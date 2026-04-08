import Nightstream.Rv64IM.Generated.AcceptedProofArtifactTypes

set_option maxHeartbeats 0
set_option maxRecDepth 65536

namespace Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors.Case_native_word_shift_chain_ecall

open Nightstream.Rv64IM.Generated

def stage1SemInputs : List SemInView :=
  [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, pc := 0, opcode := .slliw, traceOpcode := (some .slliw), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 1, archRs1Value := 1, archRs2 := 0, archRs2Value := 0, archRd := 3, archRdBefore := 0, archImm := 31, rs1 := 1, rs1Value := 1, rs2 := 0, rs2Value := 0, rd := 3, rdBefore := 0, rdAfter := 18446744071562067968, imm := 31, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, pc := 4, opcode := .srliw, traceOpcode := (some .srliw), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 2, archRs1Value := 18446744071562067968, archRs2 := 0, archRs2Value := 0, archRd := 4, archRdBefore := 0, archImm := 4, rs1 := 2, rs1Value := 18446744071562067968, rs2 := 0, rs2Value := 0, rd := 4, rdBefore := 0, rdAfter := 134217728, imm := 4, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, pc := 8, opcode := .sraiw, traceOpcode := (some .sraiw), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 2, archRs1Value := 18446744071562067968, archRs2 := 0, archRs2Value := 0, archRd := 5, archRdBefore := 0, archImm := 4, rs1 := 2, rs1Value := 18446744071562067968, rs2 := 0, rs2Value := 0, rd := 5, rdBefore := 0, rdAfter := 18446744073575333888, imm := 4, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, pc := 12, opcode := .sllw, traceOpcode := (some .sllw), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 1, archRs1Value := 1, archRs2 := 6, archRs2Value := 40, archRd := 7, archRdBefore := 0, archImm := 0, rs1 := 1, rs1Value := 1, rs2 := 6, rs2Value := 40, rd := 7, rdBefore := 0, rdAfter := 256, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 4, stepIndex := 4, sequenceIndex := 0, pc := 16, opcode := .srlw, traceOpcode := (some .srlw), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 2, archRs1Value := 18446744071562067968, archRs2 := 6, archRs2Value := 40, archRd := 8, archRdBefore := 0, archImm := 0, rs1 := 2, rs1Value := 18446744071562067968, rs2 := 6, rs2Value := 40, rd := 8, rdBefore := 0, rdAfter := 8388608, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 5, stepIndex := 5, sequenceIndex := 0, pc := 20, opcode := .sraw, traceOpcode := (some .sraw), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 2, archRs1Value := 18446744071562067968, archRs2 := 6, archRs2Value := 40, archRd := 9, archRdBefore := 0, archImm := 0, rs1 := 2, rs1Value := 18446744071562067968, rs2 := 6, rs2Value := 40, rd := 9, rdBefore := 0, rdAfter := 18446744073701163008, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 6, stepIndex := 6, sequenceIndex := 0, pc := 24, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 0, archRdBefore := 0, archImm := 0, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 0, rdBefore := 0, rdAfter := 0, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := false, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }]

def stage1RowBindings : List Stage1RowBindingView :=
  [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 32543131, opcode := .slliw, traceOpcode := (some .slliw), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 4, aluResult := 18446744071562067968, effectiveAddr := none, writesRd := true, rd := 3, rdAfter := 18446744071562067968, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 4280859, opcode := .srliw, traceOpcode := (some .srliw), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 8, aluResult := 134217728, effectiveAddr := none, writesRd := true, rd := 4, rdAfter := 134217728, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 1078022811, opcode := .sraiw, traceOpcode := (some .sraiw), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 12, aluResult := 18446744073575333888, effectiveAddr := none, writesRd := true, rd := 5, rdAfter := 18446744073575333888, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 12, fetchedWord := 6329275, opcode := .sllw, traceOpcode := (some .sllw), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 16, aluResult := 256, effectiveAddr := none, writesRd := true, rd := 7, rdAfter := 256, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 4, stepIndex := 4, sequenceIndex := 0, fetchPc := 16, fetchedWord := 6378555, opcode := .srlw, traceOpcode := (some .srlw), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 20, aluResult := 8388608, effectiveAddr := none, writesRd := true, rd := 8, rdAfter := 8388608, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 5, stepIndex := 5, sequenceIndex := 0, fetchPc := 20, fetchedWord := 1080120507, opcode := .sraw, traceOpcode := (some .sraw), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 24, aluResult := 18446744073701163008, effectiveAddr := none, writesRd := true, rd := 9, rdAfter := 18446744073701163008, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 6, stepIndex := 6, sequenceIndex := 0, fetchPc := 24, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 28, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }]

def stage1 : Stage1ProofBundleView :=
  {
    semInputs := stage1SemInputs
    , rowBindings := stage1RowBindings
    , bytecodeDigest := (bytes [112, 4, 7, 121, 1, 122, 61, 180, 42, 74, 251, 178, 250, 203, 119, 226, 63, 202, 173, 201, 109, 180, 233, 236, 244, 170, 2, 106, 82, 61, 221, 11])
    , aluDigest := (bytes [75, 74, 84, 215, 105, 190, 108, 190, 176, 151, 111, 139, 244, 72, 166, 52, 186, 157, 142, 127, 202, 100, 100, 186, 67, 249, 40, 84, 243, 186, 22, 17])
    , branchDigest := (bytes [31, 52, 12, 147, 182, 253, 82, 17, 29, 166, 135, 125, 167, 146, 24, 136, 159, 103, 0, 174, 23, 91, 7, 135, 200, 128, 27, 173, 52, 113, 187, 188])
    , semantics := { semInputsDigest := (bytes [2, 39, 160, 128, 30, 243, 187, 10, 85, 84, 146, 239, 17, 71, 241, 162, 225, 34, 203, 98, 123, 68, 118, 230, 245, 25, 11, 242, 122, 219, 238, 108]), rowBindingsDigest := (bytes [166, 30, 104, 110, 208, 95, 171, 168, 234, 205, 252, 19, 212, 142, 127, 59, 83, 57, 19, 248, 246, 26, 72, 101, 223, 1, 158, 154, 121, 68, 105, 218]), sequenceCount := 7, helperRowCount := 0, digest := (bytes [242, 252, 217, 79, 166, 127, 218, 134, 240, 55, 245, 110, 33, 119, 104, 154, 76, 56, 236, 126, 121, 15, 156, 185, 164, 46, 92, 226, 67, 33, 43, 109]) }
    , addressCorrectnessDigest := (bytes [34, 248, 60, 80, 244, 42, 183, 107, 114, 68, 246, 101, 43, 192, 160, 17, 240, 76, 91, 99, 112, 41, 62, 238, 162, 146, 179, 63, 80, 151, 40, 122])
    , linkageDigest := (bytes [92, 204, 52, 214, 230, 110, 231, 39, 247, 92, 181, 49, 223, 110, 101, 199, 108, 121, 31, 184, 0, 1, 225, 157, 51, 5, 207, 166, 6, 169, 101, 153])
    , selectedOpening := { claim := { rowsFamilyDigest := (bytes [166, 30, 104, 110, 208, 95, 171, 168, 234, 205, 252, 19, 212, 142, 127, 59, 83, 57, 19, 248, 246, 26, 72, 101, 223, 1, 158, 154, 121, 68, 105, 218]), rowCount := 7, effectRowCount := 7, commitRowCount := 7, realRowCount := 7, preservesX0Count := 1, firstTraceIndex := 0, effectTraceIndex := 0, commitTraceIndex := 0, lastTraceIndex := 6, mix := 16632802919108710147, points := { first := { id := { object := { familyTag := 1, commitmentDigest := (bytes [166, 30, 104, 110, 208, 95, 171, 168, 234, 205, 252, 19, 212, 142, 127, 59, 83, 57, 19, 248, 246, 26, 72, 101, 223, 1, 158, 154, 121, 68, 105, 218]), layoutVersion := 1, digest := (bytes [249, 24, 4, 138, 242, 178, 147, 156, 177, 6, 53, 254, 108, 254, 76, 9, 28, 45, 20, 223, 118, 231, 86, 118, 72, 20, 117, 151, 167, 46, 189, 36]) }, logicalIndex := 0, digest := (bytes [95, 236, 84, 241, 47, 34, 33, 92, 23, 170, 63, 184, 75, 48, 166, 5, 156, 239, 149, 141, 127, 70, 221, 180, 180, 95, 21, 246, 243, 50, 188, 233]) }, valueDigest := (bytes [232, 47, 34, 16, 1, 137, 24, 40, 39, 50, 53, 83, 252, 74, 6, 101, 1, 23, 115, 242, 22, 149, 147, 221, 150, 159, 212, 55, 66, 245, 125, 210]), digest := (bytes [149, 146, 155, 246, 235, 181, 39, 78, 20, 2, 54, 192, 1, 21, 251, 132, 166, 143, 36, 206, 52, 217, 90, 58, 77, 192, 174, 144, 222, 143, 59, 99]) }, effect := { id := { object := { familyTag := 1, commitmentDigest := (bytes [166, 30, 104, 110, 208, 95, 171, 168, 234, 205, 252, 19, 212, 142, 127, 59, 83, 57, 19, 248, 246, 26, 72, 101, 223, 1, 158, 154, 121, 68, 105, 218]), layoutVersion := 1, digest := (bytes [249, 24, 4, 138, 242, 178, 147, 156, 177, 6, 53, 254, 108, 254, 76, 9, 28, 45, 20, 223, 118, 231, 86, 118, 72, 20, 117, 151, 167, 46, 189, 36]) }, logicalIndex := 0, digest := (bytes [95, 236, 84, 241, 47, 34, 33, 92, 23, 170, 63, 184, 75, 48, 166, 5, 156, 239, 149, 141, 127, 70, 221, 180, 180, 95, 21, 246, 243, 50, 188, 233]) }, valueDigest := (bytes [232, 47, 34, 16, 1, 137, 24, 40, 39, 50, 53, 83, 252, 74, 6, 101, 1, 23, 115, 242, 22, 149, 147, 221, 150, 159, 212, 55, 66, 245, 125, 210]), digest := (bytes [149, 146, 155, 246, 235, 181, 39, 78, 20, 2, 54, 192, 1, 21, 251, 132, 166, 143, 36, 206, 52, 217, 90, 58, 77, 192, 174, 144, 222, 143, 59, 99]) }, commit := { id := { object := { familyTag := 1, commitmentDigest := (bytes [166, 30, 104, 110, 208, 95, 171, 168, 234, 205, 252, 19, 212, 142, 127, 59, 83, 57, 19, 248, 246, 26, 72, 101, 223, 1, 158, 154, 121, 68, 105, 218]), layoutVersion := 1, digest := (bytes [249, 24, 4, 138, 242, 178, 147, 156, 177, 6, 53, 254, 108, 254, 76, 9, 28, 45, 20, 223, 118, 231, 86, 118, 72, 20, 117, 151, 167, 46, 189, 36]) }, logicalIndex := 0, digest := (bytes [95, 236, 84, 241, 47, 34, 33, 92, 23, 170, 63, 184, 75, 48, 166, 5, 156, 239, 149, 141, 127, 70, 221, 180, 180, 95, 21, 246, 243, 50, 188, 233]) }, valueDigest := (bytes [232, 47, 34, 16, 1, 137, 24, 40, 39, 50, 53, 83, 252, 74, 6, 101, 1, 23, 115, 242, 22, 149, 147, 221, 150, 159, 212, 55, 66, 245, 125, 210]), digest := (bytes [149, 146, 155, 246, 235, 181, 39, 78, 20, 2, 54, 192, 1, 21, 251, 132, 166, 143, 36, 206, 52, 217, 90, 58, 77, 192, 174, 144, 222, 143, 59, 99]) }, last := { id := { object := { familyTag := 1, commitmentDigest := (bytes [166, 30, 104, 110, 208, 95, 171, 168, 234, 205, 252, 19, 212, 142, 127, 59, 83, 57, 19, 248, 246, 26, 72, 101, 223, 1, 158, 154, 121, 68, 105, 218]), layoutVersion := 1, digest := (bytes [249, 24, 4, 138, 242, 178, 147, 156, 177, 6, 53, 254, 108, 254, 76, 9, 28, 45, 20, 223, 118, 231, 86, 118, 72, 20, 117, 151, 167, 46, 189, 36]) }, logicalIndex := 6, digest := (bytes [148, 162, 116, 79, 181, 61, 176, 3, 26, 191, 224, 192, 91, 184, 182, 5, 25, 233, 179, 85, 88, 8, 8, 92, 88, 66, 255, 102, 179, 184, 199, 125]) }, valueDigest := (bytes [144, 146, 44, 41, 133, 23, 223, 236, 99, 134, 115, 57, 158, 12, 98, 154, 145, 46, 153, 64, 27, 39, 123, 216, 84, 198, 167, 47, 23, 105, 12, 146]), digest := (bytes [216, 150, 235, 131, 250, 240, 203, 190, 239, 249, 65, 251, 47, 52, 203, 74, 196, 132, 243, 22, 108, 127, 64, 224, 127, 38, 164, 183, 234, 80, 54, 42]) } }, digest := (bytes [91, 46, 85, 41, 167, 237, 224, 210, 189, 155, 64, 145, 2, 145, 248, 67, 13, 84, 191, 29, 34, 16, 226, 134, 70, 10, 237, 162, 203, 8, 195, 16]) }, packaged := { statementDigest := (bytes [194, 144, 120, 187, 149, 247, 96, 0, 24, 117, 58, 116, 123, 171, 165, 235, 14, 101, 186, 107, 159, 31, 36, 161, 232, 78, 212, 151, 164, 38, 3, 147]), proofDigest := (bytes [49, 59, 95, 16, 229, 92, 205, 1, 92, 43, 197, 106, 35, 210, 227, 40, 131, 185, 66, 148, 121, 159, 118, 23, 237, 253, 75, 9, 194, 98, 6, 162]) }, digest := (bytes [13, 241, 159, 115, 93, 17, 40, 130, 124, 132, 244, 152, 177, 67, 162, 99, 128, 52, 150, 89, 169, 233, 250, 14, 22, 230, 133, 180, 185, 38, 56, 139]) }
    , digest := (bytes [141, 203, 3, 220, 115, 73, 89, 58, 188, 90, 217, 55, 96, 102, 186, 183, 151, 76, 234, 31, 178, 58, 75, 232, 106, 101, 139, 16, 49, 25, 9, 58])
  }

def stage2RegisterReads : List RegisterReadEventView :=
  [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 1, value := 1 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 2, value := 18446744071562067968 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 2, value := 18446744071562067968 }, { traceIndex := 3, stepIndex := 3, role := .rs1, reg := 1, value := 1 }, { traceIndex := 3, stepIndex := 3, role := .rs2, reg := 6, value := 40 }, { traceIndex := 4, stepIndex := 4, role := .rs1, reg := 2, value := 18446744071562067968 }, { traceIndex := 4, stepIndex := 4, role := .rs2, reg := 6, value := 40 }, { traceIndex := 5, stepIndex := 5, role := .rs1, reg := 2, value := 18446744071562067968 }, { traceIndex := 5, stepIndex := 5, role := .rs2, reg := 6, value := 40 }]

def stage2RegisterWrites : List RegisterWriteEventView :=
  [{ traceIndex := 0, stepIndex := 0, reg := 3, previous := 0, next := 18446744071562067968 }, { traceIndex := 1, stepIndex := 1, reg := 4, previous := 0, next := 134217728 }, { traceIndex := 2, stepIndex := 2, reg := 5, previous := 0, next := 18446744073575333888 }, { traceIndex := 3, stepIndex := 3, reg := 7, previous := 0, next := 256 }, { traceIndex := 4, stepIndex := 4, reg := 8, previous := 0, next := 8388608 }, { traceIndex := 5, stepIndex := 5, reg := 9, previous := 0, next := 18446744073701163008 }]

def stage2RamEvents : List RamEventView :=
  []

def stage2TwistLinks : List TwistLinkEventView :=
  [{ traceIndex := 0, stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 18446744071562067968), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 1, family := .nativeAlu, routedWriteValue := (some 134217728), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 2, family := .nativeAlu, routedWriteValue := (some 18446744073575333888), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 3, family := .nativeAlu, routedWriteValue := (some 256), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 4, stepIndex := 4, family := .nativeAlu, routedWriteValue := (some 8388608), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 5, stepIndex := 5, family := .nativeAlu, routedWriteValue := (some 18446744073701163008), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 6, stepIndex := 6, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]

def stage2 : Stage2ProofBundleView :=
  {
    registerReads := stage2RegisterReads
    , registerWrites := stage2RegisterWrites
    , ramEvents := stage2RamEvents
    , registerDigest := (bytes [228, 202, 98, 172, 183, 198, 10, 192, 3, 216, 123, 58, 166, 4, 179, 0, 246, 82, 91, 161, 28, 95, 65, 161, 211, 66, 47, 70, 186, 210, 118, 61])
    , ramDigest := (bytes [209, 217, 105, 43, 209, 229, 156, 61, 92, 164, 94, 232, 52, 214, 73, 229, 72, 188, 139, 122, 165, 123, 201, 212, 205, 15, 247, 197, 165, 154, 109, 246])
    , temporal := { twistLinks := stage2TwistLinks, registerTimelineDigest := (bytes [100, 87, 248, 130, 159, 117, 251, 161, 161, 158, 15, 57, 205, 206, 197, 65, 191, 191, 215, 140, 161, 201, 201, 180, 100, 1, 15, 255, 45, 107, 199, 247]), ramTimelineDigest := (bytes [8, 117, 17, 140, 128, 180, 240, 140, 250, 181, 90, 134, 147, 17, 197, 122, 220, 8, 66, 15, 193, 254, 11, 122, 115, 210, 233, 239, 55, 132, 31, 228]), twistLinksDigest := (bytes [135, 79, 29, 217, 50, 53, 71, 131, 36, 58, 137, 178, 35, 172, 189, 149, 108, 135, 42, 171, 29, 3, 171, 238, 49, 71, 115, 66, 1, 24, 75, 205]), digest := (bytes [250, 255, 100, 0, 6, 195, 177, 182, 93, 175, 162, 60, 23, 131, 124, 88, 110, 251, 98, 175, 153, 7, 141, 98, 58, 15, 172, 125, 57, 170, 151, 233]) }
    , semantics := { registerReadsFamilyDigest := (bytes [186, 231, 176, 51, 3, 146, 238, 159, 217, 163, 247, 128, 53, 41, 196, 192, 167, 226, 85, 223, 94, 225, 17, 232, 154, 145, 156, 200, 38, 153, 233, 84]), registerWritesFamilyDigest := (bytes [43, 158, 101, 64, 136, 149, 252, 1, 113, 102, 237, 183, 147, 187, 2, 185, 68, 176, 152, 52, 188, 249, 147, 0, 83, 183, 109, 204, 127, 64, 155, 208]), ramEventsFamilyDigest := (bytes [85, 17, 108, 38, 84, 5, 109, 213, 145, 137, 203, 96, 117, 127, 130, 193, 117, 29, 27, 219, 228, 58, 7, 214, 144, 155, 66, 38, 127, 8, 241, 95]), twistLinksFamilyDigest := (bytes [126, 54, 196, 95, 192, 103, 208, 135, 137, 81, 136, 103, 41, 128, 42, 30, 49, 220, 57, 37, 109, 101, 63, 85, 196, 180, 68, 221, 93, 211, 13, 237]), rowCount := 7, registerEventCount := 15, ramEventCount := 0, digest := (bytes [208, 11, 85, 111, 230, 131, 170, 96, 181, 108, 145, 135, 130, 174, 99, 228, 188, 42, 189, 154, 65, 50, 100, 169, 0, 67, 14, 110, 32, 165, 225, 212]) }
    , linkageDigest := (bytes [132, 148, 22, 209, 33, 62, 206, 67, 220, 56, 5, 64, 59, 251, 78, 142, 80, 84, 167, 177, 38, 158, 181, 21, 114, 107, 207, 24, 251, 82, 85, 160])
    , selectedOpening := { claim := { registerReadsFamilyDigest := (bytes [186, 231, 176, 51, 3, 146, 238, 159, 217, 163, 247, 128, 53, 41, 196, 192, 167, 226, 85, 223, 94, 225, 17, 232, 154, 145, 156, 200, 38, 153, 233, 84]), registerWritesFamilyDigest := (bytes [43, 158, 101, 64, 136, 149, 252, 1, 113, 102, 237, 183, 147, 187, 2, 185, 68, 176, 152, 52, 188, 249, 147, 0, 83, 183, 109, 204, 127, 64, 155, 208]), ramEventsFamilyDigest := (bytes [85, 17, 108, 38, 84, 5, 109, 213, 145, 137, 203, 96, 117, 127, 130, 193, 117, 29, 27, 219, 228, 58, 7, 214, 144, 155, 66, 38, 127, 8, 241, 95]), twistLinksFamilyDigest := (bytes [126, 54, 196, 95, 192, 103, 208, 135, 137, 81, 136, 103, 41, 128, 42, 30, 49, 220, 57, 37, 109, 101, 63, 85, 196, 180, 68, 221, 93, 211, 13, 237]), registerReadCount := 9, registerWriteCount := 6, ramEventCount := 0, twistLinkCount := 7, ramReadCount := 0, ramWriteCount := 0, regMix := 6139558469011796608, ramMix := 17659153299687098721, points := { firstRead := (some { id := { object := { familyTag := 2, commitmentDigest := (bytes [186, 231, 176, 51, 3, 146, 238, 159, 217, 163, 247, 128, 53, 41, 196, 192, 167, 226, 85, 223, 94, 225, 17, 232, 154, 145, 156, 200, 38, 153, 233, 84]), layoutVersion := 1, digest := (bytes [30, 191, 151, 89, 236, 10, 147, 227, 9, 84, 126, 23, 105, 53, 236, 193, 112, 51, 143, 48, 106, 211, 219, 241, 141, 198, 130, 227, 95, 198, 245, 240]) }, logicalIndex := 0, digest := (bytes [73, 6, 114, 215, 146, 46, 231, 145, 248, 92, 56, 3, 213, 31, 81, 21, 78, 13, 125, 2, 230, 106, 12, 237, 90, 42, 21, 188, 251, 12, 2, 186]) }, valueDigest := (bytes [147, 236, 177, 203, 54, 142, 158, 35, 54, 253, 234, 34, 233, 0, 102, 93, 41, 30, 222, 59, 99, 11, 48, 54, 71, 211, 96, 165, 176, 94, 234, 87]), digest := (bytes [172, 134, 131, 197, 118, 136, 4, 95, 215, 80, 111, 70, 71, 208, 75, 229, 148, 29, 138, 136, 207, 73, 18, 19, 62, 117, 36, 96, 51, 176, 225, 2]) }), lastRead := (some { id := { object := { familyTag := 2, commitmentDigest := (bytes [186, 231, 176, 51, 3, 146, 238, 159, 217, 163, 247, 128, 53, 41, 196, 192, 167, 226, 85, 223, 94, 225, 17, 232, 154, 145, 156, 200, 38, 153, 233, 84]), layoutVersion := 1, digest := (bytes [30, 191, 151, 89, 236, 10, 147, 227, 9, 84, 126, 23, 105, 53, 236, 193, 112, 51, 143, 48, 106, 211, 219, 241, 141, 198, 130, 227, 95, 198, 245, 240]) }, logicalIndex := 8, digest := (bytes [79, 219, 124, 66, 35, 33, 200, 219, 246, 228, 186, 83, 153, 134, 23, 128, 90, 1, 186, 124, 148, 69, 111, 81, 1, 55, 35, 187, 125, 237, 3, 130]) }, valueDigest := (bytes [226, 131, 111, 137, 71, 49, 114, 183, 103, 157, 135, 134, 57, 35, 93, 55, 51, 50, 114, 42, 201, 200, 122, 182, 217, 90, 148, 175, 106, 162, 119, 246]), digest := (bytes [128, 247, 34, 238, 159, 115, 73, 135, 105, 53, 127, 19, 39, 244, 165, 64, 50, 247, 1, 117, 82, 242, 129, 248, 142, 213, 38, 90, 141, 189, 96, 222]) }), firstWrite := (some { id := { object := { familyTag := 3, commitmentDigest := (bytes [43, 158, 101, 64, 136, 149, 252, 1, 113, 102, 237, 183, 147, 187, 2, 185, 68, 176, 152, 52, 188, 249, 147, 0, 83, 183, 109, 204, 127, 64, 155, 208]), layoutVersion := 1, digest := (bytes [61, 249, 248, 0, 137, 196, 251, 188, 243, 41, 10, 148, 25, 121, 189, 248, 11, 81, 217, 118, 128, 36, 110, 90, 43, 194, 73, 251, 4, 183, 3, 138]) }, logicalIndex := 0, digest := (bytes [235, 237, 180, 211, 96, 187, 122, 249, 78, 164, 35, 175, 88, 89, 140, 246, 152, 52, 252, 9, 118, 143, 123, 125, 234, 157, 25, 147, 67, 243, 235, 232]) }, valueDigest := (bytes [103, 28, 222, 65, 21, 165, 15, 89, 153, 35, 102, 127, 71, 144, 64, 132, 131, 172, 206, 162, 224, 207, 69, 189, 84, 76, 230, 21, 119, 255, 208, 35]), digest := (bytes [237, 132, 90, 61, 5, 141, 17, 106, 181, 70, 65, 141, 245, 63, 103, 202, 118, 66, 145, 139, 93, 163, 251, 149, 173, 249, 108, 158, 207, 75, 119, 206]) }), lastWrite := (some { id := { object := { familyTag := 3, commitmentDigest := (bytes [43, 158, 101, 64, 136, 149, 252, 1, 113, 102, 237, 183, 147, 187, 2, 185, 68, 176, 152, 52, 188, 249, 147, 0, 83, 183, 109, 204, 127, 64, 155, 208]), layoutVersion := 1, digest := (bytes [61, 249, 248, 0, 137, 196, 251, 188, 243, 41, 10, 148, 25, 121, 189, 248, 11, 81, 217, 118, 128, 36, 110, 90, 43, 194, 73, 251, 4, 183, 3, 138]) }, logicalIndex := 5, digest := (bytes [5, 11, 182, 66, 218, 220, 75, 35, 129, 4, 8, 74, 65, 66, 13, 202, 38, 221, 59, 175, 27, 188, 101, 247, 91, 65, 237, 149, 169, 99, 76, 168]) }, valueDigest := (bytes [211, 186, 24, 113, 19, 231, 82, 173, 239, 253, 122, 252, 13, 122, 11, 26, 91, 157, 251, 244, 1, 71, 103, 1, 91, 243, 58, 142, 101, 158, 118, 56]), digest := (bytes [188, 222, 132, 110, 245, 220, 189, 0, 49, 187, 70, 148, 133, 115, 150, 22, 192, 219, 241, 237, 147, 50, 64, 28, 58, 63, 70, 156, 80, 186, 82, 151]) }), firstRam := none, lastRam := none, firstTwist := (some { id := { object := { familyTag := 5, commitmentDigest := (bytes [126, 54, 196, 95, 192, 103, 208, 135, 137, 81, 136, 103, 41, 128, 42, 30, 49, 220, 57, 37, 109, 101, 63, 85, 196, 180, 68, 221, 93, 211, 13, 237]), layoutVersion := 1, digest := (bytes [171, 241, 27, 78, 83, 246, 91, 103, 93, 83, 155, 8, 73, 194, 32, 20, 189, 119, 15, 3, 167, 113, 199, 81, 96, 141, 137, 146, 151, 134, 9, 70]) }, logicalIndex := 0, digest := (bytes [40, 48, 39, 197, 93, 53, 224, 226, 108, 93, 198, 71, 97, 242, 62, 154, 134, 128, 18, 45, 63, 243, 238, 98, 248, 169, 159, 71, 178, 14, 50, 159]) }, valueDigest := (bytes [249, 246, 65, 135, 69, 25, 219, 223, 58, 56, 55, 146, 142, 10, 118, 249, 104, 6, 186, 89, 197, 56, 124, 121, 195, 122, 70, 172, 168, 104, 126, 193]), digest := (bytes [136, 117, 89, 222, 142, 140, 137, 165, 26, 117, 123, 121, 255, 143, 38, 66, 23, 176, 13, 140, 100, 67, 48, 54, 75, 28, 123, 108, 183, 200, 85, 243]) }), lastTwist := (some { id := { object := { familyTag := 5, commitmentDigest := (bytes [126, 54, 196, 95, 192, 103, 208, 135, 137, 81, 136, 103, 41, 128, 42, 30, 49, 220, 57, 37, 109, 101, 63, 85, 196, 180, 68, 221, 93, 211, 13, 237]), layoutVersion := 1, digest := (bytes [171, 241, 27, 78, 83, 246, 91, 103, 93, 83, 155, 8, 73, 194, 32, 20, 189, 119, 15, 3, 167, 113, 199, 81, 96, 141, 137, 146, 151, 134, 9, 70]) }, logicalIndex := 6, digest := (bytes [183, 104, 20, 30, 162, 172, 129, 152, 127, 253, 234, 233, 120, 110, 91, 114, 141, 90, 137, 150, 93, 168, 54, 174, 23, 191, 125, 186, 224, 242, 134, 56]) }, valueDigest := (bytes [177, 90, 46, 16, 105, 217, 158, 221, 200, 159, 226, 176, 242, 66, 217, 14, 215, 150, 37, 246, 212, 108, 237, 104, 31, 103, 108, 107, 11, 82, 147, 173]), digest := (bytes [61, 7, 177, 23, 245, 102, 33, 160, 169, 209, 66, 90, 215, 220, 225, 249, 193, 122, 166, 225, 172, 76, 98, 99, 245, 174, 9, 57, 66, 174, 48, 182]) }) }, digest := (bytes [106, 29, 237, 220, 54, 173, 62, 149, 66, 109, 125, 236, 123, 38, 67, 141, 125, 249, 233, 206, 244, 163, 100, 140, 168, 46, 51, 195, 219, 148, 107, 217]) }, packaged := { statementDigest := (bytes [3, 158, 4, 45, 217, 29, 31, 73, 182, 67, 4, 237, 151, 73, 142, 133, 191, 142, 171, 60, 137, 228, 95, 154, 164, 224, 77, 90, 206, 231, 192, 105]), proofDigest := (bytes [186, 99, 45, 55, 122, 200, 66, 30, 61, 3, 255, 105, 101, 126, 185, 13, 50, 172, 122, 171, 24, 126, 102, 180, 44, 107, 172, 170, 181, 146, 163, 90]) }, digest := (bytes [246, 218, 202, 16, 58, 159, 92, 33, 123, 130, 195, 15, 240, 80, 153, 151, 222, 251, 84, 43, 232, 102, 242, 193, 55, 56, 127, 115, 173, 171, 65, 108]) }
    , digest := (bytes [128, 241, 120, 224, 92, 188, 105, 170, 37, 84, 142, 199, 140, 253, 48, 233, 64, 83, 98, 223, 71, 96, 52, 74, 10, 181, 33, 207, 54, 224, 168, 115])
  }

