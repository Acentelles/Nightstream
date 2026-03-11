use super::*;

pub(crate) struct ArtifactCodegenLayout<'a> {
    pub(crate) case_module_prefix: &'a str,
    pub(crate) case_def_prefix: &'a str,
    pub(crate) generated_module_name: &'a str,
    pub(crate) generated_array_name: &'a str,
}

pub(crate) const DEFAULT_ARTIFACT_LAYOUT: ArtifactCodegenLayout<'static> = ArtifactCodegenLayout {
    case_module_prefix: "NeoFoldArtifactCase",
    case_def_prefix: "neoFoldArtifactCase",
    generated_module_name: "NeoFoldArtifacts",
    generated_array_name: "neoFoldArtifactCases",
};

const TARGET_CHUNK_BYTES: usize = 32_000;
const MAX_DEFS_PER_CHUNK: usize = 12;
const GENERATED_DEF_HEARTBEAT_BUDGET: usize = 1_200_000;

fn push_typed_def(def_blocks: &mut Vec<String>, name: &str, ty: &str, body: String) {
    let mut block = String::new();
    let _ = writeln!(block, "def {name} : {ty} :=");
    let _ = writeln!(block, "  {body}");
    block.push('\n');
    def_blocks.push(block);
}

fn push_nat_array2_def(def_blocks: &mut Vec<String>, name: &str, vals: &[Vec<u64>]) {
    let row_refs: Vec<String> = vals
        .iter()
        .enumerate()
        .map(|(idx, row)| {
            let row_name = format!("{name}Row{idx}");
            push_typed_def(def_blocks, &row_name, "Array Nat", fmt_field_array(row));
            row_name
        })
        .collect();
    push_typed_def(def_blocks, name, "Array (Array Nat)", fmt_refs(&row_refs));
}

fn push_nat_array3_def(def_blocks: &mut Vec<String>, name: &str, vals: &[Vec<Vec<u64>>]) {
    let plane_refs: Vec<String> = vals
        .iter()
        .enumerate()
        .map(|(idx, plane)| {
            let plane_name = format!("{name}Plane{idx}");
            push_nat_array2_def(def_blocks, &plane_name, plane);
            plane_name
        })
        .collect();
    push_typed_def(
        def_blocks,
        name,
        "Array (Array (Array Nat))",
        fmt_refs(&plane_refs),
    );
}

fn push_lane_witness_chain_def(
    def_blocks: &mut Vec<String>,
    name: &str,
    chain: &LaneWitnessChainRepr,
) {
    let input_name = format!("{name}InputWitnessZ");
    let parent_name = format!("{name}ParentWitnessZ");
    let child_name = format!("{name}ChildWitnessZ");
    push_nat_array3_def(def_blocks, &input_name, &chain.input_witness_z);
    push_nat_array2_def(def_blocks, &parent_name, &chain.parent_witness_z);
    push_nat_array3_def(def_blocks, &child_name, &chain.child_witness_z);
    push_typed_def(
        def_blocks,
        name,
        "NeoFoldLaneWitnessCase",
        format!(
            "{{ inputWitnessZ := {input_name}, parentWitnessZ := {parent_name}, childWitnessZ := {child_name} }}"
        ),
    );
}

fn push_lane_witness_chains_def(
    def_blocks: &mut Vec<String>,
    name: &str,
    chains: &[LaneWitnessChainRepr],
) {
    let chain_refs: Vec<String> = chains
        .iter()
        .enumerate()
        .map(|(idx, chain)| {
            let chain_name = format!("{name}Chain{idx}");
            push_lane_witness_chain_def(def_blocks, &chain_name, chain);
            chain_name
        })
        .collect();
    push_typed_def(
        def_blocks,
        name,
        "Array NeoFoldLaneWitnessCase",
        fmt_refs(&chain_refs),
    );
}

fn fmt_bool(value: bool) -> &'static str {
    if value {
        "true"
    } else {
        "false"
    }
}

fn fmt_k_pair(value: &KPair) -> String {
    format!("{{ c0 := {}, c1 := {} }}", value.c0, value.c1)
}

fn fmt_nat_array(vals: &[usize]) -> String {
    let mut out = String::new();
    out.push_str("#[");
    for (idx, value) in vals.iter().enumerate() {
        if idx != 0 {
            out.push_str(", ");
        }
        let _ = write!(out, "{value}");
    }
    out.push(']');
    out
}

fn fmt_u8_array(vals: &[u8]) -> String {
    let mut out = String::new();
    out.push_str("#[");
    for (idx, value) in vals.iter().enumerate() {
        if idx != 0 {
            out.push_str(", ");
        }
        let _ = write!(out, "{value}");
    }
    out.push(']');
    out
}

