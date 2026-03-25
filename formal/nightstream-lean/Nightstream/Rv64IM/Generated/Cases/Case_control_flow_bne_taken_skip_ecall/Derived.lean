import Nightstream.Rv64IM.Generated.ParityTypes

namespace Nightstream.Rv64IM.Generated.Cases.Case_control_flow_bne_taken_skip_ecall

open Nightstream.Rv64IM.Generated

def derivedCase : ParityDerivedCase :=
  {
  manifest := { name := "control_flow_bne_taken_skip_ecall", fixtureId := "control_flow_bne_taken_skip_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.controlFlow] }
  , executionRows := [{
  traceIndex := 0
  , stepIndex := 0
  , sequenceIndex := 0
  , pc := 0
  , nextPc := 8
  , word := 2135139
  , opcode := .bne
  , traceOpcode := (some .bne)
  , traceVirtualOpcode := none
  , family := .controlFlow
  , rs1 := 1
  , rs1Value := 11
  , rs2 := 2
  , rs2Value := 12
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
  traceIndex := 1
  , stepIndex := 1
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
  , stage1 := { rows := [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 2135139, opcode := .bne, traceOpcode := (some .bne), traceVirtualOpcode := none, family := .controlFlow, nextPc := 8, aluResult := 1, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 8, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 12, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }] }
  , stage2 := {
  registerReads := [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 1, value := 11 }, { traceIndex := 0, stepIndex := 0, role := .rs2, reg := 2, value := 12 }]
  , registerWrites := []
  , ramEvents := []
  , twistLinks := [{ traceIndex := 0, stepIndex := 0, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 1, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]
}
  , stage3 := {
  continuity := [{ stepIndex := 0, pc := 0, nextPc := 8, successorPc := (some 8), finalStep := false, continuityHolds := true }, { stepIndex := 1, pc := 8, nextPc := 12, successorPc := none, finalStep := true, continuityHolds := true }]
  , halted := true
}
  , transcript := {
  appLabel := (bytes [110, 101, 111, 46, 102, 111, 108, 100, 46, 110, 101, 120, 116, 47, 114, 118, 54, 52, 105, 109, 47, 112, 97, 114, 105, 116, 121, 95, 107, 101, 114, 110, 101, 108, 95, 118, 49])
  , events := [{
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 116, 114, 97, 110, 115, 99, 114, 105, 112, 116, 95, 115, 101, 101, 100])
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 99, 111, 110, 116, 114, 111, 108, 45, 102, 108, 111, 119, 45, 98, 110, 101, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [27634538711377453, 212436084078, 13380622803955469567, 3521951206484747623, 9254679819230523135, 7793219495316757120, 11804775929249192629, 11428962190686586919], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [99, 111, 110, 116, 114, 111, 108, 95, 102, 108, 111, 119, 95, 98, 110, 101, 95, 116, 97, 107, 101, 110, 95, 115, 107, 105, 112, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [27634538711377453, 212436084078, 13380622803955469567, 3521951206484747623, 9254679819230523135, 7793219495316757120, 11804775929249192629, 11428962190686586919], absorbed := 2 }
  , cursorAfter := { stateWords := [465674789733, 10592000548927366003, 5372229839222874320, 1740214098237250806, 6119822484208687887, 9394951168810394430, 12672088132513204652, 7586149171929445972], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [2135139, 115, 115]
  , cursorBefore := { stateWords := [465674789733, 10592000548927366003, 5372229839222874320, 1740214098237250806, 6119822484208687887, 9394951168810394430, 12672088132513204652, 7586149171929445972], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 7413228006330779902, 8582650908638856027, 17610977544293839914, 3759889169736114711, 15901043119861675788, 9472634536693924453, 9505822070476413217], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 11, 12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [0, 7413228006330779902, 8582650908638856027, 17610977544293839914, 3759889169736114711, 15901043119861675788, 9472634536693924453, 9505822070476413217], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 0, 0, 16263209211967796623, 8817747458968159599, 11693157767770916334, 4535073333153540848, 13064336398401688622], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [0, 0, 0, 16263209211967796623, 8817747458968159599, 11693157767770916334, 4535073333153540848, 13064336398401688622], absorbed := 3 }
  , cursorAfter := { stateWords := [0, 184961733459445695, 10439361452232196496, 5477629110978449157, 10525452282860730865, 14850227733462477641, 655977648214868394, 10392062720265822300], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [47, 31, 245, 201, 4, 201, 33, 81, 145, 144, 28, 191, 63, 122, 223, 48, 5, 32, 233, 197, 24, 226, 36, 71, 146, 87, 33, 71, 252, 124, 36, 217])
  , u64s := []
  , cursorBefore := { stateWords := [0, 184961733459445695, 10439361452232196496, 5477629110978449157, 10525452282860730865, 14850227733462477641, 655977648214868394, 10392062720265822300], absorbed := 1 }
  , cursorAfter := { stateWords := [10841239839895884197, 7042464942923330282, 10380329362541107946, 16899627740715519546, 987348817651029690, 15668725437811754651, 14151215500991564186, 10529933252088080066], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [10841239839895884197, 7042464942923330282, 10380329362541107946, 16899627740715519546, 987348817651029690, 15668725437811754651, 14151215500991564186, 10529933252088080066], absorbed := 0 }
  , cursorAfter := { stateWords := [4164217130796975174, 13252727050654072826, 90380677729782399, 12698890649376489821, 5826372244578231027, 15080116153871298873, 15769322286630220192, 8203128819751112536], absorbed := 0 }
  , challengeOutput := (some 4164217130796975174)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [45, 158, 250, 54, 184, 86, 73, 248, 63, 220, 63, 180, 118, 150, 164, 56, 218, 177, 144, 96, 157, 102, 104, 84, 112, 137, 89, 166, 122, 177, 136, 204])
  , u64s := []
  , cursorBefore := { stateWords := [4164217130796975174, 13252727050654072826, 90380677729782399, 12698890649376489821, 5826372244578231027, 15080116153871298873, 15769322286630220192, 8203128819751112536], absorbed := 0 }
  , cursorAfter := { stateWords := [44297745918998692, 46823292963940454, 3431510394, 978335545678316923, 7935604434437939422, 16856257200924805354, 15715824662485268575, 2968672347385207192], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [44297745918998692, 46823292963940454, 3431510394, 978335545678316923, 7935604434437939422, 16856257200924805354, 15715824662485268575, 2968672347385207192], absorbed := 3 }
  , cursorAfter := { stateWords := [7272141586656064238, 574981847177334314, 1884318976108538845, 17472130890065199889, 14448322988033898676, 717315572846471317, 14313432253938417351, 18184810406592438209], absorbed := 0 }
  , challengeOutput := (some 7272141586656064238)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [7272141586656064238, 574981847177334314, 1884318976108538845, 17472130890065199889, 14448322988033898676, 717315572846471317, 14313432253938417351, 18184810406592438209], absorbed := 0 }
  , cursorAfter := { stateWords := [2349039680891761309, 3080305705491725360, 17209944193440959467, 14704130238386547015, 17509526344829944766, 8418953735115468507, 12664948723347414398, 13704819432316783687], absorbed := 0 }
  , challengeOutput := (some 2349039680891761309)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [129, 107, 134, 53, 33, 141, 82, 199, 63, 234, 186, 116, 127, 45, 37, 171, 193, 171, 141, 101, 231, 163, 252, 53, 130, 149, 218, 121, 62, 206, 218, 150])
  , u64s := []
  , cursorBefore := { stateWords := [2349039680891761309, 3080305705491725360, 17209944193440959467, 14704130238386547015, 17509526344829944766, 8418953735115468507, 12664948723347414398, 13704819432316783687], absorbed := 0 }
  , cursorAfter := { stateWords := [65132378766551845, 34298807851547811, 2530922046, 840195800100851824, 2001881315940306317, 16283633015451840385, 2215215812176052729, 6307580396098691924], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [65132378766551845, 34298807851547811, 2530922046, 840195800100851824, 2001881315940306317, 16283633015451840385, 2215215812176052729, 6307580396098691924], absorbed := 3 }
  , cursorAfter := { stateWords := [4340422366219638731, 8541316787897987729, 8901670458102449780, 549377315780916700, 14212474332240237855, 5970376535758449964, 17693034886709721856, 11145940534269579115], absorbed := 0 }
  , challengeOutput := (some 4340422366219638731)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [252, 96, 152, 80, 142, 236, 202, 65, 180, 78, 67, 159, 13, 183, 95, 54, 63, 62, 35, 230, 19, 231, 8, 241, 242, 249, 147, 56, 57, 145, 97, 98])
  , u64s := []
  , cursorBefore := { stateWords := [4340422366219638731, 8541316787897987729, 8901670458102449780, 549377315780916700, 14212474332240237855, 5970376535758449964, 17693034886709721856, 11145940534269579115], absorbed := 0 }
  , cursorAfter := { stateWords := [5601063600076383, 15925300427819239, 1650561337, 8765236588785694431, 7627285688056552044, 9241655527533399847, 2770991240558731680, 198504575758854089], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [12, 30, 19, 141, 77, 65, 148, 145, 125, 87, 54, 85, 152, 71, 200, 94, 22, 18, 250, 142, 162, 195, 48, 158, 218, 171, 89, 66, 61, 52, 72, 70])
  , u64s := []
  , cursorBefore := { stateWords := [5601063600076383, 15925300427819239, 1650561337, 8765236588785694431, 7627285688056552044, 9241655527533399847, 2770991240558731680, 198504575758854089], absorbed := 3 }
  , cursorAfter := { stateWords := [45756150923550408, 18675943104983235, 1179137085, 4122671178930506387, 14361496186358289808, 962873007711208473, 2125071514556238530, 4433116802483115950], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [109, 227, 46, 151, 163, 182, 16, 165, 221, 233, 185, 9, 44, 116, 7, 71, 91, 41, 171, 246, 46, 165, 236, 88, 0, 65, 157, 32, 119, 22, 69, 5])
  , u64s := []
  , cursorBefore := { stateWords := [45756150923550408, 18675943104983235, 1179137085, 4122671178930506387, 14361496186358289808, 962873007711208473, 2125071514556238530, 4433116802483115950], absorbed := 3 }
  , cursorAfter := { stateWords := [13219063922378503, 9180101759003813, 88413815, 7140964626494947538, 7738931268240569131, 874061480644485602, 17652081350271067358, 8290368635603139705], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [13219063922378503, 9180101759003813, 88413815, 7140964626494947538, 7738931268240569131, 874061480644485602, 17652081350271067358, 8290368635603139705], absorbed := 3 }
  , cursorAfter := { stateWords := [12704708396441037909, 8768002916712688262, 568449612292434373, 18408169467964355147, 15379168391058313291, 14443822247537523591, 1888165896308069592, 8221618839066143592], absorbed := 0 }
  , challengeOutput := (some 12704708396441037909)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [12704708396441037909, 8768002916712688262, 568449612292434373, 18408169467964355147, 15379168391058313291, 14443822247537523591, 1888165896308069592, 8221618839066143592], absorbed := 0 }
  , cursorAfter := { stateWords := [13114228731221740220, 2102961008208881693, 2049154105986150259, 10539972841722930168, 12710832207771160010, 15052990728791866921, 17002610710309475704, 3718838717642061647], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [188, 138, 177, 131, 140, 25, 255, 181, 29, 168, 201, 30, 229, 55, 47, 29, 115, 111, 86, 113, 205, 14, 112, 28, 248, 227, 40, 213, 116, 129, 69, 146]))
}]
}
  , kernel := {
  root0Digest := (bytes [47, 31, 245, 201, 4, 201, 33, 81, 145, 144, 28, 191, 63, 122, 223, 48, 5, 32, 233, 197, 24, 226, 36, 71, 146, 87, 33, 71, 252, 124, 36, 217])
  , stage1Digest := (bytes [45, 158, 250, 54, 184, 86, 73, 248, 63, 220, 63, 180, 118, 150, 164, 56, 218, 177, 144, 96, 157, 102, 104, 84, 112, 137, 89, 166, 122, 177, 136, 204])
  , stage2Digest := (bytes [129, 107, 134, 53, 33, 141, 82, 199, 63, 234, 186, 116, 127, 45, 37, 171, 193, 171, 141, 101, 231, 163, 252, 53, 130, 149, 218, 121, 62, 206, 218, 150])
  , stage3Digest := (bytes [252, 96, 152, 80, 142, 236, 202, 65, 180, 78, 67, 159, 13, 183, 95, 54, 63, 62, 35, 230, 19, 231, 8, 241, 242, 249, 147, 56, 57, 145, 97, 98])
  , executionDigest := (bytes [12, 30, 19, 141, 77, 65, 148, 145, 125, 87, 54, 85, 152, 71, 200, 94, 22, 18, 250, 142, 162, 195, 48, 158, 218, 171, 89, 66, 61, 52, 72, 70])
  , finalStateDigest := (bytes [109, 227, 46, 151, 163, 182, 16, 165, 221, 233, 185, 9, 44, 116, 7, 71, 91, 41, 171, 246, 46, 165, 236, 88, 0, 65, 157, 32, 119, 22, 69, 5])
  , stage1Mix := 4164217130796975174
  , stage2RegMix := 7272141586656064238
  , stage2RamMix := 2349039680891761309
  , stage3ContinuityMix := 4340422366219638731
  , kernelFinalMix := 12704708396441037909
  , transcriptFinalDigest := (bytes [188, 138, 177, 131, 140, 25, 255, 181, 29, 168, 201, 30, 229, 55, 47, 29, 115, 111, 86, 113, 205, 14, 112, 28, 248, 227, 40, 213, 116, 129, 69, 146])
  , finalPc := 12
  , finalRegisters := [0, 11, 12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , finalMemory := []
  , halted := true
}
}

end Nightstream.Rv64IM.Generated.Cases.Case_control_flow_bne_taken_skip_ecall
