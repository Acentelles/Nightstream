//! Owns Ajtai commitments and exact-opening transport for kernel-owned vector families.
//!
//! This module does not own manifest ordering or transcript binding. It only
//! owns how kernel-owned vector families are encoded into Ajtai
//! commitments and how manifest claims are lifted into explicit digit-opening
//! witnesses.

use neo_ajtai::{
    decomp_b_row_major, get_global_pp_for_dims, get_global_pp_seeded_params_for_dims, has_global_pp_for_dims,
    set_global_pp_seeded, AjtaiSModule, Commitment, DecompStyle,
};
use neo_ccs::{traits::SModuleHomomorphism, Mat};
use neo_math::balanced::to_balanced_i128;
use neo_math::{KExtensions, F, K};
use neo_params::NeoParams;
use neo_transcript::{Poseidon2Transcript, Transcript, TranscriptProtocol};
use p3_field::PrimeCharacteristicRing;

use crate::chip8::spec::{CommitmentId, WITNESS_WIDTH};

use super::opening_boundary::commitment_polynomial_slot;
use super::{KernelOpeningManifest, KernelStepAux, SimpleKernelError};

const TIME_VECTOR_OPENING_DECOMP_BASE: u32 = 2;
const TIME_VECTOR_OPENING_SLICE_BITS: usize = 32;
const TIME_VECTOR_OPENING_SLICE_COUNT: usize = 2;
const TIME_VECTOR_COMMIT_BATCH: usize = 256;

const LANE_FAMILY: TimeVectorFamilySpec = TimeVectorFamilySpec {
    commitment_id: CommitmentId::Lane,
    commitment_digest_domain: b"neo.fold.next/chip8/c_lane_commitments",
    label: "lane",
};

const FETCH_RA_FAMILY: TimeVectorFamilySpec = TimeVectorFamilySpec {
    commitment_id: CommitmentId::FetchRa,
    commitment_digest_domain: b"neo.fold.next/chip8/c_fetch_ra_commitments",
    label: "fetch-ra",
};

const DECODE_RA_FAMILY: TimeVectorFamilySpec = TimeVectorFamilySpec {
    commitment_id: CommitmentId::DecodeRa,
    commitment_digest_domain: b"neo.fold.next/chip8/c_decode_ra_commitments",
    label: "decode-ra",
};

const ALU_RA_FAMILY: TimeVectorFamilySpec = TimeVectorFamilySpec {
    commitment_id: CommitmentId::AluRa,
    commitment_digest_domain: b"neo.fold.next/chip8/c_alu_ra_commitments",
    label: "alu-ra",
};

const EQ4_RA_FAMILY: TimeVectorFamilySpec = TimeVectorFamilySpec {
    commitment_id: CommitmentId::Eq4Ra,
    commitment_digest_domain: b"neo.fold.next/chip8/c_eq4_ra_commitments",
    label: "eq4-ra",
};

const ROM_TABLE_FAMILY: TimeVectorFamilySpec = TimeVectorFamilySpec {
    commitment_id: CommitmentId::RomTable,
    commitment_digest_domain: b"neo.fold.next/chip8/c_rom_table_commitments",
    label: "rom-table",
};

const DECODE_TABLE_FAMILY: TimeVectorFamilySpec = TimeVectorFamilySpec {
    commitment_id: CommitmentId::DecodeTable,
    commitment_digest_domain: b"neo.fold.next/chip8/c_decode_table_commitments",
    label: "decode-table",
};

const ALU_TABLE_FAMILY: TimeVectorFamilySpec = TimeVectorFamilySpec {
    commitment_id: CommitmentId::AluTable,
    commitment_digest_domain: b"neo.fold.next/chip8/c_alu_table_commitments",
    label: "alu-table",
};

const EQ4_TABLE_FAMILY: TimeVectorFamilySpec = TimeVectorFamilySpec {
    commitment_id: CommitmentId::Eq4Table,
    commitment_digest_domain: b"neo.fold.next/chip8/c_eq4_table_commitments",
    label: "eq4-table",
};

const DECODE_HANDOFF_FAMILY: TimeVectorFamilySpec = TimeVectorFamilySpec {
    commitment_id: CommitmentId::DecodeHandoff,
    commitment_digest_domain: b"neo.fold.next/chip8/c_decode_handoff_commitments",
    label: "decode-handoff",
};

const REG_TWIST_FAMILY: TimeVectorFamilySpec = TimeVectorFamilySpec {
    commitment_id: CommitmentId::RegTwist,
    commitment_digest_domain: b"neo.fold.next/chip8/c_reg_commitments",
    label: "reg-twist",
};

const RAM_TWIST_FAMILY: TimeVectorFamilySpec = TimeVectorFamilySpec {
    commitment_id: CommitmentId::RamTwist,
    commitment_digest_domain: b"neo.fold.next/chip8/c_ram_commitments",
    label: "ram-twist",
};

#[derive(Clone, Copy)]
struct TimeVectorFamilySpec {
    commitment_id: CommitmentId,
    commitment_digest_domain: &'static [u8],
    label: &'static str,
}

#[derive(Clone, Debug)]
pub struct LaneCommitmentSet {
    pub commitments: Vec<Commitment>,
}

#[derive(Clone, Debug)]
pub struct FetchRaCommitmentSet {
    pub commitments: Vec<Commitment>,
}

#[derive(Clone, Debug)]
pub struct DecodeRaCommitmentSet {
    pub commitments: Vec<Commitment>,
}

#[derive(Clone, Debug)]
pub struct AluRaCommitmentSet {
    pub commitments: Vec<Commitment>,
}

#[derive(Clone, Debug)]
pub struct Eq4RaCommitmentSet {
    pub commitments: Vec<Commitment>,
}

#[derive(Clone, Debug)]
pub struct RomTableCommitmentSet {
    pub commitments: Vec<Commitment>,
}

#[derive(Clone, Debug)]
pub struct DecodeTableCommitmentSet {
    pub commitments: Vec<Commitment>,
}

#[derive(Clone, Debug)]
pub struct AluTableCommitmentSet {
    pub commitments: Vec<Commitment>,
}

#[derive(Clone, Debug)]
pub struct Eq4TableCommitmentSet {
    pub commitments: Vec<Commitment>,
}

#[derive(Clone, Debug)]
pub struct DecodeHandoffCommitmentSet {
    pub commitments: Vec<Commitment>,
}

#[derive(Clone, Debug)]
pub struct RegTwistCommitmentSet {
    pub commitments: Vec<Commitment>,
}

