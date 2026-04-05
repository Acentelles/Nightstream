import Nightstream.Rv64IM.Generated.AcceptedProofArtifactCorpus
import Nightstream.Rv64IM.Kernel.RequiredBackendPayloadSurface
import Nightstream.Rv64IM.Kernel.RequiredKernelDesignBridgeSurface
import Nightstream.Rv64IM.Kernel.RequiredRootExecutionSemanticsSurface

/-!
Owns the theorem-facing RV64IM Rust export contract required for proof-complete
closure. This file aggregates the exact backend, root-execution-semantics, and
kernel-design-bridge export surfaces Lean must receive before accepted-artifact
closure can be fully derived.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated

inductive RequiredProofCompleteRustExportField where
  | backendPayloadSurface
  | rootExecutionSemanticsSurface
  | kernelDesignBridgeSurface
deriving DecidableEq, Repr

def requiredProofCompleteRustExportFieldName :
    RequiredProofCompleteRustExportField → String
  | .backendPayloadSurface => "required_backend_payload_surface"
  | .rootExecutionSemanticsSurface =>
      "required_root_execution_semantics_surface"
  | .kernelDesignBridgeSurface => "required_kernel_design_bridge_surface"

def requiredProofCompleteRustExportFields :
    List RequiredProofCompleteRustExportField :=
  [ .backendPayloadSurface
  , .rootExecutionSemanticsSurface
  , .kernelDesignBridgeSurface
  ]

def requiredProofCompleteRustExportFieldPresent
    (artifact : AcceptedProofArtifactView)
    (field : RequiredProofCompleteRustExportField) : Bool :=
  match field with
  | .backendPayloadSurface => requiredBackendPayloadSurfacePresent artifact
  | .rootExecutionSemanticsSurface =>
      requiredRootExecutionSemanticsSurfacePresent artifact
  | .kernelDesignBridgeSurface =>
      requiredKernelDesignBridgeSurfacePresent artifact

def requiredProofCompleteRustExportChecks
    (artifact : AcceptedProofArtifactView) : List (String × Bool) :=
  requiredProofCompleteRustExportFields.map fun field =>
    ( requiredProofCompleteRustExportFieldName field
    , requiredProofCompleteRustExportFieldPresent artifact field
    )

def requiredProofCompleteRustExportSurfacePresent
    (artifact : AcceptedProofArtifactView) : Bool :=
  (requiredProofCompleteRustExportChecks artifact).all Prod.snd

def missingRequiredProofCompleteRustExportFields
    (artifact : AcceptedProofArtifactView) : List String :=
  (requiredProofCompleteRustExportChecks artifact).filterMap fun (name, ok) =>
    if ok then none else some name

private def appendUniqueStrings
    (acc : List String)
    (xs : List String) : List String :=
  xs.foldl (fun acc x => if x ∈ acc then acc else acc ++ [x]) acc

def requiredProofCompleteRustExportBlockers
    (artifact : AcceptedProofArtifactView) : List String :=
  let acc := appendUniqueStrings [] (requiredRootExecutionSemanticsRustExportBlockers artifact)
  let acc := appendUniqueStrings acc (requiredKernelDesignBridgeRustExportBlockers artifact)
  appendUniqueStrings acc (requiredBackendPayloadRustExportBlockers artifact)

def requiredProofCompleteBackendRustExportBlockers
    (artifact : AcceptedProofArtifactView) : List String :=
  requiredBackendPayloadRustExportBlockers artifact

def requiredProofCompleteRootExecutionSemanticsRustExportBlockers
    (artifact : AcceptedProofArtifactView) : List String :=
  requiredRootExecutionSemanticsRustExportBlockers artifact

def requiredProofCompleteKernelDesignBridgeRustExportBlockers
    (artifact : AcceptedProofArtifactView) : List String :=
  requiredKernelDesignBridgeRustExportBlockers artifact

def requiredProofCompleteBackendMissingFields
    (artifact : AcceptedProofArtifactView) : List String :=
  missingRequiredBackendPayloadFields artifact

def requiredProofCompleteRootExecutionSemanticsMissingFields
    (artifact : AcceptedProofArtifactView) : List String :=
  missingRequiredRootExecutionSemanticsFields artifact

def requiredProofCompleteKernelDesignBridgeMissingFields
    (artifact : AcceptedProofArtifactView) : List String :=
  missingRequiredKernelDesignBridgeFields artifact

def requiredProofCompleteBackendSurfacePresent
    (artifact : AcceptedProofArtifactView) : Bool :=
  (requiredProofCompleteBackendMissingFields artifact).isEmpty

def requiredProofCompleteRootExecutionSemanticsSurfacePresent
    (artifact : AcceptedProofArtifactView) : Bool :=
  (requiredProofCompleteRootExecutionSemanticsMissingFields artifact).isEmpty

def requiredProofCompleteKernelDesignBridgeSurfacePresent
    (artifact : AcceptedProofArtifactView) : Bool :=
  (requiredProofCompleteKernelDesignBridgeMissingFields artifact).isEmpty

def uniqueRequiredProofCompleteRustExportBlockers : List String :=
  Generated.AcceptedProofArtifacts.cases.foldl
    (fun acc artifact =>
      appendUniqueStrings acc (requiredProofCompleteRustExportBlockers artifact))
    []

def uniqueRequiredProofCompleteBackendRustExportBlockers : List String :=
  Generated.AcceptedProofArtifacts.cases.foldl
    (fun acc artifact =>
      appendUniqueStrings acc (requiredProofCompleteBackendRustExportBlockers artifact))
    []

