import Nightstream.Chip8.Stage1.Routing

namespace Nightstream.Chip8

namespace RoutingInterface

-- ── Types ──

abbrev Witness (K : Type*) := Nightstream.Chip8.Witness K
abbrev RoutingFlags (K : Type*) := Nightstream.Chip8.RoutingFlags K
abbrev ControlTuple (K : Type*) := Nightstream.Chip8.ControlTuple K

-- ── Column Indices ──

abbrev colOne := Nightstream.Chip8.colOne
abbrev colPc := Nightstream.Chip8.colPc
abbrev colPcNext := Nightstream.Chip8.colPcNext
abbrev colRegX := Nightstream.Chip8.colRegX
abbrev colRegY := Nightstream.Chip8.colRegY
abbrev colRegXNext := Nightstream.Chip8.colRegXNext
abbrev colIReg := Nightstream.Chip8.colIReg
abbrev colINext := Nightstream.Chip8.colINext
abbrev colKk := Nightstream.Chip8.colKk
abbrev colNnnAddr := Nightstream.Chip8.colNnnAddr
abbrev colNnnWord := Nightstream.Chip8.colNnnWord
abbrev colMemValue := Nightstream.Chip8.colMemValue
abbrev colLookupOutput := Nightstream.Chip8.colLookupOutput
abbrev colWritesLookupToX := Nightstream.Chip8.colWritesLookupToX
abbrev colWritesMemToX := Nightstream.Chip8.colWritesMemToX
abbrev colPreservesX := Nightstream.Chip8.colPreservesX
abbrev colWritesNnnToI := Nightstream.Chip8.colWritesNnnToI
abbrev colIsJump := Nightstream.Chip8.colIsJump
abbrev colIsBranch := Nightstream.Chip8.colIsBranch
abbrev colIsMemOp := Nightstream.Chip8.colIsMemOp
abbrev colXIdx := Nightstream.Chip8.colXIdx
abbrev colYIdx := Nightstream.Chip8.colYIdx
abbrev colBurstLast := Nightstream.Chip8.colBurstLast
abbrev colRamAddr := Nightstream.Chip8.colRamAddr

-- ── Flag Extractors ──

abbrev flagWritesLookupToX := @Nightstream.Chip8.flagWritesLookupToX
abbrev flagWritesMemToX := @Nightstream.Chip8.flagWritesMemToX
abbrev flagPreservesX := @Nightstream.Chip8.flagPreservesX
abbrev flagWritesNnnToI := @Nightstream.Chip8.flagWritesNnnToI
abbrev flagIsJump := @Nightstream.Chip8.flagIsJump
abbrev flagIsBranch := @Nightstream.Chip8.flagIsBranch
abbrev flagIsMemOp := @Nightstream.Chip8.flagIsMemOp

-- ── Composite Flag / Control Constructors ──

abbrev routingFlags := @Nightstream.Chip8.routingFlags
abbrev controlBits := @Nightstream.Chip8.controlBits
abbrev flags := @Nightstream.Chip8.flags
abbrev wf := @Nightstream.Chip8.wf
abbrev isBit := @Nightstream.Chip8.isBit

-- ── Constraints ──

abbrev controlBitConstraints := @Nightstream.Chip8.controlBitConstraints
abbrev xLanePartitionConstraint := @Nightstream.Chip8.xLanePartitionConstraint
abbrev xLookupConstraint := @Nightstream.Chip8.xLookupConstraint
abbrev xMemConstraint := @Nightstream.Chip8.xMemConstraint
abbrev xPreserveConstraint := @Nightstream.Chip8.xPreserveConstraint
abbrev iRoutingConstraint := @Nightstream.Chip8.iRoutingConstraint
abbrev pcJumpConstraint := @Nightstream.Chip8.pcJumpConstraint
abbrev pcBranchConstraint := @Nightstream.Chip8.pcBranchConstraint
abbrev pcMemConstraint := @Nightstream.Chip8.pcMemConstraint
abbrev pcDefaultConstraint := @Nightstream.Chip8.pcDefaultConstraint
abbrev ramAddrActiveConstraint := @Nightstream.Chip8.ramAddrActiveConstraint
abbrev ramAddrInactiveConstraint := @Nightstream.Chip8.ramAddrInactiveConstraint
abbrev chip8RowLocalConstraints := @Nightstream.Chip8.chip8RowLocalConstraints
abbrev chip8RoutingConstraints := @Nightstream.Chip8.chip8RoutingConstraints

-- ── Soundness Theorems ──

abbrev chip8RowLocalSound := @Nightstream.Chip8.chip8RowLocalSound
abbrev chip8RoutingSound := @Nightstream.Chip8.chip8RoutingSound

-- ── Behavior Decoding ──

abbrev BehaviorClass := Nightstream.Chip8.BehaviorClass
abbrev behaviorFlags := @Nightstream.Chip8.behaviorFlags
abbrev decodeImage := @Nightstream.Chip8.decodeImage

-- ── Witness Construction ──

abbrev mkWitness := @Nightstream.Chip8.mkWitness
abbrev witnessForBehavior := @Nightstream.Chip8.witnessForBehavior

-- ── Routing / Witness Theorems ──

abbrev xRouting_oneHot := @Nightstream.Chip8.xRouting_oneHot
abbrev iRouting_forced := @Nightstream.Chip8.iRouting_forced
abbrev pcRouting_forced := @Nightstream.Chip8.pcRouting_forced
abbrev ramAddrRouting_forced := @Nightstream.Chip8.ramAddrRouting_forced
abbrev chip8RowLocalSound_of_constraints := @Nightstream.Chip8.chip8RowLocalSound_of_constraints
abbrev chip8RoutingSound_of_constraints := @Nightstream.Chip8.chip8RoutingSound_of_constraints
abbrev wf_witnessForBehavior := @Nightstream.Chip8.wf_witnessForBehavior
abbrev routingFlags_witnessForBehavior := @Nightstream.Chip8.routingFlags_witnessForBehavior
abbrev flags_witnessForBehavior := @Nightstream.Chip8.flags_witnessForBehavior
abbrev chip8RowLocalConstraints_witnessForBehavior :=
  @Nightstream.Chip8.chip8RowLocalConstraints_witnessForBehavior
abbrev chip8RoutingConstraints_witnessForBehavior :=
  @Nightstream.Chip8.chip8RoutingConstraints_witnessForBehavior
abbrev rowWitness_exists_of_decodeImage := @Nightstream.Chip8.rowWitness_exists_of_decodeImage
abbrev routingWitness_exists_of_decodeImage := @Nightstream.Chip8.routingWitness_exists_of_decodeImage

end RoutingInterface

end Nightstream.Chip8
