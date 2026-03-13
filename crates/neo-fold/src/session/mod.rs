//! Thin, ergonomic session layer for Π-CCS folding.
//!
//! This module provides:
//!   1) A small adapter trait (`NeoStep`) and `FoldingSession::add_step` for Nova/Sonobe-style step synthesis.
//!   2) A direct IO path via `ProveInput` + `FoldingSession::add_step_from_io` (callers hand us (x, w)).
//!   3) A session driver (`FoldingSession`) that **hides** commitment mixers.
//!
//! Concepts (paper-aligned):
//! - Accumulator: the k ME(b, L) claims you carry between steps (the inputs to the next Π_CCS).
//! - k is never defaulted: if you supply Accumulator with k>0, we multi-fold; if not, k=1 (simple case).
//!
//! Notes:
//! - We default to Ajtai mixers internally (no frontend mixers required).
//! - If you want k>1, pass an explicit Accumulator via `with_initial_accumulator(...)`.
//!
//! This file contains only ergonomics. The formal pipeline Π_CCS → Π_RLC → Π_DEC
//! lives in `shard::fold_shard_prove/verify` (Route A integration).

#![allow(non_snake_case)]
#![doc = include_str!("README.md")]

mod resources;
pub use resources::*;
mod layout;
pub use layout::*;
mod ccs_builder;
pub use ccs_builder::*;
mod circuit;
mod driver;
pub use crate::witness_layout;
pub use circuit::*;
use driver::SessionCcsCache;

use neo_ajtai::AjtaiSModule;
use neo_ajtai::{has_seed_for_dims, s_lincomb, s_mul, unload_global_pp_for_dims, Commitment as Cmt};
use neo_ccs::traits::SModuleHomomorphism;
use neo_ccs::{CcsClaim, CcsStructure, CcsWitness, CeClaim, Mat};
use neo_math::ring::Rq as RqEl;
use neo_math::{D, F, K};
use neo_memory::ajtai::{commit_cols_for_ccs_m, decode_vector_for_ccs_m, encode_vector_for_ccs_m};
use neo_memory::builder::{
    build_shard_witness_shared_cpu_bus_from_trace_with_aux,
    build_shard_witness_shared_cpu_bus_from_trace_with_aux_and_mem_remaps, build_shard_witness_shared_cpu_bus_with_aux,
    CpuArithmetization, ShardWitnessAux,
};
use neo_memory::plain::{LutTable, PlainMemLayout};
use neo_memory::witness::LutTableSpec;
use neo_memory::witness::{StepInstanceBundle, StepWitnessBundle};
use neo_memory::AffineWordAddressRemap;
use neo_params::NeoParams;
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeCharacteristicRing;
use rand_chacha::rand_core::{SeedableRng, TryRngCore};
use std::collections::HashMap;
use std::sync::Arc;

use crate::pi_ccs::FoldingMode;
use crate::shard::{self, CommitMixers, ShardProof as FoldRun, ShardProverContext, StepLinkingConfig};
use crate::PiCcsError;
use neo_reductions::engines::utils;
use neo_vm_trace::VmTrace;

/// Optional application-level "output claim".
/// (Not consumed by Π-CCS core yet; kept for API parity / future use.)
#[derive(Clone, Debug)]
pub struct OutputClaim<Ff> {
    pub tag: &'static [u8],
    pub expected: Ff,
}

// Twist/generic-lookup linkage is supported only via the shared CPU-bus path. Callers must provide:
// - metadata-only Twist/generic-lookup instances (no independent mem/lut commitments), and
// - a CPU witness/CCS that binds those bus fields (binding + padding constraints).

/// Direct inputs for a single step when you don't want to implement `NeoStep`.
/// We'll compute the commitment and split (x | w) for you.
#[derive(Clone, Debug)]
pub struct ProveInput<'a> {
    pub ccs: &'a CcsStructure<F>,            // the circuit (must match witness length)
    pub public_input: &'a [F],               // x
    pub witness: &'a [F],                    // w
    pub output_claims: &'a [OutputClaim<F>], // optional; recorded but not enforced here
}

/// Where special coordinates live inside the step witness `z`.
#[derive(Clone, Debug)]
pub struct StepSpec {
    /// Number of public state elements carried between steps (y).
    pub y_len: usize,
    /// Index of constant 1 inside z (optional informational).
    pub const1_index: usize,
    /// Indices in z carried out as next-step public state (y).
    pub y_step_indices: Vec<usize>,
    /// Optional: indices in z corresponding to app-level public inputs.
    pub app_input_indices: Option<Vec<usize>>,
    /// Number of public inputs `m_in` (prefix length in z).
    pub m_in: usize,
}

