//! Owns the CHIP-8 simple-kernel proof boundary and root bridge.
//!
//! This file defines the proof/output types from the kernel spec, binds `root0`,
//! builds the kernel opening manifest, and owns bridge reconstruction into the
//! SuperNeo root-step surface. Stage-local proving and transcript replay live in
//! `stage1.rs`, `stage2.rs`, and `stage3.rs`.

use neo_ajtai::Commitment;
use neo_ccs::traits::SModuleHomomorphism;
use neo_ccs::{CcsClaim, CcsWitness};
use neo_math::{from_complex, KExtensions, F, K};
use neo_memory::ajtai::encode_vector_for_ccs_m;
use neo_params::NeoParams;
use neo_reductions::sumcheck::verify_sumcheck_rounds;
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeCharacteristicRing;

use super::spec::{
    build_pad_row, Chip8Program, CommitmentId, CHIP8_PROGRAM_START, COL_BURST_LAST, COL_IS_BRANCH, COL_IS_JUMP,
    COL_IS_MEMOP, COL_I_NEXT, COL_I_REG, COL_KK, COL_LOOKUP_OUTPUT, COL_MEM_VALUE, COL_NNN_ADDR, COL_NNN_WORD, COL_PC,
    COL_PC_NEXT, COL_PRESERVES_X, COL_RAM_ADDR, COL_REG_X, COL_REG_X_NEXT, COL_REG_Y, COL_WRITES_LOOKUP_TO_X,
    COL_WRITES_MEM_TO_X, COL_WRITES_NNN_TO_I, COL_X_IDX, COL_Y_IDX,
};
use super::tables::{
    build_alu_table, build_decode_table, build_eq4_table, build_rom_table, flatten_alu_key, flatten_eq4_key,
    LookupKind, RAM_SINK_ADDR, REG_SINK_ADDR,
};
use super::{stage1, stage2, stage3};

// ---------------------------------------------------------------------------
// Kernel input / output (§9.4)
// ---------------------------------------------------------------------------

pub struct SimpleKernelPublicInput {
    pub program_image: Vec<u8>,
    pub initial_pc_word: u16,
    pub initial_registers: [u8; 16],
    pub initial_i: u16,
    pub initial_ram: Vec<u8>,
    pub transcript_seed: Vec<u8>,
}

pub struct SimpleKernelWitness {
    pub semantic_trace_rows: Vec<[F; 24]>,
    pub semantic_aux_data: Vec<KernelStepAux>,
}

pub struct SimpleKernelProverInput {
    pub public: SimpleKernelPublicInput,
    pub witness: SimpleKernelWitness,
}

pub struct SimpleKernelVerifierInput {
    pub public: SimpleKernelPublicInput,
}

// ---------------------------------------------------------------------------
// Per-step auxiliary data (for stage provers)
// ---------------------------------------------------------------------------

#[derive(Clone, Debug)]
pub struct KernelStepAux {
    pub fetch_addr: usize,
    pub decode_addr: u16,
    pub alu_key: u32,
    pub eq4_key: u8,
    pub reg_ra_x_addr: usize,
    pub reg_ra_y_addr: usize,
    pub reg_ra_i_addr: usize,
    pub reg_wa_addr: usize,
    pub ram_ra_addr: usize,
    pub ram_wa_addr: usize,
    pub reg_inc: F,
    pub ram_inc: F,
    pub uses_y: bool,
    pub reads_ram: bool,
    pub writes_ram: bool,
}

// ---------------------------------------------------------------------------
// Stage proofs (§9.4)
// ---------------------------------------------------------------------------

pub struct ShoutChannelProof {
    pub addr_point: Vec<K>,
    pub sumcheck_rounds: Vec<Vec<K>>,
    pub addr_correctness_rounds: Vec<Vec<K>>,
    pub address_opening_value: K,
    pub read_values_at_cycle: Vec<K>,
    pub table_opening_values: Vec<K>,
}

pub struct Stage1ShoutProof {
    /// r_lookup
    pub cycle_point: Vec<K>,
    pub fetch_proof: ShoutChannelProof,
    pub decode_proof: ShoutChannelProof,
    pub alu_proof: ShoutChannelProof,
    pub eq4_proof: ShoutChannelProof,
    /// 3 values opened at r_lookup
    pub decode_handoff_values: Vec<K>,
    /// 17 lane columns opened at r_lookup
    pub lane_values_at_lookup: Vec<K>,
}

pub struct AddressCorrectnessProof {
    pub booleanity_rounds: Vec<Vec<K>>,
    pub hamming_weight_rounds: Vec<Vec<K>>,
    pub decode_consistency_rounds: Vec<Vec<K>>,
}

pub struct Stage2LinkClaims {
    pub rv_x: K,
    pub rv_y: K,
    pub rv_i: K,
    pub wv_reg: K,
    pub rv_ram: K,
    pub wv_ram: K,
}

pub struct Stage2TwistProof {
    /// r_twist_cycle
    pub cycle_point: Vec<K>,
    /// r_addr_reg (K^5)
    pub reg_addr_point: Vec<K>,
    /// r_addr_ram (K^13)
    pub ram_addr_point: Vec<K>,
    pub gamma_reg: K,
    pub reg_rw_batched_rounds: Vec<Vec<K>>,
    pub reg_val_from_inc_claim: K,
    pub reg_val_from_inc_rounds: Vec<Vec<K>>,
    /// 4: RegRaX, RegRaY, RegRaI, RegWa
    pub reg_addr_correctness: Vec<AddressCorrectnessProof>,
    pub gamma_ram: K,
    pub ram_rw_batched_rounds: Vec<Vec<K>>,
    pub ram_val_from_inc_claim: K,
    pub ram_val_from_inc_rounds: Vec<Vec<K>>,
    pub ram_raf_read_rounds: Vec<Vec<K>>,
    pub ram_raf_write_rounds: Vec<Vec<K>>,
    /// 2: RamRa, RamWa
    pub ram_addr_correctness: Vec<AddressCorrectnessProof>,
    pub link_claims: Stage2LinkClaims,
    pub gamma_twist_link: K,
    pub linkage_batch_value: K,
    /// 14 deduplicated lane columns at r_twist_cycle
    pub lane_values_at_twist: Vec<K>,
    /// 3 decode-handoff at r_twist_cycle
    pub handoff_values_at_twist: Vec<K>,
}

pub struct LaneShiftProof {
    /// r_shift
    pub source_point: Vec<K>,
    /// [shift_pc, shift_x_idx, shift_is_memop]
    pub claimed_shift_values: [K; 3],
    pub reduction_rounds: Vec<Vec<K>>,
}

pub struct RowBindingClaim {
    pub row_index: usize,
    pub row_bits: Vec<bool>,
    /// 23 non-fixed lane column values
    pub opened_values: Vec<K>,
}

pub struct Stage3Proof {
    pub shift_proof: LaneShiftProof,
    /// [PC(r_shift), PC_NEXT(r_shift), X_IDX(r_shift), IsMemOp(r_shift), BURST_LAST(r_shift)]
    pub shift_opening_values: [K; 5],
    pub continuity_check_value: K,
    /// [IsMemOp(0), X_IDX(0)]
    pub start_boundary_values: [K; 2],
    /// [IsMemOp(N-1), BURST_LAST(N-1)]
    pub final_boundary_values: [K; 2],
    pub row_bindings: Vec<RowBindingClaim>,
}