#[derive(Clone, Debug)]
pub struct RamTwistCommitmentSet {
    pub commitments: Vec<Commitment>,
}

#[derive(Clone, Debug, PartialEq)]
pub struct TimeVectorOpeningProof {
    pub point: Vec<K>,
    pub polynomial_ids: Vec<usize>,
    pub claimed_values: Vec<K>,
    pub digit_evals: Vec<Vec<K>>,
}

pub type LaneOpeningProof = TimeVectorOpeningProof;
pub type FetchRaOpeningProof = TimeVectorOpeningProof;
pub type DecodeRaOpeningProof = TimeVectorOpeningProof;
pub type AluRaOpeningProof = TimeVectorOpeningProof;
pub type Eq4RaOpeningProof = TimeVectorOpeningProof;
pub type RomTableOpeningProof = TimeVectorOpeningProof;
pub type DecodeTableOpeningProof = TimeVectorOpeningProof;
pub type AluTableOpeningProof = TimeVectorOpeningProof;
pub type Eq4TableOpeningProof = TimeVectorOpeningProof;
pub type DecodeHandoffOpeningProof = TimeVectorOpeningProof;
pub type RegTwistOpeningProof = TimeVectorOpeningProof;
pub type RamTwistOpeningProof = TimeVectorOpeningProof;

impl LaneCommitmentSet {
    pub fn expected_digest(&self) -> [u8; 32] {
        commitment_set_digest(LANE_FAMILY.commitment_digest_domain, &self.commitments)
    }

    pub fn expect_matches(&self, expected: &Self) -> Result<(), SimpleKernelError> {
        expect_commitments_match(&self.commitments, &expected.commitments, LANE_FAMILY.label)
    }
}

impl FetchRaCommitmentSet {
    pub fn expected_digest(&self) -> [u8; 32] {
        commitment_set_digest(FETCH_RA_FAMILY.commitment_digest_domain, &self.commitments)
    }

    pub fn expect_matches(&self, expected: &Self) -> Result<(), SimpleKernelError> {
        expect_commitments_match(&self.commitments, &expected.commitments, FETCH_RA_FAMILY.label)
    }
}

impl DecodeRaCommitmentSet {
    pub fn expected_digest(&self) -> [u8; 32] {
        commitment_set_digest(DECODE_RA_FAMILY.commitment_digest_domain, &self.commitments)
    }

    pub fn expect_matches(&self, expected: &Self) -> Result<(), SimpleKernelError> {
        expect_commitments_match(&self.commitments, &expected.commitments, DECODE_RA_FAMILY.label)
    }
}

impl AluRaCommitmentSet {
    pub fn expected_digest(&self) -> [u8; 32] {
        commitment_set_digest(ALU_RA_FAMILY.commitment_digest_domain, &self.commitments)
    }

    pub fn expect_matches(&self, expected: &Self) -> Result<(), SimpleKernelError> {
        expect_commitments_match(&self.commitments, &expected.commitments, ALU_RA_FAMILY.label)
    }
}

impl Eq4RaCommitmentSet {
    pub fn expected_digest(&self) -> [u8; 32] {
        commitment_set_digest(EQ4_RA_FAMILY.commitment_digest_domain, &self.commitments)
    }

    pub fn expect_matches(&self, expected: &Self) -> Result<(), SimpleKernelError> {
        expect_commitments_match(&self.commitments, &expected.commitments, EQ4_RA_FAMILY.label)
    }
}

impl RomTableCommitmentSet {
    pub fn expected_digest(&self) -> [u8; 32] {
        commitment_set_digest(ROM_TABLE_FAMILY.commitment_digest_domain, &self.commitments)
    }

    pub fn expect_matches(&self, expected: &Self) -> Result<(), SimpleKernelError> {
        expect_commitments_match(&self.commitments, &expected.commitments, ROM_TABLE_FAMILY.label)
    }
}

impl DecodeTableCommitmentSet {
    pub fn expected_digest(&self) -> [u8; 32] {
        commitment_set_digest(DECODE_TABLE_FAMILY.commitment_digest_domain, &self.commitments)
    }

    pub fn expect_matches(&self, expected: &Self) -> Result<(), SimpleKernelError> {
        expect_commitments_match(&self.commitments, &expected.commitments, DECODE_TABLE_FAMILY.label)
    }
}

impl AluTableCommitmentSet {
    pub fn expected_digest(&self) -> [u8; 32] {
        commitment_set_digest(ALU_TABLE_FAMILY.commitment_digest_domain, &self.commitments)
    }

    pub fn expect_matches(&self, expected: &Self) -> Result<(), SimpleKernelError> {
        expect_commitments_match(&self.commitments, &expected.commitments, ALU_TABLE_FAMILY.label)
    }
}

impl Eq4TableCommitmentSet {
    pub fn expected_digest(&self) -> [u8; 32] {
        commitment_set_digest(EQ4_TABLE_FAMILY.commitment_digest_domain, &self.commitments)
    }

    pub fn expect_matches(&self, expected: &Self) -> Result<(), SimpleKernelError> {
        expect_commitments_match(&self.commitments, &expected.commitments, EQ4_TABLE_FAMILY.label)
    }
}

impl DecodeHandoffCommitmentSet {
    pub fn expected_digest(&self) -> [u8; 32] {
        commitment_set_digest(DECODE_HANDOFF_FAMILY.commitment_digest_domain, &self.commitments)
    }

    pub fn expect_matches(&self, expected: &Self) -> Result<(), SimpleKernelError> {
        expect_commitments_match(&self.commitments, &expected.commitments, DECODE_HANDOFF_FAMILY.label)
    }
}

impl RegTwistCommitmentSet {
    pub fn expected_digest(&self) -> [u8; 32] {
        commitment_set_digest(REG_TWIST_FAMILY.commitment_digest_domain, &self.commitments)
    }

    pub fn expect_matches(&self, expected: &Self) -> Result<(), SimpleKernelError> {
        expect_commitments_match(&self.commitments, &expected.commitments, REG_TWIST_FAMILY.label)
    }
}

impl RamTwistCommitmentSet {
    pub fn expected_digest(&self) -> [u8; 32] {
        commitment_set_digest(RAM_TWIST_FAMILY.commitment_digest_domain, &self.commitments)
    }

    pub fn expect_matches(&self, expected: &Self) -> Result<(), SimpleKernelError> {
        expect_commitments_match(&self.commitments, &expected.commitments, RAM_TWIST_FAMILY.label)
    }
}

