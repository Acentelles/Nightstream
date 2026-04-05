import Nightstream.Rv64IM.Generated.AcceptedProofArtifactTypes

set_option maxHeartbeats 0
set_option maxRecDepth 65536

namespace Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors.Case_native_add_chain_x0_ecall

open Nightstream.Rv64IM.Generated

def stage1SemInputs : List SemInView :=
  [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, pc := 0, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 1, archRdBefore := 0, archImm := 7, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 1, rdBefore := 0, rdAfter := 7, imm := 7, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, pc := 4, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 1, archRs1Value := 7, archRs2 := 0, archRs2Value := 0, archRd := 2, archRdBefore := 0, archImm := 9, rs1 := 1, rs1Value := 7, rs2 := 0, rs2Value := 0, rd := 2, rdBefore := 0, rdAfter := 16, imm := 9, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, pc := 8, opcode := .add, traceOpcode := (some .add), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 2, archRs1Value := 16, archRs2 := 1, archRs2Value := 7, archRd := 3, archRdBefore := 0, archImm := 0, rs1 := 2, rs1Value := 16, rs2 := 1, rs2Value := 7, rd := 3, rdBefore := 0, rdAfter := 23, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, pc := 12, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 3, archRs1Value := 23, archRs2 := 0, archRs2Value := 0, archRd := 0, archRdBefore := 0, archImm := 5, rs1 := 3, rs1Value := 23, rs2 := 0, rs2Value := 0, rd := 0, rdBefore := 0, rdAfter := 0, imm := 5, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := false, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 4, stepIndex := 4, sequenceIndex := 0, pc := 16, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 0, archRdBefore := 0, archImm := 0, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 0, rdBefore := 0, rdAfter := 0, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := false, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }]

def stage1RowBindings : List Stage1RowBindingView :=
  [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 7340179, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 4, aluResult := 7, effectiveAddr := none, writesRd := true, rd := 1, rdAfter := 7, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 9470227, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 8, aluResult := 16, effectiveAddr := none, writesRd := true, rd := 2, rdAfter := 16, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 1114547, opcode := .add, traceOpcode := (some .add), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 12, aluResult := 23, effectiveAddr := none, writesRd := true, rd := 3, rdAfter := 23, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 12, fetchedWord := 5341203, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 16, aluResult := 28, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }, { traceIndex := 4, stepIndex := 4, sequenceIndex := 0, fetchPc := 16, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 20, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }]

def stage1 : Stage1ProofBundleView :=
  {
    semInputs := stage1SemInputs
    , rowBindings := stage1RowBindings
    , bytecodeDigest := (bytes [151, 136, 201, 140, 62, 142, 78, 22, 204, 125, 248, 98, 98, 94, 128, 49, 75, 161, 90, 245, 18, 221, 239, 71, 147, 231, 231, 158, 180, 0, 62, 67])
    , aluDigest := (bytes [152, 211, 57, 49, 231, 91, 120, 218, 228, 129, 15, 86, 225, 152, 53, 7, 240, 196, 72, 183, 156, 21, 250, 223, 215, 52, 250, 207, 57, 2, 169, 249])
    , branchDigest := (bytes [220, 179, 253, 59, 64, 112, 36, 190, 53, 211, 22, 211, 224, 215, 37, 72, 86, 24, 73, 221, 247, 140, 13, 121, 167, 250, 81, 87, 11, 115, 219, 71])
    , semantics := { semInputsDigest := (bytes [172, 2, 87, 239, 62, 62, 172, 89, 56, 203, 62, 51, 46, 124, 10, 195, 130, 129, 90, 72, 99, 172, 164, 74, 141, 122, 101, 247, 27, 231, 29, 174]), rowBindingsDigest := (bytes [137, 104, 191, 27, 99, 250, 0, 53, 237, 59, 206, 138, 109, 37, 101, 109, 54, 168, 26, 248, 100, 254, 1, 63, 215, 43, 17, 91, 1, 251, 197, 150]), sequenceCount := 5, helperRowCount := 0, digest := (bytes [20, 122, 20, 177, 150, 156, 138, 222, 139, 29, 214, 219, 56, 246, 216, 233, 67, 210, 125, 230, 228, 177, 196, 30, 159, 206, 169, 44, 53, 10, 141, 34]) }
    , addressCorrectnessDigest := (bytes [133, 40, 123, 35, 105, 195, 56, 116, 225, 123, 171, 20, 218, 227, 68, 130, 66, 21, 38, 157, 104, 16, 220, 175, 160, 249, 207, 142, 96, 205, 104, 135])
    , linkageDigest := (bytes [137, 238, 62, 58, 91, 236, 105, 234, 53, 214, 185, 11, 58, 74, 155, 94, 25, 51, 138, 83, 19, 214, 128, 81, 41, 236, 62, 243, 83, 174, 192, 240])
    , selectedOpening := { claim := { rowsFamilyDigest := (bytes [137, 104, 191, 27, 99, 250, 0, 53, 237, 59, 206, 138, 109, 37, 101, 109, 54, 168, 26, 248, 100, 254, 1, 63, 215, 43, 17, 91, 1, 251, 197, 150]), rowCount := 5, effectRowCount := 5, commitRowCount := 5, realRowCount := 5, preservesX0Count := 2, firstTraceIndex := 0, effectTraceIndex := 0, commitTraceIndex := 0, lastTraceIndex := 4, mix := 14162923987488775188, points := { first := { id := { object := { familyTag := 1, commitmentDigest := (bytes [137, 104, 191, 27, 99, 250, 0, 53, 237, 59, 206, 138, 109, 37, 101, 109, 54, 168, 26, 248, 100, 254, 1, 63, 215, 43, 17, 91, 1, 251, 197, 150]), layoutVersion := 1, digest := (bytes [222, 201, 89, 71, 67, 60, 136, 103, 224, 53, 244, 196, 30, 149, 173, 79, 245, 11, 81, 15, 228, 166, 44, 33, 206, 66, 84, 72, 116, 109, 170, 15]) }, logicalIndex := 0, digest := (bytes [204, 24, 129, 150, 55, 91, 47, 127, 102, 126, 54, 237, 73, 201, 49, 235, 4, 49, 32, 29, 44, 2, 9, 0, 11, 219, 225, 75, 221, 248, 153, 197]) }, valueDigest := (bytes [73, 83, 25, 86, 180, 30, 6, 79, 5, 208, 134, 133, 127, 129, 23, 9, 43, 243, 200, 234, 163, 191, 136, 243, 233, 110, 102, 222, 35, 33, 44, 24]), digest := (bytes [53, 116, 31, 202, 206, 167, 152, 164, 17, 136, 215, 157, 26, 175, 12, 77, 85, 234, 1, 45, 135, 239, 185, 205, 41, 41, 142, 101, 135, 205, 201, 4]) }, effect := { id := { object := { familyTag := 1, commitmentDigest := (bytes [137, 104, 191, 27, 99, 250, 0, 53, 237, 59, 206, 138, 109, 37, 101, 109, 54, 168, 26, 248, 100, 254, 1, 63, 215, 43, 17, 91, 1, 251, 197, 150]), layoutVersion := 1, digest := (bytes [222, 201, 89, 71, 67, 60, 136, 103, 224, 53, 244, 196, 30, 149, 173, 79, 245, 11, 81, 15, 228, 166, 44, 33, 206, 66, 84, 72, 116, 109, 170, 15]) }, logicalIndex := 0, digest := (bytes [204, 24, 129, 150, 55, 91, 47, 127, 102, 126, 54, 237, 73, 201, 49, 235, 4, 49, 32, 29, 44, 2, 9, 0, 11, 219, 225, 75, 221, 248, 153, 197]) }, valueDigest := (bytes [73, 83, 25, 86, 180, 30, 6, 79, 5, 208, 134, 133, 127, 129, 23, 9, 43, 243, 200, 234, 163, 191, 136, 243, 233, 110, 102, 222, 35, 33, 44, 24]), digest := (bytes [53, 116, 31, 202, 206, 167, 152, 164, 17, 136, 215, 157, 26, 175, 12, 77, 85, 234, 1, 45, 135, 239, 185, 205, 41, 41, 142, 101, 135, 205, 201, 4]) }, commit := { id := { object := { familyTag := 1, commitmentDigest := (bytes [137, 104, 191, 27, 99, 250, 0, 53, 237, 59, 206, 138, 109, 37, 101, 109, 54, 168, 26, 248, 100, 254, 1, 63, 215, 43, 17, 91, 1, 251, 197, 150]), layoutVersion := 1, digest := (bytes [222, 201, 89, 71, 67, 60, 136, 103, 224, 53, 244, 196, 30, 149, 173, 79, 245, 11, 81, 15, 228, 166, 44, 33, 206, 66, 84, 72, 116, 109, 170, 15]) }, logicalIndex := 0, digest := (bytes [204, 24, 129, 150, 55, 91, 47, 127, 102, 126, 54, 237, 73, 201, 49, 235, 4, 49, 32, 29, 44, 2, 9, 0, 11, 219, 225, 75, 221, 248, 153, 197]) }, valueDigest := (bytes [73, 83, 25, 86, 180, 30, 6, 79, 5, 208, 134, 133, 127, 129, 23, 9, 43, 243, 200, 234, 163, 191, 136, 243, 233, 110, 102, 222, 35, 33, 44, 24]), digest := (bytes [53, 116, 31, 202, 206, 167, 152, 164, 17, 136, 215, 157, 26, 175, 12, 77, 85, 234, 1, 45, 135, 239, 185, 205, 41, 41, 142, 101, 135, 205, 201, 4]) }, last := { id := { object := { familyTag := 1, commitmentDigest := (bytes [137, 104, 191, 27, 99, 250, 0, 53, 237, 59, 206, 138, 109, 37, 101, 109, 54, 168, 26, 248, 100, 254, 1, 63, 215, 43, 17, 91, 1, 251, 197, 150]), layoutVersion := 1, digest := (bytes [222, 201, 89, 71, 67, 60, 136, 103, 224, 53, 244, 196, 30, 149, 173, 79, 245, 11, 81, 15, 228, 166, 44, 33, 206, 66, 84, 72, 116, 109, 170, 15]) }, logicalIndex := 4, digest := (bytes [204, 16, 216, 43, 30, 58, 249, 142, 112, 234, 102, 84, 178, 255, 138, 215, 105, 159, 27, 33, 143, 25, 167, 210, 52, 223, 97, 242, 170, 130, 241, 173]) }, valueDigest := (bytes [80, 178, 26, 49, 69, 161, 230, 123, 68, 254, 88, 88, 229, 248, 207, 138, 245, 172, 71, 139, 39, 139, 170, 107, 237, 65, 83, 59, 93, 8, 204, 99]), digest := (bytes [137, 194, 10, 154, 148, 139, 60, 61, 101, 204, 178, 72, 199, 84, 57, 183, 138, 208, 208, 21, 65, 63, 52, 133, 234, 188, 11, 104, 23, 61, 142, 184]) } }, digest := (bytes [11, 6, 133, 222, 21, 112, 82, 111, 213, 21, 203, 67, 23, 153, 6, 16, 177, 15, 171, 107, 18, 216, 205, 232, 129, 252, 100, 111, 0, 162, 243, 250]) }, packaged := { statementDigest := (bytes [252, 165, 0, 123, 179, 134, 114, 181, 99, 155, 14, 170, 58, 243, 92, 21, 13, 81, 83, 114, 242, 142, 127, 200, 135, 13, 56, 24, 86, 192, 101, 247]), proofDigest := (bytes [19, 80, 172, 135, 243, 244, 105, 220, 19, 67, 84, 7, 170, 137, 137, 128, 230, 112, 51, 44, 13, 33, 171, 233, 131, 142, 67, 63, 235, 208, 208, 230]) }, digest := (bytes [132, 174, 232, 78, 241, 78, 76, 182, 143, 159, 220, 145, 105, 244, 181, 164, 64, 221, 241, 6, 171, 5, 207, 117, 108, 144, 154, 73, 15, 132, 167, 178]) }
    , digest := (bytes [149, 29, 49, 194, 141, 43, 68, 75, 212, 42, 207, 97, 252, 191, 254, 4, 156, 6, 203, 228, 212, 230, 19, 249, 168, 28, 162, 63, 171, 10, 29, 217])
  }

def stage2RegisterReads : List RegisterReadEventView :=
  [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 0, value := 0 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 1, value := 7 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 2, value := 16 }, { traceIndex := 2, stepIndex := 2, role := .rs2, reg := 1, value := 7 }, { traceIndex := 3, stepIndex := 3, role := .rs1, reg := 3, value := 23 }]

def stage2RegisterWrites : List RegisterWriteEventView :=
  [{ traceIndex := 0, stepIndex := 0, reg := 1, previous := 0, next := 7 }, { traceIndex := 1, stepIndex := 1, reg := 2, previous := 0, next := 16 }, { traceIndex := 2, stepIndex := 2, reg := 3, previous := 0, next := 23 }]

def stage2RamEvents : List RamEventView :=
  []

def stage2TwistLinks : List TwistLinkEventView :=
  [{ traceIndex := 0, stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 7), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 1, family := .nativeAlu, routedWriteValue := (some 16), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 2, family := .nativeAlu, routedWriteValue := (some 23), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 3, family := .nativeAlu, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 4, stepIndex := 4, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]

def stage2 : Stage2ProofBundleView :=
  {
    registerReads := stage2RegisterReads
    , registerWrites := stage2RegisterWrites
    , ramEvents := stage2RamEvents
    , registerDigest := (bytes [111, 76, 171, 234, 195, 229, 45, 36, 179, 228, 113, 202, 99, 200, 65, 130, 109, 178, 244, 101, 211, 40, 161, 25, 103, 37, 235, 42, 76, 131, 51, 95])
    , ramDigest := (bytes [209, 217, 105, 43, 209, 229, 156, 61, 92, 164, 94, 232, 52, 214, 73, 229, 72, 188, 139, 122, 165, 123, 201, 212, 205, 15, 247, 197, 165, 154, 109, 246])
    , temporal := { twistLinks := stage2TwistLinks, registerTimelineDigest := (bytes [233, 49, 210, 8, 61, 182, 49, 193, 9, 67, 237, 142, 60, 207, 143, 165, 129, 6, 165, 142, 134, 57, 166, 208, 31, 199, 228, 148, 200, 104, 169, 242]), ramTimelineDigest := (bytes [8, 117, 17, 140, 128, 180, 240, 140, 250, 181, 90, 134, 147, 17, 197, 122, 220, 8, 66, 15, 193, 254, 11, 122, 115, 210, 233, 239, 55, 132, 31, 228]), twistLinksDigest := (bytes [203, 234, 9, 145, 206, 2, 134, 154, 148, 109, 155, 128, 114, 155, 167, 193, 126, 237, 111, 215, 198, 252, 133, 48, 127, 90, 135, 168, 41, 100, 118, 220]), digest := (bytes [210, 76, 209, 6, 58, 62, 223, 200, 191, 221, 252, 176, 5, 38, 163, 26, 122, 200, 135, 22, 173, 116, 239, 249, 94, 24, 149, 127, 123, 156, 4, 249]) }
    , semantics := { registerReadsFamilyDigest := (bytes [194, 23, 124, 18, 185, 134, 254, 169, 31, 43, 101, 150, 131, 253, 0, 18, 241, 196, 224, 189, 39, 45, 138, 91, 76, 92, 255, 90, 174, 167, 17, 155]), registerWritesFamilyDigest := (bytes [137, 199, 173, 82, 220, 177, 140, 174, 117, 84, 55, 76, 112, 11, 52, 194, 27, 179, 9, 47, 97, 90, 135, 74, 33, 241, 31, 53, 168, 171, 207, 179]), ramEventsFamilyDigest := (bytes [85, 17, 108, 38, 84, 5, 109, 213, 145, 137, 203, 96, 117, 127, 130, 193, 117, 29, 27, 219, 228, 58, 7, 214, 144, 155, 66, 38, 127, 8, 241, 95]), twistLinksFamilyDigest := (bytes [119, 33, 131, 78, 183, 142, 67, 89, 155, 225, 28, 111, 63, 22, 114, 83, 222, 50, 135, 197, 77, 196, 177, 201, 140, 250, 196, 80, 65, 136, 230, 139]), rowCount := 5, registerEventCount := 8, ramEventCount := 0, digest := (bytes [166, 133, 185, 148, 207, 115, 36, 54, 134, 251, 252, 160, 57, 153, 37, 187, 163, 69, 27, 113, 26, 102, 181, 246, 195, 91, 208, 117, 151, 232, 51, 41]) }
    , linkageDigest := (bytes [199, 146, 218, 15, 237, 112, 57, 191, 101, 95, 69, 156, 97, 214, 9, 83, 43, 87, 169, 23, 34, 99, 91, 73, 26, 219, 252, 35, 184, 4, 5, 66])
    , selectedOpening := { claim := { registerReadsFamilyDigest := (bytes [194, 23, 124, 18, 185, 134, 254, 169, 31, 43, 101, 150, 131, 253, 0, 18, 241, 196, 224, 189, 39, 45, 138, 91, 76, 92, 255, 90, 174, 167, 17, 155]), registerWritesFamilyDigest := (bytes [137, 199, 173, 82, 220, 177, 140, 174, 117, 84, 55, 76, 112, 11, 52, 194, 27, 179, 9, 47, 97, 90, 135, 74, 33, 241, 31, 53, 168, 171, 207, 179]), ramEventsFamilyDigest := (bytes [85, 17, 108, 38, 84, 5, 109, 213, 145, 137, 203, 96, 117, 127, 130, 193, 117, 29, 27, 219, 228, 58, 7, 214, 144, 155, 66, 38, 127, 8, 241, 95]), twistLinksFamilyDigest := (bytes [119, 33, 131, 78, 183, 142, 67, 89, 155, 225, 28, 111, 63, 22, 114, 83, 222, 50, 135, 197, 77, 196, 177, 201, 140, 250, 196, 80, 65, 136, 230, 139]), registerReadCount := 5, registerWriteCount := 3, ramEventCount := 0, twistLinkCount := 5, ramReadCount := 0, ramWriteCount := 0, regMix := 3542089801700290441, ramMix := 1893458894779210205, points := { firstRead := (some { id := { object := { familyTag := 2, commitmentDigest := (bytes [194, 23, 124, 18, 185, 134, 254, 169, 31, 43, 101, 150, 131, 253, 0, 18, 241, 196, 224, 189, 39, 45, 138, 91, 76, 92, 255, 90, 174, 167, 17, 155]), layoutVersion := 1, digest := (bytes [38, 231, 53, 187, 224, 246, 213, 166, 78, 7, 224, 254, 26, 197, 116, 58, 136, 205, 199, 178, 210, 236, 143, 152, 88, 33, 241, 43, 139, 71, 34, 34]) }, logicalIndex := 0, digest := (bytes [74, 108, 149, 140, 84, 64, 221, 20, 7, 180, 122, 212, 84, 96, 214, 206, 228, 223, 133, 118, 44, 252, 17, 86, 117, 50, 239, 210, 62, 95, 229, 18]) }, valueDigest := (bytes [165, 2, 50, 180, 56, 84, 68, 13, 37, 136, 82, 191, 49, 42, 150, 67, 180, 45, 199, 251, 168, 91, 53, 39, 20, 9, 70, 46, 155, 135, 100, 116]), digest := (bytes [200, 199, 154, 211, 40, 200, 114, 214, 112, 165, 194, 57, 31, 33, 72, 64, 6, 209, 137, 218, 34, 136, 243, 14, 113, 254, 151, 113, 95, 250, 84, 200]) }), lastRead := (some { id := { object := { familyTag := 2, commitmentDigest := (bytes [194, 23, 124, 18, 185, 134, 254, 169, 31, 43, 101, 150, 131, 253, 0, 18, 241, 196, 224, 189, 39, 45, 138, 91, 76, 92, 255, 90, 174, 167, 17, 155]), layoutVersion := 1, digest := (bytes [38, 231, 53, 187, 224, 246, 213, 166, 78, 7, 224, 254, 26, 197, 116, 58, 136, 205, 199, 178, 210, 236, 143, 152, 88, 33, 241, 43, 139, 71, 34, 34]) }, logicalIndex := 4, digest := (bytes [134, 231, 36, 52, 152, 177, 79, 63, 101, 35, 240, 7, 92, 211, 35, 84, 95, 191, 215, 105, 71, 78, 227, 207, 117, 75, 162, 201, 133, 146, 46, 124]) }, valueDigest := (bytes [165, 143, 117, 124, 98, 216, 43, 245, 92, 103, 136, 142, 3, 92, 67, 240, 138, 159, 178, 24, 11, 218, 214, 110, 198, 21, 25, 196, 82, 25, 2, 133]), digest := (bytes [116, 201, 81, 202, 167, 10, 37, 113, 175, 222, 108, 139, 18, 87, 42, 29, 182, 193, 235, 138, 100, 117, 79, 255, 4, 80, 86, 64, 78, 73, 27, 112]) }), firstWrite := (some { id := { object := { familyTag := 3, commitmentDigest := (bytes [137, 199, 173, 82, 220, 177, 140, 174, 117, 84, 55, 76, 112, 11, 52, 194, 27, 179, 9, 47, 97, 90, 135, 74, 33, 241, 31, 53, 168, 171, 207, 179]), layoutVersion := 1, digest := (bytes [164, 225, 241, 247, 69, 126, 245, 247, 22, 103, 43, 251, 227, 33, 41, 222, 216, 72, 70, 245, 40, 92, 0, 55, 212, 159, 142, 43, 1, 80, 83, 4]) }, logicalIndex := 0, digest := (bytes [220, 14, 132, 199, 21, 152, 210, 30, 87, 17, 148, 24, 228, 126, 106, 90, 32, 40, 88, 147, 113, 253, 52, 218, 248, 3, 235, 120, 193, 14, 241, 120]) }, valueDigest := (bytes [181, 236, 6, 74, 214, 252, 67, 169, 42, 97, 4, 8, 133, 0, 2, 195, 115, 29, 129, 127, 223, 147, 85, 134, 37, 177, 71, 81, 159, 146, 46, 195]), digest := (bytes [222, 40, 126, 193, 120, 143, 37, 172, 98, 247, 201, 205, 2, 15, 8, 230, 100, 42, 76, 184, 44, 68, 216, 82, 204, 62, 221, 93, 193, 168, 173, 106]) }), lastWrite := (some { id := { object := { familyTag := 3, commitmentDigest := (bytes [137, 199, 173, 82, 220, 177, 140, 174, 117, 84, 55, 76, 112, 11, 52, 194, 27, 179, 9, 47, 97, 90, 135, 74, 33, 241, 31, 53, 168, 171, 207, 179]), layoutVersion := 1, digest := (bytes [164, 225, 241, 247, 69, 126, 245, 247, 22, 103, 43, 251, 227, 33, 41, 222, 216, 72, 70, 245, 40, 92, 0, 55, 212, 159, 142, 43, 1, 80, 83, 4]) }, logicalIndex := 2, digest := (bytes [22, 74, 129, 100, 55, 8, 3, 84, 76, 186, 95, 5, 183, 3, 219, 172, 159, 250, 140, 24, 36, 122, 79, 63, 221, 147, 137, 143, 183, 255, 131, 27]) }, valueDigest := (bytes [115, 225, 90, 247, 174, 8, 247, 146, 205, 17, 46, 133, 15, 212, 8, 220, 249, 51, 82, 118, 118, 29, 15, 34, 61, 13, 240, 240, 175, 190, 206, 34]), digest := (bytes [20, 17, 28, 11, 103, 14, 185, 23, 142, 253, 103, 165, 47, 242, 121, 138, 30, 87, 10, 143, 166, 67, 198, 10, 229, 116, 46, 44, 37, 133, 50, 194]) }), firstRam := none, lastRam := none, firstTwist := (some { id := { object := { familyTag := 5, commitmentDigest := (bytes [119, 33, 131, 78, 183, 142, 67, 89, 155, 225, 28, 111, 63, 22, 114, 83, 222, 50, 135, 197, 77, 196, 177, 201, 140, 250, 196, 80, 65, 136, 230, 139]), layoutVersion := 1, digest := (bytes [232, 142, 170, 24, 81, 103, 34, 68, 226, 146, 156, 146, 224, 52, 30, 33, 192, 95, 153, 155, 105, 27, 128, 60, 61, 96, 213, 252, 92, 236, 236, 207]) }, logicalIndex := 0, digest := (bytes [86, 33, 122, 83, 77, 51, 101, 1, 75, 221, 251, 195, 239, 193, 111, 212, 31, 209, 68, 210, 194, 123, 92, 53, 80, 151, 44, 148, 182, 165, 26, 90]) }, valueDigest := (bytes [121, 93, 166, 145, 53, 60, 109, 229, 112, 103, 78, 191, 4, 233, 65, 65, 0, 12, 229, 233, 178, 163, 199, 146, 129, 18, 75, 240, 135, 61, 148, 255]), digest := (bytes [129, 137, 64, 11, 249, 64, 16, 250, 34, 57, 103, 197, 146, 204, 199, 26, 252, 14, 70, 1, 237, 205, 169, 132, 211, 90, 113, 157, 26, 68, 204, 143]) }), lastTwist := (some { id := { object := { familyTag := 5, commitmentDigest := (bytes [119, 33, 131, 78, 183, 142, 67, 89, 155, 225, 28, 111, 63, 22, 114, 83, 222, 50, 135, 197, 77, 196, 177, 201, 140, 250, 196, 80, 65, 136, 230, 139]), layoutVersion := 1, digest := (bytes [232, 142, 170, 24, 81, 103, 34, 68, 226, 146, 156, 146, 224, 52, 30, 33, 192, 95, 153, 155, 105, 27, 128, 60, 61, 96, 213, 252, 92, 236, 236, 207]) }, logicalIndex := 4, digest := (bytes [118, 110, 70, 71, 227, 238, 228, 6, 96, 52, 160, 245, 158, 108, 41, 54, 198, 228, 176, 249, 100, 67, 190, 85, 12, 142, 60, 133, 132, 212, 147, 230]) }, valueDigest := (bytes [222, 14, 37, 177, 188, 230, 71, 93, 144, 22, 98, 93, 2, 239, 167, 13, 4, 68, 129, 81, 87, 184, 54, 32, 144, 210, 18, 143, 160, 134, 36, 170]), digest := (bytes [153, 102, 35, 0, 236, 143, 5, 72, 136, 121, 69, 34, 93, 230, 109, 50, 58, 68, 75, 2, 155, 35, 240, 79, 87, 21, 139, 209, 27, 98, 189, 185]) }) }, digest := (bytes [6, 82, 203, 234, 167, 221, 49, 150, 255, 139, 68, 8, 17, 147, 88, 252, 223, 139, 44, 62, 130, 100, 110, 110, 40, 64, 232, 151, 229, 182, 135, 16]) }, packaged := { statementDigest := (bytes [41, 166, 134, 67, 195, 227, 191, 145, 227, 6, 101, 96, 148, 139, 65, 151, 207, 228, 183, 252, 32, 140, 155, 70, 113, 89, 249, 201, 206, 58, 227, 76]), proofDigest := (bytes [135, 15, 38, 3, 92, 109, 229, 7, 159, 124, 19, 222, 178, 159, 150, 14, 228, 231, 217, 232, 98, 184, 42, 41, 167, 139, 127, 3, 242, 59, 225, 91]) }, digest := (bytes [37, 94, 113, 29, 240, 252, 1, 117, 129, 118, 152, 38, 195, 246, 181, 190, 9, 22, 141, 60, 125, 132, 251, 163, 174, 191, 143, 232, 209, 92, 15, 246]) }
    , digest := (bytes [165, 217, 172, 12, 28, 98, 22, 76, 85, 192, 200, 81, 234, 179, 85, 141, 211, 42, 242, 191, 239, 145, 163, 0, 37, 191, 78, 101, 86, 0, 128, 178])
  }