pub const STAGE1_LANE_OPEN_COLS: [usize; 17] = [
    COL_PC,
    COL_KK,
    COL_NNN_ADDR,
    COL_NNN_WORD,
    COL_REG_X,
    COL_REG_Y,
    COL_LOOKUP_OUTPUT,
    COL_WRITES_LOOKUP_TO_X,
    COL_WRITES_MEM_TO_X,
    COL_PRESERVES_X,
    COL_WRITES_NNN_TO_I,
    COL_IS_JUMP,
    COL_IS_BRANCH,
    COL_IS_MEMOP,
    COL_X_IDX,
    COL_Y_IDX,
    COL_BURST_LAST,
];

pub const STAGE2_LANE_OPEN_COLS: [usize; 14] = [
    COL_REG_X,
    COL_REG_Y,
    COL_REG_X_NEXT,
    COL_I_REG,
    COL_I_NEXT,
    COL_MEM_VALUE,
    COL_WRITES_LOOKUP_TO_X,
    COL_WRITES_MEM_TO_X,
    COL_PRESERVES_X,
    COL_WRITES_NNN_TO_I,
    COL_IS_MEMOP,
    COL_X_IDX,
    COL_Y_IDX,
    COL_RAM_ADDR,
];

pub const STAGE3_SHIFT_OPEN_COLS: [usize; 5] = [COL_PC, COL_PC_NEXT, COL_X_IDX, COL_IS_MEMOP, COL_BURST_LAST];
pub const STAGE3_START_BOUNDARY_COLS: [usize; 2] = [COL_IS_MEMOP, COL_X_IDX];
pub const STAGE3_FINAL_BOUNDARY_COLS: [usize; 2] = [COL_IS_MEMOP, COL_BURST_LAST];
pub const DECODE_HANDOFF_POLY_IDS: [usize; 3] = [0, 1, 2];
pub const REG_TWIST_POLY_IDS: [usize; 5] = [0, 1, 2, 3, 4];
pub const RAM_TWIST_POLY_IDS: [usize; 3] = [0, 1, 2];

// ---------------------------------------------------------------------------
// Opening manifest (§9.2, §9.3)
// ---------------------------------------------------------------------------

#[derive(Clone, Debug)]
pub struct KernelOpeningClaim {
    pub commitment_id: CommitmentId,
    pub point: Vec<K>,
    pub polynomial_ids: Vec<usize>,
    pub claimed_values: Vec<K>,
}

#[derive(Clone, Debug)]
pub struct KernelOpeningManifest {
    pub claims: Vec<KernelOpeningClaim>,
}

impl KernelOpeningManifest {
    pub fn new() -> Self {
        Self { claims: Vec::new() }
    }

    pub fn push(&mut self, claim: KernelOpeningClaim) {
        self.claims.push(claim);
    }

    /// Sort claims in canonical order per §9.3.
    pub fn canonicalize(&mut self) {
        self.claims.sort_by(|a, b| {
            a.commitment_id
                .cmp(&b.commitment_id)
                .then(a.point.len().cmp(&b.point.len()))
                .then(a.polynomial_ids.cmp(&b.polynomial_ids))
        });
    }
}

impl Default for KernelOpeningManifest {
    fn default() -> Self {
        Self::new()
    }
}

// ---------------------------------------------------------------------------
// Kernel proof and output (§9.4)
// ---------------------------------------------------------------------------

pub struct SimpleKernelProof {
    pub commitments: KernelCommitments,
    pub meta_pub: KernelMetaPub,
    pub stage1: Stage1ShoutProof,
    pub stage2: Stage2TwistProof,
    pub stage3: Stage3Proof,
    pub kernel_opening_manifest: KernelOpeningManifest,
}

pub struct KernelCommitments {
    pub c_lane: [u8; 32],
    pub c_fetch_ra: [u8; 32],
    pub c_decode_ra: [u8; 32],
    pub c_alu_ra: [u8; 32],
    pub c_eq4_ra: [u8; 32],
    pub c_decode_handoff: [u8; 32],
    pub c_reg: [u8; 32],
    pub c_ram: [u8; 32],
    pub c_rom_table: [u8; 32],
    pub c_decode_table: [u8; 32],
    pub c_alu_table: [u8; 32],
    pub c_eq4_table: [u8; 32],
}

pub struct KernelMetaPub {
    pub program_image_digest: [u8; 32],
    pub initial_state_digest: [u8; 32],
    pub program_word_count: usize,
    pub semantic_rows: usize,
    pub padded_trace_length: usize,
    pub pad_pc_word: u16,
    pub program_base_addr: u16,
    pub cycle_bits: usize,
}

pub struct SimpleKernelOutput {
    pub prepared_steps: Vec<crate::proof::StepInput>,
    pub public_steps: Vec<crate::proof::PublicStep>,
    pub kernel_opening_manifest: KernelOpeningManifest,
}

#[derive(Debug)]
pub enum SimpleKernelError {
    InvalidProgram(String),
    InvalidWitness(String),
    SumcheckFailed(String),
    OpeningFailed(String),
    ContinuityFailed(String),
    BridgeFailed(String),
}

impl std::fmt::Display for SimpleKernelError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::InvalidProgram(s) => write!(f, "invalid program: {s}"),
            Self::InvalidWitness(s) => write!(f, "invalid witness: {s}"),
            Self::SumcheckFailed(s) => write!(f, "sumcheck failed: {s}"),
            Self::OpeningFailed(s) => write!(f, "opening failed: {s}"),
            Self::ContinuityFailed(s) => write!(f, "continuity failed: {s}"),
            Self::BridgeFailed(s) => write!(f, "bridge failed: {s}"),
        }
    }
}

impl std::error::Error for SimpleKernelError {}

fn build_eq_table(point: &[K]) -> Vec<K> {
    let ell = point.len();
    let n = 1usize << ell;
    let mut out = vec![K::ONE; n];
    for (i, &ri) in point.iter().enumerate() {
        let stride = 1usize << i;
        let block = 1usize << (ell - i - 1);
        let one_minus = K::ONE - ri;
        let mut idx = 0usize;
        for _ in 0..block {
            for j in 0..stride {
                let a = out[idx + j];
                out[idx + j] = a * one_minus;
            }
            for j in 0..stride {
                let a = out[idx + stride + j];
                out[idx + stride + j] = a * ri;
            }
            idx += 2 * stride;
        }
    }
    out
}

fn lane_poly_ids(cols: &[usize]) -> Vec<usize> {
    cols.iter().map(|&col| col - 1).collect()
}

fn mle_eval_vec(values: &[F], point: &[K]) -> K {
    let eq = build_eq_table(point);
    values
        .iter()
        .zip(eq.iter())
        .fold(K::ZERO, |acc, (&value, &weight)| acc + K::from(value) * weight)
}

fn bits_point(index: usize, cycle_bits: usize) -> Vec<K> {
    (0..cycle_bits)
        .map(|bit| if (index >> bit) & 1 == 1 { K::ONE } else { K::ZERO })
        .collect()
}

fn open_onehot_at_point_be(addresses: &[usize], addr_point_be: &[K], cycle_point: &[K]) -> K {
    let addr_point_le: Vec<K> = addr_point_be.iter().rev().copied().collect();
    let eq_addr = build_eq_table(&addr_point_le);
    let eq_cycle = build_eq_table(cycle_point);
    addresses
        .iter()
        .enumerate()
        .fold(K::ZERO, |acc, (cycle, &addr)| acc + eq_cycle[cycle] * eq_addr[addr])
}

fn digest_bytes(domain: &'static [u8], bytes: &[u8]) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(domain);
    tr.append_message(b"chip8/kernel/bytes", bytes);
    tr.digest32()
}

