//! Shared Route-A trace-layout mapping and reexports for transcript/opening helpers.
//!
//! The heavy Route-A support logic is split by invariant family:
//! - `step_memory_binding`: transcript binding for per-step memory commitments
//! - `opening_lookup`: opening extraction and lookup helpers
//! - `sparse_time_oracles`: sparse decoded columns, time oracles, and preproof payloads
//! - `trace_semantics`: trace linkage, weight vectors, and residual arithmetic

use super::*;

#[path = "opening_lookup.rs"]
mod opening_lookup;
#[path = "sparse_time_oracles.rs"]
mod sparse_time_oracles;
#[path = "step_memory_binding.rs"]
mod step_memory_binding;
#[path = "trace_semantics.rs"]
mod trace_semantics;

pub(crate) use opening_lookup::*;
pub(crate) use sparse_time_oracles::*;
pub use sparse_time_oracles::{TwistTimeLaneOpenings, TwistTimeLaneOpeningsLane};
pub use step_memory_binding::absorb_step_memory;
pub(crate) use step_memory_binding::*;
pub(crate) use trace_semantics::*;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub(crate) enum Rv32PackedShoutOp {
    And,
    Andn,
    Add,
    Or,
    Sub,
    Xor,
    Eq,
    Neq,
    Slt,
    Sll,
    Srl,
    Sra,
    Sltu,
    Mul,
    Mulh,
    Mulhu,
    Mulhsu,
    Div,
    Divu,
    Rem,
    Remu,
}

pub(crate) fn rv32_packed_shout_layout(
    spec: &Option<LutTableSpec>,
) -> Result<Option<(Rv32PackedShoutOp, usize, usize)>, PiCcsError> {
    let (opcode, xlen, time_bits) = match spec {
        Some(LutTableSpec::RiscvOpcodePacked { opcode, xlen }) => (*opcode, *xlen, 0usize),
        Some(LutTableSpec::RiscvOpcodeEventTablePacked {
            opcode,
            xlen,
            time_bits,
        }) => (*opcode, *xlen, *time_bits),
        _ => return Ok(None),
    };

    if !matches!(xlen, 32 | 64) {
        return Err(PiCcsError::InvalidInput(format!(
            "packed RISC-V Shout requires xlen=32 or 64 in Route A (got xlen={xlen})"
        )));
    }
    if time_bits == 0 {
        if matches!(spec, Some(LutTableSpec::RiscvOpcodeEventTablePacked { .. })) {
            return Err(PiCcsError::InvalidInput(
                "RiscvOpcodeEventTablePacked requires time_bits >= 1".into(),
            ));
        }
    } else if xlen != 32 {
        return Err(PiCcsError::InvalidInput(
            "packed RV64 Shout does not support event-table mode in Route A".into(),
        ));
    }

    let op =
        match opcode {
            neo_memory::riscv::lookups::RiscvOpcode::And => Rv32PackedShoutOp::And,
            neo_memory::riscv::lookups::RiscvOpcode::Andn => Rv32PackedShoutOp::Andn,
            neo_memory::riscv::lookups::RiscvOpcode::Add => Rv32PackedShoutOp::Add,
            neo_memory::riscv::lookups::RiscvOpcode::Or => Rv32PackedShoutOp::Or,
            neo_memory::riscv::lookups::RiscvOpcode::Sub => Rv32PackedShoutOp::Sub,
            neo_memory::riscv::lookups::RiscvOpcode::Xor => Rv32PackedShoutOp::Xor,
            neo_memory::riscv::lookups::RiscvOpcode::Eq => Rv32PackedShoutOp::Eq,
            neo_memory::riscv::lookups::RiscvOpcode::Neq => Rv32PackedShoutOp::Neq,
            neo_memory::riscv::lookups::RiscvOpcode::Slt => Rv32PackedShoutOp::Slt,
            neo_memory::riscv::lookups::RiscvOpcode::Sll => Rv32PackedShoutOp::Sll,
            neo_memory::riscv::lookups::RiscvOpcode::Srl => Rv32PackedShoutOp::Srl,
            neo_memory::riscv::lookups::RiscvOpcode::Sra
            | neo_memory::riscv::lookups::RiscvOpcode::VirtualMovsignWord => Rv32PackedShoutOp::Sra,
            neo_memory::riscv::lookups::RiscvOpcode::Sltu => Rv32PackedShoutOp::Sltu,
            neo_memory::riscv::lookups::RiscvOpcode::Mul | neo_memory::riscv::lookups::RiscvOpcode::VirtualMulWord => {
                Rv32PackedShoutOp::Mul
            }
            neo_memory::riscv::lookups::RiscvOpcode::Mulh => Rv32PackedShoutOp::Mulh,
            neo_memory::riscv::lookups::RiscvOpcode::Mulhu => Rv32PackedShoutOp::Mulhu,
            neo_memory::riscv::lookups::RiscvOpcode::Mulhsu => Rv32PackedShoutOp::Mulhsu,
            neo_memory::riscv::lookups::RiscvOpcode::Div | neo_memory::riscv::lookups::RiscvOpcode::VirtualDivWord => {
                Rv32PackedShoutOp::Div
            }
            neo_memory::riscv::lookups::RiscvOpcode::Divu
            | neo_memory::riscv::lookups::RiscvOpcode::VirtualDivuWord => Rv32PackedShoutOp::Divu,
            neo_memory::riscv::lookups::RiscvOpcode::Rem | neo_memory::riscv::lookups::RiscvOpcode::VirtualRemWord => {
                Rv32PackedShoutOp::Rem
            }
            neo_memory::riscv::lookups::RiscvOpcode::Remu
            | neo_memory::riscv::lookups::RiscvOpcode::VirtualRemuWord => Rv32PackedShoutOp::Remu,
            _ => {
                return Err(PiCcsError::InvalidInput(format!(
                    "packed RISC-V Shout is unsupported in Route A for opcode={opcode:?}, xlen={xlen}"
                )));
            }
        };

    if xlen == 64
        && !matches!(
            opcode,
            neo_memory::riscv::lookups::RiscvOpcode::Mul
                | neo_memory::riscv::lookups::RiscvOpcode::Mulh
                | neo_memory::riscv::lookups::RiscvOpcode::Mulhu
                | neo_memory::riscv::lookups::RiscvOpcode::Mulhsu
                | neo_memory::riscv::lookups::RiscvOpcode::Div
                | neo_memory::riscv::lookups::RiscvOpcode::Divu
                | neo_memory::riscv::lookups::RiscvOpcode::Rem
                | neo_memory::riscv::lookups::RiscvOpcode::Remu
        )
    {
        return Err(PiCcsError::InvalidInput(format!(
            "packed RV64 Shout is currently only supported for exact base M-family ops in Route A (got opcode={opcode:?})"
        )));
    }

    Ok(Some((op, xlen, time_bits)))
}

