import Nightstream.Rv64IM.Generated.AcceptedProofArtifactCorpus

/-!
Owns the theorem-facing RV64IM export surface required to close the
root-execution-semantics step. This file states which row-local proof objects
must exist at the accepted-artifact boundary before Lean can refine accepted
root-lane execution objects back to RV64IM execution correctness.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated

inductive RequiredRootExecutionSemanticsField where
  | rowLocalRootEncodeWitness
  | rowLocalCCSAcceptance
  | executionSemanticsRefinement
deriving DecidableEq, Repr

def requiredRootExecutionSemanticsFieldName :
    RequiredRootExecutionSemanticsField → String
  | .rowLocalRootEncodeWitness => "row_local_root_encode_witness_surface"
  | .rowLocalCCSAcceptance => "row_local_ccs_acceptance_surface"
  | .executionSemanticsRefinement => "execution_semantics_refinement_surface"

def requiredRootExecutionSemanticsFields :
    List RequiredRootExecutionSemanticsField :=
  [ .rowLocalRootEncodeWitness
  , .rowLocalCCSAcceptance
  , .executionSemanticsRefinement
  ]

def requiredRootExecutionSemanticsFieldPresent
    (artifact : AcceptedProofArtifactView)
    (field : RequiredRootExecutionSemanticsField) : Bool :=
  match field with
  | .rowLocalRootEncodeWitness =>
      !artifact.rootExecution.semanticRows.isEmpty &&
        artifact.rootExecution.semanticRowsDigest ≠ [] &&
        artifact.rootExecution.digest ≠ []
  | .rowLocalCCSAcceptance =>
      let acceptance := artifact.rootExecution.rowLocalCcsAcceptance
      !acceptance.acceptances.isEmpty &&
        acceptance.acceptanceCount = artifact.rootExecution.executionRows.length &&
        acceptance.acceptances.length = artifact.rootExecution.executionRows.length &&
        acceptance.digest ≠ []
  | .executionSemanticsRefinement =>
      let refinement := artifact.rootExecution.executionSemanticsRefinement
      !refinement.refinements.isEmpty &&
        refinement.refinementCount = artifact.rootExecution.executionRows.length &&
        refinement.refinements.length = artifact.rootExecution.executionRows.length &&
        refinement.digest ≠ []

def requiredRootExecutionSemanticsChecks
    (artifact : AcceptedProofArtifactView) : List (String × Bool) :=
  requiredRootExecutionSemanticsFields.map fun field =>
    (requiredRootExecutionSemanticsFieldName field,
      requiredRootExecutionSemanticsFieldPresent artifact field)

def requiredRootExecutionSemanticsSurfacePresent
    (artifact : AcceptedProofArtifactView) : Bool :=
  (requiredRootExecutionSemanticsChecks artifact).all Prod.snd

def missingRequiredRootExecutionSemanticsFields
    (artifact : AcceptedProofArtifactView) : List String :=
  (requiredRootExecutionSemanticsChecks artifact).filterMap fun (name, ok) =>
    if ok then none else some name

def uniqueMissingRequiredRootExecutionSemanticsFields : List String :=
  Generated.AcceptedProofArtifacts.cases.foldl
    (fun acc artifact =>
      (missingRequiredRootExecutionSemanticsFields artifact).foldl
        (fun acc field => if field ∈ acc then acc else acc ++ [field])
        acc)
    []

def requiredRootExecutionSemanticsRustExportBlockers
    (artifact : AcceptedProofArtifactView) : List String :=
  let blockers : List (String × Bool) :=
    [ ( "root_execution_rows_missing_row_local_root_encode_witnesses"
      , requiredRootExecutionSemanticsFieldPresent artifact .rowLocalRootEncodeWitness
      )
    , ( "root_execution_rows_missing_row_local_ccs_acceptance_objects"
      , requiredRootExecutionSemanticsFieldPresent artifact .rowLocalCCSAcceptance
      )
    , ( "root_execution_rows_missing_execution_correct_refinement_objects"
      , requiredRootExecutionSemanticsFieldPresent artifact .executionSemanticsRefinement
      )
    ]
  blockers.filterMap fun (name, ok) =>
    if ok then none else some name

private def appendUniqueStrings
    (acc : List String)
    (xs : List String) : List String :=
  xs.foldl (fun acc x => if x ∈ acc then acc else acc ++ [x]) acc

def uniqueRequiredRootExecutionSemanticsRustExportBlockers : List String :=
  Generated.AcceptedProofArtifacts.cases.foldl
    (fun acc artifact =>
      appendUniqueStrings acc (requiredRootExecutionSemanticsRustExportBlockers artifact))
    []

structure Rv64imRequiredRootExecutionSemanticsReport where
  name : String
  checks : List (String × Bool)
  missing : List String
  rustExportBlockers : List String
deriving Repr

def rv64imRequiredRootExecutionSemanticsChecks : List Bool :=
  Generated.AcceptedProofArtifacts.cases.map requiredRootExecutionSemanticsSurfacePresent

def validGeneratedRv64imRequiredRootExecutionSemanticsCases : Bool :=
  Generated.AcceptedProofArtifacts.cases.all requiredRootExecutionSemanticsSurfacePresent

def rv64imRequiredRootExecutionSemanticsReports :
    List Rv64imRequiredRootExecutionSemanticsReport :=
  Generated.AcceptedProofArtifacts.cases.map fun artifact =>
    { name := artifact.name
    , checks := requiredRootExecutionSemanticsChecks artifact
    , missing := missingRequiredRootExecutionSemanticsFields artifact
    , rustExportBlockers := requiredRootExecutionSemanticsRustExportBlockers artifact
    }

end Nightstream.Rv64IM
