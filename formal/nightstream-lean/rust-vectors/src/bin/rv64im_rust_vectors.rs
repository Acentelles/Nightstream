use std::fs;
use std::path::{Path, PathBuf};

use neo_fold_next::rv64im::{
    build_all_parity_cases, MemoryWord, Rv64imKernelSummary, Rv64imParityCaseManifest, Rv64imParityDerivedCase,
    Rv64imParitySourceCase, TranscriptCursorSnapshot, TranscriptEventKind, TranscriptEventRecord, TranscriptRecord,
};

fn render_u8_list(values: &[u8]) -> String {
    if !values.is_empty() && values.iter().all(|&value| value == 0) {
        return format!("(zeroBytes {})", values.len());
    }
    let mut out = String::from("(bytes [");
    for (idx, value) in values.iter().enumerate() {
        if idx > 0 {
            out.push_str(", ");
        }
        out.push_str(&value.to_string());
    }
    out.push_str("])");
    out
}

fn render_u64_list(values: &[u64]) -> String {
    let mut out = String::from("[");
    for (idx, value) in values.iter().enumerate() {
        if idx > 0 {
            out.push_str(", ");
        }
        out.push_str(&value.to_string());
    }
    out.push(']');
    out
}

fn lean_ident_fragment(name: &str) -> String {
    name.chars()
        .map(|ch| if ch.is_ascii_alphanumeric() { ch } else { '_' })
        .collect()
}

fn generated_dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("..")
        .join("Nightstream")
        .join("Rv64IM")
        .join("Generated")
}

fn case_dir(case_name: &str) -> PathBuf {
    generated_dir()
        .join("Cases")
        .join(format!("Case_{}", lean_ident_fragment(case_name)))
}

fn render_string(value: &str) -> String {
    format!("{value:?}")
}

fn render_family_tag(tag: neo_fold_next::rv64im::tables::Rv64FamilyTag) -> &'static str {
    match tag {
        neo_fold_next::rv64im::tables::Rv64FamilyTag::NativeAlu => ".nativeAlu",
        neo_fold_next::rv64im::tables::Rv64FamilyTag::AlignedMemory => ".alignedMemory",
        neo_fold_next::rv64im::tables::Rv64FamilyTag::ControlFlow => ".controlFlow",
    }
}

fn family_module_name(tag: neo_fold_next::rv64im::tables::Rv64FamilyTag) -> &'static str {
    match tag {
        neo_fold_next::rv64im::tables::Rv64FamilyTag::NativeAlu => "NativeAlu",
        neo_fold_next::rv64im::tables::Rv64FamilyTag::AlignedMemory => "AlignedMemory",
        neo_fold_next::rv64im::tables::Rv64FamilyTag::ControlFlow => "ControlFlow",
    }
}

fn render_opcode(opcode: neo_fold_next::rv64im::Rv64Opcode) -> &'static str {
    match opcode {
        neo_fold_next::rv64im::Rv64Opcode::Addi => ".addi",
        neo_fold_next::rv64im::Rv64Opcode::Add => ".add",
        neo_fold_next::rv64im::Rv64Opcode::Ld => ".ld",
        neo_fold_next::rv64im::Rv64Opcode::Sd => ".sd",
        neo_fold_next::rv64im::Rv64Opcode::Ecall => ".ecall",
    }
}

fn render_register_read_role(role: neo_fold_next::rv64im::stage2::RegisterReadRole) -> &'static str {
    match role {
        neo_fold_next::rv64im::stage2::RegisterReadRole::Rs1 => ".rs1",
        neo_fold_next::rv64im::stage2::RegisterReadRole::Rs2 => ".rs2",
    }
}

fn render_ram_access_kind(kind: neo_fold_next::rv64im::stage2::RamAccessKind) -> &'static str {
    match kind {
        neo_fold_next::rv64im::stage2::RamAccessKind::Read => ".read",
        neo_fold_next::rv64im::stage2::RamAccessKind::Write => ".write",
    }
}

fn render_transcript_event_kind(kind: TranscriptEventKind) -> &'static str {
    match kind {
        TranscriptEventKind::AppendMessage => ".appendMessage",
        TranscriptEventKind::AppendU64s => ".appendU64s",
        TranscriptEventKind::ChallengeField => ".challengeField",
        TranscriptEventKind::Digest32 => ".digest32",
    }
}

fn render_option_nat(value: Option<u64>) -> String {
    match value {
        Some(value) => format!("(some {value})"),
        None => "none".into(),
    }
}

