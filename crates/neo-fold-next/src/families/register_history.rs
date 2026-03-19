//! Owns the register-history batch family.
//!
//! SOUNDNESS NOTE: This is a transcript binding, not a cryptographic proof.
//! The prover and verifier run identical code — replaying register state and
//! verifying consistency. This does not prove correctness via sumcheck. Real
//! Twist-style read-write checking proofs will replace this when Phase I is
//! implemented.

use neo_math::K;
use neo_reductions::error::PiCcsError;
use neo_transcript::{Poseidon2Transcript, Transcript};

use crate::chip8::spec::Chip8State;
use crate::families::{bind_step_points, sample_batch_point};
use crate::proof::{
    OpeningClaim, OpeningDomain, OpeningSource, RegisterAccessRecord, RegisterBank, RegisterHistoryProof,
    SessionExtensionAccumulator,
};

pub fn prove_register_history(
    initial_state: &Chip8State,
    acc: &SessionExtensionAccumulator,
    step_points: &[Vec<K>],
) -> Result<(RegisterHistoryProof, Vec<OpeningClaim>), PiCcsError> {
    let (digest, point, openings, read_count, write_count) = register_history_summary(initial_state, acc, step_points)?;
    Ok((
        RegisterHistoryProof {
            read_count,
            write_count,
            point,
            digest,
        },
        openings,
    ))
}

pub fn verify_register_history(
    initial_state: &Chip8State,
    acc: &SessionExtensionAccumulator,
    step_points: &[Vec<K>],
    proof: &RegisterHistoryProof,
) -> Result<Vec<OpeningClaim>, PiCcsError> {
    let (digest, point, openings, read_count, write_count) = register_history_summary(initial_state, acc, step_points)?;
    if proof.read_count != read_count
        || proof.write_count != write_count
        || proof.point != point
        || proof.digest != digest
    {
        return Err(PiCcsError::ProtocolError(
            "register-history proof digest/count/point mismatch".into(),
        ));
    }
    Ok(openings)
}

fn register_history_summary(
    initial_state: &Chip8State,
    acc: &SessionExtensionAccumulator,
    step_points: &[Vec<K>],
) -> Result<([u8; 32], Vec<K>, Vec<OpeningClaim>, usize, usize), PiCcsError> {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/family/register_history");
    tr.append_message(
        b"neo.fold.next/family/register_history/initial_state",
        &digest_initial_register_state(initial_state),
    );
    bind_step_points(
        &mut tr,
        b"neo.fold.next/family/register_history/step_point",
        step_points,
    );
    let mut openings = Vec::new();
    let mut read_count = 0usize;
    let mut write_count = 0usize;
    let mut v = initial_state.v;
    let mut i = initial_state.i;
    for (step_idx, step) in acc.steps.iter().enumerate() {
        let mut ordinal = 0u64;
        for read in &step.register_reads {
            let expected = read_register(read, &v, i)?;
            if read.value != expected {
                return Err(PiCcsError::ProtocolError(format!(
                    "register-history read mismatch at step {step_idx}: expected {} for {:?}[{}], got {}",
                    expected, read.bank, read.index, read.value
                )));
            }
            tr.append_u64s(
                b"neo.fold.next/family/register_history/read",
                &[
                    step_idx as u64,
                    register_bank_tag(read.bank),
                    read.index as u64,
                    read.value as u64,
                ],
            );
            openings.push(OpeningClaim {
                source: OpeningSource::RegisterHistory,
                domain: OpeningDomain::Mem,
                point: Vec::new(),
                ordinal,
                column_ids: vec![register_column_id(read.bank, read.index, 0)],
                digest: digest_register_access(step_idx as u64, ordinal, read, 0),
            });
            ordinal += 1;
            read_count += 1;
        }
        for write in &step.register_writes {
            write_register(write, &mut v, &mut i)?;
            tr.append_u64s(
                b"neo.fold.next/family/register_history/write",
                &[
                    step_idx as u64,
                    register_bank_tag(write.bank),
                    write.index as u64,
                    write.value as u64,
                ],
            );
            openings.push(OpeningClaim {
                source: OpeningSource::RegisterHistory,
                domain: OpeningDomain::Mem,
                point: Vec::new(),
                ordinal,
                column_ids: vec![register_column_id(write.bank, write.index, 1)],
                digest: digest_register_access(step_idx as u64, ordinal, write, 1),
            });
            ordinal += 1;
            write_count += 1;
        }
    }
    let point = sample_batch_point(&mut tr, b"neo.fold.next/family/register_history/point", step_points);
    for opening in &mut openings {
        opening.point = point.clone();
    }
    Ok((tr.digest32(), point, openings, read_count, write_count))
}

fn read_register(read: &RegisterAccessRecord, v: &[u8; 16], i: u16) -> Result<u16, PiCcsError> {
    match read.bank {
        RegisterBank::V => {
            let slot = v.get(read.index as usize).ok_or_else(|| {
                PiCcsError::ProtocolError(format!("register-history V index out of range: {}", read.index))
            })?;
            Ok(*slot as u16)
        }
        RegisterBank::I => {
            if read.index != 0 {
                return Err(PiCcsError::ProtocolError(format!(
                    "register-history I bank index must be 0, got {}",
                    read.index
                )));
            }
            Ok(i)
        }
    }
}

fn write_register(write: &RegisterAccessRecord, v: &mut [u8; 16], i: &mut u16) -> Result<(), PiCcsError> {
    match write.bank {
        RegisterBank::V => {
            let slot = v.get_mut(write.index as usize).ok_or_else(|| {
                PiCcsError::ProtocolError(format!("register-history V index out of range: {}", write.index))
            })?;
            let value = u8::try_from(write.value).map_err(|_| {
                PiCcsError::ProtocolError(format!(
                    "register-history V write out of 8-bit range at index {}: {}",
                    write.index, write.value
                ))
            })?;
            *slot = value;
        }
        RegisterBank::I => {
            if write.index != 0 {
                return Err(PiCcsError::ProtocolError(format!(
                    "register-history I bank index must be 0, got {}",
                    write.index
                )));
            }
            *i = write.value;
        }
    }
    Ok(())
}

fn register_bank_tag(bank: RegisterBank) -> u64 {
    match bank {
        RegisterBank::V => 0,
        RegisterBank::I => 1,
    }
}

fn register_column_id(bank: RegisterBank, index: u8, kind: u32) -> u32 {
    let bank_base = match bank {
        RegisterBank::V => 1_000u32,
        RegisterBank::I => 2_000u32,
    };
    bank_base + u32::from(index) * 2 + kind
}

fn digest_initial_register_state(initial_state: &Chip8State) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/family/register_history/initial_state");
    tr.append_u64s(
        b"neo.fold.next/family/register_history/initial_i",
        &[initial_state.i as u64],
    );
    for (idx, value) in initial_state.v.iter().enumerate() {
        tr.append_u64s(
            b"neo.fold.next/family/register_history/initial_v",
            &[idx as u64, *value as u64],
        );
    }
    tr.digest32()
}

fn digest_register_access(step_idx: u64, ordinal: u64, access: &RegisterAccessRecord, kind: u64) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/family/register_access");
    tr.append_u64s(
        b"neo.fold.next/family/register_access/meta",
        &[
            step_idx,
            ordinal,
            register_bank_tag(access.bank),
            access.index as u64,
            access.value as u64,
            kind,
        ],
    );
    tr.digest32()
}
