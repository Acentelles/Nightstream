import Nightstream.Rv64IM.Generated.AcceptedProofArtifactTypes

set_option maxHeartbeats 0
set_option maxRecDepth 65536

namespace Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors.Case_control_flow_blt_taken_skip_ecall

open Nightstream.Rv64IM.Generated

def stage1SemInputs : List SemInView :=
  [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, pc := 0, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 1, archRdBefore := 0, archImm := -1, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 1, rdBefore := 0, rdAfter := 18446744073709551615, imm := -1, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, pc := 4, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 2, archRdBefore := 0, archImm := 1, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 2, rdBefore := 0, rdAfter := 1, imm := 1, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, pc := 8, opcode := .blt, traceOpcode := (some .blt), traceVirtualOpcode := none, family := .controlFlow, archRs1 := 1, archRs1Value := 18446744073709551615, archRs2 := 2, archRs2Value := 1, archRd := 0, archRdBefore := 0, archImm := 8, rs1 := 1, rs1Value := 18446744073709551615, rs2 := 2, rs2Value := 1, rd := 0, rdBefore := 0, rdAfter := 0, imm := 8, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := false, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, pc := 16, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 0, archRdBefore := 0, archImm := 0, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 0, rdBefore := 0, rdAfter := 0, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := false, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }]

def stage1RowBindings : List Stage1RowBindingView :=
  [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 4293918867, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 4, aluResult := 18446744073709551615, effectiveAddr := none, writesRd := true, rd := 1, rdAfter := 18446744073709551615, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 1048851, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 8, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 2, rdAfter := 1, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 2147427, opcode := .blt, traceOpcode := (some .blt), traceVirtualOpcode := none, family := .controlFlow, nextPc := 16, aluResult := 1, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 16, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 20, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }]

def stage1 : Stage1ProofBundleView :=
  {
    semInputs := stage1SemInputs
    , rowBindings := stage1RowBindings
    , bytecodeDigest := (bytes [29, 127, 73, 65, 163, 175, 210, 199, 174, 243, 172, 21, 165, 3, 135, 75, 68, 211, 245, 240, 236, 143, 12, 193, 62, 128, 198, 116, 208, 75, 14, 69])
    , aluDigest := (bytes [12, 93, 218, 131, 237, 14, 243, 185, 53, 85, 79, 65, 139, 32, 172, 177, 134, 140, 153, 26, 151, 61, 153, 132, 198, 161, 232, 62, 48, 200, 174, 20])
    , branchDigest := (bytes [170, 108, 177, 78, 189, 56, 1, 108, 9, 246, 140, 48, 50, 245, 249, 207, 234, 25, 80, 211, 66, 70, 28, 109, 6, 5, 236, 179, 10, 163, 113, 133])
    , semantics := { semInputsDigest := (bytes [167, 64, 244, 194, 236, 74, 22, 63, 111, 217, 172, 116, 145, 193, 5, 160, 240, 190, 255, 214, 200, 201, 214, 12, 149, 234, 232, 121, 168, 107, 99, 7]), rowBindingsDigest := (bytes [90, 8, 155, 94, 189, 63, 178, 10, 209, 166, 18, 30, 117, 200, 87, 153, 41, 47, 207, 95, 159, 202, 98, 171, 207, 84, 217, 116, 66, 10, 128, 12]), sequenceCount := 4, helperRowCount := 0, digest := (bytes [168, 201, 5, 200, 41, 41, 243, 59, 146, 52, 189, 225, 122, 57, 136, 59, 34, 222, 130, 83, 150, 59, 190, 238, 189, 235, 90, 180, 23, 39, 6, 76]) }
    , addressCorrectnessDigest := (bytes [123, 93, 172, 135, 32, 241, 240, 156, 239, 246, 90, 218, 136, 133, 117, 18, 196, 213, 120, 50, 23, 168, 123, 24, 57, 243, 217, 251, 244, 67, 155, 168])
    , linkageDigest := (bytes [50, 164, 142, 213, 204, 50, 51, 110, 213, 72, 92, 186, 222, 138, 106, 150, 39, 99, 189, 193, 250, 213, 173, 126, 232, 9, 94, 157, 26, 146, 93, 179])
    , selectedOpening := { claim := { rowsFamilyDigest := (bytes [90, 8, 155, 94, 189, 63, 178, 10, 209, 166, 18, 30, 117, 200, 87, 153, 41, 47, 207, 95, 159, 202, 98, 171, 207, 84, 217, 116, 66, 10, 128, 12]), rowCount := 4, effectRowCount := 4, commitRowCount := 4, realRowCount := 4, preservesX0Count := 2, firstTraceIndex := 0, effectTraceIndex := 0, commitTraceIndex := 0, lastTraceIndex := 3, mix := 16644640469157671253, points := { first := { id := { object := { familyTag := 1, commitmentDigest := (bytes [90, 8, 155, 94, 189, 63, 178, 10, 209, 166, 18, 30, 117, 200, 87, 153, 41, 47, 207, 95, 159, 202, 98, 171, 207, 84, 217, 116, 66, 10, 128, 12]), layoutVersion := 1, digest := (bytes [71, 60, 252, 180, 16, 157, 77, 103, 17, 189, 142, 255, 203, 91, 173, 144, 204, 206, 17, 176, 34, 188, 130, 222, 230, 250, 62, 131, 143, 87, 236, 136]) }, logicalIndex := 0, digest := (bytes [34, 222, 91, 242, 177, 183, 97, 44, 236, 98, 76, 64, 99, 77, 218, 134, 234, 3, 112, 10, 74, 185, 213, 103, 213, 106, 37, 197, 26, 147, 132, 111]) }, valueDigest := (bytes [158, 37, 157, 35, 27, 59, 49, 54, 223, 209, 215, 4, 245, 158, 87, 22, 223, 12, 54, 180, 219, 206, 107, 15, 245, 160, 63, 101, 244, 105, 244, 72]), digest := (bytes [192, 133, 157, 188, 80, 6, 201, 188, 220, 210, 241, 175, 167, 153, 165, 115, 104, 145, 143, 180, 232, 207, 196, 63, 35, 54, 140, 55, 182, 102, 215, 137]) }, effect := { id := { object := { familyTag := 1, commitmentDigest := (bytes [90, 8, 155, 94, 189, 63, 178, 10, 209, 166, 18, 30, 117, 200, 87, 153, 41, 47, 207, 95, 159, 202, 98, 171, 207, 84, 217, 116, 66, 10, 128, 12]), layoutVersion := 1, digest := (bytes [71, 60, 252, 180, 16, 157, 77, 103, 17, 189, 142, 255, 203, 91, 173, 144, 204, 206, 17, 176, 34, 188, 130, 222, 230, 250, 62, 131, 143, 87, 236, 136]) }, logicalIndex := 0, digest := (bytes [34, 222, 91, 242, 177, 183, 97, 44, 236, 98, 76, 64, 99, 77, 218, 134, 234, 3, 112, 10, 74, 185, 213, 103, 213, 106, 37, 197, 26, 147, 132, 111]) }, valueDigest := (bytes [158, 37, 157, 35, 27, 59, 49, 54, 223, 209, 215, 4, 245, 158, 87, 22, 223, 12, 54, 180, 219, 206, 107, 15, 245, 160, 63, 101, 244, 105, 244, 72]), digest := (bytes [192, 133, 157, 188, 80, 6, 201, 188, 220, 210, 241, 175, 167, 153, 165, 115, 104, 145, 143, 180, 232, 207, 196, 63, 35, 54, 140, 55, 182, 102, 215, 137]) }, commit := { id := { object := { familyTag := 1, commitmentDigest := (bytes [90, 8, 155, 94, 189, 63, 178, 10, 209, 166, 18, 30, 117, 200, 87, 153, 41, 47, 207, 95, 159, 202, 98, 171, 207, 84, 217, 116, 66, 10, 128, 12]), layoutVersion := 1, digest := (bytes [71, 60, 252, 180, 16, 157, 77, 103, 17, 189, 142, 255, 203, 91, 173, 144, 204, 206, 17, 176, 34, 188, 130, 222, 230, 250, 62, 131, 143, 87, 236, 136]) }, logicalIndex := 0, digest := (bytes [34, 222, 91, 242, 177, 183, 97, 44, 236, 98, 76, 64, 99, 77, 218, 134, 234, 3, 112, 10, 74, 185, 213, 103, 213, 106, 37, 197, 26, 147, 132, 111]) }, valueDigest := (bytes [158, 37, 157, 35, 27, 59, 49, 54, 223, 209, 215, 4, 245, 158, 87, 22, 223, 12, 54, 180, 219, 206, 107, 15, 245, 160, 63, 101, 244, 105, 244, 72]), digest := (bytes [192, 133, 157, 188, 80, 6, 201, 188, 220, 210, 241, 175, 167, 153, 165, 115, 104, 145, 143, 180, 232, 207, 196, 63, 35, 54, 140, 55, 182, 102, 215, 137]) }, last := { id := { object := { familyTag := 1, commitmentDigest := (bytes [90, 8, 155, 94, 189, 63, 178, 10, 209, 166, 18, 30, 117, 200, 87, 153, 41, 47, 207, 95, 159, 202, 98, 171, 207, 84, 217, 116, 66, 10, 128, 12]), layoutVersion := 1, digest := (bytes [71, 60, 252, 180, 16, 157, 77, 103, 17, 189, 142, 255, 203, 91, 173, 144, 204, 206, 17, 176, 34, 188, 130, 222, 230, 250, 62, 131, 143, 87, 236, 136]) }, logicalIndex := 3, digest := (bytes [231, 100, 225, 226, 130, 178, 202, 38, 254, 159, 161, 218, 29, 225, 127, 236, 190, 117, 236, 66, 140, 195, 113, 100, 67, 196, 133, 249, 57, 121, 154, 124]) }, valueDigest := (bytes [42, 117, 137, 62, 203, 77, 127, 14, 91, 68, 2, 177, 38, 250, 164, 28, 55, 139, 198, 41, 209, 72, 143, 173, 84, 204, 135, 91, 62, 25, 137, 209]), digest := (bytes [89, 35, 156, 197, 50, 86, 53, 171, 195, 9, 203, 42, 182, 89, 99, 241, 66, 234, 79, 69, 122, 210, 240, 7, 24, 134, 197, 152, 238, 188, 74, 64]) } }, digest := (bytes [28, 250, 211, 114, 189, 95, 107, 59, 36, 144, 156, 14, 154, 246, 178, 201, 58, 104, 235, 159, 245, 46, 121, 150, 225, 116, 85, 157, 110, 144, 0, 220]) }, packaged := { statementDigest := (bytes [213, 93, 244, 91, 253, 203, 185, 232, 24, 249, 142, 176, 223, 196, 182, 99, 222, 83, 61, 250, 164, 241, 17, 8, 139, 207, 187, 220, 16, 230, 255, 20]), proofDigest := (bytes [206, 201, 246, 137, 219, 38, 8, 159, 68, 188, 135, 249, 214, 65, 197, 67, 180, 187, 63, 25, 52, 228, 147, 55, 135, 205, 71, 189, 251, 136, 18, 212]) }, digest := (bytes [9, 211, 167, 148, 204, 209, 99, 130, 11, 103, 22, 106, 135, 209, 58, 212, 168, 170, 233, 94, 97, 173, 34, 173, 80, 5, 232, 148, 135, 61, 64, 211]) }
    , digest := (bytes [103, 141, 73, 222, 229, 181, 68, 135, 250, 74, 109, 45, 95, 197, 198, 41, 88, 180, 123, 244, 127, 81, 229, 166, 129, 141, 148, 3, 13, 79, 245, 210])
  }

def stage2RegisterReads : List RegisterReadEventView :=
  [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 0, value := 0 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 0, value := 0 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 1, value := 18446744073709551615 }, { traceIndex := 2, stepIndex := 2, role := .rs2, reg := 2, value := 1 }]

def stage2RegisterWrites : List RegisterWriteEventView :=
  [{ traceIndex := 0, stepIndex := 0, reg := 1, previous := 0, next := 18446744073709551615 }, { traceIndex := 1, stepIndex := 1, reg := 2, previous := 0, next := 1 }]

def stage2RamEvents : List RamEventView :=
  []

