//! Owns packaging lowered CHIP-8 rows into `StepBuild` records.

use neo_ajtai::Commitment;
use neo_ccs::traits::SModuleHomomorphism;
use neo_ccs::{CcsClaim, CcsWitness, Mat};
use neo_math::{D, F};
use p3_field::PrimeCharacteristicRing;

use crate::chip8::ccs::Chip8VmSpec;
use crate::chip8::execute::Chip8BuildError;
use crate::chip8::isa::{decode_opcode, Chip8Program, Chip8State, Chip8StepTrace};
use crate::chip8::layout::PUBLIC_INPUTS;
use crate::chip8::lower::{build_row_traces, execute_program, Chip8RowTrace};
use crate::chip8::tables::{decode_to_output, DecodeOutput};
use crate::proof::StepInput;
use crate::step_build::StepBuild;
use crate::vm::VmSpec;
use crate::vm::VmTraceBuilder;

pub struct Chip8TraceBuilder<'a, L> {
    log: &'a L,
}

impl<'a, L> Chip8TraceBuilder<'a, L> {
    pub fn new(log: &'a L) -> Self {
        Self { log }
    }

    pub fn execute_program(
        program: &Chip8Program,
        initial_state: &Chip8State,
        step_count: usize,
    ) -> Result<Vec<crate::chip8::lower::Chip8ExecutionStep>, Chip8BuildError> {
        execute_program(program, initial_state, step_count)
    }

    pub fn build_program(
        &self,
        vm: &Chip8VmSpec,
        program: &Chip8Program,
        initial_state: &Chip8State,
        step_count: usize,
    ) -> Result<Vec<StepBuild>, Chip8BuildError>
    where
        L: SModuleHomomorphism<F, Commitment> + Sync,
    {
        let execution = execute_program(program, initial_state, step_count)?;
        let mut out = Vec::new();
        for step in &execution {
            for row_trace in &step.row_traces {
                out.push(self.build_step_from_row_trace(vm, &step.trace, row_trace)?);
            }
        }
        Ok(out)
    }

    fn build_rows(
        &self,
        vm: &Chip8VmSpec,
        _program: &Chip8Program,
        prev: &Chip8State,
        next: &Chip8State,
        trace: &Chip8StepTrace,
    ) -> Result<Vec<StepBuild>, Chip8BuildError>
    where
        L: SModuleHomomorphism<F, Commitment> + Sync,
    {
        let decoded = decode_opcode(trace.opcode).map_err(Chip8BuildError::Unsupported)?;
        let dec_out: DecodeOutput = decode_to_output(trace.opcode);
        build_row_traces(prev, next, trace, &decoded, &dec_out)?
            .iter()
            .map(|row_trace| self.build_step_from_row_trace(vm, trace, row_trace))
            .collect()
    }

    fn build_step_from_row_trace(
        &self,
        vm: &Chip8VmSpec,
        trace: &Chip8StepTrace,
        row_trace: &Chip8RowTrace,
    ) -> Result<StepBuild, Chip8BuildError>
    where
        L: SModuleHomomorphism<F, Commitment> + Sync,
    {
        let z_mat = pack_row_major(&row_trace.row);
        let x_pub = row_trace.row[..PUBLIC_INPUTS].to_vec();
        let w = row_trace.row[PUBLIC_INPUTS..].to_vec();
        let burst_label = row_trace
            .burst
            .map(|(burst_index, x_bound)| format!("[{burst_index}/{x_bound}]"))
            .unwrap_or_default();

        let prepared = StepInput {
            label: format!(
                "chip8@w{:03x}:0x{:04x}{}",
                row_trace.kernel_aux.fetch_addr, trace.opcode, burst_label
            ),
            mcs: CcsClaim {
                c: self.log.commit(&z_mat),
                x: x_pub,
                m_in: vm.core_ccs_spec().m_in,
            },
            witness: CcsWitness { w, Z: z_mat },
        };

        Ok(StepBuild {
            public_step: prepared.instance(),
            prepared,
            extension_data: row_trace.extension_data.clone(),
            kernel_aux: Some(row_trace.kernel_aux.clone()),
        })
    }
}

impl<'a, L> VmTraceBuilder<Chip8VmSpec> for Chip8TraceBuilder<'a, L>
where
    L: SModuleHomomorphism<F, Commitment> + Sync,
{
    type Program = Chip8Program;
    type MachineState = Chip8State;
    type StepTrace = Chip8StepTrace;
    type Error = Chip8BuildError;

    fn build_step(
        &self,
        vm: &Chip8VmSpec,
        program: &Self::Program,
        prev: &Self::MachineState,
        next: &Self::MachineState,
        trace: &Self::StepTrace,
    ) -> Result<StepBuild, Self::Error> {
        let rows = self.build_rows(vm, program, prev, next, trace)?;
        rows.into_iter()
            .next()
            .ok_or_else(|| Chip8BuildError::Program("no rows produced".into()))
    }
}

fn pack_row_major(z: &[F]) -> Mat<F> {
    let cols = z.len().div_ceil(D);
    let mut out = Mat::zero(D, cols, F::ZERO);
    for (idx, value) in z.iter().copied().enumerate() {
        out[(idx % D, idx / D)] = value;
    }
    out
}
