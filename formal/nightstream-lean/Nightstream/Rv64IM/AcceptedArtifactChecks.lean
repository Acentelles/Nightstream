import Nightstream.Rv64IM.Generated.AcceptedProofArtifactCorpus
import Nightstream.Rv64IM.AcceptedArtifactKernelSurface
import Nightstream.Rv64IM.AcceptedArtifactKernelReplay
import Nightstream.Rv64IM.AcceptedArtifactLocalTrace
import Nightstream.Rv64IM.AcceptedArtifactTemporalReplay
import Nightstream.Rv64IM.AcceptedArtifactStage3Refinement
import Nightstream.Rv64IM.AcceptedArtifactRootLane
import Nightstream.Rv64IM.Checks
import Nightstream.Rv64IM.Kernel.PublicProofProjection
import Nightstream.Rv64IM.ProofBoundaryChecks

/-!
Executable Rust↔Lean audit for the RV64IM accepted-proof artifact boundary.
This owner treats the source case plus proof-bearing kernel bundle as the
authoritative low layer, replays `source -> derived` inside Lean, rebuilds the
public proof projection from the replayed case, and checks exact equality
against the exported Rust public proof shape.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated

private def acceptedArtifactCaseCheckResults
    (artifact : AcceptedProofArtifactView) : List (String × Bool) :=
  match replayedAcceptedArtifactCase? artifact with
  | none =>
      [ ("sourceReplayMatchesImportedDerived", false)
      , ("exportedPublicProofApiLockstep"
        , artifact.exportedProof.statement = artifact.exportedStatement &&
            artifact.exportedProof.claim = artifact.exportedClaims &&
            artifact.exportedProof.kernel = artifact.exportedKernelProof)
      ]
  | some replayed =>
      let recomputedKernelReplay := { derived := replayed.derived }
      let schema := projectedPublicProofSchemaOfAcceptedArtifact replayed
      let proof := projectedPublicProofOfAcceptedArtifact replayed
      let recomputedKernelSurface := recomputeKernelSurfaceView replayed
      let recomputedLocalTrace := recomputeLocalTraceView replayed
      let recomputedTemporal := recoverTemporalReplay? replayed
      let recomputedStage3 := recoverStage3Refinement? replayed
      let recomputedRootLane := recomputeRootLaneView replayed.derived.executionRows
      [ ("sourceReplayMatchesImportedDerived"
        , recomputedKernelReplayMatchesArtifact recomputedKernelReplay artifact)
      , ("exportedPublicProofApiLockstep"
        , artifact.exportedProof.statement = artifact.exportedStatement &&
            artifact.exportedProof.claim = artifact.exportedClaims &&
            artifact.exportedProof.kernel = artifact.exportedKernelProof)
      , ("kernelProofArtifactMatchesExported", projectedKernelProofMatchesExported replayed)
      , ("recomputedKernelStatementMatchesArtifact"
        , recomputedKernelStatementMatchesArtifact recomputedKernelReplay artifact)
      , ("recomputedKernelClaimsMatchArtifact"
        , recomputedKernelClaimsMatchArtifact recomputedKernelReplay artifact)
      , ("recomputedKernelProofMatchesArtifact"
        , recomputedKernelProofMatchesArtifact recomputedKernelReplay artifact)
      , ("recomputedKernelStageDigestBindingsMatchArtifact"
        , recomputedKernelStageDigestBindingsMatchArtifact recomputedKernelReplay artifact)
      , ("recomputedKernelTerminalBindingsMatchArtifact"
        , recomputedKernelTerminalBindingsMatchArtifact recomputedKernelReplay artifact)
      , ("recomputedKernelReplayMatchesAllArtifactBindings"
        , recomputedKernelReplayMatchesAllArtifactBindings recomputedKernelReplay artifact)
      , ("recomputedTraceProjectionMatchesArtifact"
        , recomputedTraceProjectionMatchesArtifact recomputedKernelSurface replayed)
      , ("recomputedStageWitnessProjectionMatchesArtifact"
        , recomputedStageWitnessProjectionMatchesArtifact recomputedKernelSurface replayed)
      , ("recomputedKernelSurfaceMatchesArtifact"
        , recomputedKernelSurfaceMatchesArtifact recomputedKernelSurface replayed)
      , ("recomputedChunkInputMatchesArtifact"
        , recomputedChunkInputMatchesArtifact recomputedLocalTrace artifact)
      , ("recomputedMainLaneBoundaryMatchesArtifact"
        , recomputedMainLaneBoundaryMatchesArtifact recomputedLocalTrace artifact)
      , ("recomputedTraceLinkBoundaryMatchesArtifact"
        , recomputedTraceLinkBoundaryMatchesArtifact recomputedLocalTrace artifact)
      , ("recomputedStage3RowBindingsMatchArtifact"
        , recomputedStage3RowBindingsMatchArtifact recomputedLocalTrace artifact)
      , ("recomputedLocalTraceMatchesArtifact"
        , recomputedLocalTraceMatchesArtifact recomputedLocalTrace artifact)
      , ("recoveredTemporalReplay"
        , recomputedTemporal.isSome)
      , ("recoveredTemporalReplayMatchesArtifact"
        , recomputedTemporal.map (fun replay => recoveredTemporalReplayMatchesArtifact replay artifact) |>.getD false)
      , ("recoveredStage2TemporalClosure"
        , recomputedTemporal.isSome)
      , ("recoveredTemporalConsistency"
        , recomputedTemporal.isSome)
      , ("recoveredStage3Refinement"
        , recomputedStage3.isSome)
      , ("recoveredStage3RefinementMatchesArtifact"
        , recomputedStage3.map (fun pkg => recoveredStage3RefinementMatchesArtifact pkg artifact)
            |>.getD false)
      , ("recoveredStage3ContinuitySemantics"
        , recomputedStage3.isSome)
      , ("recoveredStage3ExportSemantics"
        , recomputedStage3.isSome)
      , ("recomputedRootLaneColumnsMatchArtifact"
        , recomputedRootLaneColumnsMatchArtifact recomputedRootLane replayed)
      , ("recomputedRootLaneCommitmentMatchesArtifact"
        , recomputedRootLaneCommitmentMatchesArtifact recomputedRootLane replayed)
      , ("recomputedMainLaneSurfaceMatchesArtifact"
        , recomputedMainLaneSurfaceMatchesArtifact recomputedRootLane replayed)
      , ("recomputedPreparedStepBindingsMatchArtifact"
        , recomputedPreparedStepBindingsMatchArtifact recomputedRootLane replayed)
      , ("recomputedRootLaneProtocolBindingsMatchArtifact"
        , recomputedRootLaneProtocolBindingsMatchArtifact recomputedRootLane replayed)
      , ("kernelProofDigests", validKernelProofDigests replayed.kernelProof)
      , ("projectedStatementDigest", validStatementDigest schema.statement)
      , ("projectedClaimDigests", validClaimDigests schema.claims)
      , ("statementMatchesKernelAndDerived"
        , statementMatchesKernelAndDerived schema.statement replayed.kernelProof replayed.derived)
      , ("claimsMatchStatementAndKernel"
        , claimsMatchStatementAndKernel schema.statement schema.claims replayed.kernelProof replayed.derived)
      , ("kernelProofMatchesDerivedAndClaims"
        , kernelProofMatchesDerivedAndClaims replayed.kernelProof replayed.derived)
      , ("projectedStatementMatchesExported", schema.statement = artifact.exportedStatement)
      , ("projectedClaimsMatchesExported", schema.claims = artifact.exportedClaims)
      , ("projectedProofMatchesExported", proof = artifact.exportedProof)
      ]

