import Nightstream.Rv64IM.Generated.AcceptedProofArtifactCorpus
import Nightstream.Rv64IM.AcceptedArtifactRootLane
import Nightstream.Rv64IM.AcceptedArtifactChecks
import Nightstream.Rv64IM.Checks
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
  | traceLinkBoundary
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
  | .traceLinkBoundary => "trace_link_boundary"
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
  , .traceLinkBoundary
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
  match replayedDerivedCaseOfArtifact? artifact with
  | some derived => !derived.transcript.events.isEmpty
  | none => false

private def proofLedAcceptedArtifactPresent (artifact : AcceptedProofArtifactView) : Bool :=
  checkAcceptedArtifactCase artifact

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
  !artifact.source.programWords.isEmpty &&
    !artifact.source.manifest.fixtureId.isEmpty

private def kernelOpeningWitnessBundlePresent
    (artifact : AcceptedProofArtifactView) : Bool :=
  artifact.kernelProof.kernelOpening.openingDigest ≠ [] &&
    artifact.kernelProof.kernelOpening.bindings.claimDigest ≠ [] &&
    artifact.kernelProof.kernelOpening.bindings.bindingsDigest ≠ [] &&
    artifact.kernelProof.kernelOpening.bindings.preparedStepsDigest ≠ [] &&
    artifact.kernelProof.kernelOpening.bindings.digest ≠ [] &&
    artifact.kernelProof.kernelOpening.digest ≠ []

private def listEnumFrom : Nat → List α → List (Nat × α)
  | _, [] => []
  | rowIndex, row :: rows => (rowIndex, row) :: listEnumFrom (rowIndex + 1) rows

private def listEnum (rows : List α) : List (Nat × α) :=
  listEnumFrom 0 rows

private def preparedStepOfExecutionRow
    (rowIndex : Nat)
    (row : ExpandedRowView) : PreparedStepView Nat :=
  { rowIndex := rowIndex
  , pc := row.pc
  , advanceArchPc := row.isCommitRow
  , terminates := row.halted
  }

private def preparedStepExportsOfExecutionRows
    (rows : List ExpandedRowView) : List (PreparedStepView Nat) :=
  listEnum rows |>.map fun (rowIndex, row) =>
    preparedStepOfExecutionRow rowIndex row

private def stage3RowBindingsOfExecutionRows
    (rows : List ExpandedRowView) :
    List (RowProjectionBinding ExpandedRowView (PreparedStepView Nat)) :=
  listEnum rows |>.map fun (rowIndex, row) =>
    { row := row
    , preparedStep := preparedStepOfExecutionRow rowIndex row
    }

private def preparedStepExportsPresent
    (artifact : AcceptedProofArtifactView) : Bool :=
  match replayedDerivedCaseOfArtifact? artifact with
  | some derived =>
      let preparedSteps := preparedStepExportsOfExecutionRows derived.executionRows
      !preparedSteps.isEmpty && preparedSteps.length = derived.executionRows.length
  | none => false

private def stage3RowBindingsPresent
    (artifact : AcceptedProofArtifactView) : Bool :=
  match replayedDerivedCaseOfArtifact? artifact with
  | some derived =>
      let rowBindings := stage3RowBindingsOfExecutionRows derived.executionRows
      !rowBindings.isEmpty && rowBindings.length = derived.executionRows.length
  | none => false

private def fullRootLaneRowsPresent
    (artifact : AcceptedProofArtifactView) : Bool :=
  match replayedDerivedCaseOfArtifact? artifact with
  | some derived =>
      proofLedAcceptedArtifactPresent artifact &&
        !derived.executionRows.isEmpty
  | none => false

private def exactOpeningWitnessesPresent
    (artifact : AcceptedProofArtifactView) : Bool :=
  proofLedAcceptedArtifactPresent artifact &&
    kernelOpeningWitnessBundlePresent artifact

private def root0BindingsPresent
    (artifact : AcceptedProofArtifactView) : Bool :=
  proofLedAcceptedArtifactPresent artifact &&
    root0ClaimPresent artifact

private def bridgeProvenanceChainsPresent
    (artifact : AcceptedProofArtifactView) : Bool :=
  proofLedAcceptedArtifactPresent artifact &&
    stage3RowBindingsPresent artifact &&
    root0BindingsPresent artifact &&
    artifact.exportedClaims.opening.digest ≠ [] &&
    artifact.exportedClaims.jointOpening.digest ≠ [] &&
    artifact.exportedClaims.accepted.digest ≠ []

private def soundnessAccountingPresent
    (artifact : AcceptedProofArtifactView) : Bool :=
  proofLedAcceptedArtifactPresent artifact &&
    mainLaneProofPresent artifact &&
    stageClaimProofPresent artifact &&
    stagePackageProofsPresent artifact &&
    kernelClaimProofPresent artifact &&
    programBindingInputsPresent artifact &&
    exactOpeningWitnessesPresent artifact &&
    bridgeProvenanceChainsPresent artifact

