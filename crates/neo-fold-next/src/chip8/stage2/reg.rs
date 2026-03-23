//! Owns the Stage 2 register-side Twist subsystem.
//! It does not own RAM-side history checks or cross-subsystem linkage batching.

use neo_math::{KExtensions, F, K};
use neo_reductions::sumcheck::{run_sumcheck_prover, RoundOracle};
use neo_transcript::Transcript;
use p3_field::PrimeCharacteristicRing;

use crate::chip8::poly::build_eq_table;
use crate::chip8::tables::{build_unmap_reg, ADDR_REG_BITS, REG_SINK_ADDR};

use crate::chip8::kernel::verify_sumcheck_known;
use crate::chip8::kernel::{KernelStepAux, SimpleKernelError};
use crate::chip8::spec::{COL_WRITES_LOOKUP_TO_X, COL_WRITES_MEM_TO_X, COL_X_IDX, COL_Y_IDX};

use super::common::{
    bool_values_from_aux, build_onehot, build_val_from_inc_factors, col_values, mle_eval_fk_be,
    mle_eval_flat_k_at_point_be, partial_eval_flat_k_at_addr_be, prove_address_correctness,
    prove_cycle_product_relation, read_port_claim, squeeze_k, squeeze_point, stage2_address_claims, write_port_claim,
};
use super::proof::{AddressCorrectnessProof, CycleProductProof, Stage2TwistProof};
use super::transcript::verify_stage2_address_correctness_transcript;

pub(crate) struct Stage2RegisterProofArtifacts {
    pub gamma_reg: K,
    pub reg_addr_point: Vec<K>,
    pub reg_val_at_point: K,
    pub reg_rw_batched_rounds: Vec<Vec<K>>,
    pub reg_val_from_inc_claim: K,
    pub reg_val_from_inc_rounds: Vec<Vec<K>>,
    pub reg_addr_correctness: Vec<AddressCorrectnessProof>,
    pub reg_ra_y_target_proof: CycleProductProof,
    pub reg_wa_addr_target_proof: CycleProductProof,
    pub rv_x_claim: K,
    pub rv_y_claim: K,
    pub rv_i_claim: K,
    pub wv_reg_claim: K,
}

