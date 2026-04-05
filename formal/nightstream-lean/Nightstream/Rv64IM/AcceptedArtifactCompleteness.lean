import Nightstream.Rv64IM.Generated.AcceptedProofArtifactCorpus
import Nightstream.Rv64IM.AcceptedArtifactKernelSurface
import Nightstream.Rv64IM.AcceptedArtifactKernelReplay
import Nightstream.Rv64IM.AcceptedArtifactLocalTrace
import Nightstream.Rv64IM.AcceptedArtifactTemporalReplay
import Nightstream.Rv64IM.AcceptedArtifactStage3Refinement
import Nightstream.Rv64IM.AcceptedArtifactStepComposition
import Nightstream.Rv64IM.AcceptedArtifactSoundnessAccounting
import Nightstream.Rv64IM.AcceptedArtifactRootLane
import Nightstream.Rv64IM.AcceptedArtifactChecks
import Nightstream.Rv64IM.Checks
import Nightstream.Rv64IM.Kernel.PublicProofProjection
import Nightstream.Rv64IM.Execution.ExecutionSemantics
import Nightstream.Rv64IM.Stage3.ContinuityBridge

/-!
Owns the Lean-side completeness audit for the exported RV64IM accepted-artifact
view. This owner does not check digest parity; it checks whether the current
export layer is rich enough for Lean to reconstruct the exact theorem-facing
kernel boundary without trusting Rust-assembled summaries.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated

inductive AcceptedArtifactTheoremField where
  | sourceCase
  | executionRows
  | transcriptEvents
  | traceChunkInput
  | mainLaneBoundary
  | traceLinkBoundary
  | stepCompositionProof
  | temporalConsistency
  | stage2Closure
  | stage3Refinement
  | kernelProofBundle
  | soundnessAccounting
  | preparedStepExports
  | fullRootLaneRows
  | fullStage3RowBindings
  | root0Bindings
  | programBindingInputs
  | kernelOpeningWitnesses
  | exactOpeningWitnesses
  | bridgeProvenanceChains
deriving DecidableEq, Repr

def acceptedArtifactTheoremFieldName : AcceptedArtifactTheoremField → String
  | .sourceCase => "source_case"
  | .executionRows => "execution_rows"
  | .transcriptEvents => "transcript_events"
  | .traceChunkInput => "trace_chunk_input"
  | .mainLaneBoundary => "main_lane_boundary"
  | .traceLinkBoundary => "trace_link_boundary"
  | .stepCompositionProof => "step_composition_proof"
  | .temporalConsistency => "temporal_consistency"
  | .stage2Closure => "stage2_closure"
  | .stage3Refinement => "stage3_refinement"
  | .kernelProofBundle => "kernel_proof_bundle"
  | .soundnessAccounting => "soundness_accounting"
  | .preparedStepExports => "prepared_step_exports"
  | .fullRootLaneRows => "full_root_lane_rows"
  | .fullStage3RowBindings => "full_stage3_row_bindings"
  | .root0Bindings => "root0_bindings"
  | .programBindingInputs => "program_binding_inputs"
  | .kernelOpeningWitnesses => "kernel_opening_witnesses"
  | .exactOpeningWitnesses => "exact_opening_witnesses"
  | .bridgeProvenanceChains => "bridge_provenance_chains"

def requiredAcceptedArtifactTheoremFields : List AcceptedArtifactTheoremField :=
  [ .sourceCase
  , .executionRows
  , .transcriptEvents
  , .traceChunkInput
  , .mainLaneBoundary
  , .traceLinkBoundary
  , .stepCompositionProof
  , .temporalConsistency
  , .stage2Closure
  , .stage3Refinement
  , .kernelProofBundle
  , .soundnessAccounting
  , .preparedStepExports
  , .fullRootLaneRows
  , .fullStage3RowBindings
  , .root0Bindings
  , .programBindingInputs
  , .kernelOpeningWitnesses
  , .exactOpeningWitnesses
  , .bridgeProvenanceChains
  ]

private def replayedDerivedCaseOfArtifact?
    (artifact : AcceptedProofArtifactView) : Option ParityDerivedCase :=
  recomputeDerivedCase? artifact.source

private def sourceCasePresent (artifact : AcceptedProofArtifactView) : Bool :=
  !artifact.source.programWords.isEmpty &&
    !artifact.source.initialRegisters.isEmpty

