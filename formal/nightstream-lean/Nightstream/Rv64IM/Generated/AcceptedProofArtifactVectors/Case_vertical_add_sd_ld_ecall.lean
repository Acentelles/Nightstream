import Nightstream.Rv64IM.Generated.AcceptedProofArtifactTypes

set_option maxHeartbeats 0
set_option maxRecDepth 65536

namespace Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors.Case_vertical_add_sd_ld_ecall

open Nightstream.Rv64IM.Generated

def stage1SemInputs : List SemInView :=
  [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, pc := 0, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 1, archRdBefore := 0, archImm := 5, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 1, rdBefore := 0, rdAfter := 5, imm := 5, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, pc := 4, opcode := .add, traceOpcode := (some .add), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 1, archRs1Value := 5, archRs2 := 1, archRs2Value := 5, archRd := 2, archRdBefore := 0, archImm := 0, rs1 := 1, rs1Value := 5, rs2 := 1, rs2Value := 5, rd := 2, rdBefore := 0, rdAfter := 10, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, pc := 8, opcode := .sd, traceOpcode := (some .sd), traceVirtualOpcode := none, family := .alignedMemory, archRs1 := 10, archRs1Value := 4096, archRs2 := 2, archRs2Value := 10, archRd := 0, archRdBefore := 0, archImm := 0, rs1 := 10, rs1Value := 4096, rs2 := 2, rs2Value := 10, rd := 0, rdBefore := 0, rdAfter := 0, imm := 0, effectiveAddr := (some 4096), memoryBefore := (some 0), memoryAfter := (some 10), memWidthBytes := (some 8), memUnsigned := none, writesRd := false, writesRam := true, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, pc := 12, opcode := .ld, traceOpcode := (some .ld), traceVirtualOpcode := none, family := .alignedMemory, archRs1 := 10, archRs1Value := 4096, archRs2 := 0, archRs2Value := 0, archRd := 3, archRdBefore := 0, archImm := 0, rs1 := 10, rs1Value := 4096, rs2 := 0, rs2Value := 0, rd := 3, rdBefore := 0, rdAfter := 10, imm := 0, effectiveAddr := (some 4096), memoryBefore := (some 10), memoryAfter := (some 10), memWidthBytes := (some 8), memUnsigned := (some true), writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 4, stepIndex := 4, sequenceIndex := 0, pc := 16, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 0, archRdBefore := 0, archImm := 0, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 0, rdBefore := 0, rdAfter := 0, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := false, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }]

def stage1RowBindings : List Stage1RowBindingView :=
  [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 5243027, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 4, aluResult := 5, effectiveAddr := none, writesRd := true, rd := 1, rdAfter := 5, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 1081651, opcode := .add, traceOpcode := (some .add), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 8, aluResult := 10, effectiveAddr := none, writesRd := true, rd := 2, rdAfter := 10, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 2437155, opcode := .sd, traceOpcode := (some .sd), traceVirtualOpcode := none, family := .alignedMemory, nextPc := 12, aluResult := 10, effectiveAddr := (some 4096), writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 12, fetchedWord := 340355, opcode := .ld, traceOpcode := (some .ld), traceVirtualOpcode := none, family := .alignedMemory, nextPc := 16, aluResult := 10, effectiveAddr := (some 4096), writesRd := true, rd := 3, rdAfter := 10, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 4, stepIndex := 4, sequenceIndex := 0, fetchPc := 16, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 20, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }]

def stage1 : Stage1ProofBundleView :=
  {
    semInputs := stage1SemInputs
    , rowBindings := stage1RowBindings
    , bytecodeDigest := (bytes [121, 138, 79, 84, 162, 191, 126, 34, 8, 188, 142, 127, 177, 243, 23, 148, 21, 47, 90, 156, 248, 180, 139, 64, 85, 97, 137, 38, 186, 147, 1, 9])
    , aluDigest := (bytes [121, 129, 30, 202, 0, 10, 44, 172, 139, 36, 27, 22, 185, 195, 240, 145, 90, 58, 110, 63, 242, 213, 34, 250, 28, 18, 90, 69, 128, 173, 202, 128])
    , branchDigest := (bytes [124, 141, 75, 148, 174, 119, 150, 88, 72, 169, 25, 234, 62, 86, 24, 213, 168, 88, 242, 13, 27, 106, 30, 62, 141, 72, 69, 81, 168, 102, 54, 204])
    , semantics := { semInputsDigest := (bytes [138, 158, 168, 220, 194, 205, 170, 28, 195, 12, 34, 250, 76, 49, 227, 108, 35, 35, 189, 52, 128, 81, 126, 204, 40, 247, 26, 66, 103, 37, 159, 116]), rowBindingsDigest := (bytes [170, 132, 211, 38, 125, 237, 30, 150, 183, 107, 93, 111, 34, 73, 148, 2, 243, 160, 207, 75, 124, 189, 129, 153, 180, 60, 240, 23, 181, 107, 84, 142]), sequenceCount := 5, helperRowCount := 0, digest := (bytes [185, 10, 252, 28, 6, 208, 226, 194, 100, 83, 68, 180, 90, 91, 25, 159, 145, 45, 95, 16, 225, 156, 68, 137, 22, 2, 226, 45, 135, 30, 73, 8]) }
    , addressCorrectnessDigest := (bytes [117, 53, 95, 70, 69, 228, 45, 16, 205, 255, 95, 18, 69, 130, 57, 170, 119, 12, 224, 74, 17, 54, 110, 196, 129, 83, 213, 87, 196, 80, 117, 197])
    , linkageDigest := (bytes [162, 143, 125, 16, 37, 49, 72, 52, 117, 54, 109, 159, 150, 204, 146, 94, 146, 192, 166, 164, 29, 41, 131, 99, 133, 139, 70, 95, 4, 44, 183, 76])
    , selectedOpening := { claim := { rowsFamilyDigest := (bytes [170, 132, 211, 38, 125, 237, 30, 150, 183, 107, 93, 111, 34, 73, 148, 2, 243, 160, 207, 75, 124, 189, 129, 153, 180, 60, 240, 23, 181, 107, 84, 142]), rowCount := 5, effectRowCount := 5, commitRowCount := 5, realRowCount := 5, preservesX0Count := 2, firstTraceIndex := 0, effectTraceIndex := 0, commitTraceIndex := 0, lastTraceIndex := 4, mix := 13284789833745455176, points := { first := { id := { object := { familyTag := 1, commitmentDigest := (bytes [170, 132, 211, 38, 125, 237, 30, 150, 183, 107, 93, 111, 34, 73, 148, 2, 243, 160, 207, 75, 124, 189, 129, 153, 180, 60, 240, 23, 181, 107, 84, 142]), layoutVersion := 1, digest := (bytes [141, 165, 86, 191, 174, 107, 169, 227, 90, 49, 32, 96, 139, 127, 85, 2, 110, 180, 44, 204, 24, 85, 2, 16, 22, 136, 193, 104, 141, 48, 203, 207]) }, logicalIndex := 0, digest := (bytes [233, 219, 8, 156, 218, 247, 130, 241, 47, 127, 202, 226, 218, 43, 154, 252, 91, 51, 103, 69, 193, 81, 138, 228, 26, 156, 52, 42, 250, 228, 172, 6]) }, valueDigest := (bytes [192, 39, 142, 151, 135, 172, 252, 135, 48, 191, 234, 37, 159, 235, 250, 50, 196, 251, 127, 61, 53, 90, 170, 88, 94, 40, 229, 126, 104, 90, 79, 155]), digest := (bytes [47, 61, 205, 93, 246, 64, 26, 24, 135, 105, 77, 123, 216, 106, 95, 255, 200, 184, 184, 200, 51, 20, 82, 255, 24, 43, 123, 223, 188, 238, 37, 118]) }, effect := { id := { object := { familyTag := 1, commitmentDigest := (bytes [170, 132, 211, 38, 125, 237, 30, 150, 183, 107, 93, 111, 34, 73, 148, 2, 243, 160, 207, 75, 124, 189, 129, 153, 180, 60, 240, 23, 181, 107, 84, 142]), layoutVersion := 1, digest := (bytes [141, 165, 86, 191, 174, 107, 169, 227, 90, 49, 32, 96, 139, 127, 85, 2, 110, 180, 44, 204, 24, 85, 2, 16, 22, 136, 193, 104, 141, 48, 203, 207]) }, logicalIndex := 0, digest := (bytes [233, 219, 8, 156, 218, 247, 130, 241, 47, 127, 202, 226, 218, 43, 154, 252, 91, 51, 103, 69, 193, 81, 138, 228, 26, 156, 52, 42, 250, 228, 172, 6]) }, valueDigest := (bytes [192, 39, 142, 151, 135, 172, 252, 135, 48, 191, 234, 37, 159, 235, 250, 50, 196, 251, 127, 61, 53, 90, 170, 88, 94, 40, 229, 126, 104, 90, 79, 155]), digest := (bytes [47, 61, 205, 93, 246, 64, 26, 24, 135, 105, 77, 123, 216, 106, 95, 255, 200, 184, 184, 200, 51, 20, 82, 255, 24, 43, 123, 223, 188, 238, 37, 118]) }, commit := { id := { object := { familyTag := 1, commitmentDigest := (bytes [170, 132, 211, 38, 125, 237, 30, 150, 183, 107, 93, 111, 34, 73, 148, 2, 243, 160, 207, 75, 124, 189, 129, 153, 180, 60, 240, 23, 181, 107, 84, 142]), layoutVersion := 1, digest := (bytes [141, 165, 86, 191, 174, 107, 169, 227, 90, 49, 32, 96, 139, 127, 85, 2, 110, 180, 44, 204, 24, 85, 2, 16, 22, 136, 193, 104, 141, 48, 203, 207]) }, logicalIndex := 0, digest := (bytes [233, 219, 8, 156, 218, 247, 130, 241, 47, 127, 202, 226, 218, 43, 154, 252, 91, 51, 103, 69, 193, 81, 138, 228, 26, 156, 52, 42, 250, 228, 172, 6]) }, valueDigest := (bytes [192, 39, 142, 151, 135, 172, 252, 135, 48, 191, 234, 37, 159, 235, 250, 50, 196, 251, 127, 61, 53, 90, 170, 88, 94, 40, 229, 126, 104, 90, 79, 155]), digest := (bytes [47, 61, 205, 93, 246, 64, 26, 24, 135, 105, 77, 123, 216, 106, 95, 255, 200, 184, 184, 200, 51, 20, 82, 255, 24, 43, 123, 223, 188, 238, 37, 118]) }, last := { id := { object := { familyTag := 1, commitmentDigest := (bytes [170, 132, 211, 38, 125, 237, 30, 150, 183, 107, 93, 111, 34, 73, 148, 2, 243, 160, 207, 75, 124, 189, 129, 153, 180, 60, 240, 23, 181, 107, 84, 142]), layoutVersion := 1, digest := (bytes [141, 165, 86, 191, 174, 107, 169, 227, 90, 49, 32, 96, 139, 127, 85, 2, 110, 180, 44, 204, 24, 85, 2, 16, 22, 136, 193, 104, 141, 48, 203, 207]) }, logicalIndex := 4, digest := (bytes [193, 72, 158, 247, 122, 62, 32, 30, 100, 156, 62, 130, 169, 118, 118, 157, 149, 183, 15, 110, 117, 71, 63, 148, 230, 32, 169, 40, 123, 245, 165, 15]) }, valueDigest := (bytes [80, 178, 26, 49, 69, 161, 230, 123, 68, 254, 88, 88, 229, 248, 207, 138, 245, 172, 71, 139, 39, 139, 170, 107, 237, 65, 83, 59, 93, 8, 204, 99]), digest := (bytes [130, 61, 167, 59, 22, 226, 250, 67, 86, 172, 38, 31, 34, 125, 135, 90, 229, 250, 103, 9, 191, 142, 54, 58, 143, 226, 57, 8, 134, 84, 52, 51]) } }, digest := (bytes [4, 109, 70, 240, 8, 211, 144, 120, 135, 143, 73, 184, 100, 17, 218, 109, 240, 24, 169, 113, 49, 49, 17, 78, 97, 193, 75, 14, 128, 106, 190, 208]) }, packaged := { statementDigest := (bytes [126, 11, 96, 158, 195, 133, 196, 147, 98, 184, 45, 42, 166, 21, 252, 112, 85, 19, 124, 28, 157, 110, 106, 29, 225, 149, 144, 53, 14, 54, 57, 192]), proofDigest := (bytes [25, 93, 79, 202, 150, 172, 122, 221, 24, 155, 155, 49, 179, 33, 8, 97, 13, 220, 100, 1, 176, 52, 59, 128, 10, 20, 243, 117, 187, 121, 115, 247]) }, digest := (bytes [23, 204, 19, 237, 74, 72, 248, 248, 24, 243, 20, 63, 17, 17, 199, 2, 200, 236, 224, 206, 206, 169, 156, 126, 127, 221, 39, 197, 210, 120, 226, 132]) }
    , digest := (bytes [112, 3, 72, 151, 34, 123, 79, 219, 153, 76, 45, 29, 110, 124, 85, 35, 252, 109, 147, 153, 147, 50, 25, 189, 222, 71, 64, 130, 23, 220, 253, 210])
  }

def stage2RegisterReads : List RegisterReadEventView :=
  [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 0, value := 0 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 1, value := 5 }, { traceIndex := 1, stepIndex := 1, role := .rs2, reg := 1, value := 5 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 10, value := 4096 }, { traceIndex := 2, stepIndex := 2, role := .rs2, reg := 2, value := 10 }, { traceIndex := 3, stepIndex := 3, role := .rs1, reg := 10, value := 4096 }]

def stage2RegisterWrites : List RegisterWriteEventView :=
  [{ traceIndex := 0, stepIndex := 0, reg := 1, previous := 0, next := 5 }, { traceIndex := 1, stepIndex := 1, reg := 2, previous := 0, next := 10 }, { traceIndex := 3, stepIndex := 3, reg := 3, previous := 0, next := 10 }]

def stage2RamEvents : List RamEventView :=
  [{ traceIndex := 2, stepIndex := 2, kind := .write, addr := 4096, previous := 0, next := 10 }, { traceIndex := 3, stepIndex := 3, kind := .read, addr := 4096, previous := 10, next := 10 }]

def stage2TwistLinks : List TwistLinkEventView :=
  [{ traceIndex := 0, stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 5), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 1, family := .nativeAlu, routedWriteValue := (some 10), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 2, family := .alignedMemory, routedWriteValue := none, routedMemoryBefore := (some 0), routedMemoryAfter := (some 10) }, { traceIndex := 3, stepIndex := 3, family := .alignedMemory, routedWriteValue := (some 10), routedMemoryBefore := (some 10), routedMemoryAfter := (some 10) }, { traceIndex := 4, stepIndex := 4, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]

def stage2 : Stage2ProofBundleView :=
  {
    registerReads := stage2RegisterReads
    , registerWrites := stage2RegisterWrites
    , ramEvents := stage2RamEvents
    , registerDigest := (bytes [5, 229, 186, 102, 246, 35, 1, 126, 125, 6, 125, 111, 124, 144, 245, 41, 140, 239, 49, 175, 167, 171, 114, 166, 245, 230, 244, 47, 53, 124, 164, 55])
    , ramDigest := (bytes [1, 196, 28, 1, 213, 188, 202, 251, 33, 145, 218, 93, 198, 212, 96, 160, 74, 188, 199, 207, 80, 229, 71, 100, 20, 168, 124, 97, 166, 71, 253, 11])
    , temporal := { twistLinks := stage2TwistLinks, registerTimelineDigest := (bytes [64, 178, 120, 19, 155, 12, 82, 97, 5, 134, 52, 37, 253, 62, 143, 79, 71, 124, 0, 223, 136, 234, 38, 52, 39, 117, 169, 40, 209, 55, 69, 166]), ramTimelineDigest := (bytes [230, 187, 211, 232, 73, 98, 40, 81, 224, 129, 51, 51, 126, 81, 42, 19, 177, 47, 230, 213, 57, 220, 130, 99, 153, 42, 105, 11, 16, 20, 205, 125]), twistLinksDigest := (bytes [17, 127, 87, 104, 245, 142, 1, 204, 63, 114, 90, 152, 213, 69, 10, 216, 179, 117, 76, 172, 44, 208, 190, 22, 80, 168, 68, 220, 63, 221, 223, 146]), digest := (bytes [81, 241, 26, 85, 42, 93, 189, 168, 72, 43, 88, 224, 214, 188, 65, 109, 53, 79, 247, 245, 178, 112, 161, 171, 204, 178, 62, 19, 182, 192, 229, 81]) }
    , semantics := { registerReadsFamilyDigest := (bytes [117, 87, 193, 217, 226, 194, 99, 227, 114, 106, 145, 233, 112, 220, 177, 26, 188, 25, 251, 41, 128, 162, 5, 208, 86, 175, 143, 104, 145, 193, 205, 94]), registerWritesFamilyDigest := (bytes [185, 51, 63, 211, 114, 140, 159, 19, 206, 172, 35, 119, 251, 231, 40, 184, 66, 231, 144, 103, 240, 129, 172, 119, 210, 31, 39, 251, 200, 10, 239, 147]), ramEventsFamilyDigest := (bytes [18, 57, 34, 88, 168, 246, 181, 250, 193, 231, 230, 176, 242, 131, 217, 15, 250, 21, 129, 219, 38, 93, 67, 95, 132, 255, 54, 15, 4, 1, 49, 127]), twistLinksFamilyDigest := (bytes [161, 246, 127, 13, 46, 191, 216, 141, 26, 210, 79, 83, 142, 75, 109, 214, 76, 55, 99, 77, 196, 163, 68, 236, 255, 154, 75, 170, 19, 7, 141, 143]), rowCount := 5, registerEventCount := 9, ramEventCount := 2, digest := (bytes [192, 166, 215, 150, 69, 221, 227, 13, 124, 229, 59, 49, 152, 230, 204, 254, 8, 142, 239, 206, 83, 153, 202, 80, 97, 221, 228, 152, 221, 226, 220, 171]) }
    , linkageDigest := (bytes [92, 168, 14, 74, 17, 126, 147, 29, 154, 191, 9, 22, 3, 255, 140, 251, 202, 135, 56, 33, 27, 70, 127, 77, 77, 77, 53, 31, 246, 67, 155, 110])
    , selectedOpening := { claim := { registerReadsFamilyDigest := (bytes [117, 87, 193, 217, 226, 194, 99, 227, 114, 106, 145, 233, 112, 220, 177, 26, 188, 25, 251, 41, 128, 162, 5, 208, 86, 175, 143, 104, 145, 193, 205, 94]), registerWritesFamilyDigest := (bytes [185, 51, 63, 211, 114, 140, 159, 19, 206, 172, 35, 119, 251, 231, 40, 184, 66, 231, 144, 103, 240, 129, 172, 119, 210, 31, 39, 251, 200, 10, 239, 147]), ramEventsFamilyDigest := (bytes [18, 57, 34, 88, 168, 246, 181, 250, 193, 231, 230, 176, 242, 131, 217, 15, 250, 21, 129, 219, 38, 93, 67, 95, 132, 255, 54, 15, 4, 1, 49, 127]), twistLinksFamilyDigest := (bytes [161, 246, 127, 13, 46, 191, 216, 141, 26, 210, 79, 83, 142, 75, 109, 214, 76, 55, 99, 77, 196, 163, 68, 236, 255, 154, 75, 170, 19, 7, 141, 143]), registerReadCount := 6, registerWriteCount := 3, ramEventCount := 2, twistLinkCount := 5, ramReadCount := 1, ramWriteCount := 1, regMix := 14969386806236800168, ramMix := 15095568061922680811, points := { firstRead := (some { id := { object := { familyTag := 2, commitmentDigest := (bytes [117, 87, 193, 217, 226, 194, 99, 227, 114, 106, 145, 233, 112, 220, 177, 26, 188, 25, 251, 41, 128, 162, 5, 208, 86, 175, 143, 104, 145, 193, 205, 94]), layoutVersion := 1, digest := (bytes [133, 122, 76, 92, 184, 76, 89, 80, 54, 240, 218, 50, 79, 218, 243, 112, 166, 76, 13, 41, 245, 210, 140, 166, 79, 196, 127, 95, 156, 117, 251, 211]) }, logicalIndex := 0, digest := (bytes [8, 169, 58, 184, 142, 68, 53, 213, 206, 219, 85, 69, 153, 34, 198, 92, 234, 30, 23, 221, 100, 254, 92, 190, 35, 143, 219, 78, 152, 98, 89, 143]) }, valueDigest := (bytes [165, 2, 50, 180, 56, 84, 68, 13, 37, 136, 82, 191, 49, 42, 150, 67, 180, 45, 199, 251, 168, 91, 53, 39, 20, 9, 70, 46, 155, 135, 100, 116]), digest := (bytes [145, 69, 71, 192, 3, 5, 104, 167, 83, 235, 100, 86, 210, 47, 56, 165, 238, 111, 87, 214, 199, 152, 73, 173, 58, 173, 140, 79, 122, 228, 252, 137]) }), lastRead := (some { id := { object := { familyTag := 2, commitmentDigest := (bytes [117, 87, 193, 217, 226, 194, 99, 227, 114, 106, 145, 233, 112, 220, 177, 26, 188, 25, 251, 41, 128, 162, 5, 208, 86, 175, 143, 104, 145, 193, 205, 94]), layoutVersion := 1, digest := (bytes [133, 122, 76, 92, 184, 76, 89, 80, 54, 240, 218, 50, 79, 218, 243, 112, 166, 76, 13, 41, 245, 210, 140, 166, 79, 196, 127, 95, 156, 117, 251, 211]) }, logicalIndex := 5, digest := (bytes [255, 53, 224, 147, 197, 66, 41, 66, 205, 172, 56, 246, 246, 60, 72, 15, 60, 32, 201, 148, 251, 9, 113, 211, 222, 12, 236, 28, 97, 43, 212, 172]) }, valueDigest := (bytes [222, 146, 192, 5, 96, 154, 144, 95, 74, 132, 52, 85, 206, 218, 173, 26, 227, 145, 65, 25, 219, 138, 245, 119, 102, 52, 219, 61, 128, 63, 225, 0]), digest := (bytes [200, 168, 147, 138, 148, 110, 174, 95, 117, 222, 4, 90, 185, 57, 39, 241, 240, 234, 70, 186, 33, 152, 68, 70, 234, 194, 117, 44, 172, 6, 96, 172]) }), firstWrite := (some { id := { object := { familyTag := 3, commitmentDigest := (bytes [185, 51, 63, 211, 114, 140, 159, 19, 206, 172, 35, 119, 251, 231, 40, 184, 66, 231, 144, 103, 240, 129, 172, 119, 210, 31, 39, 251, 200, 10, 239, 147]), layoutVersion := 1, digest := (bytes [180, 214, 17, 4, 103, 147, 117, 160, 77, 235, 0, 218, 162, 103, 215, 244, 153, 104, 220, 111, 204, 239, 116, 246, 170, 91, 28, 99, 159, 48, 214, 229]) }, logicalIndex := 0, digest := (bytes [102, 25, 133, 146, 94, 213, 167, 111, 186, 31, 127, 78, 76, 10, 254, 164, 143, 12, 81, 113, 253, 210, 118, 2, 188, 152, 1, 54, 20, 230, 248, 122]) }, valueDigest := (bytes [5, 42, 199, 83, 99, 146, 243, 205, 229, 6, 247, 87, 180, 202, 145, 220, 239, 246, 190, 63, 131, 159, 221, 85, 160, 97, 47, 166, 147, 151, 248, 133]), digest := (bytes [117, 254, 207, 45, 227, 29, 23, 46, 222, 214, 196, 163, 129, 251, 144, 68, 75, 99, 118, 164, 229, 247, 135, 209, 116, 12, 192, 142, 143, 251, 3, 34]) }), lastWrite := (some { id := { object := { familyTag := 3, commitmentDigest := (bytes [185, 51, 63, 211, 114, 140, 159, 19, 206, 172, 35, 119, 251, 231, 40, 184, 66, 231, 144, 103, 240, 129, 172, 119, 210, 31, 39, 251, 200, 10, 239, 147]), layoutVersion := 1, digest := (bytes [180, 214, 17, 4, 103, 147, 117, 160, 77, 235, 0, 218, 162, 103, 215, 244, 153, 104, 220, 111, 204, 239, 116, 246, 170, 91, 28, 99, 159, 48, 214, 229]) }, logicalIndex := 2, digest := (bytes [43, 91, 168, 133, 75, 66, 238, 69, 198, 244, 169, 35, 202, 80, 101, 105, 195, 250, 193, 34, 197, 40, 72, 230, 72, 233, 153, 140, 98, 28, 216, 232]) }, valueDigest := (bytes [15, 123, 150, 80, 132, 80, 94, 179, 216, 21, 252, 4, 112, 217, 250, 169, 50, 7, 110, 176, 181, 234, 38, 80, 138, 68, 202, 238, 96, 146, 19, 217]), digest := (bytes [122, 86, 116, 148, 248, 35, 17, 109, 119, 247, 97, 53, 144, 146, 152, 147, 57, 210, 226, 11, 94, 128, 161, 1, 172, 99, 58, 125, 92, 27, 227, 88]) }), firstRam := (some { id := { object := { familyTag := 4, commitmentDigest := (bytes [18, 57, 34, 88, 168, 246, 181, 250, 193, 231, 230, 176, 242, 131, 217, 15, 250, 21, 129, 219, 38, 93, 67, 95, 132, 255, 54, 15, 4, 1, 49, 127]), layoutVersion := 1, digest := (bytes [218, 216, 11, 235, 196, 132, 106, 189, 63, 115, 249, 231, 17, 226, 50, 124, 25, 6, 39, 139, 143, 210, 226, 227, 129, 221, 75, 190, 142, 235, 154, 246]) }, logicalIndex := 0, digest := (bytes [224, 147, 76, 136, 109, 0, 56, 194, 218, 70, 107, 254, 209, 45, 218, 100, 119, 231, 96, 109, 18, 1, 211, 13, 213, 43, 193, 45, 206, 110, 23, 187]) }, valueDigest := (bytes [169, 220, 171, 96, 15, 183, 11, 235, 247, 199, 215, 168, 239, 167, 216, 243, 237, 106, 118, 158, 130, 205, 42, 157, 168, 13, 99, 120, 237, 148, 63, 93]), digest := (bytes [152, 16, 150, 157, 184, 94, 143, 4, 153, 253, 143, 189, 187, 198, 214, 0, 238, 174, 95, 64, 212, 2, 65, 244, 225, 50, 116, 227, 60, 83, 82, 52]) }), lastRam := (some { id := { object := { familyTag := 4, commitmentDigest := (bytes [18, 57, 34, 88, 168, 246, 181, 250, 193, 231, 230, 176, 242, 131, 217, 15, 250, 21, 129, 219, 38, 93, 67, 95, 132, 255, 54, 15, 4, 1, 49, 127]), layoutVersion := 1, digest := (bytes [218, 216, 11, 235, 196, 132, 106, 189, 63, 115, 249, 231, 17, 226, 50, 124, 25, 6, 39, 139, 143, 210, 226, 227, 129, 221, 75, 190, 142, 235, 154, 246]) }, logicalIndex := 1, digest := (bytes [2, 10, 83, 15, 207, 185, 130, 44, 42, 114, 122, 115, 98, 108, 108, 190, 67, 57, 61, 180, 16, 163, 101, 218, 129, 95, 71, 79, 68, 214, 113, 111]) }, valueDigest := (bytes [180, 80, 229, 56, 75, 188, 148, 164, 223, 204, 226, 196, 178, 102, 135, 3, 4, 140, 130, 1, 191, 56, 202, 39, 33, 183, 12, 180, 84, 195, 148, 15]), digest := (bytes [132, 128, 192, 233, 22, 236, 107, 55, 89, 19, 162, 4, 66, 87, 105, 254, 4, 208, 113, 68, 55, 122, 154, 147, 105, 7, 78, 101, 102, 168, 139, 148]) }), firstTwist := (some { id := { object := { familyTag := 5, commitmentDigest := (bytes [161, 246, 127, 13, 46, 191, 216, 141, 26, 210, 79, 83, 142, 75, 109, 214, 76, 55, 99, 77, 196, 163, 68, 236, 255, 154, 75, 170, 19, 7, 141, 143]), layoutVersion := 1, digest := (bytes [252, 54, 226, 65, 57, 189, 159, 189, 33, 157, 213, 64, 81, 215, 145, 90, 227, 94, 91, 12, 219, 173, 185, 182, 194, 80, 52, 84, 85, 123, 167, 139]) }, logicalIndex := 0, digest := (bytes [202, 111, 111, 239, 214, 211, 201, 98, 16, 230, 63, 18, 203, 4, 255, 240, 164, 109, 157, 9, 48, 159, 82, 102, 224, 245, 246, 166, 52, 100, 28, 242]) }, valueDigest := (bytes [56, 135, 107, 139, 170, 102, 129, 66, 201, 158, 76, 252, 160, 79, 76, 35, 237, 181, 194, 155, 225, 231, 24, 201, 237, 26, 147, 107, 4, 156, 184, 248]), digest := (bytes [219, 248, 242, 116, 100, 207, 107, 133, 19, 36, 164, 135, 58, 85, 134, 37, 55, 232, 102, 233, 42, 209, 60, 25, 169, 236, 45, 143, 58, 87, 34, 57]) }), lastTwist := (some { id := { object := { familyTag := 5, commitmentDigest := (bytes [161, 246, 127, 13, 46, 191, 216, 141, 26, 210, 79, 83, 142, 75, 109, 214, 76, 55, 99, 77, 196, 163, 68, 236, 255, 154, 75, 170, 19, 7, 141, 143]), layoutVersion := 1, digest := (bytes [252, 54, 226, 65, 57, 189, 159, 189, 33, 157, 213, 64, 81, 215, 145, 90, 227, 94, 91, 12, 219, 173, 185, 182, 194, 80, 52, 84, 85, 123, 167, 139]) }, logicalIndex := 4, digest := (bytes [102, 98, 89, 94, 7, 190, 114, 1, 203, 196, 110, 155, 176, 108, 212, 15, 27, 57, 182, 5, 95, 177, 199, 122, 53, 157, 150, 5, 29, 241, 210, 232]) }, valueDigest := (bytes [222, 14, 37, 177, 188, 230, 71, 93, 144, 22, 98, 93, 2, 239, 167, 13, 4, 68, 129, 81, 87, 184, 54, 32, 144, 210, 18, 143, 160, 134, 36, 170]), digest := (bytes [140, 194, 108, 81, 184, 21, 0, 97, 173, 249, 168, 225, 249, 250, 35, 83, 156, 9, 184, 94, 189, 204, 8, 237, 52, 76, 73, 100, 144, 85, 211, 195]) }) }, digest := (bytes [108, 84, 139, 5, 127, 142, 206, 114, 237, 252, 245, 22, 64, 136, 186, 227, 210, 29, 45, 113, 86, 216, 223, 168, 24, 159, 181, 84, 106, 200, 27, 178]) }, packaged := { statementDigest := (bytes [222, 123, 180, 83, 90, 39, 55, 249, 2, 116, 79, 62, 240, 239, 217, 96, 91, 196, 114, 139, 222, 89, 156, 252, 195, 165, 170, 39, 151, 87, 36, 95]), proofDigest := (bytes [91, 46, 18, 215, 242, 217, 210, 230, 142, 71, 37, 145, 237, 64, 176, 226, 246, 123, 191, 63, 25, 34, 145, 42, 170, 196, 145, 62, 160, 160, 51, 6]) }, digest := (bytes [56, 34, 142, 48, 251, 128, 250, 244, 34, 234, 192, 248, 31, 237, 223, 12, 81, 15, 138, 213, 43, 255, 60, 224, 41, 246, 0, 252, 173, 52, 150, 54]) }
    , digest := (bytes [54, 140, 44, 239, 98, 75, 42, 91, 38, 237, 216, 156, 182, 76, 190, 190, 34, 245, 183, 53, 18, 160, 5, 69, 192, 219, 28, 19, 206, 214, 106, 3])
  }

