//! Convenience runner for RV32 trace-wiring CCS (time-in-rows).
//!
//! This is an ergonomic wrapper around the existing trace wiring artifacts:
//! - `neo_memory::riscv::trace` for execution-table extraction, and
//! - `neo_memory::riscv::ccs::trace` for fixed-width trace wiring CCS.
//!
//! The runner intentionally targets the current Tier 2.1 scope:
//! - fixed-width trace-wiring CCS steps with PROG/REG/RAM sidecar instances,
//! - no decode/semantics sidecar proofs in this wrapper yet.

#![allow(non_snake_case)]

use std::collections::{HashMap, HashSet};
use std::time::Duration;

use crate::output_binding::OutputBindingConfig;
use crate::pi_ccs::FoldingMode;
use crate::session::FoldingSession;
use crate::shard::{ShardProof, StepLinkingConfig};
use crate::PiCcsError;
use neo_ajtai::AjtaiSModule;
use neo_ccs::CcsStructure;
use neo_math::{F, K};
use neo_memory::output_check::ProgramIO;
use neo_memory::plain::PlainMemLayout;
use neo_memory::riscv::ccs::{build_rv32_trace_boundary_ccs, Rv32TraceCcsLayout, TraceShoutBusSpec};
use neo_memory::riscv::exec_table::{Rv32ExecRow, Rv32ExecTable};
use neo_memory::riscv::lookups::{
    decode_program, RiscvCpu, RiscvInstruction, RiscvMemory, RiscvOpcode, RiscvShoutTables, PROG_ID, RAM_ID, REG_ID,
};
use neo_memory::riscv::packed::{rv32_packed_d, rv32_packed_rollout_opcode};
use neo_memory::riscv::rom_init::prog_rom_layout_and_init_words;
use neo_memory::{LutTableSpec, MemInit, R1csCpu};
use neo_params::NeoParams;
use neo_vm_trace::{StepTrace, Twist as _, TwistOpKind};
use p3_field::PrimeCharacteristicRing;

mod chunking;
mod lookup_injection;
mod run;
use chunking::*;
use lookup_injection::*;
pub use run::Rv32TraceWiringRun;

#[cfg(target_arch = "wasm32")]
use js_sys::Date;
#[cfg(not(target_arch = "wasm32"))]
use std::time::Instant;

#[cfg(target_arch = "wasm32")]
type TimePoint = f64;
#[cfg(not(target_arch = "wasm32"))]
type TimePoint = Instant;

#[inline]
fn time_now() -> TimePoint {
    #[cfg(target_arch = "wasm32")]
    {
        Date::now()
    }
    #[cfg(not(target_arch = "wasm32"))]
    {
        Instant::now()
    }
}

#[inline]
fn elapsed_duration(start: TimePoint) -> Duration {
    #[cfg(target_arch = "wasm32")]
    {
        let elapsed_ms = Date::now() - start;
        Duration::from_secs_f64(elapsed_ms / 1_000.0)
    }
    #[cfg(not(target_arch = "wasm32"))]
    {
        start.elapsed()
    }
}

/// Hard instruction cap for trace-wiring mode (Option C).
const DEFAULT_RV32_TRACE_MAX_STEPS: usize = 1 << 20;

/// Default per-step trace rows for trace-mode IVC.
///
/// The full trace is split into fixed-size chunks of this row count (except when the whole
/// trace is smaller), and those chunks are folded with step-linking.
const DEFAULT_RV32_TRACE_CHUNK_ROWS: usize = 1 << 16;

/// - proves one or more trace-wiring CCS steps (IVC),
/// - verifies the resulting shard proof.
#[derive(Clone, Copy, Debug, Default)]
enum OutputTarget {
    #[default]
    Ram,
    Reg,
}

#[derive(Clone, Copy, Debug, Default)]
pub struct Rv32TraceProvePhaseDurations {
    pub setup: Duration,
    pub chunk_build_commit: Duration,
    pub fold_and_prove: Duration,
}

