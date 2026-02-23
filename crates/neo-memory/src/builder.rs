use crate::mem_init::{mem_init_from_state_map, MemInit};
use crate::plain::{LutTable, PlainMemLayout};
use crate::riscv::exec_table::{Rv32ExecRow, Rv32ExecTable};
use crate::riscv::lookups::uninterleave_bits;
use crate::riscv::packed::build_rv32_packed_cols;
use crate::riscv::trace::{Rv32TraceLayout, Rv32TraceWitness};
use crate::witness::{LutInstance, LutTableSpec, LutWitness, MemInstance, MemWitness, StepWitnessBundle, TraceColumnsSidecar};
use neo_vm_trace::TwistOpKind;
use neo_vm_trace::VmTrace;

use neo_ccs::matrix::Mat;
use neo_ccs::relations::{McsInstance, McsWitness};
use p3_field::PrimeCharacteristicRing;
use p3_goldilocks::Goldilocks;
use std::collections::HashMap;
use std::marker::PhantomData;
use std::sync::Arc;

// Placeholder for CPU arithmetization interface
pub trait CpuArithmetization<F, Cmt> {
    type Error: std::fmt::Debug + std::fmt::Display;

    fn build_ccs_chunks(
        &self,
        trace: &VmTrace<u64, u64>,
        chunk_size: usize,
    ) -> Result<Vec<(McsInstance<Cmt, F>, McsWitness<F>)>, Self::Error>;

    fn build_ccs_steps(
        &self,
        trace: &VmTrace<u64, u64>,
    ) -> Result<Vec<(McsInstance<Cmt, F>, McsWitness<F>)>, Self::Error> {
        self.build_ccs_chunks(trace, 1)
    }

    /// Per-table address-sharing group ids for bus layout column sharing.
    ///
    /// Tables with the same group id share `addr_bits` columns in the bus layout.
    /// Default: empty (no sharing). Override in trace mode for column efficiency.
    fn shout_addr_groups(&self) -> &HashMap<u32, u64> {
        static EMPTY: std::sync::LazyLock<HashMap<u32, u64>> = std::sync::LazyLock::new(HashMap::new);
        &EMPTY
    }

    /// Per-table selector-sharing group ids for bus layout column sharing.
    ///
    /// Tables with the same group id share `has_lookup` columns in the bus layout.
    /// Default: empty (no sharing). Override in trace mode for column efficiency.
    fn shout_selector_groups(&self) -> &HashMap<u32, u64> {
        static EMPTY: std::sync::LazyLock<HashMap<u32, u64>> = std::sync::LazyLock::new(HashMap::new);
        &EMPTY
    }
}

#[derive(Debug)]
pub enum ShardBuildError {
    VmError(String),
    CcsError(String),
    InvalidChunkSize(String),
    InvalidInit(String),
    MissingLayout(String),
    MissingTable(String),
}

/// Auxiliary outputs from `build_shard_witness_shared_cpu_bus_with_aux`.
#[derive(Clone, Debug)]
pub struct ShardWitnessAux {
    /// Original (unpadded) VM trace length.
    pub original_len: usize,
    /// Whether the VM halted before reaching `max_steps`.
    pub did_halt: bool,
    pub max_steps: usize,
    pub chunk_size: usize,
    /// Deterministic ordering of Twist instances used by the builder (and by the shared CPU bus).
    pub mem_ids: Vec<u32>,
    /// Final sparse memory states at the end of the shard: mem_id -> (addr -> value), with zero cells omitted.
    pub final_mem_states: HashMap<u32, HashMap<u64, Goldilocks>>,
}

fn ell_from_pow2_n_side(n_side: usize) -> Result<usize, ShardBuildError> {
    if n_side == 0 || !n_side.is_power_of_two() {
        return Err(ShardBuildError::InvalidInit(format!(
            "n_side must be a power of two under bit addressing, got {n_side}"
        )));
    }
    Ok(n_side.trailing_zeros() as usize)
}

fn validate_chunk_size(chunk_size: usize) -> Result<(), ShardBuildError> {
    if chunk_size == 0 {
        return Err(ShardBuildError::InvalidChunkSize("chunk_size must be >= 1".into()));
    }
    if !chunk_size.is_power_of_two() {
        return Err(ShardBuildError::InvalidChunkSize(format!(
            "chunk_size must be a power of two (got {chunk_size})"
        )));
    }
    Ok(())
}

fn bundles_only<Cmt, K>(
    out: Result<(Vec<StepWitnessBundle<Cmt, Goldilocks, K>>, ShardWitnessAux), ShardBuildError>,
) -> Result<Vec<StepWitnessBundle<Cmt, Goldilocks, K>>, ShardBuildError> {
    out.map(|(bundles, _aux)| bundles)
}

