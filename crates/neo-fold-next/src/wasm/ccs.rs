//! Owns the WASM VM contract and phase-1 core CCS.

use neo_math::F;
use p3_field::PrimeCharacteristicRing;

use crate::vm::decode::DecodeSpec;
use crate::vm::opcode_classes::OpcodeClassSpec;
use crate::vm::r1cs_builder::R1csBuilder;
use crate::vm::state::{RegisterSpec, StateSpec};
use crate::vm::{CoreCcsSpec, ShoutTableSpec, TwistTableSpec, VmSpec};

use super::isa::{opcode_code, opcode_info_from_code, WasmOpcode, WasmOpcodeClass, WasmShoutOpcode};
use super::layout::{
    selector_col, BOOLEAN_COLS, COL_AUX0, COL_AUX1, COL_HALTED, COL_LOCAL_VALUE, COL_ONE, COL_OPCODE_CODE,
    COL_READ0_ADDR, COL_READ0_VALUE, COL_READ1_ADDR, COL_READ1_VALUE, COL_READ2_ADDR, COL_READ2_VALUE, COL_SEL_RETURN,
    COL_SHOUT_ENABLED, COL_SHOUT_ID, COL_SHOUT_VALUE, COL_SP_AFTER, COL_SP_BEFORE, COL_STACK_READS, COL_STACK_WRITES,
    COL_WRITE1_ADDR, COL_WRITE1_VALUE, SELECTOR_COLS, WITNESS_WIDTH,
};

#[derive(Clone, Debug)]
pub struct WasmVmSpec {
    core: CoreCcsSpec,
}

impl Default for WasmVmSpec {
    fn default() -> Self {
        Self::new().expect("valid WASM core CCS")
    }
}

impl WasmVmSpec {
    pub fn new() -> Result<Self, String> {
        Ok(Self {
            core: build_core_ccs_spec()?,
        })
    }
}

impl VmSpec for WasmVmSpec {
    type OpcodeId = WasmOpcode;

    fn name(&self) -> &'static str {
        "wasm"
    }

    fn state_spec(&self) -> StateSpec {
        StateSpec {
            registers: vec![RegisterSpec {
                name: "sp",
                width_bits: 64,
                slots: 1,
            }],
            memory_bytes: 0,
            program_counter: "pc",
        }
    }

    fn shout_tables(&self) -> Vec<ShoutTableSpec> {
        WasmShoutOpcode::all()
            .into_iter()
            .map(|op| ShoutTableSpec {
                name: op.name(),
                slots: 1 << 16,
                width_bits: 32,
            })
            .collect()
    }

    fn twist_tables(&self) -> Vec<TwistTableSpec> {
        vec![TwistTableSpec {
            name: "stack",
            slots: 1 << 16,
            width_bits: 32,
        }]
    }

    fn opcode_classes(&self) -> Vec<OpcodeClassSpec<Self::OpcodeId>> {
        WasmOpcode::supported()
            .into_iter()
            .map(|id| {
                let info = opcode_info_from_code(code_for(id));
                OpcodeClassSpec {
                    id,
                    name: info.name,
                    selector_index: id.selector_index().expect("supported opcode selector"),
                    writes_vx: false,
                    writes_i: false,
                    touches_ram: false,
                }
            })
            .collect()
    }

    fn decode_spec(&self) -> DecodeSpec<Self::OpcodeId> {
        DecodeSpec {
            opcode_bits: 16,
            fields: Vec::new(),
            supported: WasmOpcode::supported().into_iter().collect(),
        }
    }

    fn core_ccs_spec(&self) -> &CoreCcsSpec {
        &self.core
    }
}