fn digest_u64s(domain: &'static [u8], shape: &[u64], values: &[u64]) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(domain);
    tr.append_u64s(b"chip8/kernel/shape", shape);
    tr.append_u64s(b"chip8/kernel/u64_values", values);
    tr.digest32()
}

fn digest_fields_iter<I>(domain: &'static [u8], shape: &[u64], len: usize, values: I) -> [u8; 32]
where
    I: IntoIterator<Item = F>,
{
    let mut tr = Poseidon2Transcript::new(domain);
    tr.append_u64s(b"chip8/kernel/shape", shape);
    tr.append_fields_iter(b"chip8/kernel/field_values", len, values);
    tr.digest32()
}

fn digest_twist_family(domain: &'static [u8], shape: &[u64], incs: &[F], address_families: &[&[u64]]) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(domain);
    tr.append_u64s(b"chip8/kernel/shape", shape);
    tr.append_fields(b"chip8/kernel/inc_values", incs);
    for addresses in address_families {
        tr.append_u64s(b"chip8/kernel/address_family", addresses);
    }
    tr.digest32()
}

fn build_kernel_commitments(
    trace_rows: &[[F; 24]],
    aux: &[KernelStepAux],
    rom_table: &[F],
    decode_table: &[Vec<F>],
    alu_table: &[F],
    eq4_table: &[F],
) -> KernelCommitments {
    let trace_len = trace_rows.len();
    let fetch_addrs: Vec<u64> = aux.iter().map(|step| step.fetch_addr as u64).collect();
    let decode_addrs: Vec<u64> = aux.iter().map(|step| step.decode_addr as u64).collect();
    let alu_addrs: Vec<u64> = aux.iter().map(|step| step.alu_key as u64).collect();
    let eq4_addrs: Vec<u64> = aux.iter().map(|step| step.eq4_key as u64).collect();
    let reg_ra_x_addrs: Vec<u64> = aux.iter().map(|step| step.reg_ra_x_addr as u64).collect();
    let reg_ra_y_addrs: Vec<u64> = aux.iter().map(|step| step.reg_ra_y_addr as u64).collect();
    let reg_ra_i_addrs: Vec<u64> = aux.iter().map(|step| step.reg_ra_i_addr as u64).collect();
    let reg_wa_addrs: Vec<u64> = aux.iter().map(|step| step.reg_wa_addr as u64).collect();
    let ram_ra_addrs: Vec<u64> = aux.iter().map(|step| step.ram_ra_addr as u64).collect();
    let ram_wa_addrs: Vec<u64> = aux.iter().map(|step| step.ram_wa_addr as u64).collect();

    KernelCommitments {
        c_lane: digest_fields_iter(
            b"neo.fold.next/chip8/c_lane",
            &[trace_len as u64, 23],
            trace_len * 23,
            trace_rows.iter().flat_map(|row| row[1..].iter().copied()),
        ),
        c_fetch_ra: digest_u64s(
            b"neo.fold.next/chip8/c_fetch_ra",
            &[rom_table.len() as u64, trace_len as u64],
            &fetch_addrs,
        ),
        c_decode_ra: digest_u64s(
            b"neo.fold.next/chip8/c_decode_ra",
            &[(1u64 << 16), trace_len as u64],
            &decode_addrs,
        ),
        c_alu_ra: digest_u64s(
            b"neo.fold.next/chip8/c_alu_ra",
            &[(1u64 << 18), trace_len as u64],
            &alu_addrs,
        ),
        c_eq4_ra: digest_u64s(
            b"neo.fold.next/chip8/c_eq4_ra",
            &[(1u64 << 8), trace_len as u64],
            &eq4_addrs,
        ),
        c_decode_handoff: digest_u64s(
            b"neo.fold.next/chip8/c_decode_handoff",
            &[3, trace_len as u64],
            &aux.iter()
                .flat_map(|step| [step.uses_y as u64, step.reads_ram as u64, step.writes_ram as u64])
                .collect::<Vec<_>>(),
        ),
        c_reg: digest_twist_family(
            b"neo.fold.next/chip8/c_reg",
            &[5, trace_len as u64],
            &aux.iter().map(|step| step.reg_inc).collect::<Vec<_>>(),
            &[&reg_ra_x_addrs, &reg_ra_y_addrs, &reg_ra_i_addrs, &reg_wa_addrs],
        ),
        c_ram: digest_twist_family(
            b"neo.fold.next/chip8/c_ram",
            &[3, trace_len as u64],
            &aux.iter().map(|step| step.ram_inc).collect::<Vec<_>>(),
            &[&ram_ra_addrs, &ram_wa_addrs],
        ),
        c_rom_table: digest_fields_iter(
            b"neo.fold.next/chip8/c_rom_table",
            &[rom_table.len() as u64],
            rom_table.len(),
            rom_table.iter().copied(),
        ),
        c_decode_table: digest_fields_iter(
            b"neo.fold.next/chip8/c_decode_table",
            &[
                decode_table.len() as u64,
                decode_table.first().map_or(0, Vec::len) as u64,
            ],
            decode_table.iter().map(Vec::len).sum(),
            decode_table.iter().flat_map(|col| col.iter().copied()),
        ),
        c_alu_table: digest_fields_iter(
            b"neo.fold.next/chip8/c_alu_table",
            &[alu_table.len() as u64],
            alu_table.len(),
            alu_table.iter().copied(),
        ),
        c_eq4_table: digest_fields_iter(
            b"neo.fold.next/chip8/c_eq4_table",
            &[eq4_table.len() as u64],
            eq4_table.len(),
            eq4_table.iter().copied(),
        ),
    }
}

fn absorb_root0(transcript: &mut Poseidon2Transcript, commitments: &KernelCommitments, meta_pub: &KernelMetaPub) {
    transcript.append_message(b"chip8/root0/version", b"v1");
    transcript.append_message(b"chip8/root0/c_lane", &commitments.c_lane);
    transcript.append_message(b"chip8/root0/c_fetch_ra", &commitments.c_fetch_ra);
    transcript.append_message(b"chip8/root0/c_decode_ra", &commitments.c_decode_ra);
    transcript.append_message(b"chip8/root0/c_alu_ra", &commitments.c_alu_ra);
    transcript.append_message(b"chip8/root0/c_eq4_ra", &commitments.c_eq4_ra);
    transcript.append_message(b"chip8/root0/c_decode_handoff", &commitments.c_decode_handoff);
    transcript.append_message(b"chip8/root0/c_reg", &commitments.c_reg);
    transcript.append_message(b"chip8/root0/c_ram", &commitments.c_ram);
    transcript.append_message(b"chip8/root0/c_rom_table", &commitments.c_rom_table);
    transcript.append_message(b"chip8/root0/c_decode_table", &commitments.c_decode_table);
    transcript.append_message(b"chip8/root0/c_alu_table", &commitments.c_alu_table);
    transcript.append_message(b"chip8/root0/c_eq4_table", &commitments.c_eq4_table);
    transcript.append_message(b"chip8/root0/program_image_digest", &meta_pub.program_image_digest);
    transcript.append_message(b"chip8/root0/initial_state_digest", &meta_pub.initial_state_digest);
    transcript.append_u64s(
        b"chip8/root0/meta_pub",
        &[
            meta_pub.program_word_count as u64,
            meta_pub.semantic_rows as u64,
            meta_pub.padded_trace_length as u64,
            meta_pub.pad_pc_word as u64,
            meta_pub.program_base_addr as u64,
            meta_pub.cycle_bits as u64,
        ],
    );
}

fn build_kernel_opening_manifest(
    aux: &[KernelStepAux],
    active_rows: usize,
    cycle_bits: usize,
    stage1: &Stage1ShoutProof,
    stage2: &Stage2TwistProof,
    stage3: &Stage3Proof,
) -> KernelOpeningManifest {
    let mut manifest = KernelOpeningManifest::new();

    manifest.push(KernelOpeningClaim {
        commitment_id: CommitmentId::Lane,
        point: stage1.cycle_point.clone(),
        polynomial_ids: lane_poly_ids(&STAGE1_LANE_OPEN_COLS),
        claimed_values: stage1.lane_values_at_lookup.clone(),
    });
    manifest.push(KernelOpeningClaim {
        commitment_id: CommitmentId::FetchRa,
        point: stage1
            .fetch_proof
            .addr_point
            .iter()
            .copied()
            .chain(stage1.cycle_point.iter().copied())
            .collect(),
        polynomial_ids: vec![0],
        claimed_values: vec![stage1.fetch_proof.address_opening_value],
    });
    manifest.push(KernelOpeningClaim {
        commitment_id: CommitmentId::DecodeRa,
        point: stage1
            .decode_proof
            .addr_point
            .iter()
            .copied()
            .chain(stage1.cycle_point.iter().copied())
            .collect(),
        polynomial_ids: vec![0],
        claimed_values: vec![stage1.decode_proof.address_opening_value],
    });
    manifest.push(KernelOpeningClaim {
        commitment_id: CommitmentId::AluRa,
        point: stage1
            .alu_proof
            .addr_point
            .iter()
            .copied()
            .chain(stage1.cycle_point.iter().copied())
            .collect(),
        polynomial_ids: vec![0],
        claimed_values: vec![stage1.alu_proof.address_opening_value],
    });
    manifest.push(KernelOpeningClaim {
        commitment_id: CommitmentId::Eq4Ra,
        point: stage1
            .eq4_proof
            .addr_point
            .iter()
            .copied()
            .chain(stage1.cycle_point.iter().copied())
            .collect(),
        polynomial_ids: vec![0],
        claimed_values: vec![stage1.eq4_proof.address_opening_value],
    });
    manifest.push(KernelOpeningClaim {
        commitment_id: CommitmentId::DecodeHandoff,
        point: stage1.cycle_point.clone(),
        polynomial_ids: DECODE_HANDOFF_POLY_IDS.to_vec(),
        claimed_values: stage1.decode_handoff_values.clone(),
    });
    manifest.push(KernelOpeningClaim {
        commitment_id: CommitmentId::RomTable,
        point: stage1.fetch_proof.addr_point.clone(),
        polynomial_ids: vec![0],
        claimed_values: stage1.fetch_proof.table_opening_values.clone(),
    });
    manifest.push(KernelOpeningClaim {
        commitment_id: CommitmentId::DecodeTable,
        point: stage1.decode_proof.addr_point.clone(),
        polynomial_ids: (0..stage1.decode_proof.table_opening_values.len()).collect(),
        claimed_values: stage1.decode_proof.table_opening_values.clone(),
    });
    manifest.push(KernelOpeningClaim {
        commitment_id: CommitmentId::AluTable,
        point: stage1.alu_proof.addr_point[2..].to_vec(),
        polynomial_ids: vec![0],
        claimed_values: stage1.alu_proof.table_opening_values.clone(),
    });
    manifest.push(KernelOpeningClaim {
        commitment_id: CommitmentId::Eq4Table,
        point: stage1.eq4_proof.addr_point.clone(),
        polynomial_ids: vec![0],
        claimed_values: stage1.eq4_proof.table_opening_values.clone(),
    });
    manifest.push(KernelOpeningClaim {
        commitment_id: CommitmentId::Lane,
        point: stage2.cycle_point.clone(),
        polynomial_ids: lane_poly_ids(&STAGE2_LANE_OPEN_COLS),
        claimed_values: stage2.lane_values_at_twist.clone(),
    });
    manifest.push(KernelOpeningClaim {
        commitment_id: CommitmentId::DecodeHandoff,
        point: stage2.cycle_point.clone(),
        polynomial_ids: DECODE_HANDOFF_POLY_IDS.to_vec(),
        claimed_values: stage2.handoff_values_at_twist.clone(),
    });
    let reg_point: Vec<K> = stage2
        .reg_addr_point
        .iter()
        .copied()
        .chain(stage2.cycle_point.iter().copied())
        .collect();
    manifest.push(KernelOpeningClaim {
        commitment_id: CommitmentId::RegTwist,
        point: reg_point,
        polynomial_ids: REG_TWIST_POLY_IDS.to_vec(),
        claimed_values: vec![
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
    });
    let ram_point: Vec<K> = stage2
        .ram_addr_point
        .iter()
        .copied()
        .chain(stage2.cycle_point.iter().copied())
        .collect();
    manifest.push(KernelOpeningClaim {
        commitment_id: CommitmentId::RamTwist,
        point: ram_point,
        polynomial_ids: RAM_TWIST_POLY_IDS.to_vec(),
        claimed_values: vec![
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
    });
    manifest.push(KernelOpeningClaim {
        commitment_id: CommitmentId::Lane,
        point: stage3.shift_proof.source_point.clone(),
        polynomial_ids: lane_poly_ids(&STAGE3_SHIFT_OPEN_COLS),
        claimed_values: stage3.shift_opening_values.to_vec(),
    });
    manifest.push(KernelOpeningClaim {
        commitment_id: CommitmentId::Lane,
        point: vec![K::ZERO; cycle_bits],
        polynomial_ids: lane_poly_ids(&STAGE3_START_BOUNDARY_COLS),
        claimed_values: stage3.start_boundary_values.to_vec(),
    });

    let last_row = active_rows - 1;
    manifest.push(KernelOpeningClaim {
        commitment_id: CommitmentId::Lane,
        point: bits_point(last_row, cycle_bits),
        polynomial_ids: lane_poly_ids(&STAGE3_FINAL_BOUNDARY_COLS),
        claimed_values: stage3.final_boundary_values.to_vec(),
    });

    let row_binding_ids: Vec<usize> = (0..23).collect();
    for row in &stage3.row_bindings {
        manifest.push(KernelOpeningClaim {
            commitment_id: CommitmentId::Lane,
            point: row
                .row_bits
                .iter()
                .map(|&bit| if bit { K::ONE } else { K::ZERO })
                .collect(),
            polynomial_ids: row_binding_ids.clone(),
            claimed_values: row.opened_values.clone(),
        });
    }

    manifest.canonicalize();
    manifest
}

fn pad_opcode(pad_pc_word: u16) -> u16 {
    0x1000 | (2 * pad_pc_word)
}

fn build_pad_aux(pad_pc_word: u16) -> KernelStepAux {
    KernelStepAux {
        fetch_addr: pad_pc_word as usize,
        decode_addr: pad_opcode(pad_pc_word),
        alu_key: flatten_alu_key(LookupKind::NoLookup, 0, 0),
        eq4_key: flatten_eq4_key(0, 0),
        reg_ra_x_addr: REG_SINK_ADDR,
        reg_ra_y_addr: REG_SINK_ADDR,
        reg_ra_i_addr: REG_SINK_ADDR,
        reg_wa_addr: REG_SINK_ADDR,
        ram_ra_addr: RAM_SINK_ADDR,
        ram_wa_addr: RAM_SINK_ADDR,
        reg_inc: F::ZERO,
        ram_inc: F::ZERO,
        uses_y: false,
        reads_ram: false,
        writes_ram: false,
    }
}

fn pad_semantic_witness(
    semantic_trace_rows: &[[F; 24]],
    semantic_aux_data: &[KernelStepAux],
    pad_pc_word: u16,
) -> Result<(Vec<[F; 24]>, Vec<KernelStepAux>), SimpleKernelError> {
    if semantic_trace_rows.is_empty() {
        return Err(SimpleKernelError::InvalidWitness(
            "semantic trace must contain at least one row".into(),
        ));
    }
    if semantic_trace_rows.len() != semantic_aux_data.len() {
        return Err(SimpleKernelError::InvalidWitness(format!(
            "semantic trace row count {} does not match aux row count {}",
            semantic_trace_rows.len(),
            semantic_aux_data.len()
        )));
    }

    let padded_len = semantic_trace_rows.len().next_power_of_two();
    let mut trace_rows = semantic_trace_rows.to_vec();
    let mut aux_data = semantic_aux_data.to_vec();
    let pad_row = build_pad_row(pad_pc_word);
    let pad_aux = build_pad_aux(pad_pc_word);

    while trace_rows.len() < padded_len {
        trace_rows.push(pad_row);
        aux_data.push(pad_aux.clone());
    }

    Ok((trace_rows, aux_data))
}

fn row_index_matches_bits(row_index: usize, row_bits: &[bool]) -> bool {
    row_bits
        .iter()
        .enumerate()
        .all(|(bit, &is_one)| ((row_index >> bit) & 1 == 1) == is_one)
}

fn base_value(value: K, label: &str) -> Result<F, SimpleKernelError> {
    let [real, imag] = value.as_coeffs();
    if imag != F::ZERO {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "{label} must be a base-field opening"
        )));
    }
    Ok(real)
}