structure Rv64imAcceptedArtifactReport where
  name : String
  checks : List (String × Bool)
deriving Repr

def checkAcceptedArtifactCase (artifact : AcceptedProofArtifactView) : Bool :=
  (acceptedArtifactCaseCheckResults artifact).all Prod.snd

def rv64imAcceptedArtifactChecks : List Bool :=
  Generated.AcceptedProofArtifacts.cases.map checkAcceptedArtifactCase

def validGeneratedRv64imAcceptedArtifactCases : Bool :=
  Generated.AcceptedProofArtifacts.cases.all checkAcceptedArtifactCase

def rv64imAcceptedArtifactReports : List Rv64imAcceptedArtifactReport :=
  Generated.AcceptedProofArtifacts.cases.map fun artifact =>
    { name := artifact.name, checks := acceptedArtifactCaseCheckResults artifact }

private def tamperBytes : List Byte → List Byte
  | [] => [1]
  | byte :: tail => (byte + 1) :: tail

private def withKernelProof
    (artifact : AcceptedProofArtifactView)
    (kernelProof : KernelProofBundleView) : AcceptedProofArtifactView :=
  { artifact with kernelProof := kernelProof }

private def withDerived
    (artifact : AcceptedProofArtifactView)
    (derived : ParityDerivedCase) : AcceptedProofArtifactView :=
  { artifact with derived := derived }

