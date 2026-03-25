import Nightstream.Rv64IM.Generated.ParityTypes

namespace Nightstream.Rv64IM.Generated.Cases.Case_vertical_add_sd_ld_ecall

open Nightstream.Rv64IM.Generated

def derivedCase : ParityDerivedCase :=
  {
  manifest := { name := "vertical_add_sd_ld_ecall", fixtureId := "vertical_add_sd_ld_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .alignedMemory, .controlFlow] }
  , executionRows := [{
  traceIndex := 0
  , stepIndex := 0
  , sequenceIndex := 0
  , pc := 0
  , nextPc := 4
  , word := 5243027
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
  , rdAfter := 5
  , imm := 5
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
  traceIndex := 1
  , stepIndex := 1
  , sequenceIndex := 0
  , pc := 4
  , nextPc := 8
  , word := 1081651
  , opcode := .add
  , traceOpcode := (some .add)
  , traceVirtualOpcode := none
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
  , word := 2437155
  , opcode := .sd
  , traceOpcode := (some .sd)
  , traceVirtualOpcode := none
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
  , word := 340355
  , opcode := .ld
  , traceOpcode := (some .ld)
  , traceVirtualOpcode := none
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
  , stage1 := { rows := [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 5243027, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 4, aluResult := 5, effectiveAddr := none, writesRd := true, rd := 1, rdAfter := 5, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 1081651, opcode := .add, traceOpcode := (some .add), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 8, aluResult := 10, effectiveAddr := none, writesRd := true, rd := 2, rdAfter := 10, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 2437155, opcode := .sd, traceOpcode := (some .sd), traceVirtualOpcode := none, family := .alignedMemory, nextPc := 12, aluResult := 10, effectiveAddr := (some 4096), writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 12, fetchedWord := 340355, opcode := .ld, traceOpcode := (some .ld), traceVirtualOpcode := none, family := .alignedMemory, nextPc := 16, aluResult := 10, effectiveAddr := (some 4096), writesRd := true, rd := 3, rdAfter := 10, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 4, stepIndex := 4, sequenceIndex := 0, fetchPc := 16, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 20, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }] }
  , stage2 := {
  registerReads := [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 0, value := 0 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 1, value := 5 }, { traceIndex := 1, stepIndex := 1, role := .rs2, reg := 1, value := 5 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 10, value := 4096 }, { traceIndex := 2, stepIndex := 2, role := .rs2, reg := 2, value := 10 }, { traceIndex := 3, stepIndex := 3, role := .rs1, reg := 10, value := 4096 }]
  , registerWrites := [{ traceIndex := 0, stepIndex := 0, reg := 1, previous := 0, next := 5 }, { traceIndex := 1, stepIndex := 1, reg := 2, previous := 0, next := 10 }, { traceIndex := 3, stepIndex := 3, reg := 3, previous := 0, next := 10 }]
  , ramEvents := [{ traceIndex := 2, stepIndex := 2, kind := .write, addr := 4096, previous := 0, next := 10 }, { traceIndex := 3, stepIndex := 3, kind := .read, addr := 4096, previous := 10, next := 10 }]
  , twistLinks := [{ traceIndex := 0, stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 5), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 1, family := .nativeAlu, routedWriteValue := (some 10), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 2, family := .alignedMemory, routedWriteValue := none, routedMemoryBefore := (some 0), routedMemoryAfter := (some 10) }, { traceIndex := 3, stepIndex := 3, family := .alignedMemory, routedWriteValue := (some 10), routedMemoryBefore := (some 10), routedMemoryAfter := (some 10) }, { traceIndex := 4, stepIndex := 4, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]
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
  , message := (bytes [118, 214, 69, 122, 148, 32, 162, 213, 7, 210, 132, 135, 161, 66, 31, 34, 29, 43, 130, 6, 112, 109, 4, 180, 166, 164, 136, 198, 238, 212, 121, 51])
  , u64s := []
  , cursorBefore := { stateWords := [13284789833745455176, 18407140607795037480, 16967674421196279763, 4545908446571655201, 18016966309568418852, 2424598137269674032, 9015475748579855208, 15300083809532465609], absorbed := 0 }
  , cursorAfter := { stateWords := [31532353530438175, 55882286141539437, 863622382, 9300256442076830145, 10775531560532263673, 11886855752661631686, 17060914118038258756, 1728735011302141113], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [31532353530438175, 55882286141539437, 863622382, 9300256442076830145, 10775531560532263673, 11886855752661631686, 17060914118038258756, 1728735011302141113], absorbed := 3 }
  , cursorAfter := { stateWords := [14969386806236800168, 9526483599296979969, 9427235808014444820, 18437061806071803652, 14902340541135625123, 6222171314369942080, 641337122378220848, 17503721582488447846], absorbed := 0 }
  , challengeOutput := (some 14969386806236800168)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [14969386806236800168, 9526483599296979969, 9427235808014444820, 18437061806071803652, 14902340541135625123, 6222171314369942080, 641337122378220848, 17503721582488447846], absorbed := 0 }
  , cursorAfter := { stateWords := [15095568061922680811, 6010514779189441894, 15480870243256086855, 18051190785129709915, 1882229306063730483, 11538497958393097227, 2475627159873160021, 15682995408760966558], absorbed := 0 }
  , challengeOutput := (some 15095568061922680811)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [251, 200, 2, 73, 106, 203, 134, 119, 197, 122, 57, 39, 230, 167, 35, 170, 238, 99, 170, 82, 101, 116, 253, 216, 228, 173, 71, 39, 172, 50, 146, 14])
  , u64s := []
  , cursorBefore := { stateWords := [15095568061922680811, 6010514779189441894, 15480870243256086855, 18051190785129709915, 1882229306063730483, 11538497958393097227, 2475627159873160021, 15682995408760966558], absorbed := 0 }
  , cursorAfter := { stateWords := [28519864422279715, 11056336286055796, 244462252, 5554638233071607975, 16770043516943633411, 6249926511978657610, 8687332252309969280, 1565247429972999365], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [28519864422279715, 11056336286055796, 244462252, 5554638233071607975, 16770043516943633411, 6249926511978657610, 8687332252309969280, 1565247429972999365], absorbed := 3 }
  , cursorAfter := { stateWords := [13169674182515960671, 2620955626701444129, 17721918655771029112, 14695182443956093624, 9490491841612102634, 4925892213990733004, 14165316712564429088, 10644095749004086830], absorbed := 0 }
  , challengeOutput := (some 13169674182515960671)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [2, 183, 132, 95, 231, 115, 83, 2, 8, 179, 51, 169, 210, 224, 230, 178, 60, 35, 73, 58, 195, 121, 109, 163, 86, 206, 95, 244, 250, 18, 169, 79])
  , u64s := []
  , cursorBefore := { stateWords := [13169674182515960671, 2620955626701444129, 17721918655771029112, 14695182443956093624, 9490491841612102634, 4925892213990733004, 14165316712564429088, 10644095749004086830], absorbed := 0 }
  , cursorAfter := { stateWords := [54951706256782054, 68785234138852729, 1336480506, 12968568912559367984, 11074068904078670971, 18417503360126432392, 4431800965549209855, 13352521822309759286], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [254, 167, 237, 35, 229, 145, 124, 131, 169, 247, 185, 244, 68, 31, 227, 147, 217, 37, 96, 244, 224, 23, 123, 54, 206, 154, 166, 72, 40, 193, 48, 159])
  , u64s := []
  , cursorBefore := { stateWords := [54951706256782054, 68785234138852729, 1336480506, 12968568912559367984, 11074068904078670971, 18417503360126432392, 4431800965549209855, 13352521822309759286], absorbed := 3 }
  , cursorAfter := { stateWords := [63319088572240867, 20449382138018583, 2670772520, 16292564500766371404, 5554945612843821460, 8815939437090424068, 15713632082077964399, 11463752261624317501], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [40, 203, 41, 62, 45, 52, 38, 20, 4, 174, 242, 202, 246, 67, 233, 128, 197, 240, 97, 4, 68, 33, 142, 222, 96, 232, 104, 62, 196, 10, 224, 135])
  , u64s := []
  , cursorBefore := { stateWords := [63319088572240867, 20449382138018583, 2670772520, 16292564500766371404, 5554945612843821460, 8815939437090424068, 15713632082077964399, 11463752261624317501], absorbed := 3 }
  , cursorAfter := { stateWords := [19145117114138857, 17566795822960161, 2279606980, 14923286099470022341, 4046499787932842240, 2688434062734964839, 13509419680391707383, 8823521324133878410], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [19145117114138857, 17566795822960161, 2279606980, 14923286099470022341, 4046499787932842240, 2688434062734964839, 13509419680391707383, 8823521324133878410], absorbed := 3 }
  , cursorAfter := { stateWords := [14716619926376516618, 17537159774187038019, 11348214874926457665, 8014613978832793681, 13306143600242734710, 6682435814947818059, 12790647131617082676, 11626473410328314772], absorbed := 0 }
  , challengeOutput := (some 14716619926376516618)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [14716619926376516618, 17537159774187038019, 11348214874926457665, 8014613978832793681, 13306143600242734710, 6682435814947818059, 12790647131617082676, 11626473410328314772], absorbed := 0 }
  , cursorAfter := { stateWords := [3034602953248393749, 7511704329109967520, 4884577229284093310, 11934513655341686515, 13914406895756991245, 16591503739278178274, 2732730744334366993, 5872474801572026057], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [21, 202, 184, 214, 78, 19, 29, 42, 160, 18, 93, 226, 73, 239, 62, 104, 126, 173, 112, 69, 28, 129, 201, 67, 243, 158, 176, 17, 240, 232, 159, 165]))
}]
}
  , kernel := {
  root0Digest := (bytes [135, 54, 179, 58, 175, 8, 113, 89, 77, 53, 240, 243, 127, 62, 36, 4, 249, 145, 43, 195, 231, 83, 112, 77, 131, 50, 114, 62, 167, 230, 250, 199])
  , stage1Digest := (bytes [118, 214, 69, 122, 148, 32, 162, 213, 7, 210, 132, 135, 161, 66, 31, 34, 29, 43, 130, 6, 112, 109, 4, 180, 166, 164, 136, 198, 238, 212, 121, 51])
  , stage2Digest := (bytes [251, 200, 2, 73, 106, 203, 134, 119, 197, 122, 57, 39, 230, 167, 35, 170, 238, 99, 170, 82, 101, 116, 253, 216, 228, 173, 71, 39, 172, 50, 146, 14])
  , stage3Digest := (bytes [2, 183, 132, 95, 231, 115, 83, 2, 8, 179, 51, 169, 210, 224, 230, 178, 60, 35, 73, 58, 195, 121, 109, 163, 86, 206, 95, 244, 250, 18, 169, 79])
  , executionDigest := (bytes [254, 167, 237, 35, 229, 145, 124, 131, 169, 247, 185, 244, 68, 31, 227, 147, 217, 37, 96, 244, 224, 23, 123, 54, 206, 154, 166, 72, 40, 193, 48, 159])
  , finalStateDigest := (bytes [40, 203, 41, 62, 45, 52, 38, 20, 4, 174, 242, 202, 246, 67, 233, 128, 197, 240, 97, 4, 68, 33, 142, 222, 96, 232, 104, 62, 196, 10, 224, 135])
  , stage1Mix := 13284789833745455176
  , stage2RegMix := 14969386806236800168
  , stage2RamMix := 15095568061922680811
  , stage3ContinuityMix := 13169674182515960671
  , kernelFinalMix := 14716619926376516618
  , transcriptFinalDigest := (bytes [21, 202, 184, 214, 78, 19, 29, 42, 160, 18, 93, 226, 73, 239, 62, 104, 126, 173, 112, 69, 28, 129, 201, 67, 243, 158, 176, 17, 240, 232, 159, 165])
  , finalPc := 20
  , finalRegisters := [0, 5, 10, 10, 0, 0, 0, 0, 0, 0, 4096, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , finalMemory := [{ addr := 4096, value := 10 }]
  , halted := true
}
}

end Nightstream.Rv64IM.Generated.Cases.Case_vertical_add_sd_ld_ecall