impl StepSpec {
    /// Derive a verifier-side step-linking configuration under the common IVC convention:
    ///
    /// - public `x` is ordered as `[const1] ++ y_step ++ app_inputs`
    ///   (this is exactly how `FoldingSession::add_step` constructs `x`), and
    /// - the *previous-step state* `y_prev` is stored as the first `y_len` elements of `app_inputs`.
    ///
    /// This yields constraints:
    /// `steps[i].x[1 + j] == steps[i+1].x[1 + y_step_len + j]` for `j = 0..y_len`.
    pub fn ivc_step_linking_pairs(&self) -> Result<Vec<(usize, usize)>, PiCcsError> {
        if self.y_len == 0 {
            return Ok(Vec::new());
        }
        let Some(app) = &self.app_input_indices else {
            return Err(PiCcsError::InvalidInput(
                "StepSpec: ivc_step_linking_pairs requires app_input_indices (y_prev as prefix of app_inputs)".into(),
            ));
        };
        if self.y_len > self.y_step_indices.len() {
            return Err(PiCcsError::InvalidInput(
                "StepSpec: ivc_step_linking_pairs requires y_step_indices to include y_step".into(),
            ));
        }
        if self.y_len > app.len() {
            return Err(PiCcsError::InvalidInput(
                "StepSpec: ivc_step_linking_pairs requires app_input_indices to include y_prev as a prefix".into(),
            ));
        }

        // Derive x-layout from the StepSpec to avoid hard-coding offsets.
        let x_indices = indices_from_spec(self);
        if x_indices.len() != self.m_in {
            return Err(PiCcsError::InvalidInput(format!(
                "StepSpec: ivc_step_linking_pairs requires m_in == 1 + y_step_indices.len() + app_input_indices.len(); got m_in={}, computed {}",
                self.m_in,
                x_indices.len()
            )));
        }

        // Reject duplicates to avoid ambiguous x-position mapping.
        let mut pos_by_z: HashMap<usize, usize> = HashMap::with_capacity(x_indices.len());
        for (pos, &z_idx) in x_indices.iter().enumerate() {
            if pos_by_z.insert(z_idx, pos).is_some() {
                return Err(PiCcsError::InvalidInput(
                    "StepSpec: ivc_step_linking_pairs requires unique x indices (duplicates found)".into(),
                ));
            }
        }

        // Under the IVC convention, y_prev is the prefix of app_inputs and y_step is the prefix of y_step_indices.
        let mut pairs = Vec::with_capacity(self.y_len);
        for j in 0..self.y_len {
            let y_step_z = self.y_step_indices[j];
            let y_prev_z = app[j];
            let step_pos = *pos_by_z
                .get(&y_step_z)
                .ok_or_else(|| PiCcsError::InvalidInput("StepSpec: y_step_indices must be included in x".into()))?;
            let prev_pos = *pos_by_z
                .get(&y_prev_z)
                .ok_or_else(|| PiCcsError::InvalidInput("StepSpec: app_input_indices must be included in x".into()))?;
            pairs.push((step_pos, prev_pos));
        }

        Ok(pairs)
    }
}

/// What a step must return for the session to run Π-CCS.
#[derive(Clone, Debug)]
pub struct StepArtifacts {
    pub ccs: Arc<CcsStructure<F>>,
    /// Concrete witness vector for this step (length = m).
    pub witness: Vec<F>,
    /// App inputs you want logged/exposed (optional, informational).
    pub public_app_inputs: Vec<F>,
    pub spec: StepSpec,
}

/// User implements this for their program.
pub trait NeoStep {
    type ExternalInputs: Clone;

    /// How many public state elements are threaded between steps?
    fn state_len(&self) -> usize;

    /// Static metadata about where special elements live inside `z`.
    fn step_spec(&self) -> StepSpec;

    /// Produce the CCS structure and a concrete witness for this step.
    fn synthesize_step(&mut self, step_idx: usize, y_prev: &[F], inputs: &Self::ExternalInputs) -> StepArtifacts;
}

/// Convert a rotation matrix rot(a) to the ring element a for S-action.
///
/// The first column of rot(a) contains cf(a) (coefficient form of the ring element a).
/// We extract those coefficients and use cf_inv to recover the ring element.
fn rot_matrix_to_rq(mat: &Mat<F>) -> RqEl {
    use neo_math::ring::cf_inv;

    debug_assert_eq!(mat.rows(), D);
    debug_assert_eq!(mat.cols(), D);

    // Extract the first column which contains cf(a)
    let mut coeffs = [F::ZERO; D];
    for i in 0..D {
        coeffs[i] = mat[(i, 0)];
    }

    // Convert coefficient array to ring element
    cf_inv(coeffs)
}

/// Default Ajtai mixers (hidden internally).
fn default_mixers() -> CommitMixers<fn(&[Mat<F>], &[Cmt]) -> Cmt, fn(&[Cmt], u32) -> Cmt> {
    fn mix_rhos_commits(rhos: &[Mat<F>], cs: &[Cmt]) -> Cmt {
        let rq_els: Vec<RqEl> = rhos.iter().map(rot_matrix_to_rq).collect();
        s_lincomb(&rq_els, cs).expect("s_lincomb should succeed")
    }
    fn combine_b_pows(cs: &[Cmt], b: u32) -> Cmt {
        let mut acc = cs[0].clone();
        let mut pow = F::from_u64(b as u64);
        for i in 1..cs.len() {
            let rq_pow = RqEl::from_field_scalar(pow);
            let term = s_mul(&rq_pow, &cs[i]);
            acc.add_inplace(&term);
            pow *= F::from_u64(b as u64);
        }
        acc
    }
    CommitMixers {
        mix_rhos_commits,
        combine_b_pows,
    }
}

/// An *Accumulator* is the k ME(b, L) claims carried between steps.
/// This is exactly the paper's ME(b, L)^k input vector for the next Π_CCS.
#[derive(Clone, Debug)]
pub struct Accumulator {
    pub me: Vec<CeClaim<Cmt, F, K>>,
    pub witnesses: Vec<Mat<F>>, // Z_i for each me[i]
}

