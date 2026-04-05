import Nightstream.Rv64IM.Generated.AcceptedProofArtifactTypes

set_option maxHeartbeats 0
set_option maxRecDepth 65536

namespace Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors.Case_control_flow_bgeu_taken_skip_ecall

open Nightstream.Rv64IM.Generated

def stage1SemInputs : List SemInView :=
  [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, pc := 0, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 1, archRdBefore := 0, archImm := 2, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 1, rdBefore := 0, rdAfter := 2, imm := 2, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, pc := 4, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 2, archRdBefore := 0, archImm := 1, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 2, rdBefore := 0, rdAfter := 1, imm := 1, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, pc := 8, opcode := .bgeu, traceOpcode := (some .bgeu), traceVirtualOpcode := none, family := .controlFlow, archRs1 := 1, archRs1Value := 2, archRs2 := 2, archRs2Value := 1, archRd := 0, archRdBefore := 0, archImm := 8, rs1 := 1, rs1Value := 2, rs2 := 2, rs2Value := 1, rd := 0, rdBefore := 0, rdAfter := 0, imm := 8, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := false, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, pc := 16, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 0, archRdBefore := 0, archImm := 0, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 0, rdBefore := 0, rdAfter := 0, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := false, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }]

def stage1RowBindings : List Stage1RowBindingView :=
  [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 2097299, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 4, aluResult := 2, effectiveAddr := none, writesRd := true, rd := 1, rdAfter := 2, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 1048851, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 8, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 2, rdAfter := 1, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 2159715, opcode := .bgeu, traceOpcode := (some .bgeu), traceVirtualOpcode := none, family := .controlFlow, nextPc := 16, aluResult := 1, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 16, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 20, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }]

def stage1 : Stage1ProofBundleView :=
  {
    semInputs := stage1SemInputs
    , rowBindings := stage1RowBindings
    , bytecodeDigest := (bytes [14, 98, 153, 22, 153, 88, 124, 84, 134, 30, 31, 117, 192, 129, 114, 5, 98, 16, 46, 252, 48, 212, 39, 217, 246, 32, 98, 203, 202, 180, 36, 7])
    , aluDigest := (bytes [36, 79, 116, 138, 25, 155, 64, 122, 33, 241, 168, 6, 138, 6, 118, 178, 174, 91, 186, 236, 21, 2, 121, 163, 138, 123, 215, 184, 202, 69, 157, 75])
    , branchDigest := (bytes [41, 204, 162, 232, 179, 36, 137, 88, 134, 209, 211, 9, 127, 102, 250, 47, 211, 117, 80, 70, 232, 232, 242, 235, 30, 41, 119, 176, 194, 20, 32, 248])
    , semantics := { semInputsDigest := (bytes [187, 44, 157, 96, 39, 133, 17, 129, 71, 36, 99, 181, 113, 244, 83, 22, 112, 189, 144, 252, 206, 100, 208, 205, 66, 136, 246, 133, 193, 167, 250, 63]), rowBindingsDigest := (bytes [253, 98, 11, 67, 170, 197, 80, 100, 55, 237, 104, 219, 172, 135, 192, 211, 33, 224, 249, 133, 35, 175, 213, 125, 99, 21, 91, 111, 72, 207, 91, 155]), sequenceCount := 4, helperRowCount := 0, digest := (bytes [37, 121, 123, 22, 243, 173, 26, 205, 17, 190, 8, 30, 198, 54, 230, 70, 161, 53, 230, 124, 167, 42, 84, 137, 37, 43, 127, 216, 0, 5, 52, 21]) }
    , addressCorrectnessDigest := (bytes [112, 19, 176, 114, 75, 151, 217, 245, 24, 8, 221, 255, 243, 169, 151, 243, 199, 168, 124, 209, 43, 190, 144, 233, 8, 139, 13, 179, 34, 224, 9, 77])
    , linkageDigest := (bytes [41, 155, 111, 147, 173, 3, 117, 69, 253, 5, 33, 168, 66, 218, 213, 163, 214, 66, 215, 69, 103, 38, 105, 72, 63, 1, 201, 196, 129, 249, 146, 200])
    , selectedOpening := { claim := { rowsFamilyDigest := (bytes [253, 98, 11, 67, 170, 197, 80, 100, 55, 237, 104, 219, 172, 135, 192, 211, 33, 224, 249, 133, 35, 175, 213, 125, 99, 21, 91, 111, 72, 207, 91, 155]), rowCount := 4, effectRowCount := 4, commitRowCount := 4, realRowCount := 4, preservesX0Count := 2, firstTraceIndex := 0, effectTraceIndex := 0, commitTraceIndex := 0, lastTraceIndex := 3, mix := 2302652608239151864, points := { first := { id := { object := { familyTag := 1, commitmentDigest := (bytes [253, 98, 11, 67, 170, 197, 80, 100, 55, 237, 104, 219, 172, 135, 192, 211, 33, 224, 249, 133, 35, 175, 213, 125, 99, 21, 91, 111, 72, 207, 91, 155]), layoutVersion := 1, digest := (bytes [58, 9, 95, 221, 43, 44, 10, 17, 52, 170, 93, 62, 222, 62, 74, 127, 114, 18, 171, 186, 63, 61, 36, 109, 20, 65, 116, 40, 48, 183, 4, 97]) }, logicalIndex := 0, digest := (bytes [22, 198, 209, 202, 15, 111, 203, 137, 55, 73, 105, 55, 13, 193, 162, 198, 52, 49, 226, 17, 38, 254, 94, 50, 6, 39, 178, 159, 77, 40, 113, 81]) }, valueDigest := (bytes [124, 122, 1, 251, 179, 249, 170, 178, 81, 216, 61, 239, 212, 3, 158, 82, 99, 90, 65, 100, 228, 119, 255, 14, 108, 72, 106, 194, 211, 111, 119, 3]), digest := (bytes [26, 142, 177, 132, 218, 84, 218, 182, 79, 163, 202, 39, 179, 16, 144, 160, 252, 123, 70, 24, 7, 223, 165, 156, 98, 51, 63, 112, 115, 216, 48, 161]) }, effect := { id := { object := { familyTag := 1, commitmentDigest := (bytes [253, 98, 11, 67, 170, 197, 80, 100, 55, 237, 104, 219, 172, 135, 192, 211, 33, 224, 249, 133, 35, 175, 213, 125, 99, 21, 91, 111, 72, 207, 91, 155]), layoutVersion := 1, digest := (bytes [58, 9, 95, 221, 43, 44, 10, 17, 52, 170, 93, 62, 222, 62, 74, 127, 114, 18, 171, 186, 63, 61, 36, 109, 20, 65, 116, 40, 48, 183, 4, 97]) }, logicalIndex := 0, digest := (bytes [22, 198, 209, 202, 15, 111, 203, 137, 55, 73, 105, 55, 13, 193, 162, 198, 52, 49, 226, 17, 38, 254, 94, 50, 6, 39, 178, 159, 77, 40, 113, 81]) }, valueDigest := (bytes [124, 122, 1, 251, 179, 249, 170, 178, 81, 216, 61, 239, 212, 3, 158, 82, 99, 90, 65, 100, 228, 119, 255, 14, 108, 72, 106, 194, 211, 111, 119, 3]), digest := (bytes [26, 142, 177, 132, 218, 84, 218, 182, 79, 163, 202, 39, 179, 16, 144, 160, 252, 123, 70, 24, 7, 223, 165, 156, 98, 51, 63, 112, 115, 216, 48, 161]) }, commit := { id := { object := { familyTag := 1, commitmentDigest := (bytes [253, 98, 11, 67, 170, 197, 80, 100, 55, 237, 104, 219, 172, 135, 192, 211, 33, 224, 249, 133, 35, 175, 213, 125, 99, 21, 91, 111, 72, 207, 91, 155]), layoutVersion := 1, digest := (bytes [58, 9, 95, 221, 43, 44, 10, 17, 52, 170, 93, 62, 222, 62, 74, 127, 114, 18, 171, 186, 63, 61, 36, 109, 20, 65, 116, 40, 48, 183, 4, 97]) }, logicalIndex := 0, digest := (bytes [22, 198, 209, 202, 15, 111, 203, 137, 55, 73, 105, 55, 13, 193, 162, 198, 52, 49, 226, 17, 38, 254, 94, 50, 6, 39, 178, 159, 77, 40, 113, 81]) }, valueDigest := (bytes [124, 122, 1, 251, 179, 249, 170, 178, 81, 216, 61, 239, 212, 3, 158, 82, 99, 90, 65, 100, 228, 119, 255, 14, 108, 72, 106, 194, 211, 111, 119, 3]), digest := (bytes [26, 142, 177, 132, 218, 84, 218, 182, 79, 163, 202, 39, 179, 16, 144, 160, 252, 123, 70, 24, 7, 223, 165, 156, 98, 51, 63, 112, 115, 216, 48, 161]) }, last := { id := { object := { familyTag := 1, commitmentDigest := (bytes [253, 98, 11, 67, 170, 197, 80, 100, 55, 237, 104, 219, 172, 135, 192, 211, 33, 224, 249, 133, 35, 175, 213, 125, 99, 21, 91, 111, 72, 207, 91, 155]), layoutVersion := 1, digest := (bytes [58, 9, 95, 221, 43, 44, 10, 17, 52, 170, 93, 62, 222, 62, 74, 127, 114, 18, 171, 186, 63, 61, 36, 109, 20, 65, 116, 40, 48, 183, 4, 97]) }, logicalIndex := 3, digest := (bytes [229, 91, 235, 210, 56, 118, 237, 140, 235, 183, 142, 195, 246, 199, 230, 63, 252, 5, 60, 211, 207, 116, 29, 158, 4, 55, 121, 42, 201, 104, 48, 122]) }, valueDigest := (bytes [42, 117, 137, 62, 203, 77, 127, 14, 91, 68, 2, 177, 38, 250, 164, 28, 55, 139, 198, 41, 209, 72, 143, 173, 84, 204, 135, 91, 62, 25, 137, 209]), digest := (bytes [48, 80, 24, 159, 250, 197, 247, 180, 41, 49, 20, 151, 46, 118, 102, 221, 169, 111, 131, 89, 204, 176, 177, 8, 81, 10, 99, 32, 73, 9, 26, 131]) } }, digest := (bytes [123, 239, 121, 46, 97, 33, 119, 253, 20, 66, 155, 12, 131, 214, 90, 144, 9, 28, 171, 121, 1, 187, 11, 194, 82, 222, 29, 250, 156, 69, 136, 176]) }, packaged := { statementDigest := (bytes [206, 74, 248, 9, 153, 13, 212, 153, 81, 167, 114, 158, 232, 254, 93, 213, 225, 191, 125, 194, 66, 80, 189, 140, 215, 194, 246, 2, 74, 210, 70, 45]), proofDigest := (bytes [117, 183, 164, 26, 93, 57, 171, 102, 176, 170, 84, 11, 24, 222, 35, 139, 187, 72, 198, 209, 231, 142, 244, 13, 149, 155, 115, 206, 159, 97, 52, 101]) }, digest := (bytes [130, 174, 243, 222, 39, 159, 87, 21, 175, 112, 43, 65, 6, 32, 190, 202, 78, 221, 86, 44, 131, 56, 104, 211, 120, 203, 122, 142, 72, 244, 82, 162]) }
    , digest := (bytes [199, 252, 153, 211, 123, 247, 185, 175, 66, 92, 58, 16, 196, 38, 124, 23, 226, 140, 119, 110, 13, 206, 190, 18, 14, 128, 88, 162, 142, 122, 192, 202])
  }

def stage2RegisterReads : List RegisterReadEventView :=
  [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 0, value := 0 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 0, value := 0 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 1, value := 2 }, { traceIndex := 2, stepIndex := 2, role := .rs2, reg := 2, value := 1 }]

def stage2RegisterWrites : List RegisterWriteEventView :=
  [{ traceIndex := 0, stepIndex := 0, reg := 1, previous := 0, next := 2 }, { traceIndex := 1, stepIndex := 1, reg := 2, previous := 0, next := 1 }]

def stage2RamEvents : List RamEventView :=
  []

def stage2TwistLinks : List TwistLinkEventView :=
  [{ traceIndex := 0, stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 2), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 1, family := .nativeAlu, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 2, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 3, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]

def stage2 : Stage2ProofBundleView :=
  {
    registerReads := stage2RegisterReads
    , registerWrites := stage2RegisterWrites
    , ramEvents := stage2RamEvents
    , registerDigest := (bytes [153, 83, 224, 89, 153, 124, 159, 4, 230, 168, 91, 46, 124, 58, 151, 211, 126, 42, 225, 194, 122, 41, 34, 75, 15, 59, 54, 36, 154, 164, 161, 142])
    , ramDigest := (bytes [209, 217, 105, 43, 209, 229, 156, 61, 92, 164, 94, 232, 52, 214, 73, 229, 72, 188, 139, 122, 165, 123, 201, 212, 205, 15, 247, 197, 165, 154, 109, 246])
    , temporal := { twistLinks := stage2TwistLinks, registerTimelineDigest := (bytes [43, 107, 58, 39, 150, 26, 11, 72, 182, 117, 241, 69, 24, 33, 62, 89, 189, 91, 202, 15, 130, 81, 130, 246, 59, 60, 121, 207, 178, 20, 185, 215]), ramTimelineDigest := (bytes [8, 117, 17, 140, 128, 180, 240, 140, 250, 181, 90, 134, 147, 17, 197, 122, 220, 8, 66, 15, 193, 254, 11, 122, 115, 210, 233, 239, 55, 132, 31, 228]), twistLinksDigest := (bytes [131, 82, 97, 245, 15, 90, 244, 148, 112, 151, 15, 146, 230, 252, 69, 230, 255, 119, 89, 28, 49, 57, 227, 19, 4, 37, 235, 6, 115, 215, 28, 65]), digest := (bytes [171, 82, 105, 161, 220, 165, 62, 34, 9, 68, 238, 64, 61, 241, 181, 104, 19, 131, 49, 152, 2, 161, 128, 164, 37, 248, 247, 114, 110, 131, 251, 178]) }
    , semantics := { registerReadsFamilyDigest := (bytes [109, 179, 182, 82, 28, 183, 239, 230, 75, 61, 152, 59, 60, 94, 218, 88, 182, 122, 240, 253, 78, 226, 159, 206, 96, 63, 126, 149, 74, 133, 70, 193]), registerWritesFamilyDigest := (bytes [97, 131, 235, 8, 197, 56, 92, 13, 100, 146, 90, 190, 235, 233, 212, 196, 7, 77, 86, 194, 176, 195, 144, 106, 186, 143, 238, 70, 18, 153, 101, 162]), ramEventsFamilyDigest := (bytes [85, 17, 108, 38, 84, 5, 109, 213, 145, 137, 203, 96, 117, 127, 130, 193, 117, 29, 27, 219, 228, 58, 7, 214, 144, 155, 66, 38, 127, 8, 241, 95]), twistLinksFamilyDigest := (bytes [189, 86, 40, 245, 73, 43, 251, 9, 70, 221, 169, 206, 117, 249, 17, 199, 211, 205, 0, 134, 176, 64, 145, 36, 101, 122, 38, 171, 175, 83, 246, 43]), rowCount := 4, registerEventCount := 6, ramEventCount := 0, digest := (bytes [244, 158, 19, 248, 207, 201, 20, 51, 160, 66, 173, 215, 62, 2, 210, 184, 29, 18, 134, 112, 75, 1, 104, 200, 237, 254, 33, 210, 164, 188, 243, 239]) }
    , linkageDigest := (bytes [13, 123, 217, 246, 237, 90, 127, 96, 149, 252, 45, 74, 247, 52, 60, 4, 128, 204, 246, 235, 58, 11, 163, 164, 190, 223, 241, 68, 76, 2, 180, 106])
    , selectedOpening := { claim := { registerReadsFamilyDigest := (bytes [109, 179, 182, 82, 28, 183, 239, 230, 75, 61, 152, 59, 60, 94, 218, 88, 182, 122, 240, 253, 78, 226, 159, 206, 96, 63, 126, 149, 74, 133, 70, 193]), registerWritesFamilyDigest := (bytes [97, 131, 235, 8, 197, 56, 92, 13, 100, 146, 90, 190, 235, 233, 212, 196, 7, 77, 86, 194, 176, 195, 144, 106, 186, 143, 238, 70, 18, 153, 101, 162]), ramEventsFamilyDigest := (bytes [85, 17, 108, 38, 84, 5, 109, 213, 145, 137, 203, 96, 117, 127, 130, 193, 117, 29, 27, 219, 228, 58, 7, 214, 144, 155, 66, 38, 127, 8, 241, 95]), twistLinksFamilyDigest := (bytes [189, 86, 40, 245, 73, 43, 251, 9, 70, 221, 169, 206, 117, 249, 17, 199, 211, 205, 0, 134, 176, 64, 145, 36, 101, 122, 38, 171, 175, 83, 246, 43]), registerReadCount := 4, registerWriteCount := 2, ramEventCount := 0, twistLinkCount := 4, ramReadCount := 0, ramWriteCount := 0, regMix := 10806869914316609246, ramMix := 1959622797672027888, points := { firstRead := (some { id := { object := { familyTag := 2, commitmentDigest := (bytes [109, 179, 182, 82, 28, 183, 239, 230, 75, 61, 152, 59, 60, 94, 218, 88, 182, 122, 240, 253, 78, 226, 159, 206, 96, 63, 126, 149, 74, 133, 70, 193]), layoutVersion := 1, digest := (bytes [145, 218, 98, 114, 158, 103, 98, 227, 168, 204, 228, 48, 175, 80, 247, 129, 181, 128, 230, 234, 176, 108, 100, 203, 13, 175, 187, 31, 255, 73, 169, 171]) }, logicalIndex := 0, digest := (bytes [249, 60, 240, 242, 228, 229, 192, 247, 203, 236, 74, 41, 107, 66, 120, 74, 188, 55, 119, 61, 180, 224, 11, 167, 100, 38, 0, 5, 239, 152, 232, 188]) }, valueDigest := (bytes [165, 2, 50, 180, 56, 84, 68, 13, 37, 136, 82, 191, 49, 42, 150, 67, 180, 45, 199, 251, 168, 91, 53, 39, 20, 9, 70, 46, 155, 135, 100, 116]), digest := (bytes [86, 163, 4, 224, 141, 166, 113, 253, 110, 225, 103, 115, 222, 95, 6, 99, 170, 219, 204, 4, 17, 223, 248, 66, 93, 223, 214, 86, 16, 75, 62, 170]) }), lastRead := (some { id := { object := { familyTag := 2, commitmentDigest := (bytes [109, 179, 182, 82, 28, 183, 239, 230, 75, 61, 152, 59, 60, 94, 218, 88, 182, 122, 240, 253, 78, 226, 159, 206, 96, 63, 126, 149, 74, 133, 70, 193]), layoutVersion := 1, digest := (bytes [145, 218, 98, 114, 158, 103, 98, 227, 168, 204, 228, 48, 175, 80, 247, 129, 181, 128, 230, 234, 176, 108, 100, 203, 13, 175, 187, 31, 255, 73, 169, 171]) }, logicalIndex := 3, digest := (bytes [181, 234, 194, 152, 173, 76, 225, 83, 167, 143, 219, 190, 219, 128, 129, 67, 218, 124, 64, 82, 39, 63, 102, 68, 236, 254, 142, 203, 219, 34, 57, 206]) }, valueDigest := (bytes [160, 84, 47, 218, 46, 65, 160, 13, 188, 132, 241, 222, 202, 178, 117, 86, 147, 45, 110, 179, 253, 83, 180, 119, 10, 191, 213, 44, 20, 14, 38, 138]), digest := (bytes [140, 4, 112, 37, 51, 104, 16, 226, 121, 226, 16, 46, 94, 1, 5, 140, 236, 7, 57, 33, 213, 3, 89, 253, 159, 1, 154, 202, 127, 58, 228, 175]) }), firstWrite := (some { id := { object := { familyTag := 3, commitmentDigest := (bytes [97, 131, 235, 8, 197, 56, 92, 13, 100, 146, 90, 190, 235, 233, 212, 196, 7, 77, 86, 194, 176, 195, 144, 106, 186, 143, 238, 70, 18, 153, 101, 162]), layoutVersion := 1, digest := (bytes [80, 156, 245, 25, 167, 49, 101, 221, 71, 18, 126, 65, 145, 108, 122, 149, 79, 27, 108, 217, 41, 166, 245, 165, 210, 59, 144, 226, 137, 184, 104, 200]) }, logicalIndex := 0, digest := (bytes [156, 112, 13, 141, 64, 126, 27, 60, 120, 216, 140, 240, 132, 55, 253, 76, 74, 233, 225, 157, 98, 29, 110, 222, 82, 14, 182, 218, 194, 75, 92, 173]) }, valueDigest := (bytes [240, 234, 163, 16, 221, 91, 181, 255, 218, 220, 23, 163, 115, 95, 43, 209, 188, 58, 213, 171, 79, 216, 97, 203, 207, 166, 211, 123, 104, 206, 62, 69]), digest := (bytes [50, 85, 249, 222, 45, 127, 206, 187, 56, 111, 18, 218, 58, 203, 24, 17, 193, 58, 74, 7, 252, 145, 19, 43, 182, 35, 23, 191, 226, 105, 26, 39]) }), lastWrite := (some { id := { object := { familyTag := 3, commitmentDigest := (bytes [97, 131, 235, 8, 197, 56, 92, 13, 100, 146, 90, 190, 235, 233, 212, 196, 7, 77, 86, 194, 176, 195, 144, 106, 186, 143, 238, 70, 18, 153, 101, 162]), layoutVersion := 1, digest := (bytes [80, 156, 245, 25, 167, 49, 101, 221, 71, 18, 126, 65, 145, 108, 122, 149, 79, 27, 108, 217, 41, 166, 245, 165, 210, 59, 144, 226, 137, 184, 104, 200]) }, logicalIndex := 1, digest := (bytes [160, 51, 249, 99, 36, 198, 148, 248, 188, 3, 251, 166, 3, 163, 65, 197, 122, 112, 17, 17, 221, 66, 248, 103, 5, 81, 110, 226, 205, 47, 3, 182]) }, valueDigest := (bytes [219, 157, 144, 2, 32, 103, 22, 163, 10, 232, 209, 222, 151, 26, 83, 50, 34, 204, 238, 236, 243, 105, 193, 200, 130, 129, 94, 186, 152, 13, 104, 117]), digest := (bytes [253, 167, 108, 211, 5, 157, 104, 90, 73, 63, 175, 15, 59, 154, 145, 63, 35, 20, 23, 161, 97, 68, 144, 180, 218, 192, 3, 49, 190, 123, 117, 167]) }), firstRam := none, lastRam := none, firstTwist := (some { id := { object := { familyTag := 5, commitmentDigest := (bytes [189, 86, 40, 245, 73, 43, 251, 9, 70, 221, 169, 206, 117, 249, 17, 199, 211, 205, 0, 134, 176, 64, 145, 36, 101, 122, 38, 171, 175, 83, 246, 43]), layoutVersion := 1, digest := (bytes [211, 42, 23, 116, 236, 61, 199, 120, 10, 116, 172, 246, 158, 189, 168, 41, 4, 236, 234, 71, 41, 93, 183, 40, 73, 121, 53, 108, 181, 186, 226, 232]) }, logicalIndex := 0, digest := (bytes [165, 166, 73, 250, 31, 10, 57, 113, 168, 175, 247, 15, 149, 168, 221, 194, 204, 76, 121, 23, 159, 77, 122, 165, 145, 78, 98, 218, 124, 225, 203, 219]) }, valueDigest := (bytes [121, 235, 4, 171, 3, 253, 36, 219, 172, 48, 102, 248, 218, 28, 241, 41, 240, 7, 47, 1, 38, 163, 250, 209, 189, 85, 19, 181, 56, 168, 140, 70]), digest := (bytes [220, 174, 75, 18, 145, 66, 208, 246, 120, 133, 139, 207, 22, 2, 26, 235, 236, 14, 71, 60, 146, 254, 206, 52, 207, 92, 62, 71, 28, 176, 56, 150]) }), lastTwist := (some { id := { object := { familyTag := 5, commitmentDigest := (bytes [189, 86, 40, 245, 73, 43, 251, 9, 70, 221, 169, 206, 117, 249, 17, 199, 211, 205, 0, 134, 176, 64, 145, 36, 101, 122, 38, 171, 175, 83, 246, 43]), layoutVersion := 1, digest := (bytes [211, 42, 23, 116, 236, 61, 199, 120, 10, 116, 172, 246, 158, 189, 168, 41, 4, 236, 234, 71, 41, 93, 183, 40, 73, 121, 53, 108, 181, 186, 226, 232]) }, logicalIndex := 3, digest := (bytes [139, 123, 235, 24, 96, 100, 239, 237, 133, 25, 202, 44, 207, 47, 190, 98, 193, 171, 9, 240, 21, 191, 129, 29, 231, 132, 234, 204, 144, 80, 35, 251]) }, valueDigest := (bytes [192, 220, 106, 41, 104, 255, 230, 149, 225, 60, 106, 47, 173, 175, 166, 9, 41, 27, 129, 156, 118, 121, 84, 121, 134, 180, 118, 205, 49, 136, 155, 48]), digest := (bytes [149, 222, 42, 9, 241, 38, 75, 65, 212, 240, 95, 81, 207, 250, 135, 38, 97, 144, 115, 41, 157, 112, 52, 164, 172, 160, 224, 237, 73, 75, 105, 83]) }) }, digest := (bytes [39, 137, 142, 161, 1, 2, 44, 242, 28, 97, 246, 5, 222, 103, 90, 98, 14, 192, 220, 115, 61, 12, 194, 0, 62, 136, 129, 235, 67, 152, 212, 146]) }, packaged := { statementDigest := (bytes [75, 35, 25, 79, 165, 202, 8, 208, 41, 41, 110, 238, 31, 236, 186, 79, 174, 217, 133, 6, 59, 120, 179, 178, 127, 94, 49, 16, 143, 71, 119, 254]), proofDigest := (bytes [252, 70, 235, 49, 232, 149, 127, 178, 213, 141, 239, 125, 223, 100, 81, 46, 95, 168, 191, 97, 177, 83, 87, 147, 78, 6, 217, 17, 31, 37, 181, 188]) }, digest := (bytes [182, 4, 63, 106, 219, 9, 187, 36, 105, 197, 64, 83, 214, 8, 228, 125, 163, 167, 24, 8, 190, 202, 97, 143, 101, 80, 2, 184, 123, 141, 92, 68]) }
    , digest := (bytes [115, 6, 59, 143, 127, 212, 236, 228, 182, 37, 83, 96, 132, 19, 47, 90, 133, 220, 187, 102, 14, 18, 114, 9, 197, 2, 116, 22, 25, 171, 150, 248])
  }