#[derive(Clone, Debug)]
pub struct Rv32TraceWiring {
    program_base: u64,
    program_bytes: Vec<u8>,
    xlen: usize,
    max_steps: Option<usize>,
    min_trace_len: usize,
    chunk_rows: Option<usize>,
    shared_cpu_bus: bool,
    mode: FoldingMode,
    ram_init: HashMap<u64, u64>,
    reg_init: HashMap<u64, u64>,
    output_claims: ProgramIO<F>,
    output_target: OutputTarget,
    shout_ops: Option<HashSet<RiscvOpcode>>,
    extra_lut_table_specs: HashMap<u32, LutTableSpec>,
    extra_shout_bus_specs: Vec<TraceShoutBusSpec>,
}

impl Rv32TraceWiring {
    /// Create a trace runner from ROM bytes.
    pub fn from_rom(program_base: u64, program_bytes: &[u8]) -> Self {
        Self {
            program_base,
            program_bytes: program_bytes.to_vec(),
            xlen: 32,
            max_steps: None,
            min_trace_len: 4,
            chunk_rows: None,
            shared_cpu_bus: true,
            mode: FoldingMode::Optimized,
            ram_init: HashMap::new(),
            reg_init: HashMap::new(),
            output_claims: ProgramIO::new(),
            output_target: OutputTarget::Ram,
            shout_ops: None,
            extra_lut_table_specs: HashMap::new(),
            extra_shout_bus_specs: Vec::new(),
        }
    }

    pub fn xlen(mut self, xlen: usize) -> Self {
        self.xlen = xlen;
        self
    }

    /// Lower-bound for execution-table length.
    ///
    /// Final `t` is `max(trace_len, min_trace_len)`.
    pub fn min_trace_len(mut self, min_trace_len: usize) -> Self {
        self.min_trace_len = min_trace_len.max(1);
        self
    }

    /// Fixed rows per trace step for IVC folding.
    ///
    /// The trace is split into fixed-size chunks, each chunk is proven with the same step CCS,
    /// and step-linking enforces cross-shard continuity (`pc_final -> pc0`,
    /// `halted_out -> halted_in`). The runner canonicalizes this to the next power-of-two.
    pub fn chunk_rows(mut self, chunk_rows: usize) -> Self {
        self.chunk_rows = Some(chunk_rows);
        self
    }

    /// Toggle shared-CPU-bus trace proving mode.
    ///
    /// `true` is the intended production default; `false` keeps the legacy no-shared-bus path.
    pub fn shared_cpu_bus(mut self, enabled: bool) -> Self {
        self.shared_cpu_bus = enabled;
        self
    }

    /// Bound executed instruction count.
    pub fn max_steps(mut self, max_steps: usize) -> Self {
        self.max_steps = Some(max_steps);
        self
    }

    pub fn mode(mut self, mode: FoldingMode) -> Self {
        self.mode = mode;
        self
    }

    /// Initialize RAM byte-addressed word cell to a u32 value.
    pub fn ram_init_u32(mut self, addr: u64, value: u32) -> Self {
        self.ram_init.insert(addr, value as u64);
        self
    }

    /// Initialize register `reg` (x0..x31) to a u32 value.
    pub fn reg_init_u32(mut self, reg: u64, value: u32) -> Self {
        self.reg_init.insert(reg, value as u64);
        self
    }

    pub fn output(mut self, output_addr: u64, expected_output: F) -> Self {
        self.output_claims = ProgramIO::new().with_output(output_addr, expected_output);
        self.output_target = OutputTarget::Ram;
        self
    }

    pub fn output_claim(mut self, addr: u64, value: F) -> Self {
        if !matches!(self.output_target, OutputTarget::Ram) {
            self.output_target = OutputTarget::Ram;
            self.output_claims = ProgramIO::new();
        }
        self.output_claims = self.output_claims.with_output(addr, value);
        self
    }

    pub fn reg_output(mut self, reg: u64, expected: F) -> Self {
        self.output_claims = ProgramIO::new().with_output(reg, expected);
        self.output_target = OutputTarget::Reg;
        self
    }