pub(crate) fn prove_register_subsystem<Tr: Transcript>(
    trace_rows: &[[F; 24]],
    aux: &[KernelStepAux],
    initial_registers: &[u8; 16],
    initial_i: u16,
    cycle_bits: usize,
    r_cycle: &[K],
    eq_cycle: &[K],
    lane_values_at_twist: &[K],
    handoff_values_at_twist: &[K],
    transcript: &mut Tr,
) -> Result<Stage2RegisterProofArtifacts, SimpleKernelError> {
    let trace_len = 1usize << cycle_bits;
    let reg_domain = 1usize << ADDR_REG_BITS;

    let gamma_reg = squeeze_k(transcript, b"stage2/gamma_reg");

    let reg_ra_x_addrs: Vec<usize> = aux.iter().map(|a| a.reg_ra_x_addr).collect();
    let reg_ra_y_addrs: Vec<usize> = aux.iter().map(|a| a.reg_ra_y_addr).collect();
    let reg_ra_i_addrs: Vec<usize> = aux.iter().map(|a| a.reg_ra_i_addr).collect();
    let reg_wa_addrs: Vec<usize> = aux.iter().map(|a| a.reg_wa_addr).collect();

    let reg_ra_x = build_onehot(trace_len, reg_domain, &reg_ra_x_addrs);
    let reg_ra_y = build_onehot(trace_len, reg_domain, &reg_ra_y_addrs);
    let reg_ra_i = build_onehot(trace_len, reg_domain, &reg_ra_i_addrs);
    let reg_wa = build_onehot(trace_len, reg_domain, &reg_wa_addrs);

    let reg_inc_k: Vec<K> = aux.iter().map(|a| K::from(a.reg_inc)).collect();
    let initial_reg_values = initial_reg_values(initial_registers, initial_i);

    let reg_val = compute_reg_val(trace_len, aux, initial_registers, initial_i);
    let mut reg_val_flat = vec![K::ZERO; reg_domain * trace_len];
    for a in 0..reg_domain {
        for j in 0..trace_len {
            reg_val_flat[a * trace_len + j] = K::from(reg_val[a][j]);
        }
    }

    let mut reg_rw_oracle = RegRwOracle::new(
        cycle_bits,
        r_cycle,
        gamma_reg,
        &reg_wa,
        &reg_ra_x,
        &reg_ra_y,
        &reg_ra_i,
        &reg_inc_k,
        &reg_val_flat,
    );
    let reg_rw_claim = reg_rw_oracle.compute_claim();
    let rv_x_claim = read_port_claim(eq_cycle, &reg_ra_x, &reg_val_flat, trace_len);
    let rv_y_claim = read_port_claim(eq_cycle, &reg_ra_y, &reg_val_flat, trace_len);
    let rv_i_claim = read_port_claim(eq_cycle, &reg_ra_i, &reg_val_flat, trace_len);
    let wv_reg_claim = write_port_claim(eq_cycle, &reg_wa, &reg_inc_k, &reg_val_flat, trace_len);
    let reg_rw_expected = wv_reg_claim
        + gamma_reg * rv_x_claim
        + gamma_reg * gamma_reg * rv_y_claim
        + gamma_reg * gamma_reg * gamma_reg * rv_i_claim;
    if reg_rw_claim != reg_rw_expected {
        return Err(SimpleKernelError::SumcheckFailed(
            "stage2 reg read/write claim decomposition failed".into(),
        ));
    }

    transcript.append_fields(b"stage2/reg_rw_claim", &reg_rw_claim.as_coeffs());
    let (reg_rw_rounds, _) = run_sumcheck_prover(transcript, &mut reg_rw_oracle, reg_rw_claim)
        .map_err(|e| SimpleKernelError::SumcheckFailed(format!("reg_rw: {e}")))?;

    let reg_addr_point = squeeze_point(transcript, b"stage2/r_addr_reg", ADDR_REG_BITS);
    let reg_wa_at_addr = partial_eval_flat_k_at_addr_be(&reg_wa, &reg_addr_point, trace_len);
    let reg_val_at_point = mle_eval_flat_k_at_point_be(&reg_val_flat, &reg_addr_point, r_cycle, trace_len);
    let reg_init_at_point = mle_eval_fk_be(&initial_reg_values, &reg_addr_point);

    let val_inc_factors = build_val_from_inc_factors(cycle_bits, r_cycle, &reg_inc_k, &reg_wa_at_addr);
    let factor_count = val_inc_factors.len();
    let mut val_inc_oracle = ProductOracle::new(val_inc_factors, factor_count);
    let reg_val_delta_claim = reg_val_at_point - reg_init_at_point;
    if val_inc_oracle.sum_over_hypercube() != reg_val_delta_claim {
        return Err(SimpleKernelError::SumcheckFailed(
            "stage2 register val-from-inc does not match RegVal(r_addr_reg, r_twist_cycle) - Init(r_addr_reg)".into(),
        ));
    }

    transcript.append_fields(b"stage2/reg_val_inc_claim", &reg_val_delta_claim.as_coeffs());
    let (reg_val_rounds, _) = run_sumcheck_prover(transcript, &mut val_inc_oracle, reg_val_delta_claim)
        .map_err(|e| SimpleKernelError::SumcheckFailed(format!("reg_val_inc: {e}")))?;

    let writes_lookup_to_x = col_values(trace_rows, COL_WRITES_LOOKUP_TO_X);
    let writes_mem_to_x = col_values(trace_rows, COL_WRITES_MEM_TO_X);
    let x_idx_vals = col_values(trace_rows, COL_X_IDX);
    let y_idx_vals = col_values(trace_rows, COL_Y_IDX);
    let uses_y_vals = bool_values_from_aux(aux, |row| row.uses_y);
    let write_x_target_flag: Vec<K> = writes_lookup_to_x
        .iter()
        .zip(writes_mem_to_x.iter())
        .map(|(&lookup, &mem)| lookup + mem)
        .collect();
    let reg_ra_y_target_proof = prove_cycle_product_relation(
        transcript,
        vec![eq_cycle.to_vec(), uses_y_vals, y_idx_vals],
        3,
        b"stage2/reg_ra_y_target/claim",
        "reg_ra_y_target",
    )?;
    let reg_wa_addr_target_proof = prove_cycle_product_relation(
        transcript,
        vec![eq_cycle.to_vec(), write_x_target_flag, x_idx_vals],
        3,
        b"stage2/reg_wa_x_addr_target/claim",
        "reg_wa_x_addr_target",
    )?;

    let unmap_reg = build_unmap_reg();
    let sink_reg = K::from(F::from_u64(REG_SINK_ADDR as u64));
    let i_slot = K::from(F::from_u64(16u64));
    let mapped_reg_claims = [
        lane_values_at_twist[11],
        reg_ra_y_target_proof.claim,
        i_slot,
        reg_wa_addr_target_proof.claim + lane_values_at_twist[9] * i_slot,
    ];
    let raw_reg_claims = [
        mapped_reg_claims[0],
        mapped_reg_claims[1] + (K::ONE - handoff_values_at_twist[0]) * sink_reg,
        mapped_reg_claims[2],
        mapped_reg_claims[3]
            + (K::ONE - lane_values_at_twist[6] - lane_values_at_twist[7] - lane_values_at_twist[9]) * sink_reg,
    ];
    let reg_addr_correctness = vec![
        prove_address_correctness(
            &reg_ra_x,
            r_cycle,
            ADDR_REG_BITS,
            cycle_bits,
            mapped_reg_claims[0],
            raw_reg_claims[0],
            &unmap_reg,
            "stage2 register address family 0",
            transcript,
        )?,
        prove_address_correctness(
            &reg_ra_y,
            r_cycle,
            ADDR_REG_BITS,
            cycle_bits,
            mapped_reg_claims[1],
            raw_reg_claims[1],
            &unmap_reg,
            "stage2 register address family 1",
            transcript,
        )?,
        prove_address_correctness(
            &reg_ra_i,
            r_cycle,
            ADDR_REG_BITS,
            cycle_bits,
            mapped_reg_claims[2],
            raw_reg_claims[2],
            &unmap_reg,
            "stage2 register address family 2",
            transcript,
        )?,
        prove_address_correctness(
            &reg_wa,
            r_cycle,
            ADDR_REG_BITS,
            cycle_bits,
            mapped_reg_claims[3],
            raw_reg_claims[3],
            &unmap_reg,
            "stage2 register address family 3",
            transcript,
        )?,
    ];

    Ok(Stage2RegisterProofArtifacts {
        gamma_reg,
        reg_addr_point,
        reg_val_at_point,
        reg_rw_batched_rounds: reg_rw_rounds,
        reg_val_from_inc_claim: reg_val_delta_claim,
        reg_val_from_inc_rounds: reg_val_rounds,
        reg_addr_correctness,
        reg_ra_y_target_proof,
        reg_wa_addr_target_proof,
        rv_x_claim,
        rv_y_claim,
        rv_i_claim,
        wv_reg_claim,
    })
}

