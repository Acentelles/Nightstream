//! Owns compact selected-row and kernel-opening summary surfaces for the WASM kernel.

use neo_math::KExtensions;
use neo_transcript::{Poseidon2Transcript, Transcript};

use super::types::{
    WasmKernelOpeningSummary, WasmKernelPreparedStepSummary, WasmKernelProof, WasmKernelSelectedRowRef,
    WasmKernelStage1OpeningSummary, WasmKernelStage2OpeningSummary, WasmKernelStage3OpeningSummary,
};
use crate::proof::StepInput;
use crate::wasm::stage1::Stage1LookupRowBinding;
use crate::wasm::stage2::{Stage2FamilyClaim, Stage2StackRowBinding};
use crate::wasm::stage3::Stage3BoundaryRowBinding;

pub fn build_kernel_opening_summary(proof: &WasmKernelProof, prepared_steps: &[StepInput]) -> WasmKernelOpeningSummary {
    let stage1 = build_stage1_summary(proof);
    let stage2 = build_stage2_summary(proof);
    let stage3 = build_stage3_summary(proof);
    let prepared_steps = build_prepared_step_summary(prepared_steps);

    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/kernel_opening_summary");
    tr.append_message(b"wasm/kernel_opening_summary/stage1", &stage1.digest);
    tr.append_message(b"wasm/kernel_opening_summary/stage2", &stage2.digest);
    tr.append_message(b"wasm/kernel_opening_summary/stage3", &stage3.digest);
    tr.append_message(b"wasm/kernel_opening_summary/prepared_steps", &prepared_steps.digest);

    WasmKernelOpeningSummary {
        stage1,
        stage2,
        stage3,
        prepared_steps,
        digest: tr.digest32(),
    }
}

pub fn verify_kernel_opening_summary(
    expected: &WasmKernelOpeningSummary,
    proof: &WasmKernelProof,
    prepared_steps: &[StepInput],
) -> Result<(), String> {
    let recomputed = build_kernel_opening_summary(proof, prepared_steps);
    if &recomputed != expected {
        return Err("wasm kernel opening summary mismatch".into());
    }
    Ok(())
}

fn build_stage1_summary(proof: &WasmKernelProof) -> WasmKernelStage1OpeningSummary {
    let mut rows = proof.stage1.eqz.rows.clone();
    for binary in &proof.stage1.binary {
        rows.extend(binary.rows.iter().cloned());
    }
    rows.sort_by_key(|row| row.trace_index);

    let rows_digest = digest_stage1_rows(&rows);
    let first_row = rows.first().map(|row| stage1_row_ref(0, row));
    let last_row = rows
        .last()
        .map(|row| stage1_row_ref(rows.len() as u64 - 1, row));

    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/kernel_opening_stage1");
    tr.append_message(b"wasm/kernel_opening_stage1/rows_digest", &rows_digest);
    tr.append_u64s(
        b"wasm/kernel_opening_stage1/counts",
        &[
            proof.stage1.eqz.rows.len() as u64,
            proof.stage1.binary.len() as u64,
            rows.len() as u64,
        ],
    );
    append_optional_ref(&mut tr, b"wasm/kernel_opening_stage1/first_row", first_row.as_ref());
    append_optional_ref(&mut tr, b"wasm/kernel_opening_stage1/last_row", last_row.as_ref());

    WasmKernelStage1OpeningSummary {
        rows_digest,
        eqz_row_count: proof.stage1.eqz.rows.len() as u64,
        binary_channel_count: proof.stage1.binary.len() as u64,
        row_count: rows.len() as u64,
        first_row,
        last_row,
        digest: tr.digest32(),
    }
}