def stage3Continuity : List ContinuityEventView :=
  [{ stepIndex := 0, pc := 0, nextPc := 4, successorPc := (some 4), finalStep := false, continuityHolds := true }, { stepIndex := 1, pc := 4, nextPc := 8, successorPc := (some 8), finalStep := false, continuityHolds := true }, { stepIndex := 2, pc := 8, nextPc := 12, successorPc := (some 12), finalStep := false, continuityHolds := true }, { stepIndex := 3, pc := 12, nextPc := 16, successorPc := (some 16), finalStep := false, continuityHolds := true }, { stepIndex := 4, pc := 16, nextPc := 20, successorPc := none, finalStep := true, continuityHolds := true }]

def stage3 : Stage3ProofBundleView :=
  {
    continuity := stage3Continuity
    , halted := true
    , bridgeDigest := (bytes [108, 122, 228, 150, 225, 104, 207, 4, 223, 64, 63, 38, 40, 135, 54, 145, 245, 148, 210, 198, 252, 37, 140, 223, 104, 6, 11, 236, 117, 121, 222, 177])
    , semantics := { continuityDigest := (bytes [113, 144, 165, 117, 2, 23, 60, 214, 235, 214, 31, 246, 32, 212, 211, 7, 206, 201, 156, 63, 29, 37, 105, 63, 79, 95, 223, 52, 30, 184, 74, 89]), rootSemanticRowsDigest := (bytes [153, 17, 6, 156, 133, 45, 220, 58, 31, 234, 69, 204, 34, 220, 60, 107, 252, 186, 2, 43, 116, 98, 72, 1, 245, 199, 203, 223, 105, 139, 49, 205]), rowChunkRoutesDigest := (bytes [17, 91, 99, 15, 11, 236, 55, 95, 29, 64, 142, 221, 223, 108, 122, 237, 32, 185, 12, 250, 217, 143, 221, 95, 118, 207, 92, 60, 104, 225, 196, 181]), preparedStepBindingsDigest := (bytes [166, 17, 177, 48, 228, 204, 66, 244, 60, 90, 217, 53, 191, 14, 162, 45, 145, 148, 222, 0, 46, 175, 226, 102, 99, 230, 239, 139, 144, 108, 172, 195]), stage2TemporalDigest := (bytes [81, 241, 26, 85, 42, 93, 189, 168, 72, 43, 88, 224, 214, 188, 65, 109, 53, 79, 247, 245, 178, 112, 161, 171, 204, 178, 62, 19, 182, 192, 229, 81]), initialPc := 0, finalPc := 20, realRowCount := 5, firstRealStepIndex := 0, lastRealStepIndex := 4, digest := (bytes [152, 165, 31, 0, 243, 14, 174, 31, 234, 250, 106, 37, 23, 196, 98, 177, 52, 228, 47, 52, 223, 115, 209, 85, 192, 205, 186, 132, 67, 158, 233, 55]) }
    , linkageDigest := (bytes [84, 156, 68, 127, 233, 14, 250, 163, 112, 158, 36, 91, 81, 92, 131, 175, 214, 63, 75, 235, 188, 94, 129, 42, 232, 210, 162, 52, 33, 54, 8, 226])
    , selectedOpening := { claim := { continuityFamilyDigest := (bytes [180, 21, 202, 67, 212, 116, 149, 242, 73, 2, 254, 74, 208, 185, 115, 209, 229, 157, 227, 181, 78, 244, 25, 29, 82, 77, 170, 252, 145, 102, 124, 182]), continuityCount := 5, finalStepCount := 1, halted := true, allContinuityHold := true, continuityMix := 13169674182515960671, points := { firstContinuity := (some { id := { object := { familyTag := 6, commitmentDigest := (bytes [180, 21, 202, 67, 212, 116, 149, 242, 73, 2, 254, 74, 208, 185, 115, 209, 229, 157, 227, 181, 78, 244, 25, 29, 82, 77, 170, 252, 145, 102, 124, 182]), layoutVersion := 1, digest := (bytes [197, 249, 85, 212, 218, 101, 152, 186, 19, 30, 36, 185, 152, 165, 209, 83, 127, 197, 28, 107, 221, 36, 65, 234, 79, 144, 20, 55, 123, 91, 148, 38]) }, logicalIndex := 0, digest := (bytes [135, 2, 138, 56, 98, 95, 181, 59, 112, 48, 52, 204, 46, 180, 117, 79, 81, 155, 36, 255, 244, 98, 41, 249, 179, 137, 245, 2, 152, 230, 83, 35]) }, valueDigest := (bytes [7, 131, 85, 21, 57, 109, 53, 31, 137, 53, 98, 18, 170, 36, 28, 200, 149, 213, 171, 159, 119, 200, 36, 230, 30, 35, 30, 11, 252, 126, 240, 63]), digest := (bytes [225, 52, 168, 222, 40, 147, 187, 132, 92, 200, 35, 10, 97, 76, 58, 203, 54, 182, 172, 214, 174, 127, 114, 107, 246, 49, 116, 83, 102, 231, 50, 247]) }), lastContinuity := (some { id := { object := { familyTag := 6, commitmentDigest := (bytes [180, 21, 202, 67, 212, 116, 149, 242, 73, 2, 254, 74, 208, 185, 115, 209, 229, 157, 227, 181, 78, 244, 25, 29, 82, 77, 170, 252, 145, 102, 124, 182]), layoutVersion := 1, digest := (bytes [197, 249, 85, 212, 218, 101, 152, 186, 19, 30, 36, 185, 152, 165, 209, 83, 127, 197, 28, 107, 221, 36, 65, 234, 79, 144, 20, 55, 123, 91, 148, 38]) }, logicalIndex := 4, digest := (bytes [59, 120, 172, 250, 102, 117, 237, 222, 163, 236, 2, 151, 147, 71, 229, 87, 204, 46, 208, 175, 16, 115, 154, 231, 8, 218, 118, 159, 106, 155, 179, 177]) }, valueDigest := (bytes [78, 141, 235, 113, 13, 200, 242, 233, 5, 141, 141, 77, 19, 78, 184, 2, 187, 100, 140, 5, 110, 219, 176, 65, 169, 115, 213, 24, 209, 59, 174, 122]), digest := (bytes [32, 72, 38, 207, 217, 2, 6, 111, 100, 238, 67, 192, 170, 240, 177, 100, 84, 19, 190, 114, 176, 150, 214, 214, 239, 213, 82, 176, 88, 198, 114, 246]) }) }, digest := (bytes [161, 159, 148, 21, 219, 177, 252, 172, 152, 84, 86, 100, 122, 134, 136, 196, 123, 91, 238, 59, 76, 210, 234, 12, 29, 51, 174, 227, 30, 145, 14, 113]) }, packaged := { statementDigest := (bytes [167, 248, 104, 158, 150, 163, 81, 249, 83, 0, 73, 233, 134, 46, 144, 55, 146, 20, 145, 21, 30, 72, 214, 158, 123, 63, 158, 2, 50, 226, 203, 147]), proofDigest := (bytes [204, 122, 40, 108, 65, 104, 30, 46, 80, 216, 46, 243, 99, 164, 126, 107, 11, 220, 2, 147, 27, 122, 246, 184, 62, 125, 192, 128, 122, 224, 14, 161]) }, digest := (bytes [66, 161, 193, 68, 211, 225, 10, 45, 53, 141, 95, 57, 36, 143, 64, 49, 57, 6, 169, 248, 38, 115, 137, 21, 155, 24, 133, 221, 32, 34, 51, 249]) }
    , digest := (bytes [60, 245, 49, 53, 67, 39, 109, 170, 197, 36, 11, 51, 70, 17, 204, 182, 139, 166, 21, 35, 130, 164, 234, 252, 152, 160, 119, 227, 5, 28, 43, 221])
  }

