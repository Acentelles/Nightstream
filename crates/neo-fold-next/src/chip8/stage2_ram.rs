//! Owns the Stage 2 RAM-side Twist subsystem.
//! It does not own register-side history checks or final Stage 2 linkage batching.

use neo_math::{KExtensions, F, K};
use neo_reductions::sumcheck::{run_sumcheck_prover, RoundOracle};
use neo_transcript::Transcript;
use p3_field::PrimeCharacteristicRing;

use crate::chip8::poly::build_eq_table;
use crate::chip8::tables::{build_unmap_ram, ADDR_RAM_BITS};

use super::kernel::verify_sumcheck_known;
use super::kernel::{
    verify_stage2_address_correctness_transcript, AddressCorrectnessProof, KernelStepAux, SimpleKernelError,
    Stage2TwistProof,
};
use super::spec::COL_RAM_ADDR;
use super::stage2::{
    build_onehot, build_val_from_inc_factors, mle_eval_fk, mle_eval_fk_be, mle_eval_flat_k_at_point_be,
    partial_eval_flat_k_at_addr_be, prove_address_correctness, prove_raf, read_port_claim, squeeze_k, squeeze_point,
    stage2_address_claims, write_port_claim,
};

pub(crate) struct Stage2RamProofArtifacts {
    pub gamma_ram: K,
    pub ram_addr_point: Vec<K>,
    pub ram_val_at_point: K,
    pub ram_rw_batched_rounds: Vec<Vec<K>>,
    pub ram_val_from_inc_claim: K,
    pub ram_val_from_inc_rounds: Vec<Vec<K>>,
    pub ram_raf_read_claim: K,
    pub ram_raf_read_rounds: Vec<Vec<K>>,
    pub ram_raf_write_claim: K,
    pub ram_raf_write_rounds: Vec<Vec<K>>,
    pub ram_addr_correctness: Vec<AddressCorrectnessProof>,
    pub rv_ram_claim: K,
    pub wv_ram_claim: K,
}