def stage3Continuity : List ContinuityEventView :=
  [{ stepIndex := 0, pc := 0, nextPc := 4, successorPc := (some 4), finalStep := false, continuityHolds := true }, { stepIndex := 1, pc := 4, nextPc := 8, successorPc := (some 8), finalStep := false, continuityHolds := true }, { stepIndex := 2, pc := 8, nextPc := 12, successorPc := (some 12), finalStep := false, continuityHolds := true }, { stepIndex := 3, pc := 12, nextPc := 16, successorPc := (some 16), finalStep := false, continuityHolds := true }, { stepIndex := 4, pc := 16, nextPc := 20, successorPc := none, finalStep := true, continuityHolds := true }]

def stage3 : Stage3ProofBundleView :=
  {
    continuity := stage3Continuity
    , halted := true
    , bridgeDigest := (bytes [108, 122, 228, 150, 225, 104, 207, 4, 223, 64, 63, 38, 40, 135, 54, 145, 245, 148, 210, 198, 252, 37, 140, 223, 104, 6, 11, 236, 117, 121, 222, 177])
    , semantics := { continuityDigest := (bytes [113, 144, 165, 117, 2, 23, 60, 214, 235, 214, 31, 246, 32, 212, 211, 7, 206, 201, 156, 63, 29, 37, 105, 63, 79, 95, 223, 52, 30, 184, 74, 89]), rootSemanticRowsDigest := (bytes [39, 183, 193, 165, 5, 121, 15, 179, 204, 215, 34, 223, 226, 239, 90, 220, 214, 130, 202, 79, 196, 25, 133, 201, 97, 236, 200, 198, 94, 225, 195, 19]), rowChunkRoutesDigest := (bytes [17, 91, 99, 15, 11, 236, 55, 95, 29, 64, 142, 221, 223, 108, 122, 237, 32, 185, 12, 250, 217, 143, 221, 95, 118, 207, 92, 60, 104, 225, 196, 181]), preparedStepBindingsDigest := (bytes [92, 181, 55, 62, 187, 26, 5, 222, 206, 92, 93, 243, 238, 48, 28, 35, 255, 239, 240, 213, 119, 134, 33, 37, 100, 69, 212, 13, 101, 131, 205, 238]), stage2TemporalDigest := (bytes [210, 76, 209, 6, 58, 62, 223, 200, 191, 221, 252, 176, 5, 38, 163, 26, 122, 200, 135, 22, 173, 116, 239, 249, 94, 24, 149, 127, 123, 156, 4, 249]), initialPc := 0, finalPc := 20, realRowCount := 5, firstRealStepIndex := 0, lastRealStepIndex := 4, digest := (bytes [60, 126, 174, 225, 49, 136, 70, 138, 227, 48, 150, 3, 87, 179, 83, 128, 49, 109, 42, 1, 243, 218, 34, 124, 159, 70, 254, 42, 218, 122, 125, 244]) }
    , linkageDigest := (bytes [19, 29, 111, 134, 53, 182, 25, 75, 21, 246, 18, 244, 175, 76, 57, 43, 60, 159, 17, 93, 20, 23, 25, 229, 163, 206, 146, 28, 43, 219, 80, 127])
    , selectedOpening := { claim := { continuityFamilyDigest := (bytes [180, 21, 202, 67, 212, 116, 149, 242, 73, 2, 254, 74, 208, 185, 115, 209, 229, 157, 227, 181, 78, 244, 25, 29, 82, 77, 170, 252, 145, 102, 124, 182]), continuityCount := 5, finalStepCount := 1, halted := true, allContinuityHold := true, continuityMix := 21093517096960194, points := { firstContinuity := (some { id := { object := { familyTag := 6, commitmentDigest := (bytes [180, 21, 202, 67, 212, 116, 149, 242, 73, 2, 254, 74, 208, 185, 115, 209, 229, 157, 227, 181, 78, 244, 25, 29, 82, 77, 170, 252, 145, 102, 124, 182]), layoutVersion := 1, digest := (bytes [197, 249, 85, 212, 218, 101, 152, 186, 19, 30, 36, 185, 152, 165, 209, 83, 127, 197, 28, 107, 221, 36, 65, 234, 79, 144, 20, 55, 123, 91, 148, 38]) }, logicalIndex := 0, digest := (bytes [135, 2, 138, 56, 98, 95, 181, 59, 112, 48, 52, 204, 46, 180, 117, 79, 81, 155, 36, 255, 244, 98, 41, 249, 179, 137, 245, 2, 152, 230, 83, 35]) }, valueDigest := (bytes [7, 131, 85, 21, 57, 109, 53, 31, 137, 53, 98, 18, 170, 36, 28, 200, 149, 213, 171, 159, 119, 200, 36, 230, 30, 35, 30, 11, 252, 126, 240, 63]), digest := (bytes [225, 52, 168, 222, 40, 147, 187, 132, 92, 200, 35, 10, 97, 76, 58, 203, 54, 182, 172, 214, 174, 127, 114, 107, 246, 49, 116, 83, 102, 231, 50, 247]) }), lastContinuity := (some { id := { object := { familyTag := 6, commitmentDigest := (bytes [180, 21, 202, 67, 212, 116, 149, 242, 73, 2, 254, 74, 208, 185, 115, 209, 229, 157, 227, 181, 78, 244, 25, 29, 82, 77, 170, 252, 145, 102, 124, 182]), layoutVersion := 1, digest := (bytes [197, 249, 85, 212, 218, 101, 152, 186, 19, 30, 36, 185, 152, 165, 209, 83, 127, 197, 28, 107, 221, 36, 65, 234, 79, 144, 20, 55, 123, 91, 148, 38]) }, logicalIndex := 4, digest := (bytes [59, 120, 172, 250, 102, 117, 237, 222, 163, 236, 2, 151, 147, 71, 229, 87, 204, 46, 208, 175, 16, 115, 154, 231, 8, 218, 118, 159, 106, 155, 179, 177]) }, valueDigest := (bytes [78, 141, 235, 113, 13, 200, 242, 233, 5, 141, 141, 77, 19, 78, 184, 2, 187, 100, 140, 5, 110, 219, 176, 65, 169, 115, 213, 24, 209, 59, 174, 122]), digest := (bytes [32, 72, 38, 207, 217, 2, 6, 111, 100, 238, 67, 192, 170, 240, 177, 100, 84, 19, 190, 114, 176, 150, 214, 214, 239, 213, 82, 176, 88, 198, 114, 246]) }) }, digest := (bytes [255, 173, 209, 123, 9, 105, 110, 90, 161, 197, 229, 51, 210, 135, 102, 103, 27, 92, 114, 37, 0, 228, 198, 119, 93, 249, 149, 172, 178, 92, 99, 38]) }, packaged := { statementDigest := (bytes [100, 79, 246, 88, 216, 94, 126, 97, 85, 7, 45, 209, 27, 228, 62, 141, 115, 124, 80, 168, 65, 226, 184, 180, 203, 181, 45, 204, 219, 18, 31, 215]), proofDigest := (bytes [153, 173, 91, 169, 75, 145, 209, 134, 186, 182, 70, 10, 249, 112, 66, 125, 227, 202, 98, 206, 72, 3, 227, 69, 41, 193, 72, 200, 87, 191, 234, 53]) }, digest := (bytes [163, 214, 90, 194, 31, 195, 144, 247, 188, 40, 184, 220, 245, 220, 120, 52, 58, 117, 168, 107, 9, 244, 144, 83, 137, 120, 106, 124, 255, 57, 170, 64]) }
    , digest := (bytes [25, 25, 6, 208, 239, 138, 240, 97, 223, 12, 6, 9, 40, 34, 11, 94, 237, 38, 238, 154, 112, 224, 168, 126, 28, 194, 52, 51, 164, 224, 8, 9])
  }