    pub fn reg_output_claim(mut self, reg: u64, expected: F) -> Self {
        if !matches!(self.output_target, OutputTarget::Reg) {
            self.output_target = OutputTarget::Reg;
            self.output_claims = ProgramIO::new();
        }
        self.output_claims = self.output_claims.with_output(reg, expected);
        self
    }

    /// Use the default program-inferred minimal shout set.
    pub fn shout_auto_minimal(mut self) -> Self {
        self.shout_ops = None;
        self
    }

    /// Optional override for shout tables.
    ///
    /// The override must be a superset of the program-inferred required shout set.
    pub fn shout_ops(mut self, ops: impl IntoIterator<Item = RiscvOpcode>) -> Self {
        self.shout_ops = Some(ops.into_iter().collect());
        self
    }

    /// Add an extra implicit lookup-table spec by `table_id`.
    ///
    /// The id must not collide with inferred opcode-table ids.
    pub fn extra_lut_table_spec(mut self, table_id: u32, spec: LutTableSpec) -> Self {
        self.extra_lut_table_specs.insert(table_id, spec);
        self
    }

    /// Optional extra Shout family geometry for trace shared-bus mode.
    ///
    /// Each spec adds/overrides a `table_id -> ell_addr` mapping used to size shout lanes.
    pub fn extra_shout_bus_specs(mut self, specs: impl IntoIterator<Item = TraceShoutBusSpec>) -> Self {
        self.extra_shout_bus_specs = specs.into_iter().collect();
        self
    }

