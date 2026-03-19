//! Owns the RAM-history batch family.
//!
//! SOUNDNESS NOTE: This is a transcript binding, not a cryptographic proof.
//! The prover and verifier run identical code — replaying RAM state and
//! verifying consistency. This does not prove correctness via sumcheck. Real
//! Twist-style read-write checking proofs will replace this when Phase I is
//! implemented.

use neo_math::K;
use neo_reductions::error::PiCcsError;
use neo_transcript::{Poseidon2Transcript, Transcript};

use crate::chip8::spec::{Chip8State, CHIP8_MEMORY_BYTES};
use crate::families::{bind_step_points, sample_batch_point};
use crate::proof::{OpeningClaim, OpeningDomain, OpeningSource, RamHistoryProof, SessionExtensionAccumulator};

pub fn prove_ram_history(
    initial_state: &Chip8State,
    acc: &SessionExtensionAccumulator,
    step_points: &[Vec<K>],
) -> Result<(RamHistoryProof, Vec<OpeningClaim>), PiCcsError> {
    let (digest, point, openings, read_count, write_count) = ram_history_summary(initial_state, acc, step_points)?;
    Ok((
        RamHistoryProof {
            read_count,
            write_count,
            point,
            digest,
        },
        openings,
    ))
}

pub fn verify_ram_history(
    initial_state: &Chip8State,
    acc: &SessionExtensionAccumulator,
    step_points: &[Vec<K>],
    proof: &RamHistoryProof,
) -> Result<Vec<OpeningClaim>, PiCcsError> {
    let (digest, point, openings, read_count, write_count) = ram_history_summary(initial_state, acc, step_points)?;
    if proof.read_count != read_count
        || proof.write_count != write_count
        || proof.point != point
        || proof.digest != digest
    {
        return Err(PiCcsError::ProtocolError(
            "ram-history proof digest/count/point mismatch".into(),
        ));
    }
    Ok(openings)
}

fn ram_history_summary(
    initial_state: &Chip8State,
    acc: &SessionExtensionAccumulator,
    step_points: &[Vec<K>],
) -> Result<([u8; 32], Vec<K>, Vec<OpeningClaim>, usize, usize), PiCcsError> {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/family/ram_history");
    tr.append_message(
        b"neo.fold.next/family/ram_history/initial_state",
        &digest_initial_ram_state(initial_state),
    );
    bind_step_points(&mut tr, b"neo.fold.next/family/ram_history/step_point", step_points);
    let mut openings = Vec::new();
    let mut read_count = 0usize;
    let mut write_count = 0usize;
    let mut memory = initial_state.memory;
    for (step_idx, step) in acc.steps.iter().enumerate() {
        let mut ordinal = 0u64;
        for read in &step.ram_reads {
            let addr = read.addr as usize;
            if addr >= CHIP8_MEMORY_BYTES {
                return Err(PiCcsError::ProtocolError(format!(
                    "ram-history read address out of range at step {step_idx}: 0x{:03x}",
                    read.addr
                )));
            }
            let expected = memory[addr];
            if read.value != expected {
                return Err(PiCcsError::ProtocolError(format!(
                    "ram-history read mismatch at step {step_idx}: expected {} at 0x{:03x}, got {}",
                    expected, read.addr, read.value
                )));
            }
            tr.append_u64s(
                b"neo.fold.next/family/ram_history/read",
                &[step_idx as u64, read.addr as u64, read.value as u64],
            );
            openings.push(OpeningClaim {
                source: OpeningSource::RamHistory,
                domain: OpeningDomain::Mem,
                point: Vec::new(),
                ordinal,
                column_ids: vec![ram_column_id(read.addr, 0)],
                digest: digest_ram_access(step_idx as u64, ordinal, read.addr as u64, read.value as u64, 0),
            });
            ordinal += 1;
            read_count += 1;
        }
        for write in &step.ram_writes {
            let addr = write.addr as usize;
            if addr >= CHIP8_MEMORY_BYTES {
                return Err(PiCcsError::ProtocolError(format!(
                    "ram-history write address out of range at step {step_idx}: 0x{:03x}",
                    write.addr
                )));
            }
            memory[addr] = write.value;
            tr.append_u64s(
                b"neo.fold.next/family/ram_history/write",
                &[step_idx as u64, write.addr as u64, write.value as u64],
            );
            openings.push(OpeningClaim {
                source: OpeningSource::RamHistory,
                domain: OpeningDomain::Mem,
                point: Vec::new(),
                ordinal,
                column_ids: vec![ram_column_id(write.addr, 1)],
                digest: digest_ram_access(step_idx as u64, ordinal, write.addr as u64, write.value as u64, 1),
            });
            ordinal += 1;
            write_count += 1;
        }
    }
    let point = sample_batch_point(&mut tr, b"neo.fold.next/family/ram_history/point", step_points);
    for opening in &mut openings {
        opening.point = point.clone();
    }
    Ok((tr.digest32(), point, openings, read_count, write_count))
}

fn ram_column_id(addr: u16, kind: u32) -> u32 {
    10_000u32 + u32::from(addr) * 2 + kind
}

fn digest_initial_ram_state(initial_state: &Chip8State) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/family/ram_history/initial_state");
    for (addr, value) in initial_state.memory.iter().enumerate() {
        tr.append_u64s(
            b"neo.fold.next/family/ram_history/initial_byte",
            &[addr as u64, *value as u64],
        );
    }
    tr.digest32()
}

fn digest_ram_access(step_idx: u64, ordinal: u64, addr: u64, value: u64, kind: u64) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/family/ram_access");
    tr.append_u64s(
        b"neo.fold.next/family/ram_access/meta",
        &[step_idx, ordinal, addr, value, kind],
    );
    tr.digest32()
}
