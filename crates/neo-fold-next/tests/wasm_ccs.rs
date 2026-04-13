use neo_ccs::check_ccs_rowwise_zero;
use neo_fold_next::vm::VmSpec;
use neo_fold_next::wasm::builder::build_row;
use neo_fold_next::wasm::{
    opcode_code, opcode_info_from_code, traces_from_rwasm_instr_states, StackLaneAccess, WasmOpcode, WasmStepTrace,
    WasmVmSpec,
};
use neo_math::F;
use p3_field::PrimeCharacteristicRing;
use rwasm::mem::{MemoryAccessRecord, MemoryReadRecord, MemoryRecordEnum, MemoryWriteRecord};
use rwasm::{Opcode as ConcreteOpcode, TracerInstrState};

fn assert_satisfied(z: &[F], label: &str) {
    let vm = WasmVmSpec::default();
    let ccs = &vm.core_ccs_spec().structure;
    let (x, w) = (&z[..1], &z[1..]);
    check_ccs_rowwise_zero(ccs, x, w).unwrap_or_else(|e| panic!("{label}: expected CCS satisfied, got: {e}"));
}

fn assert_rejected(z: &[F], label: &str) {
    let vm = WasmVmSpec::default();
    let ccs = &vm.core_ccs_spec().structure;
    let (x, w) = (&z[..1], &z[1..]);
    assert!(
        check_ccs_rowwise_zero(ccs, x, w).is_err(),
        "{label}: expected CCS rejection, but the witness was accepted"
    );
}

fn step(
    cycle: u64,
    pc_before: u64,
    opcode_code: u16,
    sp_before: u64,
    sp_after: u64,
    stack_read0: Option<StackLaneAccess>,
    stack_read1: Option<StackLaneAccess>,
    stack_read2: Option<StackLaneAccess>,
    stack_write1: Option<StackLaneAccess>,
    halted: bool,
) -> WasmStepTrace {
    WasmStepTrace {
        cycle,
        pc_before,
        pc_after: pc_before + 1,
        opcode_code,
        opcode: opcode_info_from_code(opcode_code).opcode,
        info: opcode_info_from_code(opcode_code),
        sp_before,
        sp_after,
        stack_read0,
        stack_read1,
        stack_read2,
        stack_write1,
        halted,
        locals_fbp: 0,
        local_index: None,
        local_read_value: None,
        local_write_value: None,
    }
}

#[test]
fn normalization_tracks_stack_pointer_for_binary_op() {
    let rows = vec![
        TracerInstrState {
            program_counter: 0,
            opcode: ConcreteOpcode::I32Const(7u32.into()),
            value: 7,
            memory_changes: vec![],
            table_changes: vec![],
            table_size_changes: vec![],
            next_table_idx: None,
            call_id: 0,
            memory_access: MemoryAccessRecord::default(),
        },
        TracerInstrState {
            program_counter: 1,
            opcode: ConcreteOpcode::I32Const(9u32.into()),
            value: 9,
            memory_changes: vec![],
            table_changes: vec![],
            table_size_changes: vec![],
            next_table_idx: None,
            call_id: 0,
            memory_access: MemoryAccessRecord::default(),
        },
        TracerInstrState {
            program_counter: 2,
            opcode: ConcreteOpcode::I32Add,
            value: 0,
            memory_changes: vec![],
            table_changes: vec![],
            table_size_changes: vec![],
            next_table_idx: None,
            call_id: 0,
            memory_access: MemoryAccessRecord {
                a: Some(MemoryRecordEnum::Read(MemoryReadRecord::new(7, 1, 1, 0, 0))),
                b: Some(MemoryRecordEnum::Read(MemoryReadRecord::new(9, 1, 2, 0, 0))),
                c: Some(MemoryRecordEnum::Write(MemoryWriteRecord::new(16, 1, 3, 0, 0, 0))),
                memory: None,
            },
        },
    ];

    let trace = traces_from_rwasm_instr_states(&rows, 0).expect("normalize");
    assert_eq!(trace[0].sp_before, 0);
    assert_eq!(trace[0].sp_after, 1);
    assert_eq!(trace[1].sp_before, 1);
    assert_eq!(trace[1].sp_after, 2);
    assert_eq!(trace[2].sp_before, 2);
    assert_eq!(trace[2].sp_after, 1);
    assert_eq!(trace[2].stack_read0.expect("lhs").addr, 0);
    assert_eq!(trace[2].stack_read1.expect("rhs").addr, 1);
    assert_eq!(trace[2].stack_write1.expect("out").addr, 0);
    assert_eq!(trace[2].opcode, WasmOpcode::I32Add);
}

