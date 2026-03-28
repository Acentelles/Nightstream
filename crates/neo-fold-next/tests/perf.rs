//! Performance/debugging reports for the current RV64IM proof path.

use std::collections::BTreeSet;
use std::env;
use std::time::Instant;

use neo_fold_next::proof::{FoldSchedule, PackagedProof};
use neo_fold_next::rv64im::ccs::{rv64im_root_main_lane_ccs, RV64IM_ROOT_PUBLIC_INPUTS, RV64IM_ROOT_ROW_WIDTH};
use neo_fold_next::rv64im::layout::RV64_REGISTER_COUNT;
use neo_fold_next::rv64im::stage1::build_stage1_summary;
use neo_fold_next::rv64im::stage2::{build_stage2_summary, RamAccessKind, RegisterReadRole};
use neo_fold_next::rv64im::stage3::build_stage3_summary;
use neo_fold_next::rv64im::tables::Rv64FamilyTag;
use neo_fold_next::rv64im::{
    build_mixed_opcode_perf_source_case, build_parity_case_from_source, build_program,
    build_rv64im_audit_witness_bundle as build_rv64im_proof_witness, build_simple_kernel_witness_with_perf,
    mixed_opcode_perf_expected_x1, prove_rv64im_public_proof_with_perf, rv64im_simple_root_params,
    validate_rv64im_public_proof_against_input_with_perf, verify_rv64im_audit_proof as verify_rv64im_proof,
    verify_rv64im_public_proof_with_perf, OpeningAccumulator, OpeningAccumulatorStats, OpeningPointLabel, Rv64Program,
    Rv64State, Rv64imProofInput, SimpleKernelBuildPerf, RV64IM_MIXED_OPCODE_PERF_BLOCK_LEN,
    RV64IM_MIXED_OPCODE_PERF_DEFAULT_N,
};

const FAMILY_ORDER: [Rv64FamilyTag; 7] = [
    Rv64FamilyTag::NativeAlu,
    Rv64FamilyTag::AlignedMemory,
    Rv64FamilyTag::NarrowMemory,
    Rv64FamilyTag::Multiply,
    Rv64FamilyTag::UnsignedDivRem,
    Rv64FamilyTag::SignedDivRem,
    Rv64FamilyTag::ControlFlow,
];

#[derive(Clone, Copy, Default)]
struct FamilyRowStats {
    rows: usize,
    real_rows: usize,
    effect_rows: usize,
    commit_rows: usize,
}

#[derive(Clone, Copy, Default)]
struct LookupSummary {
    register_reads: usize,
    register_reads_rs1: usize,
    register_reads_rs2: usize,
    unique_read_regs: usize,
    register_writes: usize,
    unique_write_regs: usize,
    ram_events: usize,
    ram_reads: usize,
    ram_writes: usize,
    unique_ram_addrs: usize,
    twist_links: usize,
    twist_write_routes: usize,
    twist_memory_before_routes: usize,
    twist_memory_after_routes: usize,
}

#[derive(Clone, Copy, Default)]
struct ExactOpeningClaimStats {
    claims: usize,
    logical_width: usize,
    packed_rows: usize,
    packed_cols: usize,
}

#[derive(Clone, Copy, Default)]
struct PackagedProofStats {
    public_steps: usize,
    public_chunks: usize,
    proof_chunks: usize,
    final_main_claims: usize,
    ccs_outputs: usize,
    dec_children: usize,
}

#[derive(Clone, Copy, Default)]
struct OpeningSurfaceTotals {
    exact_claims: usize,
    flatten_u64_words: usize,
    logical_width: usize,
    packed_rows: usize,
    packed_cols: usize,
    selected_labels: usize,
    selected_claim_words: usize,
    packaged_public_steps: usize,
    packaged_public_chunks: usize,
    packaged_proof_chunks: usize,
    packaged_final_main_claims: usize,
    packaged_ccs_outputs: usize,
    packaged_dec_children: usize,
}

#[derive(Clone, Copy, Default)]
struct OpeningLabelBuckets {
    stage1: usize,
    stage2: usize,
    stage3: usize,
    kernel_binding: usize,
    kernel_prepared_steps: usize,
}

#[derive(Clone, Copy)]
struct ExactStagePerfRow<'a> {
    label: &'a str,
    records: usize,
    selected_labels: usize,
    selected_claim_words: usize,
    flatten_u64_words: usize,
    field_limb_width: usize,
    packed_rows: usize,
    packed_cols: usize,
    flatten_ms: f64,
    limb_encode_ms: f64,
    context_setup_ms: f64,
    ccs_encode_ms: f64,
    ajtai_commit_ms: f64,
    opening_manifest_ms: f64,
    opening_prove_ms: f64,
}

fn perf_opcode_count_from_env() -> usize {
    match env::var("NS_DEBUG_N") {
        Ok(raw) => raw.parse().expect("NS_DEBUG_N must parse as usize"),
        Err(_) => RV64IM_MIXED_OPCODE_PERF_DEFAULT_N,
    }
}

fn family_label(family: Rv64FamilyTag) -> &'static str {
    match family {
        Rv64FamilyTag::NativeAlu => "native_alu",
        Rv64FamilyTag::AlignedMemory => "aligned_memory",
        Rv64FamilyTag::NarrowMemory => "narrow_memory",
        Rv64FamilyTag::Multiply => "multiply",
        Rv64FamilyTag::UnsignedDivRem => "unsigned_divrem",
        Rv64FamilyTag::SignedDivRem => "signed_divrem",
        Rv64FamilyTag::ControlFlow => "control_flow",
    }
}

fn family_index(family: Rv64FamilyTag) -> usize {
    match family {
        Rv64FamilyTag::NativeAlu => 0,
        Rv64FamilyTag::AlignedMemory => 1,
        Rv64FamilyTag::NarrowMemory => 2,
        Rv64FamilyTag::Multiply => 3,
        Rv64FamilyTag::UnsignedDivRem => 4,
        Rv64FamilyTag::SignedDivRem => 5,
        Rv64FamilyTag::ControlFlow => 6,
    }
}

fn millis_since(started: Instant) -> f64 {
    started.elapsed().as_secs_f64() * 1_000.0
}

fn per_unit(ms: f64, units: usize) -> f64 {
    if units == 0 {
        0.0
    } else {
        ms / units as f64
    }
}

fn print_section(title: &str) {
    println!();
    println!("{title}");
    println!("{}", "=".repeat(title.len()));
}

fn print_kv(label: &str, value: impl std::fmt::Display) {
    println!("  {:30} {}", label, value);
}

fn format_fold_schedule(schedule: FoldSchedule) -> String {
    match schedule {
        FoldSchedule::WholeTrace => "WholeTrace".to_string(),
        FoldSchedule::RowsPerChunk(rows) => format!("RowsPerChunk({rows})"),
    }
}

