import Nightstream.Rv64IM.AcceptedArtifactKernelReplay

/-!
Interface for exact recompute-first RV64IM kernel replay bindings.
-/

namespace Nightstream.Rv64IM.AcceptedArtifactKernelReplayInterface

abbrev RecomputedKernelReplayView :=
  @Nightstream.Rv64IM.RecomputedKernelReplayView

abbrev recomputeKernelReplayView? :=
  @Nightstream.Rv64IM.recomputeKernelReplayView?

abbrev replayedAcceptedArtifactCase? :=
  @Nightstream.Rv64IM.replayedAcceptedArtifactCase?

abbrev recomputedKernelReplayMatchesArtifact :=
  @Nightstream.Rv64IM.recomputedKernelReplayMatchesArtifact

abbrev recomputedKernelStatementMatchesArtifact :=
  @Nightstream.Rv64IM.recomputedKernelStatementMatchesArtifact

abbrev recomputedKernelClaimsMatchArtifact :=
  @Nightstream.Rv64IM.recomputedKernelClaimsMatchArtifact

abbrev recomputedKernelProofMatchesArtifact :=
  @Nightstream.Rv64IM.recomputedKernelProofMatchesArtifact

abbrev recomputedKernelStageDigestBindingsMatchArtifact :=
  @Nightstream.Rv64IM.recomputedKernelStageDigestBindingsMatchArtifact

abbrev recomputedKernelTerminalBindingsMatchArtifact :=
  @Nightstream.Rv64IM.recomputedKernelTerminalBindingsMatchArtifact

abbrev recomputedKernelReplayMatchesAllArtifactBindings :=
  @Nightstream.Rv64IM.recomputedKernelReplayMatchesAllArtifactBindings

end Nightstream.Rv64IM.AcceptedArtifactKernelReplayInterface
