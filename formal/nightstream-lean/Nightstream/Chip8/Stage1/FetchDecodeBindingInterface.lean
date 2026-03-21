import Nightstream.Chip8.Stage1.FetchDecodeBinding

namespace Nightstream.Chip8

namespace FetchDecodeBindingInterface

-- ── Types & Enumerations ──

abbrev OpcodeId := Nightstream.Chip8.FetchDecodeBinding.OpcodeId
abbrev LookupKind := Nightstream.Chip8.FetchDecodeBinding.LookupKind
abbrev OperandSelector := Nightstream.Chip8.FetchDecodeBinding.OperandSelector
abbrev behaviorOfOpcode := @Nightstream.Chip8.FetchDecodeBinding.behaviorOfOpcode
abbrev DecodedStage1 := Nightstream.Chip8.FetchDecodeBinding.DecodedStage1
abbrev DecodedCore := Nightstream.Chip8.FetchDecodeBinding.DecodedCore
abbrev DecodedRow := Nightstream.Chip8.FetchDecodeBinding.DecodedRow
abbrev Program := Nightstream.Chip8.FetchDecodeBinding.Program

-- ── Field Extraction & Decode Functions ──

abbrev opcodeAt := @Nightstream.Chip8.FetchDecodeBinding.opcodeAt
abbrev topNibble := @Nightstream.Chip8.FetchDecodeBinding.topNibble
abbrev xField := @Nightstream.Chip8.FetchDecodeBinding.xField
abbrev yField := @Nightstream.Chip8.FetchDecodeBinding.yField
abbrev lowNibble := @Nightstream.Chip8.FetchDecodeBinding.lowNibble
abbrev kkField := @Nightstream.Chip8.FetchDecodeBinding.kkField
abbrev nnnAddrField := @Nightstream.Chip8.FetchDecodeBinding.nnnAddrField
abbrev nnnWordField := @Nightstream.Chip8.FetchDecodeBinding.nnnWordField
abbrev jumpTargetAligned := @Nightstream.Chip8.FetchDecodeBinding.jumpTargetAligned
abbrev invalidStage1 := @Nightstream.Chip8.FetchDecodeBinding.invalidStage1
abbrev decodeOpcodeWord := @Nightstream.Chip8.FetchDecodeBinding.decodeOpcodeWord
abbrev decodeStage1Word := @Nightstream.Chip8.FetchDecodeBinding.decodeStage1Word
abbrev selectOperand := @Nightstream.Chip8.FetchDecodeBinding.selectOperand
abbrev byteAddLo := @Nightstream.Chip8.FetchDecodeBinding.byteAddLo
abbrev equal8 := @Nightstream.Chip8.FetchDecodeBinding.equal8
abbrev evalLookup := @Nightstream.Chip8.FetchDecodeBinding.evalLookup
abbrev eq4Eval := @Nightstream.Chip8.FetchDecodeBinding.eq4Eval

-- ── Boundary Propositions ──

abbrev AluLookupBound := @Nightstream.Chip8.FetchDecodeBinding.AluLookupBound
abbrev BurstEqBound := @Nightstream.Chip8.FetchDecodeBinding.BurstEqBound
abbrev DecodeHandoffBound := @Nightstream.Chip8.FetchDecodeBinding.DecodeHandoffBound
abbrev FetchDecodeBound := @Nightstream.Chip8.FetchDecodeBinding.FetchDecodeBound

-- ── Field & Decode Theorems ──

abbrev behaviorOfOpcode_mem_decodeImage :=
  @Nightstream.Chip8.FetchDecodeBinding.behaviorOfOpcode_mem_decodeImage
abbrev xField_lt := @Nightstream.Chip8.FetchDecodeBinding.xField_lt
abbrev yField_lt := @Nightstream.Chip8.FetchDecodeBinding.yField_lt
abbrev kkField_lt := @Nightstream.Chip8.FetchDecodeBinding.kkField_lt
abbrev nnnAddrField_lt := @Nightstream.Chip8.FetchDecodeBinding.nnnAddrField_lt
abbrev nnnWordField_lt := @Nightstream.Chip8.FetchDecodeBinding.nnnWordField_lt
abbrev jumpTargetAligned_iff_even :=
  @Nightstream.Chip8.FetchDecodeBinding.jumpTargetAligned_iff_even