fn build_root_step<L: SModuleHomomorphism<F, Commitment>>(
    row_binding: &RowBindingClaim,
    cycle_bits: usize,
    root_params: &NeoParams,
    root_log: &L,
) -> Result<crate::proof::StepInput, SimpleKernelError> {
    if row_binding.row_bits.len() != cycle_bits {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "row {} has {} row bits, expected {}",
            row_binding.row_index,
            row_binding.row_bits.len(),
            cycle_bits
        )));
    }
    if !row_index_matches_bits(row_binding.row_index, &row_binding.row_bits) {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "row {} bits do not match its row index",
            row_binding.row_index
        )));
    }
    if row_binding.opened_values.len() != 23 {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "row {} has {} opened values, expected 23",
            row_binding.row_index,
            row_binding.opened_values.len()
        )));
    }

    let mut z = Vec::with_capacity(24);
    z.push(F::ONE);
    for (col, &value) in row_binding.opened_values.iter().enumerate() {
        z.push(base_value(
            value,
            &format!("row {} column {}", row_binding.row_index, col + 1),
        )?);
    }
    let z_mat = encode_vector_for_ccs_m(root_params, z.len(), &z).map_err(SimpleKernelError::BridgeFailed)?;
    Ok(crate::proof::StepInput {
        label: format!("chip8/simple/{}", row_binding.row_index),
        mcs: CcsClaim {
            c: root_log.commit(&z_mat),
            x: vec![F::ONE],
            m_in: 1,
        },
        witness: CcsWitness {
            w: z[1..].to_vec(),
            Z: z_mat,
        },
        deferred_extensions: Vec::new(),
    })
}

