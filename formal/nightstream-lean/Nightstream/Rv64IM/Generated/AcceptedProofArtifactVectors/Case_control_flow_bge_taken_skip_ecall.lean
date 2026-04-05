import Nightstream.Rv64IM.Generated.AcceptedProofArtifactTypes

set_option maxHeartbeats 0
set_option maxRecDepth 65536

namespace Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors.Case_control_flow_bge_taken_skip_ecall

open Nightstream.Rv64IM.Generated

def stage1SemInputs : List SemInView :=
  [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, pc := 0, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 1, archRdBefore := 0, archImm := 1, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 1, rdBefore := 0, rdAfter := 1, imm := 1, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, pc := 4, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 2, archRdBefore := 0, archImm := -1, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 2, rdBefore := 0, rdAfter := 18446744073709551615, imm := -1, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, pc := 8, opcode := .bge, traceOpcode := (some .bge), traceVirtualOpcode := none, family := .controlFlow, archRs1 := 1, archRs1Value := 1, archRs2 := 2, archRs2Value := 18446744073709551615, archRd := 0, archRdBefore := 0, archImm := 8, rs1 := 1, rs1Value := 1, rs2 := 2, rs2Value := 18446744073709551615, rd := 0, rdBefore := 0, rdAfter := 0, imm := 8, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := false, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, pc := 16, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 0, archRdBefore := 0, archImm := 0, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 0, rdBefore := 0, rdAfter := 0, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := false, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }]

def stage1RowBindings : List Stage1RowBindingView :=
  [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 1048723, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 4, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 1, rdAfter := 1, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 4293918995, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 8, aluResult := 18446744073709551615, effectiveAddr := none, writesRd := true, rd := 2, rdAfter := 18446744073709551615, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 2151523, opcode := .bge, traceOpcode := (some .bge), traceVirtualOpcode := none, family := .controlFlow, nextPc := 16, aluResult := 1, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 16, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 20, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }]

def stage1 : Stage1ProofBundleView :=
  {
    semInputs := stage1SemInputs
    , rowBindings := stage1RowBindings
    , bytecodeDigest := (bytes [9, 146, 98, 253, 68, 127, 111, 73, 108, 210, 254, 137, 128, 50, 195, 68, 180, 171, 51, 185, 94, 20, 157, 11, 122, 160, 73, 140, 195, 200, 239, 197])
    , aluDigest := (bytes [168, 3, 200, 252, 27, 215, 168, 153, 49, 66, 51, 77, 2, 81, 228, 103, 255, 16, 197, 198, 157, 214, 148, 208, 228, 44, 186, 127, 47, 196, 48, 105])
    , branchDigest := (bytes [245, 66, 157, 168, 105, 86, 176, 87, 116, 56, 121, 202, 39, 220, 10, 168, 0, 145, 30, 192, 217, 64, 65, 37, 74, 145, 141, 208, 18, 168, 213, 207])
    , semantics := { semInputsDigest := (bytes [110, 195, 93, 251, 147, 57, 135, 190, 221, 103, 46, 161, 134, 206, 254, 223, 51, 229, 120, 39, 107, 9, 182, 247, 233, 239, 56, 76, 54, 220, 180, 65]), rowBindingsDigest := (bytes [82, 225, 221, 240, 202, 225, 99, 210, 18, 103, 144, 158, 250, 173, 166, 7, 129, 98, 127, 206, 46, 113, 89, 207, 53, 24, 78, 37, 61, 194, 231, 20]), sequenceCount := 4, helperRowCount := 0, digest := (bytes [169, 33, 39, 3, 150, 119, 57, 89, 151, 197, 202, 81, 70, 53, 157, 194, 148, 201, 219, 248, 46, 178, 113, 134, 55, 216, 54, 168, 140, 177, 254, 179]) }
    , addressCorrectnessDigest := (bytes [131, 8, 171, 193, 91, 133, 188, 144, 65, 239, 236, 90, 194, 54, 144, 146, 28, 131, 22, 100, 186, 200, 239, 119, 67, 75, 2, 136, 99, 105, 70, 210])
    , linkageDigest := (bytes [42, 44, 15, 176, 115, 90, 114, 130, 76, 243, 189, 111, 151, 102, 18, 115, 56, 193, 224, 97, 207, 84, 217, 131, 5, 186, 115, 59, 68, 157, 100, 58])
    , selectedOpening := { claim := { rowsFamilyDigest := (bytes [82, 225, 221, 240, 202, 225, 99, 210, 18, 103, 144, 158, 250, 173, 166, 7, 129, 98, 127, 206, 46, 113, 89, 207, 53, 24, 78, 37, 61, 194, 231, 20]), rowCount := 4, effectRowCount := 4, commitRowCount := 4, realRowCount := 4, preservesX0Count := 2, firstTraceIndex := 0, effectTraceIndex := 0, commitTraceIndex := 0, lastTraceIndex := 3, mix := 6088699767227576722, points := { first := { id := { object := { familyTag := 1, commitmentDigest := (bytes [82, 225, 221, 240, 202, 225, 99, 210, 18, 103, 144, 158, 250, 173, 166, 7, 129, 98, 127, 206, 46, 113, 89, 207, 53, 24, 78, 37, 61, 194, 231, 20]), layoutVersion := 1, digest := (bytes [6, 43, 11, 147, 130, 140, 245, 221, 166, 118, 240, 129, 126, 21, 15, 232, 52, 189, 47, 177, 163, 245, 71, 246, 150, 155, 138, 231, 220, 4, 127, 225]) }, logicalIndex := 0, digest := (bytes [241, 232, 128, 3, 231, 184, 198, 97, 14, 16, 102, 23, 248, 99, 250, 223, 32, 42, 13, 241, 115, 34, 209, 193, 232, 194, 48, 145, 26, 186, 133, 193]) }, valueDigest := (bytes [32, 177, 93, 4, 194, 84, 97, 173, 64, 18, 168, 81, 246, 234, 52, 254, 43, 233, 61, 198, 55, 106, 236, 15, 107, 29, 198, 148, 168, 64, 112, 25]), digest := (bytes [224, 27, 2, 222, 146, 227, 106, 37, 246, 118, 187, 90, 102, 239, 13, 35, 79, 134, 72, 101, 228, 83, 116, 234, 64, 113, 40, 57, 130, 199, 212, 43]) }, effect := { id := { object := { familyTag := 1, commitmentDigest := (bytes [82, 225, 221, 240, 202, 225, 99, 210, 18, 103, 144, 158, 250, 173, 166, 7, 129, 98, 127, 206, 46, 113, 89, 207, 53, 24, 78, 37, 61, 194, 231, 20]), layoutVersion := 1, digest := (bytes [6, 43, 11, 147, 130, 140, 245, 221, 166, 118, 240, 129, 126, 21, 15, 232, 52, 189, 47, 177, 163, 245, 71, 246, 150, 155, 138, 231, 220, 4, 127, 225]) }, logicalIndex := 0, digest := (bytes [241, 232, 128, 3, 231, 184, 198, 97, 14, 16, 102, 23, 248, 99, 250, 223, 32, 42, 13, 241, 115, 34, 209, 193, 232, 194, 48, 145, 26, 186, 133, 193]) }, valueDigest := (bytes [32, 177, 93, 4, 194, 84, 97, 173, 64, 18, 168, 81, 246, 234, 52, 254, 43, 233, 61, 198, 55, 106, 236, 15, 107, 29, 198, 148, 168, 64, 112, 25]), digest := (bytes [224, 27, 2, 222, 146, 227, 106, 37, 246, 118, 187, 90, 102, 239, 13, 35, 79, 134, 72, 101, 228, 83, 116, 234, 64, 113, 40, 57, 130, 199, 212, 43]) }, commit := { id := { object := { familyTag := 1, commitmentDigest := (bytes [82, 225, 221, 240, 202, 225, 99, 210, 18, 103, 144, 158, 250, 173, 166, 7, 129, 98, 127, 206, 46, 113, 89, 207, 53, 24, 78, 37, 61, 194, 231, 20]), layoutVersion := 1, digest := (bytes [6, 43, 11, 147, 130, 140, 245, 221, 166, 118, 240, 129, 126, 21, 15, 232, 52, 189, 47, 177, 163, 245, 71, 246, 150, 155, 138, 231, 220, 4, 127, 225]) }, logicalIndex := 0, digest := (bytes [241, 232, 128, 3, 231, 184, 198, 97, 14, 16, 102, 23, 248, 99, 250, 223, 32, 42, 13, 241, 115, 34, 209, 193, 232, 194, 48, 145, 26, 186, 133, 193]) }, valueDigest := (bytes [32, 177, 93, 4, 194, 84, 97, 173, 64, 18, 168, 81, 246, 234, 52, 254, 43, 233, 61, 198, 55, 106, 236, 15, 107, 29, 198, 148, 168, 64, 112, 25]), digest := (bytes [224, 27, 2, 222, 146, 227, 106, 37, 246, 118, 187, 90, 102, 239, 13, 35, 79, 134, 72, 101, 228, 83, 116, 234, 64, 113, 40, 57, 130, 199, 212, 43]) }, last := { id := { object := { familyTag := 1, commitmentDigest := (bytes [82, 225, 221, 240, 202, 225, 99, 210, 18, 103, 144, 158, 250, 173, 166, 7, 129, 98, 127, 206, 46, 113, 89, 207, 53, 24, 78, 37, 61, 194, 231, 20]), layoutVersion := 1, digest := (bytes [6, 43, 11, 147, 130, 140, 245, 221, 166, 118, 240, 129, 126, 21, 15, 232, 52, 189, 47, 177, 163, 245, 71, 246, 150, 155, 138, 231, 220, 4, 127, 225]) }, logicalIndex := 3, digest := (bytes [75, 204, 216, 179, 214, 237, 1, 207, 252, 151, 119, 134, 25, 255, 147, 242, 214, 130, 235, 178, 118, 65, 2, 18, 65, 209, 101, 100, 201, 224, 200, 138]) }, valueDigest := (bytes [42, 117, 137, 62, 203, 77, 127, 14, 91, 68, 2, 177, 38, 250, 164, 28, 55, 139, 198, 41, 209, 72, 143, 173, 84, 204, 135, 91, 62, 25, 137, 209]), digest := (bytes [157, 74, 72, 136, 168, 47, 4, 232, 174, 29, 202, 69, 217, 170, 188, 183, 187, 163, 126, 80, 165, 249, 71, 109, 83, 91, 27, 214, 156, 151, 106, 58]) } }, digest := (bytes [16, 166, 62, 195, 22, 36, 183, 149, 42, 234, 34, 40, 69, 96, 179, 201, 151, 221, 60, 14, 137, 14, 113, 177, 128, 156, 53, 207, 136, 253, 123, 239]) }, packaged := { statementDigest := (bytes [173, 183, 42, 206, 100, 29, 12, 109, 191, 104, 126, 189, 164, 184, 58, 169, 123, 158, 36, 162, 20, 206, 114, 64, 19, 126, 146, 179, 102, 25, 123, 95]), proofDigest := (bytes [68, 90, 75, 199, 203, 150, 66, 48, 233, 190, 38, 246, 116, 239, 127, 212, 167, 126, 118, 110, 212, 224, 202, 244, 103, 47, 172, 156, 92, 202, 238, 191]) }, digest := (bytes [130, 129, 202, 81, 175, 224, 184, 214, 119, 142, 209, 228, 193, 5, 42, 7, 83, 216, 66, 148, 207, 221, 63, 154, 240, 91, 166, 85, 142, 164, 247, 126]) }
    , digest := (bytes [204, 25, 17, 29, 68, 12, 112, 96, 178, 199, 172, 60, 30, 240, 93, 136, 69, 59, 128, 150, 139, 168, 177, 32, 219, 144, 205, 192, 239, 134, 26, 62])
  }

def stage2RegisterReads : List RegisterReadEventView :=
  [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 0, value := 0 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 0, value := 0 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 1, value := 1 }, { traceIndex := 2, stepIndex := 2, role := .rs2, reg := 2, value := 18446744073709551615 }]

def stage2RegisterWrites : List RegisterWriteEventView :=
  [{ traceIndex := 0, stepIndex := 0, reg := 1, previous := 0, next := 1 }, { traceIndex := 1, stepIndex := 1, reg := 2, previous := 0, next := 18446744073709551615 }]

def stage2RamEvents : List RamEventView :=
  []

