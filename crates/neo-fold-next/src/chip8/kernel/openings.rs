//! Owns the CHIP-8 opening boundary: theorem-facing claims, manifest ordering, and exact-opening refinements.

use neo_math::{KExtensions, F, K};
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::{PrimeCharacteristicRing, PrimeField64};

use crate::chip8::poly::{mle_eval_f_le, open_onehot_at_point_be as poly_open_onehot_at_point_be};
use crate::chip8::spec::CommitmentId;
use crate::chip8::{
    stage1::{Stage1ShoutProof, DECODE_HANDOFF_POLY_IDS, STAGE1_LANE_OPEN_COLS},
    stage2::{Stage2TwistProof, RAM_TWIST_POLY_IDS, REG_TWIST_POLY_IDS, STAGE2_LANE_OPEN_COLS},
    stage3::{Stage3Proof, STAGE3_FINAL_BOUNDARY_COLS, STAGE3_SHIFT_OPEN_COLS, STAGE3_START_BOUNDARY_COLS},
};
use crate::opening::{OpeningClaim, OpeningDomain, OpeningSource};

use super::{KernelStepAux, SimpleKernelError};

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum KernelOpeningSource {
    Kernel,
    Root,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct KernelOpeningClaim {
    pub source: KernelOpeningSource,
    pub commitment_id: CommitmentId,
    pub point: Vec<K>,
    pub polynomial_ids: Vec<usize>,
    pub claimed_values: Vec<K>,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct KernelOpeningManifest {
    pub claims: Vec<KernelOpeningClaim>,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct RootOpeningManifest {
    pub claims: Vec<KernelOpeningClaim>,
    pub digest: [u8; 32],
}

fn opening_source_tag(source: KernelOpeningSource) -> u64 {
    match source {
        KernelOpeningSource::Kernel => 1,
        KernelOpeningSource::Root => 2,
    }
}

pub(crate) fn opening_commitment_id_key(commitment_id: CommitmentId) -> (u64, u64) {
    match commitment_id {
        CommitmentId::Lane => (1, 0),
        CommitmentId::FetchRa => (2, 0),
        CommitmentId::DecodeRa => (3, 0),
        CommitmentId::AluRa => (4, 0),
        CommitmentId::Eq4Ra => (5, 0),
        CommitmentId::DecodeHandoff => (6, 0),
        CommitmentId::RegTwist => (7, 0),
        CommitmentId::RamTwist => (8, 0),
        CommitmentId::RomTable => (9, 0),
        CommitmentId::DecodeTable => (10, 0),
        CommitmentId::AluTable => (11, 0),
        CommitmentId::Eq4Table => (12, 0),
        CommitmentId::RootProver(tag) => (13, tag),
    }
}

fn opening_claim_ordinal(commitment_id: CommitmentId) -> u64 {
    let (order, root_tag) = opening_commitment_id_key(commitment_id);
    (order << 32) | root_tag
}

pub(crate) fn is_kernel_commitment_id(commitment_id: CommitmentId) -> bool {
    !matches!(commitment_id, CommitmentId::RootProver(_))
}

pub(crate) fn is_root_commitment_id(commitment_id: CommitmentId) -> bool {
    matches!(commitment_id, CommitmentId::RootProver(_))
}

fn append_k_point(tr: &mut Poseidon2Transcript, label: &'static [u8], point: &[K]) {
    tr.append_u64s(b"neo.fold.next/chip8/opening/point_len", &[point.len() as u64]);
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
    tr.append_u64s(b"neo.fold.next/chip8/opening/value_len", &[values.len() as u64]);
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

fn point_coord_key(point: &[K]) -> Vec<[u64; 2]> {
    point
        .iter()
        .map(|value| {
            let coeffs = value.as_coeffs();
            [coeffs[0].as_canonical_u64(), coeffs[1].as_canonical_u64()]
        })
        .collect()
}

pub(crate) fn normalize_polynomial_ids(polynomial_ids: &[usize]) -> Vec<usize> {
    let mut ids = polynomial_ids.to_vec();
    ids.sort_unstable();
    ids
}

pub(crate) fn normalize_opening_pairs(polynomial_ids: &[usize], claimed_values: &[K]) -> (Vec<usize>, Vec<K>) {
    debug_assert_eq!(
        polynomial_ids.len(),
        claimed_values.len(),
        "opening polynomial/value arity mismatch"
    );
    let mut pairs: Vec<_> = polynomial_ids
        .iter()
        .copied()
        .zip(claimed_values.iter().copied())
        .collect();
    pairs.sort_by_key(|(poly_id, _)| *poly_id);
    let normalized_ids = pairs.iter().map(|(poly_id, _)| *poly_id).collect();
    let normalized_values = pairs.into_iter().map(|(_, value)| value).collect();
    (normalized_ids, normalized_values)
}

pub(crate) fn kernel_opening_claim_cmp(left: &KernelOpeningClaim, right: &KernelOpeningClaim) -> core::cmp::Ordering {
    (
        opening_source_tag(left.source),
        opening_commitment_id_key(left.commitment_id),
        left.point.len(),
        point_coord_key(&left.point),
        &left.polynomial_ids,
    )
        .cmp(&(
            opening_source_tag(right.source),
            opening_commitment_id_key(right.commitment_id),
            right.point.len(),
            point_coord_key(&right.point),
            &right.polynomial_ids,
        ))
}

fn manifest_digest(domain: &'static [u8], claims: &[KernelOpeningClaim]) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(domain);
    tr.append_u64s(b"neo.fold.next/chip8/opening_manifest/len", &[claims.len() as u64]);
    for claim in claims {
        tr.append_message(b"neo.fold.next/chip8/opening_manifest/claim_digest", &claim.digest);
    }
    tr.digest32()
}

impl KernelOpeningClaim {
    fn with_source(
        source: KernelOpeningSource,
        commitment_id: CommitmentId,
        point: Vec<K>,
        polynomial_ids: Vec<usize>,
        claimed_values: Vec<K>,
    ) -> Self {
        let (polynomial_ids, claimed_values) = normalize_opening_pairs(&polynomial_ids, &claimed_values);
        let mut claim = Self {
            source,
            commitment_id,
            point,
            polynomial_ids,
            claimed_values,
            digest: [0; 32],
        };
        claim.digest = claim.expected_digest();
        claim
    }

    pub fn kernel(
        commitment_id: CommitmentId,
        point: Vec<K>,
        polynomial_ids: Vec<usize>,
        claimed_values: Vec<K>,
    ) -> Self {
        debug_assert!(is_kernel_commitment_id(commitment_id));
        Self::with_source(
            KernelOpeningSource::Kernel,
            commitment_id,
            point,
            polynomial_ids,
            claimed_values,
        )
    }

    pub fn root(tag: u64, point: Vec<K>, polynomial_ids: Vec<usize>, claimed_values: Vec<K>) -> Self {
        Self::with_source(
            KernelOpeningSource::Root,
            CommitmentId::RootProver(tag),
            point,
            polynomial_ids,
            claimed_values,
        )
    }

    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/opening_claim");
        let (commitment_order, root_tag) = opening_commitment_id_key(self.commitment_id);
        tr.append_u64s(
            b"neo.fold.next/chip8/opening/meta",
            &[
                opening_source_tag(self.source),
                commitment_order,
                root_tag,
                self.point.len() as u64,
                self.polynomial_ids.len() as u64,
                self.claimed_values.len() as u64,
            ],
        );
        append_k_point(&mut tr, b"neo.fold.next/chip8/opening/point", &self.point);
        let polynomial_ids_u64: Vec<u64> = self.polynomial_ids.iter().map(|&id| id as u64).collect();
        tr.append_u64s(b"neo.fold.next/chip8/opening/polynomial_ids", &polynomial_ids_u64);
        append_k_values(
            &mut tr,
            b"neo.fold.next/chip8/opening/claimed_values",
            &self.claimed_values,
        );
        tr.digest32()
    }
}

impl KernelOpeningManifest {
    pub fn new() -> Self {
        let claims = Vec::new();
        let digest = manifest_digest(b"neo.fold.next/chip8/kernel_opening_manifest", &claims);
        Self { claims, digest }
    }

    pub fn push(&mut self, claim: KernelOpeningClaim) {
        self.claims.push(claim);
    }

    pub fn push_kernel(
        &mut self,
        commitment_id: CommitmentId,
        point: Vec<K>,
        polynomial_ids: Vec<usize>,
        claimed_values: Vec<K>,
    ) {
        self.push(KernelOpeningClaim::kernel(
            commitment_id,
            point,
            polynomial_ids,
            claimed_values,
        ));
    }

    pub fn expected_digest(&self) -> [u8; 32] {
        manifest_digest(b"neo.fold.next/chip8/kernel_opening_manifest", &self.claims)
    }

    pub fn canonicalize(&mut self) {
        self.claims.sort_by(kernel_opening_claim_cmp);
        self.claims.dedup_by(|left, right| {
            left.source == right.source
                && left.commitment_id == right.commitment_id
                && left.point == right.point
                && left.polynomial_ids == right.polynomial_ids
                && left.claimed_values == right.claimed_values
                && left.digest == right.digest
        });
        self.digest = self.expected_digest();
    }
}

impl Default for KernelOpeningManifest {
    fn default() -> Self {
        Self::new()
    }
}

impl RootOpeningManifest {
    pub fn new() -> Self {
        let claims = Vec::new();
        let digest = manifest_digest(b"neo.fold.next/chip8/root_opening_manifest", &claims);
        Self { claims, digest }
    }

    pub fn push(&mut self, claim: KernelOpeningClaim) {
        self.claims.push(claim);
    }

    pub fn push_root(&mut self, tag: u64, point: Vec<K>, polynomial_ids: Vec<usize>, claimed_values: Vec<K>) {
        self.push(KernelOpeningClaim::root(tag, point, polynomial_ids, claimed_values));
    }

    pub fn expected_digest(&self) -> [u8; 32] {
        manifest_digest(b"neo.fold.next/chip8/root_opening_manifest", &self.claims)
    }

    pub fn canonicalize(&mut self) {
        self.claims.sort_by(kernel_opening_claim_cmp);
        self.claims.dedup_by(|left, right| {
            left.source == right.source
                && left.commitment_id == right.commitment_id
                && left.point == right.point
                && left.polynomial_ids == right.polynomial_ids
                && left.claimed_values == right.claimed_values
                && left.digest == right.digest
        });
        self.digest = self.expected_digest();
    }
}

impl Default for RootOpeningManifest {
    fn default() -> Self {
        Self::new()
    }
}

fn time_opening_source(source: KernelOpeningSource) -> OpeningSource {
    match source {
        KernelOpeningSource::Kernel => OpeningSource::Chip8Kernel,
        KernelOpeningSource::Root => OpeningSource::Chip8Root,
    }
}

pub(crate) fn time_opening_domain(commitment_id: CommitmentId) -> OpeningDomain {
    match commitment_id {
        CommitmentId::RegTwist | CommitmentId::RamTwist => OpeningDomain::Mem,
        CommitmentId::Lane
        | CommitmentId::FetchRa
        | CommitmentId::DecodeRa
        | CommitmentId::AluRa
        | CommitmentId::Eq4Ra
        | CommitmentId::DecodeHandoff
        | CommitmentId::RomTable
        | CommitmentId::DecodeTable
        | CommitmentId::AluTable
        | CommitmentId::Eq4Table
        | CommitmentId::RootProver(_) => OpeningDomain::Cpu,
    }
}

pub(crate) fn as_time_opening_claim(claim: &KernelOpeningClaim) -> OpeningClaim {
    OpeningClaim {
        source: time_opening_source(claim.source),
        domain: time_opening_domain(claim.commitment_id),
        point: claim.point.clone(),
        ordinal: opening_claim_ordinal(claim.commitment_id),
        column_ids: claim.polynomial_ids.iter().map(|&id| id as u32).collect(),
        digest: claim.digest,
    }
}

pub(crate) fn time_opening_claims(
    kernel_manifest: &KernelOpeningManifest,
    root_manifest: &RootOpeningManifest,
) -> Vec<OpeningClaim> {
    let mut claims = Vec::with_capacity(kernel_manifest.claims.len() + root_manifest.claims.len());
    claims.extend(kernel_manifest.claims.iter().map(as_time_opening_claim));
    claims.extend(root_manifest.claims.iter().map(as_time_opening_claim));
    claims
}

pub(crate) fn lane_poly_ids(cols: &[usize]) -> Vec<usize> {
    cols.to_vec()
}

pub(crate) fn commitment_polynomial_slot(
    commitment_id: CommitmentId,
    polynomial_id: usize,
) -> Result<usize, SimpleKernelError> {
    match commitment_id {
        CommitmentId::Lane => polynomial_id
            .checked_sub(1)
            .ok_or_else(|| SimpleKernelError::OpeningFailed("lane opening references invalid polynomial id 0".into())),
        _ => Ok(polynomial_id),
    }
}

pub(crate) fn mle_eval_vec(values: &[F], point: &[K]) -> K {
    mle_eval_f_le(values, point)
}

pub(crate) fn bits_point(index: usize, cycle_bits: usize) -> Vec<K> {
    (0..cycle_bits)
        .map(|bit| if (index >> bit) & 1 == 1 { K::ONE } else { K::ZERO })
        .collect()
}

pub(crate) fn open_onehot_at_point_be(addresses: &[usize], addr_point_be: &[K], cycle_point: &[K]) -> K {
    poly_open_onehot_at_point_be(addresses, addr_point_be, cycle_point)
}

pub(crate) fn build_kernel_opening_manifest(
    aux: &[KernelStepAux],
    active_rows: usize,
    cycle_bits: usize,
    stage1: &Stage1ShoutProof,
    stage2: &Stage2TwistProof,
    stage3: &Stage3Proof,
) -> KernelOpeningManifest {
    let mut manifest = KernelOpeningManifest::new();

    manifest.push_kernel(
        CommitmentId::Lane,
        stage1.cycle_point.clone(),
        lane_poly_ids(&STAGE1_LANE_OPEN_COLS),
        stage1.lane_values_at_lookup.clone(),
    );
    manifest.push_kernel(
        CommitmentId::FetchRa,
        stage1
            .fetch_proof
            .addr_point
            .iter()
            .copied()
            .chain(stage1.cycle_point.iter().copied())
            .collect(),
        vec![0],
        vec![stage1.fetch_proof.address_opening_value],
    );
    manifest.push_kernel(
        CommitmentId::DecodeRa,
        stage1
            .decode_proof
            .addr_point
            .iter()
            .copied()
            .chain(stage1.cycle_point.iter().copied())
            .collect(),
        vec![0],
        vec![stage1.decode_proof.address_opening_value],
    );
    manifest.push_kernel(
        CommitmentId::AluRa,
        stage1
            .alu_proof
            .addr_point
            .iter()
            .copied()
            .chain(stage1.cycle_point.iter().copied())
            .collect(),
        vec![0],
        vec![stage1.alu_proof.address_opening_value],
    );
    manifest.push_kernel(
        CommitmentId::Eq4Ra,
        stage1
            .eq4_proof
            .addr_point
            .iter()
            .copied()
            .chain(stage1.cycle_point.iter().copied())
            .collect(),
        vec![0],
        vec![stage1.eq4_proof.address_opening_value],
    );
    manifest.push_kernel(
        CommitmentId::DecodeHandoff,
        stage1.cycle_point.clone(),
        DECODE_HANDOFF_POLY_IDS.to_vec(),
        stage1.decode_handoff_values.clone(),
    );
    manifest.push_kernel(
        CommitmentId::RomTable,
        stage1.fetch_proof.addr_point.clone(),
        vec![0],
        stage1.fetch_proof.table_opening_values.clone(),
    );
    manifest.push_kernel(
        CommitmentId::DecodeTable,
        stage1.decode_proof.addr_point.clone(),
        (0..stage1.decode_proof.table_opening_values.len()).collect(),
        stage1.decode_proof.table_opening_values.clone(),
    );
    manifest.push_kernel(
        CommitmentId::AluTable,
        stage1.alu_proof.addr_point[2..].to_vec(),
        vec![0],
        stage1.alu_proof.table_opening_values.clone(),
    );
    manifest.push_kernel(
        CommitmentId::Eq4Table,
        stage1.eq4_proof.addr_point.clone(),
        vec![0],
        stage1.eq4_proof.table_opening_values.clone(),
    );
    manifest.push_kernel(
        CommitmentId::Lane,
        stage2.cycle_point.clone(),
        lane_poly_ids(&STAGE2_LANE_OPEN_COLS),
        stage2.lane_values_at_twist.clone(),
    );
    manifest.push_kernel(
        CommitmentId::DecodeHandoff,
        stage2.cycle_point.clone(),
        DECODE_HANDOFF_POLY_IDS.to_vec(),
        stage2.handoff_values_at_twist.clone(),
    );
    let reg_point: Vec<K> = stage2
        .reg_addr_point
        .iter()
        .copied()
        .chain(stage2.cycle_point.iter().copied())
        .collect();
    manifest.push_kernel(
        CommitmentId::RegTwist,
        reg_point,
        REG_TWIST_POLY_IDS.to_vec(),
        vec![
            mle_eval_vec(
                &aux.iter().map(|step| step.reg_inc).collect::<Vec<_>>(),
                &stage2.cycle_point,
            ),
            open_onehot_at_point_be(
                &aux.iter()
                    .map(|step| step.reg_ra_x_addr)
                    .collect::<Vec<_>>(),
                &stage2.reg_addr_point,
                &stage2.cycle_point,
            ),
            open_onehot_at_point_be(
                &aux.iter()
                    .map(|step| step.reg_ra_y_addr)
                    .collect::<Vec<_>>(),
                &stage2.reg_addr_point,
                &stage2.cycle_point,
            ),
            open_onehot_at_point_be(
                &aux.iter()
                    .map(|step| step.reg_ra_i_addr)
                    .collect::<Vec<_>>(),
                &stage2.reg_addr_point,
                &stage2.cycle_point,
            ),
            open_onehot_at_point_be(
                &aux.iter().map(|step| step.reg_wa_addr).collect::<Vec<_>>(),
                &stage2.reg_addr_point,
                &stage2.cycle_point,
            ),
        ],
    );
    let ram_point: Vec<K> = stage2
        .ram_addr_point
        .iter()
        .copied()
        .chain(stage2.cycle_point.iter().copied())
        .collect();
    manifest.push_kernel(
        CommitmentId::RamTwist,
        ram_point,
        RAM_TWIST_POLY_IDS.to_vec(),
        vec![
            mle_eval_vec(
                &aux.iter().map(|step| step.ram_inc).collect::<Vec<_>>(),
                &stage2.cycle_point,
            ),
            open_onehot_at_point_be(
                &aux.iter().map(|step| step.ram_ra_addr).collect::<Vec<_>>(),
                &stage2.ram_addr_point,
                &stage2.cycle_point,
            ),
            open_onehot_at_point_be(
                &aux.iter().map(|step| step.ram_wa_addr).collect::<Vec<_>>(),
                &stage2.ram_addr_point,
                &stage2.cycle_point,
            ),
        ],
    );
    manifest.push_kernel(
        CommitmentId::Lane,
        stage3.shift_proof.source_point.clone(),
        lane_poly_ids(&STAGE3_SHIFT_OPEN_COLS),
        stage3.shift_opening_values.to_vec(),
    );
    manifest.push_kernel(
        CommitmentId::Lane,
        vec![K::ZERO; cycle_bits],
        lane_poly_ids(&STAGE3_START_BOUNDARY_COLS),
        stage3.start_boundary_values.to_vec(),
    );

    let last_row = active_rows - 1;
    manifest.push_kernel(
        CommitmentId::Lane,
        bits_point(last_row, cycle_bits),
        lane_poly_ids(&STAGE3_FINAL_BOUNDARY_COLS),
        stage3.final_boundary_values.to_vec(),
    );

    let row_binding_ids: Vec<usize> = (1..=23).collect();
    for row in &stage3.row_bindings {
        manifest.push_kernel(
            CommitmentId::Lane,
            row.row_bits
                .iter()
                .map(|&bit| if bit { K::ONE } else { K::ZERO })
                .collect(),
            row_binding_ids.clone(),
            row.opened_values.clone(),
        );
    }

    manifest.canonicalize();
    manifest
}

use neo_ajtai::Commitment;
use neo_math::D;

use super::lane_commitment::{recompose_time_vector_digits_to_scalar, TimeVectorOpeningProof};
use super::{
    AluRaCommitmentSet, AluRaOpeningProof, AluTableCommitmentSet, AluTableOpeningProof, DecodeHandoffCommitmentSet,
    DecodeHandoffOpeningProof, DecodeRaCommitmentSet, DecodeRaOpeningProof, DecodeTableCommitmentSet,
    DecodeTableOpeningProof, Eq4RaCommitmentSet, Eq4RaOpeningProof, Eq4TableCommitmentSet, Eq4TableOpeningProof,
    FetchRaCommitmentSet, FetchRaOpeningProof, LaneCommitmentSet, LaneOpeningProof, RamTwistCommitmentSet,
    RamTwistOpeningProof, RegTwistCommitmentSet, RegTwistOpeningProof, RomTableCommitmentSet, RomTableOpeningProof,
};

#[derive(Clone, Debug, PartialEq)]
pub struct KernelOpeningRefinement {
    pub commitment_id: CommitmentId,
    pub point: Vec<K>,
    pub polynomial_ids: Vec<usize>,
    pub claim_digest: [u8; 32],
    pub opening_proof_digest: [u8; 32],
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelOpeningRefinementSummary {
    pub refinements: Vec<KernelOpeningRefinement>,
    pub digest: [u8; 32],
}

pub(crate) struct KernelExactOpeningArtifacts<'a> {
    pub lane_commitments: &'a LaneCommitmentSet,
    pub fetch_ra_commitments: &'a FetchRaCommitmentSet,
    pub decode_ra_commitments: &'a DecodeRaCommitmentSet,
    pub alu_ra_commitments: &'a AluRaCommitmentSet,
    pub eq4_ra_commitments: &'a Eq4RaCommitmentSet,
    pub rom_table_commitments: &'a RomTableCommitmentSet,
    pub decode_table_commitments: &'a DecodeTableCommitmentSet,
    pub alu_table_commitments: &'a AluTableCommitmentSet,
    pub eq4_table_commitments: &'a Eq4TableCommitmentSet,
    pub decode_handoff_commitments: &'a DecodeHandoffCommitmentSet,
    pub reg_twist_commitments: &'a RegTwistCommitmentSet,
    pub ram_twist_commitments: &'a RamTwistCommitmentSet,
    pub lane_opening_proofs: &'a [LaneOpeningProof],
    pub fetch_ra_opening_proofs: &'a [FetchRaOpeningProof],
    pub decode_ra_opening_proofs: &'a [DecodeRaOpeningProof],
    pub alu_ra_opening_proofs: &'a [AluRaOpeningProof],
    pub eq4_ra_opening_proofs: &'a [Eq4RaOpeningProof],
    pub rom_table_opening_proofs: &'a [RomTableOpeningProof],
    pub decode_table_opening_proofs: &'a [DecodeTableOpeningProof],
    pub alu_table_opening_proofs: &'a [AluTableOpeningProof],
    pub eq4_table_opening_proofs: &'a [Eq4TableOpeningProof],
    pub decode_handoff_opening_proofs: &'a [DecodeHandoffOpeningProof],
    pub reg_twist_opening_proofs: &'a [RegTwistOpeningProof],
    pub ram_twist_opening_proofs: &'a [RamTwistOpeningProof],
}

pub(crate) struct KernelExactClaimWitness {
    pub claim: KernelOpeningClaim,
    pub refinement: KernelOpeningRefinement,
    pub claim_commitments: Vec<Commitment>,
    pub proof: TimeVectorOpeningProof,
}

impl KernelOpeningRefinement {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/opening_refinement");
        let (commitment_order, root_tag) = opening_commitment_id_key(self.commitment_id);
        tr.append_u64s(
            b"neo.fold.next/chip8/opening_refinement/meta",
            &[
                commitment_order,
                root_tag,
                self.point.len() as u64,
                self.polynomial_ids.len() as u64,
            ],
        );
        append_point(&mut tr, b"neo.fold.next/chip8/opening_refinement/point", &self.point);
        let polynomial_ids_u64: Vec<u64> = self.polynomial_ids.iter().map(|&id| id as u64).collect();
        tr.append_u64s(
            b"neo.fold.next/chip8/opening_refinement/polynomial_ids",
            &polynomial_ids_u64,
        );
        tr.append_message(
            b"neo.fold.next/chip8/opening_refinement/claim_digest",
            &self.claim_digest,
        );
        tr.append_message(
            b"neo.fold.next/chip8/opening_refinement/opening_proof_digest",
            &self.opening_proof_digest,
        );
        tr.digest32()
    }
}

impl KernelOpeningRefinementSummary {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/opening_refinement_summary");
        tr.append_u64s(
            b"neo.fold.next/chip8/opening_refinement_summary/len",
            &[self.refinements.len() as u64],
        );
        for refinement in &self.refinements {
            tr.append_message(
                b"neo.fold.next/chip8/opening_refinement_summary/refinement_digest",
                &refinement.digest,
            );
        }
        tr.digest32()
    }
}

pub(crate) fn collect_exact_claim_witnesses(
    manifest: &KernelOpeningManifest,
    artifacts: KernelExactOpeningArtifacts<'_>,
) -> Result<Vec<KernelExactClaimWitness>, SimpleKernelError> {
    let mut lane_idx = 0usize;
    let mut fetch_idx = 0usize;
    let mut decode_idx = 0usize;
    let mut alu_idx = 0usize;
    let mut eq4_idx = 0usize;
    let mut rom_idx = 0usize;
    let mut decode_table_idx = 0usize;
    let mut alu_table_idx = 0usize;
    let mut eq4_table_idx = 0usize;
    let mut handoff_idx = 0usize;
    let mut reg_idx = 0usize;
    let mut ram_idx = 0usize;
    let mut out = Vec::with_capacity(manifest.claims.len());

    for claim in &manifest.claims {
        let witness = match claim.commitment_id {
            CommitmentId::Lane => make_exact_claim_witness(
                claim,
                &artifacts.lane_commitments.commitments,
                take_proof(artifacts.lane_opening_proofs, &mut lane_idx, "lane")?,
            )?,
            CommitmentId::FetchRa => make_exact_claim_witness(
                claim,
                &artifacts.fetch_ra_commitments.commitments,
                take_proof(artifacts.fetch_ra_opening_proofs, &mut fetch_idx, "fetch-ra")?,
            )?,
            CommitmentId::DecodeRa => make_exact_claim_witness(
                claim,
                &artifacts.decode_ra_commitments.commitments,
                take_proof(artifacts.decode_ra_opening_proofs, &mut decode_idx, "decode-ra")?,
            )?,
            CommitmentId::AluRa => make_exact_claim_witness(
                claim,
                &artifacts.alu_ra_commitments.commitments,
                take_proof(artifacts.alu_ra_opening_proofs, &mut alu_idx, "alu-ra")?,
            )?,
            CommitmentId::Eq4Ra => make_exact_claim_witness(
                claim,
                &artifacts.eq4_ra_commitments.commitments,
                take_proof(artifacts.eq4_ra_opening_proofs, &mut eq4_idx, "eq4-ra")?,
            )?,
            CommitmentId::RomTable => make_exact_claim_witness(
                claim,
                &artifacts.rom_table_commitments.commitments,
                take_proof(artifacts.rom_table_opening_proofs, &mut rom_idx, "rom-table")?,
            )?,
            CommitmentId::DecodeTable => make_exact_claim_witness(
                claim,
                &artifacts.decode_table_commitments.commitments,
                take_proof(
                    artifacts.decode_table_opening_proofs,
                    &mut decode_table_idx,
                    "decode-table",
                )?,
            )?,
            CommitmentId::AluTable => make_exact_claim_witness(
                claim,
                &artifacts.alu_table_commitments.commitments,
                take_proof(artifacts.alu_table_opening_proofs, &mut alu_table_idx, "alu-table")?,
            )?,
            CommitmentId::Eq4Table => make_exact_claim_witness(
                claim,
                &artifacts.eq4_table_commitments.commitments,
                take_proof(artifacts.eq4_table_opening_proofs, &mut eq4_table_idx, "eq4-table")?,
            )?,
            CommitmentId::DecodeHandoff => make_exact_claim_witness(
                claim,
                &artifacts.decode_handoff_commitments.commitments,
                take_proof(
                    artifacts.decode_handoff_opening_proofs,
                    &mut handoff_idx,
                    "decode-handoff",
                )?,
            )?,
            CommitmentId::RegTwist => make_exact_claim_witness(
                claim,
                &artifacts.reg_twist_commitments.commitments,
                take_proof(artifacts.reg_twist_opening_proofs, &mut reg_idx, "reg-twist")?,
            )?,
            CommitmentId::RamTwist => make_exact_claim_witness(
                claim,
                &artifacts.ram_twist_commitments.commitments,
                take_proof(artifacts.ram_twist_opening_proofs, &mut ram_idx, "ram-twist")?,
            )?,
            CommitmentId::RootProver(_) => {
                return Err(SimpleKernelError::OpeningFailed(
                    "kernel opening refinements do not support root-owned claims".into(),
                ));
            }
        };
        out.push(witness);
    }

    expect_all_consumed(artifacts.lane_opening_proofs, lane_idx, "lane")?;
    expect_all_consumed(artifacts.fetch_ra_opening_proofs, fetch_idx, "fetch-ra")?;
    expect_all_consumed(artifacts.decode_ra_opening_proofs, decode_idx, "decode-ra")?;
    expect_all_consumed(artifacts.alu_ra_opening_proofs, alu_idx, "alu-ra")?;
    expect_all_consumed(artifacts.eq4_ra_opening_proofs, eq4_idx, "eq4-ra")?;
    expect_all_consumed(artifacts.rom_table_opening_proofs, rom_idx, "rom-table")?;
    expect_all_consumed(artifacts.decode_table_opening_proofs, decode_table_idx, "decode-table")?;
    expect_all_consumed(artifacts.alu_table_opening_proofs, alu_table_idx, "alu-table")?;
    expect_all_consumed(artifacts.eq4_table_opening_proofs, eq4_table_idx, "eq4-table")?;
    expect_all_consumed(artifacts.decode_handoff_opening_proofs, handoff_idx, "decode-handoff")?;
    expect_all_consumed(artifacts.reg_twist_opening_proofs, reg_idx, "reg-twist")?;
    expect_all_consumed(artifacts.ram_twist_opening_proofs, ram_idx, "ram-twist")?;
    Ok(out)
}

pub(crate) fn build_kernel_opening_refinement_summary(
    manifest: &KernelOpeningManifest,
    artifacts: KernelExactOpeningArtifacts<'_>,
) -> Result<KernelOpeningRefinementSummary, SimpleKernelError> {
    let refinements = collect_exact_claim_witnesses(manifest, artifacts)?
        .into_iter()
        .map(|witness| witness.refinement)
        .collect();
    let summary = KernelOpeningRefinementSummary {
        refinements,
        digest: [0; 32],
    };
    Ok(KernelOpeningRefinementSummary {
        digest: summary.expected_digest(),
        ..summary
    })
}

pub(crate) fn verify_kernel_opening_refinement_summary(
    manifest: &KernelOpeningManifest,
    artifacts: KernelExactOpeningArtifacts<'_>,
    summary: &KernelOpeningRefinementSummary,
) -> Result<(), SimpleKernelError> {
    let expected = build_kernel_opening_refinement_summary(manifest, artifacts)?;
    if summary.refinements != expected.refinements {
        return Err(SimpleKernelError::OpeningFailed(
            "kernel opening refinement summary mismatch".into(),
        ));
    }
    if summary.digest != summary.expected_digest() {
        return Err(SimpleKernelError::OpeningFailed(
            "kernel opening refinement summary digest mismatch".into(),
        ));
    }
    Ok(())
}

pub(crate) fn find_refinement_by_claim_digest<'a>(
    summary: &'a KernelOpeningRefinementSummary,
    claim_digest: [u8; 32],
    label: &str,
) -> Result<&'a KernelOpeningRefinement, SimpleKernelError> {
    let mut matches = summary
        .refinements
        .iter()
        .filter(|refinement| refinement.claim_digest == claim_digest);
    let refinement = matches.next().ok_or_else(|| {
        SimpleKernelError::OpeningFailed(format!(
            "{label} missing opening refinement for claim digest {:02x?}",
            claim_digest
        ))
    })?;
    if matches.next().is_some() {
        return Err(SimpleKernelError::OpeningFailed(format!(
            "{label} has non-unique opening refinement for claim digest {:02x?}",
            claim_digest
        )));
    }
    Ok(refinement)
}

