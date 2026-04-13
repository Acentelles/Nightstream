use neo_ajtai::Commitment;
use neo_ccs::traits::SModuleHomomorphism;
use neo_ccs::{CcsStructure, Mat, SparsePoly};
use neo_fold_next::proof::{FoldSchedule, StepInput};
use neo_fold_next::prover::CommitmentMixers;
use neo_fold_next::run::{prove_run, verify_run};
use neo_fold_next::vm::VmSpec;
use neo_fold_next::wasm::{opcode_code, StackLaneAccess, WasmOpcode, WasmStepTrace, WasmTraceBuilder, WasmVmSpec};
use neo_math::F;
use neo_params::NeoParams;
use neo_reductions::api::FoldingMode;
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

fn add_commitments(lhs: &Commitment, rhs: &Commitment) -> Commitment {
    let mut out = lhs.clone();
    out.add_inplace(rhs);
    out
}

fn scale_commitment_by_rho(rho: &Mat<F>, c: &Commitment) -> Commitment {
    let mut out = Commitment::zeros(c.d, c.kappa);
    for col in 0..c.kappa {
        for r in 0..c.d {
            let mut acc = F::ZERO;
            for k in 0..c.d {
                acc += rho[(r, k)] * c.col(col)[k];
            }
            out.col_mut(col)[r] = acc;
        }
    }
    out
}

fn mix_rhos_commits(rhos: &[Mat<F>], cs: &[Commitment]) -> Commitment {
    let mut acc = Commitment::zeros(cs[0].d, cs[0].kappa);
    for (rho, c) in rhos.iter().zip(cs.iter()) {
        acc = add_commitments(&acc, &scale_commitment_by_rho(rho, c));
    }
    acc
}

fn combine_b_pows(cs: &[Commitment], b: u32) -> Commitment {
    let mut acc = Commitment::zeros(cs[0].d, cs[0].kappa);
    let mut pow = F::ONE;
    let base = F::from_u64(b as u64);
    for c in cs {
        let mut term = c.clone();
        for value in &mut term.data {
            *value *= pow;
        }
        acc = add_commitments(&acc, &term);
        pow *= base;
    }
    acc
}

fn mixers() -> CommitmentMixers<fn(&[Mat<F>], &[Commitment]) -> Commitment, fn(&[Commitment], u32) -> Commitment> {
    CommitmentMixers {
        mix_rhos_commits,
        combine_b_pows,
    }
}

fn identity_ccs(n: usize) -> CcsStructure<F> {
    CcsStructure::new(vec![Mat::identity(n)], SparsePoly::new(1, vec![])).expect("identity CCS")
}

#[test]
fn wasm_frontend_scaffold_runs_through_generic_spine() {
    let vm = WasmVmSpec::new().expect("vm");
    let log = ToyModule;
    let builder = WasmTraceBuilder::new(&log);

    let steps = vec![
        WasmStepTrace {
            cycle: 0,
            pc_before: 0,
            pc_after: 1,
            opcode_code: opcode_code(WasmOpcode::I32Const),
            opcode: WasmOpcode::I32Const,
            info: neo_fold_next::wasm::opcode_info_from_code(opcode_code(WasmOpcode::I32Const)),
            sp_before: 0,
            sp_after: 1,
            stack_read0: None,
            stack_read1: None,
            stack_read2: None,
            stack_write1: Some(StackLaneAccess { addr: 0, value: 7 }),
            halted: false,
            locals_fbp: 0,
            local_index: None,
            local_read_value: None,
            local_write_value: None,
        },
        WasmStepTrace {
            cycle: 1,
            pc_before: 1,
            pc_after: 2,
            opcode_code: opcode_code(WasmOpcode::I32Const),
            opcode: WasmOpcode::I32Const,
            info: neo_fold_next::wasm::opcode_info_from_code(opcode_code(WasmOpcode::I32Const)),
            sp_before: 1,
            sp_after: 2,
            stack_read0: None,
            stack_read1: None,
            stack_read2: None,
            stack_write1: Some(StackLaneAccess { addr: 1, value: 9 }),
            halted: false,
            locals_fbp: 0,
            local_index: None,
            local_read_value: None,
            local_write_value: None,
        },
        WasmStepTrace {
            cycle: 2,
            pc_before: 2,
            pc_after: 3,
            opcode_code: opcode_code(WasmOpcode::I32Add),
            opcode: WasmOpcode::I32Add,
            info: neo_fold_next::wasm::opcode_info_from_code(opcode_code(WasmOpcode::I32Add)),
            sp_before: 2,
            sp_after: 1,
            stack_read0: Some(StackLaneAccess { addr: 0, value: 7 }),
            stack_read1: Some(StackLaneAccess { addr: 1, value: 9 }),
            stack_read2: None,
            stack_write1: Some(StackLaneAccess { addr: 0, value: 16 }),
            halted: false,
            locals_fbp: 0,
            local_index: None,
            local_read_value: None,
            local_write_value: None,
        },
        WasmStepTrace {
            cycle: 3,
            pc_before: 3,
            pc_after: 4,
            opcode_code: opcode_code(WasmOpcode::Return),
            opcode: WasmOpcode::Return,
            info: neo_fold_next::wasm::opcode_info_from_code(opcode_code(WasmOpcode::Return)),
            sp_before: 1,
            sp_after: 1,
            stack_read0: None,
            stack_read1: None,
            stack_read2: None,
            stack_write1: None,
            halted: true,
            locals_fbp: 0,
            local_index: None,
            local_read_value: None,
            local_write_value: None,
        },
    ];

    let prepared = builder.build_steps(&vm, &steps).expect("build");
    let step_inputs: Vec<StepInput> = prepared.iter().map(|step| step.prepared.clone()).collect();
    let public_steps = step_inputs
        .iter()
        .map(|step| step.public())
        .collect::<Vec<_>>();

    let ccs = identity_ccs(vm.core_ccs_spec().witness_width);
    let params = NeoParams::goldilocks_auto_r1cs_ccs(ccs.m).expect("params");
    let proof = prove_run(
        FoldingMode::Optimized,
        FoldSchedule::RowsPerChunk(1),
        &params,
        &ccs,
        step_inputs.clone(),
        &log,
        mixers(),
    )
    .expect("prove");

    let verified = verify_run(FoldingMode::Optimized, &params, &ccs, &public_steps, &proof, mixers()).expect("verify");
    assert_eq!(verified, proof.final_main_claims);
}