fn build_stage2_summary(proof: &WasmKernelProof) -> WasmKernelStage2OpeningSummary {
    let rows_digest = digest_stage2_rows(&proof.stage2.rows);
    let family_claims_digest = digest_stage2_family_claims(&proof.stage2.family_claims);
    let first_row = proof.stage2.rows.first().map(|row| stage2_row_ref(0, row));
    let last_row = proof
        .stage2
        .rows
        .last()
        .map(|row| stage2_row_ref(proof.stage2.rows.len() as u64 - 1, row));

    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/kernel_opening_stage2");
    tr.append_message(b"wasm/kernel_opening_stage2/rows_digest", &rows_digest);
    tr.append_message(
        b"wasm/kernel_opening_stage2/family_claims_digest",
        &family_claims_digest,
    );
    tr.append_fields(
        b"wasm/kernel_opening_stage2/value_from_inc_claim",
        &proof.stage2.value_from_inc_claim.as_coeffs(),
    );
    tr.append_u64s(
        b"wasm/kernel_opening_stage2/counts",
        &[
            proof.stage2.rows.len() as u64,
            proof.stage2.family_claims.len() as u64,
            proof.stage2.final_slots.len() as u64,
        ],
    );
    append_optional_ref(&mut tr, b"wasm/kernel_opening_stage2/first_row", first_row.as_ref());
    append_optional_ref(&mut tr, b"wasm/kernel_opening_stage2/last_row", last_row.as_ref());

    WasmKernelStage2OpeningSummary {
        rows_digest,
        family_claims_digest,
        row_count: proof.stage2.rows.len() as u64,
        family_count: proof.stage2.family_claims.len() as u64,
        final_slot_count: proof.stage2.final_slots.len() as u64,
        first_row,
        last_row,
        digest: tr.digest32(),
    }
}

fn build_stage3_summary(proof: &WasmKernelProof) -> WasmKernelStage3OpeningSummary {
    let rows_digest = digest_stage3_rows(&proof.stage3.rows);
    let first_row = proof.stage3.rows.first().map(|row| stage3_row_ref(0, row));
    let last_row = proof
        .stage3
        .rows
        .last()
        .map(|row| stage3_row_ref(proof.stage3.rows.len() as u64 - 1, row));

    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/kernel_opening_stage3");
    tr.append_message(b"wasm/kernel_opening_stage3/rows_digest", &rows_digest);
    tr.append_u64s(
        b"wasm/kernel_opening_stage3/counts",
        &[
            proof.stage3.rows.len() as u64,
            u64::from(proof.stage3.final_boundary.is_some()),
        ],
    );
    append_optional_ref(&mut tr, b"wasm/kernel_opening_stage3/first_row", first_row.as_ref());
    append_optional_ref(&mut tr, b"wasm/kernel_opening_stage3/last_row", last_row.as_ref());

    WasmKernelStage3OpeningSummary {
        rows_digest,
        row_count: proof.stage3.rows.len() as u64,
        has_final_boundary: proof.stage3.final_boundary.is_some(),
        first_row,
        last_row,
        digest: tr.digest32(),
    }
}

fn build_prepared_step_summary(prepared_steps: &[StepInput]) -> WasmKernelPreparedStepSummary {
    let steps_digest = digest_prepared_steps(prepared_steps);
    let first_step = prepared_steps
        .first()
        .map(|step| prepared_step_ref(0, step));
    let last_step = prepared_steps
        .last()
        .map(|step| prepared_step_ref(prepared_steps.len() as u64 - 1, step));

    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/kernel_opening_prepared_steps");
    tr.append_message(b"wasm/kernel_opening_prepared_steps/steps_digest", &steps_digest);
    tr.append_u64s(
        b"wasm/kernel_opening_prepared_steps/counts",
        &[prepared_steps.len() as u64],
    );
    append_optional_ref(
        &mut tr,
        b"wasm/kernel_opening_prepared_steps/first_step",
        first_step.as_ref(),
    );
    append_optional_ref(
        &mut tr,
        b"wasm/kernel_opening_prepared_steps/last_step",
        last_step.as_ref(),
    );

    WasmKernelPreparedStepSummary {
        steps_digest,
        step_count: prepared_steps.len() as u64,
        first_step,
        last_step,
        digest: tr.digest32(),
    }
}

