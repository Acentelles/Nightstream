import Nightstream.Rv64IM.Generated.AcceptedProofArtifactCorpus

/-!
Owns the theorem-facing RV64IM backend payload export surface required for the
last-mile refinement into the proved SuperNeo statements `Π_CCS / Π_RLC / Π_DEC`.
This file states which low-level exported proof objects must exist at the
accepted-artifact boundary; it does not prove the refinement itself.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated

inductive RequiredBackendPayloadField where
  | chunkPayloadList
  | mainLanePiCCSPayload
  | stageClaimPiRLCPayload
  | stagePackagePiRLCPayload
  | kernelOpeningPiDECPayload
deriving DecidableEq, Repr

def requiredBackendPayloadFieldName : RequiredBackendPayloadField → String
  | .chunkPayloadList => "low_level_chunk_payload_surface"
  | .mainLanePiCCSPayload => "main_lane_payload_surface"
  | .stageClaimPiRLCPayload => "stage_claim_payload_surface"
  | .stagePackagePiRLCPayload => "stage_package_payload_surface"
  | .kernelOpeningPiDECPayload => "kernel_opening_payload_surface"

def requiredBackendPayloadFields : List RequiredBackendPayloadField :=
  [ .chunkPayloadList
  , .mainLanePiCCSPayload
  , .stageClaimPiRLCPayload
  , .stagePackagePiRLCPayload
  , .kernelOpeningPiDECPayload
  ]

def requiredBackendPayloadFieldPresent
    (_artifact : AcceptedProofArtifactView)
    (_field : RequiredBackendPayloadField) : Bool :=
  false

def requiredBackendPayloadChecks
    (artifact : AcceptedProofArtifactView) : List (String × Bool) :=
  requiredBackendPayloadFields.map fun field =>
    (requiredBackendPayloadFieldName field, requiredBackendPayloadFieldPresent artifact field)

def requiredBackendPayloadSurfacePresent
    (artifact : AcceptedProofArtifactView) : Bool :=
  (requiredBackendPayloadChecks artifact).all Prod.snd

def missingRequiredBackendPayloadFields
    (artifact : AcceptedProofArtifactView) : List String :=
  (requiredBackendPayloadChecks artifact).filterMap fun (name, ok) =>
    if ok then none else some name

def uniqueMissingRequiredBackendPayloadFields : List String :=
  Generated.AcceptedProofArtifacts.cases.foldl
    (fun acc artifact =>
      (missingRequiredBackendPayloadFields artifact).foldl
        (fun acc field => if field ∈ acc then acc else acc ++ [field])
        acc)
    []

def requiredBackendPayloadRustExportBlockers
    (artifact : AcceptedProofArtifactView) : List String :=
  let blockers : List (String × Bool) :=
    [ ( "accepted_artifact_view_missing_chunk_payload_list"
      , requiredBackendPayloadFieldPresent artifact .chunkPayloadList
      )
    , ( "main_lane_bundle_missing_theorem_bearing_pi_ccs_payload"
      , requiredBackendPayloadFieldPresent artifact .mainLanePiCCSPayload
      )
    , ( "stage_claim_bundle_missing_theorem_bearing_pi_rlc_claim_payload"
      , requiredBackendPayloadFieldPresent artifact .stageClaimPiRLCPayload
      )
    , ( "stage_package_bundle_missing_theorem_bearing_pi_rlc_package_payload"
      , requiredBackendPayloadFieldPresent artifact .stagePackagePiRLCPayload
      )
    , ( "kernel_opening_bundle_missing_theorem_bearing_pi_dec_payload"
      , requiredBackendPayloadFieldPresent artifact .kernelOpeningPiDECPayload
      )
    ]
  blockers.filterMap fun (name, ok) =>
    if ok then none else some name

private def appendUniqueStrings
    (acc : List String)
    (xs : List String) : List String :=
  xs.foldl (fun acc x => if x ∈ acc then acc else acc ++ [x]) acc

def uniqueRequiredBackendPayloadRustExportBlockers : List String :=
  Generated.AcceptedProofArtifacts.cases.foldl
    (fun acc artifact =>
      appendUniqueStrings acc (requiredBackendPayloadRustExportBlockers artifact))
    []

structure Rv64imRequiredBackendPayloadReport where
  name : String
  checks : List (String × Bool)
  missing : List String
  rustExportBlockers : List String
deriving Repr

def rv64imRequiredBackendPayloadChecks : List Bool :=
  Generated.AcceptedProofArtifacts.cases.map requiredBackendPayloadSurfacePresent

def validGeneratedRv64imRequiredBackendPayloadCases : Bool :=
  Generated.AcceptedProofArtifacts.cases.all requiredBackendPayloadSurfacePresent

def rv64imRequiredBackendPayloadReports : List Rv64imRequiredBackendPayloadReport :=
  Generated.AcceptedProofArtifacts.cases.map fun artifact =>
    { name := artifact.name
    , checks := requiredBackendPayloadChecks artifact
    , missing := missingRequiredBackendPayloadFields artifact
    , rustExportBlockers := requiredBackendPayloadRustExportBlockers artifact
    }

end Nightstream.Rv64IM