fn fmt_field_array(vals: &[u64]) -> String {
    let mut out = String::new();
    out.push_str("#[");
    for (idx, value) in vals.iter().enumerate() {
        if idx != 0 {
            out.push_str(", ");
        }
        let _ = write!(out, "{value}");
    }
    out.push(']');
    out
}

fn fmt_field_array2(vals: &[Vec<u64>]) -> String {
    let mut out = String::new();
    out.push_str("#[");
    for (idx, value) in vals.iter().enumerate() {
        if idx != 0 {
            out.push_str(", ");
        }
        out.push_str(&fmt_field_array(value));
    }
    out.push(']');
    out
}

fn fmt_string_array(vals: &[String]) -> String {
    let mut out = String::new();
    out.push_str("#[");
    for (idx, value) in vals.iter().enumerate() {
        if idx != 0 {
            out.push_str(", ");
        }
        let _ = write!(out, "{value:?}");
    }
    out.push(']');
    out
}

fn fmt_k_array(vals: &[KPair]) -> String {
    let mut out = String::new();
    out.push_str("#[");
    for (idx, value) in vals.iter().enumerate() {
        if idx != 0 {
            out.push_str(", ");
        }
        out.push_str(&fmt_k_pair(value));
    }
    out.push(']');
    out
}

fn fmt_k_array2(vals: &[Vec<KPair>]) -> String {
    let mut out = String::new();
    out.push_str("#[");
    for (idx, value) in vals.iter().enumerate() {
        if idx != 0 {
            out.push_str(", ");
        }
        out.push_str(&fmt_k_array(value));
    }
    out.push(']');
    out
}

fn fmt_k_array3(vals: &[Vec<Vec<KPair>>]) -> String {
    let mut out = String::new();
    out.push_str("#[");
    for (idx, value) in vals.iter().enumerate() {
        if idx != 0 {
            out.push_str(", ");
        }
        out.push_str(&fmt_k_array2(value));
    }
    out.push(']');
    out
}

fn fmt_sparse_entries(entries: &[SparseEntryRepr]) -> String {
    let mut out = String::new();
    out.push_str("#[");
    for (idx, entry) in entries.iter().enumerate() {
        if idx != 0 {
            out.push_str(", ");
        }
        let _ = write!(
            out,
            "{{ row := {}, col := {}, value := {} }}",
            entry.row, entry.col, entry.value
        );
    }
    out.push(']');
    out
}

fn fmt_ccs_matrix(matrix: &CcsMatrixRepr) -> String {
    format!(
        "{{ nrows := {}, ncols := {}, identity := {}, entries := {} }}",
        matrix.nrows,
        matrix.ncols,
        fmt_bool(matrix.identity),
        fmt_sparse_entries(&matrix.entries),
    )
}

fn fmt_ccs_matrices(matrices: &[CcsMatrixRepr]) -> String {
    let mut out = String::new();
    out.push_str("#[");
    for (idx, matrix) in matrices.iter().enumerate() {
        if idx != 0 {
            out.push_str(", ");
        }
        out.push_str(&fmt_ccs_matrix(matrix));
    }
    out.push(']');
    out
}

fn fmt_poly_terms(terms: &[PolyTermRepr]) -> String {
    let mut out = String::new();
    out.push_str("#[");
    for (idx, term) in terms.iter().enumerate() {
        if idx != 0 {
            out.push_str(", ");
        }
        let _ = write!(
            out,
            "{{ coeff := {}, exps := {} }}",
            term.coeff,
            fmt_nat_array(&term.exps),
        );
    }
    out.push(']');
    out
}

fn fmt_ccs(ccs: &CcsRepr) -> String {
    format!(
        "{{ n := {}, m := {}, matrices := {}, polyTerms := {} }}",
        ccs.n,
        ccs.m,
        fmt_ccs_matrices(&ccs.matrices),
        fmt_poly_terms(&ccs.poly_terms),
    )
}

fn fmt_commitment(commitment: &CommitmentRepr) -> String {
    format!("{{ cols := {} }}", fmt_field_array2(&commitment.cols))
}

fn fmt_transcript(transcript: &TranscriptRepr) -> String {
    format!(
        "{{ claimedSum := {}, degreeBound := {}, roundPolys := {}, challenges := {}, finalSum := {} }}",
        fmt_k_pair(&transcript.claimed_sum),
        transcript.degree_bound,
        fmt_k_array2(&transcript.round_polys),
        fmt_k_array(&transcript.challenges),
        fmt_k_pair(&transcript.final_sum),
    )
}

fn fmt_batched_time(batched: &BatchedTimeRepr) -> String {
    format!(
        "{{ claimedSums := {}, degreeBounds := {}, labels := {}, roundPolys := {}, sharedChallenges := {} }}",
        fmt_k_array(&batched.claimed_sums),
        fmt_nat_array(&batched.degree_bounds),
        fmt_string_array(&batched.labels),
        fmt_k_array3(&batched.round_polys),
        fmt_k_array(&batched.shared_challenges),
    )
}

