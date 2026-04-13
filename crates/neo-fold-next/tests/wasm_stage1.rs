use neo_fold_next::wasm::{
    build_stage1_summary, opcode_code, opcode_info_from_code, stage1_channel_label, StackLaneAccess, WasmLookupArity,
    WasmOpcode, WasmShoutOpcode, WasmStepTrace,
};

fn step(opcode: WasmOpcode, cycle: u64, lhs: u32, rhs: Option<u32>, out: u32) -> WasmStepTrace {
    let code = opcode_code(opcode);
    let info = opcode_info_from_code(code);
    WasmStepTrace {
        cycle,
        pc_before: cycle,
        pc_after: cycle + 1,
        opcode_code: code,
        opcode,
        info,
        sp_before: u64::from(info.stack_reads),
        sp_after: u64::from(info.stack_writes),
        stack_read0: (info.stack_reads > 0).then_some(StackLaneAccess { addr: 0, value: lhs }),
        stack_read1: rhs.map(|value| StackLaneAccess { addr: 1, value }),
        stack_read2: None,
        stack_write1: (info.stack_writes > 0).then_some(StackLaneAccess { addr: 0, value: out }),
        halted: false,
        locals_fbp: 0,
        local_index: None,
        local_read_value: None,
        local_write_value: None,
    }
}

#[test]
fn stage1_summary_extracts_only_lookup_rows() {
    let steps = vec![
        step(WasmOpcode::I32Const, 0, 0, None, 7),
        step(WasmOpcode::I32Eqz, 1, 7, None, 0),
        step(WasmOpcode::I32Add, 2, 7, Some(9), 16),
        step(WasmOpcode::I32Xor, 3, 0xaa00, Some(0x0ff0), 0xa5f0),
    ];

    let summary = build_stage1_summary(&steps);
    assert_eq!(summary.rows.len(), 2);
    assert_eq!(summary.channels.len(), 2);
    assert_eq!(summary.rows[0].trace_index, 1);
    assert_eq!(summary.rows[0].shout_opcode, WasmShoutOpcode::I32Eqz);
    assert_eq!(summary.rows[0].arity, WasmLookupArity::Unary);
    assert_eq!(summary.rows[1].trace_index, 3);
    assert_eq!(summary.rows[1].shout_opcode, WasmShoutOpcode::I32Xor);
    assert_eq!(summary.rows[1].arity, WasmLookupArity::Binary);
}

#[test]
fn stage1_summary_groups_rows_by_channel_in_stable_order() {
    let steps = vec![
        step(WasmOpcode::I32Xor, 0, 1, Some(2), 3),
        step(WasmOpcode::I32Eqz, 1, 0, None, 1),
        step(WasmOpcode::I32Xor, 2, 4, Some(8), 12),
    ];

    let summary = build_stage1_summary(&steps);
    assert_eq!(summary.channels.len(), 2);
    assert_eq!(summary.channels[0].channel, WasmShoutOpcode::I32Eqz);
    assert_eq!(summary.channels[0].rows.len(), 1);
    assert_eq!(summary.channels[1].channel, WasmShoutOpcode::I32Xor);
    assert_eq!(summary.channels[1].rows.len(), 2);
}

#[test]
fn stage1_channel_labels_are_stable() {
    assert_eq!(stage1_channel_label(WasmShoutOpcode::I32Eqz), b"wasm/stage1/i32_eqz");
    assert_eq!(stage1_channel_label(WasmShoutOpcode::I32Mul), b"wasm/stage1/i32_mul");
}