def stage3Continuity : List ContinuityEventView :=
  [{ stepIndex := 0, pc := 0, nextPc := 4, successorPc := (some 4), finalStep := false, continuityHolds := true }, { stepIndex := 1, pc := 4, nextPc := 8, successorPc := (some 8), finalStep := false, continuityHolds := true }, { stepIndex := 2, pc := 8, nextPc := 12, successorPc := (some 12), finalStep := false, continuityHolds := true }, { stepIndex := 3, pc := 12, nextPc := 16, successorPc := (some 16), finalStep := false, continuityHolds := true }, { stepIndex := 4, pc := 16, nextPc := 20, successorPc := (some 20), finalStep := false, continuityHolds := true }, { stepIndex := 5, pc := 20, nextPc := 24, successorPc := (some 24), finalStep := false, continuityHolds := true }, { stepIndex := 6, pc := 24, nextPc := 28, successorPc := none, finalStep := true, continuityHolds := true }]

def stage3 : Stage3ProofBundleView :=
  {
    continuity := stage3Continuity
    , halted := true
    , bridgeDigest := (bytes [86, 103, 197, 195, 175, 230, 234, 229, 138, 175, 224, 111, 20, 152, 207, 96, 171, 239, 105, 92, 224, 160, 7, 223, 44, 187, 231, 91, 40, 122, 54, 114])
    , semantics := { continuityDigest := (bytes [231, 127, 209, 33, 200, 198, 35, 28, 95, 20, 80, 177, 211, 177, 192, 24, 18, 155, 147, 233, 52, 13, 201, 10, 11, 228, 186, 38, 18, 206, 255, 74]), rootSemanticRowsDigest := (bytes [184, 57, 252, 126, 220, 190, 21, 217, 101, 196, 36, 83, 34, 241, 33, 180, 222, 106, 244, 157, 65, 65, 153, 56, 29, 25, 153, 22, 124, 74, 87, 219]), rowChunkRoutesDigest := (bytes [210, 211, 133, 148, 162, 150, 85, 66, 2, 24, 230, 163, 67, 64, 160, 246, 143, 119, 48, 189, 194, 114, 28, 76, 211, 182, 93, 15, 73, 83, 209, 85]), preparedStepBindingsDigest := (bytes [41, 195, 150, 239, 32, 214, 79, 228, 162, 51, 30, 99, 33, 223, 87, 214, 123, 56, 48, 217, 115, 190, 236, 88, 223, 249, 30, 188, 147, 226, 21, 152]), stage2TemporalDigest := (bytes [250, 255, 100, 0, 6, 195, 177, 182, 93, 175, 162, 60, 23, 131, 124, 88, 110, 251, 98, 175, 153, 7, 141, 98, 58, 15, 172, 125, 57, 170, 151, 233]), initialPc := 0, finalPc := 28, realRowCount := 7, firstRealStepIndex := 0, lastRealStepIndex := 6, digest := (bytes [18, 255, 11, 199, 196, 111, 183, 239, 230, 40, 62, 78, 211, 64, 43, 238, 189, 59, 47, 144, 26, 40, 173, 84, 74, 94, 240, 221, 149, 198, 165, 197]) }
    , linkageDigest := (bytes [17, 163, 20, 58, 1, 126, 137, 85, 87, 61, 207, 121, 190, 192, 194, 57, 101, 143, 151, 162, 110, 23, 117, 76, 193, 254, 57, 64, 87, 155, 79, 82])
    , selectedOpening := { claim := { continuityFamilyDigest := (bytes [94, 209, 204, 219, 207, 222, 139, 15, 162, 178, 200, 168, 102, 230, 108, 10, 222, 118, 76, 56, 76, 82, 63, 83, 183, 179, 71, 63, 14, 207, 130, 159]), continuityCount := 7, finalStepCount := 1, halted := true, allContinuityHold := true, continuityMix := 9836651665554253514, points := { firstContinuity := (some { id := { object := { familyTag := 6, commitmentDigest := (bytes [94, 209, 204, 219, 207, 222, 139, 15, 162, 178, 200, 168, 102, 230, 108, 10, 222, 118, 76, 56, 76, 82, 63, 83, 183, 179, 71, 63, 14, 207, 130, 159]), layoutVersion := 1, digest := (bytes [40, 174, 116, 139, 25, 243, 175, 145, 153, 240, 85, 170, 23, 150, 84, 150, 190, 215, 68, 209, 210, 6, 8, 236, 153, 87, 22, 207, 151, 168, 136, 52]) }, logicalIndex := 0, digest := (bytes [237, 15, 183, 29, 215, 126, 189, 58, 103, 246, 57, 89, 234, 208, 198, 46, 25, 0, 100, 80, 171, 37, 200, 69, 38, 250, 136, 86, 100, 176, 41, 56]) }, valueDigest := (bytes [7, 131, 85, 21, 57, 109, 53, 31, 137, 53, 98, 18, 170, 36, 28, 200, 149, 213, 171, 159, 119, 200, 36, 230, 30, 35, 30, 11, 252, 126, 240, 63]), digest := (bytes [9, 171, 35, 175, 184, 12, 28, 139, 81, 227, 110, 197, 202, 210, 109, 24, 113, 26, 226, 78, 132, 222, 80, 0, 45, 255, 1, 70, 236, 206, 54, 109]) }), lastContinuity := (some { id := { object := { familyTag := 6, commitmentDigest := (bytes [94, 209, 204, 219, 207, 222, 139, 15, 162, 178, 200, 168, 102, 230, 108, 10, 222, 118, 76, 56, 76, 82, 63, 83, 183, 179, 71, 63, 14, 207, 130, 159]), layoutVersion := 1, digest := (bytes [40, 174, 116, 139, 25, 243, 175, 145, 153, 240, 85, 170, 23, 150, 84, 150, 190, 215, 68, 209, 210, 6, 8, 236, 153, 87, 22, 207, 151, 168, 136, 52]) }, logicalIndex := 6, digest := (bytes [198, 85, 20, 231, 58, 95, 46, 235, 220, 204, 131, 110, 190, 111, 124, 237, 164, 76, 10, 35, 171, 200, 143, 186, 40, 161, 187, 120, 104, 155, 230, 178]) }, valueDigest := (bytes [109, 97, 69, 254, 146, 244, 236, 80, 140, 232, 150, 9, 211, 236, 70, 18, 119, 149, 140, 71, 61, 248, 99, 170, 171, 200, 158, 31, 232, 41, 83, 47]), digest := (bytes [8, 178, 50, 145, 108, 111, 144, 45, 214, 5, 171, 67, 250, 137, 125, 232, 110, 35, 132, 153, 104, 37, 158, 53, 228, 206, 133, 17, 180, 213, 227, 54]) }) }, digest := (bytes [217, 166, 230, 130, 248, 13, 237, 249, 211, 172, 159, 125, 69, 194, 28, 31, 222, 246, 168, 83, 237, 193, 159, 66, 217, 133, 56, 69, 65, 107, 121, 152]) }, packaged := { statementDigest := (bytes [37, 137, 139, 252, 64, 208, 62, 227, 153, 105, 68, 151, 82, 203, 115, 35, 17, 32, 112, 130, 47, 156, 195, 25, 67, 254, 9, 158, 76, 155, 233, 98]), proofDigest := (bytes [134, 75, 226, 57, 32, 150, 61, 50, 213, 36, 20, 132, 197, 204, 107, 219, 33, 217, 112, 20, 164, 141, 44, 93, 89, 141, 97, 54, 107, 173, 202, 12]) }, digest := (bytes [131, 117, 21, 163, 35, 215, 16, 73, 174, 212, 103, 77, 234, 136, 116, 201, 32, 240, 131, 33, 155, 237, 142, 245, 195, 121, 145, 70, 13, 44, 82, 196]) }
    , digest := (bytes [162, 231, 79, 243, 212, 192, 25, 164, 112, 53, 238, 118, 124, 185, 14, 106, 68, 6, 5, 252, 162, 71, 54, 13, 31, 188, 139, 248, 174, 176, 72, 203])
  }

