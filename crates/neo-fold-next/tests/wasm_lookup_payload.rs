use neo_ajtai::Commitment;
use neo_ccs::traits::SModuleHomomorphism;
use neo_ccs::Mat;
use neo_fold_next::wasm::{
    lookup_payload, opcode_code, opcode_info_from_code, StackLaneAccess, WasmOpcode, WasmShoutOpcode, WasmStepTrace,
    WasmTraceBuilder, WasmVmSpec,
};
use neo_math::F;
use p3_field::PrimeCharacteristicRing;

struct ToyModule;

impl SModuleHomomorphism<F, Commitment> for ToyModule {
    fn commit(&self, z: &Mat<F>) -> Commitment {
        let mut out = Commitment::zeros(z.rows(), 1);
        for r in 0..z.rows() {
            let mut acc = F::ZERO;
            for c in 0..z.cols() {
                acc += z[(r, c)];
            }
            out.data[r] = acc;
        }
        out
    }

    fn project_x(&self, z: &Mat<F>, min: usize) -> Mat<F> {
        let cols = min.min(z.cols());
        let mut out = Mat::zero(z.rows(), cols, F::ZERO);
        for r in 0..z.rows() {
            for c in 0..cols {
                out[(r, c)] = z[(r, c)];
            }
        }
        out
    }
}

fn step(opcode: WasmOpcode, lhs: u32, rhs: Option<u32>, out: u32) -> WasmStepTrace {
    let code = opcode_code(opcode);
    let info = opcode_info_from_code(code);
    WasmStepTrace {
        cycle: 0,
        pc_before: 0,
        pc_after: 1,
        opcode_code: code,
        opcode,
        info,
        sp_before: u64::from(info.stack_reads),
        sp_after: u64::from(info.stack_writes),
        stack_read0: (info.stack_reads > 0).then_some(StackLaneAccess { addr: 0, value: lhs }),
        stack_read1: rhs.map(|value| StackLaneAccess { addr: 1, value }),
        stack_read2: None,
        stack_write1: (info.stack_writes > 0).then_some(StackLaneAccess { addr: 0, value: out }),
        halted: false,
        locals_fbp: 0,
        local_index: None,
        local_read_value: None,
        local_write_value: None,
    }
}

#[test]
fn unary_lookup_payload_is_emitted_for_i32_eqz() {
    let trace = step(WasmOpcode::I32Eqz, 11, None, 0);
    let payload = lookup_payload(&trace).expect("payload");
    assert_eq!(payload.arity, neo_fold_next::wasm::WasmLookupArity::Unary);
    assert_eq!(payload.shout_id, WasmShoutOpcode::I32Eqz.to_shout_id());
    assert_eq!(payload.input0, 11);
    assert_eq!(payload.input1, 0);
    assert_eq!(payload.output, 0);
}

#[test]
fn binary_lookup_payload_is_emitted_for_i32_xor() {
    let trace = step(WasmOpcode::I32Xor, 0x55aa, Some(0x0ff0), 0x5a5a);
    let payload = lookup_payload(&trace).expect("payload");
    assert_eq!(payload.arity, neo_fold_next::wasm::WasmLookupArity::Binary);
    assert_eq!(payload.shout_id, WasmShoutOpcode::I32Xor.to_shout_id());
    assert_eq!(payload.input0, 0x55aa);
    assert_eq!(payload.input1, 0x0ff0);
    assert_eq!(payload.output, 0x5a5a);
}

#[test]
fn trace_builder_attaches_lookup_payload_to_extension_data() {
    let vm = WasmVmSpec::new().expect("vm");
    let log = ToyModule;
    let builder = WasmTraceBuilder::new(&log);
    let trace = step(WasmOpcode::I32Mul, 7, Some(9), 63);

    let built = builder.build_steps(&vm, &[trace]).expect("build");
    let payload = built[0]
        .extension_data
        .shout_lookup
        .clone()
        .expect("lookup payload");

    assert_eq!(payload.shout_id, WasmShoutOpcode::I32Mul.to_shout_id());
    assert_eq!(payload.input0, 7);
    assert_eq!(payload.input1, 9);
    assert_eq!(payload.output, 63);
}