fn fmt_claim(claim: &ClaimRepr) -> String {
    format!(
        "{{ commitment := {}, r := {}, sCol := {}, mIn := {}, xColIndices := {}, x := {}, yRing := {}, ct := {}, auxOpenings := {}, yZcol := {}, foldDigest := {}, cStepCoords := {}, uOffset := {}, uLen := {} }}",
        fmt_commitment(&claim.commitment),
        fmt_k_array(&claim.r),
        fmt_k_array(&claim.s_col),
        claim.m_in,
        fmt_nat_array(&claim.x_col_indices),
        fmt_field_array2(&claim.x),
        fmt_k_array2(&claim.y_ring),
        fmt_k_array(&claim.ct),
        fmt_k_array(&claim.aux_openings),
        fmt_k_array(&claim.y_zcol),
        fmt_u8_array(&claim.fold_digest),
        fmt_field_array(&claim.c_step_coords),
        claim.u_offset,
        claim.u_len,
    )
}

fn fmt_claims(claims: &[ClaimRepr]) -> String {
    let mut out = String::new();
    out.push_str("#[");
    for (idx, claim) in claims.iter().enumerate() {
        if idx != 0 {
            out.push_str(", ");
        }
        out.push_str(&fmt_claim(claim));
    }
    out.push(']');
    out
}

fn fmt_lane(lane: &LaneRepr) -> String {
    format!(
        "{{ ccs := {}, foldBase := {}, inputs := {}, rhoCount := {}, rhoCoeffs := {}, parent := {}, children := {} }}",
        fmt_ccs(&lane.ccs),
        lane.fold_base,
        fmt_claims(&lane.inputs),
        lane.rho_count,
        fmt_field_array2(&lane.rho_coeffs),
        fmt_claim(&lane.parent),
        fmt_claims(&lane.children),
    )
}

fn fmt_refs(names: &[String]) -> String {
    let mut out = String::new();
    out.push_str("#[");
    for (idx, name) in names.iter().enumerate() {
        if idx != 0 {
            out.push_str(", ");
        }
        out.push_str(name);
    }
    out.push(']');
    out
}

fn fmt_segment_meta(entries: &[SegmentMetaRepr]) -> String {
    let mut out = String::new();
    out.push_str("#[");
    for (idx, entry) in entries.iter().enumerate() {
        if idx != 0 {
            out.push_str(", ");
        }
        let _ = write!(
            out,
            "{{ routeA := {}, publicSteps := {}, proofSteps := {} }}",
            fmt_bool(entry.route_a),
            entry.public_steps,
            entry.proof_steps
        );
    }
    out.push(']');
    out
}

fn intern_by_key<T: Clone>(map: &mut BTreeMap<String, usize>, values: &mut Vec<T>, key: String, value: &T) -> usize {
    if let Some(idx) = map.get(&key) {
        *idx
    } else {
        let idx = values.len();
        values.push(value.clone());
        map.insert(key, idx);
        idx
    }
}

fn collect_commitment(
    commitment: &CommitmentRepr,
    commitment_ids: &mut BTreeMap<String, usize>,
    commitments: &mut Vec<CommitmentRepr>,
) -> usize {
    let key = fmt_commitment(commitment);
    intern_by_key(commitment_ids, commitments, key, commitment)
}

fn collect_claim(
    claim: &ClaimRepr,
    commitment_ids: &mut BTreeMap<String, usize>,
    commitments: &mut Vec<CommitmentRepr>,
    claim_ids: &mut BTreeMap<String, usize>,
    claims: &mut Vec<ClaimRepr>,
) -> usize {
    let _ = collect_commitment(&claim.commitment, commitment_ids, commitments);
    let key = fmt_claim(claim);
    intern_by_key(claim_ids, claims, key, claim)
}

fn collect_lane(
    lane: &LaneRepr,
    commitment_ids: &mut BTreeMap<String, usize>,
    commitments: &mut Vec<CommitmentRepr>,
    claim_ids: &mut BTreeMap<String, usize>,
    claims: &mut Vec<ClaimRepr>,
    lane_ids: &mut BTreeMap<String, usize>,
    lanes: &mut Vec<LaneRepr>,
) -> usize {
    for claim in &lane.inputs {
        let _ = collect_claim(claim, commitment_ids, commitments, claim_ids, claims);
    }
    let _ = collect_claim(&lane.parent, commitment_ids, commitments, claim_ids, claims);
    for claim in &lane.children {
        let _ = collect_claim(claim, commitment_ids, commitments, claim_ids, claims);
    }
    let key = fmt_lane(lane);
    intern_by_key(lane_ids, lanes, key, lane)
}

