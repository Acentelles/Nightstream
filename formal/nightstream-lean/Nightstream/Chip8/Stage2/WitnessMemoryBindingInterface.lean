import Nightstream.Chip8.Stage2.WitnessMemoryBinding

namespace Nightstream.Chip8

namespace WitnessMemoryBindingInterface

abbrev MachineState := Nightstream.Chip8.WitnessMemoryBinding.MachineState
abbrev InitialState := Nightstream.Chip8.WitnessMemoryBinding.InitialState
abbrev RegisterAccess := Nightstream.Chip8.WitnessMemoryBinding.RegisterAccess
abbrev RamAccess := Nightstream.Chip8.WitnessMemoryBinding.RamAccess
abbrev StepMemoryTrace := Nightstream.Chip8.WitnessMemoryBinding.StepMemoryTrace
abbrev RegAddress := Nightstream.Chip8.WitnessMemoryBinding.RegAddress
abbrev RamAddress := Nightstream.Chip8.WitnessMemoryBinding.RamAddress

abbrev vAccess := @Nightstream.Chip8.WitnessMemoryBinding.vAccess
abbrev iAccess := @Nightstream.Chip8.WitnessMemoryBinding.iAccess
abbrev regAddressNat := @Nightstream.Chip8.WitnessMemoryBinding.regAddressNat
abbrev ramAddressNat := @Nightstream.Chip8.WitnessMemoryBinding.ramAddressNat
abbrev primaryIndex := @Nightstream.Chip8.WitnessMemoryBinding.primaryIndex
abbrev yIndexOf := @Nightstream.Chip8.WitnessMemoryBinding.yIndexOf
abbrev primaryValue := @Nightstream.Chip8.WitnessMemoryBinding.primaryValue
abbrev secondaryValue := @Nightstream.Chip8.WitnessMemoryBinding.secondaryValue
abbrev currentRamAddr := @Nightstream.Chip8.WitnessMemoryBinding.currentRamAddr
abbrev burstLastValue := @Nightstream.Chip8.WitnessMemoryBinding.burstLastValue
abbrev ramAddrValue := @Nightstream.Chip8.WitnessMemoryBinding.ramAddrValue
abbrev registerSlotValue := @Nightstream.Chip8.WitnessMemoryBinding.registerSlotValue
abbrev ramSlotValue := @Nightstream.Chip8.WitnessMemoryBinding.ramSlotValue
abbrev initialRegisterValue := @Nightstream.Chip8.WitnessMemoryBinding.initialRegisterValue
abbrev initialRamValue := @Nightstream.Chip8.WitnessMemoryBinding.initialRamValue
abbrev registerInitTable := @Nightstream.Chip8.WitnessMemoryBinding.registerInitTable
abbrev ramInitTable := @Nightstream.Chip8.WitnessMemoryBinding.ramInitTable
abbrev RegisterShiftedTimeTable :=
  @Nightstream.Chip8.WitnessMemoryBinding.RegisterShiftedTimeTable
abbrev RegisterShiftedVirtualValue :=
  @Nightstream.Chip8.WitnessMemoryBinding.RegisterShiftedVirtualValue
abbrev RegisterShiftedValEvaluationExpression :=
  @Nightstream.Chip8.WitnessMemoryBinding.RegisterShiftedValEvaluationExpression
abbrev RamShiftedTimeTable := @Nightstream.Chip8.WitnessMemoryBinding.RamShiftedTimeTable
abbrev RamShiftedVirtualValue :=
  @Nightstream.Chip8.WitnessMemoryBinding.RamShiftedVirtualValue
abbrev RamShiftedValEvaluationExpression :=
  @Nightstream.Chip8.WitnessMemoryBinding.RamShiftedValEvaluationExpression
abbrev registerReadXValue := @Nightstream.Chip8.WitnessMemoryBinding.registerReadXValue
abbrev registerReadYValue := @Nightstream.Chip8.WitnessMemoryBinding.registerReadYValue
abbrev registerReadIValue := @Nightstream.Chip8.WitnessMemoryBinding.registerReadIValue
abbrev registerWriteValue := @Nightstream.Chip8.WitnessMemoryBinding.registerWriteValue
abbrev ramReadValue := @Nightstream.Chip8.WitnessMemoryBinding.ramReadValue
abbrev ramWriteValue := @Nightstream.Chip8.WitnessMemoryBinding.ramWriteValue
abbrev registerWriteClaimValue := @Nightstream.Chip8.WitnessMemoryBinding.registerWriteClaimValue
abbrev ramReadClaimValue := @Nightstream.Chip8.WitnessMemoryBinding.ramReadClaimValue
abbrev ramWriteClaimValue := @Nightstream.Chip8.WitnessMemoryBinding.ramWriteClaimValue

