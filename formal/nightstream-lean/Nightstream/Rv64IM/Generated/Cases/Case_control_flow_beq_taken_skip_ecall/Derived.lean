import Nightstream.Rv64IM.Generated.ParityTypes

namespace Nightstream.Rv64IM.Generated.Cases.Case_control_flow_beq_taken_skip_ecall

open Nightstream.Rv64IM.Generated

def derivedCase : ParityDerivedCase :=
  {
  manifest := { name := "control_flow_beq_taken_skip_ecall", fixtureId := "control_flow_beq_taken_skip_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.controlFlow] }
  , executionRows := [{
  traceIndex := 0
  , stepIndex := 0
  , sequenceIndex := 0
  , pc := 0
  , nextPc := 8
  , word := 2131043
  , opcode := .beq
  , traceOpcode := (some .beq)
  , traceVirtualOpcode := none
  , family := .controlFlow
  , rs1 := 1
  , rs1Value := 11
  , rs2 := 2
  , rs2Value := 11
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
  , stage1 := { rows := [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 2131043, opcode := .beq, traceOpcode := (some .beq), traceVirtualOpcode := none, family := .controlFlow, nextPc := 8, aluResult := 1, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 8, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 12, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }] }
  , stage2 := {
  registerReads := [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 1, value := 11 }, { traceIndex := 0, stepIndex := 0, role := .rs2, reg := 2, value := 11 }]
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
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 99, 111, 110, 116, 114, 111, 108, 45, 102, 108, 111, 119, 45, 98, 101, 113, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [27634538711377453, 212436087141, 13380622803955469567, 3521951206484747623, 9254679819230523135, 7793219495316757120, 11804775929249192629, 11428962190686586919], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [99, 111, 110, 116, 114, 111, 108, 95, 102, 108, 111, 119, 95, 98, 101, 113, 95, 116, 97, 107, 101, 110, 95, 115, 107, 105, 112, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [27634538711377453, 212436087141, 13380622803955469567, 3521951206484747623, 9254679819230523135, 7793219495316757120, 11804775929249192629, 11428962190686586919], absorbed := 2 }
  , cursorAfter := { stateWords := [465674789733, 5312434293525558663, 10596276551075553943, 14450569603918463855, 9661249273729724333, 8396065679256353767, 462731823691120736, 5635755079558203640], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [2131043, 115, 115]
  , cursorBefore := { stateWords := [465674789733, 5312434293525558663, 10596276551075553943, 14450569603918463855, 9661249273729724333, 8396065679256353767, 462731823691120736, 5635755079558203640], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 11873619447013630060, 17717464028952409005, 16732078283452893501, 3355062136245183451, 12017478481429910959, 13432977969185482095, 15432564784032517350], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 11, 11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [0, 11873619447013630060, 17717464028952409005, 16732078283452893501, 3355062136245183451, 12017478481429910959, 13432977969185482095, 15432564784032517350], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 0, 0, 5091463762318078344, 3318368112870815406, 4429344314587012580, 5261477574863575050, 8809327211239977706], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [0, 0, 0, 5091463762318078344, 3318368112870815406, 4429344314587012580, 5261477574863575050, 8809327211239977706], absorbed := 3 }
  , cursorAfter := { stateWords := [0, 6224654811356644749, 17158982144652944740, 15019933618302959643, 17118805306916780510, 12622629218219917487, 11945085463406802141, 1292762549582965804], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [249, 5, 146, 18, 33, 157, 225, 56, 4, 98, 151, 188, 61, 185, 144, 108, 82, 185, 205, 99, 163, 149, 66, 245, 152, 229, 21, 229, 178, 166, 125, 112])
  , u64s := []
  , cursorBefore := { stateWords := [0, 6224654811356644749, 17158982144652944740, 15019933618302959643, 17118805306916780510, 12622629218219917487, 11945085463406802141, 1292762549582965804], absorbed := 1 }
  , cursorAfter := { stateWords := [17614294852373895509, 4260334014617405091, 2757628817354213432, 17629617629136003529, 4373764017658542478, 12910097585617283869, 16910613524638733753, 6571769778854082165], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [17614294852373895509, 4260334014617405091, 2757628817354213432, 17629617629136003529, 4373764017658542478, 12910097585617283869, 16910613524638733753, 6571769778854082165], absorbed := 0 }
  , cursorAfter := { stateWords := [4190549072535964007, 12794268973956881462, 13814166553425613581, 7517815187664511395, 17684422961771536417, 9844967664861392129, 4733523598736916638, 225143031731422657], absorbed := 0 }
  , challengeOutput := (some 4190549072535964007)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [36, 47, 184, 18, 12, 50, 186, 169, 82, 141, 180, 188, 225, 93, 29, 63, 126, 230, 177, 79, 219, 216, 85, 39, 18, 113, 23, 130, 126, 79, 236, 202])
  , u64s := []
  , cursorBefore := { stateWords := [4190549072535964007, 12794268973956881462, 13814166553425613581, 7517815187664511395, 17684422961771536417, 9844967664861392129, 4733523598736916638, 225143031731422657], absorbed := 0 }
  , cursorAfter := { stateWords := [61730645394472733, 36617521375696344, 3404484478, 8507601828489095067, 3425256122523766441, 6182800196129712623, 2651856666103449919, 9709741938434173524], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [61730645394472733, 36617521375696344, 3404484478, 8507601828489095067, 3425256122523766441, 6182800196129712623, 2651856666103449919, 9709741938434173524], absorbed := 3 }
  , cursorAfter := { stateWords := [18305464212778748472, 5987538134623801867, 9594754670761956757, 2577424451776711354, 13212076865350624270, 6827322790088488549, 4953032372757012405, 7768922595651652791], absorbed := 0 }
  , challengeOutput := (some 18305464212778748472)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [18305464212778748472, 5987538134623801867, 9594754670761956757, 2577424451776711354, 13212076865350624270, 6827322790088488549, 4953032372757012405, 7768922595651652791], absorbed := 0 }
  , cursorAfter := { stateWords := [7376970209079173320, 14784785284542128405, 14612527663059214473, 11516311501750085401, 7922914916639183288, 12837532410929378096, 1258335970604521341, 9511426704687387811], absorbed := 0 }
  , challengeOutput := (some 7376970209079173320)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [25, 20, 189, 228, 239, 124, 86, 232, 225, 254, 85, 142, 3, 196, 28, 152, 149, 180, 38, 48, 166, 127, 68, 105, 164, 111, 247, 87, 20, 223, 22, 209])
  , u64s := []
  , cursorBefore := { stateWords := [7376970209079173320, 14784785284542128405, 14612527663059214473, 11516311501750085401, 7922914916639183288, 12837532410929378096, 1258335970604521341, 9511426704687387811], absorbed := 0 }
  , cursorAfter := { stateWords := [46777788930562076, 24760381845619839, 3507937044, 17029741251735862298, 5088480235582806640, 6893491530516230344, 16188310289769784124, 17390571491661255931], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [46777788930562076, 24760381845619839, 3507937044, 17029741251735862298, 5088480235582806640, 6893491530516230344, 16188310289769784124, 17390571491661255931], absorbed := 3 }
  , cursorAfter := { stateWords := [1578515830017360886, 13102348425270848368, 6736705986258855835, 9418399529994412154, 716325036414164578, 11982606181801334064, 10746349511559020141, 11087026921518819693], absorbed := 0 }
  , challengeOutput := (some 1578515830017360886)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [252, 96, 152, 80, 142, 236, 202, 65, 180, 78, 67, 159, 13, 183, 95, 54, 63, 62, 35, 230, 19, 231, 8, 241, 242, 249, 147, 56, 57, 145, 97, 98])
  , u64s := []
  , cursorBefore := { stateWords := [1578515830017360886, 13102348425270848368, 6736705986258855835, 9418399529994412154, 716325036414164578, 11982606181801334064, 10746349511559020141, 11087026921518819693], absorbed := 0 }
  , cursorAfter := { stateWords := [5601063600076383, 15925300427819239, 1650561337, 5536944104416592812, 4361807458315334292, 13317696426234675724, 5373262348189535065, 4000089306271179632], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [192, 1, 39, 138, 19, 177, 236, 31, 181, 87, 96, 46, 123, 20, 40, 38, 253, 79, 148, 194, 31, 247, 119, 193, 97, 86, 153, 10, 105, 80, 51, 236])
  , u64s := []
  , cursorBefore := { stateWords := [5601063600076383, 15925300427819239, 1650561337, 5536944104416592812, 4361807458315334292, 13317696426234675724, 5373262348189535065, 4000089306271179632], absorbed := 3 }
  , cursorAfter := { stateWords := [8939666530969128, 2983346053412855, 3962785897, 6685180590599001214, 7721330242153800969, 16076020078159189351, 3881767920602012033, 7673995601170826988], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [183, 93, 235, 103, 237, 123, 136, 233, 137, 240, 202, 194, 24, 22, 207, 174, 161, 119, 166, 233, 220, 222, 6, 194, 140, 66, 103, 191, 76, 82, 136, 253])
  , u64s := []
  , cursorBefore := { stateWords := [8939666530969128, 2983346053412855, 3962785897, 6685180590599001214, 7721330242153800969, 16076020078159189351, 3881767920602012033, 7673995601170826988], absorbed := 3 }
  , cursorAfter := { stateWords := [62181396057272015, 53875256078763742, 4253569612, 12509625358878870155, 16545480307144642666, 2666953779086124659, 896561413201554397, 3348032544011201779], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [62181396057272015, 53875256078763742, 4253569612, 12509625358878870155, 16545480307144642666, 2666953779086124659, 896561413201554397, 3348032544011201779], absorbed := 3 }
  , cursorAfter := { stateWords := [11318972985659409720, 5282445583460402784, 4440716925723708169, 11108142665198155559, 9972752579228453186, 16583409131949533195, 741188193352441345, 13922700169655477921], absorbed := 0 }
  , challengeOutput := (some 11318972985659409720)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [11318972985659409720, 5282445583460402784, 4440716925723708169, 11108142665198155559, 9972752579228453186, 16583409131949533195, 741188193352441345, 13922700169655477921], absorbed := 0 }
  , cursorAfter := { stateWords := [17469962232139876764, 3144586392886572932, 9984870613583022165, 9097546300152087367, 1596688359226578984, 5221128712387264392, 949841542907531777, 7075267379516501926], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [156, 9, 48, 30, 23, 198, 113, 242, 132, 247, 135, 225, 169, 208, 163, 43, 85, 72, 218, 194, 235, 98, 145, 138, 71, 3, 60, 188, 40, 250, 64, 126]))
}]
}
  , kernel := {
  root0Digest := (bytes [249, 5, 146, 18, 33, 157, 225, 56, 4, 98, 151, 188, 61, 185, 144, 108, 82, 185, 205, 99, 163, 149, 66, 245, 152, 229, 21, 229, 178, 166, 125, 112])
  , stage1Digest := (bytes [36, 47, 184, 18, 12, 50, 186, 169, 82, 141, 180, 188, 225, 93, 29, 63, 126, 230, 177, 79, 219, 216, 85, 39, 18, 113, 23, 130, 126, 79, 236, 202])
  , stage2Digest := (bytes [25, 20, 189, 228, 239, 124, 86, 232, 225, 254, 85, 142, 3, 196, 28, 152, 149, 180, 38, 48, 166, 127, 68, 105, 164, 111, 247, 87, 20, 223, 22, 209])
  , stage3Digest := (bytes [252, 96, 152, 80, 142, 236, 202, 65, 180, 78, 67, 159, 13, 183, 95, 54, 63, 62, 35, 230, 19, 231, 8, 241, 242, 249, 147, 56, 57, 145, 97, 98])
  , executionDigest := (bytes [192, 1, 39, 138, 19, 177, 236, 31, 181, 87, 96, 46, 123, 20, 40, 38, 253, 79, 148, 194, 31, 247, 119, 193, 97, 86, 153, 10, 105, 80, 51, 236])
  , finalStateDigest := (bytes [183, 93, 235, 103, 237, 123, 136, 233, 137, 240, 202, 194, 24, 22, 207, 174, 161, 119, 166, 233, 220, 222, 6, 194, 140, 66, 103, 191, 76, 82, 136, 253])
  , stage1Mix := 4190549072535964007
  , stage2RegMix := 18305464212778748472
  , stage2RamMix := 7376970209079173320
  , stage3ContinuityMix := 1578515830017360886
  , kernelFinalMix := 11318972985659409720
  , transcriptFinalDigest := (bytes [156, 9, 48, 30, 23, 198, 113, 242, 132, 247, 135, 225, 169, 208, 163, 43, 85, 72, 218, 194, 235, 98, 145, 138, 71, 3, 60, 188, 40, 250, 64, 126])
  , finalPc := 12
  , finalRegisters := [0, 11, 11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , finalMemory := []
  , halted := true
}
}

end Nightstream.Rv64IM.Generated.Cases.Case_control_flow_beq_taken_skip_ecall
