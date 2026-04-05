//! Owns the Stage 1 proving entrypoint and prove-only channel builders.

use neo_math::{F, K};
use neo_reductions::sumcheck::{run_sumcheck_prover, RoundOracle};
use neo_transcript::Transcript;
use p3_field::PrimeCharacteristicRing;

use crate::chip8::kernel::KernelStepAux;
use crate::chip8::tables::ROM_ADDR_BITS;

use super::proof::Stage1ShoutProof;
use super::{
    build_alu_mixed_table, build_onehot_witness, handoff_values_at_cycle, lane_values_at_cycle, mle_eval_k,
    mle_eval_k_be, mle_eval_many_k, mle_eval_many_k_be, partial_eval_at_cycle, sample_challenge, sample_challenge_vec,
    stage1_decode_claim, stage1_eq4_claim, stage1_fetch_claim, stage1_linkage_terms, BooleanityOracle,
    DecodeConsistencyOracle, HammingWeightOracle, ShoutChannelProof, ShoutCoreOracle, DECODE_TABLE_COLUMNS,
};

pub fn stage1_alu_expected_claim(aux: &[KernelStepAux], cycle_point: &[K]) -> K {
    let alu_expected: Vec<F> = aux
        .iter()
        .map(|step| F::from_u64(step.alu_key as u64))
        .collect();
    mle_eval_k(&alu_expected, cycle_point)
}

fn prove_shout_channel<Tr: Transcript>(
    onehot: &[F],
    table: &[F],
    read_values: &[F],
    expected_addrs: &[F],
    addr_bits: usize,
    cycle_point: &[K],
    transcript: &mut Tr,
) -> Result<ShoutChannelProof, String> {
    let cycle_bits = cycle_point.len();
    let table_size = 1usize << addr_bits;
    let trace_len = 1usize << cycle_bits;
    debug_assert_eq!(onehot.len(), table_size * trace_len);
    debug_assert_eq!(table.len(), table_size);
    debug_assert_eq!(read_values.len(), trace_len);
    debug_assert_eq!(expected_addrs.len(), trace_len);

    let rv_at_r = mle_eval_k(read_values, cycle_point);
    let ra_at_r = partial_eval_at_cycle(onehot, table_size, trace_len, cycle_point);

    let mut core_oracle = ShoutCoreOracle::new(ra_at_r.clone(), table, addr_bits);
    let (core_rounds, addr_point) =
        run_sumcheck_prover(transcript, &mut core_oracle, rv_at_r).map_err(|e| format!("core sumcheck: {e}"))?;

    let mut addr_rounds = Vec::new();
    let total_bits = addr_bits + cycle_bits;

    let mut bool_oracle = BooleanityOracle::new(onehot, total_bits);
    let (bool_rounds, _) =
        run_sumcheck_prover(transcript, &mut bool_oracle, K::ZERO).map_err(|e| format!("booleanity: {e}"))?;
    addr_rounds.extend(bool_rounds);

    let mut hw_oracle = HammingWeightOracle {
        ra_at_r: ra_at_r.clone(),
        addr_bits,
    };
    let (hw_rounds, _) =
        run_sumcheck_prover(transcript, &mut hw_oracle, K::ONE).map_err(|e| format!("hamming weight: {e}"))?;
    addr_rounds.extend(hw_rounds);

    let expected_at_r = mle_eval_k(expected_addrs, cycle_point);
    let mut dc_oracle = DecodeConsistencyOracle::new(ra_at_r, addr_bits);
    let (dc_rounds, _) = run_sumcheck_prover(transcript, &mut dc_oracle, expected_at_r)
        .map_err(|e| format!("decode consistency: {e}"))?;
    addr_rounds.extend(dc_rounds);

    Ok(ShoutChannelProof {
        addr_point,
        sumcheck_rounds: core_rounds,
        addr_correctness_rounds: addr_rounds,
        address_opening_value: K::ZERO,
        read_values_at_cycle: vec![rv_at_r],
        table_opening_values: Vec::new(),
    })
}

struct ShoutCoreOracleK {
    ra_at_r: Vec<K>,
    table: Vec<K>,
    addr_bits: usize,
}

impl RoundOracle for ShoutCoreOracleK {
    fn num_rounds(&self) -> usize {
        self.addr_bits
    }