abbrev decodeOpcodeWord_deterministic :=
  @Nightstream.Chip8.FetchDecodeBinding.decodeOpcodeWord_deterministic
abbrev decodeStage1Word_total_defaults :=
  @Nightstream.Chip8.FetchDecodeBinding.decodeStage1Word_total_defaults
abbrev decodeOpcodeWord_valid := @Nightstream.Chip8.FetchDecodeBinding.decodeOpcodeWord_valid
abbrev decodeOpcodeWord_fields := @Nightstream.Chip8.FetchDecodeBinding.decodeOpcodeWord_fields
abbrev decodeOpcodeWord_wellFormed :=
  @Nightstream.Chip8.FetchDecodeBinding.decodeOpcodeWord_wellFormed
abbrev decodeOpcodeWord_nnnWord_lt :=
  @Nightstream.Chip8.FetchDecodeBinding.decodeOpcodeWord_nnnWord_lt
abbrev decodeOpcodeWord_jump_alignment :=
  @Nightstream.Chip8.FetchDecodeBinding.decodeOpcodeWord_jump_alignment
abbrev decodeOpcodeWord_noLookup_defaults :=
  @Nightstream.Chip8.FetchDecodeBinding.decodeOpcodeWord_noLookup_defaults
abbrev decodeOpcodeWord_nonMem_defaults :=
  @Nightstream.Chip8.FetchDecodeBinding.decodeOpcodeWord_nonMem_defaults
abbrev decodeOpcodeWord_handoff_exact :=
  @Nightstream.Chip8.FetchDecodeBinding.decodeOpcodeWord_handoff_exact
abbrev decodeOpcodeWord_usesY_bit :=
  @Nightstream.Chip8.FetchDecodeBinding.decodeOpcodeWord_usesY_bit
abbrev decodeOpcodeWord_readsRam_bit :=
  @Nightstream.Chip8.FetchDecodeBinding.decodeOpcodeWord_readsRam_bit
abbrev decodeOpcodeWord_writesRam_bit :=
  @Nightstream.Chip8.FetchDecodeBinding.decodeOpcodeWord_writesRam_bit
abbrev decodeOpcodeWord_laneWrite_cases :=
  @Nightstream.Chip8.FetchDecodeBinding.decodeOpcodeWord_laneWrite_cases
abbrev decodeOpcodeWord_nonNoLookup_usesLookupOpcode :=
  @Nightstream.Chip8.FetchDecodeBinding.decodeOpcodeWord_nonNoLookup_usesLookupOpcode
abbrev decodeOpcodeWord_readsRam_is_loadRegs :=
  @Nightstream.Chip8.FetchDecodeBinding.decodeOpcodeWord_readsRam_is_loadRegs
abbrev decodeOpcodeWord_writesRam_is_storeRegs :=
  @Nightstream.Chip8.FetchDecodeBinding.decodeOpcodeWord_writesRam_is_storeRegs

-- ── FetchDecode Boundary Theorems ──

abbrev fetchDecodeBound_opcodeAt := @Nightstream.Chip8.FetchDecodeBinding.fetchDecodeBound_opcodeAt
abbrev fetchDecodeBound_decodes := @Nightstream.Chip8.FetchDecodeBinding.fetchDecodeBound_decodes
abbrev fetchDecodeBound_unique := @Nightstream.Chip8.FetchDecodeBinding.fetchDecodeBound_unique
abbrev fetchDecodeBound_wellFormed := @Nightstream.Chip8.FetchDecodeBinding.fetchDecodeBound_wellFormed
abbrev fetchDecodeBound_valid := @Nightstream.Chip8.FetchDecodeBinding.fetchDecodeBound_valid
abbrev fetchDecodeBound_flags_mem_decodeImage :=
  @Nightstream.Chip8.FetchDecodeBinding.fetchDecodeBound_flags_mem_decodeImage

-- ── ALU / Burst Boundary Theorems ──

abbrev aluLookupBound_noLookup_zero :=
  @Nightstream.Chip8.FetchDecodeBinding.aluLookupBound_noLookup_zero
abbrev burstEqBound_nonMem_zero :=
  @Nightstream.Chip8.FetchDecodeBinding.burstEqBound_nonMem_zero

end FetchDecodeBindingInterface

end Nightstream.Chip8