pub(crate) fn verify_register_subsystem<Tr: Transcript>(
    proof: &Stage2TwistProof,
    initial_registers: &[u8; 16],
    initial_i: u16,
    cycle_bits: usize,
    transcript: &mut Tr,
) -> Result<(), SimpleKernelError> {
    let lane = &proof.lane_values_at_twist;
    let handoff = &proof.handoff_values_at_twist;

    let expected_gamma_reg = squeeze_k(transcript, b"stage2/gamma_reg");
    if proof.gamma_reg != expected_gamma_reg {
        return Err(SimpleKernelError::OpeningFailed("stage2 gamma_reg mismatch".into()));
    }
    let reg_rw_claim = proof.link_claims.wv_reg
        + proof.gamma_reg * proof.link_claims.rv_x
        + proof.gamma_reg * proof.gamma_reg * proof.link_claims.rv_y
        + proof.gamma_reg * proof.gamma_reg * proof.gamma_reg * proof.link_claims.rv_i;
    transcript.append_fields(b"stage2/reg_rw_claim", &reg_rw_claim.as_coeffs());
    verify_sumcheck_known(
        transcript,
        3,
        reg_rw_claim,
        &proof.reg_rw_batched_rounds,
        "stage2 register read/write",
    )?;
    let expected_reg_addr_point = squeeze_point(transcript, b"stage2/r_addr_reg", ADDR_REG_BITS);
    if proof.reg_addr_point != expected_reg_addr_point {
        return Err(SimpleKernelError::OpeningFailed(
            "stage2 reg addr point mismatch".into(),
        ));
    }
    let reg_init_at_point = mle_eval_fk_be(&initial_reg_values(initial_registers, initial_i), &proof.reg_addr_point);
    if proof.reg_val_at_point - reg_init_at_point != proof.reg_val_from_inc_claim {
        return Err(SimpleKernelError::OpeningFailed(
            "stage2 register val-from-inc anchor mismatch".into(),
        ));
    }
    transcript.append_fields(b"stage2/reg_val_inc_claim", &proof.reg_val_from_inc_claim.as_coeffs());
    verify_sumcheck_known(
        transcript,
        3,
        proof.reg_val_from_inc_claim,
        &proof.reg_val_from_inc_rounds,
        "stage2 register val-from-inc",
    )?;
    transcript.append_fields(
        b"stage2/reg_ra_y_target/claim",
        &proof.reg_ra_y_target_proof.claim.as_coeffs(),
    );
    verify_sumcheck_known(
        transcript,
        3,
        proof.reg_ra_y_target_proof.claim,
        &proof.reg_ra_y_target_proof.rounds,
        "stage2 register ra_y target",
    )?;
    transcript.append_fields(
        b"stage2/reg_wa_x_addr_target/claim",
        &proof.reg_wa_addr_target_proof.claim.as_coeffs(),
    );
    verify_sumcheck_known(
        transcript,
        3,
        proof.reg_wa_addr_target_proof.claim,
        &proof.reg_wa_addr_target_proof.rounds,
        "stage2 register wa-address target",
    )?;
    let reg_wa_mapped_claim = proof.reg_wa_addr_target_proof.claim + lane[9] * K::from(F::from_u64(16u64));
    let (mapped_reg_claims, raw_reg_claims, _, _) = stage2_address_claims(
        lane,
        handoff,
        proof.reg_ra_y_target_proof.claim,
        reg_wa_mapped_claim,
        K::ZERO,
        K::ZERO,
    );
    if proof.reg_addr_correctness.len() != 4 {
        return Err(SimpleKernelError::SumcheckFailed(
            "stage2 register address correctness proof count must be 4".into(),
        ));
    }
    for (idx, addr_proof) in proof.reg_addr_correctness.iter().enumerate() {
        verify_stage2_address_correctness_transcript(
            transcript,
            addr_proof,
            ADDR_REG_BITS,
            cycle_bits,
            mapped_reg_claims[idx],
            raw_reg_claims[idx],
            &format!("stage2 register address family {idx}"),
        )?;
    }
    Ok(())
}

