import Nightstream.Rv64IM.Generated.AcceptedProofArtifactTypes

set_option maxHeartbeats 0
set_option maxRecDepth 65536

namespace Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors.Case_native_shift_chain_ecall

open Nightstream.Rv64IM.Generated

def stage1SemInputs : List SemInView :=
  [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, pc := 0, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 1, archRdBefore := 0, archImm := 1, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 1, rdBefore := 0, rdAfter := 1, imm := 1, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, pc := 4, opcode := .slli, traceOpcode := (some .slli), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 1, archRs1Value := 1, archRs2 := 0, archRs2Value := 0, archRd := 2, archRdBefore := 0, archImm := 4, rs1 := 1, rs1Value := 1, rs2 := 0, rs2Value := 0, rd := 2, rdBefore := 0, rdAfter := 16, imm := 4, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, pc := 8, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 3, archRdBefore := 0, archImm := -16, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 3, rdBefore := 0, rdAfter := 18446744073709551600, imm := -16, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, pc := 12, opcode := .srli, traceOpcode := (some .srli), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 2, archRs1Value := 16, archRs2 := 0, archRs2Value := 0, archRd := 4, archRdBefore := 0, archImm := 2, rs1 := 2, rs1Value := 16, rs2 := 0, rs2Value := 0, rd := 4, rdBefore := 0, rdAfter := 4, imm := 2, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 4, stepIndex := 4, sequenceIndex := 0, pc := 16, opcode := .srai, traceOpcode := (some .srai), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 3, archRs1Value := 18446744073709551600, archRs2 := 0, archRs2Value := 0, archRd := 5, archRdBefore := 0, archImm := 2, rs1 := 3, rs1Value := 18446744073709551600, rs2 := 0, rs2Value := 0, rd := 5, rdBefore := 0, rdAfter := 18446744073709551612, imm := 2, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 5, stepIndex := 5, sequenceIndex := 0, pc := 20, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 6, archRdBefore := 0, archImm := 3, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 6, rdBefore := 0, rdAfter := 3, imm := 3, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 6, stepIndex := 6, sequenceIndex := 0, pc := 24, opcode := .sll, traceOpcode := (some .sll), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 1, archRs1Value := 1, archRs2 := 6, archRs2Value := 3, archRd := 7, archRdBefore := 0, archImm := 0, rs1 := 1, rs1Value := 1, rs2 := 6, rs2Value := 3, rd := 7, rdBefore := 0, rdAfter := 8, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 7, stepIndex := 7, sequenceIndex := 0, pc := 28, opcode := .srl, traceOpcode := (some .srl), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 2, archRs1Value := 16, archRs2 := 6, archRs2Value := 3, archRd := 8, archRdBefore := 0, archImm := 0, rs1 := 2, rs1Value := 16, rs2 := 6, rs2Value := 3, rd := 8, rdBefore := 0, rdAfter := 2, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 8, stepIndex := 8, sequenceIndex := 0, pc := 32, opcode := .sra, traceOpcode := (some .sra), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 3, archRs1Value := 18446744073709551600, archRs2 := 6, archRs2Value := 3, archRd := 9, archRdBefore := 0, archImm := 0, rs1 := 3, rs1Value := 18446744073709551600, rs2 := 6, rs2Value := 3, rd := 9, rdBefore := 0, rdAfter := 18446744073709551614, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 9, stepIndex := 9, sequenceIndex := 0, pc := 36, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 0, archRdBefore := 0, archImm := 0, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 0, rdBefore := 0, rdAfter := 0, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := false, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }]

def stage1RowBindings : List Stage1RowBindingView :=
  [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 1048723, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 4, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 1, rdAfter := 1, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 4231443, opcode := .slli, traceOpcode := (some .slli), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 8, aluResult := 16, effectiveAddr := none, writesRd := true, rd := 2, rdAfter := 16, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 4278190483, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 12, aluResult := 18446744073709551600, effectiveAddr := none, writesRd := true, rd := 3, rdAfter := 18446744073709551600, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 12, fetchedWord := 2183699, opcode := .srli, traceOpcode := (some .srli), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 16, aluResult := 4, effectiveAddr := none, writesRd := true, rd := 4, rdAfter := 4, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 4, stepIndex := 4, sequenceIndex := 0, fetchPc := 16, fetchedWord := 1075958419, opcode := .srai, traceOpcode := (some .srai), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 20, aluResult := 18446744073709551612, effectiveAddr := none, writesRd := true, rd := 5, rdAfter := 18446744073709551612, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 5, stepIndex := 5, sequenceIndex := 0, fetchPc := 20, fetchedWord := 3146515, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 24, aluResult := 3, effectiveAddr := none, writesRd := true, rd := 6, rdAfter := 3, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 6, stepIndex := 6, sequenceIndex := 0, fetchPc := 24, fetchedWord := 6329267, opcode := .sll, traceOpcode := (some .sll), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 28, aluResult := 8, effectiveAddr := none, writesRd := true, rd := 7, rdAfter := 8, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 7, stepIndex := 7, sequenceIndex := 0, fetchPc := 28, fetchedWord := 6378547, opcode := .srl, traceOpcode := (some .srl), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 32, aluResult := 2, effectiveAddr := none, writesRd := true, rd := 8, rdAfter := 2, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 8, stepIndex := 8, sequenceIndex := 0, fetchPc := 32, fetchedWord := 1080153267, opcode := .sra, traceOpcode := (some .sra), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 36, aluResult := 18446744073709551614, effectiveAddr := none, writesRd := true, rd := 9, rdAfter := 18446744073709551614, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 9, stepIndex := 9, sequenceIndex := 0, fetchPc := 36, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 40, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }]

def stage1 : Stage1ProofBundleView :=
  {
    semInputs := stage1SemInputs
    , rowBindings := stage1RowBindings
    , bytecodeDigest := (bytes [90, 146, 193, 238, 80, 140, 248, 123, 226, 204, 239, 127, 87, 27, 97, 48, 237, 19, 98, 220, 45, 228, 172, 153, 8, 190, 142, 18, 17, 89, 153, 98])
    , aluDigest := (bytes [39, 212, 49, 19, 63, 118, 215, 170, 227, 21, 165, 47, 39, 151, 216, 207, 178, 71, 171, 82, 111, 214, 203, 14, 117, 94, 216, 106, 99, 82, 182, 77])
    , branchDigest := (bytes [94, 148, 1, 97, 74, 179, 242, 61, 162, 127, 118, 177, 243, 32, 27, 47, 196, 163, 200, 4, 228, 228, 252, 65, 25, 55, 95, 58, 189, 168, 170, 174])
    , semantics := { semInputsDigest := (bytes [247, 122, 72, 239, 151, 182, 78, 253, 77, 9, 147, 208, 30, 18, 12, 181, 218, 129, 97, 89, 183, 255, 43, 89, 247, 129, 102, 35, 155, 8, 131, 159]), rowBindingsDigest := (bytes [158, 163, 101, 188, 56, 157, 11, 23, 61, 89, 26, 18, 103, 71, 16, 23, 24, 22, 85, 94, 206, 123, 8, 30, 229, 175, 16, 104, 221, 141, 44, 252]), sequenceCount := 10, helperRowCount := 0, digest := (bytes [151, 26, 151, 39, 124, 116, 251, 245, 14, 224, 230, 5, 28, 66, 72, 52, 144, 83, 173, 217, 174, 78, 251, 55, 16, 70, 112, 160, 241, 74, 197, 167]) }
    , addressCorrectnessDigest := (bytes [124, 8, 210, 113, 26, 151, 220, 190, 134, 55, 27, 235, 164, 162, 85, 26, 89, 53, 209, 206, 189, 104, 102, 160, 85, 165, 20, 88, 246, 66, 167, 89])
    , linkageDigest := (bytes [99, 49, 93, 111, 245, 42, 150, 245, 130, 178, 204, 87, 236, 255, 150, 172, 63, 114, 197, 114, 218, 32, 140, 125, 3, 183, 201, 52, 236, 15, 95, 159])
    , selectedOpening := { claim := { rowsFamilyDigest := (bytes [158, 163, 101, 188, 56, 157, 11, 23, 61, 89, 26, 18, 103, 71, 16, 23, 24, 22, 85, 94, 206, 123, 8, 30, 229, 175, 16, 104, 221, 141, 44, 252]), rowCount := 10, effectRowCount := 10, commitRowCount := 10, realRowCount := 10, preservesX0Count := 1, firstTraceIndex := 0, effectTraceIndex := 0, commitTraceIndex := 0, lastTraceIndex := 9, mix := 16691009948854132645, points := { first := { id := { object := { familyTag := 1, commitmentDigest := (bytes [158, 163, 101, 188, 56, 157, 11, 23, 61, 89, 26, 18, 103, 71, 16, 23, 24, 22, 85, 94, 206, 123, 8, 30, 229, 175, 16, 104, 221, 141, 44, 252]), layoutVersion := 1, digest := (bytes [0, 52, 72, 229, 153, 109, 115, 236, 61, 244, 24, 126, 235, 57, 67, 252, 11, 173, 144, 72, 230, 250, 214, 113, 82, 73, 47, 103, 241, 121, 17, 106]) }, logicalIndex := 0, digest := (bytes [45, 69, 211, 59, 221, 13, 170, 212, 26, 85, 162, 208, 193, 47, 242, 66, 242, 144, 206, 163, 27, 225, 110, 108, 61, 42, 168, 213, 255, 209, 12, 173]) }, valueDigest := (bytes [32, 177, 93, 4, 194, 84, 97, 173, 64, 18, 168, 81, 246, 234, 52, 254, 43, 233, 61, 198, 55, 106, 236, 15, 107, 29, 198, 148, 168, 64, 112, 25]), digest := (bytes [121, 151, 118, 117, 122, 23, 150, 103, 112, 35, 212, 189, 238, 24, 60, 242, 73, 233, 204, 103, 12, 119, 251, 155, 205, 131, 8, 124, 182, 146, 80, 85]) }, effect := { id := { object := { familyTag := 1, commitmentDigest := (bytes [158, 163, 101, 188, 56, 157, 11, 23, 61, 89, 26, 18, 103, 71, 16, 23, 24, 22, 85, 94, 206, 123, 8, 30, 229, 175, 16, 104, 221, 141, 44, 252]), layoutVersion := 1, digest := (bytes [0, 52, 72, 229, 153, 109, 115, 236, 61, 244, 24, 126, 235, 57, 67, 252, 11, 173, 144, 72, 230, 250, 214, 113, 82, 73, 47, 103, 241, 121, 17, 106]) }, logicalIndex := 0, digest := (bytes [45, 69, 211, 59, 221, 13, 170, 212, 26, 85, 162, 208, 193, 47, 242, 66, 242, 144, 206, 163, 27, 225, 110, 108, 61, 42, 168, 213, 255, 209, 12, 173]) }, valueDigest := (bytes [32, 177, 93, 4, 194, 84, 97, 173, 64, 18, 168, 81, 246, 234, 52, 254, 43, 233, 61, 198, 55, 106, 236, 15, 107, 29, 198, 148, 168, 64, 112, 25]), digest := (bytes [121, 151, 118, 117, 122, 23, 150, 103, 112, 35, 212, 189, 238, 24, 60, 242, 73, 233, 204, 103, 12, 119, 251, 155, 205, 131, 8, 124, 182, 146, 80, 85]) }, commit := { id := { object := { familyTag := 1, commitmentDigest := (bytes [158, 163, 101, 188, 56, 157, 11, 23, 61, 89, 26, 18, 103, 71, 16, 23, 24, 22, 85, 94, 206, 123, 8, 30, 229, 175, 16, 104, 221, 141, 44, 252]), layoutVersion := 1, digest := (bytes [0, 52, 72, 229, 153, 109, 115, 236, 61, 244, 24, 126, 235, 57, 67, 252, 11, 173, 144, 72, 230, 250, 214, 113, 82, 73, 47, 103, 241, 121, 17, 106]) }, logicalIndex := 0, digest := (bytes [45, 69, 211, 59, 221, 13, 170, 212, 26, 85, 162, 208, 193, 47, 242, 66, 242, 144, 206, 163, 27, 225, 110, 108, 61, 42, 168, 213, 255, 209, 12, 173]) }, valueDigest := (bytes [32, 177, 93, 4, 194, 84, 97, 173, 64, 18, 168, 81, 246, 234, 52, 254, 43, 233, 61, 198, 55, 106, 236, 15, 107, 29, 198, 148, 168, 64, 112, 25]), digest := (bytes [121, 151, 118, 117, 122, 23, 150, 103, 112, 35, 212, 189, 238, 24, 60, 242, 73, 233, 204, 103, 12, 119, 251, 155, 205, 131, 8, 124, 182, 146, 80, 85]) }, last := { id := { object := { familyTag := 1, commitmentDigest := (bytes [158, 163, 101, 188, 56, 157, 11, 23, 61, 89, 26, 18, 103, 71, 16, 23, 24, 22, 85, 94, 206, 123, 8, 30, 229, 175, 16, 104, 221, 141, 44, 252]), layoutVersion := 1, digest := (bytes [0, 52, 72, 229, 153, 109, 115, 236, 61, 244, 24, 126, 235, 57, 67, 252, 11, 173, 144, 72, 230, 250, 214, 113, 82, 73, 47, 103, 241, 121, 17, 106]) }, logicalIndex := 9, digest := (bytes [50, 41, 21, 36, 79, 224, 187, 100, 93, 90, 77, 68, 217, 93, 32, 69, 207, 16, 65, 154, 55, 21, 150, 107, 200, 124, 69, 83, 7, 121, 206, 188]) }, valueDigest := (bytes [3, 109, 132, 95, 77, 141, 241, 196, 251, 53, 28, 178, 169, 7, 216, 110, 192, 41, 73, 187, 210, 96, 219, 41, 13, 120, 209, 99, 82, 190, 169, 70]), digest := (bytes [105, 50, 253, 68, 40, 37, 214, 107, 253, 136, 44, 199, 190, 112, 228, 46, 246, 241, 238, 153, 109, 26, 34, 22, 21, 74, 36, 151, 51, 173, 123, 200]) } }, digest := (bytes [95, 140, 37, 105, 124, 2, 152, 56, 224, 54, 119, 137, 176, 73, 205, 48, 125, 69, 28, 80, 201, 110, 14, 237, 114, 35, 50, 5, 223, 39, 38, 205]) }, packaged := { statementDigest := (bytes [47, 128, 203, 231, 59, 112, 142, 166, 71, 152, 27, 19, 29, 220, 0, 142, 221, 15, 233, 213, 14, 208, 160, 140, 27, 143, 137, 202, 147, 237, 163, 136]), proofDigest := (bytes [129, 46, 82, 186, 118, 122, 14, 22, 201, 58, 119, 178, 3, 72, 102, 160, 248, 30, 238, 0, 58, 106, 169, 202, 179, 232, 178, 76, 118, 113, 116, 140]) }, digest := (bytes [43, 186, 189, 15, 117, 33, 34, 68, 18, 3, 84, 129, 2, 91, 173, 225, 193, 37, 15, 208, 50, 249, 112, 52, 130, 65, 94, 111, 22, 73, 76, 78]) }
    , digest := (bytes [183, 79, 234, 200, 6, 31, 146, 207, 129, 22, 222, 146, 251, 23, 213, 54, 127, 41, 220, 170, 166, 12, 71, 14, 53, 86, 162, 204, 32, 217, 43, 255])
  }

def stage2RegisterReads : List RegisterReadEventView :=
  [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 0, value := 0 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 1, value := 1 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 0, value := 0 }, { traceIndex := 3, stepIndex := 3, role := .rs1, reg := 2, value := 16 }, { traceIndex := 4, stepIndex := 4, role := .rs1, reg := 3, value := 18446744073709551600 }, { traceIndex := 5, stepIndex := 5, role := .rs1, reg := 0, value := 0 }, { traceIndex := 6, stepIndex := 6, role := .rs1, reg := 1, value := 1 }, { traceIndex := 6, stepIndex := 6, role := .rs2, reg := 6, value := 3 }, { traceIndex := 7, stepIndex := 7, role := .rs1, reg := 2, value := 16 }, { traceIndex := 7, stepIndex := 7, role := .rs2, reg := 6, value := 3 }, { traceIndex := 8, stepIndex := 8, role := .rs1, reg := 3, value := 18446744073709551600 }, { traceIndex := 8, stepIndex := 8, role := .rs2, reg := 6, value := 3 }]

def stage2RegisterWrites : List RegisterWriteEventView :=
  [{ traceIndex := 0, stepIndex := 0, reg := 1, previous := 0, next := 1 }, { traceIndex := 1, stepIndex := 1, reg := 2, previous := 0, next := 16 }, { traceIndex := 2, stepIndex := 2, reg := 3, previous := 0, next := 18446744073709551600 }, { traceIndex := 3, stepIndex := 3, reg := 4, previous := 0, next := 4 }, { traceIndex := 4, stepIndex := 4, reg := 5, previous := 0, next := 18446744073709551612 }, { traceIndex := 5, stepIndex := 5, reg := 6, previous := 0, next := 3 }, { traceIndex := 6, stepIndex := 6, reg := 7, previous := 0, next := 8 }, { traceIndex := 7, stepIndex := 7, reg := 8, previous := 0, next := 2 }, { traceIndex := 8, stepIndex := 8, reg := 9, previous := 0, next := 18446744073709551614 }]

def stage2RamEvents : List RamEventView :=
  []

