import Nightstream.Rv64IM.Generated.ParityTypes

namespace Nightstream.Rv64IM.Generated.Cases.Case_native_word_shift_chain_ecall

open Nightstream.Rv64IM.Generated

def derivedCase : ParityDerivedCase :=
  {
  manifest := { name := "native_word_shift_chain_ecall", fixtureId := "native_word_shift_chain_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , executionRows := [{
  traceIndex := 0
  , stepIndex := 0
  , sequenceIndex := 0
  , pc := 0
  , nextPc := 4
  , word := 32543131
  , opcode := .slliw
  , traceOpcode := (some .slliw)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 1
  , rs2 := 0
  , rs2Value := 0
  , rd := 3
  , rdBefore := 0
  , rdAfter := 18446744071562067968
  , imm := 31
  , aluResult := 18446744071562067968
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
  , word := 4280859
  , opcode := .srliw
  , traceOpcode := (some .srliw)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 2
  , rs1Value := 18446744071562067968
  , rs2 := 0
  , rs2Value := 0
  , rd := 4
  , rdBefore := 0
  , rdAfter := 134217728
  , imm := 4
  , aluResult := 134217728
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
  , word := 1078022811
  , opcode := .sraiw
  , traceOpcode := (some .sraiw)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 2
  , rs1Value := 18446744071562067968
  , rs2 := 0
  , rs2Value := 0
  , rd := 5
  , rdBefore := 0
  , rdAfter := 18446744073575333888
  , imm := 4
  , aluResult := 18446744073575333888
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
  , word := 6329275
  , opcode := .sllw
  , traceOpcode := (some .sllw)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 1
  , rs2 := 6
  , rs2Value := 40
  , rd := 7
  , rdBefore := 0
  , rdAfter := 256
  , imm := 0
  , aluResult := 256
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
  , word := 6378555
  , opcode := .srlw
  , traceOpcode := (some .srlw)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 2
  , rs1Value := 18446744071562067968
  , rs2 := 6
  , rs2Value := 40
  , rd := 8
  , rdBefore := 0
  , rdAfter := 8388608
  , imm := 0
  , aluResult := 8388608
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
  , word := 1080120507
  , opcode := .sraw
  , traceOpcode := (some .sraw)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 2
  , rs1Value := 18446744071562067968
  , rs2 := 6
  , rs2Value := 40
  , rd := 9
  , rdBefore := 0
  , rdAfter := 18446744073701163008
  , imm := 0
  , aluResult := 18446744073701163008
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
  , stage1 := { rows := [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 32543131, opcode := .slliw, traceOpcode := (some .slliw), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 4, aluResult := 18446744071562067968, effectiveAddr := none, writesRd := true, rd := 3, rdAfter := 18446744071562067968, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 4280859, opcode := .srliw, traceOpcode := (some .srliw), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 8, aluResult := 134217728, effectiveAddr := none, writesRd := true, rd := 4, rdAfter := 134217728, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 1078022811, opcode := .sraiw, traceOpcode := (some .sraiw), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 12, aluResult := 18446744073575333888, effectiveAddr := none, writesRd := true, rd := 5, rdAfter := 18446744073575333888, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 12, fetchedWord := 6329275, opcode := .sllw, traceOpcode := (some .sllw), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 16, aluResult := 256, effectiveAddr := none, writesRd := true, rd := 7, rdAfter := 256, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 4, stepIndex := 4, sequenceIndex := 0, fetchPc := 16, fetchedWord := 6378555, opcode := .srlw, traceOpcode := (some .srlw), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 20, aluResult := 8388608, effectiveAddr := none, writesRd := true, rd := 8, rdAfter := 8388608, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 5, stepIndex := 5, sequenceIndex := 0, fetchPc := 20, fetchedWord := 1080120507, opcode := .sraw, traceOpcode := (some .sraw), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 24, aluResult := 18446744073701163008, effectiveAddr := none, writesRd := true, rd := 9, rdAfter := 18446744073701163008, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 6, stepIndex := 6, sequenceIndex := 0, fetchPc := 24, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 28, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }] }
  , stage2 := {
  registerReads := [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 1, value := 1 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 2, value := 18446744071562067968 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 2, value := 18446744071562067968 }, { traceIndex := 3, stepIndex := 3, role := .rs1, reg := 1, value := 1 }, { traceIndex := 3, stepIndex := 3, role := .rs2, reg := 6, value := 40 }, { traceIndex := 4, stepIndex := 4, role := .rs1, reg := 2, value := 18446744071562067968 }, { traceIndex := 4, stepIndex := 4, role := .rs2, reg := 6, value := 40 }, { traceIndex := 5, stepIndex := 5, role := .rs1, reg := 2, value := 18446744071562067968 }, { traceIndex := 5, stepIndex := 5, role := .rs2, reg := 6, value := 40 }]
  , registerWrites := [{ traceIndex := 0, stepIndex := 0, reg := 3, previous := 0, next := 18446744071562067968 }, { traceIndex := 1, stepIndex := 1, reg := 4, previous := 0, next := 134217728 }, { traceIndex := 2, stepIndex := 2, reg := 5, previous := 0, next := 18446744073575333888 }, { traceIndex := 3, stepIndex := 3, reg := 7, previous := 0, next := 256 }, { traceIndex := 4, stepIndex := 4, reg := 8, previous := 0, next := 8388608 }, { traceIndex := 5, stepIndex := 5, reg := 9, previous := 0, next := 18446744073701163008 }]
  , ramEvents := []
  , twistLinks := [{ traceIndex := 0, stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 18446744071562067968), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 1, family := .nativeAlu, routedWriteValue := (some 134217728), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 2, family := .nativeAlu, routedWriteValue := (some 18446744073575333888), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 3, family := .nativeAlu, routedWriteValue := (some 256), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 4, stepIndex := 4, family := .nativeAlu, routedWriteValue := (some 8388608), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 5, stepIndex := 5, family := .nativeAlu, routedWriteValue := (some 18446744073701163008), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 6, stepIndex := 6, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]
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
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 110, 97, 116, 105, 118, 101, 45, 119, 111, 114, 100, 45, 115, 104, 105, 102, 116, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [29400036373852023, 54383638505065, 94828755958258816, 10905788041622594868, 8841251816071870994, 13391653407446453246, 17446101127387435910, 7137168547377178156], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [110, 97, 116, 105, 118, 101, 95, 119, 111, 114, 100, 95, 115, 104, 105, 102, 116, 95, 99, 104, 97, 105, 110, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [29400036373852023, 54383638505065, 94828755958258816, 10905788041622594868, 8841251816071870994, 13391653407446453246, 17446101127387435910, 7137168547377178156], absorbed := 2 }
  , cursorAfter := { stateWords := [108, 9521594137446015360, 2547443039661527262, 8672344190622444400, 8081909694194674092, 16881897145227272165, 8660841998244389168, 6317820854843455934], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [32543131, 4280859, 1078022811, 6329275, 6378555, 1080120507, 115]
  , cursorBefore := { stateWords := [108, 9521594137446015360, 2547443039661527262, 8672344190622444400, 8081909694194674092, 16881897145227272165, 8660841998244389168, 6317820854843455934], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 14817934692253552668, 5422135311370894167, 11520748702834940406, 11883633006059594575, 13899328913923243995, 3788765349771335243, 8170474725918284627], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 1, 18446744071562067968, 0, 0, 0, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [0, 14817934692253552668, 5422135311370894167, 11520748702834940406, 11883633006059594575, 13899328913923243995, 3788765349771335243, 8170474725918284627], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 0, 0, 5599915549487473793, 16406075848753953094, 4257212436415025084, 11701250843308806400, 7729765377244787962], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [0, 0, 0, 5599915549487473793, 16406075848753953094, 4257212436415025084, 11701250843308806400, 7729765377244787962], absorbed := 3 }
  , cursorAfter := { stateWords := [0, 14440487766866437759, 16158411280243843198, 11068495199233569458, 14924541703762306079, 8267198643178946222, 3573274338800551902, 11655965166207194028], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [228, 98, 148, 141, 173, 208, 81, 252, 147, 68, 207, 191, 208, 77, 9, 104, 120, 204, 161, 231, 192, 35, 84, 44, 52, 102, 68, 156, 128, 207, 202, 141])
  , u64s := []
  , cursorBefore := { stateWords := [0, 14440487766866437759, 16158411280243843198, 11068495199233569458, 14924541703762306079, 8267198643178946222, 3573274338800551902, 11655965166207194028], absorbed := 1 }
  , cursorAfter := { stateWords := [13311955648816485990, 16750417430444283956, 7685154747109710587, 6295989157772776084, 10092538584374784937, 8793270786648840439, 14540163602231133867, 16323917404508849710], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [13311955648816485990, 16750417430444283956, 7685154747109710587, 6295989157772776084, 10092538584374784937, 8793270786648840439, 14540163602231133867, 16323917404508849710], absorbed := 0 }
  , cursorAfter := { stateWords := [16632802919108710147, 13258520627264740138, 17110149117418189791, 6344445357732662908, 300123635686731147, 4690309516771459959, 1666160823646593165, 18427001648205017043], absorbed := 0 }
  , challengeOutput := (some 16632802919108710147)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [248, 83, 178, 47, 183, 64, 167, 213, 46, 91, 10, 99, 62, 110, 132, 116, 93, 93, 226, 16, 211, 156, 232, 54, 142, 211, 84, 128, 80, 117, 85, 150])
  , u64s := []
  , cursorBefore := { stateWords := [16632802919108710147, 13258520627264740138, 17110149117418189791, 6344445357732662908, 300123635686731147, 4690309516771459959, 1666160823646593165, 18427001648205017043], absorbed := 0 }
  , cursorAfter := { stateWords := [59409784501007492, 36122064619759772, 2522182992, 5559568679772866832, 16947521631507430986, 7097905515152098934, 9662790264370553859, 14387856573604793263], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [59409784501007492, 36122064619759772, 2522182992, 5559568679772866832, 16947521631507430986, 7097905515152098934, 9662790264370553859, 14387856573604793263], absorbed := 3 }
  , cursorAfter := { stateWords := [6139558469011796608, 4884362147061659144, 6321389962816677855, 8024296613977891277, 17489341190933289337, 16990790758108438777, 8165258603605472692, 2764174045714964182], absorbed := 0 }
  , challengeOutput := (some 6139558469011796608)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [6139558469011796608, 4884362147061659144, 6321389962816677855, 8024296613977891277, 17489341190933289337, 16990790758108438777, 8165258603605472692, 2764174045714964182], absorbed := 0 }
  , cursorAfter := { stateWords := [17659153299687098721, 17712354528554568885, 7814109569743718645, 7005650859248593987, 16662198303255909078, 12430977943436854309, 16377826725812306225, 12444259142770773964], absorbed := 0 }
  , challengeOutput := (some 17659153299687098721)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [196, 71, 198, 8, 146, 145, 167, 84, 220, 161, 107, 98, 85, 177, 210, 218, 174, 250, 41, 0, 144, 47, 208, 110, 33, 168, 235, 189, 138, 191, 255, 150])
  , u64s := []
  , cursorBefore := { stateWords := [17659153299687098721, 17712354528554568885, 7814109569743718645, 7005650859248593987, 16662198303255909078, 12430977943436854309, 16377826725812306225, 12444259142770773964], absorbed := 0 }
  , cursorAfter := { stateWords := [40532576945756882, 53457877946257455, 2533343114, 4389037520566929362, 905308323029389650, 6715865865346790960, 16344541882997798331, 15633995429416586303], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [40532576945756882, 53457877946257455, 2533343114, 4389037520566929362, 905308323029389650, 6715865865346790960, 16344541882997798331, 15633995429416586303], absorbed := 3 }
  , cursorAfter := { stateWords := [9836651665554253514, 1013454718206227654, 17847195175752135230, 7315708913189141393, 4158483092181717784, 15953468123669375930, 4646134940636474177, 3253426992010223375], absorbed := 0 }
  , challengeOutput := (some 9836651665554253514)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [13, 62, 18, 231, 159, 216, 74, 146, 123, 100, 48, 154, 55, 62, 243, 77, 247, 72, 183, 146, 55, 128, 226, 205, 79, 61, 249, 159, 174, 184, 114, 0])
  , u64s := []
  , cursorBefore := { stateWords := [9836651665554253514, 1013454718206227654, 17847195175752135230, 7315708913189141393, 4158483092181717784, 15953468123669375930, 4646134940636474177, 3253426992010223375], absorbed := 0 }
  , cursorAfter := { stateWords := [15642439619923443, 45028563024208512, 7518382, 8453740008147120415, 6979412999780891539, 577455515313918828, 16131038695622428852, 5173994843640728666], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [211, 235, 172, 239, 219, 81, 4, 198, 152, 115, 67, 102, 208, 155, 208, 227, 187, 253, 120, 104, 18, 87, 209, 247, 61, 70, 120, 76, 19, 152, 132, 231])
  , u64s := []
  , cursorBefore := { stateWords := [15642439619923443, 45028563024208512, 7518382, 8453740008147120415, 6979412999780891539, 577455515313918828, 16131038695622428852, 5173994843640728666], absorbed := 3 }
  , cursorAfter := { stateWords := [5181418443105232, 21524341312704855, 3884226579, 16025574383039273646, 13256995863280240603, 1918059058719304446, 6436782240809769697, 11503317375494532065], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [1, 247, 115, 215, 23, 1, 108, 230, 175, 167, 73, 98, 183, 3, 79, 83, 190, 97, 204, 144, 79, 106, 207, 121, 17, 21, 75, 132, 7, 147, 140, 111])
  , u64s := []
  , cursorBefore := { stateWords := [5181418443105232, 21524341312704855, 3884226579, 16025574383039273646, 13256995863280240603, 1918059058719304446, 6436782240809769697, 11503317375494532065], absorbed := 3 }
  , cursorAfter := { stateWords := [22395730647733071, 37237250785398634, 1871483655, 11729623726878119526, 18264761168511554550, 10337290128883049922, 1618482010682628583, 17010165591468757266], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [22395730647733071, 37237250785398634, 1871483655, 11729623726878119526, 18264761168511554550, 10337290128883049922, 1618482010682628583, 17010165591468757266], absorbed := 3 }
  , cursorAfter := { stateWords := [15711142033001630324, 4134151270888011781, 13431836156901815533, 16491183845168824840, 9933720971416121710, 1904543339923196549, 10946279722588893383, 5822108707308381839], absorbed := 0 }
  , challengeOutput := (some 15711142033001630324)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [15711142033001630324, 4134151270888011781, 13431836156901815533, 16491183845168824840, 9933720971416121710, 1904543339923196549, 10946279722588893383, 5822108707308381839], absorbed := 0 }
  , cursorAfter := { stateWords := [7440003438911721974, 9094600317903300197, 2490998226023277318, 3776144570464026249, 14964218005992433550, 10701830863539091962, 2846698840040576937, 17077938386530220705], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [246, 145, 4, 120, 181, 51, 64, 103, 101, 230, 199, 202, 205, 130, 54, 126, 6, 227, 62, 78, 176, 205, 145, 34, 137, 62, 7, 223, 122, 143, 103, 52]))
}]
}
  , kernel := {
  root0Digest := (bytes [228, 98, 148, 141, 173, 208, 81, 252, 147, 68, 207, 191, 208, 77, 9, 104, 120, 204, 161, 231, 192, 35, 84, 44, 52, 102, 68, 156, 128, 207, 202, 141])
  , stage1Digest := (bytes [248, 83, 178, 47, 183, 64, 167, 213, 46, 91, 10, 99, 62, 110, 132, 116, 93, 93, 226, 16, 211, 156, 232, 54, 142, 211, 84, 128, 80, 117, 85, 150])
  , stage2Digest := (bytes [196, 71, 198, 8, 146, 145, 167, 84, 220, 161, 107, 98, 85, 177, 210, 218, 174, 250, 41, 0, 144, 47, 208, 110, 33, 168, 235, 189, 138, 191, 255, 150])
  , stage3Digest := (bytes [13, 62, 18, 231, 159, 216, 74, 146, 123, 100, 48, 154, 55, 62, 243, 77, 247, 72, 183, 146, 55, 128, 226, 205, 79, 61, 249, 159, 174, 184, 114, 0])
  , executionDigest := (bytes [211, 235, 172, 239, 219, 81, 4, 198, 152, 115, 67, 102, 208, 155, 208, 227, 187, 253, 120, 104, 18, 87, 209, 247, 61, 70, 120, 76, 19, 152, 132, 231])
  , finalStateDigest := (bytes [1, 247, 115, 215, 23, 1, 108, 230, 175, 167, 73, 98, 183, 3, 79, 83, 190, 97, 204, 144, 79, 106, 207, 121, 17, 21, 75, 132, 7, 147, 140, 111])
  , stage1Mix := 16632802919108710147
  , stage2RegMix := 6139558469011796608
  , stage2RamMix := 17659153299687098721
  , stage3ContinuityMix := 9836651665554253514
  , kernelFinalMix := 15711142033001630324
  , transcriptFinalDigest := (bytes [246, 145, 4, 120, 181, 51, 64, 103, 101, 230, 199, 202, 205, 130, 54, 126, 6, 227, 62, 78, 176, 205, 145, 34, 137, 62, 7, 223, 122, 143, 103, 52])
  , finalPc := 28
  , finalRegisters := [0, 1, 18446744071562067968, 18446744071562067968, 134217728, 18446744073575333888, 40, 256, 8388608, 18446744073701163008, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , finalMemory := []
  , halted := true
}
}

end Nightstream.Rv64IM.Generated.Cases.Case_native_word_shift_chain_ecall
