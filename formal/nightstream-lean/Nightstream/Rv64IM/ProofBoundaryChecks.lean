import Nightstream.Rv64IM.Generated.ImportedParityCorpus
import Nightstream.Rv64IM.Generated.PublicProofVectors.Corpus
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

private def boolWord (value : Bool) : Nat :=
  if value then 1 else 0

private def transcriptDigest (appLabel : String) (ops : List TranscriptOp) : List Byte :=
  let cursor0 := appendMessageCursor concreteCore emptyCursor poseidon2AppDomain (utf8Bytes appLabel)
  let cursor := runOps concreteCore cursor0 ops
  digestBytes concreteCore cursor

private def familyWord : FamilyTag → Nat
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

private def publicProofSchemaOfCase
    (proofCase : PublicProofVectorCase) :
    Rv64imRustPublicProofSchemaView :=
  { statement := proofCase.statement
  , claims := proofCase.claims
  , kernelProof := proofCase.kernelProof }

private def proofStatementDigest (statement : ProofStatementView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/proof_statement"
    [ .appendMessage "rv64im/proof_statement/root_params_id" statement.rootParamsId
    , .appendMessage "rv64im/proof_statement/stage_claims_digest" statement.stageClaimsDigest
    , .appendMessage "rv64im/proof_statement/stage_packages_digest" statement.stagePackagesDigest
    , .appendMessage "rv64im/proof_statement/kernel_opening_digest" statement.kernelOpeningDigest
    , .appendMessage "rv64im/proof_statement/prepared_step_bindings_digest" statement.preparedStepBindingsDigest
    , .appendMessage "rv64im/proof_statement/execution_digest" statement.executionDigest
    , .appendMessage "rv64im/proof_statement/final_state_digest" statement.finalStateDigest
    , .appendMessage "rv64im/proof_statement/transcript_final_digest" statement.transcriptFinalDigest
    , .appendMessage "rv64im/proof_statement/main_lane_statement_digest" statement.mainLaneStatementDigest
    , .appendU64s "rv64im/proof_statement/meta"
        [statement.publicStepCount, statement.finalPc, boolWord statement.halted]
    ]

private def acceptedProofStatementBindingDigest (binding : AcceptedProofStatementBindingView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/accepted_proof_statement_binding"
    [ .appendMessage
        "rv64im/accepted_proof_statement_binding/proof_statement_digest"
        binding.proofStatementDigest
    , .appendMessage
        "rv64im/accepted_proof_statement_binding/kernel_opening_digest"
        binding.kernelOpeningDigest
    ]

private def acceptedProofMainLaneBindingDigest (binding : AcceptedProofMainLaneBindingView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/accepted_proof_main_lane_binding"
    [ .appendMessage
        "rv64im/accepted_proof_main_lane_binding/main_lane_statement_digest"
        binding.mainLaneStatementDigest
    , .appendMessage
        "rv64im/accepted_proof_main_lane_binding/main_lane_proof_digest"
        binding.mainLaneProofDigest
    ]

private def acceptedProofTerminalBindingDigest (binding : AcceptedProofTerminalBindingView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/accepted_proof_terminal_binding"
    [ .appendMessage
        "rv64im/accepted_proof_terminal_binding/final_state_digest"
        binding.finalStateDigest
    , .appendU64s
        "rv64im/accepted_proof_terminal_binding/meta"
        [binding.publicStepCount, binding.finalPc, boolWord binding.halted]
    ]

private def acceptedProofClaimDigest (claim : AcceptedProofClaimView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/accepted_proof_claim"
    [ .appendMessage "rv64im/accepted_proof/root_params_id" claim.rootParamsId
    , .appendMessage "rv64im/accepted_proof/statement_digest" claim.statement.digest
    , .appendMessage "rv64im/accepted_proof/main_lane_digest" claim.mainLane.digest
    , .appendMessage "rv64im/accepted_proof/terminal_digest" claim.terminal.digest
    ]

private def mainLaneClaimBindingDigest (binding : MainLaneClaimBindingView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/main_lane_claim_binding"
    [ .appendMessage "rv64im/main_lane_claim_binding/statement_digest" binding.statementDigest
    , .appendMessage "rv64im/main_lane_claim_binding/proof_digest" binding.proofDigest
    , .appendU64s "rv64im/main_lane_claim_binding/meta" [binding.publicStepCount]
    ]

private def mainLaneClaimDigest (claim : MainLaneClaimView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/main_lane_claim"
    [ .appendMessage "rv64im/main_lane_claim/root_params_id" claim.rootParamsId
    , .appendMessage "rv64im/main_lane_claim/binding_digest" claim.binding.digest
    ]

private def kernelOpeningStageClaimBindingDigest
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

private def kernelOpeningTerminalClaimBindingDigest
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

private def kernelOpeningClaimDigest (claim : KernelOpeningClaimView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/kernel_opening_claim"
    [ .appendMessage "rv64im/kernel_opening_claim/root_params_id" claim.rootParamsId
    , .appendMessage "rv64im/kernel_opening_claim/stages_digest" claim.stages.digest
    , .appendMessage "rv64im/kernel_opening_claim/terminal_digest" claim.terminal.digest
    , .appendU64s "rv64im/kernel_opening_claim/meta" [claim.publicStepCount]
    ]

private def jointOpeningClaimBindingDigest (binding : JointOpeningClaimBindingView) : List Byte :=
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

private def jointOpeningClaimDigest (claim : JointOpeningClaimView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/joint_opening_claim"
    [ .appendMessage "rv64im/joint_opening_claim/root_params_id" claim.rootParamsId
    , .appendMessage "rv64im/joint_opening_claim/binding_digest" claim.binding.digest
    , .appendU64s "rv64im/joint_opening_claim/meta" [claim.publicStepCount]
    ]

private def root0StageClaimBindingDigest (binding : Root0StageClaimBindingView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/root0_stage_claim_binding"
    [ .appendMessage "rv64im/root0_stage_claim_binding/stage1_digest" binding.stage1Digest
    , .appendMessage "rv64im/root0_stage_claim_binding/stage2_digest" binding.stage2Digest
    , .appendMessage "rv64im/root0_stage_claim_binding/stage3_digest" binding.stage3Digest
    ]

private def root0TerminalClaimBindingDigest (binding : Root0TerminalClaimBindingView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/root0_terminal_claim_binding"
    [ .appendMessage "rv64im/root0_terminal_claim_binding/root0_digest" binding.root0Digest
    , .appendMessage "rv64im/root0_terminal_claim_binding/execution_digest" binding.executionDigest
    , .appendMessage "rv64im/root0_terminal_claim_binding/final_state_digest" binding.finalStateDigest
    , .appendMessage
        "rv64im/root0_terminal_claim_binding/transcript_final_digest"
        binding.transcriptFinalDigest
    ]

private def root0ClaimDigest (claim : Root0ClaimView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/root0_claim"
    [ .appendMessage "rv64im/root0_claim/root_params_id" claim.rootParamsId
    , .appendMessage "rv64im/root0_claim/stages_digest" claim.stages.digest
    , .appendMessage "rv64im/root0_claim/terminal_digest" claim.terminal.digest
    ]

private def kernelClaimBundleDigest (claims : KernelClaimBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/kernel_claim_bundle"
    [ .appendMessage "rv64im/kernel_claim_bundle/accepted_digest" claims.accepted.digest
    , .appendMessage "rv64im/kernel_claim_bundle/main_lane_digest" claims.mainLane.digest
    , .appendMessage "rv64im/kernel_claim_bundle/opening_digest" claims.opening.digest
    , .appendMessage
        "rv64im/kernel_claim_bundle/joint_opening_digest"
        claims.jointOpening.digest
    , .appendMessage "rv64im/kernel_claim_bundle/root0_digest" claims.root0.digest
    ]

private def mainLaneProofBindingDigest (binding : MainLaneProofBindingView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/main_lane_proof_binding"
    [ .appendMessage "rv64im/main_lane_proof_binding/statement_digest" binding.statementDigest
    , .appendMessage "rv64im/main_lane_proof_binding/proof_digest" binding.proofDigest
    , .appendU64s "rv64im/main_lane_proof_binding/meta" [binding.publicStepCount]
    ]

private def mainLaneProofBundleDigest (bundle : MainLaneProofBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/main_lane_proof_bundle"
    [ .appendMessage "rv64im/main_lane_proof_bundle/binding_digest" bundle.binding.digest ]

private def mainLaneProofSummaryBundleDigest (bundle : MainLaneProofSummaryBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/main_lane_proof_summary_bundle"
    [ .appendMessage "rv64im/main_lane_proof_summary_bundle/binding_digest" bundle.binding.digest ]

private def traceShapeBundleDigest (shape : TraceShapeBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/trace_shape_bundle"
    [ .appendU64s
        "rv64im/trace_shape_bundle/meta"
        [shape.executionRowCount, shape.realRowCount, shape.effectRowCount, shape.commitRowCount]
    ]

private def traceProofBundleDigest (bundle : TraceProofBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/trace_proof_bundle"
    ([ .appendMessage "rv64im/trace_proof_bundle/name" (utf8Bytes bundle.manifest.name)
     , .appendMessage "rv64im/trace_proof_bundle/fixture_id" (utf8Bytes bundle.manifest.fixtureId)
     , .appendU64s
         "rv64im/trace_proof_bundle/meta"
         [bundle.manifest.protocolVersionId, bundle.manifest.loweringVersionId]
     , .appendU64s
         "rv64im/trace_proof_bundle/family_tag_len"
         [bundle.manifest.familyTags.length]
     ] ++
      bundle.manifest.familyTags.map (fun family =>
        TranscriptOp.appendU64s "rv64im/trace_proof_bundle/family_tag" [familyWord family]) ++
      [ .appendMessage "rv64im/trace_proof_bundle/execution_digest" bundle.executionDigest
      , .appendMessage "rv64im/trace_proof_bundle/shape_digest" bundle.shape.digest
      ])

private def stageWitnessSummaryBundleDigest (bundle : StageWitnessSummaryBundleView) : List Byte :=
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

private def stageWitnessProofBundleDigest (bundle : StageWitnessProofBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/stage_witness_proof_bundle"
    [ .appendMessage "rv64im/stage_witness_proof_bundle/summary" bundle.summary.digest ]

private def stageClaimDigestBundleDigest (bundle : StageClaimDigestBundleView) : List Byte :=
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

private def stageClaimProofBundleDigest (bundle : StageClaimProofBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/stage_claim_proof_bundle"
    [ .appendMessage "rv64im/stage_claim_proof_bundle/summary" bundle.summary.digest ]

private def stagePackageDigestBundleDigest (bundle : StagePackageDigestBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/stage_package_digest_bundle"
    [ .appendMessage
        "rv64im/stage_package_digest_bundle/package_bundle_digest"
        bundle.packageBundleDigest
    , .appendMessage "rv64im/stage_package_digest_bundle/stage1_digest" bundle.stage1Digest
    , .appendMessage "rv64im/stage_package_digest_bundle/stage2_digest" bundle.stage2Digest
    , .appendMessage "rv64im/stage_package_digest_bundle/stage3_digest" bundle.stage3Digest
    ]

private def stagePackageProofBundleDigest (bundle : StagePackageProofBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/stage_package_proof_bundle"
    [ .appendMessage "rv64im/stage_package_proof_bundle/summary" bundle.summary.digest ]

private def kernelOpeningBindingBundleDigest (bundle : KernelOpeningBindingBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/kernel_opening_binding_bundle"
    [ .appendMessage "rv64im/kernel_opening_binding_bundle/claim_digest" bundle.claimDigest
    , .appendMessage "rv64im/kernel_opening_binding_bundle/bindings_digest" bundle.bindingsDigest
    , .appendMessage
        "rv64im/kernel_opening_binding_bundle/prepared_steps_digest"
        bundle.preparedStepsDigest
    ]

private def kernelOpeningProofBundleDigest (bundle : KernelOpeningProofBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/kernel_opening_proof_bundle"
    [ .appendMessage "rv64im/kernel_opening_proof_bundle/opening_digest" bundle.openingDigest
    , .appendMessage "rv64im/kernel_opening_proof_bundle/bindings" bundle.bindings.digest
    ]

private def kernelOpeningSummaryBundleDigest (bundle : KernelOpeningSummaryBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/kernel_opening_summary_bundle"
    [ .appendMessage "rv64im/kernel_opening_summary_bundle/opening_digest" bundle.openingDigest
    , .appendMessage
        "rv64im/kernel_opening_summary_bundle/bindings_digest"
        bundle.bindings.digest
    ]

private def kernelClaimTerminalBundleDigest (bundle : KernelClaimTerminalBundleView) : List Byte :=
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

private def kernelClaimSummaryBundleDigest (bundle : KernelClaimSummaryBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/kernel_claim_summary_bundle"
    [ .appendMessage
        "rv64im/kernel_claim_summary_bundle/prepared_step_bindings_digest"
        bundle.preparedStepBindingsDigest
    , .appendMessage "rv64im/kernel_claim_summary_bundle/terminal_digest" bundle.terminal.digest
    ]

private def kernelClaimProofBundleDigest (bundle : KernelClaimProofBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/kernel_claim_proof_bundle"
    [ .appendMessage "rv64im/kernel_claim_proof_bundle/summary" bundle.summary.digest ]

private def jointOpeningProofBundleDigest (bundle : JointOpeningProofBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/joint_opening_proof_bundle"
    [ .appendMessage
        "rv64im/joint_opening_proof_bundle/proof_statement_digest"
        bundle.proofStatementDigest
    , .appendU64s "rv64im/joint_opening_proof_bundle/meta" [bundle.publicStepCount]
    , .appendMessage
        "rv64im/joint_opening_proof_bundle/main_lane_digest"
        bundle.mainLane.digest
    , .appendMessage
        "rv64im/joint_opening_proof_bundle/kernel_opening_digest"
        bundle.kernelOpening.digest
    ]

private def root0CommitmentBundleDigest (bundle : Root0CommitmentBundleView) : List Byte :=
  transcriptDigest "neo.fold.next/rv64im/root0_commitment_bundle"
    [ .appendMessage
        "rv64im/root0_commitment_bundle/stage_claims_digest"
        bundle.stageClaims.digest
    , .appendMessage
        "rv64im/root0_commitment_bundle/stage_packages_digest"
        bundle.stagePackages.digest
    , .appendMessage
        "rv64im/root0_commitment_bundle/kernel_opening_digest"
        bundle.kernelOpening.digest
    , .appendMessage
        "rv64im/root0_commitment_bundle/kernel_claims_digest"
        bundle.kernelClaims.digest
    ]

private def kernelProofBundleDigest (bundle : KernelProofBundleView) : List Byte :=
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
        "rv64im/kernel_proof_bundle/root0_digest"
        bundle.kernelClaims.summary.terminal.root0Digest
    , .appendMessage
        "rv64im/kernel_proof_bundle/prepared_step_bindings_digest"
        bundle.kernelClaims.summary.preparedStepBindingsDigest
    , .appendMessage "rv64im/kernel_proof_bundle/main_lane_digest" bundle.mainLane.digest
    , .appendMessage
        "rv64im/kernel_proof_bundle/joint_opening_bundle_digest"
        bundle.jointOpening.digest
    , .appendMessage
        "rv64im/kernel_proof_bundle/root0_commitment_bundle_digest"
        bundle.root0Commitment.digest
    ]

private def mainLaneProofSummaryOfBundle (bundle : MainLaneProofBundleView) :
    MainLaneProofSummaryBundleView :=
  { binding := bundle.binding
  , digest := mainLaneProofSummaryBundleDigest { binding := bundle.binding, digest := [] } }

private def kernelOpeningSummaryOfProof (bundle : KernelOpeningProofBundleView) :
    KernelOpeningSummaryBundleView :=
  { openingDigest := bundle.openingDigest
  , bindings := bundle.bindings
  , digest :=
      kernelOpeningSummaryBundleDigest
        { openingDigest := bundle.openingDigest, bindings := bundle.bindings, digest := [] } }

private def parityCaseByName? (name : String) : Option (ParitySourceCase × ParityDerivedCase) :=
  Generated.parityCases.find? (fun (source, _) => source.manifest.name = name)

private def validStatementDigest (statement : ProofStatementView) : Bool :=
  proofStatementDigest statement = statement.digest

private def validClaimDigests (claims : KernelClaimBundleView) : Bool :=
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

private def validKernelProofDigests (kernel : KernelProofBundleView) : Bool :=
  traceShapeBundleDigest kernel.trace.shape = kernel.trace.shape.digest &&
    traceProofBundleDigest kernel.trace = kernel.trace.digest &&
    stageWitnessSummaryBundleDigest kernel.stages.summary = kernel.stages.summary.digest &&
    stageWitnessProofBundleDigest kernel.stages = kernel.stages.digest &&
    stageClaimDigestBundleDigest kernel.stageClaims.summary = kernel.stageClaims.summary.digest &&
    stageClaimProofBundleDigest kernel.stageClaims = kernel.stageClaims.digest &&
    stagePackageDigestBundleDigest kernel.stagePackages.summary = kernel.stagePackages.summary.digest &&
    stagePackageProofBundleDigest kernel.stagePackages = kernel.stagePackages.digest &&
    kernelOpeningBindingBundleDigest kernel.kernelOpening.bindings = kernel.kernelOpening.bindings.digest &&
    kernelOpeningProofBundleDigest kernel.kernelOpening = kernel.kernelOpening.digest &&
    kernelOpeningSummaryBundleDigest (kernelOpeningSummaryOfProof kernel.kernelOpening) =
      (kernelOpeningSummaryOfProof kernel.kernelOpening).digest &&
    kernelClaimTerminalBundleDigest kernel.kernelClaims.summary.terminal =
      kernel.kernelClaims.summary.terminal.digest &&
    kernelClaimSummaryBundleDigest kernel.kernelClaims.summary = kernel.kernelClaims.summary.digest &&
    kernelClaimProofBundleDigest kernel.kernelClaims = kernel.kernelClaims.digest &&
    mainLaneProofBindingDigest kernel.mainLane.binding = kernel.mainLane.binding.digest &&
    mainLaneProofBundleDigest kernel.mainLane = kernel.mainLane.digest &&
    mainLaneProofSummaryBundleDigest (mainLaneProofSummaryOfBundle kernel.mainLane) =
      (mainLaneProofSummaryOfBundle kernel.mainLane).digest &&
    jointOpeningProofBundleDigest kernel.jointOpening = kernel.jointOpening.digest &&
    root0CommitmentBundleDigest kernel.root0Commitment = kernel.root0Commitment.digest &&
    kernelProofBundleDigest kernel = kernel.digest

private def statementMatchesKernelAndDerived
    (statement : ProofStatementView)
    (kernel : KernelProofBundleView)
    (derived : ParityDerivedCase) : Bool :=
  statement.stageClaimsDigest = kernel.stageClaims.summary.claimBundleDigest &&
    statement.stagePackagesDigest = kernel.stagePackages.summary.packageBundleDigest &&
    statement.kernelOpeningDigest = kernel.kernelOpening.openingDigest &&
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
    statement.mainLaneStatementDigest = kernel.mainLane.binding.statementDigest &&
    statement.publicStepCount = derived.executionRows.length &&
    statement.publicStepCount = kernel.mainLane.binding.publicStepCount &&
    statement.finalPc = derived.kernel.finalPc &&
    statement.finalPc = kernel.kernelClaims.summary.terminal.finalPc &&
    statement.halted = derived.kernel.halted &&
    statement.halted = kernel.kernelClaims.summary.terminal.halted

private def claimsMatchStatementAndKernel
    (statement : ProofStatementView)
    (claims : KernelClaimBundleView)
    (kernel : KernelProofBundleView)
    (derived : ParityDerivedCase) : Bool :=
  claims.accepted.rootParamsId = statement.rootParamsId &&
    claims.accepted.rootParamsId = kernel.rootParamsId &&
    claims.accepted.statement.proofStatementDigest = statement.digest &&
    claims.accepted.statement.kernelOpeningDigest = statement.kernelOpeningDigest &&
    claims.accepted.mainLane.mainLaneStatementDigest = statement.mainLaneStatementDigest &&
    claims.accepted.mainLane.mainLaneProofDigest = kernel.mainLane.binding.proofDigest &&
    claims.accepted.terminal.finalStateDigest = statement.finalStateDigest &&
    claims.accepted.terminal.publicStepCount = statement.publicStepCount &&
    claims.accepted.terminal.finalPc = statement.finalPc &&
    claims.accepted.terminal.halted = statement.halted &&
    claims.mainLane.rootParamsId = statement.rootParamsId &&
    claims.mainLane.binding.statementDigest = statement.mainLaneStatementDigest &&
    claims.mainLane.binding.proofDigest = kernel.mainLane.binding.proofDigest &&
    claims.mainLane.binding.publicStepCount = statement.publicStepCount &&
    claims.opening.rootParamsId = statement.rootParamsId &&
    claims.opening.stages.stageClaimsDigest = statement.stageClaimsDigest &&
    claims.opening.stages.stagePackagesDigest = statement.stagePackagesDigest &&
    claims.opening.stages.kernelOpeningDigest = statement.kernelOpeningDigest &&
    claims.opening.terminal.preparedStepBindingsDigest = statement.preparedStepBindingsDigest &&
    claims.opening.terminal.executionDigest = statement.executionDigest &&
    claims.opening.terminal.transcriptFinalDigest = statement.transcriptFinalDigest &&
    claims.opening.publicStepCount = statement.publicStepCount &&
    claims.jointOpening.rootParamsId = statement.rootParamsId &&
    claims.jointOpening.binding.proofStatementDigest = statement.digest &&
    claims.jointOpening.binding.mainLaneClaimDigest = claims.mainLane.digest &&
    claims.jointOpening.binding.kernelOpeningClaimDigest = claims.opening.digest &&
    claims.jointOpening.publicStepCount = statement.publicStepCount &&
    claims.root0.rootParamsId = statement.rootParamsId &&
    claims.root0.stages.stage1Digest = derived.kernel.stage1Digest &&
    claims.root0.stages.stage2Digest = derived.kernel.stage2Digest &&
    claims.root0.stages.stage3Digest = derived.kernel.stage3Digest &&
    claims.root0.terminal.root0Digest = derived.kernel.root0Digest &&
    claims.root0.terminal.root0Digest = kernel.kernelClaims.summary.terminal.root0Digest &&
    claims.root0.terminal.executionDigest = statement.executionDigest &&
    claims.root0.terminal.finalStateDigest = statement.finalStateDigest &&
    claims.root0.terminal.transcriptFinalDigest = statement.transcriptFinalDigest

private def kernelProofMatchesDerivedAndClaims
    (claims : KernelClaimBundleView)
    (kernel : KernelProofBundleView)
    (derived : ParityDerivedCase) : Bool :=
  kernel.trace.manifest = derived.manifest &&
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
    kernel.jointOpening.proofStatementDigest = claims.accepted.statement.proofStatementDigest &&
    kernel.jointOpening.publicStepCount = claims.jointOpening.publicStepCount &&
    kernel.jointOpening.mainLane = mainLaneProofSummaryOfBundle kernel.mainLane &&
    kernel.jointOpening.kernelOpening = kernelOpeningSummaryOfProof kernel.kernelOpening &&
    kernel.root0Commitment.stageClaims = kernel.stageClaims.summary &&
    kernel.root0Commitment.stagePackages = kernel.stagePackages.summary &&
    kernel.root0Commitment.kernelOpening = kernelOpeningSummaryOfProof kernel.kernelOpening &&
    kernel.root0Commitment.kernelClaims = kernel.kernelClaims.summary

private def caseCheckResults (proofCase : PublicProofVectorCase) : List (String × Bool) :=
  let schema := publicProofSchemaOfCase proofCase
  match parityCaseByName? proofCase.name with
  | none => [("parityCasePresent", false)]
  | some (_, derived) =>
      [ ("parityCasePresent", true)
      , ( "publicProofSchemaLockstep"
        , schema.statement = proofCase.statement &&
            schema.claims = proofCase.claims &&
            schema.kernelProof = proofCase.kernelProof)
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
        , kernelProofMatchesDerivedAndClaims schema.claims schema.kernelProof derived)
      ]

structure Rv64imPublicProofBoundaryReport where
  name : String
  checks : List (String × Bool)
deriving Repr

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