impl TimeVectorOpeningProof {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/time_vector_opening");
        tr.append_u64s(
            b"neo.fold.next/chip8/time_vector_opening/meta",
            &[
                self.point.len() as u64,
                self.polynomial_ids.len() as u64,
                self.claimed_values.len() as u64,
                self.digit_evals.len() as u64,
            ],
        );
        append_k_point(&mut tr, b"neo.fold.next/chip8/time_vector_opening/point", &self.point);
        let polynomial_ids_u64: Vec<u64> = self.polynomial_ids.iter().map(|&id| id as u64).collect();
        tr.append_u64s(
            b"neo.fold.next/chip8/time_vector_opening/polynomial_ids",
            &polynomial_ids_u64,
        );
        append_k_values(
            &mut tr,
            b"neo.fold.next/chip8/time_vector_opening/claimed_values",
            &self.claimed_values,
        );
        tr.append_u64s(
            b"neo.fold.next/chip8/time_vector_opening/digit_eval_count",
            &[self.digit_evals.len() as u64],
        );
        for digits in &self.digit_evals {
            append_k_values(&mut tr, b"neo.fold.next/chip8/time_vector_opening/digit_eval", digits);
        }
        tr.digest32()
    }
}

pub(crate) fn build_lane_commitment_set(
    params: &NeoParams,
    trace_rows: &[[F; WITNESS_WIDTH]],
) -> Result<LaneCommitmentSet, SimpleKernelError> {
    let columns = lane_columns(trace_rows);
    Ok(LaneCommitmentSet {
        commitments: build_family_commitments(params, &columns, LANE_FAMILY)?,
    })
}

pub(crate) fn build_fetch_ra_commitment_set(
    params: &NeoParams,
    aux: &[KernelStepAux],
) -> Result<FetchRaCommitmentSet, SimpleKernelError> {
    let addresses: Vec<usize> = aux.iter().map(|step| step.fetch_addr).collect();
    let columns = stage1_address_columns(&addresses, 11);
    Ok(FetchRaCommitmentSet {
        commitments: build_family_commitments(params, &columns, FETCH_RA_FAMILY)?,
    })
}

pub(crate) fn build_decode_ra_commitment_set(
    params: &NeoParams,
    aux: &[KernelStepAux],
) -> Result<DecodeRaCommitmentSet, SimpleKernelError> {
    let addresses: Vec<usize> = aux.iter().map(|step| step.decode_addr as usize).collect();
    let columns = stage1_address_columns(&addresses, 16);
    Ok(DecodeRaCommitmentSet {
        commitments: build_family_commitments(params, &columns, DECODE_RA_FAMILY)?,
    })
}

pub(crate) fn build_alu_ra_commitment_set(
    params: &NeoParams,
    aux: &[KernelStepAux],
) -> Result<AluRaCommitmentSet, SimpleKernelError> {
    let addresses: Vec<usize> = aux.iter().map(|step| step.alu_key as usize).collect();
    let columns = stage1_address_columns(&addresses, 18);
    Ok(AluRaCommitmentSet {
        commitments: build_family_commitments(params, &columns, ALU_RA_FAMILY)?,
    })
}

pub(crate) fn build_eq4_ra_commitment_set(
    params: &NeoParams,
    aux: &[KernelStepAux],
) -> Result<Eq4RaCommitmentSet, SimpleKernelError> {
    let addresses: Vec<usize> = aux.iter().map(|step| step.eq4_key as usize).collect();
    let columns = stage1_address_columns(&addresses, 8);
    Ok(Eq4RaCommitmentSet {
        commitments: build_family_commitments(params, &columns, EQ4_RA_FAMILY)?,
    })
}

pub(crate) fn build_rom_table_commitment_set(
    params: &NeoParams,
    rom_table: &[F],
) -> Result<RomTableCommitmentSet, SimpleKernelError> {
    Ok(RomTableCommitmentSet {
        commitments: build_family_commitments(params, &bit_reversed_single_column(rom_table, 11), ROM_TABLE_FAMILY)?,
    })
}

pub(crate) fn build_decode_table_commitment_set(
    params: &NeoParams,
    decode_table: &[Vec<F>],
) -> Result<DecodeTableCommitmentSet, SimpleKernelError> {
    Ok(DecodeTableCommitmentSet {
        commitments: build_family_commitments(params, &bit_reversed_columns(decode_table, 16), DECODE_TABLE_FAMILY)?,
    })
}

pub(crate) fn build_alu_table_commitment_set(
    params: &NeoParams,
    alu_table: &[F],
) -> Result<AluTableCommitmentSet, SimpleKernelError> {
    Ok(AluTableCommitmentSet {
        commitments: build_family_commitments(params, &bit_reversed_single_column(alu_table, 16), ALU_TABLE_FAMILY)?,
    })
}

pub(crate) fn build_eq4_table_commitment_set(
    params: &NeoParams,
    eq4_table: &[F],
) -> Result<Eq4TableCommitmentSet, SimpleKernelError> {
    Ok(Eq4TableCommitmentSet {
        commitments: build_family_commitments(params, &bit_reversed_single_column(eq4_table, 8), EQ4_TABLE_FAMILY)?,
    })
}

pub(crate) fn build_decode_handoff_commitment_set(
    params: &NeoParams,
    aux: &[KernelStepAux],
) -> Result<DecodeHandoffCommitmentSet, SimpleKernelError> {
    let columns = decode_handoff_columns(aux);
    Ok(DecodeHandoffCommitmentSet {
        commitments: build_family_commitments(params, &columns, DECODE_HANDOFF_FAMILY)?,
    })
}

pub(crate) fn build_reg_twist_commitment_set(
    params: &NeoParams,
    aux: &[KernelStepAux],
) -> Result<RegTwistCommitmentSet, SimpleKernelError> {
    let columns = reg_twist_columns(aux);
    Ok(RegTwistCommitmentSet {
        commitments: build_family_commitments(params, &columns, REG_TWIST_FAMILY)?,
    })
}

pub(crate) fn build_ram_twist_commitment_set(
    params: &NeoParams,
    aux: &[KernelStepAux],
) -> Result<RamTwistCommitmentSet, SimpleKernelError> {
    let columns = ram_twist_columns(aux);
    Ok(RamTwistCommitmentSet {
        commitments: build_family_commitments(params, &columns, RAM_TWIST_FAMILY)?,
    })
}

