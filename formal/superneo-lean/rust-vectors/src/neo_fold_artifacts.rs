use std::collections::BTreeMap;
use std::fmt::Write as _;
use std::fs;
use std::path::{Path, PathBuf};
use std::sync::Arc;

use neo_ajtai::AjtaiSModule;
use neo_ajtai::Commitment;
use neo_ccs::relations::CeClaim;
use neo_ccs::traits::SModuleHomomorphism;
use neo_ccs::{r1cs_to_ccs, CcsMatrix, CcsStructure, Mat};
use neo_fold::pi_ccs::FoldingMode;
use neo_fold::session::{FoldingSession, NeoStep, StepArtifacts, StepSpec};
use neo_fold::shard::{
    fold_shard_prove_with_witnesses_and_audit, fold_shard_prove_with_witnesses_with_step_offset_and_audit,
    fold_shard_verify, fold_shard_verify_with_step_offset, RlcDecProof, ShardProof, ShardSegmentKind,
    ShardProofAudit, ShardSegmentMeta, StepProof,
};
use neo_fold::sumcheck;
use neo_fold::time_opening::joint_lane::build_stage8_fold_lane_plan;
use neo_math::{Fq as F, KExtensions, K};
use neo_memory::ajtai::encode_vector_for_ccs_m;
use neo_memory::witness::{StepInstanceBundle, StepWitnessBundle};
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::{PrimeCharacteristicRing, PrimeField64};
use serde::{Deserialize, Serialize};

#[path = "../../../../crates/neo-fold/tests/common/fixtures.rs"]
mod fixtures;
mod neo_fold_artifact_codegen;

use neo_fold_artifact_codegen::{
    write_case_module_with_layout, write_generated_module_with_layout, ArtifactCodegenLayout,
    DEFAULT_ARTIFACT_LAYOUT,
};

#[path = "neo_fold_integration_artifacts.rs"]
mod neo_fold_integration_artifacts;

const STARSTREAM_SESSION_SEED: [u8; 32] = [0x53; 32];
const CONTROL_NEXT_PC_LINEAR_LABEL: &str = "control/next_pc_linear";

#[derive(Debug, Deserialize, Serialize)]
struct TestExport {
    metadata: Metadata,
    ivc_params: IvcParams,
    steps: Vec<StepData>,
}

#[derive(Debug, Deserialize, Serialize)]
struct Metadata {
    test_name: String,
    field: String,
    modulus: String,
    num_steps: usize,
    should_fail: bool,
    failure_reason: Option<String>,
}

#[derive(Debug, Deserialize, Serialize)]
struct IvcParams {
    y0: Vec<String>,
    step_spec: JsonStepSpec,
}

#[derive(Debug, Deserialize, Serialize)]
struct JsonStepSpec {
    y_len: usize,
    const1_index: usize,
    y_step_indices: Vec<usize>,
    y_prev_indices: Vec<usize>,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
struct StepData {
    step_idx: usize,
    instruction: String,
    witness: WitnessData,
    r1cs: R1csData,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
struct WitnessData {
    instance: Vec<String>,
    witness: Vec<String>,
    z_full: Vec<String>,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
struct R1csData {
    num_constraints: usize,
    num_variables: usize,
    num_public_inputs: usize,
    a_sparse: Vec<(usize, usize, String)>,
    b_sparse: Vec<(usize, usize, String)>,
    c_sparse: Vec<(usize, usize, String)>,
}

#[derive(Clone)]
struct NoInputs;

struct StarstreamStepCircuit {
    steps: Vec<StepData>,
    step_spec: StepSpec,
    step_ccs: Arc<CcsStructure<F>>,
}

impl NeoStep for StarstreamStepCircuit {
    type ExternalInputs = NoInputs;

    fn state_len(&self) -> usize {
        self.step_spec.y_len
    }

    fn step_spec(&self) -> StepSpec {
        self.step_spec.clone()
    }