def rootExecutionExecutionRows : List ExpandedRowView :=
  [{
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

def rootExecutionSemanticRows : List RootSemanticRowView :=
  [{ traceIndex := 0, values := [1, 0, 0, 4, 0, 0, 0, 0, 0, 7, 0, 7, 0, 7, 0, 4, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [219, 8, 51, 136, 6, 165, 64, 201, 92, 219, 214, 171, 112, 211, 82, 38, 105, 118, 212, 115, 167, 239, 36, 209, 63, 108, 13, 59, 134, 234, 32, 123]), digest := (bytes [159, 162, 7, 252, 252, 89, 84, 29, 217, 87, 149, 218, 27, 19, 166, 108, 180, 214, 56, 68, 253, 119, 171, 131, 52, 68, 106, 204, 82, 204, 180, 60]) }, { traceIndex := 1, values := [1, 4, 0, 8, 0, 7, 0, 0, 0, 16, 0, 9, 0, 16, 0, 8, 0, 0, 0, 0, 0, 0, 0, 2, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [242, 68, 53, 66, 57, 111, 27, 168, 121, 29, 176, 200, 143, 132, 134, 68, 99, 22, 88, 194, 57, 35, 248, 76, 199, 202, 223, 48, 90, 133, 227, 214]), digest := (bytes [47, 233, 70, 4, 78, 246, 76, 12, 20, 125, 172, 106, 241, 246, 32, 207, 194, 5, 89, 135, 120, 15, 247, 196, 25, 244, 175, 193, 241, 245, 169, 237]) }, { traceIndex := 2, values := [1, 8, 0, 12, 0, 16, 0, 7, 0, 23, 0, 0, 0, 23, 0, 12, 0, 0, 0, 0, 0, 0, 0, 3, 2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1], rowDigest := (bytes [78, 89, 120, 217, 111, 112, 212, 241, 65, 136, 195, 255, 77, 125, 149, 15, 55, 149, 113, 197, 78, 202, 167, 111, 151, 101, 41, 147, 233, 236, 68, 47]), digest := (bytes [167, 122, 0, 24, 192, 29, 82, 226, 97, 254, 125, 253, 192, 241, 22, 247, 10, 229, 18, 13, 197, 199, 185, 214, 77, 250, 6, 171, 232, 198, 219, 161]) }, { traceIndex := 3, values := [1, 12, 0, 16, 0, 23, 0, 0, 0, 0, 0, 5, 0, 28, 0, 16, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [243, 181, 95, 56, 57, 83, 32, 240, 118, 231, 199, 35, 61, 197, 43, 129, 108, 230, 14, 28, 254, 137, 208, 94, 15, 140, 165, 235, 139, 104, 49, 7]), digest := (bytes [56, 99, 92, 99, 19, 66, 38, 203, 30, 172, 103, 155, 1, 178, 252, 168, 109, 210, 236, 196, 157, 151, 30, 54, 45, 57, 28, 182, 175, 241, 201, 124]) }, { traceIndex := 4, values := [1, 16, 0, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [247, 8, 91, 86, 174, 60, 198, 248, 80, 76, 136, 253, 192, 49, 138, 233, 64, 183, 153, 201, 60, 173, 121, 212, 113, 120, 175, 228, 9, 127, 13, 255]), digest := (bytes [240, 235, 255, 76, 153, 52, 106, 255, 177, 158, 252, 199, 149, 118, 183, 94, 220, 38, 144, 227, 121, 141, 204, 78, 177, 0, 122, 124, 105, 74, 208, 125]) }]

def rootExecutionPreparedBindings : List PreparedStepBindingView :=
  [{ traceIndex := 0, rowDigest := (bytes [219, 8, 51, 136, 6, 165, 64, 201, 92, 219, 214, 171, 112, 211, 82, 38, 105, 118, 212, 115, 167, 239, 36, 209, 63, 108, 13, 59, 134, 234, 32, 123]), rowOpeningDigest := (bytes [26, 245, 8, 48, 96, 7, 195, 10, 204, 117, 177, 191, 22, 245, 165, 113, 221, 231, 165, 207, 236, 31, 126, 45, 3, 126, 148, 184, 64, 60, 148, 195]), digest := (bytes [210, 57, 138, 31, 250, 209, 87, 15, 98, 106, 132, 194, 155, 36, 210, 174, 27, 135, 69, 213, 137, 89, 28, 152, 114, 242, 148, 64, 65, 189, 200, 58]) }, { traceIndex := 1, rowDigest := (bytes [242, 68, 53, 66, 57, 111, 27, 168, 121, 29, 176, 200, 143, 132, 134, 68, 99, 22, 88, 194, 57, 35, 248, 76, 199, 202, 223, 48, 90, 133, 227, 214]), rowOpeningDigest := (bytes [78, 95, 44, 159, 149, 128, 145, 68, 205, 29, 19, 86, 61, 132, 199, 15, 191, 110, 243, 208, 93, 190, 69, 196, 15, 29, 205, 182, 179, 203, 196, 18]), digest := (bytes [25, 182, 26, 43, 157, 163, 180, 129, 134, 44, 22, 253, 53, 148, 251, 70, 159, 84, 217, 255, 160, 250, 185, 95, 15, 236, 18, 199, 53, 88, 76, 142]) }, { traceIndex := 2, rowDigest := (bytes [78, 89, 120, 217, 111, 112, 212, 241, 65, 136, 195, 255, 77, 125, 149, 15, 55, 149, 113, 197, 78, 202, 167, 111, 151, 101, 41, 147, 233, 236, 68, 47]), rowOpeningDigest := (bytes [187, 207, 237, 158, 47, 134, 211, 58, 80, 250, 37, 230, 206, 39, 160, 242, 46, 238, 77, 114, 146, 246, 143, 61, 104, 31, 131, 87, 106, 81, 8, 176]), digest := (bytes [134, 126, 193, 128, 70, 67, 36, 45, 135, 67, 47, 10, 215, 236, 67, 41, 99, 110, 55, 196, 150, 35, 247, 79, 132, 111, 90, 244, 60, 108, 181, 64]) }, { traceIndex := 3, rowDigest := (bytes [243, 181, 95, 56, 57, 83, 32, 240, 118, 231, 199, 35, 61, 197, 43, 129, 108, 230, 14, 28, 254, 137, 208, 94, 15, 140, 165, 235, 139, 104, 49, 7]), rowOpeningDigest := (bytes [188, 5, 190, 218, 97, 208, 37, 116, 105, 71, 25, 191, 163, 7, 195, 61, 80, 7, 125, 10, 19, 156, 45, 3, 170, 248, 13, 225, 116, 98, 19, 19]), digest := (bytes [68, 154, 59, 86, 90, 194, 193, 126, 76, 127, 105, 118, 78, 170, 122, 161, 133, 42, 188, 94, 35, 159, 61, 103, 92, 145, 189, 198, 105, 235, 222, 206]) }, { traceIndex := 4, rowDigest := (bytes [247, 8, 91, 86, 174, 60, 198, 248, 80, 76, 136, 253, 192, 49, 138, 233, 64, 183, 153, 201, 60, 173, 121, 212, 113, 120, 175, 228, 9, 127, 13, 255]), rowOpeningDigest := (bytes [192, 110, 242, 237, 142, 80, 143, 141, 49, 184, 241, 224, 64, 5, 40, 86, 227, 115, 16, 125, 243, 95, 140, 192, 131, 152, 202, 227, 61, 206, 5, 157]), digest := (bytes [55, 215, 43, 161, 102, 58, 94, 235, 254, 110, 43, 252, 137, 128, 118, 79, 3, 90, 208, 135, 125, 233, 113, 110, 141, 69, 220, 22, 255, 129, 201, 119]) }]

def rootExecutionRowChunkRoutes : List RowChunkRouteView :=
  [{ logicalIndex := 0, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 0, digest := (bytes [138, 198, 109, 126, 144, 82, 221, 43, 248, 202, 137, 103, 62, 226, 249, 152, 163, 187, 1, 254, 36, 33, 59, 16, 64, 166, 202, 8, 219, 57, 240, 59]) }, { logicalIndex := 1, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 1, digest := (bytes [44, 177, 82, 41, 218, 60, 100, 208, 26, 31, 151, 113, 109, 148, 57, 12, 223, 21, 76, 221, 70, 245, 191, 105, 57, 199, 8, 128, 181, 145, 89, 99]) }, { logicalIndex := 2, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 2, digest := (bytes [252, 248, 65, 24, 81, 241, 150, 170, 250, 116, 222, 30, 134, 191, 78, 195, 104, 119, 225, 210, 243, 186, 212, 107, 183, 31, 243, 201, 101, 148, 32, 72]) }, { logicalIndex := 3, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 3, digest := (bytes [244, 11, 162, 13, 59, 43, 232, 47, 228, 2, 70, 126, 95, 10, 57, 40, 46, 107, 197, 81, 97, 39, 185, 163, 93, 60, 5, 66, 7, 231, 199, 134]) }, { logicalIndex := 4, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 4, digest := (bytes [98, 247, 204, 83, 252, 219, 248, 73, 49, 206, 229, 79, 169, 242, 28, 56, 7, 100, 18, 197, 133, 200, 133, 20, 161, 230, 126, 175, 98, 0, 158, 25]) }]

def rootExecutionRowLocalCcsAcceptance : List RootRowLocalCcsAcceptanceView :=
  [{ traceIndex := 0, logicalIndex := 0, rowDigest := (bytes [219, 8, 51, 136, 6, 165, 64, 201, 92, 219, 214, 171, 112, 211, 82, 38, 105, 118, 212, 115, 167, 239, 36, 209, 63, 108, 13, 59, 134, 234, 32, 123]), rowOpeningDigest := (bytes [26, 245, 8, 48, 96, 7, 195, 10, 204, 117, 177, 191, 22, 245, 165, 113, 221, 231, 165, 207, 236, 31, 126, 45, 3, 126, 148, 184, 64, 60, 148, 195]), preparedStepBindingDigest := (bytes [210, 57, 138, 31, 250, 209, 87, 15, 98, 106, 132, 194, 155, 36, 210, 174, 27, 135, 69, 213, 137, 89, 28, 152, 114, 242, 148, 64, 65, 189, 200, 58]), rowChunkRouteDigest := (bytes [138, 198, 109, 126, 144, 82, 221, 43, 248, 202, 137, 103, 62, 226, 249, 152, 163, 187, 1, 254, 36, 33, 59, 16, 64, 166, 202, 8, 219, 57, 240, 59]), publicStepDigest := (bytes [61, 169, 56, 156, 131, 159, 56, 164, 115, 44, 241, 14, 93, 234, 213, 120, 35, 99, 220, 15, 105, 199, 247, 143, 68, 76, 183, 139, 46, 209, 208, 214]), digest := (bytes [13, 187, 242, 27, 161, 56, 4, 162, 236, 138, 44, 47, 161, 195, 219, 141, 111, 44, 138, 188, 138, 173, 208, 120, 13, 232, 24, 216, 248, 85, 232, 65]) }, { traceIndex := 1, logicalIndex := 1, rowDigest := (bytes [242, 68, 53, 66, 57, 111, 27, 168, 121, 29, 176, 200, 143, 132, 134, 68, 99, 22, 88, 194, 57, 35, 248, 76, 199, 202, 223, 48, 90, 133, 227, 214]), rowOpeningDigest := (bytes [78, 95, 44, 159, 149, 128, 145, 68, 205, 29, 19, 86, 61, 132, 199, 15, 191, 110, 243, 208, 93, 190, 69, 196, 15, 29, 205, 182, 179, 203, 196, 18]), preparedStepBindingDigest := (bytes [25, 182, 26, 43, 157, 163, 180, 129, 134, 44, 22, 253, 53, 148, 251, 70, 159, 84, 217, 255, 160, 250, 185, 95, 15, 236, 18, 199, 53, 88, 76, 142]), rowChunkRouteDigest := (bytes [44, 177, 82, 41, 218, 60, 100, 208, 26, 31, 151, 113, 109, 148, 57, 12, 223, 21, 76, 221, 70, 245, 191, 105, 57, 199, 8, 128, 181, 145, 89, 99]), publicStepDigest := (bytes [146, 231, 253, 159, 178, 255, 159, 106, 248, 212, 150, 113, 82, 137, 163, 9, 227, 139, 25, 158, 126, 250, 174, 172, 242, 161, 22, 220, 55, 175, 6, 254]), digest := (bytes [99, 97, 99, 109, 190, 208, 28, 75, 188, 255, 135, 102, 86, 113, 234, 129, 163, 221, 222, 9, 38, 71, 195, 185, 17, 246, 21, 198, 230, 119, 174, 84]) }, { traceIndex := 2, logicalIndex := 2, rowDigest := (bytes [78, 89, 120, 217, 111, 112, 212, 241, 65, 136, 195, 255, 77, 125, 149, 15, 55, 149, 113, 197, 78, 202, 167, 111, 151, 101, 41, 147, 233, 236, 68, 47]), rowOpeningDigest := (bytes [187, 207, 237, 158, 47, 134, 211, 58, 80, 250, 37, 230, 206, 39, 160, 242, 46, 238, 77, 114, 146, 246, 143, 61, 104, 31, 131, 87, 106, 81, 8, 176]), preparedStepBindingDigest := (bytes [134, 126, 193, 128, 70, 67, 36, 45, 135, 67, 47, 10, 215, 236, 67, 41, 99, 110, 55, 196, 150, 35, 247, 79, 132, 111, 90, 244, 60, 108, 181, 64]), rowChunkRouteDigest := (bytes [252, 248, 65, 24, 81, 241, 150, 170, 250, 116, 222, 30, 134, 191, 78, 195, 104, 119, 225, 210, 243, 186, 212, 107, 183, 31, 243, 201, 101, 148, 32, 72]), publicStepDigest := (bytes [159, 221, 102, 167, 120, 32, 15, 132, 194, 219, 219, 73, 248, 176, 96, 85, 211, 139, 253, 80, 245, 215, 221, 12, 36, 122, 108, 122, 147, 201, 130, 232]), digest := (bytes [34, 61, 52, 196, 133, 249, 3, 251, 63, 221, 170, 221, 35, 90, 169, 152, 137, 36, 9, 207, 198, 79, 255, 57, 85, 21, 213, 159, 230, 85, 32, 84]) }, { traceIndex := 3, logicalIndex := 3, rowDigest := (bytes [243, 181, 95, 56, 57, 83, 32, 240, 118, 231, 199, 35, 61, 197, 43, 129, 108, 230, 14, 28, 254, 137, 208, 94, 15, 140, 165, 235, 139, 104, 49, 7]), rowOpeningDigest := (bytes [188, 5, 190, 218, 97, 208, 37, 116, 105, 71, 25, 191, 163, 7, 195, 61, 80, 7, 125, 10, 19, 156, 45, 3, 170, 248, 13, 225, 116, 98, 19, 19]), preparedStepBindingDigest := (bytes [68, 154, 59, 86, 90, 194, 193, 126, 76, 127, 105, 118, 78, 170, 122, 161, 133, 42, 188, 94, 35, 159, 61, 103, 92, 145, 189, 198, 105, 235, 222, 206]), rowChunkRouteDigest := (bytes [244, 11, 162, 13, 59, 43, 232, 47, 228, 2, 70, 126, 95, 10, 57, 40, 46, 107, 197, 81, 97, 39, 185, 163, 93, 60, 5, 66, 7, 231, 199, 134]), publicStepDigest := (bytes [204, 40, 200, 6, 99, 227, 56, 83, 116, 60, 110, 58, 254, 106, 148, 230, 153, 46, 47, 10, 131, 217, 238, 228, 24, 9, 194, 107, 250, 228, 108, 140]), digest := (bytes [219, 215, 116, 14, 195, 165, 67, 100, 216, 37, 123, 160, 89, 119, 29, 232, 211, 24, 210, 159, 181, 169, 196, 80, 210, 27, 126, 176, 12, 226, 200, 98]) }, { traceIndex := 4, logicalIndex := 4, rowDigest := (bytes [247, 8, 91, 86, 174, 60, 198, 248, 80, 76, 136, 253, 192, 49, 138, 233, 64, 183, 153, 201, 60, 173, 121, 212, 113, 120, 175, 228, 9, 127, 13, 255]), rowOpeningDigest := (bytes [192, 110, 242, 237, 142, 80, 143, 141, 49, 184, 241, 224, 64, 5, 40, 86, 227, 115, 16, 125, 243, 95, 140, 192, 131, 152, 202, 227, 61, 206, 5, 157]), preparedStepBindingDigest := (bytes [55, 215, 43, 161, 102, 58, 94, 235, 254, 110, 43, 252, 137, 128, 118, 79, 3, 90, 208, 135, 125, 233, 113, 110, 141, 69, 220, 22, 255, 129, 201, 119]), rowChunkRouteDigest := (bytes [98, 247, 204, 83, 252, 219, 248, 73, 49, 206, 229, 79, 169, 242, 28, 56, 7, 100, 18, 197, 133, 200, 133, 20, 161, 230, 126, 175, 98, 0, 158, 25]), publicStepDigest := (bytes [72, 142, 192, 218, 173, 197, 55, 221, 78, 31, 126, 194, 22, 139, 72, 204, 128, 208, 103, 242, 122, 221, 175, 246, 50, 244, 221, 89, 210, 23, 111, 183]), digest := (bytes [220, 252, 116, 138, 71, 12, 86, 53, 146, 181, 128, 23, 48, 181, 191, 93, 185, 194, 113, 251, 7, 184, 139, 7, 57, 13, 199, 228, 22, 112, 46, 168]) }]

def rootExecutionExecutionSemanticsRefinement : List RootExecutionSemanticsRefinementView :=
  [{ traceIndex := 0, logicalIndex := 0, semanticRowDigest := (bytes [159, 162, 7, 252, 252, 89, 84, 29, 217, 87, 149, 218, 27, 19, 166, 108, 180, 214, 56, 68, 253, 119, 171, 131, 52, 68, 106, 204, 82, 204, 180, 60]), rowLocalCcsAcceptanceDigest := (bytes [13, 187, 242, 27, 161, 56, 4, 162, 236, 138, 44, 47, 161, 195, 219, 141, 111, 44, 138, 188, 138, 173, 208, 120, 13, 232, 24, 216, 248, 85, 232, 65]), preparedStepBindingDigest := (bytes [210, 57, 138, 31, 250, 209, 87, 15, 98, 106, 132, 194, 155, 36, 210, 174, 27, 135, 69, 213, 137, 89, 28, 152, 114, 242, 148, 64, 65, 189, 200, 58]), publicStepDigest := (bytes [61, 169, 56, 156, 131, 159, 56, 164, 115, 44, 241, 14, 93, 234, 213, 120, 35, 99, 220, 15, 105, 199, 247, 143, 68, 76, 183, 139, 46, 209, 208, 214]), digest := (bytes [188, 237, 227, 51, 17, 83, 69, 85, 231, 205, 241, 215, 167, 224, 210, 201, 123, 100, 80, 172, 60, 128, 16, 87, 245, 42, 223, 225, 23, 155, 11, 254]) }, { traceIndex := 1, logicalIndex := 1, semanticRowDigest := (bytes [47, 233, 70, 4, 78, 246, 76, 12, 20, 125, 172, 106, 241, 246, 32, 207, 194, 5, 89, 135, 120, 15, 247, 196, 25, 244, 175, 193, 241, 245, 169, 237]), rowLocalCcsAcceptanceDigest := (bytes [99, 97, 99, 109, 190, 208, 28, 75, 188, 255, 135, 102, 86, 113, 234, 129, 163, 221, 222, 9, 38, 71, 195, 185, 17, 246, 21, 198, 230, 119, 174, 84]), preparedStepBindingDigest := (bytes [25, 182, 26, 43, 157, 163, 180, 129, 134, 44, 22, 253, 53, 148, 251, 70, 159, 84, 217, 255, 160, 250, 185, 95, 15, 236, 18, 199, 53, 88, 76, 142]), publicStepDigest := (bytes [146, 231, 253, 159, 178, 255, 159, 106, 248, 212, 150, 113, 82, 137, 163, 9, 227, 139, 25, 158, 126, 250, 174, 172, 242, 161, 22, 220, 55, 175, 6, 254]), digest := (bytes [83, 231, 197, 46, 36, 58, 245, 157, 233, 244, 241, 104, 56, 174, 250, 214, 214, 38, 198, 138, 206, 221, 74, 213, 253, 82, 238, 84, 22, 160, 85, 37]) }, { traceIndex := 2, logicalIndex := 2, semanticRowDigest := (bytes [167, 122, 0, 24, 192, 29, 82, 226, 97, 254, 125, 253, 192, 241, 22, 247, 10, 229, 18, 13, 197, 199, 185, 214, 77, 250, 6, 171, 232, 198, 219, 161]), rowLocalCcsAcceptanceDigest := (bytes [34, 61, 52, 196, 133, 249, 3, 251, 63, 221, 170, 221, 35, 90, 169, 152, 137, 36, 9, 207, 198, 79, 255, 57, 85, 21, 213, 159, 230, 85, 32, 84]), preparedStepBindingDigest := (bytes [134, 126, 193, 128, 70, 67, 36, 45, 135, 67, 47, 10, 215, 236, 67, 41, 99, 110, 55, 196, 150, 35, 247, 79, 132, 111, 90, 244, 60, 108, 181, 64]), publicStepDigest := (bytes [159, 221, 102, 167, 120, 32, 15, 132, 194, 219, 219, 73, 248, 176, 96, 85, 211, 139, 253, 80, 245, 215, 221, 12, 36, 122, 108, 122, 147, 201, 130, 232]), digest := (bytes [218, 229, 188, 31, 39, 40, 157, 119, 192, 74, 255, 56, 122, 207, 122, 200, 84, 56, 240, 11, 163, 86, 42, 241, 195, 220, 155, 106, 78, 214, 82, 91]) }, { traceIndex := 3, logicalIndex := 3, semanticRowDigest := (bytes [56, 99, 92, 99, 19, 66, 38, 203, 30, 172, 103, 155, 1, 178, 252, 168, 109, 210, 236, 196, 157, 151, 30, 54, 45, 57, 28, 182, 175, 241, 201, 124]), rowLocalCcsAcceptanceDigest := (bytes [219, 215, 116, 14, 195, 165, 67, 100, 216, 37, 123, 160, 89, 119, 29, 232, 211, 24, 210, 159, 181, 169, 196, 80, 210, 27, 126, 176, 12, 226, 200, 98]), preparedStepBindingDigest := (bytes [68, 154, 59, 86, 90, 194, 193, 126, 76, 127, 105, 118, 78, 170, 122, 161, 133, 42, 188, 94, 35, 159, 61, 103, 92, 145, 189, 198, 105, 235, 222, 206]), publicStepDigest := (bytes [204, 40, 200, 6, 99, 227, 56, 83, 116, 60, 110, 58, 254, 106, 148, 230, 153, 46, 47, 10, 131, 217, 238, 228, 24, 9, 194, 107, 250, 228, 108, 140]), digest := (bytes [26, 153, 156, 188, 96, 100, 237, 24, 224, 18, 185, 151, 69, 179, 19, 148, 252, 149, 212, 117, 224, 61, 255, 121, 7, 31, 28, 154, 85, 58, 209, 29]) }, { traceIndex := 4, logicalIndex := 4, semanticRowDigest := (bytes [240, 235, 255, 76, 153, 52, 106, 255, 177, 158, 252, 199, 149, 118, 183, 94, 220, 38, 144, 227, 121, 141, 204, 78, 177, 0, 122, 124, 105, 74, 208, 125]), rowLocalCcsAcceptanceDigest := (bytes [220, 252, 116, 138, 71, 12, 86, 53, 146, 181, 128, 23, 48, 181, 191, 93, 185, 194, 113, 251, 7, 184, 139, 7, 57, 13, 199, 228, 22, 112, 46, 168]), preparedStepBindingDigest := (bytes [55, 215, 43, 161, 102, 58, 94, 235, 254, 110, 43, 252, 137, 128, 118, 79, 3, 90, 208, 135, 125, 233, 113, 110, 141, 69, 220, 22, 255, 129, 201, 119]), publicStepDigest := (bytes [72, 142, 192, 218, 173, 197, 55, 221, 78, 31, 126, 194, 22, 139, 72, 204, 128, 208, 103, 242, 122, 221, 175, 246, 50, 244, 221, 89, 210, 23, 111, 183]), digest := (bytes [32, 35, 9, 63, 8, 54, 240, 180, 119, 25, 2, 218, 121, 37, 230, 6, 127, 139, 201, 53, 41, 233, 220, 196, 72, 24, 144, 90, 222, 49, 78, 69]) }]

def rootExecution : RootExecutionBundleView :=
  {
    executionRows := rootExecutionExecutionRows
    , semanticRows := rootExecutionSemanticRows
    , semanticRowsDigest := (bytes [39, 183, 193, 165, 5, 121, 15, 179, 204, 215, 34, 223, 226, 239, 90, 220, 214, 130, 202, 79, 196, 25, 133, 201, 97, 236, 200, 198, 94, 225, 195, 19])
    , preparedStepBindings := { bindings := rootExecutionPreparedBindings, bindingCount := 5, firstBindingDigest := (some (bytes [210, 57, 138, 31, 250, 209, 87, 15, 98, 106, 132, 194, 155, 36, 210, 174, 27, 135, 69, 213, 137, 89, 28, 152, 114, 242, 148, 64, 65, 189, 200, 58])), lastBindingDigest := (some (bytes [55, 215, 43, 161, 102, 58, 94, 235, 254, 110, 43, 252, 137, 128, 118, 79, 3, 90, 208, 135, 125, 233, 113, 110, 141, 69, 220, 22, 255, 129, 201, 119])), digest := (bytes [92, 181, 55, 62, 187, 26, 5, 222, 206, 92, 93, 243, 238, 48, 28, 35, 255, 239, 240, 213, 119, 134, 33, 37, 100, 69, 212, 13, 101, 131, 205, 238]) }
    , rowChunkRoutes := rootExecutionRowChunkRoutes
    , rowChunkRoutesDigest := (bytes [17, 91, 99, 15, 11, 236, 55, 95, 29, 64, 142, 221, 223, 108, 122, 237, 32, 185, 12, 250, 217, 143, 221, 95, 118, 207, 92, 60, 104, 225, 196, 181])
    , rowLocalCcsAcceptance := { acceptances := rootExecutionRowLocalCcsAcceptance, acceptanceCount := 5, firstAcceptanceDigest := (some (bytes [13, 187, 242, 27, 161, 56, 4, 162, 236, 138, 44, 47, 161, 195, 219, 141, 111, 44, 138, 188, 138, 173, 208, 120, 13, 232, 24, 216, 248, 85, 232, 65])), lastAcceptanceDigest := (some (bytes [220, 252, 116, 138, 71, 12, 86, 53, 146, 181, 128, 23, 48, 181, 191, 93, 185, 194, 113, 251, 7, 184, 139, 7, 57, 13, 199, 228, 22, 112, 46, 168])), digest := (bytes [169, 184, 145, 161, 34, 147, 185, 12, 77, 232, 193, 15, 11, 129, 66, 176, 101, 115, 5, 127, 139, 204, 0, 57, 198, 149, 116, 11, 89, 159, 130, 195]) }
    , executionSemanticsRefinement := { refinements := rootExecutionExecutionSemanticsRefinement, refinementCount := 5, firstRefinementDigest := (some (bytes [188, 237, 227, 51, 17, 83, 69, 85, 231, 205, 241, 215, 167, 224, 210, 201, 123, 100, 80, 172, 60, 128, 16, 87, 245, 42, 223, 225, 23, 155, 11, 254])), lastRefinementDigest := (some (bytes [32, 35, 9, 63, 8, 54, 240, 180, 119, 25, 2, 218, 121, 37, 230, 6, 127, 139, 201, 53, 41, 233, 220, 196, 72, 24, 144, 90, 222, 49, 78, 69])), digest := (bytes [53, 240, 124, 209, 4, 14, 170, 124, 194, 65, 204, 227, 143, 199, 32, 66, 210, 69, 42, 240, 231, 107, 92, 62, 4, 137, 93, 144, 184, 151, 69, 162]) }
    , familyDigest := (bytes [45, 71, 203, 160, 194, 189, 1, 30, 95, 127, 177, 249, 43, 213, 108, 119, 112, 254, 97, 173, 156, 157, 66, 135, 77, 15, 188, 231, 137, 105, 9, 110])
    , digest := (bytes [143, 192, 179, 235, 243, 243, 188, 114, 203, 164, 14, 86, 85, 220, 56, 62, 134, 31, 42, 193, 174, 218, 202, 188, 31, 146, 41, 176, 197, 246, 186, 86])
  }

def kernelOpeningBundle : SimpleKernelOpeningBundleView :=
  {
    claim := { bindings := { stageClaimBundleDigest := (bytes [102, 99, 228, 44, 129, 25, 213, 223, 116, 182, 230, 97, 16, 12, 17, 12, 83, 137, 225, 132, 27, 209, 204, 86, 118, 52, 219, 9, 90, 113, 72, 218]), stagePackageBundleDigest := (bytes [255, 64, 206, 73, 236, 62, 214, 128, 180, 109, 50, 226, 84, 153, 196, 85, 181, 225, 201, 75, 54, 234, 81, 219, 235, 95, 242, 43, 66, 213, 30, 179]), stage1PackageDigest := (bytes [132, 174, 232, 78, 241, 78, 76, 182, 143, 159, 220, 145, 105, 244, 181, 164, 64, 221, 241, 6, 171, 5, 207, 117, 108, 144, 154, 73, 15, 132, 167, 178]), stage2PackageDigest := (bytes [37, 94, 113, 29, 240, 252, 1, 117, 129, 118, 152, 38, 195, 246, 181, 190, 9, 22, 141, 60, 125, 132, 251, 163, 174, 191, 143, 232, 209, 92, 15, 246]), stage3PackageDigest := (bytes [163, 214, 90, 194, 31, 195, 144, 247, 188, 40, 184, 220, 245, 220, 120, 52, 58, 117, 168, 107, 9, 244, 144, 83, 137, 120, 106, 124, 255, 57, 170, 64]), preparedStepBindingsDigest := (bytes [92, 181, 55, 62, 187, 26, 5, 222, 206, 92, 93, 243, 238, 48, 28, 35, 255, 239, 240, 213, 119, 134, 33, 37, 100, 69, 212, 13, 101, 131, 205, 238]), bindingCount := 5, stage1RowCount := 5, stage2RegisterReadCount := 5, stage2RegisterWriteCount := 3, stage2RamEventCount := 0, stage3ContinuityCount := 5, points := { firstBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [92, 181, 55, 62, 187, 26, 5, 222, 206, 92, 93, 243, 238, 48, 28, 35, 255, 239, 240, 213, 119, 134, 33, 37, 100, 69, 212, 13, 101, 131, 205, 238]), layoutVersion := 1, digest := (bytes [177, 172, 15, 241, 144, 232, 6, 123, 189, 245, 225, 66, 218, 170, 142, 169, 107, 211, 128, 247, 87, 220, 200, 241, 52, 145, 150, 212, 153, 205, 123, 187]) }, logicalIndex := 0, digest := (bytes [190, 4, 197, 224, 26, 0, 77, 67, 31, 112, 90, 156, 122, 109, 72, 13, 126, 179, 127, 22, 161, 14, 77, 253, 100, 88, 36, 47, 213, 63, 153, 147]) }, valueDigest := (bytes [210, 57, 138, 31, 250, 209, 87, 15, 98, 106, 132, 194, 155, 36, 210, 174, 27, 135, 69, 213, 137, 89, 28, 152, 114, 242, 148, 64, 65, 189, 200, 58]), digest := (bytes [222, 225, 71, 211, 110, 98, 44, 254, 42, 201, 30, 231, 237, 35, 68, 98, 203, 133, 50, 31, 96, 129, 97, 55, 92, 226, 143, 76, 201, 184, 70, 106]) }), lastBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [92, 181, 55, 62, 187, 26, 5, 222, 206, 92, 93, 243, 238, 48, 28, 35, 255, 239, 240, 213, 119, 134, 33, 37, 100, 69, 212, 13, 101, 131, 205, 238]), layoutVersion := 1, digest := (bytes [177, 172, 15, 241, 144, 232, 6, 123, 189, 245, 225, 66, 218, 170, 142, 169, 107, 211, 128, 247, 87, 220, 200, 241, 52, 145, 150, 212, 153, 205, 123, 187]) }, logicalIndex := 4, digest := (bytes [43, 121, 11, 63, 20, 54, 198, 147, 94, 238, 182, 53, 25, 188, 156, 116, 90, 149, 244, 21, 176, 149, 58, 182, 76, 71, 212, 45, 137, 85, 213, 218]) }, valueDigest := (bytes [55, 215, 43, 161, 102, 58, 94, 235, 254, 110, 43, 252, 137, 128, 118, 79, 3, 90, 208, 135, 125, 233, 113, 110, 141, 69, 220, 22, 255, 129, 201, 119]), digest := (bytes [195, 145, 91, 85, 215, 68, 18, 155, 161, 124, 151, 14, 180, 53, 224, 239, 137, 133, 186, 157, 9, 84, 4, 212, 184, 71, 6, 220, 111, 244, 120, 71]) }) }, digest := (bytes [140, 138, 209, 100, 206, 40, 79, 38, 237, 107, 178, 17, 78, 187, 131, 232, 202, 104, 113, 137, 11, 27, 32, 119, 139, 207, 190, 237, 162, 139, 254, 6]) }, preparedSteps := { executionDigest := (bytes [70, 186, 27, 221, 111, 194, 9, 233, 22, 165, 61, 66, 109, 14, 68, 56, 20, 142, 12, 163, 129, 72, 137, 138, 73, 128, 143, 30, 210, 235, 246, 84]), finalStateDigest := (bytes [214, 96, 46, 11, 248, 13, 42, 132, 141, 230, 122, 96, 107, 25, 184, 147, 236, 239, 156, 156, 238, 48, 125, 174, 84, 192, 136, 2, 174, 167, 250, 118]), transcriptFinalDigest := (bytes [136, 204, 167, 75, 151, 108, 16, 255, 16, 185, 218, 191, 68, 240, 50, 151, 48, 10, 175, 78, 253, 43, 200, 70, 235, 238, 182, 242, 224, 164, 60, 127]), preparedStepCount := 5, finalPc := 20, halted := true, points := { firstPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [251, 52, 122, 0, 121, 106, 12, 175, 109, 64, 25, 255, 113, 78, 245, 166, 161, 177, 150, 198, 14, 38, 65, 237, 248, 77, 212, 154, 231, 156, 229, 92]), layoutVersion := 3, digest := (bytes [81, 52, 31, 127, 221, 91, 78, 127, 199, 0, 31, 143, 136, 90, 4, 32, 120, 56, 138, 78, 122, 226, 185, 64, 24, 32, 158, 55, 246, 183, 177, 78]) }, logicalIndex := 0, digest := (bytes [242, 114, 153, 40, 74, 253, 96, 126, 101, 13, 123, 125, 75, 21, 244, 110, 226, 166, 232, 92, 106, 246, 127, 227, 130, 121, 164, 94, 228, 79, 123, 250]) }, valueDigest := (bytes [219, 8, 51, 136, 6, 165, 64, 201, 92, 219, 214, 171, 112, 211, 82, 38, 105, 118, 212, 115, 167, 239, 36, 209, 63, 108, 13, 59, 134, 234, 32, 123]), digest := (bytes [55, 64, 227, 137, 13, 60, 159, 86, 13, 107, 122, 210, 50, 71, 172, 195, 224, 231, 124, 32, 173, 179, 230, 114, 99, 169, 52, 12, 216, 69, 62, 70]) }), lastPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [251, 52, 122, 0, 121, 106, 12, 175, 109, 64, 25, 255, 113, 78, 245, 166, 161, 177, 150, 198, 14, 38, 65, 237, 248, 77, 212, 154, 231, 156, 229, 92]), layoutVersion := 3, digest := (bytes [81, 52, 31, 127, 221, 91, 78, 127, 199, 0, 31, 143, 136, 90, 4, 32, 120, 56, 138, 78, 122, 226, 185, 64, 24, 32, 158, 55, 246, 183, 177, 78]) }, logicalIndex := 4, digest := (bytes [60, 126, 86, 51, 72, 107, 215, 93, 182, 107, 45, 2, 105, 180, 237, 178, 40, 68, 236, 195, 155, 124, 166, 64, 112, 42, 91, 36, 65, 88, 66, 133]) }, valueDigest := (bytes [247, 8, 91, 86, 174, 60, 198, 248, 80, 76, 136, 253, 192, 49, 138, 233, 64, 183, 153, 201, 60, 173, 121, 212, 113, 120, 175, 228, 9, 127, 13, 255]), digest := (bytes [33, 208, 172, 230, 136, 24, 67, 101, 152, 98, 163, 128, 55, 104, 213, 43, 113, 230, 52, 124, 122, 33, 143, 134, 6, 124, 245, 185, 94, 180, 158, 219]) }) }, digest := (bytes [234, 54, 153, 181, 235, 35, 206, 14, 191, 54, 255, 6, 183, 241, 207, 196, 21, 193, 189, 188, 32, 197, 116, 104, 211, 189, 146, 221, 219, 216, 38, 194]) }, digest := (bytes [13, 10, 239, 24, 246, 149, 181, 77, 213, 105, 209, 155, 178, 109, 152, 235, 192, 18, 180, 58, 89, 118, 168, 213, 16, 107, 1, 184, 190, 231, 121, 67]) }
    , bindings := { claim := { stageClaimBundleDigest := (bytes [102, 99, 228, 44, 129, 25, 213, 223, 116, 182, 230, 97, 16, 12, 17, 12, 83, 137, 225, 132, 27, 209, 204, 86, 118, 52, 219, 9, 90, 113, 72, 218]), stagePackageBundleDigest := (bytes [255, 64, 206, 73, 236, 62, 214, 128, 180, 109, 50, 226, 84, 153, 196, 85, 181, 225, 201, 75, 54, 234, 81, 219, 235, 95, 242, 43, 66, 213, 30, 179]), stage1PackageDigest := (bytes [132, 174, 232, 78, 241, 78, 76, 182, 143, 159, 220, 145, 105, 244, 181, 164, 64, 221, 241, 6, 171, 5, 207, 117, 108, 144, 154, 73, 15, 132, 167, 178]), stage2PackageDigest := (bytes [37, 94, 113, 29, 240, 252, 1, 117, 129, 118, 152, 38, 195, 246, 181, 190, 9, 22, 141, 60, 125, 132, 251, 163, 174, 191, 143, 232, 209, 92, 15, 246]), stage3PackageDigest := (bytes [163, 214, 90, 194, 31, 195, 144, 247, 188, 40, 184, 220, 245, 220, 120, 52, 58, 117, 168, 107, 9, 244, 144, 83, 137, 120, 106, 124, 255, 57, 170, 64]), preparedStepBindingsDigest := (bytes [92, 181, 55, 62, 187, 26, 5, 222, 206, 92, 93, 243, 238, 48, 28, 35, 255, 239, 240, 213, 119, 134, 33, 37, 100, 69, 212, 13, 101, 131, 205, 238]), bindingCount := 5, stage1RowCount := 5, stage2RegisterReadCount := 5, stage2RegisterWriteCount := 3, stage2RamEventCount := 0, stage3ContinuityCount := 5, points := { firstBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [92, 181, 55, 62, 187, 26, 5, 222, 206, 92, 93, 243, 238, 48, 28, 35, 255, 239, 240, 213, 119, 134, 33, 37, 100, 69, 212, 13, 101, 131, 205, 238]), layoutVersion := 1, digest := (bytes [177, 172, 15, 241, 144, 232, 6, 123, 189, 245, 225, 66, 218, 170, 142, 169, 107, 211, 128, 247, 87, 220, 200, 241, 52, 145, 150, 212, 153, 205, 123, 187]) }, logicalIndex := 0, digest := (bytes [190, 4, 197, 224, 26, 0, 77, 67, 31, 112, 90, 156, 122, 109, 72, 13, 126, 179, 127, 22, 161, 14, 77, 253, 100, 88, 36, 47, 213, 63, 153, 147]) }, valueDigest := (bytes [210, 57, 138, 31, 250, 209, 87, 15, 98, 106, 132, 194, 155, 36, 210, 174, 27, 135, 69, 213, 137, 89, 28, 152, 114, 242, 148, 64, 65, 189, 200, 58]), digest := (bytes [222, 225, 71, 211, 110, 98, 44, 254, 42, 201, 30, 231, 237, 35, 68, 98, 203, 133, 50, 31, 96, 129, 97, 55, 92, 226, 143, 76, 201, 184, 70, 106]) }), lastBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [92, 181, 55, 62, 187, 26, 5, 222, 206, 92, 93, 243, 238, 48, 28, 35, 255, 239, 240, 213, 119, 134, 33, 37, 100, 69, 212, 13, 101, 131, 205, 238]), layoutVersion := 1, digest := (bytes [177, 172, 15, 241, 144, 232, 6, 123, 189, 245, 225, 66, 218, 170, 142, 169, 107, 211, 128, 247, 87, 220, 200, 241, 52, 145, 150, 212, 153, 205, 123, 187]) }, logicalIndex := 4, digest := (bytes [43, 121, 11, 63, 20, 54, 198, 147, 94, 238, 182, 53, 25, 188, 156, 116, 90, 149, 244, 21, 176, 149, 58, 182, 76, 71, 212, 45, 137, 85, 213, 218]) }, valueDigest := (bytes [55, 215, 43, 161, 102, 58, 94, 235, 254, 110, 43, 252, 137, 128, 118, 79, 3, 90, 208, 135, 125, 233, 113, 110, 141, 69, 220, 22, 255, 129, 201, 119]), digest := (bytes [195, 145, 91, 85, 215, 68, 18, 155, 161, 124, 151, 14, 180, 53, 224, 239, 137, 133, 186, 157, 9, 84, 4, 212, 184, 71, 6, 220, 111, 244, 120, 71]) }) }, digest := (bytes [140, 138, 209, 100, 206, 40, 79, 38, 237, 107, 178, 17, 78, 187, 131, 232, 202, 104, 113, 137, 11, 27, 32, 119, 139, 207, 190, 237, 162, 139, 254, 6]) }, packaged := { statementDigest := (bytes [194, 180, 106, 1, 180, 31, 92, 210, 120, 67, 7, 27, 54, 164, 5, 21, 6, 236, 197, 89, 189, 1, 86, 195, 229, 72, 101, 235, 107, 207, 189, 160]), proofDigest := (bytes [212, 124, 163, 120, 79, 184, 9, 70, 20, 129, 57, 160, 243, 92, 68, 242, 197, 110, 1, 171, 73, 232, 88, 142, 83, 246, 153, 63, 204, 188, 124, 195]) }, digest := (bytes [160, 220, 21, 152, 30, 73, 128, 77, 57, 47, 114, 78, 240, 85, 1, 120, 140, 4, 199, 233, 203, 141, 80, 63, 120, 187, 71, 9, 39, 52, 112, 135]) }
    , preparedSteps := { claim := { executionDigest := (bytes [70, 186, 27, 221, 111, 194, 9, 233, 22, 165, 61, 66, 109, 14, 68, 56, 20, 142, 12, 163, 129, 72, 137, 138, 73, 128, 143, 30, 210, 235, 246, 84]), finalStateDigest := (bytes [214, 96, 46, 11, 248, 13, 42, 132, 141, 230, 122, 96, 107, 25, 184, 147, 236, 239, 156, 156, 238, 48, 125, 174, 84, 192, 136, 2, 174, 167, 250, 118]), transcriptFinalDigest := (bytes [136, 204, 167, 75, 151, 108, 16, 255, 16, 185, 218, 191, 68, 240, 50, 151, 48, 10, 175, 78, 253, 43, 200, 70, 235, 238, 182, 242, 224, 164, 60, 127]), preparedStepCount := 5, finalPc := 20, halted := true, points := { firstPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [251, 52, 122, 0, 121, 106, 12, 175, 109, 64, 25, 255, 113, 78, 245, 166, 161, 177, 150, 198, 14, 38, 65, 237, 248, 77, 212, 154, 231, 156, 229, 92]), layoutVersion := 3, digest := (bytes [81, 52, 31, 127, 221, 91, 78, 127, 199, 0, 31, 143, 136, 90, 4, 32, 120, 56, 138, 78, 122, 226, 185, 64, 24, 32, 158, 55, 246, 183, 177, 78]) }, logicalIndex := 0, digest := (bytes [242, 114, 153, 40, 74, 253, 96, 126, 101, 13, 123, 125, 75, 21, 244, 110, 226, 166, 232, 92, 106, 246, 127, 227, 130, 121, 164, 94, 228, 79, 123, 250]) }, valueDigest := (bytes [219, 8, 51, 136, 6, 165, 64, 201, 92, 219, 214, 171, 112, 211, 82, 38, 105, 118, 212, 115, 167, 239, 36, 209, 63, 108, 13, 59, 134, 234, 32, 123]), digest := (bytes [55, 64, 227, 137, 13, 60, 159, 86, 13, 107, 122, 210, 50, 71, 172, 195, 224, 231, 124, 32, 173, 179, 230, 114, 99, 169, 52, 12, 216, 69, 62, 70]) }), lastPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [251, 52, 122, 0, 121, 106, 12, 175, 109, 64, 25, 255, 113, 78, 245, 166, 161, 177, 150, 198, 14, 38, 65, 237, 248, 77, 212, 154, 231, 156, 229, 92]), layoutVersion := 3, digest := (bytes [81, 52, 31, 127, 221, 91, 78, 127, 199, 0, 31, 143, 136, 90, 4, 32, 120, 56, 138, 78, 122, 226, 185, 64, 24, 32, 158, 55, 246, 183, 177, 78]) }, logicalIndex := 4, digest := (bytes [60, 126, 86, 51, 72, 107, 215, 93, 182, 107, 45, 2, 105, 180, 237, 178, 40, 68, 236, 195, 155, 124, 166, 64, 112, 42, 91, 36, 65, 88, 66, 133]) }, valueDigest := (bytes [247, 8, 91, 86, 174, 60, 198, 248, 80, 76, 136, 253, 192, 49, 138, 233, 64, 183, 153, 201, 60, 173, 121, 212, 113, 120, 175, 228, 9, 127, 13, 255]), digest := (bytes [33, 208, 172, 230, 136, 24, 67, 101, 152, 98, 163, 128, 55, 104, 213, 43, 113, 230, 52, 124, 122, 33, 143, 134, 6, 124, 245, 185, 94, 180, 158, 219]) }) }, digest := (bytes [234, 54, 153, 181, 235, 35, 206, 14, 191, 54, 255, 6, 183, 241, 207, 196, 21, 193, 189, 188, 32, 197, 116, 104, 211, 189, 146, 221, 219, 216, 38, 194]) }, packaged := { statementDigest := (bytes [61, 225, 177, 195, 98, 246, 53, 175, 54, 142, 210, 0, 122, 215, 118, 164, 153, 240, 213, 246, 30, 27, 240, 14, 148, 25, 240, 224, 175, 119, 131, 183]), proofDigest := (bytes [254, 136, 44, 31, 104, 208, 219, 55, 72, 50, 241, 161, 10, 230, 139, 24, 48, 174, 12, 166, 133, 13, 17, 216, 154, 78, 253, 82, 205, 162, 4, 200]) }, digest := (bytes [66, 181, 107, 66, 161, 2, 148, 195, 200, 205, 104, 98, 220, 173, 82, 66, 43, 158, 151, 203, 110, 195, 69, 124, 248, 47, 116, 99, 5, 150, 126, 106]) }
    , digest := (bytes [191, 26, 131, 191, 145, 77, 181, 80, 69, 162, 195, 108, 155, 0, 244, 231, 25, 112, 123, 63, 223, 23, 125, 42, 234, 230, 155, 148, 90, 121, 31, 178])
  }

