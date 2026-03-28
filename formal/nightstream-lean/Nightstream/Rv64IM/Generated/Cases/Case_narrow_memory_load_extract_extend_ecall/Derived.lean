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
  , ramEvents := [{ traceIndex := 0, stepIndex := 0, kind := .read, addr := 12288, previous := 9920249032750366975, next := 9920249032750366975 }, { traceIndex := 1, stepIndex := 1, kind := .read, addr := 12289, previous := 9920249032750366975, next := 9920249032750366975 }, { traceIndex := 2, stepIndex := 2, kind := .read, addr := 12288, previous := 9920249032750366975, next := 9920249032750366975 }, { traceIndex := 3, stepIndex := 3, kind := .read, addr := 12290, previous := 9920249032750366975, next := 9920249032750366975 }, { traceIndex := 4, stepIndex := 4, kind := .read, addr := 12288, previous := 9920249032750366975, next := 9920249032750366975 }, { traceIndex := 5, stepIndex := 5, kind := .read, addr := 12292, previous := 9920249032750366975, next := 9920249032750366975 }]
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
  , message := (bytes [181, 216, 120, 46, 210, 197, 139, 251, 158, 87, 113, 75, 20, 106, 254, 19, 153, 46, 174, 106, 142, 122, 102, 37, 171, 42, 75, 156, 188, 201, 41, 109])
  , u64s := []
  , cursorBefore := { stateWords := [4582133116042247748, 8731322839414209506, 1662529965242248010, 8418892417039773871, 9000361494525483189, 13638806656306225915, 1570254867137968212, 6077116453526416551], absorbed := 0 }
  , cursorAfter := { stateWords := [40086743031550974, 43992742998926970, 1831455164, 1935788246349052988, 7944848740943738640, 5386847413593439148, 4756179362178964376, 8787934322272555640], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [40086743031550974, 43992742998926970, 1831455164, 1935788246349052988, 7944848740943738640, 5386847413593439148, 4756179362178964376, 8787934322272555640], absorbed := 3 }
  , cursorAfter := { stateWords := [8725406294346589369, 3228233198794358598, 14953181735171201920, 7366410876624556626, 15068592622373722274, 7402889381521569771, 16374428104316630217, 1862078958249063362], absorbed := 0 }
  , challengeOutput := (some 8725406294346589369)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [13, 62, 18, 231, 159, 216, 74, 146, 123, 100, 48, 154, 55, 62, 243, 77, 247, 72, 183, 146, 55, 128, 226, 205, 79, 61, 249, 159, 174, 184, 114, 0])
  , u64s := []
  , cursorBefore := { stateWords := [8725406294346589369, 3228233198794358598, 14953181735171201920, 7366410876624556626, 15068592622373722274, 7402889381521569771, 16374428104316630217, 1862078958249063362], absorbed := 0 }
  , cursorAfter := { stateWords := [15642439619923443, 45028563024208512, 7518382, 16708771247748191992, 11657291944355413483, 14431693973360697735, 7954629240297733010, 10878782077218798405], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [187, 211, 69, 135, 229, 127, 64, 102, 85, 14, 246, 26, 208, 214, 247, 252, 184, 3, 119, 82, 89, 137, 101, 38, 31, 135, 97, 182, 171, 175, 16, 207])
  , u64s := []
  , cursorBefore := { stateWords := [15642439619923443, 45028563024208512, 7518382, 16708771247748191992, 11657291944355413483, 14431693973360697735, 7954629240297733010, 10878782077218798405], absorbed := 3 }
  , cursorAfter := { stateWords := [25141944044289271, 51335678732428681, 3473977259, 5385261861905269423, 281814612111928979, 4511536262939994887, 18113252400606566920, 4544495708918634315], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [183, 99, 121, 135, 139, 0, 186, 237, 83, 70, 165, 225, 69, 94, 88, 23, 106, 225, 174, 203, 176, 128, 255, 252, 189, 21, 5, 237, 46, 123, 103, 80])
  , u64s := []
  , cursorBefore := { stateWords := [25141944044289271, 51335678732428681, 3473977259, 5385261861905269423, 281814612111928979, 4511536262939994887, 18113252400606566920, 4544495708918634315], absorbed := 3 }
  , cursorAfter := { stateWords := [49763547867649880, 66715160420351872, 1348959022, 3225203903876532950, 18049744920156249049, 10014600850299435896, 4301257663898535537, 13034479775411002448], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [49763547867649880, 66715160420351872, 1348959022, 3225203903876532950, 18049744920156249049, 10014600850299435896, 4301257663898535537, 13034479775411002448], absorbed := 3 }
  , cursorAfter := { stateWords := [264833077455290537, 5399324433150863685, 9815260751803662264, 4870641243578744093, 15184329028461028797, 2100720104702941134, 3620378679032292232, 6988333774434514523], absorbed := 0 }
  , challengeOutput := (some 264833077455290537)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [264833077455290537, 5399324433150863685, 9815260751803662264, 4870641243578744093, 15184329028461028797, 2100720104702941134, 3620378679032292232, 6988333774434514523], absorbed := 0 }
  , cursorAfter := { stateWords := [4452532291804518470, 10618707549547800553, 2007096857606116486, 14439258445734265159, 3090420615321664570, 3437263071003291050, 7494679618801449080, 3963356524955668864], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [70, 216, 246, 99, 135, 146, 202, 61, 233, 39, 142, 136, 65, 58, 93, 147, 134, 84, 106, 59, 245, 163, 218, 27, 71, 193, 12, 206, 13, 141, 98, 200]))
}]
}
  , kernel := {
  root0Digest := (bytes [67, 149, 212, 203, 125, 6, 193, 148, 95, 242, 87, 131, 79, 199, 154, 105, 62, 65, 66, 99, 45, 14, 202, 150, 24, 19, 22, 127, 80, 126, 57, 58])
  , stage1Digest := (bytes [233, 196, 203, 200, 70, 58, 121, 64, 190, 77, 215, 109, 211, 207, 110, 212, 227, 39, 71, 54, 50, 7, 179, 37, 204, 185, 66, 14, 130, 114, 51, 240])
  , stage2Digest := (bytes [181, 216, 120, 46, 210, 197, 139, 251, 158, 87, 113, 75, 20, 106, 254, 19, 153, 46, 174, 106, 142, 122, 102, 37, 171, 42, 75, 156, 188, 201, 41, 109])
  , stage3Digest := (bytes [13, 62, 18, 231, 159, 216, 74, 146, 123, 100, 48, 154, 55, 62, 243, 77, 247, 72, 183, 146, 55, 128, 226, 205, 79, 61, 249, 159, 174, 184, 114, 0])
  , executionDigest := (bytes [187, 211, 69, 135, 229, 127, 64, 102, 85, 14, 246, 26, 208, 214, 247, 252, 184, 3, 119, 82, 89, 137, 101, 38, 31, 135, 97, 182, 171, 175, 16, 207])
  , finalStateDigest := (bytes [183, 99, 121, 135, 139, 0, 186, 237, 83, 70, 165, 225, 69, 94, 88, 23, 106, 225, 174, 203, 176, 128, 255, 252, 189, 21, 5, 237, 46, 123, 103, 80])
  , stage1Mix := 6021918011723055633
  , stage2RegMix := 12166816141915752516
  , stage2RamMix := 4582133116042247748
  , stage3ContinuityMix := 8725406294346589369
  , kernelFinalMix := 264833077455290537
  , transcriptFinalDigest := (bytes [70, 216, 246, 99, 135, 146, 202, 61, 233, 39, 142, 136, 65, 58, 93, 147, 134, 84, 106, 59, 245, 163, 218, 27, 71, 193, 12, 206, 13, 141, 98, 200])
  , finalPc := 28
  , finalRegisters := [0, 18446744073709551615, 128, 18446744073709519103, 32895, 18446744071570424063, 2309737967, 0, 0, 0, 12288, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , finalMemory := [{ addr := 12288, value := 9920249032750366975 }]
  , halted := true
}
}

end Nightstream.Rv64IM.Generated.Cases.Case_narrow_memory_load_extract_extend_ecall
