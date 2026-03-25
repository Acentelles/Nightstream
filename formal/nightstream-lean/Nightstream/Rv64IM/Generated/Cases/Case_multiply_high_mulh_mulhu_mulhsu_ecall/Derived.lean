import Nightstream.Rv64IM.Generated.ParityTypes

namespace Nightstream.Rv64IM.Generated.Cases.Case_multiply_high_mulh_mulhu_mulhsu_ecall

open Nightstream.Rv64IM.Generated

def derivedCase : ParityDerivedCase :=
  {
  manifest := { name := "multiply_high_mulh_mulhu_mulhsu_ecall", fixtureId := "multiply_high_mulh_mulhu_mulhsu_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.multiply, .controlFlow] }
  , executionRows := [{
  traceIndex := 0
  , stepIndex := 0
  , sequenceIndex := 0
  , pc := 0
  , nextPc := 0
  , word := 35689395
  , opcode := .mulh
  , traceOpcode := none
  , traceVirtualOpcode := (some .movsign)
  , family := .multiply
  , rs1 := 1
  , rs1Value := 18446744073709551614
  , rs2 := 0
  , rs2Value := 0
  , rd := 40
  , rdBefore := 0
  , rdAfter := 18446744073709551615
  , imm := 0
  , aluResult := 18446744073709551615
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := true
  , virtualSequenceRemaining := (some 6)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 1
  , stepIndex := 0
  , sequenceIndex := 1
  , pc := 0
  , nextPc := 0
  , word := 35689395
  , opcode := .mulh
  , traceOpcode := none
  , traceVirtualOpcode := (some .movsign)
  , family := .multiply
  , rs1 := 2
  , rs1Value := 18446744073709551613
  , rs2 := 0
  , rs2Value := 0
  , rd := 41
  , rdBefore := 0
  , rdAfter := 18446744073709551615
  , imm := 0
  , aluResult := 18446744073709551615
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 5)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 2
  , stepIndex := 0
  , sequenceIndex := 2
  , pc := 0
  , nextPc := 0
  , word := 35689395
  , opcode := .mulh
  , traceOpcode := (some .mul)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 40
  , rs1Value := 18446744073709551615
  , rs2 := 2
  , rs2Value := 18446744073709551613
  , rd := 40
  , rdBefore := 18446744073709551615
  , rdAfter := 3
  , imm := 0
  , aluResult := 3
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 4)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 3
  , stepIndex := 0
  , sequenceIndex := 3
  , pc := 0
  , nextPc := 0
  , word := 35689395
  , opcode := .mulh
  , traceOpcode := (some .mul)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 41
  , rs1Value := 18446744073709551615
  , rs2 := 1
  , rs2Value := 18446744073709551614
  , rd := 41
  , rdBefore := 18446744073709551615
  , rdAfter := 2
  , imm := 0
  , aluResult := 2
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 3)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 4
  , stepIndex := 0
  , sequenceIndex := 4
  , pc := 0
  , nextPc := 0
  , word := 35689395
  , opcode := .mulh
  , traceOpcode := (some .mulhu)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 1
  , rs1Value := 18446744073709551614
  , rs2 := 2
  , rs2Value := 18446744073709551613
  , rd := 42
  , rdBefore := 0
  , rdAfter := 18446744073709551611
  , imm := 0
  , aluResult := 18446744073709551611
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 2)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 5
  , stepIndex := 0
  , sequenceIndex := 5
  , pc := 0
  , nextPc := 0
  , word := 35689395
  , opcode := .mulh
  , traceOpcode := (some .add)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 42
  , rs1Value := 18446744073709551611
  , rs2 := 40
  , rs2Value := 3
  , rd := 42
  , rdBefore := 18446744073709551611
  , rdAfter := 18446744073709551614
  , imm := 0
  , aluResult := 18446744073709551614
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 1)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 6
  , stepIndex := 0
  , sequenceIndex := 6
  , pc := 0
  , nextPc := 4
  , word := 35689395
  , opcode := .mulh
  , traceOpcode := (some .add)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 42
  , rs1Value := 18446744073709551614
  , rs2 := 41
  , rs2Value := 2
  , rd := 7
  , rdBefore := 0
  , rdAfter := 0
  , imm := 0
  , aluResult := 0
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 0)
  , isEffectRow := true
  , isCommitRow := true
  , isReal := true
}, {
  traceIndex := 7
  , stepIndex := 1
  , sequenceIndex := 0
  , pc := 4
  , nextPc := 8
  , word := 37860403
  , opcode := .mulhu
  , traceOpcode := (some .mulhu)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 3
  , rs1Value := 18446744073709551614
  , rs2 := 4
  , rs2Value := 3
  , rd := 8
  , rdBefore := 0
  , rdAfter := 2
  , imm := 0
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
  , stepIndex := 2
  , sequenceIndex := 0
  , pc := 8
  , nextPc := 8
  , word := 40019123
  , opcode := .mulhsu
  , traceOpcode := none
  , traceVirtualOpcode := (some .movsign)
  , family := .multiply
  , rs1 := 5
  , rs1Value := 18446744073709551614
  , rs2 := 0
  , rs2Value := 0
  , rd := 40
  , rdBefore := 0
  , rdAfter := 18446744073709551615
  , imm := 0
  , aluResult := 18446744073709551615
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := true
  , virtualSequenceRemaining := (some 10)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 9
  , stepIndex := 2
  , sequenceIndex := 1
  , pc := 8
  , nextPc := 8
  , word := 40019123
  , opcode := .mulhsu
  , traceOpcode := (some .andi)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 40
  , rs1Value := 18446744073709551615
  , rs2 := 0
  , rs2Value := 0
  , rd := 41
  , rdBefore := 0
  , rdAfter := 1
  , imm := 1
  , aluResult := 1
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 9)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 10
  , stepIndex := 2
  , sequenceIndex := 2
  , pc := 8
  , nextPc := 8
  , word := 40019123
  , opcode := .mulhsu
  , traceOpcode := (some .xor)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 5
  , rs1Value := 18446744073709551614
  , rs2 := 40
  , rs2Value := 18446744073709551615
  , rd := 42
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
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 8)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 11
  , stepIndex := 2
  , sequenceIndex := 3
  , pc := 8
  , nextPc := 8
  , word := 40019123
  , opcode := .mulhsu
  , traceOpcode := (some .add)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 42
  , rs1Value := 1
  , rs2 := 41
  , rs2Value := 1
  , rd := 42
  , rdBefore := 1
  , rdAfter := 2
  , imm := 0
  , aluResult := 2
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 7)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 12
  , stepIndex := 2
  , sequenceIndex := 4
  , pc := 8
  , nextPc := 8
  , word := 40019123
  , opcode := .mulhsu
  , traceOpcode := (some .mulhu)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 42
  , rs1Value := 2
  , rs2 := 6
  , rs2Value := 3
  , rd := 43
  , rdBefore := 0
  , rdAfter := 0
  , imm := 0
  , aluResult := 0
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 6)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 13
  , stepIndex := 2
  , sequenceIndex := 5
  , pc := 8
  , nextPc := 8
  , word := 40019123
  , opcode := .mulhsu
  , traceOpcode := (some .mul)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 42
  , rs1Value := 2
  , rs2 := 6
  , rs2Value := 3
  , rd := 42
  , rdBefore := 2
  , rdAfter := 6
  , imm := 0
  , aluResult := 6
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 5)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 14
  , stepIndex := 2
  , sequenceIndex := 6
  , pc := 8
  , nextPc := 8
  , word := 40019123
  , opcode := .mulhsu
  , traceOpcode := (some .xor)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 43
  , rs1Value := 0
  , rs2 := 40
  , rs2Value := 18446744073709551615
  , rd := 43
  , rdBefore := 0
  , rdAfter := 18446744073709551615
  , imm := 0
  , aluResult := 18446744073709551615
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 4)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 15
  , stepIndex := 2
  , sequenceIndex := 7
  , pc := 8
  , nextPc := 8
  , word := 40019123
  , opcode := .mulhsu
  , traceOpcode := (some .xor)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 42
  , rs1Value := 6
  , rs2 := 40
  , rs2Value := 18446744073709551615
  , rd := 42
  , rdBefore := 6
  , rdAfter := 18446744073709551609
  , imm := 0
  , aluResult := 18446744073709551609
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 3)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 16
  , stepIndex := 2
  , sequenceIndex := 8
  , pc := 8
  , nextPc := 8
  , word := 40019123
  , opcode := .mulhsu
  , traceOpcode := (some .add)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 42
  , rs1Value := 18446744073709551609
  , rs2 := 41
  , rs2Value := 1
  , rd := 40
  , rdBefore := 18446744073709551615
  , rdAfter := 18446744073709551610
  , imm := 0
  , aluResult := 18446744073709551610
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 2)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 17
  , stepIndex := 2
  , sequenceIndex := 9
  , pc := 8
  , nextPc := 8
  , word := 40019123
  , opcode := .mulhsu
  , traceOpcode := (some .sltu)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 40
  , rs1Value := 18446744073709551610
  , rs2 := 42
  , rs2Value := 18446744073709551609
  , rd := 40
  , rdBefore := 18446744073709551610
  , rdAfter := 0
  , imm := 0
  , aluResult := 0
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 1)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 18
  , stepIndex := 2
  , sequenceIndex := 10
  , pc := 8
  , nextPc := 12
  , word := 40019123
  , opcode := .mulhsu
  , traceOpcode := (some .add)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 43
  , rs1Value := 18446744073709551615
  , rs2 := 40
  , rs2Value := 0
  , rd := 9
  , rdBefore := 0
  , rdAfter := 18446744073709551615
  , imm := 0
  , aluResult := 18446744073709551615
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 0)
  , isEffectRow := true
  , isCommitRow := true
  , isReal := true
}, {
  traceIndex := 19
  , stepIndex := 3
  , sequenceIndex := 0
  , pc := 12
  , nextPc := 16
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
  , stage1 := { rows := [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 35689395, opcode := .mulh, traceOpcode := none, traceVirtualOpcode := (some .movsign), family := .multiply, nextPc := 0, aluResult := 18446744073709551615, effectiveAddr := none, writesRd := true, rd := 40, rdAfter := 18446744073709551615, isFirstInSequence := true, virtualSequenceRemaining := (some 6), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 1, stepIndex := 0, sequenceIndex := 1, fetchPc := 0, fetchedWord := 35689395, opcode := .mulh, traceOpcode := none, traceVirtualOpcode := (some .movsign), family := .multiply, nextPc := 0, aluResult := 18446744073709551615, effectiveAddr := none, writesRd := true, rd := 41, rdAfter := 18446744073709551615, isFirstInSequence := false, virtualSequenceRemaining := (some 5), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 2, stepIndex := 0, sequenceIndex := 2, fetchPc := 0, fetchedWord := 35689395, opcode := .mulh, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .multiply, nextPc := 0, aluResult := 3, effectiveAddr := none, writesRd := true, rd := 40, rdAfter := 3, isFirstInSequence := false, virtualSequenceRemaining := (some 4), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 3, stepIndex := 0, sequenceIndex := 3, fetchPc := 0, fetchedWord := 35689395, opcode := .mulh, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .multiply, nextPc := 0, aluResult := 2, effectiveAddr := none, writesRd := true, rd := 41, rdAfter := 2, isFirstInSequence := false, virtualSequenceRemaining := (some 3), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 4, stepIndex := 0, sequenceIndex := 4, fetchPc := 0, fetchedWord := 35689395, opcode := .mulh, traceOpcode := (some .mulhu), traceVirtualOpcode := none, family := .multiply, nextPc := 0, aluResult := 18446744073709551611, effectiveAddr := none, writesRd := true, rd := 42, rdAfter := 18446744073709551611, isFirstInSequence := false, virtualSequenceRemaining := (some 2), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 5, stepIndex := 0, sequenceIndex := 5, fetchPc := 0, fetchedWord := 35689395, opcode := .mulh, traceOpcode := (some .add), traceVirtualOpcode := none, family := .multiply, nextPc := 0, aluResult := 18446744073709551614, effectiveAddr := none, writesRd := true, rd := 42, rdAfter := 18446744073709551614, isFirstInSequence := false, virtualSequenceRemaining := (some 1), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 6, stepIndex := 0, sequenceIndex := 6, fetchPc := 0, fetchedWord := 35689395, opcode := .mulh, traceOpcode := (some .add), traceVirtualOpcode := none, family := .multiply, nextPc := 4, aluResult := 0, effectiveAddr := none, writesRd := true, rd := 7, rdAfter := 0, isFirstInSequence := false, virtualSequenceRemaining := (some 0), isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 7, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 37860403, opcode := .mulhu, traceOpcode := (some .mulhu), traceVirtualOpcode := none, family := .multiply, nextPc := 8, aluResult := 2, effectiveAddr := none, writesRd := true, rd := 8, rdAfter := 2, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 8, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 40019123, opcode := .mulhsu, traceOpcode := none, traceVirtualOpcode := (some .movsign), family := .multiply, nextPc := 8, aluResult := 18446744073709551615, effectiveAddr := none, writesRd := true, rd := 40, rdAfter := 18446744073709551615, isFirstInSequence := true, virtualSequenceRemaining := (some 10), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 9, stepIndex := 2, sequenceIndex := 1, fetchPc := 8, fetchedWord := 40019123, opcode := .mulhsu, traceOpcode := (some .andi), traceVirtualOpcode := none, family := .multiply, nextPc := 8, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 41, rdAfter := 1, isFirstInSequence := false, virtualSequenceRemaining := (some 9), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 10, stepIndex := 2, sequenceIndex := 2, fetchPc := 8, fetchedWord := 40019123, opcode := .mulhsu, traceOpcode := (some .xor), traceVirtualOpcode := none, family := .multiply, nextPc := 8, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 42, rdAfter := 1, isFirstInSequence := false, virtualSequenceRemaining := (some 8), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 11, stepIndex := 2, sequenceIndex := 3, fetchPc := 8, fetchedWord := 40019123, opcode := .mulhsu, traceOpcode := (some .add), traceVirtualOpcode := none, family := .multiply, nextPc := 8, aluResult := 2, effectiveAddr := none, writesRd := true, rd := 42, rdAfter := 2, isFirstInSequence := false, virtualSequenceRemaining := (some 7), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 12, stepIndex := 2, sequenceIndex := 4, fetchPc := 8, fetchedWord := 40019123, opcode := .mulhsu, traceOpcode := (some .mulhu), traceVirtualOpcode := none, family := .multiply, nextPc := 8, aluResult := 0, effectiveAddr := none, writesRd := true, rd := 43, rdAfter := 0, isFirstInSequence := false, virtualSequenceRemaining := (some 6), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 13, stepIndex := 2, sequenceIndex := 5, fetchPc := 8, fetchedWord := 40019123, opcode := .mulhsu, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .multiply, nextPc := 8, aluResult := 6, effectiveAddr := none, writesRd := true, rd := 42, rdAfter := 6, isFirstInSequence := false, virtualSequenceRemaining := (some 5), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 14, stepIndex := 2, sequenceIndex := 6, fetchPc := 8, fetchedWord := 40019123, opcode := .mulhsu, traceOpcode := (some .xor), traceVirtualOpcode := none, family := .multiply, nextPc := 8, aluResult := 18446744073709551615, effectiveAddr := none, writesRd := true, rd := 43, rdAfter := 18446744073709551615, isFirstInSequence := false, virtualSequenceRemaining := (some 4), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 15, stepIndex := 2, sequenceIndex := 7, fetchPc := 8, fetchedWord := 40019123, opcode := .mulhsu, traceOpcode := (some .xor), traceVirtualOpcode := none, family := .multiply, nextPc := 8, aluResult := 18446744073709551609, effectiveAddr := none, writesRd := true, rd := 42, rdAfter := 18446744073709551609, isFirstInSequence := false, virtualSequenceRemaining := (some 3), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 16, stepIndex := 2, sequenceIndex := 8, fetchPc := 8, fetchedWord := 40019123, opcode := .mulhsu, traceOpcode := (some .add), traceVirtualOpcode := none, family := .multiply, nextPc := 8, aluResult := 18446744073709551610, effectiveAddr := none, writesRd := true, rd := 40, rdAfter := 18446744073709551610, isFirstInSequence := false, virtualSequenceRemaining := (some 2), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 17, stepIndex := 2, sequenceIndex := 9, fetchPc := 8, fetchedWord := 40019123, opcode := .mulhsu, traceOpcode := (some .sltu), traceVirtualOpcode := none, family := .multiply, nextPc := 8, aluResult := 0, effectiveAddr := none, writesRd := true, rd := 40, rdAfter := 0, isFirstInSequence := false, virtualSequenceRemaining := (some 1), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 18, stepIndex := 2, sequenceIndex := 10, fetchPc := 8, fetchedWord := 40019123, opcode := .mulhsu, traceOpcode := (some .add), traceVirtualOpcode := none, family := .multiply, nextPc := 12, aluResult := 18446744073709551615, effectiveAddr := none, writesRd := true, rd := 9, rdAfter := 18446744073709551615, isFirstInSequence := false, virtualSequenceRemaining := (some 0), isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 19, stepIndex := 3, sequenceIndex := 0, fetchPc := 12, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 16, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }] }
  , stage2 := {
  registerReads := [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 1, value := 18446744073709551614 }, { traceIndex := 1, stepIndex := 0, role := .rs1, reg := 2, value := 18446744073709551613 }, { traceIndex := 2, stepIndex := 0, role := .rs1, reg := 40, value := 18446744073709551615 }, { traceIndex := 2, stepIndex := 0, role := .rs2, reg := 2, value := 18446744073709551613 }, { traceIndex := 3, stepIndex := 0, role := .rs1, reg := 41, value := 18446744073709551615 }, { traceIndex := 3, stepIndex := 0, role := .rs2, reg := 1, value := 18446744073709551614 }, { traceIndex := 4, stepIndex := 0, role := .rs1, reg := 1, value := 18446744073709551614 }, { traceIndex := 4, stepIndex := 0, role := .rs2, reg := 2, value := 18446744073709551613 }, { traceIndex := 5, stepIndex := 0, role := .rs1, reg := 42, value := 18446744073709551611 }, { traceIndex := 5, stepIndex := 0, role := .rs2, reg := 40, value := 3 }, { traceIndex := 6, stepIndex := 0, role := .rs1, reg := 42, value := 18446744073709551614 }, { traceIndex := 6, stepIndex := 0, role := .rs2, reg := 41, value := 2 }, { traceIndex := 7, stepIndex := 1, role := .rs1, reg := 3, value := 18446744073709551614 }, { traceIndex := 7, stepIndex := 1, role := .rs2, reg := 4, value := 3 }, { traceIndex := 8, stepIndex := 2, role := .rs1, reg := 5, value := 18446744073709551614 }, { traceIndex := 9, stepIndex := 2, role := .rs1, reg := 40, value := 18446744073709551615 }, { traceIndex := 10, stepIndex := 2, role := .rs1, reg := 5, value := 18446744073709551614 }, { traceIndex := 10, stepIndex := 2, role := .rs2, reg := 40, value := 18446744073709551615 }, { traceIndex := 11, stepIndex := 2, role := .rs1, reg := 42, value := 1 }, { traceIndex := 11, stepIndex := 2, role := .rs2, reg := 41, value := 1 }, { traceIndex := 12, stepIndex := 2, role := .rs1, reg := 42, value := 2 }, { traceIndex := 12, stepIndex := 2, role := .rs2, reg := 6, value := 3 }, { traceIndex := 13, stepIndex := 2, role := .rs1, reg := 42, value := 2 }, { traceIndex := 13, stepIndex := 2, role := .rs2, reg := 6, value := 3 }, { traceIndex := 14, stepIndex := 2, role := .rs1, reg := 43, value := 0 }, { traceIndex := 14, stepIndex := 2, role := .rs2, reg := 40, value := 18446744073709551615 }, { traceIndex := 15, stepIndex := 2, role := .rs1, reg := 42, value := 6 }, { traceIndex := 15, stepIndex := 2, role := .rs2, reg := 40, value := 18446744073709551615 }, { traceIndex := 16, stepIndex := 2, role := .rs1, reg := 42, value := 18446744073709551609 }, { traceIndex := 16, stepIndex := 2, role := .rs2, reg := 41, value := 1 }, { traceIndex := 17, stepIndex := 2, role := .rs1, reg := 40, value := 18446744073709551610 }, { traceIndex := 17, stepIndex := 2, role := .rs2, reg := 42, value := 18446744073709551609 }, { traceIndex := 18, stepIndex := 2, role := .rs1, reg := 43, value := 18446744073709551615 }, { traceIndex := 18, stepIndex := 2, role := .rs2, reg := 40, value := 0 }]
  , registerWrites := [{ traceIndex := 0, stepIndex := 0, reg := 40, previous := 0, next := 18446744073709551615 }, { traceIndex := 1, stepIndex := 0, reg := 41, previous := 0, next := 18446744073709551615 }, { traceIndex := 2, stepIndex := 0, reg := 40, previous := 18446744073709551615, next := 3 }, { traceIndex := 3, stepIndex := 0, reg := 41, previous := 18446744073709551615, next := 2 }, { traceIndex := 4, stepIndex := 0, reg := 42, previous := 0, next := 18446744073709551611 }, { traceIndex := 5, stepIndex := 0, reg := 42, previous := 18446744073709551611, next := 18446744073709551614 }, { traceIndex := 6, stepIndex := 0, reg := 7, previous := 0, next := 0 }, { traceIndex := 7, stepIndex := 1, reg := 8, previous := 0, next := 2 }, { traceIndex := 8, stepIndex := 2, reg := 40, previous := 0, next := 18446744073709551615 }, { traceIndex := 9, stepIndex := 2, reg := 41, previous := 0, next := 1 }, { traceIndex := 10, stepIndex := 2, reg := 42, previous := 0, next := 1 }, { traceIndex := 11, stepIndex := 2, reg := 42, previous := 1, next := 2 }, { traceIndex := 12, stepIndex := 2, reg := 43, previous := 0, next := 0 }, { traceIndex := 13, stepIndex := 2, reg := 42, previous := 2, next := 6 }, { traceIndex := 14, stepIndex := 2, reg := 43, previous := 0, next := 18446744073709551615 }, { traceIndex := 15, stepIndex := 2, reg := 42, previous := 6, next := 18446744073709551609 }, { traceIndex := 16, stepIndex := 2, reg := 40, previous := 18446744073709551615, next := 18446744073709551610 }, { traceIndex := 17, stepIndex := 2, reg := 40, previous := 18446744073709551610, next := 0 }, { traceIndex := 18, stepIndex := 2, reg := 9, previous := 0, next := 18446744073709551615 }]
  , ramEvents := []
  , twistLinks := [{ traceIndex := 0, stepIndex := 0, family := .multiply, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 0, family := .multiply, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 0, family := .multiply, routedWriteValue := (some 3), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 0, family := .multiply, routedWriteValue := (some 2), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 4, stepIndex := 0, family := .multiply, routedWriteValue := (some 18446744073709551611), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 5, stepIndex := 0, family := .multiply, routedWriteValue := (some 18446744073709551614), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 6, stepIndex := 0, family := .multiply, routedWriteValue := (some 0), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 7, stepIndex := 1, family := .multiply, routedWriteValue := (some 2), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 8, stepIndex := 2, family := .multiply, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 9, stepIndex := 2, family := .multiply, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 10, stepIndex := 2, family := .multiply, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 11, stepIndex := 2, family := .multiply, routedWriteValue := (some 2), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 12, stepIndex := 2, family := .multiply, routedWriteValue := (some 0), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 13, stepIndex := 2, family := .multiply, routedWriteValue := (some 6), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 14, stepIndex := 2, family := .multiply, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 15, stepIndex := 2, family := .multiply, routedWriteValue := (some 18446744073709551609), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 16, stepIndex := 2, family := .multiply, routedWriteValue := (some 18446744073709551610), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 17, stepIndex := 2, family := .multiply, routedWriteValue := (some 0), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 18, stepIndex := 2, family := .multiply, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 19, stepIndex := 3, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]
}
  , stage3 := {
  continuity := [{ stepIndex := 0, pc := 0, nextPc := 4, successorPc := (some 4), finalStep := false, continuityHolds := true }, { stepIndex := 1, pc := 4, nextPc := 8, successorPc := (some 8), finalStep := false, continuityHolds := true }, { stepIndex := 2, pc := 8, nextPc := 12, successorPc := (some 12), finalStep := false, continuityHolds := true }, { stepIndex := 3, pc := 12, nextPc := 16, successorPc := none, finalStep := true, continuityHolds := true }]
  , halted := true
}
  , transcript := {
  appLabel := (bytes [110, 101, 111, 46, 102, 111, 108, 100, 46, 110, 101, 120, 116, 47, 114, 118, 54, 52, 105, 109, 47, 112, 97, 114, 105, 116, 121, 95, 107, 101, 114, 110, 101, 108, 95, 118, 49])
  , events := [{
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 116, 114, 97, 110, 115, 99, 114, 105, 112, 116, 95, 115, 101, 101, 100])
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 109, 117, 108, 116, 105, 112, 108, 121, 45, 104, 105, 103, 104, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [12781167311334777, 12662, 12823906427971971140, 5458687368011659338, 248951889722183994, 6447366553477719410, 671691480699588116, 16458339740995496313], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [109, 117, 108, 116, 105, 112, 108, 121, 95, 104, 105, 103, 104, 95, 109, 117, 108, 104, 95, 109, 117, 108, 104, 117, 95, 109, 117, 108, 104, 115, 117, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [12781167311334777, 12662, 12823906427971971140, 5458687368011659338, 248951889722183994, 6447366553477719410, 671691480699588116, 16458339740995496313], absorbed := 2 }
  , cursorAfter := { stateWords := [27412359785313128, 27756, 2108779813393257755, 10371293853381360518, 16650352946910516604, 15704720784864639920, 634774211277878388, 2635468374773951633], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [35689395, 37860403, 40019123, 115]
  , cursorBefore := { stateWords := [27412359785313128, 27756, 2108779813393257755, 10371293853381360518, 16650352946910516604, 15704720784864639920, 634774211277878388, 2635468374773951633], absorbed := 2 }
  , cursorAfter := { stateWords := [8812575801016892909, 13040938893226428394, 9701684088077420472, 5819287778781878817, 17896264116935920441, 16593576036334108354, 18272699806094930130, 16560517447366102286], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 18446744073709551614, 18446744073709551613, 18446744073709551614, 3, 18446744073709551614, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [8812575801016892909, 13040938893226428394, 9701684088077420472, 5819287778781878817, 17896264116935920441, 16593576036334108354, 18272699806094930130, 16560517447366102286], absorbed := 0 }
  , cursorAfter := { stateWords := [0, 0, 16580090554124809443, 14270154524921358245, 4254892177879671707, 15516828335114826966, 1193383185617325903, 1696859638442303879], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [0, 0, 16580090554124809443, 14270154524921358245, 4254892177879671707, 15516828335114826966, 1193383185617325903, 1696859638442303879], absorbed := 2 }
  , cursorAfter := { stateWords := [13348506805888363, 30506403037277801, 34184295084289375, 0, 15284436219820320381, 4680745356388154385, 1520290972219069691, 3768744203301526206], absorbed := 4 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [243, 33, 113, 153, 9, 235, 68, 117, 29, 132, 237, 169, 175, 129, 160, 239, 59, 177, 90, 147, 52, 212, 120, 200, 192, 235, 87, 137, 127, 175, 131, 194])
  , u64s := []
  , cursorBefore := { stateWords := [13348506805888363, 30506403037277801, 34184295084289375, 0, 15284436219820320381, 4680745356388154385, 1520290972219069691, 3768744203301526206], absorbed := 4 }
  , cursorAfter := { stateWords := [14798716518789024, 38658741872654548, 3263410047, 16203063846249563458, 15952904281250505407, 11239127835845179134, 8682037629199545325, 12571069164232736769], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [14798716518789024, 38658741872654548, 3263410047, 16203063846249563458, 15952904281250505407, 11239127835845179134, 8682037629199545325, 12571069164232736769], absorbed := 3 }
  , cursorAfter := { stateWords := [12594224946114062434, 9120832401951012423, 15716666784263486997, 11771319206861947326, 14170695275895613368, 18155581864986460640, 8390403638239530622, 7721570034433765440], absorbed := 0 }
  , challengeOutput := (some 12594224946114062434)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [254, 135, 111, 142, 154, 116, 166, 185, 185, 222, 69, 53, 63, 69, 145, 188, 248, 151, 195, 191, 15, 203, 170, 159, 58, 111, 210, 59, 37, 159, 20, 59])
  , u64s := []
  , cursorBefore := { stateWords := [12594224946114062434, 9120832401951012423, 15716666784263486997, 11771319206861947326, 14170695275895613368, 18155581864986460640, 8390403638239530622, 7721570034433765440], absorbed := 0 }
  , cursorAfter := { stateWords := [4432971439848593, 16838398792673995, 991207205, 13523020166566597734, 9474816557060974975, 9682101722884499574, 11183025813400782569, 3504594574146367975], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [4432971439848593, 16838398792673995, 991207205, 13523020166566597734, 9474816557060974975, 9682101722884499574, 11183025813400782569, 3504594574146367975], absorbed := 3 }
  , cursorAfter := { stateWords := [7181907923970274102, 13984652350835454030, 14248157083981992134, 3489245716409723724, 11591148485536643942, 58840783525940945, 17639195001505837769, 4797479933805059576], absorbed := 0 }
  , challengeOutput := (some 7181907923970274102)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [7181907923970274102, 13984652350835454030, 14248157083981992134, 3489245716409723724, 11591148485536643942, 58840783525940945, 17639195001505837769, 4797479933805059576], absorbed := 0 }
  , cursorAfter := { stateWords := [4010680615921688272, 13559547375383272054, 12952106149071049557, 8601534984265556976, 9181871138784389685, 6401828817326474128, 2194921800358647068, 16636817962305181241], absorbed := 0 }
  , challengeOutput := (some 4010680615921688272)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [7, 82, 83, 13, 122, 202, 121, 111, 107, 12, 23, 144, 227, 48, 106, 126, 125, 114, 5, 27, 67, 29, 185, 192, 203, 20, 116, 55, 18, 178, 169, 18])
  , u64s := []
  , cursorBefore := { stateWords := [4010680615921688272, 13559547375383272054, 12952106149071049557, 8601534984265556976, 9181871138784389685, 6401828817326474128, 2194921800358647068, 16636817962305181241], absorbed := 0 }
  , cursorAfter := { stateWords := [18888533649227370, 15608756385659165, 313111058, 15518322506709063147, 2177833574961461427, 3085926819598395256, 10659100617218763088, 293927510401203621], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [18888533649227370, 15608756385659165, 313111058, 15518322506709063147, 2177833574961461427, 3085926819598395256, 10659100617218763088, 293927510401203621], absorbed := 3 }
  , cursorAfter := { stateWords := [16732273574652248418, 17216660654101797934, 8681142069474142655, 8589526100054592674, 12425421892153250114, 10855469906391529383, 15040391767145915989, 14904572834527225910], absorbed := 0 }
  , challengeOutput := (some 16732273574652248418)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [242, 180, 211, 44, 136, 191, 129, 103, 121, 27, 189, 177, 57, 84, 107, 37, 200, 205, 250, 244, 70, 251, 148, 129, 186, 236, 174, 139, 158, 109, 21, 76])
  , u64s := []
  , cursorBefore := { stateWords := [16732273574652248418, 17216660654101797934, 8681142069474142655, 8589526100054592674, 12425421892153250114, 10855469906391529383, 15040391767145915989, 14904572834527225910], absorbed := 0 }
  , cursorAfter := { stateWords := [19972606401193323, 39317353527350523, 1276472734, 230307616887654781, 12142287865684510284, 1060846835713975250, 903991690148070134, 15589771422270397194], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [253, 56, 202, 101, 142, 132, 93, 134, 75, 217, 118, 33, 12, 112, 138, 94, 76, 57, 89, 198, 120, 58, 231, 25, 226, 162, 224, 124, 164, 228, 241, 216])
  , u64s := []
  , cursorBefore := { stateWords := [19972606401193323, 39317353527350523, 1276472734, 230307616887654781, 12142287865684510284, 1060846835713975250, 903991690148070134, 15589771422270397194], absorbed := 3 }
  , cursorAfter := { stateWords := [33995083720973962, 35149887294793530, 3639731364, 11322723073178918445, 15677348921421630016, 3056688719395752326, 9239857230922062512, 8647286844324451561], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [64, 177, 68, 187, 81, 87, 252, 39, 65, 209, 64, 178, 63, 178, 69, 5, 247, 172, 14, 148, 78, 120, 110, 92, 118, 191, 130, 29, 111, 21, 65, 215])
  , u64s := []
  , cursorBefore := { stateWords := [33995083720973962, 35149887294793530, 3639731364, 11322723073178918445, 15677348921421630016, 3056688719395752326, 9239857230922062512, 8647286844324451561], absorbed := 3 }
  , cursorAfter := { stateWords := [22117838935754053, 8306533160742520, 3611366767, 15240032141194505930, 17094688214166531567, 3210725922644817130, 13724988163006776507, 17795306660117163208], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [22117838935754053, 8306533160742520, 3611366767, 15240032141194505930, 17094688214166531567, 3210725922644817130, 13724988163006776507, 17795306660117163208], absorbed := 3 }
  , cursorAfter := { stateWords := [6150446324893315326, 13940408834710205269, 3096927730202394539, 3312457634550628283, 18189760578090884427, 14404345729445534689, 2505855645016552390, 4862682994486841645], absorbed := 0 }
  , challengeOutput := (some 6150446324893315326)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [6150446324893315326, 13940408834710205269, 3096927730202394539, 3312457634550628283, 18189760578090884427, 14404345729445534689, 2505855645016552390, 4862682994486841645], absorbed := 0 }
  , cursorAfter := { stateWords := [12156655443619780216, 11474363165590510420, 8333141750803102578, 14298929851964528614, 10874228520263782992, 3844157008634569532, 7739098619381804857, 15111327435554719867], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [120, 150, 198, 157, 183, 29, 181, 168, 84, 91, 217, 92, 129, 32, 61, 159, 114, 123, 152, 127, 69, 68, 165, 115, 230, 23, 147, 254, 240, 0, 112, 198]))
}]
}
  , kernel := {
  root0Digest := (bytes [243, 33, 113, 153, 9, 235, 68, 117, 29, 132, 237, 169, 175, 129, 160, 239, 59, 177, 90, 147, 52, 212, 120, 200, 192, 235, 87, 137, 127, 175, 131, 194])
  , stage1Digest := (bytes [254, 135, 111, 142, 154, 116, 166, 185, 185, 222, 69, 53, 63, 69, 145, 188, 248, 151, 195, 191, 15, 203, 170, 159, 58, 111, 210, 59, 37, 159, 20, 59])
  , stage2Digest := (bytes [7, 82, 83, 13, 122, 202, 121, 111, 107, 12, 23, 144, 227, 48, 106, 126, 125, 114, 5, 27, 67, 29, 185, 192, 203, 20, 116, 55, 18, 178, 169, 18])
  , stage3Digest := (bytes [242, 180, 211, 44, 136, 191, 129, 103, 121, 27, 189, 177, 57, 84, 107, 37, 200, 205, 250, 244, 70, 251, 148, 129, 186, 236, 174, 139, 158, 109, 21, 76])
  , executionDigest := (bytes [253, 56, 202, 101, 142, 132, 93, 134, 75, 217, 118, 33, 12, 112, 138, 94, 76, 57, 89, 198, 120, 58, 231, 25, 226, 162, 224, 124, 164, 228, 241, 216])
  , finalStateDigest := (bytes [64, 177, 68, 187, 81, 87, 252, 39, 65, 209, 64, 178, 63, 178, 69, 5, 247, 172, 14, 148, 78, 120, 110, 92, 118, 191, 130, 29, 111, 21, 65, 215])
  , stage1Mix := 12594224946114062434
  , stage2RegMix := 7181907923970274102
  , stage2RamMix := 4010680615921688272
  , stage3ContinuityMix := 16732273574652248418
  , kernelFinalMix := 6150446324893315326
  , transcriptFinalDigest := (bytes [120, 150, 198, 157, 183, 29, 181, 168, 84, 91, 217, 92, 129, 32, 61, 159, 114, 123, 152, 127, 69, 68, 165, 115, 230, 23, 147, 254, 240, 0, 112, 198])
  , finalPc := 16
  , finalRegisters := [0, 18446744073709551614, 18446744073709551613, 18446744073709551614, 3, 18446744073709551614, 3, 0, 2, 18446744073709551615, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , finalMemory := []
  , halted := true
}
}

end Nightstream.Rv64IM.Generated.Cases.Case_multiply_high_mulh_mulhu_mulhsu_ecall
