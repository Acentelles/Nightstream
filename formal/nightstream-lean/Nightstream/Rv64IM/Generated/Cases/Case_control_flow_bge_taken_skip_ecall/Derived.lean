import Nightstream.Rv64IM.Generated.ParityTypes

namespace Nightstream.Rv64IM.Generated.Cases.Case_control_flow_bge_taken_skip_ecall

open Nightstream.Rv64IM.Generated

def derivedCase : ParityDerivedCase :=
  {
  manifest := { name := "control_flow_bge_taken_skip_ecall", fixtureId := "control_flow_bge_taken_skip_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.controlFlow, .nativeAlu] }
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
  , word := 4293918995
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
  traceIndex := 2
  , stepIndex := 2
  , sequenceIndex := 0
  , pc := 8
  , nextPc := 16
  , word := 2151523
  , opcode := .bge
  , traceOpcode := (some .bge)
  , traceVirtualOpcode := none
  , family := .controlFlow
  , rs1 := 1
  , rs1Value := 1
  , rs2 := 2
  , rs2Value := 18446744073709551615
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
  , stage1 := { rows := [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 1048723, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 4, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 1, rdAfter := 1, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 4293918995, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 8, aluResult := 18446744073709551615, effectiveAddr := none, writesRd := true, rd := 2, rdAfter := 18446744073709551615, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 2151523, opcode := .bge, traceOpcode := (some .bge), traceVirtualOpcode := none, family := .controlFlow, nextPc := 16, aluResult := 1, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 16, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 20, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }] }
  , stage2 := {
  registerReads := [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 0, value := 0 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 0, value := 0 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 1, value := 1 }, { traceIndex := 2, stepIndex := 2, role := .rs2, reg := 2, value := 18446744073709551615 }]
  , registerWrites := [{ traceIndex := 0, stepIndex := 0, reg := 1, previous := 0, next := 1 }, { traceIndex := 1, stepIndex := 1, reg := 2, previous := 0, next := 18446744073709551615 }]
  , ramEvents := []
  , twistLinks := [{ traceIndex := 0, stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 1, family := .nativeAlu, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 2, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 3, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]
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
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 99, 111, 110, 116, 114, 111, 108, 45, 102, 108, 111, 119, 45, 98, 103, 101, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [27634538711377453, 212436084071, 13380622803955469567, 3521951206484747623, 9254679819230523135, 7793219495316757120, 11804775929249192629, 11428962190686586919], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [99, 111, 110, 116, 114, 111, 108, 95, 102, 108, 111, 119, 95, 98, 103, 101, 95, 116, 97, 107, 101, 110, 95, 115, 107, 105, 112, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [27634538711377453, 212436084071, 13380622803955469567, 3521951206484747623, 9254679819230523135, 7793219495316757120, 11804775929249192629, 11428962190686586919], absorbed := 2 }
  , cursorAfter := { stateWords := [465674789733, 15215007983741485913, 1874102496922678124, 15811577226146168675, 12499081103431237419, 6236543849577039589, 18364626348649379228, 9605098834442363174], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [1048723, 4293918995, 2151523, 115, 115]
  , cursorBefore := { stateWords := [465674789733, 15215007983741485913, 1874102496922678124, 15811577226146168675, 12499081103431237419, 6236543849577039589, 18364626348649379228, 9605098834442363174], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 3863308733289208625, 7732092715818731724, 10897732674725557640, 5122957389714755714, 14412050624005899228, 1750636057271584042, 12393219942905639417], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [0, 3863308733289208625, 7732092715818731724, 10897732674725557640, 5122957389714755714, 14412050624005899228, 1750636057271584042, 12393219942905639417], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 0, 0, 16151006258102468094, 8781961033189472703, 12134297468010880506, 14040033356860820732, 5708464117521822575], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [0, 0, 0, 16151006258102468094, 8781961033189472703, 12134297468010880506, 14040033356860820732, 5708464117521822575], absorbed := 3 }
  , cursorAfter := { stateWords := [0, 13274361720229328095, 6743633916125540037, 11091420359420822032, 16156375987694885752, 8426099295295468575, 8641798412692801466, 10646262291278467146], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [72, 152, 175, 61, 117, 151, 32, 177, 71, 104, 246, 95, 143, 151, 74, 89, 231, 218, 126, 100, 152, 157, 138, 113, 5, 107, 158, 151, 6, 22, 95, 167])
  , u64s := []
  , cursorBefore := { stateWords := [0, 13274361720229328095, 6743633916125540037, 11091420359420822032, 16156375987694885752, 8426099295295468575, 8641798412692801466, 10646262291278467146], absorbed := 1 }
  , cursorAfter := { stateWords := [14357883205051597627, 13561141896955339720, 1211624597452199648, 4365701353448657734, 14478822131144684645, 16118358895982733284, 15277660066242757454, 15771106702652292425], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [14357883205051597627, 13561141896955339720, 1211624597452199648, 4365701353448657734, 14478822131144684645, 16118358895982733284, 15277660066242757454, 15771106702652292425], absorbed := 0 }
  , cursorAfter := { stateWords := [6088699767227576722, 12528948519504330862, 11279663846586579329, 17869051528129767402, 11889200830506914295, 10599455837063559955, 759464082804430731, 15283912685368151612], absorbed := 0 }
  , challengeOutput := (some 6088699767227576722)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [111, 27, 127, 199, 224, 106, 179, 224, 100, 158, 193, 168, 87, 52, 192, 102, 12, 142, 204, 107, 172, 208, 173, 109, 195, 250, 231, 36, 211, 96, 202, 41])
  , u64s := []
  , cursorBefore := { stateWords := [6088699767227576722, 12528948519504330862, 11279663846586579329, 17869051528129767402, 11889200830506914295, 10599455837063559955, 759464082804430731, 15283912685368151612], absorbed := 0 }
  , cursorAfter := { stateWords := [48532222294910656, 10388163368168912, 701128915, 14843658696269909404, 632567264487924670, 9495684395542701107, 12754696978657578631, 5965019087477990409], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [48532222294910656, 10388163368168912, 701128915, 14843658696269909404, 632567264487924670, 9495684395542701107, 12754696978657578631, 5965019087477990409], absorbed := 3 }
  , cursorAfter := { stateWords := [13380091740178962810, 1987045513776597526, 14252462800775023989, 13248926025003527830, 11922324911447888953, 15258157582598726077, 10666093963908230844, 10326266213215111518], absorbed := 0 }
  , challengeOutput := (some 13380091740178962810)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [13380091740178962810, 1987045513776597526, 14252462800775023989, 13248926025003527830, 11922324911447888953, 15258157582598726077, 10666093963908230844, 10326266213215111518], absorbed := 0 }
  , cursorAfter := { stateWords := [15897272204832747763, 11309953007401633108, 9308121576220038094, 14421880181001689210, 1035619753428010656, 5328331505368064188, 7303431608412067335, 3324893135966130710], absorbed := 0 }
  , challengeOutput := (some 15897272204832747763)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [41, 249, 151, 99, 238, 144, 154, 142, 199, 178, 160, 62, 82, 25, 55, 207, 119, 207, 88, 40, 18, 163, 232, 49, 21, 199, 146, 193, 148, 227, 131, 60])
  , u64s := []
  , cursorBefore := { stateWords := [15897272204832747763, 11309953007401633108, 9308121576220038094, 14421880181001689210, 1035619753428010656, 5328331505368064188, 7303431608412067335, 3324893135966130710], absorbed := 0 }
  , cursorAfter := { stateWords := [5110911483760439, 54486054256896163, 1015276436, 4331901097435875928, 15789074150951337316, 3955182664772735096, 10769170991645251297, 17860899021887337642], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [5110911483760439, 54486054256896163, 1015276436, 4331901097435875928, 15789074150951337316, 3955182664772735096, 10769170991645251297, 17860899021887337642], absorbed := 3 }
  , cursorAfter := { stateWords := [13290325236237073002, 3167263823412265548, 2124303598359401438, 5095260702073669384, 8423156342386431665, 13073329068178322645, 7620674100935967401, 4396032368165522868], absorbed := 0 }
  , challengeOutput := (some 13290325236237073002)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [198, 81, 7, 250, 152, 135, 65, 159, 231, 42, 117, 161, 26, 121, 63, 197, 123, 212, 231, 113, 35, 37, 159, 177, 226, 104, 247, 68, 136, 30, 16, 163])
  , u64s := []
  , cursorBefore := { stateWords := [13290325236237073002, 3167263823412265548, 2124303598359401438, 5095260702073669384, 8423156342386431665, 13073329068178322645, 7620674100935967401, 4396032368165522868], absorbed := 0 }
  , cursorAfter := { stateWords := [9976864701138239, 19412328268275493, 2735742600, 6237024833566110327, 5431075642013008537, 6023572556956649998, 10521409209457402270, 12586429016929075820], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [14, 218, 199, 227, 116, 94, 179, 48, 175, 100, 127, 227, 52, 186, 29, 20, 52, 186, 208, 59, 240, 120, 150, 172, 197, 158, 248, 136, 149, 25, 87, 170])
  , u64s := []
  , cursorBefore := { stateWords := [9976864701138239, 19412328268275493, 2735742600, 6237024833566110327, 5431075642013008537, 6023572556956649998, 10521409209457402270, 12586429016929075820], absorbed := 3 }
  , cursorAfter := { stateWords := [67619762073768989, 38553957637592696, 2857834901, 8341731544263560157, 4902622506011080670, 8080200595999723931, 11855971435305081364, 10265924672884533183], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [233, 2, 26, 64, 110, 89, 182, 250, 115, 142, 225, 137, 122, 240, 120, 174, 71, 71, 199, 38, 167, 175, 50, 4, 209, 82, 12, 195, 102, 116, 18, 219])
  , u64s := []
  , cursorBefore := { stateWords := [67619762073768989, 38553957637592696, 2857834901, 8341731544263560157, 4902622506011080670, 8080200595999723931, 11855971435305081364, 10265924672884533183], absorbed := 3 }
  , cursorAfter := { stateWords := [47048958446907000, 54901170292142767, 3675419750, 4408886950467464954, 1614180035197973635, 13250356512350060064, 13140457597853917177, 6806082314764002763], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [47048958446907000, 54901170292142767, 3675419750, 4408886950467464954, 1614180035197973635, 13250356512350060064, 13140457597853917177, 6806082314764002763], absorbed := 3 }
  , cursorAfter := { stateWords := [18231637688184314104, 12136559809485361695, 7943305808637014790, 10473583606824433045, 16180276070919521922, 2320050769754099697, 10410472214867620863, 9488396987056937058], absorbed := 0 }
  , challengeOutput := (some 18231637688184314104)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [18231637688184314104, 12136559809485361695, 7943305808637014790, 10473583606824433045, 16180276070919521922, 2320050769754099697, 10410472214867620863, 9488396987056937058], absorbed := 0 }
  , cursorAfter := { stateWords := [6989028146962492314, 13458860150513018094, 2109944762695544449, 7379276838592249487, 1877861401095802368, 8262029584102291418, 4261609953813478959, 7639261189778842531], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [154, 235, 231, 248, 17, 4, 254, 96, 238, 36, 253, 176, 255, 121, 199, 186, 129, 238, 41, 44, 149, 7, 72, 29, 143, 254, 142, 7, 48, 117, 104, 102]))
}]
}
  , kernel := {
  root0Digest := (bytes [72, 152, 175, 61, 117, 151, 32, 177, 71, 104, 246, 95, 143, 151, 74, 89, 231, 218, 126, 100, 152, 157, 138, 113, 5, 107, 158, 151, 6, 22, 95, 167])
  , stage1Digest := (bytes [111, 27, 127, 199, 224, 106, 179, 224, 100, 158, 193, 168, 87, 52, 192, 102, 12, 142, 204, 107, 172, 208, 173, 109, 195, 250, 231, 36, 211, 96, 202, 41])
  , stage2Digest := (bytes [41, 249, 151, 99, 238, 144, 154, 142, 199, 178, 160, 62, 82, 25, 55, 207, 119, 207, 88, 40, 18, 163, 232, 49, 21, 199, 146, 193, 148, 227, 131, 60])
  , stage3Digest := (bytes [198, 81, 7, 250, 152, 135, 65, 159, 231, 42, 117, 161, 26, 121, 63, 197, 123, 212, 231, 113, 35, 37, 159, 177, 226, 104, 247, 68, 136, 30, 16, 163])
  , executionDigest := (bytes [14, 218, 199, 227, 116, 94, 179, 48, 175, 100, 127, 227, 52, 186, 29, 20, 52, 186, 208, 59, 240, 120, 150, 172, 197, 158, 248, 136, 149, 25, 87, 170])
  , finalStateDigest := (bytes [233, 2, 26, 64, 110, 89, 182, 250, 115, 142, 225, 137, 122, 240, 120, 174, 71, 71, 199, 38, 167, 175, 50, 4, 209, 82, 12, 195, 102, 116, 18, 219])
  , stage1Mix := 6088699767227576722
  , stage2RegMix := 13380091740178962810
  , stage2RamMix := 15897272204832747763
  , stage3ContinuityMix := 13290325236237073002
  , kernelFinalMix := 18231637688184314104
  , transcriptFinalDigest := (bytes [154, 235, 231, 248, 17, 4, 254, 96, 238, 36, 253, 176, 255, 121, 199, 186, 129, 238, 41, 44, 149, 7, 72, 29, 143, 254, 142, 7, 48, 117, 104, 102])
  , finalPc := 20
  , finalRegisters := [0, 1, 18446744073709551615, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , finalMemory := []
  , halted := true
}
}

end Nightstream.Rv64IM.Generated.Cases.Case_control_flow_bge_taken_skip_ecall
