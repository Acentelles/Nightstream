import Nightstream.Rv64IM.Generated.AcceptedProofArtifactTypes

set_option maxHeartbeats 0
set_option maxRecDepth 65536

namespace Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors.Case_native_logic_compare_chain_ecall

open Nightstream.Rv64IM.Generated

def stage1SemInputs : List SemInView :=
  [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, pc := 0, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 1, archRdBefore := 0, archImm := 5, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 1, rdBefore := 0, rdAfter := 5, imm := 5, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, pc := 4, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 2, archRdBefore := 0, archImm := 3, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 2, rdBefore := 0, rdAfter := 3, imm := 3, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, pc := 8, opcode := .and, traceOpcode := (some .and), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 1, archRs1Value := 5, archRs2 := 2, archRs2Value := 3, archRd := 3, archRdBefore := 0, archImm := 0, rs1 := 1, rs1Value := 5, rs2 := 2, rs2Value := 3, rd := 3, rdBefore := 0, rdAfter := 1, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, pc := 12, opcode := .andi, traceOpcode := (some .andi), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 1, archRs1Value := 5, archRs2 := 0, archRs2Value := 0, archRd := 4, archRdBefore := 0, archImm := 6, rs1 := 1, rs1Value := 5, rs2 := 0, rs2Value := 0, rd := 4, rdBefore := 0, rdAfter := 4, imm := 6, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 4, stepIndex := 4, sequenceIndex := 0, pc := 16, opcode := .or, traceOpcode := (some .or), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 1, archRs1Value := 5, archRs2 := 2, archRs2Value := 3, archRd := 5, archRdBefore := 0, archImm := 0, rs1 := 1, rs1Value := 5, rs2 := 2, rs2Value := 3, rd := 5, rdBefore := 0, rdAfter := 7, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 5, stepIndex := 5, sequenceIndex := 0, pc := 20, opcode := .ori, traceOpcode := (some .ori), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 2, archRs1Value := 3, archRs2 := 0, archRs2Value := 0, archRd := 6, archRdBefore := 0, archImm := 8, rs1 := 2, rs1Value := 3, rs2 := 0, rs2Value := 0, rd := 6, rdBefore := 0, rdAfter := 11, imm := 8, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 6, stepIndex := 6, sequenceIndex := 0, pc := 24, opcode := .xor, traceOpcode := (some .xor), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 1, archRs1Value := 5, archRs2 := 2, archRs2Value := 3, archRd := 7, archRdBefore := 0, archImm := 0, rs1 := 1, rs1Value := 5, rs2 := 2, rs2Value := 3, rd := 7, rdBefore := 0, rdAfter := 6, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 7, stepIndex := 7, sequenceIndex := 0, pc := 28, opcode := .xori, traceOpcode := (some .xori), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 1, archRs1Value := 5, archRs2 := 0, archRs2Value := 0, archRd := 8, archRdBefore := 0, archImm := 7, rs1 := 1, rs1Value := 5, rs2 := 0, rs2Value := 0, rd := 8, rdBefore := 0, rdAfter := 2, imm := 7, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 8, stepIndex := 8, sequenceIndex := 0, pc := 32, opcode := .slt, traceOpcode := (some .slt), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 2, archRs1Value := 3, archRs2 := 1, archRs2Value := 5, archRd := 9, archRdBefore := 0, archImm := 0, rs1 := 2, rs1Value := 3, rs2 := 1, rs2Value := 5, rd := 9, rdBefore := 0, rdAfter := 1, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 9, stepIndex := 9, sequenceIndex := 0, pc := 36, opcode := .slti, traceOpcode := (some .slti), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 2, archRs1Value := 3, archRs2 := 0, archRs2Value := 0, archRd := 10, archRdBefore := 0, archImm := 4, rs1 := 2, rs1Value := 3, rs2 := 0, rs2Value := 0, rd := 10, rdBefore := 0, rdAfter := 1, imm := 4, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 10, stepIndex := 10, sequenceIndex := 0, pc := 40, opcode := .sltu, traceOpcode := (some .sltu), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 2, archRs1Value := 3, archRs2 := 1, archRs2Value := 5, archRd := 11, archRdBefore := 0, archImm := 0, rs1 := 2, rs1Value := 3, rs2 := 1, rs2Value := 5, rd := 11, rdBefore := 0, rdAfter := 1, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 11, stepIndex := 11, sequenceIndex := 0, pc := 44, opcode := .sltiu, traceOpcode := (some .sltiu), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 1, archRs1Value := 5, archRs2 := 0, archRs2Value := 0, archRd := 12, archRdBefore := 0, archImm := 4, rs1 := 1, rs1Value := 5, rs2 := 0, rs2Value := 0, rd := 12, rdBefore := 0, rdAfter := 0, imm := 4, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 12, stepIndex := 12, sequenceIndex := 0, pc := 48, opcode := .fence, traceOpcode := (some .fence), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 0, archRdBefore := 0, archImm := 0, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 0, rdBefore := 0, rdAfter := 0, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := false, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 13, stepIndex := 13, sequenceIndex := 0, pc := 52, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 0, archRdBefore := 0, archImm := 0, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 0, rdBefore := 0, rdAfter := 0, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := false, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }]

def stage1RowBindings : List Stage1RowBindingView :=
  [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 5243027, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 4, aluResult := 5, effectiveAddr := none, writesRd := true, rd := 1, rdAfter := 5, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 3146003, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 8, aluResult := 3, effectiveAddr := none, writesRd := true, rd := 2, rdAfter := 3, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 2159027, opcode := .and, traceOpcode := (some .and), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 12, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 3, rdAfter := 1, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 12, fetchedWord := 6353427, opcode := .andi, traceOpcode := (some .andi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 16, aluResult := 4, effectiveAddr := none, writesRd := true, rd := 4, rdAfter := 4, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 4, stepIndex := 4, sequenceIndex := 0, fetchPc := 16, fetchedWord := 2155187, opcode := .or, traceOpcode := (some .or), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 20, aluResult := 7, effectiveAddr := none, writesRd := true, rd := 5, rdAfter := 7, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 5, stepIndex := 5, sequenceIndex := 0, fetchPc := 20, fetchedWord := 8479507, opcode := .ori, traceOpcode := (some .ori), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 24, aluResult := 11, effectiveAddr := none, writesRd := true, rd := 6, rdAfter := 11, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 6, stepIndex := 6, sequenceIndex := 0, fetchPc := 24, fetchedWord := 2147251, opcode := .xor, traceOpcode := (some .xor), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 28, aluResult := 6, effectiveAddr := none, writesRd := true, rd := 7, rdAfter := 6, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 7, stepIndex := 7, sequenceIndex := 0, fetchPc := 28, fetchedWord := 7390227, opcode := .xori, traceOpcode := (some .xori), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 32, aluResult := 2, effectiveAddr := none, writesRd := true, rd := 8, rdAfter := 2, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 8, stepIndex := 8, sequenceIndex := 0, fetchPc := 32, fetchedWord := 1123507, opcode := .slt, traceOpcode := (some .slt), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 36, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 9, rdAfter := 1, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 9, stepIndex := 9, sequenceIndex := 0, fetchPc := 36, fetchedWord := 4269331, opcode := .slti, traceOpcode := (some .slti), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 40, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 10, rdAfter := 1, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 10, stepIndex := 10, sequenceIndex := 0, fetchPc := 40, fetchedWord := 1127859, opcode := .sltu, traceOpcode := (some .sltu), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 44, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 11, rdAfter := 1, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 11, stepIndex := 11, sequenceIndex := 0, fetchPc := 44, fetchedWord := 4240915, opcode := .sltiu, traceOpcode := (some .sltiu), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 48, aluResult := 0, effectiveAddr := none, writesRd := true, rd := 12, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 12, stepIndex := 12, sequenceIndex := 0, fetchPc := 48, fetchedWord := 15, opcode := .fence, traceOpcode := (some .fence), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 52, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }, { traceIndex := 13, stepIndex := 13, sequenceIndex := 0, fetchPc := 52, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 56, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }]

def stage1 : Stage1ProofBundleView :=
  {
    semInputs := stage1SemInputs
    , rowBindings := stage1RowBindings
    , bytecodeDigest := (bytes [92, 105, 117, 168, 183, 172, 41, 194, 86, 55, 182, 227, 251, 76, 34, 211, 136, 118, 175, 162, 59, 153, 240, 238, 44, 117, 185, 165, 10, 156, 50, 71])
    , aluDigest := (bytes [100, 15, 171, 246, 81, 103, 52, 53, 177, 194, 161, 204, 7, 128, 142, 137, 250, 13, 9, 53, 4, 254, 73, 130, 181, 140, 155, 87, 205, 157, 152, 155])
    , branchDigest := (bytes [190, 59, 61, 179, 41, 162, 65, 117, 130, 28, 34, 96, 199, 221, 230, 149, 106, 64, 165, 152, 36, 247, 227, 215, 86, 170, 239, 221, 224, 219, 200, 147])
    , semantics := { semInputsDigest := (bytes [203, 154, 231, 59, 113, 218, 186, 163, 38, 154, 225, 225, 115, 81, 116, 56, 100, 219, 241, 89, 171, 145, 219, 229, 0, 3, 198, 204, 187, 62, 144, 41]), rowBindingsDigest := (bytes [172, 82, 4, 10, 207, 192, 229, 24, 219, 164, 175, 254, 23, 245, 152, 230, 241, 29, 90, 128, 59, 105, 192, 142, 31, 29, 162, 29, 164, 173, 205, 68]), sequenceCount := 14, helperRowCount := 0, digest := (bytes [201, 82, 248, 5, 165, 255, 118, 9, 193, 52, 162, 52, 136, 212, 17, 253, 69, 170, 62, 206, 248, 48, 102, 43, 176, 51, 60, 231, 68, 100, 197, 230]) }
    , addressCorrectnessDigest := (bytes [188, 168, 231, 165, 204, 58, 155, 24, 180, 72, 47, 45, 227, 234, 236, 73, 182, 39, 254, 205, 87, 182, 26, 165, 207, 116, 191, 102, 79, 25, 232, 124])
    , linkageDigest := (bytes [198, 58, 151, 214, 160, 251, 202, 94, 102, 103, 87, 92, 52, 12, 70, 158, 29, 126, 200, 191, 223, 87, 69, 150, 250, 241, 192, 184, 199, 215, 198, 79])
    , selectedOpening := { claim := { rowsFamilyDigest := (bytes [172, 82, 4, 10, 207, 192, 229, 24, 219, 164, 175, 254, 23, 245, 152, 230, 241, 29, 90, 128, 59, 105, 192, 142, 31, 29, 162, 29, 164, 173, 205, 68]), rowCount := 14, effectRowCount := 14, commitRowCount := 14, realRowCount := 14, preservesX0Count := 2, firstTraceIndex := 0, effectTraceIndex := 0, commitTraceIndex := 0, lastTraceIndex := 13, mix := 3705222010059132808, points := { first := { id := { object := { familyTag := 1, commitmentDigest := (bytes [172, 82, 4, 10, 207, 192, 229, 24, 219, 164, 175, 254, 23, 245, 152, 230, 241, 29, 90, 128, 59, 105, 192, 142, 31, 29, 162, 29, 164, 173, 205, 68]), layoutVersion := 1, digest := (bytes [175, 188, 209, 46, 10, 19, 142, 241, 7, 222, 213, 151, 88, 245, 66, 14, 239, 161, 204, 119, 191, 36, 176, 90, 239, 200, 213, 198, 232, 97, 207, 182]) }, logicalIndex := 0, digest := (bytes [70, 140, 54, 73, 38, 204, 209, 222, 228, 139, 70, 117, 3, 243, 60, 80, 34, 33, 113, 15, 234, 178, 105, 97, 64, 128, 127, 11, 86, 18, 117, 65]) }, valueDigest := (bytes [192, 39, 142, 151, 135, 172, 252, 135, 48, 191, 234, 37, 159, 235, 250, 50, 196, 251, 127, 61, 53, 90, 170, 88, 94, 40, 229, 126, 104, 90, 79, 155]), digest := (bytes [118, 162, 30, 209, 13, 252, 154, 207, 253, 207, 45, 40, 219, 231, 207, 55, 135, 201, 229, 40, 240, 153, 192, 121, 164, 49, 146, 175, 71, 126, 130, 27]) }, effect := { id := { object := { familyTag := 1, commitmentDigest := (bytes [172, 82, 4, 10, 207, 192, 229, 24, 219, 164, 175, 254, 23, 245, 152, 230, 241, 29, 90, 128, 59, 105, 192, 142, 31, 29, 162, 29, 164, 173, 205, 68]), layoutVersion := 1, digest := (bytes [175, 188, 209, 46, 10, 19, 142, 241, 7, 222, 213, 151, 88, 245, 66, 14, 239, 161, 204, 119, 191, 36, 176, 90, 239, 200, 213, 198, 232, 97, 207, 182]) }, logicalIndex := 0, digest := (bytes [70, 140, 54, 73, 38, 204, 209, 222, 228, 139, 70, 117, 3, 243, 60, 80, 34, 33, 113, 15, 234, 178, 105, 97, 64, 128, 127, 11, 86, 18, 117, 65]) }, valueDigest := (bytes [192, 39, 142, 151, 135, 172, 252, 135, 48, 191, 234, 37, 159, 235, 250, 50, 196, 251, 127, 61, 53, 90, 170, 88, 94, 40, 229, 126, 104, 90, 79, 155]), digest := (bytes [118, 162, 30, 209, 13, 252, 154, 207, 253, 207, 45, 40, 219, 231, 207, 55, 135, 201, 229, 40, 240, 153, 192, 121, 164, 49, 146, 175, 71, 126, 130, 27]) }, commit := { id := { object := { familyTag := 1, commitmentDigest := (bytes [172, 82, 4, 10, 207, 192, 229, 24, 219, 164, 175, 254, 23, 245, 152, 230, 241, 29, 90, 128, 59, 105, 192, 142, 31, 29, 162, 29, 164, 173, 205, 68]), layoutVersion := 1, digest := (bytes [175, 188, 209, 46, 10, 19, 142, 241, 7, 222, 213, 151, 88, 245, 66, 14, 239, 161, 204, 119, 191, 36, 176, 90, 239, 200, 213, 198, 232, 97, 207, 182]) }, logicalIndex := 0, digest := (bytes [70, 140, 54, 73, 38, 204, 209, 222, 228, 139, 70, 117, 3, 243, 60, 80, 34, 33, 113, 15, 234, 178, 105, 97, 64, 128, 127, 11, 86, 18, 117, 65]) }, valueDigest := (bytes [192, 39, 142, 151, 135, 172, 252, 135, 48, 191, 234, 37, 159, 235, 250, 50, 196, 251, 127, 61, 53, 90, 170, 88, 94, 40, 229, 126, 104, 90, 79, 155]), digest := (bytes [118, 162, 30, 209, 13, 252, 154, 207, 253, 207, 45, 40, 219, 231, 207, 55, 135, 201, 229, 40, 240, 153, 192, 121, 164, 49, 146, 175, 71, 126, 130, 27]) }, last := { id := { object := { familyTag := 1, commitmentDigest := (bytes [172, 82, 4, 10, 207, 192, 229, 24, 219, 164, 175, 254, 23, 245, 152, 230, 241, 29, 90, 128, 59, 105, 192, 142, 31, 29, 162, 29, 164, 173, 205, 68]), layoutVersion := 1, digest := (bytes [175, 188, 209, 46, 10, 19, 142, 241, 7, 222, 213, 151, 88, 245, 66, 14, 239, 161, 204, 119, 191, 36, 176, 90, 239, 200, 213, 198, 232, 97, 207, 182]) }, logicalIndex := 13, digest := (bytes [30, 44, 141, 145, 253, 59, 130, 31, 149, 239, 121, 115, 148, 246, 103, 200, 190, 85, 187, 233, 202, 246, 107, 135, 18, 152, 200, 189, 96, 104, 254, 141]) }, valueDigest := (bytes [190, 173, 150, 74, 224, 14, 231, 215, 156, 131, 101, 243, 106, 118, 153, 86, 24, 126, 110, 109, 7, 118, 176, 189, 100, 128, 96, 65, 75, 179, 168, 117]), digest := (bytes [42, 97, 247, 232, 101, 37, 253, 201, 5, 7, 104, 116, 115, 119, 75, 95, 29, 226, 69, 107, 24, 186, 14, 229, 75, 243, 60, 205, 156, 21, 183, 201]) } }, digest := (bytes [2, 255, 133, 183, 3, 188, 244, 55, 187, 122, 4, 215, 185, 217, 13, 234, 61, 25, 12, 55, 117, 22, 153, 85, 246, 35, 208, 70, 159, 22, 71, 99]) }, packaged := { statementDigest := (bytes [214, 79, 103, 183, 146, 21, 137, 47, 239, 38, 167, 85, 13, 7, 178, 135, 35, 223, 112, 247, 194, 5, 83, 125, 155, 62, 159, 110, 130, 31, 208, 22]), proofDigest := (bytes [34, 34, 82, 183, 63, 193, 148, 201, 93, 153, 36, 10, 202, 206, 104, 100, 151, 41, 56, 172, 187, 49, 85, 144, 193, 120, 28, 77, 9, 149, 158, 240]) }, digest := (bytes [51, 63, 211, 186, 53, 109, 214, 181, 53, 47, 220, 172, 153, 111, 64, 147, 58, 164, 115, 119, 49, 122, 105, 76, 55, 28, 186, 147, 134, 23, 195, 34]) }
    , digest := (bytes [233, 187, 57, 237, 46, 224, 25, 209, 18, 185, 239, 135, 54, 126, 141, 80, 26, 108, 77, 67, 120, 106, 159, 58, 88, 6, 198, 50, 209, 110, 143, 158])
  }

def stage2RegisterReads : List RegisterReadEventView :=
  [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 0, value := 0 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 0, value := 0 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 1, value := 5 }, { traceIndex := 2, stepIndex := 2, role := .rs2, reg := 2, value := 3 }, { traceIndex := 3, stepIndex := 3, role := .rs1, reg := 1, value := 5 }, { traceIndex := 4, stepIndex := 4, role := .rs1, reg := 1, value := 5 }, { traceIndex := 4, stepIndex := 4, role := .rs2, reg := 2, value := 3 }, { traceIndex := 5, stepIndex := 5, role := .rs1, reg := 2, value := 3 }, { traceIndex := 6, stepIndex := 6, role := .rs1, reg := 1, value := 5 }, { traceIndex := 6, stepIndex := 6, role := .rs2, reg := 2, value := 3 }, { traceIndex := 7, stepIndex := 7, role := .rs1, reg := 1, value := 5 }, { traceIndex := 8, stepIndex := 8, role := .rs1, reg := 2, value := 3 }, { traceIndex := 8, stepIndex := 8, role := .rs2, reg := 1, value := 5 }, { traceIndex := 9, stepIndex := 9, role := .rs1, reg := 2, value := 3 }, { traceIndex := 10, stepIndex := 10, role := .rs1, reg := 2, value := 3 }, { traceIndex := 10, stepIndex := 10, role := .rs2, reg := 1, value := 5 }, { traceIndex := 11, stepIndex := 11, role := .rs1, reg := 1, value := 5 }]

def stage2RegisterWrites : List RegisterWriteEventView :=
  [{ traceIndex := 0, stepIndex := 0, reg := 1, previous := 0, next := 5 }, { traceIndex := 1, stepIndex := 1, reg := 2, previous := 0, next := 3 }, { traceIndex := 2, stepIndex := 2, reg := 3, previous := 0, next := 1 }, { traceIndex := 3, stepIndex := 3, reg := 4, previous := 0, next := 4 }, { traceIndex := 4, stepIndex := 4, reg := 5, previous := 0, next := 7 }, { traceIndex := 5, stepIndex := 5, reg := 6, previous := 0, next := 11 }, { traceIndex := 6, stepIndex := 6, reg := 7, previous := 0, next := 6 }, { traceIndex := 7, stepIndex := 7, reg := 8, previous := 0, next := 2 }, { traceIndex := 8, stepIndex := 8, reg := 9, previous := 0, next := 1 }, { traceIndex := 9, stepIndex := 9, reg := 10, previous := 0, next := 1 }, { traceIndex := 10, stepIndex := 10, reg := 11, previous := 0, next := 1 }, { traceIndex := 11, stepIndex := 11, reg := 12, previous := 0, next := 0 }]

def stage2RamEvents : List RamEventView :=
  []

def stage2TwistLinks : List TwistLinkEventView :=
  [{ traceIndex := 0, stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 5), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 1, family := .nativeAlu, routedWriteValue := (some 3), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 2, family := .nativeAlu, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 3, family := .nativeAlu, routedWriteValue := (some 4), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 4, stepIndex := 4, family := .nativeAlu, routedWriteValue := (some 7), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 5, stepIndex := 5, family := .nativeAlu, routedWriteValue := (some 11), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 6, stepIndex := 6, family := .nativeAlu, routedWriteValue := (some 6), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 7, stepIndex := 7, family := .nativeAlu, routedWriteValue := (some 2), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 8, stepIndex := 8, family := .nativeAlu, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 9, stepIndex := 9, family := .nativeAlu, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 10, stepIndex := 10, family := .nativeAlu, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 11, stepIndex := 11, family := .nativeAlu, routedWriteValue := (some 0), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 12, stepIndex := 12, family := .nativeAlu, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 13, stepIndex := 13, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]

def stage2 : Stage2ProofBundleView :=
  {
    registerReads := stage2RegisterReads
    , registerWrites := stage2RegisterWrites
    , ramEvents := stage2RamEvents
    , registerDigest := (bytes [160, 20, 169, 205, 224, 71, 192, 14, 94, 88, 40, 212, 125, 164, 169, 252, 69, 207, 125, 13, 115, 249, 217, 250, 171, 212, 69, 20, 222, 203, 221, 251])
    , ramDigest := (bytes [209, 217, 105, 43, 209, 229, 156, 61, 92, 164, 94, 232, 52, 214, 73, 229, 72, 188, 139, 122, 165, 123, 201, 212, 205, 15, 247, 197, 165, 154, 109, 246])
    , temporal := { twistLinks := stage2TwistLinks, registerTimelineDigest := (bytes [159, 117, 247, 88, 178, 8, 192, 42, 84, 200, 194, 171, 33, 214, 244, 74, 84, 98, 146, 183, 36, 72, 132, 164, 139, 88, 66, 93, 43, 240, 101, 195]), ramTimelineDigest := (bytes [8, 117, 17, 140, 128, 180, 240, 140, 250, 181, 90, 134, 147, 17, 197, 122, 220, 8, 66, 15, 193, 254, 11, 122, 115, 210, 233, 239, 55, 132, 31, 228]), twistLinksDigest := (bytes [84, 14, 146, 242, 132, 134, 144, 144, 40, 151, 127, 223, 162, 171, 6, 221, 218, 86, 136, 101, 95, 211, 5, 9, 149, 35, 188, 147, 113, 109, 156, 33]), digest := (bytes [188, 198, 233, 179, 54, 216, 133, 72, 82, 81, 189, 46, 183, 112, 197, 64, 191, 181, 11, 252, 55, 118, 125, 208, 30, 28, 159, 167, 62, 71, 152, 17]) }
    , semantics := { registerReadsFamilyDigest := (bytes [101, 240, 193, 194, 84, 133, 26, 60, 47, 206, 128, 104, 27, 235, 117, 90, 81, 195, 237, 244, 91, 68, 32, 166, 21, 194, 222, 8, 9, 248, 29, 62]), registerWritesFamilyDigest := (bytes [8, 251, 233, 112, 15, 136, 236, 34, 48, 135, 35, 219, 98, 21, 244, 134, 56, 154, 60, 137, 115, 81, 164, 146, 62, 4, 128, 213, 182, 207, 217, 168]), ramEventsFamilyDigest := (bytes [85, 17, 108, 38, 84, 5, 109, 213, 145, 137, 203, 96, 117, 127, 130, 193, 117, 29, 27, 219, 228, 58, 7, 214, 144, 155, 66, 38, 127, 8, 241, 95]), twistLinksFamilyDigest := (bytes [221, 2, 101, 28, 97, 165, 150, 224, 36, 71, 159, 150, 134, 101, 64, 87, 100, 210, 137, 28, 27, 225, 72, 52, 174, 195, 74, 2, 160, 136, 249, 210]), rowCount := 14, registerEventCount := 29, ramEventCount := 0, digest := (bytes [98, 191, 161, 56, 236, 205, 20, 146, 160, 24, 161, 107, 167, 248, 37, 131, 208, 23, 245, 187, 105, 79, 1, 192, 38, 53, 59, 112, 77, 242, 79, 102]) }
    , linkageDigest := (bytes [124, 237, 38, 95, 39, 214, 129, 190, 213, 181, 83, 13, 219, 135, 100, 2, 62, 18, 179, 113, 212, 131, 139, 165, 71, 234, 246, 173, 5, 107, 188, 237])
    , selectedOpening := { claim := { registerReadsFamilyDigest := (bytes [101, 240, 193, 194, 84, 133, 26, 60, 47, 206, 128, 104, 27, 235, 117, 90, 81, 195, 237, 244, 91, 68, 32, 166, 21, 194, 222, 8, 9, 248, 29, 62]), registerWritesFamilyDigest := (bytes [8, 251, 233, 112, 15, 136, 236, 34, 48, 135, 35, 219, 98, 21, 244, 134, 56, 154, 60, 137, 115, 81, 164, 146, 62, 4, 128, 213, 182, 207, 217, 168]), ramEventsFamilyDigest := (bytes [85, 17, 108, 38, 84, 5, 109, 213, 145, 137, 203, 96, 117, 127, 130, 193, 117, 29, 27, 219, 228, 58, 7, 214, 144, 155, 66, 38, 127, 8, 241, 95]), twistLinksFamilyDigest := (bytes [221, 2, 101, 28, 97, 165, 150, 224, 36, 71, 159, 150, 134, 101, 64, 87, 100, 210, 137, 28, 27, 225, 72, 52, 174, 195, 74, 2, 160, 136, 249, 210]), registerReadCount := 17, registerWriteCount := 12, ramEventCount := 0, twistLinkCount := 14, ramReadCount := 0, ramWriteCount := 0, regMix := 7940266179000280847, ramMix := 4123130262336711476, points := { firstRead := (some { id := { object := { familyTag := 2, commitmentDigest := (bytes [101, 240, 193, 194, 84, 133, 26, 60, 47, 206, 128, 104, 27, 235, 117, 90, 81, 195, 237, 244, 91, 68, 32, 166, 21, 194, 222, 8, 9, 248, 29, 62]), layoutVersion := 1, digest := (bytes [57, 180, 169, 181, 245, 69, 87, 146, 90, 31, 175, 91, 95, 113, 95, 45, 41, 36, 38, 28, 107, 170, 190, 196, 169, 136, 214, 197, 191, 103, 6, 156]) }, logicalIndex := 0, digest := (bytes [86, 247, 247, 128, 18, 222, 137, 43, 150, 99, 72, 242, 126, 226, 139, 15, 59, 253, 20, 167, 57, 181, 243, 130, 251, 136, 189, 195, 52, 181, 228, 148]) }, valueDigest := (bytes [165, 2, 50, 180, 56, 84, 68, 13, 37, 136, 82, 191, 49, 42, 150, 67, 180, 45, 199, 251, 168, 91, 53, 39, 20, 9, 70, 46, 155, 135, 100, 116]), digest := (bytes [212, 143, 179, 241, 81, 228, 5, 170, 142, 20, 218, 112, 122, 61, 74, 251, 240, 189, 124, 148, 162, 12, 77, 26, 105, 120, 243, 101, 176, 170, 38, 2]) }), lastRead := (some { id := { object := { familyTag := 2, commitmentDigest := (bytes [101, 240, 193, 194, 84, 133, 26, 60, 47, 206, 128, 104, 27, 235, 117, 90, 81, 195, 237, 244, 91, 68, 32, 166, 21, 194, 222, 8, 9, 248, 29, 62]), layoutVersion := 1, digest := (bytes [57, 180, 169, 181, 245, 69, 87, 146, 90, 31, 175, 91, 95, 113, 95, 45, 41, 36, 38, 28, 107, 170, 190, 196, 169, 136, 214, 197, 191, 103, 6, 156]) }, logicalIndex := 16, digest := (bytes [255, 200, 130, 136, 36, 33, 249, 254, 119, 116, 59, 11, 82, 124, 152, 25, 177, 205, 105, 117, 204, 182, 229, 234, 227, 199, 213, 25, 59, 195, 175, 50]) }, valueDigest := (bytes [182, 85, 19, 87, 241, 132, 237, 190, 14, 70, 204, 21, 148, 159, 63, 190, 147, 77, 41, 138, 40, 47, 252, 19, 167, 87, 86, 49, 44, 122, 213, 184]), digest := (bytes [74, 79, 205, 51, 201, 149, 127, 25, 42, 240, 122, 12, 244, 211, 155, 240, 92, 22, 169, 11, 181, 123, 251, 154, 9, 224, 114, 53, 157, 182, 133, 227]) }), firstWrite := (some { id := { object := { familyTag := 3, commitmentDigest := (bytes [8, 251, 233, 112, 15, 136, 236, 34, 48, 135, 35, 219, 98, 21, 244, 134, 56, 154, 60, 137, 115, 81, 164, 146, 62, 4, 128, 213, 182, 207, 217, 168]), layoutVersion := 1, digest := (bytes [30, 64, 87, 69, 117, 107, 143, 79, 175, 142, 144, 12, 23, 114, 160, 253, 201, 182, 54, 108, 118, 3, 110, 82, 243, 134, 10, 94, 85, 42, 179, 57]) }, logicalIndex := 0, digest := (bytes [88, 159, 227, 26, 157, 63, 61, 195, 87, 110, 236, 87, 137, 154, 139, 65, 244, 98, 131, 218, 121, 142, 21, 143, 217, 132, 91, 154, 61, 1, 12, 200]) }, valueDigest := (bytes [5, 42, 199, 83, 99, 146, 243, 205, 229, 6, 247, 87, 180, 202, 145, 220, 239, 246, 190, 63, 131, 159, 221, 85, 160, 97, 47, 166, 147, 151, 248, 133]), digest := (bytes [29, 204, 162, 250, 247, 144, 253, 39, 20, 41, 81, 252, 193, 24, 198, 248, 198, 56, 102, 255, 228, 239, 204, 238, 58, 168, 238, 132, 71, 99, 8, 174]) }), lastWrite := (some { id := { object := { familyTag := 3, commitmentDigest := (bytes [8, 251, 233, 112, 15, 136, 236, 34, 48, 135, 35, 219, 98, 21, 244, 134, 56, 154, 60, 137, 115, 81, 164, 146, 62, 4, 128, 213, 182, 207, 217, 168]), layoutVersion := 1, digest := (bytes [30, 64, 87, 69, 117, 107, 143, 79, 175, 142, 144, 12, 23, 114, 160, 253, 201, 182, 54, 108, 118, 3, 110, 82, 243, 134, 10, 94, 85, 42, 179, 57]) }, logicalIndex := 11, digest := (bytes [82, 5, 128, 124, 241, 143, 228, 225, 39, 66, 73, 23, 154, 134, 219, 228, 50, 71, 92, 5, 76, 38, 176, 164, 118, 168, 231, 232, 100, 141, 25, 229]) }, valueDigest := (bytes [184, 74, 48, 151, 19, 25, 8, 86, 84, 185, 137, 133, 44, 232, 190, 89, 129, 224, 117, 80, 161, 71, 41, 61, 215, 141, 200, 122, 41, 56, 227, 255]), digest := (bytes [71, 137, 9, 91, 139, 197, 215, 250, 207, 84, 229, 40, 130, 68, 156, 126, 29, 127, 176, 137, 8, 189, 23, 103, 7, 118, 93, 235, 28, 164, 179, 41]) }), firstRam := none, lastRam := none, firstTwist := (some { id := { object := { familyTag := 5, commitmentDigest := (bytes [221, 2, 101, 28, 97, 165, 150, 224, 36, 71, 159, 150, 134, 101, 64, 87, 100, 210, 137, 28, 27, 225, 72, 52, 174, 195, 74, 2, 160, 136, 249, 210]), layoutVersion := 1, digest := (bytes [146, 161, 223, 244, 179, 28, 8, 151, 242, 25, 37, 73, 40, 170, 37, 169, 205, 200, 152, 151, 45, 198, 128, 71, 27, 111, 231, 127, 162, 221, 151, 83]) }, logicalIndex := 0, digest := (bytes [110, 65, 0, 135, 202, 26, 49, 81, 38, 5, 45, 69, 150, 93, 150, 27, 166, 196, 132, 136, 114, 136, 246, 165, 192, 86, 111, 127, 194, 245, 125, 170]) }, valueDigest := (bytes [56, 135, 107, 139, 170, 102, 129, 66, 201, 158, 76, 252, 160, 79, 76, 35, 237, 181, 194, 155, 225, 231, 24, 201, 237, 26, 147, 107, 4, 156, 184, 248]), digest := (bytes [239, 43, 146, 118, 7, 94, 48, 106, 221, 48, 201, 100, 239, 199, 229, 227, 66, 161, 43, 169, 14, 192, 6, 207, 221, 112, 107, 255, 134, 249, 82, 167]) }), lastTwist := (some { id := { object := { familyTag := 5, commitmentDigest := (bytes [221, 2, 101, 28, 97, 165, 150, 224, 36, 71, 159, 150, 134, 101, 64, 87, 100, 210, 137, 28, 27, 225, 72, 52, 174, 195, 74, 2, 160, 136, 249, 210]), layoutVersion := 1, digest := (bytes [146, 161, 223, 244, 179, 28, 8, 151, 242, 25, 37, 73, 40, 170, 37, 169, 205, 200, 152, 151, 45, 198, 128, 71, 27, 111, 231, 127, 162, 221, 151, 83]) }, logicalIndex := 13, digest := (bytes [231, 139, 217, 107, 117, 2, 138, 205, 82, 64, 82, 250, 223, 250, 165, 230, 172, 49, 225, 21, 60, 192, 77, 68, 174, 13, 113, 193, 254, 54, 74, 66]) }, valueDigest := (bytes [109, 85, 127, 58, 138, 204, 130, 29, 47, 151, 126, 241, 206, 114, 17, 14, 82, 170, 10, 250, 114, 72, 146, 233, 60, 135, 172, 178, 178, 252, 230, 146]), digest := (bytes [16, 60, 56, 84, 211, 120, 155, 238, 74, 97, 106, 2, 18, 223, 103, 94, 10, 9, 209, 67, 125, 205, 26, 27, 144, 178, 58, 153, 177, 55, 160, 58]) }) }, digest := (bytes [91, 166, 56, 242, 94, 188, 65, 37, 226, 170, 211, 85, 22, 45, 196, 155, 69, 47, 91, 13, 133, 59, 17, 254, 227, 249, 199, 101, 71, 173, 78, 113]) }, packaged := { statementDigest := (bytes [175, 194, 103, 180, 168, 249, 95, 37, 25, 254, 94, 33, 170, 140, 99, 120, 145, 246, 56, 140, 96, 21, 45, 99, 9, 193, 210, 65, 242, 62, 41, 138]), proofDigest := (bytes [162, 32, 164, 246, 235, 227, 237, 120, 209, 222, 253, 84, 228, 28, 97, 231, 228, 67, 191, 160, 50, 129, 30, 44, 41, 0, 110, 148, 87, 76, 177, 71]) }, digest := (bytes [241, 163, 5, 223, 23, 221, 24, 134, 104, 142, 140, 248, 100, 214, 117, 54, 151, 122, 237, 155, 109, 20, 173, 192, 160, 221, 211, 80, 50, 211, 55, 77]) }
    , digest := (bytes [189, 210, 79, 184, 204, 212, 141, 149, 33, 222, 1, 78, 25, 0, 196, 107, 91, 99, 217, 230, 12, 25, 221, 201, 186, 79, 81, 117, 35, 215, 113, 244])
  }

