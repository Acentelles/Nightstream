//! Owns Ajtai commitments and exact-opening transport for kernel-owned vector families.
//!
//! This module does not own manifest ordering or transcript binding. It only
//! owns how kernel-owned vector families are encoded into Ajtai
//! commitments and how manifest claims are lifted into explicit digit-opening
//! witnesses.

mod transport;

use neo_ajtai::Commitment;
use neo_math::{F, K};
use neo_params::NeoParams;
use p3_field::PrimeCharacteristicRing;

use crate::chip8::spec::{CommitmentId, WITNESS_WIDTH};

use super::openings::KernelExactOpeningArtifacts;
use super::{KernelCommitments, KernelOpeningManifest, KernelStepAux, SimpleKernelError, SimpleKernelProof};
use transport::{
    build_family_commitments, build_family_opening_proofs, commitment_set_digest, expect_commitments_match,
};
pub(crate) use transport::{encoded_time_width, recompose_time_vector_digits_to_scalar};

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

pub(crate) struct KernelCommitmentSets {
    pub(crate) lane_commitments: LaneCommitmentSet,
    pub(crate) fetch_ra_commitments: FetchRaCommitmentSet,
    pub(crate) decode_ra_commitments: DecodeRaCommitmentSet,
    pub(crate) alu_ra_commitments: AluRaCommitmentSet,
    pub(crate) eq4_ra_commitments: Eq4RaCommitmentSet,
    pub(crate) rom_table_commitments: RomTableCommitmentSet,
    pub(crate) decode_table_commitments: DecodeTableCommitmentSet,
    pub(crate) alu_table_commitments: AluTableCommitmentSet,
    pub(crate) eq4_table_commitments: Eq4TableCommitmentSet,
    pub(crate) decode_handoff_commitments: DecodeHandoffCommitmentSet,
    pub(crate) reg_twist_commitments: RegTwistCommitmentSet,
    pub(crate) ram_twist_commitments: RamTwistCommitmentSet,
}

pub(crate) struct KernelOpeningProofSets {
    pub(crate) lane_opening_proofs: Vec<LaneOpeningProof>,
    pub(crate) fetch_ra_opening_proofs: Vec<FetchRaOpeningProof>,
    pub(crate) decode_ra_opening_proofs: Vec<DecodeRaOpeningProof>,
    pub(crate) alu_ra_opening_proofs: Vec<AluRaOpeningProof>,
    pub(crate) eq4_ra_opening_proofs: Vec<Eq4RaOpeningProof>,
    pub(crate) rom_table_opening_proofs: Vec<RomTableOpeningProof>,
    pub(crate) decode_table_opening_proofs: Vec<DecodeTableOpeningProof>,
    pub(crate) alu_table_opening_proofs: Vec<AluTableOpeningProof>,
    pub(crate) eq4_table_opening_proofs: Vec<Eq4TableOpeningProof>,
    pub(crate) decode_handoff_opening_proofs: Vec<DecodeHandoffOpeningProof>,
    pub(crate) reg_twist_opening_proofs: Vec<RegTwistOpeningProof>,
    pub(crate) ram_twist_opening_proofs: Vec<RamTwistOpeningProof>,
}

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

fn build_kernel_commitments(
    lane_commitment_digest: [u8; 32],
    fetch_ra_commitment_digest: [u8; 32],
    decode_ra_commitment_digest: [u8; 32],
    alu_ra_commitment_digest: [u8; 32],
    eq4_ra_commitment_digest: [u8; 32],
    rom_table_commitment_digest: [u8; 32],
    decode_table_commitment_digest: [u8; 32],
    alu_table_commitment_digest: [u8; 32],
    eq4_table_commitment_digest: [u8; 32],
    decode_handoff_commitment_digest: [u8; 32],
    reg_twist_commitment_digest: [u8; 32],
    ram_twist_commitment_digest: [u8; 32],
) -> KernelCommitments {
    KernelCommitments {
        c_lane: lane_commitment_digest,
        c_fetch_ra: fetch_ra_commitment_digest,
        c_decode_ra: decode_ra_commitment_digest,
        c_alu_ra: alu_ra_commitment_digest,
        c_eq4_ra: eq4_ra_commitment_digest,
        c_decode_handoff: decode_handoff_commitment_digest,
        c_reg: reg_twist_commitment_digest,
        c_ram: ram_twist_commitment_digest,
        c_rom_table: rom_table_commitment_digest,
        c_decode_table: decode_table_commitment_digest,
        c_alu_table: alu_table_commitment_digest,
        c_eq4_table: eq4_table_commitment_digest,
    }
}

