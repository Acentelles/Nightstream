use std::fmt::Write as _;
use std::fs;
use std::path::PathBuf;

use crate::neo_fold_artifacts::{self, ArtifactRepr};

use neo_ajtai::Commitment;
use neo_ccs::relations::CeClaim;
use neo_ccs::traits::SModuleHomomorphism;
use neo_fold::pi_ccs::FoldingMode;
use neo_fold::riscv_trace_shard::Rv32TraceWiring;
use neo_fold::shard::{
    fold_shard_prove_with_output_binding, fold_shard_prove_with_witnesses_and_audit,
    fold_shard_prove_with_witnesses_with_step_offset_and_audit, fold_shard_verify,
    fold_shard_verify_with_output_binding, fold_shard_verify_with_step_offset,
};
use neo_math::KExtensions;
use neo_memory::ajtai::encode_vector_for_ccs_m;
use neo_memory::witness::StepInstanceBundle;
use neo_memory::riscv::lookups::{encode_program, RiscvInstruction, RiscvMemOp, RiscvOpcode};
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::{PrimeCharacteristicRing, PrimeField64};

type F = neo_math::F;
type K = neo_math::K;

#[path = "../../../../crates/neo-fold/tests/common/fixtures.rs"]
mod fixtures;

#[derive(Clone)]
struct SessionOutputClaimRepr {
    addr: u64,
    value: u64,
}

#[derive(Clone)]
struct SessionOutputBindingRepr {
    mem_idx: usize,
    num_bits: usize,
    claims: Vec<SessionOutputClaimRepr>,
    final_state: Vec<u64>,
    proof_has_output_binding: bool,
}

#[derive(Clone)]
struct SessionCaseRepr {
    scenario_name: String,
    should_fail: bool,
    public_step_count: usize,
    proof_step_count: usize,
    fold_count: usize,
    segment_proof_step_counts: Vec<usize>,
    segment_initial_accumulator_sizes: Vec<usize>,
    segment_final_accumulator_sizes: Vec<usize>,
    segment_initial_main_digests: Vec<u64>,
    segment_final_main_digests: Vec<u64>,
    segment_initial_val_digests: Vec<Option<u64>>,
    segment_final_val_digests: Vec<Option<u64>>,
    segment_artifact_indices: Vec<usize>,
    step_link_pairs: Vec<(usize, usize)>,
    step_xs: Vec<Vec<u64>>,
    output_binding: Option<SessionOutputBindingRepr>,
}

struct SessionExportBundle {
    case: SessionCaseRepr,
    segment_artifacts: Vec<ArtifactRepr>,
}

const FNV_OFFSET_BASIS: u64 = 0xcbf29ce484222325;
const FNV_PRIME: u64 = 0x100000001b3;

fn f_u64(x: F) -> u64 {
    x.as_canonical_u64()
}

fn fmt_nat_array(vals: &[u64]) -> String {
    let mut s = String::new();
    s.push_str("#[");
    for (i, v) in vals.iter().enumerate() {
        if i != 0 {
            s.push_str(", ");
        }
        let _ = write!(s, "{v}");
    }
    s.push(']');
    s
}

fn fmt_nat_array2(vals: &[Vec<u64>]) -> String {
    let mut s = String::new();
    s.push_str("#[");
    for (i, row) in vals.iter().enumerate() {
        if i != 0 {
            s.push_str(", ");
        }
        s.push_str(&fmt_nat_array(row));
    }
    s.push(']');
    s
}

fn fmt_pair_array(vals: &[(usize, usize)]) -> String {
    let mut s = String::new();
    s.push_str("#[");
    for (i, (a, b)) in vals.iter().enumerate() {
        if i != 0 {
            s.push_str(", ");
        }
        let _ = write!(s, "({a}, {b})");
    }
    s.push(']');
    s
}

fn fmt_usize_array(vals: &[usize]) -> String {
    let mut s = String::new();
    s.push_str("#[");
    for (i, v) in vals.iter().enumerate() {
        if i != 0 {
            s.push_str(", ");
        }
        let _ = write!(s, "{v}");
    }
    s.push(']');
    s
}

fn fmt_option_u64_array(vals: &[Option<u64>]) -> String {
    let mut s = String::new();
    s.push_str("#[");
    for (i, v) in vals.iter().enumerate() {
        if i != 0 {
            s.push_str(", ");
        }
        match v {
            Some(value) => {
                let _ = write!(s, "some {value}");
            }
            None => s.push_str("none"),
        }
    }
    s.push(']');
    s
}

fn fmt_output_claims(vals: &[SessionOutputClaimRepr]) -> String {
    let mut s = String::new();
    s.push_str("#[");
    for (i, claim) in vals.iter().enumerate() {
        if i != 0 {
            s.push_str(", ");
        }
        let _ = write!(s, "{{ addr := {}, value := {} }}", claim.addr, claim.value);
    }
    s.push(']');
    s
}

fn fmt_output_binding(ob: &Option<SessionOutputBindingRepr>) -> String {
    match ob {
        None => "none".to_string(),
        Some(ob) => format!(
            "some {{ memIdx := {}, numBits := {}, claims := {}, finalState := {}, proofHasOutputBinding := {} }}",
            ob.mem_idx,
            ob.num_bits,
            fmt_output_claims(&ob.claims),
            fmt_nat_array(&ob.final_state),
            if ob.proof_has_output_binding { "true" } else { "false" }
        ),
    }
}

fn fnv_mix_u64(state: &mut u64, value: u64) {
    *state ^= value;
    *state = state.wrapping_mul(FNV_PRIME);
}

fn digest_field_elems(state: &mut u64, vals: impl IntoIterator<Item = u64>) {
    for value in vals {
        fnv_mix_u64(state, value);
    }
}

fn digest_k_elems(state: &mut u64, vals: impl IntoIterator<Item = K>) {
    for value in vals {
        let coeffs = value.as_coeffs();
        fnv_mix_u64(state, coeffs[0].as_canonical_u64());
        fnv_mix_u64(state, coeffs[1].as_canonical_u64());
    }
}

fn digest_claim_paper_core(state: &mut u64, claim: &CeClaim<Commitment, F, K>) {
    fnv_mix_u64(state, claim.m_in as u64);
    fnv_mix_u64(state, claim.c.kappa as u64);
    for col in 0..claim.c.kappa {
        let column = claim.c.col(col);
        fnv_mix_u64(state, column.len() as u64);
        digest_field_elems(state, column.iter().map(|&x| f_u64(x)));
    }
    fnv_mix_u64(state, claim.r.len() as u64);
    digest_k_elems(state, claim.r.iter().copied());
    fnv_mix_u64(state, claim.s_col.len() as u64);
    digest_k_elems(state, claim.s_col.iter().copied());
    fnv_mix_u64(state, claim.X.rows() as u64);
    fnv_mix_u64(state, claim.X.cols() as u64);
    for row in 0..claim.X.rows() {
        digest_field_elems(state, (0..claim.X.cols()).map(|col| f_u64(claim.X[(row, col)])));
    }
    fnv_mix_u64(state, claim.y_ring.len() as u64);
    for row in &claim.y_ring {
        fnv_mix_u64(state, row.len() as u64);
        digest_k_elems(state, row.iter().copied());
    }
    fnv_mix_u64(state, claim.ct.len() as u64);
    digest_k_elems(state, claim.ct.iter().copied());
    fnv_mix_u64(state, claim.aux_openings.len() as u64);
    digest_k_elems(state, claim.aux_openings.iter().copied());
    fnv_mix_u64(state, claim.y_zcol.len() as u64);
    digest_k_elems(state, claim.y_zcol.iter().copied());
}