private def withExportedStatement
    (artifact : AcceptedProofArtifactView)
    (statement : ProofStatementView) : AcceptedProofArtifactView :=
  { artifact with
      exportedStatement := statement
      exportedProof := { artifact.exportedProof with statement := statement }
  }

private def withExportedKernelProof
    (artifact : AcceptedProofArtifactView)
    (kernelProof : KernelProofBundleView) : AcceptedProofArtifactView :=
  { artifact with
      exportedKernelProof := kernelProof
      exportedProof := { artifact.exportedProof with kernel := kernelProof }
  }

private def selectedOpeningValueMismatchArtifact (artifact : AcceptedProofArtifactView) :
    AcceptedProofArtifactView :=
  let kernelProof :=
    { artifact.kernelProof with
        rootLaneColumns :=
          { artifact.kernelProof.rootLaneColumns with
              firstRow := artifact.kernelProof.rootLaneColumns.firstRow.map fun reference =>
                { reference with valueDigest := tamperBytes reference.valueDigest }
          }
    }
  withKernelProof artifact kernelProof

private def transcriptInputMismatchArtifact (artifact : AcceptedProofArtifactView) :
    AcceptedProofArtifactView :=
  let derived :=
    { artifact.derived with
        kernel :=
          { artifact.derived.kernel with
              transcriptFinalDigest := tamperBytes artifact.derived.kernel.transcriptFinalDigest
          }
    }
  withDerived artifact derived

private def stagePackagePayloadMismatchArtifact (artifact : AcceptedProofArtifactView) :
    AcceptedProofArtifactView :=
  let kernelProof :=
    { artifact.kernelProof with
        stagePackages :=
          { artifact.kernelProof.stagePackages with
              digest := tamperBytes artifact.kernelProof.stagePackages.digest
          }
    }
  withKernelProof artifact kernelProof

private def kernelOpeningPayloadMismatchArtifact (artifact : AcceptedProofArtifactView) :
    AcceptedProofArtifactView :=
  let kernelProof :=
    { artifact.kernelProof with
        kernelOpening :=
          { artifact.kernelProof.kernelOpening with
              digest := tamperBytes artifact.kernelProof.kernelOpening.digest
          }
    }
  withKernelProof artifact kernelProof

private def bridgeBindingMismatchArtifact (artifact : AcceptedProofArtifactView) :
    AcceptedProofArtifactView :=
  let derived :=
    { artifact.derived with
        kernel :=
          { artifact.derived.kernel with
              root0Digest := tamperBytes artifact.derived.kernel.root0Digest
          }
    }
  withDerived artifact derived

private def rootProofAcceptanceInputMismatchArtifact (artifact : AcceptedProofArtifactView) :
    AcceptedProofArtifactView :=
  let kernelProof :=
    { artifact.kernelProof with
        mainLane :=
          { artifact.kernelProof.mainLane with
              binding :=
                { artifact.kernelProof.mainLane.binding with
                    rootLaneCommitmentDigest :=
                      tamperBytes artifact.kernelProof.mainLane.binding.rootLaneCommitmentDigest
                }
          }
    }
  withKernelProof artifact kernelProof