fn make_exact_claim_witness(
    claim: &KernelOpeningClaim,
    commitments: &[Commitment],
    proof: &TimeVectorOpeningProof,
) -> Result<KernelExactClaimWitness, SimpleKernelError> {
    if proof.point != claim.point
        || proof.polynomial_ids != claim.polynomial_ids
        || proof.claimed_values != claim.claimed_values
    {
        return Err(SimpleKernelError::OpeningFailed(format!(
            "{} exact opening proof mismatch",
            opening_label(claim.commitment_id)
        )));
    }
    if proof.digit_evals.len() != claim.polynomial_ids.len() {
        return Err(SimpleKernelError::OpeningFailed(format!(
            "{} exact opening digit arity mismatch",
            opening_label(claim.commitment_id)
        )));
    }
    if claim.polynomial_ids.is_empty() {
        return Err(SimpleKernelError::OpeningFailed(format!(
            "{} exact opening claim is empty",
            opening_label(claim.commitment_id)
        )));
    }

    let mut claim_commitments = Vec::with_capacity(claim.polynomial_ids.len());
    for (position, (&poly_id, digits)) in claim
        .polynomial_ids
        .iter()
        .zip(proof.digit_evals.iter())
        .enumerate()
    {
        let slot = commitment_polynomial_slot(claim.commitment_id, poly_id)?;
        let commitment = commitments.get(slot).ok_or_else(|| {
            SimpleKernelError::OpeningFailed(format!(
                "{} opening references out-of-range polynomial id {poly_id}",
                opening_label(claim.commitment_id)
            ))
        })?;
        if digits.len() != D {
            return Err(SimpleKernelError::OpeningFailed(format!(
                "{} exact opening digit width mismatch at position {}",
                opening_label(claim.commitment_id),
                position
            )));
        }
        if recompose_time_vector_digits_to_scalar(digits) != claim.claimed_values[position] {
            return Err(SimpleKernelError::OpeningFailed(format!(
                "{} exact opening value mismatch at position {}",
                opening_label(claim.commitment_id),
                position
            )));
        }
        claim_commitments.push(commitment.clone());
    }

    let refinement = KernelOpeningRefinement {
        commitment_id: claim.commitment_id,
        point: claim.point.clone(),
        polynomial_ids: claim.polynomial_ids.clone(),
        claim_digest: claim.digest,
        opening_proof_digest: proof.expected_digest(),
        digest: [0; 32],
    };
    let refinement = KernelOpeningRefinement {
        digest: refinement.expected_digest(),
        ..refinement
    };
    Ok(KernelExactClaimWitness {
        claim: claim.clone(),
        refinement,
        claim_commitments,
        proof: proof.clone(),
    })
}