abbrev WitnessBinds := @Nightstream.Chip8.WitnessMemoryBinding.WitnessBinds
abbrev SourceColumnsBound := @Nightstream.Chip8.WitnessMemoryBinding.SourceColumnsBound
abbrev MemValueBound := @Nightstream.Chip8.WitnessMemoryBinding.MemValueBound
abbrev Stage2LaneLinkBound := @Nightstream.Chip8.WitnessMemoryBinding.Stage2LaneLinkBound
abbrev RamRafBound := @Nightstream.Chip8.WitnessMemoryBinding.RamRafBound
abbrev RegisterPortsBound := @Nightstream.Chip8.WitnessMemoryBinding.RegisterPortsBound
abbrev RamPortsBound := @Nightstream.Chip8.WitnessMemoryBinding.RamPortsBound
abbrev InitialStateBound := @Nightstream.Chip8.WitnessMemoryBinding.InitialStateBound
abbrev LocalMemoryBound := @Nightstream.Chip8.WitnessMemoryBinding.LocalMemoryBound
abbrev memValueOf := @Nightstream.Chip8.WitnessMemoryBinding.memValueOf
abbrev MemoryBound := @Nightstream.Chip8.WitnessMemoryBinding.MemoryBound

abbrev registerReadsExpected := @Nightstream.Chip8.WitnessMemoryBinding.registerReadsExpected
abbrev registerWritesExpected := @Nightstream.Chip8.WitnessMemoryBinding.registerWritesExpected
abbrev ramReadsExpected := @Nightstream.Chip8.WitnessMemoryBinding.ramReadsExpected
abbrev ramWritesExpected := @Nightstream.Chip8.WitnessMemoryBinding.ramWritesExpected
abbrev expectedMemoryTrace := @Nightstream.Chip8.WitnessMemoryBinding.expectedMemoryTrace
abbrev TraceMatches := @Nightstream.Chip8.WitnessMemoryBinding.TraceMatches

abbrev witnessBinds_pc := @Nightstream.Chip8.WitnessMemoryBinding.witnessBinds_pc
abbrev witnessBinds_pcNext := @Nightstream.Chip8.WitnessMemoryBinding.witnessBinds_pcNext
abbrev witnessBinds_vx := @Nightstream.Chip8.WitnessMemoryBinding.witnessBinds_vx
abbrev witnessBinds_vy := @Nightstream.Chip8.WitnessMemoryBinding.witnessBinds_vy
abbrev witnessBinds_vxNext := @Nightstream.Chip8.WitnessMemoryBinding.witnessBinds_vxNext
abbrev witnessBinds_iReg := @Nightstream.Chip8.WitnessMemoryBinding.witnessBinds_iReg
abbrev witnessBinds_iNext := @Nightstream.Chip8.WitnessMemoryBinding.witnessBinds_iNext
abbrev witnessBinds_kk := @Nightstream.Chip8.WitnessMemoryBinding.witnessBinds_kk
abbrev witnessBinds_nnnAddr := @Nightstream.Chip8.WitnessMemoryBinding.witnessBinds_nnnAddr
abbrev witnessBinds_nnnWord := @Nightstream.Chip8.WitnessMemoryBinding.witnessBinds_nnnWord
abbrev witnessBinds_xIdx := @Nightstream.Chip8.WitnessMemoryBinding.witnessBinds_xIdx
abbrev witnessBinds_yIdx := @Nightstream.Chip8.WitnessMemoryBinding.witnessBinds_yIdx
abbrev witnessBinds_burstLast := @Nightstream.Chip8.WitnessMemoryBinding.witnessBinds_burstLast
abbrev witnessBinds_ramAddr := @Nightstream.Chip8.WitnessMemoryBinding.witnessBinds_ramAddr
abbrev witnessBinds_nnn := @Nightstream.Chip8.WitnessMemoryBinding.witnessBinds_nnn
abbrev witnessBinds_flags := @Nightstream.Chip8.WitnessMemoryBinding.witnessBinds_flags
abbrev witnessBinds_flags_mem_decodeImage :=
  @Nightstream.Chip8.WitnessMemoryBinding.witnessBinds_flags_mem_decodeImage

abbrev sourceColumnsBound_vx := @Nightstream.Chip8.WitnessMemoryBinding.sourceColumnsBound_vx
abbrev sourceColumnsBound_vy := @Nightstream.Chip8.WitnessMemoryBinding.sourceColumnsBound_vy
abbrev sourceColumnsBound_iReg := @Nightstream.Chip8.WitnessMemoryBinding.sourceColumnsBound_iReg
abbrev localMemoryBound_witness := @Nightstream.Chip8.WitnessMemoryBinding.localMemoryBound_witness
abbrev localMemoryBound_memValue := @Nightstream.Chip8.WitnessMemoryBinding.localMemoryBound_memValue
abbrev memoryBound_vx := @Nightstream.Chip8.WitnessMemoryBinding.memoryBound_vx
abbrev memoryBound_vy := @Nightstream.Chip8.WitnessMemoryBinding.memoryBound_vy
abbrev memoryBound_iReg := @Nightstream.Chip8.WitnessMemoryBinding.memoryBound_iReg
abbrev memoryBound_memValue := @Nightstream.Chip8.WitnessMemoryBinding.memoryBound_memValue
abbrev memoryBound_storeRegs_value :=
  @Nightstream.Chip8.WitnessMemoryBinding.memoryBound_storeRegs_value
