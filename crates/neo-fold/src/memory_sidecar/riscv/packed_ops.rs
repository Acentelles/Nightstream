use super::*;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub(crate) enum PackedOpcodeKind {
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

pub(crate) fn packed_opcode_layout(
    spec: &Option<LutTableSpec>,
) -> Result<Option<(PackedOpcodeKind, usize)>, PiCcsError> {
    let (opcode, xlen) = match spec {
        Some(LutTableSpec::RiscvOpcodePacked { opcode, xlen }) => (*opcode, *xlen),
        _ => return Ok(None),
    };

    if !matches!(xlen, 32 | 64) {
        return Err(PiCcsError::InvalidInput(format!(
            "packed RISC-V opcode lanes require xlen=32 or 64 in Route A (got xlen={xlen})"
        )));
    }
    let op =
        match opcode {
            neo_memory::riscv::lookups::RiscvOpcode::And => PackedOpcodeKind::And,
            neo_memory::riscv::lookups::RiscvOpcode::Andn => PackedOpcodeKind::Andn,
            neo_memory::riscv::lookups::RiscvOpcode::Add => PackedOpcodeKind::Add,
            neo_memory::riscv::lookups::RiscvOpcode::Or => PackedOpcodeKind::Or,
            neo_memory::riscv::lookups::RiscvOpcode::Sub => PackedOpcodeKind::Sub,
            neo_memory::riscv::lookups::RiscvOpcode::Xor => PackedOpcodeKind::Xor,
            neo_memory::riscv::lookups::RiscvOpcode::Eq => PackedOpcodeKind::Eq,
            neo_memory::riscv::lookups::RiscvOpcode::Neq => PackedOpcodeKind::Neq,
            neo_memory::riscv::lookups::RiscvOpcode::Slt => PackedOpcodeKind::Slt,
            neo_memory::riscv::lookups::RiscvOpcode::Sll => PackedOpcodeKind::Sll,
            neo_memory::riscv::lookups::RiscvOpcode::Srl => PackedOpcodeKind::Srl,
            neo_memory::riscv::lookups::RiscvOpcode::Sra
            | neo_memory::riscv::lookups::RiscvOpcode::VirtualMovsignWord => PackedOpcodeKind::Sra,
            neo_memory::riscv::lookups::RiscvOpcode::Sltu => PackedOpcodeKind::Sltu,
            neo_memory::riscv::lookups::RiscvOpcode::Mul | neo_memory::riscv::lookups::RiscvOpcode::VirtualMulWord => {
                PackedOpcodeKind::Mul
            }
            neo_memory::riscv::lookups::RiscvOpcode::Mulh => PackedOpcodeKind::Mulh,
            neo_memory::riscv::lookups::RiscvOpcode::Mulhu => PackedOpcodeKind::Mulhu,
            neo_memory::riscv::lookups::RiscvOpcode::Mulhsu => PackedOpcodeKind::Mulhsu,
            neo_memory::riscv::lookups::RiscvOpcode::Div | neo_memory::riscv::lookups::RiscvOpcode::VirtualDivWord => {
                PackedOpcodeKind::Div
            }
            neo_memory::riscv::lookups::RiscvOpcode::Divu
            | neo_memory::riscv::lookups::RiscvOpcode::VirtualDivuWord => PackedOpcodeKind::Divu,
            neo_memory::riscv::lookups::RiscvOpcode::Rem | neo_memory::riscv::lookups::RiscvOpcode::VirtualRemWord => {
                PackedOpcodeKind::Rem
            }
            neo_memory::riscv::lookups::RiscvOpcode::Remu
            | neo_memory::riscv::lookups::RiscvOpcode::VirtualRemuWord => PackedOpcodeKind::Remu,
            _ => {
                return Err(PiCcsError::InvalidInput(format!(
                    "packed RISC-V opcode lanes are unsupported in Route A for opcode={opcode:?}, xlen={xlen}"
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
            "packed RV64 opcode lanes are currently only supported for exact base M-family ops in Route A (got opcode={opcode:?})"
        )));
    }

    Ok(Some((op, xlen)))
}

pub(crate) fn opcode_table_id_from_spec(spec: &Option<LutTableSpec>) -> Result<u32, PiCcsError> {
    let (opcode, xlen) = match spec {
        Some(LutTableSpec::RiscvOpcode { opcode, xlen }) => (*opcode, *xlen),
        Some(LutTableSpec::RiscvOpcodePacked { opcode, xlen }) => (*opcode, *xlen),
        Some(LutTableSpec::IdentityU32) => {
            return Err(PiCcsError::InvalidInput(
                "trace linkage expects RISC-V opcode table specs (IdentityU32 is unsupported)".into(),
            ));
        }
        Some(_) => {
            return Err(PiCcsError::InvalidInput(
                "unsupported packed opcode table spec in neo-fold".into(),
            ));
        }
        None => {
            return Err(PiCcsError::InvalidInput(
                "trace linkage requires LutTableSpec on opcode lookup instances".into(),
            ));
        }
    };

    if !matches!(xlen, 32 | 64) {
        return Err(PiCcsError::InvalidInput(format!(
            "trace linkage expects RISC-V opcode specs with xlen=32 or 64 (got xlen={xlen})"
        )));
    }
    Ok(neo_memory::riscv::lookups::RiscvShoutTables::new(xlen)
        .opcode_to_id(opcode)
        .0)
}

pub(crate) fn trace_link_opcode_table_id_from_spec(spec: &Option<LutTableSpec>) -> Result<Option<u32>, PiCcsError> {
    match spec {
        Some(LutTableSpec::RiscvOpcode { .. }) | Some(LutTableSpec::RiscvOpcodePacked { .. }) => {
            Ok(Some(opcode_table_id_from_spec(spec)?))
        }
        Some(LutTableSpec::IdentityU32) | None => Ok(None),
        Some(_) => Err(PiCcsError::InvalidInput(
            "unsupported packed opcode table spec in neo-fold".into(),
        )),
    }
}