fn digest_stage1_rows(rows: &[Stage1LookupRowBinding]) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/kernel_opening_stage1_rows");
    tr.append_u64s(b"wasm/kernel_opening_stage1_rows/count", &[rows.len() as u64]);
    for row in rows {
        tr.append_u64s(
            b"wasm/kernel_opening_stage1_rows/row",
            &[
                row.trace_index as u64,
                row.cycle,
                row.pc_before,
                row.opcode as u64,
                row.shout_opcode as u64,
                u64::from(row.shout_id),
                row.arity as u64,
                u64::from(row.input0),
                u64::from(row.input1),
                u64::from(row.output),
            ],
        );
    }
    tr.digest32()
}

fn digest_stage2_rows(rows: &[Stage2StackRowBinding]) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/kernel_opening_stage2_rows");
    tr.append_u64s(b"wasm/kernel_opening_stage2_rows/count", &[rows.len() as u64]);
    for row in rows {
        tr.append_u64s(
            b"wasm/kernel_opening_stage2_rows/row",
            &[row.trace_index as u64, row.cycle],
        );
        append_optional_stack_lane(&mut tr, b"wasm/kernel_opening_stage2_rows/read0", row.read0);
        append_optional_stack_lane(&mut tr, b"wasm/kernel_opening_stage2_rows/read1", row.read1);
        append_optional_stack_lane(&mut tr, b"wasm/kernel_opening_stage2_rows/read2", row.read2);
        append_optional_stack_lane(&mut tr, b"wasm/kernel_opening_stage2_rows/write1", row.write1);
    }
    tr.digest32()
}

fn digest_stage2_family_claims(claims: &[Stage2FamilyClaim]) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/kernel_opening_stage2_families");
    tr.append_u64s(b"wasm/kernel_opening_stage2_families/count", &[claims.len() as u64]);
    for claim in claims {
        tr.append_u64s(b"wasm/kernel_opening_stage2_families/family", &[claim.family as u64]);
        tr.append_fields(b"wasm/kernel_opening_stage2_families/claim", &claim.claim.as_coeffs());
    }
    tr.digest32()
}

fn digest_stage3_rows(rows: &[Stage3BoundaryRowBinding]) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/kernel_opening_stage3_rows");
    tr.append_u64s(b"wasm/kernel_opening_stage3_rows/count", &[rows.len() as u64]);
    for row in rows {
        tr.append_u64s(
            b"wasm/kernel_opening_stage3_rows/row",
            &[
                row.trace_index as u64,
                row.cycle,
                row.pc_before,
                row.pc_after,
                row.sp_before,
                row.sp_after,
                u64::from(row.halted),
            ],
        );
    }
    tr.digest32()
}

fn digest_prepared_steps(steps: &[StepInput]) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/kernel_opening_prepared_step_rows");
    tr.append_u64s(b"wasm/kernel_opening_prepared_step_rows/count", &[steps.len() as u64]);
    for step in steps {
        tr.append_message(b"wasm/kernel_opening_prepared_step_rows/label", step.label.as_bytes());
        tr.append_u64s(
            b"wasm/kernel_opening_prepared_step_rows/meta",
            &[
                step.mcs.x.len() as u64,
                step.mcs.m_in as u64,
                step.mcs.c.d as u64,
                step.mcs.c.kappa as u64,
            ],
        );
        tr.append_fields(b"wasm/kernel_opening_prepared_step_rows/x", &step.mcs.x);
        tr.append_fields(b"wasm/kernel_opening_prepared_step_rows/commitment", &step.mcs.c.data);
    }
    tr.digest32()
}

fn stage1_row_ref(logical_index: u64, row: &Stage1LookupRowBinding) -> WasmKernelSelectedRowRef {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/kernel_opening_stage1_ref_value");
    tr.append_u64s(
        b"wasm/kernel_opening_stage1_ref_value/row",
        &[
            row.trace_index as u64,
            row.cycle,
            row.pc_before,
            row.opcode as u64,
            row.shout_opcode as u64,
            u64::from(row.shout_id),
            row.arity as u64,
            u64::from(row.input0),
            u64::from(row.input1),
            u64::from(row.output),
        ],
    );
    selected_ref(b"wasm/kernel_opening_stage1_ref", logical_index, tr.digest32())
}