pub(crate) fn build_lane_opening_proofs(
    params: &NeoParams,
    trace_rows: &[[F; WITNESS_WIDTH]],
    manifest: &KernelOpeningManifest,
) -> Result<Vec<LaneOpeningProof>, SimpleKernelError> {
    let columns = lane_columns(trace_rows);
    build_family_opening_proofs(params, &columns, manifest, LANE_FAMILY)
}

pub(crate) fn build_fetch_ra_opening_proofs(
    params: &NeoParams,
    aux: &[KernelStepAux],
    manifest: &KernelOpeningManifest,
) -> Result<Vec<FetchRaOpeningProof>, SimpleKernelError> {
    let addresses: Vec<usize> = aux.iter().map(|step| step.fetch_addr).collect();
    let columns = stage1_address_columns(&addresses, 11);
    build_family_opening_proofs(params, &columns, manifest, FETCH_RA_FAMILY)
}

pub(crate) fn build_decode_ra_opening_proofs(
    params: &NeoParams,
    aux: &[KernelStepAux],
    manifest: &KernelOpeningManifest,
) -> Result<Vec<DecodeRaOpeningProof>, SimpleKernelError> {
    let addresses: Vec<usize> = aux.iter().map(|step| step.decode_addr as usize).collect();
    let columns = stage1_address_columns(&addresses, 16);
    build_family_opening_proofs(params, &columns, manifest, DECODE_RA_FAMILY)
}

pub(crate) fn build_alu_ra_opening_proofs(
    params: &NeoParams,
    aux: &[KernelStepAux],
    manifest: &KernelOpeningManifest,
) -> Result<Vec<AluRaOpeningProof>, SimpleKernelError> {
    let addresses: Vec<usize> = aux.iter().map(|step| step.alu_key as usize).collect();
    let columns = stage1_address_columns(&addresses, 18);
    build_family_opening_proofs(params, &columns, manifest, ALU_RA_FAMILY)
}

pub(crate) fn build_eq4_ra_opening_proofs(
    params: &NeoParams,
    aux: &[KernelStepAux],
    manifest: &KernelOpeningManifest,
) -> Result<Vec<Eq4RaOpeningProof>, SimpleKernelError> {
    let addresses: Vec<usize> = aux.iter().map(|step| step.eq4_key as usize).collect();
    let columns = stage1_address_columns(&addresses, 8);
    build_family_opening_proofs(params, &columns, manifest, EQ4_RA_FAMILY)
}

pub(crate) fn build_rom_table_opening_proofs(
    params: &NeoParams,
    rom_table: &[F],
    manifest: &KernelOpeningManifest,
) -> Result<Vec<RomTableOpeningProof>, SimpleKernelError> {
    build_family_opening_proofs(
        params,
        &bit_reversed_single_column(rom_table, 11),
        manifest,
        ROM_TABLE_FAMILY,
    )
}

pub(crate) fn build_decode_table_opening_proofs(
    params: &NeoParams,
    decode_table: &[Vec<F>],
    manifest: &KernelOpeningManifest,
) -> Result<Vec<DecodeTableOpeningProof>, SimpleKernelError> {
    build_family_opening_proofs(
        params,
        &bit_reversed_columns(decode_table, 16),
        manifest,
        DECODE_TABLE_FAMILY,
    )
}

pub(crate) fn build_alu_table_opening_proofs(
    params: &NeoParams,
    alu_table: &[F],
    manifest: &KernelOpeningManifest,
) -> Result<Vec<AluTableOpeningProof>, SimpleKernelError> {
    build_family_opening_proofs(
        params,
        &bit_reversed_single_column(alu_table, 16),
        manifest,
        ALU_TABLE_FAMILY,
    )
}

pub(crate) fn build_eq4_table_opening_proofs(
    params: &NeoParams,
    eq4_table: &[F],
    manifest: &KernelOpeningManifest,
) -> Result<Vec<Eq4TableOpeningProof>, SimpleKernelError> {
    build_family_opening_proofs(
        params,
        &bit_reversed_single_column(eq4_table, 8),
        manifest,
        EQ4_TABLE_FAMILY,
    )
}

pub(crate) fn build_decode_handoff_opening_proofs(
    params: &NeoParams,
    aux: &[KernelStepAux],
    manifest: &KernelOpeningManifest,
) -> Result<Vec<DecodeHandoffOpeningProof>, SimpleKernelError> {
    let columns = decode_handoff_columns(aux);
    build_family_opening_proofs(params, &columns, manifest, DECODE_HANDOFF_FAMILY)
}

pub(crate) fn build_reg_twist_opening_proofs(
    params: &NeoParams,
    aux: &[KernelStepAux],
    manifest: &KernelOpeningManifest,
) -> Result<Vec<RegTwistOpeningProof>, SimpleKernelError> {
    let columns = reg_twist_columns(aux);
    build_family_opening_proofs(params, &columns, manifest, REG_TWIST_FAMILY)
}

pub(crate) fn build_ram_twist_opening_proofs(
    params: &NeoParams,
    aux: &[KernelStepAux],
    manifest: &KernelOpeningManifest,
) -> Result<Vec<RamTwistOpeningProof>, SimpleKernelError> {
    let columns = ram_twist_columns(aux);
    build_family_opening_proofs(params, &columns, manifest, RAM_TWIST_FAMILY)
}

pub(crate) fn verify_lane_commitment_artifacts(
    params: &NeoParams,
    trace_rows: &[[F; WITNESS_WIDTH]],
    manifest: &KernelOpeningManifest,
    commitments: &LaneCommitmentSet,
    opening_proofs: &[LaneOpeningProof],
) -> Result<[u8; 32], SimpleKernelError> {
    let expected_commitments = build_lane_commitment_set(params, trace_rows)?;
    commitments.expect_matches(&expected_commitments)?;
    let expected_openings = build_lane_opening_proofs(params, trace_rows, manifest)?;
    if opening_proofs != expected_openings.as_slice() {
        return Err(SimpleKernelError::OpeningFailed("lane opening proofs mismatch".into()));
    }
    Ok(expected_commitments.expected_digest())
}

pub(crate) fn verify_fetch_ra_commitment_artifacts(
    params: &NeoParams,
    aux: &[KernelStepAux],
    manifest: &KernelOpeningManifest,
    commitments: &FetchRaCommitmentSet,
    opening_proofs: &[FetchRaOpeningProof],
) -> Result<[u8; 32], SimpleKernelError> {
    let expected_commitments = build_fetch_ra_commitment_set(params, aux)?;
    commitments.expect_matches(&expected_commitments)?;
    let expected_openings = build_fetch_ra_opening_proofs(params, aux, manifest)?;
    if opening_proofs != expected_openings.as_slice() {
        return Err(SimpleKernelError::OpeningFailed(
            "fetch-ra opening proofs mismatch".into(),
        ));
    }
    Ok(expected_commitments.expected_digest())
}