fn opening_label(commitment_id: CommitmentId) -> &'static str {
    match commitment_id {
        CommitmentId::Lane => "lane",
        CommitmentId::FetchRa => "fetch-ra",
        CommitmentId::DecodeRa => "decode-ra",
        CommitmentId::AluRa => "alu-ra",
        CommitmentId::Eq4Ra => "eq4-ra",
        CommitmentId::DecodeHandoff => "decode-handoff",
        CommitmentId::RegTwist => "reg-twist",
        CommitmentId::RamTwist => "ram-twist",
        CommitmentId::RomTable => "rom-table",
        CommitmentId::DecodeTable => "decode-table",
        CommitmentId::AluTable => "alu-table",
        CommitmentId::Eq4Table => "eq4-table",
        CommitmentId::RootProver(_) => "root-prover",
    }
}

fn take_proof<'a, T>(proofs: &'a [T], index: &mut usize, label: &str) -> Result<&'a T, SimpleKernelError> {
    let proof = proofs
        .get(*index)
        .ok_or_else(|| SimpleKernelError::OpeningFailed(format!("{label} exact opening proof count mismatch")))?;
    *index += 1;
    Ok(proof)
}

fn expect_all_consumed<T>(proofs: &[T], used: usize, label: &str) -> Result<(), SimpleKernelError> {
    if used == proofs.len() {
        Ok(())
    } else {
        Err(SimpleKernelError::OpeningFailed(format!(
            "{label} exact opening proof count mismatch"
        )))
    }
}

fn append_point(tr: &mut Poseidon2Transcript, label: &'static [u8], point: &[K]) {
    tr.append_u64s(
        b"neo.fold.next/chip8/opening_refinement/point_len",
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