def stage2TwistLinks : List TwistLinkEventView :=
  [{ traceIndex := 0, stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 1, family := .nativeAlu, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 2, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 3, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]

def stage2 : Stage2ProofBundleView :=
  {
    registerReads := stage2RegisterReads
    , registerWrites := stage2RegisterWrites
    , ramEvents := stage2RamEvents
    , registerDigest := (bytes [202, 217, 107, 236, 234, 163, 225, 38, 163, 25, 162, 6, 110, 91, 118, 198, 238, 244, 103, 216, 143, 185, 99, 144, 16, 184, 11, 36, 60, 159, 160, 235])
    , ramDigest := (bytes [209, 217, 105, 43, 209, 229, 156, 61, 92, 164, 94, 232, 52, 214, 73, 229, 72, 188, 139, 122, 165, 123, 201, 212, 205, 15, 247, 197, 165, 154, 109, 246])
    , temporal := { twistLinks := stage2TwistLinks, registerTimelineDigest := (bytes [37, 75, 202, 170, 216, 34, 182, 187, 144, 178, 25, 129, 215, 161, 70, 82, 62, 51, 12, 191, 183, 6, 123, 255, 112, 132, 152, 158, 192, 213, 51, 233]), ramTimelineDigest := (bytes [8, 117, 17, 140, 128, 180, 240, 140, 250, 181, 90, 134, 147, 17, 197, 122, 220, 8, 66, 15, 193, 254, 11, 122, 115, 210, 233, 239, 55, 132, 31, 228]), twistLinksDigest := (bytes [29, 212, 150, 153, 144, 42, 82, 255, 239, 158, 109, 67, 122, 221, 15, 102, 201, 201, 134, 22, 249, 193, 218, 76, 92, 69, 223, 33, 128, 181, 16, 223]), digest := (bytes [107, 8, 74, 107, 154, 80, 58, 185, 24, 50, 46, 178, 126, 97, 40, 74, 199, 107, 102, 199, 29, 236, 223, 104, 28, 116, 161, 51, 21, 185, 178, 64]) }
    , semantics := { registerReadsFamilyDigest := (bytes [110, 60, 90, 209, 174, 101, 184, 180, 200, 10, 172, 78, 179, 135, 209, 224, 115, 162, 133, 190, 114, 187, 81, 143, 103, 50, 112, 200, 137, 153, 254, 218]), registerWritesFamilyDigest := (bytes [34, 147, 148, 161, 224, 119, 52, 177, 141, 156, 70, 40, 227, 32, 218, 11, 126, 23, 2, 18, 249, 146, 227, 98, 177, 158, 13, 45, 197, 2, 19, 127]), ramEventsFamilyDigest := (bytes [85, 17, 108, 38, 84, 5, 109, 213, 145, 137, 203, 96, 117, 127, 130, 193, 117, 29, 27, 219, 228, 58, 7, 214, 144, 155, 66, 38, 127, 8, 241, 95]), twistLinksFamilyDigest := (bytes [158, 70, 57, 222, 46, 227, 217, 138, 157, 76, 219, 247, 70, 181, 81, 17, 232, 251, 167, 150, 82, 61, 186, 208, 229, 114, 131, 209, 5, 238, 224, 36]), rowCount := 4, registerEventCount := 6, ramEventCount := 0, digest := (bytes [240, 92, 74, 192, 53, 234, 0, 149, 84, 27, 168, 203, 112, 255, 121, 51, 51, 94, 37, 82, 254, 200, 207, 84, 129, 190, 39, 129, 228, 202, 221, 71]) }
    , linkageDigest := (bytes [39, 135, 4, 62, 179, 96, 54, 113, 170, 121, 241, 13, 116, 26, 148, 58, 44, 187, 143, 245, 152, 217, 148, 127, 23, 164, 27, 114, 219, 124, 174, 116])
    , selectedOpening := { claim := { registerReadsFamilyDigest := (bytes [110, 60, 90, 209, 174, 101, 184, 180, 200, 10, 172, 78, 179, 135, 209, 224, 115, 162, 133, 190, 114, 187, 81, 143, 103, 50, 112, 200, 137, 153, 254, 218]), registerWritesFamilyDigest := (bytes [34, 147, 148, 161, 224, 119, 52, 177, 141, 156, 70, 40, 227, 32, 218, 11, 126, 23, 2, 18, 249, 146, 227, 98, 177, 158, 13, 45, 197, 2, 19, 127]), ramEventsFamilyDigest := (bytes [85, 17, 108, 38, 84, 5, 109, 213, 145, 137, 203, 96, 117, 127, 130, 193, 117, 29, 27, 219, 228, 58, 7, 214, 144, 155, 66, 38, 127, 8, 241, 95]), twistLinksFamilyDigest := (bytes [158, 70, 57, 222, 46, 227, 217, 138, 157, 76, 219, 247, 70, 181, 81, 17, 232, 251, 167, 150, 82, 61, 186, 208, 229, 114, 131, 209, 5, 238, 224, 36]), registerReadCount := 4, registerWriteCount := 2, ramEventCount := 0, twistLinkCount := 4, ramReadCount := 0, ramWriteCount := 0, regMix := 13380091740178962810, ramMix := 15897272204832747763, points := { firstRead := (some { id := { object := { familyTag := 2, commitmentDigest := (bytes [110, 60, 90, 209, 174, 101, 184, 180, 200, 10, 172, 78, 179, 135, 209, 224, 115, 162, 133, 190, 114, 187, 81, 143, 103, 50, 112, 200, 137, 153, 254, 218]), layoutVersion := 1, digest := (bytes [44, 161, 68, 58, 34, 252, 136, 179, 251, 107, 69, 238, 93, 70, 72, 80, 191, 158, 76, 141, 162, 35, 49, 22, 147, 116, 95, 155, 95, 108, 216, 76]) }, logicalIndex := 0, digest := (bytes [77, 139, 40, 196, 156, 128, 147, 153, 36, 154, 48, 230, 101, 143, 25, 40, 230, 71, 220, 29, 79, 225, 157, 85, 58, 158, 66, 143, 240, 130, 165, 110]) }, valueDigest := (bytes [165, 2, 50, 180, 56, 84, 68, 13, 37, 136, 82, 191, 49, 42, 150, 67, 180, 45, 199, 251, 168, 91, 53, 39, 20, 9, 70, 46, 155, 135, 100, 116]), digest := (bytes [95, 51, 242, 90, 223, 251, 83, 91, 71, 195, 153, 11, 103, 238, 190, 213, 205, 26, 206, 214, 238, 101, 234, 217, 141, 167, 131, 36, 193, 126, 151, 94]) }), lastRead := (some { id := { object := { familyTag := 2, commitmentDigest := (bytes [110, 60, 90, 209, 174, 101, 184, 180, 200, 10, 172, 78, 179, 135, 209, 224, 115, 162, 133, 190, 114, 187, 81, 143, 103, 50, 112, 200, 137, 153, 254, 218]), layoutVersion := 1, digest := (bytes [44, 161, 68, 58, 34, 252, 136, 179, 251, 107, 69, 238, 93, 70, 72, 80, 191, 158, 76, 141, 162, 35, 49, 22, 147, 116, 95, 155, 95, 108, 216, 76]) }, logicalIndex := 3, digest := (bytes [228, 223, 109, 173, 90, 56, 54, 89, 32, 249, 137, 144, 247, 171, 37, 100, 192, 149, 89, 0, 236, 100, 41, 155, 156, 134, 126, 194, 130, 130, 205, 76]) }, valueDigest := (bytes [246, 223, 185, 226, 203, 120, 148, 227, 145, 110, 209, 66, 120, 170, 239, 16, 45, 59, 199, 211, 231, 254, 170, 129, 160, 93, 223, 196, 70, 158, 7, 228]), digest := (bytes [199, 226, 252, 58, 29, 86, 40, 105, 69, 46, 90, 205, 186, 72, 100, 129, 195, 87, 72, 9, 183, 232, 48, 94, 167, 202, 139, 197, 129, 206, 146, 100]) }), firstWrite := (some { id := { object := { familyTag := 3, commitmentDigest := (bytes [34, 147, 148, 161, 224, 119, 52, 177, 141, 156, 70, 40, 227, 32, 218, 11, 126, 23, 2, 18, 249, 146, 227, 98, 177, 158, 13, 45, 197, 2, 19, 127]), layoutVersion := 1, digest := (bytes [194, 16, 109, 208, 164, 123, 132, 250, 1, 93, 215, 81, 171, 155, 98, 149, 42, 45, 126, 160, 213, 76, 140, 62, 208, 21, 56, 195, 67, 147, 56, 107]) }, logicalIndex := 0, digest := (bytes [14, 123, 18, 244, 247, 123, 92, 178, 80, 203, 204, 174, 242, 100, 121, 6, 53, 20, 199, 38, 123, 10, 175, 82, 75, 82, 132, 105, 106, 248, 35, 179]) }, valueDigest := (bytes [6, 10, 8, 56, 28, 171, 254, 84, 147, 137, 212, 118, 68, 203, 11, 50, 81, 93, 22, 116, 174, 122, 49, 175, 71, 153, 47, 12, 222, 137, 227, 111]), digest := (bytes [108, 206, 75, 0, 208, 157, 200, 17, 168, 194, 61, 240, 95, 69, 186, 0, 186, 2, 244, 74, 143, 80, 250, 173, 137, 9, 178, 5, 217, 145, 11, 60]) }), lastWrite := (some { id := { object := { familyTag := 3, commitmentDigest := (bytes [34, 147, 148, 161, 224, 119, 52, 177, 141, 156, 70, 40, 227, 32, 218, 11, 126, 23, 2, 18, 249, 146, 227, 98, 177, 158, 13, 45, 197, 2, 19, 127]), layoutVersion := 1, digest := (bytes [194, 16, 109, 208, 164, 123, 132, 250, 1, 93, 215, 81, 171, 155, 98, 149, 42, 45, 126, 160, 213, 76, 140, 62, 208, 21, 56, 195, 67, 147, 56, 107]) }, logicalIndex := 1, digest := (bytes [186, 202, 209, 78, 5, 3, 126, 15, 152, 253, 20, 182, 104, 9, 74, 99, 78, 152, 13, 75, 119, 73, 156, 197, 30, 246, 73, 32, 62, 239, 178, 95]) }, valueDigest := (bytes [40, 27, 239, 51, 182, 60, 161, 89, 123, 44, 53, 92, 138, 78, 250, 43, 124, 140, 12, 207, 102, 6, 99, 167, 31, 4, 123, 247, 216, 203, 32, 114]), digest := (bytes [59, 117, 56, 165, 86, 214, 215, 255, 94, 90, 241, 104, 105, 179, 80, 242, 157, 236, 198, 89, 46, 6, 98, 62, 126, 35, 199, 26, 133, 106, 219, 62]) }), firstRam := none, lastRam := none, firstTwist := (some { id := { object := { familyTag := 5, commitmentDigest := (bytes [158, 70, 57, 222, 46, 227, 217, 138, 157, 76, 219, 247, 70, 181, 81, 17, 232, 251, 167, 150, 82, 61, 186, 208, 229, 114, 131, 209, 5, 238, 224, 36]), layoutVersion := 1, digest := (bytes [127, 244, 84, 61, 69, 33, 178, 101, 52, 145, 108, 17, 71, 223, 218, 46, 23, 196, 24, 15, 222, 79, 91, 1, 242, 88, 234, 42, 38, 100, 226, 21]) }, logicalIndex := 0, digest := (bytes [162, 133, 13, 60, 99, 96, 114, 117, 2, 168, 198, 252, 110, 4, 255, 18, 119, 96, 53, 211, 224, 213, 201, 178, 176, 205, 192, 7, 86, 45, 165, 157]) }, valueDigest := (bytes [6, 253, 89, 93, 65, 90, 254, 218, 186, 126, 113, 33, 125, 252, 29, 228, 182, 189, 94, 78, 106, 243, 59, 186, 226, 215, 103, 192, 49, 144, 186, 83]), digest := (bytes [151, 250, 167, 149, 53, 64, 66, 100, 77, 46, 68, 185, 228, 147, 253, 58, 213, 104, 0, 133, 111, 177, 3, 6, 188, 60, 47, 164, 252, 145, 18, 97]) }), lastTwist := (some { id := { object := { familyTag := 5, commitmentDigest := (bytes [158, 70, 57, 222, 46, 227, 217, 138, 157, 76, 219, 247, 70, 181, 81, 17, 232, 251, 167, 150, 82, 61, 186, 208, 229, 114, 131, 209, 5, 238, 224, 36]), layoutVersion := 1, digest := (bytes [127, 244, 84, 61, 69, 33, 178, 101, 52, 145, 108, 17, 71, 223, 218, 46, 23, 196, 24, 15, 222, 79, 91, 1, 242, 88, 234, 42, 38, 100, 226, 21]) }, logicalIndex := 3, digest := (bytes [30, 147, 209, 152, 86, 157, 230, 177, 42, 83, 192, 183, 201, 225, 54, 142, 4, 196, 182, 48, 113, 96, 0, 60, 18, 232, 183, 252, 179, 88, 95, 36]) }, valueDigest := (bytes [192, 220, 106, 41, 104, 255, 230, 149, 225, 60, 106, 47, 173, 175, 166, 9, 41, 27, 129, 156, 118, 121, 84, 121, 134, 180, 118, 205, 49, 136, 155, 48]), digest := (bytes [29, 33, 51, 22, 112, 81, 105, 200, 75, 249, 73, 151, 1, 58, 67, 22, 206, 91, 98, 152, 28, 35, 203, 46, 38, 94, 198, 31, 41, 214, 153, 48]) }) }, digest := (bytes [236, 219, 118, 255, 243, 65, 68, 92, 102, 65, 181, 75, 151, 18, 207, 162, 31, 201, 191, 183, 147, 90, 205, 174, 129, 222, 91, 46, 78, 81, 204, 173]) }, packaged := { statementDigest := (bytes [167, 89, 212, 132, 19, 24, 238, 228, 30, 134, 162, 97, 91, 241, 27, 86, 23, 216, 54, 41, 123, 97, 131, 188, 8, 150, 89, 242, 248, 115, 207, 152]), proofDigest := (bytes [249, 1, 6, 161, 184, 112, 221, 249, 40, 27, 100, 177, 161, 71, 239, 0, 108, 196, 170, 163, 160, 165, 163, 40, 234, 255, 137, 144, 58, 83, 191, 115]) }, digest := (bytes [118, 16, 79, 238, 183, 157, 103, 240, 236, 215, 2, 44, 197, 195, 41, 138, 44, 171, 242, 251, 141, 116, 188, 248, 1, 7, 218, 45, 17, 69, 218, 252]) }
    , digest := (bytes [229, 233, 238, 27, 151, 227, 198, 123, 74, 89, 146, 30, 220, 205, 24, 28, 180, 90, 109, 142, 211, 156, 131, 85, 180, 173, 109, 67, 161, 193, 28, 140])
  }

def stage3Continuity : List ContinuityEventView :=
  [{ stepIndex := 0, pc := 0, nextPc := 4, successorPc := (some 4), finalStep := false, continuityHolds := true }, { stepIndex := 1, pc := 4, nextPc := 8, successorPc := (some 8), finalStep := false, continuityHolds := true }, { stepIndex := 2, pc := 8, nextPc := 16, successorPc := (some 16), finalStep := false, continuityHolds := true }, { stepIndex := 3, pc := 16, nextPc := 20, successorPc := none, finalStep := true, continuityHolds := true }]

def stage3 : Stage3ProofBundleView :=
  {
    continuity := stage3Continuity
    , halted := true
    , bridgeDigest := (bytes [91, 155, 151, 36, 255, 29, 65, 219, 97, 184, 149, 17, 61, 71, 65, 67, 235, 95, 174, 182, 147, 224, 135, 172, 219, 41, 164, 217, 0, 115, 255, 45])
    , semantics := { continuityDigest := (bytes [225, 36, 55, 237, 16, 70, 173, 226, 205, 215, 188, 143, 132, 20, 5, 220, 229, 9, 111, 156, 132, 73, 165, 86, 137, 203, 45, 225, 35, 181, 205, 156]), rootSemanticRowsDigest := (bytes [71, 168, 252, 50, 89, 118, 14, 223, 81, 39, 153, 238, 30, 99, 52, 86, 187, 173, 76, 65, 137, 124, 118, 19, 179, 55, 254, 251, 77, 220, 29, 111]), rowChunkRoutesDigest := (bytes [170, 16, 215, 245, 131, 192, 198, 120, 95, 134, 175, 93, 217, 74, 16, 26, 237, 138, 81, 110, 201, 10, 195, 254, 244, 178, 29, 18, 146, 128, 117, 178]), preparedStepBindingsDigest := (bytes [251, 44, 102, 51, 115, 137, 29, 19, 101, 96, 19, 177, 197, 174, 40, 175, 43, 192, 215, 236, 30, 246, 118, 195, 16, 94, 178, 189, 154, 138, 180, 39]), stage2TemporalDigest := (bytes [107, 8, 74, 107, 154, 80, 58, 185, 24, 50, 46, 178, 126, 97, 40, 74, 199, 107, 102, 199, 29, 236, 223, 104, 28, 116, 161, 51, 21, 185, 178, 64]), initialPc := 0, finalPc := 20, realRowCount := 4, firstRealStepIndex := 0, lastRealStepIndex := 3, digest := (bytes [174, 219, 61, 83, 82, 247, 207, 73, 92, 129, 3, 68, 57, 214, 24, 144, 154, 37, 2, 226, 240, 182, 6, 29, 88, 171, 107, 84, 225, 209, 141, 220]) }
    , linkageDigest := (bytes [180, 96, 190, 243, 188, 34, 98, 58, 147, 97, 166, 46, 47, 34, 58, 18, 226, 19, 90, 166, 101, 7, 216, 91, 187, 175, 200, 100, 233, 209, 43, 20])
    , selectedOpening := { claim := { continuityFamilyDigest := (bytes [178, 177, 3, 134, 28, 140, 16, 149, 40, 220, 221, 198, 83, 202, 237, 105, 228, 80, 184, 187, 23, 255, 100, 66, 229, 141, 99, 228, 121, 52, 39, 88]), continuityCount := 4, finalStepCount := 1, halted := true, allContinuityHold := true, continuityMix := 13290325236237073002, points := { firstContinuity := (some { id := { object := { familyTag := 6, commitmentDigest := (bytes [178, 177, 3, 134, 28, 140, 16, 149, 40, 220, 221, 198, 83, 202, 237, 105, 228, 80, 184, 187, 23, 255, 100, 66, 229, 141, 99, 228, 121, 52, 39, 88]), layoutVersion := 1, digest := (bytes [236, 90, 105, 33, 46, 31, 185, 17, 37, 216, 190, 237, 8, 199, 200, 149, 254, 224, 190, 206, 223, 121, 110, 130, 238, 225, 162, 254, 31, 249, 173, 150]) }, logicalIndex := 0, digest := (bytes [36, 4, 204, 3, 12, 51, 32, 211, 254, 81, 204, 224, 109, 243, 139, 63, 6, 61, 51, 231, 182, 115, 199, 54, 57, 226, 50, 162, 160, 40, 253, 38]) }, valueDigest := (bytes [7, 131, 85, 21, 57, 109, 53, 31, 137, 53, 98, 18, 170, 36, 28, 200, 149, 213, 171, 159, 119, 200, 36, 230, 30, 35, 30, 11, 252, 126, 240, 63]), digest := (bytes [159, 221, 198, 197, 117, 106, 171, 81, 126, 42, 45, 192, 53, 222, 104, 114, 206, 226, 149, 147, 249, 97, 130, 60, 203, 233, 175, 235, 13, 126, 42, 204]) }), lastContinuity := (some { id := { object := { familyTag := 6, commitmentDigest := (bytes [178, 177, 3, 134, 28, 140, 16, 149, 40, 220, 221, 198, 83, 202, 237, 105, 228, 80, 184, 187, 23, 255, 100, 66, 229, 141, 99, 228, 121, 52, 39, 88]), layoutVersion := 1, digest := (bytes [236, 90, 105, 33, 46, 31, 185, 17, 37, 216, 190, 237, 8, 199, 200, 149, 254, 224, 190, 206, 223, 121, 110, 130, 238, 225, 162, 254, 31, 249, 173, 150]) }, logicalIndex := 3, digest := (bytes [185, 131, 50, 144, 41, 2, 89, 43, 206, 251, 1, 1, 71, 14, 103, 59, 244, 113, 72, 157, 221, 62, 96, 81, 169, 115, 86, 73, 16, 35, 0, 164]) }, valueDigest := (bytes [252, 134, 254, 33, 173, 19, 91, 16, 165, 37, 97, 183, 229, 243, 58, 241, 249, 218, 169, 205, 3, 229, 51, 197, 80, 15, 234, 120, 189, 254, 221, 45]), digest := (bytes [7, 151, 236, 244, 72, 147, 236, 219, 52, 132, 206, 18, 122, 251, 235, 250, 29, 51, 30, 67, 170, 84, 135, 7, 20, 212, 173, 168, 155, 255, 130, 67]) }) }, digest := (bytes [75, 198, 35, 145, 214, 91, 178, 63, 123, 142, 212, 199, 196, 50, 187, 94, 95, 63, 150, 63, 17, 226, 128, 171, 160, 14, 197, 47, 82, 225, 165, 140]) }, packaged := { statementDigest := (bytes [204, 27, 200, 146, 85, 239, 105, 169, 0, 72, 214, 120, 130, 244, 200, 25, 201, 90, 224, 138, 144, 153, 232, 244, 218, 153, 44, 243, 70, 240, 18, 3]), proofDigest := (bytes [215, 35, 231, 161, 94, 146, 97, 213, 23, 168, 176, 38, 28, 93, 249, 25, 98, 251, 148, 234, 15, 211, 181, 69, 23, 6, 153, 52, 10, 182, 175, 192]) }, digest := (bytes [117, 32, 110, 162, 230, 226, 48, 10, 111, 101, 147, 148, 48, 207, 7, 68, 89, 76, 52, 59, 26, 160, 178, 97, 243, 194, 177, 222, 86, 8, 100, 204]) }
    , digest := (bytes [107, 155, 255, 223, 59, 245, 66, 19, 7, 137, 80, 182, 187, 90, 147, 116, 171, 54, 23, 164, 125, 98, 227, 203, 130, 152, 55, 23, 144, 171, 7, 234])
  }

def rootExecutionExecutionRows : List ExpandedRowView :=
  [{
  traceIndex := 0
  , stepIndex := 0
  , sequenceIndex := 0
  , pc := 0
  , nextPc := 4
  , word := 1048723
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
  traceIndex := 1
  , stepIndex := 1
  , sequenceIndex := 0
  , pc := 4
  , nextPc := 8
  , word := 4293918995
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
  traceIndex := 2
  , stepIndex := 2
  , sequenceIndex := 0
  , pc := 8
  , nextPc := 16
  , word := 2151523
  , opcode := .bge
  , traceOpcode := (some .bge)
  , traceVirtualOpcode := none
  , family := .controlFlow
  , rs1 := 1
  , rs1Value := 1
  , rs2 := 2
  , rs2Value := 18446744073709551615
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
  [{ traceIndex := 0, values := [1, 0, 0, 4, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 4, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [48, 9, 158, 59, 120, 45, 200, 155, 8, 144, 252, 183, 179, 168, 71, 138, 10, 136, 117, 72, 217, 133, 28, 26, 240, 134, 159, 61, 227, 8, 46, 227]), digest := (bytes [77, 97, 131, 255, 203, 134, 45, 198, 175, 166, 39, 170, 211, 141, 143, 44, 217, 157, 82, 58, 43, 137, 198, 85, 25, 93, 188, 205, 7, 120, 191, 196]) }, { traceIndex := 1, values := [1, 4, 0, 8, 0, 0, 0, 0, 0, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 8, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [35, 77, 148, 47, 187, 223, 199, 221, 229, 233, 79, 55, 178, 99, 11, 11, 9, 67, 227, 102, 35, 84, 230, 167, 51, 210, 167, 50, 161, 115, 80, 42]), digest := (bytes [115, 137, 230, 102, 74, 184, 147, 88, 146, 65, 205, 179, 18, 153, 186, 130, 155, 188, 231, 100, 3, 79, 9, 236, 59, 51, 100, 223, 70, 171, 204, 238]) }, { traceIndex := 2, values := [1, 8, 0, 16, 0, 1, 0, 4294967295, 4294967295, 0, 0, 8, 0, 1, 0, 12, 0, 16, 0, 0, 0, 0, 0, 0, 1, 2, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1], rowDigest := (bytes [97, 240, 114, 129, 149, 212, 234, 193, 226, 201, 20, 2, 130, 16, 29, 83, 139, 88, 84, 155, 23, 91, 162, 107, 184, 112, 180, 74, 231, 248, 61, 94]), digest := (bytes [8, 26, 170, 182, 52, 231, 237, 245, 88, 14, 74, 100, 25, 181, 75, 117, 172, 222, 210, 206, 56, 184, 236, 117, 239, 165, 76, 131, 250, 216, 30, 155]) }, { traceIndex := 3, values := [1, 16, 0, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [196, 164, 211, 128, 251, 108, 127, 209, 13, 46, 5, 165, 45, 208, 166, 224, 83, 53, 211, 10, 49, 76, 179, 158, 125, 185, 30, 27, 57, 200, 134, 221]) }]

def rootExecutionPreparedBindings : List PreparedStepBindingView :=
  [{ traceIndex := 0, rowDigest := (bytes [48, 9, 158, 59, 120, 45, 200, 155, 8, 144, 252, 183, 179, 168, 71, 138, 10, 136, 117, 72, 217, 133, 28, 26, 240, 134, 159, 61, 227, 8, 46, 227]), rowOpeningDigest := (bytes [152, 67, 38, 218, 150, 189, 234, 79, 74, 220, 26, 159, 229, 146, 78, 206, 161, 228, 73, 176, 58, 94, 234, 140, 120, 75, 143, 142, 72, 34, 92, 172]), digest := (bytes [228, 186, 196, 100, 214, 97, 204, 91, 47, 206, 34, 198, 29, 200, 203, 87, 232, 28, 132, 169, 17, 190, 217, 45, 135, 51, 200, 19, 206, 178, 215, 73]) }, { traceIndex := 1, rowDigest := (bytes [35, 77, 148, 47, 187, 223, 199, 221, 229, 233, 79, 55, 178, 99, 11, 11, 9, 67, 227, 102, 35, 84, 230, 167, 51, 210, 167, 50, 161, 115, 80, 42]), rowOpeningDigest := (bytes [209, 82, 161, 118, 176, 56, 164, 178, 239, 192, 206, 161, 99, 238, 53, 21, 56, 208, 59, 26, 244, 227, 67, 1, 133, 5, 95, 15, 37, 231, 43, 18]), digest := (bytes [85, 7, 214, 110, 20, 144, 30, 165, 40, 103, 224, 4, 4, 0, 24, 16, 69, 126, 200, 79, 103, 250, 42, 244, 9, 152, 123, 35, 196, 178, 71, 55]) }, { traceIndex := 2, rowDigest := (bytes [97, 240, 114, 129, 149, 212, 234, 193, 226, 201, 20, 2, 130, 16, 29, 83, 139, 88, 84, 155, 23, 91, 162, 107, 184, 112, 180, 74, 231, 248, 61, 94]), rowOpeningDigest := (bytes [226, 212, 221, 31, 190, 43, 24, 162, 80, 167, 201, 244, 106, 235, 250, 249, 198, 10, 254, 155, 169, 111, 108, 254, 181, 170, 160, 109, 200, 246, 213, 101]), digest := (bytes [107, 122, 101, 49, 132, 1, 17, 35, 115, 231, 93, 156, 206, 152, 104, 87, 29, 79, 243, 187, 171, 112, 173, 60, 178, 155, 153, 180, 232, 193, 171, 142]) }, { traceIndex := 3, rowDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), rowOpeningDigest := (bytes [107, 165, 108, 133, 174, 95, 91, 234, 119, 30, 16, 150, 40, 4, 144, 239, 133, 92, 98, 43, 246, 169, 173, 74, 237, 139, 90, 107, 126, 190, 59, 91]), digest := (bytes [254, 99, 83, 87, 142, 13, 25, 128, 17, 223, 67, 18, 69, 171, 237, 57, 247, 99, 239, 18, 152, 182, 82, 245, 246, 112, 106, 248, 5, 254, 200, 205]) }]

def rootExecutionRowChunkRoutes : List RowChunkRouteView :=
  [{ logicalIndex := 0, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 0, digest := (bytes [138, 198, 109, 126, 144, 82, 221, 43, 248, 202, 137, 103, 62, 226, 249, 152, 163, 187, 1, 254, 36, 33, 59, 16, 64, 166, 202, 8, 219, 57, 240, 59]) }, { logicalIndex := 1, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 1, digest := (bytes [44, 177, 82, 41, 218, 60, 100, 208, 26, 31, 151, 113, 109, 148, 57, 12, 223, 21, 76, 221, 70, 245, 191, 105, 57, 199, 8, 128, 181, 145, 89, 99]) }, { logicalIndex := 2, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 2, digest := (bytes [252, 248, 65, 24, 81, 241, 150, 170, 250, 116, 222, 30, 134, 191, 78, 195, 104, 119, 225, 210, 243, 186, 212, 107, 183, 31, 243, 201, 101, 148, 32, 72]) }, { logicalIndex := 3, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 3, digest := (bytes [244, 11, 162, 13, 59, 43, 232, 47, 228, 2, 70, 126, 95, 10, 57, 40, 46, 107, 197, 81, 97, 39, 185, 163, 93, 60, 5, 66, 7, 231, 199, 134]) }]

def rootExecutionRowLocalCcsAcceptance : List RootRowLocalCcsAcceptanceView :=
  [{ traceIndex := 0, logicalIndex := 0, rowDigest := (bytes [48, 9, 158, 59, 120, 45, 200, 155, 8, 144, 252, 183, 179, 168, 71, 138, 10, 136, 117, 72, 217, 133, 28, 26, 240, 134, 159, 61, 227, 8, 46, 227]), rowOpeningDigest := (bytes [152, 67, 38, 218, 150, 189, 234, 79, 74, 220, 26, 159, 229, 146, 78, 206, 161, 228, 73, 176, 58, 94, 234, 140, 120, 75, 143, 142, 72, 34, 92, 172]), preparedStepBindingDigest := (bytes [228, 186, 196, 100, 214, 97, 204, 91, 47, 206, 34, 198, 29, 200, 203, 87, 232, 28, 132, 169, 17, 190, 217, 45, 135, 51, 200, 19, 206, 178, 215, 73]), rowChunkRouteDigest := (bytes [138, 198, 109, 126, 144, 82, 221, 43, 248, 202, 137, 103, 62, 226, 249, 152, 163, 187, 1, 254, 36, 33, 59, 16, 64, 166, 202, 8, 219, 57, 240, 59]), publicStepDigest := (bytes [176, 41, 96, 84, 84, 211, 190, 209, 187, 47, 137, 156, 111, 148, 42, 8, 243, 99, 64, 11, 14, 51, 190, 58, 185, 251, 119, 222, 238, 18, 74, 157]), digest := (bytes [177, 251, 198, 121, 237, 6, 125, 56, 73, 255, 206, 62, 252, 250, 222, 101, 31, 216, 145, 79, 11, 240, 185, 103, 200, 166, 133, 74, 98, 217, 180, 171]) }, { traceIndex := 1, logicalIndex := 1, rowDigest := (bytes [35, 77, 148, 47, 187, 223, 199, 221, 229, 233, 79, 55, 178, 99, 11, 11, 9, 67, 227, 102, 35, 84, 230, 167, 51, 210, 167, 50, 161, 115, 80, 42]), rowOpeningDigest := (bytes [209, 82, 161, 118, 176, 56, 164, 178, 239, 192, 206, 161, 99, 238, 53, 21, 56, 208, 59, 26, 244, 227, 67, 1, 133, 5, 95, 15, 37, 231, 43, 18]), preparedStepBindingDigest := (bytes [85, 7, 214, 110, 20, 144, 30, 165, 40, 103, 224, 4, 4, 0, 24, 16, 69, 126, 200, 79, 103, 250, 42, 244, 9, 152, 123, 35, 196, 178, 71, 55]), rowChunkRouteDigest := (bytes [44, 177, 82, 41, 218, 60, 100, 208, 26, 31, 151, 113, 109, 148, 57, 12, 223, 21, 76, 221, 70, 245, 191, 105, 57, 199, 8, 128, 181, 145, 89, 99]), publicStepDigest := (bytes [215, 117, 135, 32, 80, 73, 151, 241, 163, 240, 166, 166, 24, 108, 125, 148, 78, 39, 149, 152, 30, 136, 197, 139, 108, 165, 146, 102, 173, 138, 205, 202]), digest := (bytes [135, 124, 85, 145, 4, 57, 153, 67, 78, 148, 9, 63, 254, 212, 100, 138, 12, 122, 98, 97, 119, 134, 255, 30, 20, 87, 187, 45, 208, 137, 75, 199]) }, { traceIndex := 2, logicalIndex := 2, rowDigest := (bytes [97, 240, 114, 129, 149, 212, 234, 193, 226, 201, 20, 2, 130, 16, 29, 83, 139, 88, 84, 155, 23, 91, 162, 107, 184, 112, 180, 74, 231, 248, 61, 94]), rowOpeningDigest := (bytes [226, 212, 221, 31, 190, 43, 24, 162, 80, 167, 201, 244, 106, 235, 250, 249, 198, 10, 254, 155, 169, 111, 108, 254, 181, 170, 160, 109, 200, 246, 213, 101]), preparedStepBindingDigest := (bytes [107, 122, 101, 49, 132, 1, 17, 35, 115, 231, 93, 156, 206, 152, 104, 87, 29, 79, 243, 187, 171, 112, 173, 60, 178, 155, 153, 180, 232, 193, 171, 142]), rowChunkRouteDigest := (bytes [252, 248, 65, 24, 81, 241, 150, 170, 250, 116, 222, 30, 134, 191, 78, 195, 104, 119, 225, 210, 243, 186, 212, 107, 183, 31, 243, 201, 101, 148, 32, 72]), publicStepDigest := (bytes [114, 248, 162, 226, 177, 131, 128, 24, 82, 71, 23, 141, 71, 236, 39, 116, 240, 82, 122, 185, 131, 114, 235, 48, 82, 171, 84, 212, 90, 119, 186, 23]), digest := (bytes [157, 91, 57, 207, 55, 174, 89, 141, 67, 151, 94, 220, 41, 138, 106, 62, 140, 244, 203, 149, 19, 163, 98, 37, 90, 103, 210, 255, 147, 134, 152, 77]) }, { traceIndex := 3, logicalIndex := 3, rowDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), rowOpeningDigest := (bytes [107, 165, 108, 133, 174, 95, 91, 234, 119, 30, 16, 150, 40, 4, 144, 239, 133, 92, 98, 43, 246, 169, 173, 74, 237, 139, 90, 107, 126, 190, 59, 91]), preparedStepBindingDigest := (bytes [254, 99, 83, 87, 142, 13, 25, 128, 17, 223, 67, 18, 69, 171, 237, 57, 247, 99, 239, 18, 152, 182, 82, 245, 246, 112, 106, 248, 5, 254, 200, 205]), rowChunkRouteDigest := (bytes [244, 11, 162, 13, 59, 43, 232, 47, 228, 2, 70, 126, 95, 10, 57, 40, 46, 107, 197, 81, 97, 39, 185, 163, 93, 60, 5, 66, 7, 231, 199, 134]), publicStepDigest := (bytes [72, 142, 192, 218, 173, 197, 55, 221, 78, 31, 126, 194, 22, 139, 72, 204, 128, 208, 103, 242, 122, 221, 175, 246, 50, 244, 221, 89, 210, 23, 111, 183]), digest := (bytes [153, 43, 150, 168, 46, 113, 69, 143, 112, 180, 157, 104, 105, 188, 67, 190, 148, 129, 158, 223, 159, 18, 53, 1, 246, 248, 99, 61, 75, 75, 203, 84]) }]

def rootExecutionExecutionSemanticsRefinement : List RootExecutionSemanticsRefinementView :=
  [{ traceIndex := 0, logicalIndex := 0, semanticRowDigest := (bytes [77, 97, 131, 255, 203, 134, 45, 198, 175, 166, 39, 170, 211, 141, 143, 44, 217, 157, 82, 58, 43, 137, 198, 85, 25, 93, 188, 205, 7, 120, 191, 196]), rowLocalCcsAcceptanceDigest := (bytes [177, 251, 198, 121, 237, 6, 125, 56, 73, 255, 206, 62, 252, 250, 222, 101, 31, 216, 145, 79, 11, 240, 185, 103, 200, 166, 133, 74, 98, 217, 180, 171]), preparedStepBindingDigest := (bytes [228, 186, 196, 100, 214, 97, 204, 91, 47, 206, 34, 198, 29, 200, 203, 87, 232, 28, 132, 169, 17, 190, 217, 45, 135, 51, 200, 19, 206, 178, 215, 73]), publicStepDigest := (bytes [176, 41, 96, 84, 84, 211, 190, 209, 187, 47, 137, 156, 111, 148, 42, 8, 243, 99, 64, 11, 14, 51, 190, 58, 185, 251, 119, 222, 238, 18, 74, 157]), digest := (bytes [90, 109, 161, 32, 34, 48, 98, 107, 72, 80, 189, 76, 77, 159, 237, 176, 190, 163, 11, 160, 8, 183, 71, 88, 210, 200, 137, 141, 27, 64, 9, 38]) }, { traceIndex := 1, logicalIndex := 1, semanticRowDigest := (bytes [115, 137, 230, 102, 74, 184, 147, 88, 146, 65, 205, 179, 18, 153, 186, 130, 155, 188, 231, 100, 3, 79, 9, 236, 59, 51, 100, 223, 70, 171, 204, 238]), rowLocalCcsAcceptanceDigest := (bytes [135, 124, 85, 145, 4, 57, 153, 67, 78, 148, 9, 63, 254, 212, 100, 138, 12, 122, 98, 97, 119, 134, 255, 30, 20, 87, 187, 45, 208, 137, 75, 199]), preparedStepBindingDigest := (bytes [85, 7, 214, 110, 20, 144, 30, 165, 40, 103, 224, 4, 4, 0, 24, 16, 69, 126, 200, 79, 103, 250, 42, 244, 9, 152, 123, 35, 196, 178, 71, 55]), publicStepDigest := (bytes [215, 117, 135, 32, 80, 73, 151, 241, 163, 240, 166, 166, 24, 108, 125, 148, 78, 39, 149, 152, 30, 136, 197, 139, 108, 165, 146, 102, 173, 138, 205, 202]), digest := (bytes [230, 162, 33, 156, 38, 79, 46, 72, 211, 113, 159, 158, 131, 165, 213, 17, 45, 56, 45, 235, 109, 111, 126, 134, 195, 98, 60, 50, 4, 92, 24, 169]) }, { traceIndex := 2, logicalIndex := 2, semanticRowDigest := (bytes [8, 26, 170, 182, 52, 231, 237, 245, 88, 14, 74, 100, 25, 181, 75, 117, 172, 222, 210, 206, 56, 184, 236, 117, 239, 165, 76, 131, 250, 216, 30, 155]), rowLocalCcsAcceptanceDigest := (bytes [157, 91, 57, 207, 55, 174, 89, 141, 67, 151, 94, 220, 41, 138, 106, 62, 140, 244, 203, 149, 19, 163, 98, 37, 90, 103, 210, 255, 147, 134, 152, 77]), preparedStepBindingDigest := (bytes [107, 122, 101, 49, 132, 1, 17, 35, 115, 231, 93, 156, 206, 152, 104, 87, 29, 79, 243, 187, 171, 112, 173, 60, 178, 155, 153, 180, 232, 193, 171, 142]), publicStepDigest := (bytes [114, 248, 162, 226, 177, 131, 128, 24, 82, 71, 23, 141, 71, 236, 39, 116, 240, 82, 122, 185, 131, 114, 235, 48, 82, 171, 84, 212, 90, 119, 186, 23]), digest := (bytes [116, 221, 88, 161, 178, 25, 201, 157, 164, 233, 240, 82, 251, 228, 139, 67, 214, 220, 190, 27, 73, 161, 96, 236, 113, 158, 215, 109, 62, 200, 184, 192]) }, { traceIndex := 3, logicalIndex := 3, semanticRowDigest := (bytes [196, 164, 211, 128, 251, 108, 127, 209, 13, 46, 5, 165, 45, 208, 166, 224, 83, 53, 211, 10, 49, 76, 179, 158, 125, 185, 30, 27, 57, 200, 134, 221]), rowLocalCcsAcceptanceDigest := (bytes [153, 43, 150, 168, 46, 113, 69, 143, 112, 180, 157, 104, 105, 188, 67, 190, 148, 129, 158, 223, 159, 18, 53, 1, 246, 248, 99, 61, 75, 75, 203, 84]), preparedStepBindingDigest := (bytes [254, 99, 83, 87, 142, 13, 25, 128, 17, 223, 67, 18, 69, 171, 237, 57, 247, 99, 239, 18, 152, 182, 82, 245, 246, 112, 106, 248, 5, 254, 200, 205]), publicStepDigest := (bytes [72, 142, 192, 218, 173, 197, 55, 221, 78, 31, 126, 194, 22, 139, 72, 204, 128, 208, 103, 242, 122, 221, 175, 246, 50, 244, 221, 89, 210, 23, 111, 183]), digest := (bytes [104, 241, 81, 156, 122, 170, 193, 142, 67, 99, 86, 189, 206, 202, 1, 151, 156, 239, 163, 222, 37, 210, 81, 71, 103, 159, 181, 89, 73, 243, 129, 236]) }]

def rootExecution : RootExecutionBundleView :=
  {
    executionRows := rootExecutionExecutionRows
    , semanticRows := rootExecutionSemanticRows
    , semanticRowsDigest := (bytes [71, 168, 252, 50, 89, 118, 14, 223, 81, 39, 153, 238, 30, 99, 52, 86, 187, 173, 76, 65, 137, 124, 118, 19, 179, 55, 254, 251, 77, 220, 29, 111])
    , preparedStepBindings := { bindings := rootExecutionPreparedBindings, bindingCount := 4, firstBindingDigest := (some (bytes [228, 186, 196, 100, 214, 97, 204, 91, 47, 206, 34, 198, 29, 200, 203, 87, 232, 28, 132, 169, 17, 190, 217, 45, 135, 51, 200, 19, 206, 178, 215, 73])), lastBindingDigest := (some (bytes [254, 99, 83, 87, 142, 13, 25, 128, 17, 223, 67, 18, 69, 171, 237, 57, 247, 99, 239, 18, 152, 182, 82, 245, 246, 112, 106, 248, 5, 254, 200, 205])), digest := (bytes [251, 44, 102, 51, 115, 137, 29, 19, 101, 96, 19, 177, 197, 174, 40, 175, 43, 192, 215, 236, 30, 246, 118, 195, 16, 94, 178, 189, 154, 138, 180, 39]) }
    , rowChunkRoutes := rootExecutionRowChunkRoutes
    , rowChunkRoutesDigest := (bytes [170, 16, 215, 245, 131, 192, 198, 120, 95, 134, 175, 93, 217, 74, 16, 26, 237, 138, 81, 110, 201, 10, 195, 254, 244, 178, 29, 18, 146, 128, 117, 178])
    , rowLocalCcsAcceptance := { acceptances := rootExecutionRowLocalCcsAcceptance, acceptanceCount := 4, firstAcceptanceDigest := (some (bytes [177, 251, 198, 121, 237, 6, 125, 56, 73, 255, 206, 62, 252, 250, 222, 101, 31, 216, 145, 79, 11, 240, 185, 103, 200, 166, 133, 74, 98, 217, 180, 171])), lastAcceptanceDigest := (some (bytes [153, 43, 150, 168, 46, 113, 69, 143, 112, 180, 157, 104, 105, 188, 67, 190, 148, 129, 158, 223, 159, 18, 53, 1, 246, 248, 99, 61, 75, 75, 203, 84])), digest := (bytes [79, 50, 248, 74, 174, 1, 212, 171, 235, 126, 250, 233, 206, 142, 166, 179, 50, 180, 242, 78, 40, 239, 237, 7, 251, 89, 34, 203, 6, 125, 150, 162]) }
    , executionSemanticsRefinement := { refinements := rootExecutionExecutionSemanticsRefinement, refinementCount := 4, firstRefinementDigest := (some (bytes [90, 109, 161, 32, 34, 48, 98, 107, 72, 80, 189, 76, 77, 159, 237, 176, 190, 163, 11, 160, 8, 183, 71, 88, 210, 200, 137, 141, 27, 64, 9, 38])), lastRefinementDigest := (some (bytes [104, 241, 81, 156, 122, 170, 193, 142, 67, 99, 86, 189, 206, 202, 1, 151, 156, 239, 163, 222, 37, 210, 81, 71, 103, 159, 181, 89, 73, 243, 129, 236])), digest := (bytes [239, 223, 83, 69, 20, 39, 101, 50, 148, 235, 255, 125, 41, 225, 226, 209, 136, 58, 62, 7, 209, 77, 89, 148, 116, 113, 114, 12, 145, 226, 121, 88]) }
    , familyDigest := (bytes [145, 185, 120, 4, 182, 105, 56, 218, 160, 76, 130, 184, 185, 23, 212, 85, 29, 144, 2, 172, 228, 214, 153, 212, 237, 73, 247, 209, 214, 142, 172, 26])
    , digest := (bytes [158, 129, 18, 28, 97, 48, 103, 40, 13, 19, 128, 215, 48, 178, 190, 173, 191, 247, 210, 197, 192, 245, 250, 38, 19, 146, 231, 124, 35, 183, 229, 253])
  }

def kernelOpeningBundle : SimpleKernelOpeningBundleView :=
  {
    claim := { bindings := { stageClaimBundleDigest := (bytes [17, 193, 15, 43, 182, 63, 169, 246, 9, 163, 37, 248, 60, 182, 213, 157, 45, 152, 237, 186, 229, 9, 96, 190, 168, 42, 83, 141, 22, 6, 78, 230]), stagePackageBundleDigest := (bytes [140, 94, 154, 70, 93, 22, 120, 56, 19, 77, 149, 236, 33, 93, 123, 74, 8, 13, 64, 45, 96, 211, 193, 86, 184, 131, 57, 113, 7, 160, 71, 58]), stage1PackageDigest := (bytes [130, 129, 202, 81, 175, 224, 184, 214, 119, 142, 209, 228, 193, 5, 42, 7, 83, 216, 66, 148, 207, 221, 63, 154, 240, 91, 166, 85, 142, 164, 247, 126]), stage2PackageDigest := (bytes [118, 16, 79, 238, 183, 157, 103, 240, 236, 215, 2, 44, 197, 195, 41, 138, 44, 171, 242, 251, 141, 116, 188, 248, 1, 7, 218, 45, 17, 69, 218, 252]), stage3PackageDigest := (bytes [117, 32, 110, 162, 230, 226, 48, 10, 111, 101, 147, 148, 48, 207, 7, 68, 89, 76, 52, 59, 26, 160, 178, 97, 243, 194, 177, 222, 86, 8, 100, 204]), preparedStepBindingsDigest := (bytes [251, 44, 102, 51, 115, 137, 29, 19, 101, 96, 19, 177, 197, 174, 40, 175, 43, 192, 215, 236, 30, 246, 118, 195, 16, 94, 178, 189, 154, 138, 180, 39]), bindingCount := 4, stage1RowCount := 4, stage2RegisterReadCount := 4, stage2RegisterWriteCount := 2, stage2RamEventCount := 0, stage3ContinuityCount := 4, points := { firstBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [251, 44, 102, 51, 115, 137, 29, 19, 101, 96, 19, 177, 197, 174, 40, 175, 43, 192, 215, 236, 30, 246, 118, 195, 16, 94, 178, 189, 154, 138, 180, 39]), layoutVersion := 1, digest := (bytes [148, 119, 231, 149, 197, 120, 69, 181, 213, 105, 126, 241, 87, 120, 43, 21, 166, 69, 44, 3, 52, 36, 158, 76, 152, 36, 93, 59, 52, 129, 190, 28]) }, logicalIndex := 0, digest := (bytes [32, 161, 190, 134, 197, 143, 250, 84, 106, 186, 209, 140, 0, 6, 22, 69, 159, 86, 156, 45, 57, 157, 183, 113, 89, 50, 251, 80, 236, 44, 123, 245]) }, valueDigest := (bytes [228, 186, 196, 100, 214, 97, 204, 91, 47, 206, 34, 198, 29, 200, 203, 87, 232, 28, 132, 169, 17, 190, 217, 45, 135, 51, 200, 19, 206, 178, 215, 73]), digest := (bytes [37, 147, 164, 107, 207, 79, 108, 45, 228, 84, 208, 69, 178, 198, 208, 244, 226, 63, 89, 255, 218, 39, 87, 67, 130, 125, 65, 119, 57, 254, 6, 5]) }), lastBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [251, 44, 102, 51, 115, 137, 29, 19, 101, 96, 19, 177, 197, 174, 40, 175, 43, 192, 215, 236, 30, 246, 118, 195, 16, 94, 178, 189, 154, 138, 180, 39]), layoutVersion := 1, digest := (bytes [148, 119, 231, 149, 197, 120, 69, 181, 213, 105, 126, 241, 87, 120, 43, 21, 166, 69, 44, 3, 52, 36, 158, 76, 152, 36, 93, 59, 52, 129, 190, 28]) }, logicalIndex := 3, digest := (bytes [60, 216, 45, 113, 183, 140, 55, 158, 74, 77, 202, 126, 99, 48, 159, 111, 131, 172, 12, 133, 83, 58, 160, 74, 157, 47, 134, 115, 112, 70, 243, 246]) }, valueDigest := (bytes [254, 99, 83, 87, 142, 13, 25, 128, 17, 223, 67, 18, 69, 171, 237, 57, 247, 99, 239, 18, 152, 182, 82, 245, 246, 112, 106, 248, 5, 254, 200, 205]), digest := (bytes [108, 198, 247, 11, 221, 251, 76, 246, 248, 123, 157, 164, 37, 155, 218, 84, 111, 92, 53, 178, 222, 247, 126, 95, 8, 119, 245, 245, 114, 19, 119, 11]) }) }, digest := (bytes [127, 96, 181, 164, 194, 213, 41, 84, 240, 113, 123, 107, 57, 202, 195, 7, 9, 198, 249, 119, 27, 56, 210, 1, 250, 36, 73, 181, 222, 75, 80, 157]) }, preparedSteps := { executionDigest := (bytes [14, 218, 199, 227, 116, 94, 179, 48, 175, 100, 127, 227, 52, 186, 29, 20, 52, 186, 208, 59, 240, 120, 150, 172, 197, 158, 248, 136, 149, 25, 87, 170]), finalStateDigest := (bytes [233, 2, 26, 64, 110, 89, 182, 250, 115, 142, 225, 137, 122, 240, 120, 174, 71, 71, 199, 38, 167, 175, 50, 4, 209, 82, 12, 195, 102, 116, 18, 219]), transcriptFinalDigest := (bytes [154, 235, 231, 248, 17, 4, 254, 96, 238, 36, 253, 176, 255, 121, 199, 186, 129, 238, 41, 44, 149, 7, 72, 29, 143, 254, 142, 7, 48, 117, 104, 102]), preparedStepCount := 4, finalPc := 20, halted := true, points := { firstPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [78, 112, 96, 107, 186, 151, 14, 73, 226, 146, 137, 145, 183, 51, 53, 228, 122, 108, 60, 52, 98, 17, 23, 23, 93, 228, 209, 25, 87, 61, 135, 39]), layoutVersion := 3, digest := (bytes [142, 215, 206, 200, 110, 197, 140, 8, 50, 119, 131, 108, 114, 183, 207, 142, 143, 138, 16, 193, 88, 249, 130, 60, 72, 218, 144, 7, 98, 5, 98, 51]) }, logicalIndex := 0, digest := (bytes [185, 118, 70, 229, 49, 2, 200, 218, 33, 247, 137, 217, 135, 84, 230, 197, 19, 47, 60, 48, 6, 242, 204, 224, 209, 163, 179, 39, 200, 72, 250, 106]) }, valueDigest := (bytes [48, 9, 158, 59, 120, 45, 200, 155, 8, 144, 252, 183, 179, 168, 71, 138, 10, 136, 117, 72, 217, 133, 28, 26, 240, 134, 159, 61, 227, 8, 46, 227]), digest := (bytes [140, 205, 179, 71, 211, 37, 11, 234, 8, 119, 236, 183, 30, 232, 232, 238, 74, 242, 245, 47, 6, 195, 73, 200, 189, 138, 206, 121, 159, 131, 204, 208]) }), lastPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [78, 112, 96, 107, 186, 151, 14, 73, 226, 146, 137, 145, 183, 51, 53, 228, 122, 108, 60, 52, 98, 17, 23, 23, 93, 228, 209, 25, 87, 61, 135, 39]), layoutVersion := 3, digest := (bytes [142, 215, 206, 200, 110, 197, 140, 8, 50, 119, 131, 108, 114, 183, 207, 142, 143, 138, 16, 193, 88, 249, 130, 60, 72, 218, 144, 7, 98, 5, 98, 51]) }, logicalIndex := 3, digest := (bytes [241, 74, 29, 162, 217, 212, 2, 197, 83, 67, 8, 50, 75, 64, 52, 223, 39, 121, 92, 14, 223, 108, 155, 146, 136, 31, 254, 16, 141, 172, 24, 246]) }, valueDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [197, 174, 83, 47, 237, 159, 237, 193, 255, 249, 235, 118, 39, 230, 112, 151, 155, 242, 18, 242, 69, 119, 21, 118, 245, 166, 248, 68, 177, 255, 7, 197]) }) }, digest := (bytes [138, 129, 80, 78, 231, 248, 68, 174, 19, 130, 220, 205, 164, 82, 85, 69, 214, 240, 41, 237, 241, 125, 190, 240, 96, 15, 43, 252, 249, 221, 25, 184]) }, digest := (bytes [77, 103, 2, 222, 234, 43, 49, 240, 209, 226, 227, 228, 78, 45, 41, 84, 188, 114, 33, 24, 238, 114, 121, 171, 235, 20, 5, 64, 2, 47, 141, 70]) }
    , bindings := { claim := { stageClaimBundleDigest := (bytes [17, 193, 15, 43, 182, 63, 169, 246, 9, 163, 37, 248, 60, 182, 213, 157, 45, 152, 237, 186, 229, 9, 96, 190, 168, 42, 83, 141, 22, 6, 78, 230]), stagePackageBundleDigest := (bytes [140, 94, 154, 70, 93, 22, 120, 56, 19, 77, 149, 236, 33, 93, 123, 74, 8, 13, 64, 45, 96, 211, 193, 86, 184, 131, 57, 113, 7, 160, 71, 58]), stage1PackageDigest := (bytes [130, 129, 202, 81, 175, 224, 184, 214, 119, 142, 209, 228, 193, 5, 42, 7, 83, 216, 66, 148, 207, 221, 63, 154, 240, 91, 166, 85, 142, 164, 247, 126]), stage2PackageDigest := (bytes [118, 16, 79, 238, 183, 157, 103, 240, 236, 215, 2, 44, 197, 195, 41, 138, 44, 171, 242, 251, 141, 116, 188, 248, 1, 7, 218, 45, 17, 69, 218, 252]), stage3PackageDigest := (bytes [117, 32, 110, 162, 230, 226, 48, 10, 111, 101, 147, 148, 48, 207, 7, 68, 89, 76, 52, 59, 26, 160, 178, 97, 243, 194, 177, 222, 86, 8, 100, 204]), preparedStepBindingsDigest := (bytes [251, 44, 102, 51, 115, 137, 29, 19, 101, 96, 19, 177, 197, 174, 40, 175, 43, 192, 215, 236, 30, 246, 118, 195, 16, 94, 178, 189, 154, 138, 180, 39]), bindingCount := 4, stage1RowCount := 4, stage2RegisterReadCount := 4, stage2RegisterWriteCount := 2, stage2RamEventCount := 0, stage3ContinuityCount := 4, points := { firstBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [251, 44, 102, 51, 115, 137, 29, 19, 101, 96, 19, 177, 197, 174, 40, 175, 43, 192, 215, 236, 30, 246, 118, 195, 16, 94, 178, 189, 154, 138, 180, 39]), layoutVersion := 1, digest := (bytes [148, 119, 231, 149, 197, 120, 69, 181, 213, 105, 126, 241, 87, 120, 43, 21, 166, 69, 44, 3, 52, 36, 158, 76, 152, 36, 93, 59, 52, 129, 190, 28]) }, logicalIndex := 0, digest := (bytes [32, 161, 190, 134, 197, 143, 250, 84, 106, 186, 209, 140, 0, 6, 22, 69, 159, 86, 156, 45, 57, 157, 183, 113, 89, 50, 251, 80, 236, 44, 123, 245]) }, valueDigest := (bytes [228, 186, 196, 100, 214, 97, 204, 91, 47, 206, 34, 198, 29, 200, 203, 87, 232, 28, 132, 169, 17, 190, 217, 45, 135, 51, 200, 19, 206, 178, 215, 73]), digest := (bytes [37, 147, 164, 107, 207, 79, 108, 45, 228, 84, 208, 69, 178, 198, 208, 244, 226, 63, 89, 255, 218, 39, 87, 67, 130, 125, 65, 119, 57, 254, 6, 5]) }), lastBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [251, 44, 102, 51, 115, 137, 29, 19, 101, 96, 19, 177, 197, 174, 40, 175, 43, 192, 215, 236, 30, 246, 118, 195, 16, 94, 178, 189, 154, 138, 180, 39]), layoutVersion := 1, digest := (bytes [148, 119, 231, 149, 197, 120, 69, 181, 213, 105, 126, 241, 87, 120, 43, 21, 166, 69, 44, 3, 52, 36, 158, 76, 152, 36, 93, 59, 52, 129, 190, 28]) }, logicalIndex := 3, digest := (bytes [60, 216, 45, 113, 183, 140, 55, 158, 74, 77, 202, 126, 99, 48, 159, 111, 131, 172, 12, 133, 83, 58, 160, 74, 157, 47, 134, 115, 112, 70, 243, 246]) }, valueDigest := (bytes [254, 99, 83, 87, 142, 13, 25, 128, 17, 223, 67, 18, 69, 171, 237, 57, 247, 99, 239, 18, 152, 182, 82, 245, 246, 112, 106, 248, 5, 254, 200, 205]), digest := (bytes [108, 198, 247, 11, 221, 251, 76, 246, 248, 123, 157, 164, 37, 155, 218, 84, 111, 92, 53, 178, 222, 247, 126, 95, 8, 119, 245, 245, 114, 19, 119, 11]) }) }, digest := (bytes [127, 96, 181, 164, 194, 213, 41, 84, 240, 113, 123, 107, 57, 202, 195, 7, 9, 198, 249, 119, 27, 56, 210, 1, 250, 36, 73, 181, 222, 75, 80, 157]) }, packaged := { statementDigest := (bytes [179, 247, 254, 204, 172, 255, 228, 253, 14, 52, 49, 104, 152, 44, 240, 77, 81, 60, 220, 9, 162, 203, 95, 249, 246, 40, 202, 203, 128, 209, 167, 93]), proofDigest := (bytes [230, 13, 163, 128, 247, 151, 110, 243, 252, 60, 31, 171, 237, 20, 136, 190, 4, 63, 149, 199, 80, 34, 225, 53, 61, 19, 191, 5, 85, 169, 170, 58]) }, digest := (bytes [88, 7, 176, 215, 36, 174, 16, 232, 56, 49, 208, 136, 99, 190, 111, 56, 188, 234, 202, 72, 118, 224, 154, 33, 195, 68, 82, 11, 157, 134, 183, 83]) }
    , preparedSteps := { claim := { executionDigest := (bytes [14, 218, 199, 227, 116, 94, 179, 48, 175, 100, 127, 227, 52, 186, 29, 20, 52, 186, 208, 59, 240, 120, 150, 172, 197, 158, 248, 136, 149, 25, 87, 170]), finalStateDigest := (bytes [233, 2, 26, 64, 110, 89, 182, 250, 115, 142, 225, 137, 122, 240, 120, 174, 71, 71, 199, 38, 167, 175, 50, 4, 209, 82, 12, 195, 102, 116, 18, 219]), transcriptFinalDigest := (bytes [154, 235, 231, 248, 17, 4, 254, 96, 238, 36, 253, 176, 255, 121, 199, 186, 129, 238, 41, 44, 149, 7, 72, 29, 143, 254, 142, 7, 48, 117, 104, 102]), preparedStepCount := 4, finalPc := 20, halted := true, points := { firstPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [78, 112, 96, 107, 186, 151, 14, 73, 226, 146, 137, 145, 183, 51, 53, 228, 122, 108, 60, 52, 98, 17, 23, 23, 93, 228, 209, 25, 87, 61, 135, 39]), layoutVersion := 3, digest := (bytes [142, 215, 206, 200, 110, 197, 140, 8, 50, 119, 131, 108, 114, 183, 207, 142, 143, 138, 16, 193, 88, 249, 130, 60, 72, 218, 144, 7, 98, 5, 98, 51]) }, logicalIndex := 0, digest := (bytes [185, 118, 70, 229, 49, 2, 200, 218, 33, 247, 137, 217, 135, 84, 230, 197, 19, 47, 60, 48, 6, 242, 204, 224, 209, 163, 179, 39, 200, 72, 250, 106]) }, valueDigest := (bytes [48, 9, 158, 59, 120, 45, 200, 155, 8, 144, 252, 183, 179, 168, 71, 138, 10, 136, 117, 72, 217, 133, 28, 26, 240, 134, 159, 61, 227, 8, 46, 227]), digest := (bytes [140, 205, 179, 71, 211, 37, 11, 234, 8, 119, 236, 183, 30, 232, 232, 238, 74, 242, 245, 47, 6, 195, 73, 200, 189, 138, 206, 121, 159, 131, 204, 208]) }), lastPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [78, 112, 96, 107, 186, 151, 14, 73, 226, 146, 137, 145, 183, 51, 53, 228, 122, 108, 60, 52, 98, 17, 23, 23, 93, 228, 209, 25, 87, 61, 135, 39]), layoutVersion := 3, digest := (bytes [142, 215, 206, 200, 110, 197, 140, 8, 50, 119, 131, 108, 114, 183, 207, 142, 143, 138, 16, 193, 88, 249, 130, 60, 72, 218, 144, 7, 98, 5, 98, 51]) }, logicalIndex := 3, digest := (bytes [241, 74, 29, 162, 217, 212, 2, 197, 83, 67, 8, 50, 75, 64, 52, 223, 39, 121, 92, 14, 223, 108, 155, 146, 136, 31, 254, 16, 141, 172, 24, 246]) }, valueDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [197, 174, 83, 47, 237, 159, 237, 193, 255, 249, 235, 118, 39, 230, 112, 151, 155, 242, 18, 242, 69, 119, 21, 118, 245, 166, 248, 68, 177, 255, 7, 197]) }) }, digest := (bytes [138, 129, 80, 78, 231, 248, 68, 174, 19, 130, 220, 205, 164, 82, 85, 69, 214, 240, 41, 237, 241, 125, 190, 240, 96, 15, 43, 252, 249, 221, 25, 184]) }, packaged := { statementDigest := (bytes [178, 148, 188, 87, 230, 237, 171, 174, 49, 149, 185, 130, 251, 253, 202, 101, 30, 132, 188, 202, 158, 83, 17, 148, 110, 152, 242, 248, 196, 117, 105, 9]), proofDigest := (bytes [178, 193, 185, 55, 138, 25, 127, 104, 239, 127, 36, 125, 239, 110, 229, 213, 130, 216, 21, 176, 158, 10, 137, 99, 176, 112, 120, 118, 160, 122, 30, 41]) }, digest := (bytes [9, 215, 28, 243, 185, 219, 54, 176, 76, 253, 248, 48, 195, 69, 255, 143, 199, 197, 230, 103, 76, 155, 65, 155, 76, 172, 221, 195, 119, 225, 113, 128]) }
    , digest := (bytes [10, 169, 156, 45, 147, 202, 6, 88, 155, 159, 166, 91, 178, 107, 90, 185, 17, 121, 45, 178, 80, 28, 248, 3, 171, 64, 217, 23, 70, 122, 185, 213])
  }

