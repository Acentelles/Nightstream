use neo_fold::riscv_trace_shard::{Rv32TraceWiring, Rv32TraceWiringRun};
use neo_fold::shard::ShardProof;
use neo_math::K;
use neo_memory::riscv::lookups::{encode_program, RiscvInstruction, RiscvMemOp, RiscvOpcode};
use p3_field::PrimeCharacteristicRing;

fn prove_run(program: Vec<RiscvInstruction>, max_steps: usize) -> Rv32TraceWiringRun {
    let steps = max_steps;
    let program_bytes = encode_program(&program);
    let mut run = Rv32TraceWiring::from_rom(/*program_base=*/ 0, &program_bytes)
        .chunk_rows(steps.next_power_of_two())
        .min_trace_len(steps)
        .max_steps(steps)
        .prove()
        .expect("prove");
    run.verify().expect("baseline verify");
    run
}

fn tamper_any_claim_scalar(proof: &mut ShardProof) {
    for step in &mut proof.steps {
        for claims in [
            &mut step.fold.ccs_out,
            &mut step.mem.val_me_claims,
            &mut step.mem.sidecar_me_claims,
        ] {
            for claim in claims.iter_mut() {
                if let Some(first) = claim.y_scalars.first_mut() {
                    *first += K::ONE;
                    return;
                }
            }
        }
    }
    panic!("expected at least one claim scalar to tamper");
}

fn prove_run_with_sidecar_groups() -> Rv32TraceWiringRun {
    prove_run(
        vec![
            RiscvInstruction::Load {
                op: RiscvMemOp::Lw,
                rd: 1,
                rs1: 0,
                imm: 0,
            },
            RiscvInstruction::IAlu {
                op: RiscvOpcode::Add,
                rd: 2,
                rs1: 1,
                imm: 3,
            },
            RiscvInstruction::Halt,
        ],
        /*max_steps=*/ 3,
    )
}

fn first_step_with_sidecar_idx(proof: &ShardProof) -> usize {
    proof
        .steps
        .iter()
        .position(|s| !s.mem.sidecar_me_claims.is_empty())
        .expect("expected at least one step with sidecar ME claims")
}

#[test]
fn rv32_trace_twist_claim_tamper_must_fail() {
    let run = prove_run(
        vec![
            RiscvInstruction::Load {
                op: RiscvMemOp::Lw,
                rd: 1,
                rs1: 0,
                imm: 0,
            },
            RiscvInstruction::Halt,
        ],
        /*max_steps=*/ 2,
    );

    let mut bad_proof = run.proof().clone();
    tamper_any_claim_scalar(&mut bad_proof);
    assert!(
        run.verify_proof(&bad_proof).is_err(),
        "tampered twist proof must not verify"
    );
}

#[test]
fn rv32_trace_shout_addr_pre_tamper_must_fail() {
    let run = prove_run(
        vec![
            RiscvInstruction::IAlu {
                op: RiscvOpcode::Add,
                rd: 1,
                rs1: 0,
                imm: 1,
            },
            RiscvInstruction::Halt,
        ],
        /*max_steps=*/ 2,
    );

    let mut bad_proof = run.proof().clone();
    let step = bad_proof
        .steps
        .iter_mut()
        .find(|s| {
            s.mem
                .shout_addr_pre
                .groups
                .iter()
                .any(|g| !g.active_lanes.is_empty())
        })
        .expect("expected an active shout addr-pre group");
    let group = step
        .mem
        .shout_addr_pre
        .groups
        .iter_mut()
        .find(|g| !g.active_lanes.is_empty())
        .expect("expected non-empty active lanes");
    group.active_lanes.clear();
    group.round_polys.clear();
    assert!(
        run.verify_proof(&bad_proof).is_err(),
        "tampered shout addr-pre proof must not verify"
    );
}

#[test]
fn rv32_trace_proof_step_reordering_must_fail() {
    let run = prove_run(
        vec![
            RiscvInstruction::IAlu {
                op: RiscvOpcode::Add,
                rd: 1,
                rs1: 0,
                imm: 1,
            },
            RiscvInstruction::IAlu {
                op: RiscvOpcode::Or,
                rd: 2,
                rs1: 1,
                imm: 3,
            },
            RiscvInstruction::Halt,
        ],
        /*max_steps=*/ 3,
    );

    let mut bad_proof = run.proof().clone();
    if bad_proof.steps.len() >= 2 {
        bad_proof.steps.swap(0, 1);
    } else {
        tamper_any_claim_scalar(&mut bad_proof);
    }
    assert!(
        run.verify_proof(&bad_proof).is_err(),
        "reordered proof steps must not verify"
    );
}

#[test]
fn rv32_trace_ram_init_statement_tamper_must_fail() {
    let program = vec![
        RiscvInstruction::Load {
            op: RiscvMemOp::Lw,
            rd: 1,
            rs1: 0,
            imm: 0,
        },
        RiscvInstruction::Halt,
    ];
    let program_bytes = encode_program(&program);
    let steps = 2usize;
    let mut run = Rv32TraceWiring::from_rom(/*program_base=*/ 0, &program_bytes)
        .chunk_rows(steps)
        .min_trace_len(steps)
        .max_steps(steps)
        .ram_init_u32(/*addr=*/ 0, /*value=*/ 7)
        .prove()
        .expect("prove");
    run.verify().expect("baseline verify");

    let mut bad_proof = run.proof().clone();
    tamper_any_claim_scalar(&mut bad_proof);
    assert!(
        run.verify_proof(&bad_proof).is_err(),
        "tampered RAM-bound proof must not verify"
    );
}

#[test]
fn rv32_trace_sidecar_fold_missing_group_must_fail() {
    let run = prove_run_with_sidecar_groups();
    let mut bad_proof = run.proof().clone();
    let step_idx = first_step_with_sidecar_idx(&bad_proof);
    let step = &mut bad_proof.steps[step_idx];
    assert!(
        !step.sidecar_fold.is_empty(),
        "expected sidecar_fold groups for mixed twist+shout route-A proof"
    );
    step.sidecar_fold.pop();
    assert!(
        run.verify_proof(&bad_proof).is_err(),
        "missing sidecar_fold group must not verify"
    );
}

#[test]
fn rv32_trace_sidecar_fold_group_reorder_must_fail() {
    let run = prove_run_with_sidecar_groups();
    let mut bad_proof = run.proof().clone();
    let step_idx = first_step_with_sidecar_idx(&bad_proof);
    let step = &mut bad_proof.steps[step_idx];
    assert!(
        step.sidecar_fold.len() >= 2,
        "expected at least two sidecar_fold groups to test reorder binding"
    );
    step.sidecar_fold.swap(0, 1);
    assert!(
        run.verify_proof(&bad_proof).is_err(),
        "reordered sidecar_fold groups must not verify"
    );
}

#[test]
fn rv32_trace_sidecar_me_claim_missing_must_fail() {
    let run = prove_run_with_sidecar_groups();
    let mut bad_proof = run.proof().clone();
    let step_idx = first_step_with_sidecar_idx(&bad_proof);
    let step = &mut bad_proof.steps[step_idx];
    assert!(
        !step.mem.sidecar_me_claims.is_empty(),
        "expected sidecar ME claims for mixed twist+shout route-A proof"
    );
    step.mem.sidecar_me_claims.remove(0);
    assert!(
        run.verify_proof(&bad_proof).is_err(),
        "missing sidecar ME claim must not verify"
    );
}
