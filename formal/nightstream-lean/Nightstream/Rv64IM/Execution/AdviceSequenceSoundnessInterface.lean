import Nightstream.Rv64IM.Execution.AdviceSequenceSoundness

namespace Nightstream.Rv64IM

namespace AdviceSequenceSoundnessInterface

abbrev SequenceResult := Nightstream.Rv64IM.SequenceResult
abbrev CommittedSequence := Nightstream.Rv64IM.CommittedSequence
abbrev TouchedStateSet := Nightstream.Rv64IM.TouchedStateSet
abbrev PreservedStatePredicate := Nightstream.Rv64IM.PreservedStatePredicate
abbrev AdviceSequenceCorrect := Nightstream.Rv64IM.AdviceSequenceCorrect
abbrev AdviceSequenceDeterministic := Nightstream.Rv64IM.AdviceSequenceDeterministic
abbrev AdviceSequenceProofPackage := Nightstream.Rv64IM.AdviceSequenceProofPackage
abbrev adviceSequenceDeterministic_of_correct :=
  @Nightstream.Rv64IM.adviceSequenceDeterministic_of_correct
abbrev adviceSequenceProofPackage_of_correct :=
  @Nightstream.Rv64IM.adviceSequenceProofPackage_of_correct

end AdviceSequenceSoundnessInterface

end Nightstream.Rv64IM
