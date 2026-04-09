//! Owns WASM opcode taxonomy and stable lookup ids.

use rwasm::{Opcode as ConcreteOpcode, TrapCode};

#[derive(Clone, Copy, Debug, Eq, PartialEq, Hash)]
pub enum WasmOpcodeClass {
    System,
    ControlFlow,
    Numeric,
    Compare,
    Unknown,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq, Hash)]
pub enum WasmShoutOpcode {
    I32Eqz,
    I32Eq,
    I32Ne,
    I32LtS,
    I32LtU,
    I32And,
    I32Or,
    I32Xor,
    I32Mul,
}

impl WasmShoutOpcode {
    pub fn all() -> [Self; 9] {
        [
            Self::I32Eqz,
            Self::I32Eq,
            Self::I32Ne,
            Self::I32LtS,
            Self::I32LtU,
            Self::I32And,
            Self::I32Or,
            Self::I32Xor,
            Self::I32Mul,
        ]
    }

    pub fn name(self) -> &'static str {
        match self {
            Self::I32Eqz => "i32_eqz",
            Self::I32Eq => "i32_eq",
            Self::I32Ne => "i32_ne",
            Self::I32LtS => "i32_lt_s",
            Self::I32LtU => "i32_lt_u",
            Self::I32And => "i32_and",
            Self::I32Or => "i32_or",
            Self::I32Xor => "i32_xor",
            Self::I32Mul => "i32_mul",
        }
    }

    pub fn to_shout_id(self) -> u32 {
        const BASE: u32 = 10_000;
        let offset = match self {
            Self::I32Eqz => 0,
            Self::I32Eq => 1,
            Self::I32Ne => 2,
            Self::I32LtS => 3,
            Self::I32LtU => 4,
            Self::I32And => 21,
            Self::I32Or => 22,
            Self::I32Xor => 23,
            Self::I32Mul => 16,
        };
        BASE + offset
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq, Hash, PartialOrd, Ord)]
pub enum WasmOpcode {
    I32Const,
    I32Add,
    I32Sub,
    I32Popcnt,
    I32Eqz,
    I32Eq,
    I32Ne,
    I32LtS,
    I32LtU,
    I32And,
    I32Or,
    I32Xor,
    I32Mul,
    Select,
    BrIfEqz,
    Return,
    Trap,
    Unsupported,
}

impl WasmOpcode {
    pub fn supported() -> [Self; 16] {
        [
            Self::I32Const,
            Self::I32Add,
            Self::I32Sub,
            Self::I32Popcnt,
            Self::I32Eqz,
            Self::I32Eq,
            Self::I32Ne,
            Self::I32LtS,
            Self::I32LtU,
            Self::I32And,
            Self::I32Or,
            Self::I32Xor,
            Self::I32Mul,
            Self::Select,
            Self::BrIfEqz,
            Self::Return,
        ]
    }

    pub fn selector_index(self) -> Option<usize> {
        match self {
            Self::I32Const => Some(0),
            Self::I32Add => Some(1),
            Self::I32Sub => Some(2),
            Self::I32Popcnt => Some(3),
            Self::I32Eqz => Some(4),
            Self::I32Eq => Some(5),
            Self::I32Ne => Some(6),
            Self::I32LtS => Some(7),
            Self::I32LtU => Some(8),
            Self::I32And => Some(9),
            Self::I32Or => Some(10),
            Self::I32Xor => Some(11),
            Self::I32Mul => Some(12),
            Self::Select => Some(13),
            Self::BrIfEqz => Some(14),
            Self::Return => Some(15),
            Self::Trap | Self::Unsupported => None,
        }
    }