private def acceptedArtifactTheoremFieldPresentCached
    (artifact : AcceptedProofArtifactView)
    (replayedDerivedCase : Option ParityDerivedCase)
    (proofLedAcceptedArtifact : Bool)
    (field : AcceptedArtifactTheoremField) : Bool :=
  let executionRowsPresent :=
    match replayedDerivedCase with
    | some derived => !derived.executionRows.isEmpty
    | none => false
  let transcriptEventsPresent :=
    match replayedDerivedCase with
    | some derived => !derived.transcript.events.isEmpty
    | none => false
  let preparedStepExportsPresent :=
    match replayedDerivedCase with
    | some derived =>
        let preparedSteps := preparedStepExportsOfExecutionRows derived.executionRows
        let recomputedRootLane := recomputeRootLaneView derived.executionRows
        !preparedSteps.isEmpty &&
          preparedSteps.length = derived.executionRows.length &&
          recomputedPreparedStepBindingsMatchArtifact recomputedRootLane artifact
    | none => false
  let stage3RowBindingsPresent :=
    match replayedDerivedCase with
    | some derived =>
        let rowBindings := stage3RowBindingsOfExecutionRows derived.executionRows
        !rowBindings.isEmpty && rowBindings.length = derived.executionRows.length
    | none => false
  let fullRootLaneRowsPresent :=
    match replayedDerivedCase with
    | some derived =>
        let recomputedRootLane := recomputeRootLaneView derived.executionRows
        !derived.executionRows.isEmpty &&
          recomputedRootLaneProtocolBindingsMatchArtifact recomputedRootLane artifact
    | none => false
  let exactOpeningWitnessesPresent :=
    proofLedAcceptedArtifact && kernelOpeningWitnessBundlePresent artifact
  let root0BindingsPresent :=
    proofLedAcceptedArtifact && root0ClaimPresent artifact
  let bridgeProvenanceChainsPresent :=
    proofLedAcceptedArtifact &&
      stage3RowBindingsPresent &&
      root0BindingsPresent &&
      artifact.exportedClaims.opening.digest ≠ [] &&
      artifact.exportedClaims.jointOpening.digest ≠ [] &&
      artifact.exportedClaims.accepted.digest ≠ []
  let soundnessAccountingPresent :=
    proofLedAcceptedArtifact &&
      mainLaneProofPresent artifact &&
      stageClaimProofPresent artifact &&
      stagePackageProofsPresent artifact &&
      kernelClaimProofPresent artifact &&
      programBindingInputsPresent artifact &&
      exactOpeningWitnessesPresent &&
      bridgeProvenanceChainsPresent
  match field with
  | .sourceCase => sourceCasePresent artifact
  | .executionRows => executionRowsPresent
  | .transcriptEvents => transcriptEventsPresent
  | .traceChunkInput => sourceCasePresent artifact && executionRowsPresent
  | .traceLinkBoundary => executionRowsPresent
  | .kernelProofBundle => artifact.kernelProof.digest ≠ []
  | .soundnessAccounting => soundnessAccountingPresent
  | .preparedStepExports => preparedStepExportsPresent
  | .fullRootLaneRows => fullRootLaneRowsPresent
  | .fullStage3RowBindings => stage3RowBindingsPresent
  | .root0Bindings => root0BindingsPresent
  | .programBindingInputs => programBindingInputsPresent artifact
  | .kernelOpeningWitnesses => kernelOpeningWitnessBundlePresent artifact
  | .exactOpeningWitnesses => exactOpeningWitnessesPresent
  | .bridgeProvenanceChains => bridgeProvenanceChainsPresent

def acceptedArtifactTheoremFieldPresent
    (artifact : AcceptedProofArtifactView)
    (field : AcceptedArtifactTheoremField) : Bool :=
  acceptedArtifactTheoremFieldPresentCached
    artifact
    (replayedDerivedCaseOfArtifact? artifact)
    (checkAcceptedArtifactCase artifact)
    field

def acceptedArtifactTheoremCompletenessChecks
    (artifact : AcceptedProofArtifactView) : List (String × Bool) :=
  let replayedDerivedCase := replayedDerivedCaseOfArtifact? artifact
  let proofLedAcceptedArtifact := checkAcceptedArtifactCase artifact
  requiredAcceptedArtifactTheoremFields.map fun field =>
    (acceptedArtifactTheoremFieldName field,
      acceptedArtifactTheoremFieldPresentCached
        artifact
        replayedDerivedCase
        proofLedAcceptedArtifact
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
