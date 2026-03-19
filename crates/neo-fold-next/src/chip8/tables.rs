//! Lookup table construction for the CHIP-8 3-stage kernel.
//!
//! Owns: ROM table, full-opcode decode table, Add8Lo subtable, Eq4 table,
//! register unmap, RAM unmap. Does not own the committed polynomials themselves.

use neo_math::F;
use p3_field::PrimeCharacteristicRing;

use super::spec::{decode_opcode, Chip8Opcode, Chip8Program};

// ---------------------------------------------------------------------------
// Domain constants (§1.2)
// ---------------------------------------------------------------------------

pub const ADDR_REG_BITS: usize = 5; // 32-point register-address hypercube
pub const ADDR_RAM_BITS: usize = 13; // 8192-point RAM-address hypercube
pub const ROM_ADDR_BITS: usize = 11; // 2048 CHIP-8 word addresses
pub const REG_SINK_ADDR: usize = 17; // ⊥_reg
pub const RAM_SINK_ADDR: usize = 4096; // ⊥_ram

// ---------------------------------------------------------------------------
// LookupKind / OperandSelector / DecodeOutput (§5.2, §5.3)
// ---------------------------------------------------------------------------

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
#[repr(u8)]
pub enum LookupKind {
    NoLookup = 0,
    Identity = 1,
    Equal8 = 2,
    Add8Lo = 3,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
#[repr(u8)]
pub enum OperandSelector {
    RegX = 0,
    RegY = 1,
    Kk = 2,
    Zero = 3,
}

/// Full 22-field decode output per §5.2 / §13.10.
#[derive(Clone, Copy, Debug)]
pub struct DecodeOutput {
    pub valid: bool,
    pub x_dec: u8,
    pub y_dec: u8,
    pub kk_dec: u8,
    pub nnn_addr_dec: u16,
    pub nnn_word_dec: u16,
    pub writes_lookup_to_x: bool,
    pub writes_mem_to_x: bool,
    pub preserves_x: bool,
    pub writes_nnn_to_i: bool,
    pub is_jump: bool,
    pub is_branch: bool,
    pub is_memop: bool,
    pub is_store: bool,
    pub is_load: bool,
    pub reads_ram: bool,
    pub writes_ram: bool,
    pub uses_y: bool,
    pub lookup_kind: LookupKind,
    pub lhs_selector: OperandSelector,
    pub rhs_selector: OperandSelector,
    pub x_bound: u8,
}

impl Default for DecodeOutput {
    fn default() -> Self {
        Self {
            valid: false,
            x_dec: 0,
            y_dec: 0,
            kk_dec: 0,
            nnn_addr_dec: 0,
            nnn_word_dec: 0,
            writes_lookup_to_x: false,
            writes_mem_to_x: false,
            preserves_x: false,
            writes_nnn_to_i: false,
            is_jump: false,
            is_branch: false,
            is_memop: false,
            is_store: false,
            is_load: false,
            reads_ram: false,
            writes_ram: false,
            uses_y: false,
            lookup_kind: LookupKind::NoLookup,
            lhs_selector: OperandSelector::Zero,
            rhs_selector: OperandSelector::Zero,
            x_bound: 0,
        }
    }
}

/// Decode a 16-bit opcode into the full 22-field output. Unsupported opcodes
/// return `valid = false` with all fields zeroed.
pub fn decode_to_output(opcode: u16) -> DecodeOutput {
    let step = match decode_opcode(opcode) {
        Ok(s) => s,
        Err(_) => return DecodeOutput::default(),
    };
    let x = step.x;
    let y = step.y;
    let kk = step.kk;
    let nnn = step.nnn;
    let nnn_word = nnn / 2;
    match step.opcode_id {
        Chip8Opcode::LdImm => DecodeOutput {
            valid: true,
            x_dec: x,
            kk_dec: kk,
            writes_lookup_to_x: true,
            lookup_kind: LookupKind::Identity,
            lhs_selector: OperandSelector::Kk,
            rhs_selector: OperandSelector::Zero,
            ..DecodeOutput::default()
        },
        Chip8Opcode::AddImm => DecodeOutput {
            valid: true,
            x_dec: x,
            kk_dec: kk,
            writes_lookup_to_x: true,
            lookup_kind: LookupKind::Add8Lo,
            lhs_selector: OperandSelector::RegX,
            rhs_selector: OperandSelector::Kk,
            ..DecodeOutput::default()
        },
        Chip8Opcode::Mov => DecodeOutput {
            valid: true,
            x_dec: x,
            y_dec: y,
            writes_lookup_to_x: true,
            uses_y: true,
            lookup_kind: LookupKind::Identity,
            lhs_selector: OperandSelector::RegY,
            rhs_selector: OperandSelector::Zero,
            ..DecodeOutput::default()
        },
        Chip8Opcode::AddReg => DecodeOutput {
            valid: true,
            x_dec: x,
            y_dec: y,
            writes_lookup_to_x: true,
            uses_y: true,
            lookup_kind: LookupKind::Add8Lo,
            lhs_selector: OperandSelector::RegX,
            rhs_selector: OperandSelector::RegY,
            ..DecodeOutput::default()
        },
        Chip8Opcode::SkipEqImm => DecodeOutput {
            valid: true,
            x_dec: x,
            kk_dec: kk,
            preserves_x: true,
            is_branch: true,
            lookup_kind: LookupKind::Equal8,
            lhs_selector: OperandSelector::RegX,
            rhs_selector: OperandSelector::Kk,
            ..DecodeOutput::default()
        },
        Chip8Opcode::Jump => DecodeOutput {
            valid: true,
            nnn_addr_dec: nnn,
            nnn_word_dec: nnn_word,
            preserves_x: true,
            is_jump: true,
            ..DecodeOutput::default()
        },
        Chip8Opcode::LdI => DecodeOutput {
            valid: true,
            nnn_addr_dec: nnn,
            preserves_x: true,
            writes_nnn_to_i: true,
            ..DecodeOutput::default()
        },
        Chip8Opcode::StoreRegs => DecodeOutput {
            valid: true,
            x_dec: x,
            preserves_x: true,
            is_memop: true,
            is_store: true,
            writes_ram: true,
            x_bound: x,
            ..DecodeOutput::default()
        },
        Chip8Opcode::LoadRegs => DecodeOutput {
            valid: true,
            x_dec: x,
            writes_mem_to_x: true,
            is_memop: true,
            is_load: true,
            reads_ram: true,
            x_bound: x,
            ..DecodeOutput::default()
        },
    }
}

pub const DECODE_TABLE_COLUMNS: usize = 22;

// ---- Helper: DecodeOutput -> field array -----------------------------------

fn decode_output_to_fields(out: &DecodeOutput) -> [F; DECODE_TABLE_COLUMNS] {
    let b = |v: bool| -> F {
        if v {
            F::ONE
        } else {
            F::ZERO
        }
    };
    [
        b(out.valid),
        F::from_u64(out.x_dec as u64),
        F::from_u64(out.y_dec as u64),
        F::from_u64(out.kk_dec as u64),
        F::from_u64(out.nnn_addr_dec as u64),
        F::from_u64(out.nnn_word_dec as u64),
        b(out.writes_lookup_to_x),
        b(out.writes_mem_to_x),
        b(out.preserves_x),
        b(out.writes_nnn_to_i),
        b(out.is_jump),
        b(out.is_branch),
        b(out.is_memop),
        b(out.is_store),
        b(out.is_load),
        b(out.reads_ram),
        b(out.writes_ram),
        b(out.uses_y),
        F::from_u64(out.lookup_kind as u8 as u64),
        F::from_u64(out.lhs_selector as u8 as u64),
        F::from_u64(out.rhs_selector as u8 as u64),
        F::from_u64(out.x_bound as u64),
    ]
}

// ---- 1. ROM table (§1.2, §13.9) -------------------------------------------

/// Build the absolute 2048-word ROM table.
///
/// Indexed by absolute CHIP-8 word addresses 0..2047.
/// The program is loaded at `program.start_pc / 2`.
/// `pad_pc_word` stores the self-loop opcode `Jump(2 * pad_pc_word)`.
/// All other entries are zero.
pub fn build_rom_table(program: &Chip8Program, pad_pc_word: u16) -> Vec<F> {
    let rom_size = 1 << ROM_ADDR_BITS; // 2048
    let mut table = vec![F::ZERO; rom_size];

    let base_word = (program.start_pc / 2) as usize;
    let word_count = program.bytes.len() / 2;

    for i in 0..word_count {
        let byte_offset = i * 2;
        let hi = program.bytes[byte_offset] as u64;
        let lo = program.bytes[byte_offset + 1] as u64;
        let opcode = (hi << 8) | lo;
        table[base_word + i] = F::from_u64(opcode);
    }

    // Self-loop padding opcode: Jump(2 * pad_pc_word) = 0x1000 | (2 * pad_pc_word).
    let pad_opcode = 0x1000u64 | ((pad_pc_word as u64) * 2);
    table[pad_pc_word as usize] = F::from_u64(pad_opcode);

    table
}

// ---- 2. Decode table (§5.2, §13.10) ----------------------------------------

/// Build the full 65536-entry decode table with 22 output columns.
///
/// Returns 22 vectors, each of length 65536. Column order matches §13.10:
/// valid, x_dec, y_dec, kk_dec, nnn_addr_dec, nnn_word_dec,
/// writes_lookup_to_x, writes_mem_to_x, preserves_x, writes_nnn_to_i,
/// is_jump, is_branch, is_memop, is_store, is_load, reads_ram, writes_ram,
/// uses_y, lookup_kind, lhs_selector, rhs_selector, x_bound.
pub fn build_decode_table() -> Vec<Vec<F>> {
    let n = 1usize << 16;
    let mut cols = vec![vec![F::ZERO; n]; DECODE_TABLE_COLUMNS];

    for opcode in 0u32..=0xFFFF {
        let out = decode_to_output(opcode as u16);
        let fields = decode_output_to_fields(&out);
        let idx = opcode as usize;
        for (col, &val) in cols.iter_mut().zip(fields.iter()) {
            col[idx] = val;
        }
    }

    cols
}

// ---- 3. ALU table (§13.11) -------------------------------------------------

/// Build the 256x256 Add8Lo subtable.
///
/// `Add8Lo(a, b) = (a + b) mod 256`.
/// Returns a flat vector of length 65536 indexed as `a * 256 + b`.
pub fn build_alu_table() -> Vec<F> {
    let size = 1usize << 16;
    let mut table = vec![F::ZERO; size];
    for a in 0u64..256 {
        for b in 0u64..256 {
            table[(a * 256 + b) as usize] = F::from_u64((a + b) % 256);
        }
    }
    table
}

// ---- 4. Eq4 table (§13.12) -------------------------------------------------

/// Build the 16x16 Eq4 table.
///
/// `Eq4(a, b) = if a == b then 1 else 0`.
/// Returns a flat vector of length 256 indexed as `a * 16 + b`.
pub fn build_eq4_table() -> Vec<F> {
    let size = 1usize << 8;
    let mut table = vec![F::ZERO; size];
    for a in 0u64..16 {
        for b in 0u64..16 {
            if a == b {
                table[(a * 16 + b) as usize] = F::ONE;
            }
        }
    }
    table
}

// ---- 5. Unmap polynomials (§6.5, §6.7) -------------------------------------

/// Build the 32-element register unmap polynomial.
///
/// `unmap[a] = a` for `0..=16` (V0..V15 and I).
/// Index 17 (sink) and 18..31 (padding) map to zero.
pub fn build_unmap_reg() -> Vec<F> {
    let size = 1 << ADDR_REG_BITS; // 32
    let mut v = vec![F::ZERO; size];
    for a in 0..=16u64 {
        v[a as usize] = F::from_u64(a);
    }
    v
}

/// Build the 8192-element RAM unmap polynomial.
///
/// `unmap[a] = a` for `0..4096`.
/// Index 4096 (sink) and 4097..8191 (padding) map to zero.
pub fn build_unmap_ram() -> Vec<F> {
    let size = 1 << ADDR_RAM_BITS; // 8192
    let mut v = vec![F::ZERO; size];
    for a in 0..4096u64 {
        v[a as usize] = F::from_u64(a);
    }
    v
}

// ---- 6. ALU key helpers ----------------------------------------------------

/// Flatten an ALU key into an 18-bit integer: `(kind << 16) | (lhs << 8) | rhs`.
#[inline]
pub fn flatten_alu_key(kind: LookupKind, lhs: u8, rhs: u8) -> u32 {
    ((kind as u32) << 16) | ((lhs as u32) << 8) | (rhs as u32)
}

/// Flatten an Eq4 key: `(x_idx << 4) | (x_bound & 0xF)`.
#[inline]
pub fn flatten_eq4_key(x_idx: u8, x_bound: u8) -> u8 {
    (x_idx << 4) | (x_bound & 0xF)
}
