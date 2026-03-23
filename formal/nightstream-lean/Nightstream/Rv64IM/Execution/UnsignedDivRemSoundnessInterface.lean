import Nightstream.Rv64IM.Execution.UnsignedDivRemSoundness

namespace Nightstream.Rv64IM

namespace UnsignedDivRemSoundnessInterface

abbrev maxUnsigned64 := Nightstream.Rv64IM.maxUnsigned64
abbrev MulUNoOverflow := @Nightstream.Rv64IM.MulUNoOverflow
abbrev UnsignedDivRemSpec := @Nightstream.Rv64IM.UnsignedDivRemSpec
abbrev UnsignedDivRemOpcode := Nightstream.Rv64IM.UnsignedDivRemOpcode
abbrev UnsignedDivRemOpcodeBound := @Nightstream.Rv64IM.UnsignedDivRemOpcodeBound
abbrev UnsignedDivRemSoundnessProofPackage :=
  @Nightstream.Rv64IM.UnsignedDivRemSoundnessProofPackage
abbrev mulUNoOverflow_of_unsignedDivRemSoundness :=
  @Nightstream.Rv64IM.mulUNoOverflow_of_unsignedDivRemSoundness
abbrev unsignedDivRemDeterministic_of_soundness :=
  @Nightstream.Rv64IM.unsignedDivRemDeterministic_of_soundness
abbrev isDiv_of_unsignedDivRemOpcodeBound :=
  @Nightstream.Rv64IM.isDiv_of_unsignedDivRemOpcodeBound
abbrev isRem_of_unsignedDivRemOpcodeBound :=
  @Nightstream.Rv64IM.isRem_of_unsignedDivRemOpcodeBound
abbrev isWOp_of_unsignedDivRemOpcodeBound :=
  @Nightstream.Rv64IM.isWOp_of_unsignedDivRemOpcodeBound

end UnsignedDivRemSoundnessInterface

end Nightstream.Rv64IM