def stage2TwistLinks : List TwistLinkEventView :=
  [{ traceIndex := 0, stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 1, family := .nativeAlu, routedWriteValue := (some 16), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 2, family := .nativeAlu, routedWriteValue := (some 18446744073709551600), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 3, family := .nativeAlu, routedWriteValue := (some 4), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 4, stepIndex := 4, family := .nativeAlu, routedWriteValue := (some 18446744073709551612), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 5, stepIndex := 5, family := .nativeAlu, routedWriteValue := (some 3), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 6, stepIndex := 6, family := .nativeAlu, routedWriteValue := (some 8), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 7, stepIndex := 7, family := .nativeAlu, routedWriteValue := (some 2), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 8, stepIndex := 8, family := .nativeAlu, routedWriteValue := (some 18446744073709551614), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 9, stepIndex := 9, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]

def stage2 : Stage2ProofBundleView :=
  {
    registerReads := stage2RegisterReads
    , registerWrites := stage2RegisterWrites
    , ramEvents := stage2RamEvents
    , registerDigest := (bytes [7, 106, 167, 122, 1, 34, 179, 205, 224, 12, 180, 81, 175, 35, 11, 150, 58, 37, 252, 243, 164, 234, 198, 1, 131, 159, 39, 243, 11, 43, 86, 6])
    , ramDigest := (bytes [209, 217, 105, 43, 209, 229, 156, 61, 92, 164, 94, 232, 52, 214, 73, 229, 72, 188, 139, 122, 165, 123, 201, 212, 205, 15, 247, 197, 165, 154, 109, 246])
    , temporal := { twistLinks := stage2TwistLinks, registerTimelineDigest := (bytes [149, 207, 160, 167, 244, 151, 72, 64, 90, 113, 153, 114, 233, 245, 39, 4, 223, 12, 71, 42, 134, 228, 236, 75, 105, 238, 110, 12, 154, 188, 171, 252]), ramTimelineDigest := (bytes [8, 117, 17, 140, 128, 180, 240, 140, 250, 181, 90, 134, 147, 17, 197, 122, 220, 8, 66, 15, 193, 254, 11, 122, 115, 210, 233, 239, 55, 132, 31, 228]), twistLinksDigest := (bytes [171, 243, 51, 143, 173, 106, 254, 30, 219, 55, 26, 196, 61, 13, 95, 73, 168, 253, 76, 116, 86, 132, 193, 213, 117, 178, 26, 241, 188, 184, 106, 71]), digest := (bytes [190, 191, 201, 164, 30, 44, 16, 64, 202, 129, 93, 62, 161, 96, 58, 24, 64, 194, 160, 21, 219, 79, 192, 34, 114, 247, 79, 216, 55, 77, 25, 91]) }
    , semantics := { registerReadsFamilyDigest := (bytes [137, 183, 196, 241, 95, 89, 82, 192, 172, 131, 180, 249, 9, 148, 87, 40, 64, 80, 57, 25, 42, 64, 60, 131, 223, 218, 159, 114, 209, 108, 145, 47]), registerWritesFamilyDigest := (bytes [43, 129, 202, 135, 73, 122, 90, 134, 6, 237, 218, 161, 8, 109, 132, 165, 231, 111, 86, 176, 102, 72, 176, 21, 153, 115, 74, 131, 182, 19, 202, 131]), ramEventsFamilyDigest := (bytes [85, 17, 108, 38, 84, 5, 109, 213, 145, 137, 203, 96, 117, 127, 130, 193, 117, 29, 27, 219, 228, 58, 7, 214, 144, 155, 66, 38, 127, 8, 241, 95]), twistLinksFamilyDigest := (bytes [14, 119, 55, 101, 202, 254, 222, 221, 46, 69, 27, 94, 202, 248, 167, 143, 102, 180, 62, 254, 16, 242, 180, 180, 10, 68, 107, 103, 55, 61, 3, 127]), rowCount := 10, registerEventCount := 21, ramEventCount := 0, digest := (bytes [137, 78, 142, 226, 3, 128, 57, 191, 49, 91, 7, 13, 207, 183, 197, 131, 72, 166, 42, 115, 5, 69, 84, 159, 98, 148, 165, 72, 229, 105, 141, 120]) }
    , linkageDigest := (bytes [28, 150, 195, 115, 179, 178, 150, 51, 97, 169, 135, 178, 93, 70, 46, 44, 248, 106, 83, 221, 230, 156, 167, 137, 51, 157, 62, 155, 72, 211, 167, 159])
    , selectedOpening := { claim := { registerReadsFamilyDigest := (bytes [137, 183, 196, 241, 95, 89, 82, 192, 172, 131, 180, 249, 9, 148, 87, 40, 64, 80, 57, 25, 42, 64, 60, 131, 223, 218, 159, 114, 209, 108, 145, 47]), registerWritesFamilyDigest := (bytes [43, 129, 202, 135, 73, 122, 90, 134, 6, 237, 218, 161, 8, 109, 132, 165, 231, 111, 86, 176, 102, 72, 176, 21, 153, 115, 74, 131, 182, 19, 202, 131]), ramEventsFamilyDigest := (bytes [85, 17, 108, 38, 84, 5, 109, 213, 145, 137, 203, 96, 117, 127, 130, 193, 117, 29, 27, 219, 228, 58, 7, 214, 144, 155, 66, 38, 127, 8, 241, 95]), twistLinksFamilyDigest := (bytes [14, 119, 55, 101, 202, 254, 222, 221, 46, 69, 27, 94, 202, 248, 167, 143, 102, 180, 62, 254, 16, 242, 180, 180, 10, 68, 107, 103, 55, 61, 3, 127]), registerReadCount := 12, registerWriteCount := 9, ramEventCount := 0, twistLinkCount := 10, ramReadCount := 0, ramWriteCount := 0, regMix := 4919044041631935056, ramMix := 16264464362193895577, points := { firstRead := (some { id := { object := { familyTag := 2, commitmentDigest := (bytes [137, 183, 196, 241, 95, 89, 82, 192, 172, 131, 180, 249, 9, 148, 87, 40, 64, 80, 57, 25, 42, 64, 60, 131, 223, 218, 159, 114, 209, 108, 145, 47]), layoutVersion := 1, digest := (bytes [72, 162, 244, 24, 100, 166, 120, 156, 23, 202, 118, 239, 156, 128, 45, 218, 41, 214, 202, 224, 104, 51, 130, 43, 249, 194, 231, 93, 252, 0, 56, 107]) }, logicalIndex := 0, digest := (bytes [158, 218, 148, 215, 194, 198, 195, 75, 94, 35, 94, 122, 243, 49, 44, 174, 32, 60, 211, 73, 141, 146, 11, 20, 182, 81, 51, 84, 233, 173, 230, 192]) }, valueDigest := (bytes [165, 2, 50, 180, 56, 84, 68, 13, 37, 136, 82, 191, 49, 42, 150, 67, 180, 45, 199, 251, 168, 91, 53, 39, 20, 9, 70, 46, 155, 135, 100, 116]), digest := (bytes [187, 175, 61, 175, 147, 64, 136, 239, 52, 138, 244, 200, 67, 66, 84, 80, 1, 164, 129, 202, 79, 220, 126, 235, 219, 87, 14, 119, 248, 233, 101, 153]) }), lastRead := (some { id := { object := { familyTag := 2, commitmentDigest := (bytes [137, 183, 196, 241, 95, 89, 82, 192, 172, 131, 180, 249, 9, 148, 87, 40, 64, 80, 57, 25, 42, 64, 60, 131, 223, 218, 159, 114, 209, 108, 145, 47]), layoutVersion := 1, digest := (bytes [72, 162, 244, 24, 100, 166, 120, 156, 23, 202, 118, 239, 156, 128, 45, 218, 41, 214, 202, 224, 104, 51, 130, 43, 249, 194, 231, 93, 252, 0, 56, 107]) }, logicalIndex := 11, digest := (bytes [84, 254, 129, 75, 4, 93, 26, 145, 112, 84, 185, 211, 98, 97, 96, 57, 148, 44, 234, 167, 90, 176, 121, 236, 40, 220, 60, 48, 195, 85, 237, 160]) }, valueDigest := (bytes [142, 202, 136, 255, 46, 179, 201, 165, 20, 183, 113, 214, 35, 2, 19, 213, 120, 144, 226, 118, 55, 132, 177, 34, 99, 46, 16, 184, 101, 2, 160, 226]), digest := (bytes [141, 72, 22, 77, 229, 56, 152, 201, 245, 22, 129, 138, 47, 134, 221, 138, 5, 122, 180, 212, 195, 102, 102, 66, 208, 36, 38, 138, 95, 105, 130, 84]) }), firstWrite := (some { id := { object := { familyTag := 3, commitmentDigest := (bytes [43, 129, 202, 135, 73, 122, 90, 134, 6, 237, 218, 161, 8, 109, 132, 165, 231, 111, 86, 176, 102, 72, 176, 21, 153, 115, 74, 131, 182, 19, 202, 131]), layoutVersion := 1, digest := (bytes [207, 200, 67, 143, 194, 186, 82, 147, 80, 133, 146, 126, 216, 7, 114, 30, 1, 40, 209, 228, 117, 94, 102, 76, 120, 20, 58, 231, 113, 75, 143, 249]) }, logicalIndex := 0, digest := (bytes [241, 24, 89, 123, 212, 104, 113, 161, 3, 210, 156, 174, 136, 230, 39, 33, 160, 70, 154, 41, 15, 37, 178, 111, 122, 246, 39, 179, 76, 178, 74, 169]) }, valueDigest := (bytes [6, 10, 8, 56, 28, 171, 254, 84, 147, 137, 212, 118, 68, 203, 11, 50, 81, 93, 22, 116, 174, 122, 49, 175, 71, 153, 47, 12, 222, 137, 227, 111]), digest := (bytes [23, 127, 122, 143, 13, 66, 40, 50, 245, 145, 147, 185, 110, 175, 27, 111, 40, 30, 205, 156, 178, 23, 34, 83, 188, 48, 158, 211, 70, 79, 244, 96]) }), lastWrite := (some { id := { object := { familyTag := 3, commitmentDigest := (bytes [43, 129, 202, 135, 73, 122, 90, 134, 6, 237, 218, 161, 8, 109, 132, 165, 231, 111, 86, 176, 102, 72, 176, 21, 153, 115, 74, 131, 182, 19, 202, 131]), layoutVersion := 1, digest := (bytes [207, 200, 67, 143, 194, 186, 82, 147, 80, 133, 146, 126, 216, 7, 114, 30, 1, 40, 209, 228, 117, 94, 102, 76, 120, 20, 58, 231, 113, 75, 143, 249]) }, logicalIndex := 8, digest := (bytes [211, 177, 28, 203, 214, 102, 152, 198, 56, 42, 150, 34, 108, 203, 217, 101, 161, 115, 177, 197, 114, 94, 104, 30, 247, 255, 169, 153, 119, 245, 190, 62]) }, valueDigest := (bytes [141, 27, 165, 50, 20, 149, 86, 77, 137, 120, 28, 235, 16, 100, 35, 235, 253, 70, 26, 203, 86, 40, 135, 148, 201, 244, 128, 122, 71, 216, 78, 242]), digest := (bytes [64, 172, 126, 4, 251, 120, 96, 147, 88, 72, 240, 206, 44, 178, 29, 131, 0, 235, 62, 253, 119, 190, 43, 157, 72, 28, 108, 219, 47, 172, 118, 252]) }), firstRam := none, lastRam := none, firstTwist := (some { id := { object := { familyTag := 5, commitmentDigest := (bytes [14, 119, 55, 101, 202, 254, 222, 221, 46, 69, 27, 94, 202, 248, 167, 143, 102, 180, 62, 254, 16, 242, 180, 180, 10, 68, 107, 103, 55, 61, 3, 127]), layoutVersion := 1, digest := (bytes [117, 226, 161, 152, 205, 245, 222, 234, 202, 163, 91, 224, 39, 86, 100, 110, 77, 199, 72, 125, 165, 213, 86, 255, 17, 190, 238, 251, 237, 228, 170, 96]) }, logicalIndex := 0, digest := (bytes [4, 196, 247, 72, 210, 250, 215, 106, 91, 57, 254, 120, 209, 33, 59, 149, 146, 14, 88, 92, 50, 214, 41, 204, 19, 26, 2, 244, 233, 245, 164, 208]) }, valueDigest := (bytes [6, 253, 89, 93, 65, 90, 254, 218, 186, 126, 113, 33, 125, 252, 29, 228, 182, 189, 94, 78, 106, 243, 59, 186, 226, 215, 103, 192, 49, 144, 186, 83]), digest := (bytes [128, 44, 211, 183, 143, 172, 136, 92, 245, 143, 214, 170, 251, 152, 133, 109, 23, 7, 211, 37, 90, 124, 82, 168, 12, 252, 244, 141, 67, 66, 238, 225]) }), lastTwist := (some { id := { object := { familyTag := 5, commitmentDigest := (bytes [14, 119, 55, 101, 202, 254, 222, 221, 46, 69, 27, 94, 202, 248, 167, 143, 102, 180, 62, 254, 16, 242, 180, 180, 10, 68, 107, 103, 55, 61, 3, 127]), layoutVersion := 1, digest := (bytes [117, 226, 161, 152, 205, 245, 222, 234, 202, 163, 91, 224, 39, 86, 100, 110, 77, 199, 72, 125, 165, 213, 86, 255, 17, 190, 238, 251, 237, 228, 170, 96]) }, logicalIndex := 9, digest := (bytes [41, 67, 166, 77, 79, 216, 169, 103, 217, 90, 127, 96, 157, 35, 35, 175, 212, 56, 217, 71, 196, 218, 228, 190, 118, 193, 219, 103, 48, 40, 126, 42]) }, valueDigest := (bytes [184, 255, 167, 240, 204, 5, 153, 190, 24, 65, 177, 98, 226, 252, 181, 157, 223, 47, 9, 147, 45, 36, 211, 205, 140, 129, 150, 226, 78, 163, 212, 232]), digest := (bytes [200, 47, 1, 186, 229, 164, 226, 22, 161, 96, 111, 95, 99, 54, 210, 247, 46, 89, 237, 53, 99, 57, 105, 44, 112, 28, 37, 164, 146, 195, 227, 150]) }) }, digest := (bytes [35, 34, 58, 240, 45, 134, 167, 226, 204, 151, 82, 194, 136, 64, 14, 95, 247, 152, 33, 243, 133, 192, 161, 178, 126, 143, 93, 24, 94, 97, 53, 177]) }, packaged := { statementDigest := (bytes [215, 41, 176, 153, 50, 178, 149, 204, 147, 118, 73, 199, 179, 211, 1, 95, 38, 31, 225, 255, 86, 104, 23, 12, 241, 68, 252, 81, 230, 197, 114, 115]), proofDigest := (bytes [179, 21, 132, 63, 234, 17, 136, 113, 25, 34, 130, 126, 209, 173, 178, 212, 201, 158, 196, 198, 64, 72, 80, 31, 107, 176, 237, 187, 160, 232, 3, 63]) }, digest := (bytes [253, 241, 232, 168, 55, 211, 246, 203, 25, 241, 20, 54, 184, 114, 92, 233, 233, 199, 77, 26, 70, 65, 25, 201, 15, 55, 146, 156, 222, 134, 247, 183]) }
    , digest := (bytes [199, 248, 32, 188, 22, 30, 233, 137, 116, 185, 65, 234, 120, 181, 14, 82, 187, 86, 132, 186, 164, 115, 41, 67, 29, 169, 87, 165, 225, 181, 79, 12])
  }

def stage3Continuity : List ContinuityEventView :=
  [{ stepIndex := 0, pc := 0, nextPc := 4, successorPc := (some 4), finalStep := false, continuityHolds := true }, { stepIndex := 1, pc := 4, nextPc := 8, successorPc := (some 8), finalStep := false, continuityHolds := true }, { stepIndex := 2, pc := 8, nextPc := 12, successorPc := (some 12), finalStep := false, continuityHolds := true }, { stepIndex := 3, pc := 12, nextPc := 16, successorPc := (some 16), finalStep := false, continuityHolds := true }, { stepIndex := 4, pc := 16, nextPc := 20, successorPc := (some 20), finalStep := false, continuityHolds := true }, { stepIndex := 5, pc := 20, nextPc := 24, successorPc := (some 24), finalStep := false, continuityHolds := true }, { stepIndex := 6, pc := 24, nextPc := 28, successorPc := (some 28), finalStep := false, continuityHolds := true }, { stepIndex := 7, pc := 28, nextPc := 32, successorPc := (some 32), finalStep := false, continuityHolds := true }, { stepIndex := 8, pc := 32, nextPc := 36, successorPc := (some 36), finalStep := false, continuityHolds := true }, { stepIndex := 9, pc := 36, nextPc := 40, successorPc := none, finalStep := true, continuityHolds := true }]

def stage3 : Stage3ProofBundleView :=
  {
    continuity := stage3Continuity
    , halted := true
    , bridgeDigest := (bytes [234, 255, 95, 211, 168, 169, 254, 171, 204, 122, 250, 58, 177, 59, 96, 111, 240, 83, 223, 148, 250, 46, 48, 146, 154, 214, 163, 249, 200, 182, 254, 14])
    , semantics := { continuityDigest := (bytes [40, 20, 11, 209, 44, 224, 136, 31, 10, 28, 112, 124, 14, 145, 239, 109, 223, 30, 10, 171, 5, 157, 106, 119, 207, 23, 78, 198, 2, 147, 101, 194]), rootSemanticRowsDigest := (bytes [75, 77, 103, 212, 25, 254, 20, 245, 57, 91, 81, 194, 215, 249, 90, 89, 90, 201, 88, 167, 30, 245, 69, 113, 208, 31, 194, 44, 20, 39, 128, 155]), rowChunkRoutesDigest := (bytes [218, 161, 158, 255, 122, 203, 90, 133, 61, 184, 189, 186, 138, 38, 194, 63, 233, 205, 133, 32, 166, 190, 136, 71, 139, 40, 209, 171, 35, 80, 135, 137]), preparedStepBindingsDigest := (bytes [30, 164, 150, 41, 218, 111, 229, 43, 231, 221, 197, 31, 58, 29, 115, 85, 208, 133, 131, 125, 250, 253, 29, 48, 239, 226, 164, 136, 42, 31, 76, 180]), stage2TemporalDigest := (bytes [190, 191, 201, 164, 30, 44, 16, 64, 202, 129, 93, 62, 161, 96, 58, 24, 64, 194, 160, 21, 219, 79, 192, 34, 114, 247, 79, 216, 55, 77, 25, 91]), initialPc := 0, finalPc := 40, realRowCount := 10, firstRealStepIndex := 0, lastRealStepIndex := 9, digest := (bytes [186, 94, 144, 98, 86, 103, 74, 95, 114, 20, 200, 33, 117, 212, 95, 14, 198, 27, 110, 76, 101, 39, 107, 56, 57, 254, 247, 134, 184, 167, 71, 234]) }
    , linkageDigest := (bytes [253, 86, 226, 104, 97, 29, 177, 188, 97, 2, 126, 89, 196, 224, 243, 165, 214, 217, 187, 190, 202, 30, 22, 118, 64, 145, 189, 198, 205, 250, 149, 60])
    , selectedOpening := { claim := { continuityFamilyDigest := (bytes [217, 193, 83, 214, 118, 65, 78, 178, 227, 112, 101, 151, 14, 161, 23, 72, 150, 157, 75, 146, 177, 145, 203, 18, 192, 33, 50, 220, 2, 106, 203, 167]), continuityCount := 10, finalStepCount := 1, halted := true, allContinuityHold := true, continuityMix := 9654341997663817196, points := { firstContinuity := (some { id := { object := { familyTag := 6, commitmentDigest := (bytes [217, 193, 83, 214, 118, 65, 78, 178, 227, 112, 101, 151, 14, 161, 23, 72, 150, 157, 75, 146, 177, 145, 203, 18, 192, 33, 50, 220, 2, 106, 203, 167]), layoutVersion := 1, digest := (bytes [69, 108, 89, 7, 20, 24, 100, 46, 58, 241, 72, 143, 113, 68, 115, 149, 241, 11, 101, 41, 118, 93, 150, 186, 139, 13, 69, 31, 191, 144, 173, 203]) }, logicalIndex := 0, digest := (bytes [143, 211, 63, 161, 54, 246, 16, 190, 69, 96, 160, 45, 153, 150, 230, 127, 182, 3, 150, 75, 28, 46, 200, 22, 200, 108, 76, 200, 202, 200, 153, 24]) }, valueDigest := (bytes [7, 131, 85, 21, 57, 109, 53, 31, 137, 53, 98, 18, 170, 36, 28, 200, 149, 213, 171, 159, 119, 200, 36, 230, 30, 35, 30, 11, 252, 126, 240, 63]), digest := (bytes [139, 58, 228, 164, 6, 146, 9, 133, 139, 150, 254, 148, 30, 192, 180, 76, 74, 64, 179, 159, 153, 139, 230, 32, 196, 65, 65, 183, 253, 24, 255, 48]) }), lastContinuity := (some { id := { object := { familyTag := 6, commitmentDigest := (bytes [217, 193, 83, 214, 118, 65, 78, 178, 227, 112, 101, 151, 14, 161, 23, 72, 150, 157, 75, 146, 177, 145, 203, 18, 192, 33, 50, 220, 2, 106, 203, 167]), layoutVersion := 1, digest := (bytes [69, 108, 89, 7, 20, 24, 100, 46, 58, 241, 72, 143, 113, 68, 115, 149, 241, 11, 101, 41, 118, 93, 150, 186, 139, 13, 69, 31, 191, 144, 173, 203]) }, logicalIndex := 9, digest := (bytes [36, 52, 46, 77, 95, 139, 66, 56, 130, 250, 229, 206, 16, 188, 57, 67, 233, 188, 19, 227, 132, 247, 58, 14, 196, 102, 63, 79, 145, 81, 80, 147]) }, valueDigest := (bytes [207, 101, 181, 126, 107, 102, 134, 104, 5, 245, 166, 239, 177, 244, 175, 134, 54, 230, 129, 232, 147, 131, 128, 181, 24, 167, 101, 255, 131, 181, 87, 252]), digest := (bytes [44, 37, 183, 8, 92, 36, 214, 102, 14, 176, 77, 166, 201, 122, 192, 144, 23, 248, 193, 68, 182, 253, 190, 38, 161, 101, 61, 225, 169, 157, 64, 192]) }) }, digest := (bytes [255, 142, 57, 0, 142, 1, 205, 248, 51, 193, 121, 137, 136, 126, 124, 15, 236, 195, 0, 7, 245, 154, 233, 199, 27, 240, 192, 149, 126, 54, 196, 169]) }, packaged := { statementDigest := (bytes [200, 128, 79, 129, 37, 79, 215, 65, 9, 49, 238, 160, 194, 253, 252, 24, 20, 184, 158, 60, 38, 148, 150, 148, 69, 200, 98, 199, 251, 227, 30, 183]), proofDigest := (bytes [165, 144, 5, 9, 8, 203, 228, 238, 24, 178, 64, 36, 123, 239, 159, 242, 174, 0, 116, 13, 110, 186, 157, 53, 198, 28, 97, 91, 41, 87, 210, 116]) }, digest := (bytes [123, 200, 171, 142, 73, 227, 53, 197, 73, 245, 79, 164, 187, 42, 144, 179, 84, 250, 64, 72, 82, 210, 170, 82, 241, 181, 251, 189, 13, 255, 120, 86]) }
    , digest := (bytes [112, 238, 130, 232, 213, 172, 150, 186, 174, 246, 139, 102, 109, 45, 144, 12, 139, 147, 27, 111, 96, 223, 16, 126, 237, 108, 36, 44, 223, 62, 222, 24])
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
  , word := 4231443
  , opcode := .slli
  , traceOpcode := (some .slli)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 1
  , rs2 := 0
  , rs2Value := 0
  , rd := 2
  , rdBefore := 0
  , rdAfter := 16
  , imm := 4
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
  , word := 4278190483
  , opcode := .addi
  , traceOpcode := (some .addi)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 0
  , rs1Value := 0
  , rs2 := 0
  , rs2Value := 0
  , rd := 3
  , rdBefore := 0
  , rdAfter := 18446744073709551600
  , imm := -16
  , aluResult := 18446744073709551600
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
  , word := 2183699
  , opcode := .srli
  , traceOpcode := (some .srli)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 2
  , rs1Value := 16
  , rs2 := 0
  , rs2Value := 0
  , rd := 4
  , rdBefore := 0
  , rdAfter := 4
  , imm := 2
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
  traceIndex := 4
  , stepIndex := 4
  , sequenceIndex := 0
  , pc := 16
  , nextPc := 20
  , word := 1075958419
  , opcode := .srai
  , traceOpcode := (some .srai)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 3
  , rs1Value := 18446744073709551600
  , rs2 := 0
  , rs2Value := 0
  , rd := 5
  , rdBefore := 0
  , rdAfter := 18446744073709551612
  , imm := 2
  , aluResult := 18446744073709551612
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
  , word := 3146515
  , opcode := .addi
  , traceOpcode := (some .addi)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 0
  , rs1Value := 0
  , rs2 := 0
  , rs2Value := 0
  , rd := 6
  , rdBefore := 0
  , rdAfter := 3
  , imm := 3
  , aluResult := 3
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
  , word := 6329267
  , opcode := .sll
  , traceOpcode := (some .sll)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 1
  , rs2 := 6
  , rs2Value := 3
  , rd := 7
  , rdBefore := 0
  , rdAfter := 8
  , imm := 0
  , aluResult := 8
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
  traceIndex := 7
  , stepIndex := 7
  , sequenceIndex := 0
  , pc := 28
  , nextPc := 32
  , word := 6378547
  , opcode := .srl
  , traceOpcode := (some .srl)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 2
  , rs1Value := 16
  , rs2 := 6
  , rs2Value := 3
  , rd := 8
  , rdBefore := 0
  , rdAfter := 2
  , imm := 0
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
  traceIndex := 8
  , stepIndex := 8
  , sequenceIndex := 0
  , pc := 32
  , nextPc := 36
  , word := 1080153267
  , opcode := .sra
  , traceOpcode := (some .sra)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 3
  , rs1Value := 18446744073709551600
  , rs2 := 6
  , rs2Value := 3
  , rd := 9
  , rdBefore := 0
  , rdAfter := 18446744073709551614
  , imm := 0
  , aluResult := 18446744073709551614
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
  traceIndex := 9
  , stepIndex := 9
  , sequenceIndex := 0
  , pc := 36
  , nextPc := 40
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
  [{ traceIndex := 0, values := [1, 0, 0, 4, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 4, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [48, 9, 158, 59, 120, 45, 200, 155, 8, 144, 252, 183, 179, 168, 71, 138, 10, 136, 117, 72, 217, 133, 28, 26, 240, 134, 159, 61, 227, 8, 46, 227]), digest := (bytes [77, 97, 131, 255, 203, 134, 45, 198, 175, 166, 39, 170, 211, 141, 143, 44, 217, 157, 82, 58, 43, 137, 198, 85, 25, 93, 188, 205, 7, 120, 191, 196]) }, { traceIndex := 1, values := [1, 4, 0, 8, 0, 1, 0, 0, 0, 16, 0, 4, 0, 16, 0, 8, 0, 0, 0, 0, 0, 0, 0, 2, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [73, 162, 38, 137, 65, 140, 229, 252, 172, 76, 117, 117, 82, 151, 171, 214, 113, 75, 179, 86, 158, 113, 70, 129, 8, 46, 52, 201, 80, 235, 175, 101]), digest := (bytes [19, 136, 56, 5, 160, 108, 125, 202, 70, 213, 102, 26, 157, 63, 148, 33, 228, 255, 23, 1, 203, 192, 249, 132, 181, 55, 159, 16, 221, 178, 233, 135]) }, { traceIndex := 2, values := [1, 8, 0, 12, 0, 0, 0, 0, 0, 4294967280, 4294967295, 4294967280, 4294967295, 4294967280, 4294967295, 12, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [218, 117, 75, 56, 173, 248, 187, 88, 181, 227, 90, 121, 198, 202, 10, 220, 141, 92, 138, 241, 113, 191, 17, 88, 214, 216, 9, 179, 38, 177, 152, 168]), digest := (bytes [249, 3, 215, 0, 2, 224, 44, 81, 185, 58, 71, 188, 50, 24, 25, 226, 230, 166, 69, 240, 218, 170, 203, 181, 141, 123, 34, 117, 227, 135, 225, 134]) }, { traceIndex := 3, values := [1, 12, 0, 16, 0, 16, 0, 0, 0, 4, 0, 2, 0, 4, 0, 16, 0, 0, 0, 0, 0, 0, 0, 4, 2, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [142, 204, 225, 70, 108, 22, 28, 151, 113, 236, 92, 41, 115, 159, 176, 33, 124, 160, 226, 88, 98, 241, 40, 64, 125, 108, 138, 80, 105, 163, 64, 195]), digest := (bytes [204, 62, 19, 69, 160, 19, 10, 219, 219, 185, 185, 151, 14, 132, 77, 222, 29, 114, 86, 203, 31, 219, 163, 113, 225, 45, 131, 125, 75, 162, 235, 33]) }, { traceIndex := 4, values := [1, 16, 0, 20, 0, 4294967280, 4294967295, 0, 0, 4294967292, 4294967295, 2, 0, 4294967292, 4294967295, 20, 0, 0, 0, 0, 0, 0, 0, 5, 3, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [125, 200, 251, 236, 125, 189, 60, 169, 144, 226, 238, 77, 158, 41, 217, 52, 107, 197, 9, 150, 115, 51, 253, 135, 213, 202, 222, 213, 178, 133, 101, 255]), digest := (bytes [123, 114, 204, 124, 173, 25, 133, 87, 3, 48, 152, 120, 208, 102, 142, 23, 174, 140, 197, 43, 63, 1, 247, 83, 170, 11, 229, 185, 81, 212, 228, 36]) }, { traceIndex := 5, values := [1, 20, 0, 24, 0, 0, 0, 0, 0, 3, 0, 3, 0, 3, 0, 24, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [255, 39, 200, 136, 107, 28, 183, 6, 223, 177, 170, 63, 232, 202, 147, 241, 200, 180, 190, 200, 114, 244, 22, 72, 178, 97, 143, 252, 210, 65, 136, 173]), digest := (bytes [224, 44, 123, 202, 244, 158, 154, 245, 113, 243, 149, 54, 238, 32, 225, 92, 25, 153, 7, 182, 30, 63, 251, 151, 89, 133, 9, 93, 193, 161, 69, 36]) }, { traceIndex := 6, values := [1, 24, 0, 28, 0, 1, 0, 3, 0, 8, 0, 0, 0, 8, 0, 28, 0, 0, 0, 0, 0, 0, 0, 7, 1, 6, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1], rowDigest := (bytes [81, 4, 253, 195, 77, 166, 126, 232, 227, 165, 134, 220, 70, 95, 90, 224, 137, 74, 118, 196, 111, 247, 166, 246, 116, 199, 217, 207, 235, 163, 48, 25]), digest := (bytes [189, 148, 106, 89, 209, 75, 98, 28, 103, 163, 77, 130, 161, 3, 161, 36, 28, 41, 34, 122, 165, 74, 138, 135, 246, 86, 130, 70, 185, 88, 173, 192]) }, { traceIndex := 7, values := [1, 28, 0, 32, 0, 16, 0, 3, 0, 2, 0, 0, 0, 2, 0, 32, 0, 0, 0, 0, 0, 0, 0, 8, 2, 6, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1], rowDigest := (bytes [57, 57, 63, 246, 245, 75, 27, 38, 236, 117, 110, 45, 149, 52, 200, 62, 68, 129, 241, 147, 62, 242, 130, 22, 252, 74, 85, 37, 76, 143, 18, 188]), digest := (bytes [174, 43, 21, 21, 247, 77, 108, 186, 160, 253, 186, 41, 96, 142, 204, 236, 46, 117, 232, 202, 192, 133, 4, 20, 55, 104, 174, 186, 1, 214, 182, 42]) }, { traceIndex := 8, values := [1, 32, 0, 36, 0, 4294967280, 4294967295, 3, 0, 4294967294, 4294967295, 0, 0, 4294967294, 4294967295, 36, 0, 0, 0, 0, 0, 0, 0, 9, 3, 6, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1], rowDigest := (bytes [247, 200, 108, 1, 41, 217, 149, 168, 163, 52, 88, 116, 215, 253, 81, 13, 45, 161, 36, 66, 124, 108, 251, 112, 180, 131, 0, 248, 18, 188, 107, 120]), digest := (bytes [231, 214, 147, 187, 253, 58, 115, 51, 24, 215, 12, 45, 113, 15, 180, 210, 237, 210, 149, 198, 232, 51, 49, 88, 73, 2, 157, 89, 23, 132, 166, 237]) }, { traceIndex := 9, values := [1, 36, 0, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [182, 134, 141, 237, 80, 100, 222, 51, 79, 143, 246, 177, 31, 61, 129, 193, 216, 133, 80, 85, 220, 234, 180, 38, 196, 214, 36, 167, 155, 158, 39, 109]), digest := (bytes [145, 15, 177, 221, 121, 156, 20, 181, 9, 18, 204, 143, 99, 31, 54, 16, 213, 204, 221, 89, 46, 87, 182, 15, 224, 179, 189, 19, 141, 49, 255, 107]) }]

def rootExecutionPreparedBindings : List PreparedStepBindingView :=
  [{ traceIndex := 0, rowDigest := (bytes [48, 9, 158, 59, 120, 45, 200, 155, 8, 144, 252, 183, 179, 168, 71, 138, 10, 136, 117, 72, 217, 133, 28, 26, 240, 134, 159, 61, 227, 8, 46, 227]), rowOpeningDigest := (bytes [49, 66, 52, 214, 209, 84, 198, 152, 216, 68, 219, 110, 141, 188, 227, 107, 57, 26, 107, 138, 67, 120, 37, 90, 52, 170, 211, 173, 128, 92, 10, 61]), digest := (bytes [228, 186, 196, 100, 214, 97, 204, 91, 47, 206, 34, 198, 29, 200, 203, 87, 232, 28, 132, 169, 17, 190, 217, 45, 135, 51, 200, 19, 206, 178, 215, 73]) }, { traceIndex := 1, rowDigest := (bytes [73, 162, 38, 137, 65, 140, 229, 252, 172, 76, 117, 117, 82, 151, 171, 214, 113, 75, 179, 86, 158, 113, 70, 129, 8, 46, 52, 201, 80, 235, 175, 101]), rowOpeningDigest := (bytes [59, 0, 71, 127, 117, 109, 55, 245, 80, 152, 9, 106, 50, 85, 19, 13, 47, 192, 92, 96, 85, 12, 74, 225, 14, 149, 214, 222, 238, 142, 181, 74]), digest := (bytes [89, 110, 99, 29, 121, 239, 120, 170, 160, 233, 90, 225, 59, 247, 249, 148, 99, 165, 29, 108, 200, 87, 110, 92, 21, 244, 172, 41, 113, 210, 126, 8]) }, { traceIndex := 2, rowDigest := (bytes [218, 117, 75, 56, 173, 248, 187, 88, 181, 227, 90, 121, 198, 202, 10, 220, 141, 92, 138, 241, 113, 191, 17, 88, 214, 216, 9, 179, 38, 177, 152, 168]), rowOpeningDigest := (bytes [40, 199, 157, 127, 91, 199, 145, 124, 42, 106, 122, 201, 220, 188, 64, 232, 120, 201, 180, 191, 41, 50, 56, 134, 223, 166, 46, 172, 20, 11, 91, 104]), digest := (bytes [158, 93, 124, 54, 181, 240, 216, 99, 95, 106, 84, 254, 209, 221, 79, 138, 138, 3, 39, 252, 245, 34, 47, 92, 64, 113, 22, 130, 69, 154, 3, 86]) }, { traceIndex := 3, rowDigest := (bytes [142, 204, 225, 70, 108, 22, 28, 151, 113, 236, 92, 41, 115, 159, 176, 33, 124, 160, 226, 88, 98, 241, 40, 64, 125, 108, 138, 80, 105, 163, 64, 195]), rowOpeningDigest := (bytes [132, 15, 194, 120, 203, 234, 50, 89, 13, 2, 147, 115, 195, 195, 122, 25, 100, 221, 186, 1, 79, 88, 24, 184, 164, 77, 128, 208, 109, 94, 177, 197]), digest := (bytes [232, 22, 61, 228, 146, 30, 90, 178, 137, 61, 254, 28, 239, 24, 158, 72, 179, 118, 103, 53, 48, 11, 107, 4, 201, 91, 1, 95, 234, 188, 25, 80]) }, { traceIndex := 4, rowDigest := (bytes [125, 200, 251, 236, 125, 189, 60, 169, 144, 226, 238, 77, 158, 41, 217, 52, 107, 197, 9, 150, 115, 51, 253, 135, 213, 202, 222, 213, 178, 133, 101, 255]), rowOpeningDigest := (bytes [219, 141, 54, 209, 95, 116, 222, 237, 132, 182, 123, 126, 225, 217, 168, 38, 46, 16, 195, 127, 42, 53, 163, 238, 3, 18, 8, 161, 33, 239, 221, 200]), digest := (bytes [253, 183, 153, 31, 4, 233, 58, 149, 32, 54, 177, 149, 144, 175, 30, 146, 160, 205, 80, 149, 106, 22, 126, 187, 149, 189, 239, 191, 156, 26, 76, 207]) }, { traceIndex := 5, rowDigest := (bytes [255, 39, 200, 136, 107, 28, 183, 6, 223, 177, 170, 63, 232, 202, 147, 241, 200, 180, 190, 200, 114, 244, 22, 72, 178, 97, 143, 252, 210, 65, 136, 173]), rowOpeningDigest := (bytes [20, 212, 17, 105, 79, 189, 7, 66, 181, 178, 13, 132, 47, 207, 58, 42, 253, 204, 117, 131, 219, 122, 217, 252, 48, 56, 124, 69, 27, 187, 172, 64]), digest := (bytes [118, 212, 110, 94, 138, 243, 188, 105, 190, 235, 233, 8, 9, 77, 68, 190, 58, 93, 102, 195, 232, 136, 216, 46, 24, 145, 173, 8, 244, 199, 199, 226]) }, { traceIndex := 6, rowDigest := (bytes [81, 4, 253, 195, 77, 166, 126, 232, 227, 165, 134, 220, 70, 95, 90, 224, 137, 74, 118, 196, 111, 247, 166, 246, 116, 199, 217, 207, 235, 163, 48, 25]), rowOpeningDigest := (bytes [91, 162, 118, 206, 202, 10, 156, 237, 88, 196, 128, 195, 153, 11, 120, 196, 179, 141, 31, 2, 104, 167, 101, 85, 150, 168, 253, 226, 128, 162, 193, 4]), digest := (bytes [11, 245, 224, 241, 210, 57, 157, 42, 230, 162, 81, 98, 220, 245, 198, 185, 203, 56, 108, 54, 80, 171, 137, 177, 104, 24, 190, 99, 253, 125, 248, 215]) }, { traceIndex := 7, rowDigest := (bytes [57, 57, 63, 246, 245, 75, 27, 38, 236, 117, 110, 45, 149, 52, 200, 62, 68, 129, 241, 147, 62, 242, 130, 22, 252, 74, 85, 37, 76, 143, 18, 188]), rowOpeningDigest := (bytes [248, 163, 79, 181, 99, 108, 201, 47, 201, 181, 114, 138, 67, 56, 109, 86, 26, 39, 134, 249, 25, 179, 5, 61, 141, 112, 125, 243, 145, 197, 76, 44]), digest := (bytes [105, 130, 146, 171, 228, 148, 131, 31, 10, 111, 94, 134, 193, 230, 23, 108, 191, 74, 3, 163, 99, 117, 73, 201, 52, 12, 91, 157, 190, 103, 116, 125]) }, { traceIndex := 8, rowDigest := (bytes [247, 200, 108, 1, 41, 217, 149, 168, 163, 52, 88, 116, 215, 253, 81, 13, 45, 161, 36, 66, 124, 108, 251, 112, 180, 131, 0, 248, 18, 188, 107, 120]), rowOpeningDigest := (bytes [224, 152, 150, 183, 193, 79, 145, 70, 61, 125, 28, 118, 96, 231, 170, 162, 124, 162, 11, 132, 103, 101, 205, 98, 240, 138, 163, 111, 78, 81, 34, 133]), digest := (bytes [170, 87, 206, 228, 31, 79, 212, 219, 102, 98, 174, 128, 63, 18, 96, 239, 67, 34, 208, 242, 81, 208, 2, 218, 76, 23, 44, 13, 21, 226, 93, 230]) }, { traceIndex := 9, rowDigest := (bytes [182, 134, 141, 237, 80, 100, 222, 51, 79, 143, 246, 177, 31, 61, 129, 193, 216, 133, 80, 85, 220, 234, 180, 38, 196, 214, 36, 167, 155, 158, 39, 109]), rowOpeningDigest := (bytes [24, 14, 108, 218, 1, 247, 142, 252, 41, 224, 234, 209, 96, 212, 186, 131, 15, 64, 204, 6, 123, 205, 222, 241, 128, 57, 92, 135, 153, 60, 46, 19]), digest := (bytes [157, 175, 250, 167, 39, 214, 161, 115, 180, 44, 169, 119, 226, 188, 165, 171, 56, 139, 82, 47, 76, 62, 113, 120, 15, 217, 29, 244, 80, 189, 215, 4]) }]

def rootExecutionRowChunkRoutes : List RowChunkRouteView :=
  [{ logicalIndex := 0, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 0, digest := (bytes [138, 198, 109, 126, 144, 82, 221, 43, 248, 202, 137, 103, 62, 226, 249, 152, 163, 187, 1, 254, 36, 33, 59, 16, 64, 166, 202, 8, 219, 57, 240, 59]) }, { logicalIndex := 1, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 1, digest := (bytes [44, 177, 82, 41, 218, 60, 100, 208, 26, 31, 151, 113, 109, 148, 57, 12, 223, 21, 76, 221, 70, 245, 191, 105, 57, 199, 8, 128, 181, 145, 89, 99]) }, { logicalIndex := 2, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 2, digest := (bytes [252, 248, 65, 24, 81, 241, 150, 170, 250, 116, 222, 30, 134, 191, 78, 195, 104, 119, 225, 210, 243, 186, 212, 107, 183, 31, 243, 201, 101, 148, 32, 72]) }, { logicalIndex := 3, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 3, digest := (bytes [244, 11, 162, 13, 59, 43, 232, 47, 228, 2, 70, 126, 95, 10, 57, 40, 46, 107, 197, 81, 97, 39, 185, 163, 93, 60, 5, 66, 7, 231, 199, 134]) }, { logicalIndex := 4, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 4, digest := (bytes [98, 247, 204, 83, 252, 219, 248, 73, 49, 206, 229, 79, 169, 242, 28, 56, 7, 100, 18, 197, 133, 200, 133, 20, 161, 230, 126, 175, 98, 0, 158, 25]) }, { logicalIndex := 5, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 5, digest := (bytes [108, 248, 244, 125, 120, 190, 11, 202, 47, 205, 44, 110, 48, 43, 171, 224, 142, 98, 82, 106, 183, 21, 141, 205, 208, 18, 234, 19, 43, 61, 139, 151]) }, { logicalIndex := 6, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 6, digest := (bytes [213, 163, 43, 1, 32, 112, 128, 155, 10, 34, 241, 205, 79, 46, 234, 45, 239, 83, 213, 254, 45, 65, 13, 152, 217, 78, 36, 105, 42, 193, 181, 13]) }, { logicalIndex := 7, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 7, digest := (bytes [199, 10, 5, 135, 58, 125, 195, 205, 65, 103, 137, 179, 210, 215, 124, 50, 45, 181, 46, 62, 43, 114, 240, 192, 142, 94, 31, 202, 153, 102, 209, 54]) }, { logicalIndex := 8, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 8, digest := (bytes [243, 104, 100, 66, 94, 61, 218, 185, 138, 159, 201, 38, 53, 64, 18, 187, 81, 105, 239, 11, 139, 137, 248, 62, 130, 187, 188, 172, 131, 72, 106, 73]) }, { logicalIndex := 9, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 9, digest := (bytes [11, 164, 4, 249, 84, 107, 210, 66, 134, 110, 223, 149, 172, 176, 94, 254, 45, 42, 247, 93, 171, 29, 160, 56, 115, 52, 76, 84, 241, 17, 162, 122]) }]

def rootExecutionRowLocalCcsAcceptance : List RootRowLocalCcsAcceptanceView :=
  [{ traceIndex := 0, logicalIndex := 0, rowDigest := (bytes [48, 9, 158, 59, 120, 45, 200, 155, 8, 144, 252, 183, 179, 168, 71, 138, 10, 136, 117, 72, 217, 133, 28, 26, 240, 134, 159, 61, 227, 8, 46, 227]), rowOpeningDigest := (bytes [49, 66, 52, 214, 209, 84, 198, 152, 216, 68, 219, 110, 141, 188, 227, 107, 57, 26, 107, 138, 67, 120, 37, 90, 52, 170, 211, 173, 128, 92, 10, 61]), preparedStepBindingDigest := (bytes [228, 186, 196, 100, 214, 97, 204, 91, 47, 206, 34, 198, 29, 200, 203, 87, 232, 28, 132, 169, 17, 190, 217, 45, 135, 51, 200, 19, 206, 178, 215, 73]), rowChunkRouteDigest := (bytes [138, 198, 109, 126, 144, 82, 221, 43, 248, 202, 137, 103, 62, 226, 249, 152, 163, 187, 1, 254, 36, 33, 59, 16, 64, 166, 202, 8, 219, 57, 240, 59]), publicStepDigest := (bytes [176, 41, 96, 84, 84, 211, 190, 209, 187, 47, 137, 156, 111, 148, 42, 8, 243, 99, 64, 11, 14, 51, 190, 58, 185, 251, 119, 222, 238, 18, 74, 157]), digest := (bytes [131, 216, 81, 76, 27, 187, 29, 18, 229, 26, 228, 78, 172, 159, 112, 54, 242, 166, 168, 123, 53, 176, 12, 53, 234, 147, 76, 98, 157, 21, 212, 196]) }, { traceIndex := 1, logicalIndex := 1, rowDigest := (bytes [73, 162, 38, 137, 65, 140, 229, 252, 172, 76, 117, 117, 82, 151, 171, 214, 113, 75, 179, 86, 158, 113, 70, 129, 8, 46, 52, 201, 80, 235, 175, 101]), rowOpeningDigest := (bytes [59, 0, 71, 127, 117, 109, 55, 245, 80, 152, 9, 106, 50, 85, 19, 13, 47, 192, 92, 96, 85, 12, 74, 225, 14, 149, 214, 222, 238, 142, 181, 74]), preparedStepBindingDigest := (bytes [89, 110, 99, 29, 121, 239, 120, 170, 160, 233, 90, 225, 59, 247, 249, 148, 99, 165, 29, 108, 200, 87, 110, 92, 21, 244, 172, 41, 113, 210, 126, 8]), rowChunkRouteDigest := (bytes [44, 177, 82, 41, 218, 60, 100, 208, 26, 31, 151, 113, 109, 148, 57, 12, 223, 21, 76, 221, 70, 245, 191, 105, 57, 199, 8, 128, 181, 145, 89, 99]), publicStepDigest := (bytes [129, 76, 95, 250, 94, 208, 115, 241, 31, 134, 205, 74, 81, 198, 67, 93, 130, 216, 147, 194, 128, 83, 116, 140, 116, 90, 161, 81, 88, 223, 217, 109]), digest := (bytes [17, 130, 203, 172, 152, 129, 44, 212, 157, 71, 118, 99, 244, 131, 197, 82, 3, 162, 50, 1, 59, 28, 168, 181, 11, 146, 20, 135, 26, 245, 193, 160]) }, { traceIndex := 2, logicalIndex := 2, rowDigest := (bytes [218, 117, 75, 56, 173, 248, 187, 88, 181, 227, 90, 121, 198, 202, 10, 220, 141, 92, 138, 241, 113, 191, 17, 88, 214, 216, 9, 179, 38, 177, 152, 168]), rowOpeningDigest := (bytes [40, 199, 157, 127, 91, 199, 145, 124, 42, 106, 122, 201, 220, 188, 64, 232, 120, 201, 180, 191, 41, 50, 56, 134, 223, 166, 46, 172, 20, 11, 91, 104]), preparedStepBindingDigest := (bytes [158, 93, 124, 54, 181, 240, 216, 99, 95, 106, 84, 254, 209, 221, 79, 138, 138, 3, 39, 252, 245, 34, 47, 92, 64, 113, 22, 130, 69, 154, 3, 86]), rowChunkRouteDigest := (bytes [252, 248, 65, 24, 81, 241, 150, 170, 250, 116, 222, 30, 134, 191, 78, 195, 104, 119, 225, 210, 243, 186, 212, 107, 183, 31, 243, 201, 101, 148, 32, 72]), publicStepDigest := (bytes [219, 226, 137, 249, 51, 248, 24, 208, 34, 38, 171, 52, 91, 229, 95, 39, 247, 73, 221, 173, 193, 201, 113, 203, 16, 158, 85, 162, 171, 90, 240, 62]), digest := (bytes [132, 46, 160, 138, 50, 194, 2, 127, 23, 212, 106, 90, 123, 240, 63, 42, 235, 189, 231, 252, 20, 248, 77, 142, 77, 79, 98, 217, 66, 132, 54, 11]) }, { traceIndex := 3, logicalIndex := 3, rowDigest := (bytes [142, 204, 225, 70, 108, 22, 28, 151, 113, 236, 92, 41, 115, 159, 176, 33, 124, 160, 226, 88, 98, 241, 40, 64, 125, 108, 138, 80, 105, 163, 64, 195]), rowOpeningDigest := (bytes [132, 15, 194, 120, 203, 234, 50, 89, 13, 2, 147, 115, 195, 195, 122, 25, 100, 221, 186, 1, 79, 88, 24, 184, 164, 77, 128, 208, 109, 94, 177, 197]), preparedStepBindingDigest := (bytes [232, 22, 61, 228, 146, 30, 90, 178, 137, 61, 254, 28, 239, 24, 158, 72, 179, 118, 103, 53, 48, 11, 107, 4, 201, 91, 1, 95, 234, 188, 25, 80]), rowChunkRouteDigest := (bytes [244, 11, 162, 13, 59, 43, 232, 47, 228, 2, 70, 126, 95, 10, 57, 40, 46, 107, 197, 81, 97, 39, 185, 163, 93, 60, 5, 66, 7, 231, 199, 134]), publicStepDigest := (bytes [61, 89, 181, 94, 179, 56, 58, 6, 116, 141, 210, 231, 119, 7, 236, 127, 49, 236, 177, 144, 178, 166, 37, 129, 32, 40, 13, 103, 16, 232, 207, 79]), digest := (bytes [23, 107, 135, 174, 108, 113, 65, 27, 99, 199, 18, 17, 178, 22, 138, 116, 128, 225, 121, 65, 184, 26, 152, 111, 151, 103, 92, 248, 140, 129, 1, 56]) }, { traceIndex := 4, logicalIndex := 4, rowDigest := (bytes [125, 200, 251, 236, 125, 189, 60, 169, 144, 226, 238, 77, 158, 41, 217, 52, 107, 197, 9, 150, 115, 51, 253, 135, 213, 202, 222, 213, 178, 133, 101, 255]), rowOpeningDigest := (bytes [219, 141, 54, 209, 95, 116, 222, 237, 132, 182, 123, 126, 225, 217, 168, 38, 46, 16, 195, 127, 42, 53, 163, 238, 3, 18, 8, 161, 33, 239, 221, 200]), preparedStepBindingDigest := (bytes [253, 183, 153, 31, 4, 233, 58, 149, 32, 54, 177, 149, 144, 175, 30, 146, 160, 205, 80, 149, 106, 22, 126, 187, 149, 189, 239, 191, 156, 26, 76, 207]), rowChunkRouteDigest := (bytes [98, 247, 204, 83, 252, 219, 248, 73, 49, 206, 229, 79, 169, 242, 28, 56, 7, 100, 18, 197, 133, 200, 133, 20, 161, 230, 126, 175, 98, 0, 158, 25]), publicStepDigest := (bytes [253, 81, 226, 178, 242, 224, 154, 12, 163, 233, 205, 126, 5, 6, 92, 134, 92, 100, 35, 254, 0, 84, 138, 255, 97, 186, 85, 249, 179, 231, 59, 34]), digest := (bytes [114, 64, 150, 255, 158, 247, 33, 78, 170, 90, 95, 157, 167, 200, 91, 52, 169, 124, 7, 189, 158, 65, 224, 133, 217, 224, 46, 222, 43, 131, 80, 252]) }, { traceIndex := 5, logicalIndex := 5, rowDigest := (bytes [255, 39, 200, 136, 107, 28, 183, 6, 223, 177, 170, 63, 232, 202, 147, 241, 200, 180, 190, 200, 114, 244, 22, 72, 178, 97, 143, 252, 210, 65, 136, 173]), rowOpeningDigest := (bytes [20, 212, 17, 105, 79, 189, 7, 66, 181, 178, 13, 132, 47, 207, 58, 42, 253, 204, 117, 131, 219, 122, 217, 252, 48, 56, 124, 69, 27, 187, 172, 64]), preparedStepBindingDigest := (bytes [118, 212, 110, 94, 138, 243, 188, 105, 190, 235, 233, 8, 9, 77, 68, 190, 58, 93, 102, 195, 232, 136, 216, 46, 24, 145, 173, 8, 244, 199, 199, 226]), rowChunkRouteDigest := (bytes [108, 248, 244, 125, 120, 190, 11, 202, 47, 205, 44, 110, 48, 43, 171, 224, 142, 98, 82, 106, 183, 21, 141, 205, 208, 18, 234, 19, 43, 61, 139, 151]), publicStepDigest := (bytes [36, 237, 249, 165, 221, 238, 210, 95, 88, 167, 154, 236, 230, 158, 33, 210, 189, 37, 13, 22, 224, 85, 44, 102, 201, 48, 56, 210, 82, 6, 26, 174]), digest := (bytes [231, 8, 92, 226, 224, 56, 182, 224, 187, 190, 106, 43, 192, 59, 116, 157, 52, 138, 165, 126, 189, 40, 235, 211, 191, 214, 90, 2, 217, 94, 224, 186]) }, { traceIndex := 6, logicalIndex := 6, rowDigest := (bytes [81, 4, 253, 195, 77, 166, 126, 232, 227, 165, 134, 220, 70, 95, 90, 224, 137, 74, 118, 196, 111, 247, 166, 246, 116, 199, 217, 207, 235, 163, 48, 25]), rowOpeningDigest := (bytes [91, 162, 118, 206, 202, 10, 156, 237, 88, 196, 128, 195, 153, 11, 120, 196, 179, 141, 31, 2, 104, 167, 101, 85, 150, 168, 253, 226, 128, 162, 193, 4]), preparedStepBindingDigest := (bytes [11, 245, 224, 241, 210, 57, 157, 42, 230, 162, 81, 98, 220, 245, 198, 185, 203, 56, 108, 54, 80, 171, 137, 177, 104, 24, 190, 99, 253, 125, 248, 215]), rowChunkRouteDigest := (bytes [213, 163, 43, 1, 32, 112, 128, 155, 10, 34, 241, 205, 79, 46, 234, 45, 239, 83, 213, 254, 45, 65, 13, 152, 217, 78, 36, 105, 42, 193, 181, 13]), publicStepDigest := (bytes [195, 167, 206, 160, 175, 223, 52, 140, 201, 0, 151, 140, 143, 232, 14, 26, 154, 223, 220, 104, 254, 122, 107, 73, 188, 180, 235, 114, 44, 137, 97, 30]), digest := (bytes [11, 17, 240, 178, 170, 206, 172, 19, 57, 91, 82, 229, 245, 158, 41, 221, 101, 130, 214, 82, 36, 23, 47, 18, 95, 246, 30, 175, 92, 173, 7, 41]) }, { traceIndex := 7, logicalIndex := 7, rowDigest := (bytes [57, 57, 63, 246, 245, 75, 27, 38, 236, 117, 110, 45, 149, 52, 200, 62, 68, 129, 241, 147, 62, 242, 130, 22, 252, 74, 85, 37, 76, 143, 18, 188]), rowOpeningDigest := (bytes [248, 163, 79, 181, 99, 108, 201, 47, 201, 181, 114, 138, 67, 56, 109, 86, 26, 39, 134, 249, 25, 179, 5, 61, 141, 112, 125, 243, 145, 197, 76, 44]), preparedStepBindingDigest := (bytes [105, 130, 146, 171, 228, 148, 131, 31, 10, 111, 94, 134, 193, 230, 23, 108, 191, 74, 3, 163, 99, 117, 73, 201, 52, 12, 91, 157, 190, 103, 116, 125]), rowChunkRouteDigest := (bytes [199, 10, 5, 135, 58, 125, 195, 205, 65, 103, 137, 179, 210, 215, 124, 50, 45, 181, 46, 62, 43, 114, 240, 192, 142, 94, 31, 202, 153, 102, 209, 54]), publicStepDigest := (bytes [58, 151, 127, 71, 98, 220, 211, 20, 144, 125, 51, 249, 27, 120, 114, 117, 250, 64, 137, 145, 68, 214, 58, 163, 33, 165, 13, 205, 148, 250, 161, 101]), digest := (bytes [107, 72, 109, 88, 97, 225, 164, 141, 125, 194, 141, 242, 66, 46, 47, 76, 18, 135, 113, 63, 46, 224, 47, 82, 105, 110, 247, 206, 237, 239, 30, 213]) }, { traceIndex := 8, logicalIndex := 8, rowDigest := (bytes [247, 200, 108, 1, 41, 217, 149, 168, 163, 52, 88, 116, 215, 253, 81, 13, 45, 161, 36, 66, 124, 108, 251, 112, 180, 131, 0, 248, 18, 188, 107, 120]), rowOpeningDigest := (bytes [224, 152, 150, 183, 193, 79, 145, 70, 61, 125, 28, 118, 96, 231, 170, 162, 124, 162, 11, 132, 103, 101, 205, 98, 240, 138, 163, 111, 78, 81, 34, 133]), preparedStepBindingDigest := (bytes [170, 87, 206, 228, 31, 79, 212, 219, 102, 98, 174, 128, 63, 18, 96, 239, 67, 34, 208, 242, 81, 208, 2, 218, 76, 23, 44, 13, 21, 226, 93, 230]), rowChunkRouteDigest := (bytes [243, 104, 100, 66, 94, 61, 218, 185, 138, 159, 201, 38, 53, 64, 18, 187, 81, 105, 239, 11, 139, 137, 248, 62, 130, 187, 188, 172, 131, 72, 106, 73]), publicStepDigest := (bytes [115, 254, 252, 0, 148, 16, 176, 52, 226, 244, 32, 213, 226, 100, 105, 101, 225, 200, 45, 20, 184, 90, 42, 124, 235, 15, 131, 96, 206, 17, 201, 232]), digest := (bytes [195, 119, 129, 107, 96, 159, 143, 19, 204, 144, 231, 63, 68, 177, 126, 251, 51, 101, 75, 27, 182, 117, 28, 243, 207, 227, 88, 225, 71, 249, 7, 175]) }, { traceIndex := 9, logicalIndex := 9, rowDigest := (bytes [182, 134, 141, 237, 80, 100, 222, 51, 79, 143, 246, 177, 31, 61, 129, 193, 216, 133, 80, 85, 220, 234, 180, 38, 196, 214, 36, 167, 155, 158, 39, 109]), rowOpeningDigest := (bytes [24, 14, 108, 218, 1, 247, 142, 252, 41, 224, 234, 209, 96, 212, 186, 131, 15, 64, 204, 6, 123, 205, 222, 241, 128, 57, 92, 135, 153, 60, 46, 19]), preparedStepBindingDigest := (bytes [157, 175, 250, 167, 39, 214, 161, 115, 180, 44, 169, 119, 226, 188, 165, 171, 56, 139, 82, 47, 76, 62, 113, 120, 15, 217, 29, 244, 80, 189, 215, 4]), rowChunkRouteDigest := (bytes [11, 164, 4, 249, 84, 107, 210, 66, 134, 110, 223, 149, 172, 176, 94, 254, 45, 42, 247, 93, 171, 29, 160, 56, 115, 52, 76, 84, 241, 17, 162, 122]), publicStepDigest := (bytes [206, 75, 181, 188, 141, 169, 159, 12, 184, 27, 73, 224, 71, 53, 81, 76, 84, 67, 206, 65, 119, 14, 17, 174, 150, 205, 177, 97, 72, 27, 128, 106]), digest := (bytes [136, 194, 29, 86, 82, 196, 87, 11, 207, 3, 252, 230, 237, 104, 212, 20, 119, 226, 60, 11, 31, 16, 77, 231, 221, 110, 79, 214, 214, 142, 237, 42]) }]

def rootExecutionExecutionSemanticsRefinement : List RootExecutionSemanticsRefinementView :=
  [{ traceIndex := 0, logicalIndex := 0, semanticRowDigest := (bytes [77, 97, 131, 255, 203, 134, 45, 198, 175, 166, 39, 170, 211, 141, 143, 44, 217, 157, 82, 58, 43, 137, 198, 85, 25, 93, 188, 205, 7, 120, 191, 196]), rowLocalCcsAcceptanceDigest := (bytes [131, 216, 81, 76, 27, 187, 29, 18, 229, 26, 228, 78, 172, 159, 112, 54, 242, 166, 168, 123, 53, 176, 12, 53, 234, 147, 76, 98, 157, 21, 212, 196]), preparedStepBindingDigest := (bytes [228, 186, 196, 100, 214, 97, 204, 91, 47, 206, 34, 198, 29, 200, 203, 87, 232, 28, 132, 169, 17, 190, 217, 45, 135, 51, 200, 19, 206, 178, 215, 73]), publicStepDigest := (bytes [176, 41, 96, 84, 84, 211, 190, 209, 187, 47, 137, 156, 111, 148, 42, 8, 243, 99, 64, 11, 14, 51, 190, 58, 185, 251, 119, 222, 238, 18, 74, 157]), digest := (bytes [74, 26, 70, 133, 85, 71, 55, 183, 73, 145, 227, 106, 82, 203, 70, 53, 11, 227, 150, 195, 110, 54, 166, 206, 94, 87, 88, 148, 117, 205, 142, 14]) }, { traceIndex := 1, logicalIndex := 1, semanticRowDigest := (bytes [19, 136, 56, 5, 160, 108, 125, 202, 70, 213, 102, 26, 157, 63, 148, 33, 228, 255, 23, 1, 203, 192, 249, 132, 181, 55, 159, 16, 221, 178, 233, 135]), rowLocalCcsAcceptanceDigest := (bytes [17, 130, 203, 172, 152, 129, 44, 212, 157, 71, 118, 99, 244, 131, 197, 82, 3, 162, 50, 1, 59, 28, 168, 181, 11, 146, 20, 135, 26, 245, 193, 160]), preparedStepBindingDigest := (bytes [89, 110, 99, 29, 121, 239, 120, 170, 160, 233, 90, 225, 59, 247, 249, 148, 99, 165, 29, 108, 200, 87, 110, 92, 21, 244, 172, 41, 113, 210, 126, 8]), publicStepDigest := (bytes [129, 76, 95, 250, 94, 208, 115, 241, 31, 134, 205, 74, 81, 198, 67, 93, 130, 216, 147, 194, 128, 83, 116, 140, 116, 90, 161, 81, 88, 223, 217, 109]), digest := (bytes [244, 98, 91, 29, 179, 15, 82, 149, 102, 8, 119, 230, 108, 159, 67, 59, 100, 136, 52, 180, 79, 4, 181, 85, 7, 181, 2, 95, 172, 206, 128, 196]) }, { traceIndex := 2, logicalIndex := 2, semanticRowDigest := (bytes [249, 3, 215, 0, 2, 224, 44, 81, 185, 58, 71, 188, 50, 24, 25, 226, 230, 166, 69, 240, 218, 170, 203, 181, 141, 123, 34, 117, 227, 135, 225, 134]), rowLocalCcsAcceptanceDigest := (bytes [132, 46, 160, 138, 50, 194, 2, 127, 23, 212, 106, 90, 123, 240, 63, 42, 235, 189, 231, 252, 20, 248, 77, 142, 77, 79, 98, 217, 66, 132, 54, 11]), preparedStepBindingDigest := (bytes [158, 93, 124, 54, 181, 240, 216, 99, 95, 106, 84, 254, 209, 221, 79, 138, 138, 3, 39, 252, 245, 34, 47, 92, 64, 113, 22, 130, 69, 154, 3, 86]), publicStepDigest := (bytes [219, 226, 137, 249, 51, 248, 24, 208, 34, 38, 171, 52, 91, 229, 95, 39, 247, 73, 221, 173, 193, 201, 113, 203, 16, 158, 85, 162, 171, 90, 240, 62]), digest := (bytes [233, 56, 226, 203, 157, 240, 248, 25, 20, 221, 150, 189, 6, 44, 108, 254, 22, 188, 188, 21, 94, 108, 182, 238, 54, 152, 41, 71, 2, 29, 20, 66]) }, { traceIndex := 3, logicalIndex := 3, semanticRowDigest := (bytes [204, 62, 19, 69, 160, 19, 10, 219, 219, 185, 185, 151, 14, 132, 77, 222, 29, 114, 86, 203, 31, 219, 163, 113, 225, 45, 131, 125, 75, 162, 235, 33]), rowLocalCcsAcceptanceDigest := (bytes [23, 107, 135, 174, 108, 113, 65, 27, 99, 199, 18, 17, 178, 22, 138, 116, 128, 225, 121, 65, 184, 26, 152, 111, 151, 103, 92, 248, 140, 129, 1, 56]), preparedStepBindingDigest := (bytes [232, 22, 61, 228, 146, 30, 90, 178, 137, 61, 254, 28, 239, 24, 158, 72, 179, 118, 103, 53, 48, 11, 107, 4, 201, 91, 1, 95, 234, 188, 25, 80]), publicStepDigest := (bytes [61, 89, 181, 94, 179, 56, 58, 6, 116, 141, 210, 231, 119, 7, 236, 127, 49, 236, 177, 144, 178, 166, 37, 129, 32, 40, 13, 103, 16, 232, 207, 79]), digest := (bytes [138, 92, 36, 43, 178, 41, 34, 199, 204, 237, 240, 205, 169, 55, 153, 38, 95, 239, 29, 244, 183, 126, 122, 203, 218, 175, 253, 224, 25, 243, 86, 186]) }, { traceIndex := 4, logicalIndex := 4, semanticRowDigest := (bytes [123, 114, 204, 124, 173, 25, 133, 87, 3, 48, 152, 120, 208, 102, 142, 23, 174, 140, 197, 43, 63, 1, 247, 83, 170, 11, 229, 185, 81, 212, 228, 36]), rowLocalCcsAcceptanceDigest := (bytes [114, 64, 150, 255, 158, 247, 33, 78, 170, 90, 95, 157, 167, 200, 91, 52, 169, 124, 7, 189, 158, 65, 224, 133, 217, 224, 46, 222, 43, 131, 80, 252]), preparedStepBindingDigest := (bytes [253, 183, 153, 31, 4, 233, 58, 149, 32, 54, 177, 149, 144, 175, 30, 146, 160, 205, 80, 149, 106, 22, 126, 187, 149, 189, 239, 191, 156, 26, 76, 207]), publicStepDigest := (bytes [253, 81, 226, 178, 242, 224, 154, 12, 163, 233, 205, 126, 5, 6, 92, 134, 92, 100, 35, 254, 0, 84, 138, 255, 97, 186, 85, 249, 179, 231, 59, 34]), digest := (bytes [224, 67, 235, 139, 81, 89, 135, 50, 64, 162, 61, 226, 122, 223, 152, 92, 45, 81, 164, 130, 240, 136, 63, 241, 9, 49, 196, 116, 84, 56, 124, 60]) }, { traceIndex := 5, logicalIndex := 5, semanticRowDigest := (bytes [224, 44, 123, 202, 244, 158, 154, 245, 113, 243, 149, 54, 238, 32, 225, 92, 25, 153, 7, 182, 30, 63, 251, 151, 89, 133, 9, 93, 193, 161, 69, 36]), rowLocalCcsAcceptanceDigest := (bytes [231, 8, 92, 226, 224, 56, 182, 224, 187, 190, 106, 43, 192, 59, 116, 157, 52, 138, 165, 126, 189, 40, 235, 211, 191, 214, 90, 2, 217, 94, 224, 186]), preparedStepBindingDigest := (bytes [118, 212, 110, 94, 138, 243, 188, 105, 190, 235, 233, 8, 9, 77, 68, 190, 58, 93, 102, 195, 232, 136, 216, 46, 24, 145, 173, 8, 244, 199, 199, 226]), publicStepDigest := (bytes [36, 237, 249, 165, 221, 238, 210, 95, 88, 167, 154, 236, 230, 158, 33, 210, 189, 37, 13, 22, 224, 85, 44, 102, 201, 48, 56, 210, 82, 6, 26, 174]), digest := (bytes [219, 149, 69, 153, 66, 75, 99, 49, 140, 240, 44, 72, 240, 95, 69, 190, 158, 72, 228, 45, 175, 230, 56, 214, 101, 208, 2, 236, 189, 89, 83, 75]) }, { traceIndex := 6, logicalIndex := 6, semanticRowDigest := (bytes [189, 148, 106, 89, 209, 75, 98, 28, 103, 163, 77, 130, 161, 3, 161, 36, 28, 41, 34, 122, 165, 74, 138, 135, 246, 86, 130, 70, 185, 88, 173, 192]), rowLocalCcsAcceptanceDigest := (bytes [11, 17, 240, 178, 170, 206, 172, 19, 57, 91, 82, 229, 245, 158, 41, 221, 101, 130, 214, 82, 36, 23, 47, 18, 95, 246, 30, 175, 92, 173, 7, 41]), preparedStepBindingDigest := (bytes [11, 245, 224, 241, 210, 57, 157, 42, 230, 162, 81, 98, 220, 245, 198, 185, 203, 56, 108, 54, 80, 171, 137, 177, 104, 24, 190, 99, 253, 125, 248, 215]), publicStepDigest := (bytes [195, 167, 206, 160, 175, 223, 52, 140, 201, 0, 151, 140, 143, 232, 14, 26, 154, 223, 220, 104, 254, 122, 107, 73, 188, 180, 235, 114, 44, 137, 97, 30]), digest := (bytes [102, 179, 111, 105, 71, 2, 140, 4, 191, 26, 13, 86, 84, 231, 195, 171, 109, 130, 196, 54, 214, 2, 112, 83, 221, 36, 11, 149, 89, 7, 142, 241]) }, { traceIndex := 7, logicalIndex := 7, semanticRowDigest := (bytes [174, 43, 21, 21, 247, 77, 108, 186, 160, 253, 186, 41, 96, 142, 204, 236, 46, 117, 232, 202, 192, 133, 4, 20, 55, 104, 174, 186, 1, 214, 182, 42]), rowLocalCcsAcceptanceDigest := (bytes [107, 72, 109, 88, 97, 225, 164, 141, 125, 194, 141, 242, 66, 46, 47, 76, 18, 135, 113, 63, 46, 224, 47, 82, 105, 110, 247, 206, 237, 239, 30, 213]), preparedStepBindingDigest := (bytes [105, 130, 146, 171, 228, 148, 131, 31, 10, 111, 94, 134, 193, 230, 23, 108, 191, 74, 3, 163, 99, 117, 73, 201, 52, 12, 91, 157, 190, 103, 116, 125]), publicStepDigest := (bytes [58, 151, 127, 71, 98, 220, 211, 20, 144, 125, 51, 249, 27, 120, 114, 117, 250, 64, 137, 145, 68, 214, 58, 163, 33, 165, 13, 205, 148, 250, 161, 101]), digest := (bytes [32, 15, 62, 99, 49, 235, 53, 173, 69, 173, 150, 93, 144, 152, 31, 50, 24, 11, 199, 95, 127, 24, 34, 136, 127, 176, 53, 146, 220, 186, 192, 127]) }, { traceIndex := 8, logicalIndex := 8, semanticRowDigest := (bytes [231, 214, 147, 187, 253, 58, 115, 51, 24, 215, 12, 45, 113, 15, 180, 210, 237, 210, 149, 198, 232, 51, 49, 88, 73, 2, 157, 89, 23, 132, 166, 237]), rowLocalCcsAcceptanceDigest := (bytes [195, 119, 129, 107, 96, 159, 143, 19, 204, 144, 231, 63, 68, 177, 126, 251, 51, 101, 75, 27, 182, 117, 28, 243, 207, 227, 88, 225, 71, 249, 7, 175]), preparedStepBindingDigest := (bytes [170, 87, 206, 228, 31, 79, 212, 219, 102, 98, 174, 128, 63, 18, 96, 239, 67, 34, 208, 242, 81, 208, 2, 218, 76, 23, 44, 13, 21, 226, 93, 230]), publicStepDigest := (bytes [115, 254, 252, 0, 148, 16, 176, 52, 226, 244, 32, 213, 226, 100, 105, 101, 225, 200, 45, 20, 184, 90, 42, 124, 235, 15, 131, 96, 206, 17, 201, 232]), digest := (bytes [122, 110, 234, 128, 51, 231, 50, 243, 147, 176, 191, 58, 157, 161, 232, 253, 230, 69, 1, 169, 255, 225, 97, 235, 212, 21, 161, 67, 171, 202, 23, 33]) }, { traceIndex := 9, logicalIndex := 9, semanticRowDigest := (bytes [145, 15, 177, 221, 121, 156, 20, 181, 9, 18, 204, 143, 99, 31, 54, 16, 213, 204, 221, 89, 46, 87, 182, 15, 224, 179, 189, 19, 141, 49, 255, 107]), rowLocalCcsAcceptanceDigest := (bytes [136, 194, 29, 86, 82, 196, 87, 11, 207, 3, 252, 230, 237, 104, 212, 20, 119, 226, 60, 11, 31, 16, 77, 231, 221, 110, 79, 214, 214, 142, 237, 42]), preparedStepBindingDigest := (bytes [157, 175, 250, 167, 39, 214, 161, 115, 180, 44, 169, 119, 226, 188, 165, 171, 56, 139, 82, 47, 76, 62, 113, 120, 15, 217, 29, 244, 80, 189, 215, 4]), publicStepDigest := (bytes [206, 75, 181, 188, 141, 169, 159, 12, 184, 27, 73, 224, 71, 53, 81, 76, 84, 67, 206, 65, 119, 14, 17, 174, 150, 205, 177, 97, 72, 27, 128, 106]), digest := (bytes [192, 78, 189, 229, 158, 238, 18, 223, 53, 118, 65, 94, 43, 229, 126, 148, 202, 232, 220, 49, 49, 125, 182, 70, 74, 56, 66, 64, 54, 137, 52, 118]) }]

def rootExecution : RootExecutionBundleView :=
  {
    executionRows := rootExecutionExecutionRows
    , semanticRows := rootExecutionSemanticRows
    , semanticRowsDigest := (bytes [75, 77, 103, 212, 25, 254, 20, 245, 57, 91, 81, 194, 215, 249, 90, 89, 90, 201, 88, 167, 30, 245, 69, 113, 208, 31, 194, 44, 20, 39, 128, 155])
    , preparedStepBindings := { bindings := rootExecutionPreparedBindings, bindingCount := 10, firstBindingDigest := (some (bytes [228, 186, 196, 100, 214, 97, 204, 91, 47, 206, 34, 198, 29, 200, 203, 87, 232, 28, 132, 169, 17, 190, 217, 45, 135, 51, 200, 19, 206, 178, 215, 73])), lastBindingDigest := (some (bytes [157, 175, 250, 167, 39, 214, 161, 115, 180, 44, 169, 119, 226, 188, 165, 171, 56, 139, 82, 47, 76, 62, 113, 120, 15, 217, 29, 244, 80, 189, 215, 4])), digest := (bytes [30, 164, 150, 41, 218, 111, 229, 43, 231, 221, 197, 31, 58, 29, 115, 85, 208, 133, 131, 125, 250, 253, 29, 48, 239, 226, 164, 136, 42, 31, 76, 180]) }
    , rowChunkRoutes := rootExecutionRowChunkRoutes
    , rowChunkRoutesDigest := (bytes [218, 161, 158, 255, 122, 203, 90, 133, 61, 184, 189, 186, 138, 38, 194, 63, 233, 205, 133, 32, 166, 190, 136, 71, 139, 40, 209, 171, 35, 80, 135, 137])
    , rowLocalCcsAcceptance := { acceptances := rootExecutionRowLocalCcsAcceptance, acceptanceCount := 10, firstAcceptanceDigest := (some (bytes [131, 216, 81, 76, 27, 187, 29, 18, 229, 26, 228, 78, 172, 159, 112, 54, 242, 166, 168, 123, 53, 176, 12, 53, 234, 147, 76, 98, 157, 21, 212, 196])), lastAcceptanceDigest := (some (bytes [136, 194, 29, 86, 82, 196, 87, 11, 207, 3, 252, 230, 237, 104, 212, 20, 119, 226, 60, 11, 31, 16, 77, 231, 221, 110, 79, 214, 214, 142, 237, 42])), digest := (bytes [95, 23, 132, 14, 18, 155, 71, 245, 211, 206, 225, 253, 83, 74, 25, 236, 95, 30, 92, 141, 88, 45, 188, 31, 17, 198, 174, 41, 74, 182, 134, 79]) }
    , executionSemanticsRefinement := { refinements := rootExecutionExecutionSemanticsRefinement, refinementCount := 10, firstRefinementDigest := (some (bytes [74, 26, 70, 133, 85, 71, 55, 183, 73, 145, 227, 106, 82, 203, 70, 53, 11, 227, 150, 195, 110, 54, 166, 206, 94, 87, 88, 148, 117, 205, 142, 14])), lastRefinementDigest := (some (bytes [192, 78, 189, 229, 158, 238, 18, 223, 53, 118, 65, 94, 43, 229, 126, 148, 202, 232, 220, 49, 49, 125, 182, 70, 74, 56, 66, 64, 54, 137, 52, 118])), digest := (bytes [162, 40, 85, 212, 78, 69, 91, 41, 108, 21, 105, 88, 189, 4, 107, 124, 205, 124, 36, 250, 206, 156, 35, 21, 12, 146, 100, 222, 27, 54, 113, 142]) }
    , familyDigest := (bytes [57, 96, 173, 107, 74, 96, 6, 184, 93, 44, 158, 222, 17, 105, 235, 100, 93, 195, 146, 163, 228, 224, 253, 134, 235, 58, 173, 222, 168, 61, 29, 210])
    , digest := (bytes [208, 187, 135, 184, 132, 13, 86, 181, 164, 206, 86, 72, 51, 229, 103, 211, 72, 251, 132, 59, 106, 210, 180, 120, 221, 136, 77, 132, 76, 126, 53, 217])
  }

def kernelOpeningBundle : SimpleKernelOpeningBundleView :=
  {
    claim := { bindings := { stageClaimBundleDigest := (bytes [63, 174, 85, 23, 132, 59, 164, 91, 219, 152, 118, 75, 81, 162, 203, 103, 38, 248, 208, 230, 243, 2, 237, 20, 96, 223, 24, 199, 67, 231, 4, 104]), stagePackageBundleDigest := (bytes [113, 110, 176, 95, 213, 2, 56, 45, 40, 202, 182, 238, 248, 121, 61, 153, 97, 17, 173, 150, 8, 23, 251, 135, 103, 190, 218, 12, 139, 247, 226, 169]), stage1PackageDigest := (bytes [43, 186, 189, 15, 117, 33, 34, 68, 18, 3, 84, 129, 2, 91, 173, 225, 193, 37, 15, 208, 50, 249, 112, 52, 130, 65, 94, 111, 22, 73, 76, 78]), stage2PackageDigest := (bytes [253, 241, 232, 168, 55, 211, 246, 203, 25, 241, 20, 54, 184, 114, 92, 233, 233, 199, 77, 26, 70, 65, 25, 201, 15, 55, 146, 156, 222, 134, 247, 183]), stage3PackageDigest := (bytes [123, 200, 171, 142, 73, 227, 53, 197, 73, 245, 79, 164, 187, 42, 144, 179, 84, 250, 64, 72, 82, 210, 170, 82, 241, 181, 251, 189, 13, 255, 120, 86]), preparedStepBindingsDigest := (bytes [30, 164, 150, 41, 218, 111, 229, 43, 231, 221, 197, 31, 58, 29, 115, 85, 208, 133, 131, 125, 250, 253, 29, 48, 239, 226, 164, 136, 42, 31, 76, 180]), bindingCount := 10, stage1RowCount := 10, stage2RegisterReadCount := 12, stage2RegisterWriteCount := 9, stage2RamEventCount := 0, stage3ContinuityCount := 10, points := { firstBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [30, 164, 150, 41, 218, 111, 229, 43, 231, 221, 197, 31, 58, 29, 115, 85, 208, 133, 131, 125, 250, 253, 29, 48, 239, 226, 164, 136, 42, 31, 76, 180]), layoutVersion := 1, digest := (bytes [2, 23, 36, 224, 210, 0, 212, 207, 158, 249, 219, 192, 213, 15, 37, 187, 50, 169, 249, 111, 79, 186, 167, 91, 214, 96, 62, 125, 172, 49, 207, 56]) }, logicalIndex := 0, digest := (bytes [32, 21, 247, 46, 165, 252, 126, 145, 33, 203, 207, 201, 62, 230, 27, 27, 232, 66, 155, 22, 122, 115, 65, 177, 2, 123, 229, 125, 52, 109, 42, 81]) }, valueDigest := (bytes [228, 186, 196, 100, 214, 97, 204, 91, 47, 206, 34, 198, 29, 200, 203, 87, 232, 28, 132, 169, 17, 190, 217, 45, 135, 51, 200, 19, 206, 178, 215, 73]), digest := (bytes [91, 97, 160, 200, 68, 174, 202, 88, 166, 212, 55, 110, 113, 209, 108, 92, 173, 115, 102, 217, 227, 92, 156, 100, 40, 171, 86, 175, 237, 25, 29, 108]) }), lastBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [30, 164, 150, 41, 218, 111, 229, 43, 231, 221, 197, 31, 58, 29, 115, 85, 208, 133, 131, 125, 250, 253, 29, 48, 239, 226, 164, 136, 42, 31, 76, 180]), layoutVersion := 1, digest := (bytes [2, 23, 36, 224, 210, 0, 212, 207, 158, 249, 219, 192, 213, 15, 37, 187, 50, 169, 249, 111, 79, 186, 167, 91, 214, 96, 62, 125, 172, 49, 207, 56]) }, logicalIndex := 9, digest := (bytes [189, 165, 196, 96, 192, 251, 188, 111, 251, 213, 241, 1, 46, 215, 183, 186, 192, 153, 126, 83, 77, 130, 177, 172, 5, 175, 64, 98, 131, 79, 2, 52]) }, valueDigest := (bytes [157, 175, 250, 167, 39, 214, 161, 115, 180, 44, 169, 119, 226, 188, 165, 171, 56, 139, 82, 47, 76, 62, 113, 120, 15, 217, 29, 244, 80, 189, 215, 4]), digest := (bytes [89, 113, 20, 133, 125, 236, 81, 58, 79, 118, 145, 126, 87, 50, 153, 70, 77, 175, 94, 211, 189, 218, 113, 229, 234, 44, 237, 36, 191, 70, 150, 195]) }) }, digest := (bytes [208, 187, 166, 62, 144, 142, 237, 212, 231, 148, 113, 64, 42, 50, 62, 245, 117, 82, 16, 10, 24, 145, 86, 45, 157, 21, 88, 164, 145, 166, 135, 129]) }, preparedSteps := { executionDigest := (bytes [125, 109, 107, 30, 214, 28, 21, 190, 193, 73, 13, 134, 113, 2, 233, 252, 206, 60, 180, 47, 71, 229, 88, 95, 116, 143, 172, 12, 59, 79, 234, 150]), finalStateDigest := (bytes [103, 223, 139, 208, 116, 154, 142, 132, 78, 184, 137, 1, 105, 240, 117, 173, 130, 69, 168, 181, 198, 4, 200, 40, 154, 26, 30, 84, 163, 49, 80, 141]), transcriptFinalDigest := (bytes [40, 198, 217, 185, 8, 16, 125, 44, 61, 253, 171, 30, 100, 237, 238, 86, 30, 22, 230, 155, 239, 54, 28, 87, 238, 68, 77, 116, 87, 196, 144, 189]), preparedStepCount := 10, finalPc := 40, halted := true, points := { firstPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [143, 94, 45, 143, 60, 22, 127, 181, 118, 245, 141, 105, 103, 91, 39, 116, 24, 229, 56, 25, 163, 187, 169, 225, 28, 41, 160, 93, 78, 222, 50, 187]), layoutVersion := 3, digest := (bytes [32, 193, 20, 22, 26, 33, 51, 29, 241, 32, 118, 86, 8, 63, 194, 117, 170, 88, 106, 109, 35, 170, 4, 215, 35, 68, 106, 209, 247, 58, 81, 169]) }, logicalIndex := 0, digest := (bytes [158, 3, 251, 138, 251, 63, 112, 48, 112, 160, 14, 162, 124, 125, 104, 34, 131, 115, 51, 105, 65, 219, 250, 250, 11, 105, 178, 218, 121, 174, 58, 157]) }, valueDigest := (bytes [48, 9, 158, 59, 120, 45, 200, 155, 8, 144, 252, 183, 179, 168, 71, 138, 10, 136, 117, 72, 217, 133, 28, 26, 240, 134, 159, 61, 227, 8, 46, 227]), digest := (bytes [48, 177, 97, 252, 216, 198, 105, 222, 211, 46, 152, 50, 44, 9, 162, 23, 99, 209, 115, 184, 218, 49, 215, 43, 135, 145, 165, 158, 218, 63, 195, 229]) }), lastPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [143, 94, 45, 143, 60, 22, 127, 181, 118, 245, 141, 105, 103, 91, 39, 116, 24, 229, 56, 25, 163, 187, 169, 225, 28, 41, 160, 93, 78, 222, 50, 187]), layoutVersion := 3, digest := (bytes [32, 193, 20, 22, 26, 33, 51, 29, 241, 32, 118, 86, 8, 63, 194, 117, 170, 88, 106, 109, 35, 170, 4, 215, 35, 68, 106, 209, 247, 58, 81, 169]) }, logicalIndex := 9, digest := (bytes [137, 228, 202, 166, 22, 0, 88, 191, 67, 185, 149, 186, 113, 101, 68, 140, 239, 206, 226, 56, 101, 127, 28, 142, 224, 235, 111, 50, 181, 189, 101, 120]) }, valueDigest := (bytes [182, 134, 141, 237, 80, 100, 222, 51, 79, 143, 246, 177, 31, 61, 129, 193, 216, 133, 80, 85, 220, 234, 180, 38, 196, 214, 36, 167, 155, 158, 39, 109]), digest := (bytes [246, 34, 237, 85, 223, 76, 6, 194, 59, 192, 53, 65, 70, 12, 99, 47, 162, 216, 151, 42, 164, 30, 70, 182, 113, 250, 68, 5, 148, 143, 255, 90]) }) }, digest := (bytes [35, 106, 230, 80, 5, 101, 160, 67, 14, 242, 65, 0, 103, 76, 219, 47, 189, 85, 180, 123, 95, 22, 6, 91, 55, 78, 58, 17, 53, 119, 191, 189]) }, digest := (bytes [237, 233, 103, 61, 197, 60, 93, 141, 147, 156, 156, 127, 58, 72, 103, 44, 100, 145, 190, 255, 134, 121, 188, 169, 23, 16, 186, 120, 221, 196, 248, 22]) }
    , bindings := { claim := { stageClaimBundleDigest := (bytes [63, 174, 85, 23, 132, 59, 164, 91, 219, 152, 118, 75, 81, 162, 203, 103, 38, 248, 208, 230, 243, 2, 237, 20, 96, 223, 24, 199, 67, 231, 4, 104]), stagePackageBundleDigest := (bytes [113, 110, 176, 95, 213, 2, 56, 45, 40, 202, 182, 238, 248, 121, 61, 153, 97, 17, 173, 150, 8, 23, 251, 135, 103, 190, 218, 12, 139, 247, 226, 169]), stage1PackageDigest := (bytes [43, 186, 189, 15, 117, 33, 34, 68, 18, 3, 84, 129, 2, 91, 173, 225, 193, 37, 15, 208, 50, 249, 112, 52, 130, 65, 94, 111, 22, 73, 76, 78]), stage2PackageDigest := (bytes [253, 241, 232, 168, 55, 211, 246, 203, 25, 241, 20, 54, 184, 114, 92, 233, 233, 199, 77, 26, 70, 65, 25, 201, 15, 55, 146, 156, 222, 134, 247, 183]), stage3PackageDigest := (bytes [123, 200, 171, 142, 73, 227, 53, 197, 73, 245, 79, 164, 187, 42, 144, 179, 84, 250, 64, 72, 82, 210, 170, 82, 241, 181, 251, 189, 13, 255, 120, 86]), preparedStepBindingsDigest := (bytes [30, 164, 150, 41, 218, 111, 229, 43, 231, 221, 197, 31, 58, 29, 115, 85, 208, 133, 131, 125, 250, 253, 29, 48, 239, 226, 164, 136, 42, 31, 76, 180]), bindingCount := 10, stage1RowCount := 10, stage2RegisterReadCount := 12, stage2RegisterWriteCount := 9, stage2RamEventCount := 0, stage3ContinuityCount := 10, points := { firstBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [30, 164, 150, 41, 218, 111, 229, 43, 231, 221, 197, 31, 58, 29, 115, 85, 208, 133, 131, 125, 250, 253, 29, 48, 239, 226, 164, 136, 42, 31, 76, 180]), layoutVersion := 1, digest := (bytes [2, 23, 36, 224, 210, 0, 212, 207, 158, 249, 219, 192, 213, 15, 37, 187, 50, 169, 249, 111, 79, 186, 167, 91, 214, 96, 62, 125, 172, 49, 207, 56]) }, logicalIndex := 0, digest := (bytes [32, 21, 247, 46, 165, 252, 126, 145, 33, 203, 207, 201, 62, 230, 27, 27, 232, 66, 155, 22, 122, 115, 65, 177, 2, 123, 229, 125, 52, 109, 42, 81]) }, valueDigest := (bytes [228, 186, 196, 100, 214, 97, 204, 91, 47, 206, 34, 198, 29, 200, 203, 87, 232, 28, 132, 169, 17, 190, 217, 45, 135, 51, 200, 19, 206, 178, 215, 73]), digest := (bytes [91, 97, 160, 200, 68, 174, 202, 88, 166, 212, 55, 110, 113, 209, 108, 92, 173, 115, 102, 217, 227, 92, 156, 100, 40, 171, 86, 175, 237, 25, 29, 108]) }), lastBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [30, 164, 150, 41, 218, 111, 229, 43, 231, 221, 197, 31, 58, 29, 115, 85, 208, 133, 131, 125, 250, 253, 29, 48, 239, 226, 164, 136, 42, 31, 76, 180]), layoutVersion := 1, digest := (bytes [2, 23, 36, 224, 210, 0, 212, 207, 158, 249, 219, 192, 213, 15, 37, 187, 50, 169, 249, 111, 79, 186, 167, 91, 214, 96, 62, 125, 172, 49, 207, 56]) }, logicalIndex := 9, digest := (bytes [189, 165, 196, 96, 192, 251, 188, 111, 251, 213, 241, 1, 46, 215, 183, 186, 192, 153, 126, 83, 77, 130, 177, 172, 5, 175, 64, 98, 131, 79, 2, 52]) }, valueDigest := (bytes [157, 175, 250, 167, 39, 214, 161, 115, 180, 44, 169, 119, 226, 188, 165, 171, 56, 139, 82, 47, 76, 62, 113, 120, 15, 217, 29, 244, 80, 189, 215, 4]), digest := (bytes [89, 113, 20, 133, 125, 236, 81, 58, 79, 118, 145, 126, 87, 50, 153, 70, 77, 175, 94, 211, 189, 218, 113, 229, 234, 44, 237, 36, 191, 70, 150, 195]) }) }, digest := (bytes [208, 187, 166, 62, 144, 142, 237, 212, 231, 148, 113, 64, 42, 50, 62, 245, 117, 82, 16, 10, 24, 145, 86, 45, 157, 21, 88, 164, 145, 166, 135, 129]) }, packaged := { statementDigest := (bytes [14, 153, 83, 7, 191, 96, 107, 247, 203, 172, 112, 47, 37, 72, 133, 74, 171, 216, 153, 109, 176, 181, 230, 30, 124, 162, 1, 176, 46, 250, 234, 22]), proofDigest := (bytes [47, 127, 8, 118, 80, 241, 37, 249, 41, 38, 147, 111, 60, 240, 253, 174, 5, 87, 159, 173, 97, 89, 239, 232, 152, 165, 220, 40, 117, 150, 70, 246]) }, digest := (bytes [105, 17, 253, 140, 161, 226, 141, 222, 139, 157, 43, 163, 42, 73, 21, 118, 4, 18, 117, 190, 221, 83, 239, 144, 47, 3, 84, 174, 101, 96, 127, 107]) }
    , preparedSteps := { claim := { executionDigest := (bytes [125, 109, 107, 30, 214, 28, 21, 190, 193, 73, 13, 134, 113, 2, 233, 252, 206, 60, 180, 47, 71, 229, 88, 95, 116, 143, 172, 12, 59, 79, 234, 150]), finalStateDigest := (bytes [103, 223, 139, 208, 116, 154, 142, 132, 78, 184, 137, 1, 105, 240, 117, 173, 130, 69, 168, 181, 198, 4, 200, 40, 154, 26, 30, 84, 163, 49, 80, 141]), transcriptFinalDigest := (bytes [40, 198, 217, 185, 8, 16, 125, 44, 61, 253, 171, 30, 100, 237, 238, 86, 30, 22, 230, 155, 239, 54, 28, 87, 238, 68, 77, 116, 87, 196, 144, 189]), preparedStepCount := 10, finalPc := 40, halted := true, points := { firstPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [143, 94, 45, 143, 60, 22, 127, 181, 118, 245, 141, 105, 103, 91, 39, 116, 24, 229, 56, 25, 163, 187, 169, 225, 28, 41, 160, 93, 78, 222, 50, 187]), layoutVersion := 3, digest := (bytes [32, 193, 20, 22, 26, 33, 51, 29, 241, 32, 118, 86, 8, 63, 194, 117, 170, 88, 106, 109, 35, 170, 4, 215, 35, 68, 106, 209, 247, 58, 81, 169]) }, logicalIndex := 0, digest := (bytes [158, 3, 251, 138, 251, 63, 112, 48, 112, 160, 14, 162, 124, 125, 104, 34, 131, 115, 51, 105, 65, 219, 250, 250, 11, 105, 178, 218, 121, 174, 58, 157]) }, valueDigest := (bytes [48, 9, 158, 59, 120, 45, 200, 155, 8, 144, 252, 183, 179, 168, 71, 138, 10, 136, 117, 72, 217, 133, 28, 26, 240, 134, 159, 61, 227, 8, 46, 227]), digest := (bytes [48, 177, 97, 252, 216, 198, 105, 222, 211, 46, 152, 50, 44, 9, 162, 23, 99, 209, 115, 184, 218, 49, 215, 43, 135, 145, 165, 158, 218, 63, 195, 229]) }), lastPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [143, 94, 45, 143, 60, 22, 127, 181, 118, 245, 141, 105, 103, 91, 39, 116, 24, 229, 56, 25, 163, 187, 169, 225, 28, 41, 160, 93, 78, 222, 50, 187]), layoutVersion := 3, digest := (bytes [32, 193, 20, 22, 26, 33, 51, 29, 241, 32, 118, 86, 8, 63, 194, 117, 170, 88, 106, 109, 35, 170, 4, 215, 35, 68, 106, 209, 247, 58, 81, 169]) }, logicalIndex := 9, digest := (bytes [137, 228, 202, 166, 22, 0, 88, 191, 67, 185, 149, 186, 113, 101, 68, 140, 239, 206, 226, 56, 101, 127, 28, 142, 224, 235, 111, 50, 181, 189, 101, 120]) }, valueDigest := (bytes [182, 134, 141, 237, 80, 100, 222, 51, 79, 143, 246, 177, 31, 61, 129, 193, 216, 133, 80, 85, 220, 234, 180, 38, 196, 214, 36, 167, 155, 158, 39, 109]), digest := (bytes [246, 34, 237, 85, 223, 76, 6, 194, 59, 192, 53, 65, 70, 12, 99, 47, 162, 216, 151, 42, 164, 30, 70, 182, 113, 250, 68, 5, 148, 143, 255, 90]) }) }, digest := (bytes [35, 106, 230, 80, 5, 101, 160, 67, 14, 242, 65, 0, 103, 76, 219, 47, 189, 85, 180, 123, 95, 22, 6, 91, 55, 78, 58, 17, 53, 119, 191, 189]) }, packaged := { statementDigest := (bytes [160, 135, 122, 110, 141, 156, 89, 231, 44, 67, 178, 20, 89, 59, 167, 124, 180, 170, 104, 154, 111, 76, 66, 123, 137, 4, 175, 81, 78, 203, 37, 55]), proofDigest := (bytes [231, 247, 216, 222, 136, 183, 11, 178, 211, 154, 132, 57, 191, 54, 127, 228, 49, 252, 252, 140, 48, 40, 79, 191, 234, 1, 118, 183, 50, 253, 243, 20]) }, digest := (bytes [81, 219, 54, 55, 186, 72, 121, 178, 0, 65, 66, 150, 185, 245, 31, 236, 170, 91, 0, 247, 142, 217, 220, 215, 17, 135, 253, 254, 66, 63, 153, 211]) }
    , digest := (bytes [119, 115, 69, 96, 249, 81, 149, 206, 220, 151, 99, 202, 67, 69, 201, 92, 94, 159, 3, 77, 69, 192, 47, 246, 24, 74, 248, 141, 142, 191, 2, 138])
  }

