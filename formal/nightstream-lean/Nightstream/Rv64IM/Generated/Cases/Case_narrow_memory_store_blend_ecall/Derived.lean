import Nightstream.Rv64IM.Generated.ParityTypes

namespace Nightstream.Rv64IM.Generated.Cases.Case_narrow_memory_store_blend_ecall

open Nightstream.Rv64IM.Generated

def derivedCase : ParityDerivedCase :=
  {
  manifest := { name := "narrow_memory_store_blend_ecall", fixtureId := "narrow_memory_store_blend_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.narrowMemory, .controlFlow] }
  , executionRows := [{
  traceIndex := 0
  , stepIndex := 0
  , sequenceIndex := 0
  , pc := 0
  , nextPc := 4
  , word := 1376419
  , opcode := .sb
  , traceOpcode := (some .sb)
  , traceVirtualOpcode := none
  , family := .narrowMemory
  , rs1 := 10
  , rs1Value := 16384
  , rs2 := 1
  , rs2Value := 18446744073709551615
  , rd := 0
  , rdBefore := 0
  , rdAfter := 0
  , imm := 1
  , aluResult := 9833440827789278993
  , effectiveAddr := (some 16385)
  , memoryBefore := (some 9833440827789222417)
  , memoryAfter := (some 9833440827789278993)
  , writesRd := false
  , writesRam := true
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
  , word := 2429219
  , opcode := .sh
  , traceOpcode := (some .sh)
  , traceVirtualOpcode := none
  , family := .narrowMemory
  , rs1 := 10
  , rs1Value := 16384
  , rs2 := 2
  , rs2Value := 291
  , rd := 0
  , rdBefore := 0
  , rdAfter := 0
  , imm := 2
  , aluResult := 9833440826664156945
  , effectiveAddr := (some 16386)
  , memoryBefore := (some 9833440827789278993)
  , memoryAfter := (some 9833440826664156945)
  , writesRd := false
  , writesRam := true
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
  , word := 3482147
  , opcode := .sw
  , traceOpcode := (some .sw)
  , traceVirtualOpcode := none
  , family := .narrowMemory
  , rs1 := 10
  , rs1Value := 16384
  , rs2 := 3
  , rs2Value := 305418343
  , rd := 0
  , rdBefore := 0
  , rdAfter := 0
  , imm := 4
  , aluResult := 1311761794802646801
  , effectiveAddr := (some 16388)
  , memoryBefore := (some 9833440826664156945)
  , memoryAfter := (some 1311761794802646801)
  , writesRd := false
  , writesRam := true
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
  , stage1 := { rows := [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 1376419, opcode := .sb, traceOpcode := (some .sb), traceVirtualOpcode := none, family := .narrowMemory, nextPc := 4, aluResult := 9833440827789278993, effectiveAddr := (some 16385), writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 2429219, opcode := .sh, traceOpcode := (some .sh), traceVirtualOpcode := none, family := .narrowMemory, nextPc := 8, aluResult := 9833440826664156945, effectiveAddr := (some 16386), writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 3482147, opcode := .sw, traceOpcode := (some .sw), traceVirtualOpcode := none, family := .narrowMemory, nextPc := 12, aluResult := 1311761794802646801, effectiveAddr := (some 16388), writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 12, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 16, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }] }
  , stage2 := {
  registerReads := [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 10, value := 16384 }, { traceIndex := 0, stepIndex := 0, role := .rs2, reg := 1, value := 18446744073709551615 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 10, value := 16384 }, { traceIndex := 1, stepIndex := 1, role := .rs2, reg := 2, value := 291 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 10, value := 16384 }, { traceIndex := 2, stepIndex := 2, role := .rs2, reg := 3, value := 305418343 }]
  , registerWrites := []
  , ramEvents := [{ traceIndex := 0, stepIndex := 0, kind := .write, addr := 16385, previous := 9833440827789222417, next := 9833440827789278993 }, { traceIndex := 1, stepIndex := 1, kind := .write, addr := 16386, previous := 9833440827789278993, next := 9833440826664156945 }, { traceIndex := 2, stepIndex := 2, kind := .write, addr := 16388, previous := 9833440826664156945, next := 1311761794802646801 }]
  , twistLinks := [{ traceIndex := 0, stepIndex := 0, family := .narrowMemory, routedWriteValue := none, routedMemoryBefore := (some 9833440827789222417), routedMemoryAfter := (some 9833440827789278993) }, { traceIndex := 1, stepIndex := 1, family := .narrowMemory, routedWriteValue := none, routedMemoryBefore := (some 9833440827789278993), routedMemoryAfter := (some 9833440826664156945) }, { traceIndex := 2, stepIndex := 2, family := .narrowMemory, routedWriteValue := none, routedMemoryBefore := (some 9833440826664156945), routedMemoryAfter := (some 1311761794802646801) }, { traceIndex := 3, stepIndex := 3, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]
}
  , stage3 := {
  continuity := [{ stepIndex := 0, pc := 0, nextPc := 4, successorPc := (some 4), finalStep := false, continuityHolds := true }, { stepIndex := 1, pc := 4, nextPc := 8, successorPc := (some 8), finalStep := false, continuityHolds := true }, { stepIndex := 2, pc := 8, nextPc := 12, successorPc := (some 12), finalStep := false, continuityHolds := true }, { stepIndex := 3, pc := 12, nextPc := 16, successorPc := none, finalStep := true, continuityHolds := true }]
  , halted := true
}
  , transcript := {
  appLabel := (bytes [110, 101, 111, 46, 102, 111, 108, 100, 46, 110, 101, 120, 116, 47, 114, 118, 54, 52, 105, 109, 47, 112, 97, 114, 105, 116, 121, 95, 107, 101, 114, 110, 101, 108, 95, 118, 49])
  , events := [{
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 116, 114, 97, 110, 115, 99, 114, 105, 112, 116, 95, 115, 101, 101, 100])
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 110, 97, 114, 114, 111, 119, 45, 109, 101, 109, 111, 114, 121, 45, 115, 116, 111, 114, 101, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [12799906354652525, 33263960986711155, 49, 2469450879557506871, 17981393906185129334, 2255065206050469190, 11361339744383199720, 13350430132404872179], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [110, 97, 114, 114, 111, 119, 95, 109, 101, 109, 111, 114, 121, 95, 115, 116, 111, 114, 101, 95, 98, 108, 101, 110, 100, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [12799906354652525, 33263960986711155, 49, 2469450879557506871, 17981393906185129334, 2255065206050469190, 11361339744383199720, 13350430132404872179], absorbed := 3 }
  , cursorAfter := { stateWords := [27977483075609964, 7105633, 16235786842355175766, 9722763183111548829, 13597039914772872755, 16053446403831375374, 1969694843460043026, 12902901434017126239], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [1376419, 2429219, 3482147, 115]
  , cursorBefore := { stateWords := [27977483075609964, 7105633, 16235786842355175766, 9722763183111548829, 13597039914772872755, 16053446403831375374, 1969694843460043026, 12902901434017126239], absorbed := 2 }
  , cursorAfter := { stateWords := [7909839790110307734, 6759547673874595097, 14737629333201118450, 6593067333610068135, 17280762612585139971, 7547793365437928636, 185813838742483472, 10082908410497078523], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 18446744073709551615, 291, 305418343, 0, 0, 0, 0, 0, 0, 16384, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [7909839790110307734, 6759547673874595097, 14737629333201118450, 6593067333610068135, 17280762612585139971, 7547793365437928636, 185813838742483472, 10082908410497078523], absorbed := 0 }
  , cursorAfter := { stateWords := [0, 0, 2501476762795805839, 16706310514501368063, 9811058166863854757, 2880747809027434626, 4934780264284805179, 15014460653679776129], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := [16384, 9833440827789222417]
  , cursorBefore := { stateWords := [0, 0, 2501476762795805839, 16706310514501368063, 9811058166863854757, 2880747809027434626, 4934780264284805179, 15014460653679776129], absorbed := 2 }
  , cursorAfter := { stateWords := [10168812739775300594, 6612060964936355367, 15934757856210812279, 4938238543691379378, 9342626222090624725, 8316416302278135072, 3766218131980238172, 11838298430729853708], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [242, 110, 151, 115, 148, 148, 8, 17, 100, 152, 161, 168, 22, 189, 146, 244, 189, 245, 135, 199, 118, 227, 133, 191, 50, 208, 42, 207, 155, 138, 98, 158])
  , u64s := []
  , cursorBefore := { stateWords := [10168812739775300594, 6612060964936355367, 15934757856210812279, 4938238543691379378, 9342626222090624725, 8316416302278135072, 3766218131980238172, 11838298430729853708], absorbed := 0 }
  , cursorAfter := { stateWords := [33433434009236626, 58312393872082403, 2657258139, 1584723988080463607, 3659455058817345959, 7666179203613910153, 15153038506447981014, 17463380026104571997], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [33433434009236626, 58312393872082403, 2657258139, 1584723988080463607, 3659455058817345959, 7666179203613910153, 15153038506447981014, 17463380026104571997], absorbed := 3 }
  , cursorAfter := { stateWords := [5531152082702141776, 8852351285603339913, 3142132161316303354, 8625214617585638924, 8405662536202468113, 1237003624211582234, 4430587283651626587, 13636014788357108482], absorbed := 0 }
  , challengeOutput := (some 5531152082702141776)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [1, 22, 115, 63, 68, 39, 222, 123, 115, 145, 24, 130, 215, 136, 19, 73, 196, 123, 7, 22, 196, 88, 205, 148, 212, 139, 185, 222, 92, 254, 161, 232])
  , u64s := []
  , cursorBefore := { stateWords := [5531152082702141776, 8852351285603339913, 3142132161316303354, 8625214617585638924, 8405662536202468113, 1237003624211582234, 4430587283651626587, 13636014788357108482], absorbed := 0 }
  , cursorAfter := { stateWords := [55193316832332051, 62691455047880024, 3902930524, 10877552688092081253, 474870080077534528, 10597071065642081137, 3027504141201092204, 16391699335276388760], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [55193316832332051, 62691455047880024, 3902930524, 10877552688092081253, 474870080077534528, 10597071065642081137, 3027504141201092204, 16391699335276388760], absorbed := 3 }
  , cursorAfter := { stateWords := [5806387069185771174, 7431100681990957332, 399262971810836686, 5730744426541143173, 11093290301736432578, 16375459554798909642, 14282623156409331605, 14838679128566408960], absorbed := 0 }
  , challengeOutput := (some 5806387069185771174)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [5806387069185771174, 7431100681990957332, 399262971810836686, 5730744426541143173, 11093290301736432578, 16375459554798909642, 14282623156409331605, 14838679128566408960], absorbed := 0 }
  , cursorAfter := { stateWords := [2252285572590400925, 2501947398447012130, 5016378596024469215, 12874493306261026240, 8111351853466281069, 10136816399105058943, 11256559540498713435, 8436565593666653098], absorbed := 0 }
  , challengeOutput := (some 2252285572590400925)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [82, 155, 156, 58, 57, 174, 172, 19, 174, 90, 104, 163, 26, 66, 224, 116, 89, 12, 225, 36, 16, 182, 89, 40, 228, 218, 46, 158, 205, 7, 229, 153])
  , u64s := []
  , cursorBefore := { stateWords := [2252285572590400925, 2501947398447012130, 5016378596024469215, 12874493306261026240, 8111351853466281069, 10136816399105058943, 11256559540498713435, 8436565593666653098], absorbed := 0 }
  , cursorAfter := { stateWords := [4544148620801248, 44524563985881526, 2581923789, 1561476845787299064, 6160946031507690152, 1061100143130824716, 17309728585202106702, 4303753953300140258], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [4544148620801248, 44524563985881526, 2581923789, 1561476845787299064, 6160946031507690152, 1061100143130824716, 17309728585202106702, 4303753953300140258], absorbed := 3 }
  , cursorAfter := { stateWords := [11344168861349669954, 309934187593503557, 12742392626438456636, 3552444172848721278, 12168186189331816510, 7734376485157003612, 15305972872272012709, 812755545714809876], absorbed := 0 }
  , challengeOutput := (some 11344168861349669954)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [242, 180, 211, 44, 136, 191, 129, 103, 121, 27, 189, 177, 57, 84, 107, 37, 200, 205, 250, 244, 70, 251, 148, 129, 186, 236, 174, 139, 158, 109, 21, 76])
  , u64s := []
  , cursorBefore := { stateWords := [11344168861349669954, 309934187593503557, 12742392626438456636, 3552444172848721278, 12168186189331816510, 7734376485157003612, 15305972872272012709, 812755545714809876], absorbed := 0 }
  , cursorAfter := { stateWords := [19972606401193323, 39317353527350523, 1276472734, 4595401344071257542, 1257025798664200055, 2558123650798857335, 12376659094459369347, 12330388349695557704], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [126, 229, 176, 212, 191, 247, 23, 235, 102, 79, 163, 176, 248, 83, 234, 113, 242, 143, 167, 234, 192, 10, 182, 188, 84, 183, 186, 114, 8, 210, 7, 35])
  , u64s := []
  , cursorBefore := { stateWords := [19972606401193323, 39317353527350523, 1276472734, 4595401344071257542, 1257025798664200055, 2558123650798857335, 12376659094459369347, 12330388349695557704], absorbed := 3 }
  , cursorAfter := { stateWords := [54301200923914730, 32293443908449802, 587715080, 4438060655696046686, 400537138650302616, 5088206470290128025, 7443188918583186329, 4415741670551207390], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [154, 18, 221, 178, 230, 2, 55, 214, 98, 89, 116, 201, 158, 175, 212, 108, 114, 212, 87, 82, 1, 170, 92, 227, 67, 154, 4, 168, 36, 42, 214, 94])
  , u64s := []
  , cursorBefore := { stateWords := [54301200923914730, 32293443908449802, 587715080, 4438060655696046686, 400537138650302616, 5088206470290128025, 7443188918583186329, 4415741670551207390], absorbed := 3 }
  , cursorAfter := { stateWords := [372012156611796, 47292856697838762, 1591093796, 3264662417155200317, 13043554742622117799, 5797772543345645540, 1230714364564772446, 12202841695689355569], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [372012156611796, 47292856697838762, 1591093796, 3264662417155200317, 13043554742622117799, 5797772543345645540, 1230714364564772446, 12202841695689355569], absorbed := 3 }
  , cursorAfter := { stateWords := [3370361305450089815, 594406523164350997, 14609487907949016446, 659044346044635613, 8736022502899114162, 15745456517950588328, 2579347474030409627, 8538476403338498362], absorbed := 0 }
  , challengeOutput := (some 3370361305450089815)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [3370361305450089815, 594406523164350997, 14609487907949016446, 659044346044635613, 8736022502899114162, 15745456517950588328, 2579347474030409627, 8538476403338498362], absorbed := 0 }
  , cursorAfter := { stateWords := [7375110637719107241, 11746124680588279666, 17353745966656596618, 4616729715189868272, 15026743348915914890, 15963680833122423512, 5114706872606429921, 1668349186516782311], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [169, 182, 115, 204, 12, 168, 89, 102, 114, 191, 233, 209, 41, 158, 2, 163, 138, 42, 239, 56, 3, 228, 212, 240, 240, 230, 225, 41, 55, 235, 17, 64]))
}]
}
  , kernel := {
  root0Digest := (bytes [242, 110, 151, 115, 148, 148, 8, 17, 100, 152, 161, 168, 22, 189, 146, 244, 189, 245, 135, 199, 118, 227, 133, 191, 50, 208, 42, 207, 155, 138, 98, 158])
  , stage1Digest := (bytes [1, 22, 115, 63, 68, 39, 222, 123, 115, 145, 24, 130, 215, 136, 19, 73, 196, 123, 7, 22, 196, 88, 205, 148, 212, 139, 185, 222, 92, 254, 161, 232])
  , stage2Digest := (bytes [82, 155, 156, 58, 57, 174, 172, 19, 174, 90, 104, 163, 26, 66, 224, 116, 89, 12, 225, 36, 16, 182, 89, 40, 228, 218, 46, 158, 205, 7, 229, 153])
  , stage3Digest := (bytes [242, 180, 211, 44, 136, 191, 129, 103, 121, 27, 189, 177, 57, 84, 107, 37, 200, 205, 250, 244, 70, 251, 148, 129, 186, 236, 174, 139, 158, 109, 21, 76])
  , executionDigest := (bytes [126, 229, 176, 212, 191, 247, 23, 235, 102, 79, 163, 176, 248, 83, 234, 113, 242, 143, 167, 234, 192, 10, 182, 188, 84, 183, 186, 114, 8, 210, 7, 35])
  , finalStateDigest := (bytes [154, 18, 221, 178, 230, 2, 55, 214, 98, 89, 116, 201, 158, 175, 212, 108, 114, 212, 87, 82, 1, 170, 92, 227, 67, 154, 4, 168, 36, 42, 214, 94])
  , stage1Mix := 5531152082702141776
  , stage2RegMix := 5806387069185771174
  , stage2RamMix := 2252285572590400925
  , stage3ContinuityMix := 11344168861349669954
  , kernelFinalMix := 3370361305450089815
  , transcriptFinalDigest := (bytes [169, 182, 115, 204, 12, 168, 89, 102, 114, 191, 233, 209, 41, 158, 2, 163, 138, 42, 239, 56, 3, 228, 212, 240, 240, 230, 225, 41, 55, 235, 17, 64])
  , finalPc := 16
  , finalRegisters := [0, 18446744073709551615, 291, 305418343, 0, 0, 0, 0, 0, 0, 16384, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , finalMemory := [{ addr := 16384, value := 1311761794802646801 }]
  , halted := true
}
}

end Nightstream.Rv64IM.Generated.Cases.Case_narrow_memory_store_blend_ecall
