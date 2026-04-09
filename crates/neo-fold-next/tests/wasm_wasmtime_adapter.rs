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