def uniqueRequiredProofCompleteRootExecutionSemanticsRustExportBlockers :
    List String :=
  Generated.AcceptedProofArtifacts.cases.foldl
    (fun acc artifact =>
      appendUniqueStrings acc
        (requiredProofCompleteRootExecutionSemanticsRustExportBlockers artifact))
    []

def uniqueRequiredProofCompleteKernelDesignBridgeRustExportBlockers :
    List String :=
  Generated.AcceptedProofArtifacts.cases.foldl
    (fun acc artifact =>
      appendUniqueStrings acc
        (requiredProofCompleteKernelDesignBridgeRustExportBlockers artifact))
    []

def uniqueMissingRequiredProofCompleteRustExportFields : List String :=
  Generated.AcceptedProofArtifacts.cases.foldl
    (fun acc artifact =>
      appendUniqueStrings acc (missingRequiredProofCompleteRustExportFields artifact))
    []

def uniqueRequiredProofCompleteBackendMissingFields : List String :=
  Generated.AcceptedProofArtifacts.cases.foldl
    (fun acc artifact =>
      appendUniqueStrings acc (requiredProofCompleteBackendMissingFields artifact))
    []

def uniqueRequiredProofCompleteRootExecutionSemanticsMissingFields :
    List String :=
  Generated.AcceptedProofArtifacts.cases.foldl
    (fun acc artifact =>
      appendUniqueStrings acc
        (requiredProofCompleteRootExecutionSemanticsMissingFields artifact))
    []

def uniqueRequiredProofCompleteKernelDesignBridgeMissingFields :
    List String :=
  Generated.AcceptedProofArtifacts.cases.foldl
    (fun acc artifact =>
      appendUniqueStrings acc
        (requiredProofCompleteKernelDesignBridgeMissingFields artifact))
    []

structure Rv64imRequiredProofCompleteRustExportReport where
  name : String
  checks : List (String × Bool)
  backendSurfacePresent : Bool
  rootExecutionSemanticsSurfacePresent : Bool
  kernelDesignBridgeSurfacePresent : Bool
  aggregateSurfacePresent : Bool
  missing : List String
  missingBackendFields : List String
  missingRootExecutionSemanticsFields : List String
  missingKernelDesignBridgeFields : List String
  backendRustExportBlockers : List String
  rootExecutionSemanticsRustExportBlockers : List String
  kernelDesignBridgeRustExportBlockers : List String
  rustExportBlockers : List String
deriving Repr

def requiredProofCompleteRustExportReport
    (artifact : AcceptedProofArtifactView) : Rv64imRequiredProofCompleteRustExportReport :=
  { name := artifact.name
  , checks := requiredProofCompleteRustExportChecks artifact
  , backendSurfacePresent :=
      requiredProofCompleteBackendSurfacePresent artifact
  , rootExecutionSemanticsSurfacePresent :=
      requiredProofCompleteRootExecutionSemanticsSurfacePresent artifact
  , kernelDesignBridgeSurfacePresent :=
      requiredProofCompleteKernelDesignBridgeSurfacePresent artifact
  , aggregateSurfacePresent :=
      requiredProofCompleteRustExportSurfacePresent artifact
  , missing := missingRequiredProofCompleteRustExportFields artifact
  , missingBackendFields := requiredProofCompleteBackendMissingFields artifact
  , missingRootExecutionSemanticsFields :=
      requiredProofCompleteRootExecutionSemanticsMissingFields artifact
  , missingKernelDesignBridgeFields :=
      requiredProofCompleteKernelDesignBridgeMissingFields artifact
  , backendRustExportBlockers :=
      requiredProofCompleteBackendRustExportBlockers artifact
  , rootExecutionSemanticsRustExportBlockers :=
      requiredProofCompleteRootExecutionSemanticsRustExportBlockers artifact
  , kernelDesignBridgeRustExportBlockers :=
      requiredProofCompleteKernelDesignBridgeRustExportBlockers artifact
  , rustExportBlockers := requiredProofCompleteRustExportBlockers artifact
  }

def rv64imRequiredProofCompleteRustExportChecks : List Bool :=
  Generated.AcceptedProofArtifacts.cases.map requiredProofCompleteRustExportSurfacePresent

def validGeneratedRv64imRequiredProofCompleteRustExportCases : Bool :=
  Generated.AcceptedProofArtifacts.cases.all requiredProofCompleteRustExportSurfacePresent

def validGeneratedRv64imRequiredProofCompleteBackendSurfaceCases : Bool :=
  Generated.AcceptedProofArtifacts.cases.all
    requiredProofCompleteBackendSurfacePresent

def validGeneratedRv64imRequiredProofCompleteRootExecutionSemanticsSurfaceCases :
    Bool :=
  Generated.AcceptedProofArtifacts.cases.all
    requiredProofCompleteRootExecutionSemanticsSurfacePresent

def validGeneratedRv64imRequiredProofCompleteKernelDesignBridgeSurfaceCases :
    Bool :=
  Generated.AcceptedProofArtifacts.cases.all
    requiredProofCompleteKernelDesignBridgeSurfacePresent

def rv64imRequiredProofCompleteRustExportReports :
    List Rv64imRequiredProofCompleteRustExportReport :=
  Generated.AcceptedProofArtifacts.cases.map requiredProofCompleteRustExportReport

end Nightstream.Rv64IM
