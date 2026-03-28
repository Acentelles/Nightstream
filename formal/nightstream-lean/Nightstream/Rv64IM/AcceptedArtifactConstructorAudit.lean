import Nightstream.Rv64IM.Generated.AcceptedProofArtifactCorpus
import Nightstream.Rv64IM.AcceptedArtifactCompleteness

/-!
Owns executable constructor-slot audits from the exported RV64IM accepted
artifact into the exact theorem constructors `ExactTraceBoundaries` and
`ExactKernelBoundaries`. This owner reports whether Lean can construct each
paper-facing field from the lowest practical Rust export layer without trusting
Rust-assembled summaries.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated

inductive ExactTraceConstructorSlot where
  | stepComposition
  | chunkInput
  | mainLane
  | traceLink
  | temporal
  | stage2Closure
  | stage3Refinement
  | executionRowsMatch
  | executionRowsLength
  | preparedStepExport
  | mainLaneRowsMatch
  | traceRowsMatch
  | stage2MatchesTemporal
deriving DecidableEq, Repr

def exactTraceConstructorSlotName : ExactTraceConstructorSlot → String
  | .stepComposition => "trace_step_composition"
  | .chunkInput => "trace_chunk_input"
  | .mainLane => "trace_main_lane"
  | .traceLink => "trace_trace_link"
  | .temporal => "trace_temporal"
  | .stage2Closure => "trace_stage2_closure"
  | .stage3Refinement => "trace_stage3_refinement"
  | .executionRowsMatch => "trace_execution_rows_match"
  | .executionRowsLength => "trace_execution_rows_length"
  | .preparedStepExport => "trace_prepared_step_export"
  | .mainLaneRowsMatch => "trace_main_lane_rows_match"
  | .traceRowsMatch => "trace_trace_rows_match"
  | .stage2MatchesTemporal => "trace_stage2_matches_temporal"

def requiredExactTraceConstructorSlots : List ExactTraceConstructorSlot :=
  [ .stepComposition
  , .chunkInput
  , .mainLane
  , .traceLink
  , .temporal
  , .stage2Closure
  , .stage3Refinement
  , .executionRowsMatch
  , .executionRowsLength
  , .preparedStepExport
  , .mainLaneRowsMatch
  , .traceRowsMatch
  , .stage2MatchesTemporal
  ]

def exactTraceConstructorSlotPresent
    (artifact : AcceptedProofArtifactView)
    (slot : ExactTraceConstructorSlot) : Bool :=
  let hasStepComposition :=
    acceptedArtifactTheoremFieldPresent artifact .stepCompositionProof
  let hasChunkInput :=
    acceptedArtifactTheoremFieldPresent artifact .traceChunkInput
  let hasMainLane :=
    acceptedArtifactTheoremFieldPresent artifact .mainLaneBoundary
  let hasTraceLink :=
    acceptedArtifactTheoremFieldPresent artifact .traceLinkBoundary
  let hasTemporal :=
    acceptedArtifactTheoremFieldPresent artifact .temporalConsistency
  let hasStage3Refinement :=
    acceptedArtifactTheoremFieldPresent artifact .stage3Refinement
  let hasPreparedStepExport :=
    acceptedArtifactTheoremFieldPresent artifact .preparedStepExports
  match slot with
  | .stepComposition => hasStepComposition
  | .chunkInput => hasChunkInput
  | .mainLane => hasMainLane
  | .traceLink => hasTraceLink
  | .temporal => hasTemporal
  | .stage2Closure => hasTemporal
  | .stage3Refinement => hasStage3Refinement
  | .executionRowsMatch => hasStepComposition && hasChunkInput
  | .executionRowsLength => hasStepComposition && hasChunkInput
  | .preparedStepExport => hasStepComposition && hasMainLane && hasPreparedStepExport
  | .mainLaneRowsMatch => hasChunkInput && hasMainLane
  | .traceRowsMatch => hasChunkInput && hasTraceLink
  | .stage2MatchesTemporal => hasTemporal

def exactTraceConstructorChecks
    (artifact : AcceptedProofArtifactView) : List (String × Bool) :=
  requiredExactTraceConstructorSlots.map fun slot =>
    (exactTraceConstructorSlotName slot, exactTraceConstructorSlotPresent artifact slot)