pub(crate) fn write_case_module_with_layout(
    out_path: &Path,
    layout: &ArtifactCodegenLayout<'_>,
    case_idx: usize,
    case: &ArtifactRepr,
) {
    let mut commitment_ids: BTreeMap<String, usize> = BTreeMap::new();
    let mut commitments: Vec<CommitmentRepr> = Vec::new();
    let mut claim_ids: BTreeMap<String, usize> = BTreeMap::new();
    let mut claims: Vec<ClaimRepr> = Vec::new();
    let mut lane_ids: BTreeMap<String, usize> = BTreeMap::new();
    let mut lanes: Vec<LaneRepr> = Vec::new();

    for claim in &case.acc_init_main {
        let _ = collect_claim(
            claim,
            &mut commitment_ids,
            &mut commitments,
            &mut claim_ids,
            &mut claims,
        );
    }
    for claim in &case.final_main {
        let _ = collect_claim(
            claim,
            &mut commitment_ids,
            &mut commitments,
            &mut claim_ids,
            &mut claims,
        );
    }
    for claim in &case.final_val {
        let _ = collect_claim(
            claim,
            &mut commitment_ids,
            &mut commitments,
            &mut claim_ids,
            &mut claims,
        );
    }

    for step in &case.steps {
        let _ = collect_commitment(&step.mcs_commitment, &mut commitment_ids, &mut commitments);
        for commitment in &step.mcs_batch_commitments {
            let _ = collect_commitment(commitment, &mut commitment_ids, &mut commitments);
        }
        for claim in &step.ccs_out {
            let _ = collect_claim(
                claim,
                &mut commitment_ids,
                &mut commitments,
                &mut claim_ids,
                &mut claims,
            );
        }
        let _ = collect_lane(
            &step.main_lane,
            &mut commitment_ids,
            &mut commitments,
            &mut claim_ids,
            &mut claims,
            &mut lane_ids,
            &mut lanes,
        );
        for claim in &step.val_inputs {
            let _ = collect_claim(
                claim,
                &mut commitment_ids,
                &mut commitments,
                &mut claim_ids,
                &mut claims,
            );
        }
        for lane in &step.val_lanes {
            let _ = collect_lane(
                lane,
                &mut commitment_ids,
                &mut commitments,
                &mut claim_ids,
                &mut claims,
                &mut lane_ids,
                &mut lanes,
            );
        }
        for claim in &step.wb_inputs {
            let _ = collect_claim(
                claim,
                &mut commitment_ids,
                &mut commitments,
                &mut claim_ids,
                &mut claims,
            );
        }
        for lane in &step.wb_lanes {
            let _ = collect_lane(
                lane,
                &mut commitment_ids,
                &mut commitments,
                &mut claim_ids,
                &mut claims,
                &mut lane_ids,
                &mut lanes,
            );
        }
        for claim in &step.wp_inputs {
            let _ = collect_claim(
                claim,
                &mut commitment_ids,
                &mut commitments,
                &mut claim_ids,
                &mut claims,
            );
        }
        for lane in &step.wp_lanes {
            let _ = collect_lane(
                lane,
                &mut commitment_ids,
                &mut commitments,
                &mut claim_ids,
                &mut claims,
                &mut lane_ids,
                &mut lanes,
            );
        }
        for lane in &step.stage8_lanes {
            let _ = collect_lane(
                lane,
                &mut commitment_ids,
                &mut commitments,
                &mut claim_ids,
                &mut claims,
                &mut lane_ids,
                &mut lanes,
            );
        }
    }

    let mut def_blocks: Vec<String> = Vec::new();
    for (idx, commitment) in commitments.iter().enumerate() {
        push_typed_def(
            &mut def_blocks,
            &format!("case{case_idx}Commitment{idx}"),
            "NeoFoldCommitmentCase",
            fmt_commitment(commitment),
        );
    }
    for (idx, claim) in claims.iter().enumerate() {
        let commitment_ref = format!(
            "case{case_idx}Commitment{}",
            commitment_ids[&fmt_commitment(&claim.commitment)]
        );
        let prefix = format!("case{case_idx}Claim{idx}");
        push_typed_def(&mut def_blocks, &format!("{prefix}R"), "Array KNat", fmt_k_array(&claim.r));
        push_typed_def(
            &mut def_blocks,
            &format!("{prefix}SCol"),
            "Array KNat",
            fmt_k_array(&claim.s_col),
        );
        push_typed_def(
            &mut def_blocks,
            &format!("{prefix}XColIndices"),
            "Array Nat",
            fmt_nat_array(&claim.x_col_indices),
        );
        push_nat_array2_def(&mut def_blocks, &format!("{prefix}X"), &claim.x);
        push_typed_def(
            &mut def_blocks,
            &format!("{prefix}YRing"),
            "Array (Array KNat)",
            fmt_k_array2(&claim.y_ring),
        );
        push_typed_def(&mut def_blocks, &format!("{prefix}Ct"), "Array KNat", fmt_k_array(&claim.ct));
        push_typed_def(
            &mut def_blocks,
            &format!("{prefix}AuxOpenings"),
            "Array KNat",
            fmt_k_array(&claim.aux_openings),
        );
        push_typed_def(
            &mut def_blocks,
            &format!("{prefix}YZcol"),
            "Array KNat",
            fmt_k_array(&claim.y_zcol),
        );
        push_typed_def(
            &mut def_blocks,
            &format!("{prefix}FoldDigest"),
            "Array Nat",
            fmt_u8_array(&claim.fold_digest),
        );
        push_typed_def(
            &mut def_blocks,
            &format!("{prefix}CStepCoords"),
            "Array Nat",
            fmt_field_array(&claim.c_step_coords),
        );
        push_typed_def(
            &mut def_blocks,
            &prefix,
            "NeoFoldClaimCase",
            format!(
                "{{ commitment := {commitment_ref}, r := {prefix}R, sCol := {prefix}SCol, mIn := {}, xColIndices := {prefix}XColIndices, x := {prefix}X, yRing := {prefix}YRing, ct := {prefix}Ct, auxOpenings := {prefix}AuxOpenings, yZcol := {prefix}YZcol, foldDigest := {prefix}FoldDigest, cStepCoords := {prefix}CStepCoords, uOffset := {}, uLen := {} }}",
                claim.m_in,
                claim.u_offset,
                claim.u_len,
            ),
        );
    }
    for (idx, lane) in lanes.iter().enumerate() {
        let input_refs: Vec<String> = lane
            .inputs
            .iter()
            .map(|claim| format!("case{case_idx}Claim{}", claim_ids[&fmt_claim(claim)]))
            .collect();
        let parent_ref = format!("case{case_idx}Claim{}", claim_ids[&fmt_claim(&lane.parent)]);
        let child_refs: Vec<String> = lane
            .children
            .iter()
            .map(|claim| format!("case{case_idx}Claim{}", claim_ids[&fmt_claim(claim)]))
            .collect();
        let prefix = format!("case{case_idx}Lane{idx}");
        push_typed_def(
            &mut def_blocks,
            &format!("{prefix}Ccs"),
            "NeoFoldCcsCase",
            fmt_ccs(&lane.ccs),
        );
        push_typed_def(
            &mut def_blocks,
            &format!("{prefix}Inputs"),
            "Array NeoFoldClaimCase",
            fmt_refs(&input_refs),
        );
        push_nat_array2_def(&mut def_blocks, &format!("{prefix}RhoCoeffs"), &lane.rho_coeffs);
        push_typed_def(
            &mut def_blocks,
            &format!("{prefix}Children"),
            "Array NeoFoldClaimCase",
            fmt_refs(&child_refs),
        );
        push_typed_def(
            &mut def_blocks,
            &prefix,
            "NeoFoldLaneCase",
            format!(
                "{{ ccs := {prefix}Ccs, foldBase := {}, inputs := {prefix}Inputs, rhoCount := {}, rhoCoeffs := {prefix}RhoCoeffs, parent := {parent_ref}, children := {prefix}Children }}",
                lane.fold_base,
                lane.rho_count,
            ),
        );
    }
    for (idx, step) in case.steps.iter().enumerate() {
        let mcs_batch_commitment_refs: Vec<String> = step
            .mcs_batch_commitments
            .iter()
            .map(|commitment| {
                format!(
                    "case{case_idx}Commitment{}",
                    commitment_ids[&fmt_commitment(commitment)]
                )
            })
            .collect();
        let mcs_commitment_ref = format!(
            "case{case_idx}Commitment{}",
            commitment_ids[&fmt_commitment(&step.mcs_commitment)]
        );
        let ccs_out_refs: Vec<String> = step
            .ccs_out
            .iter()
            .map(|claim| format!("case{case_idx}Claim{}", claim_ids[&fmt_claim(claim)]))
            .collect();
        let main_lane_ref = format!("case{case_idx}Lane{}", lane_ids[&fmt_lane(&step.main_lane)]);
        let val_input_refs: Vec<String> = step
            .val_inputs
            .iter()
            .map(|claim| format!("case{case_idx}Claim{}", claim_ids[&fmt_claim(claim)]))
            .collect();
        let val_lane_refs: Vec<String> = step
            .val_lanes
            .iter()
            .map(|lane| format!("case{case_idx}Lane{}", lane_ids[&fmt_lane(lane)]))
            .collect();
        let wb_input_refs: Vec<String> = step
            .wb_inputs
            .iter()
            .map(|claim| format!("case{case_idx}Claim{}", claim_ids[&fmt_claim(claim)]))
            .collect();
        let wb_lane_refs: Vec<String> = step
            .wb_lanes
            .iter()
            .map(|lane| format!("case{case_idx}Lane{}", lane_ids[&fmt_lane(lane)]))
            .collect();
        let wp_input_refs: Vec<String> = step
            .wp_inputs
            .iter()
            .map(|claim| format!("case{case_idx}Claim{}", claim_ids[&fmt_claim(claim)]))
            .collect();
        let wp_lane_refs: Vec<String> = step
            .wp_lanes
            .iter()
            .map(|lane| format!("case{case_idx}Lane{}", lane_ids[&fmt_lane(lane)]))
            .collect();
        let stage8_lane_refs: Vec<String> = step
            .stage8_lanes
            .iter()
            .map(|lane| format!("case{case_idx}Lane{}", lane_ids[&fmt_lane(lane)]))
            .collect();
        let prefix = format!("case{case_idx}Step{idx}");
        push_nat_array2_def(
            &mut def_blocks,
            &format!("{prefix}McsBatchPublicInput"),
            &step.mcs_batch_public_input,
        );
        push_nat_array2_def(
            &mut def_blocks,
            &format!("{prefix}McsBatchPrivateInput"),
            &step.mcs_batch_private_input,
        );
        push_nat_array3_def(
            &mut def_blocks,
            &format!("{prefix}McsBatchWitnessZ"),
            &step.mcs_batch_witness_z,
        );
        push_typed_def(
            &mut def_blocks,
            &format!("{prefix}McsBatchCommitments"),
            "Array NeoFoldCommitmentCase",
            fmt_refs(&mcs_batch_commitment_refs),
        );
        push_typed_def(
            &mut def_blocks,
            &format!("{prefix}McsPublicInput"),
            "Array Nat",
            fmt_field_array(&step.mcs_public_input),
        );
        push_typed_def(
            &mut def_blocks,
            &format!("{prefix}McsPrivateInput"),
            "Array Nat",
            fmt_field_array(&step.mcs_private_input),
        );
        push_nat_array2_def(
            &mut def_blocks,
            &format!("{prefix}McsWitnessZ"),
            &step.mcs_witness_z,
        );
        push_typed_def(
            &mut def_blocks,
            &format!("{prefix}PiCcs"),
            "NeoFoldTranscriptCase",
            fmt_transcript(&step.pi_ccs),
        );
        push_typed_def(
            &mut def_blocks,
            &format!("{prefix}PiCcsNc"),
            "NeoFoldTranscriptCase",
            fmt_transcript(&step.pi_ccs_nc),
        );
        push_typed_def(
            &mut def_blocks,
            &format!("{prefix}CpuSumcheck"),
            "NeoFoldTranscriptCase",
            fmt_transcript(&step.cpu_sumcheck),
        );
        push_typed_def(
            &mut def_blocks,
            &format!("{prefix}ShiftSumcheck"),
            "NeoFoldTranscriptCase",
            fmt_transcript(&step.shift_sumcheck),
        );
        push_typed_def(
            &mut def_blocks,
            &format!("{prefix}BatchedTime"),
            "NeoFoldBatchedTimeCase",
            fmt_batched_time(&step.batched_time),
        );
        push_typed_def(
            &mut def_blocks,
            &format!("{prefix}CcsOut"),
            "Array NeoFoldClaimCase",
            fmt_refs(&ccs_out_refs),
        );
        push_nat_array3_def(
            &mut def_blocks,
            &format!("{prefix}MainLaneInputWitnessZ"),
            &step.main_lane_input_witness_z,
        );
        push_nat_array2_def(
            &mut def_blocks,
            &format!("{prefix}MainLaneParentWitnessZ"),
            &step.main_lane_parent_witness_z,
        );
        push_nat_array3_def(
            &mut def_blocks,
            &format!("{prefix}MainLaneChildWitnessZ"),
            &step.main_lane_child_witness_z,
        );
        push_lane_witness_chains_def(
            &mut def_blocks,
            &format!("{prefix}ValLaneWitnesses"),
            &step.val_lane_witnesses,
        );
        push_typed_def(
            &mut def_blocks,
            &format!("{prefix}ValInputs"),
            "Array NeoFoldClaimCase",
            fmt_refs(&val_input_refs),
        );
        push_typed_def(
            &mut def_blocks,
            &format!("{prefix}ValLanes"),
            "Array NeoFoldLaneCase",
            fmt_refs(&val_lane_refs),
        );
        push_lane_witness_chains_def(
            &mut def_blocks,
            &format!("{prefix}WbLaneWitnesses"),
            &step.wb_lane_witnesses,
        );
        push_typed_def(
            &mut def_blocks,
            &format!("{prefix}WbInputs"),
            "Array NeoFoldClaimCase",
            fmt_refs(&wb_input_refs),
        );
        push_typed_def(
            &mut def_blocks,
            &format!("{prefix}WbLanes"),
            "Array NeoFoldLaneCase",
            fmt_refs(&wb_lane_refs),
        );
        push_lane_witness_chains_def(
            &mut def_blocks,
            &format!("{prefix}WpLaneWitnesses"),
            &step.wp_lane_witnesses,
        );
        push_typed_def(
            &mut def_blocks,
            &format!("{prefix}WpInputs"),
            "Array NeoFoldClaimCase",
            fmt_refs(&wp_input_refs),
        );
        push_typed_def(
            &mut def_blocks,
            &format!("{prefix}WpLanes"),
            "Array NeoFoldLaneCase",
            fmt_refs(&wp_lane_refs),
        );
        push_typed_def(
            &mut def_blocks,
            &format!("{prefix}Stage8Lanes"),
            "Array NeoFoldLaneCase",
            fmt_refs(&stage8_lane_refs),
        );
        push_typed_def(
            &mut def_blocks,
            &prefix,
            "NeoFoldStepArtifactCase",
            format!(
                "{{ routeA := {}, compressedSubsteps := {}, mcsBatchPublicInput := {prefix}McsBatchPublicInput, mcsBatchPrivateInput := {prefix}McsBatchPrivateInput, mcsBatchWitnessZ := {prefix}McsBatchWitnessZ, mcsBatchCommitments := {prefix}McsBatchCommitments, mcsPublicInput := {prefix}McsPublicInput, mcsPrivateInput := {prefix}McsPrivateInput, mcsWitnessZ := {prefix}McsWitnessZ, mcsCommitment := {mcs_commitment_ref}, piCcs := {prefix}PiCcs, piCcsNc := {prefix}PiCcsNc, cpuSumcheck := {prefix}CpuSumcheck, shiftSumcheck := {prefix}ShiftSumcheck, batchedTime := {prefix}BatchedTime, ccsOut := {prefix}CcsOut, mainLane := {main_lane_ref}, mainLaneInputWitnessZ := {prefix}MainLaneInputWitnessZ, mainLaneParentWitnessZ := {prefix}MainLaneParentWitnessZ, mainLaneChildWitnessZ := {prefix}MainLaneChildWitnessZ, valLaneWitnesses := {prefix}ValLaneWitnesses, valInputs := {prefix}ValInputs, valLanes := {prefix}ValLanes, wbLaneWitnesses := {prefix}WbLaneWitnesses, wbInputs := {prefix}WbInputs, wbLanes := {prefix}WbLanes, wpLaneWitnesses := {prefix}WpLaneWitnesses, wpInputs := {prefix}WpInputs, wpLanes := {prefix}WpLanes, stage8Lanes := {prefix}Stage8Lanes }}",
                fmt_bool(step.route_a),
                step.compressed_substeps,
            ),
        );
    }
    let mut out = String::new();
    let acc_init_refs: Vec<String> = case
        .acc_init_main
        .iter()
        .map(|claim| format!("case{case_idx}Claim{}", claim_ids[&fmt_claim(claim)]))
        .collect();
    let final_main_refs: Vec<String> = case
        .final_main
        .iter()
        .map(|claim| format!("case{case_idx}Claim{}", claim_ids[&fmt_claim(claim)]))
        .collect();
    let final_val_refs: Vec<String> = case
        .final_val
        .iter()
        .map(|claim| format!("case{case_idx}Claim{}", claim_ids[&fmt_claim(claim)]))
        .collect();
    let step_refs: Vec<String> = (0..case.steps.len())
        .map(|idx| format!("case{case_idx}Step{idx}"))
        .collect();
    push_typed_def(
        &mut def_blocks,
        &format!("case{case_idx}ArtifactCcs"),
        "NeoFoldCcsCase",
        fmt_ccs(&case.ccs),
    );
    push_nat_array3_def(
        &mut def_blocks,
        &format!("case{case_idx}AccInitMainWitnessZ"),
        &case.acc_init_main_witness_z,
    );
    push_typed_def(
        &mut def_blocks,
        &format!("case{case_idx}AccInitMain"),
        "Array NeoFoldClaimCase",
        fmt_refs(&acc_init_refs),
    );
    push_typed_def(
        &mut def_blocks,
        &format!("case{case_idx}FinalMain"),
        "Array NeoFoldClaimCase",
        fmt_refs(&final_main_refs),
    );
    push_typed_def(
        &mut def_blocks,
        &format!("case{case_idx}FinalVal"),
        "Array NeoFoldClaimCase",
        fmt_refs(&final_val_refs),
    );
    push_typed_def(
        &mut def_blocks,
        &format!("case{case_idx}Steps"),
        "Array NeoFoldStepArtifactCase",
        fmt_refs(&step_refs),
    );
    push_typed_def(
        &mut def_blocks,
        &format!("case{case_idx}SegmentMeta"),
        "Array NeoFoldSegmentMetaCase",
        fmt_segment_meta(&case.segment_meta),
    );
    let mut chunk_ranges: Vec<(usize, usize)> = Vec::new();
    let mut start = 0usize;
    while start < def_blocks.len() {
        let mut end = start;
        let mut bytes = 0usize;
        while end < def_blocks.len() {
            let next_bytes = bytes + def_blocks[end].len();
            if end > start
                && (end - start >= MAX_DEFS_PER_CHUNK || next_bytes > TARGET_CHUNK_BYTES)
            {
                break;
            }
            bytes = next_bytes;
            end += 1;
        }
        chunk_ranges.push((start, end));
        start = end;
    }
    let chunk_count = chunk_ranges.len();
    let parent_dir = out_path.parent().expect("case path should have a parent");
    for (chunk_idx, (start, end)) in chunk_ranges.iter().copied().enumerate() {
        let mut chunk_out = String::new();
        chunk_out.push_str("import SuperNeo.Generated.NeoFoldArtifactsCases\n");
        for prev_chunk_idx in 0..chunk_idx {
            let _ = writeln!(
                chunk_out,
                "import SuperNeo.Generated.{}{case_idx}Defs{prev_chunk_idx}",
                layout.case_module_prefix
            );
        }
        let _ = writeln!(
            chunk_out,
            "\nset_option maxHeartbeats {}\n",
            GENERATED_DEF_HEARTBEAT_BUDGET
        );
        chunk_out.push_str("namespace SuperNeo.Generated\n\n");
        for block in &def_blocks[start..end] {
            chunk_out.push_str(block);
        }
        chunk_out.push_str("end SuperNeo.Generated\n");
        let chunk_path = parent_dir.join(format!(
            "{}{case_idx}Defs{chunk_idx}.lean",
            layout.case_module_prefix
        ));
        fs::write(chunk_path, chunk_out).expect("write NeoFoldArtifactCase*Defs*.lean");
    }

    out.push_str("import SuperNeo.Generated.NeoFoldArtifactsCases\n");
    for chunk_idx in 0..chunk_count {
        let _ = writeln!(
            out,
            "import SuperNeo.Generated.{}{case_idx}Defs{chunk_idx}",
            layout.case_module_prefix
        );
    }
    out.push('\n');
    out.push_str("namespace SuperNeo.Generated\n\n");
    let _ = writeln!(
        out,
        "def {}{case_idx} : NeoFoldArtifactCase :=",
        layout.case_def_prefix
    );
    let _ = writeln!(
        out,
        "  {{ scenarioName := {:?}, shouldFail := {}, foldBase := {}, kRho := {}, publicStepCount := {}, proofStepCount := {}, ccs := case{case_idx}ArtifactCcs, accInitMainWitnessZ := case{case_idx}AccInitMainWitnessZ, accInitMain := case{case_idx}AccInitMain, finalMain := case{case_idx}FinalMain, finalVal := case{case_idx}FinalVal, steps := case{case_idx}Steps, segmentMeta := case{case_idx}SegmentMeta }}",
        case.scenario_name,
        fmt_bool(case.should_fail),
        case.fold_base,
        case.k_rho,
        case.public_step_count,
        case.proof_step_count,
    );
    out.push_str("\nend SuperNeo.Generated\n");
    fs::write(out_path, out).expect("write NeoFoldArtifactCase*.lean");
}