pub(crate) fn sample_sumcheck_challenge<Tr: Transcript>(transcript: &mut Tr) -> K {
    let c0 = transcript.challenge_field(b"sumcheck/challenge/0");
    let c1 = transcript.challenge_field(b"sumcheck/challenge/1");
    from_complex(c0, c1)
}

pub(crate) fn replay_sumcheck_unchecked<Tr: Transcript>(
    transcript: &mut Tr,
    degree_bound: usize,
    rounds: &[Vec<K>],
    label: &str,
) -> Result<Vec<K>, SimpleKernelError> {
    let mut challenges = Vec::with_capacity(rounds.len());
    for (round_idx, round) in rounds.iter().enumerate() {
        if round.len() > degree_bound + 1 {
            return Err(SimpleKernelError::SumcheckFailed(format!(
                "{label} round {round_idx} exceeds degree bound {degree_bound}"
            )));
        }
        for coeff in round {
            transcript.append_fields(b"sumcheck/round/coeff", &coeff.as_coeffs());
        }
        challenges.push(sample_sumcheck_challenge(transcript));
    }
    Ok(challenges)
}

pub(crate) fn verify_sumcheck_known<Tr: Transcript>(
    transcript: &mut Tr,
    degree_bound: usize,
    initial_sum: K,
    rounds: &[Vec<K>],
    label: &str,
) -> Result<Vec<K>, SimpleKernelError> {
    let (challenges, _, ok) = verify_sumcheck_rounds(transcript, degree_bound, initial_sum, rounds);
    if ok {
        Ok(challenges)
    } else {
        Err(SimpleKernelError::SumcheckFailed(format!(
            "{label} sumcheck verification failed"
        )))
    }
}

pub(crate) fn expect_equal_k_slice(actual: &[K], expected: &[K], label: &str) -> Result<(), SimpleKernelError> {
    if actual == expected {
        Ok(())
    } else {
        Err(SimpleKernelError::OpeningFailed(format!("{label} mismatch")))
    }
}

pub(crate) fn expect_equal_k(actual: K, expected: K, label: &str) -> Result<(), SimpleKernelError> {
    if actual == expected {
        Ok(())
    } else {
        Err(SimpleKernelError::OpeningFailed(format!("{label} mismatch")))
    }
}

pub(crate) fn batch_values(values: &[K], gamma: K) -> K {
    let mut acc = K::ZERO;
    let mut gamma_power = K::ONE;
    for &value in values {
        acc += gamma_power * value;
        gamma_power *= gamma;
    }
    acc
}

pub(crate) fn split_round_groups<'a>(
    rounds: &'a [Vec<K>],
    first_len: usize,
    second_len: usize,
    third_len: usize,
    label: &str,
) -> Result<(&'a [Vec<K>], &'a [Vec<K>], &'a [Vec<K>]), SimpleKernelError> {
    let expected = first_len + second_len + third_len;
    if rounds.len() != expected {
        return Err(SimpleKernelError::SumcheckFailed(format!(
            "{label} round count {} != expected {expected}",
            rounds.len()
        )));
    }
    let (first, rest) = rounds.split_at(first_len);
    let (second, third) = rest.split_at(second_len);
    Ok((first, second, third))
}

fn assert_manifest_canonical(manifest: &KernelOpeningManifest) -> Result<(), SimpleKernelError> {
    for window in manifest.claims.windows(2) {
        let lhs = &window[0];
        let rhs = &window[1];
        let lhs_key = (lhs.commitment_id, lhs.point.len(), &lhs.polynomial_ids);
        let rhs_key = (rhs.commitment_id, rhs.point.len(), &rhs.polynomial_ids);
        if lhs_key > rhs_key {
            return Err(SimpleKernelError::OpeningFailed(
                "kernel opening manifest is not in canonical order".into(),
            ));
        }
    }
    Ok(())
}