pub(crate) fn verify_decode_ra_commitment_artifacts(
    params: &NeoParams,
    aux: &[KernelStepAux],
    manifest: &KernelOpeningManifest,
    commitments: &DecodeRaCommitmentSet,
    opening_proofs: &[DecodeRaOpeningProof],
) -> Result<[u8; 32], SimpleKernelError> {
    let expected_commitments = build_decode_ra_commitment_set(params, aux)?;
    commitments.expect_matches(&expected_commitments)?;
    let expected_openings = build_decode_ra_opening_proofs(params, aux, manifest)?;
    if opening_proofs != expected_openings.as_slice() {
        return Err(SimpleKernelError::OpeningFailed(
            "decode-ra opening proofs mismatch".into(),
        ));
    }
    Ok(expected_commitments.expected_digest())
}

pub(crate) fn verify_alu_ra_commitment_artifacts(
    params: &NeoParams,
    aux: &[KernelStepAux],
    manifest: &KernelOpeningManifest,
    commitments: &AluRaCommitmentSet,
    opening_proofs: &[AluRaOpeningProof],
) -> Result<[u8; 32], SimpleKernelError> {
    let expected_commitments = build_alu_ra_commitment_set(params, aux)?;
    commitments.expect_matches(&expected_commitments)?;
    let expected_openings = build_alu_ra_opening_proofs(params, aux, manifest)?;
    if opening_proofs != expected_openings.as_slice() {
        return Err(SimpleKernelError::OpeningFailed(
            "alu-ra opening proofs mismatch".into(),
        ));
    }
    Ok(expected_commitments.expected_digest())
}

pub(crate) fn verify_eq4_ra_commitment_artifacts(
    params: &NeoParams,
    aux: &[KernelStepAux],
    manifest: &KernelOpeningManifest,
    commitments: &Eq4RaCommitmentSet,
    opening_proofs: &[Eq4RaOpeningProof],
) -> Result<[u8; 32], SimpleKernelError> {
    let expected_commitments = build_eq4_ra_commitment_set(params, aux)?;
    commitments.expect_matches(&expected_commitments)?;
    let expected_openings = build_eq4_ra_opening_proofs(params, aux, manifest)?;
    if opening_proofs != expected_openings.as_slice() {
        return Err(SimpleKernelError::OpeningFailed(
            "eq4-ra opening proofs mismatch".into(),
        ));
    }
    Ok(expected_commitments.expected_digest())
}

pub(crate) fn verify_rom_table_commitment_artifacts(
    params: &NeoParams,
    rom_table: &[F],
    manifest: &KernelOpeningManifest,
    commitments: &RomTableCommitmentSet,
    opening_proofs: &[RomTableOpeningProof],
) -> Result<[u8; 32], SimpleKernelError> {
    let expected_commitments = build_rom_table_commitment_set(params, rom_table)?;
    commitments.expect_matches(&expected_commitments)?;
    let expected_openings = build_rom_table_opening_proofs(params, rom_table, manifest)?;
    if opening_proofs != expected_openings.as_slice() {
        return Err(SimpleKernelError::OpeningFailed(
            "rom-table opening proofs mismatch".into(),
        ));
    }
    Ok(expected_commitments.expected_digest())
}

pub(crate) fn verify_decode_table_commitment_artifacts(
    params: &NeoParams,
    decode_table: &[Vec<F>],
    manifest: &KernelOpeningManifest,
    commitments: &DecodeTableCommitmentSet,
    opening_proofs: &[DecodeTableOpeningProof],
) -> Result<[u8; 32], SimpleKernelError> {
    let expected_commitments = build_decode_table_commitment_set(params, decode_table)?;
    commitments.expect_matches(&expected_commitments)?;
    let expected_openings = build_decode_table_opening_proofs(params, decode_table, manifest)?;
    if opening_proofs != expected_openings.as_slice() {
        return Err(SimpleKernelError::OpeningFailed(
            "decode-table opening proofs mismatch".into(),
        ));
    }
    Ok(expected_commitments.expected_digest())
}

pub(crate) fn verify_alu_table_commitment_artifacts(
    params: &NeoParams,
    alu_table: &[F],
    manifest: &KernelOpeningManifest,
    commitments: &AluTableCommitmentSet,
    opening_proofs: &[AluTableOpeningProof],
) -> Result<[u8; 32], SimpleKernelError> {
    let expected_commitments = build_alu_table_commitment_set(params, alu_table)?;
    commitments.expect_matches(&expected_commitments)?;
    let expected_openings = build_alu_table_opening_proofs(params, alu_table, manifest)?;
    if opening_proofs != expected_openings.as_slice() {
        return Err(SimpleKernelError::OpeningFailed(
            "alu-table opening proofs mismatch".into(),
        ));
    }
    Ok(expected_commitments.expected_digest())
}

pub(crate) fn verify_eq4_table_commitment_artifacts(
    params: &NeoParams,
    eq4_table: &[F],
    manifest: &KernelOpeningManifest,
    commitments: &Eq4TableCommitmentSet,
    opening_proofs: &[Eq4TableOpeningProof],
) -> Result<[u8; 32], SimpleKernelError> {
    let expected_commitments = build_eq4_table_commitment_set(params, eq4_table)?;
    commitments.expect_matches(&expected_commitments)?;
    let expected_openings = build_eq4_table_opening_proofs(params, eq4_table, manifest)?;
    if opening_proofs != expected_openings.as_slice() {
        return Err(SimpleKernelError::OpeningFailed(
            "eq4-table opening proofs mismatch".into(),
        ));
    }
    Ok(expected_commitments.expected_digest())
}

pub(crate) fn verify_decode_handoff_commitment_artifacts(
    params: &NeoParams,
    aux: &[KernelStepAux],
    manifest: &KernelOpeningManifest,
    commitments: &DecodeHandoffCommitmentSet,
    opening_proofs: &[DecodeHandoffOpeningProof],
) -> Result<[u8; 32], SimpleKernelError> {
    let expected_commitments = build_decode_handoff_commitment_set(params, aux)?;
    commitments.expect_matches(&expected_commitments)?;
    let expected_openings = build_decode_handoff_opening_proofs(params, aux, manifest)?;
    if opening_proofs != expected_openings.as_slice() {
        return Err(SimpleKernelError::OpeningFailed(
            "decode-handoff opening proofs mismatch".into(),
        ));
    }
    Ok(expected_commitments.expected_digest())
}