pub(crate) fn prove_ram_subsystem<Tr: Transcript>(
    trace_rows: &[[F; 24]],
    aux: &[KernelStepAux],
    initial_ram: &[u8],
    cycle_bits: usize,
    r_cycle: &[K],
    eq_cycle: &[K],
    lane_values_at_twist: &[K],
    handoff_values_at_twist: &[K],
    reg_ra_y_target_claim: K,
    reg_wa_mapped_claim: K,
    transcript: &mut Tr,
) -> Result<Stage2RamProofArtifacts, SimpleKernelError> {
    let trace_len = 1usize << cycle_bits;
    let ram_domain = 1usize << ADDR_RAM_BITS;

    let gamma_ram = squeeze_k(transcript, b"stage2/gamma_ram");

    let ram_ra_addrs: Vec<usize> = aux.iter().map(|a| a.ram_ra_addr).collect();
    let ram_wa_addrs: Vec<usize> = aux.iter().map(|a| a.ram_wa_addr).collect();

    let ram_ra = build_onehot(trace_len, ram_domain, &ram_ra_addrs);
    let ram_wa = build_onehot(trace_len, ram_domain, &ram_wa_addrs);

    let ram_inc_k: Vec<K> = aux.iter().map(|a| K::from(a.ram_inc)).collect();
    let initial_ram_values = initial_ram_values(initial_ram);

    let ram_val = compute_ram_val(trace_len, aux, initial_ram);
    let mut ram_val_flat = vec![K::ZERO; ram_domain * trace_len];
    for a in 0..ram_domain {
        for j in 0..trace_len {
            ram_val_flat[a * trace_len + j] = K::from(ram_val[a][j]);
        }
    }

    let mut ram_rw_oracle = RamRwOracle::new(
        cycle_bits,
        r_cycle,
        gamma_ram,
        &ram_ra,
        &ram_wa,
        &ram_inc_k,
        &ram_val_flat,
    );
    let ram_rw_claim = ram_rw_oracle.compute_claim();
    let rv_ram_claim = read_port_claim(eq_cycle, &ram_ra, &ram_val_flat, trace_len);
    let wv_ram_claim = write_port_claim(eq_cycle, &ram_wa, &ram_inc_k, &ram_val_flat, trace_len);
    let ram_rw_expected = rv_ram_claim + gamma_ram * wv_ram_claim;
    if ram_rw_claim != ram_rw_expected {
        return Err(SimpleKernelError::SumcheckFailed(
            "stage2 ram read/write claim decomposition failed".into(),
        ));
    }

    transcript.append_fields(b"stage2/ram_rw_claim", &ram_rw_claim.as_coeffs());
    let (ram_rw_rounds, _) = run_sumcheck_prover(transcript, &mut ram_rw_oracle, ram_rw_claim)
        .map_err(|e| SimpleKernelError::SumcheckFailed(format!("ram_rw: {e}")))?;

    let ram_addr_point = squeeze_point(transcript, b"stage2/r_addr_ram", ADDR_RAM_BITS);
    let ram_wa_at_addr = partial_eval_flat_k_at_addr_be(&ram_wa, &ram_addr_point, trace_len);
    let ram_val_at_point = mle_eval_flat_k_at_point_be(&ram_val_flat, &ram_addr_point, r_cycle, trace_len);
    let ram_init_at_point = mle_eval_fk_be(&initial_ram_values, &ram_addr_point);

    let ram_val_inc_factors = build_val_from_inc_factors(cycle_bits, r_cycle, &ram_inc_k, &ram_wa_at_addr);
    let factor_count = ram_val_inc_factors.len();
    let mut ram_val_inc_oracle = ProductOracle::new(ram_val_inc_factors, factor_count);
    let ram_val_delta_claim = ram_val_at_point - ram_init_at_point;
    if ram_val_inc_oracle.sum_over_hypercube() != ram_val_delta_claim {
        return Err(SimpleKernelError::SumcheckFailed(
            "stage2 RAM val-from-inc does not match RamVal(r_addr_ram, r_twist_cycle) - Init(r_addr_ram)".into(),
        ));
    }

    transcript.append_fields(b"stage2/ram_val_inc_claim", &ram_val_delta_claim.as_coeffs());
    let (ram_val_rounds, _) = run_sumcheck_prover(transcript, &mut ram_val_inc_oracle, ram_val_delta_claim)
        .map_err(|e| SimpleKernelError::SumcheckFailed(format!("ram_val_inc: {e}")))?;

    let unmap_ram = build_unmap_ram();

    let reads_ram_vals: Vec<F> = aux
        .iter()
        .map(|a| if a.reads_ram { F::ONE } else { F::ZERO })
        .collect();
    let ram_addr_vals: Vec<F> = trace_rows.iter().map(|row| row[COL_RAM_ADDR]).collect();
    let masked_ram_read_addr_vals: Vec<F> = reads_ram_vals
        .iter()
        .zip(ram_addr_vals.iter())
        .map(|(&reads, &addr)| reads * addr)
        .collect();
    let raf_read_claim = mle_eval_fk(&masked_ram_read_addr_vals, r_cycle);
    let ram_raf_read_rounds = prove_raf(
        &ram_ra,
        r_cycle,
        ADDR_RAM_BITS,
        cycle_bits,
        raf_read_claim,
        &unmap_ram,
        transcript,
    )?;

    let writes_ram_vals: Vec<F> = aux
        .iter()
        .map(|a| if a.writes_ram { F::ONE } else { F::ZERO })
        .collect();
    let ram_wa_addr_vals: Vec<F> = trace_rows.iter().map(|row| row[COL_RAM_ADDR]).collect();
    let masked_ram_write_addr_vals: Vec<F> = writes_ram_vals
        .iter()
        .zip(ram_wa_addr_vals.iter())
        .map(|(&writes, &addr)| writes * addr)
        .collect();
    let raf_write_claim = mle_eval_fk(&masked_ram_write_addr_vals, r_cycle);
    let ram_raf_write_rounds = prove_raf(
        &ram_wa,
        r_cycle,
        ADDR_RAM_BITS,
        cycle_bits,
        raf_write_claim,
        &unmap_ram,
        transcript,
    )?;

    let (_, _, mapped_ram_claims, raw_ram_claims) = stage2_address_claims(
        lane_values_at_twist,
        handoff_values_at_twist,
        reg_ra_y_target_claim,
        reg_wa_mapped_claim,
        raf_read_claim,
        raf_write_claim,
    );
    let ram_addr_correctness = vec![
        prove_address_correctness(
            &ram_ra,
            r_cycle,
            ADDR_RAM_BITS,
            cycle_bits,
            mapped_ram_claims[0],
            raw_ram_claims[0],
            &unmap_ram,
            "stage2 RAM address family 0",
            transcript,
        )?,
        prove_address_correctness(
            &ram_wa,
            r_cycle,
            ADDR_RAM_BITS,
            cycle_bits,
            mapped_ram_claims[1],
            raw_ram_claims[1],
            &unmap_ram,
            "stage2 RAM address family 1",
            transcript,
        )?,
    ];

    Ok(Stage2RamProofArtifacts {
        gamma_ram,
        ram_addr_point,
        ram_val_at_point,
        ram_rw_batched_rounds: ram_rw_rounds,
        ram_val_from_inc_claim: ram_val_delta_claim,
        ram_val_from_inc_rounds: ram_val_rounds,
        ram_raf_read_claim: raf_read_claim,
        ram_raf_read_rounds,
        ram_raf_write_claim: raf_write_claim,
        ram_raf_write_rounds,
        ram_addr_correctness,
        rv_ram_claim,
        wv_ram_claim,
    })
}