    fn synthesize_step(&mut self, step_idx: usize, _y_prev: &[F], _inputs: &Self::ExternalInputs) -> StepArtifacts {
        let z = extract_witness(&self.steps[step_idx].witness);
        let z_padded = pad_witness_to_m(z, self.step_ccs.m);
        StepArtifacts {
            ccs: self.step_ccs.clone(),
            witness: z_padded,
            public_app_inputs: vec![],
            spec: self.step_spec.clone(),
        }
    }
}

#[derive(Clone)]
struct KPair {
    c0: u64,
    c1: u64,
}

#[derive(Clone)]
struct SparseEntryRepr {
    row: usize,
    col: usize,
    value: u64,
}

#[derive(Clone)]
struct CcsMatrixRepr {
    nrows: usize,
    ncols: usize,
    identity: bool,
    entries: Vec<SparseEntryRepr>,
}

#[derive(Clone)]
struct PolyTermRepr {
    coeff: u64,
    exps: Vec<usize>,
}

#[derive(Clone)]
struct CcsRepr {
    n: usize,
    m: usize,
    matrices: Vec<CcsMatrixRepr>,
    poly_terms: Vec<PolyTermRepr>,
}

#[derive(Clone)]
struct CommitmentRepr {
    cols: Vec<Vec<u64>>,
}

#[derive(Clone)]
struct TranscriptRepr {
    claimed_sum: KPair,
    degree_bound: usize,
    round_polys: Vec<Vec<KPair>>,
    challenges: Vec<KPair>,
    final_sum: KPair,
}

#[derive(Clone)]
struct BatchedTimeRepr {
    claimed_sums: Vec<KPair>,
    degree_bounds: Vec<usize>,
    labels: Vec<String>,
    round_polys: Vec<Vec<Vec<KPair>>>,
    shared_challenges: Vec<KPair>,
}

#[derive(Clone)]
struct ClaimRepr {
    commitment: CommitmentRepr,
    r: Vec<KPair>,
    s_col: Vec<KPair>,
    m_in: usize,
    x_col_indices: Vec<usize>,
    x: Vec<Vec<u64>>,
    y_ring: Vec<Vec<KPair>>,
    ct: Vec<KPair>,
    aux_openings: Vec<KPair>,
    y_zcol: Vec<KPair>,
    fold_digest: Vec<u8>,
    c_step_coords: Vec<u64>,
    u_offset: usize,
    u_len: usize,
}

#[derive(Clone)]
struct LaneRepr {
    ccs: CcsRepr,
    fold_base: u32,
    inputs: Vec<ClaimRepr>,
    rho_count: usize,
    rho_coeffs: Vec<Vec<u64>>,
    parent: ClaimRepr,
    children: Vec<ClaimRepr>,
}

#[derive(Clone)]
struct LaneWitnessChainRepr {
    input_witness_z: Vec<Vec<Vec<u64>>>,
    parent_witness_z: Vec<Vec<u64>>,
    child_witness_z: Vec<Vec<Vec<u64>>>,
}

#[derive(Clone)]
struct SegmentMetaRepr {
    route_a: bool,
    public_steps: usize,
    proof_steps: usize,
}

#[derive(Clone)]
struct StepArtifactRepr {
    route_a: bool,
    compressed_substeps: usize,
    mcs_batch_public_input: Vec<Vec<u64>>,
    mcs_batch_private_input: Vec<Vec<u64>>,
    mcs_batch_witness_z: Vec<Vec<Vec<u64>>>,
    mcs_batch_commitments: Vec<CommitmentRepr>,
    mcs_public_input: Vec<u64>,
    mcs_private_input: Vec<u64>,
    mcs_witness_z: Vec<Vec<u64>>,
    mcs_commitment: CommitmentRepr,
    pi_ccs: TranscriptRepr,
    pi_ccs_nc: TranscriptRepr,
    cpu_sumcheck: TranscriptRepr,
    shift_sumcheck: TranscriptRepr,
    batched_time: BatchedTimeRepr,
    ccs_out: Vec<ClaimRepr>,
    main_lane: LaneRepr,
    main_lane_input_witness_z: Vec<Vec<Vec<u64>>>,
    main_lane_parent_witness_z: Vec<Vec<u64>>,
    main_lane_child_witness_z: Vec<Vec<Vec<u64>>>,
    val_lane_witnesses: Vec<LaneWitnessChainRepr>,
    val_inputs: Vec<ClaimRepr>,
    val_lanes: Vec<LaneRepr>,
    wb_lane_witnesses: Vec<LaneWitnessChainRepr>,
    wb_inputs: Vec<ClaimRepr>,
    wb_lanes: Vec<LaneRepr>,
    wp_lane_witnesses: Vec<LaneWitnessChainRepr>,
    wp_inputs: Vec<ClaimRepr>,
    wp_lanes: Vec<LaneRepr>,
    stage8_lanes: Vec<LaneRepr>,
}

#[derive(Clone)]
pub(crate) struct ArtifactRepr {
    scenario_name: String,
    should_fail: bool,
    fold_base: u32,
    k_rho: u32,
    public_step_count: usize,
    proof_step_count: usize,
    ccs: CcsRepr,
    acc_init_main_witness_z: Vec<Vec<Vec<u64>>>,
    acc_init_main: Vec<ClaimRepr>,
    final_main: Vec<ClaimRepr>,
    final_val: Vec<ClaimRepr>,
    steps: Vec<StepArtifactRepr>,
    segment_meta: Vec<SegmentMetaRepr>,
}

fn parse_field_element(s: &str) -> F {
    if let Some(hex) = s.strip_prefix("0x") {
        F::from_u64(u64::from_str_radix(hex, 16).expect("valid hex"))
    } else {
        F::from_u64(s.parse::<u64>().expect("valid decimal"))
    }
}

fn sparse_to_dense_mat(sparse: &[(usize, usize, String)], rows: usize, cols: usize) -> Mat<F> {
    let mut data = vec![F::ZERO; rows * cols];
    for (row, col, val_str) in sparse {
        data[row * cols + col] = parse_field_element(val_str);
    }
    Mat::from_row_major(rows, cols, data)
}

fn build_step_ccs(r1cs: &R1csData) -> CcsStructure<F> {
    let n = r1cs.num_constraints;
    let m = r1cs.num_variables;
    let m_padded = n.max(m);
    let a = sparse_to_dense_mat(&r1cs.a_sparse, n, m_padded);
    let b = sparse_to_dense_mat(&r1cs.b_sparse, n, m_padded);
    let c = sparse_to_dense_mat(&r1cs.c_sparse, n, m_padded);
    let s0 = r1cs_to_ccs(a, b, c);
    s0.ensure_identity_first_owned()
        .expect("ensure_identity_first_owned should succeed")
}

fn extract_witness(witness_data: &WitnessData) -> Vec<F> {
    witness_data
        .z_full
        .iter()
        .map(|s| parse_field_element(s))
        .collect()
}

fn pad_witness_to_m(mut z: Vec<F>, m_target: usize) -> Vec<F> {
    z.resize(m_target, F::ZERO);
    z
}

fn load_test_export() -> TestExport {
    let manifest_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    let json_path = manifest_dir.join("../../../crates/neo-fold/starstream-tests/test_starstream_tx_export_valid.json");
    let json_content = fs::read_to_string(&json_path).expect("failed to read starstream export JSON");
    serde_json::from_str(&json_content).expect("failed to parse starstream export JSON")
}

fn k_pair(value: &K) -> KPair {
    let coeffs = value.as_coeffs();
    KPair {
        c0: coeffs[0].as_canonical_u64(),
        c1: coeffs[1].as_canonical_u64(),
    }
}

fn f_u64(value: F) -> u64 {
    value.as_canonical_u64()
}

fn field_vec_repr(values: &[F]) -> Vec<u64> {
    values.iter().map(|&value| f_u64(value)).collect()
}

fn field_matrix_repr(matrix: &Mat<F>) -> Vec<Vec<u64>> {
    (0..matrix.rows())
        .map(|row| {
            (0..matrix.cols())
                .map(|col| f_u64(matrix[(row, col)]))
                .collect()
        })
        .collect()
}

fn k_vec_repr(values: &[K]) -> Vec<KPair> {
    values.iter().map(k_pair).collect()
}

fn k_matrix_repr(rows: &[Vec<K>]) -> Vec<Vec<KPair>> {
    rows.iter()
        .map(|row| row.iter().map(k_pair).collect())
        .collect()
}

fn commitment_repr(commitment: &Commitment) -> CommitmentRepr {
    CommitmentRepr {
        cols: (0..commitment.kappa)
            .map(|col| {
                commitment
                    .col(col)
                    .iter()
                    .map(|&value| f_u64(value))
                    .collect()
            })
            .collect(),
    }
}

fn ccs_matrix_repr(matrix: &CcsMatrix<F>) -> CcsMatrixRepr {
    match matrix {
        CcsMatrix::Identity { n } => CcsMatrixRepr {
            nrows: *n,
            ncols: *n,
            identity: true,
            entries: Vec::new(),
        },
        CcsMatrix::Csc(csc) => {
            let mut entries = Vec::with_capacity(csc.vals.len());
            for col in 0..csc.ncols {
                for idx in csc.col_ptr[col]..csc.col_ptr[col + 1] {
                    entries.push(SparseEntryRepr {
                        row: csc.row_idx[idx],
                        col,
                        value: f_u64(csc.vals[idx]),
                    });
                }
            }
            CcsMatrixRepr {
                nrows: csc.nrows,
                ncols: csc.ncols,
                identity: false,
                entries,
            }
        }
    }
}

fn ccs_repr(ccs: &CcsStructure<F>) -> CcsRepr {
    CcsRepr {
        n: ccs.n,
        m: ccs.m,
        matrices: ccs.matrices.iter().map(ccs_matrix_repr).collect(),
        poly_terms: ccs
            .f
            .terms()
            .iter()
            .map(|term| PolyTermRepr {
                coeff: f_u64(term.coeff),
                exps: term.exps.iter().map(|&exp| exp as usize).collect(),
            })
            .collect(),
    }
}

fn rho_coeff_repr(rho: &Mat<F>) -> Vec<u64> {
    (0..neo_math::D).map(|idx| f_u64(rho[(idx, 0)])).collect()
}

fn prefix_x_col_indices(m_in: usize) -> Vec<usize> {
    (0..m_in).collect()
}

fn claim_x_col_indices_for_export<L>(
    _label: &str,
    _params: &neo_params::NeoParams,
    _ccs: &CcsStructure<F>,
    _l: &L,
    claim: &CeClaim<neo_ajtai::Commitment, F, K>,
    _witness: &Mat<F>,
) -> Vec<usize>
where
    L: SModuleHomomorphism<F, neo_ajtai::Commitment> + Sync,
{
    // These indices are refinement/export metadata only. Real Rust artifact validation
    // checks the public folding relations and witness-chain equalities separately; we do
    // not block artifact export on reconstructing a per-claim CE-opening projection here.
    prefix_x_col_indices(claim.m_in)
}

fn claim_repr(claim: &CeClaim<neo_ajtai::Commitment, F, K>, x_col_indices: Vec<usize>) -> ClaimRepr {
    ClaimRepr {
        commitment: commitment_repr(&claim.c),
        r: k_vec_repr(&claim.r),
        s_col: k_vec_repr(&claim.s_col),
        m_in: claim.m_in,
        x_col_indices,
        x: field_matrix_repr(&claim.X),
        y_ring: k_matrix_repr(&claim.y_ring),
        ct: k_vec_repr(&claim.ct),
        aux_openings: k_vec_repr(&claim.aux_openings),
        y_zcol: k_vec_repr(&claim.y_zcol),
        fold_digest: claim.fold_digest.to_vec(),
        c_step_coords: field_vec_repr(&claim.c_step_coords),
        u_offset: claim.u_offset,
        u_len: claim.u_len,
    }
}

fn lane_repr(
    lane_ccs: &CcsStructure<F>,
    fold_base: u32,
    inputs: Vec<ClaimRepr>,
    lane: &RlcDecProof,
    parent: ClaimRepr,
    children: Vec<ClaimRepr>,
) -> LaneRepr {
    LaneRepr {
        ccs: ccs_repr(lane_ccs),
        fold_base,
        inputs,
        rho_count: lane.rlc_rhos.len(),
        rho_coeffs: lane
            .rlc_rhos
            .iter()
            .map(|rho| rho_coeff_repr(rho.as_mat()))
            .collect(),
        parent,
        children,
    }
}

fn transcript_repr(
    claimed_sum: K,
    degree_bound: usize,
    round_polys: &[Vec<K>],
    challenges: &[K],
    final_sum: K,
) -> TranscriptRepr {
    TranscriptRepr {
        claimed_sum: k_pair(&claimed_sum),
        degree_bound,
        round_polys: round_polys
            .iter()
            .map(|round| round.iter().map(k_pair).collect())
            .collect(),
        challenges: challenges.iter().map(k_pair).collect(),
        final_sum: k_pair(&final_sum),
    }
}

fn degree_bound_from_rounds(round_polys: &[Vec<K>]) -> usize {
    round_polys
        .first()
        .map(|poly| poly.len().saturating_sub(1))
        .unwrap_or(0)
}

fn label_string(label: &[u8]) -> String {
    String::from_utf8_lossy(label).into_owned()
}

fn route_a_step(step: &StepProof) -> bool {
    !step.mem.proofs.is_empty()
        || !step.batched_time.claimed_sums.is_empty()
        || !step.val_fold.is_empty()
        || !step.wb_fold.is_empty()
        || !step.wp_fold.is_empty()
        || !step.stage8_fold.is_empty()
}

fn batch_counts(public_steps: usize, proof_steps: usize) -> Vec<usize> {
    assert!(proof_steps > 0, "proof_steps must be positive");
    assert!(
        public_steps >= proof_steps,
        "public steps must cover every proof step (public_steps={public_steps}, proof_steps={proof_steps})"
    );
    let batch_size = public_steps.div_ceil(proof_steps);
    let mut remaining_public = public_steps;
    let mut remaining_proof = proof_steps;
    let mut out = Vec::with_capacity(proof_steps);
    while remaining_proof > 0 {
        let min_reserved = remaining_proof - 1;
        let take = core::cmp::min(batch_size, remaining_public - min_reserved);
        out.push(take);
        remaining_public -= take;
        remaining_proof -= 1;
    }
    debug_assert_eq!(out.iter().sum::<usize>(), public_steps);
    out
}

fn proof_step_batches<'a>(
    steps_witness: &'a [StepWitnessBundle<neo_ajtai::Commitment, F, K>],
    proof: &ShardProof,
) -> Vec<&'a [StepWitnessBundle<neo_ajtai::Commitment, F, K>]> {
    if proof.steps.is_empty() {
        assert!(steps_witness.is_empty(), "non-empty witness list with empty proof");
        return Vec::new();
    }

