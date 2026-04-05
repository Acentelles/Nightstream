import Nightstream.Rv64IM.Generated.ParityTypes

namespace Nightstream.Rv64IM.Generated.Cases.Case_narrow_memory_load_extract_extend_ecall

open Nightstream.Rv64IM.Generated

def derivedCase : ParityDerivedCase :=
  {
  manifest := { name := "narrow_memory_load_extract_extend_ecall", fixtureId := "narrow_memory_load_extract_extend_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.narrowMemory, .controlFlow] }
  , executionRows := [{
  traceIndex := 0
  , stepIndex := 0
  , sequenceIndex := 0
  , pc := 0
  , nextPc := 4
  , word := 327811
  , opcode := .lb
  , traceOpcode := (some .lb)
  , traceVirtualOpcode := none
  , family := .narrowMemory
  , rs1 := 10
  , rs1Value := 12288
  , rs2 := 0
  , rs2Value := 0
  , rd := 1
  , rdBefore := 0
  , rdAfter := 18446744073709551615
  , imm := 0
  , aluResult := 18446744073709551615
  , effectiveAddr := (some 12288)
  , memoryBefore := (some 9920249032750366975)
  , memoryAfter := (some 9920249032750366975)
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
  , word := 1392899
  , opcode := .lbu
  , traceOpcode := (some .lbu)
  , traceVirtualOpcode := none
  , family := .narrowMemory
  , rs1 := 10
  , rs1Value := 12288
  , rs2 := 0
  , rs2Value := 0
  , rd := 2
  , rdBefore := 0
  , rdAfter := 128
  , imm := 1
  , aluResult := 128
  , effectiveAddr := (some 12289)
  , memoryBefore := (some 9920249032750366975)
  , memoryAfter := (some 9920249032750366975)
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
  , word := 332163
  , opcode := .lh
  , traceOpcode := (some .lh)
  , traceVirtualOpcode := none
  , family := .narrowMemory
  , rs1 := 10
  , rs1Value := 12288
  , rs2 := 0
  , rs2Value := 0
  , rd := 3
  , rdBefore := 0
  , rdAfter := 18446744073709519103
  , imm := 0
  , aluResult := 18446744073709519103
  , effectiveAddr := (some 12288)
  , memoryBefore := (some 9920249032750366975)
  , memoryAfter := (some 9920249032750366975)
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
  , word := 2445827
  , opcode := .lhu
  , traceOpcode := (some .lhu)
  , traceVirtualOpcode := none
  , family := .narrowMemory
  , rs1 := 10
  , rs1Value := 12288
  , rs2 := 0
  , rs2Value := 0
  , rd := 4
  , rdBefore := 0
  , rdAfter := 32895
  , imm := 2
  , aluResult := 32895
  , effectiveAddr := (some 12290)
  , memoryBefore := (some 9920249032750366975)
  , memoryAfter := (some 9920249032750366975)
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
  , word := 336515
  , opcode := .lw
  , traceOpcode := (some .lw)
  , traceVirtualOpcode := none
  , family := .narrowMemory
  , rs1 := 10
  , rs1Value := 12288
  , rs2 := 0
  , rs2Value := 0
  , rd := 5
  , rdBefore := 0
  , rdAfter := 18446744071570424063
  , imm := 0
  , aluResult := 18446744071570424063
  , effectiveAddr := (some 12288)
  , memoryBefore := (some 9920249032750366975)
  , memoryAfter := (some 9920249032750366975)
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
  , word := 4547331
  , opcode := .lwu
  , traceOpcode := (some .lwu)
  , traceVirtualOpcode := none
  , family := .narrowMemory
  , rs1 := 10
  , rs1Value := 12288
  , rs2 := 0
  , rs2Value := 0
  , rd := 6
  , rdBefore := 0
  , rdAfter := 2309737967
  , imm := 4
  , aluResult := 2309737967
  , effectiveAddr := (some 12292)
  , memoryBefore := (some 9920249032750366975)
  , memoryAfter := (some 9920249032750366975)
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
  , stage1 := { rows := [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 327811, opcode := .lb, traceOpcode := (some .lb), traceVirtualOpcode := none, family := .narrowMemory, nextPc := 4, aluResult := 18446744073709551615, effectiveAddr := (some 12288), writesRd := true, rd := 1, rdAfter := 18446744073709551615, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 1392899, opcode := .lbu, traceOpcode := (some .lbu), traceVirtualOpcode := none, family := .narrowMemory, nextPc := 8, aluResult := 128, effectiveAddr := (some 12289), writesRd := true, rd := 2, rdAfter := 128, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 332163, opcode := .lh, traceOpcode := (some .lh), traceVirtualOpcode := none, family := .narrowMemory, nextPc := 12, aluResult := 18446744073709519103, effectiveAddr := (some 12288), writesRd := true, rd := 3, rdAfter := 18446744073709519103, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 12, fetchedWord := 2445827, opcode := .lhu, traceOpcode := (some .lhu), traceVirtualOpcode := none, family := .narrowMemory, nextPc := 16, aluResult := 32895, effectiveAddr := (some 12290), writesRd := true, rd := 4, rdAfter := 32895, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 4, stepIndex := 4, sequenceIndex := 0, fetchPc := 16, fetchedWord := 336515, opcode := .lw, traceOpcode := (some .lw), traceVirtualOpcode := none, family := .narrowMemory, nextPc := 20, aluResult := 18446744071570424063, effectiveAddr := (some 12288), writesRd := true, rd := 5, rdAfter := 18446744071570424063, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 5, stepIndex := 5, sequenceIndex := 0, fetchPc := 20, fetchedWord := 4547331, opcode := .lwu, traceOpcode := (some .lwu), traceVirtualOpcode := none, family := .narrowMemory, nextPc := 24, aluResult := 2309737967, effectiveAddr := (some 12292), writesRd := true, rd := 6, rdAfter := 2309737967, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 6, stepIndex := 6, sequenceIndex := 0, fetchPc := 24, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 28, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }] }
  , stage2 := {
  registerReads := [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 10, value := 12288 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 10, value := 12288 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 10, value := 12288 }, { traceIndex := 3, stepIndex := 3, role := .rs1, reg := 10, value := 12288 }, { traceIndex := 4, stepIndex := 4, role := .rs1, reg := 10, value := 12288 }, { traceIndex := 5, stepIndex := 5, role := .rs1, reg := 10, value := 12288 }]
  , registerWrites := [{ traceIndex := 0, stepIndex := 0, reg := 1, previous := 0, next := 18446744073709551615 }, { traceIndex := 1, stepIndex := 1, reg := 2, previous := 0, next := 128 }, { traceIndex := 2, stepIndex := 2, reg := 3, previous := 0, next := 18446744073709519103 }, { traceIndex := 3, stepIndex := 3, reg := 4, previous := 0, next := 32895 }, { traceIndex := 4, stepIndex := 4, reg := 5, previous := 0, next := 18446744071570424063 }, { traceIndex := 5, stepIndex := 5, reg := 6, previous := 0, next := 2309737967 }]
  , ramEvents := [{ traceIndex := 0, stepIndex := 0, kind := .read, addr := 12288, previous := 9920249032750366975, next := 9920249032750366975 }, { traceIndex := 1, stepIndex := 1, kind := .read, addr := 12288, previous := 9920249032750366975, next := 9920249032750366975 }, { traceIndex := 2, stepIndex := 2, kind := .read, addr := 12288, previous := 9920249032750366975, next := 9920249032750366975 }, { traceIndex := 3, stepIndex := 3, kind := .read, addr := 12288, previous := 9920249032750366975, next := 9920249032750366975 }, { traceIndex := 4, stepIndex := 4, kind := .read, addr := 12288, previous := 9920249032750366975, next := 9920249032750366975 }, { traceIndex := 5, stepIndex := 5, kind := .read, addr := 12288, previous := 9920249032750366975, next := 9920249032750366975 }]
  , twistLinks := [{ traceIndex := 0, stepIndex := 0, family := .narrowMemory, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := (some 9920249032750366975), routedMemoryAfter := (some 9920249032750366975) }, { traceIndex := 1, stepIndex := 1, family := .narrowMemory, routedWriteValue := (some 128), routedMemoryBefore := (some 9920249032750366975), routedMemoryAfter := (some 9920249032750366975) }, { traceIndex := 2, stepIndex := 2, family := .narrowMemory, routedWriteValue := (some 18446744073709519103), routedMemoryBefore := (some 9920249032750366975), routedMemoryAfter := (some 9920249032750366975) }, { traceIndex := 3, stepIndex := 3, family := .narrowMemory, routedWriteValue := (some 32895), routedMemoryBefore := (some 9920249032750366975), routedMemoryAfter := (some 9920249032750366975) }, { traceIndex := 4, stepIndex := 4, family := .narrowMemory, routedWriteValue := (some 18446744071570424063), routedMemoryBefore := (some 9920249032750366975), routedMemoryAfter := (some 9920249032750366975) }, { traceIndex := 5, stepIndex := 5, family := .narrowMemory, routedWriteValue := (some 2309737967), routedMemoryBefore := (some 9920249032750366975), routedMemoryAfter := (some 9920249032750366975) }, { traceIndex := 6, stepIndex := 6, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]
}
  , stage3 := {
  continuity := [{ stepIndex := 0, pc := 0, nextPc := 4, successorPc := (some 4), finalStep := false, continuityHolds := true }, { stepIndex := 1, pc := 4, nextPc := 8, successorPc := (some 8), finalStep := false, continuityHolds := true }, { stepIndex := 2, pc := 8, nextPc := 12, successorPc := (some 12), finalStep := false, continuityHolds := true }, { stepIndex := 3, pc := 12, nextPc := 16, successorPc := (some 16), finalStep := false, continuityHolds := true }, { stepIndex := 4, pc := 16, nextPc := 20, successorPc := (some 20), finalStep := false, continuityHolds := true }, { stepIndex := 5, pc := 20, nextPc := 24, successorPc := (some 24), finalStep := false, continuityHolds := true }, { stepIndex := 6, pc := 24, nextPc := 28, successorPc := none, finalStep := true, continuityHolds := true }]
  , halted := true
}
  , transcript := {
  appLabel := (bytes [110, 101, 111, 46, 102, 111, 108, 100, 46, 110, 101, 120, 116, 47, 114, 118, 54, 52, 105, 109, 47, 112, 97, 114, 105, 116, 121, 95, 107, 101, 114, 110, 101, 108, 95, 118, 49])
  , events := [{
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 116, 114, 97, 110, 115, 99, 114, 105, 112, 116, 95, 115, 101, 101, 100])
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 110, 97, 114, 114, 111, 119, 45, 109, 101, 109, 111, 114, 121, 45, 108, 111, 97, 100, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [12799906354652525, 13922211188535148, 8175347121317401730, 8308484394106086806, 5884511499246010210, 7998233416229622215, 6964649998063382141, 1153192176276551949], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [110, 97, 114, 114, 111, 119, 95, 109, 101, 109, 111, 114, 121, 95, 108, 111, 97, 100, 95, 101, 120, 116, 114, 97, 99, 116, 95, 101, 120, 116, 101, 110, 100, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [12799906354652525, 13922211188535148, 8175347121317401730, 8308484394106086806, 5884511499246010210, 7998233416229622215, 6964649998063382141, 1153192176276551949], absorbed := 2 }
  , cursorAfter := { stateWords := [28533857601287288, 1819042147, 13405346572071477917, 15027069468260443345, 4657219632283511591, 13009867408141909840, 4570646721011936107, 9340009794846925166], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [327811, 1392899, 332163, 2445827, 336515, 4547331, 115]
  , cursorBefore := { stateWords := [28533857601287288, 1819042147, 13405346572071477917, 15027069468260443345, 4657219632283511591, 13009867408141909840, 4570646721011936107, 9340009794846925166], absorbed := 2 }
  , cursorAfter := { stateWords := [115, 0, 18158569649085369217, 4324689580891859743, 10837909801324925519, 629902553474001713, 11675622141450684452, 7267351139728427145], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 12288, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [115, 0, 18158569649085369217, 4324689580891859743, 10837909801324925519, 629902553474001713, 11675622141450684452, 7267351139728427145], absorbed := 2 }
  , cursorAfter := { stateWords := [3830413514925331899, 15686288481201580579, 4012207186557823599, 15735477179778979507, 17069698027905491847, 15814070235405475754, 820753214640218683, 3850378618103265605], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := [12288, 9920249032750366975]
  , cursorBefore := { stateWords := [3830413514925331899, 15686288481201580579, 4012207186557823599, 15735477179778979507, 17069698027905491847, 15814070235405475754, 820753214640218683, 3850378618103265605], absorbed := 0 }
  , cursorAfter := { stateWords := [2155839743, 2309737967, 17016907635301106391, 499923465555411882, 13196496673628649080, 4039687380468766989, 8511621768432349814, 1763263620507366255], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [67, 149, 212, 203, 125, 6, 193, 148, 95, 242, 87, 131, 79, 199, 154, 105, 62, 65, 66, 99, 45, 14, 202, 150, 24, 19, 22, 127, 80, 126, 57, 58])
  , u64s := []
  , cursorBefore := { stateWords := [2155839743, 2309737967, 17016907635301106391, 499923465555411882, 13196496673628649080, 4039687380468766989, 8511621768432349814, 1763263620507366255], absorbed := 2 }
  , cursorAfter := { stateWords := [976846416, 11042167288883101657, 9351894048581840145, 7006946695586167544, 17289545109842428286, 12963296847801935423, 15745235796732095321, 13267867589393505093], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [976846416, 11042167288883101657, 9351894048581840145, 7006946695586167544, 17289545109842428286, 12963296847801935423, 15745235796732095321, 13267867589393505093], absorbed := 1 }
  , cursorAfter := { stateWords := [6021918011723055633, 1314817092102069106, 12426851555635967853, 10353416768809675651, 17337105125606089765, 2918732584938148215, 14472588237035002733, 8229608136258886321], absorbed := 0 }
  , challengeOutput := (some 6021918011723055633)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [233, 196, 203, 200, 70, 58, 121, 64, 190, 77, 215, 109, 211, 207, 110, 212, 227, 39, 71, 54, 50, 7, 179, 37, 204, 185, 66, 14, 130, 114, 51, 240])
  , u64s := []
  , cursorBefore := { stateWords := [6021918011723055633, 1314817092102069106, 12426851555635967853, 10353416768809675651, 17337105125606089765, 2918732584938148215, 14472588237035002733, 8229608136258886321], absorbed := 0 }
  , cursorAfter := { stateWords := [14133428075353198, 4014015435354887, 4029903490, 16838230519069327746, 4085405358271329919, 14228927208023853474, 107353801817462348, 1952929269162220252], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [14133428075353198, 4014015435354887, 4029903490, 16838230519069327746, 4085405358271329919, 14228927208023853474, 107353801817462348, 1952929269162220252], absorbed := 3 }
  , cursorAfter := { stateWords := [12166816141915752516, 15419316117070074829, 2047636294008387338, 7699572410557338177, 13310677340565681106, 17751688798917587722, 14344274668446917168, 15533352597549184691], absorbed := 0 }
  , challengeOutput := (some 12166816141915752516)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [12166816141915752516, 15419316117070074829, 2047636294008387338, 7699572410557338177, 13310677340565681106, 17751688798917587722, 14344274668446917168, 15533352597549184691], absorbed := 0 }
  , cursorAfter := { stateWords := [4582133116042247748, 8731322839414209506, 1662529965242248010, 8418892417039773871, 9000361494525483189, 13638806656306225915, 1570254867137968212, 6077116453526416551], absorbed := 0 }
  , challengeOutput := (some 4582133116042247748)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [133, 91, 57, 33, 9, 81, 232, 147, 233, 248, 11, 52, 22, 187, 82, 147, 231, 35, 101, 212, 42, 7, 126, 94, 3, 54, 201, 128, 233, 222, 146, 92])
  , u64s := []
  , cursorBefore := { stateWords := [4582133116042247748, 8731322839414209506, 1662529965242248010, 8418892417039773871, 9000361494525483189, 13638806656306225915, 1570254867137968212, 6077116453526416551], absorbed := 0 }
  , cursorAfter := { stateWords := [12055479881012050, 36250030840905223, 1553129193, 7433689907473488653, 5965175124267803640, 14792457317794278921, 605774587042402052, 3412124567993221433], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [12055479881012050, 36250030840905223, 1553129193, 7433689907473488653, 5965175124267803640, 14792457317794278921, 605774587042402052, 3412124567993221433], absorbed := 3 }
  , cursorAfter := { stateWords := [13816550690510729125, 18101985310251038407, 9608517073677775066, 2584218457954885402, 2407808902030683260, 13628125446280137751, 3448376294072599785, 4693705293099813145], absorbed := 0 }
  , challengeOutput := (some 13816550690510729125)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [13, 62, 18, 231, 159, 216, 74, 146, 123, 100, 48, 154, 55, 62, 243, 77, 247, 72, 183, 146, 55, 128, 226, 205, 79, 61, 249, 159, 174, 184, 114, 0])
  , u64s := []
  , cursorBefore := { stateWords := [13816550690510729125, 18101985310251038407, 9608517073677775066, 2584218457954885402, 2407808902030683260, 13628125446280137751, 3448376294072599785, 4693705293099813145], absorbed := 0 }
  , cursorAfter := { stateWords := [15642439619923443, 45028563024208512, 7518382, 8361902626686925691, 2225358803819603115, 9245944133697156672, 1336650474291237605, 4811421835623193385], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [187, 211, 69, 135, 229, 127, 64, 102, 85, 14, 246, 26, 208, 214, 247, 252, 184, 3, 119, 82, 89, 137, 101, 38, 31, 135, 97, 182, 171, 175, 16, 207])
  , u64s := []
  , cursorBefore := { stateWords := [15642439619923443, 45028563024208512, 7518382, 8361902626686925691, 2225358803819603115, 9245944133697156672, 1336650474291237605, 4811421835623193385], absorbed := 3 }
  , cursorAfter := { stateWords := [25141944044289271, 51335678732428681, 3473977259, 13731804578639336113, 10961016839209921425, 18130052512516982862, 4673728544040845705, 16203916050884902499], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [183, 99, 121, 135, 139, 0, 186, 237, 83, 70, 165, 225, 69, 94, 88, 23, 106, 225, 174, 203, 176, 128, 255, 252, 189, 21, 5, 237, 46, 123, 103, 80])
  , u64s := []
  , cursorBefore := { stateWords := [25141944044289271, 51335678732428681, 3473977259, 13731804578639336113, 10961016839209921425, 18130052512516982862, 4673728544040845705, 16203916050884902499], absorbed := 3 }
  , cursorAfter := { stateWords := [49763547867649880, 66715160420351872, 1348959022, 15709606489153929614, 8121674917799648079, 15710361591141068338, 9590642781091900839, 9242433929454591953], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [49763547867649880, 66715160420351872, 1348959022, 15709606489153929614, 8121674917799648079, 15710361591141068338, 9590642781091900839, 9242433929454591953], absorbed := 3 }
  , cursorAfter := { stateWords := [5089522495975454261, 1105680697028675754, 17663795333069901089, 8984707892722831397, 9570329054447077234, 10004337964861211153, 5155669186334908773, 10948998427876731888], absorbed := 0 }
  , challengeOutput := (some 5089522495975454261)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [5089522495975454261, 1105680697028675754, 17663795333069901089, 8984707892722831397, 9570329054447077234, 10004337964861211153, 5155669186334908773, 10948998427876731888], absorbed := 0 }
  , cursorAfter := { stateWords := [6705451615684752047, 259196052256607845, 13875982187815904043, 7900743909553083362, 7968206663224187973, 14127116662389960561, 13263370867764124287, 16247986710756250182], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [175, 114, 117, 171, 183, 140, 14, 93, 101, 78, 240, 173, 111, 217, 152, 3, 43, 35, 106, 30, 72, 100, 145, 192, 226, 19, 62, 206, 185, 20, 165, 109]))
}]
}
  , kernel := {
  root0Digest := (bytes [67, 149, 212, 203, 125, 6, 193, 148, 95, 242, 87, 131, 79, 199, 154, 105, 62, 65, 66, 99, 45, 14, 202, 150, 24, 19, 22, 127, 80, 126, 57, 58])
  , stage1Digest := (bytes [233, 196, 203, 200, 70, 58, 121, 64, 190, 77, 215, 109, 211, 207, 110, 212, 227, 39, 71, 54, 50, 7, 179, 37, 204, 185, 66, 14, 130, 114, 51, 240])
  , stage2Digest := (bytes [133, 91, 57, 33, 9, 81, 232, 147, 233, 248, 11, 52, 22, 187, 82, 147, 231, 35, 101, 212, 42, 7, 126, 94, 3, 54, 201, 128, 233, 222, 146, 92])
  , stage3Digest := (bytes [13, 62, 18, 231, 159, 216, 74, 146, 123, 100, 48, 154, 55, 62, 243, 77, 247, 72, 183, 146, 55, 128, 226, 205, 79, 61, 249, 159, 174, 184, 114, 0])
  , executionDigest := (bytes [187, 211, 69, 135, 229, 127, 64, 102, 85, 14, 246, 26, 208, 214, 247, 252, 184, 3, 119, 82, 89, 137, 101, 38, 31, 135, 97, 182, 171, 175, 16, 207])
  , finalStateDigest := (bytes [183, 99, 121, 135, 139, 0, 186, 237, 83, 70, 165, 225, 69, 94, 88, 23, 106, 225, 174, 203, 176, 128, 255, 252, 189, 21, 5, 237, 46, 123, 103, 80])
  , stage1Mix := 6021918011723055633
  , stage2RegMix := 12166816141915752516
  , stage2RamMix := 4582133116042247748
  , stage3ContinuityMix := 13816550690510729125
  , kernelFinalMix := 5089522495975454261
  , transcriptFinalDigest := (bytes [175, 114, 117, 171, 183, 140, 14, 93, 101, 78, 240, 173, 111, 217, 152, 3, 43, 35, 106, 30, 72, 100, 145, 192, 226, 19, 62, 206, 185, 20, 165, 109])
  , finalPc := 28
  , finalRegisters := [0, 18446744073709551615, 128, 18446744073709519103, 32895, 18446744071570424063, 2309737967, 0, 0, 0, 12288, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , finalMemory := [{ addr := 12288, value := 9920249032750366975 }]
  , halted := true
}
}

end Nightstream.Rv64IM.Generated.Cases.Case_narrow_memory_load_extract_extend_ecall