    pub fn name(self) -> &'static str {
        match self {
            Self::I32Const => "i32_const",
            Self::I32Add => "i32_add",
            Self::I32Sub => "i32_sub",
            Self::I32Popcnt => "i32_popcnt",
            Self::I32Eqz => "i32_eqz",
            Self::I32Eq => "i32_eq",
            Self::I32Ne => "i32_ne",
            Self::I32LtS => "i32_lt_s",
            Self::I32LtU => "i32_lt_u",
            Self::I32And => "i32_and",
            Self::I32Or => "i32_or",
            Self::I32Xor => "i32_xor",
            Self::I32Mul => "i32_mul",
            Self::Select => "select",
            Self::BrIfEqz => "br_if_eqz",
            Self::Return => "return",
            Self::Trap => "trap",
            Self::Unsupported => "unsupported",
        }
    }

    pub fn from_concrete(op: ConcreteOpcode) -> Self {
        match op {
            ConcreteOpcode::I32Const(_) => Self::I32Const,
            ConcreteOpcode::I32Add => Self::I32Add,
            ConcreteOpcode::I32Sub => Self::I32Sub,
            ConcreteOpcode::I32Popcnt => Self::I32Popcnt,
            ConcreteOpcode::I32Eqz => Self::I32Eqz,
            ConcreteOpcode::I32Eq => Self::I32Eq,
            ConcreteOpcode::I32Ne => Self::I32Ne,
            ConcreteOpcode::I32LtS => Self::I32LtS,
            ConcreteOpcode::I32LtU => Self::I32LtU,
            ConcreteOpcode::I32And => Self::I32And,
            ConcreteOpcode::I32Or => Self::I32Or,
            ConcreteOpcode::I32Xor => Self::I32Xor,
            ConcreteOpcode::I32Mul => Self::I32Mul,
            ConcreteOpcode::Select => Self::Select,
            ConcreteOpcode::BrIfEqz(_) => Self::BrIfEqz,
            ConcreteOpcode::Return => Self::Return,
            ConcreteOpcode::Trap(_) => Self::Trap,
            _ => Self::Unsupported,
        }
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct WasmOpcodeInfo {
    pub opcode: WasmOpcode,
    pub code: u16,
    pub name: &'static str,
    pub class: WasmOpcodeClass,
    pub stack_reads: u8,
    pub stack_writes: u8,
    pub uses_shout: bool,
    pub shout_opcode: Option<WasmShoutOpcode>,
}

pub fn opcode_info_from_concrete(op: ConcreteOpcode) -> WasmOpcodeInfo {
    opcode_info_from_code(u16::try_from(op.code()).expect("wasm opcode code must fit u16"))
}

pub fn opcode_info_from_code(code: u16) -> WasmOpcodeInfo {
    use WasmOpcode as Op;
    use WasmOpcodeClass as Class;
    use WasmShoutOpcode as Shout;

    let op = WasmOpcode::from_concrete(code_to_concrete(code));
    match op {
        Op::I32Const => info(op, code, Class::Numeric, 0, 1, false, None),
        Op::I32Add => info(op, code, Class::Numeric, 2, 1, false, None),
        Op::I32Sub => info(op, code, Class::Numeric, 2, 1, false, None),
        Op::I32Popcnt => info(op, code, Class::Numeric, 1, 1, false, None),
        Op::I32Eqz => info(op, code, Class::Compare, 1, 1, true, Some(Shout::I32Eqz)),
        Op::I32Eq => info(op, code, Class::Compare, 2, 1, true, Some(Shout::I32Eq)),
        Op::I32Ne => info(op, code, Class::Compare, 2, 1, true, Some(Shout::I32Ne)),
        Op::I32LtS => info(op, code, Class::Compare, 2, 1, true, Some(Shout::I32LtS)),
        Op::I32LtU => info(op, code, Class::Compare, 2, 1, true, Some(Shout::I32LtU)),
        Op::I32And => info(op, code, Class::Numeric, 2, 1, true, Some(Shout::I32And)),
        Op::I32Or => info(op, code, Class::Numeric, 2, 1, true, Some(Shout::I32Or)),
        Op::I32Xor => info(op, code, Class::Numeric, 2, 1, true, Some(Shout::I32Xor)),
        Op::I32Mul => info(op, code, Class::Numeric, 2, 1, true, Some(Shout::I32Mul)),
        Op::Select => info(op, code, Class::ControlFlow, 3, 1, false, None),
        Op::BrIfEqz => info(op, code, Class::ControlFlow, 1, 0, false, None),
        Op::Return => info(op, code, Class::System, 0, 0, false, None),
        Op::Trap => info(op, code, Class::System, 0, 0, false, None),
        Op::Unsupported => info(op, code, Class::Unknown, 0, 0, false, None),
    }
}

pub fn opcode_code(op: WasmOpcode) -> u16 {
    match op {
        WasmOpcode::I32Const => concrete_code(ConcreteOpcode::I32Const(0u32.into())),
        WasmOpcode::I32Add => concrete_code(ConcreteOpcode::I32Add),
        WasmOpcode::I32Sub => concrete_code(ConcreteOpcode::I32Sub),
        WasmOpcode::I32Popcnt => concrete_code(ConcreteOpcode::I32Popcnt),
        WasmOpcode::I32Eqz => concrete_code(ConcreteOpcode::I32Eqz),
        WasmOpcode::I32Eq => concrete_code(ConcreteOpcode::I32Eq),
        WasmOpcode::I32Ne => concrete_code(ConcreteOpcode::I32Ne),
        WasmOpcode::I32LtS => concrete_code(ConcreteOpcode::I32LtS),
        WasmOpcode::I32LtU => concrete_code(ConcreteOpcode::I32LtU),
        WasmOpcode::I32And => concrete_code(ConcreteOpcode::I32And),
        WasmOpcode::I32Or => concrete_code(ConcreteOpcode::I32Or),
        WasmOpcode::I32Xor => concrete_code(ConcreteOpcode::I32Xor),
        WasmOpcode::I32Mul => concrete_code(ConcreteOpcode::I32Mul),
        WasmOpcode::Select => concrete_code(ConcreteOpcode::Select),
        WasmOpcode::BrIfEqz => concrete_code(ConcreteOpcode::BrIfEqz(0i32.into())),
        WasmOpcode::Return => concrete_code(ConcreteOpcode::Return),
        WasmOpcode::Trap => concrete_code(ConcreteOpcode::Trap(TrapCode::ExecutionHalted)),
        WasmOpcode::Unsupported => concrete_code(ConcreteOpcode::Trap(TrapCode::ExecutionHalted)),
    }
}

fn info(
    opcode: WasmOpcode,
    code: u16,
    class: WasmOpcodeClass,
    stack_reads: u8,
    stack_writes: u8,
    uses_shout: bool,
    shout_opcode: Option<WasmShoutOpcode>,
) -> WasmOpcodeInfo {
    WasmOpcodeInfo {
        opcode,
        code,
        name: opcode.name(),
        class,
        stack_reads,
        stack_writes,
        uses_shout,
        shout_opcode,
    }
}

fn code_to_concrete(code: u16) -> ConcreteOpcode {
    match code {
        x if x == opcode_code(WasmOpcode::I32Const) => ConcreteOpcode::I32Const(0u32.into()),
        x if x == opcode_code(WasmOpcode::I32Add) => ConcreteOpcode::I32Add,
        x if x == opcode_code(WasmOpcode::I32Sub) => ConcreteOpcode::I32Sub,
        x if x == opcode_code(WasmOpcode::I32Popcnt) => ConcreteOpcode::I32Popcnt,
        x if x == opcode_code(WasmOpcode::I32Eqz) => ConcreteOpcode::I32Eqz,
        x if x == opcode_code(WasmOpcode::I32Eq) => ConcreteOpcode::I32Eq,
        x if x == opcode_code(WasmOpcode::I32Ne) => ConcreteOpcode::I32Ne,
        x if x == opcode_code(WasmOpcode::I32LtS) => ConcreteOpcode::I32LtS,
        x if x == opcode_code(WasmOpcode::I32LtU) => ConcreteOpcode::I32LtU,
        x if x == opcode_code(WasmOpcode::I32And) => ConcreteOpcode::I32And,
        x if x == opcode_code(WasmOpcode::I32Or) => ConcreteOpcode::I32Or,
        x if x == opcode_code(WasmOpcode::I32Xor) => ConcreteOpcode::I32Xor,
        x if x == opcode_code(WasmOpcode::I32Mul) => ConcreteOpcode::I32Mul,
        x if x == opcode_code(WasmOpcode::Select) => ConcreteOpcode::Select,
        x if x == opcode_code(WasmOpcode::BrIfEqz) => ConcreteOpcode::BrIfEqz(0i32.into()),
        x if x == opcode_code(WasmOpcode::Return) => ConcreteOpcode::Return,
        x if x == opcode_code(WasmOpcode::Trap) => ConcreteOpcode::Trap(TrapCode::ExecutionHalted),
        _ => ConcreteOpcode::Trap(TrapCode::ExecutionHalted),
    }
}

fn concrete_code(op: ConcreteOpcode) -> u16 {
    u16::try_from(op.code()).expect("wasm opcode code must fit u16")
}
