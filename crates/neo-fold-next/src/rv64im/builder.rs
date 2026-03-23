//! Owns executing the RV64IM parity slice into concrete steps and lowered rows.

use super::execute::{execute_step, ExecutedStep};
use super::isa::{Rv64BuildError, Rv64Program, Rv64State};
use super::lower::{lower_step, Rv64ExpandedRow};

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Rv64ProgramBuild {
    pub executed_steps: Vec<ExecutedStep>,
    pub rows: Vec<Rv64ExpandedRow>,
    pub final_state: Rv64State,
}

pub fn build_program(
    program: &Rv64Program,
    initial_state: &Rv64State,
    max_steps: usize,
) -> Result<Rv64ProgramBuild, Rv64BuildError> {
    if max_steps == 0 {
        return Err(Rv64BuildError::Program(
            "RV64 parity slice requires max_steps > 0".into(),
        ));
    }

    let mut state = initial_state.clone();
    let mut executed_steps = Vec::new();
    for step_index in 0..max_steps {
        let step = execute_step(program, &state, step_index)?;
        state = step.next.clone();
        executed_steps.push(step);
        if state.halted {
            break;
        }
    }

    if !state.halted {
        return Err(Rv64BuildError::Program(format!(
            "RV64 parity slice did not halt within {max_steps} steps"
        )));
    }

    let rows = executed_steps.iter().map(lower_step).collect();
    Ok(Rv64ProgramBuild {
        executed_steps,
        rows,
        final_state: state,
    })
}
