import Nightstream.Chip8.Stage2.TwistConcreteBinding

namespace Nightstream.Chip8

namespace TwistConcreteBindingInterface

-- ── Types ──

abbrev F := Nightstream.Chip8.TwistConcreteBinding.F
abbrev InitialState := Nightstream.Chip8.TwistConcreteBinding.InitialState
abbrev RegAddress := Nightstream.Chip8.TwistConcreteBinding.RegAddress
abbrev RamAddress := Nightstream.Chip8.TwistConcreteBinding.RamAddress
abbrev RegisterTimeTable := Nightstream.Chip8.TwistConcreteBinding.RegisterTimeTable
abbrev RamTimeTable := Nightstream.Chip8.TwistConcreteBinding.RamTimeTable
abbrev RegisterAddressColumns :=
  Nightstream.Chip8.TwistConcreteBinding.RegisterAddressColumns
abbrev RamAddressColumns :=
  Nightstream.Chip8.TwistConcreteBinding.RamAddressColumns
abbrev RegisterCycleValues :=
  Nightstream.Chip8.TwistConcreteBinding.RegisterCycleValues
abbrev RamCycleValues := Nightstream.Chip8.TwistConcreteBinding.RamCycleValues

-- ── Theorems: Register Concrete Bindings ──

abbrev registerReadCheckAtBitCycle_of_relation :=
  @Nightstream.Chip8.TwistConcreteBinding.registerReadCheckAtBitCycle_of_relation
abbrev registerWriteCheckAtBitPoint_of_incrementRelation :=
  @Nightstream.Chip8.TwistConcreteBinding.registerWriteCheckAtBitPoint_of_incrementRelation
abbrev registerShiftedValEvaluationExpression_at_bitPoint :=
  @Nightstream.Chip8.TwistConcreteBinding.registerShiftedValEvaluationExpression_at_bitPoint
abbrev registerShiftedReadCheckAtBitCycle_of_relation :=
  @Nightstream.Chip8.TwistConcreteBinding.registerShiftedReadCheckAtBitCycle_of_relation
abbrev registerShiftedWriteCheckAtBitPoint_of_incrementRelation :=
  @Nightstream.Chip8.TwistConcreteBinding.registerShiftedWriteCheckAtBitPoint_of_incrementRelation
-- ── Theorems: RAM Concrete Bindings ──

abbrev ramReadCheckAtBitCycle_of_relation :=
  @Nightstream.Chip8.TwistConcreteBinding.ramReadCheckAtBitCycle_of_relation
abbrev ramWriteCheckAtBitPoint_of_incrementRelation :=
  @Nightstream.Chip8.TwistConcreteBinding.ramWriteCheckAtBitPoint_of_incrementRelation
abbrev ramShiftedValEvaluationExpression_at_bitPoint :=
  @Nightstream.Chip8.TwistConcreteBinding.ramShiftedValEvaluationExpression_at_bitPoint
abbrev ramShiftedReadCheckAtBitCycle_of_relation :=
  @Nightstream.Chip8.TwistConcreteBinding.ramShiftedReadCheckAtBitCycle_of_relation
abbrev ramShiftedWriteCheckAtBitPoint_of_incrementRelation :=
  @Nightstream.Chip8.TwistConcreteBinding.ramShiftedWriteCheckAtBitPoint_of_incrementRelation

end TwistConcreteBindingInterface

end Nightstream.Chip8