pub(crate) fn verify_ram_subsystem<Tr: Transcript>(
    proof: &Stage2TwistProof,
    initial_ram: &[u8],
    cycle_bits: usize,
    transcript: &mut Tr,
) -> Result<(), SimpleKernelError> {
    let lane = &proof.lane_values_at_twist;
    let handoff = &proof.handoff_values_at_twist;

    let expected_gamma_ram = squeeze_k(transcript, b"stage2/gamma_ram");
    if proof.gamma_ram != expected_gamma_ram {
        return Err(SimpleKernelError::OpeningFailed("stage2 gamma_ram mismatch".into()));
    }
    let ram_rw_claim = proof.link_claims.rv_ram + proof.gamma_ram * proof.link_claims.wv_ram;
    transcript.append_fields(b"stage2/ram_rw_claim", &ram_rw_claim.as_coeffs());
    verify_sumcheck_known(
        transcript,
        3,
        ram_rw_claim,
        &proof.ram_rw_batched_rounds,
        "stage2 RAM read/write",
    )?;
    let expected_ram_addr_point = squeeze_point(transcript, b"stage2/r_addr_ram", ADDR_RAM_BITS);
    if proof.ram_addr_point != expected_ram_addr_point {
        return Err(SimpleKernelError::OpeningFailed(
            "stage2 RAM addr point mismatch".into(),
        ));
    }
    let ram_init_at_point = mle_eval_fk_be(&initial_ram_values(initial_ram), &proof.ram_addr_point);
    if proof.ram_val_at_point - ram_init_at_point != proof.ram_val_from_inc_claim {
        return Err(SimpleKernelError::OpeningFailed(
            "stage2 RAM val-from-inc anchor mismatch".into(),
        ));
    }
    transcript.append_fields(b"stage2/ram_val_inc_claim", &proof.ram_val_from_inc_claim.as_coeffs());
    verify_sumcheck_known(
        transcript,
        3,
        proof.ram_val_from_inc_claim,
        &proof.ram_val_from_inc_rounds,
        "stage2 RAM val-from-inc",
    )?;

    verify_sumcheck_known(
        transcript,
        2,
        proof.ram_raf_read_claim,
        &proof.ram_raf_read_rounds,
        "stage2 RAM raf-read",
    )?;
    verify_sumcheck_known(
        transcript,
        2,
        proof.ram_raf_write_claim,
        &proof.ram_raf_write_rounds,
        "stage2 RAM raf-write",
    )?;
    let (_, _, mapped_ram_claims, raw_ram_claims) = stage2_address_claims(
        lane,
        handoff,
        K::ZERO,
        K::ZERO,
        proof.ram_raf_read_claim,
        proof.ram_raf_write_claim,
    );
    if proof.ram_addr_correctness.len() != 2 {
        return Err(SimpleKernelError::SumcheckFailed(
            "stage2 RAM address correctness proof count must be 2".into(),
        ));
    }
    for (idx, addr_proof) in proof.ram_addr_correctness.iter().enumerate() {
        verify_stage2_address_correctness_transcript(
            transcript,
            addr_proof,
            ADDR_RAM_BITS,
            cycle_bits,
            mapped_ram_claims[idx],
            raw_ram_claims[idx],
            &format!("stage2 RAM address family {idx}"),
        )?;
    }
    Ok(())
}