    pub fn prove(self) -> Result<Rv32TraceWiringRun, PiCcsError> {
        if self.xlen != 32 {
            return Err(PiCcsError::InvalidInput(format!(
                "RV32 trace wiring runner requires xlen == 32 (got {})",
                self.xlen
            )));
        }
        if self.program_base != 0 {
            return Err(PiCcsError::InvalidInput(
                "RV32 trace wiring runner requires program_base == 0".into(),
            ));
        }
        if self.program_bytes.is_empty() {
            return Err(PiCcsError::InvalidInput("program_bytes must be non-empty".into()));
        }
        if self.min_trace_len > DEFAULT_RV32_TRACE_MAX_STEPS {
            return Err(PiCcsError::InvalidInput(format!(
                "min_trace_len={} exceeds trace-mode hard cap {}. Increase chunk_rows and prove in chunks for longer executions.",
                self.min_trace_len, DEFAULT_RV32_TRACE_MAX_STEPS
            )));
        }
        if self.program_bytes.len() % 4 != 0 {
            return Err(PiCcsError::InvalidInput(
                "program_bytes must be 4-byte aligned (RVC is not supported)".into(),
            ));
        }
        for (i, chunk) in self.program_bytes.chunks_exact(4).enumerate() {
            let first_half = u16::from_le_bytes([chunk[0], chunk[1]]);
            if (first_half & 0b11) != 0b11 {
                return Err(PiCcsError::InvalidInput(format!(
                    "compressed instruction encoding (RVC) is not supported at word index {i}"
                )));
            }
        }

        let program = decode_program(&self.program_bytes)
            .map_err(|e| PiCcsError::InvalidInput(format!("decode_program failed: {e}")))?;
        let using_default_max_steps = self.max_steps.is_none();
        let max_steps = match self.max_steps {
            Some(n) => {
                if n == 0 {
                    return Err(PiCcsError::InvalidInput("max_steps must be non-zero".into()));
                }
                if n > DEFAULT_RV32_TRACE_MAX_STEPS {
                    return Err(PiCcsError::InvalidInput(format!(
                        "max_steps={} exceeds trace-mode hard cap {}. Increase chunk_rows and prove in chunks for longer executions.",
                        n, DEFAULT_RV32_TRACE_MAX_STEPS
                    )));
                }
                n
            }
            None => DEFAULT_RV32_TRACE_MAX_STEPS,
        };
        if !self.shared_cpu_bus {
            return Err(PiCcsError::InvalidInput(
                "RV32 trace wiring no-shared fallback is removed; Phase 2 decode lookup requires shared_cpu_bus=true"
                    .into(),
            ));
        }
        let ram_init_map = self.ram_init.clone();
        let reg_init_map = self.reg_init.clone();
        let output_claims = self.output_claims.clone();
        let output_target = self.output_target;
        let (prog_layout, prog_init_words) =
            prog_rom_layout_and_init_words::<F>(PROG_ID, /*base_addr=*/ 0, &self.program_bytes)
                .map_err(|e| PiCcsError::InvalidInput(format!("prog_rom_layout_and_init_words failed: {e}")))?;

        let mut vm = RiscvCpu::new(self.xlen);
        vm.load_program(/*base=*/ 0, program.clone());

        let mut twist =
            RiscvMemory::with_program_in_twist(self.xlen, PROG_ID, /*base_addr=*/ 0, &self.program_bytes);
        for (&addr, &value) in &ram_init_map {
            twist.store(RAM_ID, addr, value as u32 as u64);
        }
        for (&reg, &value) in &reg_init_map {
            if reg >= 32 {
                return Err(PiCcsError::InvalidInput(format!(
                    "reg_init_u32: register index out of range: reg={reg} (expected 0..32)"
                )));
            }
            if reg == 0 && value != 0 {
                return Err(PiCcsError::InvalidInput(
                    "reg_init_u32: x0 must be 0 (non-zero init is forbidden)".into(),
                ));
            }
            twist.store(REG_ID, reg, value as u32 as u64);
        }
        let shout = RiscvShoutTables::new(self.xlen);

        let mut trace = neo_vm_trace::trace_program(vm, twist, shout, max_steps)
            .map_err(|e| PiCcsError::InvalidInput(format!("trace_program failed: {e}")))?;

        if using_default_max_steps && !trace.did_halt() {
            return Err(PiCcsError::InvalidInput(format!(
                "RV32 execution did not halt within max_steps={max_steps}; call .max_steps(...) to raise the limit or ensure the guest halts"
            )));
        }

        let decode_selector_specs = if self.shared_cpu_bus {
            decode_selector_specs_for_prog_layout(&prog_layout)?
        } else {
            Vec::new()
        };
        let decode_selector_tables = if self.shared_cpu_bus {
            build_rv32_decode_selector_lookup_tables(&prog_layout, &prog_init_words)
        } else {
            HashMap::new()
        };
        if self.shared_cpu_bus {
            inject_rv32_decode_selector_lookup_events_into_trace(&mut trace, &prog_layout, &prog_init_words)?;
        }

        let target_len = trace.steps.len().max(self.min_trace_len);
        if target_len > DEFAULT_RV32_TRACE_MAX_STEPS {
            return Err(PiCcsError::InvalidInput(format!(
                "trace length {} exceeds trace-mode hard cap {}. Increase chunk_rows and prove in chunks for longer executions.",
                target_len, DEFAULT_RV32_TRACE_MAX_STEPS
            )));
        }
        let exec = Rv32ExecTable::from_trace_padded(&trace, target_len)
            .map_err(|e| PiCcsError::InvalidInput(format!("Rv32ExecTable::from_trace_padded failed: {e}")))?;
        exec.validate_cycle_chain()
            .map_err(|e| PiCcsError::InvalidInput(format!("validate_cycle_chain failed: {e}")))?;
        exec.validate_pc_chain()
            .map_err(|e| PiCcsError::InvalidInput(format!("validate_pc_chain failed: {e}")))?;
        exec.validate_halted_tail()
            .map_err(|e| PiCcsError::InvalidInput(format!("validate_halted_tail failed: {e}")))?;
        exec.validate_inactive_rows_are_empty()
            .map_err(|e| PiCcsError::InvalidInput(format!("validate_inactive_rows_are_empty failed: {e}")))?;
        let auto_chunk_rows = exec
            .rows
            .len()
            .max(1)
            .min(DEFAULT_RV32_TRACE_CHUNK_ROWS)
            .next_power_of_two();
        let requested_chunk_rows = self.chunk_rows.unwrap_or(auto_chunk_rows);
        if requested_chunk_rows == 0 {
            return Err(PiCcsError::InvalidInput("trace chunk_rows must be non-zero".into()));
        }
        let step_rows = requested_chunk_rows.next_power_of_two();
        let exec_chunks = split_exec_into_fixed_chunks(&exec, step_rows)?;

        let layout = Rv32TraceCcsLayout::new(step_rows)
            .map_err(|e| PiCcsError::InvalidInput(format!("Rv32TraceCcsLayout::new failed: {e}")))?;

        let prove_start = time_now();
        let setup_start = prove_start;

        let mut max_ram_addr = max_ram_addr_from_exec(&exec).unwrap_or(0);
        if let Some(max_init_addr) = ram_init_map.keys().copied().max() {
            max_ram_addr = max_ram_addr.max(max_init_addr);
        }
        let wants_ram_output = matches!(output_target, OutputTarget::Ram) && !output_claims.is_empty();
        if matches!(output_target, OutputTarget::Ram) {
            if let Some(max_claim_addr) = output_claims.claimed_addresses().max() {
                max_ram_addr = max_ram_addr.max(max_claim_addr);
            }
        }
        let ram_d = required_bits_for_max_addr(max_ram_addr).max(2);
        let ram_k = 1usize
            .checked_shl(ram_d as u32)
            .ok_or_else(|| PiCcsError::InvalidInput(format!("RAM address width too large: d={ram_d}")))?;
        // Track A used-set derivation must be deterministic from public inputs/config.
        // Do not derive RAM inclusion from runtime witness/events.
        let include_ram_sidecar =
            program_requires_ram_sidecar(&program) || !ram_init_map.is_empty() || wants_ram_output;

        let mut mem_layouts: HashMap<u32, PlainMemLayout> = HashMap::from([
            (
                REG_ID.0,
                PlainMemLayout {
                    k: 32,
                    d: 5,
                    n_side: 2,
                    lanes: 2,
                },
            ),
            (PROG_ID.0, prog_layout.clone()),
        ]);
        if include_ram_sidecar {
            mem_layouts.insert(
                RAM_ID.0,
                PlainMemLayout {
                    k: ram_k,
                    d: ram_d,
                    n_side: 2,
                    lanes: 1,
                },
            );
        }

        let inferred_shout_ops = infer_required_trace_shout_opcodes(&program);
        let shout_ops = match &self.shout_ops {
            Some(override_ops) => {
                let missing: HashSet<RiscvOpcode> = inferred_shout_ops
                    .difference(override_ops)
                    .copied()
                    .collect();
                if !missing.is_empty() {
                    let mut missing_names: Vec<String> = missing.into_iter().map(|op| format!("{op:?}")).collect();
                    missing_names.sort_unstable();
                    return Err(PiCcsError::InvalidInput(format!(
                        "trace shout_ops override must be a superset of required opcodes; missing [{}]",
                        missing_names.join(", ")
                    )));
                }
                override_ops.clone()
            }
            None => inferred_shout_ops,
        };
        let mut table_specs = rv32_trace_table_specs(&shout_ops)?;
        for (&table_id, spec) in &self.extra_lut_table_specs {
            if table_specs.contains_key(&table_id) {
                return Err(PiCcsError::InvalidInput(format!(
                    "extra_lut_table_spec collides with existing table_id={table_id}"
                )));
            }
            table_specs.insert(table_id, spec.clone());
        }
        let mut base_shout_table_ids: Vec<u32> = table_specs
            .iter()
            .filter_map(|(&table_id, spec)| match spec {
                LutTableSpec::RiscvOpcodePacked { .. } | LutTableSpec::RiscvOpcodeEventTablePacked { .. } => None,
                _ => Some(table_id),
            })
            .collect();
        base_shout_table_ids.sort_unstable();
        let mut all_extra_shout_specs = self.extra_shout_bus_specs.clone();
        for (&table_id, spec) in &table_specs {
            match spec {
                LutTableSpec::RiscvOpcodePacked { opcode, xlen } => {
                    if *xlen != 32 {
                        return Err(PiCcsError::InvalidInput(format!(
                            "RiscvOpcodePacked requires xlen=32 in RV32 trace mode (table_id={table_id}, xlen={xlen})"
                        )));
                    }
                    all_extra_shout_specs.push(TraceShoutBusSpec {
                        table_id,
                        ell_addr: rv32_packed_d(*opcode)?,
                        n_vals: 1usize,
                    });
                }
                LutTableSpec::RiscvOpcodeEventTablePacked { .. } => {
                    return Err(PiCcsError::InvalidInput(
                        "RiscvOpcodeEventTablePacked is not supported in RV32 trace shared-bus mode".into(),
                    ));
                }
                _ => {}
            }
        }
        for spec in &decode_selector_specs {
            if let Some(existing) = all_extra_shout_specs
                .iter()
                .find(|s| s.table_id == spec.table_id)
            {
                if existing.ell_addr != spec.ell_addr || existing.n_vals != spec.n_vals {
                    return Err(PiCcsError::InvalidInput(format!(
                        "decode selector shout spec conflicts for table_id={} (existing ell_addr={}, n_vals={} vs required ell_addr={}, n_vals={})",
                        spec.table_id, existing.ell_addr, existing.n_vals, spec.ell_addr, spec.n_vals
                    )));
                }
            } else {
                all_extra_shout_specs.push(*spec);
            }
        }
        for spec in &all_extra_shout_specs {
            if !table_specs.contains_key(&spec.table_id) && !decode_selector_tables.contains_key(&spec.table_id) {
                return Err(PiCcsError::InvalidInput(format!(
                    "extra_shout_bus_specs includes table_id={} without a table spec/table content",
                    spec.table_id
                )));
            }
        }

        // Keep the main CCS at trace width. Sidecar lanes are folded with sidecar-local CCS views.

        let mut ccs = build_rv32_trace_boundary_ccs(layout.t)
            .map_err(|e| PiCcsError::InvalidInput(format!("build_rv32_trace_boundary_ccs failed: {e}")))?;

        let mut session = FoldingSession::<AjtaiSModule>::new_ajtai(self.mode.clone(), &ccs)?;
        session.set_step_linking(StepLinkingConfig::new(vec![(layout.pc_final, layout.pc0)]));

        let mut prog_init_pairs: Vec<(u64, F)> = prog_init_words
            .into_iter()
            .filter_map(|((mem_id, addr), value)| (mem_id == PROG_ID.0 && value != F::ZERO).then_some((addr, value)))
            .collect();
        prog_init_pairs.sort_by_key(|(addr, _)| *addr);
        let prog_mem_init = if prog_init_pairs.is_empty() {
            MemInit::Zero
        } else {
            MemInit::Sparse(prog_init_pairs)
        };
        let mut initial_mem: HashMap<(u32, u64), F> = HashMap::new();
        if let MemInit::Sparse(pairs) = &prog_mem_init {
            for &(addr, value) in pairs {
                if value != F::ZERO {
                    initial_mem.insert((PROG_ID.0, addr), value);
                }
            }
        }
        for (&reg, &value) in &reg_init_map {
            let v = F::from_u64(value as u32 as u64);
            if v != F::ZERO {
                initial_mem.insert((REG_ID.0, reg), v);
            }
        }
        for (&addr, &value) in &ram_init_map {
            let v = F::from_u64(value as u32 as u64);
            if v != F::ZERO {
                initial_mem.insert((RAM_ID.0, addr), v);
            }
        }

        let setup_duration = elapsed_duration(setup_start);
        let mut chunk_build_commit_duration = Duration::ZERO;
        let chunk_start = time_now();

        let lut_tables = decode_selector_tables.clone();
        let lut_lanes: HashMap<u32, usize> = HashMap::new();
        let cpu_bus_lut_tables = decode_selector_tables;
        let cpu_bus_table_specs = HashMap::new();

        let cpu = R1csCpu::new(
            ccs.clone(),
            session.params().clone(),
            session.committer().clone(),
            layout.m_in,
            &cpu_bus_lut_tables,
            &cpu_bus_table_specs,
            rv32_trace_chunk_to_boundary_witness(layout.clone()),
        )
        .map_err(|e| PiCcsError::InvalidInput(format!("R1csCpu::new failed: {e}")))?;

        ccs = cpu.ccs.clone();

        session.execute_shard_shared_cpu_bus_from_trace(
            &trace,
            max_steps,
            layout.t,
            &mem_layouts,
            &lut_tables,
            &table_specs,
            &lut_lanes,
            &initial_mem,
            &cpu,
        )?;

        if session.steps_witness().len() != exec_chunks.len() {
            return Err(PiCcsError::ProtocolError(format!(
                "shared trace build drift: step bundle count {} != exec chunk count {}",
                session.steps_witness().len(),
                exec_chunks.len()
            )));
        }
        chunk_build_commit_duration += elapsed_duration(chunk_start);

        let mem_order = session
            .steps_public()
            .first()
            .map(|s| {
                s.mem_insts
                    .iter()
                    .map(|inst| inst.mem_id)
                    .collect::<Vec<_>>()
            })
            .unwrap_or_default();
        let ram_ob_mem_idx = if wants_ram_output {
            Some(
                mem_order
                    .iter()
                    .position(|&id| id == RAM_ID.0)
                    .ok_or_else(|| PiCcsError::ProtocolError("missing RAM mem instance for output binding".into()))?,
            )
        } else {
            None
        };
        let reg_ob_mem_idx = mem_order
            .iter()
            .position(|&id| id == REG_ID.0)
            .ok_or_else(|| PiCcsError::ProtocolError("missing REG mem instance for output binding".into()))?;

        let fold_start = time_now();
        let (proof, output_binding_cfg) = if output_claims.is_empty() {
            (session.fold_and_prove(&ccs)?, None)
        } else {
            let (ob_mem_idx, ob_num_bits, final_memory_state) = match output_target {
                OutputTarget::Ram => (
                    ram_ob_mem_idx.ok_or_else(|| {
                        PiCcsError::ProtocolError("missing RAM mem instance for output binding".into())
                    })?,
                    ram_d,
                    final_ram_state_dense(&exec, &ram_init_map, ram_k)?,
                ),
                OutputTarget::Reg => (reg_ob_mem_idx, 5usize, final_reg_state_dense(&exec, &reg_init_map)?),
            };
            let ob_cfg = OutputBindingConfig::new(ob_num_bits, output_claims).with_mem_idx(ob_mem_idx);
            let proof = session.fold_and_prove_with_output_binding_simple(&ccs, &ob_cfg, &final_memory_state)?;
            (proof, Some(ob_cfg))
        };
        let fold_and_prove_duration = elapsed_duration(fold_start);
        let prove_duration = elapsed_duration(prove_start);
        let prove_phase_durations = Rv32TraceProvePhaseDurations {
            setup: setup_duration,
            chunk_build_commit: chunk_build_commit_duration,
            fold_and_prove: fold_and_prove_duration,
        };

        let mut used_mem_ids: Vec<u32> = mem_layouts.keys().copied().collect();
        used_mem_ids.sort_unstable();
        let mut used_shout_table_ids = base_shout_table_ids.clone();
        for spec in &all_extra_shout_specs {
            if !used_shout_table_ids.contains(&spec.table_id) {
                used_shout_table_ids.push(spec.table_id);
            }
        }
        used_shout_table_ids.sort_unstable();

        Ok(Rv32TraceWiringRun {
            session,
            ccs,
            layout,
            exec,
            proof,
            used_mem_ids,
            used_shout_table_ids,
            output_binding_cfg,
            prove_duration,
            prove_phase_durations,
            verify_duration: None,
        })
    }
}