pub(crate) fn verify_reg_twist_commitment_artifacts(
    params: &NeoParams,
    aux: &[KernelStepAux],
    manifest: &KernelOpeningManifest,
    commitments: &RegTwistCommitmentSet,
    opening_proofs: &[RegTwistOpeningProof],
) -> Result<[u8; 32], SimpleKernelError> {
    let expected_commitments = build_reg_twist_commitment_set(params, aux)?;
    commitments.expect_matches(&expected_commitments)?;
    let expected_openings = build_reg_twist_opening_proofs(params, aux, manifest)?;
    if opening_proofs != expected_openings.as_slice() {
        return Err(SimpleKernelError::OpeningFailed(
            "reg-twist opening proofs mismatch".into(),
        ));
    }
    Ok(expected_commitments.expected_digest())
}

pub(crate) fn verify_ram_twist_commitment_artifacts(
    params: &NeoParams,
    aux: &[KernelStepAux],
    manifest: &KernelOpeningManifest,
    commitments: &RamTwistCommitmentSet,
    opening_proofs: &[RamTwistOpeningProof],
) -> Result<[u8; 32], SimpleKernelError> {
    let expected_commitments = build_ram_twist_commitment_set(params, aux)?;
    commitments.expect_matches(&expected_commitments)?;
    let expected_openings = build_ram_twist_opening_proofs(params, aux, manifest)?;
    if opening_proofs != expected_openings.as_slice() {
        return Err(SimpleKernelError::OpeningFailed(
            "ram-twist opening proofs mismatch".into(),
        ));
    }
    Ok(expected_commitments.expected_digest())
}

fn commitment_set_digest(domain: &'static [u8], commitments: &[Commitment]) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(domain);
    tr.append_u64s(
        b"neo.fold.next/chip8/time_vector_commitments/len",
        &[commitments.len() as u64],
    );
    for commitment in commitments {
        tr.append_u64s(
            b"neo.fold.next/chip8/time_vector_commitments/shape",
            &[commitment.d as u64, commitment.kappa as u64],
        );
        tr.absorb_commit_coords(&commitment.data);
    }
    tr.digest32()
}

fn expect_commitments_match(
    actual: &[Commitment],
    expected: &[Commitment],
    label: &str,
) -> Result<(), SimpleKernelError> {
    if actual.len() != expected.len() {
        return Err(SimpleKernelError::OpeningFailed(format!(
            "{label} commitment count {} != expected {}",
            actual.len(),
            expected.len()
        )));
    }
    for (index, (got, want)) in actual.iter().zip(expected.iter()).enumerate() {
        if got != want {
            return Err(SimpleKernelError::OpeningFailed(format!(
                "{label} commitment {index} mismatch"
            )));
        }
    }
    Ok(())
}

fn lane_columns(trace_rows: &[[F; WITNESS_WIDTH]]) -> Vec<Vec<F>> {
    let mut columns = vec![Vec::with_capacity(trace_rows.len()); WITNESS_WIDTH - 1];
    for row in trace_rows {
        for (column, value) in row[1..].iter().enumerate() {
            columns[column].push(*value);
        }
    }
    columns
}

fn bit_reversed_single_column(values: &[F], bits: usize) -> Vec<Vec<F>> {
    vec![bit_reversed_column(values, bits)]
}

fn bit_reversed_columns(columns: &[Vec<F>], bits: usize) -> Vec<Vec<F>> {
    columns
        .iter()
        .map(|column| bit_reversed_column(column, bits))
        .collect()
}

fn bit_reversed_column(values: &[F], bits: usize) -> Vec<F> {
    let mut reordered = vec![F::ZERO; values.len()];
    for (index, &value) in values.iter().enumerate() {
        reordered[bit_reverse_fixed(index, bits)] = value;
    }
    reordered
}

fn stage1_address_columns(addresses: &[usize], addr_bits: usize) -> Vec<Vec<F>> {
    let time_len = addresses.len();
    let addr_domain = 1usize << addr_bits;
    let lifted_len = addr_domain * time_len;
    let mut column = vec![F::ZERO; lifted_len];

    for (cycle, &addr) in addresses.iter().enumerate() {
        let index = (cycle << addr_bits) + bit_reverse_fixed(addr, addr_bits);
        column[index] = F::ONE;
    }

    vec![column]
}

fn decode_handoff_columns(aux: &[KernelStepAux]) -> Vec<Vec<F>> {
    let mut columns = vec![Vec::with_capacity(aux.len()); 3];
    for step in aux {
        columns[0].push(if step.uses_y { F::ONE } else { F::ZERO });
        columns[1].push(if step.reads_ram { F::ONE } else { F::ZERO });
        columns[2].push(if step.writes_ram { F::ONE } else { F::ZERO });
    }
    columns
}

fn reg_twist_columns(aux: &[KernelStepAux]) -> Vec<Vec<F>> {
    let time_len = aux.len();
    let addr_bits = 5usize;
    let addr_domain = 1usize << addr_bits;
    let lifted_len = addr_domain * time_len;
    let mut columns = vec![vec![F::ZERO; lifted_len]; 5];

    for (cycle, step) in aux.iter().enumerate() {
        let cycle_base = cycle << addr_bits;
        for addr in 0..addr_domain {
            columns[0][cycle_base + addr] = step.reg_inc;
        }

        let ra_x = cycle_base + bit_reverse_fixed(step.reg_ra_x_addr, addr_bits);
        let ra_y = cycle_base + bit_reverse_fixed(step.reg_ra_y_addr, addr_bits);
        let ra_i = cycle_base + bit_reverse_fixed(step.reg_ra_i_addr, addr_bits);
        let wa = cycle_base + bit_reverse_fixed(step.reg_wa_addr, addr_bits);
        columns[1][ra_x] = F::ONE;
        columns[2][ra_y] = F::ONE;
        columns[3][ra_i] = F::ONE;
        columns[4][wa] = F::ONE;
    }

    columns
}