def stage3Continuity : List ContinuityEventView :=
  [{ stepIndex := 0, pc := 0, nextPc := 4, successorPc := (some 4), finalStep := false, continuityHolds := true }, { stepIndex := 1, pc := 4, nextPc := 8, successorPc := (some 8), finalStep := false, continuityHolds := true }, { stepIndex := 2, pc := 8, nextPc := 16, successorPc := (some 16), finalStep := false, continuityHolds := true }, { stepIndex := 3, pc := 16, nextPc := 20, successorPc := none, finalStep := true, continuityHolds := true }]

def stage3 : Stage3ProofBundleView :=
  {
    continuity := stage3Continuity
    , halted := true
    , bridgeDigest := (bytes [91, 155, 151, 36, 255, 29, 65, 219, 97, 184, 149, 17, 61, 71, 65, 67, 235, 95, 174, 182, 147, 224, 135, 172, 219, 41, 164, 217, 0, 115, 255, 45])
    , semantics := { continuityDigest := (bytes [225, 36, 55, 237, 16, 70, 173, 226, 205, 215, 188, 143, 132, 20, 5, 220, 229, 9, 111, 156, 132, 73, 165, 86, 137, 203, 45, 225, 35, 181, 205, 156]), rootSemanticRowsDigest := (bytes [185, 82, 14, 202, 7, 227, 79, 193, 54, 161, 216, 135, 128, 57, 235, 114, 181, 210, 19, 252, 166, 42, 201, 7, 187, 69, 39, 207, 129, 186, 76, 15]), rowChunkRoutesDigest := (bytes [170, 16, 215, 245, 131, 192, 198, 120, 95, 134, 175, 93, 217, 74, 16, 26, 237, 138, 81, 110, 201, 10, 195, 254, 244, 178, 29, 18, 146, 128, 117, 178]), preparedStepBindingsDigest := (bytes [129, 88, 205, 31, 122, 194, 197, 123, 130, 181, 17, 239, 205, 213, 80, 253, 251, 34, 140, 79, 238, 89, 224, 13, 192, 53, 124, 88, 4, 85, 168, 55]), stage2TemporalDigest := (bytes [171, 82, 105, 161, 220, 165, 62, 34, 9, 68, 238, 64, 61, 241, 181, 104, 19, 131, 49, 152, 2, 161, 128, 164, 37, 248, 247, 114, 110, 131, 251, 178]), initialPc := 0, finalPc := 20, realRowCount := 4, firstRealStepIndex := 0, lastRealStepIndex := 3, digest := (bytes [87, 72, 94, 207, 175, 254, 73, 239, 64, 1, 194, 112, 223, 222, 219, 104, 51, 79, 151, 8, 129, 253, 175, 201, 58, 6, 100, 51, 185, 69, 69, 211]) }
    , linkageDigest := (bytes [156, 156, 190, 235, 83, 163, 59, 191, 19, 47, 173, 104, 125, 121, 235, 2, 222, 44, 253, 20, 255, 151, 135, 33, 50, 216, 102, 184, 74, 250, 27, 115])
    , selectedOpening := { claim := { continuityFamilyDigest := (bytes [178, 177, 3, 134, 28, 140, 16, 149, 40, 220, 221, 198, 83, 202, 237, 105, 228, 80, 184, 187, 23, 255, 100, 66, 229, 141, 99, 228, 121, 52, 39, 88]), continuityCount := 4, finalStepCount := 1, halted := true, allContinuityHold := true, continuityMix := 2657263387322609258, points := { firstContinuity := (some { id := { object := { familyTag := 6, commitmentDigest := (bytes [178, 177, 3, 134, 28, 140, 16, 149, 40, 220, 221, 198, 83, 202, 237, 105, 228, 80, 184, 187, 23, 255, 100, 66, 229, 141, 99, 228, 121, 52, 39, 88]), layoutVersion := 1, digest := (bytes [236, 90, 105, 33, 46, 31, 185, 17, 37, 216, 190, 237, 8, 199, 200, 149, 254, 224, 190, 206, 223, 121, 110, 130, 238, 225, 162, 254, 31, 249, 173, 150]) }, logicalIndex := 0, digest := (bytes [36, 4, 204, 3, 12, 51, 32, 211, 254, 81, 204, 224, 109, 243, 139, 63, 6, 61, 51, 231, 182, 115, 199, 54, 57, 226, 50, 162, 160, 40, 253, 38]) }, valueDigest := (bytes [7, 131, 85, 21, 57, 109, 53, 31, 137, 53, 98, 18, 170, 36, 28, 200, 149, 213, 171, 159, 119, 200, 36, 230, 30, 35, 30, 11, 252, 126, 240, 63]), digest := (bytes [159, 221, 198, 197, 117, 106, 171, 81, 126, 42, 45, 192, 53, 222, 104, 114, 206, 226, 149, 147, 249, 97, 130, 60, 203, 233, 175, 235, 13, 126, 42, 204]) }), lastContinuity := (some { id := { object := { familyTag := 6, commitmentDigest := (bytes [178, 177, 3, 134, 28, 140, 16, 149, 40, 220, 221, 198, 83, 202, 237, 105, 228, 80, 184, 187, 23, 255, 100, 66, 229, 141, 99, 228, 121, 52, 39, 88]), layoutVersion := 1, digest := (bytes [236, 90, 105, 33, 46, 31, 185, 17, 37, 216, 190, 237, 8, 199, 200, 149, 254, 224, 190, 206, 223, 121, 110, 130, 238, 225, 162, 254, 31, 249, 173, 150]) }, logicalIndex := 3, digest := (bytes [185, 131, 50, 144, 41, 2, 89, 43, 206, 251, 1, 1, 71, 14, 103, 59, 244, 113, 72, 157, 221, 62, 96, 81, 169, 115, 86, 73, 16, 35, 0, 164]) }, valueDigest := (bytes [252, 134, 254, 33, 173, 19, 91, 16, 165, 37, 97, 183, 229, 243, 58, 241, 249, 218, 169, 205, 3, 229, 51, 197, 80, 15, 234, 120, 189, 254, 221, 45]), digest := (bytes [7, 151, 236, 244, 72, 147, 236, 219, 52, 132, 206, 18, 122, 251, 235, 250, 29, 51, 30, 67, 170, 84, 135, 7, 20, 212, 173, 168, 155, 255, 130, 67]) }) }, digest := (bytes [43, 108, 133, 61, 92, 227, 250, 215, 75, 28, 31, 75, 147, 200, 99, 110, 16, 134, 11, 133, 217, 202, 17, 130, 143, 161, 16, 240, 186, 102, 164, 19]) }, packaged := { statementDigest := (bytes [64, 157, 6, 142, 159, 230, 160, 200, 251, 65, 251, 203, 147, 13, 230, 185, 146, 75, 113, 70, 23, 60, 88, 91, 247, 36, 98, 166, 19, 183, 237, 253]), proofDigest := (bytes [18, 147, 77, 37, 56, 53, 151, 182, 135, 226, 200, 125, 134, 49, 109, 127, 118, 31, 120, 78, 56, 192, 99, 0, 254, 151, 208, 207, 168, 126, 121, 163]) }, digest := (bytes [118, 192, 152, 28, 171, 93, 163, 128, 250, 17, 224, 22, 63, 144, 156, 254, 84, 82, 166, 26, 33, 242, 136, 166, 53, 92, 234, 136, 103, 80, 76, 20]) }
    , digest := (bytes [255, 75, 100, 162, 254, 15, 109, 219, 206, 44, 180, 49, 42, 84, 242, 51, 206, 38, 153, 164, 203, 87, 139, 134, 249, 88, 57, 168, 156, 55, 121, 230])
  }

def rootExecutionExecutionRows : List ExpandedRowView :=
  [{
  traceIndex := 0
  , stepIndex := 0
  , sequenceIndex := 0
  , pc := 0
  , nextPc := 4
  , word := 2097299
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
  , rdAfter := 2
  , imm := 2
  , aluResult := 2
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
  , word := 1048851
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
  , rdAfter := 1
  , imm := 1
  , aluResult := 1
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
  , nextPc := 16
  , word := 2159715
  , opcode := .bgeu
  , traceOpcode := (some .bgeu)
  , traceVirtualOpcode := none
  , family := .controlFlow
  , rs1 := 1
  , rs1Value := 2
  , rs2 := 2
  , rs2Value := 1
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
  traceIndex := 3
  , stepIndex := 3
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

def rootExecutionSemanticRows : List RootSemanticRowView :=
  [{ traceIndex := 0, values := [1, 0, 0, 4, 0, 0, 0, 0, 0, 2, 0, 2, 0, 2, 0, 4, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [16, 18, 204, 238, 34, 55, 227, 219, 112, 224, 153, 77, 87, 255, 222, 57, 93, 120, 113, 190, 238, 193, 38, 190, 84, 232, 126, 51, 50, 221, 88, 172]), digest := (bytes [60, 96, 27, 121, 197, 246, 95, 131, 95, 19, 118, 161, 209, 173, 89, 228, 121, 97, 116, 220, 194, 171, 50, 178, 1, 152, 70, 63, 141, 103, 156, 150]) }, { traceIndex := 1, values := [1, 4, 0, 8, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 8, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [81, 24, 106, 244, 9, 121, 253, 136, 123, 77, 188, 238, 80, 81, 119, 140, 17, 79, 179, 253, 207, 20, 68, 136, 9, 114, 221, 212, 70, 78, 75, 136]), digest := (bytes [173, 148, 70, 219, 203, 26, 166, 194, 228, 106, 92, 4, 43, 89, 74, 154, 83, 57, 0, 204, 232, 92, 161, 144, 18, 252, 35, 233, 22, 72, 62, 121]) }, { traceIndex := 2, values := [1, 8, 0, 16, 0, 2, 0, 1, 0, 0, 0, 8, 0, 1, 0, 12, 0, 16, 0, 0, 0, 0, 0, 0, 1, 2, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1], rowDigest := (bytes [58, 39, 122, 156, 68, 55, 17, 184, 32, 54, 224, 251, 47, 252, 145, 179, 174, 52, 97, 131, 120, 137, 219, 10, 156, 159, 210, 136, 12, 27, 25, 210]), digest := (bytes [217, 167, 163, 18, 7, 119, 101, 12, 245, 36, 200, 132, 76, 156, 1, 121, 228, 246, 26, 85, 213, 94, 26, 191, 210, 182, 241, 183, 10, 137, 205, 211]) }, { traceIndex := 3, values := [1, 16, 0, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [196, 164, 211, 128, 251, 108, 127, 209, 13, 46, 5, 165, 45, 208, 166, 224, 83, 53, 211, 10, 49, 76, 179, 158, 125, 185, 30, 27, 57, 200, 134, 221]) }]

def rootExecutionPreparedBindings : List PreparedStepBindingView :=
  [{ traceIndex := 0, rowDigest := (bytes [16, 18, 204, 238, 34, 55, 227, 219, 112, 224, 153, 77, 87, 255, 222, 57, 93, 120, 113, 190, 238, 193, 38, 190, 84, 232, 126, 51, 50, 221, 88, 172]), rowOpeningDigest := (bytes [113, 111, 113, 72, 209, 21, 197, 38, 79, 2, 169, 207, 184, 209, 224, 240, 202, 126, 144, 79, 56, 134, 102, 207, 25, 208, 184, 3, 29, 252, 81, 188]), digest := (bytes [246, 98, 181, 148, 255, 57, 197, 109, 132, 254, 155, 250, 67, 176, 149, 200, 214, 106, 86, 238, 93, 45, 0, 87, 217, 158, 66, 230, 116, 83, 8, 163]) }, { traceIndex := 1, rowDigest := (bytes [81, 24, 106, 244, 9, 121, 253, 136, 123, 77, 188, 238, 80, 81, 119, 140, 17, 79, 179, 253, 207, 20, 68, 136, 9, 114, 221, 212, 70, 78, 75, 136]), rowOpeningDigest := (bytes [81, 72, 50, 89, 58, 1, 87, 80, 245, 178, 70, 92, 197, 50, 138, 52, 201, 135, 249, 136, 7, 218, 226, 10, 66, 131, 25, 137, 255, 88, 28, 67]), digest := (bytes [100, 80, 252, 35, 52, 2, 184, 171, 227, 139, 65, 171, 18, 244, 55, 30, 193, 143, 58, 120, 221, 8, 162, 11, 76, 11, 120, 84, 13, 255, 76, 11]) }, { traceIndex := 2, rowDigest := (bytes [58, 39, 122, 156, 68, 55, 17, 184, 32, 54, 224, 251, 47, 252, 145, 179, 174, 52, 97, 131, 120, 137, 219, 10, 156, 159, 210, 136, 12, 27, 25, 210]), rowOpeningDigest := (bytes [182, 234, 128, 83, 111, 136, 28, 100, 35, 153, 239, 126, 58, 23, 39, 165, 21, 121, 23, 140, 190, 61, 106, 217, 173, 103, 147, 159, 66, 88, 230, 242]), digest := (bytes [176, 122, 141, 73, 150, 24, 233, 75, 167, 11, 147, 176, 73, 169, 241, 92, 113, 24, 8, 184, 195, 225, 130, 117, 248, 172, 93, 197, 241, 244, 180, 111]) }, { traceIndex := 3, rowDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), rowOpeningDigest := (bytes [197, 124, 175, 176, 136, 105, 83, 70, 4, 160, 98, 196, 5, 243, 56, 51, 137, 176, 18, 3, 131, 197, 173, 64, 80, 45, 117, 240, 55, 66, 193, 2]), digest := (bytes [254, 99, 83, 87, 142, 13, 25, 128, 17, 223, 67, 18, 69, 171, 237, 57, 247, 99, 239, 18, 152, 182, 82, 245, 246, 112, 106, 248, 5, 254, 200, 205]) }]

def rootExecutionRowChunkRoutes : List RowChunkRouteView :=
  [{ logicalIndex := 0, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 0, digest := (bytes [138, 198, 109, 126, 144, 82, 221, 43, 248, 202, 137, 103, 62, 226, 249, 152, 163, 187, 1, 254, 36, 33, 59, 16, 64, 166, 202, 8, 219, 57, 240, 59]) }, { logicalIndex := 1, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 1, digest := (bytes [44, 177, 82, 41, 218, 60, 100, 208, 26, 31, 151, 113, 109, 148, 57, 12, 223, 21, 76, 221, 70, 245, 191, 105, 57, 199, 8, 128, 181, 145, 89, 99]) }, { logicalIndex := 2, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 2, digest := (bytes [252, 248, 65, 24, 81, 241, 150, 170, 250, 116, 222, 30, 134, 191, 78, 195, 104, 119, 225, 210, 243, 186, 212, 107, 183, 31, 243, 201, 101, 148, 32, 72]) }, { logicalIndex := 3, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 3, digest := (bytes [244, 11, 162, 13, 59, 43, 232, 47, 228, 2, 70, 126, 95, 10, 57, 40, 46, 107, 197, 81, 97, 39, 185, 163, 93, 60, 5, 66, 7, 231, 199, 134]) }]

def rootExecutionRowLocalCcsAcceptance : List RootRowLocalCcsAcceptanceView :=
  [{ traceIndex := 0, logicalIndex := 0, rowDigest := (bytes [16, 18, 204, 238, 34, 55, 227, 219, 112, 224, 153, 77, 87, 255, 222, 57, 93, 120, 113, 190, 238, 193, 38, 190, 84, 232, 126, 51, 50, 221, 88, 172]), rowOpeningDigest := (bytes [113, 111, 113, 72, 209, 21, 197, 38, 79, 2, 169, 207, 184, 209, 224, 240, 202, 126, 144, 79, 56, 134, 102, 207, 25, 208, 184, 3, 29, 252, 81, 188]), preparedStepBindingDigest := (bytes [246, 98, 181, 148, 255, 57, 197, 109, 132, 254, 155, 250, 67, 176, 149, 200, 214, 106, 86, 238, 93, 45, 0, 87, 217, 158, 66, 230, 116, 83, 8, 163]), rowChunkRouteDigest := (bytes [138, 198, 109, 126, 144, 82, 221, 43, 248, 202, 137, 103, 62, 226, 249, 152, 163, 187, 1, 254, 36, 33, 59, 16, 64, 166, 202, 8, 219, 57, 240, 59]), publicStepDigest := (bytes [17, 131, 26, 152, 4, 35, 177, 101, 109, 193, 62, 217, 251, 23, 0, 125, 12, 174, 248, 38, 157, 10, 135, 77, 111, 36, 110, 205, 224, 129, 42, 23]), digest := (bytes [48, 222, 198, 214, 80, 158, 84, 105, 17, 22, 10, 105, 211, 248, 183, 117, 130, 57, 68, 244, 220, 142, 77, 22, 48, 73, 186, 210, 92, 72, 64, 59]) }, { traceIndex := 1, logicalIndex := 1, rowDigest := (bytes [81, 24, 106, 244, 9, 121, 253, 136, 123, 77, 188, 238, 80, 81, 119, 140, 17, 79, 179, 253, 207, 20, 68, 136, 9, 114, 221, 212, 70, 78, 75, 136]), rowOpeningDigest := (bytes [81, 72, 50, 89, 58, 1, 87, 80, 245, 178, 70, 92, 197, 50, 138, 52, 201, 135, 249, 136, 7, 218, 226, 10, 66, 131, 25, 137, 255, 88, 28, 67]), preparedStepBindingDigest := (bytes [100, 80, 252, 35, 52, 2, 184, 171, 227, 139, 65, 171, 18, 244, 55, 30, 193, 143, 58, 120, 221, 8, 162, 11, 76, 11, 120, 84, 13, 255, 76, 11]), rowChunkRouteDigest := (bytes [44, 177, 82, 41, 218, 60, 100, 208, 26, 31, 151, 113, 109, 148, 57, 12, 223, 21, 76, 221, 70, 245, 191, 105, 57, 199, 8, 128, 181, 145, 89, 99]), publicStepDigest := (bytes [139, 105, 238, 217, 75, 237, 252, 214, 128, 167, 136, 142, 206, 95, 123, 134, 61, 233, 191, 24, 127, 249, 138, 93, 109, 174, 8, 134, 131, 163, 164, 79]), digest := (bytes [4, 128, 13, 230, 223, 17, 110, 66, 51, 139, 85, 36, 91, 111, 199, 48, 27, 69, 237, 202, 240, 22, 146, 174, 94, 121, 0, 38, 143, 194, 143, 234]) }, { traceIndex := 2, logicalIndex := 2, rowDigest := (bytes [58, 39, 122, 156, 68, 55, 17, 184, 32, 54, 224, 251, 47, 252, 145, 179, 174, 52, 97, 131, 120, 137, 219, 10, 156, 159, 210, 136, 12, 27, 25, 210]), rowOpeningDigest := (bytes [182, 234, 128, 83, 111, 136, 28, 100, 35, 153, 239, 126, 58, 23, 39, 165, 21, 121, 23, 140, 190, 61, 106, 217, 173, 103, 147, 159, 66, 88, 230, 242]), preparedStepBindingDigest := (bytes [176, 122, 141, 73, 150, 24, 233, 75, 167, 11, 147, 176, 73, 169, 241, 92, 113, 24, 8, 184, 195, 225, 130, 117, 248, 172, 93, 197, 241, 244, 180, 111]), rowChunkRouteDigest := (bytes [252, 248, 65, 24, 81, 241, 150, 170, 250, 116, 222, 30, 134, 191, 78, 195, 104, 119, 225, 210, 243, 186, 212, 107, 183, 31, 243, 201, 101, 148, 32, 72]), publicStepDigest := (bytes [58, 207, 229, 0, 137, 45, 189, 69, 205, 147, 59, 189, 202, 90, 115, 100, 188, 68, 81, 225, 88, 129, 59, 36, 196, 3, 253, 91, 189, 226, 51, 66]), digest := (bytes [126, 150, 217, 62, 115, 240, 42, 145, 227, 234, 97, 239, 179, 214, 8, 160, 57, 101, 171, 130, 231, 148, 120, 144, 224, 102, 137, 83, 84, 25, 155, 218]) }, { traceIndex := 3, logicalIndex := 3, rowDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), rowOpeningDigest := (bytes [197, 124, 175, 176, 136, 105, 83, 70, 4, 160, 98, 196, 5, 243, 56, 51, 137, 176, 18, 3, 131, 197, 173, 64, 80, 45, 117, 240, 55, 66, 193, 2]), preparedStepBindingDigest := (bytes [254, 99, 83, 87, 142, 13, 25, 128, 17, 223, 67, 18, 69, 171, 237, 57, 247, 99, 239, 18, 152, 182, 82, 245, 246, 112, 106, 248, 5, 254, 200, 205]), rowChunkRouteDigest := (bytes [244, 11, 162, 13, 59, 43, 232, 47, 228, 2, 70, 126, 95, 10, 57, 40, 46, 107, 197, 81, 97, 39, 185, 163, 93, 60, 5, 66, 7, 231, 199, 134]), publicStepDigest := (bytes [72, 142, 192, 218, 173, 197, 55, 221, 78, 31, 126, 194, 22, 139, 72, 204, 128, 208, 103, 242, 122, 221, 175, 246, 50, 244, 221, 89, 210, 23, 111, 183]), digest := (bytes [20, 255, 254, 123, 69, 201, 16, 27, 199, 61, 247, 227, 84, 195, 171, 112, 45, 41, 141, 232, 159, 30, 223, 211, 239, 27, 69, 250, 60, 179, 32, 249]) }]

def rootExecutionExecutionSemanticsRefinement : List RootExecutionSemanticsRefinementView :=
  [{ traceIndex := 0, logicalIndex := 0, semanticRowDigest := (bytes [60, 96, 27, 121, 197, 246, 95, 131, 95, 19, 118, 161, 209, 173, 89, 228, 121, 97, 116, 220, 194, 171, 50, 178, 1, 152, 70, 63, 141, 103, 156, 150]), rowLocalCcsAcceptanceDigest := (bytes [48, 222, 198, 214, 80, 158, 84, 105, 17, 22, 10, 105, 211, 248, 183, 117, 130, 57, 68, 244, 220, 142, 77, 22, 48, 73, 186, 210, 92, 72, 64, 59]), preparedStepBindingDigest := (bytes [246, 98, 181, 148, 255, 57, 197, 109, 132, 254, 155, 250, 67, 176, 149, 200, 214, 106, 86, 238, 93, 45, 0, 87, 217, 158, 66, 230, 116, 83, 8, 163]), publicStepDigest := (bytes [17, 131, 26, 152, 4, 35, 177, 101, 109, 193, 62, 217, 251, 23, 0, 125, 12, 174, 248, 38, 157, 10, 135, 77, 111, 36, 110, 205, 224, 129, 42, 23]), digest := (bytes [106, 77, 156, 130, 162, 45, 27, 6, 2, 78, 109, 173, 79, 233, 168, 148, 204, 213, 28, 133, 203, 250, 167, 71, 156, 214, 138, 92, 168, 43, 155, 171]) }, { traceIndex := 1, logicalIndex := 1, semanticRowDigest := (bytes [173, 148, 70, 219, 203, 26, 166, 194, 228, 106, 92, 4, 43, 89, 74, 154, 83, 57, 0, 204, 232, 92, 161, 144, 18, 252, 35, 233, 22, 72, 62, 121]), rowLocalCcsAcceptanceDigest := (bytes [4, 128, 13, 230, 223, 17, 110, 66, 51, 139, 85, 36, 91, 111, 199, 48, 27, 69, 237, 202, 240, 22, 146, 174, 94, 121, 0, 38, 143, 194, 143, 234]), preparedStepBindingDigest := (bytes [100, 80, 252, 35, 52, 2, 184, 171, 227, 139, 65, 171, 18, 244, 55, 30, 193, 143, 58, 120, 221, 8, 162, 11, 76, 11, 120, 84, 13, 255, 76, 11]), publicStepDigest := (bytes [139, 105, 238, 217, 75, 237, 252, 214, 128, 167, 136, 142, 206, 95, 123, 134, 61, 233, 191, 24, 127, 249, 138, 93, 109, 174, 8, 134, 131, 163, 164, 79]), digest := (bytes [119, 105, 147, 61, 154, 138, 98, 231, 97, 159, 86, 208, 254, 253, 202, 224, 98, 120, 15, 148, 107, 97, 29, 156, 204, 225, 96, 72, 244, 109, 110, 173]) }, { traceIndex := 2, logicalIndex := 2, semanticRowDigest := (bytes [217, 167, 163, 18, 7, 119, 101, 12, 245, 36, 200, 132, 76, 156, 1, 121, 228, 246, 26, 85, 213, 94, 26, 191, 210, 182, 241, 183, 10, 137, 205, 211]), rowLocalCcsAcceptanceDigest := (bytes [126, 150, 217, 62, 115, 240, 42, 145, 227, 234, 97, 239, 179, 214, 8, 160, 57, 101, 171, 130, 231, 148, 120, 144, 224, 102, 137, 83, 84, 25, 155, 218]), preparedStepBindingDigest := (bytes [176, 122, 141, 73, 150, 24, 233, 75, 167, 11, 147, 176, 73, 169, 241, 92, 113, 24, 8, 184, 195, 225, 130, 117, 248, 172, 93, 197, 241, 244, 180, 111]), publicStepDigest := (bytes [58, 207, 229, 0, 137, 45, 189, 69, 205, 147, 59, 189, 202, 90, 115, 100, 188, 68, 81, 225, 88, 129, 59, 36, 196, 3, 253, 91, 189, 226, 51, 66]), digest := (bytes [255, 212, 10, 5, 215, 57, 234, 207, 10, 60, 209, 125, 94, 135, 117, 112, 31, 199, 228, 107, 53, 206, 191, 119, 85, 249, 52, 12, 187, 21, 253, 19]) }, { traceIndex := 3, logicalIndex := 3, semanticRowDigest := (bytes [196, 164, 211, 128, 251, 108, 127, 209, 13, 46, 5, 165, 45, 208, 166, 224, 83, 53, 211, 10, 49, 76, 179, 158, 125, 185, 30, 27, 57, 200, 134, 221]), rowLocalCcsAcceptanceDigest := (bytes [20, 255, 254, 123, 69, 201, 16, 27, 199, 61, 247, 227, 84, 195, 171, 112, 45, 41, 141, 232, 159, 30, 223, 211, 239, 27, 69, 250, 60, 179, 32, 249]), preparedStepBindingDigest := (bytes [254, 99, 83, 87, 142, 13, 25, 128, 17, 223, 67, 18, 69, 171, 237, 57, 247, 99, 239, 18, 152, 182, 82, 245, 246, 112, 106, 248, 5, 254, 200, 205]), publicStepDigest := (bytes [72, 142, 192, 218, 173, 197, 55, 221, 78, 31, 126, 194, 22, 139, 72, 204, 128, 208, 103, 242, 122, 221, 175, 246, 50, 244, 221, 89, 210, 23, 111, 183]), digest := (bytes [194, 214, 203, 241, 188, 64, 170, 17, 164, 82, 101, 137, 61, 224, 8, 90, 161, 203, 247, 37, 99, 146, 51, 106, 82, 153, 83, 42, 125, 160, 131, 121]) }]

