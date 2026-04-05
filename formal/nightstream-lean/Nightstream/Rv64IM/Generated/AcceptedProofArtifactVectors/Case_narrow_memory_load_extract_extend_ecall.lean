import Nightstream.Rv64IM.Generated.AcceptedProofArtifactTypes

set_option maxHeartbeats 0
set_option maxRecDepth 65536

namespace Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors.Case_narrow_memory_load_extract_extend_ecall

open Nightstream.Rv64IM.Generated

def stage1SemInputs : List SemInView :=
  [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, pc := 0, opcode := .lb, traceOpcode := (some .lb), traceVirtualOpcode := none, family := .narrowMemory, archRs1 := 10, archRs1Value := 12288, archRs2 := 0, archRs2Value := 0, archRd := 1, archRdBefore := 0, archImm := 0, rs1 := 10, rs1Value := 12288, rs2 := 0, rs2Value := 0, rd := 1, rdBefore := 0, rdAfter := 18446744073709551615, imm := 0, effectiveAddr := (some 12288), memoryBefore := (some 9920249032750366975), memoryAfter := (some 9920249032750366975), memWidthBytes := (some 1), memUnsigned := (some false), writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, pc := 4, opcode := .lbu, traceOpcode := (some .lbu), traceVirtualOpcode := none, family := .narrowMemory, archRs1 := 10, archRs1Value := 12288, archRs2 := 0, archRs2Value := 0, archRd := 2, archRdBefore := 0, archImm := 1, rs1 := 10, rs1Value := 12288, rs2 := 0, rs2Value := 0, rd := 2, rdBefore := 0, rdAfter := 128, imm := 1, effectiveAddr := (some 12289), memoryBefore := (some 9920249032750366975), memoryAfter := (some 9920249032750366975), memWidthBytes := (some 1), memUnsigned := (some true), writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, pc := 8, opcode := .lh, traceOpcode := (some .lh), traceVirtualOpcode := none, family := .narrowMemory, archRs1 := 10, archRs1Value := 12288, archRs2 := 0, archRs2Value := 0, archRd := 3, archRdBefore := 0, archImm := 0, rs1 := 10, rs1Value := 12288, rs2 := 0, rs2Value := 0, rd := 3, rdBefore := 0, rdAfter := 18446744073709519103, imm := 0, effectiveAddr := (some 12288), memoryBefore := (some 9920249032750366975), memoryAfter := (some 9920249032750366975), memWidthBytes := (some 2), memUnsigned := (some false), writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, pc := 12, opcode := .lhu, traceOpcode := (some .lhu), traceVirtualOpcode := none, family := .narrowMemory, archRs1 := 10, archRs1Value := 12288, archRs2 := 0, archRs2Value := 0, archRd := 4, archRdBefore := 0, archImm := 2, rs1 := 10, rs1Value := 12288, rs2 := 0, rs2Value := 0, rd := 4, rdBefore := 0, rdAfter := 32895, imm := 2, effectiveAddr := (some 12290), memoryBefore := (some 9920249032750366975), memoryAfter := (some 9920249032750366975), memWidthBytes := (some 2), memUnsigned := (some true), writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 4, stepIndex := 4, sequenceIndex := 0, pc := 16, opcode := .lw, traceOpcode := (some .lw), traceVirtualOpcode := none, family := .narrowMemory, archRs1 := 10, archRs1Value := 12288, archRs2 := 0, archRs2Value := 0, archRd := 5, archRdBefore := 0, archImm := 0, rs1 := 10, rs1Value := 12288, rs2 := 0, rs2Value := 0, rd := 5, rdBefore := 0, rdAfter := 18446744071570424063, imm := 0, effectiveAddr := (some 12288), memoryBefore := (some 9920249032750366975), memoryAfter := (some 9920249032750366975), memWidthBytes := (some 4), memUnsigned := (some false), writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 5, stepIndex := 5, sequenceIndex := 0, pc := 20, opcode := .lwu, traceOpcode := (some .lwu), traceVirtualOpcode := none, family := .narrowMemory, archRs1 := 10, archRs1Value := 12288, archRs2 := 0, archRs2Value := 0, archRd := 6, archRdBefore := 0, archImm := 4, rs1 := 10, rs1Value := 12288, rs2 := 0, rs2Value := 0, rd := 6, rdBefore := 0, rdAfter := 2309737967, imm := 4, effectiveAddr := (some 12292), memoryBefore := (some 9920249032750366975), memoryAfter := (some 9920249032750366975), memWidthBytes := (some 4), memUnsigned := (some true), writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 6, stepIndex := 6, sequenceIndex := 0, pc := 24, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 0, archRdBefore := 0, archImm := 0, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 0, rdBefore := 0, rdAfter := 0, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := false, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }]

def stage1RowBindings : List Stage1RowBindingView :=
  [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 327811, opcode := .lb, traceOpcode := (some .lb), traceVirtualOpcode := none, family := .narrowMemory, nextPc := 4, aluResult := 18446744073709551615, effectiveAddr := (some 12288), writesRd := true, rd := 1, rdAfter := 18446744073709551615, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 1392899, opcode := .lbu, traceOpcode := (some .lbu), traceVirtualOpcode := none, family := .narrowMemory, nextPc := 8, aluResult := 128, effectiveAddr := (some 12289), writesRd := true, rd := 2, rdAfter := 128, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 332163, opcode := .lh, traceOpcode := (some .lh), traceVirtualOpcode := none, family := .narrowMemory, nextPc := 12, aluResult := 18446744073709519103, effectiveAddr := (some 12288), writesRd := true, rd := 3, rdAfter := 18446744073709519103, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 12, fetchedWord := 2445827, opcode := .lhu, traceOpcode := (some .lhu), traceVirtualOpcode := none, family := .narrowMemory, nextPc := 16, aluResult := 32895, effectiveAddr := (some 12290), writesRd := true, rd := 4, rdAfter := 32895, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 4, stepIndex := 4, sequenceIndex := 0, fetchPc := 16, fetchedWord := 336515, opcode := .lw, traceOpcode := (some .lw), traceVirtualOpcode := none, family := .narrowMemory, nextPc := 20, aluResult := 18446744071570424063, effectiveAddr := (some 12288), writesRd := true, rd := 5, rdAfter := 18446744071570424063, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 5, stepIndex := 5, sequenceIndex := 0, fetchPc := 20, fetchedWord := 4547331, opcode := .lwu, traceOpcode := (some .lwu), traceVirtualOpcode := none, family := .narrowMemory, nextPc := 24, aluResult := 2309737967, effectiveAddr := (some 12292), writesRd := true, rd := 6, rdAfter := 2309737967, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 6, stepIndex := 6, sequenceIndex := 0, fetchPc := 24, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 28, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }]

def stage1 : Stage1ProofBundleView :=
  {
    semInputs := stage1SemInputs
    , rowBindings := stage1RowBindings
    , bytecodeDigest := (bytes [124, 99, 215, 21, 29, 54, 200, 171, 45, 115, 8, 131, 187, 233, 212, 44, 99, 53, 196, 19, 41, 172, 118, 110, 55, 23, 76, 174, 231, 1, 53, 4])
    , aluDigest := (bytes [231, 200, 96, 201, 129, 253, 171, 204, 107, 183, 38, 119, 48, 230, 141, 240, 73, 112, 48, 57, 55, 29, 139, 4, 128, 170, 98, 245, 96, 251, 35, 20])
    , branchDigest := (bytes [68, 192, 206, 101, 240, 142, 85, 68, 60, 183, 132, 78, 112, 116, 245, 238, 108, 176, 41, 24, 91, 30, 193, 152, 240, 193, 152, 12, 111, 2, 118, 170])
    , semantics := { semInputsDigest := (bytes [210, 60, 151, 53, 95, 108, 103, 225, 31, 8, 131, 60, 182, 108, 38, 179, 122, 93, 227, 73, 149, 187, 127, 84, 3, 80, 72, 161, 230, 130, 233, 70]), rowBindingsDigest := (bytes [250, 101, 108, 230, 156, 180, 246, 26, 125, 161, 39, 58, 176, 246, 83, 103, 87, 50, 225, 187, 189, 190, 189, 5, 42, 9, 152, 23, 53, 43, 59, 177]), sequenceCount := 7, helperRowCount := 0, digest := (bytes [74, 154, 72, 213, 108, 221, 218, 122, 147, 78, 0, 53, 195, 236, 115, 127, 116, 228, 133, 35, 47, 217, 46, 15, 149, 87, 2, 251, 218, 108, 15, 113]) }
    , addressCorrectnessDigest := (bytes [174, 239, 74, 211, 11, 170, 24, 110, 163, 169, 67, 169, 13, 4, 19, 213, 184, 234, 206, 173, 107, 156, 20, 51, 117, 101, 172, 232, 18, 76, 193, 186])
    , linkageDigest := (bytes [78, 142, 16, 75, 188, 152, 57, 112, 22, 97, 191, 112, 110, 78, 244, 76, 176, 28, 157, 81, 225, 195, 16, 223, 153, 81, 193, 213, 52, 198, 115, 170])
    , selectedOpening := { claim := { rowsFamilyDigest := (bytes [250, 101, 108, 230, 156, 180, 246, 26, 125, 161, 39, 58, 176, 246, 83, 103, 87, 50, 225, 187, 189, 190, 189, 5, 42, 9, 152, 23, 53, 43, 59, 177]), rowCount := 7, effectRowCount := 7, commitRowCount := 7, realRowCount := 7, preservesX0Count := 1, firstTraceIndex := 0, effectTraceIndex := 0, commitTraceIndex := 0, lastTraceIndex := 6, mix := 6021918011723055633, points := { first := { id := { object := { familyTag := 1, commitmentDigest := (bytes [250, 101, 108, 230, 156, 180, 246, 26, 125, 161, 39, 58, 176, 246, 83, 103, 87, 50, 225, 187, 189, 190, 189, 5, 42, 9, 152, 23, 53, 43, 59, 177]), layoutVersion := 1, digest := (bytes [195, 26, 93, 237, 223, 48, 230, 54, 23, 246, 96, 59, 189, 104, 219, 26, 103, 110, 205, 63, 108, 135, 0, 40, 83, 86, 77, 227, 206, 205, 171, 151]) }, logicalIndex := 0, digest := (bytes [224, 36, 168, 255, 254, 39, 154, 233, 171, 42, 149, 226, 37, 174, 52, 16, 69, 51, 88, 39, 245, 88, 146, 58, 32, 126, 102, 54, 199, 143, 160, 47]) }, valueDigest := (bytes [190, 74, 230, 185, 112, 107, 253, 145, 135, 75, 28, 45, 215, 39, 28, 91, 231, 112, 6, 59, 110, 35, 155, 56, 112, 61, 76, 199, 13, 188, 47, 25]), digest := (bytes [70, 58, 89, 109, 180, 199, 150, 8, 249, 225, 216, 112, 27, 29, 182, 63, 103, 62, 136, 157, 50, 216, 90, 241, 197, 11, 104, 108, 114, 85, 206, 207]) }, effect := { id := { object := { familyTag := 1, commitmentDigest := (bytes [250, 101, 108, 230, 156, 180, 246, 26, 125, 161, 39, 58, 176, 246, 83, 103, 87, 50, 225, 187, 189, 190, 189, 5, 42, 9, 152, 23, 53, 43, 59, 177]), layoutVersion := 1, digest := (bytes [195, 26, 93, 237, 223, 48, 230, 54, 23, 246, 96, 59, 189, 104, 219, 26, 103, 110, 205, 63, 108, 135, 0, 40, 83, 86, 77, 227, 206, 205, 171, 151]) }, logicalIndex := 0, digest := (bytes [224, 36, 168, 255, 254, 39, 154, 233, 171, 42, 149, 226, 37, 174, 52, 16, 69, 51, 88, 39, 245, 88, 146, 58, 32, 126, 102, 54, 199, 143, 160, 47]) }, valueDigest := (bytes [190, 74, 230, 185, 112, 107, 253, 145, 135, 75, 28, 45, 215, 39, 28, 91, 231, 112, 6, 59, 110, 35, 155, 56, 112, 61, 76, 199, 13, 188, 47, 25]), digest := (bytes [70, 58, 89, 109, 180, 199, 150, 8, 249, 225, 216, 112, 27, 29, 182, 63, 103, 62, 136, 157, 50, 216, 90, 241, 197, 11, 104, 108, 114, 85, 206, 207]) }, commit := { id := { object := { familyTag := 1, commitmentDigest := (bytes [250, 101, 108, 230, 156, 180, 246, 26, 125, 161, 39, 58, 176, 246, 83, 103, 87, 50, 225, 187, 189, 190, 189, 5, 42, 9, 152, 23, 53, 43, 59, 177]), layoutVersion := 1, digest := (bytes [195, 26, 93, 237, 223, 48, 230, 54, 23, 246, 96, 59, 189, 104, 219, 26, 103, 110, 205, 63, 108, 135, 0, 40, 83, 86, 77, 227, 206, 205, 171, 151]) }, logicalIndex := 0, digest := (bytes [224, 36, 168, 255, 254, 39, 154, 233, 171, 42, 149, 226, 37, 174, 52, 16, 69, 51, 88, 39, 245, 88, 146, 58, 32, 126, 102, 54, 199, 143, 160, 47]) }, valueDigest := (bytes [190, 74, 230, 185, 112, 107, 253, 145, 135, 75, 28, 45, 215, 39, 28, 91, 231, 112, 6, 59, 110, 35, 155, 56, 112, 61, 76, 199, 13, 188, 47, 25]), digest := (bytes [70, 58, 89, 109, 180, 199, 150, 8, 249, 225, 216, 112, 27, 29, 182, 63, 103, 62, 136, 157, 50, 216, 90, 241, 197, 11, 104, 108, 114, 85, 206, 207]) }, last := { id := { object := { familyTag := 1, commitmentDigest := (bytes [250, 101, 108, 230, 156, 180, 246, 26, 125, 161, 39, 58, 176, 246, 83, 103, 87, 50, 225, 187, 189, 190, 189, 5, 42, 9, 152, 23, 53, 43, 59, 177]), layoutVersion := 1, digest := (bytes [195, 26, 93, 237, 223, 48, 230, 54, 23, 246, 96, 59, 189, 104, 219, 26, 103, 110, 205, 63, 108, 135, 0, 40, 83, 86, 77, 227, 206, 205, 171, 151]) }, logicalIndex := 6, digest := (bytes [91, 232, 46, 117, 62, 75, 168, 167, 26, 141, 118, 35, 144, 151, 161, 79, 173, 6, 237, 222, 95, 216, 89, 227, 71, 165, 185, 217, 27, 32, 121, 69]) }, valueDigest := (bytes [144, 146, 44, 41, 133, 23, 223, 236, 99, 134, 115, 57, 158, 12, 98, 154, 145, 46, 153, 64, 27, 39, 123, 216, 84, 198, 167, 47, 23, 105, 12, 146]), digest := (bytes [115, 108, 51, 40, 93, 160, 121, 169, 159, 54, 0, 163, 99, 49, 140, 134, 128, 196, 106, 158, 70, 92, 30, 245, 253, 33, 24, 24, 100, 59, 171, 108]) } }, digest := (bytes [124, 2, 250, 31, 14, 240, 76, 188, 189, 178, 132, 91, 141, 149, 92, 216, 145, 34, 185, 220, 171, 9, 84, 38, 208, 98, 133, 84, 148, 223, 226, 48]) }, packaged := { statementDigest := (bytes [167, 243, 49, 186, 107, 153, 52, 3, 159, 151, 218, 62, 144, 10, 217, 23, 246, 235, 101, 2, 247, 10, 92, 25, 185, 33, 23, 65, 108, 169, 249, 141]), proofDigest := (bytes [103, 192, 49, 128, 14, 100, 197, 22, 59, 74, 253, 206, 173, 223, 198, 167, 122, 22, 106, 76, 198, 128, 235, 106, 38, 176, 22, 242, 145, 54, 13, 150]) }, digest := (bytes [242, 173, 96, 214, 78, 222, 28, 165, 129, 156, 193, 86, 68, 216, 118, 57, 97, 73, 225, 233, 152, 96, 17, 76, 85, 117, 101, 168, 162, 156, 168, 237]) }
    , digest := (bytes [247, 122, 143, 193, 194, 191, 86, 207, 178, 109, 218, 161, 201, 197, 144, 72, 133, 9, 158, 141, 106, 17, 218, 234, 234, 48, 90, 9, 234, 245, 107, 68])
  }

def stage2RegisterReads : List RegisterReadEventView :=
  [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 10, value := 12288 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 10, value := 12288 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 10, value := 12288 }, { traceIndex := 3, stepIndex := 3, role := .rs1, reg := 10, value := 12288 }, { traceIndex := 4, stepIndex := 4, role := .rs1, reg := 10, value := 12288 }, { traceIndex := 5, stepIndex := 5, role := .rs1, reg := 10, value := 12288 }]

def stage2RegisterWrites : List RegisterWriteEventView :=
  [{ traceIndex := 0, stepIndex := 0, reg := 1, previous := 0, next := 18446744073709551615 }, { traceIndex := 1, stepIndex := 1, reg := 2, previous := 0, next := 128 }, { traceIndex := 2, stepIndex := 2, reg := 3, previous := 0, next := 18446744073709519103 }, { traceIndex := 3, stepIndex := 3, reg := 4, previous := 0, next := 32895 }, { traceIndex := 4, stepIndex := 4, reg := 5, previous := 0, next := 18446744071570424063 }, { traceIndex := 5, stepIndex := 5, reg := 6, previous := 0, next := 2309737967 }]

def stage2RamEvents : List RamEventView :=
  [{ traceIndex := 0, stepIndex := 0, kind := .read, addr := 12288, previous := 9920249032750366975, next := 9920249032750366975 }, { traceIndex := 1, stepIndex := 1, kind := .read, addr := 12288, previous := 9920249032750366975, next := 9920249032750366975 }, { traceIndex := 2, stepIndex := 2, kind := .read, addr := 12288, previous := 9920249032750366975, next := 9920249032750366975 }, { traceIndex := 3, stepIndex := 3, kind := .read, addr := 12288, previous := 9920249032750366975, next := 9920249032750366975 }, { traceIndex := 4, stepIndex := 4, kind := .read, addr := 12288, previous := 9920249032750366975, next := 9920249032750366975 }, { traceIndex := 5, stepIndex := 5, kind := .read, addr := 12288, previous := 9920249032750366975, next := 9920249032750366975 }]