fn digest_claims_paper_core(claims: &[CeClaim<Commitment, F, K>]) -> u64 {
    let mut state = FNV_OFFSET_BASIS;
    fnv_mix_u64(&mut state, claims.len() as u64);
    for claim in claims {
        digest_claim_paper_core(&mut state, claim);
    }
    state
}

fn initial_main_digest_for_claims(claims: &[CeClaim<Commitment, F, K>]) -> u64 {
    if claims.is_empty() {
        0
    } else {
        digest_claims_paper_core(claims)
    }
}

fn maybe_digest_claims_paper_core(claims: &[CeClaim<Commitment, F, K>]) -> Option<u64> {
    if claims.is_empty() {
        None
    } else {
        Some(digest_claims_paper_core(claims))
    }
}

fn final_accumulator_size_from_proof(proof: &neo_fold::shard::ShardProof) -> usize {
    proof.steps.last().map(|step| step.fold.dec_children.len()).unwrap_or(0)
}

fn final_accumulator_digests_from_proof(
    proof: &neo_fold::shard::ShardProof,
) -> (u64, Option<u64>) {
    let outputs = proof.compute_fold_outputs(&[]);
    (
        digest_claims_paper_core(&outputs.obligations.main),
        maybe_digest_claims_paper_core(&outputs.obligations.val),
    )
}

fn output_binding_repr_from_run(
    run: &neo_fold::riscv_trace_shard::Rv32TraceWiringRun,
    proof_has_output_binding: bool,
) -> Option<SessionOutputBindingRepr> {
    run.output_binding_cfg().map(|cfg| SessionOutputBindingRepr {
        mem_idx: cfg.mem_idx,
        num_bits: cfg.num_bits,
        claims: cfg
            .program_io
            .claims()
            .map(|(addr, value)| SessionOutputClaimRepr {
                addr,
                value: f_u64(value),
            })
            .collect(),
        final_state: run
            .output_binding_target_state()
            .expect("output binding target state must be present when cfg is present")
            .iter()
            .copied()
            .map(f_u64)
            .collect(),
        proof_has_output_binding,
    })
}

fn step_xs_from_instances(
    steps: &[StepInstanceBundle<Commitment, F, K>],
) -> Vec<Vec<u64>> {
    steps.iter()
        .map(|step| step.mcs_inst.x.iter().copied().map(f_u64).collect())
        .collect()
}

fn run_to_case(scenario_name: &str, should_fail: bool, run: &neo_fold::riscv_trace_shard::Rv32TraceWiringRun) -> SessionCaseRepr {
    let steps_public = run.steps_public();
    let final_acc_size = final_accumulator_size_from_proof(run.proof());
    let (final_main_digest, final_val_digest) = final_accumulator_digests_from_proof(run.proof());
    let output_binding = output_binding_repr_from_run(run, run.proof().output_proof.is_some());

    SessionCaseRepr {
        scenario_name: scenario_name.to_string(),
        should_fail,
        public_step_count: steps_public.len(),
        proof_step_count: run.proof().steps.len(),
        fold_count: run.fold_count(),
        segment_proof_step_counts: vec![run.proof().steps.len()],
        segment_initial_accumulator_sizes: vec![0],
        segment_final_accumulator_sizes: vec![final_acc_size],
        segment_initial_main_digests: vec![initial_main_digest_for_claims(&[])],
        segment_final_main_digests: vec![final_main_digest],
        segment_initial_val_digests: vec![None],
        segment_final_val_digests: vec![final_val_digest],
        segment_artifact_indices: vec![],
        step_link_pairs: run.step_linking_pairs().to_vec(),
        step_xs: step_xs_from_instances(&steps_public),
        output_binding,
    }
}

fn reg_output_single_step_valid() -> SessionCaseRepr {
    let program = vec![
        RiscvInstruction::IAlu {
            op: RiscvOpcode::Add,
            rd: 2,
            rs1: 0,
            imm: 3,
        },
        RiscvInstruction::Halt,
    ];
    let program_bytes = encode_program(&program);
    let mut run = Rv32TraceWiring::from_rom(0, &program_bytes)
        .reg_output_claim(2, F::from_u64(3))
        .max_steps(program.len())
        .prove()
        .expect("single-step reg-output session should prove");
    run.verify().expect("single-step reg-output session should verify");
    run_to_case("rv32_reg_output_single_step", false, &run)
}

fn chunked_reg_output_multistep_valid() -> SessionCaseRepr {
    let program = vec![
        RiscvInstruction::IAlu {
            op: RiscvOpcode::Add,
            rd: 1,
            rs1: 0,
            imm: 1,
        },
        RiscvInstruction::IAlu {
            op: RiscvOpcode::Add,
            rd: 2,
            rs1: 1,
            imm: 2,
        },
        RiscvInstruction::Halt,
    ];
    let program_bytes = encode_program(&program);
    let mut run = Rv32TraceWiring::from_rom(0, &program_bytes)
        .chunk_rows(2)
        .reg_output_claim(2, F::from_u64(3))
        .max_steps(program.len())
        .prove()
        .expect("chunked reg-output session should prove");
    run.verify().expect("chunked reg-output session should verify");
    run_to_case("rv32_chunked_reg_output_multistep", false, &run)
}

fn chunked_ram_output_multistep_valid() -> SessionCaseRepr {
    let program = vec![
        RiscvInstruction::IAlu {
            op: RiscvOpcode::Add,
            rd: 1,
            rs1: 0,
            imm: 4,
        },
        RiscvInstruction::IAlu {
            op: RiscvOpcode::Add,
            rd: 2,
            rs1: 0,
            imm: 7,
        },
        RiscvInstruction::Store {
            op: RiscvMemOp::Sw,
            rs1: 1,
            rs2: 2,
            imm: 0,
        },
        RiscvInstruction::Halt,
    ];
    let program_bytes = encode_program(&program);
    let mut run = Rv32TraceWiring::from_rom(0, &program_bytes)
        .chunk_rows(2)
        .output_claim(4, F::from_u64(7))
        .max_steps(program.len())
        .prove()
        .expect("chunked RAM-output session should prove");
    run.verify().expect("chunked RAM-output session should verify");
    run_to_case("rv32_chunked_ram_output_multistep", false, &run)
}

fn chunked_link_only_valid() -> SessionCaseRepr {
    let program = vec![
        RiscvInstruction::IAlu {
            op: RiscvOpcode::Add,
            rd: 1,
            rs1: 0,
            imm: 1,
        },
        RiscvInstruction::IAlu {
            op: RiscvOpcode::Add,
            rd: 2,
            rs1: 1,
            imm: 2,
        },
        RiscvInstruction::Halt,
    ];
    let program_bytes = encode_program(&program);
    let mut run = Rv32TraceWiring::from_rom(0, &program_bytes)
        .chunk_rows(2)
        .max_steps(program.len())
        .prove()
        .expect("chunked link-only session should prove");
    run.verify().expect("chunked link-only session should verify");
    run_to_case("rv32_chunked_link_only_multistep", false, &run)
}

