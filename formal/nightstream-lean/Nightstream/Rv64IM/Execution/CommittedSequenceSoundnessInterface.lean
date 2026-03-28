import Nightstream.Rv64IM.Execution.CommittedSequenceSoundness

namespace Nightstream.Rv64IM

namespace CommittedSequenceSoundnessInterface

abbrev SequenceResult := Nightstream.Rv64IM.SequenceResult
abbrev CommittedSequence := Nightstream.Rv64IM.CommittedSequence
abbrev TouchedStateSet := Nightstream.Rv64IM.TouchedStateSet
abbrev PreservedStatePredicate := Nightstream.Rv64IM.PreservedStatePredicate
abbrev CommittedSequenceCorrect := Nightstream.Rv64IM.CommittedSequenceCorrect
abbrev CommittedSequenceDeterministic := Nightstream.Rv64IM.CommittedSequenceDeterministic
abbrev CommittedSequenceProofPackage := Nightstream.Rv64IM.CommittedSequenceProofPackage
abbrev committedSequenceDeterministic_of_correct :=
  @Nightstream.Rv64IM.committedSequenceDeterministic_of_correct
abbrev committedSequenceProofPackage_of_correct :=
  @Nightstream.Rv64IM.committedSequenceProofPackage_of_correct

end CommittedSequenceSoundnessInterface

end Nightstream.Rv64IM