private def executionRowsPresent (artifact : AcceptedProofArtifactView) : Bool :=
  match replayedDerivedCaseOfArtifact? artifact with
  | some derived => !derived.executionRows.isEmpty
  | none => false

private def transcriptEventsPresent (artifact : AcceptedProofArtifactView) : Bool :=
  !artifact.transcript.events.isEmpty

private def mainLaneProofPresent (artifact : AcceptedProofArtifactView) : Bool :=
  artifact.kernelProof.mainLane.binding.rootLaneColumnsDigest ≠ [] &&
    artifact.kernelProof.mainLane.binding.rootLaneCommitmentDigest ≠ [] &&
    artifact.kernelProof.mainLane.statementDigest ≠ [] &&
    artifact.kernelProof.mainLane.proofDigest ≠ [] &&
    artifact.kernelProof.mainLane.digest ≠ []

private def stagePackageProofsPresent (artifact : AcceptedProofArtifactView) : Bool :=
  artifact.kernelProof.stagePackages.summary.packageBundleDigest ≠ [] &&
    artifact.kernelProof.stagePackages.summary.stage1Digest ≠ [] &&
    artifact.kernelProof.stagePackages.summary.stage2Digest ≠ [] &&
    artifact.kernelProof.stagePackages.summary.stage3Digest ≠ [] &&
    artifact.kernelProof.stagePackages.summary.digest ≠ [] &&
    artifact.kernelProof.stagePackages.digest ≠ []

private def stageClaimProofPresent (artifact : AcceptedProofArtifactView) : Bool :=
  artifact.kernelProof.stageClaims.summary.claimBundleDigest ≠ [] &&
    artifact.kernelProof.stageClaims.summary.stage1Digest ≠ [] &&
    artifact.kernelProof.stageClaims.summary.stage2Digest ≠ [] &&
    artifact.kernelProof.stageClaims.summary.stage3Digest ≠ [] &&
    artifact.kernelProof.stageClaims.summary.transcriptDigest ≠ [] &&
    artifact.kernelProof.stageClaims.summary.executionDigest ≠ [] &&
    artifact.kernelProof.stageClaims.summary.digest ≠ [] &&
    artifact.kernelProof.stageClaims.statementDigest ≠ [] &&
    artifact.kernelProof.stageClaims.proofDigest ≠ [] &&
    artifact.kernelProof.stageClaims.digest ≠ []

private def kernelClaimProofPresent (artifact : AcceptedProofArtifactView) : Bool :=
  artifact.kernelProof.kernelClaims.summary.preparedStepBindingsDigest ≠ [] &&
    artifact.kernelProof.kernelClaims.summary.terminal.root0Digest ≠ [] &&
    artifact.kernelProof.kernelClaims.summary.terminal.executionDigest ≠ [] &&
    artifact.kernelProof.kernelClaims.summary.terminal.finalStateDigest ≠ [] &&
    artifact.kernelProof.kernelClaims.summary.terminal.transcriptFinalDigest ≠ [] &&
    artifact.kernelProof.kernelClaims.summary.terminal.digest ≠ [] &&
    artifact.kernelProof.kernelClaims.summary.digest ≠ [] &&
    artifact.kernelProof.kernelClaims.statementDigest ≠ [] &&
    artifact.kernelProof.kernelClaims.proofDigest ≠ [] &&
    artifact.kernelProof.kernelClaims.digest ≠ []

private def root0ClaimPresent (artifact : AcceptedProofArtifactView) : Bool :=
  artifact.exportedClaims.root0.rootParamsId ≠ [] &&
    artifact.exportedClaims.root0.stages.stage1Digest ≠ [] &&
    artifact.exportedClaims.root0.stages.stage2Digest ≠ [] &&
    artifact.exportedClaims.root0.stages.stage3Digest ≠ [] &&
    artifact.exportedClaims.root0.stages.digest ≠ [] &&
    artifact.exportedClaims.root0.terminal.root0Digest ≠ [] &&
    artifact.exportedClaims.root0.terminal.executionDigest ≠ [] &&
    artifact.exportedClaims.root0.terminal.finalStateDigest ≠ [] &&
    artifact.exportedClaims.root0.terminal.transcriptFinalDigest ≠ [] &&
    artifact.exportedClaims.root0.terminal.digest ≠ [] &&
    artifact.exportedClaims.root0.digest ≠ []

