import Nightstream.Rv64IM.Generated.ImportedParityCorpus
import Nightstream.Rv64IM.Generated.PublicProofVectors.Corpus
import Nightstream.Rv64IM.Kernel.AcceptedPublicProof
import Nightstream.Rv64IM.Kernel.PublicProofSchema
import Nightstream.Chip8.Kernel.Poseidon2Transcript
import Nightstream.Chip8.Kernel.Root0Digest
import Nightstream.Chip8.Kernel.Poseidon2GoldilocksCore

/-!
Executable Rust↔Lean audit for the RV64IM public proof boundary. This owner
does not rebuild the full derived trace; `Nightstream.Rv64IM.Checks` already
owns the independent source→derived replay. This file checks that the shipped
Rust public `statement / claims / kernelProof` surface is internally coherent
under the same Poseidon2 transcript formulas and that its public digests align
with the imported RV64IM parity corpus.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated
open Nightstream.Chip8.Poseidon2Transcript (TranscriptOp poseidon2AppDomain utf8Bytes)
open Nightstream.Chip8.Root0Digest (emptyCursor appendMessageCursor runOps digestBytes)
open Nightstream.Chip8.Poseidon2GoldilocksCore (concreteCore)

def boolWord (value : Bool) : Nat :=
  if value then 1 else 0

def foldScheduleWords : Nightstream.FoldSchedule → List Nat
  | .wholeTrace => [0, 0]
  | .rowsPerChunk rows => [1, rows]

def validFoldSchedule : Nightstream.FoldSchedule → Bool
  | .wholeTrace => true
  | .rowsPerChunk 0 => false
  | .rowsPerChunk (_ + 1) => true

def chunkScheduleMatches
    (schedule : Nightstream.FoldSchedule)
    (chunkCount publicStepCount : Nat) : Bool :=
  validFoldSchedule schedule &&
    chunkCount = Nightstream.FoldSchedule.chunkCount schedule publicStepCount

def transcriptDigest (appLabel : String) (ops : List TranscriptOp) : List Byte :=
  let cursor0 := appendMessageCursor concreteCore emptyCursor poseidon2AppDomain (utf8Bytes appLabel)
  let cursor := runOps concreteCore cursor0 ops
  digestBytes concreteCore cursor

def familyWord : FamilyTag → Nat
  | .nativeAlu => 0
  | .alignedMemory => 1
  | .controlFlow => 2
  | .narrowMemory => 3
  | .multiply => 4
  | .unsignedDivRem => 5
  | .signedDivRem => 6

private abbrev Rv64imRustPublicProofSchemaView :=
  Rv64imPublicProofSchema
    ProofStatementView
    KernelClaimBundleView
    KernelProofBundleView

private abbrev Rv64imRustExportedProofView :=
  ProofView

private structure Rv64imRustAcceptedPublicProofView where
  statement : ProofStatementView
  claims : KernelClaimBundleView
  kernelProof : KernelProofBundleView
  accepted : Unit

def publicProofSchemaOfCase
    (proofCase : PublicProofVectorCase) :
    Rv64imRustPublicProofSchemaView :=
  { statement := proofCase.proof.statement
  , claims := proofCase.proof.claim
  , kernelProof := proofCase.proof.kernel }

def exportedProofApiLockstep
    (proofCase : PublicProofVectorCase) : Bool :=
  let proof : Rv64imRustExportedProofView := proofCase.proof
  proof.statement = proofCase.statement &&
    proof.claim = proofCase.claims &&
    proof.kernel = proofCase.kernelProof

def acceptedPublicProofOfCase
    (proofCase : PublicProofVectorCase) :
    Rv64imRustAcceptedPublicProofView :=
  { statement := proofCase.proof.statement
  , claims := proofCase.proof.claim
  , kernelProof := proofCase.proof.kernel
  , accepted := () }

def acceptedPublicProofLockstep
    (proofCase : PublicProofVectorCase) : Bool :=
  let accepted := acceptedPublicProofOfCase proofCase
  accepted.statement = proofCase.proof.statement &&
    accepted.claims = proofCase.proof.claim &&
    accepted.kernelProof = proofCase.proof.kernel

