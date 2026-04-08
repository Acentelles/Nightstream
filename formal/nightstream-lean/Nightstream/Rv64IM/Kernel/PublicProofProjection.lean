import Nightstream.Rv64IM.Generated.AcceptedProofArtifactTypes
import Nightstream.Rv64IM.AcceptedArtifactRootLane
import Nightstream.Rv64IM.Kernel.PublicProofSchema
import Nightstream.Rv64IM.ProofBoundaryChecks

/-!
Owns the exact public-proof projection rebuilt from the Lean-owned accepted
artifact view. The authoritative inputs are the source-derived execution rows
and the proof-bearing kernel bundle carried by the artifact; the exported
public proof shape is only a projection target that must match this
recomputation exactly.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated

abbrev GeneratedRv64imPublicProofSchema :=
  Rv64imPublicProofSchema
    ProofStatementView
    KernelClaimBundleView
    KernelProofBundleView

def projectedProofStatementOfAcceptedArtifact
    (artifact : AcceptedProofArtifactView) : ProofStatementView :=
  let recomputedRootLane := recomputeRootLaneView artifact.derived.executionRows
  let rootLaneColumns := recomputedRootLane.rootLaneColumns
  let mainLaneSurface := recomputedRootLane.mainLaneSurface
  let statement : ProofStatementView :=
    { rootParamsId := artifact.kernelProof.rootParamsId
    , foldSchedule := artifact.kernelProof.mainLane.binding.foldSchedule
    , chunkCount := artifact.kernelProof.mainLane.binding.chunkCount
    , stageClaimsDigest := artifact.kernelProof.stageClaims.digest
    , stagePackagesDigest := artifact.kernelProof.stagePackages.digest
    , kernelOpeningDigest := artifact.kernelProof.kernelOpening.digest
    , preparedStepBindingsDigest := recomputedRootLane.preparedStepBindings.digest
    , executionDigest := artifact.derived.kernel.executionDigest
    , finalStateDigest := artifact.derived.kernel.finalStateDigest
    , transcriptFinalDigest := artifact.derived.kernel.transcriptFinalDigest
    , mainLaneSurfaceDigest := mainLaneSurface.digest
    , rootLaneColumnsDigest := rootLaneColumns.digest
    , publicStepCount := rootLaneColumns.timeLen
    , initialPc := artifact.source.startPc
    , finalPc := artifact.derived.kernel.finalPc
    , halted := artifact.derived.kernel.halted
    , digest := []
    }
  { statement with digest := proofStatementDigest statement }

