use neo_fold_next::wasm::{
    collect_wasmtime_steps, opcode_code, traces_from_wasmtime_steps, traces_from_wasmtime_wasm_bytes, StackLaneAccess,
    WasmOpcode, WasmtimeTraceStep,
};

fn sample_steps() -> Vec<WasmtimeTraceStep> {
    vec![
        WasmtimeTraceStep {
            step: 0,
            frame_depth: 0,
            function: "DefinedFuncIndex(0)".to_string(),
            function_index: Some(0),
            pc: Some(49),
            opcode: Some("I32Const { value: 7 }".to_string()),
            opcode_decoded: Some(WasmOpcode::I32Const),
            immediate_i32: Some(7),
            memory: None,
            locals: vec![],
            operand_stack: vec![],
        },
        WasmtimeTraceStep {
            step: 1,
            frame_depth: 0,
            function: "DefinedFuncIndex(0)".to_string(),
            function_index: Some(0),
            pc: Some(51),
            opcode: Some("I32Const { value: 9 }".to_string()),
            opcode_decoded: Some(WasmOpcode::I32Const),
            immediate_i32: Some(9),
            memory: None,
            locals: vec![],
            operand_stack: vec!["7".to_string()],
        },
        WasmtimeTraceStep {
            step: 2,
            frame_depth: 0,
            function: "DefinedFuncIndex(0)".to_string(),
            function_index: Some(0),
            pc: Some(53),
            opcode: Some("I32Add".to_string()),
            opcode_decoded: Some(WasmOpcode::I32Add),
            immediate_i32: None,
            memory: None,
            locals: vec![],
            operand_stack: vec!["7".to_string(), "9".to_string()],
        },
        WasmtimeTraceStep {
            step: 3,
            frame_depth: 0,
            function: "DefinedFuncIndex(0)".to_string(),
            function_index: Some(0),
            pc: Some(55),
            opcode: Some("End".to_string()),
            opcode_decoded: Some(WasmOpcode::Return),
            immediate_i32: None,
            memory: None,
            locals: vec![],
            operand_stack: vec!["16".to_string()],
        },
    ]
}

#[test]
fn wasmtime_steps_normalize_to_wasm_ir() {
    let trace = traces_from_wasmtime_steps(&sample_steps()).expect("normalize");
    assert_eq!(trace.len(), 4);

    assert_eq!(trace[0].opcode, WasmOpcode::I32Const);
    assert_eq!(trace[0].opcode_code, opcode_code(WasmOpcode::I32Const));
    assert_eq!(trace[0].stack_write1, Some(StackLaneAccess { addr: 0, value: 7 }));

    assert_eq!(trace[2].opcode, WasmOpcode::I32Add);
    assert_eq!(trace[2].stack_read0, Some(StackLaneAccess { addr: 0, value: 7 }));
    assert_eq!(trace[2].stack_read1, Some(StackLaneAccess { addr: 1, value: 9 }));
    assert_eq!(trace[2].stack_write1, Some(StackLaneAccess { addr: 0, value: 16 }));

    assert_eq!(trace[3].opcode, WasmOpcode::Return);
    assert!(trace[3].halted);
}

#[test]
fn wasmtime_runtime_trace_normalizes_supported_rows() {
    let wasm = wat::parse_str(
        r#"(module
            (func (export "run") (result i32)
                i32.const 7
                i32.const 9
                i32.add)
        )"#,
    )
    .expect("wat");

    let run = collect_wasmtime_steps(&wasm, "run").expect("trace run");
    assert_eq!(run.result_i32, 16);
    let trace = traces_from_wasmtime_wasm_bytes(&wasm, "run").expect("normalize wasmtime trace");
    let opcodes = trace.iter().map(|row| row.opcode).collect::<Vec<_>>();
    assert_eq!(
        opcodes,
        vec![
            WasmOpcode::I32Const,
            WasmOpcode::I32Const,
            WasmOpcode::I32Add,
            WasmOpcode::Return,
        ]
    );
    assert_eq!(trace[2].stack_write1.unwrap().value, 16);
    assert!(run
        .steps
        .iter()
        .any(|step| step.opcode.as_deref() == Some("I32Add")));
}

#[test]
fn wasmtime_trace_normalizes_local_get_and_set() {
    // A no-argument function that stores constants into locals then reads them back.
    let wasm = wat::parse_str(
        r#"(module
            (func (export "run") (result i32)
                (local i32 i32)
                i32.const 7
                local.set 0
                i32.const 9
                local.set 1
                local.get 0
                local.get 1
                i32.add)
        )"#,
    )
    .expect("wat");

    let trace = traces_from_wasmtime_wasm_bytes(&wasm, "run").expect("normalize");
    let opcodes: Vec<_> = trace.iter().map(|r| r.opcode).collect();
    assert!(
        opcodes.contains(&WasmOpcode::LocalGet),
        "expected local.get in trace: {opcodes:?}"
    );
    assert!(
        opcodes.contains(&WasmOpcode::LocalSet),
        "expected local.set in trace: {opcodes:?}"
    );

    // All local.get rows must have a local_index and local_read_value.
    for row in trace.iter().filter(|r| r.opcode == WasmOpcode::LocalGet) {
        assert!(row.local_index.is_some(), "local.get missing local_index");
        assert!(row.local_read_value.is_some(), "local.get missing local_read_value");
        // The pushed value must match the local's pre-step value.
        assert_eq!(
            row.stack_write1.map(|w| w.value),
            row.local_read_value,
            "local.get write != local_read_value"
        );
    }
    // All local.set rows must have a local_index and local_write_value.
    for row in trace.iter().filter(|r| r.opcode == WasmOpcode::LocalSet) {
        assert!(row.local_index.is_some(), "local.set missing local_index");
        assert!(row.local_write_value.is_some(), "local.set missing local_write_value");
        // The consumed stack value must match what is stored.
        assert_eq!(
            row.stack_read0.map(|r| r.value),
            row.local_write_value,
            "local.set read0 != local_write_value"
        );
    }
}
