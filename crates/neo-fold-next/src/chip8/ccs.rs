//! Owns the CHIP-8 VM contract and 24-column main-lane CCS.

use neo_math::F;
use p3_field::PrimeCharacteristicRing;

use crate::vm::decode::{DecodeField, DecodeSpec};
use crate::vm::opcode_classes::OpcodeClassSpec;
use crate::vm::r1cs_builder::R1csBuilder;
use crate::vm::state::{RegisterSpec, StateSpec};
use crate::vm::{CoreCcsSpec, ShoutTableSpec, TwistTableSpec, VmSpec};

use super::isa::Chip8Opcode;
use super::layout::{
    BOOLEAN_COLS, CHIP8_MEMORY_BYTES, COL_BURST_LAST, COL_IS_BRANCH, COL_IS_JUMP, COL_IS_MEMOP, COL_I_NEXT, COL_I_REG,
    COL_LOOKUP_OUTPUT, COL_MEM_VALUE, COL_NNN_ADDR, COL_NNN_WORD, COL_ONE, COL_PC, COL_PC_NEXT, COL_PRESERVES_X,
    COL_RAM_ADDR, COL_REG_X, COL_REG_X_NEXT, COL_WRITES_LOOKUP_TO_X, COL_WRITES_MEM_TO_X, COL_WRITES_NNN_TO_I,
    COL_X_IDX, PUBLIC_INPUTS, WITNESS_WIDTH,
};

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
    RootProver(u64),
}

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

fn build_core_ccs_spec() -> Result<CoreCcsSpec, String> {
    let mut b = R1csBuilder::new(WITNESS_WIDTH, COL_ONE)?;

    for &col in &BOOLEAN_COLS {
        b.push_boolean(col);
    }

    b.push_linear_zero(
        [
            (COL_WRITES_LOOKUP_TO_X, F::ONE),
            (COL_WRITES_MEM_TO_X, F::ONE),
            (COL_PRESERVES_X, F::ONE),
            (COL_ONE, -F::ONE),
        ]
        .into_iter(),
    );

    b.push_row(
        [(COL_WRITES_LOOKUP_TO_X, F::ONE)],
        [(COL_REG_X_NEXT, F::ONE), (COL_LOOKUP_OUTPUT, -F::ONE)],
        [],
    );
    b.push_row(
        [(COL_WRITES_MEM_TO_X, F::ONE)],
        [(COL_REG_X_NEXT, F::ONE), (COL_MEM_VALUE, -F::ONE)],
        [],
    );
    b.push_row(
        [(COL_PRESERVES_X, F::ONE)],
        [(COL_REG_X_NEXT, F::ONE), (COL_REG_X, -F::ONE)],
        [],
    );
    b.push_row(
        [(COL_WRITES_NNN_TO_I, F::ONE)],
        [(COL_NNN_ADDR, F::ONE), (COL_I_REG, -F::ONE)],
        [(COL_I_NEXT, F::ONE), (COL_I_REG, -F::ONE)],
    );
    b.push_row(
        [(COL_IS_JUMP, F::ONE)],
        [(COL_PC_NEXT, F::ONE), (COL_NNN_WORD, -F::ONE)],
        [],
    );
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
    b.push_row(
        [(COL_IS_MEMOP, F::ONE)],
        [(COL_PC_NEXT, F::ONE), (COL_PC, -F::ONE), (COL_BURST_LAST, -F::ONE)],
        [],
    );
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
    b.push_row(
        [(COL_IS_MEMOP, F::ONE)],
        [(COL_RAM_ADDR, F::ONE), (COL_I_REG, -F::ONE), (COL_X_IDX, -F::ONE)],
        [],
    );
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