fn render_option_bytes(value: Option<&[u8]>) -> String {
    match value {
        Some(bytes) => format!("(some {})", render_u8_list(bytes)),
        None => "none".into(),
    }
}

fn render_memory_word(word: &MemoryWord) -> String {
    format!("{{ addr := {}, value := {} }}", word.addr, word.value)
}

fn render_memory_words(words: &[MemoryWord]) -> String {
    let mut out = String::from("[");
    for (idx, word) in words.iter().enumerate() {
        if idx > 0 {
            out.push_str(", ");
        }
        out.push_str(&render_memory_word(word));
    }
    out.push(']');
    out
}

fn render_manifest(manifest: &Rv64imParityCaseManifest) -> String {
    let mut family_tags = String::from("[");
    for (idx, tag) in manifest.family_tags.iter().enumerate() {
        if idx > 0 {
            family_tags.push_str(", ");
        }
        family_tags.push_str(render_family_tag(*tag));
    }
    family_tags.push(']');
    format!(
        "{{ name := {}, fixtureId := {}, protocolVersionId := {}, loweringVersionId := {}, familyTags := {} }}",
        render_string(&manifest.name),
        render_string(&manifest.fixture_id),
        manifest.protocol_version_id,
        manifest.lowering_version_id,
        family_tags
    )
}

fn render_source_case(case: &Rv64imParitySourceCase) -> String {
    format!(
        "{{\n  manifest := {}\n  , startPc := {}\n  , programWords := {}\n  , initialRegisters := {}\n  , initialMemory := {}\n  , transcriptSeed := {}\n}}",
        render_manifest(&case.manifest),
        case.start_pc,
        render_u64_list(&case.program_words.iter().map(|word| *word as u64).collect::<Vec<_>>()),
        render_u64_list(&case.initial_registers),
        render_memory_words(&case.initial_memory),
        render_u8_list(&case.transcript_seed),
    )
}

fn render_expanded_row(row: &neo_fold_next::rv64im::lower::Rv64ExpandedRow) -> String {
    format!(
        "{{\n  stepIndex := {}\n  , pc := {}\n  , nextPc := {}\n  , word := {}\n  , opcode := {}\n  , family := {}\n  , rs1 := {}\n  , rs1Value := {}\n  , rs2 := {}\n  , rs2Value := {}\n  , rd := {}\n  , rdBefore := {}\n  , rdAfter := {}\n  , imm := {}\n  , aluResult := {}\n  , effectiveAddr := {}\n  , memoryBefore := {}\n  , memoryAfter := {}\n  , writesRd := {}\n  , writesRam := {}\n  , halted := {}\n}}",
        row.step_index,
        row.pc,
        row.next_pc,
        row.word,
        render_opcode(row.opcode),
        render_family_tag(row.family),
        row.rs1,
        row.rs1_value,
        row.rs2,
        row.rs2_value,
        row.rd,
        row.rd_before,
        row.rd_after,
        row.imm,
        row.alu_result,
        render_option_nat(row.effective_addr),
        render_option_nat(row.memory_before),
        render_option_nat(row.memory_after),
        if row.writes_rd { "true" } else { "false" },
        if row.writes_ram { "true" } else { "false" },
        if row.halted { "true" } else { "false" },
    )
}

fn render_stage1_summary(stage1: &neo_fold_next::rv64im::stage1::Stage1Summary) -> String {
    let mut rows = String::from("[");
    for (idx, row) in stage1.rows.iter().enumerate() {
        if idx > 0 {
            rows.push_str(", ");
        }
        rows.push_str(&format!(
            "{{ stepIndex := {}, fetchPc := {}, fetchedWord := {}, opcode := {}, family := {}, nextPc := {}, aluResult := {}, effectiveAddr := {}, writesRd := {}, rd := {}, rdAfter := {}, preservesX0 := {} }}",
            row.step_index,
            row.fetch_pc,
            row.fetched_word,
            render_opcode(row.opcode),
            render_family_tag(row.family),
            row.next_pc,
            row.alu_result,
            render_option_nat(row.effective_addr),
            if row.writes_rd { "true" } else { "false" },
            row.rd,
            row.rd_after,
            if row.preserves_x0 { "true" } else { "false" },
        ));
    }
    rows.push(']');
    format!("{{ rows := {} }}", rows)
}

