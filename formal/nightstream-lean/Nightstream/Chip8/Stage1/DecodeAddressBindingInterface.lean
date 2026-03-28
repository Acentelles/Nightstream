import Nightstream.Chip8.Stage1.DecodeAddressBinding

namespace Nightstream.Chip8

namespace DecodeAddressBindingInterface

-- ── Types ──

abbrev AddressRole := Nightstream.Chip8.DecodeAddressBinding.AddressRole
abbrev DecodedStep := Nightstream.Chip8.DecodeAddressBinding.DecodedStep
abbrev DecodedRow := Nightstream.Chip8.DecodeAddressBinding.DecodedRow

-- ── Predicates & Propositions ──

abbrev UsesLookup := @Nightstream.Chip8.DecodeAddressBinding.UsesLookup
abbrev UsesReadMem := @Nightstream.Chip8.DecodeAddressBinding.UsesReadMem
abbrev UsesWriteMem := @Nightstream.Chip8.DecodeAddressBinding.UsesWriteMem
abbrev behavior := @Nightstream.Chip8.DecodeAddressBinding.behavior
abbrev Stage1Decoded := @Nightstream.Chip8.DecodeAddressBinding.Stage1Decoded
abbrev NoLookupOperandsZero := @Nightstream.Chip8.DecodeAddressBinding.NoLookupOperandsZero
abbrev DecodeAddressShape := @Nightstream.Chip8.DecodeAddressBinding.DecodeAddressShape

-- ── Address Key & Sink Functions ──

abbrev lookupKindCode := @Nightstream.Chip8.DecodeAddressBinding.lookupKindCode
abbrev flattenAluKey := @Nightstream.Chip8.DecodeAddressBinding.flattenAluKey
abbrev eq4Key := @Nightstream.Chip8.DecodeAddressBinding.eq4Key
abbrev regSinkAddr := Nightstream.Chip8.DecodeAddressBinding.regSinkAddr
abbrev ramSinkAddr := Nightstream.Chip8.DecodeAddressBinding.ramSinkAddr

-- ── Index & Projection Functions ──

abbrev ActiveXIndexBound := @Nightstream.Chip8.DecodeAddressBinding.ActiveXIndexBound
abbrev activeXIndex := @Nightstream.Chip8.DecodeAddressBinding.activeXIndex
abbrev burstLast := @Nightstream.Chip8.DecodeAddressBinding.burstLast
abbrev projectedYIndex := @Nightstream.Chip8.DecodeAddressBinding.projectedYIndex
abbrev projectedNatAddressAt := @Nightstream.Chip8.DecodeAddressBinding.projectedNatAddressAt
abbrev projectedAddress := @Nightstream.Chip8.DecodeAddressBinding.projectedAddress

-- ── Kernel Address Bound ──

abbrev KernelAddressBoundAt := @Nightstream.Chip8.DecodeAddressBinding.KernelAddressBoundAt
abbrev KernelAddressBound := @Nightstream.Chip8.DecodeAddressBinding.KernelAddressBound

-- ── Kernel Address Theorems ──

abbrev kernelAddressBound_iff_projectedAddress :=
  @Nightstream.Chip8.DecodeAddressBinding.kernelAddressBound_iff_projectedAddress
abbrev kernelAddressBound_iff_familyProjection :=
  @Nightstream.Chip8.DecodeAddressBinding.kernelAddressBound_iff_familyProjection
abbrev kernelAddressBoundAt_projected :=
  @Nightstream.Chip8.DecodeAddressBinding.kernelAddressBoundAt_projected
abbrev kernelAddressBoundAt_fetch :=
  @Nightstream.Chip8.DecodeAddressBinding.kernelAddressBoundAt_fetch
abbrev kernelAddressBoundAt_decode :=
  @Nightstream.Chip8.DecodeAddressBinding.kernelAddressBoundAt_decode
abbrev kernelAddressBound_of_boundAt :=
  @Nightstream.Chip8.DecodeAddressBinding.kernelAddressBound_of_boundAt

-- ── ActiveXIndex Theorems ──

abbrev activeXIndex_of_storeRegs :=
  @Nightstream.Chip8.DecodeAddressBinding.activeXIndex_of_storeRegs
abbrev activeXIndex_of_loadRegs :=
  @Nightstream.Chip8.DecodeAddressBinding.activeXIndex_of_loadRegs
abbrev activeXIndex_of_nonBurst :=
  @Nightstream.Chip8.DecodeAddressBinding.activeXIndex_of_nonBurst

-- ── Stage1Decoded Property Theorems ──

abbrev stage1Decoded_wellFormed :=
  @Nightstream.Chip8.DecodeAddressBinding.stage1Decoded_wellFormed
abbrev stage1Decoded_usesY_bit :=
  @Nightstream.Chip8.DecodeAddressBinding.stage1Decoded_usesY_bit
abbrev stage1Decoded_readsRam_bit :=
  @Nightstream.Chip8.DecodeAddressBinding.stage1Decoded_readsRam_bit
abbrev stage1Decoded_writesRam_bit :=
  @Nightstream.Chip8.DecodeAddressBinding.stage1Decoded_writesRam_bit
abbrev stage1Decoded_laneWrite_cases :=
  @Nightstream.Chip8.DecodeAddressBinding.stage1Decoded_laneWrite_cases
abbrev stage1Decoded_nonNoLookup_usesLookupOpcode :=
  @Nightstream.Chip8.DecodeAddressBinding.stage1Decoded_nonNoLookup_usesLookupOpcode
abbrev stage1Decoded_readsRam_is_loadRegs :=
  @Nightstream.Chip8.DecodeAddressBinding.stage1Decoded_readsRam_is_loadRegs
abbrev stage1Decoded_writesRam_is_storeRegs :=
  @Nightstream.Chip8.DecodeAddressBinding.stage1Decoded_writesRam_is_storeRegs

-- ── Address Role Requirement Theorems ──

abbrev aluAddress_requires_lookup_family :=
  @Nightstream.Chip8.DecodeAddressBinding.aluAddress_requires_lookup_family
abbrev lookupAddress_requires_lookup_family :=
  @Nightstream.Chip8.DecodeAddressBinding.lookupAddress_requires_lookup_family
abbrev ramReadAddress_requires_readsRam :=
  @Nightstream.Chip8.DecodeAddressBinding.ramReadAddress_requires_readsRam
abbrev ramWriteAddress_requires_writesRam :=
  @Nightstream.Chip8.DecodeAddressBinding.ramWriteAddress_requires_writesRam
abbrev readMemAddress_requires_loadRegs :=
  @Nightstream.Chip8.DecodeAddressBinding.readMemAddress_requires_loadRegs
abbrev writeMemAddress_requires_storeRegs :=
  @Nightstream.Chip8.DecodeAddressBinding.writeMemAddress_requires_storeRegs
abbrev regYAddress_uses_sink_iff_not_usesY :=
  @Nightstream.Chip8.DecodeAddressBinding.regYAddress_uses_sink_iff_not_usesY
abbrev regWriteAddress_uses_sink_iff_no_lane_write :=
  @Nightstream.Chip8.DecodeAddressBinding.regWriteAddress_uses_sink_iff_no_lane_write

end DecodeAddressBindingInterface

end Nightstream.Chip8
