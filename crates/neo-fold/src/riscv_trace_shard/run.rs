use super::*;

/// Completed trace-wiring proof run.
pub struct Rv32TraceWiringRun {
    pub(super) session: FoldingSession<AjtaiSModule>,
    pub(super) ccs: CcsStructure<F>,
    pub(super) layout: Rv32TraceCcsLayout,
    pub(super) exec: Rv32ExecTable,
    pub(super) proof: ShardProof,
    pub(super) used_mem_ids: Vec<u32>,
    pub(super) used_shout_table_ids: Vec<u32>,
    pub(super) output_binding_cfg: Option<OutputBindingConfig>,
    pub(super) prove_duration: Duration,
    pub(super) prove_phase_durations: Rv32TraceProvePhaseDurations,
    pub(super) verify_duration: Option<Duration>,
}

impl Rv32TraceWiringRun {
    pub fn params(&self) -> &NeoParams {
        self.session.params()
    }

    pub fn committer(&self) -> &AjtaiSModule {
        self.session.committer()
    }

    pub fn ccs(&self) -> &CcsStructure<F> {
        &self.ccs
    }

    pub fn layout(&self) -> &Rv32TraceCcsLayout {
        &self.layout
    }

    pub fn exec_table(&self) -> &Rv32ExecTable {
        &self.exec
    }

    pub fn proof(&self) -> &ShardProof {
        &self.proof
    }

    /// Auto-derived memory sidecar IDs used by this run (`S_memory`).
    pub fn used_memory_ids(&self) -> &[u32] {
        &self.used_mem_ids
    }

    /// Auto-derived shout lookup table IDs used by this run (`S_lookup`).
    pub fn used_shout_table_ids(&self) -> &[u32] {
        &self.used_shout_table_ids
    }

    pub fn verify_proof(&self, proof: &ShardProof) -> Result<(), PiCcsError> {
        let ok = match &self.output_binding_cfg {
            None => self.session.verify_collected(&self.ccs, proof)?,
            Some(cfg) => self
                .session
                .verify_with_output_binding_collected_simple(&self.ccs, proof, cfg)?,
        };
        if !ok {
            return Err(PiCcsError::ProtocolError("verification failed".into()));
        }
        Ok(())
    }

    pub fn verify(&mut self) -> Result<(), PiCcsError> {
        let verify_start = time_now();
        self.verify_proof(&self.proof)?;
        self.verify_duration = Some(elapsed_duration(verify_start));
        Ok(())
    }

    pub fn ccs_num_constraints(&self) -> usize {
        self.ccs.n
    }

    pub fn ccs_num_variables(&self) -> usize {
        self.ccs.m
    }

    /// Number of real (active) rows in the unpadded trace.
    pub fn trace_len(&self) -> usize {
        self.exec.rows.iter().filter(|r| r.active).count()
    }

    /// Number of collected folding steps.
    pub fn fold_count(&self) -> usize {
        self.proof.steps.len()
    }

    pub fn prove_duration(&self) -> Duration {
        self.prove_duration
    }

    pub fn prove_phase_durations(&self) -> Rv32TraceProvePhaseDurations {
        self.prove_phase_durations
    }

    pub fn verify_duration(&self) -> Option<Duration> {
        self.verify_duration
    }

    pub fn steps_public(&self) -> Vec<neo_memory::witness::StepInstanceBundle<neo_ajtai::Commitment, F, K>> {
        self.session.steps_public()
    }
}
