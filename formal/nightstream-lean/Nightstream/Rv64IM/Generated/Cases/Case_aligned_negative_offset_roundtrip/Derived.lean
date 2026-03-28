import Nightstream.Rv64IM.Generated.ParityTypes

namespace Nightstream.Rv64IM.Generated.Cases.Case_aligned_negative_offset_roundtrip

open Nightstream.Rv64IM.Generated

def derivedCase : ParityDerivedCase :=
  {
  manifest := { name := "aligned_negative_offset_roundtrip", fixtureId := "aligned_negative_offset_roundtrip_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .alignedMemory, .controlFlow] }
  , executionRows := [{
  traceIndex := 0
  , stepIndex := 0
  , sequenceIndex := 0
  , pc := 0
  , nextPc := 4
  , word := 44040339
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
  , rdAfter := 42
  , imm := 42
  , aluResult := 42
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
  , word := 4262804515
  , opcode := .sd
  , traceOpcode := (some .sd)
  , traceVirtualOpcode := none
  , family := .alignedMemory
  , rs1 := 10
  , rs1Value := 8200
  , rs2 := 1
  , rs2Value := 42
  , rd := 0
  , rdBefore := 0
  , rdAfter := 0
  , imm := -8
  , aluResult := 42
  , effectiveAddr := (some 8192)
  , memoryBefore := (some 13)
  , memoryAfter := (some 42)
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
  , word := 4286918915
  , opcode := .ld
  , traceOpcode := (some .ld)
  , traceVirtualOpcode := none
  , family := .alignedMemory
  , rs1 := 10
  , rs1Value := 8200
  , rs2 := 0
  , rs2Value := 0
  , rd := 2
  , rdBefore := 0
  , rdAfter := 42
  , imm := -8
  , aluResult := 42
  , effectiveAddr := (some 8192)
  , memoryBefore := (some 42)
  , memoryAfter := (some 42)
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
  , stage1 := { rows := [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 44040339, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 4, aluResult := 42, effectiveAddr := none, writesRd := true, rd := 1, rdAfter := 42, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 4262804515, opcode := .sd, traceOpcode := (some .sd), traceVirtualOpcode := none, family := .alignedMemory, nextPc := 8, aluResult := 42, effectiveAddr := (some 8192), writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 4286918915, opcode := .ld, traceOpcode := (some .ld), traceVirtualOpcode := none, family := .alignedMemory, nextPc := 12, aluResult := 42, effectiveAddr := (some 8192), writesRd := true, rd := 2, rdAfter := 42, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 12, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 16, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }] }
  , stage2 := {
  registerReads := [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 0, value := 0 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 10, value := 8200 }, { traceIndex := 1, stepIndex := 1, role := .rs2, reg := 1, value := 42 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 10, value := 8200 }]
  , registerWrites := [{ traceIndex := 0, stepIndex := 0, reg := 1, previous := 0, next := 42 }, { traceIndex := 2, stepIndex := 2, reg := 2, previous := 0, next := 42 }]
  , ramEvents := [{ traceIndex := 1, stepIndex := 1, kind := .write, addr := 8192, previous := 13, next := 42 }, { traceIndex := 2, stepIndex := 2, kind := .read, addr := 8192, previous := 42, next := 42 }]
  , twistLinks := [{ traceIndex := 0, stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 42), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 1, family := .alignedMemory, routedWriteValue := none, routedMemoryBefore := (some 13), routedMemoryAfter := (some 42) }, { traceIndex := 2, stepIndex := 2, family := .alignedMemory, routedWriteValue := (some 42), routedMemoryBefore := (some 42), routedMemoryAfter := (some 42) }, { traceIndex := 3, stepIndex := 3, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]
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
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 97, 108, 105, 103, 110, 101, 100, 45, 109, 101, 109, 111, 114, 121, 45, 102, 111, 99, 117, 115, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [34184295084289325, 12793321968592429, 12662, 8367235646312794908, 6609912362021128733, 4530971654964840068, 16608126435609066804, 13886058711374487922], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [97, 108, 105, 103, 110, 101, 100, 95, 110, 101, 103, 97, 116, 105, 118, 101, 95, 111, 102, 102, 115, 101, 116, 95, 114, 111, 117, 110, 100, 116, 114, 105, 112])
  , u64s := []
  , cursorBefore := { stateWords := [34184295084289325, 12793321968592429, 12662, 8367235646312794908, 6609912362021128733, 4530971654964840068, 16608126435609066804, 13886058711374487922], absorbed := 3 }
  , cursorAfter := { stateWords := [31091368958850149, 482805445732, 655864604320236571, 6132064525419946433, 13303066629308455250, 14701764113772996290, 16896551000466774424, 2427104523308801353], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [44040339, 4262804515, 4286918915, 115]
  , cursorBefore := { stateWords := [31091368958850149, 482805445732, 655864604320236571, 6132064525419946433, 13303066629308455250, 14701764113772996290, 16896551000466774424, 2427104523308801353], absorbed := 2 }
  , cursorAfter := { stateWords := [8185998919415309803, 6751908568909502979, 12238304485437407211, 4338025786865486586, 1242182938994674224, 2091725317158940936, 14957155520321564083, 16109335276935461803], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8200, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [8185998919415309803, 6751908568909502979, 12238304485437407211, 4338025786865486586, 1242182938994674224, 2091725317158940936, 14957155520321564083, 16109335276935461803], absorbed := 0 }
  , cursorAfter := { stateWords := [0, 0, 8071571767436382467, 367074159184631404, 12495501133959711755, 7670288153839030894, 10542378444128228380, 5199553576577308085], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := [8192, 13, 8200, 99]
  , cursorBefore := { stateWords := [0, 0, 8071571767436382467, 367074159184631404, 12495501133959711755, 7670288153839030894, 10542378444128228380, 5199553576577308085], absorbed := 2 }
  , cursorAfter := { stateWords := [183556792562072432, 9224561173211632783, 2060421860858788921, 12148835641439052675, 8962788091006358564, 17386743607056434080, 18363597817879301429, 12329845981819666502], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [196, 47, 73, 21, 89, 47, 90, 96, 97, 14, 113, 80, 57, 244, 48, 50, 219, 255, 79, 205, 86, 212, 1, 182, 140, 236, 129, 158, 228, 112, 219, 0])
  , u64s := []
  , cursorBefore := { stateWords := [183556792562072432, 9224561173211632783, 2060421860858788921, 12148835641439052675, 8962788091006358564, 17386743607056434080, 18363597817879301429, 12329845981819666502], absorbed := 0 }
  , cursorAfter := { stateWords := [24432591475782192, 44615899293286868, 14381284, 5095205578235086874, 7288398040109309939, 18383590422939996512, 2719869129277846673, 10950560587343908132], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [24432591475782192, 44615899293286868, 14381284, 5095205578235086874, 7288398040109309939, 18383590422939996512, 2719869129277846673, 10950560587343908132], absorbed := 3 }
  , cursorAfter := { stateWords := [1056787187556541480, 7936538220362538745, 12726305489166155438, 10033257191059226404, 13102544229850939383, 12364778379655857612, 15189509943256782053, 10541895786105299061], absorbed := 0 }
  , challengeOutput := (some 1056787187556541480)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [142, 217, 182, 138, 150, 76, 176, 209, 117, 25, 246, 139, 222, 66, 241, 101, 236, 89, 218, 142, 67, 238, 206, 4, 53, 48, 117, 115, 130, 138, 60, 69])
  , u64s := []
  , cursorBefore := { stateWords := [1056787187556541480, 7936538220362538745, 12726305489166155438, 10033257191059226404, 13102544229850939383, 12364778379655857612, 15189509943256782053, 10541895786105299061], absorbed := 0 }
  , cursorAfter := { stateWords := [19015891902293489, 32498472230113006, 1161595522, 5217794296179387164, 7843225697845465923, 11072686435381559239, 2494925774217267229, 11700978844590771639], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [19015891902293489, 32498472230113006, 1161595522, 5217794296179387164, 7843225697845465923, 11072686435381559239, 2494925774217267229, 11700978844590771639], absorbed := 3 }
  , cursorAfter := { stateWords := [9619277481828672587, 665278778681307978, 15723919770595900632, 14028528519789234328, 16076129764726026145, 14784995131326301132, 18180545218882549343, 1705424844785533457], absorbed := 0 }
  , challengeOutput := (some 9619277481828672587)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [9619277481828672587, 665278778681307978, 15723919770595900632, 14028528519789234328, 16076129764726026145, 14784995131326301132, 18180545218882549343, 1705424844785533457], absorbed := 0 }
  , cursorAfter := { stateWords := [16812727767669355212, 12697392065646144401, 3369600737815196512, 995947170979125272, 9900984208576011045, 13928646283612232713, 2445152170369013135, 1514863595043610672], absorbed := 0 }
  , challengeOutput := (some 16812727767669355212)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [227, 21, 223, 164, 30, 253, 30, 252, 35, 185, 19, 78, 208, 4, 88, 134, 20, 175, 97, 180, 193, 112, 119, 234, 96, 78, 211, 206, 96, 42, 169, 244])
  , u64s := []
  , cursorBefore := { stateWords := [16812727767669355212, 12697392065646144401, 3369600737815196512, 995947170979125272, 9900984208576011045, 13928646283612232713, 2445152170369013135, 1514863595043610672], absorbed := 0 }
  , cursorAfter := { stateWords := [54523002147341912, 58216178789283696, 4104727136, 10127024330343439705, 13517581673824157262, 427902716102401987, 3414426687606941972, 18161196869091297655], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [54523002147341912, 58216178789283696, 4104727136, 10127024330343439705, 13517581673824157262, 427902716102401987, 3414426687606941972, 18161196869091297655], absorbed := 3 }
  , cursorAfter := { stateWords := [11236326198904743827, 14532122700454992670, 10802315202157041540, 13369252553900132433, 5234822617317489414, 525355939062290597, 18087254811635658711, 3351311869823913135], absorbed := 0 }
  , challengeOutput := (some 11236326198904743827)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [242, 180, 211, 44, 136, 191, 129, 103, 121, 27, 189, 177, 57, 84, 107, 37, 200, 205, 250, 244, 70, 251, 148, 129, 186, 236, 174, 139, 158, 109, 21, 76])
  , u64s := []
  , cursorBefore := { stateWords := [11236326198904743827, 14532122700454992670, 10802315202157041540, 13369252553900132433, 5234822617317489414, 525355939062290597, 18087254811635658711, 3351311869823913135], absorbed := 0 }
  , cursorAfter := { stateWords := [19972606401193323, 39317353527350523, 1276472734, 16274229555519422653, 16974672749192474638, 4430053409062725850, 16438097491389033793, 15433633138756558878], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [48, 44, 208, 21, 233, 188, 246, 118, 80, 252, 131, 40, 26, 233, 88, 199, 128, 90, 68, 220, 142, 222, 119, 79, 4, 89, 207, 71, 146, 168, 93, 57])
  , u64s := []
  , cursorBefore := { stateWords := [19972606401193323, 39317353527350523, 1276472734, 16274229555519422653, 16974672749192474638, 4430053409062725850, 16438097491389033793, 15433633138756558878], absorbed := 3 }
  , cursorAfter := { stateWords := [40211632827189080, 20212704577812446, 962439314, 6039256894354310933, 6031758554601834355, 11278688584296007858, 3893914303756742345, 4253956639539515579], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [241, 21, 138, 101, 163, 40, 99, 15, 168, 152, 12, 213, 123, 114, 205, 136, 161, 172, 16, 50, 10, 193, 235, 221, 241, 226, 242, 67, 57, 144, 122, 37])
  , u64s := []
  , cursorBefore := { stateWords := [40211632827189080, 20212704577812446, 962439314, 6039256894354310933, 6031758554601834355, 11278688584296007858, 3893914303756742345, 4253956639539515579], absorbed := 3 }
  , cursorAfter := { stateWords := [2869796964239565, 19125879973997505, 628789305, 15867107718016502534, 742118945884326825, 3231925605746862542, 9406865583467843754, 7361031662932662875], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [2869796964239565, 19125879973997505, 628789305, 15867107718016502534, 742118945884326825, 3231925605746862542, 9406865583467843754, 7361031662932662875], absorbed := 3 }
  , cursorAfter := { stateWords := [9465929736532604617, 8420220252723389205, 3417381235763225621, 4183586137376879782, 5900319465490910417, 9092472782636357916, 17349179717391889123, 17539475516024234292], absorbed := 0 }
  , challengeOutput := (some 9465929736532604617)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [9465929736532604617, 8420220252723389205, 3417381235763225621, 4183586137376879782, 5900319465490910417, 9092472782636357916, 17349179717391889123, 17539475516024234292], absorbed := 0 }
  , cursorAfter := { stateWords := [4389844868881287918, 16069944125868069814, 18074736236063466078, 270298057294202076, 5337330470334798401, 7728982227267766060, 2381843619493432972, 12046089070115929937], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [238, 138, 189, 92, 166, 220, 235, 60, 182, 211, 189, 78, 10, 233, 3, 223, 94, 162, 113, 183, 215, 92, 214, 250, 220, 196, 127, 168, 166, 74, 192, 3]))
}]
}
  , kernel := {
  root0Digest := (bytes [196, 47, 73, 21, 89, 47, 90, 96, 97, 14, 113, 80, 57, 244, 48, 50, 219, 255, 79, 205, 86, 212, 1, 182, 140, 236, 129, 158, 228, 112, 219, 0])
  , stage1Digest := (bytes [142, 217, 182, 138, 150, 76, 176, 209, 117, 25, 246, 139, 222, 66, 241, 101, 236, 89, 218, 142, 67, 238, 206, 4, 53, 48, 117, 115, 130, 138, 60, 69])
  , stage2Digest := (bytes [227, 21, 223, 164, 30, 253, 30, 252, 35, 185, 19, 78, 208, 4, 88, 134, 20, 175, 97, 180, 193, 112, 119, 234, 96, 78, 211, 206, 96, 42, 169, 244])
  , stage3Digest := (bytes [242, 180, 211, 44, 136, 191, 129, 103, 121, 27, 189, 177, 57, 84, 107, 37, 200, 205, 250, 244, 70, 251, 148, 129, 186, 236, 174, 139, 158, 109, 21, 76])
  , executionDigest := (bytes [48, 44, 208, 21, 233, 188, 246, 118, 80, 252, 131, 40, 26, 233, 88, 199, 128, 90, 68, 220, 142, 222, 119, 79, 4, 89, 207, 71, 146, 168, 93, 57])
  , finalStateDigest := (bytes [241, 21, 138, 101, 163, 40, 99, 15, 168, 152, 12, 213, 123, 114, 205, 136, 161, 172, 16, 50, 10, 193, 235, 221, 241, 226, 242, 67, 57, 144, 122, 37])
  , stage1Mix := 1056787187556541480
  , stage2RegMix := 9619277481828672587
  , stage2RamMix := 16812727767669355212
  , stage3ContinuityMix := 11236326198904743827
  , kernelFinalMix := 9465929736532604617
  , transcriptFinalDigest := (bytes [238, 138, 189, 92, 166, 220, 235, 60, 182, 211, 189, 78, 10, 233, 3, 223, 94, 162, 113, 183, 215, 92, 214, 250, 220, 196, 127, 168, 166, 74, 192, 3])
  , finalPc := 16
  , finalRegisters := [0, 42, 42, 0, 0, 0, 0, 0, 0, 0, 8200, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , finalMemory := [{ addr := 8192, value := 42 }, { addr := 8200, value := 99 }]
  , halted := true
}
}

end Nightstream.Rv64IM.Generated.Cases.Case_aligned_negative_offset_roundtrip