fn wrapped_reg_output_valid() -> SessionCaseRepr {
    let program = vec![
        RiscvInstruction::IAlu {
            op: RiscvOpcode::Add,
            rd: 2,
            rs1: 0,
            imm: -240,
        },
        RiscvInstruction::IAlu {
            op: RiscvOpcode::Add,
            rd: 13,
            rs1: 0,
            imm: 42,
        },
        RiscvInstruction::Store {
            op: RiscvMemOp::Sw,
            rs1: 2,
            rs2: 13,
            imm: 320,
        },
        RiscvInstruction::Load {
            op: RiscvMemOp::Lw,
            rd: 14,
            rs1: 2,
            imm: 320,
        },
        RiscvInstruction::Halt,
    ];
    let program_bytes = encode_program(&program);
    let mut run = Rv32TraceWiring::from_rom(0, &program_bytes)
        .reg_output_claim(14, F::from_u64(42))
        .min_trace_len(program.len())
        .max_steps(program.len())
        .prove()
        .expect("wrapped-address reg-output session should prove");
    run.verify().expect("wrapped-address reg-output session should verify");
    run_to_case("rv32_wrapped_reg_output", false, &run)
}

fn load_to_x0_reg_output_valid() -> SessionCaseRepr {
    let program = vec![
        RiscvInstruction::IAlu {
            op: RiscvOpcode::Add,
            rd: 1,
            rs1: 0,
            imm: 0x100,
        },
        RiscvInstruction::IAlu {
            op: RiscvOpcode::Add,
            rd: 2,
            rs1: 0,
            imm: 0x7f,
        },
        RiscvInstruction::Store {
            op: RiscvMemOp::Sb,
            rs1: 1,
            rs2: 2,
            imm: 0,
        },
        RiscvInstruction::Load {
            op: RiscvMemOp::Lbu,
            rd: 0,
            rs1: 1,
            imm: 0,
        },
        RiscvInstruction::Load {
            op: RiscvMemOp::Lbu,
            rd: 3,
            rs1: 1,
            imm: 0,
        },
        RiscvInstruction::Halt,
    ];
    let program_bytes = encode_program(&program);
    let mut run = Rv32TraceWiring::from_rom(0, &program_bytes)
        .reg_output_claim(3, F::from_u64(0x7f))
        .min_trace_len(program.len())
        .max_steps(program.len())
        .prove()
        .expect("load-to-x0 reg-output session should prove");
    run.verify().expect("load-to-x0 reg-output session should verify");
    run_to_case("rv32_load_to_x0_reg_output", false, &run)
}

fn chunked_multi_reg_output_valid() -> SessionCaseRepr {
    let program = vec![
        RiscvInstruction::IAlu {
            op: RiscvOpcode::Add,
            rd: 1,
            rs1: 0,
            imm: 5,
        },
        RiscvInstruction::IAlu {
            op: RiscvOpcode::Add,
            rd: 2,
            rs1: 1,
            imm: 7,
        },
        RiscvInstruction::IAlu {
            op: RiscvOpcode::Add,
            rd: 3,
            rs1: 2,
            imm: 9,
        },
        RiscvInstruction::Halt,
    ];
    let program_bytes = encode_program(&program);
    let mut run = Rv32TraceWiring::from_rom(0, &program_bytes)
        .chunk_rows(1)
        .reg_output_claim(1, F::from_u64(5))
        .reg_output_claim(2, F::from_u64(12))
        .reg_output_claim(3, F::from_u64(21))
        .max_steps(program.len())
        .prove()
        .expect("chunked multi-reg-output session should prove");
    run.verify()
        .expect("chunked multi-reg-output session should verify");
    run_to_case("rv32_chunked_multi_reg_output", false, &run)
}

fn chunked_multi_ram_output_valid() -> SessionCaseRepr {
    let program = vec![
        RiscvInstruction::IAlu {
            op: RiscvOpcode::Add,
            rd: 1,
            rs1: 0,
            imm: 4,
        },
        RiscvInstruction::IAlu {
            op: RiscvOpcode::Add,
            rd: 2,
            rs1: 0,
            imm: 7,
        },
        RiscvInstruction::Store {
            op: RiscvMemOp::Sw,
            rs1: 1,
            rs2: 2,
            imm: 0,
        },
        RiscvInstruction::IAlu {
            op: RiscvOpcode::Add,
            rd: 3,
            rs1: 0,
            imm: 8,
        },
        RiscvInstruction::IAlu {
            op: RiscvOpcode::Add,
            rd: 4,
            rs1: 0,
            imm: 11,
        },
        RiscvInstruction::Store {
            op: RiscvMemOp::Sw,
            rs1: 3,
            rs2: 4,
            imm: 0,
        },
        RiscvInstruction::Halt,
    ];
    let program_bytes = encode_program(&program);
    let mut run = Rv32TraceWiring::from_rom(0, &program_bytes)
        .chunk_rows(2)
        .output_claim(4, F::from_u64(7))
        .output_claim(8, F::from_u64(11))
        .max_steps(program.len())
        .prove()
        .expect("chunked multi-RAM-output session should prove");
    run.verify()
        .expect("chunked multi-RAM-output session should verify");
    run_to_case("rv32_chunked_multi_ram_output", false, &run)
}

fn long_chain_reg_output_valid() -> SessionCaseRepr {
    let program = vec![
        RiscvInstruction::IAlu {
            op: RiscvOpcode::Add,
            rd: 1,
            rs1: 0,
            imm: 1,
        },
        RiscvInstruction::IAlu {
            op: RiscvOpcode::Add,
            rd: 2,
            rs1: 1,
            imm: 2,
        },
        RiscvInstruction::IAlu {
            op: RiscvOpcode::Add,
            rd: 3,
            rs1: 2,
            imm: 3,
        },
        RiscvInstruction::IAlu {
            op: RiscvOpcode::Add,
            rd: 4,
            rs1: 3,
            imm: 4,
        },
        RiscvInstruction::IAlu {
            op: RiscvOpcode::Add,
            rd: 5,
            rs1: 4,
            imm: 5,
        },
        RiscvInstruction::IAlu {
            op: RiscvOpcode::Add,
            rd: 6,
            rs1: 5,
            imm: 6,
        },
        RiscvInstruction::Halt,
    ];
    let program_bytes = encode_program(&program);
    let mut run = Rv32TraceWiring::from_rom(0, &program_bytes)
        .chunk_rows(1)
        .reg_output_claim(6, F::from_u64(21))
        .max_steps(program.len())
        .prove()
        .expect("long-chain reg-output session should prove");
    run.verify()
        .expect("long-chain reg-output session should verify");
    run_to_case("rv32_long_chain_reg_output", false, &run)
}

fn tamper_bad_step_link(valid: &SessionCaseRepr) -> SessionCaseRepr {
    let mut out = valid.clone();
    out.scenario_name = format!("{}/tampered_step_link", valid.scenario_name);
    out.should_fail = true;
    if let Some((prev_idx, next_idx)) = out.step_link_pairs.first().copied() {
        if out.step_xs.len() >= 2 && next_idx < out.step_xs[1].len() {
            let cur = out.step_xs[1][next_idx];
            let new_val = if prev_idx < out.step_xs[0].len() {
                out.step_xs[0][prev_idx].wrapping_add(1)
            } else {
                cur.wrapping_add(1)
            };
            out.step_xs[1][next_idx] = new_val;
        }
    }
    out
}