#[test]
fn direct_rows_satisfy_real_wasm_ccs() {
    let rows = vec![
        build_row(&step(
            0,
            0,
            opcode_code(WasmOpcode::I32Const),
            0,
            1,
            None,
            None,
            None,
            Some(StackLaneAccess { addr: 0, value: 7 }),
            false,
        )),
        build_row(&step(
            1,
            1,
            opcode_code(WasmOpcode::I32Const),
            1,
            2,
            None,
            None,
            None,
            Some(StackLaneAccess { addr: 1, value: 9 }),
            false,
        )),
        build_row(&step(
            2,
            2,
            opcode_code(WasmOpcode::I32Add),
            2,
            1,
            Some(StackLaneAccess { addr: 0, value: 7 }),
            Some(StackLaneAccess { addr: 1, value: 9 }),
            None,
            Some(StackLaneAccess { addr: 0, value: 16 }),
            false,
        )),
        build_row(&step(
            3,
            3,
            opcode_code(WasmOpcode::I32Sub),
            2,
            1,
            Some(StackLaneAccess { addr: 0, value: 20 }),
            Some(StackLaneAccess { addr: 1, value: 5 }),
            None,
            Some(StackLaneAccess { addr: 0, value: 15 }),
            false,
        )),
        build_row(&step(
            4,
            4,
            opcode_code(WasmOpcode::Select),
            3,
            1,
            Some(StackLaneAccess { addr: 0, value: 11 }),
            Some(StackLaneAccess { addr: 1, value: 22 }),
            Some(StackLaneAccess { addr: 2, value: 1 }),
            Some(StackLaneAccess { addr: 0, value: 11 }),
            false,
        )),
        build_row(&step(
            5,
            5,
            opcode_code(WasmOpcode::Return),
            1,
            1,
            None,
            None,
            None,
            None,
            true,
        )),
    ];

    for (idx, row) in rows.iter().enumerate() {
        assert_satisfied(row, &format!("row {idx}"));
    }
}

#[test]
fn add_row_rejects_tampered_output_value() {
    let mut row = build_row(&step(
        0,
        2,
        opcode_code(WasmOpcode::I32Add),
        2,
        1,
        Some(StackLaneAccess { addr: 0, value: 7 }),
        Some(StackLaneAccess { addr: 1, value: 9 }),
        None,
        Some(StackLaneAccess { addr: 0, value: 16 }),
        false,
    ));
    row[33] = F::from_u64(17);
    assert_rejected(&row, "tampered i32.add output");
}

#[test]
fn selector_opcode_mismatch_is_rejected() {
    let mut row = build_row(&step(
        0,
        2,
        opcode_code(WasmOpcode::I32Add),
        2,
        1,
        Some(StackLaneAccess { addr: 0, value: 7 }),
        Some(StackLaneAccess { addr: 1, value: 9 }),
        None,
        Some(StackLaneAccess { addr: 0, value: 16 }),
        false,
    ));
    row[1] = F::from_u64(u64::from(opcode_code(WasmOpcode::I32Sub)));
    assert_rejected(&row, "opcode byte does not match active selector");
}

#[test]
fn return_row_requires_halted_boundary() {
    let row = build_row(&step(
        0,
        9,
        opcode_code(WasmOpcode::Return),
        1,
        1,
        None,
        None,
        None,
        None,
        false,
    ));
    assert_rejected(&row, "return row with halted=0");
}

#[test]
fn select_row_rejects_non_boolean_condition() {
    let row = build_row(&step(
        0,
        4,
        opcode_code(WasmOpcode::Select),
        3,
        1,
        Some(StackLaneAccess { addr: 0, value: 11 }),
        Some(StackLaneAccess { addr: 1, value: 22 }),
        Some(StackLaneAccess { addr: 2, value: 2 }),
        Some(StackLaneAccess { addr: 0, value: 11 }),
        false,
    ));
    assert_rejected(&row, "select row with non-boolean condition");
}