def exactTraceBoundaryConstructible
    (artifact : AcceptedProofArtifactView) : Bool :=
  (exactTraceConstructorChecks artifact).all Prod.snd

def missingExactTraceConstructorSlots
    (artifact : AcceptedProofArtifactView) : List String :=
  (exactTraceConstructorChecks artifact).filterMap fun (name, ok) =>
    if ok then none else some name

def exactTraceConstructorSlotBlockers
    (artifact : AcceptedProofArtifactView)
    (slot : ExactTraceConstructorSlot) : List String :=
  if exactTraceConstructorSlotPresent artifact slot then
    []
  else
    match slot with
    | .stepComposition => ["step_composition_proof"]
    | .chunkInput => ["trace_chunk_input"]
    | .mainLane => ["main_lane_boundary"]
    | .traceLink => ["trace_link_boundary"]
    | .temporal => ["temporal_consistency"]
    | .stage2Closure =>
        [ "temporal_consistency"
        , "derived_stage2_closure"
        ]
    | .stage3Refinement => ["stage3_refinement"]
    | .executionRowsMatch =>
        [ "step_composition_proof"
        , "trace_chunk_input"
        , "step_composition_rows_to_chunk_input_rows"
        ]
    | .executionRowsLength =>
        [ "step_composition_proof"
        , "trace_chunk_input"
        , "step_composition_rows_length"
        ]
    | .preparedStepExport =>
        [ "step_composition_proof"
        , "main_lane_boundary"
        , "prepared_step_exports"
        ]
    | .mainLaneRowsMatch =>
        [ "trace_chunk_input"
        , "main_lane_boundary"
        , "main_lane_rows_match"
        ]
    | .traceRowsMatch =>
        [ "trace_chunk_input"
        , "trace_link_boundary"
        , "trace_rows_match"
        ]
    | .stage2MatchesTemporal =>
        [ "temporal_consistency"
        , "derived_stage2_closure"
        ]

inductive ExactKernelConstructorSlot where
  | programBinding
  | trace
  | root0Bindings
  | transcript
  | transcriptSchedule
  | accounting
  | bridgeBindings
  | bridgeTraceBound
  | rowBindingCoverage
deriving DecidableEq, Repr

def exactKernelConstructorSlotName : ExactKernelConstructorSlot → String
  | .programBinding => "kernel_program_binding"
  | .trace => "kernel_trace"
  | .root0Bindings => "kernel_root0_bindings"
  | .transcript => "kernel_transcript"
  | .transcriptSchedule => "kernel_transcript_schedule"
  | .accounting => "kernel_accounting"
  | .bridgeBindings => "kernel_bridge_bindings"
  | .bridgeTraceBound => "kernel_bridge_trace_bound"
  | .rowBindingCoverage => "kernel_row_binding_coverage"

def requiredExactKernelConstructorSlots : List ExactKernelConstructorSlot :=
  [ .programBinding
  , .trace
  , .root0Bindings
  , .transcript
  , .transcriptSchedule
  , .accounting
  , .bridgeBindings
  , .bridgeTraceBound
  , .rowBindingCoverage
  ]

def exactKernelConstructorSlotPresent
    (artifact : AcceptedProofArtifactView)
    (slot : ExactKernelConstructorSlot) : Bool :=
  let hasTrace := exactTraceBoundaryConstructible artifact
  let hasRoot0Bindings :=
    acceptedArtifactTheoremFieldPresent artifact .root0Bindings
  let hasAccounting :=
    false
  let hasBridgeBindings :=
    hasTrace &&
      acceptedArtifactTheoremFieldPresent artifact .exactOpeningWitnesses &&
      acceptedArtifactTheoremFieldPresent artifact .bridgeProvenanceChains
  match slot with
  | .programBinding =>
      false
  | .trace => hasTrace
  | .root0Bindings => hasRoot0Bindings
  | .transcript => hasTrace && hasRoot0Bindings
  | .transcriptSchedule => hasTrace && hasRoot0Bindings
  | .accounting => hasAccounting
  | .bridgeBindings => hasBridgeBindings
  | .bridgeTraceBound => hasBridgeBindings
  | .rowBindingCoverage => hasTrace && hasRoot0Bindings

