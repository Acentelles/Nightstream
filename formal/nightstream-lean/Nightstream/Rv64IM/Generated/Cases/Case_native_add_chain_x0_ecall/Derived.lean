import Nightstream.Rv64IM.Generated.ParityTypes

namespace Nightstream.Rv64IM.Generated.Cases.Case_native_add_chain_x0_ecall

open Nightstream.Rv64IM.Generated

def derivedCase : ParityDerivedCase :=
  {
  manifest := { name := "native_add_chain_x0_ecall", fixtureId := "native_add_chain_x0_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , executionRows := [{
  traceIndex := 0
  , stepIndex := 0
  , sequenceIndex := 0
  , pc := 0
  , nextPc := 4
  , word := 7340179
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
  , rdAfter := 7
  , imm := 7
  , aluResult := 7
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
  , word := 9470227
  , opcode := .addi
  , traceOpcode := (some .addi)
  , traceVirtualOpcode := none
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
  , word := 1114547
  , opcode := .add
  , traceOpcode := (some .add)
  , traceVirtualOpcode := none
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
  , word := 5341203
  , opcode := .addi
  , traceOpcode := (some .addi)
  , traceVirtualOpcode := none
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
  , stage1 := { rows := [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 7340179, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 4, aluResult := 7, effectiveAddr := none, writesRd := true, rd := 1, rdAfter := 7, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 9470227, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 8, aluResult := 16, effectiveAddr := none, writesRd := true, rd := 2, rdAfter := 16, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 1114547, opcode := .add, traceOpcode := (some .add), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 12, aluResult := 23, effectiveAddr := none, writesRd := true, rd := 3, rdAfter := 23, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 12, fetchedWord := 5341203, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 16, aluResult := 28, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }, { traceIndex := 4, stepIndex := 4, sequenceIndex := 0, fetchPc := 16, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 20, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }] }
  , stage2 := {
  registerReads := [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 0, value := 0 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 1, value := 7 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 2, value := 16 }, { traceIndex := 2, stepIndex := 2, role := .rs2, reg := 1, value := 7 }, { traceIndex := 3, stepIndex := 3, role := .rs1, reg := 3, value := 23 }]
  , registerWrites := [{ traceIndex := 0, stepIndex := 0, reg := 1, previous := 0, next := 7 }, { traceIndex := 1, stepIndex := 1, reg := 2, previous := 0, next := 16 }, { traceIndex := 2, stepIndex := 2, reg := 3, previous := 0, next := 23 }]
  , ramEvents := []
  , twistLinks := [{ traceIndex := 0, stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 7), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 1, family := .nativeAlu, routedWriteValue := (some 16), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 2, family := .nativeAlu, routedWriteValue := (some 23), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 3, family := .nativeAlu, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 4, stepIndex := 4, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]
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
  , message := (bytes [180, 42, 129, 179, 124, 135, 212, 151, 194, 155, 111, 92, 136, 232, 113, 76, 56, 79, 211, 209, 190, 95, 243, 229, 22, 35, 90, 1, 212, 71, 253, 137])
  , u64s := []
  , cursorBefore := { stateWords := [14162923987488775188, 16797307657322594565, 530713704682432301, 2942947176314579868, 11936791481576444726, 9325970481356129627, 4446927050108005644, 15728051887681725599], absorbed := 0 }
  , cursorAfter := { stateWords := [53710951072418929, 380581731234655, 2315077588, 404471089951566819, 14089304587772672862, 16656098479840386833, 10424890583566839609, 4791640054766733115], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [53710951072418929, 380581731234655, 2315077588, 404471089951566819, 14089304587772672862, 16656098479840386833, 10424890583566839609, 4791640054766733115], absorbed := 3 }
  , cursorAfter := { stateWords := [3542089801700290441, 15989248133429080221, 15450858065214567725, 13531568519816715489, 11267871421064434828, 3272923391998002674, 10703006732886903138, 14204686936515922466], absorbed := 0 }
  , challengeOutput := (some 3542089801700290441)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [3542089801700290441, 15989248133429080221, 15450858065214567725, 13531568519816715489, 11267871421064434828, 3272923391998002674, 10703006732886903138, 14204686936515922466], absorbed := 0 }
  , cursorAfter := { stateWords := [1893458894779210205, 812326305289413823, 10161234340347135244, 13653044259230838721, 17695336033281440862, 10048405349083874784, 16033713234919680004, 11141048178547555840], absorbed := 0 }
  , challengeOutput := (some 1893458894779210205)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [22, 68, 145, 88, 70, 235, 218, 223, 184, 4, 4, 2, 46, 118, 45, 170, 162, 155, 203, 98, 78, 226, 202, 3, 189, 168, 151, 175, 235, 8, 242, 75])
  , u64s := []
  , cursorBefore := { stateWords := [1893458894779210205, 812326305289413823, 10161234340347135244, 13653044259230838721, 17695336033281440862, 10048405349083874784, 16033713234919680004, 11141048178547555840], absorbed := 0 }
  , cursorAfter := { stateWords := [22063674812443181, 49424871905807074, 1274153195, 2606202183321751015, 9793602104467038969, 11594609792378511356, 16393035658489701835, 15272129164648251291], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [22063674812443181, 49424871905807074, 1274153195, 2606202183321751015, 9793602104467038969, 11594609792378511356, 16393035658489701835, 15272129164648251291], absorbed := 3 }
  , cursorAfter := { stateWords := [21093517096960194, 2416446498580145112, 15036473547133881006, 8935108432444238906, 2900124145724394133, 2440633520413837267, 15440863046338638624, 2313901459075905788], absorbed := 0 }
  , challengeOutput := (some 21093517096960194)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [2, 183, 132, 95, 231, 115, 83, 2, 8, 179, 51, 169, 210, 224, 230, 178, 60, 35, 73, 58, 195, 121, 109, 163, 86, 206, 95, 244, 250, 18, 169, 79])
  , u64s := []
  , cursorBefore := { stateWords := [21093517096960194, 2416446498580145112, 15036473547133881006, 8935108432444238906, 2900124145724394133, 2440633520413837267, 15440863046338638624, 2313901459075905788], absorbed := 0 }
  , cursorAfter := { stateWords := [54951706256782054, 68785234138852729, 1336480506, 13312918721026762067, 7548919176969219603, 6467068837536569256, 8250963372448177880, 7132957405155702158], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [70, 186, 27, 221, 111, 194, 9, 233, 22, 165, 61, 66, 109, 14, 68, 56, 20, 142, 12, 163, 129, 72, 137, 138, 73, 128, 143, 30, 210, 235, 246, 84])
  , u64s := []
  , cursorBefore := { stateWords := [54951706256782054, 68785234138852729, 1336480506, 13312918721026762067, 7548919176969219603, 6467068837536569256, 8250963372448177880, 7132957405155702158], absorbed := 3 }
  , cursorAfter := { stateWords := [36489546314299460, 8602030453721416, 1425468370, 16845038968027811897, 3921973807929114099, 6498152509050841659, 12536473935488698754, 16968293454958256282], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [214, 96, 46, 11, 248, 13, 42, 132, 141, 230, 122, 96, 107, 25, 184, 147, 236, 239, 156, 156, 238, 48, 125, 174, 84, 192, 136, 2, 174, 167, 250, 118])
  , u64s := []
  , cursorBefore := { stateWords := [36489546314299460, 8602030453721416, 1425468370, 16845038968027811897, 3921973807929114099, 6498152509050841659, 12536473935488698754, 16968293454958256282], absorbed := 3 }
  , cursorAfter := { stateWords := [67163242311226296, 713309589241136, 1996138414, 13546141364609595884, 16578488933848569204, 16579114827311917326, 17871472054472850269, 11756656043216378765], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [67163242311226296, 713309589241136, 1996138414, 13546141364609595884, 16578488933848569204, 16579114827311917326, 17871472054472850269, 11756656043216378765], absorbed := 3 }
  , cursorAfter := { stateWords := [5468147942805659531, 17238503707109928287, 7052256589673988831, 7328138982349877794, 12187169204440480555, 17479710813576912342, 15342398676419493878, 4399029470200577025], absorbed := 0 }
  , challengeOutput := (some 5468147942805659531)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [5468147942805659531, 17238503707109928287, 7052256589673988831, 7328138982349877794, 12187169204440480555, 17479710813576912342, 15342398676419493878, 4399029470200577025], absorbed := 0 }
  , cursorAfter := { stateWords := [18379309476364143752, 10895034626629875984, 5100374944943901232, 9168384227471191787, 12702394029829764885, 13753893388893541142, 5270430751389827923, 13147145436996363948], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [136, 204, 167, 75, 151, 108, 16, 255, 16, 185, 218, 191, 68, 240, 50, 151, 48, 10, 175, 78, 253, 43, 200, 70, 235, 238, 182, 242, 224, 164, 60, 127]))
}]
}
  , kernel := {
  root0Digest := (bytes [180, 13, 240, 255, 164, 232, 222, 97, 177, 11, 32, 24, 102, 152, 125, 177, 128, 117, 228, 217, 234, 14, 130, 121, 56, 156, 37, 6, 1, 131, 194, 68])
  , stage1Digest := (bytes [180, 42, 129, 179, 124, 135, 212, 151, 194, 155, 111, 92, 136, 232, 113, 76, 56, 79, 211, 209, 190, 95, 243, 229, 22, 35, 90, 1, 212, 71, 253, 137])
  , stage2Digest := (bytes [22, 68, 145, 88, 70, 235, 218, 223, 184, 4, 4, 2, 46, 118, 45, 170, 162, 155, 203, 98, 78, 226, 202, 3, 189, 168, 151, 175, 235, 8, 242, 75])
  , stage3Digest := (bytes [2, 183, 132, 95, 231, 115, 83, 2, 8, 179, 51, 169, 210, 224, 230, 178, 60, 35, 73, 58, 195, 121, 109, 163, 86, 206, 95, 244, 250, 18, 169, 79])
  , executionDigest := (bytes [70, 186, 27, 221, 111, 194, 9, 233, 22, 165, 61, 66, 109, 14, 68, 56, 20, 142, 12, 163, 129, 72, 137, 138, 73, 128, 143, 30, 210, 235, 246, 84])
  , finalStateDigest := (bytes [214, 96, 46, 11, 248, 13, 42, 132, 141, 230, 122, 96, 107, 25, 184, 147, 236, 239, 156, 156, 238, 48, 125, 174, 84, 192, 136, 2, 174, 167, 250, 118])
  , stage1Mix := 14162923987488775188
  , stage2RegMix := 3542089801700290441
  , stage2RamMix := 1893458894779210205
  , stage3ContinuityMix := 21093517096960194
  , kernelFinalMix := 5468147942805659531
  , transcriptFinalDigest := (bytes [136, 204, 167, 75, 151, 108, 16, 255, 16, 185, 218, 191, 68, 240, 50, 151, 48, 10, 175, 78, 253, 43, 200, 70, 235, 238, 182, 242, 224, 164, 60, 127])
  , finalPc := 20
  , finalRegisters := [0, 7, 16, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , finalMemory := []
  , halted := true
}
}

end Nightstream.Rv64IM.Generated.Cases.Case_native_add_chain_x0_ecall
