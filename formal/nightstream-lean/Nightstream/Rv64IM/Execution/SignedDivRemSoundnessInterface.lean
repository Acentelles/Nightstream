import Nightstream.Rv64IM.Execution.SignedDivRemSoundness

namespace Nightstream.Rv64IM

namespace SignedDivRemSoundnessInterface

abbrev intMin64 := Nightstream.Rv64IM.intMin64
abbrev ChangeDivisorCorrect := Nightstream.Rv64IM.ChangeDivisorCorrect
abbrev RemainderFromDividendSign := Nightstream.Rv64IM.RemainderFromDividendSign
abbrev SignedDivRemSpec := Nightstream.Rv64IM.SignedDivRemSpec
abbrev SignedDivRemOpcode := Nightstream.Rv64IM.SignedDivRemOpcode
abbrev SignedDivRemOpcodeBound := @Nightstream.Rv64IM.SignedDivRemOpcodeBound
abbrev SignedDivRemProofPackage := Nightstream.Rv64IM.SignedDivRemProofPackage
abbrev changeDivisorCorrect_of_signedDivRemSoundness :=
  Nightstream.Rv64IM.changeDivisorCorrect_of_signedDivRemSoundness
abbrev remainderFromDividendSign_of_signedDivRemSoundness :=
  Nightstream.Rv64IM.remainderFromDividendSign_of_signedDivRemSoundness
abbrev signedDivRemSpec_of_signedDivRemSoundness :=
  Nightstream.Rv64IM.signedDivRemSpec_of_signedDivRemSoundness
abbrev isDiv_of_signedDivRemOpcodeBound :=
  @Nightstream.Rv64IM.isDiv_of_signedDivRemOpcodeBound
abbrev isRem_of_signedDivRemOpcodeBound :=
  @Nightstream.Rv64IM.isRem_of_signedDivRemOpcodeBound
abbrev isWOp_of_signedDivRemOpcodeBound :=
  @Nightstream.Rv64IM.isWOp_of_signedDivRemOpcodeBound

end SignedDivRemSoundnessInterface

end Nightstream.Rv64IM