private def programBindingInputsPresent (artifact : AcceptedProofArtifactView) : Bool :=
  sourceCasePresent artifact &&
    artifact.exportedStatement.rootParamsId ≠ [] &&
    artifact.exportedStatement.initialPc = artifact.source.startPc

private def kernelOpeningWitnessBundlePresent
    (artifact : AcceptedProofArtifactView) : Bool :=
  artifact.kernelProof.kernelOpening.openingDigest ≠ [] &&
    artifact.kernelProof.kernelOpening.bindings.claimDigest ≠ [] &&
    artifact.kernelProof.kernelOpening.bindings.bindingsDigest ≠ [] &&
    artifact.kernelProof.kernelOpening.bindings.preparedStepsDigest ≠ [] &&
    artifact.kernelProof.kernelOpening.digest ≠ [] &&
    artifact.kernelOpeningBundle.digest ≠ []

private def preparedStepExportsPresent
    (artifact : AcceptedProofArtifactView) : Bool :=
  let recomputedLocalTrace := recomputeLocalTraceView artifact
  let recomputedRootLane := recomputeRootLaneView artifact.derived.executionRows
  !recomputedLocalTrace.mainLane.preparedSteps.isEmpty &&
    recomputedMainLaneBoundaryMatchesArtifact recomputedLocalTrace artifact &&
    recomputedPreparedStepBindingsMatchArtifact recomputedRootLane artifact

private def stage3RowBindingsPresent
    (artifact : AcceptedProofArtifactView) : Bool :=
  let recomputedLocalTrace := recomputeLocalTraceView artifact
  !recomputedLocalTrace.rowBindings.isEmpty &&
    recomputedStage3RowBindingsMatchArtifact recomputedLocalTrace artifact

private def recoveredTemporalReplayPresent
    (artifact : AcceptedProofArtifactView) : Bool :=
  match recoverTemporalReplay? artifact with
  | some recovered => recoveredTemporalReplayMatchesArtifact recovered artifact
  | none => false

private def fullRootLaneRowsPresent
    (artifact : AcceptedProofArtifactView) : Bool :=
  match replayedDerivedCaseOfArtifact? artifact with
  | some derived =>
      let recomputedRootLane := recomputeRootLaneView derived.executionRows
      !derived.executionRows.isEmpty &&
        recomputedRootLaneProtocolBindingsMatchArtifact recomputedRootLane artifact
  | none => false

private def exactOpeningWitnessesPresent
    (artifact : AcceptedProofArtifactView) : Bool :=
  let opening := artifact.kernelOpeningBundle
  opening.digest ≠ [] &&
    opening.digest = artifact.kernelProof.kernelOpening.openingDigest &&
    opening.claim.digest = artifact.kernelProof.kernelOpening.bindings.claimDigest &&
    opening.bindings.digest = artifact.kernelProof.kernelOpening.bindings.bindingsDigest &&
    opening.preparedSteps.digest =
      artifact.kernelProof.kernelOpening.bindings.preparedStepsDigest &&
    opening.bindings.claim = opening.claim.bindings &&
    opening.preparedSteps.claim = opening.claim.preparedSteps &&
    opening.bindings.packaged.statementDigest ≠ [] &&
    opening.bindings.packaged.proofDigest ≠ [] &&
    opening.preparedSteps.packaged.statementDigest ≠ [] &&
    opening.preparedSteps.packaged.proofDigest ≠ [] &&
    opening.claim.bindings.bindingCount =
      artifact.rootExecution.preparedStepBindings.bindingCount &&
    opening.claim.preparedSteps.preparedStepCount =
      artifact.rootExecution.preparedStepBindings.bindingCount &&
    opening.claim.bindings.preparedStepBindingsDigest =
      artifact.rootExecution.preparedStepBindings.digest &&
    opening.claim.preparedSteps.executionDigest =
      artifact.exportedStatement.executionDigest &&
    opening.claim.preparedSteps.finalStateDigest =
      artifact.exportedStatement.finalStateDigest &&
    opening.claim.preparedSteps.transcriptFinalDigest =
      artifact.exportedStatement.transcriptFinalDigest &&
    opening.claim.preparedSteps.finalPc = artifact.exportedStatement.finalPc &&
    opening.claim.preparedSteps.halted = artifact.exportedStatement.halted