def stepComposition : StepCompositionSurfaceView :=
  {
    stage1SemanticsDigest := (bytes [20, 122, 20, 177, 150, 156, 138, 222, 139, 29, 214, 219, 56, 246, 216, 233, 67, 210, 125, 230, 228, 177, 196, 30, 159, 206, 169, 44, 53, 10, 141, 34])
    , stage2SemanticsDigest := (bytes [166, 133, 185, 148, 207, 115, 36, 54, 134, 251, 252, 160, 57, 153, 37, 187, 163, 69, 27, 113, 26, 102, 181, 246, 195, 91, 208, 117, 151, 232, 51, 41])
    , stage2TemporalDigest := (bytes [210, 76, 209, 6, 58, 62, 223, 200, 191, 221, 252, 176, 5, 38, 163, 26, 122, 200, 135, 22, 173, 116, 239, 249, 94, 24, 149, 127, 123, 156, 4, 249])
    , stage3SemanticsDigest := (bytes [60, 126, 174, 225, 49, 136, 70, 138, 227, 48, 150, 3, 87, 179, 83, 128, 49, 109, 42, 1, 243, 218, 34, 124, 159, 70, 254, 42, 218, 122, 125, 244])
    , rootExecutionDigest := (bytes [143, 192, 179, 235, 243, 243, 188, 114, 203, 164, 14, 86, 85, 220, 56, 62, 134, 31, 42, 193, 174, 218, 202, 188, 31, 146, 41, 176, 197, 246, 186, 86])
    , preparedStepBindingsDigest := (bytes [92, 181, 55, 62, 187, 26, 5, 222, 206, 92, 93, 243, 238, 48, 28, 35, 255, 239, 240, 213, 119, 134, 33, 37, 100, 69, 212, 13, 101, 131, 205, 238])
    , rowChunkRoutesDigest := (bytes [17, 91, 99, 15, 11, 236, 55, 95, 29, 64, 142, 221, 223, 108, 122, 237, 32, 185, 12, 250, 217, 143, 221, 95, 118, 207, 92, 60, 104, 225, 196, 181])
    , realRowCount := 5
    , preparedStepCount := 5
    , firstRealStepIndex := 0
    , lastRealStepIndex := 4
    , initialPc := 0
    , finalPc := 20
    , halted := true
    , digest := (bytes [206, 175, 250, 228, 75, 28, 161, 63, 163, 117, 30, 29, 32, 139, 46, 83, 142, 99, 253, 48, 144, 251, 241, 96, 133, 161, 63, 50, 48, 55, 53, 124])
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
    name := "native_add_chain_x0_ecall"
    , source := {
  manifest := { name := "native_add_chain_x0_ecall", fixtureId := "native_add_chain_x0_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , startPc := 0
  , programWords := [7340179, 9470227, 1114547, 5341203, 115]
  , initialRegisters := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , initialMemory := []
  , transcriptSeed := (bytes [114, 118, 54, 52, 105, 109, 45, 110, 97, 116, 105, 118, 101, 45, 97, 108, 117, 45, 102, 111, 99, 117, 115, 45, 118, 49])
}
    , derived := {
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
    , kernelProof := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "native_add_chain_x0_ecall", fixtureId := "native_add_chain_x0_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , executionDigest := (bytes [70, 186, 27, 221, 111, 194, 9, 233, 22, 165, 61, 66, 109, 14, 68, 56, 20, 142, 12, 163, 129, 72, 137, 138, 73, 128, 143, 30, 210, 235, 246, 84])
  , shape := { executionRowCount := 5, realRowCount := 5, effectRowCount := 5, commitRowCount := 5, digest := (bytes [11, 168, 18, 205, 239, 69, 109, 190, 207, 168, 250, 196, 121, 176, 87, 55, 1, 249, 85, 208, 31, 220, 81, 235, 69, 31, 18, 110, 121, 74, 49, 211]) }
  , digest := (bytes [193, 155, 181, 163, 0, 241, 98, 138, 61, 222, 95, 111, 148, 140, 232, 92, 142, 205, 33, 119, 54, 162, 224, 13, 99, 18, 136, 13, 66, 54, 68, 141])
}
  , stages := { summary := { stage1RowCount := 5, stage2RegisterReadCount := 5, stage2RegisterWriteCount := 3, stage2RamEventCount := 0, stage2TwistLinkCount := 5, stage3ContinuityCount := 5, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [127, 245, 117, 2, 192, 95, 67, 93, 241, 19, 209, 157, 161, 123, 253, 176, 245, 164, 142, 188, 245, 245, 1, 246, 5, 187, 151, 213, 108, 120, 65, 185]) }, digest := (bytes [6, 191, 6, 179, 164, 205, 86, 120, 223, 134, 233, 95, 152, 140, 86, 172, 53, 137, 137, 40, 35, 106, 127, 241, 174, 25, 251, 243, 15, 132, 162, 215]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [102, 99, 228, 44, 129, 25, 213, 223, 116, 182, 230, 97, 16, 12, 17, 12, 83, 137, 225, 132, 27, 209, 204, 86, 118, 52, 219, 9, 90, 113, 72, 218]), stage1Digest := (bytes [159, 102, 163, 181, 223, 56, 46, 198, 216, 147, 157, 124, 254, 76, 175, 57, 129, 101, 248, 194, 88, 80, 153, 186, 25, 233, 42, 224, 48, 207, 165, 245]), stage2Digest := (bytes [187, 28, 245, 229, 77, 36, 224, 254, 67, 4, 22, 119, 85, 33, 200, 48, 68, 14, 134, 251, 91, 252, 9, 73, 208, 31, 139, 52, 92, 207, 148, 147]), stage3Digest := (bytes [203, 140, 63, 160, 179, 160, 171, 82, 223, 2, 32, 73, 21, 112, 190, 222, 133, 97, 45, 221, 193, 128, 37, 148, 220, 120, 81, 206, 4, 164, 16, 21]), transcriptDigest := (bytes [136, 204, 167, 75, 151, 108, 16, 255, 16, 185, 218, 191, 68, 240, 50, 151, 48, 10, 175, 78, 253, 43, 200, 70, 235, 238, 182, 242, 224, 164, 60, 127]), executionDigest := (bytes [70, 186, 27, 221, 111, 194, 9, 233, 22, 165, 61, 66, 109, 14, 68, 56, 20, 142, 12, 163, 129, 72, 137, 138, 73, 128, 143, 30, 210, 235, 246, 84]), digest := (bytes [186, 215, 204, 164, 61, 146, 217, 156, 196, 71, 246, 173, 55, 241, 233, 228, 185, 127, 56, 255, 172, 41, 77, 30, 112, 99, 246, 143, 235, 165, 158, 80]) }, statementDigest := (bytes [188, 35, 237, 208, 105, 42, 201, 121, 98, 109, 222, 221, 23, 191, 56, 154, 214, 166, 136, 88, 42, 104, 153, 249, 202, 246, 53, 0, 108, 68, 142, 232]), proofDigest := (bytes [78, 33, 204, 201, 171, 186, 21, 100, 111, 246, 50, 204, 4, 186, 15, 249, 165, 60, 139, 45, 254, 174, 10, 120, 25, 25, 237, 99, 82, 185, 78, 224]), digest := (bytes [44, 64, 129, 40, 96, 56, 193, 221, 169, 135, 32, 0, 147, 107, 199, 145, 192, 142, 197, 93, 220, 208, 22, 50, 240, 244, 191, 42, 62, 210, 67, 38]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [255, 64, 206, 73, 236, 62, 214, 128, 180, 109, 50, 226, 84, 153, 196, 85, 181, 225, 201, 75, 54, 234, 81, 219, 235, 95, 242, 43, 66, 213, 30, 179]), stage1Digest := (bytes [132, 174, 232, 78, 241, 78, 76, 182, 143, 159, 220, 145, 105, 244, 181, 164, 64, 221, 241, 6, 171, 5, 207, 117, 108, 144, 154, 73, 15, 132, 167, 178]), stage2Digest := (bytes [37, 94, 113, 29, 240, 252, 1, 117, 129, 118, 152, 38, 195, 246, 181, 190, 9, 22, 141, 60, 125, 132, 251, 163, 174, 191, 143, 232, 209, 92, 15, 246]), stage3Digest := (bytes [163, 214, 90, 194, 31, 195, 144, 247, 188, 40, 184, 220, 245, 220, 120, 52, 58, 117, 168, 107, 9, 244, 144, 83, 137, 120, 106, 124, 255, 57, 170, 64]), digest := (bytes [195, 9, 161, 59, 207, 206, 56, 159, 0, 93, 219, 152, 50, 239, 113, 225, 170, 41, 144, 52, 90, 59, 40, 248, 10, 11, 182, 150, 238, 67, 32, 249]) }, digest := (bytes [169, 112, 199, 38, 3, 79, 161, 120, 167, 197, 180, 90, 41, 189, 67, 67, 133, 4, 65, 201, 128, 185, 135, 51, 168, 162, 183, 184, 99, 255, 154, 145]) }
  , kernelOpening := { openingDigest := (bytes [191, 26, 131, 191, 145, 77, 181, 80, 69, 162, 195, 108, 155, 0, 244, 231, 25, 112, 123, 63, 223, 23, 125, 42, 234, 230, 155, 148, 90, 121, 31, 178]), bindings := { claimDigest := (bytes [13, 10, 239, 24, 246, 149, 181, 77, 213, 105, 209, 155, 178, 109, 152, 235, 192, 18, 180, 58, 89, 118, 168, 213, 16, 107, 1, 184, 190, 231, 121, 67]), bindingsDigest := (bytes [160, 220, 21, 152, 30, 73, 128, 77, 57, 47, 114, 78, 240, 85, 1, 120, 140, 4, 199, 233, 203, 141, 80, 63, 120, 187, 71, 9, 39, 52, 112, 135]), preparedStepsDigest := (bytes [66, 181, 107, 66, 161, 2, 148, 195, 200, 205, 104, 98, 220, 173, 82, 66, 43, 158, 151, 203, 110, 195, 69, 124, 248, 47, 116, 99, 5, 150, 126, 106]), digest := (bytes [79, 178, 5, 37, 13, 154, 237, 7, 184, 128, 1, 189, 28, 147, 244, 244, 134, 233, 239, 19, 136, 13, 89, 27, 246, 123, 44, 216, 138, 32, 255, 133]) }, digest := (bytes [244, 39, 228, 128, 30, 118, 216, 238, 132, 5, 86, 181, 31, 154, 232, 6, 85, 232, 212, 81, 207, 207, 101, 5, 101, 1, 9, 52, 212, 236, 145, 232]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [92, 181, 55, 62, 187, 26, 5, 222, 206, 92, 93, 243, 238, 48, 28, 35, 255, 239, 240, 213, 119, 134, 33, 37, 100, 69, 212, 13, 101, 131, 205, 238]), terminal := { root0Digest := (bytes [180, 13, 240, 255, 164, 232, 222, 97, 177, 11, 32, 24, 102, 152, 125, 177, 128, 117, 228, 217, 234, 14, 130, 121, 56, 156, 37, 6, 1, 131, 194, 68]), executionDigest := (bytes [70, 186, 27, 221, 111, 194, 9, 233, 22, 165, 61, 66, 109, 14, 68, 56, 20, 142, 12, 163, 129, 72, 137, 138, 73, 128, 143, 30, 210, 235, 246, 84]), finalStateDigest := (bytes [214, 96, 46, 11, 248, 13, 42, 132, 141, 230, 122, 96, 107, 25, 184, 147, 236, 239, 156, 156, 238, 48, 125, 174, 84, 192, 136, 2, 174, 167, 250, 118]), transcriptFinalDigest := (bytes [136, 204, 167, 75, 151, 108, 16, 255, 16, 185, 218, 191, 68, 240, 50, 151, 48, 10, 175, 78, 253, 43, 200, 70, 235, 238, 182, 242, 224, 164, 60, 127]), finalPc := 20, halted := true, digest := (bytes [46, 53, 82, 173, 82, 35, 97, 250, 161, 164, 39, 172, 225, 175, 4, 238, 61, 250, 79, 130, 107, 238, 171, 12, 66, 235, 183, 204, 23, 188, 39, 174]) }, digest := (bytes [31, 113, 49, 14, 201, 59, 104, 199, 170, 13, 40, 40, 195, 100, 243, 115, 83, 121, 199, 124, 146, 36, 36, 100, 148, 156, 89, 44, 86, 216, 162, 75]) }, statementDigest := (bytes [69, 69, 116, 129, 28, 17, 174, 127, 189, 25, 147, 47, 155, 225, 89, 234, 135, 140, 227, 152, 37, 66, 159, 35, 174, 227, 193, 97, 18, 168, 240, 210]), proofDigest := (bytes [21, 175, 18, 102, 76, 30, 83, 85, 134, 14, 119, 168, 208, 52, 207, 3, 205, 91, 39, 14, 90, 126, 234, 114, 249, 17, 200, 168, 205, 120, 50, 192]), digest := (bytes [37, 106, 226, 189, 67, 61, 201, 93, 89, 128, 231, 137, 210, 201, 205, 185, 3, 195, 200, 144, 161, 94, 7, 198, 188, 6, 136, 242, 61, 71, 29, 143]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [45, 71, 203, 160, 194, 189, 1, 30, 95, 127, 177, 249, 43, 213, 108, 119, 112, 254, 97, 173, 156, 157, 66, 135, 77, 15, 188, 231, 137, 105, 9, 110]), layoutVersion := 1, digest := (bytes [112, 14, 250, 194, 60, 96, 4, 254, 188, 129, 34, 22, 229, 216, 197, 79, 187, 203, 126, 233, 172, 49, 4, 79, 99, 202, 220, 56, 16, 245, 157, 151]) }, rowWidth := 38, timeLen := 5, columnDigests := [(bytes [113, 50, 60, 138, 88, 147, 143, 114, 209, 102, 140, 109, 141, 130, 13, 65, 154, 83, 29, 54, 165, 27, 195, 207, 252, 83, 167, 120, 56, 155, 143, 109]), (bytes [164, 156, 12, 202, 128, 158, 166, 79, 50, 246, 26, 100, 33, 104, 153, 108, 231, 66, 5, 3, 94, 76, 41, 81, 13, 128, 233, 62, 40, 19, 215, 212]), (bytes [104, 86, 253, 80, 246, 180, 248, 154, 56, 26, 223, 106, 196, 169, 105, 55, 112, 123, 51, 7, 215, 60, 203, 20, 133, 2, 161, 155, 25, 94, 39, 31]), (bytes [4, 37, 191, 199, 27, 131, 127, 106, 23, 23, 164, 92, 246, 105, 210, 216, 164, 185, 128, 142, 255, 92, 5, 246, 36, 198, 85, 173, 19, 19, 230, 153]), (bytes [63, 82, 148, 11, 209, 51, 62, 242, 159, 229, 6, 212, 45, 165, 107, 74, 200, 142, 213, 63, 249, 218, 45, 61, 117, 144, 214, 116, 85, 207, 59, 178]), (bytes [210, 91, 66, 251, 135, 221, 36, 120, 13, 231, 174, 124, 106, 188, 187, 95, 106, 92, 112, 71, 220, 221, 9, 160, 52, 0, 227, 137, 192, 109, 223, 149]), (bytes [36, 247, 205, 134, 106, 32, 140, 157, 122, 229, 42, 10, 55, 110, 203, 127, 250, 34, 223, 50, 228, 244, 4, 241, 135, 200, 51, 77, 13, 125, 215, 9]), (bytes [58, 231, 30, 59, 177, 129, 0, 146, 229, 159, 0, 116, 238, 53, 40, 31, 46, 183, 127, 114, 226, 2, 33, 41, 114, 122, 79, 49, 152, 248, 132, 225]), (bytes [16, 166, 173, 204, 197, 96, 81, 23, 174, 247, 123, 173, 160, 1, 215, 78, 87, 237, 64, 153, 255, 223, 20, 26, 202, 114, 66, 221, 15, 90, 40, 102]), (bytes [56, 18, 253, 133, 46, 231, 152, 83, 26, 236, 25, 57, 166, 126, 144, 136, 201, 227, 105, 149, 194, 180, 125, 228, 122, 73, 207, 99, 35, 63, 193, 227]), (bytes [171, 162, 226, 116, 85, 67, 180, 225, 135, 53, 69, 80, 34, 0, 56, 31, 235, 115, 202, 243, 205, 132, 24, 215, 163, 123, 136, 58, 65, 165, 16, 20]), (bytes [160, 130, 202, 0, 154, 199, 5, 40, 30, 4, 250, 162, 112, 94, 21, 91, 216, 186, 62, 153, 245, 185, 186, 93, 248, 174, 116, 46, 116, 21, 218, 118]), (bytes [248, 43, 168, 152, 51, 77, 95, 23, 132, 5, 223, 243, 178, 225, 37, 246, 25, 224, 185, 100, 109, 161, 228, 41, 20, 188, 215, 100, 233, 156, 56, 187]), (bytes [43, 165, 79, 227, 192, 227, 229, 114, 137, 98, 247, 183, 149, 60, 181, 180, 183, 27, 148, 200, 111, 58, 237, 28, 252, 97, 226, 9, 247, 227, 203, 162]), (bytes [29, 217, 189, 89, 151, 246, 187, 208, 140, 159, 85, 103, 77, 104, 217, 4, 240, 201, 192, 135, 37, 250, 218, 243, 219, 70, 188, 1, 131, 20, 143, 164]), (bytes [218, 15, 164, 119, 26, 89, 153, 76, 195, 50, 55, 158, 39, 57, 253, 24, 64, 230, 89, 54, 164, 47, 223, 90, 24, 194, 243, 188, 112, 39, 74, 0]), (bytes [249, 165, 44, 168, 18, 125, 65, 76, 51, 110, 93, 193, 12, 212, 163, 81, 53, 26, 162, 66, 63, 100, 116, 243, 112, 137, 118, 14, 176, 24, 222, 159]), (bytes [11, 185, 133, 252, 50, 244, 35, 237, 167, 173, 175, 155, 13, 76, 146, 252, 114, 4, 198, 228, 91, 62, 90, 251, 253, 108, 66, 173, 181, 43, 114, 60]), (bytes [118, 104, 94, 12, 171, 3, 100, 43, 163, 51, 98, 0, 105, 201, 187, 207, 164, 190, 117, 22, 243, 3, 26, 197, 37, 180, 195, 107, 243, 137, 220, 124]), (bytes [164, 26, 251, 214, 133, 166, 36, 43, 117, 5, 240, 52, 163, 40, 219, 81, 176, 185, 168, 189, 219, 54, 240, 69, 240, 249, 122, 226, 140, 80, 170, 67]), (bytes [166, 212, 193, 165, 216, 77, 223, 22, 85, 148, 36, 46, 240, 197, 91, 192, 178, 249, 84, 99, 56, 189, 17, 175, 26, 146, 194, 235, 103, 203, 78, 106]), (bytes [117, 242, 101, 249, 21, 218, 127, 164, 230, 14, 233, 247, 199, 35, 201, 180, 129, 56, 152, 49, 20, 39, 58, 252, 143, 181, 103, 38, 215, 227, 205, 255]), (bytes [222, 141, 194, 19, 109, 181, 115, 128, 236, 90, 109, 50, 95, 37, 244, 239, 168, 246, 17, 195, 87, 245, 230, 227, 255, 210, 73, 185, 49, 105, 109, 248]), (bytes [84, 171, 113, 129, 86, 184, 33, 237, 183, 186, 33, 92, 163, 226, 172, 65, 152, 219, 38, 16, 100, 38, 111, 238, 165, 33, 31, 245, 51, 91, 249, 130]), (bytes [184, 255, 183, 155, 140, 77, 208, 108, 65, 102, 102, 53, 227, 82, 217, 107, 51, 138, 198, 79, 204, 224, 237, 67, 85, 170, 208, 32, 254, 253, 20, 25]), (bytes [165, 57, 236, 253, 245, 15, 151, 126, 139, 13, 166, 53, 101, 72, 25, 126, 18, 64, 110, 194, 120, 104, 198, 139, 62, 39, 232, 112, 9, 14, 39, 30]), (bytes [220, 78, 224, 98, 176, 132, 208, 205, 192, 85, 122, 166, 187, 69, 150, 200, 20, 30, 207, 74, 64, 208, 244, 219, 223, 190, 126, 203, 181, 182, 105, 72]), (bytes [167, 92, 69, 232, 129, 215, 150, 22, 142, 134, 186, 133, 122, 187, 98, 237, 109, 67, 169, 68, 16, 1, 0, 92, 129, 181, 145, 172, 134, 6, 57, 205]), (bytes [96, 0, 65, 107, 248, 48, 245, 113, 184, 191, 123, 32, 253, 213, 255, 207, 238, 64, 121, 47, 71, 116, 44, 209, 191, 98, 86, 211, 242, 146, 189, 253]), (bytes [231, 38, 189, 225, 191, 28, 138, 109, 137, 172, 136, 41, 0, 71, 10, 98, 82, 251, 63, 57, 134, 215, 207, 171, 22, 74, 131, 24, 248, 187, 249, 139]), (bytes [97, 115, 66, 52, 209, 119, 244, 26, 211, 179, 72, 158, 73, 50, 167, 139, 193, 248, 17, 168, 194, 18, 40, 36, 247, 217, 33, 69, 229, 217, 187, 137]), (bytes [104, 29, 194, 189, 239, 145, 194, 228, 166, 76, 154, 100, 169, 199, 26, 134, 252, 202, 252, 43, 213, 142, 242, 213, 255, 181, 81, 2, 47, 120, 226, 78]), (bytes [235, 49, 191, 128, 17, 252, 43, 130, 234, 138, 63, 235, 22, 122, 39, 9, 154, 168, 135, 151, 54, 180, 125, 133, 235, 6, 32, 243, 247, 58, 14, 141]), (bytes [203, 190, 166, 159, 209, 140, 180, 196, 75, 57, 130, 2, 89, 126, 203, 127, 16, 89, 187, 132, 95, 49, 171, 164, 127, 162, 189, 129, 74, 157, 57, 123]), (bytes [133, 97, 222, 172, 108, 224, 100, 38, 133, 82, 44, 62, 153, 42, 213, 206, 217, 200, 97, 197, 218, 106, 13, 74, 224, 64, 192, 64, 26, 89, 139, 91]), (bytes [170, 154, 45, 6, 188, 185, 88, 196, 229, 167, 43, 205, 233, 108, 55, 179, 176, 186, 4, 153, 204, 108, 150, 247, 84, 185, 23, 182, 159, 241, 182, 243]), (bytes [130, 173, 59, 185, 58, 8, 237, 139, 107, 135, 0, 131, 132, 73, 144, 156, 45, 9, 228, 30, 200, 84, 33, 41, 132, 180, 81, 15, 71, 200, 224, 49]), (bytes [142, 185, 27, 84, 132, 190, 160, 121, 218, 162, 8, 170, 126, 198, 197, 139, 11, 168, 143, 88, 101, 75, 56, 240, 14, 204, 255, 67, 55, 121, 123, 195])], familyDigest := (bytes [45, 71, 203, 160, 194, 189, 1, 30, 95, 127, 177, 249, 43, 213, 108, 119, 112, 254, 97, 173, 156, 157, 66, 135, 77, 15, 188, 231, 137, 105, 9, 110]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [45, 71, 203, 160, 194, 189, 1, 30, 95, 127, 177, 249, 43, 213, 108, 119, 112, 254, 97, 173, 156, 157, 66, 135, 77, 15, 188, 231, 137, 105, 9, 110]), layoutVersion := 1, digest := (bytes [112, 14, 250, 194, 60, 96, 4, 254, 188, 129, 34, 22, 229, 216, 197, 79, 187, 203, 126, 233, 172, 49, 4, 79, 99, 202, 220, 56, 16, 245, 157, 151]) }, logicalIndex := 0, digest := (bytes [50, 159, 254, 165, 98, 207, 226, 230, 224, 20, 148, 173, 186, 242, 215, 233, 134, 227, 55, 122, 49, 233, 29, 55, 222, 117, 247, 159, 14, 237, 10, 139]) }, valueDigest := (bytes [219, 8, 51, 136, 6, 165, 64, 201, 92, 219, 214, 171, 112, 211, 82, 38, 105, 118, 212, 115, 167, 239, 36, 209, 63, 108, 13, 59, 134, 234, 32, 123]), digest := (bytes [26, 245, 8, 48, 96, 7, 195, 10, 204, 117, 177, 191, 22, 245, 165, 113, 221, 231, 165, 207, 236, 31, 126, 45, 3, 126, 148, 184, 64, 60, 148, 195]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [45, 71, 203, 160, 194, 189, 1, 30, 95, 127, 177, 249, 43, 213, 108, 119, 112, 254, 97, 173, 156, 157, 66, 135, 77, 15, 188, 231, 137, 105, 9, 110]), layoutVersion := 1, digest := (bytes [112, 14, 250, 194, 60, 96, 4, 254, 188, 129, 34, 22, 229, 216, 197, 79, 187, 203, 126, 233, 172, 49, 4, 79, 99, 202, 220, 56, 16, 245, 157, 151]) }, logicalIndex := 4, digest := (bytes [146, 86, 139, 7, 96, 42, 26, 213, 188, 51, 22, 67, 199, 191, 115, 7, 28, 141, 210, 255, 224, 78, 49, 221, 196, 247, 207, 30, 22, 195, 173, 49]) }, valueDigest := (bytes [247, 8, 91, 86, 174, 60, 198, 248, 80, 76, 136, 253, 192, 49, 138, 233, 64, 183, 153, 201, 60, 173, 121, 212, 113, 120, 175, 228, 9, 127, 13, 255]), digest := (bytes [192, 110, 242, 237, 142, 80, 143, 141, 49, 184, 241, 224, 64, 5, 40, 86, 227, 115, 16, 125, 243, 95, 140, 192, 131, 152, 202, 227, 61, 206, 5, 157]) }), digest := (bytes [112, 169, 183, 169, 22, 117, 23, 219, 150, 215, 147, 170, 98, 194, 95, 238, 42, 249, 6, 255, 190, 62, 53, 203, 109, 144, 27, 231, 57, 25, 37, 173]) }
  , rootLaneCommitment := { timeLen := 5, commitments := { commitmentCount := 38, digest := (bytes [251, 52, 122, 0, 121, 106, 12, 175, 109, 64, 25, 255, 113, 78, 245, 166, 161, 177, 150, 198, 14, 38, 65, 237, 248, 77, 212, 154, 231, 156, 229, 92]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [251, 52, 122, 0, 121, 106, 12, 175, 109, 64, 25, 255, 113, 78, 245, 166, 161, 177, 150, 198, 14, 38, 65, 237, 248, 77, 212, 154, 231, 156, 229, 92]), layoutVersion := 3, digest := (bytes [81, 52, 31, 127, 221, 91, 78, 127, 199, 0, 31, 143, 136, 90, 4, 32, 120, 56, 138, 78, 122, 226, 185, 64, 24, 32, 158, 55, 246, 183, 177, 78]) }, logicalIndex := 0, digest := (bytes [242, 114, 153, 40, 74, 253, 96, 126, 101, 13, 123, 125, 75, 21, 244, 110, 226, 166, 232, 92, 106, 246, 127, 227, 130, 121, 164, 94, 228, 79, 123, 250]) }, valueDigest := (bytes [219, 8, 51, 136, 6, 165, 64, 201, 92, 219, 214, 171, 112, 211, 82, 38, 105, 118, 212, 115, 167, 239, 36, 209, 63, 108, 13, 59, 134, 234, 32, 123]), digest := (bytes [55, 64, 227, 137, 13, 60, 159, 86, 13, 107, 122, 210, 50, 71, 172, 195, 224, 231, 124, 32, 173, 179, 230, 114, 99, 169, 52, 12, 216, 69, 62, 70]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [251, 52, 122, 0, 121, 106, 12, 175, 109, 64, 25, 255, 113, 78, 245, 166, 161, 177, 150, 198, 14, 38, 65, 237, 248, 77, 212, 154, 231, 156, 229, 92]), layoutVersion := 3, digest := (bytes [81, 52, 31, 127, 221, 91, 78, 127, 199, 0, 31, 143, 136, 90, 4, 32, 120, 56, 138, 78, 122, 226, 185, 64, 24, 32, 158, 55, 246, 183, 177, 78]) }, logicalIndex := 4, digest := (bytes [60, 126, 86, 51, 72, 107, 215, 93, 182, 107, 45, 2, 105, 180, 237, 178, 40, 68, 236, 195, 155, 124, 166, 64, 112, 42, 91, 36, 65, 88, 66, 133]) }, valueDigest := (bytes [247, 8, 91, 86, 174, 60, 198, 248, 80, 76, 136, 253, 192, 49, 138, 233, 64, 183, 153, 201, 60, 173, 121, 212, 113, 120, 175, 228, 9, 127, 13, 255]), digest := (bytes [33, 208, 172, 230, 136, 24, 67, 101, 152, 98, 163, 128, 55, 104, 213, 43, 113, 230, 52, 124, 122, 33, 143, 134, 6, 124, 245, 185, 94, 180, 158, 219]) }), digest := (bytes [230, 14, 116, 174, 78, 244, 29, 230, 211, 33, 236, 6, 71, 146, 223, 106, 12, 61, 52, 248, 38, 4, 123, 89, 48, 130, 111, 145, 65, 234, 182, 187]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [112, 169, 183, 169, 22, 117, 23, 219, 150, 215, 147, 170, 98, 194, 95, 238, 42, 249, 6, 255, 190, 62, 53, 203, 109, 144, 27, 231, 57, 25, 37, 173]), rootLaneCommitmentDigest := (bytes [230, 14, 116, 174, 78, 244, 29, 230, 211, 33, 236, 6, 71, 146, 223, 106, 12, 61, 52, 248, 38, 4, 123, 89, 48, 130, 111, 145, 65, 234, 182, 187]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 5, digest := (bytes [165, 47, 175, 142, 167, 104, 47, 158, 220, 160, 29, 34, 249, 206, 101, 174, 109, 117, 163, 134, 31, 118, 67, 176, 30, 172, 150, 82, 128, 151, 117, 202]) }, statementDigest := (bytes [201, 59, 28, 254, 8, 9, 244, 73, 31, 20, 37, 143, 231, 183, 234, 84, 120, 212, 92, 33, 92, 226, 205, 105, 66, 171, 112, 166, 155, 23, 27, 143]), proofDigest := (bytes [198, 107, 116, 211, 59, 109, 160, 89, 36, 122, 8, 83, 54, 64, 108, 129, 219, 142, 83, 20, 17, 39, 155, 221, 192, 242, 212, 22, 219, 149, 240, 172]), digest := (bytes [166, 19, 201, 103, 30, 194, 96, 165, 88, 94, 238, 193, 151, 129, 19, 142, 86, 173, 205, 95, 151, 60, 120, 250, 221, 79, 165, 145, 103, 4, 185, 169]) }
  , digest := (bytes [245, 237, 146, 24, 215, 157, 130, 50, 11, 122, 125, 198, 60, 192, 95, 96, 36, 101, 188, 66, 69, 96, 139, 58, 1, 135, 109, 202, 216, 140, 40, 58])
}
    , exportedProof := {
  claim := {
  accepted := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , statement := { proofStatementDigest := (bytes [218, 237, 194, 188, 127, 76, 39, 150, 111, 36, 132, 10, 20, 26, 149, 216, 6, 210, 193, 132, 16, 77, 121, 28, 209, 49, 218, 69, 123, 84, 72, 19]), kernelOpeningDigest := (bytes [244, 39, 228, 128, 30, 118, 216, 238, 132, 5, 86, 181, 31, 154, 232, 6, 85, 232, 212, 81, 207, 207, 101, 5, 101, 1, 9, 52, 212, 236, 145, 232]), digest := (bytes [183, 253, 175, 157, 62, 36, 250, 110, 202, 185, 230, 144, 95, 103, 254, 137, 98, 68, 167, 32, 128, 141, 105, 140, 128, 55, 86, 151, 214, 223, 222, 71]) }
  , mainLane := { mainLaneBundleDigest := (bytes [166, 19, 201, 103, 30, 194, 96, 165, 88, 94, 238, 193, 151, 129, 19, 142, 86, 173, 205, 95, 151, 60, 120, 250, 221, 79, 165, 145, 103, 4, 185, 169]), digest := (bytes [190, 115, 221, 0, 238, 185, 128, 213, 141, 165, 14, 174, 39, 28, 26, 70, 78, 71, 209, 155, 196, 74, 161, 216, 139, 194, 193, 226, 193, 95, 197, 225]) }
  , terminal := { finalStateDigest := (bytes [214, 96, 46, 11, 248, 13, 42, 132, 141, 230, 122, 96, 107, 25, 184, 147, 236, 239, 156, 156, 238, 48, 125, 174, 84, 192, 136, 2, 174, 167, 250, 118]), finalPc := 20, halted := true, digest := (bytes [145, 20, 206, 251, 86, 77, 83, 34, 13, 2, 122, 65, 95, 22, 123, 171, 247, 47, 197, 234, 163, 179, 129, 58, 125, 90, 2, 135, 40, 121, 152, 226]) }
  , digest := (bytes [202, 243, 19, 27, 39, 96, 51, 217, 150, 165, 151, 18, 27, 96, 54, 141, 50, 44, 107, 83, 96, 140, 144, 184, 28, 219, 101, 16, 163, 213, 171, 91])
}
  , mainLane := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { mainLaneBundleDigest := (bytes [166, 19, 201, 103, 30, 194, 96, 165, 88, 94, 238, 193, 151, 129, 19, 142, 86, 173, 205, 95, 151, 60, 120, 250, 221, 79, 165, 145, 103, 4, 185, 169]), digest := (bytes [248, 43, 178, 171, 30, 71, 72, 52, 61, 219, 77, 28, 222, 155, 206, 46, 8, 120, 103, 110, 88, 19, 89, 61, 81, 184, 218, 99, 74, 181, 201, 44]) }, digest := (bytes [152, 24, 197, 107, 112, 11, 114, 180, 170, 211, 83, 7, 24, 176, 15, 211, 8, 197, 241, 49, 24, 16, 30, 65, 251, 41, 226, 186, 165, 57, 68, 181]) }
  , opening := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , stages := { stageClaimsDigest := (bytes [44, 64, 129, 40, 96, 56, 193, 221, 169, 135, 32, 0, 147, 107, 199, 145, 192, 142, 197, 93, 220, 208, 22, 50, 240, 244, 191, 42, 62, 210, 67, 38]), stagePackagesDigest := (bytes [169, 112, 199, 38, 3, 79, 161, 120, 167, 197, 180, 90, 41, 189, 67, 67, 133, 4, 65, 201, 128, 185, 135, 51, 168, 162, 183, 184, 99, 255, 154, 145]), kernelOpeningDigest := (bytes [244, 39, 228, 128, 30, 118, 216, 238, 132, 5, 86, 181, 31, 154, 232, 6, 85, 232, 212, 81, 207, 207, 101, 5, 101, 1, 9, 52, 212, 236, 145, 232]), digest := (bytes [108, 234, 197, 129, 155, 130, 9, 43, 67, 219, 131, 138, 107, 228, 208, 153, 165, 224, 239, 57, 69, 25, 229, 70, 96, 4, 128, 130, 222, 247, 92, 55]) }
  , terminal := { preparedStepBindingsDigest := (bytes [92, 181, 55, 62, 187, 26, 5, 222, 206, 92, 93, 243, 238, 48, 28, 35, 255, 239, 240, 213, 119, 134, 33, 37, 100, 69, 212, 13, 101, 131, 205, 238]), executionDigest := (bytes [70, 186, 27, 221, 111, 194, 9, 233, 22, 165, 61, 66, 109, 14, 68, 56, 20, 142, 12, 163, 129, 72, 137, 138, 73, 128, 143, 30, 210, 235, 246, 84]), transcriptFinalDigest := (bytes [136, 204, 167, 75, 151, 108, 16, 255, 16, 185, 218, 191, 68, 240, 50, 151, 48, 10, 175, 78, 253, 43, 200, 70, 235, 238, 182, 242, 224, 164, 60, 127]), digest := (bytes [18, 242, 253, 130, 114, 91, 153, 250, 88, 247, 180, 204, 249, 173, 173, 189, 168, 26, 222, 213, 159, 198, 207, 104, 32, 185, 162, 243, 215, 240, 200, 203]) }
  , digest := (bytes [9, 168, 210, 5, 219, 115, 181, 103, 36, 230, 191, 196, 90, 217, 95, 217, 100, 21, 34, 93, 62, 99, 162, 229, 73, 79, 248, 74, 137, 137, 215, 28])
}
  , jointOpening := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { proofStatementDigest := (bytes [218, 237, 194, 188, 127, 76, 39, 150, 111, 36, 132, 10, 20, 26, 149, 216, 6, 210, 193, 132, 16, 77, 121, 28, 209, 49, 218, 69, 123, 84, 72, 19]), mainLaneClaimDigest := (bytes [152, 24, 197, 107, 112, 11, 114, 180, 170, 211, 83, 7, 24, 176, 15, 211, 8, 197, 241, 49, 24, 16, 30, 65, 251, 41, 226, 186, 165, 57, 68, 181]), kernelOpeningClaimDigest := (bytes [9, 168, 210, 5, 219, 115, 181, 103, 36, 230, 191, 196, 90, 217, 95, 217, 100, 21, 34, 93, 62, 99, 162, 229, 73, 79, 248, 74, 137, 137, 215, 28]), digest := (bytes [109, 34, 119, 20, 251, 164, 227, 136, 219, 178, 151, 58, 181, 185, 118, 164, 221, 107, 213, 12, 97, 122, 181, 177, 79, 47, 179, 222, 233, 188, 116, 54]) }, digest := (bytes [210, 193, 119, 171, 89, 29, 126, 142, 141, 119, 34, 254, 84, 45, 166, 59, 144, 0, 33, 30, 12, 144, 17, 107, 154, 148, 16, 211, 233, 51, 167, 170]) }
  , root0 := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), stages := { stage1Digest := (bytes [180, 42, 129, 179, 124, 135, 212, 151, 194, 155, 111, 92, 136, 232, 113, 76, 56, 79, 211, 209, 190, 95, 243, 229, 22, 35, 90, 1, 212, 71, 253, 137]), stage2Digest := (bytes [22, 68, 145, 88, 70, 235, 218, 223, 184, 4, 4, 2, 46, 118, 45, 170, 162, 155, 203, 98, 78, 226, 202, 3, 189, 168, 151, 175, 235, 8, 242, 75]), stage3Digest := (bytes [2, 183, 132, 95, 231, 115, 83, 2, 8, 179, 51, 169, 210, 224, 230, 178, 60, 35, 73, 58, 195, 121, 109, 163, 86, 206, 95, 244, 250, 18, 169, 79]), digest := (bytes [96, 145, 34, 49, 162, 92, 26, 218, 242, 187, 74, 188, 215, 123, 92, 248, 7, 228, 142, 153, 222, 100, 27, 86, 156, 0, 170, 25, 229, 84, 143, 185]) }, terminal := { root0Digest := (bytes [180, 13, 240, 255, 164, 232, 222, 97, 177, 11, 32, 24, 102, 152, 125, 177, 128, 117, 228, 217, 234, 14, 130, 121, 56, 156, 37, 6, 1, 131, 194, 68]), executionDigest := (bytes [70, 186, 27, 221, 111, 194, 9, 233, 22, 165, 61, 66, 109, 14, 68, 56, 20, 142, 12, 163, 129, 72, 137, 138, 73, 128, 143, 30, 210, 235, 246, 84]), finalStateDigest := (bytes [214, 96, 46, 11, 248, 13, 42, 132, 141, 230, 122, 96, 107, 25, 184, 147, 236, 239, 156, 156, 238, 48, 125, 174, 84, 192, 136, 2, 174, 167, 250, 118]), transcriptFinalDigest := (bytes [136, 204, 167, 75, 151, 108, 16, 255, 16, 185, 218, 191, 68, 240, 50, 151, 48, 10, 175, 78, 253, 43, 200, 70, 235, 238, 182, 242, 224, 164, 60, 127]), digest := (bytes [213, 244, 241, 97, 177, 40, 164, 172, 183, 93, 225, 190, 10, 195, 19, 40, 152, 63, 254, 226, 126, 190, 41, 227, 137, 34, 84, 71, 36, 134, 151, 47]) }, digest := (bytes [16, 54, 5, 224, 19, 147, 39, 41, 62, 117, 79, 5, 192, 146, 168, 85, 177, 5, 98, 171, 145, 19, 246, 69, 29, 46, 105, 232, 168, 246, 52, 98]) }
  , digest := (bytes [53, 132, 170, 8, 41, 176, 11, 236, 73, 95, 181, 242, 69, 53, 230, 3, 56, 71, 153, 163, 192, 175, 235, 130, 18, 12, 252, 34, 107, 126, 137, 124])
}
  , statement := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , foldSchedule := Nightstream.FoldSchedule.wholeTrace
  , chunkCount := 1
  , stageClaimsDigest := (bytes [44, 64, 129, 40, 96, 56, 193, 221, 169, 135, 32, 0, 147, 107, 199, 145, 192, 142, 197, 93, 220, 208, 22, 50, 240, 244, 191, 42, 62, 210, 67, 38])
  , stagePackagesDigest := (bytes [169, 112, 199, 38, 3, 79, 161, 120, 167, 197, 180, 90, 41, 189, 67, 67, 133, 4, 65, 201, 128, 185, 135, 51, 168, 162, 183, 184, 99, 255, 154, 145])
  , kernelOpeningDigest := (bytes [244, 39, 228, 128, 30, 118, 216, 238, 132, 5, 86, 181, 31, 154, 232, 6, 85, 232, 212, 81, 207, 207, 101, 5, 101, 1, 9, 52, 212, 236, 145, 232])
  , preparedStepBindingsDigest := (bytes [92, 181, 55, 62, 187, 26, 5, 222, 206, 92, 93, 243, 238, 48, 28, 35, 255, 239, 240, 213, 119, 134, 33, 37, 100, 69, 212, 13, 101, 131, 205, 238])
  , executionDigest := (bytes [70, 186, 27, 221, 111, 194, 9, 233, 22, 165, 61, 66, 109, 14, 68, 56, 20, 142, 12, 163, 129, 72, 137, 138, 73, 128, 143, 30, 210, 235, 246, 84])
  , finalStateDigest := (bytes [214, 96, 46, 11, 248, 13, 42, 132, 141, 230, 122, 96, 107, 25, 184, 147, 236, 239, 156, 156, 238, 48, 125, 174, 84, 192, 136, 2, 174, 167, 250, 118])
  , transcriptFinalDigest := (bytes [136, 204, 167, 75, 151, 108, 16, 255, 16, 185, 218, 191, 68, 240, 50, 151, 48, 10, 175, 78, 253, 43, 200, 70, 235, 238, 182, 242, 224, 164, 60, 127])
  , mainLaneSurfaceDigest := (bytes [161, 239, 65, 47, 116, 8, 58, 52, 113, 131, 236, 82, 144, 148, 245, 79, 217, 22, 169, 51, 222, 255, 14, 72, 146, 29, 189, 204, 112, 147, 40, 92])
  , rootLaneColumnsDigest := (bytes [112, 169, 183, 169, 22, 117, 23, 219, 150, 215, 147, 170, 98, 194, 95, 238, 42, 249, 6, 255, 190, 62, 53, 203, 109, 144, 27, 231, 57, 25, 37, 173])
  , publicStepCount := 5
  , initialPc := 0
  , finalPc := 20
  , halted := true
  , digest := (bytes [218, 237, 194, 188, 127, 76, 39, 150, 111, 36, 132, 10, 20, 26, 149, 216, 6, 210, 193, 132, 16, 77, 121, 28, 209, 49, 218, 69, 123, 84, 72, 19])
}
  , kernel := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "native_add_chain_x0_ecall", fixtureId := "native_add_chain_x0_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , executionDigest := (bytes [70, 186, 27, 221, 111, 194, 9, 233, 22, 165, 61, 66, 109, 14, 68, 56, 20, 142, 12, 163, 129, 72, 137, 138, 73, 128, 143, 30, 210, 235, 246, 84])
  , shape := { executionRowCount := 5, realRowCount := 5, effectRowCount := 5, commitRowCount := 5, digest := (bytes [11, 168, 18, 205, 239, 69, 109, 190, 207, 168, 250, 196, 121, 176, 87, 55, 1, 249, 85, 208, 31, 220, 81, 235, 69, 31, 18, 110, 121, 74, 49, 211]) }
  , digest := (bytes [193, 155, 181, 163, 0, 241, 98, 138, 61, 222, 95, 111, 148, 140, 232, 92, 142, 205, 33, 119, 54, 162, 224, 13, 99, 18, 136, 13, 66, 54, 68, 141])
}
  , stages := { summary := { stage1RowCount := 5, stage2RegisterReadCount := 5, stage2RegisterWriteCount := 3, stage2RamEventCount := 0, stage2TwistLinkCount := 5, stage3ContinuityCount := 5, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [127, 245, 117, 2, 192, 95, 67, 93, 241, 19, 209, 157, 161, 123, 253, 176, 245, 164, 142, 188, 245, 245, 1, 246, 5, 187, 151, 213, 108, 120, 65, 185]) }, digest := (bytes [6, 191, 6, 179, 164, 205, 86, 120, 223, 134, 233, 95, 152, 140, 86, 172, 53, 137, 137, 40, 35, 106, 127, 241, 174, 25, 251, 243, 15, 132, 162, 215]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [102, 99, 228, 44, 129, 25, 213, 223, 116, 182, 230, 97, 16, 12, 17, 12, 83, 137, 225, 132, 27, 209, 204, 86, 118, 52, 219, 9, 90, 113, 72, 218]), stage1Digest := (bytes [159, 102, 163, 181, 223, 56, 46, 198, 216, 147, 157, 124, 254, 76, 175, 57, 129, 101, 248, 194, 88, 80, 153, 186, 25, 233, 42, 224, 48, 207, 165, 245]), stage2Digest := (bytes [187, 28, 245, 229, 77, 36, 224, 254, 67, 4, 22, 119, 85, 33, 200, 48, 68, 14, 134, 251, 91, 252, 9, 73, 208, 31, 139, 52, 92, 207, 148, 147]), stage3Digest := (bytes [203, 140, 63, 160, 179, 160, 171, 82, 223, 2, 32, 73, 21, 112, 190, 222, 133, 97, 45, 221, 193, 128, 37, 148, 220, 120, 81, 206, 4, 164, 16, 21]), transcriptDigest := (bytes [136, 204, 167, 75, 151, 108, 16, 255, 16, 185, 218, 191, 68, 240, 50, 151, 48, 10, 175, 78, 253, 43, 200, 70, 235, 238, 182, 242, 224, 164, 60, 127]), executionDigest := (bytes [70, 186, 27, 221, 111, 194, 9, 233, 22, 165, 61, 66, 109, 14, 68, 56, 20, 142, 12, 163, 129, 72, 137, 138, 73, 128, 143, 30, 210, 235, 246, 84]), digest := (bytes [186, 215, 204, 164, 61, 146, 217, 156, 196, 71, 246, 173, 55, 241, 233, 228, 185, 127, 56, 255, 172, 41, 77, 30, 112, 99, 246, 143, 235, 165, 158, 80]) }, statementDigest := (bytes [188, 35, 237, 208, 105, 42, 201, 121, 98, 109, 222, 221, 23, 191, 56, 154, 214, 166, 136, 88, 42, 104, 153, 249, 202, 246, 53, 0, 108, 68, 142, 232]), proofDigest := (bytes [78, 33, 204, 201, 171, 186, 21, 100, 111, 246, 50, 204, 4, 186, 15, 249, 165, 60, 139, 45, 254, 174, 10, 120, 25, 25, 237, 99, 82, 185, 78, 224]), digest := (bytes [44, 64, 129, 40, 96, 56, 193, 221, 169, 135, 32, 0, 147, 107, 199, 145, 192, 142, 197, 93, 220, 208, 22, 50, 240, 244, 191, 42, 62, 210, 67, 38]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [255, 64, 206, 73, 236, 62, 214, 128, 180, 109, 50, 226, 84, 153, 196, 85, 181, 225, 201, 75, 54, 234, 81, 219, 235, 95, 242, 43, 66, 213, 30, 179]), stage1Digest := (bytes [132, 174, 232, 78, 241, 78, 76, 182, 143, 159, 220, 145, 105, 244, 181, 164, 64, 221, 241, 6, 171, 5, 207, 117, 108, 144, 154, 73, 15, 132, 167, 178]), stage2Digest := (bytes [37, 94, 113, 29, 240, 252, 1, 117, 129, 118, 152, 38, 195, 246, 181, 190, 9, 22, 141, 60, 125, 132, 251, 163, 174, 191, 143, 232, 209, 92, 15, 246]), stage3Digest := (bytes [163, 214, 90, 194, 31, 195, 144, 247, 188, 40, 184, 220, 245, 220, 120, 52, 58, 117, 168, 107, 9, 244, 144, 83, 137, 120, 106, 124, 255, 57, 170, 64]), digest := (bytes [195, 9, 161, 59, 207, 206, 56, 159, 0, 93, 219, 152, 50, 239, 113, 225, 170, 41, 144, 52, 90, 59, 40, 248, 10, 11, 182, 150, 238, 67, 32, 249]) }, digest := (bytes [169, 112, 199, 38, 3, 79, 161, 120, 167, 197, 180, 90, 41, 189, 67, 67, 133, 4, 65, 201, 128, 185, 135, 51, 168, 162, 183, 184, 99, 255, 154, 145]) }
  , kernelOpening := { openingDigest := (bytes [191, 26, 131, 191, 145, 77, 181, 80, 69, 162, 195, 108, 155, 0, 244, 231, 25, 112, 123, 63, 223, 23, 125, 42, 234, 230, 155, 148, 90, 121, 31, 178]), bindings := { claimDigest := (bytes [13, 10, 239, 24, 246, 149, 181, 77, 213, 105, 209, 155, 178, 109, 152, 235, 192, 18, 180, 58, 89, 118, 168, 213, 16, 107, 1, 184, 190, 231, 121, 67]), bindingsDigest := (bytes [160, 220, 21, 152, 30, 73, 128, 77, 57, 47, 114, 78, 240, 85, 1, 120, 140, 4, 199, 233, 203, 141, 80, 63, 120, 187, 71, 9, 39, 52, 112, 135]), preparedStepsDigest := (bytes [66, 181, 107, 66, 161, 2, 148, 195, 200, 205, 104, 98, 220, 173, 82, 66, 43, 158, 151, 203, 110, 195, 69, 124, 248, 47, 116, 99, 5, 150, 126, 106]), digest := (bytes [79, 178, 5, 37, 13, 154, 237, 7, 184, 128, 1, 189, 28, 147, 244, 244, 134, 233, 239, 19, 136, 13, 89, 27, 246, 123, 44, 216, 138, 32, 255, 133]) }, digest := (bytes [244, 39, 228, 128, 30, 118, 216, 238, 132, 5, 86, 181, 31, 154, 232, 6, 85, 232, 212, 81, 207, 207, 101, 5, 101, 1, 9, 52, 212, 236, 145, 232]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [92, 181, 55, 62, 187, 26, 5, 222, 206, 92, 93, 243, 238, 48, 28, 35, 255, 239, 240, 213, 119, 134, 33, 37, 100, 69, 212, 13, 101, 131, 205, 238]), terminal := { root0Digest := (bytes [180, 13, 240, 255, 164, 232, 222, 97, 177, 11, 32, 24, 102, 152, 125, 177, 128, 117, 228, 217, 234, 14, 130, 121, 56, 156, 37, 6, 1, 131, 194, 68]), executionDigest := (bytes [70, 186, 27, 221, 111, 194, 9, 233, 22, 165, 61, 66, 109, 14, 68, 56, 20, 142, 12, 163, 129, 72, 137, 138, 73, 128, 143, 30, 210, 235, 246, 84]), finalStateDigest := (bytes [214, 96, 46, 11, 248, 13, 42, 132, 141, 230, 122, 96, 107, 25, 184, 147, 236, 239, 156, 156, 238, 48, 125, 174, 84, 192, 136, 2, 174, 167, 250, 118]), transcriptFinalDigest := (bytes [136, 204, 167, 75, 151, 108, 16, 255, 16, 185, 218, 191, 68, 240, 50, 151, 48, 10, 175, 78, 253, 43, 200, 70, 235, 238, 182, 242, 224, 164, 60, 127]), finalPc := 20, halted := true, digest := (bytes [46, 53, 82, 173, 82, 35, 97, 250, 161, 164, 39, 172, 225, 175, 4, 238, 61, 250, 79, 130, 107, 238, 171, 12, 66, 235, 183, 204, 23, 188, 39, 174]) }, digest := (bytes [31, 113, 49, 14, 201, 59, 104, 199, 170, 13, 40, 40, 195, 100, 243, 115, 83, 121, 199, 124, 146, 36, 36, 100, 148, 156, 89, 44, 86, 216, 162, 75]) }, statementDigest := (bytes [69, 69, 116, 129, 28, 17, 174, 127, 189, 25, 147, 47, 155, 225, 89, 234, 135, 140, 227, 152, 37, 66, 159, 35, 174, 227, 193, 97, 18, 168, 240, 210]), proofDigest := (bytes [21, 175, 18, 102, 76, 30, 83, 85, 134, 14, 119, 168, 208, 52, 207, 3, 205, 91, 39, 14, 90, 126, 234, 114, 249, 17, 200, 168, 205, 120, 50, 192]), digest := (bytes [37, 106, 226, 189, 67, 61, 201, 93, 89, 128, 231, 137, 210, 201, 205, 185, 3, 195, 200, 144, 161, 94, 7, 198, 188, 6, 136, 242, 61, 71, 29, 143]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [45, 71, 203, 160, 194, 189, 1, 30, 95, 127, 177, 249, 43, 213, 108, 119, 112, 254, 97, 173, 156, 157, 66, 135, 77, 15, 188, 231, 137, 105, 9, 110]), layoutVersion := 1, digest := (bytes [112, 14, 250, 194, 60, 96, 4, 254, 188, 129, 34, 22, 229, 216, 197, 79, 187, 203, 126, 233, 172, 49, 4, 79, 99, 202, 220, 56, 16, 245, 157, 151]) }, rowWidth := 38, timeLen := 5, columnDigests := [(bytes [113, 50, 60, 138, 88, 147, 143, 114, 209, 102, 140, 109, 141, 130, 13, 65, 154, 83, 29, 54, 165, 27, 195, 207, 252, 83, 167, 120, 56, 155, 143, 109]), (bytes [164, 156, 12, 202, 128, 158, 166, 79, 50, 246, 26, 100, 33, 104, 153, 108, 231, 66, 5, 3, 94, 76, 41, 81, 13, 128, 233, 62, 40, 19, 215, 212]), (bytes [104, 86, 253, 80, 246, 180, 248, 154, 56, 26, 223, 106, 196, 169, 105, 55, 112, 123, 51, 7, 215, 60, 203, 20, 133, 2, 161, 155, 25, 94, 39, 31]), (bytes [4, 37, 191, 199, 27, 131, 127, 106, 23, 23, 164, 92, 246, 105, 210, 216, 164, 185, 128, 142, 255, 92, 5, 246, 36, 198, 85, 173, 19, 19, 230, 153]), (bytes [63, 82, 148, 11, 209, 51, 62, 242, 159, 229, 6, 212, 45, 165, 107, 74, 200, 142, 213, 63, 249, 218, 45, 61, 117, 144, 214, 116, 85, 207, 59, 178]), (bytes [210, 91, 66, 251, 135, 221, 36, 120, 13, 231, 174, 124, 106, 188, 187, 95, 106, 92, 112, 71, 220, 221, 9, 160, 52, 0, 227, 137, 192, 109, 223, 149]), (bytes [36, 247, 205, 134, 106, 32, 140, 157, 122, 229, 42, 10, 55, 110, 203, 127, 250, 34, 223, 50, 228, 244, 4, 241, 135, 200, 51, 77, 13, 125, 215, 9]), (bytes [58, 231, 30, 59, 177, 129, 0, 146, 229, 159, 0, 116, 238, 53, 40, 31, 46, 183, 127, 114, 226, 2, 33, 41, 114, 122, 79, 49, 152, 248, 132, 225]), (bytes [16, 166, 173, 204, 197, 96, 81, 23, 174, 247, 123, 173, 160, 1, 215, 78, 87, 237, 64, 153, 255, 223, 20, 26, 202, 114, 66, 221, 15, 90, 40, 102]), (bytes [56, 18, 253, 133, 46, 231, 152, 83, 26, 236, 25, 57, 166, 126, 144, 136, 201, 227, 105, 149, 194, 180, 125, 228, 122, 73, 207, 99, 35, 63, 193, 227]), (bytes [171, 162, 226, 116, 85, 67, 180, 225, 135, 53, 69, 80, 34, 0, 56, 31, 235, 115, 202, 243, 205, 132, 24, 215, 163, 123, 136, 58, 65, 165, 16, 20]), (bytes [160, 130, 202, 0, 154, 199, 5, 40, 30, 4, 250, 162, 112, 94, 21, 91, 216, 186, 62, 153, 245, 185, 186, 93, 248, 174, 116, 46, 116, 21, 218, 118]), (bytes [248, 43, 168, 152, 51, 77, 95, 23, 132, 5, 223, 243, 178, 225, 37, 246, 25, 224, 185, 100, 109, 161, 228, 41, 20, 188, 215, 100, 233, 156, 56, 187]), (bytes [43, 165, 79, 227, 192, 227, 229, 114, 137, 98, 247, 183, 149, 60, 181, 180, 183, 27, 148, 200, 111, 58, 237, 28, 252, 97, 226, 9, 247, 227, 203, 162]), (bytes [29, 217, 189, 89, 151, 246, 187, 208, 140, 159, 85, 103, 77, 104, 217, 4, 240, 201, 192, 135, 37, 250, 218, 243, 219, 70, 188, 1, 131, 20, 143, 164]), (bytes [218, 15, 164, 119, 26, 89, 153, 76, 195, 50, 55, 158, 39, 57, 253, 24, 64, 230, 89, 54, 164, 47, 223, 90, 24, 194, 243, 188, 112, 39, 74, 0]), (bytes [249, 165, 44, 168, 18, 125, 65, 76, 51, 110, 93, 193, 12, 212, 163, 81, 53, 26, 162, 66, 63, 100, 116, 243, 112, 137, 118, 14, 176, 24, 222, 159]), (bytes [11, 185, 133, 252, 50, 244, 35, 237, 167, 173, 175, 155, 13, 76, 146, 252, 114, 4, 198, 228, 91, 62, 90, 251, 253, 108, 66, 173, 181, 43, 114, 60]), (bytes [118, 104, 94, 12, 171, 3, 100, 43, 163, 51, 98, 0, 105, 201, 187, 207, 164, 190, 117, 22, 243, 3, 26, 197, 37, 180, 195, 107, 243, 137, 220, 124]), (bytes [164, 26, 251, 214, 133, 166, 36, 43, 117, 5, 240, 52, 163, 40, 219, 81, 176, 185, 168, 189, 219, 54, 240, 69, 240, 249, 122, 226, 140, 80, 170, 67]), (bytes [166, 212, 193, 165, 216, 77, 223, 22, 85, 148, 36, 46, 240, 197, 91, 192, 178, 249, 84, 99, 56, 189, 17, 175, 26, 146, 194, 235, 103, 203, 78, 106]), (bytes [117, 242, 101, 249, 21, 218, 127, 164, 230, 14, 233, 247, 199, 35, 201, 180, 129, 56, 152, 49, 20, 39, 58, 252, 143, 181, 103, 38, 215, 227, 205, 255]), (bytes [222, 141, 194, 19, 109, 181, 115, 128, 236, 90, 109, 50, 95, 37, 244, 239, 168, 246, 17, 195, 87, 245, 230, 227, 255, 210, 73, 185, 49, 105, 109, 248]), (bytes [84, 171, 113, 129, 86, 184, 33, 237, 183, 186, 33, 92, 163, 226, 172, 65, 152, 219, 38, 16, 100, 38, 111, 238, 165, 33, 31, 245, 51, 91, 249, 130]), (bytes [184, 255, 183, 155, 140, 77, 208, 108, 65, 102, 102, 53, 227, 82, 217, 107, 51, 138, 198, 79, 204, 224, 237, 67, 85, 170, 208, 32, 254, 253, 20, 25]), (bytes [165, 57, 236, 253, 245, 15, 151, 126, 139, 13, 166, 53, 101, 72, 25, 126, 18, 64, 110, 194, 120, 104, 198, 139, 62, 39, 232, 112, 9, 14, 39, 30]), (bytes [220, 78, 224, 98, 176, 132, 208, 205, 192, 85, 122, 166, 187, 69, 150, 200, 20, 30, 207, 74, 64, 208, 244, 219, 223, 190, 126, 203, 181, 182, 105, 72]), (bytes [167, 92, 69, 232, 129, 215, 150, 22, 142, 134, 186, 133, 122, 187, 98, 237, 109, 67, 169, 68, 16, 1, 0, 92, 129, 181, 145, 172, 134, 6, 57, 205]), (bytes [96, 0, 65, 107, 248, 48, 245, 113, 184, 191, 123, 32, 253, 213, 255, 207, 238, 64, 121, 47, 71, 116, 44, 209, 191, 98, 86, 211, 242, 146, 189, 253]), (bytes [231, 38, 189, 225, 191, 28, 138, 109, 137, 172, 136, 41, 0, 71, 10, 98, 82, 251, 63, 57, 134, 215, 207, 171, 22, 74, 131, 24, 248, 187, 249, 139]), (bytes [97, 115, 66, 52, 209, 119, 244, 26, 211, 179, 72, 158, 73, 50, 167, 139, 193, 248, 17, 168, 194, 18, 40, 36, 247, 217, 33, 69, 229, 217, 187, 137]), (bytes [104, 29, 194, 189, 239, 145, 194, 228, 166, 76, 154, 100, 169, 199, 26, 134, 252, 202, 252, 43, 213, 142, 242, 213, 255, 181, 81, 2, 47, 120, 226, 78]), (bytes [235, 49, 191, 128, 17, 252, 43, 130, 234, 138, 63, 235, 22, 122, 39, 9, 154, 168, 135, 151, 54, 180, 125, 133, 235, 6, 32, 243, 247, 58, 14, 141]), (bytes [203, 190, 166, 159, 209, 140, 180, 196, 75, 57, 130, 2, 89, 126, 203, 127, 16, 89, 187, 132, 95, 49, 171, 164, 127, 162, 189, 129, 74, 157, 57, 123]), (bytes [133, 97, 222, 172, 108, 224, 100, 38, 133, 82, 44, 62, 153, 42, 213, 206, 217, 200, 97, 197, 218, 106, 13, 74, 224, 64, 192, 64, 26, 89, 139, 91]), (bytes [170, 154, 45, 6, 188, 185, 88, 196, 229, 167, 43, 205, 233, 108, 55, 179, 176, 186, 4, 153, 204, 108, 150, 247, 84, 185, 23, 182, 159, 241, 182, 243]), (bytes [130, 173, 59, 185, 58, 8, 237, 139, 107, 135, 0, 131, 132, 73, 144, 156, 45, 9, 228, 30, 200, 84, 33, 41, 132, 180, 81, 15, 71, 200, 224, 49]), (bytes [142, 185, 27, 84, 132, 190, 160, 121, 218, 162, 8, 170, 126, 198, 197, 139, 11, 168, 143, 88, 101, 75, 56, 240, 14, 204, 255, 67, 55, 121, 123, 195])], familyDigest := (bytes [45, 71, 203, 160, 194, 189, 1, 30, 95, 127, 177, 249, 43, 213, 108, 119, 112, 254, 97, 173, 156, 157, 66, 135, 77, 15, 188, 231, 137, 105, 9, 110]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [45, 71, 203, 160, 194, 189, 1, 30, 95, 127, 177, 249, 43, 213, 108, 119, 112, 254, 97, 173, 156, 157, 66, 135, 77, 15, 188, 231, 137, 105, 9, 110]), layoutVersion := 1, digest := (bytes [112, 14, 250, 194, 60, 96, 4, 254, 188, 129, 34, 22, 229, 216, 197, 79, 187, 203, 126, 233, 172, 49, 4, 79, 99, 202, 220, 56, 16, 245, 157, 151]) }, logicalIndex := 0, digest := (bytes [50, 159, 254, 165, 98, 207, 226, 230, 224, 20, 148, 173, 186, 242, 215, 233, 134, 227, 55, 122, 49, 233, 29, 55, 222, 117, 247, 159, 14, 237, 10, 139]) }, valueDigest := (bytes [219, 8, 51, 136, 6, 165, 64, 201, 92, 219, 214, 171, 112, 211, 82, 38, 105, 118, 212, 115, 167, 239, 36, 209, 63, 108, 13, 59, 134, 234, 32, 123]), digest := (bytes [26, 245, 8, 48, 96, 7, 195, 10, 204, 117, 177, 191, 22, 245, 165, 113, 221, 231, 165, 207, 236, 31, 126, 45, 3, 126, 148, 184, 64, 60, 148, 195]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [45, 71, 203, 160, 194, 189, 1, 30, 95, 127, 177, 249, 43, 213, 108, 119, 112, 254, 97, 173, 156, 157, 66, 135, 77, 15, 188, 231, 137, 105, 9, 110]), layoutVersion := 1, digest := (bytes [112, 14, 250, 194, 60, 96, 4, 254, 188, 129, 34, 22, 229, 216, 197, 79, 187, 203, 126, 233, 172, 49, 4, 79, 99, 202, 220, 56, 16, 245, 157, 151]) }, logicalIndex := 4, digest := (bytes [146, 86, 139, 7, 96, 42, 26, 213, 188, 51, 22, 67, 199, 191, 115, 7, 28, 141, 210, 255, 224, 78, 49, 221, 196, 247, 207, 30, 22, 195, 173, 49]) }, valueDigest := (bytes [247, 8, 91, 86, 174, 60, 198, 248, 80, 76, 136, 253, 192, 49, 138, 233, 64, 183, 153, 201, 60, 173, 121, 212, 113, 120, 175, 228, 9, 127, 13, 255]), digest := (bytes [192, 110, 242, 237, 142, 80, 143, 141, 49, 184, 241, 224, 64, 5, 40, 86, 227, 115, 16, 125, 243, 95, 140, 192, 131, 152, 202, 227, 61, 206, 5, 157]) }), digest := (bytes [112, 169, 183, 169, 22, 117, 23, 219, 150, 215, 147, 170, 98, 194, 95, 238, 42, 249, 6, 255, 190, 62, 53, 203, 109, 144, 27, 231, 57, 25, 37, 173]) }
  , rootLaneCommitment := { timeLen := 5, commitments := { commitmentCount := 38, digest := (bytes [251, 52, 122, 0, 121, 106, 12, 175, 109, 64, 25, 255, 113, 78, 245, 166, 161, 177, 150, 198, 14, 38, 65, 237, 248, 77, 212, 154, 231, 156, 229, 92]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [251, 52, 122, 0, 121, 106, 12, 175, 109, 64, 25, 255, 113, 78, 245, 166, 161, 177, 150, 198, 14, 38, 65, 237, 248, 77, 212, 154, 231, 156, 229, 92]), layoutVersion := 3, digest := (bytes [81, 52, 31, 127, 221, 91, 78, 127, 199, 0, 31, 143, 136, 90, 4, 32, 120, 56, 138, 78, 122, 226, 185, 64, 24, 32, 158, 55, 246, 183, 177, 78]) }, logicalIndex := 0, digest := (bytes [242, 114, 153, 40, 74, 253, 96, 126, 101, 13, 123, 125, 75, 21, 244, 110, 226, 166, 232, 92, 106, 246, 127, 227, 130, 121, 164, 94, 228, 79, 123, 250]) }, valueDigest := (bytes [219, 8, 51, 136, 6, 165, 64, 201, 92, 219, 214, 171, 112, 211, 82, 38, 105, 118, 212, 115, 167, 239, 36, 209, 63, 108, 13, 59, 134, 234, 32, 123]), digest := (bytes [55, 64, 227, 137, 13, 60, 159, 86, 13, 107, 122, 210, 50, 71, 172, 195, 224, 231, 124, 32, 173, 179, 230, 114, 99, 169, 52, 12, 216, 69, 62, 70]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [251, 52, 122, 0, 121, 106, 12, 175, 109, 64, 25, 255, 113, 78, 245, 166, 161, 177, 150, 198, 14, 38, 65, 237, 248, 77, 212, 154, 231, 156, 229, 92]), layoutVersion := 3, digest := (bytes [81, 52, 31, 127, 221, 91, 78, 127, 199, 0, 31, 143, 136, 90, 4, 32, 120, 56, 138, 78, 122, 226, 185, 64, 24, 32, 158, 55, 246, 183, 177, 78]) }, logicalIndex := 4, digest := (bytes [60, 126, 86, 51, 72, 107, 215, 93, 182, 107, 45, 2, 105, 180, 237, 178, 40, 68, 236, 195, 155, 124, 166, 64, 112, 42, 91, 36, 65, 88, 66, 133]) }, valueDigest := (bytes [247, 8, 91, 86, 174, 60, 198, 248, 80, 76, 136, 253, 192, 49, 138, 233, 64, 183, 153, 201, 60, 173, 121, 212, 113, 120, 175, 228, 9, 127, 13, 255]), digest := (bytes [33, 208, 172, 230, 136, 24, 67, 101, 152, 98, 163, 128, 55, 104, 213, 43, 113, 230, 52, 124, 122, 33, 143, 134, 6, 124, 245, 185, 94, 180, 158, 219]) }), digest := (bytes [230, 14, 116, 174, 78, 244, 29, 230, 211, 33, 236, 6, 71, 146, 223, 106, 12, 61, 52, 248, 38, 4, 123, 89, 48, 130, 111, 145, 65, 234, 182, 187]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [112, 169, 183, 169, 22, 117, 23, 219, 150, 215, 147, 170, 98, 194, 95, 238, 42, 249, 6, 255, 190, 62, 53, 203, 109, 144, 27, 231, 57, 25, 37, 173]), rootLaneCommitmentDigest := (bytes [230, 14, 116, 174, 78, 244, 29, 230, 211, 33, 236, 6, 71, 146, 223, 106, 12, 61, 52, 248, 38, 4, 123, 89, 48, 130, 111, 145, 65, 234, 182, 187]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 5, digest := (bytes [165, 47, 175, 142, 167, 104, 47, 158, 220, 160, 29, 34, 249, 206, 101, 174, 109, 117, 163, 134, 31, 118, 67, 176, 30, 172, 150, 82, 128, 151, 117, 202]) }, statementDigest := (bytes [201, 59, 28, 254, 8, 9, 244, 73, 31, 20, 37, 143, 231, 183, 234, 84, 120, 212, 92, 33, 92, 226, 205, 105, 66, 171, 112, 166, 155, 23, 27, 143]), proofDigest := (bytes [198, 107, 116, 211, 59, 109, 160, 89, 36, 122, 8, 83, 54, 64, 108, 129, 219, 142, 83, 20, 17, 39, 155, 221, 192, 242, 212, 22, 219, 149, 240, 172]), digest := (bytes [166, 19, 201, 103, 30, 194, 96, 165, 88, 94, 238, 193, 151, 129, 19, 142, 86, 173, 205, 95, 151, 60, 120, 250, 221, 79, 165, 145, 103, 4, 185, 169]) }
  , digest := (bytes [245, 237, 146, 24, 215, 157, 130, 50, 11, 122, 125, 198, 60, 192, 95, 96, 36, 101, 188, 66, 69, 96, 139, 58, 1, 135, 109, 202, 216, 140, 40, 58])
}
}
    , exportedStatement := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , foldSchedule := Nightstream.FoldSchedule.wholeTrace
  , chunkCount := 1
  , stageClaimsDigest := (bytes [44, 64, 129, 40, 96, 56, 193, 221, 169, 135, 32, 0, 147, 107, 199, 145, 192, 142, 197, 93, 220, 208, 22, 50, 240, 244, 191, 42, 62, 210, 67, 38])
  , stagePackagesDigest := (bytes [169, 112, 199, 38, 3, 79, 161, 120, 167, 197, 180, 90, 41, 189, 67, 67, 133, 4, 65, 201, 128, 185, 135, 51, 168, 162, 183, 184, 99, 255, 154, 145])
  , kernelOpeningDigest := (bytes [244, 39, 228, 128, 30, 118, 216, 238, 132, 5, 86, 181, 31, 154, 232, 6, 85, 232, 212, 81, 207, 207, 101, 5, 101, 1, 9, 52, 212, 236, 145, 232])
  , preparedStepBindingsDigest := (bytes [92, 181, 55, 62, 187, 26, 5, 222, 206, 92, 93, 243, 238, 48, 28, 35, 255, 239, 240, 213, 119, 134, 33, 37, 100, 69, 212, 13, 101, 131, 205, 238])
  , executionDigest := (bytes [70, 186, 27, 221, 111, 194, 9, 233, 22, 165, 61, 66, 109, 14, 68, 56, 20, 142, 12, 163, 129, 72, 137, 138, 73, 128, 143, 30, 210, 235, 246, 84])
  , finalStateDigest := (bytes [214, 96, 46, 11, 248, 13, 42, 132, 141, 230, 122, 96, 107, 25, 184, 147, 236, 239, 156, 156, 238, 48, 125, 174, 84, 192, 136, 2, 174, 167, 250, 118])
  , transcriptFinalDigest := (bytes [136, 204, 167, 75, 151, 108, 16, 255, 16, 185, 218, 191, 68, 240, 50, 151, 48, 10, 175, 78, 253, 43, 200, 70, 235, 238, 182, 242, 224, 164, 60, 127])
  , mainLaneSurfaceDigest := (bytes [161, 239, 65, 47, 116, 8, 58, 52, 113, 131, 236, 82, 144, 148, 245, 79, 217, 22, 169, 51, 222, 255, 14, 72, 146, 29, 189, 204, 112, 147, 40, 92])
  , rootLaneColumnsDigest := (bytes [112, 169, 183, 169, 22, 117, 23, 219, 150, 215, 147, 170, 98, 194, 95, 238, 42, 249, 6, 255, 190, 62, 53, 203, 109, 144, 27, 231, 57, 25, 37, 173])
  , publicStepCount := 5
  , initialPc := 0
  , finalPc := 20
  , halted := true
  , digest := (bytes [218, 237, 194, 188, 127, 76, 39, 150, 111, 36, 132, 10, 20, 26, 149, 216, 6, 210, 193, 132, 16, 77, 121, 28, 209, 49, 218, 69, 123, 84, 72, 19])
}
    , exportedClaims := {
  accepted := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , statement := { proofStatementDigest := (bytes [218, 237, 194, 188, 127, 76, 39, 150, 111, 36, 132, 10, 20, 26, 149, 216, 6, 210, 193, 132, 16, 77, 121, 28, 209, 49, 218, 69, 123, 84, 72, 19]), kernelOpeningDigest := (bytes [244, 39, 228, 128, 30, 118, 216, 238, 132, 5, 86, 181, 31, 154, 232, 6, 85, 232, 212, 81, 207, 207, 101, 5, 101, 1, 9, 52, 212, 236, 145, 232]), digest := (bytes [183, 253, 175, 157, 62, 36, 250, 110, 202, 185, 230, 144, 95, 103, 254, 137, 98, 68, 167, 32, 128, 141, 105, 140, 128, 55, 86, 151, 214, 223, 222, 71]) }
  , mainLane := { mainLaneBundleDigest := (bytes [166, 19, 201, 103, 30, 194, 96, 165, 88, 94, 238, 193, 151, 129, 19, 142, 86, 173, 205, 95, 151, 60, 120, 250, 221, 79, 165, 145, 103, 4, 185, 169]), digest := (bytes [190, 115, 221, 0, 238, 185, 128, 213, 141, 165, 14, 174, 39, 28, 26, 70, 78, 71, 209, 155, 196, 74, 161, 216, 139, 194, 193, 226, 193, 95, 197, 225]) }
  , terminal := { finalStateDigest := (bytes [214, 96, 46, 11, 248, 13, 42, 132, 141, 230, 122, 96, 107, 25, 184, 147, 236, 239, 156, 156, 238, 48, 125, 174, 84, 192, 136, 2, 174, 167, 250, 118]), finalPc := 20, halted := true, digest := (bytes [145, 20, 206, 251, 86, 77, 83, 34, 13, 2, 122, 65, 95, 22, 123, 171, 247, 47, 197, 234, 163, 179, 129, 58, 125, 90, 2, 135, 40, 121, 152, 226]) }
  , digest := (bytes [202, 243, 19, 27, 39, 96, 51, 217, 150, 165, 151, 18, 27, 96, 54, 141, 50, 44, 107, 83, 96, 140, 144, 184, 28, 219, 101, 16, 163, 213, 171, 91])
}
  , mainLane := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { mainLaneBundleDigest := (bytes [166, 19, 201, 103, 30, 194, 96, 165, 88, 94, 238, 193, 151, 129, 19, 142, 86, 173, 205, 95, 151, 60, 120, 250, 221, 79, 165, 145, 103, 4, 185, 169]), digest := (bytes [248, 43, 178, 171, 30, 71, 72, 52, 61, 219, 77, 28, 222, 155, 206, 46, 8, 120, 103, 110, 88, 19, 89, 61, 81, 184, 218, 99, 74, 181, 201, 44]) }, digest := (bytes [152, 24, 197, 107, 112, 11, 114, 180, 170, 211, 83, 7, 24, 176, 15, 211, 8, 197, 241, 49, 24, 16, 30, 65, 251, 41, 226, 186, 165, 57, 68, 181]) }
  , opening := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , stages := { stageClaimsDigest := (bytes [44, 64, 129, 40, 96, 56, 193, 221, 169, 135, 32, 0, 147, 107, 199, 145, 192, 142, 197, 93, 220, 208, 22, 50, 240, 244, 191, 42, 62, 210, 67, 38]), stagePackagesDigest := (bytes [169, 112, 199, 38, 3, 79, 161, 120, 167, 197, 180, 90, 41, 189, 67, 67, 133, 4, 65, 201, 128, 185, 135, 51, 168, 162, 183, 184, 99, 255, 154, 145]), kernelOpeningDigest := (bytes [244, 39, 228, 128, 30, 118, 216, 238, 132, 5, 86, 181, 31, 154, 232, 6, 85, 232, 212, 81, 207, 207, 101, 5, 101, 1, 9, 52, 212, 236, 145, 232]), digest := (bytes [108, 234, 197, 129, 155, 130, 9, 43, 67, 219, 131, 138, 107, 228, 208, 153, 165, 224, 239, 57, 69, 25, 229, 70, 96, 4, 128, 130, 222, 247, 92, 55]) }
  , terminal := { preparedStepBindingsDigest := (bytes [92, 181, 55, 62, 187, 26, 5, 222, 206, 92, 93, 243, 238, 48, 28, 35, 255, 239, 240, 213, 119, 134, 33, 37, 100, 69, 212, 13, 101, 131, 205, 238]), executionDigest := (bytes [70, 186, 27, 221, 111, 194, 9, 233, 22, 165, 61, 66, 109, 14, 68, 56, 20, 142, 12, 163, 129, 72, 137, 138, 73, 128, 143, 30, 210, 235, 246, 84]), transcriptFinalDigest := (bytes [136, 204, 167, 75, 151, 108, 16, 255, 16, 185, 218, 191, 68, 240, 50, 151, 48, 10, 175, 78, 253, 43, 200, 70, 235, 238, 182, 242, 224, 164, 60, 127]), digest := (bytes [18, 242, 253, 130, 114, 91, 153, 250, 88, 247, 180, 204, 249, 173, 173, 189, 168, 26, 222, 213, 159, 198, 207, 104, 32, 185, 162, 243, 215, 240, 200, 203]) }
  , digest := (bytes [9, 168, 210, 5, 219, 115, 181, 103, 36, 230, 191, 196, 90, 217, 95, 217, 100, 21, 34, 93, 62, 99, 162, 229, 73, 79, 248, 74, 137, 137, 215, 28])
}
  , jointOpening := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { proofStatementDigest := (bytes [218, 237, 194, 188, 127, 76, 39, 150, 111, 36, 132, 10, 20, 26, 149, 216, 6, 210, 193, 132, 16, 77, 121, 28, 209, 49, 218, 69, 123, 84, 72, 19]), mainLaneClaimDigest := (bytes [152, 24, 197, 107, 112, 11, 114, 180, 170, 211, 83, 7, 24, 176, 15, 211, 8, 197, 241, 49, 24, 16, 30, 65, 251, 41, 226, 186, 165, 57, 68, 181]), kernelOpeningClaimDigest := (bytes [9, 168, 210, 5, 219, 115, 181, 103, 36, 230, 191, 196, 90, 217, 95, 217, 100, 21, 34, 93, 62, 99, 162, 229, 73, 79, 248, 74, 137, 137, 215, 28]), digest := (bytes [109, 34, 119, 20, 251, 164, 227, 136, 219, 178, 151, 58, 181, 185, 118, 164, 221, 107, 213, 12, 97, 122, 181, 177, 79, 47, 179, 222, 233, 188, 116, 54]) }, digest := (bytes [210, 193, 119, 171, 89, 29, 126, 142, 141, 119, 34, 254, 84, 45, 166, 59, 144, 0, 33, 30, 12, 144, 17, 107, 154, 148, 16, 211, 233, 51, 167, 170]) }
  , root0 := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), stages := { stage1Digest := (bytes [180, 42, 129, 179, 124, 135, 212, 151, 194, 155, 111, 92, 136, 232, 113, 76, 56, 79, 211, 209, 190, 95, 243, 229, 22, 35, 90, 1, 212, 71, 253, 137]), stage2Digest := (bytes [22, 68, 145, 88, 70, 235, 218, 223, 184, 4, 4, 2, 46, 118, 45, 170, 162, 155, 203, 98, 78, 226, 202, 3, 189, 168, 151, 175, 235, 8, 242, 75]), stage3Digest := (bytes [2, 183, 132, 95, 231, 115, 83, 2, 8, 179, 51, 169, 210, 224, 230, 178, 60, 35, 73, 58, 195, 121, 109, 163, 86, 206, 95, 244, 250, 18, 169, 79]), digest := (bytes [96, 145, 34, 49, 162, 92, 26, 218, 242, 187, 74, 188, 215, 123, 92, 248, 7, 228, 142, 153, 222, 100, 27, 86, 156, 0, 170, 25, 229, 84, 143, 185]) }, terminal := { root0Digest := (bytes [180, 13, 240, 255, 164, 232, 222, 97, 177, 11, 32, 24, 102, 152, 125, 177, 128, 117, 228, 217, 234, 14, 130, 121, 56, 156, 37, 6, 1, 131, 194, 68]), executionDigest := (bytes [70, 186, 27, 221, 111, 194, 9, 233, 22, 165, 61, 66, 109, 14, 68, 56, 20, 142, 12, 163, 129, 72, 137, 138, 73, 128, 143, 30, 210, 235, 246, 84]), finalStateDigest := (bytes [214, 96, 46, 11, 248, 13, 42, 132, 141, 230, 122, 96, 107, 25, 184, 147, 236, 239, 156, 156, 238, 48, 125, 174, 84, 192, 136, 2, 174, 167, 250, 118]), transcriptFinalDigest := (bytes [136, 204, 167, 75, 151, 108, 16, 255, 16, 185, 218, 191, 68, 240, 50, 151, 48, 10, 175, 78, 253, 43, 200, 70, 235, 238, 182, 242, 224, 164, 60, 127]), digest := (bytes [213, 244, 241, 97, 177, 40, 164, 172, 183, 93, 225, 190, 10, 195, 19, 40, 152, 63, 254, 226, 126, 190, 41, 227, 137, 34, 84, 71, 36, 134, 151, 47]) }, digest := (bytes [16, 54, 5, 224, 19, 147, 39, 41, 62, 117, 79, 5, 192, 146, 168, 85, 177, 5, 98, 171, 145, 19, 246, 69, 29, 46, 105, 232, 168, 246, 52, 98]) }
  , digest := (bytes [53, 132, 170, 8, 41, 176, 11, 236, 73, 95, 181, 242, 69, 53, 230, 3, 56, 71, 153, 163, 192, 175, 235, 130, 18, 12, 252, 34, 107, 126, 137, 124])
}
    , exportedKernelProof := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "native_add_chain_x0_ecall", fixtureId := "native_add_chain_x0_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , executionDigest := (bytes [70, 186, 27, 221, 111, 194, 9, 233, 22, 165, 61, 66, 109, 14, 68, 56, 20, 142, 12, 163, 129, 72, 137, 138, 73, 128, 143, 30, 210, 235, 246, 84])
  , shape := { executionRowCount := 5, realRowCount := 5, effectRowCount := 5, commitRowCount := 5, digest := (bytes [11, 168, 18, 205, 239, 69, 109, 190, 207, 168, 250, 196, 121, 176, 87, 55, 1, 249, 85, 208, 31, 220, 81, 235, 69, 31, 18, 110, 121, 74, 49, 211]) }
  , digest := (bytes [193, 155, 181, 163, 0, 241, 98, 138, 61, 222, 95, 111, 148, 140, 232, 92, 142, 205, 33, 119, 54, 162, 224, 13, 99, 18, 136, 13, 66, 54, 68, 141])
}
  , stages := { summary := { stage1RowCount := 5, stage2RegisterReadCount := 5, stage2RegisterWriteCount := 3, stage2RamEventCount := 0, stage2TwistLinkCount := 5, stage3ContinuityCount := 5, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [127, 245, 117, 2, 192, 95, 67, 93, 241, 19, 209, 157, 161, 123, 253, 176, 245, 164, 142, 188, 245, 245, 1, 246, 5, 187, 151, 213, 108, 120, 65, 185]) }, digest := (bytes [6, 191, 6, 179, 164, 205, 86, 120, 223, 134, 233, 95, 152, 140, 86, 172, 53, 137, 137, 40, 35, 106, 127, 241, 174, 25, 251, 243, 15, 132, 162, 215]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [102, 99, 228, 44, 129, 25, 213, 223, 116, 182, 230, 97, 16, 12, 17, 12, 83, 137, 225, 132, 27, 209, 204, 86, 118, 52, 219, 9, 90, 113, 72, 218]), stage1Digest := (bytes [159, 102, 163, 181, 223, 56, 46, 198, 216, 147, 157, 124, 254, 76, 175, 57, 129, 101, 248, 194, 88, 80, 153, 186, 25, 233, 42, 224, 48, 207, 165, 245]), stage2Digest := (bytes [187, 28, 245, 229, 77, 36, 224, 254, 67, 4, 22, 119, 85, 33, 200, 48, 68, 14, 134, 251, 91, 252, 9, 73, 208, 31, 139, 52, 92, 207, 148, 147]), stage3Digest := (bytes [203, 140, 63, 160, 179, 160, 171, 82, 223, 2, 32, 73, 21, 112, 190, 222, 133, 97, 45, 221, 193, 128, 37, 148, 220, 120, 81, 206, 4, 164, 16, 21]), transcriptDigest := (bytes [136, 204, 167, 75, 151, 108, 16, 255, 16, 185, 218, 191, 68, 240, 50, 151, 48, 10, 175, 78, 253, 43, 200, 70, 235, 238, 182, 242, 224, 164, 60, 127]), executionDigest := (bytes [70, 186, 27, 221, 111, 194, 9, 233, 22, 165, 61, 66, 109, 14, 68, 56, 20, 142, 12, 163, 129, 72, 137, 138, 73, 128, 143, 30, 210, 235, 246, 84]), digest := (bytes [186, 215, 204, 164, 61, 146, 217, 156, 196, 71, 246, 173, 55, 241, 233, 228, 185, 127, 56, 255, 172, 41, 77, 30, 112, 99, 246, 143, 235, 165, 158, 80]) }, statementDigest := (bytes [188, 35, 237, 208, 105, 42, 201, 121, 98, 109, 222, 221, 23, 191, 56, 154, 214, 166, 136, 88, 42, 104, 153, 249, 202, 246, 53, 0, 108, 68, 142, 232]), proofDigest := (bytes [78, 33, 204, 201, 171, 186, 21, 100, 111, 246, 50, 204, 4, 186, 15, 249, 165, 60, 139, 45, 254, 174, 10, 120, 25, 25, 237, 99, 82, 185, 78, 224]), digest := (bytes [44, 64, 129, 40, 96, 56, 193, 221, 169, 135, 32, 0, 147, 107, 199, 145, 192, 142, 197, 93, 220, 208, 22, 50, 240, 244, 191, 42, 62, 210, 67, 38]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [255, 64, 206, 73, 236, 62, 214, 128, 180, 109, 50, 226, 84, 153, 196, 85, 181, 225, 201, 75, 54, 234, 81, 219, 235, 95, 242, 43, 66, 213, 30, 179]), stage1Digest := (bytes [132, 174, 232, 78, 241, 78, 76, 182, 143, 159, 220, 145, 105, 244, 181, 164, 64, 221, 241, 6, 171, 5, 207, 117, 108, 144, 154, 73, 15, 132, 167, 178]), stage2Digest := (bytes [37, 94, 113, 29, 240, 252, 1, 117, 129, 118, 152, 38, 195, 246, 181, 190, 9, 22, 141, 60, 125, 132, 251, 163, 174, 191, 143, 232, 209, 92, 15, 246]), stage3Digest := (bytes [163, 214, 90, 194, 31, 195, 144, 247, 188, 40, 184, 220, 245, 220, 120, 52, 58, 117, 168, 107, 9, 244, 144, 83, 137, 120, 106, 124, 255, 57, 170, 64]), digest := (bytes [195, 9, 161, 59, 207, 206, 56, 159, 0, 93, 219, 152, 50, 239, 113, 225, 170, 41, 144, 52, 90, 59, 40, 248, 10, 11, 182, 150, 238, 67, 32, 249]) }, digest := (bytes [169, 112, 199, 38, 3, 79, 161, 120, 167, 197, 180, 90, 41, 189, 67, 67, 133, 4, 65, 201, 128, 185, 135, 51, 168, 162, 183, 184, 99, 255, 154, 145]) }
  , kernelOpening := { openingDigest := (bytes [191, 26, 131, 191, 145, 77, 181, 80, 69, 162, 195, 108, 155, 0, 244, 231, 25, 112, 123, 63, 223, 23, 125, 42, 234, 230, 155, 148, 90, 121, 31, 178]), bindings := { claimDigest := (bytes [13, 10, 239, 24, 246, 149, 181, 77, 213, 105, 209, 155, 178, 109, 152, 235, 192, 18, 180, 58, 89, 118, 168, 213, 16, 107, 1, 184, 190, 231, 121, 67]), bindingsDigest := (bytes [160, 220, 21, 152, 30, 73, 128, 77, 57, 47, 114, 78, 240, 85, 1, 120, 140, 4, 199, 233, 203, 141, 80, 63, 120, 187, 71, 9, 39, 52, 112, 135]), preparedStepsDigest := (bytes [66, 181, 107, 66, 161, 2, 148, 195, 200, 205, 104, 98, 220, 173, 82, 66, 43, 158, 151, 203, 110, 195, 69, 124, 248, 47, 116, 99, 5, 150, 126, 106]), digest := (bytes [79, 178, 5, 37, 13, 154, 237, 7, 184, 128, 1, 189, 28, 147, 244, 244, 134, 233, 239, 19, 136, 13, 89, 27, 246, 123, 44, 216, 138, 32, 255, 133]) }, digest := (bytes [244, 39, 228, 128, 30, 118, 216, 238, 132, 5, 86, 181, 31, 154, 232, 6, 85, 232, 212, 81, 207, 207, 101, 5, 101, 1, 9, 52, 212, 236, 145, 232]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [92, 181, 55, 62, 187, 26, 5, 222, 206, 92, 93, 243, 238, 48, 28, 35, 255, 239, 240, 213, 119, 134, 33, 37, 100, 69, 212, 13, 101, 131, 205, 238]), terminal := { root0Digest := (bytes [180, 13, 240, 255, 164, 232, 222, 97, 177, 11, 32, 24, 102, 152, 125, 177, 128, 117, 228, 217, 234, 14, 130, 121, 56, 156, 37, 6, 1, 131, 194, 68]), executionDigest := (bytes [70, 186, 27, 221, 111, 194, 9, 233, 22, 165, 61, 66, 109, 14, 68, 56, 20, 142, 12, 163, 129, 72, 137, 138, 73, 128, 143, 30, 210, 235, 246, 84]), finalStateDigest := (bytes [214, 96, 46, 11, 248, 13, 42, 132, 141, 230, 122, 96, 107, 25, 184, 147, 236, 239, 156, 156, 238, 48, 125, 174, 84, 192, 136, 2, 174, 167, 250, 118]), transcriptFinalDigest := (bytes [136, 204, 167, 75, 151, 108, 16, 255, 16, 185, 218, 191, 68, 240, 50, 151, 48, 10, 175, 78, 253, 43, 200, 70, 235, 238, 182, 242, 224, 164, 60, 127]), finalPc := 20, halted := true, digest := (bytes [46, 53, 82, 173, 82, 35, 97, 250, 161, 164, 39, 172, 225, 175, 4, 238, 61, 250, 79, 130, 107, 238, 171, 12, 66, 235, 183, 204, 23, 188, 39, 174]) }, digest := (bytes [31, 113, 49, 14, 201, 59, 104, 199, 170, 13, 40, 40, 195, 100, 243, 115, 83, 121, 199, 124, 146, 36, 36, 100, 148, 156, 89, 44, 86, 216, 162, 75]) }, statementDigest := (bytes [69, 69, 116, 129, 28, 17, 174, 127, 189, 25, 147, 47, 155, 225, 89, 234, 135, 140, 227, 152, 37, 66, 159, 35, 174, 227, 193, 97, 18, 168, 240, 210]), proofDigest := (bytes [21, 175, 18, 102, 76, 30, 83, 85, 134, 14, 119, 168, 208, 52, 207, 3, 205, 91, 39, 14, 90, 126, 234, 114, 249, 17, 200, 168, 205, 120, 50, 192]), digest := (bytes [37, 106, 226, 189, 67, 61, 201, 93, 89, 128, 231, 137, 210, 201, 205, 185, 3, 195, 200, 144, 161, 94, 7, 198, 188, 6, 136, 242, 61, 71, 29, 143]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [45, 71, 203, 160, 194, 189, 1, 30, 95, 127, 177, 249, 43, 213, 108, 119, 112, 254, 97, 173, 156, 157, 66, 135, 77, 15, 188, 231, 137, 105, 9, 110]), layoutVersion := 1, digest := (bytes [112, 14, 250, 194, 60, 96, 4, 254, 188, 129, 34, 22, 229, 216, 197, 79, 187, 203, 126, 233, 172, 49, 4, 79, 99, 202, 220, 56, 16, 245, 157, 151]) }, rowWidth := 38, timeLen := 5, columnDigests := [(bytes [113, 50, 60, 138, 88, 147, 143, 114, 209, 102, 140, 109, 141, 130, 13, 65, 154, 83, 29, 54, 165, 27, 195, 207, 252, 83, 167, 120, 56, 155, 143, 109]), (bytes [164, 156, 12, 202, 128, 158, 166, 79, 50, 246, 26, 100, 33, 104, 153, 108, 231, 66, 5, 3, 94, 76, 41, 81, 13, 128, 233, 62, 40, 19, 215, 212]), (bytes [104, 86, 253, 80, 246, 180, 248, 154, 56, 26, 223, 106, 196, 169, 105, 55, 112, 123, 51, 7, 215, 60, 203, 20, 133, 2, 161, 155, 25, 94, 39, 31]), (bytes [4, 37, 191, 199, 27, 131, 127, 106, 23, 23, 164, 92, 246, 105, 210, 216, 164, 185, 128, 142, 255, 92, 5, 246, 36, 198, 85, 173, 19, 19, 230, 153]), (bytes [63, 82, 148, 11, 209, 51, 62, 242, 159, 229, 6, 212, 45, 165, 107, 74, 200, 142, 213, 63, 249, 218, 45, 61, 117, 144, 214, 116, 85, 207, 59, 178]), (bytes [210, 91, 66, 251, 135, 221, 36, 120, 13, 231, 174, 124, 106, 188, 187, 95, 106, 92, 112, 71, 220, 221, 9, 160, 52, 0, 227, 137, 192, 109, 223, 149]), (bytes [36, 247, 205, 134, 106, 32, 140, 157, 122, 229, 42, 10, 55, 110, 203, 127, 250, 34, 223, 50, 228, 244, 4, 241, 135, 200, 51, 77, 13, 125, 215, 9]), (bytes [58, 231, 30, 59, 177, 129, 0, 146, 229, 159, 0, 116, 238, 53, 40, 31, 46, 183, 127, 114, 226, 2, 33, 41, 114, 122, 79, 49, 152, 248, 132, 225]), (bytes [16, 166, 173, 204, 197, 96, 81, 23, 174, 247, 123, 173, 160, 1, 215, 78, 87, 237, 64, 153, 255, 223, 20, 26, 202, 114, 66, 221, 15, 90, 40, 102]), (bytes [56, 18, 253, 133, 46, 231, 152, 83, 26, 236, 25, 57, 166, 126, 144, 136, 201, 227, 105, 149, 194, 180, 125, 228, 122, 73, 207, 99, 35, 63, 193, 227]), (bytes [171, 162, 226, 116, 85, 67, 180, 225, 135, 53, 69, 80, 34, 0, 56, 31, 235, 115, 202, 243, 205, 132, 24, 215, 163, 123, 136, 58, 65, 165, 16, 20]), (bytes [160, 130, 202, 0, 154, 199, 5, 40, 30, 4, 250, 162, 112, 94, 21, 91, 216, 186, 62, 153, 245, 185, 186, 93, 248, 174, 116, 46, 116, 21, 218, 118]), (bytes [248, 43, 168, 152, 51, 77, 95, 23, 132, 5, 223, 243, 178, 225, 37, 246, 25, 224, 185, 100, 109, 161, 228, 41, 20, 188, 215, 100, 233, 156, 56, 187]), (bytes [43, 165, 79, 227, 192, 227, 229, 114, 137, 98, 247, 183, 149, 60, 181, 180, 183, 27, 148, 200, 111, 58, 237, 28, 252, 97, 226, 9, 247, 227, 203, 162]), (bytes [29, 217, 189, 89, 151, 246, 187, 208, 140, 159, 85, 103, 77, 104, 217, 4, 240, 201, 192, 135, 37, 250, 218, 243, 219, 70, 188, 1, 131, 20, 143, 164]), (bytes [218, 15, 164, 119, 26, 89, 153, 76, 195, 50, 55, 158, 39, 57, 253, 24, 64, 230, 89, 54, 164, 47, 223, 90, 24, 194, 243, 188, 112, 39, 74, 0]), (bytes [249, 165, 44, 168, 18, 125, 65, 76, 51, 110, 93, 193, 12, 212, 163, 81, 53, 26, 162, 66, 63, 100, 116, 243, 112, 137, 118, 14, 176, 24, 222, 159]), (bytes [11, 185, 133, 252, 50, 244, 35, 237, 167, 173, 175, 155, 13, 76, 146, 252, 114, 4, 198, 228, 91, 62, 90, 251, 253, 108, 66, 173, 181, 43, 114, 60]), (bytes [118, 104, 94, 12, 171, 3, 100, 43, 163, 51, 98, 0, 105, 201, 187, 207, 164, 190, 117, 22, 243, 3, 26, 197, 37, 180, 195, 107, 243, 137, 220, 124]), (bytes [164, 26, 251, 214, 133, 166, 36, 43, 117, 5, 240, 52, 163, 40, 219, 81, 176, 185, 168, 189, 219, 54, 240, 69, 240, 249, 122, 226, 140, 80, 170, 67]), (bytes [166, 212, 193, 165, 216, 77, 223, 22, 85, 148, 36, 46, 240, 197, 91, 192, 178, 249, 84, 99, 56, 189, 17, 175, 26, 146, 194, 235, 103, 203, 78, 106]), (bytes [117, 242, 101, 249, 21, 218, 127, 164, 230, 14, 233, 247, 199, 35, 201, 180, 129, 56, 152, 49, 20, 39, 58, 252, 143, 181, 103, 38, 215, 227, 205, 255]), (bytes [222, 141, 194, 19, 109, 181, 115, 128, 236, 90, 109, 50, 95, 37, 244, 239, 168, 246, 17, 195, 87, 245, 230, 227, 255, 210, 73, 185, 49, 105, 109, 248]), (bytes [84, 171, 113, 129, 86, 184, 33, 237, 183, 186, 33, 92, 163, 226, 172, 65, 152, 219, 38, 16, 100, 38, 111, 238, 165, 33, 31, 245, 51, 91, 249, 130]), (bytes [184, 255, 183, 155, 140, 77, 208, 108, 65, 102, 102, 53, 227, 82, 217, 107, 51, 138, 198, 79, 204, 224, 237, 67, 85, 170, 208, 32, 254, 253, 20, 25]), (bytes [165, 57, 236, 253, 245, 15, 151, 126, 139, 13, 166, 53, 101, 72, 25, 126, 18, 64, 110, 194, 120, 104, 198, 139, 62, 39, 232, 112, 9, 14, 39, 30]), (bytes [220, 78, 224, 98, 176, 132, 208, 205, 192, 85, 122, 166, 187, 69, 150, 200, 20, 30, 207, 74, 64, 208, 244, 219, 223, 190, 126, 203, 181, 182, 105, 72]), (bytes [167, 92, 69, 232, 129, 215, 150, 22, 142, 134, 186, 133, 122, 187, 98, 237, 109, 67, 169, 68, 16, 1, 0, 92, 129, 181, 145, 172, 134, 6, 57, 205]), (bytes [96, 0, 65, 107, 248, 48, 245, 113, 184, 191, 123, 32, 253, 213, 255, 207, 238, 64, 121, 47, 71, 116, 44, 209, 191, 98, 86, 211, 242, 146, 189, 253]), (bytes [231, 38, 189, 225, 191, 28, 138, 109, 137, 172, 136, 41, 0, 71, 10, 98, 82, 251, 63, 57, 134, 215, 207, 171, 22, 74, 131, 24, 248, 187, 249, 139]), (bytes [97, 115, 66, 52, 209, 119, 244, 26, 211, 179, 72, 158, 73, 50, 167, 139, 193, 248, 17, 168, 194, 18, 40, 36, 247, 217, 33, 69, 229, 217, 187, 137]), (bytes [104, 29, 194, 189, 239, 145, 194, 228, 166, 76, 154, 100, 169, 199, 26, 134, 252, 202, 252, 43, 213, 142, 242, 213, 255, 181, 81, 2, 47, 120, 226, 78]), (bytes [235, 49, 191, 128, 17, 252, 43, 130, 234, 138, 63, 235, 22, 122, 39, 9, 154, 168, 135, 151, 54, 180, 125, 133, 235, 6, 32, 243, 247, 58, 14, 141]), (bytes [203, 190, 166, 159, 209, 140, 180, 196, 75, 57, 130, 2, 89, 126, 203, 127, 16, 89, 187, 132, 95, 49, 171, 164, 127, 162, 189, 129, 74, 157, 57, 123]), (bytes [133, 97, 222, 172, 108, 224, 100, 38, 133, 82, 44, 62, 153, 42, 213, 206, 217, 200, 97, 197, 218, 106, 13, 74, 224, 64, 192, 64, 26, 89, 139, 91]), (bytes [170, 154, 45, 6, 188, 185, 88, 196, 229, 167, 43, 205, 233, 108, 55, 179, 176, 186, 4, 153, 204, 108, 150, 247, 84, 185, 23, 182, 159, 241, 182, 243]), (bytes [130, 173, 59, 185, 58, 8, 237, 139, 107, 135, 0, 131, 132, 73, 144, 156, 45, 9, 228, 30, 200, 84, 33, 41, 132, 180, 81, 15, 71, 200, 224, 49]), (bytes [142, 185, 27, 84, 132, 190, 160, 121, 218, 162, 8, 170, 126, 198, 197, 139, 11, 168, 143, 88, 101, 75, 56, 240, 14, 204, 255, 67, 55, 121, 123, 195])], familyDigest := (bytes [45, 71, 203, 160, 194, 189, 1, 30, 95, 127, 177, 249, 43, 213, 108, 119, 112, 254, 97, 173, 156, 157, 66, 135, 77, 15, 188, 231, 137, 105, 9, 110]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [45, 71, 203, 160, 194, 189, 1, 30, 95, 127, 177, 249, 43, 213, 108, 119, 112, 254, 97, 173, 156, 157, 66, 135, 77, 15, 188, 231, 137, 105, 9, 110]), layoutVersion := 1, digest := (bytes [112, 14, 250, 194, 60, 96, 4, 254, 188, 129, 34, 22, 229, 216, 197, 79, 187, 203, 126, 233, 172, 49, 4, 79, 99, 202, 220, 56, 16, 245, 157, 151]) }, logicalIndex := 0, digest := (bytes [50, 159, 254, 165, 98, 207, 226, 230, 224, 20, 148, 173, 186, 242, 215, 233, 134, 227, 55, 122, 49, 233, 29, 55, 222, 117, 247, 159, 14, 237, 10, 139]) }, valueDigest := (bytes [219, 8, 51, 136, 6, 165, 64, 201, 92, 219, 214, 171, 112, 211, 82, 38, 105, 118, 212, 115, 167, 239, 36, 209, 63, 108, 13, 59, 134, 234, 32, 123]), digest := (bytes [26, 245, 8, 48, 96, 7, 195, 10, 204, 117, 177, 191, 22, 245, 165, 113, 221, 231, 165, 207, 236, 31, 126, 45, 3, 126, 148, 184, 64, 60, 148, 195]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [45, 71, 203, 160, 194, 189, 1, 30, 95, 127, 177, 249, 43, 213, 108, 119, 112, 254, 97, 173, 156, 157, 66, 135, 77, 15, 188, 231, 137, 105, 9, 110]), layoutVersion := 1, digest := (bytes [112, 14, 250, 194, 60, 96, 4, 254, 188, 129, 34, 22, 229, 216, 197, 79, 187, 203, 126, 233, 172, 49, 4, 79, 99, 202, 220, 56, 16, 245, 157, 151]) }, logicalIndex := 4, digest := (bytes [146, 86, 139, 7, 96, 42, 26, 213, 188, 51, 22, 67, 199, 191, 115, 7, 28, 141, 210, 255, 224, 78, 49, 221, 196, 247, 207, 30, 22, 195, 173, 49]) }, valueDigest := (bytes [247, 8, 91, 86, 174, 60, 198, 248, 80, 76, 136, 253, 192, 49, 138, 233, 64, 183, 153, 201, 60, 173, 121, 212, 113, 120, 175, 228, 9, 127, 13, 255]), digest := (bytes [192, 110, 242, 237, 142, 80, 143, 141, 49, 184, 241, 224, 64, 5, 40, 86, 227, 115, 16, 125, 243, 95, 140, 192, 131, 152, 202, 227, 61, 206, 5, 157]) }), digest := (bytes [112, 169, 183, 169, 22, 117, 23, 219, 150, 215, 147, 170, 98, 194, 95, 238, 42, 249, 6, 255, 190, 62, 53, 203, 109, 144, 27, 231, 57, 25, 37, 173]) }
  , rootLaneCommitment := { timeLen := 5, commitments := { commitmentCount := 38, digest := (bytes [251, 52, 122, 0, 121, 106, 12, 175, 109, 64, 25, 255, 113, 78, 245, 166, 161, 177, 150, 198, 14, 38, 65, 237, 248, 77, 212, 154, 231, 156, 229, 92]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [251, 52, 122, 0, 121, 106, 12, 175, 109, 64, 25, 255, 113, 78, 245, 166, 161, 177, 150, 198, 14, 38, 65, 237, 248, 77, 212, 154, 231, 156, 229, 92]), layoutVersion := 3, digest := (bytes [81, 52, 31, 127, 221, 91, 78, 127, 199, 0, 31, 143, 136, 90, 4, 32, 120, 56, 138, 78, 122, 226, 185, 64, 24, 32, 158, 55, 246, 183, 177, 78]) }, logicalIndex := 0, digest := (bytes [242, 114, 153, 40, 74, 253, 96, 126, 101, 13, 123, 125, 75, 21, 244, 110, 226, 166, 232, 92, 106, 246, 127, 227, 130, 121, 164, 94, 228, 79, 123, 250]) }, valueDigest := (bytes [219, 8, 51, 136, 6, 165, 64, 201, 92, 219, 214, 171, 112, 211, 82, 38, 105, 118, 212, 115, 167, 239, 36, 209, 63, 108, 13, 59, 134, 234, 32, 123]), digest := (bytes [55, 64, 227, 137, 13, 60, 159, 86, 13, 107, 122, 210, 50, 71, 172, 195, 224, 231, 124, 32, 173, 179, 230, 114, 99, 169, 52, 12, 216, 69, 62, 70]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [251, 52, 122, 0, 121, 106, 12, 175, 109, 64, 25, 255, 113, 78, 245, 166, 161, 177, 150, 198, 14, 38, 65, 237, 248, 77, 212, 154, 231, 156, 229, 92]), layoutVersion := 3, digest := (bytes [81, 52, 31, 127, 221, 91, 78, 127, 199, 0, 31, 143, 136, 90, 4, 32, 120, 56, 138, 78, 122, 226, 185, 64, 24, 32, 158, 55, 246, 183, 177, 78]) }, logicalIndex := 4, digest := (bytes [60, 126, 86, 51, 72, 107, 215, 93, 182, 107, 45, 2, 105, 180, 237, 178, 40, 68, 236, 195, 155, 124, 166, 64, 112, 42, 91, 36, 65, 88, 66, 133]) }, valueDigest := (bytes [247, 8, 91, 86, 174, 60, 198, 248, 80, 76, 136, 253, 192, 49, 138, 233, 64, 183, 153, 201, 60, 173, 121, 212, 113, 120, 175, 228, 9, 127, 13, 255]), digest := (bytes [33, 208, 172, 230, 136, 24, 67, 101, 152, 98, 163, 128, 55, 104, 213, 43, 113, 230, 52, 124, 122, 33, 143, 134, 6, 124, 245, 185, 94, 180, 158, 219]) }), digest := (bytes [230, 14, 116, 174, 78, 244, 29, 230, 211, 33, 236, 6, 71, 146, 223, 106, 12, 61, 52, 248, 38, 4, 123, 89, 48, 130, 111, 145, 65, 234, 182, 187]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [112, 169, 183, 169, 22, 117, 23, 219, 150, 215, 147, 170, 98, 194, 95, 238, 42, 249, 6, 255, 190, 62, 53, 203, 109, 144, 27, 231, 57, 25, 37, 173]), rootLaneCommitmentDigest := (bytes [230, 14, 116, 174, 78, 244, 29, 230, 211, 33, 236, 6, 71, 146, 223, 106, 12, 61, 52, 248, 38, 4, 123, 89, 48, 130, 111, 145, 65, 234, 182, 187]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 5, digest := (bytes [165, 47, 175, 142, 167, 104, 47, 158, 220, 160, 29, 34, 249, 206, 101, 174, 109, 117, 163, 134, 31, 118, 67, 176, 30, 172, 150, 82, 128, 151, 117, 202]) }, statementDigest := (bytes [201, 59, 28, 254, 8, 9, 244, 73, 31, 20, 37, 143, 231, 183, 234, 84, 120, 212, 92, 33, 92, 226, 205, 105, 66, 171, 112, 166, 155, 23, 27, 143]), proofDigest := (bytes [198, 107, 116, 211, 59, 109, 160, 89, 36, 122, 8, 83, 54, 64, 108, 129, 219, 142, 83, 20, 17, 39, 155, 221, 192, 242, 212, 22, 219, 149, 240, 172]), digest := (bytes [166, 19, 201, 103, 30, 194, 96, 165, 88, 94, 238, 193, 151, 129, 19, 142, 86, 173, 205, 95, 151, 60, 120, 250, 221, 79, 165, 145, 103, 4, 185, 169]) }
  , digest := (bytes [245, 237, 146, 24, 215, 157, 130, 50, 11, 122, 125, 198, 60, 192, 95, 96, 36, 101, 188, 66, 69, 96, 139, 58, 1, 135, 109, 202, 216, 140, 40, 58])
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
    , stage1 := stage1
    , stage2 := stage2
    , stage3 := stage3
    , rootExecution := rootExecution
    , stepComposition := stepComposition
    , soundnessAccounting := soundnessAccounting
    , kernelOpeningBundle := kernelOpeningBundle
    , digest := (bytes [152, 255, 20, 27, 66, 130, 29, 0, 244, 34, 210, 127, 51, 208, 174, 163, 212, 187, 145, 29, 25, 11, 32, 181, 91, 2, 93, 56, 76, 255, 135, 46])
  }

end Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors.Case_native_add_chain_x0_ecall
