//! Session-level proving and verification driver logic.
//!
//! This module owns the heavy orchestration for the public session facade in
//! `session.rs`: preprocessing shared-bus CCS data, driving shard prove/verify
//! flows, and packaging accumulator/output state across the session boundary.

use super::*;
use crate::shard::{elapsed_ms, time_now};
use neo_reductions::engines::optimized_engine::oracle::SparseCache;

#[derive(Clone)]
pub(super) struct SessionCcsCache {
    /// Address of the caller-supplied `CcsStructure` used to build this cache.
    src_ptr: usize,
    /// Precomputed circuit artifacts (digest + optional sparse cache).
    ctx: ShardProverContext,
}

impl<L> FoldingSession<L>
where
    L: SModuleHomomorphism<F, Cmt> + Clone + Sync,
{
    /// Check if any steps have Twist (memory) instances.
    pub fn has_twist_instances(&self) -> bool {
        self.steps.iter().any(|s| !s.mem_instances.is_empty())
    }

    /// Check if any steps have Shout (lookup) instances.
    pub fn has_shout_instances(&self) -> bool {
        self.steps.iter().any(|s| !s.lut_instances.is_empty())
    }

    fn validate_step_bundle_superneo_layout(
        &self,
        s: &CcsStructure<F>,
        step_idx: usize,
        step: &StepWitnessBundle<Cmt, F, K>,
    ) -> Result<(), PiCcsError> {
        let m_in = step.mcs.0.m_in;
        if step.mcs.0.x.len() != m_in {
            return Err(PiCcsError::InvalidInput(format!(
                "step {step_idx}: mcs.x length {} != m_in {}",
                step.mcs.0.x.len(),
                m_in
            )));
        }
        let logical_m = m_in
            .checked_add(step.mcs.1.w.len())
            .ok_or_else(|| PiCcsError::InvalidInput(format!("step {step_idx}: m_in + witness length overflow")))?;
        if logical_m != s.m {
            return Err(PiCcsError::InvalidInput(format!(
                "step {step_idx}: logical witness length m_in + |w| = {} does not match CCS.m = {}",
                logical_m, s.m
            )));
        }

        let z = &step.mcs.1.Z;
        let packed_cols = commit_cols_for_ccs_m(s.m);
        if z.rows() != D || z.cols() != packed_cols {
            return Err(PiCcsError::InvalidInput(format!(
                "step {step_idx}: SuperNeo packed witness layout required (expected {}x{}, got {}x{})",
                D,
                packed_cols,
                z.rows(),
                z.cols()
            )));
        }
        decode_vector_for_ccs_m(&self.params, s.m, z).map_err(|e| {
            PiCcsError::InvalidInput(format!(
                "step {step_idx}: invalid SuperNeo packed witness encoding for m={}: {e}",
                s.m
            ))
        })?;

        Ok(())
    }

    fn ensure_steps_superneo_layout(&self, s: &CcsStructure<F>) -> Result<(), PiCcsError> {
        for (step_idx, step) in self.steps.iter().enumerate() {
            self.validate_step_bundle_superneo_layout(s, step_idx, step)?;
        }
        Ok(())
    }

    fn ensure_accumulator_matches_ccs(&mut self, s: &CcsStructure<F>) -> Result<(), PiCcsError> {
        let Some(acc) = self.acc0.as_mut() else {
            return Ok(());
        };

        if acc.me.is_empty() {
            return Ok(());
        }
        if acc
            .me
            .iter()
            .all(|me| me.y_ring.len() == s.t() && me.ct.len() == s.t())
        {
            return Ok(());
        }

        let dims = utils::build_dims_and_policy(&self.params, s)?;
        let d_pad = 1usize << dims.ell_d;

        for (me, z_mat) in acc.me.iter_mut().zip(acc.witnesses.iter()) {
            let (y_ring, ct) =
                neo_reductions::common::compute_y_from_Z_and_r(s, z_mat, &me.r, dims.ell_d, self.params.b);
            if y_ring.iter().any(|row| row.len() != d_pad) {
                return Err(PiCcsError::ProtocolError(format!(
                    "accumulator normalization produced non-canonical y padding (expected {d_pad})"
                )));
            }
            me.y_ring = y_ring;
            me.ct = ct;
        }

        Ok(())
    }

    fn prepared_ccs_for_accumulator<'s>(&self, s: &'s CcsStructure<F>) -> Result<&'s CcsStructure<F>, PiCcsError> {
        if !(self.has_twist_instances() || self.has_shout_instances()) {
            return Ok(s);
        }
        if self.steps.is_empty() {
            return Ok(s);
        }

        // Shared CPU bus is the only supported Route-A witness format.
        let step0 = &self.steps[0];
        let is_shared_bus = step0
            .mem_instances
            .iter()
            .all(|(inst, wit)| inst.comms.is_empty() && wit.mats.is_empty())
            && step0
                .lut_instances
                .iter()
                .all(|(inst, wit)| inst.comms.is_empty() && wit.mats.is_empty());
        if !is_shared_bus {
            return Err(PiCcsError::InvalidInput(
                "legacy no-shared CPU bus witness format was removed; use shared-bus witness bundles".into(),
            ));
        }

        // Use witness-side steps for CCS preparation so Route-A time-column mode can be inferred
        // before proof generation. `StepInstanceBundle` intentionally drops time_columns.
        let (s_prepared, _cpu_bus) =
            crate::memory_sidecar::cpu_bus::prepare_ccs_for_shared_cpu_bus_steps(s, &self.steps)?;
        Ok(s_prepared)
    }

    fn build_ccs_cache(
        &self,
        s: &CcsStructure<F>,
        ccs_sparse_cache: Option<Arc<SparseCache<F>>>,
    ) -> Result<SessionCcsCache, PiCcsError> {
        let src_ptr = (s as *const CcsStructure<F>) as usize;

        if let Some(ref cache) = ccs_sparse_cache {
            if cache.len() != s.t() {
                return Err(PiCcsError::InvalidInput(format!(
                    "SparseCache matrix count mismatch: cache has {}, CCS has {}",
                    cache.len(),
                    s.t()
                )));
            }
        }

        let ccs_sparse_cache = if let Some(cache) = ccs_sparse_cache {
            Some(cache)
        } else if shard::mode_uses_sparse_cache(&self.mode) {
            Some(Arc::new(SparseCache::build(s)))
        } else {
            None
        };

        let ccs_mat_digest = utils::digest_ccs_matrices_with_sparse_cache(s, ccs_sparse_cache.as_deref());
        let ctx = ShardProverContext {
            ccs_mat_digest,
            ccs_sparse_cache,
        };

        Ok(SessionCcsCache { src_ptr, ctx })
    }

    fn ensure_prover_ctx_for_ccs(&mut self, s: &CcsStructure<F>) -> Result<(), PiCcsError> {
        let src_ptr = (s as *const CcsStructure<F>) as usize;
        if let Some(cache) = &self.prover_ctx {
            if cache.src_ptr == src_ptr {
                return Ok(());
            }
        }
        eprintln!(
            "\x1b[33m[neo-fold] Cache miss: synthesizing circuit preprocessing (SparseCache + matrix digest).\x1b[0m"
        );
        eprintln!("\x1b[33m           This is a one-time cost per CCS structure. Subsequent runs with the same\x1b[0m");
        eprintln!("\x1b[33m           CCS pointer will reuse the cache and be faster.\x1b[0m");
        self.prover_ctx = Some(self.build_ccs_cache(s, None)?);
        Ok(())
    }

    /// Preload prover-side CCS preprocessing (sparse-cache + matrix-digest) to avoid scanning dense matrices.
    ///
    /// This is intended for callers who already have a `SparseCache` (e.g. built from sparse R1CS
    /// constraints) and want to skip the expensive `SparseCache::build` pass over dense matrices.
    ///
    /// Note: verification uses a separate cache; call `preload_verifier_ccs_sparse_cache(...)` if desired.
    pub fn preload_ccs_sparse_cache(
        &mut self,
        s: &CcsStructure<F>,
        ccs_sparse_cache: Arc<SparseCache<F>>,
    ) -> Result<(), PiCcsError> {
        self.prover_ctx = Some(self.build_ccs_cache(s, Some(ccs_sparse_cache))?);
        Ok(())
    }

    /// Preload verifier-side CCS preprocessing (sparse-cache + matrix-digest).
    ///
    /// This does **not** affect proving. It exists so benchmarks can model a verifier that
    /// preprocesses the public circuit independently of the prover.
    pub fn preload_verifier_ccs_sparse_cache(
        &mut self,
        s: &CcsStructure<F>,
        ccs_sparse_cache: Arc<SparseCache<F>>,
    ) -> Result<(), PiCcsError> {
        self.verifier_ctx = Some(self.build_ccs_cache(s, Some(ccs_sparse_cache))?);
        Ok(())
    }

    /// Fold and prove: run folding over all collected steps and return a `FoldRun`.
    /// This is where the actual cryptographic work happens (Π_CCS → RLC → DEC for each step).
    /// This method manages the transcript internally for ease of use.
    pub fn fold_and_prove(&mut self, s: &CcsStructure<F>) -> Result<FoldRun, PiCcsError> {
        let mut tr = Poseidon2Transcript::new(b"neo.fold/session");
        self.fold_and_prove_with_transcript(&mut tr, s)
    }

    /// Fold and prove with per-step proving timings (milliseconds).
    ///
    /// Returns `(run, step_prove_ms)` where `step_prove_ms[i]` is the time spent proving
    /// fold step `i` inside the shard prover.
    pub fn fold_and_prove_with_step_timings(&mut self, s: &CcsStructure<F>) -> Result<(FoldRun, Vec<f64>), PiCcsError> {
        let mut tr = Poseidon2Transcript::new(b"neo.fold/session");
        self.fold_and_prove_with_transcript_and_step_timings(&mut tr, s)
    }

    /// Fold and prove with a caller-provided transcript, returning per-step proving timings.
    pub fn fold_and_prove_with_transcript_and_step_timings(
        &mut self,
        tr: &mut Poseidon2Transcript,
        s: &CcsStructure<F>,
    ) -> Result<(FoldRun, Vec<f64>), PiCcsError> {
        self.ensure_prover_ctx_for_ccs(s)?;

        // Temporarily take the prover ctx to avoid borrow conflicts while we may mutate `self`.
        let cache = self.prover_ctx.take().expect("prover ctx must be set");
        let ctx = cache.ctx.clone();

        let result = (|| {
            self.ensure_steps_superneo_layout(s)?;

            // Shared CPU bus: compute the prepared CCS shape (copy-outs) for accumulator validation.
            let s_prepared = self.prepared_ccs_for_accumulator(s)?;
            self.ensure_accumulator_matches_ccs(s_prepared)?;

            // Determine canonical m_in from steps and ensure they all match (needed for RLC).
            let m_in_steps = self.steps.first().map(|step| step.mcs.0.m_in).unwrap_or(0);
            if !self.steps.iter().all(|step| step.mcs.0.m_in == m_in_steps) {
                return Err(PiCcsError::InvalidInput("all steps must share the same m_in".into()));
            }

            // Validate or default the accumulator: None → k=1 simple case (no ME inputs).
            let (seed_me, seed_me_wit): (&[CeClaim<Cmt, F, K>], &[Mat<F>]) = match &self.acc0 {
                Some(acc) => {
                    acc.check(&self.params, s_prepared)?;
                    // Also ensure accumulator m_in matches steps' m_in to avoid X-mixing shape issues.
                    let acc_m_in = acc.me.first().map(|m| m.m_in).unwrap_or(m_in_steps);
                    if acc_m_in != m_in_steps {
                        return Err(PiCcsError::InvalidInput(
                            "initial Accumulator.m_in must match steps' m_in".into(),
                        ));
                    }
                    (&acc.me, &acc.witnesses)
                }
                None => (&[], &[]), // k=1
            };

            // If PP is reloadable (seeded), unload it before memory-heavy oracle/sumcheck work.
            // This keeps peak RSS low on constrained runtimes (e.g. WASM).
            let m_commit = commit_cols_for_ccs_m(s.m);
            if has_seed_for_dims(D, m_commit) {
                let _ = unload_global_pp_for_dims(D, m_commit);
            }

            let start = time_now();
            let result = shard::fold_shard_prove_with_internal_options(
                self.mode.clone(),
                tr,
                &self.params,
                s,
                &self.steps,
                seed_me,
                seed_me_wit,
                &self.l,
                self.mixers,
                shard::ShardProveInternalOptions {
                    prover_ctx: Some(&ctx),
                    ..shard::ShardProveInternalOptions::default()
                },
            )?;
            let total_ms = elapsed_ms(start);
            let step_count = result.proof.steps.len();
            let step_prove_ms = if step_count == 0 {
                Vec::new()
            } else {
                vec![total_ms / (step_count as f64); step_count]
            };
            Ok((result.proof, step_prove_ms))
        })();

        self.prover_ctx = Some(cache);
        result
    }

    /// Convenience: fold, prove, and verify using the internally collected steps.
    ///
    /// This returns the proof run if verification succeeds.
    pub fn prove_and_verify_collected(&mut self, s: &CcsStructure<F>) -> Result<FoldRun, PiCcsError> {
        let run = self.fold_and_prove(s)?;
        let ok = self.verify_collected(s, &run)?;
        if !ok {
            return Err(PiCcsError::ProtocolError("verification failed".into()));
        }
        Ok(run)
    }

    /// Fold and prove with a caller-provided transcript (advanced users).
    /// This is where the actual cryptographic work happens (Π_CCS → RLC → DEC for each step).
    pub fn fold_and_prove_with_transcript(
        &mut self,
        tr: &mut Poseidon2Transcript,
        s: &CcsStructure<F>,
    ) -> Result<FoldRun, PiCcsError> {
        self.ensure_prover_ctx_for_ccs(s)?;

        // Temporarily take the prover ctx to avoid borrow conflicts while we may mutate `self`.
        let cache = self.prover_ctx.take().expect("prover ctx must be set");
        let ctx = cache.ctx.clone();

        let result = (|| {
            self.ensure_steps_superneo_layout(s)?;

            // Shared CPU bus: compute the prepared CCS shape (copy-outs) for accumulator validation.
            let s_prepared = self.prepared_ccs_for_accumulator(s)?;
            self.ensure_accumulator_matches_ccs(s_prepared)?;

            // Determine canonical m_in from steps and ensure they all match (needed for RLC).
            let m_in_steps = self.steps.first().map(|step| step.mcs.0.m_in).unwrap_or(0);
            if !self.steps.iter().all(|step| step.mcs.0.m_in == m_in_steps) {
                return Err(PiCcsError::InvalidInput("all steps must share the same m_in".into()));
            }

            // Validate or default the accumulator: None → k=1 simple case (no ME inputs).
            let (seed_me, seed_me_wit): (&[CeClaim<Cmt, F, K>], &[Mat<F>]) = match &self.acc0 {
                Some(acc) => {
                    acc.check(&self.params, s_prepared)?;
                    // Also ensure accumulator m_in matches steps' m_in to avoid X-mixing shape issues.
                    let acc_m_in = acc.me.first().map(|m| m.m_in).unwrap_or(m_in_steps);
                    if acc_m_in != m_in_steps {
                        return Err(PiCcsError::InvalidInput(
                            "initial Accumulator.m_in must match steps' m_in".into(),
                        ));
                    }
                    (&acc.me, &acc.witnesses)
                }
                None => (&[], &[]), // k=1
            };

            // If PP is reloadable (seeded), unload it before memory-heavy oracle/sumcheck work.
            // This keeps peak RSS low on constrained runtimes (e.g. WASM).
            let m_commit = commit_cols_for_ccs_m(s.m);
            if has_seed_for_dims(D, m_commit) {
                let _ = unload_global_pp_for_dims(D, m_commit);
            }

            shard::fold_shard_prove_with_internal_options(
                self.mode.clone(),
                tr,
                &self.params,
                s,
                &self.steps,
                seed_me,
                seed_me_wit,
                &self.l,
                self.mixers,
                shard::ShardProveInternalOptions {
                    prover_ctx: Some(&ctx),
                    ..shard::ShardProveInternalOptions::default()
                },
            )
            .map(|result| result.proof)
        })();

        self.prover_ctx = Some(cache);
        result
    }

    pub fn fold_and_prove_with_output_binding(
        &mut self,
        tr: &mut Poseidon2Transcript,
        s: &CcsStructure<F>,
        ob_cfg: &crate::output_binding::OutputBindingConfig,
        final_memory_state: &[F],
    ) -> Result<FoldRun, PiCcsError> {
        self.ensure_prover_ctx_for_ccs(s)?;

        let cache = self.prover_ctx.take().expect("prover ctx must be set");
        let ctx = cache.ctx.clone();

        let result = (|| {
            self.ensure_steps_superneo_layout(s)?;

            let s_prepared = self.prepared_ccs_for_accumulator(s)?;
            self.ensure_accumulator_matches_ccs(s_prepared)?;

            let m_in_steps = self.steps.first().map(|step| step.mcs.0.m_in).unwrap_or(0);
            if !self.steps.iter().all(|step| step.mcs.0.m_in == m_in_steps) {
                return Err(PiCcsError::InvalidInput("all steps must share the same m_in".into()));
            }

            let (seed_me, seed_me_wit): (&[CeClaim<Cmt, F, K>], &[Mat<F>]) = match &self.acc0 {
                Some(acc) => {
                    acc.check(&self.params, s_prepared)?;
                    let acc_m_in = acc.me.first().map(|m| m.m_in).unwrap_or(m_in_steps);
                    if acc_m_in != m_in_steps {
                        return Err(PiCcsError::InvalidInput(
                            "initial Accumulator.m_in must match steps' m_in".into(),
                        ));
                    }
                    (&acc.me, &acc.witnesses)
                }
                None => (&[], &[]),
            };

            shard::fold_shard_prove_with_internal_options(
                self.mode.clone(),
                tr,
                &self.params,
                s,
                &self.steps,
                seed_me,
                seed_me_wit,
                &self.l,
                self.mixers,
                shard::ShardProveInternalOptions {
                    output_binding: Some(shard::ShardOutputBindingInput {
                        config: ob_cfg,
                        final_memory_state,
                    }),
                    prover_ctx: Some(&ctx),
                    ..shard::ShardProveInternalOptions::default()
                },
            )
            .map(|result| result.proof)
        })();

        self.prover_ctx = Some(cache);
        result
    }

    /// Fold and prove with output binding, managing the transcript internally.
    pub fn fold_and_prove_with_output_binding_simple(
        &mut self,
        s: &CcsStructure<F>,
        ob_cfg: &crate::output_binding::OutputBindingConfig,
        final_memory_state: &[F],
    ) -> Result<FoldRun, PiCcsError> {
        let mut tr = Poseidon2Transcript::new(b"neo.fold/session");
        self.fold_and_prove_with_output_binding(&mut tr, s, ob_cfg, final_memory_state)
    }

    fn final_memory_state_for_output_binding(
        &self,
        ob_cfg: &crate::output_binding::OutputBindingConfig,
    ) -> Result<Vec<F>, PiCcsError> {
        let aux = self.shared_bus_aux.as_ref().ok_or_else(|| {
            PiCcsError::InvalidInput(
                "output binding auto mode requires shared-bus aux; call execute_shard_shared_cpu_bus(...) first".into(),
            )
        })?;
        let last_step = self
            .steps
            .last()
            .ok_or_else(|| PiCcsError::InvalidInput("output binding requires >= 1 step".into()))?;

        if ob_cfg.mem_idx >= last_step.mem_instances.len() {
            return Err(PiCcsError::InvalidInput("output binding mem_idx out of range".into()));
        }
        if ob_cfg.mem_idx >= aux.mem_ids.len() {
            return Err(PiCcsError::InvalidInput(
                "output binding mem_idx out of range for shared-bus aux".into(),
            ));
        }

        let expected_k = 1usize
            .checked_shl(ob_cfg.num_bits as u32)
            .ok_or_else(|| PiCcsError::InvalidInput("output binding: 2^num_bits overflow".into()))?;
        let mem_inst = &last_step.mem_instances[ob_cfg.mem_idx].0;
        if mem_inst.k != expected_k {
            return Err(PiCcsError::InvalidInput(format!(
                "output binding: cfg.num_bits implies k={}, but mem_inst.k={}",
                expected_k, mem_inst.k
            )));
        }
        if ob_cfg.num_bits > neo_memory::output_check::OUTPUT_SUMCHECK_MAX_NUM_BITS {
            // Sparse point-check path does not require a dense final memory vector.
            return Ok(Vec::new());
        }

        let mem_id = aux.mem_ids[ob_cfg.mem_idx];
        let mut final_memory_state = vec![F::ZERO; expected_k];
        if let Some(st) = aux.final_mem_states.get(&mem_id) {
            for (&addr, &val) in st {
                let Ok(addr_usize) = usize::try_from(addr) else {
                    continue;
                };
                if addr_usize < expected_k {
                    final_memory_state[addr_usize] = val;
                }
            }
        }
        Ok(final_memory_state)
    }

    /// Fold and prove with output binding, deriving `final_memory_state` from the most recent
    /// shared-CPU-bus witness build (see `execute_shard_shared_cpu_bus`).
    pub fn fold_and_prove_with_output_binding_auto(
        &mut self,
        tr: &mut Poseidon2Transcript,
        s: &CcsStructure<F>,
        ob_cfg: &crate::output_binding::OutputBindingConfig,
    ) -> Result<FoldRun, PiCcsError> {
        let final_memory_state = self.final_memory_state_for_output_binding(ob_cfg)?;
        self.fold_and_prove_with_output_binding(tr, s, ob_cfg, &final_memory_state)
    }

    /// Fold and prove with output binding (auto final memory state), managing the transcript internally.
    pub fn fold_and_prove_with_output_binding_auto_simple(
        &mut self,
        s: &CcsStructure<F>,
        ob_cfg: &crate::output_binding::OutputBindingConfig,
    ) -> Result<FoldRun, PiCcsError> {
        let mut tr = Poseidon2Transcript::new(b"neo.fold/session");
        self.fold_and_prove_with_output_binding_auto(&mut tr, s, ob_cfg)
    }

    /// Convenience: fold+prove with output binding (auto final memory) and verify (collected steps).
    ///
    /// This returns the proof run if verification succeeds.
    pub fn prove_and_verify_with_output_binding_collected_auto_simple(
        &mut self,
        s: &CcsStructure<F>,
        ob_cfg: &crate::output_binding::OutputBindingConfig,
    ) -> Result<FoldRun, PiCcsError> {
        let run = self.fold_and_prove_with_output_binding_auto_simple(s, ob_cfg)?;
        let ok = self.verify_with_output_binding_collected_simple(s, &run, ob_cfg)?;
        if !ok {
            return Err(PiCcsError::ProtocolError("verification failed".into()));
        }
        Ok(run)
    }

    /// Verify a finished run against the public MCS list.
    /// This method manages the transcript internally for ease of use.
    ///
    /// Note: this does not reuse prover-side preprocessing caches. To model a verifier that
    /// preprocesses the public circuit, call `preload_verifier_ccs_sparse_cache(...)` once.
    pub fn verify(
        &self,
        s: &CcsStructure<F>,
        mcss_public: &[neo_ccs::CcsClaim<Cmt, F>],
        run: &FoldRun,
    ) -> Result<bool, PiCcsError> {
        let mut tr = Poseidon2Transcript::new(b"neo.fold/session");
        self.verify_with_transcript(&mut tr, s, mcss_public, run)
    }

    /// Verify a finished run using the internally collected steps.
    /// Convenient when you don't want to manually extract the public MCS list.
    pub fn verify_collected(&self, s: &CcsStructure<F>, run: &FoldRun) -> Result<bool, PiCcsError> {
        let mcss_public = self.mcss_public();
        self.verify(s, &mcss_public, run)
    }

    /// Verify with a caller-provided transcript (advanced users).
    pub fn verify_with_transcript(
        &self,
        tr: &mut Poseidon2Transcript,
        s: &CcsStructure<F>,
        mcss_public: &[neo_ccs::CcsClaim<Cmt, F>],
        run: &FoldRun,
    ) -> Result<bool, PiCcsError> {
        let src_ptr = (s as *const CcsStructure<F>) as usize;
        let verifier_cache = self
            .verifier_ctx
            .as_ref()
            .filter(|cache| cache.src_ptr == src_ptr);
        let verifier_ctx = verifier_cache.map(|cache| &cache.ctx);

        // m_in consistency across public MCS
        let m_in_steps = mcss_public.first().map(|inst| inst.m_in).unwrap_or(0);
        if !mcss_public.iter().all(|inst| inst.m_in == m_in_steps) {
            return Err(PiCcsError::InvalidInput("all steps must share the same m_in".into()));
        }

        // Build steps_public from the internal bundles to include mem/lut instances.
        let steps_public: Vec<StepInstanceBundle<Cmt, F, K>> = self.steps.iter().map(|bundle| bundle.into()).collect();
        let s_prepared = self.prepared_ccs_for_accumulator(s)?;

        // Validate (or empty) initial accumulator to mirror finalize()
        let seed_me: &[CeClaim<Cmt, F, K>] = match &self.acc0 {
            Some(acc) => {
                acc.check(&self.params, s_prepared)?;
                let acc_m_in = acc.me.first().map(|m| m.m_in).unwrap_or(m_in_steps);
                if acc_m_in != m_in_steps {
                    return Err(PiCcsError::InvalidInput(
                        "initial Accumulator.m_in must match steps' m_in".into(),
                    ));
                }
                // ME inputs are already well-formed (checked by acc.check())
                &acc.me
            }
            None => &[], // k=1
        };

        let step_linking = self
            .step_linking
            .as_ref()
            .filter(|cfg| !cfg.prev_next_equalities.is_empty());

        let outputs = if steps_public.len() > 1 {
            match step_linking {
                Some(cfg) => match verifier_ctx {
                    Some(ctx) => shard::fold_shard_verify_with_internal_options(
                        self.mode.clone(),
                        tr,
                        &self.params,
                        s,
                        &steps_public,
                        seed_me,
                        run,
                        self.mixers,
                        shard::ShardVerifyInternalOptions {
                            step_linking: Some(cfg),
                            prover_ctx: Some(ctx),
                            ..shard::ShardVerifyInternalOptions::default()
                        },
                    )?,
                    None => shard::fold_shard_verify_with_options(
                        self.mode.clone(),
                        tr,
                        &self.params,
                        s,
                        &steps_public,
                        seed_me,
                        run,
                        self.mixers,
                        shard::ShardVerifyApiOptions {
                            step_linking: Some(cfg),
                            ..shard::ShardVerifyApiOptions::default()
                        },
                    )?,
                },
                None if self.allow_unlinked_steps => match verifier_ctx {
                    Some(ctx) => shard::fold_shard_verify_with_internal_options(
                        self.mode.clone(),
                        tr,
                        &self.params,
                        s,
                        &steps_public,
                        seed_me,
                        run,
                        self.mixers,
                        shard::ShardVerifyInternalOptions {
                            prover_ctx: Some(ctx),
                            ..shard::ShardVerifyInternalOptions::default()
                        },
                    )?,
                    None => shard::fold_shard_verify(
                        self.mode.clone(),
                        tr,
                        &self.params,
                        s,
                        &steps_public,
                        seed_me,
                        run,
                        self.mixers,
                    )?,
                },
                None => {
                    let mut msg =
                        "multi-step verification requires step linking; call FoldingSession::set_step_linking(...)"
                            .to_string();
                    if let Some(diag) = &self.auto_step_linking_error {
                        msg.push_str(&format!(" (auto step-linking from StepSpec failed: {diag})"));
                    }
                    return Err(PiCcsError::InvalidInput(msg));
                }
            }
        } else {
            match verifier_ctx {
                Some(ctx) => shard::fold_shard_verify_with_internal_options(
                    self.mode.clone(),
                    tr,
                    &self.params,
                    s,
                    &steps_public,
                    seed_me,
                    run,
                    self.mixers,
                    shard::ShardVerifyInternalOptions {
                        prover_ctx: Some(ctx),
                        ..shard::ShardVerifyInternalOptions::default()
                    },
                )?,
                None => shard::fold_shard_verify(
                    self.mode.clone(),
                    tr,
                    &self.params,
                    s,
                    &steps_public,
                    seed_me,
                    run,
                    self.mixers,
                )?,
            }
        };

        // Val-lane obligations are expected when the session carries any sidecar val lane:
        // Twist/Shout folds, or booleanity/trace-opening folds over RV32 trace openings.
        let has_twist_or_shout = self.has_twist_instances() || self.has_shout_instances();
        let has_trace_opening_sidecars = run.steps.iter().any(|step| {
            !step.mem.booleanity_me_claims.is_empty()
                || !step.mem.trace_opening_me_claims.is_empty()
                || !step.booleanity_fold.is_empty()
                || !step.trace_opening_fold.is_empty()
                || !step.joint_opening_fold.is_empty()
        });
        if !(has_twist_or_shout || has_trace_opening_sidecars) && !outputs.obligations.val.is_empty() {
            return Err(PiCcsError::ProtocolError(
                "CCS-only session verification produced unexpected val-lane obligations".into(),
            ));
        }
        Ok(true)
    }

    /// Verify with output binding, managing the transcript internally.
    pub fn verify_with_output_binding_simple(
        &self,
        s: &CcsStructure<F>,
        mcss_public: &[neo_ccs::CcsClaim<Cmt, F>],
        run: &FoldRun,
        ob_cfg: &crate::output_binding::OutputBindingConfig,
    ) -> Result<bool, PiCcsError> {
        let mut tr = Poseidon2Transcript::new(b"neo.fold/session");
        self.verify_with_output_binding(&mut tr, s, mcss_public, run, ob_cfg)
    }

    /// Verify with output binding using the internally collected steps (and public MCS list).
    pub fn verify_with_output_binding_collected_simple(
        &self,
        s: &CcsStructure<F>,
        run: &FoldRun,
        ob_cfg: &crate::output_binding::OutputBindingConfig,
    ) -> Result<bool, PiCcsError> {
        let mcss_public = self.mcss_public();
        self.verify_with_output_binding_simple(s, &mcss_public, run, ob_cfg)
    }

    pub fn verify_with_output_binding(
        &self,
        tr: &mut Poseidon2Transcript,
        s: &CcsStructure<F>,
        mcss_public: &[neo_ccs::CcsClaim<Cmt, F>],
        run: &FoldRun,
        ob_cfg: &crate::output_binding::OutputBindingConfig,
    ) -> Result<bool, PiCcsError> {
        let src_ptr = (s as *const CcsStructure<F>) as usize;
        let verifier_cache = self
            .verifier_ctx
            .as_ref()
            .filter(|cache| cache.src_ptr == src_ptr);
        let verifier_ctx = verifier_cache.map(|cache| &cache.ctx);

        let m_in_steps = mcss_public.first().map(|inst| inst.m_in).unwrap_or(0);
        if !mcss_public.iter().all(|inst| inst.m_in == m_in_steps) {
            return Err(PiCcsError::InvalidInput("all steps must share the same m_in".into()));
        }

        let steps_public: Vec<StepInstanceBundle<Cmt, F, K>> = self.steps.iter().map(|bundle| bundle.into()).collect();
        let s_prepared = self.prepared_ccs_for_accumulator(s)?;

        let seed_me: &[CeClaim<Cmt, F, K>] = match &self.acc0 {
            Some(acc) => {
                acc.check(&self.params, s_prepared)?;
                let acc_m_in = acc.me.first().map(|m| m.m_in).unwrap_or(m_in_steps);
                if acc_m_in != m_in_steps {
                    return Err(PiCcsError::InvalidInput(
                        "initial Accumulator.m_in must match steps' m_in".into(),
                    ));
                }
                &acc.me
            }
            None => &[],
        };

        let step_linking = self
            .step_linking
            .as_ref()
            .filter(|cfg| !cfg.prev_next_equalities.is_empty());

        let outputs = if steps_public.len() > 1 {
            match step_linking {
                Some(cfg) => match verifier_ctx {
                    Some(ctx) => shard::fold_shard_verify_with_internal_options(
                        self.mode.clone(),
                        tr,
                        &self.params,
                        s,
                        &steps_public,
                        seed_me,
                        run,
                        self.mixers,
                        shard::ShardVerifyInternalOptions {
                            step_linking: Some(cfg),
                            output_binding: Some(ob_cfg),
                            prover_ctx: Some(ctx),
                            ..shard::ShardVerifyInternalOptions::default()
                        },
                    )?,
                    None => shard::fold_shard_verify_with_options(
                        self.mode.clone(),
                        tr,
                        &self.params,
                        s,
                        &steps_public,
                        seed_me,
                        run,
                        self.mixers,
                        shard::ShardVerifyApiOptions {
                            step_linking: Some(cfg),
                            output_binding: Some(ob_cfg),
                            ..shard::ShardVerifyApiOptions::default()
                        },
                    )?,
                },
                None if self.allow_unlinked_steps => match verifier_ctx {
                    Some(ctx) => shard::fold_shard_verify_with_internal_options(
                        self.mode.clone(),
                        tr,
                        &self.params,
                        s,
                        &steps_public,
                        seed_me,
                        run,
                        self.mixers,
                        shard::ShardVerifyInternalOptions {
                            output_binding: Some(ob_cfg),
                            prover_ctx: Some(ctx),
                            ..shard::ShardVerifyInternalOptions::default()
                        },
                    )?,
                    None => shard::fold_shard_verify_with_options(
                        self.mode.clone(),
                        tr,
                        &self.params,
                        s,
                        &steps_public,
                        seed_me,
                        run,
                        self.mixers,
                        shard::ShardVerifyApiOptions {
                            output_binding: Some(ob_cfg),
                            ..shard::ShardVerifyApiOptions::default()
                        },
                    )?,
                },
                None => {
                    let mut msg =
                        "multi-step verification requires step linking; call FoldingSession::set_step_linking(...)"
                            .to_string();
                    if let Some(diag) = &self.auto_step_linking_error {
                        msg.push_str(&format!(" (auto step-linking from StepSpec failed: {diag})"));
                    }
                    return Err(PiCcsError::InvalidInput(msg));
                }
            }
        } else {
            match verifier_ctx {
                Some(ctx) => shard::fold_shard_verify_with_internal_options(
                    self.mode.clone(),
                    tr,
                    &self.params,
                    s,
                    &steps_public,
                    seed_me,
                    run,
                    self.mixers,
                    shard::ShardVerifyInternalOptions {
                        output_binding: Some(ob_cfg),
                        prover_ctx: Some(ctx),
                        ..shard::ShardVerifyInternalOptions::default()
                    },
                )?,
                None => shard::fold_shard_verify_with_options(
                    self.mode.clone(),
                    tr,
                    &self.params,
                    s,
                    &steps_public,
                    seed_me,
                    run,
                    self.mixers,
                    shard::ShardVerifyApiOptions {
                        output_binding: Some(ob_cfg),
                        ..shard::ShardVerifyApiOptions::default()
                    },
                )?,
            }
        };

        let has_twist_or_shout = self.has_twist_instances() || self.has_shout_instances();
        let has_trace_opening_sidecars = run.steps.iter().any(|step| {
            !step.mem.booleanity_me_claims.is_empty()
                || !step.mem.trace_opening_me_claims.is_empty()
                || !step.booleanity_fold.is_empty()
                || !step.trace_opening_fold.is_empty()
                || !step.joint_opening_fold.is_empty()
        });
        if !(has_twist_or_shout || has_trace_opening_sidecars) && !outputs.obligations.val.is_empty() {
            return Err(PiCcsError::ProtocolError(
                "CCS-only session verification produced unexpected val-lane obligations".into(),
            ));
        }

        Ok(true)
    }
}