fn initial_reg_values(initial_registers: &[u8; 16], initial_i: u16) -> Vec<F> {
    let mut values = vec![F::ZERO; 1usize << ADDR_REG_BITS];
    for i in 0..16 {
        values[i] = F::from_u64(initial_registers[i] as u64);
    }
    values[16] = F::from_u64(initial_i as u64);
    values
}

fn compute_reg_val(
    trace_len: usize,
    aux: &[KernelStepAux],
    initial_registers: &[u8; 16],
    initial_i: u16,
) -> Vec<Vec<F>> {
    let reg_domain_size = 1usize << ADDR_REG_BITS;
    let mut val = vec![vec![F::ZERO; trace_len]; reg_domain_size];
    let mut state = initial_reg_values(initial_registers, initial_i);
    for j in 0..trace_len {
        for a in 0..reg_domain_size {
            val[a][j] = state[a];
        }
        let wa = aux[j].reg_wa_addr;
        debug_assert!(wa < reg_domain_size);
        state[wa] += aux[j].reg_inc;
    }
    val
}

struct RegRwOracle {
    eq_flat: Vec<K>,
    gamma: K,
    wa_flat: Vec<K>,
    ra_x_flat: Vec<K>,
    ra_y_flat: Vec<K>,
    ra_i_flat: Vec<K>,
    inc_flat: Vec<K>,
    val_flat: Vec<K>,
    total_bits: usize,
}