fn scalar_column_to_mat(col: &[Goldilocks]) -> Mat<Goldilocks> {
    let d = neo_math::D;
    let mut out = Mat::zero(d, col.len(), Goldilocks::ZERO);
    for (j, &v) in col.iter().enumerate() {
        out[(0, j)] = v;
    }
    out
}

fn build_trace_columns_sidecar_from_trace_chunk(
    trace: &VmTrace<u64, u64>,
    chunk_start: usize,
    chunk_end: usize,
    chunk_size: usize,
    _m_in: usize,
) -> Result<(usize, usize, Vec<Vec<Goldilocks>>), ShardBuildError> {
    if chunk_start >= chunk_end {
        return Err(ShardBuildError::InvalidChunkSize(
            "trace sidecar: empty chunk range".into(),
        ));
    }
    let layout = Rv32TraceLayout::new();

    let mut rows = Vec::with_capacity(chunk_size);
    for global_j in chunk_start..chunk_end {
        let step = trace
            .steps
            .get(global_j)
            .ok_or_else(|| ShardBuildError::VmError(format!("missing trace step at global index {global_j}")))?;
        rows.push(Rv32ExecRow::from_step(step).map_err(ShardBuildError::VmError)?);
    }
    let mut cycle = rows
        .last()
        .ok_or_else(|| ShardBuildError::InvalidChunkSize("trace sidecar: empty chunk rows".into()))?
        .cycle;
    let pad_pc = rows.last().expect("rows non-empty").pc_after;
    let pad_halted = rows.last().expect("rows non-empty").halted;
    while rows.len() < chunk_size {
        cycle = cycle
            .checked_add(1)
            .ok_or_else(|| ShardBuildError::InvalidInit("trace sidecar: cycle overflow while padding".into()))?;
        rows.push(Rv32ExecRow::inactive(cycle, pad_pc, pad_halted));
    }

    let exec = Rv32ExecTable { rows };
    let trace_wit = Rv32TraceWitness::from_exec_table(&layout, &exec).map_err(ShardBuildError::VmError)?;
    if trace_wit.t != chunk_size {
        return Err(ShardBuildError::InvalidInit(format!(
            "trace sidecar: witness t mismatch (got {}, expected chunk_size={chunk_size})",
            trace_wit.t
        )));
    }

    if trace_wit.cols.len() != layout.cols {
        return Err(ShardBuildError::InvalidInit(format!(
            "trace sidecar: trace witness column count mismatch (got {}, expected {})",
            trace_wit.cols.len(),
            layout.cols
        )));
    }
    for (col_id, col) in trace_wit.cols.iter().enumerate() {
        if col.len() != chunk_size {
            return Err(ShardBuildError::InvalidInit(format!(
                "trace sidecar: column length mismatch at col_id={col_id} (len={}, expected chunk_size={chunk_size})",
                col.len()
            )));
        }
    }

    Ok((layout.cols, chunk_size, trace_wit.cols))
}

fn pack_key_to_addr_bits(key: u64, d: usize, ell: usize, n_side: usize) -> Result<Vec<Goldilocks>, ShardBuildError> {
    if n_side == 0 || !n_side.is_power_of_two() {
        return Err(ShardBuildError::InvalidInit(format!(
            "Shout sidecar: n_side must be a power-of-two, got {n_side}"
        )));
    }
    if ell == 0 {
        return Err(ShardBuildError::InvalidInit("Shout sidecar: ell must be >= 1".into()));
    }
    let mut out = vec![Goldilocks::ZERO; d * ell];
    let key_usize = usize::try_from(key)
        .map_err(|_| ShardBuildError::InvalidInit(format!("Shout sidecar: key does not fit usize: key={key}")))?;
    if let Some(max_keys) = n_side.checked_pow(d as u32) {
        if key_usize >= max_keys {
            return Err(ShardBuildError::InvalidInit(format!(
                "Shout sidecar: key out of range for (d={d}, n_side={n_side}) (key={key_usize}, max={max_keys})"
            )));
        }
    }
    for dim in 0..d {
        let stride = n_side
            .checked_pow(dim as u32)
            .ok_or_else(|| ShardBuildError::InvalidInit("Shout sidecar: n_side^dim overflow".into()))?;
        let digit = (key_usize / stride) % n_side;
        for b in 0..ell {
            let bit = ((digit >> b) & 1) == 1;
            out[dim * ell + b] = if bit { Goldilocks::ONE } else { Goldilocks::ZERO };
        }
    }
    Ok(out)
}