fn tamper_bad_final_state(valid: &SessionCaseRepr) -> SessionCaseRepr {
    let mut out = valid.clone();
    out.scenario_name = format!("{}/tampered_final_state", valid.scenario_name);
    out.should_fail = true;
    if let Some(ob) = out.output_binding.as_mut() {
        if let Some(claim) = ob.claims.first() {
            let idx = claim.addr as usize;
            if idx < ob.final_state.len() {
                ob.final_state[idx] = ob.final_state[idx].wrapping_add(1);
            }
        }
    }
    out
}

fn tamper_bad_public_step_count(valid: &SessionCaseRepr) -> SessionCaseRepr {
    let mut out = valid.clone();
    out.scenario_name = format!("{}/tampered_public_step_count", valid.scenario_name);
    out.should_fail = true;
    out.public_step_count = out.public_step_count.saturating_add(1);
    out
}

fn tamper_out_of_range_output_claim(valid: &SessionCaseRepr) -> SessionCaseRepr {
    let mut out = valid.clone();
    out.scenario_name = format!("{}/tampered_out_of_range_output_claim", valid.scenario_name);
    out.should_fail = true;
    if let Some(ob) = out.output_binding.as_mut() {
        let bad_addr = ob.final_state.len() as u64;
        if let Some(claim) = ob.claims.first_mut() {
            claim.addr = bad_addr;
        }
    }
    out
}

fn tamper_bad_output_claim(valid: &SessionCaseRepr) -> SessionCaseRepr {
    let mut out = valid.clone();
    out.scenario_name = format!("{}/tampered_output_claim", valid.scenario_name);
    out.should_fail = true;
    if let Some(ob) = out.output_binding.as_mut() {
        if let Some(claim) = ob.claims.first_mut() {
            claim.value = claim.value.wrapping_add(1);
        }
    }
    out
}

fn tamper_missing_output_proof(valid: &SessionCaseRepr) -> SessionCaseRepr {
    let mut out = valid.clone();
    out.scenario_name = format!("{}/tampered_missing_output_proof", valid.scenario_name);
    out.should_fail = true;
    if let Some(ob) = out.output_binding.as_mut() {
        ob.proof_has_output_binding = false;
    }
    out
}

#[derive(Clone)]
struct SessionSegmentRepr {
    proof_step_count: usize,
    initial_main_size: usize,
    final_main_size: usize,
    initial_main_digest: u64,
    final_main_digest: u64,
    initial_val_digest: Option<u64>,
    final_val_digest: Option<u64>,
}

fn segment_from_outputs(
    _public_step_count: usize,
    proof: &neo_fold::shard::ShardProof,
    init_main: &[CeClaim<Commitment, F, K>],
    init_val: &[CeClaim<Commitment, F, K>],
    final_main: &[CeClaim<Commitment, F, K>],
    final_val: &[CeClaim<Commitment, F, K>],
) -> SessionSegmentRepr {
    SessionSegmentRepr {
        proof_step_count: proof.steps.len(),
        initial_main_size: init_main.len(),
        final_main_size: final_main.len(),
        initial_main_digest: initial_main_digest_for_claims(init_main),
        final_main_digest: digest_claims_paper_core(final_main),
        initial_val_digest: maybe_digest_claims_paper_core(init_val),
        final_val_digest: maybe_digest_claims_paper_core(final_val),
    }
}

fn session_case_from_segments(
    scenario_name: &str,
    should_fail: bool,
    step_xs: Vec<Vec<u64>>,
    step_link_pairs: Vec<(usize, usize)>,
    segments: Vec<SessionSegmentRepr>,
    output_binding: Option<SessionOutputBindingRepr>,
) -> SessionCaseRepr {
    let public_step_count = step_xs.len();
    let proof_step_count = segments.iter().map(|seg| seg.proof_step_count).sum();
    SessionCaseRepr {
        scenario_name: scenario_name.to_string(),
        should_fail,
        public_step_count,
        proof_step_count,
        fold_count: public_step_count,
        segment_proof_step_counts: segments.iter().map(|seg| seg.proof_step_count).collect(),
        segment_initial_accumulator_sizes: segments.iter().map(|seg| seg.initial_main_size).collect(),
        segment_final_accumulator_sizes: segments.iter().map(|seg| seg.final_main_size).collect(),
        segment_initial_main_digests: segments
            .iter()
            .enumerate()
            .map(|(idx, seg)| if idx == 0 { 0 } else { seg.initial_main_digest })
            .collect(),
        segment_final_main_digests: segments.iter().map(|seg| seg.final_main_digest).collect(),
        segment_initial_val_digests: segments.iter().map(|seg| seg.initial_val_digest).collect(),
        segment_final_val_digests: segments.iter().map(|seg| seg.final_val_digest).collect(),
        segment_artifact_indices: vec![],
        step_link_pairs,
        step_xs,
        output_binding,
    }
}

fn bundle_with_segment_artifacts(case: SessionCaseRepr, segment_artifacts: Vec<ArtifactRepr>) -> SessionExportBundle {
    SessionExportBundle { case, segment_artifacts }
}

fn assign_segment_artifact_indices(
    case: &mut SessionCaseRepr,
    out_segment_artifacts: &mut Vec<ArtifactRepr>,
    segment_artifacts: &[ArtifactRepr],
) {
    let base = out_segment_artifacts.len();
    case.segment_artifact_indices = (0..segment_artifacts.len()).map(|i| base + i).collect();
    out_segment_artifacts.extend_from_slice(segment_artifacts);
}

