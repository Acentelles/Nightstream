import Nightstream.Rv64IM.Generated.ParityTypes

namespace Nightstream.Rv64IM.Generated.Cases.Case_native_logic_compare_chain_ecall

open Nightstream.Rv64IM.Generated

def derivedCase : ParityDerivedCase :=
  {
  manifest := { name := "native_logic_compare_chain_ecall", fixtureId := "native_logic_compare_chain_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , executionRows := [{
  traceIndex := 0
  , stepIndex := 0
  , sequenceIndex := 0
  , pc := 0
  , nextPc := 4
  , word := 5243027
  , opcode := .addi
  , traceOpcode := (some .addi)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 0
  , rs1Value := 0
  , rs2 := 0
  , rs2Value := 0
  , rd := 1
  , rdBefore := 0
  , rdAfter := 5
  , imm := 5
  , aluResult := 5
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := true
  , virtualSequenceRemaining := none
  , isEffectRow := true
  , isCommitRow := true
  , isReal := true
}, {
  traceIndex := 1
  , stepIndex := 1
  , sequenceIndex := 0
  , pc := 4
  , nextPc := 8
  , word := 3146003
  , opcode := .addi
  , traceOpcode := (some .addi)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 0
  , rs1Value := 0
  , rs2 := 0
  , rs2Value := 0
  , rd := 2
  , rdBefore := 0
  , rdAfter := 3
  , imm := 3
  , aluResult := 3
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := true
  , virtualSequenceRemaining := none
  , isEffectRow := true
  , isCommitRow := true
  , isReal := true
}, {
  traceIndex := 2
  , stepIndex := 2
  , sequenceIndex := 0
  , pc := 8
  , nextPc := 12
  , word := 2159027
  , opcode := .and
  , traceOpcode := (some .and)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 5
  , rs2 := 2
  , rs2Value := 3
  , rd := 3
  , rdBefore := 0
  , rdAfter := 1
  , imm := 0
  , aluResult := 1
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := true
  , virtualSequenceRemaining := none
  , isEffectRow := true
  , isCommitRow := true
  , isReal := true
}, {
  traceIndex := 3
  , stepIndex := 3
  , sequenceIndex := 0
  , pc := 12
  , nextPc := 16
  , word := 6353427
  , opcode := .andi
  , traceOpcode := (some .andi)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 5
  , rs2 := 0
  , rs2Value := 0
  , rd := 4
  , rdBefore := 0
  , rdAfter := 4
  , imm := 6
  , aluResult := 4
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := true
  , virtualSequenceRemaining := none
  , isEffectRow := true
  , isCommitRow := true
  , isReal := true
}, {
  traceIndex := 4
  , stepIndex := 4
  , sequenceIndex := 0
  , pc := 16
  , nextPc := 20
  , word := 2155187
  , opcode := .or
  , traceOpcode := (some .or)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 5
  , rs2 := 2
  , rs2Value := 3
  , rd := 5
  , rdBefore := 0
  , rdAfter := 7
  , imm := 0
  , aluResult := 7
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := true
  , virtualSequenceRemaining := none
  , isEffectRow := true
  , isCommitRow := true
  , isReal := true
}, {
  traceIndex := 5
  , stepIndex := 5
  , sequenceIndex := 0
  , pc := 20
  , nextPc := 24
  , word := 8479507
  , opcode := .ori
  , traceOpcode := (some .ori)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 2
  , rs1Value := 3
  , rs2 := 0
  , rs2Value := 0
  , rd := 6
  , rdBefore := 0
  , rdAfter := 11
  , imm := 8
  , aluResult := 11
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := true
  , virtualSequenceRemaining := none
  , isEffectRow := true
  , isCommitRow := true
  , isReal := true
}, {
  traceIndex := 6
  , stepIndex := 6
  , sequenceIndex := 0
  , pc := 24
  , nextPc := 28
  , word := 2147251
  , opcode := .xor
  , traceOpcode := (some .xor)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 5
  , rs2 := 2
  , rs2Value := 3
  , rd := 7
  , rdBefore := 0
  , rdAfter := 6
  , imm := 0
  , aluResult := 6
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := true
  , virtualSequenceRemaining := none
  , isEffectRow := true
  , isCommitRow := true
  , isReal := true
}, {
  traceIndex := 7
  , stepIndex := 7
  , sequenceIndex := 0
  , pc := 28
  , nextPc := 32
  , word := 7390227
  , opcode := .xori
  , traceOpcode := (some .xori)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 5
  , rs2 := 0
  , rs2Value := 0
  , rd := 8
  , rdBefore := 0
  , rdAfter := 2
  , imm := 7
  , aluResult := 2
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := true
  , virtualSequenceRemaining := none
  , isEffectRow := true
  , isCommitRow := true
  , isReal := true
}, {
  traceIndex := 8
  , stepIndex := 8
  , sequenceIndex := 0
  , pc := 32
  , nextPc := 36
  , word := 1123507
  , opcode := .slt
  , traceOpcode := (some .slt)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 2
  , rs1Value := 3
  , rs2 := 1
  , rs2Value := 5
  , rd := 9
  , rdBefore := 0
  , rdAfter := 1
  , imm := 0
  , aluResult := 1
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := true
  , virtualSequenceRemaining := none
  , isEffectRow := true
  , isCommitRow := true
  , isReal := true
}, {
  traceIndex := 9
  , stepIndex := 9
  , sequenceIndex := 0
  , pc := 36
  , nextPc := 40
  , word := 4269331
  , opcode := .slti
  , traceOpcode := (some .slti)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 2
  , rs1Value := 3
  , rs2 := 0
  , rs2Value := 0
  , rd := 10
  , rdBefore := 0
  , rdAfter := 1
  , imm := 4
  , aluResult := 1
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := true
  , virtualSequenceRemaining := none
  , isEffectRow := true
  , isCommitRow := true
  , isReal := true
}, {
  traceIndex := 10
  , stepIndex := 10
  , sequenceIndex := 0
  , pc := 40
  , nextPc := 44
  , word := 1127859
  , opcode := .sltu
  , traceOpcode := (some .sltu)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 2
  , rs1Value := 3
  , rs2 := 1
  , rs2Value := 5
  , rd := 11
  , rdBefore := 0
  , rdAfter := 1
  , imm := 0
  , aluResult := 1
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := true
  , virtualSequenceRemaining := none
  , isEffectRow := true
  , isCommitRow := true
  , isReal := true
}, {
  traceIndex := 11
  , stepIndex := 11
  , sequenceIndex := 0
  , pc := 44
  , nextPc := 48
  , word := 4240915
  , opcode := .sltiu
  , traceOpcode := (some .sltiu)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 5
  , rs2 := 0
  , rs2Value := 0
  , rd := 12
  , rdBefore := 0
  , rdAfter := 0
  , imm := 4
  , aluResult := 0
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := true
  , virtualSequenceRemaining := none
  , isEffectRow := true
  , isCommitRow := true
  , isReal := true
}, {
  traceIndex := 12
  , stepIndex := 12
  , sequenceIndex := 0
  , pc := 48
  , nextPc := 52
  , word := 15
  , opcode := .fence
  , traceOpcode := (some .fence)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 0
  , rs1Value := 0
  , rs2 := 0
  , rs2Value := 0
  , rd := 0
  , rdBefore := 0
  , rdAfter := 0
  , imm := 0
  , aluResult := 0
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := false
  , writesRam := false
  , halted := false
  , isFirstInSequence := true
  , virtualSequenceRemaining := none
  , isEffectRow := true
  , isCommitRow := true
  , isReal := true
}, {
  traceIndex := 13
  , stepIndex := 13
  , sequenceIndex := 0
  , pc := 52
  , nextPc := 56
  , word := 115
  , opcode := .ecall
  , traceOpcode := (some .ecall)
  , traceVirtualOpcode := none
  , family := .controlFlow
  , rs1 := 0
  , rs1Value := 0
  , rs2 := 0
  , rs2Value := 0
  , rd := 0
  , rdBefore := 0
  , rdAfter := 0
  , imm := 0
  , aluResult := 0
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := false
  , writesRam := false
  , halted := true
  , isFirstInSequence := true
  , virtualSequenceRemaining := none
  , isEffectRow := true
  , isCommitRow := true
  , isReal := true
}]
  , stage1 := { rows := [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 5243027, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 4, aluResult := 5, effectiveAddr := none, writesRd := true, rd := 1, rdAfter := 5, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 3146003, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 8, aluResult := 3, effectiveAddr := none, writesRd := true, rd := 2, rdAfter := 3, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 2159027, opcode := .and, traceOpcode := (some .and), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 12, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 3, rdAfter := 1, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 12, fetchedWord := 6353427, opcode := .andi, traceOpcode := (some .andi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 16, aluResult := 4, effectiveAddr := none, writesRd := true, rd := 4, rdAfter := 4, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 4, stepIndex := 4, sequenceIndex := 0, fetchPc := 16, fetchedWord := 2155187, opcode := .or, traceOpcode := (some .or), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 20, aluResult := 7, effectiveAddr := none, writesRd := true, rd := 5, rdAfter := 7, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 5, stepIndex := 5, sequenceIndex := 0, fetchPc := 20, fetchedWord := 8479507, opcode := .ori, traceOpcode := (some .ori), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 24, aluResult := 11, effectiveAddr := none, writesRd := true, rd := 6, rdAfter := 11, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 6, stepIndex := 6, sequenceIndex := 0, fetchPc := 24, fetchedWord := 2147251, opcode := .xor, traceOpcode := (some .xor), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 28, aluResult := 6, effectiveAddr := none, writesRd := true, rd := 7, rdAfter := 6, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 7, stepIndex := 7, sequenceIndex := 0, fetchPc := 28, fetchedWord := 7390227, opcode := .xori, traceOpcode := (some .xori), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 32, aluResult := 2, effectiveAddr := none, writesRd := true, rd := 8, rdAfter := 2, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 8, stepIndex := 8, sequenceIndex := 0, fetchPc := 32, fetchedWord := 1123507, opcode := .slt, traceOpcode := (some .slt), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 36, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 9, rdAfter := 1, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 9, stepIndex := 9, sequenceIndex := 0, fetchPc := 36, fetchedWord := 4269331, opcode := .slti, traceOpcode := (some .slti), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 40, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 10, rdAfter := 1, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 10, stepIndex := 10, sequenceIndex := 0, fetchPc := 40, fetchedWord := 1127859, opcode := .sltu, traceOpcode := (some .sltu), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 44, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 11, rdAfter := 1, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 11, stepIndex := 11, sequenceIndex := 0, fetchPc := 44, fetchedWord := 4240915, opcode := .sltiu, traceOpcode := (some .sltiu), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 48, aluResult := 0, effectiveAddr := none, writesRd := true, rd := 12, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 12, stepIndex := 12, sequenceIndex := 0, fetchPc := 48, fetchedWord := 15, opcode := .fence, traceOpcode := (some .fence), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 52, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }, { traceIndex := 13, stepIndex := 13, sequenceIndex := 0, fetchPc := 52, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 56, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }] }
  , stage2 := {
  registerReads := [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 0, value := 0 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 0, value := 0 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 1, value := 5 }, { traceIndex := 2, stepIndex := 2, role := .rs2, reg := 2, value := 3 }, { traceIndex := 3, stepIndex := 3, role := .rs1, reg := 1, value := 5 }, { traceIndex := 4, stepIndex := 4, role := .rs1, reg := 1, value := 5 }, { traceIndex := 4, stepIndex := 4, role := .rs2, reg := 2, value := 3 }, { traceIndex := 5, stepIndex := 5, role := .rs1, reg := 2, value := 3 }, { traceIndex := 6, stepIndex := 6, role := .rs1, reg := 1, value := 5 }, { traceIndex := 6, stepIndex := 6, role := .rs2, reg := 2, value := 3 }, { traceIndex := 7, stepIndex := 7, role := .rs1, reg := 1, value := 5 }, { traceIndex := 8, stepIndex := 8, role := .rs1, reg := 2, value := 3 }, { traceIndex := 8, stepIndex := 8, role := .rs2, reg := 1, value := 5 }, { traceIndex := 9, stepIndex := 9, role := .rs1, reg := 2, value := 3 }, { traceIndex := 10, stepIndex := 10, role := .rs1, reg := 2, value := 3 }, { traceIndex := 10, stepIndex := 10, role := .rs2, reg := 1, value := 5 }, { traceIndex := 11, stepIndex := 11, role := .rs1, reg := 1, value := 5 }]
  , registerWrites := [{ traceIndex := 0, stepIndex := 0, reg := 1, previous := 0, next := 5 }, { traceIndex := 1, stepIndex := 1, reg := 2, previous := 0, next := 3 }, { traceIndex := 2, stepIndex := 2, reg := 3, previous := 0, next := 1 }, { traceIndex := 3, stepIndex := 3, reg := 4, previous := 0, next := 4 }, { traceIndex := 4, stepIndex := 4, reg := 5, previous := 0, next := 7 }, { traceIndex := 5, stepIndex := 5, reg := 6, previous := 0, next := 11 }, { traceIndex := 6, stepIndex := 6, reg := 7, previous := 0, next := 6 }, { traceIndex := 7, stepIndex := 7, reg := 8, previous := 0, next := 2 }, { traceIndex := 8, stepIndex := 8, reg := 9, previous := 0, next := 1 }, { traceIndex := 9, stepIndex := 9, reg := 10, previous := 0, next := 1 }, { traceIndex := 10, stepIndex := 10, reg := 11, previous := 0, next := 1 }, { traceIndex := 11, stepIndex := 11, reg := 12, previous := 0, next := 0 }]
  , ramEvents := []
  , twistLinks := [{ traceIndex := 0, stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 5), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 1, family := .nativeAlu, routedWriteValue := (some 3), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 2, family := .nativeAlu, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 3, family := .nativeAlu, routedWriteValue := (some 4), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 4, stepIndex := 4, family := .nativeAlu, routedWriteValue := (some 7), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 5, stepIndex := 5, family := .nativeAlu, routedWriteValue := (some 11), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 6, stepIndex := 6, family := .nativeAlu, routedWriteValue := (some 6), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 7, stepIndex := 7, family := .nativeAlu, routedWriteValue := (some 2), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 8, stepIndex := 8, family := .nativeAlu, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 9, stepIndex := 9, family := .nativeAlu, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 10, stepIndex := 10, family := .nativeAlu, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 11, stepIndex := 11, family := .nativeAlu, routedWriteValue := (some 0), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 12, stepIndex := 12, family := .nativeAlu, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 13, stepIndex := 13, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]
}
  , stage3 := {
  continuity := [{ stepIndex := 0, pc := 0, nextPc := 4, successorPc := (some 4), finalStep := false, continuityHolds := true }, { stepIndex := 1, pc := 4, nextPc := 8, successorPc := (some 8), finalStep := false, continuityHolds := true }, { stepIndex := 2, pc := 8, nextPc := 12, successorPc := (some 12), finalStep := false, continuityHolds := true }, { stepIndex := 3, pc := 12, nextPc := 16, successorPc := (some 16), finalStep := false, continuityHolds := true }, { stepIndex := 4, pc := 16, nextPc := 20, successorPc := (some 20), finalStep := false, continuityHolds := true }, { stepIndex := 5, pc := 20, nextPc := 24, successorPc := (some 24), finalStep := false, continuityHolds := true }, { stepIndex := 6, pc := 24, nextPc := 28, successorPc := (some 28), finalStep := false, continuityHolds := true }, { stepIndex := 7, pc := 28, nextPc := 32, successorPc := (some 32), finalStep := false, continuityHolds := true }, { stepIndex := 8, pc := 32, nextPc := 36, successorPc := (some 36), finalStep := false, continuityHolds := true }, { stepIndex := 9, pc := 36, nextPc := 40, successorPc := (some 40), finalStep := false, continuityHolds := true }, { stepIndex := 10, pc := 40, nextPc := 44, successorPc := (some 44), finalStep := false, continuityHolds := true }, { stepIndex := 11, pc := 44, nextPc := 48, successorPc := (some 48), finalStep := false, continuityHolds := true }, { stepIndex := 12, pc := 48, nextPc := 52, successorPc := (some 52), finalStep := false, continuityHolds := true }, { stepIndex := 13, pc := 52, nextPc := 56, successorPc := none, finalStep := true, continuityHolds := true }]
  , halted := true
}
  , transcript := {
  appLabel := (bytes [110, 101, 111, 46, 102, 111, 108, 100, 46, 110, 101, 120, 116, 47, 114, 118, 54, 52, 105, 109, 47, 112, 97, 114, 105, 116, 121, 95, 107, 101, 114, 110, 101, 108, 95, 118, 49])
  , events := [{
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 116, 114, 97, 110, 115, 99, 114, 105, 112, 116, 95, 115, 101, 101, 100])
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 110, 97, 116, 105, 118, 101, 45, 108, 111, 103, 105, 99, 45, 99, 111, 109, 112, 97, 114, 101, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [27915927687753580, 12777915887414639, 12662, 14004900292649954342, 13728117369159879657, 11693063383591262488, 17082852510017092719, 16363809030615601355], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [110, 97, 116, 105, 118, 101, 95, 108, 111, 103, 105, 99, 95, 99, 111, 109, 112, 97, 114, 101, 95, 99, 104, 97, 105, 110, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [27915927687753580, 12777915887414639, 12662, 14004900292649954342, 13728117369159879657, 11693063383591262488, 17082852510017092719, 16363809030615601355], absorbed := 3 }
  , cursorAfter := { stateWords := [28533900466808931, 1819042147, 14675078370321938727, 4574521486179947848, 5924462245161849131, 2698773299494092040, 9075337403133714940, 4191472899665087393], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [5243027, 3146003, 2159027, 6353427, 2155187, 8479507, 2147251, 7390227, 1123507, 4269331, 1127859, 4240915, 15, 115]
  , cursorBefore := { stateWords := [28533900466808931, 1819042147, 14675078370321938727, 4574521486179947848, 5924462245161849131, 2698773299494092040, 9075337403133714940, 4191472899665087393], absorbed := 2 }
  , cursorAfter := { stateWords := [3276447219741767340, 13078479345119520091, 12592238531974894527, 6748780606875837271, 4492818906924154559, 11103094219351273320, 3262392760021944179, 1928312561396356522], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [3276447219741767340, 13078479345119520091, 12592238531974894527, 6748780606875837271, 4492818906924154559, 11103094219351273320, 3262392760021944179, 1928312561396356522], absorbed := 0 }
  , cursorAfter := { stateWords := [0, 0, 10459399774905745288, 8328946169001223494, 5691556989607583735, 14974589011629786926, 738872076179659364, 16017586578460096676], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [0, 0, 10459399774905745288, 8328946169001223494, 5691556989607583735, 14974589011629786926, 738872076179659364, 16017586578460096676], absorbed := 2 }
  , cursorAfter := { stateWords := [13348506805888363, 30506403037277801, 34184295084289375, 0, 12756469965976968519, 2744792860478371236, 17860809758803000662, 15715310416387930124], absorbed := 4 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [160, 47, 136, 108, 204, 129, 79, 197, 229, 103, 193, 132, 46, 237, 116, 161, 76, 12, 119, 193, 191, 6, 227, 119, 236, 118, 88, 172, 48, 50, 35, 98])
  , u64s := []
  , cursorBefore := { stateWords := [13348506805888363, 30506403037277801, 34184295084289375, 0, 12756469965976968519, 2744792860478371236, 17860809758803000662, 15715310416387930124], absorbed := 4 }
  , cursorAfter := { stateWords := [53974437603352948, 48510963790897926, 1646473776, 13300600973611324196, 7380724067355609945, 9565502279824397969, 15874006747358156928, 15902665604271536949], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [53974437603352948, 48510963790897926, 1646473776, 13300600973611324196, 7380724067355609945, 9565502279824397969, 15874006747358156928, 15902665604271536949], absorbed := 3 }
  , cursorAfter := { stateWords := [3705222010059132808, 10705559429118986591, 1156729734218909101, 8423534567024735570, 9095578176136919767, 13676969085484049303, 1580895861586138354, 2032458426184116188], absorbed := 0 }
  , challengeOutput := (some 3705222010059132808)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [64, 180, 146, 246, 139, 60, 76, 212, 49, 131, 207, 237, 101, 254, 127, 102, 212, 72, 236, 89, 205, 253, 188, 71, 14, 72, 168, 245, 217, 88, 55, 93])
  , u64s := []
  , cursorBefore := { stateWords := [3705222010059132808, 10705559429118986591, 1156729734218909101, 8423534567024735570, 9095578176136919767, 13676969085484049303, 1580895861586138354, 2032458426184116188], absorbed := 0 }
  , cursorAfter := { stateWords := [57801241594717823, 69146396724804861, 1563908313, 15717703205190525445, 6907845539242118593, 14017363633327132095, 8563616863401045740, 7187696116192749015], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [57801241594717823, 69146396724804861, 1563908313, 15717703205190525445, 6907845539242118593, 14017363633327132095, 8563616863401045740, 7187696116192749015], absorbed := 3 }
  , cursorAfter := { stateWords := [7940266179000280847, 17128601962132279149, 1049842007288689975, 9265992555679375098, 10336381086471234629, 9918544998845487875, 2119026821034374262, 15723449175245520992], absorbed := 0 }
  , challengeOutput := (some 7940266179000280847)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [7940266179000280847, 17128601962132279149, 1049842007288689975, 9265992555679375098, 10336381086471234629, 9918544998845487875, 2119026821034374262, 15723449175245520992], absorbed := 0 }
  , cursorAfter := { stateWords := [4123130262336711476, 14111673298204184757, 5156360653013349129, 11211280577908904830, 803754858751632307, 5691479114664987180, 17877381527979292013, 14816230815792099199], absorbed := 0 }
  , challengeOutput := (some 4123130262336711476)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [52, 185, 8, 160, 143, 178, 154, 190, 101, 228, 204, 246, 221, 136, 74, 154, 136, 97, 99, 235, 127, 33, 115, 45, 30, 159, 243, 89, 15, 247, 157, 142])
  , u64s := []
  , cursorBefore := { stateWords := [4123130262336711476, 14111673298204184757, 5156360653013349129, 11211280577908904830, 803754858751632307, 5691479114664987180, 17877381527979292013, 14816230815792099199], absorbed := 0 }
  , cursorAfter := { stateWords := [36006134112885322, 25319137658893089, 2392717071, 18249389629117730808, 12336873607744378464, 14852699958375720157, 7400218705089070248, 6850034240698606523], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [36006134112885322, 25319137658893089, 2392717071, 18249389629117730808, 12336873607744378464, 14852699958375720157, 7400218705089070248, 6850034240698606523], absorbed := 3 }
  , cursorAfter := { stateWords := [13522001880879900227, 2076012353615447445, 6283777378358488802, 6397285422002702166, 22029644498711621, 8946322245240676634, 14425569364995812978, 10554284728068128014], absorbed := 0 }
  , challengeOutput := (some 13522001880879900227)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [84, 58, 119, 62, 227, 203, 157, 120, 91, 33, 164, 86, 114, 27, 21, 233, 168, 252, 76, 12, 100, 202, 132, 82, 6, 21, 143, 29, 61, 32, 51, 38])
  , u64s := []
  , cursorBefore := { stateWords := [13522001880879900227, 2076012353615447445, 6283777378358488802, 6397285422002702166, 22029644498711621, 8946322245240676634, 14425569364995812978, 10554284728068128014], absorbed := 0 }
  , cursorAfter := { stateWords := [28161022467041557, 8320094787765450, 640884797, 10688822229477720999, 2298505535517364726, 9010554323198895477, 13396947121714209208, 18289360312464286512], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [160, 227, 4, 85, 140, 249, 7, 83, 176, 183, 120, 10, 187, 25, 9, 75, 146, 246, 100, 53, 9, 137, 26, 48, 91, 20, 9, 143, 92, 16, 180, 9])
  , u64s := []
  , cursorBefore := { stateWords := [28161022467041557, 8320094787765450, 640884797, 10688822229477720999, 2298505535517364726, 9010554323198895477, 13396947121714209208, 18289360312464286512], absorbed := 3 }
  , cursorAfter := { stateWords := [2591982540180233, 40260904703498889, 162795612, 11106092458926729985, 9843439728162203894, 4910876821339919711, 11743588247353110963, 16917990617748735295], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [67, 56, 221, 172, 183, 26, 231, 188, 189, 215, 247, 181, 112, 58, 232, 221, 188, 253, 63, 175, 15, 72, 182, 206, 231, 128, 239, 141, 249, 6, 198, 30])
  , u64s := []
  , cursorBefore := { stateWords := [2591982540180233, 40260904703498889, 162795612, 11106092458926729985, 9843439728162203894, 4910876821339919711, 11743588247353110963, 16917990617748735295], absorbed := 3 }
  , cursorAfter := { stateWords := [4414814025473512, 39951308640138824, 516294393, 17329624708618471016, 11674115816566501362, 14573575530215518718, 13139643552008840516, 17641270940026343217], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [4414814025473512, 39951308640138824, 516294393, 17329624708618471016, 11674115816566501362, 14573575530215518718, 13139643552008840516, 17641270940026343217], absorbed := 3 }
  , cursorAfter := { stateWords := [5710450369200423292, 5740143068072469614, 14894183229893626147, 9172001311057965075, 14492336027424921441, 885359618247772967, 13488484757209203575, 3843872230801825639], absorbed := 0 }
  , challengeOutput := (some 5710450369200423292)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [5710450369200423292, 5740143068072469614, 14894183229893626147, 9172001311057965075, 14492336027424921441, 885359618247772967, 13488484757209203575, 3843872230801825639], absorbed := 0 }
  , cursorAfter := { stateWords := [4225525998307615487, 11432035185072164917, 12583554745970507727, 13626737198406591408, 6094816200342946977, 10179070456341347142, 1214732117107862240, 4980023762376192327], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [255, 162, 77, 246, 129, 21, 164, 58, 53, 80, 254, 105, 110, 191, 166, 158, 207, 191, 64, 245, 94, 196, 161, 174, 176, 99, 160, 206, 72, 229, 27, 189]))
}]
}
  , kernel := {
  root0Digest := (bytes [160, 47, 136, 108, 204, 129, 79, 197, 229, 103, 193, 132, 46, 237, 116, 161, 76, 12, 119, 193, 191, 6, 227, 119, 236, 118, 88, 172, 48, 50, 35, 98])
  , stage1Digest := (bytes [64, 180, 146, 246, 139, 60, 76, 212, 49, 131, 207, 237, 101, 254, 127, 102, 212, 72, 236, 89, 205, 253, 188, 71, 14, 72, 168, 245, 217, 88, 55, 93])
  , stage2Digest := (bytes [52, 185, 8, 160, 143, 178, 154, 190, 101, 228, 204, 246, 221, 136, 74, 154, 136, 97, 99, 235, 127, 33, 115, 45, 30, 159, 243, 89, 15, 247, 157, 142])
  , stage3Digest := (bytes [84, 58, 119, 62, 227, 203, 157, 120, 91, 33, 164, 86, 114, 27, 21, 233, 168, 252, 76, 12, 100, 202, 132, 82, 6, 21, 143, 29, 61, 32, 51, 38])
  , executionDigest := (bytes [160, 227, 4, 85, 140, 249, 7, 83, 176, 183, 120, 10, 187, 25, 9, 75, 146, 246, 100, 53, 9, 137, 26, 48, 91, 20, 9, 143, 92, 16, 180, 9])
  , finalStateDigest := (bytes [67, 56, 221, 172, 183, 26, 231, 188, 189, 215, 247, 181, 112, 58, 232, 221, 188, 253, 63, 175, 15, 72, 182, 206, 231, 128, 239, 141, 249, 6, 198, 30])
  , stage1Mix := 3705222010059132808
  , stage2RegMix := 7940266179000280847
  , stage2RamMix := 4123130262336711476
  , stage3ContinuityMix := 13522001880879900227
  , kernelFinalMix := 5710450369200423292
  , transcriptFinalDigest := (bytes [255, 162, 77, 246, 129, 21, 164, 58, 53, 80, 254, 105, 110, 191, 166, 158, 207, 191, 64, 245, 94, 196, 161, 174, 176, 99, 160, 206, 72, 229, 27, 189])
  , finalPc := 56
  , finalRegisters := [0, 5, 3, 1, 4, 7, 11, 6, 2, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , finalMemory := []
  , halted := true
}
}

end Nightstream.Rv64IM.Generated.Cases.Case_native_logic_compare_chain_ecall
