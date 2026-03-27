//! Performance/debugging reports for the current RV64IM proof path.

use std::collections::BTreeSet;
use std::env;
use std::time::Instant;

use neo_fold_next::rv64im::ccs::{rv64im_root_main_lane_ccs, RV64IM_ROOT_PUBLIC_INPUTS, RV64IM_ROOT_ROW_WIDTH};
use neo_fold_next::rv64im::layout::{
    RV64IM_PARITY_LOWERING_VERSION_ID, RV64IM_PARITY_PROTOCOL_VERSION_ID, RV64_REGISTER_COUNT,
};
use neo_fold_next::rv64im::stage1::build_stage1_summary;
use neo_fold_next::rv64im::stage2::{build_stage2_summary, RamAccessKind, RegisterReadRole};
use neo_fold_next::rv64im::stage3::build_stage3_summary;
use neo_fold_next::rv64im::tables::Rv64FamilyTag;
use neo_fold_next::rv64im::{
    build_parity_case_from_source, build_program, build_simple_kernel_witness, encode_add, encode_addi, encode_addiw,
    encode_and, encode_beq, encode_divu, encode_ecall, encode_ld, encode_mul, encode_remu, encode_sd, encode_slli,
    encode_xor, prove_rv64im_proof, rv64im_simple_root_params, verify_rv64im_proof, MemoryWord, Rv64Program, Rv64State,
    Rv64imParityCaseManifest, Rv64imParitySourceCase, Rv64imProofInput,
};

const DEFAULT_DEBUG_N: usize = 100;
const START_PC: u64 = 0x1000;
const PERF_MEMORY_ADDR: u64 = 0x100;
const MIXED_BLOCK_LEN: usize = 13;
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