fn packed_addr_columns_from_event(
    spec: &LutTableSpec,
    key: u64,
    value: u64,
    expected_d: usize,
) -> Result<Vec<Goldilocks>, ShardBuildError> {
    match spec {
        LutTableSpec::RiscvOpcodePacked { opcode, xlen } => {
            if *xlen != 32 {
                return Err(ShardBuildError::InvalidInit(format!(
                    "Shout sidecar: packed RV32 requires xlen=32 (got {xlen})"
                )));
            }
            let (lhs, rhs) = uninterleave_bits(key as u128);
            let packed =
                build_rv32_packed_cols::<Goldilocks>(*opcode, lhs as u32, rhs as u32, value as u32).map_err(|e| {
                    ShardBuildError::InvalidInit(format!("Shout sidecar: packed col synthesis failed: {e}"))
                })?;
            if packed.len() != expected_d {
                return Err(ShardBuildError::InvalidInit(format!(
                    "Shout sidecar: packed col len mismatch (got {}, expected d={expected_d})",
                    packed.len()
                )));
            }
            Ok(packed)
        }
        LutTableSpec::RiscvOpcodeEventTablePacked { .. } => Err(ShardBuildError::InvalidInit(
            "Shout sidecar: event-table packed spec is unsupported in chunked builder".into(),
        )),
        _ => Err(ShardBuildError::InvalidInit(
            "Shout sidecar: packed addr synthesis called for non-packed spec".into(),
        )),
    }
}

fn populate_lut_witness_mats_from_trace_chunk<Cmt>(
    trace: &VmTrace<u64, u64>,
    chunk_start: usize,
    chunk_end: usize,
    chunk_size: usize,
    lut_instances: &mut [(LutInstance<Cmt, Goldilocks>, LutWitness<Goldilocks>)],
) -> Result<(), ShardBuildError> {
    for (inst, wit) in lut_instances.iter_mut() {
        wit.mats.clear();

        // Current Route-A shout oracles consume single-lane layouts.
        if inst.lanes.max(1) != 1 {
            continue;
        }

        let shout_layout = inst.shout_layout();
        let ell_addr = shout_layout.ell_addr;
        let n_cols = shout_layout.expected_len();
        let mut cols: Vec<Vec<Goldilocks>> = vec![vec![Goldilocks::ZERO; chunk_size]; n_cols];

        for (local_j, global_j) in (chunk_start..chunk_end).enumerate() {
            let step = trace
                .steps
                .get(global_j)
                .ok_or_else(|| ShardBuildError::VmError(format!("missing trace step at global index {global_j}")))?;

            let mut matching = step
                .shout_events
                .iter()
                .filter(|ev| ev.shout_id.0 == inst.table_id);
            let Some(ev) = matching.next() else {
                continue;
            };
            if matching.next().is_some() {
                return Err(ShardBuildError::InvalidInit(format!(
                    "Shout sidecar: multiple events for table_id={} at trace step {} (lanes=1 path requires uniqueness)",
                    inst.table_id, global_j
                )));
            }

            cols[shout_layout.has_lookup][local_j] = Goldilocks::ONE;
            cols[shout_layout.val][local_j] = Goldilocks::from_u64(ev.value);

            let addr_vals: Vec<Goldilocks> = match &inst.table_spec {
                Some(LutTableSpec::RiscvOpcodePacked { .. })
                | Some(LutTableSpec::RiscvOpcodeEventTablePacked { .. }) => packed_addr_columns_from_event(
                    inst.table_spec
                        .as_ref()
                        .ok_or_else(|| ShardBuildError::InvalidInit("missing packed table spec".into()))?,
                    ev.key,
                    ev.value,
                    inst.d,
                )?,
                _ => pack_key_to_addr_bits(ev.key, inst.d, inst.ell, inst.n_side)?,
            };

            if addr_vals.len() != ell_addr {
                return Err(ShardBuildError::InvalidInit(format!(
                    "Shout sidecar: addr column len mismatch for table_id={} (got {}, expected ell_addr={ell_addr})",
                    inst.table_id,
                    addr_vals.len(),
                )));
            }
            for (i, &v) in addr_vals.iter().enumerate() {
                cols[i][local_j] = v;
            }
        }

        for col in cols.iter() {
            wit.mats.push(scalar_column_to_mat(col));
        }
    }
    Ok(())
}

