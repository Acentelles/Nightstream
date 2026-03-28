import Nightstream.Rv64IM.Generated.ParityTypes

namespace Nightstream.Rv64IM.Generated.Cases.Case_native_word_arith_chain_ecall

open Nightstream.Rv64IM.Generated

def derivedCase : ParityDerivedCase :=
  {
  manifest := { name := "native_word_arith_chain_ecall", fixtureId := "native_word_arith_chain_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , executionRows := [{
  traceIndex := 0
  , stepIndex := 0
  , sequenceIndex := 0
  , pc := 0
  , nextPc := 4
  , word := 4293918875
  , opcode := .addiw
  , traceOpcode := (some .addiw)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 0
  , rs1Value := 0
  , rs2 := 0
  , rs2Value := 0
  , rd := 1
  , rdBefore := 0
  , rdAfter := 18446744073709551615
  , imm := -1
  , aluResult := 18446744073709551615
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
  , word := 2130203
  , opcode := .addiw
  , traceOpcode := (some .addiw)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 18446744073709551615
  , rs2 := 0
  , rs2Value := 0
  , rd := 2
  , rdBefore := 0
  , rdAfter := 1
  , imm := 2
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
  traceIndex := 2
  , stepIndex := 2
  , sequenceIndex := 0
  , pc := 8
  , nextPc := 12
  , word := 4293563
  , opcode := .addw
  , traceOpcode := (some .addw)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 3
  , rs1Value := 2147483647
  , rs2 := 4
  , rs2Value := 2
  , rd := 7
  , rdBefore := 0
  , rdAfter := 18446744071562067969
  , imm := 0
  , aluResult := 18446744071562067969
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
  , word := 1080198203
  , opcode := .subw
  , traceOpcode := (some .subw)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 5
  , rs1Value := 0
  , rs2 := 6
  , rs2Value := 1
  , rd := 8
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
  , stage1 := { rows := [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 4293918875, opcode := .addiw, traceOpcode := (some .addiw), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 4, aluResult := 18446744073709551615, effectiveAddr := none, writesRd := true, rd := 1, rdAfter := 18446744073709551615, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 2130203, opcode := .addiw, traceOpcode := (some .addiw), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 8, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 2, rdAfter := 1, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 4293563, opcode := .addw, traceOpcode := (some .addw), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 12, aluResult := 18446744071562067969, effectiveAddr := none, writesRd := true, rd := 7, rdAfter := 18446744071562067969, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 12, fetchedWord := 1080198203, opcode := .subw, traceOpcode := (some .subw), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 16, aluResult := 18446744073709551615, effectiveAddr := none, writesRd := true, rd := 8, rdAfter := 18446744073709551615, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 4, stepIndex := 4, sequenceIndex := 0, fetchPc := 16, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 20, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }] }
  , stage2 := {
  registerReads := [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 0, value := 0 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 1, value := 18446744073709551615 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 3, value := 2147483647 }, { traceIndex := 2, stepIndex := 2, role := .rs2, reg := 4, value := 2 }, { traceIndex := 3, stepIndex := 3, role := .rs1, reg := 5, value := 0 }, { traceIndex := 3, stepIndex := 3, role := .rs2, reg := 6, value := 1 }]
  , registerWrites := [{ traceIndex := 0, stepIndex := 0, reg := 1, previous := 0, next := 18446744073709551615 }, { traceIndex := 1, stepIndex := 1, reg := 2, previous := 0, next := 1 }, { traceIndex := 2, stepIndex := 2, reg := 7, previous := 0, next := 18446744071562067969 }, { traceIndex := 3, stepIndex := 3, reg := 8, previous := 0, next := 18446744073709551615 }]
  , ramEvents := []
  , twistLinks := [{ traceIndex := 0, stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 1, family := .nativeAlu, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 2, family := .nativeAlu, routedWriteValue := (some 18446744071562067969), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 3, family := .nativeAlu, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 4, stepIndex := 4, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]
}
  , stage3 := {
  continuity := [{ stepIndex := 0, pc := 0, nextPc := 4, successorPc := (some 4), finalStep := false, continuityHolds := true }, { stepIndex := 1, pc := 4, nextPc := 8, successorPc := (some 8), finalStep := false, continuityHolds := true }, { stepIndex := 2, pc := 8, nextPc := 12, successorPc := (some 12), finalStep := false, continuityHolds := true }, { stepIndex := 3, pc := 12, nextPc := 16, successorPc := (some 16), finalStep := false, continuityHolds := true }, { stepIndex := 4, pc := 16, nextPc := 20, successorPc := none, finalStep := true, continuityHolds := true }]
  , halted := true
}
  , transcript := {
  appLabel := (bytes [110, 101, 111, 46, 102, 111, 108, 100, 46, 110, 101, 120, 116, 47, 114, 118, 54, 52, 105, 109, 47, 112, 97, 114, 105, 116, 121, 95, 107, 101, 114, 110, 101, 108, 95, 118, 49])
  , events := [{
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 116, 114, 97, 110, 115, 99, 114, 105, 112, 116, 95, 115, 101, 101, 100])
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 110, 97, 116, 105, 118, 101, 45, 119, 111, 114, 100, 45, 97, 114, 105, 116, 104, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [32194994931658615, 54383637722217, 94828755958258816, 10905788041622594868, 8841251816071870994, 13391653407446453246, 17446101127387435910, 7137168547377178156], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [110, 97, 116, 105, 118, 101, 95, 119, 111, 114, 100, 95, 97, 114, 105, 116, 104, 95, 99, 104, 97, 105, 110, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [32194994931658615, 54383637722217, 94828755958258816, 10905788041622594868, 8841251816071870994, 13391653407446453246, 17446101127387435910, 7137168547377178156], absorbed := 2 }
  , cursorAfter := { stateWords := [108, 8046472682260722215, 11003244355940537497, 8262967534387851701, 397115538058000933, 14291341217137120322, 5063051282974981007, 6543922063873665818], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [4293918875, 2130203, 4293563, 1080198203, 115]
  , cursorBefore := { stateWords := [108, 8046472682260722215, 11003244355940537497, 8262967534387851701, 397115538058000933, 14291341217137120322, 5063051282974981007, 6543922063873665818], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 6311794259304343875, 786608718250716959, 6100874164208755578, 2245851268550729477, 2299296669935983130, 2102865596656109285, 12771573547685203882], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 0, 0, 2147483647, 2, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [0, 6311794259304343875, 786608718250716959, 6100874164208755578, 2245851268550729477, 2299296669935983130, 2102865596656109285, 12771573547685203882], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 0, 0, 7729746327826397575, 6599925485313333755, 9380419606129479895, 6316302456827070885, 16537807392675284847], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [0, 0, 0, 7729746327826397575, 6599925485313333755, 9380419606129479895, 6316302456827070885, 16537807392675284847], absorbed := 3 }
  , cursorAfter := { stateWords := [0, 12812810021020622332, 16771512372732572291, 17691475649520698636, 7640299194629275762, 10369745949424242134, 17621312550387929647, 16140505857922087759], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [92, 172, 22, 138, 218, 1, 129, 66, 224, 89, 66, 175, 77, 144, 188, 74, 225, 81, 33, 159, 113, 152, 248, 210, 237, 253, 25, 73, 246, 251, 115, 40])
  , u64s := []
  , cursorBefore := { stateWords := [0, 12812810021020622332, 16771512372732572291, 17691475649520698636, 7640299194629275762, 10369745949424242134, 17621312550387929647, 16140505857922087759], absorbed := 1 }
  , cursorAfter := { stateWords := [7954902538515988277, 304032984545023206, 10859090316681308649, 1051498967781084287, 15597103504361850509, 7639111287890164627, 1032102716464711104, 4950509479344129651], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [7954902538515988277, 304032984545023206, 10859090316681308649, 1051498967781084287, 15597103504361850509, 7639111287890164627, 1032102716464711104, 4950509479344129651], absorbed := 0 }
  , cursorAfter := { stateWords := [10558873659545640745, 7460298059074088280, 12827188633621840837, 16788346924928290626, 9765819397153587279, 79730547694703652, 6899519008508010761, 18355073430232124729], absorbed := 0 }
  , challengeOutput := (some 10558873659545640745)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [49, 161, 13, 124, 3, 254, 251, 63, 149, 85, 118, 87, 149, 41, 33, 106, 239, 224, 235, 122, 124, 115, 70, 243, 63, 43, 7, 106, 43, 13, 29, 169])
  , u64s := []
  , cursorBefore := { stateWords := [10558873659545640745, 7460298059074088280, 12827188633621840837, 16788346924928290626, 9765819397153587279, 79730547694703652, 6899519008508010761, 18355073430232124729], absorbed := 0 }
  , cursorAfter := { stateWords := [35038050621811233, 29844229869225587, 2837253419, 14854758017280570924, 4753849291562509336, 17737008842207180361, 10221970253532858519, 13455280429100110128], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [35038050621811233, 29844229869225587, 2837253419, 14854758017280570924, 4753849291562509336, 17737008842207180361, 10221970253532858519, 13455280429100110128], absorbed := 3 }
  , cursorAfter := { stateWords := [8944266866017282416, 9083455127191587360, 15870788478240046116, 261411158637596961, 13497636338210299392, 7056894553339275005, 3922081986380945488, 7961356374822133845], absorbed := 0 }
  , challengeOutput := (some 8944266866017282416)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [8944266866017282416, 9083455127191587360, 15870788478240046116, 261411158637596961, 13497636338210299392, 7056894553339275005, 3922081986380945488, 7961356374822133845], absorbed := 0 }
  , cursorAfter := { stateWords := [13660259816919425627, 5443145891308723178, 3950869399485430737, 3465726298619999636, 17114001414304282808, 18361815826803384454, 11206596754129769351, 1492281674423093212], absorbed := 0 }
  , challengeOutput := (some 13660259816919425627)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [76, 67, 196, 204, 58, 160, 47, 32, 132, 98, 117, 189, 46, 75, 241, 54, 49, 21, 50, 72, 228, 63, 229, 152, 90, 2, 115, 124, 210, 7, 178, 52])
  , u64s := []
  , cursorBefore := { stateWords := [13660259816919425627, 5443145891308723178, 3950869399485430737, 3465726298619999636, 17114001414304282808, 18361815826803384454, 11206596754129769351, 1492281674423093212], absorbed := 0 }
  , cursorAfter := { stateWords := [64255674631141105, 35029351059219775, 884082642, 10963030985313958329, 9231525161699478297, 7184243167855036890, 4915572341140035318, 1204668759425625746], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [64255674631141105, 35029351059219775, 884082642, 10963030985313958329, 9231525161699478297, 7184243167855036890, 4915572341140035318, 1204668759425625746], absorbed := 3 }
  , cursorAfter := { stateWords := [17263612136838009662, 13675245253044482734, 18189201110177164880, 10969121987671422452, 5530659556502629132, 756279455560595800, 13966163538592164266, 5192032729948296536], absorbed := 0 }
  , challengeOutput := (some 17263612136838009662)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [2, 183, 132, 95, 231, 115, 83, 2, 8, 179, 51, 169, 210, 224, 230, 178, 60, 35, 73, 58, 195, 121, 109, 163, 86, 206, 95, 244, 250, 18, 169, 79])
  , u64s := []
  , cursorBefore := { stateWords := [17263612136838009662, 13675245253044482734, 18189201110177164880, 10969121987671422452, 5530659556502629132, 756279455560595800, 13966163538592164266, 5192032729948296536], absorbed := 0 }
  , cursorAfter := { stateWords := [54951706256782054, 68785234138852729, 1336480506, 5717146340749330168, 6508766975942125165, 17493974153028014702, 15761774315220503075, 2603304443319835626], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [12, 149, 33, 173, 171, 165, 54, 175, 9, 253, 234, 193, 13, 243, 189, 0, 121, 246, 75, 0, 67, 138, 71, 71, 204, 153, 161, 108, 26, 195, 251, 119])
  , u64s := []
  , cursorBefore := { stateWords := [54951706256782054, 68785234138852729, 1336480506, 5717146340749330168, 6508766975942125165, 17493974153028014702, 15761774315220503075, 2603304443319835626], absorbed := 3 }
  , cursorAfter := { stateWords := [18859149697286333, 30576979414042506, 2012988186, 7418949465302731250, 7786578273095239209, 5462410187322239503, 2647912887876074060, 3741130172918810497], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [210, 76, 200, 21, 4, 69, 15, 25, 203, 33, 125, 2, 33, 189, 7, 17, 57, 53, 132, 53, 135, 156, 153, 112, 132, 50, 0, 120, 169, 124, 149, 40])
  , u64s := []
  , cursorBefore := { stateWords := [18859149697286333, 30576979414042506, 2012988186, 7418949465302731250, 7786578273095239209, 5462410187322239503, 2647912887876074060, 3741130172918810497], absorbed := 3 }
  , cursorAfter := { stateWords := [38057963800826119, 33777214175615388, 680885417, 338818507502728935, 10922502945274482062, 3756922488108390693, 4388242078426305734, 50998364504691158], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [38057963800826119, 33777214175615388, 680885417, 338818507502728935, 10922502945274482062, 3756922488108390693, 4388242078426305734, 50998364504691158], absorbed := 3 }
  , cursorAfter := { stateWords := [1122637793534170640, 8865404261055412735, 15682186193226367635, 11087978790780904066, 10088335413447909684, 12063018804202447092, 7846450942697976053, 17981690237755468257], absorbed := 0 }
  , challengeOutput := (some 1122637793534170640)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [1122637793534170640, 8865404261055412735, 15682186193226367635, 11087978790780904066, 10088335413447909684, 12063018804202447092, 7846450942697976053, 17981690237755468257], absorbed := 0 }
  , cursorAfter := { stateWords := [17984682559556005781, 6806124958797347119, 3740396972043565589, 8535075898710175415, 13795396721678529870, 8029699745718555254, 13832823551608342223, 14647473703533060395], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [149, 175, 127, 64, 128, 109, 150, 249, 47, 57, 9, 242, 150, 54, 116, 94, 21, 122, 154, 133, 58, 143, 232, 51, 183, 46, 158, 33, 79, 174, 114, 118]))
}]
}
  , kernel := {
  root0Digest := (bytes [92, 172, 22, 138, 218, 1, 129, 66, 224, 89, 66, 175, 77, 144, 188, 74, 225, 81, 33, 159, 113, 152, 248, 210, 237, 253, 25, 73, 246, 251, 115, 40])
  , stage1Digest := (bytes [49, 161, 13, 124, 3, 254, 251, 63, 149, 85, 118, 87, 149, 41, 33, 106, 239, 224, 235, 122, 124, 115, 70, 243, 63, 43, 7, 106, 43, 13, 29, 169])
  , stage2Digest := (bytes [76, 67, 196, 204, 58, 160, 47, 32, 132, 98, 117, 189, 46, 75, 241, 54, 49, 21, 50, 72, 228, 63, 229, 152, 90, 2, 115, 124, 210, 7, 178, 52])
  , stage3Digest := (bytes [2, 183, 132, 95, 231, 115, 83, 2, 8, 179, 51, 169, 210, 224, 230, 178, 60, 35, 73, 58, 195, 121, 109, 163, 86, 206, 95, 244, 250, 18, 169, 79])
  , executionDigest := (bytes [12, 149, 33, 173, 171, 165, 54, 175, 9, 253, 234, 193, 13, 243, 189, 0, 121, 246, 75, 0, 67, 138, 71, 71, 204, 153, 161, 108, 26, 195, 251, 119])
  , finalStateDigest := (bytes [210, 76, 200, 21, 4, 69, 15, 25, 203, 33, 125, 2, 33, 189, 7, 17, 57, 53, 132, 53, 135, 156, 153, 112, 132, 50, 0, 120, 169, 124, 149, 40])
  , stage1Mix := 10558873659545640745
  , stage2RegMix := 8944266866017282416
  , stage2RamMix := 13660259816919425627
  , stage3ContinuityMix := 17263612136838009662
  , kernelFinalMix := 1122637793534170640
  , transcriptFinalDigest := (bytes [149, 175, 127, 64, 128, 109, 150, 249, 47, 57, 9, 242, 150, 54, 116, 94, 21, 122, 154, 133, 58, 143, 232, 51, 183, 46, 158, 33, 79, 174, 114, 118])
  , finalPc := 20
  , finalRegisters := [0, 18446744073709551615, 1, 2147483647, 2, 0, 1, 18446744071562067969, 18446744073709551615, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , finalMemory := []
  , halted := true
}
}

end Nightstream.Rv64IM.Generated.Cases.Case_native_word_arith_chain_ecall
