//! Owns folded bucket-proof shape serialization helpers for the CHIP-8 kernel.

use neo_transcript::{Poseidon2Transcript, Transcript};

use super::lane_commitment::encoded_time_width;
use super::{CommitmentId, SimpleKernelError};

#[derive(Clone, Debug, PartialEq)]
pub struct KernelJointOpeningFoldShape {
    pub logical_t: usize,
    pub encoded_time_width: usize,
    pub selector_bits: usize,
    pub selector_domain_size: usize,
}

pub(super) fn append_fold_shape(
    tr: &mut Poseidon2Transcript,
    label: &'static [u8],
    shape: &KernelJointOpeningFoldShape,
) {
    tr.append_message(label, b"fold_shape");
    tr.append_u64s(
        b"neo.fold.next/chip8/joint_opening/fold_shape_meta",
        &[
            shape.logical_t as u64,
            shape.encoded_time_width as u64,
            shape.selector_bits as u64,
            shape.selector_domain_size as u64,
        ],
    );
}

pub(super) fn build_joint_opening_fold_shape_for_commitment(
    logical_t: usize,
    commitment_id: CommitmentId,
    selector_bits: usize,
) -> Result<KernelJointOpeningFoldShape, SimpleKernelError> {
    let family_logical_t = match commitment_id {
        CommitmentId::Lane | CommitmentId::DecodeHandoff => logical_t,
        CommitmentId::FetchRa => logical_t
            .checked_shl(11)
            .ok_or_else(|| SimpleKernelError::OpeningFailed("fetch-ra logical length overflow".into()))?,
        CommitmentId::DecodeRa => logical_t
            .checked_shl(16)
            .ok_or_else(|| SimpleKernelError::OpeningFailed("decode-ra logical length overflow".into()))?,
        CommitmentId::AluRa => logical_t
            .checked_shl(18)
            .ok_or_else(|| SimpleKernelError::OpeningFailed("alu-ra logical length overflow".into()))?,
        CommitmentId::Eq4Ra => logical_t
            .checked_shl(8)
            .ok_or_else(|| SimpleKernelError::OpeningFailed("eq4-ra logical length overflow".into()))?,
        CommitmentId::RegTwist => logical_t
            .checked_shl(5)
            .ok_or_else(|| SimpleKernelError::OpeningFailed("reg-twist logical length overflow".into()))?,
        CommitmentId::RamTwist => logical_t
            .checked_shl(13)
            .ok_or_else(|| SimpleKernelError::OpeningFailed("ram-twist logical length overflow".into()))?,
        CommitmentId::RomTable => 1usize << 11,
        CommitmentId::Eq4Table => 1usize << 8,
        CommitmentId::DecodeTable | CommitmentId::AluTable => 1usize << 16,
        CommitmentId::RootProver(_) => {
            return Err(SimpleKernelError::OpeningFailed(
                "kernel joint-opening fold shape does not support root-owned commitments".into(),
            ));
        }
    };

    let encoded_t = encoded_time_width(family_logical_t)?;
    if encoded_t == 0 {
        return Err(SimpleKernelError::OpeningFailed(
            "kernel joint-opening fold lane requires logical_t > 0".into(),
        ));
    }
    let selector_domain_size = 1usize
        .checked_shl(selector_bits as u32)
        .ok_or_else(|| {
            SimpleKernelError::OpeningFailed("kernel joint-opening fold lane selector domain overflow".into())
        })?
        .max(1);
    Ok(KernelJointOpeningFoldShape {
        logical_t: family_logical_t,
        encoded_time_width: encoded_t,
        selector_bits,
        selector_domain_size,
    })
}