fn populate_mem_witness_mats_from_trace_chunk<Cmt>(
    trace: &VmTrace<u64, u64>,
    chunk_start: usize,
    chunk_end: usize,
    chunk_size: usize,
    mem_instances: &mut [(MemInstance<Cmt, Goldilocks>, MemWitness<Goldilocks>)],
) -> Result<(), ShardBuildError> {
    for (inst, wit) in mem_instances.iter_mut() {
        wit.mats.clear();
        let layout = inst.twist_layout();
        let lanes = inst.lanes.max(1);
        if layout.lanes.len() != lanes {
            return Err(ShardBuildError::InvalidInit(format!(
                "Twist sidecar: layout lanes mismatch for mem_id={} (layout={}, inst={lanes})",
                inst.mem_id,
                layout.lanes.len()
            )));
        }

        let n_cols = layout.expected_len();
        let mut cols: Vec<Vec<Goldilocks>> = vec![vec![Goldilocks::ZERO; chunk_size]; n_cols];

        let mut state: HashMap<u64, Goldilocks> = HashMap::new();
        match &inst.init {
            MemInit::Zero => {}
            MemInit::Sparse(pairs) => {
                for &(addr, value) in pairs.iter() {
                    if addr >= inst.k as u64 {
                        return Err(ShardBuildError::InvalidInit(format!(
                            "Twist sidecar: init addr out of range for mem_id={} (addr={}, k={})",
                            inst.mem_id, addr, inst.k
                        )));
                    }
                    if value != Goldilocks::ZERO {
                        state.insert(addr, value);
                    }
                }
            }
        }

        for (local_j, global_j) in (chunk_start..chunk_end).enumerate() {
            let step = trace
                .steps
                .get(global_j)
                .ok_or_else(|| ShardBuildError::VmError(format!("missing trace step at global index {global_j}")))?;
            let mut reads: Vec<Option<(u64, Goldilocks)>> = vec![None; lanes];
            let mut writes: Vec<Option<(u64, Goldilocks)>> = vec![None; lanes];

            for ev in step
                .twist_events
                .iter()
                .filter(|ev| ev.twist_id.0 == inst.mem_id)
            {
                let is_write = matches!(ev.kind, TwistOpKind::Write);
                if is_write
                    && writes
                        .iter()
                        .flatten()
                        .any(|(existing_addr, _)| *existing_addr == ev.addr)
                {
                    return Err(ShardBuildError::InvalidInit(format!(
                        "Twist sidecar: duplicate write addr for mem_id={} at step {} (addr={})",
                        inst.mem_id, global_j, ev.addr
                    )));
                }
                let slots = if is_write { &mut writes } else { &mut reads };
                let lane_idx = if let Some(lane) = ev.lane {
                    let lane_idx = usize::try_from(lane).map_err(|_| {
                        ShardBuildError::InvalidInit(format!(
                            "Twist sidecar: lane does not fit usize for mem_id={} at step {}: lane={lane}",
                            inst.mem_id, global_j
                        ))
                    })?;
                    if lane_idx >= lanes {
                        return Err(ShardBuildError::InvalidInit(format!(
                            "Twist sidecar: lane out of range for mem_id={} at step {} (lane={}, lanes={lanes})",
                            inst.mem_id, global_j, lane_idx
                        )));
                    }
                    lane_idx
                } else {
                    slots.iter().position(|x| x.is_none()).ok_or_else(|| {
                        ShardBuildError::InvalidInit(format!(
                            "Twist sidecar: too many {:?} events for mem_id={} at step {} (lanes={lanes})",
                            ev.kind, inst.mem_id, global_j
                        ))
                    })?
                };

                if slots[lane_idx].is_some() {
                    return Err(ShardBuildError::InvalidInit(format!(
                        "Twist sidecar: duplicate {:?} event for mem_id={} at step {} lane={lane_idx}",
                        ev.kind, inst.mem_id, global_j
                    )));
                }
                slots[lane_idx] = Some((ev.addr, Goldilocks::from_u64(ev.value)));
            }

            let mut writes_to_apply: Vec<(u64, Goldilocks)> = Vec::new();
            for (lane_idx, lane_layout) in layout.lanes.iter().enumerate() {
                if let Some((addr, value)) = reads[lane_idx] {
                    if addr >= inst.k as u64 {
                        return Err(ShardBuildError::InvalidInit(format!(
                            "Twist sidecar: read addr out of range for mem_id={} at step {} (addr={}, k={})",
                            inst.mem_id, global_j, addr, inst.k
                        )));
                    }
                    let addr_bits = pack_key_to_addr_bits(addr, inst.d, inst.ell, inst.n_side)?;
                    if addr_bits.len() != lane_layout.ell_addr {
                        return Err(ShardBuildError::InvalidInit(format!(
                            "Twist sidecar: ra_bits len mismatch for mem_id={} at step {} lane={} (got {}, expected {})",
                            inst.mem_id,
                            global_j,
                            lane_idx,
                            addr_bits.len(),
                            lane_layout.ell_addr
                        )));
                    }
                    cols[lane_layout.has_read][local_j] = Goldilocks::ONE;
                    cols[lane_layout.rv][local_j] = value;
                    for (bit_idx, bit) in addr_bits.into_iter().enumerate() {
                        cols[lane_layout.ra_bits.start + bit_idx][local_j] = bit;
                    }
                }

                if let Some((addr, value)) = writes[lane_idx] {
                    if addr >= inst.k as u64 {
                        return Err(ShardBuildError::InvalidInit(format!(
                            "Twist sidecar: write addr out of range for mem_id={} at step {} (addr={}, k={})",
                            inst.mem_id, global_j, addr, inst.k
                        )));
                    }
                    let addr_bits = pack_key_to_addr_bits(addr, inst.d, inst.ell, inst.n_side)?;
                    if addr_bits.len() != lane_layout.ell_addr {
                        return Err(ShardBuildError::InvalidInit(format!(
                            "Twist sidecar: wa_bits len mismatch for mem_id={} at step {} lane={} (got {}, expected {})",
                            inst.mem_id,
                            global_j,
                            lane_idx,
                            addr_bits.len(),
                            lane_layout.ell_addr
                        )));
                    }
                    cols[lane_layout.has_write][local_j] = Goldilocks::ONE;
                    cols[lane_layout.wv][local_j] = value;
                    for (bit_idx, bit) in addr_bits.into_iter().enumerate() {
                        cols[lane_layout.wa_bits.start + bit_idx][local_j] = bit;
                    }
                    let old = state.get(&addr).copied().unwrap_or(Goldilocks::ZERO);
                    cols[lane_layout.inc_at_write_addr][local_j] = value - old;
                    writes_to_apply.push((addr, value));
                }
            }

            for (addr, value) in writes_to_apply {
                if value == Goldilocks::ZERO {
                    state.remove(&addr);
                } else {
                    state.insert(addr, value);
                }
            }
        }

        for col in cols.iter() {
            wit.mats.push(scalar_column_to_mat(col));
        }
    }
    Ok(())
}