private def rootLaneCommitmentSummaryMismatchArtifact
    (artifact : AcceptedProofArtifactView) : AcceptedProofArtifactView :=
  let kernelProof :=
    { artifact.kernelProof with
        rootLaneCommitment :=
          { artifact.kernelProof.rootLaneCommitment with
              digest := tamperBytes artifact.kernelProof.rootLaneCommitment.digest
          }
    }
  withKernelProof artifact kernelProof

private def placeholderLikeExportedKernelProofArtifact (artifact : AcceptedProofArtifactView) :
    AcceptedProofArtifactView :=
  let exportedKernelProof :=
    { artifact.exportedKernelProof with
        stagePackages :=
          { artifact.exportedKernelProof.stagePackages with
              digest := []
          }
    }
  withExportedKernelProof artifact exportedKernelProof

private def exportedSummaryVsRecomputationMismatchArtifact (artifact : AcceptedProofArtifactView) :
    AcceptedProofArtifactView :=
  let derived :=
    { artifact.derived with
        kernel :=
          { artifact.derived.kernel with
              finalStateDigest := tamperBytes artifact.derived.kernel.finalStateDigest
          }
    }
  withDerived artifact derived

private def executionRowLocalTraceMismatchArtifact
    (artifact : AcceptedProofArtifactView) : AcceptedProofArtifactView :=
  match artifact.derived.executionRows with
  | [] => artifact
  | row :: rows =>
      let derived :=
        { artifact.derived with
            executionRows := { row with pc := row.pc + 4 } :: rows
        }
      withDerived artifact derived

private def temporalReplayMismatchArtifact
    (artifact : AcceptedProofArtifactView) : AcceptedProofArtifactView :=
  match artifact.derived.stage2.registerWrites with
  | [] => artifact
  | write :: writes =>
      let derived :=
        { artifact.derived with
            stage2 :=
              { artifact.derived.stage2 with
                  registerWrites := { write with next := write.next + 1 } :: writes
              }
        }
      withDerived artifact derived

private def stage3RefinementMismatchArtifact
    (artifact : AcceptedProofArtifactView) : AcceptedProofArtifactView :=
  match artifact.derived.stage3.continuity with
  | [] =>
      let derived :=
        { artifact.derived with
            stage3 := { artifact.derived.stage3 with halted := !artifact.derived.stage3.halted }
        }
      withDerived artifact derived
  | event :: continuity =>
      let derived :=
        { artifact.derived with
            stage3 :=
              { artifact.derived.stage3 with
                  continuity :=
                    { event with continuityHolds := !event.continuityHolds } :: continuity
              }
        }
      withDerived artifact derived

structure Rv64imAcceptedArtifactNegativeCase where
  name : String
  expectedFailedChecks : List String
  artifact : AcceptedProofArtifactView
deriving Repr