fn find_manifest_claim<'a>(
    manifest: &'a KernelOpeningManifest,
    commitment_id: CommitmentId,
    point: &[K],
    polynomial_ids: &[usize],
    label: &str,
) -> Result<&'a KernelOpeningClaim, SimpleKernelError> {
    let mut matches = manifest.claims.iter().filter(|claim| {
        claim.commitment_id == commitment_id && claim.point == point && claim.polynomial_ids == polynomial_ids
    });
    let claim = matches
        .next()
        .ok_or_else(|| SimpleKernelError::OpeningFailed(format!("{label} missing from kernel opening manifest")))?;
    if matches.next().is_some() {
        return Err(SimpleKernelError::OpeningFailed(format!(
            "{label} appears multiple times in kernel opening manifest"
        )));
    }
    Ok(claim)
}

pub(crate) fn verify_stage1_channel_transcript<Tr: Transcript>(
    transcript: &mut Tr,
    proof: &ShoutChannelProof,
    initial_sum: K,
    addr_bits: usize,
    cycle_bits: usize,
    label: &str,
) -> Result<(), SimpleKernelError> {
    let core_point = verify_sumcheck_known(
        transcript,
        2,
        initial_sum,
        &proof.sumcheck_rounds,
        &format!("{label} core"),
    )?;
    expect_equal_k_slice(&proof.addr_point, &core_point, &format!("{label} addr point"))?;

    let total_bits = addr_bits + cycle_bits;
    let (bool_rounds, hamming_rounds, decode_rounds) = split_round_groups(
        &proof.addr_correctness_rounds,
        total_bits,
        addr_bits,
        addr_bits,
        &format!("{label} address correctness"),
    )?;
    verify_sumcheck_known(transcript, 2, K::ZERO, bool_rounds, &format!("{label} booleanity"))?;
    verify_sumcheck_known(
        transcript,
        1,
        K::ONE,
        hamming_rounds,
        &format!("{label} hamming weight"),
    )?;
    replay_sumcheck_unchecked(transcript, 2, decode_rounds, &format!("{label} decode consistency"))?;
    Ok(())
}

pub(crate) fn verify_stage2_address_correctness_transcript<Tr: Transcript>(
    transcript: &mut Tr,
    proof: &AddressCorrectnessProof,
    addr_bits: usize,
    cycle_bits: usize,
    label: &str,
) -> Result<(), SimpleKernelError> {
    let total_bits = addr_bits + cycle_bits;
    verify_sumcheck_known(
        transcript,
        2,
        K::ZERO,
        &proof.booleanity_rounds,
        &format!("{label} booleanity"),
    )?;
    if proof.booleanity_rounds.len() != total_bits {
        return Err(SimpleKernelError::SumcheckFailed(format!(
            "{label} booleanity round count {} != expected {total_bits}",
            proof.booleanity_rounds.len()
        )));
    }
    verify_sumcheck_known(
        transcript,
        1,
        K::ONE,
        &proof.hamming_weight_rounds,
        &format!("{label} hamming weight"),
    )?;
    if proof.hamming_weight_rounds.len() != addr_bits {
        return Err(SimpleKernelError::SumcheckFailed(format!(
            "{label} hamming round count {} != expected {addr_bits}",
            proof.hamming_weight_rounds.len()
        )));
    }
    replay_sumcheck_unchecked(
        transcript,
        2,
        &proof.decode_consistency_rounds,
        &format!("{label} decode consistency"),
    )?;
    if proof.decode_consistency_rounds.len() != addr_bits {
        return Err(SimpleKernelError::SumcheckFailed(format!(
            "{label} decode-consistency round count {} != expected {addr_bits}",
            proof.decode_consistency_rounds.len()
        )));
    }
    Ok(())
}

// ---------------------------------------------------------------------------
// Entry point stubs
// ---------------------------------------------------------------------------

pub fn prove_simple_kernel<L: SModuleHomomorphism<F, Commitment>>(
    input: &SimpleKernelProverInput,
    root_params: &NeoParams,
    root_log: &L,
    transcript: &mut Poseidon2Transcript,
) -> Result<(SimpleKernelOutput, SimpleKernelProof), SimpleKernelError> {
    let semantic_rows = input.witness.semantic_trace_rows.len();

    // Build program descriptor from public input.
    let program = Chip8Program {
        bytes: input.public.program_image.clone(),
        start_pc: CHIP8_PROGRAM_START,
    };
    let base_word = (program.start_pc / 2) as usize;
    let word_count = program.bytes.len() / 2;
    let pad_pc_word = (base_word + word_count) as u16;
    let (trace_rows, aux_data) = pad_semantic_witness(
        &input.witness.semantic_trace_rows,
        &input.witness.semantic_aux_data,
        pad_pc_word,
    )?;
    let padded_trace_length = trace_rows.len();
    let cycle_bits = padded_trace_length.trailing_zeros() as usize;

    // Build lookup tables.
    let rom_table = build_rom_table(&program, pad_pc_word);
    let decode_table = build_decode_table();
    let alu_table = build_alu_table();
    let eq4_table = build_eq4_table();

    let commitments = build_kernel_commitments(
        &trace_rows,
        &aux_data,
        &rom_table,
        &decode_table,
        &alu_table,
        &eq4_table,
    );
    let meta_pub = KernelMetaPub {
        program_image_digest: digest_bytes(b"neo.fold.next/chip8/program_image", &input.public.program_image),
        initial_state_digest: {
            let mut bytes = Vec::with_capacity(16 + 2 + input.public.initial_ram.len());
            bytes.extend(input.public.initial_registers);
            bytes.extend_from_slice(&input.public.initial_i.to_le_bytes());
            bytes.extend_from_slice(&input.public.initial_ram);
            digest_bytes(b"neo.fold.next/chip8/initial_state", &bytes)
        },
        program_word_count: word_count,
        semantic_rows,
        padded_trace_length,
        pad_pc_word,
        program_base_addr: CHIP8_PROGRAM_START,
        cycle_bits,
    };
    absorb_root0(transcript, &commitments, &meta_pub);

    // Stage 1: Shout (read-only lookup proofs).
    let stage1_proof = stage1::prove_stage1(
        &trace_rows,
        &aux_data,
        &rom_table,
        &decode_table,
        &alu_table,
        &eq4_table,
        cycle_bits,
        transcript,
    )
    .map_err(SimpleKernelError::SumcheckFailed)?;

    // Stage 2: Twist (read-write memory checking).
    let stage2_proof = stage2::prove_stage2(
        &trace_rows,
        &aux_data,
        &input.public.initial_registers,
        input.public.initial_i,
        &input.public.initial_ram,
        cycle_bits,
        transcript,
    )?;

    // Stage 3: Continuity + bridge binding.
    let active_rows = semantic_rows;
    let stage3_proof = stage3::prove_stage3(&trace_rows, active_rows, cycle_bits, transcript)?;

    let manifest = build_kernel_opening_manifest(
        &aux_data,
        active_rows,
        cycle_bits,
        &stage1_proof,
        &stage2_proof,
        &stage3_proof,
    );
    if stage3_proof.row_bindings.len() != semantic_rows {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "stage3 exported {} row bindings for {} semantic rows",
            stage3_proof.row_bindings.len(),
            semantic_rows
        )));
    }
    let prepared_steps: Vec<_> = stage3_proof
        .row_bindings
        .iter()
        .map(|row_binding| build_root_step(row_binding, cycle_bits, root_params, root_log))
        .collect::<Result<_, _>>()?;
    let public_steps = prepared_steps
        .iter()
        .map(crate::proof::StepInput::instance)
        .collect();

    let output = SimpleKernelOutput {
        prepared_steps,
        public_steps,
        kernel_opening_manifest: manifest.clone(),
    };

    let proof = SimpleKernelProof {
        commitments,
        meta_pub,
        stage1: stage1_proof,
        stage2: stage2_proof,
        stage3: stage3_proof,
        kernel_opening_manifest: manifest,
    };

    Ok((output, proof))
}