    fn degree_bound(&self) -> usize {
        2
    }

    fn evals_at(&mut self, points: &[K]) -> Vec<K> {
        let half = self.ra_at_r.len() / 2;
        points
            .iter()
            .map(|&x| {
                let one_minus_x = K::ONE - x;
                let mut acc = K::ZERO;
                for k in 0..half {
                    let ra_lo = self.ra_at_r[k];
                    let ra_hi = self.ra_at_r[half + k];
                    let t_lo = self.table[k];
                    let t_hi = self.table[half + k];
                    let ra_x = ra_lo * one_minus_x + ra_hi * x;
                    let t_x = t_lo * one_minus_x + t_hi * x;
                    acc += ra_x * t_x;
                }
                acc
            })
            .collect()
    }

    fn fold(&mut self, r: K) {
        let half = self.ra_at_r.len() / 2;
        let one_minus_r = K::ONE - r;
        for k in 0..half {
            self.ra_at_r[k] = self.ra_at_r[k] * one_minus_r + self.ra_at_r[half + k] * r;
            self.table[k] = self.table[k] * one_minus_r + self.table[half + k] * r;
        }
        self.ra_at_r.truncate(half);
        self.table.truncate(half);
    }
}

fn prove_decode_channel<Tr: Transcript>(
    onehot: &[F],
    decode_cols: &[Vec<F>],
    read_values_per_col: &[Vec<F>],
    expected_addrs: &[F],
    addr_bits: usize,
    cycle_point: &[K],
    transcript: &mut Tr,
) -> Result<ShoutChannelProof, String> {
    let cycle_bits = cycle_point.len();
    let table_size = 1usize << addr_bits;
    let trace_len = 1usize << cycle_bits;
    debug_assert_eq!(onehot.len(), table_size * trace_len);
    debug_assert_eq!(decode_cols.len(), DECODE_TABLE_COLUMNS);

    let alpha = sample_challenge(transcript, b"shout/decode_alpha");

    let n = decode_cols[0].len();
    let mut batched_table = vec![K::ZERO; n];
    let mut alpha_pow = K::ONE;
    for col in decode_cols {
        for (i, &val) in col.iter().enumerate() {
            batched_table[i] += alpha_pow * K::from(val);
        }
        alpha_pow *= alpha;
    }

    let mut rv_batched = vec![K::ZERO; trace_len];
    let mut alpha_pow = K::ONE;
    for col_rv in read_values_per_col {
        for (j, &val) in col_rv.iter().enumerate() {
            rv_batched[j] += alpha_pow * K::from(val);
        }
        alpha_pow *= alpha;
    }

    let chi_cycle = crate::chip8::poly::build_eq_table(cycle_point);
    let mut rv_at_r = K::ZERO;
    for (j, &chi_j) in chi_cycle.iter().enumerate() {
        rv_at_r += rv_batched[j] * chi_j;
    }

    let ra_at_r = partial_eval_at_cycle(onehot, table_size, trace_len, cycle_point);

    let mut core_oracle = ShoutCoreOracleK {
        ra_at_r: ra_at_r.clone(),
        table: batched_table,
        addr_bits,
    };
    let (core_rounds, addr_point) =
        run_sumcheck_prover(transcript, &mut core_oracle, rv_at_r).map_err(|e| format!("decode core: {e}"))?;

    let mut addr_rounds = Vec::new();
    let total_bits = addr_bits + cycle_bits;

    let mut bool_oracle = BooleanityOracle::new(onehot, total_bits);
    let (bool_rounds, _) =
        run_sumcheck_prover(transcript, &mut bool_oracle, K::ZERO).map_err(|e| format!("decode booleanity: {e}"))?;
    addr_rounds.extend(bool_rounds);

    let mut hw_oracle = HammingWeightOracle {
        ra_at_r: ra_at_r.clone(),
        addr_bits,
    };
    let (hw_rounds, _) =
        run_sumcheck_prover(transcript, &mut hw_oracle, K::ONE).map_err(|e| format!("decode hamming weight: {e}"))?;
    addr_rounds.extend(hw_rounds);

    let expected_at_r = mle_eval_k(expected_addrs, cycle_point);
    let mut dc_oracle = DecodeConsistencyOracle::new(ra_at_r, addr_bits);
    let (dc_rounds, _) = run_sumcheck_prover(transcript, &mut dc_oracle, expected_at_r)
        .map_err(|e| format!("decode consistency: {e}"))?;
    addr_rounds.extend(dc_rounds);

    Ok(ShoutChannelProof {
        addr_point,
        sumcheck_rounds: core_rounds,
        addr_correctness_rounds: addr_rounds,
        address_opening_value: K::ZERO,
        read_values_at_cycle: mle_eval_many_k(read_values_per_col, cycle_point),
        table_opening_values: Vec::new(),
    })
}