def stage2TwistLinks : List TwistLinkEventView :=
  [{ traceIndex := 0, stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 1, family := .nativeAlu, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 2, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 3, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]

def stage2 : Stage2ProofBundleView :=
  {
    registerReads := stage2RegisterReads
    , registerWrites := stage2RegisterWrites
    , ramEvents := stage2RamEvents
    , registerDigest := (bytes [139, 138, 69, 245, 35, 92, 238, 232, 29, 128, 198, 133, 73, 179, 105, 192, 100, 205, 15, 212, 230, 235, 65, 221, 88, 46, 91, 107, 110, 26, 180, 131])
    , ramDigest := (bytes [209, 217, 105, 43, 209, 229, 156, 61, 92, 164, 94, 232, 52, 214, 73, 229, 72, 188, 139, 122, 165, 123, 201, 212, 205, 15, 247, 197, 165, 154, 109, 246])
    , temporal := { twistLinks := stage2TwistLinks, registerTimelineDigest := (bytes [24, 235, 85, 172, 225, 115, 76, 252, 2, 216, 0, 33, 155, 6, 121, 147, 236, 46, 207, 238, 75, 95, 62, 85, 30, 62, 112, 105, 109, 190, 121, 15]), ramTimelineDigest := (bytes [8, 117, 17, 140, 128, 180, 240, 140, 250, 181, 90, 134, 147, 17, 197, 122, 220, 8, 66, 15, 193, 254, 11, 122, 115, 210, 233, 239, 55, 132, 31, 228]), twistLinksDigest := (bytes [70, 44, 42, 134, 60, 19, 232, 209, 81, 182, 224, 67, 53, 21, 68, 65, 126, 189, 24, 140, 219, 75, 34, 196, 144, 81, 27, 229, 213, 169, 0, 230]), digest := (bytes [12, 74, 240, 171, 75, 109, 160, 232, 176, 4, 19, 98, 228, 45, 67, 132, 184, 13, 209, 40, 81, 25, 115, 6, 148, 54, 247, 102, 241, 145, 216, 95]) }
    , semantics := { registerReadsFamilyDigest := (bytes [106, 244, 251, 56, 203, 126, 133, 195, 230, 240, 233, 47, 50, 27, 24, 94, 73, 49, 117, 210, 99, 183, 251, 177, 72, 228, 81, 218, 144, 180, 191, 55]), registerWritesFamilyDigest := (bytes [246, 2, 145, 142, 19, 107, 71, 159, 5, 205, 226, 68, 30, 20, 0, 176, 11, 128, 178, 156, 242, 168, 192, 95, 206, 138, 227, 42, 127, 194, 168, 232]), ramEventsFamilyDigest := (bytes [85, 17, 108, 38, 84, 5, 109, 213, 145, 137, 203, 96, 117, 127, 130, 193, 117, 29, 27, 219, 228, 58, 7, 214, 144, 155, 66, 38, 127, 8, 241, 95]), twistLinksFamilyDigest := (bytes [126, 253, 239, 201, 40, 20, 251, 133, 94, 214, 195, 23, 49, 133, 28, 24, 151, 146, 57, 31, 138, 82, 185, 70, 29, 177, 220, 173, 117, 112, 96, 214]), rowCount := 4, registerEventCount := 6, ramEventCount := 0, digest := (bytes [103, 243, 230, 120, 30, 162, 86, 4, 182, 36, 21, 99, 46, 221, 139, 166, 95, 58, 238, 1, 16, 201, 130, 167, 18, 176, 161, 98, 102, 43, 174, 187]) }
    , linkageDigest := (bytes [46, 18, 215, 241, 253, 111, 41, 146, 210, 250, 248, 240, 18, 12, 172, 247, 238, 44, 145, 74, 107, 32, 229, 170, 211, 64, 158, 204, 68, 65, 62, 236])
    , selectedOpening := { claim := { registerReadsFamilyDigest := (bytes [106, 244, 251, 56, 203, 126, 133, 195, 230, 240, 233, 47, 50, 27, 24, 94, 73, 49, 117, 210, 99, 183, 251, 177, 72, 228, 81, 218, 144, 180, 191, 55]), registerWritesFamilyDigest := (bytes [246, 2, 145, 142, 19, 107, 71, 159, 5, 205, 226, 68, 30, 20, 0, 176, 11, 128, 178, 156, 242, 168, 192, 95, 206, 138, 227, 42, 127, 194, 168, 232]), ramEventsFamilyDigest := (bytes [85, 17, 108, 38, 84, 5, 109, 213, 145, 137, 203, 96, 117, 127, 130, 193, 117, 29, 27, 219, 228, 58, 7, 214, 144, 155, 66, 38, 127, 8, 241, 95]), twistLinksFamilyDigest := (bytes [126, 253, 239, 201, 40, 20, 251, 133, 94, 214, 195, 23, 49, 133, 28, 24, 151, 146, 57, 31, 138, 82, 185, 70, 29, 177, 220, 173, 117, 112, 96, 214]), registerReadCount := 4, registerWriteCount := 2, ramEventCount := 0, twistLinkCount := 4, ramReadCount := 0, ramWriteCount := 0, regMix := 1411288425859349507, ramMix := 10716973488349051482, points := { firstRead := (some { id := { object := { familyTag := 2, commitmentDigest := (bytes [106, 244, 251, 56, 203, 126, 133, 195, 230, 240, 233, 47, 50, 27, 24, 94, 73, 49, 117, 210, 99, 183, 251, 177, 72, 228, 81, 218, 144, 180, 191, 55]), layoutVersion := 1, digest := (bytes [178, 70, 198, 87, 132, 100, 82, 32, 87, 252, 177, 71, 125, 245, 70, 167, 94, 90, 78, 49, 50, 14, 226, 123, 98, 131, 169, 167, 131, 251, 97, 239]) }, logicalIndex := 0, digest := (bytes [238, 182, 107, 174, 76, 182, 20, 99, 200, 211, 185, 87, 12, 23, 65, 140, 36, 79, 51, 152, 249, 139, 29, 140, 110, 140, 83, 27, 124, 241, 7, 155]) }, valueDigest := (bytes [165, 2, 50, 180, 56, 84, 68, 13, 37, 136, 82, 191, 49, 42, 150, 67, 180, 45, 199, 251, 168, 91, 53, 39, 20, 9, 70, 46, 155, 135, 100, 116]), digest := (bytes [254, 38, 8, 183, 90, 3, 104, 30, 152, 15, 252, 120, 45, 106, 173, 101, 254, 220, 227, 185, 222, 24, 180, 141, 37, 204, 120, 55, 20, 226, 135, 47]) }), lastRead := (some { id := { object := { familyTag := 2, commitmentDigest := (bytes [106, 244, 251, 56, 203, 126, 133, 195, 230, 240, 233, 47, 50, 27, 24, 94, 73, 49, 117, 210, 99, 183, 251, 177, 72, 228, 81, 218, 144, 180, 191, 55]), layoutVersion := 1, digest := (bytes [178, 70, 198, 87, 132, 100, 82, 32, 87, 252, 177, 71, 125, 245, 70, 167, 94, 90, 78, 49, 50, 14, 226, 123, 98, 131, 169, 167, 131, 251, 97, 239]) }, logicalIndex := 3, digest := (bytes [47, 126, 34, 198, 197, 133, 199, 43, 224, 251, 60, 153, 196, 249, 46, 38, 246, 73, 203, 124, 193, 42, 93, 74, 201, 103, 167, 196, 7, 179, 223, 218]) }, valueDigest := (bytes [160, 84, 47, 218, 46, 65, 160, 13, 188, 132, 241, 222, 202, 178, 117, 86, 147, 45, 110, 179, 253, 83, 180, 119, 10, 191, 213, 44, 20, 14, 38, 138]), digest := (bytes [19, 187, 87, 172, 116, 161, 95, 167, 119, 174, 7, 93, 52, 44, 52, 23, 196, 252, 251, 62, 26, 12, 134, 28, 61, 152, 40, 4, 8, 106, 227, 147]) }), firstWrite := (some { id := { object := { familyTag := 3, commitmentDigest := (bytes [246, 2, 145, 142, 19, 107, 71, 159, 5, 205, 226, 68, 30, 20, 0, 176, 11, 128, 178, 156, 242, 168, 192, 95, 206, 138, 227, 42, 127, 194, 168, 232]), layoutVersion := 1, digest := (bytes [253, 181, 194, 213, 240, 8, 212, 2, 98, 252, 182, 232, 39, 11, 161, 124, 109, 230, 101, 183, 85, 224, 181, 30, 212, 115, 98, 219, 78, 104, 185, 82]) }, logicalIndex := 0, digest := (bytes [104, 215, 89, 1, 197, 19, 15, 210, 67, 229, 6, 83, 177, 247, 79, 245, 254, 140, 233, 222, 96, 134, 218, 27, 123, 196, 82, 213, 67, 134, 48, 148]) }, valueDigest := (bytes [73, 175, 249, 106, 163, 84, 49, 4, 122, 98, 125, 56, 99, 1, 90, 255, 89, 80, 68, 237, 88, 57, 187, 224, 2, 195, 250, 214, 36, 107, 236, 89]), digest := (bytes [115, 50, 33, 92, 255, 24, 51, 189, 8, 73, 172, 242, 192, 186, 162, 35, 58, 31, 186, 200, 61, 161, 29, 180, 131, 97, 142, 135, 105, 21, 21, 141]) }), lastWrite := (some { id := { object := { familyTag := 3, commitmentDigest := (bytes [246, 2, 145, 142, 19, 107, 71, 159, 5, 205, 226, 68, 30, 20, 0, 176, 11, 128, 178, 156, 242, 168, 192, 95, 206, 138, 227, 42, 127, 194, 168, 232]), layoutVersion := 1, digest := (bytes [253, 181, 194, 213, 240, 8, 212, 2, 98, 252, 182, 232, 39, 11, 161, 124, 109, 230, 101, 183, 85, 224, 181, 30, 212, 115, 98, 219, 78, 104, 185, 82]) }, logicalIndex := 1, digest := (bytes [248, 189, 249, 94, 193, 93, 239, 71, 26, 180, 196, 161, 121, 253, 180, 30, 233, 237, 140, 28, 166, 28, 20, 255, 201, 134, 10, 28, 200, 192, 139, 149]) }, valueDigest := (bytes [219, 157, 144, 2, 32, 103, 22, 163, 10, 232, 209, 222, 151, 26, 83, 50, 34, 204, 238, 236, 243, 105, 193, 200, 130, 129, 94, 186, 152, 13, 104, 117]), digest := (bytes [189, 121, 75, 241, 102, 219, 43, 75, 29, 213, 157, 38, 197, 41, 172, 123, 106, 1, 177, 71, 68, 25, 84, 38, 240, 102, 252, 228, 60, 79, 154, 147]) }), firstRam := none, lastRam := none, firstTwist := (some { id := { object := { familyTag := 5, commitmentDigest := (bytes [126, 253, 239, 201, 40, 20, 251, 133, 94, 214, 195, 23, 49, 133, 28, 24, 151, 146, 57, 31, 138, 82, 185, 70, 29, 177, 220, 173, 117, 112, 96, 214]), layoutVersion := 1, digest := (bytes [44, 160, 81, 172, 171, 72, 244, 88, 106, 168, 123, 159, 70, 42, 58, 5, 29, 39, 114, 64, 3, 10, 81, 144, 200, 146, 184, 183, 181, 255, 87, 167]) }, logicalIndex := 0, digest := (bytes [21, 202, 111, 201, 33, 106, 203, 186, 135, 47, 185, 44, 209, 232, 238, 238, 28, 154, 151, 203, 119, 32, 183, 101, 144, 122, 129, 6, 233, 237, 45, 3]) }, valueDigest := (bytes [152, 210, 9, 226, 48, 227, 125, 163, 175, 47, 209, 131, 157, 49, 214, 35, 77, 147, 136, 211, 94, 27, 18, 44, 164, 188, 250, 227, 46, 121, 208, 238]), digest := (bytes [81, 67, 192, 250, 255, 217, 243, 105, 164, 13, 86, 249, 188, 26, 207, 80, 182, 147, 70, 122, 9, 222, 212, 78, 169, 111, 41, 47, 140, 164, 3, 158]) }), lastTwist := (some { id := { object := { familyTag := 5, commitmentDigest := (bytes [126, 253, 239, 201, 40, 20, 251, 133, 94, 214, 195, 23, 49, 133, 28, 24, 151, 146, 57, 31, 138, 82, 185, 70, 29, 177, 220, 173, 117, 112, 96, 214]), layoutVersion := 1, digest := (bytes [44, 160, 81, 172, 171, 72, 244, 88, 106, 168, 123, 159, 70, 42, 58, 5, 29, 39, 114, 64, 3, 10, 81, 144, 200, 146, 184, 183, 181, 255, 87, 167]) }, logicalIndex := 3, digest := (bytes [14, 177, 61, 240, 226, 1, 190, 205, 67, 239, 116, 254, 178, 1, 200, 252, 248, 153, 238, 79, 166, 156, 219, 180, 45, 229, 87, 182, 254, 5, 153, 220]) }, valueDigest := (bytes [192, 220, 106, 41, 104, 255, 230, 149, 225, 60, 106, 47, 173, 175, 166, 9, 41, 27, 129, 156, 118, 121, 84, 121, 134, 180, 118, 205, 49, 136, 155, 48]), digest := (bytes [52, 206, 109, 248, 106, 5, 58, 146, 197, 96, 35, 61, 127, 35, 170, 51, 69, 133, 45, 180, 35, 246, 230, 9, 79, 173, 63, 160, 83, 112, 128, 148]) }) }, digest := (bytes [169, 5, 5, 129, 43, 6, 141, 36, 202, 104, 120, 250, 248, 191, 207, 71, 153, 162, 129, 102, 62, 252, 136, 107, 200, 93, 103, 198, 123, 57, 8, 47]) }, packaged := { statementDigest := (bytes [42, 223, 176, 52, 30, 31, 71, 218, 251, 20, 44, 159, 182, 199, 149, 2, 57, 74, 235, 32, 171, 130, 156, 255, 136, 246, 35, 68, 253, 172, 69, 150]), proofDigest := (bytes [177, 8, 15, 164, 152, 143, 129, 77, 25, 44, 50, 126, 53, 246, 78, 184, 217, 77, 34, 60, 158, 1, 19, 128, 183, 136, 168, 197, 83, 43, 214, 185]) }, digest := (bytes [164, 191, 220, 178, 15, 86, 66, 181, 212, 191, 196, 106, 218, 239, 88, 61, 29, 136, 37, 196, 125, 237, 155, 97, 22, 137, 176, 135, 114, 113, 25, 60]) }
    , digest := (bytes [51, 182, 153, 1, 191, 97, 188, 170, 159, 59, 24, 161, 77, 230, 191, 254, 103, 141, 213, 120, 247, 29, 175, 212, 211, 117, 107, 82, 136, 159, 56, 101])
  }

def stage3Continuity : List ContinuityEventView :=
  [{ stepIndex := 0, pc := 0, nextPc := 4, successorPc := (some 4), finalStep := false, continuityHolds := true }, { stepIndex := 1, pc := 4, nextPc := 8, successorPc := (some 8), finalStep := false, continuityHolds := true }, { stepIndex := 2, pc := 8, nextPc := 16, successorPc := (some 16), finalStep := false, continuityHolds := true }, { stepIndex := 3, pc := 16, nextPc := 20, successorPc := none, finalStep := true, continuityHolds := true }]

def stage3 : Stage3ProofBundleView :=
  {
    continuity := stage3Continuity
    , halted := true
    , bridgeDigest := (bytes [91, 155, 151, 36, 255, 29, 65, 219, 97, 184, 149, 17, 61, 71, 65, 67, 235, 95, 174, 182, 147, 224, 135, 172, 219, 41, 164, 217, 0, 115, 255, 45])
    , semantics := { continuityDigest := (bytes [225, 36, 55, 237, 16, 70, 173, 226, 205, 215, 188, 143, 132, 20, 5, 220, 229, 9, 111, 156, 132, 73, 165, 86, 137, 203, 45, 225, 35, 181, 205, 156]), rootSemanticRowsDigest := (bytes [92, 237, 5, 115, 219, 161, 32, 14, 155, 47, 135, 159, 234, 67, 34, 27, 252, 186, 151, 230, 156, 136, 22, 219, 82, 59, 180, 195, 110, 84, 142, 216]), rowChunkRoutesDigest := (bytes [170, 16, 215, 245, 131, 192, 198, 120, 95, 134, 175, 93, 217, 74, 16, 26, 237, 138, 81, 110, 201, 10, 195, 254, 244, 178, 29, 18, 146, 128, 117, 178]), preparedStepBindingsDigest := (bytes [192, 157, 158, 171, 197, 63, 89, 130, 230, 100, 158, 40, 68, 19, 46, 243, 113, 18, 177, 19, 199, 36, 170, 141, 156, 102, 61, 205, 113, 170, 102, 192]), stage2TemporalDigest := (bytes [12, 74, 240, 171, 75, 109, 160, 232, 176, 4, 19, 98, 228, 45, 67, 132, 184, 13, 209, 40, 81, 25, 115, 6, 148, 54, 247, 102, 241, 145, 216, 95]), initialPc := 0, finalPc := 20, realRowCount := 4, firstRealStepIndex := 0, lastRealStepIndex := 3, digest := (bytes [20, 3, 200, 134, 137, 220, 58, 216, 31, 224, 139, 111, 18, 67, 121, 173, 112, 90, 144, 103, 17, 101, 46, 72, 19, 160, 90, 31, 93, 255, 229, 137]) }
    , linkageDigest := (bytes [208, 83, 111, 122, 106, 83, 98, 237, 111, 51, 226, 154, 117, 27, 31, 17, 187, 87, 190, 14, 124, 233, 91, 5, 133, 159, 175, 26, 194, 128, 147, 150])
    , selectedOpening := { claim := { continuityFamilyDigest := (bytes [178, 177, 3, 134, 28, 140, 16, 149, 40, 220, 221, 198, 83, 202, 237, 105, 228, 80, 184, 187, 23, 255, 100, 66, 229, 141, 99, 228, 121, 52, 39, 88]), continuityCount := 4, finalStepCount := 1, halted := true, allContinuityHold := true, continuityMix := 7080673056785947620, points := { firstContinuity := (some { id := { object := { familyTag := 6, commitmentDigest := (bytes [178, 177, 3, 134, 28, 140, 16, 149, 40, 220, 221, 198, 83, 202, 237, 105, 228, 80, 184, 187, 23, 255, 100, 66, 229, 141, 99, 228, 121, 52, 39, 88]), layoutVersion := 1, digest := (bytes [236, 90, 105, 33, 46, 31, 185, 17, 37, 216, 190, 237, 8, 199, 200, 149, 254, 224, 190, 206, 223, 121, 110, 130, 238, 225, 162, 254, 31, 249, 173, 150]) }, logicalIndex := 0, digest := (bytes [36, 4, 204, 3, 12, 51, 32, 211, 254, 81, 204, 224, 109, 243, 139, 63, 6, 61, 51, 231, 182, 115, 199, 54, 57, 226, 50, 162, 160, 40, 253, 38]) }, valueDigest := (bytes [7, 131, 85, 21, 57, 109, 53, 31, 137, 53, 98, 18, 170, 36, 28, 200, 149, 213, 171, 159, 119, 200, 36, 230, 30, 35, 30, 11, 252, 126, 240, 63]), digest := (bytes [159, 221, 198, 197, 117, 106, 171, 81, 126, 42, 45, 192, 53, 222, 104, 114, 206, 226, 149, 147, 249, 97, 130, 60, 203, 233, 175, 235, 13, 126, 42, 204]) }), lastContinuity := (some { id := { object := { familyTag := 6, commitmentDigest := (bytes [178, 177, 3, 134, 28, 140, 16, 149, 40, 220, 221, 198, 83, 202, 237, 105, 228, 80, 184, 187, 23, 255, 100, 66, 229, 141, 99, 228, 121, 52, 39, 88]), layoutVersion := 1, digest := (bytes [236, 90, 105, 33, 46, 31, 185, 17, 37, 216, 190, 237, 8, 199, 200, 149, 254, 224, 190, 206, 223, 121, 110, 130, 238, 225, 162, 254, 31, 249, 173, 150]) }, logicalIndex := 3, digest := (bytes [185, 131, 50, 144, 41, 2, 89, 43, 206, 251, 1, 1, 71, 14, 103, 59, 244, 113, 72, 157, 221, 62, 96, 81, 169, 115, 86, 73, 16, 35, 0, 164]) }, valueDigest := (bytes [252, 134, 254, 33, 173, 19, 91, 16, 165, 37, 97, 183, 229, 243, 58, 241, 249, 218, 169, 205, 3, 229, 51, 197, 80, 15, 234, 120, 189, 254, 221, 45]), digest := (bytes [7, 151, 236, 244, 72, 147, 236, 219, 52, 132, 206, 18, 122, 251, 235, 250, 29, 51, 30, 67, 170, 84, 135, 7, 20, 212, 173, 168, 155, 255, 130, 67]) }) }, digest := (bytes [2, 38, 119, 43, 156, 168, 148, 229, 62, 143, 151, 244, 165, 132, 246, 46, 147, 108, 27, 52, 58, 252, 80, 65, 223, 2, 1, 203, 59, 250, 219, 108]) }, packaged := { statementDigest := (bytes [207, 222, 228, 40, 21, 195, 159, 135, 36, 228, 132, 179, 1, 90, 254, 245, 141, 183, 197, 84, 235, 120, 81, 212, 202, 75, 255, 176, 163, 143, 168, 8]), proofDigest := (bytes [165, 103, 43, 247, 124, 43, 53, 88, 55, 86, 134, 149, 83, 133, 167, 21, 250, 78, 108, 174, 101, 47, 24, 236, 137, 153, 181, 249, 53, 197, 12, 241]) }, digest := (bytes [219, 79, 76, 23, 16, 156, 135, 61, 31, 134, 135, 16, 225, 146, 125, 59, 4, 56, 137, 89, 215, 205, 155, 245, 214, 170, 53, 2, 224, 13, 36, 12]) }
    , digest := (bytes [213, 14, 246, 25, 25, 53, 8, 187, 161, 23, 28, 82, 195, 206, 165, 202, 164, 117, 165, 197, 96, 100, 178, 126, 135, 176, 246, 205, 1, 29, 79, 31])
  }

def rootExecutionExecutionRows : List ExpandedRowView :=
  [{
  traceIndex := 0
  , stepIndex := 0
  , sequenceIndex := 0
  , pc := 0
  , nextPc := 4
  , word := 4293918867
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
  , rdAfter := 18446744073709551615
  , imm := -1
  , aluResult := 18446744073709551615
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
  , word := 2147427
  , opcode := .blt
  , traceOpcode := (some .blt)
  , traceVirtualOpcode := none
  , family := .controlFlow
  , rs1 := 1
  , rs1Value := 18446744073709551615
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
  [{ traceIndex := 0, values := [1, 0, 0, 4, 0, 0, 0, 0, 0, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [59, 110, 73, 184, 21, 134, 14, 247, 63, 174, 178, 199, 142, 253, 82, 19, 165, 139, 8, 196, 235, 194, 3, 121, 51, 124, 231, 35, 211, 16, 32, 52]), digest := (bytes [149, 139, 19, 34, 118, 90, 19, 4, 52, 25, 83, 142, 194, 138, 57, 197, 246, 189, 203, 198, 215, 227, 168, 97, 227, 226, 140, 68, 186, 83, 202, 182]) }, { traceIndex := 1, values := [1, 4, 0, 8, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 8, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [81, 24, 106, 244, 9, 121, 253, 136, 123, 77, 188, 238, 80, 81, 119, 140, 17, 79, 179, 253, 207, 20, 68, 136, 9, 114, 221, 212, 70, 78, 75, 136]), digest := (bytes [173, 148, 70, 219, 203, 26, 166, 194, 228, 106, 92, 4, 43, 89, 74, 154, 83, 57, 0, 204, 232, 92, 161, 144, 18, 252, 35, 233, 22, 72, 62, 121]) }, { traceIndex := 2, values := [1, 8, 0, 16, 0, 4294967295, 4294967295, 1, 0, 0, 0, 8, 0, 1, 0, 12, 0, 16, 0, 0, 0, 0, 0, 0, 1, 2, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1], rowDigest := (bytes [139, 51, 226, 224, 196, 192, 16, 221, 210, 23, 137, 255, 219, 165, 172, 137, 68, 5, 75, 126, 96, 107, 61, 22, 85, 131, 247, 186, 165, 220, 55, 142]), digest := (bytes [74, 135, 29, 143, 93, 1, 52, 71, 27, 11, 188, 48, 65, 146, 44, 142, 75, 149, 200, 193, 147, 178, 64, 238, 139, 131, 213, 168, 175, 161, 98, 162]) }, { traceIndex := 3, values := [1, 16, 0, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [196, 164, 211, 128, 251, 108, 127, 209, 13, 46, 5, 165, 45, 208, 166, 224, 83, 53, 211, 10, 49, 76, 179, 158, 125, 185, 30, 27, 57, 200, 134, 221]) }]

def rootExecutionPreparedBindings : List PreparedStepBindingView :=
  [{ traceIndex := 0, rowDigest := (bytes [59, 110, 73, 184, 21, 134, 14, 247, 63, 174, 178, 199, 142, 253, 82, 19, 165, 139, 8, 196, 235, 194, 3, 121, 51, 124, 231, 35, 211, 16, 32, 52]), rowOpeningDigest := (bytes [226, 218, 13, 4, 55, 80, 197, 195, 76, 108, 24, 197, 233, 230, 155, 103, 218, 151, 128, 91, 234, 235, 98, 162, 237, 158, 247, 170, 217, 3, 134, 70]), digest := (bytes [25, 11, 217, 92, 88, 160, 212, 211, 136, 141, 82, 184, 177, 46, 81, 157, 179, 159, 135, 132, 224, 119, 249, 41, 240, 241, 220, 197, 133, 119, 124, 255]) }, { traceIndex := 1, rowDigest := (bytes [81, 24, 106, 244, 9, 121, 253, 136, 123, 77, 188, 238, 80, 81, 119, 140, 17, 79, 179, 253, 207, 20, 68, 136, 9, 114, 221, 212, 70, 78, 75, 136]), rowOpeningDigest := (bytes [214, 199, 198, 191, 175, 192, 248, 183, 87, 53, 96, 254, 224, 161, 227, 55, 156, 152, 66, 118, 61, 152, 224, 24, 125, 181, 246, 208, 57, 254, 98, 9]), digest := (bytes [100, 80, 252, 35, 52, 2, 184, 171, 227, 139, 65, 171, 18, 244, 55, 30, 193, 143, 58, 120, 221, 8, 162, 11, 76, 11, 120, 84, 13, 255, 76, 11]) }, { traceIndex := 2, rowDigest := (bytes [139, 51, 226, 224, 196, 192, 16, 221, 210, 23, 137, 255, 219, 165, 172, 137, 68, 5, 75, 126, 96, 107, 61, 22, 85, 131, 247, 186, 165, 220, 55, 142]), rowOpeningDigest := (bytes [72, 4, 252, 54, 178, 14, 58, 93, 123, 52, 93, 153, 38, 207, 166, 148, 149, 76, 122, 14, 146, 89, 21, 37, 100, 10, 28, 7, 83, 206, 206, 73]), digest := (bytes [110, 170, 160, 42, 61, 233, 20, 241, 120, 198, 245, 3, 78, 58, 133, 87, 49, 7, 128, 247, 207, 129, 231, 50, 104, 181, 162, 40, 22, 50, 201, 92]) }, { traceIndex := 3, rowDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), rowOpeningDigest := (bytes [39, 255, 14, 211, 207, 209, 24, 34, 167, 228, 216, 123, 174, 173, 128, 46, 62, 57, 217, 213, 2, 205, 57, 34, 161, 52, 77, 9, 243, 115, 76, 211]), digest := (bytes [254, 99, 83, 87, 142, 13, 25, 128, 17, 223, 67, 18, 69, 171, 237, 57, 247, 99, 239, 18, 152, 182, 82, 245, 246, 112, 106, 248, 5, 254, 200, 205]) }]

def rootExecutionRowChunkRoutes : List RowChunkRouteView :=
  [{ logicalIndex := 0, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 0, digest := (bytes [138, 198, 109, 126, 144, 82, 221, 43, 248, 202, 137, 103, 62, 226, 249, 152, 163, 187, 1, 254, 36, 33, 59, 16, 64, 166, 202, 8, 219, 57, 240, 59]) }, { logicalIndex := 1, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 1, digest := (bytes [44, 177, 82, 41, 218, 60, 100, 208, 26, 31, 151, 113, 109, 148, 57, 12, 223, 21, 76, 221, 70, 245, 191, 105, 57, 199, 8, 128, 181, 145, 89, 99]) }, { logicalIndex := 2, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 2, digest := (bytes [252, 248, 65, 24, 81, 241, 150, 170, 250, 116, 222, 30, 134, 191, 78, 195, 104, 119, 225, 210, 243, 186, 212, 107, 183, 31, 243, 201, 101, 148, 32, 72]) }, { logicalIndex := 3, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 3, digest := (bytes [244, 11, 162, 13, 59, 43, 232, 47, 228, 2, 70, 126, 95, 10, 57, 40, 46, 107, 197, 81, 97, 39, 185, 163, 93, 60, 5, 66, 7, 231, 199, 134]) }]

def rootExecutionRowLocalCcsAcceptance : List RootRowLocalCcsAcceptanceView :=
  [{ traceIndex := 0, logicalIndex := 0, rowDigest := (bytes [59, 110, 73, 184, 21, 134, 14, 247, 63, 174, 178, 199, 142, 253, 82, 19, 165, 139, 8, 196, 235, 194, 3, 121, 51, 124, 231, 35, 211, 16, 32, 52]), rowOpeningDigest := (bytes [226, 218, 13, 4, 55, 80, 197, 195, 76, 108, 24, 197, 233, 230, 155, 103, 218, 151, 128, 91, 234, 235, 98, 162, 237, 158, 247, 170, 217, 3, 134, 70]), preparedStepBindingDigest := (bytes [25, 11, 217, 92, 88, 160, 212, 211, 136, 141, 82, 184, 177, 46, 81, 157, 179, 159, 135, 132, 224, 119, 249, 41, 240, 241, 220, 197, 133, 119, 124, 255]), rowChunkRouteDigest := (bytes [138, 198, 109, 126, 144, 82, 221, 43, 248, 202, 137, 103, 62, 226, 249, 152, 163, 187, 1, 254, 36, 33, 59, 16, 64, 166, 202, 8, 219, 57, 240, 59]), publicStepDigest := (bytes [23, 18, 247, 230, 186, 1, 79, 67, 192, 72, 168, 22, 247, 81, 178, 236, 130, 231, 105, 186, 196, 204, 4, 183, 1, 21, 11, 161, 179, 66, 54, 0]), digest := (bytes [204, 238, 86, 143, 154, 109, 16, 80, 4, 85, 161, 196, 14, 242, 253, 10, 28, 106, 181, 246, 243, 144, 60, 139, 140, 16, 254, 209, 153, 24, 169, 86]) }, { traceIndex := 1, logicalIndex := 1, rowDigest := (bytes [81, 24, 106, 244, 9, 121, 253, 136, 123, 77, 188, 238, 80, 81, 119, 140, 17, 79, 179, 253, 207, 20, 68, 136, 9, 114, 221, 212, 70, 78, 75, 136]), rowOpeningDigest := (bytes [214, 199, 198, 191, 175, 192, 248, 183, 87, 53, 96, 254, 224, 161, 227, 55, 156, 152, 66, 118, 61, 152, 224, 24, 125, 181, 246, 208, 57, 254, 98, 9]), preparedStepBindingDigest := (bytes [100, 80, 252, 35, 52, 2, 184, 171, 227, 139, 65, 171, 18, 244, 55, 30, 193, 143, 58, 120, 221, 8, 162, 11, 76, 11, 120, 84, 13, 255, 76, 11]), rowChunkRouteDigest := (bytes [44, 177, 82, 41, 218, 60, 100, 208, 26, 31, 151, 113, 109, 148, 57, 12, 223, 21, 76, 221, 70, 245, 191, 105, 57, 199, 8, 128, 181, 145, 89, 99]), publicStepDigest := (bytes [139, 105, 238, 217, 75, 237, 252, 214, 128, 167, 136, 142, 206, 95, 123, 134, 61, 233, 191, 24, 127, 249, 138, 93, 109, 174, 8, 134, 131, 163, 164, 79]), digest := (bytes [106, 11, 201, 148, 78, 163, 128, 226, 118, 194, 50, 141, 186, 230, 90, 126, 120, 80, 128, 161, 110, 3, 174, 255, 85, 32, 56, 209, 227, 169, 23, 247]) }, { traceIndex := 2, logicalIndex := 2, rowDigest := (bytes [139, 51, 226, 224, 196, 192, 16, 221, 210, 23, 137, 255, 219, 165, 172, 137, 68, 5, 75, 126, 96, 107, 61, 22, 85, 131, 247, 186, 165, 220, 55, 142]), rowOpeningDigest := (bytes [72, 4, 252, 54, 178, 14, 58, 93, 123, 52, 93, 153, 38, 207, 166, 148, 149, 76, 122, 14, 146, 89, 21, 37, 100, 10, 28, 7, 83, 206, 206, 73]), preparedStepBindingDigest := (bytes [110, 170, 160, 42, 61, 233, 20, 241, 120, 198, 245, 3, 78, 58, 133, 87, 49, 7, 128, 247, 207, 129, 231, 50, 104, 181, 162, 40, 22, 50, 201, 92]), rowChunkRouteDigest := (bytes [252, 248, 65, 24, 81, 241, 150, 170, 250, 116, 222, 30, 134, 191, 78, 195, 104, 119, 225, 210, 243, 186, 212, 107, 183, 31, 243, 201, 101, 148, 32, 72]), publicStepDigest := (bytes [92, 73, 68, 3, 83, 174, 252, 205, 143, 84, 70, 141, 173, 9, 171, 3, 159, 217, 128, 133, 18, 46, 123, 27, 85, 176, 98, 193, 73, 21, 152, 10]), digest := (bytes [165, 36, 162, 94, 154, 252, 231, 70, 210, 37, 29, 225, 240, 240, 200, 10, 164, 188, 157, 80, 150, 33, 240, 212, 163, 66, 250, 133, 24, 235, 139, 98]) }, { traceIndex := 3, logicalIndex := 3, rowDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), rowOpeningDigest := (bytes [39, 255, 14, 211, 207, 209, 24, 34, 167, 228, 216, 123, 174, 173, 128, 46, 62, 57, 217, 213, 2, 205, 57, 34, 161, 52, 77, 9, 243, 115, 76, 211]), preparedStepBindingDigest := (bytes [254, 99, 83, 87, 142, 13, 25, 128, 17, 223, 67, 18, 69, 171, 237, 57, 247, 99, 239, 18, 152, 182, 82, 245, 246, 112, 106, 248, 5, 254, 200, 205]), rowChunkRouteDigest := (bytes [244, 11, 162, 13, 59, 43, 232, 47, 228, 2, 70, 126, 95, 10, 57, 40, 46, 107, 197, 81, 97, 39, 185, 163, 93, 60, 5, 66, 7, 231, 199, 134]), publicStepDigest := (bytes [72, 142, 192, 218, 173, 197, 55, 221, 78, 31, 126, 194, 22, 139, 72, 204, 128, 208, 103, 242, 122, 221, 175, 246, 50, 244, 221, 89, 210, 23, 111, 183]), digest := (bytes [18, 100, 96, 216, 132, 190, 45, 211, 253, 136, 152, 208, 54, 64, 236, 52, 229, 131, 140, 24, 189, 116, 226, 43, 182, 101, 112, 166, 19, 97, 160, 231]) }]

def rootExecutionExecutionSemanticsRefinement : List RootExecutionSemanticsRefinementView :=
  [{ traceIndex := 0, logicalIndex := 0, semanticRowDigest := (bytes [149, 139, 19, 34, 118, 90, 19, 4, 52, 25, 83, 142, 194, 138, 57, 197, 246, 189, 203, 198, 215, 227, 168, 97, 227, 226, 140, 68, 186, 83, 202, 182]), rowLocalCcsAcceptanceDigest := (bytes [204, 238, 86, 143, 154, 109, 16, 80, 4, 85, 161, 196, 14, 242, 253, 10, 28, 106, 181, 246, 243, 144, 60, 139, 140, 16, 254, 209, 153, 24, 169, 86]), preparedStepBindingDigest := (bytes [25, 11, 217, 92, 88, 160, 212, 211, 136, 141, 82, 184, 177, 46, 81, 157, 179, 159, 135, 132, 224, 119, 249, 41, 240, 241, 220, 197, 133, 119, 124, 255]), publicStepDigest := (bytes [23, 18, 247, 230, 186, 1, 79, 67, 192, 72, 168, 22, 247, 81, 178, 236, 130, 231, 105, 186, 196, 204, 4, 183, 1, 21, 11, 161, 179, 66, 54, 0]), digest := (bytes [8, 46, 111, 44, 35, 71, 37, 20, 200, 143, 63, 192, 184, 154, 239, 225, 222, 185, 120, 161, 159, 50, 248, 71, 77, 19, 121, 77, 165, 74, 115, 92]) }, { traceIndex := 1, logicalIndex := 1, semanticRowDigest := (bytes [173, 148, 70, 219, 203, 26, 166, 194, 228, 106, 92, 4, 43, 89, 74, 154, 83, 57, 0, 204, 232, 92, 161, 144, 18, 252, 35, 233, 22, 72, 62, 121]), rowLocalCcsAcceptanceDigest := (bytes [106, 11, 201, 148, 78, 163, 128, 226, 118, 194, 50, 141, 186, 230, 90, 126, 120, 80, 128, 161, 110, 3, 174, 255, 85, 32, 56, 209, 227, 169, 23, 247]), preparedStepBindingDigest := (bytes [100, 80, 252, 35, 52, 2, 184, 171, 227, 139, 65, 171, 18, 244, 55, 30, 193, 143, 58, 120, 221, 8, 162, 11, 76, 11, 120, 84, 13, 255, 76, 11]), publicStepDigest := (bytes [139, 105, 238, 217, 75, 237, 252, 214, 128, 167, 136, 142, 206, 95, 123, 134, 61, 233, 191, 24, 127, 249, 138, 93, 109, 174, 8, 134, 131, 163, 164, 79]), digest := (bytes [150, 167, 32, 64, 179, 175, 237, 139, 159, 253, 116, 204, 110, 186, 176, 137, 253, 66, 45, 107, 167, 25, 60, 192, 121, 243, 50, 170, 54, 176, 31, 100]) }, { traceIndex := 2, logicalIndex := 2, semanticRowDigest := (bytes [74, 135, 29, 143, 93, 1, 52, 71, 27, 11, 188, 48, 65, 146, 44, 142, 75, 149, 200, 193, 147, 178, 64, 238, 139, 131, 213, 168, 175, 161, 98, 162]), rowLocalCcsAcceptanceDigest := (bytes [165, 36, 162, 94, 154, 252, 231, 70, 210, 37, 29, 225, 240, 240, 200, 10, 164, 188, 157, 80, 150, 33, 240, 212, 163, 66, 250, 133, 24, 235, 139, 98]), preparedStepBindingDigest := (bytes [110, 170, 160, 42, 61, 233, 20, 241, 120, 198, 245, 3, 78, 58, 133, 87, 49, 7, 128, 247, 207, 129, 231, 50, 104, 181, 162, 40, 22, 50, 201, 92]), publicStepDigest := (bytes [92, 73, 68, 3, 83, 174, 252, 205, 143, 84, 70, 141, 173, 9, 171, 3, 159, 217, 128, 133, 18, 46, 123, 27, 85, 176, 98, 193, 73, 21, 152, 10]), digest := (bytes [11, 183, 48, 233, 190, 183, 154, 247, 59, 59, 254, 176, 36, 34, 91, 156, 154, 111, 24, 204, 48, 140, 106, 215, 88, 172, 99, 187, 83, 95, 7, 211]) }, { traceIndex := 3, logicalIndex := 3, semanticRowDigest := (bytes [196, 164, 211, 128, 251, 108, 127, 209, 13, 46, 5, 165, 45, 208, 166, 224, 83, 53, 211, 10, 49, 76, 179, 158, 125, 185, 30, 27, 57, 200, 134, 221]), rowLocalCcsAcceptanceDigest := (bytes [18, 100, 96, 216, 132, 190, 45, 211, 253, 136, 152, 208, 54, 64, 236, 52, 229, 131, 140, 24, 189, 116, 226, 43, 182, 101, 112, 166, 19, 97, 160, 231]), preparedStepBindingDigest := (bytes [254, 99, 83, 87, 142, 13, 25, 128, 17, 223, 67, 18, 69, 171, 237, 57, 247, 99, 239, 18, 152, 182, 82, 245, 246, 112, 106, 248, 5, 254, 200, 205]), publicStepDigest := (bytes [72, 142, 192, 218, 173, 197, 55, 221, 78, 31, 126, 194, 22, 139, 72, 204, 128, 208, 103, 242, 122, 221, 175, 246, 50, 244, 221, 89, 210, 23, 111, 183]), digest := (bytes [95, 94, 88, 187, 7, 165, 90, 170, 116, 197, 55, 114, 174, 126, 144, 218, 60, 25, 130, 178, 72, 149, 64, 57, 33, 254, 98, 120, 93, 89, 254, 223]) }]

def rootExecution : RootExecutionBundleView :=
  {
    executionRows := rootExecutionExecutionRows
    , semanticRows := rootExecutionSemanticRows
    , semanticRowsDigest := (bytes [92, 237, 5, 115, 219, 161, 32, 14, 155, 47, 135, 159, 234, 67, 34, 27, 252, 186, 151, 230, 156, 136, 22, 219, 82, 59, 180, 195, 110, 84, 142, 216])
    , preparedStepBindings := { bindings := rootExecutionPreparedBindings, bindingCount := 4, firstBindingDigest := (some (bytes [25, 11, 217, 92, 88, 160, 212, 211, 136, 141, 82, 184, 177, 46, 81, 157, 179, 159, 135, 132, 224, 119, 249, 41, 240, 241, 220, 197, 133, 119, 124, 255])), lastBindingDigest := (some (bytes [254, 99, 83, 87, 142, 13, 25, 128, 17, 223, 67, 18, 69, 171, 237, 57, 247, 99, 239, 18, 152, 182, 82, 245, 246, 112, 106, 248, 5, 254, 200, 205])), digest := (bytes [192, 157, 158, 171, 197, 63, 89, 130, 230, 100, 158, 40, 68, 19, 46, 243, 113, 18, 177, 19, 199, 36, 170, 141, 156, 102, 61, 205, 113, 170, 102, 192]) }
    , rowChunkRoutes := rootExecutionRowChunkRoutes
    , rowChunkRoutesDigest := (bytes [170, 16, 215, 245, 131, 192, 198, 120, 95, 134, 175, 93, 217, 74, 16, 26, 237, 138, 81, 110, 201, 10, 195, 254, 244, 178, 29, 18, 146, 128, 117, 178])
    , rowLocalCcsAcceptance := { acceptances := rootExecutionRowLocalCcsAcceptance, acceptanceCount := 4, firstAcceptanceDigest := (some (bytes [204, 238, 86, 143, 154, 109, 16, 80, 4, 85, 161, 196, 14, 242, 253, 10, 28, 106, 181, 246, 243, 144, 60, 139, 140, 16, 254, 209, 153, 24, 169, 86])), lastAcceptanceDigest := (some (bytes [18, 100, 96, 216, 132, 190, 45, 211, 253, 136, 152, 208, 54, 64, 236, 52, 229, 131, 140, 24, 189, 116, 226, 43, 182, 101, 112, 166, 19, 97, 160, 231])), digest := (bytes [230, 18, 198, 109, 213, 140, 145, 70, 189, 164, 93, 207, 88, 42, 117, 130, 42, 221, 111, 46, 209, 226, 74, 210, 153, 28, 103, 216, 96, 211, 97, 226]) }
    , executionSemanticsRefinement := { refinements := rootExecutionExecutionSemanticsRefinement, refinementCount := 4, firstRefinementDigest := (some (bytes [8, 46, 111, 44, 35, 71, 37, 20, 200, 143, 63, 192, 184, 154, 239, 225, 222, 185, 120, 161, 159, 50, 248, 71, 77, 19, 121, 77, 165, 74, 115, 92])), lastRefinementDigest := (some (bytes [95, 94, 88, 187, 7, 165, 90, 170, 116, 197, 55, 114, 174, 126, 144, 218, 60, 25, 130, 178, 72, 149, 64, 57, 33, 254, 98, 120, 93, 89, 254, 223])), digest := (bytes [72, 127, 92, 16, 73, 22, 243, 121, 23, 45, 21, 10, 180, 86, 54, 3, 2, 149, 228, 161, 19, 223, 123, 47, 15, 94, 124, 219, 136, 231, 253, 2]) }
    , familyDigest := (bytes [17, 200, 31, 62, 49, 172, 250, 37, 145, 105, 53, 203, 246, 118, 11, 102, 130, 27, 67, 62, 33, 190, 100, 19, 43, 89, 155, 192, 93, 125, 221, 76])
    , digest := (bytes [43, 45, 61, 151, 187, 185, 175, 206, 232, 164, 23, 161, 229, 101, 195, 80, 13, 235, 108, 134, 95, 96, 114, 183, 59, 223, 83, 57, 20, 38, 172, 86])
  }

def kernelOpeningBundle : SimpleKernelOpeningBundleView :=
  {
    claim := { bindings := { stageClaimBundleDigest := (bytes [248, 254, 33, 79, 113, 110, 5, 131, 204, 190, 95, 176, 46, 168, 149, 63, 53, 198, 2, 181, 193, 80, 124, 176, 56, 122, 52, 16, 13, 153, 177, 246]), stagePackageBundleDigest := (bytes [1, 150, 13, 248, 98, 208, 148, 74, 34, 80, 169, 225, 228, 184, 163, 211, 239, 161, 173, 168, 210, 66, 122, 140, 174, 10, 147, 76, 184, 141, 166, 186]), stage1PackageDigest := (bytes [9, 211, 167, 148, 204, 209, 99, 130, 11, 103, 22, 106, 135, 209, 58, 212, 168, 170, 233, 94, 97, 173, 34, 173, 80, 5, 232, 148, 135, 61, 64, 211]), stage2PackageDigest := (bytes [164, 191, 220, 178, 15, 86, 66, 181, 212, 191, 196, 106, 218, 239, 88, 61, 29, 136, 37, 196, 125, 237, 155, 97, 22, 137, 176, 135, 114, 113, 25, 60]), stage3PackageDigest := (bytes [219, 79, 76, 23, 16, 156, 135, 61, 31, 134, 135, 16, 225, 146, 125, 59, 4, 56, 137, 89, 215, 205, 155, 245, 214, 170, 53, 2, 224, 13, 36, 12]), preparedStepBindingsDigest := (bytes [192, 157, 158, 171, 197, 63, 89, 130, 230, 100, 158, 40, 68, 19, 46, 243, 113, 18, 177, 19, 199, 36, 170, 141, 156, 102, 61, 205, 113, 170, 102, 192]), bindingCount := 4, stage1RowCount := 4, stage2RegisterReadCount := 4, stage2RegisterWriteCount := 2, stage2RamEventCount := 0, stage3ContinuityCount := 4, points := { firstBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [192, 157, 158, 171, 197, 63, 89, 130, 230, 100, 158, 40, 68, 19, 46, 243, 113, 18, 177, 19, 199, 36, 170, 141, 156, 102, 61, 205, 113, 170, 102, 192]), layoutVersion := 1, digest := (bytes [137, 32, 252, 35, 252, 91, 31, 147, 208, 223, 196, 99, 96, 69, 159, 237, 249, 166, 239, 18, 90, 47, 102, 12, 148, 255, 12, 230, 169, 239, 163, 139]) }, logicalIndex := 0, digest := (bytes [137, 68, 25, 226, 18, 38, 171, 191, 208, 213, 86, 17, 121, 132, 209, 227, 87, 25, 33, 58, 74, 67, 51, 114, 95, 42, 217, 210, 40, 171, 224, 137]) }, valueDigest := (bytes [25, 11, 217, 92, 88, 160, 212, 211, 136, 141, 82, 184, 177, 46, 81, 157, 179, 159, 135, 132, 224, 119, 249, 41, 240, 241, 220, 197, 133, 119, 124, 255]), digest := (bytes [195, 105, 217, 16, 96, 33, 143, 151, 251, 153, 164, 206, 90, 24, 186, 19, 104, 81, 160, 231, 121, 222, 59, 249, 41, 98, 198, 87, 127, 230, 241, 100]) }), lastBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [192, 157, 158, 171, 197, 63, 89, 130, 230, 100, 158, 40, 68, 19, 46, 243, 113, 18, 177, 19, 199, 36, 170, 141, 156, 102, 61, 205, 113, 170, 102, 192]), layoutVersion := 1, digest := (bytes [137, 32, 252, 35, 252, 91, 31, 147, 208, 223, 196, 99, 96, 69, 159, 237, 249, 166, 239, 18, 90, 47, 102, 12, 148, 255, 12, 230, 169, 239, 163, 139]) }, logicalIndex := 3, digest := (bytes [209, 99, 134, 178, 199, 137, 133, 171, 141, 66, 221, 72, 174, 221, 219, 0, 215, 45, 130, 71, 21, 112, 189, 185, 11, 110, 26, 125, 80, 243, 129, 5]) }, valueDigest := (bytes [254, 99, 83, 87, 142, 13, 25, 128, 17, 223, 67, 18, 69, 171, 237, 57, 247, 99, 239, 18, 152, 182, 82, 245, 246, 112, 106, 248, 5, 254, 200, 205]), digest := (bytes [75, 5, 158, 5, 205, 127, 194, 84, 198, 232, 230, 114, 173, 222, 220, 142, 96, 36, 170, 217, 5, 246, 152, 179, 218, 48, 180, 102, 85, 93, 101, 252]) }) }, digest := (bytes [222, 138, 13, 223, 179, 207, 135, 68, 181, 36, 93, 208, 109, 117, 44, 56, 110, 168, 72, 148, 184, 87, 198, 73, 194, 117, 173, 22, 163, 132, 54, 150]) }, preparedSteps := { executionDigest := (bytes [46, 32, 12, 1, 169, 11, 60, 230, 125, 5, 123, 127, 177, 78, 153, 53, 25, 114, 127, 17, 26, 141, 196, 196, 80, 189, 184, 59, 120, 244, 188, 221]), finalStateDigest := (bytes [103, 119, 166, 83, 71, 235, 116, 157, 66, 6, 65, 91, 76, 196, 146, 226, 246, 68, 215, 2, 4, 30, 194, 108, 206, 35, 183, 164, 172, 191, 117, 48]), transcriptFinalDigest := (bytes [119, 7, 167, 196, 130, 246, 97, 117, 147, 54, 106, 251, 40, 15, 103, 100, 22, 139, 124, 178, 121, 36, 93, 139, 80, 196, 5, 66, 86, 204, 216, 62]), preparedStepCount := 4, finalPc := 20, halted := true, points := { firstPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [116, 93, 153, 130, 232, 216, 210, 83, 127, 32, 104, 122, 68, 45, 119, 16, 13, 205, 151, 193, 226, 131, 66, 171, 100, 131, 124, 207, 194, 84, 69, 216]), layoutVersion := 3, digest := (bytes [206, 160, 212, 132, 68, 145, 205, 36, 65, 72, 189, 84, 106, 232, 12, 218, 83, 49, 212, 75, 8, 104, 8, 151, 141, 222, 235, 221, 213, 211, 202, 152]) }, logicalIndex := 0, digest := (bytes [14, 92, 10, 244, 78, 56, 77, 247, 46, 29, 154, 26, 176, 243, 170, 204, 158, 255, 34, 89, 33, 167, 78, 81, 90, 132, 32, 174, 4, 30, 129, 198]) }, valueDigest := (bytes [59, 110, 73, 184, 21, 134, 14, 247, 63, 174, 178, 199, 142, 253, 82, 19, 165, 139, 8, 196, 235, 194, 3, 121, 51, 124, 231, 35, 211, 16, 32, 52]), digest := (bytes [219, 218, 219, 174, 165, 130, 251, 88, 206, 16, 80, 0, 28, 86, 170, 191, 249, 191, 4, 236, 79, 80, 162, 191, 249, 161, 174, 139, 196, 157, 147, 124]) }), lastPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [116, 93, 153, 130, 232, 216, 210, 83, 127, 32, 104, 122, 68, 45, 119, 16, 13, 205, 151, 193, 226, 131, 66, 171, 100, 131, 124, 207, 194, 84, 69, 216]), layoutVersion := 3, digest := (bytes [206, 160, 212, 132, 68, 145, 205, 36, 65, 72, 189, 84, 106, 232, 12, 218, 83, 49, 212, 75, 8, 104, 8, 151, 141, 222, 235, 221, 213, 211, 202, 152]) }, logicalIndex := 3, digest := (bytes [170, 208, 237, 65, 75, 119, 119, 72, 219, 13, 34, 89, 241, 82, 231, 86, 162, 51, 20, 251, 135, 220, 233, 188, 249, 237, 246, 151, 96, 52, 237, 174]) }, valueDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [93, 157, 36, 36, 118, 242, 203, 241, 13, 166, 55, 56, 153, 196, 21, 43, 180, 209, 165, 227, 227, 152, 171, 214, 55, 182, 39, 224, 113, 54, 207, 193]) }) }, digest := (bytes [126, 202, 48, 129, 119, 95, 241, 162, 95, 2, 10, 160, 154, 108, 9, 14, 152, 231, 172, 56, 239, 188, 50, 181, 52, 17, 50, 111, 9, 71, 172, 151]) }, digest := (bytes [228, 51, 66, 220, 114, 155, 173, 21, 216, 253, 174, 182, 252, 242, 0, 113, 218, 44, 146, 169, 13, 168, 49, 151, 229, 129, 125, 240, 182, 51, 3, 55]) }
    , bindings := { claim := { stageClaimBundleDigest := (bytes [248, 254, 33, 79, 113, 110, 5, 131, 204, 190, 95, 176, 46, 168, 149, 63, 53, 198, 2, 181, 193, 80, 124, 176, 56, 122, 52, 16, 13, 153, 177, 246]), stagePackageBundleDigest := (bytes [1, 150, 13, 248, 98, 208, 148, 74, 34, 80, 169, 225, 228, 184, 163, 211, 239, 161, 173, 168, 210, 66, 122, 140, 174, 10, 147, 76, 184, 141, 166, 186]), stage1PackageDigest := (bytes [9, 211, 167, 148, 204, 209, 99, 130, 11, 103, 22, 106, 135, 209, 58, 212, 168, 170, 233, 94, 97, 173, 34, 173, 80, 5, 232, 148, 135, 61, 64, 211]), stage2PackageDigest := (bytes [164, 191, 220, 178, 15, 86, 66, 181, 212, 191, 196, 106, 218, 239, 88, 61, 29, 136, 37, 196, 125, 237, 155, 97, 22, 137, 176, 135, 114, 113, 25, 60]), stage3PackageDigest := (bytes [219, 79, 76, 23, 16, 156, 135, 61, 31, 134, 135, 16, 225, 146, 125, 59, 4, 56, 137, 89, 215, 205, 155, 245, 214, 170, 53, 2, 224, 13, 36, 12]), preparedStepBindingsDigest := (bytes [192, 157, 158, 171, 197, 63, 89, 130, 230, 100, 158, 40, 68, 19, 46, 243, 113, 18, 177, 19, 199, 36, 170, 141, 156, 102, 61, 205, 113, 170, 102, 192]), bindingCount := 4, stage1RowCount := 4, stage2RegisterReadCount := 4, stage2RegisterWriteCount := 2, stage2RamEventCount := 0, stage3ContinuityCount := 4, points := { firstBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [192, 157, 158, 171, 197, 63, 89, 130, 230, 100, 158, 40, 68, 19, 46, 243, 113, 18, 177, 19, 199, 36, 170, 141, 156, 102, 61, 205, 113, 170, 102, 192]), layoutVersion := 1, digest := (bytes [137, 32, 252, 35, 252, 91, 31, 147, 208, 223, 196, 99, 96, 69, 159, 237, 249, 166, 239, 18, 90, 47, 102, 12, 148, 255, 12, 230, 169, 239, 163, 139]) }, logicalIndex := 0, digest := (bytes [137, 68, 25, 226, 18, 38, 171, 191, 208, 213, 86, 17, 121, 132, 209, 227, 87, 25, 33, 58, 74, 67, 51, 114, 95, 42, 217, 210, 40, 171, 224, 137]) }, valueDigest := (bytes [25, 11, 217, 92, 88, 160, 212, 211, 136, 141, 82, 184, 177, 46, 81, 157, 179, 159, 135, 132, 224, 119, 249, 41, 240, 241, 220, 197, 133, 119, 124, 255]), digest := (bytes [195, 105, 217, 16, 96, 33, 143, 151, 251, 153, 164, 206, 90, 24, 186, 19, 104, 81, 160, 231, 121, 222, 59, 249, 41, 98, 198, 87, 127, 230, 241, 100]) }), lastBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [192, 157, 158, 171, 197, 63, 89, 130, 230, 100, 158, 40, 68, 19, 46, 243, 113, 18, 177, 19, 199, 36, 170, 141, 156, 102, 61, 205, 113, 170, 102, 192]), layoutVersion := 1, digest := (bytes [137, 32, 252, 35, 252, 91, 31, 147, 208, 223, 196, 99, 96, 69, 159, 237, 249, 166, 239, 18, 90, 47, 102, 12, 148, 255, 12, 230, 169, 239, 163, 139]) }, logicalIndex := 3, digest := (bytes [209, 99, 134, 178, 199, 137, 133, 171, 141, 66, 221, 72, 174, 221, 219, 0, 215, 45, 130, 71, 21, 112, 189, 185, 11, 110, 26, 125, 80, 243, 129, 5]) }, valueDigest := (bytes [254, 99, 83, 87, 142, 13, 25, 128, 17, 223, 67, 18, 69, 171, 237, 57, 247, 99, 239, 18, 152, 182, 82, 245, 246, 112, 106, 248, 5, 254, 200, 205]), digest := (bytes [75, 5, 158, 5, 205, 127, 194, 84, 198, 232, 230, 114, 173, 222, 220, 142, 96, 36, 170, 217, 5, 246, 152, 179, 218, 48, 180, 102, 85, 93, 101, 252]) }) }, digest := (bytes [222, 138, 13, 223, 179, 207, 135, 68, 181, 36, 93, 208, 109, 117, 44, 56, 110, 168, 72, 148, 184, 87, 198, 73, 194, 117, 173, 22, 163, 132, 54, 150]) }, packaged := { statementDigest := (bytes [62, 173, 123, 41, 100, 213, 222, 40, 36, 167, 47, 104, 136, 143, 66, 207, 110, 71, 241, 172, 57, 233, 11, 235, 137, 157, 111, 29, 205, 229, 216, 147]), proofDigest := (bytes [240, 235, 229, 90, 165, 189, 20, 148, 230, 41, 188, 30, 67, 207, 251, 73, 35, 131, 133, 220, 2, 168, 168, 104, 157, 247, 67, 137, 118, 198, 226, 4]) }, digest := (bytes [46, 233, 169, 32, 36, 252, 223, 62, 15, 40, 97, 78, 167, 126, 125, 62, 82, 35, 145, 236, 206, 107, 186, 151, 33, 151, 95, 216, 142, 16, 44, 31]) }
    , preparedSteps := { claim := { executionDigest := (bytes [46, 32, 12, 1, 169, 11, 60, 230, 125, 5, 123, 127, 177, 78, 153, 53, 25, 114, 127, 17, 26, 141, 196, 196, 80, 189, 184, 59, 120, 244, 188, 221]), finalStateDigest := (bytes [103, 119, 166, 83, 71, 235, 116, 157, 66, 6, 65, 91, 76, 196, 146, 226, 246, 68, 215, 2, 4, 30, 194, 108, 206, 35, 183, 164, 172, 191, 117, 48]), transcriptFinalDigest := (bytes [119, 7, 167, 196, 130, 246, 97, 117, 147, 54, 106, 251, 40, 15, 103, 100, 22, 139, 124, 178, 121, 36, 93, 139, 80, 196, 5, 66, 86, 204, 216, 62]), preparedStepCount := 4, finalPc := 20, halted := true, points := { firstPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [116, 93, 153, 130, 232, 216, 210, 83, 127, 32, 104, 122, 68, 45, 119, 16, 13, 205, 151, 193, 226, 131, 66, 171, 100, 131, 124, 207, 194, 84, 69, 216]), layoutVersion := 3, digest := (bytes [206, 160, 212, 132, 68, 145, 205, 36, 65, 72, 189, 84, 106, 232, 12, 218, 83, 49, 212, 75, 8, 104, 8, 151, 141, 222, 235, 221, 213, 211, 202, 152]) }, logicalIndex := 0, digest := (bytes [14, 92, 10, 244, 78, 56, 77, 247, 46, 29, 154, 26, 176, 243, 170, 204, 158, 255, 34, 89, 33, 167, 78, 81, 90, 132, 32, 174, 4, 30, 129, 198]) }, valueDigest := (bytes [59, 110, 73, 184, 21, 134, 14, 247, 63, 174, 178, 199, 142, 253, 82, 19, 165, 139, 8, 196, 235, 194, 3, 121, 51, 124, 231, 35, 211, 16, 32, 52]), digest := (bytes [219, 218, 219, 174, 165, 130, 251, 88, 206, 16, 80, 0, 28, 86, 170, 191, 249, 191, 4, 236, 79, 80, 162, 191, 249, 161, 174, 139, 196, 157, 147, 124]) }), lastPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [116, 93, 153, 130, 232, 216, 210, 83, 127, 32, 104, 122, 68, 45, 119, 16, 13, 205, 151, 193, 226, 131, 66, 171, 100, 131, 124, 207, 194, 84, 69, 216]), layoutVersion := 3, digest := (bytes [206, 160, 212, 132, 68, 145, 205, 36, 65, 72, 189, 84, 106, 232, 12, 218, 83, 49, 212, 75, 8, 104, 8, 151, 141, 222, 235, 221, 213, 211, 202, 152]) }, logicalIndex := 3, digest := (bytes [170, 208, 237, 65, 75, 119, 119, 72, 219, 13, 34, 89, 241, 82, 231, 86, 162, 51, 20, 251, 135, 220, 233, 188, 249, 237, 246, 151, 96, 52, 237, 174]) }, valueDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [93, 157, 36, 36, 118, 242, 203, 241, 13, 166, 55, 56, 153, 196, 21, 43, 180, 209, 165, 227, 227, 152, 171, 214, 55, 182, 39, 224, 113, 54, 207, 193]) }) }, digest := (bytes [126, 202, 48, 129, 119, 95, 241, 162, 95, 2, 10, 160, 154, 108, 9, 14, 152, 231, 172, 56, 239, 188, 50, 181, 52, 17, 50, 111, 9, 71, 172, 151]) }, packaged := { statementDigest := (bytes [63, 181, 106, 156, 147, 226, 197, 212, 65, 243, 8, 64, 205, 159, 174, 237, 35, 205, 121, 70, 240, 224, 76, 251, 231, 142, 80, 80, 5, 85, 45, 62]), proofDigest := (bytes [167, 243, 34, 120, 154, 143, 133, 207, 196, 44, 39, 188, 172, 187, 61, 155, 104, 255, 88, 103, 53, 45, 32, 158, 254, 12, 242, 11, 119, 16, 154, 102]) }, digest := (bytes [226, 30, 211, 96, 96, 63, 167, 180, 123, 34, 193, 59, 190, 48, 147, 174, 70, 34, 175, 70, 178, 218, 213, 179, 255, 239, 123, 18, 188, 9, 177, 44]) }
    , digest := (bytes [107, 58, 154, 230, 142, 221, 54, 99, 102, 173, 171, 129, 113, 222, 195, 141, 205, 132, 186, 224, 59, 145, 61, 200, 134, 161, 74, 246, 29, 243, 189, 205])
  }