    let mut out = Vec::with_capacity(proof.steps.len());
    if let Some(meta) = proof.segment_meta.as_ref() {
        if !meta.is_empty() {
            let mut step_cursor = 0usize;
            for entry in meta {
                let counts = batch_counts(entry.public_steps, entry.proof_steps);
                let mut local_cursor = 0usize;
                for count in counts {
                    out.push(&steps_witness[step_cursor + local_cursor..step_cursor + local_cursor + count]);
                    local_cursor += count;
                }
                assert_eq!(
                    local_cursor, entry.public_steps,
                    "segment proof/public step partition mismatch"
                );
                step_cursor += entry.public_steps;
            }
            assert_eq!(
                step_cursor,
                steps_witness.len(),
                "segment metadata did not cover all public steps"
            );
            assert_eq!(
                out.len(),
                proof.steps.len(),
                "segment metadata did not cover all proof steps"
            );
            return out;
        }
    }

    let mut cursor = 0usize;
    for count in batch_counts(steps_witness.len(), proof.steps.len()) {
        out.push(&steps_witness[cursor..cursor + count]);
        cursor += count;
    }
    assert_eq!(
        cursor,
        steps_witness.len(),
        "batch partition did not consume all public steps"
    );
    out
}

fn expand_route_a_chunk_steps(container: &StepProof, public_steps: usize, meta_idx: usize) -> Vec<StepProof> {
    assert!(
        public_steps > 0,
        "route-a segment metadata entry {meta_idx} must have public_steps>=1"
    );

    let mut out: Vec<StepProof> = Vec::with_capacity(public_steps);
    if let Some(prefix) = container.compressed_substeps.as_ref() {
        assert!(
            !prefix.iter().any(|step| step.compressed_substeps.is_some()),
            "route-a compressed chunk at entry {meta_idx} must not contain nested compressed_substeps"
        );
        out.extend(prefix.iter().cloned());
    } else if public_steps > 1 {
        panic!(
            "route-a segment metadata entry {meta_idx} expects {public_steps} public steps but container has no compressed_substeps"
        );
    }

    let mut terminal = container.clone();
    terminal.compressed_substeps = None;
    out.push(terminal);

    assert_eq!(
        out.len(),
        public_steps,
        "route-a compressed chunk length mismatch at entry {meta_idx} (materialized_steps={}, public_steps={public_steps})",
        out.len()
    );
    out
}

fn materialized_proof_steps<'a>(
    steps_witness: &'a [StepWitnessBundle<neo_ajtai::Commitment, F, K>],
    proof: &ShardProof,
) -> Vec<(StepProof, &'a [StepWitnessBundle<neo_ajtai::Commitment, F, K>])> {
    if proof.steps.is_empty() {
        assert!(steps_witness.is_empty(), "non-empty witness list with empty proof");
        return Vec::new();
    }

    let mut out: Vec<(StepProof, &'a [StepWitnessBundle<neo_ajtai::Commitment, F, K>])> = Vec::new();
    if let Some(meta) = proof.segment_meta.as_ref() {
        if !meta.is_empty() {
            let mut step_cursor = 0usize;
            let mut proof_cursor = 0usize;
            for (meta_idx, entry) in meta.iter().enumerate() {
                let segment_wits = &steps_witness[step_cursor..step_cursor + entry.public_steps];
                if matches!(entry.kind, ShardSegmentKind::RouteA) {
                    assert_eq!(
                        entry.proof_steps, 1,
                        "route-a segment metadata entry {meta_idx} must have proof_steps=1 in exported artifacts"
                    );
                    let container = &proof.steps[proof_cursor];
                    let chunk_steps = expand_route_a_chunk_steps(container, entry.public_steps, meta_idx);
                    for (chunk_step, wit) in chunk_steps.into_iter().zip(segment_wits.iter()) {
                        out.push((chunk_step, std::slice::from_ref(wit)));
                    }
                } else {
                    let counts = batch_counts(entry.public_steps, entry.proof_steps);
                    let mut local_cursor = 0usize;
                    for (subproof, count) in proof.steps[proof_cursor..proof_cursor + entry.proof_steps]
                        .iter()
                        .zip(counts.into_iter())
                    {
                        out.push((subproof.clone(), &segment_wits[local_cursor..local_cursor + count]));
                        local_cursor += count;
                    }
                    assert_eq!(
                        local_cursor, entry.public_steps,
                        "ccs-only segment proof/public step partition mismatch at entry {meta_idx}"
                    );
                }
                step_cursor += entry.public_steps;
                proof_cursor += entry.proof_steps;
            }
            assert_eq!(
                step_cursor,
                steps_witness.len(),
                "segment metadata did not cover all public steps"
            );
            assert_eq!(
                proof_cursor,
                proof.steps.len(),
                "segment metadata did not cover all proof steps"
            );
            return out;
        }
    }

    proof
        .steps
        .iter()
        .cloned()
        .zip(proof_step_batches(steps_witness, proof))
        .collect()
}

fn ccs_with_lane_n(base: &CcsStructure<F>, ell_lane: usize) -> CcsStructure<F> {
    let n_lane = 1usize
        .checked_shl(ell_lane as u32)
        .expect("lane r dimension should fit in usize");
    let mut out = base.clone();
    out.n = n_lane;
    out
}

fn step_repr<L>(
    scenario_name: &str,
    proof_step_idx: usize,
    step: &StepProof,
    audit_step: &neo_fold::shard::StepWitnessAudit<F>,
    step_witness_batch: &[StepWitnessBundle<neo_ajtai::Commitment, F, K>],
    ccs: &CcsStructure<F>,
    params: &neo_params::NeoParams,
    l: &L,
    fold_base: u32,
    _accumulator_wit: &[Mat<F>],
) -> StepArtifactRepr
where
    L: SModuleHomomorphism<F, neo_ajtai::Commitment> + Sync,
{
    let step_witness = step_witness_batch
        .first()
        .expect("exported proof step must cover at least one public step");
    let pi_ccs = transcript_repr(
        step.fold
            .ccs_proof
            .sc_initial_sum
            .expect("valid Pi_CCS proof has initial sum"),
        degree_bound_from_rounds(&step.fold.ccs_proof.sumcheck_rounds),
        &step.fold.ccs_proof.sumcheck_rounds,
        &step.fold.ccs_proof.sumcheck_challenges,
        step.fold.ccs_proof.sumcheck_final,
    );
    let pi_ccs_nc = transcript_repr(
        step.fold.ccs_proof.sc_initial_sum_nc.unwrap_or(K::ZERO),
        degree_bound_from_rounds(&step.fold.ccs_proof.sumcheck_rounds_nc),
        &step.fold.ccs_proof.sumcheck_rounds_nc,
        &step.fold.ccs_proof.sumcheck_challenges_nc,
        step.fold.ccs_proof.sumcheck_final_nc,
    );
    let cpu_sumcheck = transcript_repr(
        step.fold.cpu_sumcheck.claimed_sum,
        degree_bound_from_rounds(&step.fold.cpu_sumcheck.round_polys),
        &step.fold.cpu_sumcheck.round_polys,
        &step.fold.cpu_sumcheck.r_time,
        if step.fold.cpu_sumcheck.round_polys.is_empty() {
            step.fold.cpu_sumcheck.claimed_sum
        } else {
            let last_poly = step
                .fold
                .cpu_sumcheck
                .round_polys
                .last()
                .expect("non-empty cpu sumcheck rounds");
            let last_challenge = *step
                .fold
                .cpu_sumcheck
                .r_time
                .last()
                .expect("non-empty cpu sumcheck challenges");
            sumcheck::poly_eval_k(last_poly, last_challenge)
        },
    );
    let shift_sumcheck = transcript_repr(
        step.fold.shift_sumcheck.claimed_sum,
        degree_bound_from_rounds(&step.fold.shift_sumcheck.round_polys),
        &step.fold.shift_sumcheck.round_polys,
        &step.fold.shift_sumcheck.r_time,
        if step.fold.shift_sumcheck.round_polys.is_empty() {
            step.fold.shift_sumcheck.claimed_sum
        } else {
            let last_poly = step
                .fold
                .shift_sumcheck
                .round_polys
                .last()
                .expect("non-empty shift sumcheck rounds");
            let last_challenge = *step
                .fold
                .shift_sumcheck
                .r_time
                .last()
                .expect("non-empty shift sumcheck challenges");
            sumcheck::poly_eval_k(last_poly, last_challenge)
        },
    );
    let batched_time = BatchedTimeRepr {
        claimed_sums: step.batched_time.claimed_sums.iter().map(k_pair).collect(),
        degree_bounds: step.batched_time.degree_bounds.clone(),
        labels: step
            .batched_time
            .labels
            .iter()
            .map(|label| label_string(label))
            .collect(),
        round_polys: step
            .batched_time
            .round_polys
            .iter()
            .map(|claim_rounds| {
                claim_rounds
                    .iter()
                    .map(|round| round.iter().map(k_pair).collect())
                    .collect()
            })
            .collect(),
        shared_challenges: step.fold.shift_sumcheck.r_time.iter().map(k_pair).collect(),
    };
    let mut ccs_out_x_cols = Vec::with_capacity(step.fold.ccs_out.len());
    let main_lane_proof = RlcDecProof {
        rlc_rhos: step.fold.rlc_rhos.clone(),
        rlc_parent: step.fold.rlc_parent.clone(),
        dec_children: step.fold.dec_children.clone(),
    };
    let main_lane_input_wits = &audit_step.main_lane.input_witnesses;
    let main_lane_parent_wit = &audit_step.main_lane.parent_witness;
    let main_lane_child_wits = &audit_step.main_lane.child_witnesses;
    assert_eq!(
        main_lane_input_wits.len(),
        step.fold.ccs_out.len(),
        "{scenario_name}: proof step {proof_step_idx} main-lane audit/input count mismatch",
    );
    for (idx, (claim, witness)) in step.fold.ccs_out.iter().zip(main_lane_input_wits.iter()).enumerate() {
        ccs_out_x_cols.push(claim_x_col_indices_for_export(
            &format!("{scenario_name}: proof step {proof_step_idx} main-lane input[{idx}]"),
            params,
            ccs,
            l,
            claim,
            witness,
        ));
    }
    let ccs_out: Vec<_> = step
        .fold
        .ccs_out
        .iter()
        .zip(ccs_out_x_cols.iter())
        .map(|(claim, x_cols)| claim_repr(claim, x_cols.clone()))
        .collect();
    let main_lane_parent_x_cols = claim_x_col_indices_for_export(
        &format!("{scenario_name}: proof step {proof_step_idx} main-lane parent"),
        params,
        ccs,
        l,
        &step.fold.rlc_parent,
        main_lane_parent_wit,
    );
    assert_eq!(
        main_lane_child_wits.len(),
        step.fold.dec_children.len(),
        "{scenario_name}: proof step {proof_step_idx} main-lane child count mismatch",
    );
    let mut main_lane_child_x_cols = Vec::with_capacity(step.fold.dec_children.len());
    for (idx, (child_claim, child_wit)) in step.fold.dec_children.iter().zip(main_lane_child_wits.iter()).enumerate() {
        main_lane_child_x_cols.push(claim_x_col_indices_for_export(
            &format!("{scenario_name}: proof step {proof_step_idx} main-lane child[{idx}]"),
            params,
            ccs,
            l,
            child_claim,
            child_wit,
        ));
    }
    let main_lane = lane_repr(
        ccs,
        fold_base,
        ccs_out.clone(),
        &main_lane_proof,
        claim_repr(&step.fold.rlc_parent, main_lane_parent_x_cols),
        step.fold
            .dec_children
            .iter()
            .zip(main_lane_child_x_cols.iter())
            .map(|(claim, x_cols)| claim_repr(claim, x_cols.clone()))
            .collect(),
    );
    let stage8_lanes = match build_stage8_fold_lane_plan(
        &step.fold.joint_opening_lane,
        &step.fold.opening_unification,
        step.fold.time_t,
    )
        .expect("stage8 plan should build for exported artifact")
    {
        Some(plan) => {
            assert_eq!(
                step.stage8_fold.len(),
                1,
                "stage8 exported proof should be a single lane"
            );
            let stage8_ccs = plan.ccs.clone();
            step.stage8_fold
                .iter()
                .map(|lane| {
                    lane_repr(
                        &stage8_ccs,
                        neo_fold::time_opening::STAGE8_TIME_DECOMP_BASE,
                        plan.claims.iter().map(|claim| claim_repr(claim, prefix_x_col_indices(claim.m_in))).collect(),
                        lane,
                        claim_repr(&lane.rlc_parent, prefix_x_col_indices(lane.rlc_parent.m_in)),
                        lane.dec_children
                            .iter()
                            .map(|claim| claim_repr(claim, prefix_x_col_indices(claim.m_in)))
                            .collect(),
                    )
                })
                .collect()
        }
        None => {
            assert!(
                step.stage8_fold.is_empty(),
                "stage8 proofs must be empty when no plan exists"
            );
            Vec::new()
        }
    };
    let val_inputs: Vec<_> = step.mem.val_me_claims.iter().map(|claim| claim_repr(claim, prefix_x_col_indices(claim.m_in))).collect();
    let wb_inputs: Vec<_> = step.mem.wb_me_claims.iter().map(|claim| claim_repr(claim, prefix_x_col_indices(claim.m_in))).collect();
    let wp_inputs: Vec<_> = step.mem.wp_me_claims.iter().map(|claim| claim_repr(claim, prefix_x_col_indices(claim.m_in))).collect();
    let val_lane_witnesses: Vec<_> = step
        .val_fold
        .iter()
        .enumerate()
        .map(|(idx, lane)| {
            let lane_ccs = ccs_with_lane_n(ccs, step.mem.val_me_claims[idx].r.len());
            let lane_audit = &audit_step.val_lanes[idx];
            assert_eq!(lane_audit.input_witnesses.len(), 1, "val-lane audit must have one input witness");
            let _ = claim_x_col_indices_for_export("aux-lane parent", params, &lane_ccs, l, &lane.rlc_parent, &lane_audit.parent_witness);
            for (child_idx, (child_claim, child_wit)) in lane.dec_children.iter().zip(lane_audit.child_witnesses.iter()).enumerate() {
                let _ = claim_x_col_indices_for_export(
                    &format!("aux-lane child[{child_idx}]"),
                    params,
                    &lane_ccs,
                    l,
                    child_claim,
                    child_wit,
                );
            }
            LaneWitnessChainRepr {
                input_witness_z: lane_audit.input_witnesses.iter().map(field_matrix_repr).collect(),
                parent_witness_z: field_matrix_repr(&lane_audit.parent_witness),
                child_witness_z: lane_audit.child_witnesses.iter().map(field_matrix_repr).collect(),
            }
        })
        .collect();
    let wb_lane_witnesses: Vec<_> = step
        .wb_fold
        .iter()
        .enumerate()
        .map(|(idx, lane)| {
            let lane_ccs = ccs_with_lane_n(ccs, step.mem.wb_me_claims[idx].r.len());
            let lane_audit = &audit_step.wb_lanes[idx];
            assert_eq!(lane_audit.input_witnesses.len(), 1, "wb-lane audit must have one input witness");
            let _ = claim_x_col_indices_for_export("aux-lane parent", params, &lane_ccs, l, &lane.rlc_parent, &lane_audit.parent_witness);
            for (child_idx, (child_claim, child_wit)) in lane.dec_children.iter().zip(lane_audit.child_witnesses.iter()).enumerate() {
                let _ = claim_x_col_indices_for_export(
                    &format!("aux-lane child[{child_idx}]"),
                    params,
                    &lane_ccs,
                    l,
                    child_claim,
                    child_wit,
                );
            }
            LaneWitnessChainRepr {
                input_witness_z: lane_audit.input_witnesses.iter().map(field_matrix_repr).collect(),
                parent_witness_z: field_matrix_repr(&lane_audit.parent_witness),
                child_witness_z: lane_audit.child_witnesses.iter().map(field_matrix_repr).collect(),
            }
        })
        .collect();
    let wp_lane_witnesses: Vec<_> = step
        .wp_fold
        .iter()
        .enumerate()
        .map(|(idx, lane)| {
            let lane_ccs = ccs_with_lane_n(ccs, step.mem.wp_me_claims[idx].r.len());
            let lane_audit = &audit_step.wp_lanes[idx];
            assert_eq!(lane_audit.input_witnesses.len(), 1, "wp-lane audit must have one input witness");
            let _ = claim_x_col_indices_for_export("aux-lane parent", params, &lane_ccs, l, &lane.rlc_parent, &lane_audit.parent_witness);
            for (child_idx, (child_claim, child_wit)) in lane.dec_children.iter().zip(lane_audit.child_witnesses.iter()).enumerate() {
                let _ = claim_x_col_indices_for_export(
                    &format!("aux-lane child[{child_idx}]"),
                    params,
                    &lane_ccs,
                    l,
                    child_claim,
                    child_wit,
                );
            }
            LaneWitnessChainRepr {
                input_witness_z: lane_audit.input_witnesses.iter().map(field_matrix_repr).collect(),
                parent_witness_z: field_matrix_repr(&lane_audit.parent_witness),
                child_witness_z: lane_audit.child_witnesses.iter().map(field_matrix_repr).collect(),
            }
        })
        .collect();

    StepArtifactRepr {
        route_a: route_a_step(step),
        compressed_substeps: step
            .compressed_substeps
            .as_ref()
            .map(|s| s.len())
            .unwrap_or(0),
        mcs_batch_public_input: step_witness_batch
            .iter()
            .map(|wit| field_vec_repr(&wit.mcs.0.x))
            .collect(),
        mcs_batch_private_input: step_witness_batch
            .iter()
            .map(|wit| field_vec_repr(&wit.mcs.1.w))
            .collect(),
        mcs_batch_witness_z: step_witness_batch
            .iter()
            .map(|wit| field_matrix_repr(&wit.mcs.1.Z))
            .collect(),
        mcs_batch_commitments: step_witness_batch
            .iter()
            .map(|wit| commitment_repr(&wit.mcs.0.c))
            .collect(),
        mcs_public_input: field_vec_repr(&step_witness.mcs.0.x),
        mcs_private_input: field_vec_repr(&step_witness.mcs.1.w),
        mcs_witness_z: field_matrix_repr(&step_witness.mcs.1.Z),
        mcs_commitment: commitment_repr(&step_witness.mcs.0.c),
        pi_ccs,
        pi_ccs_nc,
        cpu_sumcheck,
        shift_sumcheck,
        batched_time,
        ccs_out,
        main_lane,
        main_lane_input_witness_z: main_lane_input_wits.iter().map(field_matrix_repr).collect(),
        main_lane_parent_witness_z: field_matrix_repr(main_lane_parent_wit),
        main_lane_child_witness_z: main_lane_child_wits.iter().map(field_matrix_repr).collect(),
        val_lane_witnesses,
        val_inputs: val_inputs.clone(),
        val_lanes: step
            .val_fold
            .iter()
            .enumerate()
            .map(|(idx, lane)| {
                let lane_ccs = ccs_with_lane_n(ccs, step.mem.val_me_claims[idx].r.len());
                let lane_audit = &audit_step.val_lanes[idx];
                lane_repr(
                    &lane_ccs,
                    fold_base,
                    vec![claim_repr(
                        &step.mem.val_me_claims[idx],
                        claim_x_col_indices_for_export(
                            "aux-lane input",
                            params,
                            &lane_ccs,
                            l,
                            &step.mem.val_me_claims[idx],
                            &lane_audit.input_witnesses[0],
                        ),
                    )],
                    lane,
                    claim_repr(
                        &lane.rlc_parent,
                        claim_x_col_indices_for_export(
                            "aux-lane parent",
                            params,
                            &lane_ccs,
                            l,
                            &lane.rlc_parent,
                            &lane_audit.parent_witness,
                        ),
                    ),
                    lane
                        .dec_children
                        .iter()
                        .zip(lane_audit.child_witnesses.iter())
                        .map(|(claim, wit)| {
                            claim_repr(
                                claim,
                                claim_x_col_indices_for_export(
                                    "aux-lane child",
                                    params,
                                    &lane_ccs,
                                    l,
                                    claim,
                                    wit,
                                ),
                            )
                        })
                        .collect(),
                )
            })
            .collect(),
        wb_lane_witnesses,
        wb_inputs: wb_inputs.clone(),
        wb_lanes: step
            .wb_fold
            .iter()
            .enumerate()
            .map(|(idx, lane)| {
                let lane_ccs = ccs_with_lane_n(ccs, step.mem.wb_me_claims[idx].r.len());
                let lane_audit = &audit_step.wb_lanes[idx];
                lane_repr(
                    &lane_ccs,
                    fold_base,
                    vec![claim_repr(
                        &step.mem.wb_me_claims[idx],
                        claim_x_col_indices_for_export(
                            "aux-lane input",
                            params,
                            &lane_ccs,
                            l,
                            &step.mem.wb_me_claims[idx],
                            &lane_audit.input_witnesses[0],
                        ),
                    )],
                    lane,
                    claim_repr(
                        &lane.rlc_parent,
                        claim_x_col_indices_for_export(
                            "aux-lane parent",
                            params,
                            &lane_ccs,
                            l,
                            &lane.rlc_parent,
                            &lane_audit.parent_witness,
                        ),
                    ),
                    lane
                        .dec_children
                        .iter()
                        .zip(lane_audit.child_witnesses.iter())
                        .map(|(claim, wit)| {
                            claim_repr(
                                claim,
                                claim_x_col_indices_for_export(
                                    "aux-lane child",
                                    params,
                                    &lane_ccs,
                                    l,
                                    claim,
                                    wit,
                                ),
                            )
                        })
                        .collect(),
                )
            })
            .collect(),
        wp_lane_witnesses,
        wp_inputs: wp_inputs.clone(),
        wp_lanes: step
            .wp_fold
            .iter()
            .enumerate()
            .map(|(idx, lane)| {
                let lane_ccs = ccs_with_lane_n(ccs, step.mem.wp_me_claims[idx].r.len());
                let lane_audit = &audit_step.wp_lanes[idx];
                lane_repr(
                    &lane_ccs,
                    fold_base,
                    vec![claim_repr(
                        &step.mem.wp_me_claims[idx],
                        claim_x_col_indices_for_export(
                            "aux-lane input",
                            params,
                            &lane_ccs,
                            l,
                            &step.mem.wp_me_claims[idx],
                            &lane_audit.input_witnesses[0],
                        ),
                    )],
                    lane,
                    claim_repr(
                        &lane.rlc_parent,
                        claim_x_col_indices_for_export(
                            "aux-lane parent",
                            params,
                            &lane_ccs,
                            l,
                            &lane.rlc_parent,
                            &lane_audit.parent_witness,
                        ),
                    ),
                    lane
                        .dec_children
                        .iter()
                        .zip(lane_audit.child_witnesses.iter())
                        .map(|(claim, wit)| {
                            claim_repr(
                                claim,
                                claim_x_col_indices_for_export(
                                    "aux-lane child",
                                    params,
                                    &lane_ccs,
                                    l,
                                    claim,
                                    wit,
                                ),
                            )
                        })
                        .collect(),
                )
            })
            .collect(),
        stage8_lanes,
    }
}

fn segment_meta_repr(meta: &[ShardSegmentMeta]) -> Vec<SegmentMetaRepr> {
    meta.iter()
        .map(|entry| SegmentMetaRepr {
            route_a: matches!(entry.kind, ShardSegmentKind::RouteA),
            public_steps: entry.public_steps,
            proof_steps: if matches!(entry.kind, ShardSegmentKind::RouteA) {
                entry.public_steps
            } else {
                entry.proof_steps
            },
        })
        .collect()
}

pub(crate) fn artifact_from_proof<L>(
    scenario_name: &str,
    should_fail: bool,
    public_step_count: usize,
    fold_base: u32,
    k_rho: u32,
    params: &neo_params::NeoParams,
    ccs: &CcsStructure<F>,
    l: &L,
    steps_witness: &[StepWitnessBundle<neo_ajtai::Commitment, F, K>],
    acc_init: &[CeClaim<neo_ajtai::Commitment, F, K>],
    acc_wit_init: &[Mat<F>],
    _final_main_wits: &[Mat<F>],
    proof: &ShardProof,
    audit: &ShardProofAudit<F>,
) -> ArtifactRepr
where
    L: SModuleHomomorphism<F, neo_ajtai::Commitment> + Sync,
{
    let materialized_steps = materialized_proof_steps(steps_witness, proof);
    assert_eq!(
        materialized_steps.len(),
        segment_meta_repr(proof.segment_meta.as_deref().unwrap_or(&[]))
            .iter()
            .fold(0usize, |acc, entry| acc + entry.proof_steps)
            .max(
                if proof
                    .segment_meta
                    .as_ref()
                    .is_some_and(|meta| !meta.is_empty())
                {
                    0
                } else {
                    proof.steps.len()
                }
            ),
        "materialized proof-step count mismatch for scenario {scenario_name}"
    );
    assert_eq!(
        audit.steps.len(),
        materialized_steps.len(),
        "audit/materialized step count mismatch for scenario {scenario_name}"
    );
    let outputs = proof.compute_fold_outputs(acc_init);
    ArtifactRepr {
        scenario_name: scenario_name.to_string(),
        should_fail,
        fold_base,
        k_rho,
        public_step_count,
        proof_step_count: materialized_steps.len(),
        ccs: ccs_repr(ccs),
        acc_init_main_witness_z: acc_wit_init.iter().map(field_matrix_repr).collect(),
        acc_init_main: acc_init
            .iter()
            .map(|claim| claim_repr(claim, prefix_x_col_indices(claim.m_in)))
            .collect(),
        final_main: outputs
            .obligations
            .main
            .iter()
            .map(|claim| claim_repr(claim, prefix_x_col_indices(claim.m_in)))
            .collect(),
        final_val: outputs
            .obligations
            .val
            .iter()
            .map(|claim| claim_repr(claim, prefix_x_col_indices(claim.m_in)))
            .collect(),
        steps: {
            let mut accumulator_wit: Vec<Mat<F>> = acc_wit_init.to_vec();
            let mut steps_out = Vec::with_capacity(materialized_steps.len());
            for (proof_step_idx, ((step, witness_batch), audit_step)) in materialized_steps
                .iter()
                .zip(audit.steps.iter())
                .enumerate()
            {
                let step_repr_out = step_repr(
                    scenario_name,
                    proof_step_idx,
                    step,
                    audit_step,
                    witness_batch,
                    ccs,
                    params,
                    l,
                    fold_base,
                    &accumulator_wit,
                );
                accumulator_wit = step_repr_out
                    .main_lane_child_witness_z
                    .iter()
                    .map(|child| {
                        let rows = child.len();
                        let cols = child.first().map(|row| row.len()).unwrap_or(0);
                        let data: Vec<F> = child
                            .iter()
                            .flat_map(|row| row.iter().copied().map(F::from_u64))
                            .collect();
                        Mat::from_row_major(rows, cols, data)
                    })
                    .collect();
                steps_out.push(step_repr_out);
            }
            steps_out
        },
        segment_meta: proof
            .segment_meta
            .as_ref()
            .map(|meta| segment_meta_repr(meta))
            .unwrap_or_default(),
    }
}

#[allow(dead_code)]
fn starstream_valid_artifact() -> ArtifactRepr {
    let export = load_test_export();
    let step_spec = StepSpec {
        y_len: export.ivc_params.step_spec.y_len,
        const1_index: export.ivc_params.step_spec.const1_index,
        y_step_indices: export.ivc_params.step_spec.y_step_indices.clone(),
        app_input_indices: Some(export.ivc_params.step_spec.y_prev_indices.clone()),
        m_in: export.steps[0].r1cs.num_public_inputs,
    };
    let step_ccs = Arc::new(build_step_ccs(&export.steps[0].r1cs));
    let mut circuit = StarstreamStepCircuit {
        steps: export.steps.clone(),
        step_spec,
        step_ccs: step_ccs.clone(),
    };
    let mut session = FoldingSession::<AjtaiSModule>::new_ajtai_seeded(
        FoldingMode::Optimized,
        step_ccs.as_ref(),
        STARSTREAM_SESSION_SEED,
    )
    .expect("new_ajtai_seeded");
    let inputs = NoInputs;
    session
        .add_steps(&mut circuit, &inputs, export.steps.len())
        .expect("add_steps should succeed with optimized");
    let mut tr_p = Poseidon2Transcript::new(b"starstream-leaf");
    let (run, _outputs, wits, audit) = fold_shard_prove_with_witnesses_and_audit(
        FoldingMode::Optimized,
        &mut tr_p,
        session.params(),
        step_ccs.as_ref(),
        session.steps_witness(),
        &[],
        &[],
        session.committer(),
        fixtures::default_mixers(),
    )
    .expect("starstream proof should succeed");
    artifact_from_proof(
        "starstream_leaf",
        false,
        export.steps.len(),
        session.params().b,
        session.params().k_rho,
        session.params(),
        step_ccs.as_ref(),
        session.committer(),
        session.steps_witness(),
        &[],
        &[],
        &wits.final_main_wits,
        &run,
        &audit,
    )
}

#[allow(dead_code)]
fn starstream_tampered_artifact(valid: &ArtifactRepr) -> ArtifactRepr {
    let mut tampered = valid.clone();
    tampered.scenario_name = "starstream_leaf/tampered_final_sum".to_string();
    tampered.should_fail = true;
    let step = tampered
        .steps
        .first_mut()
        .expect("tampered artifact requires at least one step");
    step.pi_ccs.final_sum.c0 = step.pi_ccs.final_sum.c0.wrapping_add(1);
    tampered
}

fn twist_shout_valid_artifact_named(scenario_name: &str, seed: u64) -> ArtifactRepr {
    let fx = fixtures::build_twist_shout_2step_fixture(seed);
    let transcript_label = b"twist-shout/fixture";
    let mut tr_p = Poseidon2Transcript::new(transcript_label);
    let (proof, _outputs, wits, audit) = fold_shard_prove_with_witnesses_and_audit(
        FoldingMode::Optimized,
        &mut tr_p,
        &fx.params,
        &fx.ccs,
        &fx.steps_witness,
        &fx.acc_init,
        &fx.acc_wit_init,
        &fx.l,
        fx.mixers,
    )
    .expect("twist/shout proof should succeed");
    let _ = fixtures::verify(FoldingMode::Optimized, &fx, &proof).expect("twist/shout proof must verify");
    artifact_from_proof(
        scenario_name,
        false,
        fx.steps_witness.len(),
        fx.params.b,
        fx.params.k_rho,
        &fx.params,
        &fx.ccs,
        &fx.l,
        &fx.steps_witness,
        &fx.acc_init,
        &fx.acc_wit_init,
        &wits.final_main_wits,
        &proof,
        &audit,
    )
}

fn twist_shout_valid_artifact() -> ArtifactRepr {
    twist_shout_valid_artifact_named("twist_shout_2step", 3)
}

#[allow(dead_code)]
fn twist_shout_tampered_artifact(valid: &ArtifactRepr) -> ArtifactRepr {
    let mut tampered = valid.clone();
    tampered.scenario_name = format!("{}/tampered_val_lane", valid.scenario_name);
    tampered.should_fail = true;
    let step = tampered
        .steps
        .first_mut()
        .expect("twist/shout artifact requires at least one step");
    step.val_lanes.clear();
    tampered
}

fn twist_shout_4step_valid_artifact() -> ArtifactRepr {
    let fx = fixtures::build_twist_shout_2step_fixture(707);
    let mut steps_witness: Vec<StepWitnessBundle<neo_ajtai::Commitment, F, K>> = Vec::new();
    steps_witness.extend(fx.steps_witness.iter().cloned());
    steps_witness.extend(fx.steps_witness.iter().cloned());
    let steps_instance: Vec<StepInstanceBundle<neo_ajtai::Commitment, F, K>> =
        steps_witness.iter().map(StepInstanceBundle::from).collect();
    let mut tr_p = Poseidon2Transcript::new(b"twist-shout/4step");
    let (proof, _outputs, wits, audit) = fold_shard_prove_with_witnesses_and_audit(
        FoldingMode::Optimized,
        &mut tr_p,
        &fx.params,
        &fx.ccs,
        &steps_witness,
        &fx.acc_init,
        &fx.acc_wit_init,
        &fx.l,
        fx.mixers,
    )
    .expect("twist/shout 4-step proof should succeed");
    let mut tr_v = Poseidon2Transcript::new(b"twist-shout/4step");
    let _ = fold_shard_verify(
        FoldingMode::Optimized,
        &mut tr_v,
        &fx.params,
        &fx.ccs,
        &steps_instance,
        &fx.acc_init,
        &proof,
        fx.mixers,
    )
    .expect("twist/shout 4-step proof should verify");
    artifact_from_proof(
        "twist_shout_4step",
        false,
        steps_witness.len(),
        fx.params.b,
        fx.params.k_rho,
        &fx.params,
        &fx.ccs,
        &fx.l,
        &steps_witness,
        &fx.acc_init,
        &fx.acc_wit_init,
        &wits.final_main_wits,
        &proof,
        &audit,
    )
}

fn twist_shout_continuation_valid_artifact() -> ArtifactRepr {
    let fx = fixtures::build_twist_shout_2step_fixture(909);
    let prefix_steps = &fx.steps_witness[..1];
    let suffix_steps = &fx.steps_witness[1..];
    let prefix_instances: Vec<StepInstanceBundle<neo_ajtai::Commitment, F, K>> =
        prefix_steps.iter().map(StepInstanceBundle::from).collect();
    let suffix_instances: Vec<StepInstanceBundle<neo_ajtai::Commitment, F, K>> =
        suffix_steps.iter().map(StepInstanceBundle::from).collect();

    let mut tr_prefix_p = Poseidon2Transcript::new(b"twist-shout/continuation");
    let (prefix_proof, prefix_outputs, prefix_wits, _prefix_audit) = fold_shard_prove_with_witnesses_and_audit(
        FoldingMode::Optimized,
        &mut tr_prefix_p,
        &fx.params,
        &fx.ccs,
        prefix_steps,
        &fx.acc_init,
        &fx.acc_wit_init,
        &fx.l,
        fx.mixers,
    )
    .expect("continuation prefix proof should succeed");
    let mut tr_prefix_v = Poseidon2Transcript::new(b"twist-shout/continuation");
    let _ = fold_shard_verify(
        FoldingMode::Optimized,
        &mut tr_prefix_v,
        &fx.params,
        &fx.ccs,
        &prefix_instances,
        &fx.acc_init,
        &prefix_proof,
        fx.mixers,
    )
    .expect("continuation prefix proof should verify");

    let mut tr_suffix_p = Poseidon2Transcript::new(b"twist-shout/continuation");
    let (suffix_proof, _, suffix_wits, suffix_audit) = fold_shard_prove_with_witnesses_with_step_offset_and_audit(
        FoldingMode::Optimized,
        &mut tr_suffix_p,
        &fx.params,
        &fx.ccs,
        suffix_steps,
        &prefix_outputs.obligations.main,
        &prefix_wits.final_main_wits,
        &fx.l,
        fx.mixers,
        prefix_steps.len(),
    )
    .expect("continuation suffix proof should succeed");
    let mut tr_suffix_v = Poseidon2Transcript::new(b"twist-shout/continuation");
    let _ = fold_shard_verify_with_step_offset(
        FoldingMode::Optimized,
        &mut tr_suffix_v,
        &fx.params,
        &fx.ccs,
        &suffix_instances,
        &prefix_outputs.obligations.main,
        &suffix_proof,
        fx.mixers,
        prefix_steps.len(),
    )
    .expect("continuation suffix proof should verify");

    artifact_from_proof(
        "twist_shout_continuation_suffix",
        false,
        suffix_steps.len(),
        fx.params.b,
        fx.params.k_rho,
        &fx.params,
        &fx.ccs,
        &fx.l,
        suffix_steps,
        &prefix_outputs.obligations.main,
        &prefix_wits.final_main_wits,
        &suffix_wits.final_main_wits,
        &suffix_proof,
        &suffix_audit,
    )
}

#[allow(dead_code)]
fn twist_shout_4step_tampered_artifact(valid: &ArtifactRepr) -> ArtifactRepr {
    let mut tampered = valid.clone();
    tampered.scenario_name = "twist_shout_4step/tampered_main_rho".to_string();
    tampered.should_fail = true;
    let step = tampered
        .steps
        .get_mut(1)
        .expect("twist/shout 4-step artifact requires at least two materialized steps");
    let row = step
        .main_lane_parent_witness_z
        .first_mut()
        .expect("twist/shout 4-step main lane parent witness must have at least one row");
    let first = row
        .first_mut()
        .expect("twist/shout 4-step main lane parent witness row must be non-empty");
    *first = first.wrapping_add(1);
    tampered
}

fn build_ccs_only_step(fx: &fixtures::ShardFixture, salt: u64) -> StepWitnessBundle<neo_ajtai::Commitment, F, K> {
    let m = fx.ccs.m;
    let m_in = fx.steps_witness[0].mcs.0.m_in;
    let z: Vec<F> = (0..m)
        .map(|i| match (salt.wrapping_add(i as u64)) % 3 {
            0 => -F::ONE,
            1 => F::ZERO,
            _ => F::ONE,
        })
        .collect();
    let x = z[..m_in].to_vec();
    let w = z[m_in..].to_vec();
    let z_mat = encode_vector_for_ccs_m(&fx.params, z.len(), &z).expect("encode witness for CCS width");
    let c = fx.l.commit(&z_mat);
    StepWitnessBundle::from((
        neo_ccs::relations::CcsClaim { c, x, m_in },
        neo_ccs::relations::CcsWitness { w, Z: z_mat },
    ))
}

#[allow(dead_code)]
fn mixed_segment_valid_artifact() -> ArtifactRepr {
    let fx = fixtures::build_twist_shout_2step_fixture(123);
    let mut steps_witness: Vec<StepWitnessBundle<neo_ajtai::Commitment, F, K>> =
        vec![build_ccs_only_step(&fx, 100), build_ccs_only_step(&fx, 200)];
    steps_witness.extend(fx.steps_witness.iter().cloned());
    steps_witness.push(build_ccs_only_step(&fx, 300));
    let steps_instance: Vec<StepInstanceBundle<neo_ajtai::Commitment, F, K>> =
        steps_witness.iter().map(StepInstanceBundle::from).collect();
    let mut tr_p = Poseidon2Transcript::new(b"mixed-ccs-route-a/segment-test");
    let (proof, _outputs, wits, audit) = fold_shard_prove_with_witnesses_and_audit(
        FoldingMode::Optimized,
        &mut tr_p,
        &fx.params,
        &fx.ccs,
        &steps_witness,
        &fx.acc_init,
        &fx.acc_wit_init,
        &fx.l,
        fx.mixers,
    )
    .expect("mixed segment proof should succeed");
    let mut tr_v = Poseidon2Transcript::new(b"mixed-ccs-route-a/segment-test");
    let _ = fold_shard_verify(
        FoldingMode::Optimized,
        &mut tr_v,
        &fx.params,
        &fx.ccs,
        &steps_instance,
        &fx.acc_init,
        &proof,
        fx.mixers,
    )
    .expect("mixed segment proof should verify");
    artifact_from_proof(
        "mixed_ccs_route_a_segments",
        false,
        steps_witness.len(),
        fx.params.b,
        fx.params.k_rho,
        &fx.params,
        &fx.ccs,
        &fx.l,
        &steps_witness,
        &fx.acc_init,
        &fx.acc_wit_init,
        &wits.final_main_wits,
        &proof,
        &audit,
    )
}

#[allow(dead_code)]
fn mixed_segment_tampered_artifact(valid: &ArtifactRepr) -> ArtifactRepr {
    let mut tampered = valid.clone();
    tampered.scenario_name = "mixed_ccs_route_a_segments/tampered_segment_kind".to_string();
    tampered.should_fail = true;
    if let Some(route_entry) = tampered.segment_meta.iter_mut().find(|entry| entry.route_a) {
        route_entry.route_a = false;
    } else {
        panic!("expected at least one Route-A segment");
    }
    tampered
}

pub(crate) fn write_artifact_family(
    generated_dir: &Path,
    layout: &ArtifactCodegenLayout<'_>,
    cases: &[ArtifactRepr],
) {
    for (idx, case) in cases.iter().enumerate() {
        let case_path = generated_dir.join(format!("{}{}.lean", layout.case_module_prefix, idx));
        write_case_module_with_layout(&case_path, layout, idx, case);
    }
    let out_path = generated_dir.join(format!("{}.lean", layout.generated_module_name));
    write_generated_module_with_layout(&out_path, layout, cases);
}

#[allow(dead_code)]
pub(crate) fn write_session_segment_artifacts(generated_dir: &Path, cases: &[ArtifactRepr]) {
    let layout = ArtifactCodegenLayout {
        case_module_prefix: "NeoFoldSessionSegmentArtifactCase",
        case_def_prefix: "neoFoldSessionSegmentArtifactCase",
        generated_module_name: "NeoFoldSessionSegmentArtifacts",
        generated_array_name: "neoFoldSessionSegmentArtifactCases",
    };
    write_artifact_family(generated_dir, &layout, cases);
}

pub fn export_neo_fold_artifacts() {
    let starstream_valid = starstream_valid_artifact();
    let twist_valid = twist_shout_valid_artifact();
    let twist_4step_valid = twist_shout_4step_valid_artifact();
    let twist_continuation_valid = twist_shout_continuation_valid_artifact();
    let mixed_segment_valid = mixed_segment_valid_artifact();
    let mut cases = vec![
        starstream_valid,
        twist_valid,
        twist_4step_valid,
        twist_continuation_valid,
        mixed_segment_valid,
    ];
    cases.extend(neo_fold_integration_artifacts::continuation_sha256_artifacts());
    cases.extend(neo_fold_integration_artifacts::output_binding_artifacts());
    let generated_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("..")
        .join("SuperNeo")
        .join("Generated");
    write_artifact_family(&generated_dir, &DEFAULT_ARTIFACT_LAYOUT, &cases);
    println!(
        "wrote {} (label {:?})",
        generated_dir.join(format!("{}.lean", DEFAULT_ARTIFACT_LAYOUT.generated_module_name)).display(),
        CONTROL_NEXT_PC_LINEAR_LABEL
    );
}
