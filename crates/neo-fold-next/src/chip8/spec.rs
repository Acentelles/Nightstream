//! Owns the static CHIP-8 VM specification and the 24-column main-lane CCS.

use neo_math::F;
use p3_field::PrimeCharacteristicRing;

use crate::proof::ExtensionFamily;
use crate::vm::decode::{DecodeField, DecodeSpec};
use crate::vm::opcode_classes::OpcodeClassSpec;
use crate::vm::r1cs_builder::R1csBuilder;
use crate::vm::state::{RegisterSpec, StateSpec};
use crate::vm::{CoreCcsSpec, ShoutTableSpec, TwistTableSpec, VmSpec};

// ---------------------------------------------------------------------------
// Domain constants (§1.2)
// ---------------------------------------------------------------------------
// ADDR_REG_BITS, ADDR_RAM_BITS, ROM_ADDR_BITS, REG_SINK_ADDR, RAM_SINK_ADDR
// are canonically defined in tables.rs and re-exported from chip8::*.

pub const CHIP8_PROGRAM_START: u16 = 0x200;
pub const CHIP8_MEMORY_BYTES: usize = 4096;

// ---------------------------------------------------------------------------
// 24-column main-lane layout (§3.1)
// ---------------------------------------------------------------------------

pub const WITNESS_WIDTH: usize = 24;
pub const PUBLIC_INPUTS: usize = 1;

pub const COL_ONE: usize = 0;
pub const COL_PC: usize = 1;
pub const COL_PC_NEXT: usize = 2;
pub const COL_REG_X: usize = 3;
pub const COL_REG_Y: usize = 4;
pub const COL_REG_X_NEXT: usize = 5;
pub const COL_I_REG: usize = 6;
pub const COL_I_NEXT: usize = 7;
pub const COL_KK: usize = 8;
pub const COL_NNN_ADDR: usize = 9;
pub const COL_NNN_WORD: usize = 10;
pub const COL_MEM_VALUE: usize = 11;
pub const COL_LOOKUP_OUTPUT: usize = 12;
pub const COL_WRITES_LOOKUP_TO_X: usize = 13;
pub const COL_WRITES_MEM_TO_X: usize = 14;
pub const COL_PRESERVES_X: usize = 15;
pub const COL_WRITES_NNN_TO_I: usize = 16;
pub const COL_IS_JUMP: usize = 17;
pub const COL_IS_BRANCH: usize = 18;
pub const COL_IS_MEMOP: usize = 19;
pub const COL_X_IDX: usize = 20;
pub const COL_Y_IDX: usize = 21;
pub const COL_BURST_LAST: usize = 22;
pub const COL_RAM_ADDR: usize = 23;

const BOOLEAN_COLS: [usize; 8] = [
    COL_WRITES_LOOKUP_TO_X,
    COL_WRITES_MEM_TO_X,
    COL_PRESERVES_X,
    COL_WRITES_NNN_TO_I,
    COL_IS_JUMP,
    COL_IS_BRANCH,
    COL_IS_MEMOP,
    COL_BURST_LAST,
];

// ---------------------------------------------------------------------------
// CommitmentId (§9.1)
// ---------------------------------------------------------------------------

#[derive(Clone, Copy, Debug, Eq, PartialEq, Hash, PartialOrd, Ord)]
pub enum CommitmentId {
    Lane,
    FetchRa,
    DecodeRa,
    AluRa,
    Eq4Ra,
    DecodeHandoff,
    RegTwist,
    RamTwist,
    RomTable,
    DecodeTable,
    AluTable,
    Eq4Table,
}

// LookupKind, OperandSelector, DecodeOutput, and decode_to_output are
// canonically defined in tables.rs and re-exported from chip8::*.

// ---------------------------------------------------------------------------
// Opcode types (kept from original)
// ---------------------------------------------------------------------------

#[derive(Clone, Copy, Debug, Eq, PartialEq, Hash)]
pub enum Chip8Opcode {
    LdImm,
    AddImm,
    Mov,
    AddReg,
    SkipEqImm,
    Jump,
    LdI,
    StoreRegs,
    LoadRegs,
}

impl Chip8Opcode {
    pub fn all() -> [Self; 9] {
        [
            Self::LdImm,
            Self::AddImm,
            Self::Mov,
            Self::AddReg,
            Self::SkipEqImm,
            Self::Jump,
            Self::LdI,
            Self::StoreRegs,
            Self::LoadRegs,
        ]
    }

