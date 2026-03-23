import Nightstream.Rv64IM.Generated.ParityTypes

namespace Nightstream.Rv64IM.Generated.Cases.Case_aligned_negative_offset_roundtrip

open Nightstream.Rv64IM.Generated

def derivedCase : ParityDerivedCase :=
  {
  manifest := { name := "aligned_negative_offset_roundtrip", fixtureId := "aligned_negative_offset_roundtrip_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .alignedMemory, .controlFlow] }
  , executionRows := [{
  stepIndex := 0
  , pc := 0
  , nextPc := 4
  , word := 44040339
  , opcode := .addi
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
}, {
  stepIndex := 1
  , pc := 4
  , nextPc := 8
  , word := 4262804515
  , opcode := .sd
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
}, {
  stepIndex := 2
  , pc := 8
  , nextPc := 12
  , word := 4286918915
  , opcode := .ld
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
}, {
  stepIndex := 3
  , pc := 12
  , nextPc := 16
  , word := 115
  , opcode := .ecall
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
}]
  , stage1 := { rows := [{ stepIndex := 0, fetchPc := 0, fetchedWord := 44040339, opcode := .addi, family := .nativeAlu, nextPc := 4, aluResult := 42, effectiveAddr := none, writesRd := true, rd := 1, rdAfter := 42, preservesX0 := false }, { stepIndex := 1, fetchPc := 4, fetchedWord := 4262804515, opcode := .sd, family := .alignedMemory, nextPc := 8, aluResult := 42, effectiveAddr := (some 8192), writesRd := false, rd := 0, rdAfter := 0, preservesX0 := true }, { stepIndex := 2, fetchPc := 8, fetchedWord := 4286918915, opcode := .ld, family := .alignedMemory, nextPc := 12, aluResult := 42, effectiveAddr := (some 8192), writesRd := true, rd := 2, rdAfter := 42, preservesX0 := false }, { stepIndex := 3, fetchPc := 12, fetchedWord := 115, opcode := .ecall, family := .controlFlow, nextPc := 16, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, preservesX0 := true }] }
  , stage2 := {
  registerReads := [{ stepIndex := 0, role := .rs1, reg := 0, value := 0 }, { stepIndex := 1, role := .rs1, reg := 10, value := 8200 }, { stepIndex := 2, role := .rs1, reg := 10, value := 8200 }]
  , registerWrites := [{ stepIndex := 0, reg := 1, previous := 0, next := 42 }, { stepIndex := 2, reg := 2, previous := 0, next := 42 }]
  , ramEvents := [{ stepIndex := 1, kind := .write, addr := 8192, previous := 13, next := 42 }, { stepIndex := 2, kind := .read, addr := 8192, previous := 42, next := 42 }]
  , twistLinks := [{ stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 42), routedMemoryBefore := none, routedMemoryAfter := none }, { stepIndex := 1, family := .alignedMemory, routedWriteValue := none, routedMemoryBefore := (some 13), routedMemoryAfter := (some 42) }, { stepIndex := 2, family := .alignedMemory, routedWriteValue := (some 42), routedMemoryBefore := (some 42), routedMemoryAfter := (some 42) }, { stepIndex := 3, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]
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
  , message := (bytes [133, 33, 172, 140, 233, 72, 46, 209, 48, 165, 182, 74, 209, 48, 22, 152, 88, 9, 98, 197, 159, 186, 241, 163, 39, 42, 69, 121, 8, 165, 34, 71])
  , u64s := []
  , cursorBefore := { stateWords := [1056787187556541480, 7936538220362538745, 12726305489166155438, 10033257191059226404, 13102544229850939383, 12364778379655857612, 15189509943256782053, 10541895786105299061], absorbed := 0 }
  , cursorAfter := { stateWords := [44971546151262230, 34134519537988026, 1193452808, 17884890454721098756, 8742815067097544182, 5833030316974842334, 14069376335563075677, 3519699764892988818], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [44971546151262230, 34134519537988026, 1193452808, 17884890454721098756, 8742815067097544182, 5833030316974842334, 14069376335563075677, 3519699764892988818], absorbed := 3 }
  , cursorAfter := { stateWords := [4238065095073052119, 7684052836494449271, 7854541950336389888, 7221685285076890941, 14401953932402353816, 15749992700437426292, 2494728818235671694, 1880941987735485193], absorbed := 0 }
  , challengeOutput := (some 4238065095073052119)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [4238065095073052119, 7684052836494449271, 7854541950336389888, 7221685285076890941, 14401953932402353816, 15749992700437426292, 2494728818235671694, 1880941987735485193], absorbed := 0 }
  , cursorAfter := { stateWords := [14880338601956528058, 11417287982766265704, 1999846905328034605, 3268762540683447153, 3041808325429348029, 11723622584960079147, 3267801232616282909, 1903437023102932086], absorbed := 0 }
  , challengeOutput := (some 14880338601956528058)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [99, 28, 72, 198, 124, 237, 213, 46, 85, 239, 4, 76, 205, 104, 112, 135, 151, 48, 199, 18, 8, 29, 82, 0, 29, 46, 209, 175, 11, 65, 240, 59])
  , u64s := []
  , cursorBefore := { stateWords := [14880338601956528058, 11417287982766265704, 1999846905328034605, 3268762540683447153, 3041808325429348029, 11723622584960079147, 3267801232616282909, 1903437023102932086], absorbed := 0 }
  , cursorAfter := { stateWords := [2272446536714096, 49488116909625885, 1005601035, 16834913648610405511, 10676089165022083198, 2351153205109985000, 15294516587064208466, 12458758220113967936], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [2272446536714096, 49488116909625885, 1005601035, 16834913648610405511, 10676089165022083198, 2351153205109985000, 15294516587064208466, 12458758220113967936], absorbed := 3 }
  , cursorAfter := { stateWords := [18307016013854385768, 386090934767535184, 301195876403596823, 8691723873807917873, 16010316393357224490, 5609107225314861888, 2143909010010563256, 617300435659316442], absorbed := 0 }
  , challengeOutput := (some 18307016013854385768)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [242, 180, 211, 44, 136, 191, 129, 103, 121, 27, 189, 177, 57, 84, 107, 37, 200, 205, 250, 244, 70, 251, 148, 129, 186, 236, 174, 139, 158, 109, 21, 76])
  , u64s := []
  , cursorBefore := { stateWords := [18307016013854385768, 386090934767535184, 301195876403596823, 8691723873807917873, 16010316393357224490, 5609107225314861888, 2143909010010563256, 617300435659316442], absorbed := 0 }
  , cursorAfter := { stateWords := [19972606401193323, 39317353527350523, 1276472734, 16900528731064752535, 15933562643972886562, 9693504331108410883, 18331968259489044684, 11793688974313911503], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [45, 139, 239, 85, 27, 12, 138, 44, 207, 170, 242, 243, 57, 214, 167, 103, 64, 10, 131, 45, 76, 123, 145, 234, 211, 58, 109, 152, 0, 38, 77, 105])
  , u64s := []
  , cursorBefore := { stateWords := [19972606401193323, 39317353527350523, 1276472734, 16900528731064752535, 15933562643972886562, 9693504331108410883, 18331968259489044684, 11793688974313911503], absorbed := 3 }
  , cursorAfter := { stateWords := [21442139065968551, 42904295890915707, 1766663680, 10458115475421553961, 9773600212131026291, 13845302979605083383, 9838001921692512024, 15293084120696307460], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [241, 21, 138, 101, 163, 40, 99, 15, 168, 152, 12, 213, 123, 114, 205, 136, 161, 172, 16, 50, 10, 193, 235, 221, 241, 226, 242, 67, 57, 144, 122, 37])
  , u64s := []
  , cursorBefore := { stateWords := [21442139065968551, 42904295890915707, 1766663680, 10458115475421553961, 9773600212131026291, 13845302979605083383, 9838001921692512024, 15293084120696307460], absorbed := 3 }
  , cursorAfter := { stateWords := [2869796964239565, 19125879973997505, 628789305, 1917667635319776294, 9398324432138629513, 18287976505901795566, 578311037544406826, 10417819720721837766], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [2869796964239565, 19125879973997505, 628789305, 1917667635319776294, 9398324432138629513, 18287976505901795566, 578311037544406826, 10417819720721837766], absorbed := 3 }
  , cursorAfter := { stateWords := [10198769342489062892, 9560620643758735775, 883114345830561381, 1543446596572376349, 927444997298294527, 2093159359449483533, 5723733942285223712, 5465858754595007560], absorbed := 0 }
  , challengeOutput := (some 10198769342489062892)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [10198769342489062892, 9560620643758735775, 883114345830561381, 1543446596572376349, 927444997298294527, 2093159359449483533, 5723733942285223712, 5465858754595007560], absorbed := 0 }
  , cursorAfter := { stateWords := [15419860829055723611, 2987260217215641730, 9435454222050012773, 6365062609455462017, 11259537094546917016, 7651890499768272024, 10334182728623754604, 9408803761618098517], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [91, 168, 211, 225, 185, 89, 254, 213, 130, 104, 203, 34, 87, 225, 116, 41, 101, 46, 192, 175, 159, 119, 241, 130, 129, 182, 182, 65, 184, 62, 85, 88]))
}]
}
  , kernel := {
  root0Digest := (bytes [196, 47, 73, 21, 89, 47, 90, 96, 97, 14, 113, 80, 57, 244, 48, 50, 219, 255, 79, 205, 86, 212, 1, 182, 140, 236, 129, 158, 228, 112, 219, 0])
  , stage1Digest := (bytes [133, 33, 172, 140, 233, 72, 46, 209, 48, 165, 182, 74, 209, 48, 22, 152, 88, 9, 98, 197, 159, 186, 241, 163, 39, 42, 69, 121, 8, 165, 34, 71])
  , stage2Digest := (bytes [99, 28, 72, 198, 124, 237, 213, 46, 85, 239, 4, 76, 205, 104, 112, 135, 151, 48, 199, 18, 8, 29, 82, 0, 29, 46, 209, 175, 11, 65, 240, 59])
  , stage3Digest := (bytes [242, 180, 211, 44, 136, 191, 129, 103, 121, 27, 189, 177, 57, 84, 107, 37, 200, 205, 250, 244, 70, 251, 148, 129, 186, 236, 174, 139, 158, 109, 21, 76])
  , executionDigest := (bytes [45, 139, 239, 85, 27, 12, 138, 44, 207, 170, 242, 243, 57, 214, 167, 103, 64, 10, 131, 45, 76, 123, 145, 234, 211, 58, 109, 152, 0, 38, 77, 105])
  , finalStateDigest := (bytes [241, 21, 138, 101, 163, 40, 99, 15, 168, 152, 12, 213, 123, 114, 205, 136, 161, 172, 16, 50, 10, 193, 235, 221, 241, 226, 242, 67, 57, 144, 122, 37])
  , stage1Mix := 1056787187556541480
  , stage2RegMix := 4238065095073052119
  , stage2RamMix := 14880338601956528058
  , stage3ContinuityMix := 18307016013854385768
  , kernelFinalMix := 10198769342489062892
  , transcriptFinalDigest := (bytes [91, 168, 211, 225, 185, 89, 254, 213, 130, 104, 203, 34, 87, 225, 116, 41, 101, 46, 192, 175, 159, 119, 241, 130, 129, 182, 182, 65, 184, 62, 85, 88])
  , finalPc := 16
  , finalRegisters := [0, 42, 42, 0, 0, 0, 0, 0, 0, 0, 8200, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , finalMemory := [{ addr := 8192, value := 42 }, { addr := 8200, value := 99 }]
  , halted := true
}
}

end Nightstream.Rv64IM.Generated.Cases.Case_aligned_negative_offset_roundtrip
