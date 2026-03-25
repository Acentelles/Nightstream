import Nightstream.Rv64IM.Generated.ParityTypes

namespace Nightstream.Rv64IM.Generated.Cases.Case_native_sub_lui_auipc_fence_ecall

open Nightstream.Rv64IM.Generated

def derivedCase : ParityDerivedCase :=
  {
  manifest := { name := "native_sub_lui_auipc_fence_ecall", fixtureId := "native_sub_lui_auipc_fence_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , executionRows := [{
  traceIndex := 0
  , stepIndex := 0
  , sequenceIndex := 0
  , pc := 0
  , nextPc := 4
  , word := 9437331
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
  , rdAfter := 9
  , imm := 9
  , aluResult := 9
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
  , word := 4194579
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
  , rdAfter := 4
  , imm := 4
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
  traceIndex := 2
  , stepIndex := 2
  , sequenceIndex := 0
  , pc := 8
  , nextPc := 12
  , word := 1075872179
  , opcode := .sub
  , traceOpcode := (some .sub)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 9
  , rs2 := 2
  , rs2Value := 4
  , rd := 3
  , rdBefore := 0
  , rdAfter := 5
  , imm := 0
  , aluResult := 5
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
  , word := 305418807
  , opcode := .lui
  , traceOpcode := (some .lui)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 0
  , rs1Value := 0
  , rs2 := 0
  , rs2Value := 0
  , rd := 4
  , rdBefore := 0
  , rdAfter := 305418240
  , imm := 305418240
  , aluResult := 305418240
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
  , word := 8855
  , opcode := .auipc
  , traceOpcode := (some .auipc)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 0
  , rs1Value := 0
  , rs2 := 0
  , rs2Value := 0
  , rd := 5
  , rdBefore := 0
  , rdAfter := 8208
  , imm := 8192
  , aluResult := 8208
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
  , word := 15
  , opcode := .fence
  , traceOpcode := (some .fence)
  , traceVirtualOpcode := none
  , family := .nativeAlu
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
  , stage1 := { rows := [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 9437331, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 4, aluResult := 9, effectiveAddr := none, writesRd := true, rd := 1, rdAfter := 9, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 4194579, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 8, aluResult := 4, effectiveAddr := none, writesRd := true, rd := 2, rdAfter := 4, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 1075872179, opcode := .sub, traceOpcode := (some .sub), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 12, aluResult := 5, effectiveAddr := none, writesRd := true, rd := 3, rdAfter := 5, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 12, fetchedWord := 305418807, opcode := .lui, traceOpcode := (some .lui), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 16, aluResult := 305418240, effectiveAddr := none, writesRd := true, rd := 4, rdAfter := 305418240, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 4, stepIndex := 4, sequenceIndex := 0, fetchPc := 16, fetchedWord := 8855, opcode := .auipc, traceOpcode := (some .auipc), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 20, aluResult := 8208, effectiveAddr := none, writesRd := true, rd := 5, rdAfter := 8208, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 5, stepIndex := 5, sequenceIndex := 0, fetchPc := 20, fetchedWord := 15, opcode := .fence, traceOpcode := (some .fence), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 24, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }, { traceIndex := 6, stepIndex := 6, sequenceIndex := 0, fetchPc := 24, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 28, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }] }
  , stage2 := {
  registerReads := [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 0, value := 0 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 0, value := 0 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 1, value := 9 }, { traceIndex := 2, stepIndex := 2, role := .rs2, reg := 2, value := 4 }]
  , registerWrites := [{ traceIndex := 0, stepIndex := 0, reg := 1, previous := 0, next := 9 }, { traceIndex := 1, stepIndex := 1, reg := 2, previous := 0, next := 4 }, { traceIndex := 2, stepIndex := 2, reg := 3, previous := 0, next := 5 }, { traceIndex := 3, stepIndex := 3, reg := 4, previous := 0, next := 305418240 }, { traceIndex := 4, stepIndex := 4, reg := 5, previous := 0, next := 8208 }]
  , ramEvents := []
  , twistLinks := [{ traceIndex := 0, stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 9), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 1, family := .nativeAlu, routedWriteValue := (some 4), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 2, family := .nativeAlu, routedWriteValue := (some 5), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 3, family := .nativeAlu, routedWriteValue := (some 305418240), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 4, stepIndex := 4, family := .nativeAlu, routedWriteValue := (some 8208), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 5, stepIndex := 5, family := .nativeAlu, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 6, stepIndex := 6, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]
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
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 110, 97, 116, 105, 118, 101, 45, 117, 112, 112, 101, 114, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [33264016603246709, 49, 3390619080185759186, 12096819762988914126, 4001610679670701799, 5432763535062103318, 13415967828788768464, 15663373744946530692], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [110, 97, 116, 105, 118, 101, 95, 115, 117, 98, 95, 108, 117, 105, 95, 97, 117, 105, 112, 99, 95, 102, 101, 110, 99, 101, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [33264016603246709, 49, 3390619080185759186, 12096819762988914126, 4001610679670701799, 5432763535062103318, 13415967828788768464, 15663373744946530692], absorbed := 2 }
  , cursorAfter := { stateWords := [1819042147, 11492432570176362726, 3613697514698292200, 2650558433509510378, 12055400323590214993, 7120483714660094914, 8332376278638538225, 13997537144169937627], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [9437331, 4194579, 1075872179, 305418807, 8855, 15, 115]
  , cursorBefore := { stateWords := [1819042147, 11492432570176362726, 3613697514698292200, 2650558433509510378, 12055400323590214993, 7120483714660094914, 8332376278638538225, 13997537144169937627], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 8205865210994545291, 16390913469773137775, 10686499010112080571, 3479089081210409115, 11490434913573307181, 4744750243635717087, 14190831713282467533], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [0, 8205865210994545291, 16390913469773137775, 10686499010112080571, 3479089081210409115, 11490434913573307181, 4744750243635717087, 14190831713282467533], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 0, 0, 13927086879393838485, 2623036754198827976, 17760213709172924268, 9303648523283746330, 14333610373503370693], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [0, 0, 0, 13927086879393838485, 2623036754198827976, 17760213709172924268, 9303648523283746330, 14333610373503370693], absorbed := 3 }
  , cursorAfter := { stateWords := [0, 15034277137021512653, 2940523068502370021, 6783709668891648116, 2921762084008379884, 13093662981597386728, 7237693185718636805, 15480948837919714228], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [243, 113, 232, 88, 106, 85, 125, 126, 75, 211, 202, 21, 77, 236, 178, 254, 109, 98, 100, 162, 148, 107, 115, 169, 238, 169, 84, 21, 113, 145, 196, 77])
  , u64s := []
  , cursorBefore := { stateWords := [0, 15034277137021512653, 2940523068502370021, 6783709668891648116, 2921762084008379884, 13093662981597386728, 7237693185718636805, 15480948837919714228], absorbed := 1 }
  , cursorAfter := { stateWords := [16698362512571709445, 5621564629903000699, 10009083160971522880, 7591915833665178415, 4881815619038706464, 1221843751511080609, 17487803174555929498, 11190372688641205339], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [16698362512571709445, 5621564629903000699, 10009083160971522880, 7591915833665178415, 4881815619038706464, 1221843751511080609, 17487803174555929498, 11190372688641205339], absorbed := 0 }
  , cursorAfter := { stateWords := [4896283865473105481, 12847043629536236269, 11452704206453262291, 12159014570259131020, 15761870554813372632, 1933128212755914187, 7691327332694391306, 5251054156748709053], absorbed := 0 }
  , challengeOutput := (some 4896283865473105481)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [13, 9, 218, 115, 204, 43, 4, 113, 32, 177, 132, 132, 182, 134, 250, 82, 89, 188, 40, 248, 201, 130, 127, 49, 3, 60, 79, 175, 212, 151, 219, 255])
  , u64s := []
  , cursorBefore := { stateWords := [4896283865473105481, 12847043629536236269, 11452704206453262291, 12159014570259131020, 15761870554813372632, 1933128212755914187, 7691327332694391306, 5251054156748709053], absorbed := 0 }
  , cursorAfter := { stateWords := [56849324161192698, 49345240094572418, 4292581332, 9800505453015189377, 9590740405110030922, 16846094450105664483, 10584449469242708340, 4875974988665847814], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [56849324161192698, 49345240094572418, 4292581332, 9800505453015189377, 9590740405110030922, 16846094450105664483, 10584449469242708340, 4875974988665847814], absorbed := 3 }
  , cursorAfter := { stateWords := [7033248085425099487, 5551250185185976109, 6838203931123481440, 10155553537626108981, 15357769538341139672, 2358490636320328012, 11314427473321819060, 9232286664736664635], absorbed := 0 }
  , challengeOutput := (some 7033248085425099487)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [7033248085425099487, 5551250185185976109, 6838203931123481440, 10155553537626108981, 15357769538341139672, 2358490636320328012, 11314427473321819060, 9232286664736664635], absorbed := 0 }
  , cursorAfter := { stateWords := [8169386753030433916, 18385266726658662445, 12573782555528246414, 11448961664731975404, 12518743713704370554, 9694518568927529184, 4856529869949649507, 10304706592028699305], absorbed := 0 }
  , challengeOutput := (some 8169386753030433916)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [15, 204, 89, 37, 7, 113, 30, 46, 152, 189, 215, 255, 96, 129, 30, 176, 43, 248, 43, 100, 180, 85, 5, 151, 15, 168, 47, 45, 165, 34, 74, 203])
  , u64s := []
  , cursorBefore := { stateWords := [8169386753030433916, 18385266726658662445, 12573782555528246414, 11448961664731975404, 12518743713704370554, 9694518568927529184, 4856529869949649507, 10304706592028699305], absorbed := 0 }
  , cursorAfter := { stateWords := [50775635817902110, 12718772814546261, 3410633381, 10034820627164037781, 13600521825979114431, 16788147473131196060, 10808458552465737848, 15289043801276852242], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [50775635817902110, 12718772814546261, 3410633381, 10034820627164037781, 13600521825979114431, 16788147473131196060, 10808458552465737848, 15289043801276852242], absorbed := 3 }
  , cursorAfter := { stateWords := [13526737568366105716, 386749902861854862, 505187822126796796, 3924489003198897156, 17943143049075451202, 13587490318313133728, 6809125786034294136, 12332313511951957591], absorbed := 0 }
  , challengeOutput := (some 13526737568366105716)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [13, 62, 18, 231, 159, 216, 74, 146, 123, 100, 48, 154, 55, 62, 243, 77, 247, 72, 183, 146, 55, 128, 226, 205, 79, 61, 249, 159, 174, 184, 114, 0])
  , u64s := []
  , cursorBefore := { stateWords := [13526737568366105716, 386749902861854862, 505187822126796796, 3924489003198897156, 17943143049075451202, 13587490318313133728, 6809125786034294136, 12332313511951957591], absorbed := 0 }
  , cursorAfter := { stateWords := [15642439619923443, 45028563024208512, 7518382, 4674175335594239469, 8343585173727886530, 13355842309813324475, 5970572056999808892, 17880192704068840598], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [28, 1, 84, 184, 89, 242, 14, 108, 33, 243, 25, 226, 156, 89, 231, 121, 72, 112, 15, 25, 78, 90, 217, 60, 9, 73, 78, 4, 175, 30, 106, 21])
  , u64s := []
  , cursorBefore := { stateWords := [15642439619923443, 45028563024208512, 7518382, 4674175335594239469, 8343585173727886530, 13355842309813324475, 5970572056999808892, 17880192704068840598], absorbed := 3 }
  , cursorAfter := { stateWords := [21982602282432999, 1211975501404506, 359276207, 11778840946998352371, 2601310992186137151, 9183972256606065443, 2341718538809599119, 7720520626828516466], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [235, 168, 117, 145, 21, 252, 85, 198, 113, 178, 38, 202, 134, 138, 105, 213, 57, 49, 5, 39, 70, 58, 244, 201, 34, 144, 14, 16, 184, 169, 197, 30])
  , u64s := []
  , cursorBefore := { stateWords := [21982602282432999, 1211975501404506, 359276207, 11778840946998352371, 2601310992186137151, 9183972256606065443, 2341718538809599119, 7720520626828516466], absorbed := 3 }
  , cursorAfter := { stateWords := [19746151623939433, 4519611849110586, 516270520, 841895348041309407, 6525366411293773459, 10331942656253231823, 8000196005749216479, 4242443321909022880], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [19746151623939433, 4519611849110586, 516270520, 841895348041309407, 6525366411293773459, 10331942656253231823, 8000196005749216479, 4242443321909022880], absorbed := 3 }
  , cursorAfter := { stateWords := [6691788142193379930, 442893960619180382, 14347864803423902063, 2733085216426276580, 13712782214558036224, 14831264393031247711, 17027622760445651302, 1083395422601994900], absorbed := 0 }
  , challengeOutput := (some 6691788142193379930)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [6691788142193379930, 442893960619180382, 14347864803423902063, 2733085216426276580, 13712782214558036224, 14831264393031247711, 17027622760445651302, 1083395422601994900], absorbed := 0 }
  , cursorAfter := { stateWords := [15976141382771928389, 11705041835130272246, 17103682074520183549, 11353896720354733691, 6592350785348559089, 11058181024729775942, 13765259832617846959, 12403894881833510756], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [69, 237, 137, 65, 241, 167, 182, 221, 246, 185, 6, 120, 136, 169, 112, 162, 253, 226, 253, 66, 58, 124, 92, 237, 123, 110, 55, 97, 233, 36, 145, 157]))
}]
}
  , kernel := {
  root0Digest := (bytes [243, 113, 232, 88, 106, 85, 125, 126, 75, 211, 202, 21, 77, 236, 178, 254, 109, 98, 100, 162, 148, 107, 115, 169, 238, 169, 84, 21, 113, 145, 196, 77])
  , stage1Digest := (bytes [13, 9, 218, 115, 204, 43, 4, 113, 32, 177, 132, 132, 182, 134, 250, 82, 89, 188, 40, 248, 201, 130, 127, 49, 3, 60, 79, 175, 212, 151, 219, 255])
  , stage2Digest := (bytes [15, 204, 89, 37, 7, 113, 30, 46, 152, 189, 215, 255, 96, 129, 30, 176, 43, 248, 43, 100, 180, 85, 5, 151, 15, 168, 47, 45, 165, 34, 74, 203])
  , stage3Digest := (bytes [13, 62, 18, 231, 159, 216, 74, 146, 123, 100, 48, 154, 55, 62, 243, 77, 247, 72, 183, 146, 55, 128, 226, 205, 79, 61, 249, 159, 174, 184, 114, 0])
  , executionDigest := (bytes [28, 1, 84, 184, 89, 242, 14, 108, 33, 243, 25, 226, 156, 89, 231, 121, 72, 112, 15, 25, 78, 90, 217, 60, 9, 73, 78, 4, 175, 30, 106, 21])
  , finalStateDigest := (bytes [235, 168, 117, 145, 21, 252, 85, 198, 113, 178, 38, 202, 134, 138, 105, 213, 57, 49, 5, 39, 70, 58, 244, 201, 34, 144, 14, 16, 184, 169, 197, 30])
  , stage1Mix := 4896283865473105481
  , stage2RegMix := 7033248085425099487
  , stage2RamMix := 8169386753030433916
  , stage3ContinuityMix := 13526737568366105716
  , kernelFinalMix := 6691788142193379930
  , transcriptFinalDigest := (bytes [69, 237, 137, 65, 241, 167, 182, 221, 246, 185, 6, 120, 136, 169, 112, 162, 253, 226, 253, 66, 58, 124, 92, 237, 123, 110, 55, 97, 233, 36, 145, 157])
  , finalPc := 28
  , finalRegisters := [0, 9, 4, 5, 305418240, 8208, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , finalMemory := []
  , halted := true
}
}

end Nightstream.Rv64IM.Generated.Cases.Case_native_sub_lui_auipc_fence_ecall