fn ram_twist_columns(aux: &[KernelStepAux]) -> Vec<Vec<F>> {
    let time_len = aux.len();
    let addr_bits = 13usize;
    let addr_domain = 1usize << addr_bits;
    let lifted_len = addr_domain * time_len;
    let mut columns = vec![vec![F::ZERO; lifted_len]; 3];

    for (cycle, step) in aux.iter().enumerate() {
        let cycle_base = cycle << addr_bits;
        for addr in 0..addr_domain {
            columns[0][cycle_base + addr] = step.ram_inc;
        }

        let ra = cycle_base + bit_reverse_fixed(step.ram_ra_addr, addr_bits);
        let wa = cycle_base + bit_reverse_fixed(step.ram_wa_addr, addr_bits);
        columns[1][ra] = F::ONE;
        columns[2][wa] = F::ONE;
    }

    columns
}

fn bit_reverse_fixed(index: usize, bits: usize) -> usize {
    if bits == 0 {
        0
    } else {
        index.reverse_bits() >> (usize::BITS as usize - bits)
    }
}

fn build_family_commitments(
    params: &NeoParams,
    columns: &[Vec<F>],
    family: TimeVectorFamilySpec,
) -> Result<Vec<Commitment>, SimpleKernelError> {
    let encoded_mats = encode_time_vector_columns(params, columns, family.label)?;
    let logical_len = columns.first().map_or(0, Vec::len);
    let committer = family_committer(params, logical_len, family)?;
    let mut commitments = Vec::with_capacity(encoded_mats.len());
    for chunk in encoded_mats.chunks(TIME_VECTOR_COMMIT_BATCH) {
        let refs: Vec<&Mat<F>> = chunk.iter().collect();
        commitments.extend(committer.commit_many(&refs));
    }
    Ok(commitments)
}

fn build_family_opening_proofs(
    params: &NeoParams,
    columns: &[Vec<F>],
    manifest: &KernelOpeningManifest,
    family: TimeVectorFamilySpec,
) -> Result<Vec<TimeVectorOpeningProof>, SimpleKernelError> {
    let encoded_mats = encode_time_vector_columns(params, columns, family.label)?;
    manifest
        .claims
        .iter()
        .filter(|claim| claim.commitment_id == family.commitment_id)
        .map(|claim| build_opening_proof(&encoded_mats, claim, family.label))
        .collect()
}

fn build_opening_proof(
    encoded_mats: &[Mat<F>],
    claim: &super::KernelOpeningClaim,
    label: &str,
) -> Result<TimeVectorOpeningProof, SimpleKernelError> {
    let mut digit_evals = Vec::with_capacity(claim.polynomial_ids.len());
    for (&poly_id, &claimed_value) in claim.polynomial_ids.iter().zip(claim.claimed_values.iter()) {
        let slot = commitment_polynomial_slot(claim.commitment_id, poly_id)?;
        let encoded = encoded_mats.get(slot).ok_or_else(|| {
            SimpleKernelError::OpeningFailed(format!(
                "{label} opening references out-of-range polynomial id {poly_id}"
            ))
        })?;
        let digits = eval_time_mat_digits_at_point(&claim.point, encoded, label)?;
        if recompose_time_vector_digits_to_scalar(&digits) != claimed_value {
            return Err(SimpleKernelError::OpeningFailed(format!(
                "{label} opening claim for polynomial {poly_id} does not match exact transport"
            )));
        }
        digit_evals.push(digits);
    }

    Ok(TimeVectorOpeningProof {
        point: claim.point.clone(),
        polynomial_ids: claim.polynomial_ids.clone(),
        claimed_values: claim.claimed_values.clone(),
        digit_evals,
    })
}

fn family_committer(
    params: &NeoParams,
    t: usize,
    family: TimeVectorFamilySpec,
) -> Result<AjtaiSModule, SimpleKernelError> {
    let d = params.d as usize;
    let encoded_t = encoded_time_width(t)?;
    let want_kappa = params.kappa as usize;
    let expected_seed = time_vector_commit_seed(d, t, encoded_t);

    if has_global_pp_for_dims(d, encoded_t) {
        if let Ok((kappa, seed)) = get_global_pp_seeded_params_for_dims(d, encoded_t) {
            if kappa != want_kappa || seed != expected_seed {
                return Err(SimpleKernelError::OpeningFailed(format!(
                    "{} commitment PP mismatch for (d,m)=({d},{encoded_t})",
                    family.label
                )));
            }
        } else {
            let pp = get_global_pp_for_dims(d, encoded_t).map_err(|err| {
                SimpleKernelError::OpeningFailed(format!(
                    "failed to load {} commitment PP for (d,m)=({d},{encoded_t}): {err}",
                    family.label
                ))
            })?;
            if pp.kappa != want_kappa {
                return Err(SimpleKernelError::OpeningFailed(format!(
                    "{} commitment PP kappa mismatch for (d,m)=({d},{encoded_t})",
                    family.label
                )));
            }
        }
    } else {
        set_global_pp_seeded(d, want_kappa, encoded_t, expected_seed).map_err(|err| {
            SimpleKernelError::OpeningFailed(format!(
                "failed to register seeded {} commitment PP for (d,m)=({d},{encoded_t}): {err}",
                family.label
            ))
        })?;
    }

    AjtaiSModule::from_global_for_dims(d, encoded_t).map_err(|err| {
        SimpleKernelError::OpeningFailed(format!(
            "failed to initialize {} committer for (d,m)=({d},{encoded_t}): {err}",
            family.label
        ))
    })
}

fn time_vector_commit_seed(d: usize, t: usize, encoded_t: usize) -> [u8; 32] {
    #[inline]
    fn mix64(mut x: u64) -> u64 {
        x ^= x >> 30;
        x = x.wrapping_mul(0xbf58_476d_1ce4_e5b9);
        x ^= x >> 27;
        x = x.wrapping_mul(0x94d0_49bb_1331_11eb);
        x ^ (x >> 31)
    }

    let dd = d as u64;
    let tt = t as u64;
    let enc = encoded_t as u64;
    let words = [
        mix64(0x6e65_6f2d_6368_6970 ^ dd ^ (tt << 1) ^ (enc << 3)),
        mix64(0x7469_6d65_2d76_6563 ^ (tt << 7) ^ (enc << 11)),
        mix64(0x636f_6d6d_6974_2d76 ^ (dd << 13) ^ (tt << 5) ^ (enc << 17)),
        mix64(
            0x6465_7465_726d_2d73
                ^ (dd << 17)
                ^ (tt << 19)
                ^ ((TIME_VECTOR_OPENING_SLICE_BITS as u64) << 23)
                ^ ((TIME_VECTOR_OPENING_SLICE_COUNT as u64) << 27),
        ),
    ];
    let mut seed = [0u8; 32];
    for (index, word) in words.iter().enumerate() {
        seed[index * 8..(index + 1) * 8].copy_from_slice(&word.to_le_bytes());
    }
    seed
}

