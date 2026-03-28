import Nightstream.Rv64IM.Generated.ParityTypes

namespace Nightstream.Rv64IM.Generated.Cases.Case_native_shift_chain_ecall

open Nightstream.Rv64IM.Generated

def derivedCase : ParityDerivedCase :=
  {
  manifest := { name := "native_shift_chain_ecall", fixtureId := "native_shift_chain_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , executionRows := [{
  traceIndex := 0
  , stepIndex := 0
  , sequenceIndex := 0
  , pc := 0
  , nextPc := 4
  , word := 1048723
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
  , rdAfter := 1
  , imm := 1
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
  traceIndex := 1
  , stepIndex := 1
  , sequenceIndex := 0
  , pc := 4
  , nextPc := 8
  , word := 4231443
  , opcode := .slli
  , traceOpcode := (some .slli)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 1
  , rs2 := 0
  , rs2Value := 0
  , rd := 2
  , rdBefore := 0
  , rdAfter := 16
  , imm := 4
  , aluResult := 16
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
  , word := 4278190483
  , opcode := .addi
  , traceOpcode := (some .addi)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 0
  , rs1Value := 0
  , rs2 := 0
  , rs2Value := 0
  , rd := 3
  , rdBefore := 0
  , rdAfter := 18446744073709551600
  , imm := -16
  , aluResult := 18446744073709551600
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
  , word := 2183699
  , opcode := .srli
  , traceOpcode := (some .srli)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 2
  , rs1Value := 16
  , rs2 := 0
  , rs2Value := 0
  , rd := 4
  , rdBefore := 0
  , rdAfter := 4
  , imm := 2
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
  , word := 1075958419
  , opcode := .srai
  , traceOpcode := (some .srai)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 3
  , rs1Value := 18446744073709551600
  , rs2 := 0
  , rs2Value := 0
  , rd := 5
  , rdBefore := 0
  , rdAfter := 18446744073709551612
  , imm := 2
  , aluResult := 18446744073709551612
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
  , word := 3146515
  , opcode := .addi
  , traceOpcode := (some .addi)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 0
  , rs1Value := 0
  , rs2 := 0
  , rs2Value := 0
  , rd := 6
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
  traceIndex := 6
  , stepIndex := 6
  , sequenceIndex := 0
  , pc := 24
  , nextPc := 28
  , word := 6329267
  , opcode := .sll
  , traceOpcode := (some .sll)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 1
  , rs2 := 6
  , rs2Value := 3
  , rd := 7
  , rdBefore := 0
  , rdAfter := 8
  , imm := 0
  , aluResult := 8
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
  , word := 6378547
  , opcode := .srl
  , traceOpcode := (some .srl)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 2
  , rs1Value := 16
  , rs2 := 6
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
  , stepIndex := 8
  , sequenceIndex := 0
  , pc := 32
  , nextPc := 36
  , word := 1080153267
  , opcode := .sra
  , traceOpcode := (some .sra)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 3
  , rs1Value := 18446744073709551600
  , rs2 := 6
  , rs2Value := 3
  , rd := 9
  , rdBefore := 0
  , rdAfter := 18446744073709551614
  , imm := 0
  , aluResult := 18446744073709551614
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
  , stage1 := { rows := [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 1048723, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 4, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 1, rdAfter := 1, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 4231443, opcode := .slli, traceOpcode := (some .slli), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 8, aluResult := 16, effectiveAddr := none, writesRd := true, rd := 2, rdAfter := 16, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 4278190483, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 12, aluResult := 18446744073709551600, effectiveAddr := none, writesRd := true, rd := 3, rdAfter := 18446744073709551600, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 12, fetchedWord := 2183699, opcode := .srli, traceOpcode := (some .srli), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 16, aluResult := 4, effectiveAddr := none, writesRd := true, rd := 4, rdAfter := 4, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 4, stepIndex := 4, sequenceIndex := 0, fetchPc := 16, fetchedWord := 1075958419, opcode := .srai, traceOpcode := (some .srai), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 20, aluResult := 18446744073709551612, effectiveAddr := none, writesRd := true, rd := 5, rdAfter := 18446744073709551612, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 5, stepIndex := 5, sequenceIndex := 0, fetchPc := 20, fetchedWord := 3146515, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 24, aluResult := 3, effectiveAddr := none, writesRd := true, rd := 6, rdAfter := 3, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 6, stepIndex := 6, sequenceIndex := 0, fetchPc := 24, fetchedWord := 6329267, opcode := .sll, traceOpcode := (some .sll), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 28, aluResult := 8, effectiveAddr := none, writesRd := true, rd := 7, rdAfter := 8, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 7, stepIndex := 7, sequenceIndex := 0, fetchPc := 28, fetchedWord := 6378547, opcode := .srl, traceOpcode := (some .srl), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 32, aluResult := 2, effectiveAddr := none, writesRd := true, rd := 8, rdAfter := 2, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 8, stepIndex := 8, sequenceIndex := 0, fetchPc := 32, fetchedWord := 1080153267, opcode := .sra, traceOpcode := (some .sra), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 36, aluResult := 18446744073709551614, effectiveAddr := none, writesRd := true, rd := 9, rdAfter := 18446744073709551614, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 9, stepIndex := 9, sequenceIndex := 0, fetchPc := 36, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 40, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }] }
  , stage2 := {
  registerReads := [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 0, value := 0 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 1, value := 1 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 0, value := 0 }, { traceIndex := 3, stepIndex := 3, role := .rs1, reg := 2, value := 16 }, { traceIndex := 4, stepIndex := 4, role := .rs1, reg := 3, value := 18446744073709551600 }, { traceIndex := 5, stepIndex := 5, role := .rs1, reg := 0, value := 0 }, { traceIndex := 6, stepIndex := 6, role := .rs1, reg := 1, value := 1 }, { traceIndex := 6, stepIndex := 6, role := .rs2, reg := 6, value := 3 }, { traceIndex := 7, stepIndex := 7, role := .rs1, reg := 2, value := 16 }, { traceIndex := 7, stepIndex := 7, role := .rs2, reg := 6, value := 3 }, { traceIndex := 8, stepIndex := 8, role := .rs1, reg := 3, value := 18446744073709551600 }, { traceIndex := 8, stepIndex := 8, role := .rs2, reg := 6, value := 3 }]
  , registerWrites := [{ traceIndex := 0, stepIndex := 0, reg := 1, previous := 0, next := 1 }, { traceIndex := 1, stepIndex := 1, reg := 2, previous := 0, next := 16 }, { traceIndex := 2, stepIndex := 2, reg := 3, previous := 0, next := 18446744073709551600 }, { traceIndex := 3, stepIndex := 3, reg := 4, previous := 0, next := 4 }, { traceIndex := 4, stepIndex := 4, reg := 5, previous := 0, next := 18446744073709551612 }, { traceIndex := 5, stepIndex := 5, reg := 6, previous := 0, next := 3 }, { traceIndex := 6, stepIndex := 6, reg := 7, previous := 0, next := 8 }, { traceIndex := 7, stepIndex := 7, reg := 8, previous := 0, next := 2 }, { traceIndex := 8, stepIndex := 8, reg := 9, previous := 0, next := 18446744073709551614 }]
  , ramEvents := []
  , twistLinks := [{ traceIndex := 0, stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 1, family := .nativeAlu, routedWriteValue := (some 16), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 2, family := .nativeAlu, routedWriteValue := (some 18446744073709551600), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 3, family := .nativeAlu, routedWriteValue := (some 4), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 4, stepIndex := 4, family := .nativeAlu, routedWriteValue := (some 18446744073709551612), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 5, stepIndex := 5, family := .nativeAlu, routedWriteValue := (some 3), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 6, stepIndex := 6, family := .nativeAlu, routedWriteValue := (some 8), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 7, stepIndex := 7, family := .nativeAlu, routedWriteValue := (some 2), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 8, stepIndex := 8, family := .nativeAlu, routedWriteValue := (some 18446744073709551614), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 9, stepIndex := 9, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]
}
  , stage3 := {
  continuity := [{ stepIndex := 0, pc := 0, nextPc := 4, successorPc := (some 4), finalStep := false, continuityHolds := true }, { stepIndex := 1, pc := 4, nextPc := 8, successorPc := (some 8), finalStep := false, continuityHolds := true }, { stepIndex := 2, pc := 8, nextPc := 12, successorPc := (some 12), finalStep := false, continuityHolds := true }, { stepIndex := 3, pc := 12, nextPc := 16, successorPc := (some 16), finalStep := false, continuityHolds := true }, { stepIndex := 4, pc := 16, nextPc := 20, successorPc := (some 20), finalStep := false, continuityHolds := true }, { stepIndex := 5, pc := 20, nextPc := 24, successorPc := (some 24), finalStep := false, continuityHolds := true }, { stepIndex := 6, pc := 24, nextPc := 28, successorPc := (some 28), finalStep := false, continuityHolds := true }, { stepIndex := 7, pc := 28, nextPc := 32, successorPc := (some 32), finalStep := false, continuityHolds := true }, { stepIndex := 8, pc := 32, nextPc := 36, successorPc := (some 36), finalStep := false, continuityHolds := true }, { stepIndex := 9, pc := 36, nextPc := 40, successorPc := none, finalStep := true, continuityHolds := true }]
  , halted := true
}
  , transcript := {
  appLabel := (bytes [110, 101, 111, 46, 102, 111, 108, 100, 46, 110, 101, 120, 116, 47, 114, 118, 54, 52, 105, 109, 47, 112, 97, 114, 105, 116, 121, 95, 107, 101, 114, 110, 101, 108, 95, 118, 49])
  , events := [{
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 116, 114, 97, 110, 115, 99, 114, 105, 112, 116, 95, 115, 101, 101, 100])
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 110, 97, 116, 105, 118, 101, 45, 115, 104, 105, 102, 116, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [33264025209497715, 49, 3390619080185759186, 12096819762988914126, 4001610679670701799, 5432763535062103318, 13415967828788768464, 15663373744946530692], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [110, 97, 116, 105, 118, 101, 95, 115, 104, 105, 102, 116, 95, 99, 104, 97, 105, 110, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [33264025209497715, 49, 3390619080185759186, 12096819762988914126, 4001610679670701799, 5432763535062103318, 13415967828788768464, 15663373744946530692], absorbed := 2 }
  , cursorAfter := { stateWords := [9343583599440594713, 10983263396399423942, 10213758535099150043, 17999485627249729703, 8213066104219617703, 12273497441021069772, 14876407735256743716, 15476744526804179329], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [1048723, 4231443, 4278190483, 2183699, 1075958419, 3146515, 6329267, 6378547, 1080153267, 115]
  , cursorBefore := { stateWords := [9343583599440594713, 10983263396399423942, 10213758535099150043, 17999485627249729703, 8213066104219617703, 12273497441021069772, 14876407735256743716, 15476744526804179329], absorbed := 0 }
  , cursorAfter := { stateWords := [115, 0, 12132189991474095693, 5724097830014706505, 4009596014858473286, 5995263417795965784, 408868401535594138, 17006945087715718041], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [115, 0, 12132189991474095693, 5724097830014706505, 4009596014858473286, 5995263417795965784, 408868401535594138, 17006945087715718041], absorbed := 2 }
  , cursorAfter := { stateWords := [3528834191574932829, 6155173375791115620, 13609196687032797688, 11002803251645454761, 12206787759704429923, 16410673065852401615, 2598699549887548923, 12066494163384387956], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [3528834191574932829, 6155173375791115620, 13609196687032797688, 11002803251645454761, 12206787759704429923, 16410673065852401615, 2598699549887548923, 12066494163384387956], absorbed := 0 }
  , cursorAfter := { stateWords := [34184295084289375, 0, 3573761302448998257, 4094924913629440852, 4449727207908542588, 7274712621141095245, 10189188638743606548, 8854558257557134109], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [100, 141, 133, 191, 65, 9, 202, 67, 178, 73, 161, 90, 192, 177, 16, 176, 7, 146, 125, 14, 199, 63, 180, 56, 245, 33, 2, 6, 126, 240, 189, 23])
  , u64s := []
  , cursorBefore := { stateWords := [34184295084289375, 0, 3573761302448998257, 4094924913629440852, 4449727207908542588, 7274712621141095245, 10189188638743606548, 8854558257557134109], absorbed := 2 }
  , cursorAfter := { stateWords := [398323838, 13563848412886993082, 5367215074576215338, 5585458906983765709, 8449989835503769803, 11906319393298175280, 17849796046869045789, 15345541679146046444], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [398323838, 13563848412886993082, 5367215074576215338, 5585458906983765709, 8449989835503769803, 11906319393298175280, 17849796046869045789, 15345541679146046444], absorbed := 1 }
  , cursorAfter := { stateWords := [16691009948854132645, 8590394677687983344, 6791025823853643633, 8055613139477747472, 2334784384309520970, 8120023813436867814, 12534626429442971049, 10949312597069331114], absorbed := 0 }
  , challengeOutput := (some 16691009948854132645)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [134, 144, 193, 223, 148, 183, 65, 251, 150, 253, 209, 238, 38, 219, 86, 43, 84, 158, 62, 219, 12, 185, 17, 172, 250, 121, 161, 155, 34, 218, 192, 23])
  , u64s := []
  , cursorBefore := { stateWords := [16691009948854132645, 8590394677687983344, 6791025823853643633, 8055613139477747472, 2334784384309520970, 8120023813436867814, 12534626429442971049, 10949312597069331114], absorbed := 0 }
  , cursorAfter := { stateWords := [3618761711299414, 43806166658847161, 398514722, 7027272740655351469, 4546986030328210763, 14841835654066153876, 15041005742323689594, 17480490590060115057], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [3618761711299414, 43806166658847161, 398514722, 7027272740655351469, 4546986030328210763, 14841835654066153876, 15041005742323689594, 17480490590060115057], absorbed := 3 }
  , cursorAfter := { stateWords := [4919044041631935056, 14189116834329926604, 12419105555469757780, 14270356555172948800, 8093844472540501353, 9124786461151767659, 7152703984857230834, 13210800323996142899], absorbed := 0 }
  , challengeOutput := (some 4919044041631935056)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [4919044041631935056, 14189116834329926604, 12419105555469757780, 14270356555172948800, 8093844472540501353, 9124786461151767659, 7152703984857230834, 13210800323996142899], absorbed := 0 }
  , cursorAfter := { stateWords := [16264464362193895577, 11461908290415474824, 11397215704295747164, 9824510442467619620, 18290234949193389834, 5594432991877263909, 9081794983633899672, 10912585245568592430], absorbed := 0 }
  , challengeOutput := (some 16264464362193895577)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [157, 229, 195, 131, 139, 8, 105, 108, 185, 165, 44, 241, 226, 186, 221, 169, 117, 119, 57, 226, 94, 130, 90, 239, 124, 28, 101, 251, 70, 102, 122, 148])
  , u64s := []
  , cursorBefore := { stateWords := [16264464362193895577, 11461908290415474824, 11397215704295747164, 9824510442467619620, 18290234949193389834, 5594432991877263909, 9081794983633899672, 10912585245568592430], absorbed := 0 }
  , cursorAfter := { stateWords := [26707384256014813, 70761392183925378, 2491049542, 9507906175547332923, 3730582484654031885, 16876102647749534996, 12581855173648909236, 16514804110931742469], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [26707384256014813, 70761392183925378, 2491049542, 9507906175547332923, 3730582484654031885, 16876102647749534996, 12581855173648909236, 16514804110931742469], absorbed := 3 }
  , cursorAfter := { stateWords := [9654341997663817196, 5004801482934633826, 15589065540793569337, 16974695238686938950, 705696601170899424, 17826056565796222072, 17185746199196365289, 17250980329634985717], absorbed := 0 }
  , challengeOutput := (some 9654341997663817196)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [234, 177, 23, 67, 38, 251, 33, 157, 164, 66, 116, 34, 106, 3, 185, 174, 39, 193, 22, 250, 158, 150, 184, 2, 134, 157, 45, 214, 185, 100, 216, 30])
  , u64s := []
  , cursorBefore := { stateWords := [9654341997663817196, 5004801482934633826, 15589065540793569337, 16974695238686938950, 705696601170899424, 17826056565796222072, 17185746199196365289, 17250980329634985717], absorbed := 0 }
  , cursorAfter := { stateWords := [44748021957111481, 60285799597521046, 517498041, 13646145847636500251, 11517170574194729242, 3460917812286701909, 4557134827179065529, 17390159929072289930], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [125, 109, 107, 30, 214, 28, 21, 190, 193, 73, 13, 134, 113, 2, 233, 252, 206, 60, 180, 47, 71, 229, 88, 95, 116, 143, 172, 12, 59, 79, 234, 150])
  , u64s := []
  , cursorBefore := { stateWords := [44748021957111481, 60285799597521046, 517498041, 13646145847636500251, 11517170574194729242, 3460917812286701909, 4557134827179065529, 17390159929072289930], absorbed := 3 }
  , cursorAfter := { stateWords := [20037174507273449, 3567431853234405, 2531938107, 1325518863947626039, 8964014674430181503, 15342147114171615346, 13426727881498678871, 139830257145797863], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [103, 223, 139, 208, 116, 154, 142, 132, 78, 184, 137, 1, 105, 240, 117, 173, 130, 69, 168, 181, 198, 4, 200, 40, 154, 26, 30, 84, 163, 49, 80, 141])
  , u64s := []
  , cursorBefore := { stateWords := [20037174507273449, 3567431853234405, 2531938107, 1325518863947626039, 8964014674430181503, 15342147114171615346, 13426727881498678871, 139830257145797863], absorbed := 3 }
  , cursorAfter := { stateWords := [55931779714035061, 23676997648041988, 2370843043, 7093541884208153986, 7915818848580902698, 3476745757337338623, 13097431133370823525, 1567520043707639019], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [55931779714035061, 23676997648041988, 2370843043, 7093541884208153986, 7915818848580902698, 3476745757337338623, 13097431133370823525, 1567520043707639019], absorbed := 3 }
  , cursorAfter := { stateWords := [10261008020113467646, 10108384727196382461, 17846612664083407406, 14694403235617166691, 13277652733314478642, 5223581477044193931, 5580092013888805740, 758801733075114328], absorbed := 0 }
  , challengeOutput := (some 10261008020113467646)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [10261008020113467646, 10108384727196382461, 17846612664083407406, 14694403235617166691, 13277652733314478642, 5223581477044193931, 5580092013888805740, 758801733075114328], absorbed := 0 }
  , cursorAfter := { stateWords := [3205736139421500968, 6264205145986039101, 6276952383388259870, 13659633549707134190, 7916290875057399432, 528344911851888055, 206090245114880306, 7344352859528851009], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [40, 198, 217, 185, 8, 16, 125, 44, 61, 253, 171, 30, 100, 237, 238, 86, 30, 22, 230, 155, 239, 54, 28, 87, 238, 68, 77, 116, 87, 196, 144, 189]))
}]
}
  , kernel := {
  root0Digest := (bytes [100, 141, 133, 191, 65, 9, 202, 67, 178, 73, 161, 90, 192, 177, 16, 176, 7, 146, 125, 14, 199, 63, 180, 56, 245, 33, 2, 6, 126, 240, 189, 23])
  , stage1Digest := (bytes [134, 144, 193, 223, 148, 183, 65, 251, 150, 253, 209, 238, 38, 219, 86, 43, 84, 158, 62, 219, 12, 185, 17, 172, 250, 121, 161, 155, 34, 218, 192, 23])
  , stage2Digest := (bytes [157, 229, 195, 131, 139, 8, 105, 108, 185, 165, 44, 241, 226, 186, 221, 169, 117, 119, 57, 226, 94, 130, 90, 239, 124, 28, 101, 251, 70, 102, 122, 148])
  , stage3Digest := (bytes [234, 177, 23, 67, 38, 251, 33, 157, 164, 66, 116, 34, 106, 3, 185, 174, 39, 193, 22, 250, 158, 150, 184, 2, 134, 157, 45, 214, 185, 100, 216, 30])
  , executionDigest := (bytes [125, 109, 107, 30, 214, 28, 21, 190, 193, 73, 13, 134, 113, 2, 233, 252, 206, 60, 180, 47, 71, 229, 88, 95, 116, 143, 172, 12, 59, 79, 234, 150])
  , finalStateDigest := (bytes [103, 223, 139, 208, 116, 154, 142, 132, 78, 184, 137, 1, 105, 240, 117, 173, 130, 69, 168, 181, 198, 4, 200, 40, 154, 26, 30, 84, 163, 49, 80, 141])
  , stage1Mix := 16691009948854132645
  , stage2RegMix := 4919044041631935056
  , stage2RamMix := 16264464362193895577
  , stage3ContinuityMix := 9654341997663817196
  , kernelFinalMix := 10261008020113467646
  , transcriptFinalDigest := (bytes [40, 198, 217, 185, 8, 16, 125, 44, 61, 253, 171, 30, 100, 237, 238, 86, 30, 22, 230, 155, 239, 54, 28, 87, 238, 68, 77, 116, 87, 196, 144, 189])
  , finalPc := 40
  , finalRegisters := [0, 1, 16, 18446744073709551600, 4, 18446744073709551612, 3, 8, 2, 18446744073709551614, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , finalMemory := []
  , halted := true
}
}

end Nightstream.Rv64IM.Generated.Cases.Case_native_shift_chain_ecall