fn initial_ram_values(initial_ram: &[u8]) -> Vec<F> {
    let mut values = vec![F::ZERO; 1usize << ADDR_RAM_BITS];
    for (idx, &byte) in initial_ram.iter().enumerate().take(4096) {
        values[idx] = F::from_u64(byte as u64);
    }
    values
}

fn compute_ram_val(trace_len: usize, aux: &[KernelStepAux], initial_ram: &[u8]) -> Vec<Vec<F>> {
    let ram_domain_size = 1usize << ADDR_RAM_BITS;
    let mut val = vec![vec![F::ZERO; trace_len]; ram_domain_size];
    let mut state = initial_ram_values(initial_ram);
    for j in 0..trace_len {
        for a in 0..ram_domain_size {
            val[a][j] = state[a];
        }
        let wa = aux[j].ram_wa_addr;
        debug_assert!(wa < ram_domain_size);
        state[wa] += aux[j].ram_inc;
    }
    val
}

struct RamRwOracle {
    eq_flat: Vec<K>,
    gamma: K,
    ra_flat: Vec<K>,
    wa_flat: Vec<K>,
    inc_flat: Vec<K>,
    val_flat: Vec<K>,
    total_bits: usize,
}

impl RamRwOracle {
    fn new(cycle_bits: usize, r_cycle: &[K], gamma: K, ra: &[K], wa: &[K], inc: &[K], val: &[K]) -> Self {
        let trace_len = 1usize << cycle_bits;
        let addr_bits = ADDR_RAM_BITS;
        let domain = 1usize << addr_bits;
        let flat_size = domain * trace_len;
        let total_bits = addr_bits + cycle_bits;

        let eq_cycle = build_eq_table(r_cycle);
        let mut eq_flat = vec![K::ZERO; flat_size];
        let mut inc_flat = vec![K::ZERO; flat_size];
        for a in 0..domain {
            for j in 0..trace_len {
                eq_flat[a * trace_len + j] = eq_cycle[j];
                inc_flat[a * trace_len + j] = inc[j];
            }
        }

        Self {
            eq_flat,
            gamma,
            ra_flat: ra.to_vec(),
            wa_flat: wa.to_vec(),
            inc_flat,
            val_flat: val.to_vec(),
            total_bits,
        }
    }

    fn compute_claim(&self) -> K {
        let mut acc = K::ZERO;
        for idx in 0..self.eq_flat.len() {
            acc += self.eq_flat[idx]
                * (self.ra_flat[idx] * self.val_flat[idx]
                    + self.gamma * self.wa_flat[idx] * (self.inc_flat[idx] + self.val_flat[idx]));
        }
        acc
    }
}