pub fn prove_stage1<Tr: Transcript>(
    trace_rows: &[[F; 24]],
    aux: &[KernelStepAux],
    rom_table: &[F],
    decode_table: &[Vec<F>],
    alu_table: &[F],
    eq4_table: &[F],
    cycle_bits: usize,
    transcript: &mut Tr,
) -> Result<Stage1ShoutProof, String> {
    let trace_len = 1usize << cycle_bits;
    if aux.len() != trace_len {
        return Err(format!("aux length {} != expected trace_len {}", aux.len(), trace_len));
    }

    let rom_size = rom_table.len();
    let rom_addr_bits = ROM_ADDR_BITS;
    let decode_size = decode_table[0].len();
    let decode_addr_bits = 16usize;
    let alu_addr_bits = 18usize;
    let eq4_size = eq4_table.len();
    let eq4_addr_bits = 8usize;

    debug_assert_eq!(rom_size, 1 << rom_addr_bits);
    debug_assert_eq!(decode_size, 1 << decode_addr_bits);
    debug_assert_eq!(eq4_size, 1 << eq4_addr_bits);

    let fetch_addrs: Vec<usize> = aux.iter().map(|a| a.fetch_addr).collect();
    let decode_addrs: Vec<usize> = aux.iter().map(|a| a.decode_addr as usize).collect();
    let alu_addrs: Vec<usize> = aux.iter().map(|a| a.alu_key as usize).collect();
    let eq4_addrs: Vec<usize> = aux.iter().map(|a| a.eq4_key as usize).collect();

    let cycle_point = sample_challenge_vec(transcript, b"stage1/r_lookup", cycle_bits);

    let fetch_onehot = build_onehot_witness(trace_len, rom_size, &fetch_addrs);
    let decode_onehot = build_onehot_witness(trace_len, decode_size, &decode_addrs);
    let alu_mixed_table = build_alu_mixed_table(alu_table);
    let alu_onehot = build_onehot_witness(trace_len, 1 << alu_addr_bits, &alu_addrs);
    let eq4_onehot = build_onehot_witness(trace_len, eq4_size, &eq4_addrs);

    let fetch_rv: Vec<F> = aux.iter().map(|a| rom_table[a.fetch_addr]).collect();
    let fetch_expected: Vec<F> = aux
        .iter()
        .map(|a| F::from_u64(a.fetch_addr as u64))
        .collect();

    let decode_rv_per_col: Vec<Vec<F>> = (0..DECODE_TABLE_COLUMNS)
        .map(|col| {
            aux.iter()
                .map(|a| decode_table[col][a.decode_addr as usize])
                .collect()
        })
        .collect();
    let decode_expected: Vec<F> = aux
        .iter()
        .map(|a| F::from_u64(a.decode_addr as u64))
        .collect();

    let alu_rv: Vec<F> = aux
        .iter()
        .map(|a| alu_mixed_table[a.alu_key as usize])
        .collect();
    let alu_expected: Vec<F> = aux.iter().map(|a| F::from_u64(a.alu_key as u64)).collect();

    let eq4_rv: Vec<F> = aux.iter().map(|a| eq4_table[a.eq4_key as usize]).collect();
    let eq4_expected: Vec<F> = aux.iter().map(|a| F::from_u64(a.eq4_key as u64)).collect();

    let mut fetch_proof = prove_shout_channel(
        &fetch_onehot,
        rom_table,
        &fetch_rv,
        &fetch_expected,
        rom_addr_bits,
        &cycle_point,
        transcript,
    )
    .map_err(|e| format!("fetch: {e}"))?;
    fetch_proof.address_opening_value =
        crate::chip8::poly::open_onehot_at_point_be(&fetch_addrs, &fetch_proof.addr_point, &cycle_point);
    fetch_proof.table_opening_values = vec![mle_eval_k_be(rom_table, &fetch_proof.addr_point)];

    let mut decode_proof = prove_decode_channel(
        &decode_onehot,
        decode_table,
        &decode_rv_per_col,
        &decode_expected,
        decode_addr_bits,
        &cycle_point,
        transcript,
    )
    .map_err(|e| format!("decode: {e}"))?;
    decode_proof.address_opening_value =
        crate::chip8::poly::open_onehot_at_point_be(&decode_addrs, &decode_proof.addr_point, &cycle_point);
    decode_proof.table_opening_values = mle_eval_many_k_be(decode_table, &decode_proof.addr_point);

    let mut alu_proof = prove_shout_channel(
        &alu_onehot,
        &alu_mixed_table,
        &alu_rv,
        &alu_expected,
        alu_addr_bits,
        &cycle_point,
        transcript,
    )
    .map_err(|e| format!("alu: {e}"))?;
    alu_proof.address_opening_value =
        crate::chip8::poly::open_onehot_at_point_be(&alu_addrs, &alu_proof.addr_point, &cycle_point);
    alu_proof.table_opening_values = vec![mle_eval_k_be(alu_table, &alu_proof.addr_point[2..])];

    let mut eq4_proof = prove_shout_channel(
        &eq4_onehot,
        eq4_table,
        &eq4_rv,
        &eq4_expected,
        eq4_addr_bits,
        &cycle_point,
        transcript,
    )
    .map_err(|e| format!("eq4: {e}"))?;
    eq4_proof.address_opening_value =
        crate::chip8::poly::open_onehot_at_point_be(&eq4_addrs, &eq4_proof.addr_point, &cycle_point);
    eq4_proof.table_opening_values = vec![mle_eval_k_be(eq4_table, &eq4_proof.addr_point)];

    let decode_handoff_values = handoff_values_at_cycle(aux, &cycle_point);
    let lane_values_at_lookup = lane_values_at_cycle(trace_rows, &cycle_point);
    let fetch_expected_at_lookup = mle_eval_k(&fetch_expected, &cycle_point);
    let decode_expected_at_lookup = mle_eval_k(&decode_expected, &cycle_point);
    let eq4_expected_at_lookup = mle_eval_k(&eq4_expected, &cycle_point);
    let fetch_claim = stage1_fetch_claim(&lane_values_at_lookup);
    let decode_claim = stage1_decode_claim(fetch_proof.read_values_at_cycle[0]);
    let gamma_lookup_link = sample_challenge(transcript, b"stage1/gamma_lookup_link");

    let decode = &decode_proof.read_values_at_cycle;
    let eq4_claim = stage1_eq4_claim(&lane_values_at_lookup, decode);
    if fetch_expected_at_lookup != fetch_claim {
        return Err("stage1 fetch address claim does not match PC at r_lookup".into());
    }
    if decode_expected_at_lookup != decode_claim {
        return Err("stage1 decode address claim does not match fetched opcode at r_lookup".into());
    }
    if eq4_expected_at_lookup != eq4_claim {
        return Err("stage1 Eq4 address claim does not match X_IDX/x_bound at r_lookup".into());
    }
    if decode[0] != K::ONE {
        return Err("stage1 linkage: decode valid column must equal 1 at r_lookup".into());
    }

    let burst_eq = eq4_proof.read_values_at_cycle[0];
    let alu_output = alu_proof.read_values_at_cycle[0];
    let linkage_terms = stage1_linkage_terms(
        &lane_values_at_lookup,
        decode,
        &decode_handoff_values,
        alu_output,
        burst_eq,
    );

    let mut batched_linkage = K::ZERO;
    let mut gamma_power = K::ONE;
    for term in linkage_terms {
        batched_linkage += gamma_power * term;
        gamma_power *= gamma_lookup_link;
    }
    if batched_linkage != K::ZERO {
        return Err("stage1 linkage batch failed at r_lookup".into());
    }

    Ok(Stage1ShoutProof {
        cycle_point,
        fetch_proof,
        decode_proof,
        alu_proof,
        eq4_proof,
        decode_handoff_values,
        lane_values_at_lookup,
    })
}
