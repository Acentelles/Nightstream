import Nightstream.Chip8.Stage2.EvidenceCoverageBounds

namespace Nightstream.Chip8

namespace EvidenceCoverageInterface

abbrev F := Nightstream.Chip8.EvidenceCoverage.F
abbrev Program := Nightstream.Chip8.EvidenceCoverage.Program
abbrev MachineState := Nightstream.Chip8.EvidenceCoverage.MachineState
abbrev ExternalSchedule := Nightstream.Chip8.EvidenceCoverage.ExternalSchedule
abbrev PCSContext := @Nightstream.Chip8.EvidenceCoverage.PCSContext
abbrev rawScalarClaim := @Nightstream.Chip8.EvidenceCoverage.rawScalarClaim
abbrev ExecutionInputContext := @Nightstream.Chip8.EvidenceCoverage.ExecutionInputContext
abbrev RomEvidence := @Nightstream.Chip8.EvidenceCoverage.RomEvidence
abbrev ScheduleEvidence := @Nightstream.Chip8.EvidenceCoverage.ScheduleEvidence
abbrev KernelInputEvidence := @Nightstream.Chip8.EvidenceCoverage.KernelInputEvidence
abbrev DirectValueWitness := @Nightstream.Chip8.EvidenceCoverage.DirectValueWitness
abbrev RowView := Nightstream.Chip8.EvidenceCoverage.RowView
abbrev RowProjection := @Nightstream.Chip8.EvidenceCoverage.RowProjection
abbrev RowProjectionWitness := @Nightstream.Chip8.EvidenceCoverage.RowProjectionWitness
abbrev RowConsistency := @Nightstream.Chip8.EvidenceCoverage.RowConsistency
abbrev RowConsistent := @Nightstream.Chip8.EvidenceCoverage.RowConsistent
abbrev TableProvenance := @Nightstream.Chip8.EvidenceCoverage.TableProvenance
abbrev ShoutClaimWitness := @Nightstream.Chip8.EvidenceCoverage.ShoutClaimWitness
abbrev TwistReadClaimWitness := @Nightstream.Chip8.EvidenceCoverage.TwistReadClaimWitness
abbrev TwistWriteClaimWitness := @Nightstream.Chip8.EvidenceCoverage.TwistWriteClaimWitness
abbrev TwistValClaimWitness := @Nightstream.Chip8.EvidenceCoverage.TwistValClaimWitness
abbrev AddressProvenanceAt := @Nightstream.Chip8.EvidenceCoverage.AddressProvenanceAt
abbrev AddressProvenance := @Nightstream.Chip8.EvidenceCoverage.AddressProvenance
abbrev TwistSessionWitness := @Nightstream.Chip8.EvidenceCoverage.TwistSessionWitness
abbrev VirtualValProvenance := @Nightstream.Chip8.EvidenceCoverage.VirtualValProvenance
abbrev TwistSessionRegistry := @Nightstream.Chip8.EvidenceCoverage.TwistSessionRegistry
abbrev TwistSessionMembersInClaims :=
  @Nightstream.Chip8.EvidenceCoverage.TwistSessionMembersInClaims
abbrev TwistSessionReadTotal :=
  @Nightstream.Chip8.EvidenceCoverage.TwistSessionReadTotal
abbrev TwistSessionWriteTotal :=
  @Nightstream.Chip8.EvidenceCoverage.TwistSessionWriteTotal
abbrev TwistSessionValTotal :=
  @Nightstream.Chip8.EvidenceCoverage.TwistSessionValTotal
abbrev TwistSessionUniqueByKey :=
  @Nightstream.Chip8.EvidenceCoverage.TwistSessionUniqueByKey
abbrev RegisterTwistSessionRegistry :=
  @Nightstream.Chip8.EvidenceCoverage.RegisterTwistSessionRegistry
abbrev RamTwistSessionRegistry :=
  @Nightstream.Chip8.EvidenceCoverage.RamTwistSessionRegistry