fn stage2_row_ref(logical_index: u64, row: &Stage2StackRowBinding) -> WasmKernelSelectedRowRef {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/kernel_opening_stage2_ref_value");
    tr.append_u64s(
        b"wasm/kernel_opening_stage2_ref_value/row",
        &[row.trace_index as u64, row.cycle],
    );
    append_optional_stack_lane(&mut tr, b"wasm/kernel_opening_stage2_ref_value/read0", row.read0);
    append_optional_stack_lane(&mut tr, b"wasm/kernel_opening_stage2_ref_value/read1", row.read1);
    append_optional_stack_lane(&mut tr, b"wasm/kernel_opening_stage2_ref_value/read2", row.read2);
    append_optional_stack_lane(&mut tr, b"wasm/kernel_opening_stage2_ref_value/write1", row.write1);
    selected_ref(b"wasm/kernel_opening_stage2_ref", logical_index, tr.digest32())
}

fn stage3_row_ref(logical_index: u64, row: &Stage3BoundaryRowBinding) -> WasmKernelSelectedRowRef {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/kernel_opening_stage3_ref_value");
    tr.append_u64s(
        b"wasm/kernel_opening_stage3_ref_value/row",
        &[
            row.trace_index as u64,
            row.cycle,
            row.pc_before,
            row.pc_after,
            row.sp_before,
            row.sp_after,
            u64::from(row.halted),
        ],
    );
    selected_ref(b"wasm/kernel_opening_stage3_ref", logical_index, tr.digest32())
}

fn prepared_step_ref(logical_index: u64, step: &StepInput) -> WasmKernelSelectedRowRef {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/kernel_opening_prepared_step_ref_value");
    tr.append_message(
        b"wasm/kernel_opening_prepared_step_ref_value/label",
        step.label.as_bytes(),
    );
    tr.append_u64s(
        b"wasm/kernel_opening_prepared_step_ref_value/meta",
        &[
            step.mcs.x.len() as u64,
            step.mcs.m_in as u64,
            step.mcs.c.d as u64,
            step.mcs.c.kappa as u64,
        ],
    );
    tr.append_fields(b"wasm/kernel_opening_prepared_step_ref_value/x", &step.mcs.x);
    tr.append_fields(
        b"wasm/kernel_opening_prepared_step_ref_value/commitment",
        &step.mcs.c.data,
    );
    selected_ref(b"wasm/kernel_opening_prepared_step_ref", logical_index, tr.digest32())
}

fn selected_ref(label: &'static [u8], logical_index: u64, value_digest: [u8; 32]) -> WasmKernelSelectedRowRef {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/kernel_selected_row_ref");
    tr.append_message(b"wasm/kernel_selected_row_ref/label", label);
    tr.append_u64s(b"wasm/kernel_selected_row_ref/index", &[logical_index]);
    tr.append_message(b"wasm/kernel_selected_row_ref/value_digest", &value_digest);
    WasmKernelSelectedRowRef {
        logical_index,
        value_digest,
        digest: tr.digest32(),
    }
}

fn append_optional_ref(
    tr: &mut Poseidon2Transcript,
    label: &'static [u8],
    reference: Option<&WasmKernelSelectedRowRef>,
) {
    tr.append_u64s(label, &[u64::from(reference.is_some())]);
    if let Some(reference) = reference {
        tr.append_u64s(label, &[reference.logical_index]);
        tr.append_message(label, &reference.value_digest);
        tr.append_message(label, &reference.digest);
    }
}

fn append_optional_stack_lane(
    tr: &mut Poseidon2Transcript,
    label: &'static [u8],
    lane: Option<crate::wasm::StackLaneAccess>,
) {
    tr.append_u64s(label, &[u64::from(lane.is_some())]);
    if let Some(lane) = lane {
        tr.append_u64s(label, &[lane.addr, u64::from(lane.value)]);
    }
}