fn encode_time_vector_columns(
    params: &NeoParams,
    columns: &[Vec<F>],
    label: &str,
) -> Result<Vec<Mat<F>>, SimpleKernelError> {
    columns
        .iter()
        .map(|column| encode_time_opening_vector_to_mat(params, column, label))
        .collect()
}

pub(crate) fn encoded_time_width(t: usize) -> Result<usize, SimpleKernelError> {
    t.checked_mul(TIME_VECTOR_OPENING_SLICE_COUNT)
        .ok_or_else(|| {
            SimpleKernelError::OpeningFailed(format!(
                "time-vector opening encoded width overflow for trace length {t}"
            ))
        })
}

fn field_from_small_signed(value: i128) -> F {
    debug_assert!(value.unsigned_abs() <= u64::MAX as u128);
    if value >= 0 {
        F::from_u64(value as u64)
    } else {
        F::ZERO - F::from_u64((-value) as u64)
    }
}

fn slice_radix_u64() -> u64 {
    1u64 << TIME_VECTOR_OPENING_SLICE_BITS
}

fn split_time_scalar_slices(value: F) -> [F; TIME_VECTOR_OPENING_SLICE_COUNT] {
    let radix = slice_radix_u64() as i128;
    let centered = to_balanced_i128(value);
    let lo = centered.rem_euclid(radix);
    let hi = (centered - lo) / radix;
    [field_from_small_signed(lo), field_from_small_signed(hi)]
}

fn encode_time_opening_vector_to_mat(
    params: &NeoParams,
    values: &[F],
    label: &str,
) -> Result<Mat<F>, SimpleKernelError> {
    let t = values.len();
    let encoded_t = encoded_time_width(t)?;
    let mut slice_values = [Vec::with_capacity(t), Vec::with_capacity(t)];
    for &value in values {
        let [lo, hi] = split_time_scalar_slices(value);
        slice_values[0].push(lo);
        slice_values[1].push(hi);
    }

    let d = params.d as usize;
    let row_major_slices = [
        decomp_b_row_major(
            slice_values[0].as_slice(),
            TIME_VECTOR_OPENING_DECOMP_BASE,
            d,
            DecompStyle::Balanced,
        ),
        decomp_b_row_major(
            slice_values[1].as_slice(),
            TIME_VECTOR_OPENING_DECOMP_BASE,
            d,
            DecompStyle::Balanced,
        ),
    ];

    let mut row_major = Vec::with_capacity(d * encoded_t);
    for rho in 0..d {
        let row_start = rho * t;
        let row_end = row_start + t;
        row_major.extend_from_slice(&row_major_slices[0][row_start..row_end]);
        row_major.extend_from_slice(&row_major_slices[1][row_start..row_end]);
    }
    if row_major.len() != d * encoded_t {
        return Err(SimpleKernelError::OpeningFailed(format!(
            "{label} encoded row-major size {} != expected {}",
            row_major.len(),
            d * encoded_t
        )));
    }
    Ok(Mat::from_row_major(d, encoded_t, row_major))
}

fn expand_time_row_weights(weights: &[K]) -> Vec<K> {
    let mut out = Vec::with_capacity(weights.len() * TIME_VECTOR_OPENING_SLICE_COUNT);
    let slice_radix = K::from(F::from_u64(slice_radix_u64()));
    let mut scale = K::ONE;
    for _ in 0..TIME_VECTOR_OPENING_SLICE_COUNT {
        for &weight in weights {
            out.push(scale * weight);
        }
        scale *= slice_radix;
    }
    out
}

fn eval_time_mat_digits_at_point(point: &[K], encoded: &Mat<F>, label: &str) -> Result<Vec<K>, SimpleKernelError> {
    let raw_t = encoded.cols() / TIME_VECTOR_OPENING_SLICE_COUNT;
    if raw_t * TIME_VECTOR_OPENING_SLICE_COUNT != encoded.cols() {
        return Err(SimpleKernelError::OpeningFailed(format!(
            "{label} encoded matrix column count {} is not divisible by slice count {}",
            encoded.cols(),
            TIME_VECTOR_OPENING_SLICE_COUNT
        )));
    }
    let weights = neo_memory::mle::build_chi_table(point);
    if weights.len() != raw_t {
        return Err(SimpleKernelError::OpeningFailed(format!(
            "{label} opening point dimension {} yields {} weights for raw_t {}",
            point.len(),
            weights.len(),
            raw_t
        )));
    }
    let expanded_weights = expand_time_row_weights(&weights);
    let mut digits = vec![K::ZERO; encoded.rows()];
    let cols = encoded.cols();
    let data = encoded.as_slice();
    for rho in 0..encoded.rows() {
        let row = &data[rho * cols..(rho + 1) * cols];
        let mut acc = K::ZERO;
        for (&weight, &value) in expanded_weights.iter().zip(row.iter()) {
            if value != F::ZERO {
                acc += weight.scale_base(value);
            }
        }
        digits[rho] = acc;
    }
    Ok(digits)
}

pub(crate) fn recompose_time_vector_digits_to_scalar(digits: &[K]) -> K {
    let base = K::from(F::from_u64(TIME_VECTOR_OPENING_DECOMP_BASE as u64));
    let mut power = K::ONE;
    let mut acc = K::ZERO;
    for &digit in digits {
        acc += power * digit;
        power *= base;
    }
    acc
}

fn append_k_point(tr: &mut Poseidon2Transcript, label: &'static [u8], point: &[K]) {
    tr.append_u64s(
        b"neo.fold.next/chip8/time_vector_opening/point_len",
        &[point.len() as u64],
    );
    let coeffs_per_elem = point
        .first()
        .map(|value| value.as_coeffs().len())
        .unwrap_or(0);
    tr.append_fields_iter(
        label,
        point.len().saturating_mul(coeffs_per_elem),
        point.iter().flat_map(|value| value.as_coeffs()),
    );
}

fn append_k_values(tr: &mut Poseidon2Transcript, label: &'static [u8], values: &[K]) {
    tr.append_u64s(
        b"neo.fold.next/chip8/time_vector_opening/value_len",
        &[values.len() as u64],
    );
    let coeffs_per_elem = values
        .first()
        .map(|value| value.as_coeffs().len())
        .unwrap_or(0);
    tr.append_fields_iter(
        label,
        values.len().saturating_mul(coeffs_per_elem),
        values.iter().flat_map(|value| value.as_coeffs()),
    );
}