fn perf_opcode_count_from_env() -> usize {
    match env::var("NS_DEBUG_N") {
        Ok(raw) => raw.parse().expect("NS_DEBUG_N must parse as usize"),
        Err(_) => DEFAULT_DEBUG_N,
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

fn mixed_opcode_perf_source_case(opcode_count: usize) -> (Rv64imParitySourceCase, usize) {
    let mixed_block = [
        encode_addi(1, 1, 1),
        encode_addi(2, 2, 3),
        encode_add(3, 1, 2),
        encode_slli(4, 3, 1),
        encode_xor(5, 4, 2),
        encode_mul(6, 5, 1),
        encode_divu(7, 6, 1),
        encode_remu(8, 6, 1),
        encode_beq(1, 0, 8),
        encode_sd(7, 0, PERF_MEMORY_ADDR as i16),
        encode_ld(9, 0, PERF_MEMORY_ADDR as i16),
        encode_and(11, 9, 5),
        encode_addiw(12, 11, 7),
    ];

    let mut x1_increment_count = 0usize;
    let mut program_words = Vec::with_capacity(opcode_count + 1);
    while program_words.len() < opcode_count {
        for (idx, word) in mixed_block.iter().copied().enumerate() {
            if program_words.len() == opcode_count {
                break;
            }
            if idx == 0 {
                x1_increment_count += 1;
            }
            program_words.push(word);
        }
    }
    program_words.push(encode_ecall());

    let mut transcript_seed = b"rv64im-mixed-opcode-perf-snapshot-v1".to_vec();
    transcript_seed.extend_from_slice(&(opcode_count as u64).to_le_bytes());

    (
        Rv64imParitySourceCase {
            manifest: Rv64imParityCaseManifest {
                name: "mixed_opcode_perf_snapshot".into(),
                fixture_id: "mixed_opcode_perf_snapshot_v1".into(),
                protocol_version_id: RV64IM_PARITY_PROTOCOL_VERSION_ID,
                lowering_version_id: RV64IM_PARITY_LOWERING_VERSION_ID,
                family_tags: vec![
                    Rv64FamilyTag::NativeAlu,
                    Rv64FamilyTag::Multiply,
                    Rv64FamilyTag::UnsignedDivRem,
                    Rv64FamilyTag::AlignedMemory,
                    Rv64FamilyTag::ControlFlow,
                ],
            },
            start_pc: START_PC,
            program_words,
            initial_registers: [0; RV64_REGISTER_COUNT],
            initial_memory: vec![MemoryWord {
                addr: PERF_MEMORY_ADDR,
                value: 0,
            }],
            transcript_seed,
        },
        x1_increment_count,
    )
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
    let opcode_count = perf_opcode_count_from_env();
    let (source, x1_increment_count) = mixed_opcode_perf_source_case(opcode_count);
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
    let output = build_simple_kernel_witness(&input).expect("build simple kernel witness");
    let build_ms = millis_since(build_started);

    let prove_started = Instant::now();
    let (proved_witness, proof) = prove_rv64im_proof(&input).expect("prove rv64im proof");
    let prove_ms = millis_since(prove_started);

    let verify_started = Instant::now();
    let verified_witness = verify_rv64im_proof(&input, &proof).expect("verify rv64im proof");
    let verify_ms = millis_since(verify_started);

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
    assert_eq!(proved_witness.public_step_count as usize, output.public_steps.len());
    assert_eq!(proof.statement.public_step_count as usize, output.public_steps.len());
    assert_eq!(
        proof.kernel.main_lane.public_step_count() as usize,
        output.public_steps.len()
    );
    assert_eq!(execution_row_count, output.prepared_steps.len());
    assert_eq!(execution_row_count, output.public_steps.len());
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
    assert_eq!(proof.statement.final_pc, START_PC + (total_opcodes as u64) * 4);
    assert!(proof.statement.halted);
    assert_eq!(
        output.kernel_claims.kernel.final_registers[1],
        x1_increment_count as u64
    );
    assert_eq!(output.kernel_claims.kernel.final_pc, proof.statement.final_pc);
    assert!(output.kernel_claims.kernel.halted);
    assert_eq!(output.kernel_claims.kernel.final_memory.len(), 1);
    assert_eq!(output.kernel_claims.kernel.final_memory[0].addr, PERF_MEMORY_ADDR);

    print_section("RV64IM Mixed Opcode Perf Snapshot");
    print_kv("ns_debug_n (non-halt ops)", opcode_count);
    print_kv("program_opcodes_total", total_opcodes);
    print_kv("mixed_block_len", MIXED_BLOCK_LEN);
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
            ("build_simple_kernel", build_ms),
            ("prove_rv64im_proof", prove_ms),
            ("verify_rv64im_proof", verify_ms),
        ],
        opcode_count,
        execution_row_count,
    );

    print_section("CCS / Constraint Shape");
    print_kv("root_row_width", RV64IM_ROOT_ROW_WIDTH);
    print_kv("root_public_inputs", RV64IM_ROOT_PUBLIC_INPUTS);
    print_kv("constraints_per_step (n)", root_ccs.n);
    print_kv("columns_per_step (m)", root_ccs.m);
    print_kv("matrix_count (t)", root_ccs.t());
    print_kv("max_degree", root_ccs.max_degree());
    print_kv("identity_matrices", ccs_identity_matrices);
    print_kv("total_nnz_per_step", ccs_total_nnz);
    print_kv(
        "avg_nnz_per_constraint",
        format!("{:.4}", per_unit(ccs_total_nnz as f64, root_ccs.n)),
    );
    print_kv("approx_constraints_for_trace", approx_trace_constraints);
    print_kv("approx_nnz_for_trace", approx_trace_nnz);
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
    print_kv("public_steps", output.public_steps.len());
    print_kv("stage1_rows", output.stages.stage1.rows.len());
    print_kv("stage3_continuity", output.stages.stage3.continuity.len());
    print_kv("transcript_events", output.stages.transcript.events.len());

    print_family_rows("Row Expansion by Family", &family_rows, opcode_count);
    print_lookup_summary(lookup_summary, opcode_count, &twist_family_counts);

    let total_executed_opcodes = build.executed_steps.len();
    let unique_opcode_labels = collect_unique_opcode_labels(&build);
    print_section("Final Summary");
    print_kv(
        "total opcodes",
        format!("{total_executed_opcodes} ({unique_opcode_labels})"),
    );
    print_kv("total proving time", format!("{prove_ms:.3} ms"));
    print_kv(
        "proving time (avg) per opcode",
        format!("{:.4} ms", per_unit(prove_ms, total_executed_opcodes)),
    );
    print_kv("total verifying time", format!("{verify_ms:.3} ms"));
    print_kv(
        "verifying time (avg) per opcode",
        format!("{:.4} ms", per_unit(verify_ms, total_executed_opcodes)),
    );
}
