//! Owns direct Wasmtime tracing and normalization into the generic WASM IR.

use std::collections::BTreeMap;
use std::future::Future;
use std::sync::Arc;

use futures::executor::block_on;
use serde::{Deserialize, Serialize};
use wasmparser::{Parser, Payload};
use wasmtime::{
    Config, DebugEvent, DebugHandler, Engine, FrameHandle, Linker, Module, Store, StoreContextMut, TypedFunc, Val,
};

use super::super::ir::{StackLaneAccess, WasmBuildError, WasmStepTrace};
use super::super::isa::{opcode_code, opcode_info_from_code, WasmOpcode};
use super::super::lower::WasmTraceSource;

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct WasmtimeTraceStep {
    pub step: u64,
    pub frame_depth: usize,
    pub function: String,
    pub function_index: Option<u32>,
    pub pc: Option<u32>,
    pub opcode: Option<String>,
    pub memory: Option<WasmtimeTraceMemoryAccess>,
    pub locals: Vec<String>,
    pub operand_stack: Vec<String>,
}

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct WasmtimeTraceMemoryAccess {
    pub kind: String,
    pub memory_index: u32,
    pub offset: u64,
    pub base_address: u64,
    pub effective_address: u64,
    pub value_i32: Option<i32>,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct WasmtimeTraceRun {
    pub result_i32: i32,
    pub steps: Vec<WasmtimeTraceStep>,
}

#[derive(Clone, Copy, Debug, Default)]
struct WasmtimeDebugHandler;

#[derive(Debug, Default)]
struct WasmtimeTraceState {
    next_step: u64,
    steps: Vec<WasmtimeTraceStep>,
    opcode_map: Arc<BTreeMap<(u32, u32), DecodedOpcode>>,
}

#[derive(Clone, Debug)]
struct DecodedOpcode {
    text: String,
    memory: Option<DecodedMemoryOpcode>,
}

#[derive(Clone, Copy, Debug)]
struct DecodedMemoryOpcode {
    kind: DecodedMemoryAccessKind,
    memory_index: u32,
    offset: u64,
}

#[derive(Clone, Copy, Debug)]
enum DecodedMemoryAccessKind {
    I32Load,
    I32Store,
}

impl WasmTraceSource for [WasmtimeTraceStep] {
    fn lower_to_wasm_ir(&self) -> Result<Vec<WasmStepTrace>, WasmBuildError> {
        traces_from_wasmtime_steps(self)
    }
}

impl WasmTraceSource for Vec<WasmtimeTraceStep> {
    fn lower_to_wasm_ir(&self) -> Result<Vec<WasmStepTrace>, WasmBuildError> {
        traces_from_wasmtime_steps(self)
    }
}

pub fn collect_wasmtime_steps(wasm_bytes: &[u8], export: &str) -> Result<WasmtimeTraceRun, WasmBuildError> {
    let opcode_map = Arc::new(build_opcode_map(wasm_bytes)?);

    let mut config = Config::new();
    config.guest_debug(true);

    let engine = Engine::new(&config)
        .map_err(|err| WasmBuildError::Trace(format!("failed to create Wasmtime engine: {err}")))?;
    let module = Module::from_binary(&engine, wasm_bytes)
        .map_err(|err| WasmBuildError::Trace(format!("failed to compile wasm bytes: {err}")))?;

    let mut store = Store::new(
        &engine,
        WasmtimeTraceState {
            next_step: 0,
            steps: Vec::new(),
            opcode_map,
        },
    );
    store.set_debug_handler(WasmtimeDebugHandler);

    {
        let mut edit = store
            .edit_breakpoints()
            .ok_or_else(|| WasmBuildError::Trace("guest debug not enabled".to_string()))?;
        edit.single_step(true)
            .map_err(|err| WasmBuildError::Trace(format!("failed to enable Wasmtime single-step mode: {err}")))?;
    }

    let linker = Linker::new(&engine);
    let instance = block_on(linker.instantiate_async(&mut store, &module))
        .map_err(|err| WasmBuildError::Trace(format!("failed to instantiate Wasmtime module: {err}")))?;
    let func: TypedFunc<(), i32> = instance
        .get_typed_func(&mut store, export)
        .map_err(|err| WasmBuildError::Trace(format!("failed to access Wasmtime export {export}: {err}")))?;
    let result_i32 = block_on(func.call_async(&mut store, ()))
        .map_err(|err| WasmBuildError::Trace(format!("failed to execute Wasmtime export {export}: {err}")))?;

    Ok(WasmtimeTraceRun {
        result_i32,
        steps: store.data().steps.clone(),
    })
}

pub fn traces_from_wasmtime_wasm_bytes(wasm_bytes: &[u8], export: &str) -> Result<Vec<WasmStepTrace>, WasmBuildError> {
    let run = collect_wasmtime_steps(wasm_bytes, export)?;
    traces_from_wasmtime_steps(&run.steps)
}

pub fn traces_from_wasmtime_steps(rows: &[WasmtimeTraceStep]) -> Result<Vec<WasmStepTrace>, WasmBuildError> {
    let mut supported = Vec::new();
    for row in rows {
        if let Some(normalized) = normalize_supported_row(row)? {
            supported.push(normalized);
        }
    }

    let mut out = Vec::with_capacity(supported.len());
    for (idx, current) in supported.iter().enumerate() {
        let next = supported.get(idx + 1);
        let pc_before = u64::from(current.pc);
        let pc_after = next
            .map(|row| u64::from(row.pc))
            .unwrap_or_else(|| pc_before.saturating_add(1));
        let sp_before = current.operand_stack.len() as u64;
        let expected_sp_after = sp_before
            .saturating_sub(u64::from(current.info.stack_reads))
            .saturating_add(u64::from(current.info.stack_writes));
        let sp_after = next
            .map(|row| row.operand_stack.len() as u64)
            .unwrap_or(expected_sp_after);
        let stack_read0 = read_lane(&current.operand_stack, sp_before, current.info.stack_reads, 0);
        let stack_read1 = read_lane(&current.operand_stack, sp_before, current.info.stack_reads, 1);
        let stack_read2 = read_lane(&current.operand_stack, sp_before, current.info.stack_reads, 2);
        let stack_write1 = write_lane(current, next, sp_after)?;
        let halted = matches!(current.opcode, WasmOpcode::Return) || next.is_none();

        out.push(WasmStepTrace {
            cycle: current.cycle,
            pc_before,
            pc_after,
            opcode_code: current.info.code,
            opcode: current.opcode,
            info: current.info,
            sp_before,
            sp_after,
            stack_read0,
            stack_read1,
            stack_read2,
            stack_write1,
            halted,
        });
    }

    if out.is_empty() {
        return Err(WasmBuildError::Unsupported(
            "wasmtime trace did not contain any currently supported wasm rows".to_string(),
        ));
    }

    Ok(out)
}

#[derive(Clone, Debug)]
struct SupportedRow {
    cycle: u64,
    pc: u32,
    opcode: WasmOpcode,
    info: super::super::isa::WasmOpcodeInfo,
    operand_stack: Vec<u32>,
    immediate_i32: Option<u32>,
}

impl DebugHandler for WasmtimeDebugHandler {
    type Data = WasmtimeTraceState;

    fn handle(
        &self,
        mut store: StoreContextMut<'_, Self::Data>,
        event: DebugEvent<'_>,
    ) -> impl Future<Output = ()> + Send {
        async move {
            if !matches!(event, DebugEvent::Breakpoint) {
                return;
            }

            let frames = store.debug_exit_frames().collect::<Vec<FrameHandle>>();
            let step = store.data().next_step;
            let mut rows = Vec::with_capacity(frames.len());
            for (frame_depth, frame) in frames.iter().enumerate() {
                match capture_frame(step, frame_depth, frame, &mut store) {
                    Ok(row) => rows.push(row),
                    Err(error) => rows.push(WasmtimeTraceStep {
                        step,
                        frame_depth,
                        function: "<frame-inspection-error>".to_string(),
                        function_index: None,
                        pc: None,
                        opcode: None,
                        memory: None,
                        locals: vec![error.to_string()],
                        operand_stack: Vec::new(),
                    }),
                }
            }

            let state = store.data_mut();
            state.next_step += 1;
            state.steps.extend(rows);
        }
    }
}

fn normalize_supported_row(row: &WasmtimeTraceStep) -> Result<Option<SupportedRow>, WasmBuildError> {
    if row.frame_depth != 0 {
        return Ok(None);
    }
    let Some(pc) = row.pc else {
        return Ok(None);
    };
    let Some(opcode_text) = row.opcode.as_deref() else {
        return Ok(None);
    };
    let Some((opcode, immediate_i32)) = parse_supported_opcode(opcode_text)? else {
        return Ok(None);
    };
    let operand_stack = row
        .operand_stack
        .iter()
        .map(|value| parse_stack_word(value))
        .collect::<Result<Vec<_>, _>>()?;
    let code = opcode_code(opcode);

    Ok(Some(SupportedRow {
        cycle: row.step,
        pc,
        opcode,
        info: opcode_info_from_code(code),
        operand_stack,
        immediate_i32,
    }))
}

fn capture_frame(
    step: u64,
    frame_depth: usize,
    frame: &FrameHandle,
    store: &mut StoreContextMut<'_, WasmtimeTraceState>,
) -> Result<WasmtimeTraceStep, WasmBuildError> {
    let (function, function_index, pc) = match frame
        .wasm_function_index_and_pc(&mut *store)
        .map_err(|err| WasmBuildError::Trace(format!("failed to inspect Wasmtime frame function/pc: {err}")))?
    {
        Some((func_index, pc)) => {
            let function_index = func_index.as_u32();
            (format!("{func_index:?}"), Some(function_index), Some(pc))
        }
        None => ("<host-or-unknown>".to_string(), None, None),
    };
    let decoded_opcode = function_index
        .zip(pc)
        .and_then(|key| store.data().opcode_map.get(&key).cloned());
    let opcode = decoded_opcode.as_ref().map(|decoded| decoded.text.clone());

    let num_locals = frame
        .num_locals(&mut *store)
        .map_err(|err| WasmBuildError::Trace(format!("failed to inspect Wasmtime locals length: {err}")))?;
    let mut locals = Vec::with_capacity(num_locals as usize);
    for index in 0..num_locals {
        let value = frame
            .local(&mut *store, index)
            .map_err(|err| WasmBuildError::Trace(format!("failed to inspect Wasmtime local {index}: {err}")))?;
        locals.push(val_to_string(value));
    }

    let num_stacks = frame
        .num_stacks(&mut *store)
        .map_err(|err| WasmBuildError::Trace(format!("failed to inspect Wasmtime operand stack length: {err}")))?;
    let mut operand_stack = Vec::with_capacity(num_stacks as usize);
    for index in 0..num_stacks {
        let value = frame.stack(&mut *store, index).map_err(|err| {
            WasmBuildError::Trace(format!("failed to inspect Wasmtime operand stack value {index}: {err}"))
        })?;
        operand_stack.push(val_to_string(value));
    }
    let memory = capture_memory_access(decoded_opcode.as_ref(), frame, store, &operand_stack)?;

    Ok(WasmtimeTraceStep {
        step,
        frame_depth,
        function,
        function_index,
        pc,
        opcode,
        memory,
        locals,
        operand_stack,
    })
}

fn build_opcode_map(wasm_bytes: &[u8]) -> Result<BTreeMap<(u32, u32), DecodedOpcode>, WasmBuildError> {
    let mut map = BTreeMap::new();
    let mut defined_function_index = 0_u32;

    for payload in Parser::new(0).parse_all(wasm_bytes) {
        match payload.map_err(|err| WasmBuildError::Trace(format!("failed to parse wasm payload: {err}")))? {
            Payload::CodeSectionEntry(body) => {
                let mut reader = body
                    .get_operators_reader()
                    .map_err(|err| WasmBuildError::Trace(format!("failed to read wasm operators: {err}")))?;
                while !reader.eof() {
                    let offset = reader.original_position() as u32;
                    let operator = reader
                        .read()
                        .map_err(|err| WasmBuildError::Trace(format!("failed to decode wasm operator: {err}")))?;
                    map.insert(
                        (defined_function_index, offset),
                        DecodedOpcode {
                            text: format!("{operator:?}"),
                            memory: decode_memory_opcode(&operator),
                        },
                    );
                }
                defined_function_index += 1;
            }
            _ => {}
        }
    }

    Ok(map)
}

fn decode_memory_opcode(operator: &wasmparser::Operator<'_>) -> Option<DecodedMemoryOpcode> {
    match operator {
        wasmparser::Operator::I32Load { memarg } => Some(DecodedMemoryOpcode {
            kind: DecodedMemoryAccessKind::I32Load,
            memory_index: memarg.memory,
            offset: memarg.offset,
        }),
        wasmparser::Operator::I32Store { memarg } => Some(DecodedMemoryOpcode {
            kind: DecodedMemoryAccessKind::I32Store,
            memory_index: memarg.memory,
            offset: memarg.offset,
        }),
        _ => None,
    }
}

fn capture_memory_access(
    decoded_opcode: Option<&DecodedOpcode>,
    frame: &FrameHandle,
    store: &mut StoreContextMut<'_, WasmtimeTraceState>,
    operand_stack: &[String],
) -> Result<Option<WasmtimeTraceMemoryAccess>, WasmBuildError> {
    let Some(memory_opcode) = decoded_opcode.and_then(|opcode| opcode.memory) else {
        return Ok(None);
    };

    let base_address = match memory_opcode.kind {
        DecodedMemoryAccessKind::I32Load => operand_stack
            .last()
            .and_then(|value| value.parse::<u64>().ok()),
        DecodedMemoryAccessKind::I32Store => operand_stack
            .get(operand_stack.len().saturating_sub(2))
            .and_then(|value| value.parse::<u64>().ok()),
    };
    let Some(base_address) = base_address else {
        return Ok(None);
    };
    let Some(effective_address) = base_address.checked_add(memory_opcode.offset) else {
        return Err(WasmBuildError::Trace("wasmtime effective address overflow".to_string()));
    };

    let instance = frame
        .instance(&mut *store)
        .map_err(|err| WasmBuildError::Trace(format!("failed to inspect Wasmtime frame instance: {err}")))?;
    let Some(memory) = instance.debug_memory(&mut *store, memory_opcode.memory_index) else {
        return Ok(None);
    };

    let mut bytes = [0_u8; 4];
    memory
        .read(&mut *store, effective_address as usize, &mut bytes)
        .map_err(|err| {
            WasmBuildError::Trace(format!(
                "failed to read Wasmtime memory at address {effective_address}: {err}"
            ))
        })?;
    let loaded_value = i32::from_le_bytes(bytes);
    let value_i32 = match memory_opcode.kind {
        DecodedMemoryAccessKind::I32Load => Some(loaded_value),
        DecodedMemoryAccessKind::I32Store => operand_stack
            .last()
            .and_then(|value| value.parse::<i32>().ok())
            .or(Some(loaded_value)),
    };

    Ok(Some(WasmtimeTraceMemoryAccess {
        kind: match memory_opcode.kind {
            DecodedMemoryAccessKind::I32Load => "i32.load".to_string(),
            DecodedMemoryAccessKind::I32Store => "i32.store".to_string(),
        },
        memory_index: memory_opcode.memory_index,
        offset: memory_opcode.offset,
        base_address,
        effective_address,
        value_i32,
    }))
}

fn parse_supported_opcode(opcode_text: &str) -> Result<Option<(WasmOpcode, Option<u32>)>, WasmBuildError> {
    if let Some(value) = parse_i32_const(opcode_text)? {
        return Ok(Some((WasmOpcode::I32Const, Some(value))));
    }

    let opcode = match opcode_text {
        "I32Add" => WasmOpcode::I32Add,
        "I32Sub" => WasmOpcode::I32Sub,
        "I32Popcnt" => WasmOpcode::I32Popcnt,
        "I32Eqz" => WasmOpcode::I32Eqz,
        "I32Eq" => WasmOpcode::I32Eq,
        "I32Ne" => WasmOpcode::I32Ne,
        "I32LtS" => WasmOpcode::I32LtS,
        "I32LtU" => WasmOpcode::I32LtU,
        "I32And" => WasmOpcode::I32And,
        "I32Or" => WasmOpcode::I32Or,
        "I32Xor" => WasmOpcode::I32Xor,
        "I32Mul" => WasmOpcode::I32Mul,
        "Select" => WasmOpcode::Select,
        text if text.starts_with("BrIf ") || text.starts_with("BrIf {") => WasmOpcode::BrIfEqz,
        "Return" | "End" => WasmOpcode::Return,
        _ => return Ok(None),
    };

    Ok(Some((opcode, None)))
}

fn parse_i32_const(opcode_text: &str) -> Result<Option<u32>, WasmBuildError> {
    const PREFIX: &str = "I32Const { value: ";
    if !opcode_text.starts_with(PREFIX) || !opcode_text.ends_with(" }") {
        return Ok(None);
    }
    let value_text = &opcode_text[PREFIX.len()..opcode_text.len() - 2];
    Ok(Some(parse_signed_u32(value_text)?))
}

fn parse_stack_word(value: &str) -> Result<u32, WasmBuildError> {
    parse_signed_u32(value)
        .map_err(|err| WasmBuildError::Trace(format!("failed to parse Wasmtime operand stack value '{value}': {err}")))
}

fn parse_signed_u32(value: &str) -> Result<u32, WasmBuildError> {
    let parsed = value.parse::<i128>().map_err(|err| {
        WasmBuildError::Trace(format!("failed to parse signed i32-compatible value '{value}': {err}"))
    })?;
    Ok((parsed as i32) as u32)
}

fn read_lane(stack: &[u32], sp_before: u64, reads: u8, lane: usize) -> Option<StackLaneAccess> {
    let reads = reads as usize;
    if reads == 0 || lane >= reads {
        return None;
    }
    let stack_index = stack.len().checked_sub(reads)?.checked_add(lane)?;
    let addr = sp_before
        .checked_sub(reads as u64)?
        .checked_add(lane as u64)?;
    stack
        .get(stack_index)
        .copied()
        .map(|value| StackLaneAccess { addr, value })
}

fn write_lane(
    current: &SupportedRow,
    next: Option<&SupportedRow>,
    sp_after: u64,
) -> Result<Option<StackLaneAccess>, WasmBuildError> {
    if current.info.stack_writes == 0 {
        return Ok(None);
    }

    let value = match current.opcode {
        WasmOpcode::I32Const => current.immediate_i32.ok_or_else(|| {
            WasmBuildError::Trace(format!(
                "missing Wasmtime immediate for i32.const at cycle {}",
                current.cycle
            ))
        })?,
        _ => next
            .and_then(|row| row.operand_stack.last().copied())
            .ok_or_else(|| {
                WasmBuildError::Trace(format!(
                    "missing Wasmtime post-state stack value for {} at cycle {}",
                    current.info.name, current.cycle
                ))
            })?,
    };

    Ok(Some(StackLaneAccess {
        addr: sp_after.saturating_sub(1),
        value,
    }))
}

fn val_to_string(val: Val) -> String {
    match val {
        Val::I32(x) => x.to_string(),
        Val::I64(x) => x.to_string(),
        Val::F32(x) => f32::from_bits(x).to_string(),
        Val::F64(x) => f64::from_bits(x).to_string(),
        other => format!("{other:?}"),
    }
}
