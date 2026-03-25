import Nightstream.Rv64IM.Generated.ParityTypes

namespace Nightstream.Rv64IM.Generated.Cases.Case_multiply_low_mul_mulw_ecall

open Nightstream.Rv64IM.Generated

def derivedCase : ParityDerivedCase :=
  {
  manifest := { name := "multiply_low_mul_mulw_ecall", fixtureId := "multiply_low_mul_mulw_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.multiply, .controlFlow] }
  , executionRows := [{
  traceIndex := 0
  , stepIndex := 0
  , sequenceIndex := 0
  , pc := 0
  , nextPc := 4
  , word := 35685043
  , opcode := .mul
  , traceOpcode := (some .mul)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 1
  , rs1Value := 3
  , rs2 := 2
  , rs2Value := 5
  , rd := 5
  , rdBefore := 0
  , rdAfter := 15
  , imm := 0
  , aluResult := 15
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
  , nextPc := 4
  , word := 37847867
  , opcode := .mulw
  , traceOpcode := (some .mul)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 3
  , rs1Value := 18446744073709551615
  , rs2 := 4
  , rs2Value := 5
  , rd := 6
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
  , isFirstInSequence := true
  , virtualSequenceRemaining := (some 1)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 2
  , stepIndex := 1
  , sequenceIndex := 1
  , pc := 4
  , nextPc := 8
  , word := 37847867
  , opcode := .mulw
  , traceOpcode := none
  , traceVirtualOpcode := (some .signExtendWord)
  , family := .multiply
  , rs1 := 6
  , rs1Value := 18446744073709551611
  , rs2 := 0
  , rs2Value := 0
  , rd := 6
  , rdBefore := 18446744073709551611
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
  , virtualSequenceRemaining := (some 0)
  , isEffectRow := true
  , isCommitRow := true
  , isReal := true
}, {
  traceIndex := 3
  , stepIndex := 2
  , sequenceIndex := 0
  , pc := 8
  , nextPc := 12
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
  , stage1 := { rows := [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 35685043, opcode := .mul, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .multiply, nextPc := 4, aluResult := 15, effectiveAddr := none, writesRd := true, rd := 5, rdAfter := 15, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 37847867, opcode := .mulw, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .multiply, nextPc := 4, aluResult := 18446744073709551611, effectiveAddr := none, writesRd := true, rd := 6, rdAfter := 18446744073709551611, isFirstInSequence := true, virtualSequenceRemaining := (some 1), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 2, stepIndex := 1, sequenceIndex := 1, fetchPc := 4, fetchedWord := 37847867, opcode := .mulw, traceOpcode := none, traceVirtualOpcode := (some .signExtendWord), family := .multiply, nextPc := 8, aluResult := 18446744073709551611, effectiveAddr := none, writesRd := true, rd := 6, rdAfter := 18446744073709551611, isFirstInSequence := false, virtualSequenceRemaining := (some 0), isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 3, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 12, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }] }
  , stage2 := {
  registerReads := [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 1, value := 3 }, { traceIndex := 0, stepIndex := 0, role := .rs2, reg := 2, value := 5 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 3, value := 18446744073709551615 }, { traceIndex := 1, stepIndex := 1, role := .rs2, reg := 4, value := 5 }, { traceIndex := 2, stepIndex := 1, role := .rs1, reg := 6, value := 18446744073709551611 }]
  , registerWrites := [{ traceIndex := 0, stepIndex := 0, reg := 5, previous := 0, next := 15 }, { traceIndex := 1, stepIndex := 1, reg := 6, previous := 0, next := 18446744073709551611 }, { traceIndex := 2, stepIndex := 1, reg := 6, previous := 18446744073709551611, next := 18446744073709551611 }]
  , ramEvents := []
  , twistLinks := [{ traceIndex := 0, stepIndex := 0, family := .multiply, routedWriteValue := (some 15), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 1, family := .multiply, routedWriteValue := (some 18446744073709551611), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 1, family := .multiply, routedWriteValue := (some 18446744073709551611), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 2, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]
}
  , stage3 := {
  continuity := [{ stepIndex := 0, pc := 0, nextPc := 4, successorPc := (some 4), finalStep := false, continuityHolds := true }, { stepIndex := 1, pc := 4, nextPc := 8, successorPc := (some 8), finalStep := false, continuityHolds := true }, { stepIndex := 2, pc := 8, nextPc := 12, successorPc := none, finalStep := true, continuityHolds := true }]
  , halted := true
}
  , transcript := {
  appLabel := (bytes [110, 101, 111, 46, 102, 111, 108, 100, 46, 110, 101, 120, 116, 47, 114, 118, 54, 52, 105, 109, 47, 112, 97, 114, 105, 116, 121, 95, 107, 101, 114, 110, 101, 108, 95, 118, 49])
  , events := [{
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 116, 114, 97, 110, 115, 99, 114, 105, 112, 116, 95, 115, 101, 101, 100])
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 109, 117, 108, 116, 105, 112, 108, 121, 45, 108, 111, 119, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [33264038245576057, 49, 15801769855426508079, 14132996704861268251, 7212379902124246076, 15047929176470279141, 5616374320259145566, 14753440915997802772], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [109, 117, 108, 116, 105, 112, 108, 121, 95, 108, 111, 119, 95, 109, 117, 108, 95, 109, 117, 108, 119, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [33264038245576057, 49, 15801769855426508079, 14132996704861268251, 7212379902124246076, 15047929176470279141, 5616374320259145566, 14753440915997802772], absorbed := 2 }
  , cursorAfter := { stateWords := [11679695271748168982, 2712977057955978529, 6392488499939417438, 9712442508924081875, 13881425306885585332, 7795794588090697948, 6883160295983221041, 10618828026406180653], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [35685043, 37847867, 115]
  , cursorBefore := { stateWords := [11679695271748168982, 2712977057955978529, 6392488499939417438, 9712442508924081875, 13881425306885585332, 7795794588090697948, 6883160295983221041, 10618828026406180653], absorbed := 0 }
  , cursorAfter := { stateWords := [12435485705448278119, 6850619590818699940, 13917565700616036084, 4392501261514991172, 13502733576928083299, 13863156554393195314, 4413081476540488696, 7896525446282371531], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 3, 5, 18446744073709551615, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [12435485705448278119, 6850619590818699940, 13917565700616036084, 4392501261514991172, 13502733576928083299, 13863156554393195314, 4413081476540488696, 7896525446282371531], absorbed := 0 }
  , cursorAfter := { stateWords := [0, 0, 7822679961934185920, 12397345697658153722, 3001304033479215618, 8656887314859786118, 14710946327372166009, 10939973110075842858], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [0, 0, 7822679961934185920, 12397345697658153722, 3001304033479215618, 8656887314859786118, 14710946327372166009, 10939973110075842858], absorbed := 2 }
  , cursorAfter := { stateWords := [13348506805888363, 30506403037277801, 34184295084289375, 0, 6880091923371616900, 9822592990985454698, 2265069032534962301, 9388863935382389039], absorbed := 4 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [55, 99, 89, 185, 167, 212, 193, 20, 132, 148, 245, 47, 29, 66, 104, 255, 254, 35, 74, 141, 242, 66, 50, 5, 38, 216, 19, 46, 148, 234, 170, 149])
  , u64s := []
  , cursorBefore := { stateWords := [13348506805888363, 30506403037277801, 34184295084289375, 0, 6880091923371616900, 9822592990985454698, 2265069032534962301, 9388863935382389039], absorbed := 4 }
  , cursorAfter := { stateWords := [68272293934989160, 12969668000428610, 2511006356, 5355837646695045982, 6658838408214485349, 5254813661533012688, 9500886277748393853, 14691489237928466676], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [68272293934989160, 12969668000428610, 2511006356, 5355837646695045982, 6658838408214485349, 5254813661533012688, 9500886277748393853, 14691489237928466676], absorbed := 3 }
  , cursorAfter := { stateWords := [958281227681322537, 9621727004723011364, 15366977138268494512, 7091799133169373218, 1920694937075606450, 15957481532292859767, 11692385134922167236, 14897684804006577139], absorbed := 0 }
  , challengeOutput := (some 958281227681322537)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [239, 32, 191, 158, 246, 120, 81, 110, 213, 34, 97, 219, 49, 213, 214, 201, 42, 36, 180, 252, 176, 208, 195, 73, 237, 247, 194, 243, 24, 209, 31, 97])
  , u64s := []
  , cursorBefore := { stateWords := [958281227681322537, 9621727004723011364, 15366977138268494512, 7091799133169373218, 1920694937075606450, 15957481532292859767, 11692385134922167236, 14897684804006577139], absorbed := 0 }
  , cursorAfter := { stateWords := [49817446532172246, 68612789434434512, 1629475096, 12685062807375549883, 6425840527485384673, 2835772843407561942, 18023079811125804460, 311893451903683171], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [49817446532172246, 68612789434434512, 1629475096, 12685062807375549883, 6425840527485384673, 2835772843407561942, 18023079811125804460, 311893451903683171], absorbed := 3 }
  , cursorAfter := { stateWords := [2675455227636596273, 15465606389814806151, 6496292526530955214, 14350157738078930549, 6332207016725253117, 15153355680753119628, 6494333196980659425, 14726632425429242732], absorbed := 0 }
  , challengeOutput := (some 2675455227636596273)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [2675455227636596273, 15465606389814806151, 6496292526530955214, 14350157738078930549, 6332207016725253117, 15153355680753119628, 6494333196980659425, 14726632425429242732], absorbed := 0 }
  , cursorAfter := { stateWords := [13053133613072267217, 7027043689607927159, 1592791213956823259, 3050071402000247761, 3871381500671292580, 10194496294615252084, 9045934512216133886, 14047791258511823390], absorbed := 0 }
  , challengeOutput := (some 13053133613072267217)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [133, 77, 156, 14, 205, 10, 134, 110, 5, 35, 247, 146, 221, 51, 137, 51, 47, 211, 187, 45, 200, 208, 211, 202, 193, 108, 48, 209, 140, 253, 224, 231])
  , u64s := []
  , cursorBefore := { stateWords := [13053133613072267217, 7027043689607927159, 1592791213956823259, 3050071402000247761, 3871381500671292580, 10194496294615252084, 9045934512216133886, 14047791258511823390], absorbed := 0 }
  , cursorAfter := { stateWords := [56345280067351433, 58881513798423504, 3890281868, 7563299808390894781, 14066407680691797500, 6393993264544238509, 5783035638399572063, 6541231049756594197], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [56345280067351433, 58881513798423504, 3890281868, 7563299808390894781, 14066407680691797500, 6393993264544238509, 5783035638399572063, 6541231049756594197], absorbed := 3 }
  , cursorAfter := { stateWords := [3287788377586240269, 16414608251463301650, 12211666100868863680, 9924354449851066269, 10474121507615922052, 8204221812019652328, 7269065889500974706, 10177302832156459772], absorbed := 0 }
  , challengeOutput := (some 3287788377586240269)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [227, 50, 66, 149, 179, 59, 217, 89, 92, 178, 49, 181, 220, 182, 219, 107, 94, 175, 121, 184, 126, 39, 254, 59, 141, 28, 136, 69, 128, 238, 158, 210])
  , u64s := []
  , cursorBefore := { stateWords := [3287788377586240269, 16414608251463301650, 12211666100868863680, 9924354449851066269, 10474121507615922052, 8204221812019652328, 7269065889500974706, 10177302832156459772], absorbed := 0 }
  , cursorAfter := { stateWords := [35668679838297051, 19571429603016231, 3533631104, 9132434312802418746, 4430554780986210717, 6067241104628758863, 4057550499568932679, 9917927534741253077], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [123, 14, 5, 5, 227, 128, 101, 102, 5, 232, 7, 177, 219, 235, 167, 68, 80, 246, 194, 154, 136, 182, 58, 97, 124, 165, 186, 136, 18, 172, 66, 34])
  , u64s := []
  , cursorBefore := { stateWords := [35668679838297051, 19571429603016231, 3533631104, 9132434312802418746, 4430554780986210717, 6067241104628758863, 4057550499568932679, 9917927534741253077], absorbed := 3 }
  , cursorAfter := { stateWords := [38450758979437735, 38485816751766198, 574794770, 3234852057638090801, 8711135607349208153, 13337997927487134985, 3623705389734534311, 12598335550552120936], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [242, 81, 176, 175, 238, 114, 245, 182, 225, 61, 206, 247, 53, 142, 80, 255, 255, 89, 165, 55, 152, 154, 68, 10, 162, 211, 197, 202, 42, 90, 209, 98])
  , u64s := []
  , cursorBefore := { stateWords := [38450758979437735, 38485816751766198, 574794770, 3234852057638090801, 8711135607349208153, 13337997927487134985, 3623705389734534311, 12598335550552120936], absorbed := 3 }
  , cursorAfter := { stateWords := [42845379779100496, 57075458042905754, 1657887274, 1157488941978709569, 7776319064664173158, 14531030589693420194, 330886240782000021, 9124333752976075353], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [42845379779100496, 57075458042905754, 1657887274, 1157488941978709569, 7776319064664173158, 14531030589693420194, 330886240782000021, 9124333752976075353], absorbed := 3 }
  , cursorAfter := { stateWords := [1139002541131170610, 13311004980905011221, 17059322981923826955, 16400005158604437465, 14198101310044799468, 4861677871181192696, 10994669030284816501, 4397522130388263428], absorbed := 0 }
  , challengeOutput := (some 1139002541131170610)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [1139002541131170610, 13311004980905011221, 17059322981923826955, 16400005158604437465, 14198101310044799468, 4861677871181192696, 10994669030284816501, 4397522130388263428], absorbed := 0 }
  , cursorAfter := { stateWords := [8691379572948843045, 16930304246629862551, 12642588212819564639, 490332071896985595, 3724576195324745426, 5614323902554289770, 6092678048444317087, 14931441881607814378], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [37, 186, 179, 53, 172, 251, 157, 120, 151, 12, 169, 255, 2, 134, 244, 234, 95, 152, 166, 10, 255, 126, 115, 175, 251, 175, 102, 231, 107, 2, 206, 6]))
}]
}
  , kernel := {
  root0Digest := (bytes [55, 99, 89, 185, 167, 212, 193, 20, 132, 148, 245, 47, 29, 66, 104, 255, 254, 35, 74, 141, 242, 66, 50, 5, 38, 216, 19, 46, 148, 234, 170, 149])
  , stage1Digest := (bytes [239, 32, 191, 158, 246, 120, 81, 110, 213, 34, 97, 219, 49, 213, 214, 201, 42, 36, 180, 252, 176, 208, 195, 73, 237, 247, 194, 243, 24, 209, 31, 97])
  , stage2Digest := (bytes [133, 77, 156, 14, 205, 10, 134, 110, 5, 35, 247, 146, 221, 51, 137, 51, 47, 211, 187, 45, 200, 208, 211, 202, 193, 108, 48, 209, 140, 253, 224, 231])
  , stage3Digest := (bytes [227, 50, 66, 149, 179, 59, 217, 89, 92, 178, 49, 181, 220, 182, 219, 107, 94, 175, 121, 184, 126, 39, 254, 59, 141, 28, 136, 69, 128, 238, 158, 210])
  , executionDigest := (bytes [123, 14, 5, 5, 227, 128, 101, 102, 5, 232, 7, 177, 219, 235, 167, 68, 80, 246, 194, 154, 136, 182, 58, 97, 124, 165, 186, 136, 18, 172, 66, 34])
  , finalStateDigest := (bytes [242, 81, 176, 175, 238, 114, 245, 182, 225, 61, 206, 247, 53, 142, 80, 255, 255, 89, 165, 55, 152, 154, 68, 10, 162, 211, 197, 202, 42, 90, 209, 98])
  , stage1Mix := 958281227681322537
  , stage2RegMix := 2675455227636596273
  , stage2RamMix := 13053133613072267217
  , stage3ContinuityMix := 3287788377586240269
  , kernelFinalMix := 1139002541131170610
  , transcriptFinalDigest := (bytes [37, 186, 179, 53, 172, 251, 157, 120, 151, 12, 169, 255, 2, 134, 244, 234, 95, 152, 166, 10, 255, 126, 115, 175, 251, 175, 102, 231, 107, 2, 206, 6])
  , finalPc := 12
  , finalRegisters := [0, 3, 5, 18446744073709551615, 5, 15, 18446744073709551611, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , finalMemory := []
  , halted := true
}
}

end Nightstream.Rv64IM.Generated.Cases.Case_multiply_low_mul_mulw_ecall