def stage3Continuity : List ContinuityEventView :=
  [{ stepIndex := 0, pc := 0, nextPc := 4, successorPc := (some 4), finalStep := false, continuityHolds := true }, { stepIndex := 1, pc := 4, nextPc := 8, successorPc := (some 8), finalStep := false, continuityHolds := true }, { stepIndex := 2, pc := 8, nextPc := 12, successorPc := (some 12), finalStep := false, continuityHolds := true }, { stepIndex := 3, pc := 12, nextPc := 16, successorPc := (some 16), finalStep := false, continuityHolds := true }, { stepIndex := 4, pc := 16, nextPc := 20, successorPc := (some 20), finalStep := false, continuityHolds := true }, { stepIndex := 5, pc := 20, nextPc := 24, successorPc := (some 24), finalStep := false, continuityHolds := true }, { stepIndex := 6, pc := 24, nextPc := 28, successorPc := (some 28), finalStep := false, continuityHolds := true }, { stepIndex := 7, pc := 28, nextPc := 32, successorPc := (some 32), finalStep := false, continuityHolds := true }, { stepIndex := 8, pc := 32, nextPc := 36, successorPc := (some 36), finalStep := false, continuityHolds := true }, { stepIndex := 9, pc := 36, nextPc := 40, successorPc := (some 40), finalStep := false, continuityHolds := true }, { stepIndex := 10, pc := 40, nextPc := 44, successorPc := (some 44), finalStep := false, continuityHolds := true }, { stepIndex := 11, pc := 44, nextPc := 48, successorPc := (some 48), finalStep := false, continuityHolds := true }, { stepIndex := 12, pc := 48, nextPc := 52, successorPc := (some 52), finalStep := false, continuityHolds := true }, { stepIndex := 13, pc := 52, nextPc := 56, successorPc := none, finalStep := true, continuityHolds := true }]

