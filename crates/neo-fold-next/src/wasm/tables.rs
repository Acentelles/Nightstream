//! Owns frontend-local lookup payloads for WASM's Shout-routed opcode family.

use super::ir::WasmStepTrace;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum WasmLookupArity {
    Unary,
    Binary,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct WasmLookupPayload {
    pub arity: WasmLookupArity,
    pub shout_id: u32,
    pub input0: u32,
    pub input1: u32,
    pub output: u32,
}

pub fn lookup_payload(trace: &WasmStepTrace) -> Option<WasmLookupPayload> {
    let shout = trace.info.shout_opcode?;
    let output = trace.stack_write1.map(|lane| lane.value).unwrap_or(0);

    Some(match trace.info.stack_reads {
        1 => WasmLookupPayload {
            arity: WasmLookupArity::Unary,
            shout_id: shout.to_shout_id(),
            input0: trace.stack_read0.map(|lane| lane.value).unwrap_or(0),
            input1: 0,
            output,
        },
        2 => WasmLookupPayload {
            arity: WasmLookupArity::Binary,
            shout_id: shout.to_shout_id(),
            input0: trace.stack_read0.map(|lane| lane.value).unwrap_or(0),
            input1: trace.stack_read1.map(|lane| lane.value).unwrap_or(0),
            output,
        },
        _ => return None,
    })
}