def rootExecutionExecutionRows : List ExpandedRowView :=
  [{
  traceIndex := 0
  , stepIndex := 0
  , sequenceIndex := 0
  , pc := 0
  , nextPc := 4
  , word := 32543131
  , opcode := .slliw
  , traceOpcode := (some .slliw)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 1
  , rs2 := 0
  , rs2Value := 0
  , rd := 3
  , rdBefore := 0
  , rdAfter := 18446744071562067968
  , imm := 31
  , aluResult := 18446744071562067968
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
  , word := 4280859
  , opcode := .srliw
  , traceOpcode := (some .srliw)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 2
  , rs1Value := 18446744071562067968
  , rs2 := 0
  , rs2Value := 0
  , rd := 4
  , rdBefore := 0
  , rdAfter := 134217728
  , imm := 4
  , aluResult := 134217728
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
  , word := 1078022811
  , opcode := .sraiw
  , traceOpcode := (some .sraiw)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 2
  , rs1Value := 18446744071562067968
  , rs2 := 0
  , rs2Value := 0
  , rd := 5
  , rdBefore := 0
  , rdAfter := 18446744073575333888
  , imm := 4
  , aluResult := 18446744073575333888
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
  , word := 6329275
  , opcode := .sllw
  , traceOpcode := (some .sllw)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 1
  , rs2 := 6
  , rs2Value := 40
  , rd := 7
  , rdBefore := 0
  , rdAfter := 256
  , imm := 0
  , aluResult := 256
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
  , word := 6378555
  , opcode := .srlw
  , traceOpcode := (some .srlw)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 2
  , rs1Value := 18446744071562067968
  , rs2 := 6
  , rs2Value := 40
  , rd := 8
  , rdBefore := 0
  , rdAfter := 8388608
  , imm := 0
  , aluResult := 8388608
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
  , word := 1080120507
  , opcode := .sraw
  , traceOpcode := (some .sraw)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 2
  , rs1Value := 18446744071562067968
  , rs2 := 6
  , rs2Value := 40
  , rd := 9
  , rdBefore := 0
  , rdAfter := 18446744073701163008
  , imm := 0
  , aluResult := 18446744073701163008
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
  [{ traceIndex := 0, values := [1, 0, 0, 4, 0, 1, 0, 0, 0, 2147483648, 4294967295, 31, 0, 2147483648, 4294967295, 4, 0, 0, 0, 0, 0, 0, 0, 3, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [32, 25, 54, 149, 189, 186, 227, 219, 56, 115, 101, 166, 109, 248, 186, 201, 34, 174, 25, 48, 30, 45, 249, 8, 84, 206, 95, 5, 29, 90, 169, 83]), digest := (bytes [107, 248, 224, 191, 57, 190, 79, 15, 240, 192, 132, 106, 155, 80, 93, 27, 116, 197, 229, 108, 65, 158, 11, 46, 47, 252, 199, 91, 37, 246, 126, 247]) }, { traceIndex := 1, values := [1, 4, 0, 8, 0, 2147483648, 4294967295, 0, 0, 134217728, 0, 4, 0, 134217728, 0, 8, 0, 0, 0, 0, 0, 0, 0, 4, 2, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [252, 111, 245, 34, 191, 18, 4, 134, 2, 165, 30, 63, 225, 99, 149, 227, 34, 134, 58, 207, 79, 40, 105, 130, 17, 133, 152, 97, 34, 56, 245, 176]), digest := (bytes [115, 63, 114, 191, 115, 97, 218, 181, 158, 142, 113, 87, 157, 77, 113, 83, 138, 225, 146, 37, 177, 196, 121, 107, 241, 122, 73, 68, 102, 129, 114, 232]) }, { traceIndex := 2, values := [1, 8, 0, 12, 0, 2147483648, 4294967295, 0, 0, 4160749568, 4294967295, 4, 0, 4160749568, 4294967295, 12, 0, 0, 0, 0, 0, 0, 0, 5, 2, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [160, 48, 198, 65, 208, 122, 21, 108, 174, 154, 75, 134, 184, 33, 135, 14, 45, 188, 240, 230, 205, 93, 10, 99, 129, 13, 53, 133, 100, 237, 133, 68]), digest := (bytes [123, 117, 177, 86, 56, 128, 21, 44, 111, 211, 85, 228, 42, 23, 133, 233, 217, 80, 111, 211, 142, 168, 21, 179, 106, 205, 46, 164, 240, 11, 95, 178]) }, { traceIndex := 3, values := [1, 12, 0, 16, 0, 1, 0, 40, 0, 256, 0, 0, 0, 256, 0, 16, 0, 0, 0, 0, 0, 0, 0, 7, 1, 6, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1], rowDigest := (bytes [49, 216, 53, 255, 141, 87, 44, 107, 205, 153, 180, 190, 141, 75, 84, 237, 177, 15, 26, 54, 159, 50, 113, 234, 213, 69, 234, 222, 105, 104, 31, 55]), digest := (bytes [166, 179, 91, 204, 104, 182, 37, 100, 140, 200, 141, 146, 133, 215, 195, 93, 193, 233, 233, 230, 26, 61, 106, 98, 166, 81, 70, 148, 160, 186, 124, 29]) }, { traceIndex := 4, values := [1, 16, 0, 20, 0, 2147483648, 4294967295, 40, 0, 8388608, 0, 0, 0, 8388608, 0, 20, 0, 0, 0, 0, 0, 0, 0, 8, 2, 6, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1], rowDigest := (bytes [122, 143, 199, 224, 76, 38, 123, 73, 135, 142, 197, 107, 168, 209, 188, 178, 214, 195, 144, 216, 86, 211, 153, 183, 7, 174, 174, 108, 18, 181, 211, 78]), digest := (bytes [213, 224, 134, 40, 74, 190, 124, 10, 227, 249, 192, 89, 144, 89, 169, 33, 233, 86, 242, 193, 3, 223, 95, 75, 19, 134, 223, 15, 72, 122, 169, 1]) }, { traceIndex := 5, values := [1, 20, 0, 24, 0, 2147483648, 4294967295, 40, 0, 4286578688, 4294967295, 0, 0, 4286578688, 4294967295, 24, 0, 0, 0, 0, 0, 0, 0, 9, 2, 6, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1], rowDigest := (bytes [172, 213, 64, 213, 73, 50, 154, 50, 100, 160, 81, 229, 188, 137, 74, 89, 55, 177, 132, 172, 91, 18, 184, 136, 233, 21, 168, 206, 67, 177, 145, 154]), digest := (bytes [234, 192, 188, 24, 126, 194, 165, 71, 213, 56, 180, 64, 71, 59, 117, 32, 125, 165, 107, 2, 113, 134, 78, 21, 190, 9, 14, 40, 72, 242, 86, 11]) }, { traceIndex := 6, values := [1, 24, 0, 28, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 28, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [57, 167, 127, 66, 29, 28, 1, 62, 111, 174, 45, 82, 212, 157, 25, 154, 254, 72, 204, 85, 223, 7, 138, 44, 48, 11, 222, 83, 122, 239, 183, 120]), digest := (bytes [53, 245, 127, 106, 55, 210, 83, 63, 162, 14, 12, 212, 9, 132, 72, 57, 29, 12, 230, 88, 252, 251, 47, 87, 51, 251, 133, 205, 8, 86, 144, 88]) }]

def rootExecutionPreparedBindings : List PreparedStepBindingView :=
  [{ traceIndex := 0, rowDigest := (bytes [32, 25, 54, 149, 189, 186, 227, 219, 56, 115, 101, 166, 109, 248, 186, 201, 34, 174, 25, 48, 30, 45, 249, 8, 84, 206, 95, 5, 29, 90, 169, 83]), rowOpeningDigest := (bytes [208, 220, 60, 227, 9, 124, 49, 34, 147, 193, 229, 226, 222, 252, 98, 171, 161, 215, 104, 20, 175, 74, 64, 218, 155, 31, 93, 177, 68, 15, 57, 187]), digest := (bytes [140, 155, 55, 239, 188, 107, 251, 199, 224, 136, 155, 42, 81, 48, 2, 90, 162, 9, 55, 82, 91, 250, 154, 39, 70, 130, 60, 106, 99, 251, 179, 75]) }, { traceIndex := 1, rowDigest := (bytes [252, 111, 245, 34, 191, 18, 4, 134, 2, 165, 30, 63, 225, 99, 149, 227, 34, 134, 58, 207, 79, 40, 105, 130, 17, 133, 152, 97, 34, 56, 245, 176]), rowOpeningDigest := (bytes [26, 233, 115, 21, 209, 128, 62, 201, 52, 46, 150, 26, 143, 160, 248, 61, 189, 207, 57, 65, 70, 98, 81, 39, 191, 127, 190, 152, 168, 213, 99, 122]), digest := (bytes [130, 85, 168, 125, 219, 162, 194, 16, 171, 218, 110, 30, 111, 235, 148, 168, 91, 236, 185, 135, 151, 142, 218, 50, 79, 71, 172, 23, 112, 181, 181, 83]) }, { traceIndex := 2, rowDigest := (bytes [160, 48, 198, 65, 208, 122, 21, 108, 174, 154, 75, 134, 184, 33, 135, 14, 45, 188, 240, 230, 205, 93, 10, 99, 129, 13, 53, 133, 100, 237, 133, 68]), rowOpeningDigest := (bytes [156, 120, 92, 49, 173, 170, 252, 115, 54, 48, 124, 34, 147, 10, 222, 253, 105, 182, 17, 171, 235, 46, 192, 13, 163, 154, 147, 65, 197, 43, 57, 35]), digest := (bytes [197, 20, 79, 129, 160, 248, 144, 207, 25, 6, 0, 6, 152, 22, 21, 181, 110, 155, 231, 89, 196, 235, 83, 226, 144, 7, 132, 170, 46, 242, 254, 106]) }, { traceIndex := 3, rowDigest := (bytes [49, 216, 53, 255, 141, 87, 44, 107, 205, 153, 180, 190, 141, 75, 84, 237, 177, 15, 26, 54, 159, 50, 113, 234, 213, 69, 234, 222, 105, 104, 31, 55]), rowOpeningDigest := (bytes [97, 166, 175, 28, 105, 185, 162, 106, 250, 149, 13, 14, 109, 62, 207, 17, 173, 48, 33, 105, 194, 35, 98, 19, 208, 181, 34, 22, 119, 92, 231, 225]), digest := (bytes [25, 16, 4, 179, 168, 66, 182, 212, 192, 193, 32, 223, 228, 41, 120, 229, 55, 145, 180, 61, 63, 130, 52, 186, 45, 221, 66, 7, 19, 124, 225, 137]) }, { traceIndex := 4, rowDigest := (bytes [122, 143, 199, 224, 76, 38, 123, 73, 135, 142, 197, 107, 168, 209, 188, 178, 214, 195, 144, 216, 86, 211, 153, 183, 7, 174, 174, 108, 18, 181, 211, 78]), rowOpeningDigest := (bytes [185, 31, 196, 126, 28, 28, 75, 59, 208, 161, 62, 143, 231, 81, 78, 185, 160, 71, 42, 17, 36, 187, 147, 245, 49, 147, 63, 51, 72, 164, 150, 142]), digest := (bytes [234, 186, 18, 99, 155, 242, 106, 69, 91, 249, 151, 105, 206, 15, 173, 168, 246, 225, 213, 135, 237, 163, 227, 200, 41, 189, 146, 70, 130, 218, 135, 146]) }, { traceIndex := 5, rowDigest := (bytes [172, 213, 64, 213, 73, 50, 154, 50, 100, 160, 81, 229, 188, 137, 74, 89, 55, 177, 132, 172, 91, 18, 184, 136, 233, 21, 168, 206, 67, 177, 145, 154]), rowOpeningDigest := (bytes [167, 131, 6, 54, 134, 144, 18, 156, 141, 177, 64, 119, 216, 166, 198, 59, 163, 116, 81, 150, 27, 80, 129, 206, 10, 156, 24, 220, 64, 192, 164, 130]), digest := (bytes [210, 50, 25, 162, 9, 12, 94, 190, 154, 110, 159, 55, 77, 118, 188, 144, 189, 77, 232, 17, 104, 179, 152, 242, 28, 21, 254, 121, 38, 94, 60, 100]) }, { traceIndex := 6, rowDigest := (bytes [57, 167, 127, 66, 29, 28, 1, 62, 111, 174, 45, 82, 212, 157, 25, 154, 254, 72, 204, 85, 223, 7, 138, 44, 48, 11, 222, 83, 122, 239, 183, 120]), rowOpeningDigest := (bytes [188, 60, 90, 111, 119, 197, 231, 126, 36, 27, 172, 206, 148, 232, 22, 65, 235, 167, 200, 142, 198, 179, 168, 235, 107, 21, 96, 205, 87, 181, 185, 239]), digest := (bytes [146, 66, 139, 78, 136, 92, 49, 207, 5, 221, 238, 58, 188, 204, 86, 91, 8, 239, 113, 163, 31, 106, 255, 92, 187, 102, 111, 227, 95, 205, 42, 209]) }]

def rootExecutionRowChunkRoutes : List RowChunkRouteView :=
  [{ logicalIndex := 0, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 0, digest := (bytes [138, 198, 109, 126, 144, 82, 221, 43, 248, 202, 137, 103, 62, 226, 249, 152, 163, 187, 1, 254, 36, 33, 59, 16, 64, 166, 202, 8, 219, 57, 240, 59]) }, { logicalIndex := 1, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 1, digest := (bytes [44, 177, 82, 41, 218, 60, 100, 208, 26, 31, 151, 113, 109, 148, 57, 12, 223, 21, 76, 221, 70, 245, 191, 105, 57, 199, 8, 128, 181, 145, 89, 99]) }, { logicalIndex := 2, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 2, digest := (bytes [252, 248, 65, 24, 81, 241, 150, 170, 250, 116, 222, 30, 134, 191, 78, 195, 104, 119, 225, 210, 243, 186, 212, 107, 183, 31, 243, 201, 101, 148, 32, 72]) }, { logicalIndex := 3, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 3, digest := (bytes [244, 11, 162, 13, 59, 43, 232, 47, 228, 2, 70, 126, 95, 10, 57, 40, 46, 107, 197, 81, 97, 39, 185, 163, 93, 60, 5, 66, 7, 231, 199, 134]) }, { logicalIndex := 4, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 4, digest := (bytes [98, 247, 204, 83, 252, 219, 248, 73, 49, 206, 229, 79, 169, 242, 28, 56, 7, 100, 18, 197, 133, 200, 133, 20, 161, 230, 126, 175, 98, 0, 158, 25]) }, { logicalIndex := 5, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 5, digest := (bytes [108, 248, 244, 125, 120, 190, 11, 202, 47, 205, 44, 110, 48, 43, 171, 224, 142, 98, 82, 106, 183, 21, 141, 205, 208, 18, 234, 19, 43, 61, 139, 151]) }, { logicalIndex := 6, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 6, digest := (bytes [213, 163, 43, 1, 32, 112, 128, 155, 10, 34, 241, 205, 79, 46, 234, 45, 239, 83, 213, 254, 45, 65, 13, 152, 217, 78, 36, 105, 42, 193, 181, 13]) }]

def rootExecutionRowLocalCcsAcceptance : List RootRowLocalCcsAcceptanceView :=
  [{ traceIndex := 0, logicalIndex := 0, rowDigest := (bytes [32, 25, 54, 149, 189, 186, 227, 219, 56, 115, 101, 166, 109, 248, 186, 201, 34, 174, 25, 48, 30, 45, 249, 8, 84, 206, 95, 5, 29, 90, 169, 83]), rowOpeningDigest := (bytes [208, 220, 60, 227, 9, 124, 49, 34, 147, 193, 229, 226, 222, 252, 98, 171, 161, 215, 104, 20, 175, 74, 64, 218, 155, 31, 93, 177, 68, 15, 57, 187]), preparedStepBindingDigest := (bytes [140, 155, 55, 239, 188, 107, 251, 199, 224, 136, 155, 42, 81, 48, 2, 90, 162, 9, 55, 82, 91, 250, 154, 39, 70, 130, 60, 106, 99, 251, 179, 75]), rowChunkRouteDigest := (bytes [138, 198, 109, 126, 144, 82, 221, 43, 248, 202, 137, 103, 62, 226, 249, 152, 163, 187, 1, 254, 36, 33, 59, 16, 64, 166, 202, 8, 219, 57, 240, 59]), publicStepDigest := (bytes [89, 192, 10, 46, 9, 78, 29, 141, 76, 49, 251, 131, 241, 32, 126, 64, 25, 154, 135, 248, 157, 57, 213, 222, 76, 222, 235, 103, 110, 133, 65, 107]), digest := (bytes [14, 200, 121, 189, 75, 157, 136, 119, 205, 87, 3, 231, 10, 118, 76, 195, 57, 236, 10, 91, 48, 144, 161, 203, 179, 252, 167, 144, 6, 184, 181, 146]) }, { traceIndex := 1, logicalIndex := 1, rowDigest := (bytes [252, 111, 245, 34, 191, 18, 4, 134, 2, 165, 30, 63, 225, 99, 149, 227, 34, 134, 58, 207, 79, 40, 105, 130, 17, 133, 152, 97, 34, 56, 245, 176]), rowOpeningDigest := (bytes [26, 233, 115, 21, 209, 128, 62, 201, 52, 46, 150, 26, 143, 160, 248, 61, 189, 207, 57, 65, 70, 98, 81, 39, 191, 127, 190, 152, 168, 213, 99, 122]), preparedStepBindingDigest := (bytes [130, 85, 168, 125, 219, 162, 194, 16, 171, 218, 110, 30, 111, 235, 148, 168, 91, 236, 185, 135, 151, 142, 218, 50, 79, 71, 172, 23, 112, 181, 181, 83]), rowChunkRouteDigest := (bytes [44, 177, 82, 41, 218, 60, 100, 208, 26, 31, 151, 113, 109, 148, 57, 12, 223, 21, 76, 221, 70, 245, 191, 105, 57, 199, 8, 128, 181, 145, 89, 99]), publicStepDigest := (bytes [127, 8, 192, 215, 22, 214, 5, 8, 40, 44, 153, 177, 16, 152, 22, 185, 47, 254, 41, 226, 159, 58, 166, 30, 204, 3, 196, 139, 174, 150, 223, 81]), digest := (bytes [54, 94, 89, 12, 173, 52, 248, 139, 37, 156, 33, 25, 115, 233, 244, 9, 179, 215, 120, 170, 28, 19, 86, 130, 192, 185, 205, 212, 248, 9, 147, 28]) }, { traceIndex := 2, logicalIndex := 2, rowDigest := (bytes [160, 48, 198, 65, 208, 122, 21, 108, 174, 154, 75, 134, 184, 33, 135, 14, 45, 188, 240, 230, 205, 93, 10, 99, 129, 13, 53, 133, 100, 237, 133, 68]), rowOpeningDigest := (bytes [156, 120, 92, 49, 173, 170, 252, 115, 54, 48, 124, 34, 147, 10, 222, 253, 105, 182, 17, 171, 235, 46, 192, 13, 163, 154, 147, 65, 197, 43, 57, 35]), preparedStepBindingDigest := (bytes [197, 20, 79, 129, 160, 248, 144, 207, 25, 6, 0, 6, 152, 22, 21, 181, 110, 155, 231, 89, 196, 235, 83, 226, 144, 7, 132, 170, 46, 242, 254, 106]), rowChunkRouteDigest := (bytes [252, 248, 65, 24, 81, 241, 150, 170, 250, 116, 222, 30, 134, 191, 78, 195, 104, 119, 225, 210, 243, 186, 212, 107, 183, 31, 243, 201, 101, 148, 32, 72]), publicStepDigest := (bytes [198, 137, 56, 220, 171, 150, 229, 248, 219, 98, 180, 75, 81, 201, 236, 44, 226, 125, 11, 104, 240, 9, 144, 0, 243, 255, 135, 103, 230, 45, 26, 224]), digest := (bytes [40, 68, 204, 98, 53, 81, 52, 44, 143, 178, 155, 20, 144, 223, 24, 43, 230, 16, 182, 144, 178, 23, 224, 41, 59, 99, 6, 224, 124, 253, 215, 107]) }, { traceIndex := 3, logicalIndex := 3, rowDigest := (bytes [49, 216, 53, 255, 141, 87, 44, 107, 205, 153, 180, 190, 141, 75, 84, 237, 177, 15, 26, 54, 159, 50, 113, 234, 213, 69, 234, 222, 105, 104, 31, 55]), rowOpeningDigest := (bytes [97, 166, 175, 28, 105, 185, 162, 106, 250, 149, 13, 14, 109, 62, 207, 17, 173, 48, 33, 105, 194, 35, 98, 19, 208, 181, 34, 22, 119, 92, 231, 225]), preparedStepBindingDigest := (bytes [25, 16, 4, 179, 168, 66, 182, 212, 192, 193, 32, 223, 228, 41, 120, 229, 55, 145, 180, 61, 63, 130, 52, 186, 45, 221, 66, 7, 19, 124, 225, 137]), rowChunkRouteDigest := (bytes [244, 11, 162, 13, 59, 43, 232, 47, 228, 2, 70, 126, 95, 10, 57, 40, 46, 107, 197, 81, 97, 39, 185, 163, 93, 60, 5, 66, 7, 231, 199, 134]), publicStepDigest := (bytes [56, 97, 158, 237, 217, 150, 171, 175, 111, 182, 40, 43, 4, 40, 117, 223, 138, 57, 73, 130, 55, 250, 248, 159, 56, 193, 121, 224, 221, 218, 165, 8]), digest := (bytes [243, 229, 137, 21, 31, 222, 82, 74, 86, 3, 195, 38, 243, 102, 179, 113, 95, 82, 85, 144, 96, 15, 101, 95, 227, 120, 42, 184, 226, 56, 47, 177]) }, { traceIndex := 4, logicalIndex := 4, rowDigest := (bytes [122, 143, 199, 224, 76, 38, 123, 73, 135, 142, 197, 107, 168, 209, 188, 178, 214, 195, 144, 216, 86, 211, 153, 183, 7, 174, 174, 108, 18, 181, 211, 78]), rowOpeningDigest := (bytes [185, 31, 196, 126, 28, 28, 75, 59, 208, 161, 62, 143, 231, 81, 78, 185, 160, 71, 42, 17, 36, 187, 147, 245, 49, 147, 63, 51, 72, 164, 150, 142]), preparedStepBindingDigest := (bytes [234, 186, 18, 99, 155, 242, 106, 69, 91, 249, 151, 105, 206, 15, 173, 168, 246, 225, 213, 135, 237, 163, 227, 200, 41, 189, 146, 70, 130, 218, 135, 146]), rowChunkRouteDigest := (bytes [98, 247, 204, 83, 252, 219, 248, 73, 49, 206, 229, 79, 169, 242, 28, 56, 7, 100, 18, 197, 133, 200, 133, 20, 161, 230, 126, 175, 98, 0, 158, 25]), publicStepDigest := (bytes [125, 234, 234, 174, 144, 185, 203, 141, 4, 144, 216, 27, 110, 194, 4, 58, 238, 214, 240, 24, 70, 231, 56, 148, 13, 212, 34, 27, 186, 210, 82, 125]), digest := (bytes [128, 199, 116, 145, 242, 90, 191, 134, 120, 202, 111, 251, 169, 255, 156, 139, 131, 10, 29, 148, 145, 141, 120, 254, 125, 146, 124, 41, 108, 203, 143, 247]) }, { traceIndex := 5, logicalIndex := 5, rowDigest := (bytes [172, 213, 64, 213, 73, 50, 154, 50, 100, 160, 81, 229, 188, 137, 74, 89, 55, 177, 132, 172, 91, 18, 184, 136, 233, 21, 168, 206, 67, 177, 145, 154]), rowOpeningDigest := (bytes [167, 131, 6, 54, 134, 144, 18, 156, 141, 177, 64, 119, 216, 166, 198, 59, 163, 116, 81, 150, 27, 80, 129, 206, 10, 156, 24, 220, 64, 192, 164, 130]), preparedStepBindingDigest := (bytes [210, 50, 25, 162, 9, 12, 94, 190, 154, 110, 159, 55, 77, 118, 188, 144, 189, 77, 232, 17, 104, 179, 152, 242, 28, 21, 254, 121, 38, 94, 60, 100]), rowChunkRouteDigest := (bytes [108, 248, 244, 125, 120, 190, 11, 202, 47, 205, 44, 110, 48, 43, 171, 224, 142, 98, 82, 106, 183, 21, 141, 205, 208, 18, 234, 19, 43, 61, 139, 151]), publicStepDigest := (bytes [9, 208, 204, 158, 21, 16, 43, 243, 86, 255, 217, 250, 188, 204, 236, 38, 76, 51, 26, 210, 150, 138, 194, 105, 78, 235, 175, 201, 149, 244, 203, 14]), digest := (bytes [178, 7, 214, 64, 182, 84, 55, 162, 168, 152, 54, 172, 236, 151, 230, 153, 32, 134, 235, 39, 184, 131, 65, 117, 173, 246, 27, 2, 213, 6, 50, 47]) }, { traceIndex := 6, logicalIndex := 6, rowDigest := (bytes [57, 167, 127, 66, 29, 28, 1, 62, 111, 174, 45, 82, 212, 157, 25, 154, 254, 72, 204, 85, 223, 7, 138, 44, 48, 11, 222, 83, 122, 239, 183, 120]), rowOpeningDigest := (bytes [188, 60, 90, 111, 119, 197, 231, 126, 36, 27, 172, 206, 148, 232, 22, 65, 235, 167, 200, 142, 198, 179, 168, 235, 107, 21, 96, 205, 87, 181, 185, 239]), preparedStepBindingDigest := (bytes [146, 66, 139, 78, 136, 92, 49, 207, 5, 221, 238, 58, 188, 204, 86, 91, 8, 239, 113, 163, 31, 106, 255, 92, 187, 102, 111, 227, 95, 205, 42, 209]), rowChunkRouteDigest := (bytes [213, 163, 43, 1, 32, 112, 128, 155, 10, 34, 241, 205, 79, 46, 234, 45, 239, 83, 213, 254, 45, 65, 13, 152, 217, 78, 36, 105, 42, 193, 181, 13]), publicStepDigest := (bytes [188, 255, 114, 147, 11, 230, 48, 155, 108, 50, 225, 167, 192, 101, 38, 131, 177, 181, 218, 166, 156, 3, 42, 148, 169, 202, 204, 45, 34, 34, 223, 74]), digest := (bytes [252, 91, 43, 197, 148, 77, 165, 50, 62, 160, 40, 250, 145, 42, 237, 174, 128, 135, 253, 75, 165, 218, 105, 253, 238, 115, 212, 48, 83, 222, 197, 119]) }]

def rootExecutionExecutionSemanticsRefinement : List RootExecutionSemanticsRefinementView :=
  [{ traceIndex := 0, logicalIndex := 0, semanticRowDigest := (bytes [107, 248, 224, 191, 57, 190, 79, 15, 240, 192, 132, 106, 155, 80, 93, 27, 116, 197, 229, 108, 65, 158, 11, 46, 47, 252, 199, 91, 37, 246, 126, 247]), rowLocalCcsAcceptanceDigest := (bytes [14, 200, 121, 189, 75, 157, 136, 119, 205, 87, 3, 231, 10, 118, 76, 195, 57, 236, 10, 91, 48, 144, 161, 203, 179, 252, 167, 144, 6, 184, 181, 146]), preparedStepBindingDigest := (bytes [140, 155, 55, 239, 188, 107, 251, 199, 224, 136, 155, 42, 81, 48, 2, 90, 162, 9, 55, 82, 91, 250, 154, 39, 70, 130, 60, 106, 99, 251, 179, 75]), publicStepDigest := (bytes [89, 192, 10, 46, 9, 78, 29, 141, 76, 49, 251, 131, 241, 32, 126, 64, 25, 154, 135, 248, 157, 57, 213, 222, 76, 222, 235, 103, 110, 133, 65, 107]), digest := (bytes [11, 149, 11, 11, 42, 0, 193, 38, 196, 184, 99, 177, 104, 185, 73, 225, 39, 92, 189, 213, 79, 199, 144, 112, 170, 223, 42, 164, 28, 223, 145, 30]) }, { traceIndex := 1, logicalIndex := 1, semanticRowDigest := (bytes [115, 63, 114, 191, 115, 97, 218, 181, 158, 142, 113, 87, 157, 77, 113, 83, 138, 225, 146, 37, 177, 196, 121, 107, 241, 122, 73, 68, 102, 129, 114, 232]), rowLocalCcsAcceptanceDigest := (bytes [54, 94, 89, 12, 173, 52, 248, 139, 37, 156, 33, 25, 115, 233, 244, 9, 179, 215, 120, 170, 28, 19, 86, 130, 192, 185, 205, 212, 248, 9, 147, 28]), preparedStepBindingDigest := (bytes [130, 85, 168, 125, 219, 162, 194, 16, 171, 218, 110, 30, 111, 235, 148, 168, 91, 236, 185, 135, 151, 142, 218, 50, 79, 71, 172, 23, 112, 181, 181, 83]), publicStepDigest := (bytes [127, 8, 192, 215, 22, 214, 5, 8, 40, 44, 153, 177, 16, 152, 22, 185, 47, 254, 41, 226, 159, 58, 166, 30, 204, 3, 196, 139, 174, 150, 223, 81]), digest := (bytes [26, 43, 94, 47, 116, 83, 190, 183, 190, 50, 237, 132, 45, 254, 88, 170, 73, 179, 185, 147, 174, 55, 9, 189, 112, 33, 60, 173, 202, 86, 82, 48]) }, { traceIndex := 2, logicalIndex := 2, semanticRowDigest := (bytes [123, 117, 177, 86, 56, 128, 21, 44, 111, 211, 85, 228, 42, 23, 133, 233, 217, 80, 111, 211, 142, 168, 21, 179, 106, 205, 46, 164, 240, 11, 95, 178]), rowLocalCcsAcceptanceDigest := (bytes [40, 68, 204, 98, 53, 81, 52, 44, 143, 178, 155, 20, 144, 223, 24, 43, 230, 16, 182, 144, 178, 23, 224, 41, 59, 99, 6, 224, 124, 253, 215, 107]), preparedStepBindingDigest := (bytes [197, 20, 79, 129, 160, 248, 144, 207, 25, 6, 0, 6, 152, 22, 21, 181, 110, 155, 231, 89, 196, 235, 83, 226, 144, 7, 132, 170, 46, 242, 254, 106]), publicStepDigest := (bytes [198, 137, 56, 220, 171, 150, 229, 248, 219, 98, 180, 75, 81, 201, 236, 44, 226, 125, 11, 104, 240, 9, 144, 0, 243, 255, 135, 103, 230, 45, 26, 224]), digest := (bytes [52, 44, 170, 80, 25, 187, 71, 117, 67, 178, 80, 243, 104, 5, 229, 43, 26, 175, 110, 244, 69, 12, 126, 84, 71, 31, 141, 240, 156, 98, 108, 126]) }, { traceIndex := 3, logicalIndex := 3, semanticRowDigest := (bytes [166, 179, 91, 204, 104, 182, 37, 100, 140, 200, 141, 146, 133, 215, 195, 93, 193, 233, 233, 230, 26, 61, 106, 98, 166, 81, 70, 148, 160, 186, 124, 29]), rowLocalCcsAcceptanceDigest := (bytes [243, 229, 137, 21, 31, 222, 82, 74, 86, 3, 195, 38, 243, 102, 179, 113, 95, 82, 85, 144, 96, 15, 101, 95, 227, 120, 42, 184, 226, 56, 47, 177]), preparedStepBindingDigest := (bytes [25, 16, 4, 179, 168, 66, 182, 212, 192, 193, 32, 223, 228, 41, 120, 229, 55, 145, 180, 61, 63, 130, 52, 186, 45, 221, 66, 7, 19, 124, 225, 137]), publicStepDigest := (bytes [56, 97, 158, 237, 217, 150, 171, 175, 111, 182, 40, 43, 4, 40, 117, 223, 138, 57, 73, 130, 55, 250, 248, 159, 56, 193, 121, 224, 221, 218, 165, 8]), digest := (bytes [121, 161, 97, 255, 39, 19, 119, 240, 247, 252, 235, 207, 153, 42, 157, 22, 94, 234, 59, 56, 59, 251, 200, 17, 145, 75, 21, 239, 62, 61, 123, 37]) }, { traceIndex := 4, logicalIndex := 4, semanticRowDigest := (bytes [213, 224, 134, 40, 74, 190, 124, 10, 227, 249, 192, 89, 144, 89, 169, 33, 233, 86, 242, 193, 3, 223, 95, 75, 19, 134, 223, 15, 72, 122, 169, 1]), rowLocalCcsAcceptanceDigest := (bytes [128, 199, 116, 145, 242, 90, 191, 134, 120, 202, 111, 251, 169, 255, 156, 139, 131, 10, 29, 148, 145, 141, 120, 254, 125, 146, 124, 41, 108, 203, 143, 247]), preparedStepBindingDigest := (bytes [234, 186, 18, 99, 155, 242, 106, 69, 91, 249, 151, 105, 206, 15, 173, 168, 246, 225, 213, 135, 237, 163, 227, 200, 41, 189, 146, 70, 130, 218, 135, 146]), publicStepDigest := (bytes [125, 234, 234, 174, 144, 185, 203, 141, 4, 144, 216, 27, 110, 194, 4, 58, 238, 214, 240, 24, 70, 231, 56, 148, 13, 212, 34, 27, 186, 210, 82, 125]), digest := (bytes [13, 115, 49, 125, 53, 185, 146, 58, 254, 211, 185, 97, 195, 243, 24, 31, 39, 180, 78, 164, 143, 119, 99, 187, 175, 203, 224, 217, 240, 230, 114, 41]) }, { traceIndex := 5, logicalIndex := 5, semanticRowDigest := (bytes [234, 192, 188, 24, 126, 194, 165, 71, 213, 56, 180, 64, 71, 59, 117, 32, 125, 165, 107, 2, 113, 134, 78, 21, 190, 9, 14, 40, 72, 242, 86, 11]), rowLocalCcsAcceptanceDigest := (bytes [178, 7, 214, 64, 182, 84, 55, 162, 168, 152, 54, 172, 236, 151, 230, 153, 32, 134, 235, 39, 184, 131, 65, 117, 173, 246, 27, 2, 213, 6, 50, 47]), preparedStepBindingDigest := (bytes [210, 50, 25, 162, 9, 12, 94, 190, 154, 110, 159, 55, 77, 118, 188, 144, 189, 77, 232, 17, 104, 179, 152, 242, 28, 21, 254, 121, 38, 94, 60, 100]), publicStepDigest := (bytes [9, 208, 204, 158, 21, 16, 43, 243, 86, 255, 217, 250, 188, 204, 236, 38, 76, 51, 26, 210, 150, 138, 194, 105, 78, 235, 175, 201, 149, 244, 203, 14]), digest := (bytes [116, 128, 196, 225, 82, 177, 81, 125, 17, 155, 57, 21, 78, 35, 109, 167, 112, 177, 91, 144, 126, 240, 122, 95, 150, 2, 104, 233, 231, 229, 253, 128]) }, { traceIndex := 6, logicalIndex := 6, semanticRowDigest := (bytes [53, 245, 127, 106, 55, 210, 83, 63, 162, 14, 12, 212, 9, 132, 72, 57, 29, 12, 230, 88, 252, 251, 47, 87, 51, 251, 133, 205, 8, 86, 144, 88]), rowLocalCcsAcceptanceDigest := (bytes [252, 91, 43, 197, 148, 77, 165, 50, 62, 160, 40, 250, 145, 42, 237, 174, 128, 135, 253, 75, 165, 218, 105, 253, 238, 115, 212, 48, 83, 222, 197, 119]), preparedStepBindingDigest := (bytes [146, 66, 139, 78, 136, 92, 49, 207, 5, 221, 238, 58, 188, 204, 86, 91, 8, 239, 113, 163, 31, 106, 255, 92, 187, 102, 111, 227, 95, 205, 42, 209]), publicStepDigest := (bytes [188, 255, 114, 147, 11, 230, 48, 155, 108, 50, 225, 167, 192, 101, 38, 131, 177, 181, 218, 166, 156, 3, 42, 148, 169, 202, 204, 45, 34, 34, 223, 74]), digest := (bytes [248, 134, 175, 128, 29, 200, 154, 41, 56, 85, 71, 238, 159, 132, 6, 80, 66, 83, 217, 45, 159, 5, 82, 220, 180, 229, 133, 11, 51, 61, 23, 172]) }]

def rootExecution : RootExecutionBundleView :=
  {
    executionRows := rootExecutionExecutionRows
    , semanticRows := rootExecutionSemanticRows
    , semanticRowsDigest := (bytes [184, 57, 252, 126, 220, 190, 21, 217, 101, 196, 36, 83, 34, 241, 33, 180, 222, 106, 244, 157, 65, 65, 153, 56, 29, 25, 153, 22, 124, 74, 87, 219])
    , preparedStepBindings := { bindings := rootExecutionPreparedBindings, bindingCount := 7, firstBindingDigest := (some (bytes [140, 155, 55, 239, 188, 107, 251, 199, 224, 136, 155, 42, 81, 48, 2, 90, 162, 9, 55, 82, 91, 250, 154, 39, 70, 130, 60, 106, 99, 251, 179, 75])), lastBindingDigest := (some (bytes [146, 66, 139, 78, 136, 92, 49, 207, 5, 221, 238, 58, 188, 204, 86, 91, 8, 239, 113, 163, 31, 106, 255, 92, 187, 102, 111, 227, 95, 205, 42, 209])), digest := (bytes [41, 195, 150, 239, 32, 214, 79, 228, 162, 51, 30, 99, 33, 223, 87, 214, 123, 56, 48, 217, 115, 190, 236, 88, 223, 249, 30, 188, 147, 226, 21, 152]) }
    , rowChunkRoutes := rootExecutionRowChunkRoutes
    , rowChunkRoutesDigest := (bytes [210, 211, 133, 148, 162, 150, 85, 66, 2, 24, 230, 163, 67, 64, 160, 246, 143, 119, 48, 189, 194, 114, 28, 76, 211, 182, 93, 15, 73, 83, 209, 85])
    , rowLocalCcsAcceptance := { acceptances := rootExecutionRowLocalCcsAcceptance, acceptanceCount := 7, firstAcceptanceDigest := (some (bytes [14, 200, 121, 189, 75, 157, 136, 119, 205, 87, 3, 231, 10, 118, 76, 195, 57, 236, 10, 91, 48, 144, 161, 203, 179, 252, 167, 144, 6, 184, 181, 146])), lastAcceptanceDigest := (some (bytes [252, 91, 43, 197, 148, 77, 165, 50, 62, 160, 40, 250, 145, 42, 237, 174, 128, 135, 253, 75, 165, 218, 105, 253, 238, 115, 212, 48, 83, 222, 197, 119])), digest := (bytes [250, 181, 138, 132, 245, 6, 167, 216, 150, 247, 35, 255, 161, 201, 13, 122, 34, 59, 94, 184, 94, 217, 197, 37, 63, 134, 94, 159, 239, 121, 33, 164]) }
    , executionSemanticsRefinement := { refinements := rootExecutionExecutionSemanticsRefinement, refinementCount := 7, firstRefinementDigest := (some (bytes [11, 149, 11, 11, 42, 0, 193, 38, 196, 184, 99, 177, 104, 185, 73, 225, 39, 92, 189, 213, 79, 199, 144, 112, 170, 223, 42, 164, 28, 223, 145, 30])), lastRefinementDigest := (some (bytes [248, 134, 175, 128, 29, 200, 154, 41, 56, 85, 71, 238, 159, 132, 6, 80, 66, 83, 217, 45, 159, 5, 82, 220, 180, 229, 133, 11, 51, 61, 23, 172])), digest := (bytes [183, 81, 127, 172, 45, 161, 215, 51, 37, 170, 186, 216, 86, 44, 198, 51, 194, 179, 209, 226, 176, 205, 146, 75, 169, 70, 30, 224, 0, 231, 107, 85]) }
    , familyDigest := (bytes [153, 121, 216, 110, 240, 248, 146, 157, 20, 167, 12, 189, 154, 204, 132, 202, 108, 103, 204, 78, 60, 2, 173, 204, 105, 180, 243, 80, 48, 209, 32, 17])
    , digest := (bytes [60, 138, 203, 162, 196, 255, 60, 203, 168, 33, 185, 191, 89, 188, 173, 62, 212, 148, 214, 97, 211, 131, 194, 143, 242, 22, 230, 48, 54, 75, 163, 86])
  }

def kernelOpeningBundle : SimpleKernelOpeningBundleView :=
  {
    claim := { bindings := { stageClaimBundleDigest := (bytes [211, 218, 130, 85, 140, 178, 79, 223, 229, 73, 205, 154, 192, 235, 95, 53, 198, 31, 80, 1, 48, 200, 23, 174, 19, 158, 102, 63, 38, 135, 45, 203]), stagePackageBundleDigest := (bytes [56, 205, 185, 245, 186, 115, 174, 71, 15, 59, 195, 51, 241, 188, 144, 241, 203, 89, 63, 206, 200, 174, 240, 18, 251, 72, 1, 197, 179, 74, 220, 8]), stage1PackageDigest := (bytes [13, 241, 159, 115, 93, 17, 40, 130, 124, 132, 244, 152, 177, 67, 162, 99, 128, 52, 150, 89, 169, 233, 250, 14, 22, 230, 133, 180, 185, 38, 56, 139]), stage2PackageDigest := (bytes [246, 218, 202, 16, 58, 159, 92, 33, 123, 130, 195, 15, 240, 80, 153, 151, 222, 251, 84, 43, 232, 102, 242, 193, 55, 56, 127, 115, 173, 171, 65, 108]), stage3PackageDigest := (bytes [131, 117, 21, 163, 35, 215, 16, 73, 174, 212, 103, 77, 234, 136, 116, 201, 32, 240, 131, 33, 155, 237, 142, 245, 195, 121, 145, 70, 13, 44, 82, 196]), preparedStepBindingsDigest := (bytes [41, 195, 150, 239, 32, 214, 79, 228, 162, 51, 30, 99, 33, 223, 87, 214, 123, 56, 48, 217, 115, 190, 236, 88, 223, 249, 30, 188, 147, 226, 21, 152]), bindingCount := 7, stage1RowCount := 7, stage2RegisterReadCount := 9, stage2RegisterWriteCount := 6, stage2RamEventCount := 0, stage3ContinuityCount := 7, points := { firstBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [41, 195, 150, 239, 32, 214, 79, 228, 162, 51, 30, 99, 33, 223, 87, 214, 123, 56, 48, 217, 115, 190, 236, 88, 223, 249, 30, 188, 147, 226, 21, 152]), layoutVersion := 1, digest := (bytes [15, 46, 32, 75, 151, 198, 198, 103, 48, 84, 224, 173, 108, 117, 16, 194, 113, 129, 23, 76, 31, 1, 113, 116, 11, 158, 234, 215, 221, 39, 151, 104]) }, logicalIndex := 0, digest := (bytes [146, 157, 97, 249, 111, 98, 108, 37, 187, 156, 146, 48, 113, 192, 187, 102, 165, 95, 97, 29, 39, 38, 191, 229, 65, 238, 206, 114, 255, 245, 201, 13]) }, valueDigest := (bytes [140, 155, 55, 239, 188, 107, 251, 199, 224, 136, 155, 42, 81, 48, 2, 90, 162, 9, 55, 82, 91, 250, 154, 39, 70, 130, 60, 106, 99, 251, 179, 75]), digest := (bytes [135, 16, 16, 187, 195, 113, 178, 237, 119, 136, 255, 9, 204, 115, 158, 85, 205, 146, 166, 212, 67, 221, 194, 16, 11, 83, 248, 212, 182, 223, 187, 129]) }), lastBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [41, 195, 150, 239, 32, 214, 79, 228, 162, 51, 30, 99, 33, 223, 87, 214, 123, 56, 48, 217, 115, 190, 236, 88, 223, 249, 30, 188, 147, 226, 21, 152]), layoutVersion := 1, digest := (bytes [15, 46, 32, 75, 151, 198, 198, 103, 48, 84, 224, 173, 108, 117, 16, 194, 113, 129, 23, 76, 31, 1, 113, 116, 11, 158, 234, 215, 221, 39, 151, 104]) }, logicalIndex := 6, digest := (bytes [143, 246, 177, 3, 180, 250, 105, 244, 232, 38, 227, 154, 253, 54, 122, 71, 156, 102, 184, 36, 91, 163, 63, 242, 108, 70, 29, 178, 209, 244, 182, 193]) }, valueDigest := (bytes [146, 66, 139, 78, 136, 92, 49, 207, 5, 221, 238, 58, 188, 204, 86, 91, 8, 239, 113, 163, 31, 106, 255, 92, 187, 102, 111, 227, 95, 205, 42, 209]), digest := (bytes [132, 64, 140, 122, 233, 92, 175, 114, 228, 96, 63, 124, 235, 149, 185, 141, 117, 39, 22, 76, 106, 128, 144, 237, 71, 41, 176, 74, 75, 92, 167, 99]) }) }, digest := (bytes [215, 243, 83, 135, 39, 126, 219, 158, 90, 124, 41, 26, 224, 26, 21, 222, 165, 92, 138, 139, 148, 226, 108, 203, 114, 131, 154, 109, 224, 30, 9, 69]) }, preparedSteps := { executionDigest := (bytes [211, 235, 172, 239, 219, 81, 4, 198, 152, 115, 67, 102, 208, 155, 208, 227, 187, 253, 120, 104, 18, 87, 209, 247, 61, 70, 120, 76, 19, 152, 132, 231]), finalStateDigest := (bytes [1, 247, 115, 215, 23, 1, 108, 230, 175, 167, 73, 98, 183, 3, 79, 83, 190, 97, 204, 144, 79, 106, 207, 121, 17, 21, 75, 132, 7, 147, 140, 111]), transcriptFinalDigest := (bytes [246, 145, 4, 120, 181, 51, 64, 103, 101, 230, 199, 202, 205, 130, 54, 126, 6, 227, 62, 78, 176, 205, 145, 34, 137, 62, 7, 223, 122, 143, 103, 52]), preparedStepCount := 7, finalPc := 28, halted := true, points := { firstPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [170, 14, 29, 134, 225, 199, 103, 89, 7, 214, 134, 26, 126, 57, 75, 67, 52, 64, 39, 68, 204, 188, 74, 124, 197, 133, 40, 188, 47, 249, 206, 220]), layoutVersion := 3, digest := (bytes [71, 102, 67, 138, 160, 200, 44, 93, 228, 136, 209, 29, 173, 196, 235, 81, 140, 197, 109, 2, 166, 200, 61, 133, 227, 190, 109, 174, 114, 1, 8, 154]) }, logicalIndex := 0, digest := (bytes [169, 26, 255, 10, 135, 163, 112, 72, 70, 110, 179, 177, 254, 131, 186, 62, 64, 217, 149, 216, 203, 138, 234, 226, 187, 210, 38, 63, 102, 49, 27, 1]) }, valueDigest := (bytes [32, 25, 54, 149, 189, 186, 227, 219, 56, 115, 101, 166, 109, 248, 186, 201, 34, 174, 25, 48, 30, 45, 249, 8, 84, 206, 95, 5, 29, 90, 169, 83]), digest := (bytes [118, 90, 125, 244, 99, 23, 222, 38, 51, 105, 79, 48, 156, 255, 31, 21, 223, 129, 105, 179, 67, 134, 106, 93, 236, 182, 103, 252, 221, 72, 115, 28]) }), lastPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [170, 14, 29, 134, 225, 199, 103, 89, 7, 214, 134, 26, 126, 57, 75, 67, 52, 64, 39, 68, 204, 188, 74, 124, 197, 133, 40, 188, 47, 249, 206, 220]), layoutVersion := 3, digest := (bytes [71, 102, 67, 138, 160, 200, 44, 93, 228, 136, 209, 29, 173, 196, 235, 81, 140, 197, 109, 2, 166, 200, 61, 133, 227, 190, 109, 174, 114, 1, 8, 154]) }, logicalIndex := 6, digest := (bytes [180, 192, 230, 255, 80, 0, 32, 166, 6, 146, 202, 92, 101, 223, 121, 213, 14, 79, 174, 196, 222, 99, 131, 100, 106, 197, 26, 84, 109, 60, 245, 44]) }, valueDigest := (bytes [57, 167, 127, 66, 29, 28, 1, 62, 111, 174, 45, 82, 212, 157, 25, 154, 254, 72, 204, 85, 223, 7, 138, 44, 48, 11, 222, 83, 122, 239, 183, 120]), digest := (bytes [190, 190, 249, 7, 73, 29, 42, 8, 76, 100, 82, 228, 184, 222, 91, 178, 186, 139, 221, 6, 168, 159, 2, 155, 165, 36, 221, 26, 183, 176, 78, 100]) }) }, digest := (bytes [6, 56, 67, 122, 12, 214, 249, 127, 209, 121, 255, 232, 21, 15, 156, 175, 193, 225, 141, 226, 43, 233, 96, 239, 87, 120, 159, 99, 96, 63, 227, 36]) }, digest := (bytes [246, 99, 76, 235, 26, 219, 170, 85, 38, 195, 183, 234, 211, 113, 33, 28, 25, 119, 91, 182, 110, 175, 43, 49, 169, 81, 178, 220, 121, 29, 142, 86]) }
    , bindings := { claim := { stageClaimBundleDigest := (bytes [211, 218, 130, 85, 140, 178, 79, 223, 229, 73, 205, 154, 192, 235, 95, 53, 198, 31, 80, 1, 48, 200, 23, 174, 19, 158, 102, 63, 38, 135, 45, 203]), stagePackageBundleDigest := (bytes [56, 205, 185, 245, 186, 115, 174, 71, 15, 59, 195, 51, 241, 188, 144, 241, 203, 89, 63, 206, 200, 174, 240, 18, 251, 72, 1, 197, 179, 74, 220, 8]), stage1PackageDigest := (bytes [13, 241, 159, 115, 93, 17, 40, 130, 124, 132, 244, 152, 177, 67, 162, 99, 128, 52, 150, 89, 169, 233, 250, 14, 22, 230, 133, 180, 185, 38, 56, 139]), stage2PackageDigest := (bytes [246, 218, 202, 16, 58, 159, 92, 33, 123, 130, 195, 15, 240, 80, 153, 151, 222, 251, 84, 43, 232, 102, 242, 193, 55, 56, 127, 115, 173, 171, 65, 108]), stage3PackageDigest := (bytes [131, 117, 21, 163, 35, 215, 16, 73, 174, 212, 103, 77, 234, 136, 116, 201, 32, 240, 131, 33, 155, 237, 142, 245, 195, 121, 145, 70, 13, 44, 82, 196]), preparedStepBindingsDigest := (bytes [41, 195, 150, 239, 32, 214, 79, 228, 162, 51, 30, 99, 33, 223, 87, 214, 123, 56, 48, 217, 115, 190, 236, 88, 223, 249, 30, 188, 147, 226, 21, 152]), bindingCount := 7, stage1RowCount := 7, stage2RegisterReadCount := 9, stage2RegisterWriteCount := 6, stage2RamEventCount := 0, stage3ContinuityCount := 7, points := { firstBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [41, 195, 150, 239, 32, 214, 79, 228, 162, 51, 30, 99, 33, 223, 87, 214, 123, 56, 48, 217, 115, 190, 236, 88, 223, 249, 30, 188, 147, 226, 21, 152]), layoutVersion := 1, digest := (bytes [15, 46, 32, 75, 151, 198, 198, 103, 48, 84, 224, 173, 108, 117, 16, 194, 113, 129, 23, 76, 31, 1, 113, 116, 11, 158, 234, 215, 221, 39, 151, 104]) }, logicalIndex := 0, digest := (bytes [146, 157, 97, 249, 111, 98, 108, 37, 187, 156, 146, 48, 113, 192, 187, 102, 165, 95, 97, 29, 39, 38, 191, 229, 65, 238, 206, 114, 255, 245, 201, 13]) }, valueDigest := (bytes [140, 155, 55, 239, 188, 107, 251, 199, 224, 136, 155, 42, 81, 48, 2, 90, 162, 9, 55, 82, 91, 250, 154, 39, 70, 130, 60, 106, 99, 251, 179, 75]), digest := (bytes [135, 16, 16, 187, 195, 113, 178, 237, 119, 136, 255, 9, 204, 115, 158, 85, 205, 146, 166, 212, 67, 221, 194, 16, 11, 83, 248, 212, 182, 223, 187, 129]) }), lastBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [41, 195, 150, 239, 32, 214, 79, 228, 162, 51, 30, 99, 33, 223, 87, 214, 123, 56, 48, 217, 115, 190, 236, 88, 223, 249, 30, 188, 147, 226, 21, 152]), layoutVersion := 1, digest := (bytes [15, 46, 32, 75, 151, 198, 198, 103, 48, 84, 224, 173, 108, 117, 16, 194, 113, 129, 23, 76, 31, 1, 113, 116, 11, 158, 234, 215, 221, 39, 151, 104]) }, logicalIndex := 6, digest := (bytes [143, 246, 177, 3, 180, 250, 105, 244, 232, 38, 227, 154, 253, 54, 122, 71, 156, 102, 184, 36, 91, 163, 63, 242, 108, 70, 29, 178, 209, 244, 182, 193]) }, valueDigest := (bytes [146, 66, 139, 78, 136, 92, 49, 207, 5, 221, 238, 58, 188, 204, 86, 91, 8, 239, 113, 163, 31, 106, 255, 92, 187, 102, 111, 227, 95, 205, 42, 209]), digest := (bytes [132, 64, 140, 122, 233, 92, 175, 114, 228, 96, 63, 124, 235, 149, 185, 141, 117, 39, 22, 76, 106, 128, 144, 237, 71, 41, 176, 74, 75, 92, 167, 99]) }) }, digest := (bytes [215, 243, 83, 135, 39, 126, 219, 158, 90, 124, 41, 26, 224, 26, 21, 222, 165, 92, 138, 139, 148, 226, 108, 203, 114, 131, 154, 109, 224, 30, 9, 69]) }, packaged := { statementDigest := (bytes [12, 93, 95, 117, 178, 131, 232, 216, 36, 1, 33, 72, 41, 53, 202, 77, 56, 186, 151, 197, 210, 67, 75, 129, 241, 221, 40, 223, 202, 160, 155, 78]), proofDigest := (bytes [234, 69, 177, 202, 112, 131, 129, 104, 58, 255, 176, 127, 54, 93, 13, 49, 127, 63, 70, 68, 207, 65, 239, 143, 30, 157, 42, 116, 18, 242, 224, 17]) }, digest := (bytes [225, 190, 19, 232, 209, 46, 174, 190, 62, 103, 136, 32, 224, 152, 156, 36, 94, 32, 195, 58, 95, 178, 58, 243, 116, 73, 132, 97, 185, 227, 78, 206]) }
    , preparedSteps := { claim := { executionDigest := (bytes [211, 235, 172, 239, 219, 81, 4, 198, 152, 115, 67, 102, 208, 155, 208, 227, 187, 253, 120, 104, 18, 87, 209, 247, 61, 70, 120, 76, 19, 152, 132, 231]), finalStateDigest := (bytes [1, 247, 115, 215, 23, 1, 108, 230, 175, 167, 73, 98, 183, 3, 79, 83, 190, 97, 204, 144, 79, 106, 207, 121, 17, 21, 75, 132, 7, 147, 140, 111]), transcriptFinalDigest := (bytes [246, 145, 4, 120, 181, 51, 64, 103, 101, 230, 199, 202, 205, 130, 54, 126, 6, 227, 62, 78, 176, 205, 145, 34, 137, 62, 7, 223, 122, 143, 103, 52]), preparedStepCount := 7, finalPc := 28, halted := true, points := { firstPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [170, 14, 29, 134, 225, 199, 103, 89, 7, 214, 134, 26, 126, 57, 75, 67, 52, 64, 39, 68, 204, 188, 74, 124, 197, 133, 40, 188, 47, 249, 206, 220]), layoutVersion := 3, digest := (bytes [71, 102, 67, 138, 160, 200, 44, 93, 228, 136, 209, 29, 173, 196, 235, 81, 140, 197, 109, 2, 166, 200, 61, 133, 227, 190, 109, 174, 114, 1, 8, 154]) }, logicalIndex := 0, digest := (bytes [169, 26, 255, 10, 135, 163, 112, 72, 70, 110, 179, 177, 254, 131, 186, 62, 64, 217, 149, 216, 203, 138, 234, 226, 187, 210, 38, 63, 102, 49, 27, 1]) }, valueDigest := (bytes [32, 25, 54, 149, 189, 186, 227, 219, 56, 115, 101, 166, 109, 248, 186, 201, 34, 174, 25, 48, 30, 45, 249, 8, 84, 206, 95, 5, 29, 90, 169, 83]), digest := (bytes [118, 90, 125, 244, 99, 23, 222, 38, 51, 105, 79, 48, 156, 255, 31, 21, 223, 129, 105, 179, 67, 134, 106, 93, 236, 182, 103, 252, 221, 72, 115, 28]) }), lastPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [170, 14, 29, 134, 225, 199, 103, 89, 7, 214, 134, 26, 126, 57, 75, 67, 52, 64, 39, 68, 204, 188, 74, 124, 197, 133, 40, 188, 47, 249, 206, 220]), layoutVersion := 3, digest := (bytes [71, 102, 67, 138, 160, 200, 44, 93, 228, 136, 209, 29, 173, 196, 235, 81, 140, 197, 109, 2, 166, 200, 61, 133, 227, 190, 109, 174, 114, 1, 8, 154]) }, logicalIndex := 6, digest := (bytes [180, 192, 230, 255, 80, 0, 32, 166, 6, 146, 202, 92, 101, 223, 121, 213, 14, 79, 174, 196, 222, 99, 131, 100, 106, 197, 26, 84, 109, 60, 245, 44]) }, valueDigest := (bytes [57, 167, 127, 66, 29, 28, 1, 62, 111, 174, 45, 82, 212, 157, 25, 154, 254, 72, 204, 85, 223, 7, 138, 44, 48, 11, 222, 83, 122, 239, 183, 120]), digest := (bytes [190, 190, 249, 7, 73, 29, 42, 8, 76, 100, 82, 228, 184, 222, 91, 178, 186, 139, 221, 6, 168, 159, 2, 155, 165, 36, 221, 26, 183, 176, 78, 100]) }) }, digest := (bytes [6, 56, 67, 122, 12, 214, 249, 127, 209, 121, 255, 232, 21, 15, 156, 175, 193, 225, 141, 226, 43, 233, 96, 239, 87, 120, 159, 99, 96, 63, 227, 36]) }, packaged := { statementDigest := (bytes [229, 245, 10, 174, 64, 23, 84, 62, 239, 153, 160, 18, 149, 18, 227, 44, 150, 193, 66, 9, 100, 72, 134, 191, 118, 160, 185, 20, 4, 165, 11, 5]), proofDigest := (bytes [159, 69, 173, 2, 239, 23, 70, 149, 41, 0, 126, 199, 121, 3, 61, 233, 69, 247, 1, 33, 139, 143, 201, 196, 20, 2, 189, 40, 128, 182, 163, 170]) }, digest := (bytes [152, 225, 237, 136, 174, 192, 85, 236, 115, 165, 197, 14, 21, 149, 57, 110, 142, 178, 55, 248, 241, 180, 221, 217, 109, 175, 38, 55, 34, 201, 38, 242]) }
    , digest := (bytes [247, 248, 69, 129, 246, 168, 80, 136, 174, 36, 155, 64, 16, 252, 84, 51, 13, 7, 13, 202, 25, 59, 232, 114, 123, 216, 173, 165, 117, 7, 71, 89])
  }