impl Accumulator {
    /// Sanity checks: dimensions, common r, consistent m_in, witness shape, and y-vector padding.
    pub fn check(&self, params: &NeoParams, s: &CcsStructure<F>) -> Result<(), PiCcsError> {
        if self.me.len() != self.witnesses.len() {
            return Err(PiCcsError::InvalidInput(
                "Accumulator: me.len() != witnesses.len()".into(),
            ));
        }
        if self.me.is_empty() {
            return Ok(());
        }
        // Dims for r length
        let dims = utils::build_dims_and_policy(params, s)?;
        let ell_n = dims.ell_n;
        let want_pad = 1usize << dims.ell_d;

        // Common r and m_in
        let r0 = &self.me[0].r;
        if r0.len() != ell_n {
            return Err(PiCcsError::InvalidInput(format!(
                "Accumulator: r length mismatch (expected ell_n={}, got {})",
                ell_n,
                r0.len()
            )));
        }
        let m_in0 = self.me[0].m_in;
        let packed_cols = commit_cols_for_ccs_m(s.m);
        for (i, (m, Z)) in self.me.iter().zip(self.witnesses.iter()).enumerate() {
            if m.r.len() != ell_n {
                return Err(PiCcsError::InvalidInput(format!(
                    "Accumulator[{}]: r length mismatch (expected ell_n={}, got {})",
                    i,
                    ell_n,
                    m.r.len()
                )));
            }
            if m.r != *r0 {
                return Err(PiCcsError::InvalidInput(
                    "Accumulator: all ME inputs must share the same r".into(),
                ));
            }
            if m.m_in != m_in0 {
                return Err(PiCcsError::InvalidInput(
                    "Accumulator: all ME inputs must share the same m_in".into(),
                ));
            }
            if Z.rows() != D || Z.cols() != packed_cols {
                return Err(PiCcsError::InvalidInput(format!(
                    "Accumulator[{i}]: SuperNeo packed layout required (expected {}x{}, got {}x{})",
                    D,
                    packed_cols,
                    Z.rows(),
                    Z.cols()
                )));
            }
            decode_vector_for_ccs_m(params, s.m, Z).map_err(|e| {
                PiCcsError::InvalidInput(format!(
                    "Accumulator[{i}]: invalid SuperNeo packed witness layout for m={}: {e}",
                    s.m
                ))
            })?;
            if m.X.rows() != D || m.X.cols() != m.m_in {
                return Err(PiCcsError::InvalidInput(
                    "Accumulator: X dimension mismatch with m_in".into(),
                ));
            }
            // Validate y-vector shape: t rows, each padded to 2^{ell_d}
            if m.y_ring.len() != s.t() || !m.y_ring.iter().all(|row| row.len() == want_pad) {
                return Err(PiCcsError::InvalidInput(format!(
                    "Accumulator[{}]: y shape invalid; expected t={} rows padded to 2^{{ell_d}}={}",
                    i,
                    s.t(),
                    want_pad
                )));
            }
        }
        Ok(())
    }
}

/// Return the column indices of Z that must populate X, in order,
/// as dictated by the step spec.
fn indices_from_spec(spec: &StepSpec) -> Vec<usize> {
    let mut idx = Vec::with_capacity(spec.m_in);
    idx.push(spec.const1_index);
    idx.extend(&spec.y_step_indices);
    if let Some(app) = &spec.app_input_indices {
        idx.extend(app);
    }
    idx
}

/// Ergonomic helper: build an ME(b, L) instance from a raw witness z with **balanced** digits.
/// This is handy for constructing an explicit Accumulator.
///
/// - `z` is the full vector (x || w), length must equal `s.m`.
/// - `r` must have length `ell_n` (from dims).
/// - `m_in` is how many columns of Z to project into X (first m_in).
///
/// This function computes y-vectors from Z and r, and pads them to 2^{ell_d} to ensure
/// consistency with the protocol engine (which expects padded y-vectors).
pub fn me_from_z_balanced<Lm: SModuleHomomorphism<F, Cmt>>(
    params: &NeoParams,
    s: &CcsStructure<F>, // rectangular or square CCS
    l: &Lm,
    z: &[F],
    r: &[K],
    m_in: usize,
) -> Result<(CeClaim<Cmt, F, K>, Mat<F>), PiCcsError> {
    if z.len() != s.m {
        return Err(PiCcsError::InvalidInput(format!(
            "me_from_z_balanced: z length {} != CCS.m {}",
            z.len(),
            s.m
        )));
    }
    if m_in > s.m {
        return Err(PiCcsError::InvalidInput("me_from_z_balanced: m_in exceeds s.m".into()));
    }

    let dims = utils::build_dims_and_policy(params, s)?;
    if r.len() != dims.ell_n {
        return Err(PiCcsError::InvalidInput(format!(
            "me_from_z_balanced: r length {} != ell_n {}",
            r.len(),
            dims.ell_n
        )));
    }

    let Z = encode_vector_for_ccs_m(params, s.m, z)
        .map_err(|e| PiCcsError::InvalidInput(format!("me_from_z_balanced: witness encode failed: {e}")))?;
    let c = l.commit(&Z);

    // X := first m_in logical witness columns.
    let X = neo_reductions::common::project_x_from_witness_mat(&Z, s.m, m_in).map_err(|e| {
        PiCcsError::InvalidInput(format!(
            "me_from_z_balanced: X projection failed for m={}, m_in={}: {e}",
            s.m, m_in
        ))
    })?;

    let (y_ring, ct) = neo_reductions::common::compute_y_from_Z_and_r(s, &Z, r, dims.ell_d, params.b);

    let me = CeClaim::<Cmt, F, K> {
        c_step_coords: vec![],
        u_offset: 0,
        u_len: 0,
        c,
        X,
        r: r.to_vec(),
        s_col: Vec::new(),
        y_ring,
        ct,
        aux_openings: Vec::new(),
        y_zcol: Vec::new(),
        m_in,
        fold_digest: [0u8; 32],
    };

    Ok((me, Z))
}