def rootExecutionExecutionRows : List ExpandedRowView :=
  [{
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

def rootExecutionSemanticRows : List RootSemanticRowView :=
  [{ traceIndex := 0, values := [1, 0, 0, 4, 0, 0, 0, 0, 0, 5, 0, 5, 0, 5, 0, 4, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [195, 104, 190, 242, 104, 180, 234, 122, 108, 245, 168, 232, 122, 59, 5, 141, 148, 97, 161, 16, 201, 133, 162, 230, 49, 127, 153, 215, 226, 163, 192, 66]), digest := (bytes [6, 140, 16, 12, 199, 169, 215, 123, 74, 92, 71, 171, 180, 226, 130, 112, 18, 207, 109, 194, 34, 121, 220, 17, 87, 27, 107, 102, 161, 141, 105, 55]) }, { traceIndex := 1, values := [1, 4, 0, 8, 0, 5, 0, 5, 0, 10, 0, 0, 0, 10, 0, 8, 0, 0, 0, 0, 0, 0, 0, 2, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1], rowDigest := (bytes [157, 165, 194, 81, 152, 42, 159, 23, 210, 89, 100, 106, 227, 18, 208, 197, 172, 0, 81, 98, 152, 189, 14, 14, 179, 223, 236, 205, 210, 94, 71, 237]), digest := (bytes [46, 107, 142, 198, 171, 124, 227, 245, 122, 52, 108, 98, 216, 7, 57, 36, 106, 245, 131, 24, 235, 36, 95, 223, 133, 166, 203, 55, 187, 112, 99, 230]) }, { traceIndex := 2, values := [1, 8, 0, 12, 0, 4096, 0, 10, 0, 0, 0, 0, 0, 10, 0, 12, 0, 0, 0, 4096, 0, 10, 0, 0, 10, 2, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1], rowDigest := (bytes [24, 247, 194, 10, 163, 253, 229, 218, 141, 6, 180, 213, 10, 146, 218, 35, 10, 56, 237, 171, 68, 82, 3, 46, 80, 83, 10, 53, 213, 124, 60, 168]), digest := (bytes [114, 129, 131, 74, 6, 82, 112, 99, 130, 140, 240, 126, 7, 181, 134, 27, 48, 132, 17, 11, 158, 118, 129, 11, 90, 102, 74, 129, 20, 21, 40, 169]) }, { traceIndex := 3, values := [1, 12, 0, 16, 0, 4096, 0, 0, 0, 10, 0, 0, 0, 10, 0, 16, 0, 0, 0, 4096, 0, 10, 0, 3, 10, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1], rowDigest := (bytes [100, 127, 82, 232, 246, 27, 237, 12, 142, 253, 143, 72, 243, 191, 248, 244, 247, 131, 90, 156, 207, 114, 78, 35, 45, 55, 208, 131, 190, 83, 238, 203]), digest := (bytes [249, 240, 220, 82, 203, 121, 233, 155, 248, 89, 89, 146, 85, 164, 89, 222, 107, 17, 114, 170, 246, 118, 37, 17, 55, 160, 152, 107, 92, 45, 98, 25]) }, { traceIndex := 4, values := [1, 16, 0, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [247, 8, 91, 86, 174, 60, 198, 248, 80, 76, 136, 253, 192, 49, 138, 233, 64, 183, 153, 201, 60, 173, 121, 212, 113, 120, 175, 228, 9, 127, 13, 255]), digest := (bytes [240, 235, 255, 76, 153, 52, 106, 255, 177, 158, 252, 199, 149, 118, 183, 94, 220, 38, 144, 227, 121, 141, 204, 78, 177, 0, 122, 124, 105, 74, 208, 125]) }]

def rootExecutionPreparedBindings : List PreparedStepBindingView :=
  [{ traceIndex := 0, rowDigest := (bytes [195, 104, 190, 242, 104, 180, 234, 122, 108, 245, 168, 232, 122, 59, 5, 141, 148, 97, 161, 16, 201, 133, 162, 230, 49, 127, 153, 215, 226, 163, 192, 66]), rowOpeningDigest := (bytes [21, 76, 16, 225, 119, 225, 104, 218, 203, 54, 249, 87, 162, 148, 36, 96, 143, 247, 221, 93, 203, 152, 105, 157, 96, 209, 60, 199, 248, 165, 137, 99]), digest := (bytes [21, 175, 100, 171, 175, 91, 213, 179, 96, 169, 117, 230, 223, 52, 10, 73, 248, 8, 221, 2, 87, 30, 20, 63, 76, 181, 185, 91, 83, 60, 174, 36]) }, { traceIndex := 1, rowDigest := (bytes [157, 165, 194, 81, 152, 42, 159, 23, 210, 89, 100, 106, 227, 18, 208, 197, 172, 0, 81, 98, 152, 189, 14, 14, 179, 223, 236, 205, 210, 94, 71, 237]), rowOpeningDigest := (bytes [91, 15, 31, 20, 176, 135, 152, 116, 235, 231, 200, 129, 36, 54, 18, 131, 160, 96, 186, 177, 62, 242, 39, 88, 47, 163, 202, 96, 187, 28, 31, 106]), digest := (bytes [21, 161, 144, 5, 155, 148, 28, 104, 136, 253, 69, 12, 101, 254, 251, 98, 164, 95, 189, 157, 177, 229, 92, 191, 46, 203, 244, 57, 110, 0, 255, 145]) }, { traceIndex := 2, rowDigest := (bytes [24, 247, 194, 10, 163, 253, 229, 218, 141, 6, 180, 213, 10, 146, 218, 35, 10, 56, 237, 171, 68, 82, 3, 46, 80, 83, 10, 53, 213, 124, 60, 168]), rowOpeningDigest := (bytes [162, 34, 95, 218, 36, 161, 218, 90, 121, 153, 118, 147, 128, 138, 68, 179, 185, 227, 57, 188, 197, 217, 121, 152, 109, 92, 203, 124, 181, 106, 59, 192]), digest := (bytes [224, 246, 39, 32, 153, 51, 190, 211, 173, 171, 170, 224, 125, 123, 245, 218, 13, 172, 232, 157, 149, 114, 173, 36, 72, 184, 113, 67, 241, 161, 146, 246]) }, { traceIndex := 3, rowDigest := (bytes [100, 127, 82, 232, 246, 27, 237, 12, 142, 253, 143, 72, 243, 191, 248, 244, 247, 131, 90, 156, 207, 114, 78, 35, 45, 55, 208, 131, 190, 83, 238, 203]), rowOpeningDigest := (bytes [1, 212, 8, 136, 129, 25, 187, 249, 102, 86, 5, 1, 222, 120, 114, 119, 209, 184, 218, 217, 252, 254, 152, 69, 193, 230, 67, 197, 227, 111, 176, 246]), digest := (bytes [99, 41, 26, 72, 144, 78, 141, 120, 228, 52, 252, 189, 221, 16, 46, 107, 68, 165, 70, 47, 91, 76, 209, 18, 0, 38, 81, 28, 244, 94, 145, 116]) }, { traceIndex := 4, rowDigest := (bytes [247, 8, 91, 86, 174, 60, 198, 248, 80, 76, 136, 253, 192, 49, 138, 233, 64, 183, 153, 201, 60, 173, 121, 212, 113, 120, 175, 228, 9, 127, 13, 255]), rowOpeningDigest := (bytes [191, 86, 73, 89, 202, 171, 100, 227, 63, 148, 86, 216, 15, 140, 225, 129, 192, 7, 28, 191, 58, 145, 62, 86, 71, 244, 220, 148, 207, 179, 38, 151]), digest := (bytes [55, 215, 43, 161, 102, 58, 94, 235, 254, 110, 43, 252, 137, 128, 118, 79, 3, 90, 208, 135, 125, 233, 113, 110, 141, 69, 220, 22, 255, 129, 201, 119]) }]

def rootExecutionRowChunkRoutes : List RowChunkRouteView :=
  [{ logicalIndex := 0, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 0, digest := (bytes [138, 198, 109, 126, 144, 82, 221, 43, 248, 202, 137, 103, 62, 226, 249, 152, 163, 187, 1, 254, 36, 33, 59, 16, 64, 166, 202, 8, 219, 57, 240, 59]) }, { logicalIndex := 1, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 1, digest := (bytes [44, 177, 82, 41, 218, 60, 100, 208, 26, 31, 151, 113, 109, 148, 57, 12, 223, 21, 76, 221, 70, 245, 191, 105, 57, 199, 8, 128, 181, 145, 89, 99]) }, { logicalIndex := 2, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 2, digest := (bytes [252, 248, 65, 24, 81, 241, 150, 170, 250, 116, 222, 30, 134, 191, 78, 195, 104, 119, 225, 210, 243, 186, 212, 107, 183, 31, 243, 201, 101, 148, 32, 72]) }, { logicalIndex := 3, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 3, digest := (bytes [244, 11, 162, 13, 59, 43, 232, 47, 228, 2, 70, 126, 95, 10, 57, 40, 46, 107, 197, 81, 97, 39, 185, 163, 93, 60, 5, 66, 7, 231, 199, 134]) }, { logicalIndex := 4, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 4, digest := (bytes [98, 247, 204, 83, 252, 219, 248, 73, 49, 206, 229, 79, 169, 242, 28, 56, 7, 100, 18, 197, 133, 200, 133, 20, 161, 230, 126, 175, 98, 0, 158, 25]) }]

def rootExecutionRowLocalCcsAcceptance : List RootRowLocalCcsAcceptanceView :=
  [{ traceIndex := 0, logicalIndex := 0, rowDigest := (bytes [195, 104, 190, 242, 104, 180, 234, 122, 108, 245, 168, 232, 122, 59, 5, 141, 148, 97, 161, 16, 201, 133, 162, 230, 49, 127, 153, 215, 226, 163, 192, 66]), rowOpeningDigest := (bytes [21, 76, 16, 225, 119, 225, 104, 218, 203, 54, 249, 87, 162, 148, 36, 96, 143, 247, 221, 93, 203, 152, 105, 157, 96, 209, 60, 199, 248, 165, 137, 99]), preparedStepBindingDigest := (bytes [21, 175, 100, 171, 175, 91, 213, 179, 96, 169, 117, 230, 223, 52, 10, 73, 248, 8, 221, 2, 87, 30, 20, 63, 76, 181, 185, 91, 83, 60, 174, 36]), rowChunkRouteDigest := (bytes [138, 198, 109, 126, 144, 82, 221, 43, 248, 202, 137, 103, 62, 226, 249, 152, 163, 187, 1, 254, 36, 33, 59, 16, 64, 166, 202, 8, 219, 57, 240, 59]), publicStepDigest := (bytes [228, 239, 224, 148, 245, 165, 43, 100, 78, 15, 201, 239, 137, 197, 239, 181, 253, 198, 6, 162, 68, 45, 255, 5, 106, 30, 29, 231, 74, 184, 217, 210]), digest := (bytes [181, 183, 155, 97, 252, 228, 22, 13, 88, 227, 221, 220, 193, 4, 227, 89, 14, 126, 119, 205, 65, 232, 194, 5, 207, 136, 208, 8, 160, 214, 202, 162]) }, { traceIndex := 1, logicalIndex := 1, rowDigest := (bytes [157, 165, 194, 81, 152, 42, 159, 23, 210, 89, 100, 106, 227, 18, 208, 197, 172, 0, 81, 98, 152, 189, 14, 14, 179, 223, 236, 205, 210, 94, 71, 237]), rowOpeningDigest := (bytes [91, 15, 31, 20, 176, 135, 152, 116, 235, 231, 200, 129, 36, 54, 18, 131, 160, 96, 186, 177, 62, 242, 39, 88, 47, 163, 202, 96, 187, 28, 31, 106]), preparedStepBindingDigest := (bytes [21, 161, 144, 5, 155, 148, 28, 104, 136, 253, 69, 12, 101, 254, 251, 98, 164, 95, 189, 157, 177, 229, 92, 191, 46, 203, 244, 57, 110, 0, 255, 145]), rowChunkRouteDigest := (bytes [44, 177, 82, 41, 218, 60, 100, 208, 26, 31, 151, 113, 109, 148, 57, 12, 223, 21, 76, 221, 70, 245, 191, 105, 57, 199, 8, 128, 181, 145, 89, 99]), publicStepDigest := (bytes [140, 98, 64, 33, 114, 26, 129, 112, 126, 14, 225, 248, 135, 0, 144, 104, 128, 24, 77, 146, 190, 76, 72, 142, 173, 44, 183, 106, 91, 148, 240, 21]), digest := (bytes [158, 162, 146, 5, 193, 44, 58, 145, 76, 58, 156, 7, 142, 209, 6, 49, 249, 188, 83, 229, 40, 190, 251, 17, 111, 192, 237, 39, 167, 140, 125, 238]) }, { traceIndex := 2, logicalIndex := 2, rowDigest := (bytes [24, 247, 194, 10, 163, 253, 229, 218, 141, 6, 180, 213, 10, 146, 218, 35, 10, 56, 237, 171, 68, 82, 3, 46, 80, 83, 10, 53, 213, 124, 60, 168]), rowOpeningDigest := (bytes [162, 34, 95, 218, 36, 161, 218, 90, 121, 153, 118, 147, 128, 138, 68, 179, 185, 227, 57, 188, 197, 217, 121, 152, 109, 92, 203, 124, 181, 106, 59, 192]), preparedStepBindingDigest := (bytes [224, 246, 39, 32, 153, 51, 190, 211, 173, 171, 170, 224, 125, 123, 245, 218, 13, 172, 232, 157, 149, 114, 173, 36, 72, 184, 113, 67, 241, 161, 146, 246]), rowChunkRouteDigest := (bytes [252, 248, 65, 24, 81, 241, 150, 170, 250, 116, 222, 30, 134, 191, 78, 195, 104, 119, 225, 210, 243, 186, 212, 107, 183, 31, 243, 201, 101, 148, 32, 72]), publicStepDigest := (bytes [198, 0, 130, 167, 61, 211, 228, 189, 165, 141, 55, 143, 63, 90, 22, 43, 84, 18, 173, 4, 160, 126, 244, 75, 82, 254, 111, 131, 93, 134, 13, 44]), digest := (bytes [171, 93, 15, 91, 69, 247, 49, 12, 150, 251, 131, 37, 166, 254, 138, 190, 63, 118, 219, 113, 231, 100, 138, 26, 158, 154, 188, 229, 50, 159, 196, 67]) }, { traceIndex := 3, logicalIndex := 3, rowDigest := (bytes [100, 127, 82, 232, 246, 27, 237, 12, 142, 253, 143, 72, 243, 191, 248, 244, 247, 131, 90, 156, 207, 114, 78, 35, 45, 55, 208, 131, 190, 83, 238, 203]), rowOpeningDigest := (bytes [1, 212, 8, 136, 129, 25, 187, 249, 102, 86, 5, 1, 222, 120, 114, 119, 209, 184, 218, 217, 252, 254, 152, 69, 193, 230, 67, 197, 227, 111, 176, 246]), preparedStepBindingDigest := (bytes [99, 41, 26, 72, 144, 78, 141, 120, 228, 52, 252, 189, 221, 16, 46, 107, 68, 165, 70, 47, 91, 76, 209, 18, 0, 38, 81, 28, 244, 94, 145, 116]), rowChunkRouteDigest := (bytes [244, 11, 162, 13, 59, 43, 232, 47, 228, 2, 70, 126, 95, 10, 57, 40, 46, 107, 197, 81, 97, 39, 185, 163, 93, 60, 5, 66, 7, 231, 199, 134]), publicStepDigest := (bytes [22, 228, 0, 212, 123, 3, 38, 57, 169, 24, 188, 238, 235, 235, 93, 99, 86, 67, 84, 219, 230, 195, 138, 166, 106, 95, 98, 180, 198, 30, 122, 189]), digest := (bytes [29, 49, 153, 60, 67, 49, 149, 100, 187, 151, 77, 137, 156, 111, 250, 35, 119, 113, 141, 5, 86, 144, 40, 105, 115, 168, 50, 7, 133, 229, 35, 19]) }, { traceIndex := 4, logicalIndex := 4, rowDigest := (bytes [247, 8, 91, 86, 174, 60, 198, 248, 80, 76, 136, 253, 192, 49, 138, 233, 64, 183, 153, 201, 60, 173, 121, 212, 113, 120, 175, 228, 9, 127, 13, 255]), rowOpeningDigest := (bytes [191, 86, 73, 89, 202, 171, 100, 227, 63, 148, 86, 216, 15, 140, 225, 129, 192, 7, 28, 191, 58, 145, 62, 86, 71, 244, 220, 148, 207, 179, 38, 151]), preparedStepBindingDigest := (bytes [55, 215, 43, 161, 102, 58, 94, 235, 254, 110, 43, 252, 137, 128, 118, 79, 3, 90, 208, 135, 125, 233, 113, 110, 141, 69, 220, 22, 255, 129, 201, 119]), rowChunkRouteDigest := (bytes [98, 247, 204, 83, 252, 219, 248, 73, 49, 206, 229, 79, 169, 242, 28, 56, 7, 100, 18, 197, 133, 200, 133, 20, 161, 230, 126, 175, 98, 0, 158, 25]), publicStepDigest := (bytes [72, 142, 192, 218, 173, 197, 55, 221, 78, 31, 126, 194, 22, 139, 72, 204, 128, 208, 103, 242, 122, 221, 175, 246, 50, 244, 221, 89, 210, 23, 111, 183]), digest := (bytes [200, 226, 226, 39, 177, 225, 229, 14, 84, 202, 188, 134, 67, 166, 25, 92, 211, 223, 189, 76, 113, 176, 61, 32, 8, 90, 50, 135, 44, 138, 126, 10]) }]

def rootExecutionExecutionSemanticsRefinement : List RootExecutionSemanticsRefinementView :=
  [{ traceIndex := 0, logicalIndex := 0, semanticRowDigest := (bytes [6, 140, 16, 12, 199, 169, 215, 123, 74, 92, 71, 171, 180, 226, 130, 112, 18, 207, 109, 194, 34, 121, 220, 17, 87, 27, 107, 102, 161, 141, 105, 55]), rowLocalCcsAcceptanceDigest := (bytes [181, 183, 155, 97, 252, 228, 22, 13, 88, 227, 221, 220, 193, 4, 227, 89, 14, 126, 119, 205, 65, 232, 194, 5, 207, 136, 208, 8, 160, 214, 202, 162]), preparedStepBindingDigest := (bytes [21, 175, 100, 171, 175, 91, 213, 179, 96, 169, 117, 230, 223, 52, 10, 73, 248, 8, 221, 2, 87, 30, 20, 63, 76, 181, 185, 91, 83, 60, 174, 36]), publicStepDigest := (bytes [228, 239, 224, 148, 245, 165, 43, 100, 78, 15, 201, 239, 137, 197, 239, 181, 253, 198, 6, 162, 68, 45, 255, 5, 106, 30, 29, 231, 74, 184, 217, 210]), digest := (bytes [4, 174, 192, 118, 23, 238, 2, 127, 213, 165, 86, 91, 254, 116, 137, 78, 204, 70, 175, 167, 100, 249, 2, 254, 91, 157, 205, 75, 180, 151, 97, 155]) }, { traceIndex := 1, logicalIndex := 1, semanticRowDigest := (bytes [46, 107, 142, 198, 171, 124, 227, 245, 122, 52, 108, 98, 216, 7, 57, 36, 106, 245, 131, 24, 235, 36, 95, 223, 133, 166, 203, 55, 187, 112, 99, 230]), rowLocalCcsAcceptanceDigest := (bytes [158, 162, 146, 5, 193, 44, 58, 145, 76, 58, 156, 7, 142, 209, 6, 49, 249, 188, 83, 229, 40, 190, 251, 17, 111, 192, 237, 39, 167, 140, 125, 238]), preparedStepBindingDigest := (bytes [21, 161, 144, 5, 155, 148, 28, 104, 136, 253, 69, 12, 101, 254, 251, 98, 164, 95, 189, 157, 177, 229, 92, 191, 46, 203, 244, 57, 110, 0, 255, 145]), publicStepDigest := (bytes [140, 98, 64, 33, 114, 26, 129, 112, 126, 14, 225, 248, 135, 0, 144, 104, 128, 24, 77, 146, 190, 76, 72, 142, 173, 44, 183, 106, 91, 148, 240, 21]), digest := (bytes [247, 135, 90, 112, 238, 103, 227, 26, 62, 19, 0, 115, 14, 172, 146, 193, 160, 90, 235, 45, 90, 174, 36, 214, 82, 194, 200, 95, 234, 152, 148, 147]) }, { traceIndex := 2, logicalIndex := 2, semanticRowDigest := (bytes [114, 129, 131, 74, 6, 82, 112, 99, 130, 140, 240, 126, 7, 181, 134, 27, 48, 132, 17, 11, 158, 118, 129, 11, 90, 102, 74, 129, 20, 21, 40, 169]), rowLocalCcsAcceptanceDigest := (bytes [171, 93, 15, 91, 69, 247, 49, 12, 150, 251, 131, 37, 166, 254, 138, 190, 63, 118, 219, 113, 231, 100, 138, 26, 158, 154, 188, 229, 50, 159, 196, 67]), preparedStepBindingDigest := (bytes [224, 246, 39, 32, 153, 51, 190, 211, 173, 171, 170, 224, 125, 123, 245, 218, 13, 172, 232, 157, 149, 114, 173, 36, 72, 184, 113, 67, 241, 161, 146, 246]), publicStepDigest := (bytes [198, 0, 130, 167, 61, 211, 228, 189, 165, 141, 55, 143, 63, 90, 22, 43, 84, 18, 173, 4, 160, 126, 244, 75, 82, 254, 111, 131, 93, 134, 13, 44]), digest := (bytes [73, 29, 58, 85, 237, 24, 133, 5, 56, 101, 137, 95, 8, 115, 215, 234, 247, 93, 141, 113, 139, 255, 75, 7, 165, 58, 162, 44, 74, 134, 204, 247]) }, { traceIndex := 3, logicalIndex := 3, semanticRowDigest := (bytes [249, 240, 220, 82, 203, 121, 233, 155, 248, 89, 89, 146, 85, 164, 89, 222, 107, 17, 114, 170, 246, 118, 37, 17, 55, 160, 152, 107, 92, 45, 98, 25]), rowLocalCcsAcceptanceDigest := (bytes [29, 49, 153, 60, 67, 49, 149, 100, 187, 151, 77, 137, 156, 111, 250, 35, 119, 113, 141, 5, 86, 144, 40, 105, 115, 168, 50, 7, 133, 229, 35, 19]), preparedStepBindingDigest := (bytes [99, 41, 26, 72, 144, 78, 141, 120, 228, 52, 252, 189, 221, 16, 46, 107, 68, 165, 70, 47, 91, 76, 209, 18, 0, 38, 81, 28, 244, 94, 145, 116]), publicStepDigest := (bytes [22, 228, 0, 212, 123, 3, 38, 57, 169, 24, 188, 238, 235, 235, 93, 99, 86, 67, 84, 219, 230, 195, 138, 166, 106, 95, 98, 180, 198, 30, 122, 189]), digest := (bytes [146, 180, 177, 14, 57, 238, 113, 27, 69, 246, 252, 80, 104, 99, 101, 85, 153, 110, 115, 219, 221, 138, 104, 189, 37, 235, 169, 212, 155, 2, 126, 107]) }, { traceIndex := 4, logicalIndex := 4, semanticRowDigest := (bytes [240, 235, 255, 76, 153, 52, 106, 255, 177, 158, 252, 199, 149, 118, 183, 94, 220, 38, 144, 227, 121, 141, 204, 78, 177, 0, 122, 124, 105, 74, 208, 125]), rowLocalCcsAcceptanceDigest := (bytes [200, 226, 226, 39, 177, 225, 229, 14, 84, 202, 188, 134, 67, 166, 25, 92, 211, 223, 189, 76, 113, 176, 61, 32, 8, 90, 50, 135, 44, 138, 126, 10]), preparedStepBindingDigest := (bytes [55, 215, 43, 161, 102, 58, 94, 235, 254, 110, 43, 252, 137, 128, 118, 79, 3, 90, 208, 135, 125, 233, 113, 110, 141, 69, 220, 22, 255, 129, 201, 119]), publicStepDigest := (bytes [72, 142, 192, 218, 173, 197, 55, 221, 78, 31, 126, 194, 22, 139, 72, 204, 128, 208, 103, 242, 122, 221, 175, 246, 50, 244, 221, 89, 210, 23, 111, 183]), digest := (bytes [253, 123, 91, 238, 9, 5, 43, 62, 117, 38, 105, 100, 25, 44, 154, 30, 74, 204, 179, 14, 121, 54, 154, 239, 145, 29, 97, 120, 170, 217, 134, 17]) }]

def rootExecution : RootExecutionBundleView :=
  {
    executionRows := rootExecutionExecutionRows
    , semanticRows := rootExecutionSemanticRows
    , semanticRowsDigest := (bytes [153, 17, 6, 156, 133, 45, 220, 58, 31, 234, 69, 204, 34, 220, 60, 107, 252, 186, 2, 43, 116, 98, 72, 1, 245, 199, 203, 223, 105, 139, 49, 205])
    , preparedStepBindings := { bindings := rootExecutionPreparedBindings, bindingCount := 5, firstBindingDigest := (some (bytes [21, 175, 100, 171, 175, 91, 213, 179, 96, 169, 117, 230, 223, 52, 10, 73, 248, 8, 221, 2, 87, 30, 20, 63, 76, 181, 185, 91, 83, 60, 174, 36])), lastBindingDigest := (some (bytes [55, 215, 43, 161, 102, 58, 94, 235, 254, 110, 43, 252, 137, 128, 118, 79, 3, 90, 208, 135, 125, 233, 113, 110, 141, 69, 220, 22, 255, 129, 201, 119])), digest := (bytes [166, 17, 177, 48, 228, 204, 66, 244, 60, 90, 217, 53, 191, 14, 162, 45, 145, 148, 222, 0, 46, 175, 226, 102, 99, 230, 239, 139, 144, 108, 172, 195]) }
    , rowChunkRoutes := rootExecutionRowChunkRoutes
    , rowChunkRoutesDigest := (bytes [17, 91, 99, 15, 11, 236, 55, 95, 29, 64, 142, 221, 223, 108, 122, 237, 32, 185, 12, 250, 217, 143, 221, 95, 118, 207, 92, 60, 104, 225, 196, 181])
    , rowLocalCcsAcceptance := { acceptances := rootExecutionRowLocalCcsAcceptance, acceptanceCount := 5, firstAcceptanceDigest := (some (bytes [181, 183, 155, 97, 252, 228, 22, 13, 88, 227, 221, 220, 193, 4, 227, 89, 14, 126, 119, 205, 65, 232, 194, 5, 207, 136, 208, 8, 160, 214, 202, 162])), lastAcceptanceDigest := (some (bytes [200, 226, 226, 39, 177, 225, 229, 14, 84, 202, 188, 134, 67, 166, 25, 92, 211, 223, 189, 76, 113, 176, 61, 32, 8, 90, 50, 135, 44, 138, 126, 10])), digest := (bytes [89, 119, 174, 72, 228, 253, 233, 10, 93, 3, 184, 97, 32, 255, 40, 168, 135, 165, 241, 214, 182, 191, 30, 120, 69, 101, 182, 122, 142, 189, 33, 228]) }
    , executionSemanticsRefinement := { refinements := rootExecutionExecutionSemanticsRefinement, refinementCount := 5, firstRefinementDigest := (some (bytes [4, 174, 192, 118, 23, 238, 2, 127, 213, 165, 86, 91, 254, 116, 137, 78, 204, 70, 175, 167, 100, 249, 2, 254, 91, 157, 205, 75, 180, 151, 97, 155])), lastRefinementDigest := (some (bytes [253, 123, 91, 238, 9, 5, 43, 62, 117, 38, 105, 100, 25, 44, 154, 30, 74, 204, 179, 14, 121, 54, 154, 239, 145, 29, 97, 120, 170, 217, 134, 17])), digest := (bytes [213, 192, 4, 146, 152, 56, 229, 5, 204, 155, 7, 114, 114, 6, 150, 85, 224, 189, 16, 201, 232, 27, 172, 164, 252, 127, 100, 146, 101, 139, 50, 242]) }
    , familyDigest := (bytes [148, 205, 89, 58, 104, 78, 64, 182, 143, 33, 124, 5, 186, 221, 99, 123, 123, 22, 87, 140, 176, 14, 0, 111, 30, 232, 141, 48, 17, 212, 190, 140])
    , digest := (bytes [216, 237, 150, 106, 84, 77, 236, 108, 93, 110, 193, 196, 99, 238, 84, 145, 16, 173, 15, 2, 27, 92, 117, 50, 254, 191, 20, 24, 248, 63, 120, 28])
  }

def kernelOpeningBundle : SimpleKernelOpeningBundleView :=
  {
    claim := { bindings := { stageClaimBundleDigest := (bytes [249, 135, 40, 152, 53, 237, 52, 34, 138, 201, 96, 112, 80, 75, 48, 252, 14, 5, 187, 32, 125, 220, 13, 123, 75, 99, 226, 55, 175, 231, 248, 99]), stagePackageBundleDigest := (bytes [249, 96, 16, 147, 144, 108, 179, 83, 216, 231, 106, 75, 166, 134, 154, 151, 57, 69, 75, 135, 129, 13, 231, 24, 180, 177, 200, 61, 70, 45, 236, 242]), stage1PackageDigest := (bytes [23, 204, 19, 237, 74, 72, 248, 248, 24, 243, 20, 63, 17, 17, 199, 2, 200, 236, 224, 206, 206, 169, 156, 126, 127, 221, 39, 197, 210, 120, 226, 132]), stage2PackageDigest := (bytes [56, 34, 142, 48, 251, 128, 250, 244, 34, 234, 192, 248, 31, 237, 223, 12, 81, 15, 138, 213, 43, 255, 60, 224, 41, 246, 0, 252, 173, 52, 150, 54]), stage3PackageDigest := (bytes [66, 161, 193, 68, 211, 225, 10, 45, 53, 141, 95, 57, 36, 143, 64, 49, 57, 6, 169, 248, 38, 115, 137, 21, 155, 24, 133, 221, 32, 34, 51, 249]), preparedStepBindingsDigest := (bytes [166, 17, 177, 48, 228, 204, 66, 244, 60, 90, 217, 53, 191, 14, 162, 45, 145, 148, 222, 0, 46, 175, 226, 102, 99, 230, 239, 139, 144, 108, 172, 195]), bindingCount := 5, stage1RowCount := 5, stage2RegisterReadCount := 6, stage2RegisterWriteCount := 3, stage2RamEventCount := 2, stage3ContinuityCount := 5, points := { firstBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [166, 17, 177, 48, 228, 204, 66, 244, 60, 90, 217, 53, 191, 14, 162, 45, 145, 148, 222, 0, 46, 175, 226, 102, 99, 230, 239, 139, 144, 108, 172, 195]), layoutVersion := 1, digest := (bytes [137, 169, 227, 76, 117, 221, 243, 119, 186, 132, 139, 11, 98, 211, 140, 196, 228, 136, 82, 196, 14, 110, 219, 117, 131, 175, 46, 152, 71, 154, 248, 68]) }, logicalIndex := 0, digest := (bytes [104, 143, 5, 53, 16, 116, 103, 82, 190, 240, 205, 172, 46, 84, 49, 246, 52, 165, 225, 124, 166, 145, 9, 248, 141, 251, 36, 118, 6, 63, 56, 102]) }, valueDigest := (bytes [21, 175, 100, 171, 175, 91, 213, 179, 96, 169, 117, 230, 223, 52, 10, 73, 248, 8, 221, 2, 87, 30, 20, 63, 76, 181, 185, 91, 83, 60, 174, 36]), digest := (bytes [169, 162, 179, 87, 99, 132, 224, 131, 49, 227, 176, 83, 178, 209, 139, 179, 252, 113, 57, 62, 230, 44, 197, 181, 19, 110, 235, 165, 233, 170, 241, 197]) }), lastBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [166, 17, 177, 48, 228, 204, 66, 244, 60, 90, 217, 53, 191, 14, 162, 45, 145, 148, 222, 0, 46, 175, 226, 102, 99, 230, 239, 139, 144, 108, 172, 195]), layoutVersion := 1, digest := (bytes [137, 169, 227, 76, 117, 221, 243, 119, 186, 132, 139, 11, 98, 211, 140, 196, 228, 136, 82, 196, 14, 110, 219, 117, 131, 175, 46, 152, 71, 154, 248, 68]) }, logicalIndex := 4, digest := (bytes [55, 129, 3, 240, 211, 10, 93, 0, 226, 102, 63, 31, 4, 226, 179, 23, 68, 82, 245, 48, 223, 4, 172, 178, 40, 194, 172, 162, 218, 218, 212, 50]) }, valueDigest := (bytes [55, 215, 43, 161, 102, 58, 94, 235, 254, 110, 43, 252, 137, 128, 118, 79, 3, 90, 208, 135, 125, 233, 113, 110, 141, 69, 220, 22, 255, 129, 201, 119]), digest := (bytes [196, 59, 88, 94, 28, 1, 12, 36, 228, 207, 240, 202, 216, 103, 51, 160, 95, 122, 95, 203, 9, 24, 182, 123, 240, 143, 152, 67, 170, 248, 62, 45]) }) }, digest := (bytes [204, 159, 171, 66, 175, 207, 138, 201, 109, 245, 13, 107, 187, 92, 212, 81, 128, 109, 198, 20, 52, 80, 240, 237, 42, 92, 250, 220, 215, 224, 136, 212]) }, preparedSteps := { executionDigest := (bytes [254, 167, 237, 35, 229, 145, 124, 131, 169, 247, 185, 244, 68, 31, 227, 147, 217, 37, 96, 244, 224, 23, 123, 54, 206, 154, 166, 72, 40, 193, 48, 159]), finalStateDigest := (bytes [40, 203, 41, 62, 45, 52, 38, 20, 4, 174, 242, 202, 246, 67, 233, 128, 197, 240, 97, 4, 68, 33, 142, 222, 96, 232, 104, 62, 196, 10, 224, 135]), transcriptFinalDigest := (bytes [21, 202, 184, 214, 78, 19, 29, 42, 160, 18, 93, 226, 73, 239, 62, 104, 126, 173, 112, 69, 28, 129, 201, 67, 243, 158, 176, 17, 240, 232, 159, 165]), preparedStepCount := 5, finalPc := 20, halted := true, points := { firstPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [116, 251, 70, 72, 221, 18, 150, 52, 56, 144, 53, 94, 3, 160, 21, 161, 1, 65, 160, 196, 197, 83, 136, 169, 243, 157, 187, 95, 225, 79, 192, 55]), layoutVersion := 3, digest := (bytes [190, 153, 87, 41, 90, 212, 192, 33, 101, 235, 172, 224, 206, 214, 250, 84, 240, 24, 180, 142, 135, 2, 21, 234, 179, 184, 255, 106, 239, 168, 181, 38]) }, logicalIndex := 0, digest := (bytes [85, 138, 25, 175, 106, 163, 9, 238, 123, 168, 154, 149, 39, 92, 47, 219, 123, 192, 182, 193, 224, 112, 108, 4, 2, 97, 154, 54, 47, 99, 182, 254]) }, valueDigest := (bytes [195, 104, 190, 242, 104, 180, 234, 122, 108, 245, 168, 232, 122, 59, 5, 141, 148, 97, 161, 16, 201, 133, 162, 230, 49, 127, 153, 215, 226, 163, 192, 66]), digest := (bytes [15, 172, 155, 22, 227, 145, 252, 231, 88, 127, 85, 247, 69, 104, 141, 208, 221, 173, 84, 44, 69, 35, 13, 90, 97, 115, 91, 47, 220, 8, 13, 248]) }), lastPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [116, 251, 70, 72, 221, 18, 150, 52, 56, 144, 53, 94, 3, 160, 21, 161, 1, 65, 160, 196, 197, 83, 136, 169, 243, 157, 187, 95, 225, 79, 192, 55]), layoutVersion := 3, digest := (bytes [190, 153, 87, 41, 90, 212, 192, 33, 101, 235, 172, 224, 206, 214, 250, 84, 240, 24, 180, 142, 135, 2, 21, 234, 179, 184, 255, 106, 239, 168, 181, 38]) }, logicalIndex := 4, digest := (bytes [69, 78, 220, 18, 192, 56, 35, 154, 217, 122, 36, 41, 100, 181, 92, 125, 242, 57, 252, 183, 199, 205, 155, 159, 254, 251, 228, 186, 123, 83, 47, 103]) }, valueDigest := (bytes [247, 8, 91, 86, 174, 60, 198, 248, 80, 76, 136, 253, 192, 49, 138, 233, 64, 183, 153, 201, 60, 173, 121, 212, 113, 120, 175, 228, 9, 127, 13, 255]), digest := (bytes [156, 67, 4, 130, 236, 171, 74, 254, 227, 134, 5, 49, 195, 32, 22, 209, 194, 114, 73, 201, 235, 241, 120, 182, 151, 14, 54, 141, 95, 75, 74, 233]) }) }, digest := (bytes [176, 209, 63, 148, 197, 117, 232, 222, 237, 212, 80, 119, 13, 138, 210, 171, 113, 8, 212, 140, 116, 6, 82, 194, 169, 31, 212, 229, 185, 171, 51, 162]) }, digest := (bytes [180, 149, 238, 246, 28, 28, 32, 196, 207, 36, 191, 185, 127, 28, 57, 41, 246, 159, 106, 122, 123, 241, 234, 87, 235, 67, 75, 122, 28, 162, 250, 112]) }
    , bindings := { claim := { stageClaimBundleDigest := (bytes [249, 135, 40, 152, 53, 237, 52, 34, 138, 201, 96, 112, 80, 75, 48, 252, 14, 5, 187, 32, 125, 220, 13, 123, 75, 99, 226, 55, 175, 231, 248, 99]), stagePackageBundleDigest := (bytes [249, 96, 16, 147, 144, 108, 179, 83, 216, 231, 106, 75, 166, 134, 154, 151, 57, 69, 75, 135, 129, 13, 231, 24, 180, 177, 200, 61, 70, 45, 236, 242]), stage1PackageDigest := (bytes [23, 204, 19, 237, 74, 72, 248, 248, 24, 243, 20, 63, 17, 17, 199, 2, 200, 236, 224, 206, 206, 169, 156, 126, 127, 221, 39, 197, 210, 120, 226, 132]), stage2PackageDigest := (bytes [56, 34, 142, 48, 251, 128, 250, 244, 34, 234, 192, 248, 31, 237, 223, 12, 81, 15, 138, 213, 43, 255, 60, 224, 41, 246, 0, 252, 173, 52, 150, 54]), stage3PackageDigest := (bytes [66, 161, 193, 68, 211, 225, 10, 45, 53, 141, 95, 57, 36, 143, 64, 49, 57, 6, 169, 248, 38, 115, 137, 21, 155, 24, 133, 221, 32, 34, 51, 249]), preparedStepBindingsDigest := (bytes [166, 17, 177, 48, 228, 204, 66, 244, 60, 90, 217, 53, 191, 14, 162, 45, 145, 148, 222, 0, 46, 175, 226, 102, 99, 230, 239, 139, 144, 108, 172, 195]), bindingCount := 5, stage1RowCount := 5, stage2RegisterReadCount := 6, stage2RegisterWriteCount := 3, stage2RamEventCount := 2, stage3ContinuityCount := 5, points := { firstBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [166, 17, 177, 48, 228, 204, 66, 244, 60, 90, 217, 53, 191, 14, 162, 45, 145, 148, 222, 0, 46, 175, 226, 102, 99, 230, 239, 139, 144, 108, 172, 195]), layoutVersion := 1, digest := (bytes [137, 169, 227, 76, 117, 221, 243, 119, 186, 132, 139, 11, 98, 211, 140, 196, 228, 136, 82, 196, 14, 110, 219, 117, 131, 175, 46, 152, 71, 154, 248, 68]) }, logicalIndex := 0, digest := (bytes [104, 143, 5, 53, 16, 116, 103, 82, 190, 240, 205, 172, 46, 84, 49, 246, 52, 165, 225, 124, 166, 145, 9, 248, 141, 251, 36, 118, 6, 63, 56, 102]) }, valueDigest := (bytes [21, 175, 100, 171, 175, 91, 213, 179, 96, 169, 117, 230, 223, 52, 10, 73, 248, 8, 221, 2, 87, 30, 20, 63, 76, 181, 185, 91, 83, 60, 174, 36]), digest := (bytes [169, 162, 179, 87, 99, 132, 224, 131, 49, 227, 176, 83, 178, 209, 139, 179, 252, 113, 57, 62, 230, 44, 197, 181, 19, 110, 235, 165, 233, 170, 241, 197]) }), lastBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [166, 17, 177, 48, 228, 204, 66, 244, 60, 90, 217, 53, 191, 14, 162, 45, 145, 148, 222, 0, 46, 175, 226, 102, 99, 230, 239, 139, 144, 108, 172, 195]), layoutVersion := 1, digest := (bytes [137, 169, 227, 76, 117, 221, 243, 119, 186, 132, 139, 11, 98, 211, 140, 196, 228, 136, 82, 196, 14, 110, 219, 117, 131, 175, 46, 152, 71, 154, 248, 68]) }, logicalIndex := 4, digest := (bytes [55, 129, 3, 240, 211, 10, 93, 0, 226, 102, 63, 31, 4, 226, 179, 23, 68, 82, 245, 48, 223, 4, 172, 178, 40, 194, 172, 162, 218, 218, 212, 50]) }, valueDigest := (bytes [55, 215, 43, 161, 102, 58, 94, 235, 254, 110, 43, 252, 137, 128, 118, 79, 3, 90, 208, 135, 125, 233, 113, 110, 141, 69, 220, 22, 255, 129, 201, 119]), digest := (bytes [196, 59, 88, 94, 28, 1, 12, 36, 228, 207, 240, 202, 216, 103, 51, 160, 95, 122, 95, 203, 9, 24, 182, 123, 240, 143, 152, 67, 170, 248, 62, 45]) }) }, digest := (bytes [204, 159, 171, 66, 175, 207, 138, 201, 109, 245, 13, 107, 187, 92, 212, 81, 128, 109, 198, 20, 52, 80, 240, 237, 42, 92, 250, 220, 215, 224, 136, 212]) }, packaged := { statementDigest := (bytes [213, 46, 36, 198, 119, 49, 42, 228, 183, 72, 15, 149, 254, 141, 118, 72, 118, 16, 173, 45, 240, 176, 52, 243, 236, 31, 70, 115, 116, 64, 53, 59]), proofDigest := (bytes [168, 161, 21, 69, 134, 216, 74, 146, 105, 73, 240, 207, 4, 72, 9, 157, 89, 78, 217, 137, 92, 197, 52, 175, 21, 109, 72, 167, 93, 201, 163, 175]) }, digest := (bytes [91, 180, 186, 199, 223, 133, 98, 216, 152, 215, 124, 217, 38, 97, 125, 89, 193, 167, 61, 206, 200, 46, 217, 229, 115, 254, 112, 23, 77, 200, 159, 0]) }
    , preparedSteps := { claim := { executionDigest := (bytes [254, 167, 237, 35, 229, 145, 124, 131, 169, 247, 185, 244, 68, 31, 227, 147, 217, 37, 96, 244, 224, 23, 123, 54, 206, 154, 166, 72, 40, 193, 48, 159]), finalStateDigest := (bytes [40, 203, 41, 62, 45, 52, 38, 20, 4, 174, 242, 202, 246, 67, 233, 128, 197, 240, 97, 4, 68, 33, 142, 222, 96, 232, 104, 62, 196, 10, 224, 135]), transcriptFinalDigest := (bytes [21, 202, 184, 214, 78, 19, 29, 42, 160, 18, 93, 226, 73, 239, 62, 104, 126, 173, 112, 69, 28, 129, 201, 67, 243, 158, 176, 17, 240, 232, 159, 165]), preparedStepCount := 5, finalPc := 20, halted := true, points := { firstPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [116, 251, 70, 72, 221, 18, 150, 52, 56, 144, 53, 94, 3, 160, 21, 161, 1, 65, 160, 196, 197, 83, 136, 169, 243, 157, 187, 95, 225, 79, 192, 55]), layoutVersion := 3, digest := (bytes [190, 153, 87, 41, 90, 212, 192, 33, 101, 235, 172, 224, 206, 214, 250, 84, 240, 24, 180, 142, 135, 2, 21, 234, 179, 184, 255, 106, 239, 168, 181, 38]) }, logicalIndex := 0, digest := (bytes [85, 138, 25, 175, 106, 163, 9, 238, 123, 168, 154, 149, 39, 92, 47, 219, 123, 192, 182, 193, 224, 112, 108, 4, 2, 97, 154, 54, 47, 99, 182, 254]) }, valueDigest := (bytes [195, 104, 190, 242, 104, 180, 234, 122, 108, 245, 168, 232, 122, 59, 5, 141, 148, 97, 161, 16, 201, 133, 162, 230, 49, 127, 153, 215, 226, 163, 192, 66]), digest := (bytes [15, 172, 155, 22, 227, 145, 252, 231, 88, 127, 85, 247, 69, 104, 141, 208, 221, 173, 84, 44, 69, 35, 13, 90, 97, 115, 91, 47, 220, 8, 13, 248]) }), lastPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [116, 251, 70, 72, 221, 18, 150, 52, 56, 144, 53, 94, 3, 160, 21, 161, 1, 65, 160, 196, 197, 83, 136, 169, 243, 157, 187, 95, 225, 79, 192, 55]), layoutVersion := 3, digest := (bytes [190, 153, 87, 41, 90, 212, 192, 33, 101, 235, 172, 224, 206, 214, 250, 84, 240, 24, 180, 142, 135, 2, 21, 234, 179, 184, 255, 106, 239, 168, 181, 38]) }, logicalIndex := 4, digest := (bytes [69, 78, 220, 18, 192, 56, 35, 154, 217, 122, 36, 41, 100, 181, 92, 125, 242, 57, 252, 183, 199, 205, 155, 159, 254, 251, 228, 186, 123, 83, 47, 103]) }, valueDigest := (bytes [247, 8, 91, 86, 174, 60, 198, 248, 80, 76, 136, 253, 192, 49, 138, 233, 64, 183, 153, 201, 60, 173, 121, 212, 113, 120, 175, 228, 9, 127, 13, 255]), digest := (bytes [156, 67, 4, 130, 236, 171, 74, 254, 227, 134, 5, 49, 195, 32, 22, 209, 194, 114, 73, 201, 235, 241, 120, 182, 151, 14, 54, 141, 95, 75, 74, 233]) }) }, digest := (bytes [176, 209, 63, 148, 197, 117, 232, 222, 237, 212, 80, 119, 13, 138, 210, 171, 113, 8, 212, 140, 116, 6, 82, 194, 169, 31, 212, 229, 185, 171, 51, 162]) }, packaged := { statementDigest := (bytes [208, 90, 4, 208, 38, 31, 126, 83, 61, 221, 90, 94, 4, 28, 23, 72, 140, 112, 143, 96, 35, 111, 211, 4, 17, 24, 35, 172, 54, 58, 244, 205]), proofDigest := (bytes [95, 60, 123, 23, 216, 28, 78, 147, 29, 32, 242, 88, 77, 51, 20, 189, 125, 109, 247, 201, 24, 88, 254, 214, 126, 73, 230, 244, 109, 190, 16, 205]) }, digest := (bytes [231, 131, 233, 151, 183, 234, 155, 166, 26, 210, 122, 12, 175, 25, 159, 70, 126, 214, 63, 42, 95, 243, 62, 29, 104, 98, 216, 205, 178, 201, 3, 11]) }
    , digest := (bytes [170, 165, 197, 187, 158, 36, 254, 29, 73, 60, 97, 105, 236, 114, 18, 131, 202, 88, 173, 101, 112, 93, 100, 221, 35, 98, 131, 35, 19, 65, 160, 138])
  }

