import Nightstream.Rv64IM.Generated.AcceptedProofArtifactTypes

set_option maxHeartbeats 0
set_option maxRecDepth 65536

namespace Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors.Case_native_sub_lui_auipc_fence_ecall

open Nightstream.Rv64IM.Generated

def stage1SemInputs : List SemInView :=
  [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, pc := 0, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 1, archRdBefore := 0, archImm := 9, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 1, rdBefore := 0, rdAfter := 9, imm := 9, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, pc := 4, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 2, archRdBefore := 0, archImm := 4, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 2, rdBefore := 0, rdAfter := 4, imm := 4, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, pc := 8, opcode := .sub, traceOpcode := (some .sub), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 1, archRs1Value := 9, archRs2 := 2, archRs2Value := 4, archRd := 3, archRdBefore := 0, archImm := 0, rs1 := 1, rs1Value := 9, rs2 := 2, rs2Value := 4, rd := 3, rdBefore := 0, rdAfter := 5, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, pc := 12, opcode := .lui, traceOpcode := (some .lui), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 4, archRdBefore := 0, archImm := 305418240, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 4, rdBefore := 0, rdAfter := 305418240, imm := 305418240, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 4, stepIndex := 4, sequenceIndex := 0, pc := 16, opcode := .auipc, traceOpcode := (some .auipc), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 5, archRdBefore := 0, archImm := 8192, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 5, rdBefore := 0, rdAfter := 8208, imm := 8192, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 5, stepIndex := 5, sequenceIndex := 0, pc := 20, opcode := .fence, traceOpcode := (some .fence), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 0, archRdBefore := 0, archImm := 0, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 0, rdBefore := 0, rdAfter := 0, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := false, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 6, stepIndex := 6, sequenceIndex := 0, pc := 24, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 0, archRdBefore := 0, archImm := 0, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 0, rdBefore := 0, rdAfter := 0, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := false, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }]

def stage1RowBindings : List Stage1RowBindingView :=
  [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 9437331, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 4, aluResult := 9, effectiveAddr := none, writesRd := true, rd := 1, rdAfter := 9, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 4194579, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 8, aluResult := 4, effectiveAddr := none, writesRd := true, rd := 2, rdAfter := 4, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 1075872179, opcode := .sub, traceOpcode := (some .sub), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 12, aluResult := 5, effectiveAddr := none, writesRd := true, rd := 3, rdAfter := 5, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 12, fetchedWord := 305418807, opcode := .lui, traceOpcode := (some .lui), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 16, aluResult := 305418240, effectiveAddr := none, writesRd := true, rd := 4, rdAfter := 305418240, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 4, stepIndex := 4, sequenceIndex := 0, fetchPc := 16, fetchedWord := 8855, opcode := .auipc, traceOpcode := (some .auipc), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 20, aluResult := 8208, effectiveAddr := none, writesRd := true, rd := 5, rdAfter := 8208, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 5, stepIndex := 5, sequenceIndex := 0, fetchPc := 20, fetchedWord := 15, opcode := .fence, traceOpcode := (some .fence), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 24, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }, { traceIndex := 6, stepIndex := 6, sequenceIndex := 0, fetchPc := 24, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 28, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }]

def stage1 : Stage1ProofBundleView :=
  {
    semInputs := stage1SemInputs
    , rowBindings := stage1RowBindings
    , bytecodeDigest := (bytes [249, 247, 96, 167, 214, 36, 111, 231, 233, 52, 199, 157, 250, 55, 220, 158, 230, 167, 149, 210, 180, 199, 128, 223, 196, 17, 184, 122, 84, 219, 122, 245])
    , aluDigest := (bytes [26, 20, 70, 172, 230, 174, 174, 49, 108, 53, 217, 189, 95, 12, 81, 139, 10, 160, 155, 120, 162, 125, 127, 15, 232, 38, 247, 20, 200, 199, 65, 246])
    , branchDigest := (bytes [121, 96, 33, 20, 22, 29, 215, 162, 160, 130, 119, 39, 248, 242, 249, 76, 249, 95, 212, 72, 83, 128, 11, 178, 204, 85, 150, 22, 116, 172, 242, 224])
    , semantics := { semInputsDigest := (bytes [133, 11, 51, 170, 194, 50, 45, 53, 120, 205, 65, 26, 38, 143, 188, 240, 190, 250, 69, 214, 207, 163, 228, 242, 71, 218, 229, 225, 173, 208, 118, 172]), rowBindingsDigest := (bytes [139, 229, 199, 217, 81, 174, 136, 160, 76, 120, 21, 34, 226, 223, 139, 193, 135, 46, 33, 128, 19, 132, 84, 175, 242, 95, 156, 93, 50, 79, 14, 20]), sequenceCount := 7, helperRowCount := 0, digest := (bytes [255, 50, 107, 241, 192, 75, 203, 220, 105, 172, 231, 27, 31, 112, 102, 66, 61, 207, 245, 167, 102, 122, 202, 242, 178, 125, 219, 173, 111, 17, 169, 178]) }
    , addressCorrectnessDigest := (bytes [150, 31, 3, 32, 230, 183, 228, 242, 198, 209, 248, 130, 148, 41, 47, 0, 89, 141, 139, 88, 82, 222, 253, 65, 109, 109, 62, 210, 170, 56, 143, 18])
    , linkageDigest := (bytes [28, 218, 70, 50, 134, 53, 248, 207, 192, 57, 121, 19, 190, 128, 182, 229, 35, 133, 109, 130, 19, 101, 205, 236, 207, 86, 95, 173, 79, 101, 162, 189])
    , selectedOpening := { claim := { rowsFamilyDigest := (bytes [139, 229, 199, 217, 81, 174, 136, 160, 76, 120, 21, 34, 226, 223, 139, 193, 135, 46, 33, 128, 19, 132, 84, 175, 242, 95, 156, 93, 50, 79, 14, 20]), rowCount := 7, effectRowCount := 7, commitRowCount := 7, realRowCount := 7, preservesX0Count := 2, firstTraceIndex := 0, effectTraceIndex := 0, commitTraceIndex := 0, lastTraceIndex := 6, mix := 4896283865473105481, points := { first := { id := { object := { familyTag := 1, commitmentDigest := (bytes [139, 229, 199, 217, 81, 174, 136, 160, 76, 120, 21, 34, 226, 223, 139, 193, 135, 46, 33, 128, 19, 132, 84, 175, 242, 95, 156, 93, 50, 79, 14, 20]), layoutVersion := 1, digest := (bytes [162, 151, 150, 198, 66, 56, 150, 18, 124, 53, 254, 110, 86, 190, 68, 186, 95, 92, 186, 47, 198, 93, 184, 162, 57, 114, 222, 168, 65, 126, 66, 157]) }, logicalIndex := 0, digest := (bytes [120, 39, 96, 103, 148, 231, 29, 77, 38, 19, 92, 5, 105, 65, 3, 29, 51, 119, 180, 129, 184, 50, 40, 121, 209, 99, 195, 79, 68, 167, 87, 228]) }, valueDigest := (bytes [25, 204, 22, 132, 65, 17, 77, 201, 191, 178, 51, 221, 78, 29, 167, 60, 16, 212, 140, 48, 35, 0, 111, 52, 50, 51, 185, 122, 107, 254, 251, 50]), digest := (bytes [183, 103, 73, 205, 191, 115, 29, 59, 171, 151, 37, 196, 41, 200, 111, 179, 107, 45, 252, 207, 110, 247, 53, 136, 191, 252, 219, 19, 147, 95, 208, 36]) }, effect := { id := { object := { familyTag := 1, commitmentDigest := (bytes [139, 229, 199, 217, 81, 174, 136, 160, 76, 120, 21, 34, 226, 223, 139, 193, 135, 46, 33, 128, 19, 132, 84, 175, 242, 95, 156, 93, 50, 79, 14, 20]), layoutVersion := 1, digest := (bytes [162, 151, 150, 198, 66, 56, 150, 18, 124, 53, 254, 110, 86, 190, 68, 186, 95, 92, 186, 47, 198, 93, 184, 162, 57, 114, 222, 168, 65, 126, 66, 157]) }, logicalIndex := 0, digest := (bytes [120, 39, 96, 103, 148, 231, 29, 77, 38, 19, 92, 5, 105, 65, 3, 29, 51, 119, 180, 129, 184, 50, 40, 121, 209, 99, 195, 79, 68, 167, 87, 228]) }, valueDigest := (bytes [25, 204, 22, 132, 65, 17, 77, 201, 191, 178, 51, 221, 78, 29, 167, 60, 16, 212, 140, 48, 35, 0, 111, 52, 50, 51, 185, 122, 107, 254, 251, 50]), digest := (bytes [183, 103, 73, 205, 191, 115, 29, 59, 171, 151, 37, 196, 41, 200, 111, 179, 107, 45, 252, 207, 110, 247, 53, 136, 191, 252, 219, 19, 147, 95, 208, 36]) }, commit := { id := { object := { familyTag := 1, commitmentDigest := (bytes [139, 229, 199, 217, 81, 174, 136, 160, 76, 120, 21, 34, 226, 223, 139, 193, 135, 46, 33, 128, 19, 132, 84, 175, 242, 95, 156, 93, 50, 79, 14, 20]), layoutVersion := 1, digest := (bytes [162, 151, 150, 198, 66, 56, 150, 18, 124, 53, 254, 110, 86, 190, 68, 186, 95, 92, 186, 47, 198, 93, 184, 162, 57, 114, 222, 168, 65, 126, 66, 157]) }, logicalIndex := 0, digest := (bytes [120, 39, 96, 103, 148, 231, 29, 77, 38, 19, 92, 5, 105, 65, 3, 29, 51, 119, 180, 129, 184, 50, 40, 121, 209, 99, 195, 79, 68, 167, 87, 228]) }, valueDigest := (bytes [25, 204, 22, 132, 65, 17, 77, 201, 191, 178, 51, 221, 78, 29, 167, 60, 16, 212, 140, 48, 35, 0, 111, 52, 50, 51, 185, 122, 107, 254, 251, 50]), digest := (bytes [183, 103, 73, 205, 191, 115, 29, 59, 171, 151, 37, 196, 41, 200, 111, 179, 107, 45, 252, 207, 110, 247, 53, 136, 191, 252, 219, 19, 147, 95, 208, 36]) }, last := { id := { object := { familyTag := 1, commitmentDigest := (bytes [139, 229, 199, 217, 81, 174, 136, 160, 76, 120, 21, 34, 226, 223, 139, 193, 135, 46, 33, 128, 19, 132, 84, 175, 242, 95, 156, 93, 50, 79, 14, 20]), layoutVersion := 1, digest := (bytes [162, 151, 150, 198, 66, 56, 150, 18, 124, 53, 254, 110, 86, 190, 68, 186, 95, 92, 186, 47, 198, 93, 184, 162, 57, 114, 222, 168, 65, 126, 66, 157]) }, logicalIndex := 6, digest := (bytes [152, 210, 174, 215, 152, 72, 58, 75, 202, 186, 102, 16, 131, 175, 137, 144, 217, 41, 155, 220, 112, 233, 5, 134, 145, 218, 117, 215, 171, 166, 18, 80]) }, valueDigest := (bytes [144, 146, 44, 41, 133, 23, 223, 236, 99, 134, 115, 57, 158, 12, 98, 154, 145, 46, 153, 64, 27, 39, 123, 216, 84, 198, 167, 47, 23, 105, 12, 146]), digest := (bytes [77, 134, 228, 243, 192, 196, 162, 8, 168, 134, 50, 175, 177, 199, 8, 159, 142, 185, 179, 203, 12, 123, 15, 250, 168, 148, 22, 196, 169, 68, 135, 93]) } }, digest := (bytes [171, 28, 151, 217, 220, 38, 168, 240, 231, 75, 153, 22, 130, 49, 196, 181, 110, 134, 162, 195, 39, 200, 104, 250, 78, 45, 89, 3, 254, 173, 154, 97]) }, packaged := { statementDigest := (bytes [124, 182, 127, 40, 99, 20, 130, 197, 71, 103, 10, 236, 12, 27, 138, 158, 213, 221, 169, 140, 204, 73, 83, 163, 183, 225, 29, 151, 185, 77, 249, 49]), proofDigest := (bytes [16, 109, 175, 14, 112, 48, 220, 75, 9, 102, 223, 64, 81, 249, 69, 192, 235, 14, 165, 81, 56, 94, 114, 43, 193, 138, 44, 98, 134, 181, 228, 184]) }, digest := (bytes [207, 40, 159, 62, 60, 5, 240, 79, 61, 235, 232, 64, 80, 50, 15, 50, 1, 147, 76, 6, 172, 104, 25, 175, 15, 199, 167, 51, 8, 68, 177, 92]) }
    , digest := (bytes [22, 234, 239, 156, 142, 17, 251, 31, 7, 42, 199, 135, 73, 170, 239, 252, 93, 159, 193, 228, 45, 94, 252, 173, 171, 51, 141, 129, 142, 108, 214, 214])
  }

def stage2RegisterReads : List RegisterReadEventView :=
  [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 0, value := 0 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 0, value := 0 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 1, value := 9 }, { traceIndex := 2, stepIndex := 2, role := .rs2, reg := 2, value := 4 }]

def stage2RegisterWrites : List RegisterWriteEventView :=
  [{ traceIndex := 0, stepIndex := 0, reg := 1, previous := 0, next := 9 }, { traceIndex := 1, stepIndex := 1, reg := 2, previous := 0, next := 4 }, { traceIndex := 2, stepIndex := 2, reg := 3, previous := 0, next := 5 }, { traceIndex := 3, stepIndex := 3, reg := 4, previous := 0, next := 305418240 }, { traceIndex := 4, stepIndex := 4, reg := 5, previous := 0, next := 8208 }]

def stage2RamEvents : List RamEventView :=
  []

def stage2TwistLinks : List TwistLinkEventView :=
  [{ traceIndex := 0, stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 9), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 1, family := .nativeAlu, routedWriteValue := (some 4), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 2, family := .nativeAlu, routedWriteValue := (some 5), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 3, family := .nativeAlu, routedWriteValue := (some 305418240), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 4, stepIndex := 4, family := .nativeAlu, routedWriteValue := (some 8208), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 5, stepIndex := 5, family := .nativeAlu, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 6, stepIndex := 6, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]

def stage2 : Stage2ProofBundleView :=
  {
    registerReads := stage2RegisterReads
    , registerWrites := stage2RegisterWrites
    , ramEvents := stage2RamEvents
    , registerDigest := (bytes [5, 16, 134, 120, 255, 208, 61, 119, 85, 244, 129, 91, 153, 103, 201, 70, 169, 168, 52, 63, 132, 151, 228, 146, 203, 253, 104, 159, 64, 110, 9, 251])
    , ramDigest := (bytes [209, 217, 105, 43, 209, 229, 156, 61, 92, 164, 94, 232, 52, 214, 73, 229, 72, 188, 139, 122, 165, 123, 201, 212, 205, 15, 247, 197, 165, 154, 109, 246])
    , temporal := { twistLinks := stage2TwistLinks, registerTimelineDigest := (bytes [81, 247, 122, 57, 53, 127, 117, 83, 97, 18, 93, 137, 14, 85, 181, 201, 158, 235, 50, 63, 51, 129, 33, 130, 110, 50, 20, 192, 45, 246, 218, 192]), ramTimelineDigest := (bytes [8, 117, 17, 140, 128, 180, 240, 140, 250, 181, 90, 134, 147, 17, 197, 122, 220, 8, 66, 15, 193, 254, 11, 122, 115, 210, 233, 239, 55, 132, 31, 228]), twistLinksDigest := (bytes [20, 204, 230, 81, 202, 185, 153, 53, 60, 87, 56, 187, 213, 0, 230, 5, 245, 235, 146, 200, 231, 37, 107, 186, 187, 20, 17, 4, 45, 44, 227, 38]), digest := (bytes [34, 170, 148, 15, 184, 157, 106, 48, 29, 142, 165, 122, 227, 113, 247, 204, 1, 33, 7, 121, 229, 124, 95, 130, 7, 94, 37, 123, 174, 122, 211, 10]) }
    , semantics := { registerReadsFamilyDigest := (bytes [179, 162, 84, 248, 145, 58, 81, 7, 174, 231, 61, 54, 79, 253, 38, 47, 31, 63, 123, 229, 106, 13, 22, 215, 78, 155, 43, 80, 170, 197, 163, 226]), registerWritesFamilyDigest := (bytes [134, 187, 195, 109, 79, 39, 47, 60, 210, 95, 68, 81, 169, 35, 19, 98, 2, 5, 202, 184, 223, 37, 151, 144, 217, 184, 248, 145, 133, 209, 27, 248]), ramEventsFamilyDigest := (bytes [85, 17, 108, 38, 84, 5, 109, 213, 145, 137, 203, 96, 117, 127, 130, 193, 117, 29, 27, 219, 228, 58, 7, 214, 144, 155, 66, 38, 127, 8, 241, 95]), twistLinksFamilyDigest := (bytes [180, 85, 164, 199, 102, 190, 215, 157, 137, 96, 73, 116, 169, 29, 163, 193, 191, 119, 199, 182, 222, 49, 203, 217, 100, 14, 192, 199, 149, 125, 240, 27]), rowCount := 7, registerEventCount := 9, ramEventCount := 0, digest := (bytes [74, 182, 110, 136, 242, 124, 162, 77, 52, 164, 99, 103, 111, 223, 15, 103, 211, 254, 211, 158, 231, 107, 214, 228, 106, 123, 170, 107, 140, 123, 20, 119]) }
    , linkageDigest := (bytes [203, 93, 254, 9, 165, 44, 137, 49, 255, 134, 114, 57, 38, 126, 110, 117, 97, 131, 53, 246, 44, 119, 233, 67, 74, 48, 12, 39, 183, 74, 41, 106])
    , selectedOpening := { claim := { registerReadsFamilyDigest := (bytes [179, 162, 84, 248, 145, 58, 81, 7, 174, 231, 61, 54, 79, 253, 38, 47, 31, 63, 123, 229, 106, 13, 22, 215, 78, 155, 43, 80, 170, 197, 163, 226]), registerWritesFamilyDigest := (bytes [134, 187, 195, 109, 79, 39, 47, 60, 210, 95, 68, 81, 169, 35, 19, 98, 2, 5, 202, 184, 223, 37, 151, 144, 217, 184, 248, 145, 133, 209, 27, 248]), ramEventsFamilyDigest := (bytes [85, 17, 108, 38, 84, 5, 109, 213, 145, 137, 203, 96, 117, 127, 130, 193, 117, 29, 27, 219, 228, 58, 7, 214, 144, 155, 66, 38, 127, 8, 241, 95]), twistLinksFamilyDigest := (bytes [180, 85, 164, 199, 102, 190, 215, 157, 137, 96, 73, 116, 169, 29, 163, 193, 191, 119, 199, 182, 222, 49, 203, 217, 100, 14, 192, 199, 149, 125, 240, 27]), registerReadCount := 4, registerWriteCount := 5, ramEventCount := 0, twistLinkCount := 7, ramReadCount := 0, ramWriteCount := 0, regMix := 7033248085425099487, ramMix := 8169386753030433916, points := { firstRead := (some { id := { object := { familyTag := 2, commitmentDigest := (bytes [179, 162, 84, 248, 145, 58, 81, 7, 174, 231, 61, 54, 79, 253, 38, 47, 31, 63, 123, 229, 106, 13, 22, 215, 78, 155, 43, 80, 170, 197, 163, 226]), layoutVersion := 1, digest := (bytes [107, 164, 140, 101, 189, 146, 24, 243, 61, 224, 123, 187, 164, 2, 18, 55, 17, 217, 152, 167, 221, 214, 23, 44, 83, 70, 180, 151, 39, 125, 41, 206]) }, logicalIndex := 0, digest := (bytes [208, 79, 206, 177, 128, 224, 61, 58, 51, 137, 160, 6, 12, 20, 75, 250, 77, 62, 184, 194, 231, 225, 180, 183, 247, 203, 95, 148, 12, 206, 124, 154]) }, valueDigest := (bytes [165, 2, 50, 180, 56, 84, 68, 13, 37, 136, 82, 191, 49, 42, 150, 67, 180, 45, 199, 251, 168, 91, 53, 39, 20, 9, 70, 46, 155, 135, 100, 116]), digest := (bytes [245, 135, 75, 240, 32, 85, 148, 101, 244, 31, 95, 236, 129, 191, 129, 170, 178, 242, 0, 31, 71, 160, 2, 243, 75, 31, 26, 43, 237, 74, 118, 232]) }), lastRead := (some { id := { object := { familyTag := 2, commitmentDigest := (bytes [179, 162, 84, 248, 145, 58, 81, 7, 174, 231, 61, 54, 79, 253, 38, 47, 31, 63, 123, 229, 106, 13, 22, 215, 78, 155, 43, 80, 170, 197, 163, 226]), layoutVersion := 1, digest := (bytes [107, 164, 140, 101, 189, 146, 24, 243, 61, 224, 123, 187, 164, 2, 18, 55, 17, 217, 152, 167, 221, 214, 23, 44, 83, 70, 180, 151, 39, 125, 41, 206]) }, logicalIndex := 3, digest := (bytes [24, 231, 193, 50, 157, 15, 205, 91, 115, 114, 19, 61, 90, 53, 6, 213, 30, 224, 229, 52, 182, 184, 36, 115, 237, 7, 188, 149, 238, 162, 171, 79]) }, valueDigest := (bytes [68, 104, 52, 155, 58, 176, 202, 197, 114, 136, 110, 38, 227, 16, 197, 121, 236, 255, 244, 95, 80, 63, 67, 44, 123, 252, 223, 230, 92, 110, 82, 73]), digest := (bytes [250, 2, 4, 193, 91, 172, 227, 208, 185, 2, 150, 85, 30, 220, 149, 89, 32, 136, 127, 62, 134, 222, 41, 102, 122, 63, 181, 108, 58, 58, 211, 123]) }), firstWrite := (some { id := { object := { familyTag := 3, commitmentDigest := (bytes [134, 187, 195, 109, 79, 39, 47, 60, 210, 95, 68, 81, 169, 35, 19, 98, 2, 5, 202, 184, 223, 37, 151, 144, 217, 184, 248, 145, 133, 209, 27, 248]), layoutVersion := 1, digest := (bytes [247, 247, 123, 166, 194, 243, 75, 212, 243, 111, 39, 46, 106, 252, 126, 83, 221, 126, 161, 229, 174, 247, 251, 251, 127, 94, 249, 195, 240, 242, 125, 28]) }, logicalIndex := 0, digest := (bytes [166, 164, 252, 87, 111, 131, 216, 88, 7, 229, 103, 123, 156, 31, 109, 14, 2, 129, 223, 52, 9, 13, 103, 16, 175, 241, 157, 89, 119, 59, 63, 140]) }, valueDigest := (bytes [63, 54, 52, 32, 49, 85, 192, 84, 92, 172, 179, 150, 244, 132, 86, 140, 78, 213, 95, 251, 58, 26, 94, 52, 10, 194, 209, 59, 254, 180, 32, 237]), digest := (bytes [215, 254, 227, 35, 117, 71, 74, 189, 116, 33, 214, 178, 93, 31, 138, 187, 186, 254, 255, 74, 238, 2, 88, 44, 49, 103, 69, 58, 19, 255, 126, 205]) }), lastWrite := (some { id := { object := { familyTag := 3, commitmentDigest := (bytes [134, 187, 195, 109, 79, 39, 47, 60, 210, 95, 68, 81, 169, 35, 19, 98, 2, 5, 202, 184, 223, 37, 151, 144, 217, 184, 248, 145, 133, 209, 27, 248]), layoutVersion := 1, digest := (bytes [247, 247, 123, 166, 194, 243, 75, 212, 243, 111, 39, 46, 106, 252, 126, 83, 221, 126, 161, 229, 174, 247, 251, 251, 127, 94, 249, 195, 240, 242, 125, 28]) }, logicalIndex := 4, digest := (bytes [13, 43, 89, 42, 221, 128, 34, 6, 25, 57, 236, 26, 159, 28, 136, 192, 189, 251, 71, 21, 222, 196, 120, 112, 227, 248, 92, 241, 180, 3, 236, 35]) }, valueDigest := (bytes [236, 61, 63, 225, 246, 217, 144, 73, 41, 154, 117, 190, 198, 86, 72, 203, 146, 150, 167, 186, 245, 11, 179, 146, 103, 170, 38, 188, 22, 217, 57, 184]), digest := (bytes [116, 6, 27, 129, 31, 1, 8, 154, 211, 169, 207, 145, 161, 35, 180, 118, 13, 254, 15, 112, 114, 47, 48, 194, 159, 252, 130, 69, 205, 246, 93, 224]) }), firstRam := none, lastRam := none, firstTwist := (some { id := { object := { familyTag := 5, commitmentDigest := (bytes [180, 85, 164, 199, 102, 190, 215, 157, 137, 96, 73, 116, 169, 29, 163, 193, 191, 119, 199, 182, 222, 49, 203, 217, 100, 14, 192, 199, 149, 125, 240, 27]), layoutVersion := 1, digest := (bytes [228, 116, 95, 56, 191, 231, 105, 169, 224, 99, 100, 105, 32, 205, 90, 187, 129, 222, 29, 207, 46, 79, 42, 194, 72, 247, 205, 198, 49, 188, 91, 107]) }, logicalIndex := 0, digest := (bytes [6, 134, 9, 174, 246, 96, 97, 102, 168, 68, 84, 126, 63, 166, 14, 114, 24, 17, 111, 181, 213, 66, 216, 10, 190, 173, 100, 121, 245, 80, 231, 0]) }, valueDigest := (bytes [185, 28, 253, 107, 78, 107, 173, 143, 28, 249, 207, 87, 148, 176, 48, 117, 60, 197, 135, 69, 210, 169, 23, 13, 45, 195, 151, 14, 0, 141, 152, 48]), digest := (bytes [138, 217, 184, 174, 16, 118, 32, 165, 30, 243, 235, 166, 165, 115, 232, 202, 81, 92, 225, 32, 44, 226, 20, 234, 151, 208, 193, 6, 47, 60, 145, 164]) }), lastTwist := (some { id := { object := { familyTag := 5, commitmentDigest := (bytes [180, 85, 164, 199, 102, 190, 215, 157, 137, 96, 73, 116, 169, 29, 163, 193, 191, 119, 199, 182, 222, 49, 203, 217, 100, 14, 192, 199, 149, 125, 240, 27]), layoutVersion := 1, digest := (bytes [228, 116, 95, 56, 191, 231, 105, 169, 224, 99, 100, 105, 32, 205, 90, 187, 129, 222, 29, 207, 46, 79, 42, 194, 72, 247, 205, 198, 49, 188, 91, 107]) }, logicalIndex := 6, digest := (bytes [52, 71, 237, 188, 117, 40, 92, 106, 152, 92, 243, 48, 104, 25, 223, 111, 36, 118, 196, 97, 22, 232, 202, 169, 121, 185, 143, 179, 199, 213, 34, 208]) }, valueDigest := (bytes [177, 90, 46, 16, 105, 217, 158, 221, 200, 159, 226, 176, 242, 66, 217, 14, 215, 150, 37, 246, 212, 108, 237, 104, 31, 103, 108, 107, 11, 82, 147, 173]), digest := (bytes [24, 21, 161, 164, 122, 6, 118, 209, 97, 105, 32, 97, 106, 82, 213, 210, 160, 188, 37, 150, 123, 230, 236, 141, 46, 76, 131, 147, 27, 107, 39, 84]) }) }, digest := (bytes [228, 46, 9, 189, 217, 204, 190, 217, 58, 36, 141, 173, 192, 54, 38, 79, 18, 36, 23, 129, 95, 253, 2, 5, 112, 170, 246, 206, 235, 247, 193, 103]) }, packaged := { statementDigest := (bytes [213, 190, 152, 213, 38, 69, 154, 207, 248, 220, 135, 162, 39, 60, 3, 129, 38, 215, 210, 33, 66, 23, 204, 77, 157, 48, 160, 236, 22, 221, 233, 158]), proofDigest := (bytes [222, 151, 183, 172, 225, 255, 149, 245, 119, 148, 196, 170, 5, 167, 199, 248, 150, 41, 229, 26, 115, 161, 234, 43, 220, 143, 116, 79, 10, 29, 44, 208]) }, digest := (bytes [91, 238, 67, 192, 173, 230, 176, 69, 21, 217, 100, 79, 117, 10, 31, 183, 249, 182, 54, 243, 26, 41, 183, 69, 215, 140, 117, 247, 219, 146, 110, 164]) }
    , digest := (bytes [149, 49, 246, 190, 142, 51, 194, 59, 46, 172, 44, 229, 255, 116, 51, 134, 34, 36, 17, 12, 21, 141, 1, 68, 22, 10, 168, 19, 81, 187, 127, 226])
  }

def stage3Continuity : List ContinuityEventView :=
  [{ stepIndex := 0, pc := 0, nextPc := 4, successorPc := (some 4), finalStep := false, continuityHolds := true }, { stepIndex := 1, pc := 4, nextPc := 8, successorPc := (some 8), finalStep := false, continuityHolds := true }, { stepIndex := 2, pc := 8, nextPc := 12, successorPc := (some 12), finalStep := false, continuityHolds := true }, { stepIndex := 3, pc := 12, nextPc := 16, successorPc := (some 16), finalStep := false, continuityHolds := true }, { stepIndex := 4, pc := 16, nextPc := 20, successorPc := (some 20), finalStep := false, continuityHolds := true }, { stepIndex := 5, pc := 20, nextPc := 24, successorPc := (some 24), finalStep := false, continuityHolds := true }, { stepIndex := 6, pc := 24, nextPc := 28, successorPc := none, finalStep := true, continuityHolds := true }]