impl KernelCommitmentSets {
    pub(crate) fn build(
        params: &NeoParams,
        trace_rows: &[[F; WITNESS_WIDTH]],
        aux: &[KernelStepAux],
        rom_table: &[F],
        decode_table: &[Vec<F>],
        alu_table: &[F],
        eq4_table: &[F],
    ) -> Result<Self, SimpleKernelError> {
        Ok(Self {
            lane_commitments: build_lane_commitment_set(params, trace_rows)?,
            fetch_ra_commitments: build_fetch_ra_commitment_set(params, aux)?,
            decode_ra_commitments: build_decode_ra_commitment_set(params, aux)?,
            alu_ra_commitments: build_alu_ra_commitment_set(params, aux)?,
            eq4_ra_commitments: build_eq4_ra_commitment_set(params, aux)?,
            rom_table_commitments: build_rom_table_commitment_set(params, rom_table)?,
            decode_table_commitments: build_decode_table_commitment_set(params, decode_table)?,
            alu_table_commitments: build_alu_table_commitment_set(params, alu_table)?,
            eq4_table_commitments: build_eq4_table_commitment_set(params, eq4_table)?,
            decode_handoff_commitments: build_decode_handoff_commitment_set(params, aux)?,
            reg_twist_commitments: build_reg_twist_commitment_set(params, aux)?,
            ram_twist_commitments: build_ram_twist_commitment_set(params, aux)?,
        })
    }

    pub(crate) fn commitments(&self) -> KernelCommitments {
        build_kernel_commitments(
            self.lane_commitments.expected_digest(),
            self.fetch_ra_commitments.expected_digest(),
            self.decode_ra_commitments.expected_digest(),
            self.alu_ra_commitments.expected_digest(),
            self.eq4_ra_commitments.expected_digest(),
            self.rom_table_commitments.expected_digest(),
            self.decode_table_commitments.expected_digest(),
            self.alu_table_commitments.expected_digest(),
            self.eq4_table_commitments.expected_digest(),
            self.decode_handoff_commitments.expected_digest(),
            self.reg_twist_commitments.expected_digest(),
            self.ram_twist_commitments.expected_digest(),
        )
    }

    pub(crate) fn exact_opening_artifacts<'a>(
        &'a self,
        opening_proofs: &'a KernelOpeningProofSets,
    ) -> KernelExactOpeningArtifacts<'a> {
        KernelExactOpeningArtifacts {
            lane_commitments: &self.lane_commitments,
            fetch_ra_commitments: &self.fetch_ra_commitments,
            decode_ra_commitments: &self.decode_ra_commitments,
            alu_ra_commitments: &self.alu_ra_commitments,
            eq4_ra_commitments: &self.eq4_ra_commitments,
            rom_table_commitments: &self.rom_table_commitments,
            decode_table_commitments: &self.decode_table_commitments,
            alu_table_commitments: &self.alu_table_commitments,
            eq4_table_commitments: &self.eq4_table_commitments,
            decode_handoff_commitments: &self.decode_handoff_commitments,
            reg_twist_commitments: &self.reg_twist_commitments,
            ram_twist_commitments: &self.ram_twist_commitments,
            lane_opening_proofs: &opening_proofs.lane_opening_proofs,
            fetch_ra_opening_proofs: &opening_proofs.fetch_ra_opening_proofs,
            decode_ra_opening_proofs: &opening_proofs.decode_ra_opening_proofs,
            alu_ra_opening_proofs: &opening_proofs.alu_ra_opening_proofs,
            eq4_ra_opening_proofs: &opening_proofs.eq4_ra_opening_proofs,
            rom_table_opening_proofs: &opening_proofs.rom_table_opening_proofs,
            decode_table_opening_proofs: &opening_proofs.decode_table_opening_proofs,
            alu_table_opening_proofs: &opening_proofs.alu_table_opening_proofs,
            eq4_table_opening_proofs: &opening_proofs.eq4_table_opening_proofs,
            decode_handoff_opening_proofs: &opening_proofs.decode_handoff_opening_proofs,
            reg_twist_opening_proofs: &opening_proofs.reg_twist_opening_proofs,
            ram_twist_opening_proofs: &opening_proofs.ram_twist_opening_proofs,
        }
    }
}