def proofStatementDigest (statement : ProofStatementView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/proof_statement"
    [ .appendMessage "rv64im/proof_statement/root_params_id" statement.rootParamsId
    , .appendU64s "rv64im/proof_statement/fold_schedule" (foldScheduleWords statement.foldSchedule)
    , .appendMessage "rv64im/proof_statement/stage_claims_digest" statement.stageClaimsDigest
    , .appendMessage "rv64im/proof_statement/stage_packages_digest" statement.stagePackagesDigest
    , .appendMessage "rv64im/proof_statement/kernel_opening_digest" statement.kernelOpeningDigest
    , .appendMessage "rv64im/proof_statement/prepared_step_bindings_digest" statement.preparedStepBindingsDigest
    , .appendMessage "rv64im/proof_statement/execution_digest" statement.executionDigest
    , .appendMessage "rv64im/proof_statement/final_state_digest" statement.finalStateDigest
    , .appendMessage "rv64im/proof_statement/transcript_final_digest" statement.transcriptFinalDigest
    , .appendMessage "rv64im/proof_statement/main_lane_surface_digest" statement.mainLaneSurfaceDigest
    , .appendMessage "rv64im/proof_statement/root_lane_columns_digest" statement.rootLaneColumnsDigest
    , .appendU64s "rv64im/proof_statement/meta"
        [statement.chunkCount, statement.publicStepCount, statement.finalPc, boolWord statement.halted]
    ]

def acceptedProofStatementBindingDigest (binding : AcceptedProofStatementBindingView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/accepted_proof_statement_binding"
    [ .appendMessage
        "rv64im/accepted_proof_statement_binding/proof_statement_digest"
        binding.proofStatementDigest
    , .appendMessage
        "rv64im/accepted_proof_statement_binding/kernel_opening_digest"
        binding.kernelOpeningDigest
    ]

def acceptedProofMainLaneBindingDigest (binding : AcceptedProofMainLaneBindingView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/accepted_proof_main_lane_binding"
    [ .appendMessage
        "rv64im/accepted_proof_main_lane_binding/main_lane_bundle_digest"
        binding.mainLaneBundleDigest
    ]

def acceptedProofTerminalBindingDigest (binding : AcceptedProofTerminalBindingView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/accepted_proof_terminal_binding"
    [ .appendMessage
        "rv64im/accepted_proof_terminal_binding/final_state_digest"
        binding.finalStateDigest
    , .appendU64s
        "rv64im/accepted_proof_terminal_binding/meta"
        [binding.finalPc, boolWord binding.halted]
    ]

def acceptedProofClaimDigest (claim : AcceptedProofClaimView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/accepted_proof_claim"
    [ .appendMessage "rv64im/accepted_proof/root_params_id" claim.rootParamsId
    , .appendMessage "rv64im/accepted_proof/statement_digest" claim.statement.digest
    , .appendMessage "rv64im/accepted_proof/main_lane_digest" claim.mainLane.digest
    , .appendMessage "rv64im/accepted_proof/terminal_digest" claim.terminal.digest
    ]

def mainLaneClaimBindingDigest (binding : MainLaneClaimBindingView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/main_lane_claim_binding"
    [ .appendMessage "rv64im/main_lane_claim_binding/main_lane_bundle_digest" binding.mainLaneBundleDigest ]

def mainLaneClaimDigest (claim : MainLaneClaimView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/main_lane_claim"
    [ .appendMessage "rv64im/main_lane_claim/root_params_id" claim.rootParamsId
    , .appendMessage "rv64im/main_lane_claim/binding_digest" claim.binding.digest
    ]

def kernelOpeningStageClaimBindingDigest
    (binding : KernelOpeningStageClaimBindingView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/kernel_opening_stage_claim_binding"
    [ .appendMessage
        "rv64im/kernel_opening_stage_claim_binding/stage_claims_digest"
        binding.stageClaimsDigest
    , .appendMessage
        "rv64im/kernel_opening_stage_claim_binding/stage_packages_digest"
        binding.stagePackagesDigest
    , .appendMessage
        "rv64im/kernel_opening_stage_claim_binding/kernel_opening_digest"
        binding.kernelOpeningDigest
    ]

def kernelOpeningTerminalClaimBindingDigest
    (binding : KernelOpeningTerminalClaimBindingView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/kernel_opening_terminal_claim_binding"
    [ .appendMessage
        "rv64im/kernel_opening_terminal_claim_binding/prepared_step_bindings_digest"
        binding.preparedStepBindingsDigest
    , .appendMessage
        "rv64im/kernel_opening_terminal_claim_binding/execution_digest"
        binding.executionDigest
    , .appendMessage
        "rv64im/kernel_opening_terminal_claim_binding/transcript_final_digest"
        binding.transcriptFinalDigest
    ]

def kernelOpeningClaimDigest (claim : KernelOpeningClaimView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/kernel_opening_claim"
    [ .appendMessage "rv64im/kernel_opening_claim/root_params_id" claim.rootParamsId
    , .appendMessage "rv64im/kernel_opening_claim/stages_digest" claim.stages.digest
    , .appendMessage "rv64im/kernel_opening_claim/terminal_digest" claim.terminal.digest
    ]

def jointOpeningClaimBindingDigest (binding : JointOpeningClaimBindingView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/joint_opening_claim_binding"
    [ .appendMessage
        "rv64im/joint_opening_claim_binding/proof_statement_digest"
        binding.proofStatementDigest
    , .appendMessage
        "rv64im/joint_opening_claim_binding/main_lane_claim_digest"
        binding.mainLaneClaimDigest
    , .appendMessage
        "rv64im/joint_opening_claim_binding/kernel_opening_claim_digest"
        binding.kernelOpeningClaimDigest
    ]

def jointOpeningClaimDigest (claim : JointOpeningClaimView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/joint_opening_claim"
    [ .appendMessage "rv64im/joint_opening_claim/root_params_id" claim.rootParamsId
    , .appendMessage "rv64im/joint_opening_claim/binding_digest" claim.binding.digest
    ]

def root0StageClaimBindingDigest (binding : Root0StageClaimBindingView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/root0_stage_claim_binding"
    [ .appendMessage "rv64im/root0_stage_claim_binding/stage1_digest" binding.stage1Digest
    , .appendMessage "rv64im/root0_stage_claim_binding/stage2_digest" binding.stage2Digest
    , .appendMessage "rv64im/root0_stage_claim_binding/stage3_digest" binding.stage3Digest
    ]

def root0TerminalClaimBindingDigest (binding : Root0TerminalClaimBindingView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/root0_terminal_claim_binding"
    [ .appendMessage "rv64im/root0_terminal_claim_binding/root0_digest" binding.root0Digest
    , .appendMessage "rv64im/root0_terminal_claim_binding/execution_digest" binding.executionDigest
    , .appendMessage "rv64im/root0_terminal_claim_binding/final_state_digest" binding.finalStateDigest
    , .appendMessage
        "rv64im/root0_terminal_claim_binding/transcript_final_digest"
        binding.transcriptFinalDigest
    ]

def root0ClaimDigest (claim : Root0ClaimView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/root0_claim"
    [ .appendMessage "rv64im/root0_claim/root_params_id" claim.rootParamsId
    , .appendMessage "rv64im/root0_claim/stages_digest" claim.stages.digest
    , .appendMessage "rv64im/root0_claim/terminal_digest" claim.terminal.digest
    ]

def kernelClaimBundleDigest (claims : KernelClaimBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/kernel_claim_bundle"
    [ .appendMessage "rv64im/kernel_claim_bundle/accepted_digest" claims.accepted.digest
    , .appendMessage "rv64im/kernel_claim_bundle/main_lane_digest" claims.mainLane.digest
    , .appendMessage "rv64im/kernel_claim_bundle/opening_digest" claims.opening.digest
    , .appendMessage
        "rv64im/kernel_claim_bundle/joint_opening_digest"
        claims.jointOpening.digest
    , .appendMessage "rv64im/kernel_claim_bundle/root0_digest" claims.root0.digest
    ]

def mainLaneProofBindingDigest (binding : MainLaneProofBindingView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/main_lane_proof_binding"
    [ .appendMessage
        "rv64im/main_lane_proof_binding/root_lane_columns_digest"
        binding.rootLaneColumnsDigest
    , .appendMessage
        "rv64im/main_lane_proof_binding/root_lane_commitment_digest"
        binding.rootLaneCommitmentDigest
    , .appendU64s
        "rv64im/main_lane_proof_binding/fold_schedule"
        (foldScheduleWords binding.foldSchedule)
    , .appendU64s
        "rv64im/main_lane_proof_binding/meta"
        [binding.chunkCount, binding.publicStepCount]
    ]

def ajtaiFamilyName : Nat → List Byte
  | 0 => utf8Bytes "root_main_lane_columns"
  | 1 => utf8Bytes "stage1_rows"
  | 2 => utf8Bytes "stage2_register_reads"
  | 3 => utf8Bytes "stage2_register_writes"
  | 4 => utf8Bytes "stage2_ram_events"
  | 5 => utf8Bytes "stage2_twist_links"
  | 6 => utf8Bytes "stage3_continuity"
  | 7 => utf8Bytes "kernel_bindings"
  | 8 => utf8Bytes "kernel_prepared_steps"
  | 9 => utf8Bytes "root_main_lane_public_steps"
  | 10 => utf8Bytes "root_main_lane_committed_rows"
  | _ => []

def ajtaiObjectIdDigest (object : AjtaiObjectIdView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/ajtai_object_id"
    [ .appendU64s
        "rv64im/ajtai_object_id/meta"
        [object.familyTag, object.layoutVersion]
    , .appendMessage "rv64im/ajtai_object_id/family" (ajtaiFamilyName object.familyTag)
    , .appendMessage "rv64im/ajtai_object_id/commitment_digest" object.commitmentDigest
    ]

def ajtaiOpeningIdDigest (opening : AjtaiOpeningIdView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/ajtai_opening_id"
    [ .appendMessage "rv64im/ajtai_opening_id/object_digest" opening.object.digest
    , .appendU64s "rv64im/ajtai_opening_id/logical_index" [opening.logicalIndex]
    ]

def selectedOpeningRefDigest (reference : SelectedOpeningRefView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/selected_opening_ref"
    [ .appendMessage "rv64im/selected_opening_ref/opening_id" reference.id.digest
    , .appendMessage "rv64im/selected_opening_ref/value_digest" reference.valueDigest
    ]

def mainLaneSurfaceDigest (surface : MainLaneSurfaceView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/main_lane_surface"
    ([ .appendMessage "rv64im/main_lane_surface/object_digest" surface.objectDigest
     , .appendMessage "rv64im/main_lane_surface/family_digest" surface.familyDigest
     , .appendU64s
         "rv64im/main_lane_surface/meta"
         [surface.rowWidth, surface.publicStepCount]
     , .appendU64s
         "rv64im/main_lane_surface/first_present"
         [boolWord surface.firstPublicStep.isSome]
     ] ++
       (match surface.firstPublicStep with
       | some reference => [TranscriptOp.appendMessage "rv64im/main_lane_surface/first_digest" reference.digest]
       | none => []) ++
       [ .appendU64s
           "rv64im/main_lane_surface/last_present"
           [boolWord surface.lastPublicStep.isSome]
       ] ++
       (match surface.lastPublicStep with
       | some reference => [TranscriptOp.appendMessage "rv64im/main_lane_surface/last_digest" reference.digest]
       | none => []))

def rootLaneColumnsDigest (bundle : RootLaneColumnsView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/root_lane_columns"
    ([ .appendMessage "rv64im/root_lane_columns/object_digest" bundle.object.digest
     , .appendU64s
         "rv64im/root_lane_columns/meta"
         [bundle.rowWidth, bundle.timeLen, bundle.columnDigests.length]
     , .appendMessage "rv64im/root_lane_columns/family_digest" bundle.familyDigest
     ] ++
      bundle.columnDigests.map (fun digest =>
        TranscriptOp.appendMessage "rv64im/root_lane_columns/column_digest" digest) ++
      [ .appendU64s
          "rv64im/root_lane_columns/first_present"
          [boolWord bundle.firstRow.isSome]
      ] ++
      (match bundle.firstRow with
      | some reference => [TranscriptOp.appendMessage "rv64im/root_lane_columns/first_digest" reference.digest]
      | none => []) ++
      [ .appendU64s
          "rv64im/root_lane_columns/last_present"
          [boolWord bundle.lastRow.isSome]
      ] ++
      (match bundle.lastRow with
      | some reference => [TranscriptOp.appendMessage "rv64im/root_lane_columns/last_digest" reference.digest]
      | none => []))

def rootLaneCommitmentArtifactDigest (artifact : RootLaneCommitmentArtifactView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/root_lane_commitment_artifact"
    ([ .appendU64s
         "rv64im/root_lane_commitment_artifact/meta"
         [artifact.timeLen]
     , .appendMessage
         "rv64im/root_lane_commitment_artifact/commitments_digest"
         artifact.commitments.digest
     , .appendU64s
         "rv64im/root_lane_commitment_artifact/first_present"
         [boolWord artifact.firstSelectedRow.isSome]
     ] ++
      (match artifact.firstSelectedRow with
      | some reference =>
          [TranscriptOp.appendMessage "rv64im/root_lane_commitment_artifact/first_digest" reference.digest]
      | none => []) ++
      [ .appendU64s
          "rv64im/root_lane_commitment_artifact/last_present"
          [boolWord artifact.lastSelectedRow.isSome]
      ] ++
      (match artifact.lastSelectedRow with
      | some reference =>
          [TranscriptOp.appendMessage "rv64im/root_lane_commitment_artifact/last_digest" reference.digest]
      | none => []))

def validRootLaneColumnsOpeningRefAt
    (bundle : RootLaneColumnsView)
    (reference : SelectedOpeningRefView)
    (logicalIndex : Nat) : Bool :=
  ajtaiObjectIdDigest reference.id.object = reference.id.object.digest &&
    ajtaiOpeningIdDigest reference.id = reference.id.digest &&
    selectedOpeningRefDigest reference = reference.digest &&
    reference.id.object.familyTag = 0 &&
    reference.id.object.commitmentDigest = bundle.familyDigest &&
    reference.id.object.digest = bundle.object.digest &&
    reference.id.logicalIndex = logicalIndex

def mainLaneProofBundleDigest (bundle : MainLaneProofBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/main_lane_proof_bundle"
    [ .appendMessage "rv64im/main_lane_proof_bundle/binding_digest" bundle.binding.digest
    , .appendMessage "rv64im/main_lane_proof_bundle/statement_digest" bundle.statementDigest
    , .appendMessage "rv64im/main_lane_proof_bundle/proof_digest" bundle.proofDigest
    ]

def mainLaneProofSummaryBundleDigest (bundle : MainLaneProofSummaryBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/main_lane_proof_summary_bundle"
    [ .appendMessage "rv64im/main_lane_proof_summary_bundle/binding_digest" bundle.binding.digest ]

def mainLaneSurfaceOfRootLaneColumns (bundle : RootLaneColumnsView) : MainLaneSurfaceView :=
  let surface :
      MainLaneSurfaceView :=
    { objectDigest := bundle.object.digest
    , familyDigest := bundle.familyDigest
    , rowWidth := bundle.rowWidth
    , publicStepCount := bundle.timeLen
    , firstPublicStep := bundle.firstRow
    , lastPublicStep := bundle.lastRow
    , digest := [] }
  { surface with digest := mainLaneSurfaceDigest surface }

def traceShapeBundleDigest (shape : TraceShapeBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/trace_shape_bundle"
    [ .appendU64s
        "rv64im/trace_shape_bundle/meta"
        [shape.executionRowCount, shape.realRowCount, shape.effectRowCount, shape.commitRowCount]
    ]

def traceProjectionBundleDigest (bundle : TraceProjectionBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/trace_summary_proof_bundle"
    ([ .appendMessage "rv64im/trace_summary_proof_bundle/name" (utf8Bytes bundle.manifest.name)
     , .appendMessage "rv64im/trace_summary_proof_bundle/fixture_id" (utf8Bytes bundle.manifest.fixtureId)
     , .appendU64s
         "rv64im/trace_summary_proof_bundle/meta"
         [bundle.manifest.protocolVersionId, bundle.manifest.loweringVersionId]
     , .appendU64s
         "rv64im/trace_summary_proof_bundle/family_tag_len"
         [bundle.manifest.familyTags.length]
     ] ++
      bundle.manifest.familyTags.map (fun family =>
        TranscriptOp.appendU64s "rv64im/trace_summary_proof_bundle/family_tag" [familyWord family]) ++
      [ .appendMessage "rv64im/trace_summary_proof_bundle/execution_digest" bundle.executionDigest
      , .appendMessage "rv64im/trace_summary_proof_bundle/shape_digest" bundle.shape.digest
      ])

def traceSummaryProjectionBundleDigest (bundle : TraceProjectionBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/trace_summary_proof_bundle"
    ([ .appendMessage "rv64im/trace_summary_proof_bundle/name" (utf8Bytes bundle.manifest.name)
     , .appendMessage "rv64im/trace_summary_proof_bundle/fixture_id" (utf8Bytes bundle.manifest.fixtureId)
     , .appendU64s
         "rv64im/trace_summary_proof_bundle/meta"
         [bundle.manifest.protocolVersionId, bundle.manifest.loweringVersionId]
     , .appendU64s
         "rv64im/trace_summary_proof_bundle/family_tag_len"
         [bundle.manifest.familyTags.length]
     ] ++
      bundle.manifest.familyTags.map (fun family =>
        TranscriptOp.appendU64s "rv64im/trace_summary_proof_bundle/family_tag" [familyWord family]) ++
      [ .appendMessage "rv64im/trace_summary_proof_bundle/execution_digest" bundle.executionDigest
      , .appendMessage "rv64im/trace_summary_proof_bundle/shape_digest" bundle.shape.digest
      ])

def stageWitnessSummaryBundleDigest (bundle : StageWitnessSummaryBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/stage_witness_summary_bundle"
    [ .appendU64s
        "rv64im/stage_witness_summary_bundle/meta"
        [ bundle.stage1RowCount
        , bundle.stage2RegisterReadCount
        , bundle.stage2RegisterWriteCount
        , bundle.stage2RamEventCount
        , bundle.stage2TwistLinkCount
        , bundle.stage3ContinuityCount
        , boolWord bundle.stage3Halted
        , bundle.transcriptEventCount
        ]
    ]

def stageWitnessProjectionBundleDigest (bundle : StageWitnessProjectionBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/stage_witness_summary_proof_bundle"
    [ .appendMessage "rv64im/stage_witness_summary_proof_bundle/summary" bundle.summary.digest ]

def stageWitnessSummaryProjectionBundleDigest (bundle : StageWitnessProjectionBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/stage_witness_summary_proof_bundle"
    [ .appendMessage "rv64im/stage_witness_summary_proof_bundle/summary" bundle.summary.digest ]

def stageClaimDigestBundleDigest (bundle : StageClaimDigestBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/stage_claim_digest_bundle"
    [ .appendMessage
        "rv64im/stage_claim_digest_bundle/claim_bundle_digest"
        bundle.claimBundleDigest
    , .appendMessage "rv64im/stage_claim_digest_bundle/stage1_digest" bundle.stage1Digest
    , .appendMessage "rv64im/stage_claim_digest_bundle/stage2_digest" bundle.stage2Digest
    , .appendMessage "rv64im/stage_claim_digest_bundle/stage3_digest" bundle.stage3Digest
    , .appendMessage "rv64im/stage_claim_digest_bundle/transcript_digest" bundle.transcriptDigest
    , .appendMessage "rv64im/stage_claim_digest_bundle/execution_digest" bundle.executionDigest
    ]

def stageClaimProofBundleDigest (bundle : StageClaimProofBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/stage_claim_proof_bundle"
    [ .appendMessage "summary_digest" bundle.summary.digest
    , .appendMessage "statement_digest" bundle.statementDigest
    , .appendMessage "proof_digest" bundle.proofDigest
    ]

def stageClaimSummaryProofBundleDigest (bundle : StageClaimProofBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/stage_claim_summary_proof_bundle"
    [ .appendMessage "rv64im/stage_claim_summary_proof_bundle/summary" bundle.summary.digest ]

def stagePackageDigestBundleDigest (bundle : StagePackageDigestBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/stage_package_digest_bundle"
    [ .appendMessage
        "rv64im/stage_package_digest_bundle/package_bundle_digest"
        bundle.packageBundleDigest
    , .appendMessage "rv64im/stage_package_digest_bundle/stage1_digest" bundle.stage1Digest
    , .appendMessage "rv64im/stage_package_digest_bundle/stage2_digest" bundle.stage2Digest
    , .appendMessage "rv64im/stage_package_digest_bundle/stage3_digest" bundle.stage3Digest
    ]

def stagePackageProofBundleDigest (bundle : StagePackageProofBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/stage_package_proof_bundle"
    [ .appendMessage "rv64im/stage_package_proof_bundle/summary" bundle.summary.digest ]

def stagePackageSummaryProofBundleDigest (bundle : StagePackageProofBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/stage_package_summary_proof_bundle"
    [ .appendMessage "rv64im/stage_package_summary_proof_bundle/summary" bundle.summary.digest ]

def kernelOpeningBindingBundleDigest (bundle : KernelOpeningBindingBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/kernel_opening_binding_bundle"
    [ .appendMessage "rv64im/kernel_opening_binding_bundle/claim_digest" bundle.claimDigest
    , .appendMessage "rv64im/kernel_opening_binding_bundle/bindings_digest" bundle.bindingsDigest
    , .appendMessage
        "rv64im/kernel_opening_binding_bundle/prepared_steps_digest"
        bundle.preparedStepsDigest
    ]

def kernelOpeningProofBundleDigest (bundle : KernelOpeningProofBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/kernel_opening_proof_bundle"
    [ .appendMessage "rv64im/kernel_opening_proof_bundle/opening_digest" bundle.openingDigest
    , .appendMessage "rv64im/kernel_opening_proof_bundle/bindings" bundle.bindings.digest
    ]

def kernelOpeningSummaryProofBundleDigest (bundle : KernelOpeningProofBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/kernel_opening_summary_bundle"
    [ .appendMessage "rv64im/kernel_opening_summary_bundle/opening_digest" bundle.openingDigest
    , .appendMessage
        "rv64im/kernel_opening_summary_bundle/bindings_digest"
        bundle.bindings.digest
    ]

def kernelOpeningSummaryBundleDigest (bundle : KernelOpeningSummaryBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/kernel_opening_summary_bundle"
    [ .appendMessage "rv64im/kernel_opening_summary_bundle/opening_digest" bundle.openingDigest
    , .appendMessage
        "rv64im/kernel_opening_summary_bundle/bindings_digest"
        bundle.bindings.digest
    ]

def kernelClaimTerminalBundleDigest (bundle : KernelClaimTerminalBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/kernel_claim_terminal_bundle"
    [ .appendMessage "rv64im/kernel_claim_terminal_bundle/root0_digest" bundle.root0Digest
    , .appendMessage "rv64im/kernel_claim_terminal_bundle/execution_digest" bundle.executionDigest
    , .appendMessage
        "rv64im/kernel_claim_terminal_bundle/final_state_digest"
        bundle.finalStateDigest
    , .appendMessage
        "rv64im/kernel_claim_terminal_bundle/transcript_final_digest"
        bundle.transcriptFinalDigest
    , .appendU64s
        "rv64im/kernel_claim_terminal_bundle/meta"
        [bundle.finalPc, boolWord bundle.halted]
    ]

def kernelClaimSummaryBundleDigest (bundle : KernelClaimSummaryBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/kernel_claim_summary_bundle"
    [ .appendMessage
        "rv64im/kernel_claim_summary_bundle/prepared_step_bindings_digest"
        bundle.preparedStepBindingsDigest
    , .appendMessage "rv64im/kernel_claim_summary_bundle/terminal_digest" bundle.terminal.digest
    ]

def kernelClaimProofBundleDigest (bundle : KernelClaimProofBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/kernel_claim_proof_bundle"
    [ .appendMessage "summary_digest" bundle.summary.digest
    , .appendMessage "statement_digest" bundle.statementDigest
    , .appendMessage "proof_digest" bundle.proofDigest
    ]

def kernelClaimSummaryProofBundleDigest (bundle : KernelClaimProofBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/kernel_claim_summary_proof_bundle"
    [ .appendMessage "rv64im/kernel_claim_summary_proof_bundle/summary" bundle.summary.digest ]

def mainLaneProofSummaryOfBundle (bundle : MainLaneProofBundleView) :
    MainLaneProofSummaryBundleView :=
  { binding := bundle.binding
  , digest :=
      mainLaneProofSummaryBundleDigest
        { binding := bundle.binding, digest := [] } }

def kernelOpeningSummaryOfProof (bundle : KernelOpeningProofBundleView) :
    KernelOpeningSummaryBundleView :=
  { openingDigest := bundle.openingDigest
  , bindings := bundle.bindings
  , digest :=
      kernelOpeningSummaryBundleDigest
        { openingDigest := bundle.openingDigest, bindings := bundle.bindings, digest := [] } }

def jointOpeningBundleDigest
    (mainLane : MainLaneProofSummaryBundleView)
    (kernelOpening : KernelOpeningProofBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/joint_opening_proof_bundle"
    [ .appendMessage
        "rv64im/joint_opening_proof_bundle/main_lane_digest"
        mainLane.digest
    , .appendMessage
        "rv64im/joint_opening_proof_bundle/kernel_opening_digest"
        kernelOpening.digest
    ]

def root0CommitmentBundleDigest
    (kernelOpening : KernelOpeningProofBundleView)
    (kernelClaims : KernelClaimSummaryBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/root0_commitment_bundle"
    [ .appendMessage
        "rv64im/root0_commitment_bundle/kernel_opening_digest"
        kernelOpening.digest
    , .appendMessage
        "rv64im/root0_commitment_bundle/kernel_claims_digest"
        kernelClaims.digest
    ]

def kernelProofBundleDigest (bundle : KernelProofBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/kernel_proof_bundle"
    [ .appendMessage "rv64im/kernel_proof_bundle/root_params_id" bundle.rootParamsId
    , .appendMessage "rv64im/kernel_proof_bundle/trace_digest" bundle.trace.digest
    , .appendMessage "rv64im/kernel_proof_bundle/stages_digest" bundle.stages.digest
    , .appendMessage
        "rv64im/kernel_proof_bundle/stage_claims_digest"
        bundle.stageClaims.digest
    , .appendMessage
        "rv64im/kernel_proof_bundle/stage_packages_digest"
        bundle.stagePackages.digest
    , .appendMessage
        "rv64im/kernel_proof_bundle/kernel_opening_digest"
        bundle.kernelOpening.digest
    , .appendMessage
        "rv64im/kernel_proof_bundle/kernel_claims_digest"
        bundle.kernelClaims.digest
    , .appendMessage
        "rv64im/kernel_proof_bundle/root_lane_columns_digest"
        bundle.rootLaneColumns.digest
    , .appendMessage
        "rv64im/kernel_proof_bundle/root_lane_commitment_digest"
        bundle.rootLaneCommitment.digest
    , .appendMessage "rv64im/kernel_proof_bundle/main_lane_digest" bundle.mainLane.digest
    ]

def parityCaseByName? (name : String) : Option (ParitySourceCase × ParityDerivedCase) :=
  Generated.parityCases.find? (fun (source, _) => source.manifest.name = name)

def validStatementDigest (statement : ProofStatementView) : Bool :=
  proofStatementDigest statement = statement.digest

def validClaimDigests (claims : KernelClaimBundleView) : Bool :=
  acceptedProofStatementBindingDigest claims.accepted.statement = claims.accepted.statement.digest &&
    acceptedProofMainLaneBindingDigest claims.accepted.mainLane = claims.accepted.mainLane.digest &&
    acceptedProofTerminalBindingDigest claims.accepted.terminal = claims.accepted.terminal.digest &&
    acceptedProofClaimDigest claims.accepted = claims.accepted.digest &&
    mainLaneClaimBindingDigest claims.mainLane.binding = claims.mainLane.binding.digest &&
    mainLaneClaimDigest claims.mainLane = claims.mainLane.digest &&
    kernelOpeningStageClaimBindingDigest claims.opening.stages = claims.opening.stages.digest &&
    kernelOpeningTerminalClaimBindingDigest claims.opening.terminal = claims.opening.terminal.digest &&
    kernelOpeningClaimDigest claims.opening = claims.opening.digest &&
    jointOpeningClaimBindingDigest claims.jointOpening.binding = claims.jointOpening.binding.digest &&
    jointOpeningClaimDigest claims.jointOpening = claims.jointOpening.digest &&
    root0StageClaimBindingDigest claims.root0.stages = claims.root0.stages.digest &&
    root0TerminalClaimBindingDigest claims.root0.terminal = claims.root0.terminal.digest &&
    root0ClaimDigest claims.root0 = claims.root0.digest &&
    kernelClaimBundleDigest claims = claims.digest

def validMainLaneOpeningRefAt
    (surface : MainLaneSurfaceView)
    (reference : SelectedOpeningRefView)
    (logicalIndex : Nat) : Bool :=
  ajtaiObjectIdDigest reference.id.object = reference.id.object.digest &&
    ajtaiOpeningIdDigest reference.id = reference.id.digest &&
    selectedOpeningRefDigest reference = reference.digest &&
    reference.id.object.familyTag = 0 &&
    reference.id.object.commitmentDigest = surface.familyDigest &&
    reference.id.object.digest = surface.objectDigest &&
    reference.id.logicalIndex = logicalIndex

def kernelProofDigestCheckResults (kernel : KernelProofBundleView) : List (String × Bool) :=
  let mainLaneSummary := mainLaneProofSummaryOfBundle kernel.mainLane
  let kernelOpeningSummary := kernelOpeningSummaryOfProof kernel.kernelOpening
  let mainLaneSurface := mainLaneSurfaceOfRootLaneColumns kernel.rootLaneColumns
  [ ("traceShapeDigest", traceShapeBundleDigest kernel.trace.shape = kernel.trace.shape.digest)
  , ("traceDigest", traceProjectionBundleDigest kernel.trace = kernel.trace.digest)
  , ("stageWitnessSummaryDigest", stageWitnessSummaryBundleDigest kernel.stages.summary = kernel.stages.summary.digest)
  , ("stageWitnessDigest", stageWitnessProjectionBundleDigest kernel.stages = kernel.stages.digest)
  , ("stageClaimSummaryDigest", stageClaimDigestBundleDigest kernel.stageClaims.summary = kernel.stageClaims.summary.digest)
  , ("stageClaimDigest", stageClaimProofBundleDigest kernel.stageClaims = kernel.stageClaims.digest)
  , ("stagePackageSummaryDigest", stagePackageDigestBundleDigest kernel.stagePackages.summary = kernel.stagePackages.summary.digest)
  , ("stagePackageDigest", stagePackageProofBundleDigest kernel.stagePackages = kernel.stagePackages.digest)
  , ("kernelOpeningBindingDigest", kernelOpeningBindingBundleDigest kernel.kernelOpening.bindings = kernel.kernelOpening.bindings.digest)
  , ("kernelOpeningDigest", kernelOpeningProofBundleDigest kernel.kernelOpening = kernel.kernelOpening.digest)
  , ("kernelOpeningSummaryDigest", kernelOpeningSummaryBundleDigest kernelOpeningSummary = kernelOpeningSummary.digest)
  , ("kernelClaimTerminalDigest", kernelClaimTerminalBundleDigest kernel.kernelClaims.summary.terminal =
      kernel.kernelClaims.summary.terminal.digest)
  , ("kernelClaimSummaryDigest", kernelClaimSummaryBundleDigest kernel.kernelClaims.summary = kernel.kernelClaims.summary.digest)
  , ("kernelClaimDigest", kernelClaimProofBundleDigest kernel.kernelClaims = kernel.kernelClaims.digest)
  , ("rootLaneObjectDigest", ajtaiObjectIdDigest kernel.rootLaneColumns.object = kernel.rootLaneColumns.object.digest)
  , ("rootLaneColumnsDigest", rootLaneColumnsDigest kernel.rootLaneColumns = kernel.rootLaneColumns.digest)
  , ("rootLaneFirstRef", match kernel.rootLaneColumns.firstRow with
      | some reference => validRootLaneColumnsOpeningRefAt kernel.rootLaneColumns reference 0
      | none => true)
  , ("rootLaneLastRef", match kernel.rootLaneColumns.lastRow with
      | some reference =>
          validRootLaneColumnsOpeningRefAt
            kernel.rootLaneColumns
            reference
            (kernel.rootLaneColumns.timeLen - 1)
      | none => true)
  , ("rootLaneCommitmentDigest", rootLaneCommitmentArtifactDigest kernel.rootLaneCommitment = kernel.rootLaneCommitment.digest)
  , ("mainLaneBindingDigest", mainLaneProofBindingDigest kernel.mainLane.binding = kernel.mainLane.binding.digest)
  , ("mainLaneSurfaceDigest", mainLaneSurfaceDigest mainLaneSurface = mainLaneSurface.digest)
  , ("mainLaneFirstRef", match mainLaneSurface.firstPublicStep with
      | some reference => validMainLaneOpeningRefAt mainLaneSurface reference 0
      | none => true)
  , ("mainLaneLastRef", match mainLaneSurface.lastPublicStep with
      | some reference =>
          validMainLaneOpeningRefAt
            mainLaneSurface
            reference
            (mainLaneSurface.publicStepCount - 1)
      | none => true)
  , ("mainLaneDigest", mainLaneProofBundleDigest kernel.mainLane = kernel.mainLane.digest)
  , ("mainLaneSummaryDigest", mainLaneProofSummaryBundleDigest mainLaneSummary = mainLaneSummary.digest)
  , ("kernelProofDigest", kernelProofBundleDigest kernel = kernel.digest)
  ]

def validKernelProofDigests (kernel : KernelProofBundleView) : Bool :=
  (kernelProofDigestCheckResults kernel).all Prod.snd

def statementMatchesKernelAndDerived
    (statement : ProofStatementView)
    (kernel : KernelProofBundleView)
    (derived : ParityDerivedCase) : Bool :=
  let mainLaneSurface := mainLaneSurfaceOfRootLaneColumns kernel.rootLaneColumns
  chunkScheduleMatches statement.foldSchedule statement.chunkCount statement.publicStepCount &&
    statement.foldSchedule = kernel.mainLane.binding.foldSchedule &&
    statement.chunkCount = kernel.mainLane.binding.chunkCount &&
    statement.stageClaimsDigest = kernel.stageClaims.digest &&
    statement.stagePackagesDigest = kernel.stagePackages.digest &&
    statement.kernelOpeningDigest = kernel.kernelOpening.digest &&
    statement.preparedStepBindingsDigest = kernel.kernelClaims.summary.preparedStepBindingsDigest &&
    statement.executionDigest = derived.kernel.executionDigest &&
    statement.executionDigest = kernel.trace.executionDigest &&
    statement.executionDigest = kernel.stageClaims.summary.executionDigest &&
    statement.executionDigest = kernel.kernelClaims.summary.terminal.executionDigest &&
    statement.finalStateDigest = derived.kernel.finalStateDigest &&
    statement.finalStateDigest = kernel.kernelClaims.summary.terminal.finalStateDigest &&
    statement.transcriptFinalDigest = derived.kernel.transcriptFinalDigest &&
    statement.transcriptFinalDigest = kernel.stageClaims.summary.transcriptDigest &&
    statement.transcriptFinalDigest = kernel.kernelClaims.summary.terminal.transcriptFinalDigest &&
    statement.mainLaneSurfaceDigest = mainLaneSurface.digest &&
    statement.rootLaneColumnsDigest = kernel.rootLaneColumns.digest &&
    statement.publicStepCount = derived.executionRows.length &&
    statement.finalPc = derived.kernel.finalPc &&
    statement.finalPc = kernel.kernelClaims.summary.terminal.finalPc &&
    statement.halted = derived.kernel.halted &&
    statement.halted = kernel.kernelClaims.summary.terminal.halted

def claimsMatchStatementAndKernel
    (statement : ProofStatementView)
    (claims : KernelClaimBundleView)
    (kernel : KernelProofBundleView)
    (derived : ParityDerivedCase) : Bool :=
  claims.accepted.rootParamsId = statement.rootParamsId &&
    claims.accepted.rootParamsId = kernel.rootParamsId &&
    claims.accepted.statement.proofStatementDigest = statement.digest &&
    claims.accepted.statement.kernelOpeningDigest = statement.kernelOpeningDigest &&
    claims.accepted.mainLane.mainLaneBundleDigest = kernel.mainLane.digest &&
    claims.accepted.terminal.finalStateDigest = statement.finalStateDigest &&
    claims.accepted.terminal.finalPc = statement.finalPc &&
    claims.accepted.terminal.halted = statement.halted &&
    claims.mainLane.rootParamsId = statement.rootParamsId &&
    claims.mainLane.binding.mainLaneBundleDigest = kernel.mainLane.digest &&
    claims.opening.rootParamsId = statement.rootParamsId &&
    claims.opening.stages.stageClaimsDigest = statement.stageClaimsDigest &&
    claims.opening.stages.stagePackagesDigest = statement.stagePackagesDigest &&
    claims.opening.stages.kernelOpeningDigest = statement.kernelOpeningDigest &&
    claims.opening.terminal.preparedStepBindingsDigest = statement.preparedStepBindingsDigest &&
    claims.opening.terminal.executionDigest = statement.executionDigest &&
    claims.opening.terminal.transcriptFinalDigest = statement.transcriptFinalDigest &&
    claims.jointOpening.rootParamsId = statement.rootParamsId &&
    claims.jointOpening.binding.proofStatementDigest = statement.digest &&
    claims.jointOpening.binding.mainLaneClaimDigest = claims.mainLane.digest &&
    claims.jointOpening.binding.kernelOpeningClaimDigest = claims.opening.digest &&
    claims.root0.rootParamsId = statement.rootParamsId &&
    claims.root0.stages.stage1Digest = derived.kernel.stage1Digest &&
    claims.root0.stages.stage2Digest = derived.kernel.stage2Digest &&
    claims.root0.stages.stage3Digest = derived.kernel.stage3Digest &&
    claims.root0.terminal.root0Digest = derived.kernel.root0Digest &&
    claims.root0.terminal.root0Digest = kernel.kernelClaims.summary.terminal.root0Digest &&
    claims.root0.terminal.executionDigest = statement.executionDigest &&
    claims.root0.terminal.finalStateDigest = statement.finalStateDigest &&
    claims.root0.terminal.transcriptFinalDigest = statement.transcriptFinalDigest

def kernelProofMatchesDerivedAndClaims
    (kernel : KernelProofBundleView)
    (derived : ParityDerivedCase) : Bool :=
  let mainLaneSurface := mainLaneSurfaceOfRootLaneColumns kernel.rootLaneColumns
  kernel.trace.manifest = derived.manifest &&
    chunkScheduleMatches
      kernel.mainLane.binding.foldSchedule
      kernel.mainLane.binding.chunkCount
      kernel.mainLane.binding.publicStepCount &&
    kernel.trace.executionDigest = derived.kernel.executionDigest &&
    kernel.trace.shape.executionRowCount = derived.executionRows.length &&
    kernel.trace.shape.realRowCount = (derived.executionRows.filter (·.isReal)).length &&
    kernel.trace.shape.effectRowCount = (derived.executionRows.filter (·.isEffectRow)).length &&
    kernel.trace.shape.commitRowCount = (derived.executionRows.filter (·.isCommitRow)).length &&
    kernel.stages.summary.stage1RowCount = derived.stage1.rows.length &&
    kernel.stages.summary.stage2RegisterReadCount = derived.stage2.registerReads.length &&
    kernel.stages.summary.stage2RegisterWriteCount = derived.stage2.registerWrites.length &&
    kernel.stages.summary.stage2RamEventCount = derived.stage2.ramEvents.length &&
    kernel.stages.summary.stage2TwistLinkCount = derived.stage2.twistLinks.length &&
    kernel.stages.summary.stage3ContinuityCount = derived.stage3.continuity.length &&
    kernel.stages.summary.stage3Halted = derived.stage3.halted &&
    kernel.stages.summary.transcriptEventCount = derived.transcript.events.length &&
    kernel.kernelClaims.summary.terminal.root0Digest = derived.kernel.root0Digest &&
    kernel.kernelClaims.summary.terminal.executionDigest = derived.kernel.executionDigest &&
    kernel.kernelClaims.summary.terminal.finalStateDigest = derived.kernel.finalStateDigest &&
    kernel.kernelClaims.summary.terminal.transcriptFinalDigest = derived.kernel.transcriptFinalDigest &&
    kernel.kernelClaims.summary.terminal.finalPc = derived.kernel.finalPc &&
    kernel.kernelClaims.summary.terminal.halted = derived.kernel.halted &&
    kernel.rootLaneColumns.object.familyTag = 0 &&
    kernel.rootLaneColumns.object.commitmentDigest = kernel.rootLaneColumns.familyDigest &&
    kernel.rootLaneColumns.rowWidth = 38 &&
    kernel.rootLaneColumns.timeLen = derived.executionRows.length &&
    kernel.rootLaneColumns.columnDigests.length = kernel.rootLaneColumns.rowWidth &&
    kernel.rootLaneCommitment.timeLen = kernel.rootLaneColumns.timeLen &&
    kernel.rootLaneCommitment.commitments.commitmentCount = kernel.rootLaneColumns.rowWidth &&
    (match kernel.rootLaneCommitment.firstSelectedRow, kernel.rootLaneColumns.firstRow with
    | some reference, some columnRef =>
        reference.id.logicalIndex = 0 &&
        reference.valueDigest = columnRef.valueDigest
    | none, none => true
    | _, _ => false) &&
    (match kernel.rootLaneCommitment.lastSelectedRow, kernel.rootLaneColumns.lastRow with
    | some reference, some columnRef =>
        reference.id.logicalIndex = kernel.rootLaneColumns.timeLen - 1 &&
        reference.valueDigest = columnRef.valueDigest
    | none, none => true
    | _, _ => false) &&
    mainLaneSurface.objectDigest = kernel.rootLaneColumns.object.digest &&
    mainLaneSurface.familyDigest = kernel.rootLaneColumns.familyDigest &&
    mainLaneSurface.firstPublicStep = kernel.rootLaneColumns.firstRow &&
    mainLaneSurface.lastPublicStep = kernel.rootLaneColumns.lastRow &&
    mainLaneSurface.publicStepCount = derived.executionRows.length &&
    mainLaneSurface.rowWidth = 38 &&
    kernel.mainLane.binding.rootLaneColumnsDigest = kernel.rootLaneColumns.digest &&
    kernel.mainLane.binding.rootLaneCommitmentDigest = kernel.rootLaneCommitment.digest &&
    kernel.mainLane.binding.publicStepCount = kernel.rootLaneColumns.timeLen &&
    kernel.mainLane.binding.chunkCount =
      Nightstream.FoldSchedule.chunkCount
        kernel.mainLane.binding.foldSchedule
        kernel.mainLane.binding.publicStepCount

private def caseCheckResultsAgainstDerived
    (proofCase : PublicProofVectorCase)
    (derived : ParityDerivedCase) : List (String × Bool) :=
  let schema := publicProofSchemaOfCase proofCase
  [ ("exportedProofApiLockstep", exportedProofApiLockstep proofCase)
  , ( "publicProofSchemaLockstep"
    , schema.statement = proofCase.statement &&
        schema.claims = proofCase.claims &&
        schema.kernelProof = proofCase.kernelProof)
  , ("acceptedPublicProofLockstep", acceptedPublicProofLockstep proofCase)
  , ("statementDigest", validStatementDigest schema.statement)
  , ("claimDigests", validClaimDigests schema.claims)
  , ("kernelProofDigests", validKernelProofDigests schema.kernelProof)
  , ( "statementMatchesKernelAndDerived"
    , statementMatchesKernelAndDerived schema.statement schema.kernelProof derived)
  , ( "claimsMatchStatementAndKernel"
    , claimsMatchStatementAndKernel
        schema.statement
        schema.claims
        schema.kernelProof
        derived)
  , ( "kernelProofMatchesDerivedAndClaims"
    , kernelProofMatchesDerivedAndClaims schema.kernelProof derived)
  ]

private def caseCheckResults (proofCase : PublicProofVectorCase) : List (String × Bool) :=
  match parityCaseByName? proofCase.name with
  | none => [("parityCasePresent", false)]
  | some (_, derived) =>
      ("parityCasePresent", true) :: caseCheckResultsAgainstDerived proofCase derived

structure Rv64imPublicProofBoundaryReport where
  name : String
  checks : List (String × Bool)
deriving Repr

def checkPublicProofVectorCaseAgainstDerived
    (proofCase : PublicProofVectorCase)
    (derived : ParityDerivedCase) : Bool :=
  (caseCheckResultsAgainstDerived proofCase derived).all Prod.snd

def publicProofCaseCheckResultsAgainstDerived
    (proofCase : PublicProofVectorCase)
    (derived : ParityDerivedCase) : List (String × Bool) :=
  caseCheckResultsAgainstDerived proofCase derived

def checkPublicProofVectorCase (proofCase : PublicProofVectorCase) : Bool :=
  (caseCheckResults proofCase).all Prod.snd

def rv64imPublicProofBoundaryChecks : List Bool :=
  Generated.PublicProofVectors.cases.map checkPublicProofVectorCase

def validGeneratedRv64imPublicProofCases : Bool :=
  Generated.PublicProofVectors.cases.all checkPublicProofVectorCase

def rv64imPublicProofBoundaryReports : List Rv64imPublicProofBoundaryReport :=
  Generated.PublicProofVectors.cases.map fun proofCase =>
    { name := proofCase.name, checks := caseCheckResults proofCase }

end Nightstream.Rv64IM