abbrev TwistSessionClosed := @Nightstream.Chip8.EvidenceCoverage.TwistSessionClosed
abbrev RegisterTwistSessionClosed :=
  @Nightstream.Chip8.EvidenceCoverage.RegisterTwistSessionClosed
abbrev RamTwistSessionClosed :=
  @Nightstream.Chip8.EvidenceCoverage.RamTwistSessionClosed
abbrev FetchDecodeEvidence := @Nightstream.Chip8.EvidenceCoverage.FetchDecodeEvidence
abbrev LookupEvidence := @Nightstream.Chip8.EvidenceCoverage.LookupEvidence
abbrev MemoryFrameEvidence := @Nightstream.Chip8.EvidenceCoverage.MemoryFrameEvidence
abbrev MemoryEvidence := @Nightstream.Chip8.EvidenceCoverage.MemoryEvidence
abbrev FramebufferEvidence := @Nightstream.Chip8.EvidenceCoverage.FramebufferEvidence
abbrev ContinuityEvidence := @Nightstream.Chip8.EvidenceCoverage.ContinuityEvidence
abbrev SemanticEvidence := @Nightstream.Chip8.EvidenceCoverage.SemanticEvidence
abbrev SemanticEvidenceCovered := @Nightstream.Chip8.EvidenceCoverage.SemanticEvidenceCovered
abbrev ExactSemanticEvidenceCovered :=
  @Nightstream.Chip8.EvidenceCoverage.ExactSemanticEvidenceCovered

abbrev DirectValueWitness.checked := @Nightstream.Chip8.EvidenceCoverage.DirectValueWitness.checked
abbrev DirectValueWitness.rawOpeningSeparation :=
  @Nightstream.Chip8.EvidenceCoverage.DirectValueWitness.rawOpeningSeparation
abbrev witnessBinds_of_rowConsistent :=
  @Nightstream.Chip8.EvidenceCoverage.witnessBinds_of_rowConsistent
abbrev localMemoryBound_of_rowConsistent :=
  @Nightstream.Chip8.EvidenceCoverage.localMemoryBound_of_rowConsistent
abbrev ShoutClaimWitness.checked := @Nightstream.Chip8.EvidenceCoverage.ShoutClaimWitness.checked
abbrev TwistReadClaimWitness.checked :=
  @Nightstream.Chip8.EvidenceCoverage.TwistReadClaimWitness.checked
abbrev TwistWriteClaimWitness.checked :=
  @Nightstream.Chip8.EvidenceCoverage.TwistWriteClaimWitness.checked
abbrev TwistValClaimWitness.checked :=
  @Nightstream.Chip8.EvidenceCoverage.TwistValClaimWitness.checked
abbrev addressProvenance_of_at := @Nightstream.Chip8.EvidenceCoverage.addressProvenance_of_at
abbrev twistSessionClosed_membersInClaims :=
  @Nightstream.Chip8.EvidenceCoverage.twistSessionClosed_membersInClaims
abbrev twistSessionClosed_readTotal :=
  @Nightstream.Chip8.EvidenceCoverage.twistSessionClosed_readTotal
abbrev twistSessionClosed_writeTotal :=
  @Nightstream.Chip8.EvidenceCoverage.twistSessionClosed_writeTotal
abbrev twistSessionClosed_valTotal :=
  @Nightstream.Chip8.EvidenceCoverage.twistSessionClosed_valTotal
abbrev twistSessionClosed_uniqueByKey :=
  @Nightstream.Chip8.EvidenceCoverage.twistSessionClosed_uniqueByKey
abbrev kernelOpeningBoundary_of_evidence :=
  @Nightstream.Chip8.EvidenceCoverage.kernelOpeningBoundary_of_evidence
abbrev witnessBinds_of_evidence := @Nightstream.Chip8.EvidenceCoverage.witnessBinds_of_evidence
abbrev routingSound_of_evidence := @Nightstream.Chip8.EvidenceCoverage.routingSound_of_evidence
abbrev fetchDecodeBound_of_evidence :=
  @Nightstream.Chip8.EvidenceCoverage.fetchDecodeBound_of_evidence