private def root0BindingsPresent
    (artifact : AcceptedProofArtifactView) : Bool :=
  root0ClaimPresent artifact

private def bridgeProvenanceChainsPresent
    (artifact : AcceptedProofArtifactView) : Bool :=
  let opening := artifact.kernelOpeningBundle
  opening.digest ≠ [] &&
    opening.claim.bindings.stageClaimBundleDigest =
      artifact.kernelProof.stageClaims.summary.claimBundleDigest &&
    opening.claim.bindings.stagePackageBundleDigest =
      artifact.kernelProof.stagePackages.summary.packageBundleDigest &&
    opening.claim.bindings.stage1PackageDigest =
      artifact.kernelProof.stagePackages.summary.stage1Digest &&
    opening.claim.bindings.stage2PackageDigest =
      artifact.kernelProof.stagePackages.summary.stage2Digest &&
    opening.claim.bindings.stage3PackageDigest =
      artifact.kernelProof.stagePackages.summary.stage3Digest &&
    artifact.kernelProof.stagePackages.summary.stage1Digest =
      artifact.stage1.selectedOpening.digest &&
    artifact.kernelProof.stagePackages.summary.stage2Digest =
      artifact.stage2.selectedOpening.digest &&
    artifact.kernelProof.stagePackages.summary.stage3Digest =
      artifact.stage3.selectedOpening.digest &&
    opening.claim.bindings.preparedStepBindingsDigest =
      artifact.rootExecution.preparedStepBindings.digest &&
    opening.claim.bindings.stage1RowCount = artifact.stage1.rowBindings.length &&
    opening.claim.bindings.stage2RegisterReadCount =
      artifact.stage2.registerReads.length &&
    opening.claim.bindings.stage2RegisterWriteCount =
      artifact.stage2.registerWrites.length &&
    opening.claim.bindings.stage2RamEventCount = artifact.stage2.ramEvents.length &&
    opening.claim.bindings.stage3ContinuityCount = artifact.stage3.continuity.length

private def soundnessAccountingPresent
    (artifact : AcceptedProofArtifactView) : Bool :=
  soundnessAccountingSurfaceMatchesCanonical artifact.soundnessAccounting