fn twist_shout_continuation_valid() -> SessionExportBundle {
    let fx = fixtures::build_twist_shout_2step_fixture(909);
    let prefix_steps = &fx.steps_witness[..1];
    let suffix_steps = &fx.steps_witness[1..];
    let prefix_instances: Vec<StepInstanceBundle<Commitment, F, K>> =
        prefix_steps.iter().map(StepInstanceBundle::from).collect();
    let suffix_instances: Vec<StepInstanceBundle<Commitment, F, K>> =
        suffix_steps.iter().map(StepInstanceBundle::from).collect();

    let mut tr_prefix_p = Poseidon2Transcript::new(b"twist-shout/continuation");
    let (prefix_proof, prefix_outputs, prefix_wits, prefix_audit) = fold_shard_prove_with_witnesses_and_audit(
        FoldingMode::Optimized,
        &mut tr_prefix_p,
        &fx.params,
        &fx.ccs,
        prefix_steps,
        &fx.acc_init,
        &fx.acc_wit_init,
        &fx.l,
        fx.mixers,
    )
    .expect("continuation prefix proof should succeed");

    let mut tr_prefix_v = Poseidon2Transcript::new(b"twist-shout/continuation");
    let _ = fold_shard_verify(
        FoldingMode::Optimized,
        &mut tr_prefix_v,
        &fx.params,
        &fx.ccs,
        &prefix_instances,
        &fx.acc_init,
        &prefix_proof,
        fx.mixers,
    )
    .expect("continuation prefix proof should verify");

    let mut tr_suffix_p = Poseidon2Transcript::new(b"twist-shout/continuation");
    let (suffix_proof, suffix_outputs, suffix_wits, suffix_audit) =
        fold_shard_prove_with_witnesses_with_step_offset_and_audit(
            FoldingMode::Optimized,
            &mut tr_suffix_p,
            &fx.params,
            &fx.ccs,
            suffix_steps,
            &prefix_outputs.obligations.main,
            &prefix_wits.final_main_wits,
            &fx.l,
            fx.mixers,
            prefix_steps.len(),
        )
        .expect("continuation suffix proof should succeed");

    let mut tr_suffix_v = Poseidon2Transcript::new(b"twist-shout/continuation");
    let _ = fold_shard_verify_with_step_offset(
        FoldingMode::Optimized,
        &mut tr_suffix_v,
        &fx.params,
        &fx.ccs,
        &suffix_instances,
        &prefix_outputs.obligations.main,
        &suffix_proof,
        fx.mixers,
        prefix_steps.len(),
    )
    .expect("continuation suffix proof should verify");

    let all_instances: Vec<StepInstanceBundle<Commitment, F, K>> =
        fx.steps_witness.iter().map(StepInstanceBundle::from).collect();

    let segments = vec![
        segment_from_outputs(
            prefix_steps.len(),
            &prefix_proof,
            &fx.acc_init,
            &[],
            &prefix_outputs.obligations.main,
            &prefix_outputs.obligations.val,
        ),
        segment_from_outputs(
            suffix_steps.len(),
            &suffix_proof,
            &prefix_outputs.obligations.main,
            &prefix_outputs.obligations.val,
            &suffix_outputs.obligations.main,
            &suffix_outputs.obligations.val,
        ),
    ];

    let segment_artifacts = vec![
        neo_fold_artifacts::artifact_from_proof(
            "twist_shout_continuation_2segment/segment0",
            false,
            prefix_steps.len(),
            fx.params.b,
            fx.params.k_rho,
            &fx.params,
            &fx.ccs,
            &fx.l,
            prefix_steps,
            &fx.acc_init,
            &fx.acc_wit_init,
            &prefix_wits.final_main_wits,
            &prefix_proof,
            &prefix_audit,
        ),
        neo_fold_artifacts::artifact_from_proof(
            "twist_shout_continuation_2segment/segment1",
            false,
            suffix_steps.len(),
            fx.params.b,
            fx.params.k_rho,
            &fx.params,
            &fx.ccs,
            &fx.l,
            suffix_steps,
            &prefix_outputs.obligations.main,
            &prefix_wits.final_main_wits,
            &suffix_wits.final_main_wits,
            &suffix_proof,
            &suffix_audit,
        ),
    ];

    bundle_with_segment_artifacts(
        session_case_from_segments(
            "twist_shout_continuation_2segment",
            false,
            all_instances
                .iter()
                .map(|step| step.mcs_inst.x.iter().copied().map(f_u64).collect())
                .collect(),
            vec![],
            segments,
            None,
        ),
        segment_artifacts,
    )
}

fn build_ccs_only_step(
    fx: &fixtures::ShardFixture,
    salt: u64,
) -> neo_memory::witness::StepWitnessBundle<neo_ajtai::Commitment, F, K> {
    let m = fx.ccs.m;
    let m_in = fx.steps_witness[0].mcs.0.m_in;
    let z: Vec<F> = (0..m)
        .map(|i| match (salt.wrapping_add(i as u64)) % 3 {
            0 => -F::ONE,
            1 => F::ZERO,
            _ => F::ONE,
        })
        .collect();
    let x = z[..m_in].to_vec();
    let w = z[m_in..].to_vec();
    let z_mat = encode_vector_for_ccs_m(&fx.params, z.len(), &z).expect("encode witness for CCS width");
    let c = fx.l.commit(&z_mat);
    neo_memory::witness::StepWitnessBundle::from((
        neo_ccs::relations::CcsClaim { c, x, m_in },
        neo_ccs::relations::CcsWitness { w, Z: z_mat },
    ))
}

fn long_chain_continuation_valid() -> SessionExportBundle {
    let program = vec![
        RiscvInstruction::IAlu { op: RiscvOpcode::Add, rd: 1, rs1: 0, imm: 1 },
        RiscvInstruction::IAlu { op: RiscvOpcode::Add, rd: 2, rs1: 1, imm: 2 },
        RiscvInstruction::IAlu { op: RiscvOpcode::Add, rd: 3, rs1: 2, imm: 3 },
        RiscvInstruction::IAlu { op: RiscvOpcode::Add, rd: 4, rs1: 3, imm: 4 },
        RiscvInstruction::IAlu { op: RiscvOpcode::Add, rd: 5, rs1: 4, imm: 5 },
        RiscvInstruction::IAlu { op: RiscvOpcode::Add, rd: 6, rs1: 5, imm: 6 },
        RiscvInstruction::Halt,
    ];
    let program_bytes = encode_program(&program);
    let mut run = Rv32TraceWiring::from_rom(0, &program_bytes)
        .chunk_rows(1)
        .reg_output_claim(6, F::from_u64(21))
        .max_steps(program.len())
        .prove()
        .expect("long-chain continuation source run should prove");
    run.verify()
        .expect("long-chain continuation source run should verify");

    let all_wits = run.steps_witness();
    let all_instances = run.steps_public();
    let seg0_wits = &all_wits[..2];
    let seg1_wits = &all_wits[2..4];
    let seg2_wits = &all_wits[4..];
    let seg0_instances: Vec<StepInstanceBundle<Commitment, F, K>> =
        seg0_wits.iter().map(StepInstanceBundle::from).collect();
    let seg1_instances: Vec<StepInstanceBundle<Commitment, F, K>> =
        seg1_wits.iter().map(StepInstanceBundle::from).collect();
    let seg2_instances: Vec<StepInstanceBundle<Commitment, F, K>> =
        seg2_wits.iter().map(StepInstanceBundle::from).collect();

    let empty_claims: Vec<CeClaim<Commitment, F, K>> = Vec::new();
    let empty_witnesses: Vec<neo_ccs::Mat<F>> = Vec::new();

    let mut tr0_p = Poseidon2Transcript::new(b"rv32/long-chain/continuation");
    let (proof0, outputs0, wits0, audit0) = fold_shard_prove_with_witnesses_and_audit(
        FoldingMode::Optimized,
        &mut tr0_p,
        run.params(),
        run.ccs(),
        seg0_wits,
        &empty_claims,
        &empty_witnesses,
        run.committer(),
        crate::common_setup::default_mixers(),
    )
    .expect("segment 0 should prove");
    let mut tr0_v = Poseidon2Transcript::new(b"rv32/long-chain/continuation");
    let _ = fold_shard_verify(
        FoldingMode::Optimized,
        &mut tr0_v,
        run.params(),
        run.ccs(),
        &seg0_instances,
        &empty_claims,
        &proof0,
        crate::common_setup::default_mixers(),
    )
    .expect("segment 0 should verify");

    let mut tr1_p = Poseidon2Transcript::new(b"rv32/long-chain/continuation");
    let (proof1, outputs1, wits1, audit1) = fold_shard_prove_with_witnesses_with_step_offset_and_audit(
        FoldingMode::Optimized,
        &mut tr1_p,
        run.params(),
        run.ccs(),
        seg1_wits,
        &outputs0.obligations.main,
        &wits0.final_main_wits,
        run.committer(),
        crate::common_setup::default_mixers(),
        seg0_wits.len(),
    )
    .expect("segment 1 should prove");
    let mut tr1_v = Poseidon2Transcript::new(b"rv32/long-chain/continuation");
    let _ = fold_shard_verify_with_step_offset(
        FoldingMode::Optimized,
        &mut tr1_v,
        run.params(),
        run.ccs(),
        &seg1_instances,
        &outputs0.obligations.main,
        &proof1,
        crate::common_setup::default_mixers(),
        seg0_wits.len(),
    )
    .expect("segment 1 should verify");

    let mut tr2_p = Poseidon2Transcript::new(b"rv32/long-chain/continuation");
    let (proof2, outputs2, wits2, audit2) = fold_shard_prove_with_witnesses_with_step_offset_and_audit(
        FoldingMode::Optimized,
        &mut tr2_p,
        run.params(),
        run.ccs(),
        seg2_wits,
        &outputs1.obligations.main,
        &wits1.final_main_wits,
        run.committer(),
        crate::common_setup::default_mixers(),
        seg0_wits.len() + seg1_wits.len(),
    )
    .expect("segment 2 should prove");
    let mut tr2_v = Poseidon2Transcript::new(b"rv32/long-chain/continuation");
    let _ = fold_shard_verify_with_step_offset(
        FoldingMode::Optimized,
        &mut tr2_v,
        run.params(),
        run.ccs(),
        &seg2_instances,
        &outputs1.obligations.main,
        &proof2,
        crate::common_setup::default_mixers(),
        seg0_wits.len() + seg1_wits.len(),
    )
    .expect("segment 2 should verify");

    let segments = vec![
        segment_from_outputs(seg0_wits.len(), &proof0, &empty_claims, &[], &outputs0.obligations.main, &outputs0.obligations.val),
        segment_from_outputs(seg1_wits.len(), &proof1, &outputs0.obligations.main, &outputs0.obligations.val, &outputs1.obligations.main, &outputs1.obligations.val),
        segment_from_outputs(seg2_wits.len(), &proof2, &outputs1.obligations.main, &outputs1.obligations.val, &outputs2.obligations.main, &outputs2.obligations.val),
    ];

    let segment_artifacts = vec![
        neo_fold_artifacts::artifact_from_proof(
            "rv32_long_chain_continuation_3segment/segment0",
            false,
            seg0_wits.len(),
            run.params().b,
            run.params().k_rho,
            run.params(),
            run.ccs(),
            run.committer(),
            seg0_wits,
            &empty_claims,
            &empty_witnesses,
            &wits0.final_main_wits,
            &proof0,
            &audit0,
        ),
        neo_fold_artifacts::artifact_from_proof(
            "rv32_long_chain_continuation_3segment/segment1",
            false,
            seg1_wits.len(),
            run.params().b,
            run.params().k_rho,
            run.params(),
            run.ccs(),
            run.committer(),
            seg1_wits,
            &outputs0.obligations.main,
            &wits0.final_main_wits,
            &wits1.final_main_wits,
            &proof1,
            &audit1,
        ),
        neo_fold_artifacts::artifact_from_proof(
            "rv32_long_chain_continuation_3segment/segment2",
            false,
            seg2_wits.len(),
            run.params().b,
            run.params().k_rho,
            run.params(),
            run.ccs(),
            run.committer(),
            seg2_wits,
            &outputs1.obligations.main,
            &wits1.final_main_wits,
            &wits2.final_main_wits,
            &proof2,
            &audit2,
        ),
    ];

    bundle_with_segment_artifacts(
        session_case_from_segments(
            "rv32_long_chain_continuation_3segment",
            false,
            step_xs_from_instances(&all_instances),
            run.step_linking_pairs().to_vec(),
            segments,
            None,
        ),
        segment_artifacts,
    )
}

