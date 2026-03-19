//! Owns batch extension-family lowering and proof facades.

pub mod bytecode_fetch;
pub mod compiler;
pub mod ram_history;
pub mod register_history;

use crate::chip8::spec::{Chip8Program, Chip8State};
use crate::proof::{ExtensionFamily, RunProof, SessionExtensionAccumulator, SessionExtensionProofs};
use neo_math::{from_complex, KExtensions, F, K};
use neo_reductions::error::PiCcsError;
use neo_transcript::{Poseidon2Transcript, Transcript};

#[derive(Clone, Debug)]
pub struct FamilyPlacement {
    pub family: ExtensionFamily,
    pub preferred_stage: u8,
}

#[derive(Clone, Debug)]
pub struct LoweredVmPlan {
    pub vm_name: &'static str,
    pub witness_width: usize,
    pub families: Vec<FamilyPlacement>,
}

pub fn session_step_points(session: &RunProof) -> Result<Vec<Vec<K>>, PiCcsError> {
    session
        .steps
        .iter()
        .enumerate()
        .map(|(step_idx, step)| {
            step.ccs_outputs
                .first()
                .map(|claim| claim.r.clone())
                .ok_or_else(|| {
                    PiCcsError::ProtocolError(format!(
                        "missing CE output point for extension families at step {step_idx}"
                    ))
                })
        })
        .collect()
}

fn validate_step_points(acc: &SessionExtensionAccumulator, step_points: &[Vec<K>]) -> Result<(), PiCcsError> {
    if acc.steps.len() != step_points.len() {
        return Err(PiCcsError::InvalidInput(format!(
            "extension step count {} does not match CE point count {}",
            acc.steps.len(),
            step_points.len()
        )));
    }
    if let Some(first) = step_points.first() {
        let point_len = first.len();
        for (idx, point) in step_points.iter().enumerate().skip(1) {
            if point.len() != point_len {
                return Err(PiCcsError::InvalidInput(format!(
                    "extension CE point length mismatch at step {idx}: expected {point_len}, got {}",
                    point.len()
                )));
            }
        }
    }
    Ok(())
}

pub(crate) fn append_point(tr: &mut Poseidon2Transcript, label: &'static [u8], point: &[K]) {
    tr.append_u64s(b"neo.fold.next/family/point_len", &[point.len() as u64]);
    let coeffs: Vec<F> = point.iter().flat_map(|value| value.as_coeffs()).collect();
    tr.append_fields(label, &coeffs);
}

pub(crate) fn bind_step_points(tr: &mut Poseidon2Transcript, label: &'static [u8], step_points: &[Vec<K>]) {
    tr.append_u64s(b"neo.fold.next/family/step_point_count", &[step_points.len() as u64]);
    for point in step_points {
        append_point(tr, label, point);
    }
}

pub(crate) fn sample_batch_point(
    tr: &mut Poseidon2Transcript,
    domain_label: &'static [u8],
    step_points: &[Vec<K>],
) -> Vec<K> {
    tr.append_message(domain_label, b"v1");
    let point_len = step_points.first().map_or(1, Vec::len);
    (0..point_len)
        .map(|_| {
            let re = tr.challenge_field(b"neo.fold.next/family/batch_point/re");
            let im = tr.challenge_field(b"neo.fold.next/family/batch_point/im");
            from_complex(re, im)
        })
        .collect()
}

pub fn prove_chip8_extensions(
    program: &Chip8Program,
    initial_state: &Chip8State,
    acc: &SessionExtensionAccumulator,
    step_points: &[Vec<K>],
) -> Result<SessionExtensionProofs, PiCcsError> {
    validate_step_points(acc, step_points)?;
    let (bytecode_fetch, mut opening_claims) = bytecode_fetch::prove_bytecode_fetch(program, acc, step_points)?;
    let (register_history, register_openings) =
        register_history::prove_register_history(initial_state, acc, step_points)?;
    let (ram_history, ram_openings) = ram_history::prove_ram_history(initial_state, acc, step_points)?;
    opening_claims.extend(register_openings);
    opening_claims.extend(ram_openings);
    Ok(SessionExtensionProofs {
        bytecode_fetch: Some(bytecode_fetch),
        register_history: Some(register_history),
        ram_history: Some(ram_history),
        opening_claims,
    })
}

pub fn verify_chip8_extensions(
    program: &Chip8Program,
    initial_state: &Chip8State,
    acc: &SessionExtensionAccumulator,
    step_points: &[Vec<K>],
    proofs: &SessionExtensionProofs,
) -> Result<(), PiCcsError> {
    validate_step_points(acc, step_points)?;
    let bytecode = proofs
        .bytecode_fetch
        .as_ref()
        .ok_or_else(|| PiCcsError::ProtocolError("missing bytecode-fetch proof".into()))?;
    let register_history = proofs
        .register_history
        .as_ref()
        .ok_or_else(|| PiCcsError::ProtocolError("missing register-history proof".into()))?;
    let ram_history = proofs
        .ram_history
        .as_ref()
        .ok_or_else(|| PiCcsError::ProtocolError("missing ram-history proof".into()))?;

    let bytecode_openings = bytecode_fetch::verify_bytecode_fetch(program, acc, step_points, bytecode)?;
    let register_openings =
        register_history::verify_register_history(initial_state, acc, step_points, register_history)?;
    let ram_openings = ram_history::verify_ram_history(initial_state, acc, step_points, ram_history)?;

    let mut expected = bytecode_openings;
    expected.extend(register_openings);
    expected.extend(ram_openings);
    if expected != proofs.opening_claims {
        return Err(PiCcsError::ProtocolError(
            "extension opening claims do not match verified family outputs".into(),
        ));
    }
    Ok(())
}
