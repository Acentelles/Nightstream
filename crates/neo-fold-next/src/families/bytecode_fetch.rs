//! Owns readonly batch family for bytecode verification.
//!
//! SOUNDNESS NOTE: This is a transcript binding, not a cryptographic proof.
//! The prover and verifier run identical code. This binds extension data into
//! the Fiat-Shamir transcript (preventing after-the-fact modification) but does
//! not prove correctness via sumcheck. Real Shout-style lookup proofs will
//! replace this when Phase G is implemented.

use neo_math::K;
use neo_reductions::error::PiCcsError;
use neo_transcript::{Poseidon2Transcript, Transcript};

use crate::chip8::spec::Chip8Program;
use crate::families::{bind_step_points, sample_batch_point};
use crate::proof::{BytecodeFetchProof, OpeningClaim, OpeningDomain, OpeningSource, SessionExtensionAccumulator};

pub fn prove_bytecode_fetch(
    program: &Chip8Program,
    acc: &SessionExtensionAccumulator,
    step_points: &[Vec<K>],
) -> Result<(BytecodeFetchProof, Vec<OpeningClaim>), PiCcsError> {
    let (digest, point, opening_claims, record_count) = bytecode_fetch_summary(program, acc, step_points)?;
    Ok((
        BytecodeFetchProof {
            record_count,
            point,
            digest,
        },
        opening_claims,
    ))
}

pub fn verify_bytecode_fetch(
    program: &Chip8Program,
    acc: &SessionExtensionAccumulator,
    step_points: &[Vec<K>],
    proof: &BytecodeFetchProof,
) -> Result<Vec<OpeningClaim>, PiCcsError> {
    let (digest, point, opening_claims, record_count) = bytecode_fetch_summary(program, acc, step_points)?;
    if proof.record_count != record_count || proof.point != point || proof.digest != digest {
        return Err(PiCcsError::ProtocolError(
            "bytecode-fetch proof digest/count/point mismatch".into(),
        ));
    }
    Ok(opening_claims)
}

fn bytecode_fetch_summary(
    program: &Chip8Program,
    acc: &SessionExtensionAccumulator,
    step_points: &[Vec<K>],
) -> Result<([u8; 32], Vec<K>, Vec<OpeningClaim>, usize), PiCcsError> {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/family/bytecode_fetch");
    bind_step_points(&mut tr, b"neo.fold.next/family/bytecode_fetch/step_point", step_points);
    let mut openings = Vec::new();
    let mut record_count = 0usize;
    for (step_idx, step) in acc.steps.iter().enumerate() {
        if let Some(record) = &step.bytecode_fetch {
            let expected = program
                .opcode_at(record.pc)
                .ok_or_else(|| PiCcsError::InvalidInput(format!("missing program word for pc 0x{:03x}", record.pc)))?;
            if expected != record.opcode {
                return Err(PiCcsError::ProtocolError(format!(
                    "bytecode fetch mismatch at pc 0x{:03x}: expected 0x{:04x}, got 0x{:04x}",
                    record.pc, expected, record.opcode
                )));
            }
            tr.append_u64s(
                b"neo.fold.next/family/bytecode_fetch/record",
                &[record.pc as u64, record.opcode as u64],
            );
            openings.push(OpeningClaim {
                source: OpeningSource::BytecodeFetch,
                domain: OpeningDomain::Mem,
                point: Vec::new(),
                ordinal: step_idx as u64,
                column_ids: vec![100, 101],
                digest: digest_record(record.pc as u64, record.opcode as u64, step_idx as u64),
            });
            record_count += 1;
        }
    }
    let point = sample_batch_point(&mut tr, b"neo.fold.next/family/bytecode_fetch/point", step_points);
    for opening in &mut openings {
        opening.point = point.clone();
    }
    Ok((tr.digest32(), point, openings, record_count))
}

fn digest_record(pc: u64, opcode: u64, ordinal: u64) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/family/bytecode_fetch/record");
    tr.append_u64s(b"neo.fold.next/family/bytecode_fetch/pc_opcode", &[pc, opcode, ordinal]);
    tr.digest32()
}