fn fold_vec(v: &mut Vec<K>, half: usize, r: K) {
    for idx in 0..half {
        v[idx] = v[2 * idx] + (v[2 * idx + 1] - v[2 * idx]) * r;
    }
    v.truncate(half);
}

impl RoundOracle for RamRwOracle {
    fn num_rounds(&self) -> usize {
        self.total_bits
    }

    fn degree_bound(&self) -> usize {
        3
    }

    fn evals_at(&mut self, points: &[K]) -> Vec<K> {
        let half = 1usize << (self.total_bits - 1);
        points
            .iter()
            .map(|&x| {
                let mut acc = K::ZERO;
                for pair in 0..half {
                    let lo = 2 * pair;
                    let hi = lo + 1;
                    let ra_x = self.ra_flat[lo] + (self.ra_flat[hi] - self.ra_flat[lo]) * x;
                    let wa_x = self.wa_flat[lo] + (self.wa_flat[hi] - self.wa_flat[lo]) * x;
                    let val_x = self.val_flat[lo] + (self.val_flat[hi] - self.val_flat[lo]) * x;
                    let inc_x = self.inc_flat[lo] + (self.inc_flat[hi] - self.inc_flat[lo]) * x;
                    let eq_x = self.eq_flat[lo] + (self.eq_flat[hi] - self.eq_flat[lo]) * x;
                    acc += eq_x * (ra_x * val_x + self.gamma * wa_x * (inc_x + val_x));
                }
                acc
            })
            .collect()
    }

    fn fold(&mut self, r: K) {
        if self.total_bits == 0 {
            return;
        }
        let half = 1usize << (self.total_bits - 1);
        fold_vec(&mut self.eq_flat, half, r);
        fold_vec(&mut self.ra_flat, half, r);
        fold_vec(&mut self.wa_flat, half, r);
        fold_vec(&mut self.inc_flat, half, r);
        fold_vec(&mut self.val_flat, half, r);
        self.total_bits -= 1;
    }
}

struct ProductOracle {
    factors: Vec<Vec<K>>,
    degree_bound: usize,
}

impl ProductOracle {
    fn new(factors: Vec<Vec<K>>, degree_bound: usize) -> Self {
        Self { factors, degree_bound }
    }

    fn sum_over_hypercube(&self) -> K {
        let n = self.factors.first().map(|factor| factor.len()).unwrap_or(0);
        (0..n)
            .map(|idx| {
                self.factors
                    .iter()
                    .fold(K::ONE, |acc, factor| acc * factor[idx])
            })
            .fold(K::ZERO, |acc, value| acc + value)
    }
}

impl RoundOracle for ProductOracle {
    fn num_rounds(&self) -> usize {
        self.factors
            .first()
            .map(|factor| factor.len().ilog2() as usize)
            .unwrap_or(0)
    }

    fn degree_bound(&self) -> usize {
        self.degree_bound
    }

    fn evals_at(&mut self, points: &[K]) -> Vec<K> {
        let half = self.factors[0].len() / 2;
        points
            .iter()
            .map(|&x| {
                let one_minus_x = K::ONE - x;
                let mut acc = K::ZERO;
                for idx in 0..half {
                    let product = self.factors.iter().fold(K::ONE, |prod, factor| {
                        let lo = factor[idx];
                        let hi = factor[half + idx];
                        prod * (lo * one_minus_x + hi * x)
                    });
                    acc += product;
                }
                acc
            })
            .collect()
    }

    fn fold(&mut self, r: K) {
        let half = self.factors[0].len() / 2;
        let one_minus_r = K::ONE - r;
        for factor in &mut self.factors {
            for idx in 0..half {
                factor[idx] = factor[idx] * one_minus_r + factor[half + idx] * r;
            }
            factor.truncate(half);
        }
    }
}