pub fn verify_simple_kernel<L: SModuleHomomorphism<F, Commitment>>(
    input: &SimpleKernelVerifierInput,
    proof: &SimpleKernelProof,
    root_params: &NeoParams,
    root_log: &L,
    transcript: &mut Poseidon2Transcript,
) -> Result<SimpleKernelOutput, SimpleKernelError> {
    let program = Chip8Program {
        bytes: input.public.program_image.clone(),
        start_pc: CHIP8_PROGRAM_START,
    };
    let base_word = (program.start_pc / 2) as usize;
    let word_count = program.bytes.len() / 2;
    let pad_pc_word = (base_word + word_count) as u16;
    let semantic_rows = proof.meta_pub.semantic_rows;
    let padded_trace_length = proof.meta_pub.padded_trace_length;
    let cycle_bits = proof.meta_pub.cycle_bits;

    if semantic_rows == 0 {
        return Err(SimpleKernelError::InvalidWitness(
            "kernel proof must contain at least one semantic row".into(),
        ));
    }
    if !padded_trace_length.is_power_of_two() {
        return Err(SimpleKernelError::InvalidWitness(format!(
            "padded trace length {padded_trace_length} must be a power of two"
        )));
    }
    if padded_trace_length != (1usize << cycle_bits) {
        return Err(SimpleKernelError::InvalidWitness(format!(
            "padded trace length {padded_trace_length} != 2^{cycle_bits}"
        )));
    }
    if semantic_rows > padded_trace_length {
        return Err(SimpleKernelError::InvalidWitness(format!(
            "semantic row count {semantic_rows} exceeds padded trace length {padded_trace_length}"
        )));
    }
    if proof.stage3.row_bindings.len() != semantic_rows {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "stage3 exported {} row bindings for {} semantic rows",
            proof.stage3.row_bindings.len(),
            semantic_rows
        )));
    }
    if proof.kernel_opening_manifest.claims.len() != 17 + semantic_rows {
        return Err(SimpleKernelError::OpeningFailed(format!(
            "kernel opening manifest has {} claims, expected {}",
            proof.kernel_opening_manifest.claims.len(),
            17 + semantic_rows
        )));
    }

    let expected_program_image_digest = digest_bytes(b"neo.fold.next/chip8/program_image", &input.public.program_image);
    let expected_initial_state_digest = {
        let mut bytes = Vec::with_capacity(16 + 2 + input.public.initial_ram.len());
        bytes.extend(input.public.initial_registers);
        bytes.extend_from_slice(&input.public.initial_i.to_le_bytes());
        bytes.extend_from_slice(&input.public.initial_ram);
        digest_bytes(b"neo.fold.next/chip8/initial_state", &bytes)
    };

    if proof.meta_pub.program_image_digest != expected_program_image_digest {
        return Err(SimpleKernelError::InvalidProgram(
            "program image digest does not match verifier input".into(),
        ));
    }
    if proof.meta_pub.initial_state_digest != expected_initial_state_digest {
        return Err(SimpleKernelError::InvalidWitness(
            "initial state digest does not match verifier input".into(),
        ));
    }
    if proof.meta_pub.program_word_count != word_count {
        return Err(SimpleKernelError::InvalidProgram(format!(
            "program word count {} != expected {word_count}",
            proof.meta_pub.program_word_count
        )));
    }
    if proof.meta_pub.pad_pc_word != pad_pc_word {
        return Err(SimpleKernelError::InvalidProgram(format!(
            "pad_pc_word {} != expected {pad_pc_word}",
            proof.meta_pub.pad_pc_word
        )));
    }
    if proof.meta_pub.program_base_addr != CHIP8_PROGRAM_START {
        return Err(SimpleKernelError::InvalidProgram(format!(
            "program base addr {} != expected {}",
            proof.meta_pub.program_base_addr, CHIP8_PROGRAM_START
        )));
    }

    assert_manifest_canonical(&proof.kernel_opening_manifest)?;
    absorb_root0(transcript, &proof.commitments, &proof.meta_pub);
    let rom_table = build_rom_table(&program, pad_pc_word);
    let decode_table = build_decode_table();
    let alu_table = build_alu_table();
    let eq4_table = build_eq4_table();

    stage1::verify_stage1(
        &proof.stage1,
        &rom_table,
        &decode_table,
        &alu_table,
        &eq4_table,
        cycle_bits,
        transcript,
    )
    .map_err(SimpleKernelError::SumcheckFailed)?;
    stage2::verify_stage2(
        &proof.stage2,
        &input.public.initial_registers,
        input.public.initial_i,
        &input.public.initial_ram,
        cycle_bits,
        transcript,
    )?;
    stage3::verify_stage3(
        &proof.stage3,
        semantic_rows,
        padded_trace_length,
        proof.meta_pub.pad_pc_word,
        cycle_bits,
        transcript,
    )?;

    let stage1_fetch_ra_point: Vec<K> = proof
        .stage1
        .fetch_proof
        .addr_point
        .iter()
        .copied()
        .chain(proof.stage1.cycle_point.iter().copied())
        .collect();
    let stage1_decode_ra_point: Vec<K> = proof
        .stage1
        .decode_proof
        .addr_point
        .iter()
        .copied()
        .chain(proof.stage1.cycle_point.iter().copied())
        .collect();
    let stage1_alu_ra_point: Vec<K> = proof
        .stage1
        .alu_proof
        .addr_point
        .iter()
        .copied()
        .chain(proof.stage1.cycle_point.iter().copied())
        .collect();
    let stage1_eq4_ra_point: Vec<K> = proof
        .stage1
        .eq4_proof
        .addr_point
        .iter()
        .copied()
        .chain(proof.stage1.cycle_point.iter().copied())
        .collect();
    expect_equal_k_slice(
        &find_manifest_claim(
            &proof.kernel_opening_manifest,
            CommitmentId::Lane,
            &proof.stage1.cycle_point,
            &lane_poly_ids(&STAGE1_LANE_OPEN_COLS),
            "stage1 lane opening",
        )?
        .claimed_values,
        &proof.stage1.lane_values_at_lookup,
        "stage1 lane opening values",
    )?;
    expect_equal_k_slice(
        &find_manifest_claim(
            &proof.kernel_opening_manifest,
            CommitmentId::DecodeHandoff,
            &proof.stage1.cycle_point,
            &DECODE_HANDOFF_POLY_IDS,
            "stage1 decode handoff opening",
        )?
        .claimed_values,
        &proof.stage1.decode_handoff_values,
        "stage1 decode handoff values",
    )?;
    expect_equal_k_slice(
        &find_manifest_claim(
            &proof.kernel_opening_manifest,
            CommitmentId::FetchRa,
            &stage1_fetch_ra_point,
            &[0],
            "stage1 fetch address opening",
        )?
        .claimed_values,
        &[proof.stage1.fetch_proof.address_opening_value],
        "stage1 fetch address opening value",
    )?;
    expect_equal_k_slice(
        &find_manifest_claim(
            &proof.kernel_opening_manifest,
            CommitmentId::DecodeRa,
            &stage1_decode_ra_point,
            &[0],
            "stage1 decode address opening",
        )?
        .claimed_values,
        &[proof.stage1.decode_proof.address_opening_value],
        "stage1 decode address opening value",
    )?;
    expect_equal_k_slice(
        &find_manifest_claim(
            &proof.kernel_opening_manifest,
            CommitmentId::AluRa,
            &stage1_alu_ra_point,
            &[0],
            "stage1 ALU address opening",
        )?
        .claimed_values,
        &[proof.stage1.alu_proof.address_opening_value],
        "stage1 ALU address opening value",
    )?;
    expect_equal_k_slice(
        &find_manifest_claim(
            &proof.kernel_opening_manifest,
            CommitmentId::Eq4Ra,
            &stage1_eq4_ra_point,
            &[0],
            "stage1 Eq4 address opening",
        )?
        .claimed_values,
        &[proof.stage1.eq4_proof.address_opening_value],
        "stage1 Eq4 address opening value",
    )?;
    expect_equal_k_slice(
        &find_manifest_claim(
            &proof.kernel_opening_manifest,
            CommitmentId::RomTable,
            &proof.stage1.fetch_proof.addr_point,
            &[0],
            "stage1 ROM table opening",
        )?
        .claimed_values,
        &proof.stage1.fetch_proof.table_opening_values,
        "stage1 ROM table opening values",
    )?;
    let decode_poly_ids: Vec<usize> = (0..proof.stage1.decode_proof.table_opening_values.len()).collect();
    expect_equal_k_slice(
        &find_manifest_claim(
            &proof.kernel_opening_manifest,
            CommitmentId::DecodeTable,
            &proof.stage1.decode_proof.addr_point,
            &decode_poly_ids,
            "stage1 decode table opening",
        )?
        .claimed_values,
        &proof.stage1.decode_proof.table_opening_values,
        "stage1 decode table opening values",
    )?;
    expect_equal_k_slice(
        &find_manifest_claim(
            &proof.kernel_opening_manifest,
            CommitmentId::AluTable,
            &proof.stage1.alu_proof.addr_point[2..],
            &[0],
            "stage1 ALU table opening",
        )?
        .claimed_values,
        &proof.stage1.alu_proof.table_opening_values,
        "stage1 ALU table opening values",
    )?;
    expect_equal_k_slice(
        &find_manifest_claim(
            &proof.kernel_opening_manifest,
            CommitmentId::Eq4Table,
            &proof.stage1.eq4_proof.addr_point,
            &[0],
            "stage1 Eq4 table opening",
        )?
        .claimed_values,
        &proof.stage1.eq4_proof.table_opening_values,
        "stage1 Eq4 table opening values",
    )?;

    expect_equal_k_slice(
        &find_manifest_claim(
            &proof.kernel_opening_manifest,
            CommitmentId::Lane,
            &proof.stage2.cycle_point,
            &lane_poly_ids(&STAGE2_LANE_OPEN_COLS),
            "stage2 lane opening",
        )?
        .claimed_values,
        &proof.stage2.lane_values_at_twist,
        "stage2 lane opening values",
    )?;
    expect_equal_k_slice(
        &find_manifest_claim(
            &proof.kernel_opening_manifest,
            CommitmentId::DecodeHandoff,
            &proof.stage2.cycle_point,
            &DECODE_HANDOFF_POLY_IDS,
            "stage2 decode handoff opening",
        )?
        .claimed_values,
        &proof.stage2.handoff_values_at_twist,
        "stage2 decode handoff values",
    )?;
    let reg_point: Vec<K> = proof
        .stage2
        .reg_addr_point
        .iter()
        .copied()
        .chain(proof.stage2.cycle_point.iter().copied())
        .collect();
    let ram_point: Vec<K> = proof
        .stage2
        .ram_addr_point
        .iter()
        .copied()
        .chain(proof.stage2.cycle_point.iter().copied())
        .collect();
    let reg_claim = find_manifest_claim(
        &proof.kernel_opening_manifest,
        CommitmentId::RegTwist,
        &reg_point,
        &REG_TWIST_POLY_IDS,
        "stage2 register twist opening",
    )?;
    if reg_claim.claimed_values.len() != REG_TWIST_POLY_IDS.len() {
        return Err(SimpleKernelError::OpeningFailed(
            "stage2 register twist opening has the wrong arity".into(),
        ));
    }
    let ram_claim = find_manifest_claim(
        &proof.kernel_opening_manifest,
        CommitmentId::RamTwist,
        &ram_point,
        &RAM_TWIST_POLY_IDS,
        "stage2 RAM twist opening",
    )?;
    if ram_claim.claimed_values.len() != RAM_TWIST_POLY_IDS.len() {
        return Err(SimpleKernelError::OpeningFailed(
            "stage2 RAM twist opening has the wrong arity".into(),
        ));
    }

    let shift_claim = find_manifest_claim(
        &proof.kernel_opening_manifest,
        CommitmentId::Lane,
        &proof.stage3.shift_proof.source_point,
        &lane_poly_ids(&STAGE3_SHIFT_OPEN_COLS),
        "stage3 shift opening",
    )?;
    if shift_claim.claimed_values.len() != STAGE3_SHIFT_OPEN_COLS.len() {
        return Err(SimpleKernelError::OpeningFailed(
            "stage3 shift opening has the wrong arity".into(),
        ));
    }
    expect_equal_k(
        proof.stage3.shift_opening_values[0],
        shift_claim.claimed_values[0],
        "stage3 shift opening PC value",
    )?;
    expect_equal_k_slice(
        &shift_claim.claimed_values,
        &proof.stage3.shift_opening_values,
        "stage3 shift opening values",
    )?;
    let stage3_start_point = vec![K::ZERO; cycle_bits];
    expect_equal_k_slice(
        &find_manifest_claim(
            &proof.kernel_opening_manifest,
            CommitmentId::Lane,
            &stage3_start_point,
            &lane_poly_ids(&STAGE3_START_BOUNDARY_COLS),
            "stage3 start-boundary opening",
        )?
        .claimed_values,
        &proof.stage3.start_boundary_values,
        "stage3 start-boundary values",
    )?;
    let stage3_final_point = bits_point(semantic_rows - 1, cycle_bits);
    expect_equal_k_slice(
        &find_manifest_claim(
            &proof.kernel_opening_manifest,
            CommitmentId::Lane,
            &stage3_final_point,
            &lane_poly_ids(&STAGE3_FINAL_BOUNDARY_COLS),
            "stage3 final-boundary opening",
        )?
        .claimed_values,
        &proof.stage3.final_boundary_values,
        "stage3 final-boundary values",
    )?;

    let row_binding_ids: Vec<usize> = (0..23).collect();
    let prepared_steps: Vec<_> = proof
        .stage3
        .row_bindings
        .iter()
        .map(|row_binding| {
            let row_point: Vec<K> = row_binding
                .row_bits
                .iter()
                .map(|&bit| if bit { K::ONE } else { K::ZERO })
                .collect();
            expect_equal_k_slice(
                &find_manifest_claim(
                    &proof.kernel_opening_manifest,
                    CommitmentId::Lane,
                    &row_point,
                    &row_binding_ids,
                    &format!("stage3 row-binding opening {}", row_binding.row_index),
                )?
                .claimed_values,
                &row_binding.opened_values,
                &format!("stage3 row-binding values {}", row_binding.row_index),
            )?;
            build_root_step(row_binding, cycle_bits, root_params, root_log)
        })
        .collect::<Result<_, _>>()?;
    let public_steps = prepared_steps
        .iter()
        .map(crate::proof::StepInput::instance)
        .collect();

    Ok(SimpleKernelOutput {
        prepared_steps,
        public_steps,
        kernel_opening_manifest: proof.kernel_opening_manifest.clone(),
    })
}