def rootExecution : RootExecutionBundleView :=
  {
    executionRows := rootExecutionExecutionRows
    , semanticRows := rootExecutionSemanticRows
    , semanticRowsDigest := (bytes [185, 82, 14, 202, 7, 227, 79, 193, 54, 161, 216, 135, 128, 57, 235, 114, 181, 210, 19, 252, 166, 42, 201, 7, 187, 69, 39, 207, 129, 186, 76, 15])
    , preparedStepBindings := { bindings := rootExecutionPreparedBindings, bindingCount := 4, firstBindingDigest := (some (bytes [246, 98, 181, 148, 255, 57, 197, 109, 132, 254, 155, 250, 67, 176, 149, 200, 214, 106, 86, 238, 93, 45, 0, 87, 217, 158, 66, 230, 116, 83, 8, 163])), lastBindingDigest := (some (bytes [254, 99, 83, 87, 142, 13, 25, 128, 17, 223, 67, 18, 69, 171, 237, 57, 247, 99, 239, 18, 152, 182, 82, 245, 246, 112, 106, 248, 5, 254, 200, 205])), digest := (bytes [129, 88, 205, 31, 122, 194, 197, 123, 130, 181, 17, 239, 205, 213, 80, 253, 251, 34, 140, 79, 238, 89, 224, 13, 192, 53, 124, 88, 4, 85, 168, 55]) }
    , rowChunkRoutes := rootExecutionRowChunkRoutes
    , rowChunkRoutesDigest := (bytes [170, 16, 215, 245, 131, 192, 198, 120, 95, 134, 175, 93, 217, 74, 16, 26, 237, 138, 81, 110, 201, 10, 195, 254, 244, 178, 29, 18, 146, 128, 117, 178])
    , rowLocalCcsAcceptance := { acceptances := rootExecutionRowLocalCcsAcceptance, acceptanceCount := 4, firstAcceptanceDigest := (some (bytes [48, 222, 198, 214, 80, 158, 84, 105, 17, 22, 10, 105, 211, 248, 183, 117, 130, 57, 68, 244, 220, 142, 77, 22, 48, 73, 186, 210, 92, 72, 64, 59])), lastAcceptanceDigest := (some (bytes [20, 255, 254, 123, 69, 201, 16, 27, 199, 61, 247, 227, 84, 195, 171, 112, 45, 41, 141, 232, 159, 30, 223, 211, 239, 27, 69, 250, 60, 179, 32, 249])), digest := (bytes [46, 70, 153, 0, 135, 70, 219, 51, 239, 125, 237, 199, 40, 31, 55, 100, 139, 163, 143, 199, 50, 35, 151, 248, 70, 176, 45, 10, 145, 23, 17, 196]) }
    , executionSemanticsRefinement := { refinements := rootExecutionExecutionSemanticsRefinement, refinementCount := 4, firstRefinementDigest := (some (bytes [106, 77, 156, 130, 162, 45, 27, 6, 2, 78, 109, 173, 79, 233, 168, 148, 204, 213, 28, 133, 203, 250, 167, 71, 156, 214, 138, 92, 168, 43, 155, 171])), lastRefinementDigest := (some (bytes [194, 214, 203, 241, 188, 64, 170, 17, 164, 82, 101, 137, 61, 224, 8, 90, 161, 203, 247, 37, 99, 146, 51, 106, 82, 153, 83, 42, 125, 160, 131, 121])), digest := (bytes [172, 124, 248, 2, 0, 232, 212, 42, 220, 84, 228, 108, 249, 205, 49, 30, 236, 179, 185, 116, 43, 7, 238, 108, 123, 21, 148, 173, 52, 112, 91, 72]) }
    , familyDigest := (bytes [25, 242, 215, 184, 254, 20, 90, 185, 232, 189, 207, 235, 115, 136, 182, 48, 249, 188, 59, 126, 24, 245, 6, 203, 160, 163, 22, 116, 111, 63, 199, 193])
    , digest := (bytes [88, 250, 237, 83, 89, 208, 61, 163, 200, 108, 165, 207, 134, 167, 234, 77, 35, 205, 97, 195, 142, 135, 222, 194, 33, 148, 186, 4, 49, 166, 172, 215])
  }

def kernelOpeningBundle : SimpleKernelOpeningBundleView :=
  {
    claim := { bindings := { stageClaimBundleDigest := (bytes [224, 201, 173, 115, 16, 169, 230, 244, 82, 92, 10, 191, 220, 189, 26, 104, 94, 147, 3, 207, 153, 214, 192, 54, 230, 130, 54, 146, 88, 45, 255, 104]), stagePackageBundleDigest := (bytes [201, 255, 135, 89, 100, 112, 244, 221, 158, 73, 161, 80, 120, 100, 150, 234, 84, 221, 91, 163, 45, 13, 136, 121, 11, 99, 35, 106, 97, 157, 255, 33]), stage1PackageDigest := (bytes [130, 174, 243, 222, 39, 159, 87, 21, 175, 112, 43, 65, 6, 32, 190, 202, 78, 221, 86, 44, 131, 56, 104, 211, 120, 203, 122, 142, 72, 244, 82, 162]), stage2PackageDigest := (bytes [182, 4, 63, 106, 219, 9, 187, 36, 105, 197, 64, 83, 214, 8, 228, 125, 163, 167, 24, 8, 190, 202, 97, 143, 101, 80, 2, 184, 123, 141, 92, 68]), stage3PackageDigest := (bytes [118, 192, 152, 28, 171, 93, 163, 128, 250, 17, 224, 22, 63, 144, 156, 254, 84, 82, 166, 26, 33, 242, 136, 166, 53, 92, 234, 136, 103, 80, 76, 20]), preparedStepBindingsDigest := (bytes [129, 88, 205, 31, 122, 194, 197, 123, 130, 181, 17, 239, 205, 213, 80, 253, 251, 34, 140, 79, 238, 89, 224, 13, 192, 53, 124, 88, 4, 85, 168, 55]), bindingCount := 4, stage1RowCount := 4, stage2RegisterReadCount := 4, stage2RegisterWriteCount := 2, stage2RamEventCount := 0, stage3ContinuityCount := 4, points := { firstBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [129, 88, 205, 31, 122, 194, 197, 123, 130, 181, 17, 239, 205, 213, 80, 253, 251, 34, 140, 79, 238, 89, 224, 13, 192, 53, 124, 88, 4, 85, 168, 55]), layoutVersion := 1, digest := (bytes [233, 48, 73, 152, 100, 238, 127, 133, 88, 180, 106, 168, 166, 65, 66, 93, 165, 116, 168, 126, 3, 61, 176, 15, 77, 29, 116, 244, 248, 45, 73, 90]) }, logicalIndex := 0, digest := (bytes [132, 225, 98, 223, 240, 236, 222, 222, 238, 165, 45, 1, 79, 35, 173, 134, 104, 181, 104, 80, 188, 237, 246, 38, 218, 83, 202, 188, 152, 2, 151, 142]) }, valueDigest := (bytes [246, 98, 181, 148, 255, 57, 197, 109, 132, 254, 155, 250, 67, 176, 149, 200, 214, 106, 86, 238, 93, 45, 0, 87, 217, 158, 66, 230, 116, 83, 8, 163]), digest := (bytes [142, 105, 136, 220, 93, 11, 151, 48, 109, 185, 78, 2, 167, 149, 13, 66, 140, 140, 117, 10, 174, 54, 194, 149, 146, 119, 144, 34, 144, 58, 71, 230]) }), lastBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [129, 88, 205, 31, 122, 194, 197, 123, 130, 181, 17, 239, 205, 213, 80, 253, 251, 34, 140, 79, 238, 89, 224, 13, 192, 53, 124, 88, 4, 85, 168, 55]), layoutVersion := 1, digest := (bytes [233, 48, 73, 152, 100, 238, 127, 133, 88, 180, 106, 168, 166, 65, 66, 93, 165, 116, 168, 126, 3, 61, 176, 15, 77, 29, 116, 244, 248, 45, 73, 90]) }, logicalIndex := 3, digest := (bytes [216, 202, 198, 138, 209, 218, 29, 51, 96, 234, 81, 163, 238, 119, 252, 151, 93, 85, 69, 81, 120, 78, 137, 127, 106, 95, 240, 240, 23, 108, 122, 229]) }, valueDigest := (bytes [254, 99, 83, 87, 142, 13, 25, 128, 17, 223, 67, 18, 69, 171, 237, 57, 247, 99, 239, 18, 152, 182, 82, 245, 246, 112, 106, 248, 5, 254, 200, 205]), digest := (bytes [129, 41, 215, 230, 252, 173, 35, 38, 81, 231, 152, 229, 167, 225, 9, 155, 129, 63, 190, 202, 5, 223, 112, 1, 95, 159, 88, 56, 135, 42, 154, 201]) }) }, digest := (bytes [221, 26, 56, 74, 26, 0, 202, 179, 128, 33, 215, 161, 247, 144, 15, 44, 116, 236, 80, 59, 123, 151, 167, 45, 93, 78, 127, 194, 105, 118, 2, 7]) }, preparedSteps := { executionDigest := (bytes [216, 222, 179, 38, 20, 54, 249, 142, 177, 39, 183, 229, 29, 226, 13, 225, 74, 252, 72, 165, 4, 145, 80, 197, 205, 158, 197, 254, 151, 248, 6, 131]), finalStateDigest := (bytes [207, 244, 140, 140, 253, 220, 153, 85, 210, 72, 78, 149, 45, 76, 101, 175, 63, 107, 102, 240, 184, 237, 98, 242, 203, 60, 16, 255, 244, 31, 162, 249]), transcriptFinalDigest := (bytes [220, 210, 243, 194, 82, 47, 210, 0, 22, 21, 24, 49, 198, 154, 28, 14, 214, 176, 219, 99, 123, 33, 22, 249, 10, 120, 148, 255, 68, 207, 116, 2]), preparedStepCount := 4, finalPc := 20, halted := true, points := { firstPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [224, 35, 130, 146, 73, 187, 180, 161, 207, 126, 172, 132, 75, 27, 45, 130, 95, 188, 79, 180, 97, 222, 14, 171, 162, 112, 240, 232, 195, 86, 247, 255]), layoutVersion := 3, digest := (bytes [73, 219, 13, 49, 103, 247, 89, 166, 27, 108, 67, 127, 15, 169, 73, 6, 209, 175, 225, 108, 224, 209, 237, 64, 72, 252, 167, 45, 73, 146, 155, 48]) }, logicalIndex := 0, digest := (bytes [23, 192, 58, 164, 26, 55, 218, 251, 99, 242, 254, 15, 136, 176, 28, 136, 128, 246, 130, 180, 140, 153, 188, 49, 52, 63, 8, 210, 49, 107, 105, 71]) }, valueDigest := (bytes [16, 18, 204, 238, 34, 55, 227, 219, 112, 224, 153, 77, 87, 255, 222, 57, 93, 120, 113, 190, 238, 193, 38, 190, 84, 232, 126, 51, 50, 221, 88, 172]), digest := (bytes [82, 152, 47, 125, 240, 238, 38, 102, 66, 145, 113, 22, 238, 165, 163, 111, 107, 0, 135, 54, 70, 71, 176, 39, 95, 98, 9, 66, 244, 202, 154, 32]) }), lastPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [224, 35, 130, 146, 73, 187, 180, 161, 207, 126, 172, 132, 75, 27, 45, 130, 95, 188, 79, 180, 97, 222, 14, 171, 162, 112, 240, 232, 195, 86, 247, 255]), layoutVersion := 3, digest := (bytes [73, 219, 13, 49, 103, 247, 89, 166, 27, 108, 67, 127, 15, 169, 73, 6, 209, 175, 225, 108, 224, 209, 237, 64, 72, 252, 167, 45, 73, 146, 155, 48]) }, logicalIndex := 3, digest := (bytes [90, 134, 137, 77, 249, 107, 189, 181, 52, 146, 43, 116, 82, 82, 78, 93, 175, 11, 187, 228, 162, 43, 196, 92, 67, 20, 241, 239, 245, 202, 241, 97]) }, valueDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [16, 20, 62, 26, 165, 5, 139, 163, 57, 15, 250, 146, 67, 199, 114, 6, 83, 128, 154, 182, 12, 172, 181, 146, 186, 187, 199, 193, 101, 10, 132, 108]) }) }, digest := (bytes [168, 2, 186, 5, 123, 215, 23, 85, 125, 161, 208, 185, 4, 134, 25, 20, 81, 28, 53, 133, 80, 105, 133, 86, 24, 156, 28, 0, 91, 209, 86, 97]) }, digest := (bytes [233, 29, 192, 247, 8, 136, 44, 53, 125, 99, 242, 175, 186, 199, 178, 144, 73, 20, 162, 240, 120, 223, 127, 134, 226, 237, 149, 30, 84, 53, 135, 41]) }
    , bindings := { claim := { stageClaimBundleDigest := (bytes [224, 201, 173, 115, 16, 169, 230, 244, 82, 92, 10, 191, 220, 189, 26, 104, 94, 147, 3, 207, 153, 214, 192, 54, 230, 130, 54, 146, 88, 45, 255, 104]), stagePackageBundleDigest := (bytes [201, 255, 135, 89, 100, 112, 244, 221, 158, 73, 161, 80, 120, 100, 150, 234, 84, 221, 91, 163, 45, 13, 136, 121, 11, 99, 35, 106, 97, 157, 255, 33]), stage1PackageDigest := (bytes [130, 174, 243, 222, 39, 159, 87, 21, 175, 112, 43, 65, 6, 32, 190, 202, 78, 221, 86, 44, 131, 56, 104, 211, 120, 203, 122, 142, 72, 244, 82, 162]), stage2PackageDigest := (bytes [182, 4, 63, 106, 219, 9, 187, 36, 105, 197, 64, 83, 214, 8, 228, 125, 163, 167, 24, 8, 190, 202, 97, 143, 101, 80, 2, 184, 123, 141, 92, 68]), stage3PackageDigest := (bytes [118, 192, 152, 28, 171, 93, 163, 128, 250, 17, 224, 22, 63, 144, 156, 254, 84, 82, 166, 26, 33, 242, 136, 166, 53, 92, 234, 136, 103, 80, 76, 20]), preparedStepBindingsDigest := (bytes [129, 88, 205, 31, 122, 194, 197, 123, 130, 181, 17, 239, 205, 213, 80, 253, 251, 34, 140, 79, 238, 89, 224, 13, 192, 53, 124, 88, 4, 85, 168, 55]), bindingCount := 4, stage1RowCount := 4, stage2RegisterReadCount := 4, stage2RegisterWriteCount := 2, stage2RamEventCount := 0, stage3ContinuityCount := 4, points := { firstBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [129, 88, 205, 31, 122, 194, 197, 123, 130, 181, 17, 239, 205, 213, 80, 253, 251, 34, 140, 79, 238, 89, 224, 13, 192, 53, 124, 88, 4, 85, 168, 55]), layoutVersion := 1, digest := (bytes [233, 48, 73, 152, 100, 238, 127, 133, 88, 180, 106, 168, 166, 65, 66, 93, 165, 116, 168, 126, 3, 61, 176, 15, 77, 29, 116, 244, 248, 45, 73, 90]) }, logicalIndex := 0, digest := (bytes [132, 225, 98, 223, 240, 236, 222, 222, 238, 165, 45, 1, 79, 35, 173, 134, 104, 181, 104, 80, 188, 237, 246, 38, 218, 83, 202, 188, 152, 2, 151, 142]) }, valueDigest := (bytes [246, 98, 181, 148, 255, 57, 197, 109, 132, 254, 155, 250, 67, 176, 149, 200, 214, 106, 86, 238, 93, 45, 0, 87, 217, 158, 66, 230, 116, 83, 8, 163]), digest := (bytes [142, 105, 136, 220, 93, 11, 151, 48, 109, 185, 78, 2, 167, 149, 13, 66, 140, 140, 117, 10, 174, 54, 194, 149, 146, 119, 144, 34, 144, 58, 71, 230]) }), lastBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [129, 88, 205, 31, 122, 194, 197, 123, 130, 181, 17, 239, 205, 213, 80, 253, 251, 34, 140, 79, 238, 89, 224, 13, 192, 53, 124, 88, 4, 85, 168, 55]), layoutVersion := 1, digest := (bytes [233, 48, 73, 152, 100, 238, 127, 133, 88, 180, 106, 168, 166, 65, 66, 93, 165, 116, 168, 126, 3, 61, 176, 15, 77, 29, 116, 244, 248, 45, 73, 90]) }, logicalIndex := 3, digest := (bytes [216, 202, 198, 138, 209, 218, 29, 51, 96, 234, 81, 163, 238, 119, 252, 151, 93, 85, 69, 81, 120, 78, 137, 127, 106, 95, 240, 240, 23, 108, 122, 229]) }, valueDigest := (bytes [254, 99, 83, 87, 142, 13, 25, 128, 17, 223, 67, 18, 69, 171, 237, 57, 247, 99, 239, 18, 152, 182, 82, 245, 246, 112, 106, 248, 5, 254, 200, 205]), digest := (bytes [129, 41, 215, 230, 252, 173, 35, 38, 81, 231, 152, 229, 167, 225, 9, 155, 129, 63, 190, 202, 5, 223, 112, 1, 95, 159, 88, 56, 135, 42, 154, 201]) }) }, digest := (bytes [221, 26, 56, 74, 26, 0, 202, 179, 128, 33, 215, 161, 247, 144, 15, 44, 116, 236, 80, 59, 123, 151, 167, 45, 93, 78, 127, 194, 105, 118, 2, 7]) }, packaged := { statementDigest := (bytes [62, 190, 75, 30, 162, 225, 148, 170, 115, 190, 36, 52, 60, 220, 219, 97, 43, 116, 125, 232, 90, 250, 51, 78, 47, 90, 183, 202, 82, 205, 219, 75]), proofDigest := (bytes [46, 111, 132, 84, 223, 3, 199, 234, 119, 35, 157, 146, 36, 11, 103, 102, 155, 159, 131, 13, 248, 106, 237, 2, 181, 79, 56, 63, 108, 249, 79, 148]) }, digest := (bytes [191, 4, 51, 6, 94, 48, 172, 219, 100, 92, 162, 144, 159, 143, 193, 39, 155, 211, 15, 146, 90, 254, 129, 35, 195, 70, 64, 90, 228, 155, 120, 48]) }
    , preparedSteps := { claim := { executionDigest := (bytes [216, 222, 179, 38, 20, 54, 249, 142, 177, 39, 183, 229, 29, 226, 13, 225, 74, 252, 72, 165, 4, 145, 80, 197, 205, 158, 197, 254, 151, 248, 6, 131]), finalStateDigest := (bytes [207, 244, 140, 140, 253, 220, 153, 85, 210, 72, 78, 149, 45, 76, 101, 175, 63, 107, 102, 240, 184, 237, 98, 242, 203, 60, 16, 255, 244, 31, 162, 249]), transcriptFinalDigest := (bytes [220, 210, 243, 194, 82, 47, 210, 0, 22, 21, 24, 49, 198, 154, 28, 14, 214, 176, 219, 99, 123, 33, 22, 249, 10, 120, 148, 255, 68, 207, 116, 2]), preparedStepCount := 4, finalPc := 20, halted := true, points := { firstPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [224, 35, 130, 146, 73, 187, 180, 161, 207, 126, 172, 132, 75, 27, 45, 130, 95, 188, 79, 180, 97, 222, 14, 171, 162, 112, 240, 232, 195, 86, 247, 255]), layoutVersion := 3, digest := (bytes [73, 219, 13, 49, 103, 247, 89, 166, 27, 108, 67, 127, 15, 169, 73, 6, 209, 175, 225, 108, 224, 209, 237, 64, 72, 252, 167, 45, 73, 146, 155, 48]) }, logicalIndex := 0, digest := (bytes [23, 192, 58, 164, 26, 55, 218, 251, 99, 242, 254, 15, 136, 176, 28, 136, 128, 246, 130, 180, 140, 153, 188, 49, 52, 63, 8, 210, 49, 107, 105, 71]) }, valueDigest := (bytes [16, 18, 204, 238, 34, 55, 227, 219, 112, 224, 153, 77, 87, 255, 222, 57, 93, 120, 113, 190, 238, 193, 38, 190, 84, 232, 126, 51, 50, 221, 88, 172]), digest := (bytes [82, 152, 47, 125, 240, 238, 38, 102, 66, 145, 113, 22, 238, 165, 163, 111, 107, 0, 135, 54, 70, 71, 176, 39, 95, 98, 9, 66, 244, 202, 154, 32]) }), lastPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [224, 35, 130, 146, 73, 187, 180, 161, 207, 126, 172, 132, 75, 27, 45, 130, 95, 188, 79, 180, 97, 222, 14, 171, 162, 112, 240, 232, 195, 86, 247, 255]), layoutVersion := 3, digest := (bytes [73, 219, 13, 49, 103, 247, 89, 166, 27, 108, 67, 127, 15, 169, 73, 6, 209, 175, 225, 108, 224, 209, 237, 64, 72, 252, 167, 45, 73, 146, 155, 48]) }, logicalIndex := 3, digest := (bytes [90, 134, 137, 77, 249, 107, 189, 181, 52, 146, 43, 116, 82, 82, 78, 93, 175, 11, 187, 228, 162, 43, 196, 92, 67, 20, 241, 239, 245, 202, 241, 97]) }, valueDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [16, 20, 62, 26, 165, 5, 139, 163, 57, 15, 250, 146, 67, 199, 114, 6, 83, 128, 154, 182, 12, 172, 181, 146, 186, 187, 199, 193, 101, 10, 132, 108]) }) }, digest := (bytes [168, 2, 186, 5, 123, 215, 23, 85, 125, 161, 208, 185, 4, 134, 25, 20, 81, 28, 53, 133, 80, 105, 133, 86, 24, 156, 28, 0, 91, 209, 86, 97]) }, packaged := { statementDigest := (bytes [8, 219, 238, 178, 247, 214, 212, 96, 32, 60, 207, 176, 210, 186, 90, 84, 37, 56, 121, 242, 241, 50, 203, 144, 226, 49, 145, 34, 56, 62, 68, 109]), proofDigest := (bytes [198, 147, 3, 92, 189, 194, 53, 210, 61, 135, 223, 249, 182, 200, 130, 187, 53, 214, 61, 136, 10, 230, 51, 112, 100, 159, 131, 249, 44, 99, 111, 104]) }, digest := (bytes [175, 67, 54, 44, 255, 117, 192, 118, 14, 93, 142, 131, 123, 234, 138, 135, 168, 227, 78, 140, 10, 110, 73, 40, 187, 240, 199, 211, 168, 154, 90, 250]) }
    , digest := (bytes [218, 41, 39, 230, 165, 102, 65, 80, 104, 208, 33, 60, 133, 147, 57, 209, 186, 177, 47, 218, 192, 172, 103, 49, 37, 58, 104, 127, 42, 16, 17, 182])
  }

def stepComposition : StepCompositionSurfaceView :=
  {
    stage1SemanticsDigest := (bytes [37, 121, 123, 22, 243, 173, 26, 205, 17, 190, 8, 30, 198, 54, 230, 70, 161, 53, 230, 124, 167, 42, 84, 137, 37, 43, 127, 216, 0, 5, 52, 21])
    , stage2SemanticsDigest := (bytes [244, 158, 19, 248, 207, 201, 20, 51, 160, 66, 173, 215, 62, 2, 210, 184, 29, 18, 134, 112, 75, 1, 104, 200, 237, 254, 33, 210, 164, 188, 243, 239])
    , stage2TemporalDigest := (bytes [171, 82, 105, 161, 220, 165, 62, 34, 9, 68, 238, 64, 61, 241, 181, 104, 19, 131, 49, 152, 2, 161, 128, 164, 37, 248, 247, 114, 110, 131, 251, 178])
    , stage3SemanticsDigest := (bytes [87, 72, 94, 207, 175, 254, 73, 239, 64, 1, 194, 112, 223, 222, 219, 104, 51, 79, 151, 8, 129, 253, 175, 201, 58, 6, 100, 51, 185, 69, 69, 211])
    , rootExecutionDigest := (bytes [88, 250, 237, 83, 89, 208, 61, 163, 200, 108, 165, 207, 134, 167, 234, 77, 35, 205, 97, 195, 142, 135, 222, 194, 33, 148, 186, 4, 49, 166, 172, 215])
    , preparedStepBindingsDigest := (bytes [129, 88, 205, 31, 122, 194, 197, 123, 130, 181, 17, 239, 205, 213, 80, 253, 251, 34, 140, 79, 238, 89, 224, 13, 192, 53, 124, 88, 4, 85, 168, 55])
    , rowChunkRoutesDigest := (bytes [170, 16, 215, 245, 131, 192, 198, 120, 95, 134, 175, 93, 217, 74, 16, 26, 237, 138, 81, 110, 201, 10, 195, 254, 244, 178, 29, 18, 146, 128, 117, 178])
    , realRowCount := 4
    , preparedStepCount := 4
    , firstRealStepIndex := 0
    , lastRealStepIndex := 3
    , initialPc := 0
    , finalPc := 20
    , halted := true
    , digest := (bytes [140, 138, 236, 248, 249, 55, 153, 118, 239, 255, 232, 212, 31, 166, 78, 237, 26, 223, 234, 54, 244, 31, 127, 130, 189, 154, 205, 38, 238, 29, 21, 209])
  }

def soundnessAccounting : KernelSoundnessAccountingSurfaceView :=
  {
    schemaVersion := 1
    , stage1ShoutChannels := ["bytecode", "alu", "branch"]
    , stage1AddressFamilies := ["bytecode", "alu", "branch"]
    , stage2AddressFamilies := ["reg", "ram"]
    , twistMemoryFamilies := ["reg", "ram"]
    , scalarTerms := ["ram_raf", "stage1_linkage", "stage2_linkage", "continuity", "opening_provenance", "program_binding", "pcs", "fs", "outer"]
    , schemaDigest := (bytes [165, 80, 74, 18, 114, 207, 102, 75, 141, 3, 200, 237, 122, 193, 251, 46, 66, 26, 12, 63, 116, 14, 248, 113, 184, 88, 224, 13, 54, 52, 152, 45])
    , digest := (bytes [123, 169, 146, 221, 196, 9, 54, 236, 107, 117, 89, 201, 225, 110, 178, 107, 176, 205, 19, 10, 14, 127, 62, 30, 20, 173, 230, 254, 254, 22, 113, 22])
  }

