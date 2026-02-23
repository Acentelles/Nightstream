use neo_fold::riscv_trace_shard::{Rv32TraceWiring, Rv32TraceWiringRun};
use neo_fold::shard::ShardProof;
use neo_math::K;
use neo_memory::riscv::lookups::{encode_program, RiscvInstruction, RiscvMemOp, RiscvOpcode};
use p3_field::PrimeCharacteristicRing;

fn prove_run_with_sidecar_groups() -> Rv32TraceWiringRun {
    let program = vec![
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
    ];
    let steps = 3usize;
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

fn find_first_sidecar_fold_with_extra(proof: &ShardProof, core_t: usize) -> Option<(usize, usize)> {
    proof.steps.iter().enumerate().find_map(|(step_idx, step)| {
        step.sidecar_fold
            .iter()
            .enumerate()
            .find(|(_, fold)| fold.rlc_parent.y_scalars.len() > core_t && !fold.dec_children.is_empty())
            .map(|(fold_idx, _)| (step_idx, fold_idx))
    })
}

fn find_first_val_fold_with_extra(proof: &ShardProof, core_t: usize) -> Option<(usize, usize)> {
    proof.steps.iter().enumerate().find_map(|(step_idx, step)| {
        step.val_fold
            .iter()
            .enumerate()
            .find(|(_, fold)| {
                fold.rlc_parent.y.len() > core_t
                    && !fold.dec_children.is_empty()
                    && fold.dec_children[0].y.len() > core_t
                    && !fold.dec_children[0].y[core_t].is_empty()
            })
            .map(|(fold_idx, _)| (step_idx, fold_idx))
    })
}

#[test]
fn full_vector_rlc_dec_positive_route_a() {
    let mut run = prove_run_with_sidecar_groups();
    run.verify().expect("proof should verify");
}

#[test]
fn full_vector_rlc_dec_parent_tamper_fails() {
    let run = prove_run_with_sidecar_groups();
    let mut bad_proof = run.proof().clone();
    let core_t = run.layout().t;

    let (step_idx, fold_idx) = find_first_sidecar_fold_with_extra(&bad_proof, core_t)
        .expect("expected a sidecar_fold proof carrying appended openings");
    bad_proof.steps[step_idx].sidecar_fold[fold_idx].rlc_parent.y_scalars[core_t] += K::ONE;

    assert!(
        run.verify_proof(&bad_proof).is_err(),
        "tampering appended parent coordinate must fail verification"
    );
}

#[test]
fn full_vector_rlc_dec_child_tamper_fails() {
    let run = prove_run_with_sidecar_groups();
    let mut bad_proof = run.proof().clone();
    let core_t = run.layout().t;

    let (step_idx, fold_idx) = find_first_sidecar_fold_with_extra(&bad_proof, core_t)
        .expect("expected a sidecar_fold proof carrying appended openings");
    bad_proof.steps[step_idx].sidecar_fold[fold_idx].dec_children[0].y_scalars[core_t] += K::ONE;

    assert!(
        run.verify_proof(&bad_proof).is_err(),
        "tampering appended child coordinate must fail verification"
    );
}

#[test]
fn full_vector_rlc_dec_val_child_tamper_fails() {
    let run = prove_run_with_sidecar_groups();
    let mut bad_proof = run.proof().clone();
    let core_t = run.layout().t;

    let (step_idx, fold_idx) = find_first_val_fold_with_extra(&bad_proof, core_t)
        .expect("expected a val_fold proof carrying appended openings");
    bad_proof.steps[step_idx].val_fold[fold_idx].dec_children[0].y[core_t][0] += K::ONE;

    assert!(
        run.verify_proof(&bad_proof).is_err(),
        "tampering appended val-lane child coordinate must fail verification"
    );
}

#[test]
fn full_vector_rlc_dec_shape_invariant_for_extra_openings() {
    let run = prove_run_with_sidecar_groups();
    let proof = run.proof();
    let core_t = run.layout().t;

    for step in &proof.steps {
        for lane in [&step.val_fold, &step.sidecar_fold] {
            for fold in lane.iter() {
                let parent_extra = fold.rlc_parent.y.len() > core_t;
                if !parent_extra {
                    continue;
                }
                assert_eq!(
                    fold.rlc_parent.y.len(),
                    fold.rlc_parent.y_scalars.len(),
                    "parent y/y_scalars lengths must match in full-vector mode"
                );
                for child in &fold.dec_children {
                    assert_eq!(
                        child.y.len(),
                        fold.rlc_parent.y.len(),
                        "child y length must match full parent y length when parent carries appended openings"
                    );
                    assert_eq!(
                        child.y_scalars.len(),
                        fold.rlc_parent.y_scalars.len(),
                        "child y_scalars length must match full parent y_scalars length when parent carries appended openings"
                    );
                }
            }
        }
    }
}