impl KernelOpeningProofSets {
    pub(crate) fn build(
        params: &NeoParams,
        trace_rows: &[[F; WITNESS_WIDTH]],
        aux: &[KernelStepAux],
        rom_table: &[F],
        decode_table: &[Vec<F>],
        alu_table: &[F],
        eq4_table: &[F],
        manifest: &KernelOpeningManifest,
    ) -> Result<Self, SimpleKernelError> {
        Ok(Self {
            lane_opening_proofs: build_lane_opening_proofs(params, trace_rows, manifest)?,
            fetch_ra_opening_proofs: build_fetch_ra_opening_proofs(params, aux, manifest)?,
            decode_ra_opening_proofs: build_decode_ra_opening_proofs(params, aux, manifest)?,
            alu_ra_opening_proofs: build_alu_ra_opening_proofs(params, aux, manifest)?,
            eq4_ra_opening_proofs: build_eq4_ra_opening_proofs(params, aux, manifest)?,
            rom_table_opening_proofs: build_rom_table_opening_proofs(params, rom_table, manifest)?,
            decode_table_opening_proofs: build_decode_table_opening_proofs(params, decode_table, manifest)?,
            alu_table_opening_proofs: build_alu_table_opening_proofs(params, alu_table, manifest)?,
            eq4_table_opening_proofs: build_eq4_table_opening_proofs(params, eq4_table, manifest)?,
            decode_handoff_opening_proofs: build_decode_handoff_opening_proofs(params, aux, manifest)?,
            reg_twist_opening_proofs: build_reg_twist_opening_proofs(params, aux, manifest)?,
            ram_twist_opening_proofs: build_ram_twist_opening_proofs(params, aux, manifest)?,
        })
    }
}

pub(crate) fn proof_exact_opening_artifacts(proof: &SimpleKernelProof) -> KernelExactOpeningArtifacts<'_> {
    KernelExactOpeningArtifacts {
        lane_commitments: &proof.lane_commitments,
        fetch_ra_commitments: &proof.fetch_ra_commitments,
        decode_ra_commitments: &proof.decode_ra_commitments,
        alu_ra_commitments: &proof.alu_ra_commitments,
        eq4_ra_commitments: &proof.eq4_ra_commitments,
        rom_table_commitments: &proof.rom_table_commitments,
        decode_table_commitments: &proof.decode_table_commitments,
        alu_table_commitments: &proof.alu_table_commitments,
        eq4_table_commitments: &proof.eq4_table_commitments,
        decode_handoff_commitments: &proof.decode_handoff_commitments,
        reg_twist_commitments: &proof.reg_twist_commitments,
        ram_twist_commitments: &proof.ram_twist_commitments,
        lane_opening_proofs: &proof.lane_opening_proofs,
        fetch_ra_opening_proofs: &proof.fetch_ra_opening_proofs,
        decode_ra_opening_proofs: &proof.decode_ra_opening_proofs,
        alu_ra_opening_proofs: &proof.alu_ra_opening_proofs,
        eq4_ra_opening_proofs: &proof.eq4_ra_opening_proofs,
        rom_table_opening_proofs: &proof.rom_table_opening_proofs,
        decode_table_opening_proofs: &proof.decode_table_opening_proofs,
        alu_table_opening_proofs: &proof.alu_table_opening_proofs,
        eq4_table_opening_proofs: &proof.eq4_table_opening_proofs,
        decode_handoff_opening_proofs: &proof.decode_handoff_opening_proofs,
        reg_twist_opening_proofs: &proof.reg_twist_opening_proofs,
        ram_twist_opening_proofs: &proof.ram_twist_opening_proofs,
    }
}