fn output_binding_continuation_valid() -> SessionExportBundle {
    let program = vec![
        RiscvInstruction::IAlu { op: RiscvOpcode::Add, rd: 1, rs1: 0, imm: 4 },
        RiscvInstruction::IAlu { op: RiscvOpcode::Add, rd: 2, rs1: 0, imm: 7 },
        RiscvInstruction::Store { op: RiscvMemOp::Sw, rs1: 1, rs2: 2, imm: 0 },
        RiscvInstruction::IAlu { op: RiscvOpcode::Add, rd: 3, rs1: 0, imm: 8 },
        RiscvInstruction::IAlu { op: RiscvOpcode::Add, rd: 4, rs1: 0, imm: 11 },
        RiscvInstruction::Store { op: RiscvMemOp::Sw, rs1: 3, rs2: 4, imm: 0 },
        RiscvInstruction::Halt,
    ];
    let program_bytes = encode_program(&program);
    let mut run = Rv32TraceWiring::from_rom(0, &program_bytes)
        .chunk_rows(2)
        .output_claim(4, F::from_u64(7))
        .output_claim(8, F::from_u64(11))
        .max_steps(program.len())
        .prove()
        .expect("output-binding continuation source run should prove");
    run.verify()
        .expect("output-binding continuation source run should verify");

    let all_wits = run.steps_witness();
    let all_instances = run.steps_public();
    let split = 2usize.min(all_wits.len().saturating_sub(1));
    let prefix_wits = &all_wits[..split];
    let suffix_wits = &all_wits[split..];
    let prefix_instances: Vec<StepInstanceBundle<Commitment, F, K>> =
        prefix_wits.iter().map(StepInstanceBundle::from).collect();

    let empty_claims: Vec<CeClaim<Commitment, F, K>> = Vec::new();
    let empty_witnesses: Vec<neo_ccs::Mat<F>> = Vec::new();
    let mut tr_prefix_p = Poseidon2Transcript::new(b"rv32/output-binding/continuation");
    let (prefix_proof, prefix_outputs, prefix_wits_final, _audit0) = fold_shard_prove_with_witnesses_and_audit(
        FoldingMode::Optimized,
        &mut tr_prefix_p,
        run.params(),
        run.ccs(),
        prefix_wits,
        &empty_claims,
        &empty_witnesses,
        run.committer(),
        crate::common_setup::default_mixers(),
    )
    .expect("output-binding prefix should prove");
    let mut tr_prefix_v = Poseidon2Transcript::new(b"rv32/output-binding/continuation");
    let _ = fold_shard_verify(
        FoldingMode::Optimized,
        &mut tr_prefix_v,
        run.params(),
        run.ccs(),
        &prefix_instances,
        &empty_claims,
        &prefix_proof,
        crate::common_setup::default_mixers(),
    )
    .expect("output-binding prefix should verify");

    let ob_cfg = run
        .output_binding_cfg()
        .expect("output-binding continuation run must carry an output-binding cfg")
        .clone();
    let final_state: Vec<F> = run
        .output_binding_target_state()
        .expect("output-binding continuation run must carry final output state")
        .to_vec();
    let mut tr_suffix_p = Poseidon2Transcript::new(b"rv32/output-binding/continuation");
    let suffix_proof = fold_shard_prove_with_output_binding(
        FoldingMode::Optimized,
        &mut tr_suffix_p,
        run.params(),
        run.ccs(),
        suffix_wits,
        &prefix_outputs.obligations.main,
        &prefix_wits_final.final_main_wits,
        run.committer(),
        crate::common_setup::default_mixers(),
        &ob_cfg,
        &final_state,
    )
    .expect("output-binding suffix should prove");
    let suffix_instances: Vec<StepInstanceBundle<Commitment, F, K>> =
        suffix_wits.iter().map(StepInstanceBundle::from).collect();
    let mut tr_suffix_v = Poseidon2Transcript::new(b"rv32/output-binding/continuation");
    let suffix_outputs = fold_shard_verify_with_output_binding(
        FoldingMode::Optimized,
        &mut tr_suffix_v,
        run.params(),
        run.ccs(),
        &suffix_instances,
        &prefix_outputs.obligations.main,
        &suffix_proof,
        crate::common_setup::default_mixers(),
        &ob_cfg,
    )
    .expect("output-binding suffix should verify");

    let segments = vec![
        segment_from_outputs(prefix_wits.len(), &prefix_proof, &empty_claims, &[], &prefix_outputs.obligations.main, &prefix_outputs.obligations.val),
        segment_from_outputs(
            suffix_wits.len(),
            &suffix_proof,
            &prefix_outputs.obligations.main,
            &prefix_outputs.obligations.val,
            &suffix_outputs.obligations.main,
            &suffix_outputs.obligations.val,
        ),
    ];

    bundle_with_segment_artifacts(
        session_case_from_segments(
            "rv32_output_binding_continuation_tail",
            false,
            step_xs_from_instances(&all_instances),
            run.step_linking_pairs().to_vec(),
            segments,
            output_binding_repr_from_run(&run, suffix_proof.output_proof.is_some()),
        ),
        vec![],
    )
}