def stepComposition : StepCompositionSurfaceView :=
  {
    stage1SemanticsDigest := (bytes [185, 10, 252, 28, 6, 208, 226, 194, 100, 83, 68, 180, 90, 91, 25, 159, 145, 45, 95, 16, 225, 156, 68, 137, 22, 2, 226, 45, 135, 30, 73, 8])
    , stage2SemanticsDigest := (bytes [192, 166, 215, 150, 69, 221, 227, 13, 124, 229, 59, 49, 152, 230, 204, 254, 8, 142, 239, 206, 83, 153, 202, 80, 97, 221, 228, 152, 221, 226, 220, 171])
    , stage2TemporalDigest := (bytes [81, 241, 26, 85, 42, 93, 189, 168, 72, 43, 88, 224, 214, 188, 65, 109, 53, 79, 247, 245, 178, 112, 161, 171, 204, 178, 62, 19, 182, 192, 229, 81])
    , stage3SemanticsDigest := (bytes [152, 165, 31, 0, 243, 14, 174, 31, 234, 250, 106, 37, 23, 196, 98, 177, 52, 228, 47, 52, 223, 115, 209, 85, 192, 205, 186, 132, 67, 158, 233, 55])
    , rootExecutionDigest := (bytes [216, 237, 150, 106, 84, 77, 236, 108, 93, 110, 193, 196, 99, 238, 84, 145, 16, 173, 15, 2, 27, 92, 117, 50, 254, 191, 20, 24, 248, 63, 120, 28])
    , preparedStepBindingsDigest := (bytes [166, 17, 177, 48, 228, 204, 66, 244, 60, 90, 217, 53, 191, 14, 162, 45, 145, 148, 222, 0, 46, 175, 226, 102, 99, 230, 239, 139, 144, 108, 172, 195])
    , rowChunkRoutesDigest := (bytes [17, 91, 99, 15, 11, 236, 55, 95, 29, 64, 142, 221, 223, 108, 122, 237, 32, 185, 12, 250, 217, 143, 221, 95, 118, 207, 92, 60, 104, 225, 196, 181])
    , realRowCount := 5
    , preparedStepCount := 5
    , firstRealStepIndex := 0
    , lastRealStepIndex := 4
    , initialPc := 0
    , finalPc := 20
    , halted := true
    , digest := (bytes [109, 95, 226, 108, 135, 146, 107, 110, 84, 152, 254, 122, 136, 34, 39, 150, 175, 20, 20, 15, 247, 193, 70, 166, 28, 173, 229, 60, 77, 144, 129, 222])
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
    name := "vertical_add_sd_ld_ecall"
    , source := {
  manifest := { name := "vertical_add_sd_ld_ecall", fixtureId := "vertical_add_sd_ld_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .alignedMemory, .controlFlow] }
  , startPc := 0
  , programWords := [5243027, 1081651, 2437155, 340355, 115]
  , initialRegisters := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4096, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , initialMemory := [{ addr := 4096, value := 0 }]
  , transcriptSeed := (bytes [114, 118, 54, 52, 105, 109, 45, 118, 101, 114, 116, 105, 99, 97, 108, 45, 115, 108, 105, 99, 101, 45, 118, 49])
}
    , derived := {
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
    , kernelProof := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "vertical_add_sd_ld_ecall", fixtureId := "vertical_add_sd_ld_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .alignedMemory, .controlFlow] }
  , executionDigest := (bytes [254, 167, 237, 35, 229, 145, 124, 131, 169, 247, 185, 244, 68, 31, 227, 147, 217, 37, 96, 244, 224, 23, 123, 54, 206, 154, 166, 72, 40, 193, 48, 159])
  , shape := { executionRowCount := 5, realRowCount := 5, effectRowCount := 5, commitRowCount := 5, digest := (bytes [11, 168, 18, 205, 239, 69, 109, 190, 207, 168, 250, 196, 121, 176, 87, 55, 1, 249, 85, 208, 31, 220, 81, 235, 69, 31, 18, 110, 121, 74, 49, 211]) }
  , digest := (bytes [173, 217, 114, 112, 189, 126, 253, 193, 169, 197, 191, 13, 134, 218, 171, 111, 29, 22, 183, 80, 116, 144, 77, 195, 184, 61, 112, 105, 215, 115, 198, 141])
}
  , stages := { summary := { stage1RowCount := 5, stage2RegisterReadCount := 6, stage2RegisterWriteCount := 3, stage2RamEventCount := 2, stage2TwistLinkCount := 5, stage3ContinuityCount := 5, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [78, 225, 50, 59, 119, 119, 30, 42, 194, 95, 156, 158, 7, 248, 90, 157, 46, 178, 8, 71, 82, 161, 58, 84, 22, 89, 138, 24, 131, 121, 201, 86]) }, digest := (bytes [152, 132, 235, 188, 213, 206, 112, 158, 9, 9, 152, 157, 3, 239, 90, 7, 153, 84, 78, 194, 2, 154, 69, 60, 195, 118, 188, 148, 74, 19, 150, 73]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [249, 135, 40, 152, 53, 237, 52, 34, 138, 201, 96, 112, 80, 75, 48, 252, 14, 5, 187, 32, 125, 220, 13, 123, 75, 99, 226, 55, 175, 231, 248, 99]), stage1Digest := (bytes [164, 13, 128, 213, 82, 178, 19, 220, 137, 27, 45, 85, 86, 13, 185, 247, 233, 243, 57, 38, 2, 160, 123, 254, 186, 242, 145, 140, 17, 1, 233, 229]), stage2Digest := (bytes [222, 22, 203, 174, 187, 223, 75, 183, 131, 22, 214, 82, 109, 154, 168, 135, 61, 158, 186, 184, 146, 119, 236, 180, 212, 57, 242, 56, 31, 98, 60, 229]), stage3Digest := (bytes [203, 140, 63, 160, 179, 160, 171, 82, 223, 2, 32, 73, 21, 112, 190, 222, 133, 97, 45, 221, 193, 128, 37, 148, 220, 120, 81, 206, 4, 164, 16, 21]), transcriptDigest := (bytes [21, 202, 184, 214, 78, 19, 29, 42, 160, 18, 93, 226, 73, 239, 62, 104, 126, 173, 112, 69, 28, 129, 201, 67, 243, 158, 176, 17, 240, 232, 159, 165]), executionDigest := (bytes [254, 167, 237, 35, 229, 145, 124, 131, 169, 247, 185, 244, 68, 31, 227, 147, 217, 37, 96, 244, 224, 23, 123, 54, 206, 154, 166, 72, 40, 193, 48, 159]), digest := (bytes [220, 81, 72, 226, 176, 167, 217, 254, 181, 189, 173, 79, 43, 32, 188, 155, 212, 3, 235, 129, 203, 66, 204, 15, 172, 198, 197, 138, 87, 237, 15, 214]) }, statementDigest := (bytes [252, 213, 158, 82, 138, 35, 18, 91, 193, 55, 4, 206, 41, 15, 250, 255, 243, 195, 49, 203, 24, 114, 29, 101, 111, 25, 3, 244, 245, 90, 178, 138]), proofDigest := (bytes [194, 28, 249, 143, 240, 57, 106, 254, 212, 107, 113, 103, 76, 187, 205, 83, 90, 242, 206, 78, 224, 21, 217, 13, 244, 149, 185, 143, 148, 173, 3, 69]), digest := (bytes [241, 92, 86, 15, 201, 229, 218, 179, 211, 86, 110, 210, 126, 122, 102, 152, 233, 196, 253, 19, 99, 194, 253, 165, 247, 85, 73, 75, 77, 121, 139, 210]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [249, 96, 16, 147, 144, 108, 179, 83, 216, 231, 106, 75, 166, 134, 154, 151, 57, 69, 75, 135, 129, 13, 231, 24, 180, 177, 200, 61, 70, 45, 236, 242]), stage1Digest := (bytes [23, 204, 19, 237, 74, 72, 248, 248, 24, 243, 20, 63, 17, 17, 199, 2, 200, 236, 224, 206, 206, 169, 156, 126, 127, 221, 39, 197, 210, 120, 226, 132]), stage2Digest := (bytes [56, 34, 142, 48, 251, 128, 250, 244, 34, 234, 192, 248, 31, 237, 223, 12, 81, 15, 138, 213, 43, 255, 60, 224, 41, 246, 0, 252, 173, 52, 150, 54]), stage3Digest := (bytes [66, 161, 193, 68, 211, 225, 10, 45, 53, 141, 95, 57, 36, 143, 64, 49, 57, 6, 169, 248, 38, 115, 137, 21, 155, 24, 133, 221, 32, 34, 51, 249]), digest := (bytes [204, 62, 104, 13, 63, 22, 3, 121, 62, 93, 43, 116, 45, 169, 63, 93, 252, 140, 4, 238, 190, 51, 110, 15, 110, 164, 190, 85, 206, 45, 214, 142]) }, digest := (bytes [71, 41, 197, 213, 81, 224, 30, 206, 55, 92, 216, 240, 89, 51, 8, 59, 172, 87, 112, 175, 49, 43, 204, 22, 152, 141, 178, 216, 253, 58, 171, 70]) }
  , kernelOpening := { openingDigest := (bytes [170, 165, 197, 187, 158, 36, 254, 29, 73, 60, 97, 105, 236, 114, 18, 131, 202, 88, 173, 101, 112, 93, 100, 221, 35, 98, 131, 35, 19, 65, 160, 138]), bindings := { claimDigest := (bytes [180, 149, 238, 246, 28, 28, 32, 196, 207, 36, 191, 185, 127, 28, 57, 41, 246, 159, 106, 122, 123, 241, 234, 87, 235, 67, 75, 122, 28, 162, 250, 112]), bindingsDigest := (bytes [91, 180, 186, 199, 223, 133, 98, 216, 152, 215, 124, 217, 38, 97, 125, 89, 193, 167, 61, 206, 200, 46, 217, 229, 115, 254, 112, 23, 77, 200, 159, 0]), preparedStepsDigest := (bytes [231, 131, 233, 151, 183, 234, 155, 166, 26, 210, 122, 12, 175, 25, 159, 70, 126, 214, 63, 42, 95, 243, 62, 29, 104, 98, 216, 205, 178, 201, 3, 11]), digest := (bytes [6, 67, 217, 35, 167, 65, 211, 27, 252, 216, 74, 114, 58, 39, 128, 145, 72, 117, 12, 75, 214, 210, 212, 241, 81, 32, 229, 165, 183, 219, 28, 187]) }, digest := (bytes [61, 26, 66, 196, 217, 11, 66, 33, 123, 177, 21, 24, 107, 230, 116, 159, 157, 157, 62, 197, 107, 218, 117, 102, 10, 80, 209, 101, 201, 183, 83, 0]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [166, 17, 177, 48, 228, 204, 66, 244, 60, 90, 217, 53, 191, 14, 162, 45, 145, 148, 222, 0, 46, 175, 226, 102, 99, 230, 239, 139, 144, 108, 172, 195]), terminal := { root0Digest := (bytes [135, 54, 179, 58, 175, 8, 113, 89, 77, 53, 240, 243, 127, 62, 36, 4, 249, 145, 43, 195, 231, 83, 112, 77, 131, 50, 114, 62, 167, 230, 250, 199]), executionDigest := (bytes [254, 167, 237, 35, 229, 145, 124, 131, 169, 247, 185, 244, 68, 31, 227, 147, 217, 37, 96, 244, 224, 23, 123, 54, 206, 154, 166, 72, 40, 193, 48, 159]), finalStateDigest := (bytes [40, 203, 41, 62, 45, 52, 38, 20, 4, 174, 242, 202, 246, 67, 233, 128, 197, 240, 97, 4, 68, 33, 142, 222, 96, 232, 104, 62, 196, 10, 224, 135]), transcriptFinalDigest := (bytes [21, 202, 184, 214, 78, 19, 29, 42, 160, 18, 93, 226, 73, 239, 62, 104, 126, 173, 112, 69, 28, 129, 201, 67, 243, 158, 176, 17, 240, 232, 159, 165]), finalPc := 20, halted := true, digest := (bytes [251, 40, 235, 31, 151, 119, 59, 78, 203, 230, 90, 44, 85, 31, 181, 25, 39, 115, 193, 61, 246, 244, 183, 211, 41, 84, 75, 8, 70, 166, 110, 5]) }, digest := (bytes [215, 10, 29, 178, 6, 206, 29, 213, 130, 24, 254, 23, 24, 40, 4, 1, 219, 92, 166, 97, 195, 80, 41, 237, 58, 108, 14, 63, 21, 209, 51, 199]) }, statementDigest := (bytes [69, 115, 26, 166, 5, 48, 223, 140, 52, 137, 42, 222, 236, 168, 198, 20, 185, 18, 74, 245, 222, 163, 226, 207, 183, 108, 7, 17, 46, 58, 171, 91]), proofDigest := (bytes [28, 119, 35, 99, 152, 3, 28, 126, 247, 59, 73, 233, 161, 178, 128, 21, 176, 46, 103, 49, 75, 47, 64, 181, 184, 45, 245, 128, 228, 47, 1, 114]), digest := (bytes [139, 91, 41, 56, 143, 77, 16, 92, 45, 176, 144, 237, 127, 137, 90, 222, 98, 250, 69, 144, 139, 45, 198, 226, 58, 245, 186, 73, 184, 36, 35, 96]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [148, 205, 89, 58, 104, 78, 64, 182, 143, 33, 124, 5, 186, 221, 99, 123, 123, 22, 87, 140, 176, 14, 0, 111, 30, 232, 141, 48, 17, 212, 190, 140]), layoutVersion := 1, digest := (bytes [84, 230, 187, 51, 108, 175, 121, 85, 61, 172, 28, 197, 57, 253, 21, 44, 4, 95, 34, 8, 129, 70, 100, 102, 169, 168, 125, 151, 58, 14, 80, 22]) }, rowWidth := 38, timeLen := 5, columnDigests := [(bytes [113, 50, 60, 138, 88, 147, 143, 114, 209, 102, 140, 109, 141, 130, 13, 65, 154, 83, 29, 54, 165, 27, 195, 207, 252, 83, 167, 120, 56, 155, 143, 109]), (bytes [164, 156, 12, 202, 128, 158, 166, 79, 50, 246, 26, 100, 33, 104, 153, 108, 231, 66, 5, 3, 94, 76, 41, 81, 13, 128, 233, 62, 40, 19, 215, 212]), (bytes [104, 86, 253, 80, 246, 180, 248, 154, 56, 26, 223, 106, 196, 169, 105, 55, 112, 123, 51, 7, 215, 60, 203, 20, 133, 2, 161, 155, 25, 94, 39, 31]), (bytes [4, 37, 191, 199, 27, 131, 127, 106, 23, 23, 164, 92, 246, 105, 210, 216, 164, 185, 128, 142, 255, 92, 5, 246, 36, 198, 85, 173, 19, 19, 230, 153]), (bytes [63, 82, 148, 11, 209, 51, 62, 242, 159, 229, 6, 212, 45, 165, 107, 74, 200, 142, 213, 63, 249, 218, 45, 61, 117, 144, 214, 116, 85, 207, 59, 178]), (bytes [40, 86, 180, 196, 136, 142, 131, 114, 170, 148, 131, 157, 229, 108, 112, 242, 18, 99, 53, 118, 202, 175, 81, 88, 163, 134, 0, 98, 34, 184, 118, 74]), (bytes [36, 247, 205, 134, 106, 32, 140, 157, 122, 229, 42, 10, 55, 110, 203, 127, 250, 34, 223, 50, 228, 244, 4, 241, 135, 200, 51, 77, 13, 125, 215, 9]), (bytes [180, 254, 114, 101, 168, 240, 153, 186, 91, 99, 85, 28, 200, 63, 248, 147, 77, 57, 153, 2, 76, 107, 11, 48, 210, 66, 197, 201, 154, 182, 36, 213]), (bytes [16, 166, 173, 204, 197, 96, 81, 23, 174, 247, 123, 173, 160, 1, 215, 78, 87, 237, 64, 153, 255, 223, 20, 26, 202, 114, 66, 221, 15, 90, 40, 102]), (bytes [160, 204, 187, 73, 181, 120, 132, 82, 133, 157, 51, 214, 173, 186, 106, 128, 103, 191, 148, 168, 90, 20, 134, 149, 180, 102, 53, 235, 118, 119, 229, 5]), (bytes [171, 162, 226, 116, 85, 67, 180, 225, 135, 53, 69, 80, 34, 0, 56, 31, 235, 115, 202, 243, 205, 132, 24, 215, 163, 123, 136, 58, 65, 165, 16, 20]), (bytes [200, 70, 207, 188, 229, 30, 55, 93, 2, 14, 174, 213, 10, 59, 54, 173, 38, 71, 129, 251, 173, 123, 217, 79, 111, 149, 86, 191, 99, 79, 28, 216]), (bytes [248, 43, 168, 152, 51, 77, 95, 23, 132, 5, 223, 243, 178, 225, 37, 246, 25, 224, 185, 100, 109, 161, 228, 41, 20, 188, 215, 100, 233, 156, 56, 187]), (bytes [19, 113, 135, 52, 174, 88, 155, 91, 202, 70, 153, 177, 10, 220, 46, 38, 114, 112, 45, 203, 232, 16, 6, 112, 95, 205, 83, 205, 92, 249, 225, 51]), (bytes [29, 217, 189, 89, 151, 246, 187, 208, 140, 159, 85, 103, 77, 104, 217, 4, 240, 201, 192, 135, 37, 250, 218, 243, 219, 70, 188, 1, 131, 20, 143, 164]), (bytes [218, 15, 164, 119, 26, 89, 153, 76, 195, 50, 55, 158, 39, 57, 253, 24, 64, 230, 89, 54, 164, 47, 223, 90, 24, 194, 243, 188, 112, 39, 74, 0]), (bytes [249, 165, 44, 168, 18, 125, 65, 76, 51, 110, 93, 193, 12, 212, 163, 81, 53, 26, 162, 66, 63, 100, 116, 243, 112, 137, 118, 14, 176, 24, 222, 159]), (bytes [11, 185, 133, 252, 50, 244, 35, 237, 167, 173, 175, 155, 13, 76, 146, 252, 114, 4, 198, 228, 91, 62, 90, 251, 253, 108, 66, 173, 181, 43, 114, 60]), (bytes [118, 104, 94, 12, 171, 3, 100, 43, 163, 51, 98, 0, 105, 201, 187, 207, 164, 190, 117, 22, 243, 3, 26, 197, 37, 180, 195, 107, 243, 137, 220, 124]), (bytes [163, 65, 0, 229, 155, 105, 235, 6, 98, 248, 24, 117, 182, 245, 253, 107, 41, 53, 94, 249, 6, 94, 26, 77, 116, 211, 3, 138, 34, 184, 92, 62]), (bytes [166, 212, 193, 165, 216, 77, 223, 22, 85, 148, 36, 46, 240, 197, 91, 192, 178, 249, 84, 99, 56, 189, 17, 175, 26, 146, 194, 235, 103, 203, 78, 106]), (bytes [185, 205, 148, 118, 221, 133, 170, 5, 227, 183, 106, 29, 38, 170, 245, 219, 225, 31, 101, 192, 28, 113, 185, 107, 3, 209, 206, 46, 192, 200, 44, 81]), (bytes [222, 141, 194, 19, 109, 181, 115, 128, 236, 90, 109, 50, 95, 37, 244, 239, 168, 246, 17, 195, 87, 245, 230, 227, 255, 210, 73, 185, 49, 105, 109, 248]), (bytes [83, 103, 3, 75, 9, 33, 248, 240, 3, 92, 111, 187, 27, 152, 47, 192, 237, 17, 71, 35, 227, 187, 140, 184, 160, 92, 191, 56, 81, 5, 51, 116]), (bytes [83, 232, 66, 239, 59, 2, 156, 145, 221, 98, 42, 75, 125, 205, 204, 123, 158, 238, 163, 227, 197, 173, 25, 243, 204, 223, 93, 186, 149, 245, 58, 7]), (bytes [51, 147, 200, 72, 91, 38, 180, 66, 102, 246, 249, 59, 248, 210, 206, 122, 171, 75, 43, 129, 133, 20, 204, 87, 175, 151, 246, 36, 59, 58, 55, 54]), (bytes [61, 169, 61, 118, 122, 118, 139, 112, 180, 2, 225, 125, 1, 241, 243, 209, 64, 94, 20, 252, 240, 64, 93, 21, 190, 0, 165, 42, 205, 8, 253, 178]), (bytes [231, 90, 188, 219, 85, 37, 169, 164, 156, 230, 215, 236, 253, 31, 99, 199, 6, 215, 157, 254, 79, 211, 182, 31, 154, 20, 40, 93, 13, 201, 63, 92]), (bytes [207, 240, 74, 100, 136, 151, 53, 114, 95, 100, 101, 150, 5, 171, 152, 112, 93, 233, 25, 87, 110, 174, 32, 232, 81, 209, 187, 254, 107, 190, 140, 165]), (bytes [231, 38, 189, 225, 191, 28, 138, 109, 137, 172, 136, 41, 0, 71, 10, 98, 82, 251, 63, 57, 134, 215, 207, 171, 22, 74, 131, 24, 248, 187, 249, 139]), (bytes [97, 115, 66, 52, 209, 119, 244, 26, 211, 179, 72, 158, 73, 50, 167, 139, 193, 248, 17, 168, 194, 18, 40, 36, 247, 217, 33, 69, 229, 217, 187, 137]), (bytes [104, 29, 194, 189, 239, 145, 194, 228, 166, 76, 154, 100, 169, 199, 26, 134, 252, 202, 252, 43, 213, 142, 242, 213, 255, 181, 81, 2, 47, 120, 226, 78]), (bytes [235, 49, 191, 128, 17, 252, 43, 130, 234, 138, 63, 235, 22, 122, 39, 9, 154, 168, 135, 151, 54, 180, 125, 133, 235, 6, 32, 243, 247, 58, 14, 141]), (bytes [203, 190, 166, 159, 209, 140, 180, 196, 75, 57, 130, 2, 89, 126, 203, 127, 16, 89, 187, 132, 95, 49, 171, 164, 127, 162, 189, 129, 74, 157, 57, 123]), (bytes [33, 214, 126, 87, 207, 101, 162, 210, 45, 167, 156, 227, 80, 125, 250, 219, 226, 223, 53, 255, 164, 250, 108, 120, 67, 180, 142, 80, 57, 57, 208, 227]), (bytes [62, 7, 150, 11, 99, 98, 7, 110, 228, 135, 72, 232, 238, 53, 224, 30, 95, 75, 71, 72, 114, 247, 48, 12, 96, 132, 25, 33, 74, 63, 170, 176]), (bytes [66, 40, 11, 18, 100, 132, 218, 135, 50, 222, 36, 13, 230, 231, 227, 22, 14, 154, 65, 49, 70, 93, 240, 181, 195, 51, 222, 94, 195, 49, 12, 83]), (bytes [142, 185, 27, 84, 132, 190, 160, 121, 218, 162, 8, 170, 126, 198, 197, 139, 11, 168, 143, 88, 101, 75, 56, 240, 14, 204, 255, 67, 55, 121, 123, 195])], familyDigest := (bytes [148, 205, 89, 58, 104, 78, 64, 182, 143, 33, 124, 5, 186, 221, 99, 123, 123, 22, 87, 140, 176, 14, 0, 111, 30, 232, 141, 48, 17, 212, 190, 140]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [148, 205, 89, 58, 104, 78, 64, 182, 143, 33, 124, 5, 186, 221, 99, 123, 123, 22, 87, 140, 176, 14, 0, 111, 30, 232, 141, 48, 17, 212, 190, 140]), layoutVersion := 1, digest := (bytes [84, 230, 187, 51, 108, 175, 121, 85, 61, 172, 28, 197, 57, 253, 21, 44, 4, 95, 34, 8, 129, 70, 100, 102, 169, 168, 125, 151, 58, 14, 80, 22]) }, logicalIndex := 0, digest := (bytes [33, 222, 236, 140, 152, 132, 200, 6, 98, 222, 232, 153, 56, 64, 78, 183, 86, 239, 200, 156, 54, 167, 4, 32, 180, 158, 128, 41, 109, 212, 87, 64]) }, valueDigest := (bytes [195, 104, 190, 242, 104, 180, 234, 122, 108, 245, 168, 232, 122, 59, 5, 141, 148, 97, 161, 16, 201, 133, 162, 230, 49, 127, 153, 215, 226, 163, 192, 66]), digest := (bytes [21, 76, 16, 225, 119, 225, 104, 218, 203, 54, 249, 87, 162, 148, 36, 96, 143, 247, 221, 93, 203, 152, 105, 157, 96, 209, 60, 199, 248, 165, 137, 99]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [148, 205, 89, 58, 104, 78, 64, 182, 143, 33, 124, 5, 186, 221, 99, 123, 123, 22, 87, 140, 176, 14, 0, 111, 30, 232, 141, 48, 17, 212, 190, 140]), layoutVersion := 1, digest := (bytes [84, 230, 187, 51, 108, 175, 121, 85, 61, 172, 28, 197, 57, 253, 21, 44, 4, 95, 34, 8, 129, 70, 100, 102, 169, 168, 125, 151, 58, 14, 80, 22]) }, logicalIndex := 4, digest := (bytes [167, 107, 119, 68, 241, 43, 38, 31, 166, 248, 2, 16, 126, 226, 211, 250, 159, 22, 151, 250, 26, 19, 129, 35, 237, 246, 88, 82, 70, 183, 22, 254]) }, valueDigest := (bytes [247, 8, 91, 86, 174, 60, 198, 248, 80, 76, 136, 253, 192, 49, 138, 233, 64, 183, 153, 201, 60, 173, 121, 212, 113, 120, 175, 228, 9, 127, 13, 255]), digest := (bytes [191, 86, 73, 89, 202, 171, 100, 227, 63, 148, 86, 216, 15, 140, 225, 129, 192, 7, 28, 191, 58, 145, 62, 86, 71, 244, 220, 148, 207, 179, 38, 151]) }), digest := (bytes [87, 192, 20, 226, 96, 100, 216, 246, 52, 69, 119, 139, 107, 145, 196, 12, 158, 110, 172, 91, 42, 240, 104, 76, 32, 255, 60, 5, 246, 41, 158, 130]) }
  , rootLaneCommitment := { timeLen := 5, commitments := { commitmentCount := 38, digest := (bytes [116, 251, 70, 72, 221, 18, 150, 52, 56, 144, 53, 94, 3, 160, 21, 161, 1, 65, 160, 196, 197, 83, 136, 169, 243, 157, 187, 95, 225, 79, 192, 55]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [116, 251, 70, 72, 221, 18, 150, 52, 56, 144, 53, 94, 3, 160, 21, 161, 1, 65, 160, 196, 197, 83, 136, 169, 243, 157, 187, 95, 225, 79, 192, 55]), layoutVersion := 3, digest := (bytes [190, 153, 87, 41, 90, 212, 192, 33, 101, 235, 172, 224, 206, 214, 250, 84, 240, 24, 180, 142, 135, 2, 21, 234, 179, 184, 255, 106, 239, 168, 181, 38]) }, logicalIndex := 0, digest := (bytes [85, 138, 25, 175, 106, 163, 9, 238, 123, 168, 154, 149, 39, 92, 47, 219, 123, 192, 182, 193, 224, 112, 108, 4, 2, 97, 154, 54, 47, 99, 182, 254]) }, valueDigest := (bytes [195, 104, 190, 242, 104, 180, 234, 122, 108, 245, 168, 232, 122, 59, 5, 141, 148, 97, 161, 16, 201, 133, 162, 230, 49, 127, 153, 215, 226, 163, 192, 66]), digest := (bytes [15, 172, 155, 22, 227, 145, 252, 231, 88, 127, 85, 247, 69, 104, 141, 208, 221, 173, 84, 44, 69, 35, 13, 90, 97, 115, 91, 47, 220, 8, 13, 248]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [116, 251, 70, 72, 221, 18, 150, 52, 56, 144, 53, 94, 3, 160, 21, 161, 1, 65, 160, 196, 197, 83, 136, 169, 243, 157, 187, 95, 225, 79, 192, 55]), layoutVersion := 3, digest := (bytes [190, 153, 87, 41, 90, 212, 192, 33, 101, 235, 172, 224, 206, 214, 250, 84, 240, 24, 180, 142, 135, 2, 21, 234, 179, 184, 255, 106, 239, 168, 181, 38]) }, logicalIndex := 4, digest := (bytes [69, 78, 220, 18, 192, 56, 35, 154, 217, 122, 36, 41, 100, 181, 92, 125, 242, 57, 252, 183, 199, 205, 155, 159, 254, 251, 228, 186, 123, 83, 47, 103]) }, valueDigest := (bytes [247, 8, 91, 86, 174, 60, 198, 248, 80, 76, 136, 253, 192, 49, 138, 233, 64, 183, 153, 201, 60, 173, 121, 212, 113, 120, 175, 228, 9, 127, 13, 255]), digest := (bytes [156, 67, 4, 130, 236, 171, 74, 254, 227, 134, 5, 49, 195, 32, 22, 209, 194, 114, 73, 201, 235, 241, 120, 182, 151, 14, 54, 141, 95, 75, 74, 233]) }), digest := (bytes [27, 36, 48, 10, 198, 252, 81, 218, 111, 103, 230, 103, 89, 168, 41, 146, 70, 247, 57, 93, 236, 222, 102, 157, 121, 247, 153, 254, 74, 187, 229, 144]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [87, 192, 20, 226, 96, 100, 216, 246, 52, 69, 119, 139, 107, 145, 196, 12, 158, 110, 172, 91, 42, 240, 104, 76, 32, 255, 60, 5, 246, 41, 158, 130]), rootLaneCommitmentDigest := (bytes [27, 36, 48, 10, 198, 252, 81, 218, 111, 103, 230, 103, 89, 168, 41, 146, 70, 247, 57, 93, 236, 222, 102, 157, 121, 247, 153, 254, 74, 187, 229, 144]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 5, digest := (bytes [162, 114, 160, 176, 3, 193, 26, 204, 220, 193, 15, 215, 38, 15, 2, 29, 235, 69, 196, 87, 17, 45, 175, 62, 71, 208, 199, 117, 253, 107, 62, 170]) }, statementDigest := (bytes [32, 65, 185, 77, 24, 58, 28, 218, 212, 29, 45, 129, 123, 151, 43, 73, 150, 153, 255, 154, 122, 186, 217, 44, 101, 231, 211, 182, 154, 195, 42, 64]), proofDigest := (bytes [40, 15, 29, 146, 94, 67, 107, 120, 15, 89, 88, 104, 107, 38, 137, 69, 158, 87, 139, 148, 41, 23, 245, 148, 116, 231, 113, 44, 149, 53, 139, 88]), digest := (bytes [221, 82, 176, 224, 111, 78, 62, 71, 41, 191, 205, 45, 115, 229, 13, 40, 251, 83, 99, 59, 161, 240, 78, 80, 118, 32, 228, 17, 150, 61, 100, 246]) }
  , digest := (bytes [232, 42, 24, 12, 101, 125, 72, 7, 79, 121, 120, 196, 107, 10, 168, 84, 93, 36, 231, 121, 73, 65, 136, 68, 77, 217, 231, 32, 101, 213, 9, 40])
}
    , exportedProof := {
  claim := {
  accepted := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , statement := { proofStatementDigest := (bytes [168, 166, 8, 196, 137, 26, 59, 74, 39, 49, 97, 237, 115, 140, 103, 54, 50, 108, 57, 48, 45, 151, 67, 21, 211, 193, 28, 123, 121, 114, 136, 118]), kernelOpeningDigest := (bytes [61, 26, 66, 196, 217, 11, 66, 33, 123, 177, 21, 24, 107, 230, 116, 159, 157, 157, 62, 197, 107, 218, 117, 102, 10, 80, 209, 101, 201, 183, 83, 0]), digest := (bytes [229, 218, 77, 139, 234, 81, 141, 130, 24, 58, 82, 35, 40, 4, 202, 116, 52, 171, 193, 202, 119, 220, 2, 121, 223, 169, 232, 247, 143, 206, 197, 221]) }
  , mainLane := { mainLaneBundleDigest := (bytes [221, 82, 176, 224, 111, 78, 62, 71, 41, 191, 205, 45, 115, 229, 13, 40, 251, 83, 99, 59, 161, 240, 78, 80, 118, 32, 228, 17, 150, 61, 100, 246]), digest := (bytes [241, 89, 214, 235, 160, 10, 125, 174, 98, 170, 169, 219, 135, 118, 51, 176, 159, 218, 221, 79, 245, 9, 166, 195, 21, 112, 98, 218, 246, 96, 129, 188]) }
  , terminal := { finalStateDigest := (bytes [40, 203, 41, 62, 45, 52, 38, 20, 4, 174, 242, 202, 246, 67, 233, 128, 197, 240, 97, 4, 68, 33, 142, 222, 96, 232, 104, 62, 196, 10, 224, 135]), finalPc := 20, halted := true, digest := (bytes [41, 85, 135, 44, 24, 129, 161, 207, 51, 45, 181, 192, 190, 250, 123, 36, 170, 56, 75, 148, 80, 223, 97, 49, 203, 188, 111, 105, 124, 74, 157, 230]) }
  , digest := (bytes [17, 106, 227, 128, 162, 28, 182, 194, 82, 31, 107, 11, 173, 48, 108, 238, 55, 77, 27, 55, 219, 27, 172, 67, 213, 137, 153, 21, 137, 84, 48, 136])
}
  , mainLane := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { mainLaneBundleDigest := (bytes [221, 82, 176, 224, 111, 78, 62, 71, 41, 191, 205, 45, 115, 229, 13, 40, 251, 83, 99, 59, 161, 240, 78, 80, 118, 32, 228, 17, 150, 61, 100, 246]), digest := (bytes [170, 45, 181, 172, 61, 53, 156, 74, 182, 135, 157, 109, 91, 2, 215, 217, 252, 235, 239, 92, 239, 243, 102, 26, 88, 2, 218, 250, 42, 201, 54, 167]) }, digest := (bytes [159, 164, 223, 188, 70, 19, 131, 54, 32, 205, 144, 42, 56, 170, 130, 161, 223, 140, 162, 109, 108, 16, 10, 2, 172, 98, 63, 59, 35, 177, 109, 184]) }
  , opening := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , stages := { stageClaimsDigest := (bytes [241, 92, 86, 15, 201, 229, 218, 179, 211, 86, 110, 210, 126, 122, 102, 152, 233, 196, 253, 19, 99, 194, 253, 165, 247, 85, 73, 75, 77, 121, 139, 210]), stagePackagesDigest := (bytes [71, 41, 197, 213, 81, 224, 30, 206, 55, 92, 216, 240, 89, 51, 8, 59, 172, 87, 112, 175, 49, 43, 204, 22, 152, 141, 178, 216, 253, 58, 171, 70]), kernelOpeningDigest := (bytes [61, 26, 66, 196, 217, 11, 66, 33, 123, 177, 21, 24, 107, 230, 116, 159, 157, 157, 62, 197, 107, 218, 117, 102, 10, 80, 209, 101, 201, 183, 83, 0]), digest := (bytes [145, 140, 10, 200, 234, 217, 24, 173, 120, 47, 246, 100, 14, 187, 122, 249, 155, 66, 244, 54, 25, 126, 36, 254, 115, 114, 216, 188, 224, 212, 224, 179]) }
  , terminal := { preparedStepBindingsDigest := (bytes [166, 17, 177, 48, 228, 204, 66, 244, 60, 90, 217, 53, 191, 14, 162, 45, 145, 148, 222, 0, 46, 175, 226, 102, 99, 230, 239, 139, 144, 108, 172, 195]), executionDigest := (bytes [254, 167, 237, 35, 229, 145, 124, 131, 169, 247, 185, 244, 68, 31, 227, 147, 217, 37, 96, 244, 224, 23, 123, 54, 206, 154, 166, 72, 40, 193, 48, 159]), transcriptFinalDigest := (bytes [21, 202, 184, 214, 78, 19, 29, 42, 160, 18, 93, 226, 73, 239, 62, 104, 126, 173, 112, 69, 28, 129, 201, 67, 243, 158, 176, 17, 240, 232, 159, 165]), digest := (bytes [26, 105, 115, 46, 112, 95, 241, 163, 31, 200, 94, 176, 103, 119, 231, 201, 239, 67, 5, 197, 208, 234, 15, 129, 229, 196, 87, 253, 218, 169, 142, 193]) }
  , digest := (bytes [116, 204, 114, 147, 33, 71, 105, 143, 144, 70, 127, 177, 208, 150, 118, 188, 56, 158, 160, 98, 5, 162, 81, 198, 197, 113, 29, 204, 31, 134, 208, 8])
}
  , jointOpening := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { proofStatementDigest := (bytes [168, 166, 8, 196, 137, 26, 59, 74, 39, 49, 97, 237, 115, 140, 103, 54, 50, 108, 57, 48, 45, 151, 67, 21, 211, 193, 28, 123, 121, 114, 136, 118]), mainLaneClaimDigest := (bytes [159, 164, 223, 188, 70, 19, 131, 54, 32, 205, 144, 42, 56, 170, 130, 161, 223, 140, 162, 109, 108, 16, 10, 2, 172, 98, 63, 59, 35, 177, 109, 184]), kernelOpeningClaimDigest := (bytes [116, 204, 114, 147, 33, 71, 105, 143, 144, 70, 127, 177, 208, 150, 118, 188, 56, 158, 160, 98, 5, 162, 81, 198, 197, 113, 29, 204, 31, 134, 208, 8]), digest := (bytes [167, 251, 55, 82, 11, 14, 159, 25, 131, 11, 22, 211, 206, 193, 112, 195, 246, 43, 213, 245, 50, 114, 102, 19, 86, 119, 236, 102, 154, 124, 173, 245]) }, digest := (bytes [159, 206, 16, 47, 145, 138, 6, 49, 214, 20, 120, 47, 146, 151, 113, 239, 157, 181, 221, 105, 211, 167, 127, 87, 66, 154, 195, 189, 198, 227, 109, 47]) }
  , root0 := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), stages := { stage1Digest := (bytes [118, 214, 69, 122, 148, 32, 162, 213, 7, 210, 132, 135, 161, 66, 31, 34, 29, 43, 130, 6, 112, 109, 4, 180, 166, 164, 136, 198, 238, 212, 121, 51]), stage2Digest := (bytes [251, 200, 2, 73, 106, 203, 134, 119, 197, 122, 57, 39, 230, 167, 35, 170, 238, 99, 170, 82, 101, 116, 253, 216, 228, 173, 71, 39, 172, 50, 146, 14]), stage3Digest := (bytes [2, 183, 132, 95, 231, 115, 83, 2, 8, 179, 51, 169, 210, 224, 230, 178, 60, 35, 73, 58, 195, 121, 109, 163, 86, 206, 95, 244, 250, 18, 169, 79]), digest := (bytes [228, 113, 28, 87, 179, 71, 219, 140, 152, 238, 187, 235, 21, 107, 197, 80, 121, 24, 117, 98, 102, 141, 140, 147, 45, 61, 168, 194, 246, 234, 141, 196]) }, terminal := { root0Digest := (bytes [135, 54, 179, 58, 175, 8, 113, 89, 77, 53, 240, 243, 127, 62, 36, 4, 249, 145, 43, 195, 231, 83, 112, 77, 131, 50, 114, 62, 167, 230, 250, 199]), executionDigest := (bytes [254, 167, 237, 35, 229, 145, 124, 131, 169, 247, 185, 244, 68, 31, 227, 147, 217, 37, 96, 244, 224, 23, 123, 54, 206, 154, 166, 72, 40, 193, 48, 159]), finalStateDigest := (bytes [40, 203, 41, 62, 45, 52, 38, 20, 4, 174, 242, 202, 246, 67, 233, 128, 197, 240, 97, 4, 68, 33, 142, 222, 96, 232, 104, 62, 196, 10, 224, 135]), transcriptFinalDigest := (bytes [21, 202, 184, 214, 78, 19, 29, 42, 160, 18, 93, 226, 73, 239, 62, 104, 126, 173, 112, 69, 28, 129, 201, 67, 243, 158, 176, 17, 240, 232, 159, 165]), digest := (bytes [68, 178, 217, 156, 59, 201, 37, 104, 63, 105, 87, 48, 18, 243, 162, 255, 107, 23, 205, 246, 21, 164, 173, 2, 243, 208, 106, 20, 136, 28, 35, 57]) }, digest := (bytes [201, 151, 216, 131, 180, 124, 121, 250, 197, 130, 152, 232, 238, 108, 110, 219, 79, 213, 245, 88, 61, 108, 179, 27, 11, 232, 120, 44, 197, 189, 183, 18]) }
  , digest := (bytes [229, 15, 206, 143, 180, 192, 249, 85, 192, 246, 226, 65, 114, 251, 144, 31, 127, 231, 185, 213, 233, 163, 29, 9, 216, 178, 134, 112, 21, 95, 63, 246])
}
  , statement := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , foldSchedule := Nightstream.FoldSchedule.wholeTrace
  , chunkCount := 1
  , stageClaimsDigest := (bytes [241, 92, 86, 15, 201, 229, 218, 179, 211, 86, 110, 210, 126, 122, 102, 152, 233, 196, 253, 19, 99, 194, 253, 165, 247, 85, 73, 75, 77, 121, 139, 210])
  , stagePackagesDigest := (bytes [71, 41, 197, 213, 81, 224, 30, 206, 55, 92, 216, 240, 89, 51, 8, 59, 172, 87, 112, 175, 49, 43, 204, 22, 152, 141, 178, 216, 253, 58, 171, 70])
  , kernelOpeningDigest := (bytes [61, 26, 66, 196, 217, 11, 66, 33, 123, 177, 21, 24, 107, 230, 116, 159, 157, 157, 62, 197, 107, 218, 117, 102, 10, 80, 209, 101, 201, 183, 83, 0])
  , preparedStepBindingsDigest := (bytes [166, 17, 177, 48, 228, 204, 66, 244, 60, 90, 217, 53, 191, 14, 162, 45, 145, 148, 222, 0, 46, 175, 226, 102, 99, 230, 239, 139, 144, 108, 172, 195])
  , executionDigest := (bytes [254, 167, 237, 35, 229, 145, 124, 131, 169, 247, 185, 244, 68, 31, 227, 147, 217, 37, 96, 244, 224, 23, 123, 54, 206, 154, 166, 72, 40, 193, 48, 159])
  , finalStateDigest := (bytes [40, 203, 41, 62, 45, 52, 38, 20, 4, 174, 242, 202, 246, 67, 233, 128, 197, 240, 97, 4, 68, 33, 142, 222, 96, 232, 104, 62, 196, 10, 224, 135])
  , transcriptFinalDigest := (bytes [21, 202, 184, 214, 78, 19, 29, 42, 160, 18, 93, 226, 73, 239, 62, 104, 126, 173, 112, 69, 28, 129, 201, 67, 243, 158, 176, 17, 240, 232, 159, 165])
  , mainLaneSurfaceDigest := (bytes [252, 95, 2, 189, 32, 244, 10, 101, 247, 135, 227, 115, 183, 51, 77, 21, 228, 200, 10, 27, 159, 187, 150, 53, 124, 46, 235, 91, 172, 133, 116, 203])
  , rootLaneColumnsDigest := (bytes [87, 192, 20, 226, 96, 100, 216, 246, 52, 69, 119, 139, 107, 145, 196, 12, 158, 110, 172, 91, 42, 240, 104, 76, 32, 255, 60, 5, 246, 41, 158, 130])
  , publicStepCount := 5
  , initialPc := 0
  , finalPc := 20
  , halted := true
  , digest := (bytes [168, 166, 8, 196, 137, 26, 59, 74, 39, 49, 97, 237, 115, 140, 103, 54, 50, 108, 57, 48, 45, 151, 67, 21, 211, 193, 28, 123, 121, 114, 136, 118])
}
  , kernel := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "vertical_add_sd_ld_ecall", fixtureId := "vertical_add_sd_ld_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .alignedMemory, .controlFlow] }
  , executionDigest := (bytes [254, 167, 237, 35, 229, 145, 124, 131, 169, 247, 185, 244, 68, 31, 227, 147, 217, 37, 96, 244, 224, 23, 123, 54, 206, 154, 166, 72, 40, 193, 48, 159])
  , shape := { executionRowCount := 5, realRowCount := 5, effectRowCount := 5, commitRowCount := 5, digest := (bytes [11, 168, 18, 205, 239, 69, 109, 190, 207, 168, 250, 196, 121, 176, 87, 55, 1, 249, 85, 208, 31, 220, 81, 235, 69, 31, 18, 110, 121, 74, 49, 211]) }
  , digest := (bytes [173, 217, 114, 112, 189, 126, 253, 193, 169, 197, 191, 13, 134, 218, 171, 111, 29, 22, 183, 80, 116, 144, 77, 195, 184, 61, 112, 105, 215, 115, 198, 141])
}
  , stages := { summary := { stage1RowCount := 5, stage2RegisterReadCount := 6, stage2RegisterWriteCount := 3, stage2RamEventCount := 2, stage2TwistLinkCount := 5, stage3ContinuityCount := 5, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [78, 225, 50, 59, 119, 119, 30, 42, 194, 95, 156, 158, 7, 248, 90, 157, 46, 178, 8, 71, 82, 161, 58, 84, 22, 89, 138, 24, 131, 121, 201, 86]) }, digest := (bytes [152, 132, 235, 188, 213, 206, 112, 158, 9, 9, 152, 157, 3, 239, 90, 7, 153, 84, 78, 194, 2, 154, 69, 60, 195, 118, 188, 148, 74, 19, 150, 73]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [249, 135, 40, 152, 53, 237, 52, 34, 138, 201, 96, 112, 80, 75, 48, 252, 14, 5, 187, 32, 125, 220, 13, 123, 75, 99, 226, 55, 175, 231, 248, 99]), stage1Digest := (bytes [164, 13, 128, 213, 82, 178, 19, 220, 137, 27, 45, 85, 86, 13, 185, 247, 233, 243, 57, 38, 2, 160, 123, 254, 186, 242, 145, 140, 17, 1, 233, 229]), stage2Digest := (bytes [222, 22, 203, 174, 187, 223, 75, 183, 131, 22, 214, 82, 109, 154, 168, 135, 61, 158, 186, 184, 146, 119, 236, 180, 212, 57, 242, 56, 31, 98, 60, 229]), stage3Digest := (bytes [203, 140, 63, 160, 179, 160, 171, 82, 223, 2, 32, 73, 21, 112, 190, 222, 133, 97, 45, 221, 193, 128, 37, 148, 220, 120, 81, 206, 4, 164, 16, 21]), transcriptDigest := (bytes [21, 202, 184, 214, 78, 19, 29, 42, 160, 18, 93, 226, 73, 239, 62, 104, 126, 173, 112, 69, 28, 129, 201, 67, 243, 158, 176, 17, 240, 232, 159, 165]), executionDigest := (bytes [254, 167, 237, 35, 229, 145, 124, 131, 169, 247, 185, 244, 68, 31, 227, 147, 217, 37, 96, 244, 224, 23, 123, 54, 206, 154, 166, 72, 40, 193, 48, 159]), digest := (bytes [220, 81, 72, 226, 176, 167, 217, 254, 181, 189, 173, 79, 43, 32, 188, 155, 212, 3, 235, 129, 203, 66, 204, 15, 172, 198, 197, 138, 87, 237, 15, 214]) }, statementDigest := (bytes [252, 213, 158, 82, 138, 35, 18, 91, 193, 55, 4, 206, 41, 15, 250, 255, 243, 195, 49, 203, 24, 114, 29, 101, 111, 25, 3, 244, 245, 90, 178, 138]), proofDigest := (bytes [194, 28, 249, 143, 240, 57, 106, 254, 212, 107, 113, 103, 76, 187, 205, 83, 90, 242, 206, 78, 224, 21, 217, 13, 244, 149, 185, 143, 148, 173, 3, 69]), digest := (bytes [241, 92, 86, 15, 201, 229, 218, 179, 211, 86, 110, 210, 126, 122, 102, 152, 233, 196, 253, 19, 99, 194, 253, 165, 247, 85, 73, 75, 77, 121, 139, 210]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [249, 96, 16, 147, 144, 108, 179, 83, 216, 231, 106, 75, 166, 134, 154, 151, 57, 69, 75, 135, 129, 13, 231, 24, 180, 177, 200, 61, 70, 45, 236, 242]), stage1Digest := (bytes [23, 204, 19, 237, 74, 72, 248, 248, 24, 243, 20, 63, 17, 17, 199, 2, 200, 236, 224, 206, 206, 169, 156, 126, 127, 221, 39, 197, 210, 120, 226, 132]), stage2Digest := (bytes [56, 34, 142, 48, 251, 128, 250, 244, 34, 234, 192, 248, 31, 237, 223, 12, 81, 15, 138, 213, 43, 255, 60, 224, 41, 246, 0, 252, 173, 52, 150, 54]), stage3Digest := (bytes [66, 161, 193, 68, 211, 225, 10, 45, 53, 141, 95, 57, 36, 143, 64, 49, 57, 6, 169, 248, 38, 115, 137, 21, 155, 24, 133, 221, 32, 34, 51, 249]), digest := (bytes [204, 62, 104, 13, 63, 22, 3, 121, 62, 93, 43, 116, 45, 169, 63, 93, 252, 140, 4, 238, 190, 51, 110, 15, 110, 164, 190, 85, 206, 45, 214, 142]) }, digest := (bytes [71, 41, 197, 213, 81, 224, 30, 206, 55, 92, 216, 240, 89, 51, 8, 59, 172, 87, 112, 175, 49, 43, 204, 22, 152, 141, 178, 216, 253, 58, 171, 70]) }
  , kernelOpening := { openingDigest := (bytes [170, 165, 197, 187, 158, 36, 254, 29, 73, 60, 97, 105, 236, 114, 18, 131, 202, 88, 173, 101, 112, 93, 100, 221, 35, 98, 131, 35, 19, 65, 160, 138]), bindings := { claimDigest := (bytes [180, 149, 238, 246, 28, 28, 32, 196, 207, 36, 191, 185, 127, 28, 57, 41, 246, 159, 106, 122, 123, 241, 234, 87, 235, 67, 75, 122, 28, 162, 250, 112]), bindingsDigest := (bytes [91, 180, 186, 199, 223, 133, 98, 216, 152, 215, 124, 217, 38, 97, 125, 89, 193, 167, 61, 206, 200, 46, 217, 229, 115, 254, 112, 23, 77, 200, 159, 0]), preparedStepsDigest := (bytes [231, 131, 233, 151, 183, 234, 155, 166, 26, 210, 122, 12, 175, 25, 159, 70, 126, 214, 63, 42, 95, 243, 62, 29, 104, 98, 216, 205, 178, 201, 3, 11]), digest := (bytes [6, 67, 217, 35, 167, 65, 211, 27, 252, 216, 74, 114, 58, 39, 128, 145, 72, 117, 12, 75, 214, 210, 212, 241, 81, 32, 229, 165, 183, 219, 28, 187]) }, digest := (bytes [61, 26, 66, 196, 217, 11, 66, 33, 123, 177, 21, 24, 107, 230, 116, 159, 157, 157, 62, 197, 107, 218, 117, 102, 10, 80, 209, 101, 201, 183, 83, 0]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [166, 17, 177, 48, 228, 204, 66, 244, 60, 90, 217, 53, 191, 14, 162, 45, 145, 148, 222, 0, 46, 175, 226, 102, 99, 230, 239, 139, 144, 108, 172, 195]), terminal := { root0Digest := (bytes [135, 54, 179, 58, 175, 8, 113, 89, 77, 53, 240, 243, 127, 62, 36, 4, 249, 145, 43, 195, 231, 83, 112, 77, 131, 50, 114, 62, 167, 230, 250, 199]), executionDigest := (bytes [254, 167, 237, 35, 229, 145, 124, 131, 169, 247, 185, 244, 68, 31, 227, 147, 217, 37, 96, 244, 224, 23, 123, 54, 206, 154, 166, 72, 40, 193, 48, 159]), finalStateDigest := (bytes [40, 203, 41, 62, 45, 52, 38, 20, 4, 174, 242, 202, 246, 67, 233, 128, 197, 240, 97, 4, 68, 33, 142, 222, 96, 232, 104, 62, 196, 10, 224, 135]), transcriptFinalDigest := (bytes [21, 202, 184, 214, 78, 19, 29, 42, 160, 18, 93, 226, 73, 239, 62, 104, 126, 173, 112, 69, 28, 129, 201, 67, 243, 158, 176, 17, 240, 232, 159, 165]), finalPc := 20, halted := true, digest := (bytes [251, 40, 235, 31, 151, 119, 59, 78, 203, 230, 90, 44, 85, 31, 181, 25, 39, 115, 193, 61, 246, 244, 183, 211, 41, 84, 75, 8, 70, 166, 110, 5]) }, digest := (bytes [215, 10, 29, 178, 6, 206, 29, 213, 130, 24, 254, 23, 24, 40, 4, 1, 219, 92, 166, 97, 195, 80, 41, 237, 58, 108, 14, 63, 21, 209, 51, 199]) }, statementDigest := (bytes [69, 115, 26, 166, 5, 48, 223, 140, 52, 137, 42, 222, 236, 168, 198, 20, 185, 18, 74, 245, 222, 163, 226, 207, 183, 108, 7, 17, 46, 58, 171, 91]), proofDigest := (bytes [28, 119, 35, 99, 152, 3, 28, 126, 247, 59, 73, 233, 161, 178, 128, 21, 176, 46, 103, 49, 75, 47, 64, 181, 184, 45, 245, 128, 228, 47, 1, 114]), digest := (bytes [139, 91, 41, 56, 143, 77, 16, 92, 45, 176, 144, 237, 127, 137, 90, 222, 98, 250, 69, 144, 139, 45, 198, 226, 58, 245, 186, 73, 184, 36, 35, 96]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [148, 205, 89, 58, 104, 78, 64, 182, 143, 33, 124, 5, 186, 221, 99, 123, 123, 22, 87, 140, 176, 14, 0, 111, 30, 232, 141, 48, 17, 212, 190, 140]), layoutVersion := 1, digest := (bytes [84, 230, 187, 51, 108, 175, 121, 85, 61, 172, 28, 197, 57, 253, 21, 44, 4, 95, 34, 8, 129, 70, 100, 102, 169, 168, 125, 151, 58, 14, 80, 22]) }, rowWidth := 38, timeLen := 5, columnDigests := [(bytes [113, 50, 60, 138, 88, 147, 143, 114, 209, 102, 140, 109, 141, 130, 13, 65, 154, 83, 29, 54, 165, 27, 195, 207, 252, 83, 167, 120, 56, 155, 143, 109]), (bytes [164, 156, 12, 202, 128, 158, 166, 79, 50, 246, 26, 100, 33, 104, 153, 108, 231, 66, 5, 3, 94, 76, 41, 81, 13, 128, 233, 62, 40, 19, 215, 212]), (bytes [104, 86, 253, 80, 246, 180, 248, 154, 56, 26, 223, 106, 196, 169, 105, 55, 112, 123, 51, 7, 215, 60, 203, 20, 133, 2, 161, 155, 25, 94, 39, 31]), (bytes [4, 37, 191, 199, 27, 131, 127, 106, 23, 23, 164, 92, 246, 105, 210, 216, 164, 185, 128, 142, 255, 92, 5, 246, 36, 198, 85, 173, 19, 19, 230, 153]), (bytes [63, 82, 148, 11, 209, 51, 62, 242, 159, 229, 6, 212, 45, 165, 107, 74, 200, 142, 213, 63, 249, 218, 45, 61, 117, 144, 214, 116, 85, 207, 59, 178]), (bytes [40, 86, 180, 196, 136, 142, 131, 114, 170, 148, 131, 157, 229, 108, 112, 242, 18, 99, 53, 118, 202, 175, 81, 88, 163, 134, 0, 98, 34, 184, 118, 74]), (bytes [36, 247, 205, 134, 106, 32, 140, 157, 122, 229, 42, 10, 55, 110, 203, 127, 250, 34, 223, 50, 228, 244, 4, 241, 135, 200, 51, 77, 13, 125, 215, 9]), (bytes [180, 254, 114, 101, 168, 240, 153, 186, 91, 99, 85, 28, 200, 63, 248, 147, 77, 57, 153, 2, 76, 107, 11, 48, 210, 66, 197, 201, 154, 182, 36, 213]), (bytes [16, 166, 173, 204, 197, 96, 81, 23, 174, 247, 123, 173, 160, 1, 215, 78, 87, 237, 64, 153, 255, 223, 20, 26, 202, 114, 66, 221, 15, 90, 40, 102]), (bytes [160, 204, 187, 73, 181, 120, 132, 82, 133, 157, 51, 214, 173, 186, 106, 128, 103, 191, 148, 168, 90, 20, 134, 149, 180, 102, 53, 235, 118, 119, 229, 5]), (bytes [171, 162, 226, 116, 85, 67, 180, 225, 135, 53, 69, 80, 34, 0, 56, 31, 235, 115, 202, 243, 205, 132, 24, 215, 163, 123, 136, 58, 65, 165, 16, 20]), (bytes [200, 70, 207, 188, 229, 30, 55, 93, 2, 14, 174, 213, 10, 59, 54, 173, 38, 71, 129, 251, 173, 123, 217, 79, 111, 149, 86, 191, 99, 79, 28, 216]), (bytes [248, 43, 168, 152, 51, 77, 95, 23, 132, 5, 223, 243, 178, 225, 37, 246, 25, 224, 185, 100, 109, 161, 228, 41, 20, 188, 215, 100, 233, 156, 56, 187]), (bytes [19, 113, 135, 52, 174, 88, 155, 91, 202, 70, 153, 177, 10, 220, 46, 38, 114, 112, 45, 203, 232, 16, 6, 112, 95, 205, 83, 205, 92, 249, 225, 51]), (bytes [29, 217, 189, 89, 151, 246, 187, 208, 140, 159, 85, 103, 77, 104, 217, 4, 240, 201, 192, 135, 37, 250, 218, 243, 219, 70, 188, 1, 131, 20, 143, 164]), (bytes [218, 15, 164, 119, 26, 89, 153, 76, 195, 50, 55, 158, 39, 57, 253, 24, 64, 230, 89, 54, 164, 47, 223, 90, 24, 194, 243, 188, 112, 39, 74, 0]), (bytes [249, 165, 44, 168, 18, 125, 65, 76, 51, 110, 93, 193, 12, 212, 163, 81, 53, 26, 162, 66, 63, 100, 116, 243, 112, 137, 118, 14, 176, 24, 222, 159]), (bytes [11, 185, 133, 252, 50, 244, 35, 237, 167, 173, 175, 155, 13, 76, 146, 252, 114, 4, 198, 228, 91, 62, 90, 251, 253, 108, 66, 173, 181, 43, 114, 60]), (bytes [118, 104, 94, 12, 171, 3, 100, 43, 163, 51, 98, 0, 105, 201, 187, 207, 164, 190, 117, 22, 243, 3, 26, 197, 37, 180, 195, 107, 243, 137, 220, 124]), (bytes [163, 65, 0, 229, 155, 105, 235, 6, 98, 248, 24, 117, 182, 245, 253, 107, 41, 53, 94, 249, 6, 94, 26, 77, 116, 211, 3, 138, 34, 184, 92, 62]), (bytes [166, 212, 193, 165, 216, 77, 223, 22, 85, 148, 36, 46, 240, 197, 91, 192, 178, 249, 84, 99, 56, 189, 17, 175, 26, 146, 194, 235, 103, 203, 78, 106]), (bytes [185, 205, 148, 118, 221, 133, 170, 5, 227, 183, 106, 29, 38, 170, 245, 219, 225, 31, 101, 192, 28, 113, 185, 107, 3, 209, 206, 46, 192, 200, 44, 81]), (bytes [222, 141, 194, 19, 109, 181, 115, 128, 236, 90, 109, 50, 95, 37, 244, 239, 168, 246, 17, 195, 87, 245, 230, 227, 255, 210, 73, 185, 49, 105, 109, 248]), (bytes [83, 103, 3, 75, 9, 33, 248, 240, 3, 92, 111, 187, 27, 152, 47, 192, 237, 17, 71, 35, 227, 187, 140, 184, 160, 92, 191, 56, 81, 5, 51, 116]), (bytes [83, 232, 66, 239, 59, 2, 156, 145, 221, 98, 42, 75, 125, 205, 204, 123, 158, 238, 163, 227, 197, 173, 25, 243, 204, 223, 93, 186, 149, 245, 58, 7]), (bytes [51, 147, 200, 72, 91, 38, 180, 66, 102, 246, 249, 59, 248, 210, 206, 122, 171, 75, 43, 129, 133, 20, 204, 87, 175, 151, 246, 36, 59, 58, 55, 54]), (bytes [61, 169, 61, 118, 122, 118, 139, 112, 180, 2, 225, 125, 1, 241, 243, 209, 64, 94, 20, 252, 240, 64, 93, 21, 190, 0, 165, 42, 205, 8, 253, 178]), (bytes [231, 90, 188, 219, 85, 37, 169, 164, 156, 230, 215, 236, 253, 31, 99, 199, 6, 215, 157, 254, 79, 211, 182, 31, 154, 20, 40, 93, 13, 201, 63, 92]), (bytes [207, 240, 74, 100, 136, 151, 53, 114, 95, 100, 101, 150, 5, 171, 152, 112, 93, 233, 25, 87, 110, 174, 32, 232, 81, 209, 187, 254, 107, 190, 140, 165]), (bytes [231, 38, 189, 225, 191, 28, 138, 109, 137, 172, 136, 41, 0, 71, 10, 98, 82, 251, 63, 57, 134, 215, 207, 171, 22, 74, 131, 24, 248, 187, 249, 139]), (bytes [97, 115, 66, 52, 209, 119, 244, 26, 211, 179, 72, 158, 73, 50, 167, 139, 193, 248, 17, 168, 194, 18, 40, 36, 247, 217, 33, 69, 229, 217, 187, 137]), (bytes [104, 29, 194, 189, 239, 145, 194, 228, 166, 76, 154, 100, 169, 199, 26, 134, 252, 202, 252, 43, 213, 142, 242, 213, 255, 181, 81, 2, 47, 120, 226, 78]), (bytes [235, 49, 191, 128, 17, 252, 43, 130, 234, 138, 63, 235, 22, 122, 39, 9, 154, 168, 135, 151, 54, 180, 125, 133, 235, 6, 32, 243, 247, 58, 14, 141]), (bytes [203, 190, 166, 159, 209, 140, 180, 196, 75, 57, 130, 2, 89, 126, 203, 127, 16, 89, 187, 132, 95, 49, 171, 164, 127, 162, 189, 129, 74, 157, 57, 123]), (bytes [33, 214, 126, 87, 207, 101, 162, 210, 45, 167, 156, 227, 80, 125, 250, 219, 226, 223, 53, 255, 164, 250, 108, 120, 67, 180, 142, 80, 57, 57, 208, 227]), (bytes [62, 7, 150, 11, 99, 98, 7, 110, 228, 135, 72, 232, 238, 53, 224, 30, 95, 75, 71, 72, 114, 247, 48, 12, 96, 132, 25, 33, 74, 63, 170, 176]), (bytes [66, 40, 11, 18, 100, 132, 218, 135, 50, 222, 36, 13, 230, 231, 227, 22, 14, 154, 65, 49, 70, 93, 240, 181, 195, 51, 222, 94, 195, 49, 12, 83]), (bytes [142, 185, 27, 84, 132, 190, 160, 121, 218, 162, 8, 170, 126, 198, 197, 139, 11, 168, 143, 88, 101, 75, 56, 240, 14, 204, 255, 67, 55, 121, 123, 195])], familyDigest := (bytes [148, 205, 89, 58, 104, 78, 64, 182, 143, 33, 124, 5, 186, 221, 99, 123, 123, 22, 87, 140, 176, 14, 0, 111, 30, 232, 141, 48, 17, 212, 190, 140]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [148, 205, 89, 58, 104, 78, 64, 182, 143, 33, 124, 5, 186, 221, 99, 123, 123, 22, 87, 140, 176, 14, 0, 111, 30, 232, 141, 48, 17, 212, 190, 140]), layoutVersion := 1, digest := (bytes [84, 230, 187, 51, 108, 175, 121, 85, 61, 172, 28, 197, 57, 253, 21, 44, 4, 95, 34, 8, 129, 70, 100, 102, 169, 168, 125, 151, 58, 14, 80, 22]) }, logicalIndex := 0, digest := (bytes [33, 222, 236, 140, 152, 132, 200, 6, 98, 222, 232, 153, 56, 64, 78, 183, 86, 239, 200, 156, 54, 167, 4, 32, 180, 158, 128, 41, 109, 212, 87, 64]) }, valueDigest := (bytes [195, 104, 190, 242, 104, 180, 234, 122, 108, 245, 168, 232, 122, 59, 5, 141, 148, 97, 161, 16, 201, 133, 162, 230, 49, 127, 153, 215, 226, 163, 192, 66]), digest := (bytes [21, 76, 16, 225, 119, 225, 104, 218, 203, 54, 249, 87, 162, 148, 36, 96, 143, 247, 221, 93, 203, 152, 105, 157, 96, 209, 60, 199, 248, 165, 137, 99]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [148, 205, 89, 58, 104, 78, 64, 182, 143, 33, 124, 5, 186, 221, 99, 123, 123, 22, 87, 140, 176, 14, 0, 111, 30, 232, 141, 48, 17, 212, 190, 140]), layoutVersion := 1, digest := (bytes [84, 230, 187, 51, 108, 175, 121, 85, 61, 172, 28, 197, 57, 253, 21, 44, 4, 95, 34, 8, 129, 70, 100, 102, 169, 168, 125, 151, 58, 14, 80, 22]) }, logicalIndex := 4, digest := (bytes [167, 107, 119, 68, 241, 43, 38, 31, 166, 248, 2, 16, 126, 226, 211, 250, 159, 22, 151, 250, 26, 19, 129, 35, 237, 246, 88, 82, 70, 183, 22, 254]) }, valueDigest := (bytes [247, 8, 91, 86, 174, 60, 198, 248, 80, 76, 136, 253, 192, 49, 138, 233, 64, 183, 153, 201, 60, 173, 121, 212, 113, 120, 175, 228, 9, 127, 13, 255]), digest := (bytes [191, 86, 73, 89, 202, 171, 100, 227, 63, 148, 86, 216, 15, 140, 225, 129, 192, 7, 28, 191, 58, 145, 62, 86, 71, 244, 220, 148, 207, 179, 38, 151]) }), digest := (bytes [87, 192, 20, 226, 96, 100, 216, 246, 52, 69, 119, 139, 107, 145, 196, 12, 158, 110, 172, 91, 42, 240, 104, 76, 32, 255, 60, 5, 246, 41, 158, 130]) }
  , rootLaneCommitment := { timeLen := 5, commitments := { commitmentCount := 38, digest := (bytes [116, 251, 70, 72, 221, 18, 150, 52, 56, 144, 53, 94, 3, 160, 21, 161, 1, 65, 160, 196, 197, 83, 136, 169, 243, 157, 187, 95, 225, 79, 192, 55]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [116, 251, 70, 72, 221, 18, 150, 52, 56, 144, 53, 94, 3, 160, 21, 161, 1, 65, 160, 196, 197, 83, 136, 169, 243, 157, 187, 95, 225, 79, 192, 55]), layoutVersion := 3, digest := (bytes [190, 153, 87, 41, 90, 212, 192, 33, 101, 235, 172, 224, 206, 214, 250, 84, 240, 24, 180, 142, 135, 2, 21, 234, 179, 184, 255, 106, 239, 168, 181, 38]) }, logicalIndex := 0, digest := (bytes [85, 138, 25, 175, 106, 163, 9, 238, 123, 168, 154, 149, 39, 92, 47, 219, 123, 192, 182, 193, 224, 112, 108, 4, 2, 97, 154, 54, 47, 99, 182, 254]) }, valueDigest := (bytes [195, 104, 190, 242, 104, 180, 234, 122, 108, 245, 168, 232, 122, 59, 5, 141, 148, 97, 161, 16, 201, 133, 162, 230, 49, 127, 153, 215, 226, 163, 192, 66]), digest := (bytes [15, 172, 155, 22, 227, 145, 252, 231, 88, 127, 85, 247, 69, 104, 141, 208, 221, 173, 84, 44, 69, 35, 13, 90, 97, 115, 91, 47, 220, 8, 13, 248]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [116, 251, 70, 72, 221, 18, 150, 52, 56, 144, 53, 94, 3, 160, 21, 161, 1, 65, 160, 196, 197, 83, 136, 169, 243, 157, 187, 95, 225, 79, 192, 55]), layoutVersion := 3, digest := (bytes [190, 153, 87, 41, 90, 212, 192, 33, 101, 235, 172, 224, 206, 214, 250, 84, 240, 24, 180, 142, 135, 2, 21, 234, 179, 184, 255, 106, 239, 168, 181, 38]) }, logicalIndex := 4, digest := (bytes [69, 78, 220, 18, 192, 56, 35, 154, 217, 122, 36, 41, 100, 181, 92, 125, 242, 57, 252, 183, 199, 205, 155, 159, 254, 251, 228, 186, 123, 83, 47, 103]) }, valueDigest := (bytes [247, 8, 91, 86, 174, 60, 198, 248, 80, 76, 136, 253, 192, 49, 138, 233, 64, 183, 153, 201, 60, 173, 121, 212, 113, 120, 175, 228, 9, 127, 13, 255]), digest := (bytes [156, 67, 4, 130, 236, 171, 74, 254, 227, 134, 5, 49, 195, 32, 22, 209, 194, 114, 73, 201, 235, 241, 120, 182, 151, 14, 54, 141, 95, 75, 74, 233]) }), digest := (bytes [27, 36, 48, 10, 198, 252, 81, 218, 111, 103, 230, 103, 89, 168, 41, 146, 70, 247, 57, 93, 236, 222, 102, 157, 121, 247, 153, 254, 74, 187, 229, 144]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [87, 192, 20, 226, 96, 100, 216, 246, 52, 69, 119, 139, 107, 145, 196, 12, 158, 110, 172, 91, 42, 240, 104, 76, 32, 255, 60, 5, 246, 41, 158, 130]), rootLaneCommitmentDigest := (bytes [27, 36, 48, 10, 198, 252, 81, 218, 111, 103, 230, 103, 89, 168, 41, 146, 70, 247, 57, 93, 236, 222, 102, 157, 121, 247, 153, 254, 74, 187, 229, 144]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 5, digest := (bytes [162, 114, 160, 176, 3, 193, 26, 204, 220, 193, 15, 215, 38, 15, 2, 29, 235, 69, 196, 87, 17, 45, 175, 62, 71, 208, 199, 117, 253, 107, 62, 170]) }, statementDigest := (bytes [32, 65, 185, 77, 24, 58, 28, 218, 212, 29, 45, 129, 123, 151, 43, 73, 150, 153, 255, 154, 122, 186, 217, 44, 101, 231, 211, 182, 154, 195, 42, 64]), proofDigest := (bytes [40, 15, 29, 146, 94, 67, 107, 120, 15, 89, 88, 104, 107, 38, 137, 69, 158, 87, 139, 148, 41, 23, 245, 148, 116, 231, 113, 44, 149, 53, 139, 88]), digest := (bytes [221, 82, 176, 224, 111, 78, 62, 71, 41, 191, 205, 45, 115, 229, 13, 40, 251, 83, 99, 59, 161, 240, 78, 80, 118, 32, 228, 17, 150, 61, 100, 246]) }
  , digest := (bytes [232, 42, 24, 12, 101, 125, 72, 7, 79, 121, 120, 196, 107, 10, 168, 84, 93, 36, 231, 121, 73, 65, 136, 68, 77, 217, 231, 32, 101, 213, 9, 40])
}
}
    , exportedStatement := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , foldSchedule := Nightstream.FoldSchedule.wholeTrace
  , chunkCount := 1
  , stageClaimsDigest := (bytes [241, 92, 86, 15, 201, 229, 218, 179, 211, 86, 110, 210, 126, 122, 102, 152, 233, 196, 253, 19, 99, 194, 253, 165, 247, 85, 73, 75, 77, 121, 139, 210])
  , stagePackagesDigest := (bytes [71, 41, 197, 213, 81, 224, 30, 206, 55, 92, 216, 240, 89, 51, 8, 59, 172, 87, 112, 175, 49, 43, 204, 22, 152, 141, 178, 216, 253, 58, 171, 70])
  , kernelOpeningDigest := (bytes [61, 26, 66, 196, 217, 11, 66, 33, 123, 177, 21, 24, 107, 230, 116, 159, 157, 157, 62, 197, 107, 218, 117, 102, 10, 80, 209, 101, 201, 183, 83, 0])
  , preparedStepBindingsDigest := (bytes [166, 17, 177, 48, 228, 204, 66, 244, 60, 90, 217, 53, 191, 14, 162, 45, 145, 148, 222, 0, 46, 175, 226, 102, 99, 230, 239, 139, 144, 108, 172, 195])
  , executionDigest := (bytes [254, 167, 237, 35, 229, 145, 124, 131, 169, 247, 185, 244, 68, 31, 227, 147, 217, 37, 96, 244, 224, 23, 123, 54, 206, 154, 166, 72, 40, 193, 48, 159])
  , finalStateDigest := (bytes [40, 203, 41, 62, 45, 52, 38, 20, 4, 174, 242, 202, 246, 67, 233, 128, 197, 240, 97, 4, 68, 33, 142, 222, 96, 232, 104, 62, 196, 10, 224, 135])
  , transcriptFinalDigest := (bytes [21, 202, 184, 214, 78, 19, 29, 42, 160, 18, 93, 226, 73, 239, 62, 104, 126, 173, 112, 69, 28, 129, 201, 67, 243, 158, 176, 17, 240, 232, 159, 165])
  , mainLaneSurfaceDigest := (bytes [252, 95, 2, 189, 32, 244, 10, 101, 247, 135, 227, 115, 183, 51, 77, 21, 228, 200, 10, 27, 159, 187, 150, 53, 124, 46, 235, 91, 172, 133, 116, 203])
  , rootLaneColumnsDigest := (bytes [87, 192, 20, 226, 96, 100, 216, 246, 52, 69, 119, 139, 107, 145, 196, 12, 158, 110, 172, 91, 42, 240, 104, 76, 32, 255, 60, 5, 246, 41, 158, 130])
  , publicStepCount := 5
  , initialPc := 0
  , finalPc := 20
  , halted := true
  , digest := (bytes [168, 166, 8, 196, 137, 26, 59, 74, 39, 49, 97, 237, 115, 140, 103, 54, 50, 108, 57, 48, 45, 151, 67, 21, 211, 193, 28, 123, 121, 114, 136, 118])
}
    , exportedClaims := {
  accepted := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , statement := { proofStatementDigest := (bytes [168, 166, 8, 196, 137, 26, 59, 74, 39, 49, 97, 237, 115, 140, 103, 54, 50, 108, 57, 48, 45, 151, 67, 21, 211, 193, 28, 123, 121, 114, 136, 118]), kernelOpeningDigest := (bytes [61, 26, 66, 196, 217, 11, 66, 33, 123, 177, 21, 24, 107, 230, 116, 159, 157, 157, 62, 197, 107, 218, 117, 102, 10, 80, 209, 101, 201, 183, 83, 0]), digest := (bytes [229, 218, 77, 139, 234, 81, 141, 130, 24, 58, 82, 35, 40, 4, 202, 116, 52, 171, 193, 202, 119, 220, 2, 121, 223, 169, 232, 247, 143, 206, 197, 221]) }
  , mainLane := { mainLaneBundleDigest := (bytes [221, 82, 176, 224, 111, 78, 62, 71, 41, 191, 205, 45, 115, 229, 13, 40, 251, 83, 99, 59, 161, 240, 78, 80, 118, 32, 228, 17, 150, 61, 100, 246]), digest := (bytes [241, 89, 214, 235, 160, 10, 125, 174, 98, 170, 169, 219, 135, 118, 51, 176, 159, 218, 221, 79, 245, 9, 166, 195, 21, 112, 98, 218, 246, 96, 129, 188]) }
  , terminal := { finalStateDigest := (bytes [40, 203, 41, 62, 45, 52, 38, 20, 4, 174, 242, 202, 246, 67, 233, 128, 197, 240, 97, 4, 68, 33, 142, 222, 96, 232, 104, 62, 196, 10, 224, 135]), finalPc := 20, halted := true, digest := (bytes [41, 85, 135, 44, 24, 129, 161, 207, 51, 45, 181, 192, 190, 250, 123, 36, 170, 56, 75, 148, 80, 223, 97, 49, 203, 188, 111, 105, 124, 74, 157, 230]) }
  , digest := (bytes [17, 106, 227, 128, 162, 28, 182, 194, 82, 31, 107, 11, 173, 48, 108, 238, 55, 77, 27, 55, 219, 27, 172, 67, 213, 137, 153, 21, 137, 84, 48, 136])
}
  , mainLane := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { mainLaneBundleDigest := (bytes [221, 82, 176, 224, 111, 78, 62, 71, 41, 191, 205, 45, 115, 229, 13, 40, 251, 83, 99, 59, 161, 240, 78, 80, 118, 32, 228, 17, 150, 61, 100, 246]), digest := (bytes [170, 45, 181, 172, 61, 53, 156, 74, 182, 135, 157, 109, 91, 2, 215, 217, 252, 235, 239, 92, 239, 243, 102, 26, 88, 2, 218, 250, 42, 201, 54, 167]) }, digest := (bytes [159, 164, 223, 188, 70, 19, 131, 54, 32, 205, 144, 42, 56, 170, 130, 161, 223, 140, 162, 109, 108, 16, 10, 2, 172, 98, 63, 59, 35, 177, 109, 184]) }
  , opening := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , stages := { stageClaimsDigest := (bytes [241, 92, 86, 15, 201, 229, 218, 179, 211, 86, 110, 210, 126, 122, 102, 152, 233, 196, 253, 19, 99, 194, 253, 165, 247, 85, 73, 75, 77, 121, 139, 210]), stagePackagesDigest := (bytes [71, 41, 197, 213, 81, 224, 30, 206, 55, 92, 216, 240, 89, 51, 8, 59, 172, 87, 112, 175, 49, 43, 204, 22, 152, 141, 178, 216, 253, 58, 171, 70]), kernelOpeningDigest := (bytes [61, 26, 66, 196, 217, 11, 66, 33, 123, 177, 21, 24, 107, 230, 116, 159, 157, 157, 62, 197, 107, 218, 117, 102, 10, 80, 209, 101, 201, 183, 83, 0]), digest := (bytes [145, 140, 10, 200, 234, 217, 24, 173, 120, 47, 246, 100, 14, 187, 122, 249, 155, 66, 244, 54, 25, 126, 36, 254, 115, 114, 216, 188, 224, 212, 224, 179]) }
  , terminal := { preparedStepBindingsDigest := (bytes [166, 17, 177, 48, 228, 204, 66, 244, 60, 90, 217, 53, 191, 14, 162, 45, 145, 148, 222, 0, 46, 175, 226, 102, 99, 230, 239, 139, 144, 108, 172, 195]), executionDigest := (bytes [254, 167, 237, 35, 229, 145, 124, 131, 169, 247, 185, 244, 68, 31, 227, 147, 217, 37, 96, 244, 224, 23, 123, 54, 206, 154, 166, 72, 40, 193, 48, 159]), transcriptFinalDigest := (bytes [21, 202, 184, 214, 78, 19, 29, 42, 160, 18, 93, 226, 73, 239, 62, 104, 126, 173, 112, 69, 28, 129, 201, 67, 243, 158, 176, 17, 240, 232, 159, 165]), digest := (bytes [26, 105, 115, 46, 112, 95, 241, 163, 31, 200, 94, 176, 103, 119, 231, 201, 239, 67, 5, 197, 208, 234, 15, 129, 229, 196, 87, 253, 218, 169, 142, 193]) }
  , digest := (bytes [116, 204, 114, 147, 33, 71, 105, 143, 144, 70, 127, 177, 208, 150, 118, 188, 56, 158, 160, 98, 5, 162, 81, 198, 197, 113, 29, 204, 31, 134, 208, 8])
}
  , jointOpening := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { proofStatementDigest := (bytes [168, 166, 8, 196, 137, 26, 59, 74, 39, 49, 97, 237, 115, 140, 103, 54, 50, 108, 57, 48, 45, 151, 67, 21, 211, 193, 28, 123, 121, 114, 136, 118]), mainLaneClaimDigest := (bytes [159, 164, 223, 188, 70, 19, 131, 54, 32, 205, 144, 42, 56, 170, 130, 161, 223, 140, 162, 109, 108, 16, 10, 2, 172, 98, 63, 59, 35, 177, 109, 184]), kernelOpeningClaimDigest := (bytes [116, 204, 114, 147, 33, 71, 105, 143, 144, 70, 127, 177, 208, 150, 118, 188, 56, 158, 160, 98, 5, 162, 81, 198, 197, 113, 29, 204, 31, 134, 208, 8]), digest := (bytes [167, 251, 55, 82, 11, 14, 159, 25, 131, 11, 22, 211, 206, 193, 112, 195, 246, 43, 213, 245, 50, 114, 102, 19, 86, 119, 236, 102, 154, 124, 173, 245]) }, digest := (bytes [159, 206, 16, 47, 145, 138, 6, 49, 214, 20, 120, 47, 146, 151, 113, 239, 157, 181, 221, 105, 211, 167, 127, 87, 66, 154, 195, 189, 198, 227, 109, 47]) }
  , root0 := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), stages := { stage1Digest := (bytes [118, 214, 69, 122, 148, 32, 162, 213, 7, 210, 132, 135, 161, 66, 31, 34, 29, 43, 130, 6, 112, 109, 4, 180, 166, 164, 136, 198, 238, 212, 121, 51]), stage2Digest := (bytes [251, 200, 2, 73, 106, 203, 134, 119, 197, 122, 57, 39, 230, 167, 35, 170, 238, 99, 170, 82, 101, 116, 253, 216, 228, 173, 71, 39, 172, 50, 146, 14]), stage3Digest := (bytes [2, 183, 132, 95, 231, 115, 83, 2, 8, 179, 51, 169, 210, 224, 230, 178, 60, 35, 73, 58, 195, 121, 109, 163, 86, 206, 95, 244, 250, 18, 169, 79]), digest := (bytes [228, 113, 28, 87, 179, 71, 219, 140, 152, 238, 187, 235, 21, 107, 197, 80, 121, 24, 117, 98, 102, 141, 140, 147, 45, 61, 168, 194, 246, 234, 141, 196]) }, terminal := { root0Digest := (bytes [135, 54, 179, 58, 175, 8, 113, 89, 77, 53, 240, 243, 127, 62, 36, 4, 249, 145, 43, 195, 231, 83, 112, 77, 131, 50, 114, 62, 167, 230, 250, 199]), executionDigest := (bytes [254, 167, 237, 35, 229, 145, 124, 131, 169, 247, 185, 244, 68, 31, 227, 147, 217, 37, 96, 244, 224, 23, 123, 54, 206, 154, 166, 72, 40, 193, 48, 159]), finalStateDigest := (bytes [40, 203, 41, 62, 45, 52, 38, 20, 4, 174, 242, 202, 246, 67, 233, 128, 197, 240, 97, 4, 68, 33, 142, 222, 96, 232, 104, 62, 196, 10, 224, 135]), transcriptFinalDigest := (bytes [21, 202, 184, 214, 78, 19, 29, 42, 160, 18, 93, 226, 73, 239, 62, 104, 126, 173, 112, 69, 28, 129, 201, 67, 243, 158, 176, 17, 240, 232, 159, 165]), digest := (bytes [68, 178, 217, 156, 59, 201, 37, 104, 63, 105, 87, 48, 18, 243, 162, 255, 107, 23, 205, 246, 21, 164, 173, 2, 243, 208, 106, 20, 136, 28, 35, 57]) }, digest := (bytes [201, 151, 216, 131, 180, 124, 121, 250, 197, 130, 152, 232, 238, 108, 110, 219, 79, 213, 245, 88, 61, 108, 179, 27, 11, 232, 120, 44, 197, 189, 183, 18]) }
  , digest := (bytes [229, 15, 206, 143, 180, 192, 249, 85, 192, 246, 226, 65, 114, 251, 144, 31, 127, 231, 185, 213, 233, 163, 29, 9, 216, 178, 134, 112, 21, 95, 63, 246])
}
    , exportedKernelProof := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "vertical_add_sd_ld_ecall", fixtureId := "vertical_add_sd_ld_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .alignedMemory, .controlFlow] }
  , executionDigest := (bytes [254, 167, 237, 35, 229, 145, 124, 131, 169, 247, 185, 244, 68, 31, 227, 147, 217, 37, 96, 244, 224, 23, 123, 54, 206, 154, 166, 72, 40, 193, 48, 159])
  , shape := { executionRowCount := 5, realRowCount := 5, effectRowCount := 5, commitRowCount := 5, digest := (bytes [11, 168, 18, 205, 239, 69, 109, 190, 207, 168, 250, 196, 121, 176, 87, 55, 1, 249, 85, 208, 31, 220, 81, 235, 69, 31, 18, 110, 121, 74, 49, 211]) }
  , digest := (bytes [173, 217, 114, 112, 189, 126, 253, 193, 169, 197, 191, 13, 134, 218, 171, 111, 29, 22, 183, 80, 116, 144, 77, 195, 184, 61, 112, 105, 215, 115, 198, 141])
}
  , stages := { summary := { stage1RowCount := 5, stage2RegisterReadCount := 6, stage2RegisterWriteCount := 3, stage2RamEventCount := 2, stage2TwistLinkCount := 5, stage3ContinuityCount := 5, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [78, 225, 50, 59, 119, 119, 30, 42, 194, 95, 156, 158, 7, 248, 90, 157, 46, 178, 8, 71, 82, 161, 58, 84, 22, 89, 138, 24, 131, 121, 201, 86]) }, digest := (bytes [152, 132, 235, 188, 213, 206, 112, 158, 9, 9, 152, 157, 3, 239, 90, 7, 153, 84, 78, 194, 2, 154, 69, 60, 195, 118, 188, 148, 74, 19, 150, 73]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [249, 135, 40, 152, 53, 237, 52, 34, 138, 201, 96, 112, 80, 75, 48, 252, 14, 5, 187, 32, 125, 220, 13, 123, 75, 99, 226, 55, 175, 231, 248, 99]), stage1Digest := (bytes [164, 13, 128, 213, 82, 178, 19, 220, 137, 27, 45, 85, 86, 13, 185, 247, 233, 243, 57, 38, 2, 160, 123, 254, 186, 242, 145, 140, 17, 1, 233, 229]), stage2Digest := (bytes [222, 22, 203, 174, 187, 223, 75, 183, 131, 22, 214, 82, 109, 154, 168, 135, 61, 158, 186, 184, 146, 119, 236, 180, 212, 57, 242, 56, 31, 98, 60, 229]), stage3Digest := (bytes [203, 140, 63, 160, 179, 160, 171, 82, 223, 2, 32, 73, 21, 112, 190, 222, 133, 97, 45, 221, 193, 128, 37, 148, 220, 120, 81, 206, 4, 164, 16, 21]), transcriptDigest := (bytes [21, 202, 184, 214, 78, 19, 29, 42, 160, 18, 93, 226, 73, 239, 62, 104, 126, 173, 112, 69, 28, 129, 201, 67, 243, 158, 176, 17, 240, 232, 159, 165]), executionDigest := (bytes [254, 167, 237, 35, 229, 145, 124, 131, 169, 247, 185, 244, 68, 31, 227, 147, 217, 37, 96, 244, 224, 23, 123, 54, 206, 154, 166, 72, 40, 193, 48, 159]), digest := (bytes [220, 81, 72, 226, 176, 167, 217, 254, 181, 189, 173, 79, 43, 32, 188, 155, 212, 3, 235, 129, 203, 66, 204, 15, 172, 198, 197, 138, 87, 237, 15, 214]) }, statementDigest := (bytes [252, 213, 158, 82, 138, 35, 18, 91, 193, 55, 4, 206, 41, 15, 250, 255, 243, 195, 49, 203, 24, 114, 29, 101, 111, 25, 3, 244, 245, 90, 178, 138]), proofDigest := (bytes [194, 28, 249, 143, 240, 57, 106, 254, 212, 107, 113, 103, 76, 187, 205, 83, 90, 242, 206, 78, 224, 21, 217, 13, 244, 149, 185, 143, 148, 173, 3, 69]), digest := (bytes [241, 92, 86, 15, 201, 229, 218, 179, 211, 86, 110, 210, 126, 122, 102, 152, 233, 196, 253, 19, 99, 194, 253, 165, 247, 85, 73, 75, 77, 121, 139, 210]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [249, 96, 16, 147, 144, 108, 179, 83, 216, 231, 106, 75, 166, 134, 154, 151, 57, 69, 75, 135, 129, 13, 231, 24, 180, 177, 200, 61, 70, 45, 236, 242]), stage1Digest := (bytes [23, 204, 19, 237, 74, 72, 248, 248, 24, 243, 20, 63, 17, 17, 199, 2, 200, 236, 224, 206, 206, 169, 156, 126, 127, 221, 39, 197, 210, 120, 226, 132]), stage2Digest := (bytes [56, 34, 142, 48, 251, 128, 250, 244, 34, 234, 192, 248, 31, 237, 223, 12, 81, 15, 138, 213, 43, 255, 60, 224, 41, 246, 0, 252, 173, 52, 150, 54]), stage3Digest := (bytes [66, 161, 193, 68, 211, 225, 10, 45, 53, 141, 95, 57, 36, 143, 64, 49, 57, 6, 169, 248, 38, 115, 137, 21, 155, 24, 133, 221, 32, 34, 51, 249]), digest := (bytes [204, 62, 104, 13, 63, 22, 3, 121, 62, 93, 43, 116, 45, 169, 63, 93, 252, 140, 4, 238, 190, 51, 110, 15, 110, 164, 190, 85, 206, 45, 214, 142]) }, digest := (bytes [71, 41, 197, 213, 81, 224, 30, 206, 55, 92, 216, 240, 89, 51, 8, 59, 172, 87, 112, 175, 49, 43, 204, 22, 152, 141, 178, 216, 253, 58, 171, 70]) }
  , kernelOpening := { openingDigest := (bytes [170, 165, 197, 187, 158, 36, 254, 29, 73, 60, 97, 105, 236, 114, 18, 131, 202, 88, 173, 101, 112, 93, 100, 221, 35, 98, 131, 35, 19, 65, 160, 138]), bindings := { claimDigest := (bytes [180, 149, 238, 246, 28, 28, 32, 196, 207, 36, 191, 185, 127, 28, 57, 41, 246, 159, 106, 122, 123, 241, 234, 87, 235, 67, 75, 122, 28, 162, 250, 112]), bindingsDigest := (bytes [91, 180, 186, 199, 223, 133, 98, 216, 152, 215, 124, 217, 38, 97, 125, 89, 193, 167, 61, 206, 200, 46, 217, 229, 115, 254, 112, 23, 77, 200, 159, 0]), preparedStepsDigest := (bytes [231, 131, 233, 151, 183, 234, 155, 166, 26, 210, 122, 12, 175, 25, 159, 70, 126, 214, 63, 42, 95, 243, 62, 29, 104, 98, 216, 205, 178, 201, 3, 11]), digest := (bytes [6, 67, 217, 35, 167, 65, 211, 27, 252, 216, 74, 114, 58, 39, 128, 145, 72, 117, 12, 75, 214, 210, 212, 241, 81, 32, 229, 165, 183, 219, 28, 187]) }, digest := (bytes [61, 26, 66, 196, 217, 11, 66, 33, 123, 177, 21, 24, 107, 230, 116, 159, 157, 157, 62, 197, 107, 218, 117, 102, 10, 80, 209, 101, 201, 183, 83, 0]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [166, 17, 177, 48, 228, 204, 66, 244, 60, 90, 217, 53, 191, 14, 162, 45, 145, 148, 222, 0, 46, 175, 226, 102, 99, 230, 239, 139, 144, 108, 172, 195]), terminal := { root0Digest := (bytes [135, 54, 179, 58, 175, 8, 113, 89, 77, 53, 240, 243, 127, 62, 36, 4, 249, 145, 43, 195, 231, 83, 112, 77, 131, 50, 114, 62, 167, 230, 250, 199]), executionDigest := (bytes [254, 167, 237, 35, 229, 145, 124, 131, 169, 247, 185, 244, 68, 31, 227, 147, 217, 37, 96, 244, 224, 23, 123, 54, 206, 154, 166, 72, 40, 193, 48, 159]), finalStateDigest := (bytes [40, 203, 41, 62, 45, 52, 38, 20, 4, 174, 242, 202, 246, 67, 233, 128, 197, 240, 97, 4, 68, 33, 142, 222, 96, 232, 104, 62, 196, 10, 224, 135]), transcriptFinalDigest := (bytes [21, 202, 184, 214, 78, 19, 29, 42, 160, 18, 93, 226, 73, 239, 62, 104, 126, 173, 112, 69, 28, 129, 201, 67, 243, 158, 176, 17, 240, 232, 159, 165]), finalPc := 20, halted := true, digest := (bytes [251, 40, 235, 31, 151, 119, 59, 78, 203, 230, 90, 44, 85, 31, 181, 25, 39, 115, 193, 61, 246, 244, 183, 211, 41, 84, 75, 8, 70, 166, 110, 5]) }, digest := (bytes [215, 10, 29, 178, 6, 206, 29, 213, 130, 24, 254, 23, 24, 40, 4, 1, 219, 92, 166, 97, 195, 80, 41, 237, 58, 108, 14, 63, 21, 209, 51, 199]) }, statementDigest := (bytes [69, 115, 26, 166, 5, 48, 223, 140, 52, 137, 42, 222, 236, 168, 198, 20, 185, 18, 74, 245, 222, 163, 226, 207, 183, 108, 7, 17, 46, 58, 171, 91]), proofDigest := (bytes [28, 119, 35, 99, 152, 3, 28, 126, 247, 59, 73, 233, 161, 178, 128, 21, 176, 46, 103, 49, 75, 47, 64, 181, 184, 45, 245, 128, 228, 47, 1, 114]), digest := (bytes [139, 91, 41, 56, 143, 77, 16, 92, 45, 176, 144, 237, 127, 137, 90, 222, 98, 250, 69, 144, 139, 45, 198, 226, 58, 245, 186, 73, 184, 36, 35, 96]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [148, 205, 89, 58, 104, 78, 64, 182, 143, 33, 124, 5, 186, 221, 99, 123, 123, 22, 87, 140, 176, 14, 0, 111, 30, 232, 141, 48, 17, 212, 190, 140]), layoutVersion := 1, digest := (bytes [84, 230, 187, 51, 108, 175, 121, 85, 61, 172, 28, 197, 57, 253, 21, 44, 4, 95, 34, 8, 129, 70, 100, 102, 169, 168, 125, 151, 58, 14, 80, 22]) }, rowWidth := 38, timeLen := 5, columnDigests := [(bytes [113, 50, 60, 138, 88, 147, 143, 114, 209, 102, 140, 109, 141, 130, 13, 65, 154, 83, 29, 54, 165, 27, 195, 207, 252, 83, 167, 120, 56, 155, 143, 109]), (bytes [164, 156, 12, 202, 128, 158, 166, 79, 50, 246, 26, 100, 33, 104, 153, 108, 231, 66, 5, 3, 94, 76, 41, 81, 13, 128, 233, 62, 40, 19, 215, 212]), (bytes [104, 86, 253, 80, 246, 180, 248, 154, 56, 26, 223, 106, 196, 169, 105, 55, 112, 123, 51, 7, 215, 60, 203, 20, 133, 2, 161, 155, 25, 94, 39, 31]), (bytes [4, 37, 191, 199, 27, 131, 127, 106, 23, 23, 164, 92, 246, 105, 210, 216, 164, 185, 128, 142, 255, 92, 5, 246, 36, 198, 85, 173, 19, 19, 230, 153]), (bytes [63, 82, 148, 11, 209, 51, 62, 242, 159, 229, 6, 212, 45, 165, 107, 74, 200, 142, 213, 63, 249, 218, 45, 61, 117, 144, 214, 116, 85, 207, 59, 178]), (bytes [40, 86, 180, 196, 136, 142, 131, 114, 170, 148, 131, 157, 229, 108, 112, 242, 18, 99, 53, 118, 202, 175, 81, 88, 163, 134, 0, 98, 34, 184, 118, 74]), (bytes [36, 247, 205, 134, 106, 32, 140, 157, 122, 229, 42, 10, 55, 110, 203, 127, 250, 34, 223, 50, 228, 244, 4, 241, 135, 200, 51, 77, 13, 125, 215, 9]), (bytes [180, 254, 114, 101, 168, 240, 153, 186, 91, 99, 85, 28, 200, 63, 248, 147, 77, 57, 153, 2, 76, 107, 11, 48, 210, 66, 197, 201, 154, 182, 36, 213]), (bytes [16, 166, 173, 204, 197, 96, 81, 23, 174, 247, 123, 173, 160, 1, 215, 78, 87, 237, 64, 153, 255, 223, 20, 26, 202, 114, 66, 221, 15, 90, 40, 102]), (bytes [160, 204, 187, 73, 181, 120, 132, 82, 133, 157, 51, 214, 173, 186, 106, 128, 103, 191, 148, 168, 90, 20, 134, 149, 180, 102, 53, 235, 118, 119, 229, 5]), (bytes [171, 162, 226, 116, 85, 67, 180, 225, 135, 53, 69, 80, 34, 0, 56, 31, 235, 115, 202, 243, 205, 132, 24, 215, 163, 123, 136, 58, 65, 165, 16, 20]), (bytes [200, 70, 207, 188, 229, 30, 55, 93, 2, 14, 174, 213, 10, 59, 54, 173, 38, 71, 129, 251, 173, 123, 217, 79, 111, 149, 86, 191, 99, 79, 28, 216]), (bytes [248, 43, 168, 152, 51, 77, 95, 23, 132, 5, 223, 243, 178, 225, 37, 246, 25, 224, 185, 100, 109, 161, 228, 41, 20, 188, 215, 100, 233, 156, 56, 187]), (bytes [19, 113, 135, 52, 174, 88, 155, 91, 202, 70, 153, 177, 10, 220, 46, 38, 114, 112, 45, 203, 232, 16, 6, 112, 95, 205, 83, 205, 92, 249, 225, 51]), (bytes [29, 217, 189, 89, 151, 246, 187, 208, 140, 159, 85, 103, 77, 104, 217, 4, 240, 201, 192, 135, 37, 250, 218, 243, 219, 70, 188, 1, 131, 20, 143, 164]), (bytes [218, 15, 164, 119, 26, 89, 153, 76, 195, 50, 55, 158, 39, 57, 253, 24, 64, 230, 89, 54, 164, 47, 223, 90, 24, 194, 243, 188, 112, 39, 74, 0]), (bytes [249, 165, 44, 168, 18, 125, 65, 76, 51, 110, 93, 193, 12, 212, 163, 81, 53, 26, 162, 66, 63, 100, 116, 243, 112, 137, 118, 14, 176, 24, 222, 159]), (bytes [11, 185, 133, 252, 50, 244, 35, 237, 167, 173, 175, 155, 13, 76, 146, 252, 114, 4, 198, 228, 91, 62, 90, 251, 253, 108, 66, 173, 181, 43, 114, 60]), (bytes [118, 104, 94, 12, 171, 3, 100, 43, 163, 51, 98, 0, 105, 201, 187, 207, 164, 190, 117, 22, 243, 3, 26, 197, 37, 180, 195, 107, 243, 137, 220, 124]), (bytes [163, 65, 0, 229, 155, 105, 235, 6, 98, 248, 24, 117, 182, 245, 253, 107, 41, 53, 94, 249, 6, 94, 26, 77, 116, 211, 3, 138, 34, 184, 92, 62]), (bytes [166, 212, 193, 165, 216, 77, 223, 22, 85, 148, 36, 46, 240, 197, 91, 192, 178, 249, 84, 99, 56, 189, 17, 175, 26, 146, 194, 235, 103, 203, 78, 106]), (bytes [185, 205, 148, 118, 221, 133, 170, 5, 227, 183, 106, 29, 38, 170, 245, 219, 225, 31, 101, 192, 28, 113, 185, 107, 3, 209, 206, 46, 192, 200, 44, 81]), (bytes [222, 141, 194, 19, 109, 181, 115, 128, 236, 90, 109, 50, 95, 37, 244, 239, 168, 246, 17, 195, 87, 245, 230, 227, 255, 210, 73, 185, 49, 105, 109, 248]), (bytes [83, 103, 3, 75, 9, 33, 248, 240, 3, 92, 111, 187, 27, 152, 47, 192, 237, 17, 71, 35, 227, 187, 140, 184, 160, 92, 191, 56, 81, 5, 51, 116]), (bytes [83, 232, 66, 239, 59, 2, 156, 145, 221, 98, 42, 75, 125, 205, 204, 123, 158, 238, 163, 227, 197, 173, 25, 243, 204, 223, 93, 186, 149, 245, 58, 7]), (bytes [51, 147, 200, 72, 91, 38, 180, 66, 102, 246, 249, 59, 248, 210, 206, 122, 171, 75, 43, 129, 133, 20, 204, 87, 175, 151, 246, 36, 59, 58, 55, 54]), (bytes [61, 169, 61, 118, 122, 118, 139, 112, 180, 2, 225, 125, 1, 241, 243, 209, 64, 94, 20, 252, 240, 64, 93, 21, 190, 0, 165, 42, 205, 8, 253, 178]), (bytes [231, 90, 188, 219, 85, 37, 169, 164, 156, 230, 215, 236, 253, 31, 99, 199, 6, 215, 157, 254, 79, 211, 182, 31, 154, 20, 40, 93, 13, 201, 63, 92]), (bytes [207, 240, 74, 100, 136, 151, 53, 114, 95, 100, 101, 150, 5, 171, 152, 112, 93, 233, 25, 87, 110, 174, 32, 232, 81, 209, 187, 254, 107, 190, 140, 165]), (bytes [231, 38, 189, 225, 191, 28, 138, 109, 137, 172, 136, 41, 0, 71, 10, 98, 82, 251, 63, 57, 134, 215, 207, 171, 22, 74, 131, 24, 248, 187, 249, 139]), (bytes [97, 115, 66, 52, 209, 119, 244, 26, 211, 179, 72, 158, 73, 50, 167, 139, 193, 248, 17, 168, 194, 18, 40, 36, 247, 217, 33, 69, 229, 217, 187, 137]), (bytes [104, 29, 194, 189, 239, 145, 194, 228, 166, 76, 154, 100, 169, 199, 26, 134, 252, 202, 252, 43, 213, 142, 242, 213, 255, 181, 81, 2, 47, 120, 226, 78]), (bytes [235, 49, 191, 128, 17, 252, 43, 130, 234, 138, 63, 235, 22, 122, 39, 9, 154, 168, 135, 151, 54, 180, 125, 133, 235, 6, 32, 243, 247, 58, 14, 141]), (bytes [203, 190, 166, 159, 209, 140, 180, 196, 75, 57, 130, 2, 89, 126, 203, 127, 16, 89, 187, 132, 95, 49, 171, 164, 127, 162, 189, 129, 74, 157, 57, 123]), (bytes [33, 214, 126, 87, 207, 101, 162, 210, 45, 167, 156, 227, 80, 125, 250, 219, 226, 223, 53, 255, 164, 250, 108, 120, 67, 180, 142, 80, 57, 57, 208, 227]), (bytes [62, 7, 150, 11, 99, 98, 7, 110, 228, 135, 72, 232, 238, 53, 224, 30, 95, 75, 71, 72, 114, 247, 48, 12, 96, 132, 25, 33, 74, 63, 170, 176]), (bytes [66, 40, 11, 18, 100, 132, 218, 135, 50, 222, 36, 13, 230, 231, 227, 22, 14, 154, 65, 49, 70, 93, 240, 181, 195, 51, 222, 94, 195, 49, 12, 83]), (bytes [142, 185, 27, 84, 132, 190, 160, 121, 218, 162, 8, 170, 126, 198, 197, 139, 11, 168, 143, 88, 101, 75, 56, 240, 14, 204, 255, 67, 55, 121, 123, 195])], familyDigest := (bytes [148, 205, 89, 58, 104, 78, 64, 182, 143, 33, 124, 5, 186, 221, 99, 123, 123, 22, 87, 140, 176, 14, 0, 111, 30, 232, 141, 48, 17, 212, 190, 140]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [148, 205, 89, 58, 104, 78, 64, 182, 143, 33, 124, 5, 186, 221, 99, 123, 123, 22, 87, 140, 176, 14, 0, 111, 30, 232, 141, 48, 17, 212, 190, 140]), layoutVersion := 1, digest := (bytes [84, 230, 187, 51, 108, 175, 121, 85, 61, 172, 28, 197, 57, 253, 21, 44, 4, 95, 34, 8, 129, 70, 100, 102, 169, 168, 125, 151, 58, 14, 80, 22]) }, logicalIndex := 0, digest := (bytes [33, 222, 236, 140, 152, 132, 200, 6, 98, 222, 232, 153, 56, 64, 78, 183, 86, 239, 200, 156, 54, 167, 4, 32, 180, 158, 128, 41, 109, 212, 87, 64]) }, valueDigest := (bytes [195, 104, 190, 242, 104, 180, 234, 122, 108, 245, 168, 232, 122, 59, 5, 141, 148, 97, 161, 16, 201, 133, 162, 230, 49, 127, 153, 215, 226, 163, 192, 66]), digest := (bytes [21, 76, 16, 225, 119, 225, 104, 218, 203, 54, 249, 87, 162, 148, 36, 96, 143, 247, 221, 93, 203, 152, 105, 157, 96, 209, 60, 199, 248, 165, 137, 99]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [148, 205, 89, 58, 104, 78, 64, 182, 143, 33, 124, 5, 186, 221, 99, 123, 123, 22, 87, 140, 176, 14, 0, 111, 30, 232, 141, 48, 17, 212, 190, 140]), layoutVersion := 1, digest := (bytes [84, 230, 187, 51, 108, 175, 121, 85, 61, 172, 28, 197, 57, 253, 21, 44, 4, 95, 34, 8, 129, 70, 100, 102, 169, 168, 125, 151, 58, 14, 80, 22]) }, logicalIndex := 4, digest := (bytes [167, 107, 119, 68, 241, 43, 38, 31, 166, 248, 2, 16, 126, 226, 211, 250, 159, 22, 151, 250, 26, 19, 129, 35, 237, 246, 88, 82, 70, 183, 22, 254]) }, valueDigest := (bytes [247, 8, 91, 86, 174, 60, 198, 248, 80, 76, 136, 253, 192, 49, 138, 233, 64, 183, 153, 201, 60, 173, 121, 212, 113, 120, 175, 228, 9, 127, 13, 255]), digest := (bytes [191, 86, 73, 89, 202, 171, 100, 227, 63, 148, 86, 216, 15, 140, 225, 129, 192, 7, 28, 191, 58, 145, 62, 86, 71, 244, 220, 148, 207, 179, 38, 151]) }), digest := (bytes [87, 192, 20, 226, 96, 100, 216, 246, 52, 69, 119, 139, 107, 145, 196, 12, 158, 110, 172, 91, 42, 240, 104, 76, 32, 255, 60, 5, 246, 41, 158, 130]) }
  , rootLaneCommitment := { timeLen := 5, commitments := { commitmentCount := 38, digest := (bytes [116, 251, 70, 72, 221, 18, 150, 52, 56, 144, 53, 94, 3, 160, 21, 161, 1, 65, 160, 196, 197, 83, 136, 169, 243, 157, 187, 95, 225, 79, 192, 55]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [116, 251, 70, 72, 221, 18, 150, 52, 56, 144, 53, 94, 3, 160, 21, 161, 1, 65, 160, 196, 197, 83, 136, 169, 243, 157, 187, 95, 225, 79, 192, 55]), layoutVersion := 3, digest := (bytes [190, 153, 87, 41, 90, 212, 192, 33, 101, 235, 172, 224, 206, 214, 250, 84, 240, 24, 180, 142, 135, 2, 21, 234, 179, 184, 255, 106, 239, 168, 181, 38]) }, logicalIndex := 0, digest := (bytes [85, 138, 25, 175, 106, 163, 9, 238, 123, 168, 154, 149, 39, 92, 47, 219, 123, 192, 182, 193, 224, 112, 108, 4, 2, 97, 154, 54, 47, 99, 182, 254]) }, valueDigest := (bytes [195, 104, 190, 242, 104, 180, 234, 122, 108, 245, 168, 232, 122, 59, 5, 141, 148, 97, 161, 16, 201, 133, 162, 230, 49, 127, 153, 215, 226, 163, 192, 66]), digest := (bytes [15, 172, 155, 22, 227, 145, 252, 231, 88, 127, 85, 247, 69, 104, 141, 208, 221, 173, 84, 44, 69, 35, 13, 90, 97, 115, 91, 47, 220, 8, 13, 248]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [116, 251, 70, 72, 221, 18, 150, 52, 56, 144, 53, 94, 3, 160, 21, 161, 1, 65, 160, 196, 197, 83, 136, 169, 243, 157, 187, 95, 225, 79, 192, 55]), layoutVersion := 3, digest := (bytes [190, 153, 87, 41, 90, 212, 192, 33, 101, 235, 172, 224, 206, 214, 250, 84, 240, 24, 180, 142, 135, 2, 21, 234, 179, 184, 255, 106, 239, 168, 181, 38]) }, logicalIndex := 4, digest := (bytes [69, 78, 220, 18, 192, 56, 35, 154, 217, 122, 36, 41, 100, 181, 92, 125, 242, 57, 252, 183, 199, 205, 155, 159, 254, 251, 228, 186, 123, 83, 47, 103]) }, valueDigest := (bytes [247, 8, 91, 86, 174, 60, 198, 248, 80, 76, 136, 253, 192, 49, 138, 233, 64, 183, 153, 201, 60, 173, 121, 212, 113, 120, 175, 228, 9, 127, 13, 255]), digest := (bytes [156, 67, 4, 130, 236, 171, 74, 254, 227, 134, 5, 49, 195, 32, 22, 209, 194, 114, 73, 201, 235, 241, 120, 182, 151, 14, 54, 141, 95, 75, 74, 233]) }), digest := (bytes [27, 36, 48, 10, 198, 252, 81, 218, 111, 103, 230, 103, 89, 168, 41, 146, 70, 247, 57, 93, 236, 222, 102, 157, 121, 247, 153, 254, 74, 187, 229, 144]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [87, 192, 20, 226, 96, 100, 216, 246, 52, 69, 119, 139, 107, 145, 196, 12, 158, 110, 172, 91, 42, 240, 104, 76, 32, 255, 60, 5, 246, 41, 158, 130]), rootLaneCommitmentDigest := (bytes [27, 36, 48, 10, 198, 252, 81, 218, 111, 103, 230, 103, 89, 168, 41, 146, 70, 247, 57, 93, 236, 222, 102, 157, 121, 247, 153, 254, 74, 187, 229, 144]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 5, digest := (bytes [162, 114, 160, 176, 3, 193, 26, 204, 220, 193, 15, 215, 38, 15, 2, 29, 235, 69, 196, 87, 17, 45, 175, 62, 71, 208, 199, 117, 253, 107, 62, 170]) }, statementDigest := (bytes [32, 65, 185, 77, 24, 58, 28, 218, 212, 29, 45, 129, 123, 151, 43, 73, 150, 153, 255, 154, 122, 186, 217, 44, 101, 231, 211, 182, 154, 195, 42, 64]), proofDigest := (bytes [40, 15, 29, 146, 94, 67, 107, 120, 15, 89, 88, 104, 107, 38, 137, 69, 158, 87, 139, 148, 41, 23, 245, 148, 116, 231, 113, 44, 149, 53, 139, 88]), digest := (bytes [221, 82, 176, 224, 111, 78, 62, 71, 41, 191, 205, 45, 115, 229, 13, 40, 251, 83, 99, 59, 161, 240, 78, 80, 118, 32, 228, 17, 150, 61, 100, 246]) }
  , digest := (bytes [232, 42, 24, 12, 101, 125, 72, 7, 79, 121, 120, 196, 107, 10, 168, 84, 93, 36, 231, 121, 73, 65, 136, 68, 77, 217, 231, 32, 101, 213, 9, 40])
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
    , stage1 := stage1
    , stage2 := stage2
    , stage3 := stage3
    , rootExecution := rootExecution
    , stepComposition := stepComposition
    , soundnessAccounting := soundnessAccounting
    , kernelOpeningBundle := kernelOpeningBundle
    , digest := (bytes [241, 131, 219, 44, 208, 54, 3, 166, 116, 101, 4, 92, 211, 9, 117, 143, 92, 199, 88, 217, 138, 160, 69, 59, 1, 133, 146, 104, 48, 122, 212, 199])
  }

end Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors.Case_vertical_add_sd_ld_ecall