def projectedKernelClaimBundleOfAcceptedArtifact
    (artifact : AcceptedProofArtifactView) : KernelClaimBundleView :=
  let statement := projectedProofStatementOfAcceptedArtifact artifact
  let acceptedStatement : AcceptedProofStatementBindingView :=
    let binding : AcceptedProofStatementBindingView :=
      { proofStatementDigest := statement.digest
      , kernelOpeningDigest := statement.kernelOpeningDigest
      , digest := []
      }
    { binding with digest := acceptedProofStatementBindingDigest binding }
  let acceptedMainLane : AcceptedProofMainLaneBindingView :=
    let binding : AcceptedProofMainLaneBindingView :=
      { mainLaneBundleDigest := artifact.kernelProof.mainLane.digest
      , digest := []
      }
    { binding with digest := acceptedProofMainLaneBindingDigest binding }
  let acceptedTerminal : AcceptedProofTerminalBindingView :=
    let binding : AcceptedProofTerminalBindingView :=
      { finalStateDigest := statement.finalStateDigest
      , finalPc := statement.finalPc
      , halted := statement.halted
      , digest := []
      }
    { binding with digest := acceptedProofTerminalBindingDigest binding }
  let accepted : AcceptedProofClaimView :=
    let claim : AcceptedProofClaimView :=
      { rootParamsId := statement.rootParamsId
      , statement := acceptedStatement
      , mainLane := acceptedMainLane
      , terminal := acceptedTerminal
      , digest := []
      }
    { claim with digest := acceptedProofClaimDigest claim }
  let mainLaneBinding : MainLaneClaimBindingView :=
    let binding : MainLaneClaimBindingView :=
      { mainLaneBundleDigest := artifact.kernelProof.mainLane.digest
      , digest := []
      }
    { binding with digest := mainLaneClaimBindingDigest binding }
  let mainLane : MainLaneClaimView :=
    let claim : MainLaneClaimView :=
      { rootParamsId := statement.rootParamsId
      , binding := mainLaneBinding
      , digest := []
      }
    { claim with digest := mainLaneClaimDigest claim }
  let openingStages : KernelOpeningStageClaimBindingView :=
    let binding : KernelOpeningStageClaimBindingView :=
      { stageClaimsDigest := statement.stageClaimsDigest
      , stagePackagesDigest := statement.stagePackagesDigest
      , kernelOpeningDigest := statement.kernelOpeningDigest
      , digest := []
      }
    { binding with digest := kernelOpeningStageClaimBindingDigest binding }
  let openingTerminal : KernelOpeningTerminalClaimBindingView :=
    let binding : KernelOpeningTerminalClaimBindingView :=
      { preparedStepBindingsDigest := statement.preparedStepBindingsDigest
      , executionDigest := statement.executionDigest
      , transcriptFinalDigest := statement.transcriptFinalDigest
      , digest := []
      }
    { binding with digest := kernelOpeningTerminalClaimBindingDigest binding }
  let opening : KernelOpeningClaimView :=
    let claim : KernelOpeningClaimView :=
      { rootParamsId := statement.rootParamsId
      , stages := openingStages
      , terminal := openingTerminal
      , digest := []
      }
    { claim with digest := kernelOpeningClaimDigest claim }
  let jointBinding : JointOpeningClaimBindingView :=
    let binding : JointOpeningClaimBindingView :=
      { proofStatementDigest := statement.digest
      , mainLaneClaimDigest := mainLane.digest
      , kernelOpeningClaimDigest := opening.digest
      , digest := []
      }
    { binding with digest := jointOpeningClaimBindingDigest binding }
  let jointOpening : JointOpeningClaimView :=
    let claim : JointOpeningClaimView :=
      { rootParamsId := statement.rootParamsId
      , binding := jointBinding
      , digest := []
      }
    { claim with digest := jointOpeningClaimDigest claim }
  let root0Stages : Root0StageClaimBindingView :=
    let binding : Root0StageClaimBindingView :=
      { stage1Digest := artifact.derived.kernel.stage1Digest
      , stage2Digest := artifact.derived.kernel.stage2Digest
      , stage3Digest := artifact.derived.kernel.stage3Digest
      , digest := []
      }
    { binding with digest := root0StageClaimBindingDigest binding }
  let root0Terminal : Root0TerminalClaimBindingView :=
    let binding : Root0TerminalClaimBindingView :=
      { root0Digest := artifact.derived.kernel.root0Digest
      , executionDigest := statement.executionDigest
      , finalStateDigest := statement.finalStateDigest
      , transcriptFinalDigest := statement.transcriptFinalDigest
      , digest := []
      }
    { binding with digest := root0TerminalClaimBindingDigest binding }
  let root0 : Root0ClaimView :=
    let claim : Root0ClaimView :=
      { rootParamsId := statement.rootParamsId
      , stages := root0Stages
      , terminal := root0Terminal
      , digest := []
      }
    { claim with digest := root0ClaimDigest claim }
  let claims : KernelClaimBundleView :=
    { accepted := accepted
    , mainLane := mainLane
    , opening := opening
    , jointOpening := jointOpening
    , root0 := root0
    , digest := []
    }
  { claims with digest := kernelClaimBundleDigest claims }

def projectedPublicProofSchemaOfAcceptedArtifact
    (artifact : AcceptedProofArtifactView) : GeneratedRv64imPublicProofSchema :=
  { statement := projectedProofStatementOfAcceptedArtifact artifact
  , claims := projectedKernelClaimBundleOfAcceptedArtifact artifact
  , kernelProof := artifact.kernelProof
  }

def projectedPublicProofOfAcceptedArtifact (artifact : AcceptedProofArtifactView) : ProofView :=
  let schema := projectedPublicProofSchemaOfAcceptedArtifact artifact
  { claim := schema.claims
  , statement := schema.statement
  , kernel := schema.kernelProof
  }

def projectedStatementMatchesExported (artifact : AcceptedProofArtifactView) : Bool :=
  projectedProofStatementOfAcceptedArtifact artifact = artifact.exportedStatement

def projectedClaimsMatchesExported (artifact : AcceptedProofArtifactView) : Bool :=
  projectedKernelClaimBundleOfAcceptedArtifact artifact = artifact.exportedClaims

def projectedKernelProofMatchesExported (artifact : AcceptedProofArtifactView) : Bool :=
  artifact.kernelProof = artifact.exportedKernelProof

def projectedPublicProofMatchesExported (artifact : AcceptedProofArtifactView) : Bool :=
  projectedPublicProofOfAcceptedArtifact artifact = artifact.exportedProof

end Nightstream.Rv64IM