fn collect_unique_opcode_labels(build: &neo_fold_next::rv64im::builder::Rv64ProgramBuild) -> String {
    let mut labels = BTreeSet::new();
    for step in &build.executed_steps {
        labels.insert(format!("{:?}", step.decoded.opcode));
    }
    labels.into_iter().collect::<Vec<_>>().join(", ")
}

fn print_timing_table(rows: &[(&str, f64)], opcode_count: usize, execution_rows: usize) {
    print_section("Timing");
    println!("  {:26} {:>12} {:>14} {:>14}", "phase", "wall ms", "ms/op", "ms/row");
    for (label, ms) in rows {
        println!(
            "  {:26} {:>12.3} {:>14.4} {:>14.4}",
            label,
            ms,
            per_unit(*ms, opcode_count),
            per_unit(*ms, execution_rows),
        );
    }
}

fn exact_stage_path_is_live(rows: &[ExactStagePerfRow<'_>]) -> bool {
    rows.iter().any(|row| {
        row.records != 0
            && (row.packed_rows != 0
                || row.packed_cols != 0
                || row.flatten_u64_words != 0
                || row.field_limb_width != 0
                || row.flatten_ms != 0.0
                || row.limb_encode_ms != 0.0
                || row.context_setup_ms != 0.0
                || row.ccs_encode_ms != 0.0
                || row.ajtai_commit_ms != 0.0
                || row.opening_manifest_ms != 0.0
                || row.opening_prove_ms != 0.0)
    })
}

fn exact_opening_claims_are_live(rows: &[(&str, ExactOpeningClaimStats)]) -> bool {
    rows.iter().any(|(_, stats)| {
        stats.claims != 0 || stats.logical_width != 0 || stats.packed_rows != 0 || stats.packed_cols != 0
    })
}

fn print_family_rows(title: &str, stats: &[FamilyRowStats], opcode_count: usize) {
    print_section(title);
    println!(
        "  {:18} {:>8} {:>8} {:>8} {:>8} {:>12}",
        "family", "rows", "real", "effect", "commit", "rows/op"
    );
    for family in FAMILY_ORDER {
        let stats = stats[family_index(family)];
        if stats.rows == 0 {
            continue;
        }
        println!(
            "  {:18} {:>8} {:>8} {:>8} {:>8} {:>12.4}",
            family_label(family),
            stats.rows,
            stats.real_rows,
            stats.effect_rows,
            stats.commit_rows,
            per_unit(stats.rows as f64, opcode_count),
        );
    }
}

fn print_lookup_summary(summary: LookupSummary, opcode_count: usize, twist_family_counts: &[usize]) {
    print_section("Lookup Summary");
    println!("  {:20} {:>10} {:>10} {:>12}", "kind", "count", "per op", "extra");
    println!(
        "  {:20} {:>10} {:>10.4} {:>12}",
        "register_reads",
        summary.register_reads,
        per_unit(summary.register_reads as f64, opcode_count),
        summary.unique_read_regs
    );
    println!(
        "  {:20} {:>10} {:>10.4} {:>12}",
        "register_writes",
        summary.register_writes,
        per_unit(summary.register_writes as f64, opcode_count),
        summary.unique_write_regs
    );
    println!(
        "  {:20} {:>10} {:>10.4} {:>12}",
        "ram_events",
        summary.ram_events,
        per_unit(summary.ram_events as f64, opcode_count),
        summary.unique_ram_addrs
    );
    println!(
        "  {:20} {:>10} {:>10.4} {:>12}",
        "twist_links",
        summary.twist_links,
        per_unit(summary.twist_links as f64, opcode_count),
        FAMILY_ORDER.len()
    );
    print_kv(
        "register_read_roles",
        format!("rs1={} rs2={}", summary.register_reads_rs1, summary.register_reads_rs2),
    );
    print_kv(
        "ram_access_split",
        format!("read={} write={}", summary.ram_reads, summary.ram_writes),
    );
    print_kv(
        "twist_routed_payloads",
        format!(
            "write={} mem_before={} mem_after={}",
            summary.twist_write_routes, summary.twist_memory_before_routes, summary.twist_memory_after_routes
        ),
    );

    println!();
    println!("  {:18} {:>8} {:>12}", "twist_family", "count", "per op");
    for family in FAMILY_ORDER {
        let count = twist_family_counts[family_index(family)];
        if count == 0 {
            continue;
        }
        println!(
            "  {:18} {:>8} {:>12.4}",
            family_label(family),
            count,
            per_unit(count as f64, opcode_count),
        );
    }
}

fn print_lookup_group_density(
    summary: LookupSummary,
    opcode_count: usize,
    twist_family_counts: &[usize],
    active_twist_family_count: usize,
) {
    print_section("Lookup Group Density");
    println!(
        "  {:20} {:>12} {:>10} {:>14} {:>16}",
        "group_kind", "active_groups", "events", "events/group", "inactive_slots"
    );
    println!(
        "  {:20} {:>12} {:>10} {:>14.4} {:>16}",
        "read_regs",
        summary.unique_read_regs,
        summary.register_reads,
        per_unit(summary.register_reads as f64, summary.unique_read_regs),
        RV64_REGISTER_COUNT.saturating_sub(summary.unique_read_regs)
    );
    println!(
        "  {:20} {:>12} {:>10} {:>14.4} {:>16}",
        "write_regs",
        summary.unique_write_regs,
        summary.register_writes,
        per_unit(summary.register_writes as f64, summary.unique_write_regs),
        RV64_REGISTER_COUNT.saturating_sub(summary.unique_write_regs)
    );
    println!(
        "  {:20} {:>12} {:>10} {:>14.4} {:>16}",
        "ram_addrs",
        summary.unique_ram_addrs,
        summary.ram_events,
        per_unit(summary.ram_events as f64, summary.unique_ram_addrs),
        "n/a"
    );
    println!(
        "  {:20} {:>12} {:>10} {:>14.4} {:>16}",
        "twist_families",
        active_twist_family_count,
        summary.twist_links,
        per_unit(summary.twist_links as f64, active_twist_family_count),
        FAMILY_ORDER.len().saturating_sub(active_twist_family_count)
    );
    print_kv(
        "used_lookup_groups (current proxy)",
        format!(
            "read_regs={} write_regs={} ram_addrs={} twist_families={}",
            summary.unique_read_regs, summary.unique_write_regs, summary.unique_ram_addrs, active_twist_family_count
        ),
    );
    print_kv(
        "avg_lookup_events_per_non-halt_opcode",
        format!(
            "reads={:.4} writes={:.4} ram={:.4} twist={:.4}",
            per_unit(summary.register_reads as f64, opcode_count),
            per_unit(summary.register_writes as f64, opcode_count),
            per_unit(summary.ram_events as f64, opcode_count),
            per_unit(summary.twist_links as f64, opcode_count),
        ),
    );
    print_kv(
        "active_twist_families",
        twist_family_counts
            .iter()
            .enumerate()
            .filter(|(_, count)| **count > 0)
            .map(|(idx, _)| family_label(FAMILY_ORDER[idx]))
            .collect::<Vec<_>>()
            .join(", "),
    );
}

fn exact_stage_perf_rows(
    output: &neo_fold_next::rv64im::SimpleKernelOutput,
    perf: &SimpleKernelBuildPerf,
) -> [ExactStagePerfRow<'static>; 3] {
    [
        ExactStagePerfRow {
            label: "stage1",
            records: output.stages.stage1.rows.len(),
            selected_labels: perf.stage_package_bundle.stage1.selected_labels,
            selected_claim_words: perf.stage_package_bundle.stage1.claim_words,
            flatten_u64_words: perf.stage_claim_bundle.stage1.flatten_u64_words,
            field_limb_width: perf.stage_claim_bundle.stage1.field_limb_width,
            packed_rows: perf.stage_claim_bundle.stage1.packed_rows,
            packed_cols: perf.stage_claim_bundle.stage1.packed_cols,
            flatten_ms: perf.stage_claim_bundle.stage1.flatten_ms,
            limb_encode_ms: perf.stage_claim_bundle.stage1.limb_encode_ms,
            context_setup_ms: perf.stage_claim_bundle.stage1.context_setup_ms,
            ccs_encode_ms: perf.stage_claim_bundle.stage1.ccs_encode_ms,
            ajtai_commit_ms: perf.stage_claim_bundle.stage1.ajtai_commit_ms,
            opening_manifest_ms: perf.stage_claim_bundle.stage1.opening_manifest_ms,
            opening_prove_ms: perf.stage_claim_bundle.stage1.opening_prove_ms,
        },
        ExactStagePerfRow {
            label: "stage2",
            records: output.stages.stage2.register_reads.len()
                + output.stages.stage2.register_writes.len()
                + output.stages.stage2.ram_events.len()
                + output.stages.stage2.twist_links.len()
                + 4,
            selected_labels: perf.stage_package_bundle.stage2.selected_labels,
            selected_claim_words: perf.stage_package_bundle.stage2.claim_words,
            flatten_u64_words: perf.stage_claim_bundle.stage2.flatten_u64_words,
            field_limb_width: perf.stage_claim_bundle.stage2.field_limb_width,
            packed_rows: perf.stage_claim_bundle.stage2.packed_rows,
            packed_cols: perf.stage_claim_bundle.stage2.packed_cols,
            flatten_ms: perf.stage_claim_bundle.stage2.flatten_ms,
            limb_encode_ms: perf.stage_claim_bundle.stage2.limb_encode_ms,
            context_setup_ms: perf.stage_claim_bundle.stage2.context_setup_ms,
            ccs_encode_ms: perf.stage_claim_bundle.stage2.ccs_encode_ms,
            ajtai_commit_ms: perf.stage_claim_bundle.stage2.ajtai_commit_ms,
            opening_manifest_ms: perf.stage_claim_bundle.stage2.opening_manifest_ms,
            opening_prove_ms: perf.stage_claim_bundle.stage2.opening_prove_ms,
        },
        ExactStagePerfRow {
            label: "stage3",
            records: output.stages.stage3.continuity.len() + 2,
            selected_labels: perf.stage_package_bundle.stage3.selected_labels,
            selected_claim_words: perf.stage_package_bundle.stage3.claim_words,
            flatten_u64_words: perf.stage_claim_bundle.stage3.flatten_u64_words,
            field_limb_width: perf.stage_claim_bundle.stage3.field_limb_width,
            packed_rows: perf.stage_claim_bundle.stage3.packed_rows,
            packed_cols: perf.stage_claim_bundle.stage3.packed_cols,
            flatten_ms: perf.stage_claim_bundle.stage3.flatten_ms,
            limb_encode_ms: perf.stage_claim_bundle.stage3.limb_encode_ms,
            context_setup_ms: perf.stage_claim_bundle.stage3.context_setup_ms,
            ccs_encode_ms: perf.stage_claim_bundle.stage3.ccs_encode_ms,
            ajtai_commit_ms: perf.stage_claim_bundle.stage3.ajtai_commit_ms,
            opening_manifest_ms: perf.stage_claim_bundle.stage3.opening_manifest_ms,
            opening_prove_ms: perf.stage_claim_bundle.stage3.opening_prove_ms,
        },
    ]
}

fn opening_reuse_stats(output: &neo_fold_next::rv64im::SimpleKernelOutput) -> (OpeningAccumulatorStats, Vec<[u8; 32]>) {
    let mut accumulator = OpeningAccumulator::default();
    for reference in output.root_lane_columns.opening_refs() {
        accumulator
            .observe(reference)
            .expect("root-lane canonical opening alias");
    }
    for reference in output.stage_packages.stage1.claim.opening_refs() {
        accumulator
            .observe(reference)
            .expect("stage1 canonical opening alias");
    }
    for reference in output.stage_packages.stage2.claim.opening_refs() {
        accumulator
            .observe(reference)
            .expect("stage2 canonical opening alias");
    }
    for reference in output.stage_packages.stage3.claim.opening_refs() {
        accumulator
            .observe(reference)
            .expect("stage3 canonical opening alias");
    }
    for reference in output.kernel_opening.claim.opening_refs() {
        accumulator
            .observe(reference)
            .expect("kernel canonical opening alias");
    }
    let opening_ids = accumulator.opening_id_digests();
    (accumulator.stats(), opening_ids)
}

fn print_root_main_lane_family(
    output: &neo_fold_next::rv64im::SimpleKernelOutput,
    proof: &neo_fold_next::rv64im::Rv64imProof,
) {
    print_section("Root Main Lane Columns");
    print_kv("canonical_lane_objects", 1);
    print_kv("row_width", output.root_lane_columns.row_width);
    print_kv("time_len", output.root_lane_columns.time_len);
    print_kv("padded_time_len", output.root_lane_commitment.padded_time_len);
    print_kv("column_count", output.root_lane_columns.column_digests.len());
    print_kv(
        "column_commitments",
        output.root_lane_commitment.commitments.commitments.len(),
    );
    print_kv("selected_openings", output.root_lane_columns.opening_refs().len());
    print_kv(
        "opening_proofs",
        usize::from(output.root_lane_commitment.first_opening.is_some())
            + usize::from(output.root_lane_commitment.last_opening.is_some()),
    );
    print_kv(
        "first_logical_index",
        output
            .root_lane_columns
            .first_row
            .as_ref()
            .map(|reference| reference.id.logical_index)
            .unwrap_or(0),
    );
    print_kv(
        "last_logical_index",
        output
            .root_lane_columns
            .last_row
            .as_ref()
            .map(|reference| reference.id.logical_index)
            .unwrap_or(0),
    );
    print_kv(
        "fold_schedule",
        format_fold_schedule(proof.kernel.main_lane.fold_schedule()),
    );
    print_kv("proof_chunks", proof.kernel.main_lane.chunk_count());
    print_kv(
        "bridge_status",
        "column family has Ajtai commitments and selected row openings; root reductions now prove schedule-bound contiguous chunks",
    );
}

fn print_exact_stage_witness_shape(rows: &[ExactStagePerfRow<'_>]) {
    if !exact_stage_path_is_live(rows) {
        print_section("Exact Stage Path");
        print_kv("status", "disabled on the live proof-complete public path");
        return;
    }
    print_section("Exact Stage Witness Shape");
    println!(
        "  {:10} {:>8} {:>10} {:>10} {:>12} {:>12} {:>10} {:>12} {:>12} {:>10}",
        "surface",
        "records",
        "pack_rows",
        "pack_cols",
        "u64_words",
        "field_limbs",
        "blowup",
        "u64/record",
        "limbs/record",
        "selected"
    );
    for row in rows {
        println!(
            "  {:10} {:>8} {:>10} {:>10} {:>12} {:>12} {:>10.4} {:>12.4} {:>12.4} {:>10}",
            row.label,
            row.records,
            row.packed_rows,
            row.packed_cols,
            row.flatten_u64_words,
            row.field_limb_width,
            per_unit(row.field_limb_width as f64, row.flatten_u64_words),
            per_unit(row.flatten_u64_words as f64, row.records),
            per_unit(row.field_limb_width as f64, row.records),
            row.selected_labels,
        );
    }
}

fn print_selected_vs_exact_amplification(rows: &[ExactStagePerfRow<'_>]) {
    if !exact_stage_path_is_live(rows) {
        return;
    }
    print_section("Selected vs Exact Amplification");
    println!(
        "  {:10} {:>12} {:>12} {:>12} {:>14} {:>12} {:>12}",
        "surface", "field_limbs", "claim_words", "labels", "exact/claim", "claim/label", "ms/label"
    );
    for row in rows {
        println!(
            "  {:10} {:>12} {:>12} {:>12} {:>14.4} {:>12.4} {:>12.4}",
            row.label,
            row.field_limb_width,
            row.selected_claim_words,
            row.selected_labels,
            per_unit(row.field_limb_width as f64, row.selected_claim_words),
            per_unit(row.selected_claim_words as f64, row.selected_labels),
            per_unit(
                row.flatten_ms
                    + row.limb_encode_ms
                    + row.context_setup_ms
                    + row.ccs_encode_ms
                    + row.ajtai_commit_ms
                    + row.opening_manifest_ms
                    + row.opening_prove_ms,
                row.selected_labels,
            ),
        );
    }
}

fn print_exact_stage_build_breakdown(rows: &[ExactStagePerfRow<'_>]) {
    if !exact_stage_path_is_live(rows) {
        return;
    }
    print_section("Exact Stage Build Breakdown");
    println!(
        "  {:10} {:>9} {:>9} {:>9} {:>9} {:>9} {:>9} {:>9}",
        "surface", "flatten", "limb", "context", "ccs", "commit", "manifest", "proof"
    );
    for row in rows {
        println!(
            "  {:10} {:>9.3} {:>9.3} {:>9.3} {:>9.3} {:>9.3} {:>9.3} {:>9.3}",
            row.label,
            row.flatten_ms,
            row.limb_encode_ms,
            row.context_setup_ms,
            row.ccs_encode_ms,
            row.ajtai_commit_ms,
            row.opening_manifest_ms,
            row.opening_prove_ms,
        );
    }
}

fn print_opening_reuse_proxy(output: &neo_fold_next::rv64im::SimpleKernelOutput) {
    let (stats, unique_opening_ids) = opening_reuse_stats(output);
    print_section("Opening Reuse");
    print_kv("opening_requests_total", stats.total_requests);
    print_kv("opening_requests_unique", stats.unique_requests);
    print_kv("opening_requests_aliased", stats.aliased_requests);
    print_kv(
        "opening_request_reuse_ratio",
        format!("{:.4}", per_unit(stats.aliased_requests as f64, stats.total_requests)),
    );
    print_kv("opening_id_digests_recorded", unique_opening_ids.len());
}

fn print_compact_opening_build_breakdown(perf: &SimpleKernelBuildPerf) {
    print_section("Compact Opening Build Breakdown");
    println!(
        "  {:18} {:>8} {:>12} {:>12} {:>12}",
        "surface", "labels", "claim_words", "package_ms", "ms/label"
    );
    for (label, stats) in [
        ("stage1", perf.stage_package_bundle.stage1),
        ("stage2", perf.stage_package_bundle.stage2),
        ("stage3", perf.stage_package_bundle.stage3),
        ("kernel_bindings", perf.kernel_opening_bundle.bindings),
        ("kernel_prepared", perf.kernel_opening_bundle.prepared_steps),
    ] {
        println!(
            "  {:18} {:>8} {:>12} {:>12.3} {:>12.4}",
            label,
            stats.selected_labels,
            stats.claim_words,
            stats.package_ms,
            per_unit(stats.package_ms, stats.selected_labels),
        );
    }
}

fn print_verify_breakdown(
    title: &str,
    perf: &neo_fold_next::rv64im::Rv64imPublicProofVerifyPerf,
    opcode_count: usize,
    execution_rows: usize,
) {
    print_section(title);
    println!("  {:26} {:>12} {:>14} {:>14}", "phase", "wall ms", "ms/op", "ms/row");
    for (label, ms) in [
        ("public_claim_digests", perf.public_claim_digests_ms),
        ("public_bundle_digests", perf.public_bundle_digests_ms),
        ("public_bundle_bindings", perf.public_bundle_bindings_ms),
        ("root_main_lane_proof", perf.root_main_lane_proof_ms),
        ("stage_package_verify", perf.stage_package_verify_ms),
        ("kernel_opening_verify", perf.kernel_opening_verify_ms),
        ("summary_consistency", perf.summary_consistency_ms),
    ] {
        println!(
            "  {:26} {:>12.3} {:>14.4} {:>14.4}",
            label,
            ms,
            per_unit(ms, opcode_count),
            per_unit(ms, execution_rows),
        );
    }

    if perf.public_kernel_build.total_ms > 0.0 {
        println!(
            "  {:26} {:>12.3} {:>14.4} {:>14.4}",
            "build_public_kernel",
            perf.public_kernel_build.total_ms,
            per_unit(perf.public_kernel_build.total_ms, opcode_count),
            per_unit(perf.public_kernel_build.total_ms, execution_rows),
        );
        println!();
        println!("  {:26} {:>12}", "build_public_kernel subphase", "wall ms");
        println!(
            "  {:26} {:>12.3}",
            "root_lane_witness", perf.public_kernel_build.root_lane_witness_ms
        );
        println!(
            "  {:26} {:>12.3}",
            "root_lane_columns", perf.public_kernel_build.root_lane_columns_ms
        );
        println!(
            "  {:26} {:>12.3}",
            "root_lane_commitment", perf.public_kernel_build.root_lane_commitment_ms
        );
        println!(
            "  {:26} {:>12.3}",
            "prepared_step_bindings", perf.public_kernel_build.prepared_step_bindings_ms
        );
        println!(
            "  {:26} {:>12.3}",
            "stage_claim_build", perf.public_kernel_build.stage_claim_bundle.total_ms
        );
        println!(
            "  {:26} {:>12.3}",
            "stage_package_build", perf.public_kernel_build.stage_package_bundle.total_ms
        );
        println!(
            "  {:26} {:>12.3}",
            "kernel_opening_build", perf.public_kernel_build.kernel_opening_bundle.total_ms
        );
    } else {
        println!();
        println!("  theorem verify uses the carried proof witness; no public-kernel replay runs in this path");
    }
}

fn packaged_proof_stats(packaged: &PackagedProof) -> PackagedProofStats {
    let mut stats = PackagedProofStats {
        public_steps: packaged.statement.public_step_count(),
        public_chunks: packaged.statement.chunks.len(),
        proof_chunks: packaged.proof.session.chunks.len(),
        final_main_claims: packaged.proof.session.final_main_claims.len(),
        ..PackagedProofStats::default()
    };
    for chunk in &packaged.proof.session.chunks {
        stats.ccs_outputs += chunk.ccs_outputs.len();
        stats.dec_children += chunk.dec.children.len();
    }
    stats
}

fn opening_surface_totals(
    build_perf: &SimpleKernelBuildPerf,
    exact_claims: &[ExactOpeningClaimStats],
    packaged_proofs: &[PackagedProofStats],
    selected_labels: usize,
) -> OpeningSurfaceTotals {
    let mut totals = OpeningSurfaceTotals {
        selected_labels,
        flatten_u64_words: build_perf.stage_claim_bundle.stage1.flatten_u64_words
            + build_perf.stage_claim_bundle.stage2.flatten_u64_words
            + build_perf.stage_claim_bundle.stage3.flatten_u64_words,
        selected_claim_words: build_perf.stage_package_bundle.stage1.claim_words
            + build_perf.stage_package_bundle.stage2.claim_words
            + build_perf.stage_package_bundle.stage3.claim_words
            + build_perf.kernel_opening_bundle.bindings.claim_words
            + build_perf.kernel_opening_bundle.prepared_steps.claim_words,
        ..OpeningSurfaceTotals::default()
    };
    for stats in exact_claims {
        totals.exact_claims += stats.claims;
        totals.logical_width += stats.logical_width;
        totals.packed_rows += stats.packed_rows;
        totals.packed_cols += stats.packed_cols;
    }
    for stats in packaged_proofs {
        totals.packaged_public_steps += stats.public_steps;
        totals.packaged_public_chunks += stats.public_chunks;
        totals.packaged_proof_chunks += stats.proof_chunks;
        totals.packaged_final_main_claims += stats.final_main_claims;
        totals.packaged_ccs_outputs += stats.ccs_outputs;
        totals.packaged_dec_children += stats.dec_children;
    }
    totals
}

fn opening_label_buckets(labels: &[OpeningPointLabel]) -> OpeningLabelBuckets {
    let mut buckets = OpeningLabelBuckets::default();
    for label in labels {
        match label {
            OpeningPointLabel::Stage1First
            | OpeningPointLabel::Stage1Effect
            | OpeningPointLabel::Stage1Commit
            | OpeningPointLabel::Stage1Last => buckets.stage1 += 1,
            OpeningPointLabel::Stage2FirstRead
            | OpeningPointLabel::Stage2LastRead
            | OpeningPointLabel::Stage2FirstWrite
            | OpeningPointLabel::Stage2LastWrite
            | OpeningPointLabel::Stage2FirstRam
            | OpeningPointLabel::Stage2LastRam
            | OpeningPointLabel::Stage2FirstTwist
            | OpeningPointLabel::Stage2LastTwist => buckets.stage2 += 1,
            OpeningPointLabel::Stage3FirstContinuity | OpeningPointLabel::Stage3LastContinuity => buckets.stage3 += 1,
            OpeningPointLabel::KernelFirstBinding | OpeningPointLabel::KernelLastBinding => buckets.kernel_binding += 1,
            OpeningPointLabel::KernelFirstPreparedStep | OpeningPointLabel::KernelLastPreparedStep => {
                buckets.kernel_prepared_steps += 1
            }
        }
    }
    buckets
}

fn print_exact_opening_table(rows: &[(&str, ExactOpeningClaimStats)], opcode_count: usize, execution_rows: usize) {
    if !exact_opening_claims_are_live(rows) {
        return;
    }
    print_section("Exact Opening Claims");
    println!(
        "  {:18} {:>8} {:>12} {:>12} {:>12} {:>10} {:>10}",
        "surface", "claims", "field_limbs", "packed_rows", "packed_cols", "claims/op", "claims/row"
    );
    for (label, stats) in rows {
        println!(
            "  {:18} {:>8} {:>12} {:>12} {:>12} {:>10.4} {:>10.4}",
            label,
            stats.claims,
            stats.logical_width,
            stats.packed_rows,
            stats.packed_cols,
            per_unit(stats.claims as f64, opcode_count),
            per_unit(stats.claims as f64, execution_rows),
        );
    }
}

fn print_packaged_proof_table(rows: &[(&str, PackagedProofStats)]) {
    print_section("Packaged Opening Proofs");
    println!(
        "  {:18} {:>12} {:>13} {:>12} {:>12} {:>12} {:>12}",
        "surface", "public_steps", "public_chunks", "proof_chunks", "final_main", "ccs_outputs", "dec_children"
    );
    for (label, stats) in rows {
        println!(
            "  {:18} {:>12} {:>13} {:>12} {:>12} {:>12} {:>12}",
            label,
            stats.public_steps,
            stats.public_chunks,
            stats.proof_chunks,
            stats.final_main_claims,
            stats.ccs_outputs,
            stats.dec_children,
        );
    }
}

fn print_opening_surface_totals(totals: OpeningSurfaceTotals, opcode_count: usize, execution_rows: usize) {
    print_section("Opening Surface Totals");
    print_kv("selected_labels_total", totals.selected_labels);
    print_kv("selected_claim_words_total", totals.selected_claim_words);
    print_kv("packaged_public_steps_total", totals.packaged_public_steps);
    print_kv("packaged_public_chunks_total", totals.packaged_public_chunks);
    print_kv("packaged_proof_chunks_total", totals.packaged_proof_chunks);
    print_kv("packaged_final_main_claims_total", totals.packaged_final_main_claims);
    print_kv("packaged_ccs_outputs_total", totals.packaged_ccs_outputs);
    print_kv("packaged_dec_children_total", totals.packaged_dec_children);
    if totals.exact_claims != 0 || totals.flatten_u64_words != 0 || totals.logical_width != 0 {
        print_kv("exact_claims_total", totals.exact_claims);
        print_kv("exact_stage_flatten_u64_words_total", totals.flatten_u64_words);
        print_kv("exact_field_limb_width_total", totals.logical_width);
        print_kv("packed_rows_total", totals.packed_rows);
        print_kv("packed_cols_total", totals.packed_cols);
        print_kv(
            "exact_claims_per_non-halt_opcode",
            format!("{:.4}", per_unit(totals.exact_claims as f64, opcode_count)),
        );
        print_kv(
            "selected_labels_per_exact_claim",
            format!("{:.4}", per_unit(totals.selected_labels as f64, totals.exact_claims)),
        );
        print_kv(
            "exact_to_selected_amplification",
            format!(
                "{:.4}",
                per_unit(totals.logical_width as f64, totals.selected_claim_words)
            ),
        );
    }
    print_kv(
        "packaged_dec_children_per_execution_row",
        format!("{:.4}", per_unit(totals.packaged_dec_children as f64, execution_rows)),
    );
}

fn print_opening_label_summary(labels: &[OpeningPointLabel]) {
    let buckets = opening_label_buckets(labels);
    let rendered = labels
        .iter()
        .map(|label| format!("{label:?}"))
        .collect::<Vec<_>>()
        .join(", ");
    print_section("Selected Opening Labels");
    print_kv("total_labels", labels.len());
    print_kv(
        "bucket_counts",
        format!(
            "stage1={} stage2={} stage3={} kernel_binding={} kernel_prepared={}",
            buckets.stage1, buckets.stage2, buckets.stage3, buckets.kernel_binding, buckets.kernel_prepared_steps
        ),
    );
    print_kv("labels", rendered);
}

fn aggregate_family_rows(output: &neo_fold_next::rv64im::SimpleKernelOutput) -> [FamilyRowStats; FAMILY_ORDER.len()] {
    let mut stats = [FamilyRowStats::default(); FAMILY_ORDER.len()];
    for row in &output.trace.execution_rows {
        let family = &mut stats[family_index(row.family)];
        family.rows += 1;
        family.real_rows += usize::from(row.is_real);
        family.effect_rows += usize::from(row.is_effect_row);
        family.commit_rows += usize::from(row.is_commit_row);
    }
    stats
}

fn aggregate_lookups(
    output: &neo_fold_next::rv64im::SimpleKernelOutput,
) -> (LookupSummary, [usize; FAMILY_ORDER.len()]) {
    let mut read_regs = [false; RV64_REGISTER_COUNT];
    let mut write_regs = [false; RV64_REGISTER_COUNT];
    let mut ram_addrs = BTreeSet::new();
    let mut twist_family_counts = [0usize; FAMILY_ORDER.len()];
    let mut summary = LookupSummary::default();

    for event in &output.stages.stage2.register_reads {
        summary.register_reads += 1;
        match event.role {
            RegisterReadRole::Rs1 => summary.register_reads_rs1 += 1,
            RegisterReadRole::Rs2 => summary.register_reads_rs2 += 1,
        }
        if let Some(seen) = read_regs.get_mut(event.reg as usize) {
            *seen = true;
        }
    }

    for event in &output.stages.stage2.register_writes {
        summary.register_writes += 1;
        if let Some(seen) = write_regs.get_mut(event.reg as usize) {
            *seen = true;
        }
    }

    for event in &output.stages.stage2.ram_events {
        summary.ram_events += 1;
        match event.kind {
            RamAccessKind::Read => summary.ram_reads += 1,
            RamAccessKind::Write => summary.ram_writes += 1,
        }
        ram_addrs.insert(event.addr);
    }

    for event in &output.stages.stage2.twist_links {
        summary.twist_links += 1;
        twist_family_counts[family_index(event.family)] += 1;
        summary.twist_write_routes += usize::from(event.routed_write_value.is_some());
        summary.twist_memory_before_routes += usize::from(event.routed_memory_before.is_some());
        summary.twist_memory_after_routes += usize::from(event.routed_memory_after.is_some());
    }

    summary.unique_read_regs = read_regs.iter().filter(|seen| **seen).count();
    summary.unique_write_regs = write_regs.iter().filter(|seen| **seen).count();
    summary.unique_ram_addrs = ram_addrs.len();
    (summary, twist_family_counts)
}

#[test]
#[ignore = "performance/debugging snapshot; run with --release -- --ignored --nocapture"]
fn rv64im_mixed_opcode_perf_snapshot() {
    let end_to_end_started = Instant::now();
    let opcode_count = perf_opcode_count_from_env();
    let source = build_mixed_opcode_perf_source_case(opcode_count);
    let x1_increment_count = mixed_opcode_perf_expected_x1(opcode_count);
    let total_opcodes = source.program_words.len();
    let input = Rv64imProofInput {
        source: source.clone(),
        max_steps: total_opcodes,
    };

    let program = Rv64Program::new(source.start_pc, source.program_words.clone());
    let initial_state = Rv64State::new(source.start_pc, source.initial_registers, &source.initial_memory);

    let build_program_started = Instant::now();
    let build = build_program(&program, &initial_state, total_opcodes).expect("build program");
    let build_program_ms = millis_since(build_program_started);

    let stage1_started = Instant::now();
    let stage1 = build_stage1_summary(&build.rows);
    let stage1_ms = millis_since(stage1_started);

    let stage2_started = Instant::now();
    let stage2 = build_stage2_summary(&build.rows);
    let stage2_ms = millis_since(stage2_started);

    let stage3_started = Instant::now();
    let stage3 = build_stage3_summary(&build.rows);
    let stage3_ms = millis_since(stage3_started);

    let parity_started = Instant::now();
    let (_, derived) = build_parity_case_from_source(source.clone(), total_opcodes).expect("build derived parity case");
    let parity_ms = millis_since(parity_started);

    let build_started = Instant::now();
    let (output, build_perf) = build_simple_kernel_witness_with_perf(&input).expect("build simple kernel witness");
    let build_ms = millis_since(build_started);

    let prove_started = Instant::now();
    let (proof, prove_perf) = prove_rv64im_public_proof_with_perf(&input).expect("prove rv64im public proof");
    let prove_ms = millis_since(prove_started);

    let verify_started = Instant::now();
    let verify_perf = verify_rv64im_public_proof_with_perf(&proof).expect("verify rv64im public proof");
    let verify_ms = millis_since(verify_started);

    let verify_replay_started = Instant::now();
    let verify_replay_perf = validate_rv64im_public_proof_against_input_with_perf(&input, &proof)
        .expect("validate rv64im public proof against input");
    let verify_replay_ms = millis_since(verify_replay_started);
    let end_to_end_ms = millis_since(end_to_end_started);

    let prove_witness_started = Instant::now();
    let proved_witness = build_rv64im_proof_witness(&input).expect("build rv64im proof witness");
    let prove_witness_ms = millis_since(prove_witness_started);

    let verify_witness_started = Instant::now();
    let verified_witness = verify_rv64im_proof(&proof).expect("verify rv64im proof witness");
    let verify_witness_ms = millis_since(verify_witness_started);

    let execution_row_count = output.trace.execution_rows.len();
    let real_row_count = output
        .trace
        .execution_rows
        .iter()
        .filter(|row| row.is_real)
        .count();
    let effect_row_count = output
        .trace
        .execution_rows
        .iter()
        .filter(|row| row.is_effect_row)
        .count();
    let commit_row_count = output
        .trace
        .execution_rows
        .iter()
        .filter(|row| row.is_commit_row)
        .count();

    let root_ccs = rv64im_root_main_lane_ccs().expect("build RV64IM root CCS");
    let root_params = rv64im_simple_root_params();
    let root_ccs_n_p2 = root_ccs.n.next_power_of_two();
    let root_ccs_m_p2 = root_ccs.m.next_power_of_two();
    let ccs_total_nnz: usize = root_ccs
        .matrices
        .iter()
        .map(|matrix| {
            matrix
                .as_csc()
                .map(|csc| csc.vals.len())
                .unwrap_or(matrix.rows())
        })
        .sum();
    let ccs_identity_matrices = root_ccs
        .matrices
        .iter()
        .filter(|matrix| matrix.as_csc().is_none())
        .count();
    let approx_trace_constraints = root_ccs.n.saturating_mul(output.prepared_steps.len());
    let approx_trace_nnz = ccs_total_nnz.saturating_mul(output.prepared_steps.len());
    let family_rows = aggregate_family_rows(&output);
    let (lookup_summary, twist_family_counts) = aggregate_lookups(&output);
    let active_twist_family_count = twist_family_counts
        .iter()
        .filter(|count| **count > 0)
        .count();
    let stage1_exact_openings = ExactOpeningClaimStats::default();
    let stage2_exact_openings = ExactOpeningClaimStats::default();
    let stage3_exact_openings = ExactOpeningClaimStats::default();
    let stage1_packaged = packaged_proof_stats(&output.stage_packages.stage1.packaged);
    let stage2_packaged = packaged_proof_stats(&output.stage_packages.stage2.packaged);
    let stage3_packaged = packaged_proof_stats(&output.stage_packages.stage3.packaged);
    let kernel_binding_packaged = packaged_proof_stats(&output.kernel_opening.bindings.packaged);
    let kernel_prepared_packaged = packaged_proof_stats(&output.kernel_opening.prepared_steps.packaged);
    let mut selected_opening_labels = output.stage_packages.stage1.claim.labels();
    selected_opening_labels.extend(output.stage_packages.stage2.claim.labels());
    selected_opening_labels.extend(output.stage_packages.stage3.claim.labels());
    selected_opening_labels.extend(output.kernel_opening.claim.labels());
    let opening_totals = opening_surface_totals(
        &build_perf,
        &[stage1_exact_openings, stage2_exact_openings, stage3_exact_openings],
        &[
            stage1_packaged,
            stage2_packaged,
            stage3_packaged,
            kernel_binding_packaged,
            kernel_prepared_packaged,
        ],
        selected_opening_labels.len(),
    );
    let exact_stage_rows = exact_stage_perf_rows(&output, &build_perf);

    assert_eq!(build.rows, output.trace.execution_rows);
    assert_eq!(build.final_state.pc, output.kernel_claims.kernel.final_pc);
    assert_eq!(stage1, output.stages.stage1);
    assert_eq!(stage2, output.stages.stage2);
    assert_eq!(stage3, output.stages.stage3);
    assert_eq!(derived.execution_rows, output.trace.execution_rows);
    assert_eq!(derived.stage1, output.stages.stage1);
    assert_eq!(derived.stage2, output.stages.stage2);
    assert_eq!(derived.stage3, output.stages.stage3);
    assert_eq!(derived.transcript, output.stages.transcript);
    assert_eq!(derived.kernel, output.kernel_claims.kernel);

    assert_eq!(proved_witness.digest, verified_witness.digest);
    assert_eq!(proved_witness.trace.digest, verified_witness.trace.digest);
    assert_eq!(
        proved_witness.kernel_claims.digest,
        verified_witness.kernel_claims.digest
    );
    assert_eq!(
        proved_witness.root_lane_columns.time_len as usize,
        output.prepared_steps.len()
    );
    assert_eq!(proof.statement.public_step_count as usize, output.prepared_steps.len());
    assert_eq!(
        proof.kernel.root_lane_columns.time_len as usize,
        output.prepared_steps.len()
    );
    assert_eq!(execution_row_count, output.prepared_steps.len());
    assert_eq!(execution_row_count, output.root_lane_columns.time_len as usize);
    assert_eq!(
        proved_witness.trace.shape.execution_row_count as usize,
        execution_row_count
    );
    assert_eq!(proved_witness.trace.shape.real_row_count as usize, real_row_count);
    assert_eq!(proved_witness.trace.shape.effect_row_count as usize, effect_row_count);
    assert_eq!(proved_witness.trace.shape.commit_row_count as usize, commit_row_count);
    assert_eq!(
        proof.kernel.stages.summary.stage1_row_count as usize,
        output.stages.stage1.rows.len()
    );
    assert_eq!(
        proof.kernel.stages.summary.stage2_register_read_count as usize,
        output.stages.stage2.register_reads.len()
    );
    assert_eq!(
        proof.kernel.stages.summary.stage2_register_write_count as usize,
        output.stages.stage2.register_writes.len()
    );
    assert_eq!(
        proof.kernel.stages.summary.stage2_ram_event_count as usize,
        output.stages.stage2.ram_events.len()
    );
    assert_eq!(
        proof.kernel.stages.summary.stage2_twist_link_count as usize,
        output.stages.stage2.twist_links.len()
    );
    assert_eq!(
        proof.kernel.stages.summary.stage3_continuity_count as usize,
        output.stages.stage3.continuity.len()
    );
    assert_eq!(
        proof.kernel.stages.summary.transcript_event_count as usize,
        output.stages.transcript.events.len()
    );
    assert_eq!(proof.statement.final_pc, source.start_pc + (total_opcodes as u64) * 4);
    assert!(proof.statement.halted);
    assert_eq!(
        output.kernel_claims.kernel.final_registers[1],
        x1_increment_count as u64
    );
    assert_eq!(output.kernel_claims.kernel.final_pc, proof.statement.final_pc);
    assert!(output.kernel_claims.kernel.halted);
    assert_eq!(output.kernel_claims.kernel.final_memory.len(), 1);
    assert_eq!(
        output.kernel_claims.kernel.final_memory[0].addr,
        source.initial_memory[0].addr
    );

    print_section("RV64IM Mixed Opcode Perf Snapshot");
    print_kv("ns_debug_n (non-halt ops)", opcode_count);
    print_kv("program_opcodes_total", total_opcodes);
    print_kv("mixed_block_len", RV64IM_MIXED_OPCODE_PERF_BLOCK_LEN);
    print_kv("family_tags", source.manifest.family_tags.len());
    print_kv("final_pc", proof.statement.final_pc);
    print_kv("final_x1", output.kernel_claims.kernel.final_registers[1]);
    print_kv("final_x7", output.kernel_claims.kernel.final_registers[7]);
    print_kv("final_mem_0x100", output.kernel_claims.kernel.final_memory[0].value);
    print_kv(
        "row_expansion",
        format!(
            "{execution_row_count}/{opcode_count} = {:.4} rows/op",
            per_unit(execution_row_count as f64, opcode_count)
        ),
    );
    print_kv(
        "prepared_step_expansion",
        format!(
            "{}/{} = {:.4} steps/op",
            output.prepared_steps.len(),
            opcode_count,
            per_unit(output.prepared_steps.len() as f64, opcode_count)
        ),
    );

    print_timing_table(
        &[
            ("build_program", build_program_ms),
            ("stage1_summary", stage1_ms),
            ("stage2_summary", stage2_ms),
            ("stage3_summary", stage3_ms),
            ("build_parity_case", parity_ms),
            ("root_lane_witness", build_perf.root_lane_witness_ms),
            ("root_lane_columns", build_perf.root_lane_columns_ms),
            ("root_lane_commitment", build_perf.root_lane_commitment_ms),
            ("build_simple_kernel", build_ms),
            ("prove_rv64im_public_proof", prove_ms),
            ("verify_rv64im_public_proof", verify_ms),
            ("build_rv64im_proof_witness", prove_witness_ms),
            ("verify_rv64im_proof_witness", verify_witness_ms),
        ],
        opcode_count,
        execution_row_count,
    );

    print_section("CCS / Constraint Shape");
    print_kv("root_row_width", RV64IM_ROOT_ROW_WIDTH);
    print_kv("root_public_inputs", RV64IM_ROOT_PUBLIC_INPUTS);
    print_kv("constraints_per_step (n)", root_ccs.n);
    print_kv("columns_per_step (m)", root_ccs.m);
    print_kv("constraints_per_step_p2", root_ccs_n_p2);
    print_kv("columns_per_step_p2", root_ccs_m_p2);
    print_kv("matrix_count (t)", root_ccs.t());
    print_kv("max_degree", root_ccs.max_degree());
    print_kv("identity_matrices", ccs_identity_matrices);
    print_kv("total_nnz_per_step (non-zero matrix entries)", ccs_total_nnz);
    print_kv(
        "avg_nnz_per_constraint (non-zero matrix entries)",
        format!("{:.4}", per_unit(ccs_total_nnz as f64, root_ccs.n)),
    );
    print_kv("approx_constraints_for_trace", approx_trace_constraints);
    print_kv(
        "approx_constraints_per_non-halt_opcode",
        format!("{:.4}", per_unit(approx_trace_constraints as f64, opcode_count)),
    );
    print_kv("approx_nnz_for_trace (non-zero matrix entries)", approx_trace_nnz);
    print_kv(
        "approx_nnz_per_non-halt_opcode (non-zero matrix entries)",
        format!("{:.4}", per_unit(approx_trace_nnz as f64, opcode_count)),
    );
    print_kv(
        "root_params",
        format!(
            "d={} kappa={} m={} b={} k_rho={} B={} T={} s={} lambda={}",
            root_params.d,
            root_params.kappa,
            root_params.m,
            root_params.b,
            root_params.k_rho,
            root_params.B,
            root_params.T,
            root_params.s,
            root_params.lambda
        ),
    );

    print_section("Row / Step Shape");
    print_kv("execution_rows", execution_row_count);
    print_kv("real_rows", real_row_count);
    print_kv("effect_rows", effect_row_count);
    print_kv("commit_rows", commit_row_count);
    print_kv("prepared_steps", output.prepared_steps.len());
    print_kv("public_steps", output.root_lane_columns.time_len);
    print_kv("stage1_rows", output.stages.stage1.rows.len());
    print_kv("stage3_continuity", output.stages.stage3.continuity.len());
    print_kv("transcript_events", output.stages.transcript.events.len());
    print_root_main_lane_family(&output, &proof);

    print_family_rows("Row Expansion by Family", &family_rows, opcode_count);
    print_lookup_summary(lookup_summary, opcode_count, &twist_family_counts);
    print_lookup_group_density(
        lookup_summary,
        opcode_count,
        &twist_family_counts,
        active_twist_family_count,
    );
    print_exact_stage_witness_shape(&exact_stage_rows);
    print_exact_opening_table(
        &[
            ("stage1", stage1_exact_openings),
            ("stage2", stage2_exact_openings),
            ("stage3", stage3_exact_openings),
        ],
        opcode_count,
        execution_row_count,
    );
    print_selected_vs_exact_amplification(&exact_stage_rows);
    print_exact_stage_build_breakdown(&exact_stage_rows);
    print_packaged_proof_table(&[
        ("stage1", stage1_packaged),
        ("stage2", stage2_packaged),
        ("stage3", stage3_packaged),
        ("kernel_bindings", kernel_binding_packaged),
        ("kernel_prepared", kernel_prepared_packaged),
    ]);
    print_compact_opening_build_breakdown(&build_perf);
    print_opening_surface_totals(opening_totals, opcode_count, execution_row_count);
    print_opening_reuse_proxy(&output);
    print_opening_label_summary(&selected_opening_labels);
    print_verify_breakdown(
        "Theorem Verify Breakdown",
        &verify_perf,
        opcode_count,
        execution_row_count,
    );
    print_verify_breakdown(
        "Verify + Input Replay Breakdown",
        &verify_replay_perf,
        opcode_count,
        execution_row_count,
    );

    let total_executed_opcodes = build.executed_steps.len();
    let unique_opcode_labels = collect_unique_opcode_labels(&build);
    print_section("Final Summary");
    print_kv(
        "total opcodes",
        format!("{total_executed_opcodes} ({unique_opcode_labels})"),
    );
    print_kv("total public proving time", format!("{prove_ms:.3} ms"));
    print_kv(
        "public proving time (avg) per opcode",
        format!("{:.4} ms", per_unit(prove_ms, total_executed_opcodes)),
    );
    print_kv("total public verifying time", format!("{verify_ms:.3} ms"));
    print_kv(
        "public verifying time (avg) per opcode",
        format!("{:.4} ms", per_unit(verify_ms, total_executed_opcodes)),
    );
    print_kv("public verify + replay time", format!("{verify_replay_ms:.3} ms"));
    print_kv(
        "public verify + replay time (avg) per opcode",
        format!("{:.4} ms", per_unit(verify_replay_ms, total_executed_opcodes)),
    );
    print_kv("proof witness build time", format!("{prove_witness_ms:.3} ms"));
    print_kv("verified witness build time", format!("{verify_witness_ms:.3} ms"));
    print_kv("total end-to-end time", format!("{end_to_end_ms:.3} ms"));
    print_kv(
        "prove main-lane subphase",
        format!(
            "kernel_build={:.3} ms main_lane={:.3} ms export={:.3} ms",
            prove_perf.simple_kernel.total_ms, prove_perf.main_lane_ms, prove_perf.public_export_ms
        ),
    );
}