abbrev lookupBound_of_evidence := @Nightstream.Chip8.EvidenceCoverage.lookupBound_of_evidence
abbrev memoryBound_of_evidence := @Nightstream.Chip8.EvidenceCoverage.memoryBound_of_evidence
abbrev continuityRowBound_of_evidence :=
  @Nightstream.Chip8.EvidenceCoverage.continuityRowBound_of_evidence
abbrev startBoundaryBound_of_evidence :=
  @Nightstream.Chip8.EvidenceCoverage.startBoundaryBound_of_evidence
abbrev startBoundaryFrame_of_evidence :=
  @Nightstream.Chip8.EvidenceCoverage.startBoundaryFrame_of_evidence
abbrev finalBoundaryBound_of_evidence :=
  @Nightstream.Chip8.EvidenceCoverage.finalBoundaryBound_of_evidence
abbrev finalBoundaryFrame_of_evidence :=
  @Nightstream.Chip8.EvidenceCoverage.finalBoundaryFrame_of_evidence
abbrev framebufferBound_of_evidence :=
  @Nightstream.Chip8.EvidenceCoverage.framebufferBound_of_evidence
abbrev kernelPublicInputsBound_of_evidence :=
  @Nightstream.Chip8.EvidenceCoverage.kernelPublicInputsBound_of_evidence
abbrev executionInputsBound_of_evidence :=
  @Nightstream.Chip8.EvidenceCoverage.executionInputsBound_of_evidence
abbrev scheduleBound_of_evidence := @Nightstream.Chip8.EvidenceCoverage.scheduleBound_of_evidence
abbrev Stage2TemporalSeedBound :=
  @Nightstream.Chip8.EvidenceCoverage.Stage2TemporalSeedBound
abbrev RegisterTemporalSeedBound :=
  @Nightstream.Chip8.EvidenceCoverage.RegisterTemporalSeedBound
abbrev RamTemporalSeedBound :=
  @Nightstream.Chip8.EvidenceCoverage.RamTemporalSeedBound
noncomputable abbrev stage2TemporalSeedBound_of_evidence :=
  @Nightstream.Chip8.EvidenceCoverage.stage2TemporalSeedBound_of_evidence
noncomputable abbrev stage2TemporalSeedBound_of_exactAuthenticatedEvidence :=
  @Nightstream.Chip8.EvidenceCoverage.stage2TemporalSeedBound_of_exactAuthenticatedEvidence
abbrev registerTemporalSeedBound_of_stage2TemporalSeedBound :=
  @Nightstream.Chip8.EvidenceCoverage.registerTemporalSeedBound_of_stage2TemporalSeedBound
abbrev ramTemporalSeedBound_of_stage2TemporalSeedBound :=
  @Nightstream.Chip8.EvidenceCoverage.ramTemporalSeedBound_of_stage2TemporalSeedBound
abbrev semanticBounds_of_authenticatedEvidence :=
  @Nightstream.Chip8.EvidenceCoverage.semanticBounds_of_authenticatedEvidence
abbrev semanticEvidenceCovered_of_exactEvidence :=
  @Nightstream.Chip8.EvidenceCoverage.semanticEvidenceCovered_of_exactEvidence
abbrev laneShiftSourceOpeningAppears_of_authenticatedEvidence :=
  @Nightstream.Chip8.EvidenceCoverage.laneShiftSourceOpeningAppears_of_authenticatedEvidence
abbrev laneShiftSourceOpeningAppears_of_exactAuthenticatedEvidence :=
  @Nightstream.Chip8.EvidenceCoverage.laneShiftSourceOpeningAppears_of_exactAuthenticatedEvidence
abbrev semanticBounds_of_exactAuthenticatedEvidence :=
  @Nightstream.Chip8.EvidenceCoverage.semanticBounds_of_exactAuthenticatedEvidence

end EvidenceCoverageInterface

end Nightstream.Chip8