fn render_stage2_summary(stage2: &neo_fold_next::rv64im::stage2::Stage2Summary) -> String {
    let mut register_reads = String::from("[");
    for (idx, event) in stage2.register_reads.iter().enumerate() {
        if idx > 0 {
            register_reads.push_str(", ");
        }
        register_reads.push_str(&format!(
            "{{ stepIndex := {}, role := {}, reg := {}, value := {} }}",
            event.step_index,
            render_register_read_role(event.role),
            event.reg,
            event.value,
        ));
    }
    register_reads.push(']');

    let mut register_writes = String::from("[");
    for (idx, event) in stage2.register_writes.iter().enumerate() {
        if idx > 0 {
            register_writes.push_str(", ");
        }
        register_writes.push_str(&format!(
            "{{ stepIndex := {}, reg := {}, previous := {}, next := {} }}",
            event.step_index,
            event.reg,
            event.previous,
            event.next,
        ));
    }
    register_writes.push(']');

    let mut ram_events = String::from("[");
    for (idx, event) in stage2.ram_events.iter().enumerate() {
        if idx > 0 {
            ram_events.push_str(", ");
        }
        ram_events.push_str(&format!(
            "{{ stepIndex := {}, kind := {}, addr := {}, previous := {}, next := {} }}",
            event.step_index,
            render_ram_access_kind(event.kind),
            event.addr,
            event.previous,
            event.next,
        ));
    }
    ram_events.push(']');

    let mut twist_links = String::from("[");
    for (idx, event) in stage2.twist_links.iter().enumerate() {
        if idx > 0 {
            twist_links.push_str(", ");
        }
        twist_links.push_str(&format!(
            "{{ stepIndex := {}, family := {}, routedWriteValue := {}, routedMemoryBefore := {}, routedMemoryAfter := {} }}",
            event.step_index,
            render_family_tag(event.family),
            render_option_nat(event.routed_write_value),
            render_option_nat(event.routed_memory_before),
            render_option_nat(event.routed_memory_after),
        ));
    }
    twist_links.push(']');

    format!(
        "{{\n  registerReads := {}\n  , registerWrites := {}\n  , ramEvents := {}\n  , twistLinks := {}\n}}",
        register_reads, register_writes, ram_events, twist_links
    )
}

fn render_stage3_summary(stage3: &neo_fold_next::rv64im::stage3::Stage3Summary) -> String {
    let mut continuity = String::from("[");
    for (idx, event) in stage3.continuity.iter().enumerate() {
        if idx > 0 {
            continuity.push_str(", ");
        }
        continuity.push_str(&format!(
            "{{ stepIndex := {}, pc := {}, nextPc := {}, successorPc := {}, finalStep := {}, continuityHolds := {} }}",
            event.step_index,
            event.pc,
            event.next_pc,
            render_option_nat(event.successor_pc),
            if event.final_step { "true" } else { "false" },
            if event.continuity_holds { "true" } else { "false" },
        ));
    }
    continuity.push(']');
    format!(
        "{{\n  continuity := {}\n  , halted := {}\n}}",
        continuity,
        if stage3.halted { "true" } else { "false" }
    )
}

fn render_cursor_snapshot(snapshot: &TranscriptCursorSnapshot) -> String {
    format!(
        "{{ stateWords := {}, absorbed := {} }}",
        render_u64_list(&snapshot.state_words),
        snapshot.absorbed
    )
}

fn render_transcript_event(event: &TranscriptEventRecord) -> String {
    format!(
        "{{\n  kind := {}\n  , label := {}\n  , message := {}\n  , u64s := {}\n  , cursorBefore := {}\n  , cursorAfter := {}\n  , challengeOutput := {}\n  , digestOutput := {}\n}}",
        render_transcript_event_kind(event.kind),
        render_u8_list(&event.label),
        render_u8_list(&event.message),
        render_u64_list(&event.u64s),
        render_cursor_snapshot(&event.cursor_before),
        render_cursor_snapshot(&event.cursor_after),
        match event.challenge_output {
            Some(value) => format!("(some {value})"),
            None => "none".into(),
        },
        render_option_bytes(event.digest_output.as_ref().map(|digest| digest.as_slice())),
    )
}

fn render_transcript(record: &TranscriptRecord) -> String {
    let mut events = String::from("[");
    for (idx, event) in record.events.iter().enumerate() {
        if idx > 0 {
            events.push_str(", ");
        }
        events.push_str(&render_transcript_event(event));
    }
    events.push(']');
    format!(
        "{{\n  appLabel := {}\n  , events := {}\n}}",
        render_u8_list(&record.app_label),
        events
    )
}