def stepComposition : StepCompositionSurfaceView :=
  {
    stage1SemanticsDigest := (bytes [242, 252, 217, 79, 166, 127, 218, 134, 240, 55, 245, 110, 33, 119, 104, 154, 76, 56, 236, 126, 121, 15, 156, 185, 164, 46, 92, 226, 67, 33, 43, 109])
    , stage2SemanticsDigest := (bytes [208, 11, 85, 111, 230, 131, 170, 96, 181, 108, 145, 135, 130, 174, 99, 228, 188, 42, 189, 154, 65, 50, 100, 169, 0, 67, 14, 110, 32, 165, 225, 212])
    , stage2TemporalDigest := (bytes [250, 255, 100, 0, 6, 195, 177, 182, 93, 175, 162, 60, 23, 131, 124, 88, 110, 251, 98, 175, 153, 7, 141, 98, 58, 15, 172, 125, 57, 170, 151, 233])
    , stage3SemanticsDigest := (bytes [18, 255, 11, 199, 196, 111, 183, 239, 230, 40, 62, 78, 211, 64, 43, 238, 189, 59, 47, 144, 26, 40, 173, 84, 74, 94, 240, 221, 149, 198, 165, 197])
    , rootExecutionDigest := (bytes [60, 138, 203, 162, 196, 255, 60, 203, 168, 33, 185, 191, 89, 188, 173, 62, 212, 148, 214, 97, 211, 131, 194, 143, 242, 22, 230, 48, 54, 75, 163, 86])
    , preparedStepBindingsDigest := (bytes [41, 195, 150, 239, 32, 214, 79, 228, 162, 51, 30, 99, 33, 223, 87, 214, 123, 56, 48, 217, 115, 190, 236, 88, 223, 249, 30, 188, 147, 226, 21, 152])
    , rowChunkRoutesDigest := (bytes [210, 211, 133, 148, 162, 150, 85, 66, 2, 24, 230, 163, 67, 64, 160, 246, 143, 119, 48, 189, 194, 114, 28, 76, 211, 182, 93, 15, 73, 83, 209, 85])
    , realRowCount := 7
    , preparedStepCount := 7
    , firstRealStepIndex := 0
    , lastRealStepIndex := 6
    , initialPc := 0
    , finalPc := 28
    , halted := true
    , digest := (bytes [46, 243, 48, 160, 86, 182, 183, 206, 163, 167, 88, 201, 96, 158, 122, 61, 38, 232, 155, 223, 116, 101, 191, 9, 210, 219, 115, 159, 220, 235, 248, 142])
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
    name := "native_word_shift_chain_ecall"
    , source := {
  manifest := { name := "native_word_shift_chain_ecall", fixtureId := "native_word_shift_chain_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , startPc := 0
  , programWords := [32543131, 4280859, 1078022811, 6329275, 6378555, 1080120507, 115]
  , initialRegisters := [0, 1, 18446744071562067968, 0, 0, 0, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , initialMemory := []
  , transcriptSeed := (bytes [114, 118, 54, 52, 105, 109, 45, 110, 97, 116, 105, 118, 101, 45, 119, 111, 114, 100, 45, 115, 104, 105, 102, 116, 45, 118, 49])
}
    , derived := {
  manifest := { name := "native_word_shift_chain_ecall", fixtureId := "native_word_shift_chain_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , executionRows := [{
  traceIndex := 0
  , stepIndex := 0
  , sequenceIndex := 0
  , pc := 0
  , nextPc := 4
  , word := 32543131
  , opcode := .slliw
  , traceOpcode := (some .slliw)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 1
  , rs2 := 0
  , rs2Value := 0
  , rd := 3
  , rdBefore := 0
  , rdAfter := 18446744071562067968
  , imm := 31
  , aluResult := 18446744071562067968
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
  , word := 4280859
  , opcode := .srliw
  , traceOpcode := (some .srliw)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 2
  , rs1Value := 18446744071562067968
  , rs2 := 0
  , rs2Value := 0
  , rd := 4
  , rdBefore := 0
  , rdAfter := 134217728
  , imm := 4
  , aluResult := 134217728
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
  , word := 1078022811
  , opcode := .sraiw
  , traceOpcode := (some .sraiw)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 2
  , rs1Value := 18446744071562067968
  , rs2 := 0
  , rs2Value := 0
  , rd := 5
  , rdBefore := 0
  , rdAfter := 18446744073575333888
  , imm := 4
  , aluResult := 18446744073575333888
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
  , word := 6329275
  , opcode := .sllw
  , traceOpcode := (some .sllw)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 1
  , rs2 := 6
  , rs2Value := 40
  , rd := 7
  , rdBefore := 0
  , rdAfter := 256
  , imm := 0
  , aluResult := 256
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
  , word := 6378555
  , opcode := .srlw
  , traceOpcode := (some .srlw)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 2
  , rs1Value := 18446744071562067968
  , rs2 := 6
  , rs2Value := 40
  , rd := 8
  , rdBefore := 0
  , rdAfter := 8388608
  , imm := 0
  , aluResult := 8388608
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
  , word := 1080120507
  , opcode := .sraw
  , traceOpcode := (some .sraw)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 2
  , rs1Value := 18446744071562067968
  , rs2 := 6
  , rs2Value := 40
  , rd := 9
  , rdBefore := 0
  , rdAfter := 18446744073701163008
  , imm := 0
  , aluResult := 18446744073701163008
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
  , stage1 := { rows := [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 32543131, opcode := .slliw, traceOpcode := (some .slliw), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 4, aluResult := 18446744071562067968, effectiveAddr := none, writesRd := true, rd := 3, rdAfter := 18446744071562067968, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 4280859, opcode := .srliw, traceOpcode := (some .srliw), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 8, aluResult := 134217728, effectiveAddr := none, writesRd := true, rd := 4, rdAfter := 134217728, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 1078022811, opcode := .sraiw, traceOpcode := (some .sraiw), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 12, aluResult := 18446744073575333888, effectiveAddr := none, writesRd := true, rd := 5, rdAfter := 18446744073575333888, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 12, fetchedWord := 6329275, opcode := .sllw, traceOpcode := (some .sllw), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 16, aluResult := 256, effectiveAddr := none, writesRd := true, rd := 7, rdAfter := 256, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 4, stepIndex := 4, sequenceIndex := 0, fetchPc := 16, fetchedWord := 6378555, opcode := .srlw, traceOpcode := (some .srlw), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 20, aluResult := 8388608, effectiveAddr := none, writesRd := true, rd := 8, rdAfter := 8388608, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 5, stepIndex := 5, sequenceIndex := 0, fetchPc := 20, fetchedWord := 1080120507, opcode := .sraw, traceOpcode := (some .sraw), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 24, aluResult := 18446744073701163008, effectiveAddr := none, writesRd := true, rd := 9, rdAfter := 18446744073701163008, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 6, stepIndex := 6, sequenceIndex := 0, fetchPc := 24, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 28, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }] }
  , stage2 := {
  registerReads := [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 1, value := 1 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 2, value := 18446744071562067968 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 2, value := 18446744071562067968 }, { traceIndex := 3, stepIndex := 3, role := .rs1, reg := 1, value := 1 }, { traceIndex := 3, stepIndex := 3, role := .rs2, reg := 6, value := 40 }, { traceIndex := 4, stepIndex := 4, role := .rs1, reg := 2, value := 18446744071562067968 }, { traceIndex := 4, stepIndex := 4, role := .rs2, reg := 6, value := 40 }, { traceIndex := 5, stepIndex := 5, role := .rs1, reg := 2, value := 18446744071562067968 }, { traceIndex := 5, stepIndex := 5, role := .rs2, reg := 6, value := 40 }]
  , registerWrites := [{ traceIndex := 0, stepIndex := 0, reg := 3, previous := 0, next := 18446744071562067968 }, { traceIndex := 1, stepIndex := 1, reg := 4, previous := 0, next := 134217728 }, { traceIndex := 2, stepIndex := 2, reg := 5, previous := 0, next := 18446744073575333888 }, { traceIndex := 3, stepIndex := 3, reg := 7, previous := 0, next := 256 }, { traceIndex := 4, stepIndex := 4, reg := 8, previous := 0, next := 8388608 }, { traceIndex := 5, stepIndex := 5, reg := 9, previous := 0, next := 18446744073701163008 }]
  , ramEvents := []
  , twistLinks := [{ traceIndex := 0, stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 18446744071562067968), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 1, family := .nativeAlu, routedWriteValue := (some 134217728), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 2, family := .nativeAlu, routedWriteValue := (some 18446744073575333888), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 3, family := .nativeAlu, routedWriteValue := (some 256), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 4, stepIndex := 4, family := .nativeAlu, routedWriteValue := (some 8388608), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 5, stepIndex := 5, family := .nativeAlu, routedWriteValue := (some 18446744073701163008), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 6, stepIndex := 6, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]
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
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 110, 97, 116, 105, 118, 101, 45, 119, 111, 114, 100, 45, 115, 104, 105, 102, 116, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [29400036373852023, 54383638505065, 94828755958258816, 10905788041622594868, 8841251816071870994, 13391653407446453246, 17446101127387435910, 7137168547377178156], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [110, 97, 116, 105, 118, 101, 95, 119, 111, 114, 100, 95, 115, 104, 105, 102, 116, 95, 99, 104, 97, 105, 110, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [29400036373852023, 54383638505065, 94828755958258816, 10905788041622594868, 8841251816071870994, 13391653407446453246, 17446101127387435910, 7137168547377178156], absorbed := 2 }
  , cursorAfter := { stateWords := [108, 9521594137446015360, 2547443039661527262, 8672344190622444400, 8081909694194674092, 16881897145227272165, 8660841998244389168, 6317820854843455934], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [32543131, 4280859, 1078022811, 6329275, 6378555, 1080120507, 115]
  , cursorBefore := { stateWords := [108, 9521594137446015360, 2547443039661527262, 8672344190622444400, 8081909694194674092, 16881897145227272165, 8660841998244389168, 6317820854843455934], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 14817934692253552668, 5422135311370894167, 11520748702834940406, 11883633006059594575, 13899328913923243995, 3788765349771335243, 8170474725918284627], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 1, 18446744071562067968, 0, 0, 0, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [0, 14817934692253552668, 5422135311370894167, 11520748702834940406, 11883633006059594575, 13899328913923243995, 3788765349771335243, 8170474725918284627], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 0, 0, 5599915549487473793, 16406075848753953094, 4257212436415025084, 11701250843308806400, 7729765377244787962], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [0, 0, 0, 5599915549487473793, 16406075848753953094, 4257212436415025084, 11701250843308806400, 7729765377244787962], absorbed := 3 }
  , cursorAfter := { stateWords := [0, 14440487766866437759, 16158411280243843198, 11068495199233569458, 14924541703762306079, 8267198643178946222, 3573274338800551902, 11655965166207194028], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [228, 98, 148, 141, 173, 208, 81, 252, 147, 68, 207, 191, 208, 77, 9, 104, 120, 204, 161, 231, 192, 35, 84, 44, 52, 102, 68, 156, 128, 207, 202, 141])
  , u64s := []
  , cursorBefore := { stateWords := [0, 14440487766866437759, 16158411280243843198, 11068495199233569458, 14924541703762306079, 8267198643178946222, 3573274338800551902, 11655965166207194028], absorbed := 1 }
  , cursorAfter := { stateWords := [13311955648816485990, 16750417430444283956, 7685154747109710587, 6295989157772776084, 10092538584374784937, 8793270786648840439, 14540163602231133867, 16323917404508849710], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [13311955648816485990, 16750417430444283956, 7685154747109710587, 6295989157772776084, 10092538584374784937, 8793270786648840439, 14540163602231133867, 16323917404508849710], absorbed := 0 }
  , cursorAfter := { stateWords := [16632802919108710147, 13258520627264740138, 17110149117418189791, 6344445357732662908, 300123635686731147, 4690309516771459959, 1666160823646593165, 18427001648205017043], absorbed := 0 }
  , challengeOutput := (some 16632802919108710147)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [248, 83, 178, 47, 183, 64, 167, 213, 46, 91, 10, 99, 62, 110, 132, 116, 93, 93, 226, 16, 211, 156, 232, 54, 142, 211, 84, 128, 80, 117, 85, 150])
  , u64s := []
  , cursorBefore := { stateWords := [16632802919108710147, 13258520627264740138, 17110149117418189791, 6344445357732662908, 300123635686731147, 4690309516771459959, 1666160823646593165, 18427001648205017043], absorbed := 0 }
  , cursorAfter := { stateWords := [59409784501007492, 36122064619759772, 2522182992, 5559568679772866832, 16947521631507430986, 7097905515152098934, 9662790264370553859, 14387856573604793263], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [59409784501007492, 36122064619759772, 2522182992, 5559568679772866832, 16947521631507430986, 7097905515152098934, 9662790264370553859, 14387856573604793263], absorbed := 3 }
  , cursorAfter := { stateWords := [6139558469011796608, 4884362147061659144, 6321389962816677855, 8024296613977891277, 17489341190933289337, 16990790758108438777, 8165258603605472692, 2764174045714964182], absorbed := 0 }
  , challengeOutput := (some 6139558469011796608)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [6139558469011796608, 4884362147061659144, 6321389962816677855, 8024296613977891277, 17489341190933289337, 16990790758108438777, 8165258603605472692, 2764174045714964182], absorbed := 0 }
  , cursorAfter := { stateWords := [17659153299687098721, 17712354528554568885, 7814109569743718645, 7005650859248593987, 16662198303255909078, 12430977943436854309, 16377826725812306225, 12444259142770773964], absorbed := 0 }
  , challengeOutput := (some 17659153299687098721)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [196, 71, 198, 8, 146, 145, 167, 84, 220, 161, 107, 98, 85, 177, 210, 218, 174, 250, 41, 0, 144, 47, 208, 110, 33, 168, 235, 189, 138, 191, 255, 150])
  , u64s := []
  , cursorBefore := { stateWords := [17659153299687098721, 17712354528554568885, 7814109569743718645, 7005650859248593987, 16662198303255909078, 12430977943436854309, 16377826725812306225, 12444259142770773964], absorbed := 0 }
  , cursorAfter := { stateWords := [40532576945756882, 53457877946257455, 2533343114, 4389037520566929362, 905308323029389650, 6715865865346790960, 16344541882997798331, 15633995429416586303], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [40532576945756882, 53457877946257455, 2533343114, 4389037520566929362, 905308323029389650, 6715865865346790960, 16344541882997798331, 15633995429416586303], absorbed := 3 }
  , cursorAfter := { stateWords := [9836651665554253514, 1013454718206227654, 17847195175752135230, 7315708913189141393, 4158483092181717784, 15953468123669375930, 4646134940636474177, 3253426992010223375], absorbed := 0 }
  , challengeOutput := (some 9836651665554253514)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [13, 62, 18, 231, 159, 216, 74, 146, 123, 100, 48, 154, 55, 62, 243, 77, 247, 72, 183, 146, 55, 128, 226, 205, 79, 61, 249, 159, 174, 184, 114, 0])
  , u64s := []
  , cursorBefore := { stateWords := [9836651665554253514, 1013454718206227654, 17847195175752135230, 7315708913189141393, 4158483092181717784, 15953468123669375930, 4646134940636474177, 3253426992010223375], absorbed := 0 }
  , cursorAfter := { stateWords := [15642439619923443, 45028563024208512, 7518382, 8453740008147120415, 6979412999780891539, 577455515313918828, 16131038695622428852, 5173994843640728666], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [211, 235, 172, 239, 219, 81, 4, 198, 152, 115, 67, 102, 208, 155, 208, 227, 187, 253, 120, 104, 18, 87, 209, 247, 61, 70, 120, 76, 19, 152, 132, 231])
  , u64s := []
  , cursorBefore := { stateWords := [15642439619923443, 45028563024208512, 7518382, 8453740008147120415, 6979412999780891539, 577455515313918828, 16131038695622428852, 5173994843640728666], absorbed := 3 }
  , cursorAfter := { stateWords := [5181418443105232, 21524341312704855, 3884226579, 16025574383039273646, 13256995863280240603, 1918059058719304446, 6436782240809769697, 11503317375494532065], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [1, 247, 115, 215, 23, 1, 108, 230, 175, 167, 73, 98, 183, 3, 79, 83, 190, 97, 204, 144, 79, 106, 207, 121, 17, 21, 75, 132, 7, 147, 140, 111])
  , u64s := []
  , cursorBefore := { stateWords := [5181418443105232, 21524341312704855, 3884226579, 16025574383039273646, 13256995863280240603, 1918059058719304446, 6436782240809769697, 11503317375494532065], absorbed := 3 }
  , cursorAfter := { stateWords := [22395730647733071, 37237250785398634, 1871483655, 11729623726878119526, 18264761168511554550, 10337290128883049922, 1618482010682628583, 17010165591468757266], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [22395730647733071, 37237250785398634, 1871483655, 11729623726878119526, 18264761168511554550, 10337290128883049922, 1618482010682628583, 17010165591468757266], absorbed := 3 }
  , cursorAfter := { stateWords := [15711142033001630324, 4134151270888011781, 13431836156901815533, 16491183845168824840, 9933720971416121710, 1904543339923196549, 10946279722588893383, 5822108707308381839], absorbed := 0 }
  , challengeOutput := (some 15711142033001630324)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [15711142033001630324, 4134151270888011781, 13431836156901815533, 16491183845168824840, 9933720971416121710, 1904543339923196549, 10946279722588893383, 5822108707308381839], absorbed := 0 }
  , cursorAfter := { stateWords := [7440003438911721974, 9094600317903300197, 2490998226023277318, 3776144570464026249, 14964218005992433550, 10701830863539091962, 2846698840040576937, 17077938386530220705], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [246, 145, 4, 120, 181, 51, 64, 103, 101, 230, 199, 202, 205, 130, 54, 126, 6, 227, 62, 78, 176, 205, 145, 34, 137, 62, 7, 223, 122, 143, 103, 52]))
}]
}
  , kernel := {
  root0Digest := (bytes [228, 98, 148, 141, 173, 208, 81, 252, 147, 68, 207, 191, 208, 77, 9, 104, 120, 204, 161, 231, 192, 35, 84, 44, 52, 102, 68, 156, 128, 207, 202, 141])
  , stage1Digest := (bytes [248, 83, 178, 47, 183, 64, 167, 213, 46, 91, 10, 99, 62, 110, 132, 116, 93, 93, 226, 16, 211, 156, 232, 54, 142, 211, 84, 128, 80, 117, 85, 150])
  , stage2Digest := (bytes [196, 71, 198, 8, 146, 145, 167, 84, 220, 161, 107, 98, 85, 177, 210, 218, 174, 250, 41, 0, 144, 47, 208, 110, 33, 168, 235, 189, 138, 191, 255, 150])
  , stage3Digest := (bytes [13, 62, 18, 231, 159, 216, 74, 146, 123, 100, 48, 154, 55, 62, 243, 77, 247, 72, 183, 146, 55, 128, 226, 205, 79, 61, 249, 159, 174, 184, 114, 0])
  , executionDigest := (bytes [211, 235, 172, 239, 219, 81, 4, 198, 152, 115, 67, 102, 208, 155, 208, 227, 187, 253, 120, 104, 18, 87, 209, 247, 61, 70, 120, 76, 19, 152, 132, 231])
  , finalStateDigest := (bytes [1, 247, 115, 215, 23, 1, 108, 230, 175, 167, 73, 98, 183, 3, 79, 83, 190, 97, 204, 144, 79, 106, 207, 121, 17, 21, 75, 132, 7, 147, 140, 111])
  , stage1Mix := 16632802919108710147
  , stage2RegMix := 6139558469011796608
  , stage2RamMix := 17659153299687098721
  , stage3ContinuityMix := 9836651665554253514
  , kernelFinalMix := 15711142033001630324
  , transcriptFinalDigest := (bytes [246, 145, 4, 120, 181, 51, 64, 103, 101, 230, 199, 202, 205, 130, 54, 126, 6, 227, 62, 78, 176, 205, 145, 34, 137, 62, 7, 223, 122, 143, 103, 52])
  , finalPc := 28
  , finalRegisters := [0, 1, 18446744071562067968, 18446744071562067968, 134217728, 18446744073575333888, 40, 256, 8388608, 18446744073701163008, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , finalMemory := []
  , halted := true
}
}
    , kernelProof := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "native_word_shift_chain_ecall", fixtureId := "native_word_shift_chain_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , executionDigest := (bytes [211, 235, 172, 239, 219, 81, 4, 198, 152, 115, 67, 102, 208, 155, 208, 227, 187, 253, 120, 104, 18, 87, 209, 247, 61, 70, 120, 76, 19, 152, 132, 231])
  , shape := { executionRowCount := 7, realRowCount := 7, effectRowCount := 7, commitRowCount := 7, digest := (bytes [36, 118, 223, 124, 248, 115, 52, 199, 198, 250, 25, 33, 218, 131, 247, 174, 126, 69, 105, 226, 74, 199, 244, 245, 142, 55, 128, 143, 190, 129, 55, 117]) }
  , digest := (bytes [58, 234, 212, 76, 82, 208, 167, 67, 62, 218, 232, 108, 2, 116, 80, 108, 41, 29, 1, 9, 145, 63, 246, 202, 193, 119, 154, 36, 192, 116, 3, 202])
}
  , stages := { summary := { stage1RowCount := 7, stage2RegisterReadCount := 9, stage2RegisterWriteCount := 6, stage2RamEventCount := 0, stage2TwistLinkCount := 7, stage3ContinuityCount := 7, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [200, 186, 116, 165, 162, 250, 226, 207, 218, 18, 74, 163, 152, 182, 65, 254, 140, 33, 125, 158, 195, 66, 128, 215, 27, 7, 212, 125, 61, 107, 30, 150]) }, digest := (bytes [104, 218, 74, 24, 129, 84, 15, 61, 142, 147, 57, 159, 122, 144, 207, 242, 173, 67, 221, 223, 0, 18, 6, 30, 10, 124, 249, 68, 100, 237, 224, 46]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [211, 218, 130, 85, 140, 178, 79, 223, 229, 73, 205, 154, 192, 235, 95, 53, 198, 31, 80, 1, 48, 200, 23, 174, 19, 158, 102, 63, 38, 135, 45, 203]), stage1Digest := (bytes [134, 9, 7, 133, 202, 106, 171, 137, 185, 209, 142, 95, 153, 181, 175, 6, 249, 53, 4, 130, 158, 164, 176, 72, 207, 93, 252, 127, 230, 255, 21, 67]), stage2Digest := (bytes [153, 13, 167, 117, 179, 81, 0, 25, 21, 249, 210, 8, 212, 85, 205, 182, 125, 245, 145, 117, 100, 163, 97, 85, 120, 9, 43, 199, 193, 90, 138, 177]), stage3Digest := (bytes [191, 231, 148, 196, 231, 32, 230, 244, 246, 105, 83, 164, 118, 60, 102, 72, 67, 56, 200, 185, 75, 228, 213, 186, 94, 157, 206, 182, 221, 166, 14, 83]), transcriptDigest := (bytes [246, 145, 4, 120, 181, 51, 64, 103, 101, 230, 199, 202, 205, 130, 54, 126, 6, 227, 62, 78, 176, 205, 145, 34, 137, 62, 7, 223, 122, 143, 103, 52]), executionDigest := (bytes [211, 235, 172, 239, 219, 81, 4, 198, 152, 115, 67, 102, 208, 155, 208, 227, 187, 253, 120, 104, 18, 87, 209, 247, 61, 70, 120, 76, 19, 152, 132, 231]), digest := (bytes [72, 226, 204, 106, 209, 148, 118, 215, 123, 85, 189, 37, 156, 155, 32, 25, 48, 102, 113, 241, 19, 117, 230, 131, 246, 152, 238, 82, 128, 96, 147, 242]) }, statementDigest := (bytes [71, 26, 19, 31, 190, 78, 223, 71, 11, 88, 170, 244, 226, 113, 232, 4, 219, 164, 150, 35, 239, 193, 142, 10, 156, 16, 96, 157, 227, 55, 233, 197]), proofDigest := (bytes [178, 40, 63, 46, 243, 247, 184, 212, 174, 90, 172, 150, 59, 76, 23, 82, 120, 10, 157, 150, 75, 87, 1, 27, 209, 92, 17, 68, 101, 178, 178, 34]), digest := (bytes [154, 2, 231, 70, 20, 58, 230, 101, 52, 7, 50, 182, 243, 49, 248, 236, 233, 190, 102, 205, 57, 245, 80, 194, 229, 185, 53, 233, 44, 13, 104, 233]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [56, 205, 185, 245, 186, 115, 174, 71, 15, 59, 195, 51, 241, 188, 144, 241, 203, 89, 63, 206, 200, 174, 240, 18, 251, 72, 1, 197, 179, 74, 220, 8]), stage1Digest := (bytes [13, 241, 159, 115, 93, 17, 40, 130, 124, 132, 244, 152, 177, 67, 162, 99, 128, 52, 150, 89, 169, 233, 250, 14, 22, 230, 133, 180, 185, 38, 56, 139]), stage2Digest := (bytes [246, 218, 202, 16, 58, 159, 92, 33, 123, 130, 195, 15, 240, 80, 153, 151, 222, 251, 84, 43, 232, 102, 242, 193, 55, 56, 127, 115, 173, 171, 65, 108]), stage3Digest := (bytes [131, 117, 21, 163, 35, 215, 16, 73, 174, 212, 103, 77, 234, 136, 116, 201, 32, 240, 131, 33, 155, 237, 142, 245, 195, 121, 145, 70, 13, 44, 82, 196]), digest := (bytes [198, 178, 144, 188, 188, 58, 216, 96, 133, 234, 1, 177, 205, 3, 205, 80, 104, 170, 6, 19, 68, 155, 239, 122, 114, 72, 176, 157, 238, 224, 234, 195]) }, digest := (bytes [118, 50, 156, 47, 133, 6, 93, 207, 40, 242, 62, 194, 133, 244, 109, 164, 228, 251, 51, 247, 37, 21, 23, 139, 147, 121, 82, 178, 224, 249, 171, 114]) }
  , kernelOpening := { openingDigest := (bytes [247, 248, 69, 129, 246, 168, 80, 136, 174, 36, 155, 64, 16, 252, 84, 51, 13, 7, 13, 202, 25, 59, 232, 114, 123, 216, 173, 165, 117, 7, 71, 89]), bindings := { claimDigest := (bytes [246, 99, 76, 235, 26, 219, 170, 85, 38, 195, 183, 234, 211, 113, 33, 28, 25, 119, 91, 182, 110, 175, 43, 49, 169, 81, 178, 220, 121, 29, 142, 86]), bindingsDigest := (bytes [225, 190, 19, 232, 209, 46, 174, 190, 62, 103, 136, 32, 224, 152, 156, 36, 94, 32, 195, 58, 95, 178, 58, 243, 116, 73, 132, 97, 185, 227, 78, 206]), preparedStepsDigest := (bytes [152, 225, 237, 136, 174, 192, 85, 236, 115, 165, 197, 14, 21, 149, 57, 110, 142, 178, 55, 248, 241, 180, 221, 217, 109, 175, 38, 55, 34, 201, 38, 242]), digest := (bytes [60, 236, 104, 243, 51, 52, 123, 56, 27, 143, 137, 139, 30, 57, 39, 139, 99, 244, 241, 217, 225, 41, 25, 212, 123, 201, 227, 70, 212, 173, 254, 101]) }, digest := (bytes [181, 195, 83, 157, 191, 127, 29, 25, 230, 30, 150, 26, 72, 124, 26, 81, 13, 77, 132, 121, 178, 255, 88, 153, 159, 236, 68, 142, 229, 161, 239, 21]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [41, 195, 150, 239, 32, 214, 79, 228, 162, 51, 30, 99, 33, 223, 87, 214, 123, 56, 48, 217, 115, 190, 236, 88, 223, 249, 30, 188, 147, 226, 21, 152]), terminal := { root0Digest := (bytes [228, 98, 148, 141, 173, 208, 81, 252, 147, 68, 207, 191, 208, 77, 9, 104, 120, 204, 161, 231, 192, 35, 84, 44, 52, 102, 68, 156, 128, 207, 202, 141]), executionDigest := (bytes [211, 235, 172, 239, 219, 81, 4, 198, 152, 115, 67, 102, 208, 155, 208, 227, 187, 253, 120, 104, 18, 87, 209, 247, 61, 70, 120, 76, 19, 152, 132, 231]), finalStateDigest := (bytes [1, 247, 115, 215, 23, 1, 108, 230, 175, 167, 73, 98, 183, 3, 79, 83, 190, 97, 204, 144, 79, 106, 207, 121, 17, 21, 75, 132, 7, 147, 140, 111]), transcriptFinalDigest := (bytes [246, 145, 4, 120, 181, 51, 64, 103, 101, 230, 199, 202, 205, 130, 54, 126, 6, 227, 62, 78, 176, 205, 145, 34, 137, 62, 7, 223, 122, 143, 103, 52]), finalPc := 28, halted := true, digest := (bytes [96, 86, 243, 189, 152, 53, 19, 92, 125, 157, 112, 9, 11, 185, 179, 17, 32, 195, 53, 211, 210, 181, 233, 214, 123, 72, 189, 118, 143, 245, 189, 167]) }, digest := (bytes [7, 250, 249, 107, 159, 171, 46, 82, 105, 220, 85, 187, 161, 166, 34, 206, 6, 240, 187, 203, 152, 203, 31, 67, 23, 200, 73, 90, 99, 8, 87, 125]) }, statementDigest := (bytes [110, 47, 130, 218, 147, 20, 153, 51, 38, 142, 195, 49, 92, 172, 232, 189, 99, 199, 172, 138, 193, 8, 157, 130, 60, 174, 88, 115, 142, 243, 127, 54]), proofDigest := (bytes [250, 195, 242, 92, 188, 228, 8, 54, 122, 101, 207, 157, 128, 145, 171, 222, 59, 82, 220, 58, 149, 183, 48, 64, 84, 37, 32, 33, 92, 102, 204, 127]), digest := (bytes [119, 98, 233, 24, 215, 68, 61, 19, 147, 216, 204, 61, 157, 117, 112, 197, 76, 192, 171, 71, 230, 177, 12, 189, 74, 93, 189, 151, 52, 212, 208, 236]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [153, 121, 216, 110, 240, 248, 146, 157, 20, 167, 12, 189, 154, 204, 132, 202, 108, 103, 204, 78, 60, 2, 173, 204, 105, 180, 243, 80, 48, 209, 32, 17]), layoutVersion := 1, digest := (bytes [99, 142, 166, 59, 238, 59, 149, 214, 93, 217, 239, 31, 34, 87, 244, 70, 32, 9, 72, 139, 114, 157, 6, 31, 189, 0, 96, 226, 71, 34, 229, 95]) }, rowWidth := 38, timeLen := 7, columnDigests := [(bytes [40, 243, 169, 246, 170, 121, 143, 48, 132, 183, 68, 213, 151, 130, 14, 65, 20, 212, 138, 236, 77, 112, 226, 150, 158, 109, 142, 75, 172, 115, 156, 234]), (bytes [183, 255, 181, 34, 203, 1, 222, 219, 152, 86, 144, 13, 74, 163, 20, 134, 40, 184, 20, 201, 107, 98, 76, 0, 125, 194, 18, 176, 16, 226, 102, 175]), (bytes [153, 111, 70, 176, 156, 174, 226, 182, 197, 190, 144, 153, 100, 226, 206, 209, 132, 162, 24, 222, 166, 233, 132, 102, 120, 151, 149, 92, 177, 154, 105, 134]), (bytes [188, 23, 179, 202, 216, 119, 253, 192, 107, 56, 140, 18, 247, 51, 234, 39, 235, 216, 134, 241, 7, 60, 104, 146, 182, 166, 45, 236, 214, 213, 211, 83]), (bytes [78, 156, 218, 132, 187, 128, 28, 175, 180, 45, 97, 45, 52, 94, 142, 189, 238, 235, 64, 164, 28, 129, 72, 154, 162, 227, 67, 115, 203, 223, 178, 142]), (bytes [189, 155, 81, 251, 138, 136, 164, 240, 180, 224, 212, 246, 18, 174, 156, 132, 116, 45, 59, 219, 73, 254, 15, 113, 76, 59, 178, 6, 146, 205, 42, 115]), (bytes [168, 158, 183, 194, 59, 180, 51, 126, 250, 210, 142, 218, 119, 32, 165, 239, 245, 70, 212, 189, 195, 167, 153, 17, 153, 157, 56, 25, 27, 21, 189, 146]), (bytes [219, 173, 100, 223, 171, 1, 39, 17, 46, 51, 57, 219, 160, 183, 120, 245, 65, 217, 219, 14, 138, 72, 96, 115, 208, 0, 240, 36, 251, 136, 217, 106]), (bytes [179, 197, 166, 238, 247, 39, 161, 56, 86, 33, 181, 194, 233, 28, 80, 101, 156, 182, 133, 82, 176, 76, 183, 86, 85, 15, 113, 247, 11, 149, 206, 77]), (bytes [194, 169, 173, 29, 87, 213, 106, 41, 191, 121, 147, 102, 81, 113, 114, 66, 108, 114, 250, 131, 6, 253, 216, 198, 121, 242, 243, 205, 133, 213, 44, 69]), (bytes [34, 66, 101, 86, 144, 122, 14, 179, 45, 168, 117, 59, 211, 96, 252, 176, 204, 151, 121, 60, 105, 8, 12, 175, 172, 123, 38, 241, 39, 82, 180, 168]), (bytes [85, 129, 120, 17, 159, 15, 138, 237, 251, 198, 57, 163, 198, 187, 181, 57, 167, 74, 108, 55, 221, 93, 134, 114, 83, 91, 141, 93, 103, 221, 230, 253]), (bytes [18, 172, 128, 176, 253, 198, 4, 93, 34, 80, 94, 154, 166, 81, 235, 21, 208, 214, 240, 19, 132, 26, 227, 255, 47, 232, 138, 242, 49, 178, 152, 151]), (bytes [253, 211, 57, 186, 104, 56, 3, 26, 129, 185, 211, 251, 238, 155, 29, 124, 129, 209, 87, 124, 7, 144, 114, 245, 223, 214, 100, 145, 234, 90, 77, 153]), (bytes [242, 1, 63, 177, 206, 208, 100, 22, 231, 176, 240, 61, 227, 173, 73, 250, 20, 176, 119, 198, 90, 249, 204, 195, 8, 124, 11, 51, 17, 235, 161, 140]), (bytes [44, 32, 216, 93, 16, 146, 0, 130, 207, 204, 36, 141, 166, 246, 232, 20, 247, 247, 116, 89, 62, 217, 122, 245, 142, 15, 143, 44, 219, 131, 183, 12]), (bytes [63, 55, 148, 202, 193, 201, 88, 153, 244, 174, 145, 10, 157, 92, 137, 79, 24, 240, 86, 214, 120, 193, 105, 254, 83, 207, 7, 36, 175, 251, 198, 209]), (bytes [49, 184, 142, 166, 178, 93, 15, 133, 19, 3, 245, 149, 190, 250, 17, 77, 195, 143, 141, 153, 122, 25, 168, 96, 127, 182, 178, 210, 211, 3, 144, 60]), (bytes [86, 196, 110, 116, 66, 242, 23, 243, 102, 32, 103, 253, 30, 136, 67, 166, 214, 221, 241, 169, 190, 115, 51, 189, 2, 90, 50, 65, 2, 198, 240, 74]), (bytes [204, 170, 135, 24, 120, 2, 130, 166, 238, 140, 237, 167, 80, 81, 222, 98, 53, 76, 178, 231, 84, 4, 44, 222, 24, 14, 1, 161, 175, 62, 34, 83]), (bytes [254, 19, 232, 192, 11, 39, 102, 229, 212, 95, 179, 72, 76, 113, 31, 113, 119, 17, 192, 125, 69, 105, 89, 144, 235, 22, 196, 55, 37, 148, 98, 206]), (bytes [126, 178, 122, 220, 67, 252, 127, 71, 82, 225, 133, 219, 37, 32, 10, 78, 133, 40, 227, 107, 52, 114, 163, 131, 123, 127, 232, 227, 171, 62, 101, 156]), (bytes [150, 56, 15, 19, 5, 104, 56, 230, 209, 159, 201, 154, 59, 102, 109, 165, 137, 182, 61, 198, 151, 229, 213, 14, 110, 234, 163, 84, 29, 98, 8, 176]), (bytes [105, 118, 181, 152, 170, 170, 80, 36, 29, 249, 169, 142, 236, 59, 15, 11, 59, 205, 14, 114, 151, 114, 7, 73, 18, 196, 2, 193, 250, 170, 235, 120]), (bytes [87, 1, 92, 107, 112, 167, 64, 72, 4, 131, 203, 104, 88, 56, 9, 128, 223, 142, 99, 228, 224, 67, 80, 30, 120, 182, 57, 96, 168, 242, 217, 95]), (bytes [127, 173, 148, 81, 228, 129, 62, 46, 172, 74, 9, 108, 122, 134, 202, 226, 44, 207, 71, 119, 97, 112, 85, 223, 223, 71, 49, 13, 244, 157, 198, 116]), (bytes [121, 73, 251, 102, 179, 33, 89, 124, 134, 206, 98, 15, 47, 86, 71, 209, 119, 88, 17, 23, 79, 123, 152, 112, 138, 201, 7, 67, 225, 58, 179, 29]), (bytes [115, 221, 25, 201, 235, 175, 57, 9, 159, 237, 1, 99, 122, 176, 133, 105, 76, 191, 15, 198, 154, 87, 195, 119, 27, 252, 234, 251, 191, 97, 36, 22]), (bytes [150, 176, 216, 226, 239, 79, 218, 77, 47, 25, 98, 54, 47, 52, 197, 168, 30, 126, 93, 34, 149, 210, 8, 114, 248, 27, 12, 14, 147, 154, 204, 250]), (bytes [83, 251, 49, 48, 54, 174, 206, 33, 38, 55, 53, 86, 238, 134, 67, 140, 194, 44, 73, 155, 93, 189, 217, 191, 38, 87, 214, 184, 137, 68, 230, 167]), (bytes [240, 212, 182, 90, 28, 28, 194, 255, 94, 159, 35, 103, 91, 242, 214, 20, 102, 217, 67, 85, 43, 252, 11, 32, 160, 11, 241, 164, 190, 14, 75, 153]), (bytes [83, 203, 23, 43, 120, 2, 138, 179, 201, 101, 117, 199, 249, 119, 150, 189, 107, 206, 100, 240, 241, 191, 29, 12, 95, 189, 46, 162, 173, 67, 52, 64]), (bytes [243, 18, 112, 16, 115, 206, 161, 217, 70, 120, 53, 168, 21, 217, 125, 177, 15, 184, 39, 220, 129, 252, 253, 217, 143, 169, 231, 204, 197, 173, 74, 44]), (bytes [174, 205, 154, 64, 243, 198, 70, 67, 132, 170, 211, 195, 186, 11, 96, 55, 55, 6, 248, 130, 169, 186, 214, 86, 104, 198, 34, 111, 234, 42, 133, 117]), (bytes [181, 205, 4, 135, 126, 61, 165, 192, 182, 157, 219, 25, 61, 190, 241, 123, 199, 165, 114, 116, 128, 144, 237, 80, 99, 219, 70, 24, 44, 75, 141, 99]), (bytes [64, 184, 77, 60, 124, 164, 54, 93, 23, 121, 89, 235, 81, 60, 107, 51, 86, 73, 18, 40, 80, 16, 45, 151, 39, 61, 175, 64, 40, 48, 21, 239]), (bytes [10, 155, 182, 37, 26, 80, 79, 213, 200, 66, 53, 194, 225, 49, 41, 142, 45, 21, 123, 146, 196, 246, 52, 107, 151, 162, 236, 199, 129, 135, 242, 251]), (bytes [145, 99, 191, 35, 121, 90, 118, 57, 187, 82, 200, 99, 201, 117, 132, 16, 109, 95, 126, 62, 89, 129, 183, 210, 46, 8, 148, 208, 73, 204, 191, 238])], familyDigest := (bytes [153, 121, 216, 110, 240, 248, 146, 157, 20, 167, 12, 189, 154, 204, 132, 202, 108, 103, 204, 78, 60, 2, 173, 204, 105, 180, 243, 80, 48, 209, 32, 17]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [153, 121, 216, 110, 240, 248, 146, 157, 20, 167, 12, 189, 154, 204, 132, 202, 108, 103, 204, 78, 60, 2, 173, 204, 105, 180, 243, 80, 48, 209, 32, 17]), layoutVersion := 1, digest := (bytes [99, 142, 166, 59, 238, 59, 149, 214, 93, 217, 239, 31, 34, 87, 244, 70, 32, 9, 72, 139, 114, 157, 6, 31, 189, 0, 96, 226, 71, 34, 229, 95]) }, logicalIndex := 0, digest := (bytes [18, 51, 19, 39, 198, 104, 194, 81, 151, 63, 76, 177, 54, 35, 250, 176, 124, 88, 101, 157, 92, 13, 106, 3, 11, 85, 186, 117, 194, 10, 231, 245]) }, valueDigest := (bytes [32, 25, 54, 149, 189, 186, 227, 219, 56, 115, 101, 166, 109, 248, 186, 201, 34, 174, 25, 48, 30, 45, 249, 8, 84, 206, 95, 5, 29, 90, 169, 83]), digest := (bytes [208, 220, 60, 227, 9, 124, 49, 34, 147, 193, 229, 226, 222, 252, 98, 171, 161, 215, 104, 20, 175, 74, 64, 218, 155, 31, 93, 177, 68, 15, 57, 187]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [153, 121, 216, 110, 240, 248, 146, 157, 20, 167, 12, 189, 154, 204, 132, 202, 108, 103, 204, 78, 60, 2, 173, 204, 105, 180, 243, 80, 48, 209, 32, 17]), layoutVersion := 1, digest := (bytes [99, 142, 166, 59, 238, 59, 149, 214, 93, 217, 239, 31, 34, 87, 244, 70, 32, 9, 72, 139, 114, 157, 6, 31, 189, 0, 96, 226, 71, 34, 229, 95]) }, logicalIndex := 6, digest := (bytes [137, 178, 248, 108, 119, 225, 187, 34, 49, 110, 111, 188, 151, 93, 162, 150, 63, 252, 241, 220, 218, 34, 72, 6, 185, 255, 216, 220, 72, 152, 88, 42]) }, valueDigest := (bytes [57, 167, 127, 66, 29, 28, 1, 62, 111, 174, 45, 82, 212, 157, 25, 154, 254, 72, 204, 85, 223, 7, 138, 44, 48, 11, 222, 83, 122, 239, 183, 120]), digest := (bytes [188, 60, 90, 111, 119, 197, 231, 126, 36, 27, 172, 206, 148, 232, 22, 65, 235, 167, 200, 142, 198, 179, 168, 235, 107, 21, 96, 205, 87, 181, 185, 239]) }), digest := (bytes [202, 175, 54, 249, 31, 220, 29, 162, 134, 134, 205, 12, 19, 192, 31, 178, 42, 110, 193, 192, 243, 152, 215, 42, 74, 237, 141, 161, 169, 103, 105, 237]) }
  , rootLaneCommitment := { timeLen := 7, commitments := { commitmentCount := 38, digest := (bytes [170, 14, 29, 134, 225, 199, 103, 89, 7, 214, 134, 26, 126, 57, 75, 67, 52, 64, 39, 68, 204, 188, 74, 124, 197, 133, 40, 188, 47, 249, 206, 220]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [170, 14, 29, 134, 225, 199, 103, 89, 7, 214, 134, 26, 126, 57, 75, 67, 52, 64, 39, 68, 204, 188, 74, 124, 197, 133, 40, 188, 47, 249, 206, 220]), layoutVersion := 3, digest := (bytes [71, 102, 67, 138, 160, 200, 44, 93, 228, 136, 209, 29, 173, 196, 235, 81, 140, 197, 109, 2, 166, 200, 61, 133, 227, 190, 109, 174, 114, 1, 8, 154]) }, logicalIndex := 0, digest := (bytes [169, 26, 255, 10, 135, 163, 112, 72, 70, 110, 179, 177, 254, 131, 186, 62, 64, 217, 149, 216, 203, 138, 234, 226, 187, 210, 38, 63, 102, 49, 27, 1]) }, valueDigest := (bytes [32, 25, 54, 149, 189, 186, 227, 219, 56, 115, 101, 166, 109, 248, 186, 201, 34, 174, 25, 48, 30, 45, 249, 8, 84, 206, 95, 5, 29, 90, 169, 83]), digest := (bytes [118, 90, 125, 244, 99, 23, 222, 38, 51, 105, 79, 48, 156, 255, 31, 21, 223, 129, 105, 179, 67, 134, 106, 93, 236, 182, 103, 252, 221, 72, 115, 28]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [170, 14, 29, 134, 225, 199, 103, 89, 7, 214, 134, 26, 126, 57, 75, 67, 52, 64, 39, 68, 204, 188, 74, 124, 197, 133, 40, 188, 47, 249, 206, 220]), layoutVersion := 3, digest := (bytes [71, 102, 67, 138, 160, 200, 44, 93, 228, 136, 209, 29, 173, 196, 235, 81, 140, 197, 109, 2, 166, 200, 61, 133, 227, 190, 109, 174, 114, 1, 8, 154]) }, logicalIndex := 6, digest := (bytes [180, 192, 230, 255, 80, 0, 32, 166, 6, 146, 202, 92, 101, 223, 121, 213, 14, 79, 174, 196, 222, 99, 131, 100, 106, 197, 26, 84, 109, 60, 245, 44]) }, valueDigest := (bytes [57, 167, 127, 66, 29, 28, 1, 62, 111, 174, 45, 82, 212, 157, 25, 154, 254, 72, 204, 85, 223, 7, 138, 44, 48, 11, 222, 83, 122, 239, 183, 120]), digest := (bytes [190, 190, 249, 7, 73, 29, 42, 8, 76, 100, 82, 228, 184, 222, 91, 178, 186, 139, 221, 6, 168, 159, 2, 155, 165, 36, 221, 26, 183, 176, 78, 100]) }), digest := (bytes [19, 66, 14, 108, 184, 243, 218, 181, 55, 225, 166, 228, 205, 83, 99, 109, 255, 56, 70, 59, 157, 187, 21, 165, 253, 51, 112, 94, 92, 162, 254, 233]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [202, 175, 54, 249, 31, 220, 29, 162, 134, 134, 205, 12, 19, 192, 31, 178, 42, 110, 193, 192, 243, 152, 215, 42, 74, 237, 141, 161, 169, 103, 105, 237]), rootLaneCommitmentDigest := (bytes [19, 66, 14, 108, 184, 243, 218, 181, 55, 225, 166, 228, 205, 83, 99, 109, 255, 56, 70, 59, 157, 187, 21, 165, 253, 51, 112, 94, 92, 162, 254, 233]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 7, digest := (bytes [205, 50, 135, 117, 150, 42, 203, 16, 236, 253, 110, 121, 48, 68, 115, 251, 11, 157, 41, 163, 56, 154, 12, 74, 203, 247, 246, 101, 23, 130, 3, 100]) }, statementDigest := (bytes [7, 109, 15, 141, 11, 23, 102, 193, 30, 187, 15, 18, 199, 247, 3, 194, 72, 103, 113, 60, 174, 114, 72, 186, 21, 236, 118, 168, 171, 51, 224, 94]), proofDigest := (bytes [45, 30, 35, 153, 35, 207, 194, 222, 206, 45, 186, 45, 112, 192, 119, 217, 203, 235, 46, 72, 166, 141, 4, 13, 199, 56, 249, 187, 121, 49, 91, 229]), digest := (bytes [157, 184, 53, 28, 82, 148, 211, 217, 78, 64, 250, 39, 152, 131, 110, 124, 149, 58, 20, 110, 12, 214, 121, 115, 70, 89, 66, 100, 176, 101, 195, 101]) }
  , digest := (bytes [32, 98, 5, 28, 247, 19, 23, 230, 12, 30, 137, 32, 79, 181, 252, 211, 32, 107, 117, 205, 248, 228, 1, 104, 36, 229, 151, 228, 219, 128, 47, 125])
}
    , exportedProof := {
  claim := {
  accepted := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , statement := { proofStatementDigest := (bytes [144, 56, 113, 223, 195, 161, 9, 142, 114, 212, 230, 208, 183, 2, 175, 185, 110, 240, 1, 208, 34, 177, 245, 246, 90, 199, 103, 254, 191, 176, 169, 22]), kernelOpeningDigest := (bytes [181, 195, 83, 157, 191, 127, 29, 25, 230, 30, 150, 26, 72, 124, 26, 81, 13, 77, 132, 121, 178, 255, 88, 153, 159, 236, 68, 142, 229, 161, 239, 21]), digest := (bytes [31, 163, 57, 123, 240, 124, 175, 65, 112, 40, 86, 238, 208, 146, 16, 224, 88, 216, 96, 10, 55, 17, 98, 181, 65, 22, 102, 193, 178, 165, 87, 105]) }
  , mainLane := { mainLaneBundleDigest := (bytes [157, 184, 53, 28, 82, 148, 211, 217, 78, 64, 250, 39, 152, 131, 110, 124, 149, 58, 20, 110, 12, 214, 121, 115, 70, 89, 66, 100, 176, 101, 195, 101]), digest := (bytes [29, 253, 228, 93, 217, 211, 201, 202, 225, 199, 77, 129, 187, 52, 156, 188, 139, 140, 58, 248, 23, 253, 60, 227, 17, 54, 145, 69, 221, 139, 210, 27]) }
  , terminal := { finalStateDigest := (bytes [1, 247, 115, 215, 23, 1, 108, 230, 175, 167, 73, 98, 183, 3, 79, 83, 190, 97, 204, 144, 79, 106, 207, 121, 17, 21, 75, 132, 7, 147, 140, 111]), finalPc := 28, halted := true, digest := (bytes [56, 62, 217, 134, 162, 83, 165, 115, 243, 174, 108, 151, 212, 222, 171, 197, 37, 187, 66, 123, 44, 24, 161, 243, 187, 73, 104, 128, 224, 88, 85, 134]) }
  , digest := (bytes [137, 94, 128, 232, 240, 157, 105, 30, 184, 8, 26, 200, 116, 108, 110, 169, 100, 55, 231, 64, 207, 173, 68, 33, 118, 57, 236, 222, 83, 87, 205, 68])
}
  , mainLane := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { mainLaneBundleDigest := (bytes [157, 184, 53, 28, 82, 148, 211, 217, 78, 64, 250, 39, 152, 131, 110, 124, 149, 58, 20, 110, 12, 214, 121, 115, 70, 89, 66, 100, 176, 101, 195, 101]), digest := (bytes [37, 145, 6, 6, 219, 113, 203, 104, 136, 168, 137, 143, 163, 39, 111, 78, 188, 137, 253, 9, 19, 30, 161, 7, 242, 30, 120, 32, 219, 176, 58, 215]) }, digest := (bytes [119, 125, 191, 252, 202, 131, 60, 60, 207, 153, 107, 241, 202, 18, 6, 155, 30, 124, 10, 64, 85, 52, 69, 53, 152, 241, 201, 45, 91, 20, 201, 83]) }
  , opening := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , stages := { stageClaimsDigest := (bytes [154, 2, 231, 70, 20, 58, 230, 101, 52, 7, 50, 182, 243, 49, 248, 236, 233, 190, 102, 205, 57, 245, 80, 194, 229, 185, 53, 233, 44, 13, 104, 233]), stagePackagesDigest := (bytes [118, 50, 156, 47, 133, 6, 93, 207, 40, 242, 62, 194, 133, 244, 109, 164, 228, 251, 51, 247, 37, 21, 23, 139, 147, 121, 82, 178, 224, 249, 171, 114]), kernelOpeningDigest := (bytes [181, 195, 83, 157, 191, 127, 29, 25, 230, 30, 150, 26, 72, 124, 26, 81, 13, 77, 132, 121, 178, 255, 88, 153, 159, 236, 68, 142, 229, 161, 239, 21]), digest := (bytes [27, 61, 62, 59, 132, 25, 87, 179, 104, 207, 1, 54, 255, 149, 165, 215, 66, 186, 7, 204, 96, 117, 203, 45, 223, 55, 211, 247, 153, 38, 137, 21]) }
  , terminal := { preparedStepBindingsDigest := (bytes [41, 195, 150, 239, 32, 214, 79, 228, 162, 51, 30, 99, 33, 223, 87, 214, 123, 56, 48, 217, 115, 190, 236, 88, 223, 249, 30, 188, 147, 226, 21, 152]), executionDigest := (bytes [211, 235, 172, 239, 219, 81, 4, 198, 152, 115, 67, 102, 208, 155, 208, 227, 187, 253, 120, 104, 18, 87, 209, 247, 61, 70, 120, 76, 19, 152, 132, 231]), transcriptFinalDigest := (bytes [246, 145, 4, 120, 181, 51, 64, 103, 101, 230, 199, 202, 205, 130, 54, 126, 6, 227, 62, 78, 176, 205, 145, 34, 137, 62, 7, 223, 122, 143, 103, 52]), digest := (bytes [90, 57, 102, 215, 182, 48, 205, 189, 24, 186, 28, 86, 30, 126, 79, 149, 139, 36, 37, 254, 30, 152, 117, 44, 167, 46, 200, 140, 181, 13, 65, 39]) }
  , digest := (bytes [248, 132, 146, 18, 65, 140, 163, 77, 170, 87, 133, 201, 87, 157, 201, 231, 184, 88, 128, 112, 97, 122, 104, 31, 246, 21, 43, 150, 189, 84, 168, 53])
}
  , jointOpening := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { proofStatementDigest := (bytes [144, 56, 113, 223, 195, 161, 9, 142, 114, 212, 230, 208, 183, 2, 175, 185, 110, 240, 1, 208, 34, 177, 245, 246, 90, 199, 103, 254, 191, 176, 169, 22]), mainLaneClaimDigest := (bytes [119, 125, 191, 252, 202, 131, 60, 60, 207, 153, 107, 241, 202, 18, 6, 155, 30, 124, 10, 64, 85, 52, 69, 53, 152, 241, 201, 45, 91, 20, 201, 83]), kernelOpeningClaimDigest := (bytes [248, 132, 146, 18, 65, 140, 163, 77, 170, 87, 133, 201, 87, 157, 201, 231, 184, 88, 128, 112, 97, 122, 104, 31, 246, 21, 43, 150, 189, 84, 168, 53]), digest := (bytes [17, 102, 85, 103, 169, 138, 49, 238, 214, 104, 11, 189, 124, 46, 196, 54, 198, 137, 9, 33, 59, 74, 102, 196, 203, 183, 75, 226, 120, 86, 78, 11]) }, digest := (bytes [23, 241, 200, 51, 195, 18, 201, 232, 28, 77, 30, 189, 211, 120, 133, 203, 190, 196, 222, 150, 59, 60, 114, 172, 34, 244, 49, 223, 198, 62, 136, 134]) }
  , root0 := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), stages := { stage1Digest := (bytes [248, 83, 178, 47, 183, 64, 167, 213, 46, 91, 10, 99, 62, 110, 132, 116, 93, 93, 226, 16, 211, 156, 232, 54, 142, 211, 84, 128, 80, 117, 85, 150]), stage2Digest := (bytes [196, 71, 198, 8, 146, 145, 167, 84, 220, 161, 107, 98, 85, 177, 210, 218, 174, 250, 41, 0, 144, 47, 208, 110, 33, 168, 235, 189, 138, 191, 255, 150]), stage3Digest := (bytes [13, 62, 18, 231, 159, 216, 74, 146, 123, 100, 48, 154, 55, 62, 243, 77, 247, 72, 183, 146, 55, 128, 226, 205, 79, 61, 249, 159, 174, 184, 114, 0]), digest := (bytes [232, 33, 34, 12, 67, 20, 2, 37, 178, 96, 130, 219, 71, 138, 147, 112, 168, 87, 31, 41, 70, 230, 100, 30, 39, 251, 189, 197, 79, 137, 77, 45]) }, terminal := { root0Digest := (bytes [228, 98, 148, 141, 173, 208, 81, 252, 147, 68, 207, 191, 208, 77, 9, 104, 120, 204, 161, 231, 192, 35, 84, 44, 52, 102, 68, 156, 128, 207, 202, 141]), executionDigest := (bytes [211, 235, 172, 239, 219, 81, 4, 198, 152, 115, 67, 102, 208, 155, 208, 227, 187, 253, 120, 104, 18, 87, 209, 247, 61, 70, 120, 76, 19, 152, 132, 231]), finalStateDigest := (bytes [1, 247, 115, 215, 23, 1, 108, 230, 175, 167, 73, 98, 183, 3, 79, 83, 190, 97, 204, 144, 79, 106, 207, 121, 17, 21, 75, 132, 7, 147, 140, 111]), transcriptFinalDigest := (bytes [246, 145, 4, 120, 181, 51, 64, 103, 101, 230, 199, 202, 205, 130, 54, 126, 6, 227, 62, 78, 176, 205, 145, 34, 137, 62, 7, 223, 122, 143, 103, 52]), digest := (bytes [241, 143, 53, 1, 21, 113, 20, 56, 91, 53, 37, 48, 168, 27, 40, 86, 208, 59, 100, 194, 255, 2, 41, 174, 176, 239, 42, 236, 80, 141, 73, 47]) }, digest := (bytes [180, 89, 83, 48, 45, 254, 243, 70, 139, 178, 231, 50, 175, 131, 125, 233, 189, 236, 186, 130, 249, 252, 114, 251, 144, 8, 108, 25, 116, 233, 79, 45]) }
  , digest := (bytes [23, 195, 8, 36, 203, 148, 127, 171, 87, 152, 245, 234, 186, 35, 33, 125, 47, 226, 237, 217, 2, 95, 160, 68, 145, 211, 155, 34, 229, 197, 255, 146])
}
  , statement := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , foldSchedule := Nightstream.FoldSchedule.wholeTrace
  , chunkCount := 1
  , stageClaimsDigest := (bytes [154, 2, 231, 70, 20, 58, 230, 101, 52, 7, 50, 182, 243, 49, 248, 236, 233, 190, 102, 205, 57, 245, 80, 194, 229, 185, 53, 233, 44, 13, 104, 233])
  , stagePackagesDigest := (bytes [118, 50, 156, 47, 133, 6, 93, 207, 40, 242, 62, 194, 133, 244, 109, 164, 228, 251, 51, 247, 37, 21, 23, 139, 147, 121, 82, 178, 224, 249, 171, 114])
  , kernelOpeningDigest := (bytes [181, 195, 83, 157, 191, 127, 29, 25, 230, 30, 150, 26, 72, 124, 26, 81, 13, 77, 132, 121, 178, 255, 88, 153, 159, 236, 68, 142, 229, 161, 239, 21])
  , preparedStepBindingsDigest := (bytes [41, 195, 150, 239, 32, 214, 79, 228, 162, 51, 30, 99, 33, 223, 87, 214, 123, 56, 48, 217, 115, 190, 236, 88, 223, 249, 30, 188, 147, 226, 21, 152])
  , executionDigest := (bytes [211, 235, 172, 239, 219, 81, 4, 198, 152, 115, 67, 102, 208, 155, 208, 227, 187, 253, 120, 104, 18, 87, 209, 247, 61, 70, 120, 76, 19, 152, 132, 231])
  , finalStateDigest := (bytes [1, 247, 115, 215, 23, 1, 108, 230, 175, 167, 73, 98, 183, 3, 79, 83, 190, 97, 204, 144, 79, 106, 207, 121, 17, 21, 75, 132, 7, 147, 140, 111])
  , transcriptFinalDigest := (bytes [246, 145, 4, 120, 181, 51, 64, 103, 101, 230, 199, 202, 205, 130, 54, 126, 6, 227, 62, 78, 176, 205, 145, 34, 137, 62, 7, 223, 122, 143, 103, 52])
  , mainLaneSurfaceDigest := (bytes [175, 242, 229, 61, 160, 59, 88, 170, 206, 47, 53, 48, 153, 104, 212, 38, 51, 37, 74, 184, 154, 107, 18, 99, 195, 98, 110, 61, 141, 64, 173, 114])
  , rootLaneColumnsDigest := (bytes [202, 175, 54, 249, 31, 220, 29, 162, 134, 134, 205, 12, 19, 192, 31, 178, 42, 110, 193, 192, 243, 152, 215, 42, 74, 237, 141, 161, 169, 103, 105, 237])
  , publicStepCount := 7
  , initialPc := 0
  , finalPc := 28
  , halted := true
  , digest := (bytes [144, 56, 113, 223, 195, 161, 9, 142, 114, 212, 230, 208, 183, 2, 175, 185, 110, 240, 1, 208, 34, 177, 245, 246, 90, 199, 103, 254, 191, 176, 169, 22])
}
  , kernel := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "native_word_shift_chain_ecall", fixtureId := "native_word_shift_chain_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , executionDigest := (bytes [211, 235, 172, 239, 219, 81, 4, 198, 152, 115, 67, 102, 208, 155, 208, 227, 187, 253, 120, 104, 18, 87, 209, 247, 61, 70, 120, 76, 19, 152, 132, 231])
  , shape := { executionRowCount := 7, realRowCount := 7, effectRowCount := 7, commitRowCount := 7, digest := (bytes [36, 118, 223, 124, 248, 115, 52, 199, 198, 250, 25, 33, 218, 131, 247, 174, 126, 69, 105, 226, 74, 199, 244, 245, 142, 55, 128, 143, 190, 129, 55, 117]) }
  , digest := (bytes [58, 234, 212, 76, 82, 208, 167, 67, 62, 218, 232, 108, 2, 116, 80, 108, 41, 29, 1, 9, 145, 63, 246, 202, 193, 119, 154, 36, 192, 116, 3, 202])
}
  , stages := { summary := { stage1RowCount := 7, stage2RegisterReadCount := 9, stage2RegisterWriteCount := 6, stage2RamEventCount := 0, stage2TwistLinkCount := 7, stage3ContinuityCount := 7, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [200, 186, 116, 165, 162, 250, 226, 207, 218, 18, 74, 163, 152, 182, 65, 254, 140, 33, 125, 158, 195, 66, 128, 215, 27, 7, 212, 125, 61, 107, 30, 150]) }, digest := (bytes [104, 218, 74, 24, 129, 84, 15, 61, 142, 147, 57, 159, 122, 144, 207, 242, 173, 67, 221, 223, 0, 18, 6, 30, 10, 124, 249, 68, 100, 237, 224, 46]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [211, 218, 130, 85, 140, 178, 79, 223, 229, 73, 205, 154, 192, 235, 95, 53, 198, 31, 80, 1, 48, 200, 23, 174, 19, 158, 102, 63, 38, 135, 45, 203]), stage1Digest := (bytes [134, 9, 7, 133, 202, 106, 171, 137, 185, 209, 142, 95, 153, 181, 175, 6, 249, 53, 4, 130, 158, 164, 176, 72, 207, 93, 252, 127, 230, 255, 21, 67]), stage2Digest := (bytes [153, 13, 167, 117, 179, 81, 0, 25, 21, 249, 210, 8, 212, 85, 205, 182, 125, 245, 145, 117, 100, 163, 97, 85, 120, 9, 43, 199, 193, 90, 138, 177]), stage3Digest := (bytes [191, 231, 148, 196, 231, 32, 230, 244, 246, 105, 83, 164, 118, 60, 102, 72, 67, 56, 200, 185, 75, 228, 213, 186, 94, 157, 206, 182, 221, 166, 14, 83]), transcriptDigest := (bytes [246, 145, 4, 120, 181, 51, 64, 103, 101, 230, 199, 202, 205, 130, 54, 126, 6, 227, 62, 78, 176, 205, 145, 34, 137, 62, 7, 223, 122, 143, 103, 52]), executionDigest := (bytes [211, 235, 172, 239, 219, 81, 4, 198, 152, 115, 67, 102, 208, 155, 208, 227, 187, 253, 120, 104, 18, 87, 209, 247, 61, 70, 120, 76, 19, 152, 132, 231]), digest := (bytes [72, 226, 204, 106, 209, 148, 118, 215, 123, 85, 189, 37, 156, 155, 32, 25, 48, 102, 113, 241, 19, 117, 230, 131, 246, 152, 238, 82, 128, 96, 147, 242]) }, statementDigest := (bytes [71, 26, 19, 31, 190, 78, 223, 71, 11, 88, 170, 244, 226, 113, 232, 4, 219, 164, 150, 35, 239, 193, 142, 10, 156, 16, 96, 157, 227, 55, 233, 197]), proofDigest := (bytes [178, 40, 63, 46, 243, 247, 184, 212, 174, 90, 172, 150, 59, 76, 23, 82, 120, 10, 157, 150, 75, 87, 1, 27, 209, 92, 17, 68, 101, 178, 178, 34]), digest := (bytes [154, 2, 231, 70, 20, 58, 230, 101, 52, 7, 50, 182, 243, 49, 248, 236, 233, 190, 102, 205, 57, 245, 80, 194, 229, 185, 53, 233, 44, 13, 104, 233]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [56, 205, 185, 245, 186, 115, 174, 71, 15, 59, 195, 51, 241, 188, 144, 241, 203, 89, 63, 206, 200, 174, 240, 18, 251, 72, 1, 197, 179, 74, 220, 8]), stage1Digest := (bytes [13, 241, 159, 115, 93, 17, 40, 130, 124, 132, 244, 152, 177, 67, 162, 99, 128, 52, 150, 89, 169, 233, 250, 14, 22, 230, 133, 180, 185, 38, 56, 139]), stage2Digest := (bytes [246, 218, 202, 16, 58, 159, 92, 33, 123, 130, 195, 15, 240, 80, 153, 151, 222, 251, 84, 43, 232, 102, 242, 193, 55, 56, 127, 115, 173, 171, 65, 108]), stage3Digest := (bytes [131, 117, 21, 163, 35, 215, 16, 73, 174, 212, 103, 77, 234, 136, 116, 201, 32, 240, 131, 33, 155, 237, 142, 245, 195, 121, 145, 70, 13, 44, 82, 196]), digest := (bytes [198, 178, 144, 188, 188, 58, 216, 96, 133, 234, 1, 177, 205, 3, 205, 80, 104, 170, 6, 19, 68, 155, 239, 122, 114, 72, 176, 157, 238, 224, 234, 195]) }, digest := (bytes [118, 50, 156, 47, 133, 6, 93, 207, 40, 242, 62, 194, 133, 244, 109, 164, 228, 251, 51, 247, 37, 21, 23, 139, 147, 121, 82, 178, 224, 249, 171, 114]) }
  , kernelOpening := { openingDigest := (bytes [247, 248, 69, 129, 246, 168, 80, 136, 174, 36, 155, 64, 16, 252, 84, 51, 13, 7, 13, 202, 25, 59, 232, 114, 123, 216, 173, 165, 117, 7, 71, 89]), bindings := { claimDigest := (bytes [246, 99, 76, 235, 26, 219, 170, 85, 38, 195, 183, 234, 211, 113, 33, 28, 25, 119, 91, 182, 110, 175, 43, 49, 169, 81, 178, 220, 121, 29, 142, 86]), bindingsDigest := (bytes [225, 190, 19, 232, 209, 46, 174, 190, 62, 103, 136, 32, 224, 152, 156, 36, 94, 32, 195, 58, 95, 178, 58, 243, 116, 73, 132, 97, 185, 227, 78, 206]), preparedStepsDigest := (bytes [152, 225, 237, 136, 174, 192, 85, 236, 115, 165, 197, 14, 21, 149, 57, 110, 142, 178, 55, 248, 241, 180, 221, 217, 109, 175, 38, 55, 34, 201, 38, 242]), digest := (bytes [60, 236, 104, 243, 51, 52, 123, 56, 27, 143, 137, 139, 30, 57, 39, 139, 99, 244, 241, 217, 225, 41, 25, 212, 123, 201, 227, 70, 212, 173, 254, 101]) }, digest := (bytes [181, 195, 83, 157, 191, 127, 29, 25, 230, 30, 150, 26, 72, 124, 26, 81, 13, 77, 132, 121, 178, 255, 88, 153, 159, 236, 68, 142, 229, 161, 239, 21]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [41, 195, 150, 239, 32, 214, 79, 228, 162, 51, 30, 99, 33, 223, 87, 214, 123, 56, 48, 217, 115, 190, 236, 88, 223, 249, 30, 188, 147, 226, 21, 152]), terminal := { root0Digest := (bytes [228, 98, 148, 141, 173, 208, 81, 252, 147, 68, 207, 191, 208, 77, 9, 104, 120, 204, 161, 231, 192, 35, 84, 44, 52, 102, 68, 156, 128, 207, 202, 141]), executionDigest := (bytes [211, 235, 172, 239, 219, 81, 4, 198, 152, 115, 67, 102, 208, 155, 208, 227, 187, 253, 120, 104, 18, 87, 209, 247, 61, 70, 120, 76, 19, 152, 132, 231]), finalStateDigest := (bytes [1, 247, 115, 215, 23, 1, 108, 230, 175, 167, 73, 98, 183, 3, 79, 83, 190, 97, 204, 144, 79, 106, 207, 121, 17, 21, 75, 132, 7, 147, 140, 111]), transcriptFinalDigest := (bytes [246, 145, 4, 120, 181, 51, 64, 103, 101, 230, 199, 202, 205, 130, 54, 126, 6, 227, 62, 78, 176, 205, 145, 34, 137, 62, 7, 223, 122, 143, 103, 52]), finalPc := 28, halted := true, digest := (bytes [96, 86, 243, 189, 152, 53, 19, 92, 125, 157, 112, 9, 11, 185, 179, 17, 32, 195, 53, 211, 210, 181, 233, 214, 123, 72, 189, 118, 143, 245, 189, 167]) }, digest := (bytes [7, 250, 249, 107, 159, 171, 46, 82, 105, 220, 85, 187, 161, 166, 34, 206, 6, 240, 187, 203, 152, 203, 31, 67, 23, 200, 73, 90, 99, 8, 87, 125]) }, statementDigest := (bytes [110, 47, 130, 218, 147, 20, 153, 51, 38, 142, 195, 49, 92, 172, 232, 189, 99, 199, 172, 138, 193, 8, 157, 130, 60, 174, 88, 115, 142, 243, 127, 54]), proofDigest := (bytes [250, 195, 242, 92, 188, 228, 8, 54, 122, 101, 207, 157, 128, 145, 171, 222, 59, 82, 220, 58, 149, 183, 48, 64, 84, 37, 32, 33, 92, 102, 204, 127]), digest := (bytes [119, 98, 233, 24, 215, 68, 61, 19, 147, 216, 204, 61, 157, 117, 112, 197, 76, 192, 171, 71, 230, 177, 12, 189, 74, 93, 189, 151, 52, 212, 208, 236]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [153, 121, 216, 110, 240, 248, 146, 157, 20, 167, 12, 189, 154, 204, 132, 202, 108, 103, 204, 78, 60, 2, 173, 204, 105, 180, 243, 80, 48, 209, 32, 17]), layoutVersion := 1, digest := (bytes [99, 142, 166, 59, 238, 59, 149, 214, 93, 217, 239, 31, 34, 87, 244, 70, 32, 9, 72, 139, 114, 157, 6, 31, 189, 0, 96, 226, 71, 34, 229, 95]) }, rowWidth := 38, timeLen := 7, columnDigests := [(bytes [40, 243, 169, 246, 170, 121, 143, 48, 132, 183, 68, 213, 151, 130, 14, 65, 20, 212, 138, 236, 77, 112, 226, 150, 158, 109, 142, 75, 172, 115, 156, 234]), (bytes [183, 255, 181, 34, 203, 1, 222, 219, 152, 86, 144, 13, 74, 163, 20, 134, 40, 184, 20, 201, 107, 98, 76, 0, 125, 194, 18, 176, 16, 226, 102, 175]), (bytes [153, 111, 70, 176, 156, 174, 226, 182, 197, 190, 144, 153, 100, 226, 206, 209, 132, 162, 24, 222, 166, 233, 132, 102, 120, 151, 149, 92, 177, 154, 105, 134]), (bytes [188, 23, 179, 202, 216, 119, 253, 192, 107, 56, 140, 18, 247, 51, 234, 39, 235, 216, 134, 241, 7, 60, 104, 146, 182, 166, 45, 236, 214, 213, 211, 83]), (bytes [78, 156, 218, 132, 187, 128, 28, 175, 180, 45, 97, 45, 52, 94, 142, 189, 238, 235, 64, 164, 28, 129, 72, 154, 162, 227, 67, 115, 203, 223, 178, 142]), (bytes [189, 155, 81, 251, 138, 136, 164, 240, 180, 224, 212, 246, 18, 174, 156, 132, 116, 45, 59, 219, 73, 254, 15, 113, 76, 59, 178, 6, 146, 205, 42, 115]), (bytes [168, 158, 183, 194, 59, 180, 51, 126, 250, 210, 142, 218, 119, 32, 165, 239, 245, 70, 212, 189, 195, 167, 153, 17, 153, 157, 56, 25, 27, 21, 189, 146]), (bytes [219, 173, 100, 223, 171, 1, 39, 17, 46, 51, 57, 219, 160, 183, 120, 245, 65, 217, 219, 14, 138, 72, 96, 115, 208, 0, 240, 36, 251, 136, 217, 106]), (bytes [179, 197, 166, 238, 247, 39, 161, 56, 86, 33, 181, 194, 233, 28, 80, 101, 156, 182, 133, 82, 176, 76, 183, 86, 85, 15, 113, 247, 11, 149, 206, 77]), (bytes [194, 169, 173, 29, 87, 213, 106, 41, 191, 121, 147, 102, 81, 113, 114, 66, 108, 114, 250, 131, 6, 253, 216, 198, 121, 242, 243, 205, 133, 213, 44, 69]), (bytes [34, 66, 101, 86, 144, 122, 14, 179, 45, 168, 117, 59, 211, 96, 252, 176, 204, 151, 121, 60, 105, 8, 12, 175, 172, 123, 38, 241, 39, 82, 180, 168]), (bytes [85, 129, 120, 17, 159, 15, 138, 237, 251, 198, 57, 163, 198, 187, 181, 57, 167, 74, 108, 55, 221, 93, 134, 114, 83, 91, 141, 93, 103, 221, 230, 253]), (bytes [18, 172, 128, 176, 253, 198, 4, 93, 34, 80, 94, 154, 166, 81, 235, 21, 208, 214, 240, 19, 132, 26, 227, 255, 47, 232, 138, 242, 49, 178, 152, 151]), (bytes [253, 211, 57, 186, 104, 56, 3, 26, 129, 185, 211, 251, 238, 155, 29, 124, 129, 209, 87, 124, 7, 144, 114, 245, 223, 214, 100, 145, 234, 90, 77, 153]), (bytes [242, 1, 63, 177, 206, 208, 100, 22, 231, 176, 240, 61, 227, 173, 73, 250, 20, 176, 119, 198, 90, 249, 204, 195, 8, 124, 11, 51, 17, 235, 161, 140]), (bytes [44, 32, 216, 93, 16, 146, 0, 130, 207, 204, 36, 141, 166, 246, 232, 20, 247, 247, 116, 89, 62, 217, 122, 245, 142, 15, 143, 44, 219, 131, 183, 12]), (bytes [63, 55, 148, 202, 193, 201, 88, 153, 244, 174, 145, 10, 157, 92, 137, 79, 24, 240, 86, 214, 120, 193, 105, 254, 83, 207, 7, 36, 175, 251, 198, 209]), (bytes [49, 184, 142, 166, 178, 93, 15, 133, 19, 3, 245, 149, 190, 250, 17, 77, 195, 143, 141, 153, 122, 25, 168, 96, 127, 182, 178, 210, 211, 3, 144, 60]), (bytes [86, 196, 110, 116, 66, 242, 23, 243, 102, 32, 103, 253, 30, 136, 67, 166, 214, 221, 241, 169, 190, 115, 51, 189, 2, 90, 50, 65, 2, 198, 240, 74]), (bytes [204, 170, 135, 24, 120, 2, 130, 166, 238, 140, 237, 167, 80, 81, 222, 98, 53, 76, 178, 231, 84, 4, 44, 222, 24, 14, 1, 161, 175, 62, 34, 83]), (bytes [254, 19, 232, 192, 11, 39, 102, 229, 212, 95, 179, 72, 76, 113, 31, 113, 119, 17, 192, 125, 69, 105, 89, 144, 235, 22, 196, 55, 37, 148, 98, 206]), (bytes [126, 178, 122, 220, 67, 252, 127, 71, 82, 225, 133, 219, 37, 32, 10, 78, 133, 40, 227, 107, 52, 114, 163, 131, 123, 127, 232, 227, 171, 62, 101, 156]), (bytes [150, 56, 15, 19, 5, 104, 56, 230, 209, 159, 201, 154, 59, 102, 109, 165, 137, 182, 61, 198, 151, 229, 213, 14, 110, 234, 163, 84, 29, 98, 8, 176]), (bytes [105, 118, 181, 152, 170, 170, 80, 36, 29, 249, 169, 142, 236, 59, 15, 11, 59, 205, 14, 114, 151, 114, 7, 73, 18, 196, 2, 193, 250, 170, 235, 120]), (bytes [87, 1, 92, 107, 112, 167, 64, 72, 4, 131, 203, 104, 88, 56, 9, 128, 223, 142, 99, 228, 224, 67, 80, 30, 120, 182, 57, 96, 168, 242, 217, 95]), (bytes [127, 173, 148, 81, 228, 129, 62, 46, 172, 74, 9, 108, 122, 134, 202, 226, 44, 207, 71, 119, 97, 112, 85, 223, 223, 71, 49, 13, 244, 157, 198, 116]), (bytes [121, 73, 251, 102, 179, 33, 89, 124, 134, 206, 98, 15, 47, 86, 71, 209, 119, 88, 17, 23, 79, 123, 152, 112, 138, 201, 7, 67, 225, 58, 179, 29]), (bytes [115, 221, 25, 201, 235, 175, 57, 9, 159, 237, 1, 99, 122, 176, 133, 105, 76, 191, 15, 198, 154, 87, 195, 119, 27, 252, 234, 251, 191, 97, 36, 22]), (bytes [150, 176, 216, 226, 239, 79, 218, 77, 47, 25, 98, 54, 47, 52, 197, 168, 30, 126, 93, 34, 149, 210, 8, 114, 248, 27, 12, 14, 147, 154, 204, 250]), (bytes [83, 251, 49, 48, 54, 174, 206, 33, 38, 55, 53, 86, 238, 134, 67, 140, 194, 44, 73, 155, 93, 189, 217, 191, 38, 87, 214, 184, 137, 68, 230, 167]), (bytes [240, 212, 182, 90, 28, 28, 194, 255, 94, 159, 35, 103, 91, 242, 214, 20, 102, 217, 67, 85, 43, 252, 11, 32, 160, 11, 241, 164, 190, 14, 75, 153]), (bytes [83, 203, 23, 43, 120, 2, 138, 179, 201, 101, 117, 199, 249, 119, 150, 189, 107, 206, 100, 240, 241, 191, 29, 12, 95, 189, 46, 162, 173, 67, 52, 64]), (bytes [243, 18, 112, 16, 115, 206, 161, 217, 70, 120, 53, 168, 21, 217, 125, 177, 15, 184, 39, 220, 129, 252, 253, 217, 143, 169, 231, 204, 197, 173, 74, 44]), (bytes [174, 205, 154, 64, 243, 198, 70, 67, 132, 170, 211, 195, 186, 11, 96, 55, 55, 6, 248, 130, 169, 186, 214, 86, 104, 198, 34, 111, 234, 42, 133, 117]), (bytes [181, 205, 4, 135, 126, 61, 165, 192, 182, 157, 219, 25, 61, 190, 241, 123, 199, 165, 114, 116, 128, 144, 237, 80, 99, 219, 70, 24, 44, 75, 141, 99]), (bytes [64, 184, 77, 60, 124, 164, 54, 93, 23, 121, 89, 235, 81, 60, 107, 51, 86, 73, 18, 40, 80, 16, 45, 151, 39, 61, 175, 64, 40, 48, 21, 239]), (bytes [10, 155, 182, 37, 26, 80, 79, 213, 200, 66, 53, 194, 225, 49, 41, 142, 45, 21, 123, 146, 196, 246, 52, 107, 151, 162, 236, 199, 129, 135, 242, 251]), (bytes [145, 99, 191, 35, 121, 90, 118, 57, 187, 82, 200, 99, 201, 117, 132, 16, 109, 95, 126, 62, 89, 129, 183, 210, 46, 8, 148, 208, 73, 204, 191, 238])], familyDigest := (bytes [153, 121, 216, 110, 240, 248, 146, 157, 20, 167, 12, 189, 154, 204, 132, 202, 108, 103, 204, 78, 60, 2, 173, 204, 105, 180, 243, 80, 48, 209, 32, 17]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [153, 121, 216, 110, 240, 248, 146, 157, 20, 167, 12, 189, 154, 204, 132, 202, 108, 103, 204, 78, 60, 2, 173, 204, 105, 180, 243, 80, 48, 209, 32, 17]), layoutVersion := 1, digest := (bytes [99, 142, 166, 59, 238, 59, 149, 214, 93, 217, 239, 31, 34, 87, 244, 70, 32, 9, 72, 139, 114, 157, 6, 31, 189, 0, 96, 226, 71, 34, 229, 95]) }, logicalIndex := 0, digest := (bytes [18, 51, 19, 39, 198, 104, 194, 81, 151, 63, 76, 177, 54, 35, 250, 176, 124, 88, 101, 157, 92, 13, 106, 3, 11, 85, 186, 117, 194, 10, 231, 245]) }, valueDigest := (bytes [32, 25, 54, 149, 189, 186, 227, 219, 56, 115, 101, 166, 109, 248, 186, 201, 34, 174, 25, 48, 30, 45, 249, 8, 84, 206, 95, 5, 29, 90, 169, 83]), digest := (bytes [208, 220, 60, 227, 9, 124, 49, 34, 147, 193, 229, 226, 222, 252, 98, 171, 161, 215, 104, 20, 175, 74, 64, 218, 155, 31, 93, 177, 68, 15, 57, 187]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [153, 121, 216, 110, 240, 248, 146, 157, 20, 167, 12, 189, 154, 204, 132, 202, 108, 103, 204, 78, 60, 2, 173, 204, 105, 180, 243, 80, 48, 209, 32, 17]), layoutVersion := 1, digest := (bytes [99, 142, 166, 59, 238, 59, 149, 214, 93, 217, 239, 31, 34, 87, 244, 70, 32, 9, 72, 139, 114, 157, 6, 31, 189, 0, 96, 226, 71, 34, 229, 95]) }, logicalIndex := 6, digest := (bytes [137, 178, 248, 108, 119, 225, 187, 34, 49, 110, 111, 188, 151, 93, 162, 150, 63, 252, 241, 220, 218, 34, 72, 6, 185, 255, 216, 220, 72, 152, 88, 42]) }, valueDigest := (bytes [57, 167, 127, 66, 29, 28, 1, 62, 111, 174, 45, 82, 212, 157, 25, 154, 254, 72, 204, 85, 223, 7, 138, 44, 48, 11, 222, 83, 122, 239, 183, 120]), digest := (bytes [188, 60, 90, 111, 119, 197, 231, 126, 36, 27, 172, 206, 148, 232, 22, 65, 235, 167, 200, 142, 198, 179, 168, 235, 107, 21, 96, 205, 87, 181, 185, 239]) }), digest := (bytes [202, 175, 54, 249, 31, 220, 29, 162, 134, 134, 205, 12, 19, 192, 31, 178, 42, 110, 193, 192, 243, 152, 215, 42, 74, 237, 141, 161, 169, 103, 105, 237]) }
  , rootLaneCommitment := { timeLen := 7, commitments := { commitmentCount := 38, digest := (bytes [170, 14, 29, 134, 225, 199, 103, 89, 7, 214, 134, 26, 126, 57, 75, 67, 52, 64, 39, 68, 204, 188, 74, 124, 197, 133, 40, 188, 47, 249, 206, 220]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [170, 14, 29, 134, 225, 199, 103, 89, 7, 214, 134, 26, 126, 57, 75, 67, 52, 64, 39, 68, 204, 188, 74, 124, 197, 133, 40, 188, 47, 249, 206, 220]), layoutVersion := 3, digest := (bytes [71, 102, 67, 138, 160, 200, 44, 93, 228, 136, 209, 29, 173, 196, 235, 81, 140, 197, 109, 2, 166, 200, 61, 133, 227, 190, 109, 174, 114, 1, 8, 154]) }, logicalIndex := 0, digest := (bytes [169, 26, 255, 10, 135, 163, 112, 72, 70, 110, 179, 177, 254, 131, 186, 62, 64, 217, 149, 216, 203, 138, 234, 226, 187, 210, 38, 63, 102, 49, 27, 1]) }, valueDigest := (bytes [32, 25, 54, 149, 189, 186, 227, 219, 56, 115, 101, 166, 109, 248, 186, 201, 34, 174, 25, 48, 30, 45, 249, 8, 84, 206, 95, 5, 29, 90, 169, 83]), digest := (bytes [118, 90, 125, 244, 99, 23, 222, 38, 51, 105, 79, 48, 156, 255, 31, 21, 223, 129, 105, 179, 67, 134, 106, 93, 236, 182, 103, 252, 221, 72, 115, 28]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [170, 14, 29, 134, 225, 199, 103, 89, 7, 214, 134, 26, 126, 57, 75, 67, 52, 64, 39, 68, 204, 188, 74, 124, 197, 133, 40, 188, 47, 249, 206, 220]), layoutVersion := 3, digest := (bytes [71, 102, 67, 138, 160, 200, 44, 93, 228, 136, 209, 29, 173, 196, 235, 81, 140, 197, 109, 2, 166, 200, 61, 133, 227, 190, 109, 174, 114, 1, 8, 154]) }, logicalIndex := 6, digest := (bytes [180, 192, 230, 255, 80, 0, 32, 166, 6, 146, 202, 92, 101, 223, 121, 213, 14, 79, 174, 196, 222, 99, 131, 100, 106, 197, 26, 84, 109, 60, 245, 44]) }, valueDigest := (bytes [57, 167, 127, 66, 29, 28, 1, 62, 111, 174, 45, 82, 212, 157, 25, 154, 254, 72, 204, 85, 223, 7, 138, 44, 48, 11, 222, 83, 122, 239, 183, 120]), digest := (bytes [190, 190, 249, 7, 73, 29, 42, 8, 76, 100, 82, 228, 184, 222, 91, 178, 186, 139, 221, 6, 168, 159, 2, 155, 165, 36, 221, 26, 183, 176, 78, 100]) }), digest := (bytes [19, 66, 14, 108, 184, 243, 218, 181, 55, 225, 166, 228, 205, 83, 99, 109, 255, 56, 70, 59, 157, 187, 21, 165, 253, 51, 112, 94, 92, 162, 254, 233]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [202, 175, 54, 249, 31, 220, 29, 162, 134, 134, 205, 12, 19, 192, 31, 178, 42, 110, 193, 192, 243, 152, 215, 42, 74, 237, 141, 161, 169, 103, 105, 237]), rootLaneCommitmentDigest := (bytes [19, 66, 14, 108, 184, 243, 218, 181, 55, 225, 166, 228, 205, 83, 99, 109, 255, 56, 70, 59, 157, 187, 21, 165, 253, 51, 112, 94, 92, 162, 254, 233]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 7, digest := (bytes [205, 50, 135, 117, 150, 42, 203, 16, 236, 253, 110, 121, 48, 68, 115, 251, 11, 157, 41, 163, 56, 154, 12, 74, 203, 247, 246, 101, 23, 130, 3, 100]) }, statementDigest := (bytes [7, 109, 15, 141, 11, 23, 102, 193, 30, 187, 15, 18, 199, 247, 3, 194, 72, 103, 113, 60, 174, 114, 72, 186, 21, 236, 118, 168, 171, 51, 224, 94]), proofDigest := (bytes [45, 30, 35, 153, 35, 207, 194, 222, 206, 45, 186, 45, 112, 192, 119, 217, 203, 235, 46, 72, 166, 141, 4, 13, 199, 56, 249, 187, 121, 49, 91, 229]), digest := (bytes [157, 184, 53, 28, 82, 148, 211, 217, 78, 64, 250, 39, 152, 131, 110, 124, 149, 58, 20, 110, 12, 214, 121, 115, 70, 89, 66, 100, 176, 101, 195, 101]) }
  , digest := (bytes [32, 98, 5, 28, 247, 19, 23, 230, 12, 30, 137, 32, 79, 181, 252, 211, 32, 107, 117, 205, 248, 228, 1, 104, 36, 229, 151, 228, 219, 128, 47, 125])
}
}
    , exportedStatement := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , foldSchedule := Nightstream.FoldSchedule.wholeTrace
  , chunkCount := 1
  , stageClaimsDigest := (bytes [154, 2, 231, 70, 20, 58, 230, 101, 52, 7, 50, 182, 243, 49, 248, 236, 233, 190, 102, 205, 57, 245, 80, 194, 229, 185, 53, 233, 44, 13, 104, 233])
  , stagePackagesDigest := (bytes [118, 50, 156, 47, 133, 6, 93, 207, 40, 242, 62, 194, 133, 244, 109, 164, 228, 251, 51, 247, 37, 21, 23, 139, 147, 121, 82, 178, 224, 249, 171, 114])
  , kernelOpeningDigest := (bytes [181, 195, 83, 157, 191, 127, 29, 25, 230, 30, 150, 26, 72, 124, 26, 81, 13, 77, 132, 121, 178, 255, 88, 153, 159, 236, 68, 142, 229, 161, 239, 21])
  , preparedStepBindingsDigest := (bytes [41, 195, 150, 239, 32, 214, 79, 228, 162, 51, 30, 99, 33, 223, 87, 214, 123, 56, 48, 217, 115, 190, 236, 88, 223, 249, 30, 188, 147, 226, 21, 152])
  , executionDigest := (bytes [211, 235, 172, 239, 219, 81, 4, 198, 152, 115, 67, 102, 208, 155, 208, 227, 187, 253, 120, 104, 18, 87, 209, 247, 61, 70, 120, 76, 19, 152, 132, 231])
  , finalStateDigest := (bytes [1, 247, 115, 215, 23, 1, 108, 230, 175, 167, 73, 98, 183, 3, 79, 83, 190, 97, 204, 144, 79, 106, 207, 121, 17, 21, 75, 132, 7, 147, 140, 111])
  , transcriptFinalDigest := (bytes [246, 145, 4, 120, 181, 51, 64, 103, 101, 230, 199, 202, 205, 130, 54, 126, 6, 227, 62, 78, 176, 205, 145, 34, 137, 62, 7, 223, 122, 143, 103, 52])
  , mainLaneSurfaceDigest := (bytes [175, 242, 229, 61, 160, 59, 88, 170, 206, 47, 53, 48, 153, 104, 212, 38, 51, 37, 74, 184, 154, 107, 18, 99, 195, 98, 110, 61, 141, 64, 173, 114])
  , rootLaneColumnsDigest := (bytes [202, 175, 54, 249, 31, 220, 29, 162, 134, 134, 205, 12, 19, 192, 31, 178, 42, 110, 193, 192, 243, 152, 215, 42, 74, 237, 141, 161, 169, 103, 105, 237])
  , publicStepCount := 7
  , initialPc := 0
  , finalPc := 28
  , halted := true
  , digest := (bytes [144, 56, 113, 223, 195, 161, 9, 142, 114, 212, 230, 208, 183, 2, 175, 185, 110, 240, 1, 208, 34, 177, 245, 246, 90, 199, 103, 254, 191, 176, 169, 22])
}
    , exportedClaims := {
  accepted := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , statement := { proofStatementDigest := (bytes [144, 56, 113, 223, 195, 161, 9, 142, 114, 212, 230, 208, 183, 2, 175, 185, 110, 240, 1, 208, 34, 177, 245, 246, 90, 199, 103, 254, 191, 176, 169, 22]), kernelOpeningDigest := (bytes [181, 195, 83, 157, 191, 127, 29, 25, 230, 30, 150, 26, 72, 124, 26, 81, 13, 77, 132, 121, 178, 255, 88, 153, 159, 236, 68, 142, 229, 161, 239, 21]), digest := (bytes [31, 163, 57, 123, 240, 124, 175, 65, 112, 40, 86, 238, 208, 146, 16, 224, 88, 216, 96, 10, 55, 17, 98, 181, 65, 22, 102, 193, 178, 165, 87, 105]) }
  , mainLane := { mainLaneBundleDigest := (bytes [157, 184, 53, 28, 82, 148, 211, 217, 78, 64, 250, 39, 152, 131, 110, 124, 149, 58, 20, 110, 12, 214, 121, 115, 70, 89, 66, 100, 176, 101, 195, 101]), digest := (bytes [29, 253, 228, 93, 217, 211, 201, 202, 225, 199, 77, 129, 187, 52, 156, 188, 139, 140, 58, 248, 23, 253, 60, 227, 17, 54, 145, 69, 221, 139, 210, 27]) }
  , terminal := { finalStateDigest := (bytes [1, 247, 115, 215, 23, 1, 108, 230, 175, 167, 73, 98, 183, 3, 79, 83, 190, 97, 204, 144, 79, 106, 207, 121, 17, 21, 75, 132, 7, 147, 140, 111]), finalPc := 28, halted := true, digest := (bytes [56, 62, 217, 134, 162, 83, 165, 115, 243, 174, 108, 151, 212, 222, 171, 197, 37, 187, 66, 123, 44, 24, 161, 243, 187, 73, 104, 128, 224, 88, 85, 134]) }
  , digest := (bytes [137, 94, 128, 232, 240, 157, 105, 30, 184, 8, 26, 200, 116, 108, 110, 169, 100, 55, 231, 64, 207, 173, 68, 33, 118, 57, 236, 222, 83, 87, 205, 68])
}
  , mainLane := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { mainLaneBundleDigest := (bytes [157, 184, 53, 28, 82, 148, 211, 217, 78, 64, 250, 39, 152, 131, 110, 124, 149, 58, 20, 110, 12, 214, 121, 115, 70, 89, 66, 100, 176, 101, 195, 101]), digest := (bytes [37, 145, 6, 6, 219, 113, 203, 104, 136, 168, 137, 143, 163, 39, 111, 78, 188, 137, 253, 9, 19, 30, 161, 7, 242, 30, 120, 32, 219, 176, 58, 215]) }, digest := (bytes [119, 125, 191, 252, 202, 131, 60, 60, 207, 153, 107, 241, 202, 18, 6, 155, 30, 124, 10, 64, 85, 52, 69, 53, 152, 241, 201, 45, 91, 20, 201, 83]) }
  , opening := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , stages := { stageClaimsDigest := (bytes [154, 2, 231, 70, 20, 58, 230, 101, 52, 7, 50, 182, 243, 49, 248, 236, 233, 190, 102, 205, 57, 245, 80, 194, 229, 185, 53, 233, 44, 13, 104, 233]), stagePackagesDigest := (bytes [118, 50, 156, 47, 133, 6, 93, 207, 40, 242, 62, 194, 133, 244, 109, 164, 228, 251, 51, 247, 37, 21, 23, 139, 147, 121, 82, 178, 224, 249, 171, 114]), kernelOpeningDigest := (bytes [181, 195, 83, 157, 191, 127, 29, 25, 230, 30, 150, 26, 72, 124, 26, 81, 13, 77, 132, 121, 178, 255, 88, 153, 159, 236, 68, 142, 229, 161, 239, 21]), digest := (bytes [27, 61, 62, 59, 132, 25, 87, 179, 104, 207, 1, 54, 255, 149, 165, 215, 66, 186, 7, 204, 96, 117, 203, 45, 223, 55, 211, 247, 153, 38, 137, 21]) }
  , terminal := { preparedStepBindingsDigest := (bytes [41, 195, 150, 239, 32, 214, 79, 228, 162, 51, 30, 99, 33, 223, 87, 214, 123, 56, 48, 217, 115, 190, 236, 88, 223, 249, 30, 188, 147, 226, 21, 152]), executionDigest := (bytes [211, 235, 172, 239, 219, 81, 4, 198, 152, 115, 67, 102, 208, 155, 208, 227, 187, 253, 120, 104, 18, 87, 209, 247, 61, 70, 120, 76, 19, 152, 132, 231]), transcriptFinalDigest := (bytes [246, 145, 4, 120, 181, 51, 64, 103, 101, 230, 199, 202, 205, 130, 54, 126, 6, 227, 62, 78, 176, 205, 145, 34, 137, 62, 7, 223, 122, 143, 103, 52]), digest := (bytes [90, 57, 102, 215, 182, 48, 205, 189, 24, 186, 28, 86, 30, 126, 79, 149, 139, 36, 37, 254, 30, 152, 117, 44, 167, 46, 200, 140, 181, 13, 65, 39]) }
  , digest := (bytes [248, 132, 146, 18, 65, 140, 163, 77, 170, 87, 133, 201, 87, 157, 201, 231, 184, 88, 128, 112, 97, 122, 104, 31, 246, 21, 43, 150, 189, 84, 168, 53])
}
  , jointOpening := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { proofStatementDigest := (bytes [144, 56, 113, 223, 195, 161, 9, 142, 114, 212, 230, 208, 183, 2, 175, 185, 110, 240, 1, 208, 34, 177, 245, 246, 90, 199, 103, 254, 191, 176, 169, 22]), mainLaneClaimDigest := (bytes [119, 125, 191, 252, 202, 131, 60, 60, 207, 153, 107, 241, 202, 18, 6, 155, 30, 124, 10, 64, 85, 52, 69, 53, 152, 241, 201, 45, 91, 20, 201, 83]), kernelOpeningClaimDigest := (bytes [248, 132, 146, 18, 65, 140, 163, 77, 170, 87, 133, 201, 87, 157, 201, 231, 184, 88, 128, 112, 97, 122, 104, 31, 246, 21, 43, 150, 189, 84, 168, 53]), digest := (bytes [17, 102, 85, 103, 169, 138, 49, 238, 214, 104, 11, 189, 124, 46, 196, 54, 198, 137, 9, 33, 59, 74, 102, 196, 203, 183, 75, 226, 120, 86, 78, 11]) }, digest := (bytes [23, 241, 200, 51, 195, 18, 201, 232, 28, 77, 30, 189, 211, 120, 133, 203, 190, 196, 222, 150, 59, 60, 114, 172, 34, 244, 49, 223, 198, 62, 136, 134]) }
  , root0 := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), stages := { stage1Digest := (bytes [248, 83, 178, 47, 183, 64, 167, 213, 46, 91, 10, 99, 62, 110, 132, 116, 93, 93, 226, 16, 211, 156, 232, 54, 142, 211, 84, 128, 80, 117, 85, 150]), stage2Digest := (bytes [196, 71, 198, 8, 146, 145, 167, 84, 220, 161, 107, 98, 85, 177, 210, 218, 174, 250, 41, 0, 144, 47, 208, 110, 33, 168, 235, 189, 138, 191, 255, 150]), stage3Digest := (bytes [13, 62, 18, 231, 159, 216, 74, 146, 123, 100, 48, 154, 55, 62, 243, 77, 247, 72, 183, 146, 55, 128, 226, 205, 79, 61, 249, 159, 174, 184, 114, 0]), digest := (bytes [232, 33, 34, 12, 67, 20, 2, 37, 178, 96, 130, 219, 71, 138, 147, 112, 168, 87, 31, 41, 70, 230, 100, 30, 39, 251, 189, 197, 79, 137, 77, 45]) }, terminal := { root0Digest := (bytes [228, 98, 148, 141, 173, 208, 81, 252, 147, 68, 207, 191, 208, 77, 9, 104, 120, 204, 161, 231, 192, 35, 84, 44, 52, 102, 68, 156, 128, 207, 202, 141]), executionDigest := (bytes [211, 235, 172, 239, 219, 81, 4, 198, 152, 115, 67, 102, 208, 155, 208, 227, 187, 253, 120, 104, 18, 87, 209, 247, 61, 70, 120, 76, 19, 152, 132, 231]), finalStateDigest := (bytes [1, 247, 115, 215, 23, 1, 108, 230, 175, 167, 73, 98, 183, 3, 79, 83, 190, 97, 204, 144, 79, 106, 207, 121, 17, 21, 75, 132, 7, 147, 140, 111]), transcriptFinalDigest := (bytes [246, 145, 4, 120, 181, 51, 64, 103, 101, 230, 199, 202, 205, 130, 54, 126, 6, 227, 62, 78, 176, 205, 145, 34, 137, 62, 7, 223, 122, 143, 103, 52]), digest := (bytes [241, 143, 53, 1, 21, 113, 20, 56, 91, 53, 37, 48, 168, 27, 40, 86, 208, 59, 100, 194, 255, 2, 41, 174, 176, 239, 42, 236, 80, 141, 73, 47]) }, digest := (bytes [180, 89, 83, 48, 45, 254, 243, 70, 139, 178, 231, 50, 175, 131, 125, 233, 189, 236, 186, 130, 249, 252, 114, 251, 144, 8, 108, 25, 116, 233, 79, 45]) }
  , digest := (bytes [23, 195, 8, 36, 203, 148, 127, 171, 87, 152, 245, 234, 186, 35, 33, 125, 47, 226, 237, 217, 2, 95, 160, 68, 145, 211, 155, 34, 229, 197, 255, 146])
}
    , exportedKernelProof := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "native_word_shift_chain_ecall", fixtureId := "native_word_shift_chain_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , executionDigest := (bytes [211, 235, 172, 239, 219, 81, 4, 198, 152, 115, 67, 102, 208, 155, 208, 227, 187, 253, 120, 104, 18, 87, 209, 247, 61, 70, 120, 76, 19, 152, 132, 231])
  , shape := { executionRowCount := 7, realRowCount := 7, effectRowCount := 7, commitRowCount := 7, digest := (bytes [36, 118, 223, 124, 248, 115, 52, 199, 198, 250, 25, 33, 218, 131, 247, 174, 126, 69, 105, 226, 74, 199, 244, 245, 142, 55, 128, 143, 190, 129, 55, 117]) }
  , digest := (bytes [58, 234, 212, 76, 82, 208, 167, 67, 62, 218, 232, 108, 2, 116, 80, 108, 41, 29, 1, 9, 145, 63, 246, 202, 193, 119, 154, 36, 192, 116, 3, 202])
}
  , stages := { summary := { stage1RowCount := 7, stage2RegisterReadCount := 9, stage2RegisterWriteCount := 6, stage2RamEventCount := 0, stage2TwistLinkCount := 7, stage3ContinuityCount := 7, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [200, 186, 116, 165, 162, 250, 226, 207, 218, 18, 74, 163, 152, 182, 65, 254, 140, 33, 125, 158, 195, 66, 128, 215, 27, 7, 212, 125, 61, 107, 30, 150]) }, digest := (bytes [104, 218, 74, 24, 129, 84, 15, 61, 142, 147, 57, 159, 122, 144, 207, 242, 173, 67, 221, 223, 0, 18, 6, 30, 10, 124, 249, 68, 100, 237, 224, 46]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [211, 218, 130, 85, 140, 178, 79, 223, 229, 73, 205, 154, 192, 235, 95, 53, 198, 31, 80, 1, 48, 200, 23, 174, 19, 158, 102, 63, 38, 135, 45, 203]), stage1Digest := (bytes [134, 9, 7, 133, 202, 106, 171, 137, 185, 209, 142, 95, 153, 181, 175, 6, 249, 53, 4, 130, 158, 164, 176, 72, 207, 93, 252, 127, 230, 255, 21, 67]), stage2Digest := (bytes [153, 13, 167, 117, 179, 81, 0, 25, 21, 249, 210, 8, 212, 85, 205, 182, 125, 245, 145, 117, 100, 163, 97, 85, 120, 9, 43, 199, 193, 90, 138, 177]), stage3Digest := (bytes [191, 231, 148, 196, 231, 32, 230, 244, 246, 105, 83, 164, 118, 60, 102, 72, 67, 56, 200, 185, 75, 228, 213, 186, 94, 157, 206, 182, 221, 166, 14, 83]), transcriptDigest := (bytes [246, 145, 4, 120, 181, 51, 64, 103, 101, 230, 199, 202, 205, 130, 54, 126, 6, 227, 62, 78, 176, 205, 145, 34, 137, 62, 7, 223, 122, 143, 103, 52]), executionDigest := (bytes [211, 235, 172, 239, 219, 81, 4, 198, 152, 115, 67, 102, 208, 155, 208, 227, 187, 253, 120, 104, 18, 87, 209, 247, 61, 70, 120, 76, 19, 152, 132, 231]), digest := (bytes [72, 226, 204, 106, 209, 148, 118, 215, 123, 85, 189, 37, 156, 155, 32, 25, 48, 102, 113, 241, 19, 117, 230, 131, 246, 152, 238, 82, 128, 96, 147, 242]) }, statementDigest := (bytes [71, 26, 19, 31, 190, 78, 223, 71, 11, 88, 170, 244, 226, 113, 232, 4, 219, 164, 150, 35, 239, 193, 142, 10, 156, 16, 96, 157, 227, 55, 233, 197]), proofDigest := (bytes [178, 40, 63, 46, 243, 247, 184, 212, 174, 90, 172, 150, 59, 76, 23, 82, 120, 10, 157, 150, 75, 87, 1, 27, 209, 92, 17, 68, 101, 178, 178, 34]), digest := (bytes [154, 2, 231, 70, 20, 58, 230, 101, 52, 7, 50, 182, 243, 49, 248, 236, 233, 190, 102, 205, 57, 245, 80, 194, 229, 185, 53, 233, 44, 13, 104, 233]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [56, 205, 185, 245, 186, 115, 174, 71, 15, 59, 195, 51, 241, 188, 144, 241, 203, 89, 63, 206, 200, 174, 240, 18, 251, 72, 1, 197, 179, 74, 220, 8]), stage1Digest := (bytes [13, 241, 159, 115, 93, 17, 40, 130, 124, 132, 244, 152, 177, 67, 162, 99, 128, 52, 150, 89, 169, 233, 250, 14, 22, 230, 133, 180, 185, 38, 56, 139]), stage2Digest := (bytes [246, 218, 202, 16, 58, 159, 92, 33, 123, 130, 195, 15, 240, 80, 153, 151, 222, 251, 84, 43, 232, 102, 242, 193, 55, 56, 127, 115, 173, 171, 65, 108]), stage3Digest := (bytes [131, 117, 21, 163, 35, 215, 16, 73, 174, 212, 103, 77, 234, 136, 116, 201, 32, 240, 131, 33, 155, 237, 142, 245, 195, 121, 145, 70, 13, 44, 82, 196]), digest := (bytes [198, 178, 144, 188, 188, 58, 216, 96, 133, 234, 1, 177, 205, 3, 205, 80, 104, 170, 6, 19, 68, 155, 239, 122, 114, 72, 176, 157, 238, 224, 234, 195]) }, digest := (bytes [118, 50, 156, 47, 133, 6, 93, 207, 40, 242, 62, 194, 133, 244, 109, 164, 228, 251, 51, 247, 37, 21, 23, 139, 147, 121, 82, 178, 224, 249, 171, 114]) }
  , kernelOpening := { openingDigest := (bytes [247, 248, 69, 129, 246, 168, 80, 136, 174, 36, 155, 64, 16, 252, 84, 51, 13, 7, 13, 202, 25, 59, 232, 114, 123, 216, 173, 165, 117, 7, 71, 89]), bindings := { claimDigest := (bytes [246, 99, 76, 235, 26, 219, 170, 85, 38, 195, 183, 234, 211, 113, 33, 28, 25, 119, 91, 182, 110, 175, 43, 49, 169, 81, 178, 220, 121, 29, 142, 86]), bindingsDigest := (bytes [225, 190, 19, 232, 209, 46, 174, 190, 62, 103, 136, 32, 224, 152, 156, 36, 94, 32, 195, 58, 95, 178, 58, 243, 116, 73, 132, 97, 185, 227, 78, 206]), preparedStepsDigest := (bytes [152, 225, 237, 136, 174, 192, 85, 236, 115, 165, 197, 14, 21, 149, 57, 110, 142, 178, 55, 248, 241, 180, 221, 217, 109, 175, 38, 55, 34, 201, 38, 242]), digest := (bytes [60, 236, 104, 243, 51, 52, 123, 56, 27, 143, 137, 139, 30, 57, 39, 139, 99, 244, 241, 217, 225, 41, 25, 212, 123, 201, 227, 70, 212, 173, 254, 101]) }, digest := (bytes [181, 195, 83, 157, 191, 127, 29, 25, 230, 30, 150, 26, 72, 124, 26, 81, 13, 77, 132, 121, 178, 255, 88, 153, 159, 236, 68, 142, 229, 161, 239, 21]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [41, 195, 150, 239, 32, 214, 79, 228, 162, 51, 30, 99, 33, 223, 87, 214, 123, 56, 48, 217, 115, 190, 236, 88, 223, 249, 30, 188, 147, 226, 21, 152]), terminal := { root0Digest := (bytes [228, 98, 148, 141, 173, 208, 81, 252, 147, 68, 207, 191, 208, 77, 9, 104, 120, 204, 161, 231, 192, 35, 84, 44, 52, 102, 68, 156, 128, 207, 202, 141]), executionDigest := (bytes [211, 235, 172, 239, 219, 81, 4, 198, 152, 115, 67, 102, 208, 155, 208, 227, 187, 253, 120, 104, 18, 87, 209, 247, 61, 70, 120, 76, 19, 152, 132, 231]), finalStateDigest := (bytes [1, 247, 115, 215, 23, 1, 108, 230, 175, 167, 73, 98, 183, 3, 79, 83, 190, 97, 204, 144, 79, 106, 207, 121, 17, 21, 75, 132, 7, 147, 140, 111]), transcriptFinalDigest := (bytes [246, 145, 4, 120, 181, 51, 64, 103, 101, 230, 199, 202, 205, 130, 54, 126, 6, 227, 62, 78, 176, 205, 145, 34, 137, 62, 7, 223, 122, 143, 103, 52]), finalPc := 28, halted := true, digest := (bytes [96, 86, 243, 189, 152, 53, 19, 92, 125, 157, 112, 9, 11, 185, 179, 17, 32, 195, 53, 211, 210, 181, 233, 214, 123, 72, 189, 118, 143, 245, 189, 167]) }, digest := (bytes [7, 250, 249, 107, 159, 171, 46, 82, 105, 220, 85, 187, 161, 166, 34, 206, 6, 240, 187, 203, 152, 203, 31, 67, 23, 200, 73, 90, 99, 8, 87, 125]) }, statementDigest := (bytes [110, 47, 130, 218, 147, 20, 153, 51, 38, 142, 195, 49, 92, 172, 232, 189, 99, 199, 172, 138, 193, 8, 157, 130, 60, 174, 88, 115, 142, 243, 127, 54]), proofDigest := (bytes [250, 195, 242, 92, 188, 228, 8, 54, 122, 101, 207, 157, 128, 145, 171, 222, 59, 82, 220, 58, 149, 183, 48, 64, 84, 37, 32, 33, 92, 102, 204, 127]), digest := (bytes [119, 98, 233, 24, 215, 68, 61, 19, 147, 216, 204, 61, 157, 117, 112, 197, 76, 192, 171, 71, 230, 177, 12, 189, 74, 93, 189, 151, 52, 212, 208, 236]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [153, 121, 216, 110, 240, 248, 146, 157, 20, 167, 12, 189, 154, 204, 132, 202, 108, 103, 204, 78, 60, 2, 173, 204, 105, 180, 243, 80, 48, 209, 32, 17]), layoutVersion := 1, digest := (bytes [99, 142, 166, 59, 238, 59, 149, 214, 93, 217, 239, 31, 34, 87, 244, 70, 32, 9, 72, 139, 114, 157, 6, 31, 189, 0, 96, 226, 71, 34, 229, 95]) }, rowWidth := 38, timeLen := 7, columnDigests := [(bytes [40, 243, 169, 246, 170, 121, 143, 48, 132, 183, 68, 213, 151, 130, 14, 65, 20, 212, 138, 236, 77, 112, 226, 150, 158, 109, 142, 75, 172, 115, 156, 234]), (bytes [183, 255, 181, 34, 203, 1, 222, 219, 152, 86, 144, 13, 74, 163, 20, 134, 40, 184, 20, 201, 107, 98, 76, 0, 125, 194, 18, 176, 16, 226, 102, 175]), (bytes [153, 111, 70, 176, 156, 174, 226, 182, 197, 190, 144, 153, 100, 226, 206, 209, 132, 162, 24, 222, 166, 233, 132, 102, 120, 151, 149, 92, 177, 154, 105, 134]), (bytes [188, 23, 179, 202, 216, 119, 253, 192, 107, 56, 140, 18, 247, 51, 234, 39, 235, 216, 134, 241, 7, 60, 104, 146, 182, 166, 45, 236, 214, 213, 211, 83]), (bytes [78, 156, 218, 132, 187, 128, 28, 175, 180, 45, 97, 45, 52, 94, 142, 189, 238, 235, 64, 164, 28, 129, 72, 154, 162, 227, 67, 115, 203, 223, 178, 142]), (bytes [189, 155, 81, 251, 138, 136, 164, 240, 180, 224, 212, 246, 18, 174, 156, 132, 116, 45, 59, 219, 73, 254, 15, 113, 76, 59, 178, 6, 146, 205, 42, 115]), (bytes [168, 158, 183, 194, 59, 180, 51, 126, 250, 210, 142, 218, 119, 32, 165, 239, 245, 70, 212, 189, 195, 167, 153, 17, 153, 157, 56, 25, 27, 21, 189, 146]), (bytes [219, 173, 100, 223, 171, 1, 39, 17, 46, 51, 57, 219, 160, 183, 120, 245, 65, 217, 219, 14, 138, 72, 96, 115, 208, 0, 240, 36, 251, 136, 217, 106]), (bytes [179, 197, 166, 238, 247, 39, 161, 56, 86, 33, 181, 194, 233, 28, 80, 101, 156, 182, 133, 82, 176, 76, 183, 86, 85, 15, 113, 247, 11, 149, 206, 77]), (bytes [194, 169, 173, 29, 87, 213, 106, 41, 191, 121, 147, 102, 81, 113, 114, 66, 108, 114, 250, 131, 6, 253, 216, 198, 121, 242, 243, 205, 133, 213, 44, 69]), (bytes [34, 66, 101, 86, 144, 122, 14, 179, 45, 168, 117, 59, 211, 96, 252, 176, 204, 151, 121, 60, 105, 8, 12, 175, 172, 123, 38, 241, 39, 82, 180, 168]), (bytes [85, 129, 120, 17, 159, 15, 138, 237, 251, 198, 57, 163, 198, 187, 181, 57, 167, 74, 108, 55, 221, 93, 134, 114, 83, 91, 141, 93, 103, 221, 230, 253]), (bytes [18, 172, 128, 176, 253, 198, 4, 93, 34, 80, 94, 154, 166, 81, 235, 21, 208, 214, 240, 19, 132, 26, 227, 255, 47, 232, 138, 242, 49, 178, 152, 151]), (bytes [253, 211, 57, 186, 104, 56, 3, 26, 129, 185, 211, 251, 238, 155, 29, 124, 129, 209, 87, 124, 7, 144, 114, 245, 223, 214, 100, 145, 234, 90, 77, 153]), (bytes [242, 1, 63, 177, 206, 208, 100, 22, 231, 176, 240, 61, 227, 173, 73, 250, 20, 176, 119, 198, 90, 249, 204, 195, 8, 124, 11, 51, 17, 235, 161, 140]), (bytes [44, 32, 216, 93, 16, 146, 0, 130, 207, 204, 36, 141, 166, 246, 232, 20, 247, 247, 116, 89, 62, 217, 122, 245, 142, 15, 143, 44, 219, 131, 183, 12]), (bytes [63, 55, 148, 202, 193, 201, 88, 153, 244, 174, 145, 10, 157, 92, 137, 79, 24, 240, 86, 214, 120, 193, 105, 254, 83, 207, 7, 36, 175, 251, 198, 209]), (bytes [49, 184, 142, 166, 178, 93, 15, 133, 19, 3, 245, 149, 190, 250, 17, 77, 195, 143, 141, 153, 122, 25, 168, 96, 127, 182, 178, 210, 211, 3, 144, 60]), (bytes [86, 196, 110, 116, 66, 242, 23, 243, 102, 32, 103, 253, 30, 136, 67, 166, 214, 221, 241, 169, 190, 115, 51, 189, 2, 90, 50, 65, 2, 198, 240, 74]), (bytes [204, 170, 135, 24, 120, 2, 130, 166, 238, 140, 237, 167, 80, 81, 222, 98, 53, 76, 178, 231, 84, 4, 44, 222, 24, 14, 1, 161, 175, 62, 34, 83]), (bytes [254, 19, 232, 192, 11, 39, 102, 229, 212, 95, 179, 72, 76, 113, 31, 113, 119, 17, 192, 125, 69, 105, 89, 144, 235, 22, 196, 55, 37, 148, 98, 206]), (bytes [126, 178, 122, 220, 67, 252, 127, 71, 82, 225, 133, 219, 37, 32, 10, 78, 133, 40, 227, 107, 52, 114, 163, 131, 123, 127, 232, 227, 171, 62, 101, 156]), (bytes [150, 56, 15, 19, 5, 104, 56, 230, 209, 159, 201, 154, 59, 102, 109, 165, 137, 182, 61, 198, 151, 229, 213, 14, 110, 234, 163, 84, 29, 98, 8, 176]), (bytes [105, 118, 181, 152, 170, 170, 80, 36, 29, 249, 169, 142, 236, 59, 15, 11, 59, 205, 14, 114, 151, 114, 7, 73, 18, 196, 2, 193, 250, 170, 235, 120]), (bytes [87, 1, 92, 107, 112, 167, 64, 72, 4, 131, 203, 104, 88, 56, 9, 128, 223, 142, 99, 228, 224, 67, 80, 30, 120, 182, 57, 96, 168, 242, 217, 95]), (bytes [127, 173, 148, 81, 228, 129, 62, 46, 172, 74, 9, 108, 122, 134, 202, 226, 44, 207, 71, 119, 97, 112, 85, 223, 223, 71, 49, 13, 244, 157, 198, 116]), (bytes [121, 73, 251, 102, 179, 33, 89, 124, 134, 206, 98, 15, 47, 86, 71, 209, 119, 88, 17, 23, 79, 123, 152, 112, 138, 201, 7, 67, 225, 58, 179, 29]), (bytes [115, 221, 25, 201, 235, 175, 57, 9, 159, 237, 1, 99, 122, 176, 133, 105, 76, 191, 15, 198, 154, 87, 195, 119, 27, 252, 234, 251, 191, 97, 36, 22]), (bytes [150, 176, 216, 226, 239, 79, 218, 77, 47, 25, 98, 54, 47, 52, 197, 168, 30, 126, 93, 34, 149, 210, 8, 114, 248, 27, 12, 14, 147, 154, 204, 250]), (bytes [83, 251, 49, 48, 54, 174, 206, 33, 38, 55, 53, 86, 238, 134, 67, 140, 194, 44, 73, 155, 93, 189, 217, 191, 38, 87, 214, 184, 137, 68, 230, 167]), (bytes [240, 212, 182, 90, 28, 28, 194, 255, 94, 159, 35, 103, 91, 242, 214, 20, 102, 217, 67, 85, 43, 252, 11, 32, 160, 11, 241, 164, 190, 14, 75, 153]), (bytes [83, 203, 23, 43, 120, 2, 138, 179, 201, 101, 117, 199, 249, 119, 150, 189, 107, 206, 100, 240, 241, 191, 29, 12, 95, 189, 46, 162, 173, 67, 52, 64]), (bytes [243, 18, 112, 16, 115, 206, 161, 217, 70, 120, 53, 168, 21, 217, 125, 177, 15, 184, 39, 220, 129, 252, 253, 217, 143, 169, 231, 204, 197, 173, 74, 44]), (bytes [174, 205, 154, 64, 243, 198, 70, 67, 132, 170, 211, 195, 186, 11, 96, 55, 55, 6, 248, 130, 169, 186, 214, 86, 104, 198, 34, 111, 234, 42, 133, 117]), (bytes [181, 205, 4, 135, 126, 61, 165, 192, 182, 157, 219, 25, 61, 190, 241, 123, 199, 165, 114, 116, 128, 144, 237, 80, 99, 219, 70, 24, 44, 75, 141, 99]), (bytes [64, 184, 77, 60, 124, 164, 54, 93, 23, 121, 89, 235, 81, 60, 107, 51, 86, 73, 18, 40, 80, 16, 45, 151, 39, 61, 175, 64, 40, 48, 21, 239]), (bytes [10, 155, 182, 37, 26, 80, 79, 213, 200, 66, 53, 194, 225, 49, 41, 142, 45, 21, 123, 146, 196, 246, 52, 107, 151, 162, 236, 199, 129, 135, 242, 251]), (bytes [145, 99, 191, 35, 121, 90, 118, 57, 187, 82, 200, 99, 201, 117, 132, 16, 109, 95, 126, 62, 89, 129, 183, 210, 46, 8, 148, 208, 73, 204, 191, 238])], familyDigest := (bytes [153, 121, 216, 110, 240, 248, 146, 157, 20, 167, 12, 189, 154, 204, 132, 202, 108, 103, 204, 78, 60, 2, 173, 204, 105, 180, 243, 80, 48, 209, 32, 17]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [153, 121, 216, 110, 240, 248, 146, 157, 20, 167, 12, 189, 154, 204, 132, 202, 108, 103, 204, 78, 60, 2, 173, 204, 105, 180, 243, 80, 48, 209, 32, 17]), layoutVersion := 1, digest := (bytes [99, 142, 166, 59, 238, 59, 149, 214, 93, 217, 239, 31, 34, 87, 244, 70, 32, 9, 72, 139, 114, 157, 6, 31, 189, 0, 96, 226, 71, 34, 229, 95]) }, logicalIndex := 0, digest := (bytes [18, 51, 19, 39, 198, 104, 194, 81, 151, 63, 76, 177, 54, 35, 250, 176, 124, 88, 101, 157, 92, 13, 106, 3, 11, 85, 186, 117, 194, 10, 231, 245]) }, valueDigest := (bytes [32, 25, 54, 149, 189, 186, 227, 219, 56, 115, 101, 166, 109, 248, 186, 201, 34, 174, 25, 48, 30, 45, 249, 8, 84, 206, 95, 5, 29, 90, 169, 83]), digest := (bytes [208, 220, 60, 227, 9, 124, 49, 34, 147, 193, 229, 226, 222, 252, 98, 171, 161, 215, 104, 20, 175, 74, 64, 218, 155, 31, 93, 177, 68, 15, 57, 187]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [153, 121, 216, 110, 240, 248, 146, 157, 20, 167, 12, 189, 154, 204, 132, 202, 108, 103, 204, 78, 60, 2, 173, 204, 105, 180, 243, 80, 48, 209, 32, 17]), layoutVersion := 1, digest := (bytes [99, 142, 166, 59, 238, 59, 149, 214, 93, 217, 239, 31, 34, 87, 244, 70, 32, 9, 72, 139, 114, 157, 6, 31, 189, 0, 96, 226, 71, 34, 229, 95]) }, logicalIndex := 6, digest := (bytes [137, 178, 248, 108, 119, 225, 187, 34, 49, 110, 111, 188, 151, 93, 162, 150, 63, 252, 241, 220, 218, 34, 72, 6, 185, 255, 216, 220, 72, 152, 88, 42]) }, valueDigest := (bytes [57, 167, 127, 66, 29, 28, 1, 62, 111, 174, 45, 82, 212, 157, 25, 154, 254, 72, 204, 85, 223, 7, 138, 44, 48, 11, 222, 83, 122, 239, 183, 120]), digest := (bytes [188, 60, 90, 111, 119, 197, 231, 126, 36, 27, 172, 206, 148, 232, 22, 65, 235, 167, 200, 142, 198, 179, 168, 235, 107, 21, 96, 205, 87, 181, 185, 239]) }), digest := (bytes [202, 175, 54, 249, 31, 220, 29, 162, 134, 134, 205, 12, 19, 192, 31, 178, 42, 110, 193, 192, 243, 152, 215, 42, 74, 237, 141, 161, 169, 103, 105, 237]) }
  , rootLaneCommitment := { timeLen := 7, commitments := { commitmentCount := 38, digest := (bytes [170, 14, 29, 134, 225, 199, 103, 89, 7, 214, 134, 26, 126, 57, 75, 67, 52, 64, 39, 68, 204, 188, 74, 124, 197, 133, 40, 188, 47, 249, 206, 220]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [170, 14, 29, 134, 225, 199, 103, 89, 7, 214, 134, 26, 126, 57, 75, 67, 52, 64, 39, 68, 204, 188, 74, 124, 197, 133, 40, 188, 47, 249, 206, 220]), layoutVersion := 3, digest := (bytes [71, 102, 67, 138, 160, 200, 44, 93, 228, 136, 209, 29, 173, 196, 235, 81, 140, 197, 109, 2, 166, 200, 61, 133, 227, 190, 109, 174, 114, 1, 8, 154]) }, logicalIndex := 0, digest := (bytes [169, 26, 255, 10, 135, 163, 112, 72, 70, 110, 179, 177, 254, 131, 186, 62, 64, 217, 149, 216, 203, 138, 234, 226, 187, 210, 38, 63, 102, 49, 27, 1]) }, valueDigest := (bytes [32, 25, 54, 149, 189, 186, 227, 219, 56, 115, 101, 166, 109, 248, 186, 201, 34, 174, 25, 48, 30, 45, 249, 8, 84, 206, 95, 5, 29, 90, 169, 83]), digest := (bytes [118, 90, 125, 244, 99, 23, 222, 38, 51, 105, 79, 48, 156, 255, 31, 21, 223, 129, 105, 179, 67, 134, 106, 93, 236, 182, 103, 252, 221, 72, 115, 28]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [170, 14, 29, 134, 225, 199, 103, 89, 7, 214, 134, 26, 126, 57, 75, 67, 52, 64, 39, 68, 204, 188, 74, 124, 197, 133, 40, 188, 47, 249, 206, 220]), layoutVersion := 3, digest := (bytes [71, 102, 67, 138, 160, 200, 44, 93, 228, 136, 209, 29, 173, 196, 235, 81, 140, 197, 109, 2, 166, 200, 61, 133, 227, 190, 109, 174, 114, 1, 8, 154]) }, logicalIndex := 6, digest := (bytes [180, 192, 230, 255, 80, 0, 32, 166, 6, 146, 202, 92, 101, 223, 121, 213, 14, 79, 174, 196, 222, 99, 131, 100, 106, 197, 26, 84, 109, 60, 245, 44]) }, valueDigest := (bytes [57, 167, 127, 66, 29, 28, 1, 62, 111, 174, 45, 82, 212, 157, 25, 154, 254, 72, 204, 85, 223, 7, 138, 44, 48, 11, 222, 83, 122, 239, 183, 120]), digest := (bytes [190, 190, 249, 7, 73, 29, 42, 8, 76, 100, 82, 228, 184, 222, 91, 178, 186, 139, 221, 6, 168, 159, 2, 155, 165, 36, 221, 26, 183, 176, 78, 100]) }), digest := (bytes [19, 66, 14, 108, 184, 243, 218, 181, 55, 225, 166, 228, 205, 83, 99, 109, 255, 56, 70, 59, 157, 187, 21, 165, 253, 51, 112, 94, 92, 162, 254, 233]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [202, 175, 54, 249, 31, 220, 29, 162, 134, 134, 205, 12, 19, 192, 31, 178, 42, 110, 193, 192, 243, 152, 215, 42, 74, 237, 141, 161, 169, 103, 105, 237]), rootLaneCommitmentDigest := (bytes [19, 66, 14, 108, 184, 243, 218, 181, 55, 225, 166, 228, 205, 83, 99, 109, 255, 56, 70, 59, 157, 187, 21, 165, 253, 51, 112, 94, 92, 162, 254, 233]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 7, digest := (bytes [205, 50, 135, 117, 150, 42, 203, 16, 236, 253, 110, 121, 48, 68, 115, 251, 11, 157, 41, 163, 56, 154, 12, 74, 203, 247, 246, 101, 23, 130, 3, 100]) }, statementDigest := (bytes [7, 109, 15, 141, 11, 23, 102, 193, 30, 187, 15, 18, 199, 247, 3, 194, 72, 103, 113, 60, 174, 114, 72, 186, 21, 236, 118, 168, 171, 51, 224, 94]), proofDigest := (bytes [45, 30, 35, 153, 35, 207, 194, 222, 206, 45, 186, 45, 112, 192, 119, 217, 203, 235, 46, 72, 166, 141, 4, 13, 199, 56, 249, 187, 121, 49, 91, 229]), digest := (bytes [157, 184, 53, 28, 82, 148, 211, 217, 78, 64, 250, 39, 152, 131, 110, 124, 149, 58, 20, 110, 12, 214, 121, 115, 70, 89, 66, 100, 176, 101, 195, 101]) }
  , digest := (bytes [32, 98, 5, 28, 247, 19, 23, 230, 12, 30, 137, 32, 79, 181, 252, 211, 32, 107, 117, 205, 248, 228, 1, 104, 36, 229, 151, 228, 219, 128, 47, 125])
}
    , transcript := {
  appLabel := (bytes [110, 101, 111, 46, 102, 111, 108, 100, 46, 110, 101, 120, 116, 47, 114, 118, 54, 52, 105, 109, 47, 112, 97, 114, 105, 116, 121, 95, 107, 101, 114, 110, 101, 108, 95, 118, 49])
  , events := [{
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 116, 114, 97, 110, 115, 99, 114, 105, 112, 116, 95, 115, 101, 101, 100])
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 110, 97, 116, 105, 118, 101, 45, 119, 111, 114, 100, 45, 115, 104, 105, 102, 116, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [29400036373852023, 54383638505065, 94828755958258816, 10905788041622594868, 8841251816071870994, 13391653407446453246, 17446101127387435910, 7137168547377178156], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [110, 97, 116, 105, 118, 101, 95, 119, 111, 114, 100, 95, 115, 104, 105, 102, 116, 95, 99, 104, 97, 105, 110, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [29400036373852023, 54383638505065, 94828755958258816, 10905788041622594868, 8841251816071870994, 13391653407446453246, 17446101127387435910, 7137168547377178156], absorbed := 2 }
  , cursorAfter := { stateWords := [108, 9521594137446015360, 2547443039661527262, 8672344190622444400, 8081909694194674092, 16881897145227272165, 8660841998244389168, 6317820854843455934], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [32543131, 4280859, 1078022811, 6329275, 6378555, 1080120507, 115]
  , cursorBefore := { stateWords := [108, 9521594137446015360, 2547443039661527262, 8672344190622444400, 8081909694194674092, 16881897145227272165, 8660841998244389168, 6317820854843455934], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 14817934692253552668, 5422135311370894167, 11520748702834940406, 11883633006059594575, 13899328913923243995, 3788765349771335243, 8170474725918284627], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 1, 18446744071562067968, 0, 0, 0, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [0, 14817934692253552668, 5422135311370894167, 11520748702834940406, 11883633006059594575, 13899328913923243995, 3788765349771335243, 8170474725918284627], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 0, 0, 5599915549487473793, 16406075848753953094, 4257212436415025084, 11701250843308806400, 7729765377244787962], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [0, 0, 0, 5599915549487473793, 16406075848753953094, 4257212436415025084, 11701250843308806400, 7729765377244787962], absorbed := 3 }
  , cursorAfter := { stateWords := [0, 14440487766866437759, 16158411280243843198, 11068495199233569458, 14924541703762306079, 8267198643178946222, 3573274338800551902, 11655965166207194028], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [228, 98, 148, 141, 173, 208, 81, 252, 147, 68, 207, 191, 208, 77, 9, 104, 120, 204, 161, 231, 192, 35, 84, 44, 52, 102, 68, 156, 128, 207, 202, 141])
  , u64s := []
  , cursorBefore := { stateWords := [0, 14440487766866437759, 16158411280243843198, 11068495199233569458, 14924541703762306079, 8267198643178946222, 3573274338800551902, 11655965166207194028], absorbed := 1 }
  , cursorAfter := { stateWords := [13311955648816485990, 16750417430444283956, 7685154747109710587, 6295989157772776084, 10092538584374784937, 8793270786648840439, 14540163602231133867, 16323917404508849710], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [13311955648816485990, 16750417430444283956, 7685154747109710587, 6295989157772776084, 10092538584374784937, 8793270786648840439, 14540163602231133867, 16323917404508849710], absorbed := 0 }
  , cursorAfter := { stateWords := [16632802919108710147, 13258520627264740138, 17110149117418189791, 6344445357732662908, 300123635686731147, 4690309516771459959, 1666160823646593165, 18427001648205017043], absorbed := 0 }
  , challengeOutput := (some 16632802919108710147)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [248, 83, 178, 47, 183, 64, 167, 213, 46, 91, 10, 99, 62, 110, 132, 116, 93, 93, 226, 16, 211, 156, 232, 54, 142, 211, 84, 128, 80, 117, 85, 150])
  , u64s := []
  , cursorBefore := { stateWords := [16632802919108710147, 13258520627264740138, 17110149117418189791, 6344445357732662908, 300123635686731147, 4690309516771459959, 1666160823646593165, 18427001648205017043], absorbed := 0 }
  , cursorAfter := { stateWords := [59409784501007492, 36122064619759772, 2522182992, 5559568679772866832, 16947521631507430986, 7097905515152098934, 9662790264370553859, 14387856573604793263], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [59409784501007492, 36122064619759772, 2522182992, 5559568679772866832, 16947521631507430986, 7097905515152098934, 9662790264370553859, 14387856573604793263], absorbed := 3 }
  , cursorAfter := { stateWords := [6139558469011796608, 4884362147061659144, 6321389962816677855, 8024296613977891277, 17489341190933289337, 16990790758108438777, 8165258603605472692, 2764174045714964182], absorbed := 0 }
  , challengeOutput := (some 6139558469011796608)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [6139558469011796608, 4884362147061659144, 6321389962816677855, 8024296613977891277, 17489341190933289337, 16990790758108438777, 8165258603605472692, 2764174045714964182], absorbed := 0 }
  , cursorAfter := { stateWords := [17659153299687098721, 17712354528554568885, 7814109569743718645, 7005650859248593987, 16662198303255909078, 12430977943436854309, 16377826725812306225, 12444259142770773964], absorbed := 0 }
  , challengeOutput := (some 17659153299687098721)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [196, 71, 198, 8, 146, 145, 167, 84, 220, 161, 107, 98, 85, 177, 210, 218, 174, 250, 41, 0, 144, 47, 208, 110, 33, 168, 235, 189, 138, 191, 255, 150])
  , u64s := []
  , cursorBefore := { stateWords := [17659153299687098721, 17712354528554568885, 7814109569743718645, 7005650859248593987, 16662198303255909078, 12430977943436854309, 16377826725812306225, 12444259142770773964], absorbed := 0 }
  , cursorAfter := { stateWords := [40532576945756882, 53457877946257455, 2533343114, 4389037520566929362, 905308323029389650, 6715865865346790960, 16344541882997798331, 15633995429416586303], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [40532576945756882, 53457877946257455, 2533343114, 4389037520566929362, 905308323029389650, 6715865865346790960, 16344541882997798331, 15633995429416586303], absorbed := 3 }
  , cursorAfter := { stateWords := [9836651665554253514, 1013454718206227654, 17847195175752135230, 7315708913189141393, 4158483092181717784, 15953468123669375930, 4646134940636474177, 3253426992010223375], absorbed := 0 }
  , challengeOutput := (some 9836651665554253514)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [13, 62, 18, 231, 159, 216, 74, 146, 123, 100, 48, 154, 55, 62, 243, 77, 247, 72, 183, 146, 55, 128, 226, 205, 79, 61, 249, 159, 174, 184, 114, 0])
  , u64s := []
  , cursorBefore := { stateWords := [9836651665554253514, 1013454718206227654, 17847195175752135230, 7315708913189141393, 4158483092181717784, 15953468123669375930, 4646134940636474177, 3253426992010223375], absorbed := 0 }
  , cursorAfter := { stateWords := [15642439619923443, 45028563024208512, 7518382, 8453740008147120415, 6979412999780891539, 577455515313918828, 16131038695622428852, 5173994843640728666], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [211, 235, 172, 239, 219, 81, 4, 198, 152, 115, 67, 102, 208, 155, 208, 227, 187, 253, 120, 104, 18, 87, 209, 247, 61, 70, 120, 76, 19, 152, 132, 231])
  , u64s := []
  , cursorBefore := { stateWords := [15642439619923443, 45028563024208512, 7518382, 8453740008147120415, 6979412999780891539, 577455515313918828, 16131038695622428852, 5173994843640728666], absorbed := 3 }
  , cursorAfter := { stateWords := [5181418443105232, 21524341312704855, 3884226579, 16025574383039273646, 13256995863280240603, 1918059058719304446, 6436782240809769697, 11503317375494532065], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [1, 247, 115, 215, 23, 1, 108, 230, 175, 167, 73, 98, 183, 3, 79, 83, 190, 97, 204, 144, 79, 106, 207, 121, 17, 21, 75, 132, 7, 147, 140, 111])
  , u64s := []
  , cursorBefore := { stateWords := [5181418443105232, 21524341312704855, 3884226579, 16025574383039273646, 13256995863280240603, 1918059058719304446, 6436782240809769697, 11503317375494532065], absorbed := 3 }
  , cursorAfter := { stateWords := [22395730647733071, 37237250785398634, 1871483655, 11729623726878119526, 18264761168511554550, 10337290128883049922, 1618482010682628583, 17010165591468757266], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [22395730647733071, 37237250785398634, 1871483655, 11729623726878119526, 18264761168511554550, 10337290128883049922, 1618482010682628583, 17010165591468757266], absorbed := 3 }
  , cursorAfter := { stateWords := [15711142033001630324, 4134151270888011781, 13431836156901815533, 16491183845168824840, 9933720971416121710, 1904543339923196549, 10946279722588893383, 5822108707308381839], absorbed := 0 }
  , challengeOutput := (some 15711142033001630324)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [15711142033001630324, 4134151270888011781, 13431836156901815533, 16491183845168824840, 9933720971416121710, 1904543339923196549, 10946279722588893383, 5822108707308381839], absorbed := 0 }
  , cursorAfter := { stateWords := [7440003438911721974, 9094600317903300197, 2490998226023277318, 3776144570464026249, 14964218005992433550, 10701830863539091962, 2846698840040576937, 17077938386530220705], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [246, 145, 4, 120, 181, 51, 64, 103, 101, 230, 199, 202, 205, 130, 54, 126, 6, 227, 62, 78, 176, 205, 145, 34, 137, 62, 7, 223, 122, 143, 103, 52]))
}]
}
    , stage1 := stage1
    , stage2 := stage2
    , stage3 := stage3
    , rootExecution := rootExecution
    , stepComposition := stepComposition
    , soundnessAccounting := soundnessAccounting
    , kernelOpeningBundle := kernelOpeningBundle
    , digest := (bytes [156, 55, 38, 155, 71, 93, 13, 190, 140, 204, 90, 183, 28, 191, 232, 118, 44, 0, 237, 117, 226, 189, 255, 15, 172, 9, 241, 91, 194, 169, 150, 85])
  }

end Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors.Case_native_word_shift_chain_ecall