/// Same as `me_from_z_balanced`, but X is formed by selecting the given Z-column indices,
/// in that exact order (required for NC constraints to hold).
///
/// This variant is used when public inputs are not contiguous at the front of z,
/// as specified by StepSpec indices.
pub fn me_from_z_balanced_select<Lm: SModuleHomomorphism<F, Cmt>>(
    params: &NeoParams,
    s: &CcsStructure<F>, // rectangular or square CCS
    l: &Lm,
    z: &[F],
    r: &[K],
    x_col_indices: &[usize], // which columns of Z form X, in order
) -> Result<(CeClaim<Cmt, F, K>, Mat<F>), PiCcsError> {
    if z.len() != s.m {
        return Err(PiCcsError::InvalidInput(format!(
            "me_from_z_balanced_select: z length {} != CCS.m {}",
            z.len(),
            s.m
        )));
    }

    let dims = utils::build_dims_and_policy(params, s)?;
    if r.len() != dims.ell_n {
        return Err(PiCcsError::InvalidInput(format!(
            "me_from_z_balanced_select: r length {} != ell_n {}",
            r.len(),
            dims.ell_n
        )));
    }

    let Z = encode_vector_for_ccs_m(params, s.m, z)
        .map_err(|e| PiCcsError::InvalidInput(format!("me_from_z_balanced_select: witness encode failed: {e}")))?;
    let d = Z.rows();
    let c = l.commit(&Z);

    // X := selected logical witness columns (not necessarily contiguous).
    let m_in = x_col_indices.len();
    let mut X = Mat::zero(d, m_in, F::ZERO);
    let z_layout = neo_reductions::common::witness_mat_layout(&Z, s.m).map_err(|e| {
        PiCcsError::InvalidInput(format!(
            "me_from_z_balanced_select: invalid witness layout for m={}: {e}",
            s.m
        ))
    })?;
    for (j, &col) in x_col_indices.iter().enumerate() {
        if col >= s.m {
            return Err(PiCcsError::InvalidInput(format!(
                "X column index {} out of range (logical witness width {})",
                col, s.m
            )));
        }
        for rho in 0..d {
            X[(rho, j)] = neo_reductions::common::witness_mat_get_f(&Z, z_layout, s.m, rho, col);
        }
    }

    // Debug assertion that X equals the projection of Z
    #[cfg(feature = "debug-logs")]
    {
        for (j, &col) in x_col_indices.iter().enumerate() {
            for rho in 0..d {
                debug_assert_eq!(
                    X[(rho, j)],
                    neo_reductions::common::witness_mat_get_f(&Z, z_layout, s.m, rho, col),
                    "X != logical Z[:, col]"
                );
            }
        }
    }

    let (y_ring, ct) = neo_reductions::common::compute_y_from_Z_and_r(s, &Z, r, dims.ell_d, params.b);

    let me = CeClaim::<Cmt, F, K> {
        c_step_coords: vec![],
        u_offset: 0,
        u_len: 0,
        c,
        X,
        r: r.to_vec(),
        s_col: Vec::new(),
        y_ring,
        ct,
        aux_openings: Vec::new(),
        y_zcol: Vec::new(),
        m_in,
        fold_digest: [0u8; 32],
    };

    Ok((me, Z))
}

/// Minimal session that provides an ergonomic per-step API.
/// Mixers are hidden and default to Ajtai; the initial Accumulator is optional.
/// If absent, we run the *simple* k=1 case (no ME inputs).
pub struct FoldingSession<L>
where
    L: SModuleHomomorphism<F, Cmt> + Clone + Sync,
{
    mode: FoldingMode,
    params: NeoParams,
    l: L,
    commit_m: Option<usize>,
    mixers: CommitMixers<fn(&[Mat<F>], &[Cmt]) -> Cmt, fn(&[Cmt], u32) -> Cmt>,

    // Cached CCS preprocessing for proving (best-effort reuse).
    prover_ctx: Option<SessionCcsCache>,
    // Cached CCS preprocessing for verification (must be explicitly preloaded).
    verifier_ctx: Option<SessionCcsCache>,

    // Collected per-step bundles (CCS-only steps have empty LUT/MEM vectors)
    steps: Vec<StepWitnessBundle<Cmt, F, K>>,
    /// Auxiliary data for the most recent shared-CPU-bus witness build (if any).
    ///
    /// This is used to support ergonomic APIs such as “output binding without manually providing
    /// final_memory_state”.
    shared_bus_aux: Option<ShardWitnessAux>,
    /// Optional declarative resource configuration used by `execute_shard_shared_cpu_bus_configured`.
    shared_bus_resources: Option<SharedBusResources>,

    /// Optional verifier-side step-to-step linking constraints.
    ///
    /// If more than one step is collected, verification requires either:
    /// - a non-empty `step_linking` config, or
    /// - `allow_unlinked_steps=true` (explicit and unsafe).
    step_linking: Option<StepLinkingConfig>,
    /// Explicit escape hatch: allow verifying multi-step runs without step linking.
    ///
    /// This is unsafe for any workflow where step-to-step chaining is part of the statement.
    allow_unlinked_steps: bool,
    /// Best-effort diagnostic for why auto step-linking did not engage (if attempted).
    auto_step_linking_error: Option<String>,

    // Optional initial accumulated ME(b, L)^k inputs (k = me.len()).
    acc0: Option<Accumulator>,

    // Optional: app-level claims recorded per step (not enforced here yet)
    step_claims: Vec<Vec<OutputClaim<F>>>,

    /// Current threaded state y (if any). Length is determined by `NeoStep::state_len()`.
    curr_state: Option<Vec<F>>,
}