/// Build shard witness bundles for **shared CPU bus** mode.
///
/// Route-A uses metadata-only Twist/Shout instances (`comms = []`) and commits sidecar lane mats
/// directly during proving.
///
/// This builder therefore emits:
/// - `MemInstance/LutInstance` **metadata only** (`comms = []`)
/// - `MemWitness` mats populated with Twist lane columns over time
/// - `LutWitness` mats populated from trace shout events for single-lane instances
///   (`[addr_bits, has_lookup, val]`).
pub fn build_shard_witness_shared_cpu_bus<V, Cmt, K, A, Tw, Sh>(
    vm: V,
    twist: Tw,
    shout: Sh,
    max_steps: usize,
    chunk_size: usize,
    mem_layouts: &HashMap<u32, PlainMemLayout>,
    lut_tables: &HashMap<u32, LutTable<Goldilocks>>,
    lut_table_specs: &HashMap<u32, LutTableSpec>,
    lut_lanes: &HashMap<u32, usize>,
    initial_mem: &HashMap<(u32, u64), Goldilocks>,
    cpu_arith: &A,
) -> Result<Vec<StepWitnessBundle<Cmt, Goldilocks, K>>, ShardBuildError>
where
    V: neo_vm_trace::VmCpu<u64, u64>,
    Tw: neo_vm_trace::Twist<u64, u64>,
    Sh: neo_vm_trace::Shout<u64>,
    A: CpuArithmetization<Goldilocks, Cmt>,
{
    bundles_only(build_shard_witness_shared_cpu_bus_with_aux(
        vm,
        twist,
        shout,
        max_steps,
        chunk_size,
        mem_layouts,
        lut_tables,
        lut_table_specs,
        lut_lanes,
        initial_mem,
        cpu_arith,
    ))
}

/// Build shard witness bundles for **shared CPU bus** mode from an already-executed VM trace.
///
/// This is equivalent to `build_shard_witness_shared_cpu_bus(...)`, but avoids re-running the VM
/// when the caller already has a `VmTrace` available.
pub fn build_shard_witness_shared_cpu_bus_from_trace<Cmt, K, A>(
    trace: &VmTrace<u64, u64>,
    max_steps: usize,
    chunk_size: usize,
    mem_layouts: &HashMap<u32, PlainMemLayout>,
    lut_tables: &HashMap<u32, LutTable<Goldilocks>>,
    lut_table_specs: &HashMap<u32, LutTableSpec>,
    lut_lanes: &HashMap<u32, usize>,
    initial_mem: &HashMap<(u32, u64), Goldilocks>,
    cpu_arith: &A,
) -> Result<Vec<StepWitnessBundle<Cmt, Goldilocks, K>>, ShardBuildError>
where
    A: CpuArithmetization<Goldilocks, Cmt>,
{
    bundles_only(build_shard_witness_shared_cpu_bus_from_trace_with_aux(
        trace,
        max_steps,
        chunk_size,
        mem_layouts,
        lut_tables,
        lut_table_specs,
        lut_lanes,
        initial_mem,
        cpu_arith,
    ))
}