def stepComposition : StepCompositionSurfaceView :=
  {
    stage1SemanticsDigest := (bytes [151, 26, 151, 39, 124, 116, 251, 245, 14, 224, 230, 5, 28, 66, 72, 52, 144, 83, 173, 217, 174, 78, 251, 55, 16, 70, 112, 160, 241, 74, 197, 167])
    , stage2SemanticsDigest := (bytes [137, 78, 142, 226, 3, 128, 57, 191, 49, 91, 7, 13, 207, 183, 197, 131, 72, 166, 42, 115, 5, 69, 84, 159, 98, 148, 165, 72, 229, 105, 141, 120])
    , stage2TemporalDigest := (bytes [190, 191, 201, 164, 30, 44, 16, 64, 202, 129, 93, 62, 161, 96, 58, 24, 64, 194, 160, 21, 219, 79, 192, 34, 114, 247, 79, 216, 55, 77, 25, 91])
    , stage3SemanticsDigest := (bytes [186, 94, 144, 98, 86, 103, 74, 95, 114, 20, 200, 33, 117, 212, 95, 14, 198, 27, 110, 76, 101, 39, 107, 56, 57, 254, 247, 134, 184, 167, 71, 234])
    , rootExecutionDigest := (bytes [208, 187, 135, 184, 132, 13, 86, 181, 164, 206, 86, 72, 51, 229, 103, 211, 72, 251, 132, 59, 106, 210, 180, 120, 221, 136, 77, 132, 76, 126, 53, 217])
    , preparedStepBindingsDigest := (bytes [30, 164, 150, 41, 218, 111, 229, 43, 231, 221, 197, 31, 58, 29, 115, 85, 208, 133, 131, 125, 250, 253, 29, 48, 239, 226, 164, 136, 42, 31, 76, 180])
    , rowChunkRoutesDigest := (bytes [218, 161, 158, 255, 122, 203, 90, 133, 61, 184, 189, 186, 138, 38, 194, 63, 233, 205, 133, 32, 166, 190, 136, 71, 139, 40, 209, 171, 35, 80, 135, 137])
    , realRowCount := 10
    , preparedStepCount := 10
    , firstRealStepIndex := 0
    , lastRealStepIndex := 9
    , initialPc := 0
    , finalPc := 40
    , halted := true
    , digest := (bytes [50, 149, 202, 163, 33, 3, 95, 184, 123, 41, 4, 90, 219, 249, 93, 213, 64, 252, 204, 200, 154, 189, 183, 253, 138, 40, 105, 26, 118, 149, 128, 97])
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
    name := "native_shift_chain_ecall"
    , source := {
  manifest := { name := "native_shift_chain_ecall", fixtureId := "native_shift_chain_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , startPc := 0
  , programWords := [1048723, 4231443, 4278190483, 2183699, 1075958419, 3146515, 6329267, 6378547, 1080153267, 115]
  , initialRegisters := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , initialMemory := []
  , transcriptSeed := (bytes [114, 118, 54, 52, 105, 109, 45, 110, 97, 116, 105, 118, 101, 45, 115, 104, 105, 102, 116, 45, 118, 49])
}
    , derived := {
  manifest := { name := "native_shift_chain_ecall", fixtureId := "native_shift_chain_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
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
  , word := 4231443
  , opcode := .slli
  , traceOpcode := (some .slli)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 1
  , rs2 := 0
  , rs2Value := 0
  , rd := 2
  , rdBefore := 0
  , rdAfter := 16
  , imm := 4
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
  , word := 4278190483
  , opcode := .addi
  , traceOpcode := (some .addi)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 0
  , rs1Value := 0
  , rs2 := 0
  , rs2Value := 0
  , rd := 3
  , rdBefore := 0
  , rdAfter := 18446744073709551600
  , imm := -16
  , aluResult := 18446744073709551600
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
  , word := 2183699
  , opcode := .srli
  , traceOpcode := (some .srli)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 2
  , rs1Value := 16
  , rs2 := 0
  , rs2Value := 0
  , rd := 4
  , rdBefore := 0
  , rdAfter := 4
  , imm := 2
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
  traceIndex := 4
  , stepIndex := 4
  , sequenceIndex := 0
  , pc := 16
  , nextPc := 20
  , word := 1075958419
  , opcode := .srai
  , traceOpcode := (some .srai)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 3
  , rs1Value := 18446744073709551600
  , rs2 := 0
  , rs2Value := 0
  , rd := 5
  , rdBefore := 0
  , rdAfter := 18446744073709551612
  , imm := 2
  , aluResult := 18446744073709551612
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
  , word := 3146515
  , opcode := .addi
  , traceOpcode := (some .addi)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 0
  , rs1Value := 0
  , rs2 := 0
  , rs2Value := 0
  , rd := 6
  , rdBefore := 0
  , rdAfter := 3
  , imm := 3
  , aluResult := 3
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
  , word := 6329267
  , opcode := .sll
  , traceOpcode := (some .sll)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 1
  , rs2 := 6
  , rs2Value := 3
  , rd := 7
  , rdBefore := 0
  , rdAfter := 8
  , imm := 0
  , aluResult := 8
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
  traceIndex := 7
  , stepIndex := 7
  , sequenceIndex := 0
  , pc := 28
  , nextPc := 32
  , word := 6378547
  , opcode := .srl
  , traceOpcode := (some .srl)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 2
  , rs1Value := 16
  , rs2 := 6
  , rs2Value := 3
  , rd := 8
  , rdBefore := 0
  , rdAfter := 2
  , imm := 0
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
  traceIndex := 8
  , stepIndex := 8
  , sequenceIndex := 0
  , pc := 32
  , nextPc := 36
  , word := 1080153267
  , opcode := .sra
  , traceOpcode := (some .sra)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 3
  , rs1Value := 18446744073709551600
  , rs2 := 6
  , rs2Value := 3
  , rd := 9
  , rdBefore := 0
  , rdAfter := 18446744073709551614
  , imm := 0
  , aluResult := 18446744073709551614
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
  traceIndex := 9
  , stepIndex := 9
  , sequenceIndex := 0
  , pc := 36
  , nextPc := 40
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
  , stage1 := { rows := [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 1048723, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 4, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 1, rdAfter := 1, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 4231443, opcode := .slli, traceOpcode := (some .slli), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 8, aluResult := 16, effectiveAddr := none, writesRd := true, rd := 2, rdAfter := 16, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 4278190483, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 12, aluResult := 18446744073709551600, effectiveAddr := none, writesRd := true, rd := 3, rdAfter := 18446744073709551600, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 12, fetchedWord := 2183699, opcode := .srli, traceOpcode := (some .srli), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 16, aluResult := 4, effectiveAddr := none, writesRd := true, rd := 4, rdAfter := 4, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 4, stepIndex := 4, sequenceIndex := 0, fetchPc := 16, fetchedWord := 1075958419, opcode := .srai, traceOpcode := (some .srai), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 20, aluResult := 18446744073709551612, effectiveAddr := none, writesRd := true, rd := 5, rdAfter := 18446744073709551612, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 5, stepIndex := 5, sequenceIndex := 0, fetchPc := 20, fetchedWord := 3146515, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 24, aluResult := 3, effectiveAddr := none, writesRd := true, rd := 6, rdAfter := 3, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 6, stepIndex := 6, sequenceIndex := 0, fetchPc := 24, fetchedWord := 6329267, opcode := .sll, traceOpcode := (some .sll), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 28, aluResult := 8, effectiveAddr := none, writesRd := true, rd := 7, rdAfter := 8, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 7, stepIndex := 7, sequenceIndex := 0, fetchPc := 28, fetchedWord := 6378547, opcode := .srl, traceOpcode := (some .srl), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 32, aluResult := 2, effectiveAddr := none, writesRd := true, rd := 8, rdAfter := 2, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 8, stepIndex := 8, sequenceIndex := 0, fetchPc := 32, fetchedWord := 1080153267, opcode := .sra, traceOpcode := (some .sra), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 36, aluResult := 18446744073709551614, effectiveAddr := none, writesRd := true, rd := 9, rdAfter := 18446744073709551614, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 9, stepIndex := 9, sequenceIndex := 0, fetchPc := 36, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 40, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }] }
  , stage2 := {
  registerReads := [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 0, value := 0 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 1, value := 1 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 0, value := 0 }, { traceIndex := 3, stepIndex := 3, role := .rs1, reg := 2, value := 16 }, { traceIndex := 4, stepIndex := 4, role := .rs1, reg := 3, value := 18446744073709551600 }, { traceIndex := 5, stepIndex := 5, role := .rs1, reg := 0, value := 0 }, { traceIndex := 6, stepIndex := 6, role := .rs1, reg := 1, value := 1 }, { traceIndex := 6, stepIndex := 6, role := .rs2, reg := 6, value := 3 }, { traceIndex := 7, stepIndex := 7, role := .rs1, reg := 2, value := 16 }, { traceIndex := 7, stepIndex := 7, role := .rs2, reg := 6, value := 3 }, { traceIndex := 8, stepIndex := 8, role := .rs1, reg := 3, value := 18446744073709551600 }, { traceIndex := 8, stepIndex := 8, role := .rs2, reg := 6, value := 3 }]
  , registerWrites := [{ traceIndex := 0, stepIndex := 0, reg := 1, previous := 0, next := 1 }, { traceIndex := 1, stepIndex := 1, reg := 2, previous := 0, next := 16 }, { traceIndex := 2, stepIndex := 2, reg := 3, previous := 0, next := 18446744073709551600 }, { traceIndex := 3, stepIndex := 3, reg := 4, previous := 0, next := 4 }, { traceIndex := 4, stepIndex := 4, reg := 5, previous := 0, next := 18446744073709551612 }, { traceIndex := 5, stepIndex := 5, reg := 6, previous := 0, next := 3 }, { traceIndex := 6, stepIndex := 6, reg := 7, previous := 0, next := 8 }, { traceIndex := 7, stepIndex := 7, reg := 8, previous := 0, next := 2 }, { traceIndex := 8, stepIndex := 8, reg := 9, previous := 0, next := 18446744073709551614 }]
  , ramEvents := []
  , twistLinks := [{ traceIndex := 0, stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 1, family := .nativeAlu, routedWriteValue := (some 16), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 2, family := .nativeAlu, routedWriteValue := (some 18446744073709551600), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 3, family := .nativeAlu, routedWriteValue := (some 4), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 4, stepIndex := 4, family := .nativeAlu, routedWriteValue := (some 18446744073709551612), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 5, stepIndex := 5, family := .nativeAlu, routedWriteValue := (some 3), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 6, stepIndex := 6, family := .nativeAlu, routedWriteValue := (some 8), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 7, stepIndex := 7, family := .nativeAlu, routedWriteValue := (some 2), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 8, stepIndex := 8, family := .nativeAlu, routedWriteValue := (some 18446744073709551614), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 9, stepIndex := 9, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]
}
  , stage3 := {
  continuity := [{ stepIndex := 0, pc := 0, nextPc := 4, successorPc := (some 4), finalStep := false, continuityHolds := true }, { stepIndex := 1, pc := 4, nextPc := 8, successorPc := (some 8), finalStep := false, continuityHolds := true }, { stepIndex := 2, pc := 8, nextPc := 12, successorPc := (some 12), finalStep := false, continuityHolds := true }, { stepIndex := 3, pc := 12, nextPc := 16, successorPc := (some 16), finalStep := false, continuityHolds := true }, { stepIndex := 4, pc := 16, nextPc := 20, successorPc := (some 20), finalStep := false, continuityHolds := true }, { stepIndex := 5, pc := 20, nextPc := 24, successorPc := (some 24), finalStep := false, continuityHolds := true }, { stepIndex := 6, pc := 24, nextPc := 28, successorPc := (some 28), finalStep := false, continuityHolds := true }, { stepIndex := 7, pc := 28, nextPc := 32, successorPc := (some 32), finalStep := false, continuityHolds := true }, { stepIndex := 8, pc := 32, nextPc := 36, successorPc := (some 36), finalStep := false, continuityHolds := true }, { stepIndex := 9, pc := 36, nextPc := 40, successorPc := none, finalStep := true, continuityHolds := true }]
  , halted := true
}
  , transcript := {
  appLabel := (bytes [110, 101, 111, 46, 102, 111, 108, 100, 46, 110, 101, 120, 116, 47, 114, 118, 54, 52, 105, 109, 47, 112, 97, 114, 105, 116, 121, 95, 107, 101, 114, 110, 101, 108, 95, 118, 49])
  , events := [{
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 116, 114, 97, 110, 115, 99, 114, 105, 112, 116, 95, 115, 101, 101, 100])
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 110, 97, 116, 105, 118, 101, 45, 115, 104, 105, 102, 116, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [33264025209497715, 49, 3390619080185759186, 12096819762988914126, 4001610679670701799, 5432763535062103318, 13415967828788768464, 15663373744946530692], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [110, 97, 116, 105, 118, 101, 95, 115, 104, 105, 102, 116, 95, 99, 104, 97, 105, 110, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [33264025209497715, 49, 3390619080185759186, 12096819762988914126, 4001610679670701799, 5432763535062103318, 13415967828788768464, 15663373744946530692], absorbed := 2 }
  , cursorAfter := { stateWords := [9343583599440594713, 10983263396399423942, 10213758535099150043, 17999485627249729703, 8213066104219617703, 12273497441021069772, 14876407735256743716, 15476744526804179329], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [1048723, 4231443, 4278190483, 2183699, 1075958419, 3146515, 6329267, 6378547, 1080153267, 115]
  , cursorBefore := { stateWords := [9343583599440594713, 10983263396399423942, 10213758535099150043, 17999485627249729703, 8213066104219617703, 12273497441021069772, 14876407735256743716, 15476744526804179329], absorbed := 0 }
  , cursorAfter := { stateWords := [115, 0, 12132189991474095693, 5724097830014706505, 4009596014858473286, 5995263417795965784, 408868401535594138, 17006945087715718041], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [115, 0, 12132189991474095693, 5724097830014706505, 4009596014858473286, 5995263417795965784, 408868401535594138, 17006945087715718041], absorbed := 2 }
  , cursorAfter := { stateWords := [3528834191574932829, 6155173375791115620, 13609196687032797688, 11002803251645454761, 12206787759704429923, 16410673065852401615, 2598699549887548923, 12066494163384387956], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [3528834191574932829, 6155173375791115620, 13609196687032797688, 11002803251645454761, 12206787759704429923, 16410673065852401615, 2598699549887548923, 12066494163384387956], absorbed := 0 }
  , cursorAfter := { stateWords := [34184295084289375, 0, 3573761302448998257, 4094924913629440852, 4449727207908542588, 7274712621141095245, 10189188638743606548, 8854558257557134109], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [100, 141, 133, 191, 65, 9, 202, 67, 178, 73, 161, 90, 192, 177, 16, 176, 7, 146, 125, 14, 199, 63, 180, 56, 245, 33, 2, 6, 126, 240, 189, 23])
  , u64s := []
  , cursorBefore := { stateWords := [34184295084289375, 0, 3573761302448998257, 4094924913629440852, 4449727207908542588, 7274712621141095245, 10189188638743606548, 8854558257557134109], absorbed := 2 }
  , cursorAfter := { stateWords := [398323838, 13563848412886993082, 5367215074576215338, 5585458906983765709, 8449989835503769803, 11906319393298175280, 17849796046869045789, 15345541679146046444], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [398323838, 13563848412886993082, 5367215074576215338, 5585458906983765709, 8449989835503769803, 11906319393298175280, 17849796046869045789, 15345541679146046444], absorbed := 1 }
  , cursorAfter := { stateWords := [16691009948854132645, 8590394677687983344, 6791025823853643633, 8055613139477747472, 2334784384309520970, 8120023813436867814, 12534626429442971049, 10949312597069331114], absorbed := 0 }
  , challengeOutput := (some 16691009948854132645)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [134, 144, 193, 223, 148, 183, 65, 251, 150, 253, 209, 238, 38, 219, 86, 43, 84, 158, 62, 219, 12, 185, 17, 172, 250, 121, 161, 155, 34, 218, 192, 23])
  , u64s := []
  , cursorBefore := { stateWords := [16691009948854132645, 8590394677687983344, 6791025823853643633, 8055613139477747472, 2334784384309520970, 8120023813436867814, 12534626429442971049, 10949312597069331114], absorbed := 0 }
  , cursorAfter := { stateWords := [3618761711299414, 43806166658847161, 398514722, 7027272740655351469, 4546986030328210763, 14841835654066153876, 15041005742323689594, 17480490590060115057], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [3618761711299414, 43806166658847161, 398514722, 7027272740655351469, 4546986030328210763, 14841835654066153876, 15041005742323689594, 17480490590060115057], absorbed := 3 }
  , cursorAfter := { stateWords := [4919044041631935056, 14189116834329926604, 12419105555469757780, 14270356555172948800, 8093844472540501353, 9124786461151767659, 7152703984857230834, 13210800323996142899], absorbed := 0 }
  , challengeOutput := (some 4919044041631935056)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [4919044041631935056, 14189116834329926604, 12419105555469757780, 14270356555172948800, 8093844472540501353, 9124786461151767659, 7152703984857230834, 13210800323996142899], absorbed := 0 }
  , cursorAfter := { stateWords := [16264464362193895577, 11461908290415474824, 11397215704295747164, 9824510442467619620, 18290234949193389834, 5594432991877263909, 9081794983633899672, 10912585245568592430], absorbed := 0 }
  , challengeOutput := (some 16264464362193895577)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [157, 229, 195, 131, 139, 8, 105, 108, 185, 165, 44, 241, 226, 186, 221, 169, 117, 119, 57, 226, 94, 130, 90, 239, 124, 28, 101, 251, 70, 102, 122, 148])
  , u64s := []
  , cursorBefore := { stateWords := [16264464362193895577, 11461908290415474824, 11397215704295747164, 9824510442467619620, 18290234949193389834, 5594432991877263909, 9081794983633899672, 10912585245568592430], absorbed := 0 }
  , cursorAfter := { stateWords := [26707384256014813, 70761392183925378, 2491049542, 9507906175547332923, 3730582484654031885, 16876102647749534996, 12581855173648909236, 16514804110931742469], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [26707384256014813, 70761392183925378, 2491049542, 9507906175547332923, 3730582484654031885, 16876102647749534996, 12581855173648909236, 16514804110931742469], absorbed := 3 }
  , cursorAfter := { stateWords := [9654341997663817196, 5004801482934633826, 15589065540793569337, 16974695238686938950, 705696601170899424, 17826056565796222072, 17185746199196365289, 17250980329634985717], absorbed := 0 }
  , challengeOutput := (some 9654341997663817196)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [234, 177, 23, 67, 38, 251, 33, 157, 164, 66, 116, 34, 106, 3, 185, 174, 39, 193, 22, 250, 158, 150, 184, 2, 134, 157, 45, 214, 185, 100, 216, 30])
  , u64s := []
  , cursorBefore := { stateWords := [9654341997663817196, 5004801482934633826, 15589065540793569337, 16974695238686938950, 705696601170899424, 17826056565796222072, 17185746199196365289, 17250980329634985717], absorbed := 0 }
  , cursorAfter := { stateWords := [44748021957111481, 60285799597521046, 517498041, 13646145847636500251, 11517170574194729242, 3460917812286701909, 4557134827179065529, 17390159929072289930], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [125, 109, 107, 30, 214, 28, 21, 190, 193, 73, 13, 134, 113, 2, 233, 252, 206, 60, 180, 47, 71, 229, 88, 95, 116, 143, 172, 12, 59, 79, 234, 150])
  , u64s := []
  , cursorBefore := { stateWords := [44748021957111481, 60285799597521046, 517498041, 13646145847636500251, 11517170574194729242, 3460917812286701909, 4557134827179065529, 17390159929072289930], absorbed := 3 }
  , cursorAfter := { stateWords := [20037174507273449, 3567431853234405, 2531938107, 1325518863947626039, 8964014674430181503, 15342147114171615346, 13426727881498678871, 139830257145797863], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [103, 223, 139, 208, 116, 154, 142, 132, 78, 184, 137, 1, 105, 240, 117, 173, 130, 69, 168, 181, 198, 4, 200, 40, 154, 26, 30, 84, 163, 49, 80, 141])
  , u64s := []
  , cursorBefore := { stateWords := [20037174507273449, 3567431853234405, 2531938107, 1325518863947626039, 8964014674430181503, 15342147114171615346, 13426727881498678871, 139830257145797863], absorbed := 3 }
  , cursorAfter := { stateWords := [55931779714035061, 23676997648041988, 2370843043, 7093541884208153986, 7915818848580902698, 3476745757337338623, 13097431133370823525, 1567520043707639019], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [55931779714035061, 23676997648041988, 2370843043, 7093541884208153986, 7915818848580902698, 3476745757337338623, 13097431133370823525, 1567520043707639019], absorbed := 3 }
  , cursorAfter := { stateWords := [10261008020113467646, 10108384727196382461, 17846612664083407406, 14694403235617166691, 13277652733314478642, 5223581477044193931, 5580092013888805740, 758801733075114328], absorbed := 0 }
  , challengeOutput := (some 10261008020113467646)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [10261008020113467646, 10108384727196382461, 17846612664083407406, 14694403235617166691, 13277652733314478642, 5223581477044193931, 5580092013888805740, 758801733075114328], absorbed := 0 }
  , cursorAfter := { stateWords := [3205736139421500968, 6264205145986039101, 6276952383388259870, 13659633549707134190, 7916290875057399432, 528344911851888055, 206090245114880306, 7344352859528851009], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [40, 198, 217, 185, 8, 16, 125, 44, 61, 253, 171, 30, 100, 237, 238, 86, 30, 22, 230, 155, 239, 54, 28, 87, 238, 68, 77, 116, 87, 196, 144, 189]))
}]
}
  , kernel := {
  root0Digest := (bytes [100, 141, 133, 191, 65, 9, 202, 67, 178, 73, 161, 90, 192, 177, 16, 176, 7, 146, 125, 14, 199, 63, 180, 56, 245, 33, 2, 6, 126, 240, 189, 23])
  , stage1Digest := (bytes [134, 144, 193, 223, 148, 183, 65, 251, 150, 253, 209, 238, 38, 219, 86, 43, 84, 158, 62, 219, 12, 185, 17, 172, 250, 121, 161, 155, 34, 218, 192, 23])
  , stage2Digest := (bytes [157, 229, 195, 131, 139, 8, 105, 108, 185, 165, 44, 241, 226, 186, 221, 169, 117, 119, 57, 226, 94, 130, 90, 239, 124, 28, 101, 251, 70, 102, 122, 148])
  , stage3Digest := (bytes [234, 177, 23, 67, 38, 251, 33, 157, 164, 66, 116, 34, 106, 3, 185, 174, 39, 193, 22, 250, 158, 150, 184, 2, 134, 157, 45, 214, 185, 100, 216, 30])
  , executionDigest := (bytes [125, 109, 107, 30, 214, 28, 21, 190, 193, 73, 13, 134, 113, 2, 233, 252, 206, 60, 180, 47, 71, 229, 88, 95, 116, 143, 172, 12, 59, 79, 234, 150])
  , finalStateDigest := (bytes [103, 223, 139, 208, 116, 154, 142, 132, 78, 184, 137, 1, 105, 240, 117, 173, 130, 69, 168, 181, 198, 4, 200, 40, 154, 26, 30, 84, 163, 49, 80, 141])
  , stage1Mix := 16691009948854132645
  , stage2RegMix := 4919044041631935056
  , stage2RamMix := 16264464362193895577
  , stage3ContinuityMix := 9654341997663817196
  , kernelFinalMix := 10261008020113467646
  , transcriptFinalDigest := (bytes [40, 198, 217, 185, 8, 16, 125, 44, 61, 253, 171, 30, 100, 237, 238, 86, 30, 22, 230, 155, 239, 54, 28, 87, 238, 68, 77, 116, 87, 196, 144, 189])
  , finalPc := 40
  , finalRegisters := [0, 1, 16, 18446744073709551600, 4, 18446744073709551612, 3, 8, 2, 18446744073709551614, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , finalMemory := []
  , halted := true
}
}
    , kernelProof := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "native_shift_chain_ecall", fixtureId := "native_shift_chain_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , executionDigest := (bytes [125, 109, 107, 30, 214, 28, 21, 190, 193, 73, 13, 134, 113, 2, 233, 252, 206, 60, 180, 47, 71, 229, 88, 95, 116, 143, 172, 12, 59, 79, 234, 150])
  , shape := { executionRowCount := 10, realRowCount := 10, effectRowCount := 10, commitRowCount := 10, digest := (bytes [112, 139, 125, 186, 65, 232, 254, 194, 0, 75, 41, 115, 118, 66, 196, 105, 51, 14, 26, 159, 116, 35, 103, 9, 240, 124, 96, 130, 114, 5, 66, 126]) }
  , digest := (bytes [88, 119, 98, 13, 111, 130, 86, 174, 128, 138, 42, 115, 149, 129, 170, 120, 133, 40, 140, 114, 109, 125, 63, 210, 101, 48, 53, 168, 174, 117, 116, 179])
}
  , stages := { summary := { stage1RowCount := 10, stage2RegisterReadCount := 12, stage2RegisterWriteCount := 9, stage2RamEventCount := 0, stage2TwistLinkCount := 10, stage3ContinuityCount := 10, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [182, 88, 119, 178, 173, 139, 2, 120, 38, 241, 130, 157, 51, 75, 125, 230, 46, 252, 195, 62, 2, 4, 209, 233, 243, 210, 102, 203, 155, 170, 137, 196]) }, digest := (bytes [165, 169, 132, 131, 219, 58, 190, 147, 230, 10, 193, 16, 55, 193, 168, 83, 13, 115, 211, 67, 151, 50, 203, 71, 52, 226, 54, 108, 249, 109, 12, 194]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [63, 174, 85, 23, 132, 59, 164, 91, 219, 152, 118, 75, 81, 162, 203, 103, 38, 248, 208, 230, 243, 2, 237, 20, 96, 223, 24, 199, 67, 231, 4, 104]), stage1Digest := (bytes [102, 83, 120, 230, 208, 62, 162, 142, 24, 32, 119, 9, 11, 24, 97, 204, 106, 60, 128, 52, 172, 61, 9, 199, 179, 68, 37, 136, 147, 34, 125, 249]), stage2Digest := (bytes [222, 241, 73, 158, 149, 26, 237, 199, 105, 195, 107, 195, 113, 106, 151, 33, 10, 191, 23, 71, 7, 123, 23, 92, 172, 171, 255, 252, 26, 144, 255, 12]), stage3Digest := (bytes [82, 5, 191, 228, 29, 143, 146, 70, 210, 162, 133, 104, 132, 207, 23, 6, 167, 217, 152, 44, 223, 222, 180, 240, 61, 220, 69, 241, 83, 34, 91, 99]), transcriptDigest := (bytes [40, 198, 217, 185, 8, 16, 125, 44, 61, 253, 171, 30, 100, 237, 238, 86, 30, 22, 230, 155, 239, 54, 28, 87, 238, 68, 77, 116, 87, 196, 144, 189]), executionDigest := (bytes [125, 109, 107, 30, 214, 28, 21, 190, 193, 73, 13, 134, 113, 2, 233, 252, 206, 60, 180, 47, 71, 229, 88, 95, 116, 143, 172, 12, 59, 79, 234, 150]), digest := (bytes [119, 119, 96, 244, 71, 146, 91, 58, 24, 68, 255, 24, 93, 173, 78, 140, 21, 31, 194, 166, 124, 163, 86, 49, 24, 209, 46, 222, 37, 6, 187, 191]) }, statementDigest := (bytes [126, 146, 37, 155, 39, 220, 180, 4, 242, 78, 225, 66, 250, 95, 176, 124, 237, 49, 145, 231, 136, 82, 170, 203, 92, 38, 148, 28, 66, 16, 176, 179]), proofDigest := (bytes [222, 162, 167, 196, 223, 72, 3, 60, 61, 16, 115, 109, 128, 252, 138, 110, 186, 29, 232, 71, 30, 215, 84, 147, 242, 139, 51, 160, 22, 69, 97, 245]), digest := (bytes [157, 217, 182, 50, 102, 253, 73, 90, 236, 226, 136, 241, 15, 164, 204, 21, 241, 250, 31, 176, 23, 65, 64, 84, 28, 75, 159, 11, 136, 45, 9, 201]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [113, 110, 176, 95, 213, 2, 56, 45, 40, 202, 182, 238, 248, 121, 61, 153, 97, 17, 173, 150, 8, 23, 251, 135, 103, 190, 218, 12, 139, 247, 226, 169]), stage1Digest := (bytes [43, 186, 189, 15, 117, 33, 34, 68, 18, 3, 84, 129, 2, 91, 173, 225, 193, 37, 15, 208, 50, 249, 112, 52, 130, 65, 94, 111, 22, 73, 76, 78]), stage2Digest := (bytes [253, 241, 232, 168, 55, 211, 246, 203, 25, 241, 20, 54, 184, 114, 92, 233, 233, 199, 77, 26, 70, 65, 25, 201, 15, 55, 146, 156, 222, 134, 247, 183]), stage3Digest := (bytes [123, 200, 171, 142, 73, 227, 53, 197, 73, 245, 79, 164, 187, 42, 144, 179, 84, 250, 64, 72, 82, 210, 170, 82, 241, 181, 251, 189, 13, 255, 120, 86]), digest := (bytes [133, 21, 66, 136, 48, 137, 198, 59, 148, 231, 171, 98, 105, 70, 132, 93, 153, 70, 79, 47, 95, 196, 59, 124, 6, 157, 193, 132, 228, 80, 114, 230]) }, digest := (bytes [52, 150, 130, 38, 165, 150, 120, 60, 9, 255, 119, 17, 136, 162, 5, 129, 56, 141, 234, 26, 228, 172, 50, 243, 205, 148, 140, 78, 183, 140, 115, 201]) }
  , kernelOpening := { openingDigest := (bytes [119, 115, 69, 96, 249, 81, 149, 206, 220, 151, 99, 202, 67, 69, 201, 92, 94, 159, 3, 77, 69, 192, 47, 246, 24, 74, 248, 141, 142, 191, 2, 138]), bindings := { claimDigest := (bytes [237, 233, 103, 61, 197, 60, 93, 141, 147, 156, 156, 127, 58, 72, 103, 44, 100, 145, 190, 255, 134, 121, 188, 169, 23, 16, 186, 120, 221, 196, 248, 22]), bindingsDigest := (bytes [105, 17, 253, 140, 161, 226, 141, 222, 139, 157, 43, 163, 42, 73, 21, 118, 4, 18, 117, 190, 221, 83, 239, 144, 47, 3, 84, 174, 101, 96, 127, 107]), preparedStepsDigest := (bytes [81, 219, 54, 55, 186, 72, 121, 178, 0, 65, 66, 150, 185, 245, 31, 236, 170, 91, 0, 247, 142, 217, 220, 215, 17, 135, 253, 254, 66, 63, 153, 211]), digest := (bytes [150, 94, 158, 112, 210, 229, 71, 125, 37, 46, 29, 188, 68, 12, 154, 71, 104, 118, 105, 175, 201, 75, 93, 53, 192, 95, 59, 55, 235, 106, 233, 0]) }, digest := (bytes [186, 38, 161, 225, 204, 168, 253, 188, 96, 231, 230, 92, 153, 18, 36, 164, 241, 82, 9, 4, 151, 96, 212, 85, 114, 235, 209, 49, 240, 134, 110, 101]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [30, 164, 150, 41, 218, 111, 229, 43, 231, 221, 197, 31, 58, 29, 115, 85, 208, 133, 131, 125, 250, 253, 29, 48, 239, 226, 164, 136, 42, 31, 76, 180]), terminal := { root0Digest := (bytes [100, 141, 133, 191, 65, 9, 202, 67, 178, 73, 161, 90, 192, 177, 16, 176, 7, 146, 125, 14, 199, 63, 180, 56, 245, 33, 2, 6, 126, 240, 189, 23]), executionDigest := (bytes [125, 109, 107, 30, 214, 28, 21, 190, 193, 73, 13, 134, 113, 2, 233, 252, 206, 60, 180, 47, 71, 229, 88, 95, 116, 143, 172, 12, 59, 79, 234, 150]), finalStateDigest := (bytes [103, 223, 139, 208, 116, 154, 142, 132, 78, 184, 137, 1, 105, 240, 117, 173, 130, 69, 168, 181, 198, 4, 200, 40, 154, 26, 30, 84, 163, 49, 80, 141]), transcriptFinalDigest := (bytes [40, 198, 217, 185, 8, 16, 125, 44, 61, 253, 171, 30, 100, 237, 238, 86, 30, 22, 230, 155, 239, 54, 28, 87, 238, 68, 77, 116, 87, 196, 144, 189]), finalPc := 40, halted := true, digest := (bytes [144, 111, 188, 226, 66, 170, 58, 159, 68, 203, 38, 149, 106, 226, 154, 125, 200, 223, 159, 59, 47, 55, 193, 41, 253, 116, 109, 155, 245, 29, 95, 125]) }, digest := (bytes [142, 36, 38, 156, 150, 255, 148, 120, 152, 162, 171, 102, 136, 163, 255, 130, 69, 240, 176, 63, 222, 134, 222, 107, 42, 199, 112, 201, 191, 32, 249, 214]) }, statementDigest := (bytes [236, 221, 46, 4, 110, 86, 195, 216, 120, 3, 130, 111, 87, 29, 63, 57, 107, 2, 247, 98, 191, 146, 95, 48, 62, 151, 183, 255, 39, 157, 73, 119]), proofDigest := (bytes [122, 78, 120, 200, 161, 108, 181, 126, 26, 14, 240, 3, 67, 156, 181, 117, 40, 145, 19, 78, 22, 40, 243, 33, 241, 9, 216, 89, 158, 63, 50, 190]), digest := (bytes [242, 42, 150, 57, 63, 86, 128, 252, 140, 109, 108, 250, 72, 222, 150, 43, 79, 38, 0, 73, 171, 248, 214, 3, 53, 71, 222, 85, 180, 82, 15, 117]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [57, 96, 173, 107, 74, 96, 6, 184, 93, 44, 158, 222, 17, 105, 235, 100, 93, 195, 146, 163, 228, 224, 253, 134, 235, 58, 173, 222, 168, 61, 29, 210]), layoutVersion := 1, digest := (bytes [218, 252, 26, 46, 28, 218, 125, 203, 192, 156, 76, 141, 163, 163, 128, 206, 131, 248, 235, 86, 73, 170, 207, 167, 89, 133, 185, 83, 239, 57, 137, 201]) }, rowWidth := 38, timeLen := 10, columnDigests := [(bytes [12, 228, 244, 232, 232, 195, 81, 12, 214, 193, 42, 183, 200, 29, 152, 94, 136, 29, 6, 38, 78, 210, 160, 183, 216, 225, 73, 147, 50, 136, 142, 214]), (bytes [240, 182, 76, 250, 35, 170, 242, 238, 13, 3, 36, 197, 217, 34, 88, 179, 25, 179, 252, 9, 53, 253, 106, 155, 210, 71, 3, 170, 179, 214, 158, 65]), (bytes [195, 188, 63, 10, 98, 211, 186, 126, 183, 152, 82, 190, 233, 91, 13, 44, 234, 86, 153, 242, 47, 0, 90, 173, 178, 126, 238, 39, 206, 42, 90, 234]), (bytes [8, 42, 43, 132, 150, 119, 43, 88, 120, 73, 248, 4, 160, 61, 234, 157, 237, 5, 30, 176, 13, 32, 132, 34, 140, 232, 248, 156, 189, 150, 158, 132]), (bytes [183, 153, 10, 248, 62, 168, 118, 167, 230, 138, 239, 173, 144, 140, 163, 208, 253, 182, 92, 210, 65, 128, 123, 109, 59, 243, 8, 21, 192, 111, 223, 235]), (bytes [96, 49, 53, 146, 252, 231, 2, 133, 7, 150, 231, 243, 19, 147, 34, 3, 19, 95, 125, 142, 225, 119, 94, 30, 41, 92, 213, 40, 58, 73, 204, 178]), (bytes [6, 202, 216, 137, 252, 35, 77, 13, 181, 151, 136, 136, 116, 231, 11, 46, 57, 52, 185, 82, 154, 67, 81, 140, 148, 104, 11, 88, 174, 229, 167, 189]), (bytes [48, 51, 138, 201, 111, 86, 152, 134, 106, 27, 115, 24, 34, 241, 131, 144, 253, 88, 175, 132, 8, 28, 83, 227, 186, 166, 5, 153, 14, 152, 167, 155]), (bytes [38, 189, 190, 109, 40, 90, 176, 164, 205, 6, 244, 99, 155, 110, 177, 188, 15, 110, 175, 155, 25, 30, 14, 180, 42, 110, 165, 250, 171, 206, 182, 252]), (bytes [237, 165, 119, 146, 86, 53, 241, 200, 114, 247, 22, 68, 204, 180, 71, 182, 30, 146, 193, 238, 245, 34, 150, 29, 228, 223, 212, 88, 34, 209, 138, 59]), (bytes [100, 157, 167, 161, 144, 13, 101, 250, 75, 66, 176, 27, 234, 116, 230, 94, 68, 12, 251, 12, 193, 57, 231, 191, 86, 6, 57, 71, 28, 61, 41, 243]), (bytes [55, 104, 163, 114, 203, 113, 243, 96, 246, 239, 169, 197, 247, 25, 87, 83, 254, 89, 219, 112, 50, 58, 113, 40, 39, 11, 128, 37, 130, 105, 141, 223]), (bytes [75, 32, 207, 134, 219, 18, 161, 48, 94, 95, 165, 227, 110, 209, 210, 37, 12, 218, 2, 100, 69, 87, 80, 84, 199, 63, 213, 142, 156, 83, 58, 207]), (bytes [67, 239, 94, 227, 76, 210, 86, 117, 147, 191, 52, 217, 52, 78, 157, 14, 95, 144, 135, 97, 188, 115, 47, 236, 121, 233, 209, 179, 61, 184, 178, 88]), (bytes [72, 188, 177, 89, 243, 172, 72, 201, 140, 24, 218, 201, 12, 85, 51, 235, 118, 224, 89, 207, 230, 208, 206, 156, 116, 113, 199, 219, 143, 79, 31, 182]), (bytes [70, 226, 162, 48, 249, 249, 238, 229, 208, 237, 173, 243, 12, 180, 219, 129, 178, 47, 57, 146, 39, 248, 168, 200, 27, 239, 97, 103, 235, 87, 98, 152]), (bytes [168, 135, 31, 110, 99, 170, 118, 153, 62, 23, 162, 146, 237, 131, 59, 107, 61, 171, 125, 141, 126, 72, 211, 252, 87, 247, 107, 97, 184, 97, 115, 62]), (bytes [195, 241, 122, 156, 175, 234, 131, 108, 215, 171, 109, 221, 145, 195, 177, 216, 224, 3, 71, 137, 168, 123, 92, 150, 220, 244, 199, 164, 30, 190, 118, 196]), (bytes [91, 173, 31, 113, 28, 0, 124, 210, 36, 221, 147, 10, 225, 65, 253, 252, 190, 167, 173, 20, 27, 91, 29, 243, 214, 72, 147, 137, 219, 101, 249, 19]), (bytes [59, 90, 50, 88, 131, 202, 40, 187, 147, 95, 62, 165, 211, 185, 201, 13, 248, 93, 124, 178, 255, 171, 133, 136, 142, 97, 27, 17, 233, 80, 74, 206]), (bytes [66, 136, 207, 236, 216, 66, 254, 209, 16, 181, 177, 57, 69, 165, 202, 200, 200, 139, 52, 180, 129, 129, 57, 57, 45, 36, 235, 80, 85, 41, 104, 97]), (bytes [250, 243, 36, 121, 222, 230, 87, 172, 149, 80, 32, 187, 23, 44, 161, 164, 116, 82, 156, 142, 181, 200, 8, 117, 73, 175, 232, 208, 178, 248, 111, 216]), (bytes [176, 39, 109, 185, 241, 9, 236, 176, 30, 215, 238, 28, 183, 191, 205, 114, 166, 252, 186, 41, 162, 90, 213, 56, 162, 0, 252, 238, 13, 68, 157, 75]), (bytes [191, 14, 23, 70, 191, 143, 164, 138, 31, 103, 126, 202, 195, 103, 102, 91, 13, 76, 74, 232, 113, 19, 110, 181, 239, 121, 83, 104, 130, 66, 20, 253]), (bytes [161, 175, 165, 91, 84, 150, 30, 59, 1, 249, 254, 100, 229, 185, 223, 86, 127, 89, 230, 146, 65, 69, 137, 203, 79, 105, 52, 90, 109, 2, 37, 33]), (bytes [233, 165, 191, 129, 157, 1, 246, 73, 33, 152, 81, 181, 88, 226, 255, 164, 136, 147, 176, 124, 163, 119, 171, 116, 230, 54, 36, 93, 201, 201, 12, 154]), (bytes [120, 241, 77, 148, 156, 149, 19, 10, 198, 193, 143, 175, 140, 145, 200, 37, 79, 90, 110, 93, 33, 50, 32, 17, 152, 164, 75, 183, 13, 110, 138, 180]), (bytes [180, 238, 180, 101, 177, 238, 139, 240, 30, 235, 37, 156, 160, 17, 158, 230, 150, 48, 150, 208, 185, 74, 30, 212, 220, 22, 112, 242, 233, 187, 105, 34]), (bytes [15, 1, 218, 124, 15, 223, 36, 143, 32, 158, 170, 206, 91, 155, 126, 37, 196, 143, 155, 198, 194, 142, 246, 15, 222, 133, 213, 79, 12, 118, 55, 86]), (bytes [234, 5, 33, 209, 57, 239, 56, 248, 2, 242, 172, 102, 200, 208, 75, 112, 102, 61, 189, 1, 20, 2, 94, 68, 72, 178, 83, 113, 30, 120, 234, 96]), (bytes [69, 95, 44, 2, 235, 12, 178, 37, 126, 183, 181, 181, 34, 31, 118, 138, 88, 126, 88, 160, 125, 206, 247, 182, 110, 182, 45, 127, 119, 49, 254, 66]), (bytes [98, 233, 75, 159, 154, 202, 229, 197, 204, 114, 61, 90, 121, 211, 59, 64, 176, 54, 189, 127, 231, 130, 146, 184, 171, 30, 12, 52, 230, 151, 238, 234]), (bytes [85, 138, 40, 17, 194, 246, 165, 186, 54, 48, 183, 234, 232, 158, 92, 162, 223, 181, 255, 178, 195, 61, 236, 20, 16, 246, 177, 195, 118, 179, 254, 250]), (bytes [239, 10, 197, 2, 15, 35, 45, 100, 252, 20, 168, 193, 214, 233, 118, 179, 26, 248, 115, 153, 62, 42, 18, 72, 92, 106, 228, 90, 223, 90, 43, 14]), (bytes [193, 59, 68, 39, 80, 165, 100, 185, 20, 170, 20, 170, 19, 36, 29, 31, 55, 205, 233, 106, 36, 227, 142, 2, 63, 219, 79, 27, 21, 248, 36, 25]), (bytes [52, 1, 149, 46, 119, 9, 176, 204, 186, 190, 87, 167, 210, 115, 219, 0, 114, 162, 51, 255, 85, 195, 255, 197, 145, 74, 70, 24, 80, 13, 229, 52]), (bytes [113, 35, 60, 216, 127, 5, 20, 16, 38, 10, 254, 113, 13, 6, 112, 72, 47, 146, 253, 123, 255, 67, 40, 28, 150, 201, 176, 250, 103, 139, 16, 73]), (bytes [63, 217, 215, 39, 159, 216, 214, 211, 74, 192, 206, 214, 51, 249, 89, 113, 249, 83, 19, 201, 137, 72, 173, 246, 67, 188, 116, 70, 76, 81, 191, 96])], familyDigest := (bytes [57, 96, 173, 107, 74, 96, 6, 184, 93, 44, 158, 222, 17, 105, 235, 100, 93, 195, 146, 163, 228, 224, 253, 134, 235, 58, 173, 222, 168, 61, 29, 210]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [57, 96, 173, 107, 74, 96, 6, 184, 93, 44, 158, 222, 17, 105, 235, 100, 93, 195, 146, 163, 228, 224, 253, 134, 235, 58, 173, 222, 168, 61, 29, 210]), layoutVersion := 1, digest := (bytes [218, 252, 26, 46, 28, 218, 125, 203, 192, 156, 76, 141, 163, 163, 128, 206, 131, 248, 235, 86, 73, 170, 207, 167, 89, 133, 185, 83, 239, 57, 137, 201]) }, logicalIndex := 0, digest := (bytes [54, 28, 19, 75, 137, 45, 177, 143, 245, 153, 104, 45, 35, 166, 251, 47, 50, 28, 106, 102, 36, 231, 93, 5, 72, 37, 42, 247, 137, 226, 27, 82]) }, valueDigest := (bytes [48, 9, 158, 59, 120, 45, 200, 155, 8, 144, 252, 183, 179, 168, 71, 138, 10, 136, 117, 72, 217, 133, 28, 26, 240, 134, 159, 61, 227, 8, 46, 227]), digest := (bytes [49, 66, 52, 214, 209, 84, 198, 152, 216, 68, 219, 110, 141, 188, 227, 107, 57, 26, 107, 138, 67, 120, 37, 90, 52, 170, 211, 173, 128, 92, 10, 61]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [57, 96, 173, 107, 74, 96, 6, 184, 93, 44, 158, 222, 17, 105, 235, 100, 93, 195, 146, 163, 228, 224, 253, 134, 235, 58, 173, 222, 168, 61, 29, 210]), layoutVersion := 1, digest := (bytes [218, 252, 26, 46, 28, 218, 125, 203, 192, 156, 76, 141, 163, 163, 128, 206, 131, 248, 235, 86, 73, 170, 207, 167, 89, 133, 185, 83, 239, 57, 137, 201]) }, logicalIndex := 9, digest := (bytes [64, 210, 212, 127, 248, 49, 117, 4, 151, 121, 75, 236, 120, 11, 169, 68, 49, 158, 135, 180, 211, 60, 107, 250, 129, 157, 15, 164, 44, 198, 127, 75]) }, valueDigest := (bytes [182, 134, 141, 237, 80, 100, 222, 51, 79, 143, 246, 177, 31, 61, 129, 193, 216, 133, 80, 85, 220, 234, 180, 38, 196, 214, 36, 167, 155, 158, 39, 109]), digest := (bytes [24, 14, 108, 218, 1, 247, 142, 252, 41, 224, 234, 209, 96, 212, 186, 131, 15, 64, 204, 6, 123, 205, 222, 241, 128, 57, 92, 135, 153, 60, 46, 19]) }), digest := (bytes [207, 213, 92, 60, 135, 89, 29, 218, 252, 37, 75, 51, 101, 210, 109, 73, 181, 35, 225, 52, 76, 234, 32, 4, 119, 115, 236, 87, 27, 19, 132, 170]) }
  , rootLaneCommitment := { timeLen := 10, commitments := { commitmentCount := 38, digest := (bytes [143, 94, 45, 143, 60, 22, 127, 181, 118, 245, 141, 105, 103, 91, 39, 116, 24, 229, 56, 25, 163, 187, 169, 225, 28, 41, 160, 93, 78, 222, 50, 187]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [143, 94, 45, 143, 60, 22, 127, 181, 118, 245, 141, 105, 103, 91, 39, 116, 24, 229, 56, 25, 163, 187, 169, 225, 28, 41, 160, 93, 78, 222, 50, 187]), layoutVersion := 3, digest := (bytes [32, 193, 20, 22, 26, 33, 51, 29, 241, 32, 118, 86, 8, 63, 194, 117, 170, 88, 106, 109, 35, 170, 4, 215, 35, 68, 106, 209, 247, 58, 81, 169]) }, logicalIndex := 0, digest := (bytes [158, 3, 251, 138, 251, 63, 112, 48, 112, 160, 14, 162, 124, 125, 104, 34, 131, 115, 51, 105, 65, 219, 250, 250, 11, 105, 178, 218, 121, 174, 58, 157]) }, valueDigest := (bytes [48, 9, 158, 59, 120, 45, 200, 155, 8, 144, 252, 183, 179, 168, 71, 138, 10, 136, 117, 72, 217, 133, 28, 26, 240, 134, 159, 61, 227, 8, 46, 227]), digest := (bytes [48, 177, 97, 252, 216, 198, 105, 222, 211, 46, 152, 50, 44, 9, 162, 23, 99, 209, 115, 184, 218, 49, 215, 43, 135, 145, 165, 158, 218, 63, 195, 229]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [143, 94, 45, 143, 60, 22, 127, 181, 118, 245, 141, 105, 103, 91, 39, 116, 24, 229, 56, 25, 163, 187, 169, 225, 28, 41, 160, 93, 78, 222, 50, 187]), layoutVersion := 3, digest := (bytes [32, 193, 20, 22, 26, 33, 51, 29, 241, 32, 118, 86, 8, 63, 194, 117, 170, 88, 106, 109, 35, 170, 4, 215, 35, 68, 106, 209, 247, 58, 81, 169]) }, logicalIndex := 9, digest := (bytes [137, 228, 202, 166, 22, 0, 88, 191, 67, 185, 149, 186, 113, 101, 68, 140, 239, 206, 226, 56, 101, 127, 28, 142, 224, 235, 111, 50, 181, 189, 101, 120]) }, valueDigest := (bytes [182, 134, 141, 237, 80, 100, 222, 51, 79, 143, 246, 177, 31, 61, 129, 193, 216, 133, 80, 85, 220, 234, 180, 38, 196, 214, 36, 167, 155, 158, 39, 109]), digest := (bytes [246, 34, 237, 85, 223, 76, 6, 194, 59, 192, 53, 65, 70, 12, 99, 47, 162, 216, 151, 42, 164, 30, 70, 182, 113, 250, 68, 5, 148, 143, 255, 90]) }), digest := (bytes [87, 228, 169, 87, 152, 129, 159, 14, 17, 95, 214, 28, 120, 218, 198, 65, 5, 33, 11, 236, 65, 79, 9, 75, 119, 32, 140, 184, 182, 172, 87, 232]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [207, 213, 92, 60, 135, 89, 29, 218, 252, 37, 75, 51, 101, 210, 109, 73, 181, 35, 225, 52, 76, 234, 32, 4, 119, 115, 236, 87, 27, 19, 132, 170]), rootLaneCommitmentDigest := (bytes [87, 228, 169, 87, 152, 129, 159, 14, 17, 95, 214, 28, 120, 218, 198, 65, 5, 33, 11, 236, 65, 79, 9, 75, 119, 32, 140, 184, 182, 172, 87, 232]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 10, digest := (bytes [169, 94, 117, 101, 121, 120, 176, 58, 203, 155, 197, 125, 115, 194, 63, 243, 218, 69, 12, 117, 147, 44, 140, 64, 30, 239, 27, 111, 38, 180, 108, 209]) }, statementDigest := (bytes [211, 37, 78, 168, 125, 1, 230, 222, 67, 193, 107, 233, 216, 151, 67, 160, 95, 53, 246, 57, 63, 44, 102, 132, 52, 59, 115, 227, 44, 151, 141, 225]), proofDigest := (bytes [99, 203, 182, 204, 176, 144, 142, 254, 222, 67, 35, 92, 140, 51, 147, 19, 15, 53, 180, 206, 193, 33, 228, 210, 1, 71, 182, 69, 136, 252, 24, 56]), digest := (bytes [177, 89, 1, 47, 45, 239, 78, 141, 192, 8, 252, 192, 54, 37, 103, 6, 143, 111, 149, 1, 131, 172, 26, 214, 136, 143, 221, 158, 143, 242, 16, 83]) }
  , digest := (bytes [32, 254, 59, 204, 184, 252, 90, 91, 215, 132, 126, 130, 125, 188, 6, 144, 135, 66, 237, 30, 83, 240, 242, 88, 214, 84, 49, 48, 148, 230, 98, 14])
}
    , exportedProof := {
  claim := {
  accepted := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , statement := { proofStatementDigest := (bytes [253, 162, 194, 206, 158, 102, 159, 167, 114, 209, 156, 68, 161, 183, 177, 160, 15, 56, 222, 141, 8, 50, 216, 50, 210, 29, 197, 114, 87, 88, 56, 165]), kernelOpeningDigest := (bytes [186, 38, 161, 225, 204, 168, 253, 188, 96, 231, 230, 92, 153, 18, 36, 164, 241, 82, 9, 4, 151, 96, 212, 85, 114, 235, 209, 49, 240, 134, 110, 101]), digest := (bytes [148, 123, 232, 210, 230, 205, 73, 87, 120, 242, 32, 152, 178, 233, 58, 73, 16, 231, 240, 93, 235, 156, 229, 97, 163, 61, 86, 117, 81, 193, 10, 201]) }
  , mainLane := { mainLaneBundleDigest := (bytes [177, 89, 1, 47, 45, 239, 78, 141, 192, 8, 252, 192, 54, 37, 103, 6, 143, 111, 149, 1, 131, 172, 26, 214, 136, 143, 221, 158, 143, 242, 16, 83]), digest := (bytes [140, 197, 187, 64, 174, 42, 186, 222, 36, 194, 231, 204, 253, 186, 52, 228, 152, 231, 33, 147, 36, 166, 29, 69, 19, 130, 28, 135, 88, 167, 185, 158]) }
  , terminal := { finalStateDigest := (bytes [103, 223, 139, 208, 116, 154, 142, 132, 78, 184, 137, 1, 105, 240, 117, 173, 130, 69, 168, 181, 198, 4, 200, 40, 154, 26, 30, 84, 163, 49, 80, 141]), finalPc := 40, halted := true, digest := (bytes [244, 231, 52, 6, 159, 1, 154, 26, 57, 221, 79, 252, 201, 139, 50, 239, 65, 248, 34, 105, 22, 254, 192, 216, 218, 123, 81, 98, 93, 44, 17, 174]) }
  , digest := (bytes [240, 244, 174, 35, 252, 123, 15, 128, 61, 44, 39, 0, 182, 25, 247, 200, 180, 242, 164, 50, 64, 61, 174, 140, 105, 128, 247, 136, 23, 33, 141, 168])
}
  , mainLane := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { mainLaneBundleDigest := (bytes [177, 89, 1, 47, 45, 239, 78, 141, 192, 8, 252, 192, 54, 37, 103, 6, 143, 111, 149, 1, 131, 172, 26, 214, 136, 143, 221, 158, 143, 242, 16, 83]), digest := (bytes [200, 171, 177, 0, 199, 79, 140, 176, 24, 220, 29, 245, 65, 47, 148, 115, 227, 33, 37, 166, 141, 199, 176, 131, 144, 159, 204, 199, 141, 141, 251, 74]) }, digest := (bytes [200, 228, 74, 0, 87, 214, 175, 151, 170, 246, 29, 242, 76, 153, 145, 200, 193, 171, 204, 84, 236, 150, 17, 121, 243, 108, 154, 85, 213, 209, 132, 210]) }
  , opening := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , stages := { stageClaimsDigest := (bytes [157, 217, 182, 50, 102, 253, 73, 90, 236, 226, 136, 241, 15, 164, 204, 21, 241, 250, 31, 176, 23, 65, 64, 84, 28, 75, 159, 11, 136, 45, 9, 201]), stagePackagesDigest := (bytes [52, 150, 130, 38, 165, 150, 120, 60, 9, 255, 119, 17, 136, 162, 5, 129, 56, 141, 234, 26, 228, 172, 50, 243, 205, 148, 140, 78, 183, 140, 115, 201]), kernelOpeningDigest := (bytes [186, 38, 161, 225, 204, 168, 253, 188, 96, 231, 230, 92, 153, 18, 36, 164, 241, 82, 9, 4, 151, 96, 212, 85, 114, 235, 209, 49, 240, 134, 110, 101]), digest := (bytes [75, 168, 46, 15, 204, 96, 255, 173, 157, 128, 16, 227, 166, 84, 146, 242, 209, 72, 179, 102, 171, 192, 83, 72, 179, 21, 196, 197, 89, 19, 109, 218]) }
  , terminal := { preparedStepBindingsDigest := (bytes [30, 164, 150, 41, 218, 111, 229, 43, 231, 221, 197, 31, 58, 29, 115, 85, 208, 133, 131, 125, 250, 253, 29, 48, 239, 226, 164, 136, 42, 31, 76, 180]), executionDigest := (bytes [125, 109, 107, 30, 214, 28, 21, 190, 193, 73, 13, 134, 113, 2, 233, 252, 206, 60, 180, 47, 71, 229, 88, 95, 116, 143, 172, 12, 59, 79, 234, 150]), transcriptFinalDigest := (bytes [40, 198, 217, 185, 8, 16, 125, 44, 61, 253, 171, 30, 100, 237, 238, 86, 30, 22, 230, 155, 239, 54, 28, 87, 238, 68, 77, 116, 87, 196, 144, 189]), digest := (bytes [148, 116, 14, 112, 99, 154, 106, 183, 169, 147, 134, 185, 166, 25, 206, 99, 141, 182, 251, 156, 151, 56, 208, 204, 18, 10, 64, 151, 173, 38, 200, 38]) }
  , digest := (bytes [96, 5, 17, 15, 45, 235, 122, 220, 147, 117, 31, 240, 237, 64, 196, 233, 104, 157, 12, 220, 141, 224, 132, 145, 146, 133, 64, 188, 197, 248, 9, 41])
}
  , jointOpening := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { proofStatementDigest := (bytes [253, 162, 194, 206, 158, 102, 159, 167, 114, 209, 156, 68, 161, 183, 177, 160, 15, 56, 222, 141, 8, 50, 216, 50, 210, 29, 197, 114, 87, 88, 56, 165]), mainLaneClaimDigest := (bytes [200, 228, 74, 0, 87, 214, 175, 151, 170, 246, 29, 242, 76, 153, 145, 200, 193, 171, 204, 84, 236, 150, 17, 121, 243, 108, 154, 85, 213, 209, 132, 210]), kernelOpeningClaimDigest := (bytes [96, 5, 17, 15, 45, 235, 122, 220, 147, 117, 31, 240, 237, 64, 196, 233, 104, 157, 12, 220, 141, 224, 132, 145, 146, 133, 64, 188, 197, 248, 9, 41]), digest := (bytes [188, 186, 150, 72, 221, 140, 3, 95, 205, 106, 129, 38, 197, 193, 119, 165, 109, 172, 67, 172, 195, 152, 205, 41, 132, 183, 147, 169, 31, 78, 195, 88]) }, digest := (bytes [195, 160, 106, 171, 123, 242, 196, 82, 27, 218, 187, 164, 97, 177, 230, 138, 192, 1, 29, 253, 239, 228, 19, 223, 3, 81, 6, 23, 164, 246, 197, 201]) }
  , root0 := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), stages := { stage1Digest := (bytes [134, 144, 193, 223, 148, 183, 65, 251, 150, 253, 209, 238, 38, 219, 86, 43, 84, 158, 62, 219, 12, 185, 17, 172, 250, 121, 161, 155, 34, 218, 192, 23]), stage2Digest := (bytes [157, 229, 195, 131, 139, 8, 105, 108, 185, 165, 44, 241, 226, 186, 221, 169, 117, 119, 57, 226, 94, 130, 90, 239, 124, 28, 101, 251, 70, 102, 122, 148]), stage3Digest := (bytes [234, 177, 23, 67, 38, 251, 33, 157, 164, 66, 116, 34, 106, 3, 185, 174, 39, 193, 22, 250, 158, 150, 184, 2, 134, 157, 45, 214, 185, 100, 216, 30]), digest := (bytes [0, 83, 102, 19, 18, 64, 105, 253, 199, 72, 227, 135, 177, 136, 149, 219, 178, 112, 127, 116, 42, 61, 47, 225, 173, 124, 252, 236, 166, 29, 9, 70]) }, terminal := { root0Digest := (bytes [100, 141, 133, 191, 65, 9, 202, 67, 178, 73, 161, 90, 192, 177, 16, 176, 7, 146, 125, 14, 199, 63, 180, 56, 245, 33, 2, 6, 126, 240, 189, 23]), executionDigest := (bytes [125, 109, 107, 30, 214, 28, 21, 190, 193, 73, 13, 134, 113, 2, 233, 252, 206, 60, 180, 47, 71, 229, 88, 95, 116, 143, 172, 12, 59, 79, 234, 150]), finalStateDigest := (bytes [103, 223, 139, 208, 116, 154, 142, 132, 78, 184, 137, 1, 105, 240, 117, 173, 130, 69, 168, 181, 198, 4, 200, 40, 154, 26, 30, 84, 163, 49, 80, 141]), transcriptFinalDigest := (bytes [40, 198, 217, 185, 8, 16, 125, 44, 61, 253, 171, 30, 100, 237, 238, 86, 30, 22, 230, 155, 239, 54, 28, 87, 238, 68, 77, 116, 87, 196, 144, 189]), digest := (bytes [171, 47, 214, 199, 71, 186, 220, 107, 78, 115, 68, 89, 104, 94, 62, 122, 154, 71, 211, 99, 253, 86, 158, 186, 220, 7, 8, 87, 138, 83, 75, 230]) }, digest := (bytes [175, 152, 176, 130, 159, 1, 145, 73, 178, 107, 224, 198, 103, 82, 194, 186, 138, 1, 219, 151, 82, 68, 149, 184, 233, 60, 188, 171, 49, 44, 51, 35]) }
  , digest := (bytes [57, 246, 203, 150, 14, 82, 66, 8, 198, 221, 44, 75, 65, 70, 139, 159, 201, 241, 229, 135, 228, 161, 141, 130, 28, 16, 50, 161, 154, 185, 182, 202])
}
  , statement := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , foldSchedule := Nightstream.FoldSchedule.wholeTrace
  , chunkCount := 1
  , stageClaimsDigest := (bytes [157, 217, 182, 50, 102, 253, 73, 90, 236, 226, 136, 241, 15, 164, 204, 21, 241, 250, 31, 176, 23, 65, 64, 84, 28, 75, 159, 11, 136, 45, 9, 201])
  , stagePackagesDigest := (bytes [52, 150, 130, 38, 165, 150, 120, 60, 9, 255, 119, 17, 136, 162, 5, 129, 56, 141, 234, 26, 228, 172, 50, 243, 205, 148, 140, 78, 183, 140, 115, 201])
  , kernelOpeningDigest := (bytes [186, 38, 161, 225, 204, 168, 253, 188, 96, 231, 230, 92, 153, 18, 36, 164, 241, 82, 9, 4, 151, 96, 212, 85, 114, 235, 209, 49, 240, 134, 110, 101])
  , preparedStepBindingsDigest := (bytes [30, 164, 150, 41, 218, 111, 229, 43, 231, 221, 197, 31, 58, 29, 115, 85, 208, 133, 131, 125, 250, 253, 29, 48, 239, 226, 164, 136, 42, 31, 76, 180])
  , executionDigest := (bytes [125, 109, 107, 30, 214, 28, 21, 190, 193, 73, 13, 134, 113, 2, 233, 252, 206, 60, 180, 47, 71, 229, 88, 95, 116, 143, 172, 12, 59, 79, 234, 150])
  , finalStateDigest := (bytes [103, 223, 139, 208, 116, 154, 142, 132, 78, 184, 137, 1, 105, 240, 117, 173, 130, 69, 168, 181, 198, 4, 200, 40, 154, 26, 30, 84, 163, 49, 80, 141])
  , transcriptFinalDigest := (bytes [40, 198, 217, 185, 8, 16, 125, 44, 61, 253, 171, 30, 100, 237, 238, 86, 30, 22, 230, 155, 239, 54, 28, 87, 238, 68, 77, 116, 87, 196, 144, 189])
  , mainLaneSurfaceDigest := (bytes [158, 244, 230, 166, 7, 26, 200, 97, 238, 117, 50, 31, 153, 101, 36, 103, 89, 93, 107, 138, 156, 171, 136, 228, 128, 236, 67, 8, 168, 71, 82, 121])
  , rootLaneColumnsDigest := (bytes [207, 213, 92, 60, 135, 89, 29, 218, 252, 37, 75, 51, 101, 210, 109, 73, 181, 35, 225, 52, 76, 234, 32, 4, 119, 115, 236, 87, 27, 19, 132, 170])
  , publicStepCount := 10
  , initialPc := 0
  , finalPc := 40
  , halted := true
  , digest := (bytes [253, 162, 194, 206, 158, 102, 159, 167, 114, 209, 156, 68, 161, 183, 177, 160, 15, 56, 222, 141, 8, 50, 216, 50, 210, 29, 197, 114, 87, 88, 56, 165])
}
  , kernel := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "native_shift_chain_ecall", fixtureId := "native_shift_chain_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , executionDigest := (bytes [125, 109, 107, 30, 214, 28, 21, 190, 193, 73, 13, 134, 113, 2, 233, 252, 206, 60, 180, 47, 71, 229, 88, 95, 116, 143, 172, 12, 59, 79, 234, 150])
  , shape := { executionRowCount := 10, realRowCount := 10, effectRowCount := 10, commitRowCount := 10, digest := (bytes [112, 139, 125, 186, 65, 232, 254, 194, 0, 75, 41, 115, 118, 66, 196, 105, 51, 14, 26, 159, 116, 35, 103, 9, 240, 124, 96, 130, 114, 5, 66, 126]) }
  , digest := (bytes [88, 119, 98, 13, 111, 130, 86, 174, 128, 138, 42, 115, 149, 129, 170, 120, 133, 40, 140, 114, 109, 125, 63, 210, 101, 48, 53, 168, 174, 117, 116, 179])
}
  , stages := { summary := { stage1RowCount := 10, stage2RegisterReadCount := 12, stage2RegisterWriteCount := 9, stage2RamEventCount := 0, stage2TwistLinkCount := 10, stage3ContinuityCount := 10, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [182, 88, 119, 178, 173, 139, 2, 120, 38, 241, 130, 157, 51, 75, 125, 230, 46, 252, 195, 62, 2, 4, 209, 233, 243, 210, 102, 203, 155, 170, 137, 196]) }, digest := (bytes [165, 169, 132, 131, 219, 58, 190, 147, 230, 10, 193, 16, 55, 193, 168, 83, 13, 115, 211, 67, 151, 50, 203, 71, 52, 226, 54, 108, 249, 109, 12, 194]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [63, 174, 85, 23, 132, 59, 164, 91, 219, 152, 118, 75, 81, 162, 203, 103, 38, 248, 208, 230, 243, 2, 237, 20, 96, 223, 24, 199, 67, 231, 4, 104]), stage1Digest := (bytes [102, 83, 120, 230, 208, 62, 162, 142, 24, 32, 119, 9, 11, 24, 97, 204, 106, 60, 128, 52, 172, 61, 9, 199, 179, 68, 37, 136, 147, 34, 125, 249]), stage2Digest := (bytes [222, 241, 73, 158, 149, 26, 237, 199, 105, 195, 107, 195, 113, 106, 151, 33, 10, 191, 23, 71, 7, 123, 23, 92, 172, 171, 255, 252, 26, 144, 255, 12]), stage3Digest := (bytes [82, 5, 191, 228, 29, 143, 146, 70, 210, 162, 133, 104, 132, 207, 23, 6, 167, 217, 152, 44, 223, 222, 180, 240, 61, 220, 69, 241, 83, 34, 91, 99]), transcriptDigest := (bytes [40, 198, 217, 185, 8, 16, 125, 44, 61, 253, 171, 30, 100, 237, 238, 86, 30, 22, 230, 155, 239, 54, 28, 87, 238, 68, 77, 116, 87, 196, 144, 189]), executionDigest := (bytes [125, 109, 107, 30, 214, 28, 21, 190, 193, 73, 13, 134, 113, 2, 233, 252, 206, 60, 180, 47, 71, 229, 88, 95, 116, 143, 172, 12, 59, 79, 234, 150]), digest := (bytes [119, 119, 96, 244, 71, 146, 91, 58, 24, 68, 255, 24, 93, 173, 78, 140, 21, 31, 194, 166, 124, 163, 86, 49, 24, 209, 46, 222, 37, 6, 187, 191]) }, statementDigest := (bytes [126, 146, 37, 155, 39, 220, 180, 4, 242, 78, 225, 66, 250, 95, 176, 124, 237, 49, 145, 231, 136, 82, 170, 203, 92, 38, 148, 28, 66, 16, 176, 179]), proofDigest := (bytes [222, 162, 167, 196, 223, 72, 3, 60, 61, 16, 115, 109, 128, 252, 138, 110, 186, 29, 232, 71, 30, 215, 84, 147, 242, 139, 51, 160, 22, 69, 97, 245]), digest := (bytes [157, 217, 182, 50, 102, 253, 73, 90, 236, 226, 136, 241, 15, 164, 204, 21, 241, 250, 31, 176, 23, 65, 64, 84, 28, 75, 159, 11, 136, 45, 9, 201]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [113, 110, 176, 95, 213, 2, 56, 45, 40, 202, 182, 238, 248, 121, 61, 153, 97, 17, 173, 150, 8, 23, 251, 135, 103, 190, 218, 12, 139, 247, 226, 169]), stage1Digest := (bytes [43, 186, 189, 15, 117, 33, 34, 68, 18, 3, 84, 129, 2, 91, 173, 225, 193, 37, 15, 208, 50, 249, 112, 52, 130, 65, 94, 111, 22, 73, 76, 78]), stage2Digest := (bytes [253, 241, 232, 168, 55, 211, 246, 203, 25, 241, 20, 54, 184, 114, 92, 233, 233, 199, 77, 26, 70, 65, 25, 201, 15, 55, 146, 156, 222, 134, 247, 183]), stage3Digest := (bytes [123, 200, 171, 142, 73, 227, 53, 197, 73, 245, 79, 164, 187, 42, 144, 179, 84, 250, 64, 72, 82, 210, 170, 82, 241, 181, 251, 189, 13, 255, 120, 86]), digest := (bytes [133, 21, 66, 136, 48, 137, 198, 59, 148, 231, 171, 98, 105, 70, 132, 93, 153, 70, 79, 47, 95, 196, 59, 124, 6, 157, 193, 132, 228, 80, 114, 230]) }, digest := (bytes [52, 150, 130, 38, 165, 150, 120, 60, 9, 255, 119, 17, 136, 162, 5, 129, 56, 141, 234, 26, 228, 172, 50, 243, 205, 148, 140, 78, 183, 140, 115, 201]) }
  , kernelOpening := { openingDigest := (bytes [119, 115, 69, 96, 249, 81, 149, 206, 220, 151, 99, 202, 67, 69, 201, 92, 94, 159, 3, 77, 69, 192, 47, 246, 24, 74, 248, 141, 142, 191, 2, 138]), bindings := { claimDigest := (bytes [237, 233, 103, 61, 197, 60, 93, 141, 147, 156, 156, 127, 58, 72, 103, 44, 100, 145, 190, 255, 134, 121, 188, 169, 23, 16, 186, 120, 221, 196, 248, 22]), bindingsDigest := (bytes [105, 17, 253, 140, 161, 226, 141, 222, 139, 157, 43, 163, 42, 73, 21, 118, 4, 18, 117, 190, 221, 83, 239, 144, 47, 3, 84, 174, 101, 96, 127, 107]), preparedStepsDigest := (bytes [81, 219, 54, 55, 186, 72, 121, 178, 0, 65, 66, 150, 185, 245, 31, 236, 170, 91, 0, 247, 142, 217, 220, 215, 17, 135, 253, 254, 66, 63, 153, 211]), digest := (bytes [150, 94, 158, 112, 210, 229, 71, 125, 37, 46, 29, 188, 68, 12, 154, 71, 104, 118, 105, 175, 201, 75, 93, 53, 192, 95, 59, 55, 235, 106, 233, 0]) }, digest := (bytes [186, 38, 161, 225, 204, 168, 253, 188, 96, 231, 230, 92, 153, 18, 36, 164, 241, 82, 9, 4, 151, 96, 212, 85, 114, 235, 209, 49, 240, 134, 110, 101]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [30, 164, 150, 41, 218, 111, 229, 43, 231, 221, 197, 31, 58, 29, 115, 85, 208, 133, 131, 125, 250, 253, 29, 48, 239, 226, 164, 136, 42, 31, 76, 180]), terminal := { root0Digest := (bytes [100, 141, 133, 191, 65, 9, 202, 67, 178, 73, 161, 90, 192, 177, 16, 176, 7, 146, 125, 14, 199, 63, 180, 56, 245, 33, 2, 6, 126, 240, 189, 23]), executionDigest := (bytes [125, 109, 107, 30, 214, 28, 21, 190, 193, 73, 13, 134, 113, 2, 233, 252, 206, 60, 180, 47, 71, 229, 88, 95, 116, 143, 172, 12, 59, 79, 234, 150]), finalStateDigest := (bytes [103, 223, 139, 208, 116, 154, 142, 132, 78, 184, 137, 1, 105, 240, 117, 173, 130, 69, 168, 181, 198, 4, 200, 40, 154, 26, 30, 84, 163, 49, 80, 141]), transcriptFinalDigest := (bytes [40, 198, 217, 185, 8, 16, 125, 44, 61, 253, 171, 30, 100, 237, 238, 86, 30, 22, 230, 155, 239, 54, 28, 87, 238, 68, 77, 116, 87, 196, 144, 189]), finalPc := 40, halted := true, digest := (bytes [144, 111, 188, 226, 66, 170, 58, 159, 68, 203, 38, 149, 106, 226, 154, 125, 200, 223, 159, 59, 47, 55, 193, 41, 253, 116, 109, 155, 245, 29, 95, 125]) }, digest := (bytes [142, 36, 38, 156, 150, 255, 148, 120, 152, 162, 171, 102, 136, 163, 255, 130, 69, 240, 176, 63, 222, 134, 222, 107, 42, 199, 112, 201, 191, 32, 249, 214]) }, statementDigest := (bytes [236, 221, 46, 4, 110, 86, 195, 216, 120, 3, 130, 111, 87, 29, 63, 57, 107, 2, 247, 98, 191, 146, 95, 48, 62, 151, 183, 255, 39, 157, 73, 119]), proofDigest := (bytes [122, 78, 120, 200, 161, 108, 181, 126, 26, 14, 240, 3, 67, 156, 181, 117, 40, 145, 19, 78, 22, 40, 243, 33, 241, 9, 216, 89, 158, 63, 50, 190]), digest := (bytes [242, 42, 150, 57, 63, 86, 128, 252, 140, 109, 108, 250, 72, 222, 150, 43, 79, 38, 0, 73, 171, 248, 214, 3, 53, 71, 222, 85, 180, 82, 15, 117]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [57, 96, 173, 107, 74, 96, 6, 184, 93, 44, 158, 222, 17, 105, 235, 100, 93, 195, 146, 163, 228, 224, 253, 134, 235, 58, 173, 222, 168, 61, 29, 210]), layoutVersion := 1, digest := (bytes [218, 252, 26, 46, 28, 218, 125, 203, 192, 156, 76, 141, 163, 163, 128, 206, 131, 248, 235, 86, 73, 170, 207, 167, 89, 133, 185, 83, 239, 57, 137, 201]) }, rowWidth := 38, timeLen := 10, columnDigests := [(bytes [12, 228, 244, 232, 232, 195, 81, 12, 214, 193, 42, 183, 200, 29, 152, 94, 136, 29, 6, 38, 78, 210, 160, 183, 216, 225, 73, 147, 50, 136, 142, 214]), (bytes [240, 182, 76, 250, 35, 170, 242, 238, 13, 3, 36, 197, 217, 34, 88, 179, 25, 179, 252, 9, 53, 253, 106, 155, 210, 71, 3, 170, 179, 214, 158, 65]), (bytes [195, 188, 63, 10, 98, 211, 186, 126, 183, 152, 82, 190, 233, 91, 13, 44, 234, 86, 153, 242, 47, 0, 90, 173, 178, 126, 238, 39, 206, 42, 90, 234]), (bytes [8, 42, 43, 132, 150, 119, 43, 88, 120, 73, 248, 4, 160, 61, 234, 157, 237, 5, 30, 176, 13, 32, 132, 34, 140, 232, 248, 156, 189, 150, 158, 132]), (bytes [183, 153, 10, 248, 62, 168, 118, 167, 230, 138, 239, 173, 144, 140, 163, 208, 253, 182, 92, 210, 65, 128, 123, 109, 59, 243, 8, 21, 192, 111, 223, 235]), (bytes [96, 49, 53, 146, 252, 231, 2, 133, 7, 150, 231, 243, 19, 147, 34, 3, 19, 95, 125, 142, 225, 119, 94, 30, 41, 92, 213, 40, 58, 73, 204, 178]), (bytes [6, 202, 216, 137, 252, 35, 77, 13, 181, 151, 136, 136, 116, 231, 11, 46, 57, 52, 185, 82, 154, 67, 81, 140, 148, 104, 11, 88, 174, 229, 167, 189]), (bytes [48, 51, 138, 201, 111, 86, 152, 134, 106, 27, 115, 24, 34, 241, 131, 144, 253, 88, 175, 132, 8, 28, 83, 227, 186, 166, 5, 153, 14, 152, 167, 155]), (bytes [38, 189, 190, 109, 40, 90, 176, 164, 205, 6, 244, 99, 155, 110, 177, 188, 15, 110, 175, 155, 25, 30, 14, 180, 42, 110, 165, 250, 171, 206, 182, 252]), (bytes [237, 165, 119, 146, 86, 53, 241, 200, 114, 247, 22, 68, 204, 180, 71, 182, 30, 146, 193, 238, 245, 34, 150, 29, 228, 223, 212, 88, 34, 209, 138, 59]), (bytes [100, 157, 167, 161, 144, 13, 101, 250, 75, 66, 176, 27, 234, 116, 230, 94, 68, 12, 251, 12, 193, 57, 231, 191, 86, 6, 57, 71, 28, 61, 41, 243]), (bytes [55, 104, 163, 114, 203, 113, 243, 96, 246, 239, 169, 197, 247, 25, 87, 83, 254, 89, 219, 112, 50, 58, 113, 40, 39, 11, 128, 37, 130, 105, 141, 223]), (bytes [75, 32, 207, 134, 219, 18, 161, 48, 94, 95, 165, 227, 110, 209, 210, 37, 12, 218, 2, 100, 69, 87, 80, 84, 199, 63, 213, 142, 156, 83, 58, 207]), (bytes [67, 239, 94, 227, 76, 210, 86, 117, 147, 191, 52, 217, 52, 78, 157, 14, 95, 144, 135, 97, 188, 115, 47, 236, 121, 233, 209, 179, 61, 184, 178, 88]), (bytes [72, 188, 177, 89, 243, 172, 72, 201, 140, 24, 218, 201, 12, 85, 51, 235, 118, 224, 89, 207, 230, 208, 206, 156, 116, 113, 199, 219, 143, 79, 31, 182]), (bytes [70, 226, 162, 48, 249, 249, 238, 229, 208, 237, 173, 243, 12, 180, 219, 129, 178, 47, 57, 146, 39, 248, 168, 200, 27, 239, 97, 103, 235, 87, 98, 152]), (bytes [168, 135, 31, 110, 99, 170, 118, 153, 62, 23, 162, 146, 237, 131, 59, 107, 61, 171, 125, 141, 126, 72, 211, 252, 87, 247, 107, 97, 184, 97, 115, 62]), (bytes [195, 241, 122, 156, 175, 234, 131, 108, 215, 171, 109, 221, 145, 195, 177, 216, 224, 3, 71, 137, 168, 123, 92, 150, 220, 244, 199, 164, 30, 190, 118, 196]), (bytes [91, 173, 31, 113, 28, 0, 124, 210, 36, 221, 147, 10, 225, 65, 253, 252, 190, 167, 173, 20, 27, 91, 29, 243, 214, 72, 147, 137, 219, 101, 249, 19]), (bytes [59, 90, 50, 88, 131, 202, 40, 187, 147, 95, 62, 165, 211, 185, 201, 13, 248, 93, 124, 178, 255, 171, 133, 136, 142, 97, 27, 17, 233, 80, 74, 206]), (bytes [66, 136, 207, 236, 216, 66, 254, 209, 16, 181, 177, 57, 69, 165, 202, 200, 200, 139, 52, 180, 129, 129, 57, 57, 45, 36, 235, 80, 85, 41, 104, 97]), (bytes [250, 243, 36, 121, 222, 230, 87, 172, 149, 80, 32, 187, 23, 44, 161, 164, 116, 82, 156, 142, 181, 200, 8, 117, 73, 175, 232, 208, 178, 248, 111, 216]), (bytes [176, 39, 109, 185, 241, 9, 236, 176, 30, 215, 238, 28, 183, 191, 205, 114, 166, 252, 186, 41, 162, 90, 213, 56, 162, 0, 252, 238, 13, 68, 157, 75]), (bytes [191, 14, 23, 70, 191, 143, 164, 138, 31, 103, 126, 202, 195, 103, 102, 91, 13, 76, 74, 232, 113, 19, 110, 181, 239, 121, 83, 104, 130, 66, 20, 253]), (bytes [161, 175, 165, 91, 84, 150, 30, 59, 1, 249, 254, 100, 229, 185, 223, 86, 127, 89, 230, 146, 65, 69, 137, 203, 79, 105, 52, 90, 109, 2, 37, 33]), (bytes [233, 165, 191, 129, 157, 1, 246, 73, 33, 152, 81, 181, 88, 226, 255, 164, 136, 147, 176, 124, 163, 119, 171, 116, 230, 54, 36, 93, 201, 201, 12, 154]), (bytes [120, 241, 77, 148, 156, 149, 19, 10, 198, 193, 143, 175, 140, 145, 200, 37, 79, 90, 110, 93, 33, 50, 32, 17, 152, 164, 75, 183, 13, 110, 138, 180]), (bytes [180, 238, 180, 101, 177, 238, 139, 240, 30, 235, 37, 156, 160, 17, 158, 230, 150, 48, 150, 208, 185, 74, 30, 212, 220, 22, 112, 242, 233, 187, 105, 34]), (bytes [15, 1, 218, 124, 15, 223, 36, 143, 32, 158, 170, 206, 91, 155, 126, 37, 196, 143, 155, 198, 194, 142, 246, 15, 222, 133, 213, 79, 12, 118, 55, 86]), (bytes [234, 5, 33, 209, 57, 239, 56, 248, 2, 242, 172, 102, 200, 208, 75, 112, 102, 61, 189, 1, 20, 2, 94, 68, 72, 178, 83, 113, 30, 120, 234, 96]), (bytes [69, 95, 44, 2, 235, 12, 178, 37, 126, 183, 181, 181, 34, 31, 118, 138, 88, 126, 88, 160, 125, 206, 247, 182, 110, 182, 45, 127, 119, 49, 254, 66]), (bytes [98, 233, 75, 159, 154, 202, 229, 197, 204, 114, 61, 90, 121, 211, 59, 64, 176, 54, 189, 127, 231, 130, 146, 184, 171, 30, 12, 52, 230, 151, 238, 234]), (bytes [85, 138, 40, 17, 194, 246, 165, 186, 54, 48, 183, 234, 232, 158, 92, 162, 223, 181, 255, 178, 195, 61, 236, 20, 16, 246, 177, 195, 118, 179, 254, 250]), (bytes [239, 10, 197, 2, 15, 35, 45, 100, 252, 20, 168, 193, 214, 233, 118, 179, 26, 248, 115, 153, 62, 42, 18, 72, 92, 106, 228, 90, 223, 90, 43, 14]), (bytes [193, 59, 68, 39, 80, 165, 100, 185, 20, 170, 20, 170, 19, 36, 29, 31, 55, 205, 233, 106, 36, 227, 142, 2, 63, 219, 79, 27, 21, 248, 36, 25]), (bytes [52, 1, 149, 46, 119, 9, 176, 204, 186, 190, 87, 167, 210, 115, 219, 0, 114, 162, 51, 255, 85, 195, 255, 197, 145, 74, 70, 24, 80, 13, 229, 52]), (bytes [113, 35, 60, 216, 127, 5, 20, 16, 38, 10, 254, 113, 13, 6, 112, 72, 47, 146, 253, 123, 255, 67, 40, 28, 150, 201, 176, 250, 103, 139, 16, 73]), (bytes [63, 217, 215, 39, 159, 216, 214, 211, 74, 192, 206, 214, 51, 249, 89, 113, 249, 83, 19, 201, 137, 72, 173, 246, 67, 188, 116, 70, 76, 81, 191, 96])], familyDigest := (bytes [57, 96, 173, 107, 74, 96, 6, 184, 93, 44, 158, 222, 17, 105, 235, 100, 93, 195, 146, 163, 228, 224, 253, 134, 235, 58, 173, 222, 168, 61, 29, 210]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [57, 96, 173, 107, 74, 96, 6, 184, 93, 44, 158, 222, 17, 105, 235, 100, 93, 195, 146, 163, 228, 224, 253, 134, 235, 58, 173, 222, 168, 61, 29, 210]), layoutVersion := 1, digest := (bytes [218, 252, 26, 46, 28, 218, 125, 203, 192, 156, 76, 141, 163, 163, 128, 206, 131, 248, 235, 86, 73, 170, 207, 167, 89, 133, 185, 83, 239, 57, 137, 201]) }, logicalIndex := 0, digest := (bytes [54, 28, 19, 75, 137, 45, 177, 143, 245, 153, 104, 45, 35, 166, 251, 47, 50, 28, 106, 102, 36, 231, 93, 5, 72, 37, 42, 247, 137, 226, 27, 82]) }, valueDigest := (bytes [48, 9, 158, 59, 120, 45, 200, 155, 8, 144, 252, 183, 179, 168, 71, 138, 10, 136, 117, 72, 217, 133, 28, 26, 240, 134, 159, 61, 227, 8, 46, 227]), digest := (bytes [49, 66, 52, 214, 209, 84, 198, 152, 216, 68, 219, 110, 141, 188, 227, 107, 57, 26, 107, 138, 67, 120, 37, 90, 52, 170, 211, 173, 128, 92, 10, 61]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [57, 96, 173, 107, 74, 96, 6, 184, 93, 44, 158, 222, 17, 105, 235, 100, 93, 195, 146, 163, 228, 224, 253, 134, 235, 58, 173, 222, 168, 61, 29, 210]), layoutVersion := 1, digest := (bytes [218, 252, 26, 46, 28, 218, 125, 203, 192, 156, 76, 141, 163, 163, 128, 206, 131, 248, 235, 86, 73, 170, 207, 167, 89, 133, 185, 83, 239, 57, 137, 201]) }, logicalIndex := 9, digest := (bytes [64, 210, 212, 127, 248, 49, 117, 4, 151, 121, 75, 236, 120, 11, 169, 68, 49, 158, 135, 180, 211, 60, 107, 250, 129, 157, 15, 164, 44, 198, 127, 75]) }, valueDigest := (bytes [182, 134, 141, 237, 80, 100, 222, 51, 79, 143, 246, 177, 31, 61, 129, 193, 216, 133, 80, 85, 220, 234, 180, 38, 196, 214, 36, 167, 155, 158, 39, 109]), digest := (bytes [24, 14, 108, 218, 1, 247, 142, 252, 41, 224, 234, 209, 96, 212, 186, 131, 15, 64, 204, 6, 123, 205, 222, 241, 128, 57, 92, 135, 153, 60, 46, 19]) }), digest := (bytes [207, 213, 92, 60, 135, 89, 29, 218, 252, 37, 75, 51, 101, 210, 109, 73, 181, 35, 225, 52, 76, 234, 32, 4, 119, 115, 236, 87, 27, 19, 132, 170]) }
  , rootLaneCommitment := { timeLen := 10, commitments := { commitmentCount := 38, digest := (bytes [143, 94, 45, 143, 60, 22, 127, 181, 118, 245, 141, 105, 103, 91, 39, 116, 24, 229, 56, 25, 163, 187, 169, 225, 28, 41, 160, 93, 78, 222, 50, 187]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [143, 94, 45, 143, 60, 22, 127, 181, 118, 245, 141, 105, 103, 91, 39, 116, 24, 229, 56, 25, 163, 187, 169, 225, 28, 41, 160, 93, 78, 222, 50, 187]), layoutVersion := 3, digest := (bytes [32, 193, 20, 22, 26, 33, 51, 29, 241, 32, 118, 86, 8, 63, 194, 117, 170, 88, 106, 109, 35, 170, 4, 215, 35, 68, 106, 209, 247, 58, 81, 169]) }, logicalIndex := 0, digest := (bytes [158, 3, 251, 138, 251, 63, 112, 48, 112, 160, 14, 162, 124, 125, 104, 34, 131, 115, 51, 105, 65, 219, 250, 250, 11, 105, 178, 218, 121, 174, 58, 157]) }, valueDigest := (bytes [48, 9, 158, 59, 120, 45, 200, 155, 8, 144, 252, 183, 179, 168, 71, 138, 10, 136, 117, 72, 217, 133, 28, 26, 240, 134, 159, 61, 227, 8, 46, 227]), digest := (bytes [48, 177, 97, 252, 216, 198, 105, 222, 211, 46, 152, 50, 44, 9, 162, 23, 99, 209, 115, 184, 218, 49, 215, 43, 135, 145, 165, 158, 218, 63, 195, 229]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [143, 94, 45, 143, 60, 22, 127, 181, 118, 245, 141, 105, 103, 91, 39, 116, 24, 229, 56, 25, 163, 187, 169, 225, 28, 41, 160, 93, 78, 222, 50, 187]), layoutVersion := 3, digest := (bytes [32, 193, 20, 22, 26, 33, 51, 29, 241, 32, 118, 86, 8, 63, 194, 117, 170, 88, 106, 109, 35, 170, 4, 215, 35, 68, 106, 209, 247, 58, 81, 169]) }, logicalIndex := 9, digest := (bytes [137, 228, 202, 166, 22, 0, 88, 191, 67, 185, 149, 186, 113, 101, 68, 140, 239, 206, 226, 56, 101, 127, 28, 142, 224, 235, 111, 50, 181, 189, 101, 120]) }, valueDigest := (bytes [182, 134, 141, 237, 80, 100, 222, 51, 79, 143, 246, 177, 31, 61, 129, 193, 216, 133, 80, 85, 220, 234, 180, 38, 196, 214, 36, 167, 155, 158, 39, 109]), digest := (bytes [246, 34, 237, 85, 223, 76, 6, 194, 59, 192, 53, 65, 70, 12, 99, 47, 162, 216, 151, 42, 164, 30, 70, 182, 113, 250, 68, 5, 148, 143, 255, 90]) }), digest := (bytes [87, 228, 169, 87, 152, 129, 159, 14, 17, 95, 214, 28, 120, 218, 198, 65, 5, 33, 11, 236, 65, 79, 9, 75, 119, 32, 140, 184, 182, 172, 87, 232]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [207, 213, 92, 60, 135, 89, 29, 218, 252, 37, 75, 51, 101, 210, 109, 73, 181, 35, 225, 52, 76, 234, 32, 4, 119, 115, 236, 87, 27, 19, 132, 170]), rootLaneCommitmentDigest := (bytes [87, 228, 169, 87, 152, 129, 159, 14, 17, 95, 214, 28, 120, 218, 198, 65, 5, 33, 11, 236, 65, 79, 9, 75, 119, 32, 140, 184, 182, 172, 87, 232]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 10, digest := (bytes [169, 94, 117, 101, 121, 120, 176, 58, 203, 155, 197, 125, 115, 194, 63, 243, 218, 69, 12, 117, 147, 44, 140, 64, 30, 239, 27, 111, 38, 180, 108, 209]) }, statementDigest := (bytes [211, 37, 78, 168, 125, 1, 230, 222, 67, 193, 107, 233, 216, 151, 67, 160, 95, 53, 246, 57, 63, 44, 102, 132, 52, 59, 115, 227, 44, 151, 141, 225]), proofDigest := (bytes [99, 203, 182, 204, 176, 144, 142, 254, 222, 67, 35, 92, 140, 51, 147, 19, 15, 53, 180, 206, 193, 33, 228, 210, 1, 71, 182, 69, 136, 252, 24, 56]), digest := (bytes [177, 89, 1, 47, 45, 239, 78, 141, 192, 8, 252, 192, 54, 37, 103, 6, 143, 111, 149, 1, 131, 172, 26, 214, 136, 143, 221, 158, 143, 242, 16, 83]) }
  , digest := (bytes [32, 254, 59, 204, 184, 252, 90, 91, 215, 132, 126, 130, 125, 188, 6, 144, 135, 66, 237, 30, 83, 240, 242, 88, 214, 84, 49, 48, 148, 230, 98, 14])
}
}
    , exportedStatement := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , foldSchedule := Nightstream.FoldSchedule.wholeTrace
  , chunkCount := 1
  , stageClaimsDigest := (bytes [157, 217, 182, 50, 102, 253, 73, 90, 236, 226, 136, 241, 15, 164, 204, 21, 241, 250, 31, 176, 23, 65, 64, 84, 28, 75, 159, 11, 136, 45, 9, 201])
  , stagePackagesDigest := (bytes [52, 150, 130, 38, 165, 150, 120, 60, 9, 255, 119, 17, 136, 162, 5, 129, 56, 141, 234, 26, 228, 172, 50, 243, 205, 148, 140, 78, 183, 140, 115, 201])
  , kernelOpeningDigest := (bytes [186, 38, 161, 225, 204, 168, 253, 188, 96, 231, 230, 92, 153, 18, 36, 164, 241, 82, 9, 4, 151, 96, 212, 85, 114, 235, 209, 49, 240, 134, 110, 101])
  , preparedStepBindingsDigest := (bytes [30, 164, 150, 41, 218, 111, 229, 43, 231, 221, 197, 31, 58, 29, 115, 85, 208, 133, 131, 125, 250, 253, 29, 48, 239, 226, 164, 136, 42, 31, 76, 180])
  , executionDigest := (bytes [125, 109, 107, 30, 214, 28, 21, 190, 193, 73, 13, 134, 113, 2, 233, 252, 206, 60, 180, 47, 71, 229, 88, 95, 116, 143, 172, 12, 59, 79, 234, 150])
  , finalStateDigest := (bytes [103, 223, 139, 208, 116, 154, 142, 132, 78, 184, 137, 1, 105, 240, 117, 173, 130, 69, 168, 181, 198, 4, 200, 40, 154, 26, 30, 84, 163, 49, 80, 141])
  , transcriptFinalDigest := (bytes [40, 198, 217, 185, 8, 16, 125, 44, 61, 253, 171, 30, 100, 237, 238, 86, 30, 22, 230, 155, 239, 54, 28, 87, 238, 68, 77, 116, 87, 196, 144, 189])
  , mainLaneSurfaceDigest := (bytes [158, 244, 230, 166, 7, 26, 200, 97, 238, 117, 50, 31, 153, 101, 36, 103, 89, 93, 107, 138, 156, 171, 136, 228, 128, 236, 67, 8, 168, 71, 82, 121])
  , rootLaneColumnsDigest := (bytes [207, 213, 92, 60, 135, 89, 29, 218, 252, 37, 75, 51, 101, 210, 109, 73, 181, 35, 225, 52, 76, 234, 32, 4, 119, 115, 236, 87, 27, 19, 132, 170])
  , publicStepCount := 10
  , initialPc := 0
  , finalPc := 40
  , halted := true
  , digest := (bytes [253, 162, 194, 206, 158, 102, 159, 167, 114, 209, 156, 68, 161, 183, 177, 160, 15, 56, 222, 141, 8, 50, 216, 50, 210, 29, 197, 114, 87, 88, 56, 165])
}
    , exportedClaims := {
  accepted := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , statement := { proofStatementDigest := (bytes [253, 162, 194, 206, 158, 102, 159, 167, 114, 209, 156, 68, 161, 183, 177, 160, 15, 56, 222, 141, 8, 50, 216, 50, 210, 29, 197, 114, 87, 88, 56, 165]), kernelOpeningDigest := (bytes [186, 38, 161, 225, 204, 168, 253, 188, 96, 231, 230, 92, 153, 18, 36, 164, 241, 82, 9, 4, 151, 96, 212, 85, 114, 235, 209, 49, 240, 134, 110, 101]), digest := (bytes [148, 123, 232, 210, 230, 205, 73, 87, 120, 242, 32, 152, 178, 233, 58, 73, 16, 231, 240, 93, 235, 156, 229, 97, 163, 61, 86, 117, 81, 193, 10, 201]) }
  , mainLane := { mainLaneBundleDigest := (bytes [177, 89, 1, 47, 45, 239, 78, 141, 192, 8, 252, 192, 54, 37, 103, 6, 143, 111, 149, 1, 131, 172, 26, 214, 136, 143, 221, 158, 143, 242, 16, 83]), digest := (bytes [140, 197, 187, 64, 174, 42, 186, 222, 36, 194, 231, 204, 253, 186, 52, 228, 152, 231, 33, 147, 36, 166, 29, 69, 19, 130, 28, 135, 88, 167, 185, 158]) }
  , terminal := { finalStateDigest := (bytes [103, 223, 139, 208, 116, 154, 142, 132, 78, 184, 137, 1, 105, 240, 117, 173, 130, 69, 168, 181, 198, 4, 200, 40, 154, 26, 30, 84, 163, 49, 80, 141]), finalPc := 40, halted := true, digest := (bytes [244, 231, 52, 6, 159, 1, 154, 26, 57, 221, 79, 252, 201, 139, 50, 239, 65, 248, 34, 105, 22, 254, 192, 216, 218, 123, 81, 98, 93, 44, 17, 174]) }
  , digest := (bytes [240, 244, 174, 35, 252, 123, 15, 128, 61, 44, 39, 0, 182, 25, 247, 200, 180, 242, 164, 50, 64, 61, 174, 140, 105, 128, 247, 136, 23, 33, 141, 168])
}
  , mainLane := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { mainLaneBundleDigest := (bytes [177, 89, 1, 47, 45, 239, 78, 141, 192, 8, 252, 192, 54, 37, 103, 6, 143, 111, 149, 1, 131, 172, 26, 214, 136, 143, 221, 158, 143, 242, 16, 83]), digest := (bytes [200, 171, 177, 0, 199, 79, 140, 176, 24, 220, 29, 245, 65, 47, 148, 115, 227, 33, 37, 166, 141, 199, 176, 131, 144, 159, 204, 199, 141, 141, 251, 74]) }, digest := (bytes [200, 228, 74, 0, 87, 214, 175, 151, 170, 246, 29, 242, 76, 153, 145, 200, 193, 171, 204, 84, 236, 150, 17, 121, 243, 108, 154, 85, 213, 209, 132, 210]) }
  , opening := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , stages := { stageClaimsDigest := (bytes [157, 217, 182, 50, 102, 253, 73, 90, 236, 226, 136, 241, 15, 164, 204, 21, 241, 250, 31, 176, 23, 65, 64, 84, 28, 75, 159, 11, 136, 45, 9, 201]), stagePackagesDigest := (bytes [52, 150, 130, 38, 165, 150, 120, 60, 9, 255, 119, 17, 136, 162, 5, 129, 56, 141, 234, 26, 228, 172, 50, 243, 205, 148, 140, 78, 183, 140, 115, 201]), kernelOpeningDigest := (bytes [186, 38, 161, 225, 204, 168, 253, 188, 96, 231, 230, 92, 153, 18, 36, 164, 241, 82, 9, 4, 151, 96, 212, 85, 114, 235, 209, 49, 240, 134, 110, 101]), digest := (bytes [75, 168, 46, 15, 204, 96, 255, 173, 157, 128, 16, 227, 166, 84, 146, 242, 209, 72, 179, 102, 171, 192, 83, 72, 179, 21, 196, 197, 89, 19, 109, 218]) }
  , terminal := { preparedStepBindingsDigest := (bytes [30, 164, 150, 41, 218, 111, 229, 43, 231, 221, 197, 31, 58, 29, 115, 85, 208, 133, 131, 125, 250, 253, 29, 48, 239, 226, 164, 136, 42, 31, 76, 180]), executionDigest := (bytes [125, 109, 107, 30, 214, 28, 21, 190, 193, 73, 13, 134, 113, 2, 233, 252, 206, 60, 180, 47, 71, 229, 88, 95, 116, 143, 172, 12, 59, 79, 234, 150]), transcriptFinalDigest := (bytes [40, 198, 217, 185, 8, 16, 125, 44, 61, 253, 171, 30, 100, 237, 238, 86, 30, 22, 230, 155, 239, 54, 28, 87, 238, 68, 77, 116, 87, 196, 144, 189]), digest := (bytes [148, 116, 14, 112, 99, 154, 106, 183, 169, 147, 134, 185, 166, 25, 206, 99, 141, 182, 251, 156, 151, 56, 208, 204, 18, 10, 64, 151, 173, 38, 200, 38]) }
  , digest := (bytes [96, 5, 17, 15, 45, 235, 122, 220, 147, 117, 31, 240, 237, 64, 196, 233, 104, 157, 12, 220, 141, 224, 132, 145, 146, 133, 64, 188, 197, 248, 9, 41])
}
  , jointOpening := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { proofStatementDigest := (bytes [253, 162, 194, 206, 158, 102, 159, 167, 114, 209, 156, 68, 161, 183, 177, 160, 15, 56, 222, 141, 8, 50, 216, 50, 210, 29, 197, 114, 87, 88, 56, 165]), mainLaneClaimDigest := (bytes [200, 228, 74, 0, 87, 214, 175, 151, 170, 246, 29, 242, 76, 153, 145, 200, 193, 171, 204, 84, 236, 150, 17, 121, 243, 108, 154, 85, 213, 209, 132, 210]), kernelOpeningClaimDigest := (bytes [96, 5, 17, 15, 45, 235, 122, 220, 147, 117, 31, 240, 237, 64, 196, 233, 104, 157, 12, 220, 141, 224, 132, 145, 146, 133, 64, 188, 197, 248, 9, 41]), digest := (bytes [188, 186, 150, 72, 221, 140, 3, 95, 205, 106, 129, 38, 197, 193, 119, 165, 109, 172, 67, 172, 195, 152, 205, 41, 132, 183, 147, 169, 31, 78, 195, 88]) }, digest := (bytes [195, 160, 106, 171, 123, 242, 196, 82, 27, 218, 187, 164, 97, 177, 230, 138, 192, 1, 29, 253, 239, 228, 19, 223, 3, 81, 6, 23, 164, 246, 197, 201]) }
  , root0 := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), stages := { stage1Digest := (bytes [134, 144, 193, 223, 148, 183, 65, 251, 150, 253, 209, 238, 38, 219, 86, 43, 84, 158, 62, 219, 12, 185, 17, 172, 250, 121, 161, 155, 34, 218, 192, 23]), stage2Digest := (bytes [157, 229, 195, 131, 139, 8, 105, 108, 185, 165, 44, 241, 226, 186, 221, 169, 117, 119, 57, 226, 94, 130, 90, 239, 124, 28, 101, 251, 70, 102, 122, 148]), stage3Digest := (bytes [234, 177, 23, 67, 38, 251, 33, 157, 164, 66, 116, 34, 106, 3, 185, 174, 39, 193, 22, 250, 158, 150, 184, 2, 134, 157, 45, 214, 185, 100, 216, 30]), digest := (bytes [0, 83, 102, 19, 18, 64, 105, 253, 199, 72, 227, 135, 177, 136, 149, 219, 178, 112, 127, 116, 42, 61, 47, 225, 173, 124, 252, 236, 166, 29, 9, 70]) }, terminal := { root0Digest := (bytes [100, 141, 133, 191, 65, 9, 202, 67, 178, 73, 161, 90, 192, 177, 16, 176, 7, 146, 125, 14, 199, 63, 180, 56, 245, 33, 2, 6, 126, 240, 189, 23]), executionDigest := (bytes [125, 109, 107, 30, 214, 28, 21, 190, 193, 73, 13, 134, 113, 2, 233, 252, 206, 60, 180, 47, 71, 229, 88, 95, 116, 143, 172, 12, 59, 79, 234, 150]), finalStateDigest := (bytes [103, 223, 139, 208, 116, 154, 142, 132, 78, 184, 137, 1, 105, 240, 117, 173, 130, 69, 168, 181, 198, 4, 200, 40, 154, 26, 30, 84, 163, 49, 80, 141]), transcriptFinalDigest := (bytes [40, 198, 217, 185, 8, 16, 125, 44, 61, 253, 171, 30, 100, 237, 238, 86, 30, 22, 230, 155, 239, 54, 28, 87, 238, 68, 77, 116, 87, 196, 144, 189]), digest := (bytes [171, 47, 214, 199, 71, 186, 220, 107, 78, 115, 68, 89, 104, 94, 62, 122, 154, 71, 211, 99, 253, 86, 158, 186, 220, 7, 8, 87, 138, 83, 75, 230]) }, digest := (bytes [175, 152, 176, 130, 159, 1, 145, 73, 178, 107, 224, 198, 103, 82, 194, 186, 138, 1, 219, 151, 82, 68, 149, 184, 233, 60, 188, 171, 49, 44, 51, 35]) }
  , digest := (bytes [57, 246, 203, 150, 14, 82, 66, 8, 198, 221, 44, 75, 65, 70, 139, 159, 201, 241, 229, 135, 228, 161, 141, 130, 28, 16, 50, 161, 154, 185, 182, 202])
}
    , exportedKernelProof := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "native_shift_chain_ecall", fixtureId := "native_shift_chain_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , executionDigest := (bytes [125, 109, 107, 30, 214, 28, 21, 190, 193, 73, 13, 134, 113, 2, 233, 252, 206, 60, 180, 47, 71, 229, 88, 95, 116, 143, 172, 12, 59, 79, 234, 150])
  , shape := { executionRowCount := 10, realRowCount := 10, effectRowCount := 10, commitRowCount := 10, digest := (bytes [112, 139, 125, 186, 65, 232, 254, 194, 0, 75, 41, 115, 118, 66, 196, 105, 51, 14, 26, 159, 116, 35, 103, 9, 240, 124, 96, 130, 114, 5, 66, 126]) }
  , digest := (bytes [88, 119, 98, 13, 111, 130, 86, 174, 128, 138, 42, 115, 149, 129, 170, 120, 133, 40, 140, 114, 109, 125, 63, 210, 101, 48, 53, 168, 174, 117, 116, 179])
}
  , stages := { summary := { stage1RowCount := 10, stage2RegisterReadCount := 12, stage2RegisterWriteCount := 9, stage2RamEventCount := 0, stage2TwistLinkCount := 10, stage3ContinuityCount := 10, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [182, 88, 119, 178, 173, 139, 2, 120, 38, 241, 130, 157, 51, 75, 125, 230, 46, 252, 195, 62, 2, 4, 209, 233, 243, 210, 102, 203, 155, 170, 137, 196]) }, digest := (bytes [165, 169, 132, 131, 219, 58, 190, 147, 230, 10, 193, 16, 55, 193, 168, 83, 13, 115, 211, 67, 151, 50, 203, 71, 52, 226, 54, 108, 249, 109, 12, 194]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [63, 174, 85, 23, 132, 59, 164, 91, 219, 152, 118, 75, 81, 162, 203, 103, 38, 248, 208, 230, 243, 2, 237, 20, 96, 223, 24, 199, 67, 231, 4, 104]), stage1Digest := (bytes [102, 83, 120, 230, 208, 62, 162, 142, 24, 32, 119, 9, 11, 24, 97, 204, 106, 60, 128, 52, 172, 61, 9, 199, 179, 68, 37, 136, 147, 34, 125, 249]), stage2Digest := (bytes [222, 241, 73, 158, 149, 26, 237, 199, 105, 195, 107, 195, 113, 106, 151, 33, 10, 191, 23, 71, 7, 123, 23, 92, 172, 171, 255, 252, 26, 144, 255, 12]), stage3Digest := (bytes [82, 5, 191, 228, 29, 143, 146, 70, 210, 162, 133, 104, 132, 207, 23, 6, 167, 217, 152, 44, 223, 222, 180, 240, 61, 220, 69, 241, 83, 34, 91, 99]), transcriptDigest := (bytes [40, 198, 217, 185, 8, 16, 125, 44, 61, 253, 171, 30, 100, 237, 238, 86, 30, 22, 230, 155, 239, 54, 28, 87, 238, 68, 77, 116, 87, 196, 144, 189]), executionDigest := (bytes [125, 109, 107, 30, 214, 28, 21, 190, 193, 73, 13, 134, 113, 2, 233, 252, 206, 60, 180, 47, 71, 229, 88, 95, 116, 143, 172, 12, 59, 79, 234, 150]), digest := (bytes [119, 119, 96, 244, 71, 146, 91, 58, 24, 68, 255, 24, 93, 173, 78, 140, 21, 31, 194, 166, 124, 163, 86, 49, 24, 209, 46, 222, 37, 6, 187, 191]) }, statementDigest := (bytes [126, 146, 37, 155, 39, 220, 180, 4, 242, 78, 225, 66, 250, 95, 176, 124, 237, 49, 145, 231, 136, 82, 170, 203, 92, 38, 148, 28, 66, 16, 176, 179]), proofDigest := (bytes [222, 162, 167, 196, 223, 72, 3, 60, 61, 16, 115, 109, 128, 252, 138, 110, 186, 29, 232, 71, 30, 215, 84, 147, 242, 139, 51, 160, 22, 69, 97, 245]), digest := (bytes [157, 217, 182, 50, 102, 253, 73, 90, 236, 226, 136, 241, 15, 164, 204, 21, 241, 250, 31, 176, 23, 65, 64, 84, 28, 75, 159, 11, 136, 45, 9, 201]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [113, 110, 176, 95, 213, 2, 56, 45, 40, 202, 182, 238, 248, 121, 61, 153, 97, 17, 173, 150, 8, 23, 251, 135, 103, 190, 218, 12, 139, 247, 226, 169]), stage1Digest := (bytes [43, 186, 189, 15, 117, 33, 34, 68, 18, 3, 84, 129, 2, 91, 173, 225, 193, 37, 15, 208, 50, 249, 112, 52, 130, 65, 94, 111, 22, 73, 76, 78]), stage2Digest := (bytes [253, 241, 232, 168, 55, 211, 246, 203, 25, 241, 20, 54, 184, 114, 92, 233, 233, 199, 77, 26, 70, 65, 25, 201, 15, 55, 146, 156, 222, 134, 247, 183]), stage3Digest := (bytes [123, 200, 171, 142, 73, 227, 53, 197, 73, 245, 79, 164, 187, 42, 144, 179, 84, 250, 64, 72, 82, 210, 170, 82, 241, 181, 251, 189, 13, 255, 120, 86]), digest := (bytes [133, 21, 66, 136, 48, 137, 198, 59, 148, 231, 171, 98, 105, 70, 132, 93, 153, 70, 79, 47, 95, 196, 59, 124, 6, 157, 193, 132, 228, 80, 114, 230]) }, digest := (bytes [52, 150, 130, 38, 165, 150, 120, 60, 9, 255, 119, 17, 136, 162, 5, 129, 56, 141, 234, 26, 228, 172, 50, 243, 205, 148, 140, 78, 183, 140, 115, 201]) }
  , kernelOpening := { openingDigest := (bytes [119, 115, 69, 96, 249, 81, 149, 206, 220, 151, 99, 202, 67, 69, 201, 92, 94, 159, 3, 77, 69, 192, 47, 246, 24, 74, 248, 141, 142, 191, 2, 138]), bindings := { claimDigest := (bytes [237, 233, 103, 61, 197, 60, 93, 141, 147, 156, 156, 127, 58, 72, 103, 44, 100, 145, 190, 255, 134, 121, 188, 169, 23, 16, 186, 120, 221, 196, 248, 22]), bindingsDigest := (bytes [105, 17, 253, 140, 161, 226, 141, 222, 139, 157, 43, 163, 42, 73, 21, 118, 4, 18, 117, 190, 221, 83, 239, 144, 47, 3, 84, 174, 101, 96, 127, 107]), preparedStepsDigest := (bytes [81, 219, 54, 55, 186, 72, 121, 178, 0, 65, 66, 150, 185, 245, 31, 236, 170, 91, 0, 247, 142, 217, 220, 215, 17, 135, 253, 254, 66, 63, 153, 211]), digest := (bytes [150, 94, 158, 112, 210, 229, 71, 125, 37, 46, 29, 188, 68, 12, 154, 71, 104, 118, 105, 175, 201, 75, 93, 53, 192, 95, 59, 55, 235, 106, 233, 0]) }, digest := (bytes [186, 38, 161, 225, 204, 168, 253, 188, 96, 231, 230, 92, 153, 18, 36, 164, 241, 82, 9, 4, 151, 96, 212, 85, 114, 235, 209, 49, 240, 134, 110, 101]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [30, 164, 150, 41, 218, 111, 229, 43, 231, 221, 197, 31, 58, 29, 115, 85, 208, 133, 131, 125, 250, 253, 29, 48, 239, 226, 164, 136, 42, 31, 76, 180]), terminal := { root0Digest := (bytes [100, 141, 133, 191, 65, 9, 202, 67, 178, 73, 161, 90, 192, 177, 16, 176, 7, 146, 125, 14, 199, 63, 180, 56, 245, 33, 2, 6, 126, 240, 189, 23]), executionDigest := (bytes [125, 109, 107, 30, 214, 28, 21, 190, 193, 73, 13, 134, 113, 2, 233, 252, 206, 60, 180, 47, 71, 229, 88, 95, 116, 143, 172, 12, 59, 79, 234, 150]), finalStateDigest := (bytes [103, 223, 139, 208, 116, 154, 142, 132, 78, 184, 137, 1, 105, 240, 117, 173, 130, 69, 168, 181, 198, 4, 200, 40, 154, 26, 30, 84, 163, 49, 80, 141]), transcriptFinalDigest := (bytes [40, 198, 217, 185, 8, 16, 125, 44, 61, 253, 171, 30, 100, 237, 238, 86, 30, 22, 230, 155, 239, 54, 28, 87, 238, 68, 77, 116, 87, 196, 144, 189]), finalPc := 40, halted := true, digest := (bytes [144, 111, 188, 226, 66, 170, 58, 159, 68, 203, 38, 149, 106, 226, 154, 125, 200, 223, 159, 59, 47, 55, 193, 41, 253, 116, 109, 155, 245, 29, 95, 125]) }, digest := (bytes [142, 36, 38, 156, 150, 255, 148, 120, 152, 162, 171, 102, 136, 163, 255, 130, 69, 240, 176, 63, 222, 134, 222, 107, 42, 199, 112, 201, 191, 32, 249, 214]) }, statementDigest := (bytes [236, 221, 46, 4, 110, 86, 195, 216, 120, 3, 130, 111, 87, 29, 63, 57, 107, 2, 247, 98, 191, 146, 95, 48, 62, 151, 183, 255, 39, 157, 73, 119]), proofDigest := (bytes [122, 78, 120, 200, 161, 108, 181, 126, 26, 14, 240, 3, 67, 156, 181, 117, 40, 145, 19, 78, 22, 40, 243, 33, 241, 9, 216, 89, 158, 63, 50, 190]), digest := (bytes [242, 42, 150, 57, 63, 86, 128, 252, 140, 109, 108, 250, 72, 222, 150, 43, 79, 38, 0, 73, 171, 248, 214, 3, 53, 71, 222, 85, 180, 82, 15, 117]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [57, 96, 173, 107, 74, 96, 6, 184, 93, 44, 158, 222, 17, 105, 235, 100, 93, 195, 146, 163, 228, 224, 253, 134, 235, 58, 173, 222, 168, 61, 29, 210]), layoutVersion := 1, digest := (bytes [218, 252, 26, 46, 28, 218, 125, 203, 192, 156, 76, 141, 163, 163, 128, 206, 131, 248, 235, 86, 73, 170, 207, 167, 89, 133, 185, 83, 239, 57, 137, 201]) }, rowWidth := 38, timeLen := 10, columnDigests := [(bytes [12, 228, 244, 232, 232, 195, 81, 12, 214, 193, 42, 183, 200, 29, 152, 94, 136, 29, 6, 38, 78, 210, 160, 183, 216, 225, 73, 147, 50, 136, 142, 214]), (bytes [240, 182, 76, 250, 35, 170, 242, 238, 13, 3, 36, 197, 217, 34, 88, 179, 25, 179, 252, 9, 53, 253, 106, 155, 210, 71, 3, 170, 179, 214, 158, 65]), (bytes [195, 188, 63, 10, 98, 211, 186, 126, 183, 152, 82, 190, 233, 91, 13, 44, 234, 86, 153, 242, 47, 0, 90, 173, 178, 126, 238, 39, 206, 42, 90, 234]), (bytes [8, 42, 43, 132, 150, 119, 43, 88, 120, 73, 248, 4, 160, 61, 234, 157, 237, 5, 30, 176, 13, 32, 132, 34, 140, 232, 248, 156, 189, 150, 158, 132]), (bytes [183, 153, 10, 248, 62, 168, 118, 167, 230, 138, 239, 173, 144, 140, 163, 208, 253, 182, 92, 210, 65, 128, 123, 109, 59, 243, 8, 21, 192, 111, 223, 235]), (bytes [96, 49, 53, 146, 252, 231, 2, 133, 7, 150, 231, 243, 19, 147, 34, 3, 19, 95, 125, 142, 225, 119, 94, 30, 41, 92, 213, 40, 58, 73, 204, 178]), (bytes [6, 202, 216, 137, 252, 35, 77, 13, 181, 151, 136, 136, 116, 231, 11, 46, 57, 52, 185, 82, 154, 67, 81, 140, 148, 104, 11, 88, 174, 229, 167, 189]), (bytes [48, 51, 138, 201, 111, 86, 152, 134, 106, 27, 115, 24, 34, 241, 131, 144, 253, 88, 175, 132, 8, 28, 83, 227, 186, 166, 5, 153, 14, 152, 167, 155]), (bytes [38, 189, 190, 109, 40, 90, 176, 164, 205, 6, 244, 99, 155, 110, 177, 188, 15, 110, 175, 155, 25, 30, 14, 180, 42, 110, 165, 250, 171, 206, 182, 252]), (bytes [237, 165, 119, 146, 86, 53, 241, 200, 114, 247, 22, 68, 204, 180, 71, 182, 30, 146, 193, 238, 245, 34, 150, 29, 228, 223, 212, 88, 34, 209, 138, 59]), (bytes [100, 157, 167, 161, 144, 13, 101, 250, 75, 66, 176, 27, 234, 116, 230, 94, 68, 12, 251, 12, 193, 57, 231, 191, 86, 6, 57, 71, 28, 61, 41, 243]), (bytes [55, 104, 163, 114, 203, 113, 243, 96, 246, 239, 169, 197, 247, 25, 87, 83, 254, 89, 219, 112, 50, 58, 113, 40, 39, 11, 128, 37, 130, 105, 141, 223]), (bytes [75, 32, 207, 134, 219, 18, 161, 48, 94, 95, 165, 227, 110, 209, 210, 37, 12, 218, 2, 100, 69, 87, 80, 84, 199, 63, 213, 142, 156, 83, 58, 207]), (bytes [67, 239, 94, 227, 76, 210, 86, 117, 147, 191, 52, 217, 52, 78, 157, 14, 95, 144, 135, 97, 188, 115, 47, 236, 121, 233, 209, 179, 61, 184, 178, 88]), (bytes [72, 188, 177, 89, 243, 172, 72, 201, 140, 24, 218, 201, 12, 85, 51, 235, 118, 224, 89, 207, 230, 208, 206, 156, 116, 113, 199, 219, 143, 79, 31, 182]), (bytes [70, 226, 162, 48, 249, 249, 238, 229, 208, 237, 173, 243, 12, 180, 219, 129, 178, 47, 57, 146, 39, 248, 168, 200, 27, 239, 97, 103, 235, 87, 98, 152]), (bytes [168, 135, 31, 110, 99, 170, 118, 153, 62, 23, 162, 146, 237, 131, 59, 107, 61, 171, 125, 141, 126, 72, 211, 252, 87, 247, 107, 97, 184, 97, 115, 62]), (bytes [195, 241, 122, 156, 175, 234, 131, 108, 215, 171, 109, 221, 145, 195, 177, 216, 224, 3, 71, 137, 168, 123, 92, 150, 220, 244, 199, 164, 30, 190, 118, 196]), (bytes [91, 173, 31, 113, 28, 0, 124, 210, 36, 221, 147, 10, 225, 65, 253, 252, 190, 167, 173, 20, 27, 91, 29, 243, 214, 72, 147, 137, 219, 101, 249, 19]), (bytes [59, 90, 50, 88, 131, 202, 40, 187, 147, 95, 62, 165, 211, 185, 201, 13, 248, 93, 124, 178, 255, 171, 133, 136, 142, 97, 27, 17, 233, 80, 74, 206]), (bytes [66, 136, 207, 236, 216, 66, 254, 209, 16, 181, 177, 57, 69, 165, 202, 200, 200, 139, 52, 180, 129, 129, 57, 57, 45, 36, 235, 80, 85, 41, 104, 97]), (bytes [250, 243, 36, 121, 222, 230, 87, 172, 149, 80, 32, 187, 23, 44, 161, 164, 116, 82, 156, 142, 181, 200, 8, 117, 73, 175, 232, 208, 178, 248, 111, 216]), (bytes [176, 39, 109, 185, 241, 9, 236, 176, 30, 215, 238, 28, 183, 191, 205, 114, 166, 252, 186, 41, 162, 90, 213, 56, 162, 0, 252, 238, 13, 68, 157, 75]), (bytes [191, 14, 23, 70, 191, 143, 164, 138, 31, 103, 126, 202, 195, 103, 102, 91, 13, 76, 74, 232, 113, 19, 110, 181, 239, 121, 83, 104, 130, 66, 20, 253]), (bytes [161, 175, 165, 91, 84, 150, 30, 59, 1, 249, 254, 100, 229, 185, 223, 86, 127, 89, 230, 146, 65, 69, 137, 203, 79, 105, 52, 90, 109, 2, 37, 33]), (bytes [233, 165, 191, 129, 157, 1, 246, 73, 33, 152, 81, 181, 88, 226, 255, 164, 136, 147, 176, 124, 163, 119, 171, 116, 230, 54, 36, 93, 201, 201, 12, 154]), (bytes [120, 241, 77, 148, 156, 149, 19, 10, 198, 193, 143, 175, 140, 145, 200, 37, 79, 90, 110, 93, 33, 50, 32, 17, 152, 164, 75, 183, 13, 110, 138, 180]), (bytes [180, 238, 180, 101, 177, 238, 139, 240, 30, 235, 37, 156, 160, 17, 158, 230, 150, 48, 150, 208, 185, 74, 30, 212, 220, 22, 112, 242, 233, 187, 105, 34]), (bytes [15, 1, 218, 124, 15, 223, 36, 143, 32, 158, 170, 206, 91, 155, 126, 37, 196, 143, 155, 198, 194, 142, 246, 15, 222, 133, 213, 79, 12, 118, 55, 86]), (bytes [234, 5, 33, 209, 57, 239, 56, 248, 2, 242, 172, 102, 200, 208, 75, 112, 102, 61, 189, 1, 20, 2, 94, 68, 72, 178, 83, 113, 30, 120, 234, 96]), (bytes [69, 95, 44, 2, 235, 12, 178, 37, 126, 183, 181, 181, 34, 31, 118, 138, 88, 126, 88, 160, 125, 206, 247, 182, 110, 182, 45, 127, 119, 49, 254, 66]), (bytes [98, 233, 75, 159, 154, 202, 229, 197, 204, 114, 61, 90, 121, 211, 59, 64, 176, 54, 189, 127, 231, 130, 146, 184, 171, 30, 12, 52, 230, 151, 238, 234]), (bytes [85, 138, 40, 17, 194, 246, 165, 186, 54, 48, 183, 234, 232, 158, 92, 162, 223, 181, 255, 178, 195, 61, 236, 20, 16, 246, 177, 195, 118, 179, 254, 250]), (bytes [239, 10, 197, 2, 15, 35, 45, 100, 252, 20, 168, 193, 214, 233, 118, 179, 26, 248, 115, 153, 62, 42, 18, 72, 92, 106, 228, 90, 223, 90, 43, 14]), (bytes [193, 59, 68, 39, 80, 165, 100, 185, 20, 170, 20, 170, 19, 36, 29, 31, 55, 205, 233, 106, 36, 227, 142, 2, 63, 219, 79, 27, 21, 248, 36, 25]), (bytes [52, 1, 149, 46, 119, 9, 176, 204, 186, 190, 87, 167, 210, 115, 219, 0, 114, 162, 51, 255, 85, 195, 255, 197, 145, 74, 70, 24, 80, 13, 229, 52]), (bytes [113, 35, 60, 216, 127, 5, 20, 16, 38, 10, 254, 113, 13, 6, 112, 72, 47, 146, 253, 123, 255, 67, 40, 28, 150, 201, 176, 250, 103, 139, 16, 73]), (bytes [63, 217, 215, 39, 159, 216, 214, 211, 74, 192, 206, 214, 51, 249, 89, 113, 249, 83, 19, 201, 137, 72, 173, 246, 67, 188, 116, 70, 76, 81, 191, 96])], familyDigest := (bytes [57, 96, 173, 107, 74, 96, 6, 184, 93, 44, 158, 222, 17, 105, 235, 100, 93, 195, 146, 163, 228, 224, 253, 134, 235, 58, 173, 222, 168, 61, 29, 210]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [57, 96, 173, 107, 74, 96, 6, 184, 93, 44, 158, 222, 17, 105, 235, 100, 93, 195, 146, 163, 228, 224, 253, 134, 235, 58, 173, 222, 168, 61, 29, 210]), layoutVersion := 1, digest := (bytes [218, 252, 26, 46, 28, 218, 125, 203, 192, 156, 76, 141, 163, 163, 128, 206, 131, 248, 235, 86, 73, 170, 207, 167, 89, 133, 185, 83, 239, 57, 137, 201]) }, logicalIndex := 0, digest := (bytes [54, 28, 19, 75, 137, 45, 177, 143, 245, 153, 104, 45, 35, 166, 251, 47, 50, 28, 106, 102, 36, 231, 93, 5, 72, 37, 42, 247, 137, 226, 27, 82]) }, valueDigest := (bytes [48, 9, 158, 59, 120, 45, 200, 155, 8, 144, 252, 183, 179, 168, 71, 138, 10, 136, 117, 72, 217, 133, 28, 26, 240, 134, 159, 61, 227, 8, 46, 227]), digest := (bytes [49, 66, 52, 214, 209, 84, 198, 152, 216, 68, 219, 110, 141, 188, 227, 107, 57, 26, 107, 138, 67, 120, 37, 90, 52, 170, 211, 173, 128, 92, 10, 61]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [57, 96, 173, 107, 74, 96, 6, 184, 93, 44, 158, 222, 17, 105, 235, 100, 93, 195, 146, 163, 228, 224, 253, 134, 235, 58, 173, 222, 168, 61, 29, 210]), layoutVersion := 1, digest := (bytes [218, 252, 26, 46, 28, 218, 125, 203, 192, 156, 76, 141, 163, 163, 128, 206, 131, 248, 235, 86, 73, 170, 207, 167, 89, 133, 185, 83, 239, 57, 137, 201]) }, logicalIndex := 9, digest := (bytes [64, 210, 212, 127, 248, 49, 117, 4, 151, 121, 75, 236, 120, 11, 169, 68, 49, 158, 135, 180, 211, 60, 107, 250, 129, 157, 15, 164, 44, 198, 127, 75]) }, valueDigest := (bytes [182, 134, 141, 237, 80, 100, 222, 51, 79, 143, 246, 177, 31, 61, 129, 193, 216, 133, 80, 85, 220, 234, 180, 38, 196, 214, 36, 167, 155, 158, 39, 109]), digest := (bytes [24, 14, 108, 218, 1, 247, 142, 252, 41, 224, 234, 209, 96, 212, 186, 131, 15, 64, 204, 6, 123, 205, 222, 241, 128, 57, 92, 135, 153, 60, 46, 19]) }), digest := (bytes [207, 213, 92, 60, 135, 89, 29, 218, 252, 37, 75, 51, 101, 210, 109, 73, 181, 35, 225, 52, 76, 234, 32, 4, 119, 115, 236, 87, 27, 19, 132, 170]) }
  , rootLaneCommitment := { timeLen := 10, commitments := { commitmentCount := 38, digest := (bytes [143, 94, 45, 143, 60, 22, 127, 181, 118, 245, 141, 105, 103, 91, 39, 116, 24, 229, 56, 25, 163, 187, 169, 225, 28, 41, 160, 93, 78, 222, 50, 187]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [143, 94, 45, 143, 60, 22, 127, 181, 118, 245, 141, 105, 103, 91, 39, 116, 24, 229, 56, 25, 163, 187, 169, 225, 28, 41, 160, 93, 78, 222, 50, 187]), layoutVersion := 3, digest := (bytes [32, 193, 20, 22, 26, 33, 51, 29, 241, 32, 118, 86, 8, 63, 194, 117, 170, 88, 106, 109, 35, 170, 4, 215, 35, 68, 106, 209, 247, 58, 81, 169]) }, logicalIndex := 0, digest := (bytes [158, 3, 251, 138, 251, 63, 112, 48, 112, 160, 14, 162, 124, 125, 104, 34, 131, 115, 51, 105, 65, 219, 250, 250, 11, 105, 178, 218, 121, 174, 58, 157]) }, valueDigest := (bytes [48, 9, 158, 59, 120, 45, 200, 155, 8, 144, 252, 183, 179, 168, 71, 138, 10, 136, 117, 72, 217, 133, 28, 26, 240, 134, 159, 61, 227, 8, 46, 227]), digest := (bytes [48, 177, 97, 252, 216, 198, 105, 222, 211, 46, 152, 50, 44, 9, 162, 23, 99, 209, 115, 184, 218, 49, 215, 43, 135, 145, 165, 158, 218, 63, 195, 229]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [143, 94, 45, 143, 60, 22, 127, 181, 118, 245, 141, 105, 103, 91, 39, 116, 24, 229, 56, 25, 163, 187, 169, 225, 28, 41, 160, 93, 78, 222, 50, 187]), layoutVersion := 3, digest := (bytes [32, 193, 20, 22, 26, 33, 51, 29, 241, 32, 118, 86, 8, 63, 194, 117, 170, 88, 106, 109, 35, 170, 4, 215, 35, 68, 106, 209, 247, 58, 81, 169]) }, logicalIndex := 9, digest := (bytes [137, 228, 202, 166, 22, 0, 88, 191, 67, 185, 149, 186, 113, 101, 68, 140, 239, 206, 226, 56, 101, 127, 28, 142, 224, 235, 111, 50, 181, 189, 101, 120]) }, valueDigest := (bytes [182, 134, 141, 237, 80, 100, 222, 51, 79, 143, 246, 177, 31, 61, 129, 193, 216, 133, 80, 85, 220, 234, 180, 38, 196, 214, 36, 167, 155, 158, 39, 109]), digest := (bytes [246, 34, 237, 85, 223, 76, 6, 194, 59, 192, 53, 65, 70, 12, 99, 47, 162, 216, 151, 42, 164, 30, 70, 182, 113, 250, 68, 5, 148, 143, 255, 90]) }), digest := (bytes [87, 228, 169, 87, 152, 129, 159, 14, 17, 95, 214, 28, 120, 218, 198, 65, 5, 33, 11, 236, 65, 79, 9, 75, 119, 32, 140, 184, 182, 172, 87, 232]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [207, 213, 92, 60, 135, 89, 29, 218, 252, 37, 75, 51, 101, 210, 109, 73, 181, 35, 225, 52, 76, 234, 32, 4, 119, 115, 236, 87, 27, 19, 132, 170]), rootLaneCommitmentDigest := (bytes [87, 228, 169, 87, 152, 129, 159, 14, 17, 95, 214, 28, 120, 218, 198, 65, 5, 33, 11, 236, 65, 79, 9, 75, 119, 32, 140, 184, 182, 172, 87, 232]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 10, digest := (bytes [169, 94, 117, 101, 121, 120, 176, 58, 203, 155, 197, 125, 115, 194, 63, 243, 218, 69, 12, 117, 147, 44, 140, 64, 30, 239, 27, 111, 38, 180, 108, 209]) }, statementDigest := (bytes [211, 37, 78, 168, 125, 1, 230, 222, 67, 193, 107, 233, 216, 151, 67, 160, 95, 53, 246, 57, 63, 44, 102, 132, 52, 59, 115, 227, 44, 151, 141, 225]), proofDigest := (bytes [99, 203, 182, 204, 176, 144, 142, 254, 222, 67, 35, 92, 140, 51, 147, 19, 15, 53, 180, 206, 193, 33, 228, 210, 1, 71, 182, 69, 136, 252, 24, 56]), digest := (bytes [177, 89, 1, 47, 45, 239, 78, 141, 192, 8, 252, 192, 54, 37, 103, 6, 143, 111, 149, 1, 131, 172, 26, 214, 136, 143, 221, 158, 143, 242, 16, 83]) }
  , digest := (bytes [32, 254, 59, 204, 184, 252, 90, 91, 215, 132, 126, 130, 125, 188, 6, 144, 135, 66, 237, 30, 83, 240, 242, 88, 214, 84, 49, 48, 148, 230, 98, 14])
}
    , transcript := {
  appLabel := (bytes [110, 101, 111, 46, 102, 111, 108, 100, 46, 110, 101, 120, 116, 47, 114, 118, 54, 52, 105, 109, 47, 112, 97, 114, 105, 116, 121, 95, 107, 101, 114, 110, 101, 108, 95, 118, 49])
  , events := [{
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 116, 114, 97, 110, 115, 99, 114, 105, 112, 116, 95, 115, 101, 101, 100])
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 110, 97, 116, 105, 118, 101, 45, 115, 104, 105, 102, 116, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [33264025209497715, 49, 3390619080185759186, 12096819762988914126, 4001610679670701799, 5432763535062103318, 13415967828788768464, 15663373744946530692], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [110, 97, 116, 105, 118, 101, 95, 115, 104, 105, 102, 116, 95, 99, 104, 97, 105, 110, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [33264025209497715, 49, 3390619080185759186, 12096819762988914126, 4001610679670701799, 5432763535062103318, 13415967828788768464, 15663373744946530692], absorbed := 2 }
  , cursorAfter := { stateWords := [9343583599440594713, 10983263396399423942, 10213758535099150043, 17999485627249729703, 8213066104219617703, 12273497441021069772, 14876407735256743716, 15476744526804179329], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [1048723, 4231443, 4278190483, 2183699, 1075958419, 3146515, 6329267, 6378547, 1080153267, 115]
  , cursorBefore := { stateWords := [9343583599440594713, 10983263396399423942, 10213758535099150043, 17999485627249729703, 8213066104219617703, 12273497441021069772, 14876407735256743716, 15476744526804179329], absorbed := 0 }
  , cursorAfter := { stateWords := [115, 0, 12132189991474095693, 5724097830014706505, 4009596014858473286, 5995263417795965784, 408868401535594138, 17006945087715718041], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [115, 0, 12132189991474095693, 5724097830014706505, 4009596014858473286, 5995263417795965784, 408868401535594138, 17006945087715718041], absorbed := 2 }
  , cursorAfter := { stateWords := [3528834191574932829, 6155173375791115620, 13609196687032797688, 11002803251645454761, 12206787759704429923, 16410673065852401615, 2598699549887548923, 12066494163384387956], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [3528834191574932829, 6155173375791115620, 13609196687032797688, 11002803251645454761, 12206787759704429923, 16410673065852401615, 2598699549887548923, 12066494163384387956], absorbed := 0 }
  , cursorAfter := { stateWords := [34184295084289375, 0, 3573761302448998257, 4094924913629440852, 4449727207908542588, 7274712621141095245, 10189188638743606548, 8854558257557134109], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [100, 141, 133, 191, 65, 9, 202, 67, 178, 73, 161, 90, 192, 177, 16, 176, 7, 146, 125, 14, 199, 63, 180, 56, 245, 33, 2, 6, 126, 240, 189, 23])
  , u64s := []
  , cursorBefore := { stateWords := [34184295084289375, 0, 3573761302448998257, 4094924913629440852, 4449727207908542588, 7274712621141095245, 10189188638743606548, 8854558257557134109], absorbed := 2 }
  , cursorAfter := { stateWords := [398323838, 13563848412886993082, 5367215074576215338, 5585458906983765709, 8449989835503769803, 11906319393298175280, 17849796046869045789, 15345541679146046444], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [398323838, 13563848412886993082, 5367215074576215338, 5585458906983765709, 8449989835503769803, 11906319393298175280, 17849796046869045789, 15345541679146046444], absorbed := 1 }
  , cursorAfter := { stateWords := [16691009948854132645, 8590394677687983344, 6791025823853643633, 8055613139477747472, 2334784384309520970, 8120023813436867814, 12534626429442971049, 10949312597069331114], absorbed := 0 }
  , challengeOutput := (some 16691009948854132645)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [134, 144, 193, 223, 148, 183, 65, 251, 150, 253, 209, 238, 38, 219, 86, 43, 84, 158, 62, 219, 12, 185, 17, 172, 250, 121, 161, 155, 34, 218, 192, 23])
  , u64s := []
  , cursorBefore := { stateWords := [16691009948854132645, 8590394677687983344, 6791025823853643633, 8055613139477747472, 2334784384309520970, 8120023813436867814, 12534626429442971049, 10949312597069331114], absorbed := 0 }
  , cursorAfter := { stateWords := [3618761711299414, 43806166658847161, 398514722, 7027272740655351469, 4546986030328210763, 14841835654066153876, 15041005742323689594, 17480490590060115057], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [3618761711299414, 43806166658847161, 398514722, 7027272740655351469, 4546986030328210763, 14841835654066153876, 15041005742323689594, 17480490590060115057], absorbed := 3 }
  , cursorAfter := { stateWords := [4919044041631935056, 14189116834329926604, 12419105555469757780, 14270356555172948800, 8093844472540501353, 9124786461151767659, 7152703984857230834, 13210800323996142899], absorbed := 0 }
  , challengeOutput := (some 4919044041631935056)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [4919044041631935056, 14189116834329926604, 12419105555469757780, 14270356555172948800, 8093844472540501353, 9124786461151767659, 7152703984857230834, 13210800323996142899], absorbed := 0 }
  , cursorAfter := { stateWords := [16264464362193895577, 11461908290415474824, 11397215704295747164, 9824510442467619620, 18290234949193389834, 5594432991877263909, 9081794983633899672, 10912585245568592430], absorbed := 0 }
  , challengeOutput := (some 16264464362193895577)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [157, 229, 195, 131, 139, 8, 105, 108, 185, 165, 44, 241, 226, 186, 221, 169, 117, 119, 57, 226, 94, 130, 90, 239, 124, 28, 101, 251, 70, 102, 122, 148])
  , u64s := []
  , cursorBefore := { stateWords := [16264464362193895577, 11461908290415474824, 11397215704295747164, 9824510442467619620, 18290234949193389834, 5594432991877263909, 9081794983633899672, 10912585245568592430], absorbed := 0 }
  , cursorAfter := { stateWords := [26707384256014813, 70761392183925378, 2491049542, 9507906175547332923, 3730582484654031885, 16876102647749534996, 12581855173648909236, 16514804110931742469], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [26707384256014813, 70761392183925378, 2491049542, 9507906175547332923, 3730582484654031885, 16876102647749534996, 12581855173648909236, 16514804110931742469], absorbed := 3 }
  , cursorAfter := { stateWords := [9654341997663817196, 5004801482934633826, 15589065540793569337, 16974695238686938950, 705696601170899424, 17826056565796222072, 17185746199196365289, 17250980329634985717], absorbed := 0 }
  , challengeOutput := (some 9654341997663817196)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [234, 177, 23, 67, 38, 251, 33, 157, 164, 66, 116, 34, 106, 3, 185, 174, 39, 193, 22, 250, 158, 150, 184, 2, 134, 157, 45, 214, 185, 100, 216, 30])
  , u64s := []
  , cursorBefore := { stateWords := [9654341997663817196, 5004801482934633826, 15589065540793569337, 16974695238686938950, 705696601170899424, 17826056565796222072, 17185746199196365289, 17250980329634985717], absorbed := 0 }
  , cursorAfter := { stateWords := [44748021957111481, 60285799597521046, 517498041, 13646145847636500251, 11517170574194729242, 3460917812286701909, 4557134827179065529, 17390159929072289930], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [125, 109, 107, 30, 214, 28, 21, 190, 193, 73, 13, 134, 113, 2, 233, 252, 206, 60, 180, 47, 71, 229, 88, 95, 116, 143, 172, 12, 59, 79, 234, 150])
  , u64s := []
  , cursorBefore := { stateWords := [44748021957111481, 60285799597521046, 517498041, 13646145847636500251, 11517170574194729242, 3460917812286701909, 4557134827179065529, 17390159929072289930], absorbed := 3 }
  , cursorAfter := { stateWords := [20037174507273449, 3567431853234405, 2531938107, 1325518863947626039, 8964014674430181503, 15342147114171615346, 13426727881498678871, 139830257145797863], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [103, 223, 139, 208, 116, 154, 142, 132, 78, 184, 137, 1, 105, 240, 117, 173, 130, 69, 168, 181, 198, 4, 200, 40, 154, 26, 30, 84, 163, 49, 80, 141])
  , u64s := []
  , cursorBefore := { stateWords := [20037174507273449, 3567431853234405, 2531938107, 1325518863947626039, 8964014674430181503, 15342147114171615346, 13426727881498678871, 139830257145797863], absorbed := 3 }
  , cursorAfter := { stateWords := [55931779714035061, 23676997648041988, 2370843043, 7093541884208153986, 7915818848580902698, 3476745757337338623, 13097431133370823525, 1567520043707639019], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [55931779714035061, 23676997648041988, 2370843043, 7093541884208153986, 7915818848580902698, 3476745757337338623, 13097431133370823525, 1567520043707639019], absorbed := 3 }
  , cursorAfter := { stateWords := [10261008020113467646, 10108384727196382461, 17846612664083407406, 14694403235617166691, 13277652733314478642, 5223581477044193931, 5580092013888805740, 758801733075114328], absorbed := 0 }
  , challengeOutput := (some 10261008020113467646)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [10261008020113467646, 10108384727196382461, 17846612664083407406, 14694403235617166691, 13277652733314478642, 5223581477044193931, 5580092013888805740, 758801733075114328], absorbed := 0 }
  , cursorAfter := { stateWords := [3205736139421500968, 6264205145986039101, 6276952383388259870, 13659633549707134190, 7916290875057399432, 528344911851888055, 206090245114880306, 7344352859528851009], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [40, 198, 217, 185, 8, 16, 125, 44, 61, 253, 171, 30, 100, 237, 238, 86, 30, 22, 230, 155, 239, 54, 28, 87, 238, 68, 77, 116, 87, 196, 144, 189]))
}]
}
    , stage1 := stage1
    , stage2 := stage2
    , stage3 := stage3
    , rootExecution := rootExecution
    , stepComposition := stepComposition
    , soundnessAccounting := soundnessAccounting
    , kernelOpeningBundle := kernelOpeningBundle
    , digest := (bytes [132, 231, 188, 241, 231, 135, 57, 44, 6, 124, 150, 71, 162, 125, 82, 174, 222, 208, 4, 20, 81, 221, 132, 188, 21, 234, 224, 95, 139, 95, 167, 180])
  }

end Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors.Case_native_shift_chain_ecall