impl<L> FoldingSession<L>
where
    L: SModuleHomomorphism<F, Cmt> + Clone + Sync,
{
    /// Create a new session with default Ajtai mixers and no initial accumulator (k=1 simple flow).
    pub fn new(mode: FoldingMode, params: NeoParams, l: L) -> Self {
        Self {
            mode,
            params,
            l,
            commit_m: None,
            mixers: default_mixers(),
            prover_ctx: None,
            verifier_ctx: None,
            steps: vec![],
            shared_bus_aux: None,
            shared_bus_resources: None,
            step_linking: None,
            allow_unlinked_steps: false,
            auto_step_linking_error: None,
            acc0: None,
            step_claims: vec![],
            curr_state: None,
        }
    }

    /// Access the selected Neo parameters for this session.
    pub fn params(&self) -> &NeoParams {
        &self.params
    }

    /// Returns the configured initial accumulator, if any.
    ///
    /// When this is `None`, the session is using the "simple" flow (k=1, no ME inputs).
    pub fn initial_accumulator(&self) -> Option<&Accumulator> {
        self.acc0.as_ref()
    }

    /// Access the underlying committer used by this session.
    pub fn committer(&self) -> &L {
        &self.l
    }

    fn ensure_committer_m_matches(&self, m: usize) -> Result<(), PiCcsError> {
        let Some(commit_m) = self.commit_m else {
            return Ok(());
        };
        let expected_commit_m = commit_cols_for_ccs_m(m);
        if commit_m != expected_commit_m {
            return Err(PiCcsError::InvalidInput(format!(
                "session committer configured for witness columns={}, but this step expects witness columns={} (from CCS.m={}); construct the session from the same CCS width/layout",
                commit_m, expected_commit_m, m
            )));
        }
        Ok(())
    }

    /// Replace the stored shared-bus resource configuration (Twist layouts/init + Shout tables/specs).
    pub fn set_shared_bus_resources(&mut self, resources: SharedBusResources) {
        self.shared_bus_resources = Some(resources);
    }

    /// Mutably access (and lazily initialize) the shared-bus resource configuration.
    pub fn shared_bus_resources_mut(&mut self) -> &mut SharedBusResources {
        self.shared_bus_resources
            .get_or_insert_with(SharedBusResources::new)
    }

    /// Execute a VM shard in shared-CPU-bus mode using the resources stored on this session.
    ///
    /// This is equivalent to calling `execute_shard_shared_cpu_bus(...)` with the maps from
    /// `SharedBusResources`, but avoids re-threading those arguments on every call.
    pub fn execute_shard_shared_cpu_bus_configured<V, A, Tw, Sh>(
        &mut self,
        vm: V,
        twist: Tw,
        shout: Sh,
        max_steps: usize,
        chunk_size: usize,
        cpu_arith: &A,
    ) -> Result<(), PiCcsError>
    where
        V: neo_vm_trace::VmCpu<u64, u64, u128>,
        Tw: neo_vm_trace::Twist<u64, u64>,
        Sh: neo_vm_trace::Shout<u128, u64>,
        A: CpuArithmetization<F, Cmt, u128>,
    {
        let (bundles, aux) = {
            let resources = self.shared_bus_resources.as_ref().ok_or_else(|| {
                PiCcsError::InvalidInput(
                    "missing shared-bus resources; call set_shared_bus_resources(...) or shared_bus_resources_mut() first".into(),
                )
            })?;

            build_shard_witness_shared_cpu_bus_with_aux(
                vm,
                twist,
                shout,
                max_steps,
                chunk_size,
                &resources.mem_layouts,
                &resources.lut_tables,
                &resources.lut_table_specs,
                &resources.lut_lanes,
                &resources.initial_mem,
                cpu_arith,
            )
            .map_err(|e| PiCcsError::InvalidInput(format!("shared-bus witness build failed: {e:?}")))?
        };

        self.add_step_bundles(bundles);
        self.shared_bus_aux = Some(aux);
        Ok(())
    }

    /// Enable verifier-side step-to-step linking for multi-step runs.
    pub fn set_step_linking(&mut self, cfg: StepLinkingConfig) {
        self.step_linking = Some(cfg);
        self.auto_step_linking_error = None;
    }

    /// Enable verifier-side step-to-step linking using the common IVC convention from `StepSpec`.
    ///
    /// See `StepSpec::ivc_step_linking_pairs` for the exact assumptions.
    pub fn enable_step_linking_from_step_spec(&mut self, spec: &StepSpec) -> Result<(), PiCcsError> {
        let pairs = spec.ivc_step_linking_pairs()?;
        self.set_step_linking(StepLinkingConfig::new(pairs));
        Ok(())
    }

    /// Set an explicit initial state y₀ for the IVC (optional).
    /// If not set, y₀ defaults to all zeros of length `state_len()`.
    pub fn set_initial_state(&mut self, y0: Vec<F>) {
        self.curr_state = Some(y0);
    }

    /// Inject an explicit initial Accumulator (k = acc.me.len()). This enables k>1 multi-folding.
    pub fn with_initial_accumulator(mut self, acc: Accumulator, s: &CcsStructure<F>) -> Result<Self, PiCcsError> {
        acc.check(&self.params, s)?;
        self.acc0 = Some(acc);
        Ok(self)
    }

    /// Access the accumulated public MCS instances (for verification APIs).
    pub fn mcss_public(&self) -> Vec<CcsClaim<Cmt, F>> {
        self.steps.iter().map(|step| step.mcs.0.clone()).collect()
    }

    /// Access the collected *public* per-step bundles (MCS + optional Twist/generic-lookup instances).
    ///
    /// This is useful for specialized verifiers that need access
    /// to memory/lookup instances, not just the MCS list.
    pub fn steps_public(&self) -> Vec<StepInstanceBundle<Cmt, F, K>> {
        self.steps.iter().map(StepInstanceBundle::from).collect()
    }

    /// Access the collected per-step witness bundles (includes private witness).
    pub fn steps_witness(&self) -> &[StepWitnessBundle<Cmt, F, K>] {
        &self.steps
    }

    pub fn steps_witness_mut(&mut self) -> &mut [StepWitnessBundle<Cmt, F, K>] {
        &mut self.steps
    }

    /// Access auxiliary data captured during the most recent shared-CPU-bus witness build (if any).
    pub fn shared_bus_aux(&self) -> Option<&ShardWitnessAux> {
        self.shared_bus_aux.as_ref()
    }

    /// Add one step using the `NeoStep` synthesis adapter.
    /// This accumulates the step instance and witness without performing any folding.
    ///
    /// If the returned `StepSpec` matches the common IVC layout (see
    /// `StepSpec::ivc_step_linking_pairs`), this automatically enables verifier-side step linking
    /// so multi-step verification works by default.
    pub fn add_step<S: NeoStep>(&mut self, stepper: &mut S, inputs: &S::ExternalInputs) -> Result<(), PiCcsError> {
        let step_idx = self.steps.len();
        // 1) Decide previous state y_prev
        let state_len = stepper.state_len();
        let y_prev = self
            .curr_state
            .clone()
            .unwrap_or_else(|| vec![F::ZERO; state_len]);

        // 2) Let the app synthesize CCS + witness given y_prev
        let StepArtifacts {
            ccs,
            witness: z,
            spec,
            public_app_inputs: _,
        } = stepper.synthesize_step(step_idx, &y_prev, inputs);

        // Safety: require state_len to match StepSpec
        if spec.y_len != state_len {
            return Err(PiCcsError::InvalidInput(format!(
                "StepSpec.y_len ({}) must equal stepper.state_len() ({})",
                spec.y_len, state_len
            )));
        }

        if self.step_linking.is_none() && !self.allow_unlinked_steps {
            match spec.ivc_step_linking_pairs() {
                Ok(pairs) => {
                    if !pairs.is_empty() {
                        self.set_step_linking(StepLinkingConfig::new(pairs));
                    }
                }
                Err(e) => {
                    self.auto_step_linking_error = Some(format!("step {step_idx}: {e}"));
                }
            }
        }

        // Canonicalize witness length to the CCS width.
        let m_expected = ccs.m;
        self.ensure_committer_m_matches(m_expected)?;
        if z.len() != m_expected {
            return Err(PiCcsError::InvalidInput(format!(
                "step witness length {} must equal CCS.m={}",
                z.len(),
                m_expected,
            )));
        }
        if spec.m_in > z.len() {
            return Err(PiCcsError::InvalidInput("m_in exceeds witness length".into()));
        }

        // 3) Build MCS instance + witness as before
        let x_indices = indices_from_spec(&spec);

        if x_indices.len() != spec.m_in {
            return Err(PiCcsError::InvalidInput(format!(
                "StepSpec produced {} public-input indices, expected m_in={}",
                x_indices.len(),
                spec.m_in
            )));
        }

        // Validate uniqueness
        {
            use std::collections::BTreeSet;
            if x_indices.iter().copied().collect::<BTreeSet<_>>().len() != x_indices.len() {
                return Err(PiCcsError::InvalidInput("StepSpec indices contain duplicates".into()));
            }
        }

        // Validate range
        if let Some(&idx) = x_indices.iter().find(|&&i| i >= z.len()) {
            return Err(PiCcsError::InvalidInput(format!(
                "StepSpec index {} out of bounds (witness length {})",
                idx,
                z.len()
            )));
        }

        let x: Vec<F> = x_indices.iter().map(|&i| z[i]).collect();

        let Z = encode_vector_for_ccs_m(&self.params, m_expected, &z)
            .map_err(|e| PiCcsError::InvalidInput(format!("encode step witness failed: {e}")))?;
        let c = self.l.commit(&Z);
        let m_in = spec.m_in;

        // w is the private witness (suffix)
        let w = z[m_in..].to_vec();

        let mcs_inst = CcsClaim { c, x, m_in };
        let mcs_wit = CcsWitness { w, Z };

        self.shared_bus_aux = None;
        self.steps.push((mcs_inst, mcs_wit).into());
        self.step_claims.push(vec![]);

        // 4) Update current state y from the witness coordinates
        if spec.y_len > 0 {
            if spec.y_len > spec.y_step_indices.len() {
                return Err(PiCcsError::InvalidInput(
                    "StepSpec: y_len exceeds y_step_indices.len()".into(),
                ));
            }
            let mut new_state = Vec::with_capacity(spec.y_len);
            for &idx in spec.y_step_indices.iter().take(spec.y_len) {
                if idx >= z.len() {
                    return Err(PiCcsError::InvalidInput(format!(
                        "StepSpec y_step_index {} out of bounds for witness of length {}",
                        idx,
                        z.len()
                    )));
                }
                new_state.push(z[idx]);
            }
            self.curr_state = Some(new_state);
        }

        Ok(())
    }

    /// Add one step directly from (x, w) without implementing `NeoStep`.
    /// We compute the commitment and split (x | w) for you.
    /// This accumulates the step instance and witness without performing any folding.
    pub fn add_step_from_io(&mut self, input: &ProveInput<'_>) -> Result<(), PiCcsError> {
        let m_in = input.public_input.len();
        let m_expected = input.ccs.m;
        self.ensure_committer_m_matches(m_expected)?;
        let total = m_in
            .checked_add(input.witness.len())
            .ok_or_else(|| PiCcsError::InvalidInput("len(x) + len(w) overflow".into()))?;
        if total != m_expected {
            return Err(PiCcsError::InvalidInput(format!(
                "len(x) + len(w) = {} but CCS.m = {}",
                total, m_expected
            )));
        }

        // Build z = [x | w], compute Z and commitment c
        let mut z = Vec::with_capacity(m_expected);
        z.extend_from_slice(input.public_input);
        z.extend_from_slice(input.witness);
        debug_assert_eq!(z.len(), m_expected);

        let Z = encode_vector_for_ccs_m(&self.params, m_expected, &z)
            .map_err(|e| PiCcsError::InvalidInput(format!("encode step witness failed: {e}")))?;
        let c = self.l.commit(&Z);

        // Produce MCS instance + witness
        let mcs_inst = CcsClaim {
            c,
            x: input.public_input.to_vec(),
            m_in,
        };
        let mcs_wit = CcsWitness {
            w: z[m_in..].to_vec(),
            Z,
        };

        self.shared_bus_aux = None;
        self.steps.push((mcs_inst, mcs_wit).into());
        self.step_claims.push(input.output_claims.to_vec());

        Ok(())
    }

    /// Convenience: add one step directly from `(x, w)` without constructing `ProveInput`.
    pub fn add_step_io(&mut self, ccs: &CcsStructure<F>, public_input: &[F], witness: &[F]) -> Result<(), PiCcsError> {
        let input = ProveInput {
            ccs,
            public_input,
            witness,
            output_claims: &[],
        };
        self.add_step_from_io(&input)
    }

    /// Convenience: add `n_steps` steps by repeatedly calling `add_step`.
    pub fn add_steps<S: NeoStep>(
        &mut self,
        stepper: &mut S,
        inputs: &S::ExternalInputs,
        n_steps: usize,
    ) -> Result<(), PiCcsError> {
        for _ in 0..n_steps {
            self.add_step(stepper, inputs)?;
        }
        Ok(())
    }

    /// Add a pre-built step bundle directly.
    ///
    /// This is the low-level API for when you have already constructed a `StepWitnessBundle`
    /// with memory (Twist) and/or lookup (Shout) instances.
    ///
    /// Use this method when your proof requires Twist/generic-lookup arguments in addition to CCS.
    pub fn add_step_bundle(&mut self, bundle: StepWitnessBundle<Cmt, F, K>) {
        self.shared_bus_aux = None;
        self.steps.push(bundle);
        self.step_claims.push(vec![]);
    }

    /// Add multiple pre-built step bundles at once.
    pub fn add_step_bundles(&mut self, bundles: impl IntoIterator<Item = StepWitnessBundle<Cmt, F, K>>) {
        for bundle in bundles {
            self.add_step_bundle(bundle);
        }
    }

    /// Execute a VM for one shard and add shared-CPU-bus step bundles to this session.
    ///
    /// This is an ergonomic wrapper around `neo_memory::builder::build_shard_witness_shared_cpu_bus_with_aux`.
    /// It also stores auxiliary outputs (including the terminal Twist memory state) so the session
    /// can later prove output binding without the caller manually providing `final_memory_state`.
    pub fn execute_shard_shared_cpu_bus<V, A, Tw, Sh>(
        &mut self,
        vm: V,
        twist: Tw,
        shout: Sh,
        max_steps: usize,
        chunk_size: usize,
        mem_layouts: &HashMap<u32, PlainMemLayout>,
        lut_tables: &HashMap<u32, LutTable<F>>,
        lut_table_specs: &HashMap<u32, LutTableSpec>,
        lut_lanes: &HashMap<u32, usize>,
        initial_mem: &HashMap<(u32, u64), F>,
        cpu_arith: &A,
    ) -> Result<(), PiCcsError>
    where
        V: neo_vm_trace::VmCpu<u64, u64, u128>,
        Tw: neo_vm_trace::Twist<u64, u64>,
        Sh: neo_vm_trace::Shout<u128, u64>,
        A: CpuArithmetization<F, Cmt, u128>,
    {
        let (bundles, aux) = build_shard_witness_shared_cpu_bus_with_aux(
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
        )
        .map_err(|e| PiCcsError::InvalidInput(format!("shared-bus witness build failed: {e:?}")))?;

        self.add_step_bundles(bundles);
        self.shared_bus_aux = Some(aux);
        Ok(())
    }

    /// Add shared-CPU-bus step bundles from an already-executed trace.
    ///
    /// This avoids re-running `trace_program` when the caller already has a `VmTrace`.
    pub fn execute_shard_shared_cpu_bus_from_trace<A, Key>(
        &mut self,
        trace: &VmTrace<u64, u64, Key>,
        max_steps: usize,
        chunk_size: usize,
        mem_layouts: &HashMap<u32, PlainMemLayout>,
        lut_tables: &HashMap<u32, LutTable<F>>,
        lut_table_specs: &HashMap<u32, LutTableSpec>,
        lut_lanes: &HashMap<u32, usize>,
        initial_mem: &HashMap<(u32, u64), F>,
        cpu_arith: &A,
    ) -> Result<(), PiCcsError>
    where
        A: CpuArithmetization<F, Cmt, Key>,
        Key: Copy + TryInto<u128> + Eq,
        <Key as TryInto<u128>>::Error: std::fmt::Debug,
    {
        let (bundles, aux) = build_shard_witness_shared_cpu_bus_from_trace_with_aux(
            trace,
            max_steps,
            chunk_size,
            mem_layouts,
            lut_tables,
            lut_table_specs,
            lut_lanes,
            initial_mem,
            cpu_arith,
        )
        .map_err(|e| PiCcsError::InvalidInput(format!("shared-bus witness build failed: {e:?}")))?;

        self.add_step_bundles(bundles);
        self.shared_bus_aux = Some(aux);
        Ok(())
    }

    pub fn execute_shard_shared_cpu_bus_from_trace_with_mem_remaps<A, Key>(
        &mut self,
        trace: &VmTrace<u64, u64, Key>,
        max_steps: usize,
        chunk_size: usize,
        mem_layouts: &HashMap<u32, PlainMemLayout>,
        lut_tables: &HashMap<u32, LutTable<F>>,
        lut_table_specs: &HashMap<u32, LutTableSpec>,
        lut_lanes: &HashMap<u32, usize>,
        initial_mem: &HashMap<(u32, u64), F>,
        mem_addr_remaps: &HashMap<u32, AffineWordAddressRemap>,
        cpu_arith: &A,
    ) -> Result<(), PiCcsError>
    where
        A: CpuArithmetization<F, Cmt, Key>,
        Key: Copy + TryInto<u128> + Eq,
        <Key as TryInto<u128>>::Error: std::fmt::Debug,
    {
        let (bundles, aux) = build_shard_witness_shared_cpu_bus_from_trace_with_aux_and_mem_remaps(
            trace,
            max_steps,
            chunk_size,
            mem_layouts,
            lut_tables,
            lut_table_specs,
            lut_lanes,
            initial_mem,
            mem_addr_remaps,
            cpu_arith,
        )
        .map_err(|e| PiCcsError::InvalidInput(format!("shared-bus witness build failed: {e:?}")))?;

        self.add_step_bundles(bundles);
        self.shared_bus_aux = Some(aux);
        Ok(())
    }
}

