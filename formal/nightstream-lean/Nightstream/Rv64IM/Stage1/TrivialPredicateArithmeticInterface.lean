import Nightstream.Rv64IM.Stage1.TrivialPredicateArithmetic

namespace Nightstream.Rv64IM

namespace TrivialPredicateArithmeticInterface

abbrev AlignmentWidth := Nightstream.Rv64IM.AlignmentWidth
abbrev AlignmentWidth_bytes := Nightstream.Rv64IM.AlignmentWidth.bytes
abbrev NaturalAlignment := Nightstream.Rv64IM.NaturalAlignment
abbrev ArithmeticAlignmentFromLowByte := Nightstream.Rv64IM.ArithmeticAlignmentFromLowByte
abbrev naturalAlignment_iff_arithmetic_from_lowByte :=
  @Nightstream.Rv64IM.naturalAlignment_iff_arithmetic_from_lowByte
abbrev naturalAlignment_iff_of_lowByte_eq_mod :=
  @Nightstream.Rv64IM.naturalAlignment_iff_of_lowByte_eq_mod
abbrev naturalAlignment_of_arithmetic_from_lowByte :=
  @Nightstream.Rv64IM.naturalAlignment_of_arithmetic_from_lowByte
abbrev arithmetic_from_lowByte_of_naturalAlignment :=
  @Nightstream.Rv64IM.arithmetic_from_lowByte_of_naturalAlignment

end TrivialPredicateArithmeticInterface

end Nightstream.Rv64IM