def stage3 : Stage3ProofBundleView :=
  {
    continuity := stage3Continuity
    , halted := true
    , bridgeDigest := (bytes [86, 103, 197, 195, 175, 230, 234, 229, 138, 175, 224, 111, 20, 152, 207, 96, 171, 239, 105, 92, 224, 160, 7, 223, 44, 187, 231, 91, 40, 122, 54, 114])
    , semantics := { continuityDigest := (bytes [231, 127, 209, 33, 200, 198, 35, 28, 95, 20, 80, 177, 211, 177, 192, 24, 18, 155, 147, 233, 52, 13, 201, 10, 11, 228, 186, 38, 18, 206, 255, 74]), rootSemanticRowsDigest := (bytes [111, 130, 143, 170, 185, 255, 79, 237, 60, 170, 31, 135, 174, 129, 165, 226, 87, 243, 1, 41, 177, 16, 52, 36, 158, 105, 170, 9, 154, 242, 229, 168]), rowChunkRoutesDigest := (bytes [210, 211, 133, 148, 162, 150, 85, 66, 2, 24, 230, 163, 67, 64, 160, 246, 143, 119, 48, 189, 194, 114, 28, 76, 211, 182, 93, 15, 73, 83, 209, 85]), preparedStepBindingsDigest := (bytes [112, 197, 82, 217, 71, 142, 123, 243, 160, 171, 19, 245, 183, 154, 255, 69, 152, 22, 80, 238, 217, 143, 85, 100, 93, 29, 74, 46, 45, 249, 112, 40]), stage2TemporalDigest := (bytes [34, 170, 148, 15, 184, 157, 106, 48, 29, 142, 165, 122, 227, 113, 247, 204, 1, 33, 7, 121, 229, 124, 95, 130, 7, 94, 37, 123, 174, 122, 211, 10]), initialPc := 0, finalPc := 28, realRowCount := 7, firstRealStepIndex := 0, lastRealStepIndex := 6, digest := (bytes [188, 163, 27, 52, 221, 123, 120, 113, 195, 255, 112, 101, 48, 33, 200, 85, 75, 130, 194, 222, 75, 178, 13, 76, 190, 51, 69, 141, 137, 18, 61, 194]) }
    , linkageDigest := (bytes [226, 29, 251, 250, 198, 140, 42, 132, 34, 116, 2, 226, 220, 55, 215, 173, 147, 102, 97, 233, 138, 74, 29, 5, 165, 21, 121, 110, 178, 145, 195, 42])
    , selectedOpening := { claim := { continuityFamilyDigest := (bytes [94, 209, 204, 219, 207, 222, 139, 15, 162, 178, 200, 168, 102, 230, 108, 10, 222, 118, 76, 56, 76, 82, 63, 83, 183, 179, 71, 63, 14, 207, 130, 159]), continuityCount := 7, finalStepCount := 1, halted := true, allContinuityHold := true, continuityMix := 13526737568366105716, points := { firstContinuity := (some { id := { object := { familyTag := 6, commitmentDigest := (bytes [94, 209, 204, 219, 207, 222, 139, 15, 162, 178, 200, 168, 102, 230, 108, 10, 222, 118, 76, 56, 76, 82, 63, 83, 183, 179, 71, 63, 14, 207, 130, 159]), layoutVersion := 1, digest := (bytes [40, 174, 116, 139, 25, 243, 175, 145, 153, 240, 85, 170, 23, 150, 84, 150, 190, 215, 68, 209, 210, 6, 8, 236, 153, 87, 22, 207, 151, 168, 136, 52]) }, logicalIndex := 0, digest := (bytes [237, 15, 183, 29, 215, 126, 189, 58, 103, 246, 57, 89, 234, 208, 198, 46, 25, 0, 100, 80, 171, 37, 200, 69, 38, 250, 136, 86, 100, 176, 41, 56]) }, valueDigest := (bytes [7, 131, 85, 21, 57, 109, 53, 31, 137, 53, 98, 18, 170, 36, 28, 200, 149, 213, 171, 159, 119, 200, 36, 230, 30, 35, 30, 11, 252, 126, 240, 63]), digest := (bytes [9, 171, 35, 175, 184, 12, 28, 139, 81, 227, 110, 197, 202, 210, 109, 24, 113, 26, 226, 78, 132, 222, 80, 0, 45, 255, 1, 70, 236, 206, 54, 109]) }), lastContinuity := (some { id := { object := { familyTag := 6, commitmentDigest := (bytes [94, 209, 204, 219, 207, 222, 139, 15, 162, 178, 200, 168, 102, 230, 108, 10, 222, 118, 76, 56, 76, 82, 63, 83, 183, 179, 71, 63, 14, 207, 130, 159]), layoutVersion := 1, digest := (bytes [40, 174, 116, 139, 25, 243, 175, 145, 153, 240, 85, 170, 23, 150, 84, 150, 190, 215, 68, 209, 210, 6, 8, 236, 153, 87, 22, 207, 151, 168, 136, 52]) }, logicalIndex := 6, digest := (bytes [198, 85, 20, 231, 58, 95, 46, 235, 220, 204, 131, 110, 190, 111, 124, 237, 164, 76, 10, 35, 171, 200, 143, 186, 40, 161, 187, 120, 104, 155, 230, 178]) }, valueDigest := (bytes [109, 97, 69, 254, 146, 244, 236, 80, 140, 232, 150, 9, 211, 236, 70, 18, 119, 149, 140, 71, 61, 248, 99, 170, 171, 200, 158, 31, 232, 41, 83, 47]), digest := (bytes [8, 178, 50, 145, 108, 111, 144, 45, 214, 5, 171, 67, 250, 137, 125, 232, 110, 35, 132, 153, 104, 37, 158, 53, 228, 206, 133, 17, 180, 213, 227, 54]) }) }, digest := (bytes [96, 118, 50, 133, 155, 125, 70, 188, 19, 68, 174, 214, 152, 35, 122, 222, 182, 206, 44, 186, 45, 225, 11, 11, 5, 54, 230, 49, 136, 94, 108, 227]) }, packaged := { statementDigest := (bytes [111, 166, 131, 5, 190, 114, 34, 244, 151, 62, 246, 245, 116, 4, 92, 215, 19, 142, 108, 46, 142, 161, 49, 83, 3, 123, 18, 47, 116, 225, 145, 250]), proofDigest := (bytes [255, 59, 205, 236, 81, 116, 199, 196, 93, 79, 97, 34, 84, 90, 19, 102, 111, 31, 168, 74, 198, 224, 208, 166, 196, 67, 42, 94, 9, 177, 27, 130]) }, digest := (bytes [92, 247, 26, 104, 3, 68, 55, 71, 237, 45, 12, 153, 238, 197, 30, 23, 0, 5, 192, 200, 156, 49, 112, 225, 23, 23, 16, 191, 254, 164, 5, 217]) }
    , digest := (bytes [220, 246, 93, 196, 62, 189, 127, 197, 206, 3, 135, 59, 240, 248, 251, 107, 217, 39, 229, 78, 241, 140, 27, 97, 168, 36, 228, 79, 21, 43, 149, 180])
  }