/// Like `build_shard_witness_shared_cpu_bus_from_trace`, but also returns auxiliary outputs useful
/// for higher-level APIs (e.g. output binding that needs terminal Twist memory states).
pub fn build_shard_witness_shared_cpu_bus_from_trace_with_aux<Cmt, K, A>(
    trace: &VmTrace<u64, u64>,
    max_steps: usize,
    chunk_size: usize,
    mem_layouts: &HashMap<u32, PlainMemLayout>,
    lut_tables: &HashMap<u32, LutTable<Goldilocks>>,
    lut_table_specs: &HashMap<u32, LutTableSpec>,
    lut_lanes: &HashMap<u32, usize>,
    initial_mem: &HashMap<(u32, u64), Goldilocks>,
    cpu_arith: &A,
) -> Result<(Vec<StepWitnessBundle<Cmt, Goldilocks, K>>, ShardWitnessAux), ShardBuildError>
where
    A: CpuArithmetization<Goldilocks, Cmt>,
{
    validate_chunk_size(chunk_size)?;
    if trace.steps.len() > max_steps {
        return Err(ShardBuildError::InvalidChunkSize(format!(
            "trace length {} exceeds max_steps {}",
            trace.steps.len(),
            max_steps
        )));
    }

    // Shared-bus mode does not support "silent dropping" of trace events: if the trace contains
    // Twist/Shout events, the corresponding instance metadata must be provided so the prover
    // actually proves those semantics.
    for (j, step) in trace.steps.iter().enumerate() {
        for ev in &step.twist_events {
            let mem_id = ev.twist_id.0;
            if !mem_layouts.contains_key(&mem_id) {
                return Err(ShardBuildError::MissingLayout(format!(
                    "trace contains twist events for twist_id={mem_id} at step {j}, but mem_layouts has no entry"
                )));
            }
        }
        for ev in &step.shout_events {
            let table_id = ev.shout_id.0;
            if !lut_tables.contains_key(&table_id) && !lut_table_specs.contains_key(&table_id) {
                return Err(ShardBuildError::MissingTable(format!(
                    "trace contains shout events for table_id={table_id} at step {j}, but neither lut_tables nor lut_table_specs has an entry"
                )));
            }
        }
    }
    for ((mem_id, _addr), _val) in initial_mem.iter() {
        if !mem_layouts.contains_key(mem_id) {
            return Err(ShardBuildError::MissingLayout(format!(
                "initial_mem contains entries for twist_id={mem_id}, but mem_layouts has no entry"
            )));
        }
    }

    let original_len = trace.steps.len();
    let did_halt = trace.did_halt();
    let steps_len = trace.steps.len();
    let chunks_len = steps_len.div_ceil(chunk_size);

    // Deterministic ordering (required for the shared-bus column schema).
    let mut mem_ids: Vec<u32> = mem_layouts.keys().copied().collect();
    mem_ids.sort_unstable();
    let mut table_ids: Vec<u32> = lut_tables
        .keys()
        .copied()
        .chain(lut_table_specs.keys().copied())
        .collect();
    table_ids.sort_unstable();
    table_ids.dedup();

    // 3) CPU arithmetization chunks.
    let mcss = cpu_arith
        .build_ccs_chunks(trace, chunk_size)
        .map_err(|e| ShardBuildError::CcsError(e.to_string()))?;
    if mcss.len() != chunks_len {
        return Err(ShardBuildError::CcsError(format!(
            "cpu arithmetization returned {} chunks, expected {} (steps={}, chunk_size={})",
            mcss.len(),
            chunks_len,
            steps_len,
            chunk_size
        )));
    }

    // 4) Track sparse memory state across chunks to compute per-chunk MemInit (rollover).
    let mut mem_states: HashMap<u32, HashMap<u64, Goldilocks>> = HashMap::new();
    for mem_id in mem_ids.iter().copied() {
        let layout = mem_layouts
            .get(&mem_id)
            .ok_or_else(|| ShardBuildError::MissingLayout(format!("missing PlainMemLayout for twist_id {}", mem_id)))?;
        let mut state = HashMap::<u64, Goldilocks>::new();
        for ((init_mem_id, addr), &val) in initial_mem.iter() {
            if *init_mem_id != mem_id || val == Goldilocks::ZERO {
                continue;
            }
            let addr_usize = usize::try_from(*addr).map_err(|_| {
                ShardBuildError::InvalidInit(format!(
                    "initial_mem address doesn't fit usize for twist_id {}: addr={addr}",
                    mem_id
                ))
            })?;
            if addr_usize >= layout.k {
                return Err(ShardBuildError::InvalidInit(format!(
                    "initial_mem address out of range for twist_id {}: addr={} >= k={}",
                    mem_id, addr, layout.k
                )));
            }
            if state.insert(*addr, val).is_some() {
                return Err(ShardBuildError::InvalidInit(format!(
                    "initial_mem contains duplicate address {} for twist_id {}",
                    addr, mem_id
                )));
            }
        }
        mem_states.insert(mem_id, state);
    }

    let mut step_bundles = Vec::with_capacity(chunks_len);
    let mut chunk_start = 0usize;
    for (chunk_idx, mcs) in mcss.into_iter().enumerate() {
        let chunk_end = (chunk_start + chunk_size).min(steps_len);
        let chunk_len = chunk_end.saturating_sub(chunk_start);
        if chunk_len == 0 {
            return Err(ShardBuildError::CcsError(format!(
                "internal error: empty chunk at chunk_idx {} (start={}, end={}, steps={})",
                chunk_idx, chunk_start, chunk_end, steps_len
            )));
        }

        // Memory instances (metadata-only).
        let mut mem_instances = Vec::new();
        for mem_id in mem_ids.iter().copied() {
            let layout = mem_layouts.get(&mem_id).ok_or_else(|| {
                ShardBuildError::MissingLayout(format!("missing PlainMemLayout for twist_id {}", mem_id))
            })?;
            let state = mem_states
                .get_mut(&mem_id)
                .ok_or_else(|| ShardBuildError::MissingLayout(format!("missing state for twist_id {}", mem_id)))?;
            let init = mem_init_from_state_map(mem_id, layout.k, state)
                .map_err(|e| ShardBuildError::InvalidInit(e.to_string()))?;
            let ell = ell_from_pow2_n_side(layout.n_side)?;

            let inst = MemInstance::<Cmt, Goldilocks> {
                mem_id,
                comms: Vec::new(),
                k: layout.k,
                d: layout.d,
                n_side: layout.n_side,
                steps: chunk_size,
                lanes: layout.lanes.max(1),
                ell,
                init,
            };
            let wit = MemWitness { mats: Vec::new() };
            mem_instances.push((inst, wit));

            // Advance state across this chunk for the next chunk's init.
            for t in chunk_start..chunk_end {
                let step = trace
                    .steps
                    .get(t)
                    .ok_or_else(|| ShardBuildError::VmError(format!("missing trace step t={t}")))?;
                for ev in &step.twist_events {
                    if ev.twist_id.0 != mem_id || ev.kind != TwistOpKind::Write {
                        continue;
                    }
                    let addr = ev.addr;
                    let Ok(addr_usize) = usize::try_from(addr) else {
                        continue;
                    };
                    if addr_usize >= layout.k {
                        continue;
                    }
                    let new_val = Goldilocks::from_u64(ev.value);
                    if new_val == Goldilocks::ZERO {
                        state.remove(&addr);
                    } else {
                        state.insert(addr, new_val);
                    }
                }
            }
        }

        // Lookup instances (metadata-only).
        let mut lut_instances = Vec::new();
        for table_id in table_ids.iter().copied() {
            if lut_tables.contains_key(&table_id) && lut_table_specs.contains_key(&table_id) {
                return Err(ShardBuildError::InvalidInit(format!(
                    "shout table_id={table_id} appears in both lut_tables (explicit) and lut_table_specs (implicit); pick exactly one to avoid schema ambiguity"
                )));
            }
            let table_spec = lut_table_specs.get(&table_id).cloned();

            let (k, d, n_side, ell, table) = if let Some(spec) = &table_spec {
                // Derive addressing parameters from the implicit table spec.
                match spec {
                    LutTableSpec::RiscvOpcode { xlen, .. } => {
                        let d = xlen.checked_mul(2).ok_or_else(|| {
                            ShardBuildError::InvalidInit("2*xlen overflow for RISC-V shout table".into())
                        })?;
                        let n_side = 2usize;
                        let ell = 1usize;
                        (0usize, d, n_side, ell, Vec::new())
                    }
                    LutTableSpec::RiscvOpcodePacked { opcode, xlen } => {
                        if *xlen != 32 {
                            return Err(ShardBuildError::InvalidInit(format!(
                                "RiscvOpcodePacked requires xlen=32 in shared-bus mode (got xlen={xlen})"
                            )));
                        }
                        let d = crate::riscv::packed::rv32_packed_d(*opcode)
                            .map_err(|e| ShardBuildError::InvalidInit(format!("invalid packed opcode spec: {e}")))?;
                        let n_side = 2usize;
                        let ell = 1usize;
                        (0usize, d, n_side, ell, Vec::new())
                    }
                    LutTableSpec::RiscvOpcodeEventTablePacked { .. } => {
                        return Err(ShardBuildError::InvalidInit(
                            "RiscvOpcodeEventTablePacked is not supported in the chunked builder path".into(),
                        ));
                    }
                    LutTableSpec::IdentityU32 => (0usize, 32usize, 2usize, 1usize, Vec::new()),
                }
            } else {
                let table = lut_tables.get(&table_id).ok_or_else(|| {
                    ShardBuildError::MissingTable(format!("missing LutTable for shout_id {}", table_id))
                })?;
                let ell = ell_from_pow2_n_side(table.n_side)?;
                (table.k, table.d, table.n_side, ell, table.content.clone())
            };

            let lanes = lut_lanes.get(&table_id).copied().unwrap_or(1).max(1);
            let inst = LutInstance::<Cmt, Goldilocks> {
                table_id,
                comms: Vec::new(),
                k,
                d,
                n_side,
                steps: chunk_size,
                lanes,
                ell,
                table_spec,
                table,
                addr_group: cpu_arith.shout_addr_groups().get(&table_id).copied(),
                selector_group: cpu_arith.shout_selector_groups().get(&table_id).copied(),
            };
            let wit = LutWitness { mats: Vec::new() };
            lut_instances.push((inst, wit));
        }
        populate_lut_witness_mats_from_trace_chunk(trace, chunk_start, chunk_end, chunk_size, &mut lut_instances)?;
        populate_mem_witness_mats_from_trace_chunk(trace, chunk_start, chunk_end, chunk_size, &mut mem_instances)?;

        let (trace_cols, trace_t_len, trace_sidecar_cols) =
            build_trace_columns_sidecar_from_trace_chunk(trace, chunk_start, chunk_end, chunk_size, mcs.0.m_in)?;
        let m_in = mcs.0.m_in;

        let step_bundle = StepWitnessBundle {
            mcs,
            lut_instances,
            mem_instances,
            trace_sidecar: Some(TraceColumnsSidecar {
                m_in,
                t_len: trace_t_len,
                trace_cols,
                cols: Arc::new(trace_sidecar_cols),
            }),
            _phantom: PhantomData,
        };

        step_bundles.push(step_bundle);

        chunk_start = chunk_end;
    }

    let aux = ShardWitnessAux {
        original_len,
        did_halt,
        max_steps,
        chunk_size,
        mem_ids,
        final_mem_states: mem_states,
    };
    Ok((step_bundles, aux))
}

