import Nightstream.Rv64IM.Generated.ParityTypes

namespace Nightstream.Rv64IM.Generated.Cases.Case_control_flow_bltu_taken_skip_ecall

open Nightstream.Rv64IM.Generated

def derivedCase : ParityDerivedCase :=
  {
  manifest := { name := "control_flow_bltu_taken_skip_ecall", fixtureId := "control_flow_bltu_taken_skip_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.controlFlow, .nativeAlu] }
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
  , word := 2097427
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
  , rdAfter := 2
  , imm := 2
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
  traceIndex := 2
  , stepIndex := 2
  , sequenceIndex := 0
  , pc := 8
  , nextPc := 16
  , word := 2155619
  , opcode := .bltu
  , traceOpcode := (some .bltu)
  , traceVirtualOpcode := none
  , family := .controlFlow
  , rs1 := 1
  , rs1Value := 1
  , rs2 := 2
  , rs2Value := 2
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
  , stage1 := { rows := [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 1048723, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 4, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 1, rdAfter := 1, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 2097427, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 8, aluResult := 2, effectiveAddr := none, writesRd := true, rd := 2, rdAfter := 2, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 2155619, opcode := .bltu, traceOpcode := (some .bltu), traceVirtualOpcode := none, family := .controlFlow, nextPc := 16, aluResult := 1, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 16, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 20, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }] }
  , stage2 := {
  registerReads := [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 0, value := 0 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 0, value := 0 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 1, value := 1 }, { traceIndex := 2, stepIndex := 2, role := .rs2, reg := 2, value := 2 }]
  , registerWrites := [{ traceIndex := 0, stepIndex := 0, reg := 1, previous := 0, next := 1 }, { traceIndex := 1, stepIndex := 1, reg := 2, previous := 0, next := 2 }]
  , ramEvents := []
  , twistLinks := [{ traceIndex := 0, stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 1, family := .nativeAlu, routedWriteValue := (some 2), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 2, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 3, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]
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
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 99, 111, 110, 116, 114, 111, 108, 45, 102, 108, 111, 119, 45, 98, 108, 116, 117, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [27634538711377453, 54383638574188, 1823709644592138771, 15695669540104460710, 8188744055654938720, 6008164579518882152, 10584698648648697023, 6532369056394176230], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [99, 111, 110, 116, 114, 111, 108, 95, 102, 108, 111, 119, 95, 98, 108, 116, 117, 95, 116, 97, 107, 101, 110, 95, 115, 107, 105, 112, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [27634538711377453, 54383638574188, 1823709644592138771, 15695669540104460710, 8188744055654938720, 6008164579518882152, 10584698648648697023, 6532369056394176230], absorbed := 2 }
  , cursorAfter := { stateWords := [119212746171743, 12208028352350156733, 13116747255023234155, 14361117635213581249, 10512020492052434381, 12419906133025396461, 15979211480460189741, 1777931489941413951], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [1048723, 2097427, 2155619, 115, 115]
  , cursorBefore := { stateWords := [119212746171743, 12208028352350156733, 13116747255023234155, 14361117635213581249, 10512020492052434381, 12419906133025396461, 15979211480460189741, 1777931489941413951], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 16397939035672565642, 11641441053675113354, 16521885663412804258, 3932218136266550266, 5914036218258353172, 16396554047951467107, 194808442544638140], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [0, 16397939035672565642, 11641441053675113354, 16521885663412804258, 3932218136266550266, 5914036218258353172, 16396554047951467107, 194808442544638140], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 0, 0, 881487480932087110, 12013070208049965127, 13175601915555830455, 15818305995734650527, 17566464973142032050], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [0, 0, 0, 881487480932087110, 12013070208049965127, 13175601915555830455, 15818305995734650527, 17566464973142032050], absorbed := 3 }
  , cursorAfter := { stateWords := [0, 5659295860271643948, 17196621751330026985, 11816108413138352063, 7731328996701478098, 2208618711023935331, 5184172702489234712, 4012119732739570676], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [129, 249, 195, 4, 194, 62, 5, 111, 3, 163, 217, 146, 174, 130, 122, 238, 234, 192, 21, 127, 252, 112, 84, 85, 106, 53, 39, 158, 101, 145, 151, 55])
  , u64s := []
  , cursorBefore := { stateWords := [0, 5659295860271643948, 17196621751330026985, 11816108413138352063, 7731328996701478098, 2208618711023935331, 5184172702489234712, 4012119732739570676], absorbed := 1 }
  , cursorAfter := { stateWords := [4092868761203551035, 5735683149795635746, 16451237304497144096, 15660729885261835049, 4993037928439025236, 4058496521599560720, 1830960361648420361, 3978819030440664472], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [4092868761203551035, 5735683149795635746, 16451237304497144096, 15660729885261835049, 4993037928439025236, 4058496521599560720, 1830960361648420361, 3978819030440664472], absorbed := 0 }
  , cursorAfter := { stateWords := [12597393124285258733, 4007867179351945362, 4850091778944820385, 17991037833033007994, 476015916384254308, 14419281049321754399, 7561257148764249156, 1132223698927151629], absorbed := 0 }
  , challengeOutput := (some 12597393124285258733)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [79, 54, 35, 89, 181, 60, 120, 62, 23, 216, 151, 8, 213, 60, 71, 0, 66, 90, 147, 125, 53, 147, 210, 191, 92, 59, 24, 230, 4, 58, 45, 9])
  , u64s := []
  , cursorBefore := { stateWords := [12597393124285258733, 4007867179351945362, 4850091778944820385, 17991037833033007994, 476015916384254308, 14419281049321754399, 7561257148764249156, 1132223698927151629], absorbed := 0 }
  , cursorAfter := { stateWords := [15056245593604167, 64765887881663123, 153958916, 9997542546738313031, 16853801998999087846, 13982512411198372988, 8554071259391645168, 13108539371935154626], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [15056245593604167, 64765887881663123, 153958916, 9997542546738313031, 16853801998999087846, 13982512411198372988, 8554071259391645168, 13108539371935154626], absorbed := 3 }
  , cursorAfter := { stateWords := [8403032955572713120, 10194722622930340936, 17038147923175873622, 6655223517539784936, 13617601525376964849, 2293126206090744488, 4903383980242401457, 18359890104668421032], absorbed := 0 }
  , challengeOutput := (some 8403032955572713120)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [8403032955572713120, 10194722622930340936, 17038147923175873622, 6655223517539784936, 13617601525376964849, 2293126206090744488, 4903383980242401457, 18359890104668421032], absorbed := 0 }
  , cursorAfter := { stateWords := [6883570667930004418, 4347745747494188624, 16976776541035948748, 5246595802583663249, 222760462322422117, 9882636753605636144, 16541711643128801052, 18376981885606520272], absorbed := 0 }
  , challengeOutput := (some 6883570667930004418)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [59, 77, 145, 209, 31, 130, 112, 69, 30, 34, 112, 204, 73, 72, 47, 51, 247, 164, 118, 200, 178, 22, 87, 88, 74, 116, 115, 132, 88, 127, 97, 100])
  , u64s := []
  , cursorBefore := { stateWords := [6883570667930004418, 4347745747494188624, 16976776541035948748, 5246595802583663249, 222760462322422117, 9882636753605636144, 16541711643128801052, 18376981885606520272], absorbed := 0 }
  , cursorAfter := { stateWords := [50322957753856815, 37281640226510614, 1684111192, 7216131882496189275, 17059082051772819397, 392206444769693843, 6967327010175071487, 2617740938094769044], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [50322957753856815, 37281640226510614, 1684111192, 7216131882496189275, 17059082051772819397, 392206444769693843, 6967327010175071487, 2617740938094769044], absorbed := 3 }
  , cursorAfter := { stateWords := [5434653513256456592, 2019440646099219393, 14502873697191680645, 18414208927306151731, 16466704025794420414, 6222860899880621933, 467525259224987042, 2024518562970414523], absorbed := 0 }
  , challengeOutput := (some 5434653513256456592)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [198, 81, 7, 250, 152, 135, 65, 159, 231, 42, 117, 161, 26, 121, 63, 197, 123, 212, 231, 113, 35, 37, 159, 177, 226, 104, 247, 68, 136, 30, 16, 163])
  , u64s := []
  , cursorBefore := { stateWords := [5434653513256456592, 2019440646099219393, 14502873697191680645, 18414208927306151731, 16466704025794420414, 6222860899880621933, 467525259224987042, 2024518562970414523], absorbed := 0 }
  , cursorAfter := { stateWords := [9976864701138239, 19412328268275493, 2735742600, 8224034729581685552, 14602704957001709965, 14970224487669671009, 12214536921972360220, 8804407349145409156], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [141, 81, 95, 195, 231, 84, 171, 240, 150, 119, 148, 108, 81, 62, 93, 105, 24, 74, 13, 118, 229, 236, 2, 205, 125, 30, 81, 145, 166, 192, 80, 84])
  , u64s := []
  , cursorBefore := { stateWords := [9976864701138239, 19412328268275493, 2735742600, 8224034729581685552, 14602704957001709965, 14970224487669671009, 12214536921972360220, 8804407349145409156], absorbed := 3 }
  , cursorAfter := { stateWords := [64587569116506461, 40903063024501484, 1414578342, 14196438228949969798, 18403734006346840136, 13405937549382790609, 7173023050622960964, 10786742084945241388], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [145, 232, 119, 42, 209, 144, 217, 53, 205, 241, 241, 70, 26, 199, 99, 90, 150, 109, 80, 126, 52, 204, 98, 226, 231, 236, 152, 221, 67, 149, 32, 60])
  , u64s := []
  , cursorBefore := { stateWords := [64587569116506461, 40903063024501484, 1414578342, 14196438228949969798, 18403734006346840136, 13405937549382790609, 7173023050622960964, 10786742084945241388], absorbed := 3 }
  , cursorAfter := { stateWords := [14775582690007651, 62374113123132108, 1008768323, 8094561612940107350, 5686126895398755498, 17866238643063324752, 1175931973497704862, 4453093798857192440], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [14775582690007651, 62374113123132108, 1008768323, 8094561612940107350, 5686126895398755498, 17866238643063324752, 1175931973497704862, 4453093798857192440], absorbed := 3 }
  , cursorAfter := { stateWords := [6072416836816506878, 3629861325522078768, 10966163059651396786, 11527671172202609175, 11198492021099575808, 9824312880916574066, 853475271184614411, 5712062166666301321], absorbed := 0 }
  , challengeOutput := (some 6072416836816506878)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [6072416836816506878, 3629861325522078768, 10966163059651396786, 11527671172202609175, 11198492021099575808, 9824312880916574066, 853475271184614411, 5712062166666301321], absorbed := 0 }
  , cursorAfter := { stateWords := [10555985995699718432, 18223850609000066347, 2758488876129618957, 12960147545075652446, 7628832371191976516, 2123629962868476640, 5111925167032223623, 6695332481206384055], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [32, 9, 174, 199, 85, 101, 126, 146, 43, 45, 60, 37, 147, 31, 232, 252, 13, 140, 146, 138, 4, 31, 72, 38, 94, 151, 226, 196, 134, 177, 219, 179]))
}]
}
  , kernel := {
  root0Digest := (bytes [129, 249, 195, 4, 194, 62, 5, 111, 3, 163, 217, 146, 174, 130, 122, 238, 234, 192, 21, 127, 252, 112, 84, 85, 106, 53, 39, 158, 101, 145, 151, 55])
  , stage1Digest := (bytes [79, 54, 35, 89, 181, 60, 120, 62, 23, 216, 151, 8, 213, 60, 71, 0, 66, 90, 147, 125, 53, 147, 210, 191, 92, 59, 24, 230, 4, 58, 45, 9])
  , stage2Digest := (bytes [59, 77, 145, 209, 31, 130, 112, 69, 30, 34, 112, 204, 73, 72, 47, 51, 247, 164, 118, 200, 178, 22, 87, 88, 74, 116, 115, 132, 88, 127, 97, 100])
  , stage3Digest := (bytes [198, 81, 7, 250, 152, 135, 65, 159, 231, 42, 117, 161, 26, 121, 63, 197, 123, 212, 231, 113, 35, 37, 159, 177, 226, 104, 247, 68, 136, 30, 16, 163])
  , executionDigest := (bytes [141, 81, 95, 195, 231, 84, 171, 240, 150, 119, 148, 108, 81, 62, 93, 105, 24, 74, 13, 118, 229, 236, 2, 205, 125, 30, 81, 145, 166, 192, 80, 84])
  , finalStateDigest := (bytes [145, 232, 119, 42, 209, 144, 217, 53, 205, 241, 241, 70, 26, 199, 99, 90, 150, 109, 80, 126, 52, 204, 98, 226, 231, 236, 152, 221, 67, 149, 32, 60])
  , stage1Mix := 12597393124285258733
  , stage2RegMix := 8403032955572713120
  , stage2RamMix := 6883570667930004418
  , stage3ContinuityMix := 5434653513256456592
  , kernelFinalMix := 6072416836816506878
  , transcriptFinalDigest := (bytes [32, 9, 174, 199, 85, 101, 126, 146, 43, 45, 60, 37, 147, 31, 232, 252, 13, 140, 146, 138, 4, 31, 72, 38, 94, 151, 226, 196, 134, 177, 219, 179])
  , finalPc := 20
  , finalRegisters := [0, 1, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , finalMemory := []
  , halted := true
}
}

end Nightstream.Rv64IM.Generated.Cases.Case_control_flow_bltu_taken_skip_ecall