def rootExecutionExecutionRows : List ExpandedRowView :=
  [{
  traceIndex := 0
  , stepIndex := 0
  , sequenceIndex := 0
  , pc := 0
  , nextPc := 4
  , word := 9437331
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
  , rdAfter := 9
  , imm := 9
  , aluResult := 9
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
  , word := 4194579
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
  , rdAfter := 4
  , imm := 4
  , aluResult := 4
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
  , word := 1075872179
  , opcode := .sub
  , traceOpcode := (some .sub)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 9
  , rs2 := 2
  , rs2Value := 4
  , rd := 3
  , rdBefore := 0
  , rdAfter := 5
  , imm := 0
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
  traceIndex := 3
  , stepIndex := 3
  , sequenceIndex := 0
  , pc := 12
  , nextPc := 16
  , word := 305418807
  , opcode := .lui
  , traceOpcode := (some .lui)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 0
  , rs1Value := 0
  , rs2 := 0
  , rs2Value := 0
  , rd := 4
  , rdBefore := 0
  , rdAfter := 305418240
  , imm := 305418240
  , aluResult := 305418240
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
  traceIndex := 4
  , stepIndex := 4
  , sequenceIndex := 0
  , pc := 16
  , nextPc := 20
  , word := 8855
  , opcode := .auipc
  , traceOpcode := (some .auipc)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 0
  , rs1Value := 0
  , rs2 := 0
  , rs2Value := 0
  , rd := 5
  , rdBefore := 0
  , rdAfter := 8208
  , imm := 8192
  , aluResult := 8208
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
  traceIndex := 5
  , stepIndex := 5
  , sequenceIndex := 0
  , pc := 20
  , nextPc := 24
  , word := 15
  , opcode := .fence
  , traceOpcode := (some .fence)
  , traceVirtualOpcode := none
  , family := .nativeAlu
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
  , halted := false
  , isFirstInSequence := true
  , virtualSequenceRemaining := none
  , isEffectRow := true
  , isCommitRow := true
  , isReal := true
}, {
  traceIndex := 6
  , stepIndex := 6
  , sequenceIndex := 0
  , pc := 24
  , nextPc := 28
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
  [{ traceIndex := 0, values := [1, 0, 0, 4, 0, 0, 0, 0, 0, 9, 0, 9, 0, 9, 0, 4, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [49, 112, 41, 120, 103, 26, 24, 17, 240, 51, 88, 180, 158, 199, 42, 251, 183, 57, 20, 149, 1, 43, 127, 249, 47, 108, 100, 231, 221, 153, 232, 90]), digest := (bytes [164, 59, 59, 232, 207, 90, 160, 229, 75, 224, 77, 123, 70, 41, 127, 212, 172, 117, 126, 135, 148, 178, 98, 215, 65, 8, 221, 213, 255, 116, 51, 88]) }, { traceIndex := 1, values := [1, 4, 0, 8, 0, 0, 0, 0, 0, 4, 0, 4, 0, 4, 0, 8, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [197, 229, 102, 63, 211, 173, 141, 180, 21, 69, 157, 154, 253, 158, 41, 85, 158, 245, 93, 199, 202, 127, 166, 34, 128, 216, 228, 166, 176, 78, 208, 160]), digest := (bytes [22, 54, 34, 88, 55, 151, 16, 99, 222, 235, 109, 58, 119, 120, 232, 159, 14, 255, 59, 127, 85, 139, 122, 14, 38, 215, 15, 222, 145, 57, 115, 201]) }, { traceIndex := 2, values := [1, 8, 0, 12, 0, 9, 0, 4, 0, 5, 0, 0, 0, 5, 0, 12, 0, 0, 0, 0, 0, 0, 0, 3, 1, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1], rowDigest := (bytes [87, 47, 170, 122, 76, 25, 83, 14, 55, 223, 187, 37, 99, 189, 134, 254, 180, 159, 76, 215, 19, 45, 47, 201, 166, 96, 215, 138, 208, 80, 97, 90]), digest := (bytes [111, 128, 49, 102, 52, 65, 25, 227, 107, 76, 66, 180, 31, 149, 207, 46, 18, 63, 88, 116, 175, 163, 28, 40, 62, 77, 141, 179, 200, 57, 38, 200]) }, { traceIndex := 3, values := [1, 12, 0, 16, 0, 0, 0, 0, 0, 305418240, 0, 305418240, 0, 305418240, 0, 16, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [241, 95, 213, 152, 95, 119, 241, 166, 218, 88, 116, 103, 253, 199, 8, 5, 17, 244, 75, 111, 165, 49, 148, 166, 202, 22, 206, 167, 183, 244, 98, 100]), digest := (bytes [83, 215, 80, 82, 75, 27, 33, 3, 36, 44, 48, 206, 42, 46, 104, 148, 109, 29, 22, 178, 92, 240, 61, 232, 95, 207, 187, 129, 29, 115, 19, 132]) }, { traceIndex := 4, values := [1, 16, 0, 20, 0, 0, 0, 0, 0, 8208, 0, 8192, 0, 8208, 0, 20, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [108, 228, 27, 44, 48, 131, 83, 155, 115, 108, 14, 26, 97, 29, 105, 165, 202, 18, 136, 22, 36, 243, 247, 252, 22, 129, 190, 12, 63, 176, 155, 237]), digest := (bytes [22, 6, 72, 83, 138, 136, 122, 72, 189, 231, 17, 240, 127, 147, 153, 92, 99, 70, 60, 58, 156, 204, 80, 24, 70, 102, 120, 29, 49, 159, 184, 18]) }, { traceIndex := 5, values := [1, 20, 0, 24, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 24, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [183, 204, 193, 164, 189, 140, 99, 142, 217, 205, 21, 25, 50, 82, 4, 191, 168, 13, 185, 113, 29, 29, 70, 18, 169, 0, 151, 227, 102, 247, 141, 202]), digest := (bytes [255, 142, 65, 113, 11, 142, 121, 184, 80, 128, 58, 192, 213, 116, 182, 159, 129, 218, 111, 127, 211, 22, 40, 184, 71, 171, 162, 170, 230, 89, 173, 198]) }, { traceIndex := 6, values := [1, 24, 0, 28, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 28, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [57, 167, 127, 66, 29, 28, 1, 62, 111, 174, 45, 82, 212, 157, 25, 154, 254, 72, 204, 85, 223, 7, 138, 44, 48, 11, 222, 83, 122, 239, 183, 120]), digest := (bytes [53, 245, 127, 106, 55, 210, 83, 63, 162, 14, 12, 212, 9, 132, 72, 57, 29, 12, 230, 88, 252, 251, 47, 87, 51, 251, 133, 205, 8, 86, 144, 88]) }]

def rootExecutionPreparedBindings : List PreparedStepBindingView :=
  [{ traceIndex := 0, rowDigest := (bytes [49, 112, 41, 120, 103, 26, 24, 17, 240, 51, 88, 180, 158, 199, 42, 251, 183, 57, 20, 149, 1, 43, 127, 249, 47, 108, 100, 231, 221, 153, 232, 90]), rowOpeningDigest := (bytes [17, 207, 121, 237, 159, 155, 36, 164, 116, 95, 128, 75, 120, 77, 118, 119, 80, 17, 73, 60, 22, 80, 44, 110, 232, 41, 145, 233, 164, 251, 92, 238]), digest := (bytes [112, 4, 14, 184, 248, 3, 154, 25, 197, 83, 128, 57, 75, 189, 86, 252, 6, 171, 47, 64, 185, 152, 79, 238, 197, 182, 140, 41, 4, 66, 2, 187]) }, { traceIndex := 1, rowDigest := (bytes [197, 229, 102, 63, 211, 173, 141, 180, 21, 69, 157, 154, 253, 158, 41, 85, 158, 245, 93, 199, 202, 127, 166, 34, 128, 216, 228, 166, 176, 78, 208, 160]), rowOpeningDigest := (bytes [229, 75, 157, 233, 166, 115, 255, 135, 216, 60, 109, 157, 167, 160, 242, 11, 108, 193, 120, 240, 238, 113, 162, 154, 121, 84, 157, 142, 246, 208, 151, 116]), digest := (bytes [110, 86, 30, 24, 31, 202, 7, 218, 60, 209, 248, 187, 24, 207, 211, 134, 23, 175, 231, 124, 20, 151, 248, 229, 193, 56, 73, 168, 242, 223, 176, 26]) }, { traceIndex := 2, rowDigest := (bytes [87, 47, 170, 122, 76, 25, 83, 14, 55, 223, 187, 37, 99, 189, 134, 254, 180, 159, 76, 215, 19, 45, 47, 201, 166, 96, 215, 138, 208, 80, 97, 90]), rowOpeningDigest := (bytes [53, 34, 63, 49, 95, 9, 74, 96, 31, 99, 225, 171, 249, 4, 32, 118, 255, 96, 165, 121, 63, 203, 117, 156, 193, 177, 85, 104, 149, 126, 13, 110]), digest := (bytes [205, 181, 113, 228, 21, 47, 143, 50, 0, 249, 255, 207, 205, 15, 244, 30, 196, 145, 24, 111, 121, 194, 166, 167, 165, 221, 195, 96, 43, 104, 98, 173]) }, { traceIndex := 3, rowDigest := (bytes [241, 95, 213, 152, 95, 119, 241, 166, 218, 88, 116, 103, 253, 199, 8, 5, 17, 244, 75, 111, 165, 49, 148, 166, 202, 22, 206, 167, 183, 244, 98, 100]), rowOpeningDigest := (bytes [244, 147, 189, 225, 8, 124, 228, 54, 91, 9, 52, 250, 162, 150, 56, 114, 114, 188, 251, 174, 119, 164, 131, 146, 74, 182, 241, 80, 174, 157, 68, 98]), digest := (bytes [221, 58, 243, 244, 133, 83, 73, 19, 4, 142, 107, 66, 34, 0, 181, 138, 155, 121, 123, 39, 128, 9, 117, 84, 222, 53, 51, 202, 179, 14, 47, 250]) }, { traceIndex := 4, rowDigest := (bytes [108, 228, 27, 44, 48, 131, 83, 155, 115, 108, 14, 26, 97, 29, 105, 165, 202, 18, 136, 22, 36, 243, 247, 252, 22, 129, 190, 12, 63, 176, 155, 237]), rowOpeningDigest := (bytes [88, 193, 250, 208, 204, 91, 169, 21, 9, 133, 230, 172, 219, 79, 167, 137, 50, 77, 110, 161, 43, 9, 56, 107, 238, 225, 106, 109, 95, 215, 96, 245]), digest := (bytes [100, 238, 113, 170, 136, 29, 223, 174, 222, 192, 208, 10, 134, 194, 55, 34, 60, 245, 105, 249, 233, 247, 93, 154, 17, 218, 73, 216, 49, 232, 254, 155]) }, { traceIndex := 5, rowDigest := (bytes [183, 204, 193, 164, 189, 140, 99, 142, 217, 205, 21, 25, 50, 82, 4, 191, 168, 13, 185, 113, 29, 29, 70, 18, 169, 0, 151, 227, 102, 247, 141, 202]), rowOpeningDigest := (bytes [9, 174, 143, 11, 27, 44, 235, 246, 215, 210, 160, 37, 36, 94, 37, 206, 198, 67, 181, 202, 139, 3, 60, 50, 139, 52, 123, 37, 71, 78, 130, 11]), digest := (bytes [250, 47, 237, 196, 205, 50, 105, 199, 41, 131, 13, 61, 175, 60, 7, 162, 224, 128, 111, 231, 185, 120, 228, 171, 43, 64, 45, 245, 89, 122, 113, 243]) }, { traceIndex := 6, rowDigest := (bytes [57, 167, 127, 66, 29, 28, 1, 62, 111, 174, 45, 82, 212, 157, 25, 154, 254, 72, 204, 85, 223, 7, 138, 44, 48, 11, 222, 83, 122, 239, 183, 120]), rowOpeningDigest := (bytes [66, 120, 177, 28, 12, 51, 17, 88, 29, 137, 234, 40, 93, 97, 58, 32, 240, 194, 5, 198, 91, 176, 154, 39, 164, 136, 135, 32, 86, 196, 137, 83]), digest := (bytes [146, 66, 139, 78, 136, 92, 49, 207, 5, 221, 238, 58, 188, 204, 86, 91, 8, 239, 113, 163, 31, 106, 255, 92, 187, 102, 111, 227, 95, 205, 42, 209]) }]

def rootExecutionRowChunkRoutes : List RowChunkRouteView :=
  [{ logicalIndex := 0, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 0, digest := (bytes [138, 198, 109, 126, 144, 82, 221, 43, 248, 202, 137, 103, 62, 226, 249, 152, 163, 187, 1, 254, 36, 33, 59, 16, 64, 166, 202, 8, 219, 57, 240, 59]) }, { logicalIndex := 1, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 1, digest := (bytes [44, 177, 82, 41, 218, 60, 100, 208, 26, 31, 151, 113, 109, 148, 57, 12, 223, 21, 76, 221, 70, 245, 191, 105, 57, 199, 8, 128, 181, 145, 89, 99]) }, { logicalIndex := 2, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 2, digest := (bytes [252, 248, 65, 24, 81, 241, 150, 170, 250, 116, 222, 30, 134, 191, 78, 195, 104, 119, 225, 210, 243, 186, 212, 107, 183, 31, 243, 201, 101, 148, 32, 72]) }, { logicalIndex := 3, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 3, digest := (bytes [244, 11, 162, 13, 59, 43, 232, 47, 228, 2, 70, 126, 95, 10, 57, 40, 46, 107, 197, 81, 97, 39, 185, 163, 93, 60, 5, 66, 7, 231, 199, 134]) }, { logicalIndex := 4, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 4, digest := (bytes [98, 247, 204, 83, 252, 219, 248, 73, 49, 206, 229, 79, 169, 242, 28, 56, 7, 100, 18, 197, 133, 200, 133, 20, 161, 230, 126, 175, 98, 0, 158, 25]) }, { logicalIndex := 5, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 5, digest := (bytes [108, 248, 244, 125, 120, 190, 11, 202, 47, 205, 44, 110, 48, 43, 171, 224, 142, 98, 82, 106, 183, 21, 141, 205, 208, 18, 234, 19, 43, 61, 139, 151]) }, { logicalIndex := 6, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 6, digest := (bytes [213, 163, 43, 1, 32, 112, 128, 155, 10, 34, 241, 205, 79, 46, 234, 45, 239, 83, 213, 254, 45, 65, 13, 152, 217, 78, 36, 105, 42, 193, 181, 13]) }]

def rootExecutionRowLocalCcsAcceptance : List RootRowLocalCcsAcceptanceView :=
  [{ traceIndex := 0, logicalIndex := 0, rowDigest := (bytes [49, 112, 41, 120, 103, 26, 24, 17, 240, 51, 88, 180, 158, 199, 42, 251, 183, 57, 20, 149, 1, 43, 127, 249, 47, 108, 100, 231, 221, 153, 232, 90]), rowOpeningDigest := (bytes [17, 207, 121, 237, 159, 155, 36, 164, 116, 95, 128, 75, 120, 77, 118, 119, 80, 17, 73, 60, 22, 80, 44, 110, 232, 41, 145, 233, 164, 251, 92, 238]), preparedStepBindingDigest := (bytes [112, 4, 14, 184, 248, 3, 154, 25, 197, 83, 128, 57, 75, 189, 86, 252, 6, 171, 47, 64, 185, 152, 79, 238, 197, 182, 140, 41, 4, 66, 2, 187]), rowChunkRouteDigest := (bytes [138, 198, 109, 126, 144, 82, 221, 43, 248, 202, 137, 103, 62, 226, 249, 152, 163, 187, 1, 254, 36, 33, 59, 16, 64, 166, 202, 8, 219, 57, 240, 59]), publicStepDigest := (bytes [29, 198, 75, 252, 121, 5, 180, 177, 207, 206, 143, 76, 185, 127, 79, 162, 242, 35, 105, 14, 57, 198, 183, 162, 202, 227, 174, 195, 74, 249, 122, 135]), digest := (bytes [79, 78, 99, 12, 119, 87, 47, 1, 65, 108, 8, 107, 72, 84, 168, 19, 222, 191, 243, 222, 87, 114, 85, 48, 71, 31, 93, 32, 101, 212, 241, 133]) }, { traceIndex := 1, logicalIndex := 1, rowDigest := (bytes [197, 229, 102, 63, 211, 173, 141, 180, 21, 69, 157, 154, 253, 158, 41, 85, 158, 245, 93, 199, 202, 127, 166, 34, 128, 216, 228, 166, 176, 78, 208, 160]), rowOpeningDigest := (bytes [229, 75, 157, 233, 166, 115, 255, 135, 216, 60, 109, 157, 167, 160, 242, 11, 108, 193, 120, 240, 238, 113, 162, 154, 121, 84, 157, 142, 246, 208, 151, 116]), preparedStepBindingDigest := (bytes [110, 86, 30, 24, 31, 202, 7, 218, 60, 209, 248, 187, 24, 207, 211, 134, 23, 175, 231, 124, 20, 151, 248, 229, 193, 56, 73, 168, 242, 223, 176, 26]), rowChunkRouteDigest := (bytes [44, 177, 82, 41, 218, 60, 100, 208, 26, 31, 151, 113, 109, 148, 57, 12, 223, 21, 76, 221, 70, 245, 191, 105, 57, 199, 8, 128, 181, 145, 89, 99]), publicStepDigest := (bytes [238, 44, 248, 205, 55, 214, 41, 234, 182, 60, 82, 234, 110, 195, 136, 21, 82, 19, 120, 52, 192, 181, 99, 10, 160, 69, 184, 167, 190, 201, 55, 142]), digest := (bytes [207, 70, 198, 253, 115, 178, 248, 5, 76, 211, 242, 146, 1, 100, 206, 47, 52, 239, 94, 140, 208, 75, 97, 91, 60, 52, 94, 127, 31, 127, 1, 113]) }, { traceIndex := 2, logicalIndex := 2, rowDigest := (bytes [87, 47, 170, 122, 76, 25, 83, 14, 55, 223, 187, 37, 99, 189, 134, 254, 180, 159, 76, 215, 19, 45, 47, 201, 166, 96, 215, 138, 208, 80, 97, 90]), rowOpeningDigest := (bytes [53, 34, 63, 49, 95, 9, 74, 96, 31, 99, 225, 171, 249, 4, 32, 118, 255, 96, 165, 121, 63, 203, 117, 156, 193, 177, 85, 104, 149, 126, 13, 110]), preparedStepBindingDigest := (bytes [205, 181, 113, 228, 21, 47, 143, 50, 0, 249, 255, 207, 205, 15, 244, 30, 196, 145, 24, 111, 121, 194, 166, 167, 165, 221, 195, 96, 43, 104, 98, 173]), rowChunkRouteDigest := (bytes [252, 248, 65, 24, 81, 241, 150, 170, 250, 116, 222, 30, 134, 191, 78, 195, 104, 119, 225, 210, 243, 186, 212, 107, 183, 31, 243, 201, 101, 148, 32, 72]), publicStepDigest := (bytes [162, 30, 23, 135, 92, 58, 165, 179, 240, 93, 6, 241, 152, 9, 158, 64, 144, 157, 161, 85, 4, 75, 182, 88, 177, 52, 147, 177, 94, 186, 108, 217]), digest := (bytes [239, 173, 198, 22, 86, 93, 9, 83, 224, 49, 146, 37, 195, 16, 61, 209, 249, 218, 238, 180, 41, 84, 19, 151, 114, 21, 177, 203, 152, 30, 220, 124]) }, { traceIndex := 3, logicalIndex := 3, rowDigest := (bytes [241, 95, 213, 152, 95, 119, 241, 166, 218, 88, 116, 103, 253, 199, 8, 5, 17, 244, 75, 111, 165, 49, 148, 166, 202, 22, 206, 167, 183, 244, 98, 100]), rowOpeningDigest := (bytes [244, 147, 189, 225, 8, 124, 228, 54, 91, 9, 52, 250, 162, 150, 56, 114, 114, 188, 251, 174, 119, 164, 131, 146, 74, 182, 241, 80, 174, 157, 68, 98]), preparedStepBindingDigest := (bytes [221, 58, 243, 244, 133, 83, 73, 19, 4, 142, 107, 66, 34, 0, 181, 138, 155, 121, 123, 39, 128, 9, 117, 84, 222, 53, 51, 202, 179, 14, 47, 250]), rowChunkRouteDigest := (bytes [244, 11, 162, 13, 59, 43, 232, 47, 228, 2, 70, 126, 95, 10, 57, 40, 46, 107, 197, 81, 97, 39, 185, 163, 93, 60, 5, 66, 7, 231, 199, 134]), publicStepDigest := (bytes [215, 221, 94, 3, 9, 34, 58, 77, 193, 226, 110, 72, 41, 60, 172, 246, 221, 248, 69, 191, 19, 219, 105, 112, 166, 137, 142, 28, 118, 53, 101, 216]), digest := (bytes [243, 108, 186, 111, 17, 186, 25, 41, 174, 21, 25, 66, 195, 239, 229, 151, 43, 173, 202, 189, 124, 207, 104, 138, 87, 102, 218, 205, 0, 93, 162, 191]) }, { traceIndex := 4, logicalIndex := 4, rowDigest := (bytes [108, 228, 27, 44, 48, 131, 83, 155, 115, 108, 14, 26, 97, 29, 105, 165, 202, 18, 136, 22, 36, 243, 247, 252, 22, 129, 190, 12, 63, 176, 155, 237]), rowOpeningDigest := (bytes [88, 193, 250, 208, 204, 91, 169, 21, 9, 133, 230, 172, 219, 79, 167, 137, 50, 77, 110, 161, 43, 9, 56, 107, 238, 225, 106, 109, 95, 215, 96, 245]), preparedStepBindingDigest := (bytes [100, 238, 113, 170, 136, 29, 223, 174, 222, 192, 208, 10, 134, 194, 55, 34, 60, 245, 105, 249, 233, 247, 93, 154, 17, 218, 73, 216, 49, 232, 254, 155]), rowChunkRouteDigest := (bytes [98, 247, 204, 83, 252, 219, 248, 73, 49, 206, 229, 79, 169, 242, 28, 56, 7, 100, 18, 197, 133, 200, 133, 20, 161, 230, 126, 175, 98, 0, 158, 25]), publicStepDigest := (bytes [135, 44, 226, 174, 109, 134, 49, 107, 117, 181, 60, 41, 79, 233, 250, 65, 179, 46, 130, 42, 127, 185, 111, 90, 78, 68, 222, 238, 12, 162, 31, 106]), digest := (bytes [2, 3, 205, 108, 252, 132, 81, 247, 88, 83, 216, 27, 209, 22, 155, 122, 70, 174, 232, 228, 118, 67, 24, 151, 236, 103, 24, 129, 225, 190, 179, 64]) }, { traceIndex := 5, logicalIndex := 5, rowDigest := (bytes [183, 204, 193, 164, 189, 140, 99, 142, 217, 205, 21, 25, 50, 82, 4, 191, 168, 13, 185, 113, 29, 29, 70, 18, 169, 0, 151, 227, 102, 247, 141, 202]), rowOpeningDigest := (bytes [9, 174, 143, 11, 27, 44, 235, 246, 215, 210, 160, 37, 36, 94, 37, 206, 198, 67, 181, 202, 139, 3, 60, 50, 139, 52, 123, 37, 71, 78, 130, 11]), preparedStepBindingDigest := (bytes [250, 47, 237, 196, 205, 50, 105, 199, 41, 131, 13, 61, 175, 60, 7, 162, 224, 128, 111, 231, 185, 120, 228, 171, 43, 64, 45, 245, 89, 122, 113, 243]), rowChunkRouteDigest := (bytes [108, 248, 244, 125, 120, 190, 11, 202, 47, 205, 44, 110, 48, 43, 171, 224, 142, 98, 82, 106, 183, 21, 141, 205, 208, 18, 234, 19, 43, 61, 139, 151]), publicStepDigest := (bytes [28, 109, 66, 164, 34, 42, 118, 88, 162, 145, 76, 122, 169, 93, 235, 155, 221, 95, 70, 5, 89, 254, 212, 200, 38, 186, 90, 18, 222, 69, 191, 189]), digest := (bytes [70, 94, 191, 55, 83, 105, 99, 72, 206, 204, 77, 127, 5, 173, 247, 20, 236, 179, 168, 253, 45, 246, 164, 172, 244, 60, 241, 222, 213, 16, 146, 69]) }, { traceIndex := 6, logicalIndex := 6, rowDigest := (bytes [57, 167, 127, 66, 29, 28, 1, 62, 111, 174, 45, 82, 212, 157, 25, 154, 254, 72, 204, 85, 223, 7, 138, 44, 48, 11, 222, 83, 122, 239, 183, 120]), rowOpeningDigest := (bytes [66, 120, 177, 28, 12, 51, 17, 88, 29, 137, 234, 40, 93, 97, 58, 32, 240, 194, 5, 198, 91, 176, 154, 39, 164, 136, 135, 32, 86, 196, 137, 83]), preparedStepBindingDigest := (bytes [146, 66, 139, 78, 136, 92, 49, 207, 5, 221, 238, 58, 188, 204, 86, 91, 8, 239, 113, 163, 31, 106, 255, 92, 187, 102, 111, 227, 95, 205, 42, 209]), rowChunkRouteDigest := (bytes [213, 163, 43, 1, 32, 112, 128, 155, 10, 34, 241, 205, 79, 46, 234, 45, 239, 83, 213, 254, 45, 65, 13, 152, 217, 78, 36, 105, 42, 193, 181, 13]), publicStepDigest := (bytes [188, 255, 114, 147, 11, 230, 48, 155, 108, 50, 225, 167, 192, 101, 38, 131, 177, 181, 218, 166, 156, 3, 42, 148, 169, 202, 204, 45, 34, 34, 223, 74]), digest := (bytes [63, 193, 228, 135, 166, 186, 196, 143, 213, 152, 51, 24, 40, 168, 221, 228, 160, 158, 65, 182, 39, 69, 40, 250, 155, 60, 177, 175, 24, 197, 233, 135]) }]

def rootExecutionExecutionSemanticsRefinement : List RootExecutionSemanticsRefinementView :=
  [{ traceIndex := 0, logicalIndex := 0, semanticRowDigest := (bytes [164, 59, 59, 232, 207, 90, 160, 229, 75, 224, 77, 123, 70, 41, 127, 212, 172, 117, 126, 135, 148, 178, 98, 215, 65, 8, 221, 213, 255, 116, 51, 88]), rowLocalCcsAcceptanceDigest := (bytes [79, 78, 99, 12, 119, 87, 47, 1, 65, 108, 8, 107, 72, 84, 168, 19, 222, 191, 243, 222, 87, 114, 85, 48, 71, 31, 93, 32, 101, 212, 241, 133]), preparedStepBindingDigest := (bytes [112, 4, 14, 184, 248, 3, 154, 25, 197, 83, 128, 57, 75, 189, 86, 252, 6, 171, 47, 64, 185, 152, 79, 238, 197, 182, 140, 41, 4, 66, 2, 187]), publicStepDigest := (bytes [29, 198, 75, 252, 121, 5, 180, 177, 207, 206, 143, 76, 185, 127, 79, 162, 242, 35, 105, 14, 57, 198, 183, 162, 202, 227, 174, 195, 74, 249, 122, 135]), digest := (bytes [196, 88, 71, 93, 57, 162, 98, 50, 189, 126, 15, 65, 211, 170, 225, 25, 6, 106, 157, 245, 92, 162, 31, 40, 176, 205, 184, 117, 188, 210, 108, 183]) }, { traceIndex := 1, logicalIndex := 1, semanticRowDigest := (bytes [22, 54, 34, 88, 55, 151, 16, 99, 222, 235, 109, 58, 119, 120, 232, 159, 14, 255, 59, 127, 85, 139, 122, 14, 38, 215, 15, 222, 145, 57, 115, 201]), rowLocalCcsAcceptanceDigest := (bytes [207, 70, 198, 253, 115, 178, 248, 5, 76, 211, 242, 146, 1, 100, 206, 47, 52, 239, 94, 140, 208, 75, 97, 91, 60, 52, 94, 127, 31, 127, 1, 113]), preparedStepBindingDigest := (bytes [110, 86, 30, 24, 31, 202, 7, 218, 60, 209, 248, 187, 24, 207, 211, 134, 23, 175, 231, 124, 20, 151, 248, 229, 193, 56, 73, 168, 242, 223, 176, 26]), publicStepDigest := (bytes [238, 44, 248, 205, 55, 214, 41, 234, 182, 60, 82, 234, 110, 195, 136, 21, 82, 19, 120, 52, 192, 181, 99, 10, 160, 69, 184, 167, 190, 201, 55, 142]), digest := (bytes [140, 177, 11, 99, 9, 231, 27, 204, 134, 27, 243, 138, 7, 201, 252, 162, 102, 59, 82, 93, 8, 170, 110, 11, 88, 188, 126, 129, 24, 140, 170, 99]) }, { traceIndex := 2, logicalIndex := 2, semanticRowDigest := (bytes [111, 128, 49, 102, 52, 65, 25, 227, 107, 76, 66, 180, 31, 149, 207, 46, 18, 63, 88, 116, 175, 163, 28, 40, 62, 77, 141, 179, 200, 57, 38, 200]), rowLocalCcsAcceptanceDigest := (bytes [239, 173, 198, 22, 86, 93, 9, 83, 224, 49, 146, 37, 195, 16, 61, 209, 249, 218, 238, 180, 41, 84, 19, 151, 114, 21, 177, 203, 152, 30, 220, 124]), preparedStepBindingDigest := (bytes [205, 181, 113, 228, 21, 47, 143, 50, 0, 249, 255, 207, 205, 15, 244, 30, 196, 145, 24, 111, 121, 194, 166, 167, 165, 221, 195, 96, 43, 104, 98, 173]), publicStepDigest := (bytes [162, 30, 23, 135, 92, 58, 165, 179, 240, 93, 6, 241, 152, 9, 158, 64, 144, 157, 161, 85, 4, 75, 182, 88, 177, 52, 147, 177, 94, 186, 108, 217]), digest := (bytes [90, 89, 63, 6, 231, 37, 66, 243, 221, 19, 209, 195, 39, 151, 243, 191, 174, 6, 201, 188, 223, 25, 108, 106, 29, 147, 13, 2, 146, 91, 215, 91]) }, { traceIndex := 3, logicalIndex := 3, semanticRowDigest := (bytes [83, 215, 80, 82, 75, 27, 33, 3, 36, 44, 48, 206, 42, 46, 104, 148, 109, 29, 22, 178, 92, 240, 61, 232, 95, 207, 187, 129, 29, 115, 19, 132]), rowLocalCcsAcceptanceDigest := (bytes [243, 108, 186, 111, 17, 186, 25, 41, 174, 21, 25, 66, 195, 239, 229, 151, 43, 173, 202, 189, 124, 207, 104, 138, 87, 102, 218, 205, 0, 93, 162, 191]), preparedStepBindingDigest := (bytes [221, 58, 243, 244, 133, 83, 73, 19, 4, 142, 107, 66, 34, 0, 181, 138, 155, 121, 123, 39, 128, 9, 117, 84, 222, 53, 51, 202, 179, 14, 47, 250]), publicStepDigest := (bytes [215, 221, 94, 3, 9, 34, 58, 77, 193, 226, 110, 72, 41, 60, 172, 246, 221, 248, 69, 191, 19, 219, 105, 112, 166, 137, 142, 28, 118, 53, 101, 216]), digest := (bytes [196, 156, 169, 13, 122, 20, 40, 71, 247, 102, 159, 106, 142, 167, 130, 253, 15, 228, 62, 248, 232, 176, 236, 180, 68, 248, 205, 144, 9, 233, 48, 233]) }, { traceIndex := 4, logicalIndex := 4, semanticRowDigest := (bytes [22, 6, 72, 83, 138, 136, 122, 72, 189, 231, 17, 240, 127, 147, 153, 92, 99, 70, 60, 58, 156, 204, 80, 24, 70, 102, 120, 29, 49, 159, 184, 18]), rowLocalCcsAcceptanceDigest := (bytes [2, 3, 205, 108, 252, 132, 81, 247, 88, 83, 216, 27, 209, 22, 155, 122, 70, 174, 232, 228, 118, 67, 24, 151, 236, 103, 24, 129, 225, 190, 179, 64]), preparedStepBindingDigest := (bytes [100, 238, 113, 170, 136, 29, 223, 174, 222, 192, 208, 10, 134, 194, 55, 34, 60, 245, 105, 249, 233, 247, 93, 154, 17, 218, 73, 216, 49, 232, 254, 155]), publicStepDigest := (bytes [135, 44, 226, 174, 109, 134, 49, 107, 117, 181, 60, 41, 79, 233, 250, 65, 179, 46, 130, 42, 127, 185, 111, 90, 78, 68, 222, 238, 12, 162, 31, 106]), digest := (bytes [30, 2, 98, 35, 56, 132, 55, 87, 233, 165, 21, 225, 44, 157, 112, 18, 176, 50, 247, 154, 156, 42, 155, 109, 19, 118, 149, 149, 248, 154, 144, 9]) }, { traceIndex := 5, logicalIndex := 5, semanticRowDigest := (bytes [255, 142, 65, 113, 11, 142, 121, 184, 80, 128, 58, 192, 213, 116, 182, 159, 129, 218, 111, 127, 211, 22, 40, 184, 71, 171, 162, 170, 230, 89, 173, 198]), rowLocalCcsAcceptanceDigest := (bytes [70, 94, 191, 55, 83, 105, 99, 72, 206, 204, 77, 127, 5, 173, 247, 20, 236, 179, 168, 253, 45, 246, 164, 172, 244, 60, 241, 222, 213, 16, 146, 69]), preparedStepBindingDigest := (bytes [250, 47, 237, 196, 205, 50, 105, 199, 41, 131, 13, 61, 175, 60, 7, 162, 224, 128, 111, 231, 185, 120, 228, 171, 43, 64, 45, 245, 89, 122, 113, 243]), publicStepDigest := (bytes [28, 109, 66, 164, 34, 42, 118, 88, 162, 145, 76, 122, 169, 93, 235, 155, 221, 95, 70, 5, 89, 254, 212, 200, 38, 186, 90, 18, 222, 69, 191, 189]), digest := (bytes [189, 84, 194, 196, 199, 6, 31, 89, 89, 160, 21, 33, 103, 157, 55, 121, 2, 2, 108, 191, 16, 48, 175, 221, 245, 110, 81, 111, 95, 121, 104, 191]) }, { traceIndex := 6, logicalIndex := 6, semanticRowDigest := (bytes [53, 245, 127, 106, 55, 210, 83, 63, 162, 14, 12, 212, 9, 132, 72, 57, 29, 12, 230, 88, 252, 251, 47, 87, 51, 251, 133, 205, 8, 86, 144, 88]), rowLocalCcsAcceptanceDigest := (bytes [63, 193, 228, 135, 166, 186, 196, 143, 213, 152, 51, 24, 40, 168, 221, 228, 160, 158, 65, 182, 39, 69, 40, 250, 155, 60, 177, 175, 24, 197, 233, 135]), preparedStepBindingDigest := (bytes [146, 66, 139, 78, 136, 92, 49, 207, 5, 221, 238, 58, 188, 204, 86, 91, 8, 239, 113, 163, 31, 106, 255, 92, 187, 102, 111, 227, 95, 205, 42, 209]), publicStepDigest := (bytes [188, 255, 114, 147, 11, 230, 48, 155, 108, 50, 225, 167, 192, 101, 38, 131, 177, 181, 218, 166, 156, 3, 42, 148, 169, 202, 204, 45, 34, 34, 223, 74]), digest := (bytes [142, 173, 158, 233, 98, 102, 105, 215, 178, 59, 7, 32, 90, 169, 233, 29, 108, 14, 238, 97, 148, 59, 211, 144, 106, 77, 184, 122, 248, 13, 26, 159]) }]

def rootExecution : RootExecutionBundleView :=
  {
    executionRows := rootExecutionExecutionRows
    , semanticRows := rootExecutionSemanticRows
    , semanticRowsDigest := (bytes [111, 130, 143, 170, 185, 255, 79, 237, 60, 170, 31, 135, 174, 129, 165, 226, 87, 243, 1, 41, 177, 16, 52, 36, 158, 105, 170, 9, 154, 242, 229, 168])
    , preparedStepBindings := { bindings := rootExecutionPreparedBindings, bindingCount := 7, firstBindingDigest := (some (bytes [112, 4, 14, 184, 248, 3, 154, 25, 197, 83, 128, 57, 75, 189, 86, 252, 6, 171, 47, 64, 185, 152, 79, 238, 197, 182, 140, 41, 4, 66, 2, 187])), lastBindingDigest := (some (bytes [146, 66, 139, 78, 136, 92, 49, 207, 5, 221, 238, 58, 188, 204, 86, 91, 8, 239, 113, 163, 31, 106, 255, 92, 187, 102, 111, 227, 95, 205, 42, 209])), digest := (bytes [112, 197, 82, 217, 71, 142, 123, 243, 160, 171, 19, 245, 183, 154, 255, 69, 152, 22, 80, 238, 217, 143, 85, 100, 93, 29, 74, 46, 45, 249, 112, 40]) }
    , rowChunkRoutes := rootExecutionRowChunkRoutes
    , rowChunkRoutesDigest := (bytes [210, 211, 133, 148, 162, 150, 85, 66, 2, 24, 230, 163, 67, 64, 160, 246, 143, 119, 48, 189, 194, 114, 28, 76, 211, 182, 93, 15, 73, 83, 209, 85])
    , rowLocalCcsAcceptance := { acceptances := rootExecutionRowLocalCcsAcceptance, acceptanceCount := 7, firstAcceptanceDigest := (some (bytes [79, 78, 99, 12, 119, 87, 47, 1, 65, 108, 8, 107, 72, 84, 168, 19, 222, 191, 243, 222, 87, 114, 85, 48, 71, 31, 93, 32, 101, 212, 241, 133])), lastAcceptanceDigest := (some (bytes [63, 193, 228, 135, 166, 186, 196, 143, 213, 152, 51, 24, 40, 168, 221, 228, 160, 158, 65, 182, 39, 69, 40, 250, 155, 60, 177, 175, 24, 197, 233, 135])), digest := (bytes [113, 175, 20, 136, 94, 93, 150, 68, 255, 94, 107, 61, 0, 137, 149, 63, 177, 153, 34, 87, 211, 156, 96, 21, 236, 169, 22, 214, 57, 65, 251, 8]) }
    , executionSemanticsRefinement := { refinements := rootExecutionExecutionSemanticsRefinement, refinementCount := 7, firstRefinementDigest := (some (bytes [196, 88, 71, 93, 57, 162, 98, 50, 189, 126, 15, 65, 211, 170, 225, 25, 6, 106, 157, 245, 92, 162, 31, 40, 176, 205, 184, 117, 188, 210, 108, 183])), lastRefinementDigest := (some (bytes [142, 173, 158, 233, 98, 102, 105, 215, 178, 59, 7, 32, 90, 169, 233, 29, 108, 14, 238, 97, 148, 59, 211, 144, 106, 77, 184, 122, 248, 13, 26, 159])), digest := (bytes [176, 243, 163, 102, 11, 94, 248, 33, 159, 180, 131, 143, 153, 52, 15, 140, 19, 91, 217, 82, 136, 224, 5, 191, 87, 162, 41, 67, 207, 114, 255, 182]) }
    , familyDigest := (bytes [6, 23, 36, 33, 23, 226, 157, 251, 165, 190, 255, 219, 249, 58, 34, 233, 160, 194, 223, 125, 31, 225, 196, 138, 224, 6, 179, 93, 109, 39, 25, 113])
    , digest := (bytes [238, 90, 135, 208, 2, 60, 241, 126, 243, 127, 46, 182, 126, 127, 53, 232, 123, 166, 233, 144, 50, 181, 200, 47, 120, 15, 195, 156, 235, 173, 107, 5])
  }

def kernelOpeningBundle : SimpleKernelOpeningBundleView :=
  {
    claim := { bindings := { stageClaimBundleDigest := (bytes [223, 225, 90, 207, 134, 93, 119, 56, 41, 5, 124, 209, 164, 29, 171, 3, 36, 243, 143, 44, 178, 63, 24, 247, 108, 3, 98, 54, 90, 32, 232, 16]), stagePackageBundleDigest := (bytes [150, 142, 19, 32, 35, 228, 183, 42, 168, 254, 224, 21, 201, 251, 104, 107, 156, 210, 162, 210, 187, 213, 91, 41, 34, 90, 7, 179, 143, 206, 21, 186]), stage1PackageDigest := (bytes [207, 40, 159, 62, 60, 5, 240, 79, 61, 235, 232, 64, 80, 50, 15, 50, 1, 147, 76, 6, 172, 104, 25, 175, 15, 199, 167, 51, 8, 68, 177, 92]), stage2PackageDigest := (bytes [91, 238, 67, 192, 173, 230, 176, 69, 21, 217, 100, 79, 117, 10, 31, 183, 249, 182, 54, 243, 26, 41, 183, 69, 215, 140, 117, 247, 219, 146, 110, 164]), stage3PackageDigest := (bytes [92, 247, 26, 104, 3, 68, 55, 71, 237, 45, 12, 153, 238, 197, 30, 23, 0, 5, 192, 200, 156, 49, 112, 225, 23, 23, 16, 191, 254, 164, 5, 217]), preparedStepBindingsDigest := (bytes [112, 197, 82, 217, 71, 142, 123, 243, 160, 171, 19, 245, 183, 154, 255, 69, 152, 22, 80, 238, 217, 143, 85, 100, 93, 29, 74, 46, 45, 249, 112, 40]), bindingCount := 7, stage1RowCount := 7, stage2RegisterReadCount := 4, stage2RegisterWriteCount := 5, stage2RamEventCount := 0, stage3ContinuityCount := 7, points := { firstBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [112, 197, 82, 217, 71, 142, 123, 243, 160, 171, 19, 245, 183, 154, 255, 69, 152, 22, 80, 238, 217, 143, 85, 100, 93, 29, 74, 46, 45, 249, 112, 40]), layoutVersion := 1, digest := (bytes [218, 225, 226, 1, 126, 7, 97, 154, 254, 238, 100, 26, 147, 169, 122, 215, 11, 179, 134, 178, 200, 228, 157, 16, 135, 18, 11, 61, 82, 138, 101, 138]) }, logicalIndex := 0, digest := (bytes [189, 107, 146, 32, 92, 143, 35, 172, 31, 227, 15, 136, 239, 132, 155, 130, 254, 159, 252, 9, 138, 252, 9, 13, 184, 200, 58, 227, 163, 152, 44, 164]) }, valueDigest := (bytes [112, 4, 14, 184, 248, 3, 154, 25, 197, 83, 128, 57, 75, 189, 86, 252, 6, 171, 47, 64, 185, 152, 79, 238, 197, 182, 140, 41, 4, 66, 2, 187]), digest := (bytes [140, 140, 232, 37, 93, 129, 228, 91, 22, 60, 82, 187, 171, 170, 140, 145, 60, 38, 70, 115, 45, 67, 180, 205, 143, 127, 146, 164, 25, 190, 24, 127]) }), lastBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [112, 197, 82, 217, 71, 142, 123, 243, 160, 171, 19, 245, 183, 154, 255, 69, 152, 22, 80, 238, 217, 143, 85, 100, 93, 29, 74, 46, 45, 249, 112, 40]), layoutVersion := 1, digest := (bytes [218, 225, 226, 1, 126, 7, 97, 154, 254, 238, 100, 26, 147, 169, 122, 215, 11, 179, 134, 178, 200, 228, 157, 16, 135, 18, 11, 61, 82, 138, 101, 138]) }, logicalIndex := 6, digest := (bytes [109, 157, 249, 176, 58, 76, 248, 19, 201, 200, 6, 70, 147, 184, 246, 230, 231, 237, 144, 2, 165, 100, 92, 16, 198, 193, 144, 225, 91, 229, 248, 74]) }, valueDigest := (bytes [146, 66, 139, 78, 136, 92, 49, 207, 5, 221, 238, 58, 188, 204, 86, 91, 8, 239, 113, 163, 31, 106, 255, 92, 187, 102, 111, 227, 95, 205, 42, 209]), digest := (bytes [207, 74, 3, 237, 105, 120, 192, 90, 45, 69, 142, 10, 184, 36, 178, 180, 93, 214, 12, 9, 247, 23, 86, 29, 34, 173, 252, 158, 103, 205, 109, 127]) }) }, digest := (bytes [103, 23, 226, 56, 219, 16, 75, 213, 97, 208, 34, 138, 199, 155, 144, 26, 40, 65, 189, 89, 151, 200, 64, 83, 136, 108, 6, 11, 173, 240, 13, 141]) }, preparedSteps := { executionDigest := (bytes [28, 1, 84, 184, 89, 242, 14, 108, 33, 243, 25, 226, 156, 89, 231, 121, 72, 112, 15, 25, 78, 90, 217, 60, 9, 73, 78, 4, 175, 30, 106, 21]), finalStateDigest := (bytes [235, 168, 117, 145, 21, 252, 85, 198, 113, 178, 38, 202, 134, 138, 105, 213, 57, 49, 5, 39, 70, 58, 244, 201, 34, 144, 14, 16, 184, 169, 197, 30]), transcriptFinalDigest := (bytes [69, 237, 137, 65, 241, 167, 182, 221, 246, 185, 6, 120, 136, 169, 112, 162, 253, 226, 253, 66, 58, 124, 92, 237, 123, 110, 55, 97, 233, 36, 145, 157]), preparedStepCount := 7, finalPc := 28, halted := true, points := { firstPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [188, 12, 95, 85, 66, 33, 99, 49, 226, 20, 83, 140, 184, 203, 2, 197, 58, 72, 27, 185, 133, 183, 5, 214, 56, 240, 203, 134, 116, 9, 141, 194]), layoutVersion := 3, digest := (bytes [93, 165, 209, 153, 58, 191, 53, 125, 149, 135, 164, 81, 108, 190, 175, 75, 191, 102, 98, 247, 125, 159, 208, 119, 229, 244, 240, 202, 143, 114, 108, 202]) }, logicalIndex := 0, digest := (bytes [129, 215, 43, 59, 203, 39, 35, 65, 215, 34, 107, 74, 102, 41, 143, 193, 105, 59, 216, 89, 191, 88, 229, 192, 27, 145, 190, 119, 196, 193, 146, 86]) }, valueDigest := (bytes [49, 112, 41, 120, 103, 26, 24, 17, 240, 51, 88, 180, 158, 199, 42, 251, 183, 57, 20, 149, 1, 43, 127, 249, 47, 108, 100, 231, 221, 153, 232, 90]), digest := (bytes [34, 109, 239, 78, 212, 125, 84, 109, 35, 231, 9, 110, 158, 166, 139, 211, 73, 48, 227, 193, 83, 46, 47, 210, 163, 190, 147, 240, 188, 142, 74, 13]) }), lastPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [188, 12, 95, 85, 66, 33, 99, 49, 226, 20, 83, 140, 184, 203, 2, 197, 58, 72, 27, 185, 133, 183, 5, 214, 56, 240, 203, 134, 116, 9, 141, 194]), layoutVersion := 3, digest := (bytes [93, 165, 209, 153, 58, 191, 53, 125, 149, 135, 164, 81, 108, 190, 175, 75, 191, 102, 98, 247, 125, 159, 208, 119, 229, 244, 240, 202, 143, 114, 108, 202]) }, logicalIndex := 6, digest := (bytes [27, 222, 251, 202, 155, 65, 36, 46, 105, 119, 166, 124, 124, 92, 5, 11, 163, 81, 33, 98, 148, 207, 51, 68, 71, 88, 69, 250, 107, 132, 2, 115]) }, valueDigest := (bytes [57, 167, 127, 66, 29, 28, 1, 62, 111, 174, 45, 82, 212, 157, 25, 154, 254, 72, 204, 85, 223, 7, 138, 44, 48, 11, 222, 83, 122, 239, 183, 120]), digest := (bytes [239, 144, 64, 133, 16, 33, 187, 192, 199, 171, 231, 186, 85, 250, 190, 54, 136, 147, 57, 153, 203, 201, 166, 165, 80, 159, 29, 7, 34, 242, 144, 125]) }) }, digest := (bytes [42, 43, 187, 138, 183, 43, 10, 144, 163, 176, 102, 142, 139, 48, 17, 47, 216, 200, 70, 210, 136, 11, 37, 58, 178, 17, 30, 193, 195, 48, 146, 55]) }, digest := (bytes [99, 34, 151, 196, 202, 146, 254, 239, 47, 204, 153, 51, 30, 203, 74, 164, 234, 127, 173, 202, 32, 168, 7, 101, 17, 82, 80, 237, 198, 225, 67, 175]) }
    , bindings := { claim := { stageClaimBundleDigest := (bytes [223, 225, 90, 207, 134, 93, 119, 56, 41, 5, 124, 209, 164, 29, 171, 3, 36, 243, 143, 44, 178, 63, 24, 247, 108, 3, 98, 54, 90, 32, 232, 16]), stagePackageBundleDigest := (bytes [150, 142, 19, 32, 35, 228, 183, 42, 168, 254, 224, 21, 201, 251, 104, 107, 156, 210, 162, 210, 187, 213, 91, 41, 34, 90, 7, 179, 143, 206, 21, 186]), stage1PackageDigest := (bytes [207, 40, 159, 62, 60, 5, 240, 79, 61, 235, 232, 64, 80, 50, 15, 50, 1, 147, 76, 6, 172, 104, 25, 175, 15, 199, 167, 51, 8, 68, 177, 92]), stage2PackageDigest := (bytes [91, 238, 67, 192, 173, 230, 176, 69, 21, 217, 100, 79, 117, 10, 31, 183, 249, 182, 54, 243, 26, 41, 183, 69, 215, 140, 117, 247, 219, 146, 110, 164]), stage3PackageDigest := (bytes [92, 247, 26, 104, 3, 68, 55, 71, 237, 45, 12, 153, 238, 197, 30, 23, 0, 5, 192, 200, 156, 49, 112, 225, 23, 23, 16, 191, 254, 164, 5, 217]), preparedStepBindingsDigest := (bytes [112, 197, 82, 217, 71, 142, 123, 243, 160, 171, 19, 245, 183, 154, 255, 69, 152, 22, 80, 238, 217, 143, 85, 100, 93, 29, 74, 46, 45, 249, 112, 40]), bindingCount := 7, stage1RowCount := 7, stage2RegisterReadCount := 4, stage2RegisterWriteCount := 5, stage2RamEventCount := 0, stage3ContinuityCount := 7, points := { firstBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [112, 197, 82, 217, 71, 142, 123, 243, 160, 171, 19, 245, 183, 154, 255, 69, 152, 22, 80, 238, 217, 143, 85, 100, 93, 29, 74, 46, 45, 249, 112, 40]), layoutVersion := 1, digest := (bytes [218, 225, 226, 1, 126, 7, 97, 154, 254, 238, 100, 26, 147, 169, 122, 215, 11, 179, 134, 178, 200, 228, 157, 16, 135, 18, 11, 61, 82, 138, 101, 138]) }, logicalIndex := 0, digest := (bytes [189, 107, 146, 32, 92, 143, 35, 172, 31, 227, 15, 136, 239, 132, 155, 130, 254, 159, 252, 9, 138, 252, 9, 13, 184, 200, 58, 227, 163, 152, 44, 164]) }, valueDigest := (bytes [112, 4, 14, 184, 248, 3, 154, 25, 197, 83, 128, 57, 75, 189, 86, 252, 6, 171, 47, 64, 185, 152, 79, 238, 197, 182, 140, 41, 4, 66, 2, 187]), digest := (bytes [140, 140, 232, 37, 93, 129, 228, 91, 22, 60, 82, 187, 171, 170, 140, 145, 60, 38, 70, 115, 45, 67, 180, 205, 143, 127, 146, 164, 25, 190, 24, 127]) }), lastBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [112, 197, 82, 217, 71, 142, 123, 243, 160, 171, 19, 245, 183, 154, 255, 69, 152, 22, 80, 238, 217, 143, 85, 100, 93, 29, 74, 46, 45, 249, 112, 40]), layoutVersion := 1, digest := (bytes [218, 225, 226, 1, 126, 7, 97, 154, 254, 238, 100, 26, 147, 169, 122, 215, 11, 179, 134, 178, 200, 228, 157, 16, 135, 18, 11, 61, 82, 138, 101, 138]) }, logicalIndex := 6, digest := (bytes [109, 157, 249, 176, 58, 76, 248, 19, 201, 200, 6, 70, 147, 184, 246, 230, 231, 237, 144, 2, 165, 100, 92, 16, 198, 193, 144, 225, 91, 229, 248, 74]) }, valueDigest := (bytes [146, 66, 139, 78, 136, 92, 49, 207, 5, 221, 238, 58, 188, 204, 86, 91, 8, 239, 113, 163, 31, 106, 255, 92, 187, 102, 111, 227, 95, 205, 42, 209]), digest := (bytes [207, 74, 3, 237, 105, 120, 192, 90, 45, 69, 142, 10, 184, 36, 178, 180, 93, 214, 12, 9, 247, 23, 86, 29, 34, 173, 252, 158, 103, 205, 109, 127]) }) }, digest := (bytes [103, 23, 226, 56, 219, 16, 75, 213, 97, 208, 34, 138, 199, 155, 144, 26, 40, 65, 189, 89, 151, 200, 64, 83, 136, 108, 6, 11, 173, 240, 13, 141]) }, packaged := { statementDigest := (bytes [79, 166, 198, 61, 75, 212, 90, 85, 232, 77, 246, 26, 81, 146, 236, 105, 60, 246, 51, 177, 120, 227, 52, 28, 254, 4, 3, 158, 139, 186, 23, 166]), proofDigest := (bytes [32, 50, 224, 160, 151, 180, 47, 83, 175, 7, 225, 195, 120, 46, 163, 99, 130, 236, 204, 113, 152, 61, 62, 2, 246, 199, 172, 129, 64, 111, 64, 99]) }, digest := (bytes [129, 138, 174, 5, 255, 253, 129, 183, 216, 28, 225, 116, 153, 198, 179, 189, 89, 132, 75, 243, 54, 209, 212, 217, 115, 5, 232, 185, 102, 184, 181, 133]) }
    , preparedSteps := { claim := { executionDigest := (bytes [28, 1, 84, 184, 89, 242, 14, 108, 33, 243, 25, 226, 156, 89, 231, 121, 72, 112, 15, 25, 78, 90, 217, 60, 9, 73, 78, 4, 175, 30, 106, 21]), finalStateDigest := (bytes [235, 168, 117, 145, 21, 252, 85, 198, 113, 178, 38, 202, 134, 138, 105, 213, 57, 49, 5, 39, 70, 58, 244, 201, 34, 144, 14, 16, 184, 169, 197, 30]), transcriptFinalDigest := (bytes [69, 237, 137, 65, 241, 167, 182, 221, 246, 185, 6, 120, 136, 169, 112, 162, 253, 226, 253, 66, 58, 124, 92, 237, 123, 110, 55, 97, 233, 36, 145, 157]), preparedStepCount := 7, finalPc := 28, halted := true, points := { firstPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [188, 12, 95, 85, 66, 33, 99, 49, 226, 20, 83, 140, 184, 203, 2, 197, 58, 72, 27, 185, 133, 183, 5, 214, 56, 240, 203, 134, 116, 9, 141, 194]), layoutVersion := 3, digest := (bytes [93, 165, 209, 153, 58, 191, 53, 125, 149, 135, 164, 81, 108, 190, 175, 75, 191, 102, 98, 247, 125, 159, 208, 119, 229, 244, 240, 202, 143, 114, 108, 202]) }, logicalIndex := 0, digest := (bytes [129, 215, 43, 59, 203, 39, 35, 65, 215, 34, 107, 74, 102, 41, 143, 193, 105, 59, 216, 89, 191, 88, 229, 192, 27, 145, 190, 119, 196, 193, 146, 86]) }, valueDigest := (bytes [49, 112, 41, 120, 103, 26, 24, 17, 240, 51, 88, 180, 158, 199, 42, 251, 183, 57, 20, 149, 1, 43, 127, 249, 47, 108, 100, 231, 221, 153, 232, 90]), digest := (bytes [34, 109, 239, 78, 212, 125, 84, 109, 35, 231, 9, 110, 158, 166, 139, 211, 73, 48, 227, 193, 83, 46, 47, 210, 163, 190, 147, 240, 188, 142, 74, 13]) }), lastPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [188, 12, 95, 85, 66, 33, 99, 49, 226, 20, 83, 140, 184, 203, 2, 197, 58, 72, 27, 185, 133, 183, 5, 214, 56, 240, 203, 134, 116, 9, 141, 194]), layoutVersion := 3, digest := (bytes [93, 165, 209, 153, 58, 191, 53, 125, 149, 135, 164, 81, 108, 190, 175, 75, 191, 102, 98, 247, 125, 159, 208, 119, 229, 244, 240, 202, 143, 114, 108, 202]) }, logicalIndex := 6, digest := (bytes [27, 222, 251, 202, 155, 65, 36, 46, 105, 119, 166, 124, 124, 92, 5, 11, 163, 81, 33, 98, 148, 207, 51, 68, 71, 88, 69, 250, 107, 132, 2, 115]) }, valueDigest := (bytes [57, 167, 127, 66, 29, 28, 1, 62, 111, 174, 45, 82, 212, 157, 25, 154, 254, 72, 204, 85, 223, 7, 138, 44, 48, 11, 222, 83, 122, 239, 183, 120]), digest := (bytes [239, 144, 64, 133, 16, 33, 187, 192, 199, 171, 231, 186, 85, 250, 190, 54, 136, 147, 57, 153, 203, 201, 166, 165, 80, 159, 29, 7, 34, 242, 144, 125]) }) }, digest := (bytes [42, 43, 187, 138, 183, 43, 10, 144, 163, 176, 102, 142, 139, 48, 17, 47, 216, 200, 70, 210, 136, 11, 37, 58, 178, 17, 30, 193, 195, 48, 146, 55]) }, packaged := { statementDigest := (bytes [2, 6, 120, 45, 36, 121, 65, 175, 54, 40, 183, 87, 172, 78, 29, 108, 217, 133, 65, 12, 214, 237, 175, 11, 102, 87, 33, 225, 80, 210, 26, 98]), proofDigest := (bytes [95, 205, 83, 134, 60, 162, 42, 107, 156, 138, 8, 91, 188, 135, 27, 177, 150, 155, 247, 174, 204, 17, 208, 226, 200, 241, 119, 104, 117, 216, 53, 162]) }, digest := (bytes [104, 161, 237, 106, 213, 86, 56, 187, 59, 171, 30, 146, 84, 245, 188, 145, 56, 189, 98, 238, 160, 119, 225, 127, 204, 183, 83, 71, 147, 126, 93, 83]) }
    , digest := (bytes [153, 66, 190, 187, 35, 36, 86, 58, 136, 141, 131, 132, 103, 148, 218, 91, 83, 111, 51, 179, 149, 216, 145, 116, 212, 56, 181, 212, 15, 0, 155, 76])
  }