fn mixed_continuation_valid() -> SessionExportBundle {
    let fx = fixtures::build_twist_shout_2step_fixture(123);
    let steps_witness: Vec<neo_memory::witness::StepWitnessBundle<neo_ajtai::Commitment, F, K>> = vec![
        build_ccs_only_step(&fx, 100),
        build_ccs_only_step(&fx, 200),
        fx.steps_witness[0].clone(),
        fx.steps_witness[1].clone(),
        build_ccs_only_step(&fx, 300),
    ];
    let steps_instance: Vec<StepInstanceBundle<Commitment, F, K>> =
        steps_witness.iter().map(StepInstanceBundle::from).collect();
    let seg0_wits = &steps_witness[..2];
    let seg1_wits = &steps_witness[2..4];
    let seg2_wits = &steps_witness[4..];
    let seg0_instances: Vec<StepInstanceBundle<Commitment, F, K>> =
        seg0_wits.iter().map(StepInstanceBundle::from).collect();
    let seg1_instances: Vec<StepInstanceBundle<Commitment, F, K>> =
        seg1_wits.iter().map(StepInstanceBundle::from).collect();
    let seg2_instances: Vec<StepInstanceBundle<Commitment, F, K>> =
        seg2_wits.iter().map(StepInstanceBundle::from).collect();

    let empty_claims: Vec<CeClaim<Commitment, F, K>> = Vec::new();
    let empty_witnesses: Vec<neo_ccs::Mat<F>> = Vec::new();

    let mut tr0_p = Poseidon2Transcript::new(b"mixed-ccs-route-a/continuation");
    let (proof0, outputs0, wits0, audit0) = fold_shard_prove_with_witnesses_and_audit(
        FoldingMode::Optimized,
        &mut tr0_p,
        &fx.params,
        &fx.ccs,
        seg0_wits,
        &empty_claims,
        &empty_witnesses,
        &fx.l,
        fx.mixers,
    )
    .expect("mixed continuation segment 0 should prove");
    let mut tr0_v = Poseidon2Transcript::new(b"mixed-ccs-route-a/continuation");
    let _ = fold_shard_verify(
        FoldingMode::Optimized,
        &mut tr0_v,
        &fx.params,
        &fx.ccs,
        &seg0_instances,
        &empty_claims,
        &proof0,
        fx.mixers,
    )
    .expect("mixed continuation segment 0 should verify");

    let mut tr1_p = Poseidon2Transcript::new(b"mixed-ccs-route-a/continuation");
    let (proof1, outputs1, wits1, audit1) = fold_shard_prove_with_witnesses_with_step_offset_and_audit(
        FoldingMode::Optimized,
        &mut tr1_p,
        &fx.params,
        &fx.ccs,
        seg1_wits,
        &outputs0.obligations.main,
        &wits0.final_main_wits,
        &fx.l,
        fx.mixers,
        seg0_wits.len(),
    )
    .expect("mixed continuation segment 1 should prove");
    let mut tr1_v = Poseidon2Transcript::new(b"mixed-ccs-route-a/continuation");
    let _ = fold_shard_verify_with_step_offset(
        FoldingMode::Optimized,
        &mut tr1_v,
        &fx.params,
        &fx.ccs,
        &seg1_instances,
        &outputs0.obligations.main,
        &proof1,
        fx.mixers,
        seg0_wits.len(),
    )
    .expect("mixed continuation segment 1 should verify");

    let mut tr2_p = Poseidon2Transcript::new(b"mixed-ccs-route-a/continuation");
    let (proof2, outputs2, wits2, audit2) = fold_shard_prove_with_witnesses_with_step_offset_and_audit(
        FoldingMode::Optimized,
        &mut tr2_p,
        &fx.params,
        &fx.ccs,
        seg2_wits,
        &outputs1.obligations.main,
        &wits1.final_main_wits,
        &fx.l,
        fx.mixers,
        seg0_wits.len() + seg1_wits.len(),
    )
    .expect("mixed continuation segment 2 should prove");
    let mut tr2_v = Poseidon2Transcript::new(b"mixed-ccs-route-a/continuation");
    let _ = fold_shard_verify_with_step_offset(
        FoldingMode::Optimized,
        &mut tr2_v,
        &fx.params,
        &fx.ccs,
        &seg2_instances,
        &outputs1.obligations.main,
        &proof2,
        fx.mixers,
        seg0_wits.len() + seg1_wits.len(),
    )
    .expect("mixed continuation segment 2 should verify");

    let segments = vec![
        segment_from_outputs(seg0_wits.len(), &proof0, &empty_claims, &[], &outputs0.obligations.main, &outputs0.obligations.val),
        segment_from_outputs(seg1_wits.len(), &proof1, &outputs0.obligations.main, &outputs0.obligations.val, &outputs1.obligations.main, &outputs1.obligations.val),
        segment_from_outputs(seg2_wits.len(), &proof2, &outputs1.obligations.main, &outputs1.obligations.val, &outputs2.obligations.main, &outputs2.obligations.val),
    ];

    let segment_artifacts = vec![
        neo_fold_artifacts::artifact_from_proof(
            "mixed_ccs_route_a_continuation/segment0",
            false,
            seg0_wits.len(),
            fx.params.b,
            fx.params.k_rho,
            &fx.params,
            &fx.ccs,
            &fx.l,
            seg0_wits,
            &empty_claims,
            &empty_witnesses,
            &wits0.final_main_wits,
            &proof0,
            &audit0,
        ),
        neo_fold_artifacts::artifact_from_proof(
            "mixed_ccs_route_a_continuation/segment1",
            false,
            seg1_wits.len(),
            fx.params.b,
            fx.params.k_rho,
            &fx.params,
            &fx.ccs,
            &fx.l,
            seg1_wits,
            &outputs0.obligations.main,
            &wits0.final_main_wits,
            &wits1.final_main_wits,
            &proof1,
            &audit1,
        ),
        neo_fold_artifacts::artifact_from_proof(
            "mixed_ccs_route_a_continuation/segment2",
            false,
            seg2_wits.len(),
            fx.params.b,
            fx.params.k_rho,
            &fx.params,
            &fx.ccs,
            &fx.l,
            seg2_wits,
            &outputs1.obligations.main,
            &wits1.final_main_wits,
            &wits2.final_main_wits,
            &proof2,
            &audit2,
        ),
    ];

    bundle_with_segment_artifacts(
        session_case_from_segments(
            "mixed_ccs_route_a_continuation",
            false,
            step_xs_from_instances(&steps_instance),
            vec![],
            segments,
            None,
        ),
        segment_artifacts,
    )
}