def stage2TwistLinks : List TwistLinkEventView :=
  [{ traceIndex := 0, stepIndex := 0, family := .narrowMemory, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := (some 9920249032750366975), routedMemoryAfter := (some 9920249032750366975) }, { traceIndex := 1, stepIndex := 1, family := .narrowMemory, routedWriteValue := (some 128), routedMemoryBefore := (some 9920249032750366975), routedMemoryAfter := (some 9920249032750366975) }, { traceIndex := 2, stepIndex := 2, family := .narrowMemory, routedWriteValue := (some 18446744073709519103), routedMemoryBefore := (some 9920249032750366975), routedMemoryAfter := (some 9920249032750366975) }, { traceIndex := 3, stepIndex := 3, family := .narrowMemory, routedWriteValue := (some 32895), routedMemoryBefore := (some 9920249032750366975), routedMemoryAfter := (some 9920249032750366975) }, { traceIndex := 4, stepIndex := 4, family := .narrowMemory, routedWriteValue := (some 18446744071570424063), routedMemoryBefore := (some 9920249032750366975), routedMemoryAfter := (some 9920249032750366975) }, { traceIndex := 5, stepIndex := 5, family := .narrowMemory, routedWriteValue := (some 2309737967), routedMemoryBefore := (some 9920249032750366975), routedMemoryAfter := (some 9920249032750366975) }, { traceIndex := 6, stepIndex := 6, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]

def stage2 : Stage2ProofBundleView :=
  {
    registerReads := stage2RegisterReads
    , registerWrites := stage2RegisterWrites
    , ramEvents := stage2RamEvents
    , registerDigest := (bytes [194, 228, 137, 253, 223, 81, 106, 75, 248, 16, 191, 238, 5, 166, 186, 207, 206, 200, 113, 137, 254, 55, 0, 176, 3, 9, 111, 64, 1, 121, 185, 71])
    , ramDigest := (bytes [28, 123, 135, 36, 107, 191, 170, 54, 113, 196, 113, 76, 157, 175, 58, 48, 53, 180, 79, 138, 188, 94, 7, 127, 204, 197, 135, 233, 145, 126, 75, 65])
    , temporal := { twistLinks := stage2TwistLinks, registerTimelineDigest := (bytes [155, 172, 126, 149, 75, 58, 33, 18, 250, 91, 119, 96, 31, 83, 159, 237, 111, 55, 87, 11, 23, 143, 75, 52, 233, 181, 91, 44, 66, 105, 156, 114]), ramTimelineDigest := (bytes [131, 228, 217, 68, 199, 50, 27, 63, 243, 215, 16, 32, 158, 106, 127, 26, 210, 51, 227, 76, 85, 187, 138, 144, 78, 0, 206, 175, 194, 175, 27, 199]), twistLinksDigest := (bytes [63, 23, 169, 10, 200, 18, 118, 94, 173, 171, 163, 157, 243, 113, 19, 241, 166, 124, 220, 188, 118, 132, 226, 79, 166, 190, 208, 168, 172, 87, 46, 227]), digest := (bytes [146, 143, 86, 88, 53, 249, 16, 218, 47, 25, 144, 130, 231, 121, 210, 15, 203, 112, 97, 68, 235, 120, 203, 255, 255, 59, 194, 199, 162, 104, 156, 50]) }
    , semantics := { registerReadsFamilyDigest := (bytes [74, 53, 112, 91, 77, 31, 247, 74, 211, 232, 98, 37, 58, 143, 249, 90, 111, 50, 110, 219, 160, 108, 203, 195, 73, 72, 160, 223, 7, 50, 67, 150]), registerWritesFamilyDigest := (bytes [171, 51, 100, 25, 53, 28, 165, 143, 40, 219, 102, 147, 183, 84, 105, 234, 1, 68, 137, 179, 177, 61, 228, 154, 81, 82, 63, 182, 220, 1, 73, 51]), ramEventsFamilyDigest := (bytes [157, 190, 186, 16, 59, 138, 84, 241, 65, 219, 4, 198, 97, 17, 51, 167, 90, 168, 11, 163, 137, 22, 93, 42, 240, 164, 81, 120, 110, 6, 208, 116]), twistLinksFamilyDigest := (bytes [199, 232, 219, 229, 79, 187, 200, 210, 216, 81, 215, 99, 209, 238, 205, 53, 203, 22, 52, 241, 75, 247, 201, 223, 112, 151, 50, 42, 110, 167, 94, 28]), rowCount := 7, registerEventCount := 12, ramEventCount := 6, digest := (bytes [83, 192, 90, 234, 58, 169, 14, 192, 26, 112, 127, 126, 4, 121, 154, 146, 118, 1, 221, 180, 209, 50, 248, 51, 75, 199, 123, 125, 53, 72, 3, 118]) }
    , linkageDigest := (bytes [65, 58, 185, 159, 1, 63, 130, 48, 183, 151, 240, 86, 9, 225, 150, 228, 113, 212, 134, 244, 135, 1, 120, 164, 211, 39, 45, 109, 55, 78, 84, 149])
    , selectedOpening := { claim := { registerReadsFamilyDigest := (bytes [74, 53, 112, 91, 77, 31, 247, 74, 211, 232, 98, 37, 58, 143, 249, 90, 111, 50, 110, 219, 160, 108, 203, 195, 73, 72, 160, 223, 7, 50, 67, 150]), registerWritesFamilyDigest := (bytes [171, 51, 100, 25, 53, 28, 165, 143, 40, 219, 102, 147, 183, 84, 105, 234, 1, 68, 137, 179, 177, 61, 228, 154, 81, 82, 63, 182, 220, 1, 73, 51]), ramEventsFamilyDigest := (bytes [157, 190, 186, 16, 59, 138, 84, 241, 65, 219, 4, 198, 97, 17, 51, 167, 90, 168, 11, 163, 137, 22, 93, 42, 240, 164, 81, 120, 110, 6, 208, 116]), twistLinksFamilyDigest := (bytes [199, 232, 219, 229, 79, 187, 200, 210, 216, 81, 215, 99, 209, 238, 205, 53, 203, 22, 52, 241, 75, 247, 201, 223, 112, 151, 50, 42, 110, 167, 94, 28]), registerReadCount := 6, registerWriteCount := 6, ramEventCount := 6, twistLinkCount := 7, ramReadCount := 6, ramWriteCount := 0, regMix := 12166816141915752516, ramMix := 4582133116042247748, points := { firstRead := (some { id := { object := { familyTag := 2, commitmentDigest := (bytes [74, 53, 112, 91, 77, 31, 247, 74, 211, 232, 98, 37, 58, 143, 249, 90, 111, 50, 110, 219, 160, 108, 203, 195, 73, 72, 160, 223, 7, 50, 67, 150]), layoutVersion := 1, digest := (bytes [123, 115, 245, 242, 216, 251, 117, 187, 176, 251, 228, 178, 205, 106, 252, 218, 164, 170, 42, 224, 110, 238, 194, 236, 151, 75, 247, 122, 66, 139, 231, 231]) }, logicalIndex := 0, digest := (bytes [159, 124, 18, 15, 219, 89, 56, 18, 181, 174, 64, 240, 44, 106, 72, 69, 218, 236, 64, 175, 217, 139, 99, 68, 252, 138, 170, 191, 159, 161, 183, 99]) }, valueDigest := (bytes [229, 37, 6, 101, 184, 189, 75, 246, 35, 14, 221, 247, 43, 239, 122, 101, 206, 182, 15, 183, 81, 179, 167, 205, 2, 244, 2, 255, 236, 126, 24, 70]), digest := (bytes [158, 184, 156, 115, 72, 57, 135, 118, 19, 169, 43, 153, 157, 180, 248, 192, 76, 17, 239, 51, 128, 225, 4, 119, 253, 12, 245, 21, 185, 17, 29, 107]) }), lastRead := (some { id := { object := { familyTag := 2, commitmentDigest := (bytes [74, 53, 112, 91, 77, 31, 247, 74, 211, 232, 98, 37, 58, 143, 249, 90, 111, 50, 110, 219, 160, 108, 203, 195, 73, 72, 160, 223, 7, 50, 67, 150]), layoutVersion := 1, digest := (bytes [123, 115, 245, 242, 216, 251, 117, 187, 176, 251, 228, 178, 205, 106, 252, 218, 164, 170, 42, 224, 110, 238, 194, 236, 151, 75, 247, 122, 66, 139, 231, 231]) }, logicalIndex := 5, digest := (bytes [133, 17, 247, 206, 210, 39, 62, 221, 78, 18, 79, 190, 144, 225, 242, 70, 81, 178, 31, 63, 50, 88, 131, 204, 122, 66, 144, 108, 71, 135, 40, 131]) }, valueDigest := (bytes [187, 71, 87, 250, 236, 86, 93, 182, 56, 245, 247, 23, 244, 157, 61, 138, 179, 252, 194, 187, 47, 138, 24, 227, 141, 229, 222, 253, 113, 59, 212, 206]), digest := (bytes [81, 198, 72, 14, 26, 142, 56, 183, 137, 14, 54, 121, 209, 225, 89, 68, 143, 239, 86, 168, 95, 175, 24, 237, 115, 195, 240, 37, 201, 232, 150, 223]) }), firstWrite := (some { id := { object := { familyTag := 3, commitmentDigest := (bytes [171, 51, 100, 25, 53, 28, 165, 143, 40, 219, 102, 147, 183, 84, 105, 234, 1, 68, 137, 179, 177, 61, 228, 154, 81, 82, 63, 182, 220, 1, 73, 51]), layoutVersion := 1, digest := (bytes [137, 41, 15, 78, 206, 1, 189, 128, 92, 181, 55, 234, 196, 53, 120, 13, 120, 64, 115, 68, 175, 126, 242, 146, 197, 155, 88, 16, 253, 113, 48, 87]) }, logicalIndex := 0, digest := (bytes [38, 9, 62, 212, 0, 46, 157, 36, 216, 102, 55, 51, 249, 199, 4, 52, 210, 64, 92, 87, 27, 161, 98, 172, 158, 177, 178, 65, 65, 146, 240, 180]) }, valueDigest := (bytes [73, 175, 249, 106, 163, 84, 49, 4, 122, 98, 125, 56, 99, 1, 90, 255, 89, 80, 68, 237, 88, 57, 187, 224, 2, 195, 250, 214, 36, 107, 236, 89]), digest := (bytes [153, 123, 189, 87, 188, 145, 212, 208, 179, 249, 130, 43, 63, 77, 202, 176, 164, 160, 55, 88, 170, 182, 98, 202, 170, 221, 20, 122, 77, 176, 252, 25]) }), lastWrite := (some { id := { object := { familyTag := 3, commitmentDigest := (bytes [171, 51, 100, 25, 53, 28, 165, 143, 40, 219, 102, 147, 183, 84, 105, 234, 1, 68, 137, 179, 177, 61, 228, 154, 81, 82, 63, 182, 220, 1, 73, 51]), layoutVersion := 1, digest := (bytes [137, 41, 15, 78, 206, 1, 189, 128, 92, 181, 55, 234, 196, 53, 120, 13, 120, 64, 115, 68, 175, 126, 242, 146, 197, 155, 88, 16, 253, 113, 48, 87]) }, logicalIndex := 5, digest := (bytes [248, 216, 214, 50, 191, 181, 55, 49, 248, 72, 125, 97, 195, 147, 122, 111, 177, 51, 147, 34, 129, 124, 16, 20, 193, 184, 255, 50, 213, 73, 73, 252]) }, valueDigest := (bytes [29, 222, 22, 21, 246, 71, 180, 205, 216, 64, 22, 46, 110, 231, 127, 39, 216, 165, 109, 31, 64, 132, 55, 63, 114, 23, 231, 181, 46, 185, 222, 89]), digest := (bytes [43, 213, 148, 214, 113, 215, 159, 184, 213, 149, 50, 233, 23, 151, 117, 1, 220, 219, 141, 50, 187, 252, 85, 236, 29, 135, 246, 95, 189, 32, 50, 15]) }), firstRam := (some { id := { object := { familyTag := 4, commitmentDigest := (bytes [157, 190, 186, 16, 59, 138, 84, 241, 65, 219, 4, 198, 97, 17, 51, 167, 90, 168, 11, 163, 137, 22, 93, 42, 240, 164, 81, 120, 110, 6, 208, 116]), layoutVersion := 1, digest := (bytes [182, 39, 189, 99, 3, 166, 180, 170, 109, 25, 47, 96, 198, 158, 85, 135, 152, 214, 229, 184, 26, 110, 39, 135, 34, 223, 43, 53, 200, 133, 100, 125]) }, logicalIndex := 0, digest := (bytes [38, 205, 242, 83, 67, 188, 16, 208, 4, 212, 47, 199, 18, 124, 71, 120, 203, 102, 178, 179, 247, 233, 97, 152, 201, 166, 249, 33, 202, 144, 122, 58]) }, valueDigest := (bytes [41, 31, 79, 84, 210, 60, 18, 33, 0, 120, 180, 252, 253, 195, 24, 241, 33, 198, 10, 177, 195, 205, 161, 118, 251, 83, 77, 154, 252, 11, 132, 143]), digest := (bytes [33, 157, 87, 244, 56, 214, 56, 188, 53, 201, 146, 200, 121, 44, 205, 42, 36, 121, 43, 243, 217, 98, 129, 123, 60, 255, 56, 42, 203, 187, 208, 212]) }), lastRam := (some { id := { object := { familyTag := 4, commitmentDigest := (bytes [157, 190, 186, 16, 59, 138, 84, 241, 65, 219, 4, 198, 97, 17, 51, 167, 90, 168, 11, 163, 137, 22, 93, 42, 240, 164, 81, 120, 110, 6, 208, 116]), layoutVersion := 1, digest := (bytes [182, 39, 189, 99, 3, 166, 180, 170, 109, 25, 47, 96, 198, 158, 85, 135, 152, 214, 229, 184, 26, 110, 39, 135, 34, 223, 43, 53, 200, 133, 100, 125]) }, logicalIndex := 5, digest := (bytes [87, 17, 247, 147, 232, 187, 239, 129, 241, 246, 42, 65, 210, 171, 25, 214, 175, 75, 108, 186, 141, 187, 126, 189, 44, 152, 133, 110, 48, 75, 168, 187]) }, valueDigest := (bytes [211, 129, 73, 125, 27, 206, 195, 25, 164, 47, 176, 66, 70, 50, 60, 62, 239, 63, 78, 234, 192, 30, 226, 223, 76, 113, 78, 76, 15, 229, 57, 119]), digest := (bytes [80, 91, 68, 68, 103, 64, 81, 205, 182, 28, 233, 10, 26, 165, 60, 81, 197, 138, 219, 236, 113, 33, 243, 46, 40, 121, 200, 21, 175, 183, 42, 76]) }), firstTwist := (some { id := { object := { familyTag := 5, commitmentDigest := (bytes [199, 232, 219, 229, 79, 187, 200, 210, 216, 81, 215, 99, 209, 238, 205, 53, 203, 22, 52, 241, 75, 247, 201, 223, 112, 151, 50, 42, 110, 167, 94, 28]), layoutVersion := 1, digest := (bytes [13, 143, 103, 208, 199, 35, 58, 163, 48, 3, 37, 231, 218, 226, 206, 82, 39, 172, 248, 35, 242, 95, 146, 216, 62, 136, 83, 13, 44, 247, 98, 34]) }, logicalIndex := 0, digest := (bytes [82, 6, 8, 200, 4, 2, 134, 16, 109, 20, 184, 145, 170, 106, 36, 112, 241, 16, 192, 36, 172, 15, 159, 69, 211, 9, 39, 254, 180, 155, 119, 128]) }, valueDigest := (bytes [40, 88, 65, 187, 147, 34, 8, 118, 140, 168, 111, 251, 203, 44, 115, 209, 215, 197, 25, 67, 138, 168, 87, 101, 83, 49, 83, 244, 192, 78, 235, 32]), digest := (bytes [171, 242, 17, 247, 81, 36, 37, 33, 218, 198, 124, 139, 30, 3, 231, 233, 134, 15, 73, 244, 42, 170, 30, 174, 150, 48, 68, 119, 65, 129, 42, 161]) }), lastTwist := (some { id := { object := { familyTag := 5, commitmentDigest := (bytes [199, 232, 219, 229, 79, 187, 200, 210, 216, 81, 215, 99, 209, 238, 205, 53, 203, 22, 52, 241, 75, 247, 201, 223, 112, 151, 50, 42, 110, 167, 94, 28]), layoutVersion := 1, digest := (bytes [13, 143, 103, 208, 199, 35, 58, 163, 48, 3, 37, 231, 218, 226, 206, 82, 39, 172, 248, 35, 242, 95, 146, 216, 62, 136, 83, 13, 44, 247, 98, 34]) }, logicalIndex := 6, digest := (bytes [95, 192, 175, 17, 76, 48, 238, 98, 188, 67, 107, 236, 243, 255, 40, 95, 135, 152, 120, 221, 80, 173, 48, 31, 179, 44, 201, 132, 45, 219, 150, 112]) }, valueDigest := (bytes [177, 90, 46, 16, 105, 217, 158, 221, 200, 159, 226, 176, 242, 66, 217, 14, 215, 150, 37, 246, 212, 108, 237, 104, 31, 103, 108, 107, 11, 82, 147, 173]), digest := (bytes [17, 247, 78, 244, 75, 44, 229, 228, 127, 235, 180, 122, 233, 144, 147, 11, 77, 180, 43, 137, 23, 181, 95, 183, 232, 163, 216, 111, 193, 127, 108, 89]) }) }, digest := (bytes [90, 56, 99, 246, 25, 128, 85, 186, 205, 213, 47, 140, 73, 25, 3, 163, 98, 185, 204, 52, 240, 106, 20, 233, 252, 40, 203, 98, 195, 68, 62, 226]) }, packaged := { statementDigest := (bytes [187, 168, 61, 117, 39, 45, 144, 90, 190, 157, 76, 190, 118, 122, 8, 54, 141, 13, 219, 201, 208, 157, 41, 47, 194, 96, 0, 104, 175, 5, 152, 178]), proofDigest := (bytes [184, 93, 120, 142, 232, 253, 143, 84, 243, 12, 52, 160, 108, 4, 186, 95, 130, 220, 177, 126, 37, 201, 145, 230, 218, 153, 91, 129, 200, 8, 32, 16]) }, digest := (bytes [117, 100, 103, 165, 37, 29, 92, 151, 19, 172, 62, 235, 204, 183, 18, 246, 119, 143, 55, 182, 59, 131, 149, 169, 204, 165, 111, 196, 201, 14, 96, 167]) }
    , digest := (bytes [15, 17, 138, 202, 232, 224, 124, 49, 70, 3, 28, 91, 248, 216, 7, 144, 53, 160, 111, 86, 53, 218, 7, 5, 16, 243, 76, 25, 161, 211, 134, 162])
  }

def stage3Continuity : List ContinuityEventView :=
  [{ stepIndex := 0, pc := 0, nextPc := 4, successorPc := (some 4), finalStep := false, continuityHolds := true }, { stepIndex := 1, pc := 4, nextPc := 8, successorPc := (some 8), finalStep := false, continuityHolds := true }, { stepIndex := 2, pc := 8, nextPc := 12, successorPc := (some 12), finalStep := false, continuityHolds := true }, { stepIndex := 3, pc := 12, nextPc := 16, successorPc := (some 16), finalStep := false, continuityHolds := true }, { stepIndex := 4, pc := 16, nextPc := 20, successorPc := (some 20), finalStep := false, continuityHolds := true }, { stepIndex := 5, pc := 20, nextPc := 24, successorPc := (some 24), finalStep := false, continuityHolds := true }, { stepIndex := 6, pc := 24, nextPc := 28, successorPc := none, finalStep := true, continuityHolds := true }]

def stage3 : Stage3ProofBundleView :=
  {
    continuity := stage3Continuity
    , halted := true
    , bridgeDigest := (bytes [86, 103, 197, 195, 175, 230, 234, 229, 138, 175, 224, 111, 20, 152, 207, 96, 171, 239, 105, 92, 224, 160, 7, 223, 44, 187, 231, 91, 40, 122, 54, 114])
    , semantics := { continuityDigest := (bytes [231, 127, 209, 33, 200, 198, 35, 28, 95, 20, 80, 177, 211, 177, 192, 24, 18, 155, 147, 233, 52, 13, 201, 10, 11, 228, 186, 38, 18, 206, 255, 74]), rootSemanticRowsDigest := (bytes [226, 75, 185, 10, 235, 220, 135, 146, 12, 179, 192, 149, 134, 192, 120, 69, 206, 76, 227, 251, 108, 250, 217, 1, 30, 128, 163, 106, 189, 44, 139, 242]), rowChunkRoutesDigest := (bytes [210, 211, 133, 148, 162, 150, 85, 66, 2, 24, 230, 163, 67, 64, 160, 246, 143, 119, 48, 189, 194, 114, 28, 76, 211, 182, 93, 15, 73, 83, 209, 85]), preparedStepBindingsDigest := (bytes [87, 71, 197, 222, 145, 126, 134, 239, 226, 74, 253, 106, 28, 144, 235, 131, 31, 120, 247, 233, 88, 225, 201, 44, 4, 49, 185, 67, 38, 174, 63, 242]), stage2TemporalDigest := (bytes [146, 143, 86, 88, 53, 249, 16, 218, 47, 25, 144, 130, 231, 121, 210, 15, 203, 112, 97, 68, 235, 120, 203, 255, 255, 59, 194, 199, 162, 104, 156, 50]), initialPc := 0, finalPc := 28, realRowCount := 7, firstRealStepIndex := 0, lastRealStepIndex := 6, digest := (bytes [71, 94, 30, 190, 57, 47, 196, 27, 202, 94, 77, 211, 45, 254, 46, 51, 134, 201, 240, 237, 218, 173, 22, 122, 161, 44, 236, 184, 223, 176, 163, 166]) }
    , linkageDigest := (bytes [116, 162, 190, 173, 129, 168, 200, 0, 6, 228, 118, 60, 249, 79, 246, 146, 166, 208, 177, 161, 195, 222, 158, 96, 79, 89, 124, 176, 18, 240, 177, 93])
    , selectedOpening := { claim := { continuityFamilyDigest := (bytes [94, 209, 204, 219, 207, 222, 139, 15, 162, 178, 200, 168, 102, 230, 108, 10, 222, 118, 76, 56, 76, 82, 63, 83, 183, 179, 71, 63, 14, 207, 130, 159]), continuityCount := 7, finalStepCount := 1, halted := true, allContinuityHold := true, continuityMix := 13816550690510729125, points := { firstContinuity := (some { id := { object := { familyTag := 6, commitmentDigest := (bytes [94, 209, 204, 219, 207, 222, 139, 15, 162, 178, 200, 168, 102, 230, 108, 10, 222, 118, 76, 56, 76, 82, 63, 83, 183, 179, 71, 63, 14, 207, 130, 159]), layoutVersion := 1, digest := (bytes [40, 174, 116, 139, 25, 243, 175, 145, 153, 240, 85, 170, 23, 150, 84, 150, 190, 215, 68, 209, 210, 6, 8, 236, 153, 87, 22, 207, 151, 168, 136, 52]) }, logicalIndex := 0, digest := (bytes [237, 15, 183, 29, 215, 126, 189, 58, 103, 246, 57, 89, 234, 208, 198, 46, 25, 0, 100, 80, 171, 37, 200, 69, 38, 250, 136, 86, 100, 176, 41, 56]) }, valueDigest := (bytes [7, 131, 85, 21, 57, 109, 53, 31, 137, 53, 98, 18, 170, 36, 28, 200, 149, 213, 171, 159, 119, 200, 36, 230, 30, 35, 30, 11, 252, 126, 240, 63]), digest := (bytes [9, 171, 35, 175, 184, 12, 28, 139, 81, 227, 110, 197, 202, 210, 109, 24, 113, 26, 226, 78, 132, 222, 80, 0, 45, 255, 1, 70, 236, 206, 54, 109]) }), lastContinuity := (some { id := { object := { familyTag := 6, commitmentDigest := (bytes [94, 209, 204, 219, 207, 222, 139, 15, 162, 178, 200, 168, 102, 230, 108, 10, 222, 118, 76, 56, 76, 82, 63, 83, 183, 179, 71, 63, 14, 207, 130, 159]), layoutVersion := 1, digest := (bytes [40, 174, 116, 139, 25, 243, 175, 145, 153, 240, 85, 170, 23, 150, 84, 150, 190, 215, 68, 209, 210, 6, 8, 236, 153, 87, 22, 207, 151, 168, 136, 52]) }, logicalIndex := 6, digest := (bytes [198, 85, 20, 231, 58, 95, 46, 235, 220, 204, 131, 110, 190, 111, 124, 237, 164, 76, 10, 35, 171, 200, 143, 186, 40, 161, 187, 120, 104, 155, 230, 178]) }, valueDigest := (bytes [109, 97, 69, 254, 146, 244, 236, 80, 140, 232, 150, 9, 211, 236, 70, 18, 119, 149, 140, 71, 61, 248, 99, 170, 171, 200, 158, 31, 232, 41, 83, 47]), digest := (bytes [8, 178, 50, 145, 108, 111, 144, 45, 214, 5, 171, 67, 250, 137, 125, 232, 110, 35, 132, 153, 104, 37, 158, 53, 228, 206, 133, 17, 180, 213, 227, 54]) }) }, digest := (bytes [106, 92, 39, 77, 255, 19, 74, 132, 69, 227, 19, 163, 191, 69, 216, 48, 20, 96, 69, 253, 142, 43, 214, 55, 22, 57, 39, 129, 119, 224, 207, 68]) }, packaged := { statementDigest := (bytes [180, 97, 118, 154, 5, 161, 173, 9, 13, 2, 226, 140, 173, 213, 199, 114, 80, 205, 8, 150, 57, 88, 119, 77, 146, 202, 109, 239, 151, 101, 117, 8]), proofDigest := (bytes [187, 164, 111, 203, 229, 157, 255, 214, 109, 60, 53, 92, 110, 138, 58, 18, 140, 162, 22, 137, 150, 2, 216, 94, 168, 145, 126, 189, 81, 71, 203, 172]) }, digest := (bytes [21, 245, 157, 115, 126, 105, 209, 146, 6, 189, 145, 233, 254, 142, 227, 64, 172, 198, 139, 5, 185, 117, 230, 218, 60, 6, 163, 248, 78, 42, 113, 139]) }
    , digest := (bytes [219, 43, 189, 101, 135, 223, 185, 84, 134, 209, 243, 216, 185, 118, 71, 141, 227, 123, 22, 146, 165, 155, 98, 249, 214, 78, 61, 182, 109, 197, 155, 113])
  }

def rootExecutionExecutionRows : List ExpandedRowView :=
  [{
  traceIndex := 0
  , stepIndex := 0
  , sequenceIndex := 0
  , pc := 0
  , nextPc := 4
  , word := 327811
  , opcode := .lb
  , traceOpcode := (some .lb)
  , traceVirtualOpcode := none
  , family := .narrowMemory
  , rs1 := 10
  , rs1Value := 12288
  , rs2 := 0
  , rs2Value := 0
  , rd := 1
  , rdBefore := 0
  , rdAfter := 18446744073709551615
  , imm := 0
  , aluResult := 18446744073709551615
  , effectiveAddr := (some 12288)
  , memoryBefore := (some 9920249032750366975)
  , memoryAfter := (some 9920249032750366975)
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
  , word := 1392899
  , opcode := .lbu
  , traceOpcode := (some .lbu)
  , traceVirtualOpcode := none
  , family := .narrowMemory
  , rs1 := 10
  , rs1Value := 12288
  , rs2 := 0
  , rs2Value := 0
  , rd := 2
  , rdBefore := 0
  , rdAfter := 128
  , imm := 1
  , aluResult := 128
  , effectiveAddr := (some 12289)
  , memoryBefore := (some 9920249032750366975)
  , memoryAfter := (some 9920249032750366975)
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
  , word := 332163
  , opcode := .lh
  , traceOpcode := (some .lh)
  , traceVirtualOpcode := none
  , family := .narrowMemory
  , rs1 := 10
  , rs1Value := 12288
  , rs2 := 0
  , rs2Value := 0
  , rd := 3
  , rdBefore := 0
  , rdAfter := 18446744073709519103
  , imm := 0
  , aluResult := 18446744073709519103
  , effectiveAddr := (some 12288)
  , memoryBefore := (some 9920249032750366975)
  , memoryAfter := (some 9920249032750366975)
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
  , word := 2445827
  , opcode := .lhu
  , traceOpcode := (some .lhu)
  , traceVirtualOpcode := none
  , family := .narrowMemory
  , rs1 := 10
  , rs1Value := 12288
  , rs2 := 0
  , rs2Value := 0
  , rd := 4
  , rdBefore := 0
  , rdAfter := 32895
  , imm := 2
  , aluResult := 32895
  , effectiveAddr := (some 12290)
  , memoryBefore := (some 9920249032750366975)
  , memoryAfter := (some 9920249032750366975)
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
  , word := 336515
  , opcode := .lw
  , traceOpcode := (some .lw)
  , traceVirtualOpcode := none
  , family := .narrowMemory
  , rs1 := 10
  , rs1Value := 12288
  , rs2 := 0
  , rs2Value := 0
  , rd := 5
  , rdBefore := 0
  , rdAfter := 18446744071570424063
  , imm := 0
  , aluResult := 18446744071570424063
  , effectiveAddr := (some 12288)
  , memoryBefore := (some 9920249032750366975)
  , memoryAfter := (some 9920249032750366975)
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
  , word := 4547331
  , opcode := .lwu
  , traceOpcode := (some .lwu)
  , traceVirtualOpcode := none
  , family := .narrowMemory
  , rs1 := 10
  , rs1Value := 12288
  , rs2 := 0
  , rs2Value := 0
  , rd := 6
  , rdBefore := 0
  , rdAfter := 2309737967
  , imm := 4
  , aluResult := 2309737967
  , effectiveAddr := (some 12292)
  , memoryBefore := (some 9920249032750366975)
  , memoryAfter := (some 9920249032750366975)
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
  [{ traceIndex := 0, values := [1, 0, 0, 4, 0, 12288, 0, 0, 0, 4294967295, 4294967295, 0, 0, 4294967295, 4294967295, 4, 0, 0, 0, 12288, 0, 4294967295, 4294967295, 1, 10, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1], rowDigest := (bytes [129, 16, 11, 76, 253, 155, 142, 28, 89, 240, 19, 169, 171, 115, 101, 224, 73, 120, 86, 195, 27, 185, 106, 175, 64, 231, 190, 170, 187, 57, 144, 129]), digest := (bytes [22, 15, 48, 19, 12, 56, 48, 65, 147, 46, 70, 93, 99, 22, 242, 99, 133, 202, 72, 193, 133, 246, 250, 179, 76, 181, 245, 190, 93, 148, 8, 38]) }, { traceIndex := 1, values := [1, 4, 0, 8, 0, 12288, 0, 0, 0, 128, 0, 1, 0, 128, 0, 8, 0, 0, 0, 12289, 0, 128, 0, 2, 10, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1], rowDigest := (bytes [118, 241, 85, 52, 49, 34, 244, 58, 177, 77, 241, 26, 187, 99, 153, 232, 253, 232, 156, 193, 74, 0, 238, 197, 59, 40, 202, 150, 1, 189, 10, 218]), digest := (bytes [88, 255, 43, 47, 77, 137, 174, 163, 27, 232, 200, 155, 170, 241, 173, 173, 228, 118, 100, 27, 139, 219, 250, 211, 189, 242, 77, 16, 202, 239, 96, 213]) }, { traceIndex := 2, values := [1, 8, 0, 12, 0, 12288, 0, 0, 0, 4294934783, 4294967295, 0, 0, 4294934783, 4294967295, 12, 0, 0, 0, 12288, 0, 4294934783, 4294967295, 3, 10, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1], rowDigest := (bytes [217, 26, 183, 177, 8, 240, 17, 93, 113, 53, 64, 231, 72, 111, 32, 6, 194, 253, 46, 50, 165, 138, 12, 26, 208, 109, 54, 159, 204, 6, 42, 71]), digest := (bytes [145, 22, 223, 91, 177, 92, 204, 114, 69, 124, 79, 90, 77, 57, 19, 168, 123, 21, 249, 104, 90, 90, 55, 81, 149, 52, 217, 254, 139, 45, 140, 202]) }, { traceIndex := 3, values := [1, 12, 0, 16, 0, 12288, 0, 0, 0, 32895, 0, 2, 0, 32895, 0, 16, 0, 0, 0, 12290, 0, 32895, 0, 4, 10, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1], rowDigest := (bytes [89, 175, 55, 123, 106, 77, 80, 69, 22, 106, 206, 131, 222, 113, 179, 246, 122, 216, 188, 244, 216, 168, 32, 232, 170, 1, 133, 1, 44, 143, 104, 206]), digest := (bytes [147, 73, 250, 12, 171, 14, 83, 195, 57, 92, 93, 105, 153, 223, 147, 91, 161, 165, 21, 77, 193, 185, 138, 0, 127, 233, 188, 44, 183, 249, 96, 100]) }, { traceIndex := 4, values := [1, 16, 0, 20, 0, 12288, 0, 0, 0, 2155839743, 4294967295, 0, 0, 2155839743, 4294967295, 20, 0, 0, 0, 12288, 0, 2155839743, 4294967295, 5, 10, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1], rowDigest := (bytes [146, 107, 246, 114, 225, 206, 161, 39, 106, 133, 250, 2, 173, 145, 114, 194, 134, 143, 150, 85, 138, 5, 63, 119, 169, 178, 156, 187, 12, 20, 99, 235]), digest := (bytes [84, 250, 70, 198, 126, 228, 94, 227, 112, 158, 83, 146, 125, 231, 115, 156, 175, 148, 38, 135, 24, 10, 191, 16, 121, 169, 185, 184, 202, 217, 224, 146]) }, { traceIndex := 5, values := [1, 20, 0, 24, 0, 12288, 0, 0, 0, 2309737967, 0, 4, 0, 2309737967, 0, 24, 0, 0, 0, 12292, 0, 2309737967, 0, 6, 10, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1], rowDigest := (bytes [233, 172, 62, 172, 60, 220, 125, 47, 73, 118, 70, 20, 91, 10, 72, 149, 100, 66, 186, 233, 219, 120, 143, 177, 63, 23, 182, 145, 221, 171, 75, 122]), digest := (bytes [224, 149, 5, 210, 48, 219, 23, 114, 196, 243, 105, 57, 160, 196, 140, 240, 24, 201, 0, 219, 159, 153, 16, 112, 187, 8, 109, 168, 186, 217, 86, 95]) }, { traceIndex := 6, values := [1, 24, 0, 28, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 28, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [57, 167, 127, 66, 29, 28, 1, 62, 111, 174, 45, 82, 212, 157, 25, 154, 254, 72, 204, 85, 223, 7, 138, 44, 48, 11, 222, 83, 122, 239, 183, 120]), digest := (bytes [53, 245, 127, 106, 55, 210, 83, 63, 162, 14, 12, 212, 9, 132, 72, 57, 29, 12, 230, 88, 252, 251, 47, 87, 51, 251, 133, 205, 8, 86, 144, 88]) }]

def rootExecutionPreparedBindings : List PreparedStepBindingView :=
  [{ traceIndex := 0, rowDigest := (bytes [129, 16, 11, 76, 253, 155, 142, 28, 89, 240, 19, 169, 171, 115, 101, 224, 73, 120, 86, 195, 27, 185, 106, 175, 64, 231, 190, 170, 187, 57, 144, 129]), rowOpeningDigest := (bytes [50, 238, 42, 133, 107, 34, 54, 70, 10, 53, 197, 4, 106, 27, 119, 32, 0, 4, 236, 119, 96, 117, 207, 30, 209, 141, 155, 246, 5, 255, 61, 231]), digest := (bytes [21, 99, 9, 114, 231, 3, 32, 163, 10, 42, 219, 25, 150, 124, 100, 226, 74, 77, 162, 66, 151, 141, 204, 96, 55, 199, 145, 42, 86, 140, 96, 191]) }, { traceIndex := 1, rowDigest := (bytes [118, 241, 85, 52, 49, 34, 244, 58, 177, 77, 241, 26, 187, 99, 153, 232, 253, 232, 156, 193, 74, 0, 238, 197, 59, 40, 202, 150, 1, 189, 10, 218]), rowOpeningDigest := (bytes [65, 216, 39, 173, 34, 162, 110, 125, 56, 63, 43, 5, 194, 27, 171, 110, 73, 164, 56, 143, 189, 199, 164, 147, 126, 50, 225, 146, 132, 184, 132, 214]), digest := (bytes [242, 209, 238, 208, 107, 200, 193, 150, 27, 134, 218, 255, 95, 97, 148, 24, 120, 101, 254, 123, 95, 124, 0, 103, 94, 210, 234, 204, 49, 27, 23, 130]) }, { traceIndex := 2, rowDigest := (bytes [217, 26, 183, 177, 8, 240, 17, 93, 113, 53, 64, 231, 72, 111, 32, 6, 194, 253, 46, 50, 165, 138, 12, 26, 208, 109, 54, 159, 204, 6, 42, 71]), rowOpeningDigest := (bytes [59, 125, 48, 165, 145, 163, 181, 48, 39, 185, 243, 117, 79, 195, 220, 158, 173, 58, 125, 172, 131, 233, 162, 142, 69, 88, 138, 189, 204, 3, 40, 232]), digest := (bytes [235, 169, 74, 146, 2, 77, 188, 252, 90, 53, 152, 22, 238, 244, 202, 252, 175, 206, 111, 129, 27, 146, 185, 86, 179, 10, 14, 97, 53, 142, 230, 172]) }, { traceIndex := 3, rowDigest := (bytes [89, 175, 55, 123, 106, 77, 80, 69, 22, 106, 206, 131, 222, 113, 179, 246, 122, 216, 188, 244, 216, 168, 32, 232, 170, 1, 133, 1, 44, 143, 104, 206]), rowOpeningDigest := (bytes [72, 222, 79, 90, 77, 47, 81, 28, 125, 37, 30, 208, 84, 119, 76, 32, 220, 22, 139, 6, 211, 35, 197, 173, 130, 146, 199, 251, 168, 9, 117, 49]), digest := (bytes [238, 161, 160, 64, 117, 74, 0, 214, 252, 23, 112, 248, 71, 53, 200, 108, 220, 83, 236, 189, 132, 21, 130, 226, 103, 241, 82, 112, 234, 106, 218, 132]) }, { traceIndex := 4, rowDigest := (bytes [146, 107, 246, 114, 225, 206, 161, 39, 106, 133, 250, 2, 173, 145, 114, 194, 134, 143, 150, 85, 138, 5, 63, 119, 169, 178, 156, 187, 12, 20, 99, 235]), rowOpeningDigest := (bytes [25, 169, 50, 74, 116, 167, 11, 225, 103, 14, 225, 152, 168, 47, 151, 134, 49, 190, 33, 231, 154, 153, 109, 251, 209, 228, 12, 87, 212, 221, 109, 249]), digest := (bytes [17, 180, 59, 178, 230, 103, 43, 25, 169, 72, 223, 71, 222, 210, 82, 75, 65, 193, 6, 54, 152, 199, 23, 102, 190, 223, 192, 106, 123, 133, 92, 5]) }, { traceIndex := 5, rowDigest := (bytes [233, 172, 62, 172, 60, 220, 125, 47, 73, 118, 70, 20, 91, 10, 72, 149, 100, 66, 186, 233, 219, 120, 143, 177, 63, 23, 182, 145, 221, 171, 75, 122]), rowOpeningDigest := (bytes [254, 251, 219, 175, 114, 174, 93, 63, 242, 81, 3, 194, 40, 100, 92, 71, 184, 9, 33, 25, 146, 247, 216, 78, 6, 111, 245, 201, 140, 128, 133, 120]), digest := (bytes [66, 70, 43, 21, 55, 183, 194, 62, 165, 13, 206, 88, 22, 170, 245, 239, 126, 241, 99, 250, 145, 238, 111, 229, 253, 46, 26, 85, 118, 214, 162, 218]) }, { traceIndex := 6, rowDigest := (bytes [57, 167, 127, 66, 29, 28, 1, 62, 111, 174, 45, 82, 212, 157, 25, 154, 254, 72, 204, 85, 223, 7, 138, 44, 48, 11, 222, 83, 122, 239, 183, 120]), rowOpeningDigest := (bytes [2, 131, 66, 126, 27, 244, 0, 68, 253, 150, 147, 11, 191, 45, 95, 27, 113, 76, 223, 152, 32, 11, 185, 143, 34, 76, 74, 206, 33, 197, 20, 254]), digest := (bytes [146, 66, 139, 78, 136, 92, 49, 207, 5, 221, 238, 58, 188, 204, 86, 91, 8, 239, 113, 163, 31, 106, 255, 92, 187, 102, 111, 227, 95, 205, 42, 209]) }]

def rootExecutionRowChunkRoutes : List RowChunkRouteView :=
  [{ logicalIndex := 0, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 0, digest := (bytes [138, 198, 109, 126, 144, 82, 221, 43, 248, 202, 137, 103, 62, 226, 249, 152, 163, 187, 1, 254, 36, 33, 59, 16, 64, 166, 202, 8, 219, 57, 240, 59]) }, { logicalIndex := 1, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 1, digest := (bytes [44, 177, 82, 41, 218, 60, 100, 208, 26, 31, 151, 113, 109, 148, 57, 12, 223, 21, 76, 221, 70, 245, 191, 105, 57, 199, 8, 128, 181, 145, 89, 99]) }, { logicalIndex := 2, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 2, digest := (bytes [252, 248, 65, 24, 81, 241, 150, 170, 250, 116, 222, 30, 134, 191, 78, 195, 104, 119, 225, 210, 243, 186, 212, 107, 183, 31, 243, 201, 101, 148, 32, 72]) }, { logicalIndex := 3, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 3, digest := (bytes [244, 11, 162, 13, 59, 43, 232, 47, 228, 2, 70, 126, 95, 10, 57, 40, 46, 107, 197, 81, 97, 39, 185, 163, 93, 60, 5, 66, 7, 231, 199, 134]) }, { logicalIndex := 4, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 4, digest := (bytes [98, 247, 204, 83, 252, 219, 248, 73, 49, 206, 229, 79, 169, 242, 28, 56, 7, 100, 18, 197, 133, 200, 133, 20, 161, 230, 126, 175, 98, 0, 158, 25]) }, { logicalIndex := 5, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 5, digest := (bytes [108, 248, 244, 125, 120, 190, 11, 202, 47, 205, 44, 110, 48, 43, 171, 224, 142, 98, 82, 106, 183, 21, 141, 205, 208, 18, 234, 19, 43, 61, 139, 151]) }, { logicalIndex := 6, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 6, digest := (bytes [213, 163, 43, 1, 32, 112, 128, 155, 10, 34, 241, 205, 79, 46, 234, 45, 239, 83, 213, 254, 45, 65, 13, 152, 217, 78, 36, 105, 42, 193, 181, 13]) }]

def rootExecutionRowLocalCcsAcceptance : List RootRowLocalCcsAcceptanceView :=
  [{ traceIndex := 0, logicalIndex := 0, rowDigest := (bytes [129, 16, 11, 76, 253, 155, 142, 28, 89, 240, 19, 169, 171, 115, 101, 224, 73, 120, 86, 195, 27, 185, 106, 175, 64, 231, 190, 170, 187, 57, 144, 129]), rowOpeningDigest := (bytes [50, 238, 42, 133, 107, 34, 54, 70, 10, 53, 197, 4, 106, 27, 119, 32, 0, 4, 236, 119, 96, 117, 207, 30, 209, 141, 155, 246, 5, 255, 61, 231]), preparedStepBindingDigest := (bytes [21, 99, 9, 114, 231, 3, 32, 163, 10, 42, 219, 25, 150, 124, 100, 226, 74, 77, 162, 66, 151, 141, 204, 96, 55, 199, 145, 42, 86, 140, 96, 191]), rowChunkRouteDigest := (bytes [138, 198, 109, 126, 144, 82, 221, 43, 248, 202, 137, 103, 62, 226, 249, 152, 163, 187, 1, 254, 36, 33, 59, 16, 64, 166, 202, 8, 219, 57, 240, 59]), publicStepDigest := (bytes [228, 87, 91, 158, 31, 90, 174, 156, 225, 173, 149, 7, 36, 18, 99, 17, 154, 156, 153, 179, 195, 43, 110, 194, 9, 41, 76, 52, 41, 61, 99, 140]), digest := (bytes [192, 121, 155, 29, 216, 127, 81, 155, 184, 202, 3, 216, 33, 42, 6, 194, 133, 182, 147, 245, 245, 132, 206, 181, 66, 197, 206, 238, 205, 220, 238, 7]) }, { traceIndex := 1, logicalIndex := 1, rowDigest := (bytes [118, 241, 85, 52, 49, 34, 244, 58, 177, 77, 241, 26, 187, 99, 153, 232, 253, 232, 156, 193, 74, 0, 238, 197, 59, 40, 202, 150, 1, 189, 10, 218]), rowOpeningDigest := (bytes [65, 216, 39, 173, 34, 162, 110, 125, 56, 63, 43, 5, 194, 27, 171, 110, 73, 164, 56, 143, 189, 199, 164, 147, 126, 50, 225, 146, 132, 184, 132, 214]), preparedStepBindingDigest := (bytes [242, 209, 238, 208, 107, 200, 193, 150, 27, 134, 218, 255, 95, 97, 148, 24, 120, 101, 254, 123, 95, 124, 0, 103, 94, 210, 234, 204, 49, 27, 23, 130]), rowChunkRouteDigest := (bytes [44, 177, 82, 41, 218, 60, 100, 208, 26, 31, 151, 113, 109, 148, 57, 12, 223, 21, 76, 221, 70, 245, 191, 105, 57, 199, 8, 128, 181, 145, 89, 99]), publicStepDigest := (bytes [76, 67, 67, 35, 253, 190, 93, 34, 202, 197, 161, 115, 154, 206, 112, 123, 165, 77, 145, 24, 52, 119, 122, 174, 180, 38, 158, 126, 170, 188, 42, 39]), digest := (bytes [76, 98, 202, 236, 170, 92, 215, 122, 213, 205, 203, 163, 194, 110, 147, 124, 86, 213, 238, 190, 120, 127, 28, 88, 195, 207, 9, 6, 158, 234, 27, 188]) }, { traceIndex := 2, logicalIndex := 2, rowDigest := (bytes [217, 26, 183, 177, 8, 240, 17, 93, 113, 53, 64, 231, 72, 111, 32, 6, 194, 253, 46, 50, 165, 138, 12, 26, 208, 109, 54, 159, 204, 6, 42, 71]), rowOpeningDigest := (bytes [59, 125, 48, 165, 145, 163, 181, 48, 39, 185, 243, 117, 79, 195, 220, 158, 173, 58, 125, 172, 131, 233, 162, 142, 69, 88, 138, 189, 204, 3, 40, 232]), preparedStepBindingDigest := (bytes [235, 169, 74, 146, 2, 77, 188, 252, 90, 53, 152, 22, 238, 244, 202, 252, 175, 206, 111, 129, 27, 146, 185, 86, 179, 10, 14, 97, 53, 142, 230, 172]), rowChunkRouteDigest := (bytes [252, 248, 65, 24, 81, 241, 150, 170, 250, 116, 222, 30, 134, 191, 78, 195, 104, 119, 225, 210, 243, 186, 212, 107, 183, 31, 243, 201, 101, 148, 32, 72]), publicStepDigest := (bytes [255, 180, 5, 145, 154, 201, 137, 129, 180, 235, 200, 187, 99, 166, 180, 172, 159, 233, 62, 198, 66, 24, 43, 134, 51, 207, 231, 230, 91, 241, 82, 206]), digest := (bytes [158, 55, 230, 14, 11, 25, 191, 103, 63, 15, 210, 45, 226, 6, 161, 192, 80, 174, 68, 209, 56, 0, 52, 206, 246, 77, 82, 188, 173, 95, 207, 170]) }, { traceIndex := 3, logicalIndex := 3, rowDigest := (bytes [89, 175, 55, 123, 106, 77, 80, 69, 22, 106, 206, 131, 222, 113, 179, 246, 122, 216, 188, 244, 216, 168, 32, 232, 170, 1, 133, 1, 44, 143, 104, 206]), rowOpeningDigest := (bytes [72, 222, 79, 90, 77, 47, 81, 28, 125, 37, 30, 208, 84, 119, 76, 32, 220, 22, 139, 6, 211, 35, 197, 173, 130, 146, 199, 251, 168, 9, 117, 49]), preparedStepBindingDigest := (bytes [238, 161, 160, 64, 117, 74, 0, 214, 252, 23, 112, 248, 71, 53, 200, 108, 220, 83, 236, 189, 132, 21, 130, 226, 103, 241, 82, 112, 234, 106, 218, 132]), rowChunkRouteDigest := (bytes [244, 11, 162, 13, 59, 43, 232, 47, 228, 2, 70, 126, 95, 10, 57, 40, 46, 107, 197, 81, 97, 39, 185, 163, 93, 60, 5, 66, 7, 231, 199, 134]), publicStepDigest := (bytes [65, 167, 78, 103, 174, 250, 205, 121, 49, 200, 156, 51, 193, 30, 209, 248, 68, 228, 221, 157, 208, 114, 123, 211, 242, 180, 11, 172, 11, 5, 127, 203]), digest := (bytes [45, 126, 161, 24, 69, 95, 86, 14, 21, 232, 37, 19, 133, 11, 86, 58, 37, 241, 82, 206, 53, 8, 135, 102, 207, 185, 172, 216, 125, 73, 88, 144]) }, { traceIndex := 4, logicalIndex := 4, rowDigest := (bytes [146, 107, 246, 114, 225, 206, 161, 39, 106, 133, 250, 2, 173, 145, 114, 194, 134, 143, 150, 85, 138, 5, 63, 119, 169, 178, 156, 187, 12, 20, 99, 235]), rowOpeningDigest := (bytes [25, 169, 50, 74, 116, 167, 11, 225, 103, 14, 225, 152, 168, 47, 151, 134, 49, 190, 33, 231, 154, 153, 109, 251, 209, 228, 12, 87, 212, 221, 109, 249]), preparedStepBindingDigest := (bytes [17, 180, 59, 178, 230, 103, 43, 25, 169, 72, 223, 71, 222, 210, 82, 75, 65, 193, 6, 54, 152, 199, 23, 102, 190, 223, 192, 106, 123, 133, 92, 5]), rowChunkRouteDigest := (bytes [98, 247, 204, 83, 252, 219, 248, 73, 49, 206, 229, 79, 169, 242, 28, 56, 7, 100, 18, 197, 133, 200, 133, 20, 161, 230, 126, 175, 98, 0, 158, 25]), publicStepDigest := (bytes [224, 184, 182, 173, 24, 146, 76, 217, 28, 153, 144, 221, 202, 226, 90, 137, 142, 162, 22, 178, 234, 136, 218, 167, 10, 10, 213, 154, 118, 201, 131, 252]), digest := (bytes [130, 240, 144, 65, 0, 133, 245, 107, 165, 246, 186, 139, 143, 49, 193, 71, 210, 55, 50, 231, 102, 85, 54, 103, 152, 185, 232, 191, 10, 12, 135, 180]) }, { traceIndex := 5, logicalIndex := 5, rowDigest := (bytes [233, 172, 62, 172, 60, 220, 125, 47, 73, 118, 70, 20, 91, 10, 72, 149, 100, 66, 186, 233, 219, 120, 143, 177, 63, 23, 182, 145, 221, 171, 75, 122]), rowOpeningDigest := (bytes [254, 251, 219, 175, 114, 174, 93, 63, 242, 81, 3, 194, 40, 100, 92, 71, 184, 9, 33, 25, 146, 247, 216, 78, 6, 111, 245, 201, 140, 128, 133, 120]), preparedStepBindingDigest := (bytes [66, 70, 43, 21, 55, 183, 194, 62, 165, 13, 206, 88, 22, 170, 245, 239, 126, 241, 99, 250, 145, 238, 111, 229, 253, 46, 26, 85, 118, 214, 162, 218]), rowChunkRouteDigest := (bytes [108, 248, 244, 125, 120, 190, 11, 202, 47, 205, 44, 110, 48, 43, 171, 224, 142, 98, 82, 106, 183, 21, 141, 205, 208, 18, 234, 19, 43, 61, 139, 151]), publicStepDigest := (bytes [7, 157, 52, 8, 17, 165, 175, 211, 46, 221, 200, 71, 64, 80, 138, 26, 23, 20, 201, 231, 137, 82, 50, 199, 147, 99, 2, 182, 65, 101, 76, 175]), digest := (bytes [174, 93, 197, 49, 38, 19, 234, 104, 37, 10, 216, 229, 255, 187, 160, 74, 54, 5, 17, 241, 237, 216, 128, 205, 226, 42, 242, 70, 235, 240, 7, 229]) }, { traceIndex := 6, logicalIndex := 6, rowDigest := (bytes [57, 167, 127, 66, 29, 28, 1, 62, 111, 174, 45, 82, 212, 157, 25, 154, 254, 72, 204, 85, 223, 7, 138, 44, 48, 11, 222, 83, 122, 239, 183, 120]), rowOpeningDigest := (bytes [2, 131, 66, 126, 27, 244, 0, 68, 253, 150, 147, 11, 191, 45, 95, 27, 113, 76, 223, 152, 32, 11, 185, 143, 34, 76, 74, 206, 33, 197, 20, 254]), preparedStepBindingDigest := (bytes [146, 66, 139, 78, 136, 92, 49, 207, 5, 221, 238, 58, 188, 204, 86, 91, 8, 239, 113, 163, 31, 106, 255, 92, 187, 102, 111, 227, 95, 205, 42, 209]), rowChunkRouteDigest := (bytes [213, 163, 43, 1, 32, 112, 128, 155, 10, 34, 241, 205, 79, 46, 234, 45, 239, 83, 213, 254, 45, 65, 13, 152, 217, 78, 36, 105, 42, 193, 181, 13]), publicStepDigest := (bytes [188, 255, 114, 147, 11, 230, 48, 155, 108, 50, 225, 167, 192, 101, 38, 131, 177, 181, 218, 166, 156, 3, 42, 148, 169, 202, 204, 45, 34, 34, 223, 74]), digest := (bytes [123, 71, 114, 241, 206, 182, 7, 111, 201, 29, 95, 137, 57, 237, 145, 49, 204, 120, 98, 191, 172, 176, 66, 243, 181, 50, 229, 32, 12, 82, 156, 203]) }]

def rootExecutionExecutionSemanticsRefinement : List RootExecutionSemanticsRefinementView :=
  [{ traceIndex := 0, logicalIndex := 0, semanticRowDigest := (bytes [22, 15, 48, 19, 12, 56, 48, 65, 147, 46, 70, 93, 99, 22, 242, 99, 133, 202, 72, 193, 133, 246, 250, 179, 76, 181, 245, 190, 93, 148, 8, 38]), rowLocalCcsAcceptanceDigest := (bytes [192, 121, 155, 29, 216, 127, 81, 155, 184, 202, 3, 216, 33, 42, 6, 194, 133, 182, 147, 245, 245, 132, 206, 181, 66, 197, 206, 238, 205, 220, 238, 7]), preparedStepBindingDigest := (bytes [21, 99, 9, 114, 231, 3, 32, 163, 10, 42, 219, 25, 150, 124, 100, 226, 74, 77, 162, 66, 151, 141, 204, 96, 55, 199, 145, 42, 86, 140, 96, 191]), publicStepDigest := (bytes [228, 87, 91, 158, 31, 90, 174, 156, 225, 173, 149, 7, 36, 18, 99, 17, 154, 156, 153, 179, 195, 43, 110, 194, 9, 41, 76, 52, 41, 61, 99, 140]), digest := (bytes [109, 150, 86, 69, 95, 66, 187, 212, 59, 226, 165, 172, 203, 66, 212, 219, 235, 246, 41, 150, 179, 28, 71, 239, 211, 241, 161, 146, 4, 251, 98, 249]) }, { traceIndex := 1, logicalIndex := 1, semanticRowDigest := (bytes [88, 255, 43, 47, 77, 137, 174, 163, 27, 232, 200, 155, 170, 241, 173, 173, 228, 118, 100, 27, 139, 219, 250, 211, 189, 242, 77, 16, 202, 239, 96, 213]), rowLocalCcsAcceptanceDigest := (bytes [76, 98, 202, 236, 170, 92, 215, 122, 213, 205, 203, 163, 194, 110, 147, 124, 86, 213, 238, 190, 120, 127, 28, 88, 195, 207, 9, 6, 158, 234, 27, 188]), preparedStepBindingDigest := (bytes [242, 209, 238, 208, 107, 200, 193, 150, 27, 134, 218, 255, 95, 97, 148, 24, 120, 101, 254, 123, 95, 124, 0, 103, 94, 210, 234, 204, 49, 27, 23, 130]), publicStepDigest := (bytes [76, 67, 67, 35, 253, 190, 93, 34, 202, 197, 161, 115, 154, 206, 112, 123, 165, 77, 145, 24, 52, 119, 122, 174, 180, 38, 158, 126, 170, 188, 42, 39]), digest := (bytes [79, 184, 183, 87, 118, 14, 133, 12, 186, 254, 118, 138, 98, 43, 137, 123, 181, 79, 39, 237, 238, 204, 170, 79, 123, 189, 167, 134, 239, 156, 250, 6]) }, { traceIndex := 2, logicalIndex := 2, semanticRowDigest := (bytes [145, 22, 223, 91, 177, 92, 204, 114, 69, 124, 79, 90, 77, 57, 19, 168, 123, 21, 249, 104, 90, 90, 55, 81, 149, 52, 217, 254, 139, 45, 140, 202]), rowLocalCcsAcceptanceDigest := (bytes [158, 55, 230, 14, 11, 25, 191, 103, 63, 15, 210, 45, 226, 6, 161, 192, 80, 174, 68, 209, 56, 0, 52, 206, 246, 77, 82, 188, 173, 95, 207, 170]), preparedStepBindingDigest := (bytes [235, 169, 74, 146, 2, 77, 188, 252, 90, 53, 152, 22, 238, 244, 202, 252, 175, 206, 111, 129, 27, 146, 185, 86, 179, 10, 14, 97, 53, 142, 230, 172]), publicStepDigest := (bytes [255, 180, 5, 145, 154, 201, 137, 129, 180, 235, 200, 187, 99, 166, 180, 172, 159, 233, 62, 198, 66, 24, 43, 134, 51, 207, 231, 230, 91, 241, 82, 206]), digest := (bytes [33, 156, 161, 190, 219, 0, 25, 126, 187, 54, 70, 255, 83, 125, 132, 0, 128, 198, 183, 3, 107, 1, 43, 92, 162, 6, 254, 96, 103, 247, 99, 177]) }, { traceIndex := 3, logicalIndex := 3, semanticRowDigest := (bytes [147, 73, 250, 12, 171, 14, 83, 195, 57, 92, 93, 105, 153, 223, 147, 91, 161, 165, 21, 77, 193, 185, 138, 0, 127, 233, 188, 44, 183, 249, 96, 100]), rowLocalCcsAcceptanceDigest := (bytes [45, 126, 161, 24, 69, 95, 86, 14, 21, 232, 37, 19, 133, 11, 86, 58, 37, 241, 82, 206, 53, 8, 135, 102, 207, 185, 172, 216, 125, 73, 88, 144]), preparedStepBindingDigest := (bytes [238, 161, 160, 64, 117, 74, 0, 214, 252, 23, 112, 248, 71, 53, 200, 108, 220, 83, 236, 189, 132, 21, 130, 226, 103, 241, 82, 112, 234, 106, 218, 132]), publicStepDigest := (bytes [65, 167, 78, 103, 174, 250, 205, 121, 49, 200, 156, 51, 193, 30, 209, 248, 68, 228, 221, 157, 208, 114, 123, 211, 242, 180, 11, 172, 11, 5, 127, 203]), digest := (bytes [134, 210, 110, 90, 52, 7, 62, 55, 122, 205, 146, 156, 236, 94, 216, 252, 190, 186, 38, 28, 178, 98, 129, 101, 213, 60, 189, 0, 151, 27, 88, 89]) }, { traceIndex := 4, logicalIndex := 4, semanticRowDigest := (bytes [84, 250, 70, 198, 126, 228, 94, 227, 112, 158, 83, 146, 125, 231, 115, 156, 175, 148, 38, 135, 24, 10, 191, 16, 121, 169, 185, 184, 202, 217, 224, 146]), rowLocalCcsAcceptanceDigest := (bytes [130, 240, 144, 65, 0, 133, 245, 107, 165, 246, 186, 139, 143, 49, 193, 71, 210, 55, 50, 231, 102, 85, 54, 103, 152, 185, 232, 191, 10, 12, 135, 180]), preparedStepBindingDigest := (bytes [17, 180, 59, 178, 230, 103, 43, 25, 169, 72, 223, 71, 222, 210, 82, 75, 65, 193, 6, 54, 152, 199, 23, 102, 190, 223, 192, 106, 123, 133, 92, 5]), publicStepDigest := (bytes [224, 184, 182, 173, 24, 146, 76, 217, 28, 153, 144, 221, 202, 226, 90, 137, 142, 162, 22, 178, 234, 136, 218, 167, 10, 10, 213, 154, 118, 201, 131, 252]), digest := (bytes [90, 179, 152, 4, 149, 119, 240, 212, 238, 185, 143, 6, 20, 12, 113, 159, 43, 66, 30, 55, 196, 199, 87, 248, 90, 64, 125, 18, 64, 141, 35, 228]) }, { traceIndex := 5, logicalIndex := 5, semanticRowDigest := (bytes [224, 149, 5, 210, 48, 219, 23, 114, 196, 243, 105, 57, 160, 196, 140, 240, 24, 201, 0, 219, 159, 153, 16, 112, 187, 8, 109, 168, 186, 217, 86, 95]), rowLocalCcsAcceptanceDigest := (bytes [174, 93, 197, 49, 38, 19, 234, 104, 37, 10, 216, 229, 255, 187, 160, 74, 54, 5, 17, 241, 237, 216, 128, 205, 226, 42, 242, 70, 235, 240, 7, 229]), preparedStepBindingDigest := (bytes [66, 70, 43, 21, 55, 183, 194, 62, 165, 13, 206, 88, 22, 170, 245, 239, 126, 241, 99, 250, 145, 238, 111, 229, 253, 46, 26, 85, 118, 214, 162, 218]), publicStepDigest := (bytes [7, 157, 52, 8, 17, 165, 175, 211, 46, 221, 200, 71, 64, 80, 138, 26, 23, 20, 201, 231, 137, 82, 50, 199, 147, 99, 2, 182, 65, 101, 76, 175]), digest := (bytes [70, 65, 22, 127, 204, 4, 129, 202, 225, 63, 20, 206, 37, 241, 233, 168, 239, 5, 41, 71, 94, 33, 255, 178, 77, 164, 50, 237, 79, 100, 68, 41]) }, { traceIndex := 6, logicalIndex := 6, semanticRowDigest := (bytes [53, 245, 127, 106, 55, 210, 83, 63, 162, 14, 12, 212, 9, 132, 72, 57, 29, 12, 230, 88, 252, 251, 47, 87, 51, 251, 133, 205, 8, 86, 144, 88]), rowLocalCcsAcceptanceDigest := (bytes [123, 71, 114, 241, 206, 182, 7, 111, 201, 29, 95, 137, 57, 237, 145, 49, 204, 120, 98, 191, 172, 176, 66, 243, 181, 50, 229, 32, 12, 82, 156, 203]), preparedStepBindingDigest := (bytes [146, 66, 139, 78, 136, 92, 49, 207, 5, 221, 238, 58, 188, 204, 86, 91, 8, 239, 113, 163, 31, 106, 255, 92, 187, 102, 111, 227, 95, 205, 42, 209]), publicStepDigest := (bytes [188, 255, 114, 147, 11, 230, 48, 155, 108, 50, 225, 167, 192, 101, 38, 131, 177, 181, 218, 166, 156, 3, 42, 148, 169, 202, 204, 45, 34, 34, 223, 74]), digest := (bytes [209, 133, 175, 223, 246, 72, 150, 105, 221, 143, 149, 218, 47, 134, 39, 145, 144, 184, 17, 74, 45, 183, 133, 88, 223, 238, 91, 215, 67, 138, 110, 115]) }]

def rootExecution : RootExecutionBundleView :=
  {
    executionRows := rootExecutionExecutionRows
    , semanticRows := rootExecutionSemanticRows
    , semanticRowsDigest := (bytes [226, 75, 185, 10, 235, 220, 135, 146, 12, 179, 192, 149, 134, 192, 120, 69, 206, 76, 227, 251, 108, 250, 217, 1, 30, 128, 163, 106, 189, 44, 139, 242])
    , preparedStepBindings := { bindings := rootExecutionPreparedBindings, bindingCount := 7, firstBindingDigest := (some (bytes [21, 99, 9, 114, 231, 3, 32, 163, 10, 42, 219, 25, 150, 124, 100, 226, 74, 77, 162, 66, 151, 141, 204, 96, 55, 199, 145, 42, 86, 140, 96, 191])), lastBindingDigest := (some (bytes [146, 66, 139, 78, 136, 92, 49, 207, 5, 221, 238, 58, 188, 204, 86, 91, 8, 239, 113, 163, 31, 106, 255, 92, 187, 102, 111, 227, 95, 205, 42, 209])), digest := (bytes [87, 71, 197, 222, 145, 126, 134, 239, 226, 74, 253, 106, 28, 144, 235, 131, 31, 120, 247, 233, 88, 225, 201, 44, 4, 49, 185, 67, 38, 174, 63, 242]) }
    , rowChunkRoutes := rootExecutionRowChunkRoutes
    , rowChunkRoutesDigest := (bytes [210, 211, 133, 148, 162, 150, 85, 66, 2, 24, 230, 163, 67, 64, 160, 246, 143, 119, 48, 189, 194, 114, 28, 76, 211, 182, 93, 15, 73, 83, 209, 85])
    , rowLocalCcsAcceptance := { acceptances := rootExecutionRowLocalCcsAcceptance, acceptanceCount := 7, firstAcceptanceDigest := (some (bytes [192, 121, 155, 29, 216, 127, 81, 155, 184, 202, 3, 216, 33, 42, 6, 194, 133, 182, 147, 245, 245, 132, 206, 181, 66, 197, 206, 238, 205, 220, 238, 7])), lastAcceptanceDigest := (some (bytes [123, 71, 114, 241, 206, 182, 7, 111, 201, 29, 95, 137, 57, 237, 145, 49, 204, 120, 98, 191, 172, 176, 66, 243, 181, 50, 229, 32, 12, 82, 156, 203])), digest := (bytes [95, 143, 238, 218, 177, 26, 83, 13, 150, 1, 96, 197, 195, 170, 115, 121, 140, 231, 147, 165, 40, 6, 168, 235, 188, 99, 193, 149, 207, 139, 106, 31]) }
    , executionSemanticsRefinement := { refinements := rootExecutionExecutionSemanticsRefinement, refinementCount := 7, firstRefinementDigest := (some (bytes [109, 150, 86, 69, 95, 66, 187, 212, 59, 226, 165, 172, 203, 66, 212, 219, 235, 246, 41, 150, 179, 28, 71, 239, 211, 241, 161, 146, 4, 251, 98, 249])), lastRefinementDigest := (some (bytes [209, 133, 175, 223, 246, 72, 150, 105, 221, 143, 149, 218, 47, 134, 39, 145, 144, 184, 17, 74, 45, 183, 133, 88, 223, 238, 91, 215, 67, 138, 110, 115])), digest := (bytes [39, 39, 85, 13, 234, 109, 111, 147, 213, 195, 82, 188, 6, 246, 223, 154, 241, 68, 203, 141, 161, 228, 87, 67, 246, 181, 219, 65, 22, 86, 253, 117]) }
    , familyDigest := (bytes [70, 190, 119, 237, 36, 24, 10, 255, 89, 160, 80, 108, 23, 145, 105, 211, 62, 238, 219, 129, 146, 61, 176, 70, 36, 218, 198, 73, 69, 147, 187, 137])
    , digest := (bytes [24, 252, 253, 214, 237, 162, 252, 240, 119, 138, 248, 141, 129, 98, 239, 90, 224, 7, 18, 3, 199, 223, 75, 2, 223, 241, 183, 100, 24, 143, 35, 172])
  }

def kernelOpeningBundle : SimpleKernelOpeningBundleView :=
  {
    claim := { bindings := { stageClaimBundleDigest := (bytes [252, 175, 36, 55, 16, 39, 35, 65, 192, 33, 136, 127, 92, 37, 5, 83, 58, 102, 165, 202, 255, 157, 139, 172, 252, 2, 15, 208, 167, 198, 104, 16]), stagePackageBundleDigest := (bytes [94, 159, 169, 31, 25, 245, 184, 4, 46, 138, 109, 67, 182, 224, 199, 16, 153, 186, 190, 175, 225, 196, 202, 59, 226, 179, 27, 101, 188, 47, 165, 149]), stage1PackageDigest := (bytes [242, 173, 96, 214, 78, 222, 28, 165, 129, 156, 193, 86, 68, 216, 118, 57, 97, 73, 225, 233, 152, 96, 17, 76, 85, 117, 101, 168, 162, 156, 168, 237]), stage2PackageDigest := (bytes [117, 100, 103, 165, 37, 29, 92, 151, 19, 172, 62, 235, 204, 183, 18, 246, 119, 143, 55, 182, 59, 131, 149, 169, 204, 165, 111, 196, 201, 14, 96, 167]), stage3PackageDigest := (bytes [21, 245, 157, 115, 126, 105, 209, 146, 6, 189, 145, 233, 254, 142, 227, 64, 172, 198, 139, 5, 185, 117, 230, 218, 60, 6, 163, 248, 78, 42, 113, 139]), preparedStepBindingsDigest := (bytes [87, 71, 197, 222, 145, 126, 134, 239, 226, 74, 253, 106, 28, 144, 235, 131, 31, 120, 247, 233, 88, 225, 201, 44, 4, 49, 185, 67, 38, 174, 63, 242]), bindingCount := 7, stage1RowCount := 7, stage2RegisterReadCount := 6, stage2RegisterWriteCount := 6, stage2RamEventCount := 6, stage3ContinuityCount := 7, points := { firstBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [87, 71, 197, 222, 145, 126, 134, 239, 226, 74, 253, 106, 28, 144, 235, 131, 31, 120, 247, 233, 88, 225, 201, 44, 4, 49, 185, 67, 38, 174, 63, 242]), layoutVersion := 1, digest := (bytes [247, 250, 179, 246, 113, 150, 182, 235, 255, 13, 224, 68, 250, 132, 167, 38, 61, 34, 211, 175, 154, 181, 67, 152, 144, 139, 248, 110, 9, 220, 249, 121]) }, logicalIndex := 0, digest := (bytes [160, 247, 93, 131, 56, 9, 70, 168, 123, 167, 55, 99, 122, 88, 207, 239, 233, 144, 93, 49, 236, 139, 60, 14, 157, 115, 221, 196, 127, 135, 12, 113]) }, valueDigest := (bytes [21, 99, 9, 114, 231, 3, 32, 163, 10, 42, 219, 25, 150, 124, 100, 226, 74, 77, 162, 66, 151, 141, 204, 96, 55, 199, 145, 42, 86, 140, 96, 191]), digest := (bytes [1, 254, 63, 105, 142, 38, 61, 95, 199, 63, 155, 160, 71, 244, 76, 207, 208, 178, 158, 12, 103, 8, 59, 235, 148, 127, 122, 86, 78, 6, 202, 198]) }), lastBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [87, 71, 197, 222, 145, 126, 134, 239, 226, 74, 253, 106, 28, 144, 235, 131, 31, 120, 247, 233, 88, 225, 201, 44, 4, 49, 185, 67, 38, 174, 63, 242]), layoutVersion := 1, digest := (bytes [247, 250, 179, 246, 113, 150, 182, 235, 255, 13, 224, 68, 250, 132, 167, 38, 61, 34, 211, 175, 154, 181, 67, 152, 144, 139, 248, 110, 9, 220, 249, 121]) }, logicalIndex := 6, digest := (bytes [121, 81, 40, 140, 127, 131, 149, 153, 13, 162, 207, 93, 197, 182, 164, 133, 35, 252, 135, 187, 9, 95, 112, 214, 57, 241, 68, 13, 199, 3, 146, 4]) }, valueDigest := (bytes [146, 66, 139, 78, 136, 92, 49, 207, 5, 221, 238, 58, 188, 204, 86, 91, 8, 239, 113, 163, 31, 106, 255, 92, 187, 102, 111, 227, 95, 205, 42, 209]), digest := (bytes [201, 227, 147, 215, 119, 254, 12, 222, 89, 139, 101, 193, 76, 59, 155, 48, 104, 209, 167, 165, 225, 61, 194, 188, 111, 109, 75, 166, 97, 21, 108, 96]) }) }, digest := (bytes [166, 229, 218, 129, 192, 173, 209, 183, 236, 7, 251, 111, 224, 86, 47, 38, 18, 71, 47, 202, 254, 62, 169, 21, 90, 201, 94, 199, 143, 186, 44, 48]) }, preparedSteps := { executionDigest := (bytes [187, 211, 69, 135, 229, 127, 64, 102, 85, 14, 246, 26, 208, 214, 247, 252, 184, 3, 119, 82, 89, 137, 101, 38, 31, 135, 97, 182, 171, 175, 16, 207]), finalStateDigest := (bytes [183, 99, 121, 135, 139, 0, 186, 237, 83, 70, 165, 225, 69, 94, 88, 23, 106, 225, 174, 203, 176, 128, 255, 252, 189, 21, 5, 237, 46, 123, 103, 80]), transcriptFinalDigest := (bytes [175, 114, 117, 171, 183, 140, 14, 93, 101, 78, 240, 173, 111, 217, 152, 3, 43, 35, 106, 30, 72, 100, 145, 192, 226, 19, 62, 206, 185, 20, 165, 109]), preparedStepCount := 7, finalPc := 28, halted := true, points := { firstPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [242, 91, 154, 59, 179, 31, 205, 226, 106, 197, 36, 140, 227, 67, 214, 106, 172, 86, 15, 141, 54, 207, 214, 226, 236, 63, 189, 77, 236, 136, 221, 41]), layoutVersion := 3, digest := (bytes [196, 194, 83, 41, 254, 85, 154, 3, 27, 133, 154, 198, 75, 41, 176, 38, 251, 138, 26, 245, 43, 23, 149, 221, 37, 126, 131, 135, 61, 219, 245, 126]) }, logicalIndex := 0, digest := (bytes [18, 182, 151, 108, 176, 139, 62, 254, 180, 178, 194, 184, 131, 85, 158, 49, 199, 77, 210, 40, 135, 44, 158, 184, 74, 173, 44, 24, 177, 94, 55, 54]) }, valueDigest := (bytes [129, 16, 11, 76, 253, 155, 142, 28, 89, 240, 19, 169, 171, 115, 101, 224, 73, 120, 86, 195, 27, 185, 106, 175, 64, 231, 190, 170, 187, 57, 144, 129]), digest := (bytes [172, 1, 44, 77, 105, 92, 145, 74, 215, 231, 41, 237, 112, 208, 85, 46, 7, 45, 204, 78, 158, 105, 59, 123, 2, 171, 181, 78, 110, 138, 150, 6]) }), lastPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [242, 91, 154, 59, 179, 31, 205, 226, 106, 197, 36, 140, 227, 67, 214, 106, 172, 86, 15, 141, 54, 207, 214, 226, 236, 63, 189, 77, 236, 136, 221, 41]), layoutVersion := 3, digest := (bytes [196, 194, 83, 41, 254, 85, 154, 3, 27, 133, 154, 198, 75, 41, 176, 38, 251, 138, 26, 245, 43, 23, 149, 221, 37, 126, 131, 135, 61, 219, 245, 126]) }, logicalIndex := 6, digest := (bytes [10, 223, 129, 108, 227, 203, 154, 145, 141, 129, 215, 247, 157, 208, 180, 255, 202, 36, 10, 231, 89, 215, 159, 81, 120, 177, 99, 161, 55, 22, 112, 57]) }, valueDigest := (bytes [57, 167, 127, 66, 29, 28, 1, 62, 111, 174, 45, 82, 212, 157, 25, 154, 254, 72, 204, 85, 223, 7, 138, 44, 48, 11, 222, 83, 122, 239, 183, 120]), digest := (bytes [92, 219, 197, 231, 121, 26, 25, 227, 146, 19, 85, 137, 42, 97, 157, 106, 111, 249, 53, 54, 34, 115, 103, 115, 189, 185, 106, 22, 129, 42, 59, 71]) }) }, digest := (bytes [201, 9, 212, 255, 232, 117, 192, 59, 215, 218, 237, 184, 244, 224, 66, 47, 60, 177, 180, 23, 19, 143, 141, 115, 103, 198, 37, 19, 243, 136, 11, 184]) }, digest := (bytes [125, 215, 94, 215, 230, 158, 106, 144, 53, 21, 187, 48, 96, 238, 228, 131, 131, 235, 98, 201, 79, 252, 28, 204, 85, 44, 105, 21, 223, 210, 61, 61]) }
    , bindings := { claim := { stageClaimBundleDigest := (bytes [252, 175, 36, 55, 16, 39, 35, 65, 192, 33, 136, 127, 92, 37, 5, 83, 58, 102, 165, 202, 255, 157, 139, 172, 252, 2, 15, 208, 167, 198, 104, 16]), stagePackageBundleDigest := (bytes [94, 159, 169, 31, 25, 245, 184, 4, 46, 138, 109, 67, 182, 224, 199, 16, 153, 186, 190, 175, 225, 196, 202, 59, 226, 179, 27, 101, 188, 47, 165, 149]), stage1PackageDigest := (bytes [242, 173, 96, 214, 78, 222, 28, 165, 129, 156, 193, 86, 68, 216, 118, 57, 97, 73, 225, 233, 152, 96, 17, 76, 85, 117, 101, 168, 162, 156, 168, 237]), stage2PackageDigest := (bytes [117, 100, 103, 165, 37, 29, 92, 151, 19, 172, 62, 235, 204, 183, 18, 246, 119, 143, 55, 182, 59, 131, 149, 169, 204, 165, 111, 196, 201, 14, 96, 167]), stage3PackageDigest := (bytes [21, 245, 157, 115, 126, 105, 209, 146, 6, 189, 145, 233, 254, 142, 227, 64, 172, 198, 139, 5, 185, 117, 230, 218, 60, 6, 163, 248, 78, 42, 113, 139]), preparedStepBindingsDigest := (bytes [87, 71, 197, 222, 145, 126, 134, 239, 226, 74, 253, 106, 28, 144, 235, 131, 31, 120, 247, 233, 88, 225, 201, 44, 4, 49, 185, 67, 38, 174, 63, 242]), bindingCount := 7, stage1RowCount := 7, stage2RegisterReadCount := 6, stage2RegisterWriteCount := 6, stage2RamEventCount := 6, stage3ContinuityCount := 7, points := { firstBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [87, 71, 197, 222, 145, 126, 134, 239, 226, 74, 253, 106, 28, 144, 235, 131, 31, 120, 247, 233, 88, 225, 201, 44, 4, 49, 185, 67, 38, 174, 63, 242]), layoutVersion := 1, digest := (bytes [247, 250, 179, 246, 113, 150, 182, 235, 255, 13, 224, 68, 250, 132, 167, 38, 61, 34, 211, 175, 154, 181, 67, 152, 144, 139, 248, 110, 9, 220, 249, 121]) }, logicalIndex := 0, digest := (bytes [160, 247, 93, 131, 56, 9, 70, 168, 123, 167, 55, 99, 122, 88, 207, 239, 233, 144, 93, 49, 236, 139, 60, 14, 157, 115, 221, 196, 127, 135, 12, 113]) }, valueDigest := (bytes [21, 99, 9, 114, 231, 3, 32, 163, 10, 42, 219, 25, 150, 124, 100, 226, 74, 77, 162, 66, 151, 141, 204, 96, 55, 199, 145, 42, 86, 140, 96, 191]), digest := (bytes [1, 254, 63, 105, 142, 38, 61, 95, 199, 63, 155, 160, 71, 244, 76, 207, 208, 178, 158, 12, 103, 8, 59, 235, 148, 127, 122, 86, 78, 6, 202, 198]) }), lastBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [87, 71, 197, 222, 145, 126, 134, 239, 226, 74, 253, 106, 28, 144, 235, 131, 31, 120, 247, 233, 88, 225, 201, 44, 4, 49, 185, 67, 38, 174, 63, 242]), layoutVersion := 1, digest := (bytes [247, 250, 179, 246, 113, 150, 182, 235, 255, 13, 224, 68, 250, 132, 167, 38, 61, 34, 211, 175, 154, 181, 67, 152, 144, 139, 248, 110, 9, 220, 249, 121]) }, logicalIndex := 6, digest := (bytes [121, 81, 40, 140, 127, 131, 149, 153, 13, 162, 207, 93, 197, 182, 164, 133, 35, 252, 135, 187, 9, 95, 112, 214, 57, 241, 68, 13, 199, 3, 146, 4]) }, valueDigest := (bytes [146, 66, 139, 78, 136, 92, 49, 207, 5, 221, 238, 58, 188, 204, 86, 91, 8, 239, 113, 163, 31, 106, 255, 92, 187, 102, 111, 227, 95, 205, 42, 209]), digest := (bytes [201, 227, 147, 215, 119, 254, 12, 222, 89, 139, 101, 193, 76, 59, 155, 48, 104, 209, 167, 165, 225, 61, 194, 188, 111, 109, 75, 166, 97, 21, 108, 96]) }) }, digest := (bytes [166, 229, 218, 129, 192, 173, 209, 183, 236, 7, 251, 111, 224, 86, 47, 38, 18, 71, 47, 202, 254, 62, 169, 21, 90, 201, 94, 199, 143, 186, 44, 48]) }, packaged := { statementDigest := (bytes [5, 158, 245, 197, 180, 15, 129, 203, 37, 28, 123, 167, 218, 193, 144, 209, 15, 243, 39, 167, 8, 217, 110, 17, 9, 160, 145, 128, 72, 61, 185, 0]), proofDigest := (bytes [91, 219, 52, 4, 112, 93, 47, 25, 192, 55, 203, 148, 78, 49, 12, 182, 244, 147, 224, 231, 69, 252, 126, 78, 109, 173, 255, 236, 150, 232, 164, 136]) }, digest := (bytes [172, 38, 119, 164, 63, 10, 208, 83, 254, 205, 64, 201, 219, 250, 218, 151, 248, 218, 166, 136, 128, 2, 176, 192, 120, 173, 199, 116, 104, 79, 83, 221]) }
    , preparedSteps := { claim := { executionDigest := (bytes [187, 211, 69, 135, 229, 127, 64, 102, 85, 14, 246, 26, 208, 214, 247, 252, 184, 3, 119, 82, 89, 137, 101, 38, 31, 135, 97, 182, 171, 175, 16, 207]), finalStateDigest := (bytes [183, 99, 121, 135, 139, 0, 186, 237, 83, 70, 165, 225, 69, 94, 88, 23, 106, 225, 174, 203, 176, 128, 255, 252, 189, 21, 5, 237, 46, 123, 103, 80]), transcriptFinalDigest := (bytes [175, 114, 117, 171, 183, 140, 14, 93, 101, 78, 240, 173, 111, 217, 152, 3, 43, 35, 106, 30, 72, 100, 145, 192, 226, 19, 62, 206, 185, 20, 165, 109]), preparedStepCount := 7, finalPc := 28, halted := true, points := { firstPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [242, 91, 154, 59, 179, 31, 205, 226, 106, 197, 36, 140, 227, 67, 214, 106, 172, 86, 15, 141, 54, 207, 214, 226, 236, 63, 189, 77, 236, 136, 221, 41]), layoutVersion := 3, digest := (bytes [196, 194, 83, 41, 254, 85, 154, 3, 27, 133, 154, 198, 75, 41, 176, 38, 251, 138, 26, 245, 43, 23, 149, 221, 37, 126, 131, 135, 61, 219, 245, 126]) }, logicalIndex := 0, digest := (bytes [18, 182, 151, 108, 176, 139, 62, 254, 180, 178, 194, 184, 131, 85, 158, 49, 199, 77, 210, 40, 135, 44, 158, 184, 74, 173, 44, 24, 177, 94, 55, 54]) }, valueDigest := (bytes [129, 16, 11, 76, 253, 155, 142, 28, 89, 240, 19, 169, 171, 115, 101, 224, 73, 120, 86, 195, 27, 185, 106, 175, 64, 231, 190, 170, 187, 57, 144, 129]), digest := (bytes [172, 1, 44, 77, 105, 92, 145, 74, 215, 231, 41, 237, 112, 208, 85, 46, 7, 45, 204, 78, 158, 105, 59, 123, 2, 171, 181, 78, 110, 138, 150, 6]) }), lastPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [242, 91, 154, 59, 179, 31, 205, 226, 106, 197, 36, 140, 227, 67, 214, 106, 172, 86, 15, 141, 54, 207, 214, 226, 236, 63, 189, 77, 236, 136, 221, 41]), layoutVersion := 3, digest := (bytes [196, 194, 83, 41, 254, 85, 154, 3, 27, 133, 154, 198, 75, 41, 176, 38, 251, 138, 26, 245, 43, 23, 149, 221, 37, 126, 131, 135, 61, 219, 245, 126]) }, logicalIndex := 6, digest := (bytes [10, 223, 129, 108, 227, 203, 154, 145, 141, 129, 215, 247, 157, 208, 180, 255, 202, 36, 10, 231, 89, 215, 159, 81, 120, 177, 99, 161, 55, 22, 112, 57]) }, valueDigest := (bytes [57, 167, 127, 66, 29, 28, 1, 62, 111, 174, 45, 82, 212, 157, 25, 154, 254, 72, 204, 85, 223, 7, 138, 44, 48, 11, 222, 83, 122, 239, 183, 120]), digest := (bytes [92, 219, 197, 231, 121, 26, 25, 227, 146, 19, 85, 137, 42, 97, 157, 106, 111, 249, 53, 54, 34, 115, 103, 115, 189, 185, 106, 22, 129, 42, 59, 71]) }) }, digest := (bytes [201, 9, 212, 255, 232, 117, 192, 59, 215, 218, 237, 184, 244, 224, 66, 47, 60, 177, 180, 23, 19, 143, 141, 115, 103, 198, 37, 19, 243, 136, 11, 184]) }, packaged := { statementDigest := (bytes [50, 58, 206, 0, 218, 115, 243, 54, 191, 15, 60, 53, 153, 159, 240, 123, 79, 92, 63, 56, 100, 59, 134, 201, 16, 141, 201, 160, 184, 252, 165, 157]), proofDigest := (bytes [196, 16, 101, 8, 10, 30, 50, 39, 123, 17, 115, 17, 70, 120, 8, 196, 224, 55, 26, 151, 1, 42, 62, 181, 29, 201, 186, 161, 239, 233, 216, 249]) }, digest := (bytes [128, 244, 11, 88, 195, 150, 200, 124, 145, 196, 16, 43, 4, 66, 29, 221, 61, 201, 157, 185, 154, 35, 129, 178, 187, 121, 123, 200, 20, 148, 99, 91]) }
    , digest := (bytes [174, 215, 89, 16, 208, 92, 164, 214, 195, 135, 203, 234, 204, 218, 31, 142, 86, 82, 205, 149, 108, 240, 27, 186, 231, 60, 230, 45, 110, 162, 156, 232])
  }