def stage3 : Stage3ProofBundleView :=
  {
    continuity := stage3Continuity
    , halted := true
    , bridgeDigest := (bytes [216, 105, 3, 186, 206, 61, 31, 240, 96, 117, 64, 96, 191, 193, 183, 71, 229, 32, 62, 40, 78, 231, 190, 67, 36, 211, 232, 91, 70, 219, 48, 85])
    , semantics := { continuityDigest := (bytes [78, 198, 43, 142, 176, 219, 1, 131, 124, 160, 125, 173, 141, 209, 21, 67, 236, 27, 15, 206, 136, 102, 152, 25, 73, 126, 174, 208, 168, 109, 128, 129]), rootSemanticRowsDigest := (bytes [15, 37, 86, 76, 184, 62, 76, 209, 122, 70, 16, 53, 62, 4, 218, 140, 38, 22, 71, 21, 78, 10, 23, 122, 196, 53, 1, 13, 58, 250, 219, 51]), rowChunkRoutesDigest := (bytes [31, 198, 49, 36, 227, 179, 69, 11, 12, 162, 182, 190, 148, 140, 214, 39, 221, 243, 102, 239, 45, 242, 25, 129, 189, 122, 159, 99, 209, 169, 203, 52]), preparedStepBindingsDigest := (bytes [49, 15, 156, 222, 222, 132, 248, 219, 86, 74, 177, 173, 126, 92, 88, 142, 71, 233, 147, 61, 144, 74, 40, 78, 93, 229, 111, 147, 78, 221, 224, 124]), stage2TemporalDigest := (bytes [188, 198, 233, 179, 54, 216, 133, 72, 82, 81, 189, 46, 183, 112, 197, 64, 191, 181, 11, 252, 55, 118, 125, 208, 30, 28, 159, 167, 62, 71, 152, 17]), initialPc := 0, finalPc := 56, realRowCount := 14, firstRealStepIndex := 0, lastRealStepIndex := 13, digest := (bytes [93, 95, 54, 194, 166, 247, 41, 85, 8, 151, 179, 253, 234, 181, 113, 103, 109, 155, 101, 76, 22, 166, 91, 233, 207, 227, 217, 247, 151, 125, 86, 175]) }
    , linkageDigest := (bytes [66, 55, 42, 131, 130, 13, 52, 57, 86, 125, 0, 213, 177, 236, 84, 157, 20, 30, 245, 139, 155, 223, 167, 232, 147, 230, 2, 113, 48, 60, 217, 50])
    , selectedOpening := { claim := { continuityFamilyDigest := (bytes [196, 122, 177, 171, 225, 179, 3, 92, 41, 244, 68, 233, 146, 27, 15, 77, 22, 8, 56, 26, 133, 179, 240, 241, 18, 131, 97, 24, 197, 104, 220, 165]), continuityCount := 14, finalStepCount := 1, halted := true, allContinuityHold := true, continuityMix := 13522001880879900227, points := { firstContinuity := (some { id := { object := { familyTag := 6, commitmentDigest := (bytes [196, 122, 177, 171, 225, 179, 3, 92, 41, 244, 68, 233, 146, 27, 15, 77, 22, 8, 56, 26, 133, 179, 240, 241, 18, 131, 97, 24, 197, 104, 220, 165]), layoutVersion := 1, digest := (bytes [235, 67, 108, 213, 145, 121, 19, 213, 228, 201, 91, 11, 201, 157, 88, 77, 119, 224, 224, 119, 57, 175, 59, 120, 101, 180, 109, 57, 92, 175, 139, 229]) }, logicalIndex := 0, digest := (bytes [9, 254, 166, 156, 17, 235, 7, 144, 191, 136, 234, 37, 182, 0, 137, 170, 97, 186, 165, 234, 40, 138, 118, 195, 115, 18, 204, 163, 232, 73, 65, 91]) }, valueDigest := (bytes [7, 131, 85, 21, 57, 109, 53, 31, 137, 53, 98, 18, 170, 36, 28, 200, 149, 213, 171, 159, 119, 200, 36, 230, 30, 35, 30, 11, 252, 126, 240, 63]), digest := (bytes [19, 173, 83, 171, 91, 248, 142, 49, 27, 215, 102, 54, 78, 244, 233, 122, 103, 137, 121, 58, 97, 28, 163, 223, 73, 179, 71, 7, 34, 126, 252, 202]) }), lastContinuity := (some { id := { object := { familyTag := 6, commitmentDigest := (bytes [196, 122, 177, 171, 225, 179, 3, 92, 41, 244, 68, 233, 146, 27, 15, 77, 22, 8, 56, 26, 133, 179, 240, 241, 18, 131, 97, 24, 197, 104, 220, 165]), layoutVersion := 1, digest := (bytes [235, 67, 108, 213, 145, 121, 19, 213, 228, 201, 91, 11, 201, 157, 88, 77, 119, 224, 224, 119, 57, 175, 59, 120, 101, 180, 109, 57, 92, 175, 139, 229]) }, logicalIndex := 13, digest := (bytes [2, 184, 157, 237, 110, 232, 208, 231, 163, 137, 133, 108, 130, 52, 254, 160, 44, 92, 99, 17, 29, 86, 36, 253, 18, 183, 41, 168, 122, 32, 113, 94]) }, valueDigest := (bytes [169, 242, 97, 127, 223, 67, 17, 244, 40, 3, 81, 85, 25, 51, 231, 61, 139, 110, 187, 139, 79, 106, 236, 55, 223, 209, 76, 33, 17, 142, 137, 2]), digest := (bytes [252, 4, 83, 125, 191, 97, 31, 25, 83, 174, 56, 55, 69, 150, 193, 88, 111, 150, 56, 238, 180, 37, 153, 72, 99, 231, 159, 22, 251, 234, 147, 167]) }) }, digest := (bytes [136, 210, 196, 45, 147, 120, 177, 177, 162, 157, 10, 130, 72, 124, 55, 133, 217, 71, 200, 97, 53, 7, 213, 101, 101, 179, 125, 244, 1, 165, 129, 79]) }, packaged := { statementDigest := (bytes [105, 42, 211, 91, 75, 112, 213, 126, 134, 249, 195, 66, 65, 209, 228, 204, 230, 14, 16, 42, 145, 193, 224, 236, 28, 23, 131, 51, 86, 193, 247, 244]), proofDigest := (bytes [85, 234, 45, 86, 26, 204, 30, 222, 168, 126, 93, 173, 113, 211, 99, 197, 36, 184, 5, 70, 2, 211, 174, 78, 128, 9, 250, 7, 26, 59, 7, 16]) }, digest := (bytes [185, 92, 17, 202, 45, 12, 222, 226, 100, 195, 61, 245, 228, 18, 236, 184, 35, 105, 128, 226, 194, 228, 196, 136, 241, 250, 141, 81, 14, 6, 246, 103]) }
    , digest := (bytes [48, 100, 153, 26, 18, 99, 180, 51, 91, 198, 152, 115, 177, 164, 71, 172, 101, 120, 195, 30, 58, 172, 240, 16, 141, 226, 11, 46, 153, 76, 62, 44])
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
  , word := 3146003
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
  traceIndex := 2
  , stepIndex := 2
  , sequenceIndex := 0
  , pc := 8
  , nextPc := 12
  , word := 2159027
  , opcode := .and
  , traceOpcode := (some .and)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 5
  , rs2 := 2
  , rs2Value := 3
  , rd := 3
  , rdBefore := 0
  , rdAfter := 1
  , imm := 0
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
  traceIndex := 3
  , stepIndex := 3
  , sequenceIndex := 0
  , pc := 12
  , nextPc := 16
  , word := 6353427
  , opcode := .andi
  , traceOpcode := (some .andi)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 5
  , rs2 := 0
  , rs2Value := 0
  , rd := 4
  , rdBefore := 0
  , rdAfter := 4
  , imm := 6
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
  , word := 2155187
  , opcode := .or
  , traceOpcode := (some .or)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 5
  , rs2 := 2
  , rs2Value := 3
  , rd := 5
  , rdBefore := 0
  , rdAfter := 7
  , imm := 0
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
  traceIndex := 5
  , stepIndex := 5
  , sequenceIndex := 0
  , pc := 20
  , nextPc := 24
  , word := 8479507
  , opcode := .ori
  , traceOpcode := (some .ori)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 2
  , rs1Value := 3
  , rs2 := 0
  , rs2Value := 0
  , rd := 6
  , rdBefore := 0
  , rdAfter := 11
  , imm := 8
  , aluResult := 11
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
  , word := 2147251
  , opcode := .xor
  , traceOpcode := (some .xor)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 5
  , rs2 := 2
  , rs2Value := 3
  , rd := 7
  , rdBefore := 0
  , rdAfter := 6
  , imm := 0
  , aluResult := 6
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
  , word := 7390227
  , opcode := .xori
  , traceOpcode := (some .xori)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 5
  , rs2 := 0
  , rs2Value := 0
  , rd := 8
  , rdBefore := 0
  , rdAfter := 2
  , imm := 7
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
  , word := 1123507
  , opcode := .slt
  , traceOpcode := (some .slt)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 2
  , rs1Value := 3
  , rs2 := 1
  , rs2Value := 5
  , rd := 9
  , rdBefore := 0
  , rdAfter := 1
  , imm := 0
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
  traceIndex := 9
  , stepIndex := 9
  , sequenceIndex := 0
  , pc := 36
  , nextPc := 40
  , word := 4269331
  , opcode := .slti
  , traceOpcode := (some .slti)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 2
  , rs1Value := 3
  , rs2 := 0
  , rs2Value := 0
  , rd := 10
  , rdBefore := 0
  , rdAfter := 1
  , imm := 4
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
  traceIndex := 10
  , stepIndex := 10
  , sequenceIndex := 0
  , pc := 40
  , nextPc := 44
  , word := 1127859
  , opcode := .sltu
  , traceOpcode := (some .sltu)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 2
  , rs1Value := 3
  , rs2 := 1
  , rs2Value := 5
  , rd := 11
  , rdBefore := 0
  , rdAfter := 1
  , imm := 0
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
  traceIndex := 11
  , stepIndex := 11
  , sequenceIndex := 0
  , pc := 44
  , nextPc := 48
  , word := 4240915
  , opcode := .sltiu
  , traceOpcode := (some .sltiu)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 5
  , rs2 := 0
  , rs2Value := 0
  , rd := 12
  , rdBefore := 0
  , rdAfter := 0
  , imm := 4
  , aluResult := 0
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
  traceIndex := 12
  , stepIndex := 12
  , sequenceIndex := 0
  , pc := 48
  , nextPc := 52
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
  traceIndex := 13
  , stepIndex := 13
  , sequenceIndex := 0
  , pc := 52
  , nextPc := 56
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
  [{ traceIndex := 0, values := [1, 0, 0, 4, 0, 0, 0, 0, 0, 5, 0, 5, 0, 5, 0, 4, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [195, 104, 190, 242, 104, 180, 234, 122, 108, 245, 168, 232, 122, 59, 5, 141, 148, 97, 161, 16, 201, 133, 162, 230, 49, 127, 153, 215, 226, 163, 192, 66]), digest := (bytes [6, 140, 16, 12, 199, 169, 215, 123, 74, 92, 71, 171, 180, 226, 130, 112, 18, 207, 109, 194, 34, 121, 220, 17, 87, 27, 107, 102, 161, 141, 105, 55]) }, { traceIndex := 1, values := [1, 4, 0, 8, 0, 0, 0, 0, 0, 3, 0, 3, 0, 3, 0, 8, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [255, 201, 197, 212, 64, 166, 182, 76, 81, 47, 124, 75, 61, 223, 48, 19, 162, 79, 168, 42, 166, 188, 10, 106, 49, 98, 183, 23, 120, 205, 209, 2]), digest := (bytes [212, 234, 171, 12, 138, 31, 235, 104, 223, 43, 50, 208, 126, 84, 222, 180, 169, 114, 131, 188, 138, 229, 223, 12, 193, 251, 115, 200, 157, 181, 189, 68]) }, { traceIndex := 2, values := [1, 8, 0, 12, 0, 5, 0, 3, 0, 1, 0, 0, 0, 1, 0, 12, 0, 0, 0, 0, 0, 0, 0, 3, 1, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1], rowDigest := (bytes [43, 97, 198, 200, 196, 33, 6, 248, 154, 21, 120, 232, 168, 61, 73, 236, 166, 29, 136, 111, 34, 116, 110, 221, 60, 152, 180, 57, 161, 195, 47, 155]), digest := (bytes [143, 174, 144, 2, 114, 141, 158, 207, 93, 155, 18, 77, 195, 219, 175, 75, 61, 184, 241, 236, 221, 230, 124, 148, 80, 123, 67, 172, 189, 20, 95, 175]) }, { traceIndex := 3, values := [1, 12, 0, 16, 0, 5, 0, 0, 0, 4, 0, 6, 0, 4, 0, 16, 0, 0, 0, 0, 0, 0, 0, 4, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [163, 225, 178, 19, 58, 48, 97, 124, 97, 23, 58, 2, 181, 204, 114, 203, 155, 228, 110, 241, 176, 250, 4, 4, 106, 132, 114, 179, 90, 133, 250, 237]), digest := (bytes [124, 197, 201, 222, 187, 124, 142, 159, 235, 180, 93, 224, 158, 198, 126, 167, 213, 0, 20, 91, 147, 228, 248, 205, 205, 240, 39, 137, 20, 159, 139, 72]) }, { traceIndex := 4, values := [1, 16, 0, 20, 0, 5, 0, 3, 0, 7, 0, 0, 0, 7, 0, 20, 0, 0, 0, 0, 0, 0, 0, 5, 1, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1], rowDigest := (bytes [116, 93, 115, 58, 78, 116, 192, 52, 235, 188, 139, 103, 124, 214, 229, 219, 147, 116, 97, 59, 34, 241, 239, 38, 195, 231, 247, 216, 20, 165, 247, 63]), digest := (bytes [134, 232, 118, 108, 235, 145, 215, 226, 99, 28, 180, 96, 173, 165, 154, 156, 251, 90, 125, 111, 18, 71, 67, 106, 12, 61, 90, 87, 52, 108, 122, 170]) }, { traceIndex := 5, values := [1, 20, 0, 24, 0, 3, 0, 0, 0, 11, 0, 8, 0, 11, 0, 24, 0, 0, 0, 0, 0, 0, 0, 6, 2, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [117, 193, 90, 184, 146, 69, 205, 172, 50, 151, 22, 223, 182, 77, 255, 5, 41, 81, 131, 228, 238, 238, 87, 229, 11, 149, 164, 30, 207, 248, 49, 59]), digest := (bytes [1, 222, 94, 42, 141, 75, 176, 174, 49, 99, 145, 41, 227, 36, 61, 154, 137, 128, 52, 221, 212, 121, 70, 121, 204, 191, 28, 132, 60, 67, 7, 52]) }, { traceIndex := 6, values := [1, 24, 0, 28, 0, 5, 0, 3, 0, 6, 0, 0, 0, 6, 0, 28, 0, 0, 0, 0, 0, 0, 0, 7, 1, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1], rowDigest := (bytes [1, 82, 142, 23, 161, 157, 226, 140, 168, 11, 192, 13, 170, 139, 178, 96, 240, 231, 250, 48, 217, 159, 217, 248, 158, 118, 86, 166, 84, 16, 126, 15]), digest := (bytes [196, 228, 114, 137, 124, 179, 131, 72, 123, 208, 213, 20, 87, 7, 240, 57, 166, 235, 182, 255, 154, 80, 91, 226, 140, 225, 165, 194, 8, 160, 176, 237]) }, { traceIndex := 7, values := [1, 28, 0, 32, 0, 5, 0, 0, 0, 2, 0, 7, 0, 2, 0, 32, 0, 0, 0, 0, 0, 0, 0, 8, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [134, 88, 202, 229, 168, 7, 59, 55, 233, 243, 248, 179, 213, 137, 140, 58, 189, 5, 172, 233, 177, 182, 77, 182, 146, 41, 193, 56, 120, 67, 72, 54]), digest := (bytes [97, 130, 128, 50, 86, 229, 199, 63, 193, 230, 206, 148, 107, 201, 255, 33, 159, 56, 34, 239, 190, 21, 95, 199, 49, 12, 124, 62, 47, 219, 39, 168]) }, { traceIndex := 8, values := [1, 32, 0, 36, 0, 3, 0, 5, 0, 1, 0, 0, 0, 1, 0, 36, 0, 0, 0, 0, 0, 0, 0, 9, 2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1], rowDigest := (bytes [230, 234, 199, 45, 183, 197, 205, 237, 117, 182, 198, 245, 169, 173, 243, 207, 36, 58, 35, 202, 135, 232, 50, 12, 5, 116, 12, 188, 28, 173, 54, 250]), digest := (bytes [51, 233, 47, 176, 156, 165, 248, 137, 237, 135, 217, 194, 3, 53, 208, 117, 57, 3, 160, 62, 220, 38, 21, 228, 79, 126, 231, 232, 228, 224, 168, 90]) }, { traceIndex := 9, values := [1, 36, 0, 40, 0, 3, 0, 0, 0, 1, 0, 4, 0, 1, 0, 40, 0, 0, 0, 0, 0, 0, 0, 10, 2, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [17, 205, 99, 232, 149, 39, 125, 122, 177, 225, 225, 205, 61, 116, 214, 23, 107, 41, 201, 95, 182, 150, 66, 19, 72, 208, 17, 211, 166, 126, 147, 63]), digest := (bytes [23, 92, 139, 48, 198, 233, 92, 148, 204, 88, 10, 243, 213, 70, 32, 88, 240, 237, 194, 45, 210, 179, 200, 111, 88, 97, 89, 95, 246, 86, 254, 61]) }, { traceIndex := 10, values := [1, 40, 0, 44, 0, 3, 0, 5, 0, 1, 0, 0, 0, 1, 0, 44, 0, 0, 0, 0, 0, 0, 0, 11, 2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1], rowDigest := (bytes [154, 226, 191, 230, 117, 41, 86, 104, 178, 93, 26, 206, 239, 63, 72, 12, 232, 145, 240, 109, 229, 31, 201, 34, 230, 56, 165, 183, 11, 83, 106, 12]), digest := (bytes [60, 113, 103, 227, 170, 254, 242, 238, 206, 225, 169, 158, 202, 48, 22, 168, 138, 174, 51, 105, 1, 215, 14, 144, 28, 196, 105, 76, 169, 93, 34, 187]) }, { traceIndex := 11, values := [1, 44, 0, 48, 0, 5, 0, 0, 0, 0, 0, 4, 0, 0, 0, 48, 0, 0, 0, 0, 0, 0, 0, 12, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [117, 13, 26, 42, 62, 227, 191, 149, 225, 150, 206, 189, 253, 211, 23, 67, 182, 48, 36, 204, 211, 120, 157, 255, 102, 75, 77, 178, 205, 20, 147, 42]), digest := (bytes [254, 201, 249, 172, 246, 249, 56, 48, 43, 154, 74, 78, 63, 77, 23, 138, 109, 230, 196, 56, 250, 31, 39, 48, 18, 101, 114, 121, 63, 214, 175, 39]) }, { traceIndex := 12, values := [1, 48, 0, 52, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 52, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [91, 220, 3, 182, 115, 135, 173, 198, 2, 58, 135, 90, 194, 100, 227, 62, 80, 155, 255, 171, 85, 235, 51, 190, 217, 19, 234, 57, 128, 112, 68, 58]), digest := (bytes [74, 253, 244, 230, 48, 15, 119, 37, 184, 207, 6, 3, 154, 36, 2, 70, 57, 102, 76, 29, 117, 79, 248, 10, 5, 24, 188, 15, 199, 204, 218, 109]) }, { traceIndex := 13, values := [1, 52, 0, 56, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 56, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [228, 218, 132, 173, 40, 175, 163, 113, 77, 51, 14, 129, 172, 72, 64, 113, 166, 5, 209, 86, 65, 181, 139, 164, 241, 195, 58, 252, 148, 133, 40, 21]), digest := (bytes [151, 239, 244, 235, 40, 49, 123, 67, 148, 116, 73, 209, 72, 190, 170, 68, 89, 250, 89, 157, 238, 251, 139, 18, 200, 162, 217, 58, 56, 15, 0, 154]) }]

def rootExecutionPreparedBindings : List PreparedStepBindingView :=
  [{ traceIndex := 0, rowDigest := (bytes [195, 104, 190, 242, 104, 180, 234, 122, 108, 245, 168, 232, 122, 59, 5, 141, 148, 97, 161, 16, 201, 133, 162, 230, 49, 127, 153, 215, 226, 163, 192, 66]), rowOpeningDigest := (bytes [229, 44, 46, 216, 109, 204, 220, 233, 58, 5, 59, 127, 77, 57, 93, 180, 92, 174, 71, 184, 220, 8, 113, 222, 241, 157, 184, 161, 240, 199, 81, 75]), digest := (bytes [21, 175, 100, 171, 175, 91, 213, 179, 96, 169, 117, 230, 223, 52, 10, 73, 248, 8, 221, 2, 87, 30, 20, 63, 76, 181, 185, 91, 83, 60, 174, 36]) }, { traceIndex := 1, rowDigest := (bytes [255, 201, 197, 212, 64, 166, 182, 76, 81, 47, 124, 75, 61, 223, 48, 19, 162, 79, 168, 42, 166, 188, 10, 106, 49, 98, 183, 23, 120, 205, 209, 2]), rowOpeningDigest := (bytes [184, 162, 231, 237, 163, 136, 137, 106, 131, 70, 198, 245, 54, 42, 25, 42, 191, 97, 122, 181, 126, 231, 241, 76, 86, 142, 162, 180, 214, 4, 136, 248]), digest := (bytes [96, 86, 224, 184, 79, 73, 28, 38, 18, 40, 125, 32, 196, 239, 124, 59, 39, 246, 124, 222, 225, 27, 121, 167, 51, 129, 194, 121, 176, 20, 74, 122]) }, { traceIndex := 2, rowDigest := (bytes [43, 97, 198, 200, 196, 33, 6, 248, 154, 21, 120, 232, 168, 61, 73, 236, 166, 29, 136, 111, 34, 116, 110, 221, 60, 152, 180, 57, 161, 195, 47, 155]), rowOpeningDigest := (bytes [161, 118, 157, 139, 146, 94, 38, 121, 93, 46, 63, 58, 101, 112, 186, 7, 163, 191, 93, 204, 214, 192, 98, 52, 208, 218, 239, 49, 232, 103, 178, 50]), digest := (bytes [113, 219, 248, 71, 109, 99, 87, 81, 169, 131, 50, 3, 164, 169, 234, 222, 154, 166, 242, 7, 39, 95, 125, 164, 194, 157, 218, 186, 176, 212, 59, 24]) }, { traceIndex := 3, rowDigest := (bytes [163, 225, 178, 19, 58, 48, 97, 124, 97, 23, 58, 2, 181, 204, 114, 203, 155, 228, 110, 241, 176, 250, 4, 4, 106, 132, 114, 179, 90, 133, 250, 237]), rowOpeningDigest := (bytes [38, 151, 118, 2, 51, 123, 153, 40, 117, 184, 7, 99, 164, 227, 108, 171, 204, 181, 184, 229, 218, 11, 129, 91, 25, 197, 210, 53, 245, 96, 16, 153]), digest := (bytes [239, 3, 69, 143, 141, 124, 191, 59, 172, 135, 239, 142, 166, 143, 76, 203, 182, 252, 172, 208, 174, 66, 122, 60, 144, 144, 105, 48, 75, 184, 138, 155]) }, { traceIndex := 4, rowDigest := (bytes [116, 93, 115, 58, 78, 116, 192, 52, 235, 188, 139, 103, 124, 214, 229, 219, 147, 116, 97, 59, 34, 241, 239, 38, 195, 231, 247, 216, 20, 165, 247, 63]), rowOpeningDigest := (bytes [131, 167, 61, 216, 129, 171, 105, 43, 177, 40, 170, 75, 227, 42, 174, 48, 237, 218, 241, 112, 22, 144, 101, 119, 30, 34, 0, 63, 229, 155, 175, 122]), digest := (bytes [209, 212, 54, 96, 113, 176, 142, 154, 177, 177, 207, 94, 91, 86, 140, 77, 187, 102, 251, 177, 232, 173, 219, 248, 158, 195, 180, 183, 12, 11, 101, 189]) }, { traceIndex := 5, rowDigest := (bytes [117, 193, 90, 184, 146, 69, 205, 172, 50, 151, 22, 223, 182, 77, 255, 5, 41, 81, 131, 228, 238, 238, 87, 229, 11, 149, 164, 30, 207, 248, 49, 59]), rowOpeningDigest := (bytes [194, 252, 212, 171, 86, 244, 243, 77, 202, 227, 107, 199, 29, 227, 93, 43, 147, 8, 115, 25, 228, 147, 140, 142, 172, 167, 36, 59, 68, 150, 88, 54]), digest := (bytes [244, 206, 29, 64, 176, 203, 110, 15, 213, 33, 113, 68, 248, 100, 140, 132, 79, 111, 133, 168, 14, 227, 204, 244, 9, 120, 21, 43, 100, 161, 230, 132]) }, { traceIndex := 6, rowDigest := (bytes [1, 82, 142, 23, 161, 157, 226, 140, 168, 11, 192, 13, 170, 139, 178, 96, 240, 231, 250, 48, 217, 159, 217, 248, 158, 118, 86, 166, 84, 16, 126, 15]), rowOpeningDigest := (bytes [106, 57, 237, 57, 64, 132, 72, 116, 221, 156, 167, 78, 49, 199, 106, 217, 147, 49, 12, 167, 61, 98, 209, 188, 159, 229, 37, 207, 106, 81, 239, 139]), digest := (bytes [88, 249, 121, 137, 204, 253, 113, 186, 77, 92, 221, 125, 9, 197, 35, 37, 133, 228, 252, 77, 155, 229, 144, 126, 45, 132, 169, 214, 20, 222, 229, 5]) }, { traceIndex := 7, rowDigest := (bytes [134, 88, 202, 229, 168, 7, 59, 55, 233, 243, 248, 179, 213, 137, 140, 58, 189, 5, 172, 233, 177, 182, 77, 182, 146, 41, 193, 56, 120, 67, 72, 54]), rowOpeningDigest := (bytes [197, 18, 3, 133, 235, 245, 102, 157, 86, 149, 144, 80, 131, 49, 119, 183, 244, 83, 17, 22, 247, 160, 219, 219, 213, 176, 156, 14, 223, 109, 16, 52]), digest := (bytes [240, 165, 223, 191, 230, 87, 180, 189, 148, 153, 196, 10, 213, 244, 214, 217, 117, 100, 37, 86, 3, 164, 101, 92, 122, 53, 102, 247, 23, 169, 192, 139]) }, { traceIndex := 8, rowDigest := (bytes [230, 234, 199, 45, 183, 197, 205, 237, 117, 182, 198, 245, 169, 173, 243, 207, 36, 58, 35, 202, 135, 232, 50, 12, 5, 116, 12, 188, 28, 173, 54, 250]), rowOpeningDigest := (bytes [99, 34, 12, 104, 82, 152, 197, 102, 84, 141, 202, 124, 27, 96, 246, 198, 1, 25, 88, 67, 146, 9, 9, 253, 193, 21, 121, 243, 4, 117, 16, 158]), digest := (bytes [199, 10, 89, 203, 233, 123, 33, 237, 131, 146, 53, 43, 103, 43, 242, 1, 27, 138, 127, 245, 129, 206, 237, 139, 224, 75, 35, 144, 2, 1, 245, 108]) }, { traceIndex := 9, rowDigest := (bytes [17, 205, 99, 232, 149, 39, 125, 122, 177, 225, 225, 205, 61, 116, 214, 23, 107, 41, 201, 95, 182, 150, 66, 19, 72, 208, 17, 211, 166, 126, 147, 63]), rowOpeningDigest := (bytes [170, 232, 158, 106, 13, 133, 118, 173, 177, 66, 162, 16, 201, 150, 45, 88, 242, 245, 91, 3, 194, 229, 2, 128, 137, 14, 201, 76, 235, 135, 250, 182]), digest := (bytes [148, 223, 251, 72, 102, 243, 225, 104, 218, 205, 41, 74, 231, 218, 191, 88, 190, 187, 186, 153, 145, 15, 153, 56, 226, 34, 127, 243, 109, 189, 117, 232]) }, { traceIndex := 10, rowDigest := (bytes [154, 226, 191, 230, 117, 41, 86, 104, 178, 93, 26, 206, 239, 63, 72, 12, 232, 145, 240, 109, 229, 31, 201, 34, 230, 56, 165, 183, 11, 83, 106, 12]), rowOpeningDigest := (bytes [11, 6, 255, 10, 8, 37, 243, 87, 28, 234, 234, 8, 38, 149, 165, 177, 171, 87, 76, 232, 6, 38, 238, 214, 7, 244, 21, 211, 128, 100, 206, 84]), digest := (bytes [230, 101, 10, 204, 211, 84, 71, 133, 165, 182, 2, 247, 237, 109, 159, 197, 27, 244, 214, 58, 202, 157, 9, 6, 212, 97, 238, 29, 122, 70, 1, 96]) }, { traceIndex := 11, rowDigest := (bytes [117, 13, 26, 42, 62, 227, 191, 149, 225, 150, 206, 189, 253, 211, 23, 67, 182, 48, 36, 204, 211, 120, 157, 255, 102, 75, 77, 178, 205, 20, 147, 42]), rowOpeningDigest := (bytes [79, 85, 197, 182, 69, 179, 214, 16, 86, 185, 163, 245, 3, 198, 173, 52, 209, 238, 107, 96, 73, 80, 66, 123, 80, 36, 125, 143, 207, 95, 175, 77]), digest := (bytes [166, 155, 87, 199, 143, 104, 9, 153, 208, 68, 205, 215, 253, 198, 152, 185, 59, 116, 123, 63, 18, 47, 171, 153, 85, 179, 163, 249, 7, 164, 82, 208]) }, { traceIndex := 12, rowDigest := (bytes [91, 220, 3, 182, 115, 135, 173, 198, 2, 58, 135, 90, 194, 100, 227, 62, 80, 155, 255, 171, 85, 235, 51, 190, 217, 19, 234, 57, 128, 112, 68, 58]), rowOpeningDigest := (bytes [141, 87, 60, 61, 85, 14, 70, 180, 152, 226, 208, 150, 173, 34, 233, 134, 61, 120, 133, 156, 63, 206, 163, 228, 51, 125, 186, 166, 22, 196, 167, 94]), digest := (bytes [2, 107, 52, 249, 169, 243, 3, 54, 157, 161, 119, 127, 25, 249, 186, 32, 242, 75, 218, 204, 7, 84, 82, 239, 227, 21, 130, 25, 66, 105, 109, 45]) }, { traceIndex := 13, rowDigest := (bytes [228, 218, 132, 173, 40, 175, 163, 113, 77, 51, 14, 129, 172, 72, 64, 113, 166, 5, 209, 86, 65, 181, 139, 164, 241, 195, 58, 252, 148, 133, 40, 21]), rowOpeningDigest := (bytes [35, 165, 121, 231, 139, 68, 67, 111, 41, 179, 143, 236, 33, 48, 73, 237, 21, 135, 195, 13, 104, 225, 9, 101, 64, 133, 47, 110, 7, 141, 253, 126]), digest := (bytes [76, 132, 48, 195, 214, 228, 209, 236, 198, 44, 194, 138, 89, 163, 55, 79, 123, 118, 251, 2, 198, 82, 187, 223, 64, 157, 178, 184, 138, 109, 161, 204]) }]

def rootExecutionRowChunkRoutes : List RowChunkRouteView :=
  [{ logicalIndex := 0, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 0, digest := (bytes [138, 198, 109, 126, 144, 82, 221, 43, 248, 202, 137, 103, 62, 226, 249, 152, 163, 187, 1, 254, 36, 33, 59, 16, 64, 166, 202, 8, 219, 57, 240, 59]) }, { logicalIndex := 1, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 1, digest := (bytes [44, 177, 82, 41, 218, 60, 100, 208, 26, 31, 151, 113, 109, 148, 57, 12, 223, 21, 76, 221, 70, 245, 191, 105, 57, 199, 8, 128, 181, 145, 89, 99]) }, { logicalIndex := 2, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 2, digest := (bytes [252, 248, 65, 24, 81, 241, 150, 170, 250, 116, 222, 30, 134, 191, 78, 195, 104, 119, 225, 210, 243, 186, 212, 107, 183, 31, 243, 201, 101, 148, 32, 72]) }, { logicalIndex := 3, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 3, digest := (bytes [244, 11, 162, 13, 59, 43, 232, 47, 228, 2, 70, 126, 95, 10, 57, 40, 46, 107, 197, 81, 97, 39, 185, 163, 93, 60, 5, 66, 7, 231, 199, 134]) }, { logicalIndex := 4, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 4, digest := (bytes [98, 247, 204, 83, 252, 219, 248, 73, 49, 206, 229, 79, 169, 242, 28, 56, 7, 100, 18, 197, 133, 200, 133, 20, 161, 230, 126, 175, 98, 0, 158, 25]) }, { logicalIndex := 5, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 5, digest := (bytes [108, 248, 244, 125, 120, 190, 11, 202, 47, 205, 44, 110, 48, 43, 171, 224, 142, 98, 82, 106, 183, 21, 141, 205, 208, 18, 234, 19, 43, 61, 139, 151]) }, { logicalIndex := 6, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 6, digest := (bytes [213, 163, 43, 1, 32, 112, 128, 155, 10, 34, 241, 205, 79, 46, 234, 45, 239, 83, 213, 254, 45, 65, 13, 152, 217, 78, 36, 105, 42, 193, 181, 13]) }, { logicalIndex := 7, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 7, digest := (bytes [199, 10, 5, 135, 58, 125, 195, 205, 65, 103, 137, 179, 210, 215, 124, 50, 45, 181, 46, 62, 43, 114, 240, 192, 142, 94, 31, 202, 153, 102, 209, 54]) }, { logicalIndex := 8, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 8, digest := (bytes [243, 104, 100, 66, 94, 61, 218, 185, 138, 159, 201, 38, 53, 64, 18, 187, 81, 105, 239, 11, 139, 137, 248, 62, 130, 187, 188, 172, 131, 72, 106, 73]) }, { logicalIndex := 9, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 9, digest := (bytes [11, 164, 4, 249, 84, 107, 210, 66, 134, 110, 223, 149, 172, 176, 94, 254, 45, 42, 247, 93, 171, 29, 160, 56, 115, 52, 76, 84, 241, 17, 162, 122]) }, { logicalIndex := 10, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 10, digest := (bytes [163, 19, 52, 250, 55, 230, 68, 230, 28, 108, 101, 226, 50, 126, 176, 29, 159, 73, 227, 92, 77, 232, 226, 141, 7, 245, 241, 158, 73, 79, 99, 112]) }, { logicalIndex := 11, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 11, digest := (bytes [115, 116, 77, 106, 67, 232, 252, 146, 254, 38, 128, 153, 91, 223, 186, 248, 84, 234, 139, 247, 166, 27, 192, 52, 214, 24, 163, 76, 113, 87, 73, 143]) }, { logicalIndex := 12, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 12, digest := (bytes [151, 66, 233, 32, 5, 102, 244, 23, 80, 146, 192, 205, 244, 38, 63, 33, 134, 114, 135, 193, 174, 45, 168, 58, 244, 117, 162, 37, 125, 67, 17, 62]) }, { logicalIndex := 13, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 13, digest := (bytes [41, 1, 15, 89, 18, 198, 149, 21, 97, 142, 177, 33, 73, 111, 64, 204, 143, 105, 217, 48, 102, 83, 246, 243, 173, 192, 38, 246, 224, 129, 45, 221]) }]

def rootExecutionRowLocalCcsAcceptance : List RootRowLocalCcsAcceptanceView :=
  [{ traceIndex := 0, logicalIndex := 0, rowDigest := (bytes [195, 104, 190, 242, 104, 180, 234, 122, 108, 245, 168, 232, 122, 59, 5, 141, 148, 97, 161, 16, 201, 133, 162, 230, 49, 127, 153, 215, 226, 163, 192, 66]), rowOpeningDigest := (bytes [229, 44, 46, 216, 109, 204, 220, 233, 58, 5, 59, 127, 77, 57, 93, 180, 92, 174, 71, 184, 220, 8, 113, 222, 241, 157, 184, 161, 240, 199, 81, 75]), preparedStepBindingDigest := (bytes [21, 175, 100, 171, 175, 91, 213, 179, 96, 169, 117, 230, 223, 52, 10, 73, 248, 8, 221, 2, 87, 30, 20, 63, 76, 181, 185, 91, 83, 60, 174, 36]), rowChunkRouteDigest := (bytes [138, 198, 109, 126, 144, 82, 221, 43, 248, 202, 137, 103, 62, 226, 249, 152, 163, 187, 1, 254, 36, 33, 59, 16, 64, 166, 202, 8, 219, 57, 240, 59]), publicStepDigest := (bytes [228, 239, 224, 148, 245, 165, 43, 100, 78, 15, 201, 239, 137, 197, 239, 181, 253, 198, 6, 162, 68, 45, 255, 5, 106, 30, 29, 231, 74, 184, 217, 210]), digest := (bytes [234, 245, 12, 208, 195, 17, 2, 214, 37, 2, 180, 85, 178, 255, 128, 115, 69, 190, 63, 23, 94, 25, 63, 40, 68, 224, 142, 88, 64, 167, 152, 92]) }, { traceIndex := 1, logicalIndex := 1, rowDigest := (bytes [255, 201, 197, 212, 64, 166, 182, 76, 81, 47, 124, 75, 61, 223, 48, 19, 162, 79, 168, 42, 166, 188, 10, 106, 49, 98, 183, 23, 120, 205, 209, 2]), rowOpeningDigest := (bytes [184, 162, 231, 237, 163, 136, 137, 106, 131, 70, 198, 245, 54, 42, 25, 42, 191, 97, 122, 181, 126, 231, 241, 76, 86, 142, 162, 180, 214, 4, 136, 248]), preparedStepBindingDigest := (bytes [96, 86, 224, 184, 79, 73, 28, 38, 18, 40, 125, 32, 196, 239, 124, 59, 39, 246, 124, 222, 225, 27, 121, 167, 51, 129, 194, 121, 176, 20, 74, 122]), rowChunkRouteDigest := (bytes [44, 177, 82, 41, 218, 60, 100, 208, 26, 31, 151, 113, 109, 148, 57, 12, 223, 21, 76, 221, 70, 245, 191, 105, 57, 199, 8, 128, 181, 145, 89, 99]), publicStepDigest := (bytes [148, 92, 211, 48, 48, 118, 148, 6, 121, 78, 235, 62, 183, 90, 172, 58, 21, 103, 44, 26, 89, 153, 183, 207, 149, 38, 112, 103, 124, 71, 115, 69]), digest := (bytes [235, 74, 15, 156, 120, 57, 6, 50, 63, 70, 185, 50, 221, 9, 50, 75, 85, 126, 175, 208, 149, 185, 125, 155, 221, 198, 200, 147, 252, 0, 225, 113]) }, { traceIndex := 2, logicalIndex := 2, rowDigest := (bytes [43, 97, 198, 200, 196, 33, 6, 248, 154, 21, 120, 232, 168, 61, 73, 236, 166, 29, 136, 111, 34, 116, 110, 221, 60, 152, 180, 57, 161, 195, 47, 155]), rowOpeningDigest := (bytes [161, 118, 157, 139, 146, 94, 38, 121, 93, 46, 63, 58, 101, 112, 186, 7, 163, 191, 93, 204, 214, 192, 98, 52, 208, 218, 239, 49, 232, 103, 178, 50]), preparedStepBindingDigest := (bytes [113, 219, 248, 71, 109, 99, 87, 81, 169, 131, 50, 3, 164, 169, 234, 222, 154, 166, 242, 7, 39, 95, 125, 164, 194, 157, 218, 186, 176, 212, 59, 24]), rowChunkRouteDigest := (bytes [252, 248, 65, 24, 81, 241, 150, 170, 250, 116, 222, 30, 134, 191, 78, 195, 104, 119, 225, 210, 243, 186, 212, 107, 183, 31, 243, 201, 101, 148, 32, 72]), publicStepDigest := (bytes [10, 4, 45, 225, 94, 22, 99, 13, 99, 213, 104, 230, 248, 48, 112, 68, 215, 228, 201, 78, 217, 217, 69, 71, 150, 92, 141, 249, 73, 43, 23, 40]), digest := (bytes [17, 198, 21, 234, 50, 78, 25, 132, 35, 109, 71, 108, 246, 54, 114, 181, 24, 151, 61, 20, 70, 71, 202, 54, 186, 93, 0, 10, 207, 44, 72, 117]) }, { traceIndex := 3, logicalIndex := 3, rowDigest := (bytes [163, 225, 178, 19, 58, 48, 97, 124, 97, 23, 58, 2, 181, 204, 114, 203, 155, 228, 110, 241, 176, 250, 4, 4, 106, 132, 114, 179, 90, 133, 250, 237]), rowOpeningDigest := (bytes [38, 151, 118, 2, 51, 123, 153, 40, 117, 184, 7, 99, 164, 227, 108, 171, 204, 181, 184, 229, 218, 11, 129, 91, 25, 197, 210, 53, 245, 96, 16, 153]), preparedStepBindingDigest := (bytes [239, 3, 69, 143, 141, 124, 191, 59, 172, 135, 239, 142, 166, 143, 76, 203, 182, 252, 172, 208, 174, 66, 122, 60, 144, 144, 105, 48, 75, 184, 138, 155]), rowChunkRouteDigest := (bytes [244, 11, 162, 13, 59, 43, 232, 47, 228, 2, 70, 126, 95, 10, 57, 40, 46, 107, 197, 81, 97, 39, 185, 163, 93, 60, 5, 66, 7, 231, 199, 134]), publicStepDigest := (bytes [217, 244, 102, 88, 244, 175, 119, 78, 87, 125, 3, 150, 246, 183, 9, 162, 2, 199, 230, 103, 92, 168, 218, 40, 26, 234, 19, 32, 154, 62, 95, 42]), digest := (bytes [130, 171, 199, 33, 219, 119, 6, 13, 72, 140, 222, 26, 160, 140, 215, 236, 29, 42, 60, 91, 212, 126, 172, 91, 205, 208, 132, 68, 138, 242, 158, 115]) }, { traceIndex := 4, logicalIndex := 4, rowDigest := (bytes [116, 93, 115, 58, 78, 116, 192, 52, 235, 188, 139, 103, 124, 214, 229, 219, 147, 116, 97, 59, 34, 241, 239, 38, 195, 231, 247, 216, 20, 165, 247, 63]), rowOpeningDigest := (bytes [131, 167, 61, 216, 129, 171, 105, 43, 177, 40, 170, 75, 227, 42, 174, 48, 237, 218, 241, 112, 22, 144, 101, 119, 30, 34, 0, 63, 229, 155, 175, 122]), preparedStepBindingDigest := (bytes [209, 212, 54, 96, 113, 176, 142, 154, 177, 177, 207, 94, 91, 86, 140, 77, 187, 102, 251, 177, 232, 173, 219, 248, 158, 195, 180, 183, 12, 11, 101, 189]), rowChunkRouteDigest := (bytes [98, 247, 204, 83, 252, 219, 248, 73, 49, 206, 229, 79, 169, 242, 28, 56, 7, 100, 18, 197, 133, 200, 133, 20, 161, 230, 126, 175, 98, 0, 158, 25]), publicStepDigest := (bytes [221, 60, 168, 92, 217, 11, 10, 72, 225, 104, 129, 164, 31, 124, 177, 102, 173, 133, 114, 35, 68, 163, 71, 51, 63, 161, 51, 145, 83, 206, 249, 108]), digest := (bytes [192, 135, 150, 113, 161, 89, 25, 200, 172, 204, 167, 63, 205, 11, 133, 118, 77, 173, 31, 245, 198, 86, 247, 79, 93, 159, 238, 87, 204, 142, 141, 161]) }, { traceIndex := 5, logicalIndex := 5, rowDigest := (bytes [117, 193, 90, 184, 146, 69, 205, 172, 50, 151, 22, 223, 182, 77, 255, 5, 41, 81, 131, 228, 238, 238, 87, 229, 11, 149, 164, 30, 207, 248, 49, 59]), rowOpeningDigest := (bytes [194, 252, 212, 171, 86, 244, 243, 77, 202, 227, 107, 199, 29, 227, 93, 43, 147, 8, 115, 25, 228, 147, 140, 142, 172, 167, 36, 59, 68, 150, 88, 54]), preparedStepBindingDigest := (bytes [244, 206, 29, 64, 176, 203, 110, 15, 213, 33, 113, 68, 248, 100, 140, 132, 79, 111, 133, 168, 14, 227, 204, 244, 9, 120, 21, 43, 100, 161, 230, 132]), rowChunkRouteDigest := (bytes [108, 248, 244, 125, 120, 190, 11, 202, 47, 205, 44, 110, 48, 43, 171, 224, 142, 98, 82, 106, 183, 21, 141, 205, 208, 18, 234, 19, 43, 61, 139, 151]), publicStepDigest := (bytes [45, 130, 86, 81, 28, 228, 112, 144, 55, 203, 83, 99, 233, 126, 239, 14, 6, 157, 230, 158, 194, 166, 138, 137, 187, 31, 208, 27, 86, 83, 245, 133]), digest := (bytes [175, 255, 202, 229, 126, 123, 84, 214, 232, 48, 51, 207, 245, 134, 170, 76, 45, 242, 129, 52, 48, 38, 30, 87, 71, 25, 220, 68, 26, 175, 17, 120]) }, { traceIndex := 6, logicalIndex := 6, rowDigest := (bytes [1, 82, 142, 23, 161, 157, 226, 140, 168, 11, 192, 13, 170, 139, 178, 96, 240, 231, 250, 48, 217, 159, 217, 248, 158, 118, 86, 166, 84, 16, 126, 15]), rowOpeningDigest := (bytes [106, 57, 237, 57, 64, 132, 72, 116, 221, 156, 167, 78, 49, 199, 106, 217, 147, 49, 12, 167, 61, 98, 209, 188, 159, 229, 37, 207, 106, 81, 239, 139]), preparedStepBindingDigest := (bytes [88, 249, 121, 137, 204, 253, 113, 186, 77, 92, 221, 125, 9, 197, 35, 37, 133, 228, 252, 77, 155, 229, 144, 126, 45, 132, 169, 214, 20, 222, 229, 5]), rowChunkRouteDigest := (bytes [213, 163, 43, 1, 32, 112, 128, 155, 10, 34, 241, 205, 79, 46, 234, 45, 239, 83, 213, 254, 45, 65, 13, 152, 217, 78, 36, 105, 42, 193, 181, 13]), publicStepDigest := (bytes [61, 138, 102, 78, 35, 127, 70, 249, 31, 61, 179, 26, 244, 204, 172, 180, 142, 52, 63, 173, 152, 77, 81, 30, 242, 127, 44, 197, 233, 20, 63, 144]), digest := (bytes [198, 74, 83, 57, 130, 251, 44, 180, 169, 83, 15, 113, 35, 153, 9, 44, 208, 108, 158, 199, 128, 45, 216, 0, 117, 51, 39, 118, 145, 164, 173, 237]) }, { traceIndex := 7, logicalIndex := 7, rowDigest := (bytes [134, 88, 202, 229, 168, 7, 59, 55, 233, 243, 248, 179, 213, 137, 140, 58, 189, 5, 172, 233, 177, 182, 77, 182, 146, 41, 193, 56, 120, 67, 72, 54]), rowOpeningDigest := (bytes [197, 18, 3, 133, 235, 245, 102, 157, 86, 149, 144, 80, 131, 49, 119, 183, 244, 83, 17, 22, 247, 160, 219, 219, 213, 176, 156, 14, 223, 109, 16, 52]), preparedStepBindingDigest := (bytes [240, 165, 223, 191, 230, 87, 180, 189, 148, 153, 196, 10, 213, 244, 214, 217, 117, 100, 37, 86, 3, 164, 101, 92, 122, 53, 102, 247, 23, 169, 192, 139]), rowChunkRouteDigest := (bytes [199, 10, 5, 135, 58, 125, 195, 205, 65, 103, 137, 179, 210, 215, 124, 50, 45, 181, 46, 62, 43, 114, 240, 192, 142, 94, 31, 202, 153, 102, 209, 54]), publicStepDigest := (bytes [148, 141, 118, 19, 37, 80, 156, 106, 47, 104, 15, 47, 22, 60, 146, 191, 86, 167, 96, 234, 90, 61, 179, 22, 189, 2, 12, 228, 5, 174, 112, 147]), digest := (bytes [34, 162, 182, 240, 91, 92, 232, 152, 229, 115, 222, 125, 196, 225, 46, 181, 103, 21, 150, 80, 87, 63, 200, 132, 172, 57, 80, 83, 199, 128, 138, 103]) }, { traceIndex := 8, logicalIndex := 8, rowDigest := (bytes [230, 234, 199, 45, 183, 197, 205, 237, 117, 182, 198, 245, 169, 173, 243, 207, 36, 58, 35, 202, 135, 232, 50, 12, 5, 116, 12, 188, 28, 173, 54, 250]), rowOpeningDigest := (bytes [99, 34, 12, 104, 82, 152, 197, 102, 84, 141, 202, 124, 27, 96, 246, 198, 1, 25, 88, 67, 146, 9, 9, 253, 193, 21, 121, 243, 4, 117, 16, 158]), preparedStepBindingDigest := (bytes [199, 10, 89, 203, 233, 123, 33, 237, 131, 146, 53, 43, 103, 43, 242, 1, 27, 138, 127, 245, 129, 206, 237, 139, 224, 75, 35, 144, 2, 1, 245, 108]), rowChunkRouteDigest := (bytes [243, 104, 100, 66, 94, 61, 218, 185, 138, 159, 201, 38, 53, 64, 18, 187, 81, 105, 239, 11, 139, 137, 248, 62, 130, 187, 188, 172, 131, 72, 106, 73]), publicStepDigest := (bytes [82, 109, 207, 131, 212, 149, 216, 24, 23, 254, 53, 213, 5, 155, 106, 26, 42, 192, 97, 94, 74, 60, 186, 57, 87, 149, 77, 177, 2, 183, 69, 124]), digest := (bytes [128, 125, 177, 219, 10, 2, 246, 200, 44, 93, 87, 92, 123, 102, 106, 97, 96, 108, 216, 121, 190, 170, 99, 113, 37, 249, 177, 134, 100, 134, 90, 72]) }, { traceIndex := 9, logicalIndex := 9, rowDigest := (bytes [17, 205, 99, 232, 149, 39, 125, 122, 177, 225, 225, 205, 61, 116, 214, 23, 107, 41, 201, 95, 182, 150, 66, 19, 72, 208, 17, 211, 166, 126, 147, 63]), rowOpeningDigest := (bytes [170, 232, 158, 106, 13, 133, 118, 173, 177, 66, 162, 16, 201, 150, 45, 88, 242, 245, 91, 3, 194, 229, 2, 128, 137, 14, 201, 76, 235, 135, 250, 182]), preparedStepBindingDigest := (bytes [148, 223, 251, 72, 102, 243, 225, 104, 218, 205, 41, 74, 231, 218, 191, 88, 190, 187, 186, 153, 145, 15, 153, 56, 226, 34, 127, 243, 109, 189, 117, 232]), rowChunkRouteDigest := (bytes [11, 164, 4, 249, 84, 107, 210, 66, 134, 110, 223, 149, 172, 176, 94, 254, 45, 42, 247, 93, 171, 29, 160, 56, 115, 52, 76, 84, 241, 17, 162, 122]), publicStepDigest := (bytes [175, 177, 6, 47, 114, 251, 34, 112, 134, 99, 51, 174, 158, 148, 232, 248, 217, 249, 94, 98, 196, 49, 39, 228, 54, 13, 86, 62, 156, 104, 23, 9]), digest := (bytes [173, 200, 95, 199, 193, 197, 85, 235, 135, 153, 57, 175, 169, 173, 82, 23, 190, 160, 115, 138, 226, 206, 96, 254, 29, 33, 16, 122, 59, 71, 180, 95]) }, { traceIndex := 10, logicalIndex := 10, rowDigest := (bytes [154, 226, 191, 230, 117, 41, 86, 104, 178, 93, 26, 206, 239, 63, 72, 12, 232, 145, 240, 109, 229, 31, 201, 34, 230, 56, 165, 183, 11, 83, 106, 12]), rowOpeningDigest := (bytes [11, 6, 255, 10, 8, 37, 243, 87, 28, 234, 234, 8, 38, 149, 165, 177, 171, 87, 76, 232, 6, 38, 238, 214, 7, 244, 21, 211, 128, 100, 206, 84]), preparedStepBindingDigest := (bytes [230, 101, 10, 204, 211, 84, 71, 133, 165, 182, 2, 247, 237, 109, 159, 197, 27, 244, 214, 58, 202, 157, 9, 6, 212, 97, 238, 29, 122, 70, 1, 96]), rowChunkRouteDigest := (bytes [163, 19, 52, 250, 55, 230, 68, 230, 28, 108, 101, 226, 50, 126, 176, 29, 159, 73, 227, 92, 77, 232, 226, 141, 7, 245, 241, 158, 73, 79, 99, 112]), publicStepDigest := (bytes [74, 173, 26, 54, 134, 56, 169, 145, 20, 38, 21, 229, 64, 80, 199, 136, 144, 116, 94, 72, 125, 205, 224, 146, 141, 104, 171, 149, 125, 160, 208, 78]), digest := (bytes [25, 19, 149, 12, 35, 53, 56, 15, 64, 255, 29, 104, 145, 154, 45, 25, 224, 126, 158, 217, 54, 151, 81, 230, 22, 32, 136, 58, 184, 6, 130, 207]) }, { traceIndex := 11, logicalIndex := 11, rowDigest := (bytes [117, 13, 26, 42, 62, 227, 191, 149, 225, 150, 206, 189, 253, 211, 23, 67, 182, 48, 36, 204, 211, 120, 157, 255, 102, 75, 77, 178, 205, 20, 147, 42]), rowOpeningDigest := (bytes [79, 85, 197, 182, 69, 179, 214, 16, 86, 185, 163, 245, 3, 198, 173, 52, 209, 238, 107, 96, 73, 80, 66, 123, 80, 36, 125, 143, 207, 95, 175, 77]), preparedStepBindingDigest := (bytes [166, 155, 87, 199, 143, 104, 9, 153, 208, 68, 205, 215, 253, 198, 152, 185, 59, 116, 123, 63, 18, 47, 171, 153, 85, 179, 163, 249, 7, 164, 82, 208]), rowChunkRouteDigest := (bytes [115, 116, 77, 106, 67, 232, 252, 146, 254, 38, 128, 153, 91, 223, 186, 248, 84, 234, 139, 247, 166, 27, 192, 52, 214, 24, 163, 76, 113, 87, 73, 143]), publicStepDigest := (bytes [176, 169, 252, 140, 206, 234, 121, 102, 181, 98, 161, 86, 37, 18, 66, 189, 116, 156, 6, 76, 195, 136, 172, 191, 214, 172, 39, 175, 221, 187, 221, 161]), digest := (bytes [61, 24, 207, 228, 16, 156, 126, 156, 113, 32, 225, 14, 76, 42, 152, 140, 178, 198, 5, 141, 250, 200, 209, 57, 238, 77, 6, 233, 31, 196, 37, 21]) }, { traceIndex := 12, logicalIndex := 12, rowDigest := (bytes [91, 220, 3, 182, 115, 135, 173, 198, 2, 58, 135, 90, 194, 100, 227, 62, 80, 155, 255, 171, 85, 235, 51, 190, 217, 19, 234, 57, 128, 112, 68, 58]), rowOpeningDigest := (bytes [141, 87, 60, 61, 85, 14, 70, 180, 152, 226, 208, 150, 173, 34, 233, 134, 61, 120, 133, 156, 63, 206, 163, 228, 51, 125, 186, 166, 22, 196, 167, 94]), preparedStepBindingDigest := (bytes [2, 107, 52, 249, 169, 243, 3, 54, 157, 161, 119, 127, 25, 249, 186, 32, 242, 75, 218, 204, 7, 84, 82, 239, 227, 21, 130, 25, 66, 105, 109, 45]), rowChunkRouteDigest := (bytes [151, 66, 233, 32, 5, 102, 244, 23, 80, 146, 192, 205, 244, 38, 63, 33, 134, 114, 135, 193, 174, 45, 168, 58, 244, 117, 162, 37, 125, 67, 17, 62]), publicStepDigest := (bytes [163, 190, 215, 237, 225, 101, 67, 114, 22, 16, 143, 112, 12, 140, 94, 90, 43, 114, 147, 189, 2, 133, 56, 252, 15, 149, 245, 122, 252, 27, 189, 205]), digest := (bytes [64, 64, 54, 228, 230, 194, 141, 80, 30, 31, 158, 13, 193, 5, 181, 1, 80, 103, 242, 145, 232, 68, 28, 87, 46, 4, 195, 117, 236, 84, 219, 100]) }, { traceIndex := 13, logicalIndex := 13, rowDigest := (bytes [228, 218, 132, 173, 40, 175, 163, 113, 77, 51, 14, 129, 172, 72, 64, 113, 166, 5, 209, 86, 65, 181, 139, 164, 241, 195, 58, 252, 148, 133, 40, 21]), rowOpeningDigest := (bytes [35, 165, 121, 231, 139, 68, 67, 111, 41, 179, 143, 236, 33, 48, 73, 237, 21, 135, 195, 13, 104, 225, 9, 101, 64, 133, 47, 110, 7, 141, 253, 126]), preparedStepBindingDigest := (bytes [76, 132, 48, 195, 214, 228, 209, 236, 198, 44, 194, 138, 89, 163, 55, 79, 123, 118, 251, 2, 198, 82, 187, 223, 64, 157, 178, 184, 138, 109, 161, 204]), rowChunkRouteDigest := (bytes [41, 1, 15, 89, 18, 198, 149, 21, 97, 142, 177, 33, 73, 111, 64, 204, 143, 105, 217, 48, 102, 83, 246, 243, 173, 192, 38, 246, 224, 129, 45, 221]), publicStepDigest := (bytes [201, 217, 243, 231, 62, 18, 83, 190, 92, 15, 3, 50, 155, 186, 29, 147, 169, 150, 109, 213, 171, 210, 233, 144, 250, 177, 110, 132, 156, 19, 182, 174]), digest := (bytes [41, 199, 191, 81, 159, 104, 199, 2, 210, 200, 33, 171, 255, 217, 237, 20, 31, 219, 25, 236, 193, 252, 116, 99, 164, 69, 61, 211, 155, 23, 36, 112]) }]

def rootExecutionExecutionSemanticsRefinement : List RootExecutionSemanticsRefinementView :=
  [{ traceIndex := 0, logicalIndex := 0, semanticRowDigest := (bytes [6, 140, 16, 12, 199, 169, 215, 123, 74, 92, 71, 171, 180, 226, 130, 112, 18, 207, 109, 194, 34, 121, 220, 17, 87, 27, 107, 102, 161, 141, 105, 55]), rowLocalCcsAcceptanceDigest := (bytes [234, 245, 12, 208, 195, 17, 2, 214, 37, 2, 180, 85, 178, 255, 128, 115, 69, 190, 63, 23, 94, 25, 63, 40, 68, 224, 142, 88, 64, 167, 152, 92]), preparedStepBindingDigest := (bytes [21, 175, 100, 171, 175, 91, 213, 179, 96, 169, 117, 230, 223, 52, 10, 73, 248, 8, 221, 2, 87, 30, 20, 63, 76, 181, 185, 91, 83, 60, 174, 36]), publicStepDigest := (bytes [228, 239, 224, 148, 245, 165, 43, 100, 78, 15, 201, 239, 137, 197, 239, 181, 253, 198, 6, 162, 68, 45, 255, 5, 106, 30, 29, 231, 74, 184, 217, 210]), digest := (bytes [231, 191, 38, 205, 72, 151, 50, 74, 42, 206, 91, 169, 128, 112, 151, 58, 13, 134, 160, 153, 208, 195, 66, 139, 214, 134, 132, 69, 114, 195, 172, 239]) }, { traceIndex := 1, logicalIndex := 1, semanticRowDigest := (bytes [212, 234, 171, 12, 138, 31, 235, 104, 223, 43, 50, 208, 126, 84, 222, 180, 169, 114, 131, 188, 138, 229, 223, 12, 193, 251, 115, 200, 157, 181, 189, 68]), rowLocalCcsAcceptanceDigest := (bytes [235, 74, 15, 156, 120, 57, 6, 50, 63, 70, 185, 50, 221, 9, 50, 75, 85, 126, 175, 208, 149, 185, 125, 155, 221, 198, 200, 147, 252, 0, 225, 113]), preparedStepBindingDigest := (bytes [96, 86, 224, 184, 79, 73, 28, 38, 18, 40, 125, 32, 196, 239, 124, 59, 39, 246, 124, 222, 225, 27, 121, 167, 51, 129, 194, 121, 176, 20, 74, 122]), publicStepDigest := (bytes [148, 92, 211, 48, 48, 118, 148, 6, 121, 78, 235, 62, 183, 90, 172, 58, 21, 103, 44, 26, 89, 153, 183, 207, 149, 38, 112, 103, 124, 71, 115, 69]), digest := (bytes [21, 87, 145, 36, 182, 90, 80, 38, 135, 22, 85, 166, 16, 196, 13, 162, 79, 25, 200, 237, 182, 168, 38, 14, 218, 171, 180, 85, 52, 161, 187, 236]) }, { traceIndex := 2, logicalIndex := 2, semanticRowDigest := (bytes [143, 174, 144, 2, 114, 141, 158, 207, 93, 155, 18, 77, 195, 219, 175, 75, 61, 184, 241, 236, 221, 230, 124, 148, 80, 123, 67, 172, 189, 20, 95, 175]), rowLocalCcsAcceptanceDigest := (bytes [17, 198, 21, 234, 50, 78, 25, 132, 35, 109, 71, 108, 246, 54, 114, 181, 24, 151, 61, 20, 70, 71, 202, 54, 186, 93, 0, 10, 207, 44, 72, 117]), preparedStepBindingDigest := (bytes [113, 219, 248, 71, 109, 99, 87, 81, 169, 131, 50, 3, 164, 169, 234, 222, 154, 166, 242, 7, 39, 95, 125, 164, 194, 157, 218, 186, 176, 212, 59, 24]), publicStepDigest := (bytes [10, 4, 45, 225, 94, 22, 99, 13, 99, 213, 104, 230, 248, 48, 112, 68, 215, 228, 201, 78, 217, 217, 69, 71, 150, 92, 141, 249, 73, 43, 23, 40]), digest := (bytes [213, 199, 64, 227, 1, 124, 88, 186, 69, 110, 52, 0, 168, 43, 80, 175, 219, 104, 86, 209, 26, 56, 178, 135, 33, 45, 123, 230, 36, 152, 137, 119]) }, { traceIndex := 3, logicalIndex := 3, semanticRowDigest := (bytes [124, 197, 201, 222, 187, 124, 142, 159, 235, 180, 93, 224, 158, 198, 126, 167, 213, 0, 20, 91, 147, 228, 248, 205, 205, 240, 39, 137, 20, 159, 139, 72]), rowLocalCcsAcceptanceDigest := (bytes [130, 171, 199, 33, 219, 119, 6, 13, 72, 140, 222, 26, 160, 140, 215, 236, 29, 42, 60, 91, 212, 126, 172, 91, 205, 208, 132, 68, 138, 242, 158, 115]), preparedStepBindingDigest := (bytes [239, 3, 69, 143, 141, 124, 191, 59, 172, 135, 239, 142, 166, 143, 76, 203, 182, 252, 172, 208, 174, 66, 122, 60, 144, 144, 105, 48, 75, 184, 138, 155]), publicStepDigest := (bytes [217, 244, 102, 88, 244, 175, 119, 78, 87, 125, 3, 150, 246, 183, 9, 162, 2, 199, 230, 103, 92, 168, 218, 40, 26, 234, 19, 32, 154, 62, 95, 42]), digest := (bytes [116, 103, 160, 167, 97, 82, 185, 97, 39, 220, 208, 255, 182, 112, 88, 213, 79, 227, 100, 92, 53, 48, 158, 220, 10, 172, 113, 46, 43, 74, 86, 50]) }, { traceIndex := 4, logicalIndex := 4, semanticRowDigest := (bytes [134, 232, 118, 108, 235, 145, 215, 226, 99, 28, 180, 96, 173, 165, 154, 156, 251, 90, 125, 111, 18, 71, 67, 106, 12, 61, 90, 87, 52, 108, 122, 170]), rowLocalCcsAcceptanceDigest := (bytes [192, 135, 150, 113, 161, 89, 25, 200, 172, 204, 167, 63, 205, 11, 133, 118, 77, 173, 31, 245, 198, 86, 247, 79, 93, 159, 238, 87, 204, 142, 141, 161]), preparedStepBindingDigest := (bytes [209, 212, 54, 96, 113, 176, 142, 154, 177, 177, 207, 94, 91, 86, 140, 77, 187, 102, 251, 177, 232, 173, 219, 248, 158, 195, 180, 183, 12, 11, 101, 189]), publicStepDigest := (bytes [221, 60, 168, 92, 217, 11, 10, 72, 225, 104, 129, 164, 31, 124, 177, 102, 173, 133, 114, 35, 68, 163, 71, 51, 63, 161, 51, 145, 83, 206, 249, 108]), digest := (bytes [205, 199, 95, 218, 20, 248, 194, 162, 119, 5, 148, 231, 34, 134, 192, 71, 70, 124, 135, 41, 247, 178, 231, 113, 94, 143, 16, 230, 79, 172, 155, 158]) }, { traceIndex := 5, logicalIndex := 5, semanticRowDigest := (bytes [1, 222, 94, 42, 141, 75, 176, 174, 49, 99, 145, 41, 227, 36, 61, 154, 137, 128, 52, 221, 212, 121, 70, 121, 204, 191, 28, 132, 60, 67, 7, 52]), rowLocalCcsAcceptanceDigest := (bytes [175, 255, 202, 229, 126, 123, 84, 214, 232, 48, 51, 207, 245, 134, 170, 76, 45, 242, 129, 52, 48, 38, 30, 87, 71, 25, 220, 68, 26, 175, 17, 120]), preparedStepBindingDigest := (bytes [244, 206, 29, 64, 176, 203, 110, 15, 213, 33, 113, 68, 248, 100, 140, 132, 79, 111, 133, 168, 14, 227, 204, 244, 9, 120, 21, 43, 100, 161, 230, 132]), publicStepDigest := (bytes [45, 130, 86, 81, 28, 228, 112, 144, 55, 203, 83, 99, 233, 126, 239, 14, 6, 157, 230, 158, 194, 166, 138, 137, 187, 31, 208, 27, 86, 83, 245, 133]), digest := (bytes [174, 36, 60, 46, 83, 182, 232, 164, 5, 198, 226, 33, 1, 143, 151, 39, 251, 34, 216, 82, 135, 120, 135, 233, 25, 72, 158, 3, 73, 145, 107, 180]) }, { traceIndex := 6, logicalIndex := 6, semanticRowDigest := (bytes [196, 228, 114, 137, 124, 179, 131, 72, 123, 208, 213, 20, 87, 7, 240, 57, 166, 235, 182, 255, 154, 80, 91, 226, 140, 225, 165, 194, 8, 160, 176, 237]), rowLocalCcsAcceptanceDigest := (bytes [198, 74, 83, 57, 130, 251, 44, 180, 169, 83, 15, 113, 35, 153, 9, 44, 208, 108, 158, 199, 128, 45, 216, 0, 117, 51, 39, 118, 145, 164, 173, 237]), preparedStepBindingDigest := (bytes [88, 249, 121, 137, 204, 253, 113, 186, 77, 92, 221, 125, 9, 197, 35, 37, 133, 228, 252, 77, 155, 229, 144, 126, 45, 132, 169, 214, 20, 222, 229, 5]), publicStepDigest := (bytes [61, 138, 102, 78, 35, 127, 70, 249, 31, 61, 179, 26, 244, 204, 172, 180, 142, 52, 63, 173, 152, 77, 81, 30, 242, 127, 44, 197, 233, 20, 63, 144]), digest := (bytes [159, 32, 117, 71, 151, 223, 162, 245, 238, 204, 147, 110, 207, 83, 53, 223, 57, 225, 146, 57, 206, 27, 10, 251, 144, 112, 104, 247, 116, 170, 42, 49]) }, { traceIndex := 7, logicalIndex := 7, semanticRowDigest := (bytes [97, 130, 128, 50, 86, 229, 199, 63, 193, 230, 206, 148, 107, 201, 255, 33, 159, 56, 34, 239, 190, 21, 95, 199, 49, 12, 124, 62, 47, 219, 39, 168]), rowLocalCcsAcceptanceDigest := (bytes [34, 162, 182, 240, 91, 92, 232, 152, 229, 115, 222, 125, 196, 225, 46, 181, 103, 21, 150, 80, 87, 63, 200, 132, 172, 57, 80, 83, 199, 128, 138, 103]), preparedStepBindingDigest := (bytes [240, 165, 223, 191, 230, 87, 180, 189, 148, 153, 196, 10, 213, 244, 214, 217, 117, 100, 37, 86, 3, 164, 101, 92, 122, 53, 102, 247, 23, 169, 192, 139]), publicStepDigest := (bytes [148, 141, 118, 19, 37, 80, 156, 106, 47, 104, 15, 47, 22, 60, 146, 191, 86, 167, 96, 234, 90, 61, 179, 22, 189, 2, 12, 228, 5, 174, 112, 147]), digest := (bytes [213, 248, 191, 247, 80, 203, 84, 74, 207, 202, 147, 206, 26, 174, 173, 49, 15, 162, 224, 45, 154, 199, 5, 173, 112, 69, 88, 163, 220, 245, 124, 224]) }, { traceIndex := 8, logicalIndex := 8, semanticRowDigest := (bytes [51, 233, 47, 176, 156, 165, 248, 137, 237, 135, 217, 194, 3, 53, 208, 117, 57, 3, 160, 62, 220, 38, 21, 228, 79, 126, 231, 232, 228, 224, 168, 90]), rowLocalCcsAcceptanceDigest := (bytes [128, 125, 177, 219, 10, 2, 246, 200, 44, 93, 87, 92, 123, 102, 106, 97, 96, 108, 216, 121, 190, 170, 99, 113, 37, 249, 177, 134, 100, 134, 90, 72]), preparedStepBindingDigest := (bytes [199, 10, 89, 203, 233, 123, 33, 237, 131, 146, 53, 43, 103, 43, 242, 1, 27, 138, 127, 245, 129, 206, 237, 139, 224, 75, 35, 144, 2, 1, 245, 108]), publicStepDigest := (bytes [82, 109, 207, 131, 212, 149, 216, 24, 23, 254, 53, 213, 5, 155, 106, 26, 42, 192, 97, 94, 74, 60, 186, 57, 87, 149, 77, 177, 2, 183, 69, 124]), digest := (bytes [82, 241, 72, 177, 101, 119, 214, 122, 167, 105, 87, 171, 204, 190, 193, 157, 24, 168, 114, 241, 74, 47, 202, 226, 183, 233, 20, 13, 189, 38, 218, 118]) }, { traceIndex := 9, logicalIndex := 9, semanticRowDigest := (bytes [23, 92, 139, 48, 198, 233, 92, 148, 204, 88, 10, 243, 213, 70, 32, 88, 240, 237, 194, 45, 210, 179, 200, 111, 88, 97, 89, 95, 246, 86, 254, 61]), rowLocalCcsAcceptanceDigest := (bytes [173, 200, 95, 199, 193, 197, 85, 235, 135, 153, 57, 175, 169, 173, 82, 23, 190, 160, 115, 138, 226, 206, 96, 254, 29, 33, 16, 122, 59, 71, 180, 95]), preparedStepBindingDigest := (bytes [148, 223, 251, 72, 102, 243, 225, 104, 218, 205, 41, 74, 231, 218, 191, 88, 190, 187, 186, 153, 145, 15, 153, 56, 226, 34, 127, 243, 109, 189, 117, 232]), publicStepDigest := (bytes [175, 177, 6, 47, 114, 251, 34, 112, 134, 99, 51, 174, 158, 148, 232, 248, 217, 249, 94, 98, 196, 49, 39, 228, 54, 13, 86, 62, 156, 104, 23, 9]), digest := (bytes [93, 69, 214, 146, 30, 93, 209, 235, 59, 202, 128, 158, 241, 106, 134, 141, 134, 236, 150, 72, 22, 205, 14, 102, 235, 215, 40, 28, 35, 39, 136, 79]) }, { traceIndex := 10, logicalIndex := 10, semanticRowDigest := (bytes [60, 113, 103, 227, 170, 254, 242, 238, 206, 225, 169, 158, 202, 48, 22, 168, 138, 174, 51, 105, 1, 215, 14, 144, 28, 196, 105, 76, 169, 93, 34, 187]), rowLocalCcsAcceptanceDigest := (bytes [25, 19, 149, 12, 35, 53, 56, 15, 64, 255, 29, 104, 145, 154, 45, 25, 224, 126, 158, 217, 54, 151, 81, 230, 22, 32, 136, 58, 184, 6, 130, 207]), preparedStepBindingDigest := (bytes [230, 101, 10, 204, 211, 84, 71, 133, 165, 182, 2, 247, 237, 109, 159, 197, 27, 244, 214, 58, 202, 157, 9, 6, 212, 97, 238, 29, 122, 70, 1, 96]), publicStepDigest := (bytes [74, 173, 26, 54, 134, 56, 169, 145, 20, 38, 21, 229, 64, 80, 199, 136, 144, 116, 94, 72, 125, 205, 224, 146, 141, 104, 171, 149, 125, 160, 208, 78]), digest := (bytes [209, 94, 237, 91, 67, 176, 145, 173, 179, 69, 26, 98, 81, 179, 133, 209, 126, 229, 247, 129, 244, 183, 214, 54, 166, 3, 88, 251, 150, 117, 97, 132]) }, { traceIndex := 11, logicalIndex := 11, semanticRowDigest := (bytes [254, 201, 249, 172, 246, 249, 56, 48, 43, 154, 74, 78, 63, 77, 23, 138, 109, 230, 196, 56, 250, 31, 39, 48, 18, 101, 114, 121, 63, 214, 175, 39]), rowLocalCcsAcceptanceDigest := (bytes [61, 24, 207, 228, 16, 156, 126, 156, 113, 32, 225, 14, 76, 42, 152, 140, 178, 198, 5, 141, 250, 200, 209, 57, 238, 77, 6, 233, 31, 196, 37, 21]), preparedStepBindingDigest := (bytes [166, 155, 87, 199, 143, 104, 9, 153, 208, 68, 205, 215, 253, 198, 152, 185, 59, 116, 123, 63, 18, 47, 171, 153, 85, 179, 163, 249, 7, 164, 82, 208]), publicStepDigest := (bytes [176, 169, 252, 140, 206, 234, 121, 102, 181, 98, 161, 86, 37, 18, 66, 189, 116, 156, 6, 76, 195, 136, 172, 191, 214, 172, 39, 175, 221, 187, 221, 161]), digest := (bytes [134, 215, 230, 128, 253, 9, 91, 27, 169, 16, 69, 15, 53, 226, 148, 234, 0, 252, 64, 101, 55, 130, 189, 83, 215, 37, 184, 214, 200, 210, 123, 84]) }, { traceIndex := 12, logicalIndex := 12, semanticRowDigest := (bytes [74, 253, 244, 230, 48, 15, 119, 37, 184, 207, 6, 3, 154, 36, 2, 70, 57, 102, 76, 29, 117, 79, 248, 10, 5, 24, 188, 15, 199, 204, 218, 109]), rowLocalCcsAcceptanceDigest := (bytes [64, 64, 54, 228, 230, 194, 141, 80, 30, 31, 158, 13, 193, 5, 181, 1, 80, 103, 242, 145, 232, 68, 28, 87, 46, 4, 195, 117, 236, 84, 219, 100]), preparedStepBindingDigest := (bytes [2, 107, 52, 249, 169, 243, 3, 54, 157, 161, 119, 127, 25, 249, 186, 32, 242, 75, 218, 204, 7, 84, 82, 239, 227, 21, 130, 25, 66, 105, 109, 45]), publicStepDigest := (bytes [163, 190, 215, 237, 225, 101, 67, 114, 22, 16, 143, 112, 12, 140, 94, 90, 43, 114, 147, 189, 2, 133, 56, 252, 15, 149, 245, 122, 252, 27, 189, 205]), digest := (bytes [61, 186, 55, 19, 47, 165, 53, 228, 216, 183, 135, 210, 147, 102, 178, 89, 11, 50, 140, 81, 152, 183, 62, 142, 20, 25, 108, 235, 222, 207, 85, 205]) }, { traceIndex := 13, logicalIndex := 13, semanticRowDigest := (bytes [151, 239, 244, 235, 40, 49, 123, 67, 148, 116, 73, 209, 72, 190, 170, 68, 89, 250, 89, 157, 238, 251, 139, 18, 200, 162, 217, 58, 56, 15, 0, 154]), rowLocalCcsAcceptanceDigest := (bytes [41, 199, 191, 81, 159, 104, 199, 2, 210, 200, 33, 171, 255, 217, 237, 20, 31, 219, 25, 236, 193, 252, 116, 99, 164, 69, 61, 211, 155, 23, 36, 112]), preparedStepBindingDigest := (bytes [76, 132, 48, 195, 214, 228, 209, 236, 198, 44, 194, 138, 89, 163, 55, 79, 123, 118, 251, 2, 198, 82, 187, 223, 64, 157, 178, 184, 138, 109, 161, 204]), publicStepDigest := (bytes [201, 217, 243, 231, 62, 18, 83, 190, 92, 15, 3, 50, 155, 186, 29, 147, 169, 150, 109, 213, 171, 210, 233, 144, 250, 177, 110, 132, 156, 19, 182, 174]), digest := (bytes [60, 117, 1, 187, 204, 222, 146, 85, 122, 3, 131, 214, 66, 100, 122, 105, 233, 198, 67, 204, 193, 196, 0, 216, 29, 97, 104, 182, 109, 239, 98, 114]) }]

def rootExecution : RootExecutionBundleView :=
  {
    executionRows := rootExecutionExecutionRows
    , semanticRows := rootExecutionSemanticRows
    , semanticRowsDigest := (bytes [15, 37, 86, 76, 184, 62, 76, 209, 122, 70, 16, 53, 62, 4, 218, 140, 38, 22, 71, 21, 78, 10, 23, 122, 196, 53, 1, 13, 58, 250, 219, 51])
    , preparedStepBindings := { bindings := rootExecutionPreparedBindings, bindingCount := 14, firstBindingDigest := (some (bytes [21, 175, 100, 171, 175, 91, 213, 179, 96, 169, 117, 230, 223, 52, 10, 73, 248, 8, 221, 2, 87, 30, 20, 63, 76, 181, 185, 91, 83, 60, 174, 36])), lastBindingDigest := (some (bytes [76, 132, 48, 195, 214, 228, 209, 236, 198, 44, 194, 138, 89, 163, 55, 79, 123, 118, 251, 2, 198, 82, 187, 223, 64, 157, 178, 184, 138, 109, 161, 204])), digest := (bytes [49, 15, 156, 222, 222, 132, 248, 219, 86, 74, 177, 173, 126, 92, 88, 142, 71, 233, 147, 61, 144, 74, 40, 78, 93, 229, 111, 147, 78, 221, 224, 124]) }
    , rowChunkRoutes := rootExecutionRowChunkRoutes
    , rowChunkRoutesDigest := (bytes [31, 198, 49, 36, 227, 179, 69, 11, 12, 162, 182, 190, 148, 140, 214, 39, 221, 243, 102, 239, 45, 242, 25, 129, 189, 122, 159, 99, 209, 169, 203, 52])
    , rowLocalCcsAcceptance := { acceptances := rootExecutionRowLocalCcsAcceptance, acceptanceCount := 14, firstAcceptanceDigest := (some (bytes [234, 245, 12, 208, 195, 17, 2, 214, 37, 2, 180, 85, 178, 255, 128, 115, 69, 190, 63, 23, 94, 25, 63, 40, 68, 224, 142, 88, 64, 167, 152, 92])), lastAcceptanceDigest := (some (bytes [41, 199, 191, 81, 159, 104, 199, 2, 210, 200, 33, 171, 255, 217, 237, 20, 31, 219, 25, 236, 193, 252, 116, 99, 164, 69, 61, 211, 155, 23, 36, 112])), digest := (bytes [6, 103, 168, 237, 117, 96, 109, 228, 63, 79, 182, 170, 172, 63, 9, 107, 113, 76, 184, 250, 233, 51, 108, 112, 25, 125, 108, 50, 189, 244, 188, 52]) }
    , executionSemanticsRefinement := { refinements := rootExecutionExecutionSemanticsRefinement, refinementCount := 14, firstRefinementDigest := (some (bytes [231, 191, 38, 205, 72, 151, 50, 74, 42, 206, 91, 169, 128, 112, 151, 58, 13, 134, 160, 153, 208, 195, 66, 139, 214, 134, 132, 69, 114, 195, 172, 239])), lastRefinementDigest := (some (bytes [60, 117, 1, 187, 204, 222, 146, 85, 122, 3, 131, 214, 66, 100, 122, 105, 233, 198, 67, 204, 193, 196, 0, 216, 29, 97, 104, 182, 109, 239, 98, 114])), digest := (bytes [97, 166, 40, 0, 176, 22, 79, 117, 164, 141, 87, 139, 139, 22, 88, 190, 215, 12, 75, 133, 43, 230, 28, 244, 126, 130, 41, 21, 58, 210, 192, 43]) }
    , familyDigest := (bytes [21, 45, 25, 215, 138, 137, 7, 133, 215, 110, 157, 80, 190, 214, 195, 121, 158, 12, 227, 251, 45, 243, 101, 206, 199, 100, 36, 105, 152, 72, 2, 50])
    , digest := (bytes [215, 74, 235, 100, 154, 170, 55, 36, 86, 9, 57, 170, 22, 0, 182, 208, 172, 196, 187, 132, 112, 22, 102, 85, 41, 99, 74, 62, 201, 227, 21, 7])
  }

def kernelOpeningBundle : SimpleKernelOpeningBundleView :=
  {
    claim := { bindings := { stageClaimBundleDigest := (bytes [216, 32, 228, 212, 19, 254, 160, 162, 75, 41, 38, 216, 58, 20, 142, 66, 97, 224, 122, 73, 33, 212, 76, 206, 137, 158, 21, 56, 129, 251, 202, 238]), stagePackageBundleDigest := (bytes [189, 31, 79, 14, 204, 208, 208, 71, 134, 15, 236, 185, 181, 28, 81, 145, 219, 208, 251, 41, 93, 43, 132, 149, 208, 180, 210, 74, 29, 67, 229, 6]), stage1PackageDigest := (bytes [51, 63, 211, 186, 53, 109, 214, 181, 53, 47, 220, 172, 153, 111, 64, 147, 58, 164, 115, 119, 49, 122, 105, 76, 55, 28, 186, 147, 134, 23, 195, 34]), stage2PackageDigest := (bytes [241, 163, 5, 223, 23, 221, 24, 134, 104, 142, 140, 248, 100, 214, 117, 54, 151, 122, 237, 155, 109, 20, 173, 192, 160, 221, 211, 80, 50, 211, 55, 77]), stage3PackageDigest := (bytes [185, 92, 17, 202, 45, 12, 222, 226, 100, 195, 61, 245, 228, 18, 236, 184, 35, 105, 128, 226, 194, 228, 196, 136, 241, 250, 141, 81, 14, 6, 246, 103]), preparedStepBindingsDigest := (bytes [49, 15, 156, 222, 222, 132, 248, 219, 86, 74, 177, 173, 126, 92, 88, 142, 71, 233, 147, 61, 144, 74, 40, 78, 93, 229, 111, 147, 78, 221, 224, 124]), bindingCount := 14, stage1RowCount := 14, stage2RegisterReadCount := 17, stage2RegisterWriteCount := 12, stage2RamEventCount := 0, stage3ContinuityCount := 14, points := { firstBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [49, 15, 156, 222, 222, 132, 248, 219, 86, 74, 177, 173, 126, 92, 88, 142, 71, 233, 147, 61, 144, 74, 40, 78, 93, 229, 111, 147, 78, 221, 224, 124]), layoutVersion := 1, digest := (bytes [148, 225, 182, 249, 33, 121, 221, 60, 45, 225, 148, 145, 66, 220, 25, 19, 95, 73, 239, 99, 45, 34, 161, 141, 224, 133, 22, 29, 20, 36, 214, 136]) }, logicalIndex := 0, digest := (bytes [143, 209, 87, 165, 164, 36, 231, 171, 98, 102, 159, 116, 29, 214, 239, 71, 103, 190, 112, 226, 114, 192, 146, 55, 56, 32, 198, 247, 114, 201, 18, 250]) }, valueDigest := (bytes [21, 175, 100, 171, 175, 91, 213, 179, 96, 169, 117, 230, 223, 52, 10, 73, 248, 8, 221, 2, 87, 30, 20, 63, 76, 181, 185, 91, 83, 60, 174, 36]), digest := (bytes [12, 171, 148, 186, 32, 183, 81, 29, 86, 96, 122, 78, 236, 114, 146, 193, 121, 218, 67, 109, 125, 104, 69, 207, 238, 120, 45, 88, 20, 143, 243, 171]) }), lastBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [49, 15, 156, 222, 222, 132, 248, 219, 86, 74, 177, 173, 126, 92, 88, 142, 71, 233, 147, 61, 144, 74, 40, 78, 93, 229, 111, 147, 78, 221, 224, 124]), layoutVersion := 1, digest := (bytes [148, 225, 182, 249, 33, 121, 221, 60, 45, 225, 148, 145, 66, 220, 25, 19, 95, 73, 239, 99, 45, 34, 161, 141, 224, 133, 22, 29, 20, 36, 214, 136]) }, logicalIndex := 13, digest := (bytes [158, 102, 97, 20, 5, 121, 84, 148, 38, 241, 138, 109, 56, 131, 62, 120, 15, 200, 225, 145, 238, 194, 139, 25, 7, 144, 140, 157, 209, 79, 66, 42]) }, valueDigest := (bytes [76, 132, 48, 195, 214, 228, 209, 236, 198, 44, 194, 138, 89, 163, 55, 79, 123, 118, 251, 2, 198, 82, 187, 223, 64, 157, 178, 184, 138, 109, 161, 204]), digest := (bytes [229, 41, 222, 103, 45, 22, 99, 222, 164, 60, 245, 6, 176, 220, 237, 129, 192, 178, 209, 182, 58, 103, 158, 132, 121, 140, 13, 7, 97, 206, 57, 136]) }) }, digest := (bytes [162, 231, 17, 252, 230, 243, 163, 48, 250, 255, 59, 9, 223, 84, 191, 198, 13, 77, 254, 147, 238, 245, 76, 85, 185, 97, 1, 199, 120, 113, 133, 53]) }, preparedSteps := { executionDigest := (bytes [160, 227, 4, 85, 140, 249, 7, 83, 176, 183, 120, 10, 187, 25, 9, 75, 146, 246, 100, 53, 9, 137, 26, 48, 91, 20, 9, 143, 92, 16, 180, 9]), finalStateDigest := (bytes [67, 56, 221, 172, 183, 26, 231, 188, 189, 215, 247, 181, 112, 58, 232, 221, 188, 253, 63, 175, 15, 72, 182, 206, 231, 128, 239, 141, 249, 6, 198, 30]), transcriptFinalDigest := (bytes [255, 162, 77, 246, 129, 21, 164, 58, 53, 80, 254, 105, 110, 191, 166, 158, 207, 191, 64, 245, 94, 196, 161, 174, 176, 99, 160, 206, 72, 229, 27, 189]), preparedStepCount := 14, finalPc := 56, halted := true, points := { firstPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [219, 195, 168, 58, 246, 163, 92, 165, 69, 68, 110, 143, 93, 49, 110, 10, 179, 183, 197, 231, 89, 147, 118, 24, 213, 113, 174, 182, 139, 68, 78, 10]), layoutVersion := 3, digest := (bytes [54, 65, 220, 157, 10, 119, 33, 155, 19, 18, 245, 163, 208, 135, 18, 19, 24, 227, 38, 183, 95, 97, 46, 170, 116, 249, 170, 121, 2, 11, 204, 182]) }, logicalIndex := 0, digest := (bytes [241, 115, 53, 60, 47, 124, 25, 29, 82, 180, 123, 91, 122, 32, 206, 112, 208, 0, 206, 191, 62, 203, 101, 97, 201, 179, 232, 144, 237, 192, 143, 121]) }, valueDigest := (bytes [195, 104, 190, 242, 104, 180, 234, 122, 108, 245, 168, 232, 122, 59, 5, 141, 148, 97, 161, 16, 201, 133, 162, 230, 49, 127, 153, 215, 226, 163, 192, 66]), digest := (bytes [89, 78, 226, 130, 74, 6, 255, 150, 236, 10, 155, 172, 163, 196, 73, 50, 37, 76, 115, 142, 113, 231, 224, 168, 209, 76, 106, 244, 171, 66, 169, 154]) }), lastPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [219, 195, 168, 58, 246, 163, 92, 165, 69, 68, 110, 143, 93, 49, 110, 10, 179, 183, 197, 231, 89, 147, 118, 24, 213, 113, 174, 182, 139, 68, 78, 10]), layoutVersion := 3, digest := (bytes [54, 65, 220, 157, 10, 119, 33, 155, 19, 18, 245, 163, 208, 135, 18, 19, 24, 227, 38, 183, 95, 97, 46, 170, 116, 249, 170, 121, 2, 11, 204, 182]) }, logicalIndex := 13, digest := (bytes [185, 1, 193, 126, 91, 144, 233, 178, 197, 252, 245, 92, 123, 155, 197, 155, 10, 196, 139, 217, 152, 18, 84, 207, 109, 8, 90, 93, 226, 254, 153, 106]) }, valueDigest := (bytes [228, 218, 132, 173, 40, 175, 163, 113, 77, 51, 14, 129, 172, 72, 64, 113, 166, 5, 209, 86, 65, 181, 139, 164, 241, 195, 58, 252, 148, 133, 40, 21]), digest := (bytes [100, 245, 202, 28, 32, 25, 16, 215, 85, 76, 248, 178, 234, 220, 79, 156, 168, 40, 235, 229, 37, 100, 64, 184, 15, 144, 28, 188, 217, 69, 155, 173]) }) }, digest := (bytes [212, 62, 86, 152, 24, 114, 227, 192, 100, 76, 149, 138, 86, 102, 191, 92, 229, 101, 160, 75, 101, 37, 231, 143, 179, 209, 92, 49, 94, 19, 206, 226]) }, digest := (bytes [233, 118, 64, 129, 165, 249, 195, 188, 13, 127, 117, 113, 7, 236, 106, 87, 47, 166, 208, 183, 46, 103, 181, 137, 164, 184, 174, 225, 49, 52, 15, 52]) }
    , bindings := { claim := { stageClaimBundleDigest := (bytes [216, 32, 228, 212, 19, 254, 160, 162, 75, 41, 38, 216, 58, 20, 142, 66, 97, 224, 122, 73, 33, 212, 76, 206, 137, 158, 21, 56, 129, 251, 202, 238]), stagePackageBundleDigest := (bytes [189, 31, 79, 14, 204, 208, 208, 71, 134, 15, 236, 185, 181, 28, 81, 145, 219, 208, 251, 41, 93, 43, 132, 149, 208, 180, 210, 74, 29, 67, 229, 6]), stage1PackageDigest := (bytes [51, 63, 211, 186, 53, 109, 214, 181, 53, 47, 220, 172, 153, 111, 64, 147, 58, 164, 115, 119, 49, 122, 105, 76, 55, 28, 186, 147, 134, 23, 195, 34]), stage2PackageDigest := (bytes [241, 163, 5, 223, 23, 221, 24, 134, 104, 142, 140, 248, 100, 214, 117, 54, 151, 122, 237, 155, 109, 20, 173, 192, 160, 221, 211, 80, 50, 211, 55, 77]), stage3PackageDigest := (bytes [185, 92, 17, 202, 45, 12, 222, 226, 100, 195, 61, 245, 228, 18, 236, 184, 35, 105, 128, 226, 194, 228, 196, 136, 241, 250, 141, 81, 14, 6, 246, 103]), preparedStepBindingsDigest := (bytes [49, 15, 156, 222, 222, 132, 248, 219, 86, 74, 177, 173, 126, 92, 88, 142, 71, 233, 147, 61, 144, 74, 40, 78, 93, 229, 111, 147, 78, 221, 224, 124]), bindingCount := 14, stage1RowCount := 14, stage2RegisterReadCount := 17, stage2RegisterWriteCount := 12, stage2RamEventCount := 0, stage3ContinuityCount := 14, points := { firstBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [49, 15, 156, 222, 222, 132, 248, 219, 86, 74, 177, 173, 126, 92, 88, 142, 71, 233, 147, 61, 144, 74, 40, 78, 93, 229, 111, 147, 78, 221, 224, 124]), layoutVersion := 1, digest := (bytes [148, 225, 182, 249, 33, 121, 221, 60, 45, 225, 148, 145, 66, 220, 25, 19, 95, 73, 239, 99, 45, 34, 161, 141, 224, 133, 22, 29, 20, 36, 214, 136]) }, logicalIndex := 0, digest := (bytes [143, 209, 87, 165, 164, 36, 231, 171, 98, 102, 159, 116, 29, 214, 239, 71, 103, 190, 112, 226, 114, 192, 146, 55, 56, 32, 198, 247, 114, 201, 18, 250]) }, valueDigest := (bytes [21, 175, 100, 171, 175, 91, 213, 179, 96, 169, 117, 230, 223, 52, 10, 73, 248, 8, 221, 2, 87, 30, 20, 63, 76, 181, 185, 91, 83, 60, 174, 36]), digest := (bytes [12, 171, 148, 186, 32, 183, 81, 29, 86, 96, 122, 78, 236, 114, 146, 193, 121, 218, 67, 109, 125, 104, 69, 207, 238, 120, 45, 88, 20, 143, 243, 171]) }), lastBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [49, 15, 156, 222, 222, 132, 248, 219, 86, 74, 177, 173, 126, 92, 88, 142, 71, 233, 147, 61, 144, 74, 40, 78, 93, 229, 111, 147, 78, 221, 224, 124]), layoutVersion := 1, digest := (bytes [148, 225, 182, 249, 33, 121, 221, 60, 45, 225, 148, 145, 66, 220, 25, 19, 95, 73, 239, 99, 45, 34, 161, 141, 224, 133, 22, 29, 20, 36, 214, 136]) }, logicalIndex := 13, digest := (bytes [158, 102, 97, 20, 5, 121, 84, 148, 38, 241, 138, 109, 56, 131, 62, 120, 15, 200, 225, 145, 238, 194, 139, 25, 7, 144, 140, 157, 209, 79, 66, 42]) }, valueDigest := (bytes [76, 132, 48, 195, 214, 228, 209, 236, 198, 44, 194, 138, 89, 163, 55, 79, 123, 118, 251, 2, 198, 82, 187, 223, 64, 157, 178, 184, 138, 109, 161, 204]), digest := (bytes [229, 41, 222, 103, 45, 22, 99, 222, 164, 60, 245, 6, 176, 220, 237, 129, 192, 178, 209, 182, 58, 103, 158, 132, 121, 140, 13, 7, 97, 206, 57, 136]) }) }, digest := (bytes [162, 231, 17, 252, 230, 243, 163, 48, 250, 255, 59, 9, 223, 84, 191, 198, 13, 77, 254, 147, 238, 245, 76, 85, 185, 97, 1, 199, 120, 113, 133, 53]) }, packaged := { statementDigest := (bytes [203, 249, 43, 198, 84, 4, 141, 94, 195, 73, 120, 105, 194, 26, 111, 138, 156, 134, 242, 212, 239, 77, 206, 223, 203, 183, 252, 44, 88, 29, 192, 250]), proofDigest := (bytes [157, 43, 206, 64, 112, 187, 183, 26, 241, 119, 177, 9, 71, 16, 129, 149, 161, 91, 1, 181, 22, 92, 113, 250, 94, 16, 101, 118, 5, 166, 182, 111]) }, digest := (bytes [146, 69, 160, 136, 176, 177, 104, 110, 60, 43, 120, 212, 38, 199, 157, 204, 134, 99, 251, 149, 77, 23, 66, 175, 77, 128, 36, 224, 204, 56, 59, 142]) }
    , preparedSteps := { claim := { executionDigest := (bytes [160, 227, 4, 85, 140, 249, 7, 83, 176, 183, 120, 10, 187, 25, 9, 75, 146, 246, 100, 53, 9, 137, 26, 48, 91, 20, 9, 143, 92, 16, 180, 9]), finalStateDigest := (bytes [67, 56, 221, 172, 183, 26, 231, 188, 189, 215, 247, 181, 112, 58, 232, 221, 188, 253, 63, 175, 15, 72, 182, 206, 231, 128, 239, 141, 249, 6, 198, 30]), transcriptFinalDigest := (bytes [255, 162, 77, 246, 129, 21, 164, 58, 53, 80, 254, 105, 110, 191, 166, 158, 207, 191, 64, 245, 94, 196, 161, 174, 176, 99, 160, 206, 72, 229, 27, 189]), preparedStepCount := 14, finalPc := 56, halted := true, points := { firstPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [219, 195, 168, 58, 246, 163, 92, 165, 69, 68, 110, 143, 93, 49, 110, 10, 179, 183, 197, 231, 89, 147, 118, 24, 213, 113, 174, 182, 139, 68, 78, 10]), layoutVersion := 3, digest := (bytes [54, 65, 220, 157, 10, 119, 33, 155, 19, 18, 245, 163, 208, 135, 18, 19, 24, 227, 38, 183, 95, 97, 46, 170, 116, 249, 170, 121, 2, 11, 204, 182]) }, logicalIndex := 0, digest := (bytes [241, 115, 53, 60, 47, 124, 25, 29, 82, 180, 123, 91, 122, 32, 206, 112, 208, 0, 206, 191, 62, 203, 101, 97, 201, 179, 232, 144, 237, 192, 143, 121]) }, valueDigest := (bytes [195, 104, 190, 242, 104, 180, 234, 122, 108, 245, 168, 232, 122, 59, 5, 141, 148, 97, 161, 16, 201, 133, 162, 230, 49, 127, 153, 215, 226, 163, 192, 66]), digest := (bytes [89, 78, 226, 130, 74, 6, 255, 150, 236, 10, 155, 172, 163, 196, 73, 50, 37, 76, 115, 142, 113, 231, 224, 168, 209, 76, 106, 244, 171, 66, 169, 154]) }), lastPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [219, 195, 168, 58, 246, 163, 92, 165, 69, 68, 110, 143, 93, 49, 110, 10, 179, 183, 197, 231, 89, 147, 118, 24, 213, 113, 174, 182, 139, 68, 78, 10]), layoutVersion := 3, digest := (bytes [54, 65, 220, 157, 10, 119, 33, 155, 19, 18, 245, 163, 208, 135, 18, 19, 24, 227, 38, 183, 95, 97, 46, 170, 116, 249, 170, 121, 2, 11, 204, 182]) }, logicalIndex := 13, digest := (bytes [185, 1, 193, 126, 91, 144, 233, 178, 197, 252, 245, 92, 123, 155, 197, 155, 10, 196, 139, 217, 152, 18, 84, 207, 109, 8, 90, 93, 226, 254, 153, 106]) }, valueDigest := (bytes [228, 218, 132, 173, 40, 175, 163, 113, 77, 51, 14, 129, 172, 72, 64, 113, 166, 5, 209, 86, 65, 181, 139, 164, 241, 195, 58, 252, 148, 133, 40, 21]), digest := (bytes [100, 245, 202, 28, 32, 25, 16, 215, 85, 76, 248, 178, 234, 220, 79, 156, 168, 40, 235, 229, 37, 100, 64, 184, 15, 144, 28, 188, 217, 69, 155, 173]) }) }, digest := (bytes [212, 62, 86, 152, 24, 114, 227, 192, 100, 76, 149, 138, 86, 102, 191, 92, 229, 101, 160, 75, 101, 37, 231, 143, 179, 209, 92, 49, 94, 19, 206, 226]) }, packaged := { statementDigest := (bytes [73, 154, 142, 166, 169, 53, 39, 0, 121, 104, 148, 171, 150, 97, 26, 121, 229, 179, 239, 240, 199, 84, 178, 219, 53, 30, 244, 207, 71, 13, 102, 169]), proofDigest := (bytes [84, 54, 148, 107, 238, 147, 188, 184, 182, 91, 43, 89, 176, 10, 77, 124, 225, 114, 124, 238, 36, 179, 41, 113, 4, 87, 21, 72, 71, 171, 183, 114]) }, digest := (bytes [194, 38, 40, 76, 72, 198, 130, 9, 251, 15, 187, 205, 206, 52, 19, 22, 121, 122, 44, 210, 35, 167, 39, 30, 166, 51, 1, 38, 6, 6, 143, 194]) }
    , digest := (bytes [211, 255, 49, 81, 169, 115, 42, 68, 80, 117, 32, 168, 72, 90, 186, 205, 250, 15, 188, 208, 218, 121, 98, 163, 63, 168, 237, 110, 93, 53, 180, 67])
  }