def stepComposition : StepCompositionSurfaceView :=
  {
    stage1SemanticsDigest := (bytes [168, 201, 5, 200, 41, 41, 243, 59, 146, 52, 189, 225, 122, 57, 136, 59, 34, 222, 130, 83, 150, 59, 190, 238, 189, 235, 90, 180, 23, 39, 6, 76])
    , stage2SemanticsDigest := (bytes [103, 243, 230, 120, 30, 162, 86, 4, 182, 36, 21, 99, 46, 221, 139, 166, 95, 58, 238, 1, 16, 201, 130, 167, 18, 176, 161, 98, 102, 43, 174, 187])
    , stage2TemporalDigest := (bytes [12, 74, 240, 171, 75, 109, 160, 232, 176, 4, 19, 98, 228, 45, 67, 132, 184, 13, 209, 40, 81, 25, 115, 6, 148, 54, 247, 102, 241, 145, 216, 95])
    , stage3SemanticsDigest := (bytes [20, 3, 200, 134, 137, 220, 58, 216, 31, 224, 139, 111, 18, 67, 121, 173, 112, 90, 144, 103, 17, 101, 46, 72, 19, 160, 90, 31, 93, 255, 229, 137])
    , rootExecutionDigest := (bytes [43, 45, 61, 151, 187, 185, 175, 206, 232, 164, 23, 161, 229, 101, 195, 80, 13, 235, 108, 134, 95, 96, 114, 183, 59, 223, 83, 57, 20, 38, 172, 86])
    , preparedStepBindingsDigest := (bytes [192, 157, 158, 171, 197, 63, 89, 130, 230, 100, 158, 40, 68, 19, 46, 243, 113, 18, 177, 19, 199, 36, 170, 141, 156, 102, 61, 205, 113, 170, 102, 192])
    , rowChunkRoutesDigest := (bytes [170, 16, 215, 245, 131, 192, 198, 120, 95, 134, 175, 93, 217, 74, 16, 26, 237, 138, 81, 110, 201, 10, 195, 254, 244, 178, 29, 18, 146, 128, 117, 178])
    , realRowCount := 4
    , preparedStepCount := 4
    , firstRealStepIndex := 0
    , lastRealStepIndex := 3
    , initialPc := 0
    , finalPc := 20
    , halted := true
    , digest := (bytes [214, 224, 226, 86, 120, 168, 148, 150, 141, 94, 225, 107, 127, 5, 214, 103, 91, 16, 95, 60, 29, 7, 136, 28, 217, 199, 115, 69, 42, 74, 226, 93])
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
    name := "control_flow_blt_taken_skip_ecall"
    , source := {
  manifest := { name := "control_flow_blt_taken_skip_ecall", fixtureId := "control_flow_blt_taken_skip_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.controlFlow, .nativeAlu] }
  , startPc := 0
  , programWords := [4293918867, 1048851, 2147427, 115, 115]
  , initialRegisters := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , initialMemory := []
  , transcriptSeed := (bytes [114, 118, 54, 52, 105, 109, 45, 99, 111, 110, 116, 114, 111, 108, 45, 102, 108, 111, 119, 45, 98, 108, 116, 45, 118, 49])
}
    , derived := {
  manifest := { name := "control_flow_blt_taken_skip_ecall", fixtureId := "control_flow_blt_taken_skip_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.controlFlow, .nativeAlu] }
  , executionRows := [{
  traceIndex := 0
  , stepIndex := 0
  , sequenceIndex := 0
  , pc := 0
  , nextPc := 4
  , word := 4293918867
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
  , rdAfter := 18446744073709551615
  , imm := -1
  , aluResult := 18446744073709551615
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
  , word := 2147427
  , opcode := .blt
  , traceOpcode := (some .blt)
  , traceVirtualOpcode := none
  , family := .controlFlow
  , rs1 := 1
  , rs1Value := 18446744073709551615
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
  , stage1 := { rows := [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 4293918867, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 4, aluResult := 18446744073709551615, effectiveAddr := none, writesRd := true, rd := 1, rdAfter := 18446744073709551615, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 1048851, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 8, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 2, rdAfter := 1, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 2147427, opcode := .blt, traceOpcode := (some .blt), traceVirtualOpcode := none, family := .controlFlow, nextPc := 16, aluResult := 1, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 16, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 20, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }] }
  , stage2 := {
  registerReads := [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 0, value := 0 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 0, value := 0 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 1, value := 18446744073709551615 }, { traceIndex := 2, stepIndex := 2, role := .rs2, reg := 2, value := 1 }]
  , registerWrites := [{ traceIndex := 0, stepIndex := 0, reg := 1, previous := 0, next := 18446744073709551615 }, { traceIndex := 1, stepIndex := 1, reg := 2, previous := 0, next := 1 }]
  , ramEvents := []
  , twistLinks := [{ traceIndex := 0, stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 1, family := .nativeAlu, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 2, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 3, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]
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
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 99, 111, 110, 116, 114, 111, 108, 45, 102, 108, 111, 119, 45, 98, 108, 116, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [27634538711377453, 212436087916, 13380622803955469567, 3521951206484747623, 9254679819230523135, 7793219495316757120, 11804775929249192629, 11428962190686586919], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [99, 111, 110, 116, 114, 111, 108, 95, 102, 108, 111, 119, 95, 98, 108, 116, 95, 116, 97, 107, 101, 110, 95, 115, 107, 105, 112, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [27634538711377453, 212436087916, 13380622803955469567, 3521951206484747623, 9254679819230523135, 7793219495316757120, 11804775929249192629, 11428962190686586919], absorbed := 2 }
  , cursorAfter := { stateWords := [465674789733, 7180296237315089499, 11733811407418221658, 16498453394416949328, 14614950331407827170, 386261267250689441, 17895202755823189055, 13656127343008880826], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [4293918867, 1048851, 2147427, 115, 115]
  , cursorBefore := { stateWords := [465674789733, 7180296237315089499, 11733811407418221658, 16498453394416949328, 14614950331407827170, 386261267250689441, 17895202755823189055, 13656127343008880826], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 4342287947480010762, 10770147552220420142, 11196137098178073159, 3410458198267189641, 17053939472173617309, 10618310545408775523, 14632938316382243867], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [0, 4342287947480010762, 10770147552220420142, 11196137098178073159, 3410458198267189641, 17053939472173617309, 10618310545408775523, 14632938316382243867], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 0, 0, 3177119353095704368, 1122698152926025607, 8287482361524826601, 16723245261626599678, 4302150586641423449], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [0, 0, 0, 3177119353095704368, 1122698152926025607, 8287482361524826601, 16723245261626599678, 4302150586641423449], absorbed := 3 }
  , cursorAfter := { stateWords := [0, 8997489801189187788, 9188462323838030656, 3846626849677102628, 493978877708530803, 5797943057098051682, 265212388903239129, 5384776338942354106], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [98, 18, 188, 175, 27, 205, 179, 130, 57, 12, 232, 219, 38, 211, 175, 110, 23, 173, 187, 111, 225, 55, 139, 25, 196, 177, 64, 5, 240, 114, 106, 227])
  , u64s := []
  , cursorBefore := { stateWords := [0, 8997489801189187788, 9188462323838030656, 3846626849677102628, 493978877708530803, 5797943057098051682, 265212388903239129, 5384776338942354106], absorbed := 1 }
  , cursorAfter := { stateWords := [12638052876212445947, 11542696732698544447, 18007394215398869016, 14068469168916825873, 16931571443844531563, 6599354317457268593, 17714847696491555142, 1851216477043460655], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [12638052876212445947, 11542696732698544447, 18007394215398869016, 14068469168916825873, 16931571443844531563, 6599354317457268593, 17714847696491555142, 1851216477043460655], absorbed := 0 }
  , cursorAfter := { stateWords := [16644640469157671253, 6345635710436128953, 8972926169320819561, 8802111708820718633, 11586481162637383844, 18409059249488434770, 15588410963579079596, 16258969875057624872], absorbed := 0 }
  , challengeOutput := (some 16644640469157671253)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [17, 173, 35, 176, 52, 237, 183, 61, 86, 195, 142, 108, 204, 29, 120, 209, 90, 254, 172, 22, 131, 169, 195, 218, 54, 196, 115, 33, 141, 248, 85, 89])
  , u64s := []
  , cursorBefore := { stateWords := [16644640469157671253, 6345635710436128953, 8972926169320819561, 8802111708820718633, 11586481162637383844, 18409059249488434770, 15588410963579079596, 16258969875057624872], absorbed := 0 }
  , cursorAfter := { stateWords := [36898154206646648, 9415960802542505, 1498806413, 9072776052887572135, 11721581926632944754, 3535138222753818749, 6273687341861194554, 8882264780997456134], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [36898154206646648, 9415960802542505, 1498806413, 9072776052887572135, 11721581926632944754, 3535138222753818749, 6273687341861194554, 8882264780997456134], absorbed := 3 }
  , cursorAfter := { stateWords := [1411288425859349507, 4187811786765448679, 2899879548899209826, 12708691591653258630, 12167309891279697045, 2700363555137302011, 2186034203693546282, 13447575716582957255], absorbed := 0 }
  , challengeOutput := (some 1411288425859349507)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [1411288425859349507, 4187811786765448679, 2899879548899209826, 12708691591653258630, 12167309891279697045, 2700363555137302011, 2186034203693546282, 13447575716582957255], absorbed := 0 }
  , cursorAfter := { stateWords := [10716973488349051482, 3868992218345858838, 12653624167884364434, 6196821790445151857, 6347444349010254889, 7408501223560603604, 16906200941066870330, 18076423091780357662], absorbed := 0 }
  , challengeOutput := (some 10716973488349051482)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [113, 106, 8, 108, 18, 192, 96, 184, 164, 166, 127, 255, 228, 167, 133, 127, 188, 165, 129, 20, 7, 71, 150, 61, 35, 41, 236, 246, 45, 79, 63, 14])
  , u64s := []
  , cursorBefore := { stateWords := [10716973488349051482, 3868992218345858838, 12653624167884364434, 6196821790445151857, 6347444349010254889, 7408501223560603604, 16906200941066870330, 18076423091780357662], absorbed := 0 }
  , cursorAfter := { stateWords := [1992871900905349, 69502505699874375, 239030061, 449049874361303726, 13278269026255423333, 16025667103406807846, 11359412951690612528, 1030809117376067969], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [1992871900905349, 69502505699874375, 239030061, 449049874361303726, 13278269026255423333, 16025667103406807846, 11359412951690612528, 1030809117376067969], absorbed := 3 }
  , cursorAfter := { stateWords := [7080673056785947620, 10323909872972385627, 3294867110705849055, 17575164267868533637, 12557480519429552349, 12862571481398172470, 16561057601711089821, 2428372152698216523], absorbed := 0 }
  , challengeOutput := (some 7080673056785947620)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [198, 81, 7, 250, 152, 135, 65, 159, 231, 42, 117, 161, 26, 121, 63, 197, 123, 212, 231, 113, 35, 37, 159, 177, 226, 104, 247, 68, 136, 30, 16, 163])
  , u64s := []
  , cursorBefore := { stateWords := [7080673056785947620, 10323909872972385627, 3294867110705849055, 17575164267868533637, 12557480519429552349, 12862571481398172470, 16561057601711089821, 2428372152698216523], absorbed := 0 }
  , cursorAfter := { stateWords := [9976864701138239, 19412328268275493, 2735742600, 4961504159926370359, 14655189360590489950, 14059714068881444742, 14349289097047773731, 16140683775358900588], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [46, 32, 12, 1, 169, 11, 60, 230, 125, 5, 123, 127, 177, 78, 153, 53, 25, 114, 127, 17, 26, 141, 196, 196, 80, 189, 184, 59, 120, 244, 188, 221])
  , u64s := []
  , cursorBefore := { stateWords := [9976864701138239, 19412328268275493, 2735742600, 4961504159926370359, 14655189360590489950, 14059714068881444742, 14349289097047773731, 16140683775358900588], absorbed := 3 }
  , cursorAfter := { stateWords := [7337588467250585, 16810146869331085, 3720148088, 437345699824599267, 3522153810974739236, 14925937994573417365, 152522263272405329, 10141347386645065159], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [103, 119, 166, 83, 71, 235, 116, 157, 66, 6, 65, 91, 76, 196, 146, 226, 246, 68, 215, 2, 4, 30, 194, 108, 206, 35, 183, 164, 172, 191, 117, 48])
  , u64s := []
  , cursorBefore := { stateWords := [7337588467250585, 16810146869331085, 3720148088, 437345699824599267, 3522153810974739236, 14925937994573417365, 152522263272405329, 10141347386645065159], absorbed := 3 }
  , cursorAfter := { stateWords := [1129023505097362, 46363260595520030, 813023148, 12846192668686633647, 6741557979578876315, 5327271313024723108, 1204975810469412893, 2852815224866682480], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [1129023505097362, 46363260595520030, 813023148, 12846192668686633647, 6741557979578876315, 5327271313024723108, 1204975810469412893, 2852815224866682480], absorbed := 3 }
  , cursorAfter := { stateWords := [2909462562917863239, 9929399740580202738, 13577020951539415088, 17670864534221122448, 9593501634175910908, 6516463136653550587, 7536639024974644756, 5816055747239020741], absorbed := 0 }
  , challengeOutput := (some 2909462562917863239)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [2909462562917863239, 9929399740580202738, 13577020951539415088, 17670864534221122448, 9593501634175910908, 6516463136653550587, 7536639024974644756, 5816055747239020741], absorbed := 0 }
  , cursorAfter := { stateWords := [8458312616683964279, 7234767995085141651, 10042222849210223382, 4528594096167961680, 9166438756173917332, 17489391845004188911, 12640545817216988034, 14193716235814182519], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [119, 7, 167, 196, 130, 246, 97, 117, 147, 54, 106, 251, 40, 15, 103, 100, 22, 139, 124, 178, 121, 36, 93, 139, 80, 196, 5, 66, 86, 204, 216, 62]))
}]
}
  , kernel := {
  root0Digest := (bytes [98, 18, 188, 175, 27, 205, 179, 130, 57, 12, 232, 219, 38, 211, 175, 110, 23, 173, 187, 111, 225, 55, 139, 25, 196, 177, 64, 5, 240, 114, 106, 227])
  , stage1Digest := (bytes [17, 173, 35, 176, 52, 237, 183, 61, 86, 195, 142, 108, 204, 29, 120, 209, 90, 254, 172, 22, 131, 169, 195, 218, 54, 196, 115, 33, 141, 248, 85, 89])
  , stage2Digest := (bytes [113, 106, 8, 108, 18, 192, 96, 184, 164, 166, 127, 255, 228, 167, 133, 127, 188, 165, 129, 20, 7, 71, 150, 61, 35, 41, 236, 246, 45, 79, 63, 14])
  , stage3Digest := (bytes [198, 81, 7, 250, 152, 135, 65, 159, 231, 42, 117, 161, 26, 121, 63, 197, 123, 212, 231, 113, 35, 37, 159, 177, 226, 104, 247, 68, 136, 30, 16, 163])
  , executionDigest := (bytes [46, 32, 12, 1, 169, 11, 60, 230, 125, 5, 123, 127, 177, 78, 153, 53, 25, 114, 127, 17, 26, 141, 196, 196, 80, 189, 184, 59, 120, 244, 188, 221])
  , finalStateDigest := (bytes [103, 119, 166, 83, 71, 235, 116, 157, 66, 6, 65, 91, 76, 196, 146, 226, 246, 68, 215, 2, 4, 30, 194, 108, 206, 35, 183, 164, 172, 191, 117, 48])
  , stage1Mix := 16644640469157671253
  , stage2RegMix := 1411288425859349507
  , stage2RamMix := 10716973488349051482
  , stage3ContinuityMix := 7080673056785947620
  , kernelFinalMix := 2909462562917863239
  , transcriptFinalDigest := (bytes [119, 7, 167, 196, 130, 246, 97, 117, 147, 54, 106, 251, 40, 15, 103, 100, 22, 139, 124, 178, 121, 36, 93, 139, 80, 196, 5, 66, 86, 204, 216, 62])
  , finalPc := 20
  , finalRegisters := [0, 18446744073709551615, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , finalMemory := []
  , halted := true
}
}
    , kernelProof := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "control_flow_blt_taken_skip_ecall", fixtureId := "control_flow_blt_taken_skip_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.controlFlow, .nativeAlu] }
  , executionDigest := (bytes [46, 32, 12, 1, 169, 11, 60, 230, 125, 5, 123, 127, 177, 78, 153, 53, 25, 114, 127, 17, 26, 141, 196, 196, 80, 189, 184, 59, 120, 244, 188, 221])
  , shape := { executionRowCount := 4, realRowCount := 4, effectRowCount := 4, commitRowCount := 4, digest := (bytes [45, 178, 181, 197, 132, 60, 130, 1, 239, 208, 160, 249, 86, 246, 26, 179, 94, 235, 136, 250, 242, 5, 139, 0, 36, 216, 225, 255, 232, 86, 248, 123]) }
  , digest := (bytes [196, 26, 136, 122, 213, 208, 195, 92, 124, 69, 178, 0, 92, 124, 214, 171, 169, 245, 214, 201, 52, 17, 60, 22, 108, 28, 172, 142, 76, 53, 245, 132])
}
  , stages := { summary := { stage1RowCount := 4, stage2RegisterReadCount := 4, stage2RegisterWriteCount := 2, stage2RamEventCount := 0, stage2TwistLinkCount := 4, stage3ContinuityCount := 4, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [188, 146, 61, 220, 245, 51, 7, 161, 36, 1, 199, 100, 62, 187, 19, 182, 215, 124, 14, 176, 250, 206, 43, 76, 0, 125, 203, 144, 45, 193, 111, 34]) }, digest := (bytes [109, 34, 58, 13, 68, 111, 109, 31, 96, 208, 232, 119, 140, 198, 44, 192, 184, 71, 199, 65, 42, 115, 36, 133, 68, 13, 13, 169, 75, 7, 175, 245]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [248, 254, 33, 79, 113, 110, 5, 131, 204, 190, 95, 176, 46, 168, 149, 63, 53, 198, 2, 181, 193, 80, 124, 176, 56, 122, 52, 16, 13, 153, 177, 246]), stage1Digest := (bytes [223, 31, 180, 114, 3, 114, 161, 197, 87, 4, 250, 141, 112, 65, 40, 191, 115, 7, 71, 221, 149, 154, 89, 254, 132, 96, 3, 217, 138, 47, 26, 230]), stage2Digest := (bytes [191, 72, 172, 199, 228, 144, 252, 216, 206, 245, 155, 111, 171, 154, 84, 141, 166, 29, 13, 238, 119, 226, 188, 198, 96, 195, 42, 255, 96, 226, 246, 99]), stage3Digest := (bytes [241, 139, 61, 96, 28, 236, 184, 76, 31, 31, 90, 170, 231, 105, 75, 206, 127, 224, 133, 83, 235, 74, 203, 217, 94, 188, 29, 205, 255, 17, 30, 140]), transcriptDigest := (bytes [119, 7, 167, 196, 130, 246, 97, 117, 147, 54, 106, 251, 40, 15, 103, 100, 22, 139, 124, 178, 121, 36, 93, 139, 80, 196, 5, 66, 86, 204, 216, 62]), executionDigest := (bytes [46, 32, 12, 1, 169, 11, 60, 230, 125, 5, 123, 127, 177, 78, 153, 53, 25, 114, 127, 17, 26, 141, 196, 196, 80, 189, 184, 59, 120, 244, 188, 221]), digest := (bytes [101, 228, 44, 88, 13, 183, 105, 13, 221, 39, 134, 220, 242, 175, 246, 160, 1, 44, 117, 252, 194, 132, 235, 60, 80, 59, 6, 31, 13, 254, 21, 223]) }, statementDigest := (bytes [143, 149, 228, 116, 108, 170, 170, 67, 37, 91, 66, 236, 130, 196, 6, 86, 110, 112, 245, 172, 56, 69, 20, 164, 210, 190, 232, 225, 32, 62, 21, 227]), proofDigest := (bytes [223, 201, 6, 133, 146, 17, 237, 100, 94, 189, 154, 213, 116, 219, 178, 79, 148, 165, 139, 78, 209, 117, 159, 110, 42, 110, 163, 132, 7, 212, 40, 165]), digest := (bytes [243, 68, 218, 224, 114, 170, 185, 59, 140, 151, 48, 75, 105, 99, 122, 132, 237, 231, 239, 198, 37, 220, 251, 111, 58, 141, 246, 229, 194, 30, 49, 239]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [1, 150, 13, 248, 98, 208, 148, 74, 34, 80, 169, 225, 228, 184, 163, 211, 239, 161, 173, 168, 210, 66, 122, 140, 174, 10, 147, 76, 184, 141, 166, 186]), stage1Digest := (bytes [9, 211, 167, 148, 204, 209, 99, 130, 11, 103, 22, 106, 135, 209, 58, 212, 168, 170, 233, 94, 97, 173, 34, 173, 80, 5, 232, 148, 135, 61, 64, 211]), stage2Digest := (bytes [164, 191, 220, 178, 15, 86, 66, 181, 212, 191, 196, 106, 218, 239, 88, 61, 29, 136, 37, 196, 125, 237, 155, 97, 22, 137, 176, 135, 114, 113, 25, 60]), stage3Digest := (bytes [219, 79, 76, 23, 16, 156, 135, 61, 31, 134, 135, 16, 225, 146, 125, 59, 4, 56, 137, 89, 215, 205, 155, 245, 214, 170, 53, 2, 224, 13, 36, 12]), digest := (bytes [42, 182, 57, 44, 12, 233, 48, 223, 129, 82, 165, 14, 49, 221, 247, 84, 201, 249, 26, 125, 201, 109, 42, 70, 100, 35, 40, 105, 154, 98, 17, 40]) }, digest := (bytes [103, 159, 177, 43, 2, 12, 183, 140, 108, 118, 153, 33, 156, 70, 171, 82, 80, 51, 47, 152, 46, 51, 89, 110, 66, 237, 240, 240, 132, 217, 100, 43]) }
  , kernelOpening := { openingDigest := (bytes [107, 58, 154, 230, 142, 221, 54, 99, 102, 173, 171, 129, 113, 222, 195, 141, 205, 132, 186, 224, 59, 145, 61, 200, 134, 161, 74, 246, 29, 243, 189, 205]), bindings := { claimDigest := (bytes [228, 51, 66, 220, 114, 155, 173, 21, 216, 253, 174, 182, 252, 242, 0, 113, 218, 44, 146, 169, 13, 168, 49, 151, 229, 129, 125, 240, 182, 51, 3, 55]), bindingsDigest := (bytes [46, 233, 169, 32, 36, 252, 223, 62, 15, 40, 97, 78, 167, 126, 125, 62, 82, 35, 145, 236, 206, 107, 186, 151, 33, 151, 95, 216, 142, 16, 44, 31]), preparedStepsDigest := (bytes [226, 30, 211, 96, 96, 63, 167, 180, 123, 34, 193, 59, 190, 48, 147, 174, 70, 34, 175, 70, 178, 218, 213, 179, 255, 239, 123, 18, 188, 9, 177, 44]), digest := (bytes [76, 6, 163, 185, 135, 85, 69, 126, 231, 57, 39, 106, 29, 166, 242, 129, 46, 204, 21, 197, 133, 240, 100, 191, 233, 162, 39, 188, 181, 177, 203, 49]) }, digest := (bytes [97, 173, 64, 9, 167, 85, 152, 95, 131, 94, 87, 92, 213, 202, 219, 208, 12, 193, 115, 132, 11, 133, 165, 8, 10, 219, 159, 59, 205, 122, 159, 87]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [192, 157, 158, 171, 197, 63, 89, 130, 230, 100, 158, 40, 68, 19, 46, 243, 113, 18, 177, 19, 199, 36, 170, 141, 156, 102, 61, 205, 113, 170, 102, 192]), terminal := { root0Digest := (bytes [98, 18, 188, 175, 27, 205, 179, 130, 57, 12, 232, 219, 38, 211, 175, 110, 23, 173, 187, 111, 225, 55, 139, 25, 196, 177, 64, 5, 240, 114, 106, 227]), executionDigest := (bytes [46, 32, 12, 1, 169, 11, 60, 230, 125, 5, 123, 127, 177, 78, 153, 53, 25, 114, 127, 17, 26, 141, 196, 196, 80, 189, 184, 59, 120, 244, 188, 221]), finalStateDigest := (bytes [103, 119, 166, 83, 71, 235, 116, 157, 66, 6, 65, 91, 76, 196, 146, 226, 246, 68, 215, 2, 4, 30, 194, 108, 206, 35, 183, 164, 172, 191, 117, 48]), transcriptFinalDigest := (bytes [119, 7, 167, 196, 130, 246, 97, 117, 147, 54, 106, 251, 40, 15, 103, 100, 22, 139, 124, 178, 121, 36, 93, 139, 80, 196, 5, 66, 86, 204, 216, 62]), finalPc := 20, halted := true, digest := (bytes [91, 235, 115, 249, 147, 209, 26, 233, 108, 152, 165, 255, 9, 235, 51, 94, 102, 210, 191, 88, 9, 152, 212, 39, 19, 115, 91, 230, 173, 203, 191, 53]) }, digest := (bytes [165, 210, 68, 127, 142, 143, 0, 35, 107, 59, 193, 151, 12, 70, 37, 104, 61, 227, 84, 188, 28, 23, 182, 80, 198, 211, 131, 5, 11, 159, 112, 31]) }, statementDigest := (bytes [140, 226, 248, 131, 105, 165, 226, 9, 246, 59, 96, 204, 72, 149, 237, 189, 119, 170, 171, 217, 51, 103, 251, 69, 96, 187, 203, 253, 31, 160, 208, 80]), proofDigest := (bytes [229, 6, 212, 131, 222, 235, 89, 39, 195, 239, 186, 54, 56, 171, 189, 8, 5, 105, 29, 178, 45, 95, 22, 238, 123, 90, 68, 78, 192, 73, 93, 240]), digest := (bytes [61, 63, 204, 211, 91, 172, 227, 27, 108, 10, 243, 49, 114, 61, 134, 127, 26, 167, 144, 240, 205, 249, 13, 131, 9, 33, 119, 60, 66, 186, 180, 127]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [17, 200, 31, 62, 49, 172, 250, 37, 145, 105, 53, 203, 246, 118, 11, 102, 130, 27, 67, 62, 33, 190, 100, 19, 43, 89, 155, 192, 93, 125, 221, 76]), layoutVersion := 1, digest := (bytes [209, 81, 166, 186, 4, 204, 166, 150, 37, 137, 27, 146, 96, 65, 41, 111, 22, 187, 153, 19, 225, 72, 116, 47, 30, 162, 26, 76, 240, 92, 137, 202]) }, rowWidth := 38, timeLen := 4, columnDigests := [(bytes [212, 186, 229, 172, 74, 68, 211, 103, 24, 241, 21, 82, 209, 33, 189, 99, 223, 36, 129, 167, 9, 173, 76, 108, 178, 222, 90, 225, 89, 142, 8, 14]), (bytes [56, 58, 241, 13, 94, 161, 102, 38, 209, 85, 101, 10, 115, 74, 68, 15, 139, 16, 65, 164, 142, 61, 38, 80, 159, 19, 8, 220, 33, 174, 155, 155]), (bytes [29, 30, 250, 119, 67, 192, 190, 83, 169, 199, 126, 126, 209, 9, 207, 51, 13, 31, 240, 215, 38, 77, 233, 53, 71, 218, 94, 76, 41, 218, 33, 58]), (bytes [181, 122, 105, 181, 35, 180, 95, 214, 79, 41, 41, 2, 114, 48, 216, 55, 223, 211, 166, 64, 24, 33, 244, 234, 111, 10, 124, 63, 69, 70, 27, 116]), (bytes [235, 168, 211, 18, 219, 164, 123, 11, 1, 214, 235, 228, 142, 231, 19, 191, 111, 116, 112, 196, 167, 65, 6, 113, 150, 204, 141, 39, 111, 24, 165, 153]), (bytes [2, 223, 179, 210, 209, 205, 146, 17, 164, 217, 202, 178, 34, 24, 81, 6, 189, 236, 155, 58, 107, 97, 35, 210, 41, 139, 124, 249, 115, 65, 71, 53]), (bytes [148, 93, 109, 35, 88, 87, 157, 97, 249, 179, 2, 2, 221, 198, 208, 66, 170, 138, 243, 110, 6, 236, 227, 101, 91, 65, 171, 243, 200, 198, 189, 148]), (bytes [132, 13, 123, 172, 120, 106, 189, 241, 207, 17, 23, 219, 168, 136, 164, 0, 142, 128, 126, 198, 69, 95, 67, 194, 148, 13, 102, 136, 180, 146, 31, 139]), (bytes [13, 51, 13, 112, 10, 98, 204, 18, 53, 169, 156, 155, 63, 147, 114, 64, 241, 138, 154, 179, 238, 77, 114, 193, 171, 122, 197, 145, 246, 175, 206, 33]), (bytes [232, 60, 34, 59, 99, 35, 37, 101, 97, 80, 246, 173, 253, 205, 108, 125, 30, 217, 170, 112, 111, 96, 190, 85, 240, 167, 219, 144, 235, 27, 30, 175]), (bytes [33, 226, 191, 51, 76, 109, 28, 150, 35, 183, 64, 252, 90, 183, 140, 34, 61, 65, 9, 61, 233, 26, 98, 58, 22, 113, 219, 130, 57, 126, 25, 166]), (bytes [118, 132, 140, 41, 46, 54, 170, 167, 122, 118, 200, 245, 49, 89, 177, 77, 198, 10, 78, 179, 11, 224, 33, 204, 58, 199, 196, 82, 84, 72, 223, 144]), (bytes [205, 50, 239, 174, 62, 102, 47, 47, 168, 229, 99, 79, 130, 123, 211, 62, 86, 5, 136, 142, 232, 236, 222, 93, 139, 184, 152, 44, 168, 14, 179, 91]), (bytes [103, 53, 107, 4, 189, 132, 244, 169, 29, 6, 184, 32, 91, 82, 178, 107, 52, 16, 254, 231, 248, 28, 125, 77, 103, 211, 79, 63, 83, 74, 140, 122]), (bytes [134, 141, 124, 169, 119, 38, 249, 119, 111, 250, 40, 3, 85, 79, 214, 122, 209, 119, 227, 254, 195, 29, 190, 77, 250, 140, 202, 20, 171, 232, 229, 55]), (bytes [220, 193, 230, 244, 243, 14, 93, 42, 216, 108, 251, 253, 94, 191, 212, 189, 13, 211, 94, 236, 218, 138, 122, 7, 190, 222, 130, 249, 182, 150, 137, 189]), (bytes [223, 89, 191, 11, 110, 102, 31, 137, 129, 115, 137, 48, 64, 221, 208, 112, 235, 228, 24, 226, 254, 59, 16, 16, 192, 134, 30, 101, 212, 162, 156, 187]), (bytes [156, 22, 213, 157, 3, 147, 139, 132, 146, 22, 57, 209, 56, 31, 20, 20, 229, 105, 89, 38, 226, 230, 110, 49, 208, 70, 178, 10, 75, 21, 225, 62]), (bytes [89, 6, 118, 169, 105, 54, 5, 121, 26, 253, 91, 160, 13, 78, 211, 28, 177, 107, 187, 177, 10, 185, 35, 168, 191, 215, 99, 41, 155, 74, 182, 15]), (bytes [16, 1, 45, 207, 125, 115, 77, 40, 96, 249, 191, 96, 68, 155, 161, 144, 89, 205, 15, 173, 177, 139, 3, 87, 248, 132, 221, 254, 91, 235, 118, 133]), (bytes [2, 197, 213, 149, 21, 90, 236, 108, 141, 146, 26, 38, 0, 78, 135, 95, 223, 228, 221, 179, 125, 245, 167, 198, 49, 196, 48, 128, 192, 39, 124, 49]), (bytes [130, 134, 127, 131, 40, 47, 149, 206, 210, 112, 225, 17, 66, 25, 14, 78, 65, 235, 99, 73, 206, 90, 67, 148, 19, 78, 146, 25, 197, 149, 108, 61]), (bytes [8, 234, 67, 158, 76, 76, 170, 16, 58, 161, 138, 98, 35, 61, 115, 114, 104, 189, 45, 62, 96, 35, 11, 160, 56, 73, 223, 212, 106, 84, 224, 145]), (bytes [0, 189, 116, 3, 67, 124, 251, 249, 47, 128, 49, 73, 210, 47, 86, 252, 162, 78, 171, 9, 96, 183, 112, 195, 81, 120, 202, 223, 242, 24, 76, 51]), (bytes [81, 144, 1, 221, 155, 166, 187, 155, 181, 172, 254, 158, 176, 149, 110, 161, 164, 146, 156, 197, 231, 227, 176, 108, 72, 168, 128, 97, 162, 214, 166, 78]), (bytes [238, 147, 134, 181, 8, 29, 128, 200, 221, 198, 65, 181, 234, 22, 117, 159, 112, 0, 90, 214, 190, 69, 86, 72, 209, 196, 234, 23, 145, 109, 49, 190]), (bytes [150, 94, 21, 115, 92, 3, 250, 46, 250, 39, 23, 156, 66, 177, 198, 103, 242, 34, 109, 175, 253, 18, 181, 44, 23, 6, 9, 9, 119, 235, 11, 108]), (bytes [135, 215, 141, 47, 156, 11, 54, 54, 3, 72, 179, 247, 223, 155, 104, 7, 155, 222, 232, 159, 97, 172, 115, 97, 167, 121, 212, 57, 156, 44, 117, 203]), (bytes [84, 95, 115, 25, 213, 106, 24, 56, 216, 206, 94, 157, 100, 187, 198, 197, 93, 1, 173, 134, 90, 112, 47, 80, 254, 7, 54, 249, 32, 132, 243, 167]), (bytes [130, 198, 251, 47, 44, 43, 143, 92, 82, 195, 92, 157, 42, 215, 42, 26, 5, 251, 108, 34, 34, 0, 80, 113, 213, 113, 25, 247, 190, 124, 74, 52]), (bytes [234, 182, 234, 160, 23, 192, 246, 199, 173, 187, 203, 106, 254, 25, 134, 196, 2, 40, 181, 117, 170, 220, 56, 86, 63, 246, 0, 182, 78, 16, 61, 77]), (bytes [40, 254, 204, 213, 6, 140, 117, 235, 134, 79, 86, 81, 169, 63, 60, 118, 8, 156, 87, 198, 194, 60, 29, 160, 125, 250, 15, 187, 147, 220, 29, 92]), (bytes [18, 187, 180, 226, 104, 66, 42, 243, 22, 156, 53, 240, 151, 142, 203, 83, 91, 143, 153, 183, 211, 14, 178, 15, 249, 35, 88, 211, 226, 167, 221, 238]), (bytes [164, 40, 127, 229, 211, 147, 121, 221, 253, 56, 242, 238, 25, 160, 231, 5, 98, 88, 35, 198, 216, 51, 242, 34, 196, 132, 1, 62, 202, 49, 246, 41]), (bytes [122, 105, 77, 66, 174, 33, 37, 82, 171, 117, 60, 146, 152, 71, 176, 9, 4, 214, 95, 111, 117, 16, 77, 11, 22, 12, 202, 53, 36, 93, 76, 79]), (bytes [190, 26, 99, 184, 175, 199, 251, 124, 134, 183, 220, 35, 196, 195, 152, 135, 36, 169, 87, 198, 14, 22, 245, 143, 20, 239, 221, 18, 139, 77, 165, 236]), (bytes [80, 33, 41, 82, 68, 242, 18, 200, 209, 172, 125, 228, 155, 229, 192, 181, 222, 62, 254, 113, 197, 197, 209, 167, 162, 245, 86, 19, 189, 248, 96, 43]), (bytes [90, 10, 190, 250, 226, 23, 47, 210, 182, 164, 148, 175, 37, 226, 99, 192, 247, 166, 149, 66, 95, 29, 230, 232, 50, 99, 224, 203, 78, 177, 221, 250])], familyDigest := (bytes [17, 200, 31, 62, 49, 172, 250, 37, 145, 105, 53, 203, 246, 118, 11, 102, 130, 27, 67, 62, 33, 190, 100, 19, 43, 89, 155, 192, 93, 125, 221, 76]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [17, 200, 31, 62, 49, 172, 250, 37, 145, 105, 53, 203, 246, 118, 11, 102, 130, 27, 67, 62, 33, 190, 100, 19, 43, 89, 155, 192, 93, 125, 221, 76]), layoutVersion := 1, digest := (bytes [209, 81, 166, 186, 4, 204, 166, 150, 37, 137, 27, 146, 96, 65, 41, 111, 22, 187, 153, 19, 225, 72, 116, 47, 30, 162, 26, 76, 240, 92, 137, 202]) }, logicalIndex := 0, digest := (bytes [74, 163, 169, 52, 59, 19, 192, 199, 26, 28, 140, 249, 102, 6, 101, 159, 107, 24, 248, 134, 243, 34, 87, 85, 72, 167, 66, 239, 150, 191, 249, 200]) }, valueDigest := (bytes [59, 110, 73, 184, 21, 134, 14, 247, 63, 174, 178, 199, 142, 253, 82, 19, 165, 139, 8, 196, 235, 194, 3, 121, 51, 124, 231, 35, 211, 16, 32, 52]), digest := (bytes [226, 218, 13, 4, 55, 80, 197, 195, 76, 108, 24, 197, 233, 230, 155, 103, 218, 151, 128, 91, 234, 235, 98, 162, 237, 158, 247, 170, 217, 3, 134, 70]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [17, 200, 31, 62, 49, 172, 250, 37, 145, 105, 53, 203, 246, 118, 11, 102, 130, 27, 67, 62, 33, 190, 100, 19, 43, 89, 155, 192, 93, 125, 221, 76]), layoutVersion := 1, digest := (bytes [209, 81, 166, 186, 4, 204, 166, 150, 37, 137, 27, 146, 96, 65, 41, 111, 22, 187, 153, 19, 225, 72, 116, 47, 30, 162, 26, 76, 240, 92, 137, 202]) }, logicalIndex := 3, digest := (bytes [83, 176, 155, 12, 128, 45, 187, 248, 3, 198, 3, 196, 135, 231, 240, 194, 102, 143, 106, 53, 186, 216, 189, 103, 2, 215, 13, 68, 157, 15, 93, 68]) }, valueDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [39, 255, 14, 211, 207, 209, 24, 34, 167, 228, 216, 123, 174, 173, 128, 46, 62, 57, 217, 213, 2, 205, 57, 34, 161, 52, 77, 9, 243, 115, 76, 211]) }), digest := (bytes [109, 78, 11, 81, 10, 95, 146, 203, 37, 0, 50, 102, 146, 114, 137, 79, 18, 144, 51, 195, 86, 163, 101, 61, 242, 3, 132, 155, 189, 182, 80, 39]) }
  , rootLaneCommitment := { timeLen := 4, commitments := { commitmentCount := 38, digest := (bytes [116, 93, 153, 130, 232, 216, 210, 83, 127, 32, 104, 122, 68, 45, 119, 16, 13, 205, 151, 193, 226, 131, 66, 171, 100, 131, 124, 207, 194, 84, 69, 216]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [116, 93, 153, 130, 232, 216, 210, 83, 127, 32, 104, 122, 68, 45, 119, 16, 13, 205, 151, 193, 226, 131, 66, 171, 100, 131, 124, 207, 194, 84, 69, 216]), layoutVersion := 3, digest := (bytes [206, 160, 212, 132, 68, 145, 205, 36, 65, 72, 189, 84, 106, 232, 12, 218, 83, 49, 212, 75, 8, 104, 8, 151, 141, 222, 235, 221, 213, 211, 202, 152]) }, logicalIndex := 0, digest := (bytes [14, 92, 10, 244, 78, 56, 77, 247, 46, 29, 154, 26, 176, 243, 170, 204, 158, 255, 34, 89, 33, 167, 78, 81, 90, 132, 32, 174, 4, 30, 129, 198]) }, valueDigest := (bytes [59, 110, 73, 184, 21, 134, 14, 247, 63, 174, 178, 199, 142, 253, 82, 19, 165, 139, 8, 196, 235, 194, 3, 121, 51, 124, 231, 35, 211, 16, 32, 52]), digest := (bytes [219, 218, 219, 174, 165, 130, 251, 88, 206, 16, 80, 0, 28, 86, 170, 191, 249, 191, 4, 236, 79, 80, 162, 191, 249, 161, 174, 139, 196, 157, 147, 124]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [116, 93, 153, 130, 232, 216, 210, 83, 127, 32, 104, 122, 68, 45, 119, 16, 13, 205, 151, 193, 226, 131, 66, 171, 100, 131, 124, 207, 194, 84, 69, 216]), layoutVersion := 3, digest := (bytes [206, 160, 212, 132, 68, 145, 205, 36, 65, 72, 189, 84, 106, 232, 12, 218, 83, 49, 212, 75, 8, 104, 8, 151, 141, 222, 235, 221, 213, 211, 202, 152]) }, logicalIndex := 3, digest := (bytes [170, 208, 237, 65, 75, 119, 119, 72, 219, 13, 34, 89, 241, 82, 231, 86, 162, 51, 20, 251, 135, 220, 233, 188, 249, 237, 246, 151, 96, 52, 237, 174]) }, valueDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [93, 157, 36, 36, 118, 242, 203, 241, 13, 166, 55, 56, 153, 196, 21, 43, 180, 209, 165, 227, 227, 152, 171, 214, 55, 182, 39, 224, 113, 54, 207, 193]) }), digest := (bytes [173, 179, 33, 189, 187, 191, 177, 180, 128, 209, 106, 82, 101, 161, 51, 198, 78, 189, 60, 236, 72, 131, 100, 76, 191, 155, 96, 159, 125, 38, 9, 222]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [109, 78, 11, 81, 10, 95, 146, 203, 37, 0, 50, 102, 146, 114, 137, 79, 18, 144, 51, 195, 86, 163, 101, 61, 242, 3, 132, 155, 189, 182, 80, 39]), rootLaneCommitmentDigest := (bytes [173, 179, 33, 189, 187, 191, 177, 180, 128, 209, 106, 82, 101, 161, 51, 198, 78, 189, 60, 236, 72, 131, 100, 76, 191, 155, 96, 159, 125, 38, 9, 222]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 4, digest := (bytes [69, 198, 181, 31, 1, 82, 207, 80, 49, 145, 106, 234, 47, 152, 166, 167, 63, 253, 95, 41, 215, 15, 110, 210, 230, 54, 36, 253, 97, 206, 221, 44]) }, statementDigest := (bytes [243, 11, 20, 125, 199, 20, 35, 50, 23, 6, 226, 42, 212, 106, 174, 82, 204, 153, 180, 0, 253, 47, 62, 199, 146, 177, 65, 197, 37, 161, 193, 26]), proofDigest := (bytes [179, 50, 115, 34, 156, 230, 119, 223, 90, 255, 82, 147, 133, 148, 105, 168, 198, 209, 236, 197, 7, 9, 42, 41, 0, 25, 175, 56, 15, 211, 199, 185]), digest := (bytes [247, 226, 241, 187, 96, 204, 66, 130, 5, 31, 120, 64, 209, 158, 104, 12, 193, 149, 56, 123, 58, 80, 81, 90, 181, 31, 184, 242, 179, 137, 141, 150]) }
  , digest := (bytes [223, 126, 79, 134, 8, 241, 122, 213, 45, 95, 249, 223, 68, 72, 29, 226, 49, 131, 7, 43, 44, 114, 47, 212, 117, 118, 213, 188, 145, 166, 230, 154])
}
    , exportedProof := {
  claim := {
  accepted := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , statement := { proofStatementDigest := (bytes [199, 136, 0, 35, 212, 30, 248, 57, 82, 159, 198, 18, 101, 222, 184, 62, 88, 25, 148, 202, 78, 213, 221, 220, 187, 240, 2, 128, 176, 203, 244, 252]), kernelOpeningDigest := (bytes [97, 173, 64, 9, 167, 85, 152, 95, 131, 94, 87, 92, 213, 202, 219, 208, 12, 193, 115, 132, 11, 133, 165, 8, 10, 219, 159, 59, 205, 122, 159, 87]), digest := (bytes [26, 34, 159, 162, 0, 78, 148, 235, 157, 177, 141, 63, 223, 174, 100, 145, 202, 189, 160, 79, 78, 245, 23, 140, 68, 1, 137, 116, 11, 146, 96, 149]) }
  , mainLane := { mainLaneBundleDigest := (bytes [247, 226, 241, 187, 96, 204, 66, 130, 5, 31, 120, 64, 209, 158, 104, 12, 193, 149, 56, 123, 58, 80, 81, 90, 181, 31, 184, 242, 179, 137, 141, 150]), digest := (bytes [155, 220, 136, 114, 133, 51, 43, 75, 206, 134, 231, 240, 97, 86, 41, 181, 124, 22, 157, 200, 189, 42, 49, 9, 142, 50, 132, 90, 31, 242, 211, 90]) }
  , terminal := { finalStateDigest := (bytes [103, 119, 166, 83, 71, 235, 116, 157, 66, 6, 65, 91, 76, 196, 146, 226, 246, 68, 215, 2, 4, 30, 194, 108, 206, 35, 183, 164, 172, 191, 117, 48]), finalPc := 20, halted := true, digest := (bytes [75, 37, 1, 63, 9, 237, 150, 194, 191, 94, 240, 80, 37, 47, 206, 233, 56, 244, 48, 202, 88, 196, 136, 246, 8, 177, 86, 219, 203, 132, 68, 89]) }
  , digest := (bytes [149, 63, 234, 234, 197, 128, 164, 15, 241, 165, 105, 166, 149, 42, 143, 75, 26, 191, 12, 80, 134, 137, 239, 67, 245, 153, 145, 172, 163, 204, 139, 171])
}
  , mainLane := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { mainLaneBundleDigest := (bytes [247, 226, 241, 187, 96, 204, 66, 130, 5, 31, 120, 64, 209, 158, 104, 12, 193, 149, 56, 123, 58, 80, 81, 90, 181, 31, 184, 242, 179, 137, 141, 150]), digest := (bytes [129, 179, 37, 166, 172, 211, 55, 230, 245, 40, 48, 31, 94, 41, 4, 51, 85, 81, 220, 37, 200, 62, 198, 28, 30, 208, 197, 143, 36, 97, 5, 240]) }, digest := (bytes [201, 201, 16, 161, 208, 210, 149, 200, 117, 183, 159, 176, 174, 214, 226, 253, 111, 152, 47, 88, 120, 123, 52, 177, 40, 246, 3, 52, 39, 19, 128, 41]) }
  , opening := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , stages := { stageClaimsDigest := (bytes [243, 68, 218, 224, 114, 170, 185, 59, 140, 151, 48, 75, 105, 99, 122, 132, 237, 231, 239, 198, 37, 220, 251, 111, 58, 141, 246, 229, 194, 30, 49, 239]), stagePackagesDigest := (bytes [103, 159, 177, 43, 2, 12, 183, 140, 108, 118, 153, 33, 156, 70, 171, 82, 80, 51, 47, 152, 46, 51, 89, 110, 66, 237, 240, 240, 132, 217, 100, 43]), kernelOpeningDigest := (bytes [97, 173, 64, 9, 167, 85, 152, 95, 131, 94, 87, 92, 213, 202, 219, 208, 12, 193, 115, 132, 11, 133, 165, 8, 10, 219, 159, 59, 205, 122, 159, 87]), digest := (bytes [45, 89, 67, 37, 220, 97, 241, 91, 163, 107, 115, 157, 34, 116, 153, 217, 74, 73, 43, 149, 24, 71, 189, 183, 160, 13, 51, 76, 136, 5, 224, 227]) }
  , terminal := { preparedStepBindingsDigest := (bytes [192, 157, 158, 171, 197, 63, 89, 130, 230, 100, 158, 40, 68, 19, 46, 243, 113, 18, 177, 19, 199, 36, 170, 141, 156, 102, 61, 205, 113, 170, 102, 192]), executionDigest := (bytes [46, 32, 12, 1, 169, 11, 60, 230, 125, 5, 123, 127, 177, 78, 153, 53, 25, 114, 127, 17, 26, 141, 196, 196, 80, 189, 184, 59, 120, 244, 188, 221]), transcriptFinalDigest := (bytes [119, 7, 167, 196, 130, 246, 97, 117, 147, 54, 106, 251, 40, 15, 103, 100, 22, 139, 124, 178, 121, 36, 93, 139, 80, 196, 5, 66, 86, 204, 216, 62]), digest := (bytes [160, 9, 236, 38, 47, 178, 251, 33, 23, 226, 207, 204, 48, 219, 137, 114, 105, 237, 69, 23, 72, 245, 208, 255, 73, 175, 57, 164, 185, 153, 173, 149]) }
  , digest := (bytes [243, 48, 230, 250, 171, 200, 23, 144, 239, 125, 190, 97, 64, 231, 85, 156, 181, 125, 99, 44, 123, 75, 196, 5, 131, 89, 80, 112, 201, 100, 16, 227])
}
  , jointOpening := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { proofStatementDigest := (bytes [199, 136, 0, 35, 212, 30, 248, 57, 82, 159, 198, 18, 101, 222, 184, 62, 88, 25, 148, 202, 78, 213, 221, 220, 187, 240, 2, 128, 176, 203, 244, 252]), mainLaneClaimDigest := (bytes [201, 201, 16, 161, 208, 210, 149, 200, 117, 183, 159, 176, 174, 214, 226, 253, 111, 152, 47, 88, 120, 123, 52, 177, 40, 246, 3, 52, 39, 19, 128, 41]), kernelOpeningClaimDigest := (bytes [243, 48, 230, 250, 171, 200, 23, 144, 239, 125, 190, 97, 64, 231, 85, 156, 181, 125, 99, 44, 123, 75, 196, 5, 131, 89, 80, 112, 201, 100, 16, 227]), digest := (bytes [116, 52, 87, 133, 240, 138, 153, 153, 117, 233, 98, 75, 164, 92, 78, 162, 134, 227, 110, 170, 215, 179, 149, 156, 204, 68, 175, 97, 76, 15, 52, 198]) }, digest := (bytes [233, 222, 137, 155, 249, 139, 200, 84, 4, 177, 1, 105, 179, 248, 31, 204, 246, 175, 216, 159, 177, 231, 101, 165, 4, 250, 147, 214, 69, 202, 216, 113]) }
  , root0 := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), stages := { stage1Digest := (bytes [17, 173, 35, 176, 52, 237, 183, 61, 86, 195, 142, 108, 204, 29, 120, 209, 90, 254, 172, 22, 131, 169, 195, 218, 54, 196, 115, 33, 141, 248, 85, 89]), stage2Digest := (bytes [113, 106, 8, 108, 18, 192, 96, 184, 164, 166, 127, 255, 228, 167, 133, 127, 188, 165, 129, 20, 7, 71, 150, 61, 35, 41, 236, 246, 45, 79, 63, 14]), stage3Digest := (bytes [198, 81, 7, 250, 152, 135, 65, 159, 231, 42, 117, 161, 26, 121, 63, 197, 123, 212, 231, 113, 35, 37, 159, 177, 226, 104, 247, 68, 136, 30, 16, 163]), digest := (bytes [199, 242, 212, 155, 43, 234, 95, 172, 150, 153, 4, 104, 11, 53, 62, 78, 12, 107, 147, 90, 55, 127, 167, 138, 174, 163, 47, 236, 117, 65, 123, 197]) }, terminal := { root0Digest := (bytes [98, 18, 188, 175, 27, 205, 179, 130, 57, 12, 232, 219, 38, 211, 175, 110, 23, 173, 187, 111, 225, 55, 139, 25, 196, 177, 64, 5, 240, 114, 106, 227]), executionDigest := (bytes [46, 32, 12, 1, 169, 11, 60, 230, 125, 5, 123, 127, 177, 78, 153, 53, 25, 114, 127, 17, 26, 141, 196, 196, 80, 189, 184, 59, 120, 244, 188, 221]), finalStateDigest := (bytes [103, 119, 166, 83, 71, 235, 116, 157, 66, 6, 65, 91, 76, 196, 146, 226, 246, 68, 215, 2, 4, 30, 194, 108, 206, 35, 183, 164, 172, 191, 117, 48]), transcriptFinalDigest := (bytes [119, 7, 167, 196, 130, 246, 97, 117, 147, 54, 106, 251, 40, 15, 103, 100, 22, 139, 124, 178, 121, 36, 93, 139, 80, 196, 5, 66, 86, 204, 216, 62]), digest := (bytes [63, 237, 157, 146, 1, 94, 140, 78, 81, 122, 27, 254, 102, 147, 28, 112, 98, 18, 223, 245, 68, 110, 11, 139, 56, 49, 112, 107, 119, 68, 228, 187]) }, digest := (bytes [131, 229, 70, 241, 24, 30, 85, 38, 214, 12, 105, 25, 140, 205, 10, 248, 82, 49, 185, 37, 86, 19, 72, 7, 189, 241, 205, 147, 242, 194, 123, 87]) }
  , digest := (bytes [32, 172, 73, 221, 155, 80, 206, 47, 216, 242, 132, 27, 9, 124, 97, 161, 89, 152, 175, 245, 53, 175, 3, 44, 215, 82, 126, 235, 122, 80, 129, 100])
}
  , statement := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , foldSchedule := Nightstream.FoldSchedule.wholeTrace
  , chunkCount := 1
  , stageClaimsDigest := (bytes [243, 68, 218, 224, 114, 170, 185, 59, 140, 151, 48, 75, 105, 99, 122, 132, 237, 231, 239, 198, 37, 220, 251, 111, 58, 141, 246, 229, 194, 30, 49, 239])
  , stagePackagesDigest := (bytes [103, 159, 177, 43, 2, 12, 183, 140, 108, 118, 153, 33, 156, 70, 171, 82, 80, 51, 47, 152, 46, 51, 89, 110, 66, 237, 240, 240, 132, 217, 100, 43])
  , kernelOpeningDigest := (bytes [97, 173, 64, 9, 167, 85, 152, 95, 131, 94, 87, 92, 213, 202, 219, 208, 12, 193, 115, 132, 11, 133, 165, 8, 10, 219, 159, 59, 205, 122, 159, 87])
  , preparedStepBindingsDigest := (bytes [192, 157, 158, 171, 197, 63, 89, 130, 230, 100, 158, 40, 68, 19, 46, 243, 113, 18, 177, 19, 199, 36, 170, 141, 156, 102, 61, 205, 113, 170, 102, 192])
  , executionDigest := (bytes [46, 32, 12, 1, 169, 11, 60, 230, 125, 5, 123, 127, 177, 78, 153, 53, 25, 114, 127, 17, 26, 141, 196, 196, 80, 189, 184, 59, 120, 244, 188, 221])
  , finalStateDigest := (bytes [103, 119, 166, 83, 71, 235, 116, 157, 66, 6, 65, 91, 76, 196, 146, 226, 246, 68, 215, 2, 4, 30, 194, 108, 206, 35, 183, 164, 172, 191, 117, 48])
  , transcriptFinalDigest := (bytes [119, 7, 167, 196, 130, 246, 97, 117, 147, 54, 106, 251, 40, 15, 103, 100, 22, 139, 124, 178, 121, 36, 93, 139, 80, 196, 5, 66, 86, 204, 216, 62])
  , mainLaneSurfaceDigest := (bytes [104, 207, 161, 54, 82, 138, 222, 2, 178, 223, 157, 163, 216, 112, 205, 173, 98, 114, 195, 150, 252, 55, 148, 89, 212, 86, 230, 72, 242, 142, 14, 152])
  , rootLaneColumnsDigest := (bytes [109, 78, 11, 81, 10, 95, 146, 203, 37, 0, 50, 102, 146, 114, 137, 79, 18, 144, 51, 195, 86, 163, 101, 61, 242, 3, 132, 155, 189, 182, 80, 39])
  , publicStepCount := 4
  , initialPc := 0
  , finalPc := 20
  , halted := true
  , digest := (bytes [199, 136, 0, 35, 212, 30, 248, 57, 82, 159, 198, 18, 101, 222, 184, 62, 88, 25, 148, 202, 78, 213, 221, 220, 187, 240, 2, 128, 176, 203, 244, 252])
}
  , kernel := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "control_flow_blt_taken_skip_ecall", fixtureId := "control_flow_blt_taken_skip_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.controlFlow, .nativeAlu] }
  , executionDigest := (bytes [46, 32, 12, 1, 169, 11, 60, 230, 125, 5, 123, 127, 177, 78, 153, 53, 25, 114, 127, 17, 26, 141, 196, 196, 80, 189, 184, 59, 120, 244, 188, 221])
  , shape := { executionRowCount := 4, realRowCount := 4, effectRowCount := 4, commitRowCount := 4, digest := (bytes [45, 178, 181, 197, 132, 60, 130, 1, 239, 208, 160, 249, 86, 246, 26, 179, 94, 235, 136, 250, 242, 5, 139, 0, 36, 216, 225, 255, 232, 86, 248, 123]) }
  , digest := (bytes [196, 26, 136, 122, 213, 208, 195, 92, 124, 69, 178, 0, 92, 124, 214, 171, 169, 245, 214, 201, 52, 17, 60, 22, 108, 28, 172, 142, 76, 53, 245, 132])
}
  , stages := { summary := { stage1RowCount := 4, stage2RegisterReadCount := 4, stage2RegisterWriteCount := 2, stage2RamEventCount := 0, stage2TwistLinkCount := 4, stage3ContinuityCount := 4, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [188, 146, 61, 220, 245, 51, 7, 161, 36, 1, 199, 100, 62, 187, 19, 182, 215, 124, 14, 176, 250, 206, 43, 76, 0, 125, 203, 144, 45, 193, 111, 34]) }, digest := (bytes [109, 34, 58, 13, 68, 111, 109, 31, 96, 208, 232, 119, 140, 198, 44, 192, 184, 71, 199, 65, 42, 115, 36, 133, 68, 13, 13, 169, 75, 7, 175, 245]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [248, 254, 33, 79, 113, 110, 5, 131, 204, 190, 95, 176, 46, 168, 149, 63, 53, 198, 2, 181, 193, 80, 124, 176, 56, 122, 52, 16, 13, 153, 177, 246]), stage1Digest := (bytes [223, 31, 180, 114, 3, 114, 161, 197, 87, 4, 250, 141, 112, 65, 40, 191, 115, 7, 71, 221, 149, 154, 89, 254, 132, 96, 3, 217, 138, 47, 26, 230]), stage2Digest := (bytes [191, 72, 172, 199, 228, 144, 252, 216, 206, 245, 155, 111, 171, 154, 84, 141, 166, 29, 13, 238, 119, 226, 188, 198, 96, 195, 42, 255, 96, 226, 246, 99]), stage3Digest := (bytes [241, 139, 61, 96, 28, 236, 184, 76, 31, 31, 90, 170, 231, 105, 75, 206, 127, 224, 133, 83, 235, 74, 203, 217, 94, 188, 29, 205, 255, 17, 30, 140]), transcriptDigest := (bytes [119, 7, 167, 196, 130, 246, 97, 117, 147, 54, 106, 251, 40, 15, 103, 100, 22, 139, 124, 178, 121, 36, 93, 139, 80, 196, 5, 66, 86, 204, 216, 62]), executionDigest := (bytes [46, 32, 12, 1, 169, 11, 60, 230, 125, 5, 123, 127, 177, 78, 153, 53, 25, 114, 127, 17, 26, 141, 196, 196, 80, 189, 184, 59, 120, 244, 188, 221]), digest := (bytes [101, 228, 44, 88, 13, 183, 105, 13, 221, 39, 134, 220, 242, 175, 246, 160, 1, 44, 117, 252, 194, 132, 235, 60, 80, 59, 6, 31, 13, 254, 21, 223]) }, statementDigest := (bytes [143, 149, 228, 116, 108, 170, 170, 67, 37, 91, 66, 236, 130, 196, 6, 86, 110, 112, 245, 172, 56, 69, 20, 164, 210, 190, 232, 225, 32, 62, 21, 227]), proofDigest := (bytes [223, 201, 6, 133, 146, 17, 237, 100, 94, 189, 154, 213, 116, 219, 178, 79, 148, 165, 139, 78, 209, 117, 159, 110, 42, 110, 163, 132, 7, 212, 40, 165]), digest := (bytes [243, 68, 218, 224, 114, 170, 185, 59, 140, 151, 48, 75, 105, 99, 122, 132, 237, 231, 239, 198, 37, 220, 251, 111, 58, 141, 246, 229, 194, 30, 49, 239]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [1, 150, 13, 248, 98, 208, 148, 74, 34, 80, 169, 225, 228, 184, 163, 211, 239, 161, 173, 168, 210, 66, 122, 140, 174, 10, 147, 76, 184, 141, 166, 186]), stage1Digest := (bytes [9, 211, 167, 148, 204, 209, 99, 130, 11, 103, 22, 106, 135, 209, 58, 212, 168, 170, 233, 94, 97, 173, 34, 173, 80, 5, 232, 148, 135, 61, 64, 211]), stage2Digest := (bytes [164, 191, 220, 178, 15, 86, 66, 181, 212, 191, 196, 106, 218, 239, 88, 61, 29, 136, 37, 196, 125, 237, 155, 97, 22, 137, 176, 135, 114, 113, 25, 60]), stage3Digest := (bytes [219, 79, 76, 23, 16, 156, 135, 61, 31, 134, 135, 16, 225, 146, 125, 59, 4, 56, 137, 89, 215, 205, 155, 245, 214, 170, 53, 2, 224, 13, 36, 12]), digest := (bytes [42, 182, 57, 44, 12, 233, 48, 223, 129, 82, 165, 14, 49, 221, 247, 84, 201, 249, 26, 125, 201, 109, 42, 70, 100, 35, 40, 105, 154, 98, 17, 40]) }, digest := (bytes [103, 159, 177, 43, 2, 12, 183, 140, 108, 118, 153, 33, 156, 70, 171, 82, 80, 51, 47, 152, 46, 51, 89, 110, 66, 237, 240, 240, 132, 217, 100, 43]) }
  , kernelOpening := { openingDigest := (bytes [107, 58, 154, 230, 142, 221, 54, 99, 102, 173, 171, 129, 113, 222, 195, 141, 205, 132, 186, 224, 59, 145, 61, 200, 134, 161, 74, 246, 29, 243, 189, 205]), bindings := { claimDigest := (bytes [228, 51, 66, 220, 114, 155, 173, 21, 216, 253, 174, 182, 252, 242, 0, 113, 218, 44, 146, 169, 13, 168, 49, 151, 229, 129, 125, 240, 182, 51, 3, 55]), bindingsDigest := (bytes [46, 233, 169, 32, 36, 252, 223, 62, 15, 40, 97, 78, 167, 126, 125, 62, 82, 35, 145, 236, 206, 107, 186, 151, 33, 151, 95, 216, 142, 16, 44, 31]), preparedStepsDigest := (bytes [226, 30, 211, 96, 96, 63, 167, 180, 123, 34, 193, 59, 190, 48, 147, 174, 70, 34, 175, 70, 178, 218, 213, 179, 255, 239, 123, 18, 188, 9, 177, 44]), digest := (bytes [76, 6, 163, 185, 135, 85, 69, 126, 231, 57, 39, 106, 29, 166, 242, 129, 46, 204, 21, 197, 133, 240, 100, 191, 233, 162, 39, 188, 181, 177, 203, 49]) }, digest := (bytes [97, 173, 64, 9, 167, 85, 152, 95, 131, 94, 87, 92, 213, 202, 219, 208, 12, 193, 115, 132, 11, 133, 165, 8, 10, 219, 159, 59, 205, 122, 159, 87]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [192, 157, 158, 171, 197, 63, 89, 130, 230, 100, 158, 40, 68, 19, 46, 243, 113, 18, 177, 19, 199, 36, 170, 141, 156, 102, 61, 205, 113, 170, 102, 192]), terminal := { root0Digest := (bytes [98, 18, 188, 175, 27, 205, 179, 130, 57, 12, 232, 219, 38, 211, 175, 110, 23, 173, 187, 111, 225, 55, 139, 25, 196, 177, 64, 5, 240, 114, 106, 227]), executionDigest := (bytes [46, 32, 12, 1, 169, 11, 60, 230, 125, 5, 123, 127, 177, 78, 153, 53, 25, 114, 127, 17, 26, 141, 196, 196, 80, 189, 184, 59, 120, 244, 188, 221]), finalStateDigest := (bytes [103, 119, 166, 83, 71, 235, 116, 157, 66, 6, 65, 91, 76, 196, 146, 226, 246, 68, 215, 2, 4, 30, 194, 108, 206, 35, 183, 164, 172, 191, 117, 48]), transcriptFinalDigest := (bytes [119, 7, 167, 196, 130, 246, 97, 117, 147, 54, 106, 251, 40, 15, 103, 100, 22, 139, 124, 178, 121, 36, 93, 139, 80, 196, 5, 66, 86, 204, 216, 62]), finalPc := 20, halted := true, digest := (bytes [91, 235, 115, 249, 147, 209, 26, 233, 108, 152, 165, 255, 9, 235, 51, 94, 102, 210, 191, 88, 9, 152, 212, 39, 19, 115, 91, 230, 173, 203, 191, 53]) }, digest := (bytes [165, 210, 68, 127, 142, 143, 0, 35, 107, 59, 193, 151, 12, 70, 37, 104, 61, 227, 84, 188, 28, 23, 182, 80, 198, 211, 131, 5, 11, 159, 112, 31]) }, statementDigest := (bytes [140, 226, 248, 131, 105, 165, 226, 9, 246, 59, 96, 204, 72, 149, 237, 189, 119, 170, 171, 217, 51, 103, 251, 69, 96, 187, 203, 253, 31, 160, 208, 80]), proofDigest := (bytes [229, 6, 212, 131, 222, 235, 89, 39, 195, 239, 186, 54, 56, 171, 189, 8, 5, 105, 29, 178, 45, 95, 22, 238, 123, 90, 68, 78, 192, 73, 93, 240]), digest := (bytes [61, 63, 204, 211, 91, 172, 227, 27, 108, 10, 243, 49, 114, 61, 134, 127, 26, 167, 144, 240, 205, 249, 13, 131, 9, 33, 119, 60, 66, 186, 180, 127]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [17, 200, 31, 62, 49, 172, 250, 37, 145, 105, 53, 203, 246, 118, 11, 102, 130, 27, 67, 62, 33, 190, 100, 19, 43, 89, 155, 192, 93, 125, 221, 76]), layoutVersion := 1, digest := (bytes [209, 81, 166, 186, 4, 204, 166, 150, 37, 137, 27, 146, 96, 65, 41, 111, 22, 187, 153, 19, 225, 72, 116, 47, 30, 162, 26, 76, 240, 92, 137, 202]) }, rowWidth := 38, timeLen := 4, columnDigests := [(bytes [212, 186, 229, 172, 74, 68, 211, 103, 24, 241, 21, 82, 209, 33, 189, 99, 223, 36, 129, 167, 9, 173, 76, 108, 178, 222, 90, 225, 89, 142, 8, 14]), (bytes [56, 58, 241, 13, 94, 161, 102, 38, 209, 85, 101, 10, 115, 74, 68, 15, 139, 16, 65, 164, 142, 61, 38, 80, 159, 19, 8, 220, 33, 174, 155, 155]), (bytes [29, 30, 250, 119, 67, 192, 190, 83, 169, 199, 126, 126, 209, 9, 207, 51, 13, 31, 240, 215, 38, 77, 233, 53, 71, 218, 94, 76, 41, 218, 33, 58]), (bytes [181, 122, 105, 181, 35, 180, 95, 214, 79, 41, 41, 2, 114, 48, 216, 55, 223, 211, 166, 64, 24, 33, 244, 234, 111, 10, 124, 63, 69, 70, 27, 116]), (bytes [235, 168, 211, 18, 219, 164, 123, 11, 1, 214, 235, 228, 142, 231, 19, 191, 111, 116, 112, 196, 167, 65, 6, 113, 150, 204, 141, 39, 111, 24, 165, 153]), (bytes [2, 223, 179, 210, 209, 205, 146, 17, 164, 217, 202, 178, 34, 24, 81, 6, 189, 236, 155, 58, 107, 97, 35, 210, 41, 139, 124, 249, 115, 65, 71, 53]), (bytes [148, 93, 109, 35, 88, 87, 157, 97, 249, 179, 2, 2, 221, 198, 208, 66, 170, 138, 243, 110, 6, 236, 227, 101, 91, 65, 171, 243, 200, 198, 189, 148]), (bytes [132, 13, 123, 172, 120, 106, 189, 241, 207, 17, 23, 219, 168, 136, 164, 0, 142, 128, 126, 198, 69, 95, 67, 194, 148, 13, 102, 136, 180, 146, 31, 139]), (bytes [13, 51, 13, 112, 10, 98, 204, 18, 53, 169, 156, 155, 63, 147, 114, 64, 241, 138, 154, 179, 238, 77, 114, 193, 171, 122, 197, 145, 246, 175, 206, 33]), (bytes [232, 60, 34, 59, 99, 35, 37, 101, 97, 80, 246, 173, 253, 205, 108, 125, 30, 217, 170, 112, 111, 96, 190, 85, 240, 167, 219, 144, 235, 27, 30, 175]), (bytes [33, 226, 191, 51, 76, 109, 28, 150, 35, 183, 64, 252, 90, 183, 140, 34, 61, 65, 9, 61, 233, 26, 98, 58, 22, 113, 219, 130, 57, 126, 25, 166]), (bytes [118, 132, 140, 41, 46, 54, 170, 167, 122, 118, 200, 245, 49, 89, 177, 77, 198, 10, 78, 179, 11, 224, 33, 204, 58, 199, 196, 82, 84, 72, 223, 144]), (bytes [205, 50, 239, 174, 62, 102, 47, 47, 168, 229, 99, 79, 130, 123, 211, 62, 86, 5, 136, 142, 232, 236, 222, 93, 139, 184, 152, 44, 168, 14, 179, 91]), (bytes [103, 53, 107, 4, 189, 132, 244, 169, 29, 6, 184, 32, 91, 82, 178, 107, 52, 16, 254, 231, 248, 28, 125, 77, 103, 211, 79, 63, 83, 74, 140, 122]), (bytes [134, 141, 124, 169, 119, 38, 249, 119, 111, 250, 40, 3, 85, 79, 214, 122, 209, 119, 227, 254, 195, 29, 190, 77, 250, 140, 202, 20, 171, 232, 229, 55]), (bytes [220, 193, 230, 244, 243, 14, 93, 42, 216, 108, 251, 253, 94, 191, 212, 189, 13, 211, 94, 236, 218, 138, 122, 7, 190, 222, 130, 249, 182, 150, 137, 189]), (bytes [223, 89, 191, 11, 110, 102, 31, 137, 129, 115, 137, 48, 64, 221, 208, 112, 235, 228, 24, 226, 254, 59, 16, 16, 192, 134, 30, 101, 212, 162, 156, 187]), (bytes [156, 22, 213, 157, 3, 147, 139, 132, 146, 22, 57, 209, 56, 31, 20, 20, 229, 105, 89, 38, 226, 230, 110, 49, 208, 70, 178, 10, 75, 21, 225, 62]), (bytes [89, 6, 118, 169, 105, 54, 5, 121, 26, 253, 91, 160, 13, 78, 211, 28, 177, 107, 187, 177, 10, 185, 35, 168, 191, 215, 99, 41, 155, 74, 182, 15]), (bytes [16, 1, 45, 207, 125, 115, 77, 40, 96, 249, 191, 96, 68, 155, 161, 144, 89, 205, 15, 173, 177, 139, 3, 87, 248, 132, 221, 254, 91, 235, 118, 133]), (bytes [2, 197, 213, 149, 21, 90, 236, 108, 141, 146, 26, 38, 0, 78, 135, 95, 223, 228, 221, 179, 125, 245, 167, 198, 49, 196, 48, 128, 192, 39, 124, 49]), (bytes [130, 134, 127, 131, 40, 47, 149, 206, 210, 112, 225, 17, 66, 25, 14, 78, 65, 235, 99, 73, 206, 90, 67, 148, 19, 78, 146, 25, 197, 149, 108, 61]), (bytes [8, 234, 67, 158, 76, 76, 170, 16, 58, 161, 138, 98, 35, 61, 115, 114, 104, 189, 45, 62, 96, 35, 11, 160, 56, 73, 223, 212, 106, 84, 224, 145]), (bytes [0, 189, 116, 3, 67, 124, 251, 249, 47, 128, 49, 73, 210, 47, 86, 252, 162, 78, 171, 9, 96, 183, 112, 195, 81, 120, 202, 223, 242, 24, 76, 51]), (bytes [81, 144, 1, 221, 155, 166, 187, 155, 181, 172, 254, 158, 176, 149, 110, 161, 164, 146, 156, 197, 231, 227, 176, 108, 72, 168, 128, 97, 162, 214, 166, 78]), (bytes [238, 147, 134, 181, 8, 29, 128, 200, 221, 198, 65, 181, 234, 22, 117, 159, 112, 0, 90, 214, 190, 69, 86, 72, 209, 196, 234, 23, 145, 109, 49, 190]), (bytes [150, 94, 21, 115, 92, 3, 250, 46, 250, 39, 23, 156, 66, 177, 198, 103, 242, 34, 109, 175, 253, 18, 181, 44, 23, 6, 9, 9, 119, 235, 11, 108]), (bytes [135, 215, 141, 47, 156, 11, 54, 54, 3, 72, 179, 247, 223, 155, 104, 7, 155, 222, 232, 159, 97, 172, 115, 97, 167, 121, 212, 57, 156, 44, 117, 203]), (bytes [84, 95, 115, 25, 213, 106, 24, 56, 216, 206, 94, 157, 100, 187, 198, 197, 93, 1, 173, 134, 90, 112, 47, 80, 254, 7, 54, 249, 32, 132, 243, 167]), (bytes [130, 198, 251, 47, 44, 43, 143, 92, 82, 195, 92, 157, 42, 215, 42, 26, 5, 251, 108, 34, 34, 0, 80, 113, 213, 113, 25, 247, 190, 124, 74, 52]), (bytes [234, 182, 234, 160, 23, 192, 246, 199, 173, 187, 203, 106, 254, 25, 134, 196, 2, 40, 181, 117, 170, 220, 56, 86, 63, 246, 0, 182, 78, 16, 61, 77]), (bytes [40, 254, 204, 213, 6, 140, 117, 235, 134, 79, 86, 81, 169, 63, 60, 118, 8, 156, 87, 198, 194, 60, 29, 160, 125, 250, 15, 187, 147, 220, 29, 92]), (bytes [18, 187, 180, 226, 104, 66, 42, 243, 22, 156, 53, 240, 151, 142, 203, 83, 91, 143, 153, 183, 211, 14, 178, 15, 249, 35, 88, 211, 226, 167, 221, 238]), (bytes [164, 40, 127, 229, 211, 147, 121, 221, 253, 56, 242, 238, 25, 160, 231, 5, 98, 88, 35, 198, 216, 51, 242, 34, 196, 132, 1, 62, 202, 49, 246, 41]), (bytes [122, 105, 77, 66, 174, 33, 37, 82, 171, 117, 60, 146, 152, 71, 176, 9, 4, 214, 95, 111, 117, 16, 77, 11, 22, 12, 202, 53, 36, 93, 76, 79]), (bytes [190, 26, 99, 184, 175, 199, 251, 124, 134, 183, 220, 35, 196, 195, 152, 135, 36, 169, 87, 198, 14, 22, 245, 143, 20, 239, 221, 18, 139, 77, 165, 236]), (bytes [80, 33, 41, 82, 68, 242, 18, 200, 209, 172, 125, 228, 155, 229, 192, 181, 222, 62, 254, 113, 197, 197, 209, 167, 162, 245, 86, 19, 189, 248, 96, 43]), (bytes [90, 10, 190, 250, 226, 23, 47, 210, 182, 164, 148, 175, 37, 226, 99, 192, 247, 166, 149, 66, 95, 29, 230, 232, 50, 99, 224, 203, 78, 177, 221, 250])], familyDigest := (bytes [17, 200, 31, 62, 49, 172, 250, 37, 145, 105, 53, 203, 246, 118, 11, 102, 130, 27, 67, 62, 33, 190, 100, 19, 43, 89, 155, 192, 93, 125, 221, 76]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [17, 200, 31, 62, 49, 172, 250, 37, 145, 105, 53, 203, 246, 118, 11, 102, 130, 27, 67, 62, 33, 190, 100, 19, 43, 89, 155, 192, 93, 125, 221, 76]), layoutVersion := 1, digest := (bytes [209, 81, 166, 186, 4, 204, 166, 150, 37, 137, 27, 146, 96, 65, 41, 111, 22, 187, 153, 19, 225, 72, 116, 47, 30, 162, 26, 76, 240, 92, 137, 202]) }, logicalIndex := 0, digest := (bytes [74, 163, 169, 52, 59, 19, 192, 199, 26, 28, 140, 249, 102, 6, 101, 159, 107, 24, 248, 134, 243, 34, 87, 85, 72, 167, 66, 239, 150, 191, 249, 200]) }, valueDigest := (bytes [59, 110, 73, 184, 21, 134, 14, 247, 63, 174, 178, 199, 142, 253, 82, 19, 165, 139, 8, 196, 235, 194, 3, 121, 51, 124, 231, 35, 211, 16, 32, 52]), digest := (bytes [226, 218, 13, 4, 55, 80, 197, 195, 76, 108, 24, 197, 233, 230, 155, 103, 218, 151, 128, 91, 234, 235, 98, 162, 237, 158, 247, 170, 217, 3, 134, 70]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [17, 200, 31, 62, 49, 172, 250, 37, 145, 105, 53, 203, 246, 118, 11, 102, 130, 27, 67, 62, 33, 190, 100, 19, 43, 89, 155, 192, 93, 125, 221, 76]), layoutVersion := 1, digest := (bytes [209, 81, 166, 186, 4, 204, 166, 150, 37, 137, 27, 146, 96, 65, 41, 111, 22, 187, 153, 19, 225, 72, 116, 47, 30, 162, 26, 76, 240, 92, 137, 202]) }, logicalIndex := 3, digest := (bytes [83, 176, 155, 12, 128, 45, 187, 248, 3, 198, 3, 196, 135, 231, 240, 194, 102, 143, 106, 53, 186, 216, 189, 103, 2, 215, 13, 68, 157, 15, 93, 68]) }, valueDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [39, 255, 14, 211, 207, 209, 24, 34, 167, 228, 216, 123, 174, 173, 128, 46, 62, 57, 217, 213, 2, 205, 57, 34, 161, 52, 77, 9, 243, 115, 76, 211]) }), digest := (bytes [109, 78, 11, 81, 10, 95, 146, 203, 37, 0, 50, 102, 146, 114, 137, 79, 18, 144, 51, 195, 86, 163, 101, 61, 242, 3, 132, 155, 189, 182, 80, 39]) }
  , rootLaneCommitment := { timeLen := 4, commitments := { commitmentCount := 38, digest := (bytes [116, 93, 153, 130, 232, 216, 210, 83, 127, 32, 104, 122, 68, 45, 119, 16, 13, 205, 151, 193, 226, 131, 66, 171, 100, 131, 124, 207, 194, 84, 69, 216]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [116, 93, 153, 130, 232, 216, 210, 83, 127, 32, 104, 122, 68, 45, 119, 16, 13, 205, 151, 193, 226, 131, 66, 171, 100, 131, 124, 207, 194, 84, 69, 216]), layoutVersion := 3, digest := (bytes [206, 160, 212, 132, 68, 145, 205, 36, 65, 72, 189, 84, 106, 232, 12, 218, 83, 49, 212, 75, 8, 104, 8, 151, 141, 222, 235, 221, 213, 211, 202, 152]) }, logicalIndex := 0, digest := (bytes [14, 92, 10, 244, 78, 56, 77, 247, 46, 29, 154, 26, 176, 243, 170, 204, 158, 255, 34, 89, 33, 167, 78, 81, 90, 132, 32, 174, 4, 30, 129, 198]) }, valueDigest := (bytes [59, 110, 73, 184, 21, 134, 14, 247, 63, 174, 178, 199, 142, 253, 82, 19, 165, 139, 8, 196, 235, 194, 3, 121, 51, 124, 231, 35, 211, 16, 32, 52]), digest := (bytes [219, 218, 219, 174, 165, 130, 251, 88, 206, 16, 80, 0, 28, 86, 170, 191, 249, 191, 4, 236, 79, 80, 162, 191, 249, 161, 174, 139, 196, 157, 147, 124]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [116, 93, 153, 130, 232, 216, 210, 83, 127, 32, 104, 122, 68, 45, 119, 16, 13, 205, 151, 193, 226, 131, 66, 171, 100, 131, 124, 207, 194, 84, 69, 216]), layoutVersion := 3, digest := (bytes [206, 160, 212, 132, 68, 145, 205, 36, 65, 72, 189, 84, 106, 232, 12, 218, 83, 49, 212, 75, 8, 104, 8, 151, 141, 222, 235, 221, 213, 211, 202, 152]) }, logicalIndex := 3, digest := (bytes [170, 208, 237, 65, 75, 119, 119, 72, 219, 13, 34, 89, 241, 82, 231, 86, 162, 51, 20, 251, 135, 220, 233, 188, 249, 237, 246, 151, 96, 52, 237, 174]) }, valueDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [93, 157, 36, 36, 118, 242, 203, 241, 13, 166, 55, 56, 153, 196, 21, 43, 180, 209, 165, 227, 227, 152, 171, 214, 55, 182, 39, 224, 113, 54, 207, 193]) }), digest := (bytes [173, 179, 33, 189, 187, 191, 177, 180, 128, 209, 106, 82, 101, 161, 51, 198, 78, 189, 60, 236, 72, 131, 100, 76, 191, 155, 96, 159, 125, 38, 9, 222]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [109, 78, 11, 81, 10, 95, 146, 203, 37, 0, 50, 102, 146, 114, 137, 79, 18, 144, 51, 195, 86, 163, 101, 61, 242, 3, 132, 155, 189, 182, 80, 39]), rootLaneCommitmentDigest := (bytes [173, 179, 33, 189, 187, 191, 177, 180, 128, 209, 106, 82, 101, 161, 51, 198, 78, 189, 60, 236, 72, 131, 100, 76, 191, 155, 96, 159, 125, 38, 9, 222]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 4, digest := (bytes [69, 198, 181, 31, 1, 82, 207, 80, 49, 145, 106, 234, 47, 152, 166, 167, 63, 253, 95, 41, 215, 15, 110, 210, 230, 54, 36, 253, 97, 206, 221, 44]) }, statementDigest := (bytes [243, 11, 20, 125, 199, 20, 35, 50, 23, 6, 226, 42, 212, 106, 174, 82, 204, 153, 180, 0, 253, 47, 62, 199, 146, 177, 65, 197, 37, 161, 193, 26]), proofDigest := (bytes [179, 50, 115, 34, 156, 230, 119, 223, 90, 255, 82, 147, 133, 148, 105, 168, 198, 209, 236, 197, 7, 9, 42, 41, 0, 25, 175, 56, 15, 211, 199, 185]), digest := (bytes [247, 226, 241, 187, 96, 204, 66, 130, 5, 31, 120, 64, 209, 158, 104, 12, 193, 149, 56, 123, 58, 80, 81, 90, 181, 31, 184, 242, 179, 137, 141, 150]) }
  , digest := (bytes [223, 126, 79, 134, 8, 241, 122, 213, 45, 95, 249, 223, 68, 72, 29, 226, 49, 131, 7, 43, 44, 114, 47, 212, 117, 118, 213, 188, 145, 166, 230, 154])
}
}
    , exportedStatement := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , foldSchedule := Nightstream.FoldSchedule.wholeTrace
  , chunkCount := 1
  , stageClaimsDigest := (bytes [243, 68, 218, 224, 114, 170, 185, 59, 140, 151, 48, 75, 105, 99, 122, 132, 237, 231, 239, 198, 37, 220, 251, 111, 58, 141, 246, 229, 194, 30, 49, 239])
  , stagePackagesDigest := (bytes [103, 159, 177, 43, 2, 12, 183, 140, 108, 118, 153, 33, 156, 70, 171, 82, 80, 51, 47, 152, 46, 51, 89, 110, 66, 237, 240, 240, 132, 217, 100, 43])
  , kernelOpeningDigest := (bytes [97, 173, 64, 9, 167, 85, 152, 95, 131, 94, 87, 92, 213, 202, 219, 208, 12, 193, 115, 132, 11, 133, 165, 8, 10, 219, 159, 59, 205, 122, 159, 87])
  , preparedStepBindingsDigest := (bytes [192, 157, 158, 171, 197, 63, 89, 130, 230, 100, 158, 40, 68, 19, 46, 243, 113, 18, 177, 19, 199, 36, 170, 141, 156, 102, 61, 205, 113, 170, 102, 192])
  , executionDigest := (bytes [46, 32, 12, 1, 169, 11, 60, 230, 125, 5, 123, 127, 177, 78, 153, 53, 25, 114, 127, 17, 26, 141, 196, 196, 80, 189, 184, 59, 120, 244, 188, 221])
  , finalStateDigest := (bytes [103, 119, 166, 83, 71, 235, 116, 157, 66, 6, 65, 91, 76, 196, 146, 226, 246, 68, 215, 2, 4, 30, 194, 108, 206, 35, 183, 164, 172, 191, 117, 48])
  , transcriptFinalDigest := (bytes [119, 7, 167, 196, 130, 246, 97, 117, 147, 54, 106, 251, 40, 15, 103, 100, 22, 139, 124, 178, 121, 36, 93, 139, 80, 196, 5, 66, 86, 204, 216, 62])
  , mainLaneSurfaceDigest := (bytes [104, 207, 161, 54, 82, 138, 222, 2, 178, 223, 157, 163, 216, 112, 205, 173, 98, 114, 195, 150, 252, 55, 148, 89, 212, 86, 230, 72, 242, 142, 14, 152])
  , rootLaneColumnsDigest := (bytes [109, 78, 11, 81, 10, 95, 146, 203, 37, 0, 50, 102, 146, 114, 137, 79, 18, 144, 51, 195, 86, 163, 101, 61, 242, 3, 132, 155, 189, 182, 80, 39])
  , publicStepCount := 4
  , initialPc := 0
  , finalPc := 20
  , halted := true
  , digest := (bytes [199, 136, 0, 35, 212, 30, 248, 57, 82, 159, 198, 18, 101, 222, 184, 62, 88, 25, 148, 202, 78, 213, 221, 220, 187, 240, 2, 128, 176, 203, 244, 252])
}
    , exportedClaims := {
  accepted := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , statement := { proofStatementDigest := (bytes [199, 136, 0, 35, 212, 30, 248, 57, 82, 159, 198, 18, 101, 222, 184, 62, 88, 25, 148, 202, 78, 213, 221, 220, 187, 240, 2, 128, 176, 203, 244, 252]), kernelOpeningDigest := (bytes [97, 173, 64, 9, 167, 85, 152, 95, 131, 94, 87, 92, 213, 202, 219, 208, 12, 193, 115, 132, 11, 133, 165, 8, 10, 219, 159, 59, 205, 122, 159, 87]), digest := (bytes [26, 34, 159, 162, 0, 78, 148, 235, 157, 177, 141, 63, 223, 174, 100, 145, 202, 189, 160, 79, 78, 245, 23, 140, 68, 1, 137, 116, 11, 146, 96, 149]) }
  , mainLane := { mainLaneBundleDigest := (bytes [247, 226, 241, 187, 96, 204, 66, 130, 5, 31, 120, 64, 209, 158, 104, 12, 193, 149, 56, 123, 58, 80, 81, 90, 181, 31, 184, 242, 179, 137, 141, 150]), digest := (bytes [155, 220, 136, 114, 133, 51, 43, 75, 206, 134, 231, 240, 97, 86, 41, 181, 124, 22, 157, 200, 189, 42, 49, 9, 142, 50, 132, 90, 31, 242, 211, 90]) }
  , terminal := { finalStateDigest := (bytes [103, 119, 166, 83, 71, 235, 116, 157, 66, 6, 65, 91, 76, 196, 146, 226, 246, 68, 215, 2, 4, 30, 194, 108, 206, 35, 183, 164, 172, 191, 117, 48]), finalPc := 20, halted := true, digest := (bytes [75, 37, 1, 63, 9, 237, 150, 194, 191, 94, 240, 80, 37, 47, 206, 233, 56, 244, 48, 202, 88, 196, 136, 246, 8, 177, 86, 219, 203, 132, 68, 89]) }
  , digest := (bytes [149, 63, 234, 234, 197, 128, 164, 15, 241, 165, 105, 166, 149, 42, 143, 75, 26, 191, 12, 80, 134, 137, 239, 67, 245, 153, 145, 172, 163, 204, 139, 171])
}
  , mainLane := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { mainLaneBundleDigest := (bytes [247, 226, 241, 187, 96, 204, 66, 130, 5, 31, 120, 64, 209, 158, 104, 12, 193, 149, 56, 123, 58, 80, 81, 90, 181, 31, 184, 242, 179, 137, 141, 150]), digest := (bytes [129, 179, 37, 166, 172, 211, 55, 230, 245, 40, 48, 31, 94, 41, 4, 51, 85, 81, 220, 37, 200, 62, 198, 28, 30, 208, 197, 143, 36, 97, 5, 240]) }, digest := (bytes [201, 201, 16, 161, 208, 210, 149, 200, 117, 183, 159, 176, 174, 214, 226, 253, 111, 152, 47, 88, 120, 123, 52, 177, 40, 246, 3, 52, 39, 19, 128, 41]) }
  , opening := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , stages := { stageClaimsDigest := (bytes [243, 68, 218, 224, 114, 170, 185, 59, 140, 151, 48, 75, 105, 99, 122, 132, 237, 231, 239, 198, 37, 220, 251, 111, 58, 141, 246, 229, 194, 30, 49, 239]), stagePackagesDigest := (bytes [103, 159, 177, 43, 2, 12, 183, 140, 108, 118, 153, 33, 156, 70, 171, 82, 80, 51, 47, 152, 46, 51, 89, 110, 66, 237, 240, 240, 132, 217, 100, 43]), kernelOpeningDigest := (bytes [97, 173, 64, 9, 167, 85, 152, 95, 131, 94, 87, 92, 213, 202, 219, 208, 12, 193, 115, 132, 11, 133, 165, 8, 10, 219, 159, 59, 205, 122, 159, 87]), digest := (bytes [45, 89, 67, 37, 220, 97, 241, 91, 163, 107, 115, 157, 34, 116, 153, 217, 74, 73, 43, 149, 24, 71, 189, 183, 160, 13, 51, 76, 136, 5, 224, 227]) }
  , terminal := { preparedStepBindingsDigest := (bytes [192, 157, 158, 171, 197, 63, 89, 130, 230, 100, 158, 40, 68, 19, 46, 243, 113, 18, 177, 19, 199, 36, 170, 141, 156, 102, 61, 205, 113, 170, 102, 192]), executionDigest := (bytes [46, 32, 12, 1, 169, 11, 60, 230, 125, 5, 123, 127, 177, 78, 153, 53, 25, 114, 127, 17, 26, 141, 196, 196, 80, 189, 184, 59, 120, 244, 188, 221]), transcriptFinalDigest := (bytes [119, 7, 167, 196, 130, 246, 97, 117, 147, 54, 106, 251, 40, 15, 103, 100, 22, 139, 124, 178, 121, 36, 93, 139, 80, 196, 5, 66, 86, 204, 216, 62]), digest := (bytes [160, 9, 236, 38, 47, 178, 251, 33, 23, 226, 207, 204, 48, 219, 137, 114, 105, 237, 69, 23, 72, 245, 208, 255, 73, 175, 57, 164, 185, 153, 173, 149]) }
  , digest := (bytes [243, 48, 230, 250, 171, 200, 23, 144, 239, 125, 190, 97, 64, 231, 85, 156, 181, 125, 99, 44, 123, 75, 196, 5, 131, 89, 80, 112, 201, 100, 16, 227])
}
  , jointOpening := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { proofStatementDigest := (bytes [199, 136, 0, 35, 212, 30, 248, 57, 82, 159, 198, 18, 101, 222, 184, 62, 88, 25, 148, 202, 78, 213, 221, 220, 187, 240, 2, 128, 176, 203, 244, 252]), mainLaneClaimDigest := (bytes [201, 201, 16, 161, 208, 210, 149, 200, 117, 183, 159, 176, 174, 214, 226, 253, 111, 152, 47, 88, 120, 123, 52, 177, 40, 246, 3, 52, 39, 19, 128, 41]), kernelOpeningClaimDigest := (bytes [243, 48, 230, 250, 171, 200, 23, 144, 239, 125, 190, 97, 64, 231, 85, 156, 181, 125, 99, 44, 123, 75, 196, 5, 131, 89, 80, 112, 201, 100, 16, 227]), digest := (bytes [116, 52, 87, 133, 240, 138, 153, 153, 117, 233, 98, 75, 164, 92, 78, 162, 134, 227, 110, 170, 215, 179, 149, 156, 204, 68, 175, 97, 76, 15, 52, 198]) }, digest := (bytes [233, 222, 137, 155, 249, 139, 200, 84, 4, 177, 1, 105, 179, 248, 31, 204, 246, 175, 216, 159, 177, 231, 101, 165, 4, 250, 147, 214, 69, 202, 216, 113]) }
  , root0 := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), stages := { stage1Digest := (bytes [17, 173, 35, 176, 52, 237, 183, 61, 86, 195, 142, 108, 204, 29, 120, 209, 90, 254, 172, 22, 131, 169, 195, 218, 54, 196, 115, 33, 141, 248, 85, 89]), stage2Digest := (bytes [113, 106, 8, 108, 18, 192, 96, 184, 164, 166, 127, 255, 228, 167, 133, 127, 188, 165, 129, 20, 7, 71, 150, 61, 35, 41, 236, 246, 45, 79, 63, 14]), stage3Digest := (bytes [198, 81, 7, 250, 152, 135, 65, 159, 231, 42, 117, 161, 26, 121, 63, 197, 123, 212, 231, 113, 35, 37, 159, 177, 226, 104, 247, 68, 136, 30, 16, 163]), digest := (bytes [199, 242, 212, 155, 43, 234, 95, 172, 150, 153, 4, 104, 11, 53, 62, 78, 12, 107, 147, 90, 55, 127, 167, 138, 174, 163, 47, 236, 117, 65, 123, 197]) }, terminal := { root0Digest := (bytes [98, 18, 188, 175, 27, 205, 179, 130, 57, 12, 232, 219, 38, 211, 175, 110, 23, 173, 187, 111, 225, 55, 139, 25, 196, 177, 64, 5, 240, 114, 106, 227]), executionDigest := (bytes [46, 32, 12, 1, 169, 11, 60, 230, 125, 5, 123, 127, 177, 78, 153, 53, 25, 114, 127, 17, 26, 141, 196, 196, 80, 189, 184, 59, 120, 244, 188, 221]), finalStateDigest := (bytes [103, 119, 166, 83, 71, 235, 116, 157, 66, 6, 65, 91, 76, 196, 146, 226, 246, 68, 215, 2, 4, 30, 194, 108, 206, 35, 183, 164, 172, 191, 117, 48]), transcriptFinalDigest := (bytes [119, 7, 167, 196, 130, 246, 97, 117, 147, 54, 106, 251, 40, 15, 103, 100, 22, 139, 124, 178, 121, 36, 93, 139, 80, 196, 5, 66, 86, 204, 216, 62]), digest := (bytes [63, 237, 157, 146, 1, 94, 140, 78, 81, 122, 27, 254, 102, 147, 28, 112, 98, 18, 223, 245, 68, 110, 11, 139, 56, 49, 112, 107, 119, 68, 228, 187]) }, digest := (bytes [131, 229, 70, 241, 24, 30, 85, 38, 214, 12, 105, 25, 140, 205, 10, 248, 82, 49, 185, 37, 86, 19, 72, 7, 189, 241, 205, 147, 242, 194, 123, 87]) }
  , digest := (bytes [32, 172, 73, 221, 155, 80, 206, 47, 216, 242, 132, 27, 9, 124, 97, 161, 89, 152, 175, 245, 53, 175, 3, 44, 215, 82, 126, 235, 122, 80, 129, 100])
}
    , exportedKernelProof := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "control_flow_blt_taken_skip_ecall", fixtureId := "control_flow_blt_taken_skip_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.controlFlow, .nativeAlu] }
  , executionDigest := (bytes [46, 32, 12, 1, 169, 11, 60, 230, 125, 5, 123, 127, 177, 78, 153, 53, 25, 114, 127, 17, 26, 141, 196, 196, 80, 189, 184, 59, 120, 244, 188, 221])
  , shape := { executionRowCount := 4, realRowCount := 4, effectRowCount := 4, commitRowCount := 4, digest := (bytes [45, 178, 181, 197, 132, 60, 130, 1, 239, 208, 160, 249, 86, 246, 26, 179, 94, 235, 136, 250, 242, 5, 139, 0, 36, 216, 225, 255, 232, 86, 248, 123]) }
  , digest := (bytes [196, 26, 136, 122, 213, 208, 195, 92, 124, 69, 178, 0, 92, 124, 214, 171, 169, 245, 214, 201, 52, 17, 60, 22, 108, 28, 172, 142, 76, 53, 245, 132])
}
  , stages := { summary := { stage1RowCount := 4, stage2RegisterReadCount := 4, stage2RegisterWriteCount := 2, stage2RamEventCount := 0, stage2TwistLinkCount := 4, stage3ContinuityCount := 4, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [188, 146, 61, 220, 245, 51, 7, 161, 36, 1, 199, 100, 62, 187, 19, 182, 215, 124, 14, 176, 250, 206, 43, 76, 0, 125, 203, 144, 45, 193, 111, 34]) }, digest := (bytes [109, 34, 58, 13, 68, 111, 109, 31, 96, 208, 232, 119, 140, 198, 44, 192, 184, 71, 199, 65, 42, 115, 36, 133, 68, 13, 13, 169, 75, 7, 175, 245]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [248, 254, 33, 79, 113, 110, 5, 131, 204, 190, 95, 176, 46, 168, 149, 63, 53, 198, 2, 181, 193, 80, 124, 176, 56, 122, 52, 16, 13, 153, 177, 246]), stage1Digest := (bytes [223, 31, 180, 114, 3, 114, 161, 197, 87, 4, 250, 141, 112, 65, 40, 191, 115, 7, 71, 221, 149, 154, 89, 254, 132, 96, 3, 217, 138, 47, 26, 230]), stage2Digest := (bytes [191, 72, 172, 199, 228, 144, 252, 216, 206, 245, 155, 111, 171, 154, 84, 141, 166, 29, 13, 238, 119, 226, 188, 198, 96, 195, 42, 255, 96, 226, 246, 99]), stage3Digest := (bytes [241, 139, 61, 96, 28, 236, 184, 76, 31, 31, 90, 170, 231, 105, 75, 206, 127, 224, 133, 83, 235, 74, 203, 217, 94, 188, 29, 205, 255, 17, 30, 140]), transcriptDigest := (bytes [119, 7, 167, 196, 130, 246, 97, 117, 147, 54, 106, 251, 40, 15, 103, 100, 22, 139, 124, 178, 121, 36, 93, 139, 80, 196, 5, 66, 86, 204, 216, 62]), executionDigest := (bytes [46, 32, 12, 1, 169, 11, 60, 230, 125, 5, 123, 127, 177, 78, 153, 53, 25, 114, 127, 17, 26, 141, 196, 196, 80, 189, 184, 59, 120, 244, 188, 221]), digest := (bytes [101, 228, 44, 88, 13, 183, 105, 13, 221, 39, 134, 220, 242, 175, 246, 160, 1, 44, 117, 252, 194, 132, 235, 60, 80, 59, 6, 31, 13, 254, 21, 223]) }, statementDigest := (bytes [143, 149, 228, 116, 108, 170, 170, 67, 37, 91, 66, 236, 130, 196, 6, 86, 110, 112, 245, 172, 56, 69, 20, 164, 210, 190, 232, 225, 32, 62, 21, 227]), proofDigest := (bytes [223, 201, 6, 133, 146, 17, 237, 100, 94, 189, 154, 213, 116, 219, 178, 79, 148, 165, 139, 78, 209, 117, 159, 110, 42, 110, 163, 132, 7, 212, 40, 165]), digest := (bytes [243, 68, 218, 224, 114, 170, 185, 59, 140, 151, 48, 75, 105, 99, 122, 132, 237, 231, 239, 198, 37, 220, 251, 111, 58, 141, 246, 229, 194, 30, 49, 239]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [1, 150, 13, 248, 98, 208, 148, 74, 34, 80, 169, 225, 228, 184, 163, 211, 239, 161, 173, 168, 210, 66, 122, 140, 174, 10, 147, 76, 184, 141, 166, 186]), stage1Digest := (bytes [9, 211, 167, 148, 204, 209, 99, 130, 11, 103, 22, 106, 135, 209, 58, 212, 168, 170, 233, 94, 97, 173, 34, 173, 80, 5, 232, 148, 135, 61, 64, 211]), stage2Digest := (bytes [164, 191, 220, 178, 15, 86, 66, 181, 212, 191, 196, 106, 218, 239, 88, 61, 29, 136, 37, 196, 125, 237, 155, 97, 22, 137, 176, 135, 114, 113, 25, 60]), stage3Digest := (bytes [219, 79, 76, 23, 16, 156, 135, 61, 31, 134, 135, 16, 225, 146, 125, 59, 4, 56, 137, 89, 215, 205, 155, 245, 214, 170, 53, 2, 224, 13, 36, 12]), digest := (bytes [42, 182, 57, 44, 12, 233, 48, 223, 129, 82, 165, 14, 49, 221, 247, 84, 201, 249, 26, 125, 201, 109, 42, 70, 100, 35, 40, 105, 154, 98, 17, 40]) }, digest := (bytes [103, 159, 177, 43, 2, 12, 183, 140, 108, 118, 153, 33, 156, 70, 171, 82, 80, 51, 47, 152, 46, 51, 89, 110, 66, 237, 240, 240, 132, 217, 100, 43]) }
  , kernelOpening := { openingDigest := (bytes [107, 58, 154, 230, 142, 221, 54, 99, 102, 173, 171, 129, 113, 222, 195, 141, 205, 132, 186, 224, 59, 145, 61, 200, 134, 161, 74, 246, 29, 243, 189, 205]), bindings := { claimDigest := (bytes [228, 51, 66, 220, 114, 155, 173, 21, 216, 253, 174, 182, 252, 242, 0, 113, 218, 44, 146, 169, 13, 168, 49, 151, 229, 129, 125, 240, 182, 51, 3, 55]), bindingsDigest := (bytes [46, 233, 169, 32, 36, 252, 223, 62, 15, 40, 97, 78, 167, 126, 125, 62, 82, 35, 145, 236, 206, 107, 186, 151, 33, 151, 95, 216, 142, 16, 44, 31]), preparedStepsDigest := (bytes [226, 30, 211, 96, 96, 63, 167, 180, 123, 34, 193, 59, 190, 48, 147, 174, 70, 34, 175, 70, 178, 218, 213, 179, 255, 239, 123, 18, 188, 9, 177, 44]), digest := (bytes [76, 6, 163, 185, 135, 85, 69, 126, 231, 57, 39, 106, 29, 166, 242, 129, 46, 204, 21, 197, 133, 240, 100, 191, 233, 162, 39, 188, 181, 177, 203, 49]) }, digest := (bytes [97, 173, 64, 9, 167, 85, 152, 95, 131, 94, 87, 92, 213, 202, 219, 208, 12, 193, 115, 132, 11, 133, 165, 8, 10, 219, 159, 59, 205, 122, 159, 87]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [192, 157, 158, 171, 197, 63, 89, 130, 230, 100, 158, 40, 68, 19, 46, 243, 113, 18, 177, 19, 199, 36, 170, 141, 156, 102, 61, 205, 113, 170, 102, 192]), terminal := { root0Digest := (bytes [98, 18, 188, 175, 27, 205, 179, 130, 57, 12, 232, 219, 38, 211, 175, 110, 23, 173, 187, 111, 225, 55, 139, 25, 196, 177, 64, 5, 240, 114, 106, 227]), executionDigest := (bytes [46, 32, 12, 1, 169, 11, 60, 230, 125, 5, 123, 127, 177, 78, 153, 53, 25, 114, 127, 17, 26, 141, 196, 196, 80, 189, 184, 59, 120, 244, 188, 221]), finalStateDigest := (bytes [103, 119, 166, 83, 71, 235, 116, 157, 66, 6, 65, 91, 76, 196, 146, 226, 246, 68, 215, 2, 4, 30, 194, 108, 206, 35, 183, 164, 172, 191, 117, 48]), transcriptFinalDigest := (bytes [119, 7, 167, 196, 130, 246, 97, 117, 147, 54, 106, 251, 40, 15, 103, 100, 22, 139, 124, 178, 121, 36, 93, 139, 80, 196, 5, 66, 86, 204, 216, 62]), finalPc := 20, halted := true, digest := (bytes [91, 235, 115, 249, 147, 209, 26, 233, 108, 152, 165, 255, 9, 235, 51, 94, 102, 210, 191, 88, 9, 152, 212, 39, 19, 115, 91, 230, 173, 203, 191, 53]) }, digest := (bytes [165, 210, 68, 127, 142, 143, 0, 35, 107, 59, 193, 151, 12, 70, 37, 104, 61, 227, 84, 188, 28, 23, 182, 80, 198, 211, 131, 5, 11, 159, 112, 31]) }, statementDigest := (bytes [140, 226, 248, 131, 105, 165, 226, 9, 246, 59, 96, 204, 72, 149, 237, 189, 119, 170, 171, 217, 51, 103, 251, 69, 96, 187, 203, 253, 31, 160, 208, 80]), proofDigest := (bytes [229, 6, 212, 131, 222, 235, 89, 39, 195, 239, 186, 54, 56, 171, 189, 8, 5, 105, 29, 178, 45, 95, 22, 238, 123, 90, 68, 78, 192, 73, 93, 240]), digest := (bytes [61, 63, 204, 211, 91, 172, 227, 27, 108, 10, 243, 49, 114, 61, 134, 127, 26, 167, 144, 240, 205, 249, 13, 131, 9, 33, 119, 60, 66, 186, 180, 127]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [17, 200, 31, 62, 49, 172, 250, 37, 145, 105, 53, 203, 246, 118, 11, 102, 130, 27, 67, 62, 33, 190, 100, 19, 43, 89, 155, 192, 93, 125, 221, 76]), layoutVersion := 1, digest := (bytes [209, 81, 166, 186, 4, 204, 166, 150, 37, 137, 27, 146, 96, 65, 41, 111, 22, 187, 153, 19, 225, 72, 116, 47, 30, 162, 26, 76, 240, 92, 137, 202]) }, rowWidth := 38, timeLen := 4, columnDigests := [(bytes [212, 186, 229, 172, 74, 68, 211, 103, 24, 241, 21, 82, 209, 33, 189, 99, 223, 36, 129, 167, 9, 173, 76, 108, 178, 222, 90, 225, 89, 142, 8, 14]), (bytes [56, 58, 241, 13, 94, 161, 102, 38, 209, 85, 101, 10, 115, 74, 68, 15, 139, 16, 65, 164, 142, 61, 38, 80, 159, 19, 8, 220, 33, 174, 155, 155]), (bytes [29, 30, 250, 119, 67, 192, 190, 83, 169, 199, 126, 126, 209, 9, 207, 51, 13, 31, 240, 215, 38, 77, 233, 53, 71, 218, 94, 76, 41, 218, 33, 58]), (bytes [181, 122, 105, 181, 35, 180, 95, 214, 79, 41, 41, 2, 114, 48, 216, 55, 223, 211, 166, 64, 24, 33, 244, 234, 111, 10, 124, 63, 69, 70, 27, 116]), (bytes [235, 168, 211, 18, 219, 164, 123, 11, 1, 214, 235, 228, 142, 231, 19, 191, 111, 116, 112, 196, 167, 65, 6, 113, 150, 204, 141, 39, 111, 24, 165, 153]), (bytes [2, 223, 179, 210, 209, 205, 146, 17, 164, 217, 202, 178, 34, 24, 81, 6, 189, 236, 155, 58, 107, 97, 35, 210, 41, 139, 124, 249, 115, 65, 71, 53]), (bytes [148, 93, 109, 35, 88, 87, 157, 97, 249, 179, 2, 2, 221, 198, 208, 66, 170, 138, 243, 110, 6, 236, 227, 101, 91, 65, 171, 243, 200, 198, 189, 148]), (bytes [132, 13, 123, 172, 120, 106, 189, 241, 207, 17, 23, 219, 168, 136, 164, 0, 142, 128, 126, 198, 69, 95, 67, 194, 148, 13, 102, 136, 180, 146, 31, 139]), (bytes [13, 51, 13, 112, 10, 98, 204, 18, 53, 169, 156, 155, 63, 147, 114, 64, 241, 138, 154, 179, 238, 77, 114, 193, 171, 122, 197, 145, 246, 175, 206, 33]), (bytes [232, 60, 34, 59, 99, 35, 37, 101, 97, 80, 246, 173, 253, 205, 108, 125, 30, 217, 170, 112, 111, 96, 190, 85, 240, 167, 219, 144, 235, 27, 30, 175]), (bytes [33, 226, 191, 51, 76, 109, 28, 150, 35, 183, 64, 252, 90, 183, 140, 34, 61, 65, 9, 61, 233, 26, 98, 58, 22, 113, 219, 130, 57, 126, 25, 166]), (bytes [118, 132, 140, 41, 46, 54, 170, 167, 122, 118, 200, 245, 49, 89, 177, 77, 198, 10, 78, 179, 11, 224, 33, 204, 58, 199, 196, 82, 84, 72, 223, 144]), (bytes [205, 50, 239, 174, 62, 102, 47, 47, 168, 229, 99, 79, 130, 123, 211, 62, 86, 5, 136, 142, 232, 236, 222, 93, 139, 184, 152, 44, 168, 14, 179, 91]), (bytes [103, 53, 107, 4, 189, 132, 244, 169, 29, 6, 184, 32, 91, 82, 178, 107, 52, 16, 254, 231, 248, 28, 125, 77, 103, 211, 79, 63, 83, 74, 140, 122]), (bytes [134, 141, 124, 169, 119, 38, 249, 119, 111, 250, 40, 3, 85, 79, 214, 122, 209, 119, 227, 254, 195, 29, 190, 77, 250, 140, 202, 20, 171, 232, 229, 55]), (bytes [220, 193, 230, 244, 243, 14, 93, 42, 216, 108, 251, 253, 94, 191, 212, 189, 13, 211, 94, 236, 218, 138, 122, 7, 190, 222, 130, 249, 182, 150, 137, 189]), (bytes [223, 89, 191, 11, 110, 102, 31, 137, 129, 115, 137, 48, 64, 221, 208, 112, 235, 228, 24, 226, 254, 59, 16, 16, 192, 134, 30, 101, 212, 162, 156, 187]), (bytes [156, 22, 213, 157, 3, 147, 139, 132, 146, 22, 57, 209, 56, 31, 20, 20, 229, 105, 89, 38, 226, 230, 110, 49, 208, 70, 178, 10, 75, 21, 225, 62]), (bytes [89, 6, 118, 169, 105, 54, 5, 121, 26, 253, 91, 160, 13, 78, 211, 28, 177, 107, 187, 177, 10, 185, 35, 168, 191, 215, 99, 41, 155, 74, 182, 15]), (bytes [16, 1, 45, 207, 125, 115, 77, 40, 96, 249, 191, 96, 68, 155, 161, 144, 89, 205, 15, 173, 177, 139, 3, 87, 248, 132, 221, 254, 91, 235, 118, 133]), (bytes [2, 197, 213, 149, 21, 90, 236, 108, 141, 146, 26, 38, 0, 78, 135, 95, 223, 228, 221, 179, 125, 245, 167, 198, 49, 196, 48, 128, 192, 39, 124, 49]), (bytes [130, 134, 127, 131, 40, 47, 149, 206, 210, 112, 225, 17, 66, 25, 14, 78, 65, 235, 99, 73, 206, 90, 67, 148, 19, 78, 146, 25, 197, 149, 108, 61]), (bytes [8, 234, 67, 158, 76, 76, 170, 16, 58, 161, 138, 98, 35, 61, 115, 114, 104, 189, 45, 62, 96, 35, 11, 160, 56, 73, 223, 212, 106, 84, 224, 145]), (bytes [0, 189, 116, 3, 67, 124, 251, 249, 47, 128, 49, 73, 210, 47, 86, 252, 162, 78, 171, 9, 96, 183, 112, 195, 81, 120, 202, 223, 242, 24, 76, 51]), (bytes [81, 144, 1, 221, 155, 166, 187, 155, 181, 172, 254, 158, 176, 149, 110, 161, 164, 146, 156, 197, 231, 227, 176, 108, 72, 168, 128, 97, 162, 214, 166, 78]), (bytes [238, 147, 134, 181, 8, 29, 128, 200, 221, 198, 65, 181, 234, 22, 117, 159, 112, 0, 90, 214, 190, 69, 86, 72, 209, 196, 234, 23, 145, 109, 49, 190]), (bytes [150, 94, 21, 115, 92, 3, 250, 46, 250, 39, 23, 156, 66, 177, 198, 103, 242, 34, 109, 175, 253, 18, 181, 44, 23, 6, 9, 9, 119, 235, 11, 108]), (bytes [135, 215, 141, 47, 156, 11, 54, 54, 3, 72, 179, 247, 223, 155, 104, 7, 155, 222, 232, 159, 97, 172, 115, 97, 167, 121, 212, 57, 156, 44, 117, 203]), (bytes [84, 95, 115, 25, 213, 106, 24, 56, 216, 206, 94, 157, 100, 187, 198, 197, 93, 1, 173, 134, 90, 112, 47, 80, 254, 7, 54, 249, 32, 132, 243, 167]), (bytes [130, 198, 251, 47, 44, 43, 143, 92, 82, 195, 92, 157, 42, 215, 42, 26, 5, 251, 108, 34, 34, 0, 80, 113, 213, 113, 25, 247, 190, 124, 74, 52]), (bytes [234, 182, 234, 160, 23, 192, 246, 199, 173, 187, 203, 106, 254, 25, 134, 196, 2, 40, 181, 117, 170, 220, 56, 86, 63, 246, 0, 182, 78, 16, 61, 77]), (bytes [40, 254, 204, 213, 6, 140, 117, 235, 134, 79, 86, 81, 169, 63, 60, 118, 8, 156, 87, 198, 194, 60, 29, 160, 125, 250, 15, 187, 147, 220, 29, 92]), (bytes [18, 187, 180, 226, 104, 66, 42, 243, 22, 156, 53, 240, 151, 142, 203, 83, 91, 143, 153, 183, 211, 14, 178, 15, 249, 35, 88, 211, 226, 167, 221, 238]), (bytes [164, 40, 127, 229, 211, 147, 121, 221, 253, 56, 242, 238, 25, 160, 231, 5, 98, 88, 35, 198, 216, 51, 242, 34, 196, 132, 1, 62, 202, 49, 246, 41]), (bytes [122, 105, 77, 66, 174, 33, 37, 82, 171, 117, 60, 146, 152, 71, 176, 9, 4, 214, 95, 111, 117, 16, 77, 11, 22, 12, 202, 53, 36, 93, 76, 79]), (bytes [190, 26, 99, 184, 175, 199, 251, 124, 134, 183, 220, 35, 196, 195, 152, 135, 36, 169, 87, 198, 14, 22, 245, 143, 20, 239, 221, 18, 139, 77, 165, 236]), (bytes [80, 33, 41, 82, 68, 242, 18, 200, 209, 172, 125, 228, 155, 229, 192, 181, 222, 62, 254, 113, 197, 197, 209, 167, 162, 245, 86, 19, 189, 248, 96, 43]), (bytes [90, 10, 190, 250, 226, 23, 47, 210, 182, 164, 148, 175, 37, 226, 99, 192, 247, 166, 149, 66, 95, 29, 230, 232, 50, 99, 224, 203, 78, 177, 221, 250])], familyDigest := (bytes [17, 200, 31, 62, 49, 172, 250, 37, 145, 105, 53, 203, 246, 118, 11, 102, 130, 27, 67, 62, 33, 190, 100, 19, 43, 89, 155, 192, 93, 125, 221, 76]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [17, 200, 31, 62, 49, 172, 250, 37, 145, 105, 53, 203, 246, 118, 11, 102, 130, 27, 67, 62, 33, 190, 100, 19, 43, 89, 155, 192, 93, 125, 221, 76]), layoutVersion := 1, digest := (bytes [209, 81, 166, 186, 4, 204, 166, 150, 37, 137, 27, 146, 96, 65, 41, 111, 22, 187, 153, 19, 225, 72, 116, 47, 30, 162, 26, 76, 240, 92, 137, 202]) }, logicalIndex := 0, digest := (bytes [74, 163, 169, 52, 59, 19, 192, 199, 26, 28, 140, 249, 102, 6, 101, 159, 107, 24, 248, 134, 243, 34, 87, 85, 72, 167, 66, 239, 150, 191, 249, 200]) }, valueDigest := (bytes [59, 110, 73, 184, 21, 134, 14, 247, 63, 174, 178, 199, 142, 253, 82, 19, 165, 139, 8, 196, 235, 194, 3, 121, 51, 124, 231, 35, 211, 16, 32, 52]), digest := (bytes [226, 218, 13, 4, 55, 80, 197, 195, 76, 108, 24, 197, 233, 230, 155, 103, 218, 151, 128, 91, 234, 235, 98, 162, 237, 158, 247, 170, 217, 3, 134, 70]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [17, 200, 31, 62, 49, 172, 250, 37, 145, 105, 53, 203, 246, 118, 11, 102, 130, 27, 67, 62, 33, 190, 100, 19, 43, 89, 155, 192, 93, 125, 221, 76]), layoutVersion := 1, digest := (bytes [209, 81, 166, 186, 4, 204, 166, 150, 37, 137, 27, 146, 96, 65, 41, 111, 22, 187, 153, 19, 225, 72, 116, 47, 30, 162, 26, 76, 240, 92, 137, 202]) }, logicalIndex := 3, digest := (bytes [83, 176, 155, 12, 128, 45, 187, 248, 3, 198, 3, 196, 135, 231, 240, 194, 102, 143, 106, 53, 186, 216, 189, 103, 2, 215, 13, 68, 157, 15, 93, 68]) }, valueDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [39, 255, 14, 211, 207, 209, 24, 34, 167, 228, 216, 123, 174, 173, 128, 46, 62, 57, 217, 213, 2, 205, 57, 34, 161, 52, 77, 9, 243, 115, 76, 211]) }), digest := (bytes [109, 78, 11, 81, 10, 95, 146, 203, 37, 0, 50, 102, 146, 114, 137, 79, 18, 144, 51, 195, 86, 163, 101, 61, 242, 3, 132, 155, 189, 182, 80, 39]) }
  , rootLaneCommitment := { timeLen := 4, commitments := { commitmentCount := 38, digest := (bytes [116, 93, 153, 130, 232, 216, 210, 83, 127, 32, 104, 122, 68, 45, 119, 16, 13, 205, 151, 193, 226, 131, 66, 171, 100, 131, 124, 207, 194, 84, 69, 216]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [116, 93, 153, 130, 232, 216, 210, 83, 127, 32, 104, 122, 68, 45, 119, 16, 13, 205, 151, 193, 226, 131, 66, 171, 100, 131, 124, 207, 194, 84, 69, 216]), layoutVersion := 3, digest := (bytes [206, 160, 212, 132, 68, 145, 205, 36, 65, 72, 189, 84, 106, 232, 12, 218, 83, 49, 212, 75, 8, 104, 8, 151, 141, 222, 235, 221, 213, 211, 202, 152]) }, logicalIndex := 0, digest := (bytes [14, 92, 10, 244, 78, 56, 77, 247, 46, 29, 154, 26, 176, 243, 170, 204, 158, 255, 34, 89, 33, 167, 78, 81, 90, 132, 32, 174, 4, 30, 129, 198]) }, valueDigest := (bytes [59, 110, 73, 184, 21, 134, 14, 247, 63, 174, 178, 199, 142, 253, 82, 19, 165, 139, 8, 196, 235, 194, 3, 121, 51, 124, 231, 35, 211, 16, 32, 52]), digest := (bytes [219, 218, 219, 174, 165, 130, 251, 88, 206, 16, 80, 0, 28, 86, 170, 191, 249, 191, 4, 236, 79, 80, 162, 191, 249, 161, 174, 139, 196, 157, 147, 124]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [116, 93, 153, 130, 232, 216, 210, 83, 127, 32, 104, 122, 68, 45, 119, 16, 13, 205, 151, 193, 226, 131, 66, 171, 100, 131, 124, 207, 194, 84, 69, 216]), layoutVersion := 3, digest := (bytes [206, 160, 212, 132, 68, 145, 205, 36, 65, 72, 189, 84, 106, 232, 12, 218, 83, 49, 212, 75, 8, 104, 8, 151, 141, 222, 235, 221, 213, 211, 202, 152]) }, logicalIndex := 3, digest := (bytes [170, 208, 237, 65, 75, 119, 119, 72, 219, 13, 34, 89, 241, 82, 231, 86, 162, 51, 20, 251, 135, 220, 233, 188, 249, 237, 246, 151, 96, 52, 237, 174]) }, valueDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [93, 157, 36, 36, 118, 242, 203, 241, 13, 166, 55, 56, 153, 196, 21, 43, 180, 209, 165, 227, 227, 152, 171, 214, 55, 182, 39, 224, 113, 54, 207, 193]) }), digest := (bytes [173, 179, 33, 189, 187, 191, 177, 180, 128, 209, 106, 82, 101, 161, 51, 198, 78, 189, 60, 236, 72, 131, 100, 76, 191, 155, 96, 159, 125, 38, 9, 222]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [109, 78, 11, 81, 10, 95, 146, 203, 37, 0, 50, 102, 146, 114, 137, 79, 18, 144, 51, 195, 86, 163, 101, 61, 242, 3, 132, 155, 189, 182, 80, 39]), rootLaneCommitmentDigest := (bytes [173, 179, 33, 189, 187, 191, 177, 180, 128, 209, 106, 82, 101, 161, 51, 198, 78, 189, 60, 236, 72, 131, 100, 76, 191, 155, 96, 159, 125, 38, 9, 222]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 4, digest := (bytes [69, 198, 181, 31, 1, 82, 207, 80, 49, 145, 106, 234, 47, 152, 166, 167, 63, 253, 95, 41, 215, 15, 110, 210, 230, 54, 36, 253, 97, 206, 221, 44]) }, statementDigest := (bytes [243, 11, 20, 125, 199, 20, 35, 50, 23, 6, 226, 42, 212, 106, 174, 82, 204, 153, 180, 0, 253, 47, 62, 199, 146, 177, 65, 197, 37, 161, 193, 26]), proofDigest := (bytes [179, 50, 115, 34, 156, 230, 119, 223, 90, 255, 82, 147, 133, 148, 105, 168, 198, 209, 236, 197, 7, 9, 42, 41, 0, 25, 175, 56, 15, 211, 199, 185]), digest := (bytes [247, 226, 241, 187, 96, 204, 66, 130, 5, 31, 120, 64, 209, 158, 104, 12, 193, 149, 56, 123, 58, 80, 81, 90, 181, 31, 184, 242, 179, 137, 141, 150]) }
  , digest := (bytes [223, 126, 79, 134, 8, 241, 122, 213, 45, 95, 249, 223, 68, 72, 29, 226, 49, 131, 7, 43, 44, 114, 47, 212, 117, 118, 213, 188, 145, 166, 230, 154])
}
    , transcript := {
  appLabel := (bytes [110, 101, 111, 46, 102, 111, 108, 100, 46, 110, 101, 120, 116, 47, 114, 118, 54, 52, 105, 109, 47, 112, 97, 114, 105, 116, 121, 95, 107, 101, 114, 110, 101, 108, 95, 118, 49])
  , events := [{
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 116, 114, 97, 110, 115, 99, 114, 105, 112, 116, 95, 115, 101, 101, 100])
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 99, 111, 110, 116, 114, 111, 108, 45, 102, 108, 111, 119, 45, 98, 108, 116, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [27634538711377453, 212436087916, 13380622803955469567, 3521951206484747623, 9254679819230523135, 7793219495316757120, 11804775929249192629, 11428962190686586919], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [99, 111, 110, 116, 114, 111, 108, 95, 102, 108, 111, 119, 95, 98, 108, 116, 95, 116, 97, 107, 101, 110, 95, 115, 107, 105, 112, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [27634538711377453, 212436087916, 13380622803955469567, 3521951206484747623, 9254679819230523135, 7793219495316757120, 11804775929249192629, 11428962190686586919], absorbed := 2 }
  , cursorAfter := { stateWords := [465674789733, 7180296237315089499, 11733811407418221658, 16498453394416949328, 14614950331407827170, 386261267250689441, 17895202755823189055, 13656127343008880826], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [4293918867, 1048851, 2147427, 115, 115]
  , cursorBefore := { stateWords := [465674789733, 7180296237315089499, 11733811407418221658, 16498453394416949328, 14614950331407827170, 386261267250689441, 17895202755823189055, 13656127343008880826], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 4342287947480010762, 10770147552220420142, 11196137098178073159, 3410458198267189641, 17053939472173617309, 10618310545408775523, 14632938316382243867], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [0, 4342287947480010762, 10770147552220420142, 11196137098178073159, 3410458198267189641, 17053939472173617309, 10618310545408775523, 14632938316382243867], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 0, 0, 3177119353095704368, 1122698152926025607, 8287482361524826601, 16723245261626599678, 4302150586641423449], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [0, 0, 0, 3177119353095704368, 1122698152926025607, 8287482361524826601, 16723245261626599678, 4302150586641423449], absorbed := 3 }
  , cursorAfter := { stateWords := [0, 8997489801189187788, 9188462323838030656, 3846626849677102628, 493978877708530803, 5797943057098051682, 265212388903239129, 5384776338942354106], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [98, 18, 188, 175, 27, 205, 179, 130, 57, 12, 232, 219, 38, 211, 175, 110, 23, 173, 187, 111, 225, 55, 139, 25, 196, 177, 64, 5, 240, 114, 106, 227])
  , u64s := []
  , cursorBefore := { stateWords := [0, 8997489801189187788, 9188462323838030656, 3846626849677102628, 493978877708530803, 5797943057098051682, 265212388903239129, 5384776338942354106], absorbed := 1 }
  , cursorAfter := { stateWords := [12638052876212445947, 11542696732698544447, 18007394215398869016, 14068469168916825873, 16931571443844531563, 6599354317457268593, 17714847696491555142, 1851216477043460655], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [12638052876212445947, 11542696732698544447, 18007394215398869016, 14068469168916825873, 16931571443844531563, 6599354317457268593, 17714847696491555142, 1851216477043460655], absorbed := 0 }
  , cursorAfter := { stateWords := [16644640469157671253, 6345635710436128953, 8972926169320819561, 8802111708820718633, 11586481162637383844, 18409059249488434770, 15588410963579079596, 16258969875057624872], absorbed := 0 }
  , challengeOutput := (some 16644640469157671253)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [17, 173, 35, 176, 52, 237, 183, 61, 86, 195, 142, 108, 204, 29, 120, 209, 90, 254, 172, 22, 131, 169, 195, 218, 54, 196, 115, 33, 141, 248, 85, 89])
  , u64s := []
  , cursorBefore := { stateWords := [16644640469157671253, 6345635710436128953, 8972926169320819561, 8802111708820718633, 11586481162637383844, 18409059249488434770, 15588410963579079596, 16258969875057624872], absorbed := 0 }
  , cursorAfter := { stateWords := [36898154206646648, 9415960802542505, 1498806413, 9072776052887572135, 11721581926632944754, 3535138222753818749, 6273687341861194554, 8882264780997456134], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [36898154206646648, 9415960802542505, 1498806413, 9072776052887572135, 11721581926632944754, 3535138222753818749, 6273687341861194554, 8882264780997456134], absorbed := 3 }
  , cursorAfter := { stateWords := [1411288425859349507, 4187811786765448679, 2899879548899209826, 12708691591653258630, 12167309891279697045, 2700363555137302011, 2186034203693546282, 13447575716582957255], absorbed := 0 }
  , challengeOutput := (some 1411288425859349507)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [1411288425859349507, 4187811786765448679, 2899879548899209826, 12708691591653258630, 12167309891279697045, 2700363555137302011, 2186034203693546282, 13447575716582957255], absorbed := 0 }
  , cursorAfter := { stateWords := [10716973488349051482, 3868992218345858838, 12653624167884364434, 6196821790445151857, 6347444349010254889, 7408501223560603604, 16906200941066870330, 18076423091780357662], absorbed := 0 }
  , challengeOutput := (some 10716973488349051482)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [113, 106, 8, 108, 18, 192, 96, 184, 164, 166, 127, 255, 228, 167, 133, 127, 188, 165, 129, 20, 7, 71, 150, 61, 35, 41, 236, 246, 45, 79, 63, 14])
  , u64s := []
  , cursorBefore := { stateWords := [10716973488349051482, 3868992218345858838, 12653624167884364434, 6196821790445151857, 6347444349010254889, 7408501223560603604, 16906200941066870330, 18076423091780357662], absorbed := 0 }
  , cursorAfter := { stateWords := [1992871900905349, 69502505699874375, 239030061, 449049874361303726, 13278269026255423333, 16025667103406807846, 11359412951690612528, 1030809117376067969], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [1992871900905349, 69502505699874375, 239030061, 449049874361303726, 13278269026255423333, 16025667103406807846, 11359412951690612528, 1030809117376067969], absorbed := 3 }
  , cursorAfter := { stateWords := [7080673056785947620, 10323909872972385627, 3294867110705849055, 17575164267868533637, 12557480519429552349, 12862571481398172470, 16561057601711089821, 2428372152698216523], absorbed := 0 }
  , challengeOutput := (some 7080673056785947620)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [198, 81, 7, 250, 152, 135, 65, 159, 231, 42, 117, 161, 26, 121, 63, 197, 123, 212, 231, 113, 35, 37, 159, 177, 226, 104, 247, 68, 136, 30, 16, 163])
  , u64s := []
  , cursorBefore := { stateWords := [7080673056785947620, 10323909872972385627, 3294867110705849055, 17575164267868533637, 12557480519429552349, 12862571481398172470, 16561057601711089821, 2428372152698216523], absorbed := 0 }
  , cursorAfter := { stateWords := [9976864701138239, 19412328268275493, 2735742600, 4961504159926370359, 14655189360590489950, 14059714068881444742, 14349289097047773731, 16140683775358900588], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [46, 32, 12, 1, 169, 11, 60, 230, 125, 5, 123, 127, 177, 78, 153, 53, 25, 114, 127, 17, 26, 141, 196, 196, 80, 189, 184, 59, 120, 244, 188, 221])
  , u64s := []
  , cursorBefore := { stateWords := [9976864701138239, 19412328268275493, 2735742600, 4961504159926370359, 14655189360590489950, 14059714068881444742, 14349289097047773731, 16140683775358900588], absorbed := 3 }
  , cursorAfter := { stateWords := [7337588467250585, 16810146869331085, 3720148088, 437345699824599267, 3522153810974739236, 14925937994573417365, 152522263272405329, 10141347386645065159], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [103, 119, 166, 83, 71, 235, 116, 157, 66, 6, 65, 91, 76, 196, 146, 226, 246, 68, 215, 2, 4, 30, 194, 108, 206, 35, 183, 164, 172, 191, 117, 48])
  , u64s := []
  , cursorBefore := { stateWords := [7337588467250585, 16810146869331085, 3720148088, 437345699824599267, 3522153810974739236, 14925937994573417365, 152522263272405329, 10141347386645065159], absorbed := 3 }
  , cursorAfter := { stateWords := [1129023505097362, 46363260595520030, 813023148, 12846192668686633647, 6741557979578876315, 5327271313024723108, 1204975810469412893, 2852815224866682480], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [1129023505097362, 46363260595520030, 813023148, 12846192668686633647, 6741557979578876315, 5327271313024723108, 1204975810469412893, 2852815224866682480], absorbed := 3 }
  , cursorAfter := { stateWords := [2909462562917863239, 9929399740580202738, 13577020951539415088, 17670864534221122448, 9593501634175910908, 6516463136653550587, 7536639024974644756, 5816055747239020741], absorbed := 0 }
  , challengeOutput := (some 2909462562917863239)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [2909462562917863239, 9929399740580202738, 13577020951539415088, 17670864534221122448, 9593501634175910908, 6516463136653550587, 7536639024974644756, 5816055747239020741], absorbed := 0 }
  , cursorAfter := { stateWords := [8458312616683964279, 7234767995085141651, 10042222849210223382, 4528594096167961680, 9166438756173917332, 17489391845004188911, 12640545817216988034, 14193716235814182519], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [119, 7, 167, 196, 130, 246, 97, 117, 147, 54, 106, 251, 40, 15, 103, 100, 22, 139, 124, 178, 121, 36, 93, 139, 80, 196, 5, 66, 86, 204, 216, 62]))
}]
}
    , stage1 := stage1
    , stage2 := stage2
    , stage3 := stage3
    , rootExecution := rootExecution
    , stepComposition := stepComposition
    , soundnessAccounting := soundnessAccounting
    , kernelOpeningBundle := kernelOpeningBundle
    , digest := (bytes [230, 41, 58, 175, 121, 96, 66, 44, 85, 229, 215, 194, 75, 65, 233, 18, 210, 71, 209, 229, 100, 53, 104, 128, 30, 130, 141, 133, 38, 2, 215, 87])
  }

end Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors.Case_control_flow_blt_taken_skip_ecall
