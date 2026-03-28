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
    let op = match opcode {
        deprecated_neo_memory::riscv::lookups::RiscvOpcode::And => PackedOpcodeKind::And,
        deprecated_neo_memory::riscv::lookups::RiscvOpcode::Andn => PackedOpcodeKind::Andn,
        deprecated_neo_memory::riscv::lookups::RiscvOpcode::Add => PackedOpcodeKind::Add,
        deprecated_neo_memory::riscv::lookups::RiscvOpcode::Or => PackedOpcodeKind::Or,
        deprecated_neo_memory::riscv::lookups::RiscvOpcode::Sub => PackedOpcodeKind::Sub,
        deprecated_neo_memory::riscv::lookups::RiscvOpcode::Xor => PackedOpcodeKind::Xor,
        deprecated_neo_memory::riscv::lookups::RiscvOpcode::Eq => PackedOpcodeKind::Eq,
        deprecated_neo_memory::riscv::lookups::RiscvOpcode::Neq => PackedOpcodeKind::Neq,
        deprecated_neo_memory::riscv::lookups::RiscvOpcode::Slt => PackedOpcodeKind::Slt,
        deprecated_neo_memory::riscv::lookups::RiscvOpcode::Sll => PackedOpcodeKind::Sll,
        deprecated_neo_memory::riscv::lookups::RiscvOpcode::Srl => PackedOpcodeKind::Srl,
        deprecated_neo_memory::riscv::lookups::RiscvOpcode::Sra
        | deprecated_neo_memory::riscv::lookups::RiscvOpcode::VirtualMovsignWord => PackedOpcodeKind::Sra,
        deprecated_neo_memory::riscv::lookups::RiscvOpcode::Sltu => PackedOpcodeKind::Sltu,
        deprecated_neo_memory::riscv::lookups::RiscvOpcode::Mul
        | deprecated_neo_memory::riscv::lookups::RiscvOpcode::VirtualMulWord => PackedOpcodeKind::Mul,
        deprecated_neo_memory::riscv::lookups::RiscvOpcode::Mulh => PackedOpcodeKind::Mulh,
        deprecated_neo_memory::riscv::lookups::RiscvOpcode::Mulhu => PackedOpcodeKind::Mulhu,
        deprecated_neo_memory::riscv::lookups::RiscvOpcode::Mulhsu => PackedOpcodeKind::Mulhsu,
        deprecated_neo_memory::riscv::lookups::RiscvOpcode::Div
        | deprecated_neo_memory::riscv::lookups::RiscvOpcode::VirtualDivWord => PackedOpcodeKind::Div,
        deprecated_neo_memory::riscv::lookups::RiscvOpcode::Divu
        | deprecated_neo_memory::riscv::lookups::RiscvOpcode::VirtualDivuWord => PackedOpcodeKind::Divu,
        deprecated_neo_memory::riscv::lookups::RiscvOpcode::Rem
        | deprecated_neo_memory::riscv::lookups::RiscvOpcode::VirtualRemWord => PackedOpcodeKind::Rem,
        deprecated_neo_memory::riscv::lookups::RiscvOpcode::Remu
        | deprecated_neo_memory::riscv::lookups::RiscvOpcode::VirtualRemuWord => PackedOpcodeKind::Remu,
        _ => {
            return Err(PiCcsError::InvalidInput(format!(
                "packed RISC-V opcode lanes are unsupported in Route A for opcode={opcode:?}, xlen={xlen}"
            )));
        }
    };

    if xlen == 64
        && !matches!(
            opcode,
            deprecated_neo_memory::riscv::lookups::RiscvOpcode::Mul
                | deprecated_neo_memory::riscv::lookups::RiscvOpcode::Mulh
                | deprecated_neo_memory::riscv::lookups::RiscvOpcode::Mulhu
                | deprecated_neo_memory::riscv::lookups::RiscvOpcode::Mulhsu
                | deprecated_neo_memory::riscv::lookups::RiscvOpcode::Div
                | deprecated_neo_memory::riscv::lookups::RiscvOpcode::Divu
                | deprecated_neo_memory::riscv::lookups::RiscvOpcode::Rem
                | deprecated_neo_memory::riscv::lookups::RiscvOpcode::Remu
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
    Ok(deprecated_neo_memory::riscv::lookups::RiscvShoutTables::new(xlen)
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