def stepComposition : StepCompositionSurfaceView :=
  {
    stage1SemanticsDigest := (bytes [201, 82, 248, 5, 165, 255, 118, 9, 193, 52, 162, 52, 136, 212, 17, 253, 69, 170, 62, 206, 248, 48, 102, 43, 176, 51, 60, 231, 68, 100, 197, 230])
    , stage2SemanticsDigest := (bytes [98, 191, 161, 56, 236, 205, 20, 146, 160, 24, 161, 107, 167, 248, 37, 131, 208, 23, 245, 187, 105, 79, 1, 192, 38, 53, 59, 112, 77, 242, 79, 102])
    , stage2TemporalDigest := (bytes [188, 198, 233, 179, 54, 216, 133, 72, 82, 81, 189, 46, 183, 112, 197, 64, 191, 181, 11, 252, 55, 118, 125, 208, 30, 28, 159, 167, 62, 71, 152, 17])
    , stage3SemanticsDigest := (bytes [93, 95, 54, 194, 166, 247, 41, 85, 8, 151, 179, 253, 234, 181, 113, 103, 109, 155, 101, 76, 22, 166, 91, 233, 207, 227, 217, 247, 151, 125, 86, 175])
    , rootExecutionDigest := (bytes [215, 74, 235, 100, 154, 170, 55, 36, 86, 9, 57, 170, 22, 0, 182, 208, 172, 196, 187, 132, 112, 22, 102, 85, 41, 99, 74, 62, 201, 227, 21, 7])
    , preparedStepBindingsDigest := (bytes [49, 15, 156, 222, 222, 132, 248, 219, 86, 74, 177, 173, 126, 92, 88, 142, 71, 233, 147, 61, 144, 74, 40, 78, 93, 229, 111, 147, 78, 221, 224, 124])
    , rowChunkRoutesDigest := (bytes [31, 198, 49, 36, 227, 179, 69, 11, 12, 162, 182, 190, 148, 140, 214, 39, 221, 243, 102, 239, 45, 242, 25, 129, 189, 122, 159, 99, 209, 169, 203, 52])
    , realRowCount := 14
    , preparedStepCount := 14
    , firstRealStepIndex := 0
    , lastRealStepIndex := 13
    , initialPc := 0
    , finalPc := 56
    , halted := true
    , digest := (bytes [241, 115, 249, 175, 195, 65, 137, 203, 101, 75, 240, 146, 167, 135, 18, 15, 220, 243, 99, 119, 233, 213, 67, 108, 234, 124, 29, 90, 198, 231, 99, 108])
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
    name := "native_logic_compare_chain_ecall"
    , source := {
  manifest := { name := "native_logic_compare_chain_ecall", fixtureId := "native_logic_compare_chain_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , startPc := 0
  , programWords := [5243027, 3146003, 2159027, 6353427, 2155187, 8479507, 2147251, 7390227, 1123507, 4269331, 1127859, 4240915, 15, 115]
  , initialRegisters := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , initialMemory := []
  , transcriptSeed := (bytes [114, 118, 54, 52, 105, 109, 45, 110, 97, 116, 105, 118, 101, 45, 108, 111, 103, 105, 99, 45, 99, 111, 109, 112, 97, 114, 101, 45, 118, 49])
}
    , derived := {
  manifest := { name := "native_logic_compare_chain_ecall", fixtureId := "native_logic_compare_chain_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
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
  , word := 3146003
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
  traceIndex := 2
  , stepIndex := 2
  , sequenceIndex := 0
  , pc := 8
  , nextPc := 12
  , word := 2159027
  , opcode := .and
  , traceOpcode := (some .and)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 5
  , rs2 := 2
  , rs2Value := 3
  , rd := 3
  , rdBefore := 0
  , rdAfter := 1
  , imm := 0
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
  traceIndex := 3
  , stepIndex := 3
  , sequenceIndex := 0
  , pc := 12
  , nextPc := 16
  , word := 6353427
  , opcode := .andi
  , traceOpcode := (some .andi)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 5
  , rs2 := 0
  , rs2Value := 0
  , rd := 4
  , rdBefore := 0
  , rdAfter := 4
  , imm := 6
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
  , word := 2155187
  , opcode := .or
  , traceOpcode := (some .or)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 5
  , rs2 := 2
  , rs2Value := 3
  , rd := 5
  , rdBefore := 0
  , rdAfter := 7
  , imm := 0
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
  traceIndex := 5
  , stepIndex := 5
  , sequenceIndex := 0
  , pc := 20
  , nextPc := 24
  , word := 8479507
  , opcode := .ori
  , traceOpcode := (some .ori)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 2
  , rs1Value := 3
  , rs2 := 0
  , rs2Value := 0
  , rd := 6
  , rdBefore := 0
  , rdAfter := 11
  , imm := 8
  , aluResult := 11
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
  , word := 2147251
  , opcode := .xor
  , traceOpcode := (some .xor)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 5
  , rs2 := 2
  , rs2Value := 3
  , rd := 7
  , rdBefore := 0
  , rdAfter := 6
  , imm := 0
  , aluResult := 6
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
  , word := 7390227
  , opcode := .xori
  , traceOpcode := (some .xori)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 5
  , rs2 := 0
  , rs2Value := 0
  , rd := 8
  , rdBefore := 0
  , rdAfter := 2
  , imm := 7
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
  , word := 1123507
  , opcode := .slt
  , traceOpcode := (some .slt)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 2
  , rs1Value := 3
  , rs2 := 1
  , rs2Value := 5
  , rd := 9
  , rdBefore := 0
  , rdAfter := 1
  , imm := 0
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
  traceIndex := 9
  , stepIndex := 9
  , sequenceIndex := 0
  , pc := 36
  , nextPc := 40
  , word := 4269331
  , opcode := .slti
  , traceOpcode := (some .slti)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 2
  , rs1Value := 3
  , rs2 := 0
  , rs2Value := 0
  , rd := 10
  , rdBefore := 0
  , rdAfter := 1
  , imm := 4
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
  traceIndex := 10
  , stepIndex := 10
  , sequenceIndex := 0
  , pc := 40
  , nextPc := 44
  , word := 1127859
  , opcode := .sltu
  , traceOpcode := (some .sltu)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 2
  , rs1Value := 3
  , rs2 := 1
  , rs2Value := 5
  , rd := 11
  , rdBefore := 0
  , rdAfter := 1
  , imm := 0
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
  traceIndex := 11
  , stepIndex := 11
  , sequenceIndex := 0
  , pc := 44
  , nextPc := 48
  , word := 4240915
  , opcode := .sltiu
  , traceOpcode := (some .sltiu)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 5
  , rs2 := 0
  , rs2Value := 0
  , rd := 12
  , rdBefore := 0
  , rdAfter := 0
  , imm := 4
  , aluResult := 0
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
  traceIndex := 12
  , stepIndex := 12
  , sequenceIndex := 0
  , pc := 48
  , nextPc := 52
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
  traceIndex := 13
  , stepIndex := 13
  , sequenceIndex := 0
  , pc := 52
  , nextPc := 56
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
  , stage1 := { rows := [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 5243027, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 4, aluResult := 5, effectiveAddr := none, writesRd := true, rd := 1, rdAfter := 5, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 3146003, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 8, aluResult := 3, effectiveAddr := none, writesRd := true, rd := 2, rdAfter := 3, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 2159027, opcode := .and, traceOpcode := (some .and), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 12, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 3, rdAfter := 1, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 12, fetchedWord := 6353427, opcode := .andi, traceOpcode := (some .andi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 16, aluResult := 4, effectiveAddr := none, writesRd := true, rd := 4, rdAfter := 4, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 4, stepIndex := 4, sequenceIndex := 0, fetchPc := 16, fetchedWord := 2155187, opcode := .or, traceOpcode := (some .or), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 20, aluResult := 7, effectiveAddr := none, writesRd := true, rd := 5, rdAfter := 7, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 5, stepIndex := 5, sequenceIndex := 0, fetchPc := 20, fetchedWord := 8479507, opcode := .ori, traceOpcode := (some .ori), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 24, aluResult := 11, effectiveAddr := none, writesRd := true, rd := 6, rdAfter := 11, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 6, stepIndex := 6, sequenceIndex := 0, fetchPc := 24, fetchedWord := 2147251, opcode := .xor, traceOpcode := (some .xor), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 28, aluResult := 6, effectiveAddr := none, writesRd := true, rd := 7, rdAfter := 6, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 7, stepIndex := 7, sequenceIndex := 0, fetchPc := 28, fetchedWord := 7390227, opcode := .xori, traceOpcode := (some .xori), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 32, aluResult := 2, effectiveAddr := none, writesRd := true, rd := 8, rdAfter := 2, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 8, stepIndex := 8, sequenceIndex := 0, fetchPc := 32, fetchedWord := 1123507, opcode := .slt, traceOpcode := (some .slt), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 36, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 9, rdAfter := 1, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 9, stepIndex := 9, sequenceIndex := 0, fetchPc := 36, fetchedWord := 4269331, opcode := .slti, traceOpcode := (some .slti), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 40, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 10, rdAfter := 1, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 10, stepIndex := 10, sequenceIndex := 0, fetchPc := 40, fetchedWord := 1127859, opcode := .sltu, traceOpcode := (some .sltu), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 44, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 11, rdAfter := 1, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 11, stepIndex := 11, sequenceIndex := 0, fetchPc := 44, fetchedWord := 4240915, opcode := .sltiu, traceOpcode := (some .sltiu), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 48, aluResult := 0, effectiveAddr := none, writesRd := true, rd := 12, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 12, stepIndex := 12, sequenceIndex := 0, fetchPc := 48, fetchedWord := 15, opcode := .fence, traceOpcode := (some .fence), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 52, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }, { traceIndex := 13, stepIndex := 13, sequenceIndex := 0, fetchPc := 52, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 56, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }] }
  , stage2 := {
  registerReads := [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 0, value := 0 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 0, value := 0 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 1, value := 5 }, { traceIndex := 2, stepIndex := 2, role := .rs2, reg := 2, value := 3 }, { traceIndex := 3, stepIndex := 3, role := .rs1, reg := 1, value := 5 }, { traceIndex := 4, stepIndex := 4, role := .rs1, reg := 1, value := 5 }, { traceIndex := 4, stepIndex := 4, role := .rs2, reg := 2, value := 3 }, { traceIndex := 5, stepIndex := 5, role := .rs1, reg := 2, value := 3 }, { traceIndex := 6, stepIndex := 6, role := .rs1, reg := 1, value := 5 }, { traceIndex := 6, stepIndex := 6, role := .rs2, reg := 2, value := 3 }, { traceIndex := 7, stepIndex := 7, role := .rs1, reg := 1, value := 5 }, { traceIndex := 8, stepIndex := 8, role := .rs1, reg := 2, value := 3 }, { traceIndex := 8, stepIndex := 8, role := .rs2, reg := 1, value := 5 }, { traceIndex := 9, stepIndex := 9, role := .rs1, reg := 2, value := 3 }, { traceIndex := 10, stepIndex := 10, role := .rs1, reg := 2, value := 3 }, { traceIndex := 10, stepIndex := 10, role := .rs2, reg := 1, value := 5 }, { traceIndex := 11, stepIndex := 11, role := .rs1, reg := 1, value := 5 }]
  , registerWrites := [{ traceIndex := 0, stepIndex := 0, reg := 1, previous := 0, next := 5 }, { traceIndex := 1, stepIndex := 1, reg := 2, previous := 0, next := 3 }, { traceIndex := 2, stepIndex := 2, reg := 3, previous := 0, next := 1 }, { traceIndex := 3, stepIndex := 3, reg := 4, previous := 0, next := 4 }, { traceIndex := 4, stepIndex := 4, reg := 5, previous := 0, next := 7 }, { traceIndex := 5, stepIndex := 5, reg := 6, previous := 0, next := 11 }, { traceIndex := 6, stepIndex := 6, reg := 7, previous := 0, next := 6 }, { traceIndex := 7, stepIndex := 7, reg := 8, previous := 0, next := 2 }, { traceIndex := 8, stepIndex := 8, reg := 9, previous := 0, next := 1 }, { traceIndex := 9, stepIndex := 9, reg := 10, previous := 0, next := 1 }, { traceIndex := 10, stepIndex := 10, reg := 11, previous := 0, next := 1 }, { traceIndex := 11, stepIndex := 11, reg := 12, previous := 0, next := 0 }]
  , ramEvents := []
  , twistLinks := [{ traceIndex := 0, stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 5), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 1, family := .nativeAlu, routedWriteValue := (some 3), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 2, family := .nativeAlu, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 3, family := .nativeAlu, routedWriteValue := (some 4), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 4, stepIndex := 4, family := .nativeAlu, routedWriteValue := (some 7), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 5, stepIndex := 5, family := .nativeAlu, routedWriteValue := (some 11), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 6, stepIndex := 6, family := .nativeAlu, routedWriteValue := (some 6), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 7, stepIndex := 7, family := .nativeAlu, routedWriteValue := (some 2), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 8, stepIndex := 8, family := .nativeAlu, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 9, stepIndex := 9, family := .nativeAlu, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 10, stepIndex := 10, family := .nativeAlu, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 11, stepIndex := 11, family := .nativeAlu, routedWriteValue := (some 0), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 12, stepIndex := 12, family := .nativeAlu, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 13, stepIndex := 13, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]
}
  , stage3 := {
  continuity := [{ stepIndex := 0, pc := 0, nextPc := 4, successorPc := (some 4), finalStep := false, continuityHolds := true }, { stepIndex := 1, pc := 4, nextPc := 8, successorPc := (some 8), finalStep := false, continuityHolds := true }, { stepIndex := 2, pc := 8, nextPc := 12, successorPc := (some 12), finalStep := false, continuityHolds := true }, { stepIndex := 3, pc := 12, nextPc := 16, successorPc := (some 16), finalStep := false, continuityHolds := true }, { stepIndex := 4, pc := 16, nextPc := 20, successorPc := (some 20), finalStep := false, continuityHolds := true }, { stepIndex := 5, pc := 20, nextPc := 24, successorPc := (some 24), finalStep := false, continuityHolds := true }, { stepIndex := 6, pc := 24, nextPc := 28, successorPc := (some 28), finalStep := false, continuityHolds := true }, { stepIndex := 7, pc := 28, nextPc := 32, successorPc := (some 32), finalStep := false, continuityHolds := true }, { stepIndex := 8, pc := 32, nextPc := 36, successorPc := (some 36), finalStep := false, continuityHolds := true }, { stepIndex := 9, pc := 36, nextPc := 40, successorPc := (some 40), finalStep := false, continuityHolds := true }, { stepIndex := 10, pc := 40, nextPc := 44, successorPc := (some 44), finalStep := false, continuityHolds := true }, { stepIndex := 11, pc := 44, nextPc := 48, successorPc := (some 48), finalStep := false, continuityHolds := true }, { stepIndex := 12, pc := 48, nextPc := 52, successorPc := (some 52), finalStep := false, continuityHolds := true }, { stepIndex := 13, pc := 52, nextPc := 56, successorPc := none, finalStep := true, continuityHolds := true }]
  , halted := true
}
  , transcript := {
  appLabel := (bytes [110, 101, 111, 46, 102, 111, 108, 100, 46, 110, 101, 120, 116, 47, 114, 118, 54, 52, 105, 109, 47, 112, 97, 114, 105, 116, 121, 95, 107, 101, 114, 110, 101, 108, 95, 118, 49])
  , events := [{
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 116, 114, 97, 110, 115, 99, 114, 105, 112, 116, 95, 115, 101, 101, 100])
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 110, 97, 116, 105, 118, 101, 45, 108, 111, 103, 105, 99, 45, 99, 111, 109, 112, 97, 114, 101, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [27915927687753580, 12777915887414639, 12662, 14004900292649954342, 13728117369159879657, 11693063383591262488, 17082852510017092719, 16363809030615601355], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [110, 97, 116, 105, 118, 101, 95, 108, 111, 103, 105, 99, 95, 99, 111, 109, 112, 97, 114, 101, 95, 99, 104, 97, 105, 110, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [27915927687753580, 12777915887414639, 12662, 14004900292649954342, 13728117369159879657, 11693063383591262488, 17082852510017092719, 16363809030615601355], absorbed := 3 }
  , cursorAfter := { stateWords := [28533900466808931, 1819042147, 14675078370321938727, 4574521486179947848, 5924462245161849131, 2698773299494092040, 9075337403133714940, 4191472899665087393], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [5243027, 3146003, 2159027, 6353427, 2155187, 8479507, 2147251, 7390227, 1123507, 4269331, 1127859, 4240915, 15, 115]
  , cursorBefore := { stateWords := [28533900466808931, 1819042147, 14675078370321938727, 4574521486179947848, 5924462245161849131, 2698773299494092040, 9075337403133714940, 4191472899665087393], absorbed := 2 }
  , cursorAfter := { stateWords := [3276447219741767340, 13078479345119520091, 12592238531974894527, 6748780606875837271, 4492818906924154559, 11103094219351273320, 3262392760021944179, 1928312561396356522], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [3276447219741767340, 13078479345119520091, 12592238531974894527, 6748780606875837271, 4492818906924154559, 11103094219351273320, 3262392760021944179, 1928312561396356522], absorbed := 0 }
  , cursorAfter := { stateWords := [0, 0, 10459399774905745288, 8328946169001223494, 5691556989607583735, 14974589011629786926, 738872076179659364, 16017586578460096676], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [0, 0, 10459399774905745288, 8328946169001223494, 5691556989607583735, 14974589011629786926, 738872076179659364, 16017586578460096676], absorbed := 2 }
  , cursorAfter := { stateWords := [13348506805888363, 30506403037277801, 34184295084289375, 0, 12756469965976968519, 2744792860478371236, 17860809758803000662, 15715310416387930124], absorbed := 4 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [160, 47, 136, 108, 204, 129, 79, 197, 229, 103, 193, 132, 46, 237, 116, 161, 76, 12, 119, 193, 191, 6, 227, 119, 236, 118, 88, 172, 48, 50, 35, 98])
  , u64s := []
  , cursorBefore := { stateWords := [13348506805888363, 30506403037277801, 34184295084289375, 0, 12756469965976968519, 2744792860478371236, 17860809758803000662, 15715310416387930124], absorbed := 4 }
  , cursorAfter := { stateWords := [53974437603352948, 48510963790897926, 1646473776, 13300600973611324196, 7380724067355609945, 9565502279824397969, 15874006747358156928, 15902665604271536949], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [53974437603352948, 48510963790897926, 1646473776, 13300600973611324196, 7380724067355609945, 9565502279824397969, 15874006747358156928, 15902665604271536949], absorbed := 3 }
  , cursorAfter := { stateWords := [3705222010059132808, 10705559429118986591, 1156729734218909101, 8423534567024735570, 9095578176136919767, 13676969085484049303, 1580895861586138354, 2032458426184116188], absorbed := 0 }
  , challengeOutput := (some 3705222010059132808)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [64, 180, 146, 246, 139, 60, 76, 212, 49, 131, 207, 237, 101, 254, 127, 102, 212, 72, 236, 89, 205, 253, 188, 71, 14, 72, 168, 245, 217, 88, 55, 93])
  , u64s := []
  , cursorBefore := { stateWords := [3705222010059132808, 10705559429118986591, 1156729734218909101, 8423534567024735570, 9095578176136919767, 13676969085484049303, 1580895861586138354, 2032458426184116188], absorbed := 0 }
  , cursorAfter := { stateWords := [57801241594717823, 69146396724804861, 1563908313, 15717703205190525445, 6907845539242118593, 14017363633327132095, 8563616863401045740, 7187696116192749015], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [57801241594717823, 69146396724804861, 1563908313, 15717703205190525445, 6907845539242118593, 14017363633327132095, 8563616863401045740, 7187696116192749015], absorbed := 3 }
  , cursorAfter := { stateWords := [7940266179000280847, 17128601962132279149, 1049842007288689975, 9265992555679375098, 10336381086471234629, 9918544998845487875, 2119026821034374262, 15723449175245520992], absorbed := 0 }
  , challengeOutput := (some 7940266179000280847)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [7940266179000280847, 17128601962132279149, 1049842007288689975, 9265992555679375098, 10336381086471234629, 9918544998845487875, 2119026821034374262, 15723449175245520992], absorbed := 0 }
  , cursorAfter := { stateWords := [4123130262336711476, 14111673298204184757, 5156360653013349129, 11211280577908904830, 803754858751632307, 5691479114664987180, 17877381527979292013, 14816230815792099199], absorbed := 0 }
  , challengeOutput := (some 4123130262336711476)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [52, 185, 8, 160, 143, 178, 154, 190, 101, 228, 204, 246, 221, 136, 74, 154, 136, 97, 99, 235, 127, 33, 115, 45, 30, 159, 243, 89, 15, 247, 157, 142])
  , u64s := []
  , cursorBefore := { stateWords := [4123130262336711476, 14111673298204184757, 5156360653013349129, 11211280577908904830, 803754858751632307, 5691479114664987180, 17877381527979292013, 14816230815792099199], absorbed := 0 }
  , cursorAfter := { stateWords := [36006134112885322, 25319137658893089, 2392717071, 18249389629117730808, 12336873607744378464, 14852699958375720157, 7400218705089070248, 6850034240698606523], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [36006134112885322, 25319137658893089, 2392717071, 18249389629117730808, 12336873607744378464, 14852699958375720157, 7400218705089070248, 6850034240698606523], absorbed := 3 }
  , cursorAfter := { stateWords := [13522001880879900227, 2076012353615447445, 6283777378358488802, 6397285422002702166, 22029644498711621, 8946322245240676634, 14425569364995812978, 10554284728068128014], absorbed := 0 }
  , challengeOutput := (some 13522001880879900227)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [84, 58, 119, 62, 227, 203, 157, 120, 91, 33, 164, 86, 114, 27, 21, 233, 168, 252, 76, 12, 100, 202, 132, 82, 6, 21, 143, 29, 61, 32, 51, 38])
  , u64s := []
  , cursorBefore := { stateWords := [13522001880879900227, 2076012353615447445, 6283777378358488802, 6397285422002702166, 22029644498711621, 8946322245240676634, 14425569364995812978, 10554284728068128014], absorbed := 0 }
  , cursorAfter := { stateWords := [28161022467041557, 8320094787765450, 640884797, 10688822229477720999, 2298505535517364726, 9010554323198895477, 13396947121714209208, 18289360312464286512], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [160, 227, 4, 85, 140, 249, 7, 83, 176, 183, 120, 10, 187, 25, 9, 75, 146, 246, 100, 53, 9, 137, 26, 48, 91, 20, 9, 143, 92, 16, 180, 9])
  , u64s := []
  , cursorBefore := { stateWords := [28161022467041557, 8320094787765450, 640884797, 10688822229477720999, 2298505535517364726, 9010554323198895477, 13396947121714209208, 18289360312464286512], absorbed := 3 }
  , cursorAfter := { stateWords := [2591982540180233, 40260904703498889, 162795612, 11106092458926729985, 9843439728162203894, 4910876821339919711, 11743588247353110963, 16917990617748735295], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [67, 56, 221, 172, 183, 26, 231, 188, 189, 215, 247, 181, 112, 58, 232, 221, 188, 253, 63, 175, 15, 72, 182, 206, 231, 128, 239, 141, 249, 6, 198, 30])
  , u64s := []
  , cursorBefore := { stateWords := [2591982540180233, 40260904703498889, 162795612, 11106092458926729985, 9843439728162203894, 4910876821339919711, 11743588247353110963, 16917990617748735295], absorbed := 3 }
  , cursorAfter := { stateWords := [4414814025473512, 39951308640138824, 516294393, 17329624708618471016, 11674115816566501362, 14573575530215518718, 13139643552008840516, 17641270940026343217], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [4414814025473512, 39951308640138824, 516294393, 17329624708618471016, 11674115816566501362, 14573575530215518718, 13139643552008840516, 17641270940026343217], absorbed := 3 }
  , cursorAfter := { stateWords := [5710450369200423292, 5740143068072469614, 14894183229893626147, 9172001311057965075, 14492336027424921441, 885359618247772967, 13488484757209203575, 3843872230801825639], absorbed := 0 }
  , challengeOutput := (some 5710450369200423292)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [5710450369200423292, 5740143068072469614, 14894183229893626147, 9172001311057965075, 14492336027424921441, 885359618247772967, 13488484757209203575, 3843872230801825639], absorbed := 0 }
  , cursorAfter := { stateWords := [4225525998307615487, 11432035185072164917, 12583554745970507727, 13626737198406591408, 6094816200342946977, 10179070456341347142, 1214732117107862240, 4980023762376192327], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [255, 162, 77, 246, 129, 21, 164, 58, 53, 80, 254, 105, 110, 191, 166, 158, 207, 191, 64, 245, 94, 196, 161, 174, 176, 99, 160, 206, 72, 229, 27, 189]))
}]
}
  , kernel := {
  root0Digest := (bytes [160, 47, 136, 108, 204, 129, 79, 197, 229, 103, 193, 132, 46, 237, 116, 161, 76, 12, 119, 193, 191, 6, 227, 119, 236, 118, 88, 172, 48, 50, 35, 98])
  , stage1Digest := (bytes [64, 180, 146, 246, 139, 60, 76, 212, 49, 131, 207, 237, 101, 254, 127, 102, 212, 72, 236, 89, 205, 253, 188, 71, 14, 72, 168, 245, 217, 88, 55, 93])
  , stage2Digest := (bytes [52, 185, 8, 160, 143, 178, 154, 190, 101, 228, 204, 246, 221, 136, 74, 154, 136, 97, 99, 235, 127, 33, 115, 45, 30, 159, 243, 89, 15, 247, 157, 142])
  , stage3Digest := (bytes [84, 58, 119, 62, 227, 203, 157, 120, 91, 33, 164, 86, 114, 27, 21, 233, 168, 252, 76, 12, 100, 202, 132, 82, 6, 21, 143, 29, 61, 32, 51, 38])
  , executionDigest := (bytes [160, 227, 4, 85, 140, 249, 7, 83, 176, 183, 120, 10, 187, 25, 9, 75, 146, 246, 100, 53, 9, 137, 26, 48, 91, 20, 9, 143, 92, 16, 180, 9])
  , finalStateDigest := (bytes [67, 56, 221, 172, 183, 26, 231, 188, 189, 215, 247, 181, 112, 58, 232, 221, 188, 253, 63, 175, 15, 72, 182, 206, 231, 128, 239, 141, 249, 6, 198, 30])
  , stage1Mix := 3705222010059132808
  , stage2RegMix := 7940266179000280847
  , stage2RamMix := 4123130262336711476
  , stage3ContinuityMix := 13522001880879900227
  , kernelFinalMix := 5710450369200423292
  , transcriptFinalDigest := (bytes [255, 162, 77, 246, 129, 21, 164, 58, 53, 80, 254, 105, 110, 191, 166, 158, 207, 191, 64, 245, 94, 196, 161, 174, 176, 99, 160, 206, 72, 229, 27, 189])
  , finalPc := 56
  , finalRegisters := [0, 5, 3, 1, 4, 7, 11, 6, 2, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , finalMemory := []
  , halted := true
}
}
    , kernelProof := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "native_logic_compare_chain_ecall", fixtureId := "native_logic_compare_chain_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , executionDigest := (bytes [160, 227, 4, 85, 140, 249, 7, 83, 176, 183, 120, 10, 187, 25, 9, 75, 146, 246, 100, 53, 9, 137, 26, 48, 91, 20, 9, 143, 92, 16, 180, 9])
  , shape := { executionRowCount := 14, realRowCount := 14, effectRowCount := 14, commitRowCount := 14, digest := (bytes [98, 27, 16, 203, 163, 39, 179, 238, 226, 141, 246, 213, 119, 136, 91, 127, 225, 172, 34, 125, 207, 246, 89, 73, 181, 67, 50, 45, 109, 140, 177, 128]) }
  , digest := (bytes [54, 77, 166, 199, 117, 175, 43, 138, 198, 157, 160, 244, 179, 194, 196, 103, 209, 182, 248, 110, 114, 9, 218, 177, 4, 83, 169, 122, 189, 68, 112, 23])
}
  , stages := { summary := { stage1RowCount := 14, stage2RegisterReadCount := 17, stage2RegisterWriteCount := 12, stage2RamEventCount := 0, stage2TwistLinkCount := 14, stage3ContinuityCount := 14, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [212, 121, 182, 157, 130, 31, 103, 83, 22, 231, 57, 213, 125, 221, 246, 63, 101, 215, 96, 34, 214, 161, 104, 135, 185, 91, 123, 234, 48, 239, 148, 226]) }, digest := (bytes [253, 22, 78, 69, 28, 133, 223, 161, 128, 253, 133, 85, 114, 218, 23, 234, 67, 40, 241, 162, 84, 225, 131, 143, 19, 32, 93, 218, 127, 244, 61, 249]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [216, 32, 228, 212, 19, 254, 160, 162, 75, 41, 38, 216, 58, 20, 142, 66, 97, 224, 122, 73, 33, 212, 76, 206, 137, 158, 21, 56, 129, 251, 202, 238]), stage1Digest := (bytes [130, 247, 139, 113, 190, 199, 67, 92, 177, 90, 56, 59, 212, 190, 76, 7, 106, 121, 239, 148, 167, 195, 24, 238, 152, 173, 69, 165, 234, 31, 97, 120]), stage2Digest := (bytes [59, 223, 169, 57, 54, 184, 4, 101, 63, 96, 83, 251, 20, 132, 175, 144, 122, 175, 137, 16, 233, 191, 59, 26, 191, 66, 100, 108, 143, 54, 105, 196]), stage3Digest := (bytes [203, 4, 139, 177, 198, 192, 60, 107, 40, 171, 79, 131, 16, 234, 19, 169, 216, 128, 96, 170, 131, 179, 97, 98, 145, 116, 199, 205, 234, 150, 209, 66]), transcriptDigest := (bytes [255, 162, 77, 246, 129, 21, 164, 58, 53, 80, 254, 105, 110, 191, 166, 158, 207, 191, 64, 245, 94, 196, 161, 174, 176, 99, 160, 206, 72, 229, 27, 189]), executionDigest := (bytes [160, 227, 4, 85, 140, 249, 7, 83, 176, 183, 120, 10, 187, 25, 9, 75, 146, 246, 100, 53, 9, 137, 26, 48, 91, 20, 9, 143, 92, 16, 180, 9]), digest := (bytes [73, 160, 4, 47, 240, 97, 89, 234, 165, 28, 225, 61, 143, 196, 212, 92, 228, 61, 244, 136, 8, 79, 79, 172, 23, 71, 81, 200, 142, 176, 155, 198]) }, statementDigest := (bytes [223, 217, 79, 22, 200, 45, 194, 2, 107, 8, 57, 106, 132, 11, 243, 31, 2, 145, 24, 162, 190, 91, 98, 203, 97, 82, 240, 168, 95, 50, 212, 48]), proofDigest := (bytes [180, 255, 82, 224, 253, 0, 148, 235, 124, 11, 163, 47, 51, 195, 215, 62, 85, 80, 193, 141, 182, 30, 211, 161, 181, 231, 225, 211, 127, 206, 178, 134]), digest := (bytes [82, 91, 83, 175, 161, 62, 254, 207, 152, 70, 151, 72, 246, 103, 232, 195, 170, 41, 28, 111, 11, 192, 113, 61, 195, 0, 56, 76, 145, 1, 192, 167]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [189, 31, 79, 14, 204, 208, 208, 71, 134, 15, 236, 185, 181, 28, 81, 145, 219, 208, 251, 41, 93, 43, 132, 149, 208, 180, 210, 74, 29, 67, 229, 6]), stage1Digest := (bytes [51, 63, 211, 186, 53, 109, 214, 181, 53, 47, 220, 172, 153, 111, 64, 147, 58, 164, 115, 119, 49, 122, 105, 76, 55, 28, 186, 147, 134, 23, 195, 34]), stage2Digest := (bytes [241, 163, 5, 223, 23, 221, 24, 134, 104, 142, 140, 248, 100, 214, 117, 54, 151, 122, 237, 155, 109, 20, 173, 192, 160, 221, 211, 80, 50, 211, 55, 77]), stage3Digest := (bytes [185, 92, 17, 202, 45, 12, 222, 226, 100, 195, 61, 245, 228, 18, 236, 184, 35, 105, 128, 226, 194, 228, 196, 136, 241, 250, 141, 81, 14, 6, 246, 103]), digest := (bytes [4, 99, 68, 229, 187, 4, 4, 254, 48, 233, 7, 250, 222, 79, 110, 251, 82, 46, 170, 249, 229, 158, 220, 40, 167, 148, 218, 45, 85, 9, 181, 238]) }, digest := (bytes [0, 241, 139, 67, 208, 59, 204, 53, 214, 182, 232, 172, 16, 157, 142, 18, 18, 119, 75, 139, 221, 139, 235, 119, 170, 22, 32, 99, 124, 53, 138, 186]) }
  , kernelOpening := { openingDigest := (bytes [211, 255, 49, 81, 169, 115, 42, 68, 80, 117, 32, 168, 72, 90, 186, 205, 250, 15, 188, 208, 218, 121, 98, 163, 63, 168, 237, 110, 93, 53, 180, 67]), bindings := { claimDigest := (bytes [233, 118, 64, 129, 165, 249, 195, 188, 13, 127, 117, 113, 7, 236, 106, 87, 47, 166, 208, 183, 46, 103, 181, 137, 164, 184, 174, 225, 49, 52, 15, 52]), bindingsDigest := (bytes [146, 69, 160, 136, 176, 177, 104, 110, 60, 43, 120, 212, 38, 199, 157, 204, 134, 99, 251, 149, 77, 23, 66, 175, 77, 128, 36, 224, 204, 56, 59, 142]), preparedStepsDigest := (bytes [194, 38, 40, 76, 72, 198, 130, 9, 251, 15, 187, 205, 206, 52, 19, 22, 121, 122, 44, 210, 35, 167, 39, 30, 166, 51, 1, 38, 6, 6, 143, 194]), digest := (bytes [85, 21, 110, 105, 130, 200, 29, 255, 8, 30, 214, 248, 93, 75, 111, 61, 171, 17, 76, 102, 129, 100, 87, 61, 183, 94, 212, 242, 248, 207, 223, 208]) }, digest := (bytes [143, 47, 208, 232, 105, 59, 172, 154, 135, 205, 139, 55, 178, 92, 134, 89, 253, 75, 76, 153, 228, 254, 72, 162, 137, 168, 74, 174, 142, 223, 69, 17]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [49, 15, 156, 222, 222, 132, 248, 219, 86, 74, 177, 173, 126, 92, 88, 142, 71, 233, 147, 61, 144, 74, 40, 78, 93, 229, 111, 147, 78, 221, 224, 124]), terminal := { root0Digest := (bytes [160, 47, 136, 108, 204, 129, 79, 197, 229, 103, 193, 132, 46, 237, 116, 161, 76, 12, 119, 193, 191, 6, 227, 119, 236, 118, 88, 172, 48, 50, 35, 98]), executionDigest := (bytes [160, 227, 4, 85, 140, 249, 7, 83, 176, 183, 120, 10, 187, 25, 9, 75, 146, 246, 100, 53, 9, 137, 26, 48, 91, 20, 9, 143, 92, 16, 180, 9]), finalStateDigest := (bytes [67, 56, 221, 172, 183, 26, 231, 188, 189, 215, 247, 181, 112, 58, 232, 221, 188, 253, 63, 175, 15, 72, 182, 206, 231, 128, 239, 141, 249, 6, 198, 30]), transcriptFinalDigest := (bytes [255, 162, 77, 246, 129, 21, 164, 58, 53, 80, 254, 105, 110, 191, 166, 158, 207, 191, 64, 245, 94, 196, 161, 174, 176, 99, 160, 206, 72, 229, 27, 189]), finalPc := 56, halted := true, digest := (bytes [178, 141, 77, 109, 21, 73, 107, 171, 56, 179, 173, 63, 107, 123, 216, 38, 10, 194, 109, 218, 63, 153, 60, 48, 81, 71, 208, 71, 129, 235, 115, 220]) }, digest := (bytes [116, 191, 93, 247, 125, 154, 53, 94, 53, 1, 48, 242, 66, 156, 82, 127, 23, 224, 175, 113, 74, 118, 170, 197, 237, 210, 94, 177, 141, 78, 46, 50]) }, statementDigest := (bytes [121, 81, 8, 82, 242, 231, 166, 46, 197, 5, 160, 168, 10, 6, 14, 122, 96, 29, 2, 218, 92, 22, 219, 162, 199, 16, 113, 249, 245, 212, 245, 134]), proofDigest := (bytes [199, 226, 164, 107, 96, 250, 60, 74, 145, 253, 236, 234, 78, 125, 246, 176, 178, 97, 197, 60, 16, 107, 218, 95, 240, 226, 248, 50, 210, 21, 196, 73]), digest := (bytes [108, 64, 141, 86, 75, 232, 8, 174, 72, 121, 219, 110, 141, 178, 155, 204, 218, 245, 180, 32, 155, 228, 55, 241, 93, 117, 113, 158, 64, 168, 157, 200]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [21, 45, 25, 215, 138, 137, 7, 133, 215, 110, 157, 80, 190, 214, 195, 121, 158, 12, 227, 251, 45, 243, 101, 206, 199, 100, 36, 105, 152, 72, 2, 50]), layoutVersion := 1, digest := (bytes [214, 75, 94, 215, 91, 109, 134, 19, 161, 154, 62, 207, 10, 12, 209, 67, 12, 194, 141, 59, 26, 158, 87, 80, 191, 44, 144, 250, 112, 104, 43, 29]) }, rowWidth := 38, timeLen := 14, columnDigests := [(bytes [117, 219, 33, 6, 121, 216, 214, 88, 201, 71, 161, 234, 46, 145, 226, 25, 168, 148, 81, 127, 39, 201, 178, 91, 125, 55, 226, 134, 98, 162, 247, 165]), (bytes [197, 181, 33, 35, 38, 2, 136, 79, 30, 37, 189, 113, 57, 26, 19, 18, 185, 191, 112, 240, 25, 225, 206, 117, 184, 96, 69, 226, 200, 10, 76, 139]), (bytes [57, 108, 130, 214, 65, 8, 103, 231, 217, 218, 243, 15, 15, 250, 39, 96, 230, 92, 253, 246, 32, 193, 25, 183, 138, 114, 179, 63, 86, 2, 52, 26]), (bytes [35, 205, 28, 213, 21, 92, 83, 146, 40, 245, 171, 225, 235, 158, 123, 171, 220, 228, 247, 250, 67, 19, 107, 111, 185, 91, 15, 208, 242, 155, 155, 237]), (bytes [225, 140, 32, 65, 184, 164, 210, 224, 82, 130, 234, 4, 68, 84, 90, 101, 213, 147, 159, 56, 21, 221, 40, 210, 149, 192, 227, 46, 148, 196, 23, 182]), (bytes [112, 64, 164, 229, 44, 104, 81, 148, 89, 4, 54, 158, 99, 79, 29, 207, 5, 78, 38, 165, 106, 71, 223, 164, 77, 252, 15, 16, 206, 129, 11, 228]), (bytes [59, 23, 13, 174, 99, 176, 215, 100, 74, 207, 200, 4, 45, 23, 227, 121, 174, 32, 3, 14, 109, 163, 162, 237, 222, 141, 35, 52, 196, 142, 119, 121]), (bytes [162, 192, 202, 183, 159, 172, 138, 151, 62, 98, 85, 9, 227, 35, 47, 254, 225, 156, 246, 62, 197, 213, 221, 21, 238, 92, 184, 77, 193, 139, 148, 39]), (bytes [30, 156, 113, 121, 45, 182, 44, 79, 80, 23, 100, 103, 103, 220, 37, 206, 19, 133, 143, 137, 36, 66, 23, 201, 184, 224, 147, 133, 121, 61, 164, 132]), (bytes [156, 238, 235, 235, 231, 56, 7, 144, 230, 102, 206, 102, 232, 250, 181, 201, 253, 212, 223, 216, 248, 101, 154, 132, 67, 141, 180, 235, 176, 0, 222, 186]), (bytes [10, 202, 130, 96, 129, 174, 239, 254, 59, 37, 168, 13, 84, 88, 60, 23, 246, 105, 129, 160, 2, 164, 141, 152, 10, 226, 104, 120, 223, 227, 147, 182]), (bytes [9, 66, 153, 238, 64, 72, 96, 76, 167, 53, 105, 235, 191, 80, 145, 191, 171, 199, 163, 209, 2, 21, 219, 193, 40, 15, 117, 44, 38, 227, 174, 82]), (bytes [53, 210, 212, 164, 155, 209, 180, 66, 35, 26, 74, 182, 180, 154, 135, 145, 137, 232, 23, 91, 107, 43, 121, 206, 253, 135, 62, 8, 176, 59, 70, 15]), (bytes [106, 103, 191, 216, 129, 70, 108, 56, 80, 28, 234, 109, 65, 95, 182, 111, 36, 14, 26, 208, 195, 175, 179, 126, 195, 123, 25, 193, 7, 72, 58, 5]), (bytes [158, 160, 91, 142, 12, 187, 225, 43, 156, 22, 68, 189, 240, 1, 88, 7, 141, 81, 210, 236, 208, 6, 71, 79, 37, 130, 163, 202, 36, 228, 89, 90]), (bytes [46, 141, 40, 223, 54, 17, 192, 49, 98, 51, 120, 151, 49, 190, 176, 227, 105, 252, 116, 226, 229, 183, 147, 50, 206, 83, 32, 121, 210, 41, 242, 19]), (bytes [231, 48, 167, 64, 215, 215, 29, 147, 80, 109, 156, 204, 135, 216, 75, 125, 111, 94, 243, 59, 187, 142, 142, 74, 214, 190, 99, 151, 155, 156, 232, 73]), (bytes [133, 46, 47, 118, 238, 252, 67, 1, 21, 108, 79, 178, 171, 204, 150, 189, 94, 42, 56, 225, 67, 208, 179, 168, 238, 177, 139, 49, 116, 118, 233, 48]), (bytes [46, 251, 78, 50, 246, 29, 89, 188, 104, 90, 229, 230, 68, 49, 70, 98, 0, 159, 143, 222, 166, 67, 222, 126, 233, 42, 212, 215, 177, 122, 245, 244]), (bytes [212, 78, 225, 26, 70, 215, 242, 159, 253, 200, 243, 164, 143, 156, 86, 194, 196, 102, 151, 234, 218, 46, 250, 223, 27, 253, 119, 88, 200, 151, 41, 209]), (bytes [182, 174, 245, 10, 243, 83, 65, 234, 45, 41, 186, 225, 212, 138, 230, 28, 172, 143, 28, 204, 202, 35, 217, 157, 45, 144, 50, 95, 139, 222, 168, 230]), (bytes [21, 77, 175, 162, 196, 200, 15, 200, 96, 52, 57, 177, 5, 199, 15, 224, 233, 131, 135, 35, 0, 74, 204, 63, 45, 38, 40, 42, 83, 165, 235, 243]), (bytes [200, 123, 150, 180, 130, 239, 77, 46, 107, 115, 96, 151, 175, 87, 196, 173, 178, 38, 203, 18, 14, 52, 71, 156, 198, 241, 154, 189, 135, 60, 150, 110]), (bytes [184, 136, 227, 97, 138, 201, 215, 114, 117, 53, 142, 36, 34, 167, 62, 209, 106, 69, 42, 232, 117, 199, 155, 239, 194, 220, 232, 182, 63, 236, 25, 97]), (bytes [22, 55, 140, 189, 108, 57, 66, 26, 133, 242, 191, 229, 238, 69, 253, 171, 74, 63, 149, 139, 162, 33, 95, 212, 14, 166, 26, 181, 169, 173, 73, 107]), (bytes [71, 235, 66, 169, 108, 11, 32, 25, 100, 8, 26, 151, 135, 70, 176, 89, 186, 60, 39, 27, 47, 251, 214, 193, 253, 123, 156, 123, 227, 7, 42, 133]), (bytes [38, 35, 109, 20, 232, 248, 173, 153, 141, 11, 184, 169, 252, 171, 163, 233, 237, 209, 48, 71, 4, 40, 151, 201, 46, 242, 122, 122, 76, 11, 111, 82]), (bytes [115, 209, 211, 165, 55, 80, 224, 206, 50, 30, 225, 178, 67, 220, 207, 144, 208, 23, 121, 128, 32, 139, 245, 153, 224, 172, 81, 199, 157, 129, 211, 234]), (bytes [118, 95, 207, 73, 175, 215, 224, 3, 14, 57, 95, 55, 64, 126, 153, 245, 171, 14, 102, 120, 48, 223, 7, 108, 134, 216, 22, 195, 42, 52, 105, 193]), (bytes [88, 173, 13, 26, 248, 14, 100, 146, 9, 13, 119, 131, 100, 96, 131, 15, 46, 36, 166, 90, 58, 117, 139, 234, 255, 203, 93, 134, 162, 52, 138, 196]), (bytes [219, 235, 162, 252, 244, 131, 57, 44, 96, 184, 103, 140, 129, 91, 68, 126, 235, 200, 120, 74, 129, 82, 219, 2, 219, 239, 106, 136, 241, 248, 4, 6]), (bytes [81, 28, 93, 93, 78, 249, 146, 159, 50, 232, 208, 43, 63, 144, 199, 21, 179, 47, 31, 243, 102, 195, 82, 239, 22, 75, 90, 82, 11, 186, 64, 183]), (bytes [178, 1, 114, 173, 184, 198, 199, 2, 65, 38, 209, 186, 236, 30, 77, 73, 178, 252, 99, 158, 156, 60, 16, 109, 47, 2, 150, 51, 182, 12, 158, 105]), (bytes [170, 253, 136, 66, 232, 134, 49, 97, 255, 124, 180, 202, 199, 107, 154, 137, 63, 179, 121, 77, 63, 183, 209, 85, 250, 46, 51, 59, 76, 216, 149, 2]), (bytes [49, 120, 127, 173, 34, 105, 205, 134, 178, 107, 240, 182, 184, 188, 174, 96, 13, 204, 69, 149, 244, 10, 15, 30, 97, 136, 83, 122, 151, 98, 204, 122]), (bytes [206, 71, 13, 21, 155, 247, 202, 63, 127, 27, 147, 48, 193, 52, 116, 125, 197, 59, 78, 254, 220, 172, 61, 227, 236, 77, 54, 242, 46, 251, 223, 109]), (bytes [42, 247, 89, 60, 176, 10, 50, 11, 210, 124, 225, 47, 203, 182, 22, 10, 69, 47, 163, 227, 61, 219, 255, 58, 27, 125, 7, 215, 15, 46, 153, 158]), (bytes [13, 4, 101, 10, 60, 237, 254, 163, 224, 43, 55, 67, 190, 96, 200, 157, 57, 12, 196, 123, 175, 252, 100, 2, 55, 183, 231, 132, 214, 148, 208, 173])], familyDigest := (bytes [21, 45, 25, 215, 138, 137, 7, 133, 215, 110, 157, 80, 190, 214, 195, 121, 158, 12, 227, 251, 45, 243, 101, 206, 199, 100, 36, 105, 152, 72, 2, 50]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [21, 45, 25, 215, 138, 137, 7, 133, 215, 110, 157, 80, 190, 214, 195, 121, 158, 12, 227, 251, 45, 243, 101, 206, 199, 100, 36, 105, 152, 72, 2, 50]), layoutVersion := 1, digest := (bytes [214, 75, 94, 215, 91, 109, 134, 19, 161, 154, 62, 207, 10, 12, 209, 67, 12, 194, 141, 59, 26, 158, 87, 80, 191, 44, 144, 250, 112, 104, 43, 29]) }, logicalIndex := 0, digest := (bytes [212, 251, 215, 182, 26, 81, 126, 18, 167, 62, 136, 137, 74, 50, 183, 244, 249, 148, 146, 115, 7, 221, 9, 25, 73, 36, 27, 98, 74, 185, 12, 250]) }, valueDigest := (bytes [195, 104, 190, 242, 104, 180, 234, 122, 108, 245, 168, 232, 122, 59, 5, 141, 148, 97, 161, 16, 201, 133, 162, 230, 49, 127, 153, 215, 226, 163, 192, 66]), digest := (bytes [229, 44, 46, 216, 109, 204, 220, 233, 58, 5, 59, 127, 77, 57, 93, 180, 92, 174, 71, 184, 220, 8, 113, 222, 241, 157, 184, 161, 240, 199, 81, 75]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [21, 45, 25, 215, 138, 137, 7, 133, 215, 110, 157, 80, 190, 214, 195, 121, 158, 12, 227, 251, 45, 243, 101, 206, 199, 100, 36, 105, 152, 72, 2, 50]), layoutVersion := 1, digest := (bytes [214, 75, 94, 215, 91, 109, 134, 19, 161, 154, 62, 207, 10, 12, 209, 67, 12, 194, 141, 59, 26, 158, 87, 80, 191, 44, 144, 250, 112, 104, 43, 29]) }, logicalIndex := 13, digest := (bytes [136, 16, 76, 149, 67, 51, 94, 206, 213, 112, 20, 104, 240, 255, 176, 60, 202, 245, 225, 21, 12, 224, 192, 247, 123, 154, 88, 4, 102, 146, 16, 136]) }, valueDigest := (bytes [228, 218, 132, 173, 40, 175, 163, 113, 77, 51, 14, 129, 172, 72, 64, 113, 166, 5, 209, 86, 65, 181, 139, 164, 241, 195, 58, 252, 148, 133, 40, 21]), digest := (bytes [35, 165, 121, 231, 139, 68, 67, 111, 41, 179, 143, 236, 33, 48, 73, 237, 21, 135, 195, 13, 104, 225, 9, 101, 64, 133, 47, 110, 7, 141, 253, 126]) }), digest := (bytes [225, 122, 202, 119, 211, 61, 230, 86, 129, 212, 18, 206, 97, 154, 229, 221, 132, 99, 162, 82, 68, 231, 230, 99, 4, 155, 163, 100, 53, 150, 253, 136]) }
  , rootLaneCommitment := { timeLen := 14, commitments := { commitmentCount := 38, digest := (bytes [219, 195, 168, 58, 246, 163, 92, 165, 69, 68, 110, 143, 93, 49, 110, 10, 179, 183, 197, 231, 89, 147, 118, 24, 213, 113, 174, 182, 139, 68, 78, 10]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [219, 195, 168, 58, 246, 163, 92, 165, 69, 68, 110, 143, 93, 49, 110, 10, 179, 183, 197, 231, 89, 147, 118, 24, 213, 113, 174, 182, 139, 68, 78, 10]), layoutVersion := 3, digest := (bytes [54, 65, 220, 157, 10, 119, 33, 155, 19, 18, 245, 163, 208, 135, 18, 19, 24, 227, 38, 183, 95, 97, 46, 170, 116, 249, 170, 121, 2, 11, 204, 182]) }, logicalIndex := 0, digest := (bytes [241, 115, 53, 60, 47, 124, 25, 29, 82, 180, 123, 91, 122, 32, 206, 112, 208, 0, 206, 191, 62, 203, 101, 97, 201, 179, 232, 144, 237, 192, 143, 121]) }, valueDigest := (bytes [195, 104, 190, 242, 104, 180, 234, 122, 108, 245, 168, 232, 122, 59, 5, 141, 148, 97, 161, 16, 201, 133, 162, 230, 49, 127, 153, 215, 226, 163, 192, 66]), digest := (bytes [89, 78, 226, 130, 74, 6, 255, 150, 236, 10, 155, 172, 163, 196, 73, 50, 37, 76, 115, 142, 113, 231, 224, 168, 209, 76, 106, 244, 171, 66, 169, 154]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [219, 195, 168, 58, 246, 163, 92, 165, 69, 68, 110, 143, 93, 49, 110, 10, 179, 183, 197, 231, 89, 147, 118, 24, 213, 113, 174, 182, 139, 68, 78, 10]), layoutVersion := 3, digest := (bytes [54, 65, 220, 157, 10, 119, 33, 155, 19, 18, 245, 163, 208, 135, 18, 19, 24, 227, 38, 183, 95, 97, 46, 170, 116, 249, 170, 121, 2, 11, 204, 182]) }, logicalIndex := 13, digest := (bytes [185, 1, 193, 126, 91, 144, 233, 178, 197, 252, 245, 92, 123, 155, 197, 155, 10, 196, 139, 217, 152, 18, 84, 207, 109, 8, 90, 93, 226, 254, 153, 106]) }, valueDigest := (bytes [228, 218, 132, 173, 40, 175, 163, 113, 77, 51, 14, 129, 172, 72, 64, 113, 166, 5, 209, 86, 65, 181, 139, 164, 241, 195, 58, 252, 148, 133, 40, 21]), digest := (bytes [100, 245, 202, 28, 32, 25, 16, 215, 85, 76, 248, 178, 234, 220, 79, 156, 168, 40, 235, 229, 37, 100, 64, 184, 15, 144, 28, 188, 217, 69, 155, 173]) }), digest := (bytes [40, 69, 56, 85, 171, 193, 21, 86, 12, 115, 250, 132, 216, 70, 194, 119, 195, 78, 79, 250, 249, 208, 33, 23, 244, 28, 33, 90, 220, 90, 136, 23]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [225, 122, 202, 119, 211, 61, 230, 86, 129, 212, 18, 206, 97, 154, 229, 221, 132, 99, 162, 82, 68, 231, 230, 99, 4, 155, 163, 100, 53, 150, 253, 136]), rootLaneCommitmentDigest := (bytes [40, 69, 56, 85, 171, 193, 21, 86, 12, 115, 250, 132, 216, 70, 194, 119, 195, 78, 79, 250, 249, 208, 33, 23, 244, 28, 33, 90, 220, 90, 136, 23]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 14, digest := (bytes [145, 180, 130, 91, 155, 62, 221, 96, 76, 78, 228, 160, 188, 5, 204, 73, 241, 89, 79, 184, 135, 187, 214, 132, 167, 18, 254, 183, 18, 158, 106, 93]) }, statementDigest := (bytes [113, 63, 31, 237, 65, 2, 87, 182, 247, 241, 197, 211, 37, 239, 137, 135, 15, 246, 76, 190, 148, 98, 253, 235, 220, 39, 237, 155, 89, 217, 142, 48]), proofDigest := (bytes [145, 41, 204, 146, 205, 253, 124, 41, 180, 135, 11, 131, 74, 35, 113, 62, 61, 146, 142, 242, 220, 107, 208, 201, 49, 33, 207, 155, 129, 118, 140, 243]), digest := (bytes [74, 129, 33, 167, 23, 241, 3, 172, 136, 8, 212, 7, 162, 100, 186, 51, 106, 184, 249, 123, 189, 184, 1, 200, 179, 172, 80, 207, 46, 93, 96, 32]) }
  , digest := (bytes [171, 71, 135, 204, 223, 232, 85, 180, 153, 205, 222, 8, 114, 1, 56, 56, 37, 137, 114, 119, 167, 24, 169, 20, 119, 90, 179, 217, 175, 147, 27, 61])
}
    , exportedProof := {
  claim := {
  accepted := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , statement := { proofStatementDigest := (bytes [43, 148, 11, 160, 66, 233, 231, 115, 70, 41, 27, 39, 122, 8, 101, 242, 101, 187, 23, 96, 203, 112, 94, 49, 131, 67, 29, 56, 210, 129, 165, 129]), kernelOpeningDigest := (bytes [143, 47, 208, 232, 105, 59, 172, 154, 135, 205, 139, 55, 178, 92, 134, 89, 253, 75, 76, 153, 228, 254, 72, 162, 137, 168, 74, 174, 142, 223, 69, 17]), digest := (bytes [153, 182, 9, 97, 140, 10, 187, 24, 23, 144, 160, 132, 219, 195, 255, 225, 216, 126, 19, 77, 175, 103, 178, 78, 167, 132, 208, 182, 130, 123, 159, 12]) }
  , mainLane := { mainLaneBundleDigest := (bytes [74, 129, 33, 167, 23, 241, 3, 172, 136, 8, 212, 7, 162, 100, 186, 51, 106, 184, 249, 123, 189, 184, 1, 200, 179, 172, 80, 207, 46, 93, 96, 32]), digest := (bytes [169, 103, 20, 147, 151, 46, 224, 158, 40, 126, 203, 214, 116, 204, 20, 18, 179, 19, 195, 28, 123, 187, 186, 34, 148, 24, 181, 125, 180, 39, 128, 222]) }
  , terminal := { finalStateDigest := (bytes [67, 56, 221, 172, 183, 26, 231, 188, 189, 215, 247, 181, 112, 58, 232, 221, 188, 253, 63, 175, 15, 72, 182, 206, 231, 128, 239, 141, 249, 6, 198, 30]), finalPc := 56, halted := true, digest := (bytes [221, 217, 28, 9, 91, 13, 112, 45, 176, 158, 0, 39, 53, 48, 20, 244, 27, 150, 63, 118, 246, 39, 186, 79, 198, 41, 196, 52, 64, 233, 166, 130]) }
  , digest := (bytes [42, 86, 110, 158, 95, 72, 188, 41, 123, 14, 225, 215, 152, 94, 186, 116, 232, 185, 236, 246, 24, 161, 231, 250, 99, 169, 156, 1, 103, 163, 4, 5])
}
  , mainLane := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { mainLaneBundleDigest := (bytes [74, 129, 33, 167, 23, 241, 3, 172, 136, 8, 212, 7, 162, 100, 186, 51, 106, 184, 249, 123, 189, 184, 1, 200, 179, 172, 80, 207, 46, 93, 96, 32]), digest := (bytes [7, 159, 54, 170, 155, 218, 73, 249, 27, 249, 106, 48, 84, 48, 12, 151, 71, 171, 90, 246, 46, 186, 95, 249, 37, 161, 29, 30, 115, 227, 77, 132]) }, digest := (bytes [104, 166, 52, 151, 159, 153, 106, 101, 82, 79, 119, 60, 138, 231, 95, 134, 49, 131, 104, 210, 192, 171, 39, 215, 22, 205, 14, 57, 141, 16, 221, 201]) }
  , opening := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , stages := { stageClaimsDigest := (bytes [82, 91, 83, 175, 161, 62, 254, 207, 152, 70, 151, 72, 246, 103, 232, 195, 170, 41, 28, 111, 11, 192, 113, 61, 195, 0, 56, 76, 145, 1, 192, 167]), stagePackagesDigest := (bytes [0, 241, 139, 67, 208, 59, 204, 53, 214, 182, 232, 172, 16, 157, 142, 18, 18, 119, 75, 139, 221, 139, 235, 119, 170, 22, 32, 99, 124, 53, 138, 186]), kernelOpeningDigest := (bytes [143, 47, 208, 232, 105, 59, 172, 154, 135, 205, 139, 55, 178, 92, 134, 89, 253, 75, 76, 153, 228, 254, 72, 162, 137, 168, 74, 174, 142, 223, 69, 17]), digest := (bytes [106, 183, 230, 184, 23, 47, 80, 134, 52, 18, 120, 197, 11, 107, 4, 8, 96, 77, 49, 192, 215, 135, 159, 144, 78, 47, 202, 174, 109, 76, 7, 246]) }
  , terminal := { preparedStepBindingsDigest := (bytes [49, 15, 156, 222, 222, 132, 248, 219, 86, 74, 177, 173, 126, 92, 88, 142, 71, 233, 147, 61, 144, 74, 40, 78, 93, 229, 111, 147, 78, 221, 224, 124]), executionDigest := (bytes [160, 227, 4, 85, 140, 249, 7, 83, 176, 183, 120, 10, 187, 25, 9, 75, 146, 246, 100, 53, 9, 137, 26, 48, 91, 20, 9, 143, 92, 16, 180, 9]), transcriptFinalDigest := (bytes [255, 162, 77, 246, 129, 21, 164, 58, 53, 80, 254, 105, 110, 191, 166, 158, 207, 191, 64, 245, 94, 196, 161, 174, 176, 99, 160, 206, 72, 229, 27, 189]), digest := (bytes [0, 191, 245, 88, 39, 162, 110, 136, 64, 209, 107, 50, 69, 115, 7, 218, 184, 158, 185, 98, 5, 196, 212, 249, 111, 112, 132, 103, 150, 174, 105, 37]) }
  , digest := (bytes [243, 202, 179, 131, 219, 230, 26, 19, 77, 111, 206, 73, 239, 43, 166, 219, 100, 107, 100, 194, 171, 111, 255, 122, 205, 63, 57, 71, 44, 177, 109, 47])
}
  , jointOpening := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { proofStatementDigest := (bytes [43, 148, 11, 160, 66, 233, 231, 115, 70, 41, 27, 39, 122, 8, 101, 242, 101, 187, 23, 96, 203, 112, 94, 49, 131, 67, 29, 56, 210, 129, 165, 129]), mainLaneClaimDigest := (bytes [104, 166, 52, 151, 159, 153, 106, 101, 82, 79, 119, 60, 138, 231, 95, 134, 49, 131, 104, 210, 192, 171, 39, 215, 22, 205, 14, 57, 141, 16, 221, 201]), kernelOpeningClaimDigest := (bytes [243, 202, 179, 131, 219, 230, 26, 19, 77, 111, 206, 73, 239, 43, 166, 219, 100, 107, 100, 194, 171, 111, 255, 122, 205, 63, 57, 71, 44, 177, 109, 47]), digest := (bytes [43, 36, 118, 63, 9, 157, 148, 232, 47, 197, 94, 236, 106, 156, 61, 143, 196, 14, 96, 129, 244, 50, 33, 117, 129, 101, 61, 211, 203, 90, 79, 225]) }, digest := (bytes [5, 158, 122, 236, 44, 46, 120, 193, 175, 2, 25, 179, 224, 113, 116, 66, 1, 243, 98, 29, 198, 230, 15, 133, 209, 172, 66, 59, 190, 206, 64, 15]) }
  , root0 := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), stages := { stage1Digest := (bytes [64, 180, 146, 246, 139, 60, 76, 212, 49, 131, 207, 237, 101, 254, 127, 102, 212, 72, 236, 89, 205, 253, 188, 71, 14, 72, 168, 245, 217, 88, 55, 93]), stage2Digest := (bytes [52, 185, 8, 160, 143, 178, 154, 190, 101, 228, 204, 246, 221, 136, 74, 154, 136, 97, 99, 235, 127, 33, 115, 45, 30, 159, 243, 89, 15, 247, 157, 142]), stage3Digest := (bytes [84, 58, 119, 62, 227, 203, 157, 120, 91, 33, 164, 86, 114, 27, 21, 233, 168, 252, 76, 12, 100, 202, 132, 82, 6, 21, 143, 29, 61, 32, 51, 38]), digest := (bytes [129, 68, 6, 98, 94, 113, 239, 119, 107, 235, 21, 226, 14, 23, 49, 31, 9, 11, 141, 148, 30, 79, 174, 30, 50, 108, 124, 52, 48, 93, 54, 249]) }, terminal := { root0Digest := (bytes [160, 47, 136, 108, 204, 129, 79, 197, 229, 103, 193, 132, 46, 237, 116, 161, 76, 12, 119, 193, 191, 6, 227, 119, 236, 118, 88, 172, 48, 50, 35, 98]), executionDigest := (bytes [160, 227, 4, 85, 140, 249, 7, 83, 176, 183, 120, 10, 187, 25, 9, 75, 146, 246, 100, 53, 9, 137, 26, 48, 91, 20, 9, 143, 92, 16, 180, 9]), finalStateDigest := (bytes [67, 56, 221, 172, 183, 26, 231, 188, 189, 215, 247, 181, 112, 58, 232, 221, 188, 253, 63, 175, 15, 72, 182, 206, 231, 128, 239, 141, 249, 6, 198, 30]), transcriptFinalDigest := (bytes [255, 162, 77, 246, 129, 21, 164, 58, 53, 80, 254, 105, 110, 191, 166, 158, 207, 191, 64, 245, 94, 196, 161, 174, 176, 99, 160, 206, 72, 229, 27, 189]), digest := (bytes [95, 22, 34, 167, 29, 69, 60, 99, 112, 15, 134, 214, 198, 195, 9, 21, 100, 227, 56, 174, 193, 173, 147, 210, 14, 252, 15, 175, 251, 189, 56, 24]) }, digest := (bytes [243, 178, 128, 227, 57, 29, 42, 251, 187, 102, 53, 249, 11, 99, 119, 47, 27, 167, 2, 173, 196, 163, 127, 198, 202, 246, 151, 200, 25, 39, 173, 251]) }
  , digest := (bytes [49, 227, 210, 237, 10, 183, 0, 231, 57, 236, 59, 187, 165, 201, 22, 30, 28, 194, 40, 117, 119, 186, 164, 245, 255, 238, 193, 252, 214, 180, 74, 248])
}
  , statement := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , foldSchedule := Nightstream.FoldSchedule.wholeTrace
  , chunkCount := 1
  , stageClaimsDigest := (bytes [82, 91, 83, 175, 161, 62, 254, 207, 152, 70, 151, 72, 246, 103, 232, 195, 170, 41, 28, 111, 11, 192, 113, 61, 195, 0, 56, 76, 145, 1, 192, 167])
  , stagePackagesDigest := (bytes [0, 241, 139, 67, 208, 59, 204, 53, 214, 182, 232, 172, 16, 157, 142, 18, 18, 119, 75, 139, 221, 139, 235, 119, 170, 22, 32, 99, 124, 53, 138, 186])
  , kernelOpeningDigest := (bytes [143, 47, 208, 232, 105, 59, 172, 154, 135, 205, 139, 55, 178, 92, 134, 89, 253, 75, 76, 153, 228, 254, 72, 162, 137, 168, 74, 174, 142, 223, 69, 17])
  , preparedStepBindingsDigest := (bytes [49, 15, 156, 222, 222, 132, 248, 219, 86, 74, 177, 173, 126, 92, 88, 142, 71, 233, 147, 61, 144, 74, 40, 78, 93, 229, 111, 147, 78, 221, 224, 124])
  , executionDigest := (bytes [160, 227, 4, 85, 140, 249, 7, 83, 176, 183, 120, 10, 187, 25, 9, 75, 146, 246, 100, 53, 9, 137, 26, 48, 91, 20, 9, 143, 92, 16, 180, 9])
  , finalStateDigest := (bytes [67, 56, 221, 172, 183, 26, 231, 188, 189, 215, 247, 181, 112, 58, 232, 221, 188, 253, 63, 175, 15, 72, 182, 206, 231, 128, 239, 141, 249, 6, 198, 30])
  , transcriptFinalDigest := (bytes [255, 162, 77, 246, 129, 21, 164, 58, 53, 80, 254, 105, 110, 191, 166, 158, 207, 191, 64, 245, 94, 196, 161, 174, 176, 99, 160, 206, 72, 229, 27, 189])
  , mainLaneSurfaceDigest := (bytes [157, 114, 148, 142, 136, 170, 34, 182, 21, 229, 153, 132, 237, 74, 135, 140, 27, 221, 155, 178, 174, 6, 190, 242, 22, 167, 191, 146, 146, 182, 42, 49])
  , rootLaneColumnsDigest := (bytes [225, 122, 202, 119, 211, 61, 230, 86, 129, 212, 18, 206, 97, 154, 229, 221, 132, 99, 162, 82, 68, 231, 230, 99, 4, 155, 163, 100, 53, 150, 253, 136])
  , publicStepCount := 14
  , initialPc := 0
  , finalPc := 56
  , halted := true
  , digest := (bytes [43, 148, 11, 160, 66, 233, 231, 115, 70, 41, 27, 39, 122, 8, 101, 242, 101, 187, 23, 96, 203, 112, 94, 49, 131, 67, 29, 56, 210, 129, 165, 129])
}
  , kernel := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "native_logic_compare_chain_ecall", fixtureId := "native_logic_compare_chain_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , executionDigest := (bytes [160, 227, 4, 85, 140, 249, 7, 83, 176, 183, 120, 10, 187, 25, 9, 75, 146, 246, 100, 53, 9, 137, 26, 48, 91, 20, 9, 143, 92, 16, 180, 9])
  , shape := { executionRowCount := 14, realRowCount := 14, effectRowCount := 14, commitRowCount := 14, digest := (bytes [98, 27, 16, 203, 163, 39, 179, 238, 226, 141, 246, 213, 119, 136, 91, 127, 225, 172, 34, 125, 207, 246, 89, 73, 181, 67, 50, 45, 109, 140, 177, 128]) }
  , digest := (bytes [54, 77, 166, 199, 117, 175, 43, 138, 198, 157, 160, 244, 179, 194, 196, 103, 209, 182, 248, 110, 114, 9, 218, 177, 4, 83, 169, 122, 189, 68, 112, 23])
}
  , stages := { summary := { stage1RowCount := 14, stage2RegisterReadCount := 17, stage2RegisterWriteCount := 12, stage2RamEventCount := 0, stage2TwistLinkCount := 14, stage3ContinuityCount := 14, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [212, 121, 182, 157, 130, 31, 103, 83, 22, 231, 57, 213, 125, 221, 246, 63, 101, 215, 96, 34, 214, 161, 104, 135, 185, 91, 123, 234, 48, 239, 148, 226]) }, digest := (bytes [253, 22, 78, 69, 28, 133, 223, 161, 128, 253, 133, 85, 114, 218, 23, 234, 67, 40, 241, 162, 84, 225, 131, 143, 19, 32, 93, 218, 127, 244, 61, 249]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [216, 32, 228, 212, 19, 254, 160, 162, 75, 41, 38, 216, 58, 20, 142, 66, 97, 224, 122, 73, 33, 212, 76, 206, 137, 158, 21, 56, 129, 251, 202, 238]), stage1Digest := (bytes [130, 247, 139, 113, 190, 199, 67, 92, 177, 90, 56, 59, 212, 190, 76, 7, 106, 121, 239, 148, 167, 195, 24, 238, 152, 173, 69, 165, 234, 31, 97, 120]), stage2Digest := (bytes [59, 223, 169, 57, 54, 184, 4, 101, 63, 96, 83, 251, 20, 132, 175, 144, 122, 175, 137, 16, 233, 191, 59, 26, 191, 66, 100, 108, 143, 54, 105, 196]), stage3Digest := (bytes [203, 4, 139, 177, 198, 192, 60, 107, 40, 171, 79, 131, 16, 234, 19, 169, 216, 128, 96, 170, 131, 179, 97, 98, 145, 116, 199, 205, 234, 150, 209, 66]), transcriptDigest := (bytes [255, 162, 77, 246, 129, 21, 164, 58, 53, 80, 254, 105, 110, 191, 166, 158, 207, 191, 64, 245, 94, 196, 161, 174, 176, 99, 160, 206, 72, 229, 27, 189]), executionDigest := (bytes [160, 227, 4, 85, 140, 249, 7, 83, 176, 183, 120, 10, 187, 25, 9, 75, 146, 246, 100, 53, 9, 137, 26, 48, 91, 20, 9, 143, 92, 16, 180, 9]), digest := (bytes [73, 160, 4, 47, 240, 97, 89, 234, 165, 28, 225, 61, 143, 196, 212, 92, 228, 61, 244, 136, 8, 79, 79, 172, 23, 71, 81, 200, 142, 176, 155, 198]) }, statementDigest := (bytes [223, 217, 79, 22, 200, 45, 194, 2, 107, 8, 57, 106, 132, 11, 243, 31, 2, 145, 24, 162, 190, 91, 98, 203, 97, 82, 240, 168, 95, 50, 212, 48]), proofDigest := (bytes [180, 255, 82, 224, 253, 0, 148, 235, 124, 11, 163, 47, 51, 195, 215, 62, 85, 80, 193, 141, 182, 30, 211, 161, 181, 231, 225, 211, 127, 206, 178, 134]), digest := (bytes [82, 91, 83, 175, 161, 62, 254, 207, 152, 70, 151, 72, 246, 103, 232, 195, 170, 41, 28, 111, 11, 192, 113, 61, 195, 0, 56, 76, 145, 1, 192, 167]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [189, 31, 79, 14, 204, 208, 208, 71, 134, 15, 236, 185, 181, 28, 81, 145, 219, 208, 251, 41, 93, 43, 132, 149, 208, 180, 210, 74, 29, 67, 229, 6]), stage1Digest := (bytes [51, 63, 211, 186, 53, 109, 214, 181, 53, 47, 220, 172, 153, 111, 64, 147, 58, 164, 115, 119, 49, 122, 105, 76, 55, 28, 186, 147, 134, 23, 195, 34]), stage2Digest := (bytes [241, 163, 5, 223, 23, 221, 24, 134, 104, 142, 140, 248, 100, 214, 117, 54, 151, 122, 237, 155, 109, 20, 173, 192, 160, 221, 211, 80, 50, 211, 55, 77]), stage3Digest := (bytes [185, 92, 17, 202, 45, 12, 222, 226, 100, 195, 61, 245, 228, 18, 236, 184, 35, 105, 128, 226, 194, 228, 196, 136, 241, 250, 141, 81, 14, 6, 246, 103]), digest := (bytes [4, 99, 68, 229, 187, 4, 4, 254, 48, 233, 7, 250, 222, 79, 110, 251, 82, 46, 170, 249, 229, 158, 220, 40, 167, 148, 218, 45, 85, 9, 181, 238]) }, digest := (bytes [0, 241, 139, 67, 208, 59, 204, 53, 214, 182, 232, 172, 16, 157, 142, 18, 18, 119, 75, 139, 221, 139, 235, 119, 170, 22, 32, 99, 124, 53, 138, 186]) }
  , kernelOpening := { openingDigest := (bytes [211, 255, 49, 81, 169, 115, 42, 68, 80, 117, 32, 168, 72, 90, 186, 205, 250, 15, 188, 208, 218, 121, 98, 163, 63, 168, 237, 110, 93, 53, 180, 67]), bindings := { claimDigest := (bytes [233, 118, 64, 129, 165, 249, 195, 188, 13, 127, 117, 113, 7, 236, 106, 87, 47, 166, 208, 183, 46, 103, 181, 137, 164, 184, 174, 225, 49, 52, 15, 52]), bindingsDigest := (bytes [146, 69, 160, 136, 176, 177, 104, 110, 60, 43, 120, 212, 38, 199, 157, 204, 134, 99, 251, 149, 77, 23, 66, 175, 77, 128, 36, 224, 204, 56, 59, 142]), preparedStepsDigest := (bytes [194, 38, 40, 76, 72, 198, 130, 9, 251, 15, 187, 205, 206, 52, 19, 22, 121, 122, 44, 210, 35, 167, 39, 30, 166, 51, 1, 38, 6, 6, 143, 194]), digest := (bytes [85, 21, 110, 105, 130, 200, 29, 255, 8, 30, 214, 248, 93, 75, 111, 61, 171, 17, 76, 102, 129, 100, 87, 61, 183, 94, 212, 242, 248, 207, 223, 208]) }, digest := (bytes [143, 47, 208, 232, 105, 59, 172, 154, 135, 205, 139, 55, 178, 92, 134, 89, 253, 75, 76, 153, 228, 254, 72, 162, 137, 168, 74, 174, 142, 223, 69, 17]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [49, 15, 156, 222, 222, 132, 248, 219, 86, 74, 177, 173, 126, 92, 88, 142, 71, 233, 147, 61, 144, 74, 40, 78, 93, 229, 111, 147, 78, 221, 224, 124]), terminal := { root0Digest := (bytes [160, 47, 136, 108, 204, 129, 79, 197, 229, 103, 193, 132, 46, 237, 116, 161, 76, 12, 119, 193, 191, 6, 227, 119, 236, 118, 88, 172, 48, 50, 35, 98]), executionDigest := (bytes [160, 227, 4, 85, 140, 249, 7, 83, 176, 183, 120, 10, 187, 25, 9, 75, 146, 246, 100, 53, 9, 137, 26, 48, 91, 20, 9, 143, 92, 16, 180, 9]), finalStateDigest := (bytes [67, 56, 221, 172, 183, 26, 231, 188, 189, 215, 247, 181, 112, 58, 232, 221, 188, 253, 63, 175, 15, 72, 182, 206, 231, 128, 239, 141, 249, 6, 198, 30]), transcriptFinalDigest := (bytes [255, 162, 77, 246, 129, 21, 164, 58, 53, 80, 254, 105, 110, 191, 166, 158, 207, 191, 64, 245, 94, 196, 161, 174, 176, 99, 160, 206, 72, 229, 27, 189]), finalPc := 56, halted := true, digest := (bytes [178, 141, 77, 109, 21, 73, 107, 171, 56, 179, 173, 63, 107, 123, 216, 38, 10, 194, 109, 218, 63, 153, 60, 48, 81, 71, 208, 71, 129, 235, 115, 220]) }, digest := (bytes [116, 191, 93, 247, 125, 154, 53, 94, 53, 1, 48, 242, 66, 156, 82, 127, 23, 224, 175, 113, 74, 118, 170, 197, 237, 210, 94, 177, 141, 78, 46, 50]) }, statementDigest := (bytes [121, 81, 8, 82, 242, 231, 166, 46, 197, 5, 160, 168, 10, 6, 14, 122, 96, 29, 2, 218, 92, 22, 219, 162, 199, 16, 113, 249, 245, 212, 245, 134]), proofDigest := (bytes [199, 226, 164, 107, 96, 250, 60, 74, 145, 253, 236, 234, 78, 125, 246, 176, 178, 97, 197, 60, 16, 107, 218, 95, 240, 226, 248, 50, 210, 21, 196, 73]), digest := (bytes [108, 64, 141, 86, 75, 232, 8, 174, 72, 121, 219, 110, 141, 178, 155, 204, 218, 245, 180, 32, 155, 228, 55, 241, 93, 117, 113, 158, 64, 168, 157, 200]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [21, 45, 25, 215, 138, 137, 7, 133, 215, 110, 157, 80, 190, 214, 195, 121, 158, 12, 227, 251, 45, 243, 101, 206, 199, 100, 36, 105, 152, 72, 2, 50]), layoutVersion := 1, digest := (bytes [214, 75, 94, 215, 91, 109, 134, 19, 161, 154, 62, 207, 10, 12, 209, 67, 12, 194, 141, 59, 26, 158, 87, 80, 191, 44, 144, 250, 112, 104, 43, 29]) }, rowWidth := 38, timeLen := 14, columnDigests := [(bytes [117, 219, 33, 6, 121, 216, 214, 88, 201, 71, 161, 234, 46, 145, 226, 25, 168, 148, 81, 127, 39, 201, 178, 91, 125, 55, 226, 134, 98, 162, 247, 165]), (bytes [197, 181, 33, 35, 38, 2, 136, 79, 30, 37, 189, 113, 57, 26, 19, 18, 185, 191, 112, 240, 25, 225, 206, 117, 184, 96, 69, 226, 200, 10, 76, 139]), (bytes [57, 108, 130, 214, 65, 8, 103, 231, 217, 218, 243, 15, 15, 250, 39, 96, 230, 92, 253, 246, 32, 193, 25, 183, 138, 114, 179, 63, 86, 2, 52, 26]), (bytes [35, 205, 28, 213, 21, 92, 83, 146, 40, 245, 171, 225, 235, 158, 123, 171, 220, 228, 247, 250, 67, 19, 107, 111, 185, 91, 15, 208, 242, 155, 155, 237]), (bytes [225, 140, 32, 65, 184, 164, 210, 224, 82, 130, 234, 4, 68, 84, 90, 101, 213, 147, 159, 56, 21, 221, 40, 210, 149, 192, 227, 46, 148, 196, 23, 182]), (bytes [112, 64, 164, 229, 44, 104, 81, 148, 89, 4, 54, 158, 99, 79, 29, 207, 5, 78, 38, 165, 106, 71, 223, 164, 77, 252, 15, 16, 206, 129, 11, 228]), (bytes [59, 23, 13, 174, 99, 176, 215, 100, 74, 207, 200, 4, 45, 23, 227, 121, 174, 32, 3, 14, 109, 163, 162, 237, 222, 141, 35, 52, 196, 142, 119, 121]), (bytes [162, 192, 202, 183, 159, 172, 138, 151, 62, 98, 85, 9, 227, 35, 47, 254, 225, 156, 246, 62, 197, 213, 221, 21, 238, 92, 184, 77, 193, 139, 148, 39]), (bytes [30, 156, 113, 121, 45, 182, 44, 79, 80, 23, 100, 103, 103, 220, 37, 206, 19, 133, 143, 137, 36, 66, 23, 201, 184, 224, 147, 133, 121, 61, 164, 132]), (bytes [156, 238, 235, 235, 231, 56, 7, 144, 230, 102, 206, 102, 232, 250, 181, 201, 253, 212, 223, 216, 248, 101, 154, 132, 67, 141, 180, 235, 176, 0, 222, 186]), (bytes [10, 202, 130, 96, 129, 174, 239, 254, 59, 37, 168, 13, 84, 88, 60, 23, 246, 105, 129, 160, 2, 164, 141, 152, 10, 226, 104, 120, 223, 227, 147, 182]), (bytes [9, 66, 153, 238, 64, 72, 96, 76, 167, 53, 105, 235, 191, 80, 145, 191, 171, 199, 163, 209, 2, 21, 219, 193, 40, 15, 117, 44, 38, 227, 174, 82]), (bytes [53, 210, 212, 164, 155, 209, 180, 66, 35, 26, 74, 182, 180, 154, 135, 145, 137, 232, 23, 91, 107, 43, 121, 206, 253, 135, 62, 8, 176, 59, 70, 15]), (bytes [106, 103, 191, 216, 129, 70, 108, 56, 80, 28, 234, 109, 65, 95, 182, 111, 36, 14, 26, 208, 195, 175, 179, 126, 195, 123, 25, 193, 7, 72, 58, 5]), (bytes [158, 160, 91, 142, 12, 187, 225, 43, 156, 22, 68, 189, 240, 1, 88, 7, 141, 81, 210, 236, 208, 6, 71, 79, 37, 130, 163, 202, 36, 228, 89, 90]), (bytes [46, 141, 40, 223, 54, 17, 192, 49, 98, 51, 120, 151, 49, 190, 176, 227, 105, 252, 116, 226, 229, 183, 147, 50, 206, 83, 32, 121, 210, 41, 242, 19]), (bytes [231, 48, 167, 64, 215, 215, 29, 147, 80, 109, 156, 204, 135, 216, 75, 125, 111, 94, 243, 59, 187, 142, 142, 74, 214, 190, 99, 151, 155, 156, 232, 73]), (bytes [133, 46, 47, 118, 238, 252, 67, 1, 21, 108, 79, 178, 171, 204, 150, 189, 94, 42, 56, 225, 67, 208, 179, 168, 238, 177, 139, 49, 116, 118, 233, 48]), (bytes [46, 251, 78, 50, 246, 29, 89, 188, 104, 90, 229, 230, 68, 49, 70, 98, 0, 159, 143, 222, 166, 67, 222, 126, 233, 42, 212, 215, 177, 122, 245, 244]), (bytes [212, 78, 225, 26, 70, 215, 242, 159, 253, 200, 243, 164, 143, 156, 86, 194, 196, 102, 151, 234, 218, 46, 250, 223, 27, 253, 119, 88, 200, 151, 41, 209]), (bytes [182, 174, 245, 10, 243, 83, 65, 234, 45, 41, 186, 225, 212, 138, 230, 28, 172, 143, 28, 204, 202, 35, 217, 157, 45, 144, 50, 95, 139, 222, 168, 230]), (bytes [21, 77, 175, 162, 196, 200, 15, 200, 96, 52, 57, 177, 5, 199, 15, 224, 233, 131, 135, 35, 0, 74, 204, 63, 45, 38, 40, 42, 83, 165, 235, 243]), (bytes [200, 123, 150, 180, 130, 239, 77, 46, 107, 115, 96, 151, 175, 87, 196, 173, 178, 38, 203, 18, 14, 52, 71, 156, 198, 241, 154, 189, 135, 60, 150, 110]), (bytes [184, 136, 227, 97, 138, 201, 215, 114, 117, 53, 142, 36, 34, 167, 62, 209, 106, 69, 42, 232, 117, 199, 155, 239, 194, 220, 232, 182, 63, 236, 25, 97]), (bytes [22, 55, 140, 189, 108, 57, 66, 26, 133, 242, 191, 229, 238, 69, 253, 171, 74, 63, 149, 139, 162, 33, 95, 212, 14, 166, 26, 181, 169, 173, 73, 107]), (bytes [71, 235, 66, 169, 108, 11, 32, 25, 100, 8, 26, 151, 135, 70, 176, 89, 186, 60, 39, 27, 47, 251, 214, 193, 253, 123, 156, 123, 227, 7, 42, 133]), (bytes [38, 35, 109, 20, 232, 248, 173, 153, 141, 11, 184, 169, 252, 171, 163, 233, 237, 209, 48, 71, 4, 40, 151, 201, 46, 242, 122, 122, 76, 11, 111, 82]), (bytes [115, 209, 211, 165, 55, 80, 224, 206, 50, 30, 225, 178, 67, 220, 207, 144, 208, 23, 121, 128, 32, 139, 245, 153, 224, 172, 81, 199, 157, 129, 211, 234]), (bytes [118, 95, 207, 73, 175, 215, 224, 3, 14, 57, 95, 55, 64, 126, 153, 245, 171, 14, 102, 120, 48, 223, 7, 108, 134, 216, 22, 195, 42, 52, 105, 193]), (bytes [88, 173, 13, 26, 248, 14, 100, 146, 9, 13, 119, 131, 100, 96, 131, 15, 46, 36, 166, 90, 58, 117, 139, 234, 255, 203, 93, 134, 162, 52, 138, 196]), (bytes [219, 235, 162, 252, 244, 131, 57, 44, 96, 184, 103, 140, 129, 91, 68, 126, 235, 200, 120, 74, 129, 82, 219, 2, 219, 239, 106, 136, 241, 248, 4, 6]), (bytes [81, 28, 93, 93, 78, 249, 146, 159, 50, 232, 208, 43, 63, 144, 199, 21, 179, 47, 31, 243, 102, 195, 82, 239, 22, 75, 90, 82, 11, 186, 64, 183]), (bytes [178, 1, 114, 173, 184, 198, 199, 2, 65, 38, 209, 186, 236, 30, 77, 73, 178, 252, 99, 158, 156, 60, 16, 109, 47, 2, 150, 51, 182, 12, 158, 105]), (bytes [170, 253, 136, 66, 232, 134, 49, 97, 255, 124, 180, 202, 199, 107, 154, 137, 63, 179, 121, 77, 63, 183, 209, 85, 250, 46, 51, 59, 76, 216, 149, 2]), (bytes [49, 120, 127, 173, 34, 105, 205, 134, 178, 107, 240, 182, 184, 188, 174, 96, 13, 204, 69, 149, 244, 10, 15, 30, 97, 136, 83, 122, 151, 98, 204, 122]), (bytes [206, 71, 13, 21, 155, 247, 202, 63, 127, 27, 147, 48, 193, 52, 116, 125, 197, 59, 78, 254, 220, 172, 61, 227, 236, 77, 54, 242, 46, 251, 223, 109]), (bytes [42, 247, 89, 60, 176, 10, 50, 11, 210, 124, 225, 47, 203, 182, 22, 10, 69, 47, 163, 227, 61, 219, 255, 58, 27, 125, 7, 215, 15, 46, 153, 158]), (bytes [13, 4, 101, 10, 60, 237, 254, 163, 224, 43, 55, 67, 190, 96, 200, 157, 57, 12, 196, 123, 175, 252, 100, 2, 55, 183, 231, 132, 214, 148, 208, 173])], familyDigest := (bytes [21, 45, 25, 215, 138, 137, 7, 133, 215, 110, 157, 80, 190, 214, 195, 121, 158, 12, 227, 251, 45, 243, 101, 206, 199, 100, 36, 105, 152, 72, 2, 50]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [21, 45, 25, 215, 138, 137, 7, 133, 215, 110, 157, 80, 190, 214, 195, 121, 158, 12, 227, 251, 45, 243, 101, 206, 199, 100, 36, 105, 152, 72, 2, 50]), layoutVersion := 1, digest := (bytes [214, 75, 94, 215, 91, 109, 134, 19, 161, 154, 62, 207, 10, 12, 209, 67, 12, 194, 141, 59, 26, 158, 87, 80, 191, 44, 144, 250, 112, 104, 43, 29]) }, logicalIndex := 0, digest := (bytes [212, 251, 215, 182, 26, 81, 126, 18, 167, 62, 136, 137, 74, 50, 183, 244, 249, 148, 146, 115, 7, 221, 9, 25, 73, 36, 27, 98, 74, 185, 12, 250]) }, valueDigest := (bytes [195, 104, 190, 242, 104, 180, 234, 122, 108, 245, 168, 232, 122, 59, 5, 141, 148, 97, 161, 16, 201, 133, 162, 230, 49, 127, 153, 215, 226, 163, 192, 66]), digest := (bytes [229, 44, 46, 216, 109, 204, 220, 233, 58, 5, 59, 127, 77, 57, 93, 180, 92, 174, 71, 184, 220, 8, 113, 222, 241, 157, 184, 161, 240, 199, 81, 75]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [21, 45, 25, 215, 138, 137, 7, 133, 215, 110, 157, 80, 190, 214, 195, 121, 158, 12, 227, 251, 45, 243, 101, 206, 199, 100, 36, 105, 152, 72, 2, 50]), layoutVersion := 1, digest := (bytes [214, 75, 94, 215, 91, 109, 134, 19, 161, 154, 62, 207, 10, 12, 209, 67, 12, 194, 141, 59, 26, 158, 87, 80, 191, 44, 144, 250, 112, 104, 43, 29]) }, logicalIndex := 13, digest := (bytes [136, 16, 76, 149, 67, 51, 94, 206, 213, 112, 20, 104, 240, 255, 176, 60, 202, 245, 225, 21, 12, 224, 192, 247, 123, 154, 88, 4, 102, 146, 16, 136]) }, valueDigest := (bytes [228, 218, 132, 173, 40, 175, 163, 113, 77, 51, 14, 129, 172, 72, 64, 113, 166, 5, 209, 86, 65, 181, 139, 164, 241, 195, 58, 252, 148, 133, 40, 21]), digest := (bytes [35, 165, 121, 231, 139, 68, 67, 111, 41, 179, 143, 236, 33, 48, 73, 237, 21, 135, 195, 13, 104, 225, 9, 101, 64, 133, 47, 110, 7, 141, 253, 126]) }), digest := (bytes [225, 122, 202, 119, 211, 61, 230, 86, 129, 212, 18, 206, 97, 154, 229, 221, 132, 99, 162, 82, 68, 231, 230, 99, 4, 155, 163, 100, 53, 150, 253, 136]) }
  , rootLaneCommitment := { timeLen := 14, commitments := { commitmentCount := 38, digest := (bytes [219, 195, 168, 58, 246, 163, 92, 165, 69, 68, 110, 143, 93, 49, 110, 10, 179, 183, 197, 231, 89, 147, 118, 24, 213, 113, 174, 182, 139, 68, 78, 10]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [219, 195, 168, 58, 246, 163, 92, 165, 69, 68, 110, 143, 93, 49, 110, 10, 179, 183, 197, 231, 89, 147, 118, 24, 213, 113, 174, 182, 139, 68, 78, 10]), layoutVersion := 3, digest := (bytes [54, 65, 220, 157, 10, 119, 33, 155, 19, 18, 245, 163, 208, 135, 18, 19, 24, 227, 38, 183, 95, 97, 46, 170, 116, 249, 170, 121, 2, 11, 204, 182]) }, logicalIndex := 0, digest := (bytes [241, 115, 53, 60, 47, 124, 25, 29, 82, 180, 123, 91, 122, 32, 206, 112, 208, 0, 206, 191, 62, 203, 101, 97, 201, 179, 232, 144, 237, 192, 143, 121]) }, valueDigest := (bytes [195, 104, 190, 242, 104, 180, 234, 122, 108, 245, 168, 232, 122, 59, 5, 141, 148, 97, 161, 16, 201, 133, 162, 230, 49, 127, 153, 215, 226, 163, 192, 66]), digest := (bytes [89, 78, 226, 130, 74, 6, 255, 150, 236, 10, 155, 172, 163, 196, 73, 50, 37, 76, 115, 142, 113, 231, 224, 168, 209, 76, 106, 244, 171, 66, 169, 154]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [219, 195, 168, 58, 246, 163, 92, 165, 69, 68, 110, 143, 93, 49, 110, 10, 179, 183, 197, 231, 89, 147, 118, 24, 213, 113, 174, 182, 139, 68, 78, 10]), layoutVersion := 3, digest := (bytes [54, 65, 220, 157, 10, 119, 33, 155, 19, 18, 245, 163, 208, 135, 18, 19, 24, 227, 38, 183, 95, 97, 46, 170, 116, 249, 170, 121, 2, 11, 204, 182]) }, logicalIndex := 13, digest := (bytes [185, 1, 193, 126, 91, 144, 233, 178, 197, 252, 245, 92, 123, 155, 197, 155, 10, 196, 139, 217, 152, 18, 84, 207, 109, 8, 90, 93, 226, 254, 153, 106]) }, valueDigest := (bytes [228, 218, 132, 173, 40, 175, 163, 113, 77, 51, 14, 129, 172, 72, 64, 113, 166, 5, 209, 86, 65, 181, 139, 164, 241, 195, 58, 252, 148, 133, 40, 21]), digest := (bytes [100, 245, 202, 28, 32, 25, 16, 215, 85, 76, 248, 178, 234, 220, 79, 156, 168, 40, 235, 229, 37, 100, 64, 184, 15, 144, 28, 188, 217, 69, 155, 173]) }), digest := (bytes [40, 69, 56, 85, 171, 193, 21, 86, 12, 115, 250, 132, 216, 70, 194, 119, 195, 78, 79, 250, 249, 208, 33, 23, 244, 28, 33, 90, 220, 90, 136, 23]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [225, 122, 202, 119, 211, 61, 230, 86, 129, 212, 18, 206, 97, 154, 229, 221, 132, 99, 162, 82, 68, 231, 230, 99, 4, 155, 163, 100, 53, 150, 253, 136]), rootLaneCommitmentDigest := (bytes [40, 69, 56, 85, 171, 193, 21, 86, 12, 115, 250, 132, 216, 70, 194, 119, 195, 78, 79, 250, 249, 208, 33, 23, 244, 28, 33, 90, 220, 90, 136, 23]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 14, digest := (bytes [145, 180, 130, 91, 155, 62, 221, 96, 76, 78, 228, 160, 188, 5, 204, 73, 241, 89, 79, 184, 135, 187, 214, 132, 167, 18, 254, 183, 18, 158, 106, 93]) }, statementDigest := (bytes [113, 63, 31, 237, 65, 2, 87, 182, 247, 241, 197, 211, 37, 239, 137, 135, 15, 246, 76, 190, 148, 98, 253, 235, 220, 39, 237, 155, 89, 217, 142, 48]), proofDigest := (bytes [145, 41, 204, 146, 205, 253, 124, 41, 180, 135, 11, 131, 74, 35, 113, 62, 61, 146, 142, 242, 220, 107, 208, 201, 49, 33, 207, 155, 129, 118, 140, 243]), digest := (bytes [74, 129, 33, 167, 23, 241, 3, 172, 136, 8, 212, 7, 162, 100, 186, 51, 106, 184, 249, 123, 189, 184, 1, 200, 179, 172, 80, 207, 46, 93, 96, 32]) }
  , digest := (bytes [171, 71, 135, 204, 223, 232, 85, 180, 153, 205, 222, 8, 114, 1, 56, 56, 37, 137, 114, 119, 167, 24, 169, 20, 119, 90, 179, 217, 175, 147, 27, 61])
}
}
    , exportedStatement := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , foldSchedule := Nightstream.FoldSchedule.wholeTrace
  , chunkCount := 1
  , stageClaimsDigest := (bytes [82, 91, 83, 175, 161, 62, 254, 207, 152, 70, 151, 72, 246, 103, 232, 195, 170, 41, 28, 111, 11, 192, 113, 61, 195, 0, 56, 76, 145, 1, 192, 167])
  , stagePackagesDigest := (bytes [0, 241, 139, 67, 208, 59, 204, 53, 214, 182, 232, 172, 16, 157, 142, 18, 18, 119, 75, 139, 221, 139, 235, 119, 170, 22, 32, 99, 124, 53, 138, 186])
  , kernelOpeningDigest := (bytes [143, 47, 208, 232, 105, 59, 172, 154, 135, 205, 139, 55, 178, 92, 134, 89, 253, 75, 76, 153, 228, 254, 72, 162, 137, 168, 74, 174, 142, 223, 69, 17])
  , preparedStepBindingsDigest := (bytes [49, 15, 156, 222, 222, 132, 248, 219, 86, 74, 177, 173, 126, 92, 88, 142, 71, 233, 147, 61, 144, 74, 40, 78, 93, 229, 111, 147, 78, 221, 224, 124])
  , executionDigest := (bytes [160, 227, 4, 85, 140, 249, 7, 83, 176, 183, 120, 10, 187, 25, 9, 75, 146, 246, 100, 53, 9, 137, 26, 48, 91, 20, 9, 143, 92, 16, 180, 9])
  , finalStateDigest := (bytes [67, 56, 221, 172, 183, 26, 231, 188, 189, 215, 247, 181, 112, 58, 232, 221, 188, 253, 63, 175, 15, 72, 182, 206, 231, 128, 239, 141, 249, 6, 198, 30])
  , transcriptFinalDigest := (bytes [255, 162, 77, 246, 129, 21, 164, 58, 53, 80, 254, 105, 110, 191, 166, 158, 207, 191, 64, 245, 94, 196, 161, 174, 176, 99, 160, 206, 72, 229, 27, 189])
  , mainLaneSurfaceDigest := (bytes [157, 114, 148, 142, 136, 170, 34, 182, 21, 229, 153, 132, 237, 74, 135, 140, 27, 221, 155, 178, 174, 6, 190, 242, 22, 167, 191, 146, 146, 182, 42, 49])
  , rootLaneColumnsDigest := (bytes [225, 122, 202, 119, 211, 61, 230, 86, 129, 212, 18, 206, 97, 154, 229, 221, 132, 99, 162, 82, 68, 231, 230, 99, 4, 155, 163, 100, 53, 150, 253, 136])
  , publicStepCount := 14
  , initialPc := 0
  , finalPc := 56
  , halted := true
  , digest := (bytes [43, 148, 11, 160, 66, 233, 231, 115, 70, 41, 27, 39, 122, 8, 101, 242, 101, 187, 23, 96, 203, 112, 94, 49, 131, 67, 29, 56, 210, 129, 165, 129])
}
    , exportedClaims := {
  accepted := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , statement := { proofStatementDigest := (bytes [43, 148, 11, 160, 66, 233, 231, 115, 70, 41, 27, 39, 122, 8, 101, 242, 101, 187, 23, 96, 203, 112, 94, 49, 131, 67, 29, 56, 210, 129, 165, 129]), kernelOpeningDigest := (bytes [143, 47, 208, 232, 105, 59, 172, 154, 135, 205, 139, 55, 178, 92, 134, 89, 253, 75, 76, 153, 228, 254, 72, 162, 137, 168, 74, 174, 142, 223, 69, 17]), digest := (bytes [153, 182, 9, 97, 140, 10, 187, 24, 23, 144, 160, 132, 219, 195, 255, 225, 216, 126, 19, 77, 175, 103, 178, 78, 167, 132, 208, 182, 130, 123, 159, 12]) }
  , mainLane := { mainLaneBundleDigest := (bytes [74, 129, 33, 167, 23, 241, 3, 172, 136, 8, 212, 7, 162, 100, 186, 51, 106, 184, 249, 123, 189, 184, 1, 200, 179, 172, 80, 207, 46, 93, 96, 32]), digest := (bytes [169, 103, 20, 147, 151, 46, 224, 158, 40, 126, 203, 214, 116, 204, 20, 18, 179, 19, 195, 28, 123, 187, 186, 34, 148, 24, 181, 125, 180, 39, 128, 222]) }
  , terminal := { finalStateDigest := (bytes [67, 56, 221, 172, 183, 26, 231, 188, 189, 215, 247, 181, 112, 58, 232, 221, 188, 253, 63, 175, 15, 72, 182, 206, 231, 128, 239, 141, 249, 6, 198, 30]), finalPc := 56, halted := true, digest := (bytes [221, 217, 28, 9, 91, 13, 112, 45, 176, 158, 0, 39, 53, 48, 20, 244, 27, 150, 63, 118, 246, 39, 186, 79, 198, 41, 196, 52, 64, 233, 166, 130]) }
  , digest := (bytes [42, 86, 110, 158, 95, 72, 188, 41, 123, 14, 225, 215, 152, 94, 186, 116, 232, 185, 236, 246, 24, 161, 231, 250, 99, 169, 156, 1, 103, 163, 4, 5])
}
  , mainLane := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { mainLaneBundleDigest := (bytes [74, 129, 33, 167, 23, 241, 3, 172, 136, 8, 212, 7, 162, 100, 186, 51, 106, 184, 249, 123, 189, 184, 1, 200, 179, 172, 80, 207, 46, 93, 96, 32]), digest := (bytes [7, 159, 54, 170, 155, 218, 73, 249, 27, 249, 106, 48, 84, 48, 12, 151, 71, 171, 90, 246, 46, 186, 95, 249, 37, 161, 29, 30, 115, 227, 77, 132]) }, digest := (bytes [104, 166, 52, 151, 159, 153, 106, 101, 82, 79, 119, 60, 138, 231, 95, 134, 49, 131, 104, 210, 192, 171, 39, 215, 22, 205, 14, 57, 141, 16, 221, 201]) }
  , opening := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , stages := { stageClaimsDigest := (bytes [82, 91, 83, 175, 161, 62, 254, 207, 152, 70, 151, 72, 246, 103, 232, 195, 170, 41, 28, 111, 11, 192, 113, 61, 195, 0, 56, 76, 145, 1, 192, 167]), stagePackagesDigest := (bytes [0, 241, 139, 67, 208, 59, 204, 53, 214, 182, 232, 172, 16, 157, 142, 18, 18, 119, 75, 139, 221, 139, 235, 119, 170, 22, 32, 99, 124, 53, 138, 186]), kernelOpeningDigest := (bytes [143, 47, 208, 232, 105, 59, 172, 154, 135, 205, 139, 55, 178, 92, 134, 89, 253, 75, 76, 153, 228, 254, 72, 162, 137, 168, 74, 174, 142, 223, 69, 17]), digest := (bytes [106, 183, 230, 184, 23, 47, 80, 134, 52, 18, 120, 197, 11, 107, 4, 8, 96, 77, 49, 192, 215, 135, 159, 144, 78, 47, 202, 174, 109, 76, 7, 246]) }
  , terminal := { preparedStepBindingsDigest := (bytes [49, 15, 156, 222, 222, 132, 248, 219, 86, 74, 177, 173, 126, 92, 88, 142, 71, 233, 147, 61, 144, 74, 40, 78, 93, 229, 111, 147, 78, 221, 224, 124]), executionDigest := (bytes [160, 227, 4, 85, 140, 249, 7, 83, 176, 183, 120, 10, 187, 25, 9, 75, 146, 246, 100, 53, 9, 137, 26, 48, 91, 20, 9, 143, 92, 16, 180, 9]), transcriptFinalDigest := (bytes [255, 162, 77, 246, 129, 21, 164, 58, 53, 80, 254, 105, 110, 191, 166, 158, 207, 191, 64, 245, 94, 196, 161, 174, 176, 99, 160, 206, 72, 229, 27, 189]), digest := (bytes [0, 191, 245, 88, 39, 162, 110, 136, 64, 209, 107, 50, 69, 115, 7, 218, 184, 158, 185, 98, 5, 196, 212, 249, 111, 112, 132, 103, 150, 174, 105, 37]) }
  , digest := (bytes [243, 202, 179, 131, 219, 230, 26, 19, 77, 111, 206, 73, 239, 43, 166, 219, 100, 107, 100, 194, 171, 111, 255, 122, 205, 63, 57, 71, 44, 177, 109, 47])
}
  , jointOpening := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { proofStatementDigest := (bytes [43, 148, 11, 160, 66, 233, 231, 115, 70, 41, 27, 39, 122, 8, 101, 242, 101, 187, 23, 96, 203, 112, 94, 49, 131, 67, 29, 56, 210, 129, 165, 129]), mainLaneClaimDigest := (bytes [104, 166, 52, 151, 159, 153, 106, 101, 82, 79, 119, 60, 138, 231, 95, 134, 49, 131, 104, 210, 192, 171, 39, 215, 22, 205, 14, 57, 141, 16, 221, 201]), kernelOpeningClaimDigest := (bytes [243, 202, 179, 131, 219, 230, 26, 19, 77, 111, 206, 73, 239, 43, 166, 219, 100, 107, 100, 194, 171, 111, 255, 122, 205, 63, 57, 71, 44, 177, 109, 47]), digest := (bytes [43, 36, 118, 63, 9, 157, 148, 232, 47, 197, 94, 236, 106, 156, 61, 143, 196, 14, 96, 129, 244, 50, 33, 117, 129, 101, 61, 211, 203, 90, 79, 225]) }, digest := (bytes [5, 158, 122, 236, 44, 46, 120, 193, 175, 2, 25, 179, 224, 113, 116, 66, 1, 243, 98, 29, 198, 230, 15, 133, 209, 172, 66, 59, 190, 206, 64, 15]) }
  , root0 := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), stages := { stage1Digest := (bytes [64, 180, 146, 246, 139, 60, 76, 212, 49, 131, 207, 237, 101, 254, 127, 102, 212, 72, 236, 89, 205, 253, 188, 71, 14, 72, 168, 245, 217, 88, 55, 93]), stage2Digest := (bytes [52, 185, 8, 160, 143, 178, 154, 190, 101, 228, 204, 246, 221, 136, 74, 154, 136, 97, 99, 235, 127, 33, 115, 45, 30, 159, 243, 89, 15, 247, 157, 142]), stage3Digest := (bytes [84, 58, 119, 62, 227, 203, 157, 120, 91, 33, 164, 86, 114, 27, 21, 233, 168, 252, 76, 12, 100, 202, 132, 82, 6, 21, 143, 29, 61, 32, 51, 38]), digest := (bytes [129, 68, 6, 98, 94, 113, 239, 119, 107, 235, 21, 226, 14, 23, 49, 31, 9, 11, 141, 148, 30, 79, 174, 30, 50, 108, 124, 52, 48, 93, 54, 249]) }, terminal := { root0Digest := (bytes [160, 47, 136, 108, 204, 129, 79, 197, 229, 103, 193, 132, 46, 237, 116, 161, 76, 12, 119, 193, 191, 6, 227, 119, 236, 118, 88, 172, 48, 50, 35, 98]), executionDigest := (bytes [160, 227, 4, 85, 140, 249, 7, 83, 176, 183, 120, 10, 187, 25, 9, 75, 146, 246, 100, 53, 9, 137, 26, 48, 91, 20, 9, 143, 92, 16, 180, 9]), finalStateDigest := (bytes [67, 56, 221, 172, 183, 26, 231, 188, 189, 215, 247, 181, 112, 58, 232, 221, 188, 253, 63, 175, 15, 72, 182, 206, 231, 128, 239, 141, 249, 6, 198, 30]), transcriptFinalDigest := (bytes [255, 162, 77, 246, 129, 21, 164, 58, 53, 80, 254, 105, 110, 191, 166, 158, 207, 191, 64, 245, 94, 196, 161, 174, 176, 99, 160, 206, 72, 229, 27, 189]), digest := (bytes [95, 22, 34, 167, 29, 69, 60, 99, 112, 15, 134, 214, 198, 195, 9, 21, 100, 227, 56, 174, 193, 173, 147, 210, 14, 252, 15, 175, 251, 189, 56, 24]) }, digest := (bytes [243, 178, 128, 227, 57, 29, 42, 251, 187, 102, 53, 249, 11, 99, 119, 47, 27, 167, 2, 173, 196, 163, 127, 198, 202, 246, 151, 200, 25, 39, 173, 251]) }
  , digest := (bytes [49, 227, 210, 237, 10, 183, 0, 231, 57, 236, 59, 187, 165, 201, 22, 30, 28, 194, 40, 117, 119, 186, 164, 245, 255, 238, 193, 252, 214, 180, 74, 248])
}
    , exportedKernelProof := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "native_logic_compare_chain_ecall", fixtureId := "native_logic_compare_chain_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , executionDigest := (bytes [160, 227, 4, 85, 140, 249, 7, 83, 176, 183, 120, 10, 187, 25, 9, 75, 146, 246, 100, 53, 9, 137, 26, 48, 91, 20, 9, 143, 92, 16, 180, 9])
  , shape := { executionRowCount := 14, realRowCount := 14, effectRowCount := 14, commitRowCount := 14, digest := (bytes [98, 27, 16, 203, 163, 39, 179, 238, 226, 141, 246, 213, 119, 136, 91, 127, 225, 172, 34, 125, 207, 246, 89, 73, 181, 67, 50, 45, 109, 140, 177, 128]) }
  , digest := (bytes [54, 77, 166, 199, 117, 175, 43, 138, 198, 157, 160, 244, 179, 194, 196, 103, 209, 182, 248, 110, 114, 9, 218, 177, 4, 83, 169, 122, 189, 68, 112, 23])
}
  , stages := { summary := { stage1RowCount := 14, stage2RegisterReadCount := 17, stage2RegisterWriteCount := 12, stage2RamEventCount := 0, stage2TwistLinkCount := 14, stage3ContinuityCount := 14, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [212, 121, 182, 157, 130, 31, 103, 83, 22, 231, 57, 213, 125, 221, 246, 63, 101, 215, 96, 34, 214, 161, 104, 135, 185, 91, 123, 234, 48, 239, 148, 226]) }, digest := (bytes [253, 22, 78, 69, 28, 133, 223, 161, 128, 253, 133, 85, 114, 218, 23, 234, 67, 40, 241, 162, 84, 225, 131, 143, 19, 32, 93, 218, 127, 244, 61, 249]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [216, 32, 228, 212, 19, 254, 160, 162, 75, 41, 38, 216, 58, 20, 142, 66, 97, 224, 122, 73, 33, 212, 76, 206, 137, 158, 21, 56, 129, 251, 202, 238]), stage1Digest := (bytes [130, 247, 139, 113, 190, 199, 67, 92, 177, 90, 56, 59, 212, 190, 76, 7, 106, 121, 239, 148, 167, 195, 24, 238, 152, 173, 69, 165, 234, 31, 97, 120]), stage2Digest := (bytes [59, 223, 169, 57, 54, 184, 4, 101, 63, 96, 83, 251, 20, 132, 175, 144, 122, 175, 137, 16, 233, 191, 59, 26, 191, 66, 100, 108, 143, 54, 105, 196]), stage3Digest := (bytes [203, 4, 139, 177, 198, 192, 60, 107, 40, 171, 79, 131, 16, 234, 19, 169, 216, 128, 96, 170, 131, 179, 97, 98, 145, 116, 199, 205, 234, 150, 209, 66]), transcriptDigest := (bytes [255, 162, 77, 246, 129, 21, 164, 58, 53, 80, 254, 105, 110, 191, 166, 158, 207, 191, 64, 245, 94, 196, 161, 174, 176, 99, 160, 206, 72, 229, 27, 189]), executionDigest := (bytes [160, 227, 4, 85, 140, 249, 7, 83, 176, 183, 120, 10, 187, 25, 9, 75, 146, 246, 100, 53, 9, 137, 26, 48, 91, 20, 9, 143, 92, 16, 180, 9]), digest := (bytes [73, 160, 4, 47, 240, 97, 89, 234, 165, 28, 225, 61, 143, 196, 212, 92, 228, 61, 244, 136, 8, 79, 79, 172, 23, 71, 81, 200, 142, 176, 155, 198]) }, statementDigest := (bytes [223, 217, 79, 22, 200, 45, 194, 2, 107, 8, 57, 106, 132, 11, 243, 31, 2, 145, 24, 162, 190, 91, 98, 203, 97, 82, 240, 168, 95, 50, 212, 48]), proofDigest := (bytes [180, 255, 82, 224, 253, 0, 148, 235, 124, 11, 163, 47, 51, 195, 215, 62, 85, 80, 193, 141, 182, 30, 211, 161, 181, 231, 225, 211, 127, 206, 178, 134]), digest := (bytes [82, 91, 83, 175, 161, 62, 254, 207, 152, 70, 151, 72, 246, 103, 232, 195, 170, 41, 28, 111, 11, 192, 113, 61, 195, 0, 56, 76, 145, 1, 192, 167]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [189, 31, 79, 14, 204, 208, 208, 71, 134, 15, 236, 185, 181, 28, 81, 145, 219, 208, 251, 41, 93, 43, 132, 149, 208, 180, 210, 74, 29, 67, 229, 6]), stage1Digest := (bytes [51, 63, 211, 186, 53, 109, 214, 181, 53, 47, 220, 172, 153, 111, 64, 147, 58, 164, 115, 119, 49, 122, 105, 76, 55, 28, 186, 147, 134, 23, 195, 34]), stage2Digest := (bytes [241, 163, 5, 223, 23, 221, 24, 134, 104, 142, 140, 248, 100, 214, 117, 54, 151, 122, 237, 155, 109, 20, 173, 192, 160, 221, 211, 80, 50, 211, 55, 77]), stage3Digest := (bytes [185, 92, 17, 202, 45, 12, 222, 226, 100, 195, 61, 245, 228, 18, 236, 184, 35, 105, 128, 226, 194, 228, 196, 136, 241, 250, 141, 81, 14, 6, 246, 103]), digest := (bytes [4, 99, 68, 229, 187, 4, 4, 254, 48, 233, 7, 250, 222, 79, 110, 251, 82, 46, 170, 249, 229, 158, 220, 40, 167, 148, 218, 45, 85, 9, 181, 238]) }, digest := (bytes [0, 241, 139, 67, 208, 59, 204, 53, 214, 182, 232, 172, 16, 157, 142, 18, 18, 119, 75, 139, 221, 139, 235, 119, 170, 22, 32, 99, 124, 53, 138, 186]) }
  , kernelOpening := { openingDigest := (bytes [211, 255, 49, 81, 169, 115, 42, 68, 80, 117, 32, 168, 72, 90, 186, 205, 250, 15, 188, 208, 218, 121, 98, 163, 63, 168, 237, 110, 93, 53, 180, 67]), bindings := { claimDigest := (bytes [233, 118, 64, 129, 165, 249, 195, 188, 13, 127, 117, 113, 7, 236, 106, 87, 47, 166, 208, 183, 46, 103, 181, 137, 164, 184, 174, 225, 49, 52, 15, 52]), bindingsDigest := (bytes [146, 69, 160, 136, 176, 177, 104, 110, 60, 43, 120, 212, 38, 199, 157, 204, 134, 99, 251, 149, 77, 23, 66, 175, 77, 128, 36, 224, 204, 56, 59, 142]), preparedStepsDigest := (bytes [194, 38, 40, 76, 72, 198, 130, 9, 251, 15, 187, 205, 206, 52, 19, 22, 121, 122, 44, 210, 35, 167, 39, 30, 166, 51, 1, 38, 6, 6, 143, 194]), digest := (bytes [85, 21, 110, 105, 130, 200, 29, 255, 8, 30, 214, 248, 93, 75, 111, 61, 171, 17, 76, 102, 129, 100, 87, 61, 183, 94, 212, 242, 248, 207, 223, 208]) }, digest := (bytes [143, 47, 208, 232, 105, 59, 172, 154, 135, 205, 139, 55, 178, 92, 134, 89, 253, 75, 76, 153, 228, 254, 72, 162, 137, 168, 74, 174, 142, 223, 69, 17]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [49, 15, 156, 222, 222, 132, 248, 219, 86, 74, 177, 173, 126, 92, 88, 142, 71, 233, 147, 61, 144, 74, 40, 78, 93, 229, 111, 147, 78, 221, 224, 124]), terminal := { root0Digest := (bytes [160, 47, 136, 108, 204, 129, 79, 197, 229, 103, 193, 132, 46, 237, 116, 161, 76, 12, 119, 193, 191, 6, 227, 119, 236, 118, 88, 172, 48, 50, 35, 98]), executionDigest := (bytes [160, 227, 4, 85, 140, 249, 7, 83, 176, 183, 120, 10, 187, 25, 9, 75, 146, 246, 100, 53, 9, 137, 26, 48, 91, 20, 9, 143, 92, 16, 180, 9]), finalStateDigest := (bytes [67, 56, 221, 172, 183, 26, 231, 188, 189, 215, 247, 181, 112, 58, 232, 221, 188, 253, 63, 175, 15, 72, 182, 206, 231, 128, 239, 141, 249, 6, 198, 30]), transcriptFinalDigest := (bytes [255, 162, 77, 246, 129, 21, 164, 58, 53, 80, 254, 105, 110, 191, 166, 158, 207, 191, 64, 245, 94, 196, 161, 174, 176, 99, 160, 206, 72, 229, 27, 189]), finalPc := 56, halted := true, digest := (bytes [178, 141, 77, 109, 21, 73, 107, 171, 56, 179, 173, 63, 107, 123, 216, 38, 10, 194, 109, 218, 63, 153, 60, 48, 81, 71, 208, 71, 129, 235, 115, 220]) }, digest := (bytes [116, 191, 93, 247, 125, 154, 53, 94, 53, 1, 48, 242, 66, 156, 82, 127, 23, 224, 175, 113, 74, 118, 170, 197, 237, 210, 94, 177, 141, 78, 46, 50]) }, statementDigest := (bytes [121, 81, 8, 82, 242, 231, 166, 46, 197, 5, 160, 168, 10, 6, 14, 122, 96, 29, 2, 218, 92, 22, 219, 162, 199, 16, 113, 249, 245, 212, 245, 134]), proofDigest := (bytes [199, 226, 164, 107, 96, 250, 60, 74, 145, 253, 236, 234, 78, 125, 246, 176, 178, 97, 197, 60, 16, 107, 218, 95, 240, 226, 248, 50, 210, 21, 196, 73]), digest := (bytes [108, 64, 141, 86, 75, 232, 8, 174, 72, 121, 219, 110, 141, 178, 155, 204, 218, 245, 180, 32, 155, 228, 55, 241, 93, 117, 113, 158, 64, 168, 157, 200]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [21, 45, 25, 215, 138, 137, 7, 133, 215, 110, 157, 80, 190, 214, 195, 121, 158, 12, 227, 251, 45, 243, 101, 206, 199, 100, 36, 105, 152, 72, 2, 50]), layoutVersion := 1, digest := (bytes [214, 75, 94, 215, 91, 109, 134, 19, 161, 154, 62, 207, 10, 12, 209, 67, 12, 194, 141, 59, 26, 158, 87, 80, 191, 44, 144, 250, 112, 104, 43, 29]) }, rowWidth := 38, timeLen := 14, columnDigests := [(bytes [117, 219, 33, 6, 121, 216, 214, 88, 201, 71, 161, 234, 46, 145, 226, 25, 168, 148, 81, 127, 39, 201, 178, 91, 125, 55, 226, 134, 98, 162, 247, 165]), (bytes [197, 181, 33, 35, 38, 2, 136, 79, 30, 37, 189, 113, 57, 26, 19, 18, 185, 191, 112, 240, 25, 225, 206, 117, 184, 96, 69, 226, 200, 10, 76, 139]), (bytes [57, 108, 130, 214, 65, 8, 103, 231, 217, 218, 243, 15, 15, 250, 39, 96, 230, 92, 253, 246, 32, 193, 25, 183, 138, 114, 179, 63, 86, 2, 52, 26]), (bytes [35, 205, 28, 213, 21, 92, 83, 146, 40, 245, 171, 225, 235, 158, 123, 171, 220, 228, 247, 250, 67, 19, 107, 111, 185, 91, 15, 208, 242, 155, 155, 237]), (bytes [225, 140, 32, 65, 184, 164, 210, 224, 82, 130, 234, 4, 68, 84, 90, 101, 213, 147, 159, 56, 21, 221, 40, 210, 149, 192, 227, 46, 148, 196, 23, 182]), (bytes [112, 64, 164, 229, 44, 104, 81, 148, 89, 4, 54, 158, 99, 79, 29, 207, 5, 78, 38, 165, 106, 71, 223, 164, 77, 252, 15, 16, 206, 129, 11, 228]), (bytes [59, 23, 13, 174, 99, 176, 215, 100, 74, 207, 200, 4, 45, 23, 227, 121, 174, 32, 3, 14, 109, 163, 162, 237, 222, 141, 35, 52, 196, 142, 119, 121]), (bytes [162, 192, 202, 183, 159, 172, 138, 151, 62, 98, 85, 9, 227, 35, 47, 254, 225, 156, 246, 62, 197, 213, 221, 21, 238, 92, 184, 77, 193, 139, 148, 39]), (bytes [30, 156, 113, 121, 45, 182, 44, 79, 80, 23, 100, 103, 103, 220, 37, 206, 19, 133, 143, 137, 36, 66, 23, 201, 184, 224, 147, 133, 121, 61, 164, 132]), (bytes [156, 238, 235, 235, 231, 56, 7, 144, 230, 102, 206, 102, 232, 250, 181, 201, 253, 212, 223, 216, 248, 101, 154, 132, 67, 141, 180, 235, 176, 0, 222, 186]), (bytes [10, 202, 130, 96, 129, 174, 239, 254, 59, 37, 168, 13, 84, 88, 60, 23, 246, 105, 129, 160, 2, 164, 141, 152, 10, 226, 104, 120, 223, 227, 147, 182]), (bytes [9, 66, 153, 238, 64, 72, 96, 76, 167, 53, 105, 235, 191, 80, 145, 191, 171, 199, 163, 209, 2, 21, 219, 193, 40, 15, 117, 44, 38, 227, 174, 82]), (bytes [53, 210, 212, 164, 155, 209, 180, 66, 35, 26, 74, 182, 180, 154, 135, 145, 137, 232, 23, 91, 107, 43, 121, 206, 253, 135, 62, 8, 176, 59, 70, 15]), (bytes [106, 103, 191, 216, 129, 70, 108, 56, 80, 28, 234, 109, 65, 95, 182, 111, 36, 14, 26, 208, 195, 175, 179, 126, 195, 123, 25, 193, 7, 72, 58, 5]), (bytes [158, 160, 91, 142, 12, 187, 225, 43, 156, 22, 68, 189, 240, 1, 88, 7, 141, 81, 210, 236, 208, 6, 71, 79, 37, 130, 163, 202, 36, 228, 89, 90]), (bytes [46, 141, 40, 223, 54, 17, 192, 49, 98, 51, 120, 151, 49, 190, 176, 227, 105, 252, 116, 226, 229, 183, 147, 50, 206, 83, 32, 121, 210, 41, 242, 19]), (bytes [231, 48, 167, 64, 215, 215, 29, 147, 80, 109, 156, 204, 135, 216, 75, 125, 111, 94, 243, 59, 187, 142, 142, 74, 214, 190, 99, 151, 155, 156, 232, 73]), (bytes [133, 46, 47, 118, 238, 252, 67, 1, 21, 108, 79, 178, 171, 204, 150, 189, 94, 42, 56, 225, 67, 208, 179, 168, 238, 177, 139, 49, 116, 118, 233, 48]), (bytes [46, 251, 78, 50, 246, 29, 89, 188, 104, 90, 229, 230, 68, 49, 70, 98, 0, 159, 143, 222, 166, 67, 222, 126, 233, 42, 212, 215, 177, 122, 245, 244]), (bytes [212, 78, 225, 26, 70, 215, 242, 159, 253, 200, 243, 164, 143, 156, 86, 194, 196, 102, 151, 234, 218, 46, 250, 223, 27, 253, 119, 88, 200, 151, 41, 209]), (bytes [182, 174, 245, 10, 243, 83, 65, 234, 45, 41, 186, 225, 212, 138, 230, 28, 172, 143, 28, 204, 202, 35, 217, 157, 45, 144, 50, 95, 139, 222, 168, 230]), (bytes [21, 77, 175, 162, 196, 200, 15, 200, 96, 52, 57, 177, 5, 199, 15, 224, 233, 131, 135, 35, 0, 74, 204, 63, 45, 38, 40, 42, 83, 165, 235, 243]), (bytes [200, 123, 150, 180, 130, 239, 77, 46, 107, 115, 96, 151, 175, 87, 196, 173, 178, 38, 203, 18, 14, 52, 71, 156, 198, 241, 154, 189, 135, 60, 150, 110]), (bytes [184, 136, 227, 97, 138, 201, 215, 114, 117, 53, 142, 36, 34, 167, 62, 209, 106, 69, 42, 232, 117, 199, 155, 239, 194, 220, 232, 182, 63, 236, 25, 97]), (bytes [22, 55, 140, 189, 108, 57, 66, 26, 133, 242, 191, 229, 238, 69, 253, 171, 74, 63, 149, 139, 162, 33, 95, 212, 14, 166, 26, 181, 169, 173, 73, 107]), (bytes [71, 235, 66, 169, 108, 11, 32, 25, 100, 8, 26, 151, 135, 70, 176, 89, 186, 60, 39, 27, 47, 251, 214, 193, 253, 123, 156, 123, 227, 7, 42, 133]), (bytes [38, 35, 109, 20, 232, 248, 173, 153, 141, 11, 184, 169, 252, 171, 163, 233, 237, 209, 48, 71, 4, 40, 151, 201, 46, 242, 122, 122, 76, 11, 111, 82]), (bytes [115, 209, 211, 165, 55, 80, 224, 206, 50, 30, 225, 178, 67, 220, 207, 144, 208, 23, 121, 128, 32, 139, 245, 153, 224, 172, 81, 199, 157, 129, 211, 234]), (bytes [118, 95, 207, 73, 175, 215, 224, 3, 14, 57, 95, 55, 64, 126, 153, 245, 171, 14, 102, 120, 48, 223, 7, 108, 134, 216, 22, 195, 42, 52, 105, 193]), (bytes [88, 173, 13, 26, 248, 14, 100, 146, 9, 13, 119, 131, 100, 96, 131, 15, 46, 36, 166, 90, 58, 117, 139, 234, 255, 203, 93, 134, 162, 52, 138, 196]), (bytes [219, 235, 162, 252, 244, 131, 57, 44, 96, 184, 103, 140, 129, 91, 68, 126, 235, 200, 120, 74, 129, 82, 219, 2, 219, 239, 106, 136, 241, 248, 4, 6]), (bytes [81, 28, 93, 93, 78, 249, 146, 159, 50, 232, 208, 43, 63, 144, 199, 21, 179, 47, 31, 243, 102, 195, 82, 239, 22, 75, 90, 82, 11, 186, 64, 183]), (bytes [178, 1, 114, 173, 184, 198, 199, 2, 65, 38, 209, 186, 236, 30, 77, 73, 178, 252, 99, 158, 156, 60, 16, 109, 47, 2, 150, 51, 182, 12, 158, 105]), (bytes [170, 253, 136, 66, 232, 134, 49, 97, 255, 124, 180, 202, 199, 107, 154, 137, 63, 179, 121, 77, 63, 183, 209, 85, 250, 46, 51, 59, 76, 216, 149, 2]), (bytes [49, 120, 127, 173, 34, 105, 205, 134, 178, 107, 240, 182, 184, 188, 174, 96, 13, 204, 69, 149, 244, 10, 15, 30, 97, 136, 83, 122, 151, 98, 204, 122]), (bytes [206, 71, 13, 21, 155, 247, 202, 63, 127, 27, 147, 48, 193, 52, 116, 125, 197, 59, 78, 254, 220, 172, 61, 227, 236, 77, 54, 242, 46, 251, 223, 109]), (bytes [42, 247, 89, 60, 176, 10, 50, 11, 210, 124, 225, 47, 203, 182, 22, 10, 69, 47, 163, 227, 61, 219, 255, 58, 27, 125, 7, 215, 15, 46, 153, 158]), (bytes [13, 4, 101, 10, 60, 237, 254, 163, 224, 43, 55, 67, 190, 96, 200, 157, 57, 12, 196, 123, 175, 252, 100, 2, 55, 183, 231, 132, 214, 148, 208, 173])], familyDigest := (bytes [21, 45, 25, 215, 138, 137, 7, 133, 215, 110, 157, 80, 190, 214, 195, 121, 158, 12, 227, 251, 45, 243, 101, 206, 199, 100, 36, 105, 152, 72, 2, 50]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [21, 45, 25, 215, 138, 137, 7, 133, 215, 110, 157, 80, 190, 214, 195, 121, 158, 12, 227, 251, 45, 243, 101, 206, 199, 100, 36, 105, 152, 72, 2, 50]), layoutVersion := 1, digest := (bytes [214, 75, 94, 215, 91, 109, 134, 19, 161, 154, 62, 207, 10, 12, 209, 67, 12, 194, 141, 59, 26, 158, 87, 80, 191, 44, 144, 250, 112, 104, 43, 29]) }, logicalIndex := 0, digest := (bytes [212, 251, 215, 182, 26, 81, 126, 18, 167, 62, 136, 137, 74, 50, 183, 244, 249, 148, 146, 115, 7, 221, 9, 25, 73, 36, 27, 98, 74, 185, 12, 250]) }, valueDigest := (bytes [195, 104, 190, 242, 104, 180, 234, 122, 108, 245, 168, 232, 122, 59, 5, 141, 148, 97, 161, 16, 201, 133, 162, 230, 49, 127, 153, 215, 226, 163, 192, 66]), digest := (bytes [229, 44, 46, 216, 109, 204, 220, 233, 58, 5, 59, 127, 77, 57, 93, 180, 92, 174, 71, 184, 220, 8, 113, 222, 241, 157, 184, 161, 240, 199, 81, 75]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [21, 45, 25, 215, 138, 137, 7, 133, 215, 110, 157, 80, 190, 214, 195, 121, 158, 12, 227, 251, 45, 243, 101, 206, 199, 100, 36, 105, 152, 72, 2, 50]), layoutVersion := 1, digest := (bytes [214, 75, 94, 215, 91, 109, 134, 19, 161, 154, 62, 207, 10, 12, 209, 67, 12, 194, 141, 59, 26, 158, 87, 80, 191, 44, 144, 250, 112, 104, 43, 29]) }, logicalIndex := 13, digest := (bytes [136, 16, 76, 149, 67, 51, 94, 206, 213, 112, 20, 104, 240, 255, 176, 60, 202, 245, 225, 21, 12, 224, 192, 247, 123, 154, 88, 4, 102, 146, 16, 136]) }, valueDigest := (bytes [228, 218, 132, 173, 40, 175, 163, 113, 77, 51, 14, 129, 172, 72, 64, 113, 166, 5, 209, 86, 65, 181, 139, 164, 241, 195, 58, 252, 148, 133, 40, 21]), digest := (bytes [35, 165, 121, 231, 139, 68, 67, 111, 41, 179, 143, 236, 33, 48, 73, 237, 21, 135, 195, 13, 104, 225, 9, 101, 64, 133, 47, 110, 7, 141, 253, 126]) }), digest := (bytes [225, 122, 202, 119, 211, 61, 230, 86, 129, 212, 18, 206, 97, 154, 229, 221, 132, 99, 162, 82, 68, 231, 230, 99, 4, 155, 163, 100, 53, 150, 253, 136]) }
  , rootLaneCommitment := { timeLen := 14, commitments := { commitmentCount := 38, digest := (bytes [219, 195, 168, 58, 246, 163, 92, 165, 69, 68, 110, 143, 93, 49, 110, 10, 179, 183, 197, 231, 89, 147, 118, 24, 213, 113, 174, 182, 139, 68, 78, 10]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [219, 195, 168, 58, 246, 163, 92, 165, 69, 68, 110, 143, 93, 49, 110, 10, 179, 183, 197, 231, 89, 147, 118, 24, 213, 113, 174, 182, 139, 68, 78, 10]), layoutVersion := 3, digest := (bytes [54, 65, 220, 157, 10, 119, 33, 155, 19, 18, 245, 163, 208, 135, 18, 19, 24, 227, 38, 183, 95, 97, 46, 170, 116, 249, 170, 121, 2, 11, 204, 182]) }, logicalIndex := 0, digest := (bytes [241, 115, 53, 60, 47, 124, 25, 29, 82, 180, 123, 91, 122, 32, 206, 112, 208, 0, 206, 191, 62, 203, 101, 97, 201, 179, 232, 144, 237, 192, 143, 121]) }, valueDigest := (bytes [195, 104, 190, 242, 104, 180, 234, 122, 108, 245, 168, 232, 122, 59, 5, 141, 148, 97, 161, 16, 201, 133, 162, 230, 49, 127, 153, 215, 226, 163, 192, 66]), digest := (bytes [89, 78, 226, 130, 74, 6, 255, 150, 236, 10, 155, 172, 163, 196, 73, 50, 37, 76, 115, 142, 113, 231, 224, 168, 209, 76, 106, 244, 171, 66, 169, 154]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [219, 195, 168, 58, 246, 163, 92, 165, 69, 68, 110, 143, 93, 49, 110, 10, 179, 183, 197, 231, 89, 147, 118, 24, 213, 113, 174, 182, 139, 68, 78, 10]), layoutVersion := 3, digest := (bytes [54, 65, 220, 157, 10, 119, 33, 155, 19, 18, 245, 163, 208, 135, 18, 19, 24, 227, 38, 183, 95, 97, 46, 170, 116, 249, 170, 121, 2, 11, 204, 182]) }, logicalIndex := 13, digest := (bytes [185, 1, 193, 126, 91, 144, 233, 178, 197, 252, 245, 92, 123, 155, 197, 155, 10, 196, 139, 217, 152, 18, 84, 207, 109, 8, 90, 93, 226, 254, 153, 106]) }, valueDigest := (bytes [228, 218, 132, 173, 40, 175, 163, 113, 77, 51, 14, 129, 172, 72, 64, 113, 166, 5, 209, 86, 65, 181, 139, 164, 241, 195, 58, 252, 148, 133, 40, 21]), digest := (bytes [100, 245, 202, 28, 32, 25, 16, 215, 85, 76, 248, 178, 234, 220, 79, 156, 168, 40, 235, 229, 37, 100, 64, 184, 15, 144, 28, 188, 217, 69, 155, 173]) }), digest := (bytes [40, 69, 56, 85, 171, 193, 21, 86, 12, 115, 250, 132, 216, 70, 194, 119, 195, 78, 79, 250, 249, 208, 33, 23, 244, 28, 33, 90, 220, 90, 136, 23]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [225, 122, 202, 119, 211, 61, 230, 86, 129, 212, 18, 206, 97, 154, 229, 221, 132, 99, 162, 82, 68, 231, 230, 99, 4, 155, 163, 100, 53, 150, 253, 136]), rootLaneCommitmentDigest := (bytes [40, 69, 56, 85, 171, 193, 21, 86, 12, 115, 250, 132, 216, 70, 194, 119, 195, 78, 79, 250, 249, 208, 33, 23, 244, 28, 33, 90, 220, 90, 136, 23]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 14, digest := (bytes [145, 180, 130, 91, 155, 62, 221, 96, 76, 78, 228, 160, 188, 5, 204, 73, 241, 89, 79, 184, 135, 187, 214, 132, 167, 18, 254, 183, 18, 158, 106, 93]) }, statementDigest := (bytes [113, 63, 31, 237, 65, 2, 87, 182, 247, 241, 197, 211, 37, 239, 137, 135, 15, 246, 76, 190, 148, 98, 253, 235, 220, 39, 237, 155, 89, 217, 142, 48]), proofDigest := (bytes [145, 41, 204, 146, 205, 253, 124, 41, 180, 135, 11, 131, 74, 35, 113, 62, 61, 146, 142, 242, 220, 107, 208, 201, 49, 33, 207, 155, 129, 118, 140, 243]), digest := (bytes [74, 129, 33, 167, 23, 241, 3, 172, 136, 8, 212, 7, 162, 100, 186, 51, 106, 184, 249, 123, 189, 184, 1, 200, 179, 172, 80, 207, 46, 93, 96, 32]) }
  , digest := (bytes [171, 71, 135, 204, 223, 232, 85, 180, 153, 205, 222, 8, 114, 1, 56, 56, 37, 137, 114, 119, 167, 24, 169, 20, 119, 90, 179, 217, 175, 147, 27, 61])
}
    , transcript := {
  appLabel := (bytes [110, 101, 111, 46, 102, 111, 108, 100, 46, 110, 101, 120, 116, 47, 114, 118, 54, 52, 105, 109, 47, 112, 97, 114, 105, 116, 121, 95, 107, 101, 114, 110, 101, 108, 95, 118, 49])
  , events := [{
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 116, 114, 97, 110, 115, 99, 114, 105, 112, 116, 95, 115, 101, 101, 100])
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 110, 97, 116, 105, 118, 101, 45, 108, 111, 103, 105, 99, 45, 99, 111, 109, 112, 97, 114, 101, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [27915927687753580, 12777915887414639, 12662, 14004900292649954342, 13728117369159879657, 11693063383591262488, 17082852510017092719, 16363809030615601355], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [110, 97, 116, 105, 118, 101, 95, 108, 111, 103, 105, 99, 95, 99, 111, 109, 112, 97, 114, 101, 95, 99, 104, 97, 105, 110, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [27915927687753580, 12777915887414639, 12662, 14004900292649954342, 13728117369159879657, 11693063383591262488, 17082852510017092719, 16363809030615601355], absorbed := 3 }
  , cursorAfter := { stateWords := [28533900466808931, 1819042147, 14675078370321938727, 4574521486179947848, 5924462245161849131, 2698773299494092040, 9075337403133714940, 4191472899665087393], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [5243027, 3146003, 2159027, 6353427, 2155187, 8479507, 2147251, 7390227, 1123507, 4269331, 1127859, 4240915, 15, 115]
  , cursorBefore := { stateWords := [28533900466808931, 1819042147, 14675078370321938727, 4574521486179947848, 5924462245161849131, 2698773299494092040, 9075337403133714940, 4191472899665087393], absorbed := 2 }
  , cursorAfter := { stateWords := [3276447219741767340, 13078479345119520091, 12592238531974894527, 6748780606875837271, 4492818906924154559, 11103094219351273320, 3262392760021944179, 1928312561396356522], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [3276447219741767340, 13078479345119520091, 12592238531974894527, 6748780606875837271, 4492818906924154559, 11103094219351273320, 3262392760021944179, 1928312561396356522], absorbed := 0 }
  , cursorAfter := { stateWords := [0, 0, 10459399774905745288, 8328946169001223494, 5691556989607583735, 14974589011629786926, 738872076179659364, 16017586578460096676], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [0, 0, 10459399774905745288, 8328946169001223494, 5691556989607583735, 14974589011629786926, 738872076179659364, 16017586578460096676], absorbed := 2 }
  , cursorAfter := { stateWords := [13348506805888363, 30506403037277801, 34184295084289375, 0, 12756469965976968519, 2744792860478371236, 17860809758803000662, 15715310416387930124], absorbed := 4 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [160, 47, 136, 108, 204, 129, 79, 197, 229, 103, 193, 132, 46, 237, 116, 161, 76, 12, 119, 193, 191, 6, 227, 119, 236, 118, 88, 172, 48, 50, 35, 98])
  , u64s := []
  , cursorBefore := { stateWords := [13348506805888363, 30506403037277801, 34184295084289375, 0, 12756469965976968519, 2744792860478371236, 17860809758803000662, 15715310416387930124], absorbed := 4 }
  , cursorAfter := { stateWords := [53974437603352948, 48510963790897926, 1646473776, 13300600973611324196, 7380724067355609945, 9565502279824397969, 15874006747358156928, 15902665604271536949], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [53974437603352948, 48510963790897926, 1646473776, 13300600973611324196, 7380724067355609945, 9565502279824397969, 15874006747358156928, 15902665604271536949], absorbed := 3 }
  , cursorAfter := { stateWords := [3705222010059132808, 10705559429118986591, 1156729734218909101, 8423534567024735570, 9095578176136919767, 13676969085484049303, 1580895861586138354, 2032458426184116188], absorbed := 0 }
  , challengeOutput := (some 3705222010059132808)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [64, 180, 146, 246, 139, 60, 76, 212, 49, 131, 207, 237, 101, 254, 127, 102, 212, 72, 236, 89, 205, 253, 188, 71, 14, 72, 168, 245, 217, 88, 55, 93])
  , u64s := []
  , cursorBefore := { stateWords := [3705222010059132808, 10705559429118986591, 1156729734218909101, 8423534567024735570, 9095578176136919767, 13676969085484049303, 1580895861586138354, 2032458426184116188], absorbed := 0 }
  , cursorAfter := { stateWords := [57801241594717823, 69146396724804861, 1563908313, 15717703205190525445, 6907845539242118593, 14017363633327132095, 8563616863401045740, 7187696116192749015], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [57801241594717823, 69146396724804861, 1563908313, 15717703205190525445, 6907845539242118593, 14017363633327132095, 8563616863401045740, 7187696116192749015], absorbed := 3 }
  , cursorAfter := { stateWords := [7940266179000280847, 17128601962132279149, 1049842007288689975, 9265992555679375098, 10336381086471234629, 9918544998845487875, 2119026821034374262, 15723449175245520992], absorbed := 0 }
  , challengeOutput := (some 7940266179000280847)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [7940266179000280847, 17128601962132279149, 1049842007288689975, 9265992555679375098, 10336381086471234629, 9918544998845487875, 2119026821034374262, 15723449175245520992], absorbed := 0 }
  , cursorAfter := { stateWords := [4123130262336711476, 14111673298204184757, 5156360653013349129, 11211280577908904830, 803754858751632307, 5691479114664987180, 17877381527979292013, 14816230815792099199], absorbed := 0 }
  , challengeOutput := (some 4123130262336711476)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [52, 185, 8, 160, 143, 178, 154, 190, 101, 228, 204, 246, 221, 136, 74, 154, 136, 97, 99, 235, 127, 33, 115, 45, 30, 159, 243, 89, 15, 247, 157, 142])
  , u64s := []
  , cursorBefore := { stateWords := [4123130262336711476, 14111673298204184757, 5156360653013349129, 11211280577908904830, 803754858751632307, 5691479114664987180, 17877381527979292013, 14816230815792099199], absorbed := 0 }
  , cursorAfter := { stateWords := [36006134112885322, 25319137658893089, 2392717071, 18249389629117730808, 12336873607744378464, 14852699958375720157, 7400218705089070248, 6850034240698606523], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [36006134112885322, 25319137658893089, 2392717071, 18249389629117730808, 12336873607744378464, 14852699958375720157, 7400218705089070248, 6850034240698606523], absorbed := 3 }
  , cursorAfter := { stateWords := [13522001880879900227, 2076012353615447445, 6283777378358488802, 6397285422002702166, 22029644498711621, 8946322245240676634, 14425569364995812978, 10554284728068128014], absorbed := 0 }
  , challengeOutput := (some 13522001880879900227)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [84, 58, 119, 62, 227, 203, 157, 120, 91, 33, 164, 86, 114, 27, 21, 233, 168, 252, 76, 12, 100, 202, 132, 82, 6, 21, 143, 29, 61, 32, 51, 38])
  , u64s := []
  , cursorBefore := { stateWords := [13522001880879900227, 2076012353615447445, 6283777378358488802, 6397285422002702166, 22029644498711621, 8946322245240676634, 14425569364995812978, 10554284728068128014], absorbed := 0 }
  , cursorAfter := { stateWords := [28161022467041557, 8320094787765450, 640884797, 10688822229477720999, 2298505535517364726, 9010554323198895477, 13396947121714209208, 18289360312464286512], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [160, 227, 4, 85, 140, 249, 7, 83, 176, 183, 120, 10, 187, 25, 9, 75, 146, 246, 100, 53, 9, 137, 26, 48, 91, 20, 9, 143, 92, 16, 180, 9])
  , u64s := []
  , cursorBefore := { stateWords := [28161022467041557, 8320094787765450, 640884797, 10688822229477720999, 2298505535517364726, 9010554323198895477, 13396947121714209208, 18289360312464286512], absorbed := 3 }
  , cursorAfter := { stateWords := [2591982540180233, 40260904703498889, 162795612, 11106092458926729985, 9843439728162203894, 4910876821339919711, 11743588247353110963, 16917990617748735295], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [67, 56, 221, 172, 183, 26, 231, 188, 189, 215, 247, 181, 112, 58, 232, 221, 188, 253, 63, 175, 15, 72, 182, 206, 231, 128, 239, 141, 249, 6, 198, 30])
  , u64s := []
  , cursorBefore := { stateWords := [2591982540180233, 40260904703498889, 162795612, 11106092458926729985, 9843439728162203894, 4910876821339919711, 11743588247353110963, 16917990617748735295], absorbed := 3 }
  , cursorAfter := { stateWords := [4414814025473512, 39951308640138824, 516294393, 17329624708618471016, 11674115816566501362, 14573575530215518718, 13139643552008840516, 17641270940026343217], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [4414814025473512, 39951308640138824, 516294393, 17329624708618471016, 11674115816566501362, 14573575530215518718, 13139643552008840516, 17641270940026343217], absorbed := 3 }
  , cursorAfter := { stateWords := [5710450369200423292, 5740143068072469614, 14894183229893626147, 9172001311057965075, 14492336027424921441, 885359618247772967, 13488484757209203575, 3843872230801825639], absorbed := 0 }
  , challengeOutput := (some 5710450369200423292)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [5710450369200423292, 5740143068072469614, 14894183229893626147, 9172001311057965075, 14492336027424921441, 885359618247772967, 13488484757209203575, 3843872230801825639], absorbed := 0 }
  , cursorAfter := { stateWords := [4225525998307615487, 11432035185072164917, 12583554745970507727, 13626737198406591408, 6094816200342946977, 10179070456341347142, 1214732117107862240, 4980023762376192327], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [255, 162, 77, 246, 129, 21, 164, 58, 53, 80, 254, 105, 110, 191, 166, 158, 207, 191, 64, 245, 94, 196, 161, 174, 176, 99, 160, 206, 72, 229, 27, 189]))
}]
}
    , stage1 := stage1
    , stage2 := stage2
    , stage3 := stage3
    , rootExecution := rootExecution
    , stepComposition := stepComposition
    , soundnessAccounting := soundnessAccounting
    , kernelOpeningBundle := kernelOpeningBundle
    , digest := (bytes [202, 65, 129, 179, 39, 0, 29, 67, 252, 174, 39, 115, 5, 97, 91, 149, 157, 176, 50, 121, 203, 171, 53, 68, 2, 65, 8, 70, 197, 162, 216, 221])
  }

end Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors.Case_native_logic_compare_chain_ecall
