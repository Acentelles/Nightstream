import Nightstream.Rv64IM.Generated.AcceptedProofArtifactCorpus
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

private def replayedArtifactCase? (artifact : AcceptedProofArtifactView) :
    Option AcceptedProofArtifactView :=
  recomputeDerivedCase? artifact.source |>.map fun derived =>
    { artifact with derived := derived }

private def acceptedArtifactCaseCheckResults
    (artifact : AcceptedProofArtifactView) : List (String × Bool) :=
  match replayedArtifactCase? artifact with
  | none =>
      [ ("sourceReplayMatchesImportedDerived", false)
      , ("exportedPublicProofApiLockstep"
        , artifact.exportedProof.statement = artifact.exportedStatement &&
            artifact.exportedProof.claim = artifact.exportedClaims &&
            artifact.exportedProof.kernel = artifact.exportedKernelProof)
      ]
  | some replayed =>
      let schema := projectedPublicProofSchemaOfAcceptedArtifact replayed
      let proof := projectedPublicProofOfAcceptedArtifact replayed
      let recomputedRootLane := recomputeRootLaneView replayed.derived.executionRows
      [ ("sourceReplayMatchesImportedDerived", replayed.derived = artifact.derived)
      , ("exportedPublicProofApiLockstep"
        , artifact.exportedProof.statement = artifact.exportedStatement &&
            artifact.exportedProof.claim = artifact.exportedClaims &&
            artifact.exportedProof.kernel = artifact.exportedKernelProof)
      , ("kernelProofArtifactMatchesExported", projectedKernelProofMatchesExported replayed)
      , ("recomputedRootLaneColumnsMatchArtifact"
        , recomputedRootLaneColumnsMatchArtifact recomputedRootLane replayed)
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
      , { name := "placeholder_like_exported_kernel_payload"
        , expectedFailedChecks := ["kernelProofArtifactMatchesExported", "projectedProofMatchesExported"]
        , artifact := placeholderLikeExportedKernelProofArtifact artifact
        }
      , { name := "exported_summary_vs_recomputation_mismatch"
        , expectedFailedChecks := ["sourceReplayMatchesImportedDerived"]
        , artifact := exportedSummaryVsRecomputationMismatchArtifact artifact
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