fn render_kernel_summary(summary: &Rv64imKernelSummary) -> String {
    format!(
        "{{\n  root0Digest := {}\n  , stage1Digest := {}\n  , stage2Digest := {}\n  , stage3Digest := {}\n  , executionDigest := {}\n  , finalStateDigest := {}\n  , stage1Mix := {}\n  , stage2RegMix := {}\n  , stage2RamMix := {}\n  , stage3ContinuityMix := {}\n  , kernelFinalMix := {}\n  , transcriptFinalDigest := {}\n  , finalPc := {}\n  , finalRegisters := {}\n  , finalMemory := {}\n  , halted := {}\n}}",
        render_u8_list(&summary.root0_digest),
        render_u8_list(&summary.stage1_digest),
        render_u8_list(&summary.stage2_digest),
        render_u8_list(&summary.stage3_digest),
        render_u8_list(&summary.execution_digest),
        render_u8_list(&summary.final_state_digest),
        summary.stage1_mix,
        summary.stage2_reg_mix,
        summary.stage2_ram_mix,
        summary.stage3_continuity_mix,
        summary.kernel_final_mix,
        render_u8_list(&summary.transcript_final_digest),
        summary.final_pc,
        render_u64_list(&summary.final_registers),
        render_memory_words(&summary.final_memory),
        if summary.halted { "true" } else { "false" },
    )
}

fn render_derived_case(case: &Rv64imParityDerivedCase) -> String {
    let mut rows = String::from("[");
    for (idx, row) in case.execution_rows.iter().enumerate() {
        if idx > 0 {
            rows.push_str(", ");
        }
        rows.push_str(&render_expanded_row(row));
    }
    rows.push(']');

    format!(
        "{{\n  manifest := {}\n  , executionRows := {}\n  , stage1 := {}\n  , stage2 := {}\n  , stage3 := {}\n  , transcript := {}\n  , kernel := {}\n}}",
        render_manifest(&case.manifest),
        rows,
        render_stage1_summary(&case.stage1),
        render_stage2_summary(&case.stage2),
        render_stage3_summary(&case.stage3),
        render_transcript(&case.transcript),
        render_kernel_summary(&case.kernel),
    )
}

fn render_source_module(case: &Rv64imParitySourceCase) -> String {
    format!(
        "import Nightstream.Rv64IM.Generated.ParityTypes\n\nnamespace Nightstream.Rv64IM.Generated.Cases.Case_{}\n\nopen Nightstream.Rv64IM.Generated\n\ndef sourceCase : ParitySourceCase :=\n  {}\n\nend Nightstream.Rv64IM.Generated.Cases.Case_{}\n",
        lean_ident_fragment(&case.manifest.name),
        render_source_case(case),
        lean_ident_fragment(&case.manifest.name),
    )
}

fn render_derived_module(case: &Rv64imParityDerivedCase) -> String {
    format!(
        "import Nightstream.Rv64IM.Generated.ParityTypes\n\nnamespace Nightstream.Rv64IM.Generated.Cases.Case_{}\n\nopen Nightstream.Rv64IM.Generated\n\ndef derivedCase : ParityDerivedCase :=\n  {}\n\nend Nightstream.Rv64IM.Generated.Cases.Case_{}\n",
        lean_ident_fragment(&case.manifest.name),
        render_derived_case(case),
        lean_ident_fragment(&case.manifest.name),
    )
}

fn render_index_module(module_name: &str, cases: &[(Rv64imParitySourceCase, Rv64imParityDerivedCase)]) -> String {
    let mut imports = String::new();
    let mut sources = String::from("[");
    let mut derived = String::from("[");
    let mut parity_cases = String::from("[");

    for (idx, (source, _)) in cases.iter().enumerate() {
        let ident = lean_ident_fragment(&source.manifest.name);
        imports.push_str(&format!(
            "import Nightstream.Rv64IM.Generated.Cases.Case_{ident}.Source\nimport Nightstream.Rv64IM.Generated.Cases.Case_{ident}.Derived\n"
        ));
        if idx > 0 {
            sources.push_str(", ");
            derived.push_str(", ");
            parity_cases.push_str(", ");
        }
        sources.push_str(&format!("Nightstream.Rv64IM.Generated.Cases.Case_{ident}.sourceCase"));
        derived.push_str(&format!("Nightstream.Rv64IM.Generated.Cases.Case_{ident}.derivedCase"));
        parity_cases.push_str(&format!(
            "(Nightstream.Rv64IM.Generated.Cases.Case_{ident}.sourceCase, Nightstream.Rv64IM.Generated.Cases.Case_{ident}.derivedCase)"
        ));
    }

    sources.push(']');
    derived.push(']');
    parity_cases.push(']');

    format!(
        "{imports}\nnamespace Nightstream.Rv64IM.Generated.Index.{module_name}\n\nopen Nightstream.Rv64IM.Generated\n\ndef sourceCases : List ParitySourceCase :=\n  {sources}\n\ndef derivedCases : List ParityDerivedCase :=\n  {derived}\n\ndef parityCases : List (ParitySourceCase × ParityDerivedCase) :=\n  {parity_cases}\n\nend Nightstream.Rv64IM.Generated.Index.{module_name}\n"
    )
}