def exactKernelConstructorChecks
    (artifact : AcceptedProofArtifactView) : List (String × Bool) :=
  requiredExactKernelConstructorSlots.map fun slot =>
    (exactKernelConstructorSlotName slot, exactKernelConstructorSlotPresent artifact slot)

def exactKernelBoundaryConstructible
    (artifact : AcceptedProofArtifactView) : Bool :=
  (exactKernelConstructorChecks artifact).all Prod.snd

def missingExactKernelConstructorSlots
    (artifact : AcceptedProofArtifactView) : List String :=
  (exactKernelConstructorChecks artifact).filterMap fun (name, ok) =>
    if ok then none else some name

def exactKernelConstructorSlotBlockers
    (artifact : AcceptedProofArtifactView)
    (slot : ExactKernelConstructorSlot) : List String :=
  if exactKernelConstructorSlotPresent artifact slot then
    []
  else
    match slot with
    | .programBinding =>
        [ "program_binding_inputs"
        , "program_binding_proof_package"
        ]
    | .trace =>
        missingExactTraceConstructorSlots artifact
    | .root0Bindings =>
        [ "root0_bindings" ]
    | .transcript =>
        [ "kernel_trace"
        , "kernel_root0_bindings"
        , "derived_transcript_schedule"
        ]
    | .transcriptSchedule =>
        [ "kernel_trace"
        , "kernel_root0_bindings"
        , "derived_transcript_schedule"
        ]
    | .accounting =>
        [ "soundness_accounting"
        , "soundness_accounting_package"
        ]
    | .bridgeBindings =>
        [ "kernel_trace"
        , "exact_opening_witnesses"
        , "bridge_provenance_chains"
        , "kernel_bridge_bindings"
        ]
    | .bridgeTraceBound =>
        [ "kernel_bridge_bindings"
        , "kernel_bridge_trace_bound"
        ]
    | .rowBindingCoverage =>
        [ "kernel_trace"
        , "kernel_root0_bindings"
        , "derived_transcript_schedule"
        , "kernel_row_binding_coverage"
        ]

structure Rv64imAcceptedArtifactConstructorReport where
  name : String
  traceChecks : List (String × Bool)
  traceMissingSlots : List String
  traceBlockedBy : List (String × List String)
  kernelChecks : List (String × Bool)
  kernelMissingSlots : List String
  kernelBlockedBy : List (String × List String)
deriving Repr

def rv64imAcceptedArtifactTraceConstructorChecks : List Bool :=
  Generated.AcceptedProofArtifacts.cases.map exactTraceBoundaryConstructible

def validGeneratedRv64imAcceptedArtifactTraceConstructorCases : Bool :=
  Generated.AcceptedProofArtifacts.cases.all exactTraceBoundaryConstructible

def rv64imAcceptedArtifactKernelConstructorChecks : List Bool :=
  Generated.AcceptedProofArtifacts.cases.map exactKernelBoundaryConstructible

def validGeneratedRv64imAcceptedArtifactKernelConstructorCases : Bool :=
  Generated.AcceptedProofArtifacts.cases.all exactKernelBoundaryConstructible

def rv64imAcceptedArtifactConstructorReports :
    List Rv64imAcceptedArtifactConstructorReport :=
  Generated.AcceptedProofArtifacts.cases.map fun artifact =>
    { name := artifact.name
    , traceChecks := exactTraceConstructorChecks artifact
    , traceMissingSlots := missingExactTraceConstructorSlots artifact
    , traceBlockedBy :=
        requiredExactTraceConstructorSlots.filterMap fun slot =>
          let blockers := exactTraceConstructorSlotBlockers artifact slot
          if blockers.isEmpty then
            none
          else
            some (exactTraceConstructorSlotName slot, blockers)
    , kernelChecks := exactKernelConstructorChecks artifact
    , kernelMissingSlots := missingExactKernelConstructorSlots artifact
    , kernelBlockedBy :=
        requiredExactKernelConstructorSlots.filterMap fun slot =>
          let blockers := exactKernelConstructorSlotBlockers artifact slot
          if blockers.isEmpty then
            none
          else
            some (exactKernelConstructorSlotName slot, blockers)
    }

end Nightstream.Rv64IM