private def acceptedArtifactNegativeCases : List Rv64imAcceptedArtifactNegativeCase :=
  match Generated.AcceptedProofArtifacts.caseByName? "vertical_add_sd_ld_ecall" with
  | none => []
  | some artifact =>
      [ { name := "selected_opening_value_mismatch"
        , expectedFailedChecks := ["kernelProofArtifactMatchesExported", "kernelProofDigests"]
        , artifact := selectedOpeningValueMismatchArtifact artifact
        }
      , { name := "transcript_input_mismatch"
        , expectedFailedChecks := ["sourceReplayMatchesImportedDerived"]
        , artifact := transcriptInputMismatchArtifact artifact
        }
      , { name := "stage_package_payload_mismatch"
        , expectedFailedChecks := ["kernelProofArtifactMatchesExported", "kernelProofDigests"]
        , artifact := stagePackagePayloadMismatchArtifact artifact
        }
      , { name := "kernel_opening_payload_mismatch"
        , expectedFailedChecks := ["kernelProofArtifactMatchesExported", "kernelProofDigests"]
        , artifact := kernelOpeningPayloadMismatchArtifact artifact
        }
      , { name := "bridge_binding_mismatch"
        , expectedFailedChecks := ["sourceReplayMatchesImportedDerived"]
        , artifact := bridgeBindingMismatchArtifact artifact
        }
      , { name := "root_proof_acceptance_input_mismatch"
        , expectedFailedChecks := ["kernelProofArtifactMatchesExported", "kernelProofDigests"]
        , artifact := rootProofAcceptanceInputMismatchArtifact artifact
        }
      , { name := "root_lane_commitment_summary_mismatch"
        , expectedFailedChecks :=
            [ "kernelProofArtifactMatchesExported"
            , "recomputedRootLaneCommitmentMatchesArtifact"
            , "recomputedRootLaneProtocolBindingsMatchArtifact"
            , "kernelProofDigests"
            ]
        , artifact := rootLaneCommitmentSummaryMismatchArtifact artifact
        }
      , { name := "placeholder_like_exported_kernel_payload"
        , expectedFailedChecks := ["kernelProofArtifactMatchesExported", "projectedProofMatchesExported"]
        , artifact := placeholderLikeExportedKernelProofArtifact artifact
        }
      , { name := "exported_summary_vs_recomputation_mismatch"
        , expectedFailedChecks := ["sourceReplayMatchesImportedDerived"]
        , artifact := exportedSummaryVsRecomputationMismatchArtifact artifact
        }
      , { name := "execution_row_local_trace_mismatch"
        , expectedFailedChecks :=
            [ "sourceReplayMatchesImportedDerived"
            , "recomputedChunkInputMatchesArtifact"
            , "recomputedMainLaneBoundaryMatchesArtifact"
            , "recomputedTraceLinkBoundaryMatchesArtifact"
            , "recomputedStage3RowBindingsMatchArtifact"
            , "recomputedLocalTraceMatchesArtifact"
            ]
        , artifact := executionRowLocalTraceMismatchArtifact artifact
        }
      , { name := "temporal_replay_mismatch"
        , expectedFailedChecks :=
            [ "sourceReplayMatchesImportedDerived"
            , "recoveredTemporalReplayMatchesArtifact"
            ]
        , artifact := temporalReplayMismatchArtifact artifact
        }
      , { name := "stage3_refinement_mismatch"
        , expectedFailedChecks :=
            [ "sourceReplayMatchesImportedDerived"
            , "recoveredStage3RefinementMatchesArtifact"
            ]
        , artifact := stage3RefinementMismatchArtifact artifact
        }
      ]

private def failingCheckNames (checks : List (String × Bool)) : List String :=
  checks.filterMap fun (name, ok) => if ok then none else some name

private def expectedFailuresPresent
    (checks : List (String × Bool))
    (expected : List String) : Bool :=
  let failing := failingCheckNames checks
  expected.all failing.contains

structure Rv64imAcceptedArtifactNegativeReport where
  name : String
  expectedFailedChecks : List String
  failingChecks : List String
  checks : List (String × Bool)
deriving Repr

def checkAcceptedArtifactNegativeCase (negativeCase : Rv64imAcceptedArtifactNegativeCase) : Bool :=
  let checks := acceptedArtifactCaseCheckResults negativeCase.artifact
  !(checks.all Prod.snd) &&
    expectedFailuresPresent checks negativeCase.expectedFailedChecks

def rv64imAcceptedArtifactNegativeChecks : List Bool :=
  acceptedArtifactNegativeCases.map checkAcceptedArtifactNegativeCase

def validGeneratedRv64imAcceptedArtifactNegativeCases : Bool :=
  acceptedArtifactNegativeCases.all checkAcceptedArtifactNegativeCase

def rv64imAcceptedArtifactNegativeReports : List Rv64imAcceptedArtifactNegativeReport :=
  acceptedArtifactNegativeCases.map fun negativeCase =>
    let checks := acceptedArtifactCaseCheckResults negativeCase.artifact
    { name := negativeCase.name
    , expectedFailedChecks := negativeCase.expectedFailedChecks
    , failingChecks := failingCheckNames checks
    , checks := checks
    }

end Nightstream.Rv64IM
