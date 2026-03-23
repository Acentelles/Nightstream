import Nightstream.Rv64IM.Generated.ParityTypes

namespace Nightstream.Rv64IM.Generated.Cases.Case_vertical_add_sd_ld_ecall

open Nightstream.Rv64IM.Generated

def derivedCase : ParityDerivedCase :=
  {
  manifest := { name := "vertical_add_sd_ld_ecall", fixtureId := "vertical_add_sd_ld_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .alignedMemory, .controlFlow] }
  , executionRows := [{
  stepIndex := 0
  , pc := 0
  , nextPc := 4
  , word := 5243027
  , opcode := .addi
  , family := .nativeAlu
  , rs1 := 0
  , rs1Value := 0
  , rs2 := 0
  , rs2Value := 0
  , rd := 1
  , rdBefore := 0
  , rdAfter := 5
  , imm := 5
  , aluResult := 5
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
  , word := 1081651
  , opcode := .add
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 5
  , rs2 := 1
  , rs2Value := 5
  , rd := 2
  , rdBefore := 0
  , rdAfter := 10
  , imm := 0
  , aluResult := 10
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
}, {
  stepIndex := 2
  , pc := 8
  , nextPc := 12
  , word := 2437155
  , opcode := .sd
  , family := .alignedMemory
  , rs1 := 10
  , rs1Value := 4096
  , rs2 := 2
  , rs2Value := 10
  , rd := 0
  , rdBefore := 0
  , rdAfter := 0
  , imm := 0
  , aluResult := 10
  , effectiveAddr := (some 4096)
  , memoryBefore := (some 0)
  , memoryAfter := (some 10)
  , writesRd := false
  , writesRam := true
  , halted := false
}, {
  stepIndex := 3
  , pc := 12
  , nextPc := 16
  , word := 340355
  , opcode := .ld
  , family := .alignedMemory
  , rs1 := 10
  , rs1Value := 4096
  , rs2 := 0
  , rs2Value := 0
  , rd := 3
  , rdBefore := 0
  , rdAfter := 10
  , imm := 0
  , aluResult := 10
  , effectiveAddr := (some 4096)
  , memoryBefore := (some 10)
  , memoryAfter := (some 10)
  , writesRd := true
  , writesRam := false
  , halted := false
}, {
  stepIndex := 4
  , pc := 16
  , nextPc := 20
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
  , stage1 := { rows := [{ stepIndex := 0, fetchPc := 0, fetchedWord := 5243027, opcode := .addi, family := .nativeAlu, nextPc := 4, aluResult := 5, effectiveAddr := none, writesRd := true, rd := 1, rdAfter := 5, preservesX0 := false }, { stepIndex := 1, fetchPc := 4, fetchedWord := 1081651, opcode := .add, family := .nativeAlu, nextPc := 8, aluResult := 10, effectiveAddr := none, writesRd := true, rd := 2, rdAfter := 10, preservesX0 := false }, { stepIndex := 2, fetchPc := 8, fetchedWord := 2437155, opcode := .sd, family := .alignedMemory, nextPc := 12, aluResult := 10, effectiveAddr := (some 4096), writesRd := false, rd := 0, rdAfter := 0, preservesX0 := true }, { stepIndex := 3, fetchPc := 12, fetchedWord := 340355, opcode := .ld, family := .alignedMemory, nextPc := 16, aluResult := 10, effectiveAddr := (some 4096), writesRd := true, rd := 3, rdAfter := 10, preservesX0 := false }, { stepIndex := 4, fetchPc := 16, fetchedWord := 115, opcode := .ecall, family := .controlFlow, nextPc := 20, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, preservesX0 := true }] }
  , stage2 := {
  registerReads := [{ stepIndex := 0, role := .rs1, reg := 0, value := 0 }, { stepIndex := 1, role := .rs1, reg := 1, value := 5 }, { stepIndex := 1, role := .rs2, reg := 1, value := 5 }, { stepIndex := 2, role := .rs1, reg := 10, value := 4096 }, { stepIndex := 3, role := .rs1, reg := 10, value := 4096 }]
  , registerWrites := [{ stepIndex := 0, reg := 1, previous := 0, next := 5 }, { stepIndex := 1, reg := 2, previous := 0, next := 10 }, { stepIndex := 3, reg := 3, previous := 0, next := 10 }]
  , ramEvents := [{ stepIndex := 2, kind := .write, addr := 4096, previous := 0, next := 10 }, { stepIndex := 3, kind := .read, addr := 4096, previous := 10, next := 10 }]
  , twistLinks := [{ stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 5), routedMemoryBefore := none, routedMemoryAfter := none }, { stepIndex := 1, family := .nativeAlu, routedWriteValue := (some 10), routedMemoryBefore := none, routedMemoryAfter := none }, { stepIndex := 2, family := .alignedMemory, routedWriteValue := none, routedMemoryBefore := (some 0), routedMemoryAfter := (some 10) }, { stepIndex := 3, family := .alignedMemory, routedWriteValue := (some 10), routedMemoryBefore := (some 10), routedMemoryAfter := (some 10) }, { stepIndex := 4, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]
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
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 118, 101, 114, 116, 105, 99, 97, 108, 45, 115, 108, 105, 99, 101, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [28538277089979756, 3241517, 11247131002411220005, 5435835552270204743, 15388508341400942211, 4572597483610962766, 14825494483880519391, 51518881347152392], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [118, 101, 114, 116, 105, 99, 97, 108, 95, 97, 100, 100, 95, 115, 100, 95, 108, 100, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [28538277089979756, 3241517, 11247131002411220005, 5435835552270204743, 15388508341400942211, 4572597483610962766, 14825494483880519391, 51518881347152392], absorbed := 2 }
  , cursorAfter := { stateWords := [15018134131099841210, 4093721524628903831, 12107099154920401332, 5405138344777535718, 9378026571548915261, 12853400877180769673, 6899204031258671695, 8311987294460978322], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [5243027, 1081651, 2437155, 340355, 115]
  , cursorBefore := { stateWords := [15018134131099841210, 4093721524628903831, 12107099154920401332, 5405138344777535718, 9378026571548915261, 12853400877180769673, 6899204031258671695, 8311987294460978322], absorbed := 0 }
  , cursorAfter := { stateWords := [13073242237465996376, 1250467122214735314, 520150815703364713, 9242552485110564463, 12848588334899739503, 2929718555086446532, 9380751848217189172, 1319530647437838763], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4096, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [13073242237465996376, 1250467122214735314, 520150815703364713, 9242552485110564463, 12848588334899739503, 2929718555086446532, 9380751848217189172, 1319530647437838763], absorbed := 0 }
  , cursorAfter := { stateWords := [0, 0, 6705560915287133513, 13408505293975691925, 10591771283367582474, 17536731636326088848, 11276534104956640532, 7493323203656352938], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := [4096, 0]
  , cursorBefore := { stateWords := [0, 0, 6705560915287133513, 13408505293975691925, 10591771283367582474, 17536731636326088848, 11276534104956640532, 7493323203656352938], absorbed := 2 }
  , cursorAfter := { stateWords := [15526256317599728511, 2568722878831804987, 16239885287391594497, 496917456094660677, 3792261335952761898, 2505621802826336562, 2596672253789177435, 11150339277950828537], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [135, 54, 179, 58, 175, 8, 113, 89, 77, 53, 240, 243, 127, 62, 36, 4, 249, 145, 43, 195, 231, 83, 112, 77, 131, 50, 114, 62, 167, 230, 250, 199])
  , u64s := []
  , cursorBefore := { stateWords := [15526256317599728511, 2568722878831804987, 16239885287391594497, 496917456094660677, 3792261335952761898, 2505621802826336562, 2596672253789177435, 11150339277950828537], absorbed := 0 }
  , cursorAfter := { stateWords := [65235311520187428, 17577009832882259, 3355109031, 7098088108992737938, 15199159180739713279, 16246857198051749921, 13825906894878008692, 7315425589310402749], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [65235311520187428, 17577009832882259, 3355109031, 7098088108992737938, 15199159180739713279, 16246857198051749921, 13825906894878008692, 7315425589310402749], absorbed := 3 }
  , cursorAfter := { stateWords := [13284789833745455176, 18407140607795037480, 16967674421196279763, 4545908446571655201, 18016966309568418852, 2424598137269674032, 9015475748579855208, 15300083809532465609], absorbed := 0 }
  , challengeOutput := (some 13284789833745455176)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [141, 60, 222, 110, 72, 134, 144, 255, 30, 29, 143, 27, 33, 27, 155, 77, 186, 43, 202, 153, 208, 77, 69, 79, 227, 135, 205, 228, 232, 125, 128, 73])
  , u64s := []
  , cursorBefore := { stateWords := [13284789833745455176, 18407140607795037480, 16967674421196279763, 4545908446571655201, 18016966309568418852, 2424598137269674032, 9015475748579855208, 15300083809532465609], absorbed := 0 }
  , cursorAfter := { stateWords := [58715888751889819, 64402278207931725, 1233157608, 14377241659299474688, 4989901967043415790, 14693409989382355077, 3818688867547531949, 4463197993533255067], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [58715888751889819, 64402278207931725, 1233157608, 14377241659299474688, 4989901967043415790, 14693409989382355077, 3818688867547531949, 4463197993533255067], absorbed := 3 }
  , cursorAfter := { stateWords := [3271685352293115224, 1809944022706024298, 4869239437444832545, 13522655261471072268, 17897824799257747025, 2219191128963985366, 12935467767798407264, 2823047734300996580], absorbed := 0 }
  , challengeOutput := (some 3271685352293115224)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [3271685352293115224, 1809944022706024298, 4869239437444832545, 13522655261471072268, 17897824799257747025, 2219191128963985366, 12935467767798407264, 2823047734300996580], absorbed := 0 }
  , cursorAfter := { stateWords := [9218866771718727688, 13109997995152223479, 9829307680778826472, 7965284470240856609, 12491745418835085191, 10279103266569047589, 3142160263433565842, 12596041497774200422], absorbed := 0 }
  , challengeOutput := (some 9218866771718727688)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [223, 239, 255, 28, 146, 192, 6, 116, 198, 27, 15, 79, 49, 195, 136, 199, 1, 166, 27, 219, 44, 172, 41, 12, 58, 56, 204, 203, 30, 230, 135, 4])
  , u64s := []
  , cursorBefore := { stateWords := [9218866771718727688, 13109997995152223479, 9829307680778826472, 7965284470240856609, 12491745418835085191, 10279103266569047589, 3142160263433565842, 12596041497774200422], absorbed := 0 }
  , cursorAfter := { stateWords := [12625810771003272, 57363962136373676, 76015134, 658990330382324414, 5505691856059335622, 6892212685702928604, 8414454523880207699, 11758051443809347878], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [12625810771003272, 57363962136373676, 76015134, 658990330382324414, 5505691856059335622, 6892212685702928604, 8414454523880207699, 11758051443809347878], absorbed := 3 }
  , cursorAfter := { stateWords := [15394704039026863757, 1394823330894368654, 16630938165649606139, 3941037561964915537, 8730646407226150473, 16811055434466578420, 7948332472488679106, 11457091133282816067], absorbed := 0 }
  , challengeOutput := (some 15394704039026863757)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [2, 183, 132, 95, 231, 115, 83, 2, 8, 179, 51, 169, 210, 224, 230, 178, 60, 35, 73, 58, 195, 121, 109, 163, 86, 206, 95, 244, 250, 18, 169, 79])
  , u64s := []
  , cursorBefore := { stateWords := [15394704039026863757, 1394823330894368654, 16630938165649606139, 3941037561964915537, 8730646407226150473, 16811055434466578420, 7948332472488679106, 11457091133282816067], absorbed := 0 }
  , cursorAfter := { stateWords := [54951706256782054, 68785234138852729, 1336480506, 6091142444155521179, 714139807984783389, 18404415564636979016, 6983580963615186070, 11638188602759427353], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [201, 164, 221, 125, 109, 222, 37, 62, 147, 92, 84, 169, 55, 144, 33, 41, 50, 90, 63, 149, 113, 201, 51, 95, 194, 1, 232, 102, 233, 121, 198, 233])
  , u64s := []
  , cursorBefore := { stateWords := [54951706256782054, 68785234138852729, 1336480506, 6091142444155521179, 714139807984783389, 18404415564636979016, 6983580963615186070, 11638188602759427353], absorbed := 3 }
  , cursorAfter := { stateWords := [31970771697019169, 28965541878117321, 3922098665, 13488886464747868322, 2693774648152640598, 10958848604694780033, 3685411586920218821, 17742351956826345716], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [40, 203, 41, 62, 45, 52, 38, 20, 4, 174, 242, 202, 246, 67, 233, 128, 197, 240, 97, 4, 68, 33, 142, 222, 96, 232, 104, 62, 196, 10, 224, 135])
  , u64s := []
  , cursorBefore := { stateWords := [31970771697019169, 28965541878117321, 3922098665, 13488886464747868322, 2693774648152640598, 10958848604694780033, 3685411586920218821, 17742351956826345716], absorbed := 3 }
  , cursorAfter := { stateWords := [19145117114138857, 17566795822960161, 2279606980, 4164349308777004802, 16293406047596688505, 2321762257387163045, 5265428952262799829, 1660736174867803745], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [19145117114138857, 17566795822960161, 2279606980, 4164349308777004802, 16293406047596688505, 2321762257387163045, 5265428952262799829, 1660736174867803745], absorbed := 3 }
  , cursorAfter := { stateWords := [4074194980095530359, 16018322859894848766, 16978167734426648606, 10141121826579587349, 6287995167082662773, 11453392136283081043, 7747834270715057250, 2068958726031090031], absorbed := 0 }
  , challengeOutput := (some 4074194980095530359)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [4074194980095530359, 16018322859894848766, 16978167734426648606, 10141121826579587349, 6287995167082662773, 11453392136283081043, 7747834270715057250, 2068958726031090031], absorbed := 0 }
  , cursorAfter := { stateWords := [593195542347662015, 16943457376105610954, 1912585542118184234, 8506393287541568248, 15059549659121664523, 13809046069210185339, 7998069989490838832, 6686271977506892650], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [191, 66, 250, 239, 51, 116, 59, 8, 202, 62, 191, 153, 182, 64, 35, 235, 42, 149, 128, 208, 106, 222, 138, 26, 248, 178, 174, 79, 160, 199, 12, 118]))
}]
}
  , kernel := {
  root0Digest := (bytes [135, 54, 179, 58, 175, 8, 113, 89, 77, 53, 240, 243, 127, 62, 36, 4, 249, 145, 43, 195, 231, 83, 112, 77, 131, 50, 114, 62, 167, 230, 250, 199])
  , stage1Digest := (bytes [141, 60, 222, 110, 72, 134, 144, 255, 30, 29, 143, 27, 33, 27, 155, 77, 186, 43, 202, 153, 208, 77, 69, 79, 227, 135, 205, 228, 232, 125, 128, 73])
  , stage2Digest := (bytes [223, 239, 255, 28, 146, 192, 6, 116, 198, 27, 15, 79, 49, 195, 136, 199, 1, 166, 27, 219, 44, 172, 41, 12, 58, 56, 204, 203, 30, 230, 135, 4])
  , stage3Digest := (bytes [2, 183, 132, 95, 231, 115, 83, 2, 8, 179, 51, 169, 210, 224, 230, 178, 60, 35, 73, 58, 195, 121, 109, 163, 86, 206, 95, 244, 250, 18, 169, 79])
  , executionDigest := (bytes [201, 164, 221, 125, 109, 222, 37, 62, 147, 92, 84, 169, 55, 144, 33, 41, 50, 90, 63, 149, 113, 201, 51, 95, 194, 1, 232, 102, 233, 121, 198, 233])
  , finalStateDigest := (bytes [40, 203, 41, 62, 45, 52, 38, 20, 4, 174, 242, 202, 246, 67, 233, 128, 197, 240, 97, 4, 68, 33, 142, 222, 96, 232, 104, 62, 196, 10, 224, 135])
  , stage1Mix := 13284789833745455176
  , stage2RegMix := 3271685352293115224
  , stage2RamMix := 9218866771718727688
  , stage3ContinuityMix := 15394704039026863757
  , kernelFinalMix := 4074194980095530359
  , transcriptFinalDigest := (bytes [191, 66, 250, 239, 51, 116, 59, 8, 202, 62, 191, 153, 182, 64, 35, 235, 42, 149, 128, 208, 106, 222, 138, 26, 248, 178, 174, 79, 160, 199, 12, 118])
  , finalPc := 20
  , finalRegisters := [0, 5, 10, 10, 0, 0, 0, 0, 0, 0, 4096, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , finalMemory := [{ addr := 4096, value := 10 }]
  , halted := true
}
}

end Nightstream.Rv64IM.Generated.Cases.Case_vertical_add_sd_ld_ecall