pub(crate) fn verify_expected_commitments(
    params: &NeoParams,
    proof: &SimpleKernelProof,
    trace_rows: &[[F; WITNESS_WIDTH]],
    aux: &[KernelStepAux],
    rom_table: &[F],
    decode_table: &[Vec<F>],
    alu_table: &[F],
    eq4_table: &[F],
) -> Result<KernelCommitments, SimpleKernelError> {
    let manifest = &proof.kernel_opening_manifest;
    let expected_lane_digest = verify_lane_commitment_artifacts(
        params,
        trace_rows,
        manifest,
        &proof.lane_commitments,
        &proof.lane_opening_proofs,
    )?;
    let expected_fetch_ra_digest = verify_fetch_ra_commitment_artifacts(
        params,
        aux,
        manifest,
        &proof.fetch_ra_commitments,
        &proof.fetch_ra_opening_proofs,
    )?;
    let expected_decode_ra_digest = verify_decode_ra_commitment_artifacts(
        params,
        aux,
        manifest,
        &proof.decode_ra_commitments,
        &proof.decode_ra_opening_proofs,
    )?;
    let expected_alu_ra_digest = verify_alu_ra_commitment_artifacts(
        params,
        aux,
        manifest,
        &proof.alu_ra_commitments,
        &proof.alu_ra_opening_proofs,
    )?;
    let expected_eq4_ra_digest = verify_eq4_ra_commitment_artifacts(
        params,
        aux,
        manifest,
        &proof.eq4_ra_commitments,
        &proof.eq4_ra_opening_proofs,
    )?;
    let expected_rom_table_digest = verify_rom_table_commitment_artifacts(
        params,
        rom_table,
        manifest,
        &proof.rom_table_commitments,
        &proof.rom_table_opening_proofs,
    )?;
    let expected_decode_table_digest = verify_decode_table_commitment_artifacts(
        params,
        decode_table,
        manifest,
        &proof.decode_table_commitments,
        &proof.decode_table_opening_proofs,
    )?;
    let expected_alu_table_digest = verify_alu_table_commitment_artifacts(
        params,
        alu_table,
        manifest,
        &proof.alu_table_commitments,
        &proof.alu_table_opening_proofs,
    )?;
    let expected_eq4_table_digest = verify_eq4_table_commitment_artifacts(
        params,
        eq4_table,
        manifest,
        &proof.eq4_table_commitments,
        &proof.eq4_table_opening_proofs,
    )?;
    let expected_decode_handoff_digest = verify_decode_handoff_commitment_artifacts(
        params,
        aux,
        manifest,
        &proof.decode_handoff_commitments,
        &proof.decode_handoff_opening_proofs,
    )?;
    let expected_reg_twist_digest = verify_reg_twist_commitment_artifacts(
        params,
        aux,
        manifest,
        &proof.reg_twist_commitments,
        &proof.reg_twist_opening_proofs,
    )?;
    let expected_ram_twist_digest = verify_ram_twist_commitment_artifacts(
        params,
        aux,
        manifest,
        &proof.ram_twist_commitments,
        &proof.ram_twist_opening_proofs,
    )?;
    Ok(build_kernel_commitments(
        expected_lane_digest,
        expected_fetch_ra_digest,
        expected_decode_ra_digest,
        expected_alu_ra_digest,
        expected_eq4_ra_digest,
        expected_rom_table_digest,
        expected_decode_table_digest,
        expected_alu_table_digest,
        expected_eq4_table_digest,
        expected_decode_handoff_digest,
        expected_reg_twist_digest,
        expected_ram_twist_digest,
    ))
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