    pub fn family_requirements(self) -> &'static [ExtensionFamily] {
        match self {
            Self::LdImm | Self::AddImm | Self::Mov | Self::AddReg | Self::SkipEqImm | Self::Jump | Self::LdI => {
                &[ExtensionFamily::BytecodeFetch, ExtensionFamily::RegisterHistory]
            }
            Self::StoreRegs | Self::LoadRegs => &[
                ExtensionFamily::BytecodeFetch,
                ExtensionFamily::RegisterHistory,
                ExtensionFamily::RamHistory,
            ],
        }
    }
}

// ---------------------------------------------------------------------------
// Program / State / Trace types (kept from original)
// ---------------------------------------------------------------------------

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Chip8Program {
    pub bytes: Vec<u8>,
    pub start_pc: u16,
}

impl Chip8Program {
    pub fn from_opcodes(opcodes: &[u16]) -> Self {
        let mut bytes = Vec::with_capacity(opcodes.len() * 2);
        for opcode in opcodes {
            bytes.push((opcode >> 8) as u8);
            bytes.push(*opcode as u8);
        }
        Self {
            bytes,
            start_pc: CHIP8_PROGRAM_START,
        }
    }

    pub fn opcode_at(&self, pc: u16) -> Option<u16> {
        let offset = pc.checked_sub(self.start_pc)? as usize;
        let hi = *self.bytes.get(offset)? as u16;
        let lo = *self.bytes.get(offset + 1)? as u16;
        Some((hi << 8) | lo)
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Chip8State {
    pub pc: u16,
    pub i: u16,
    pub v: [u8; 16],
    pub memory: [u8; CHIP8_MEMORY_BYTES],
}

impl Default for Chip8State {
    fn default() -> Self {
        Self {
            pc: CHIP8_PROGRAM_START,
            i: 0,
            v: [0; 16],
            memory: [0; CHIP8_MEMORY_BYTES],
        }
    }
}

impl Chip8State {
    pub fn with_program(program: &Chip8Program) -> Result<Self, String> {
        let mut state = Self::default();
        let start = program.start_pc as usize;
        let end = start
            .checked_add(program.bytes.len())
            .ok_or_else(|| "program length overflow".to_string())?;
        if end > CHIP8_MEMORY_BYTES {
            return Err("program does not fit in CHIP-8 memory".into());
        }
        state.memory[start..end].copy_from_slice(&program.bytes);
        state.pc = program.start_pc;
        Ok(state)
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct Chip8StepTrace {
    pub opcode: u16,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct Chip8DecodedStep {
    pub opcode_id: Chip8Opcode,
    pub x: u8,
    pub y: u8,
    pub kk: u8,
    pub nnn: u16,
}

// ---------------------------------------------------------------------------
// Opcode decode
// ---------------------------------------------------------------------------

pub fn decode_opcode(opcode: u16) -> Result<Chip8DecodedStep, String> {
    let top = (opcode & 0xF000) >> 12;
    let x = ((opcode & 0x0F00) >> 8) as u8;
    let y = ((opcode & 0x00F0) >> 4) as u8;
    let n = (opcode & 0x000F) as u8;
    let kk = (opcode & 0x00FF) as u8;
    let nnn = opcode & 0x0FFF;
    let opcode_id = match (top, n) {
        (0x6, _) => Chip8Opcode::LdImm,
        (0x7, _) => Chip8Opcode::AddImm,
        (0x8, 0x0) => Chip8Opcode::Mov,
        (0x8, 0x4) => Chip8Opcode::AddReg,
        (0x3, _) => Chip8Opcode::SkipEqImm,
        (0x1, _) => Chip8Opcode::Jump,
        (0xA, _) => Chip8Opcode::LdI,
        (0xF, 0x5) if kk == 0x55 => Chip8Opcode::StoreRegs,
        (0xF, 0x5) if kk == 0x65 => Chip8Opcode::LoadRegs,
        (0xF, 0x5) => return Err(format!("unsupported 0xF? opcode 0x{opcode:04x}")),
        _ => return Err(format!("unsupported CHIP-8 opcode 0x{opcode:04x}")),
    };
    Ok(Chip8DecodedStep {
        opcode_id,
        x,
        y,
        kk,
        nnn,
    })
}

// ---------------------------------------------------------------------------
// Pad row (§3.2)
// ---------------------------------------------------------------------------

pub fn build_pad_row(pad_pc_word: u16) -> [F; WITNESS_WIDTH] {
    let mut row = [F::ZERO; WITNESS_WIDTH];
    row[COL_ONE] = F::ONE;
    row[COL_PC] = F::from_u64(pad_pc_word as u64);
    row[COL_PC_NEXT] = F::from_u64(pad_pc_word as u64);
    // REG_X, REG_Y, REG_X_NEXT, I_REG, I_NEXT, KK = 0
    row[COL_NNN_ADDR] = F::from_u64(2 * pad_pc_word as u64);
    row[COL_NNN_WORD] = F::from_u64(pad_pc_word as u64);
    // MEM_VALUE, LOOKUP_OUTPUT = 0
    // WritesLookupToX, WritesMemToX = 0
    row[COL_PRESERVES_X] = F::ONE;
    // WritesNnnToI = 0
    row[COL_IS_JUMP] = F::ONE;
    // IsBranch, IsMemOp = 0
    // X_IDX, Y_IDX, BURST_LAST, RAM_ADDR = 0
    row
}

// ---------------------------------------------------------------------------
// VmSpec implementation
// ---------------------------------------------------------------------------

#[derive(Clone, Debug)]
pub struct Chip8VmSpec {
    core: CoreCcsSpec,
}

impl Default for Chip8VmSpec {
    fn default() -> Self {
        Self::new().expect("valid CHIP-8 core CCS")
    }
}

impl Chip8VmSpec {
    pub fn new() -> Result<Self, String> {
        Ok(Self {
            core: build_core_ccs_spec()?,
        })
    }
}

impl VmSpec for Chip8VmSpec {
    type OpcodeId = Chip8Opcode;

    fn name(&self) -> &'static str {
        "chip8"
    }

    fn state_spec(&self) -> StateSpec {
        StateSpec {
            registers: vec![
                RegisterSpec {
                    name: "V",
                    width_bits: 8,
                    slots: 16,
                },
                RegisterSpec {
                    name: "I",
                    width_bits: 16,
                    slots: 1,
                },
            ],
            memory_bytes: CHIP8_MEMORY_BYTES,
            program_counter: "pc",
        }
    }

    fn shout_tables(&self) -> Vec<ShoutTableSpec> {
        vec![ShoutTableSpec {
            name: "program",
            slots: CHIP8_MEMORY_BYTES,
            width_bits: 8,
        }]
    }

    fn twist_tables(&self) -> Vec<TwistTableSpec> {
        vec![
            TwistTableSpec {
                name: "registers",
                slots: 17,
                width_bits: 16,
            },
            TwistTableSpec {
                name: "ram",
                slots: CHIP8_MEMORY_BYTES,
                width_bits: 8,
            },
        ]
    }

    fn opcode_classes(&self) -> Vec<OpcodeClassSpec<Self::OpcodeId>> {
        Chip8Opcode::all()
            .into_iter()
            .map(|id| OpcodeClassSpec {
                id,
                name: opcode_name(id),
                selector_index: selector_index(id),
                writes_vx: matches!(
                    id,
                    Chip8Opcode::LdImm
                        | Chip8Opcode::AddImm
                        | Chip8Opcode::Mov
                        | Chip8Opcode::AddReg
                        | Chip8Opcode::LoadRegs
                ),
                writes_i: matches!(id, Chip8Opcode::LdI),
                touches_ram: matches!(id, Chip8Opcode::StoreRegs | Chip8Opcode::LoadRegs),
            })
            .collect()
    }

    fn decode_spec(&self) -> DecodeSpec<Self::OpcodeId> {
        DecodeSpec {
            opcode_bits: 16,
            fields: vec![
                DecodeField {
                    name: "x",
                    width_bits: 4,
                },
                DecodeField {
                    name: "y",
                    width_bits: 4,
                },
                DecodeField {
                    name: "kk",
                    width_bits: 8,
                },
                DecodeField {
                    name: "nnn",
                    width_bits: 12,
                },
            ],
            supported: Chip8Opcode::all().into_iter().collect(),
        }
    }

    fn core_ccs_spec(&self) -> &CoreCcsSpec {
        &self.core
    }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

fn opcode_name(id: Chip8Opcode) -> &'static str {
    match id {
        Chip8Opcode::LdImm => "ld_imm",
        Chip8Opcode::AddImm => "add_imm",
        Chip8Opcode::Mov => "mov",
        Chip8Opcode::AddReg => "add_reg",
        Chip8Opcode::SkipEqImm => "skip_eq_imm",
        Chip8Opcode::Jump => "jump",
        Chip8Opcode::LdI => "ld_i",
        Chip8Opcode::StoreRegs => "store_regs",
        Chip8Opcode::LoadRegs => "load_regs",
    }
}

fn selector_index(id: Chip8Opcode) -> usize {
    match id {
        Chip8Opcode::LdImm => 0,
        Chip8Opcode::AddImm => 1,
        Chip8Opcode::Mov => 2,
        Chip8Opcode::AddReg => 3,
        Chip8Opcode::SkipEqImm => 4,
        Chip8Opcode::Jump => 5,
        Chip8Opcode::LdI => 6,
        Chip8Opcode::StoreRegs => 7,
        Chip8Opcode::LoadRegs => 8,
    }
}

// ---------------------------------------------------------------------------
// 19 R1CS rows (§4.1 / §11.3)
// ---------------------------------------------------------------------------

fn build_core_ccs_spec() -> Result<CoreCcsSpec, String> {
    let mut b = R1csBuilder::new(WITNESS_WIDTH, COL_ONE)?;

    // Rows 0-7: Booleanity for the 8 boolean columns.
    for &col in &BOOLEAN_COLS {
        b.push_boolean(col);
    }

    // Row 8: X-lane partition — WritesLookupToX + WritesMemToX + PreservesX = 1.
    b.push_linear_zero(
        [
            (COL_WRITES_LOOKUP_TO_X, F::ONE),
            (COL_WRITES_MEM_TO_X, F::ONE),
            (COL_PRESERVES_X, F::ONE),
            (COL_ONE, -F::ONE),
        ]
        .into_iter(),
    );

    // Row 9: WritesLookupToX · (REG_X_NEXT - LOOKUP_OUTPUT) = 0
    b.push_row(
        [(COL_WRITES_LOOKUP_TO_X, F::ONE)],
        [(COL_REG_X_NEXT, F::ONE), (COL_LOOKUP_OUTPUT, -F::ONE)],
        [],
    );

    // Row 10: WritesMemToX · (REG_X_NEXT - MEM_VALUE) = 0
    b.push_row(
        [(COL_WRITES_MEM_TO_X, F::ONE)],
        [(COL_REG_X_NEXT, F::ONE), (COL_MEM_VALUE, -F::ONE)],
        [],
    );

    // Row 11: PreservesX · (REG_X_NEXT - REG_X) = 0
    b.push_row(
        [(COL_PRESERVES_X, F::ONE)],
        [(COL_REG_X_NEXT, F::ONE), (COL_REG_X, -F::ONE)],
        [],
    );

    // Row 12: WritesNnnToI · (NNN_ADDR - I_REG) = I_NEXT - I_REG
    b.push_row(
        [(COL_WRITES_NNN_TO_I, F::ONE)],
        [(COL_NNN_ADDR, F::ONE), (COL_I_REG, -F::ONE)],
        [(COL_I_NEXT, F::ONE), (COL_I_REG, -F::ONE)],
    );

    // Row 13: IsJump · (PC_NEXT - NNN_WORD) = 0
    b.push_row(
        [(COL_IS_JUMP, F::ONE)],
        [(COL_PC_NEXT, F::ONE), (COL_NNN_WORD, -F::ONE)],
        [],
    );

    // Row 14: IsBranch · (PC_NEXT - PC - ONE - LOOKUP_OUTPUT) = 0
    b.push_row(
        [(COL_IS_BRANCH, F::ONE)],
        [
            (COL_PC_NEXT, F::ONE),
            (COL_PC, -F::ONE),
            (COL_ONE, -F::ONE),
            (COL_LOOKUP_OUTPUT, -F::ONE),
        ],
        [],
    );

    // Row 15: IsMemOp · (PC_NEXT - PC - BURST_LAST) = 0
    b.push_row(
        [(COL_IS_MEMOP, F::ONE)],
        [(COL_PC_NEXT, F::ONE), (COL_PC, -F::ONE), (COL_BURST_LAST, -F::ONE)],
        [],
    );

    // Row 16: (ONE - IsJump - IsBranch - IsMemOp) · (PC_NEXT - PC - ONE) = 0
    b.push_row(
        [
            (COL_ONE, F::ONE),
            (COL_IS_JUMP, -F::ONE),
            (COL_IS_BRANCH, -F::ONE),
            (COL_IS_MEMOP, -F::ONE),
        ],
        [(COL_PC_NEXT, F::ONE), (COL_PC, -F::ONE), (COL_ONE, -F::ONE)],
        [],
    );

    // Row 17: IsMemOp · (RAM_ADDR - I_REG - X_IDX) = 0
    b.push_row(
        [(COL_IS_MEMOP, F::ONE)],
        [(COL_RAM_ADDR, F::ONE), (COL_I_REG, -F::ONE), (COL_X_IDX, -F::ONE)],
        [],
    );

    // Row 18: (ONE - IsMemOp) · RAM_ADDR = 0
    b.push_row(
        [(COL_ONE, F::ONE), (COL_IS_MEMOP, -F::ONE)],
        [(COL_RAM_ADDR, F::ONE)],
        [],
    );

    Ok(CoreCcsSpec {
        structure: b.build()?,
        m_in: PUBLIC_INPUTS,
        witness_width: WITNESS_WIDTH,
        const_one_col: COL_ONE,
    })
}
