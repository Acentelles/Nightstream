import Nightstream.StagedBridge

namespace Nightstream

namespace StagedBridgeInterface

abbrev CanonicalStagePayloads := @Nightstream.CanonicalStagePayloads
abbrev canonicalStagePayloads_length_eq := @Nightstream.canonicalStagePayloads_length_eq

abbrev StagedBridgeArtifact := @Nightstream.StagedBridgeArtifact
noncomputable abbrev stagedBridgeArtifact_of_parts := @Nightstream.stagedBridgeArtifact_of_parts
abbrev chunkCount_matches_schedule := @Nightstream.chunkCount_matches_schedule
abbrev foldSchedule_valid := @Nightstream.foldSchedule_valid
abbrev preparedStepCount_matches_publicView := @Nightstream.preparedStepCount_matches_publicView
abbrev publicStages_eq_canonical := @Nightstream.publicStages_eq_canonical
abbrev stagePayloadCount_matches_stageOrder := @Nightstream.stagePayloadCount_matches_stageOrder

end StagedBridgeInterface

end Nightstream
