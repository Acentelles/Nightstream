import Nightstream.Rv64IM.Generated.ParityTypes

namespace Nightstream.Rv64IM.Generated.Cases.Case_native_add_chain_x0_ecall

open Nightstream.Rv64IM.Generated

def derivedCase : ParityDerivedCase :=
  {
  manifest := { name := "native_add_chain_x0_ecall", fixtureId := "native_add_chain_x0_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , executionRows := [{
  stepIndex := 0
  , pc := 0
  , nextPc := 4
  , word := 7340179
  , opcode := .addi
  , family := .nativeAlu
  , rs1 := 0
  , rs1Value := 0
  , rs2 := 0
  , rs2Value := 0
  , rd := 1
  , rdBefore := 0
  , rdAfter := 7
  , imm := 7
  , aluResult := 7
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
  , word := 9470227
  , opcode := .addi
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 7
  , rs2 := 0
  , rs2Value := 0
  , rd := 2
  , rdBefore := 0
  , rdAfter := 16
  , imm := 9
  , aluResult := 16
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
  , word := 1114547
  , opcode := .add
  , family := .nativeAlu
  , rs1 := 2
  , rs1Value := 16
  , rs2 := 1
  , rs2Value := 7
  , rd := 3
  , rdBefore := 0
  , rdAfter := 23
  , imm := 0
  , aluResult := 23
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
}, {
  stepIndex := 3
  , pc := 12
  , nextPc := 16
  , word := 5341203
  , opcode := .addi
  , family := .nativeAlu
  , rs1 := 3
  , rs1Value := 23
  , rs2 := 0
  , rs2Value := 0
  , rd := 0
  , rdBefore := 0
  , rdAfter := 0
  , imm := 5
  , aluResult := 28
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := false
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
  , stage1 := { rows := [{ stepIndex := 0, fetchPc := 0, fetchedWord := 7340179, opcode := .addi, family := .nativeAlu, nextPc := 4, aluResult := 7, effectiveAddr := none, writesRd := true, rd := 1, rdAfter := 7, preservesX0 := false }, { stepIndex := 1, fetchPc := 4, fetchedWord := 9470227, opcode := .addi, family := .nativeAlu, nextPc := 8, aluResult := 16, effectiveAddr := none, writesRd := true, rd := 2, rdAfter := 16, preservesX0 := false }, { stepIndex := 2, fetchPc := 8, fetchedWord := 1114547, opcode := .add, family := .nativeAlu, nextPc := 12, aluResult := 23, effectiveAddr := none, writesRd := true, rd := 3, rdAfter := 23, preservesX0 := false }, { stepIndex := 3, fetchPc := 12, fetchedWord := 5341203, opcode := .addi, family := .nativeAlu, nextPc := 16, aluResult := 28, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, preservesX0 := true }, { stepIndex := 4, fetchPc := 16, fetchedWord := 115, opcode := .ecall, family := .controlFlow, nextPc := 20, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, preservesX0 := true }] }
  , stage2 := {
  registerReads := [{ stepIndex := 0, role := .rs1, reg := 0, value := 0 }, { stepIndex := 1, role := .rs1, reg := 1, value := 7 }, { stepIndex := 2, role := .rs1, reg := 2, value := 16 }, { stepIndex := 2, role := .rs2, reg := 1, value := 7 }, { stepIndex := 3, role := .rs1, reg := 3, value := 23 }]
  , registerWrites := [{ stepIndex := 0, reg := 1, previous := 0, next := 7 }, { stepIndex := 1, reg := 2, previous := 0, next := 16 }, { stepIndex := 2, reg := 3, previous := 0, next := 23 }]
  , ramEvents := []
  , twistLinks := [{ stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 7), routedMemoryBefore := none, routedMemoryAfter := none }, { stepIndex := 1, family := .nativeAlu, routedWriteValue := (some 16), routedMemoryBefore := none, routedMemoryAfter := none }, { stepIndex := 2, family := .nativeAlu, routedWriteValue := (some 23), routedMemoryBefore := none, routedMemoryAfter := none }, { stepIndex := 3, family := .nativeAlu, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }, { stepIndex := 4, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]
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
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 110, 97, 116, 105, 118, 101, 45, 97, 108, 117, 45, 102, 111, 99, 117, 115, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [27988507334372449, 212436087669, 14264303989960973401, 3215849794886146390, 10042860024979054934, 15257409885963832532, 2376093066444741576, 18193299644673243561], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [110, 97, 116, 105, 118, 101, 95, 97, 100, 100, 95, 99, 104, 97, 105, 110, 95, 120, 48, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [27988507334372449, 212436087669, 14264303989960973401, 3215849794886146390, 10042860024979054934, 15257409885963832532, 2376093066444741576, 18193299644673243561], absorbed := 2 }
  , cursorAfter := { stateWords := [4548024108268397587, 16458779747321873702, 2666937373414097358, 16910391511651017512, 11398115826373143875, 16109463991283723855, 3475229583654167426, 12764927656275458301], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [7340179, 9470227, 1114547, 5341203, 115]
  , cursorBefore := { stateWords := [4548024108268397587, 16458779747321873702, 2666937373414097358, 16910391511651017512, 11398115826373143875, 16109463991283723855, 3475229583654167426, 12764927656275458301], absorbed := 0 }
  , cursorAfter := { stateWords := [10196448457963954601, 14546862249488034473, 10261940889723612426, 10229600108539305089, 17500297838859746622, 164642097475240703, 8065733747467251880, 9786555401515593789], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [10196448457963954601, 14546862249488034473, 10261940889723612426, 10229600108539305089, 17500297838859746622, 164642097475240703, 8065733747467251880, 9786555401515593789], absorbed := 0 }
  , cursorAfter := { stateWords := [0, 0, 16876402198132634995, 3207221032579994089, 8206132730277703886, 11042399392411210402, 7981446409608069835, 2348842280716452947], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [0, 0, 16876402198132634995, 3207221032579994089, 8206132730277703886, 11042399392411210402, 7981446409608069835, 2348842280716452947], absorbed := 2 }
  , cursorAfter := { stateWords := [13348506805888363, 30506403037277801, 34184295084289375, 0, 11793658172603017654, 6996695863839993320, 4748336754983773800, 7388682435183580689], absorbed := 4 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [180, 13, 240, 255, 164, 232, 222, 97, 177, 11, 32, 24, 102, 152, 125, 177, 128, 117, 228, 217, 234, 14, 130, 121, 56, 156, 37, 6, 1, 131, 194, 68])
  , u64s := []
  , cursorBefore := { stateWords := [13348506805888363, 30506403037277801, 34184295084289375, 0, 11793658172603017654, 6996695863839993320, 4748336754983773800, 7388682435183580689], absorbed := 4 }
  , cursorAfter := { stateWords := [66104719797432701, 1730202752877070, 1153598209, 6034386762256108278, 13454175237798974208, 3821292413083577093, 10497702945218391943, 879049951455548088], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [66104719797432701, 1730202752877070, 1153598209, 6034386762256108278, 13454175237798974208, 3821292413083577093, 10497702945218391943, 879049951455548088], absorbed := 3 }
  , cursorAfter := { stateWords := [14162923987488775188, 16797307657322594565, 530713704682432301, 2942947176314579868, 11936791481576444726, 9325970481356129627, 4446927050108005644, 15728051887681725599], absorbed := 0 }
  , challengeOutput := (some 14162923987488775188)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [240, 249, 23, 149, 131, 235, 113, 183, 46, 202, 253, 100, 220, 100, 157, 165, 43, 172, 132, 241, 245, 20, 96, 206, 98, 63, 204, 29, 173, 237, 194, 7])
  , u64s := []
  , cursorBefore := { stateWords := [14162923987488775188, 16797307657322594565, 530713704682432301, 2942947176314579868, 11936791481576444726, 9325970481356129627, 4446927050108005644, 15728051887681725599], absorbed := 0 }
  , cursorAfter := { stateWords := [69226921420629405, 8387346937307156, 130215341, 16197312674555511892, 6027628805459744775, 15200988497287117841, 14388462714546168722, 5856018266703160773], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [69226921420629405, 8387346937307156, 130215341, 16197312674555511892, 6027628805459744775, 15200988497287117841, 14388462714546168722, 5856018266703160773], absorbed := 3 }
  , cursorAfter := { stateWords := [8139393358631315419, 13218483736249968482, 4760049131843852239, 5031021291050480498, 6877887106617442218, 16206976676798311079, 10288723963876363730, 11631343917010133954], absorbed := 0 }
  , challengeOutput := (some 8139393358631315419)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [8139393358631315419, 13218483736249968482, 4760049131843852239, 5031021291050480498, 6877887106617442218, 16206976676798311079, 10288723963876363730, 11631343917010133954], absorbed := 0 }
  , cursorAfter := { stateWords := [10734980643415565248, 9889223767871461876, 6287519865353795241, 1402383844604226350, 18164129097257444094, 17556134554563490851, 9565916361687195893, 12417185346610599388], absorbed := 0 }
  , challengeOutput := (some 10734980643415565248)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [220, 215, 97, 102, 101, 209, 86, 10, 104, 18, 194, 206, 38, 168, 170, 130, 176, 82, 186, 212, 158, 172, 30, 24, 104, 217, 114, 151, 22, 224, 223, 28])
  , u64s := []
  , cursorBefore := { stateWords := [10734980643415565248, 9889223767871461876, 6287519865353795241, 1402383844604226350, 18164129097257444094, 17556134554563490851, 9565916361687195893, 12417185346610599388], absorbed := 0 }
  , cursorAfter := { stateWords := [44706943036588714, 42628999563189932, 484433942, 8311694749377968331, 4435841898961262431, 14916184120896260399, 8761448226975787589, 7865784165576009749], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [44706943036588714, 42628999563189932, 484433942, 8311694749377968331, 4435841898961262431, 14916184120896260399, 8761448226975787589, 7865784165576009749], absorbed := 3 }
  , cursorAfter := { stateWords := [6819642771539643300, 10858397424638744433, 10386259815162601429, 7035107629675307799, 9449901303446914790, 7258652820027410714, 2447023727957229652, 2507186634934719116], absorbed := 0 }
  , challengeOutput := (some 6819642771539643300)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [2, 183, 132, 95, 231, 115, 83, 2, 8, 179, 51, 169, 210, 224, 230, 178, 60, 35, 73, 58, 195, 121, 109, 163, 86, 206, 95, 244, 250, 18, 169, 79])
  , u64s := []
  , cursorBefore := { stateWords := [6819642771539643300, 10858397424638744433, 10386259815162601429, 7035107629675307799, 9449901303446914790, 7258652820027410714, 2447023727957229652, 2507186634934719116], absorbed := 0 }
  , cursorAfter := { stateWords := [54951706256782054, 68785234138852729, 1336480506, 17530294576912649592, 5622163684679052503, 10326071321547977822, 11321196841755969154, 5284813999308685478], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [215, 59, 59, 133, 41, 20, 121, 164, 97, 118, 197, 96, 39, 22, 54, 63, 26, 231, 87, 233, 137, 52, 195, 29, 243, 165, 199, 218, 129, 216, 215, 230])
  , u64s := []
  , cursorBefore := { stateWords := [54951706256782054, 68785234138852729, 1336480506, 17530294576912649592, 5622163684679052503, 10326071321547977822, 11321196841755969154, 5284813999308685478], absorbed := 3 }
  , cursorAfter := { stateWords := [38818635558043446, 61581060485268276, 3872905345, 1523216988827745902, 17072551728395310992, 8326446700143070089, 15078769462727108412, 12773081427968202432], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [214, 96, 46, 11, 248, 13, 42, 132, 141, 230, 122, 96, 107, 25, 184, 147, 236, 239, 156, 156, 238, 48, 125, 174, 84, 192, 136, 2, 174, 167, 250, 118])
  , u64s := []
  , cursorBefore := { stateWords := [38818635558043446, 61581060485268276, 3872905345, 1523216988827745902, 17072551728395310992, 8326446700143070089, 15078769462727108412, 12773081427968202432], absorbed := 3 }
  , cursorAfter := { stateWords := [67163242311226296, 713309589241136, 1996138414, 17127048905021460476, 12619637625836344466, 10818113000672301117, 8331622119130417078, 13094019160208046728], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [67163242311226296, 713309589241136, 1996138414, 17127048905021460476, 12619637625836344466, 10818113000672301117, 8331622119130417078, 13094019160208046728], absorbed := 3 }
  , cursorAfter := { stateWords := [9551110893071342933, 15397613102412001879, 11213459168980495927, 13615848396704311204, 11251209228751699738, 9901087859667229297, 2331505264940252525, 4864090530200345794], absorbed := 0 }
  , challengeOutput := (some 9551110893071342933)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [9551110893071342933, 15397613102412001879, 11213459168980495927, 13615848396704311204, 11251209228751699738, 9901087859667229297, 2331505264940252525, 4864090530200345794], absorbed := 0 }
  , cursorAfter := { stateWords := [11745583248183375644, 10606750546150857260, 12963283598297508031, 11142930475946385654, 456244231809128156, 17191399727706706762, 6184777101887448439, 5177202585976750721], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [28, 183, 191, 195, 187, 177, 0, 163, 44, 154, 128, 188, 108, 191, 50, 147, 191, 168, 43, 15, 192, 213, 230, 179, 246, 160, 168, 231, 58, 164, 163, 154]))
}]
}
  , kernel := {
  root0Digest := (bytes [180, 13, 240, 255, 164, 232, 222, 97, 177, 11, 32, 24, 102, 152, 125, 177, 128, 117, 228, 217, 234, 14, 130, 121, 56, 156, 37, 6, 1, 131, 194, 68])
  , stage1Digest := (bytes [240, 249, 23, 149, 131, 235, 113, 183, 46, 202, 253, 100, 220, 100, 157, 165, 43, 172, 132, 241, 245, 20, 96, 206, 98, 63, 204, 29, 173, 237, 194, 7])
  , stage2Digest := (bytes [220, 215, 97, 102, 101, 209, 86, 10, 104, 18, 194, 206, 38, 168, 170, 130, 176, 82, 186, 212, 158, 172, 30, 24, 104, 217, 114, 151, 22, 224, 223, 28])
  , stage3Digest := (bytes [2, 183, 132, 95, 231, 115, 83, 2, 8, 179, 51, 169, 210, 224, 230, 178, 60, 35, 73, 58, 195, 121, 109, 163, 86, 206, 95, 244, 250, 18, 169, 79])
  , executionDigest := (bytes [215, 59, 59, 133, 41, 20, 121, 164, 97, 118, 197, 96, 39, 22, 54, 63, 26, 231, 87, 233, 137, 52, 195, 29, 243, 165, 199, 218, 129, 216, 215, 230])
  , finalStateDigest := (bytes [214, 96, 46, 11, 248, 13, 42, 132, 141, 230, 122, 96, 107, 25, 184, 147, 236, 239, 156, 156, 238, 48, 125, 174, 84, 192, 136, 2, 174, 167, 250, 118])
  , stage1Mix := 14162923987488775188
  , stage2RegMix := 8139393358631315419
  , stage2RamMix := 10734980643415565248
  , stage3ContinuityMix := 6819642771539643300
  , kernelFinalMix := 9551110893071342933
  , transcriptFinalDigest := (bytes [28, 183, 191, 195, 187, 177, 0, 163, 44, 154, 128, 188, 108, 191, 50, 147, 191, 168, 43, 15, 192, 213, 230, 179, 246, 160, 168, 231, 58, 164, 163, 154])
  , finalPc := 20
  , finalRegisters := [0, 7, 16, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , finalMemory := []
  , halted := true
}
}

end Nightstream.Rv64IM.Generated.Cases.Case_native_add_chain_x0_ecall