private def acceptedArtifactTheoremFieldPresentCached
    (artifact : AcceptedProofArtifactView)
    (replayedDerivedCase : Option ParityDerivedCase)
    (field : AcceptedArtifactTheoremField) : Bool :=
  let executionRowsPresent :=
    match replayedDerivedCase with
    | some derived => !derived.executionRows.isEmpty
    | none => false
  let recomputedKernelSurface := recomputeKernelSurfaceView artifact
  let recomputedLocalTrace := recomputeLocalTraceView artifact
  let recoveredTemporalReplay := recoverTemporalReplay? artifact
  let recoveredStage3Refinement := recoverStage3Refinement? artifact
  let transcriptEventsPresent := !artifact.transcript.events.isEmpty
  let preparedStepExportsPresent :=
    let recomputedRootLane := recomputeRootLaneView artifact.derived.executionRows
    !recomputedLocalTrace.mainLane.preparedSteps.isEmpty &&
      recomputedMainLaneBoundaryMatchesArtifact recomputedLocalTrace artifact &&
      recomputedPreparedStepBindingsMatchArtifact recomputedRootLane artifact
  let stage3RowBindingsPresent :=
    !recomputedLocalTrace.rowBindings.isEmpty &&
      recomputedStage3RowBindingsMatchArtifact recomputedLocalTrace artifact
  let fullRootLaneRowsPresent :=
    match replayedDerivedCase with
    | some derived =>
        let recomputedRootLane := recomputeRootLaneView derived.executionRows
        !derived.executionRows.isEmpty &&
          recomputedRootLaneProtocolBindingsMatchArtifact recomputedRootLane artifact
    | none => false
  let exactOpeningWitnessesPresentNow := exactOpeningWitnessesPresent artifact
  let root0BindingsPresent := root0ClaimPresent artifact
  let bridgeProvenanceChainsPresentNow := bridgeProvenanceChainsPresent artifact
  let recomputedStepComposition := recomputeStepCompositionSurfaceView artifact
  let soundnessAccountingPresent :=
    soundnessAccountingSurfaceMatchesCanonical artifact.soundnessAccounting
  match field with
  | .sourceCase => sourceCasePresent artifact
  | .executionRows => executionRowsPresent
  | .transcriptEvents => transcriptEventsPresent
  | .traceChunkInput =>
      sourceCasePresent artifact &&
        executionRowsPresent &&
        recomputedChunkInputMatchesArtifact recomputedLocalTrace artifact &&
        recomputedTraceProjectionMatchesArtifact recomputedKernelSurface artifact
  | .mainLaneBoundary =>
      executionRowsPresent &&
        recomputedMainLaneBoundaryMatchesArtifact recomputedLocalTrace artifact
  | .traceLinkBoundary =>
      executionRowsPresent &&
        recomputedTraceLinkBoundaryMatchesArtifact recomputedLocalTrace artifact &&
        recomputedStageWitnessProjectionMatchesArtifact recomputedKernelSurface artifact
  | .stepCompositionProof =>
      recomputedStepCompositionSurfaceMatchesArtifact recomputedStepComposition artifact
  | .temporalConsistency =>
      match recoveredTemporalReplay with
      | some recovered =>
          recoveredTemporalReplayMatchesArtifact recovered artifact
      | none => false
  | .stage2Closure =>
      match recoveredTemporalReplay with
      | some recovered =>
          recoveredTemporalReplayMatchesArtifact recovered artifact
      | none => false
  | .stage3Refinement =>
      match recoveredStage3Refinement with
      | some recovered =>
          recoveredStage3RefinementMatchesArtifact recovered artifact
      | none => false
  | .kernelProofBundle => artifact.kernelProof.digest ≠ []
  | .soundnessAccounting => soundnessAccountingPresent
  | .preparedStepExports => preparedStepExportsPresent
  | .fullRootLaneRows => fullRootLaneRowsPresent
  | .fullStage3RowBindings => stage3RowBindingsPresent
  | .root0Bindings => root0BindingsPresent
  | .programBindingInputs => programBindingInputsPresent artifact
  | .kernelOpeningWitnesses => kernelOpeningWitnessBundlePresent artifact
  | .exactOpeningWitnesses => exactOpeningWitnessesPresentNow
  | .bridgeProvenanceChains => bridgeProvenanceChainsPresentNow

def acceptedArtifactTheoremFieldPresent
    (artifact : AcceptedProofArtifactView)
    (field : AcceptedArtifactTheoremField) : Bool :=
  acceptedArtifactTheoremFieldPresentCached
    artifact
    (replayedDerivedCaseOfArtifact? artifact)
    field

def acceptedArtifactTheoremCompletenessChecks
    (artifact : AcceptedProofArtifactView) : List (String × Bool) :=
  let replayedDerivedCase := replayedDerivedCaseOfArtifact? artifact
  requiredAcceptedArtifactTheoremFields.map fun field =>
    (acceptedArtifactTheoremFieldName field,
      acceptedArtifactTheoremFieldPresentCached
        artifact
        replayedDerivedCase
        field)

def theoremCompleteAcceptedArtifact (artifact : AcceptedProofArtifactView) : Bool :=
  (acceptedArtifactTheoremCompletenessChecks artifact).all Prod.snd

def missingAcceptedArtifactTheoremFields
    (artifact : AcceptedProofArtifactView) : List String :=
  (acceptedArtifactTheoremCompletenessChecks artifact).filterMap fun (name, ok) =>
    if ok then none else some name

structure Rv64imAcceptedArtifactCompletenessReport where
  name : String
  checks : List (String × Bool)
  missingFields : List String
deriving Repr

def rv64imAcceptedArtifactCompletenessChecks : List Bool :=
  Generated.AcceptedProofArtifacts.cases.map theoremCompleteAcceptedArtifact

def validGeneratedRv64imAcceptedArtifactCompletenessCases : Bool :=
  Generated.AcceptedProofArtifacts.cases.all theoremCompleteAcceptedArtifact

def rv64imAcceptedArtifactCompletenessReports :
    List Rv64imAcceptedArtifactCompletenessReport :=
  Generated.AcceptedProofArtifacts.cases.map fun artifact =>
    { name := artifact.name
    , checks := acceptedArtifactTheoremCompletenessChecks artifact
    , missingFields := missingAcceptedArtifactTheoremFields artifact
    }

end Nightstream.Rv64IM