#[allow(dead_code)]
pub(crate) fn write_case_module(out_path: &Path, case_idx: usize, case: &ArtifactRepr) {
    write_case_module_with_layout(out_path, &DEFAULT_ARTIFACT_LAYOUT, case_idx, case)
}

pub(crate) fn write_generated_module_with_layout(
    out_path: &Path,
    layout: &ArtifactCodegenLayout<'_>,
    cases: &[ArtifactRepr],
) {
    let mut out = String::new();
    out.push_str("import SuperNeo.Generated.NeoFoldArtifactsCases\n\n");
    for idx in 0..cases.len() {
        let _ = writeln!(
            out,
            "import SuperNeo.Generated.{}{idx}",
            layout.case_module_prefix
        );
    }
    out.push('\n');
    out.push_str("namespace SuperNeo.Generated\n\n");
    let _ = writeln!(
        out,
        "def {} : Array NeoFoldArtifactCase := #[",
        layout.generated_array_name
    );
    for idx in 0..cases.len() {
        let comma = if idx + 1 == cases.len() { "" } else { "," };
        let _ = writeln!(out, "  {}{idx}{comma}", layout.case_def_prefix);
    }
    out.push_str("]\n\n");
    out.push_str("end SuperNeo.Generated\n");
    fs::write(out_path, out).expect("write NeoFoldArtifacts.lean");
}

#[allow(dead_code)]
pub(crate) fn write_generated_module(out_path: &Path, cases: &[ArtifactRepr]) {
    write_generated_module_with_layout(out_path, &DEFAULT_ARTIFACT_LAYOUT, cases)
}
