//! Owns the exact Stage 1 lookup-row summary and next-PC ROM digest for WASM.

use neo_transcript::{Poseidon2Transcript, Transcript};

use super::super::ir::WasmStepTrace;
use super::super::isa::{WasmOpcode, WasmShoutOpcode};
use super::super::tables::{lookup_payload, WasmLookupArity};

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Stage1LookupRowBinding {
    pub trace_index: usize,
    pub cycle: u64,
    pub pc_before: u64,
    pub opcode: WasmOpcode,
    pub shout_opcode: WasmShoutOpcode,
    pub shout_id: u32,
    pub arity: WasmLookupArity,
    pub input0: u32,
    pub input1: u32,
    pub output: u32,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Stage1ChannelSummary {
    pub channel: WasmShoutOpcode,
    pub rows: Vec<Stage1LookupRowBinding>,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Stage1Summary {
    pub rows: Vec<Stage1LookupRowBinding>,
    pub channels: Vec<Stage1ChannelSummary>,
}

#[derive(Clone, Debug, PartialEq)]
pub struct Stage1EqzProof {
    pub rows: Vec<Stage1LookupRowBinding>,
    pub batched_claim: neo_math::K,
}

#[derive(Clone, Debug, PartialEq)]
pub struct Stage1BinaryProof {
    pub channel: WasmShoutOpcode,
    pub rows: Vec<Stage1LookupRowBinding>,
    pub batched_claim: neo_math::K,
}

/// Compute a Poseidon2 digest of the next-PC ROM entries (sorted by pc_before).
pub fn digest_pc_rom(rom: &[(u64, u64)]) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"wasm/pc_rom");
    tr.append_u64s(b"wasm/pc_rom/count", &[rom.len() as u64]);
    for (pc_before, pc_after) in rom {
        tr.append_u64s(b"wasm/pc_rom/entry", &[*pc_before, *pc_after]);
    }
    tr.digest32()
}

pub fn build_stage1_summary(steps: &[WasmStepTrace]) -> Stage1Summary {
    let rows: Vec<Stage1LookupRowBinding> = steps
        .iter()
        .enumerate()
        .filter_map(|(trace_index, step)| {
            let shout_opcode = step.info.shout_opcode?;
            let payload = lookup_payload(step)?;
            Some(Stage1LookupRowBinding {
                trace_index,
                cycle: step.cycle,
                pc_before: step.pc_before,
                opcode: step.opcode,
                shout_opcode,
                shout_id: payload.shout_id,
                arity: payload.arity,
                input0: payload.input0,
                input1: payload.input1,
                output: payload.output,
            })
        })
        .collect();

    let channels = WasmShoutOpcode::all()
        .into_iter()
        .filter_map(|channel| {
            let rows: Vec<Stage1LookupRowBinding> = rows
                .iter()
                .filter(|row| row.shout_opcode == channel)
                .cloned()
                .collect();
            (!rows.is_empty()).then_some(Stage1ChannelSummary { channel, rows })
        })
        .collect();

    Stage1Summary { rows, channels }
}