fn build_core_ccs_spec() -> Result<CoreCcsSpec, String> {
    let mut b = R1csBuilder::new(WITNESS_WIDTH, COL_ONE)?;

    for &col in &BOOLEAN_COLS {
        b.push_boolean(col);
    }

    b.push_linear_zero(
        SELECTOR_COLS
            .into_iter()
            .map(|col| (col, F::ONE))
            .chain([(COL_ONE, -F::ONE)]),
    );

    b.push_linear_zero(
        [
            (COL_OPCODE_CODE, F::ONE),
            (
                selector_col(WasmOpcode::I32Const).unwrap(),
                -f_u16(opcode_code(WasmOpcode::I32Const)),
            ),
            (
                selector_col(WasmOpcode::I32Add).unwrap(),
                -f_u16(opcode_code(WasmOpcode::I32Add)),
            ),
            (
                selector_col(WasmOpcode::I32Sub).unwrap(),
                -f_u16(opcode_code(WasmOpcode::I32Sub)),
            ),
            (
                selector_col(WasmOpcode::I32Popcnt).unwrap(),
                -f_u16(opcode_code(WasmOpcode::I32Popcnt)),
            ),
            (
                selector_col(WasmOpcode::I32Eqz).unwrap(),
                -f_u16(opcode_code(WasmOpcode::I32Eqz)),
            ),
            (
                selector_col(WasmOpcode::I32Eq).unwrap(),
                -f_u16(opcode_code(WasmOpcode::I32Eq)),
            ),
            (
                selector_col(WasmOpcode::I32Ne).unwrap(),
                -f_u16(opcode_code(WasmOpcode::I32Ne)),
            ),
            (
                selector_col(WasmOpcode::I32LtS).unwrap(),
                -f_u16(opcode_code(WasmOpcode::I32LtS)),
            ),
            (
                selector_col(WasmOpcode::I32LtU).unwrap(),
                -f_u16(opcode_code(WasmOpcode::I32LtU)),
            ),
            (
                selector_col(WasmOpcode::I32And).unwrap(),
                -f_u16(opcode_code(WasmOpcode::I32And)),
            ),
            (
                selector_col(WasmOpcode::I32Or).unwrap(),
                -f_u16(opcode_code(WasmOpcode::I32Or)),
            ),
            (
                selector_col(WasmOpcode::I32Xor).unwrap(),
                -f_u16(opcode_code(WasmOpcode::I32Xor)),
            ),
            (
                selector_col(WasmOpcode::I32Mul).unwrap(),
                -f_u16(opcode_code(WasmOpcode::I32Mul)),
            ),
            (
                selector_col(WasmOpcode::Select).unwrap(),
                -f_u16(opcode_code(WasmOpcode::Select)),
            ),
            (
                selector_col(WasmOpcode::BrIfEqz).unwrap(),
                -f_u16(opcode_code(WasmOpcode::BrIfEqz)),
            ),
            (
                selector_col(WasmOpcode::Return).unwrap(),
                -f_u16(opcode_code(WasmOpcode::Return)),
            ),
            (
                selector_col(WasmOpcode::LocalGet).unwrap(),
                -f_u16(opcode_code(WasmOpcode::LocalGet)),
            ),
            (
                selector_col(WasmOpcode::LocalSet).unwrap(),
                -f_u16(opcode_code(WasmOpcode::LocalSet)),
            ),
            (
                selector_col(WasmOpcode::LocalTee).unwrap(),
                -f_u16(opcode_code(WasmOpcode::LocalTee)),
            ),
        ]
        .into_iter(),
    );

    // sp after + stack reads = sp before + stack writes
    b.push_linear_zero([
        (COL_SP_AFTER, F::ONE),
        (COL_SP_BEFORE, -F::ONE),
        (COL_STACK_READS, F::ONE),
        (COL_STACK_WRITES, -F::ONE),
    ]);

    b.push_linear_zero([(COL_HALTED, F::ONE), (COL_SEL_RETURN, -F::ONE)].into_iter());

    b.push_linear_zero(
        [
            (COL_SHOUT_ENABLED, F::ONE),
            (selector_for_lookup(WasmOpcode::I32Eqz), -F::ONE),
            (selector_for_lookup(WasmOpcode::I32Eq), -F::ONE),
            (selector_for_lookup(WasmOpcode::I32Ne), -F::ONE),
            (selector_for_lookup(WasmOpcode::I32LtS), -F::ONE),
            (selector_for_lookup(WasmOpcode::I32LtU), -F::ONE),
            (selector_for_lookup(WasmOpcode::I32And), -F::ONE),
            (selector_for_lookup(WasmOpcode::I32Or), -F::ONE),
            (selector_for_lookup(WasmOpcode::I32Xor), -F::ONE),
            (selector_for_lookup(WasmOpcode::I32Mul), -F::ONE),
        ]
        .into_iter(),
    );

    push_gated_linear_zero(
        &mut b,
        selector_col(WasmOpcode::I32Const).unwrap(),
        [(COL_WRITE1_ADDR, F::ONE), (COL_SP_BEFORE, -F::ONE)],
    );

    for op in [WasmOpcode::I32Popcnt, WasmOpcode::I32Eqz, WasmOpcode::BrIfEqz] {
        let sel = selector_col(op).unwrap();
        push_gated_linear_zero(
            &mut b,
            sel,
            [(COL_READ0_ADDR, F::ONE), (COL_SP_BEFORE, -F::ONE), (COL_ONE, F::ONE)],
        );
    }

    for op in [WasmOpcode::I32Popcnt, WasmOpcode::I32Eqz] {
        let sel = selector_col(op).unwrap();
        push_gated_linear_zero(
            &mut b,
            sel,
            [(COL_WRITE1_ADDR, F::ONE), (COL_SP_BEFORE, -F::ONE), (COL_ONE, F::ONE)],
        );
    }

    for op in [
        WasmOpcode::I32Add,
        WasmOpcode::I32Sub,
        WasmOpcode::I32Eq,
        WasmOpcode::I32Ne,
        WasmOpcode::I32LtS,
        WasmOpcode::I32LtU,
        WasmOpcode::I32And,
        WasmOpcode::I32Or,
        WasmOpcode::I32Xor,
        WasmOpcode::I32Mul,
    ] {
        let sel = selector_col(op).unwrap();
        push_gated_linear_zero(
            &mut b,
            sel,
            [(COL_READ0_ADDR, F::ONE), (COL_SP_BEFORE, -F::ONE), (COL_ONE, f_u64(2))],
        );
        push_gated_linear_zero(
            &mut b,
            sel,
            [(COL_READ1_ADDR, F::ONE), (COL_SP_BEFORE, -F::ONE), (COL_ONE, F::ONE)],
        );
        push_gated_linear_zero(
            &mut b,
            sel,
            [(COL_WRITE1_ADDR, F::ONE), (COL_SP_BEFORE, -F::ONE), (COL_ONE, f_u64(2))],
        );
    }

    let sel_select = selector_col(WasmOpcode::Select).unwrap();
    push_gated_linear_zero(
        &mut b,
        sel_select,
        [(COL_READ0_ADDR, F::ONE), (COL_SP_BEFORE, -F::ONE), (COL_ONE, f_u64(3))],
    );
    push_gated_linear_zero(
        &mut b,
        sel_select,
        [(COL_READ1_ADDR, F::ONE), (COL_SP_BEFORE, -F::ONE), (COL_ONE, f_u64(2))],
    );
    push_gated_linear_zero(
        &mut b,
        sel_select,
        [(COL_READ2_ADDR, F::ONE), (COL_SP_BEFORE, -F::ONE), (COL_ONE, F::ONE)],
    );
    push_gated_linear_zero(
        &mut b,
        sel_select,
        [(COL_WRITE1_ADDR, F::ONE), (COL_SP_BEFORE, -F::ONE), (COL_ONE, f_u64(3))],
    );

    // Stack address constraints for local opcodes.
    // local.get: no stack reads; write1 goes to sp_before (new top).
    push_gated_linear_zero(
        &mut b,
        selector_col(WasmOpcode::LocalGet).unwrap(),
        [(COL_WRITE1_ADDR, F::ONE), (COL_SP_BEFORE, -F::ONE)],
    );
    // local.set: reads top of stack (sp_before - 1); no stack write.
    push_gated_linear_zero(
        &mut b,
        selector_col(WasmOpcode::LocalSet).unwrap(),
        [(COL_READ0_ADDR, F::ONE), (COL_SP_BEFORE, -F::ONE), (COL_ONE, F::ONE)],
    );
    // local.tee: reads and writes back to the same top position (sp_before - 1).
    push_gated_linear_zero(
        &mut b,
        selector_col(WasmOpcode::LocalTee).unwrap(),
        [(COL_READ0_ADDR, F::ONE), (COL_SP_BEFORE, -F::ONE), (COL_ONE, F::ONE)],
    );
    push_gated_linear_zero(
        &mut b,
        selector_col(WasmOpcode::LocalTee).unwrap(),
        [(COL_WRITE1_ADDR, F::ONE), (COL_SP_BEFORE, -F::ONE), (COL_ONE, F::ONE)],
    );

    // Local value constraints (row-local only; cross-step consistency belongs in Stage 2).
    // local.get: the value pushed onto the stack equals the local's pre-step value.
    push_gated_linear_zero(
        &mut b,
        selector_col(WasmOpcode::LocalGet).unwrap(),
        [(COL_WRITE1_VALUE, F::ONE), (COL_LOCAL_VALUE, -F::ONE)],
    );
    // local.set: the value popped from the stack equals what is stored in the local.
    push_gated_linear_zero(
        &mut b,
        selector_col(WasmOpcode::LocalSet).unwrap(),
        [(COL_READ0_VALUE, F::ONE), (COL_LOCAL_VALUE, -F::ONE)],
    );
    // local.tee: the stack top value and the locally stored value are the same.
    push_gated_linear_zero(
        &mut b,
        selector_col(WasmOpcode::LocalTee).unwrap(),
        [(COL_READ0_VALUE, F::ONE), (COL_LOCAL_VALUE, -F::ONE)],
    );
    push_gated_linear_zero(
        &mut b,
        selector_col(WasmOpcode::LocalTee).unwrap(),
        [(COL_WRITE1_VALUE, F::ONE), (COL_LOCAL_VALUE, -F::ONE)],
    );

    push_gated_linear_zero(
        &mut b,
        selector_col(WasmOpcode::I32Add).unwrap(),
        [
            (COL_READ0_VALUE, F::ONE),
            (COL_READ1_VALUE, F::ONE),
            (COL_WRITE1_VALUE, -F::ONE),
        ],
    );
    push_gated_linear_zero(
        &mut b,
        selector_col(WasmOpcode::I32Sub).unwrap(),
        [
            (COL_READ0_VALUE, F::ONE),
            (COL_READ1_VALUE, -F::ONE),
            (COL_WRITE1_VALUE, -F::ONE),
        ],
    );
    push_gated_linear_zero(
        &mut b,
        sel_select,
        [
            (COL_WRITE1_VALUE, F::ONE),
            (COL_READ1_VALUE, -F::ONE),
            (COL_AUX0, -F::ONE),
        ],
    );
    push_gated_linear_zero(
        &mut b,
        sel_select,
        [
            (COL_READ0_VALUE, F::ONE),
            (COL_READ1_VALUE, -F::ONE),
            (COL_AUX1, -F::ONE),
        ],
    );
    b.push_row(
        [(COL_READ2_VALUE, F::ONE)],
        [(COL_READ2_VALUE, F::ONE), (COL_ONE, -F::ONE)],
        [],
    );
    b.push_row([(COL_READ2_VALUE, F::ONE)], [(COL_AUX1, F::ONE)], [(COL_AUX0, F::ONE)]);

    for (op, shout) in [
        (WasmOpcode::I32Eqz, WasmShoutOpcode::I32Eqz),
        (WasmOpcode::I32Eq, WasmShoutOpcode::I32Eq),
        (WasmOpcode::I32Ne, WasmShoutOpcode::I32Ne),
        (WasmOpcode::I32LtS, WasmShoutOpcode::I32LtS),
        (WasmOpcode::I32LtU, WasmShoutOpcode::I32LtU),
        (WasmOpcode::I32And, WasmShoutOpcode::I32And),
        (WasmOpcode::I32Or, WasmShoutOpcode::I32Or),
        (WasmOpcode::I32Xor, WasmShoutOpcode::I32Xor),
        (WasmOpcode::I32Mul, WasmShoutOpcode::I32Mul),
    ] {
        let sel = selector_col(op).unwrap();
        push_gated_linear_zero(
            &mut b,
            sel,
            [(COL_SHOUT_ID, F::ONE), (COL_ONE, -f_u32(shout.to_shout_id()))],
        );
        push_gated_linear_zero(&mut b, sel, [(COL_SHOUT_VALUE, F::ONE), (COL_WRITE1_VALUE, -F::ONE)]);
    }

    let structure = b.build()?;
    Ok(CoreCcsSpec {
        structure,
        m_in: 1,
        witness_width: WITNESS_WIDTH,
        const_one_col: COL_ONE,
    })
}

fn push_gated_linear_zero<const N: usize>(b: &mut R1csBuilder, selector: usize, terms: [(usize, F); N]) {
    b.push_row([(selector, F::ONE)], terms, []);
}

fn f_u16(v: u16) -> F {
    F::from_u64(u64::from(v))
}

fn f_u32(v: u32) -> F {
    F::from_u64(u64::from(v))
}

fn f_u64(v: u64) -> F {
    F::from_u64(v)
}

fn selector_for_lookup(op: WasmOpcode) -> usize {
    selector_col(op).expect("lookup opcode selector column")
}

fn code_for(op: WasmOpcode) -> u16 {
    opcode_code(op)
}

#[allow(dead_code)]
fn _class_name(class: WasmOpcodeClass) -> &'static str {
    match class {
        WasmOpcodeClass::System => "system",
        WasmOpcodeClass::ControlFlow => "control_flow",
        WasmOpcodeClass::Numeric => "numeric",
        WasmOpcodeClass::Compare => "compare",
        WasmOpcodeClass::Unknown => "unknown",
    }
}
