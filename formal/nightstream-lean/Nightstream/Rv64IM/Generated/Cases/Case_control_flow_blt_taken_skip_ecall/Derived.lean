import Nightstream.Rv64IM.Generated.ParityTypes

namespace Nightstream.Rv64IM.Generated.Cases.Case_control_flow_blt_taken_skip_ecall

open Nightstream.Rv64IM.Generated

def derivedCase : ParityDerivedCase :=
  {
  manifest := { name := "control_flow_blt_taken_skip_ecall", fixtureId := "control_flow_blt_taken_skip_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.controlFlow, .nativeAlu] }
  , executionRows := [{
  traceIndex := 0
  , stepIndex := 0
  , sequenceIndex := 0
  , pc := 0
  , nextPc := 4
  , word := 4293918867
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
  , word := 1048851
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
  traceIndex := 2
  , stepIndex := 2
  , sequenceIndex := 0
  , pc := 8
  , nextPc := 16
  , word := 2147427
  , opcode := .blt
  , traceOpcode := (some .blt)
  , traceVirtualOpcode := none
  , family := .controlFlow
  , rs1 := 1
  , rs1Value := 18446744073709551615
  , rs2 := 2
  , rs2Value := 1
  , rd := 0
  , rdBefore := 0
  , rdAfter := 0
  , imm := 8
  , aluResult := 1
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
  traceIndex := 3
  , stepIndex := 3
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
  , stage1 := { rows := [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 4293918867, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 4, aluResult := 18446744073709551615, effectiveAddr := none, writesRd := true, rd := 1, rdAfter := 18446744073709551615, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 1048851, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 8, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 2, rdAfter := 1, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 2147427, opcode := .blt, traceOpcode := (some .blt), traceVirtualOpcode := none, family := .controlFlow, nextPc := 16, aluResult := 1, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 16, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 20, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }] }
  , stage2 := {
  registerReads := [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 0, value := 0 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 0, value := 0 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 1, value := 18446744073709551615 }, { traceIndex := 2, stepIndex := 2, role := .rs2, reg := 2, value := 1 }]
  , registerWrites := [{ traceIndex := 0, stepIndex := 0, reg := 1, previous := 0, next := 18446744073709551615 }, { traceIndex := 1, stepIndex := 1, reg := 2, previous := 0, next := 1 }]
  , ramEvents := []
  , twistLinks := [{ traceIndex := 0, stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 1, family := .nativeAlu, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 2, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 3, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]
}
  , stage3 := {
  continuity := [{ stepIndex := 0, pc := 0, nextPc := 4, successorPc := (some 4), finalStep := false, continuityHolds := true }, { stepIndex := 1, pc := 4, nextPc := 8, successorPc := (some 8), finalStep := false, continuityHolds := true }, { stepIndex := 2, pc := 8, nextPc := 16, successorPc := (some 16), finalStep := false, continuityHolds := true }, { stepIndex := 3, pc := 16, nextPc := 20, successorPc := none, finalStep := true, continuityHolds := true }]
  , halted := true
}
  , transcript := {
  appLabel := (bytes [110, 101, 111, 46, 102, 111, 108, 100, 46, 110, 101, 120, 116, 47, 114, 118, 54, 52, 105, 109, 47, 112, 97, 114, 105, 116, 121, 95, 107, 101, 114, 110, 101, 108, 95, 118, 49])
  , events := [{
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 116, 114, 97, 110, 115, 99, 114, 105, 112, 116, 95, 115, 101, 101, 100])
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 99, 111, 110, 116, 114, 111, 108, 45, 102, 108, 111, 119, 45, 98, 108, 116, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [27634538711377453, 212436087916, 13380622803955469567, 3521951206484747623, 9254679819230523135, 7793219495316757120, 11804775929249192629, 11428962190686586919], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [99, 111, 110, 116, 114, 111, 108, 95, 102, 108, 111, 119, 95, 98, 108, 116, 95, 116, 97, 107, 101, 110, 95, 115, 107, 105, 112, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [27634538711377453, 212436087916, 13380622803955469567, 3521951206484747623, 9254679819230523135, 7793219495316757120, 11804775929249192629, 11428962190686586919], absorbed := 2 }
  , cursorAfter := { stateWords := [465674789733, 7180296237315089499, 11733811407418221658, 16498453394416949328, 14614950331407827170, 386261267250689441, 17895202755823189055, 13656127343008880826], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [4293918867, 1048851, 2147427, 115, 115]
  , cursorBefore := { stateWords := [465674789733, 7180296237315089499, 11733811407418221658, 16498453394416949328, 14614950331407827170, 386261267250689441, 17895202755823189055, 13656127343008880826], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 4342287947480010762, 10770147552220420142, 11196137098178073159, 3410458198267189641, 17053939472173617309, 10618310545408775523, 14632938316382243867], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [0, 4342287947480010762, 10770147552220420142, 11196137098178073159, 3410458198267189641, 17053939472173617309, 10618310545408775523, 14632938316382243867], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 0, 0, 3177119353095704368, 1122698152926025607, 8287482361524826601, 16723245261626599678, 4302150586641423449], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [0, 0, 0, 3177119353095704368, 1122698152926025607, 8287482361524826601, 16723245261626599678, 4302150586641423449], absorbed := 3 }
  , cursorAfter := { stateWords := [0, 8997489801189187788, 9188462323838030656, 3846626849677102628, 493978877708530803, 5797943057098051682, 265212388903239129, 5384776338942354106], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [98, 18, 188, 175, 27, 205, 179, 130, 57, 12, 232, 219, 38, 211, 175, 110, 23, 173, 187, 111, 225, 55, 139, 25, 196, 177, 64, 5, 240, 114, 106, 227])
  , u64s := []
  , cursorBefore := { stateWords := [0, 8997489801189187788, 9188462323838030656, 3846626849677102628, 493978877708530803, 5797943057098051682, 265212388903239129, 5384776338942354106], absorbed := 1 }
  , cursorAfter := { stateWords := [12638052876212445947, 11542696732698544447, 18007394215398869016, 14068469168916825873, 16931571443844531563, 6599354317457268593, 17714847696491555142, 1851216477043460655], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [12638052876212445947, 11542696732698544447, 18007394215398869016, 14068469168916825873, 16931571443844531563, 6599354317457268593, 17714847696491555142, 1851216477043460655], absorbed := 0 }
  , cursorAfter := { stateWords := [16644640469157671253, 6345635710436128953, 8972926169320819561, 8802111708820718633, 11586481162637383844, 18409059249488434770, 15588410963579079596, 16258969875057624872], absorbed := 0 }
  , challengeOutput := (some 16644640469157671253)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [17, 173, 35, 176, 52, 237, 183, 61, 86, 195, 142, 108, 204, 29, 120, 209, 90, 254, 172, 22, 131, 169, 195, 218, 54, 196, 115, 33, 141, 248, 85, 89])
  , u64s := []
  , cursorBefore := { stateWords := [16644640469157671253, 6345635710436128953, 8972926169320819561, 8802111708820718633, 11586481162637383844, 18409059249488434770, 15588410963579079596, 16258969875057624872], absorbed := 0 }
  , cursorAfter := { stateWords := [36898154206646648, 9415960802542505, 1498806413, 9072776052887572135, 11721581926632944754, 3535138222753818749, 6273687341861194554, 8882264780997456134], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [36898154206646648, 9415960802542505, 1498806413, 9072776052887572135, 11721581926632944754, 3535138222753818749, 6273687341861194554, 8882264780997456134], absorbed := 3 }
  , cursorAfter := { stateWords := [1411288425859349507, 4187811786765448679, 2899879548899209826, 12708691591653258630, 12167309891279697045, 2700363555137302011, 2186034203693546282, 13447575716582957255], absorbed := 0 }
  , challengeOutput := (some 1411288425859349507)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [1411288425859349507, 4187811786765448679, 2899879548899209826, 12708691591653258630, 12167309891279697045, 2700363555137302011, 2186034203693546282, 13447575716582957255], absorbed := 0 }
  , cursorAfter := { stateWords := [10716973488349051482, 3868992218345858838, 12653624167884364434, 6196821790445151857, 6347444349010254889, 7408501223560603604, 16906200941066870330, 18076423091780357662], absorbed := 0 }
  , challengeOutput := (some 10716973488349051482)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [113, 106, 8, 108, 18, 192, 96, 184, 164, 166, 127, 255, 228, 167, 133, 127, 188, 165, 129, 20, 7, 71, 150, 61, 35, 41, 236, 246, 45, 79, 63, 14])
  , u64s := []
  , cursorBefore := { stateWords := [10716973488349051482, 3868992218345858838, 12653624167884364434, 6196821790445151857, 6347444349010254889, 7408501223560603604, 16906200941066870330, 18076423091780357662], absorbed := 0 }
  , cursorAfter := { stateWords := [1992871900905349, 69502505699874375, 239030061, 449049874361303726, 13278269026255423333, 16025667103406807846, 11359412951690612528, 1030809117376067969], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [1992871900905349, 69502505699874375, 239030061, 449049874361303726, 13278269026255423333, 16025667103406807846, 11359412951690612528, 1030809117376067969], absorbed := 3 }
  , cursorAfter := { stateWords := [7080673056785947620, 10323909872972385627, 3294867110705849055, 17575164267868533637, 12557480519429552349, 12862571481398172470, 16561057601711089821, 2428372152698216523], absorbed := 0 }
  , challengeOutput := (some 7080673056785947620)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [198, 81, 7, 250, 152, 135, 65, 159, 231, 42, 117, 161, 26, 121, 63, 197, 123, 212, 231, 113, 35, 37, 159, 177, 226, 104, 247, 68, 136, 30, 16, 163])
  , u64s := []
  , cursorBefore := { stateWords := [7080673056785947620, 10323909872972385627, 3294867110705849055, 17575164267868533637, 12557480519429552349, 12862571481398172470, 16561057601711089821, 2428372152698216523], absorbed := 0 }
  , cursorAfter := { stateWords := [9976864701138239, 19412328268275493, 2735742600, 4961504159926370359, 14655189360590489950, 14059714068881444742, 14349289097047773731, 16140683775358900588], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [46, 32, 12, 1, 169, 11, 60, 230, 125, 5, 123, 127, 177, 78, 153, 53, 25, 114, 127, 17, 26, 141, 196, 196, 80, 189, 184, 59, 120, 244, 188, 221])
  , u64s := []
  , cursorBefore := { stateWords := [9976864701138239, 19412328268275493, 2735742600, 4961504159926370359, 14655189360590489950, 14059714068881444742, 14349289097047773731, 16140683775358900588], absorbed := 3 }
  , cursorAfter := { stateWords := [7337588467250585, 16810146869331085, 3720148088, 437345699824599267, 3522153810974739236, 14925937994573417365, 152522263272405329, 10141347386645065159], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [103, 119, 166, 83, 71, 235, 116, 157, 66, 6, 65, 91, 76, 196, 146, 226, 246, 68, 215, 2, 4, 30, 194, 108, 206, 35, 183, 164, 172, 191, 117, 48])
  , u64s := []
  , cursorBefore := { stateWords := [7337588467250585, 16810146869331085, 3720148088, 437345699824599267, 3522153810974739236, 14925937994573417365, 152522263272405329, 10141347386645065159], absorbed := 3 }
  , cursorAfter := { stateWords := [1129023505097362, 46363260595520030, 813023148, 12846192668686633647, 6741557979578876315, 5327271313024723108, 1204975810469412893, 2852815224866682480], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [1129023505097362, 46363260595520030, 813023148, 12846192668686633647, 6741557979578876315, 5327271313024723108, 1204975810469412893, 2852815224866682480], absorbed := 3 }
  , cursorAfter := { stateWords := [2909462562917863239, 9929399740580202738, 13577020951539415088, 17670864534221122448, 9593501634175910908, 6516463136653550587, 7536639024974644756, 5816055747239020741], absorbed := 0 }
  , challengeOutput := (some 2909462562917863239)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [2909462562917863239, 9929399740580202738, 13577020951539415088, 17670864534221122448, 9593501634175910908, 6516463136653550587, 7536639024974644756, 5816055747239020741], absorbed := 0 }
  , cursorAfter := { stateWords := [8458312616683964279, 7234767995085141651, 10042222849210223382, 4528594096167961680, 9166438756173917332, 17489391845004188911, 12640545817216988034, 14193716235814182519], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [119, 7, 167, 196, 130, 246, 97, 117, 147, 54, 106, 251, 40, 15, 103, 100, 22, 139, 124, 178, 121, 36, 93, 139, 80, 196, 5, 66, 86, 204, 216, 62]))
}]
}
  , kernel := {
  root0Digest := (bytes [98, 18, 188, 175, 27, 205, 179, 130, 57, 12, 232, 219, 38, 211, 175, 110, 23, 173, 187, 111, 225, 55, 139, 25, 196, 177, 64, 5, 240, 114, 106, 227])
  , stage1Digest := (bytes [17, 173, 35, 176, 52, 237, 183, 61, 86, 195, 142, 108, 204, 29, 120, 209, 90, 254, 172, 22, 131, 169, 195, 218, 54, 196, 115, 33, 141, 248, 85, 89])
  , stage2Digest := (bytes [113, 106, 8, 108, 18, 192, 96, 184, 164, 166, 127, 255, 228, 167, 133, 127, 188, 165, 129, 20, 7, 71, 150, 61, 35, 41, 236, 246, 45, 79, 63, 14])
  , stage3Digest := (bytes [198, 81, 7, 250, 152, 135, 65, 159, 231, 42, 117, 161, 26, 121, 63, 197, 123, 212, 231, 113, 35, 37, 159, 177, 226, 104, 247, 68, 136, 30, 16, 163])
  , executionDigest := (bytes [46, 32, 12, 1, 169, 11, 60, 230, 125, 5, 123, 127, 177, 78, 153, 53, 25, 114, 127, 17, 26, 141, 196, 196, 80, 189, 184, 59, 120, 244, 188, 221])
  , finalStateDigest := (bytes [103, 119, 166, 83, 71, 235, 116, 157, 66, 6, 65, 91, 76, 196, 146, 226, 246, 68, 215, 2, 4, 30, 194, 108, 206, 35, 183, 164, 172, 191, 117, 48])
  , stage1Mix := 16644640469157671253
  , stage2RegMix := 1411288425859349507
  , stage2RamMix := 10716973488349051482
  , stage3ContinuityMix := 7080673056785947620
  , kernelFinalMix := 2909462562917863239
  , transcriptFinalDigest := (bytes [119, 7, 167, 196, 130, 246, 97, 117, 147, 54, 106, 251, 40, 15, 103, 100, 22, 139, 124, 178, 121, 36, 93, 139, 80, 196, 5, 66, 86, 204, 216, 62])
  , finalPc := 20
  , finalRegisters := [0, 18446744073709551615, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , finalMemory := []
  , halted := true
}
}

end Nightstream.Rv64IM.Generated.Cases.Case_control_flow_blt_taken_skip_ecall