abbrev memoryBound_loadRegs_value :=
  @Nightstream.Chip8.WitnessMemoryBinding.memoryBound_loadRegs_value
abbrev memoryBound_nonMemOp_value_zero :=
  @Nightstream.Chip8.WitnessMemoryBinding.memoryBound_nonMemOp_value_zero
abbrev memoryBound_registerPorts :=
  @Nightstream.Chip8.WitnessMemoryBinding.memoryBound_registerPorts
abbrev memoryBound_ramPorts := @Nightstream.Chip8.WitnessMemoryBinding.memoryBound_ramPorts
abbrev memoryBound_initialState :=
  @Nightstream.Chip8.WitnessMemoryBinding.memoryBound_initialState
abbrev initialStateBound_register :=
  @Nightstream.Chip8.WitnessMemoryBinding.initialStateBound_register
abbrev initialStateBound_i := @Nightstream.Chip8.WitnessMemoryBinding.initialStateBound_i
abbrev initialStateBound_regSink :=
  @Nightstream.Chip8.WitnessMemoryBinding.initialStateBound_regSink
abbrev registerInitTable_active :=
  @Nightstream.Chip8.WitnessMemoryBinding.registerInitTable_active
abbrev registerInitTable_i :=
  @Nightstream.Chip8.WitnessMemoryBinding.registerInitTable_i
abbrev registerInitTable_sink :=
  @Nightstream.Chip8.WitnessMemoryBinding.registerInitTable_sink
abbrev initialStateBound_ram := @Nightstream.Chip8.WitnessMemoryBinding.initialStateBound_ram
abbrev initialStateBound_ramSink :=
  @Nightstream.Chip8.WitnessMemoryBinding.initialStateBound_ramSink
abbrev ramInitTable_active :=
  @Nightstream.Chip8.WitnessMemoryBinding.ramInitTable_active
abbrev ramInitTable_sink :=
  @Nightstream.Chip8.WitnessMemoryBinding.ramInitTable_sink
abbrev registerShiftedVirtualValue_at_bitCycle :=
  @Nightstream.Chip8.WitnessMemoryBinding.registerShiftedVirtualValue_at_bitCycle
abbrev registerShiftedValEvaluationExpression_eq_timeTableMLE :=
  @Nightstream.Chip8.WitnessMemoryBinding.registerShiftedValEvaluationExpression_eq_timeTableMLE
abbrev registerTimeTableMLE_shifted_at_bitAddress :=
  @Nightstream.Chip8.WitnessMemoryBinding.registerTimeTableMLE_shifted_at_bitAddress
abbrev ramShiftedVirtualValue_at_bitCycle :=
  @Nightstream.Chip8.WitnessMemoryBinding.ramShiftedVirtualValue_at_bitCycle
abbrev ramShiftedValEvaluationExpression_eq_timeTableMLE :=
  @Nightstream.Chip8.WitnessMemoryBinding.ramShiftedValEvaluationExpression_eq_timeTableMLE
abbrev ramTimeTableMLE_shifted_at_bitAddress :=
  @Nightstream.Chip8.WitnessMemoryBinding.ramTimeTableMLE_shifted_at_bitAddress
abbrev initialStateBound_exact :=
  @Nightstream.Chip8.WitnessMemoryBinding.initialStateBound_exact

abbrev traceMatches_registerReads :=
  @Nightstream.Chip8.WitnessMemoryBinding.traceMatches_registerReads
abbrev traceMatches_registerWrites :=
  @Nightstream.Chip8.WitnessMemoryBinding.traceMatches_registerWrites
abbrev traceMatches_ramReads := @Nightstream.Chip8.WitnessMemoryBinding.traceMatches_ramReads
abbrev traceMatches_ramWrites := @Nightstream.Chip8.WitnessMemoryBinding.traceMatches_ramWrites
abbrev storeRegs_trace_counts := @Nightstream.Chip8.WitnessMemoryBinding.storeRegs_trace_counts
abbrev loadRegs_trace_counts := @Nightstream.Chip8.WitnessMemoryBinding.loadRegs_trace_counts

end WitnessMemoryBindingInterface

end Nightstream.Chip8