/// Like `build_shard_witness_shared_cpu_bus`, but also returns auxiliary outputs useful for
/// higher-level APIs (e.g. output binding that needs the terminal Twist memory state).
pub fn build_shard_witness_shared_cpu_bus_with_aux<V, Cmt, K, A, Tw, Sh>(
    vm: V,
    twist: Tw,
    shout: Sh,
    max_steps: usize,
    chunk_size: usize,
    mem_layouts: &HashMap<u32, PlainMemLayout>,
    lut_tables: &HashMap<u32, LutTable<Goldilocks>>,
    lut_table_specs: &HashMap<u32, LutTableSpec>,
    lut_lanes: &HashMap<u32, usize>,
    initial_mem: &HashMap<(u32, u64), Goldilocks>,
    cpu_arith: &A,
) -> Result<(Vec<StepWitnessBundle<Cmt, Goldilocks, K>>, ShardWitnessAux), ShardBuildError>
where
    V: neo_vm_trace::VmCpu<u64, u64>,
    Tw: neo_vm_trace::Twist<u64, u64>,
    Sh: neo_vm_trace::Shout<u64>,
    A: CpuArithmetization<Goldilocks, Cmt>,
{
    validate_chunk_size(chunk_size)?;

    // 1) Run VM and collect the executed trace for this shard (up to `max_steps`).
    //
    // NOTE: We intentionally do **not** pad out to `max_steps` here. Padding is handled at the
    // per-chunk level by the CPU arithmetization via `is_active`, so the last chunk may be partial.
    //
    // This keeps the proof size proportional to the executed trace length instead of the caller's
    // safety bound.
    let trace = neo_vm_trace::trace_program(vm, twist, shout, max_steps)
        .map_err(|e| ShardBuildError::VmError(e.to_string()))?;
    build_shard_witness_shared_cpu_bus_from_trace_with_aux(
        &trace,
        max_steps,
        chunk_size,
        mem_layouts,
        lut_tables,
        lut_table_specs,
        lut_lanes,
        initial_mem,
        cpu_arith,
    )
}