def artifact : AcceptedProofArtifactView :=
  {
    name := "control_flow_bgeu_taken_skip_ecall"
    , source := {
  manifest := { name := "control_flow_bgeu_taken_skip_ecall", fixtureId := "control_flow_bgeu_taken_skip_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.controlFlow, .nativeAlu] }
  , startPc := 0
  , programWords := [2097299, 1048851, 2159715, 115, 115]
  , initialRegisters := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , initialMemory := []
  , transcriptSeed := (bytes [114, 118, 54, 52, 105, 109, 45, 99, 111, 110, 116, 114, 111, 108, 45, 102, 108, 111, 119, 45, 98, 103, 101, 117, 45, 118, 49])
}
    , derived := {
  manifest := { name := "control_flow_bgeu_taken_skip_ecall", fixtureId := "control_flow_bgeu_taken_skip_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.controlFlow, .nativeAlu] }
  , executionRows := [{
  traceIndex := 0
  , stepIndex := 0
  , sequenceIndex := 0
  , pc := 0
  , nextPc := 4
  , word := 2097299
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
  , rdAfter := 2
  , imm := 2
  , aluResult := 2
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
  , word := 1048851
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
  , rdAfter := 1
  , imm := 1
  , aluResult := 1
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
  , nextPc := 16
  , word := 2159715
  , opcode := .bgeu
  , traceOpcode := (some .bgeu)
  , traceVirtualOpcode := none
  , family := .controlFlow
  , rs1 := 1
  , rs1Value := 2
  , rs2 := 2
  , rs2Value := 1
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
  traceIndex := 3
  , stepIndex := 3
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
  , stage1 := { rows := [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 2097299, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 4, aluResult := 2, effectiveAddr := none, writesRd := true, rd := 1, rdAfter := 2, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 1048851, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 8, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 2, rdAfter := 1, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 2159715, opcode := .bgeu, traceOpcode := (some .bgeu), traceVirtualOpcode := none, family := .controlFlow, nextPc := 16, aluResult := 1, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 16, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 20, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }] }
  , stage2 := {
  registerReads := [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 0, value := 0 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 0, value := 0 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 1, value := 2 }, { traceIndex := 2, stepIndex := 2, role := .rs2, reg := 2, value := 1 }]
  , registerWrites := [{ traceIndex := 0, stepIndex := 0, reg := 1, previous := 0, next := 2 }, { traceIndex := 1, stepIndex := 1, reg := 2, previous := 0, next := 1 }]
  , ramEvents := []
  , twistLinks := [{ traceIndex := 0, stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 2), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 1, family := .nativeAlu, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 2, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 3, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]
}
  , stage3 := {
  continuity := [{ stepIndex := 0, pc := 0, nextPc := 4, successorPc := (some 4), finalStep := false, continuityHolds := true }, { stepIndex := 1, pc := 4, nextPc := 8, successorPc := (some 8), finalStep := false, continuityHolds := true }, { stepIndex := 2, pc := 8, nextPc := 16, successorPc := (some 16), finalStep := false, continuityHolds := true }, { stepIndex := 3, pc := 16, nextPc := 20, successorPc := none, finalStep := true, continuityHolds := true }]
  , halted := true
}
  , transcript := {
  appLabel := (bytes [110, 101, 111, 46, 102, 111, 108, 100, 46, 110, 101, 120, 116, 47, 114, 118, 54, 52, 105, 109, 47, 112, 97, 114, 105, 116, 121, 95, 107, 101, 114, 110, 101, 108, 95, 118, 49])
  , events := [{
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 116, 114, 97, 110, 115, 99, 114, 105, 112, 116, 95, 115, 101, 101, 100])
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 99, 111, 110, 116, 114, 111, 108, 45, 102, 108, 111, 119, 45, 98, 103, 101, 117, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [27634538711377453, 54383638570343, 1823709644592138771, 15695669540104460710, 8188744055654938720, 6008164579518882152, 10584698648648697023, 6532369056394176230], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [99, 111, 110, 116, 114, 111, 108, 95, 102, 108, 111, 119, 95, 98, 103, 101, 117, 95, 116, 97, 107, 101, 110, 95, 115, 107, 105, 112, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [27634538711377453, 54383638570343, 1823709644592138771, 15695669540104460710, 8188744055654938720, 6008164579518882152, 10584698648648697023, 6532369056394176230], absorbed := 2 }
  , cursorAfter := { stateWords := [119212746171743, 4115465076320722641, 10265791983627518635, 543941533280415099, 6470597071131417095, 3459529626164976671, 6538594751029149855, 9202376365345449052], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [2097299, 1048851, 2159715, 115, 115]
  , cursorBefore := { stateWords := [119212746171743, 4115465076320722641, 10265791983627518635, 543941533280415099, 6470597071131417095, 3459529626164976671, 6538594751029149855, 9202376365345449052], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 7631244085689216595, 8440193799965894114, 14388964891207711840, 2056782885545757663, 1529144530094235108, 2253812106308094552, 13023645497027124897], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [0, 7631244085689216595, 8440193799965894114, 14388964891207711840, 2056782885545757663, 1529144530094235108, 2253812106308094552, 13023645497027124897], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 0, 0, 8054943088534077807, 13846332591903095255, 12463867618150028911, 14586359305607902986, 11717871853396826665], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [0, 0, 0, 8054943088534077807, 13846332591903095255, 12463867618150028911, 14586359305607902986, 11717871853396826665], absorbed := 3 }
  , cursorAfter := { stateWords := [0, 230873779471710420, 6964603481912124136, 11370762658102756114, 607388998938196074, 10350170456409138927, 12953860084092507636, 1082719992604845587], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [136, 28, 209, 27, 97, 186, 22, 192, 232, 198, 243, 170, 46, 6, 247, 29, 121, 48, 129, 111, 147, 109, 255, 41, 26, 208, 224, 144, 114, 105, 103, 152])
  , u64s := []
  , cursorBefore := { stateWords := [0, 230873779471710420, 6964603481912124136, 11370762658102756114, 607388998938196074, 10350170456409138927, 12953860084092507636, 1082719992604845587], absorbed := 1 }
  , cursorAfter := { stateWords := [2491980700698988972, 14068472359300423438, 17519047032954281148, 16448807135216549510, 14756161607341614720, 14989551616862978022, 13957537584803479485, 2382084973428616934], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [2491980700698988972, 14068472359300423438, 17519047032954281148, 16448807135216549510, 14756161607341614720, 14989551616862978022, 13957537584803479485, 2382084973428616934], absorbed := 0 }
  , cursorAfter := { stateWords := [2302652608239151864, 7130242139247192989, 1536477261163950027, 6314366652416881261, 9774956454389601012, 1241629233521582540, 11522590400807307548, 5735015773736746616], absorbed := 0 }
  , challengeOutput := (some 2302652608239151864)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [38, 1, 111, 25, 28, 52, 17, 93, 213, 60, 148, 249, 31, 250, 244, 14, 78, 84, 6, 40, 66, 110, 230, 118, 128, 211, 149, 94, 100, 248, 222, 19])
  , u64s := []
  , cursorBefore := { stateWords := [2302652608239151864, 7130242139247192989, 1536477261163950027, 6314366652416881261, 9774956454389601012, 1241629233521582540, 11522590400807307548, 5735015773736746616], absorbed := 0 }
  , cursorAfter := { stateWords := [18621356112219892, 26623383436715630, 333379684, 10485438589329696725, 14876902141821514848, 15276347457467243244, 16519611062992214112, 7256149985783836630], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [18621356112219892, 26623383436715630, 333379684, 10485438589329696725, 14876902141821514848, 15276347457467243244, 16519611062992214112, 7256149985783836630], absorbed := 3 }
  , cursorAfter := { stateWords := [10806869914316609246, 15806731556035115430, 12389253343389949275, 16729553705511047762, 6582825377533277016, 16734122218319710901, 8005843161548042819, 3880364712725972742], absorbed := 0 }
  , challengeOutput := (some 10806869914316609246)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [10806869914316609246, 15806731556035115430, 12389253343389949275, 16729553705511047762, 6582825377533277016, 16734122218319710901, 8005843161548042819, 3880364712725972742], absorbed := 0 }
  , cursorAfter := { stateWords := [1959622797672027888, 17651696247336291884, 11720460566859635632, 6919812372420016008, 5499717622967941681, 2853279359317452701, 14759054242794873370, 6243048439933786052], absorbed := 0 }
  , challengeOutput := (some 1959622797672027888)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [166, 190, 44, 132, 128, 151, 204, 56, 245, 149, 250, 100, 68, 251, 133, 216, 118, 141, 212, 118, 201, 209, 68, 33, 74, 28, 127, 220, 47, 90, 112, 230])
  , u64s := []
  , cursorBefore := { stateWords := [1959622797672027888, 17651696247336291884, 11720460566859635632, 6919812372420016008, 5499717622967941681, 2853279359317452701, 14759054242794873370, 6243048439933786052], absorbed := 0 }
  , cursorAfter := { stateWords := [56707125597362309, 62064254355850449, 3866122799, 12929877950451745014, 1756846508717143854, 9609595341734835927, 17484194971466081028, 13465387111089516922], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [56707125597362309, 62064254355850449, 3866122799, 12929877950451745014, 1756846508717143854, 9609595341734835927, 17484194971466081028, 13465387111089516922], absorbed := 3 }
  , cursorAfter := { stateWords := [2657263387322609258, 17421979329178809139, 9787209125109745185, 7491875297347501185, 1989378684025500775, 9005104167904948773, 10165090286127097813, 11761285918797788840], absorbed := 0 }
  , challengeOutput := (some 2657263387322609258)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [198, 81, 7, 250, 152, 135, 65, 159, 231, 42, 117, 161, 26, 121, 63, 197, 123, 212, 231, 113, 35, 37, 159, 177, 226, 104, 247, 68, 136, 30, 16, 163])
  , u64s := []
  , cursorBefore := { stateWords := [2657263387322609258, 17421979329178809139, 9787209125109745185, 7491875297347501185, 1989378684025500775, 9005104167904948773, 10165090286127097813, 11761285918797788840], absorbed := 0 }
  , cursorAfter := { stateWords := [9976864701138239, 19412328268275493, 2735742600, 4589826518242105380, 16312361777310826010, 14330958536230969493, 7763975302023814306, 2351550924013014552], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [216, 222, 179, 38, 20, 54, 249, 142, 177, 39, 183, 229, 29, 226, 13, 225, 74, 252, 72, 165, 4, 145, 80, 197, 205, 158, 197, 254, 151, 248, 6, 131])
  , u64s := []
  , cursorBefore := { stateWords := [9976864701138239, 19412328268275493, 2735742600, 4589826518242105380, 16312361777310826010, 14330958536230969493, 7763975302023814306, 2351550924013014552], absorbed := 3 }
  , cursorAfter := { stateWords := [1307632795836685, 71711929932271761, 2198272151, 5006567380650827533, 12695412723250713982, 2202973391026883564, 4455388109040917094, 12391254929522659973], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [207, 244, 140, 140, 253, 220, 153, 85, 210, 72, 78, 149, 45, 76, 101, 175, 63, 107, 102, 240, 184, 237, 98, 242, 203, 60, 16, 255, 244, 31, 162, 249])
  , u64s := []
  , cursorBefore := { stateWords := [1307632795836685, 71711929932271761, 2198272151, 5006567380650827533, 12695412723250713982, 2202973391026883564, 4455388109040917094, 12391254929522659973], absorbed := 3 }
  , cursorAfter := { stateWords := [52055718391426917, 71793972366959341, 4188151796, 14720217363501469615, 5839986288202124512, 15842499204513090931, 4209314985581236974, 3003143283336044558], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [52055718391426917, 71793972366959341, 4188151796, 14720217363501469615, 5839986288202124512, 15842499204513090931, 4209314985581236974, 3003143283336044558], absorbed := 3 }
  , cursorAfter := { stateWords := [1727357311060009140, 392412233049723249, 5376223040815207962, 5545438250291612210, 18191948353196698425, 2930334182322678240, 5188326213335546338, 3654734493943723780], absorbed := 0 }
  , challengeOutput := (some 1727357311060009140)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [1727357311060009140, 392412233049723249, 5376223040815207962, 5545438250291612210, 18191948353196698425, 2930334182322678240, 5188326213335546338, 3654734493943723780], absorbed := 0 }
  , cursorAfter := { stateWords := [59161777613820636, 1016857791896753430, 17948570178771726550, 176994180626937866, 2116920300628803648, 7782557740171667341, 9568767961969140595, 10469167577974212368], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [220, 210, 243, 194, 82, 47, 210, 0, 22, 21, 24, 49, 198, 154, 28, 14, 214, 176, 219, 99, 123, 33, 22, 249, 10, 120, 148, 255, 68, 207, 116, 2]))
}]
}
  , kernel := {
  root0Digest := (bytes [136, 28, 209, 27, 97, 186, 22, 192, 232, 198, 243, 170, 46, 6, 247, 29, 121, 48, 129, 111, 147, 109, 255, 41, 26, 208, 224, 144, 114, 105, 103, 152])
  , stage1Digest := (bytes [38, 1, 111, 25, 28, 52, 17, 93, 213, 60, 148, 249, 31, 250, 244, 14, 78, 84, 6, 40, 66, 110, 230, 118, 128, 211, 149, 94, 100, 248, 222, 19])
  , stage2Digest := (bytes [166, 190, 44, 132, 128, 151, 204, 56, 245, 149, 250, 100, 68, 251, 133, 216, 118, 141, 212, 118, 201, 209, 68, 33, 74, 28, 127, 220, 47, 90, 112, 230])
  , stage3Digest := (bytes [198, 81, 7, 250, 152, 135, 65, 159, 231, 42, 117, 161, 26, 121, 63, 197, 123, 212, 231, 113, 35, 37, 159, 177, 226, 104, 247, 68, 136, 30, 16, 163])
  , executionDigest := (bytes [216, 222, 179, 38, 20, 54, 249, 142, 177, 39, 183, 229, 29, 226, 13, 225, 74, 252, 72, 165, 4, 145, 80, 197, 205, 158, 197, 254, 151, 248, 6, 131])
  , finalStateDigest := (bytes [207, 244, 140, 140, 253, 220, 153, 85, 210, 72, 78, 149, 45, 76, 101, 175, 63, 107, 102, 240, 184, 237, 98, 242, 203, 60, 16, 255, 244, 31, 162, 249])
  , stage1Mix := 2302652608239151864
  , stage2RegMix := 10806869914316609246
  , stage2RamMix := 1959622797672027888
  , stage3ContinuityMix := 2657263387322609258
  , kernelFinalMix := 1727357311060009140
  , transcriptFinalDigest := (bytes [220, 210, 243, 194, 82, 47, 210, 0, 22, 21, 24, 49, 198, 154, 28, 14, 214, 176, 219, 99, 123, 33, 22, 249, 10, 120, 148, 255, 68, 207, 116, 2])
  , finalPc := 20
  , finalRegisters := [0, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , finalMemory := []
  , halted := true
}
}
    , kernelProof := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "control_flow_bgeu_taken_skip_ecall", fixtureId := "control_flow_bgeu_taken_skip_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.controlFlow, .nativeAlu] }
  , executionDigest := (bytes [216, 222, 179, 38, 20, 54, 249, 142, 177, 39, 183, 229, 29, 226, 13, 225, 74, 252, 72, 165, 4, 145, 80, 197, 205, 158, 197, 254, 151, 248, 6, 131])
  , shape := { executionRowCount := 4, realRowCount := 4, effectRowCount := 4, commitRowCount := 4, digest := (bytes [45, 178, 181, 197, 132, 60, 130, 1, 239, 208, 160, 249, 86, 246, 26, 179, 94, 235, 136, 250, 242, 5, 139, 0, 36, 216, 225, 255, 232, 86, 248, 123]) }
  , digest := (bytes [69, 124, 181, 213, 25, 23, 236, 30, 130, 199, 93, 40, 112, 241, 205, 116, 156, 230, 35, 190, 85, 192, 105, 145, 203, 220, 170, 14, 149, 228, 68, 31])
}
  , stages := { summary := { stage1RowCount := 4, stage2RegisterReadCount := 4, stage2RegisterWriteCount := 2, stage2RamEventCount := 0, stage2TwistLinkCount := 4, stage3ContinuityCount := 4, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [188, 146, 61, 220, 245, 51, 7, 161, 36, 1, 199, 100, 62, 187, 19, 182, 215, 124, 14, 176, 250, 206, 43, 76, 0, 125, 203, 144, 45, 193, 111, 34]) }, digest := (bytes [109, 34, 58, 13, 68, 111, 109, 31, 96, 208, 232, 119, 140, 198, 44, 192, 184, 71, 199, 65, 42, 115, 36, 133, 68, 13, 13, 169, 75, 7, 175, 245]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [224, 201, 173, 115, 16, 169, 230, 244, 82, 92, 10, 191, 220, 189, 26, 104, 94, 147, 3, 207, 153, 214, 192, 54, 230, 130, 54, 146, 88, 45, 255, 104]), stage1Digest := (bytes [112, 185, 47, 45, 40, 43, 97, 13, 83, 242, 126, 182, 239, 45, 100, 232, 22, 39, 165, 84, 184, 60, 93, 6, 138, 137, 33, 187, 49, 2, 241, 238]), stage2Digest := (bytes [211, 63, 102, 118, 255, 81, 200, 216, 247, 19, 168, 121, 232, 100, 242, 248, 84, 67, 76, 4, 169, 132, 38, 99, 183, 122, 249, 250, 156, 156, 152, 27]), stage3Digest := (bytes [241, 139, 61, 96, 28, 236, 184, 76, 31, 31, 90, 170, 231, 105, 75, 206, 127, 224, 133, 83, 235, 74, 203, 217, 94, 188, 29, 205, 255, 17, 30, 140]), transcriptDigest := (bytes [220, 210, 243, 194, 82, 47, 210, 0, 22, 21, 24, 49, 198, 154, 28, 14, 214, 176, 219, 99, 123, 33, 22, 249, 10, 120, 148, 255, 68, 207, 116, 2]), executionDigest := (bytes [216, 222, 179, 38, 20, 54, 249, 142, 177, 39, 183, 229, 29, 226, 13, 225, 74, 252, 72, 165, 4, 145, 80, 197, 205, 158, 197, 254, 151, 248, 6, 131]), digest := (bytes [191, 74, 251, 126, 250, 53, 177, 185, 122, 27, 171, 243, 175, 47, 223, 91, 82, 113, 135, 118, 67, 70, 98, 254, 150, 147, 7, 8, 26, 197, 179, 249]) }, statementDigest := (bytes [232, 117, 81, 34, 97, 83, 248, 229, 62, 28, 252, 216, 90, 26, 243, 173, 71, 41, 220, 91, 202, 238, 85, 106, 212, 166, 97, 6, 206, 170, 168, 10]), proofDigest := (bytes [126, 130, 236, 47, 188, 75, 22, 145, 77, 98, 206, 77, 117, 148, 76, 244, 137, 24, 74, 198, 71, 200, 139, 6, 92, 250, 203, 59, 53, 99, 85, 181]), digest := (bytes [43, 124, 10, 46, 101, 98, 126, 221, 48, 170, 172, 15, 128, 146, 73, 33, 193, 48, 6, 65, 212, 178, 209, 144, 126, 158, 251, 187, 238, 74, 155, 175]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [201, 255, 135, 89, 100, 112, 244, 221, 158, 73, 161, 80, 120, 100, 150, 234, 84, 221, 91, 163, 45, 13, 136, 121, 11, 99, 35, 106, 97, 157, 255, 33]), stage1Digest := (bytes [130, 174, 243, 222, 39, 159, 87, 21, 175, 112, 43, 65, 6, 32, 190, 202, 78, 221, 86, 44, 131, 56, 104, 211, 120, 203, 122, 142, 72, 244, 82, 162]), stage2Digest := (bytes [182, 4, 63, 106, 219, 9, 187, 36, 105, 197, 64, 83, 214, 8, 228, 125, 163, 167, 24, 8, 190, 202, 97, 143, 101, 80, 2, 184, 123, 141, 92, 68]), stage3Digest := (bytes [118, 192, 152, 28, 171, 93, 163, 128, 250, 17, 224, 22, 63, 144, 156, 254, 84, 82, 166, 26, 33, 242, 136, 166, 53, 92, 234, 136, 103, 80, 76, 20]), digest := (bytes [56, 62, 146, 161, 38, 174, 45, 14, 33, 115, 98, 73, 100, 140, 170, 77, 233, 22, 23, 84, 207, 33, 150, 231, 100, 228, 221, 142, 36, 151, 238, 224]) }, digest := (bytes [105, 229, 187, 246, 25, 23, 36, 81, 114, 222, 49, 199, 227, 237, 223, 121, 93, 13, 243, 202, 203, 133, 200, 21, 119, 100, 244, 72, 36, 136, 164, 179]) }
  , kernelOpening := { openingDigest := (bytes [218, 41, 39, 230, 165, 102, 65, 80, 104, 208, 33, 60, 133, 147, 57, 209, 186, 177, 47, 218, 192, 172, 103, 49, 37, 58, 104, 127, 42, 16, 17, 182]), bindings := { claimDigest := (bytes [233, 29, 192, 247, 8, 136, 44, 53, 125, 99, 242, 175, 186, 199, 178, 144, 73, 20, 162, 240, 120, 223, 127, 134, 226, 237, 149, 30, 84, 53, 135, 41]), bindingsDigest := (bytes [191, 4, 51, 6, 94, 48, 172, 219, 100, 92, 162, 144, 159, 143, 193, 39, 155, 211, 15, 146, 90, 254, 129, 35, 195, 70, 64, 90, 228, 155, 120, 48]), preparedStepsDigest := (bytes [175, 67, 54, 44, 255, 117, 192, 118, 14, 93, 142, 131, 123, 234, 138, 135, 168, 227, 78, 140, 10, 110, 73, 40, 187, 240, 199, 211, 168, 154, 90, 250]), digest := (bytes [149, 99, 147, 14, 14, 6, 253, 3, 182, 144, 34, 12, 93, 170, 109, 54, 239, 236, 66, 245, 178, 65, 183, 123, 248, 39, 11, 16, 252, 150, 174, 10]) }, digest := (bytes [27, 150, 255, 63, 85, 153, 185, 126, 162, 122, 198, 148, 77, 239, 85, 126, 86, 220, 211, 202, 66, 153, 181, 200, 186, 49, 170, 243, 64, 98, 191, 194]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [129, 88, 205, 31, 122, 194, 197, 123, 130, 181, 17, 239, 205, 213, 80, 253, 251, 34, 140, 79, 238, 89, 224, 13, 192, 53, 124, 88, 4, 85, 168, 55]), terminal := { root0Digest := (bytes [136, 28, 209, 27, 97, 186, 22, 192, 232, 198, 243, 170, 46, 6, 247, 29, 121, 48, 129, 111, 147, 109, 255, 41, 26, 208, 224, 144, 114, 105, 103, 152]), executionDigest := (bytes [216, 222, 179, 38, 20, 54, 249, 142, 177, 39, 183, 229, 29, 226, 13, 225, 74, 252, 72, 165, 4, 145, 80, 197, 205, 158, 197, 254, 151, 248, 6, 131]), finalStateDigest := (bytes [207, 244, 140, 140, 253, 220, 153, 85, 210, 72, 78, 149, 45, 76, 101, 175, 63, 107, 102, 240, 184, 237, 98, 242, 203, 60, 16, 255, 244, 31, 162, 249]), transcriptFinalDigest := (bytes [220, 210, 243, 194, 82, 47, 210, 0, 22, 21, 24, 49, 198, 154, 28, 14, 214, 176, 219, 99, 123, 33, 22, 249, 10, 120, 148, 255, 68, 207, 116, 2]), finalPc := 20, halted := true, digest := (bytes [230, 130, 151, 154, 26, 73, 48, 177, 171, 156, 247, 36, 229, 237, 235, 178, 76, 218, 151, 34, 120, 37, 159, 77, 124, 7, 88, 139, 201, 244, 46, 138]) }, digest := (bytes [223, 99, 247, 150, 25, 105, 60, 1, 224, 71, 244, 170, 170, 166, 74, 223, 174, 54, 29, 19, 94, 189, 48, 24, 231, 246, 233, 254, 174, 32, 71, 239]) }, statementDigest := (bytes [172, 98, 152, 75, 221, 218, 251, 125, 38, 77, 190, 76, 10, 28, 172, 244, 129, 182, 235, 204, 161, 217, 172, 167, 58, 131, 247, 109, 63, 249, 35, 99]), proofDigest := (bytes [159, 19, 219, 77, 69, 117, 42, 189, 34, 119, 209, 86, 67, 89, 168, 149, 225, 114, 238, 44, 242, 175, 141, 27, 123, 55, 87, 188, 159, 233, 3, 24]), digest := (bytes [222, 161, 136, 86, 37, 77, 100, 58, 71, 45, 220, 126, 181, 63, 132, 123, 166, 71, 26, 209, 3, 155, 11, 102, 50, 172, 160, 187, 90, 140, 144, 191]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [25, 242, 215, 184, 254, 20, 90, 185, 232, 189, 207, 235, 115, 136, 182, 48, 249, 188, 59, 126, 24, 245, 6, 203, 160, 163, 22, 116, 111, 63, 199, 193]), layoutVersion := 1, digest := (bytes [110, 102, 202, 253, 144, 17, 153, 81, 240, 59, 211, 141, 212, 238, 213, 218, 7, 149, 22, 140, 89, 124, 147, 70, 176, 145, 212, 50, 89, 224, 59, 77]) }, rowWidth := 38, timeLen := 4, columnDigests := [(bytes [212, 186, 229, 172, 74, 68, 211, 103, 24, 241, 21, 82, 209, 33, 189, 99, 223, 36, 129, 167, 9, 173, 76, 108, 178, 222, 90, 225, 89, 142, 8, 14]), (bytes [56, 58, 241, 13, 94, 161, 102, 38, 209, 85, 101, 10, 115, 74, 68, 15, 139, 16, 65, 164, 142, 61, 38, 80, 159, 19, 8, 220, 33, 174, 155, 155]), (bytes [29, 30, 250, 119, 67, 192, 190, 83, 169, 199, 126, 126, 209, 9, 207, 51, 13, 31, 240, 215, 38, 77, 233, 53, 71, 218, 94, 76, 41, 218, 33, 58]), (bytes [181, 122, 105, 181, 35, 180, 95, 214, 79, 41, 41, 2, 114, 48, 216, 55, 223, 211, 166, 64, 24, 33, 244, 234, 111, 10, 124, 63, 69, 70, 27, 116]), (bytes [235, 168, 211, 18, 219, 164, 123, 11, 1, 214, 235, 228, 142, 231, 19, 191, 111, 116, 112, 196, 167, 65, 6, 113, 150, 204, 141, 39, 111, 24, 165, 153]), (bytes [121, 130, 244, 43, 235, 154, 135, 182, 125, 251, 219, 139, 88, 218, 127, 71, 219, 212, 14, 47, 150, 5, 16, 183, 37, 152, 140, 186, 198, 73, 221, 183]), (bytes [91, 136, 102, 108, 254, 142, 77, 48, 97, 138, 138, 188, 220, 213, 55, 183, 133, 216, 230, 69, 191, 7, 253, 203, 112, 162, 85, 64, 74, 16, 34, 24]), (bytes [132, 13, 123, 172, 120, 106, 189, 241, 207, 17, 23, 219, 168, 136, 164, 0, 142, 128, 126, 198, 69, 95, 67, 194, 148, 13, 102, 136, 180, 146, 31, 139]), (bytes [13, 51, 13, 112, 10, 98, 204, 18, 53, 169, 156, 155, 63, 147, 114, 64, 241, 138, 154, 179, 238, 77, 114, 193, 171, 122, 197, 145, 246, 175, 206, 33]), (bytes [248, 213, 174, 164, 44, 211, 83, 119, 168, 127, 195, 214, 11, 72, 96, 216, 198, 29, 242, 145, 123, 183, 225, 150, 175, 102, 111, 235, 208, 130, 139, 155]), (bytes [32, 64, 97, 165, 48, 228, 106, 97, 58, 99, 14, 168, 63, 135, 66, 111, 135, 195, 225, 237, 39, 221, 23, 227, 16, 4, 135, 55, 248, 191, 135, 167]), (bytes [228, 208, 212, 3, 158, 123, 159, 22, 200, 85, 94, 53, 133, 251, 112, 144, 104, 119, 103, 120, 106, 126, 134, 102, 254, 183, 119, 5, 230, 104, 137, 4]), (bytes [238, 189, 198, 6, 199, 30, 93, 193, 29, 126, 221, 61, 73, 119, 129, 87, 55, 227, 133, 106, 170, 178, 160, 203, 102, 209, 230, 172, 220, 2, 72, 166]), (bytes [128, 172, 240, 189, 197, 88, 138, 41, 109, 81, 42, 68, 25, 21, 173, 79, 110, 210, 130, 146, 48, 191, 99, 218, 113, 149, 146, 144, 184, 14, 150, 106]), (bytes [74, 226, 37, 10, 152, 135, 71, 32, 121, 204, 236, 95, 238, 168, 237, 37, 113, 198, 64, 103, 189, 79, 90, 86, 18, 168, 112, 176, 240, 27, 29, 182]), (bytes [220, 193, 230, 244, 243, 14, 93, 42, 216, 108, 251, 253, 94, 191, 212, 189, 13, 211, 94, 236, 218, 138, 122, 7, 190, 222, 130, 249, 182, 150, 137, 189]), (bytes [223, 89, 191, 11, 110, 102, 31, 137, 129, 115, 137, 48, 64, 221, 208, 112, 235, 228, 24, 226, 254, 59, 16, 16, 192, 134, 30, 101, 212, 162, 156, 187]), (bytes [156, 22, 213, 157, 3, 147, 139, 132, 146, 22, 57, 209, 56, 31, 20, 20, 229, 105, 89, 38, 226, 230, 110, 49, 208, 70, 178, 10, 75, 21, 225, 62]), (bytes [89, 6, 118, 169, 105, 54, 5, 121, 26, 253, 91, 160, 13, 78, 211, 28, 177, 107, 187, 177, 10, 185, 35, 168, 191, 215, 99, 41, 155, 74, 182, 15]), (bytes [16, 1, 45, 207, 125, 115, 77, 40, 96, 249, 191, 96, 68, 155, 161, 144, 89, 205, 15, 173, 177, 139, 3, 87, 248, 132, 221, 254, 91, 235, 118, 133]), (bytes [2, 197, 213, 149, 21, 90, 236, 108, 141, 146, 26, 38, 0, 78, 135, 95, 223, 228, 221, 179, 125, 245, 167, 198, 49, 196, 48, 128, 192, 39, 124, 49]), (bytes [130, 134, 127, 131, 40, 47, 149, 206, 210, 112, 225, 17, 66, 25, 14, 78, 65, 235, 99, 73, 206, 90, 67, 148, 19, 78, 146, 25, 197, 149, 108, 61]), (bytes [8, 234, 67, 158, 76, 76, 170, 16, 58, 161, 138, 98, 35, 61, 115, 114, 104, 189, 45, 62, 96, 35, 11, 160, 56, 73, 223, 212, 106, 84, 224, 145]), (bytes [0, 189, 116, 3, 67, 124, 251, 249, 47, 128, 49, 73, 210, 47, 86, 252, 162, 78, 171, 9, 96, 183, 112, 195, 81, 120, 202, 223, 242, 24, 76, 51]), (bytes [81, 144, 1, 221, 155, 166, 187, 155, 181, 172, 254, 158, 176, 149, 110, 161, 164, 146, 156, 197, 231, 227, 176, 108, 72, 168, 128, 97, 162, 214, 166, 78]), (bytes [238, 147, 134, 181, 8, 29, 128, 200, 221, 198, 65, 181, 234, 22, 117, 159, 112, 0, 90, 214, 190, 69, 86, 72, 209, 196, 234, 23, 145, 109, 49, 190]), (bytes [150, 94, 21, 115, 92, 3, 250, 46, 250, 39, 23, 156, 66, 177, 198, 103, 242, 34, 109, 175, 253, 18, 181, 44, 23, 6, 9, 9, 119, 235, 11, 108]), (bytes [135, 215, 141, 47, 156, 11, 54, 54, 3, 72, 179, 247, 223, 155, 104, 7, 155, 222, 232, 159, 97, 172, 115, 97, 167, 121, 212, 57, 156, 44, 117, 203]), (bytes [84, 95, 115, 25, 213, 106, 24, 56, 216, 206, 94, 157, 100, 187, 198, 197, 93, 1, 173, 134, 90, 112, 47, 80, 254, 7, 54, 249, 32, 132, 243, 167]), (bytes [130, 198, 251, 47, 44, 43, 143, 92, 82, 195, 92, 157, 42, 215, 42, 26, 5, 251, 108, 34, 34, 0, 80, 113, 213, 113, 25, 247, 190, 124, 74, 52]), (bytes [234, 182, 234, 160, 23, 192, 246, 199, 173, 187, 203, 106, 254, 25, 134, 196, 2, 40, 181, 117, 170, 220, 56, 86, 63, 246, 0, 182, 78, 16, 61, 77]), (bytes [40, 254, 204, 213, 6, 140, 117, 235, 134, 79, 86, 81, 169, 63, 60, 118, 8, 156, 87, 198, 194, 60, 29, 160, 125, 250, 15, 187, 147, 220, 29, 92]), (bytes [18, 187, 180, 226, 104, 66, 42, 243, 22, 156, 53, 240, 151, 142, 203, 83, 91, 143, 153, 183, 211, 14, 178, 15, 249, 35, 88, 211, 226, 167, 221, 238]), (bytes [164, 40, 127, 229, 211, 147, 121, 221, 253, 56, 242, 238, 25, 160, 231, 5, 98, 88, 35, 198, 216, 51, 242, 34, 196, 132, 1, 62, 202, 49, 246, 41]), (bytes [122, 105, 77, 66, 174, 33, 37, 82, 171, 117, 60, 146, 152, 71, 176, 9, 4, 214, 95, 111, 117, 16, 77, 11, 22, 12, 202, 53, 36, 93, 76, 79]), (bytes [190, 26, 99, 184, 175, 199, 251, 124, 134, 183, 220, 35, 196, 195, 152, 135, 36, 169, 87, 198, 14, 22, 245, 143, 20, 239, 221, 18, 139, 77, 165, 236]), (bytes [80, 33, 41, 82, 68, 242, 18, 200, 209, 172, 125, 228, 155, 229, 192, 181, 222, 62, 254, 113, 197, 197, 209, 167, 162, 245, 86, 19, 189, 248, 96, 43]), (bytes [90, 10, 190, 250, 226, 23, 47, 210, 182, 164, 148, 175, 37, 226, 99, 192, 247, 166, 149, 66, 95, 29, 230, 232, 50, 99, 224, 203, 78, 177, 221, 250])], familyDigest := (bytes [25, 242, 215, 184, 254, 20, 90, 185, 232, 189, 207, 235, 115, 136, 182, 48, 249, 188, 59, 126, 24, 245, 6, 203, 160, 163, 22, 116, 111, 63, 199, 193]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [25, 242, 215, 184, 254, 20, 90, 185, 232, 189, 207, 235, 115, 136, 182, 48, 249, 188, 59, 126, 24, 245, 6, 203, 160, 163, 22, 116, 111, 63, 199, 193]), layoutVersion := 1, digest := (bytes [110, 102, 202, 253, 144, 17, 153, 81, 240, 59, 211, 141, 212, 238, 213, 218, 7, 149, 22, 140, 89, 124, 147, 70, 176, 145, 212, 50, 89, 224, 59, 77]) }, logicalIndex := 0, digest := (bytes [143, 96, 174, 197, 151, 152, 68, 42, 161, 160, 41, 84, 98, 128, 102, 57, 51, 162, 58, 94, 208, 62, 160, 239, 22, 200, 217, 244, 140, 235, 31, 3]) }, valueDigest := (bytes [16, 18, 204, 238, 34, 55, 227, 219, 112, 224, 153, 77, 87, 255, 222, 57, 93, 120, 113, 190, 238, 193, 38, 190, 84, 232, 126, 51, 50, 221, 88, 172]), digest := (bytes [113, 111, 113, 72, 209, 21, 197, 38, 79, 2, 169, 207, 184, 209, 224, 240, 202, 126, 144, 79, 56, 134, 102, 207, 25, 208, 184, 3, 29, 252, 81, 188]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [25, 242, 215, 184, 254, 20, 90, 185, 232, 189, 207, 235, 115, 136, 182, 48, 249, 188, 59, 126, 24, 245, 6, 203, 160, 163, 22, 116, 111, 63, 199, 193]), layoutVersion := 1, digest := (bytes [110, 102, 202, 253, 144, 17, 153, 81, 240, 59, 211, 141, 212, 238, 213, 218, 7, 149, 22, 140, 89, 124, 147, 70, 176, 145, 212, 50, 89, 224, 59, 77]) }, logicalIndex := 3, digest := (bytes [46, 219, 119, 80, 92, 182, 252, 143, 220, 118, 171, 93, 244, 115, 34, 173, 16, 25, 125, 107, 132, 88, 40, 5, 86, 131, 110, 153, 108, 82, 226, 151]) }, valueDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [197, 124, 175, 176, 136, 105, 83, 70, 4, 160, 98, 196, 5, 243, 56, 51, 137, 176, 18, 3, 131, 197, 173, 64, 80, 45, 117, 240, 55, 66, 193, 2]) }), digest := (bytes [36, 62, 47, 98, 133, 33, 72, 45, 157, 139, 218, 98, 165, 14, 212, 18, 88, 172, 130, 72, 105, 154, 80, 3, 222, 66, 91, 193, 91, 182, 221, 126]) }
  , rootLaneCommitment := { timeLen := 4, commitments := { commitmentCount := 38, digest := (bytes [224, 35, 130, 146, 73, 187, 180, 161, 207, 126, 172, 132, 75, 27, 45, 130, 95, 188, 79, 180, 97, 222, 14, 171, 162, 112, 240, 232, 195, 86, 247, 255]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [224, 35, 130, 146, 73, 187, 180, 161, 207, 126, 172, 132, 75, 27, 45, 130, 95, 188, 79, 180, 97, 222, 14, 171, 162, 112, 240, 232, 195, 86, 247, 255]), layoutVersion := 3, digest := (bytes [73, 219, 13, 49, 103, 247, 89, 166, 27, 108, 67, 127, 15, 169, 73, 6, 209, 175, 225, 108, 224, 209, 237, 64, 72, 252, 167, 45, 73, 146, 155, 48]) }, logicalIndex := 0, digest := (bytes [23, 192, 58, 164, 26, 55, 218, 251, 99, 242, 254, 15, 136, 176, 28, 136, 128, 246, 130, 180, 140, 153, 188, 49, 52, 63, 8, 210, 49, 107, 105, 71]) }, valueDigest := (bytes [16, 18, 204, 238, 34, 55, 227, 219, 112, 224, 153, 77, 87, 255, 222, 57, 93, 120, 113, 190, 238, 193, 38, 190, 84, 232, 126, 51, 50, 221, 88, 172]), digest := (bytes [82, 152, 47, 125, 240, 238, 38, 102, 66, 145, 113, 22, 238, 165, 163, 111, 107, 0, 135, 54, 70, 71, 176, 39, 95, 98, 9, 66, 244, 202, 154, 32]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [224, 35, 130, 146, 73, 187, 180, 161, 207, 126, 172, 132, 75, 27, 45, 130, 95, 188, 79, 180, 97, 222, 14, 171, 162, 112, 240, 232, 195, 86, 247, 255]), layoutVersion := 3, digest := (bytes [73, 219, 13, 49, 103, 247, 89, 166, 27, 108, 67, 127, 15, 169, 73, 6, 209, 175, 225, 108, 224, 209, 237, 64, 72, 252, 167, 45, 73, 146, 155, 48]) }, logicalIndex := 3, digest := (bytes [90, 134, 137, 77, 249, 107, 189, 181, 52, 146, 43, 116, 82, 82, 78, 93, 175, 11, 187, 228, 162, 43, 196, 92, 67, 20, 241, 239, 245, 202, 241, 97]) }, valueDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [16, 20, 62, 26, 165, 5, 139, 163, 57, 15, 250, 146, 67, 199, 114, 6, 83, 128, 154, 182, 12, 172, 181, 146, 186, 187, 199, 193, 101, 10, 132, 108]) }), digest := (bytes [241, 160, 179, 19, 65, 253, 184, 51, 70, 153, 122, 41, 192, 101, 164, 133, 222, 36, 82, 136, 158, 151, 0, 29, 255, 61, 250, 221, 38, 182, 106, 64]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [36, 62, 47, 98, 133, 33, 72, 45, 157, 139, 218, 98, 165, 14, 212, 18, 88, 172, 130, 72, 105, 154, 80, 3, 222, 66, 91, 193, 91, 182, 221, 126]), rootLaneCommitmentDigest := (bytes [241, 160, 179, 19, 65, 253, 184, 51, 70, 153, 122, 41, 192, 101, 164, 133, 222, 36, 82, 136, 158, 151, 0, 29, 255, 61, 250, 221, 38, 182, 106, 64]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 4, digest := (bytes [10, 37, 78, 104, 98, 178, 246, 10, 37, 94, 101, 207, 244, 124, 152, 243, 75, 112, 143, 5, 82, 12, 30, 107, 120, 24, 79, 135, 75, 57, 249, 235]) }, statementDigest := (bytes [162, 252, 86, 97, 11, 168, 138, 195, 168, 18, 167, 37, 97, 235, 98, 74, 90, 211, 73, 97, 94, 106, 142, 73, 184, 74, 214, 123, 225, 38, 238, 205]), proofDigest := (bytes [75, 22, 135, 51, 89, 193, 5, 134, 98, 110, 209, 10, 221, 111, 178, 57, 128, 45, 117, 209, 105, 219, 88, 244, 15, 191, 58, 0, 173, 135, 73, 229]), digest := (bytes [78, 71, 22, 7, 181, 80, 70, 222, 142, 207, 248, 22, 150, 29, 171, 21, 200, 26, 17, 15, 20, 143, 190, 249, 2, 120, 244, 123, 93, 197, 187, 210]) }
  , digest := (bytes [125, 1, 18, 237, 158, 43, 221, 220, 231, 222, 172, 98, 48, 211, 238, 66, 51, 232, 6, 141, 202, 162, 165, 120, 228, 35, 49, 172, 181, 172, 152, 163])
}
    , exportedProof := {
  claim := {
  accepted := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , statement := { proofStatementDigest := (bytes [29, 154, 119, 194, 253, 168, 51, 30, 89, 28, 25, 46, 45, 222, 3, 4, 196, 181, 108, 98, 250, 90, 68, 28, 229, 47, 25, 71, 73, 15, 125, 11]), kernelOpeningDigest := (bytes [27, 150, 255, 63, 85, 153, 185, 126, 162, 122, 198, 148, 77, 239, 85, 126, 86, 220, 211, 202, 66, 153, 181, 200, 186, 49, 170, 243, 64, 98, 191, 194]), digest := (bytes [49, 209, 135, 92, 103, 155, 147, 96, 186, 15, 7, 25, 35, 116, 116, 144, 236, 246, 61, 248, 100, 205, 190, 95, 40, 83, 34, 184, 134, 246, 203, 84]) }
  , mainLane := { mainLaneBundleDigest := (bytes [78, 71, 22, 7, 181, 80, 70, 222, 142, 207, 248, 22, 150, 29, 171, 21, 200, 26, 17, 15, 20, 143, 190, 249, 2, 120, 244, 123, 93, 197, 187, 210]), digest := (bytes [63, 207, 102, 236, 96, 163, 84, 115, 194, 247, 54, 108, 74, 69, 169, 81, 203, 77, 234, 134, 163, 205, 136, 147, 81, 15, 208, 133, 15, 219, 11, 42]) }
  , terminal := { finalStateDigest := (bytes [207, 244, 140, 140, 253, 220, 153, 85, 210, 72, 78, 149, 45, 76, 101, 175, 63, 107, 102, 240, 184, 237, 98, 242, 203, 60, 16, 255, 244, 31, 162, 249]), finalPc := 20, halted := true, digest := (bytes [182, 238, 214, 77, 173, 219, 153, 231, 19, 217, 139, 61, 75, 99, 95, 78, 125, 238, 44, 56, 13, 12, 58, 3, 51, 189, 13, 78, 238, 192, 97, 92]) }
  , digest := (bytes [16, 34, 255, 18, 116, 166, 184, 251, 133, 14, 150, 239, 136, 33, 23, 134, 41, 0, 65, 75, 188, 128, 89, 4, 242, 84, 49, 149, 90, 133, 96, 228])
}
  , mainLane := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { mainLaneBundleDigest := (bytes [78, 71, 22, 7, 181, 80, 70, 222, 142, 207, 248, 22, 150, 29, 171, 21, 200, 26, 17, 15, 20, 143, 190, 249, 2, 120, 244, 123, 93, 197, 187, 210]), digest := (bytes [30, 233, 2, 235, 251, 171, 26, 25, 25, 160, 139, 130, 201, 162, 113, 92, 102, 188, 44, 224, 77, 87, 89, 170, 202, 65, 104, 181, 111, 22, 81, 93]) }, digest := (bytes [166, 222, 212, 144, 139, 15, 153, 69, 247, 99, 255, 78, 219, 117, 103, 186, 184, 153, 36, 63, 8, 114, 145, 178, 147, 17, 205, 18, 187, 254, 22, 243]) }
  , opening := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , stages := { stageClaimsDigest := (bytes [43, 124, 10, 46, 101, 98, 126, 221, 48, 170, 172, 15, 128, 146, 73, 33, 193, 48, 6, 65, 212, 178, 209, 144, 126, 158, 251, 187, 238, 74, 155, 175]), stagePackagesDigest := (bytes [105, 229, 187, 246, 25, 23, 36, 81, 114, 222, 49, 199, 227, 237, 223, 121, 93, 13, 243, 202, 203, 133, 200, 21, 119, 100, 244, 72, 36, 136, 164, 179]), kernelOpeningDigest := (bytes [27, 150, 255, 63, 85, 153, 185, 126, 162, 122, 198, 148, 77, 239, 85, 126, 86, 220, 211, 202, 66, 153, 181, 200, 186, 49, 170, 243, 64, 98, 191, 194]), digest := (bytes [74, 202, 84, 223, 201, 35, 89, 194, 66, 94, 221, 237, 28, 16, 91, 134, 134, 3, 161, 220, 39, 93, 135, 47, 178, 0, 139, 81, 13, 103, 147, 213]) }
  , terminal := { preparedStepBindingsDigest := (bytes [129, 88, 205, 31, 122, 194, 197, 123, 130, 181, 17, 239, 205, 213, 80, 253, 251, 34, 140, 79, 238, 89, 224, 13, 192, 53, 124, 88, 4, 85, 168, 55]), executionDigest := (bytes [216, 222, 179, 38, 20, 54, 249, 142, 177, 39, 183, 229, 29, 226, 13, 225, 74, 252, 72, 165, 4, 145, 80, 197, 205, 158, 197, 254, 151, 248, 6, 131]), transcriptFinalDigest := (bytes [220, 210, 243, 194, 82, 47, 210, 0, 22, 21, 24, 49, 198, 154, 28, 14, 214, 176, 219, 99, 123, 33, 22, 249, 10, 120, 148, 255, 68, 207, 116, 2]), digest := (bytes [233, 162, 253, 83, 39, 178, 59, 185, 120, 105, 125, 175, 112, 24, 6, 6, 243, 47, 217, 221, 2, 59, 101, 159, 250, 27, 42, 58, 17, 60, 86, 251]) }
  , digest := (bytes [31, 74, 181, 114, 4, 93, 185, 92, 37, 40, 145, 242, 203, 242, 38, 53, 114, 66, 193, 188, 146, 211, 103, 173, 10, 218, 44, 151, 129, 141, 20, 114])
}
  , jointOpening := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { proofStatementDigest := (bytes [29, 154, 119, 194, 253, 168, 51, 30, 89, 28, 25, 46, 45, 222, 3, 4, 196, 181, 108, 98, 250, 90, 68, 28, 229, 47, 25, 71, 73, 15, 125, 11]), mainLaneClaimDigest := (bytes [166, 222, 212, 144, 139, 15, 153, 69, 247, 99, 255, 78, 219, 117, 103, 186, 184, 153, 36, 63, 8, 114, 145, 178, 147, 17, 205, 18, 187, 254, 22, 243]), kernelOpeningClaimDigest := (bytes [31, 74, 181, 114, 4, 93, 185, 92, 37, 40, 145, 242, 203, 242, 38, 53, 114, 66, 193, 188, 146, 211, 103, 173, 10, 218, 44, 151, 129, 141, 20, 114]), digest := (bytes [195, 12, 92, 30, 163, 72, 187, 246, 122, 128, 49, 147, 196, 161, 28, 253, 250, 38, 200, 41, 182, 255, 185, 130, 148, 187, 162, 17, 255, 228, 206, 82]) }, digest := (bytes [251, 206, 61, 248, 246, 240, 218, 228, 48, 52, 110, 212, 48, 56, 74, 62, 187, 116, 4, 32, 125, 57, 138, 99, 153, 176, 228, 187, 197, 101, 87, 65]) }
  , root0 := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), stages := { stage1Digest := (bytes [38, 1, 111, 25, 28, 52, 17, 93, 213, 60, 148, 249, 31, 250, 244, 14, 78, 84, 6, 40, 66, 110, 230, 118, 128, 211, 149, 94, 100, 248, 222, 19]), stage2Digest := (bytes [166, 190, 44, 132, 128, 151, 204, 56, 245, 149, 250, 100, 68, 251, 133, 216, 118, 141, 212, 118, 201, 209, 68, 33, 74, 28, 127, 220, 47, 90, 112, 230]), stage3Digest := (bytes [198, 81, 7, 250, 152, 135, 65, 159, 231, 42, 117, 161, 26, 121, 63, 197, 123, 212, 231, 113, 35, 37, 159, 177, 226, 104, 247, 68, 136, 30, 16, 163]), digest := (bytes [37, 35, 123, 152, 215, 105, 0, 78, 189, 95, 56, 47, 18, 139, 179, 42, 241, 212, 241, 85, 131, 150, 114, 92, 2, 252, 57, 102, 250, 116, 25, 162]) }, terminal := { root0Digest := (bytes [136, 28, 209, 27, 97, 186, 22, 192, 232, 198, 243, 170, 46, 6, 247, 29, 121, 48, 129, 111, 147, 109, 255, 41, 26, 208, 224, 144, 114, 105, 103, 152]), executionDigest := (bytes [216, 222, 179, 38, 20, 54, 249, 142, 177, 39, 183, 229, 29, 226, 13, 225, 74, 252, 72, 165, 4, 145, 80, 197, 205, 158, 197, 254, 151, 248, 6, 131]), finalStateDigest := (bytes [207, 244, 140, 140, 253, 220, 153, 85, 210, 72, 78, 149, 45, 76, 101, 175, 63, 107, 102, 240, 184, 237, 98, 242, 203, 60, 16, 255, 244, 31, 162, 249]), transcriptFinalDigest := (bytes [220, 210, 243, 194, 82, 47, 210, 0, 22, 21, 24, 49, 198, 154, 28, 14, 214, 176, 219, 99, 123, 33, 22, 249, 10, 120, 148, 255, 68, 207, 116, 2]), digest := (bytes [13, 142, 254, 151, 217, 133, 140, 47, 200, 184, 21, 170, 29, 27, 22, 114, 195, 194, 219, 147, 187, 42, 220, 34, 50, 38, 199, 13, 74, 83, 74, 38]) }, digest := (bytes [216, 150, 247, 198, 195, 236, 209, 130, 189, 240, 120, 94, 161, 211, 249, 8, 205, 84, 187, 25, 251, 109, 75, 181, 194, 151, 6, 52, 169, 99, 127, 45]) }
  , digest := (bytes [69, 138, 8, 7, 14, 109, 238, 43, 127, 56, 248, 9, 95, 50, 133, 91, 227, 123, 134, 100, 248, 232, 160, 63, 57, 221, 69, 177, 99, 207, 162, 249])
}
  , statement := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , foldSchedule := Nightstream.FoldSchedule.wholeTrace
  , chunkCount := 1
  , stageClaimsDigest := (bytes [43, 124, 10, 46, 101, 98, 126, 221, 48, 170, 172, 15, 128, 146, 73, 33, 193, 48, 6, 65, 212, 178, 209, 144, 126, 158, 251, 187, 238, 74, 155, 175])
  , stagePackagesDigest := (bytes [105, 229, 187, 246, 25, 23, 36, 81, 114, 222, 49, 199, 227, 237, 223, 121, 93, 13, 243, 202, 203, 133, 200, 21, 119, 100, 244, 72, 36, 136, 164, 179])
  , kernelOpeningDigest := (bytes [27, 150, 255, 63, 85, 153, 185, 126, 162, 122, 198, 148, 77, 239, 85, 126, 86, 220, 211, 202, 66, 153, 181, 200, 186, 49, 170, 243, 64, 98, 191, 194])
  , preparedStepBindingsDigest := (bytes [129, 88, 205, 31, 122, 194, 197, 123, 130, 181, 17, 239, 205, 213, 80, 253, 251, 34, 140, 79, 238, 89, 224, 13, 192, 53, 124, 88, 4, 85, 168, 55])
  , executionDigest := (bytes [216, 222, 179, 38, 20, 54, 249, 142, 177, 39, 183, 229, 29, 226, 13, 225, 74, 252, 72, 165, 4, 145, 80, 197, 205, 158, 197, 254, 151, 248, 6, 131])
  , finalStateDigest := (bytes [207, 244, 140, 140, 253, 220, 153, 85, 210, 72, 78, 149, 45, 76, 101, 175, 63, 107, 102, 240, 184, 237, 98, 242, 203, 60, 16, 255, 244, 31, 162, 249])
  , transcriptFinalDigest := (bytes [220, 210, 243, 194, 82, 47, 210, 0, 22, 21, 24, 49, 198, 154, 28, 14, 214, 176, 219, 99, 123, 33, 22, 249, 10, 120, 148, 255, 68, 207, 116, 2])
  , mainLaneSurfaceDigest := (bytes [178, 204, 3, 17, 196, 179, 105, 22, 174, 10, 22, 229, 42, 119, 13, 79, 230, 112, 234, 169, 35, 1, 236, 217, 200, 77, 208, 78, 215, 13, 170, 245])
  , rootLaneColumnsDigest := (bytes [36, 62, 47, 98, 133, 33, 72, 45, 157, 139, 218, 98, 165, 14, 212, 18, 88, 172, 130, 72, 105, 154, 80, 3, 222, 66, 91, 193, 91, 182, 221, 126])
  , publicStepCount := 4
  , initialPc := 0
  , finalPc := 20
  , halted := true
  , digest := (bytes [29, 154, 119, 194, 253, 168, 51, 30, 89, 28, 25, 46, 45, 222, 3, 4, 196, 181, 108, 98, 250, 90, 68, 28, 229, 47, 25, 71, 73, 15, 125, 11])
}
  , kernel := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "control_flow_bgeu_taken_skip_ecall", fixtureId := "control_flow_bgeu_taken_skip_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.controlFlow, .nativeAlu] }
  , executionDigest := (bytes [216, 222, 179, 38, 20, 54, 249, 142, 177, 39, 183, 229, 29, 226, 13, 225, 74, 252, 72, 165, 4, 145, 80, 197, 205, 158, 197, 254, 151, 248, 6, 131])
  , shape := { executionRowCount := 4, realRowCount := 4, effectRowCount := 4, commitRowCount := 4, digest := (bytes [45, 178, 181, 197, 132, 60, 130, 1, 239, 208, 160, 249, 86, 246, 26, 179, 94, 235, 136, 250, 242, 5, 139, 0, 36, 216, 225, 255, 232, 86, 248, 123]) }
  , digest := (bytes [69, 124, 181, 213, 25, 23, 236, 30, 130, 199, 93, 40, 112, 241, 205, 116, 156, 230, 35, 190, 85, 192, 105, 145, 203, 220, 170, 14, 149, 228, 68, 31])
}
  , stages := { summary := { stage1RowCount := 4, stage2RegisterReadCount := 4, stage2RegisterWriteCount := 2, stage2RamEventCount := 0, stage2TwistLinkCount := 4, stage3ContinuityCount := 4, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [188, 146, 61, 220, 245, 51, 7, 161, 36, 1, 199, 100, 62, 187, 19, 182, 215, 124, 14, 176, 250, 206, 43, 76, 0, 125, 203, 144, 45, 193, 111, 34]) }, digest := (bytes [109, 34, 58, 13, 68, 111, 109, 31, 96, 208, 232, 119, 140, 198, 44, 192, 184, 71, 199, 65, 42, 115, 36, 133, 68, 13, 13, 169, 75, 7, 175, 245]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [224, 201, 173, 115, 16, 169, 230, 244, 82, 92, 10, 191, 220, 189, 26, 104, 94, 147, 3, 207, 153, 214, 192, 54, 230, 130, 54, 146, 88, 45, 255, 104]), stage1Digest := (bytes [112, 185, 47, 45, 40, 43, 97, 13, 83, 242, 126, 182, 239, 45, 100, 232, 22, 39, 165, 84, 184, 60, 93, 6, 138, 137, 33, 187, 49, 2, 241, 238]), stage2Digest := (bytes [211, 63, 102, 118, 255, 81, 200, 216, 247, 19, 168, 121, 232, 100, 242, 248, 84, 67, 76, 4, 169, 132, 38, 99, 183, 122, 249, 250, 156, 156, 152, 27]), stage3Digest := (bytes [241, 139, 61, 96, 28, 236, 184, 76, 31, 31, 90, 170, 231, 105, 75, 206, 127, 224, 133, 83, 235, 74, 203, 217, 94, 188, 29, 205, 255, 17, 30, 140]), transcriptDigest := (bytes [220, 210, 243, 194, 82, 47, 210, 0, 22, 21, 24, 49, 198, 154, 28, 14, 214, 176, 219, 99, 123, 33, 22, 249, 10, 120, 148, 255, 68, 207, 116, 2]), executionDigest := (bytes [216, 222, 179, 38, 20, 54, 249, 142, 177, 39, 183, 229, 29, 226, 13, 225, 74, 252, 72, 165, 4, 145, 80, 197, 205, 158, 197, 254, 151, 248, 6, 131]), digest := (bytes [191, 74, 251, 126, 250, 53, 177, 185, 122, 27, 171, 243, 175, 47, 223, 91, 82, 113, 135, 118, 67, 70, 98, 254, 150, 147, 7, 8, 26, 197, 179, 249]) }, statementDigest := (bytes [232, 117, 81, 34, 97, 83, 248, 229, 62, 28, 252, 216, 90, 26, 243, 173, 71, 41, 220, 91, 202, 238, 85, 106, 212, 166, 97, 6, 206, 170, 168, 10]), proofDigest := (bytes [126, 130, 236, 47, 188, 75, 22, 145, 77, 98, 206, 77, 117, 148, 76, 244, 137, 24, 74, 198, 71, 200, 139, 6, 92, 250, 203, 59, 53, 99, 85, 181]), digest := (bytes [43, 124, 10, 46, 101, 98, 126, 221, 48, 170, 172, 15, 128, 146, 73, 33, 193, 48, 6, 65, 212, 178, 209, 144, 126, 158, 251, 187, 238, 74, 155, 175]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [201, 255, 135, 89, 100, 112, 244, 221, 158, 73, 161, 80, 120, 100, 150, 234, 84, 221, 91, 163, 45, 13, 136, 121, 11, 99, 35, 106, 97, 157, 255, 33]), stage1Digest := (bytes [130, 174, 243, 222, 39, 159, 87, 21, 175, 112, 43, 65, 6, 32, 190, 202, 78, 221, 86, 44, 131, 56, 104, 211, 120, 203, 122, 142, 72, 244, 82, 162]), stage2Digest := (bytes [182, 4, 63, 106, 219, 9, 187, 36, 105, 197, 64, 83, 214, 8, 228, 125, 163, 167, 24, 8, 190, 202, 97, 143, 101, 80, 2, 184, 123, 141, 92, 68]), stage3Digest := (bytes [118, 192, 152, 28, 171, 93, 163, 128, 250, 17, 224, 22, 63, 144, 156, 254, 84, 82, 166, 26, 33, 242, 136, 166, 53, 92, 234, 136, 103, 80, 76, 20]), digest := (bytes [56, 62, 146, 161, 38, 174, 45, 14, 33, 115, 98, 73, 100, 140, 170, 77, 233, 22, 23, 84, 207, 33, 150, 231, 100, 228, 221, 142, 36, 151, 238, 224]) }, digest := (bytes [105, 229, 187, 246, 25, 23, 36, 81, 114, 222, 49, 199, 227, 237, 223, 121, 93, 13, 243, 202, 203, 133, 200, 21, 119, 100, 244, 72, 36, 136, 164, 179]) }
  , kernelOpening := { openingDigest := (bytes [218, 41, 39, 230, 165, 102, 65, 80, 104, 208, 33, 60, 133, 147, 57, 209, 186, 177, 47, 218, 192, 172, 103, 49, 37, 58, 104, 127, 42, 16, 17, 182]), bindings := { claimDigest := (bytes [233, 29, 192, 247, 8, 136, 44, 53, 125, 99, 242, 175, 186, 199, 178, 144, 73, 20, 162, 240, 120, 223, 127, 134, 226, 237, 149, 30, 84, 53, 135, 41]), bindingsDigest := (bytes [191, 4, 51, 6, 94, 48, 172, 219, 100, 92, 162, 144, 159, 143, 193, 39, 155, 211, 15, 146, 90, 254, 129, 35, 195, 70, 64, 90, 228, 155, 120, 48]), preparedStepsDigest := (bytes [175, 67, 54, 44, 255, 117, 192, 118, 14, 93, 142, 131, 123, 234, 138, 135, 168, 227, 78, 140, 10, 110, 73, 40, 187, 240, 199, 211, 168, 154, 90, 250]), digest := (bytes [149, 99, 147, 14, 14, 6, 253, 3, 182, 144, 34, 12, 93, 170, 109, 54, 239, 236, 66, 245, 178, 65, 183, 123, 248, 39, 11, 16, 252, 150, 174, 10]) }, digest := (bytes [27, 150, 255, 63, 85, 153, 185, 126, 162, 122, 198, 148, 77, 239, 85, 126, 86, 220, 211, 202, 66, 153, 181, 200, 186, 49, 170, 243, 64, 98, 191, 194]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [129, 88, 205, 31, 122, 194, 197, 123, 130, 181, 17, 239, 205, 213, 80, 253, 251, 34, 140, 79, 238, 89, 224, 13, 192, 53, 124, 88, 4, 85, 168, 55]), terminal := { root0Digest := (bytes [136, 28, 209, 27, 97, 186, 22, 192, 232, 198, 243, 170, 46, 6, 247, 29, 121, 48, 129, 111, 147, 109, 255, 41, 26, 208, 224, 144, 114, 105, 103, 152]), executionDigest := (bytes [216, 222, 179, 38, 20, 54, 249, 142, 177, 39, 183, 229, 29, 226, 13, 225, 74, 252, 72, 165, 4, 145, 80, 197, 205, 158, 197, 254, 151, 248, 6, 131]), finalStateDigest := (bytes [207, 244, 140, 140, 253, 220, 153, 85, 210, 72, 78, 149, 45, 76, 101, 175, 63, 107, 102, 240, 184, 237, 98, 242, 203, 60, 16, 255, 244, 31, 162, 249]), transcriptFinalDigest := (bytes [220, 210, 243, 194, 82, 47, 210, 0, 22, 21, 24, 49, 198, 154, 28, 14, 214, 176, 219, 99, 123, 33, 22, 249, 10, 120, 148, 255, 68, 207, 116, 2]), finalPc := 20, halted := true, digest := (bytes [230, 130, 151, 154, 26, 73, 48, 177, 171, 156, 247, 36, 229, 237, 235, 178, 76, 218, 151, 34, 120, 37, 159, 77, 124, 7, 88, 139, 201, 244, 46, 138]) }, digest := (bytes [223, 99, 247, 150, 25, 105, 60, 1, 224, 71, 244, 170, 170, 166, 74, 223, 174, 54, 29, 19, 94, 189, 48, 24, 231, 246, 233, 254, 174, 32, 71, 239]) }, statementDigest := (bytes [172, 98, 152, 75, 221, 218, 251, 125, 38, 77, 190, 76, 10, 28, 172, 244, 129, 182, 235, 204, 161, 217, 172, 167, 58, 131, 247, 109, 63, 249, 35, 99]), proofDigest := (bytes [159, 19, 219, 77, 69, 117, 42, 189, 34, 119, 209, 86, 67, 89, 168, 149, 225, 114, 238, 44, 242, 175, 141, 27, 123, 55, 87, 188, 159, 233, 3, 24]), digest := (bytes [222, 161, 136, 86, 37, 77, 100, 58, 71, 45, 220, 126, 181, 63, 132, 123, 166, 71, 26, 209, 3, 155, 11, 102, 50, 172, 160, 187, 90, 140, 144, 191]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [25, 242, 215, 184, 254, 20, 90, 185, 232, 189, 207, 235, 115, 136, 182, 48, 249, 188, 59, 126, 24, 245, 6, 203, 160, 163, 22, 116, 111, 63, 199, 193]), layoutVersion := 1, digest := (bytes [110, 102, 202, 253, 144, 17, 153, 81, 240, 59, 211, 141, 212, 238, 213, 218, 7, 149, 22, 140, 89, 124, 147, 70, 176, 145, 212, 50, 89, 224, 59, 77]) }, rowWidth := 38, timeLen := 4, columnDigests := [(bytes [212, 186, 229, 172, 74, 68, 211, 103, 24, 241, 21, 82, 209, 33, 189, 99, 223, 36, 129, 167, 9, 173, 76, 108, 178, 222, 90, 225, 89, 142, 8, 14]), (bytes [56, 58, 241, 13, 94, 161, 102, 38, 209, 85, 101, 10, 115, 74, 68, 15, 139, 16, 65, 164, 142, 61, 38, 80, 159, 19, 8, 220, 33, 174, 155, 155]), (bytes [29, 30, 250, 119, 67, 192, 190, 83, 169, 199, 126, 126, 209, 9, 207, 51, 13, 31, 240, 215, 38, 77, 233, 53, 71, 218, 94, 76, 41, 218, 33, 58]), (bytes [181, 122, 105, 181, 35, 180, 95, 214, 79, 41, 41, 2, 114, 48, 216, 55, 223, 211, 166, 64, 24, 33, 244, 234, 111, 10, 124, 63, 69, 70, 27, 116]), (bytes [235, 168, 211, 18, 219, 164, 123, 11, 1, 214, 235, 228, 142, 231, 19, 191, 111, 116, 112, 196, 167, 65, 6, 113, 150, 204, 141, 39, 111, 24, 165, 153]), (bytes [121, 130, 244, 43, 235, 154, 135, 182, 125, 251, 219, 139, 88, 218, 127, 71, 219, 212, 14, 47, 150, 5, 16, 183, 37, 152, 140, 186, 198, 73, 221, 183]), (bytes [91, 136, 102, 108, 254, 142, 77, 48, 97, 138, 138, 188, 220, 213, 55, 183, 133, 216, 230, 69, 191, 7, 253, 203, 112, 162, 85, 64, 74, 16, 34, 24]), (bytes [132, 13, 123, 172, 120, 106, 189, 241, 207, 17, 23, 219, 168, 136, 164, 0, 142, 128, 126, 198, 69, 95, 67, 194, 148, 13, 102, 136, 180, 146, 31, 139]), (bytes [13, 51, 13, 112, 10, 98, 204, 18, 53, 169, 156, 155, 63, 147, 114, 64, 241, 138, 154, 179, 238, 77, 114, 193, 171, 122, 197, 145, 246, 175, 206, 33]), (bytes [248, 213, 174, 164, 44, 211, 83, 119, 168, 127, 195, 214, 11, 72, 96, 216, 198, 29, 242, 145, 123, 183, 225, 150, 175, 102, 111, 235, 208, 130, 139, 155]), (bytes [32, 64, 97, 165, 48, 228, 106, 97, 58, 99, 14, 168, 63, 135, 66, 111, 135, 195, 225, 237, 39, 221, 23, 227, 16, 4, 135, 55, 248, 191, 135, 167]), (bytes [228, 208, 212, 3, 158, 123, 159, 22, 200, 85, 94, 53, 133, 251, 112, 144, 104, 119, 103, 120, 106, 126, 134, 102, 254, 183, 119, 5, 230, 104, 137, 4]), (bytes [238, 189, 198, 6, 199, 30, 93, 193, 29, 126, 221, 61, 73, 119, 129, 87, 55, 227, 133, 106, 170, 178, 160, 203, 102, 209, 230, 172, 220, 2, 72, 166]), (bytes [128, 172, 240, 189, 197, 88, 138, 41, 109, 81, 42, 68, 25, 21, 173, 79, 110, 210, 130, 146, 48, 191, 99, 218, 113, 149, 146, 144, 184, 14, 150, 106]), (bytes [74, 226, 37, 10, 152, 135, 71, 32, 121, 204, 236, 95, 238, 168, 237, 37, 113, 198, 64, 103, 189, 79, 90, 86, 18, 168, 112, 176, 240, 27, 29, 182]), (bytes [220, 193, 230, 244, 243, 14, 93, 42, 216, 108, 251, 253, 94, 191, 212, 189, 13, 211, 94, 236, 218, 138, 122, 7, 190, 222, 130, 249, 182, 150, 137, 189]), (bytes [223, 89, 191, 11, 110, 102, 31, 137, 129, 115, 137, 48, 64, 221, 208, 112, 235, 228, 24, 226, 254, 59, 16, 16, 192, 134, 30, 101, 212, 162, 156, 187]), (bytes [156, 22, 213, 157, 3, 147, 139, 132, 146, 22, 57, 209, 56, 31, 20, 20, 229, 105, 89, 38, 226, 230, 110, 49, 208, 70, 178, 10, 75, 21, 225, 62]), (bytes [89, 6, 118, 169, 105, 54, 5, 121, 26, 253, 91, 160, 13, 78, 211, 28, 177, 107, 187, 177, 10, 185, 35, 168, 191, 215, 99, 41, 155, 74, 182, 15]), (bytes [16, 1, 45, 207, 125, 115, 77, 40, 96, 249, 191, 96, 68, 155, 161, 144, 89, 205, 15, 173, 177, 139, 3, 87, 248, 132, 221, 254, 91, 235, 118, 133]), (bytes [2, 197, 213, 149, 21, 90, 236, 108, 141, 146, 26, 38, 0, 78, 135, 95, 223, 228, 221, 179, 125, 245, 167, 198, 49, 196, 48, 128, 192, 39, 124, 49]), (bytes [130, 134, 127, 131, 40, 47, 149, 206, 210, 112, 225, 17, 66, 25, 14, 78, 65, 235, 99, 73, 206, 90, 67, 148, 19, 78, 146, 25, 197, 149, 108, 61]), (bytes [8, 234, 67, 158, 76, 76, 170, 16, 58, 161, 138, 98, 35, 61, 115, 114, 104, 189, 45, 62, 96, 35, 11, 160, 56, 73, 223, 212, 106, 84, 224, 145]), (bytes [0, 189, 116, 3, 67, 124, 251, 249, 47, 128, 49, 73, 210, 47, 86, 252, 162, 78, 171, 9, 96, 183, 112, 195, 81, 120, 202, 223, 242, 24, 76, 51]), (bytes [81, 144, 1, 221, 155, 166, 187, 155, 181, 172, 254, 158, 176, 149, 110, 161, 164, 146, 156, 197, 231, 227, 176, 108, 72, 168, 128, 97, 162, 214, 166, 78]), (bytes [238, 147, 134, 181, 8, 29, 128, 200, 221, 198, 65, 181, 234, 22, 117, 159, 112, 0, 90, 214, 190, 69, 86, 72, 209, 196, 234, 23, 145, 109, 49, 190]), (bytes [150, 94, 21, 115, 92, 3, 250, 46, 250, 39, 23, 156, 66, 177, 198, 103, 242, 34, 109, 175, 253, 18, 181, 44, 23, 6, 9, 9, 119, 235, 11, 108]), (bytes [135, 215, 141, 47, 156, 11, 54, 54, 3, 72, 179, 247, 223, 155, 104, 7, 155, 222, 232, 159, 97, 172, 115, 97, 167, 121, 212, 57, 156, 44, 117, 203]), (bytes [84, 95, 115, 25, 213, 106, 24, 56, 216, 206, 94, 157, 100, 187, 198, 197, 93, 1, 173, 134, 90, 112, 47, 80, 254, 7, 54, 249, 32, 132, 243, 167]), (bytes [130, 198, 251, 47, 44, 43, 143, 92, 82, 195, 92, 157, 42, 215, 42, 26, 5, 251, 108, 34, 34, 0, 80, 113, 213, 113, 25, 247, 190, 124, 74, 52]), (bytes [234, 182, 234, 160, 23, 192, 246, 199, 173, 187, 203, 106, 254, 25, 134, 196, 2, 40, 181, 117, 170, 220, 56, 86, 63, 246, 0, 182, 78, 16, 61, 77]), (bytes [40, 254, 204, 213, 6, 140, 117, 235, 134, 79, 86, 81, 169, 63, 60, 118, 8, 156, 87, 198, 194, 60, 29, 160, 125, 250, 15, 187, 147, 220, 29, 92]), (bytes [18, 187, 180, 226, 104, 66, 42, 243, 22, 156, 53, 240, 151, 142, 203, 83, 91, 143, 153, 183, 211, 14, 178, 15, 249, 35, 88, 211, 226, 167, 221, 238]), (bytes [164, 40, 127, 229, 211, 147, 121, 221, 253, 56, 242, 238, 25, 160, 231, 5, 98, 88, 35, 198, 216, 51, 242, 34, 196, 132, 1, 62, 202, 49, 246, 41]), (bytes [122, 105, 77, 66, 174, 33, 37, 82, 171, 117, 60, 146, 152, 71, 176, 9, 4, 214, 95, 111, 117, 16, 77, 11, 22, 12, 202, 53, 36, 93, 76, 79]), (bytes [190, 26, 99, 184, 175, 199, 251, 124, 134, 183, 220, 35, 196, 195, 152, 135, 36, 169, 87, 198, 14, 22, 245, 143, 20, 239, 221, 18, 139, 77, 165, 236]), (bytes [80, 33, 41, 82, 68, 242, 18, 200, 209, 172, 125, 228, 155, 229, 192, 181, 222, 62, 254, 113, 197, 197, 209, 167, 162, 245, 86, 19, 189, 248, 96, 43]), (bytes [90, 10, 190, 250, 226, 23, 47, 210, 182, 164, 148, 175, 37, 226, 99, 192, 247, 166, 149, 66, 95, 29, 230, 232, 50, 99, 224, 203, 78, 177, 221, 250])], familyDigest := (bytes [25, 242, 215, 184, 254, 20, 90, 185, 232, 189, 207, 235, 115, 136, 182, 48, 249, 188, 59, 126, 24, 245, 6, 203, 160, 163, 22, 116, 111, 63, 199, 193]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [25, 242, 215, 184, 254, 20, 90, 185, 232, 189, 207, 235, 115, 136, 182, 48, 249, 188, 59, 126, 24, 245, 6, 203, 160, 163, 22, 116, 111, 63, 199, 193]), layoutVersion := 1, digest := (bytes [110, 102, 202, 253, 144, 17, 153, 81, 240, 59, 211, 141, 212, 238, 213, 218, 7, 149, 22, 140, 89, 124, 147, 70, 176, 145, 212, 50, 89, 224, 59, 77]) }, logicalIndex := 0, digest := (bytes [143, 96, 174, 197, 151, 152, 68, 42, 161, 160, 41, 84, 98, 128, 102, 57, 51, 162, 58, 94, 208, 62, 160, 239, 22, 200, 217, 244, 140, 235, 31, 3]) }, valueDigest := (bytes [16, 18, 204, 238, 34, 55, 227, 219, 112, 224, 153, 77, 87, 255, 222, 57, 93, 120, 113, 190, 238, 193, 38, 190, 84, 232, 126, 51, 50, 221, 88, 172]), digest := (bytes [113, 111, 113, 72, 209, 21, 197, 38, 79, 2, 169, 207, 184, 209, 224, 240, 202, 126, 144, 79, 56, 134, 102, 207, 25, 208, 184, 3, 29, 252, 81, 188]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [25, 242, 215, 184, 254, 20, 90, 185, 232, 189, 207, 235, 115, 136, 182, 48, 249, 188, 59, 126, 24, 245, 6, 203, 160, 163, 22, 116, 111, 63, 199, 193]), layoutVersion := 1, digest := (bytes [110, 102, 202, 253, 144, 17, 153, 81, 240, 59, 211, 141, 212, 238, 213, 218, 7, 149, 22, 140, 89, 124, 147, 70, 176, 145, 212, 50, 89, 224, 59, 77]) }, logicalIndex := 3, digest := (bytes [46, 219, 119, 80, 92, 182, 252, 143, 220, 118, 171, 93, 244, 115, 34, 173, 16, 25, 125, 107, 132, 88, 40, 5, 86, 131, 110, 153, 108, 82, 226, 151]) }, valueDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [197, 124, 175, 176, 136, 105, 83, 70, 4, 160, 98, 196, 5, 243, 56, 51, 137, 176, 18, 3, 131, 197, 173, 64, 80, 45, 117, 240, 55, 66, 193, 2]) }), digest := (bytes [36, 62, 47, 98, 133, 33, 72, 45, 157, 139, 218, 98, 165, 14, 212, 18, 88, 172, 130, 72, 105, 154, 80, 3, 222, 66, 91, 193, 91, 182, 221, 126]) }
  , rootLaneCommitment := { timeLen := 4, commitments := { commitmentCount := 38, digest := (bytes [224, 35, 130, 146, 73, 187, 180, 161, 207, 126, 172, 132, 75, 27, 45, 130, 95, 188, 79, 180, 97, 222, 14, 171, 162, 112, 240, 232, 195, 86, 247, 255]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [224, 35, 130, 146, 73, 187, 180, 161, 207, 126, 172, 132, 75, 27, 45, 130, 95, 188, 79, 180, 97, 222, 14, 171, 162, 112, 240, 232, 195, 86, 247, 255]), layoutVersion := 3, digest := (bytes [73, 219, 13, 49, 103, 247, 89, 166, 27, 108, 67, 127, 15, 169, 73, 6, 209, 175, 225, 108, 224, 209, 237, 64, 72, 252, 167, 45, 73, 146, 155, 48]) }, logicalIndex := 0, digest := (bytes [23, 192, 58, 164, 26, 55, 218, 251, 99, 242, 254, 15, 136, 176, 28, 136, 128, 246, 130, 180, 140, 153, 188, 49, 52, 63, 8, 210, 49, 107, 105, 71]) }, valueDigest := (bytes [16, 18, 204, 238, 34, 55, 227, 219, 112, 224, 153, 77, 87, 255, 222, 57, 93, 120, 113, 190, 238, 193, 38, 190, 84, 232, 126, 51, 50, 221, 88, 172]), digest := (bytes [82, 152, 47, 125, 240, 238, 38, 102, 66, 145, 113, 22, 238, 165, 163, 111, 107, 0, 135, 54, 70, 71, 176, 39, 95, 98, 9, 66, 244, 202, 154, 32]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [224, 35, 130, 146, 73, 187, 180, 161, 207, 126, 172, 132, 75, 27, 45, 130, 95, 188, 79, 180, 97, 222, 14, 171, 162, 112, 240, 232, 195, 86, 247, 255]), layoutVersion := 3, digest := (bytes [73, 219, 13, 49, 103, 247, 89, 166, 27, 108, 67, 127, 15, 169, 73, 6, 209, 175, 225, 108, 224, 209, 237, 64, 72, 252, 167, 45, 73, 146, 155, 48]) }, logicalIndex := 3, digest := (bytes [90, 134, 137, 77, 249, 107, 189, 181, 52, 146, 43, 116, 82, 82, 78, 93, 175, 11, 187, 228, 162, 43, 196, 92, 67, 20, 241, 239, 245, 202, 241, 97]) }, valueDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [16, 20, 62, 26, 165, 5, 139, 163, 57, 15, 250, 146, 67, 199, 114, 6, 83, 128, 154, 182, 12, 172, 181, 146, 186, 187, 199, 193, 101, 10, 132, 108]) }), digest := (bytes [241, 160, 179, 19, 65, 253, 184, 51, 70, 153, 122, 41, 192, 101, 164, 133, 222, 36, 82, 136, 158, 151, 0, 29, 255, 61, 250, 221, 38, 182, 106, 64]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [36, 62, 47, 98, 133, 33, 72, 45, 157, 139, 218, 98, 165, 14, 212, 18, 88, 172, 130, 72, 105, 154, 80, 3, 222, 66, 91, 193, 91, 182, 221, 126]), rootLaneCommitmentDigest := (bytes [241, 160, 179, 19, 65, 253, 184, 51, 70, 153, 122, 41, 192, 101, 164, 133, 222, 36, 82, 136, 158, 151, 0, 29, 255, 61, 250, 221, 38, 182, 106, 64]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 4, digest := (bytes [10, 37, 78, 104, 98, 178, 246, 10, 37, 94, 101, 207, 244, 124, 152, 243, 75, 112, 143, 5, 82, 12, 30, 107, 120, 24, 79, 135, 75, 57, 249, 235]) }, statementDigest := (bytes [162, 252, 86, 97, 11, 168, 138, 195, 168, 18, 167, 37, 97, 235, 98, 74, 90, 211, 73, 97, 94, 106, 142, 73, 184, 74, 214, 123, 225, 38, 238, 205]), proofDigest := (bytes [75, 22, 135, 51, 89, 193, 5, 134, 98, 110, 209, 10, 221, 111, 178, 57, 128, 45, 117, 209, 105, 219, 88, 244, 15, 191, 58, 0, 173, 135, 73, 229]), digest := (bytes [78, 71, 22, 7, 181, 80, 70, 222, 142, 207, 248, 22, 150, 29, 171, 21, 200, 26, 17, 15, 20, 143, 190, 249, 2, 120, 244, 123, 93, 197, 187, 210]) }
  , digest := (bytes [125, 1, 18, 237, 158, 43, 221, 220, 231, 222, 172, 98, 48, 211, 238, 66, 51, 232, 6, 141, 202, 162, 165, 120, 228, 35, 49, 172, 181, 172, 152, 163])
}
}
    , exportedStatement := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , foldSchedule := Nightstream.FoldSchedule.wholeTrace
  , chunkCount := 1
  , stageClaimsDigest := (bytes [43, 124, 10, 46, 101, 98, 126, 221, 48, 170, 172, 15, 128, 146, 73, 33, 193, 48, 6, 65, 212, 178, 209, 144, 126, 158, 251, 187, 238, 74, 155, 175])
  , stagePackagesDigest := (bytes [105, 229, 187, 246, 25, 23, 36, 81, 114, 222, 49, 199, 227, 237, 223, 121, 93, 13, 243, 202, 203, 133, 200, 21, 119, 100, 244, 72, 36, 136, 164, 179])
  , kernelOpeningDigest := (bytes [27, 150, 255, 63, 85, 153, 185, 126, 162, 122, 198, 148, 77, 239, 85, 126, 86, 220, 211, 202, 66, 153, 181, 200, 186, 49, 170, 243, 64, 98, 191, 194])
  , preparedStepBindingsDigest := (bytes [129, 88, 205, 31, 122, 194, 197, 123, 130, 181, 17, 239, 205, 213, 80, 253, 251, 34, 140, 79, 238, 89, 224, 13, 192, 53, 124, 88, 4, 85, 168, 55])
  , executionDigest := (bytes [216, 222, 179, 38, 20, 54, 249, 142, 177, 39, 183, 229, 29, 226, 13, 225, 74, 252, 72, 165, 4, 145, 80, 197, 205, 158, 197, 254, 151, 248, 6, 131])
  , finalStateDigest := (bytes [207, 244, 140, 140, 253, 220, 153, 85, 210, 72, 78, 149, 45, 76, 101, 175, 63, 107, 102, 240, 184, 237, 98, 242, 203, 60, 16, 255, 244, 31, 162, 249])
  , transcriptFinalDigest := (bytes [220, 210, 243, 194, 82, 47, 210, 0, 22, 21, 24, 49, 198, 154, 28, 14, 214, 176, 219, 99, 123, 33, 22, 249, 10, 120, 148, 255, 68, 207, 116, 2])
  , mainLaneSurfaceDigest := (bytes [178, 204, 3, 17, 196, 179, 105, 22, 174, 10, 22, 229, 42, 119, 13, 79, 230, 112, 234, 169, 35, 1, 236, 217, 200, 77, 208, 78, 215, 13, 170, 245])
  , rootLaneColumnsDigest := (bytes [36, 62, 47, 98, 133, 33, 72, 45, 157, 139, 218, 98, 165, 14, 212, 18, 88, 172, 130, 72, 105, 154, 80, 3, 222, 66, 91, 193, 91, 182, 221, 126])
  , publicStepCount := 4
  , initialPc := 0
  , finalPc := 20
  , halted := true
  , digest := (bytes [29, 154, 119, 194, 253, 168, 51, 30, 89, 28, 25, 46, 45, 222, 3, 4, 196, 181, 108, 98, 250, 90, 68, 28, 229, 47, 25, 71, 73, 15, 125, 11])
}
    , exportedClaims := {
  accepted := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , statement := { proofStatementDigest := (bytes [29, 154, 119, 194, 253, 168, 51, 30, 89, 28, 25, 46, 45, 222, 3, 4, 196, 181, 108, 98, 250, 90, 68, 28, 229, 47, 25, 71, 73, 15, 125, 11]), kernelOpeningDigest := (bytes [27, 150, 255, 63, 85, 153, 185, 126, 162, 122, 198, 148, 77, 239, 85, 126, 86, 220, 211, 202, 66, 153, 181, 200, 186, 49, 170, 243, 64, 98, 191, 194]), digest := (bytes [49, 209, 135, 92, 103, 155, 147, 96, 186, 15, 7, 25, 35, 116, 116, 144, 236, 246, 61, 248, 100, 205, 190, 95, 40, 83, 34, 184, 134, 246, 203, 84]) }
  , mainLane := { mainLaneBundleDigest := (bytes [78, 71, 22, 7, 181, 80, 70, 222, 142, 207, 248, 22, 150, 29, 171, 21, 200, 26, 17, 15, 20, 143, 190, 249, 2, 120, 244, 123, 93, 197, 187, 210]), digest := (bytes [63, 207, 102, 236, 96, 163, 84, 115, 194, 247, 54, 108, 74, 69, 169, 81, 203, 77, 234, 134, 163, 205, 136, 147, 81, 15, 208, 133, 15, 219, 11, 42]) }
  , terminal := { finalStateDigest := (bytes [207, 244, 140, 140, 253, 220, 153, 85, 210, 72, 78, 149, 45, 76, 101, 175, 63, 107, 102, 240, 184, 237, 98, 242, 203, 60, 16, 255, 244, 31, 162, 249]), finalPc := 20, halted := true, digest := (bytes [182, 238, 214, 77, 173, 219, 153, 231, 19, 217, 139, 61, 75, 99, 95, 78, 125, 238, 44, 56, 13, 12, 58, 3, 51, 189, 13, 78, 238, 192, 97, 92]) }
  , digest := (bytes [16, 34, 255, 18, 116, 166, 184, 251, 133, 14, 150, 239, 136, 33, 23, 134, 41, 0, 65, 75, 188, 128, 89, 4, 242, 84, 49, 149, 90, 133, 96, 228])
}
  , mainLane := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { mainLaneBundleDigest := (bytes [78, 71, 22, 7, 181, 80, 70, 222, 142, 207, 248, 22, 150, 29, 171, 21, 200, 26, 17, 15, 20, 143, 190, 249, 2, 120, 244, 123, 93, 197, 187, 210]), digest := (bytes [30, 233, 2, 235, 251, 171, 26, 25, 25, 160, 139, 130, 201, 162, 113, 92, 102, 188, 44, 224, 77, 87, 89, 170, 202, 65, 104, 181, 111, 22, 81, 93]) }, digest := (bytes [166, 222, 212, 144, 139, 15, 153, 69, 247, 99, 255, 78, 219, 117, 103, 186, 184, 153, 36, 63, 8, 114, 145, 178, 147, 17, 205, 18, 187, 254, 22, 243]) }
  , opening := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , stages := { stageClaimsDigest := (bytes [43, 124, 10, 46, 101, 98, 126, 221, 48, 170, 172, 15, 128, 146, 73, 33, 193, 48, 6, 65, 212, 178, 209, 144, 126, 158, 251, 187, 238, 74, 155, 175]), stagePackagesDigest := (bytes [105, 229, 187, 246, 25, 23, 36, 81, 114, 222, 49, 199, 227, 237, 223, 121, 93, 13, 243, 202, 203, 133, 200, 21, 119, 100, 244, 72, 36, 136, 164, 179]), kernelOpeningDigest := (bytes [27, 150, 255, 63, 85, 153, 185, 126, 162, 122, 198, 148, 77, 239, 85, 126, 86, 220, 211, 202, 66, 153, 181, 200, 186, 49, 170, 243, 64, 98, 191, 194]), digest := (bytes [74, 202, 84, 223, 201, 35, 89, 194, 66, 94, 221, 237, 28, 16, 91, 134, 134, 3, 161, 220, 39, 93, 135, 47, 178, 0, 139, 81, 13, 103, 147, 213]) }
  , terminal := { preparedStepBindingsDigest := (bytes [129, 88, 205, 31, 122, 194, 197, 123, 130, 181, 17, 239, 205, 213, 80, 253, 251, 34, 140, 79, 238, 89, 224, 13, 192, 53, 124, 88, 4, 85, 168, 55]), executionDigest := (bytes [216, 222, 179, 38, 20, 54, 249, 142, 177, 39, 183, 229, 29, 226, 13, 225, 74, 252, 72, 165, 4, 145, 80, 197, 205, 158, 197, 254, 151, 248, 6, 131]), transcriptFinalDigest := (bytes [220, 210, 243, 194, 82, 47, 210, 0, 22, 21, 24, 49, 198, 154, 28, 14, 214, 176, 219, 99, 123, 33, 22, 249, 10, 120, 148, 255, 68, 207, 116, 2]), digest := (bytes [233, 162, 253, 83, 39, 178, 59, 185, 120, 105, 125, 175, 112, 24, 6, 6, 243, 47, 217, 221, 2, 59, 101, 159, 250, 27, 42, 58, 17, 60, 86, 251]) }
  , digest := (bytes [31, 74, 181, 114, 4, 93, 185, 92, 37, 40, 145, 242, 203, 242, 38, 53, 114, 66, 193, 188, 146, 211, 103, 173, 10, 218, 44, 151, 129, 141, 20, 114])
}
  , jointOpening := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { proofStatementDigest := (bytes [29, 154, 119, 194, 253, 168, 51, 30, 89, 28, 25, 46, 45, 222, 3, 4, 196, 181, 108, 98, 250, 90, 68, 28, 229, 47, 25, 71, 73, 15, 125, 11]), mainLaneClaimDigest := (bytes [166, 222, 212, 144, 139, 15, 153, 69, 247, 99, 255, 78, 219, 117, 103, 186, 184, 153, 36, 63, 8, 114, 145, 178, 147, 17, 205, 18, 187, 254, 22, 243]), kernelOpeningClaimDigest := (bytes [31, 74, 181, 114, 4, 93, 185, 92, 37, 40, 145, 242, 203, 242, 38, 53, 114, 66, 193, 188, 146, 211, 103, 173, 10, 218, 44, 151, 129, 141, 20, 114]), digest := (bytes [195, 12, 92, 30, 163, 72, 187, 246, 122, 128, 49, 147, 196, 161, 28, 253, 250, 38, 200, 41, 182, 255, 185, 130, 148, 187, 162, 17, 255, 228, 206, 82]) }, digest := (bytes [251, 206, 61, 248, 246, 240, 218, 228, 48, 52, 110, 212, 48, 56, 74, 62, 187, 116, 4, 32, 125, 57, 138, 99, 153, 176, 228, 187, 197, 101, 87, 65]) }
  , root0 := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), stages := { stage1Digest := (bytes [38, 1, 111, 25, 28, 52, 17, 93, 213, 60, 148, 249, 31, 250, 244, 14, 78, 84, 6, 40, 66, 110, 230, 118, 128, 211, 149, 94, 100, 248, 222, 19]), stage2Digest := (bytes [166, 190, 44, 132, 128, 151, 204, 56, 245, 149, 250, 100, 68, 251, 133, 216, 118, 141, 212, 118, 201, 209, 68, 33, 74, 28, 127, 220, 47, 90, 112, 230]), stage3Digest := (bytes [198, 81, 7, 250, 152, 135, 65, 159, 231, 42, 117, 161, 26, 121, 63, 197, 123, 212, 231, 113, 35, 37, 159, 177, 226, 104, 247, 68, 136, 30, 16, 163]), digest := (bytes [37, 35, 123, 152, 215, 105, 0, 78, 189, 95, 56, 47, 18, 139, 179, 42, 241, 212, 241, 85, 131, 150, 114, 92, 2, 252, 57, 102, 250, 116, 25, 162]) }, terminal := { root0Digest := (bytes [136, 28, 209, 27, 97, 186, 22, 192, 232, 198, 243, 170, 46, 6, 247, 29, 121, 48, 129, 111, 147, 109, 255, 41, 26, 208, 224, 144, 114, 105, 103, 152]), executionDigest := (bytes [216, 222, 179, 38, 20, 54, 249, 142, 177, 39, 183, 229, 29, 226, 13, 225, 74, 252, 72, 165, 4, 145, 80, 197, 205, 158, 197, 254, 151, 248, 6, 131]), finalStateDigest := (bytes [207, 244, 140, 140, 253, 220, 153, 85, 210, 72, 78, 149, 45, 76, 101, 175, 63, 107, 102, 240, 184, 237, 98, 242, 203, 60, 16, 255, 244, 31, 162, 249]), transcriptFinalDigest := (bytes [220, 210, 243, 194, 82, 47, 210, 0, 22, 21, 24, 49, 198, 154, 28, 14, 214, 176, 219, 99, 123, 33, 22, 249, 10, 120, 148, 255, 68, 207, 116, 2]), digest := (bytes [13, 142, 254, 151, 217, 133, 140, 47, 200, 184, 21, 170, 29, 27, 22, 114, 195, 194, 219, 147, 187, 42, 220, 34, 50, 38, 199, 13, 74, 83, 74, 38]) }, digest := (bytes [216, 150, 247, 198, 195, 236, 209, 130, 189, 240, 120, 94, 161, 211, 249, 8, 205, 84, 187, 25, 251, 109, 75, 181, 194, 151, 6, 52, 169, 99, 127, 45]) }
  , digest := (bytes [69, 138, 8, 7, 14, 109, 238, 43, 127, 56, 248, 9, 95, 50, 133, 91, 227, 123, 134, 100, 248, 232, 160, 63, 57, 221, 69, 177, 99, 207, 162, 249])
}
    , exportedKernelProof := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "control_flow_bgeu_taken_skip_ecall", fixtureId := "control_flow_bgeu_taken_skip_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.controlFlow, .nativeAlu] }
  , executionDigest := (bytes [216, 222, 179, 38, 20, 54, 249, 142, 177, 39, 183, 229, 29, 226, 13, 225, 74, 252, 72, 165, 4, 145, 80, 197, 205, 158, 197, 254, 151, 248, 6, 131])
  , shape := { executionRowCount := 4, realRowCount := 4, effectRowCount := 4, commitRowCount := 4, digest := (bytes [45, 178, 181, 197, 132, 60, 130, 1, 239, 208, 160, 249, 86, 246, 26, 179, 94, 235, 136, 250, 242, 5, 139, 0, 36, 216, 225, 255, 232, 86, 248, 123]) }
  , digest := (bytes [69, 124, 181, 213, 25, 23, 236, 30, 130, 199, 93, 40, 112, 241, 205, 116, 156, 230, 35, 190, 85, 192, 105, 145, 203, 220, 170, 14, 149, 228, 68, 31])
}
  , stages := { summary := { stage1RowCount := 4, stage2RegisterReadCount := 4, stage2RegisterWriteCount := 2, stage2RamEventCount := 0, stage2TwistLinkCount := 4, stage3ContinuityCount := 4, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [188, 146, 61, 220, 245, 51, 7, 161, 36, 1, 199, 100, 62, 187, 19, 182, 215, 124, 14, 176, 250, 206, 43, 76, 0, 125, 203, 144, 45, 193, 111, 34]) }, digest := (bytes [109, 34, 58, 13, 68, 111, 109, 31, 96, 208, 232, 119, 140, 198, 44, 192, 184, 71, 199, 65, 42, 115, 36, 133, 68, 13, 13, 169, 75, 7, 175, 245]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [224, 201, 173, 115, 16, 169, 230, 244, 82, 92, 10, 191, 220, 189, 26, 104, 94, 147, 3, 207, 153, 214, 192, 54, 230, 130, 54, 146, 88, 45, 255, 104]), stage1Digest := (bytes [112, 185, 47, 45, 40, 43, 97, 13, 83, 242, 126, 182, 239, 45, 100, 232, 22, 39, 165, 84, 184, 60, 93, 6, 138, 137, 33, 187, 49, 2, 241, 238]), stage2Digest := (bytes [211, 63, 102, 118, 255, 81, 200, 216, 247, 19, 168, 121, 232, 100, 242, 248, 84, 67, 76, 4, 169, 132, 38, 99, 183, 122, 249, 250, 156, 156, 152, 27]), stage3Digest := (bytes [241, 139, 61, 96, 28, 236, 184, 76, 31, 31, 90, 170, 231, 105, 75, 206, 127, 224, 133, 83, 235, 74, 203, 217, 94, 188, 29, 205, 255, 17, 30, 140]), transcriptDigest := (bytes [220, 210, 243, 194, 82, 47, 210, 0, 22, 21, 24, 49, 198, 154, 28, 14, 214, 176, 219, 99, 123, 33, 22, 249, 10, 120, 148, 255, 68, 207, 116, 2]), executionDigest := (bytes [216, 222, 179, 38, 20, 54, 249, 142, 177, 39, 183, 229, 29, 226, 13, 225, 74, 252, 72, 165, 4, 145, 80, 197, 205, 158, 197, 254, 151, 248, 6, 131]), digest := (bytes [191, 74, 251, 126, 250, 53, 177, 185, 122, 27, 171, 243, 175, 47, 223, 91, 82, 113, 135, 118, 67, 70, 98, 254, 150, 147, 7, 8, 26, 197, 179, 249]) }, statementDigest := (bytes [232, 117, 81, 34, 97, 83, 248, 229, 62, 28, 252, 216, 90, 26, 243, 173, 71, 41, 220, 91, 202, 238, 85, 106, 212, 166, 97, 6, 206, 170, 168, 10]), proofDigest := (bytes [126, 130, 236, 47, 188, 75, 22, 145, 77, 98, 206, 77, 117, 148, 76, 244, 137, 24, 74, 198, 71, 200, 139, 6, 92, 250, 203, 59, 53, 99, 85, 181]), digest := (bytes [43, 124, 10, 46, 101, 98, 126, 221, 48, 170, 172, 15, 128, 146, 73, 33, 193, 48, 6, 65, 212, 178, 209, 144, 126, 158, 251, 187, 238, 74, 155, 175]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [201, 255, 135, 89, 100, 112, 244, 221, 158, 73, 161, 80, 120, 100, 150, 234, 84, 221, 91, 163, 45, 13, 136, 121, 11, 99, 35, 106, 97, 157, 255, 33]), stage1Digest := (bytes [130, 174, 243, 222, 39, 159, 87, 21, 175, 112, 43, 65, 6, 32, 190, 202, 78, 221, 86, 44, 131, 56, 104, 211, 120, 203, 122, 142, 72, 244, 82, 162]), stage2Digest := (bytes [182, 4, 63, 106, 219, 9, 187, 36, 105, 197, 64, 83, 214, 8, 228, 125, 163, 167, 24, 8, 190, 202, 97, 143, 101, 80, 2, 184, 123, 141, 92, 68]), stage3Digest := (bytes [118, 192, 152, 28, 171, 93, 163, 128, 250, 17, 224, 22, 63, 144, 156, 254, 84, 82, 166, 26, 33, 242, 136, 166, 53, 92, 234, 136, 103, 80, 76, 20]), digest := (bytes [56, 62, 146, 161, 38, 174, 45, 14, 33, 115, 98, 73, 100, 140, 170, 77, 233, 22, 23, 84, 207, 33, 150, 231, 100, 228, 221, 142, 36, 151, 238, 224]) }, digest := (bytes [105, 229, 187, 246, 25, 23, 36, 81, 114, 222, 49, 199, 227, 237, 223, 121, 93, 13, 243, 202, 203, 133, 200, 21, 119, 100, 244, 72, 36, 136, 164, 179]) }
  , kernelOpening := { openingDigest := (bytes [218, 41, 39, 230, 165, 102, 65, 80, 104, 208, 33, 60, 133, 147, 57, 209, 186, 177, 47, 218, 192, 172, 103, 49, 37, 58, 104, 127, 42, 16, 17, 182]), bindings := { claimDigest := (bytes [233, 29, 192, 247, 8, 136, 44, 53, 125, 99, 242, 175, 186, 199, 178, 144, 73, 20, 162, 240, 120, 223, 127, 134, 226, 237, 149, 30, 84, 53, 135, 41]), bindingsDigest := (bytes [191, 4, 51, 6, 94, 48, 172, 219, 100, 92, 162, 144, 159, 143, 193, 39, 155, 211, 15, 146, 90, 254, 129, 35, 195, 70, 64, 90, 228, 155, 120, 48]), preparedStepsDigest := (bytes [175, 67, 54, 44, 255, 117, 192, 118, 14, 93, 142, 131, 123, 234, 138, 135, 168, 227, 78, 140, 10, 110, 73, 40, 187, 240, 199, 211, 168, 154, 90, 250]), digest := (bytes [149, 99, 147, 14, 14, 6, 253, 3, 182, 144, 34, 12, 93, 170, 109, 54, 239, 236, 66, 245, 178, 65, 183, 123, 248, 39, 11, 16, 252, 150, 174, 10]) }, digest := (bytes [27, 150, 255, 63, 85, 153, 185, 126, 162, 122, 198, 148, 77, 239, 85, 126, 86, 220, 211, 202, 66, 153, 181, 200, 186, 49, 170, 243, 64, 98, 191, 194]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [129, 88, 205, 31, 122, 194, 197, 123, 130, 181, 17, 239, 205, 213, 80, 253, 251, 34, 140, 79, 238, 89, 224, 13, 192, 53, 124, 88, 4, 85, 168, 55]), terminal := { root0Digest := (bytes [136, 28, 209, 27, 97, 186, 22, 192, 232, 198, 243, 170, 46, 6, 247, 29, 121, 48, 129, 111, 147, 109, 255, 41, 26, 208, 224, 144, 114, 105, 103, 152]), executionDigest := (bytes [216, 222, 179, 38, 20, 54, 249, 142, 177, 39, 183, 229, 29, 226, 13, 225, 74, 252, 72, 165, 4, 145, 80, 197, 205, 158, 197, 254, 151, 248, 6, 131]), finalStateDigest := (bytes [207, 244, 140, 140, 253, 220, 153, 85, 210, 72, 78, 149, 45, 76, 101, 175, 63, 107, 102, 240, 184, 237, 98, 242, 203, 60, 16, 255, 244, 31, 162, 249]), transcriptFinalDigest := (bytes [220, 210, 243, 194, 82, 47, 210, 0, 22, 21, 24, 49, 198, 154, 28, 14, 214, 176, 219, 99, 123, 33, 22, 249, 10, 120, 148, 255, 68, 207, 116, 2]), finalPc := 20, halted := true, digest := (bytes [230, 130, 151, 154, 26, 73, 48, 177, 171, 156, 247, 36, 229, 237, 235, 178, 76, 218, 151, 34, 120, 37, 159, 77, 124, 7, 88, 139, 201, 244, 46, 138]) }, digest := (bytes [223, 99, 247, 150, 25, 105, 60, 1, 224, 71, 244, 170, 170, 166, 74, 223, 174, 54, 29, 19, 94, 189, 48, 24, 231, 246, 233, 254, 174, 32, 71, 239]) }, statementDigest := (bytes [172, 98, 152, 75, 221, 218, 251, 125, 38, 77, 190, 76, 10, 28, 172, 244, 129, 182, 235, 204, 161, 217, 172, 167, 58, 131, 247, 109, 63, 249, 35, 99]), proofDigest := (bytes [159, 19, 219, 77, 69, 117, 42, 189, 34, 119, 209, 86, 67, 89, 168, 149, 225, 114, 238, 44, 242, 175, 141, 27, 123, 55, 87, 188, 159, 233, 3, 24]), digest := (bytes [222, 161, 136, 86, 37, 77, 100, 58, 71, 45, 220, 126, 181, 63, 132, 123, 166, 71, 26, 209, 3, 155, 11, 102, 50, 172, 160, 187, 90, 140, 144, 191]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [25, 242, 215, 184, 254, 20, 90, 185, 232, 189, 207, 235, 115, 136, 182, 48, 249, 188, 59, 126, 24, 245, 6, 203, 160, 163, 22, 116, 111, 63, 199, 193]), layoutVersion := 1, digest := (bytes [110, 102, 202, 253, 144, 17, 153, 81, 240, 59, 211, 141, 212, 238, 213, 218, 7, 149, 22, 140, 89, 124, 147, 70, 176, 145, 212, 50, 89, 224, 59, 77]) }, rowWidth := 38, timeLen := 4, columnDigests := [(bytes [212, 186, 229, 172, 74, 68, 211, 103, 24, 241, 21, 82, 209, 33, 189, 99, 223, 36, 129, 167, 9, 173, 76, 108, 178, 222, 90, 225, 89, 142, 8, 14]), (bytes [56, 58, 241, 13, 94, 161, 102, 38, 209, 85, 101, 10, 115, 74, 68, 15, 139, 16, 65, 164, 142, 61, 38, 80, 159, 19, 8, 220, 33, 174, 155, 155]), (bytes [29, 30, 250, 119, 67, 192, 190, 83, 169, 199, 126, 126, 209, 9, 207, 51, 13, 31, 240, 215, 38, 77, 233, 53, 71, 218, 94, 76, 41, 218, 33, 58]), (bytes [181, 122, 105, 181, 35, 180, 95, 214, 79, 41, 41, 2, 114, 48, 216, 55, 223, 211, 166, 64, 24, 33, 244, 234, 111, 10, 124, 63, 69, 70, 27, 116]), (bytes [235, 168, 211, 18, 219, 164, 123, 11, 1, 214, 235, 228, 142, 231, 19, 191, 111, 116, 112, 196, 167, 65, 6, 113, 150, 204, 141, 39, 111, 24, 165, 153]), (bytes [121, 130, 244, 43, 235, 154, 135, 182, 125, 251, 219, 139, 88, 218, 127, 71, 219, 212, 14, 47, 150, 5, 16, 183, 37, 152, 140, 186, 198, 73, 221, 183]), (bytes [91, 136, 102, 108, 254, 142, 77, 48, 97, 138, 138, 188, 220, 213, 55, 183, 133, 216, 230, 69, 191, 7, 253, 203, 112, 162, 85, 64, 74, 16, 34, 24]), (bytes [132, 13, 123, 172, 120, 106, 189, 241, 207, 17, 23, 219, 168, 136, 164, 0, 142, 128, 126, 198, 69, 95, 67, 194, 148, 13, 102, 136, 180, 146, 31, 139]), (bytes [13, 51, 13, 112, 10, 98, 204, 18, 53, 169, 156, 155, 63, 147, 114, 64, 241, 138, 154, 179, 238, 77, 114, 193, 171, 122, 197, 145, 246, 175, 206, 33]), (bytes [248, 213, 174, 164, 44, 211, 83, 119, 168, 127, 195, 214, 11, 72, 96, 216, 198, 29, 242, 145, 123, 183, 225, 150, 175, 102, 111, 235, 208, 130, 139, 155]), (bytes [32, 64, 97, 165, 48, 228, 106, 97, 58, 99, 14, 168, 63, 135, 66, 111, 135, 195, 225, 237, 39, 221, 23, 227, 16, 4, 135, 55, 248, 191, 135, 167]), (bytes [228, 208, 212, 3, 158, 123, 159, 22, 200, 85, 94, 53, 133, 251, 112, 144, 104, 119, 103, 120, 106, 126, 134, 102, 254, 183, 119, 5, 230, 104, 137, 4]), (bytes [238, 189, 198, 6, 199, 30, 93, 193, 29, 126, 221, 61, 73, 119, 129, 87, 55, 227, 133, 106, 170, 178, 160, 203, 102, 209, 230, 172, 220, 2, 72, 166]), (bytes [128, 172, 240, 189, 197, 88, 138, 41, 109, 81, 42, 68, 25, 21, 173, 79, 110, 210, 130, 146, 48, 191, 99, 218, 113, 149, 146, 144, 184, 14, 150, 106]), (bytes [74, 226, 37, 10, 152, 135, 71, 32, 121, 204, 236, 95, 238, 168, 237, 37, 113, 198, 64, 103, 189, 79, 90, 86, 18, 168, 112, 176, 240, 27, 29, 182]), (bytes [220, 193, 230, 244, 243, 14, 93, 42, 216, 108, 251, 253, 94, 191, 212, 189, 13, 211, 94, 236, 218, 138, 122, 7, 190, 222, 130, 249, 182, 150, 137, 189]), (bytes [223, 89, 191, 11, 110, 102, 31, 137, 129, 115, 137, 48, 64, 221, 208, 112, 235, 228, 24, 226, 254, 59, 16, 16, 192, 134, 30, 101, 212, 162, 156, 187]), (bytes [156, 22, 213, 157, 3, 147, 139, 132, 146, 22, 57, 209, 56, 31, 20, 20, 229, 105, 89, 38, 226, 230, 110, 49, 208, 70, 178, 10, 75, 21, 225, 62]), (bytes [89, 6, 118, 169, 105, 54, 5, 121, 26, 253, 91, 160, 13, 78, 211, 28, 177, 107, 187, 177, 10, 185, 35, 168, 191, 215, 99, 41, 155, 74, 182, 15]), (bytes [16, 1, 45, 207, 125, 115, 77, 40, 96, 249, 191, 96, 68, 155, 161, 144, 89, 205, 15, 173, 177, 139, 3, 87, 248, 132, 221, 254, 91, 235, 118, 133]), (bytes [2, 197, 213, 149, 21, 90, 236, 108, 141, 146, 26, 38, 0, 78, 135, 95, 223, 228, 221, 179, 125, 245, 167, 198, 49, 196, 48, 128, 192, 39, 124, 49]), (bytes [130, 134, 127, 131, 40, 47, 149, 206, 210, 112, 225, 17, 66, 25, 14, 78, 65, 235, 99, 73, 206, 90, 67, 148, 19, 78, 146, 25, 197, 149, 108, 61]), (bytes [8, 234, 67, 158, 76, 76, 170, 16, 58, 161, 138, 98, 35, 61, 115, 114, 104, 189, 45, 62, 96, 35, 11, 160, 56, 73, 223, 212, 106, 84, 224, 145]), (bytes [0, 189, 116, 3, 67, 124, 251, 249, 47, 128, 49, 73, 210, 47, 86, 252, 162, 78, 171, 9, 96, 183, 112, 195, 81, 120, 202, 223, 242, 24, 76, 51]), (bytes [81, 144, 1, 221, 155, 166, 187, 155, 181, 172, 254, 158, 176, 149, 110, 161, 164, 146, 156, 197, 231, 227, 176, 108, 72, 168, 128, 97, 162, 214, 166, 78]), (bytes [238, 147, 134, 181, 8, 29, 128, 200, 221, 198, 65, 181, 234, 22, 117, 159, 112, 0, 90, 214, 190, 69, 86, 72, 209, 196, 234, 23, 145, 109, 49, 190]), (bytes [150, 94, 21, 115, 92, 3, 250, 46, 250, 39, 23, 156, 66, 177, 198, 103, 242, 34, 109, 175, 253, 18, 181, 44, 23, 6, 9, 9, 119, 235, 11, 108]), (bytes [135, 215, 141, 47, 156, 11, 54, 54, 3, 72, 179, 247, 223, 155, 104, 7, 155, 222, 232, 159, 97, 172, 115, 97, 167, 121, 212, 57, 156, 44, 117, 203]), (bytes [84, 95, 115, 25, 213, 106, 24, 56, 216, 206, 94, 157, 100, 187, 198, 197, 93, 1, 173, 134, 90, 112, 47, 80, 254, 7, 54, 249, 32, 132, 243, 167]), (bytes [130, 198, 251, 47, 44, 43, 143, 92, 82, 195, 92, 157, 42, 215, 42, 26, 5, 251, 108, 34, 34, 0, 80, 113, 213, 113, 25, 247, 190, 124, 74, 52]), (bytes [234, 182, 234, 160, 23, 192, 246, 199, 173, 187, 203, 106, 254, 25, 134, 196, 2, 40, 181, 117, 170, 220, 56, 86, 63, 246, 0, 182, 78, 16, 61, 77]), (bytes [40, 254, 204, 213, 6, 140, 117, 235, 134, 79, 86, 81, 169, 63, 60, 118, 8, 156, 87, 198, 194, 60, 29, 160, 125, 250, 15, 187, 147, 220, 29, 92]), (bytes [18, 187, 180, 226, 104, 66, 42, 243, 22, 156, 53, 240, 151, 142, 203, 83, 91, 143, 153, 183, 211, 14, 178, 15, 249, 35, 88, 211, 226, 167, 221, 238]), (bytes [164, 40, 127, 229, 211, 147, 121, 221, 253, 56, 242, 238, 25, 160, 231, 5, 98, 88, 35, 198, 216, 51, 242, 34, 196, 132, 1, 62, 202, 49, 246, 41]), (bytes [122, 105, 77, 66, 174, 33, 37, 82, 171, 117, 60, 146, 152, 71, 176, 9, 4, 214, 95, 111, 117, 16, 77, 11, 22, 12, 202, 53, 36, 93, 76, 79]), (bytes [190, 26, 99, 184, 175, 199, 251, 124, 134, 183, 220, 35, 196, 195, 152, 135, 36, 169, 87, 198, 14, 22, 245, 143, 20, 239, 221, 18, 139, 77, 165, 236]), (bytes [80, 33, 41, 82, 68, 242, 18, 200, 209, 172, 125, 228, 155, 229, 192, 181, 222, 62, 254, 113, 197, 197, 209, 167, 162, 245, 86, 19, 189, 248, 96, 43]), (bytes [90, 10, 190, 250, 226, 23, 47, 210, 182, 164, 148, 175, 37, 226, 99, 192, 247, 166, 149, 66, 95, 29, 230, 232, 50, 99, 224, 203, 78, 177, 221, 250])], familyDigest := (bytes [25, 242, 215, 184, 254, 20, 90, 185, 232, 189, 207, 235, 115, 136, 182, 48, 249, 188, 59, 126, 24, 245, 6, 203, 160, 163, 22, 116, 111, 63, 199, 193]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [25, 242, 215, 184, 254, 20, 90, 185, 232, 189, 207, 235, 115, 136, 182, 48, 249, 188, 59, 126, 24, 245, 6, 203, 160, 163, 22, 116, 111, 63, 199, 193]), layoutVersion := 1, digest := (bytes [110, 102, 202, 253, 144, 17, 153, 81, 240, 59, 211, 141, 212, 238, 213, 218, 7, 149, 22, 140, 89, 124, 147, 70, 176, 145, 212, 50, 89, 224, 59, 77]) }, logicalIndex := 0, digest := (bytes [143, 96, 174, 197, 151, 152, 68, 42, 161, 160, 41, 84, 98, 128, 102, 57, 51, 162, 58, 94, 208, 62, 160, 239, 22, 200, 217, 244, 140, 235, 31, 3]) }, valueDigest := (bytes [16, 18, 204, 238, 34, 55, 227, 219, 112, 224, 153, 77, 87, 255, 222, 57, 93, 120, 113, 190, 238, 193, 38, 190, 84, 232, 126, 51, 50, 221, 88, 172]), digest := (bytes [113, 111, 113, 72, 209, 21, 197, 38, 79, 2, 169, 207, 184, 209, 224, 240, 202, 126, 144, 79, 56, 134, 102, 207, 25, 208, 184, 3, 29, 252, 81, 188]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [25, 242, 215, 184, 254, 20, 90, 185, 232, 189, 207, 235, 115, 136, 182, 48, 249, 188, 59, 126, 24, 245, 6, 203, 160, 163, 22, 116, 111, 63, 199, 193]), layoutVersion := 1, digest := (bytes [110, 102, 202, 253, 144, 17, 153, 81, 240, 59, 211, 141, 212, 238, 213, 218, 7, 149, 22, 140, 89, 124, 147, 70, 176, 145, 212, 50, 89, 224, 59, 77]) }, logicalIndex := 3, digest := (bytes [46, 219, 119, 80, 92, 182, 252, 143, 220, 118, 171, 93, 244, 115, 34, 173, 16, 25, 125, 107, 132, 88, 40, 5, 86, 131, 110, 153, 108, 82, 226, 151]) }, valueDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [197, 124, 175, 176, 136, 105, 83, 70, 4, 160, 98, 196, 5, 243, 56, 51, 137, 176, 18, 3, 131, 197, 173, 64, 80, 45, 117, 240, 55, 66, 193, 2]) }), digest := (bytes [36, 62, 47, 98, 133, 33, 72, 45, 157, 139, 218, 98, 165, 14, 212, 18, 88, 172, 130, 72, 105, 154, 80, 3, 222, 66, 91, 193, 91, 182, 221, 126]) }
  , rootLaneCommitment := { timeLen := 4, commitments := { commitmentCount := 38, digest := (bytes [224, 35, 130, 146, 73, 187, 180, 161, 207, 126, 172, 132, 75, 27, 45, 130, 95, 188, 79, 180, 97, 222, 14, 171, 162, 112, 240, 232, 195, 86, 247, 255]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [224, 35, 130, 146, 73, 187, 180, 161, 207, 126, 172, 132, 75, 27, 45, 130, 95, 188, 79, 180, 97, 222, 14, 171, 162, 112, 240, 232, 195, 86, 247, 255]), layoutVersion := 3, digest := (bytes [73, 219, 13, 49, 103, 247, 89, 166, 27, 108, 67, 127, 15, 169, 73, 6, 209, 175, 225, 108, 224, 209, 237, 64, 72, 252, 167, 45, 73, 146, 155, 48]) }, logicalIndex := 0, digest := (bytes [23, 192, 58, 164, 26, 55, 218, 251, 99, 242, 254, 15, 136, 176, 28, 136, 128, 246, 130, 180, 140, 153, 188, 49, 52, 63, 8, 210, 49, 107, 105, 71]) }, valueDigest := (bytes [16, 18, 204, 238, 34, 55, 227, 219, 112, 224, 153, 77, 87, 255, 222, 57, 93, 120, 113, 190, 238, 193, 38, 190, 84, 232, 126, 51, 50, 221, 88, 172]), digest := (bytes [82, 152, 47, 125, 240, 238, 38, 102, 66, 145, 113, 22, 238, 165, 163, 111, 107, 0, 135, 54, 70, 71, 176, 39, 95, 98, 9, 66, 244, 202, 154, 32]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [224, 35, 130, 146, 73, 187, 180, 161, 207, 126, 172, 132, 75, 27, 45, 130, 95, 188, 79, 180, 97, 222, 14, 171, 162, 112, 240, 232, 195, 86, 247, 255]), layoutVersion := 3, digest := (bytes [73, 219, 13, 49, 103, 247, 89, 166, 27, 108, 67, 127, 15, 169, 73, 6, 209, 175, 225, 108, 224, 209, 237, 64, 72, 252, 167, 45, 73, 146, 155, 48]) }, logicalIndex := 3, digest := (bytes [90, 134, 137, 77, 249, 107, 189, 181, 52, 146, 43, 116, 82, 82, 78, 93, 175, 11, 187, 228, 162, 43, 196, 92, 67, 20, 241, 239, 245, 202, 241, 97]) }, valueDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [16, 20, 62, 26, 165, 5, 139, 163, 57, 15, 250, 146, 67, 199, 114, 6, 83, 128, 154, 182, 12, 172, 181, 146, 186, 187, 199, 193, 101, 10, 132, 108]) }), digest := (bytes [241, 160, 179, 19, 65, 253, 184, 51, 70, 153, 122, 41, 192, 101, 164, 133, 222, 36, 82, 136, 158, 151, 0, 29, 255, 61, 250, 221, 38, 182, 106, 64]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [36, 62, 47, 98, 133, 33, 72, 45, 157, 139, 218, 98, 165, 14, 212, 18, 88, 172, 130, 72, 105, 154, 80, 3, 222, 66, 91, 193, 91, 182, 221, 126]), rootLaneCommitmentDigest := (bytes [241, 160, 179, 19, 65, 253, 184, 51, 70, 153, 122, 41, 192, 101, 164, 133, 222, 36, 82, 136, 158, 151, 0, 29, 255, 61, 250, 221, 38, 182, 106, 64]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 4, digest := (bytes [10, 37, 78, 104, 98, 178, 246, 10, 37, 94, 101, 207, 244, 124, 152, 243, 75, 112, 143, 5, 82, 12, 30, 107, 120, 24, 79, 135, 75, 57, 249, 235]) }, statementDigest := (bytes [162, 252, 86, 97, 11, 168, 138, 195, 168, 18, 167, 37, 97, 235, 98, 74, 90, 211, 73, 97, 94, 106, 142, 73, 184, 74, 214, 123, 225, 38, 238, 205]), proofDigest := (bytes [75, 22, 135, 51, 89, 193, 5, 134, 98, 110, 209, 10, 221, 111, 178, 57, 128, 45, 117, 209, 105, 219, 88, 244, 15, 191, 58, 0, 173, 135, 73, 229]), digest := (bytes [78, 71, 22, 7, 181, 80, 70, 222, 142, 207, 248, 22, 150, 29, 171, 21, 200, 26, 17, 15, 20, 143, 190, 249, 2, 120, 244, 123, 93, 197, 187, 210]) }
  , digest := (bytes [125, 1, 18, 237, 158, 43, 221, 220, 231, 222, 172, 98, 48, 211, 238, 66, 51, 232, 6, 141, 202, 162, 165, 120, 228, 35, 49, 172, 181, 172, 152, 163])
}
    , transcript := {
  appLabel := (bytes [110, 101, 111, 46, 102, 111, 108, 100, 46, 110, 101, 120, 116, 47, 114, 118, 54, 52, 105, 109, 47, 112, 97, 114, 105, 116, 121, 95, 107, 101, 114, 110, 101, 108, 95, 118, 49])
  , events := [{
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 116, 114, 97, 110, 115, 99, 114, 105, 112, 116, 95, 115, 101, 101, 100])
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 99, 111, 110, 116, 114, 111, 108, 45, 102, 108, 111, 119, 45, 98, 103, 101, 117, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [27634538711377453, 54383638570343, 1823709644592138771, 15695669540104460710, 8188744055654938720, 6008164579518882152, 10584698648648697023, 6532369056394176230], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [99, 111, 110, 116, 114, 111, 108, 95, 102, 108, 111, 119, 95, 98, 103, 101, 117, 95, 116, 97, 107, 101, 110, 95, 115, 107, 105, 112, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [27634538711377453, 54383638570343, 1823709644592138771, 15695669540104460710, 8188744055654938720, 6008164579518882152, 10584698648648697023, 6532369056394176230], absorbed := 2 }
  , cursorAfter := { stateWords := [119212746171743, 4115465076320722641, 10265791983627518635, 543941533280415099, 6470597071131417095, 3459529626164976671, 6538594751029149855, 9202376365345449052], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [2097299, 1048851, 2159715, 115, 115]
  , cursorBefore := { stateWords := [119212746171743, 4115465076320722641, 10265791983627518635, 543941533280415099, 6470597071131417095, 3459529626164976671, 6538594751029149855, 9202376365345449052], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 7631244085689216595, 8440193799965894114, 14388964891207711840, 2056782885545757663, 1529144530094235108, 2253812106308094552, 13023645497027124897], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [0, 7631244085689216595, 8440193799965894114, 14388964891207711840, 2056782885545757663, 1529144530094235108, 2253812106308094552, 13023645497027124897], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 0, 0, 8054943088534077807, 13846332591903095255, 12463867618150028911, 14586359305607902986, 11717871853396826665], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [0, 0, 0, 8054943088534077807, 13846332591903095255, 12463867618150028911, 14586359305607902986, 11717871853396826665], absorbed := 3 }
  , cursorAfter := { stateWords := [0, 230873779471710420, 6964603481912124136, 11370762658102756114, 607388998938196074, 10350170456409138927, 12953860084092507636, 1082719992604845587], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [136, 28, 209, 27, 97, 186, 22, 192, 232, 198, 243, 170, 46, 6, 247, 29, 121, 48, 129, 111, 147, 109, 255, 41, 26, 208, 224, 144, 114, 105, 103, 152])
  , u64s := []
  , cursorBefore := { stateWords := [0, 230873779471710420, 6964603481912124136, 11370762658102756114, 607388998938196074, 10350170456409138927, 12953860084092507636, 1082719992604845587], absorbed := 1 }
  , cursorAfter := { stateWords := [2491980700698988972, 14068472359300423438, 17519047032954281148, 16448807135216549510, 14756161607341614720, 14989551616862978022, 13957537584803479485, 2382084973428616934], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [2491980700698988972, 14068472359300423438, 17519047032954281148, 16448807135216549510, 14756161607341614720, 14989551616862978022, 13957537584803479485, 2382084973428616934], absorbed := 0 }
  , cursorAfter := { stateWords := [2302652608239151864, 7130242139247192989, 1536477261163950027, 6314366652416881261, 9774956454389601012, 1241629233521582540, 11522590400807307548, 5735015773736746616], absorbed := 0 }
  , challengeOutput := (some 2302652608239151864)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [38, 1, 111, 25, 28, 52, 17, 93, 213, 60, 148, 249, 31, 250, 244, 14, 78, 84, 6, 40, 66, 110, 230, 118, 128, 211, 149, 94, 100, 248, 222, 19])
  , u64s := []
  , cursorBefore := { stateWords := [2302652608239151864, 7130242139247192989, 1536477261163950027, 6314366652416881261, 9774956454389601012, 1241629233521582540, 11522590400807307548, 5735015773736746616], absorbed := 0 }
  , cursorAfter := { stateWords := [18621356112219892, 26623383436715630, 333379684, 10485438589329696725, 14876902141821514848, 15276347457467243244, 16519611062992214112, 7256149985783836630], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [18621356112219892, 26623383436715630, 333379684, 10485438589329696725, 14876902141821514848, 15276347457467243244, 16519611062992214112, 7256149985783836630], absorbed := 3 }
  , cursorAfter := { stateWords := [10806869914316609246, 15806731556035115430, 12389253343389949275, 16729553705511047762, 6582825377533277016, 16734122218319710901, 8005843161548042819, 3880364712725972742], absorbed := 0 }
  , challengeOutput := (some 10806869914316609246)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [10806869914316609246, 15806731556035115430, 12389253343389949275, 16729553705511047762, 6582825377533277016, 16734122218319710901, 8005843161548042819, 3880364712725972742], absorbed := 0 }
  , cursorAfter := { stateWords := [1959622797672027888, 17651696247336291884, 11720460566859635632, 6919812372420016008, 5499717622967941681, 2853279359317452701, 14759054242794873370, 6243048439933786052], absorbed := 0 }
  , challengeOutput := (some 1959622797672027888)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [166, 190, 44, 132, 128, 151, 204, 56, 245, 149, 250, 100, 68, 251, 133, 216, 118, 141, 212, 118, 201, 209, 68, 33, 74, 28, 127, 220, 47, 90, 112, 230])
  , u64s := []
  , cursorBefore := { stateWords := [1959622797672027888, 17651696247336291884, 11720460566859635632, 6919812372420016008, 5499717622967941681, 2853279359317452701, 14759054242794873370, 6243048439933786052], absorbed := 0 }
  , cursorAfter := { stateWords := [56707125597362309, 62064254355850449, 3866122799, 12929877950451745014, 1756846508717143854, 9609595341734835927, 17484194971466081028, 13465387111089516922], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [56707125597362309, 62064254355850449, 3866122799, 12929877950451745014, 1756846508717143854, 9609595341734835927, 17484194971466081028, 13465387111089516922], absorbed := 3 }
  , cursorAfter := { stateWords := [2657263387322609258, 17421979329178809139, 9787209125109745185, 7491875297347501185, 1989378684025500775, 9005104167904948773, 10165090286127097813, 11761285918797788840], absorbed := 0 }
  , challengeOutput := (some 2657263387322609258)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [198, 81, 7, 250, 152, 135, 65, 159, 231, 42, 117, 161, 26, 121, 63, 197, 123, 212, 231, 113, 35, 37, 159, 177, 226, 104, 247, 68, 136, 30, 16, 163])
  , u64s := []
  , cursorBefore := { stateWords := [2657263387322609258, 17421979329178809139, 9787209125109745185, 7491875297347501185, 1989378684025500775, 9005104167904948773, 10165090286127097813, 11761285918797788840], absorbed := 0 }
  , cursorAfter := { stateWords := [9976864701138239, 19412328268275493, 2735742600, 4589826518242105380, 16312361777310826010, 14330958536230969493, 7763975302023814306, 2351550924013014552], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [216, 222, 179, 38, 20, 54, 249, 142, 177, 39, 183, 229, 29, 226, 13, 225, 74, 252, 72, 165, 4, 145, 80, 197, 205, 158, 197, 254, 151, 248, 6, 131])
  , u64s := []
  , cursorBefore := { stateWords := [9976864701138239, 19412328268275493, 2735742600, 4589826518242105380, 16312361777310826010, 14330958536230969493, 7763975302023814306, 2351550924013014552], absorbed := 3 }
  , cursorAfter := { stateWords := [1307632795836685, 71711929932271761, 2198272151, 5006567380650827533, 12695412723250713982, 2202973391026883564, 4455388109040917094, 12391254929522659973], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [207, 244, 140, 140, 253, 220, 153, 85, 210, 72, 78, 149, 45, 76, 101, 175, 63, 107, 102, 240, 184, 237, 98, 242, 203, 60, 16, 255, 244, 31, 162, 249])
  , u64s := []
  , cursorBefore := { stateWords := [1307632795836685, 71711929932271761, 2198272151, 5006567380650827533, 12695412723250713982, 2202973391026883564, 4455388109040917094, 12391254929522659973], absorbed := 3 }
  , cursorAfter := { stateWords := [52055718391426917, 71793972366959341, 4188151796, 14720217363501469615, 5839986288202124512, 15842499204513090931, 4209314985581236974, 3003143283336044558], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [52055718391426917, 71793972366959341, 4188151796, 14720217363501469615, 5839986288202124512, 15842499204513090931, 4209314985581236974, 3003143283336044558], absorbed := 3 }
  , cursorAfter := { stateWords := [1727357311060009140, 392412233049723249, 5376223040815207962, 5545438250291612210, 18191948353196698425, 2930334182322678240, 5188326213335546338, 3654734493943723780], absorbed := 0 }
  , challengeOutput := (some 1727357311060009140)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [1727357311060009140, 392412233049723249, 5376223040815207962, 5545438250291612210, 18191948353196698425, 2930334182322678240, 5188326213335546338, 3654734493943723780], absorbed := 0 }
  , cursorAfter := { stateWords := [59161777613820636, 1016857791896753430, 17948570178771726550, 176994180626937866, 2116920300628803648, 7782557740171667341, 9568767961969140595, 10469167577974212368], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [220, 210, 243, 194, 82, 47, 210, 0, 22, 21, 24, 49, 198, 154, 28, 14, 214, 176, 219, 99, 123, 33, 22, 249, 10, 120, 148, 255, 68, 207, 116, 2]))
}]
}
    , stage1 := stage1
    , stage2 := stage2
    , stage3 := stage3
    , rootExecution := rootExecution
    , stepComposition := stepComposition
    , soundnessAccounting := soundnessAccounting
    , kernelOpeningBundle := kernelOpeningBundle
    , digest := (bytes [210, 215, 149, 16, 73, 151, 175, 18, 5, 238, 67, 0, 19, 58, 66, 39, 33, 232, 93, 148, 110, 212, 85, 78, 157, 6, 209, 85, 183, 53, 205, 99])
  }

end Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors.Case_control_flow_bgeu_taken_skip_ecall