fn tamper_bad_resume_accumulator(valid: &SessionCaseRepr) -> SessionCaseRepr {
    let mut out = valid.clone();
    out.scenario_name = format!("{}/tampered_resume_accumulator", valid.scenario_name);
    out.should_fail = true;
    if out.segment_initial_accumulator_sizes.len() >= 2 {
        out.segment_initial_accumulator_sizes[1] =
            out.segment_initial_accumulator_sizes[1].saturating_add(1);
    }
    out
}

fn tamper_bad_resume_segment_count(valid: &SessionCaseRepr) -> SessionCaseRepr {
    let mut out = valid.clone();
    out.scenario_name = format!("{}/tampered_resume_segment_count", valid.scenario_name);
    out.should_fail = true;
    if let Some(last) = out.segment_proof_step_counts.last_mut() {
        *last = last.saturating_add(1);
    }
    out
}

fn tamper_bad_resume_main_digest(valid: &SessionCaseRepr) -> SessionCaseRepr {
    let mut out = valid.clone();
    out.scenario_name = format!("{}/tampered_resume_main_digest", valid.scenario_name);
    out.should_fail = true;
    if out.segment_initial_main_digests.len() >= 2 {
        out.segment_initial_main_digests[1] =
            out.segment_initial_main_digests[1].wrapping_add(1);
    }
    out
}

fn tamper_bad_tail_output_claim(valid: &SessionCaseRepr) -> SessionCaseRepr {
    let mut out = valid.clone();
    out.scenario_name = format!("{}/tampered_tail_output_claim", valid.scenario_name);
    out.should_fail = true;
    if let Some(ob) = out.output_binding.as_mut() {
        if let Some(claim) = ob.claims.last_mut() {
            claim.value = claim.value.wrapping_add(1);
        }
    }
    out
}

fn write_generated_sessions_module(out_path: &PathBuf, cases: &[SessionCaseRepr]) {
    let mut out = String::new();
    out.push_str("import SuperNeo.Generated.NeoFoldSessionsCases\n\n");
    out.push_str("namespace SuperNeo.Generated\n\n");
    out.push_str("def neoFoldSessionCases : Array NeoFoldSessionCase := #[\n");
    for case in cases {
        let _ = writeln!(
            out,
            "  {{ scenarioName := {:?}, shouldFail := {}, publicStepCount := {}, proofStepCount := {}, foldCount := {}, segmentProofStepCounts := {}, segmentInitialAccumulatorSizes := {}, segmentFinalAccumulatorSizes := {}, segmentInitialMainDigests := {}, segmentFinalMainDigests := {}, segmentInitialValDigests := {}, segmentFinalValDigests := {}, segmentArtifactIndices := {}, stepLinkPairs := {}, stepXs := {}, outputBinding := {} }},",
            case.scenario_name,
            if case.should_fail { "true" } else { "false" },
            case.public_step_count,
            case.proof_step_count,
            case.fold_count,
            fmt_usize_array(&case.segment_proof_step_counts),
            fmt_usize_array(&case.segment_initial_accumulator_sizes),
            fmt_usize_array(&case.segment_final_accumulator_sizes),
            fmt_nat_array(&case.segment_initial_main_digests),
            fmt_nat_array(&case.segment_final_main_digests),
            fmt_option_u64_array(&case.segment_initial_val_digests),
            fmt_option_u64_array(&case.segment_final_val_digests),
            fmt_usize_array(&case.segment_artifact_indices),
            fmt_pair_array(&case.step_link_pairs),
            fmt_nat_array2(&case.step_xs),
            fmt_output_binding(&case.output_binding),
        );
    }
    out.push_str("]\n\nend SuperNeo.Generated\n");
    fs::write(out_path, out).expect("write neo-fold sessions");
}

pub fn export_neo_fold_sessions() {
    let single_reg = reg_output_single_step_valid();
    let chunked_reg = chunked_reg_output_multistep_valid();
    let chunked_ram = chunked_ram_output_multistep_valid();
    let chunked_link_only = chunked_link_only_valid();
    let wrapped_reg = wrapped_reg_output_valid();
    let load_to_x0 = load_to_x0_reg_output_valid();
    let chunked_multi_reg = chunked_multi_reg_output_valid();
    let chunked_multi_ram = chunked_multi_ram_output_valid();
    let long_chain_reg = long_chain_reg_output_valid();
    let mut continuation = twist_shout_continuation_valid();
    let mut long_chain_cont = long_chain_continuation_valid();
    let mut output_binding_cont = output_binding_continuation_valid();
    let mut mixed_cont = mixed_continuation_valid();
    let mut segment_artifacts: Vec<ArtifactRepr> = Vec::new();
    assign_segment_artifact_indices(
        &mut continuation.case,
        &mut segment_artifacts,
        &continuation.segment_artifacts,
    );
    assign_segment_artifact_indices(
        &mut long_chain_cont.case,
        &mut segment_artifacts,
        &long_chain_cont.segment_artifacts,
    );
    assign_segment_artifact_indices(
        &mut output_binding_cont.case,
        &mut segment_artifacts,
        &output_binding_cont.segment_artifacts,
    );
    assign_segment_artifact_indices(
        &mut mixed_cont.case,
        &mut segment_artifacts,
        &mixed_cont.segment_artifacts,
    );
    let cases = vec![
        single_reg.clone(),
        chunked_reg.clone(),
        chunked_ram.clone(),
        chunked_link_only,
        wrapped_reg,
        load_to_x0,
        chunked_multi_reg.clone(),
        chunked_multi_ram.clone(),
        long_chain_reg.clone(),
        continuation.case.clone(),
        long_chain_cont.case.clone(),
        output_binding_cont.case.clone(),
        mixed_cont.case.clone(),
        tamper_bad_output_claim(&single_reg),
        tamper_bad_step_link(&chunked_reg),
        tamper_missing_output_proof(&chunked_ram),
        tamper_bad_final_state(&chunked_multi_ram),
        tamper_bad_public_step_count(&long_chain_reg),
        tamper_out_of_range_output_claim(&chunked_multi_ram),
        tamper_bad_resume_accumulator(&continuation.case),
        tamper_bad_resume_segment_count(&continuation.case),
        tamper_bad_resume_main_digest(&continuation.case),
        tamper_bad_resume_segment_count(&long_chain_cont.case),
        tamper_bad_resume_main_digest(&long_chain_cont.case),
        tamper_bad_tail_output_claim(&output_binding_cont.case),
        tamper_bad_resume_main_digest(&output_binding_cont.case),
        tamper_bad_resume_segment_count(&mixed_cont.case),
        tamper_bad_resume_main_digest(&mixed_cont.case),
    ];

    let out_path = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("..")
        .join("SuperNeo")
        .join("Generated")
        .join("NeoFoldSessions.lean");
    write_generated_sessions_module(&out_path, &cases);
    let generated_dir = out_path
        .parent()
        .expect("session artifact output should have a parent");
    neo_fold_artifacts::write_session_segment_artifacts(generated_dir, &segment_artifacts);
    println!("wrote {}", out_path.display());
}