pub(crate) fn rv32_shout_table_id_from_spec(spec: &Option<LutTableSpec>) -> Result<u32, PiCcsError> {
    let (opcode, xlen) = match spec {
        Some(LutTableSpec::RiscvOpcode { opcode, xlen }) => (*opcode, *xlen),
        Some(LutTableSpec::RiscvOpcodePacked { opcode, xlen }) => (*opcode, *xlen),
        Some(LutTableSpec::RiscvOpcodeEventTablePacked { opcode, xlen, .. }) => (*opcode, *xlen),
        Some(LutTableSpec::IdentityU32) => {
            return Err(PiCcsError::InvalidInput(
                "trace linkage expects RISC-V shout table specs (IdentityU32 is unsupported)".into(),
            ));
        }
        None => {
            return Err(PiCcsError::InvalidInput(
                "trace linkage requires LutTableSpec on Shout instances".into(),
            ));
        }
    };

    if !matches!(xlen, 32 | 64) {
        return Err(PiCcsError::InvalidInput(format!(
            "trace linkage expects RISC-V shout specs with xlen=32 or 64 (got xlen={xlen})"
        )));
    }
    Ok(neo_memory::riscv::lookups::RiscvShoutTables::new(xlen)
        .opcode_to_id(opcode)
        .0)
}

pub(crate) fn rv32_trace_link_table_id_from_spec(spec: &Option<LutTableSpec>) -> Result<Option<u32>, PiCcsError> {
    match spec {
        Some(LutTableSpec::RiscvOpcode { .. })
        | Some(LutTableSpec::RiscvOpcodePacked { .. })
        | Some(LutTableSpec::RiscvOpcodeEventTablePacked { .. }) => Ok(Some(rv32_shout_table_id_from_spec(spec)?)),
        Some(LutTableSpec::IdentityU32) | None => Ok(None),
    }
}