impl FoldingSession<AjtaiSModule> {
    /// Build a session with an Ajtai committer and auto-picked Goldilocks parameters.
    ///
    /// This is intended as a “few lines” frontend: it hides Ajtai PP generation and `NeoParams`
    /// selection.
    ///
    /// - Commitment width follows active embedding layout (`ccs.m` or `ccs.m / D`).
    /// - Parameters use `max(ccs.n, ccs.m)` to satisfy extension-field policy for both FE and NC.
    ///
    /// For deterministic parameters (e.g. in tests), use `new_ajtai_seeded`.
    pub fn new_ajtai(mode: FoldingMode, ccs: &CcsStructure<F>) -> Result<Self, PiCcsError> {
        let m_commit = commit_cols_for_ccs_m(ccs.m);
        let params = NeoParams::goldilocks_auto_r1cs_ccs(ccs.n.max(ccs.m))
            .map_err(|e| PiCcsError::InvalidInput(format!("NeoParams::goldilocks_auto_r1cs_ccs failed: {e}")))?;

        let mut seed = [0u8; 32];
        rand_chacha::rand_core::OsRng
            .try_fill_bytes(&mut seed)
            .map_err(|e| PiCcsError::InvalidInput(format!("OsRng failed: {e}")))?;
        let mut rng = rand_chacha::ChaCha8Rng::from_seed(seed);
        let pp = neo_ajtai::setup_par(&mut rng, D, params.kappa as usize, m_commit)
            .map_err(|e| PiCcsError::InvalidInput(format!("Ajtai setup failed: {e}")))?;
        let committer = AjtaiSModule::new(Arc::new(pp));
        let mut session = FoldingSession::new(mode, params, committer);
        session.commit_m = Some(m_commit);
        Ok(session)
    }

    /// Same as `new_ajtai`, but with a deterministic ChaCha8 seed for reproducible tests/benchmarks.
    ///
    /// This uses the sequential Ajtai setup to avoid any parallelism-related determinism concerns.
    pub fn new_ajtai_seeded(mode: FoldingMode, ccs: &CcsStructure<F>, seed: [u8; 32]) -> Result<Self, PiCcsError> {
        let m_commit = commit_cols_for_ccs_m(ccs.m);
        let params = NeoParams::goldilocks_auto_r1cs_ccs(ccs.n.max(ccs.m))
            .map_err(|e| PiCcsError::InvalidInput(format!("NeoParams::goldilocks_auto_r1cs_ccs failed: {e}")))?;

        let mut rng = rand_chacha::ChaCha8Rng::from_seed(seed);
        let pp = neo_ajtai::setup(&mut rng, D, params.kappa as usize, m_commit)
            .map_err(|e| PiCcsError::InvalidInput(format!("Ajtai setup failed: {e}")))?;
        let committer = AjtaiSModule::new(Arc::new(pp));
        let mut session = FoldingSession::new(mode, params, committer);
        session.commit_m = Some(m_commit);
        Ok(session)
    }
}