def stepComposition : StepCompositionSurfaceView :=
  {
    stage1SemanticsDigest := (bytes [169, 33, 39, 3, 150, 119, 57, 89, 151, 197, 202, 81, 70, 53, 157, 194, 148, 201, 219, 248, 46, 178, 113, 134, 55, 216, 54, 168, 140, 177, 254, 179])
    , stage2SemanticsDigest := (bytes [240, 92, 74, 192, 53, 234, 0, 149, 84, 27, 168, 203, 112, 255, 121, 51, 51, 94, 37, 82, 254, 200, 207, 84, 129, 190, 39, 129, 228, 202, 221, 71])
    , stage2TemporalDigest := (bytes [107, 8, 74, 107, 154, 80, 58, 185, 24, 50, 46, 178, 126, 97, 40, 74, 199, 107, 102, 199, 29, 236, 223, 104, 28, 116, 161, 51, 21, 185, 178, 64])
    , stage3SemanticsDigest := (bytes [174, 219, 61, 83, 82, 247, 207, 73, 92, 129, 3, 68, 57, 214, 24, 144, 154, 37, 2, 226, 240, 182, 6, 29, 88, 171, 107, 84, 225, 209, 141, 220])
    , rootExecutionDigest := (bytes [158, 129, 18, 28, 97, 48, 103, 40, 13, 19, 128, 215, 48, 178, 190, 173, 191, 247, 210, 197, 192, 245, 250, 38, 19, 146, 231, 124, 35, 183, 229, 253])
    , preparedStepBindingsDigest := (bytes [251, 44, 102, 51, 115, 137, 29, 19, 101, 96, 19, 177, 197, 174, 40, 175, 43, 192, 215, 236, 30, 246, 118, 195, 16, 94, 178, 189, 154, 138, 180, 39])
    , rowChunkRoutesDigest := (bytes [170, 16, 215, 245, 131, 192, 198, 120, 95, 134, 175, 93, 217, 74, 16, 26, 237, 138, 81, 110, 201, 10, 195, 254, 244, 178, 29, 18, 146, 128, 117, 178])
    , realRowCount := 4
    , preparedStepCount := 4
    , firstRealStepIndex := 0
    , lastRealStepIndex := 3
    , initialPc := 0
    , finalPc := 20
    , halted := true
    , digest := (bytes [42, 118, 17, 137, 114, 151, 138, 211, 189, 79, 108, 83, 82, 122, 48, 255, 226, 77, 189, 90, 115, 95, 60, 30, 112, 160, 26, 175, 90, 104, 73, 194])
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
    name := "control_flow_bge_taken_skip_ecall"
    , source := {
  manifest := { name := "control_flow_bge_taken_skip_ecall", fixtureId := "control_flow_bge_taken_skip_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.controlFlow, .nativeAlu] }
  , startPc := 0
  , programWords := [1048723, 4293918995, 2151523, 115, 115]
  , initialRegisters := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , initialMemory := []
  , transcriptSeed := (bytes [114, 118, 54, 52, 105, 109, 45, 99, 111, 110, 116, 114, 111, 108, 45, 102, 108, 111, 119, 45, 98, 103, 101, 45, 118, 49])
}
    , derived := {
  manifest := { name := "control_flow_bge_taken_skip_ecall", fixtureId := "control_flow_bge_taken_skip_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.controlFlow, .nativeAlu] }
  , executionRows := [{
  traceIndex := 0
  , stepIndex := 0
  , sequenceIndex := 0
  , pc := 0
  , nextPc := 4
  , word := 1048723
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
  traceIndex := 1
  , stepIndex := 1
  , sequenceIndex := 0
  , pc := 4
  , nextPc := 8
  , word := 4293918995
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
  traceIndex := 2
  , stepIndex := 2
  , sequenceIndex := 0
  , pc := 8
  , nextPc := 16
  , word := 2151523
  , opcode := .bge
  , traceOpcode := (some .bge)
  , traceVirtualOpcode := none
  , family := .controlFlow
  , rs1 := 1
  , rs1Value := 1
  , rs2 := 2
  , rs2Value := 18446744073709551615
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
  , stage1 := { rows := [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 1048723, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 4, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 1, rdAfter := 1, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 4293918995, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 8, aluResult := 18446744073709551615, effectiveAddr := none, writesRd := true, rd := 2, rdAfter := 18446744073709551615, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 2151523, opcode := .bge, traceOpcode := (some .bge), traceVirtualOpcode := none, family := .controlFlow, nextPc := 16, aluResult := 1, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 16, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 20, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }] }
  , stage2 := {
  registerReads := [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 0, value := 0 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 0, value := 0 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 1, value := 1 }, { traceIndex := 2, stepIndex := 2, role := .rs2, reg := 2, value := 18446744073709551615 }]
  , registerWrites := [{ traceIndex := 0, stepIndex := 0, reg := 1, previous := 0, next := 1 }, { traceIndex := 1, stepIndex := 1, reg := 2, previous := 0, next := 18446744073709551615 }]
  , ramEvents := []
  , twistLinks := [{ traceIndex := 0, stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 1, family := .nativeAlu, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 2, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 3, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]
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
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 99, 111, 110, 116, 114, 111, 108, 45, 102, 108, 111, 119, 45, 98, 103, 101, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [27634538711377453, 212436084071, 13380622803955469567, 3521951206484747623, 9254679819230523135, 7793219495316757120, 11804775929249192629, 11428962190686586919], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [99, 111, 110, 116, 114, 111, 108, 95, 102, 108, 111, 119, 95, 98, 103, 101, 95, 116, 97, 107, 101, 110, 95, 115, 107, 105, 112, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [27634538711377453, 212436084071, 13380622803955469567, 3521951206484747623, 9254679819230523135, 7793219495316757120, 11804775929249192629, 11428962190686586919], absorbed := 2 }
  , cursorAfter := { stateWords := [465674789733, 15215007983741485913, 1874102496922678124, 15811577226146168675, 12499081103431237419, 6236543849577039589, 18364626348649379228, 9605098834442363174], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [1048723, 4293918995, 2151523, 115, 115]
  , cursorBefore := { stateWords := [465674789733, 15215007983741485913, 1874102496922678124, 15811577226146168675, 12499081103431237419, 6236543849577039589, 18364626348649379228, 9605098834442363174], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 3863308733289208625, 7732092715818731724, 10897732674725557640, 5122957389714755714, 14412050624005899228, 1750636057271584042, 12393219942905639417], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [0, 3863308733289208625, 7732092715818731724, 10897732674725557640, 5122957389714755714, 14412050624005899228, 1750636057271584042, 12393219942905639417], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 0, 0, 16151006258102468094, 8781961033189472703, 12134297468010880506, 14040033356860820732, 5708464117521822575], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [0, 0, 0, 16151006258102468094, 8781961033189472703, 12134297468010880506, 14040033356860820732, 5708464117521822575], absorbed := 3 }
  , cursorAfter := { stateWords := [0, 13274361720229328095, 6743633916125540037, 11091420359420822032, 16156375987694885752, 8426099295295468575, 8641798412692801466, 10646262291278467146], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [72, 152, 175, 61, 117, 151, 32, 177, 71, 104, 246, 95, 143, 151, 74, 89, 231, 218, 126, 100, 152, 157, 138, 113, 5, 107, 158, 151, 6, 22, 95, 167])
  , u64s := []
  , cursorBefore := { stateWords := [0, 13274361720229328095, 6743633916125540037, 11091420359420822032, 16156375987694885752, 8426099295295468575, 8641798412692801466, 10646262291278467146], absorbed := 1 }
  , cursorAfter := { stateWords := [14357883205051597627, 13561141896955339720, 1211624597452199648, 4365701353448657734, 14478822131144684645, 16118358895982733284, 15277660066242757454, 15771106702652292425], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [14357883205051597627, 13561141896955339720, 1211624597452199648, 4365701353448657734, 14478822131144684645, 16118358895982733284, 15277660066242757454, 15771106702652292425], absorbed := 0 }
  , cursorAfter := { stateWords := [6088699767227576722, 12528948519504330862, 11279663846586579329, 17869051528129767402, 11889200830506914295, 10599455837063559955, 759464082804430731, 15283912685368151612], absorbed := 0 }
  , challengeOutput := (some 6088699767227576722)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [111, 27, 127, 199, 224, 106, 179, 224, 100, 158, 193, 168, 87, 52, 192, 102, 12, 142, 204, 107, 172, 208, 173, 109, 195, 250, 231, 36, 211, 96, 202, 41])
  , u64s := []
  , cursorBefore := { stateWords := [6088699767227576722, 12528948519504330862, 11279663846586579329, 17869051528129767402, 11889200830506914295, 10599455837063559955, 759464082804430731, 15283912685368151612], absorbed := 0 }
  , cursorAfter := { stateWords := [48532222294910656, 10388163368168912, 701128915, 14843658696269909404, 632567264487924670, 9495684395542701107, 12754696978657578631, 5965019087477990409], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [48532222294910656, 10388163368168912, 701128915, 14843658696269909404, 632567264487924670, 9495684395542701107, 12754696978657578631, 5965019087477990409], absorbed := 3 }
  , cursorAfter := { stateWords := [13380091740178962810, 1987045513776597526, 14252462800775023989, 13248926025003527830, 11922324911447888953, 15258157582598726077, 10666093963908230844, 10326266213215111518], absorbed := 0 }
  , challengeOutput := (some 13380091740178962810)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [13380091740178962810, 1987045513776597526, 14252462800775023989, 13248926025003527830, 11922324911447888953, 15258157582598726077, 10666093963908230844, 10326266213215111518], absorbed := 0 }
  , cursorAfter := { stateWords := [15897272204832747763, 11309953007401633108, 9308121576220038094, 14421880181001689210, 1035619753428010656, 5328331505368064188, 7303431608412067335, 3324893135966130710], absorbed := 0 }
  , challengeOutput := (some 15897272204832747763)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [41, 249, 151, 99, 238, 144, 154, 142, 199, 178, 160, 62, 82, 25, 55, 207, 119, 207, 88, 40, 18, 163, 232, 49, 21, 199, 146, 193, 148, 227, 131, 60])
  , u64s := []
  , cursorBefore := { stateWords := [15897272204832747763, 11309953007401633108, 9308121576220038094, 14421880181001689210, 1035619753428010656, 5328331505368064188, 7303431608412067335, 3324893135966130710], absorbed := 0 }
  , cursorAfter := { stateWords := [5110911483760439, 54486054256896163, 1015276436, 4331901097435875928, 15789074150951337316, 3955182664772735096, 10769170991645251297, 17860899021887337642], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [5110911483760439, 54486054256896163, 1015276436, 4331901097435875928, 15789074150951337316, 3955182664772735096, 10769170991645251297, 17860899021887337642], absorbed := 3 }
  , cursorAfter := { stateWords := [13290325236237073002, 3167263823412265548, 2124303598359401438, 5095260702073669384, 8423156342386431665, 13073329068178322645, 7620674100935967401, 4396032368165522868], absorbed := 0 }
  , challengeOutput := (some 13290325236237073002)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [198, 81, 7, 250, 152, 135, 65, 159, 231, 42, 117, 161, 26, 121, 63, 197, 123, 212, 231, 113, 35, 37, 159, 177, 226, 104, 247, 68, 136, 30, 16, 163])
  , u64s := []
  , cursorBefore := { stateWords := [13290325236237073002, 3167263823412265548, 2124303598359401438, 5095260702073669384, 8423156342386431665, 13073329068178322645, 7620674100935967401, 4396032368165522868], absorbed := 0 }
  , cursorAfter := { stateWords := [9976864701138239, 19412328268275493, 2735742600, 6237024833566110327, 5431075642013008537, 6023572556956649998, 10521409209457402270, 12586429016929075820], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [14, 218, 199, 227, 116, 94, 179, 48, 175, 100, 127, 227, 52, 186, 29, 20, 52, 186, 208, 59, 240, 120, 150, 172, 197, 158, 248, 136, 149, 25, 87, 170])
  , u64s := []
  , cursorBefore := { stateWords := [9976864701138239, 19412328268275493, 2735742600, 6237024833566110327, 5431075642013008537, 6023572556956649998, 10521409209457402270, 12586429016929075820], absorbed := 3 }
  , cursorAfter := { stateWords := [67619762073768989, 38553957637592696, 2857834901, 8341731544263560157, 4902622506011080670, 8080200595999723931, 11855971435305081364, 10265924672884533183], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [233, 2, 26, 64, 110, 89, 182, 250, 115, 142, 225, 137, 122, 240, 120, 174, 71, 71, 199, 38, 167, 175, 50, 4, 209, 82, 12, 195, 102, 116, 18, 219])
  , u64s := []
  , cursorBefore := { stateWords := [67619762073768989, 38553957637592696, 2857834901, 8341731544263560157, 4902622506011080670, 8080200595999723931, 11855971435305081364, 10265924672884533183], absorbed := 3 }
  , cursorAfter := { stateWords := [47048958446907000, 54901170292142767, 3675419750, 4408886950467464954, 1614180035197973635, 13250356512350060064, 13140457597853917177, 6806082314764002763], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [47048958446907000, 54901170292142767, 3675419750, 4408886950467464954, 1614180035197973635, 13250356512350060064, 13140457597853917177, 6806082314764002763], absorbed := 3 }
  , cursorAfter := { stateWords := [18231637688184314104, 12136559809485361695, 7943305808637014790, 10473583606824433045, 16180276070919521922, 2320050769754099697, 10410472214867620863, 9488396987056937058], absorbed := 0 }
  , challengeOutput := (some 18231637688184314104)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [18231637688184314104, 12136559809485361695, 7943305808637014790, 10473583606824433045, 16180276070919521922, 2320050769754099697, 10410472214867620863, 9488396987056937058], absorbed := 0 }
  , cursorAfter := { stateWords := [6989028146962492314, 13458860150513018094, 2109944762695544449, 7379276838592249487, 1877861401095802368, 8262029584102291418, 4261609953813478959, 7639261189778842531], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [154, 235, 231, 248, 17, 4, 254, 96, 238, 36, 253, 176, 255, 121, 199, 186, 129, 238, 41, 44, 149, 7, 72, 29, 143, 254, 142, 7, 48, 117, 104, 102]))
}]
}
  , kernel := {
  root0Digest := (bytes [72, 152, 175, 61, 117, 151, 32, 177, 71, 104, 246, 95, 143, 151, 74, 89, 231, 218, 126, 100, 152, 157, 138, 113, 5, 107, 158, 151, 6, 22, 95, 167])
  , stage1Digest := (bytes [111, 27, 127, 199, 224, 106, 179, 224, 100, 158, 193, 168, 87, 52, 192, 102, 12, 142, 204, 107, 172, 208, 173, 109, 195, 250, 231, 36, 211, 96, 202, 41])
  , stage2Digest := (bytes [41, 249, 151, 99, 238, 144, 154, 142, 199, 178, 160, 62, 82, 25, 55, 207, 119, 207, 88, 40, 18, 163, 232, 49, 21, 199, 146, 193, 148, 227, 131, 60])
  , stage3Digest := (bytes [198, 81, 7, 250, 152, 135, 65, 159, 231, 42, 117, 161, 26, 121, 63, 197, 123, 212, 231, 113, 35, 37, 159, 177, 226, 104, 247, 68, 136, 30, 16, 163])
  , executionDigest := (bytes [14, 218, 199, 227, 116, 94, 179, 48, 175, 100, 127, 227, 52, 186, 29, 20, 52, 186, 208, 59, 240, 120, 150, 172, 197, 158, 248, 136, 149, 25, 87, 170])
  , finalStateDigest := (bytes [233, 2, 26, 64, 110, 89, 182, 250, 115, 142, 225, 137, 122, 240, 120, 174, 71, 71, 199, 38, 167, 175, 50, 4, 209, 82, 12, 195, 102, 116, 18, 219])
  , stage1Mix := 6088699767227576722
  , stage2RegMix := 13380091740178962810
  , stage2RamMix := 15897272204832747763
  , stage3ContinuityMix := 13290325236237073002
  , kernelFinalMix := 18231637688184314104
  , transcriptFinalDigest := (bytes [154, 235, 231, 248, 17, 4, 254, 96, 238, 36, 253, 176, 255, 121, 199, 186, 129, 238, 41, 44, 149, 7, 72, 29, 143, 254, 142, 7, 48, 117, 104, 102])
  , finalPc := 20
  , finalRegisters := [0, 1, 18446744073709551615, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , finalMemory := []
  , halted := true
}
}
    , kernelProof := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "control_flow_bge_taken_skip_ecall", fixtureId := "control_flow_bge_taken_skip_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.controlFlow, .nativeAlu] }
  , executionDigest := (bytes [14, 218, 199, 227, 116, 94, 179, 48, 175, 100, 127, 227, 52, 186, 29, 20, 52, 186, 208, 59, 240, 120, 150, 172, 197, 158, 248, 136, 149, 25, 87, 170])
  , shape := { executionRowCount := 4, realRowCount := 4, effectRowCount := 4, commitRowCount := 4, digest := (bytes [45, 178, 181, 197, 132, 60, 130, 1, 239, 208, 160, 249, 86, 246, 26, 179, 94, 235, 136, 250, 242, 5, 139, 0, 36, 216, 225, 255, 232, 86, 248, 123]) }
  , digest := (bytes [102, 60, 204, 185, 118, 57, 127, 238, 243, 56, 152, 26, 95, 233, 164, 141, 187, 138, 195, 58, 221, 0, 175, 104, 21, 214, 191, 9, 209, 3, 189, 125])
}
  , stages := { summary := { stage1RowCount := 4, stage2RegisterReadCount := 4, stage2RegisterWriteCount := 2, stage2RamEventCount := 0, stage2TwistLinkCount := 4, stage3ContinuityCount := 4, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [188, 146, 61, 220, 245, 51, 7, 161, 36, 1, 199, 100, 62, 187, 19, 182, 215, 124, 14, 176, 250, 206, 43, 76, 0, 125, 203, 144, 45, 193, 111, 34]) }, digest := (bytes [109, 34, 58, 13, 68, 111, 109, 31, 96, 208, 232, 119, 140, 198, 44, 192, 184, 71, 199, 65, 42, 115, 36, 133, 68, 13, 13, 169, 75, 7, 175, 245]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [17, 193, 15, 43, 182, 63, 169, 246, 9, 163, 37, 248, 60, 182, 213, 157, 45, 152, 237, 186, 229, 9, 96, 190, 168, 42, 83, 141, 22, 6, 78, 230]), stage1Digest := (bytes [21, 23, 85, 145, 218, 56, 77, 129, 216, 250, 230, 159, 152, 168, 182, 223, 139, 183, 178, 17, 176, 2, 25, 191, 173, 243, 52, 17, 192, 160, 246, 80]), stage2Digest := (bytes [120, 107, 32, 249, 1, 189, 111, 88, 233, 97, 74, 25, 73, 100, 31, 170, 93, 129, 84, 55, 231, 148, 119, 170, 101, 154, 228, 126, 78, 238, 101, 16]), stage3Digest := (bytes [241, 139, 61, 96, 28, 236, 184, 76, 31, 31, 90, 170, 231, 105, 75, 206, 127, 224, 133, 83, 235, 74, 203, 217, 94, 188, 29, 205, 255, 17, 30, 140]), transcriptDigest := (bytes [154, 235, 231, 248, 17, 4, 254, 96, 238, 36, 253, 176, 255, 121, 199, 186, 129, 238, 41, 44, 149, 7, 72, 29, 143, 254, 142, 7, 48, 117, 104, 102]), executionDigest := (bytes [14, 218, 199, 227, 116, 94, 179, 48, 175, 100, 127, 227, 52, 186, 29, 20, 52, 186, 208, 59, 240, 120, 150, 172, 197, 158, 248, 136, 149, 25, 87, 170]), digest := (bytes [154, 18, 55, 45, 137, 67, 43, 9, 188, 63, 170, 248, 114, 132, 200, 6, 147, 157, 15, 174, 32, 101, 93, 192, 227, 136, 201, 56, 50, 239, 176, 89]) }, statementDigest := (bytes [200, 247, 29, 252, 116, 210, 62, 41, 220, 155, 93, 226, 150, 185, 192, 237, 119, 122, 141, 26, 165, 0, 57, 101, 151, 198, 65, 19, 215, 163, 167, 240]), proofDigest := (bytes [240, 38, 170, 113, 66, 117, 37, 95, 214, 57, 93, 161, 82, 168, 88, 174, 187, 147, 247, 213, 113, 201, 190, 172, 250, 225, 124, 180, 92, 137, 144, 135]), digest := (bytes [128, 111, 75, 221, 200, 115, 111, 5, 211, 147, 200, 231, 167, 222, 101, 17, 248, 192, 153, 43, 190, 235, 239, 193, 206, 64, 176, 179, 137, 12, 216, 228]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [140, 94, 154, 70, 93, 22, 120, 56, 19, 77, 149, 236, 33, 93, 123, 74, 8, 13, 64, 45, 96, 211, 193, 86, 184, 131, 57, 113, 7, 160, 71, 58]), stage1Digest := (bytes [130, 129, 202, 81, 175, 224, 184, 214, 119, 142, 209, 228, 193, 5, 42, 7, 83, 216, 66, 148, 207, 221, 63, 154, 240, 91, 166, 85, 142, 164, 247, 126]), stage2Digest := (bytes [118, 16, 79, 238, 183, 157, 103, 240, 236, 215, 2, 44, 197, 195, 41, 138, 44, 171, 242, 251, 141, 116, 188, 248, 1, 7, 218, 45, 17, 69, 218, 252]), stage3Digest := (bytes [117, 32, 110, 162, 230, 226, 48, 10, 111, 101, 147, 148, 48, 207, 7, 68, 89, 76, 52, 59, 26, 160, 178, 97, 243, 194, 177, 222, 86, 8, 100, 204]), digest := (bytes [13, 205, 245, 114, 119, 16, 148, 21, 237, 69, 14, 75, 20, 157, 49, 220, 78, 236, 20, 140, 91, 116, 26, 14, 38, 178, 107, 54, 217, 99, 18, 145]) }, digest := (bytes [140, 177, 233, 3, 207, 149, 216, 170, 101, 134, 63, 206, 45, 165, 67, 215, 185, 22, 18, 74, 231, 142, 89, 9, 143, 128, 94, 28, 128, 234, 126, 137]) }
  , kernelOpening := { openingDigest := (bytes [10, 169, 156, 45, 147, 202, 6, 88, 155, 159, 166, 91, 178, 107, 90, 185, 17, 121, 45, 178, 80, 28, 248, 3, 171, 64, 217, 23, 70, 122, 185, 213]), bindings := { claimDigest := (bytes [77, 103, 2, 222, 234, 43, 49, 240, 209, 226, 227, 228, 78, 45, 41, 84, 188, 114, 33, 24, 238, 114, 121, 171, 235, 20, 5, 64, 2, 47, 141, 70]), bindingsDigest := (bytes [88, 7, 176, 215, 36, 174, 16, 232, 56, 49, 208, 136, 99, 190, 111, 56, 188, 234, 202, 72, 118, 224, 154, 33, 195, 68, 82, 11, 157, 134, 183, 83]), preparedStepsDigest := (bytes [9, 215, 28, 243, 185, 219, 54, 176, 76, 253, 248, 48, 195, 69, 255, 143, 199, 197, 230, 103, 76, 155, 65, 155, 76, 172, 221, 195, 119, 225, 113, 128]), digest := (bytes [129, 48, 16, 205, 95, 34, 47, 133, 159, 23, 172, 90, 108, 112, 2, 217, 172, 55, 179, 59, 84, 92, 140, 87, 155, 57, 255, 201, 196, 163, 171, 240]) }, digest := (bytes [81, 43, 28, 115, 145, 177, 204, 19, 224, 96, 52, 141, 2, 180, 244, 156, 194, 185, 27, 94, 29, 153, 147, 150, 141, 68, 19, 242, 105, 187, 85, 205]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [251, 44, 102, 51, 115, 137, 29, 19, 101, 96, 19, 177, 197, 174, 40, 175, 43, 192, 215, 236, 30, 246, 118, 195, 16, 94, 178, 189, 154, 138, 180, 39]), terminal := { root0Digest := (bytes [72, 152, 175, 61, 117, 151, 32, 177, 71, 104, 246, 95, 143, 151, 74, 89, 231, 218, 126, 100, 152, 157, 138, 113, 5, 107, 158, 151, 6, 22, 95, 167]), executionDigest := (bytes [14, 218, 199, 227, 116, 94, 179, 48, 175, 100, 127, 227, 52, 186, 29, 20, 52, 186, 208, 59, 240, 120, 150, 172, 197, 158, 248, 136, 149, 25, 87, 170]), finalStateDigest := (bytes [233, 2, 26, 64, 110, 89, 182, 250, 115, 142, 225, 137, 122, 240, 120, 174, 71, 71, 199, 38, 167, 175, 50, 4, 209, 82, 12, 195, 102, 116, 18, 219]), transcriptFinalDigest := (bytes [154, 235, 231, 248, 17, 4, 254, 96, 238, 36, 253, 176, 255, 121, 199, 186, 129, 238, 41, 44, 149, 7, 72, 29, 143, 254, 142, 7, 48, 117, 104, 102]), finalPc := 20, halted := true, digest := (bytes [146, 253, 92, 210, 65, 102, 70, 30, 209, 216, 105, 21, 150, 94, 125, 28, 32, 243, 53, 70, 158, 123, 122, 39, 125, 14, 164, 76, 121, 222, 43, 79]) }, digest := (bytes [92, 27, 194, 212, 73, 191, 193, 123, 77, 216, 5, 40, 118, 84, 88, 193, 92, 43, 125, 222, 234, 195, 153, 26, 151, 125, 159, 137, 254, 50, 5, 73]) }, statementDigest := (bytes [42, 101, 154, 85, 158, 161, 187, 254, 169, 170, 79, 216, 200, 213, 158, 169, 96, 62, 119, 120, 71, 142, 202, 15, 103, 177, 22, 123, 41, 105, 7, 41]), proofDigest := (bytes [42, 130, 54, 190, 34, 251, 78, 0, 20, 192, 149, 131, 102, 98, 114, 167, 203, 118, 188, 195, 191, 192, 250, 217, 166, 217, 187, 84, 132, 153, 16, 7]), digest := (bytes [164, 76, 177, 101, 164, 73, 39, 79, 196, 212, 168, 150, 99, 204, 112, 238, 222, 112, 18, 167, 234, 16, 16, 30, 55, 166, 47, 192, 154, 229, 26, 164]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [145, 185, 120, 4, 182, 105, 56, 218, 160, 76, 130, 184, 185, 23, 212, 85, 29, 144, 2, 172, 228, 214, 153, 212, 237, 73, 247, 209, 214, 142, 172, 26]), layoutVersion := 1, digest := (bytes [18, 231, 233, 115, 54, 59, 74, 124, 141, 216, 53, 117, 18, 195, 37, 72, 42, 155, 48, 36, 212, 118, 188, 110, 112, 122, 142, 164, 103, 22, 125, 227]) }, rowWidth := 38, timeLen := 4, columnDigests := [(bytes [212, 186, 229, 172, 74, 68, 211, 103, 24, 241, 21, 82, 209, 33, 189, 99, 223, 36, 129, 167, 9, 173, 76, 108, 178, 222, 90, 225, 89, 142, 8, 14]), (bytes [56, 58, 241, 13, 94, 161, 102, 38, 209, 85, 101, 10, 115, 74, 68, 15, 139, 16, 65, 164, 142, 61, 38, 80, 159, 19, 8, 220, 33, 174, 155, 155]), (bytes [29, 30, 250, 119, 67, 192, 190, 83, 169, 199, 126, 126, 209, 9, 207, 51, 13, 31, 240, 215, 38, 77, 233, 53, 71, 218, 94, 76, 41, 218, 33, 58]), (bytes [181, 122, 105, 181, 35, 180, 95, 214, 79, 41, 41, 2, 114, 48, 216, 55, 223, 211, 166, 64, 24, 33, 244, 234, 111, 10, 124, 63, 69, 70, 27, 116]), (bytes [235, 168, 211, 18, 219, 164, 123, 11, 1, 214, 235, 228, 142, 231, 19, 191, 111, 116, 112, 196, 167, 65, 6, 113, 150, 204, 141, 39, 111, 24, 165, 153]), (bytes [242, 28, 35, 169, 87, 104, 212, 237, 236, 149, 250, 219, 103, 80, 207, 126, 166, 205, 108, 128, 249, 85, 204, 223, 195, 102, 69, 23, 26, 53, 12, 57]), (bytes [91, 136, 102, 108, 254, 142, 77, 48, 97, 138, 138, 188, 220, 213, 55, 183, 133, 216, 230, 69, 191, 7, 253, 203, 112, 162, 85, 64, 74, 16, 34, 24]), (bytes [129, 132, 183, 42, 51, 67, 121, 100, 80, 40, 164, 136, 133, 105, 229, 130, 159, 202, 234, 223, 139, 249, 75, 123, 172, 38, 218, 88, 128, 30, 75, 38]), (bytes [126, 87, 159, 40, 116, 37, 52, 13, 86, 125, 244, 174, 142, 181, 192, 111, 194, 227, 82, 248, 236, 58, 229, 164, 28, 128, 106, 53, 58, 161, 20, 153]), (bytes [188, 182, 15, 241, 27, 114, 61, 238, 138, 213, 162, 50, 229, 51, 254, 0, 246, 2, 104, 201, 95, 72, 156, 200, 194, 39, 117, 213, 161, 47, 201, 214]), (bytes [205, 97, 99, 248, 17, 57, 155, 127, 10, 102, 114, 119, 106, 212, 70, 158, 53, 53, 223, 134, 113, 7, 137, 116, 70, 128, 72, 131, 100, 105, 126, 35]), (bytes [159, 179, 196, 167, 11, 132, 131, 110, 84, 172, 39, 73, 244, 241, 232, 32, 248, 129, 72, 151, 124, 121, 160, 127, 78, 225, 160, 13, 107, 159, 19, 251]), (bytes [228, 133, 33, 58, 61, 4, 79, 187, 176, 11, 11, 138, 102, 106, 51, 254, 251, 43, 4, 121, 130, 120, 223, 211, 164, 108, 183, 93, 47, 129, 51, 217]), (bytes [228, 193, 216, 182, 131, 150, 36, 125, 196, 115, 206, 157, 54, 8, 132, 236, 146, 38, 35, 6, 90, 57, 169, 190, 50, 184, 164, 10, 148, 113, 222, 157]), (bytes [87, 102, 108, 126, 93, 164, 233, 69, 211, 71, 36, 223, 61, 16, 50, 218, 90, 189, 162, 8, 230, 188, 91, 133, 74, 139, 163, 152, 147, 136, 55, 6]), (bytes [220, 193, 230, 244, 243, 14, 93, 42, 216, 108, 251, 253, 94, 191, 212, 189, 13, 211, 94, 236, 218, 138, 122, 7, 190, 222, 130, 249, 182, 150, 137, 189]), (bytes [223, 89, 191, 11, 110, 102, 31, 137, 129, 115, 137, 48, 64, 221, 208, 112, 235, 228, 24, 226, 254, 59, 16, 16, 192, 134, 30, 101, 212, 162, 156, 187]), (bytes [156, 22, 213, 157, 3, 147, 139, 132, 146, 22, 57, 209, 56, 31, 20, 20, 229, 105, 89, 38, 226, 230, 110, 49, 208, 70, 178, 10, 75, 21, 225, 62]), (bytes [89, 6, 118, 169, 105, 54, 5, 121, 26, 253, 91, 160, 13, 78, 211, 28, 177, 107, 187, 177, 10, 185, 35, 168, 191, 215, 99, 41, 155, 74, 182, 15]), (bytes [16, 1, 45, 207, 125, 115, 77, 40, 96, 249, 191, 96, 68, 155, 161, 144, 89, 205, 15, 173, 177, 139, 3, 87, 248, 132, 221, 254, 91, 235, 118, 133]), (bytes [2, 197, 213, 149, 21, 90, 236, 108, 141, 146, 26, 38, 0, 78, 135, 95, 223, 228, 221, 179, 125, 245, 167, 198, 49, 196, 48, 128, 192, 39, 124, 49]), (bytes [130, 134, 127, 131, 40, 47, 149, 206, 210, 112, 225, 17, 66, 25, 14, 78, 65, 235, 99, 73, 206, 90, 67, 148, 19, 78, 146, 25, 197, 149, 108, 61]), (bytes [8, 234, 67, 158, 76, 76, 170, 16, 58, 161, 138, 98, 35, 61, 115, 114, 104, 189, 45, 62, 96, 35, 11, 160, 56, 73, 223, 212, 106, 84, 224, 145]), (bytes [0, 189, 116, 3, 67, 124, 251, 249, 47, 128, 49, 73, 210, 47, 86, 252, 162, 78, 171, 9, 96, 183, 112, 195, 81, 120, 202, 223, 242, 24, 76, 51]), (bytes [81, 144, 1, 221, 155, 166, 187, 155, 181, 172, 254, 158, 176, 149, 110, 161, 164, 146, 156, 197, 231, 227, 176, 108, 72, 168, 128, 97, 162, 214, 166, 78]), (bytes [238, 147, 134, 181, 8, 29, 128, 200, 221, 198, 65, 181, 234, 22, 117, 159, 112, 0, 90, 214, 190, 69, 86, 72, 209, 196, 234, 23, 145, 109, 49, 190]), (bytes [150, 94, 21, 115, 92, 3, 250, 46, 250, 39, 23, 156, 66, 177, 198, 103, 242, 34, 109, 175, 253, 18, 181, 44, 23, 6, 9, 9, 119, 235, 11, 108]), (bytes [135, 215, 141, 47, 156, 11, 54, 54, 3, 72, 179, 247, 223, 155, 104, 7, 155, 222, 232, 159, 97, 172, 115, 97, 167, 121, 212, 57, 156, 44, 117, 203]), (bytes [84, 95, 115, 25, 213, 106, 24, 56, 216, 206, 94, 157, 100, 187, 198, 197, 93, 1, 173, 134, 90, 112, 47, 80, 254, 7, 54, 249, 32, 132, 243, 167]), (bytes [130, 198, 251, 47, 44, 43, 143, 92, 82, 195, 92, 157, 42, 215, 42, 26, 5, 251, 108, 34, 34, 0, 80, 113, 213, 113, 25, 247, 190, 124, 74, 52]), (bytes [234, 182, 234, 160, 23, 192, 246, 199, 173, 187, 203, 106, 254, 25, 134, 196, 2, 40, 181, 117, 170, 220, 56, 86, 63, 246, 0, 182, 78, 16, 61, 77]), (bytes [40, 254, 204, 213, 6, 140, 117, 235, 134, 79, 86, 81, 169, 63, 60, 118, 8, 156, 87, 198, 194, 60, 29, 160, 125, 250, 15, 187, 147, 220, 29, 92]), (bytes [18, 187, 180, 226, 104, 66, 42, 243, 22, 156, 53, 240, 151, 142, 203, 83, 91, 143, 153, 183, 211, 14, 178, 15, 249, 35, 88, 211, 226, 167, 221, 238]), (bytes [164, 40, 127, 229, 211, 147, 121, 221, 253, 56, 242, 238, 25, 160, 231, 5, 98, 88, 35, 198, 216, 51, 242, 34, 196, 132, 1, 62, 202, 49, 246, 41]), (bytes [122, 105, 77, 66, 174, 33, 37, 82, 171, 117, 60, 146, 152, 71, 176, 9, 4, 214, 95, 111, 117, 16, 77, 11, 22, 12, 202, 53, 36, 93, 76, 79]), (bytes [190, 26, 99, 184, 175, 199, 251, 124, 134, 183, 220, 35, 196, 195, 152, 135, 36, 169, 87, 198, 14, 22, 245, 143, 20, 239, 221, 18, 139, 77, 165, 236]), (bytes [80, 33, 41, 82, 68, 242, 18, 200, 209, 172, 125, 228, 155, 229, 192, 181, 222, 62, 254, 113, 197, 197, 209, 167, 162, 245, 86, 19, 189, 248, 96, 43]), (bytes [90, 10, 190, 250, 226, 23, 47, 210, 182, 164, 148, 175, 37, 226, 99, 192, 247, 166, 149, 66, 95, 29, 230, 232, 50, 99, 224, 203, 78, 177, 221, 250])], familyDigest := (bytes [145, 185, 120, 4, 182, 105, 56, 218, 160, 76, 130, 184, 185, 23, 212, 85, 29, 144, 2, 172, 228, 214, 153, 212, 237, 73, 247, 209, 214, 142, 172, 26]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [145, 185, 120, 4, 182, 105, 56, 218, 160, 76, 130, 184, 185, 23, 212, 85, 29, 144, 2, 172, 228, 214, 153, 212, 237, 73, 247, 209, 214, 142, 172, 26]), layoutVersion := 1, digest := (bytes [18, 231, 233, 115, 54, 59, 74, 124, 141, 216, 53, 117, 18, 195, 37, 72, 42, 155, 48, 36, 212, 118, 188, 110, 112, 122, 142, 164, 103, 22, 125, 227]) }, logicalIndex := 0, digest := (bytes [114, 0, 231, 125, 184, 11, 189, 86, 47, 104, 253, 243, 59, 242, 5, 175, 6, 250, 216, 110, 254, 254, 46, 197, 14, 254, 237, 152, 105, 219, 99, 18]) }, valueDigest := (bytes [48, 9, 158, 59, 120, 45, 200, 155, 8, 144, 252, 183, 179, 168, 71, 138, 10, 136, 117, 72, 217, 133, 28, 26, 240, 134, 159, 61, 227, 8, 46, 227]), digest := (bytes [152, 67, 38, 218, 150, 189, 234, 79, 74, 220, 26, 159, 229, 146, 78, 206, 161, 228, 73, 176, 58, 94, 234, 140, 120, 75, 143, 142, 72, 34, 92, 172]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [145, 185, 120, 4, 182, 105, 56, 218, 160, 76, 130, 184, 185, 23, 212, 85, 29, 144, 2, 172, 228, 214, 153, 212, 237, 73, 247, 209, 214, 142, 172, 26]), layoutVersion := 1, digest := (bytes [18, 231, 233, 115, 54, 59, 74, 124, 141, 216, 53, 117, 18, 195, 37, 72, 42, 155, 48, 36, 212, 118, 188, 110, 112, 122, 142, 164, 103, 22, 125, 227]) }, logicalIndex := 3, digest := (bytes [120, 98, 118, 137, 205, 199, 187, 39, 239, 102, 53, 233, 55, 0, 58, 90, 154, 127, 255, 27, 120, 128, 11, 18, 59, 142, 157, 230, 244, 116, 14, 230]) }, valueDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [107, 165, 108, 133, 174, 95, 91, 234, 119, 30, 16, 150, 40, 4, 144, 239, 133, 92, 98, 43, 246, 169, 173, 74, 237, 139, 90, 107, 126, 190, 59, 91]) }), digest := (bytes [98, 184, 1, 28, 8, 233, 14, 167, 138, 139, 164, 47, 11, 140, 225, 95, 226, 252, 123, 45, 143, 58, 3, 143, 189, 89, 52, 186, 168, 57, 35, 189]) }
  , rootLaneCommitment := { timeLen := 4, commitments := { commitmentCount := 38, digest := (bytes [78, 112, 96, 107, 186, 151, 14, 73, 226, 146, 137, 145, 183, 51, 53, 228, 122, 108, 60, 52, 98, 17, 23, 23, 93, 228, 209, 25, 87, 61, 135, 39]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [78, 112, 96, 107, 186, 151, 14, 73, 226, 146, 137, 145, 183, 51, 53, 228, 122, 108, 60, 52, 98, 17, 23, 23, 93, 228, 209, 25, 87, 61, 135, 39]), layoutVersion := 3, digest := (bytes [142, 215, 206, 200, 110, 197, 140, 8, 50, 119, 131, 108, 114, 183, 207, 142, 143, 138, 16, 193, 88, 249, 130, 60, 72, 218, 144, 7, 98, 5, 98, 51]) }, logicalIndex := 0, digest := (bytes [185, 118, 70, 229, 49, 2, 200, 218, 33, 247, 137, 217, 135, 84, 230, 197, 19, 47, 60, 48, 6, 242, 204, 224, 209, 163, 179, 39, 200, 72, 250, 106]) }, valueDigest := (bytes [48, 9, 158, 59, 120, 45, 200, 155, 8, 144, 252, 183, 179, 168, 71, 138, 10, 136, 117, 72, 217, 133, 28, 26, 240, 134, 159, 61, 227, 8, 46, 227]), digest := (bytes [140, 205, 179, 71, 211, 37, 11, 234, 8, 119, 236, 183, 30, 232, 232, 238, 74, 242, 245, 47, 6, 195, 73, 200, 189, 138, 206, 121, 159, 131, 204, 208]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [78, 112, 96, 107, 186, 151, 14, 73, 226, 146, 137, 145, 183, 51, 53, 228, 122, 108, 60, 52, 98, 17, 23, 23, 93, 228, 209, 25, 87, 61, 135, 39]), layoutVersion := 3, digest := (bytes [142, 215, 206, 200, 110, 197, 140, 8, 50, 119, 131, 108, 114, 183, 207, 142, 143, 138, 16, 193, 88, 249, 130, 60, 72, 218, 144, 7, 98, 5, 98, 51]) }, logicalIndex := 3, digest := (bytes [241, 74, 29, 162, 217, 212, 2, 197, 83, 67, 8, 50, 75, 64, 52, 223, 39, 121, 92, 14, 223, 108, 155, 146, 136, 31, 254, 16, 141, 172, 24, 246]) }, valueDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [197, 174, 83, 47, 237, 159, 237, 193, 255, 249, 235, 118, 39, 230, 112, 151, 155, 242, 18, 242, 69, 119, 21, 118, 245, 166, 248, 68, 177, 255, 7, 197]) }), digest := (bytes [102, 192, 243, 201, 108, 61, 3, 38, 64, 97, 138, 8, 92, 253, 154, 67, 113, 184, 198, 21, 111, 157, 113, 66, 67, 157, 65, 39, 71, 84, 32, 55]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [98, 184, 1, 28, 8, 233, 14, 167, 138, 139, 164, 47, 11, 140, 225, 95, 226, 252, 123, 45, 143, 58, 3, 143, 189, 89, 52, 186, 168, 57, 35, 189]), rootLaneCommitmentDigest := (bytes [102, 192, 243, 201, 108, 61, 3, 38, 64, 97, 138, 8, 92, 253, 154, 67, 113, 184, 198, 21, 111, 157, 113, 66, 67, 157, 65, 39, 71, 84, 32, 55]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 4, digest := (bytes [201, 15, 235, 187, 156, 81, 127, 240, 117, 241, 217, 193, 19, 245, 60, 149, 61, 230, 20, 186, 179, 27, 38, 148, 211, 194, 26, 35, 196, 99, 247, 74]) }, statementDigest := (bytes [237, 101, 30, 82, 184, 88, 85, 162, 193, 97, 218, 117, 225, 141, 189, 173, 215, 38, 253, 132, 254, 169, 92, 71, 141, 159, 55, 250, 65, 92, 27, 224]), proofDigest := (bytes [163, 55, 54, 51, 73, 32, 148, 151, 237, 58, 3, 182, 45, 114, 218, 232, 32, 94, 178, 234, 66, 148, 227, 45, 139, 72, 130, 73, 107, 136, 223, 71]), digest := (bytes [0, 29, 102, 54, 6, 148, 6, 86, 12, 1, 176, 2, 191, 135, 233, 121, 31, 139, 122, 177, 208, 181, 163, 188, 12, 166, 245, 147, 44, 19, 4, 102]) }
  , digest := (bytes [234, 150, 212, 123, 115, 169, 123, 27, 165, 211, 254, 65, 92, 38, 227, 180, 23, 12, 29, 179, 141, 184, 163, 101, 214, 225, 2, 194, 97, 249, 7, 1])
}
    , exportedProof := {
  claim := {
  accepted := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , statement := { proofStatementDigest := (bytes [12, 81, 226, 26, 119, 34, 160, 60, 20, 245, 28, 68, 89, 96, 117, 32, 188, 200, 83, 30, 201, 203, 40, 53, 242, 178, 92, 200, 116, 80, 175, 148]), kernelOpeningDigest := (bytes [81, 43, 28, 115, 145, 177, 204, 19, 224, 96, 52, 141, 2, 180, 244, 156, 194, 185, 27, 94, 29, 153, 147, 150, 141, 68, 19, 242, 105, 187, 85, 205]), digest := (bytes [13, 16, 63, 137, 41, 112, 184, 152, 63, 210, 55, 18, 53, 11, 51, 93, 81, 243, 36, 106, 73, 43, 115, 30, 97, 232, 207, 108, 162, 36, 222, 170]) }
  , mainLane := { mainLaneBundleDigest := (bytes [0, 29, 102, 54, 6, 148, 6, 86, 12, 1, 176, 2, 191, 135, 233, 121, 31, 139, 122, 177, 208, 181, 163, 188, 12, 166, 245, 147, 44, 19, 4, 102]), digest := (bytes [220, 102, 229, 113, 115, 120, 143, 0, 142, 162, 130, 177, 34, 124, 209, 200, 240, 215, 209, 221, 201, 205, 130, 108, 233, 156, 26, 199, 151, 19, 138, 157]) }
  , terminal := { finalStateDigest := (bytes [233, 2, 26, 64, 110, 89, 182, 250, 115, 142, 225, 137, 122, 240, 120, 174, 71, 71, 199, 38, 167, 175, 50, 4, 209, 82, 12, 195, 102, 116, 18, 219]), finalPc := 20, halted := true, digest := (bytes [88, 39, 62, 153, 53, 192, 87, 204, 224, 160, 28, 9, 7, 244, 179, 2, 22, 162, 186, 45, 168, 4, 19, 225, 119, 159, 178, 174, 198, 166, 24, 157]) }
  , digest := (bytes [51, 180, 223, 201, 175, 200, 216, 78, 226, 73, 9, 83, 16, 1, 157, 84, 103, 128, 134, 9, 113, 196, 18, 67, 2, 42, 72, 136, 53, 43, 211, 247])
}
  , mainLane := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { mainLaneBundleDigest := (bytes [0, 29, 102, 54, 6, 148, 6, 86, 12, 1, 176, 2, 191, 135, 233, 121, 31, 139, 122, 177, 208, 181, 163, 188, 12, 166, 245, 147, 44, 19, 4, 102]), digest := (bytes [34, 253, 56, 197, 149, 121, 245, 0, 181, 69, 242, 146, 42, 159, 207, 227, 157, 43, 6, 107, 139, 117, 86, 23, 17, 35, 175, 234, 242, 153, 144, 6]) }, digest := (bytes [123, 90, 171, 16, 91, 39, 242, 57, 186, 5, 184, 58, 133, 250, 143, 29, 115, 190, 5, 123, 191, 254, 20, 120, 72, 154, 34, 237, 170, 134, 163, 251]) }
  , opening := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , stages := { stageClaimsDigest := (bytes [128, 111, 75, 221, 200, 115, 111, 5, 211, 147, 200, 231, 167, 222, 101, 17, 248, 192, 153, 43, 190, 235, 239, 193, 206, 64, 176, 179, 137, 12, 216, 228]), stagePackagesDigest := (bytes [140, 177, 233, 3, 207, 149, 216, 170, 101, 134, 63, 206, 45, 165, 67, 215, 185, 22, 18, 74, 231, 142, 89, 9, 143, 128, 94, 28, 128, 234, 126, 137]), kernelOpeningDigest := (bytes [81, 43, 28, 115, 145, 177, 204, 19, 224, 96, 52, 141, 2, 180, 244, 156, 194, 185, 27, 94, 29, 153, 147, 150, 141, 68, 19, 242, 105, 187, 85, 205]), digest := (bytes [180, 250, 113, 57, 64, 215, 108, 218, 7, 137, 165, 53, 39, 58, 19, 163, 132, 252, 48, 165, 156, 217, 94, 152, 9, 181, 127, 18, 228, 188, 203, 152]) }
  , terminal := { preparedStepBindingsDigest := (bytes [251, 44, 102, 51, 115, 137, 29, 19, 101, 96, 19, 177, 197, 174, 40, 175, 43, 192, 215, 236, 30, 246, 118, 195, 16, 94, 178, 189, 154, 138, 180, 39]), executionDigest := (bytes [14, 218, 199, 227, 116, 94, 179, 48, 175, 100, 127, 227, 52, 186, 29, 20, 52, 186, 208, 59, 240, 120, 150, 172, 197, 158, 248, 136, 149, 25, 87, 170]), transcriptFinalDigest := (bytes [154, 235, 231, 248, 17, 4, 254, 96, 238, 36, 253, 176, 255, 121, 199, 186, 129, 238, 41, 44, 149, 7, 72, 29, 143, 254, 142, 7, 48, 117, 104, 102]), digest := (bytes [226, 166, 116, 61, 37, 235, 85, 228, 59, 96, 159, 78, 73, 128, 59, 72, 30, 190, 86, 67, 154, 177, 84, 37, 115, 172, 244, 131, 101, 83, 251, 16]) }
  , digest := (bytes [222, 241, 126, 208, 231, 65, 230, 193, 219, 33, 62, 194, 231, 57, 165, 146, 111, 79, 36, 137, 180, 253, 95, 194, 120, 220, 148, 116, 96, 55, 74, 30])
}
  , jointOpening := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { proofStatementDigest := (bytes [12, 81, 226, 26, 119, 34, 160, 60, 20, 245, 28, 68, 89, 96, 117, 32, 188, 200, 83, 30, 201, 203, 40, 53, 242, 178, 92, 200, 116, 80, 175, 148]), mainLaneClaimDigest := (bytes [123, 90, 171, 16, 91, 39, 242, 57, 186, 5, 184, 58, 133, 250, 143, 29, 115, 190, 5, 123, 191, 254, 20, 120, 72, 154, 34, 237, 170, 134, 163, 251]), kernelOpeningClaimDigest := (bytes [222, 241, 126, 208, 231, 65, 230, 193, 219, 33, 62, 194, 231, 57, 165, 146, 111, 79, 36, 137, 180, 253, 95, 194, 120, 220, 148, 116, 96, 55, 74, 30]), digest := (bytes [207, 250, 242, 20, 70, 117, 231, 193, 0, 48, 171, 125, 226, 235, 41, 84, 188, 156, 151, 88, 30, 112, 1, 34, 143, 179, 187, 73, 163, 129, 92, 141]) }, digest := (bytes [168, 228, 126, 185, 228, 18, 151, 98, 27, 81, 177, 7, 83, 89, 42, 153, 76, 0, 255, 61, 147, 230, 198, 31, 225, 67, 113, 166, 234, 206, 197, 254]) }
  , root0 := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), stages := { stage1Digest := (bytes [111, 27, 127, 199, 224, 106, 179, 224, 100, 158, 193, 168, 87, 52, 192, 102, 12, 142, 204, 107, 172, 208, 173, 109, 195, 250, 231, 36, 211, 96, 202, 41]), stage2Digest := (bytes [41, 249, 151, 99, 238, 144, 154, 142, 199, 178, 160, 62, 82, 25, 55, 207, 119, 207, 88, 40, 18, 163, 232, 49, 21, 199, 146, 193, 148, 227, 131, 60]), stage3Digest := (bytes [198, 81, 7, 250, 152, 135, 65, 159, 231, 42, 117, 161, 26, 121, 63, 197, 123, 212, 231, 113, 35, 37, 159, 177, 226, 104, 247, 68, 136, 30, 16, 163]), digest := (bytes [10, 109, 188, 112, 93, 235, 152, 180, 19, 117, 164, 96, 201, 225, 132, 31, 188, 195, 230, 111, 29, 212, 96, 246, 79, 160, 7, 125, 107, 247, 190, 29]) }, terminal := { root0Digest := (bytes [72, 152, 175, 61, 117, 151, 32, 177, 71, 104, 246, 95, 143, 151, 74, 89, 231, 218, 126, 100, 152, 157, 138, 113, 5, 107, 158, 151, 6, 22, 95, 167]), executionDigest := (bytes [14, 218, 199, 227, 116, 94, 179, 48, 175, 100, 127, 227, 52, 186, 29, 20, 52, 186, 208, 59, 240, 120, 150, 172, 197, 158, 248, 136, 149, 25, 87, 170]), finalStateDigest := (bytes [233, 2, 26, 64, 110, 89, 182, 250, 115, 142, 225, 137, 122, 240, 120, 174, 71, 71, 199, 38, 167, 175, 50, 4, 209, 82, 12, 195, 102, 116, 18, 219]), transcriptFinalDigest := (bytes [154, 235, 231, 248, 17, 4, 254, 96, 238, 36, 253, 176, 255, 121, 199, 186, 129, 238, 41, 44, 149, 7, 72, 29, 143, 254, 142, 7, 48, 117, 104, 102]), digest := (bytes [51, 224, 147, 61, 117, 14, 98, 101, 62, 42, 34, 139, 254, 163, 34, 104, 217, 103, 204, 182, 99, 54, 62, 140, 16, 35, 104, 171, 59, 210, 21, 207]) }, digest := (bytes [187, 159, 2, 165, 91, 25, 248, 127, 2, 38, 132, 113, 46, 5, 34, 163, 85, 112, 77, 98, 195, 202, 103, 210, 255, 75, 191, 178, 130, 191, 70, 54]) }
  , digest := (bytes [249, 51, 204, 3, 114, 21, 254, 224, 164, 121, 96, 189, 176, 99, 77, 206, 109, 82, 97, 8, 139, 17, 193, 125, 188, 76, 202, 95, 165, 67, 113, 175])
}
  , statement := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , foldSchedule := Nightstream.FoldSchedule.wholeTrace
  , chunkCount := 1
  , stageClaimsDigest := (bytes [128, 111, 75, 221, 200, 115, 111, 5, 211, 147, 200, 231, 167, 222, 101, 17, 248, 192, 153, 43, 190, 235, 239, 193, 206, 64, 176, 179, 137, 12, 216, 228])
  , stagePackagesDigest := (bytes [140, 177, 233, 3, 207, 149, 216, 170, 101, 134, 63, 206, 45, 165, 67, 215, 185, 22, 18, 74, 231, 142, 89, 9, 143, 128, 94, 28, 128, 234, 126, 137])
  , kernelOpeningDigest := (bytes [81, 43, 28, 115, 145, 177, 204, 19, 224, 96, 52, 141, 2, 180, 244, 156, 194, 185, 27, 94, 29, 153, 147, 150, 141, 68, 19, 242, 105, 187, 85, 205])
  , preparedStepBindingsDigest := (bytes [251, 44, 102, 51, 115, 137, 29, 19, 101, 96, 19, 177, 197, 174, 40, 175, 43, 192, 215, 236, 30, 246, 118, 195, 16, 94, 178, 189, 154, 138, 180, 39])
  , executionDigest := (bytes [14, 218, 199, 227, 116, 94, 179, 48, 175, 100, 127, 227, 52, 186, 29, 20, 52, 186, 208, 59, 240, 120, 150, 172, 197, 158, 248, 136, 149, 25, 87, 170])
  , finalStateDigest := (bytes [233, 2, 26, 64, 110, 89, 182, 250, 115, 142, 225, 137, 122, 240, 120, 174, 71, 71, 199, 38, 167, 175, 50, 4, 209, 82, 12, 195, 102, 116, 18, 219])
  , transcriptFinalDigest := (bytes [154, 235, 231, 248, 17, 4, 254, 96, 238, 36, 253, 176, 255, 121, 199, 186, 129, 238, 41, 44, 149, 7, 72, 29, 143, 254, 142, 7, 48, 117, 104, 102])
  , mainLaneSurfaceDigest := (bytes [237, 174, 7, 29, 156, 240, 253, 16, 112, 67, 174, 157, 37, 168, 211, 196, 187, 8, 238, 35, 221, 219, 220, 211, 209, 26, 46, 48, 167, 228, 138, 125])
  , rootLaneColumnsDigest := (bytes [98, 184, 1, 28, 8, 233, 14, 167, 138, 139, 164, 47, 11, 140, 225, 95, 226, 252, 123, 45, 143, 58, 3, 143, 189, 89, 52, 186, 168, 57, 35, 189])
  , publicStepCount := 4
  , initialPc := 0
  , finalPc := 20
  , halted := true
  , digest := (bytes [12, 81, 226, 26, 119, 34, 160, 60, 20, 245, 28, 68, 89, 96, 117, 32, 188, 200, 83, 30, 201, 203, 40, 53, 242, 178, 92, 200, 116, 80, 175, 148])
}
  , kernel := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "control_flow_bge_taken_skip_ecall", fixtureId := "control_flow_bge_taken_skip_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.controlFlow, .nativeAlu] }
  , executionDigest := (bytes [14, 218, 199, 227, 116, 94, 179, 48, 175, 100, 127, 227, 52, 186, 29, 20, 52, 186, 208, 59, 240, 120, 150, 172, 197, 158, 248, 136, 149, 25, 87, 170])
  , shape := { executionRowCount := 4, realRowCount := 4, effectRowCount := 4, commitRowCount := 4, digest := (bytes [45, 178, 181, 197, 132, 60, 130, 1, 239, 208, 160, 249, 86, 246, 26, 179, 94, 235, 136, 250, 242, 5, 139, 0, 36, 216, 225, 255, 232, 86, 248, 123]) }
  , digest := (bytes [102, 60, 204, 185, 118, 57, 127, 238, 243, 56, 152, 26, 95, 233, 164, 141, 187, 138, 195, 58, 221, 0, 175, 104, 21, 214, 191, 9, 209, 3, 189, 125])
}
  , stages := { summary := { stage1RowCount := 4, stage2RegisterReadCount := 4, stage2RegisterWriteCount := 2, stage2RamEventCount := 0, stage2TwistLinkCount := 4, stage3ContinuityCount := 4, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [188, 146, 61, 220, 245, 51, 7, 161, 36, 1, 199, 100, 62, 187, 19, 182, 215, 124, 14, 176, 250, 206, 43, 76, 0, 125, 203, 144, 45, 193, 111, 34]) }, digest := (bytes [109, 34, 58, 13, 68, 111, 109, 31, 96, 208, 232, 119, 140, 198, 44, 192, 184, 71, 199, 65, 42, 115, 36, 133, 68, 13, 13, 169, 75, 7, 175, 245]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [17, 193, 15, 43, 182, 63, 169, 246, 9, 163, 37, 248, 60, 182, 213, 157, 45, 152, 237, 186, 229, 9, 96, 190, 168, 42, 83, 141, 22, 6, 78, 230]), stage1Digest := (bytes [21, 23, 85, 145, 218, 56, 77, 129, 216, 250, 230, 159, 152, 168, 182, 223, 139, 183, 178, 17, 176, 2, 25, 191, 173, 243, 52, 17, 192, 160, 246, 80]), stage2Digest := (bytes [120, 107, 32, 249, 1, 189, 111, 88, 233, 97, 74, 25, 73, 100, 31, 170, 93, 129, 84, 55, 231, 148, 119, 170, 101, 154, 228, 126, 78, 238, 101, 16]), stage3Digest := (bytes [241, 139, 61, 96, 28, 236, 184, 76, 31, 31, 90, 170, 231, 105, 75, 206, 127, 224, 133, 83, 235, 74, 203, 217, 94, 188, 29, 205, 255, 17, 30, 140]), transcriptDigest := (bytes [154, 235, 231, 248, 17, 4, 254, 96, 238, 36, 253, 176, 255, 121, 199, 186, 129, 238, 41, 44, 149, 7, 72, 29, 143, 254, 142, 7, 48, 117, 104, 102]), executionDigest := (bytes [14, 218, 199, 227, 116, 94, 179, 48, 175, 100, 127, 227, 52, 186, 29, 20, 52, 186, 208, 59, 240, 120, 150, 172, 197, 158, 248, 136, 149, 25, 87, 170]), digest := (bytes [154, 18, 55, 45, 137, 67, 43, 9, 188, 63, 170, 248, 114, 132, 200, 6, 147, 157, 15, 174, 32, 101, 93, 192, 227, 136, 201, 56, 50, 239, 176, 89]) }, statementDigest := (bytes [200, 247, 29, 252, 116, 210, 62, 41, 220, 155, 93, 226, 150, 185, 192, 237, 119, 122, 141, 26, 165, 0, 57, 101, 151, 198, 65, 19, 215, 163, 167, 240]), proofDigest := (bytes [240, 38, 170, 113, 66, 117, 37, 95, 214, 57, 93, 161, 82, 168, 88, 174, 187, 147, 247, 213, 113, 201, 190, 172, 250, 225, 124, 180, 92, 137, 144, 135]), digest := (bytes [128, 111, 75, 221, 200, 115, 111, 5, 211, 147, 200, 231, 167, 222, 101, 17, 248, 192, 153, 43, 190, 235, 239, 193, 206, 64, 176, 179, 137, 12, 216, 228]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [140, 94, 154, 70, 93, 22, 120, 56, 19, 77, 149, 236, 33, 93, 123, 74, 8, 13, 64, 45, 96, 211, 193, 86, 184, 131, 57, 113, 7, 160, 71, 58]), stage1Digest := (bytes [130, 129, 202, 81, 175, 224, 184, 214, 119, 142, 209, 228, 193, 5, 42, 7, 83, 216, 66, 148, 207, 221, 63, 154, 240, 91, 166, 85, 142, 164, 247, 126]), stage2Digest := (bytes [118, 16, 79, 238, 183, 157, 103, 240, 236, 215, 2, 44, 197, 195, 41, 138, 44, 171, 242, 251, 141, 116, 188, 248, 1, 7, 218, 45, 17, 69, 218, 252]), stage3Digest := (bytes [117, 32, 110, 162, 230, 226, 48, 10, 111, 101, 147, 148, 48, 207, 7, 68, 89, 76, 52, 59, 26, 160, 178, 97, 243, 194, 177, 222, 86, 8, 100, 204]), digest := (bytes [13, 205, 245, 114, 119, 16, 148, 21, 237, 69, 14, 75, 20, 157, 49, 220, 78, 236, 20, 140, 91, 116, 26, 14, 38, 178, 107, 54, 217, 99, 18, 145]) }, digest := (bytes [140, 177, 233, 3, 207, 149, 216, 170, 101, 134, 63, 206, 45, 165, 67, 215, 185, 22, 18, 74, 231, 142, 89, 9, 143, 128, 94, 28, 128, 234, 126, 137]) }
  , kernelOpening := { openingDigest := (bytes [10, 169, 156, 45, 147, 202, 6, 88, 155, 159, 166, 91, 178, 107, 90, 185, 17, 121, 45, 178, 80, 28, 248, 3, 171, 64, 217, 23, 70, 122, 185, 213]), bindings := { claimDigest := (bytes [77, 103, 2, 222, 234, 43, 49, 240, 209, 226, 227, 228, 78, 45, 41, 84, 188, 114, 33, 24, 238, 114, 121, 171, 235, 20, 5, 64, 2, 47, 141, 70]), bindingsDigest := (bytes [88, 7, 176, 215, 36, 174, 16, 232, 56, 49, 208, 136, 99, 190, 111, 56, 188, 234, 202, 72, 118, 224, 154, 33, 195, 68, 82, 11, 157, 134, 183, 83]), preparedStepsDigest := (bytes [9, 215, 28, 243, 185, 219, 54, 176, 76, 253, 248, 48, 195, 69, 255, 143, 199, 197, 230, 103, 76, 155, 65, 155, 76, 172, 221, 195, 119, 225, 113, 128]), digest := (bytes [129, 48, 16, 205, 95, 34, 47, 133, 159, 23, 172, 90, 108, 112, 2, 217, 172, 55, 179, 59, 84, 92, 140, 87, 155, 57, 255, 201, 196, 163, 171, 240]) }, digest := (bytes [81, 43, 28, 115, 145, 177, 204, 19, 224, 96, 52, 141, 2, 180, 244, 156, 194, 185, 27, 94, 29, 153, 147, 150, 141, 68, 19, 242, 105, 187, 85, 205]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [251, 44, 102, 51, 115, 137, 29, 19, 101, 96, 19, 177, 197, 174, 40, 175, 43, 192, 215, 236, 30, 246, 118, 195, 16, 94, 178, 189, 154, 138, 180, 39]), terminal := { root0Digest := (bytes [72, 152, 175, 61, 117, 151, 32, 177, 71, 104, 246, 95, 143, 151, 74, 89, 231, 218, 126, 100, 152, 157, 138, 113, 5, 107, 158, 151, 6, 22, 95, 167]), executionDigest := (bytes [14, 218, 199, 227, 116, 94, 179, 48, 175, 100, 127, 227, 52, 186, 29, 20, 52, 186, 208, 59, 240, 120, 150, 172, 197, 158, 248, 136, 149, 25, 87, 170]), finalStateDigest := (bytes [233, 2, 26, 64, 110, 89, 182, 250, 115, 142, 225, 137, 122, 240, 120, 174, 71, 71, 199, 38, 167, 175, 50, 4, 209, 82, 12, 195, 102, 116, 18, 219]), transcriptFinalDigest := (bytes [154, 235, 231, 248, 17, 4, 254, 96, 238, 36, 253, 176, 255, 121, 199, 186, 129, 238, 41, 44, 149, 7, 72, 29, 143, 254, 142, 7, 48, 117, 104, 102]), finalPc := 20, halted := true, digest := (bytes [146, 253, 92, 210, 65, 102, 70, 30, 209, 216, 105, 21, 150, 94, 125, 28, 32, 243, 53, 70, 158, 123, 122, 39, 125, 14, 164, 76, 121, 222, 43, 79]) }, digest := (bytes [92, 27, 194, 212, 73, 191, 193, 123, 77, 216, 5, 40, 118, 84, 88, 193, 92, 43, 125, 222, 234, 195, 153, 26, 151, 125, 159, 137, 254, 50, 5, 73]) }, statementDigest := (bytes [42, 101, 154, 85, 158, 161, 187, 254, 169, 170, 79, 216, 200, 213, 158, 169, 96, 62, 119, 120, 71, 142, 202, 15, 103, 177, 22, 123, 41, 105, 7, 41]), proofDigest := (bytes [42, 130, 54, 190, 34, 251, 78, 0, 20, 192, 149, 131, 102, 98, 114, 167, 203, 118, 188, 195, 191, 192, 250, 217, 166, 217, 187, 84, 132, 153, 16, 7]), digest := (bytes [164, 76, 177, 101, 164, 73, 39, 79, 196, 212, 168, 150, 99, 204, 112, 238, 222, 112, 18, 167, 234, 16, 16, 30, 55, 166, 47, 192, 154, 229, 26, 164]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [145, 185, 120, 4, 182, 105, 56, 218, 160, 76, 130, 184, 185, 23, 212, 85, 29, 144, 2, 172, 228, 214, 153, 212, 237, 73, 247, 209, 214, 142, 172, 26]), layoutVersion := 1, digest := (bytes [18, 231, 233, 115, 54, 59, 74, 124, 141, 216, 53, 117, 18, 195, 37, 72, 42, 155, 48, 36, 212, 118, 188, 110, 112, 122, 142, 164, 103, 22, 125, 227]) }, rowWidth := 38, timeLen := 4, columnDigests := [(bytes [212, 186, 229, 172, 74, 68, 211, 103, 24, 241, 21, 82, 209, 33, 189, 99, 223, 36, 129, 167, 9, 173, 76, 108, 178, 222, 90, 225, 89, 142, 8, 14]), (bytes [56, 58, 241, 13, 94, 161, 102, 38, 209, 85, 101, 10, 115, 74, 68, 15, 139, 16, 65, 164, 142, 61, 38, 80, 159, 19, 8, 220, 33, 174, 155, 155]), (bytes [29, 30, 250, 119, 67, 192, 190, 83, 169, 199, 126, 126, 209, 9, 207, 51, 13, 31, 240, 215, 38, 77, 233, 53, 71, 218, 94, 76, 41, 218, 33, 58]), (bytes [181, 122, 105, 181, 35, 180, 95, 214, 79, 41, 41, 2, 114, 48, 216, 55, 223, 211, 166, 64, 24, 33, 244, 234, 111, 10, 124, 63, 69, 70, 27, 116]), (bytes [235, 168, 211, 18, 219, 164, 123, 11, 1, 214, 235, 228, 142, 231, 19, 191, 111, 116, 112, 196, 167, 65, 6, 113, 150, 204, 141, 39, 111, 24, 165, 153]), (bytes [242, 28, 35, 169, 87, 104, 212, 237, 236, 149, 250, 219, 103, 80, 207, 126, 166, 205, 108, 128, 249, 85, 204, 223, 195, 102, 69, 23, 26, 53, 12, 57]), (bytes [91, 136, 102, 108, 254, 142, 77, 48, 97, 138, 138, 188, 220, 213, 55, 183, 133, 216, 230, 69, 191, 7, 253, 203, 112, 162, 85, 64, 74, 16, 34, 24]), (bytes [129, 132, 183, 42, 51, 67, 121, 100, 80, 40, 164, 136, 133, 105, 229, 130, 159, 202, 234, 223, 139, 249, 75, 123, 172, 38, 218, 88, 128, 30, 75, 38]), (bytes [126, 87, 159, 40, 116, 37, 52, 13, 86, 125, 244, 174, 142, 181, 192, 111, 194, 227, 82, 248, 236, 58, 229, 164, 28, 128, 106, 53, 58, 161, 20, 153]), (bytes [188, 182, 15, 241, 27, 114, 61, 238, 138, 213, 162, 50, 229, 51, 254, 0, 246, 2, 104, 201, 95, 72, 156, 200, 194, 39, 117, 213, 161, 47, 201, 214]), (bytes [205, 97, 99, 248, 17, 57, 155, 127, 10, 102, 114, 119, 106, 212, 70, 158, 53, 53, 223, 134, 113, 7, 137, 116, 70, 128, 72, 131, 100, 105, 126, 35]), (bytes [159, 179, 196, 167, 11, 132, 131, 110, 84, 172, 39, 73, 244, 241, 232, 32, 248, 129, 72, 151, 124, 121, 160, 127, 78, 225, 160, 13, 107, 159, 19, 251]), (bytes [228, 133, 33, 58, 61, 4, 79, 187, 176, 11, 11, 138, 102, 106, 51, 254, 251, 43, 4, 121, 130, 120, 223, 211, 164, 108, 183, 93, 47, 129, 51, 217]), (bytes [228, 193, 216, 182, 131, 150, 36, 125, 196, 115, 206, 157, 54, 8, 132, 236, 146, 38, 35, 6, 90, 57, 169, 190, 50, 184, 164, 10, 148, 113, 222, 157]), (bytes [87, 102, 108, 126, 93, 164, 233, 69, 211, 71, 36, 223, 61, 16, 50, 218, 90, 189, 162, 8, 230, 188, 91, 133, 74, 139, 163, 152, 147, 136, 55, 6]), (bytes [220, 193, 230, 244, 243, 14, 93, 42, 216, 108, 251, 253, 94, 191, 212, 189, 13, 211, 94, 236, 218, 138, 122, 7, 190, 222, 130, 249, 182, 150, 137, 189]), (bytes [223, 89, 191, 11, 110, 102, 31, 137, 129, 115, 137, 48, 64, 221, 208, 112, 235, 228, 24, 226, 254, 59, 16, 16, 192, 134, 30, 101, 212, 162, 156, 187]), (bytes [156, 22, 213, 157, 3, 147, 139, 132, 146, 22, 57, 209, 56, 31, 20, 20, 229, 105, 89, 38, 226, 230, 110, 49, 208, 70, 178, 10, 75, 21, 225, 62]), (bytes [89, 6, 118, 169, 105, 54, 5, 121, 26, 253, 91, 160, 13, 78, 211, 28, 177, 107, 187, 177, 10, 185, 35, 168, 191, 215, 99, 41, 155, 74, 182, 15]), (bytes [16, 1, 45, 207, 125, 115, 77, 40, 96, 249, 191, 96, 68, 155, 161, 144, 89, 205, 15, 173, 177, 139, 3, 87, 248, 132, 221, 254, 91, 235, 118, 133]), (bytes [2, 197, 213, 149, 21, 90, 236, 108, 141, 146, 26, 38, 0, 78, 135, 95, 223, 228, 221, 179, 125, 245, 167, 198, 49, 196, 48, 128, 192, 39, 124, 49]), (bytes [130, 134, 127, 131, 40, 47, 149, 206, 210, 112, 225, 17, 66, 25, 14, 78, 65, 235, 99, 73, 206, 90, 67, 148, 19, 78, 146, 25, 197, 149, 108, 61]), (bytes [8, 234, 67, 158, 76, 76, 170, 16, 58, 161, 138, 98, 35, 61, 115, 114, 104, 189, 45, 62, 96, 35, 11, 160, 56, 73, 223, 212, 106, 84, 224, 145]), (bytes [0, 189, 116, 3, 67, 124, 251, 249, 47, 128, 49, 73, 210, 47, 86, 252, 162, 78, 171, 9, 96, 183, 112, 195, 81, 120, 202, 223, 242, 24, 76, 51]), (bytes [81, 144, 1, 221, 155, 166, 187, 155, 181, 172, 254, 158, 176, 149, 110, 161, 164, 146, 156, 197, 231, 227, 176, 108, 72, 168, 128, 97, 162, 214, 166, 78]), (bytes [238, 147, 134, 181, 8, 29, 128, 200, 221, 198, 65, 181, 234, 22, 117, 159, 112, 0, 90, 214, 190, 69, 86, 72, 209, 196, 234, 23, 145, 109, 49, 190]), (bytes [150, 94, 21, 115, 92, 3, 250, 46, 250, 39, 23, 156, 66, 177, 198, 103, 242, 34, 109, 175, 253, 18, 181, 44, 23, 6, 9, 9, 119, 235, 11, 108]), (bytes [135, 215, 141, 47, 156, 11, 54, 54, 3, 72, 179, 247, 223, 155, 104, 7, 155, 222, 232, 159, 97, 172, 115, 97, 167, 121, 212, 57, 156, 44, 117, 203]), (bytes [84, 95, 115, 25, 213, 106, 24, 56, 216, 206, 94, 157, 100, 187, 198, 197, 93, 1, 173, 134, 90, 112, 47, 80, 254, 7, 54, 249, 32, 132, 243, 167]), (bytes [130, 198, 251, 47, 44, 43, 143, 92, 82, 195, 92, 157, 42, 215, 42, 26, 5, 251, 108, 34, 34, 0, 80, 113, 213, 113, 25, 247, 190, 124, 74, 52]), (bytes [234, 182, 234, 160, 23, 192, 246, 199, 173, 187, 203, 106, 254, 25, 134, 196, 2, 40, 181, 117, 170, 220, 56, 86, 63, 246, 0, 182, 78, 16, 61, 77]), (bytes [40, 254, 204, 213, 6, 140, 117, 235, 134, 79, 86, 81, 169, 63, 60, 118, 8, 156, 87, 198, 194, 60, 29, 160, 125, 250, 15, 187, 147, 220, 29, 92]), (bytes [18, 187, 180, 226, 104, 66, 42, 243, 22, 156, 53, 240, 151, 142, 203, 83, 91, 143, 153, 183, 211, 14, 178, 15, 249, 35, 88, 211, 226, 167, 221, 238]), (bytes [164, 40, 127, 229, 211, 147, 121, 221, 253, 56, 242, 238, 25, 160, 231, 5, 98, 88, 35, 198, 216, 51, 242, 34, 196, 132, 1, 62, 202, 49, 246, 41]), (bytes [122, 105, 77, 66, 174, 33, 37, 82, 171, 117, 60, 146, 152, 71, 176, 9, 4, 214, 95, 111, 117, 16, 77, 11, 22, 12, 202, 53, 36, 93, 76, 79]), (bytes [190, 26, 99, 184, 175, 199, 251, 124, 134, 183, 220, 35, 196, 195, 152, 135, 36, 169, 87, 198, 14, 22, 245, 143, 20, 239, 221, 18, 139, 77, 165, 236]), (bytes [80, 33, 41, 82, 68, 242, 18, 200, 209, 172, 125, 228, 155, 229, 192, 181, 222, 62, 254, 113, 197, 197, 209, 167, 162, 245, 86, 19, 189, 248, 96, 43]), (bytes [90, 10, 190, 250, 226, 23, 47, 210, 182, 164, 148, 175, 37, 226, 99, 192, 247, 166, 149, 66, 95, 29, 230, 232, 50, 99, 224, 203, 78, 177, 221, 250])], familyDigest := (bytes [145, 185, 120, 4, 182, 105, 56, 218, 160, 76, 130, 184, 185, 23, 212, 85, 29, 144, 2, 172, 228, 214, 153, 212, 237, 73, 247, 209, 214, 142, 172, 26]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [145, 185, 120, 4, 182, 105, 56, 218, 160, 76, 130, 184, 185, 23, 212, 85, 29, 144, 2, 172, 228, 214, 153, 212, 237, 73, 247, 209, 214, 142, 172, 26]), layoutVersion := 1, digest := (bytes [18, 231, 233, 115, 54, 59, 74, 124, 141, 216, 53, 117, 18, 195, 37, 72, 42, 155, 48, 36, 212, 118, 188, 110, 112, 122, 142, 164, 103, 22, 125, 227]) }, logicalIndex := 0, digest := (bytes [114, 0, 231, 125, 184, 11, 189, 86, 47, 104, 253, 243, 59, 242, 5, 175, 6, 250, 216, 110, 254, 254, 46, 197, 14, 254, 237, 152, 105, 219, 99, 18]) }, valueDigest := (bytes [48, 9, 158, 59, 120, 45, 200, 155, 8, 144, 252, 183, 179, 168, 71, 138, 10, 136, 117, 72, 217, 133, 28, 26, 240, 134, 159, 61, 227, 8, 46, 227]), digest := (bytes [152, 67, 38, 218, 150, 189, 234, 79, 74, 220, 26, 159, 229, 146, 78, 206, 161, 228, 73, 176, 58, 94, 234, 140, 120, 75, 143, 142, 72, 34, 92, 172]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [145, 185, 120, 4, 182, 105, 56, 218, 160, 76, 130, 184, 185, 23, 212, 85, 29, 144, 2, 172, 228, 214, 153, 212, 237, 73, 247, 209, 214, 142, 172, 26]), layoutVersion := 1, digest := (bytes [18, 231, 233, 115, 54, 59, 74, 124, 141, 216, 53, 117, 18, 195, 37, 72, 42, 155, 48, 36, 212, 118, 188, 110, 112, 122, 142, 164, 103, 22, 125, 227]) }, logicalIndex := 3, digest := (bytes [120, 98, 118, 137, 205, 199, 187, 39, 239, 102, 53, 233, 55, 0, 58, 90, 154, 127, 255, 27, 120, 128, 11, 18, 59, 142, 157, 230, 244, 116, 14, 230]) }, valueDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [107, 165, 108, 133, 174, 95, 91, 234, 119, 30, 16, 150, 40, 4, 144, 239, 133, 92, 98, 43, 246, 169, 173, 74, 237, 139, 90, 107, 126, 190, 59, 91]) }), digest := (bytes [98, 184, 1, 28, 8, 233, 14, 167, 138, 139, 164, 47, 11, 140, 225, 95, 226, 252, 123, 45, 143, 58, 3, 143, 189, 89, 52, 186, 168, 57, 35, 189]) }
  , rootLaneCommitment := { timeLen := 4, commitments := { commitmentCount := 38, digest := (bytes [78, 112, 96, 107, 186, 151, 14, 73, 226, 146, 137, 145, 183, 51, 53, 228, 122, 108, 60, 52, 98, 17, 23, 23, 93, 228, 209, 25, 87, 61, 135, 39]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [78, 112, 96, 107, 186, 151, 14, 73, 226, 146, 137, 145, 183, 51, 53, 228, 122, 108, 60, 52, 98, 17, 23, 23, 93, 228, 209, 25, 87, 61, 135, 39]), layoutVersion := 3, digest := (bytes [142, 215, 206, 200, 110, 197, 140, 8, 50, 119, 131, 108, 114, 183, 207, 142, 143, 138, 16, 193, 88, 249, 130, 60, 72, 218, 144, 7, 98, 5, 98, 51]) }, logicalIndex := 0, digest := (bytes [185, 118, 70, 229, 49, 2, 200, 218, 33, 247, 137, 217, 135, 84, 230, 197, 19, 47, 60, 48, 6, 242, 204, 224, 209, 163, 179, 39, 200, 72, 250, 106]) }, valueDigest := (bytes [48, 9, 158, 59, 120, 45, 200, 155, 8, 144, 252, 183, 179, 168, 71, 138, 10, 136, 117, 72, 217, 133, 28, 26, 240, 134, 159, 61, 227, 8, 46, 227]), digest := (bytes [140, 205, 179, 71, 211, 37, 11, 234, 8, 119, 236, 183, 30, 232, 232, 238, 74, 242, 245, 47, 6, 195, 73, 200, 189, 138, 206, 121, 159, 131, 204, 208]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [78, 112, 96, 107, 186, 151, 14, 73, 226, 146, 137, 145, 183, 51, 53, 228, 122, 108, 60, 52, 98, 17, 23, 23, 93, 228, 209, 25, 87, 61, 135, 39]), layoutVersion := 3, digest := (bytes [142, 215, 206, 200, 110, 197, 140, 8, 50, 119, 131, 108, 114, 183, 207, 142, 143, 138, 16, 193, 88, 249, 130, 60, 72, 218, 144, 7, 98, 5, 98, 51]) }, logicalIndex := 3, digest := (bytes [241, 74, 29, 162, 217, 212, 2, 197, 83, 67, 8, 50, 75, 64, 52, 223, 39, 121, 92, 14, 223, 108, 155, 146, 136, 31, 254, 16, 141, 172, 24, 246]) }, valueDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [197, 174, 83, 47, 237, 159, 237, 193, 255, 249, 235, 118, 39, 230, 112, 151, 155, 242, 18, 242, 69, 119, 21, 118, 245, 166, 248, 68, 177, 255, 7, 197]) }), digest := (bytes [102, 192, 243, 201, 108, 61, 3, 38, 64, 97, 138, 8, 92, 253, 154, 67, 113, 184, 198, 21, 111, 157, 113, 66, 67, 157, 65, 39, 71, 84, 32, 55]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [98, 184, 1, 28, 8, 233, 14, 167, 138, 139, 164, 47, 11, 140, 225, 95, 226, 252, 123, 45, 143, 58, 3, 143, 189, 89, 52, 186, 168, 57, 35, 189]), rootLaneCommitmentDigest := (bytes [102, 192, 243, 201, 108, 61, 3, 38, 64, 97, 138, 8, 92, 253, 154, 67, 113, 184, 198, 21, 111, 157, 113, 66, 67, 157, 65, 39, 71, 84, 32, 55]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 4, digest := (bytes [201, 15, 235, 187, 156, 81, 127, 240, 117, 241, 217, 193, 19, 245, 60, 149, 61, 230, 20, 186, 179, 27, 38, 148, 211, 194, 26, 35, 196, 99, 247, 74]) }, statementDigest := (bytes [237, 101, 30, 82, 184, 88, 85, 162, 193, 97, 218, 117, 225, 141, 189, 173, 215, 38, 253, 132, 254, 169, 92, 71, 141, 159, 55, 250, 65, 92, 27, 224]), proofDigest := (bytes [163, 55, 54, 51, 73, 32, 148, 151, 237, 58, 3, 182, 45, 114, 218, 232, 32, 94, 178, 234, 66, 148, 227, 45, 139, 72, 130, 73, 107, 136, 223, 71]), digest := (bytes [0, 29, 102, 54, 6, 148, 6, 86, 12, 1, 176, 2, 191, 135, 233, 121, 31, 139, 122, 177, 208, 181, 163, 188, 12, 166, 245, 147, 44, 19, 4, 102]) }
  , digest := (bytes [234, 150, 212, 123, 115, 169, 123, 27, 165, 211, 254, 65, 92, 38, 227, 180, 23, 12, 29, 179, 141, 184, 163, 101, 214, 225, 2, 194, 97, 249, 7, 1])
}
}
    , exportedStatement := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , foldSchedule := Nightstream.FoldSchedule.wholeTrace
  , chunkCount := 1
  , stageClaimsDigest := (bytes [128, 111, 75, 221, 200, 115, 111, 5, 211, 147, 200, 231, 167, 222, 101, 17, 248, 192, 153, 43, 190, 235, 239, 193, 206, 64, 176, 179, 137, 12, 216, 228])
  , stagePackagesDigest := (bytes [140, 177, 233, 3, 207, 149, 216, 170, 101, 134, 63, 206, 45, 165, 67, 215, 185, 22, 18, 74, 231, 142, 89, 9, 143, 128, 94, 28, 128, 234, 126, 137])
  , kernelOpeningDigest := (bytes [81, 43, 28, 115, 145, 177, 204, 19, 224, 96, 52, 141, 2, 180, 244, 156, 194, 185, 27, 94, 29, 153, 147, 150, 141, 68, 19, 242, 105, 187, 85, 205])
  , preparedStepBindingsDigest := (bytes [251, 44, 102, 51, 115, 137, 29, 19, 101, 96, 19, 177, 197, 174, 40, 175, 43, 192, 215, 236, 30, 246, 118, 195, 16, 94, 178, 189, 154, 138, 180, 39])
  , executionDigest := (bytes [14, 218, 199, 227, 116, 94, 179, 48, 175, 100, 127, 227, 52, 186, 29, 20, 52, 186, 208, 59, 240, 120, 150, 172, 197, 158, 248, 136, 149, 25, 87, 170])
  , finalStateDigest := (bytes [233, 2, 26, 64, 110, 89, 182, 250, 115, 142, 225, 137, 122, 240, 120, 174, 71, 71, 199, 38, 167, 175, 50, 4, 209, 82, 12, 195, 102, 116, 18, 219])
  , transcriptFinalDigest := (bytes [154, 235, 231, 248, 17, 4, 254, 96, 238, 36, 253, 176, 255, 121, 199, 186, 129, 238, 41, 44, 149, 7, 72, 29, 143, 254, 142, 7, 48, 117, 104, 102])
  , mainLaneSurfaceDigest := (bytes [237, 174, 7, 29, 156, 240, 253, 16, 112, 67, 174, 157, 37, 168, 211, 196, 187, 8, 238, 35, 221, 219, 220, 211, 209, 26, 46, 48, 167, 228, 138, 125])
  , rootLaneColumnsDigest := (bytes [98, 184, 1, 28, 8, 233, 14, 167, 138, 139, 164, 47, 11, 140, 225, 95, 226, 252, 123, 45, 143, 58, 3, 143, 189, 89, 52, 186, 168, 57, 35, 189])
  , publicStepCount := 4
  , initialPc := 0
  , finalPc := 20
  , halted := true
  , digest := (bytes [12, 81, 226, 26, 119, 34, 160, 60, 20, 245, 28, 68, 89, 96, 117, 32, 188, 200, 83, 30, 201, 203, 40, 53, 242, 178, 92, 200, 116, 80, 175, 148])
}
    , exportedClaims := {
  accepted := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , statement := { proofStatementDigest := (bytes [12, 81, 226, 26, 119, 34, 160, 60, 20, 245, 28, 68, 89, 96, 117, 32, 188, 200, 83, 30, 201, 203, 40, 53, 242, 178, 92, 200, 116, 80, 175, 148]), kernelOpeningDigest := (bytes [81, 43, 28, 115, 145, 177, 204, 19, 224, 96, 52, 141, 2, 180, 244, 156, 194, 185, 27, 94, 29, 153, 147, 150, 141, 68, 19, 242, 105, 187, 85, 205]), digest := (bytes [13, 16, 63, 137, 41, 112, 184, 152, 63, 210, 55, 18, 53, 11, 51, 93, 81, 243, 36, 106, 73, 43, 115, 30, 97, 232, 207, 108, 162, 36, 222, 170]) }
  , mainLane := { mainLaneBundleDigest := (bytes [0, 29, 102, 54, 6, 148, 6, 86, 12, 1, 176, 2, 191, 135, 233, 121, 31, 139, 122, 177, 208, 181, 163, 188, 12, 166, 245, 147, 44, 19, 4, 102]), digest := (bytes [220, 102, 229, 113, 115, 120, 143, 0, 142, 162, 130, 177, 34, 124, 209, 200, 240, 215, 209, 221, 201, 205, 130, 108, 233, 156, 26, 199, 151, 19, 138, 157]) }
  , terminal := { finalStateDigest := (bytes [233, 2, 26, 64, 110, 89, 182, 250, 115, 142, 225, 137, 122, 240, 120, 174, 71, 71, 199, 38, 167, 175, 50, 4, 209, 82, 12, 195, 102, 116, 18, 219]), finalPc := 20, halted := true, digest := (bytes [88, 39, 62, 153, 53, 192, 87, 204, 224, 160, 28, 9, 7, 244, 179, 2, 22, 162, 186, 45, 168, 4, 19, 225, 119, 159, 178, 174, 198, 166, 24, 157]) }
  , digest := (bytes [51, 180, 223, 201, 175, 200, 216, 78, 226, 73, 9, 83, 16, 1, 157, 84, 103, 128, 134, 9, 113, 196, 18, 67, 2, 42, 72, 136, 53, 43, 211, 247])
}
  , mainLane := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { mainLaneBundleDigest := (bytes [0, 29, 102, 54, 6, 148, 6, 86, 12, 1, 176, 2, 191, 135, 233, 121, 31, 139, 122, 177, 208, 181, 163, 188, 12, 166, 245, 147, 44, 19, 4, 102]), digest := (bytes [34, 253, 56, 197, 149, 121, 245, 0, 181, 69, 242, 146, 42, 159, 207, 227, 157, 43, 6, 107, 139, 117, 86, 23, 17, 35, 175, 234, 242, 153, 144, 6]) }, digest := (bytes [123, 90, 171, 16, 91, 39, 242, 57, 186, 5, 184, 58, 133, 250, 143, 29, 115, 190, 5, 123, 191, 254, 20, 120, 72, 154, 34, 237, 170, 134, 163, 251]) }
  , opening := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , stages := { stageClaimsDigest := (bytes [128, 111, 75, 221, 200, 115, 111, 5, 211, 147, 200, 231, 167, 222, 101, 17, 248, 192, 153, 43, 190, 235, 239, 193, 206, 64, 176, 179, 137, 12, 216, 228]), stagePackagesDigest := (bytes [140, 177, 233, 3, 207, 149, 216, 170, 101, 134, 63, 206, 45, 165, 67, 215, 185, 22, 18, 74, 231, 142, 89, 9, 143, 128, 94, 28, 128, 234, 126, 137]), kernelOpeningDigest := (bytes [81, 43, 28, 115, 145, 177, 204, 19, 224, 96, 52, 141, 2, 180, 244, 156, 194, 185, 27, 94, 29, 153, 147, 150, 141, 68, 19, 242, 105, 187, 85, 205]), digest := (bytes [180, 250, 113, 57, 64, 215, 108, 218, 7, 137, 165, 53, 39, 58, 19, 163, 132, 252, 48, 165, 156, 217, 94, 152, 9, 181, 127, 18, 228, 188, 203, 152]) }
  , terminal := { preparedStepBindingsDigest := (bytes [251, 44, 102, 51, 115, 137, 29, 19, 101, 96, 19, 177, 197, 174, 40, 175, 43, 192, 215, 236, 30, 246, 118, 195, 16, 94, 178, 189, 154, 138, 180, 39]), executionDigest := (bytes [14, 218, 199, 227, 116, 94, 179, 48, 175, 100, 127, 227, 52, 186, 29, 20, 52, 186, 208, 59, 240, 120, 150, 172, 197, 158, 248, 136, 149, 25, 87, 170]), transcriptFinalDigest := (bytes [154, 235, 231, 248, 17, 4, 254, 96, 238, 36, 253, 176, 255, 121, 199, 186, 129, 238, 41, 44, 149, 7, 72, 29, 143, 254, 142, 7, 48, 117, 104, 102]), digest := (bytes [226, 166, 116, 61, 37, 235, 85, 228, 59, 96, 159, 78, 73, 128, 59, 72, 30, 190, 86, 67, 154, 177, 84, 37, 115, 172, 244, 131, 101, 83, 251, 16]) }
  , digest := (bytes [222, 241, 126, 208, 231, 65, 230, 193, 219, 33, 62, 194, 231, 57, 165, 146, 111, 79, 36, 137, 180, 253, 95, 194, 120, 220, 148, 116, 96, 55, 74, 30])
}
  , jointOpening := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { proofStatementDigest := (bytes [12, 81, 226, 26, 119, 34, 160, 60, 20, 245, 28, 68, 89, 96, 117, 32, 188, 200, 83, 30, 201, 203, 40, 53, 242, 178, 92, 200, 116, 80, 175, 148]), mainLaneClaimDigest := (bytes [123, 90, 171, 16, 91, 39, 242, 57, 186, 5, 184, 58, 133, 250, 143, 29, 115, 190, 5, 123, 191, 254, 20, 120, 72, 154, 34, 237, 170, 134, 163, 251]), kernelOpeningClaimDigest := (bytes [222, 241, 126, 208, 231, 65, 230, 193, 219, 33, 62, 194, 231, 57, 165, 146, 111, 79, 36, 137, 180, 253, 95, 194, 120, 220, 148, 116, 96, 55, 74, 30]), digest := (bytes [207, 250, 242, 20, 70, 117, 231, 193, 0, 48, 171, 125, 226, 235, 41, 84, 188, 156, 151, 88, 30, 112, 1, 34, 143, 179, 187, 73, 163, 129, 92, 141]) }, digest := (bytes [168, 228, 126, 185, 228, 18, 151, 98, 27, 81, 177, 7, 83, 89, 42, 153, 76, 0, 255, 61, 147, 230, 198, 31, 225, 67, 113, 166, 234, 206, 197, 254]) }
  , root0 := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), stages := { stage1Digest := (bytes [111, 27, 127, 199, 224, 106, 179, 224, 100, 158, 193, 168, 87, 52, 192, 102, 12, 142, 204, 107, 172, 208, 173, 109, 195, 250, 231, 36, 211, 96, 202, 41]), stage2Digest := (bytes [41, 249, 151, 99, 238, 144, 154, 142, 199, 178, 160, 62, 82, 25, 55, 207, 119, 207, 88, 40, 18, 163, 232, 49, 21, 199, 146, 193, 148, 227, 131, 60]), stage3Digest := (bytes [198, 81, 7, 250, 152, 135, 65, 159, 231, 42, 117, 161, 26, 121, 63, 197, 123, 212, 231, 113, 35, 37, 159, 177, 226, 104, 247, 68, 136, 30, 16, 163]), digest := (bytes [10, 109, 188, 112, 93, 235, 152, 180, 19, 117, 164, 96, 201, 225, 132, 31, 188, 195, 230, 111, 29, 212, 96, 246, 79, 160, 7, 125, 107, 247, 190, 29]) }, terminal := { root0Digest := (bytes [72, 152, 175, 61, 117, 151, 32, 177, 71, 104, 246, 95, 143, 151, 74, 89, 231, 218, 126, 100, 152, 157, 138, 113, 5, 107, 158, 151, 6, 22, 95, 167]), executionDigest := (bytes [14, 218, 199, 227, 116, 94, 179, 48, 175, 100, 127, 227, 52, 186, 29, 20, 52, 186, 208, 59, 240, 120, 150, 172, 197, 158, 248, 136, 149, 25, 87, 170]), finalStateDigest := (bytes [233, 2, 26, 64, 110, 89, 182, 250, 115, 142, 225, 137, 122, 240, 120, 174, 71, 71, 199, 38, 167, 175, 50, 4, 209, 82, 12, 195, 102, 116, 18, 219]), transcriptFinalDigest := (bytes [154, 235, 231, 248, 17, 4, 254, 96, 238, 36, 253, 176, 255, 121, 199, 186, 129, 238, 41, 44, 149, 7, 72, 29, 143, 254, 142, 7, 48, 117, 104, 102]), digest := (bytes [51, 224, 147, 61, 117, 14, 98, 101, 62, 42, 34, 139, 254, 163, 34, 104, 217, 103, 204, 182, 99, 54, 62, 140, 16, 35, 104, 171, 59, 210, 21, 207]) }, digest := (bytes [187, 159, 2, 165, 91, 25, 248, 127, 2, 38, 132, 113, 46, 5, 34, 163, 85, 112, 77, 98, 195, 202, 103, 210, 255, 75, 191, 178, 130, 191, 70, 54]) }
  , digest := (bytes [249, 51, 204, 3, 114, 21, 254, 224, 164, 121, 96, 189, 176, 99, 77, 206, 109, 82, 97, 8, 139, 17, 193, 125, 188, 76, 202, 95, 165, 67, 113, 175])
}
    , exportedKernelProof := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "control_flow_bge_taken_skip_ecall", fixtureId := "control_flow_bge_taken_skip_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.controlFlow, .nativeAlu] }
  , executionDigest := (bytes [14, 218, 199, 227, 116, 94, 179, 48, 175, 100, 127, 227, 52, 186, 29, 20, 52, 186, 208, 59, 240, 120, 150, 172, 197, 158, 248, 136, 149, 25, 87, 170])
  , shape := { executionRowCount := 4, realRowCount := 4, effectRowCount := 4, commitRowCount := 4, digest := (bytes [45, 178, 181, 197, 132, 60, 130, 1, 239, 208, 160, 249, 86, 246, 26, 179, 94, 235, 136, 250, 242, 5, 139, 0, 36, 216, 225, 255, 232, 86, 248, 123]) }
  , digest := (bytes [102, 60, 204, 185, 118, 57, 127, 238, 243, 56, 152, 26, 95, 233, 164, 141, 187, 138, 195, 58, 221, 0, 175, 104, 21, 214, 191, 9, 209, 3, 189, 125])
}
  , stages := { summary := { stage1RowCount := 4, stage2RegisterReadCount := 4, stage2RegisterWriteCount := 2, stage2RamEventCount := 0, stage2TwistLinkCount := 4, stage3ContinuityCount := 4, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [188, 146, 61, 220, 245, 51, 7, 161, 36, 1, 199, 100, 62, 187, 19, 182, 215, 124, 14, 176, 250, 206, 43, 76, 0, 125, 203, 144, 45, 193, 111, 34]) }, digest := (bytes [109, 34, 58, 13, 68, 111, 109, 31, 96, 208, 232, 119, 140, 198, 44, 192, 184, 71, 199, 65, 42, 115, 36, 133, 68, 13, 13, 169, 75, 7, 175, 245]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [17, 193, 15, 43, 182, 63, 169, 246, 9, 163, 37, 248, 60, 182, 213, 157, 45, 152, 237, 186, 229, 9, 96, 190, 168, 42, 83, 141, 22, 6, 78, 230]), stage1Digest := (bytes [21, 23, 85, 145, 218, 56, 77, 129, 216, 250, 230, 159, 152, 168, 182, 223, 139, 183, 178, 17, 176, 2, 25, 191, 173, 243, 52, 17, 192, 160, 246, 80]), stage2Digest := (bytes [120, 107, 32, 249, 1, 189, 111, 88, 233, 97, 74, 25, 73, 100, 31, 170, 93, 129, 84, 55, 231, 148, 119, 170, 101, 154, 228, 126, 78, 238, 101, 16]), stage3Digest := (bytes [241, 139, 61, 96, 28, 236, 184, 76, 31, 31, 90, 170, 231, 105, 75, 206, 127, 224, 133, 83, 235, 74, 203, 217, 94, 188, 29, 205, 255, 17, 30, 140]), transcriptDigest := (bytes [154, 235, 231, 248, 17, 4, 254, 96, 238, 36, 253, 176, 255, 121, 199, 186, 129, 238, 41, 44, 149, 7, 72, 29, 143, 254, 142, 7, 48, 117, 104, 102]), executionDigest := (bytes [14, 218, 199, 227, 116, 94, 179, 48, 175, 100, 127, 227, 52, 186, 29, 20, 52, 186, 208, 59, 240, 120, 150, 172, 197, 158, 248, 136, 149, 25, 87, 170]), digest := (bytes [154, 18, 55, 45, 137, 67, 43, 9, 188, 63, 170, 248, 114, 132, 200, 6, 147, 157, 15, 174, 32, 101, 93, 192, 227, 136, 201, 56, 50, 239, 176, 89]) }, statementDigest := (bytes [200, 247, 29, 252, 116, 210, 62, 41, 220, 155, 93, 226, 150, 185, 192, 237, 119, 122, 141, 26, 165, 0, 57, 101, 151, 198, 65, 19, 215, 163, 167, 240]), proofDigest := (bytes [240, 38, 170, 113, 66, 117, 37, 95, 214, 57, 93, 161, 82, 168, 88, 174, 187, 147, 247, 213, 113, 201, 190, 172, 250, 225, 124, 180, 92, 137, 144, 135]), digest := (bytes [128, 111, 75, 221, 200, 115, 111, 5, 211, 147, 200, 231, 167, 222, 101, 17, 248, 192, 153, 43, 190, 235, 239, 193, 206, 64, 176, 179, 137, 12, 216, 228]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [140, 94, 154, 70, 93, 22, 120, 56, 19, 77, 149, 236, 33, 93, 123, 74, 8, 13, 64, 45, 96, 211, 193, 86, 184, 131, 57, 113, 7, 160, 71, 58]), stage1Digest := (bytes [130, 129, 202, 81, 175, 224, 184, 214, 119, 142, 209, 228, 193, 5, 42, 7, 83, 216, 66, 148, 207, 221, 63, 154, 240, 91, 166, 85, 142, 164, 247, 126]), stage2Digest := (bytes [118, 16, 79, 238, 183, 157, 103, 240, 236, 215, 2, 44, 197, 195, 41, 138, 44, 171, 242, 251, 141, 116, 188, 248, 1, 7, 218, 45, 17, 69, 218, 252]), stage3Digest := (bytes [117, 32, 110, 162, 230, 226, 48, 10, 111, 101, 147, 148, 48, 207, 7, 68, 89, 76, 52, 59, 26, 160, 178, 97, 243, 194, 177, 222, 86, 8, 100, 204]), digest := (bytes [13, 205, 245, 114, 119, 16, 148, 21, 237, 69, 14, 75, 20, 157, 49, 220, 78, 236, 20, 140, 91, 116, 26, 14, 38, 178, 107, 54, 217, 99, 18, 145]) }, digest := (bytes [140, 177, 233, 3, 207, 149, 216, 170, 101, 134, 63, 206, 45, 165, 67, 215, 185, 22, 18, 74, 231, 142, 89, 9, 143, 128, 94, 28, 128, 234, 126, 137]) }
  , kernelOpening := { openingDigest := (bytes [10, 169, 156, 45, 147, 202, 6, 88, 155, 159, 166, 91, 178, 107, 90, 185, 17, 121, 45, 178, 80, 28, 248, 3, 171, 64, 217, 23, 70, 122, 185, 213]), bindings := { claimDigest := (bytes [77, 103, 2, 222, 234, 43, 49, 240, 209, 226, 227, 228, 78, 45, 41, 84, 188, 114, 33, 24, 238, 114, 121, 171, 235, 20, 5, 64, 2, 47, 141, 70]), bindingsDigest := (bytes [88, 7, 176, 215, 36, 174, 16, 232, 56, 49, 208, 136, 99, 190, 111, 56, 188, 234, 202, 72, 118, 224, 154, 33, 195, 68, 82, 11, 157, 134, 183, 83]), preparedStepsDigest := (bytes [9, 215, 28, 243, 185, 219, 54, 176, 76, 253, 248, 48, 195, 69, 255, 143, 199, 197, 230, 103, 76, 155, 65, 155, 76, 172, 221, 195, 119, 225, 113, 128]), digest := (bytes [129, 48, 16, 205, 95, 34, 47, 133, 159, 23, 172, 90, 108, 112, 2, 217, 172, 55, 179, 59, 84, 92, 140, 87, 155, 57, 255, 201, 196, 163, 171, 240]) }, digest := (bytes [81, 43, 28, 115, 145, 177, 204, 19, 224, 96, 52, 141, 2, 180, 244, 156, 194, 185, 27, 94, 29, 153, 147, 150, 141, 68, 19, 242, 105, 187, 85, 205]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [251, 44, 102, 51, 115, 137, 29, 19, 101, 96, 19, 177, 197, 174, 40, 175, 43, 192, 215, 236, 30, 246, 118, 195, 16, 94, 178, 189, 154, 138, 180, 39]), terminal := { root0Digest := (bytes [72, 152, 175, 61, 117, 151, 32, 177, 71, 104, 246, 95, 143, 151, 74, 89, 231, 218, 126, 100, 152, 157, 138, 113, 5, 107, 158, 151, 6, 22, 95, 167]), executionDigest := (bytes [14, 218, 199, 227, 116, 94, 179, 48, 175, 100, 127, 227, 52, 186, 29, 20, 52, 186, 208, 59, 240, 120, 150, 172, 197, 158, 248, 136, 149, 25, 87, 170]), finalStateDigest := (bytes [233, 2, 26, 64, 110, 89, 182, 250, 115, 142, 225, 137, 122, 240, 120, 174, 71, 71, 199, 38, 167, 175, 50, 4, 209, 82, 12, 195, 102, 116, 18, 219]), transcriptFinalDigest := (bytes [154, 235, 231, 248, 17, 4, 254, 96, 238, 36, 253, 176, 255, 121, 199, 186, 129, 238, 41, 44, 149, 7, 72, 29, 143, 254, 142, 7, 48, 117, 104, 102]), finalPc := 20, halted := true, digest := (bytes [146, 253, 92, 210, 65, 102, 70, 30, 209, 216, 105, 21, 150, 94, 125, 28, 32, 243, 53, 70, 158, 123, 122, 39, 125, 14, 164, 76, 121, 222, 43, 79]) }, digest := (bytes [92, 27, 194, 212, 73, 191, 193, 123, 77, 216, 5, 40, 118, 84, 88, 193, 92, 43, 125, 222, 234, 195, 153, 26, 151, 125, 159, 137, 254, 50, 5, 73]) }, statementDigest := (bytes [42, 101, 154, 85, 158, 161, 187, 254, 169, 170, 79, 216, 200, 213, 158, 169, 96, 62, 119, 120, 71, 142, 202, 15, 103, 177, 22, 123, 41, 105, 7, 41]), proofDigest := (bytes [42, 130, 54, 190, 34, 251, 78, 0, 20, 192, 149, 131, 102, 98, 114, 167, 203, 118, 188, 195, 191, 192, 250, 217, 166, 217, 187, 84, 132, 153, 16, 7]), digest := (bytes [164, 76, 177, 101, 164, 73, 39, 79, 196, 212, 168, 150, 99, 204, 112, 238, 222, 112, 18, 167, 234, 16, 16, 30, 55, 166, 47, 192, 154, 229, 26, 164]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [145, 185, 120, 4, 182, 105, 56, 218, 160, 76, 130, 184, 185, 23, 212, 85, 29, 144, 2, 172, 228, 214, 153, 212, 237, 73, 247, 209, 214, 142, 172, 26]), layoutVersion := 1, digest := (bytes [18, 231, 233, 115, 54, 59, 74, 124, 141, 216, 53, 117, 18, 195, 37, 72, 42, 155, 48, 36, 212, 118, 188, 110, 112, 122, 142, 164, 103, 22, 125, 227]) }, rowWidth := 38, timeLen := 4, columnDigests := [(bytes [212, 186, 229, 172, 74, 68, 211, 103, 24, 241, 21, 82, 209, 33, 189, 99, 223, 36, 129, 167, 9, 173, 76, 108, 178, 222, 90, 225, 89, 142, 8, 14]), (bytes [56, 58, 241, 13, 94, 161, 102, 38, 209, 85, 101, 10, 115, 74, 68, 15, 139, 16, 65, 164, 142, 61, 38, 80, 159, 19, 8, 220, 33, 174, 155, 155]), (bytes [29, 30, 250, 119, 67, 192, 190, 83, 169, 199, 126, 126, 209, 9, 207, 51, 13, 31, 240, 215, 38, 77, 233, 53, 71, 218, 94, 76, 41, 218, 33, 58]), (bytes [181, 122, 105, 181, 35, 180, 95, 214, 79, 41, 41, 2, 114, 48, 216, 55, 223, 211, 166, 64, 24, 33, 244, 234, 111, 10, 124, 63, 69, 70, 27, 116]), (bytes [235, 168, 211, 18, 219, 164, 123, 11, 1, 214, 235, 228, 142, 231, 19, 191, 111, 116, 112, 196, 167, 65, 6, 113, 150, 204, 141, 39, 111, 24, 165, 153]), (bytes [242, 28, 35, 169, 87, 104, 212, 237, 236, 149, 250, 219, 103, 80, 207, 126, 166, 205, 108, 128, 249, 85, 204, 223, 195, 102, 69, 23, 26, 53, 12, 57]), (bytes [91, 136, 102, 108, 254, 142, 77, 48, 97, 138, 138, 188, 220, 213, 55, 183, 133, 216, 230, 69, 191, 7, 253, 203, 112, 162, 85, 64, 74, 16, 34, 24]), (bytes [129, 132, 183, 42, 51, 67, 121, 100, 80, 40, 164, 136, 133, 105, 229, 130, 159, 202, 234, 223, 139, 249, 75, 123, 172, 38, 218, 88, 128, 30, 75, 38]), (bytes [126, 87, 159, 40, 116, 37, 52, 13, 86, 125, 244, 174, 142, 181, 192, 111, 194, 227, 82, 248, 236, 58, 229, 164, 28, 128, 106, 53, 58, 161, 20, 153]), (bytes [188, 182, 15, 241, 27, 114, 61, 238, 138, 213, 162, 50, 229, 51, 254, 0, 246, 2, 104, 201, 95, 72, 156, 200, 194, 39, 117, 213, 161, 47, 201, 214]), (bytes [205, 97, 99, 248, 17, 57, 155, 127, 10, 102, 114, 119, 106, 212, 70, 158, 53, 53, 223, 134, 113, 7, 137, 116, 70, 128, 72, 131, 100, 105, 126, 35]), (bytes [159, 179, 196, 167, 11, 132, 131, 110, 84, 172, 39, 73, 244, 241, 232, 32, 248, 129, 72, 151, 124, 121, 160, 127, 78, 225, 160, 13, 107, 159, 19, 251]), (bytes [228, 133, 33, 58, 61, 4, 79, 187, 176, 11, 11, 138, 102, 106, 51, 254, 251, 43, 4, 121, 130, 120, 223, 211, 164, 108, 183, 93, 47, 129, 51, 217]), (bytes [228, 193, 216, 182, 131, 150, 36, 125, 196, 115, 206, 157, 54, 8, 132, 236, 146, 38, 35, 6, 90, 57, 169, 190, 50, 184, 164, 10, 148, 113, 222, 157]), (bytes [87, 102, 108, 126, 93, 164, 233, 69, 211, 71, 36, 223, 61, 16, 50, 218, 90, 189, 162, 8, 230, 188, 91, 133, 74, 139, 163, 152, 147, 136, 55, 6]), (bytes [220, 193, 230, 244, 243, 14, 93, 42, 216, 108, 251, 253, 94, 191, 212, 189, 13, 211, 94, 236, 218, 138, 122, 7, 190, 222, 130, 249, 182, 150, 137, 189]), (bytes [223, 89, 191, 11, 110, 102, 31, 137, 129, 115, 137, 48, 64, 221, 208, 112, 235, 228, 24, 226, 254, 59, 16, 16, 192, 134, 30, 101, 212, 162, 156, 187]), (bytes [156, 22, 213, 157, 3, 147, 139, 132, 146, 22, 57, 209, 56, 31, 20, 20, 229, 105, 89, 38, 226, 230, 110, 49, 208, 70, 178, 10, 75, 21, 225, 62]), (bytes [89, 6, 118, 169, 105, 54, 5, 121, 26, 253, 91, 160, 13, 78, 211, 28, 177, 107, 187, 177, 10, 185, 35, 168, 191, 215, 99, 41, 155, 74, 182, 15]), (bytes [16, 1, 45, 207, 125, 115, 77, 40, 96, 249, 191, 96, 68, 155, 161, 144, 89, 205, 15, 173, 177, 139, 3, 87, 248, 132, 221, 254, 91, 235, 118, 133]), (bytes [2, 197, 213, 149, 21, 90, 236, 108, 141, 146, 26, 38, 0, 78, 135, 95, 223, 228, 221, 179, 125, 245, 167, 198, 49, 196, 48, 128, 192, 39, 124, 49]), (bytes [130, 134, 127, 131, 40, 47, 149, 206, 210, 112, 225, 17, 66, 25, 14, 78, 65, 235, 99, 73, 206, 90, 67, 148, 19, 78, 146, 25, 197, 149, 108, 61]), (bytes [8, 234, 67, 158, 76, 76, 170, 16, 58, 161, 138, 98, 35, 61, 115, 114, 104, 189, 45, 62, 96, 35, 11, 160, 56, 73, 223, 212, 106, 84, 224, 145]), (bytes [0, 189, 116, 3, 67, 124, 251, 249, 47, 128, 49, 73, 210, 47, 86, 252, 162, 78, 171, 9, 96, 183, 112, 195, 81, 120, 202, 223, 242, 24, 76, 51]), (bytes [81, 144, 1, 221, 155, 166, 187, 155, 181, 172, 254, 158, 176, 149, 110, 161, 164, 146, 156, 197, 231, 227, 176, 108, 72, 168, 128, 97, 162, 214, 166, 78]), (bytes [238, 147, 134, 181, 8, 29, 128, 200, 221, 198, 65, 181, 234, 22, 117, 159, 112, 0, 90, 214, 190, 69, 86, 72, 209, 196, 234, 23, 145, 109, 49, 190]), (bytes [150, 94, 21, 115, 92, 3, 250, 46, 250, 39, 23, 156, 66, 177, 198, 103, 242, 34, 109, 175, 253, 18, 181, 44, 23, 6, 9, 9, 119, 235, 11, 108]), (bytes [135, 215, 141, 47, 156, 11, 54, 54, 3, 72, 179, 247, 223, 155, 104, 7, 155, 222, 232, 159, 97, 172, 115, 97, 167, 121, 212, 57, 156, 44, 117, 203]), (bytes [84, 95, 115, 25, 213, 106, 24, 56, 216, 206, 94, 157, 100, 187, 198, 197, 93, 1, 173, 134, 90, 112, 47, 80, 254, 7, 54, 249, 32, 132, 243, 167]), (bytes [130, 198, 251, 47, 44, 43, 143, 92, 82, 195, 92, 157, 42, 215, 42, 26, 5, 251, 108, 34, 34, 0, 80, 113, 213, 113, 25, 247, 190, 124, 74, 52]), (bytes [234, 182, 234, 160, 23, 192, 246, 199, 173, 187, 203, 106, 254, 25, 134, 196, 2, 40, 181, 117, 170, 220, 56, 86, 63, 246, 0, 182, 78, 16, 61, 77]), (bytes [40, 254, 204, 213, 6, 140, 117, 235, 134, 79, 86, 81, 169, 63, 60, 118, 8, 156, 87, 198, 194, 60, 29, 160, 125, 250, 15, 187, 147, 220, 29, 92]), (bytes [18, 187, 180, 226, 104, 66, 42, 243, 22, 156, 53, 240, 151, 142, 203, 83, 91, 143, 153, 183, 211, 14, 178, 15, 249, 35, 88, 211, 226, 167, 221, 238]), (bytes [164, 40, 127, 229, 211, 147, 121, 221, 253, 56, 242, 238, 25, 160, 231, 5, 98, 88, 35, 198, 216, 51, 242, 34, 196, 132, 1, 62, 202, 49, 246, 41]), (bytes [122, 105, 77, 66, 174, 33, 37, 82, 171, 117, 60, 146, 152, 71, 176, 9, 4, 214, 95, 111, 117, 16, 77, 11, 22, 12, 202, 53, 36, 93, 76, 79]), (bytes [190, 26, 99, 184, 175, 199, 251, 124, 134, 183, 220, 35, 196, 195, 152, 135, 36, 169, 87, 198, 14, 22, 245, 143, 20, 239, 221, 18, 139, 77, 165, 236]), (bytes [80, 33, 41, 82, 68, 242, 18, 200, 209, 172, 125, 228, 155, 229, 192, 181, 222, 62, 254, 113, 197, 197, 209, 167, 162, 245, 86, 19, 189, 248, 96, 43]), (bytes [90, 10, 190, 250, 226, 23, 47, 210, 182, 164, 148, 175, 37, 226, 99, 192, 247, 166, 149, 66, 95, 29, 230, 232, 50, 99, 224, 203, 78, 177, 221, 250])], familyDigest := (bytes [145, 185, 120, 4, 182, 105, 56, 218, 160, 76, 130, 184, 185, 23, 212, 85, 29, 144, 2, 172, 228, 214, 153, 212, 237, 73, 247, 209, 214, 142, 172, 26]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [145, 185, 120, 4, 182, 105, 56, 218, 160, 76, 130, 184, 185, 23, 212, 85, 29, 144, 2, 172, 228, 214, 153, 212, 237, 73, 247, 209, 214, 142, 172, 26]), layoutVersion := 1, digest := (bytes [18, 231, 233, 115, 54, 59, 74, 124, 141, 216, 53, 117, 18, 195, 37, 72, 42, 155, 48, 36, 212, 118, 188, 110, 112, 122, 142, 164, 103, 22, 125, 227]) }, logicalIndex := 0, digest := (bytes [114, 0, 231, 125, 184, 11, 189, 86, 47, 104, 253, 243, 59, 242, 5, 175, 6, 250, 216, 110, 254, 254, 46, 197, 14, 254, 237, 152, 105, 219, 99, 18]) }, valueDigest := (bytes [48, 9, 158, 59, 120, 45, 200, 155, 8, 144, 252, 183, 179, 168, 71, 138, 10, 136, 117, 72, 217, 133, 28, 26, 240, 134, 159, 61, 227, 8, 46, 227]), digest := (bytes [152, 67, 38, 218, 150, 189, 234, 79, 74, 220, 26, 159, 229, 146, 78, 206, 161, 228, 73, 176, 58, 94, 234, 140, 120, 75, 143, 142, 72, 34, 92, 172]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [145, 185, 120, 4, 182, 105, 56, 218, 160, 76, 130, 184, 185, 23, 212, 85, 29, 144, 2, 172, 228, 214, 153, 212, 237, 73, 247, 209, 214, 142, 172, 26]), layoutVersion := 1, digest := (bytes [18, 231, 233, 115, 54, 59, 74, 124, 141, 216, 53, 117, 18, 195, 37, 72, 42, 155, 48, 36, 212, 118, 188, 110, 112, 122, 142, 164, 103, 22, 125, 227]) }, logicalIndex := 3, digest := (bytes [120, 98, 118, 137, 205, 199, 187, 39, 239, 102, 53, 233, 55, 0, 58, 90, 154, 127, 255, 27, 120, 128, 11, 18, 59, 142, 157, 230, 244, 116, 14, 230]) }, valueDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [107, 165, 108, 133, 174, 95, 91, 234, 119, 30, 16, 150, 40, 4, 144, 239, 133, 92, 98, 43, 246, 169, 173, 74, 237, 139, 90, 107, 126, 190, 59, 91]) }), digest := (bytes [98, 184, 1, 28, 8, 233, 14, 167, 138, 139, 164, 47, 11, 140, 225, 95, 226, 252, 123, 45, 143, 58, 3, 143, 189, 89, 52, 186, 168, 57, 35, 189]) }
  , rootLaneCommitment := { timeLen := 4, commitments := { commitmentCount := 38, digest := (bytes [78, 112, 96, 107, 186, 151, 14, 73, 226, 146, 137, 145, 183, 51, 53, 228, 122, 108, 60, 52, 98, 17, 23, 23, 93, 228, 209, 25, 87, 61, 135, 39]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [78, 112, 96, 107, 186, 151, 14, 73, 226, 146, 137, 145, 183, 51, 53, 228, 122, 108, 60, 52, 98, 17, 23, 23, 93, 228, 209, 25, 87, 61, 135, 39]), layoutVersion := 3, digest := (bytes [142, 215, 206, 200, 110, 197, 140, 8, 50, 119, 131, 108, 114, 183, 207, 142, 143, 138, 16, 193, 88, 249, 130, 60, 72, 218, 144, 7, 98, 5, 98, 51]) }, logicalIndex := 0, digest := (bytes [185, 118, 70, 229, 49, 2, 200, 218, 33, 247, 137, 217, 135, 84, 230, 197, 19, 47, 60, 48, 6, 242, 204, 224, 209, 163, 179, 39, 200, 72, 250, 106]) }, valueDigest := (bytes [48, 9, 158, 59, 120, 45, 200, 155, 8, 144, 252, 183, 179, 168, 71, 138, 10, 136, 117, 72, 217, 133, 28, 26, 240, 134, 159, 61, 227, 8, 46, 227]), digest := (bytes [140, 205, 179, 71, 211, 37, 11, 234, 8, 119, 236, 183, 30, 232, 232, 238, 74, 242, 245, 47, 6, 195, 73, 200, 189, 138, 206, 121, 159, 131, 204, 208]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [78, 112, 96, 107, 186, 151, 14, 73, 226, 146, 137, 145, 183, 51, 53, 228, 122, 108, 60, 52, 98, 17, 23, 23, 93, 228, 209, 25, 87, 61, 135, 39]), layoutVersion := 3, digest := (bytes [142, 215, 206, 200, 110, 197, 140, 8, 50, 119, 131, 108, 114, 183, 207, 142, 143, 138, 16, 193, 88, 249, 130, 60, 72, 218, 144, 7, 98, 5, 98, 51]) }, logicalIndex := 3, digest := (bytes [241, 74, 29, 162, 217, 212, 2, 197, 83, 67, 8, 50, 75, 64, 52, 223, 39, 121, 92, 14, 223, 108, 155, 146, 136, 31, 254, 16, 141, 172, 24, 246]) }, valueDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [197, 174, 83, 47, 237, 159, 237, 193, 255, 249, 235, 118, 39, 230, 112, 151, 155, 242, 18, 242, 69, 119, 21, 118, 245, 166, 248, 68, 177, 255, 7, 197]) }), digest := (bytes [102, 192, 243, 201, 108, 61, 3, 38, 64, 97, 138, 8, 92, 253, 154, 67, 113, 184, 198, 21, 111, 157, 113, 66, 67, 157, 65, 39, 71, 84, 32, 55]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [98, 184, 1, 28, 8, 233, 14, 167, 138, 139, 164, 47, 11, 140, 225, 95, 226, 252, 123, 45, 143, 58, 3, 143, 189, 89, 52, 186, 168, 57, 35, 189]), rootLaneCommitmentDigest := (bytes [102, 192, 243, 201, 108, 61, 3, 38, 64, 97, 138, 8, 92, 253, 154, 67, 113, 184, 198, 21, 111, 157, 113, 66, 67, 157, 65, 39, 71, 84, 32, 55]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 4, digest := (bytes [201, 15, 235, 187, 156, 81, 127, 240, 117, 241, 217, 193, 19, 245, 60, 149, 61, 230, 20, 186, 179, 27, 38, 148, 211, 194, 26, 35, 196, 99, 247, 74]) }, statementDigest := (bytes [237, 101, 30, 82, 184, 88, 85, 162, 193, 97, 218, 117, 225, 141, 189, 173, 215, 38, 253, 132, 254, 169, 92, 71, 141, 159, 55, 250, 65, 92, 27, 224]), proofDigest := (bytes [163, 55, 54, 51, 73, 32, 148, 151, 237, 58, 3, 182, 45, 114, 218, 232, 32, 94, 178, 234, 66, 148, 227, 45, 139, 72, 130, 73, 107, 136, 223, 71]), digest := (bytes [0, 29, 102, 54, 6, 148, 6, 86, 12, 1, 176, 2, 191, 135, 233, 121, 31, 139, 122, 177, 208, 181, 163, 188, 12, 166, 245, 147, 44, 19, 4, 102]) }
  , digest := (bytes [234, 150, 212, 123, 115, 169, 123, 27, 165, 211, 254, 65, 92, 38, 227, 180, 23, 12, 29, 179, 141, 184, 163, 101, 214, 225, 2, 194, 97, 249, 7, 1])
}
    , transcript := {
  appLabel := (bytes [110, 101, 111, 46, 102, 111, 108, 100, 46, 110, 101, 120, 116, 47, 114, 118, 54, 52, 105, 109, 47, 112, 97, 114, 105, 116, 121, 95, 107, 101, 114, 110, 101, 108, 95, 118, 49])
  , events := [{
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 116, 114, 97, 110, 115, 99, 114, 105, 112, 116, 95, 115, 101, 101, 100])
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 99, 111, 110, 116, 114, 111, 108, 45, 102, 108, 111, 119, 45, 98, 103, 101, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [27634538711377453, 212436084071, 13380622803955469567, 3521951206484747623, 9254679819230523135, 7793219495316757120, 11804775929249192629, 11428962190686586919], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [99, 111, 110, 116, 114, 111, 108, 95, 102, 108, 111, 119, 95, 98, 103, 101, 95, 116, 97, 107, 101, 110, 95, 115, 107, 105, 112, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [27634538711377453, 212436084071, 13380622803955469567, 3521951206484747623, 9254679819230523135, 7793219495316757120, 11804775929249192629, 11428962190686586919], absorbed := 2 }
  , cursorAfter := { stateWords := [465674789733, 15215007983741485913, 1874102496922678124, 15811577226146168675, 12499081103431237419, 6236543849577039589, 18364626348649379228, 9605098834442363174], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [1048723, 4293918995, 2151523, 115, 115]
  , cursorBefore := { stateWords := [465674789733, 15215007983741485913, 1874102496922678124, 15811577226146168675, 12499081103431237419, 6236543849577039589, 18364626348649379228, 9605098834442363174], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 3863308733289208625, 7732092715818731724, 10897732674725557640, 5122957389714755714, 14412050624005899228, 1750636057271584042, 12393219942905639417], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [0, 3863308733289208625, 7732092715818731724, 10897732674725557640, 5122957389714755714, 14412050624005899228, 1750636057271584042, 12393219942905639417], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 0, 0, 16151006258102468094, 8781961033189472703, 12134297468010880506, 14040033356860820732, 5708464117521822575], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [0, 0, 0, 16151006258102468094, 8781961033189472703, 12134297468010880506, 14040033356860820732, 5708464117521822575], absorbed := 3 }
  , cursorAfter := { stateWords := [0, 13274361720229328095, 6743633916125540037, 11091420359420822032, 16156375987694885752, 8426099295295468575, 8641798412692801466, 10646262291278467146], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [72, 152, 175, 61, 117, 151, 32, 177, 71, 104, 246, 95, 143, 151, 74, 89, 231, 218, 126, 100, 152, 157, 138, 113, 5, 107, 158, 151, 6, 22, 95, 167])
  , u64s := []
  , cursorBefore := { stateWords := [0, 13274361720229328095, 6743633916125540037, 11091420359420822032, 16156375987694885752, 8426099295295468575, 8641798412692801466, 10646262291278467146], absorbed := 1 }
  , cursorAfter := { stateWords := [14357883205051597627, 13561141896955339720, 1211624597452199648, 4365701353448657734, 14478822131144684645, 16118358895982733284, 15277660066242757454, 15771106702652292425], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [14357883205051597627, 13561141896955339720, 1211624597452199648, 4365701353448657734, 14478822131144684645, 16118358895982733284, 15277660066242757454, 15771106702652292425], absorbed := 0 }
  , cursorAfter := { stateWords := [6088699767227576722, 12528948519504330862, 11279663846586579329, 17869051528129767402, 11889200830506914295, 10599455837063559955, 759464082804430731, 15283912685368151612], absorbed := 0 }
  , challengeOutput := (some 6088699767227576722)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [111, 27, 127, 199, 224, 106, 179, 224, 100, 158, 193, 168, 87, 52, 192, 102, 12, 142, 204, 107, 172, 208, 173, 109, 195, 250, 231, 36, 211, 96, 202, 41])
  , u64s := []
  , cursorBefore := { stateWords := [6088699767227576722, 12528948519504330862, 11279663846586579329, 17869051528129767402, 11889200830506914295, 10599455837063559955, 759464082804430731, 15283912685368151612], absorbed := 0 }
  , cursorAfter := { stateWords := [48532222294910656, 10388163368168912, 701128915, 14843658696269909404, 632567264487924670, 9495684395542701107, 12754696978657578631, 5965019087477990409], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [48532222294910656, 10388163368168912, 701128915, 14843658696269909404, 632567264487924670, 9495684395542701107, 12754696978657578631, 5965019087477990409], absorbed := 3 }
  , cursorAfter := { stateWords := [13380091740178962810, 1987045513776597526, 14252462800775023989, 13248926025003527830, 11922324911447888953, 15258157582598726077, 10666093963908230844, 10326266213215111518], absorbed := 0 }
  , challengeOutput := (some 13380091740178962810)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [13380091740178962810, 1987045513776597526, 14252462800775023989, 13248926025003527830, 11922324911447888953, 15258157582598726077, 10666093963908230844, 10326266213215111518], absorbed := 0 }
  , cursorAfter := { stateWords := [15897272204832747763, 11309953007401633108, 9308121576220038094, 14421880181001689210, 1035619753428010656, 5328331505368064188, 7303431608412067335, 3324893135966130710], absorbed := 0 }
  , challengeOutput := (some 15897272204832747763)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [41, 249, 151, 99, 238, 144, 154, 142, 199, 178, 160, 62, 82, 25, 55, 207, 119, 207, 88, 40, 18, 163, 232, 49, 21, 199, 146, 193, 148, 227, 131, 60])
  , u64s := []
  , cursorBefore := { stateWords := [15897272204832747763, 11309953007401633108, 9308121576220038094, 14421880181001689210, 1035619753428010656, 5328331505368064188, 7303431608412067335, 3324893135966130710], absorbed := 0 }
  , cursorAfter := { stateWords := [5110911483760439, 54486054256896163, 1015276436, 4331901097435875928, 15789074150951337316, 3955182664772735096, 10769170991645251297, 17860899021887337642], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [5110911483760439, 54486054256896163, 1015276436, 4331901097435875928, 15789074150951337316, 3955182664772735096, 10769170991645251297, 17860899021887337642], absorbed := 3 }
  , cursorAfter := { stateWords := [13290325236237073002, 3167263823412265548, 2124303598359401438, 5095260702073669384, 8423156342386431665, 13073329068178322645, 7620674100935967401, 4396032368165522868], absorbed := 0 }
  , challengeOutput := (some 13290325236237073002)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [198, 81, 7, 250, 152, 135, 65, 159, 231, 42, 117, 161, 26, 121, 63, 197, 123, 212, 231, 113, 35, 37, 159, 177, 226, 104, 247, 68, 136, 30, 16, 163])
  , u64s := []
  , cursorBefore := { stateWords := [13290325236237073002, 3167263823412265548, 2124303598359401438, 5095260702073669384, 8423156342386431665, 13073329068178322645, 7620674100935967401, 4396032368165522868], absorbed := 0 }
  , cursorAfter := { stateWords := [9976864701138239, 19412328268275493, 2735742600, 6237024833566110327, 5431075642013008537, 6023572556956649998, 10521409209457402270, 12586429016929075820], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [14, 218, 199, 227, 116, 94, 179, 48, 175, 100, 127, 227, 52, 186, 29, 20, 52, 186, 208, 59, 240, 120, 150, 172, 197, 158, 248, 136, 149, 25, 87, 170])
  , u64s := []
  , cursorBefore := { stateWords := [9976864701138239, 19412328268275493, 2735742600, 6237024833566110327, 5431075642013008537, 6023572556956649998, 10521409209457402270, 12586429016929075820], absorbed := 3 }
  , cursorAfter := { stateWords := [67619762073768989, 38553957637592696, 2857834901, 8341731544263560157, 4902622506011080670, 8080200595999723931, 11855971435305081364, 10265924672884533183], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [233, 2, 26, 64, 110, 89, 182, 250, 115, 142, 225, 137, 122, 240, 120, 174, 71, 71, 199, 38, 167, 175, 50, 4, 209, 82, 12, 195, 102, 116, 18, 219])
  , u64s := []
  , cursorBefore := { stateWords := [67619762073768989, 38553957637592696, 2857834901, 8341731544263560157, 4902622506011080670, 8080200595999723931, 11855971435305081364, 10265924672884533183], absorbed := 3 }
  , cursorAfter := { stateWords := [47048958446907000, 54901170292142767, 3675419750, 4408886950467464954, 1614180035197973635, 13250356512350060064, 13140457597853917177, 6806082314764002763], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [47048958446907000, 54901170292142767, 3675419750, 4408886950467464954, 1614180035197973635, 13250356512350060064, 13140457597853917177, 6806082314764002763], absorbed := 3 }
  , cursorAfter := { stateWords := [18231637688184314104, 12136559809485361695, 7943305808637014790, 10473583606824433045, 16180276070919521922, 2320050769754099697, 10410472214867620863, 9488396987056937058], absorbed := 0 }
  , challengeOutput := (some 18231637688184314104)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [18231637688184314104, 12136559809485361695, 7943305808637014790, 10473583606824433045, 16180276070919521922, 2320050769754099697, 10410472214867620863, 9488396987056937058], absorbed := 0 }
  , cursorAfter := { stateWords := [6989028146962492314, 13458860150513018094, 2109944762695544449, 7379276838592249487, 1877861401095802368, 8262029584102291418, 4261609953813478959, 7639261189778842531], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [154, 235, 231, 248, 17, 4, 254, 96, 238, 36, 253, 176, 255, 121, 199, 186, 129, 238, 41, 44, 149, 7, 72, 29, 143, 254, 142, 7, 48, 117, 104, 102]))
}]
}
    , stage1 := stage1
    , stage2 := stage2
    , stage3 := stage3
    , rootExecution := rootExecution
    , stepComposition := stepComposition
    , soundnessAccounting := soundnessAccounting
    , kernelOpeningBundle := kernelOpeningBundle
    , digest := (bytes [71, 144, 126, 107, 77, 250, 71, 99, 213, 93, 132, 112, 217, 71, 62, 133, 26, 136, 176, 242, 29, 54, 2, 99, 186, 98, 169, 88, 3, 99, 196, 94])
  }

end Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors.Case_control_flow_bge_taken_skip_ecall