fn render_corpus_module() -> String {
    "import Nightstream.Rv64IM.Generated.Index.AllCases\nimport Nightstream.Rv64IM.Generated.Index.AlignedMemory\nimport Nightstream.Rv64IM.Generated.Index.ControlFlow\nimport Nightstream.Rv64IM.Generated.Index.NativeAlu\n\nnamespace Nightstream.Rv64IM.Generated\n\ndef nativeAluParityCases : List (ParitySourceCase × ParityDerivedCase) :=\n  Nightstream.Rv64IM.Generated.Index.NativeAlu.parityCases\n\ndef alignedMemoryParityCases : List (ParitySourceCase × ParityDerivedCase) :=\n  Nightstream.Rv64IM.Generated.Index.AlignedMemory.parityCases\n\ndef controlFlowParityCases : List (ParitySourceCase × ParityDerivedCase) :=\n  Nightstream.Rv64IM.Generated.Index.ControlFlow.parityCases\n\ndef parityCases : List (ParitySourceCase × ParityDerivedCase) :=\n  Nightstream.Rv64IM.Generated.Index.AllCases.parityCases\n\nend Nightstream.Rv64IM.Generated\n".into()
}

fn write_file(path: &Path, contents: String) {
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent).expect("create output directory");
    }
    fs::write(path, contents).expect("write generated file");
}

fn reset_generated_dirs() {
    for path in [generated_dir().join("Cases"), generated_dir().join("Index")] {
        if path.exists() {
            fs::remove_dir_all(&path).expect("remove stale generated directory");
        }
    }
}

fn main() {
    let cases = build_all_parity_cases().expect("build RV64IM parity cases");
    reset_generated_dirs();

    for (source, derived) in &cases {
        let case_path = case_dir(&source.manifest.name);
        write_file(&case_path.join("Source.lean"), render_source_module(source));
        write_file(&case_path.join("Derived.lean"), render_derived_module(derived));
    }

    let native_alu_cases = cases
        .iter()
        .filter(|(source, _)| {
            source
                .manifest
                .family_tags
                .contains(&neo_fold_next::rv64im::tables::Rv64FamilyTag::NativeAlu)
        })
        .cloned()
        .collect::<Vec<_>>();
    let aligned_memory_cases = cases
        .iter()
        .filter(|(source, _)| {
            source
                .manifest
                .family_tags
                .contains(&neo_fold_next::rv64im::tables::Rv64FamilyTag::AlignedMemory)
        })
        .cloned()
        .collect::<Vec<_>>();
    let control_flow_cases = cases
        .iter()
        .filter(|(source, _)| {
            source
                .manifest
                .family_tags
                .contains(&neo_fold_next::rv64im::tables::Rv64FamilyTag::ControlFlow)
        })
        .cloned()
        .collect::<Vec<_>>();

    write_file(
        &generated_dir().join("Index").join("NativeAlu.lean"),
        render_index_module(family_module_name(neo_fold_next::rv64im::tables::Rv64FamilyTag::NativeAlu), &native_alu_cases),
    );
    write_file(
        &generated_dir().join("Index").join("AlignedMemory.lean"),
        render_index_module(
            family_module_name(neo_fold_next::rv64im::tables::Rv64FamilyTag::AlignedMemory),
            &aligned_memory_cases,
        ),
    );
    write_file(
        &generated_dir().join("Index").join("ControlFlow.lean"),
        render_index_module(
            family_module_name(neo_fold_next::rv64im::tables::Rv64FamilyTag::ControlFlow),
            &control_flow_cases,
        ),
    );
    write_file(
        &generated_dir().join("Index").join("AllCases.lean"),
        render_index_module("AllCases", &cases),
    );
    write_file(
        &generated_dir().join("ImportedParityCorpus.lean"),
        render_corpus_module(),
    );

    println!(
        "wrote RV64IM parity artifacts for {} cases to {}",
        cases.len(),
        generated_dir().display()
    );
}