impl RegRwOracle {
    fn new(
        cycle_bits: usize,
        r_cycle: &[K],
        gamma: K,
        wa: &[K],
        ra_x: &[K],
        ra_y: &[K],
        ra_i: &[K],
        inc: &[K],
        val: &[K],
    ) -> Self {
        let trace_len = 1usize << cycle_bits;
        let addr_bits = ADDR_REG_BITS;
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
            wa_flat: wa.to_vec(),
            ra_x_flat: ra_x.to_vec(),
            ra_y_flat: ra_y.to_vec(),
            ra_i_flat: ra_i.to_vec(),
            inc_flat,
            val_flat: val.to_vec(),
            total_bits,
        }
    }

    fn compute_claim(&self) -> K {
        let mut acc = K::ZERO;
        let gamma2 = self.gamma * self.gamma;
        let gamma3 = gamma2 * self.gamma;
        for idx in 0..self.eq_flat.len() {
            let v = self.val_flat[idx];
            acc += self.eq_flat[idx]
                * (self.wa_flat[idx] * (self.inc_flat[idx] + v)
                    + self.gamma * self.ra_x_flat[idx] * v
                    + gamma2 * self.ra_y_flat[idx] * v
                    + gamma3 * self.ra_i_flat[idx] * v);
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

impl RoundOracle for RegRwOracle {
    fn num_rounds(&self) -> usize {
        self.total_bits
    }

    fn degree_bound(&self) -> usize {
        3
    }

    fn evals_at(&mut self, points: &[K]) -> Vec<K> {
        let half = 1usize << (self.total_bits - 1);
        let gamma2 = self.gamma * self.gamma;
        let gamma3 = gamma2 * self.gamma;
        points
            .iter()
            .map(|&x| {
                let mut acc = K::ZERO;
                for pair in 0..half {
                    let lo = 2 * pair;
                    let hi = lo + 1;
                    let eq_x = self.eq_flat[lo] + (self.eq_flat[hi] - self.eq_flat[lo]) * x;
                    let wa_x = self.wa_flat[lo] + (self.wa_flat[hi] - self.wa_flat[lo]) * x;
                    let rax_x = self.ra_x_flat[lo] + (self.ra_x_flat[hi] - self.ra_x_flat[lo]) * x;
                    let ray_x = self.ra_y_flat[lo] + (self.ra_y_flat[hi] - self.ra_y_flat[lo]) * x;
                    let rai_x = self.ra_i_flat[lo] + (self.ra_i_flat[hi] - self.ra_i_flat[lo]) * x;
                    let inc_x = self.inc_flat[lo] + (self.inc_flat[hi] - self.inc_flat[lo]) * x;
                    let val_x = self.val_flat[lo] + (self.val_flat[hi] - self.val_flat[lo]) * x;
                    acc += eq_x
                        * (wa_x * (inc_x + val_x)
                            + self.gamma * rax_x * val_x
                            + gamma2 * ray_x * val_x
                            + gamma3 * rai_x * val_x);
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
        fold_vec(&mut self.wa_flat, half, r);
        fold_vec(&mut self.ra_x_flat, half, r);
        fold_vec(&mut self.ra_y_flat, half, r);
        fold_vec(&mut self.ra_i_flat, half, r);
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