def stepComposition : StepCompositionSurfaceView :=
  {
    stage1SemanticsDigest := (bytes [255, 50, 107, 241, 192, 75, 203, 220, 105, 172, 231, 27, 31, 112, 102, 66, 61, 207, 245, 167, 102, 122, 202, 242, 178, 125, 219, 173, 111, 17, 169, 178])
    , stage2SemanticsDigest := (bytes [74, 182, 110, 136, 242, 124, 162, 77, 52, 164, 99, 103, 111, 223, 15, 103, 211, 254, 211, 158, 231, 107, 214, 228, 106, 123, 170, 107, 140, 123, 20, 119])
    , stage2TemporalDigest := (bytes [34, 170, 148, 15, 184, 157, 106, 48, 29, 142, 165, 122, 227, 113, 247, 204, 1, 33, 7, 121, 229, 124, 95, 130, 7, 94, 37, 123, 174, 122, 211, 10])
    , stage3SemanticsDigest := (bytes [188, 163, 27, 52, 221, 123, 120, 113, 195, 255, 112, 101, 48, 33, 200, 85, 75, 130, 194, 222, 75, 178, 13, 76, 190, 51, 69, 141, 137, 18, 61, 194])
    , rootExecutionDigest := (bytes [238, 90, 135, 208, 2, 60, 241, 126, 243, 127, 46, 182, 126, 127, 53, 232, 123, 166, 233, 144, 50, 181, 200, 47, 120, 15, 195, 156, 235, 173, 107, 5])
    , preparedStepBindingsDigest := (bytes [112, 197, 82, 217, 71, 142, 123, 243, 160, 171, 19, 245, 183, 154, 255, 69, 152, 22, 80, 238, 217, 143, 85, 100, 93, 29, 74, 46, 45, 249, 112, 40])
    , rowChunkRoutesDigest := (bytes [210, 211, 133, 148, 162, 150, 85, 66, 2, 24, 230, 163, 67, 64, 160, 246, 143, 119, 48, 189, 194, 114, 28, 76, 211, 182, 93, 15, 73, 83, 209, 85])
    , realRowCount := 7
    , preparedStepCount := 7
    , firstRealStepIndex := 0
    , lastRealStepIndex := 6
    , initialPc := 0
    , finalPc := 28
    , halted := true
    , digest := (bytes [107, 29, 142, 29, 223, 230, 128, 212, 94, 123, 91, 63, 129, 2, 57, 130, 98, 201, 68, 227, 202, 228, 67, 118, 60, 253, 149, 96, 96, 41, 84, 242])
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
    name := "native_sub_lui_auipc_fence_ecall"
    , source := {
  manifest := { name := "native_sub_lui_auipc_fence_ecall", fixtureId := "native_sub_lui_auipc_fence_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , startPc := 0
  , programWords := [9437331, 4194579, 1075872179, 305418807, 8855, 15, 115]
  , initialRegisters := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , initialMemory := []
  , transcriptSeed := (bytes [114, 118, 54, 52, 105, 109, 45, 110, 97, 116, 105, 118, 101, 45, 117, 112, 112, 101, 114, 45, 118, 49])
}
    , derived := {
  manifest := { name := "native_sub_lui_auipc_fence_ecall", fixtureId := "native_sub_lui_auipc_fence_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , executionRows := [{
  traceIndex := 0
  , stepIndex := 0
  , sequenceIndex := 0
  , pc := 0
  , nextPc := 4
  , word := 9437331
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
  , rdAfter := 9
  , imm := 9
  , aluResult := 9
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
  , word := 4194579
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
  , rdAfter := 4
  , imm := 4
  , aluResult := 4
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
  , word := 1075872179
  , opcode := .sub
  , traceOpcode := (some .sub)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 9
  , rs2 := 2
  , rs2Value := 4
  , rd := 3
  , rdBefore := 0
  , rdAfter := 5
  , imm := 0
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
  traceIndex := 3
  , stepIndex := 3
  , sequenceIndex := 0
  , pc := 12
  , nextPc := 16
  , word := 305418807
  , opcode := .lui
  , traceOpcode := (some .lui)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 0
  , rs1Value := 0
  , rs2 := 0
  , rs2Value := 0
  , rd := 4
  , rdBefore := 0
  , rdAfter := 305418240
  , imm := 305418240
  , aluResult := 305418240
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
  traceIndex := 4
  , stepIndex := 4
  , sequenceIndex := 0
  , pc := 16
  , nextPc := 20
  , word := 8855
  , opcode := .auipc
  , traceOpcode := (some .auipc)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 0
  , rs1Value := 0
  , rs2 := 0
  , rs2Value := 0
  , rd := 5
  , rdBefore := 0
  , rdAfter := 8208
  , imm := 8192
  , aluResult := 8208
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
  traceIndex := 5
  , stepIndex := 5
  , sequenceIndex := 0
  , pc := 20
  , nextPc := 24
  , word := 15
  , opcode := .fence
  , traceOpcode := (some .fence)
  , traceVirtualOpcode := none
  , family := .nativeAlu
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
  , halted := false
  , isFirstInSequence := true
  , virtualSequenceRemaining := none
  , isEffectRow := true
  , isCommitRow := true
  , isReal := true
}, {
  traceIndex := 6
  , stepIndex := 6
  , sequenceIndex := 0
  , pc := 24
  , nextPc := 28
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
  , stage1 := { rows := [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 9437331, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 4, aluResult := 9, effectiveAddr := none, writesRd := true, rd := 1, rdAfter := 9, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 4194579, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 8, aluResult := 4, effectiveAddr := none, writesRd := true, rd := 2, rdAfter := 4, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 1075872179, opcode := .sub, traceOpcode := (some .sub), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 12, aluResult := 5, effectiveAddr := none, writesRd := true, rd := 3, rdAfter := 5, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 12, fetchedWord := 305418807, opcode := .lui, traceOpcode := (some .lui), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 16, aluResult := 305418240, effectiveAddr := none, writesRd := true, rd := 4, rdAfter := 305418240, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 4, stepIndex := 4, sequenceIndex := 0, fetchPc := 16, fetchedWord := 8855, opcode := .auipc, traceOpcode := (some .auipc), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 20, aluResult := 8208, effectiveAddr := none, writesRd := true, rd := 5, rdAfter := 8208, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 5, stepIndex := 5, sequenceIndex := 0, fetchPc := 20, fetchedWord := 15, opcode := .fence, traceOpcode := (some .fence), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 24, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }, { traceIndex := 6, stepIndex := 6, sequenceIndex := 0, fetchPc := 24, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 28, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }] }
  , stage2 := {
  registerReads := [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 0, value := 0 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 0, value := 0 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 1, value := 9 }, { traceIndex := 2, stepIndex := 2, role := .rs2, reg := 2, value := 4 }]
  , registerWrites := [{ traceIndex := 0, stepIndex := 0, reg := 1, previous := 0, next := 9 }, { traceIndex := 1, stepIndex := 1, reg := 2, previous := 0, next := 4 }, { traceIndex := 2, stepIndex := 2, reg := 3, previous := 0, next := 5 }, { traceIndex := 3, stepIndex := 3, reg := 4, previous := 0, next := 305418240 }, { traceIndex := 4, stepIndex := 4, reg := 5, previous := 0, next := 8208 }]
  , ramEvents := []
  , twistLinks := [{ traceIndex := 0, stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 9), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 1, family := .nativeAlu, routedWriteValue := (some 4), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 2, family := .nativeAlu, routedWriteValue := (some 5), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 3, family := .nativeAlu, routedWriteValue := (some 305418240), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 4, stepIndex := 4, family := .nativeAlu, routedWriteValue := (some 8208), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 5, stepIndex := 5, family := .nativeAlu, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 6, stepIndex := 6, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]
}
  , stage3 := {
  continuity := [{ stepIndex := 0, pc := 0, nextPc := 4, successorPc := (some 4), finalStep := false, continuityHolds := true }, { stepIndex := 1, pc := 4, nextPc := 8, successorPc := (some 8), finalStep := false, continuityHolds := true }, { stepIndex := 2, pc := 8, nextPc := 12, successorPc := (some 12), finalStep := false, continuityHolds := true }, { stepIndex := 3, pc := 12, nextPc := 16, successorPc := (some 16), finalStep := false, continuityHolds := true }, { stepIndex := 4, pc := 16, nextPc := 20, successorPc := (some 20), finalStep := false, continuityHolds := true }, { stepIndex := 5, pc := 20, nextPc := 24, successorPc := (some 24), finalStep := false, continuityHolds := true }, { stepIndex := 6, pc := 24, nextPc := 28, successorPc := none, finalStep := true, continuityHolds := true }]
  , halted := true
}
  , transcript := {
  appLabel := (bytes [110, 101, 111, 46, 102, 111, 108, 100, 46, 110, 101, 120, 116, 47, 114, 118, 54, 52, 105, 109, 47, 112, 97, 114, 105, 116, 121, 95, 107, 101, 114, 110, 101, 108, 95, 118, 49])
  , events := [{
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 116, 114, 97, 110, 115, 99, 114, 105, 112, 116, 95, 115, 101, 101, 100])
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 110, 97, 116, 105, 118, 101, 45, 117, 112, 112, 101, 114, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [33264016603246709, 49, 3390619080185759186, 12096819762988914126, 4001610679670701799, 5432763535062103318, 13415967828788768464, 15663373744946530692], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [110, 97, 116, 105, 118, 101, 95, 115, 117, 98, 95, 108, 117, 105, 95, 97, 117, 105, 112, 99, 95, 102, 101, 110, 99, 101, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [33264016603246709, 49, 3390619080185759186, 12096819762988914126, 4001610679670701799, 5432763535062103318, 13415967828788768464, 15663373744946530692], absorbed := 2 }
  , cursorAfter := { stateWords := [1819042147, 11492432570176362726, 3613697514698292200, 2650558433509510378, 12055400323590214993, 7120483714660094914, 8332376278638538225, 13997537144169937627], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [9437331, 4194579, 1075872179, 305418807, 8855, 15, 115]
  , cursorBefore := { stateWords := [1819042147, 11492432570176362726, 3613697514698292200, 2650558433509510378, 12055400323590214993, 7120483714660094914, 8332376278638538225, 13997537144169937627], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 8205865210994545291, 16390913469773137775, 10686499010112080571, 3479089081210409115, 11490434913573307181, 4744750243635717087, 14190831713282467533], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [0, 8205865210994545291, 16390913469773137775, 10686499010112080571, 3479089081210409115, 11490434913573307181, 4744750243635717087, 14190831713282467533], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 0, 0, 13927086879393838485, 2623036754198827976, 17760213709172924268, 9303648523283746330, 14333610373503370693], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [0, 0, 0, 13927086879393838485, 2623036754198827976, 17760213709172924268, 9303648523283746330, 14333610373503370693], absorbed := 3 }
  , cursorAfter := { stateWords := [0, 15034277137021512653, 2940523068502370021, 6783709668891648116, 2921762084008379884, 13093662981597386728, 7237693185718636805, 15480948837919714228], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [243, 113, 232, 88, 106, 85, 125, 126, 75, 211, 202, 21, 77, 236, 178, 254, 109, 98, 100, 162, 148, 107, 115, 169, 238, 169, 84, 21, 113, 145, 196, 77])
  , u64s := []
  , cursorBefore := { stateWords := [0, 15034277137021512653, 2940523068502370021, 6783709668891648116, 2921762084008379884, 13093662981597386728, 7237693185718636805, 15480948837919714228], absorbed := 1 }
  , cursorAfter := { stateWords := [16698362512571709445, 5621564629903000699, 10009083160971522880, 7591915833665178415, 4881815619038706464, 1221843751511080609, 17487803174555929498, 11190372688641205339], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [16698362512571709445, 5621564629903000699, 10009083160971522880, 7591915833665178415, 4881815619038706464, 1221843751511080609, 17487803174555929498, 11190372688641205339], absorbed := 0 }
  , cursorAfter := { stateWords := [4896283865473105481, 12847043629536236269, 11452704206453262291, 12159014570259131020, 15761870554813372632, 1933128212755914187, 7691327332694391306, 5251054156748709053], absorbed := 0 }
  , challengeOutput := (some 4896283865473105481)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [13, 9, 218, 115, 204, 43, 4, 113, 32, 177, 132, 132, 182, 134, 250, 82, 89, 188, 40, 248, 201, 130, 127, 49, 3, 60, 79, 175, 212, 151, 219, 255])
  , u64s := []
  , cursorBefore := { stateWords := [4896283865473105481, 12847043629536236269, 11452704206453262291, 12159014570259131020, 15761870554813372632, 1933128212755914187, 7691327332694391306, 5251054156748709053], absorbed := 0 }
  , cursorAfter := { stateWords := [56849324161192698, 49345240094572418, 4292581332, 9800505453015189377, 9590740405110030922, 16846094450105664483, 10584449469242708340, 4875974988665847814], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [56849324161192698, 49345240094572418, 4292581332, 9800505453015189377, 9590740405110030922, 16846094450105664483, 10584449469242708340, 4875974988665847814], absorbed := 3 }
  , cursorAfter := { stateWords := [7033248085425099487, 5551250185185976109, 6838203931123481440, 10155553537626108981, 15357769538341139672, 2358490636320328012, 11314427473321819060, 9232286664736664635], absorbed := 0 }
  , challengeOutput := (some 7033248085425099487)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [7033248085425099487, 5551250185185976109, 6838203931123481440, 10155553537626108981, 15357769538341139672, 2358490636320328012, 11314427473321819060, 9232286664736664635], absorbed := 0 }
  , cursorAfter := { stateWords := [8169386753030433916, 18385266726658662445, 12573782555528246414, 11448961664731975404, 12518743713704370554, 9694518568927529184, 4856529869949649507, 10304706592028699305], absorbed := 0 }
  , challengeOutput := (some 8169386753030433916)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [15, 204, 89, 37, 7, 113, 30, 46, 152, 189, 215, 255, 96, 129, 30, 176, 43, 248, 43, 100, 180, 85, 5, 151, 15, 168, 47, 45, 165, 34, 74, 203])
  , u64s := []
  , cursorBefore := { stateWords := [8169386753030433916, 18385266726658662445, 12573782555528246414, 11448961664731975404, 12518743713704370554, 9694518568927529184, 4856529869949649507, 10304706592028699305], absorbed := 0 }
  , cursorAfter := { stateWords := [50775635817902110, 12718772814546261, 3410633381, 10034820627164037781, 13600521825979114431, 16788147473131196060, 10808458552465737848, 15289043801276852242], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [50775635817902110, 12718772814546261, 3410633381, 10034820627164037781, 13600521825979114431, 16788147473131196060, 10808458552465737848, 15289043801276852242], absorbed := 3 }
  , cursorAfter := { stateWords := [13526737568366105716, 386749902861854862, 505187822126796796, 3924489003198897156, 17943143049075451202, 13587490318313133728, 6809125786034294136, 12332313511951957591], absorbed := 0 }
  , challengeOutput := (some 13526737568366105716)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [13, 62, 18, 231, 159, 216, 74, 146, 123, 100, 48, 154, 55, 62, 243, 77, 247, 72, 183, 146, 55, 128, 226, 205, 79, 61, 249, 159, 174, 184, 114, 0])
  , u64s := []
  , cursorBefore := { stateWords := [13526737568366105716, 386749902861854862, 505187822126796796, 3924489003198897156, 17943143049075451202, 13587490318313133728, 6809125786034294136, 12332313511951957591], absorbed := 0 }
  , cursorAfter := { stateWords := [15642439619923443, 45028563024208512, 7518382, 4674175335594239469, 8343585173727886530, 13355842309813324475, 5970572056999808892, 17880192704068840598], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [28, 1, 84, 184, 89, 242, 14, 108, 33, 243, 25, 226, 156, 89, 231, 121, 72, 112, 15, 25, 78, 90, 217, 60, 9, 73, 78, 4, 175, 30, 106, 21])
  , u64s := []
  , cursorBefore := { stateWords := [15642439619923443, 45028563024208512, 7518382, 4674175335594239469, 8343585173727886530, 13355842309813324475, 5970572056999808892, 17880192704068840598], absorbed := 3 }
  , cursorAfter := { stateWords := [21982602282432999, 1211975501404506, 359276207, 11778840946998352371, 2601310992186137151, 9183972256606065443, 2341718538809599119, 7720520626828516466], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [235, 168, 117, 145, 21, 252, 85, 198, 113, 178, 38, 202, 134, 138, 105, 213, 57, 49, 5, 39, 70, 58, 244, 201, 34, 144, 14, 16, 184, 169, 197, 30])
  , u64s := []
  , cursorBefore := { stateWords := [21982602282432999, 1211975501404506, 359276207, 11778840946998352371, 2601310992186137151, 9183972256606065443, 2341718538809599119, 7720520626828516466], absorbed := 3 }
  , cursorAfter := { stateWords := [19746151623939433, 4519611849110586, 516270520, 841895348041309407, 6525366411293773459, 10331942656253231823, 8000196005749216479, 4242443321909022880], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [19746151623939433, 4519611849110586, 516270520, 841895348041309407, 6525366411293773459, 10331942656253231823, 8000196005749216479, 4242443321909022880], absorbed := 3 }
  , cursorAfter := { stateWords := [6691788142193379930, 442893960619180382, 14347864803423902063, 2733085216426276580, 13712782214558036224, 14831264393031247711, 17027622760445651302, 1083395422601994900], absorbed := 0 }
  , challengeOutput := (some 6691788142193379930)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [6691788142193379930, 442893960619180382, 14347864803423902063, 2733085216426276580, 13712782214558036224, 14831264393031247711, 17027622760445651302, 1083395422601994900], absorbed := 0 }
  , cursorAfter := { stateWords := [15976141382771928389, 11705041835130272246, 17103682074520183549, 11353896720354733691, 6592350785348559089, 11058181024729775942, 13765259832617846959, 12403894881833510756], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [69, 237, 137, 65, 241, 167, 182, 221, 246, 185, 6, 120, 136, 169, 112, 162, 253, 226, 253, 66, 58, 124, 92, 237, 123, 110, 55, 97, 233, 36, 145, 157]))
}]
}
  , kernel := {
  root0Digest := (bytes [243, 113, 232, 88, 106, 85, 125, 126, 75, 211, 202, 21, 77, 236, 178, 254, 109, 98, 100, 162, 148, 107, 115, 169, 238, 169, 84, 21, 113, 145, 196, 77])
  , stage1Digest := (bytes [13, 9, 218, 115, 204, 43, 4, 113, 32, 177, 132, 132, 182, 134, 250, 82, 89, 188, 40, 248, 201, 130, 127, 49, 3, 60, 79, 175, 212, 151, 219, 255])
  , stage2Digest := (bytes [15, 204, 89, 37, 7, 113, 30, 46, 152, 189, 215, 255, 96, 129, 30, 176, 43, 248, 43, 100, 180, 85, 5, 151, 15, 168, 47, 45, 165, 34, 74, 203])
  , stage3Digest := (bytes [13, 62, 18, 231, 159, 216, 74, 146, 123, 100, 48, 154, 55, 62, 243, 77, 247, 72, 183, 146, 55, 128, 226, 205, 79, 61, 249, 159, 174, 184, 114, 0])
  , executionDigest := (bytes [28, 1, 84, 184, 89, 242, 14, 108, 33, 243, 25, 226, 156, 89, 231, 121, 72, 112, 15, 25, 78, 90, 217, 60, 9, 73, 78, 4, 175, 30, 106, 21])
  , finalStateDigest := (bytes [235, 168, 117, 145, 21, 252, 85, 198, 113, 178, 38, 202, 134, 138, 105, 213, 57, 49, 5, 39, 70, 58, 244, 201, 34, 144, 14, 16, 184, 169, 197, 30])
  , stage1Mix := 4896283865473105481
  , stage2RegMix := 7033248085425099487
  , stage2RamMix := 8169386753030433916
  , stage3ContinuityMix := 13526737568366105716
  , kernelFinalMix := 6691788142193379930
  , transcriptFinalDigest := (bytes [69, 237, 137, 65, 241, 167, 182, 221, 246, 185, 6, 120, 136, 169, 112, 162, 253, 226, 253, 66, 58, 124, 92, 237, 123, 110, 55, 97, 233, 36, 145, 157])
  , finalPc := 28
  , finalRegisters := [0, 9, 4, 5, 305418240, 8208, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , finalMemory := []
  , halted := true
}
}
    , kernelProof := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "native_sub_lui_auipc_fence_ecall", fixtureId := "native_sub_lui_auipc_fence_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , executionDigest := (bytes [28, 1, 84, 184, 89, 242, 14, 108, 33, 243, 25, 226, 156, 89, 231, 121, 72, 112, 15, 25, 78, 90, 217, 60, 9, 73, 78, 4, 175, 30, 106, 21])
  , shape := { executionRowCount := 7, realRowCount := 7, effectRowCount := 7, commitRowCount := 7, digest := (bytes [36, 118, 223, 124, 248, 115, 52, 199, 198, 250, 25, 33, 218, 131, 247, 174, 126, 69, 105, 226, 74, 199, 244, 245, 142, 55, 128, 143, 190, 129, 55, 117]) }
  , digest := (bytes [25, 177, 8, 78, 250, 64, 121, 27, 95, 130, 19, 187, 172, 206, 182, 113, 40, 6, 86, 61, 186, 140, 176, 73, 167, 183, 185, 149, 17, 51, 159, 234])
}
  , stages := { summary := { stage1RowCount := 7, stage2RegisterReadCount := 4, stage2RegisterWriteCount := 5, stage2RamEventCount := 0, stage2TwistLinkCount := 7, stage3ContinuityCount := 7, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [46, 60, 80, 68, 232, 175, 7, 254, 34, 84, 66, 191, 186, 46, 55, 77, 247, 135, 191, 47, 61, 137, 117, 18, 238, 18, 212, 9, 122, 9, 11, 114]) }, digest := (bytes [107, 50, 114, 67, 253, 159, 78, 201, 18, 88, 90, 164, 67, 99, 228, 158, 81, 35, 118, 111, 232, 74, 74, 246, 34, 208, 132, 50, 143, 226, 36, 231]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [223, 225, 90, 207, 134, 93, 119, 56, 41, 5, 124, 209, 164, 29, 171, 3, 36, 243, 143, 44, 178, 63, 24, 247, 108, 3, 98, 54, 90, 32, 232, 16]), stage1Digest := (bytes [64, 84, 229, 244, 202, 62, 104, 54, 50, 187, 250, 129, 94, 180, 4, 55, 226, 242, 74, 117, 54, 226, 62, 122, 109, 26, 132, 182, 138, 51, 16, 221]), stage2Digest := (bytes [65, 117, 94, 226, 199, 99, 0, 115, 210, 41, 234, 106, 155, 98, 21, 72, 184, 238, 222, 173, 90, 126, 128, 56, 218, 130, 176, 5, 142, 88, 136, 50]), stage3Digest := (bytes [191, 231, 148, 196, 231, 32, 230, 244, 246, 105, 83, 164, 118, 60, 102, 72, 67, 56, 200, 185, 75, 228, 213, 186, 94, 157, 206, 182, 221, 166, 14, 83]), transcriptDigest := (bytes [69, 237, 137, 65, 241, 167, 182, 221, 246, 185, 6, 120, 136, 169, 112, 162, 253, 226, 253, 66, 58, 124, 92, 237, 123, 110, 55, 97, 233, 36, 145, 157]), executionDigest := (bytes [28, 1, 84, 184, 89, 242, 14, 108, 33, 243, 25, 226, 156, 89, 231, 121, 72, 112, 15, 25, 78, 90, 217, 60, 9, 73, 78, 4, 175, 30, 106, 21]), digest := (bytes [174, 196, 6, 102, 3, 97, 153, 82, 217, 147, 83, 12, 127, 248, 114, 137, 116, 13, 71, 169, 60, 34, 41, 230, 245, 231, 92, 165, 215, 114, 152, 172]) }, statementDigest := (bytes [31, 95, 156, 162, 153, 195, 123, 136, 98, 121, 229, 184, 10, 204, 86, 75, 7, 85, 128, 8, 150, 213, 17, 224, 198, 175, 204, 241, 34, 152, 24, 75]), proofDigest := (bytes [30, 212, 61, 182, 78, 252, 131, 84, 85, 152, 38, 107, 137, 117, 116, 183, 123, 3, 175, 228, 117, 241, 83, 228, 61, 57, 13, 48, 219, 236, 252, 76]), digest := (bytes [35, 77, 86, 75, 86, 182, 236, 197, 64, 43, 180, 51, 61, 219, 114, 231, 99, 113, 179, 232, 208, 116, 200, 50, 118, 6, 170, 254, 149, 8, 27, 233]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [150, 142, 19, 32, 35, 228, 183, 42, 168, 254, 224, 21, 201, 251, 104, 107, 156, 210, 162, 210, 187, 213, 91, 41, 34, 90, 7, 179, 143, 206, 21, 186]), stage1Digest := (bytes [207, 40, 159, 62, 60, 5, 240, 79, 61, 235, 232, 64, 80, 50, 15, 50, 1, 147, 76, 6, 172, 104, 25, 175, 15, 199, 167, 51, 8, 68, 177, 92]), stage2Digest := (bytes [91, 238, 67, 192, 173, 230, 176, 69, 21, 217, 100, 79, 117, 10, 31, 183, 249, 182, 54, 243, 26, 41, 183, 69, 215, 140, 117, 247, 219, 146, 110, 164]), stage3Digest := (bytes [92, 247, 26, 104, 3, 68, 55, 71, 237, 45, 12, 153, 238, 197, 30, 23, 0, 5, 192, 200, 156, 49, 112, 225, 23, 23, 16, 191, 254, 164, 5, 217]), digest := (bytes [45, 137, 221, 116, 85, 65, 64, 58, 3, 92, 186, 197, 200, 201, 88, 159, 156, 55, 243, 123, 126, 142, 209, 206, 137, 22, 188, 125, 173, 17, 168, 248]) }, digest := (bytes [52, 190, 239, 220, 236, 238, 67, 70, 23, 4, 94, 122, 14, 113, 70, 190, 94, 82, 149, 196, 47, 72, 72, 234, 109, 24, 115, 178, 82, 113, 170, 111]) }
  , kernelOpening := { openingDigest := (bytes [153, 66, 190, 187, 35, 36, 86, 58, 136, 141, 131, 132, 103, 148, 218, 91, 83, 111, 51, 179, 149, 216, 145, 116, 212, 56, 181, 212, 15, 0, 155, 76]), bindings := { claimDigest := (bytes [99, 34, 151, 196, 202, 146, 254, 239, 47, 204, 153, 51, 30, 203, 74, 164, 234, 127, 173, 202, 32, 168, 7, 101, 17, 82, 80, 237, 198, 225, 67, 175]), bindingsDigest := (bytes [129, 138, 174, 5, 255, 253, 129, 183, 216, 28, 225, 116, 153, 198, 179, 189, 89, 132, 75, 243, 54, 209, 212, 217, 115, 5, 232, 185, 102, 184, 181, 133]), preparedStepsDigest := (bytes [104, 161, 237, 106, 213, 86, 56, 187, 59, 171, 30, 146, 84, 245, 188, 145, 56, 189, 98, 238, 160, 119, 225, 127, 204, 183, 83, 71, 147, 126, 93, 83]), digest := (bytes [225, 152, 64, 173, 123, 31, 30, 7, 76, 87, 58, 3, 100, 205, 188, 77, 218, 237, 125, 142, 149, 116, 201, 247, 223, 107, 149, 135, 20, 139, 187, 149]) }, digest := (bytes [246, 239, 58, 153, 3, 236, 85, 36, 188, 10, 50, 193, 184, 94, 232, 222, 167, 119, 0, 179, 144, 23, 134, 108, 183, 203, 105, 27, 190, 107, 130, 138]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [112, 197, 82, 217, 71, 142, 123, 243, 160, 171, 19, 245, 183, 154, 255, 69, 152, 22, 80, 238, 217, 143, 85, 100, 93, 29, 74, 46, 45, 249, 112, 40]), terminal := { root0Digest := (bytes [243, 113, 232, 88, 106, 85, 125, 126, 75, 211, 202, 21, 77, 236, 178, 254, 109, 98, 100, 162, 148, 107, 115, 169, 238, 169, 84, 21, 113, 145, 196, 77]), executionDigest := (bytes [28, 1, 84, 184, 89, 242, 14, 108, 33, 243, 25, 226, 156, 89, 231, 121, 72, 112, 15, 25, 78, 90, 217, 60, 9, 73, 78, 4, 175, 30, 106, 21]), finalStateDigest := (bytes [235, 168, 117, 145, 21, 252, 85, 198, 113, 178, 38, 202, 134, 138, 105, 213, 57, 49, 5, 39, 70, 58, 244, 201, 34, 144, 14, 16, 184, 169, 197, 30]), transcriptFinalDigest := (bytes [69, 237, 137, 65, 241, 167, 182, 221, 246, 185, 6, 120, 136, 169, 112, 162, 253, 226, 253, 66, 58, 124, 92, 237, 123, 110, 55, 97, 233, 36, 145, 157]), finalPc := 28, halted := true, digest := (bytes [119, 214, 190, 186, 54, 197, 166, 242, 37, 110, 67, 95, 104, 49, 84, 197, 11, 83, 73, 168, 49, 213, 3, 148, 216, 177, 112, 193, 85, 101, 120, 22]) }, digest := (bytes [30, 239, 83, 8, 170, 59, 238, 195, 251, 232, 77, 197, 205, 161, 118, 240, 151, 151, 80, 11, 214, 160, 121, 14, 159, 146, 1, 108, 61, 229, 194, 118]) }, statementDigest := (bytes [124, 156, 154, 171, 189, 248, 70, 22, 31, 55, 1, 96, 178, 184, 228, 119, 125, 97, 30, 225, 108, 109, 3, 93, 188, 57, 156, 200, 229, 206, 48, 58]), proofDigest := (bytes [115, 29, 228, 63, 183, 24, 43, 189, 218, 32, 158, 46, 7, 216, 139, 236, 26, 44, 25, 35, 76, 238, 116, 238, 83, 169, 201, 249, 201, 28, 148, 146]), digest := (bytes [145, 67, 229, 156, 229, 109, 195, 165, 193, 66, 157, 156, 180, 30, 108, 89, 13, 97, 239, 246, 100, 51, 14, 208, 99, 183, 178, 39, 210, 153, 105, 113]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [6, 23, 36, 33, 23, 226, 157, 251, 165, 190, 255, 219, 249, 58, 34, 233, 160, 194, 223, 125, 31, 225, 196, 138, 224, 6, 179, 93, 109, 39, 25, 113]), layoutVersion := 1, digest := (bytes [215, 208, 213, 36, 98, 12, 42, 132, 158, 68, 40, 9, 236, 133, 239, 185, 198, 81, 232, 6, 93, 27, 137, 38, 86, 217, 165, 249, 122, 174, 131, 168]) }, rowWidth := 38, timeLen := 7, columnDigests := [(bytes [40, 243, 169, 246, 170, 121, 143, 48, 132, 183, 68, 213, 151, 130, 14, 65, 20, 212, 138, 236, 77, 112, 226, 150, 158, 109, 142, 75, 172, 115, 156, 234]), (bytes [183, 255, 181, 34, 203, 1, 222, 219, 152, 86, 144, 13, 74, 163, 20, 134, 40, 184, 20, 201, 107, 98, 76, 0, 125, 194, 18, 176, 16, 226, 102, 175]), (bytes [153, 111, 70, 176, 156, 174, 226, 182, 197, 190, 144, 153, 100, 226, 206, 209, 132, 162, 24, 222, 166, 233, 132, 102, 120, 151, 149, 92, 177, 154, 105, 134]), (bytes [188, 23, 179, 202, 216, 119, 253, 192, 107, 56, 140, 18, 247, 51, 234, 39, 235, 216, 134, 241, 7, 60, 104, 146, 182, 166, 45, 236, 214, 213, 211, 83]), (bytes [78, 156, 218, 132, 187, 128, 28, 175, 180, 45, 97, 45, 52, 94, 142, 189, 238, 235, 64, 164, 28, 129, 72, 154, 162, 227, 67, 115, 203, 223, 178, 142]), (bytes [247, 84, 178, 204, 90, 180, 61, 115, 170, 41, 175, 56, 192, 166, 216, 206, 90, 250, 210, 11, 223, 56, 140, 159, 30, 177, 31, 157, 136, 117, 20, 121]), (bytes [50, 117, 247, 44, 135, 251, 33, 130, 187, 149, 173, 15, 157, 44, 184, 232, 74, 29, 121, 15, 49, 15, 1, 170, 4, 57, 254, 21, 66, 20, 255, 57]), (bytes [42, 144, 74, 161, 221, 59, 4, 10, 214, 228, 39, 229, 69, 243, 213, 91, 38, 245, 79, 115, 75, 9, 211, 87, 113, 158, 116, 122, 108, 167, 109, 114]), (bytes [179, 197, 166, 238, 247, 39, 161, 56, 86, 33, 181, 194, 233, 28, 80, 101, 156, 182, 133, 82, 176, 76, 183, 86, 85, 15, 113, 247, 11, 149, 206, 77]), (bytes [133, 160, 199, 189, 7, 112, 198, 246, 237, 84, 81, 147, 189, 17, 217, 241, 202, 249, 239, 243, 169, 101, 30, 246, 218, 32, 171, 254, 107, 102, 128, 154]), (bytes [63, 200, 130, 136, 30, 171, 131, 98, 252, 188, 139, 234, 231, 103, 43, 28, 103, 10, 4, 88, 242, 189, 178, 158, 238, 119, 30, 71, 137, 61, 186, 18]), (bytes [126, 86, 142, 26, 182, 125, 203, 210, 164, 8, 133, 114, 56, 130, 212, 35, 222, 149, 156, 50, 191, 58, 183, 101, 106, 74, 112, 221, 102, 51, 206, 34]), (bytes [18, 172, 128, 176, 253, 198, 4, 93, 34, 80, 94, 154, 166, 81, 235, 21, 208, 214, 240, 19, 132, 26, 227, 255, 47, 232, 138, 242, 49, 178, 152, 151]), (bytes [123, 115, 37, 51, 88, 50, 51, 84, 5, 102, 248, 34, 238, 90, 209, 104, 209, 182, 98, 112, 16, 243, 38, 61, 147, 240, 83, 109, 196, 231, 107, 44]), (bytes [125, 139, 255, 63, 66, 75, 217, 97, 3, 18, 128, 169, 165, 111, 145, 8, 118, 207, 26, 139, 239, 101, 9, 150, 41, 34, 162, 59, 254, 252, 55, 58]), (bytes [44, 32, 216, 93, 16, 146, 0, 130, 207, 204, 36, 141, 166, 246, 232, 20, 247, 247, 116, 89, 62, 217, 122, 245, 142, 15, 143, 44, 219, 131, 183, 12]), (bytes [63, 55, 148, 202, 193, 201, 88, 153, 244, 174, 145, 10, 157, 92, 137, 79, 24, 240, 86, 214, 120, 193, 105, 254, 83, 207, 7, 36, 175, 251, 198, 209]), (bytes [49, 184, 142, 166, 178, 93, 15, 133, 19, 3, 245, 149, 190, 250, 17, 77, 195, 143, 141, 153, 122, 25, 168, 96, 127, 182, 178, 210, 211, 3, 144, 60]), (bytes [86, 196, 110, 116, 66, 242, 23, 243, 102, 32, 103, 253, 30, 136, 67, 166, 214, 221, 241, 169, 190, 115, 51, 189, 2, 90, 50, 65, 2, 198, 240, 74]), (bytes [204, 170, 135, 24, 120, 2, 130, 166, 238, 140, 237, 167, 80, 81, 222, 98, 53, 76, 178, 231, 84, 4, 44, 222, 24, 14, 1, 161, 175, 62, 34, 83]), (bytes [254, 19, 232, 192, 11, 39, 102, 229, 212, 95, 179, 72, 76, 113, 31, 113, 119, 17, 192, 125, 69, 105, 89, 144, 235, 22, 196, 55, 37, 148, 98, 206]), (bytes [126, 178, 122, 220, 67, 252, 127, 71, 82, 225, 133, 219, 37, 32, 10, 78, 133, 40, 227, 107, 52, 114, 163, 131, 123, 127, 232, 227, 171, 62, 101, 156]), (bytes [150, 56, 15, 19, 5, 104, 56, 230, 209, 159, 201, 154, 59, 102, 109, 165, 137, 182, 61, 198, 151, 229, 213, 14, 110, 234, 163, 84, 29, 98, 8, 176]), (bytes [200, 56, 51, 134, 173, 219, 218, 153, 14, 48, 181, 178, 53, 188, 122, 219, 157, 116, 70, 125, 225, 15, 34, 230, 227, 66, 217, 29, 84, 102, 182, 253]), (bytes [210, 70, 3, 57, 245, 131, 122, 183, 202, 155, 172, 21, 75, 121, 43, 183, 199, 58, 106, 240, 174, 143, 12, 118, 52, 65, 199, 50, 16, 143, 205, 192]), (bytes [179, 48, 0, 250, 27, 221, 177, 148, 93, 180, 91, 49, 228, 54, 116, 100, 128, 40, 176, 25, 157, 98, 83, 138, 39, 246, 67, 217, 82, 69, 86, 192]), (bytes [230, 233, 51, 142, 175, 227, 185, 68, 193, 102, 205, 229, 70, 211, 83, 226, 20, 174, 185, 68, 145, 102, 56, 1, 187, 15, 129, 252, 242, 17, 12, 153]), (bytes [115, 221, 25, 201, 235, 175, 57, 9, 159, 237, 1, 99, 122, 176, 133, 105, 76, 191, 15, 198, 154, 87, 195, 119, 27, 252, 234, 251, 191, 97, 36, 22]), (bytes [159, 136, 79, 19, 3, 64, 16, 130, 170, 158, 169, 178, 191, 146, 174, 198, 91, 233, 1, 17, 175, 210, 201, 9, 131, 122, 214, 44, 60, 157, 185, 73]), (bytes [83, 251, 49, 48, 54, 174, 206, 33, 38, 55, 53, 86, 238, 134, 67, 140, 194, 44, 73, 155, 93, 189, 217, 191, 38, 87, 214, 184, 137, 68, 230, 167]), (bytes [240, 212, 182, 90, 28, 28, 194, 255, 94, 159, 35, 103, 91, 242, 214, 20, 102, 217, 67, 85, 43, 252, 11, 32, 160, 11, 241, 164, 190, 14, 75, 153]), (bytes [83, 203, 23, 43, 120, 2, 138, 179, 201, 101, 117, 199, 249, 119, 150, 189, 107, 206, 100, 240, 241, 191, 29, 12, 95, 189, 46, 162, 173, 67, 52, 64]), (bytes [243, 18, 112, 16, 115, 206, 161, 217, 70, 120, 53, 168, 21, 217, 125, 177, 15, 184, 39, 220, 129, 252, 253, 217, 143, 169, 231, 204, 197, 173, 74, 44]), (bytes [174, 205, 154, 64, 243, 198, 70, 67, 132, 170, 211, 195, 186, 11, 96, 55, 55, 6, 248, 130, 169, 186, 214, 86, 104, 198, 34, 111, 234, 42, 133, 117]), (bytes [181, 205, 4, 135, 126, 61, 165, 192, 182, 157, 219, 25, 61, 190, 241, 123, 199, 165, 114, 116, 128, 144, 237, 80, 99, 219, 70, 24, 44, 75, 141, 99]), (bytes [64, 184, 77, 60, 124, 164, 54, 93, 23, 121, 89, 235, 81, 60, 107, 51, 86, 73, 18, 40, 80, 16, 45, 151, 39, 61, 175, 64, 40, 48, 21, 239]), (bytes [233, 150, 233, 24, 120, 142, 81, 204, 197, 94, 9, 71, 112, 24, 112, 173, 149, 24, 63, 117, 95, 104, 238, 197, 31, 101, 173, 98, 112, 244, 218, 130]), (bytes [145, 99, 191, 35, 121, 90, 118, 57, 187, 82, 200, 99, 201, 117, 132, 16, 109, 95, 126, 62, 89, 129, 183, 210, 46, 8, 148, 208, 73, 204, 191, 238])], familyDigest := (bytes [6, 23, 36, 33, 23, 226, 157, 251, 165, 190, 255, 219, 249, 58, 34, 233, 160, 194, 223, 125, 31, 225, 196, 138, 224, 6, 179, 93, 109, 39, 25, 113]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [6, 23, 36, 33, 23, 226, 157, 251, 165, 190, 255, 219, 249, 58, 34, 233, 160, 194, 223, 125, 31, 225, 196, 138, 224, 6, 179, 93, 109, 39, 25, 113]), layoutVersion := 1, digest := (bytes [215, 208, 213, 36, 98, 12, 42, 132, 158, 68, 40, 9, 236, 133, 239, 185, 198, 81, 232, 6, 93, 27, 137, 38, 86, 217, 165, 249, 122, 174, 131, 168]) }, logicalIndex := 0, digest := (bytes [108, 77, 206, 195, 120, 223, 83, 3, 248, 79, 145, 30, 138, 29, 114, 42, 133, 197, 137, 83, 200, 226, 104, 75, 191, 200, 247, 248, 184, 27, 238, 62]) }, valueDigest := (bytes [49, 112, 41, 120, 103, 26, 24, 17, 240, 51, 88, 180, 158, 199, 42, 251, 183, 57, 20, 149, 1, 43, 127, 249, 47, 108, 100, 231, 221, 153, 232, 90]), digest := (bytes [17, 207, 121, 237, 159, 155, 36, 164, 116, 95, 128, 75, 120, 77, 118, 119, 80, 17, 73, 60, 22, 80, 44, 110, 232, 41, 145, 233, 164, 251, 92, 238]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [6, 23, 36, 33, 23, 226, 157, 251, 165, 190, 255, 219, 249, 58, 34, 233, 160, 194, 223, 125, 31, 225, 196, 138, 224, 6, 179, 93, 109, 39, 25, 113]), layoutVersion := 1, digest := (bytes [215, 208, 213, 36, 98, 12, 42, 132, 158, 68, 40, 9, 236, 133, 239, 185, 198, 81, 232, 6, 93, 27, 137, 38, 86, 217, 165, 249, 122, 174, 131, 168]) }, logicalIndex := 6, digest := (bytes [216, 72, 40, 191, 64, 74, 101, 211, 203, 238, 142, 231, 112, 78, 0, 138, 144, 122, 184, 130, 143, 193, 200, 114, 121, 8, 231, 201, 217, 200, 170, 128]) }, valueDigest := (bytes [57, 167, 127, 66, 29, 28, 1, 62, 111, 174, 45, 82, 212, 157, 25, 154, 254, 72, 204, 85, 223, 7, 138, 44, 48, 11, 222, 83, 122, 239, 183, 120]), digest := (bytes [66, 120, 177, 28, 12, 51, 17, 88, 29, 137, 234, 40, 93, 97, 58, 32, 240, 194, 5, 198, 91, 176, 154, 39, 164, 136, 135, 32, 86, 196, 137, 83]) }), digest := (bytes [185, 24, 211, 142, 31, 112, 65, 51, 253, 112, 60, 223, 123, 82, 147, 127, 254, 126, 62, 18, 64, 21, 206, 117, 19, 200, 13, 224, 237, 197, 69, 170]) }
  , rootLaneCommitment := { timeLen := 7, commitments := { commitmentCount := 38, digest := (bytes [188, 12, 95, 85, 66, 33, 99, 49, 226, 20, 83, 140, 184, 203, 2, 197, 58, 72, 27, 185, 133, 183, 5, 214, 56, 240, 203, 134, 116, 9, 141, 194]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [188, 12, 95, 85, 66, 33, 99, 49, 226, 20, 83, 140, 184, 203, 2, 197, 58, 72, 27, 185, 133, 183, 5, 214, 56, 240, 203, 134, 116, 9, 141, 194]), layoutVersion := 3, digest := (bytes [93, 165, 209, 153, 58, 191, 53, 125, 149, 135, 164, 81, 108, 190, 175, 75, 191, 102, 98, 247, 125, 159, 208, 119, 229, 244, 240, 202, 143, 114, 108, 202]) }, logicalIndex := 0, digest := (bytes [129, 215, 43, 59, 203, 39, 35, 65, 215, 34, 107, 74, 102, 41, 143, 193, 105, 59, 216, 89, 191, 88, 229, 192, 27, 145, 190, 119, 196, 193, 146, 86]) }, valueDigest := (bytes [49, 112, 41, 120, 103, 26, 24, 17, 240, 51, 88, 180, 158, 199, 42, 251, 183, 57, 20, 149, 1, 43, 127, 249, 47, 108, 100, 231, 221, 153, 232, 90]), digest := (bytes [34, 109, 239, 78, 212, 125, 84, 109, 35, 231, 9, 110, 158, 166, 139, 211, 73, 48, 227, 193, 83, 46, 47, 210, 163, 190, 147, 240, 188, 142, 74, 13]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [188, 12, 95, 85, 66, 33, 99, 49, 226, 20, 83, 140, 184, 203, 2, 197, 58, 72, 27, 185, 133, 183, 5, 214, 56, 240, 203, 134, 116, 9, 141, 194]), layoutVersion := 3, digest := (bytes [93, 165, 209, 153, 58, 191, 53, 125, 149, 135, 164, 81, 108, 190, 175, 75, 191, 102, 98, 247, 125, 159, 208, 119, 229, 244, 240, 202, 143, 114, 108, 202]) }, logicalIndex := 6, digest := (bytes [27, 222, 251, 202, 155, 65, 36, 46, 105, 119, 166, 124, 124, 92, 5, 11, 163, 81, 33, 98, 148, 207, 51, 68, 71, 88, 69, 250, 107, 132, 2, 115]) }, valueDigest := (bytes [57, 167, 127, 66, 29, 28, 1, 62, 111, 174, 45, 82, 212, 157, 25, 154, 254, 72, 204, 85, 223, 7, 138, 44, 48, 11, 222, 83, 122, 239, 183, 120]), digest := (bytes [239, 144, 64, 133, 16, 33, 187, 192, 199, 171, 231, 186, 85, 250, 190, 54, 136, 147, 57, 153, 203, 201, 166, 165, 80, 159, 29, 7, 34, 242, 144, 125]) }), digest := (bytes [154, 54, 137, 236, 75, 115, 116, 110, 148, 80, 210, 34, 52, 240, 128, 94, 154, 75, 213, 221, 154, 160, 95, 236, 179, 252, 242, 20, 68, 216, 117, 243]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [185, 24, 211, 142, 31, 112, 65, 51, 253, 112, 60, 223, 123, 82, 147, 127, 254, 126, 62, 18, 64, 21, 206, 117, 19, 200, 13, 224, 237, 197, 69, 170]), rootLaneCommitmentDigest := (bytes [154, 54, 137, 236, 75, 115, 116, 110, 148, 80, 210, 34, 52, 240, 128, 94, 154, 75, 213, 221, 154, 160, 95, 236, 179, 252, 242, 20, 68, 216, 117, 243]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 7, digest := (bytes [206, 159, 213, 58, 149, 250, 197, 229, 63, 141, 122, 233, 11, 38, 60, 217, 215, 34, 60, 17, 141, 154, 200, 71, 6, 104, 67, 107, 105, 225, 247, 114]) }, statementDigest := (bytes [149, 99, 152, 248, 29, 72, 150, 108, 49, 205, 156, 74, 10, 12, 136, 78, 8, 240, 221, 63, 39, 142, 87, 120, 12, 133, 254, 176, 161, 154, 58, 228]), proofDigest := (bytes [142, 4, 17, 150, 223, 130, 123, 216, 10, 91, 235, 126, 9, 148, 131, 195, 18, 211, 37, 62, 45, 2, 94, 114, 112, 56, 49, 30, 29, 144, 252, 207]), digest := (bytes [11, 174, 3, 238, 131, 48, 50, 235, 141, 1, 103, 149, 189, 244, 17, 245, 9, 195, 8, 21, 46, 95, 194, 235, 69, 28, 176, 211, 210, 72, 177, 98]) }
  , digest := (bytes [25, 208, 63, 191, 56, 150, 225, 211, 131, 209, 183, 103, 230, 33, 34, 36, 245, 162, 195, 60, 200, 17, 239, 169, 26, 209, 78, 207, 135, 192, 57, 129])
}
    , exportedProof := {
  claim := {
  accepted := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , statement := { proofStatementDigest := (bytes [103, 27, 39, 162, 68, 137, 185, 117, 237, 254, 70, 203, 99, 51, 244, 146, 116, 162, 208, 115, 237, 31, 185, 139, 65, 255, 181, 53, 167, 1, 247, 23]), kernelOpeningDigest := (bytes [246, 239, 58, 153, 3, 236, 85, 36, 188, 10, 50, 193, 184, 94, 232, 222, 167, 119, 0, 179, 144, 23, 134, 108, 183, 203, 105, 27, 190, 107, 130, 138]), digest := (bytes [181, 240, 134, 186, 209, 104, 210, 141, 165, 188, 162, 19, 20, 18, 197, 36, 15, 208, 9, 182, 6, 96, 183, 231, 130, 1, 109, 106, 136, 98, 87, 93]) }
  , mainLane := { mainLaneBundleDigest := (bytes [11, 174, 3, 238, 131, 48, 50, 235, 141, 1, 103, 149, 189, 244, 17, 245, 9, 195, 8, 21, 46, 95, 194, 235, 69, 28, 176, 211, 210, 72, 177, 98]), digest := (bytes [178, 245, 29, 80, 82, 53, 101, 144, 108, 106, 73, 232, 21, 214, 206, 214, 122, 102, 164, 246, 228, 121, 56, 76, 87, 71, 159, 45, 142, 54, 87, 175]) }
  , terminal := { finalStateDigest := (bytes [235, 168, 117, 145, 21, 252, 85, 198, 113, 178, 38, 202, 134, 138, 105, 213, 57, 49, 5, 39, 70, 58, 244, 201, 34, 144, 14, 16, 184, 169, 197, 30]), finalPc := 28, halted := true, digest := (bytes [11, 107, 79, 125, 37, 71, 186, 127, 223, 171, 110, 138, 239, 210, 23, 51, 141, 136, 244, 21, 95, 244, 93, 182, 164, 27, 247, 7, 50, 39, 167, 118]) }
  , digest := (bytes [135, 192, 244, 62, 46, 187, 224, 79, 155, 8, 187, 57, 133, 189, 85, 234, 92, 145, 136, 218, 49, 1, 0, 126, 181, 29, 36, 239, 8, 141, 28, 34])
}
  , mainLane := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { mainLaneBundleDigest := (bytes [11, 174, 3, 238, 131, 48, 50, 235, 141, 1, 103, 149, 189, 244, 17, 245, 9, 195, 8, 21, 46, 95, 194, 235, 69, 28, 176, 211, 210, 72, 177, 98]), digest := (bytes [21, 167, 30, 47, 106, 32, 171, 118, 155, 122, 42, 85, 147, 145, 117, 8, 251, 65, 241, 242, 207, 106, 38, 69, 55, 175, 94, 236, 127, 93, 227, 200]) }, digest := (bytes [116, 229, 1, 90, 33, 105, 78, 240, 231, 197, 6, 54, 128, 65, 5, 209, 126, 158, 75, 89, 40, 196, 52, 151, 252, 177, 249, 142, 91, 114, 51, 180]) }
  , opening := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , stages := { stageClaimsDigest := (bytes [35, 77, 86, 75, 86, 182, 236, 197, 64, 43, 180, 51, 61, 219, 114, 231, 99, 113, 179, 232, 208, 116, 200, 50, 118, 6, 170, 254, 149, 8, 27, 233]), stagePackagesDigest := (bytes [52, 190, 239, 220, 236, 238, 67, 70, 23, 4, 94, 122, 14, 113, 70, 190, 94, 82, 149, 196, 47, 72, 72, 234, 109, 24, 115, 178, 82, 113, 170, 111]), kernelOpeningDigest := (bytes [246, 239, 58, 153, 3, 236, 85, 36, 188, 10, 50, 193, 184, 94, 232, 222, 167, 119, 0, 179, 144, 23, 134, 108, 183, 203, 105, 27, 190, 107, 130, 138]), digest := (bytes [115, 169, 67, 90, 225, 199, 57, 253, 146, 45, 177, 243, 98, 28, 57, 31, 217, 165, 199, 216, 156, 199, 129, 83, 242, 31, 254, 141, 192, 59, 189, 209]) }
  , terminal := { preparedStepBindingsDigest := (bytes [112, 197, 82, 217, 71, 142, 123, 243, 160, 171, 19, 245, 183, 154, 255, 69, 152, 22, 80, 238, 217, 143, 85, 100, 93, 29, 74, 46, 45, 249, 112, 40]), executionDigest := (bytes [28, 1, 84, 184, 89, 242, 14, 108, 33, 243, 25, 226, 156, 89, 231, 121, 72, 112, 15, 25, 78, 90, 217, 60, 9, 73, 78, 4, 175, 30, 106, 21]), transcriptFinalDigest := (bytes [69, 237, 137, 65, 241, 167, 182, 221, 246, 185, 6, 120, 136, 169, 112, 162, 253, 226, 253, 66, 58, 124, 92, 237, 123, 110, 55, 97, 233, 36, 145, 157]), digest := (bytes [32, 37, 230, 188, 130, 218, 210, 109, 144, 81, 214, 2, 151, 77, 112, 33, 94, 87, 253, 121, 56, 213, 232, 204, 147, 100, 174, 178, 219, 78, 42, 111]) }
  , digest := (bytes [22, 29, 209, 244, 210, 182, 221, 183, 197, 226, 200, 198, 228, 223, 225, 85, 19, 196, 53, 157, 101, 51, 86, 200, 79, 182, 5, 148, 166, 248, 110, 145])
}
  , jointOpening := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { proofStatementDigest := (bytes [103, 27, 39, 162, 68, 137, 185, 117, 237, 254, 70, 203, 99, 51, 244, 146, 116, 162, 208, 115, 237, 31, 185, 139, 65, 255, 181, 53, 167, 1, 247, 23]), mainLaneClaimDigest := (bytes [116, 229, 1, 90, 33, 105, 78, 240, 231, 197, 6, 54, 128, 65, 5, 209, 126, 158, 75, 89, 40, 196, 52, 151, 252, 177, 249, 142, 91, 114, 51, 180]), kernelOpeningClaimDigest := (bytes [22, 29, 209, 244, 210, 182, 221, 183, 197, 226, 200, 198, 228, 223, 225, 85, 19, 196, 53, 157, 101, 51, 86, 200, 79, 182, 5, 148, 166, 248, 110, 145]), digest := (bytes [228, 241, 46, 199, 177, 233, 88, 141, 156, 72, 99, 145, 22, 195, 59, 193, 204, 203, 103, 151, 149, 140, 132, 5, 228, 114, 147, 107, 162, 47, 222, 254]) }, digest := (bytes [93, 233, 113, 154, 224, 142, 14, 43, 40, 191, 69, 234, 127, 122, 226, 201, 101, 106, 0, 188, 248, 143, 81, 192, 255, 220, 40, 185, 224, 68, 226, 84]) }
  , root0 := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), stages := { stage1Digest := (bytes [13, 9, 218, 115, 204, 43, 4, 113, 32, 177, 132, 132, 182, 134, 250, 82, 89, 188, 40, 248, 201, 130, 127, 49, 3, 60, 79, 175, 212, 151, 219, 255]), stage2Digest := (bytes [15, 204, 89, 37, 7, 113, 30, 46, 152, 189, 215, 255, 96, 129, 30, 176, 43, 248, 43, 100, 180, 85, 5, 151, 15, 168, 47, 45, 165, 34, 74, 203]), stage3Digest := (bytes [13, 62, 18, 231, 159, 216, 74, 146, 123, 100, 48, 154, 55, 62, 243, 77, 247, 72, 183, 146, 55, 128, 226, 205, 79, 61, 249, 159, 174, 184, 114, 0]), digest := (bytes [34, 196, 200, 127, 190, 74, 47, 130, 0, 114, 189, 61, 248, 201, 17, 151, 84, 84, 104, 50, 155, 245, 157, 49, 123, 36, 138, 16, 249, 216, 3, 250]) }, terminal := { root0Digest := (bytes [243, 113, 232, 88, 106, 85, 125, 126, 75, 211, 202, 21, 77, 236, 178, 254, 109, 98, 100, 162, 148, 107, 115, 169, 238, 169, 84, 21, 113, 145, 196, 77]), executionDigest := (bytes [28, 1, 84, 184, 89, 242, 14, 108, 33, 243, 25, 226, 156, 89, 231, 121, 72, 112, 15, 25, 78, 90, 217, 60, 9, 73, 78, 4, 175, 30, 106, 21]), finalStateDigest := (bytes [235, 168, 117, 145, 21, 252, 85, 198, 113, 178, 38, 202, 134, 138, 105, 213, 57, 49, 5, 39, 70, 58, 244, 201, 34, 144, 14, 16, 184, 169, 197, 30]), transcriptFinalDigest := (bytes [69, 237, 137, 65, 241, 167, 182, 221, 246, 185, 6, 120, 136, 169, 112, 162, 253, 226, 253, 66, 58, 124, 92, 237, 123, 110, 55, 97, 233, 36, 145, 157]), digest := (bytes [171, 25, 162, 165, 145, 165, 218, 83, 83, 208, 137, 146, 115, 76, 12, 211, 102, 149, 76, 132, 211, 242, 68, 5, 6, 36, 102, 49, 24, 238, 12, 54]) }, digest := (bytes [22, 243, 3, 149, 169, 115, 221, 233, 107, 211, 8, 4, 94, 156, 221, 140, 23, 50, 183, 187, 0, 174, 49, 222, 109, 144, 232, 247, 57, 9, 149, 107]) }
  , digest := (bytes [22, 183, 114, 147, 104, 112, 253, 104, 155, 158, 51, 14, 96, 43, 142, 46, 78, 6, 6, 147, 134, 38, 247, 66, 175, 132, 253, 122, 47, 43, 35, 165])
}
  , statement := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , foldSchedule := Nightstream.FoldSchedule.wholeTrace
  , chunkCount := 1
  , stageClaimsDigest := (bytes [35, 77, 86, 75, 86, 182, 236, 197, 64, 43, 180, 51, 61, 219, 114, 231, 99, 113, 179, 232, 208, 116, 200, 50, 118, 6, 170, 254, 149, 8, 27, 233])
  , stagePackagesDigest := (bytes [52, 190, 239, 220, 236, 238, 67, 70, 23, 4, 94, 122, 14, 113, 70, 190, 94, 82, 149, 196, 47, 72, 72, 234, 109, 24, 115, 178, 82, 113, 170, 111])
  , kernelOpeningDigest := (bytes [246, 239, 58, 153, 3, 236, 85, 36, 188, 10, 50, 193, 184, 94, 232, 222, 167, 119, 0, 179, 144, 23, 134, 108, 183, 203, 105, 27, 190, 107, 130, 138])
  , preparedStepBindingsDigest := (bytes [112, 197, 82, 217, 71, 142, 123, 243, 160, 171, 19, 245, 183, 154, 255, 69, 152, 22, 80, 238, 217, 143, 85, 100, 93, 29, 74, 46, 45, 249, 112, 40])
  , executionDigest := (bytes [28, 1, 84, 184, 89, 242, 14, 108, 33, 243, 25, 226, 156, 89, 231, 121, 72, 112, 15, 25, 78, 90, 217, 60, 9, 73, 78, 4, 175, 30, 106, 21])
  , finalStateDigest := (bytes [235, 168, 117, 145, 21, 252, 85, 198, 113, 178, 38, 202, 134, 138, 105, 213, 57, 49, 5, 39, 70, 58, 244, 201, 34, 144, 14, 16, 184, 169, 197, 30])
  , transcriptFinalDigest := (bytes [69, 237, 137, 65, 241, 167, 182, 221, 246, 185, 6, 120, 136, 169, 112, 162, 253, 226, 253, 66, 58, 124, 92, 237, 123, 110, 55, 97, 233, 36, 145, 157])
  , mainLaneSurfaceDigest := (bytes [219, 202, 214, 12, 57, 57, 21, 80, 239, 95, 243, 30, 57, 13, 3, 245, 84, 95, 19, 196, 232, 147, 144, 50, 28, 153, 16, 248, 73, 249, 169, 50])
  , rootLaneColumnsDigest := (bytes [185, 24, 211, 142, 31, 112, 65, 51, 253, 112, 60, 223, 123, 82, 147, 127, 254, 126, 62, 18, 64, 21, 206, 117, 19, 200, 13, 224, 237, 197, 69, 170])
  , publicStepCount := 7
  , initialPc := 0
  , finalPc := 28
  , halted := true
  , digest := (bytes [103, 27, 39, 162, 68, 137, 185, 117, 237, 254, 70, 203, 99, 51, 244, 146, 116, 162, 208, 115, 237, 31, 185, 139, 65, 255, 181, 53, 167, 1, 247, 23])
}
  , kernel := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "native_sub_lui_auipc_fence_ecall", fixtureId := "native_sub_lui_auipc_fence_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , executionDigest := (bytes [28, 1, 84, 184, 89, 242, 14, 108, 33, 243, 25, 226, 156, 89, 231, 121, 72, 112, 15, 25, 78, 90, 217, 60, 9, 73, 78, 4, 175, 30, 106, 21])
  , shape := { executionRowCount := 7, realRowCount := 7, effectRowCount := 7, commitRowCount := 7, digest := (bytes [36, 118, 223, 124, 248, 115, 52, 199, 198, 250, 25, 33, 218, 131, 247, 174, 126, 69, 105, 226, 74, 199, 244, 245, 142, 55, 128, 143, 190, 129, 55, 117]) }
  , digest := (bytes [25, 177, 8, 78, 250, 64, 121, 27, 95, 130, 19, 187, 172, 206, 182, 113, 40, 6, 86, 61, 186, 140, 176, 73, 167, 183, 185, 149, 17, 51, 159, 234])
}
  , stages := { summary := { stage1RowCount := 7, stage2RegisterReadCount := 4, stage2RegisterWriteCount := 5, stage2RamEventCount := 0, stage2TwistLinkCount := 7, stage3ContinuityCount := 7, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [46, 60, 80, 68, 232, 175, 7, 254, 34, 84, 66, 191, 186, 46, 55, 77, 247, 135, 191, 47, 61, 137, 117, 18, 238, 18, 212, 9, 122, 9, 11, 114]) }, digest := (bytes [107, 50, 114, 67, 253, 159, 78, 201, 18, 88, 90, 164, 67, 99, 228, 158, 81, 35, 118, 111, 232, 74, 74, 246, 34, 208, 132, 50, 143, 226, 36, 231]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [223, 225, 90, 207, 134, 93, 119, 56, 41, 5, 124, 209, 164, 29, 171, 3, 36, 243, 143, 44, 178, 63, 24, 247, 108, 3, 98, 54, 90, 32, 232, 16]), stage1Digest := (bytes [64, 84, 229, 244, 202, 62, 104, 54, 50, 187, 250, 129, 94, 180, 4, 55, 226, 242, 74, 117, 54, 226, 62, 122, 109, 26, 132, 182, 138, 51, 16, 221]), stage2Digest := (bytes [65, 117, 94, 226, 199, 99, 0, 115, 210, 41, 234, 106, 155, 98, 21, 72, 184, 238, 222, 173, 90, 126, 128, 56, 218, 130, 176, 5, 142, 88, 136, 50]), stage3Digest := (bytes [191, 231, 148, 196, 231, 32, 230, 244, 246, 105, 83, 164, 118, 60, 102, 72, 67, 56, 200, 185, 75, 228, 213, 186, 94, 157, 206, 182, 221, 166, 14, 83]), transcriptDigest := (bytes [69, 237, 137, 65, 241, 167, 182, 221, 246, 185, 6, 120, 136, 169, 112, 162, 253, 226, 253, 66, 58, 124, 92, 237, 123, 110, 55, 97, 233, 36, 145, 157]), executionDigest := (bytes [28, 1, 84, 184, 89, 242, 14, 108, 33, 243, 25, 226, 156, 89, 231, 121, 72, 112, 15, 25, 78, 90, 217, 60, 9, 73, 78, 4, 175, 30, 106, 21]), digest := (bytes [174, 196, 6, 102, 3, 97, 153, 82, 217, 147, 83, 12, 127, 248, 114, 137, 116, 13, 71, 169, 60, 34, 41, 230, 245, 231, 92, 165, 215, 114, 152, 172]) }, statementDigest := (bytes [31, 95, 156, 162, 153, 195, 123, 136, 98, 121, 229, 184, 10, 204, 86, 75, 7, 85, 128, 8, 150, 213, 17, 224, 198, 175, 204, 241, 34, 152, 24, 75]), proofDigest := (bytes [30, 212, 61, 182, 78, 252, 131, 84, 85, 152, 38, 107, 137, 117, 116, 183, 123, 3, 175, 228, 117, 241, 83, 228, 61, 57, 13, 48, 219, 236, 252, 76]), digest := (bytes [35, 77, 86, 75, 86, 182, 236, 197, 64, 43, 180, 51, 61, 219, 114, 231, 99, 113, 179, 232, 208, 116, 200, 50, 118, 6, 170, 254, 149, 8, 27, 233]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [150, 142, 19, 32, 35, 228, 183, 42, 168, 254, 224, 21, 201, 251, 104, 107, 156, 210, 162, 210, 187, 213, 91, 41, 34, 90, 7, 179, 143, 206, 21, 186]), stage1Digest := (bytes [207, 40, 159, 62, 60, 5, 240, 79, 61, 235, 232, 64, 80, 50, 15, 50, 1, 147, 76, 6, 172, 104, 25, 175, 15, 199, 167, 51, 8, 68, 177, 92]), stage2Digest := (bytes [91, 238, 67, 192, 173, 230, 176, 69, 21, 217, 100, 79, 117, 10, 31, 183, 249, 182, 54, 243, 26, 41, 183, 69, 215, 140, 117, 247, 219, 146, 110, 164]), stage3Digest := (bytes [92, 247, 26, 104, 3, 68, 55, 71, 237, 45, 12, 153, 238, 197, 30, 23, 0, 5, 192, 200, 156, 49, 112, 225, 23, 23, 16, 191, 254, 164, 5, 217]), digest := (bytes [45, 137, 221, 116, 85, 65, 64, 58, 3, 92, 186, 197, 200, 201, 88, 159, 156, 55, 243, 123, 126, 142, 209, 206, 137, 22, 188, 125, 173, 17, 168, 248]) }, digest := (bytes [52, 190, 239, 220, 236, 238, 67, 70, 23, 4, 94, 122, 14, 113, 70, 190, 94, 82, 149, 196, 47, 72, 72, 234, 109, 24, 115, 178, 82, 113, 170, 111]) }
  , kernelOpening := { openingDigest := (bytes [153, 66, 190, 187, 35, 36, 86, 58, 136, 141, 131, 132, 103, 148, 218, 91, 83, 111, 51, 179, 149, 216, 145, 116, 212, 56, 181, 212, 15, 0, 155, 76]), bindings := { claimDigest := (bytes [99, 34, 151, 196, 202, 146, 254, 239, 47, 204, 153, 51, 30, 203, 74, 164, 234, 127, 173, 202, 32, 168, 7, 101, 17, 82, 80, 237, 198, 225, 67, 175]), bindingsDigest := (bytes [129, 138, 174, 5, 255, 253, 129, 183, 216, 28, 225, 116, 153, 198, 179, 189, 89, 132, 75, 243, 54, 209, 212, 217, 115, 5, 232, 185, 102, 184, 181, 133]), preparedStepsDigest := (bytes [104, 161, 237, 106, 213, 86, 56, 187, 59, 171, 30, 146, 84, 245, 188, 145, 56, 189, 98, 238, 160, 119, 225, 127, 204, 183, 83, 71, 147, 126, 93, 83]), digest := (bytes [225, 152, 64, 173, 123, 31, 30, 7, 76, 87, 58, 3, 100, 205, 188, 77, 218, 237, 125, 142, 149, 116, 201, 247, 223, 107, 149, 135, 20, 139, 187, 149]) }, digest := (bytes [246, 239, 58, 153, 3, 236, 85, 36, 188, 10, 50, 193, 184, 94, 232, 222, 167, 119, 0, 179, 144, 23, 134, 108, 183, 203, 105, 27, 190, 107, 130, 138]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [112, 197, 82, 217, 71, 142, 123, 243, 160, 171, 19, 245, 183, 154, 255, 69, 152, 22, 80, 238, 217, 143, 85, 100, 93, 29, 74, 46, 45, 249, 112, 40]), terminal := { root0Digest := (bytes [243, 113, 232, 88, 106, 85, 125, 126, 75, 211, 202, 21, 77, 236, 178, 254, 109, 98, 100, 162, 148, 107, 115, 169, 238, 169, 84, 21, 113, 145, 196, 77]), executionDigest := (bytes [28, 1, 84, 184, 89, 242, 14, 108, 33, 243, 25, 226, 156, 89, 231, 121, 72, 112, 15, 25, 78, 90, 217, 60, 9, 73, 78, 4, 175, 30, 106, 21]), finalStateDigest := (bytes [235, 168, 117, 145, 21, 252, 85, 198, 113, 178, 38, 202, 134, 138, 105, 213, 57, 49, 5, 39, 70, 58, 244, 201, 34, 144, 14, 16, 184, 169, 197, 30]), transcriptFinalDigest := (bytes [69, 237, 137, 65, 241, 167, 182, 221, 246, 185, 6, 120, 136, 169, 112, 162, 253, 226, 253, 66, 58, 124, 92, 237, 123, 110, 55, 97, 233, 36, 145, 157]), finalPc := 28, halted := true, digest := (bytes [119, 214, 190, 186, 54, 197, 166, 242, 37, 110, 67, 95, 104, 49, 84, 197, 11, 83, 73, 168, 49, 213, 3, 148, 216, 177, 112, 193, 85, 101, 120, 22]) }, digest := (bytes [30, 239, 83, 8, 170, 59, 238, 195, 251, 232, 77, 197, 205, 161, 118, 240, 151, 151, 80, 11, 214, 160, 121, 14, 159, 146, 1, 108, 61, 229, 194, 118]) }, statementDigest := (bytes [124, 156, 154, 171, 189, 248, 70, 22, 31, 55, 1, 96, 178, 184, 228, 119, 125, 97, 30, 225, 108, 109, 3, 93, 188, 57, 156, 200, 229, 206, 48, 58]), proofDigest := (bytes [115, 29, 228, 63, 183, 24, 43, 189, 218, 32, 158, 46, 7, 216, 139, 236, 26, 44, 25, 35, 76, 238, 116, 238, 83, 169, 201, 249, 201, 28, 148, 146]), digest := (bytes [145, 67, 229, 156, 229, 109, 195, 165, 193, 66, 157, 156, 180, 30, 108, 89, 13, 97, 239, 246, 100, 51, 14, 208, 99, 183, 178, 39, 210, 153, 105, 113]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [6, 23, 36, 33, 23, 226, 157, 251, 165, 190, 255, 219, 249, 58, 34, 233, 160, 194, 223, 125, 31, 225, 196, 138, 224, 6, 179, 93, 109, 39, 25, 113]), layoutVersion := 1, digest := (bytes [215, 208, 213, 36, 98, 12, 42, 132, 158, 68, 40, 9, 236, 133, 239, 185, 198, 81, 232, 6, 93, 27, 137, 38, 86, 217, 165, 249, 122, 174, 131, 168]) }, rowWidth := 38, timeLen := 7, columnDigests := [(bytes [40, 243, 169, 246, 170, 121, 143, 48, 132, 183, 68, 213, 151, 130, 14, 65, 20, 212, 138, 236, 77, 112, 226, 150, 158, 109, 142, 75, 172, 115, 156, 234]), (bytes [183, 255, 181, 34, 203, 1, 222, 219, 152, 86, 144, 13, 74, 163, 20, 134, 40, 184, 20, 201, 107, 98, 76, 0, 125, 194, 18, 176, 16, 226, 102, 175]), (bytes [153, 111, 70, 176, 156, 174, 226, 182, 197, 190, 144, 153, 100, 226, 206, 209, 132, 162, 24, 222, 166, 233, 132, 102, 120, 151, 149, 92, 177, 154, 105, 134]), (bytes [188, 23, 179, 202, 216, 119, 253, 192, 107, 56, 140, 18, 247, 51, 234, 39, 235, 216, 134, 241, 7, 60, 104, 146, 182, 166, 45, 236, 214, 213, 211, 83]), (bytes [78, 156, 218, 132, 187, 128, 28, 175, 180, 45, 97, 45, 52, 94, 142, 189, 238, 235, 64, 164, 28, 129, 72, 154, 162, 227, 67, 115, 203, 223, 178, 142]), (bytes [247, 84, 178, 204, 90, 180, 61, 115, 170, 41, 175, 56, 192, 166, 216, 206, 90, 250, 210, 11, 223, 56, 140, 159, 30, 177, 31, 157, 136, 117, 20, 121]), (bytes [50, 117, 247, 44, 135, 251, 33, 130, 187, 149, 173, 15, 157, 44, 184, 232, 74, 29, 121, 15, 49, 15, 1, 170, 4, 57, 254, 21, 66, 20, 255, 57]), (bytes [42, 144, 74, 161, 221, 59, 4, 10, 214, 228, 39, 229, 69, 243, 213, 91, 38, 245, 79, 115, 75, 9, 211, 87, 113, 158, 116, 122, 108, 167, 109, 114]), (bytes [179, 197, 166, 238, 247, 39, 161, 56, 86, 33, 181, 194, 233, 28, 80, 101, 156, 182, 133, 82, 176, 76, 183, 86, 85, 15, 113, 247, 11, 149, 206, 77]), (bytes [133, 160, 199, 189, 7, 112, 198, 246, 237, 84, 81, 147, 189, 17, 217, 241, 202, 249, 239, 243, 169, 101, 30, 246, 218, 32, 171, 254, 107, 102, 128, 154]), (bytes [63, 200, 130, 136, 30, 171, 131, 98, 252, 188, 139, 234, 231, 103, 43, 28, 103, 10, 4, 88, 242, 189, 178, 158, 238, 119, 30, 71, 137, 61, 186, 18]), (bytes [126, 86, 142, 26, 182, 125, 203, 210, 164, 8, 133, 114, 56, 130, 212, 35, 222, 149, 156, 50, 191, 58, 183, 101, 106, 74, 112, 221, 102, 51, 206, 34]), (bytes [18, 172, 128, 176, 253, 198, 4, 93, 34, 80, 94, 154, 166, 81, 235, 21, 208, 214, 240, 19, 132, 26, 227, 255, 47, 232, 138, 242, 49, 178, 152, 151]), (bytes [123, 115, 37, 51, 88, 50, 51, 84, 5, 102, 248, 34, 238, 90, 209, 104, 209, 182, 98, 112, 16, 243, 38, 61, 147, 240, 83, 109, 196, 231, 107, 44]), (bytes [125, 139, 255, 63, 66, 75, 217, 97, 3, 18, 128, 169, 165, 111, 145, 8, 118, 207, 26, 139, 239, 101, 9, 150, 41, 34, 162, 59, 254, 252, 55, 58]), (bytes [44, 32, 216, 93, 16, 146, 0, 130, 207, 204, 36, 141, 166, 246, 232, 20, 247, 247, 116, 89, 62, 217, 122, 245, 142, 15, 143, 44, 219, 131, 183, 12]), (bytes [63, 55, 148, 202, 193, 201, 88, 153, 244, 174, 145, 10, 157, 92, 137, 79, 24, 240, 86, 214, 120, 193, 105, 254, 83, 207, 7, 36, 175, 251, 198, 209]), (bytes [49, 184, 142, 166, 178, 93, 15, 133, 19, 3, 245, 149, 190, 250, 17, 77, 195, 143, 141, 153, 122, 25, 168, 96, 127, 182, 178, 210, 211, 3, 144, 60]), (bytes [86, 196, 110, 116, 66, 242, 23, 243, 102, 32, 103, 253, 30, 136, 67, 166, 214, 221, 241, 169, 190, 115, 51, 189, 2, 90, 50, 65, 2, 198, 240, 74]), (bytes [204, 170, 135, 24, 120, 2, 130, 166, 238, 140, 237, 167, 80, 81, 222, 98, 53, 76, 178, 231, 84, 4, 44, 222, 24, 14, 1, 161, 175, 62, 34, 83]), (bytes [254, 19, 232, 192, 11, 39, 102, 229, 212, 95, 179, 72, 76, 113, 31, 113, 119, 17, 192, 125, 69, 105, 89, 144, 235, 22, 196, 55, 37, 148, 98, 206]), (bytes [126, 178, 122, 220, 67, 252, 127, 71, 82, 225, 133, 219, 37, 32, 10, 78, 133, 40, 227, 107, 52, 114, 163, 131, 123, 127, 232, 227, 171, 62, 101, 156]), (bytes [150, 56, 15, 19, 5, 104, 56, 230, 209, 159, 201, 154, 59, 102, 109, 165, 137, 182, 61, 198, 151, 229, 213, 14, 110, 234, 163, 84, 29, 98, 8, 176]), (bytes [200, 56, 51, 134, 173, 219, 218, 153, 14, 48, 181, 178, 53, 188, 122, 219, 157, 116, 70, 125, 225, 15, 34, 230, 227, 66, 217, 29, 84, 102, 182, 253]), (bytes [210, 70, 3, 57, 245, 131, 122, 183, 202, 155, 172, 21, 75, 121, 43, 183, 199, 58, 106, 240, 174, 143, 12, 118, 52, 65, 199, 50, 16, 143, 205, 192]), (bytes [179, 48, 0, 250, 27, 221, 177, 148, 93, 180, 91, 49, 228, 54, 116, 100, 128, 40, 176, 25, 157, 98, 83, 138, 39, 246, 67, 217, 82, 69, 86, 192]), (bytes [230, 233, 51, 142, 175, 227, 185, 68, 193, 102, 205, 229, 70, 211, 83, 226, 20, 174, 185, 68, 145, 102, 56, 1, 187, 15, 129, 252, 242, 17, 12, 153]), (bytes [115, 221, 25, 201, 235, 175, 57, 9, 159, 237, 1, 99, 122, 176, 133, 105, 76, 191, 15, 198, 154, 87, 195, 119, 27, 252, 234, 251, 191, 97, 36, 22]), (bytes [159, 136, 79, 19, 3, 64, 16, 130, 170, 158, 169, 178, 191, 146, 174, 198, 91, 233, 1, 17, 175, 210, 201, 9, 131, 122, 214, 44, 60, 157, 185, 73]), (bytes [83, 251, 49, 48, 54, 174, 206, 33, 38, 55, 53, 86, 238, 134, 67, 140, 194, 44, 73, 155, 93, 189, 217, 191, 38, 87, 214, 184, 137, 68, 230, 167]), (bytes [240, 212, 182, 90, 28, 28, 194, 255, 94, 159, 35, 103, 91, 242, 214, 20, 102, 217, 67, 85, 43, 252, 11, 32, 160, 11, 241, 164, 190, 14, 75, 153]), (bytes [83, 203, 23, 43, 120, 2, 138, 179, 201, 101, 117, 199, 249, 119, 150, 189, 107, 206, 100, 240, 241, 191, 29, 12, 95, 189, 46, 162, 173, 67, 52, 64]), (bytes [243, 18, 112, 16, 115, 206, 161, 217, 70, 120, 53, 168, 21, 217, 125, 177, 15, 184, 39, 220, 129, 252, 253, 217, 143, 169, 231, 204, 197, 173, 74, 44]), (bytes [174, 205, 154, 64, 243, 198, 70, 67, 132, 170, 211, 195, 186, 11, 96, 55, 55, 6, 248, 130, 169, 186, 214, 86, 104, 198, 34, 111, 234, 42, 133, 117]), (bytes [181, 205, 4, 135, 126, 61, 165, 192, 182, 157, 219, 25, 61, 190, 241, 123, 199, 165, 114, 116, 128, 144, 237, 80, 99, 219, 70, 24, 44, 75, 141, 99]), (bytes [64, 184, 77, 60, 124, 164, 54, 93, 23, 121, 89, 235, 81, 60, 107, 51, 86, 73, 18, 40, 80, 16, 45, 151, 39, 61, 175, 64, 40, 48, 21, 239]), (bytes [233, 150, 233, 24, 120, 142, 81, 204, 197, 94, 9, 71, 112, 24, 112, 173, 149, 24, 63, 117, 95, 104, 238, 197, 31, 101, 173, 98, 112, 244, 218, 130]), (bytes [145, 99, 191, 35, 121, 90, 118, 57, 187, 82, 200, 99, 201, 117, 132, 16, 109, 95, 126, 62, 89, 129, 183, 210, 46, 8, 148, 208, 73, 204, 191, 238])], familyDigest := (bytes [6, 23, 36, 33, 23, 226, 157, 251, 165, 190, 255, 219, 249, 58, 34, 233, 160, 194, 223, 125, 31, 225, 196, 138, 224, 6, 179, 93, 109, 39, 25, 113]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [6, 23, 36, 33, 23, 226, 157, 251, 165, 190, 255, 219, 249, 58, 34, 233, 160, 194, 223, 125, 31, 225, 196, 138, 224, 6, 179, 93, 109, 39, 25, 113]), layoutVersion := 1, digest := (bytes [215, 208, 213, 36, 98, 12, 42, 132, 158, 68, 40, 9, 236, 133, 239, 185, 198, 81, 232, 6, 93, 27, 137, 38, 86, 217, 165, 249, 122, 174, 131, 168]) }, logicalIndex := 0, digest := (bytes [108, 77, 206, 195, 120, 223, 83, 3, 248, 79, 145, 30, 138, 29, 114, 42, 133, 197, 137, 83, 200, 226, 104, 75, 191, 200, 247, 248, 184, 27, 238, 62]) }, valueDigest := (bytes [49, 112, 41, 120, 103, 26, 24, 17, 240, 51, 88, 180, 158, 199, 42, 251, 183, 57, 20, 149, 1, 43, 127, 249, 47, 108, 100, 231, 221, 153, 232, 90]), digest := (bytes [17, 207, 121, 237, 159, 155, 36, 164, 116, 95, 128, 75, 120, 77, 118, 119, 80, 17, 73, 60, 22, 80, 44, 110, 232, 41, 145, 233, 164, 251, 92, 238]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [6, 23, 36, 33, 23, 226, 157, 251, 165, 190, 255, 219, 249, 58, 34, 233, 160, 194, 223, 125, 31, 225, 196, 138, 224, 6, 179, 93, 109, 39, 25, 113]), layoutVersion := 1, digest := (bytes [215, 208, 213, 36, 98, 12, 42, 132, 158, 68, 40, 9, 236, 133, 239, 185, 198, 81, 232, 6, 93, 27, 137, 38, 86, 217, 165, 249, 122, 174, 131, 168]) }, logicalIndex := 6, digest := (bytes [216, 72, 40, 191, 64, 74, 101, 211, 203, 238, 142, 231, 112, 78, 0, 138, 144, 122, 184, 130, 143, 193, 200, 114, 121, 8, 231, 201, 217, 200, 170, 128]) }, valueDigest := (bytes [57, 167, 127, 66, 29, 28, 1, 62, 111, 174, 45, 82, 212, 157, 25, 154, 254, 72, 204, 85, 223, 7, 138, 44, 48, 11, 222, 83, 122, 239, 183, 120]), digest := (bytes [66, 120, 177, 28, 12, 51, 17, 88, 29, 137, 234, 40, 93, 97, 58, 32, 240, 194, 5, 198, 91, 176, 154, 39, 164, 136, 135, 32, 86, 196, 137, 83]) }), digest := (bytes [185, 24, 211, 142, 31, 112, 65, 51, 253, 112, 60, 223, 123, 82, 147, 127, 254, 126, 62, 18, 64, 21, 206, 117, 19, 200, 13, 224, 237, 197, 69, 170]) }
  , rootLaneCommitment := { timeLen := 7, commitments := { commitmentCount := 38, digest := (bytes [188, 12, 95, 85, 66, 33, 99, 49, 226, 20, 83, 140, 184, 203, 2, 197, 58, 72, 27, 185, 133, 183, 5, 214, 56, 240, 203, 134, 116, 9, 141, 194]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [188, 12, 95, 85, 66, 33, 99, 49, 226, 20, 83, 140, 184, 203, 2, 197, 58, 72, 27, 185, 133, 183, 5, 214, 56, 240, 203, 134, 116, 9, 141, 194]), layoutVersion := 3, digest := (bytes [93, 165, 209, 153, 58, 191, 53, 125, 149, 135, 164, 81, 108, 190, 175, 75, 191, 102, 98, 247, 125, 159, 208, 119, 229, 244, 240, 202, 143, 114, 108, 202]) }, logicalIndex := 0, digest := (bytes [129, 215, 43, 59, 203, 39, 35, 65, 215, 34, 107, 74, 102, 41, 143, 193, 105, 59, 216, 89, 191, 88, 229, 192, 27, 145, 190, 119, 196, 193, 146, 86]) }, valueDigest := (bytes [49, 112, 41, 120, 103, 26, 24, 17, 240, 51, 88, 180, 158, 199, 42, 251, 183, 57, 20, 149, 1, 43, 127, 249, 47, 108, 100, 231, 221, 153, 232, 90]), digest := (bytes [34, 109, 239, 78, 212, 125, 84, 109, 35, 231, 9, 110, 158, 166, 139, 211, 73, 48, 227, 193, 83, 46, 47, 210, 163, 190, 147, 240, 188, 142, 74, 13]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [188, 12, 95, 85, 66, 33, 99, 49, 226, 20, 83, 140, 184, 203, 2, 197, 58, 72, 27, 185, 133, 183, 5, 214, 56, 240, 203, 134, 116, 9, 141, 194]), layoutVersion := 3, digest := (bytes [93, 165, 209, 153, 58, 191, 53, 125, 149, 135, 164, 81, 108, 190, 175, 75, 191, 102, 98, 247, 125, 159, 208, 119, 229, 244, 240, 202, 143, 114, 108, 202]) }, logicalIndex := 6, digest := (bytes [27, 222, 251, 202, 155, 65, 36, 46, 105, 119, 166, 124, 124, 92, 5, 11, 163, 81, 33, 98, 148, 207, 51, 68, 71, 88, 69, 250, 107, 132, 2, 115]) }, valueDigest := (bytes [57, 167, 127, 66, 29, 28, 1, 62, 111, 174, 45, 82, 212, 157, 25, 154, 254, 72, 204, 85, 223, 7, 138, 44, 48, 11, 222, 83, 122, 239, 183, 120]), digest := (bytes [239, 144, 64, 133, 16, 33, 187, 192, 199, 171, 231, 186, 85, 250, 190, 54, 136, 147, 57, 153, 203, 201, 166, 165, 80, 159, 29, 7, 34, 242, 144, 125]) }), digest := (bytes [154, 54, 137, 236, 75, 115, 116, 110, 148, 80, 210, 34, 52, 240, 128, 94, 154, 75, 213, 221, 154, 160, 95, 236, 179, 252, 242, 20, 68, 216, 117, 243]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [185, 24, 211, 142, 31, 112, 65, 51, 253, 112, 60, 223, 123, 82, 147, 127, 254, 126, 62, 18, 64, 21, 206, 117, 19, 200, 13, 224, 237, 197, 69, 170]), rootLaneCommitmentDigest := (bytes [154, 54, 137, 236, 75, 115, 116, 110, 148, 80, 210, 34, 52, 240, 128, 94, 154, 75, 213, 221, 154, 160, 95, 236, 179, 252, 242, 20, 68, 216, 117, 243]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 7, digest := (bytes [206, 159, 213, 58, 149, 250, 197, 229, 63, 141, 122, 233, 11, 38, 60, 217, 215, 34, 60, 17, 141, 154, 200, 71, 6, 104, 67, 107, 105, 225, 247, 114]) }, statementDigest := (bytes [149, 99, 152, 248, 29, 72, 150, 108, 49, 205, 156, 74, 10, 12, 136, 78, 8, 240, 221, 63, 39, 142, 87, 120, 12, 133, 254, 176, 161, 154, 58, 228]), proofDigest := (bytes [142, 4, 17, 150, 223, 130, 123, 216, 10, 91, 235, 126, 9, 148, 131, 195, 18, 211, 37, 62, 45, 2, 94, 114, 112, 56, 49, 30, 29, 144, 252, 207]), digest := (bytes [11, 174, 3, 238, 131, 48, 50, 235, 141, 1, 103, 149, 189, 244, 17, 245, 9, 195, 8, 21, 46, 95, 194, 235, 69, 28, 176, 211, 210, 72, 177, 98]) }
  , digest := (bytes [25, 208, 63, 191, 56, 150, 225, 211, 131, 209, 183, 103, 230, 33, 34, 36, 245, 162, 195, 60, 200, 17, 239, 169, 26, 209, 78, 207, 135, 192, 57, 129])
}
}
    , exportedStatement := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , foldSchedule := Nightstream.FoldSchedule.wholeTrace
  , chunkCount := 1
  , stageClaimsDigest := (bytes [35, 77, 86, 75, 86, 182, 236, 197, 64, 43, 180, 51, 61, 219, 114, 231, 99, 113, 179, 232, 208, 116, 200, 50, 118, 6, 170, 254, 149, 8, 27, 233])
  , stagePackagesDigest := (bytes [52, 190, 239, 220, 236, 238, 67, 70, 23, 4, 94, 122, 14, 113, 70, 190, 94, 82, 149, 196, 47, 72, 72, 234, 109, 24, 115, 178, 82, 113, 170, 111])
  , kernelOpeningDigest := (bytes [246, 239, 58, 153, 3, 236, 85, 36, 188, 10, 50, 193, 184, 94, 232, 222, 167, 119, 0, 179, 144, 23, 134, 108, 183, 203, 105, 27, 190, 107, 130, 138])
  , preparedStepBindingsDigest := (bytes [112, 197, 82, 217, 71, 142, 123, 243, 160, 171, 19, 245, 183, 154, 255, 69, 152, 22, 80, 238, 217, 143, 85, 100, 93, 29, 74, 46, 45, 249, 112, 40])
  , executionDigest := (bytes [28, 1, 84, 184, 89, 242, 14, 108, 33, 243, 25, 226, 156, 89, 231, 121, 72, 112, 15, 25, 78, 90, 217, 60, 9, 73, 78, 4, 175, 30, 106, 21])
  , finalStateDigest := (bytes [235, 168, 117, 145, 21, 252, 85, 198, 113, 178, 38, 202, 134, 138, 105, 213, 57, 49, 5, 39, 70, 58, 244, 201, 34, 144, 14, 16, 184, 169, 197, 30])
  , transcriptFinalDigest := (bytes [69, 237, 137, 65, 241, 167, 182, 221, 246, 185, 6, 120, 136, 169, 112, 162, 253, 226, 253, 66, 58, 124, 92, 237, 123, 110, 55, 97, 233, 36, 145, 157])
  , mainLaneSurfaceDigest := (bytes [219, 202, 214, 12, 57, 57, 21, 80, 239, 95, 243, 30, 57, 13, 3, 245, 84, 95, 19, 196, 232, 147, 144, 50, 28, 153, 16, 248, 73, 249, 169, 50])
  , rootLaneColumnsDigest := (bytes [185, 24, 211, 142, 31, 112, 65, 51, 253, 112, 60, 223, 123, 82, 147, 127, 254, 126, 62, 18, 64, 21, 206, 117, 19, 200, 13, 224, 237, 197, 69, 170])
  , publicStepCount := 7
  , initialPc := 0
  , finalPc := 28
  , halted := true
  , digest := (bytes [103, 27, 39, 162, 68, 137, 185, 117, 237, 254, 70, 203, 99, 51, 244, 146, 116, 162, 208, 115, 237, 31, 185, 139, 65, 255, 181, 53, 167, 1, 247, 23])
}
    , exportedClaims := {
  accepted := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , statement := { proofStatementDigest := (bytes [103, 27, 39, 162, 68, 137, 185, 117, 237, 254, 70, 203, 99, 51, 244, 146, 116, 162, 208, 115, 237, 31, 185, 139, 65, 255, 181, 53, 167, 1, 247, 23]), kernelOpeningDigest := (bytes [246, 239, 58, 153, 3, 236, 85, 36, 188, 10, 50, 193, 184, 94, 232, 222, 167, 119, 0, 179, 144, 23, 134, 108, 183, 203, 105, 27, 190, 107, 130, 138]), digest := (bytes [181, 240, 134, 186, 209, 104, 210, 141, 165, 188, 162, 19, 20, 18, 197, 36, 15, 208, 9, 182, 6, 96, 183, 231, 130, 1, 109, 106, 136, 98, 87, 93]) }
  , mainLane := { mainLaneBundleDigest := (bytes [11, 174, 3, 238, 131, 48, 50, 235, 141, 1, 103, 149, 189, 244, 17, 245, 9, 195, 8, 21, 46, 95, 194, 235, 69, 28, 176, 211, 210, 72, 177, 98]), digest := (bytes [178, 245, 29, 80, 82, 53, 101, 144, 108, 106, 73, 232, 21, 214, 206, 214, 122, 102, 164, 246, 228, 121, 56, 76, 87, 71, 159, 45, 142, 54, 87, 175]) }
  , terminal := { finalStateDigest := (bytes [235, 168, 117, 145, 21, 252, 85, 198, 113, 178, 38, 202, 134, 138, 105, 213, 57, 49, 5, 39, 70, 58, 244, 201, 34, 144, 14, 16, 184, 169, 197, 30]), finalPc := 28, halted := true, digest := (bytes [11, 107, 79, 125, 37, 71, 186, 127, 223, 171, 110, 138, 239, 210, 23, 51, 141, 136, 244, 21, 95, 244, 93, 182, 164, 27, 247, 7, 50, 39, 167, 118]) }
  , digest := (bytes [135, 192, 244, 62, 46, 187, 224, 79, 155, 8, 187, 57, 133, 189, 85, 234, 92, 145, 136, 218, 49, 1, 0, 126, 181, 29, 36, 239, 8, 141, 28, 34])
}
  , mainLane := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { mainLaneBundleDigest := (bytes [11, 174, 3, 238, 131, 48, 50, 235, 141, 1, 103, 149, 189, 244, 17, 245, 9, 195, 8, 21, 46, 95, 194, 235, 69, 28, 176, 211, 210, 72, 177, 98]), digest := (bytes [21, 167, 30, 47, 106, 32, 171, 118, 155, 122, 42, 85, 147, 145, 117, 8, 251, 65, 241, 242, 207, 106, 38, 69, 55, 175, 94, 236, 127, 93, 227, 200]) }, digest := (bytes [116, 229, 1, 90, 33, 105, 78, 240, 231, 197, 6, 54, 128, 65, 5, 209, 126, 158, 75, 89, 40, 196, 52, 151, 252, 177, 249, 142, 91, 114, 51, 180]) }
  , opening := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , stages := { stageClaimsDigest := (bytes [35, 77, 86, 75, 86, 182, 236, 197, 64, 43, 180, 51, 61, 219, 114, 231, 99, 113, 179, 232, 208, 116, 200, 50, 118, 6, 170, 254, 149, 8, 27, 233]), stagePackagesDigest := (bytes [52, 190, 239, 220, 236, 238, 67, 70, 23, 4, 94, 122, 14, 113, 70, 190, 94, 82, 149, 196, 47, 72, 72, 234, 109, 24, 115, 178, 82, 113, 170, 111]), kernelOpeningDigest := (bytes [246, 239, 58, 153, 3, 236, 85, 36, 188, 10, 50, 193, 184, 94, 232, 222, 167, 119, 0, 179, 144, 23, 134, 108, 183, 203, 105, 27, 190, 107, 130, 138]), digest := (bytes [115, 169, 67, 90, 225, 199, 57, 253, 146, 45, 177, 243, 98, 28, 57, 31, 217, 165, 199, 216, 156, 199, 129, 83, 242, 31, 254, 141, 192, 59, 189, 209]) }
  , terminal := { preparedStepBindingsDigest := (bytes [112, 197, 82, 217, 71, 142, 123, 243, 160, 171, 19, 245, 183, 154, 255, 69, 152, 22, 80, 238, 217, 143, 85, 100, 93, 29, 74, 46, 45, 249, 112, 40]), executionDigest := (bytes [28, 1, 84, 184, 89, 242, 14, 108, 33, 243, 25, 226, 156, 89, 231, 121, 72, 112, 15, 25, 78, 90, 217, 60, 9, 73, 78, 4, 175, 30, 106, 21]), transcriptFinalDigest := (bytes [69, 237, 137, 65, 241, 167, 182, 221, 246, 185, 6, 120, 136, 169, 112, 162, 253, 226, 253, 66, 58, 124, 92, 237, 123, 110, 55, 97, 233, 36, 145, 157]), digest := (bytes [32, 37, 230, 188, 130, 218, 210, 109, 144, 81, 214, 2, 151, 77, 112, 33, 94, 87, 253, 121, 56, 213, 232, 204, 147, 100, 174, 178, 219, 78, 42, 111]) }
  , digest := (bytes [22, 29, 209, 244, 210, 182, 221, 183, 197, 226, 200, 198, 228, 223, 225, 85, 19, 196, 53, 157, 101, 51, 86, 200, 79, 182, 5, 148, 166, 248, 110, 145])
}
  , jointOpening := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { proofStatementDigest := (bytes [103, 27, 39, 162, 68, 137, 185, 117, 237, 254, 70, 203, 99, 51, 244, 146, 116, 162, 208, 115, 237, 31, 185, 139, 65, 255, 181, 53, 167, 1, 247, 23]), mainLaneClaimDigest := (bytes [116, 229, 1, 90, 33, 105, 78, 240, 231, 197, 6, 54, 128, 65, 5, 209, 126, 158, 75, 89, 40, 196, 52, 151, 252, 177, 249, 142, 91, 114, 51, 180]), kernelOpeningClaimDigest := (bytes [22, 29, 209, 244, 210, 182, 221, 183, 197, 226, 200, 198, 228, 223, 225, 85, 19, 196, 53, 157, 101, 51, 86, 200, 79, 182, 5, 148, 166, 248, 110, 145]), digest := (bytes [228, 241, 46, 199, 177, 233, 88, 141, 156, 72, 99, 145, 22, 195, 59, 193, 204, 203, 103, 151, 149, 140, 132, 5, 228, 114, 147, 107, 162, 47, 222, 254]) }, digest := (bytes [93, 233, 113, 154, 224, 142, 14, 43, 40, 191, 69, 234, 127, 122, 226, 201, 101, 106, 0, 188, 248, 143, 81, 192, 255, 220, 40, 185, 224, 68, 226, 84]) }
  , root0 := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), stages := { stage1Digest := (bytes [13, 9, 218, 115, 204, 43, 4, 113, 32, 177, 132, 132, 182, 134, 250, 82, 89, 188, 40, 248, 201, 130, 127, 49, 3, 60, 79, 175, 212, 151, 219, 255]), stage2Digest := (bytes [15, 204, 89, 37, 7, 113, 30, 46, 152, 189, 215, 255, 96, 129, 30, 176, 43, 248, 43, 100, 180, 85, 5, 151, 15, 168, 47, 45, 165, 34, 74, 203]), stage3Digest := (bytes [13, 62, 18, 231, 159, 216, 74, 146, 123, 100, 48, 154, 55, 62, 243, 77, 247, 72, 183, 146, 55, 128, 226, 205, 79, 61, 249, 159, 174, 184, 114, 0]), digest := (bytes [34, 196, 200, 127, 190, 74, 47, 130, 0, 114, 189, 61, 248, 201, 17, 151, 84, 84, 104, 50, 155, 245, 157, 49, 123, 36, 138, 16, 249, 216, 3, 250]) }, terminal := { root0Digest := (bytes [243, 113, 232, 88, 106, 85, 125, 126, 75, 211, 202, 21, 77, 236, 178, 254, 109, 98, 100, 162, 148, 107, 115, 169, 238, 169, 84, 21, 113, 145, 196, 77]), executionDigest := (bytes [28, 1, 84, 184, 89, 242, 14, 108, 33, 243, 25, 226, 156, 89, 231, 121, 72, 112, 15, 25, 78, 90, 217, 60, 9, 73, 78, 4, 175, 30, 106, 21]), finalStateDigest := (bytes [235, 168, 117, 145, 21, 252, 85, 198, 113, 178, 38, 202, 134, 138, 105, 213, 57, 49, 5, 39, 70, 58, 244, 201, 34, 144, 14, 16, 184, 169, 197, 30]), transcriptFinalDigest := (bytes [69, 237, 137, 65, 241, 167, 182, 221, 246, 185, 6, 120, 136, 169, 112, 162, 253, 226, 253, 66, 58, 124, 92, 237, 123, 110, 55, 97, 233, 36, 145, 157]), digest := (bytes [171, 25, 162, 165, 145, 165, 218, 83, 83, 208, 137, 146, 115, 76, 12, 211, 102, 149, 76, 132, 211, 242, 68, 5, 6, 36, 102, 49, 24, 238, 12, 54]) }, digest := (bytes [22, 243, 3, 149, 169, 115, 221, 233, 107, 211, 8, 4, 94, 156, 221, 140, 23, 50, 183, 187, 0, 174, 49, 222, 109, 144, 232, 247, 57, 9, 149, 107]) }
  , digest := (bytes [22, 183, 114, 147, 104, 112, 253, 104, 155, 158, 51, 14, 96, 43, 142, 46, 78, 6, 6, 147, 134, 38, 247, 66, 175, 132, 253, 122, 47, 43, 35, 165])
}
    , exportedKernelProof := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "native_sub_lui_auipc_fence_ecall", fixtureId := "native_sub_lui_auipc_fence_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , executionDigest := (bytes [28, 1, 84, 184, 89, 242, 14, 108, 33, 243, 25, 226, 156, 89, 231, 121, 72, 112, 15, 25, 78, 90, 217, 60, 9, 73, 78, 4, 175, 30, 106, 21])
  , shape := { executionRowCount := 7, realRowCount := 7, effectRowCount := 7, commitRowCount := 7, digest := (bytes [36, 118, 223, 124, 248, 115, 52, 199, 198, 250, 25, 33, 218, 131, 247, 174, 126, 69, 105, 226, 74, 199, 244, 245, 142, 55, 128, 143, 190, 129, 55, 117]) }
  , digest := (bytes [25, 177, 8, 78, 250, 64, 121, 27, 95, 130, 19, 187, 172, 206, 182, 113, 40, 6, 86, 61, 186, 140, 176, 73, 167, 183, 185, 149, 17, 51, 159, 234])
}
  , stages := { summary := { stage1RowCount := 7, stage2RegisterReadCount := 4, stage2RegisterWriteCount := 5, stage2RamEventCount := 0, stage2TwistLinkCount := 7, stage3ContinuityCount := 7, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [46, 60, 80, 68, 232, 175, 7, 254, 34, 84, 66, 191, 186, 46, 55, 77, 247, 135, 191, 47, 61, 137, 117, 18, 238, 18, 212, 9, 122, 9, 11, 114]) }, digest := (bytes [107, 50, 114, 67, 253, 159, 78, 201, 18, 88, 90, 164, 67, 99, 228, 158, 81, 35, 118, 111, 232, 74, 74, 246, 34, 208, 132, 50, 143, 226, 36, 231]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [223, 225, 90, 207, 134, 93, 119, 56, 41, 5, 124, 209, 164, 29, 171, 3, 36, 243, 143, 44, 178, 63, 24, 247, 108, 3, 98, 54, 90, 32, 232, 16]), stage1Digest := (bytes [64, 84, 229, 244, 202, 62, 104, 54, 50, 187, 250, 129, 94, 180, 4, 55, 226, 242, 74, 117, 54, 226, 62, 122, 109, 26, 132, 182, 138, 51, 16, 221]), stage2Digest := (bytes [65, 117, 94, 226, 199, 99, 0, 115, 210, 41, 234, 106, 155, 98, 21, 72, 184, 238, 222, 173, 90, 126, 128, 56, 218, 130, 176, 5, 142, 88, 136, 50]), stage3Digest := (bytes [191, 231, 148, 196, 231, 32, 230, 244, 246, 105, 83, 164, 118, 60, 102, 72, 67, 56, 200, 185, 75, 228, 213, 186, 94, 157, 206, 182, 221, 166, 14, 83]), transcriptDigest := (bytes [69, 237, 137, 65, 241, 167, 182, 221, 246, 185, 6, 120, 136, 169, 112, 162, 253, 226, 253, 66, 58, 124, 92, 237, 123, 110, 55, 97, 233, 36, 145, 157]), executionDigest := (bytes [28, 1, 84, 184, 89, 242, 14, 108, 33, 243, 25, 226, 156, 89, 231, 121, 72, 112, 15, 25, 78, 90, 217, 60, 9, 73, 78, 4, 175, 30, 106, 21]), digest := (bytes [174, 196, 6, 102, 3, 97, 153, 82, 217, 147, 83, 12, 127, 248, 114, 137, 116, 13, 71, 169, 60, 34, 41, 230, 245, 231, 92, 165, 215, 114, 152, 172]) }, statementDigest := (bytes [31, 95, 156, 162, 153, 195, 123, 136, 98, 121, 229, 184, 10, 204, 86, 75, 7, 85, 128, 8, 150, 213, 17, 224, 198, 175, 204, 241, 34, 152, 24, 75]), proofDigest := (bytes [30, 212, 61, 182, 78, 252, 131, 84, 85, 152, 38, 107, 137, 117, 116, 183, 123, 3, 175, 228, 117, 241, 83, 228, 61, 57, 13, 48, 219, 236, 252, 76]), digest := (bytes [35, 77, 86, 75, 86, 182, 236, 197, 64, 43, 180, 51, 61, 219, 114, 231, 99, 113, 179, 232, 208, 116, 200, 50, 118, 6, 170, 254, 149, 8, 27, 233]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [150, 142, 19, 32, 35, 228, 183, 42, 168, 254, 224, 21, 201, 251, 104, 107, 156, 210, 162, 210, 187, 213, 91, 41, 34, 90, 7, 179, 143, 206, 21, 186]), stage1Digest := (bytes [207, 40, 159, 62, 60, 5, 240, 79, 61, 235, 232, 64, 80, 50, 15, 50, 1, 147, 76, 6, 172, 104, 25, 175, 15, 199, 167, 51, 8, 68, 177, 92]), stage2Digest := (bytes [91, 238, 67, 192, 173, 230, 176, 69, 21, 217, 100, 79, 117, 10, 31, 183, 249, 182, 54, 243, 26, 41, 183, 69, 215, 140, 117, 247, 219, 146, 110, 164]), stage3Digest := (bytes [92, 247, 26, 104, 3, 68, 55, 71, 237, 45, 12, 153, 238, 197, 30, 23, 0, 5, 192, 200, 156, 49, 112, 225, 23, 23, 16, 191, 254, 164, 5, 217]), digest := (bytes [45, 137, 221, 116, 85, 65, 64, 58, 3, 92, 186, 197, 200, 201, 88, 159, 156, 55, 243, 123, 126, 142, 209, 206, 137, 22, 188, 125, 173, 17, 168, 248]) }, digest := (bytes [52, 190, 239, 220, 236, 238, 67, 70, 23, 4, 94, 122, 14, 113, 70, 190, 94, 82, 149, 196, 47, 72, 72, 234, 109, 24, 115, 178, 82, 113, 170, 111]) }
  , kernelOpening := { openingDigest := (bytes [153, 66, 190, 187, 35, 36, 86, 58, 136, 141, 131, 132, 103, 148, 218, 91, 83, 111, 51, 179, 149, 216, 145, 116, 212, 56, 181, 212, 15, 0, 155, 76]), bindings := { claimDigest := (bytes [99, 34, 151, 196, 202, 146, 254, 239, 47, 204, 153, 51, 30, 203, 74, 164, 234, 127, 173, 202, 32, 168, 7, 101, 17, 82, 80, 237, 198, 225, 67, 175]), bindingsDigest := (bytes [129, 138, 174, 5, 255, 253, 129, 183, 216, 28, 225, 116, 153, 198, 179, 189, 89, 132, 75, 243, 54, 209, 212, 217, 115, 5, 232, 185, 102, 184, 181, 133]), preparedStepsDigest := (bytes [104, 161, 237, 106, 213, 86, 56, 187, 59, 171, 30, 146, 84, 245, 188, 145, 56, 189, 98, 238, 160, 119, 225, 127, 204, 183, 83, 71, 147, 126, 93, 83]), digest := (bytes [225, 152, 64, 173, 123, 31, 30, 7, 76, 87, 58, 3, 100, 205, 188, 77, 218, 237, 125, 142, 149, 116, 201, 247, 223, 107, 149, 135, 20, 139, 187, 149]) }, digest := (bytes [246, 239, 58, 153, 3, 236, 85, 36, 188, 10, 50, 193, 184, 94, 232, 222, 167, 119, 0, 179, 144, 23, 134, 108, 183, 203, 105, 27, 190, 107, 130, 138]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [112, 197, 82, 217, 71, 142, 123, 243, 160, 171, 19, 245, 183, 154, 255, 69, 152, 22, 80, 238, 217, 143, 85, 100, 93, 29, 74, 46, 45, 249, 112, 40]), terminal := { root0Digest := (bytes [243, 113, 232, 88, 106, 85, 125, 126, 75, 211, 202, 21, 77, 236, 178, 254, 109, 98, 100, 162, 148, 107, 115, 169, 238, 169, 84, 21, 113, 145, 196, 77]), executionDigest := (bytes [28, 1, 84, 184, 89, 242, 14, 108, 33, 243, 25, 226, 156, 89, 231, 121, 72, 112, 15, 25, 78, 90, 217, 60, 9, 73, 78, 4, 175, 30, 106, 21]), finalStateDigest := (bytes [235, 168, 117, 145, 21, 252, 85, 198, 113, 178, 38, 202, 134, 138, 105, 213, 57, 49, 5, 39, 70, 58, 244, 201, 34, 144, 14, 16, 184, 169, 197, 30]), transcriptFinalDigest := (bytes [69, 237, 137, 65, 241, 167, 182, 221, 246, 185, 6, 120, 136, 169, 112, 162, 253, 226, 253, 66, 58, 124, 92, 237, 123, 110, 55, 97, 233, 36, 145, 157]), finalPc := 28, halted := true, digest := (bytes [119, 214, 190, 186, 54, 197, 166, 242, 37, 110, 67, 95, 104, 49, 84, 197, 11, 83, 73, 168, 49, 213, 3, 148, 216, 177, 112, 193, 85, 101, 120, 22]) }, digest := (bytes [30, 239, 83, 8, 170, 59, 238, 195, 251, 232, 77, 197, 205, 161, 118, 240, 151, 151, 80, 11, 214, 160, 121, 14, 159, 146, 1, 108, 61, 229, 194, 118]) }, statementDigest := (bytes [124, 156, 154, 171, 189, 248, 70, 22, 31, 55, 1, 96, 178, 184, 228, 119, 125, 97, 30, 225, 108, 109, 3, 93, 188, 57, 156, 200, 229, 206, 48, 58]), proofDigest := (bytes [115, 29, 228, 63, 183, 24, 43, 189, 218, 32, 158, 46, 7, 216, 139, 236, 26, 44, 25, 35, 76, 238, 116, 238, 83, 169, 201, 249, 201, 28, 148, 146]), digest := (bytes [145, 67, 229, 156, 229, 109, 195, 165, 193, 66, 157, 156, 180, 30, 108, 89, 13, 97, 239, 246, 100, 51, 14, 208, 99, 183, 178, 39, 210, 153, 105, 113]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [6, 23, 36, 33, 23, 226, 157, 251, 165, 190, 255, 219, 249, 58, 34, 233, 160, 194, 223, 125, 31, 225, 196, 138, 224, 6, 179, 93, 109, 39, 25, 113]), layoutVersion := 1, digest := (bytes [215, 208, 213, 36, 98, 12, 42, 132, 158, 68, 40, 9, 236, 133, 239, 185, 198, 81, 232, 6, 93, 27, 137, 38, 86, 217, 165, 249, 122, 174, 131, 168]) }, rowWidth := 38, timeLen := 7, columnDigests := [(bytes [40, 243, 169, 246, 170, 121, 143, 48, 132, 183, 68, 213, 151, 130, 14, 65, 20, 212, 138, 236, 77, 112, 226, 150, 158, 109, 142, 75, 172, 115, 156, 234]), (bytes [183, 255, 181, 34, 203, 1, 222, 219, 152, 86, 144, 13, 74, 163, 20, 134, 40, 184, 20, 201, 107, 98, 76, 0, 125, 194, 18, 176, 16, 226, 102, 175]), (bytes [153, 111, 70, 176, 156, 174, 226, 182, 197, 190, 144, 153, 100, 226, 206, 209, 132, 162, 24, 222, 166, 233, 132, 102, 120, 151, 149, 92, 177, 154, 105, 134]), (bytes [188, 23, 179, 202, 216, 119, 253, 192, 107, 56, 140, 18, 247, 51, 234, 39, 235, 216, 134, 241, 7, 60, 104, 146, 182, 166, 45, 236, 214, 213, 211, 83]), (bytes [78, 156, 218, 132, 187, 128, 28, 175, 180, 45, 97, 45, 52, 94, 142, 189, 238, 235, 64, 164, 28, 129, 72, 154, 162, 227, 67, 115, 203, 223, 178, 142]), (bytes [247, 84, 178, 204, 90, 180, 61, 115, 170, 41, 175, 56, 192, 166, 216, 206, 90, 250, 210, 11, 223, 56, 140, 159, 30, 177, 31, 157, 136, 117, 20, 121]), (bytes [50, 117, 247, 44, 135, 251, 33, 130, 187, 149, 173, 15, 157, 44, 184, 232, 74, 29, 121, 15, 49, 15, 1, 170, 4, 57, 254, 21, 66, 20, 255, 57]), (bytes [42, 144, 74, 161, 221, 59, 4, 10, 214, 228, 39, 229, 69, 243, 213, 91, 38, 245, 79, 115, 75, 9, 211, 87, 113, 158, 116, 122, 108, 167, 109, 114]), (bytes [179, 197, 166, 238, 247, 39, 161, 56, 86, 33, 181, 194, 233, 28, 80, 101, 156, 182, 133, 82, 176, 76, 183, 86, 85, 15, 113, 247, 11, 149, 206, 77]), (bytes [133, 160, 199, 189, 7, 112, 198, 246, 237, 84, 81, 147, 189, 17, 217, 241, 202, 249, 239, 243, 169, 101, 30, 246, 218, 32, 171, 254, 107, 102, 128, 154]), (bytes [63, 200, 130, 136, 30, 171, 131, 98, 252, 188, 139, 234, 231, 103, 43, 28, 103, 10, 4, 88, 242, 189, 178, 158, 238, 119, 30, 71, 137, 61, 186, 18]), (bytes [126, 86, 142, 26, 182, 125, 203, 210, 164, 8, 133, 114, 56, 130, 212, 35, 222, 149, 156, 50, 191, 58, 183, 101, 106, 74, 112, 221, 102, 51, 206, 34]), (bytes [18, 172, 128, 176, 253, 198, 4, 93, 34, 80, 94, 154, 166, 81, 235, 21, 208, 214, 240, 19, 132, 26, 227, 255, 47, 232, 138, 242, 49, 178, 152, 151]), (bytes [123, 115, 37, 51, 88, 50, 51, 84, 5, 102, 248, 34, 238, 90, 209, 104, 209, 182, 98, 112, 16, 243, 38, 61, 147, 240, 83, 109, 196, 231, 107, 44]), (bytes [125, 139, 255, 63, 66, 75, 217, 97, 3, 18, 128, 169, 165, 111, 145, 8, 118, 207, 26, 139, 239, 101, 9, 150, 41, 34, 162, 59, 254, 252, 55, 58]), (bytes [44, 32, 216, 93, 16, 146, 0, 130, 207, 204, 36, 141, 166, 246, 232, 20, 247, 247, 116, 89, 62, 217, 122, 245, 142, 15, 143, 44, 219, 131, 183, 12]), (bytes [63, 55, 148, 202, 193, 201, 88, 153, 244, 174, 145, 10, 157, 92, 137, 79, 24, 240, 86, 214, 120, 193, 105, 254, 83, 207, 7, 36, 175, 251, 198, 209]), (bytes [49, 184, 142, 166, 178, 93, 15, 133, 19, 3, 245, 149, 190, 250, 17, 77, 195, 143, 141, 153, 122, 25, 168, 96, 127, 182, 178, 210, 211, 3, 144, 60]), (bytes [86, 196, 110, 116, 66, 242, 23, 243, 102, 32, 103, 253, 30, 136, 67, 166, 214, 221, 241, 169, 190, 115, 51, 189, 2, 90, 50, 65, 2, 198, 240, 74]), (bytes [204, 170, 135, 24, 120, 2, 130, 166, 238, 140, 237, 167, 80, 81, 222, 98, 53, 76, 178, 231, 84, 4, 44, 222, 24, 14, 1, 161, 175, 62, 34, 83]), (bytes [254, 19, 232, 192, 11, 39, 102, 229, 212, 95, 179, 72, 76, 113, 31, 113, 119, 17, 192, 125, 69, 105, 89, 144, 235, 22, 196, 55, 37, 148, 98, 206]), (bytes [126, 178, 122, 220, 67, 252, 127, 71, 82, 225, 133, 219, 37, 32, 10, 78, 133, 40, 227, 107, 52, 114, 163, 131, 123, 127, 232, 227, 171, 62, 101, 156]), (bytes [150, 56, 15, 19, 5, 104, 56, 230, 209, 159, 201, 154, 59, 102, 109, 165, 137, 182, 61, 198, 151, 229, 213, 14, 110, 234, 163, 84, 29, 98, 8, 176]), (bytes [200, 56, 51, 134, 173, 219, 218, 153, 14, 48, 181, 178, 53, 188, 122, 219, 157, 116, 70, 125, 225, 15, 34, 230, 227, 66, 217, 29, 84, 102, 182, 253]), (bytes [210, 70, 3, 57, 245, 131, 122, 183, 202, 155, 172, 21, 75, 121, 43, 183, 199, 58, 106, 240, 174, 143, 12, 118, 52, 65, 199, 50, 16, 143, 205, 192]), (bytes [179, 48, 0, 250, 27, 221, 177, 148, 93, 180, 91, 49, 228, 54, 116, 100, 128, 40, 176, 25, 157, 98, 83, 138, 39, 246, 67, 217, 82, 69, 86, 192]), (bytes [230, 233, 51, 142, 175, 227, 185, 68, 193, 102, 205, 229, 70, 211, 83, 226, 20, 174, 185, 68, 145, 102, 56, 1, 187, 15, 129, 252, 242, 17, 12, 153]), (bytes [115, 221, 25, 201, 235, 175, 57, 9, 159, 237, 1, 99, 122, 176, 133, 105, 76, 191, 15, 198, 154, 87, 195, 119, 27, 252, 234, 251, 191, 97, 36, 22]), (bytes [159, 136, 79, 19, 3, 64, 16, 130, 170, 158, 169, 178, 191, 146, 174, 198, 91, 233, 1, 17, 175, 210, 201, 9, 131, 122, 214, 44, 60, 157, 185, 73]), (bytes [83, 251, 49, 48, 54, 174, 206, 33, 38, 55, 53, 86, 238, 134, 67, 140, 194, 44, 73, 155, 93, 189, 217, 191, 38, 87, 214, 184, 137, 68, 230, 167]), (bytes [240, 212, 182, 90, 28, 28, 194, 255, 94, 159, 35, 103, 91, 242, 214, 20, 102, 217, 67, 85, 43, 252, 11, 32, 160, 11, 241, 164, 190, 14, 75, 153]), (bytes [83, 203, 23, 43, 120, 2, 138, 179, 201, 101, 117, 199, 249, 119, 150, 189, 107, 206, 100, 240, 241, 191, 29, 12, 95, 189, 46, 162, 173, 67, 52, 64]), (bytes [243, 18, 112, 16, 115, 206, 161, 217, 70, 120, 53, 168, 21, 217, 125, 177, 15, 184, 39, 220, 129, 252, 253, 217, 143, 169, 231, 204, 197, 173, 74, 44]), (bytes [174, 205, 154, 64, 243, 198, 70, 67, 132, 170, 211, 195, 186, 11, 96, 55, 55, 6, 248, 130, 169, 186, 214, 86, 104, 198, 34, 111, 234, 42, 133, 117]), (bytes [181, 205, 4, 135, 126, 61, 165, 192, 182, 157, 219, 25, 61, 190, 241, 123, 199, 165, 114, 116, 128, 144, 237, 80, 99, 219, 70, 24, 44, 75, 141, 99]), (bytes [64, 184, 77, 60, 124, 164, 54, 93, 23, 121, 89, 235, 81, 60, 107, 51, 86, 73, 18, 40, 80, 16, 45, 151, 39, 61, 175, 64, 40, 48, 21, 239]), (bytes [233, 150, 233, 24, 120, 142, 81, 204, 197, 94, 9, 71, 112, 24, 112, 173, 149, 24, 63, 117, 95, 104, 238, 197, 31, 101, 173, 98, 112, 244, 218, 130]), (bytes [145, 99, 191, 35, 121, 90, 118, 57, 187, 82, 200, 99, 201, 117, 132, 16, 109, 95, 126, 62, 89, 129, 183, 210, 46, 8, 148, 208, 73, 204, 191, 238])], familyDigest := (bytes [6, 23, 36, 33, 23, 226, 157, 251, 165, 190, 255, 219, 249, 58, 34, 233, 160, 194, 223, 125, 31, 225, 196, 138, 224, 6, 179, 93, 109, 39, 25, 113]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [6, 23, 36, 33, 23, 226, 157, 251, 165, 190, 255, 219, 249, 58, 34, 233, 160, 194, 223, 125, 31, 225, 196, 138, 224, 6, 179, 93, 109, 39, 25, 113]), layoutVersion := 1, digest := (bytes [215, 208, 213, 36, 98, 12, 42, 132, 158, 68, 40, 9, 236, 133, 239, 185, 198, 81, 232, 6, 93, 27, 137, 38, 86, 217, 165, 249, 122, 174, 131, 168]) }, logicalIndex := 0, digest := (bytes [108, 77, 206, 195, 120, 223, 83, 3, 248, 79, 145, 30, 138, 29, 114, 42, 133, 197, 137, 83, 200, 226, 104, 75, 191, 200, 247, 248, 184, 27, 238, 62]) }, valueDigest := (bytes [49, 112, 41, 120, 103, 26, 24, 17, 240, 51, 88, 180, 158, 199, 42, 251, 183, 57, 20, 149, 1, 43, 127, 249, 47, 108, 100, 231, 221, 153, 232, 90]), digest := (bytes [17, 207, 121, 237, 159, 155, 36, 164, 116, 95, 128, 75, 120, 77, 118, 119, 80, 17, 73, 60, 22, 80, 44, 110, 232, 41, 145, 233, 164, 251, 92, 238]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [6, 23, 36, 33, 23, 226, 157, 251, 165, 190, 255, 219, 249, 58, 34, 233, 160, 194, 223, 125, 31, 225, 196, 138, 224, 6, 179, 93, 109, 39, 25, 113]), layoutVersion := 1, digest := (bytes [215, 208, 213, 36, 98, 12, 42, 132, 158, 68, 40, 9, 236, 133, 239, 185, 198, 81, 232, 6, 93, 27, 137, 38, 86, 217, 165, 249, 122, 174, 131, 168]) }, logicalIndex := 6, digest := (bytes [216, 72, 40, 191, 64, 74, 101, 211, 203, 238, 142, 231, 112, 78, 0, 138, 144, 122, 184, 130, 143, 193, 200, 114, 121, 8, 231, 201, 217, 200, 170, 128]) }, valueDigest := (bytes [57, 167, 127, 66, 29, 28, 1, 62, 111, 174, 45, 82, 212, 157, 25, 154, 254, 72, 204, 85, 223, 7, 138, 44, 48, 11, 222, 83, 122, 239, 183, 120]), digest := (bytes [66, 120, 177, 28, 12, 51, 17, 88, 29, 137, 234, 40, 93, 97, 58, 32, 240, 194, 5, 198, 91, 176, 154, 39, 164, 136, 135, 32, 86, 196, 137, 83]) }), digest := (bytes [185, 24, 211, 142, 31, 112, 65, 51, 253, 112, 60, 223, 123, 82, 147, 127, 254, 126, 62, 18, 64, 21, 206, 117, 19, 200, 13, 224, 237, 197, 69, 170]) }
  , rootLaneCommitment := { timeLen := 7, commitments := { commitmentCount := 38, digest := (bytes [188, 12, 95, 85, 66, 33, 99, 49, 226, 20, 83, 140, 184, 203, 2, 197, 58, 72, 27, 185, 133, 183, 5, 214, 56, 240, 203, 134, 116, 9, 141, 194]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [188, 12, 95, 85, 66, 33, 99, 49, 226, 20, 83, 140, 184, 203, 2, 197, 58, 72, 27, 185, 133, 183, 5, 214, 56, 240, 203, 134, 116, 9, 141, 194]), layoutVersion := 3, digest := (bytes [93, 165, 209, 153, 58, 191, 53, 125, 149, 135, 164, 81, 108, 190, 175, 75, 191, 102, 98, 247, 125, 159, 208, 119, 229, 244, 240, 202, 143, 114, 108, 202]) }, logicalIndex := 0, digest := (bytes [129, 215, 43, 59, 203, 39, 35, 65, 215, 34, 107, 74, 102, 41, 143, 193, 105, 59, 216, 89, 191, 88, 229, 192, 27, 145, 190, 119, 196, 193, 146, 86]) }, valueDigest := (bytes [49, 112, 41, 120, 103, 26, 24, 17, 240, 51, 88, 180, 158, 199, 42, 251, 183, 57, 20, 149, 1, 43, 127, 249, 47, 108, 100, 231, 221, 153, 232, 90]), digest := (bytes [34, 109, 239, 78, 212, 125, 84, 109, 35, 231, 9, 110, 158, 166, 139, 211, 73, 48, 227, 193, 83, 46, 47, 210, 163, 190, 147, 240, 188, 142, 74, 13]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [188, 12, 95, 85, 66, 33, 99, 49, 226, 20, 83, 140, 184, 203, 2, 197, 58, 72, 27, 185, 133, 183, 5, 214, 56, 240, 203, 134, 116, 9, 141, 194]), layoutVersion := 3, digest := (bytes [93, 165, 209, 153, 58, 191, 53, 125, 149, 135, 164, 81, 108, 190, 175, 75, 191, 102, 98, 247, 125, 159, 208, 119, 229, 244, 240, 202, 143, 114, 108, 202]) }, logicalIndex := 6, digest := (bytes [27, 222, 251, 202, 155, 65, 36, 46, 105, 119, 166, 124, 124, 92, 5, 11, 163, 81, 33, 98, 148, 207, 51, 68, 71, 88, 69, 250, 107, 132, 2, 115]) }, valueDigest := (bytes [57, 167, 127, 66, 29, 28, 1, 62, 111, 174, 45, 82, 212, 157, 25, 154, 254, 72, 204, 85, 223, 7, 138, 44, 48, 11, 222, 83, 122, 239, 183, 120]), digest := (bytes [239, 144, 64, 133, 16, 33, 187, 192, 199, 171, 231, 186, 85, 250, 190, 54, 136, 147, 57, 153, 203, 201, 166, 165, 80, 159, 29, 7, 34, 242, 144, 125]) }), digest := (bytes [154, 54, 137, 236, 75, 115, 116, 110, 148, 80, 210, 34, 52, 240, 128, 94, 154, 75, 213, 221, 154, 160, 95, 236, 179, 252, 242, 20, 68, 216, 117, 243]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [185, 24, 211, 142, 31, 112, 65, 51, 253, 112, 60, 223, 123, 82, 147, 127, 254, 126, 62, 18, 64, 21, 206, 117, 19, 200, 13, 224, 237, 197, 69, 170]), rootLaneCommitmentDigest := (bytes [154, 54, 137, 236, 75, 115, 116, 110, 148, 80, 210, 34, 52, 240, 128, 94, 154, 75, 213, 221, 154, 160, 95, 236, 179, 252, 242, 20, 68, 216, 117, 243]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 7, digest := (bytes [206, 159, 213, 58, 149, 250, 197, 229, 63, 141, 122, 233, 11, 38, 60, 217, 215, 34, 60, 17, 141, 154, 200, 71, 6, 104, 67, 107, 105, 225, 247, 114]) }, statementDigest := (bytes [149, 99, 152, 248, 29, 72, 150, 108, 49, 205, 156, 74, 10, 12, 136, 78, 8, 240, 221, 63, 39, 142, 87, 120, 12, 133, 254, 176, 161, 154, 58, 228]), proofDigest := (bytes [142, 4, 17, 150, 223, 130, 123, 216, 10, 91, 235, 126, 9, 148, 131, 195, 18, 211, 37, 62, 45, 2, 94, 114, 112, 56, 49, 30, 29, 144, 252, 207]), digest := (bytes [11, 174, 3, 238, 131, 48, 50, 235, 141, 1, 103, 149, 189, 244, 17, 245, 9, 195, 8, 21, 46, 95, 194, 235, 69, 28, 176, 211, 210, 72, 177, 98]) }
  , digest := (bytes [25, 208, 63, 191, 56, 150, 225, 211, 131, 209, 183, 103, 230, 33, 34, 36, 245, 162, 195, 60, 200, 17, 239, 169, 26, 209, 78, 207, 135, 192, 57, 129])
}
    , transcript := {
  appLabel := (bytes [110, 101, 111, 46, 102, 111, 108, 100, 46, 110, 101, 120, 116, 47, 114, 118, 54, 52, 105, 109, 47, 112, 97, 114, 105, 116, 121, 95, 107, 101, 114, 110, 101, 108, 95, 118, 49])
  , events := [{
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 116, 114, 97, 110, 115, 99, 114, 105, 112, 116, 95, 115, 101, 101, 100])
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 110, 97, 116, 105, 118, 101, 45, 117, 112, 112, 101, 114, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [33264016603246709, 49, 3390619080185759186, 12096819762988914126, 4001610679670701799, 5432763535062103318, 13415967828788768464, 15663373744946530692], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [110, 97, 116, 105, 118, 101, 95, 115, 117, 98, 95, 108, 117, 105, 95, 97, 117, 105, 112, 99, 95, 102, 101, 110, 99, 101, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [33264016603246709, 49, 3390619080185759186, 12096819762988914126, 4001610679670701799, 5432763535062103318, 13415967828788768464, 15663373744946530692], absorbed := 2 }
  , cursorAfter := { stateWords := [1819042147, 11492432570176362726, 3613697514698292200, 2650558433509510378, 12055400323590214993, 7120483714660094914, 8332376278638538225, 13997537144169937627], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [9437331, 4194579, 1075872179, 305418807, 8855, 15, 115]
  , cursorBefore := { stateWords := [1819042147, 11492432570176362726, 3613697514698292200, 2650558433509510378, 12055400323590214993, 7120483714660094914, 8332376278638538225, 13997537144169937627], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 8205865210994545291, 16390913469773137775, 10686499010112080571, 3479089081210409115, 11490434913573307181, 4744750243635717087, 14190831713282467533], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [0, 8205865210994545291, 16390913469773137775, 10686499010112080571, 3479089081210409115, 11490434913573307181, 4744750243635717087, 14190831713282467533], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 0, 0, 13927086879393838485, 2623036754198827976, 17760213709172924268, 9303648523283746330, 14333610373503370693], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [0, 0, 0, 13927086879393838485, 2623036754198827976, 17760213709172924268, 9303648523283746330, 14333610373503370693], absorbed := 3 }
  , cursorAfter := { stateWords := [0, 15034277137021512653, 2940523068502370021, 6783709668891648116, 2921762084008379884, 13093662981597386728, 7237693185718636805, 15480948837919714228], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [243, 113, 232, 88, 106, 85, 125, 126, 75, 211, 202, 21, 77, 236, 178, 254, 109, 98, 100, 162, 148, 107, 115, 169, 238, 169, 84, 21, 113, 145, 196, 77])
  , u64s := []
  , cursorBefore := { stateWords := [0, 15034277137021512653, 2940523068502370021, 6783709668891648116, 2921762084008379884, 13093662981597386728, 7237693185718636805, 15480948837919714228], absorbed := 1 }
  , cursorAfter := { stateWords := [16698362512571709445, 5621564629903000699, 10009083160971522880, 7591915833665178415, 4881815619038706464, 1221843751511080609, 17487803174555929498, 11190372688641205339], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [16698362512571709445, 5621564629903000699, 10009083160971522880, 7591915833665178415, 4881815619038706464, 1221843751511080609, 17487803174555929498, 11190372688641205339], absorbed := 0 }
  , cursorAfter := { stateWords := [4896283865473105481, 12847043629536236269, 11452704206453262291, 12159014570259131020, 15761870554813372632, 1933128212755914187, 7691327332694391306, 5251054156748709053], absorbed := 0 }
  , challengeOutput := (some 4896283865473105481)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [13, 9, 218, 115, 204, 43, 4, 113, 32, 177, 132, 132, 182, 134, 250, 82, 89, 188, 40, 248, 201, 130, 127, 49, 3, 60, 79, 175, 212, 151, 219, 255])
  , u64s := []
  , cursorBefore := { stateWords := [4896283865473105481, 12847043629536236269, 11452704206453262291, 12159014570259131020, 15761870554813372632, 1933128212755914187, 7691327332694391306, 5251054156748709053], absorbed := 0 }
  , cursorAfter := { stateWords := [56849324161192698, 49345240094572418, 4292581332, 9800505453015189377, 9590740405110030922, 16846094450105664483, 10584449469242708340, 4875974988665847814], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [56849324161192698, 49345240094572418, 4292581332, 9800505453015189377, 9590740405110030922, 16846094450105664483, 10584449469242708340, 4875974988665847814], absorbed := 3 }
  , cursorAfter := { stateWords := [7033248085425099487, 5551250185185976109, 6838203931123481440, 10155553537626108981, 15357769538341139672, 2358490636320328012, 11314427473321819060, 9232286664736664635], absorbed := 0 }
  , challengeOutput := (some 7033248085425099487)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [7033248085425099487, 5551250185185976109, 6838203931123481440, 10155553537626108981, 15357769538341139672, 2358490636320328012, 11314427473321819060, 9232286664736664635], absorbed := 0 }
  , cursorAfter := { stateWords := [8169386753030433916, 18385266726658662445, 12573782555528246414, 11448961664731975404, 12518743713704370554, 9694518568927529184, 4856529869949649507, 10304706592028699305], absorbed := 0 }
  , challengeOutput := (some 8169386753030433916)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [15, 204, 89, 37, 7, 113, 30, 46, 152, 189, 215, 255, 96, 129, 30, 176, 43, 248, 43, 100, 180, 85, 5, 151, 15, 168, 47, 45, 165, 34, 74, 203])
  , u64s := []
  , cursorBefore := { stateWords := [8169386753030433916, 18385266726658662445, 12573782555528246414, 11448961664731975404, 12518743713704370554, 9694518568927529184, 4856529869949649507, 10304706592028699305], absorbed := 0 }
  , cursorAfter := { stateWords := [50775635817902110, 12718772814546261, 3410633381, 10034820627164037781, 13600521825979114431, 16788147473131196060, 10808458552465737848, 15289043801276852242], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [50775635817902110, 12718772814546261, 3410633381, 10034820627164037781, 13600521825979114431, 16788147473131196060, 10808458552465737848, 15289043801276852242], absorbed := 3 }
  , cursorAfter := { stateWords := [13526737568366105716, 386749902861854862, 505187822126796796, 3924489003198897156, 17943143049075451202, 13587490318313133728, 6809125786034294136, 12332313511951957591], absorbed := 0 }
  , challengeOutput := (some 13526737568366105716)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [13, 62, 18, 231, 159, 216, 74, 146, 123, 100, 48, 154, 55, 62, 243, 77, 247, 72, 183, 146, 55, 128, 226, 205, 79, 61, 249, 159, 174, 184, 114, 0])
  , u64s := []
  , cursorBefore := { stateWords := [13526737568366105716, 386749902861854862, 505187822126796796, 3924489003198897156, 17943143049075451202, 13587490318313133728, 6809125786034294136, 12332313511951957591], absorbed := 0 }
  , cursorAfter := { stateWords := [15642439619923443, 45028563024208512, 7518382, 4674175335594239469, 8343585173727886530, 13355842309813324475, 5970572056999808892, 17880192704068840598], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [28, 1, 84, 184, 89, 242, 14, 108, 33, 243, 25, 226, 156, 89, 231, 121, 72, 112, 15, 25, 78, 90, 217, 60, 9, 73, 78, 4, 175, 30, 106, 21])
  , u64s := []
  , cursorBefore := { stateWords := [15642439619923443, 45028563024208512, 7518382, 4674175335594239469, 8343585173727886530, 13355842309813324475, 5970572056999808892, 17880192704068840598], absorbed := 3 }
  , cursorAfter := { stateWords := [21982602282432999, 1211975501404506, 359276207, 11778840946998352371, 2601310992186137151, 9183972256606065443, 2341718538809599119, 7720520626828516466], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [235, 168, 117, 145, 21, 252, 85, 198, 113, 178, 38, 202, 134, 138, 105, 213, 57, 49, 5, 39, 70, 58, 244, 201, 34, 144, 14, 16, 184, 169, 197, 30])
  , u64s := []
  , cursorBefore := { stateWords := [21982602282432999, 1211975501404506, 359276207, 11778840946998352371, 2601310992186137151, 9183972256606065443, 2341718538809599119, 7720520626828516466], absorbed := 3 }
  , cursorAfter := { stateWords := [19746151623939433, 4519611849110586, 516270520, 841895348041309407, 6525366411293773459, 10331942656253231823, 8000196005749216479, 4242443321909022880], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [19746151623939433, 4519611849110586, 516270520, 841895348041309407, 6525366411293773459, 10331942656253231823, 8000196005749216479, 4242443321909022880], absorbed := 3 }
  , cursorAfter := { stateWords := [6691788142193379930, 442893960619180382, 14347864803423902063, 2733085216426276580, 13712782214558036224, 14831264393031247711, 17027622760445651302, 1083395422601994900], absorbed := 0 }
  , challengeOutput := (some 6691788142193379930)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [6691788142193379930, 442893960619180382, 14347864803423902063, 2733085216426276580, 13712782214558036224, 14831264393031247711, 17027622760445651302, 1083395422601994900], absorbed := 0 }
  , cursorAfter := { stateWords := [15976141382771928389, 11705041835130272246, 17103682074520183549, 11353896720354733691, 6592350785348559089, 11058181024729775942, 13765259832617846959, 12403894881833510756], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [69, 237, 137, 65, 241, 167, 182, 221, 246, 185, 6, 120, 136, 169, 112, 162, 253, 226, 253, 66, 58, 124, 92, 237, 123, 110, 55, 97, 233, 36, 145, 157]))
}]
}
    , stage1 := stage1
    , stage2 := stage2
    , stage3 := stage3
    , rootExecution := rootExecution
    , stepComposition := stepComposition
    , soundnessAccounting := soundnessAccounting
    , kernelOpeningBundle := kernelOpeningBundle
    , digest := (bytes [17, 121, 115, 11, 35, 48, 181, 53, 153, 206, 34, 31, 226, 227, 140, 60, 28, 186, 141, 67, 235, 41, 48, 192, 63, 98, 239, 213, 5, 119, 248, 57])
  }

end Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors.Case_native_sub_lui_auipc_fence_ecall