def stepComposition : StepCompositionSurfaceView :=
  {
    stage1SemanticsDigest := (bytes [74, 154, 72, 213, 108, 221, 218, 122, 147, 78, 0, 53, 195, 236, 115, 127, 116, 228, 133, 35, 47, 217, 46, 15, 149, 87, 2, 251, 218, 108, 15, 113])
    , stage2SemanticsDigest := (bytes [83, 192, 90, 234, 58, 169, 14, 192, 26, 112, 127, 126, 4, 121, 154, 146, 118, 1, 221, 180, 209, 50, 248, 51, 75, 199, 123, 125, 53, 72, 3, 118])
    , stage2TemporalDigest := (bytes [146, 143, 86, 88, 53, 249, 16, 218, 47, 25, 144, 130, 231, 121, 210, 15, 203, 112, 97, 68, 235, 120, 203, 255, 255, 59, 194, 199, 162, 104, 156, 50])
    , stage3SemanticsDigest := (bytes [71, 94, 30, 190, 57, 47, 196, 27, 202, 94, 77, 211, 45, 254, 46, 51, 134, 201, 240, 237, 218, 173, 22, 122, 161, 44, 236, 184, 223, 176, 163, 166])
    , rootExecutionDigest := (bytes [24, 252, 253, 214, 237, 162, 252, 240, 119, 138, 248, 141, 129, 98, 239, 90, 224, 7, 18, 3, 199, 223, 75, 2, 223, 241, 183, 100, 24, 143, 35, 172])
    , preparedStepBindingsDigest := (bytes [87, 71, 197, 222, 145, 126, 134, 239, 226, 74, 253, 106, 28, 144, 235, 131, 31, 120, 247, 233, 88, 225, 201, 44, 4, 49, 185, 67, 38, 174, 63, 242])
    , rowChunkRoutesDigest := (bytes [210, 211, 133, 148, 162, 150, 85, 66, 2, 24, 230, 163, 67, 64, 160, 246, 143, 119, 48, 189, 194, 114, 28, 76, 211, 182, 93, 15, 73, 83, 209, 85])
    , realRowCount := 7
    , preparedStepCount := 7
    , firstRealStepIndex := 0
    , lastRealStepIndex := 6
    , initialPc := 0
    , finalPc := 28
    , halted := true
    , digest := (bytes [201, 171, 245, 116, 1, 229, 43, 230, 163, 165, 169, 83, 83, 139, 26, 78, 250, 11, 76, 175, 160, 41, 54, 238, 127, 166, 102, 106, 217, 87, 121, 112])
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
    name := "narrow_memory_load_extract_extend_ecall"
    , source := {
  manifest := { name := "narrow_memory_load_extract_extend_ecall", fixtureId := "narrow_memory_load_extract_extend_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.narrowMemory, .controlFlow] }
  , startPc := 0
  , programWords := [327811, 1392899, 332163, 2445827, 336515, 4547331, 115]
  , initialRegisters := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 12288, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , initialMemory := [{ addr := 12288, value := 9920249032750366975 }]
  , transcriptSeed := (bytes [114, 118, 54, 52, 105, 109, 45, 110, 97, 114, 114, 111, 119, 45, 109, 101, 109, 111, 114, 121, 45, 108, 111, 97, 100, 45, 118, 49])
}
    , derived := {
  manifest := { name := "narrow_memory_load_extract_extend_ecall", fixtureId := "narrow_memory_load_extract_extend_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.narrowMemory, .controlFlow] }
  , executionRows := [{
  traceIndex := 0
  , stepIndex := 0
  , sequenceIndex := 0
  , pc := 0
  , nextPc := 4
  , word := 327811
  , opcode := .lb
  , traceOpcode := (some .lb)
  , traceVirtualOpcode := none
  , family := .narrowMemory
  , rs1 := 10
  , rs1Value := 12288
  , rs2 := 0
  , rs2Value := 0
  , rd := 1
  , rdBefore := 0
  , rdAfter := 18446744073709551615
  , imm := 0
  , aluResult := 18446744073709551615
  , effectiveAddr := (some 12288)
  , memoryBefore := (some 9920249032750366975)
  , memoryAfter := (some 9920249032750366975)
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
  , word := 1392899
  , opcode := .lbu
  , traceOpcode := (some .lbu)
  , traceVirtualOpcode := none
  , family := .narrowMemory
  , rs1 := 10
  , rs1Value := 12288
  , rs2 := 0
  , rs2Value := 0
  , rd := 2
  , rdBefore := 0
  , rdAfter := 128
  , imm := 1
  , aluResult := 128
  , effectiveAddr := (some 12289)
  , memoryBefore := (some 9920249032750366975)
  , memoryAfter := (some 9920249032750366975)
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
  , word := 332163
  , opcode := .lh
  , traceOpcode := (some .lh)
  , traceVirtualOpcode := none
  , family := .narrowMemory
  , rs1 := 10
  , rs1Value := 12288
  , rs2 := 0
  , rs2Value := 0
  , rd := 3
  , rdBefore := 0
  , rdAfter := 18446744073709519103
  , imm := 0
  , aluResult := 18446744073709519103
  , effectiveAddr := (some 12288)
  , memoryBefore := (some 9920249032750366975)
  , memoryAfter := (some 9920249032750366975)
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
  , word := 2445827
  , opcode := .lhu
  , traceOpcode := (some .lhu)
  , traceVirtualOpcode := none
  , family := .narrowMemory
  , rs1 := 10
  , rs1Value := 12288
  , rs2 := 0
  , rs2Value := 0
  , rd := 4
  , rdBefore := 0
  , rdAfter := 32895
  , imm := 2
  , aluResult := 32895
  , effectiveAddr := (some 12290)
  , memoryBefore := (some 9920249032750366975)
  , memoryAfter := (some 9920249032750366975)
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
  , word := 336515
  , opcode := .lw
  , traceOpcode := (some .lw)
  , traceVirtualOpcode := none
  , family := .narrowMemory
  , rs1 := 10
  , rs1Value := 12288
  , rs2 := 0
  , rs2Value := 0
  , rd := 5
  , rdBefore := 0
  , rdAfter := 18446744071570424063
  , imm := 0
  , aluResult := 18446744071570424063
  , effectiveAddr := (some 12288)
  , memoryBefore := (some 9920249032750366975)
  , memoryAfter := (some 9920249032750366975)
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
  , word := 4547331
  , opcode := .lwu
  , traceOpcode := (some .lwu)
  , traceVirtualOpcode := none
  , family := .narrowMemory
  , rs1 := 10
  , rs1Value := 12288
  , rs2 := 0
  , rs2Value := 0
  , rd := 6
  , rdBefore := 0
  , rdAfter := 2309737967
  , imm := 4
  , aluResult := 2309737967
  , effectiveAddr := (some 12292)
  , memoryBefore := (some 9920249032750366975)
  , memoryAfter := (some 9920249032750366975)
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
  , stage1 := { rows := [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 327811, opcode := .lb, traceOpcode := (some .lb), traceVirtualOpcode := none, family := .narrowMemory, nextPc := 4, aluResult := 18446744073709551615, effectiveAddr := (some 12288), writesRd := true, rd := 1, rdAfter := 18446744073709551615, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 1392899, opcode := .lbu, traceOpcode := (some .lbu), traceVirtualOpcode := none, family := .narrowMemory, nextPc := 8, aluResult := 128, effectiveAddr := (some 12289), writesRd := true, rd := 2, rdAfter := 128, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 332163, opcode := .lh, traceOpcode := (some .lh), traceVirtualOpcode := none, family := .narrowMemory, nextPc := 12, aluResult := 18446744073709519103, effectiveAddr := (some 12288), writesRd := true, rd := 3, rdAfter := 18446744073709519103, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 12, fetchedWord := 2445827, opcode := .lhu, traceOpcode := (some .lhu), traceVirtualOpcode := none, family := .narrowMemory, nextPc := 16, aluResult := 32895, effectiveAddr := (some 12290), writesRd := true, rd := 4, rdAfter := 32895, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 4, stepIndex := 4, sequenceIndex := 0, fetchPc := 16, fetchedWord := 336515, opcode := .lw, traceOpcode := (some .lw), traceVirtualOpcode := none, family := .narrowMemory, nextPc := 20, aluResult := 18446744071570424063, effectiveAddr := (some 12288), writesRd := true, rd := 5, rdAfter := 18446744071570424063, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 5, stepIndex := 5, sequenceIndex := 0, fetchPc := 20, fetchedWord := 4547331, opcode := .lwu, traceOpcode := (some .lwu), traceVirtualOpcode := none, family := .narrowMemory, nextPc := 24, aluResult := 2309737967, effectiveAddr := (some 12292), writesRd := true, rd := 6, rdAfter := 2309737967, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 6, stepIndex := 6, sequenceIndex := 0, fetchPc := 24, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 28, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }] }
  , stage2 := {
  registerReads := [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 10, value := 12288 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 10, value := 12288 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 10, value := 12288 }, { traceIndex := 3, stepIndex := 3, role := .rs1, reg := 10, value := 12288 }, { traceIndex := 4, stepIndex := 4, role := .rs1, reg := 10, value := 12288 }, { traceIndex := 5, stepIndex := 5, role := .rs1, reg := 10, value := 12288 }]
  , registerWrites := [{ traceIndex := 0, stepIndex := 0, reg := 1, previous := 0, next := 18446744073709551615 }, { traceIndex := 1, stepIndex := 1, reg := 2, previous := 0, next := 128 }, { traceIndex := 2, stepIndex := 2, reg := 3, previous := 0, next := 18446744073709519103 }, { traceIndex := 3, stepIndex := 3, reg := 4, previous := 0, next := 32895 }, { traceIndex := 4, stepIndex := 4, reg := 5, previous := 0, next := 18446744071570424063 }, { traceIndex := 5, stepIndex := 5, reg := 6, previous := 0, next := 2309737967 }]
  , ramEvents := [{ traceIndex := 0, stepIndex := 0, kind := .read, addr := 12288, previous := 9920249032750366975, next := 9920249032750366975 }, { traceIndex := 1, stepIndex := 1, kind := .read, addr := 12288, previous := 9920249032750366975, next := 9920249032750366975 }, { traceIndex := 2, stepIndex := 2, kind := .read, addr := 12288, previous := 9920249032750366975, next := 9920249032750366975 }, { traceIndex := 3, stepIndex := 3, kind := .read, addr := 12288, previous := 9920249032750366975, next := 9920249032750366975 }, { traceIndex := 4, stepIndex := 4, kind := .read, addr := 12288, previous := 9920249032750366975, next := 9920249032750366975 }, { traceIndex := 5, stepIndex := 5, kind := .read, addr := 12288, previous := 9920249032750366975, next := 9920249032750366975 }]
  , twistLinks := [{ traceIndex := 0, stepIndex := 0, family := .narrowMemory, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := (some 9920249032750366975), routedMemoryAfter := (some 9920249032750366975) }, { traceIndex := 1, stepIndex := 1, family := .narrowMemory, routedWriteValue := (some 128), routedMemoryBefore := (some 9920249032750366975), routedMemoryAfter := (some 9920249032750366975) }, { traceIndex := 2, stepIndex := 2, family := .narrowMemory, routedWriteValue := (some 18446744073709519103), routedMemoryBefore := (some 9920249032750366975), routedMemoryAfter := (some 9920249032750366975) }, { traceIndex := 3, stepIndex := 3, family := .narrowMemory, routedWriteValue := (some 32895), routedMemoryBefore := (some 9920249032750366975), routedMemoryAfter := (some 9920249032750366975) }, { traceIndex := 4, stepIndex := 4, family := .narrowMemory, routedWriteValue := (some 18446744071570424063), routedMemoryBefore := (some 9920249032750366975), routedMemoryAfter := (some 9920249032750366975) }, { traceIndex := 5, stepIndex := 5, family := .narrowMemory, routedWriteValue := (some 2309737967), routedMemoryBefore := (some 9920249032750366975), routedMemoryAfter := (some 9920249032750366975) }, { traceIndex := 6, stepIndex := 6, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]
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
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 110, 97, 114, 114, 111, 119, 45, 109, 101, 109, 111, 114, 121, 45, 108, 111, 97, 100, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [12799906354652525, 13922211188535148, 8175347121317401730, 8308484394106086806, 5884511499246010210, 7998233416229622215, 6964649998063382141, 1153192176276551949], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [110, 97, 114, 114, 111, 119, 95, 109, 101, 109, 111, 114, 121, 95, 108, 111, 97, 100, 95, 101, 120, 116, 114, 97, 99, 116, 95, 101, 120, 116, 101, 110, 100, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [12799906354652525, 13922211188535148, 8175347121317401730, 8308484394106086806, 5884511499246010210, 7998233416229622215, 6964649998063382141, 1153192176276551949], absorbed := 2 }
  , cursorAfter := { stateWords := [28533857601287288, 1819042147, 13405346572071477917, 15027069468260443345, 4657219632283511591, 13009867408141909840, 4570646721011936107, 9340009794846925166], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [327811, 1392899, 332163, 2445827, 336515, 4547331, 115]
  , cursorBefore := { stateWords := [28533857601287288, 1819042147, 13405346572071477917, 15027069468260443345, 4657219632283511591, 13009867408141909840, 4570646721011936107, 9340009794846925166], absorbed := 2 }
  , cursorAfter := { stateWords := [115, 0, 18158569649085369217, 4324689580891859743, 10837909801324925519, 629902553474001713, 11675622141450684452, 7267351139728427145], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 12288, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [115, 0, 18158569649085369217, 4324689580891859743, 10837909801324925519, 629902553474001713, 11675622141450684452, 7267351139728427145], absorbed := 2 }
  , cursorAfter := { stateWords := [3830413514925331899, 15686288481201580579, 4012207186557823599, 15735477179778979507, 17069698027905491847, 15814070235405475754, 820753214640218683, 3850378618103265605], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := [12288, 9920249032750366975]
  , cursorBefore := { stateWords := [3830413514925331899, 15686288481201580579, 4012207186557823599, 15735477179778979507, 17069698027905491847, 15814070235405475754, 820753214640218683, 3850378618103265605], absorbed := 0 }
  , cursorAfter := { stateWords := [2155839743, 2309737967, 17016907635301106391, 499923465555411882, 13196496673628649080, 4039687380468766989, 8511621768432349814, 1763263620507366255], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [67, 149, 212, 203, 125, 6, 193, 148, 95, 242, 87, 131, 79, 199, 154, 105, 62, 65, 66, 99, 45, 14, 202, 150, 24, 19, 22, 127, 80, 126, 57, 58])
  , u64s := []
  , cursorBefore := { stateWords := [2155839743, 2309737967, 17016907635301106391, 499923465555411882, 13196496673628649080, 4039687380468766989, 8511621768432349814, 1763263620507366255], absorbed := 2 }
  , cursorAfter := { stateWords := [976846416, 11042167288883101657, 9351894048581840145, 7006946695586167544, 17289545109842428286, 12963296847801935423, 15745235796732095321, 13267867589393505093], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [976846416, 11042167288883101657, 9351894048581840145, 7006946695586167544, 17289545109842428286, 12963296847801935423, 15745235796732095321, 13267867589393505093], absorbed := 1 }
  , cursorAfter := { stateWords := [6021918011723055633, 1314817092102069106, 12426851555635967853, 10353416768809675651, 17337105125606089765, 2918732584938148215, 14472588237035002733, 8229608136258886321], absorbed := 0 }
  , challengeOutput := (some 6021918011723055633)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [233, 196, 203, 200, 70, 58, 121, 64, 190, 77, 215, 109, 211, 207, 110, 212, 227, 39, 71, 54, 50, 7, 179, 37, 204, 185, 66, 14, 130, 114, 51, 240])
  , u64s := []
  , cursorBefore := { stateWords := [6021918011723055633, 1314817092102069106, 12426851555635967853, 10353416768809675651, 17337105125606089765, 2918732584938148215, 14472588237035002733, 8229608136258886321], absorbed := 0 }
  , cursorAfter := { stateWords := [14133428075353198, 4014015435354887, 4029903490, 16838230519069327746, 4085405358271329919, 14228927208023853474, 107353801817462348, 1952929269162220252], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [14133428075353198, 4014015435354887, 4029903490, 16838230519069327746, 4085405358271329919, 14228927208023853474, 107353801817462348, 1952929269162220252], absorbed := 3 }
  , cursorAfter := { stateWords := [12166816141915752516, 15419316117070074829, 2047636294008387338, 7699572410557338177, 13310677340565681106, 17751688798917587722, 14344274668446917168, 15533352597549184691], absorbed := 0 }
  , challengeOutput := (some 12166816141915752516)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [12166816141915752516, 15419316117070074829, 2047636294008387338, 7699572410557338177, 13310677340565681106, 17751688798917587722, 14344274668446917168, 15533352597549184691], absorbed := 0 }
  , cursorAfter := { stateWords := [4582133116042247748, 8731322839414209506, 1662529965242248010, 8418892417039773871, 9000361494525483189, 13638806656306225915, 1570254867137968212, 6077116453526416551], absorbed := 0 }
  , challengeOutput := (some 4582133116042247748)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [133, 91, 57, 33, 9, 81, 232, 147, 233, 248, 11, 52, 22, 187, 82, 147, 231, 35, 101, 212, 42, 7, 126, 94, 3, 54, 201, 128, 233, 222, 146, 92])
  , u64s := []
  , cursorBefore := { stateWords := [4582133116042247748, 8731322839414209506, 1662529965242248010, 8418892417039773871, 9000361494525483189, 13638806656306225915, 1570254867137968212, 6077116453526416551], absorbed := 0 }
  , cursorAfter := { stateWords := [12055479881012050, 36250030840905223, 1553129193, 7433689907473488653, 5965175124267803640, 14792457317794278921, 605774587042402052, 3412124567993221433], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [12055479881012050, 36250030840905223, 1553129193, 7433689907473488653, 5965175124267803640, 14792457317794278921, 605774587042402052, 3412124567993221433], absorbed := 3 }
  , cursorAfter := { stateWords := [13816550690510729125, 18101985310251038407, 9608517073677775066, 2584218457954885402, 2407808902030683260, 13628125446280137751, 3448376294072599785, 4693705293099813145], absorbed := 0 }
  , challengeOutput := (some 13816550690510729125)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [13, 62, 18, 231, 159, 216, 74, 146, 123, 100, 48, 154, 55, 62, 243, 77, 247, 72, 183, 146, 55, 128, 226, 205, 79, 61, 249, 159, 174, 184, 114, 0])
  , u64s := []
  , cursorBefore := { stateWords := [13816550690510729125, 18101985310251038407, 9608517073677775066, 2584218457954885402, 2407808902030683260, 13628125446280137751, 3448376294072599785, 4693705293099813145], absorbed := 0 }
  , cursorAfter := { stateWords := [15642439619923443, 45028563024208512, 7518382, 8361902626686925691, 2225358803819603115, 9245944133697156672, 1336650474291237605, 4811421835623193385], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [187, 211, 69, 135, 229, 127, 64, 102, 85, 14, 246, 26, 208, 214, 247, 252, 184, 3, 119, 82, 89, 137, 101, 38, 31, 135, 97, 182, 171, 175, 16, 207])
  , u64s := []
  , cursorBefore := { stateWords := [15642439619923443, 45028563024208512, 7518382, 8361902626686925691, 2225358803819603115, 9245944133697156672, 1336650474291237605, 4811421835623193385], absorbed := 3 }
  , cursorAfter := { stateWords := [25141944044289271, 51335678732428681, 3473977259, 13731804578639336113, 10961016839209921425, 18130052512516982862, 4673728544040845705, 16203916050884902499], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [183, 99, 121, 135, 139, 0, 186, 237, 83, 70, 165, 225, 69, 94, 88, 23, 106, 225, 174, 203, 176, 128, 255, 252, 189, 21, 5, 237, 46, 123, 103, 80])
  , u64s := []
  , cursorBefore := { stateWords := [25141944044289271, 51335678732428681, 3473977259, 13731804578639336113, 10961016839209921425, 18130052512516982862, 4673728544040845705, 16203916050884902499], absorbed := 3 }
  , cursorAfter := { stateWords := [49763547867649880, 66715160420351872, 1348959022, 15709606489153929614, 8121674917799648079, 15710361591141068338, 9590642781091900839, 9242433929454591953], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [49763547867649880, 66715160420351872, 1348959022, 15709606489153929614, 8121674917799648079, 15710361591141068338, 9590642781091900839, 9242433929454591953], absorbed := 3 }
  , cursorAfter := { stateWords := [5089522495975454261, 1105680697028675754, 17663795333069901089, 8984707892722831397, 9570329054447077234, 10004337964861211153, 5155669186334908773, 10948998427876731888], absorbed := 0 }
  , challengeOutput := (some 5089522495975454261)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [5089522495975454261, 1105680697028675754, 17663795333069901089, 8984707892722831397, 9570329054447077234, 10004337964861211153, 5155669186334908773, 10948998427876731888], absorbed := 0 }
  , cursorAfter := { stateWords := [6705451615684752047, 259196052256607845, 13875982187815904043, 7900743909553083362, 7968206663224187973, 14127116662389960561, 13263370867764124287, 16247986710756250182], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [175, 114, 117, 171, 183, 140, 14, 93, 101, 78, 240, 173, 111, 217, 152, 3, 43, 35, 106, 30, 72, 100, 145, 192, 226, 19, 62, 206, 185, 20, 165, 109]))
}]
}
  , kernel := {
  root0Digest := (bytes [67, 149, 212, 203, 125, 6, 193, 148, 95, 242, 87, 131, 79, 199, 154, 105, 62, 65, 66, 99, 45, 14, 202, 150, 24, 19, 22, 127, 80, 126, 57, 58])
  , stage1Digest := (bytes [233, 196, 203, 200, 70, 58, 121, 64, 190, 77, 215, 109, 211, 207, 110, 212, 227, 39, 71, 54, 50, 7, 179, 37, 204, 185, 66, 14, 130, 114, 51, 240])
  , stage2Digest := (bytes [133, 91, 57, 33, 9, 81, 232, 147, 233, 248, 11, 52, 22, 187, 82, 147, 231, 35, 101, 212, 42, 7, 126, 94, 3, 54, 201, 128, 233, 222, 146, 92])
  , stage3Digest := (bytes [13, 62, 18, 231, 159, 216, 74, 146, 123, 100, 48, 154, 55, 62, 243, 77, 247, 72, 183, 146, 55, 128, 226, 205, 79, 61, 249, 159, 174, 184, 114, 0])
  , executionDigest := (bytes [187, 211, 69, 135, 229, 127, 64, 102, 85, 14, 246, 26, 208, 214, 247, 252, 184, 3, 119, 82, 89, 137, 101, 38, 31, 135, 97, 182, 171, 175, 16, 207])
  , finalStateDigest := (bytes [183, 99, 121, 135, 139, 0, 186, 237, 83, 70, 165, 225, 69, 94, 88, 23, 106, 225, 174, 203, 176, 128, 255, 252, 189, 21, 5, 237, 46, 123, 103, 80])
  , stage1Mix := 6021918011723055633
  , stage2RegMix := 12166816141915752516
  , stage2RamMix := 4582133116042247748
  , stage3ContinuityMix := 13816550690510729125
  , kernelFinalMix := 5089522495975454261
  , transcriptFinalDigest := (bytes [175, 114, 117, 171, 183, 140, 14, 93, 101, 78, 240, 173, 111, 217, 152, 3, 43, 35, 106, 30, 72, 100, 145, 192, 226, 19, 62, 206, 185, 20, 165, 109])
  , finalPc := 28
  , finalRegisters := [0, 18446744073709551615, 128, 18446744073709519103, 32895, 18446744071570424063, 2309737967, 0, 0, 0, 12288, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , finalMemory := [{ addr := 12288, value := 9920249032750366975 }]
  , halted := true
}
}
    , kernelProof := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "narrow_memory_load_extract_extend_ecall", fixtureId := "narrow_memory_load_extract_extend_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.narrowMemory, .controlFlow] }
  , executionDigest := (bytes [187, 211, 69, 135, 229, 127, 64, 102, 85, 14, 246, 26, 208, 214, 247, 252, 184, 3, 119, 82, 89, 137, 101, 38, 31, 135, 97, 182, 171, 175, 16, 207])
  , shape := { executionRowCount := 7, realRowCount := 7, effectRowCount := 7, commitRowCount := 7, digest := (bytes [36, 118, 223, 124, 248, 115, 52, 199, 198, 250, 25, 33, 218, 131, 247, 174, 126, 69, 105, 226, 74, 199, 244, 245, 142, 55, 128, 143, 190, 129, 55, 117]) }
  , digest := (bytes [86, 78, 49, 65, 94, 63, 99, 57, 236, 173, 117, 185, 233, 227, 96, 236, 240, 241, 56, 163, 8, 27, 20, 172, 76, 91, 3, 79, 142, 80, 144, 152])
}
  , stages := { summary := { stage1RowCount := 7, stage2RegisterReadCount := 6, stage2RegisterWriteCount := 6, stage2RamEventCount := 6, stage2TwistLinkCount := 7, stage3ContinuityCount := 7, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [13, 103, 5, 60, 171, 246, 186, 177, 139, 97, 5, 132, 102, 84, 58, 208, 250, 132, 196, 23, 6, 156, 134, 31, 139, 46, 24, 118, 84, 20, 145, 230]) }, digest := (bytes [122, 94, 1, 183, 131, 155, 12, 186, 101, 198, 192, 53, 132, 152, 30, 77, 246, 137, 62, 65, 199, 135, 82, 194, 84, 215, 126, 139, 196, 45, 52, 64]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [252, 175, 36, 55, 16, 39, 35, 65, 192, 33, 136, 127, 92, 37, 5, 83, 58, 102, 165, 202, 255, 157, 139, 172, 252, 2, 15, 208, 167, 198, 104, 16]), stage1Digest := (bytes [28, 198, 65, 235, 4, 107, 49, 175, 18, 110, 191, 155, 156, 19, 240, 191, 2, 113, 73, 38, 8, 215, 32, 192, 83, 250, 154, 167, 86, 35, 11, 39]), stage2Digest := (bytes [73, 18, 118, 218, 186, 72, 53, 121, 0, 64, 208, 199, 248, 10, 57, 52, 139, 208, 124, 252, 43, 145, 182, 89, 171, 169, 217, 161, 225, 45, 210, 159]), stage3Digest := (bytes [191, 231, 148, 196, 231, 32, 230, 244, 246, 105, 83, 164, 118, 60, 102, 72, 67, 56, 200, 185, 75, 228, 213, 186, 94, 157, 206, 182, 221, 166, 14, 83]), transcriptDigest := (bytes [175, 114, 117, 171, 183, 140, 14, 93, 101, 78, 240, 173, 111, 217, 152, 3, 43, 35, 106, 30, 72, 100, 145, 192, 226, 19, 62, 206, 185, 20, 165, 109]), executionDigest := (bytes [187, 211, 69, 135, 229, 127, 64, 102, 85, 14, 246, 26, 208, 214, 247, 252, 184, 3, 119, 82, 89, 137, 101, 38, 31, 135, 97, 182, 171, 175, 16, 207]), digest := (bytes [126, 39, 205, 171, 139, 230, 18, 144, 245, 239, 56, 160, 216, 130, 121, 191, 218, 21, 7, 220, 31, 214, 144, 245, 61, 214, 81, 63, 199, 124, 9, 16]) }, statementDigest := (bytes [216, 26, 238, 112, 223, 67, 174, 31, 136, 143, 156, 159, 231, 136, 90, 99, 74, 194, 221, 66, 220, 65, 159, 218, 151, 173, 22, 211, 219, 63, 189, 212]), proofDigest := (bytes [255, 32, 35, 85, 2, 248, 186, 92, 40, 149, 115, 30, 99, 171, 133, 241, 192, 32, 175, 129, 180, 46, 195, 254, 198, 27, 44, 190, 188, 119, 201, 217]), digest := (bytes [187, 50, 157, 181, 241, 79, 199, 205, 161, 23, 168, 61, 213, 19, 247, 236, 73, 137, 221, 22, 189, 207, 80, 10, 57, 202, 77, 165, 69, 151, 191, 138]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [94, 159, 169, 31, 25, 245, 184, 4, 46, 138, 109, 67, 182, 224, 199, 16, 153, 186, 190, 175, 225, 196, 202, 59, 226, 179, 27, 101, 188, 47, 165, 149]), stage1Digest := (bytes [242, 173, 96, 214, 78, 222, 28, 165, 129, 156, 193, 86, 68, 216, 118, 57, 97, 73, 225, 233, 152, 96, 17, 76, 85, 117, 101, 168, 162, 156, 168, 237]), stage2Digest := (bytes [117, 100, 103, 165, 37, 29, 92, 151, 19, 172, 62, 235, 204, 183, 18, 246, 119, 143, 55, 182, 59, 131, 149, 169, 204, 165, 111, 196, 201, 14, 96, 167]), stage3Digest := (bytes [21, 245, 157, 115, 126, 105, 209, 146, 6, 189, 145, 233, 254, 142, 227, 64, 172, 198, 139, 5, 185, 117, 230, 218, 60, 6, 163, 248, 78, 42, 113, 139]), digest := (bytes [148, 243, 99, 118, 217, 55, 232, 151, 71, 161, 71, 104, 198, 192, 233, 163, 242, 169, 39, 139, 237, 210, 69, 153, 88, 121, 0, 150, 128, 28, 0, 226]) }, digest := (bytes [159, 123, 197, 156, 14, 226, 241, 7, 33, 88, 247, 60, 170, 137, 188, 149, 66, 230, 86, 169, 192, 25, 109, 119, 38, 44, 37, 209, 169, 81, 180, 13]) }
  , kernelOpening := { openingDigest := (bytes [174, 215, 89, 16, 208, 92, 164, 214, 195, 135, 203, 234, 204, 218, 31, 142, 86, 82, 205, 149, 108, 240, 27, 186, 231, 60, 230, 45, 110, 162, 156, 232]), bindings := { claimDigest := (bytes [125, 215, 94, 215, 230, 158, 106, 144, 53, 21, 187, 48, 96, 238, 228, 131, 131, 235, 98, 201, 79, 252, 28, 204, 85, 44, 105, 21, 223, 210, 61, 61]), bindingsDigest := (bytes [172, 38, 119, 164, 63, 10, 208, 83, 254, 205, 64, 201, 219, 250, 218, 151, 248, 218, 166, 136, 128, 2, 176, 192, 120, 173, 199, 116, 104, 79, 83, 221]), preparedStepsDigest := (bytes [128, 244, 11, 88, 195, 150, 200, 124, 145, 196, 16, 43, 4, 66, 29, 221, 61, 201, 157, 185, 154, 35, 129, 178, 187, 121, 123, 200, 20, 148, 99, 91]), digest := (bytes [197, 157, 149, 152, 127, 208, 125, 59, 21, 71, 182, 70, 126, 77, 132, 169, 1, 62, 127, 92, 104, 162, 17, 40, 78, 11, 182, 23, 90, 156, 175, 210]) }, digest := (bytes [141, 146, 207, 140, 176, 146, 70, 236, 225, 112, 7, 92, 12, 245, 12, 82, 60, 62, 117, 190, 159, 12, 155, 34, 223, 223, 52, 134, 143, 244, 198, 230]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [87, 71, 197, 222, 145, 126, 134, 239, 226, 74, 253, 106, 28, 144, 235, 131, 31, 120, 247, 233, 88, 225, 201, 44, 4, 49, 185, 67, 38, 174, 63, 242]), terminal := { root0Digest := (bytes [67, 149, 212, 203, 125, 6, 193, 148, 95, 242, 87, 131, 79, 199, 154, 105, 62, 65, 66, 99, 45, 14, 202, 150, 24, 19, 22, 127, 80, 126, 57, 58]), executionDigest := (bytes [187, 211, 69, 135, 229, 127, 64, 102, 85, 14, 246, 26, 208, 214, 247, 252, 184, 3, 119, 82, 89, 137, 101, 38, 31, 135, 97, 182, 171, 175, 16, 207]), finalStateDigest := (bytes [183, 99, 121, 135, 139, 0, 186, 237, 83, 70, 165, 225, 69, 94, 88, 23, 106, 225, 174, 203, 176, 128, 255, 252, 189, 21, 5, 237, 46, 123, 103, 80]), transcriptFinalDigest := (bytes [175, 114, 117, 171, 183, 140, 14, 93, 101, 78, 240, 173, 111, 217, 152, 3, 43, 35, 106, 30, 72, 100, 145, 192, 226, 19, 62, 206, 185, 20, 165, 109]), finalPc := 28, halted := true, digest := (bytes [205, 254, 30, 56, 36, 192, 1, 150, 90, 196, 175, 20, 48, 150, 32, 137, 244, 105, 221, 101, 229, 178, 245, 230, 78, 102, 13, 208, 70, 39, 231, 127]) }, digest := (bytes [184, 187, 88, 120, 243, 102, 201, 103, 114, 10, 92, 102, 1, 66, 22, 53, 92, 115, 50, 97, 173, 40, 206, 140, 124, 30, 39, 199, 227, 153, 171, 6]) }, statementDigest := (bytes [41, 230, 229, 127, 113, 224, 169, 26, 193, 238, 157, 97, 181, 175, 228, 171, 145, 204, 91, 211, 167, 85, 181, 18, 209, 57, 194, 234, 102, 148, 104, 188]), proofDigest := (bytes [160, 158, 253, 248, 207, 31, 75, 5, 38, 216, 215, 163, 229, 200, 25, 23, 102, 76, 104, 4, 60, 225, 204, 6, 193, 32, 176, 46, 73, 79, 72, 72]), digest := (bytes [38, 10, 121, 0, 128, 196, 163, 184, 62, 57, 95, 43, 230, 234, 49, 198, 207, 48, 15, 204, 126, 59, 0, 243, 85, 229, 253, 153, 227, 87, 93, 121]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [70, 190, 119, 237, 36, 24, 10, 255, 89, 160, 80, 108, 23, 145, 105, 211, 62, 238, 219, 129, 146, 61, 176, 70, 36, 218, 198, 73, 69, 147, 187, 137]), layoutVersion := 1, digest := (bytes [223, 12, 232, 107, 103, 109, 239, 254, 232, 159, 134, 133, 162, 7, 6, 93, 43, 61, 94, 124, 24, 133, 145, 222, 17, 11, 39, 186, 227, 136, 222, 49]) }, rowWidth := 38, timeLen := 7, columnDigests := [(bytes [40, 243, 169, 246, 170, 121, 143, 48, 132, 183, 68, 213, 151, 130, 14, 65, 20, 212, 138, 236, 77, 112, 226, 150, 158, 109, 142, 75, 172, 115, 156, 234]), (bytes [183, 255, 181, 34, 203, 1, 222, 219, 152, 86, 144, 13, 74, 163, 20, 134, 40, 184, 20, 201, 107, 98, 76, 0, 125, 194, 18, 176, 16, 226, 102, 175]), (bytes [153, 111, 70, 176, 156, 174, 226, 182, 197, 190, 144, 153, 100, 226, 206, 209, 132, 162, 24, 222, 166, 233, 132, 102, 120, 151, 149, 92, 177, 154, 105, 134]), (bytes [188, 23, 179, 202, 216, 119, 253, 192, 107, 56, 140, 18, 247, 51, 234, 39, 235, 216, 134, 241, 7, 60, 104, 146, 182, 166, 45, 236, 214, 213, 211, 83]), (bytes [78, 156, 218, 132, 187, 128, 28, 175, 180, 45, 97, 45, 52, 94, 142, 189, 238, 235, 64, 164, 28, 129, 72, 154, 162, 227, 67, 115, 203, 223, 178, 142]), (bytes [51, 155, 54, 140, 69, 32, 98, 139, 131, 15, 88, 241, 40, 59, 194, 36, 19, 79, 79, 128, 83, 255, 244, 188, 114, 23, 227, 76, 101, 158, 176, 30]), (bytes [50, 117, 247, 44, 135, 251, 33, 130, 187, 149, 173, 15, 157, 44, 184, 232, 74, 29, 121, 15, 49, 15, 1, 170, 4, 57, 254, 21, 66, 20, 255, 57]), (bytes [2, 151, 98, 91, 97, 198, 16, 102, 234, 151, 132, 235, 230, 225, 56, 72, 84, 195, 243, 65, 52, 112, 148, 213, 95, 205, 136, 136, 88, 166, 193, 238]), (bytes [179, 197, 166, 238, 247, 39, 161, 56, 86, 33, 181, 194, 233, 28, 80, 101, 156, 182, 133, 82, 176, 76, 183, 86, 85, 15, 113, 247, 11, 149, 206, 77]), (bytes [128, 164, 14, 32, 252, 110, 116, 191, 114, 251, 127, 177, 36, 25, 157, 9, 231, 136, 149, 138, 208, 250, 23, 50, 252, 29, 12, 233, 140, 95, 8, 140]), (bytes [89, 22, 73, 8, 21, 226, 125, 65, 127, 59, 246, 65, 171, 105, 50, 132, 94, 238, 207, 204, 138, 37, 170, 12, 117, 47, 94, 106, 8, 120, 51, 34]), (bytes [67, 66, 11, 107, 7, 178, 186, 212, 181, 238, 54, 244, 195, 113, 149, 104, 106, 62, 123, 255, 19, 55, 230, 77, 191, 247, 179, 205, 153, 160, 181, 50]), (bytes [18, 172, 128, 176, 253, 198, 4, 93, 34, 80, 94, 154, 166, 81, 235, 21, 208, 214, 240, 19, 132, 26, 227, 255, 47, 232, 138, 242, 49, 178, 152, 151]), (bytes [201, 43, 191, 252, 118, 131, 37, 225, 38, 225, 69, 142, 36, 139, 96, 240, 17, 37, 223, 234, 119, 9, 228, 163, 114, 217, 233, 239, 233, 185, 185, 128]), (bytes [249, 205, 171, 26, 216, 243, 195, 221, 128, 60, 80, 144, 180, 172, 149, 4, 27, 137, 206, 13, 166, 2, 78, 155, 206, 226, 57, 188, 182, 101, 121, 146]), (bytes [44, 32, 216, 93, 16, 146, 0, 130, 207, 204, 36, 141, 166, 246, 232, 20, 247, 247, 116, 89, 62, 217, 122, 245, 142, 15, 143, 44, 219, 131, 183, 12]), (bytes [63, 55, 148, 202, 193, 201, 88, 153, 244, 174, 145, 10, 157, 92, 137, 79, 24, 240, 86, 214, 120, 193, 105, 254, 83, 207, 7, 36, 175, 251, 198, 209]), (bytes [49, 184, 142, 166, 178, 93, 15, 133, 19, 3, 245, 149, 190, 250, 17, 77, 195, 143, 141, 153, 122, 25, 168, 96, 127, 182, 178, 210, 211, 3, 144, 60]), (bytes [86, 196, 110, 116, 66, 242, 23, 243, 102, 32, 103, 253, 30, 136, 67, 166, 214, 221, 241, 169, 190, 115, 51, 189, 2, 90, 50, 65, 2, 198, 240, 74]), (bytes [40, 190, 66, 17, 225, 194, 79, 155, 132, 37, 100, 66, 38, 252, 86, 198, 130, 181, 255, 44, 150, 162, 100, 158, 217, 251, 29, 121, 236, 9, 180, 205]), (bytes [254, 19, 232, 192, 11, 39, 102, 229, 212, 95, 179, 72, 76, 113, 31, 113, 119, 17, 192, 125, 69, 105, 89, 144, 235, 22, 196, 55, 37, 148, 98, 206]), (bytes [162, 220, 83, 150, 211, 225, 255, 88, 142, 249, 241, 103, 91, 83, 182, 68, 224, 210, 129, 244, 152, 190, 182, 178, 247, 142, 200, 54, 61, 197, 59, 136]), (bytes [157, 243, 246, 1, 231, 124, 63, 187, 113, 83, 135, 59, 185, 176, 92, 154, 19, 95, 23, 144, 39, 18, 116, 243, 148, 33, 40, 76, 72, 135, 179, 217]), (bytes [215, 235, 228, 195, 126, 67, 73, 117, 240, 48, 198, 153, 149, 10, 116, 211, 229, 187, 72, 167, 138, 70, 233, 6, 198, 196, 67, 132, 227, 126, 249, 237]), (bytes [155, 46, 222, 79, 160, 132, 118, 83, 92, 71, 119, 54, 198, 8, 141, 171, 147, 66, 60, 77, 68, 15, 109, 158, 26, 159, 53, 144, 233, 162, 202, 146]), (bytes [183, 229, 214, 38, 2, 127, 216, 184, 77, 254, 138, 78, 137, 131, 89, 214, 211, 90, 100, 35, 45, 51, 180, 50, 190, 176, 83, 112, 101, 23, 181, 170]), (bytes [121, 173, 212, 206, 43, 62, 110, 188, 123, 202, 190, 163, 124, 203, 14, 8, 205, 10, 134, 22, 77, 113, 110, 162, 179, 102, 146, 84, 172, 188, 144, 247]), (bytes [134, 43, 219, 6, 234, 143, 97, 163, 132, 117, 241, 141, 98, 196, 41, 77, 3, 224, 76, 14, 112, 49, 93, 186, 30, 158, 156, 221, 192, 147, 18, 53]), (bytes [150, 176, 216, 226, 239, 79, 218, 77, 47, 25, 98, 54, 47, 52, 197, 168, 30, 126, 93, 34, 149, 210, 8, 114, 248, 27, 12, 14, 147, 154, 204, 250]), (bytes [83, 251, 49, 48, 54, 174, 206, 33, 38, 55, 53, 86, 238, 134, 67, 140, 194, 44, 73, 155, 93, 189, 217, 191, 38, 87, 214, 184, 137, 68, 230, 167]), (bytes [240, 212, 182, 90, 28, 28, 194, 255, 94, 159, 35, 103, 91, 242, 214, 20, 102, 217, 67, 85, 43, 252, 11, 32, 160, 11, 241, 164, 190, 14, 75, 153]), (bytes [83, 203, 23, 43, 120, 2, 138, 179, 201, 101, 117, 199, 249, 119, 150, 189, 107, 206, 100, 240, 241, 191, 29, 12, 95, 189, 46, 162, 173, 67, 52, 64]), (bytes [243, 18, 112, 16, 115, 206, 161, 217, 70, 120, 53, 168, 21, 217, 125, 177, 15, 184, 39, 220, 129, 252, 253, 217, 143, 169, 231, 204, 197, 173, 74, 44]), (bytes [174, 205, 154, 64, 243, 198, 70, 67, 132, 170, 211, 195, 186, 11, 96, 55, 55, 6, 248, 130, 169, 186, 214, 86, 104, 198, 34, 111, 234, 42, 133, 117]), (bytes [80, 237, 204, 122, 194, 130, 220, 252, 3, 111, 197, 112, 201, 6, 39, 55, 107, 14, 41, 172, 114, 110, 188, 233, 86, 120, 251, 235, 230, 110, 137, 34]), (bytes [64, 184, 77, 60, 124, 164, 54, 93, 23, 121, 89, 235, 81, 60, 107, 51, 86, 73, 18, 40, 80, 16, 45, 151, 39, 61, 175, 64, 40, 48, 21, 239]), (bytes [12, 243, 124, 85, 184, 138, 62, 99, 176, 174, 57, 188, 133, 173, 127, 231, 9, 202, 235, 153, 59, 220, 215, 127, 240, 138, 226, 158, 18, 89, 217, 143]), (bytes [145, 99, 191, 35, 121, 90, 118, 57, 187, 82, 200, 99, 201, 117, 132, 16, 109, 95, 126, 62, 89, 129, 183, 210, 46, 8, 148, 208, 73, 204, 191, 238])], familyDigest := (bytes [70, 190, 119, 237, 36, 24, 10, 255, 89, 160, 80, 108, 23, 145, 105, 211, 62, 238, 219, 129, 146, 61, 176, 70, 36, 218, 198, 73, 69, 147, 187, 137]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [70, 190, 119, 237, 36, 24, 10, 255, 89, 160, 80, 108, 23, 145, 105, 211, 62, 238, 219, 129, 146, 61, 176, 70, 36, 218, 198, 73, 69, 147, 187, 137]), layoutVersion := 1, digest := (bytes [223, 12, 232, 107, 103, 109, 239, 254, 232, 159, 134, 133, 162, 7, 6, 93, 43, 61, 94, 124, 24, 133, 145, 222, 17, 11, 39, 186, 227, 136, 222, 49]) }, logicalIndex := 0, digest := (bytes [181, 209, 216, 196, 249, 234, 132, 147, 93, 249, 188, 78, 137, 39, 111, 159, 36, 223, 189, 242, 193, 195, 223, 81, 244, 157, 13, 96, 136, 118, 229, 69]) }, valueDigest := (bytes [129, 16, 11, 76, 253, 155, 142, 28, 89, 240, 19, 169, 171, 115, 101, 224, 73, 120, 86, 195, 27, 185, 106, 175, 64, 231, 190, 170, 187, 57, 144, 129]), digest := (bytes [50, 238, 42, 133, 107, 34, 54, 70, 10, 53, 197, 4, 106, 27, 119, 32, 0, 4, 236, 119, 96, 117, 207, 30, 209, 141, 155, 246, 5, 255, 61, 231]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [70, 190, 119, 237, 36, 24, 10, 255, 89, 160, 80, 108, 23, 145, 105, 211, 62, 238, 219, 129, 146, 61, 176, 70, 36, 218, 198, 73, 69, 147, 187, 137]), layoutVersion := 1, digest := (bytes [223, 12, 232, 107, 103, 109, 239, 254, 232, 159, 134, 133, 162, 7, 6, 93, 43, 61, 94, 124, 24, 133, 145, 222, 17, 11, 39, 186, 227, 136, 222, 49]) }, logicalIndex := 6, digest := (bytes [179, 55, 245, 26, 249, 15, 28, 32, 239, 95, 29, 215, 250, 6, 235, 143, 12, 253, 38, 245, 111, 6, 153, 38, 208, 180, 243, 114, 202, 234, 176, 118]) }, valueDigest := (bytes [57, 167, 127, 66, 29, 28, 1, 62, 111, 174, 45, 82, 212, 157, 25, 154, 254, 72, 204, 85, 223, 7, 138, 44, 48, 11, 222, 83, 122, 239, 183, 120]), digest := (bytes [2, 131, 66, 126, 27, 244, 0, 68, 253, 150, 147, 11, 191, 45, 95, 27, 113, 76, 223, 152, 32, 11, 185, 143, 34, 76, 74, 206, 33, 197, 20, 254]) }), digest := (bytes [37, 8, 78, 14, 146, 205, 65, 159, 184, 239, 247, 118, 54, 105, 79, 220, 185, 208, 0, 155, 34, 183, 214, 251, 219, 121, 128, 94, 200, 126, 158, 249]) }
  , rootLaneCommitment := { timeLen := 7, commitments := { commitmentCount := 38, digest := (bytes [242, 91, 154, 59, 179, 31, 205, 226, 106, 197, 36, 140, 227, 67, 214, 106, 172, 86, 15, 141, 54, 207, 214, 226, 236, 63, 189, 77, 236, 136, 221, 41]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [242, 91, 154, 59, 179, 31, 205, 226, 106, 197, 36, 140, 227, 67, 214, 106, 172, 86, 15, 141, 54, 207, 214, 226, 236, 63, 189, 77, 236, 136, 221, 41]), layoutVersion := 3, digest := (bytes [196, 194, 83, 41, 254, 85, 154, 3, 27, 133, 154, 198, 75, 41, 176, 38, 251, 138, 26, 245, 43, 23, 149, 221, 37, 126, 131, 135, 61, 219, 245, 126]) }, logicalIndex := 0, digest := (bytes [18, 182, 151, 108, 176, 139, 62, 254, 180, 178, 194, 184, 131, 85, 158, 49, 199, 77, 210, 40, 135, 44, 158, 184, 74, 173, 44, 24, 177, 94, 55, 54]) }, valueDigest := (bytes [129, 16, 11, 76, 253, 155, 142, 28, 89, 240, 19, 169, 171, 115, 101, 224, 73, 120, 86, 195, 27, 185, 106, 175, 64, 231, 190, 170, 187, 57, 144, 129]), digest := (bytes [172, 1, 44, 77, 105, 92, 145, 74, 215, 231, 41, 237, 112, 208, 85, 46, 7, 45, 204, 78, 158, 105, 59, 123, 2, 171, 181, 78, 110, 138, 150, 6]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [242, 91, 154, 59, 179, 31, 205, 226, 106, 197, 36, 140, 227, 67, 214, 106, 172, 86, 15, 141, 54, 207, 214, 226, 236, 63, 189, 77, 236, 136, 221, 41]), layoutVersion := 3, digest := (bytes [196, 194, 83, 41, 254, 85, 154, 3, 27, 133, 154, 198, 75, 41, 176, 38, 251, 138, 26, 245, 43, 23, 149, 221, 37, 126, 131, 135, 61, 219, 245, 126]) }, logicalIndex := 6, digest := (bytes [10, 223, 129, 108, 227, 203, 154, 145, 141, 129, 215, 247, 157, 208, 180, 255, 202, 36, 10, 231, 89, 215, 159, 81, 120, 177, 99, 161, 55, 22, 112, 57]) }, valueDigest := (bytes [57, 167, 127, 66, 29, 28, 1, 62, 111, 174, 45, 82, 212, 157, 25, 154, 254, 72, 204, 85, 223, 7, 138, 44, 48, 11, 222, 83, 122, 239, 183, 120]), digest := (bytes [92, 219, 197, 231, 121, 26, 25, 227, 146, 19, 85, 137, 42, 97, 157, 106, 111, 249, 53, 54, 34, 115, 103, 115, 189, 185, 106, 22, 129, 42, 59, 71]) }), digest := (bytes [84, 208, 93, 185, 245, 39, 103, 192, 242, 100, 29, 19, 49, 87, 23, 220, 246, 252, 36, 11, 90, 91, 215, 1, 154, 23, 178, 107, 196, 135, 122, 112]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [37, 8, 78, 14, 146, 205, 65, 159, 184, 239, 247, 118, 54, 105, 79, 220, 185, 208, 0, 155, 34, 183, 214, 251, 219, 121, 128, 94, 200, 126, 158, 249]), rootLaneCommitmentDigest := (bytes [84, 208, 93, 185, 245, 39, 103, 192, 242, 100, 29, 19, 49, 87, 23, 220, 246, 252, 36, 11, 90, 91, 215, 1, 154, 23, 178, 107, 196, 135, 122, 112]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 7, digest := (bytes [217, 193, 32, 88, 183, 117, 187, 140, 85, 37, 144, 64, 64, 78, 9, 138, 114, 53, 75, 81, 119, 141, 235, 113, 84, 219, 104, 242, 125, 236, 59, 214]) }, statementDigest := (bytes [177, 220, 4, 67, 98, 192, 66, 110, 152, 145, 91, 155, 208, 155, 27, 227, 143, 244, 99, 43, 231, 16, 238, 72, 148, 55, 185, 189, 126, 164, 42, 76]), proofDigest := (bytes [166, 125, 197, 254, 250, 227, 216, 35, 70, 138, 144, 252, 36, 213, 196, 70, 147, 222, 207, 251, 149, 2, 79, 84, 23, 13, 145, 183, 128, 167, 96, 75]), digest := (bytes [147, 223, 38, 91, 91, 170, 19, 43, 67, 11, 53, 229, 189, 7, 194, 217, 136, 136, 124, 129, 140, 43, 14, 0, 118, 11, 65, 35, 152, 217, 42, 130]) }
  , digest := (bytes [128, 232, 234, 130, 162, 99, 245, 11, 117, 140, 17, 237, 240, 121, 40, 103, 216, 30, 129, 106, 141, 52, 147, 240, 241, 18, 212, 169, 151, 1, 239, 151])
}
    , exportedProof := {
  claim := {
  accepted := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , statement := { proofStatementDigest := (bytes [9, 26, 47, 110, 120, 237, 66, 220, 196, 116, 214, 65, 240, 120, 175, 24, 254, 10, 155, 184, 219, 117, 77, 9, 99, 37, 45, 97, 31, 34, 96, 26]), kernelOpeningDigest := (bytes [141, 146, 207, 140, 176, 146, 70, 236, 225, 112, 7, 92, 12, 245, 12, 82, 60, 62, 117, 190, 159, 12, 155, 34, 223, 223, 52, 134, 143, 244, 198, 230]), digest := (bytes [150, 30, 177, 116, 125, 20, 242, 54, 30, 252, 74, 183, 26, 20, 68, 170, 154, 65, 63, 223, 244, 12, 4, 133, 16, 7, 224, 125, 51, 113, 161, 124]) }
  , mainLane := { mainLaneBundleDigest := (bytes [147, 223, 38, 91, 91, 170, 19, 43, 67, 11, 53, 229, 189, 7, 194, 217, 136, 136, 124, 129, 140, 43, 14, 0, 118, 11, 65, 35, 152, 217, 42, 130]), digest := (bytes [147, 177, 245, 247, 119, 107, 75, 243, 229, 68, 178, 238, 29, 226, 64, 78, 39, 205, 237, 60, 37, 241, 254, 69, 145, 234, 120, 190, 131, 189, 153, 138]) }
  , terminal := { finalStateDigest := (bytes [183, 99, 121, 135, 139, 0, 186, 237, 83, 70, 165, 225, 69, 94, 88, 23, 106, 225, 174, 203, 176, 128, 255, 252, 189, 21, 5, 237, 46, 123, 103, 80]), finalPc := 28, halted := true, digest := (bytes [205, 138, 253, 137, 65, 200, 120, 143, 138, 62, 28, 126, 73, 47, 246, 171, 246, 128, 191, 30, 83, 68, 128, 28, 212, 244, 166, 182, 126, 121, 249, 68]) }
  , digest := (bytes [156, 120, 39, 215, 81, 48, 234, 114, 72, 75, 244, 93, 196, 6, 128, 50, 50, 169, 92, 117, 164, 125, 86, 69, 252, 34, 231, 70, 6, 159, 166, 200])
}
  , mainLane := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { mainLaneBundleDigest := (bytes [147, 223, 38, 91, 91, 170, 19, 43, 67, 11, 53, 229, 189, 7, 194, 217, 136, 136, 124, 129, 140, 43, 14, 0, 118, 11, 65, 35, 152, 217, 42, 130]), digest := (bytes [255, 126, 21, 166, 110, 107, 195, 7, 240, 125, 197, 158, 205, 75, 41, 53, 93, 222, 22, 105, 230, 248, 213, 167, 43, 198, 16, 213, 103, 121, 143, 82]) }, digest := (bytes [207, 93, 32, 13, 143, 104, 149, 211, 24, 35, 131, 142, 225, 161, 219, 138, 235, 171, 15, 171, 103, 31, 204, 190, 155, 14, 91, 120, 215, 180, 109, 117]) }
  , opening := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , stages := { stageClaimsDigest := (bytes [187, 50, 157, 181, 241, 79, 199, 205, 161, 23, 168, 61, 213, 19, 247, 236, 73, 137, 221, 22, 189, 207, 80, 10, 57, 202, 77, 165, 69, 151, 191, 138]), stagePackagesDigest := (bytes [159, 123, 197, 156, 14, 226, 241, 7, 33, 88, 247, 60, 170, 137, 188, 149, 66, 230, 86, 169, 192, 25, 109, 119, 38, 44, 37, 209, 169, 81, 180, 13]), kernelOpeningDigest := (bytes [141, 146, 207, 140, 176, 146, 70, 236, 225, 112, 7, 92, 12, 245, 12, 82, 60, 62, 117, 190, 159, 12, 155, 34, 223, 223, 52, 134, 143, 244, 198, 230]), digest := (bytes [251, 156, 34, 223, 190, 40, 61, 46, 104, 169, 174, 154, 215, 200, 34, 239, 142, 150, 120, 203, 8, 224, 14, 146, 135, 99, 17, 6, 195, 166, 109, 41]) }
  , terminal := { preparedStepBindingsDigest := (bytes [87, 71, 197, 222, 145, 126, 134, 239, 226, 74, 253, 106, 28, 144, 235, 131, 31, 120, 247, 233, 88, 225, 201, 44, 4, 49, 185, 67, 38, 174, 63, 242]), executionDigest := (bytes [187, 211, 69, 135, 229, 127, 64, 102, 85, 14, 246, 26, 208, 214, 247, 252, 184, 3, 119, 82, 89, 137, 101, 38, 31, 135, 97, 182, 171, 175, 16, 207]), transcriptFinalDigest := (bytes [175, 114, 117, 171, 183, 140, 14, 93, 101, 78, 240, 173, 111, 217, 152, 3, 43, 35, 106, 30, 72, 100, 145, 192, 226, 19, 62, 206, 185, 20, 165, 109]), digest := (bytes [211, 44, 76, 38, 148, 24, 179, 111, 92, 121, 159, 201, 175, 154, 46, 219, 82, 71, 181, 188, 11, 252, 118, 65, 242, 183, 6, 158, 126, 181, 201, 136]) }
  , digest := (bytes [255, 214, 134, 89, 136, 66, 25, 9, 227, 251, 220, 230, 255, 69, 207, 171, 155, 207, 167, 75, 133, 109, 63, 69, 41, 89, 98, 89, 19, 32, 43, 142])
}
  , jointOpening := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { proofStatementDigest := (bytes [9, 26, 47, 110, 120, 237, 66, 220, 196, 116, 214, 65, 240, 120, 175, 24, 254, 10, 155, 184, 219, 117, 77, 9, 99, 37, 45, 97, 31, 34, 96, 26]), mainLaneClaimDigest := (bytes [207, 93, 32, 13, 143, 104, 149, 211, 24, 35, 131, 142, 225, 161, 219, 138, 235, 171, 15, 171, 103, 31, 204, 190, 155, 14, 91, 120, 215, 180, 109, 117]), kernelOpeningClaimDigest := (bytes [255, 214, 134, 89, 136, 66, 25, 9, 227, 251, 220, 230, 255, 69, 207, 171, 155, 207, 167, 75, 133, 109, 63, 69, 41, 89, 98, 89, 19, 32, 43, 142]), digest := (bytes [111, 82, 78, 62, 181, 82, 166, 232, 158, 123, 144, 119, 135, 3, 239, 126, 250, 71, 252, 78, 54, 107, 79, 10, 29, 147, 0, 77, 67, 165, 16, 156]) }, digest := (bytes [191, 148, 46, 158, 202, 212, 217, 245, 2, 236, 252, 186, 110, 87, 62, 95, 117, 252, 137, 187, 49, 152, 95, 154, 95, 75, 22, 5, 68, 145, 187, 72]) }
  , root0 := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), stages := { stage1Digest := (bytes [233, 196, 203, 200, 70, 58, 121, 64, 190, 77, 215, 109, 211, 207, 110, 212, 227, 39, 71, 54, 50, 7, 179, 37, 204, 185, 66, 14, 130, 114, 51, 240]), stage2Digest := (bytes [133, 91, 57, 33, 9, 81, 232, 147, 233, 248, 11, 52, 22, 187, 82, 147, 231, 35, 101, 212, 42, 7, 126, 94, 3, 54, 201, 128, 233, 222, 146, 92]), stage3Digest := (bytes [13, 62, 18, 231, 159, 216, 74, 146, 123, 100, 48, 154, 55, 62, 243, 77, 247, 72, 183, 146, 55, 128, 226, 205, 79, 61, 249, 159, 174, 184, 114, 0]), digest := (bytes [45, 86, 90, 69, 182, 192, 236, 132, 159, 153, 254, 191, 253, 67, 122, 245, 66, 226, 40, 198, 206, 149, 109, 102, 146, 184, 164, 196, 126, 113, 146, 6]) }, terminal := { root0Digest := (bytes [67, 149, 212, 203, 125, 6, 193, 148, 95, 242, 87, 131, 79, 199, 154, 105, 62, 65, 66, 99, 45, 14, 202, 150, 24, 19, 22, 127, 80, 126, 57, 58]), executionDigest := (bytes [187, 211, 69, 135, 229, 127, 64, 102, 85, 14, 246, 26, 208, 214, 247, 252, 184, 3, 119, 82, 89, 137, 101, 38, 31, 135, 97, 182, 171, 175, 16, 207]), finalStateDigest := (bytes [183, 99, 121, 135, 139, 0, 186, 237, 83, 70, 165, 225, 69, 94, 88, 23, 106, 225, 174, 203, 176, 128, 255, 252, 189, 21, 5, 237, 46, 123, 103, 80]), transcriptFinalDigest := (bytes [175, 114, 117, 171, 183, 140, 14, 93, 101, 78, 240, 173, 111, 217, 152, 3, 43, 35, 106, 30, 72, 100, 145, 192, 226, 19, 62, 206, 185, 20, 165, 109]), digest := (bytes [30, 17, 202, 223, 244, 223, 240, 246, 28, 229, 241, 158, 198, 72, 84, 89, 115, 29, 122, 118, 45, 98, 42, 37, 140, 148, 206, 122, 239, 29, 210, 172]) }, digest := (bytes [192, 239, 89, 135, 38, 141, 227, 96, 149, 138, 107, 247, 134, 149, 232, 90, 124, 47, 230, 185, 60, 239, 200, 35, 224, 39, 126, 219, 255, 175, 18, 123]) }
  , digest := (bytes [19, 11, 93, 73, 94, 168, 72, 222, 152, 6, 180, 17, 72, 48, 109, 139, 122, 3, 159, 35, 123, 12, 117, 118, 60, 92, 14, 116, 210, 146, 121, 27])
}
  , statement := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , foldSchedule := Nightstream.FoldSchedule.wholeTrace
  , chunkCount := 1
  , stageClaimsDigest := (bytes [187, 50, 157, 181, 241, 79, 199, 205, 161, 23, 168, 61, 213, 19, 247, 236, 73, 137, 221, 22, 189, 207, 80, 10, 57, 202, 77, 165, 69, 151, 191, 138])
  , stagePackagesDigest := (bytes [159, 123, 197, 156, 14, 226, 241, 7, 33, 88, 247, 60, 170, 137, 188, 149, 66, 230, 86, 169, 192, 25, 109, 119, 38, 44, 37, 209, 169, 81, 180, 13])
  , kernelOpeningDigest := (bytes [141, 146, 207, 140, 176, 146, 70, 236, 225, 112, 7, 92, 12, 245, 12, 82, 60, 62, 117, 190, 159, 12, 155, 34, 223, 223, 52, 134, 143, 244, 198, 230])
  , preparedStepBindingsDigest := (bytes [87, 71, 197, 222, 145, 126, 134, 239, 226, 74, 253, 106, 28, 144, 235, 131, 31, 120, 247, 233, 88, 225, 201, 44, 4, 49, 185, 67, 38, 174, 63, 242])
  , executionDigest := (bytes [187, 211, 69, 135, 229, 127, 64, 102, 85, 14, 246, 26, 208, 214, 247, 252, 184, 3, 119, 82, 89, 137, 101, 38, 31, 135, 97, 182, 171, 175, 16, 207])
  , finalStateDigest := (bytes [183, 99, 121, 135, 139, 0, 186, 237, 83, 70, 165, 225, 69, 94, 88, 23, 106, 225, 174, 203, 176, 128, 255, 252, 189, 21, 5, 237, 46, 123, 103, 80])
  , transcriptFinalDigest := (bytes [175, 114, 117, 171, 183, 140, 14, 93, 101, 78, 240, 173, 111, 217, 152, 3, 43, 35, 106, 30, 72, 100, 145, 192, 226, 19, 62, 206, 185, 20, 165, 109])
  , mainLaneSurfaceDigest := (bytes [193, 57, 83, 164, 60, 80, 135, 119, 159, 30, 14, 93, 91, 166, 106, 111, 192, 102, 228, 113, 243, 240, 152, 41, 122, 245, 207, 64, 61, 77, 55, 210])
  , rootLaneColumnsDigest := (bytes [37, 8, 78, 14, 146, 205, 65, 159, 184, 239, 247, 118, 54, 105, 79, 220, 185, 208, 0, 155, 34, 183, 214, 251, 219, 121, 128, 94, 200, 126, 158, 249])
  , publicStepCount := 7
  , initialPc := 0
  , finalPc := 28
  , halted := true
  , digest := (bytes [9, 26, 47, 110, 120, 237, 66, 220, 196, 116, 214, 65, 240, 120, 175, 24, 254, 10, 155, 184, 219, 117, 77, 9, 99, 37, 45, 97, 31, 34, 96, 26])
}
  , kernel := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "narrow_memory_load_extract_extend_ecall", fixtureId := "narrow_memory_load_extract_extend_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.narrowMemory, .controlFlow] }
  , executionDigest := (bytes [187, 211, 69, 135, 229, 127, 64, 102, 85, 14, 246, 26, 208, 214, 247, 252, 184, 3, 119, 82, 89, 137, 101, 38, 31, 135, 97, 182, 171, 175, 16, 207])
  , shape := { executionRowCount := 7, realRowCount := 7, effectRowCount := 7, commitRowCount := 7, digest := (bytes [36, 118, 223, 124, 248, 115, 52, 199, 198, 250, 25, 33, 218, 131, 247, 174, 126, 69, 105, 226, 74, 199, 244, 245, 142, 55, 128, 143, 190, 129, 55, 117]) }
  , digest := (bytes [86, 78, 49, 65, 94, 63, 99, 57, 236, 173, 117, 185, 233, 227, 96, 236, 240, 241, 56, 163, 8, 27, 20, 172, 76, 91, 3, 79, 142, 80, 144, 152])
}
  , stages := { summary := { stage1RowCount := 7, stage2RegisterReadCount := 6, stage2RegisterWriteCount := 6, stage2RamEventCount := 6, stage2TwistLinkCount := 7, stage3ContinuityCount := 7, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [13, 103, 5, 60, 171, 246, 186, 177, 139, 97, 5, 132, 102, 84, 58, 208, 250, 132, 196, 23, 6, 156, 134, 31, 139, 46, 24, 118, 84, 20, 145, 230]) }, digest := (bytes [122, 94, 1, 183, 131, 155, 12, 186, 101, 198, 192, 53, 132, 152, 30, 77, 246, 137, 62, 65, 199, 135, 82, 194, 84, 215, 126, 139, 196, 45, 52, 64]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [252, 175, 36, 55, 16, 39, 35, 65, 192, 33, 136, 127, 92, 37, 5, 83, 58, 102, 165, 202, 255, 157, 139, 172, 252, 2, 15, 208, 167, 198, 104, 16]), stage1Digest := (bytes [28, 198, 65, 235, 4, 107, 49, 175, 18, 110, 191, 155, 156, 19, 240, 191, 2, 113, 73, 38, 8, 215, 32, 192, 83, 250, 154, 167, 86, 35, 11, 39]), stage2Digest := (bytes [73, 18, 118, 218, 186, 72, 53, 121, 0, 64, 208, 199, 248, 10, 57, 52, 139, 208, 124, 252, 43, 145, 182, 89, 171, 169, 217, 161, 225, 45, 210, 159]), stage3Digest := (bytes [191, 231, 148, 196, 231, 32, 230, 244, 246, 105, 83, 164, 118, 60, 102, 72, 67, 56, 200, 185, 75, 228, 213, 186, 94, 157, 206, 182, 221, 166, 14, 83]), transcriptDigest := (bytes [175, 114, 117, 171, 183, 140, 14, 93, 101, 78, 240, 173, 111, 217, 152, 3, 43, 35, 106, 30, 72, 100, 145, 192, 226, 19, 62, 206, 185, 20, 165, 109]), executionDigest := (bytes [187, 211, 69, 135, 229, 127, 64, 102, 85, 14, 246, 26, 208, 214, 247, 252, 184, 3, 119, 82, 89, 137, 101, 38, 31, 135, 97, 182, 171, 175, 16, 207]), digest := (bytes [126, 39, 205, 171, 139, 230, 18, 144, 245, 239, 56, 160, 216, 130, 121, 191, 218, 21, 7, 220, 31, 214, 144, 245, 61, 214, 81, 63, 199, 124, 9, 16]) }, statementDigest := (bytes [216, 26, 238, 112, 223, 67, 174, 31, 136, 143, 156, 159, 231, 136, 90, 99, 74, 194, 221, 66, 220, 65, 159, 218, 151, 173, 22, 211, 219, 63, 189, 212]), proofDigest := (bytes [255, 32, 35, 85, 2, 248, 186, 92, 40, 149, 115, 30, 99, 171, 133, 241, 192, 32, 175, 129, 180, 46, 195, 254, 198, 27, 44, 190, 188, 119, 201, 217]), digest := (bytes [187, 50, 157, 181, 241, 79, 199, 205, 161, 23, 168, 61, 213, 19, 247, 236, 73, 137, 221, 22, 189, 207, 80, 10, 57, 202, 77, 165, 69, 151, 191, 138]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [94, 159, 169, 31, 25, 245, 184, 4, 46, 138, 109, 67, 182, 224, 199, 16, 153, 186, 190, 175, 225, 196, 202, 59, 226, 179, 27, 101, 188, 47, 165, 149]), stage1Digest := (bytes [242, 173, 96, 214, 78, 222, 28, 165, 129, 156, 193, 86, 68, 216, 118, 57, 97, 73, 225, 233, 152, 96, 17, 76, 85, 117, 101, 168, 162, 156, 168, 237]), stage2Digest := (bytes [117, 100, 103, 165, 37, 29, 92, 151, 19, 172, 62, 235, 204, 183, 18, 246, 119, 143, 55, 182, 59, 131, 149, 169, 204, 165, 111, 196, 201, 14, 96, 167]), stage3Digest := (bytes [21, 245, 157, 115, 126, 105, 209, 146, 6, 189, 145, 233, 254, 142, 227, 64, 172, 198, 139, 5, 185, 117, 230, 218, 60, 6, 163, 248, 78, 42, 113, 139]), digest := (bytes [148, 243, 99, 118, 217, 55, 232, 151, 71, 161, 71, 104, 198, 192, 233, 163, 242, 169, 39, 139, 237, 210, 69, 153, 88, 121, 0, 150, 128, 28, 0, 226]) }, digest := (bytes [159, 123, 197, 156, 14, 226, 241, 7, 33, 88, 247, 60, 170, 137, 188, 149, 66, 230, 86, 169, 192, 25, 109, 119, 38, 44, 37, 209, 169, 81, 180, 13]) }
  , kernelOpening := { openingDigest := (bytes [174, 215, 89, 16, 208, 92, 164, 214, 195, 135, 203, 234, 204, 218, 31, 142, 86, 82, 205, 149, 108, 240, 27, 186, 231, 60, 230, 45, 110, 162, 156, 232]), bindings := { claimDigest := (bytes [125, 215, 94, 215, 230, 158, 106, 144, 53, 21, 187, 48, 96, 238, 228, 131, 131, 235, 98, 201, 79, 252, 28, 204, 85, 44, 105, 21, 223, 210, 61, 61]), bindingsDigest := (bytes [172, 38, 119, 164, 63, 10, 208, 83, 254, 205, 64, 201, 219, 250, 218, 151, 248, 218, 166, 136, 128, 2, 176, 192, 120, 173, 199, 116, 104, 79, 83, 221]), preparedStepsDigest := (bytes [128, 244, 11, 88, 195, 150, 200, 124, 145, 196, 16, 43, 4, 66, 29, 221, 61, 201, 157, 185, 154, 35, 129, 178, 187, 121, 123, 200, 20, 148, 99, 91]), digest := (bytes [197, 157, 149, 152, 127, 208, 125, 59, 21, 71, 182, 70, 126, 77, 132, 169, 1, 62, 127, 92, 104, 162, 17, 40, 78, 11, 182, 23, 90, 156, 175, 210]) }, digest := (bytes [141, 146, 207, 140, 176, 146, 70, 236, 225, 112, 7, 92, 12, 245, 12, 82, 60, 62, 117, 190, 159, 12, 155, 34, 223, 223, 52, 134, 143, 244, 198, 230]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [87, 71, 197, 222, 145, 126, 134, 239, 226, 74, 253, 106, 28, 144, 235, 131, 31, 120, 247, 233, 88, 225, 201, 44, 4, 49, 185, 67, 38, 174, 63, 242]), terminal := { root0Digest := (bytes [67, 149, 212, 203, 125, 6, 193, 148, 95, 242, 87, 131, 79, 199, 154, 105, 62, 65, 66, 99, 45, 14, 202, 150, 24, 19, 22, 127, 80, 126, 57, 58]), executionDigest := (bytes [187, 211, 69, 135, 229, 127, 64, 102, 85, 14, 246, 26, 208, 214, 247, 252, 184, 3, 119, 82, 89, 137, 101, 38, 31, 135, 97, 182, 171, 175, 16, 207]), finalStateDigest := (bytes [183, 99, 121, 135, 139, 0, 186, 237, 83, 70, 165, 225, 69, 94, 88, 23, 106, 225, 174, 203, 176, 128, 255, 252, 189, 21, 5, 237, 46, 123, 103, 80]), transcriptFinalDigest := (bytes [175, 114, 117, 171, 183, 140, 14, 93, 101, 78, 240, 173, 111, 217, 152, 3, 43, 35, 106, 30, 72, 100, 145, 192, 226, 19, 62, 206, 185, 20, 165, 109]), finalPc := 28, halted := true, digest := (bytes [205, 254, 30, 56, 36, 192, 1, 150, 90, 196, 175, 20, 48, 150, 32, 137, 244, 105, 221, 101, 229, 178, 245, 230, 78, 102, 13, 208, 70, 39, 231, 127]) }, digest := (bytes [184, 187, 88, 120, 243, 102, 201, 103, 114, 10, 92, 102, 1, 66, 22, 53, 92, 115, 50, 97, 173, 40, 206, 140, 124, 30, 39, 199, 227, 153, 171, 6]) }, statementDigest := (bytes [41, 230, 229, 127, 113, 224, 169, 26, 193, 238, 157, 97, 181, 175, 228, 171, 145, 204, 91, 211, 167, 85, 181, 18, 209, 57, 194, 234, 102, 148, 104, 188]), proofDigest := (bytes [160, 158, 253, 248, 207, 31, 75, 5, 38, 216, 215, 163, 229, 200, 25, 23, 102, 76, 104, 4, 60, 225, 204, 6, 193, 32, 176, 46, 73, 79, 72, 72]), digest := (bytes [38, 10, 121, 0, 128, 196, 163, 184, 62, 57, 95, 43, 230, 234, 49, 198, 207, 48, 15, 204, 126, 59, 0, 243, 85, 229, 253, 153, 227, 87, 93, 121]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [70, 190, 119, 237, 36, 24, 10, 255, 89, 160, 80, 108, 23, 145, 105, 211, 62, 238, 219, 129, 146, 61, 176, 70, 36, 218, 198, 73, 69, 147, 187, 137]), layoutVersion := 1, digest := (bytes [223, 12, 232, 107, 103, 109, 239, 254, 232, 159, 134, 133, 162, 7, 6, 93, 43, 61, 94, 124, 24, 133, 145, 222, 17, 11, 39, 186, 227, 136, 222, 49]) }, rowWidth := 38, timeLen := 7, columnDigests := [(bytes [40, 243, 169, 246, 170, 121, 143, 48, 132, 183, 68, 213, 151, 130, 14, 65, 20, 212, 138, 236, 77, 112, 226, 150, 158, 109, 142, 75, 172, 115, 156, 234]), (bytes [183, 255, 181, 34, 203, 1, 222, 219, 152, 86, 144, 13, 74, 163, 20, 134, 40, 184, 20, 201, 107, 98, 76, 0, 125, 194, 18, 176, 16, 226, 102, 175]), (bytes [153, 111, 70, 176, 156, 174, 226, 182, 197, 190, 144, 153, 100, 226, 206, 209, 132, 162, 24, 222, 166, 233, 132, 102, 120, 151, 149, 92, 177, 154, 105, 134]), (bytes [188, 23, 179, 202, 216, 119, 253, 192, 107, 56, 140, 18, 247, 51, 234, 39, 235, 216, 134, 241, 7, 60, 104, 146, 182, 166, 45, 236, 214, 213, 211, 83]), (bytes [78, 156, 218, 132, 187, 128, 28, 175, 180, 45, 97, 45, 52, 94, 142, 189, 238, 235, 64, 164, 28, 129, 72, 154, 162, 227, 67, 115, 203, 223, 178, 142]), (bytes [51, 155, 54, 140, 69, 32, 98, 139, 131, 15, 88, 241, 40, 59, 194, 36, 19, 79, 79, 128, 83, 255, 244, 188, 114, 23, 227, 76, 101, 158, 176, 30]), (bytes [50, 117, 247, 44, 135, 251, 33, 130, 187, 149, 173, 15, 157, 44, 184, 232, 74, 29, 121, 15, 49, 15, 1, 170, 4, 57, 254, 21, 66, 20, 255, 57]), (bytes [2, 151, 98, 91, 97, 198, 16, 102, 234, 151, 132, 235, 230, 225, 56, 72, 84, 195, 243, 65, 52, 112, 148, 213, 95, 205, 136, 136, 88, 166, 193, 238]), (bytes [179, 197, 166, 238, 247, 39, 161, 56, 86, 33, 181, 194, 233, 28, 80, 101, 156, 182, 133, 82, 176, 76, 183, 86, 85, 15, 113, 247, 11, 149, 206, 77]), (bytes [128, 164, 14, 32, 252, 110, 116, 191, 114, 251, 127, 177, 36, 25, 157, 9, 231, 136, 149, 138, 208, 250, 23, 50, 252, 29, 12, 233, 140, 95, 8, 140]), (bytes [89, 22, 73, 8, 21, 226, 125, 65, 127, 59, 246, 65, 171, 105, 50, 132, 94, 238, 207, 204, 138, 37, 170, 12, 117, 47, 94, 106, 8, 120, 51, 34]), (bytes [67, 66, 11, 107, 7, 178, 186, 212, 181, 238, 54, 244, 195, 113, 149, 104, 106, 62, 123, 255, 19, 55, 230, 77, 191, 247, 179, 205, 153, 160, 181, 50]), (bytes [18, 172, 128, 176, 253, 198, 4, 93, 34, 80, 94, 154, 166, 81, 235, 21, 208, 214, 240, 19, 132, 26, 227, 255, 47, 232, 138, 242, 49, 178, 152, 151]), (bytes [201, 43, 191, 252, 118, 131, 37, 225, 38, 225, 69, 142, 36, 139, 96, 240, 17, 37, 223, 234, 119, 9, 228, 163, 114, 217, 233, 239, 233, 185, 185, 128]), (bytes [249, 205, 171, 26, 216, 243, 195, 221, 128, 60, 80, 144, 180, 172, 149, 4, 27, 137, 206, 13, 166, 2, 78, 155, 206, 226, 57, 188, 182, 101, 121, 146]), (bytes [44, 32, 216, 93, 16, 146, 0, 130, 207, 204, 36, 141, 166, 246, 232, 20, 247, 247, 116, 89, 62, 217, 122, 245, 142, 15, 143, 44, 219, 131, 183, 12]), (bytes [63, 55, 148, 202, 193, 201, 88, 153, 244, 174, 145, 10, 157, 92, 137, 79, 24, 240, 86, 214, 120, 193, 105, 254, 83, 207, 7, 36, 175, 251, 198, 209]), (bytes [49, 184, 142, 166, 178, 93, 15, 133, 19, 3, 245, 149, 190, 250, 17, 77, 195, 143, 141, 153, 122, 25, 168, 96, 127, 182, 178, 210, 211, 3, 144, 60]), (bytes [86, 196, 110, 116, 66, 242, 23, 243, 102, 32, 103, 253, 30, 136, 67, 166, 214, 221, 241, 169, 190, 115, 51, 189, 2, 90, 50, 65, 2, 198, 240, 74]), (bytes [40, 190, 66, 17, 225, 194, 79, 155, 132, 37, 100, 66, 38, 252, 86, 198, 130, 181, 255, 44, 150, 162, 100, 158, 217, 251, 29, 121, 236, 9, 180, 205]), (bytes [254, 19, 232, 192, 11, 39, 102, 229, 212, 95, 179, 72, 76, 113, 31, 113, 119, 17, 192, 125, 69, 105, 89, 144, 235, 22, 196, 55, 37, 148, 98, 206]), (bytes [162, 220, 83, 150, 211, 225, 255, 88, 142, 249, 241, 103, 91, 83, 182, 68, 224, 210, 129, 244, 152, 190, 182, 178, 247, 142, 200, 54, 61, 197, 59, 136]), (bytes [157, 243, 246, 1, 231, 124, 63, 187, 113, 83, 135, 59, 185, 176, 92, 154, 19, 95, 23, 144, 39, 18, 116, 243, 148, 33, 40, 76, 72, 135, 179, 217]), (bytes [215, 235, 228, 195, 126, 67, 73, 117, 240, 48, 198, 153, 149, 10, 116, 211, 229, 187, 72, 167, 138, 70, 233, 6, 198, 196, 67, 132, 227, 126, 249, 237]), (bytes [155, 46, 222, 79, 160, 132, 118, 83, 92, 71, 119, 54, 198, 8, 141, 171, 147, 66, 60, 77, 68, 15, 109, 158, 26, 159, 53, 144, 233, 162, 202, 146]), (bytes [183, 229, 214, 38, 2, 127, 216, 184, 77, 254, 138, 78, 137, 131, 89, 214, 211, 90, 100, 35, 45, 51, 180, 50, 190, 176, 83, 112, 101, 23, 181, 170]), (bytes [121, 173, 212, 206, 43, 62, 110, 188, 123, 202, 190, 163, 124, 203, 14, 8, 205, 10, 134, 22, 77, 113, 110, 162, 179, 102, 146, 84, 172, 188, 144, 247]), (bytes [134, 43, 219, 6, 234, 143, 97, 163, 132, 117, 241, 141, 98, 196, 41, 77, 3, 224, 76, 14, 112, 49, 93, 186, 30, 158, 156, 221, 192, 147, 18, 53]), (bytes [150, 176, 216, 226, 239, 79, 218, 77, 47, 25, 98, 54, 47, 52, 197, 168, 30, 126, 93, 34, 149, 210, 8, 114, 248, 27, 12, 14, 147, 154, 204, 250]), (bytes [83, 251, 49, 48, 54, 174, 206, 33, 38, 55, 53, 86, 238, 134, 67, 140, 194, 44, 73, 155, 93, 189, 217, 191, 38, 87, 214, 184, 137, 68, 230, 167]), (bytes [240, 212, 182, 90, 28, 28, 194, 255, 94, 159, 35, 103, 91, 242, 214, 20, 102, 217, 67, 85, 43, 252, 11, 32, 160, 11, 241, 164, 190, 14, 75, 153]), (bytes [83, 203, 23, 43, 120, 2, 138, 179, 201, 101, 117, 199, 249, 119, 150, 189, 107, 206, 100, 240, 241, 191, 29, 12, 95, 189, 46, 162, 173, 67, 52, 64]), (bytes [243, 18, 112, 16, 115, 206, 161, 217, 70, 120, 53, 168, 21, 217, 125, 177, 15, 184, 39, 220, 129, 252, 253, 217, 143, 169, 231, 204, 197, 173, 74, 44]), (bytes [174, 205, 154, 64, 243, 198, 70, 67, 132, 170, 211, 195, 186, 11, 96, 55, 55, 6, 248, 130, 169, 186, 214, 86, 104, 198, 34, 111, 234, 42, 133, 117]), (bytes [80, 237, 204, 122, 194, 130, 220, 252, 3, 111, 197, 112, 201, 6, 39, 55, 107, 14, 41, 172, 114, 110, 188, 233, 86, 120, 251, 235, 230, 110, 137, 34]), (bytes [64, 184, 77, 60, 124, 164, 54, 93, 23, 121, 89, 235, 81, 60, 107, 51, 86, 73, 18, 40, 80, 16, 45, 151, 39, 61, 175, 64, 40, 48, 21, 239]), (bytes [12, 243, 124, 85, 184, 138, 62, 99, 176, 174, 57, 188, 133, 173, 127, 231, 9, 202, 235, 153, 59, 220, 215, 127, 240, 138, 226, 158, 18, 89, 217, 143]), (bytes [145, 99, 191, 35, 121, 90, 118, 57, 187, 82, 200, 99, 201, 117, 132, 16, 109, 95, 126, 62, 89, 129, 183, 210, 46, 8, 148, 208, 73, 204, 191, 238])], familyDigest := (bytes [70, 190, 119, 237, 36, 24, 10, 255, 89, 160, 80, 108, 23, 145, 105, 211, 62, 238, 219, 129, 146, 61, 176, 70, 36, 218, 198, 73, 69, 147, 187, 137]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [70, 190, 119, 237, 36, 24, 10, 255, 89, 160, 80, 108, 23, 145, 105, 211, 62, 238, 219, 129, 146, 61, 176, 70, 36, 218, 198, 73, 69, 147, 187, 137]), layoutVersion := 1, digest := (bytes [223, 12, 232, 107, 103, 109, 239, 254, 232, 159, 134, 133, 162, 7, 6, 93, 43, 61, 94, 124, 24, 133, 145, 222, 17, 11, 39, 186, 227, 136, 222, 49]) }, logicalIndex := 0, digest := (bytes [181, 209, 216, 196, 249, 234, 132, 147, 93, 249, 188, 78, 137, 39, 111, 159, 36, 223, 189, 242, 193, 195, 223, 81, 244, 157, 13, 96, 136, 118, 229, 69]) }, valueDigest := (bytes [129, 16, 11, 76, 253, 155, 142, 28, 89, 240, 19, 169, 171, 115, 101, 224, 73, 120, 86, 195, 27, 185, 106, 175, 64, 231, 190, 170, 187, 57, 144, 129]), digest := (bytes [50, 238, 42, 133, 107, 34, 54, 70, 10, 53, 197, 4, 106, 27, 119, 32, 0, 4, 236, 119, 96, 117, 207, 30, 209, 141, 155, 246, 5, 255, 61, 231]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [70, 190, 119, 237, 36, 24, 10, 255, 89, 160, 80, 108, 23, 145, 105, 211, 62, 238, 219, 129, 146, 61, 176, 70, 36, 218, 198, 73, 69, 147, 187, 137]), layoutVersion := 1, digest := (bytes [223, 12, 232, 107, 103, 109, 239, 254, 232, 159, 134, 133, 162, 7, 6, 93, 43, 61, 94, 124, 24, 133, 145, 222, 17, 11, 39, 186, 227, 136, 222, 49]) }, logicalIndex := 6, digest := (bytes [179, 55, 245, 26, 249, 15, 28, 32, 239, 95, 29, 215, 250, 6, 235, 143, 12, 253, 38, 245, 111, 6, 153, 38, 208, 180, 243, 114, 202, 234, 176, 118]) }, valueDigest := (bytes [57, 167, 127, 66, 29, 28, 1, 62, 111, 174, 45, 82, 212, 157, 25, 154, 254, 72, 204, 85, 223, 7, 138, 44, 48, 11, 222, 83, 122, 239, 183, 120]), digest := (bytes [2, 131, 66, 126, 27, 244, 0, 68, 253, 150, 147, 11, 191, 45, 95, 27, 113, 76, 223, 152, 32, 11, 185, 143, 34, 76, 74, 206, 33, 197, 20, 254]) }), digest := (bytes [37, 8, 78, 14, 146, 205, 65, 159, 184, 239, 247, 118, 54, 105, 79, 220, 185, 208, 0, 155, 34, 183, 214, 251, 219, 121, 128, 94, 200, 126, 158, 249]) }
  , rootLaneCommitment := { timeLen := 7, commitments := { commitmentCount := 38, digest := (bytes [242, 91, 154, 59, 179, 31, 205, 226, 106, 197, 36, 140, 227, 67, 214, 106, 172, 86, 15, 141, 54, 207, 214, 226, 236, 63, 189, 77, 236, 136, 221, 41]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [242, 91, 154, 59, 179, 31, 205, 226, 106, 197, 36, 140, 227, 67, 214, 106, 172, 86, 15, 141, 54, 207, 214, 226, 236, 63, 189, 77, 236, 136, 221, 41]), layoutVersion := 3, digest := (bytes [196, 194, 83, 41, 254, 85, 154, 3, 27, 133, 154, 198, 75, 41, 176, 38, 251, 138, 26, 245, 43, 23, 149, 221, 37, 126, 131, 135, 61, 219, 245, 126]) }, logicalIndex := 0, digest := (bytes [18, 182, 151, 108, 176, 139, 62, 254, 180, 178, 194, 184, 131, 85, 158, 49, 199, 77, 210, 40, 135, 44, 158, 184, 74, 173, 44, 24, 177, 94, 55, 54]) }, valueDigest := (bytes [129, 16, 11, 76, 253, 155, 142, 28, 89, 240, 19, 169, 171, 115, 101, 224, 73, 120, 86, 195, 27, 185, 106, 175, 64, 231, 190, 170, 187, 57, 144, 129]), digest := (bytes [172, 1, 44, 77, 105, 92, 145, 74, 215, 231, 41, 237, 112, 208, 85, 46, 7, 45, 204, 78, 158, 105, 59, 123, 2, 171, 181, 78, 110, 138, 150, 6]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [242, 91, 154, 59, 179, 31, 205, 226, 106, 197, 36, 140, 227, 67, 214, 106, 172, 86, 15, 141, 54, 207, 214, 226, 236, 63, 189, 77, 236, 136, 221, 41]), layoutVersion := 3, digest := (bytes [196, 194, 83, 41, 254, 85, 154, 3, 27, 133, 154, 198, 75, 41, 176, 38, 251, 138, 26, 245, 43, 23, 149, 221, 37, 126, 131, 135, 61, 219, 245, 126]) }, logicalIndex := 6, digest := (bytes [10, 223, 129, 108, 227, 203, 154, 145, 141, 129, 215, 247, 157, 208, 180, 255, 202, 36, 10, 231, 89, 215, 159, 81, 120, 177, 99, 161, 55, 22, 112, 57]) }, valueDigest := (bytes [57, 167, 127, 66, 29, 28, 1, 62, 111, 174, 45, 82, 212, 157, 25, 154, 254, 72, 204, 85, 223, 7, 138, 44, 48, 11, 222, 83, 122, 239, 183, 120]), digest := (bytes [92, 219, 197, 231, 121, 26, 25, 227, 146, 19, 85, 137, 42, 97, 157, 106, 111, 249, 53, 54, 34, 115, 103, 115, 189, 185, 106, 22, 129, 42, 59, 71]) }), digest := (bytes [84, 208, 93, 185, 245, 39, 103, 192, 242, 100, 29, 19, 49, 87, 23, 220, 246, 252, 36, 11, 90, 91, 215, 1, 154, 23, 178, 107, 196, 135, 122, 112]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [37, 8, 78, 14, 146, 205, 65, 159, 184, 239, 247, 118, 54, 105, 79, 220, 185, 208, 0, 155, 34, 183, 214, 251, 219, 121, 128, 94, 200, 126, 158, 249]), rootLaneCommitmentDigest := (bytes [84, 208, 93, 185, 245, 39, 103, 192, 242, 100, 29, 19, 49, 87, 23, 220, 246, 252, 36, 11, 90, 91, 215, 1, 154, 23, 178, 107, 196, 135, 122, 112]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 7, digest := (bytes [217, 193, 32, 88, 183, 117, 187, 140, 85, 37, 144, 64, 64, 78, 9, 138, 114, 53, 75, 81, 119, 141, 235, 113, 84, 219, 104, 242, 125, 236, 59, 214]) }, statementDigest := (bytes [177, 220, 4, 67, 98, 192, 66, 110, 152, 145, 91, 155, 208, 155, 27, 227, 143, 244, 99, 43, 231, 16, 238, 72, 148, 55, 185, 189, 126, 164, 42, 76]), proofDigest := (bytes [166, 125, 197, 254, 250, 227, 216, 35, 70, 138, 144, 252, 36, 213, 196, 70, 147, 222, 207, 251, 149, 2, 79, 84, 23, 13, 145, 183, 128, 167, 96, 75]), digest := (bytes [147, 223, 38, 91, 91, 170, 19, 43, 67, 11, 53, 229, 189, 7, 194, 217, 136, 136, 124, 129, 140, 43, 14, 0, 118, 11, 65, 35, 152, 217, 42, 130]) }
  , digest := (bytes [128, 232, 234, 130, 162, 99, 245, 11, 117, 140, 17, 237, 240, 121, 40, 103, 216, 30, 129, 106, 141, 52, 147, 240, 241, 18, 212, 169, 151, 1, 239, 151])
}
}
    , exportedStatement := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , foldSchedule := Nightstream.FoldSchedule.wholeTrace
  , chunkCount := 1
  , stageClaimsDigest := (bytes [187, 50, 157, 181, 241, 79, 199, 205, 161, 23, 168, 61, 213, 19, 247, 236, 73, 137, 221, 22, 189, 207, 80, 10, 57, 202, 77, 165, 69, 151, 191, 138])
  , stagePackagesDigest := (bytes [159, 123, 197, 156, 14, 226, 241, 7, 33, 88, 247, 60, 170, 137, 188, 149, 66, 230, 86, 169, 192, 25, 109, 119, 38, 44, 37, 209, 169, 81, 180, 13])
  , kernelOpeningDigest := (bytes [141, 146, 207, 140, 176, 146, 70, 236, 225, 112, 7, 92, 12, 245, 12, 82, 60, 62, 117, 190, 159, 12, 155, 34, 223, 223, 52, 134, 143, 244, 198, 230])
  , preparedStepBindingsDigest := (bytes [87, 71, 197, 222, 145, 126, 134, 239, 226, 74, 253, 106, 28, 144, 235, 131, 31, 120, 247, 233, 88, 225, 201, 44, 4, 49, 185, 67, 38, 174, 63, 242])
  , executionDigest := (bytes [187, 211, 69, 135, 229, 127, 64, 102, 85, 14, 246, 26, 208, 214, 247, 252, 184, 3, 119, 82, 89, 137, 101, 38, 31, 135, 97, 182, 171, 175, 16, 207])
  , finalStateDigest := (bytes [183, 99, 121, 135, 139, 0, 186, 237, 83, 70, 165, 225, 69, 94, 88, 23, 106, 225, 174, 203, 176, 128, 255, 252, 189, 21, 5, 237, 46, 123, 103, 80])
  , transcriptFinalDigest := (bytes [175, 114, 117, 171, 183, 140, 14, 93, 101, 78, 240, 173, 111, 217, 152, 3, 43, 35, 106, 30, 72, 100, 145, 192, 226, 19, 62, 206, 185, 20, 165, 109])
  , mainLaneSurfaceDigest := (bytes [193, 57, 83, 164, 60, 80, 135, 119, 159, 30, 14, 93, 91, 166, 106, 111, 192, 102, 228, 113, 243, 240, 152, 41, 122, 245, 207, 64, 61, 77, 55, 210])
  , rootLaneColumnsDigest := (bytes [37, 8, 78, 14, 146, 205, 65, 159, 184, 239, 247, 118, 54, 105, 79, 220, 185, 208, 0, 155, 34, 183, 214, 251, 219, 121, 128, 94, 200, 126, 158, 249])
  , publicStepCount := 7
  , initialPc := 0
  , finalPc := 28
  , halted := true
  , digest := (bytes [9, 26, 47, 110, 120, 237, 66, 220, 196, 116, 214, 65, 240, 120, 175, 24, 254, 10, 155, 184, 219, 117, 77, 9, 99, 37, 45, 97, 31, 34, 96, 26])
}
    , exportedClaims := {
  accepted := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , statement := { proofStatementDigest := (bytes [9, 26, 47, 110, 120, 237, 66, 220, 196, 116, 214, 65, 240, 120, 175, 24, 254, 10, 155, 184, 219, 117, 77, 9, 99, 37, 45, 97, 31, 34, 96, 26]), kernelOpeningDigest := (bytes [141, 146, 207, 140, 176, 146, 70, 236, 225, 112, 7, 92, 12, 245, 12, 82, 60, 62, 117, 190, 159, 12, 155, 34, 223, 223, 52, 134, 143, 244, 198, 230]), digest := (bytes [150, 30, 177, 116, 125, 20, 242, 54, 30, 252, 74, 183, 26, 20, 68, 170, 154, 65, 63, 223, 244, 12, 4, 133, 16, 7, 224, 125, 51, 113, 161, 124]) }
  , mainLane := { mainLaneBundleDigest := (bytes [147, 223, 38, 91, 91, 170, 19, 43, 67, 11, 53, 229, 189, 7, 194, 217, 136, 136, 124, 129, 140, 43, 14, 0, 118, 11, 65, 35, 152, 217, 42, 130]), digest := (bytes [147, 177, 245, 247, 119, 107, 75, 243, 229, 68, 178, 238, 29, 226, 64, 78, 39, 205, 237, 60, 37, 241, 254, 69, 145, 234, 120, 190, 131, 189, 153, 138]) }
  , terminal := { finalStateDigest := (bytes [183, 99, 121, 135, 139, 0, 186, 237, 83, 70, 165, 225, 69, 94, 88, 23, 106, 225, 174, 203, 176, 128, 255, 252, 189, 21, 5, 237, 46, 123, 103, 80]), finalPc := 28, halted := true, digest := (bytes [205, 138, 253, 137, 65, 200, 120, 143, 138, 62, 28, 126, 73, 47, 246, 171, 246, 128, 191, 30, 83, 68, 128, 28, 212, 244, 166, 182, 126, 121, 249, 68]) }
  , digest := (bytes [156, 120, 39, 215, 81, 48, 234, 114, 72, 75, 244, 93, 196, 6, 128, 50, 50, 169, 92, 117, 164, 125, 86, 69, 252, 34, 231, 70, 6, 159, 166, 200])
}
  , mainLane := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { mainLaneBundleDigest := (bytes [147, 223, 38, 91, 91, 170, 19, 43, 67, 11, 53, 229, 189, 7, 194, 217, 136, 136, 124, 129, 140, 43, 14, 0, 118, 11, 65, 35, 152, 217, 42, 130]), digest := (bytes [255, 126, 21, 166, 110, 107, 195, 7, 240, 125, 197, 158, 205, 75, 41, 53, 93, 222, 22, 105, 230, 248, 213, 167, 43, 198, 16, 213, 103, 121, 143, 82]) }, digest := (bytes [207, 93, 32, 13, 143, 104, 149, 211, 24, 35, 131, 142, 225, 161, 219, 138, 235, 171, 15, 171, 103, 31, 204, 190, 155, 14, 91, 120, 215, 180, 109, 117]) }
  , opening := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , stages := { stageClaimsDigest := (bytes [187, 50, 157, 181, 241, 79, 199, 205, 161, 23, 168, 61, 213, 19, 247, 236, 73, 137, 221, 22, 189, 207, 80, 10, 57, 202, 77, 165, 69, 151, 191, 138]), stagePackagesDigest := (bytes [159, 123, 197, 156, 14, 226, 241, 7, 33, 88, 247, 60, 170, 137, 188, 149, 66, 230, 86, 169, 192, 25, 109, 119, 38, 44, 37, 209, 169, 81, 180, 13]), kernelOpeningDigest := (bytes [141, 146, 207, 140, 176, 146, 70, 236, 225, 112, 7, 92, 12, 245, 12, 82, 60, 62, 117, 190, 159, 12, 155, 34, 223, 223, 52, 134, 143, 244, 198, 230]), digest := (bytes [251, 156, 34, 223, 190, 40, 61, 46, 104, 169, 174, 154, 215, 200, 34, 239, 142, 150, 120, 203, 8, 224, 14, 146, 135, 99, 17, 6, 195, 166, 109, 41]) }
  , terminal := { preparedStepBindingsDigest := (bytes [87, 71, 197, 222, 145, 126, 134, 239, 226, 74, 253, 106, 28, 144, 235, 131, 31, 120, 247, 233, 88, 225, 201, 44, 4, 49, 185, 67, 38, 174, 63, 242]), executionDigest := (bytes [187, 211, 69, 135, 229, 127, 64, 102, 85, 14, 246, 26, 208, 214, 247, 252, 184, 3, 119, 82, 89, 137, 101, 38, 31, 135, 97, 182, 171, 175, 16, 207]), transcriptFinalDigest := (bytes [175, 114, 117, 171, 183, 140, 14, 93, 101, 78, 240, 173, 111, 217, 152, 3, 43, 35, 106, 30, 72, 100, 145, 192, 226, 19, 62, 206, 185, 20, 165, 109]), digest := (bytes [211, 44, 76, 38, 148, 24, 179, 111, 92, 121, 159, 201, 175, 154, 46, 219, 82, 71, 181, 188, 11, 252, 118, 65, 242, 183, 6, 158, 126, 181, 201, 136]) }
  , digest := (bytes [255, 214, 134, 89, 136, 66, 25, 9, 227, 251, 220, 230, 255, 69, 207, 171, 155, 207, 167, 75, 133, 109, 63, 69, 41, 89, 98, 89, 19, 32, 43, 142])
}
  , jointOpening := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { proofStatementDigest := (bytes [9, 26, 47, 110, 120, 237, 66, 220, 196, 116, 214, 65, 240, 120, 175, 24, 254, 10, 155, 184, 219, 117, 77, 9, 99, 37, 45, 97, 31, 34, 96, 26]), mainLaneClaimDigest := (bytes [207, 93, 32, 13, 143, 104, 149, 211, 24, 35, 131, 142, 225, 161, 219, 138, 235, 171, 15, 171, 103, 31, 204, 190, 155, 14, 91, 120, 215, 180, 109, 117]), kernelOpeningClaimDigest := (bytes [255, 214, 134, 89, 136, 66, 25, 9, 227, 251, 220, 230, 255, 69, 207, 171, 155, 207, 167, 75, 133, 109, 63, 69, 41, 89, 98, 89, 19, 32, 43, 142]), digest := (bytes [111, 82, 78, 62, 181, 82, 166, 232, 158, 123, 144, 119, 135, 3, 239, 126, 250, 71, 252, 78, 54, 107, 79, 10, 29, 147, 0, 77, 67, 165, 16, 156]) }, digest := (bytes [191, 148, 46, 158, 202, 212, 217, 245, 2, 236, 252, 186, 110, 87, 62, 95, 117, 252, 137, 187, 49, 152, 95, 154, 95, 75, 22, 5, 68, 145, 187, 72]) }
  , root0 := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), stages := { stage1Digest := (bytes [233, 196, 203, 200, 70, 58, 121, 64, 190, 77, 215, 109, 211, 207, 110, 212, 227, 39, 71, 54, 50, 7, 179, 37, 204, 185, 66, 14, 130, 114, 51, 240]), stage2Digest := (bytes [133, 91, 57, 33, 9, 81, 232, 147, 233, 248, 11, 52, 22, 187, 82, 147, 231, 35, 101, 212, 42, 7, 126, 94, 3, 54, 201, 128, 233, 222, 146, 92]), stage3Digest := (bytes [13, 62, 18, 231, 159, 216, 74, 146, 123, 100, 48, 154, 55, 62, 243, 77, 247, 72, 183, 146, 55, 128, 226, 205, 79, 61, 249, 159, 174, 184, 114, 0]), digest := (bytes [45, 86, 90, 69, 182, 192, 236, 132, 159, 153, 254, 191, 253, 67, 122, 245, 66, 226, 40, 198, 206, 149, 109, 102, 146, 184, 164, 196, 126, 113, 146, 6]) }, terminal := { root0Digest := (bytes [67, 149, 212, 203, 125, 6, 193, 148, 95, 242, 87, 131, 79, 199, 154, 105, 62, 65, 66, 99, 45, 14, 202, 150, 24, 19, 22, 127, 80, 126, 57, 58]), executionDigest := (bytes [187, 211, 69, 135, 229, 127, 64, 102, 85, 14, 246, 26, 208, 214, 247, 252, 184, 3, 119, 82, 89, 137, 101, 38, 31, 135, 97, 182, 171, 175, 16, 207]), finalStateDigest := (bytes [183, 99, 121, 135, 139, 0, 186, 237, 83, 70, 165, 225, 69, 94, 88, 23, 106, 225, 174, 203, 176, 128, 255, 252, 189, 21, 5, 237, 46, 123, 103, 80]), transcriptFinalDigest := (bytes [175, 114, 117, 171, 183, 140, 14, 93, 101, 78, 240, 173, 111, 217, 152, 3, 43, 35, 106, 30, 72, 100, 145, 192, 226, 19, 62, 206, 185, 20, 165, 109]), digest := (bytes [30, 17, 202, 223, 244, 223, 240, 246, 28, 229, 241, 158, 198, 72, 84, 89, 115, 29, 122, 118, 45, 98, 42, 37, 140, 148, 206, 122, 239, 29, 210, 172]) }, digest := (bytes [192, 239, 89, 135, 38, 141, 227, 96, 149, 138, 107, 247, 134, 149, 232, 90, 124, 47, 230, 185, 60, 239, 200, 35, 224, 39, 126, 219, 255, 175, 18, 123]) }
  , digest := (bytes [19, 11, 93, 73, 94, 168, 72, 222, 152, 6, 180, 17, 72, 48, 109, 139, 122, 3, 159, 35, 123, 12, 117, 118, 60, 92, 14, 116, 210, 146, 121, 27])
}
    , exportedKernelProof := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "narrow_memory_load_extract_extend_ecall", fixtureId := "narrow_memory_load_extract_extend_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.narrowMemory, .controlFlow] }
  , executionDigest := (bytes [187, 211, 69, 135, 229, 127, 64, 102, 85, 14, 246, 26, 208, 214, 247, 252, 184, 3, 119, 82, 89, 137, 101, 38, 31, 135, 97, 182, 171, 175, 16, 207])
  , shape := { executionRowCount := 7, realRowCount := 7, effectRowCount := 7, commitRowCount := 7, digest := (bytes [36, 118, 223, 124, 248, 115, 52, 199, 198, 250, 25, 33, 218, 131, 247, 174, 126, 69, 105, 226, 74, 199, 244, 245, 142, 55, 128, 143, 190, 129, 55, 117]) }
  , digest := (bytes [86, 78, 49, 65, 94, 63, 99, 57, 236, 173, 117, 185, 233, 227, 96, 236, 240, 241, 56, 163, 8, 27, 20, 172, 76, 91, 3, 79, 142, 80, 144, 152])
}
  , stages := { summary := { stage1RowCount := 7, stage2RegisterReadCount := 6, stage2RegisterWriteCount := 6, stage2RamEventCount := 6, stage2TwistLinkCount := 7, stage3ContinuityCount := 7, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [13, 103, 5, 60, 171, 246, 186, 177, 139, 97, 5, 132, 102, 84, 58, 208, 250, 132, 196, 23, 6, 156, 134, 31, 139, 46, 24, 118, 84, 20, 145, 230]) }, digest := (bytes [122, 94, 1, 183, 131, 155, 12, 186, 101, 198, 192, 53, 132, 152, 30, 77, 246, 137, 62, 65, 199, 135, 82, 194, 84, 215, 126, 139, 196, 45, 52, 64]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [252, 175, 36, 55, 16, 39, 35, 65, 192, 33, 136, 127, 92, 37, 5, 83, 58, 102, 165, 202, 255, 157, 139, 172, 252, 2, 15, 208, 167, 198, 104, 16]), stage1Digest := (bytes [28, 198, 65, 235, 4, 107, 49, 175, 18, 110, 191, 155, 156, 19, 240, 191, 2, 113, 73, 38, 8, 215, 32, 192, 83, 250, 154, 167, 86, 35, 11, 39]), stage2Digest := (bytes [73, 18, 118, 218, 186, 72, 53, 121, 0, 64, 208, 199, 248, 10, 57, 52, 139, 208, 124, 252, 43, 145, 182, 89, 171, 169, 217, 161, 225, 45, 210, 159]), stage3Digest := (bytes [191, 231, 148, 196, 231, 32, 230, 244, 246, 105, 83, 164, 118, 60, 102, 72, 67, 56, 200, 185, 75, 228, 213, 186, 94, 157, 206, 182, 221, 166, 14, 83]), transcriptDigest := (bytes [175, 114, 117, 171, 183, 140, 14, 93, 101, 78, 240, 173, 111, 217, 152, 3, 43, 35, 106, 30, 72, 100, 145, 192, 226, 19, 62, 206, 185, 20, 165, 109]), executionDigest := (bytes [187, 211, 69, 135, 229, 127, 64, 102, 85, 14, 246, 26, 208, 214, 247, 252, 184, 3, 119, 82, 89, 137, 101, 38, 31, 135, 97, 182, 171, 175, 16, 207]), digest := (bytes [126, 39, 205, 171, 139, 230, 18, 144, 245, 239, 56, 160, 216, 130, 121, 191, 218, 21, 7, 220, 31, 214, 144, 245, 61, 214, 81, 63, 199, 124, 9, 16]) }, statementDigest := (bytes [216, 26, 238, 112, 223, 67, 174, 31, 136, 143, 156, 159, 231, 136, 90, 99, 74, 194, 221, 66, 220, 65, 159, 218, 151, 173, 22, 211, 219, 63, 189, 212]), proofDigest := (bytes [255, 32, 35, 85, 2, 248, 186, 92, 40, 149, 115, 30, 99, 171, 133, 241, 192, 32, 175, 129, 180, 46, 195, 254, 198, 27, 44, 190, 188, 119, 201, 217]), digest := (bytes [187, 50, 157, 181, 241, 79, 199, 205, 161, 23, 168, 61, 213, 19, 247, 236, 73, 137, 221, 22, 189, 207, 80, 10, 57, 202, 77, 165, 69, 151, 191, 138]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [94, 159, 169, 31, 25, 245, 184, 4, 46, 138, 109, 67, 182, 224, 199, 16, 153, 186, 190, 175, 225, 196, 202, 59, 226, 179, 27, 101, 188, 47, 165, 149]), stage1Digest := (bytes [242, 173, 96, 214, 78, 222, 28, 165, 129, 156, 193, 86, 68, 216, 118, 57, 97, 73, 225, 233, 152, 96, 17, 76, 85, 117, 101, 168, 162, 156, 168, 237]), stage2Digest := (bytes [117, 100, 103, 165, 37, 29, 92, 151, 19, 172, 62, 235, 204, 183, 18, 246, 119, 143, 55, 182, 59, 131, 149, 169, 204, 165, 111, 196, 201, 14, 96, 167]), stage3Digest := (bytes [21, 245, 157, 115, 126, 105, 209, 146, 6, 189, 145, 233, 254, 142, 227, 64, 172, 198, 139, 5, 185, 117, 230, 218, 60, 6, 163, 248, 78, 42, 113, 139]), digest := (bytes [148, 243, 99, 118, 217, 55, 232, 151, 71, 161, 71, 104, 198, 192, 233, 163, 242, 169, 39, 139, 237, 210, 69, 153, 88, 121, 0, 150, 128, 28, 0, 226]) }, digest := (bytes [159, 123, 197, 156, 14, 226, 241, 7, 33, 88, 247, 60, 170, 137, 188, 149, 66, 230, 86, 169, 192, 25, 109, 119, 38, 44, 37, 209, 169, 81, 180, 13]) }
  , kernelOpening := { openingDigest := (bytes [174, 215, 89, 16, 208, 92, 164, 214, 195, 135, 203, 234, 204, 218, 31, 142, 86, 82, 205, 149, 108, 240, 27, 186, 231, 60, 230, 45, 110, 162, 156, 232]), bindings := { claimDigest := (bytes [125, 215, 94, 215, 230, 158, 106, 144, 53, 21, 187, 48, 96, 238, 228, 131, 131, 235, 98, 201, 79, 252, 28, 204, 85, 44, 105, 21, 223, 210, 61, 61]), bindingsDigest := (bytes [172, 38, 119, 164, 63, 10, 208, 83, 254, 205, 64, 201, 219, 250, 218, 151, 248, 218, 166, 136, 128, 2, 176, 192, 120, 173, 199, 116, 104, 79, 83, 221]), preparedStepsDigest := (bytes [128, 244, 11, 88, 195, 150, 200, 124, 145, 196, 16, 43, 4, 66, 29, 221, 61, 201, 157, 185, 154, 35, 129, 178, 187, 121, 123, 200, 20, 148, 99, 91]), digest := (bytes [197, 157, 149, 152, 127, 208, 125, 59, 21, 71, 182, 70, 126, 77, 132, 169, 1, 62, 127, 92, 104, 162, 17, 40, 78, 11, 182, 23, 90, 156, 175, 210]) }, digest := (bytes [141, 146, 207, 140, 176, 146, 70, 236, 225, 112, 7, 92, 12, 245, 12, 82, 60, 62, 117, 190, 159, 12, 155, 34, 223, 223, 52, 134, 143, 244, 198, 230]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [87, 71, 197, 222, 145, 126, 134, 239, 226, 74, 253, 106, 28, 144, 235, 131, 31, 120, 247, 233, 88, 225, 201, 44, 4, 49, 185, 67, 38, 174, 63, 242]), terminal := { root0Digest := (bytes [67, 149, 212, 203, 125, 6, 193, 148, 95, 242, 87, 131, 79, 199, 154, 105, 62, 65, 66, 99, 45, 14, 202, 150, 24, 19, 22, 127, 80, 126, 57, 58]), executionDigest := (bytes [187, 211, 69, 135, 229, 127, 64, 102, 85, 14, 246, 26, 208, 214, 247, 252, 184, 3, 119, 82, 89, 137, 101, 38, 31, 135, 97, 182, 171, 175, 16, 207]), finalStateDigest := (bytes [183, 99, 121, 135, 139, 0, 186, 237, 83, 70, 165, 225, 69, 94, 88, 23, 106, 225, 174, 203, 176, 128, 255, 252, 189, 21, 5, 237, 46, 123, 103, 80]), transcriptFinalDigest := (bytes [175, 114, 117, 171, 183, 140, 14, 93, 101, 78, 240, 173, 111, 217, 152, 3, 43, 35, 106, 30, 72, 100, 145, 192, 226, 19, 62, 206, 185, 20, 165, 109]), finalPc := 28, halted := true, digest := (bytes [205, 254, 30, 56, 36, 192, 1, 150, 90, 196, 175, 20, 48, 150, 32, 137, 244, 105, 221, 101, 229, 178, 245, 230, 78, 102, 13, 208, 70, 39, 231, 127]) }, digest := (bytes [184, 187, 88, 120, 243, 102, 201, 103, 114, 10, 92, 102, 1, 66, 22, 53, 92, 115, 50, 97, 173, 40, 206, 140, 124, 30, 39, 199, 227, 153, 171, 6]) }, statementDigest := (bytes [41, 230, 229, 127, 113, 224, 169, 26, 193, 238, 157, 97, 181, 175, 228, 171, 145, 204, 91, 211, 167, 85, 181, 18, 209, 57, 194, 234, 102, 148, 104, 188]), proofDigest := (bytes [160, 158, 253, 248, 207, 31, 75, 5, 38, 216, 215, 163, 229, 200, 25, 23, 102, 76, 104, 4, 60, 225, 204, 6, 193, 32, 176, 46, 73, 79, 72, 72]), digest := (bytes [38, 10, 121, 0, 128, 196, 163, 184, 62, 57, 95, 43, 230, 234, 49, 198, 207, 48, 15, 204, 126, 59, 0, 243, 85, 229, 253, 153, 227, 87, 93, 121]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [70, 190, 119, 237, 36, 24, 10, 255, 89, 160, 80, 108, 23, 145, 105, 211, 62, 238, 219, 129, 146, 61, 176, 70, 36, 218, 198, 73, 69, 147, 187, 137]), layoutVersion := 1, digest := (bytes [223, 12, 232, 107, 103, 109, 239, 254, 232, 159, 134, 133, 162, 7, 6, 93, 43, 61, 94, 124, 24, 133, 145, 222, 17, 11, 39, 186, 227, 136, 222, 49]) }, rowWidth := 38, timeLen := 7, columnDigests := [(bytes [40, 243, 169, 246, 170, 121, 143, 48, 132, 183, 68, 213, 151, 130, 14, 65, 20, 212, 138, 236, 77, 112, 226, 150, 158, 109, 142, 75, 172, 115, 156, 234]), (bytes [183, 255, 181, 34, 203, 1, 222, 219, 152, 86, 144, 13, 74, 163, 20, 134, 40, 184, 20, 201, 107, 98, 76, 0, 125, 194, 18, 176, 16, 226, 102, 175]), (bytes [153, 111, 70, 176, 156, 174, 226, 182, 197, 190, 144, 153, 100, 226, 206, 209, 132, 162, 24, 222, 166, 233, 132, 102, 120, 151, 149, 92, 177, 154, 105, 134]), (bytes [188, 23, 179, 202, 216, 119, 253, 192, 107, 56, 140, 18, 247, 51, 234, 39, 235, 216, 134, 241, 7, 60, 104, 146, 182, 166, 45, 236, 214, 213, 211, 83]), (bytes [78, 156, 218, 132, 187, 128, 28, 175, 180, 45, 97, 45, 52, 94, 142, 189, 238, 235, 64, 164, 28, 129, 72, 154, 162, 227, 67, 115, 203, 223, 178, 142]), (bytes [51, 155, 54, 140, 69, 32, 98, 139, 131, 15, 88, 241, 40, 59, 194, 36, 19, 79, 79, 128, 83, 255, 244, 188, 114, 23, 227, 76, 101, 158, 176, 30]), (bytes [50, 117, 247, 44, 135, 251, 33, 130, 187, 149, 173, 15, 157, 44, 184, 232, 74, 29, 121, 15, 49, 15, 1, 170, 4, 57, 254, 21, 66, 20, 255, 57]), (bytes [2, 151, 98, 91, 97, 198, 16, 102, 234, 151, 132, 235, 230, 225, 56, 72, 84, 195, 243, 65, 52, 112, 148, 213, 95, 205, 136, 136, 88, 166, 193, 238]), (bytes [179, 197, 166, 238, 247, 39, 161, 56, 86, 33, 181, 194, 233, 28, 80, 101, 156, 182, 133, 82, 176, 76, 183, 86, 85, 15, 113, 247, 11, 149, 206, 77]), (bytes [128, 164, 14, 32, 252, 110, 116, 191, 114, 251, 127, 177, 36, 25, 157, 9, 231, 136, 149, 138, 208, 250, 23, 50, 252, 29, 12, 233, 140, 95, 8, 140]), (bytes [89, 22, 73, 8, 21, 226, 125, 65, 127, 59, 246, 65, 171, 105, 50, 132, 94, 238, 207, 204, 138, 37, 170, 12, 117, 47, 94, 106, 8, 120, 51, 34]), (bytes [67, 66, 11, 107, 7, 178, 186, 212, 181, 238, 54, 244, 195, 113, 149, 104, 106, 62, 123, 255, 19, 55, 230, 77, 191, 247, 179, 205, 153, 160, 181, 50]), (bytes [18, 172, 128, 176, 253, 198, 4, 93, 34, 80, 94, 154, 166, 81, 235, 21, 208, 214, 240, 19, 132, 26, 227, 255, 47, 232, 138, 242, 49, 178, 152, 151]), (bytes [201, 43, 191, 252, 118, 131, 37, 225, 38, 225, 69, 142, 36, 139, 96, 240, 17, 37, 223, 234, 119, 9, 228, 163, 114, 217, 233, 239, 233, 185, 185, 128]), (bytes [249, 205, 171, 26, 216, 243, 195, 221, 128, 60, 80, 144, 180, 172, 149, 4, 27, 137, 206, 13, 166, 2, 78, 155, 206, 226, 57, 188, 182, 101, 121, 146]), (bytes [44, 32, 216, 93, 16, 146, 0, 130, 207, 204, 36, 141, 166, 246, 232, 20, 247, 247, 116, 89, 62, 217, 122, 245, 142, 15, 143, 44, 219, 131, 183, 12]), (bytes [63, 55, 148, 202, 193, 201, 88, 153, 244, 174, 145, 10, 157, 92, 137, 79, 24, 240, 86, 214, 120, 193, 105, 254, 83, 207, 7, 36, 175, 251, 198, 209]), (bytes [49, 184, 142, 166, 178, 93, 15, 133, 19, 3, 245, 149, 190, 250, 17, 77, 195, 143, 141, 153, 122, 25, 168, 96, 127, 182, 178, 210, 211, 3, 144, 60]), (bytes [86, 196, 110, 116, 66, 242, 23, 243, 102, 32, 103, 253, 30, 136, 67, 166, 214, 221, 241, 169, 190, 115, 51, 189, 2, 90, 50, 65, 2, 198, 240, 74]), (bytes [40, 190, 66, 17, 225, 194, 79, 155, 132, 37, 100, 66, 38, 252, 86, 198, 130, 181, 255, 44, 150, 162, 100, 158, 217, 251, 29, 121, 236, 9, 180, 205]), (bytes [254, 19, 232, 192, 11, 39, 102, 229, 212, 95, 179, 72, 76, 113, 31, 113, 119, 17, 192, 125, 69, 105, 89, 144, 235, 22, 196, 55, 37, 148, 98, 206]), (bytes [162, 220, 83, 150, 211, 225, 255, 88, 142, 249, 241, 103, 91, 83, 182, 68, 224, 210, 129, 244, 152, 190, 182, 178, 247, 142, 200, 54, 61, 197, 59, 136]), (bytes [157, 243, 246, 1, 231, 124, 63, 187, 113, 83, 135, 59, 185, 176, 92, 154, 19, 95, 23, 144, 39, 18, 116, 243, 148, 33, 40, 76, 72, 135, 179, 217]), (bytes [215, 235, 228, 195, 126, 67, 73, 117, 240, 48, 198, 153, 149, 10, 116, 211, 229, 187, 72, 167, 138, 70, 233, 6, 198, 196, 67, 132, 227, 126, 249, 237]), (bytes [155, 46, 222, 79, 160, 132, 118, 83, 92, 71, 119, 54, 198, 8, 141, 171, 147, 66, 60, 77, 68, 15, 109, 158, 26, 159, 53, 144, 233, 162, 202, 146]), (bytes [183, 229, 214, 38, 2, 127, 216, 184, 77, 254, 138, 78, 137, 131, 89, 214, 211, 90, 100, 35, 45, 51, 180, 50, 190, 176, 83, 112, 101, 23, 181, 170]), (bytes [121, 173, 212, 206, 43, 62, 110, 188, 123, 202, 190, 163, 124, 203, 14, 8, 205, 10, 134, 22, 77, 113, 110, 162, 179, 102, 146, 84, 172, 188, 144, 247]), (bytes [134, 43, 219, 6, 234, 143, 97, 163, 132, 117, 241, 141, 98, 196, 41, 77, 3, 224, 76, 14, 112, 49, 93, 186, 30, 158, 156, 221, 192, 147, 18, 53]), (bytes [150, 176, 216, 226, 239, 79, 218, 77, 47, 25, 98, 54, 47, 52, 197, 168, 30, 126, 93, 34, 149, 210, 8, 114, 248, 27, 12, 14, 147, 154, 204, 250]), (bytes [83, 251, 49, 48, 54, 174, 206, 33, 38, 55, 53, 86, 238, 134, 67, 140, 194, 44, 73, 155, 93, 189, 217, 191, 38, 87, 214, 184, 137, 68, 230, 167]), (bytes [240, 212, 182, 90, 28, 28, 194, 255, 94, 159, 35, 103, 91, 242, 214, 20, 102, 217, 67, 85, 43, 252, 11, 32, 160, 11, 241, 164, 190, 14, 75, 153]), (bytes [83, 203, 23, 43, 120, 2, 138, 179, 201, 101, 117, 199, 249, 119, 150, 189, 107, 206, 100, 240, 241, 191, 29, 12, 95, 189, 46, 162, 173, 67, 52, 64]), (bytes [243, 18, 112, 16, 115, 206, 161, 217, 70, 120, 53, 168, 21, 217, 125, 177, 15, 184, 39, 220, 129, 252, 253, 217, 143, 169, 231, 204, 197, 173, 74, 44]), (bytes [174, 205, 154, 64, 243, 198, 70, 67, 132, 170, 211, 195, 186, 11, 96, 55, 55, 6, 248, 130, 169, 186, 214, 86, 104, 198, 34, 111, 234, 42, 133, 117]), (bytes [80, 237, 204, 122, 194, 130, 220, 252, 3, 111, 197, 112, 201, 6, 39, 55, 107, 14, 41, 172, 114, 110, 188, 233, 86, 120, 251, 235, 230, 110, 137, 34]), (bytes [64, 184, 77, 60, 124, 164, 54, 93, 23, 121, 89, 235, 81, 60, 107, 51, 86, 73, 18, 40, 80, 16, 45, 151, 39, 61, 175, 64, 40, 48, 21, 239]), (bytes [12, 243, 124, 85, 184, 138, 62, 99, 176, 174, 57, 188, 133, 173, 127, 231, 9, 202, 235, 153, 59, 220, 215, 127, 240, 138, 226, 158, 18, 89, 217, 143]), (bytes [145, 99, 191, 35, 121, 90, 118, 57, 187, 82, 200, 99, 201, 117, 132, 16, 109, 95, 126, 62, 89, 129, 183, 210, 46, 8, 148, 208, 73, 204, 191, 238])], familyDigest := (bytes [70, 190, 119, 237, 36, 24, 10, 255, 89, 160, 80, 108, 23, 145, 105, 211, 62, 238, 219, 129, 146, 61, 176, 70, 36, 218, 198, 73, 69, 147, 187, 137]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [70, 190, 119, 237, 36, 24, 10, 255, 89, 160, 80, 108, 23, 145, 105, 211, 62, 238, 219, 129, 146, 61, 176, 70, 36, 218, 198, 73, 69, 147, 187, 137]), layoutVersion := 1, digest := (bytes [223, 12, 232, 107, 103, 109, 239, 254, 232, 159, 134, 133, 162, 7, 6, 93, 43, 61, 94, 124, 24, 133, 145, 222, 17, 11, 39, 186, 227, 136, 222, 49]) }, logicalIndex := 0, digest := (bytes [181, 209, 216, 196, 249, 234, 132, 147, 93, 249, 188, 78, 137, 39, 111, 159, 36, 223, 189, 242, 193, 195, 223, 81, 244, 157, 13, 96, 136, 118, 229, 69]) }, valueDigest := (bytes [129, 16, 11, 76, 253, 155, 142, 28, 89, 240, 19, 169, 171, 115, 101, 224, 73, 120, 86, 195, 27, 185, 106, 175, 64, 231, 190, 170, 187, 57, 144, 129]), digest := (bytes [50, 238, 42, 133, 107, 34, 54, 70, 10, 53, 197, 4, 106, 27, 119, 32, 0, 4, 236, 119, 96, 117, 207, 30, 209, 141, 155, 246, 5, 255, 61, 231]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [70, 190, 119, 237, 36, 24, 10, 255, 89, 160, 80, 108, 23, 145, 105, 211, 62, 238, 219, 129, 146, 61, 176, 70, 36, 218, 198, 73, 69, 147, 187, 137]), layoutVersion := 1, digest := (bytes [223, 12, 232, 107, 103, 109, 239, 254, 232, 159, 134, 133, 162, 7, 6, 93, 43, 61, 94, 124, 24, 133, 145, 222, 17, 11, 39, 186, 227, 136, 222, 49]) }, logicalIndex := 6, digest := (bytes [179, 55, 245, 26, 249, 15, 28, 32, 239, 95, 29, 215, 250, 6, 235, 143, 12, 253, 38, 245, 111, 6, 153, 38, 208, 180, 243, 114, 202, 234, 176, 118]) }, valueDigest := (bytes [57, 167, 127, 66, 29, 28, 1, 62, 111, 174, 45, 82, 212, 157, 25, 154, 254, 72, 204, 85, 223, 7, 138, 44, 48, 11, 222, 83, 122, 239, 183, 120]), digest := (bytes [2, 131, 66, 126, 27, 244, 0, 68, 253, 150, 147, 11, 191, 45, 95, 27, 113, 76, 223, 152, 32, 11, 185, 143, 34, 76, 74, 206, 33, 197, 20, 254]) }), digest := (bytes [37, 8, 78, 14, 146, 205, 65, 159, 184, 239, 247, 118, 54, 105, 79, 220, 185, 208, 0, 155, 34, 183, 214, 251, 219, 121, 128, 94, 200, 126, 158, 249]) }
  , rootLaneCommitment := { timeLen := 7, commitments := { commitmentCount := 38, digest := (bytes [242, 91, 154, 59, 179, 31, 205, 226, 106, 197, 36, 140, 227, 67, 214, 106, 172, 86, 15, 141, 54, 207, 214, 226, 236, 63, 189, 77, 236, 136, 221, 41]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [242, 91, 154, 59, 179, 31, 205, 226, 106, 197, 36, 140, 227, 67, 214, 106, 172, 86, 15, 141, 54, 207, 214, 226, 236, 63, 189, 77, 236, 136, 221, 41]), layoutVersion := 3, digest := (bytes [196, 194, 83, 41, 254, 85, 154, 3, 27, 133, 154, 198, 75, 41, 176, 38, 251, 138, 26, 245, 43, 23, 149, 221, 37, 126, 131, 135, 61, 219, 245, 126]) }, logicalIndex := 0, digest := (bytes [18, 182, 151, 108, 176, 139, 62, 254, 180, 178, 194, 184, 131, 85, 158, 49, 199, 77, 210, 40, 135, 44, 158, 184, 74, 173, 44, 24, 177, 94, 55, 54]) }, valueDigest := (bytes [129, 16, 11, 76, 253, 155, 142, 28, 89, 240, 19, 169, 171, 115, 101, 224, 73, 120, 86, 195, 27, 185, 106, 175, 64, 231, 190, 170, 187, 57, 144, 129]), digest := (bytes [172, 1, 44, 77, 105, 92, 145, 74, 215, 231, 41, 237, 112, 208, 85, 46, 7, 45, 204, 78, 158, 105, 59, 123, 2, 171, 181, 78, 110, 138, 150, 6]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [242, 91, 154, 59, 179, 31, 205, 226, 106, 197, 36, 140, 227, 67, 214, 106, 172, 86, 15, 141, 54, 207, 214, 226, 236, 63, 189, 77, 236, 136, 221, 41]), layoutVersion := 3, digest := (bytes [196, 194, 83, 41, 254, 85, 154, 3, 27, 133, 154, 198, 75, 41, 176, 38, 251, 138, 26, 245, 43, 23, 149, 221, 37, 126, 131, 135, 61, 219, 245, 126]) }, logicalIndex := 6, digest := (bytes [10, 223, 129, 108, 227, 203, 154, 145, 141, 129, 215, 247, 157, 208, 180, 255, 202, 36, 10, 231, 89, 215, 159, 81, 120, 177, 99, 161, 55, 22, 112, 57]) }, valueDigest := (bytes [57, 167, 127, 66, 29, 28, 1, 62, 111, 174, 45, 82, 212, 157, 25, 154, 254, 72, 204, 85, 223, 7, 138, 44, 48, 11, 222, 83, 122, 239, 183, 120]), digest := (bytes [92, 219, 197, 231, 121, 26, 25, 227, 146, 19, 85, 137, 42, 97, 157, 106, 111, 249, 53, 54, 34, 115, 103, 115, 189, 185, 106, 22, 129, 42, 59, 71]) }), digest := (bytes [84, 208, 93, 185, 245, 39, 103, 192, 242, 100, 29, 19, 49, 87, 23, 220, 246, 252, 36, 11, 90, 91, 215, 1, 154, 23, 178, 107, 196, 135, 122, 112]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [37, 8, 78, 14, 146, 205, 65, 159, 184, 239, 247, 118, 54, 105, 79, 220, 185, 208, 0, 155, 34, 183, 214, 251, 219, 121, 128, 94, 200, 126, 158, 249]), rootLaneCommitmentDigest := (bytes [84, 208, 93, 185, 245, 39, 103, 192, 242, 100, 29, 19, 49, 87, 23, 220, 246, 252, 36, 11, 90, 91, 215, 1, 154, 23, 178, 107, 196, 135, 122, 112]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 7, digest := (bytes [217, 193, 32, 88, 183, 117, 187, 140, 85, 37, 144, 64, 64, 78, 9, 138, 114, 53, 75, 81, 119, 141, 235, 113, 84, 219, 104, 242, 125, 236, 59, 214]) }, statementDigest := (bytes [177, 220, 4, 67, 98, 192, 66, 110, 152, 145, 91, 155, 208, 155, 27, 227, 143, 244, 99, 43, 231, 16, 238, 72, 148, 55, 185, 189, 126, 164, 42, 76]), proofDigest := (bytes [166, 125, 197, 254, 250, 227, 216, 35, 70, 138, 144, 252, 36, 213, 196, 70, 147, 222, 207, 251, 149, 2, 79, 84, 23, 13, 145, 183, 128, 167, 96, 75]), digest := (bytes [147, 223, 38, 91, 91, 170, 19, 43, 67, 11, 53, 229, 189, 7, 194, 217, 136, 136, 124, 129, 140, 43, 14, 0, 118, 11, 65, 35, 152, 217, 42, 130]) }
  , digest := (bytes [128, 232, 234, 130, 162, 99, 245, 11, 117, 140, 17, 237, 240, 121, 40, 103, 216, 30, 129, 106, 141, 52, 147, 240, 241, 18, 212, 169, 151, 1, 239, 151])
}
    , transcript := {
  appLabel := (bytes [110, 101, 111, 46, 102, 111, 108, 100, 46, 110, 101, 120, 116, 47, 114, 118, 54, 52, 105, 109, 47, 112, 97, 114, 105, 116, 121, 95, 107, 101, 114, 110, 101, 108, 95, 118, 49])
  , events := [{
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 116, 114, 97, 110, 115, 99, 114, 105, 112, 116, 95, 115, 101, 101, 100])
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 110, 97, 114, 114, 111, 119, 45, 109, 101, 109, 111, 114, 121, 45, 108, 111, 97, 100, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [12799906354652525, 13922211188535148, 8175347121317401730, 8308484394106086806, 5884511499246010210, 7998233416229622215, 6964649998063382141, 1153192176276551949], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [110, 97, 114, 114, 111, 119, 95, 109, 101, 109, 111, 114, 121, 95, 108, 111, 97, 100, 95, 101, 120, 116, 114, 97, 99, 116, 95, 101, 120, 116, 101, 110, 100, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [12799906354652525, 13922211188535148, 8175347121317401730, 8308484394106086806, 5884511499246010210, 7998233416229622215, 6964649998063382141, 1153192176276551949], absorbed := 2 }
  , cursorAfter := { stateWords := [28533857601287288, 1819042147, 13405346572071477917, 15027069468260443345, 4657219632283511591, 13009867408141909840, 4570646721011936107, 9340009794846925166], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [327811, 1392899, 332163, 2445827, 336515, 4547331, 115]
  , cursorBefore := { stateWords := [28533857601287288, 1819042147, 13405346572071477917, 15027069468260443345, 4657219632283511591, 13009867408141909840, 4570646721011936107, 9340009794846925166], absorbed := 2 }
  , cursorAfter := { stateWords := [115, 0, 18158569649085369217, 4324689580891859743, 10837909801324925519, 629902553474001713, 11675622141450684452, 7267351139728427145], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 12288, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [115, 0, 18158569649085369217, 4324689580891859743, 10837909801324925519, 629902553474001713, 11675622141450684452, 7267351139728427145], absorbed := 2 }
  , cursorAfter := { stateWords := [3830413514925331899, 15686288481201580579, 4012207186557823599, 15735477179778979507, 17069698027905491847, 15814070235405475754, 820753214640218683, 3850378618103265605], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := [12288, 9920249032750366975]
  , cursorBefore := { stateWords := [3830413514925331899, 15686288481201580579, 4012207186557823599, 15735477179778979507, 17069698027905491847, 15814070235405475754, 820753214640218683, 3850378618103265605], absorbed := 0 }
  , cursorAfter := { stateWords := [2155839743, 2309737967, 17016907635301106391, 499923465555411882, 13196496673628649080, 4039687380468766989, 8511621768432349814, 1763263620507366255], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [67, 149, 212, 203, 125, 6, 193, 148, 95, 242, 87, 131, 79, 199, 154, 105, 62, 65, 66, 99, 45, 14, 202, 150, 24, 19, 22, 127, 80, 126, 57, 58])
  , u64s := []
  , cursorBefore := { stateWords := [2155839743, 2309737967, 17016907635301106391, 499923465555411882, 13196496673628649080, 4039687380468766989, 8511621768432349814, 1763263620507366255], absorbed := 2 }
  , cursorAfter := { stateWords := [976846416, 11042167288883101657, 9351894048581840145, 7006946695586167544, 17289545109842428286, 12963296847801935423, 15745235796732095321, 13267867589393505093], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [976846416, 11042167288883101657, 9351894048581840145, 7006946695586167544, 17289545109842428286, 12963296847801935423, 15745235796732095321, 13267867589393505093], absorbed := 1 }
  , cursorAfter := { stateWords := [6021918011723055633, 1314817092102069106, 12426851555635967853, 10353416768809675651, 17337105125606089765, 2918732584938148215, 14472588237035002733, 8229608136258886321], absorbed := 0 }
  , challengeOutput := (some 6021918011723055633)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [233, 196, 203, 200, 70, 58, 121, 64, 190, 77, 215, 109, 211, 207, 110, 212, 227, 39, 71, 54, 50, 7, 179, 37, 204, 185, 66, 14, 130, 114, 51, 240])
  , u64s := []
  , cursorBefore := { stateWords := [6021918011723055633, 1314817092102069106, 12426851555635967853, 10353416768809675651, 17337105125606089765, 2918732584938148215, 14472588237035002733, 8229608136258886321], absorbed := 0 }
  , cursorAfter := { stateWords := [14133428075353198, 4014015435354887, 4029903490, 16838230519069327746, 4085405358271329919, 14228927208023853474, 107353801817462348, 1952929269162220252], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [14133428075353198, 4014015435354887, 4029903490, 16838230519069327746, 4085405358271329919, 14228927208023853474, 107353801817462348, 1952929269162220252], absorbed := 3 }
  , cursorAfter := { stateWords := [12166816141915752516, 15419316117070074829, 2047636294008387338, 7699572410557338177, 13310677340565681106, 17751688798917587722, 14344274668446917168, 15533352597549184691], absorbed := 0 }
  , challengeOutput := (some 12166816141915752516)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [12166816141915752516, 15419316117070074829, 2047636294008387338, 7699572410557338177, 13310677340565681106, 17751688798917587722, 14344274668446917168, 15533352597549184691], absorbed := 0 }
  , cursorAfter := { stateWords := [4582133116042247748, 8731322839414209506, 1662529965242248010, 8418892417039773871, 9000361494525483189, 13638806656306225915, 1570254867137968212, 6077116453526416551], absorbed := 0 }
  , challengeOutput := (some 4582133116042247748)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [133, 91, 57, 33, 9, 81, 232, 147, 233, 248, 11, 52, 22, 187, 82, 147, 231, 35, 101, 212, 42, 7, 126, 94, 3, 54, 201, 128, 233, 222, 146, 92])
  , u64s := []
  , cursorBefore := { stateWords := [4582133116042247748, 8731322839414209506, 1662529965242248010, 8418892417039773871, 9000361494525483189, 13638806656306225915, 1570254867137968212, 6077116453526416551], absorbed := 0 }
  , cursorAfter := { stateWords := [12055479881012050, 36250030840905223, 1553129193, 7433689907473488653, 5965175124267803640, 14792457317794278921, 605774587042402052, 3412124567993221433], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [12055479881012050, 36250030840905223, 1553129193, 7433689907473488653, 5965175124267803640, 14792457317794278921, 605774587042402052, 3412124567993221433], absorbed := 3 }
  , cursorAfter := { stateWords := [13816550690510729125, 18101985310251038407, 9608517073677775066, 2584218457954885402, 2407808902030683260, 13628125446280137751, 3448376294072599785, 4693705293099813145], absorbed := 0 }
  , challengeOutput := (some 13816550690510729125)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [13, 62, 18, 231, 159, 216, 74, 146, 123, 100, 48, 154, 55, 62, 243, 77, 247, 72, 183, 146, 55, 128, 226, 205, 79, 61, 249, 159, 174, 184, 114, 0])
  , u64s := []
  , cursorBefore := { stateWords := [13816550690510729125, 18101985310251038407, 9608517073677775066, 2584218457954885402, 2407808902030683260, 13628125446280137751, 3448376294072599785, 4693705293099813145], absorbed := 0 }
  , cursorAfter := { stateWords := [15642439619923443, 45028563024208512, 7518382, 8361902626686925691, 2225358803819603115, 9245944133697156672, 1336650474291237605, 4811421835623193385], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [187, 211, 69, 135, 229, 127, 64, 102, 85, 14, 246, 26, 208, 214, 247, 252, 184, 3, 119, 82, 89, 137, 101, 38, 31, 135, 97, 182, 171, 175, 16, 207])
  , u64s := []
  , cursorBefore := { stateWords := [15642439619923443, 45028563024208512, 7518382, 8361902626686925691, 2225358803819603115, 9245944133697156672, 1336650474291237605, 4811421835623193385], absorbed := 3 }
  , cursorAfter := { stateWords := [25141944044289271, 51335678732428681, 3473977259, 13731804578639336113, 10961016839209921425, 18130052512516982862, 4673728544040845705, 16203916050884902499], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [183, 99, 121, 135, 139, 0, 186, 237, 83, 70, 165, 225, 69, 94, 88, 23, 106, 225, 174, 203, 176, 128, 255, 252, 189, 21, 5, 237, 46, 123, 103, 80])
  , u64s := []
  , cursorBefore := { stateWords := [25141944044289271, 51335678732428681, 3473977259, 13731804578639336113, 10961016839209921425, 18130052512516982862, 4673728544040845705, 16203916050884902499], absorbed := 3 }
  , cursorAfter := { stateWords := [49763547867649880, 66715160420351872, 1348959022, 15709606489153929614, 8121674917799648079, 15710361591141068338, 9590642781091900839, 9242433929454591953], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [49763547867649880, 66715160420351872, 1348959022, 15709606489153929614, 8121674917799648079, 15710361591141068338, 9590642781091900839, 9242433929454591953], absorbed := 3 }
  , cursorAfter := { stateWords := [5089522495975454261, 1105680697028675754, 17663795333069901089, 8984707892722831397, 9570329054447077234, 10004337964861211153, 5155669186334908773, 10948998427876731888], absorbed := 0 }
  , challengeOutput := (some 5089522495975454261)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [5089522495975454261, 1105680697028675754, 17663795333069901089, 8984707892722831397, 9570329054447077234, 10004337964861211153, 5155669186334908773, 10948998427876731888], absorbed := 0 }
  , cursorAfter := { stateWords := [6705451615684752047, 259196052256607845, 13875982187815904043, 7900743909553083362, 7968206663224187973, 14127116662389960561, 13263370867764124287, 16247986710756250182], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [175, 114, 117, 171, 183, 140, 14, 93, 101, 78, 240, 173, 111, 217, 152, 3, 43, 35, 106, 30, 72, 100, 145, 192, 226, 19, 62, 206, 185, 20, 165, 109]))
}]
}
    , stage1 := stage1
    , stage2 := stage2
    , stage3 := stage3
    , rootExecution := rootExecution
    , stepComposition := stepComposition
    , soundnessAccounting := soundnessAccounting
    , kernelOpeningBundle := kernelOpeningBundle
    , digest := (bytes [30, 174, 128, 27, 28, 94, 212, 88, 29, 233, 42, 105, 213, 157, 156, 212, 62, 158, 140, 195, 196, 149, 138, 67, 123, 145, 73, 48, 180, 220, 131, 199])
  }

end Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors.Case_narrow_memory_load_extract_extend_ecall
