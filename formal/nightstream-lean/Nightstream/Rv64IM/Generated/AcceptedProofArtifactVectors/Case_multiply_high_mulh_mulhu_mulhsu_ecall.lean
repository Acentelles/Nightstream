import Nightstream.Rv64IM.Generated.AcceptedProofArtifactTypes

set_option maxHeartbeats 0
set_option maxRecDepth 65536

namespace Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors.Case_multiply_high_mulh_mulhu_mulhsu_ecall

open Nightstream.Rv64IM.Generated

def stage1SemInputs : List SemInView :=
  [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, pc := 0, opcode := .mulh, traceOpcode := none, traceVirtualOpcode := (some .movsign), family := .multiply, archRs1 := 1, archRs1Value := 18446744073709551614, archRs2 := 2, archRs2Value := 18446744073709551613, archRd := 7, archRdBefore := 0, archImm := 0, rs1 := 1, rs1Value := 18446744073709551614, rs2 := 0, rs2Value := 0, rd := 40, rdBefore := 0, rdAfter := 18446744073709551615, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := (some 6), isEffectRow := false, isCommitRow := false, isReal := false }, { traceIndex := 1, stepIndex := 0, sequenceIndex := 1, pc := 0, opcode := .mulh, traceOpcode := none, traceVirtualOpcode := (some .movsign), family := .multiply, archRs1 := 1, archRs1Value := 18446744073709551614, archRs2 := 2, archRs2Value := 18446744073709551613, archRd := 7, archRdBefore := 0, archImm := 0, rs1 := 2, rs1Value := 18446744073709551613, rs2 := 0, rs2Value := 0, rd := 41, rdBefore := 0, rdAfter := 18446744073709551615, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 5), isEffectRow := false, isCommitRow := false, isReal := false }, { traceIndex := 2, stepIndex := 0, sequenceIndex := 2, pc := 0, opcode := .mulh, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .multiply, archRs1 := 1, archRs1Value := 18446744073709551614, archRs2 := 2, archRs2Value := 18446744073709551613, archRd := 7, archRdBefore := 0, archImm := 0, rs1 := 40, rs1Value := 18446744073709551615, rs2 := 2, rs2Value := 18446744073709551613, rd := 40, rdBefore := 18446744073709551615, rdAfter := 3, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 4), isEffectRow := false, isCommitRow := false, isReal := false }, { traceIndex := 3, stepIndex := 0, sequenceIndex := 3, pc := 0, opcode := .mulh, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .multiply, archRs1 := 1, archRs1Value := 18446744073709551614, archRs2 := 2, archRs2Value := 18446744073709551613, archRd := 7, archRdBefore := 0, archImm := 0, rs1 := 41, rs1Value := 18446744073709551615, rs2 := 1, rs2Value := 18446744073709551614, rd := 41, rdBefore := 18446744073709551615, rdAfter := 2, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 3), isEffectRow := false, isCommitRow := false, isReal := false }, { traceIndex := 4, stepIndex := 0, sequenceIndex := 4, pc := 0, opcode := .mulh, traceOpcode := (some .mulhu), traceVirtualOpcode := none, family := .multiply, archRs1 := 1, archRs1Value := 18446744073709551614, archRs2 := 2, archRs2Value := 18446744073709551613, archRd := 7, archRdBefore := 0, archImm := 0, rs1 := 1, rs1Value := 18446744073709551614, rs2 := 2, rs2Value := 18446744073709551613, rd := 42, rdBefore := 0, rdAfter := 18446744073709551611, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 2), isEffectRow := false, isCommitRow := false, isReal := false }, { traceIndex := 5, stepIndex := 0, sequenceIndex := 5, pc := 0, opcode := .mulh, traceOpcode := (some .add), traceVirtualOpcode := none, family := .multiply, archRs1 := 1, archRs1Value := 18446744073709551614, archRs2 := 2, archRs2Value := 18446744073709551613, archRd := 7, archRdBefore := 0, archImm := 0, rs1 := 42, rs1Value := 18446744073709551611, rs2 := 40, rs2Value := 3, rd := 42, rdBefore := 18446744073709551611, rdAfter := 18446744073709551614, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 1), isEffectRow := false, isCommitRow := false, isReal := false }, { traceIndex := 6, stepIndex := 0, sequenceIndex := 6, pc := 0, opcode := .mulh, traceOpcode := (some .add), traceVirtualOpcode := none, family := .multiply, archRs1 := 1, archRs1Value := 18446744073709551614, archRs2 := 2, archRs2Value := 18446744073709551613, archRd := 7, archRdBefore := 0, archImm := 0, rs1 := 42, rs1Value := 18446744073709551614, rs2 := 41, rs2Value := 2, rd := 7, rdBefore := 0, rdAfter := 0, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 0), isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 7, stepIndex := 1, sequenceIndex := 0, pc := 4, opcode := .mulhu, traceOpcode := (some .mulhu), traceVirtualOpcode := none, family := .multiply, archRs1 := 3, archRs1Value := 18446744073709551614, archRs2 := 4, archRs2Value := 3, archRd := 8, archRdBefore := 0, archImm := 0, rs1 := 3, rs1Value := 18446744073709551614, rs2 := 4, rs2Value := 3, rd := 8, rdBefore := 0, rdAfter := 2, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 8, stepIndex := 2, sequenceIndex := 0, pc := 8, opcode := .mulhsu, traceOpcode := none, traceVirtualOpcode := (some .movsign), family := .multiply, archRs1 := 5, archRs1Value := 18446744073709551614, archRs2 := 6, archRs2Value := 3, archRd := 9, archRdBefore := 0, archImm := 0, rs1 := 5, rs1Value := 18446744073709551614, rs2 := 0, rs2Value := 0, rd := 40, rdBefore := 0, rdAfter := 18446744073709551615, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := (some 10), isEffectRow := false, isCommitRow := false, isReal := false }, { traceIndex := 9, stepIndex := 2, sequenceIndex := 1, pc := 8, opcode := .mulhsu, traceOpcode := (some .andi), traceVirtualOpcode := none, family := .multiply, archRs1 := 5, archRs1Value := 18446744073709551614, archRs2 := 6, archRs2Value := 3, archRd := 9, archRdBefore := 0, archImm := 0, rs1 := 40, rs1Value := 18446744073709551615, rs2 := 0, rs2Value := 0, rd := 41, rdBefore := 0, rdAfter := 1, imm := 1, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 9), isEffectRow := false, isCommitRow := false, isReal := false }, { traceIndex := 10, stepIndex := 2, sequenceIndex := 2, pc := 8, opcode := .mulhsu, traceOpcode := (some .xor), traceVirtualOpcode := none, family := .multiply, archRs1 := 5, archRs1Value := 18446744073709551614, archRs2 := 6, archRs2Value := 3, archRd := 9, archRdBefore := 0, archImm := 0, rs1 := 5, rs1Value := 18446744073709551614, rs2 := 40, rs2Value := 18446744073709551615, rd := 42, rdBefore := 0, rdAfter := 1, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 8), isEffectRow := false, isCommitRow := false, isReal := false }, { traceIndex := 11, stepIndex := 2, sequenceIndex := 3, pc := 8, opcode := .mulhsu, traceOpcode := (some .add), traceVirtualOpcode := none, family := .multiply, archRs1 := 5, archRs1Value := 18446744073709551614, archRs2 := 6, archRs2Value := 3, archRd := 9, archRdBefore := 0, archImm := 0, rs1 := 42, rs1Value := 1, rs2 := 41, rs2Value := 1, rd := 42, rdBefore := 1, rdAfter := 2, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 7), isEffectRow := false, isCommitRow := false, isReal := false }, { traceIndex := 12, stepIndex := 2, sequenceIndex := 4, pc := 8, opcode := .mulhsu, traceOpcode := (some .mulhu), traceVirtualOpcode := none, family := .multiply, archRs1 := 5, archRs1Value := 18446744073709551614, archRs2 := 6, archRs2Value := 3, archRd := 9, archRdBefore := 0, archImm := 0, rs1 := 42, rs1Value := 2, rs2 := 6, rs2Value := 3, rd := 43, rdBefore := 0, rdAfter := 0, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 6), isEffectRow := false, isCommitRow := false, isReal := false }, { traceIndex := 13, stepIndex := 2, sequenceIndex := 5, pc := 8, opcode := .mulhsu, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .multiply, archRs1 := 5, archRs1Value := 18446744073709551614, archRs2 := 6, archRs2Value := 3, archRd := 9, archRdBefore := 0, archImm := 0, rs1 := 42, rs1Value := 2, rs2 := 6, rs2Value := 3, rd := 42, rdBefore := 2, rdAfter := 6, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 5), isEffectRow := false, isCommitRow := false, isReal := false }, { traceIndex := 14, stepIndex := 2, sequenceIndex := 6, pc := 8, opcode := .mulhsu, traceOpcode := (some .xor), traceVirtualOpcode := none, family := .multiply, archRs1 := 5, archRs1Value := 18446744073709551614, archRs2 := 6, archRs2Value := 3, archRd := 9, archRdBefore := 0, archImm := 0, rs1 := 43, rs1Value := 0, rs2 := 40, rs2Value := 18446744073709551615, rd := 43, rdBefore := 0, rdAfter := 18446744073709551615, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 4), isEffectRow := false, isCommitRow := false, isReal := false }, { traceIndex := 15, stepIndex := 2, sequenceIndex := 7, pc := 8, opcode := .mulhsu, traceOpcode := (some .xor), traceVirtualOpcode := none, family := .multiply, archRs1 := 5, archRs1Value := 18446744073709551614, archRs2 := 6, archRs2Value := 3, archRd := 9, archRdBefore := 0, archImm := 0, rs1 := 42, rs1Value := 6, rs2 := 40, rs2Value := 18446744073709551615, rd := 42, rdBefore := 6, rdAfter := 18446744073709551609, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 3), isEffectRow := false, isCommitRow := false, isReal := false }, { traceIndex := 16, stepIndex := 2, sequenceIndex := 8, pc := 8, opcode := .mulhsu, traceOpcode := (some .add), traceVirtualOpcode := none, family := .multiply, archRs1 := 5, archRs1Value := 18446744073709551614, archRs2 := 6, archRs2Value := 3, archRd := 9, archRdBefore := 0, archImm := 0, rs1 := 42, rs1Value := 18446744073709551609, rs2 := 41, rs2Value := 1, rd := 40, rdBefore := 18446744073709551615, rdAfter := 18446744073709551610, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 2), isEffectRow := false, isCommitRow := false, isReal := false }, { traceIndex := 17, stepIndex := 2, sequenceIndex := 9, pc := 8, opcode := .mulhsu, traceOpcode := (some .sltu), traceVirtualOpcode := none, family := .multiply, archRs1 := 5, archRs1Value := 18446744073709551614, archRs2 := 6, archRs2Value := 3, archRd := 9, archRdBefore := 0, archImm := 0, rs1 := 40, rs1Value := 18446744073709551610, rs2 := 42, rs2Value := 18446744073709551609, rd := 40, rdBefore := 18446744073709551610, rdAfter := 0, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 1), isEffectRow := false, isCommitRow := false, isReal := false }, { traceIndex := 18, stepIndex := 2, sequenceIndex := 10, pc := 8, opcode := .mulhsu, traceOpcode := (some .add), traceVirtualOpcode := none, family := .multiply, archRs1 := 5, archRs1Value := 18446744073709551614, archRs2 := 6, archRs2Value := 3, archRd := 9, archRdBefore := 0, archImm := 0, rs1 := 43, rs1Value := 18446744073709551615, rs2 := 40, rs2Value := 0, rd := 9, rdBefore := 0, rdAfter := 18446744073709551615, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 0), isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 19, stepIndex := 3, sequenceIndex := 0, pc := 12, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 0, archRdBefore := 0, archImm := 0, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 0, rdBefore := 0, rdAfter := 0, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := false, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }]

def stage1RowBindings : List Stage1RowBindingView :=
  [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 35689395, opcode := .mulh, traceOpcode := none, traceVirtualOpcode := (some .movsign), family := .multiply, nextPc := 0, aluResult := 18446744073709551615, effectiveAddr := none, writesRd := true, rd := 40, rdAfter := 18446744073709551615, isFirstInSequence := true, virtualSequenceRemaining := (some 6), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 1, stepIndex := 0, sequenceIndex := 1, fetchPc := 0, fetchedWord := 35689395, opcode := .mulh, traceOpcode := none, traceVirtualOpcode := (some .movsign), family := .multiply, nextPc := 0, aluResult := 18446744073709551615, effectiveAddr := none, writesRd := true, rd := 41, rdAfter := 18446744073709551615, isFirstInSequence := false, virtualSequenceRemaining := (some 5), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 2, stepIndex := 0, sequenceIndex := 2, fetchPc := 0, fetchedWord := 35689395, opcode := .mulh, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .multiply, nextPc := 0, aluResult := 3, effectiveAddr := none, writesRd := true, rd := 40, rdAfter := 3, isFirstInSequence := false, virtualSequenceRemaining := (some 4), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 3, stepIndex := 0, sequenceIndex := 3, fetchPc := 0, fetchedWord := 35689395, opcode := .mulh, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .multiply, nextPc := 0, aluResult := 2, effectiveAddr := none, writesRd := true, rd := 41, rdAfter := 2, isFirstInSequence := false, virtualSequenceRemaining := (some 3), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 4, stepIndex := 0, sequenceIndex := 4, fetchPc := 0, fetchedWord := 35689395, opcode := .mulh, traceOpcode := (some .mulhu), traceVirtualOpcode := none, family := .multiply, nextPc := 0, aluResult := 18446744073709551611, effectiveAddr := none, writesRd := true, rd := 42, rdAfter := 18446744073709551611, isFirstInSequence := false, virtualSequenceRemaining := (some 2), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 5, stepIndex := 0, sequenceIndex := 5, fetchPc := 0, fetchedWord := 35689395, opcode := .mulh, traceOpcode := (some .add), traceVirtualOpcode := none, family := .multiply, nextPc := 0, aluResult := 18446744073709551614, effectiveAddr := none, writesRd := true, rd := 42, rdAfter := 18446744073709551614, isFirstInSequence := false, virtualSequenceRemaining := (some 1), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 6, stepIndex := 0, sequenceIndex := 6, fetchPc := 0, fetchedWord := 35689395, opcode := .mulh, traceOpcode := (some .add), traceVirtualOpcode := none, family := .multiply, nextPc := 4, aluResult := 0, effectiveAddr := none, writesRd := true, rd := 7, rdAfter := 0, isFirstInSequence := false, virtualSequenceRemaining := (some 0), isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 7, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 37860403, opcode := .mulhu, traceOpcode := (some .mulhu), traceVirtualOpcode := none, family := .multiply, nextPc := 8, aluResult := 2, effectiveAddr := none, writesRd := true, rd := 8, rdAfter := 2, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 8, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 40019123, opcode := .mulhsu, traceOpcode := none, traceVirtualOpcode := (some .movsign), family := .multiply, nextPc := 8, aluResult := 18446744073709551615, effectiveAddr := none, writesRd := true, rd := 40, rdAfter := 18446744073709551615, isFirstInSequence := true, virtualSequenceRemaining := (some 10), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 9, stepIndex := 2, sequenceIndex := 1, fetchPc := 8, fetchedWord := 40019123, opcode := .mulhsu, traceOpcode := (some .andi), traceVirtualOpcode := none, family := .multiply, nextPc := 8, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 41, rdAfter := 1, isFirstInSequence := false, virtualSequenceRemaining := (some 9), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 10, stepIndex := 2, sequenceIndex := 2, fetchPc := 8, fetchedWord := 40019123, opcode := .mulhsu, traceOpcode := (some .xor), traceVirtualOpcode := none, family := .multiply, nextPc := 8, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 42, rdAfter := 1, isFirstInSequence := false, virtualSequenceRemaining := (some 8), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 11, stepIndex := 2, sequenceIndex := 3, fetchPc := 8, fetchedWord := 40019123, opcode := .mulhsu, traceOpcode := (some .add), traceVirtualOpcode := none, family := .multiply, nextPc := 8, aluResult := 2, effectiveAddr := none, writesRd := true, rd := 42, rdAfter := 2, isFirstInSequence := false, virtualSequenceRemaining := (some 7), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 12, stepIndex := 2, sequenceIndex := 4, fetchPc := 8, fetchedWord := 40019123, opcode := .mulhsu, traceOpcode := (some .mulhu), traceVirtualOpcode := none, family := .multiply, nextPc := 8, aluResult := 0, effectiveAddr := none, writesRd := true, rd := 43, rdAfter := 0, isFirstInSequence := false, virtualSequenceRemaining := (some 6), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 13, stepIndex := 2, sequenceIndex := 5, fetchPc := 8, fetchedWord := 40019123, opcode := .mulhsu, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .multiply, nextPc := 8, aluResult := 6, effectiveAddr := none, writesRd := true, rd := 42, rdAfter := 6, isFirstInSequence := false, virtualSequenceRemaining := (some 5), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 14, stepIndex := 2, sequenceIndex := 6, fetchPc := 8, fetchedWord := 40019123, opcode := .mulhsu, traceOpcode := (some .xor), traceVirtualOpcode := none, family := .multiply, nextPc := 8, aluResult := 18446744073709551615, effectiveAddr := none, writesRd := true, rd := 43, rdAfter := 18446744073709551615, isFirstInSequence := false, virtualSequenceRemaining := (some 4), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 15, stepIndex := 2, sequenceIndex := 7, fetchPc := 8, fetchedWord := 40019123, opcode := .mulhsu, traceOpcode := (some .xor), traceVirtualOpcode := none, family := .multiply, nextPc := 8, aluResult := 18446744073709551609, effectiveAddr := none, writesRd := true, rd := 42, rdAfter := 18446744073709551609, isFirstInSequence := false, virtualSequenceRemaining := (some 3), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 16, stepIndex := 2, sequenceIndex := 8, fetchPc := 8, fetchedWord := 40019123, opcode := .mulhsu, traceOpcode := (some .add), traceVirtualOpcode := none, family := .multiply, nextPc := 8, aluResult := 18446744073709551610, effectiveAddr := none, writesRd := true, rd := 40, rdAfter := 18446744073709551610, isFirstInSequence := false, virtualSequenceRemaining := (some 2), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 17, stepIndex := 2, sequenceIndex := 9, fetchPc := 8, fetchedWord := 40019123, opcode := .mulhsu, traceOpcode := (some .sltu), traceVirtualOpcode := none, family := .multiply, nextPc := 8, aluResult := 0, effectiveAddr := none, writesRd := true, rd := 40, rdAfter := 0, isFirstInSequence := false, virtualSequenceRemaining := (some 1), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 18, stepIndex := 2, sequenceIndex := 10, fetchPc := 8, fetchedWord := 40019123, opcode := .mulhsu, traceOpcode := (some .add), traceVirtualOpcode := none, family := .multiply, nextPc := 12, aluResult := 18446744073709551615, effectiveAddr := none, writesRd := true, rd := 9, rdAfter := 18446744073709551615, isFirstInSequence := false, virtualSequenceRemaining := (some 0), isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 19, stepIndex := 3, sequenceIndex := 0, fetchPc := 12, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 16, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }]

def stage1 : Stage1ProofBundleView :=
  {
    semInputs := stage1SemInputs
    , rowBindings := stage1RowBindings
    , bytecodeDigest := (bytes [239, 180, 238, 231, 247, 144, 156, 87, 108, 179, 121, 195, 42, 43, 68, 82, 36, 104, 9, 188, 175, 84, 72, 101, 36, 1, 179, 28, 166, 60, 214, 183])
    , aluDigest := (bytes [165, 25, 2, 135, 158, 213, 215, 186, 66, 32, 128, 185, 246, 135, 80, 14, 200, 232, 141, 218, 155, 244, 157, 163, 27, 35, 197, 40, 210, 175, 107, 48])
    , branchDigest := (bytes [93, 141, 99, 210, 208, 189, 190, 34, 141, 242, 171, 0, 145, 229, 71, 230, 147, 15, 107, 255, 24, 236, 39, 20, 98, 145, 244, 140, 14, 24, 200, 154])
    , semantics := { semInputsDigest := (bytes [246, 238, 13, 231, 30, 174, 219, 108, 97, 75, 192, 133, 58, 198, 33, 201, 228, 160, 188, 142, 81, 179, 229, 192, 141, 106, 71, 242, 255, 208, 119, 168]), rowBindingsDigest := (bytes [18, 19, 231, 171, 196, 155, 122, 122, 226, 6, 104, 219, 164, 14, 91, 188, 106, 57, 126, 117, 145, 183, 5, 144, 80, 42, 228, 4, 80, 100, 87, 61]), sequenceCount := 4, helperRowCount := 16, digest := (bytes [59, 96, 220, 72, 75, 13, 241, 70, 83, 180, 7, 194, 187, 76, 194, 181, 152, 15, 191, 203, 85, 30, 80, 21, 133, 20, 133, 163, 171, 95, 223, 241]) }
    , addressCorrectnessDigest := (bytes [90, 232, 218, 184, 159, 55, 201, 61, 25, 68, 137, 169, 203, 37, 68, 49, 155, 248, 42, 41, 15, 20, 129, 141, 113, 195, 82, 203, 207, 248, 209, 255])
    , linkageDigest := (bytes [211, 126, 36, 252, 76, 149, 195, 200, 143, 155, 103, 235, 8, 11, 7, 188, 33, 64, 191, 19, 29, 110, 93, 113, 99, 50, 130, 71, 43, 254, 150, 194])
    , selectedOpening := { claim := { rowsFamilyDigest := (bytes [18, 19, 231, 171, 196, 155, 122, 122, 226, 6, 104, 219, 164, 14, 91, 188, 106, 57, 126, 117, 145, 183, 5, 144, 80, 42, 228, 4, 80, 100, 87, 61]), rowCount := 20, effectRowCount := 4, commitRowCount := 4, realRowCount := 4, preservesX0Count := 1, firstTraceIndex := 0, effectTraceIndex := 6, commitTraceIndex := 6, lastTraceIndex := 19, mix := 12594224946114062434, points := { first := { id := { object := { familyTag := 1, commitmentDigest := (bytes [18, 19, 231, 171, 196, 155, 122, 122, 226, 6, 104, 219, 164, 14, 91, 188, 106, 57, 126, 117, 145, 183, 5, 144, 80, 42, 228, 4, 80, 100, 87, 61]), layoutVersion := 1, digest := (bytes [72, 80, 149, 171, 40, 202, 94, 18, 162, 97, 25, 95, 238, 103, 58, 22, 157, 164, 221, 22, 21, 152, 75, 54, 62, 124, 188, 157, 131, 118, 205, 251]) }, logicalIndex := 0, digest := (bytes [246, 63, 93, 76, 119, 138, 225, 44, 163, 101, 155, 230, 247, 235, 26, 123, 75, 81, 198, 227, 187, 139, 151, 225, 130, 173, 184, 82, 200, 143, 234, 104]) }, valueDigest := (bytes [83, 120, 171, 238, 51, 232, 103, 160, 58, 181, 216, 18, 202, 144, 95, 36, 107, 8, 101, 162, 26, 119, 204, 18, 119, 172, 214, 138, 50, 194, 126, 224]), digest := (bytes [166, 61, 68, 5, 111, 104, 251, 122, 197, 102, 11, 16, 199, 191, 47, 74, 67, 62, 139, 133, 253, 245, 252, 175, 206, 137, 222, 95, 194, 168, 197, 66]) }, effect := { id := { object := { familyTag := 1, commitmentDigest := (bytes [18, 19, 231, 171, 196, 155, 122, 122, 226, 6, 104, 219, 164, 14, 91, 188, 106, 57, 126, 117, 145, 183, 5, 144, 80, 42, 228, 4, 80, 100, 87, 61]), layoutVersion := 1, digest := (bytes [72, 80, 149, 171, 40, 202, 94, 18, 162, 97, 25, 95, 238, 103, 58, 22, 157, 164, 221, 22, 21, 152, 75, 54, 62, 124, 188, 157, 131, 118, 205, 251]) }, logicalIndex := 6, digest := (bytes [79, 233, 69, 220, 167, 227, 203, 30, 218, 225, 227, 32, 136, 105, 17, 18, 24, 36, 14, 21, 19, 68, 220, 9, 45, 99, 198, 172, 67, 232, 126, 137]) }, valueDigest := (bytes [206, 146, 106, 81, 193, 248, 190, 205, 89, 37, 28, 149, 102, 143, 185, 158, 105, 122, 216, 185, 83, 112, 54, 173, 149, 23, 168, 16, 247, 34, 87, 26]), digest := (bytes [78, 191, 69, 230, 248, 213, 21, 131, 173, 20, 83, 250, 57, 31, 22, 111, 103, 30, 54, 125, 82, 213, 95, 185, 49, 227, 214, 136, 13, 242, 9, 246]) }, commit := { id := { object := { familyTag := 1, commitmentDigest := (bytes [18, 19, 231, 171, 196, 155, 122, 122, 226, 6, 104, 219, 164, 14, 91, 188, 106, 57, 126, 117, 145, 183, 5, 144, 80, 42, 228, 4, 80, 100, 87, 61]), layoutVersion := 1, digest := (bytes [72, 80, 149, 171, 40, 202, 94, 18, 162, 97, 25, 95, 238, 103, 58, 22, 157, 164, 221, 22, 21, 152, 75, 54, 62, 124, 188, 157, 131, 118, 205, 251]) }, logicalIndex := 6, digest := (bytes [79, 233, 69, 220, 167, 227, 203, 30, 218, 225, 227, 32, 136, 105, 17, 18, 24, 36, 14, 21, 19, 68, 220, 9, 45, 99, 198, 172, 67, 232, 126, 137]) }, valueDigest := (bytes [206, 146, 106, 81, 193, 248, 190, 205, 89, 37, 28, 149, 102, 143, 185, 158, 105, 122, 216, 185, 83, 112, 54, 173, 149, 23, 168, 16, 247, 34, 87, 26]), digest := (bytes [78, 191, 69, 230, 248, 213, 21, 131, 173, 20, 83, 250, 57, 31, 22, 111, 103, 30, 54, 125, 82, 213, 95, 185, 49, 227, 214, 136, 13, 242, 9, 246]) }, last := { id := { object := { familyTag := 1, commitmentDigest := (bytes [18, 19, 231, 171, 196, 155, 122, 122, 226, 6, 104, 219, 164, 14, 91, 188, 106, 57, 126, 117, 145, 183, 5, 144, 80, 42, 228, 4, 80, 100, 87, 61]), layoutVersion := 1, digest := (bytes [72, 80, 149, 171, 40, 202, 94, 18, 162, 97, 25, 95, 238, 103, 58, 22, 157, 164, 221, 22, 21, 152, 75, 54, 62, 124, 188, 157, 131, 118, 205, 251]) }, logicalIndex := 19, digest := (bytes [28, 83, 64, 229, 91, 215, 242, 55, 71, 255, 93, 189, 204, 205, 243, 130, 209, 159, 241, 229, 14, 16, 180, 19, 230, 169, 216, 109, 58, 93, 120, 16]) }, valueDigest := (bytes [253, 35, 104, 203, 4, 132, 11, 229, 235, 176, 56, 133, 174, 7, 164, 188, 104, 97, 29, 44, 72, 218, 34, 127, 228, 100, 167, 160, 222, 194, 189, 145]), digest := (bytes [47, 242, 211, 174, 3, 47, 56, 91, 214, 18, 23, 105, 106, 104, 96, 188, 113, 234, 19, 193, 172, 213, 83, 126, 39, 131, 164, 0, 201, 122, 143, 220]) } }, digest := (bytes [168, 154, 148, 145, 9, 50, 70, 215, 240, 4, 131, 107, 88, 103, 167, 3, 231, 102, 100, 242, 33, 236, 184, 222, 78, 107, 216, 170, 80, 78, 23, 203]) }, packaged := { statementDigest := (bytes [144, 117, 107, 184, 69, 217, 52, 178, 51, 42, 252, 203, 144, 143, 23, 151, 30, 99, 48, 58, 10, 244, 35, 205, 83, 80, 229, 208, 183, 194, 80, 22]), proofDigest := (bytes [4, 140, 239, 14, 240, 246, 233, 72, 6, 48, 7, 69, 2, 50, 45, 100, 53, 158, 204, 208, 34, 209, 50, 208, 165, 76, 230, 170, 99, 66, 0, 180]) }, digest := (bytes [6, 10, 87, 34, 241, 198, 152, 111, 25, 24, 54, 182, 89, 57, 247, 48, 242, 144, 226, 150, 167, 143, 175, 224, 254, 182, 192, 43, 164, 232, 67, 22]) }
    , digest := (bytes [10, 195, 49, 51, 41, 225, 223, 137, 194, 153, 222, 133, 23, 213, 192, 248, 114, 92, 60, 44, 215, 4, 102, 103, 19, 127, 169, 249, 191, 87, 54, 153])
  }

def stage2RegisterReads : List RegisterReadEventView :=
  [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 1, value := 18446744073709551614 }, { traceIndex := 1, stepIndex := 0, role := .rs1, reg := 2, value := 18446744073709551613 }, { traceIndex := 2, stepIndex := 0, role := .rs1, reg := 40, value := 18446744073709551615 }, { traceIndex := 2, stepIndex := 0, role := .rs2, reg := 2, value := 18446744073709551613 }, { traceIndex := 3, stepIndex := 0, role := .rs1, reg := 41, value := 18446744073709551615 }, { traceIndex := 3, stepIndex := 0, role := .rs2, reg := 1, value := 18446744073709551614 }, { traceIndex := 4, stepIndex := 0, role := .rs1, reg := 1, value := 18446744073709551614 }, { traceIndex := 4, stepIndex := 0, role := .rs2, reg := 2, value := 18446744073709551613 }, { traceIndex := 5, stepIndex := 0, role := .rs1, reg := 42, value := 18446744073709551611 }, { traceIndex := 5, stepIndex := 0, role := .rs2, reg := 40, value := 3 }, { traceIndex := 6, stepIndex := 0, role := .rs1, reg := 42, value := 18446744073709551614 }, { traceIndex := 6, stepIndex := 0, role := .rs2, reg := 41, value := 2 }, { traceIndex := 7, stepIndex := 1, role := .rs1, reg := 3, value := 18446744073709551614 }, { traceIndex := 7, stepIndex := 1, role := .rs2, reg := 4, value := 3 }, { traceIndex := 8, stepIndex := 2, role := .rs1, reg := 5, value := 18446744073709551614 }, { traceIndex := 9, stepIndex := 2, role := .rs1, reg := 40, value := 18446744073709551615 }, { traceIndex := 10, stepIndex := 2, role := .rs1, reg := 5, value := 18446744073709551614 }, { traceIndex := 10, stepIndex := 2, role := .rs2, reg := 40, value := 18446744073709551615 }, { traceIndex := 11, stepIndex := 2, role := .rs1, reg := 42, value := 1 }, { traceIndex := 11, stepIndex := 2, role := .rs2, reg := 41, value := 1 }, { traceIndex := 12, stepIndex := 2, role := .rs1, reg := 42, value := 2 }, { traceIndex := 12, stepIndex := 2, role := .rs2, reg := 6, value := 3 }, { traceIndex := 13, stepIndex := 2, role := .rs1, reg := 42, value := 2 }, { traceIndex := 13, stepIndex := 2, role := .rs2, reg := 6, value := 3 }, { traceIndex := 14, stepIndex := 2, role := .rs1, reg := 43, value := 0 }, { traceIndex := 14, stepIndex := 2, role := .rs2, reg := 40, value := 18446744073709551615 }, { traceIndex := 15, stepIndex := 2, role := .rs1, reg := 42, value := 6 }, { traceIndex := 15, stepIndex := 2, role := .rs2, reg := 40, value := 18446744073709551615 }, { traceIndex := 16, stepIndex := 2, role := .rs1, reg := 42, value := 18446744073709551609 }, { traceIndex := 16, stepIndex := 2, role := .rs2, reg := 41, value := 1 }, { traceIndex := 17, stepIndex := 2, role := .rs1, reg := 40, value := 18446744073709551610 }, { traceIndex := 17, stepIndex := 2, role := .rs2, reg := 42, value := 18446744073709551609 }, { traceIndex := 18, stepIndex := 2, role := .rs1, reg := 43, value := 18446744073709551615 }, { traceIndex := 18, stepIndex := 2, role := .rs2, reg := 40, value := 0 }]

def stage2RegisterWrites : List RegisterWriteEventView :=
  [{ traceIndex := 0, stepIndex := 0, reg := 40, previous := 0, next := 18446744073709551615 }, { traceIndex := 1, stepIndex := 0, reg := 41, previous := 0, next := 18446744073709551615 }, { traceIndex := 2, stepIndex := 0, reg := 40, previous := 18446744073709551615, next := 3 }, { traceIndex := 3, stepIndex := 0, reg := 41, previous := 18446744073709551615, next := 2 }, { traceIndex := 4, stepIndex := 0, reg := 42, previous := 0, next := 18446744073709551611 }, { traceIndex := 5, stepIndex := 0, reg := 42, previous := 18446744073709551611, next := 18446744073709551614 }, { traceIndex := 6, stepIndex := 0, reg := 7, previous := 0, next := 0 }, { traceIndex := 7, stepIndex := 1, reg := 8, previous := 0, next := 2 }, { traceIndex := 8, stepIndex := 2, reg := 40, previous := 0, next := 18446744073709551615 }, { traceIndex := 9, stepIndex := 2, reg := 41, previous := 0, next := 1 }, { traceIndex := 10, stepIndex := 2, reg := 42, previous := 0, next := 1 }, { traceIndex := 11, stepIndex := 2, reg := 42, previous := 1, next := 2 }, { traceIndex := 12, stepIndex := 2, reg := 43, previous := 0, next := 0 }, { traceIndex := 13, stepIndex := 2, reg := 42, previous := 2, next := 6 }, { traceIndex := 14, stepIndex := 2, reg := 43, previous := 0, next := 18446744073709551615 }, { traceIndex := 15, stepIndex := 2, reg := 42, previous := 6, next := 18446744073709551609 }, { traceIndex := 16, stepIndex := 2, reg := 40, previous := 18446744073709551615, next := 18446744073709551610 }, { traceIndex := 17, stepIndex := 2, reg := 40, previous := 18446744073709551610, next := 0 }, { traceIndex := 18, stepIndex := 2, reg := 9, previous := 0, next := 18446744073709551615 }]

def stage2RamEvents : List RamEventView :=
  []

def stage2TwistLinks : List TwistLinkEventView :=
  [{ traceIndex := 0, stepIndex := 0, family := .multiply, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 0, family := .multiply, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 0, family := .multiply, routedWriteValue := (some 3), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 0, family := .multiply, routedWriteValue := (some 2), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 4, stepIndex := 0, family := .multiply, routedWriteValue := (some 18446744073709551611), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 5, stepIndex := 0, family := .multiply, routedWriteValue := (some 18446744073709551614), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 6, stepIndex := 0, family := .multiply, routedWriteValue := (some 0), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 7, stepIndex := 1, family := .multiply, routedWriteValue := (some 2), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 8, stepIndex := 2, family := .multiply, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 9, stepIndex := 2, family := .multiply, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 10, stepIndex := 2, family := .multiply, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 11, stepIndex := 2, family := .multiply, routedWriteValue := (some 2), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 12, stepIndex := 2, family := .multiply, routedWriteValue := (some 0), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 13, stepIndex := 2, family := .multiply, routedWriteValue := (some 6), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 14, stepIndex := 2, family := .multiply, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 15, stepIndex := 2, family := .multiply, routedWriteValue := (some 18446744073709551609), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 16, stepIndex := 2, family := .multiply, routedWriteValue := (some 18446744073709551610), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 17, stepIndex := 2, family := .multiply, routedWriteValue := (some 0), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 18, stepIndex := 2, family := .multiply, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 19, stepIndex := 3, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]

def stage2 : Stage2ProofBundleView :=
  {
    registerReads := stage2RegisterReads
    , registerWrites := stage2RegisterWrites
    , ramEvents := stage2RamEvents
    , registerDigest := (bytes [3, 35, 32, 227, 10, 80, 42, 129, 9, 58, 169, 128, 176, 246, 42, 151, 17, 121, 167, 174, 84, 173, 137, 222, 25, 55, 143, 224, 107, 93, 176, 41])
    , ramDigest := (bytes [209, 217, 105, 43, 209, 229, 156, 61, 92, 164, 94, 232, 52, 214, 73, 229, 72, 188, 139, 122, 165, 123, 201, 212, 205, 15, 247, 197, 165, 154, 109, 246])
    , temporal := { twistLinks := stage2TwistLinks, registerTimelineDigest := (bytes [72, 170, 229, 234, 117, 94, 37, 18, 223, 149, 138, 93, 105, 244, 180, 76, 186, 113, 220, 49, 135, 212, 60, 217, 123, 30, 101, 24, 170, 71, 82, 188]), ramTimelineDigest := (bytes [8, 117, 17, 140, 128, 180, 240, 140, 250, 181, 90, 134, 147, 17, 197, 122, 220, 8, 66, 15, 193, 254, 11, 122, 115, 210, 233, 239, 55, 132, 31, 228]), twistLinksDigest := (bytes [150, 148, 184, 116, 172, 99, 50, 84, 45, 203, 165, 16, 137, 73, 58, 124, 212, 48, 93, 70, 218, 4, 251, 59, 224, 87, 35, 4, 28, 139, 59, 181]), digest := (bytes [184, 252, 18, 169, 243, 90, 119, 1, 89, 55, 13, 179, 188, 32, 96, 113, 89, 243, 236, 23, 213, 185, 137, 124, 117, 1, 160, 107, 123, 236, 237, 116]) }
    , semantics := { registerReadsFamilyDigest := (bytes [148, 168, 52, 219, 2, 243, 175, 125, 132, 104, 253, 85, 254, 207, 246, 84, 106, 226, 255, 94, 9, 175, 93, 222, 92, 152, 36, 6, 35, 62, 3, 205]), registerWritesFamilyDigest := (bytes [79, 72, 244, 75, 221, 91, 165, 218, 80, 107, 20, 108, 159, 88, 170, 38, 129, 92, 161, 136, 75, 189, 202, 99, 1, 84, 250, 122, 208, 28, 240, 155]), ramEventsFamilyDigest := (bytes [85, 17, 108, 38, 84, 5, 109, 213, 145, 137, 203, 96, 117, 127, 130, 193, 117, 29, 27, 219, 228, 58, 7, 214, 144, 155, 66, 38, 127, 8, 241, 95]), twistLinksFamilyDigest := (bytes [64, 29, 75, 213, 52, 72, 128, 196, 132, 235, 92, 192, 141, 100, 25, 114, 13, 77, 144, 188, 67, 88, 211, 210, 249, 232, 177, 7, 208, 58, 24, 148]), rowCount := 20, registerEventCount := 53, ramEventCount := 0, digest := (bytes [215, 97, 207, 225, 149, 200, 237, 95, 243, 122, 17, 254, 156, 75, 188, 203, 40, 49, 133, 146, 11, 70, 208, 5, 42, 90, 39, 155, 112, 80, 170, 156]) }
    , linkageDigest := (bytes [125, 176, 155, 141, 104, 225, 119, 167, 212, 250, 54, 108, 5, 30, 141, 243, 151, 216, 82, 237, 93, 41, 127, 179, 125, 85, 79, 65, 109, 64, 143, 141])
    , selectedOpening := { claim := { registerReadsFamilyDigest := (bytes [148, 168, 52, 219, 2, 243, 175, 125, 132, 104, 253, 85, 254, 207, 246, 84, 106, 226, 255, 94, 9, 175, 93, 222, 92, 152, 36, 6, 35, 62, 3, 205]), registerWritesFamilyDigest := (bytes [79, 72, 244, 75, 221, 91, 165, 218, 80, 107, 20, 108, 159, 88, 170, 38, 129, 92, 161, 136, 75, 189, 202, 99, 1, 84, 250, 122, 208, 28, 240, 155]), ramEventsFamilyDigest := (bytes [85, 17, 108, 38, 84, 5, 109, 213, 145, 137, 203, 96, 117, 127, 130, 193, 117, 29, 27, 219, 228, 58, 7, 214, 144, 155, 66, 38, 127, 8, 241, 95]), twistLinksFamilyDigest := (bytes [64, 29, 75, 213, 52, 72, 128, 196, 132, 235, 92, 192, 141, 100, 25, 114, 13, 77, 144, 188, 67, 88, 211, 210, 249, 232, 177, 7, 208, 58, 24, 148]), registerReadCount := 34, registerWriteCount := 19, ramEventCount := 0, twistLinkCount := 20, ramReadCount := 0, ramWriteCount := 0, regMix := 7181907923970274102, ramMix := 4010680615921688272, points := { firstRead := (some { id := { object := { familyTag := 2, commitmentDigest := (bytes [148, 168, 52, 219, 2, 243, 175, 125, 132, 104, 253, 85, 254, 207, 246, 84, 106, 226, 255, 94, 9, 175, 93, 222, 92, 152, 36, 6, 35, 62, 3, 205]), layoutVersion := 1, digest := (bytes [20, 201, 72, 196, 144, 220, 68, 190, 119, 209, 45, 35, 17, 205, 162, 209, 183, 160, 113, 77, 103, 138, 100, 38, 161, 101, 149, 138, 27, 38, 196, 104]) }, logicalIndex := 0, digest := (bytes [21, 188, 22, 224, 186, 153, 47, 24, 223, 18, 10, 224, 135, 18, 191, 151, 192, 193, 69, 194, 217, 233, 185, 56, 216, 181, 89, 16, 81, 104, 80, 44]) }, valueDigest := (bytes [171, 151, 24, 197, 42, 241, 236, 55, 60, 97, 43, 36, 126, 13, 154, 120, 59, 120, 229, 167, 36, 115, 49, 62, 224, 249, 22, 79, 205, 105, 92, 28]), digest := (bytes [156, 28, 91, 201, 253, 84, 208, 181, 134, 126, 116, 22, 184, 48, 24, 211, 61, 92, 128, 174, 182, 167, 110, 235, 202, 31, 211, 254, 174, 181, 207, 178]) }), lastRead := (some { id := { object := { familyTag := 2, commitmentDigest := (bytes [148, 168, 52, 219, 2, 243, 175, 125, 132, 104, 253, 85, 254, 207, 246, 84, 106, 226, 255, 94, 9, 175, 93, 222, 92, 152, 36, 6, 35, 62, 3, 205]), layoutVersion := 1, digest := (bytes [20, 201, 72, 196, 144, 220, 68, 190, 119, 209, 45, 35, 17, 205, 162, 209, 183, 160, 113, 77, 103, 138, 100, 38, 161, 101, 149, 138, 27, 38, 196, 104]) }, logicalIndex := 33, digest := (bytes [192, 151, 219, 210, 30, 38, 177, 245, 73, 69, 190, 73, 150, 91, 113, 75, 128, 53, 15, 235, 4, 4, 87, 129, 16, 41, 40, 69, 154, 214, 0, 49]) }, valueDigest := (bytes [127, 153, 123, 10, 36, 4, 239, 137, 239, 57, 156, 247, 177, 41, 78, 106, 151, 96, 211, 138, 135, 223, 53, 206, 220, 22, 109, 213, 117, 240, 182, 115]), digest := (bytes [69, 250, 58, 140, 17, 4, 154, 190, 96, 75, 97, 44, 31, 224, 89, 236, 255, 185, 202, 108, 38, 72, 184, 223, 74, 162, 18, 91, 89, 30, 108, 8]) }), firstWrite := (some { id := { object := { familyTag := 3, commitmentDigest := (bytes [79, 72, 244, 75, 221, 91, 165, 218, 80, 107, 20, 108, 159, 88, 170, 38, 129, 92, 161, 136, 75, 189, 202, 99, 1, 84, 250, 122, 208, 28, 240, 155]), layoutVersion := 1, digest := (bytes [21, 27, 84, 122, 187, 145, 94, 255, 5, 248, 138, 6, 24, 131, 87, 219, 141, 84, 216, 82, 120, 10, 83, 165, 49, 44, 63, 91, 62, 46, 245, 196]) }, logicalIndex := 0, digest := (bytes [233, 132, 65, 219, 169, 46, 17, 41, 121, 91, 197, 55, 129, 241, 210, 42, 27, 132, 215, 195, 72, 54, 221, 250, 180, 183, 20, 4, 243, 172, 62, 154]) }, valueDigest := (bytes [71, 48, 249, 25, 100, 17, 102, 59, 215, 129, 13, 5, 113, 248, 164, 175, 230, 79, 162, 36, 237, 182, 68, 40, 255, 226, 253, 109, 187, 126, 253, 226]), digest := (bytes [121, 60, 133, 128, 138, 37, 218, 146, 92, 203, 90, 74, 57, 238, 239, 245, 37, 166, 171, 245, 219, 239, 78, 194, 55, 172, 34, 240, 110, 129, 245, 214]) }), lastWrite := (some { id := { object := { familyTag := 3, commitmentDigest := (bytes [79, 72, 244, 75, 221, 91, 165, 218, 80, 107, 20, 108, 159, 88, 170, 38, 129, 92, 161, 136, 75, 189, 202, 99, 1, 84, 250, 122, 208, 28, 240, 155]), layoutVersion := 1, digest := (bytes [21, 27, 84, 122, 187, 145, 94, 255, 5, 248, 138, 6, 24, 131, 87, 219, 141, 84, 216, 82, 120, 10, 83, 165, 49, 44, 63, 91, 62, 46, 245, 196]) }, logicalIndex := 18, digest := (bytes [141, 130, 214, 137, 172, 1, 81, 232, 239, 138, 10, 108, 32, 174, 251, 135, 250, 87, 7, 230, 239, 212, 0, 109, 189, 136, 41, 232, 77, 104, 171, 34]) }, valueDigest := (bytes [123, 54, 253, 168, 9, 191, 60, 0, 86, 162, 245, 26, 117, 223, 217, 112, 173, 225, 152, 80, 250, 48, 208, 76, 118, 126, 108, 253, 116, 169, 29, 41]), digest := (bytes [150, 225, 121, 114, 85, 134, 221, 9, 255, 149, 113, 111, 179, 236, 44, 212, 19, 109, 196, 162, 63, 89, 211, 110, 51, 25, 253, 41, 61, 63, 16, 112]) }), firstRam := none, lastRam := none, firstTwist := (some { id := { object := { familyTag := 5, commitmentDigest := (bytes [64, 29, 75, 213, 52, 72, 128, 196, 132, 235, 92, 192, 141, 100, 25, 114, 13, 77, 144, 188, 67, 88, 211, 210, 249, 232, 177, 7, 208, 58, 24, 148]), layoutVersion := 1, digest := (bytes [178, 25, 99, 52, 33, 48, 234, 48, 37, 171, 23, 107, 173, 82, 8, 74, 216, 152, 148, 94, 190, 169, 189, 236, 159, 37, 133, 74, 250, 112, 138, 85]) }, logicalIndex := 0, digest := (bytes [168, 41, 192, 209, 14, 158, 242, 185, 22, 42, 218, 51, 172, 92, 13, 251, 189, 231, 88, 89, 41, 244, 238, 30, 104, 209, 188, 62, 169, 212, 178, 114]) }, valueDigest := (bytes [67, 8, 81, 205, 14, 151, 29, 16, 109, 222, 179, 32, 124, 119, 12, 48, 41, 34, 36, 15, 62, 237, 119, 132, 90, 82, 16, 38, 155, 138, 237, 151]), digest := (bytes [198, 73, 144, 134, 166, 204, 63, 241, 205, 112, 3, 70, 42, 123, 220, 98, 202, 180, 35, 100, 131, 215, 15, 173, 60, 225, 221, 111, 116, 71, 128, 237]) }), lastTwist := (some { id := { object := { familyTag := 5, commitmentDigest := (bytes [64, 29, 75, 213, 52, 72, 128, 196, 132, 235, 92, 192, 141, 100, 25, 114, 13, 77, 144, 188, 67, 88, 211, 210, 249, 232, 177, 7, 208, 58, 24, 148]), layoutVersion := 1, digest := (bytes [178, 25, 99, 52, 33, 48, 234, 48, 37, 171, 23, 107, 173, 82, 8, 74, 216, 152, 148, 94, 190, 169, 189, 236, 159, 37, 133, 74, 250, 112, 138, 85]) }, logicalIndex := 19, digest := (bytes [32, 218, 14, 219, 175, 150, 225, 63, 253, 197, 169, 156, 85, 223, 189, 120, 141, 175, 41, 146, 107, 202, 237, 204, 63, 237, 46, 158, 82, 75, 202, 7]) }, valueDigest := (bytes [203, 27, 113, 123, 101, 108, 223, 161, 124, 155, 230, 173, 184, 141, 156, 216, 61, 155, 229, 181, 161, 167, 32, 127, 16, 91, 29, 148, 153, 204, 121, 199]), digest := (bytes [145, 64, 108, 154, 51, 181, 249, 21, 2, 230, 189, 212, 0, 1, 112, 31, 80, 87, 68, 42, 16, 46, 43, 196, 77, 73, 83, 27, 168, 69, 170, 117]) }) }, digest := (bytes [120, 14, 159, 125, 74, 28, 43, 35, 60, 243, 122, 119, 78, 74, 71, 137, 5, 65, 93, 229, 94, 194, 210, 156, 130, 225, 108, 254, 142, 129, 209, 44]) }, packaged := { statementDigest := (bytes [33, 110, 214, 95, 93, 230, 238, 10, 189, 221, 187, 18, 11, 68, 78, 223, 240, 16, 146, 240, 193, 190, 218, 222, 157, 218, 124, 220, 198, 1, 235, 63]), proofDigest := (bytes [118, 85, 206, 21, 253, 136, 226, 191, 63, 234, 95, 58, 105, 28, 212, 229, 82, 132, 5, 21, 118, 194, 108, 91, 9, 161, 190, 112, 31, 34, 248, 149]) }, digest := (bytes [218, 40, 31, 235, 102, 3, 46, 12, 84, 131, 99, 11, 21, 10, 80, 37, 106, 103, 252, 44, 250, 58, 169, 51, 76, 29, 215, 63, 181, 188, 27, 111]) }
    , digest := (bytes [140, 216, 5, 220, 38, 221, 149, 54, 162, 190, 158, 213, 110, 106, 96, 26, 205, 230, 69, 36, 23, 223, 241, 66, 248, 0, 195, 91, 157, 141, 95, 181])
  }

def stage3Continuity : List ContinuityEventView :=
  [{ stepIndex := 0, pc := 0, nextPc := 4, successorPc := (some 4), finalStep := false, continuityHolds := true }, { stepIndex := 1, pc := 4, nextPc := 8, successorPc := (some 8), finalStep := false, continuityHolds := true }, { stepIndex := 2, pc := 8, nextPc := 12, successorPc := (some 12), finalStep := false, continuityHolds := true }, { stepIndex := 3, pc := 12, nextPc := 16, successorPc := none, finalStep := true, continuityHolds := true }]

def stage3 : Stage3ProofBundleView :=
  {
    continuity := stage3Continuity
    , halted := true
    , bridgeDigest := (bytes [229, 94, 202, 24, 66, 232, 109, 198, 229, 19, 83, 45, 204, 221, 7, 227, 208, 20, 88, 144, 251, 93, 185, 201, 248, 240, 125, 6, 104, 141, 59, 5])
    , semantics := { continuityDigest := (bytes [130, 228, 63, 175, 76, 42, 157, 92, 245, 164, 95, 242, 227, 234, 25, 172, 180, 188, 143, 68, 105, 121, 33, 203, 111, 111, 42, 219, 83, 99, 88, 233]), rootSemanticRowsDigest := (bytes [143, 50, 80, 146, 88, 180, 163, 180, 18, 250, 142, 67, 29, 198, 31, 93, 11, 216, 111, 127, 238, 166, 15, 102, 43, 215, 91, 30, 2, 248, 103, 86]), rowChunkRoutesDigest := (bytes [44, 19, 15, 238, 134, 132, 130, 143, 37, 145, 123, 34, 41, 193, 34, 193, 20, 41, 74, 29, 203, 33, 147, 118, 124, 21, 3, 194, 30, 95, 164, 186]), preparedStepBindingsDigest := (bytes [56, 55, 65, 136, 166, 105, 55, 221, 32, 59, 92, 217, 19, 218, 150, 142, 9, 231, 253, 237, 17, 141, 61, 10, 157, 65, 174, 106, 188, 85, 117, 232]), stage2TemporalDigest := (bytes [184, 252, 18, 169, 243, 90, 119, 1, 89, 55, 13, 179, 188, 32, 96, 113, 89, 243, 236, 23, 213, 185, 137, 124, 117, 1, 160, 107, 123, 236, 237, 116]), initialPc := 0, finalPc := 16, realRowCount := 4, firstRealStepIndex := 0, lastRealStepIndex := 3, digest := (bytes [92, 171, 234, 150, 144, 168, 117, 235, 254, 7, 82, 199, 150, 32, 197, 180, 38, 163, 196, 126, 44, 71, 58, 97, 22, 109, 180, 250, 128, 101, 42, 209]) }
    , linkageDigest := (bytes [252, 185, 236, 112, 47, 239, 232, 182, 253, 212, 101, 231, 128, 212, 7, 44, 187, 86, 244, 143, 142, 113, 66, 138, 192, 88, 215, 218, 107, 120, 147, 79])
    , selectedOpening := { claim := { continuityFamilyDigest := (bytes [36, 145, 162, 1, 122, 57, 69, 164, 232, 234, 32, 251, 24, 216, 66, 234, 76, 247, 12, 203, 138, 66, 151, 82, 154, 84, 143, 219, 245, 68, 140, 185]), continuityCount := 4, finalStepCount := 1, halted := true, allContinuityHold := true, continuityMix := 16732273574652248418, points := { firstContinuity := (some { id := { object := { familyTag := 6, commitmentDigest := (bytes [36, 145, 162, 1, 122, 57, 69, 164, 232, 234, 32, 251, 24, 216, 66, 234, 76, 247, 12, 203, 138, 66, 151, 82, 154, 84, 143, 219, 245, 68, 140, 185]), layoutVersion := 1, digest := (bytes [160, 220, 179, 14, 199, 254, 81, 53, 117, 96, 70, 165, 212, 229, 0, 122, 156, 201, 2, 245, 137, 174, 66, 154, 196, 13, 58, 68, 219, 25, 81, 100]) }, logicalIndex := 0, digest := (bytes [223, 132, 42, 75, 248, 225, 64, 208, 180, 176, 200, 120, 233, 5, 33, 188, 166, 54, 240, 118, 187, 203, 127, 88, 56, 255, 138, 59, 248, 182, 248, 54]) }, valueDigest := (bytes [7, 131, 85, 21, 57, 109, 53, 31, 137, 53, 98, 18, 170, 36, 28, 200, 149, 213, 171, 159, 119, 200, 36, 230, 30, 35, 30, 11, 252, 126, 240, 63]), digest := (bytes [231, 168, 163, 84, 17, 45, 116, 23, 208, 214, 34, 31, 184, 170, 115, 156, 185, 119, 115, 229, 236, 122, 140, 88, 61, 225, 56, 203, 144, 4, 248, 71]) }), lastContinuity := (some { id := { object := { familyTag := 6, commitmentDigest := (bytes [36, 145, 162, 1, 122, 57, 69, 164, 232, 234, 32, 251, 24, 216, 66, 234, 76, 247, 12, 203, 138, 66, 151, 82, 154, 84, 143, 219, 245, 68, 140, 185]), layoutVersion := 1, digest := (bytes [160, 220, 179, 14, 199, 254, 81, 53, 117, 96, 70, 165, 212, 229, 0, 122, 156, 201, 2, 245, 137, 174, 66, 154, 196, 13, 58, 68, 219, 25, 81, 100]) }, logicalIndex := 3, digest := (bytes [150, 213, 84, 54, 217, 134, 4, 31, 230, 223, 9, 92, 67, 140, 106, 235, 138, 215, 4, 194, 7, 142, 77, 103, 164, 215, 197, 80, 55, 198, 120, 224]) }, valueDigest := (bytes [15, 34, 13, 74, 171, 218, 255, 182, 206, 83, 10, 195, 2, 153, 48, 183, 205, 82, 29, 152, 205, 208, 71, 113, 10, 25, 195, 29, 1, 86, 100, 46]), digest := (bytes [15, 132, 9, 199, 125, 187, 78, 207, 144, 161, 80, 238, 132, 133, 201, 218, 80, 216, 26, 225, 161, 144, 107, 165, 29, 0, 16, 227, 169, 15, 144, 24]) }) }, digest := (bytes [216, 184, 29, 52, 242, 133, 183, 13, 176, 184, 61, 49, 70, 98, 6, 10, 70, 124, 204, 66, 26, 35, 223, 35, 60, 26, 12, 176, 26, 198, 2, 207]) }, packaged := { statementDigest := (bytes [47, 248, 94, 142, 152, 111, 241, 162, 66, 201, 180, 147, 203, 17, 203, 15, 185, 144, 239, 204, 167, 8, 38, 119, 24, 111, 124, 59, 119, 162, 250, 154]), proofDigest := (bytes [68, 125, 242, 172, 129, 81, 157, 222, 113, 19, 31, 120, 190, 50, 206, 165, 47, 129, 118, 155, 7, 98, 207, 65, 234, 152, 142, 186, 65, 232, 5, 81]) }, digest := (bytes [11, 50, 217, 85, 206, 200, 239, 139, 234, 25, 96, 96, 132, 20, 133, 5, 36, 123, 115, 179, 2, 255, 142, 86, 179, 60, 240, 89, 255, 62, 179, 48]) }
    , digest := (bytes [144, 190, 29, 169, 25, 28, 0, 159, 222, 243, 225, 172, 192, 73, 102, 126, 241, 126, 130, 122, 249, 220, 128, 173, 103, 74, 218, 217, 205, 96, 170, 94])
  }

def rootExecutionExecutionRows : List ExpandedRowView :=
  [{
  traceIndex := 0
  , stepIndex := 0
  , sequenceIndex := 0
  , pc := 0
  , nextPc := 0
  , word := 35689395
  , opcode := .mulh
  , traceOpcode := none
  , traceVirtualOpcode := (some .movsign)
  , family := .multiply
  , rs1 := 1
  , rs1Value := 18446744073709551614
  , rs2 := 0
  , rs2Value := 0
  , rd := 40
  , rdBefore := 0
  , rdAfter := 18446744073709551615
  , imm := 0
  , aluResult := 18446744073709551615
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := true
  , virtualSequenceRemaining := (some 6)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 1
  , stepIndex := 0
  , sequenceIndex := 1
  , pc := 0
  , nextPc := 0
  , word := 35689395
  , opcode := .mulh
  , traceOpcode := none
  , traceVirtualOpcode := (some .movsign)
  , family := .multiply
  , rs1 := 2
  , rs1Value := 18446744073709551613
  , rs2 := 0
  , rs2Value := 0
  , rd := 41
  , rdBefore := 0
  , rdAfter := 18446744073709551615
  , imm := 0
  , aluResult := 18446744073709551615
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 5)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 2
  , stepIndex := 0
  , sequenceIndex := 2
  , pc := 0
  , nextPc := 0
  , word := 35689395
  , opcode := .mulh
  , traceOpcode := (some .mul)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 40
  , rs1Value := 18446744073709551615
  , rs2 := 2
  , rs2Value := 18446744073709551613
  , rd := 40
  , rdBefore := 18446744073709551615
  , rdAfter := 3
  , imm := 0
  , aluResult := 3
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 4)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 3
  , stepIndex := 0
  , sequenceIndex := 3
  , pc := 0
  , nextPc := 0
  , word := 35689395
  , opcode := .mulh
  , traceOpcode := (some .mul)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 41
  , rs1Value := 18446744073709551615
  , rs2 := 1
  , rs2Value := 18446744073709551614
  , rd := 41
  , rdBefore := 18446744073709551615
  , rdAfter := 2
  , imm := 0
  , aluResult := 2
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 3)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 4
  , stepIndex := 0
  , sequenceIndex := 4
  , pc := 0
  , nextPc := 0
  , word := 35689395
  , opcode := .mulh
  , traceOpcode := (some .mulhu)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 1
  , rs1Value := 18446744073709551614
  , rs2 := 2
  , rs2Value := 18446744073709551613
  , rd := 42
  , rdBefore := 0
  , rdAfter := 18446744073709551611
  , imm := 0
  , aluResult := 18446744073709551611
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 2)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 5
  , stepIndex := 0
  , sequenceIndex := 5
  , pc := 0
  , nextPc := 0
  , word := 35689395
  , opcode := .mulh
  , traceOpcode := (some .add)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 42
  , rs1Value := 18446744073709551611
  , rs2 := 40
  , rs2Value := 3
  , rd := 42
  , rdBefore := 18446744073709551611
  , rdAfter := 18446744073709551614
  , imm := 0
  , aluResult := 18446744073709551614
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 1)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 6
  , stepIndex := 0
  , sequenceIndex := 6
  , pc := 0
  , nextPc := 4
  , word := 35689395
  , opcode := .mulh
  , traceOpcode := (some .add)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 42
  , rs1Value := 18446744073709551614
  , rs2 := 41
  , rs2Value := 2
  , rd := 7
  , rdBefore := 0
  , rdAfter := 0
  , imm := 0
  , aluResult := 0
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 0)
  , isEffectRow := true
  , isCommitRow := true
  , isReal := true
}, {
  traceIndex := 7
  , stepIndex := 1
  , sequenceIndex := 0
  , pc := 4
  , nextPc := 8
  , word := 37860403
  , opcode := .mulhu
  , traceOpcode := (some .mulhu)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 3
  , rs1Value := 18446744073709551614
  , rs2 := 4
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
  , stepIndex := 2
  , sequenceIndex := 0
  , pc := 8
  , nextPc := 8
  , word := 40019123
  , opcode := .mulhsu
  , traceOpcode := none
  , traceVirtualOpcode := (some .movsign)
  , family := .multiply
  , rs1 := 5
  , rs1Value := 18446744073709551614
  , rs2 := 0
  , rs2Value := 0
  , rd := 40
  , rdBefore := 0
  , rdAfter := 18446744073709551615
  , imm := 0
  , aluResult := 18446744073709551615
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := true
  , virtualSequenceRemaining := (some 10)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 9
  , stepIndex := 2
  , sequenceIndex := 1
  , pc := 8
  , nextPc := 8
  , word := 40019123
  , opcode := .mulhsu
  , traceOpcode := (some .andi)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 40
  , rs1Value := 18446744073709551615
  , rs2 := 0
  , rs2Value := 0
  , rd := 41
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
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 9)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 10
  , stepIndex := 2
  , sequenceIndex := 2
  , pc := 8
  , nextPc := 8
  , word := 40019123
  , opcode := .mulhsu
  , traceOpcode := (some .xor)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 5
  , rs1Value := 18446744073709551614
  , rs2 := 40
  , rs2Value := 18446744073709551615
  , rd := 42
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
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 8)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 11
  , stepIndex := 2
  , sequenceIndex := 3
  , pc := 8
  , nextPc := 8
  , word := 40019123
  , opcode := .mulhsu
  , traceOpcode := (some .add)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 42
  , rs1Value := 1
  , rs2 := 41
  , rs2Value := 1
  , rd := 42
  , rdBefore := 1
  , rdAfter := 2
  , imm := 0
  , aluResult := 2
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 7)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 12
  , stepIndex := 2
  , sequenceIndex := 4
  , pc := 8
  , nextPc := 8
  , word := 40019123
  , opcode := .mulhsu
  , traceOpcode := (some .mulhu)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 42
  , rs1Value := 2
  , rs2 := 6
  , rs2Value := 3
  , rd := 43
  , rdBefore := 0
  , rdAfter := 0
  , imm := 0
  , aluResult := 0
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 6)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 13
  , stepIndex := 2
  , sequenceIndex := 5
  , pc := 8
  , nextPc := 8
  , word := 40019123
  , opcode := .mulhsu
  , traceOpcode := (some .mul)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 42
  , rs1Value := 2
  , rs2 := 6
  , rs2Value := 3
  , rd := 42
  , rdBefore := 2
  , rdAfter := 6
  , imm := 0
  , aluResult := 6
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 5)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 14
  , stepIndex := 2
  , sequenceIndex := 6
  , pc := 8
  , nextPc := 8
  , word := 40019123
  , opcode := .mulhsu
  , traceOpcode := (some .xor)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 43
  , rs1Value := 0
  , rs2 := 40
  , rs2Value := 18446744073709551615
  , rd := 43
  , rdBefore := 0
  , rdAfter := 18446744073709551615
  , imm := 0
  , aluResult := 18446744073709551615
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 4)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 15
  , stepIndex := 2
  , sequenceIndex := 7
  , pc := 8
  , nextPc := 8
  , word := 40019123
  , opcode := .mulhsu
  , traceOpcode := (some .xor)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 42
  , rs1Value := 6
  , rs2 := 40
  , rs2Value := 18446744073709551615
  , rd := 42
  , rdBefore := 6
  , rdAfter := 18446744073709551609
  , imm := 0
  , aluResult := 18446744073709551609
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 3)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 16
  , stepIndex := 2
  , sequenceIndex := 8
  , pc := 8
  , nextPc := 8
  , word := 40019123
  , opcode := .mulhsu
  , traceOpcode := (some .add)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 42
  , rs1Value := 18446744073709551609
  , rs2 := 41
  , rs2Value := 1
  , rd := 40
  , rdBefore := 18446744073709551615
  , rdAfter := 18446744073709551610
  , imm := 0
  , aluResult := 18446744073709551610
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 2)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 17
  , stepIndex := 2
  , sequenceIndex := 9
  , pc := 8
  , nextPc := 8
  , word := 40019123
  , opcode := .mulhsu
  , traceOpcode := (some .sltu)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 40
  , rs1Value := 18446744073709551610
  , rs2 := 42
  , rs2Value := 18446744073709551609
  , rd := 40
  , rdBefore := 18446744073709551610
  , rdAfter := 0
  , imm := 0
  , aluResult := 0
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 1)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 18
  , stepIndex := 2
  , sequenceIndex := 10
  , pc := 8
  , nextPc := 12
  , word := 40019123
  , opcode := .mulhsu
  , traceOpcode := (some .add)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 43
  , rs1Value := 18446744073709551615
  , rs2 := 40
  , rs2Value := 0
  , rd := 9
  , rdBefore := 0
  , rdAfter := 18446744073709551615
  , imm := 0
  , aluResult := 18446744073709551615
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 0)
  , isEffectRow := true
  , isCommitRow := true
  , isReal := true
}, {
  traceIndex := 19
  , stepIndex := 3
  , sequenceIndex := 0
  , pc := 12
  , nextPc := 16
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
  [{ traceIndex := 0, values := [1, 0, 0, 0, 0, 4294967294, 4294967295, 0, 0, 4294967295, 4294967295, 0, 0, 4294967295, 4294967295, 4, 0, 0, 0, 0, 0, 0, 0, 40, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], rowDigest := (bytes [158, 63, 138, 206, 127, 145, 146, 109, 103, 153, 88, 114, 209, 198, 164, 199, 49, 182, 5, 151, 139, 25, 106, 81, 245, 88, 121, 14, 33, 120, 32, 196]), digest := (bytes [25, 205, 150, 160, 178, 102, 166, 186, 246, 174, 205, 130, 40, 51, 62, 134, 37, 1, 15, 182, 103, 238, 174, 17, 68, 143, 26, 72, 174, 144, 228, 71]) }, { traceIndex := 1, values := [1, 0, 0, 0, 0, 4294967293, 4294967295, 0, 0, 4294967295, 4294967295, 0, 0, 4294967295, 4294967295, 4, 0, 0, 0, 0, 0, 0, 0, 41, 2, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], rowDigest := (bytes [30, 68, 58, 84, 175, 11, 160, 249, 39, 145, 50, 95, 16, 212, 64, 78, 98, 42, 117, 222, 223, 194, 158, 145, 126, 125, 17, 23, 54, 138, 122, 80]), digest := (bytes [47, 203, 55, 160, 32, 200, 70, 137, 205, 91, 223, 43, 238, 148, 104, 115, 87, 4, 97, 88, 6, 138, 86, 28, 191, 190, 74, 22, 46, 109, 45, 28]) }, { traceIndex := 2, values := [1, 0, 0, 0, 0, 4294967295, 4294967295, 4294967293, 4294967295, 3, 0, 0, 0, 3, 0, 4, 0, 0, 0, 0, 0, 0, 0, 40, 40, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], rowDigest := (bytes [178, 44, 170, 123, 123, 27, 226, 112, 10, 219, 173, 190, 229, 37, 167, 135, 127, 196, 68, 7, 250, 125, 219, 32, 134, 127, 171, 216, 69, 106, 130, 156]), digest := (bytes [84, 29, 185, 47, 225, 75, 171, 219, 35, 80, 85, 250, 190, 141, 152, 131, 254, 116, 201, 41, 138, 30, 137, 4, 231, 133, 56, 206, 54, 98, 101, 159]) }, { traceIndex := 3, values := [1, 0, 0, 0, 0, 4294967295, 4294967295, 4294967294, 4294967295, 2, 0, 0, 0, 2, 0, 4, 0, 0, 0, 0, 0, 0, 0, 41, 41, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], rowDigest := (bytes [204, 89, 98, 191, 112, 54, 128, 12, 196, 231, 127, 23, 3, 143, 26, 215, 48, 236, 156, 165, 112, 21, 184, 57, 90, 7, 232, 66, 107, 229, 107, 45]), digest := (bytes [57, 57, 112, 124, 93, 25, 155, 6, 125, 18, 253, 179, 142, 49, 42, 240, 241, 164, 207, 129, 149, 21, 122, 4, 81, 54, 179, 169, 103, 128, 111, 0]) }, { traceIndex := 4, values := [1, 0, 0, 0, 0, 4294967294, 4294967295, 4294967293, 4294967295, 4294967291, 4294967295, 0, 0, 4294967291, 4294967295, 4, 0, 0, 0, 0, 0, 0, 0, 42, 1, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], rowDigest := (bytes [20, 207, 74, 15, 142, 67, 144, 245, 10, 60, 36, 62, 55, 250, 212, 231, 38, 9, 173, 154, 62, 190, 177, 127, 80, 19, 123, 179, 3, 254, 168, 237]), digest := (bytes [206, 26, 107, 178, 125, 131, 254, 175, 50, 56, 194, 134, 84, 84, 142, 25, 138, 250, 27, 100, 135, 208, 47, 163, 86, 11, 8, 200, 149, 157, 92, 50]) }, { traceIndex := 5, values := [1, 0, 0, 0, 0, 4294967291, 4294967295, 3, 0, 4294967294, 4294967295, 0, 0, 4294967294, 4294967295, 4, 0, 0, 0, 0, 0, 0, 0, 42, 42, 40, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], rowDigest := (bytes [246, 16, 98, 215, 242, 223, 69, 56, 52, 163, 208, 255, 69, 200, 49, 90, 170, 121, 232, 125, 96, 209, 208, 167, 50, 195, 120, 1, 218, 43, 20, 220]), digest := (bytes [2, 15, 209, 249, 178, 201, 5, 129, 220, 23, 199, 2, 65, 40, 141, 57, 99, 175, 26, 99, 80, 51, 143, 9, 129, 193, 169, 255, 40, 138, 254, 221]) }, { traceIndex := 6, values := [1, 0, 0, 4, 0, 4294967294, 4294967295, 2, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 7, 42, 41, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1], rowDigest := (bytes [80, 52, 1, 224, 195, 53, 195, 155, 48, 141, 141, 133, 71, 70, 159, 185, 13, 131, 104, 77, 34, 74, 9, 167, 19, 18, 133, 45, 219, 55, 235, 84]), digest := (bytes [244, 6, 228, 191, 173, 198, 180, 154, 233, 137, 182, 252, 205, 112, 107, 149, 152, 251, 14, 61, 62, 76, 170, 236, 203, 12, 96, 182, 198, 101, 16, 1]) }, { traceIndex := 7, values := [1, 4, 0, 8, 0, 4294967294, 4294967295, 3, 0, 2, 0, 0, 0, 2, 0, 8, 0, 0, 0, 0, 0, 0, 0, 8, 3, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1], rowDigest := (bytes [123, 74, 99, 234, 106, 3, 85, 168, 105, 77, 91, 143, 218, 79, 210, 129, 19, 31, 152, 60, 100, 233, 158, 198, 72, 104, 166, 142, 21, 2, 240, 28]), digest := (bytes [190, 212, 56, 166, 190, 157, 5, 119, 143, 202, 81, 172, 233, 51, 144, 63, 243, 93, 192, 12, 21, 201, 138, 79, 67, 248, 245, 166, 249, 32, 192, 143]) }, { traceIndex := 8, values := [1, 8, 0, 8, 0, 4294967294, 4294967295, 0, 0, 4294967295, 4294967295, 0, 0, 4294967295, 4294967295, 12, 0, 0, 0, 0, 0, 0, 0, 40, 5, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], rowDigest := (bytes [158, 217, 189, 162, 21, 24, 94, 106, 137, 77, 251, 203, 145, 76, 178, 60, 241, 147, 137, 185, 95, 104, 20, 85, 25, 151, 218, 90, 238, 207, 42, 103]), digest := (bytes [11, 119, 15, 129, 60, 245, 142, 222, 64, 205, 20, 207, 97, 240, 98, 144, 221, 12, 161, 22, 197, 221, 71, 180, 134, 45, 232, 208, 83, 24, 18, 96]) }, { traceIndex := 9, values := [1, 8, 0, 8, 0, 4294967295, 4294967295, 0, 0, 1, 0, 1, 0, 1, 0, 12, 0, 0, 0, 0, 0, 0, 0, 41, 40, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], rowDigest := (bytes [205, 194, 177, 93, 89, 23, 156, 62, 204, 14, 207, 248, 121, 190, 213, 168, 90, 140, 244, 199, 141, 65, 162, 39, 255, 0, 175, 238, 76, 119, 95, 65]), digest := (bytes [27, 233, 76, 142, 212, 192, 12, 79, 163, 104, 188, 173, 88, 193, 242, 155, 146, 181, 72, 197, 57, 203, 119, 140, 209, 108, 206, 44, 24, 7, 144, 43]) }, { traceIndex := 10, values := [1, 8, 0, 8, 0, 4294967294, 4294967295, 4294967295, 4294967295, 1, 0, 0, 0, 1, 0, 12, 0, 0, 0, 0, 0, 0, 0, 42, 5, 40, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], rowDigest := (bytes [219, 37, 234, 30, 178, 217, 93, 96, 211, 218, 208, 49, 151, 47, 53, 233, 79, 13, 80, 7, 224, 100, 121, 131, 82, 7, 130, 105, 104, 91, 195, 76]), digest := (bytes [246, 130, 144, 47, 199, 141, 164, 141, 220, 63, 10, 231, 166, 134, 83, 96, 187, 73, 143, 121, 168, 85, 96, 132, 0, 68, 193, 116, 159, 223, 9, 230]) }, { traceIndex := 11, values := [1, 8, 0, 8, 0, 1, 0, 1, 0, 2, 0, 0, 0, 2, 0, 12, 0, 0, 0, 0, 0, 0, 0, 42, 42, 41, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], rowDigest := (bytes [194, 37, 158, 198, 208, 202, 71, 136, 176, 37, 0, 223, 59, 9, 142, 153, 252, 35, 178, 52, 46, 240, 42, 180, 21, 37, 90, 134, 54, 168, 126, 49]), digest := (bytes [53, 214, 155, 198, 96, 192, 106, 15, 65, 40, 142, 24, 38, 45, 69, 66, 223, 208, 245, 13, 42, 120, 99, 219, 131, 219, 222, 90, 83, 246, 204, 56]) }, { traceIndex := 12, values := [1, 8, 0, 8, 0, 2, 0, 3, 0, 0, 0, 0, 0, 0, 0, 12, 0, 0, 0, 0, 0, 0, 0, 43, 42, 6, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], rowDigest := (bytes [126, 195, 171, 232, 165, 194, 244, 162, 228, 241, 186, 102, 42, 82, 160, 178, 166, 244, 222, 45, 66, 223, 90, 55, 3, 213, 72, 102, 67, 249, 57, 132]), digest := (bytes [89, 54, 78, 193, 151, 220, 252, 136, 36, 218, 4, 54, 14, 84, 200, 221, 249, 231, 239, 86, 80, 155, 153, 29, 184, 80, 8, 94, 161, 144, 245, 216]) }, { traceIndex := 13, values := [1, 8, 0, 8, 0, 2, 0, 3, 0, 6, 0, 0, 0, 6, 0, 12, 0, 0, 0, 0, 0, 0, 0, 42, 42, 6, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], rowDigest := (bytes [237, 11, 83, 137, 122, 187, 124, 63, 44, 245, 185, 225, 204, 82, 42, 232, 178, 182, 194, 117, 198, 78, 96, 182, 187, 52, 184, 225, 14, 177, 115, 98]), digest := (bytes [207, 221, 213, 152, 121, 82, 189, 190, 174, 204, 234, 67, 8, 192, 177, 39, 28, 255, 160, 26, 247, 166, 200, 49, 210, 126, 153, 38, 122, 205, 36, 244]) }, { traceIndex := 14, values := [1, 8, 0, 8, 0, 0, 0, 4294967295, 4294967295, 4294967295, 4294967295, 0, 0, 4294967295, 4294967295, 12, 0, 0, 0, 0, 0, 0, 0, 43, 43, 40, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], rowDigest := (bytes [65, 147, 137, 59, 251, 191, 106, 251, 17, 251, 114, 249, 112, 47, 75, 125, 78, 168, 5, 212, 122, 91, 87, 187, 142, 229, 122, 134, 183, 238, 110, 158]), digest := (bytes [163, 250, 210, 147, 54, 153, 13, 233, 213, 180, 11, 107, 28, 35, 113, 219, 90, 21, 242, 94, 240, 146, 98, 139, 154, 108, 80, 195, 112, 236, 102, 252]) }, { traceIndex := 15, values := [1, 8, 0, 8, 0, 6, 0, 4294967295, 4294967295, 4294967289, 4294967295, 0, 0, 4294967289, 4294967295, 12, 0, 0, 0, 0, 0, 0, 0, 42, 42, 40, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], rowDigest := (bytes [145, 36, 190, 4, 173, 194, 171, 173, 47, 207, 70, 153, 179, 153, 223, 185, 56, 23, 135, 222, 66, 59, 50, 253, 80, 141, 40, 77, 100, 146, 76, 114]), digest := (bytes [88, 62, 98, 123, 155, 196, 19, 77, 251, 36, 182, 19, 199, 119, 196, 238, 212, 247, 69, 102, 239, 191, 3, 65, 54, 49, 68, 199, 8, 157, 188, 45]) }, { traceIndex := 16, values := [1, 8, 0, 8, 0, 4294967289, 4294967295, 1, 0, 4294967290, 4294967295, 0, 0, 4294967290, 4294967295, 12, 0, 0, 0, 0, 0, 0, 0, 40, 42, 41, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], rowDigest := (bytes [113, 51, 63, 193, 230, 90, 59, 142, 32, 108, 103, 13, 97, 35, 249, 64, 255, 46, 208, 13, 248, 56, 39, 188, 153, 240, 188, 242, 59, 120, 183, 232]), digest := (bytes [153, 190, 165, 237, 221, 129, 209, 122, 193, 244, 238, 77, 44, 186, 31, 85, 22, 233, 131, 76, 77, 7, 48, 203, 237, 145, 177, 68, 203, 200, 123, 110]) }, { traceIndex := 17, values := [1, 8, 0, 8, 0, 4294967290, 4294967295, 4294967289, 4294967295, 0, 0, 0, 0, 0, 0, 12, 0, 0, 0, 0, 0, 0, 0, 40, 40, 42, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], rowDigest := (bytes [234, 92, 237, 37, 179, 192, 51, 104, 221, 175, 14, 84, 63, 210, 32, 223, 55, 4, 66, 196, 79, 49, 196, 200, 85, 179, 24, 122, 66, 84, 31, 216]), digest := (bytes [195, 243, 133, 64, 105, 194, 248, 152, 40, 73, 123, 215, 88, 139, 41, 228, 68, 181, 42, 175, 171, 25, 157, 220, 61, 224, 83, 77, 218, 75, 146, 132]) }, { traceIndex := 18, values := [1, 8, 0, 12, 0, 4294967295, 4294967295, 0, 0, 4294967295, 4294967295, 0, 0, 4294967295, 4294967295, 12, 0, 0, 0, 0, 0, 0, 0, 9, 43, 40, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1], rowDigest := (bytes [233, 15, 162, 223, 44, 191, 195, 118, 252, 251, 108, 34, 223, 246, 189, 249, 229, 160, 187, 90, 230, 124, 90, 151, 226, 64, 211, 243, 182, 119, 203, 181]), digest := (bytes [49, 52, 40, 94, 178, 137, 120, 104, 78, 84, 211, 131, 246, 77, 156, 245, 22, 249, 123, 226, 36, 209, 17, 59, 37, 88, 25, 2, 73, 254, 124, 224]) }, { traceIndex := 19, values := [1, 12, 0, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [82, 160, 133, 135, 90, 74, 33, 242, 167, 29, 94, 199, 13, 129, 162, 84, 101, 207, 110, 195, 203, 13, 137, 237, 155, 115, 102, 78, 93, 59, 31, 37]), digest := (bytes [53, 156, 3, 202, 62, 80, 30, 254, 227, 185, 183, 114, 60, 229, 114, 88, 172, 197, 116, 170, 157, 169, 113, 77, 120, 250, 47, 150, 195, 59, 67, 192]) }]

def rootExecutionPreparedBindings : List PreparedStepBindingView :=
  [{ traceIndex := 0, rowDigest := (bytes [158, 63, 138, 206, 127, 145, 146, 109, 103, 153, 88, 114, 209, 198, 164, 199, 49, 182, 5, 151, 139, 25, 106, 81, 245, 88, 121, 14, 33, 120, 32, 196]), rowOpeningDigest := (bytes [176, 201, 107, 186, 67, 164, 205, 98, 198, 118, 96, 140, 24, 206, 27, 122, 43, 121, 3, 221, 245, 101, 16, 164, 108, 55, 16, 184, 60, 138, 164, 156]), digest := (bytes [16, 205, 233, 91, 190, 78, 83, 228, 90, 205, 244, 8, 169, 34, 193, 217, 30, 161, 98, 80, 83, 164, 76, 84, 87, 39, 184, 235, 149, 84, 113, 117]) }, { traceIndex := 1, rowDigest := (bytes [30, 68, 58, 84, 175, 11, 160, 249, 39, 145, 50, 95, 16, 212, 64, 78, 98, 42, 117, 222, 223, 194, 158, 145, 126, 125, 17, 23, 54, 138, 122, 80]), rowOpeningDigest := (bytes [206, 101, 112, 226, 38, 138, 239, 73, 187, 56, 159, 148, 15, 67, 157, 151, 163, 226, 147, 94, 52, 159, 223, 237, 26, 247, 48, 197, 21, 246, 5, 208]), digest := (bytes [150, 164, 162, 7, 225, 128, 111, 248, 86, 210, 88, 25, 126, 176, 65, 6, 89, 141, 88, 14, 1, 188, 64, 159, 55, 17, 4, 241, 152, 9, 15, 222]) }, { traceIndex := 2, rowDigest := (bytes [178, 44, 170, 123, 123, 27, 226, 112, 10, 219, 173, 190, 229, 37, 167, 135, 127, 196, 68, 7, 250, 125, 219, 32, 134, 127, 171, 216, 69, 106, 130, 156]), rowOpeningDigest := (bytes [145, 29, 31, 24, 136, 141, 50, 143, 234, 143, 94, 93, 180, 138, 139, 34, 22, 200, 79, 213, 109, 155, 117, 118, 14, 148, 182, 70, 196, 136, 156, 104]), digest := (bytes [202, 37, 153, 90, 230, 88, 139, 14, 100, 243, 240, 198, 141, 191, 135, 203, 59, 142, 75, 253, 174, 190, 7, 57, 150, 109, 96, 209, 110, 100, 68, 127]) }, { traceIndex := 3, rowDigest := (bytes [204, 89, 98, 191, 112, 54, 128, 12, 196, 231, 127, 23, 3, 143, 26, 215, 48, 236, 156, 165, 112, 21, 184, 57, 90, 7, 232, 66, 107, 229, 107, 45]), rowOpeningDigest := (bytes [200, 248, 214, 238, 193, 167, 231, 181, 116, 124, 244, 15, 253, 15, 54, 183, 187, 235, 175, 50, 177, 57, 161, 104, 189, 205, 132, 61, 63, 155, 67, 106]), digest := (bytes [42, 57, 236, 20, 246, 101, 71, 158, 170, 197, 107, 228, 206, 138, 236, 159, 174, 188, 86, 247, 174, 117, 0, 250, 155, 35, 115, 138, 10, 149, 180, 209]) }, { traceIndex := 4, rowDigest := (bytes [20, 207, 74, 15, 142, 67, 144, 245, 10, 60, 36, 62, 55, 250, 212, 231, 38, 9, 173, 154, 62, 190, 177, 127, 80, 19, 123, 179, 3, 254, 168, 237]), rowOpeningDigest := (bytes [242, 96, 148, 241, 207, 14, 155, 105, 152, 146, 238, 32, 187, 9, 91, 107, 85, 75, 221, 166, 100, 101, 49, 123, 82, 207, 45, 88, 156, 132, 6, 149]), digest := (bytes [236, 45, 161, 11, 2, 137, 122, 218, 107, 164, 246, 197, 218, 146, 237, 125, 31, 3, 121, 151, 131, 203, 35, 70, 96, 26, 181, 122, 155, 241, 193, 124]) }, { traceIndex := 5, rowDigest := (bytes [246, 16, 98, 215, 242, 223, 69, 56, 52, 163, 208, 255, 69, 200, 49, 90, 170, 121, 232, 125, 96, 209, 208, 167, 50, 195, 120, 1, 218, 43, 20, 220]), rowOpeningDigest := (bytes [16, 202, 200, 254, 82, 124, 55, 85, 102, 137, 0, 39, 76, 89, 214, 70, 48, 168, 133, 190, 115, 81, 72, 144, 238, 184, 102, 87, 9, 251, 92, 54]), digest := (bytes [229, 77, 208, 30, 93, 67, 91, 41, 221, 113, 53, 103, 92, 12, 127, 154, 228, 16, 26, 164, 33, 218, 154, 50, 20, 78, 246, 25, 86, 64, 96, 224]) }, { traceIndex := 6, rowDigest := (bytes [80, 52, 1, 224, 195, 53, 195, 155, 48, 141, 141, 133, 71, 70, 159, 185, 13, 131, 104, 77, 34, 74, 9, 167, 19, 18, 133, 45, 219, 55, 235, 84]), rowOpeningDigest := (bytes [118, 0, 98, 217, 19, 108, 36, 13, 185, 182, 241, 152, 77, 69, 48, 146, 171, 22, 237, 81, 238, 195, 12, 93, 244, 218, 100, 172, 220, 115, 197, 216]), digest := (bytes [25, 85, 98, 243, 190, 250, 13, 112, 190, 16, 241, 133, 71, 245, 233, 49, 232, 140, 12, 157, 126, 202, 140, 158, 194, 169, 238, 145, 221, 44, 162, 213]) }, { traceIndex := 7, rowDigest := (bytes [123, 74, 99, 234, 106, 3, 85, 168, 105, 77, 91, 143, 218, 79, 210, 129, 19, 31, 152, 60, 100, 233, 158, 198, 72, 104, 166, 142, 21, 2, 240, 28]), rowOpeningDigest := (bytes [55, 193, 201, 103, 72, 33, 137, 31, 63, 204, 97, 146, 57, 174, 206, 134, 114, 145, 170, 71, 194, 167, 47, 84, 239, 200, 117, 38, 132, 149, 20, 90]), digest := (bytes [148, 193, 2, 108, 252, 9, 154, 226, 147, 2, 122, 235, 99, 195, 22, 177, 231, 186, 105, 92, 141, 56, 74, 93, 53, 167, 161, 79, 57, 86, 123, 85]) }, { traceIndex := 8, rowDigest := (bytes [158, 217, 189, 162, 21, 24, 94, 106, 137, 77, 251, 203, 145, 76, 178, 60, 241, 147, 137, 185, 95, 104, 20, 85, 25, 151, 218, 90, 238, 207, 42, 103]), rowOpeningDigest := (bytes [155, 108, 141, 64, 155, 59, 9, 251, 53, 56, 205, 108, 138, 144, 156, 224, 142, 152, 160, 145, 196, 41, 188, 253, 216, 208, 149, 51, 230, 112, 214, 195]), digest := (bytes [53, 216, 135, 45, 14, 35, 255, 179, 171, 41, 32, 36, 249, 67, 158, 76, 174, 161, 98, 93, 212, 58, 140, 140, 134, 187, 98, 55, 245, 72, 237, 35]) }, { traceIndex := 9, rowDigest := (bytes [205, 194, 177, 93, 89, 23, 156, 62, 204, 14, 207, 248, 121, 190, 213, 168, 90, 140, 244, 199, 141, 65, 162, 39, 255, 0, 175, 238, 76, 119, 95, 65]), rowOpeningDigest := (bytes [211, 192, 147, 204, 14, 221, 41, 67, 255, 225, 146, 24, 109, 134, 225, 209, 18, 84, 120, 252, 158, 102, 69, 98, 47, 208, 251, 11, 74, 249, 125, 239]), digest := (bytes [111, 104, 76, 134, 51, 128, 7, 213, 0, 49, 2, 221, 30, 3, 97, 137, 5, 255, 115, 32, 241, 143, 91, 9, 215, 129, 20, 35, 85, 92, 199, 39]) }, { traceIndex := 10, rowDigest := (bytes [219, 37, 234, 30, 178, 217, 93, 96, 211, 218, 208, 49, 151, 47, 53, 233, 79, 13, 80, 7, 224, 100, 121, 131, 82, 7, 130, 105, 104, 91, 195, 76]), rowOpeningDigest := (bytes [205, 115, 198, 226, 205, 178, 245, 175, 236, 140, 156, 174, 71, 80, 203, 196, 139, 226, 144, 20, 216, 186, 21, 101, 27, 207, 30, 71, 255, 200, 223, 12]), digest := (bytes [128, 216, 46, 28, 166, 165, 213, 173, 67, 93, 91, 41, 17, 61, 2, 93, 24, 3, 252, 191, 66, 127, 215, 191, 245, 20, 181, 39, 96, 29, 244, 204]) }, { traceIndex := 11, rowDigest := (bytes [194, 37, 158, 198, 208, 202, 71, 136, 176, 37, 0, 223, 59, 9, 142, 153, 252, 35, 178, 52, 46, 240, 42, 180, 21, 37, 90, 134, 54, 168, 126, 49]), rowOpeningDigest := (bytes [124, 237, 204, 130, 56, 181, 75, 220, 126, 204, 25, 11, 59, 37, 50, 190, 25, 65, 87, 95, 37, 28, 12, 32, 134, 154, 32, 62, 186, 216, 88, 198]), digest := (bytes [66, 10, 68, 105, 176, 6, 81, 57, 159, 171, 235, 37, 164, 228, 24, 156, 219, 214, 155, 212, 144, 14, 175, 94, 122, 10, 20, 68, 133, 248, 145, 211]) }, { traceIndex := 12, rowDigest := (bytes [126, 195, 171, 232, 165, 194, 244, 162, 228, 241, 186, 102, 42, 82, 160, 178, 166, 244, 222, 45, 66, 223, 90, 55, 3, 213, 72, 102, 67, 249, 57, 132]), rowOpeningDigest := (bytes [101, 45, 174, 221, 36, 97, 164, 241, 79, 66, 179, 64, 214, 113, 7, 235, 249, 164, 189, 235, 229, 101, 0, 95, 90, 162, 42, 103, 188, 186, 1, 107]), digest := (bytes [213, 147, 190, 191, 234, 115, 82, 204, 203, 38, 47, 83, 250, 30, 164, 37, 54, 223, 158, 101, 130, 79, 247, 149, 175, 42, 218, 6, 119, 132, 137, 192]) }, { traceIndex := 13, rowDigest := (bytes [237, 11, 83, 137, 122, 187, 124, 63, 44, 245, 185, 225, 204, 82, 42, 232, 178, 182, 194, 117, 198, 78, 96, 182, 187, 52, 184, 225, 14, 177, 115, 98]), rowOpeningDigest := (bytes [3, 247, 123, 41, 242, 117, 183, 40, 98, 185, 149, 18, 226, 65, 43, 197, 82, 71, 223, 164, 203, 75, 204, 224, 33, 116, 35, 105, 71, 211, 81, 108]), digest := (bytes [88, 177, 99, 41, 131, 216, 173, 165, 68, 35, 101, 40, 107, 149, 32, 157, 214, 107, 240, 183, 0, 33, 213, 133, 141, 185, 124, 91, 25, 29, 48, 180]) }, { traceIndex := 14, rowDigest := (bytes [65, 147, 137, 59, 251, 191, 106, 251, 17, 251, 114, 249, 112, 47, 75, 125, 78, 168, 5, 212, 122, 91, 87, 187, 142, 229, 122, 134, 183, 238, 110, 158]), rowOpeningDigest := (bytes [182, 109, 196, 253, 227, 146, 78, 159, 162, 149, 125, 36, 120, 45, 165, 190, 61, 157, 187, 3, 17, 186, 116, 20, 202, 161, 212, 254, 253, 33, 212, 130]), digest := (bytes [167, 181, 116, 128, 98, 10, 113, 164, 78, 181, 67, 154, 200, 49, 60, 83, 104, 224, 61, 180, 76, 5, 237, 154, 166, 166, 153, 49, 117, 65, 124, 133]) }, { traceIndex := 15, rowDigest := (bytes [145, 36, 190, 4, 173, 194, 171, 173, 47, 207, 70, 153, 179, 153, 223, 185, 56, 23, 135, 222, 66, 59, 50, 253, 80, 141, 40, 77, 100, 146, 76, 114]), rowOpeningDigest := (bytes [147, 29, 77, 238, 221, 185, 22, 196, 130, 72, 114, 7, 122, 7, 222, 48, 69, 184, 76, 13, 150, 27, 221, 137, 223, 222, 46, 220, 3, 221, 253, 242]), digest := (bytes [18, 92, 76, 174, 17, 137, 253, 44, 113, 240, 241, 197, 228, 31, 92, 159, 228, 64, 20, 109, 6, 44, 27, 3, 236, 172, 119, 172, 62, 240, 196, 153]) }, { traceIndex := 16, rowDigest := (bytes [113, 51, 63, 193, 230, 90, 59, 142, 32, 108, 103, 13, 97, 35, 249, 64, 255, 46, 208, 13, 248, 56, 39, 188, 153, 240, 188, 242, 59, 120, 183, 232]), rowOpeningDigest := (bytes [213, 221, 135, 118, 86, 155, 141, 94, 169, 253, 64, 220, 7, 226, 186, 241, 216, 59, 228, 217, 46, 97, 52, 23, 250, 125, 5, 2, 105, 21, 186, 65]), digest := (bytes [43, 207, 150, 152, 158, 75, 134, 31, 137, 6, 143, 208, 184, 40, 93, 151, 151, 59, 3, 222, 32, 41, 90, 126, 37, 17, 10, 1, 49, 83, 114, 179]) }, { traceIndex := 17, rowDigest := (bytes [234, 92, 237, 37, 179, 192, 51, 104, 221, 175, 14, 84, 63, 210, 32, 223, 55, 4, 66, 196, 79, 49, 196, 200, 85, 179, 24, 122, 66, 84, 31, 216]), rowOpeningDigest := (bytes [44, 200, 238, 52, 39, 36, 235, 82, 79, 170, 175, 113, 189, 115, 244, 139, 220, 11, 119, 104, 91, 36, 144, 57, 84, 224, 114, 137, 165, 84, 224, 155]), digest := (bytes [45, 125, 208, 137, 59, 127, 149, 244, 0, 81, 180, 31, 124, 249, 107, 73, 16, 250, 236, 228, 245, 186, 14, 249, 40, 56, 223, 140, 238, 37, 202, 68]) }, { traceIndex := 18, rowDigest := (bytes [233, 15, 162, 223, 44, 191, 195, 118, 252, 251, 108, 34, 223, 246, 189, 249, 229, 160, 187, 90, 230, 124, 90, 151, 226, 64, 211, 243, 182, 119, 203, 181]), rowOpeningDigest := (bytes [84, 18, 223, 72, 229, 55, 101, 218, 119, 67, 205, 169, 113, 1, 149, 227, 1, 240, 233, 131, 84, 181, 55, 180, 136, 27, 75, 141, 63, 196, 163, 236]), digest := (bytes [241, 205, 183, 198, 7, 248, 2, 25, 167, 221, 163, 134, 160, 119, 162, 8, 30, 71, 190, 31, 39, 117, 21, 245, 152, 255, 194, 169, 164, 82, 154, 139]) }, { traceIndex := 19, rowDigest := (bytes [82, 160, 133, 135, 90, 74, 33, 242, 167, 29, 94, 199, 13, 129, 162, 84, 101, 207, 110, 195, 203, 13, 137, 237, 155, 115, 102, 78, 93, 59, 31, 37]), rowOpeningDigest := (bytes [166, 225, 149, 216, 78, 142, 12, 228, 37, 240, 55, 30, 144, 48, 78, 28, 229, 56, 186, 2, 231, 23, 50, 115, 64, 99, 154, 101, 186, 197, 100, 255]), digest := (bytes [112, 32, 157, 27, 87, 130, 44, 253, 88, 154, 107, 25, 133, 72, 79, 148, 9, 88, 139, 88, 112, 15, 73, 85, 17, 244, 208, 189, 245, 38, 28, 71]) }]

def rootExecutionRowChunkRoutes : List RowChunkRouteView :=
  [{ logicalIndex := 0, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 0, digest := (bytes [138, 198, 109, 126, 144, 82, 221, 43, 248, 202, 137, 103, 62, 226, 249, 152, 163, 187, 1, 254, 36, 33, 59, 16, 64, 166, 202, 8, 219, 57, 240, 59]) }, { logicalIndex := 1, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 1, digest := (bytes [44, 177, 82, 41, 218, 60, 100, 208, 26, 31, 151, 113, 109, 148, 57, 12, 223, 21, 76, 221, 70, 245, 191, 105, 57, 199, 8, 128, 181, 145, 89, 99]) }, { logicalIndex := 2, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 2, digest := (bytes [252, 248, 65, 24, 81, 241, 150, 170, 250, 116, 222, 30, 134, 191, 78, 195, 104, 119, 225, 210, 243, 186, 212, 107, 183, 31, 243, 201, 101, 148, 32, 72]) }, { logicalIndex := 3, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 3, digest := (bytes [244, 11, 162, 13, 59, 43, 232, 47, 228, 2, 70, 126, 95, 10, 57, 40, 46, 107, 197, 81, 97, 39, 185, 163, 93, 60, 5, 66, 7, 231, 199, 134]) }, { logicalIndex := 4, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 4, digest := (bytes [98, 247, 204, 83, 252, 219, 248, 73, 49, 206, 229, 79, 169, 242, 28, 56, 7, 100, 18, 197, 133, 200, 133, 20, 161, 230, 126, 175, 98, 0, 158, 25]) }, { logicalIndex := 5, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 5, digest := (bytes [108, 248, 244, 125, 120, 190, 11, 202, 47, 205, 44, 110, 48, 43, 171, 224, 142, 98, 82, 106, 183, 21, 141, 205, 208, 18, 234, 19, 43, 61, 139, 151]) }, { logicalIndex := 6, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 6, digest := (bytes [213, 163, 43, 1, 32, 112, 128, 155, 10, 34, 241, 205, 79, 46, 234, 45, 239, 83, 213, 254, 45, 65, 13, 152, 217, 78, 36, 105, 42, 193, 181, 13]) }, { logicalIndex := 7, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 7, digest := (bytes [199, 10, 5, 135, 58, 125, 195, 205, 65, 103, 137, 179, 210, 215, 124, 50, 45, 181, 46, 62, 43, 114, 240, 192, 142, 94, 31, 202, 153, 102, 209, 54]) }, { logicalIndex := 8, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 8, digest := (bytes [243, 104, 100, 66, 94, 61, 218, 185, 138, 159, 201, 38, 53, 64, 18, 187, 81, 105, 239, 11, 139, 137, 248, 62, 130, 187, 188, 172, 131, 72, 106, 73]) }, { logicalIndex := 9, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 9, digest := (bytes [11, 164, 4, 249, 84, 107, 210, 66, 134, 110, 223, 149, 172, 176, 94, 254, 45, 42, 247, 93, 171, 29, 160, 56, 115, 52, 76, 84, 241, 17, 162, 122]) }, { logicalIndex := 10, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 10, digest := (bytes [163, 19, 52, 250, 55, 230, 68, 230, 28, 108, 101, 226, 50, 126, 176, 29, 159, 73, 227, 92, 77, 232, 226, 141, 7, 245, 241, 158, 73, 79, 99, 112]) }, { logicalIndex := 11, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 11, digest := (bytes [115, 116, 77, 106, 67, 232, 252, 146, 254, 38, 128, 153, 91, 223, 186, 248, 84, 234, 139, 247, 166, 27, 192, 52, 214, 24, 163, 76, 113, 87, 73, 143]) }, { logicalIndex := 12, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 12, digest := (bytes [151, 66, 233, 32, 5, 102, 244, 23, 80, 146, 192, 205, 244, 38, 63, 33, 134, 114, 135, 193, 174, 45, 168, 58, 244, 117, 162, 37, 125, 67, 17, 62]) }, { logicalIndex := 13, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 13, digest := (bytes [41, 1, 15, 89, 18, 198, 149, 21, 97, 142, 177, 33, 73, 111, 64, 204, 143, 105, 217, 48, 102, 83, 246, 243, 173, 192, 38, 246, 224, 129, 45, 221]) }, { logicalIndex := 14, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 14, digest := (bytes [246, 114, 135, 161, 178, 53, 206, 202, 196, 23, 121, 2, 47, 67, 239, 255, 15, 108, 83, 19, 64, 41, 233, 11, 253, 188, 14, 168, 173, 26, 141, 186]) }, { logicalIndex := 15, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 15, digest := (bytes [79, 33, 106, 58, 58, 186, 35, 70, 104, 72, 32, 206, 250, 47, 17, 78, 164, 156, 202, 60, 4, 146, 2, 224, 119, 5, 201, 23, 142, 93, 70, 32]) }, { logicalIndex := 16, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 16, digest := (bytes [211, 34, 171, 22, 120, 105, 79, 121, 69, 20, 10, 127, 162, 66, 130, 188, 210, 78, 27, 72, 237, 50, 100, 77, 221, 113, 39, 105, 3, 213, 42, 194]) }, { logicalIndex := 17, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 17, digest := (bytes [60, 116, 47, 157, 204, 40, 115, 180, 217, 145, 21, 136, 79, 49, 254, 121, 95, 213, 49, 82, 223, 81, 194, 204, 134, 195, 0, 211, 19, 86, 61, 237]) }, { logicalIndex := 18, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 18, digest := (bytes [119, 226, 246, 158, 218, 188, 209, 157, 129, 189, 208, 34, 161, 104, 149, 56, 200, 191, 153, 38, 201, 203, 147, 192, 166, 54, 208, 235, 159, 89, 230, 186]) }, { logicalIndex := 19, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 19, digest := (bytes [36, 56, 152, 150, 197, 106, 152, 50, 184, 7, 202, 30, 2, 107, 151, 112, 42, 108, 53, 20, 127, 122, 215, 160, 56, 16, 143, 203, 177, 54, 117, 157]) }]

def rootExecutionRowLocalCcsAcceptance : List RootRowLocalCcsAcceptanceView :=
  [{ traceIndex := 0, logicalIndex := 0, rowDigest := (bytes [158, 63, 138, 206, 127, 145, 146, 109, 103, 153, 88, 114, 209, 198, 164, 199, 49, 182, 5, 151, 139, 25, 106, 81, 245, 88, 121, 14, 33, 120, 32, 196]), rowOpeningDigest := (bytes [176, 201, 107, 186, 67, 164, 205, 98, 198, 118, 96, 140, 24, 206, 27, 122, 43, 121, 3, 221, 245, 101, 16, 164, 108, 55, 16, 184, 60, 138, 164, 156]), preparedStepBindingDigest := (bytes [16, 205, 233, 91, 190, 78, 83, 228, 90, 205, 244, 8, 169, 34, 193, 217, 30, 161, 98, 80, 83, 164, 76, 84, 87, 39, 184, 235, 149, 84, 113, 117]), rowChunkRouteDigest := (bytes [138, 198, 109, 126, 144, 82, 221, 43, 248, 202, 137, 103, 62, 226, 249, 152, 163, 187, 1, 254, 36, 33, 59, 16, 64, 166, 202, 8, 219, 57, 240, 59]), publicStepDigest := (bytes [240, 46, 31, 196, 96, 151, 51, 144, 113, 37, 191, 136, 107, 59, 129, 235, 79, 196, 230, 119, 28, 149, 235, 245, 82, 231, 207, 227, 12, 182, 128, 217]), digest := (bytes [212, 5, 248, 192, 113, 22, 243, 180, 213, 80, 219, 180, 16, 96, 14, 166, 166, 12, 52, 2, 66, 146, 103, 131, 146, 124, 88, 183, 30, 0, 207, 93]) }, { traceIndex := 1, logicalIndex := 1, rowDigest := (bytes [30, 68, 58, 84, 175, 11, 160, 249, 39, 145, 50, 95, 16, 212, 64, 78, 98, 42, 117, 222, 223, 194, 158, 145, 126, 125, 17, 23, 54, 138, 122, 80]), rowOpeningDigest := (bytes [206, 101, 112, 226, 38, 138, 239, 73, 187, 56, 159, 148, 15, 67, 157, 151, 163, 226, 147, 94, 52, 159, 223, 237, 26, 247, 48, 197, 21, 246, 5, 208]), preparedStepBindingDigest := (bytes [150, 164, 162, 7, 225, 128, 111, 248, 86, 210, 88, 25, 126, 176, 65, 6, 89, 141, 88, 14, 1, 188, 64, 159, 55, 17, 4, 241, 152, 9, 15, 222]), rowChunkRouteDigest := (bytes [44, 177, 82, 41, 218, 60, 100, 208, 26, 31, 151, 113, 109, 148, 57, 12, 223, 21, 76, 221, 70, 245, 191, 105, 57, 199, 8, 128, 181, 145, 89, 99]), publicStepDigest := (bytes [198, 83, 28, 163, 107, 9, 21, 254, 0, 158, 245, 1, 237, 88, 183, 211, 122, 9, 86, 82, 185, 87, 196, 121, 6, 70, 86, 243, 249, 38, 196, 99]), digest := (bytes [29, 254, 159, 9, 39, 132, 102, 240, 52, 156, 58, 24, 243, 208, 155, 157, 189, 75, 201, 129, 40, 180, 95, 84, 174, 55, 157, 207, 207, 7, 163, 101]) }, { traceIndex := 2, logicalIndex := 2, rowDigest := (bytes [178, 44, 170, 123, 123, 27, 226, 112, 10, 219, 173, 190, 229, 37, 167, 135, 127, 196, 68, 7, 250, 125, 219, 32, 134, 127, 171, 216, 69, 106, 130, 156]), rowOpeningDigest := (bytes [145, 29, 31, 24, 136, 141, 50, 143, 234, 143, 94, 93, 180, 138, 139, 34, 22, 200, 79, 213, 109, 155, 117, 118, 14, 148, 182, 70, 196, 136, 156, 104]), preparedStepBindingDigest := (bytes [202, 37, 153, 90, 230, 88, 139, 14, 100, 243, 240, 198, 141, 191, 135, 203, 59, 142, 75, 253, 174, 190, 7, 57, 150, 109, 96, 209, 110, 100, 68, 127]), rowChunkRouteDigest := (bytes [252, 248, 65, 24, 81, 241, 150, 170, 250, 116, 222, 30, 134, 191, 78, 195, 104, 119, 225, 210, 243, 186, 212, 107, 183, 31, 243, 201, 101, 148, 32, 72]), publicStepDigest := (bytes [108, 232, 89, 87, 219, 161, 172, 113, 228, 94, 238, 0, 10, 52, 86, 36, 100, 224, 94, 53, 104, 116, 60, 246, 92, 225, 45, 64, 84, 228, 74, 144]), digest := (bytes [231, 180, 77, 184, 137, 49, 49, 141, 173, 188, 131, 30, 239, 224, 138, 74, 50, 106, 10, 98, 254, 31, 87, 95, 86, 199, 165, 214, 11, 189, 122, 66]) }, { traceIndex := 3, logicalIndex := 3, rowDigest := (bytes [204, 89, 98, 191, 112, 54, 128, 12, 196, 231, 127, 23, 3, 143, 26, 215, 48, 236, 156, 165, 112, 21, 184, 57, 90, 7, 232, 66, 107, 229, 107, 45]), rowOpeningDigest := (bytes [200, 248, 214, 238, 193, 167, 231, 181, 116, 124, 244, 15, 253, 15, 54, 183, 187, 235, 175, 50, 177, 57, 161, 104, 189, 205, 132, 61, 63, 155, 67, 106]), preparedStepBindingDigest := (bytes [42, 57, 236, 20, 246, 101, 71, 158, 170, 197, 107, 228, 206, 138, 236, 159, 174, 188, 86, 247, 174, 117, 0, 250, 155, 35, 115, 138, 10, 149, 180, 209]), rowChunkRouteDigest := (bytes [244, 11, 162, 13, 59, 43, 232, 47, 228, 2, 70, 126, 95, 10, 57, 40, 46, 107, 197, 81, 97, 39, 185, 163, 93, 60, 5, 66, 7, 231, 199, 134]), publicStepDigest := (bytes [174, 47, 238, 129, 225, 71, 46, 135, 222, 225, 136, 204, 68, 223, 94, 36, 10, 4, 238, 34, 159, 95, 156, 77, 97, 77, 113, 220, 42, 248, 199, 232]), digest := (bytes [184, 197, 251, 198, 10, 212, 76, 35, 149, 11, 102, 88, 182, 122, 110, 246, 83, 170, 172, 155, 155, 138, 10, 64, 114, 148, 211, 33, 164, 179, 255, 133]) }, { traceIndex := 4, logicalIndex := 4, rowDigest := (bytes [20, 207, 74, 15, 142, 67, 144, 245, 10, 60, 36, 62, 55, 250, 212, 231, 38, 9, 173, 154, 62, 190, 177, 127, 80, 19, 123, 179, 3, 254, 168, 237]), rowOpeningDigest := (bytes [242, 96, 148, 241, 207, 14, 155, 105, 152, 146, 238, 32, 187, 9, 91, 107, 85, 75, 221, 166, 100, 101, 49, 123, 82, 207, 45, 88, 156, 132, 6, 149]), preparedStepBindingDigest := (bytes [236, 45, 161, 11, 2, 137, 122, 218, 107, 164, 246, 197, 218, 146, 237, 125, 31, 3, 121, 151, 131, 203, 35, 70, 96, 26, 181, 122, 155, 241, 193, 124]), rowChunkRouteDigest := (bytes [98, 247, 204, 83, 252, 219, 248, 73, 49, 206, 229, 79, 169, 242, 28, 56, 7, 100, 18, 197, 133, 200, 133, 20, 161, 230, 126, 175, 98, 0, 158, 25]), publicStepDigest := (bytes [218, 242, 124, 215, 243, 93, 179, 240, 4, 247, 241, 65, 182, 156, 153, 12, 207, 75, 122, 167, 142, 217, 198, 112, 136, 47, 38, 245, 89, 92, 131, 165]), digest := (bytes [30, 133, 44, 77, 214, 30, 249, 239, 73, 253, 239, 80, 21, 25, 175, 91, 98, 10, 211, 11, 66, 154, 104, 84, 76, 86, 255, 223, 123, 52, 97, 251]) }, { traceIndex := 5, logicalIndex := 5, rowDigest := (bytes [246, 16, 98, 215, 242, 223, 69, 56, 52, 163, 208, 255, 69, 200, 49, 90, 170, 121, 232, 125, 96, 209, 208, 167, 50, 195, 120, 1, 218, 43, 20, 220]), rowOpeningDigest := (bytes [16, 202, 200, 254, 82, 124, 55, 85, 102, 137, 0, 39, 76, 89, 214, 70, 48, 168, 133, 190, 115, 81, 72, 144, 238, 184, 102, 87, 9, 251, 92, 54]), preparedStepBindingDigest := (bytes [229, 77, 208, 30, 93, 67, 91, 41, 221, 113, 53, 103, 92, 12, 127, 154, 228, 16, 26, 164, 33, 218, 154, 50, 20, 78, 246, 25, 86, 64, 96, 224]), rowChunkRouteDigest := (bytes [108, 248, 244, 125, 120, 190, 11, 202, 47, 205, 44, 110, 48, 43, 171, 224, 142, 98, 82, 106, 183, 21, 141, 205, 208, 18, 234, 19, 43, 61, 139, 151]), publicStepDigest := (bytes [88, 68, 79, 200, 246, 112, 167, 247, 52, 218, 242, 95, 165, 120, 193, 57, 238, 123, 255, 93, 135, 227, 86, 174, 38, 144, 90, 117, 117, 121, 167, 16]), digest := (bytes [222, 166, 183, 9, 154, 76, 218, 179, 176, 103, 62, 237, 99, 108, 91, 107, 78, 153, 65, 5, 102, 165, 181, 192, 7, 17, 207, 195, 228, 91, 75, 99]) }, { traceIndex := 6, logicalIndex := 6, rowDigest := (bytes [80, 52, 1, 224, 195, 53, 195, 155, 48, 141, 141, 133, 71, 70, 159, 185, 13, 131, 104, 77, 34, 74, 9, 167, 19, 18, 133, 45, 219, 55, 235, 84]), rowOpeningDigest := (bytes [118, 0, 98, 217, 19, 108, 36, 13, 185, 182, 241, 152, 77, 69, 48, 146, 171, 22, 237, 81, 238, 195, 12, 93, 244, 218, 100, 172, 220, 115, 197, 216]), preparedStepBindingDigest := (bytes [25, 85, 98, 243, 190, 250, 13, 112, 190, 16, 241, 133, 71, 245, 233, 49, 232, 140, 12, 157, 126, 202, 140, 158, 194, 169, 238, 145, 221, 44, 162, 213]), rowChunkRouteDigest := (bytes [213, 163, 43, 1, 32, 112, 128, 155, 10, 34, 241, 205, 79, 46, 234, 45, 239, 83, 213, 254, 45, 65, 13, 152, 217, 78, 36, 105, 42, 193, 181, 13]), publicStepDigest := (bytes [68, 162, 210, 187, 51, 84, 213, 52, 148, 62, 239, 229, 0, 143, 232, 51, 9, 40, 166, 161, 141, 107, 156, 126, 242, 2, 0, 37, 222, 98, 239, 240]), digest := (bytes [56, 251, 168, 204, 30, 118, 215, 71, 207, 141, 180, 15, 214, 59, 166, 251, 90, 167, 38, 105, 118, 161, 134, 165, 117, 227, 226, 53, 221, 178, 105, 192]) }, { traceIndex := 7, logicalIndex := 7, rowDigest := (bytes [123, 74, 99, 234, 106, 3, 85, 168, 105, 77, 91, 143, 218, 79, 210, 129, 19, 31, 152, 60, 100, 233, 158, 198, 72, 104, 166, 142, 21, 2, 240, 28]), rowOpeningDigest := (bytes [55, 193, 201, 103, 72, 33, 137, 31, 63, 204, 97, 146, 57, 174, 206, 134, 114, 145, 170, 71, 194, 167, 47, 84, 239, 200, 117, 38, 132, 149, 20, 90]), preparedStepBindingDigest := (bytes [148, 193, 2, 108, 252, 9, 154, 226, 147, 2, 122, 235, 99, 195, 22, 177, 231, 186, 105, 92, 141, 56, 74, 93, 53, 167, 161, 79, 57, 86, 123, 85]), rowChunkRouteDigest := (bytes [199, 10, 5, 135, 58, 125, 195, 205, 65, 103, 137, 179, 210, 215, 124, 50, 45, 181, 46, 62, 43, 114, 240, 192, 142, 94, 31, 202, 153, 102, 209, 54]), publicStepDigest := (bytes [56, 150, 110, 249, 76, 174, 14, 146, 14, 59, 122, 69, 143, 66, 249, 175, 29, 243, 139, 50, 170, 70, 130, 115, 180, 186, 54, 207, 13, 59, 146, 250]), digest := (bytes [40, 146, 79, 78, 11, 115, 86, 118, 128, 182, 212, 151, 168, 122, 161, 186, 109, 101, 147, 205, 53, 62, 226, 34, 2, 45, 204, 251, 229, 20, 69, 163]) }, { traceIndex := 8, logicalIndex := 8, rowDigest := (bytes [158, 217, 189, 162, 21, 24, 94, 106, 137, 77, 251, 203, 145, 76, 178, 60, 241, 147, 137, 185, 95, 104, 20, 85, 25, 151, 218, 90, 238, 207, 42, 103]), rowOpeningDigest := (bytes [155, 108, 141, 64, 155, 59, 9, 251, 53, 56, 205, 108, 138, 144, 156, 224, 142, 152, 160, 145, 196, 41, 188, 253, 216, 208, 149, 51, 230, 112, 214, 195]), preparedStepBindingDigest := (bytes [53, 216, 135, 45, 14, 35, 255, 179, 171, 41, 32, 36, 249, 67, 158, 76, 174, 161, 98, 93, 212, 58, 140, 140, 134, 187, 98, 55, 245, 72, 237, 35]), rowChunkRouteDigest := (bytes [243, 104, 100, 66, 94, 61, 218, 185, 138, 159, 201, 38, 53, 64, 18, 187, 81, 105, 239, 11, 139, 137, 248, 62, 130, 187, 188, 172, 131, 72, 106, 73]), publicStepDigest := (bytes [84, 52, 215, 50, 140, 25, 127, 112, 137, 82, 18, 190, 128, 242, 245, 1, 36, 93, 169, 62, 59, 88, 156, 159, 236, 45, 47, 189, 144, 52, 28, 173]), digest := (bytes [244, 137, 34, 51, 57, 211, 128, 119, 184, 100, 20, 69, 187, 57, 230, 131, 236, 115, 12, 162, 56, 218, 165, 136, 6, 20, 98, 45, 142, 109, 43, 68]) }, { traceIndex := 9, logicalIndex := 9, rowDigest := (bytes [205, 194, 177, 93, 89, 23, 156, 62, 204, 14, 207, 248, 121, 190, 213, 168, 90, 140, 244, 199, 141, 65, 162, 39, 255, 0, 175, 238, 76, 119, 95, 65]), rowOpeningDigest := (bytes [211, 192, 147, 204, 14, 221, 41, 67, 255, 225, 146, 24, 109, 134, 225, 209, 18, 84, 120, 252, 158, 102, 69, 98, 47, 208, 251, 11, 74, 249, 125, 239]), preparedStepBindingDigest := (bytes [111, 104, 76, 134, 51, 128, 7, 213, 0, 49, 2, 221, 30, 3, 97, 137, 5, 255, 115, 32, 241, 143, 91, 9, 215, 129, 20, 35, 85, 92, 199, 39]), rowChunkRouteDigest := (bytes [11, 164, 4, 249, 84, 107, 210, 66, 134, 110, 223, 149, 172, 176, 94, 254, 45, 42, 247, 93, 171, 29, 160, 56, 115, 52, 76, 84, 241, 17, 162, 122]), publicStepDigest := (bytes [151, 180, 170, 167, 123, 171, 194, 147, 84, 255, 252, 6, 147, 240, 54, 234, 69, 60, 89, 189, 39, 255, 160, 137, 210, 241, 194, 135, 32, 21, 110, 214]), digest := (bytes [129, 211, 165, 178, 184, 226, 141, 89, 22, 252, 145, 47, 69, 37, 214, 10, 249, 157, 11, 161, 230, 52, 230, 251, 60, 139, 16, 85, 35, 195, 169, 89]) }, { traceIndex := 10, logicalIndex := 10, rowDigest := (bytes [219, 37, 234, 30, 178, 217, 93, 96, 211, 218, 208, 49, 151, 47, 53, 233, 79, 13, 80, 7, 224, 100, 121, 131, 82, 7, 130, 105, 104, 91, 195, 76]), rowOpeningDigest := (bytes [205, 115, 198, 226, 205, 178, 245, 175, 236, 140, 156, 174, 71, 80, 203, 196, 139, 226, 144, 20, 216, 186, 21, 101, 27, 207, 30, 71, 255, 200, 223, 12]), preparedStepBindingDigest := (bytes [128, 216, 46, 28, 166, 165, 213, 173, 67, 93, 91, 41, 17, 61, 2, 93, 24, 3, 252, 191, 66, 127, 215, 191, 245, 20, 181, 39, 96, 29, 244, 204]), rowChunkRouteDigest := (bytes [163, 19, 52, 250, 55, 230, 68, 230, 28, 108, 101, 226, 50, 126, 176, 29, 159, 73, 227, 92, 77, 232, 226, 141, 7, 245, 241, 158, 73, 79, 99, 112]), publicStepDigest := (bytes [210, 170, 39, 51, 59, 34, 200, 68, 27, 200, 15, 212, 56, 19, 152, 103, 82, 236, 42, 48, 218, 47, 17, 240, 235, 225, 57, 70, 117, 209, 12, 240]), digest := (bytes [77, 137, 36, 40, 245, 230, 70, 12, 133, 36, 59, 15, 158, 109, 149, 178, 187, 112, 89, 178, 249, 138, 84, 173, 192, 229, 148, 21, 231, 199, 72, 80]) }, { traceIndex := 11, logicalIndex := 11, rowDigest := (bytes [194, 37, 158, 198, 208, 202, 71, 136, 176, 37, 0, 223, 59, 9, 142, 153, 252, 35, 178, 52, 46, 240, 42, 180, 21, 37, 90, 134, 54, 168, 126, 49]), rowOpeningDigest := (bytes [124, 237, 204, 130, 56, 181, 75, 220, 126, 204, 25, 11, 59, 37, 50, 190, 25, 65, 87, 95, 37, 28, 12, 32, 134, 154, 32, 62, 186, 216, 88, 198]), preparedStepBindingDigest := (bytes [66, 10, 68, 105, 176, 6, 81, 57, 159, 171, 235, 37, 164, 228, 24, 156, 219, 214, 155, 212, 144, 14, 175, 94, 122, 10, 20, 68, 133, 248, 145, 211]), rowChunkRouteDigest := (bytes [115, 116, 77, 106, 67, 232, 252, 146, 254, 38, 128, 153, 91, 223, 186, 248, 84, 234, 139, 247, 166, 27, 192, 52, 214, 24, 163, 76, 113, 87, 73, 143]), publicStepDigest := (bytes [32, 172, 108, 15, 208, 47, 194, 209, 63, 249, 125, 112, 52, 47, 131, 155, 246, 110, 27, 189, 141, 1, 112, 149, 179, 215, 143, 167, 192, 138, 90, 8]), digest := (bytes [227, 6, 135, 82, 152, 95, 37, 149, 89, 204, 124, 213, 168, 149, 115, 169, 97, 30, 171, 102, 35, 120, 97, 27, 212, 225, 3, 81, 97, 186, 5, 11]) }, { traceIndex := 12, logicalIndex := 12, rowDigest := (bytes [126, 195, 171, 232, 165, 194, 244, 162, 228, 241, 186, 102, 42, 82, 160, 178, 166, 244, 222, 45, 66, 223, 90, 55, 3, 213, 72, 102, 67, 249, 57, 132]), rowOpeningDigest := (bytes [101, 45, 174, 221, 36, 97, 164, 241, 79, 66, 179, 64, 214, 113, 7, 235, 249, 164, 189, 235, 229, 101, 0, 95, 90, 162, 42, 103, 188, 186, 1, 107]), preparedStepBindingDigest := (bytes [213, 147, 190, 191, 234, 115, 82, 204, 203, 38, 47, 83, 250, 30, 164, 37, 54, 223, 158, 101, 130, 79, 247, 149, 175, 42, 218, 6, 119, 132, 137, 192]), rowChunkRouteDigest := (bytes [151, 66, 233, 32, 5, 102, 244, 23, 80, 146, 192, 205, 244, 38, 63, 33, 134, 114, 135, 193, 174, 45, 168, 58, 244, 117, 162, 37, 125, 67, 17, 62]), publicStepDigest := (bytes [15, 174, 95, 74, 41, 91, 168, 67, 2, 95, 235, 34, 250, 196, 203, 64, 180, 142, 139, 180, 167, 89, 241, 155, 246, 40, 107, 18, 142, 208, 61, 66]), digest := (bytes [81, 47, 158, 193, 6, 208, 47, 128, 114, 165, 196, 57, 243, 87, 140, 59, 42, 141, 231, 133, 50, 176, 68, 206, 10, 85, 85, 148, 194, 203, 171, 226]) }, { traceIndex := 13, logicalIndex := 13, rowDigest := (bytes [237, 11, 83, 137, 122, 187, 124, 63, 44, 245, 185, 225, 204, 82, 42, 232, 178, 182, 194, 117, 198, 78, 96, 182, 187, 52, 184, 225, 14, 177, 115, 98]), rowOpeningDigest := (bytes [3, 247, 123, 41, 242, 117, 183, 40, 98, 185, 149, 18, 226, 65, 43, 197, 82, 71, 223, 164, 203, 75, 204, 224, 33, 116, 35, 105, 71, 211, 81, 108]), preparedStepBindingDigest := (bytes [88, 177, 99, 41, 131, 216, 173, 165, 68, 35, 101, 40, 107, 149, 32, 157, 214, 107, 240, 183, 0, 33, 213, 133, 141, 185, 124, 91, 25, 29, 48, 180]), rowChunkRouteDigest := (bytes [41, 1, 15, 89, 18, 198, 149, 21, 97, 142, 177, 33, 73, 111, 64, 204, 143, 105, 217, 48, 102, 83, 246, 243, 173, 192, 38, 246, 224, 129, 45, 221]), publicStepDigest := (bytes [164, 207, 77, 18, 54, 177, 150, 247, 187, 34, 32, 240, 224, 216, 112, 143, 100, 19, 147, 77, 84, 234, 22, 211, 62, 229, 211, 94, 82, 168, 181, 197]), digest := (bytes [89, 183, 155, 103, 8, 29, 6, 121, 220, 199, 243, 218, 0, 45, 51, 232, 177, 247, 112, 197, 220, 132, 125, 137, 118, 132, 29, 28, 111, 101, 11, 151]) }, { traceIndex := 14, logicalIndex := 14, rowDigest := (bytes [65, 147, 137, 59, 251, 191, 106, 251, 17, 251, 114, 249, 112, 47, 75, 125, 78, 168, 5, 212, 122, 91, 87, 187, 142, 229, 122, 134, 183, 238, 110, 158]), rowOpeningDigest := (bytes [182, 109, 196, 253, 227, 146, 78, 159, 162, 149, 125, 36, 120, 45, 165, 190, 61, 157, 187, 3, 17, 186, 116, 20, 202, 161, 212, 254, 253, 33, 212, 130]), preparedStepBindingDigest := (bytes [167, 181, 116, 128, 98, 10, 113, 164, 78, 181, 67, 154, 200, 49, 60, 83, 104, 224, 61, 180, 76, 5, 237, 154, 166, 166, 153, 49, 117, 65, 124, 133]), rowChunkRouteDigest := (bytes [246, 114, 135, 161, 178, 53, 206, 202, 196, 23, 121, 2, 47, 67, 239, 255, 15, 108, 83, 19, 64, 41, 233, 11, 253, 188, 14, 168, 173, 26, 141, 186]), publicStepDigest := (bytes [153, 11, 161, 124, 199, 12, 122, 193, 74, 44, 184, 254, 229, 183, 125, 136, 228, 241, 27, 20, 189, 90, 203, 75, 84, 49, 202, 34, 201, 170, 176, 121]), digest := (bytes [157, 164, 41, 254, 213, 226, 18, 73, 28, 103, 121, 80, 197, 253, 151, 50, 183, 150, 133, 178, 226, 170, 120, 244, 168, 16, 176, 163, 241, 80, 89, 58]) }, { traceIndex := 15, logicalIndex := 15, rowDigest := (bytes [145, 36, 190, 4, 173, 194, 171, 173, 47, 207, 70, 153, 179, 153, 223, 185, 56, 23, 135, 222, 66, 59, 50, 253, 80, 141, 40, 77, 100, 146, 76, 114]), rowOpeningDigest := (bytes [147, 29, 77, 238, 221, 185, 22, 196, 130, 72, 114, 7, 122, 7, 222, 48, 69, 184, 76, 13, 150, 27, 221, 137, 223, 222, 46, 220, 3, 221, 253, 242]), preparedStepBindingDigest := (bytes [18, 92, 76, 174, 17, 137, 253, 44, 113, 240, 241, 197, 228, 31, 92, 159, 228, 64, 20, 109, 6, 44, 27, 3, 236, 172, 119, 172, 62, 240, 196, 153]), rowChunkRouteDigest := (bytes [79, 33, 106, 58, 58, 186, 35, 70, 104, 72, 32, 206, 250, 47, 17, 78, 164, 156, 202, 60, 4, 146, 2, 224, 119, 5, 201, 23, 142, 93, 70, 32]), publicStepDigest := (bytes [219, 53, 10, 149, 67, 177, 61, 169, 201, 154, 153, 177, 127, 226, 122, 116, 149, 40, 225, 216, 50, 248, 151, 156, 200, 186, 238, 44, 108, 203, 183, 9]), digest := (bytes [95, 51, 67, 81, 73, 96, 192, 38, 159, 68, 53, 65, 23, 137, 203, 28, 99, 57, 127, 197, 28, 150, 68, 107, 152, 73, 81, 150, 245, 125, 168, 135]) }, { traceIndex := 16, logicalIndex := 16, rowDigest := (bytes [113, 51, 63, 193, 230, 90, 59, 142, 32, 108, 103, 13, 97, 35, 249, 64, 255, 46, 208, 13, 248, 56, 39, 188, 153, 240, 188, 242, 59, 120, 183, 232]), rowOpeningDigest := (bytes [213, 221, 135, 118, 86, 155, 141, 94, 169, 253, 64, 220, 7, 226, 186, 241, 216, 59, 228, 217, 46, 97, 52, 23, 250, 125, 5, 2, 105, 21, 186, 65]), preparedStepBindingDigest := (bytes [43, 207, 150, 152, 158, 75, 134, 31, 137, 6, 143, 208, 184, 40, 93, 151, 151, 59, 3, 222, 32, 41, 90, 126, 37, 17, 10, 1, 49, 83, 114, 179]), rowChunkRouteDigest := (bytes [211, 34, 171, 22, 120, 105, 79, 121, 69, 20, 10, 127, 162, 66, 130, 188, 210, 78, 27, 72, 237, 50, 100, 77, 221, 113, 39, 105, 3, 213, 42, 194]), publicStepDigest := (bytes [91, 20, 112, 78, 184, 123, 178, 65, 67, 79, 41, 91, 158, 240, 176, 211, 42, 252, 57, 72, 222, 83, 165, 13, 101, 218, 60, 89, 41, 13, 182, 133]), digest := (bytes [187, 219, 226, 37, 12, 71, 215, 4, 223, 128, 194, 4, 37, 199, 30, 62, 247, 40, 154, 169, 215, 205, 237, 74, 115, 10, 83, 215, 7, 63, 178, 63]) }, { traceIndex := 17, logicalIndex := 17, rowDigest := (bytes [234, 92, 237, 37, 179, 192, 51, 104, 221, 175, 14, 84, 63, 210, 32, 223, 55, 4, 66, 196, 79, 49, 196, 200, 85, 179, 24, 122, 66, 84, 31, 216]), rowOpeningDigest := (bytes [44, 200, 238, 52, 39, 36, 235, 82, 79, 170, 175, 113, 189, 115, 244, 139, 220, 11, 119, 104, 91, 36, 144, 57, 84, 224, 114, 137, 165, 84, 224, 155]), preparedStepBindingDigest := (bytes [45, 125, 208, 137, 59, 127, 149, 244, 0, 81, 180, 31, 124, 249, 107, 73, 16, 250, 236, 228, 245, 186, 14, 249, 40, 56, 223, 140, 238, 37, 202, 68]), rowChunkRouteDigest := (bytes [60, 116, 47, 157, 204, 40, 115, 180, 217, 145, 21, 136, 79, 49, 254, 121, 95, 213, 49, 82, 223, 81, 194, 204, 134, 195, 0, 211, 19, 86, 61, 237]), publicStepDigest := (bytes [3, 71, 173, 5, 248, 3, 124, 9, 68, 11, 12, 17, 175, 158, 219, 80, 156, 195, 156, 120, 195, 108, 203, 4, 4, 59, 3, 84, 137, 138, 184, 114]), digest := (bytes [127, 69, 85, 218, 199, 143, 124, 130, 159, 164, 141, 231, 169, 39, 29, 198, 240, 232, 114, 187, 199, 195, 177, 244, 74, 65, 194, 6, 6, 152, 129, 93]) }, { traceIndex := 18, logicalIndex := 18, rowDigest := (bytes [233, 15, 162, 223, 44, 191, 195, 118, 252, 251, 108, 34, 223, 246, 189, 249, 229, 160, 187, 90, 230, 124, 90, 151, 226, 64, 211, 243, 182, 119, 203, 181]), rowOpeningDigest := (bytes [84, 18, 223, 72, 229, 55, 101, 218, 119, 67, 205, 169, 113, 1, 149, 227, 1, 240, 233, 131, 84, 181, 55, 180, 136, 27, 75, 141, 63, 196, 163, 236]), preparedStepBindingDigest := (bytes [241, 205, 183, 198, 7, 248, 2, 25, 167, 221, 163, 134, 160, 119, 162, 8, 30, 71, 190, 31, 39, 117, 21, 245, 152, 255, 194, 169, 164, 82, 154, 139]), rowChunkRouteDigest := (bytes [119, 226, 246, 158, 218, 188, 209, 157, 129, 189, 208, 34, 161, 104, 149, 56, 200, 191, 153, 38, 201, 203, 147, 192, 166, 54, 208, 235, 159, 89, 230, 186]), publicStepDigest := (bytes [168, 186, 173, 189, 232, 242, 27, 84, 57, 205, 172, 157, 65, 255, 8, 199, 183, 182, 242, 232, 77, 18, 42, 32, 134, 204, 3, 50, 116, 32, 182, 125]), digest := (bytes [223, 155, 254, 234, 64, 58, 123, 113, 249, 108, 98, 162, 40, 7, 84, 103, 138, 10, 139, 232, 86, 196, 4, 230, 185, 234, 64, 216, 205, 100, 47, 55]) }, { traceIndex := 19, logicalIndex := 19, rowDigest := (bytes [82, 160, 133, 135, 90, 74, 33, 242, 167, 29, 94, 199, 13, 129, 162, 84, 101, 207, 110, 195, 203, 13, 137, 237, 155, 115, 102, 78, 93, 59, 31, 37]), rowOpeningDigest := (bytes [166, 225, 149, 216, 78, 142, 12, 228, 37, 240, 55, 30, 144, 48, 78, 28, 229, 56, 186, 2, 231, 23, 50, 115, 64, 99, 154, 101, 186, 197, 100, 255]), preparedStepBindingDigest := (bytes [112, 32, 157, 27, 87, 130, 44, 253, 88, 154, 107, 25, 133, 72, 79, 148, 9, 88, 139, 88, 112, 15, 73, 85, 17, 244, 208, 189, 245, 38, 28, 71]), rowChunkRouteDigest := (bytes [36, 56, 152, 150, 197, 106, 152, 50, 184, 7, 202, 30, 2, 107, 151, 112, 42, 108, 53, 20, 127, 122, 215, 160, 56, 16, 143, 203, 177, 54, 117, 157]), publicStepDigest := (bytes [106, 128, 173, 45, 66, 12, 245, 212, 146, 133, 54, 235, 234, 174, 115, 65, 99, 113, 64, 14, 129, 86, 252, 254, 141, 194, 222, 200, 174, 15, 131, 63]), digest := (bytes [85, 117, 55, 102, 240, 131, 63, 232, 189, 240, 188, 138, 33, 136, 122, 101, 69, 221, 16, 191, 165, 169, 118, 2, 87, 170, 4, 14, 89, 50, 4, 175]) }]

def rootExecutionExecutionSemanticsRefinement : List RootExecutionSemanticsRefinementView :=
  [{ traceIndex := 0, logicalIndex := 0, semanticRowDigest := (bytes [25, 205, 150, 160, 178, 102, 166, 186, 246, 174, 205, 130, 40, 51, 62, 134, 37, 1, 15, 182, 103, 238, 174, 17, 68, 143, 26, 72, 174, 144, 228, 71]), rowLocalCcsAcceptanceDigest := (bytes [212, 5, 248, 192, 113, 22, 243, 180, 213, 80, 219, 180, 16, 96, 14, 166, 166, 12, 52, 2, 66, 146, 103, 131, 146, 124, 88, 183, 30, 0, 207, 93]), preparedStepBindingDigest := (bytes [16, 205, 233, 91, 190, 78, 83, 228, 90, 205, 244, 8, 169, 34, 193, 217, 30, 161, 98, 80, 83, 164, 76, 84, 87, 39, 184, 235, 149, 84, 113, 117]), publicStepDigest := (bytes [240, 46, 31, 196, 96, 151, 51, 144, 113, 37, 191, 136, 107, 59, 129, 235, 79, 196, 230, 119, 28, 149, 235, 245, 82, 231, 207, 227, 12, 182, 128, 217]), digest := (bytes [147, 213, 63, 116, 232, 91, 226, 177, 76, 155, 129, 162, 191, 255, 215, 45, 3, 117, 91, 7, 121, 242, 86, 88, 219, 114, 250, 49, 200, 93, 157, 231]) }, { traceIndex := 1, logicalIndex := 1, semanticRowDigest := (bytes [47, 203, 55, 160, 32, 200, 70, 137, 205, 91, 223, 43, 238, 148, 104, 115, 87, 4, 97, 88, 6, 138, 86, 28, 191, 190, 74, 22, 46, 109, 45, 28]), rowLocalCcsAcceptanceDigest := (bytes [29, 254, 159, 9, 39, 132, 102, 240, 52, 156, 58, 24, 243, 208, 155, 157, 189, 75, 201, 129, 40, 180, 95, 84, 174, 55, 157, 207, 207, 7, 163, 101]), preparedStepBindingDigest := (bytes [150, 164, 162, 7, 225, 128, 111, 248, 86, 210, 88, 25, 126, 176, 65, 6, 89, 141, 88, 14, 1, 188, 64, 159, 55, 17, 4, 241, 152, 9, 15, 222]), publicStepDigest := (bytes [198, 83, 28, 163, 107, 9, 21, 254, 0, 158, 245, 1, 237, 88, 183, 211, 122, 9, 86, 82, 185, 87, 196, 121, 6, 70, 86, 243, 249, 38, 196, 99]), digest := (bytes [96, 20, 47, 91, 157, 116, 199, 166, 178, 198, 227, 144, 182, 29, 170, 209, 82, 6, 27, 85, 229, 13, 244, 165, 175, 41, 18, 168, 47, 222, 46, 10]) }, { traceIndex := 2, logicalIndex := 2, semanticRowDigest := (bytes [84, 29, 185, 47, 225, 75, 171, 219, 35, 80, 85, 250, 190, 141, 152, 131, 254, 116, 201, 41, 138, 30, 137, 4, 231, 133, 56, 206, 54, 98, 101, 159]), rowLocalCcsAcceptanceDigest := (bytes [231, 180, 77, 184, 137, 49, 49, 141, 173, 188, 131, 30, 239, 224, 138, 74, 50, 106, 10, 98, 254, 31, 87, 95, 86, 199, 165, 214, 11, 189, 122, 66]), preparedStepBindingDigest := (bytes [202, 37, 153, 90, 230, 88, 139, 14, 100, 243, 240, 198, 141, 191, 135, 203, 59, 142, 75, 253, 174, 190, 7, 57, 150, 109, 96, 209, 110, 100, 68, 127]), publicStepDigest := (bytes [108, 232, 89, 87, 219, 161, 172, 113, 228, 94, 238, 0, 10, 52, 86, 36, 100, 224, 94, 53, 104, 116, 60, 246, 92, 225, 45, 64, 84, 228, 74, 144]), digest := (bytes [166, 220, 183, 162, 84, 81, 90, 195, 218, 171, 97, 79, 111, 95, 110, 16, 38, 252, 15, 75, 4, 37, 54, 83, 164, 66, 64, 101, 224, 158, 66, 254]) }, { traceIndex := 3, logicalIndex := 3, semanticRowDigest := (bytes [57, 57, 112, 124, 93, 25, 155, 6, 125, 18, 253, 179, 142, 49, 42, 240, 241, 164, 207, 129, 149, 21, 122, 4, 81, 54, 179, 169, 103, 128, 111, 0]), rowLocalCcsAcceptanceDigest := (bytes [184, 197, 251, 198, 10, 212, 76, 35, 149, 11, 102, 88, 182, 122, 110, 246, 83, 170, 172, 155, 155, 138, 10, 64, 114, 148, 211, 33, 164, 179, 255, 133]), preparedStepBindingDigest := (bytes [42, 57, 236, 20, 246, 101, 71, 158, 170, 197, 107, 228, 206, 138, 236, 159, 174, 188, 86, 247, 174, 117, 0, 250, 155, 35, 115, 138, 10, 149, 180, 209]), publicStepDigest := (bytes [174, 47, 238, 129, 225, 71, 46, 135, 222, 225, 136, 204, 68, 223, 94, 36, 10, 4, 238, 34, 159, 95, 156, 77, 97, 77, 113, 220, 42, 248, 199, 232]), digest := (bytes [224, 51, 175, 205, 188, 63, 130, 160, 72, 165, 35, 124, 134, 198, 190, 172, 137, 139, 224, 94, 168, 61, 109, 77, 95, 28, 90, 203, 101, 207, 142, 68]) }, { traceIndex := 4, logicalIndex := 4, semanticRowDigest := (bytes [206, 26, 107, 178, 125, 131, 254, 175, 50, 56, 194, 134, 84, 84, 142, 25, 138, 250, 27, 100, 135, 208, 47, 163, 86, 11, 8, 200, 149, 157, 92, 50]), rowLocalCcsAcceptanceDigest := (bytes [30, 133, 44, 77, 214, 30, 249, 239, 73, 253, 239, 80, 21, 25, 175, 91, 98, 10, 211, 11, 66, 154, 104, 84, 76, 86, 255, 223, 123, 52, 97, 251]), preparedStepBindingDigest := (bytes [236, 45, 161, 11, 2, 137, 122, 218, 107, 164, 246, 197, 218, 146, 237, 125, 31, 3, 121, 151, 131, 203, 35, 70, 96, 26, 181, 122, 155, 241, 193, 124]), publicStepDigest := (bytes [218, 242, 124, 215, 243, 93, 179, 240, 4, 247, 241, 65, 182, 156, 153, 12, 207, 75, 122, 167, 142, 217, 198, 112, 136, 47, 38, 245, 89, 92, 131, 165]), digest := (bytes [41, 111, 123, 6, 219, 115, 200, 106, 184, 95, 136, 252, 87, 227, 225, 79, 142, 87, 27, 140, 101, 219, 84, 175, 84, 33, 172, 41, 151, 75, 55, 42]) }, { traceIndex := 5, logicalIndex := 5, semanticRowDigest := (bytes [2, 15, 209, 249, 178, 201, 5, 129, 220, 23, 199, 2, 65, 40, 141, 57, 99, 175, 26, 99, 80, 51, 143, 9, 129, 193, 169, 255, 40, 138, 254, 221]), rowLocalCcsAcceptanceDigest := (bytes [222, 166, 183, 9, 154, 76, 218, 179, 176, 103, 62, 237, 99, 108, 91, 107, 78, 153, 65, 5, 102, 165, 181, 192, 7, 17, 207, 195, 228, 91, 75, 99]), preparedStepBindingDigest := (bytes [229, 77, 208, 30, 93, 67, 91, 41, 221, 113, 53, 103, 92, 12, 127, 154, 228, 16, 26, 164, 33, 218, 154, 50, 20, 78, 246, 25, 86, 64, 96, 224]), publicStepDigest := (bytes [88, 68, 79, 200, 246, 112, 167, 247, 52, 218, 242, 95, 165, 120, 193, 57, 238, 123, 255, 93, 135, 227, 86, 174, 38, 144, 90, 117, 117, 121, 167, 16]), digest := (bytes [88, 8, 253, 65, 130, 2, 216, 179, 225, 178, 78, 249, 75, 45, 149, 15, 216, 54, 130, 113, 122, 203, 71, 121, 41, 181, 3, 81, 149, 101, 43, 143]) }, { traceIndex := 6, logicalIndex := 6, semanticRowDigest := (bytes [244, 6, 228, 191, 173, 198, 180, 154, 233, 137, 182, 252, 205, 112, 107, 149, 152, 251, 14, 61, 62, 76, 170, 236, 203, 12, 96, 182, 198, 101, 16, 1]), rowLocalCcsAcceptanceDigest := (bytes [56, 251, 168, 204, 30, 118, 215, 71, 207, 141, 180, 15, 214, 59, 166, 251, 90, 167, 38, 105, 118, 161, 134, 165, 117, 227, 226, 53, 221, 178, 105, 192]), preparedStepBindingDigest := (bytes [25, 85, 98, 243, 190, 250, 13, 112, 190, 16, 241, 133, 71, 245, 233, 49, 232, 140, 12, 157, 126, 202, 140, 158, 194, 169, 238, 145, 221, 44, 162, 213]), publicStepDigest := (bytes [68, 162, 210, 187, 51, 84, 213, 52, 148, 62, 239, 229, 0, 143, 232, 51, 9, 40, 166, 161, 141, 107, 156, 126, 242, 2, 0, 37, 222, 98, 239, 240]), digest := (bytes [110, 172, 246, 187, 242, 18, 107, 209, 104, 213, 36, 48, 100, 80, 103, 229, 13, 114, 45, 1, 29, 47, 121, 54, 20, 96, 189, 28, 103, 184, 62, 21]) }, { traceIndex := 7, logicalIndex := 7, semanticRowDigest := (bytes [190, 212, 56, 166, 190, 157, 5, 119, 143, 202, 81, 172, 233, 51, 144, 63, 243, 93, 192, 12, 21, 201, 138, 79, 67, 248, 245, 166, 249, 32, 192, 143]), rowLocalCcsAcceptanceDigest := (bytes [40, 146, 79, 78, 11, 115, 86, 118, 128, 182, 212, 151, 168, 122, 161, 186, 109, 101, 147, 205, 53, 62, 226, 34, 2, 45, 204, 251, 229, 20, 69, 163]), preparedStepBindingDigest := (bytes [148, 193, 2, 108, 252, 9, 154, 226, 147, 2, 122, 235, 99, 195, 22, 177, 231, 186, 105, 92, 141, 56, 74, 93, 53, 167, 161, 79, 57, 86, 123, 85]), publicStepDigest := (bytes [56, 150, 110, 249, 76, 174, 14, 146, 14, 59, 122, 69, 143, 66, 249, 175, 29, 243, 139, 50, 170, 70, 130, 115, 180, 186, 54, 207, 13, 59, 146, 250]), digest := (bytes [201, 27, 5, 6, 172, 231, 81, 83, 146, 214, 23, 245, 97, 187, 183, 246, 26, 132, 137, 15, 44, 82, 176, 81, 222, 81, 185, 160, 216, 212, 170, 242]) }, { traceIndex := 8, logicalIndex := 8, semanticRowDigest := (bytes [11, 119, 15, 129, 60, 245, 142, 222, 64, 205, 20, 207, 97, 240, 98, 144, 221, 12, 161, 22, 197, 221, 71, 180, 134, 45, 232, 208, 83, 24, 18, 96]), rowLocalCcsAcceptanceDigest := (bytes [244, 137, 34, 51, 57, 211, 128, 119, 184, 100, 20, 69, 187, 57, 230, 131, 236, 115, 12, 162, 56, 218, 165, 136, 6, 20, 98, 45, 142, 109, 43, 68]), preparedStepBindingDigest := (bytes [53, 216, 135, 45, 14, 35, 255, 179, 171, 41, 32, 36, 249, 67, 158, 76, 174, 161, 98, 93, 212, 58, 140, 140, 134, 187, 98, 55, 245, 72, 237, 35]), publicStepDigest := (bytes [84, 52, 215, 50, 140, 25, 127, 112, 137, 82, 18, 190, 128, 242, 245, 1, 36, 93, 169, 62, 59, 88, 156, 159, 236, 45, 47, 189, 144, 52, 28, 173]), digest := (bytes [159, 230, 162, 36, 203, 33, 230, 115, 184, 180, 147, 110, 63, 20, 214, 156, 68, 193, 56, 64, 136, 133, 199, 182, 68, 124, 7, 72, 217, 111, 44, 249]) }, { traceIndex := 9, logicalIndex := 9, semanticRowDigest := (bytes [27, 233, 76, 142, 212, 192, 12, 79, 163, 104, 188, 173, 88, 193, 242, 155, 146, 181, 72, 197, 57, 203, 119, 140, 209, 108, 206, 44, 24, 7, 144, 43]), rowLocalCcsAcceptanceDigest := (bytes [129, 211, 165, 178, 184, 226, 141, 89, 22, 252, 145, 47, 69, 37, 214, 10, 249, 157, 11, 161, 230, 52, 230, 251, 60, 139, 16, 85, 35, 195, 169, 89]), preparedStepBindingDigest := (bytes [111, 104, 76, 134, 51, 128, 7, 213, 0, 49, 2, 221, 30, 3, 97, 137, 5, 255, 115, 32, 241, 143, 91, 9, 215, 129, 20, 35, 85, 92, 199, 39]), publicStepDigest := (bytes [151, 180, 170, 167, 123, 171, 194, 147, 84, 255, 252, 6, 147, 240, 54, 234, 69, 60, 89, 189, 39, 255, 160, 137, 210, 241, 194, 135, 32, 21, 110, 214]), digest := (bytes [26, 143, 210, 6, 209, 39, 38, 56, 167, 167, 231, 34, 87, 3, 40, 97, 61, 121, 61, 93, 175, 42, 51, 227, 92, 186, 87, 19, 45, 107, 118, 15]) }, { traceIndex := 10, logicalIndex := 10, semanticRowDigest := (bytes [246, 130, 144, 47, 199, 141, 164, 141, 220, 63, 10, 231, 166, 134, 83, 96, 187, 73, 143, 121, 168, 85, 96, 132, 0, 68, 193, 116, 159, 223, 9, 230]), rowLocalCcsAcceptanceDigest := (bytes [77, 137, 36, 40, 245, 230, 70, 12, 133, 36, 59, 15, 158, 109, 149, 178, 187, 112, 89, 178, 249, 138, 84, 173, 192, 229, 148, 21, 231, 199, 72, 80]), preparedStepBindingDigest := (bytes [128, 216, 46, 28, 166, 165, 213, 173, 67, 93, 91, 41, 17, 61, 2, 93, 24, 3, 252, 191, 66, 127, 215, 191, 245, 20, 181, 39, 96, 29, 244, 204]), publicStepDigest := (bytes [210, 170, 39, 51, 59, 34, 200, 68, 27, 200, 15, 212, 56, 19, 152, 103, 82, 236, 42, 48, 218, 47, 17, 240, 235, 225, 57, 70, 117, 209, 12, 240]), digest := (bytes [149, 18, 201, 60, 7, 232, 118, 76, 31, 51, 197, 81, 79, 204, 207, 8, 223, 66, 164, 59, 107, 222, 245, 168, 116, 134, 138, 183, 168, 202, 134, 200]) }, { traceIndex := 11, logicalIndex := 11, semanticRowDigest := (bytes [53, 214, 155, 198, 96, 192, 106, 15, 65, 40, 142, 24, 38, 45, 69, 66, 223, 208, 245, 13, 42, 120, 99, 219, 131, 219, 222, 90, 83, 246, 204, 56]), rowLocalCcsAcceptanceDigest := (bytes [227, 6, 135, 82, 152, 95, 37, 149, 89, 204, 124, 213, 168, 149, 115, 169, 97, 30, 171, 102, 35, 120, 97, 27, 212, 225, 3, 81, 97, 186, 5, 11]), preparedStepBindingDigest := (bytes [66, 10, 68, 105, 176, 6, 81, 57, 159, 171, 235, 37, 164, 228, 24, 156, 219, 214, 155, 212, 144, 14, 175, 94, 122, 10, 20, 68, 133, 248, 145, 211]), publicStepDigest := (bytes [32, 172, 108, 15, 208, 47, 194, 209, 63, 249, 125, 112, 52, 47, 131, 155, 246, 110, 27, 189, 141, 1, 112, 149, 179, 215, 143, 167, 192, 138, 90, 8]), digest := (bytes [142, 34, 185, 79, 72, 41, 74, 131, 27, 49, 57, 182, 97, 160, 125, 136, 242, 1, 15, 64, 69, 116, 180, 200, 66, 221, 185, 59, 93, 156, 155, 112]) }, { traceIndex := 12, logicalIndex := 12, semanticRowDigest := (bytes [89, 54, 78, 193, 151, 220, 252, 136, 36, 218, 4, 54, 14, 84, 200, 221, 249, 231, 239, 86, 80, 155, 153, 29, 184, 80, 8, 94, 161, 144, 245, 216]), rowLocalCcsAcceptanceDigest := (bytes [81, 47, 158, 193, 6, 208, 47, 128, 114, 165, 196, 57, 243, 87, 140, 59, 42, 141, 231, 133, 50, 176, 68, 206, 10, 85, 85, 148, 194, 203, 171, 226]), preparedStepBindingDigest := (bytes [213, 147, 190, 191, 234, 115, 82, 204, 203, 38, 47, 83, 250, 30, 164, 37, 54, 223, 158, 101, 130, 79, 247, 149, 175, 42, 218, 6, 119, 132, 137, 192]), publicStepDigest := (bytes [15, 174, 95, 74, 41, 91, 168, 67, 2, 95, 235, 34, 250, 196, 203, 64, 180, 142, 139, 180, 167, 89, 241, 155, 246, 40, 107, 18, 142, 208, 61, 66]), digest := (bytes [107, 107, 91, 215, 6, 150, 16, 20, 181, 58, 66, 115, 11, 47, 199, 168, 70, 36, 175, 89, 30, 160, 138, 93, 83, 54, 94, 75, 2, 73, 45, 188]) }, { traceIndex := 13, logicalIndex := 13, semanticRowDigest := (bytes [207, 221, 213, 152, 121, 82, 189, 190, 174, 204, 234, 67, 8, 192, 177, 39, 28, 255, 160, 26, 247, 166, 200, 49, 210, 126, 153, 38, 122, 205, 36, 244]), rowLocalCcsAcceptanceDigest := (bytes [89, 183, 155, 103, 8, 29, 6, 121, 220, 199, 243, 218, 0, 45, 51, 232, 177, 247, 112, 197, 220, 132, 125, 137, 118, 132, 29, 28, 111, 101, 11, 151]), preparedStepBindingDigest := (bytes [88, 177, 99, 41, 131, 216, 173, 165, 68, 35, 101, 40, 107, 149, 32, 157, 214, 107, 240, 183, 0, 33, 213, 133, 141, 185, 124, 91, 25, 29, 48, 180]), publicStepDigest := (bytes [164, 207, 77, 18, 54, 177, 150, 247, 187, 34, 32, 240, 224, 216, 112, 143, 100, 19, 147, 77, 84, 234, 22, 211, 62, 229, 211, 94, 82, 168, 181, 197]), digest := (bytes [49, 77, 1, 106, 238, 176, 6, 225, 250, 68, 80, 28, 8, 74, 135, 182, 156, 218, 103, 83, 190, 253, 207, 1, 52, 97, 16, 227, 87, 2, 81, 28]) }, { traceIndex := 14, logicalIndex := 14, semanticRowDigest := (bytes [163, 250, 210, 147, 54, 153, 13, 233, 213, 180, 11, 107, 28, 35, 113, 219, 90, 21, 242, 94, 240, 146, 98, 139, 154, 108, 80, 195, 112, 236, 102, 252]), rowLocalCcsAcceptanceDigest := (bytes [157, 164, 41, 254, 213, 226, 18, 73, 28, 103, 121, 80, 197, 253, 151, 50, 183, 150, 133, 178, 226, 170, 120, 244, 168, 16, 176, 163, 241, 80, 89, 58]), preparedStepBindingDigest := (bytes [167, 181, 116, 128, 98, 10, 113, 164, 78, 181, 67, 154, 200, 49, 60, 83, 104, 224, 61, 180, 76, 5, 237, 154, 166, 166, 153, 49, 117, 65, 124, 133]), publicStepDigest := (bytes [153, 11, 161, 124, 199, 12, 122, 193, 74, 44, 184, 254, 229, 183, 125, 136, 228, 241, 27, 20, 189, 90, 203, 75, 84, 49, 202, 34, 201, 170, 176, 121]), digest := (bytes [54, 92, 195, 96, 240, 133, 48, 168, 173, 1, 252, 85, 178, 204, 179, 145, 191, 249, 56, 80, 76, 216, 35, 156, 127, 63, 101, 100, 10, 249, 81, 255]) }, { traceIndex := 15, logicalIndex := 15, semanticRowDigest := (bytes [88, 62, 98, 123, 155, 196, 19, 77, 251, 36, 182, 19, 199, 119, 196, 238, 212, 247, 69, 102, 239, 191, 3, 65, 54, 49, 68, 199, 8, 157, 188, 45]), rowLocalCcsAcceptanceDigest := (bytes [95, 51, 67, 81, 73, 96, 192, 38, 159, 68, 53, 65, 23, 137, 203, 28, 99, 57, 127, 197, 28, 150, 68, 107, 152, 73, 81, 150, 245, 125, 168, 135]), preparedStepBindingDigest := (bytes [18, 92, 76, 174, 17, 137, 253, 44, 113, 240, 241, 197, 228, 31, 92, 159, 228, 64, 20, 109, 6, 44, 27, 3, 236, 172, 119, 172, 62, 240, 196, 153]), publicStepDigest := (bytes [219, 53, 10, 149, 67, 177, 61, 169, 201, 154, 153, 177, 127, 226, 122, 116, 149, 40, 225, 216, 50, 248, 151, 156, 200, 186, 238, 44, 108, 203, 183, 9]), digest := (bytes [2, 213, 55, 243, 18, 24, 166, 108, 7, 132, 161, 56, 60, 63, 50, 212, 73, 67, 126, 165, 32, 216, 143, 183, 156, 221, 204, 33, 192, 110, 174, 200]) }, { traceIndex := 16, logicalIndex := 16, semanticRowDigest := (bytes [153, 190, 165, 237, 221, 129, 209, 122, 193, 244, 238, 77, 44, 186, 31, 85, 22, 233, 131, 76, 77, 7, 48, 203, 237, 145, 177, 68, 203, 200, 123, 110]), rowLocalCcsAcceptanceDigest := (bytes [187, 219, 226, 37, 12, 71, 215, 4, 223, 128, 194, 4, 37, 199, 30, 62, 247, 40, 154, 169, 215, 205, 237, 74, 115, 10, 83, 215, 7, 63, 178, 63]), preparedStepBindingDigest := (bytes [43, 207, 150, 152, 158, 75, 134, 31, 137, 6, 143, 208, 184, 40, 93, 151, 151, 59, 3, 222, 32, 41, 90, 126, 37, 17, 10, 1, 49, 83, 114, 179]), publicStepDigest := (bytes [91, 20, 112, 78, 184, 123, 178, 65, 67, 79, 41, 91, 158, 240, 176, 211, 42, 252, 57, 72, 222, 83, 165, 13, 101, 218, 60, 89, 41, 13, 182, 133]), digest := (bytes [219, 17, 198, 241, 206, 223, 232, 230, 0, 66, 64, 114, 20, 223, 41, 139, 136, 91, 219, 131, 39, 161, 152, 104, 145, 100, 171, 236, 2, 28, 202, 193]) }, { traceIndex := 17, logicalIndex := 17, semanticRowDigest := (bytes [195, 243, 133, 64, 105, 194, 248, 152, 40, 73, 123, 215, 88, 139, 41, 228, 68, 181, 42, 175, 171, 25, 157, 220, 61, 224, 83, 77, 218, 75, 146, 132]), rowLocalCcsAcceptanceDigest := (bytes [127, 69, 85, 218, 199, 143, 124, 130, 159, 164, 141, 231, 169, 39, 29, 198, 240, 232, 114, 187, 199, 195, 177, 244, 74, 65, 194, 6, 6, 152, 129, 93]), preparedStepBindingDigest := (bytes [45, 125, 208, 137, 59, 127, 149, 244, 0, 81, 180, 31, 124, 249, 107, 73, 16, 250, 236, 228, 245, 186, 14, 249, 40, 56, 223, 140, 238, 37, 202, 68]), publicStepDigest := (bytes [3, 71, 173, 5, 248, 3, 124, 9, 68, 11, 12, 17, 175, 158, 219, 80, 156, 195, 156, 120, 195, 108, 203, 4, 4, 59, 3, 84, 137, 138, 184, 114]), digest := (bytes [247, 52, 137, 227, 49, 152, 240, 136, 165, 216, 212, 168, 190, 234, 44, 19, 158, 49, 84, 242, 7, 252, 225, 44, 160, 49, 249, 120, 122, 211, 19, 244]) }, { traceIndex := 18, logicalIndex := 18, semanticRowDigest := (bytes [49, 52, 40, 94, 178, 137, 120, 104, 78, 84, 211, 131, 246, 77, 156, 245, 22, 249, 123, 226, 36, 209, 17, 59, 37, 88, 25, 2, 73, 254, 124, 224]), rowLocalCcsAcceptanceDigest := (bytes [223, 155, 254, 234, 64, 58, 123, 113, 249, 108, 98, 162, 40, 7, 84, 103, 138, 10, 139, 232, 86, 196, 4, 230, 185, 234, 64, 216, 205, 100, 47, 55]), preparedStepBindingDigest := (bytes [241, 205, 183, 198, 7, 248, 2, 25, 167, 221, 163, 134, 160, 119, 162, 8, 30, 71, 190, 31, 39, 117, 21, 245, 152, 255, 194, 169, 164, 82, 154, 139]), publicStepDigest := (bytes [168, 186, 173, 189, 232, 242, 27, 84, 57, 205, 172, 157, 65, 255, 8, 199, 183, 182, 242, 232, 77, 18, 42, 32, 134, 204, 3, 50, 116, 32, 182, 125]), digest := (bytes [215, 22, 62, 134, 250, 20, 242, 10, 75, 251, 31, 211, 250, 164, 239, 254, 182, 29, 209, 110, 47, 195, 132, 160, 169, 238, 91, 74, 31, 222, 97, 63]) }, { traceIndex := 19, logicalIndex := 19, semanticRowDigest := (bytes [53, 156, 3, 202, 62, 80, 30, 254, 227, 185, 183, 114, 60, 229, 114, 88, 172, 197, 116, 170, 157, 169, 113, 77, 120, 250, 47, 150, 195, 59, 67, 192]), rowLocalCcsAcceptanceDigest := (bytes [85, 117, 55, 102, 240, 131, 63, 232, 189, 240, 188, 138, 33, 136, 122, 101, 69, 221, 16, 191, 165, 169, 118, 2, 87, 170, 4, 14, 89, 50, 4, 175]), preparedStepBindingDigest := (bytes [112, 32, 157, 27, 87, 130, 44, 253, 88, 154, 107, 25, 133, 72, 79, 148, 9, 88, 139, 88, 112, 15, 73, 85, 17, 244, 208, 189, 245, 38, 28, 71]), publicStepDigest := (bytes [106, 128, 173, 45, 66, 12, 245, 212, 146, 133, 54, 235, 234, 174, 115, 65, 99, 113, 64, 14, 129, 86, 252, 254, 141, 194, 222, 200, 174, 15, 131, 63]), digest := (bytes [252, 82, 58, 61, 44, 107, 166, 29, 78, 0, 24, 237, 208, 23, 103, 173, 105, 232, 110, 8, 7, 170, 27, 170, 92, 152, 211, 203, 62, 181, 189, 50]) }]

def rootExecution : RootExecutionBundleView :=
  {
    executionRows := rootExecutionExecutionRows
    , semanticRows := rootExecutionSemanticRows
    , semanticRowsDigest := (bytes [143, 50, 80, 146, 88, 180, 163, 180, 18, 250, 142, 67, 29, 198, 31, 93, 11, 216, 111, 127, 238, 166, 15, 102, 43, 215, 91, 30, 2, 248, 103, 86])
    , preparedStepBindings := { bindings := rootExecutionPreparedBindings, bindingCount := 20, firstBindingDigest := (some (bytes [16, 205, 233, 91, 190, 78, 83, 228, 90, 205, 244, 8, 169, 34, 193, 217, 30, 161, 98, 80, 83, 164, 76, 84, 87, 39, 184, 235, 149, 84, 113, 117])), lastBindingDigest := (some (bytes [112, 32, 157, 27, 87, 130, 44, 253, 88, 154, 107, 25, 133, 72, 79, 148, 9, 88, 139, 88, 112, 15, 73, 85, 17, 244, 208, 189, 245, 38, 28, 71])), digest := (bytes [56, 55, 65, 136, 166, 105, 55, 221, 32, 59, 92, 217, 19, 218, 150, 142, 9, 231, 253, 237, 17, 141, 61, 10, 157, 65, 174, 106, 188, 85, 117, 232]) }
    , rowChunkRoutes := rootExecutionRowChunkRoutes
    , rowChunkRoutesDigest := (bytes [44, 19, 15, 238, 134, 132, 130, 143, 37, 145, 123, 34, 41, 193, 34, 193, 20, 41, 74, 29, 203, 33, 147, 118, 124, 21, 3, 194, 30, 95, 164, 186])
    , rowLocalCcsAcceptance := { acceptances := rootExecutionRowLocalCcsAcceptance, acceptanceCount := 20, firstAcceptanceDigest := (some (bytes [212, 5, 248, 192, 113, 22, 243, 180, 213, 80, 219, 180, 16, 96, 14, 166, 166, 12, 52, 2, 66, 146, 103, 131, 146, 124, 88, 183, 30, 0, 207, 93])), lastAcceptanceDigest := (some (bytes [85, 117, 55, 102, 240, 131, 63, 232, 189, 240, 188, 138, 33, 136, 122, 101, 69, 221, 16, 191, 165, 169, 118, 2, 87, 170, 4, 14, 89, 50, 4, 175])), digest := (bytes [71, 31, 158, 139, 168, 62, 255, 111, 199, 200, 57, 255, 49, 11, 184, 109, 184, 98, 197, 98, 160, 156, 240, 250, 157, 172, 128, 81, 58, 155, 170, 81]) }
    , executionSemanticsRefinement := { refinements := rootExecutionExecutionSemanticsRefinement, refinementCount := 20, firstRefinementDigest := (some (bytes [147, 213, 63, 116, 232, 91, 226, 177, 76, 155, 129, 162, 191, 255, 215, 45, 3, 117, 91, 7, 121, 242, 86, 88, 219, 114, 250, 49, 200, 93, 157, 231])), lastRefinementDigest := (some (bytes [252, 82, 58, 61, 44, 107, 166, 29, 78, 0, 24, 237, 208, 23, 103, 173, 105, 232, 110, 8, 7, 170, 27, 170, 92, 152, 211, 203, 62, 181, 189, 50])), digest := (bytes [235, 157, 126, 178, 206, 29, 103, 88, 186, 87, 67, 216, 239, 174, 88, 145, 158, 118, 76, 125, 169, 162, 154, 160, 137, 188, 120, 101, 61, 105, 75, 35]) }
    , familyDigest := (bytes [171, 224, 63, 43, 249, 74, 225, 231, 62, 81, 99, 246, 21, 22, 245, 111, 89, 94, 177, 243, 37, 191, 68, 180, 9, 24, 201, 59, 114, 116, 96, 14])
    , digest := (bytes [162, 32, 73, 53, 232, 76, 203, 205, 243, 139, 1, 167, 234, 109, 45, 41, 127, 45, 19, 238, 123, 208, 168, 244, 69, 207, 177, 45, 57, 79, 40, 74])
  }

def kernelOpeningBundle : SimpleKernelOpeningBundleView :=
  {
    claim := { bindings := { stageClaimBundleDigest := (bytes [70, 47, 32, 181, 107, 177, 216, 251, 0, 96, 119, 64, 150, 0, 74, 134, 39, 166, 239, 171, 130, 128, 99, 70, 185, 223, 7, 31, 93, 150, 85, 55]), stagePackageBundleDigest := (bytes [253, 68, 102, 128, 114, 247, 96, 30, 42, 155, 72, 120, 189, 122, 83, 246, 73, 123, 104, 153, 131, 27, 149, 124, 249, 24, 106, 81, 205, 160, 156, 232]), stage1PackageDigest := (bytes [6, 10, 87, 34, 241, 198, 152, 111, 25, 24, 54, 182, 89, 57, 247, 48, 242, 144, 226, 150, 167, 143, 175, 224, 254, 182, 192, 43, 164, 232, 67, 22]), stage2PackageDigest := (bytes [218, 40, 31, 235, 102, 3, 46, 12, 84, 131, 99, 11, 21, 10, 80, 37, 106, 103, 252, 44, 250, 58, 169, 51, 76, 29, 215, 63, 181, 188, 27, 111]), stage3PackageDigest := (bytes [11, 50, 217, 85, 206, 200, 239, 139, 234, 25, 96, 96, 132, 20, 133, 5, 36, 123, 115, 179, 2, 255, 142, 86, 179, 60, 240, 89, 255, 62, 179, 48]), preparedStepBindingsDigest := (bytes [56, 55, 65, 136, 166, 105, 55, 221, 32, 59, 92, 217, 19, 218, 150, 142, 9, 231, 253, 237, 17, 141, 61, 10, 157, 65, 174, 106, 188, 85, 117, 232]), bindingCount := 20, stage1RowCount := 20, stage2RegisterReadCount := 34, stage2RegisterWriteCount := 19, stage2RamEventCount := 0, stage3ContinuityCount := 4, points := { firstBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [56, 55, 65, 136, 166, 105, 55, 221, 32, 59, 92, 217, 19, 218, 150, 142, 9, 231, 253, 237, 17, 141, 61, 10, 157, 65, 174, 106, 188, 85, 117, 232]), layoutVersion := 1, digest := (bytes [7, 204, 47, 109, 222, 128, 50, 239, 190, 159, 31, 220, 206, 91, 120, 125, 120, 172, 39, 120, 165, 111, 159, 73, 34, 61, 148, 98, 198, 70, 232, 44]) }, logicalIndex := 0, digest := (bytes [152, 233, 193, 189, 35, 205, 69, 42, 240, 103, 168, 203, 45, 56, 158, 175, 43, 14, 70, 161, 74, 181, 172, 33, 244, 149, 20, 184, 205, 53, 160, 103]) }, valueDigest := (bytes [16, 205, 233, 91, 190, 78, 83, 228, 90, 205, 244, 8, 169, 34, 193, 217, 30, 161, 98, 80, 83, 164, 76, 84, 87, 39, 184, 235, 149, 84, 113, 117]), digest := (bytes [55, 204, 242, 148, 229, 166, 27, 132, 47, 108, 94, 182, 139, 132, 149, 224, 147, 248, 30, 105, 225, 127, 78, 45, 52, 244, 170, 55, 195, 145, 77, 126]) }), lastBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [56, 55, 65, 136, 166, 105, 55, 221, 32, 59, 92, 217, 19, 218, 150, 142, 9, 231, 253, 237, 17, 141, 61, 10, 157, 65, 174, 106, 188, 85, 117, 232]), layoutVersion := 1, digest := (bytes [7, 204, 47, 109, 222, 128, 50, 239, 190, 159, 31, 220, 206, 91, 120, 125, 120, 172, 39, 120, 165, 111, 159, 73, 34, 61, 148, 98, 198, 70, 232, 44]) }, logicalIndex := 19, digest := (bytes [233, 10, 239, 92, 184, 61, 95, 196, 56, 145, 130, 121, 79, 94, 209, 177, 192, 123, 197, 61, 243, 86, 107, 131, 58, 102, 151, 195, 73, 33, 146, 76]) }, valueDigest := (bytes [112, 32, 157, 27, 87, 130, 44, 253, 88, 154, 107, 25, 133, 72, 79, 148, 9, 88, 139, 88, 112, 15, 73, 85, 17, 244, 208, 189, 245, 38, 28, 71]), digest := (bytes [250, 68, 212, 19, 199, 173, 48, 197, 159, 250, 117, 25, 188, 176, 244, 184, 225, 138, 244, 250, 123, 199, 171, 146, 194, 62, 152, 42, 117, 249, 11, 162]) }) }, digest := (bytes [234, 249, 186, 36, 218, 31, 51, 124, 131, 125, 25, 16, 205, 94, 3, 58, 25, 240, 47, 227, 227, 46, 246, 198, 231, 203, 179, 127, 193, 161, 156, 174]) }, preparedSteps := { executionDigest := (bytes [253, 56, 202, 101, 142, 132, 93, 134, 75, 217, 118, 33, 12, 112, 138, 94, 76, 57, 89, 198, 120, 58, 231, 25, 226, 162, 224, 124, 164, 228, 241, 216]), finalStateDigest := (bytes [64, 177, 68, 187, 81, 87, 252, 39, 65, 209, 64, 178, 63, 178, 69, 5, 247, 172, 14, 148, 78, 120, 110, 92, 118, 191, 130, 29, 111, 21, 65, 215]), transcriptFinalDigest := (bytes [120, 150, 198, 157, 183, 29, 181, 168, 84, 91, 217, 92, 129, 32, 61, 159, 114, 123, 152, 127, 69, 68, 165, 115, 230, 23, 147, 254, 240, 0, 112, 198]), preparedStepCount := 20, finalPc := 16, halted := true, points := { firstPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [212, 205, 99, 165, 179, 213, 216, 52, 3, 111, 39, 206, 164, 185, 138, 173, 4, 18, 72, 230, 120, 223, 52, 220, 233, 175, 26, 2, 158, 238, 255, 174]), layoutVersion := 3, digest := (bytes [108, 219, 176, 66, 40, 133, 237, 106, 119, 34, 250, 122, 114, 69, 60, 225, 151, 212, 179, 30, 218, 106, 205, 20, 247, 174, 89, 29, 93, 30, 175, 128]) }, logicalIndex := 0, digest := (bytes [211, 213, 209, 113, 179, 55, 161, 232, 121, 201, 243, 72, 119, 136, 63, 108, 133, 246, 161, 86, 238, 142, 145, 88, 113, 127, 217, 16, 223, 161, 88, 75]) }, valueDigest := (bytes [158, 63, 138, 206, 127, 145, 146, 109, 103, 153, 88, 114, 209, 198, 164, 199, 49, 182, 5, 151, 139, 25, 106, 81, 245, 88, 121, 14, 33, 120, 32, 196]), digest := (bytes [191, 83, 25, 35, 78, 235, 194, 227, 254, 254, 234, 224, 176, 9, 90, 171, 211, 218, 193, 16, 146, 5, 213, 132, 60, 208, 44, 15, 55, 232, 14, 220]) }), lastPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [212, 205, 99, 165, 179, 213, 216, 52, 3, 111, 39, 206, 164, 185, 138, 173, 4, 18, 72, 230, 120, 223, 52, 220, 233, 175, 26, 2, 158, 238, 255, 174]), layoutVersion := 3, digest := (bytes [108, 219, 176, 66, 40, 133, 237, 106, 119, 34, 250, 122, 114, 69, 60, 225, 151, 212, 179, 30, 218, 106, 205, 20, 247, 174, 89, 29, 93, 30, 175, 128]) }, logicalIndex := 19, digest := (bytes [105, 49, 34, 171, 7, 204, 146, 158, 175, 143, 55, 126, 234, 35, 10, 50, 47, 214, 49, 195, 242, 6, 48, 207, 226, 244, 123, 30, 15, 70, 204, 102]) }, valueDigest := (bytes [82, 160, 133, 135, 90, 74, 33, 242, 167, 29, 94, 199, 13, 129, 162, 84, 101, 207, 110, 195, 203, 13, 137, 237, 155, 115, 102, 78, 93, 59, 31, 37]), digest := (bytes [122, 22, 157, 76, 176, 180, 197, 55, 51, 178, 205, 194, 143, 161, 136, 221, 111, 214, 205, 82, 133, 124, 105, 171, 89, 209, 99, 80, 14, 216, 80, 60]) }) }, digest := (bytes [95, 132, 120, 99, 169, 96, 63, 151, 165, 118, 85, 165, 221, 85, 248, 141, 11, 0, 194, 11, 189, 201, 126, 69, 219, 60, 241, 232, 98, 119, 243, 78]) }, digest := (bytes [57, 252, 166, 206, 50, 86, 5, 153, 150, 113, 83, 200, 199, 104, 253, 16, 89, 102, 78, 215, 127, 45, 39, 160, 68, 94, 193, 22, 228, 124, 251, 217]) }
    , bindings := { claim := { stageClaimBundleDigest := (bytes [70, 47, 32, 181, 107, 177, 216, 251, 0, 96, 119, 64, 150, 0, 74, 134, 39, 166, 239, 171, 130, 128, 99, 70, 185, 223, 7, 31, 93, 150, 85, 55]), stagePackageBundleDigest := (bytes [253, 68, 102, 128, 114, 247, 96, 30, 42, 155, 72, 120, 189, 122, 83, 246, 73, 123, 104, 153, 131, 27, 149, 124, 249, 24, 106, 81, 205, 160, 156, 232]), stage1PackageDigest := (bytes [6, 10, 87, 34, 241, 198, 152, 111, 25, 24, 54, 182, 89, 57, 247, 48, 242, 144, 226, 150, 167, 143, 175, 224, 254, 182, 192, 43, 164, 232, 67, 22]), stage2PackageDigest := (bytes [218, 40, 31, 235, 102, 3, 46, 12, 84, 131, 99, 11, 21, 10, 80, 37, 106, 103, 252, 44, 250, 58, 169, 51, 76, 29, 215, 63, 181, 188, 27, 111]), stage3PackageDigest := (bytes [11, 50, 217, 85, 206, 200, 239, 139, 234, 25, 96, 96, 132, 20, 133, 5, 36, 123, 115, 179, 2, 255, 142, 86, 179, 60, 240, 89, 255, 62, 179, 48]), preparedStepBindingsDigest := (bytes [56, 55, 65, 136, 166, 105, 55, 221, 32, 59, 92, 217, 19, 218, 150, 142, 9, 231, 253, 237, 17, 141, 61, 10, 157, 65, 174, 106, 188, 85, 117, 232]), bindingCount := 20, stage1RowCount := 20, stage2RegisterReadCount := 34, stage2RegisterWriteCount := 19, stage2RamEventCount := 0, stage3ContinuityCount := 4, points := { firstBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [56, 55, 65, 136, 166, 105, 55, 221, 32, 59, 92, 217, 19, 218, 150, 142, 9, 231, 253, 237, 17, 141, 61, 10, 157, 65, 174, 106, 188, 85, 117, 232]), layoutVersion := 1, digest := (bytes [7, 204, 47, 109, 222, 128, 50, 239, 190, 159, 31, 220, 206, 91, 120, 125, 120, 172, 39, 120, 165, 111, 159, 73, 34, 61, 148, 98, 198, 70, 232, 44]) }, logicalIndex := 0, digest := (bytes [152, 233, 193, 189, 35, 205, 69, 42, 240, 103, 168, 203, 45, 56, 158, 175, 43, 14, 70, 161, 74, 181, 172, 33, 244, 149, 20, 184, 205, 53, 160, 103]) }, valueDigest := (bytes [16, 205, 233, 91, 190, 78, 83, 228, 90, 205, 244, 8, 169, 34, 193, 217, 30, 161, 98, 80, 83, 164, 76, 84, 87, 39, 184, 235, 149, 84, 113, 117]), digest := (bytes [55, 204, 242, 148, 229, 166, 27, 132, 47, 108, 94, 182, 139, 132, 149, 224, 147, 248, 30, 105, 225, 127, 78, 45, 52, 244, 170, 55, 195, 145, 77, 126]) }), lastBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [56, 55, 65, 136, 166, 105, 55, 221, 32, 59, 92, 217, 19, 218, 150, 142, 9, 231, 253, 237, 17, 141, 61, 10, 157, 65, 174, 106, 188, 85, 117, 232]), layoutVersion := 1, digest := (bytes [7, 204, 47, 109, 222, 128, 50, 239, 190, 159, 31, 220, 206, 91, 120, 125, 120, 172, 39, 120, 165, 111, 159, 73, 34, 61, 148, 98, 198, 70, 232, 44]) }, logicalIndex := 19, digest := (bytes [233, 10, 239, 92, 184, 61, 95, 196, 56, 145, 130, 121, 79, 94, 209, 177, 192, 123, 197, 61, 243, 86, 107, 131, 58, 102, 151, 195, 73, 33, 146, 76]) }, valueDigest := (bytes [112, 32, 157, 27, 87, 130, 44, 253, 88, 154, 107, 25, 133, 72, 79, 148, 9, 88, 139, 88, 112, 15, 73, 85, 17, 244, 208, 189, 245, 38, 28, 71]), digest := (bytes [250, 68, 212, 19, 199, 173, 48, 197, 159, 250, 117, 25, 188, 176, 244, 184, 225, 138, 244, 250, 123, 199, 171, 146, 194, 62, 152, 42, 117, 249, 11, 162]) }) }, digest := (bytes [234, 249, 186, 36, 218, 31, 51, 124, 131, 125, 25, 16, 205, 94, 3, 58, 25, 240, 47, 227, 227, 46, 246, 198, 231, 203, 179, 127, 193, 161, 156, 174]) }, packaged := { statementDigest := (bytes [64, 32, 199, 43, 82, 114, 86, 93, 43, 101, 140, 134, 188, 142, 17, 149, 214, 37, 8, 205, 214, 136, 118, 131, 255, 216, 46, 237, 110, 17, 248, 159]), proofDigest := (bytes [98, 41, 63, 215, 7, 1, 28, 49, 89, 165, 212, 90, 22, 165, 241, 14, 51, 178, 86, 109, 89, 183, 60, 73, 200, 167, 124, 188, 245, 115, 143, 121]) }, digest := (bytes [229, 202, 10, 251, 106, 127, 222, 240, 249, 36, 93, 163, 113, 62, 72, 62, 57, 8, 91, 47, 197, 119, 41, 238, 165, 135, 41, 137, 39, 142, 226, 11]) }
    , preparedSteps := { claim := { executionDigest := (bytes [253, 56, 202, 101, 142, 132, 93, 134, 75, 217, 118, 33, 12, 112, 138, 94, 76, 57, 89, 198, 120, 58, 231, 25, 226, 162, 224, 124, 164, 228, 241, 216]), finalStateDigest := (bytes [64, 177, 68, 187, 81, 87, 252, 39, 65, 209, 64, 178, 63, 178, 69, 5, 247, 172, 14, 148, 78, 120, 110, 92, 118, 191, 130, 29, 111, 21, 65, 215]), transcriptFinalDigest := (bytes [120, 150, 198, 157, 183, 29, 181, 168, 84, 91, 217, 92, 129, 32, 61, 159, 114, 123, 152, 127, 69, 68, 165, 115, 230, 23, 147, 254, 240, 0, 112, 198]), preparedStepCount := 20, finalPc := 16, halted := true, points := { firstPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [212, 205, 99, 165, 179, 213, 216, 52, 3, 111, 39, 206, 164, 185, 138, 173, 4, 18, 72, 230, 120, 223, 52, 220, 233, 175, 26, 2, 158, 238, 255, 174]), layoutVersion := 3, digest := (bytes [108, 219, 176, 66, 40, 133, 237, 106, 119, 34, 250, 122, 114, 69, 60, 225, 151, 212, 179, 30, 218, 106, 205, 20, 247, 174, 89, 29, 93, 30, 175, 128]) }, logicalIndex := 0, digest := (bytes [211, 213, 209, 113, 179, 55, 161, 232, 121, 201, 243, 72, 119, 136, 63, 108, 133, 246, 161, 86, 238, 142, 145, 88, 113, 127, 217, 16, 223, 161, 88, 75]) }, valueDigest := (bytes [158, 63, 138, 206, 127, 145, 146, 109, 103, 153, 88, 114, 209, 198, 164, 199, 49, 182, 5, 151, 139, 25, 106, 81, 245, 88, 121, 14, 33, 120, 32, 196]), digest := (bytes [191, 83, 25, 35, 78, 235, 194, 227, 254, 254, 234, 224, 176, 9, 90, 171, 211, 218, 193, 16, 146, 5, 213, 132, 60, 208, 44, 15, 55, 232, 14, 220]) }), lastPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [212, 205, 99, 165, 179, 213, 216, 52, 3, 111, 39, 206, 164, 185, 138, 173, 4, 18, 72, 230, 120, 223, 52, 220, 233, 175, 26, 2, 158, 238, 255, 174]), layoutVersion := 3, digest := (bytes [108, 219, 176, 66, 40, 133, 237, 106, 119, 34, 250, 122, 114, 69, 60, 225, 151, 212, 179, 30, 218, 106, 205, 20, 247, 174, 89, 29, 93, 30, 175, 128]) }, logicalIndex := 19, digest := (bytes [105, 49, 34, 171, 7, 204, 146, 158, 175, 143, 55, 126, 234, 35, 10, 50, 47, 214, 49, 195, 242, 6, 48, 207, 226, 244, 123, 30, 15, 70, 204, 102]) }, valueDigest := (bytes [82, 160, 133, 135, 90, 74, 33, 242, 167, 29, 94, 199, 13, 129, 162, 84, 101, 207, 110, 195, 203, 13, 137, 237, 155, 115, 102, 78, 93, 59, 31, 37]), digest := (bytes [122, 22, 157, 76, 176, 180, 197, 55, 51, 178, 205, 194, 143, 161, 136, 221, 111, 214, 205, 82, 133, 124, 105, 171, 89, 209, 99, 80, 14, 216, 80, 60]) }) }, digest := (bytes [95, 132, 120, 99, 169, 96, 63, 151, 165, 118, 85, 165, 221, 85, 248, 141, 11, 0, 194, 11, 189, 201, 126, 69, 219, 60, 241, 232, 98, 119, 243, 78]) }, packaged := { statementDigest := (bytes [129, 88, 235, 192, 153, 81, 87, 15, 79, 179, 154, 22, 162, 111, 213, 130, 195, 59, 140, 30, 221, 17, 125, 93, 53, 142, 174, 140, 166, 68, 51, 108]), proofDigest := (bytes [127, 59, 127, 134, 186, 238, 249, 49, 18, 82, 33, 54, 57, 109, 114, 218, 14, 87, 38, 1, 237, 153, 219, 91, 95, 199, 240, 199, 255, 56, 8, 50]) }, digest := (bytes [160, 151, 120, 21, 206, 145, 64, 91, 14, 148, 98, 135, 27, 128, 129, 141, 192, 57, 207, 232, 9, 243, 128, 103, 109, 149, 129, 179, 71, 87, 65, 181]) }
    , digest := (bytes [198, 84, 146, 64, 111, 119, 190, 121, 159, 108, 161, 239, 196, 219, 253, 57, 156, 179, 128, 200, 150, 72, 115, 128, 184, 62, 117, 82, 200, 134, 59, 132])
  }

def stepComposition : StepCompositionSurfaceView :=
  {
    stage1SemanticsDigest := (bytes [59, 96, 220, 72, 75, 13, 241, 70, 83, 180, 7, 194, 187, 76, 194, 181, 152, 15, 191, 203, 85, 30, 80, 21, 133, 20, 133, 163, 171, 95, 223, 241])
    , stage2SemanticsDigest := (bytes [215, 97, 207, 225, 149, 200, 237, 95, 243, 122, 17, 254, 156, 75, 188, 203, 40, 49, 133, 146, 11, 70, 208, 5, 42, 90, 39, 155, 112, 80, 170, 156])
    , stage2TemporalDigest := (bytes [184, 252, 18, 169, 243, 90, 119, 1, 89, 55, 13, 179, 188, 32, 96, 113, 89, 243, 236, 23, 213, 185, 137, 124, 117, 1, 160, 107, 123, 236, 237, 116])
    , stage3SemanticsDigest := (bytes [92, 171, 234, 150, 144, 168, 117, 235, 254, 7, 82, 199, 150, 32, 197, 180, 38, 163, 196, 126, 44, 71, 58, 97, 22, 109, 180, 250, 128, 101, 42, 209])
    , rootExecutionDigest := (bytes [162, 32, 73, 53, 232, 76, 203, 205, 243, 139, 1, 167, 234, 109, 45, 41, 127, 45, 19, 238, 123, 208, 168, 244, 69, 207, 177, 45, 57, 79, 40, 74])
    , preparedStepBindingsDigest := (bytes [56, 55, 65, 136, 166, 105, 55, 221, 32, 59, 92, 217, 19, 218, 150, 142, 9, 231, 253, 237, 17, 141, 61, 10, 157, 65, 174, 106, 188, 85, 117, 232])
    , rowChunkRoutesDigest := (bytes [44, 19, 15, 238, 134, 132, 130, 143, 37, 145, 123, 34, 41, 193, 34, 193, 20, 41, 74, 29, 203, 33, 147, 118, 124, 21, 3, 194, 30, 95, 164, 186])
    , realRowCount := 4
    , preparedStepCount := 20
    , firstRealStepIndex := 0
    , lastRealStepIndex := 3
    , initialPc := 0
    , finalPc := 16
    , halted := true
    , digest := (bytes [199, 197, 157, 183, 160, 232, 107, 192, 193, 83, 219, 207, 136, 134, 175, 105, 209, 135, 230, 77, 171, 243, 53, 5, 95, 88, 96, 160, 175, 64, 125, 46])
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
    name := "multiply_high_mulh_mulhu_mulhsu_ecall"
    , source := {
  manifest := { name := "multiply_high_mulh_mulhu_mulhsu_ecall", fixtureId := "multiply_high_mulh_mulhu_mulhsu_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.multiply, .controlFlow] }
  , startPc := 0
  , programWords := [35689395, 37860403, 40019123, 115]
  , initialRegisters := [0, 18446744073709551614, 18446744073709551613, 18446744073709551614, 3, 18446744073709551614, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , initialMemory := []
  , transcriptSeed := (bytes [114, 118, 54, 52, 105, 109, 45, 109, 117, 108, 116, 105, 112, 108, 121, 45, 104, 105, 103, 104, 45, 118, 49])
}
    , derived := {
  manifest := { name := "multiply_high_mulh_mulhu_mulhsu_ecall", fixtureId := "multiply_high_mulh_mulhu_mulhsu_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.multiply, .controlFlow] }
  , executionRows := [{
  traceIndex := 0
  , stepIndex := 0
  , sequenceIndex := 0
  , pc := 0
  , nextPc := 0
  , word := 35689395
  , opcode := .mulh
  , traceOpcode := none
  , traceVirtualOpcode := (some .movsign)
  , family := .multiply
  , rs1 := 1
  , rs1Value := 18446744073709551614
  , rs2 := 0
  , rs2Value := 0
  , rd := 40
  , rdBefore := 0
  , rdAfter := 18446744073709551615
  , imm := 0
  , aluResult := 18446744073709551615
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := true
  , virtualSequenceRemaining := (some 6)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 1
  , stepIndex := 0
  , sequenceIndex := 1
  , pc := 0
  , nextPc := 0
  , word := 35689395
  , opcode := .mulh
  , traceOpcode := none
  , traceVirtualOpcode := (some .movsign)
  , family := .multiply
  , rs1 := 2
  , rs1Value := 18446744073709551613
  , rs2 := 0
  , rs2Value := 0
  , rd := 41
  , rdBefore := 0
  , rdAfter := 18446744073709551615
  , imm := 0
  , aluResult := 18446744073709551615
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 5)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 2
  , stepIndex := 0
  , sequenceIndex := 2
  , pc := 0
  , nextPc := 0
  , word := 35689395
  , opcode := .mulh
  , traceOpcode := (some .mul)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 40
  , rs1Value := 18446744073709551615
  , rs2 := 2
  , rs2Value := 18446744073709551613
  , rd := 40
  , rdBefore := 18446744073709551615
  , rdAfter := 3
  , imm := 0
  , aluResult := 3
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 4)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 3
  , stepIndex := 0
  , sequenceIndex := 3
  , pc := 0
  , nextPc := 0
  , word := 35689395
  , opcode := .mulh
  , traceOpcode := (some .mul)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 41
  , rs1Value := 18446744073709551615
  , rs2 := 1
  , rs2Value := 18446744073709551614
  , rd := 41
  , rdBefore := 18446744073709551615
  , rdAfter := 2
  , imm := 0
  , aluResult := 2
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 3)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 4
  , stepIndex := 0
  , sequenceIndex := 4
  , pc := 0
  , nextPc := 0
  , word := 35689395
  , opcode := .mulh
  , traceOpcode := (some .mulhu)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 1
  , rs1Value := 18446744073709551614
  , rs2 := 2
  , rs2Value := 18446744073709551613
  , rd := 42
  , rdBefore := 0
  , rdAfter := 18446744073709551611
  , imm := 0
  , aluResult := 18446744073709551611
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 2)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 5
  , stepIndex := 0
  , sequenceIndex := 5
  , pc := 0
  , nextPc := 0
  , word := 35689395
  , opcode := .mulh
  , traceOpcode := (some .add)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 42
  , rs1Value := 18446744073709551611
  , rs2 := 40
  , rs2Value := 3
  , rd := 42
  , rdBefore := 18446744073709551611
  , rdAfter := 18446744073709551614
  , imm := 0
  , aluResult := 18446744073709551614
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 1)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 6
  , stepIndex := 0
  , sequenceIndex := 6
  , pc := 0
  , nextPc := 4
  , word := 35689395
  , opcode := .mulh
  , traceOpcode := (some .add)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 42
  , rs1Value := 18446744073709551614
  , rs2 := 41
  , rs2Value := 2
  , rd := 7
  , rdBefore := 0
  , rdAfter := 0
  , imm := 0
  , aluResult := 0
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 0)
  , isEffectRow := true
  , isCommitRow := true
  , isReal := true
}, {
  traceIndex := 7
  , stepIndex := 1
  , sequenceIndex := 0
  , pc := 4
  , nextPc := 8
  , word := 37860403
  , opcode := .mulhu
  , traceOpcode := (some .mulhu)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 3
  , rs1Value := 18446744073709551614
  , rs2 := 4
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
  , stepIndex := 2
  , sequenceIndex := 0
  , pc := 8
  , nextPc := 8
  , word := 40019123
  , opcode := .mulhsu
  , traceOpcode := none
  , traceVirtualOpcode := (some .movsign)
  , family := .multiply
  , rs1 := 5
  , rs1Value := 18446744073709551614
  , rs2 := 0
  , rs2Value := 0
  , rd := 40
  , rdBefore := 0
  , rdAfter := 18446744073709551615
  , imm := 0
  , aluResult := 18446744073709551615
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := true
  , virtualSequenceRemaining := (some 10)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 9
  , stepIndex := 2
  , sequenceIndex := 1
  , pc := 8
  , nextPc := 8
  , word := 40019123
  , opcode := .mulhsu
  , traceOpcode := (some .andi)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 40
  , rs1Value := 18446744073709551615
  , rs2 := 0
  , rs2Value := 0
  , rd := 41
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
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 9)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 10
  , stepIndex := 2
  , sequenceIndex := 2
  , pc := 8
  , nextPc := 8
  , word := 40019123
  , opcode := .mulhsu
  , traceOpcode := (some .xor)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 5
  , rs1Value := 18446744073709551614
  , rs2 := 40
  , rs2Value := 18446744073709551615
  , rd := 42
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
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 8)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 11
  , stepIndex := 2
  , sequenceIndex := 3
  , pc := 8
  , nextPc := 8
  , word := 40019123
  , opcode := .mulhsu
  , traceOpcode := (some .add)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 42
  , rs1Value := 1
  , rs2 := 41
  , rs2Value := 1
  , rd := 42
  , rdBefore := 1
  , rdAfter := 2
  , imm := 0
  , aluResult := 2
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 7)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 12
  , stepIndex := 2
  , sequenceIndex := 4
  , pc := 8
  , nextPc := 8
  , word := 40019123
  , opcode := .mulhsu
  , traceOpcode := (some .mulhu)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 42
  , rs1Value := 2
  , rs2 := 6
  , rs2Value := 3
  , rd := 43
  , rdBefore := 0
  , rdAfter := 0
  , imm := 0
  , aluResult := 0
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 6)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 13
  , stepIndex := 2
  , sequenceIndex := 5
  , pc := 8
  , nextPc := 8
  , word := 40019123
  , opcode := .mulhsu
  , traceOpcode := (some .mul)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 42
  , rs1Value := 2
  , rs2 := 6
  , rs2Value := 3
  , rd := 42
  , rdBefore := 2
  , rdAfter := 6
  , imm := 0
  , aluResult := 6
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 5)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 14
  , stepIndex := 2
  , sequenceIndex := 6
  , pc := 8
  , nextPc := 8
  , word := 40019123
  , opcode := .mulhsu
  , traceOpcode := (some .xor)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 43
  , rs1Value := 0
  , rs2 := 40
  , rs2Value := 18446744073709551615
  , rd := 43
  , rdBefore := 0
  , rdAfter := 18446744073709551615
  , imm := 0
  , aluResult := 18446744073709551615
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 4)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 15
  , stepIndex := 2
  , sequenceIndex := 7
  , pc := 8
  , nextPc := 8
  , word := 40019123
  , opcode := .mulhsu
  , traceOpcode := (some .xor)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 42
  , rs1Value := 6
  , rs2 := 40
  , rs2Value := 18446744073709551615
  , rd := 42
  , rdBefore := 6
  , rdAfter := 18446744073709551609
  , imm := 0
  , aluResult := 18446744073709551609
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 3)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 16
  , stepIndex := 2
  , sequenceIndex := 8
  , pc := 8
  , nextPc := 8
  , word := 40019123
  , opcode := .mulhsu
  , traceOpcode := (some .add)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 42
  , rs1Value := 18446744073709551609
  , rs2 := 41
  , rs2Value := 1
  , rd := 40
  , rdBefore := 18446744073709551615
  , rdAfter := 18446744073709551610
  , imm := 0
  , aluResult := 18446744073709551610
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 2)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 17
  , stepIndex := 2
  , sequenceIndex := 9
  , pc := 8
  , nextPc := 8
  , word := 40019123
  , opcode := .mulhsu
  , traceOpcode := (some .sltu)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 40
  , rs1Value := 18446744073709551610
  , rs2 := 42
  , rs2Value := 18446744073709551609
  , rd := 40
  , rdBefore := 18446744073709551610
  , rdAfter := 0
  , imm := 0
  , aluResult := 0
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 1)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 18
  , stepIndex := 2
  , sequenceIndex := 10
  , pc := 8
  , nextPc := 12
  , word := 40019123
  , opcode := .mulhsu
  , traceOpcode := (some .add)
  , traceVirtualOpcode := none
  , family := .multiply
  , rs1 := 43
  , rs1Value := 18446744073709551615
  , rs2 := 40
  , rs2Value := 0
  , rd := 9
  , rdBefore := 0
  , rdAfter := 18446744073709551615
  , imm := 0
  , aluResult := 18446744073709551615
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 0)
  , isEffectRow := true
  , isCommitRow := true
  , isReal := true
}, {
  traceIndex := 19
  , stepIndex := 3
  , sequenceIndex := 0
  , pc := 12
  , nextPc := 16
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
  , stage1 := { rows := [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 35689395, opcode := .mulh, traceOpcode := none, traceVirtualOpcode := (some .movsign), family := .multiply, nextPc := 0, aluResult := 18446744073709551615, effectiveAddr := none, writesRd := true, rd := 40, rdAfter := 18446744073709551615, isFirstInSequence := true, virtualSequenceRemaining := (some 6), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 1, stepIndex := 0, sequenceIndex := 1, fetchPc := 0, fetchedWord := 35689395, opcode := .mulh, traceOpcode := none, traceVirtualOpcode := (some .movsign), family := .multiply, nextPc := 0, aluResult := 18446744073709551615, effectiveAddr := none, writesRd := true, rd := 41, rdAfter := 18446744073709551615, isFirstInSequence := false, virtualSequenceRemaining := (some 5), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 2, stepIndex := 0, sequenceIndex := 2, fetchPc := 0, fetchedWord := 35689395, opcode := .mulh, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .multiply, nextPc := 0, aluResult := 3, effectiveAddr := none, writesRd := true, rd := 40, rdAfter := 3, isFirstInSequence := false, virtualSequenceRemaining := (some 4), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 3, stepIndex := 0, sequenceIndex := 3, fetchPc := 0, fetchedWord := 35689395, opcode := .mulh, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .multiply, nextPc := 0, aluResult := 2, effectiveAddr := none, writesRd := true, rd := 41, rdAfter := 2, isFirstInSequence := false, virtualSequenceRemaining := (some 3), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 4, stepIndex := 0, sequenceIndex := 4, fetchPc := 0, fetchedWord := 35689395, opcode := .mulh, traceOpcode := (some .mulhu), traceVirtualOpcode := none, family := .multiply, nextPc := 0, aluResult := 18446744073709551611, effectiveAddr := none, writesRd := true, rd := 42, rdAfter := 18446744073709551611, isFirstInSequence := false, virtualSequenceRemaining := (some 2), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 5, stepIndex := 0, sequenceIndex := 5, fetchPc := 0, fetchedWord := 35689395, opcode := .mulh, traceOpcode := (some .add), traceVirtualOpcode := none, family := .multiply, nextPc := 0, aluResult := 18446744073709551614, effectiveAddr := none, writesRd := true, rd := 42, rdAfter := 18446744073709551614, isFirstInSequence := false, virtualSequenceRemaining := (some 1), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 6, stepIndex := 0, sequenceIndex := 6, fetchPc := 0, fetchedWord := 35689395, opcode := .mulh, traceOpcode := (some .add), traceVirtualOpcode := none, family := .multiply, nextPc := 4, aluResult := 0, effectiveAddr := none, writesRd := true, rd := 7, rdAfter := 0, isFirstInSequence := false, virtualSequenceRemaining := (some 0), isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 7, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 37860403, opcode := .mulhu, traceOpcode := (some .mulhu), traceVirtualOpcode := none, family := .multiply, nextPc := 8, aluResult := 2, effectiveAddr := none, writesRd := true, rd := 8, rdAfter := 2, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 8, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 40019123, opcode := .mulhsu, traceOpcode := none, traceVirtualOpcode := (some .movsign), family := .multiply, nextPc := 8, aluResult := 18446744073709551615, effectiveAddr := none, writesRd := true, rd := 40, rdAfter := 18446744073709551615, isFirstInSequence := true, virtualSequenceRemaining := (some 10), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 9, stepIndex := 2, sequenceIndex := 1, fetchPc := 8, fetchedWord := 40019123, opcode := .mulhsu, traceOpcode := (some .andi), traceVirtualOpcode := none, family := .multiply, nextPc := 8, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 41, rdAfter := 1, isFirstInSequence := false, virtualSequenceRemaining := (some 9), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 10, stepIndex := 2, sequenceIndex := 2, fetchPc := 8, fetchedWord := 40019123, opcode := .mulhsu, traceOpcode := (some .xor), traceVirtualOpcode := none, family := .multiply, nextPc := 8, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 42, rdAfter := 1, isFirstInSequence := false, virtualSequenceRemaining := (some 8), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 11, stepIndex := 2, sequenceIndex := 3, fetchPc := 8, fetchedWord := 40019123, opcode := .mulhsu, traceOpcode := (some .add), traceVirtualOpcode := none, family := .multiply, nextPc := 8, aluResult := 2, effectiveAddr := none, writesRd := true, rd := 42, rdAfter := 2, isFirstInSequence := false, virtualSequenceRemaining := (some 7), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 12, stepIndex := 2, sequenceIndex := 4, fetchPc := 8, fetchedWord := 40019123, opcode := .mulhsu, traceOpcode := (some .mulhu), traceVirtualOpcode := none, family := .multiply, nextPc := 8, aluResult := 0, effectiveAddr := none, writesRd := true, rd := 43, rdAfter := 0, isFirstInSequence := false, virtualSequenceRemaining := (some 6), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 13, stepIndex := 2, sequenceIndex := 5, fetchPc := 8, fetchedWord := 40019123, opcode := .mulhsu, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .multiply, nextPc := 8, aluResult := 6, effectiveAddr := none, writesRd := true, rd := 42, rdAfter := 6, isFirstInSequence := false, virtualSequenceRemaining := (some 5), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 14, stepIndex := 2, sequenceIndex := 6, fetchPc := 8, fetchedWord := 40019123, opcode := .mulhsu, traceOpcode := (some .xor), traceVirtualOpcode := none, family := .multiply, nextPc := 8, aluResult := 18446744073709551615, effectiveAddr := none, writesRd := true, rd := 43, rdAfter := 18446744073709551615, isFirstInSequence := false, virtualSequenceRemaining := (some 4), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 15, stepIndex := 2, sequenceIndex := 7, fetchPc := 8, fetchedWord := 40019123, opcode := .mulhsu, traceOpcode := (some .xor), traceVirtualOpcode := none, family := .multiply, nextPc := 8, aluResult := 18446744073709551609, effectiveAddr := none, writesRd := true, rd := 42, rdAfter := 18446744073709551609, isFirstInSequence := false, virtualSequenceRemaining := (some 3), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 16, stepIndex := 2, sequenceIndex := 8, fetchPc := 8, fetchedWord := 40019123, opcode := .mulhsu, traceOpcode := (some .add), traceVirtualOpcode := none, family := .multiply, nextPc := 8, aluResult := 18446744073709551610, effectiveAddr := none, writesRd := true, rd := 40, rdAfter := 18446744073709551610, isFirstInSequence := false, virtualSequenceRemaining := (some 2), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 17, stepIndex := 2, sequenceIndex := 9, fetchPc := 8, fetchedWord := 40019123, opcode := .mulhsu, traceOpcode := (some .sltu), traceVirtualOpcode := none, family := .multiply, nextPc := 8, aluResult := 0, effectiveAddr := none, writesRd := true, rd := 40, rdAfter := 0, isFirstInSequence := false, virtualSequenceRemaining := (some 1), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 18, stepIndex := 2, sequenceIndex := 10, fetchPc := 8, fetchedWord := 40019123, opcode := .mulhsu, traceOpcode := (some .add), traceVirtualOpcode := none, family := .multiply, nextPc := 12, aluResult := 18446744073709551615, effectiveAddr := none, writesRd := true, rd := 9, rdAfter := 18446744073709551615, isFirstInSequence := false, virtualSequenceRemaining := (some 0), isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 19, stepIndex := 3, sequenceIndex := 0, fetchPc := 12, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 16, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }] }
  , stage2 := {
  registerReads := [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 1, value := 18446744073709551614 }, { traceIndex := 1, stepIndex := 0, role := .rs1, reg := 2, value := 18446744073709551613 }, { traceIndex := 2, stepIndex := 0, role := .rs1, reg := 40, value := 18446744073709551615 }, { traceIndex := 2, stepIndex := 0, role := .rs2, reg := 2, value := 18446744073709551613 }, { traceIndex := 3, stepIndex := 0, role := .rs1, reg := 41, value := 18446744073709551615 }, { traceIndex := 3, stepIndex := 0, role := .rs2, reg := 1, value := 18446744073709551614 }, { traceIndex := 4, stepIndex := 0, role := .rs1, reg := 1, value := 18446744073709551614 }, { traceIndex := 4, stepIndex := 0, role := .rs2, reg := 2, value := 18446744073709551613 }, { traceIndex := 5, stepIndex := 0, role := .rs1, reg := 42, value := 18446744073709551611 }, { traceIndex := 5, stepIndex := 0, role := .rs2, reg := 40, value := 3 }, { traceIndex := 6, stepIndex := 0, role := .rs1, reg := 42, value := 18446744073709551614 }, { traceIndex := 6, stepIndex := 0, role := .rs2, reg := 41, value := 2 }, { traceIndex := 7, stepIndex := 1, role := .rs1, reg := 3, value := 18446744073709551614 }, { traceIndex := 7, stepIndex := 1, role := .rs2, reg := 4, value := 3 }, { traceIndex := 8, stepIndex := 2, role := .rs1, reg := 5, value := 18446744073709551614 }, { traceIndex := 9, stepIndex := 2, role := .rs1, reg := 40, value := 18446744073709551615 }, { traceIndex := 10, stepIndex := 2, role := .rs1, reg := 5, value := 18446744073709551614 }, { traceIndex := 10, stepIndex := 2, role := .rs2, reg := 40, value := 18446744073709551615 }, { traceIndex := 11, stepIndex := 2, role := .rs1, reg := 42, value := 1 }, { traceIndex := 11, stepIndex := 2, role := .rs2, reg := 41, value := 1 }, { traceIndex := 12, stepIndex := 2, role := .rs1, reg := 42, value := 2 }, { traceIndex := 12, stepIndex := 2, role := .rs2, reg := 6, value := 3 }, { traceIndex := 13, stepIndex := 2, role := .rs1, reg := 42, value := 2 }, { traceIndex := 13, stepIndex := 2, role := .rs2, reg := 6, value := 3 }, { traceIndex := 14, stepIndex := 2, role := .rs1, reg := 43, value := 0 }, { traceIndex := 14, stepIndex := 2, role := .rs2, reg := 40, value := 18446744073709551615 }, { traceIndex := 15, stepIndex := 2, role := .rs1, reg := 42, value := 6 }, { traceIndex := 15, stepIndex := 2, role := .rs2, reg := 40, value := 18446744073709551615 }, { traceIndex := 16, stepIndex := 2, role := .rs1, reg := 42, value := 18446744073709551609 }, { traceIndex := 16, stepIndex := 2, role := .rs2, reg := 41, value := 1 }, { traceIndex := 17, stepIndex := 2, role := .rs1, reg := 40, value := 18446744073709551610 }, { traceIndex := 17, stepIndex := 2, role := .rs2, reg := 42, value := 18446744073709551609 }, { traceIndex := 18, stepIndex := 2, role := .rs1, reg := 43, value := 18446744073709551615 }, { traceIndex := 18, stepIndex := 2, role := .rs2, reg := 40, value := 0 }]
  , registerWrites := [{ traceIndex := 0, stepIndex := 0, reg := 40, previous := 0, next := 18446744073709551615 }, { traceIndex := 1, stepIndex := 0, reg := 41, previous := 0, next := 18446744073709551615 }, { traceIndex := 2, stepIndex := 0, reg := 40, previous := 18446744073709551615, next := 3 }, { traceIndex := 3, stepIndex := 0, reg := 41, previous := 18446744073709551615, next := 2 }, { traceIndex := 4, stepIndex := 0, reg := 42, previous := 0, next := 18446744073709551611 }, { traceIndex := 5, stepIndex := 0, reg := 42, previous := 18446744073709551611, next := 18446744073709551614 }, { traceIndex := 6, stepIndex := 0, reg := 7, previous := 0, next := 0 }, { traceIndex := 7, stepIndex := 1, reg := 8, previous := 0, next := 2 }, { traceIndex := 8, stepIndex := 2, reg := 40, previous := 0, next := 18446744073709551615 }, { traceIndex := 9, stepIndex := 2, reg := 41, previous := 0, next := 1 }, { traceIndex := 10, stepIndex := 2, reg := 42, previous := 0, next := 1 }, { traceIndex := 11, stepIndex := 2, reg := 42, previous := 1, next := 2 }, { traceIndex := 12, stepIndex := 2, reg := 43, previous := 0, next := 0 }, { traceIndex := 13, stepIndex := 2, reg := 42, previous := 2, next := 6 }, { traceIndex := 14, stepIndex := 2, reg := 43, previous := 0, next := 18446744073709551615 }, { traceIndex := 15, stepIndex := 2, reg := 42, previous := 6, next := 18446744073709551609 }, { traceIndex := 16, stepIndex := 2, reg := 40, previous := 18446744073709551615, next := 18446744073709551610 }, { traceIndex := 17, stepIndex := 2, reg := 40, previous := 18446744073709551610, next := 0 }, { traceIndex := 18, stepIndex := 2, reg := 9, previous := 0, next := 18446744073709551615 }]
  , ramEvents := []
  , twistLinks := [{ traceIndex := 0, stepIndex := 0, family := .multiply, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 0, family := .multiply, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 0, family := .multiply, routedWriteValue := (some 3), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 0, family := .multiply, routedWriteValue := (some 2), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 4, stepIndex := 0, family := .multiply, routedWriteValue := (some 18446744073709551611), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 5, stepIndex := 0, family := .multiply, routedWriteValue := (some 18446744073709551614), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 6, stepIndex := 0, family := .multiply, routedWriteValue := (some 0), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 7, stepIndex := 1, family := .multiply, routedWriteValue := (some 2), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 8, stepIndex := 2, family := .multiply, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 9, stepIndex := 2, family := .multiply, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 10, stepIndex := 2, family := .multiply, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 11, stepIndex := 2, family := .multiply, routedWriteValue := (some 2), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 12, stepIndex := 2, family := .multiply, routedWriteValue := (some 0), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 13, stepIndex := 2, family := .multiply, routedWriteValue := (some 6), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 14, stepIndex := 2, family := .multiply, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 15, stepIndex := 2, family := .multiply, routedWriteValue := (some 18446744073709551609), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 16, stepIndex := 2, family := .multiply, routedWriteValue := (some 18446744073709551610), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 17, stepIndex := 2, family := .multiply, routedWriteValue := (some 0), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 18, stepIndex := 2, family := .multiply, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 19, stepIndex := 3, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]
}
  , stage3 := {
  continuity := [{ stepIndex := 0, pc := 0, nextPc := 4, successorPc := (some 4), finalStep := false, continuityHolds := true }, { stepIndex := 1, pc := 4, nextPc := 8, successorPc := (some 8), finalStep := false, continuityHolds := true }, { stepIndex := 2, pc := 8, nextPc := 12, successorPc := (some 12), finalStep := false, continuityHolds := true }, { stepIndex := 3, pc := 12, nextPc := 16, successorPc := none, finalStep := true, continuityHolds := true }]
  , halted := true
}
  , transcript := {
  appLabel := (bytes [110, 101, 111, 46, 102, 111, 108, 100, 46, 110, 101, 120, 116, 47, 114, 118, 54, 52, 105, 109, 47, 112, 97, 114, 105, 116, 121, 95, 107, 101, 114, 110, 101, 108, 95, 118, 49])
  , events := [{
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 116, 114, 97, 110, 115, 99, 114, 105, 112, 116, 95, 115, 101, 101, 100])
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 109, 117, 108, 116, 105, 112, 108, 121, 45, 104, 105, 103, 104, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [12781167311334777, 12662, 12823906427971971140, 5458687368011659338, 248951889722183994, 6447366553477719410, 671691480699588116, 16458339740995496313], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [109, 117, 108, 116, 105, 112, 108, 121, 95, 104, 105, 103, 104, 95, 109, 117, 108, 104, 95, 109, 117, 108, 104, 117, 95, 109, 117, 108, 104, 115, 117, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [12781167311334777, 12662, 12823906427971971140, 5458687368011659338, 248951889722183994, 6447366553477719410, 671691480699588116, 16458339740995496313], absorbed := 2 }
  , cursorAfter := { stateWords := [27412359785313128, 27756, 2108779813393257755, 10371293853381360518, 16650352946910516604, 15704720784864639920, 634774211277878388, 2635468374773951633], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [35689395, 37860403, 40019123, 115]
  , cursorBefore := { stateWords := [27412359785313128, 27756, 2108779813393257755, 10371293853381360518, 16650352946910516604, 15704720784864639920, 634774211277878388, 2635468374773951633], absorbed := 2 }
  , cursorAfter := { stateWords := [8812575801016892909, 13040938893226428394, 9701684088077420472, 5819287778781878817, 17896264116935920441, 16593576036334108354, 18272699806094930130, 16560517447366102286], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 18446744073709551614, 18446744073709551613, 18446744073709551614, 3, 18446744073709551614, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [8812575801016892909, 13040938893226428394, 9701684088077420472, 5819287778781878817, 17896264116935920441, 16593576036334108354, 18272699806094930130, 16560517447366102286], absorbed := 0 }
  , cursorAfter := { stateWords := [0, 0, 16580090554124809443, 14270154524921358245, 4254892177879671707, 15516828335114826966, 1193383185617325903, 1696859638442303879], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [0, 0, 16580090554124809443, 14270154524921358245, 4254892177879671707, 15516828335114826966, 1193383185617325903, 1696859638442303879], absorbed := 2 }
  , cursorAfter := { stateWords := [13348506805888363, 30506403037277801, 34184295084289375, 0, 15284436219820320381, 4680745356388154385, 1520290972219069691, 3768744203301526206], absorbed := 4 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [243, 33, 113, 153, 9, 235, 68, 117, 29, 132, 237, 169, 175, 129, 160, 239, 59, 177, 90, 147, 52, 212, 120, 200, 192, 235, 87, 137, 127, 175, 131, 194])
  , u64s := []
  , cursorBefore := { stateWords := [13348506805888363, 30506403037277801, 34184295084289375, 0, 15284436219820320381, 4680745356388154385, 1520290972219069691, 3768744203301526206], absorbed := 4 }
  , cursorAfter := { stateWords := [14798716518789024, 38658741872654548, 3263410047, 16203063846249563458, 15952904281250505407, 11239127835845179134, 8682037629199545325, 12571069164232736769], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [14798716518789024, 38658741872654548, 3263410047, 16203063846249563458, 15952904281250505407, 11239127835845179134, 8682037629199545325, 12571069164232736769], absorbed := 3 }
  , cursorAfter := { stateWords := [12594224946114062434, 9120832401951012423, 15716666784263486997, 11771319206861947326, 14170695275895613368, 18155581864986460640, 8390403638239530622, 7721570034433765440], absorbed := 0 }
  , challengeOutput := (some 12594224946114062434)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [254, 135, 111, 142, 154, 116, 166, 185, 185, 222, 69, 53, 63, 69, 145, 188, 248, 151, 195, 191, 15, 203, 170, 159, 58, 111, 210, 59, 37, 159, 20, 59])
  , u64s := []
  , cursorBefore := { stateWords := [12594224946114062434, 9120832401951012423, 15716666784263486997, 11771319206861947326, 14170695275895613368, 18155581864986460640, 8390403638239530622, 7721570034433765440], absorbed := 0 }
  , cursorAfter := { stateWords := [4432971439848593, 16838398792673995, 991207205, 13523020166566597734, 9474816557060974975, 9682101722884499574, 11183025813400782569, 3504594574146367975], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [4432971439848593, 16838398792673995, 991207205, 13523020166566597734, 9474816557060974975, 9682101722884499574, 11183025813400782569, 3504594574146367975], absorbed := 3 }
  , cursorAfter := { stateWords := [7181907923970274102, 13984652350835454030, 14248157083981992134, 3489245716409723724, 11591148485536643942, 58840783525940945, 17639195001505837769, 4797479933805059576], absorbed := 0 }
  , challengeOutput := (some 7181907923970274102)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [7181907923970274102, 13984652350835454030, 14248157083981992134, 3489245716409723724, 11591148485536643942, 58840783525940945, 17639195001505837769, 4797479933805059576], absorbed := 0 }
  , cursorAfter := { stateWords := [4010680615921688272, 13559547375383272054, 12952106149071049557, 8601534984265556976, 9181871138784389685, 6401828817326474128, 2194921800358647068, 16636817962305181241], absorbed := 0 }
  , challengeOutput := (some 4010680615921688272)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [7, 82, 83, 13, 122, 202, 121, 111, 107, 12, 23, 144, 227, 48, 106, 126, 125, 114, 5, 27, 67, 29, 185, 192, 203, 20, 116, 55, 18, 178, 169, 18])
  , u64s := []
  , cursorBefore := { stateWords := [4010680615921688272, 13559547375383272054, 12952106149071049557, 8601534984265556976, 9181871138784389685, 6401828817326474128, 2194921800358647068, 16636817962305181241], absorbed := 0 }
  , cursorAfter := { stateWords := [18888533649227370, 15608756385659165, 313111058, 15518322506709063147, 2177833574961461427, 3085926819598395256, 10659100617218763088, 293927510401203621], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [18888533649227370, 15608756385659165, 313111058, 15518322506709063147, 2177833574961461427, 3085926819598395256, 10659100617218763088, 293927510401203621], absorbed := 3 }
  , cursorAfter := { stateWords := [16732273574652248418, 17216660654101797934, 8681142069474142655, 8589526100054592674, 12425421892153250114, 10855469906391529383, 15040391767145915989, 14904572834527225910], absorbed := 0 }
  , challengeOutput := (some 16732273574652248418)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [242, 180, 211, 44, 136, 191, 129, 103, 121, 27, 189, 177, 57, 84, 107, 37, 200, 205, 250, 244, 70, 251, 148, 129, 186, 236, 174, 139, 158, 109, 21, 76])
  , u64s := []
  , cursorBefore := { stateWords := [16732273574652248418, 17216660654101797934, 8681142069474142655, 8589526100054592674, 12425421892153250114, 10855469906391529383, 15040391767145915989, 14904572834527225910], absorbed := 0 }
  , cursorAfter := { stateWords := [19972606401193323, 39317353527350523, 1276472734, 230307616887654781, 12142287865684510284, 1060846835713975250, 903991690148070134, 15589771422270397194], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [253, 56, 202, 101, 142, 132, 93, 134, 75, 217, 118, 33, 12, 112, 138, 94, 76, 57, 89, 198, 120, 58, 231, 25, 226, 162, 224, 124, 164, 228, 241, 216])
  , u64s := []
  , cursorBefore := { stateWords := [19972606401193323, 39317353527350523, 1276472734, 230307616887654781, 12142287865684510284, 1060846835713975250, 903991690148070134, 15589771422270397194], absorbed := 3 }
  , cursorAfter := { stateWords := [33995083720973962, 35149887294793530, 3639731364, 11322723073178918445, 15677348921421630016, 3056688719395752326, 9239857230922062512, 8647286844324451561], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [64, 177, 68, 187, 81, 87, 252, 39, 65, 209, 64, 178, 63, 178, 69, 5, 247, 172, 14, 148, 78, 120, 110, 92, 118, 191, 130, 29, 111, 21, 65, 215])
  , u64s := []
  , cursorBefore := { stateWords := [33995083720973962, 35149887294793530, 3639731364, 11322723073178918445, 15677348921421630016, 3056688719395752326, 9239857230922062512, 8647286844324451561], absorbed := 3 }
  , cursorAfter := { stateWords := [22117838935754053, 8306533160742520, 3611366767, 15240032141194505930, 17094688214166531567, 3210725922644817130, 13724988163006776507, 17795306660117163208], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [22117838935754053, 8306533160742520, 3611366767, 15240032141194505930, 17094688214166531567, 3210725922644817130, 13724988163006776507, 17795306660117163208], absorbed := 3 }
  , cursorAfter := { stateWords := [6150446324893315326, 13940408834710205269, 3096927730202394539, 3312457634550628283, 18189760578090884427, 14404345729445534689, 2505855645016552390, 4862682994486841645], absorbed := 0 }
  , challengeOutput := (some 6150446324893315326)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [6150446324893315326, 13940408834710205269, 3096927730202394539, 3312457634550628283, 18189760578090884427, 14404345729445534689, 2505855645016552390, 4862682994486841645], absorbed := 0 }
  , cursorAfter := { stateWords := [12156655443619780216, 11474363165590510420, 8333141750803102578, 14298929851964528614, 10874228520263782992, 3844157008634569532, 7739098619381804857, 15111327435554719867], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [120, 150, 198, 157, 183, 29, 181, 168, 84, 91, 217, 92, 129, 32, 61, 159, 114, 123, 152, 127, 69, 68, 165, 115, 230, 23, 147, 254, 240, 0, 112, 198]))
}]
}
  , kernel := {
  root0Digest := (bytes [243, 33, 113, 153, 9, 235, 68, 117, 29, 132, 237, 169, 175, 129, 160, 239, 59, 177, 90, 147, 52, 212, 120, 200, 192, 235, 87, 137, 127, 175, 131, 194])
  , stage1Digest := (bytes [254, 135, 111, 142, 154, 116, 166, 185, 185, 222, 69, 53, 63, 69, 145, 188, 248, 151, 195, 191, 15, 203, 170, 159, 58, 111, 210, 59, 37, 159, 20, 59])
  , stage2Digest := (bytes [7, 82, 83, 13, 122, 202, 121, 111, 107, 12, 23, 144, 227, 48, 106, 126, 125, 114, 5, 27, 67, 29, 185, 192, 203, 20, 116, 55, 18, 178, 169, 18])
  , stage3Digest := (bytes [242, 180, 211, 44, 136, 191, 129, 103, 121, 27, 189, 177, 57, 84, 107, 37, 200, 205, 250, 244, 70, 251, 148, 129, 186, 236, 174, 139, 158, 109, 21, 76])
  , executionDigest := (bytes [253, 56, 202, 101, 142, 132, 93, 134, 75, 217, 118, 33, 12, 112, 138, 94, 76, 57, 89, 198, 120, 58, 231, 25, 226, 162, 224, 124, 164, 228, 241, 216])
  , finalStateDigest := (bytes [64, 177, 68, 187, 81, 87, 252, 39, 65, 209, 64, 178, 63, 178, 69, 5, 247, 172, 14, 148, 78, 120, 110, 92, 118, 191, 130, 29, 111, 21, 65, 215])
  , stage1Mix := 12594224946114062434
  , stage2RegMix := 7181907923970274102
  , stage2RamMix := 4010680615921688272
  , stage3ContinuityMix := 16732273574652248418
  , kernelFinalMix := 6150446324893315326
  , transcriptFinalDigest := (bytes [120, 150, 198, 157, 183, 29, 181, 168, 84, 91, 217, 92, 129, 32, 61, 159, 114, 123, 152, 127, 69, 68, 165, 115, 230, 23, 147, 254, 240, 0, 112, 198])
  , finalPc := 16
  , finalRegisters := [0, 18446744073709551614, 18446744073709551613, 18446744073709551614, 3, 18446744073709551614, 3, 0, 2, 18446744073709551615, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , finalMemory := []
  , halted := true
}
}
    , kernelProof := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "multiply_high_mulh_mulhu_mulhsu_ecall", fixtureId := "multiply_high_mulh_mulhu_mulhsu_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.multiply, .controlFlow] }
  , executionDigest := (bytes [253, 56, 202, 101, 142, 132, 93, 134, 75, 217, 118, 33, 12, 112, 138, 94, 76, 57, 89, 198, 120, 58, 231, 25, 226, 162, 224, 124, 164, 228, 241, 216])
  , shape := { executionRowCount := 20, realRowCount := 4, effectRowCount := 4, commitRowCount := 4, digest := (bytes [59, 163, 65, 114, 71, 203, 144, 250, 133, 131, 27, 218, 175, 132, 145, 9, 167, 224, 25, 210, 57, 136, 160, 228, 226, 219, 137, 198, 45, 37, 220, 249]) }
  , digest := (bytes [87, 190, 113, 20, 186, 182, 14, 185, 37, 191, 147, 144, 5, 87, 60, 209, 224, 173, 239, 91, 134, 183, 254, 180, 78, 119, 90, 185, 106, 193, 86, 105])
}
  , stages := { summary := { stage1RowCount := 20, stage2RegisterReadCount := 34, stage2RegisterWriteCount := 19, stage2RamEventCount := 0, stage2TwistLinkCount := 20, stage3ContinuityCount := 4, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [255, 24, 93, 239, 18, 91, 171, 28, 223, 204, 202, 124, 227, 86, 233, 201, 83, 172, 80, 193, 136, 215, 72, 104, 247, 205, 80, 146, 165, 255, 200, 255]) }, digest := (bytes [245, 102, 156, 90, 74, 70, 146, 73, 212, 89, 104, 24, 161, 60, 41, 146, 100, 19, 24, 43, 92, 110, 220, 101, 4, 86, 90, 196, 253, 64, 18, 42]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [70, 47, 32, 181, 107, 177, 216, 251, 0, 96, 119, 64, 150, 0, 74, 134, 39, 166, 239, 171, 130, 128, 99, 70, 185, 223, 7, 31, 93, 150, 85, 55]), stage1Digest := (bytes [119, 218, 212, 143, 84, 5, 68, 70, 103, 149, 150, 166, 87, 83, 126, 28, 62, 243, 151, 29, 60, 52, 29, 156, 124, 167, 241, 115, 150, 56, 50, 228]), stage2Digest := (bytes [189, 140, 3, 161, 137, 109, 65, 178, 71, 224, 130, 138, 61, 59, 201, 89, 255, 58, 87, 9, 210, 58, 150, 166, 7, 97, 142, 52, 198, 124, 61, 7]), stage3Digest := (bytes [36, 225, 132, 194, 224, 112, 136, 254, 241, 228, 10, 51, 211, 162, 201, 21, 129, 198, 178, 230, 72, 16, 240, 160, 192, 242, 8, 234, 55, 33, 177, 139]), transcriptDigest := (bytes [120, 150, 198, 157, 183, 29, 181, 168, 84, 91, 217, 92, 129, 32, 61, 159, 114, 123, 152, 127, 69, 68, 165, 115, 230, 23, 147, 254, 240, 0, 112, 198]), executionDigest := (bytes [253, 56, 202, 101, 142, 132, 93, 134, 75, 217, 118, 33, 12, 112, 138, 94, 76, 57, 89, 198, 120, 58, 231, 25, 226, 162, 224, 124, 164, 228, 241, 216]), digest := (bytes [255, 249, 153, 248, 151, 143, 63, 2, 185, 112, 164, 47, 36, 214, 3, 20, 30, 60, 58, 8, 190, 192, 175, 58, 171, 177, 116, 180, 157, 92, 52, 245]) }, statementDigest := (bytes [65, 170, 247, 137, 42, 100, 251, 203, 22, 85, 243, 254, 99, 185, 112, 125, 180, 33, 208, 243, 113, 32, 49, 129, 63, 112, 67, 250, 127, 76, 52, 129]), proofDigest := (bytes [104, 146, 73, 104, 116, 95, 200, 172, 230, 213, 189, 116, 148, 86, 238, 55, 94, 87, 141, 7, 170, 31, 11, 133, 156, 193, 26, 80, 239, 191, 128, 227]), digest := (bytes [154, 191, 59, 142, 143, 78, 16, 57, 13, 122, 149, 108, 83, 186, 13, 160, 101, 219, 21, 202, 214, 211, 41, 112, 34, 249, 222, 108, 174, 63, 179, 237]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [253, 68, 102, 128, 114, 247, 96, 30, 42, 155, 72, 120, 189, 122, 83, 246, 73, 123, 104, 153, 131, 27, 149, 124, 249, 24, 106, 81, 205, 160, 156, 232]), stage1Digest := (bytes [6, 10, 87, 34, 241, 198, 152, 111, 25, 24, 54, 182, 89, 57, 247, 48, 242, 144, 226, 150, 167, 143, 175, 224, 254, 182, 192, 43, 164, 232, 67, 22]), stage2Digest := (bytes [218, 40, 31, 235, 102, 3, 46, 12, 84, 131, 99, 11, 21, 10, 80, 37, 106, 103, 252, 44, 250, 58, 169, 51, 76, 29, 215, 63, 181, 188, 27, 111]), stage3Digest := (bytes [11, 50, 217, 85, 206, 200, 239, 139, 234, 25, 96, 96, 132, 20, 133, 5, 36, 123, 115, 179, 2, 255, 142, 86, 179, 60, 240, 89, 255, 62, 179, 48]), digest := (bytes [179, 79, 124, 213, 197, 219, 93, 112, 48, 42, 73, 201, 179, 124, 255, 216, 54, 77, 106, 35, 178, 39, 18, 1, 199, 24, 17, 127, 89, 156, 94, 37]) }, digest := (bytes [27, 207, 142, 24, 29, 52, 215, 192, 49, 83, 98, 73, 13, 203, 80, 250, 150, 170, 175, 117, 0, 22, 29, 27, 195, 243, 22, 118, 42, 207, 134, 126]) }
  , kernelOpening := { openingDigest := (bytes [198, 84, 146, 64, 111, 119, 190, 121, 159, 108, 161, 239, 196, 219, 253, 57, 156, 179, 128, 200, 150, 72, 115, 128, 184, 62, 117, 82, 200, 134, 59, 132]), bindings := { claimDigest := (bytes [57, 252, 166, 206, 50, 86, 5, 153, 150, 113, 83, 200, 199, 104, 253, 16, 89, 102, 78, 215, 127, 45, 39, 160, 68, 94, 193, 22, 228, 124, 251, 217]), bindingsDigest := (bytes [229, 202, 10, 251, 106, 127, 222, 240, 249, 36, 93, 163, 113, 62, 72, 62, 57, 8, 91, 47, 197, 119, 41, 238, 165, 135, 41, 137, 39, 142, 226, 11]), preparedStepsDigest := (bytes [160, 151, 120, 21, 206, 145, 64, 91, 14, 148, 98, 135, 27, 128, 129, 141, 192, 57, 207, 232, 9, 243, 128, 103, 109, 149, 129, 179, 71, 87, 65, 181]), digest := (bytes [182, 190, 74, 60, 203, 251, 25, 255, 203, 111, 169, 173, 153, 233, 249, 22, 157, 151, 48, 46, 82, 90, 141, 149, 110, 70, 220, 144, 91, 87, 107, 117]) }, digest := (bytes [141, 147, 194, 158, 1, 113, 164, 5, 52, 60, 204, 22, 214, 218, 60, 235, 163, 130, 167, 78, 77, 79, 166, 89, 20, 6, 80, 169, 90, 145, 220, 253]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [56, 55, 65, 136, 166, 105, 55, 221, 32, 59, 92, 217, 19, 218, 150, 142, 9, 231, 253, 237, 17, 141, 61, 10, 157, 65, 174, 106, 188, 85, 117, 232]), terminal := { root0Digest := (bytes [243, 33, 113, 153, 9, 235, 68, 117, 29, 132, 237, 169, 175, 129, 160, 239, 59, 177, 90, 147, 52, 212, 120, 200, 192, 235, 87, 137, 127, 175, 131, 194]), executionDigest := (bytes [253, 56, 202, 101, 142, 132, 93, 134, 75, 217, 118, 33, 12, 112, 138, 94, 76, 57, 89, 198, 120, 58, 231, 25, 226, 162, 224, 124, 164, 228, 241, 216]), finalStateDigest := (bytes [64, 177, 68, 187, 81, 87, 252, 39, 65, 209, 64, 178, 63, 178, 69, 5, 247, 172, 14, 148, 78, 120, 110, 92, 118, 191, 130, 29, 111, 21, 65, 215]), transcriptFinalDigest := (bytes [120, 150, 198, 157, 183, 29, 181, 168, 84, 91, 217, 92, 129, 32, 61, 159, 114, 123, 152, 127, 69, 68, 165, 115, 230, 23, 147, 254, 240, 0, 112, 198]), finalPc := 16, halted := true, digest := (bytes [171, 30, 191, 224, 99, 223, 179, 117, 65, 45, 229, 73, 132, 2, 198, 34, 76, 148, 13, 19, 129, 37, 20, 65, 127, 7, 62, 77, 92, 35, 32, 125]) }, digest := (bytes [110, 101, 243, 133, 133, 41, 232, 139, 240, 162, 182, 159, 61, 123, 193, 9, 167, 76, 83, 71, 24, 83, 67, 116, 247, 59, 84, 55, 31, 113, 173, 156]) }, statementDigest := (bytes [112, 113, 21, 103, 107, 197, 161, 221, 119, 129, 146, 170, 156, 57, 144, 189, 106, 201, 102, 13, 245, 131, 180, 125, 41, 26, 184, 82, 105, 229, 160, 44]), proofDigest := (bytes [5, 43, 177, 20, 43, 145, 65, 217, 251, 241, 227, 77, 229, 213, 236, 99, 136, 172, 221, 132, 130, 21, 67, 230, 22, 38, 32, 8, 120, 139, 196, 252]), digest := (bytes [38, 238, 244, 237, 19, 102, 134, 67, 255, 223, 166, 62, 88, 132, 120, 38, 23, 234, 112, 247, 106, 254, 59, 151, 138, 102, 58, 65, 200, 148, 101, 31]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [171, 224, 63, 43, 249, 74, 225, 231, 62, 81, 99, 246, 21, 22, 245, 111, 89, 94, 177, 243, 37, 191, 68, 180, 9, 24, 201, 59, 114, 116, 96, 14]), layoutVersion := 1, digest := (bytes [195, 60, 175, 242, 0, 182, 128, 130, 166, 241, 208, 233, 227, 162, 249, 61, 247, 191, 144, 26, 215, 50, 223, 212, 108, 31, 169, 122, 166, 223, 167, 83]) }, rowWidth := 38, timeLen := 20, columnDigests := [(bytes [199, 57, 218, 242, 224, 219, 158, 68, 215, 187, 96, 181, 151, 77, 205, 24, 48, 176, 155, 147, 109, 207, 131, 76, 49, 50, 103, 236, 189, 78, 9, 147]), (bytes [99, 48, 0, 205, 223, 203, 201, 183, 80, 150, 15, 104, 75, 254, 20, 172, 5, 27, 49, 46, 89, 164, 236, 136, 72, 153, 142, 0, 42, 148, 252, 208]), (bytes [36, 195, 3, 23, 204, 207, 187, 92, 134, 65, 178, 127, 245, 52, 1, 162, 126, 151, 221, 177, 208, 31, 231, 155, 90, 58, 153, 245, 68, 0, 240, 103]), (bytes [89, 63, 211, 203, 102, 246, 143, 81, 89, 207, 248, 85, 99, 165, 30, 91, 192, 59, 192, 250, 16, 166, 139, 207, 219, 207, 36, 142, 232, 96, 192, 44]), (bytes [113, 127, 125, 130, 71, 31, 68, 221, 233, 32, 247, 34, 239, 167, 174, 36, 31, 184, 199, 64, 194, 125, 224, 240, 191, 198, 237, 167, 62, 90, 96, 14]), (bytes [186, 200, 182, 147, 241, 252, 231, 126, 240, 229, 127, 182, 218, 96, 185, 151, 145, 86, 52, 78, 20, 31, 94, 133, 56, 247, 201, 49, 168, 6, 115, 210]), (bytes [20, 239, 222, 15, 28, 249, 226, 194, 34, 201, 188, 165, 49, 102, 255, 52, 17, 120, 85, 66, 76, 236, 75, 106, 241, 40, 111, 2, 199, 49, 66, 129]), (bytes [155, 229, 31, 161, 157, 48, 177, 68, 31, 151, 237, 55, 220, 226, 115, 87, 178, 72, 240, 124, 163, 209, 241, 233, 81, 208, 232, 166, 72, 132, 207, 121]), (bytes [141, 140, 151, 173, 50, 143, 215, 38, 128, 21, 96, 159, 60, 16, 93, 194, 28, 165, 7, 118, 136, 8, 254, 34, 209, 124, 210, 88, 134, 172, 165, 242]), (bytes [199, 162, 226, 113, 228, 252, 225, 138, 196, 134, 111, 23, 169, 182, 26, 100, 208, 27, 39, 53, 145, 219, 86, 152, 192, 237, 175, 179, 167, 93, 188, 94]), (bytes [191, 167, 98, 84, 60, 165, 246, 85, 129, 174, 87, 162, 68, 168, 194, 224, 187, 111, 92, 227, 53, 121, 5, 48, 7, 228, 167, 191, 137, 229, 166, 170]), (bytes [160, 102, 96, 180, 246, 11, 52, 159, 119, 76, 141, 231, 133, 23, 9, 119, 228, 1, 70, 206, 126, 162, 179, 28, 156, 184, 163, 31, 182, 58, 88, 215]), (bytes [119, 144, 167, 4, 144, 100, 3, 176, 118, 116, 10, 43, 195, 7, 229, 110, 54, 108, 24, 115, 166, 12, 93, 185, 8, 236, 7, 93, 53, 189, 116, 238]), (bytes [160, 140, 215, 227, 142, 180, 183, 126, 61, 192, 126, 80, 155, 85, 239, 167, 248, 137, 93, 73, 1, 200, 114, 168, 112, 221, 50, 21, 238, 112, 66, 137]), (bytes [29, 191, 87, 134, 114, 120, 112, 77, 54, 230, 225, 160, 156, 69, 104, 233, 35, 230, 20, 201, 163, 119, 150, 230, 235, 74, 203, 254, 28, 129, 68, 144]), (bytes [220, 134, 74, 254, 168, 170, 90, 218, 220, 173, 45, 14, 192, 32, 17, 92, 118, 17, 21, 108, 194, 255, 107, 224, 122, 195, 197, 203, 150, 35, 246, 38]), (bytes [23, 221, 175, 82, 173, 40, 177, 63, 122, 124, 63, 200, 23, 59, 66, 72, 139, 28, 221, 165, 134, 118, 18, 108, 110, 25, 104, 195, 235, 31, 183, 105]), (bytes [19, 242, 208, 114, 246, 72, 120, 4, 108, 22, 97, 237, 194, 18, 147, 141, 70, 8, 138, 161, 44, 126, 1, 150, 233, 62, 99, 194, 228, 4, 7, 60]), (bytes [143, 63, 44, 207, 193, 170, 223, 121, 72, 38, 251, 158, 186, 24, 156, 134, 119, 200, 24, 69, 58, 205, 28, 146, 68, 123, 182, 59, 187, 70, 101, 157]), (bytes [82, 198, 219, 146, 209, 228, 0, 63, 23, 140, 218, 8, 118, 185, 16, 163, 209, 190, 40, 23, 2, 29, 193, 207, 208, 61, 181, 29, 83, 223, 140, 118]), (bytes [213, 212, 105, 129, 90, 226, 186, 46, 54, 94, 7, 8, 200, 118, 213, 207, 26, 95, 5, 248, 212, 29, 125, 167, 241, 209, 160, 70, 78, 145, 153, 124]), (bytes [110, 10, 95, 75, 51, 135, 244, 161, 129, 133, 205, 17, 204, 168, 179, 82, 234, 251, 49, 40, 61, 55, 155, 222, 255, 254, 189, 184, 151, 47, 122, 31]), (bytes [143, 33, 187, 119, 210, 61, 33, 128, 104, 91, 227, 144, 242, 32, 21, 215, 211, 250, 225, 212, 103, 252, 98, 115, 14, 243, 255, 123, 47, 157, 26, 243]), (bytes [215, 73, 51, 105, 58, 149, 81, 194, 219, 52, 130, 177, 222, 8, 21, 210, 5, 207, 49, 180, 184, 255, 192, 16, 55, 82, 71, 19, 253, 161, 96, 104]), (bytes [250, 98, 150, 222, 194, 20, 56, 122, 190, 148, 37, 175, 141, 61, 45, 142, 216, 103, 215, 157, 193, 179, 140, 10, 91, 3, 99, 9, 240, 124, 210, 173]), (bytes [190, 136, 248, 225, 222, 253, 46, 33, 200, 133, 253, 210, 70, 204, 87, 55, 169, 174, 37, 145, 73, 225, 153, 86, 46, 206, 245, 174, 40, 19, 104, 149]), (bytes [173, 186, 166, 20, 194, 0, 154, 126, 238, 199, 229, 202, 82, 199, 113, 9, 230, 155, 178, 88, 159, 104, 225, 33, 209, 141, 149, 119, 155, 197, 110, 213]), (bytes [81, 161, 204, 190, 177, 184, 85, 120, 28, 157, 158, 220, 28, 73, 128, 253, 140, 113, 246, 62, 211, 188, 122, 206, 220, 238, 176, 237, 117, 161, 0, 74]), (bytes [204, 150, 94, 210, 198, 197, 205, 40, 103, 192, 126, 176, 207, 85, 169, 214, 193, 164, 70, 147, 153, 222, 165, 162, 184, 105, 43, 246, 72, 81, 179, 31]), (bytes [112, 190, 127, 210, 196, 91, 121, 216, 190, 103, 234, 134, 56, 255, 143, 82, 145, 93, 119, 145, 12, 168, 183, 157, 150, 255, 107, 65, 170, 82, 21, 235]), (bytes [214, 89, 191, 109, 21, 218, 236, 154, 83, 18, 54, 215, 222, 109, 74, 135, 224, 173, 247, 174, 42, 210, 43, 167, 39, 41, 253, 77, 195, 146, 146, 214]), (bytes [130, 206, 12, 128, 116, 252, 135, 80, 244, 108, 186, 197, 44, 92, 183, 69, 200, 72, 211, 195, 131, 228, 33, 66, 82, 200, 179, 222, 35, 36, 46, 53]), (bytes [30, 174, 79, 121, 65, 219, 110, 233, 104, 173, 47, 250, 248, 186, 51, 18, 233, 106, 158, 31, 210, 255, 216, 247, 66, 63, 184, 92, 64, 177, 197, 23]), (bytes [246, 158, 186, 43, 36, 74, 166, 236, 79, 158, 243, 35, 212, 72, 68, 198, 116, 32, 121, 218, 154, 118, 208, 56, 160, 244, 61, 201, 85, 48, 159, 93]), (bytes [141, 183, 79, 72, 221, 229, 227, 58, 251, 55, 254, 17, 223, 169, 236, 10, 37, 101, 81, 83, 170, 118, 143, 227, 71, 5, 6, 200, 162, 35, 182, 112]), (bytes [185, 163, 191, 38, 99, 54, 152, 226, 199, 110, 164, 217, 233, 133, 253, 32, 30, 212, 79, 20, 215, 238, 152, 166, 233, 202, 69, 255, 252, 184, 201, 176]), (bytes [193, 67, 131, 128, 216, 120, 11, 160, 59, 118, 83, 134, 33, 180, 32, 153, 12, 167, 149, 198, 161, 255, 166, 30, 166, 91, 128, 93, 168, 129, 38, 230]), (bytes [136, 3, 111, 102, 197, 171, 236, 253, 23, 47, 92, 61, 161, 223, 251, 82, 79, 56, 23, 29, 95, 26, 73, 177, 249, 201, 202, 221, 26, 168, 179, 26])], familyDigest := (bytes [171, 224, 63, 43, 249, 74, 225, 231, 62, 81, 99, 246, 21, 22, 245, 111, 89, 94, 177, 243, 37, 191, 68, 180, 9, 24, 201, 59, 114, 116, 96, 14]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [171, 224, 63, 43, 249, 74, 225, 231, 62, 81, 99, 246, 21, 22, 245, 111, 89, 94, 177, 243, 37, 191, 68, 180, 9, 24, 201, 59, 114, 116, 96, 14]), layoutVersion := 1, digest := (bytes [195, 60, 175, 242, 0, 182, 128, 130, 166, 241, 208, 233, 227, 162, 249, 61, 247, 191, 144, 26, 215, 50, 223, 212, 108, 31, 169, 122, 166, 223, 167, 83]) }, logicalIndex := 0, digest := (bytes [44, 208, 166, 220, 7, 118, 202, 186, 32, 64, 247, 246, 176, 36, 60, 214, 15, 67, 63, 142, 244, 85, 221, 67, 105, 38, 45, 247, 155, 175, 4, 245]) }, valueDigest := (bytes [158, 63, 138, 206, 127, 145, 146, 109, 103, 153, 88, 114, 209, 198, 164, 199, 49, 182, 5, 151, 139, 25, 106, 81, 245, 88, 121, 14, 33, 120, 32, 196]), digest := (bytes [176, 201, 107, 186, 67, 164, 205, 98, 198, 118, 96, 140, 24, 206, 27, 122, 43, 121, 3, 221, 245, 101, 16, 164, 108, 55, 16, 184, 60, 138, 164, 156]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [171, 224, 63, 43, 249, 74, 225, 231, 62, 81, 99, 246, 21, 22, 245, 111, 89, 94, 177, 243, 37, 191, 68, 180, 9, 24, 201, 59, 114, 116, 96, 14]), layoutVersion := 1, digest := (bytes [195, 60, 175, 242, 0, 182, 128, 130, 166, 241, 208, 233, 227, 162, 249, 61, 247, 191, 144, 26, 215, 50, 223, 212, 108, 31, 169, 122, 166, 223, 167, 83]) }, logicalIndex := 19, digest := (bytes [95, 98, 214, 207, 168, 225, 165, 46, 72, 5, 204, 165, 163, 38, 141, 197, 68, 228, 12, 178, 99, 226, 246, 107, 247, 52, 36, 234, 17, 113, 63, 206]) }, valueDigest := (bytes [82, 160, 133, 135, 90, 74, 33, 242, 167, 29, 94, 199, 13, 129, 162, 84, 101, 207, 110, 195, 203, 13, 137, 237, 155, 115, 102, 78, 93, 59, 31, 37]), digest := (bytes [166, 225, 149, 216, 78, 142, 12, 228, 37, 240, 55, 30, 144, 48, 78, 28, 229, 56, 186, 2, 231, 23, 50, 115, 64, 99, 154, 101, 186, 197, 100, 255]) }), digest := (bytes [33, 31, 63, 90, 59, 250, 60, 157, 168, 213, 143, 188, 18, 195, 59, 75, 168, 114, 83, 102, 100, 133, 81, 79, 163, 29, 214, 62, 1, 183, 65, 48]) }
  , rootLaneCommitment := { timeLen := 20, commitments := { commitmentCount := 38, digest := (bytes [212, 205, 99, 165, 179, 213, 216, 52, 3, 111, 39, 206, 164, 185, 138, 173, 4, 18, 72, 230, 120, 223, 52, 220, 233, 175, 26, 2, 158, 238, 255, 174]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [212, 205, 99, 165, 179, 213, 216, 52, 3, 111, 39, 206, 164, 185, 138, 173, 4, 18, 72, 230, 120, 223, 52, 220, 233, 175, 26, 2, 158, 238, 255, 174]), layoutVersion := 3, digest := (bytes [108, 219, 176, 66, 40, 133, 237, 106, 119, 34, 250, 122, 114, 69, 60, 225, 151, 212, 179, 30, 218, 106, 205, 20, 247, 174, 89, 29, 93, 30, 175, 128]) }, logicalIndex := 0, digest := (bytes [211, 213, 209, 113, 179, 55, 161, 232, 121, 201, 243, 72, 119, 136, 63, 108, 133, 246, 161, 86, 238, 142, 145, 88, 113, 127, 217, 16, 223, 161, 88, 75]) }, valueDigest := (bytes [158, 63, 138, 206, 127, 145, 146, 109, 103, 153, 88, 114, 209, 198, 164, 199, 49, 182, 5, 151, 139, 25, 106, 81, 245, 88, 121, 14, 33, 120, 32, 196]), digest := (bytes [191, 83, 25, 35, 78, 235, 194, 227, 254, 254, 234, 224, 176, 9, 90, 171, 211, 218, 193, 16, 146, 5, 213, 132, 60, 208, 44, 15, 55, 232, 14, 220]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [212, 205, 99, 165, 179, 213, 216, 52, 3, 111, 39, 206, 164, 185, 138, 173, 4, 18, 72, 230, 120, 223, 52, 220, 233, 175, 26, 2, 158, 238, 255, 174]), layoutVersion := 3, digest := (bytes [108, 219, 176, 66, 40, 133, 237, 106, 119, 34, 250, 122, 114, 69, 60, 225, 151, 212, 179, 30, 218, 106, 205, 20, 247, 174, 89, 29, 93, 30, 175, 128]) }, logicalIndex := 19, digest := (bytes [105, 49, 34, 171, 7, 204, 146, 158, 175, 143, 55, 126, 234, 35, 10, 50, 47, 214, 49, 195, 242, 6, 48, 207, 226, 244, 123, 30, 15, 70, 204, 102]) }, valueDigest := (bytes [82, 160, 133, 135, 90, 74, 33, 242, 167, 29, 94, 199, 13, 129, 162, 84, 101, 207, 110, 195, 203, 13, 137, 237, 155, 115, 102, 78, 93, 59, 31, 37]), digest := (bytes [122, 22, 157, 76, 176, 180, 197, 55, 51, 178, 205, 194, 143, 161, 136, 221, 111, 214, 205, 82, 133, 124, 105, 171, 89, 209, 99, 80, 14, 216, 80, 60]) }), digest := (bytes [132, 218, 128, 216, 210, 30, 114, 205, 158, 193, 168, 74, 31, 216, 255, 49, 157, 128, 233, 88, 207, 242, 224, 154, 79, 27, 179, 137, 1, 11, 49, 84]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [33, 31, 63, 90, 59, 250, 60, 157, 168, 213, 143, 188, 18, 195, 59, 75, 168, 114, 83, 102, 100, 133, 81, 79, 163, 29, 214, 62, 1, 183, 65, 48]), rootLaneCommitmentDigest := (bytes [132, 218, 128, 216, 210, 30, 114, 205, 158, 193, 168, 74, 31, 216, 255, 49, 157, 128, 233, 88, 207, 242, 224, 154, 79, 27, 179, 137, 1, 11, 49, 84]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 20, digest := (bytes [63, 167, 53, 181, 40, 105, 105, 92, 184, 198, 65, 223, 185, 82, 6, 253, 77, 143, 221, 29, 34, 152, 46, 165, 163, 216, 220, 15, 81, 22, 7, 77]) }, statementDigest := (bytes [36, 155, 149, 100, 190, 91, 188, 216, 125, 113, 243, 71, 21, 87, 169, 138, 69, 3, 142, 167, 191, 54, 96, 236, 80, 178, 69, 51, 193, 235, 62, 100]), proofDigest := (bytes [4, 68, 47, 46, 191, 108, 1, 113, 249, 29, 108, 73, 175, 123, 14, 7, 124, 239, 135, 20, 92, 180, 80, 86, 127, 169, 148, 115, 219, 170, 185, 91]), digest := (bytes [205, 127, 238, 79, 18, 179, 165, 180, 84, 204, 50, 254, 220, 19, 108, 155, 119, 74, 122, 211, 237, 31, 211, 185, 204, 186, 49, 238, 206, 55, 188, 237]) }
  , digest := (bytes [29, 66, 224, 225, 150, 70, 133, 125, 182, 71, 86, 125, 111, 44, 218, 127, 207, 157, 130, 107, 143, 48, 162, 155, 221, 246, 241, 169, 241, 132, 177, 165])
}
    , exportedProof := {
  claim := {
  accepted := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , statement := { proofStatementDigest := (bytes [163, 193, 85, 8, 214, 35, 229, 53, 178, 6, 102, 59, 215, 46, 78, 105, 238, 214, 203, 29, 95, 39, 99, 251, 32, 84, 230, 205, 40, 77, 122, 12]), kernelOpeningDigest := (bytes [141, 147, 194, 158, 1, 113, 164, 5, 52, 60, 204, 22, 214, 218, 60, 235, 163, 130, 167, 78, 77, 79, 166, 89, 20, 6, 80, 169, 90, 145, 220, 253]), digest := (bytes [144, 215, 103, 145, 172, 249, 166, 161, 141, 59, 236, 42, 248, 238, 241, 76, 54, 107, 151, 150, 4, 168, 208, 77, 196, 104, 101, 107, 22, 127, 55, 246]) }
  , mainLane := { mainLaneBundleDigest := (bytes [205, 127, 238, 79, 18, 179, 165, 180, 84, 204, 50, 254, 220, 19, 108, 155, 119, 74, 122, 211, 237, 31, 211, 185, 204, 186, 49, 238, 206, 55, 188, 237]), digest := (bytes [82, 163, 3, 158, 84, 96, 206, 212, 135, 83, 71, 12, 106, 112, 46, 129, 224, 94, 184, 229, 4, 2, 18, 178, 29, 135, 136, 84, 181, 39, 29, 149]) }
  , terminal := { finalStateDigest := (bytes [64, 177, 68, 187, 81, 87, 252, 39, 65, 209, 64, 178, 63, 178, 69, 5, 247, 172, 14, 148, 78, 120, 110, 92, 118, 191, 130, 29, 111, 21, 65, 215]), finalPc := 16, halted := true, digest := (bytes [65, 214, 99, 82, 157, 22, 8, 154, 247, 90, 125, 137, 111, 254, 52, 169, 48, 53, 71, 47, 13, 163, 140, 237, 14, 115, 94, 207, 169, 61, 138, 82]) }
  , digest := (bytes [111, 104, 92, 39, 242, 6, 131, 119, 207, 10, 120, 145, 139, 54, 58, 42, 22, 34, 167, 97, 82, 71, 252, 225, 133, 173, 0, 95, 75, 73, 48, 25])
}
  , mainLane := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { mainLaneBundleDigest := (bytes [205, 127, 238, 79, 18, 179, 165, 180, 84, 204, 50, 254, 220, 19, 108, 155, 119, 74, 122, 211, 237, 31, 211, 185, 204, 186, 49, 238, 206, 55, 188, 237]), digest := (bytes [90, 116, 241, 94, 105, 229, 100, 212, 180, 38, 230, 205, 183, 179, 46, 2, 88, 4, 231, 11, 31, 60, 12, 49, 255, 75, 100, 216, 172, 192, 137, 213]) }, digest := (bytes [249, 62, 148, 166, 103, 78, 94, 148, 19, 54, 58, 129, 47, 184, 159, 202, 159, 33, 32, 69, 83, 239, 87, 39, 31, 160, 93, 87, 53, 4, 118, 170]) }
  , opening := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , stages := { stageClaimsDigest := (bytes [154, 191, 59, 142, 143, 78, 16, 57, 13, 122, 149, 108, 83, 186, 13, 160, 101, 219, 21, 202, 214, 211, 41, 112, 34, 249, 222, 108, 174, 63, 179, 237]), stagePackagesDigest := (bytes [27, 207, 142, 24, 29, 52, 215, 192, 49, 83, 98, 73, 13, 203, 80, 250, 150, 170, 175, 117, 0, 22, 29, 27, 195, 243, 22, 118, 42, 207, 134, 126]), kernelOpeningDigest := (bytes [141, 147, 194, 158, 1, 113, 164, 5, 52, 60, 204, 22, 214, 218, 60, 235, 163, 130, 167, 78, 77, 79, 166, 89, 20, 6, 80, 169, 90, 145, 220, 253]), digest := (bytes [201, 126, 68, 8, 12, 116, 228, 86, 44, 99, 199, 31, 133, 224, 186, 35, 204, 143, 22, 31, 150, 228, 45, 193, 221, 131, 12, 152, 209, 215, 69, 32]) }
  , terminal := { preparedStepBindingsDigest := (bytes [56, 55, 65, 136, 166, 105, 55, 221, 32, 59, 92, 217, 19, 218, 150, 142, 9, 231, 253, 237, 17, 141, 61, 10, 157, 65, 174, 106, 188, 85, 117, 232]), executionDigest := (bytes [253, 56, 202, 101, 142, 132, 93, 134, 75, 217, 118, 33, 12, 112, 138, 94, 76, 57, 89, 198, 120, 58, 231, 25, 226, 162, 224, 124, 164, 228, 241, 216]), transcriptFinalDigest := (bytes [120, 150, 198, 157, 183, 29, 181, 168, 84, 91, 217, 92, 129, 32, 61, 159, 114, 123, 152, 127, 69, 68, 165, 115, 230, 23, 147, 254, 240, 0, 112, 198]), digest := (bytes [235, 30, 39, 129, 58, 85, 237, 64, 109, 223, 122, 186, 13, 214, 150, 135, 235, 234, 94, 108, 236, 65, 31, 203, 50, 201, 89, 254, 36, 79, 9, 57]) }
  , digest := (bytes [96, 35, 168, 198, 204, 70, 94, 181, 252, 242, 163, 156, 212, 109, 247, 112, 88, 167, 219, 57, 246, 27, 58, 6, 240, 6, 200, 240, 207, 172, 116, 85])
}
  , jointOpening := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { proofStatementDigest := (bytes [163, 193, 85, 8, 214, 35, 229, 53, 178, 6, 102, 59, 215, 46, 78, 105, 238, 214, 203, 29, 95, 39, 99, 251, 32, 84, 230, 205, 40, 77, 122, 12]), mainLaneClaimDigest := (bytes [249, 62, 148, 166, 103, 78, 94, 148, 19, 54, 58, 129, 47, 184, 159, 202, 159, 33, 32, 69, 83, 239, 87, 39, 31, 160, 93, 87, 53, 4, 118, 170]), kernelOpeningClaimDigest := (bytes [96, 35, 168, 198, 204, 70, 94, 181, 252, 242, 163, 156, 212, 109, 247, 112, 88, 167, 219, 57, 246, 27, 58, 6, 240, 6, 200, 240, 207, 172, 116, 85]), digest := (bytes [28, 193, 245, 124, 127, 90, 249, 199, 250, 201, 67, 151, 163, 220, 107, 106, 167, 99, 202, 249, 223, 222, 211, 102, 62, 73, 131, 22, 78, 123, 1, 20]) }, digest := (bytes [131, 92, 92, 75, 126, 238, 155, 148, 255, 21, 84, 90, 160, 23, 247, 201, 148, 245, 191, 80, 48, 81, 63, 145, 34, 3, 204, 188, 190, 162, 65, 121]) }
  , root0 := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), stages := { stage1Digest := (bytes [254, 135, 111, 142, 154, 116, 166, 185, 185, 222, 69, 53, 63, 69, 145, 188, 248, 151, 195, 191, 15, 203, 170, 159, 58, 111, 210, 59, 37, 159, 20, 59]), stage2Digest := (bytes [7, 82, 83, 13, 122, 202, 121, 111, 107, 12, 23, 144, 227, 48, 106, 126, 125, 114, 5, 27, 67, 29, 185, 192, 203, 20, 116, 55, 18, 178, 169, 18]), stage3Digest := (bytes [242, 180, 211, 44, 136, 191, 129, 103, 121, 27, 189, 177, 57, 84, 107, 37, 200, 205, 250, 244, 70, 251, 148, 129, 186, 236, 174, 139, 158, 109, 21, 76]), digest := (bytes [159, 188, 213, 135, 201, 41, 50, 56, 89, 243, 207, 156, 76, 149, 151, 236, 196, 59, 148, 141, 130, 221, 135, 211, 217, 229, 44, 106, 17, 88, 247, 88]) }, terminal := { root0Digest := (bytes [243, 33, 113, 153, 9, 235, 68, 117, 29, 132, 237, 169, 175, 129, 160, 239, 59, 177, 90, 147, 52, 212, 120, 200, 192, 235, 87, 137, 127, 175, 131, 194]), executionDigest := (bytes [253, 56, 202, 101, 142, 132, 93, 134, 75, 217, 118, 33, 12, 112, 138, 94, 76, 57, 89, 198, 120, 58, 231, 25, 226, 162, 224, 124, 164, 228, 241, 216]), finalStateDigest := (bytes [64, 177, 68, 187, 81, 87, 252, 39, 65, 209, 64, 178, 63, 178, 69, 5, 247, 172, 14, 148, 78, 120, 110, 92, 118, 191, 130, 29, 111, 21, 65, 215]), transcriptFinalDigest := (bytes [120, 150, 198, 157, 183, 29, 181, 168, 84, 91, 217, 92, 129, 32, 61, 159, 114, 123, 152, 127, 69, 68, 165, 115, 230, 23, 147, 254, 240, 0, 112, 198]), digest := (bytes [211, 61, 218, 162, 39, 130, 167, 129, 31, 174, 19, 79, 203, 166, 188, 64, 212, 151, 189, 104, 32, 253, 116, 92, 84, 28, 5, 171, 249, 65, 145, 147]) }, digest := (bytes [127, 140, 234, 181, 168, 45, 8, 196, 116, 176, 114, 36, 9, 232, 44, 79, 216, 2, 76, 230, 168, 69, 220, 138, 147, 50, 137, 215, 194, 229, 157, 240]) }
  , digest := (bytes [53, 244, 238, 44, 57, 32, 164, 54, 200, 144, 150, 67, 139, 32, 175, 27, 164, 37, 207, 8, 161, 103, 84, 219, 196, 127, 44, 63, 4, 42, 70, 41])
}
  , statement := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , foldSchedule := Nightstream.FoldSchedule.wholeTrace
  , chunkCount := 1
  , stageClaimsDigest := (bytes [154, 191, 59, 142, 143, 78, 16, 57, 13, 122, 149, 108, 83, 186, 13, 160, 101, 219, 21, 202, 214, 211, 41, 112, 34, 249, 222, 108, 174, 63, 179, 237])
  , stagePackagesDigest := (bytes [27, 207, 142, 24, 29, 52, 215, 192, 49, 83, 98, 73, 13, 203, 80, 250, 150, 170, 175, 117, 0, 22, 29, 27, 195, 243, 22, 118, 42, 207, 134, 126])
  , kernelOpeningDigest := (bytes [141, 147, 194, 158, 1, 113, 164, 5, 52, 60, 204, 22, 214, 218, 60, 235, 163, 130, 167, 78, 77, 79, 166, 89, 20, 6, 80, 169, 90, 145, 220, 253])
  , preparedStepBindingsDigest := (bytes [56, 55, 65, 136, 166, 105, 55, 221, 32, 59, 92, 217, 19, 218, 150, 142, 9, 231, 253, 237, 17, 141, 61, 10, 157, 65, 174, 106, 188, 85, 117, 232])
  , executionDigest := (bytes [253, 56, 202, 101, 142, 132, 93, 134, 75, 217, 118, 33, 12, 112, 138, 94, 76, 57, 89, 198, 120, 58, 231, 25, 226, 162, 224, 124, 164, 228, 241, 216])
  , finalStateDigest := (bytes [64, 177, 68, 187, 81, 87, 252, 39, 65, 209, 64, 178, 63, 178, 69, 5, 247, 172, 14, 148, 78, 120, 110, 92, 118, 191, 130, 29, 111, 21, 65, 215])
  , transcriptFinalDigest := (bytes [120, 150, 198, 157, 183, 29, 181, 168, 84, 91, 217, 92, 129, 32, 61, 159, 114, 123, 152, 127, 69, 68, 165, 115, 230, 23, 147, 254, 240, 0, 112, 198])
  , mainLaneSurfaceDigest := (bytes [143, 226, 73, 81, 243, 97, 127, 178, 191, 48, 92, 215, 223, 10, 197, 109, 190, 17, 107, 76, 228, 152, 103, 1, 187, 241, 3, 112, 121, 130, 231, 111])
  , rootLaneColumnsDigest := (bytes [33, 31, 63, 90, 59, 250, 60, 157, 168, 213, 143, 188, 18, 195, 59, 75, 168, 114, 83, 102, 100, 133, 81, 79, 163, 29, 214, 62, 1, 183, 65, 48])
  , publicStepCount := 20
  , initialPc := 0
  , finalPc := 16
  , halted := true
  , digest := (bytes [163, 193, 85, 8, 214, 35, 229, 53, 178, 6, 102, 59, 215, 46, 78, 105, 238, 214, 203, 29, 95, 39, 99, 251, 32, 84, 230, 205, 40, 77, 122, 12])
}
  , kernel := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "multiply_high_mulh_mulhu_mulhsu_ecall", fixtureId := "multiply_high_mulh_mulhu_mulhsu_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.multiply, .controlFlow] }
  , executionDigest := (bytes [253, 56, 202, 101, 142, 132, 93, 134, 75, 217, 118, 33, 12, 112, 138, 94, 76, 57, 89, 198, 120, 58, 231, 25, 226, 162, 224, 124, 164, 228, 241, 216])
  , shape := { executionRowCount := 20, realRowCount := 4, effectRowCount := 4, commitRowCount := 4, digest := (bytes [59, 163, 65, 114, 71, 203, 144, 250, 133, 131, 27, 218, 175, 132, 145, 9, 167, 224, 25, 210, 57, 136, 160, 228, 226, 219, 137, 198, 45, 37, 220, 249]) }
  , digest := (bytes [87, 190, 113, 20, 186, 182, 14, 185, 37, 191, 147, 144, 5, 87, 60, 209, 224, 173, 239, 91, 134, 183, 254, 180, 78, 119, 90, 185, 106, 193, 86, 105])
}
  , stages := { summary := { stage1RowCount := 20, stage2RegisterReadCount := 34, stage2RegisterWriteCount := 19, stage2RamEventCount := 0, stage2TwistLinkCount := 20, stage3ContinuityCount := 4, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [255, 24, 93, 239, 18, 91, 171, 28, 223, 204, 202, 124, 227, 86, 233, 201, 83, 172, 80, 193, 136, 215, 72, 104, 247, 205, 80, 146, 165, 255, 200, 255]) }, digest := (bytes [245, 102, 156, 90, 74, 70, 146, 73, 212, 89, 104, 24, 161, 60, 41, 146, 100, 19, 24, 43, 92, 110, 220, 101, 4, 86, 90, 196, 253, 64, 18, 42]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [70, 47, 32, 181, 107, 177, 216, 251, 0, 96, 119, 64, 150, 0, 74, 134, 39, 166, 239, 171, 130, 128, 99, 70, 185, 223, 7, 31, 93, 150, 85, 55]), stage1Digest := (bytes [119, 218, 212, 143, 84, 5, 68, 70, 103, 149, 150, 166, 87, 83, 126, 28, 62, 243, 151, 29, 60, 52, 29, 156, 124, 167, 241, 115, 150, 56, 50, 228]), stage2Digest := (bytes [189, 140, 3, 161, 137, 109, 65, 178, 71, 224, 130, 138, 61, 59, 201, 89, 255, 58, 87, 9, 210, 58, 150, 166, 7, 97, 142, 52, 198, 124, 61, 7]), stage3Digest := (bytes [36, 225, 132, 194, 224, 112, 136, 254, 241, 228, 10, 51, 211, 162, 201, 21, 129, 198, 178, 230, 72, 16, 240, 160, 192, 242, 8, 234, 55, 33, 177, 139]), transcriptDigest := (bytes [120, 150, 198, 157, 183, 29, 181, 168, 84, 91, 217, 92, 129, 32, 61, 159, 114, 123, 152, 127, 69, 68, 165, 115, 230, 23, 147, 254, 240, 0, 112, 198]), executionDigest := (bytes [253, 56, 202, 101, 142, 132, 93, 134, 75, 217, 118, 33, 12, 112, 138, 94, 76, 57, 89, 198, 120, 58, 231, 25, 226, 162, 224, 124, 164, 228, 241, 216]), digest := (bytes [255, 249, 153, 248, 151, 143, 63, 2, 185, 112, 164, 47, 36, 214, 3, 20, 30, 60, 58, 8, 190, 192, 175, 58, 171, 177, 116, 180, 157, 92, 52, 245]) }, statementDigest := (bytes [65, 170, 247, 137, 42, 100, 251, 203, 22, 85, 243, 254, 99, 185, 112, 125, 180, 33, 208, 243, 113, 32, 49, 129, 63, 112, 67, 250, 127, 76, 52, 129]), proofDigest := (bytes [104, 146, 73, 104, 116, 95, 200, 172, 230, 213, 189, 116, 148, 86, 238, 55, 94, 87, 141, 7, 170, 31, 11, 133, 156, 193, 26, 80, 239, 191, 128, 227]), digest := (bytes [154, 191, 59, 142, 143, 78, 16, 57, 13, 122, 149, 108, 83, 186, 13, 160, 101, 219, 21, 202, 214, 211, 41, 112, 34, 249, 222, 108, 174, 63, 179, 237]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [253, 68, 102, 128, 114, 247, 96, 30, 42, 155, 72, 120, 189, 122, 83, 246, 73, 123, 104, 153, 131, 27, 149, 124, 249, 24, 106, 81, 205, 160, 156, 232]), stage1Digest := (bytes [6, 10, 87, 34, 241, 198, 152, 111, 25, 24, 54, 182, 89, 57, 247, 48, 242, 144, 226, 150, 167, 143, 175, 224, 254, 182, 192, 43, 164, 232, 67, 22]), stage2Digest := (bytes [218, 40, 31, 235, 102, 3, 46, 12, 84, 131, 99, 11, 21, 10, 80, 37, 106, 103, 252, 44, 250, 58, 169, 51, 76, 29, 215, 63, 181, 188, 27, 111]), stage3Digest := (bytes [11, 50, 217, 85, 206, 200, 239, 139, 234, 25, 96, 96, 132, 20, 133, 5, 36, 123, 115, 179, 2, 255, 142, 86, 179, 60, 240, 89, 255, 62, 179, 48]), digest := (bytes [179, 79, 124, 213, 197, 219, 93, 112, 48, 42, 73, 201, 179, 124, 255, 216, 54, 77, 106, 35, 178, 39, 18, 1, 199, 24, 17, 127, 89, 156, 94, 37]) }, digest := (bytes [27, 207, 142, 24, 29, 52, 215, 192, 49, 83, 98, 73, 13, 203, 80, 250, 150, 170, 175, 117, 0, 22, 29, 27, 195, 243, 22, 118, 42, 207, 134, 126]) }
  , kernelOpening := { openingDigest := (bytes [198, 84, 146, 64, 111, 119, 190, 121, 159, 108, 161, 239, 196, 219, 253, 57, 156, 179, 128, 200, 150, 72, 115, 128, 184, 62, 117, 82, 200, 134, 59, 132]), bindings := { claimDigest := (bytes [57, 252, 166, 206, 50, 86, 5, 153, 150, 113, 83, 200, 199, 104, 253, 16, 89, 102, 78, 215, 127, 45, 39, 160, 68, 94, 193, 22, 228, 124, 251, 217]), bindingsDigest := (bytes [229, 202, 10, 251, 106, 127, 222, 240, 249, 36, 93, 163, 113, 62, 72, 62, 57, 8, 91, 47, 197, 119, 41, 238, 165, 135, 41, 137, 39, 142, 226, 11]), preparedStepsDigest := (bytes [160, 151, 120, 21, 206, 145, 64, 91, 14, 148, 98, 135, 27, 128, 129, 141, 192, 57, 207, 232, 9, 243, 128, 103, 109, 149, 129, 179, 71, 87, 65, 181]), digest := (bytes [182, 190, 74, 60, 203, 251, 25, 255, 203, 111, 169, 173, 153, 233, 249, 22, 157, 151, 48, 46, 82, 90, 141, 149, 110, 70, 220, 144, 91, 87, 107, 117]) }, digest := (bytes [141, 147, 194, 158, 1, 113, 164, 5, 52, 60, 204, 22, 214, 218, 60, 235, 163, 130, 167, 78, 77, 79, 166, 89, 20, 6, 80, 169, 90, 145, 220, 253]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [56, 55, 65, 136, 166, 105, 55, 221, 32, 59, 92, 217, 19, 218, 150, 142, 9, 231, 253, 237, 17, 141, 61, 10, 157, 65, 174, 106, 188, 85, 117, 232]), terminal := { root0Digest := (bytes [243, 33, 113, 153, 9, 235, 68, 117, 29, 132, 237, 169, 175, 129, 160, 239, 59, 177, 90, 147, 52, 212, 120, 200, 192, 235, 87, 137, 127, 175, 131, 194]), executionDigest := (bytes [253, 56, 202, 101, 142, 132, 93, 134, 75, 217, 118, 33, 12, 112, 138, 94, 76, 57, 89, 198, 120, 58, 231, 25, 226, 162, 224, 124, 164, 228, 241, 216]), finalStateDigest := (bytes [64, 177, 68, 187, 81, 87, 252, 39, 65, 209, 64, 178, 63, 178, 69, 5, 247, 172, 14, 148, 78, 120, 110, 92, 118, 191, 130, 29, 111, 21, 65, 215]), transcriptFinalDigest := (bytes [120, 150, 198, 157, 183, 29, 181, 168, 84, 91, 217, 92, 129, 32, 61, 159, 114, 123, 152, 127, 69, 68, 165, 115, 230, 23, 147, 254, 240, 0, 112, 198]), finalPc := 16, halted := true, digest := (bytes [171, 30, 191, 224, 99, 223, 179, 117, 65, 45, 229, 73, 132, 2, 198, 34, 76, 148, 13, 19, 129, 37, 20, 65, 127, 7, 62, 77, 92, 35, 32, 125]) }, digest := (bytes [110, 101, 243, 133, 133, 41, 232, 139, 240, 162, 182, 159, 61, 123, 193, 9, 167, 76, 83, 71, 24, 83, 67, 116, 247, 59, 84, 55, 31, 113, 173, 156]) }, statementDigest := (bytes [112, 113, 21, 103, 107, 197, 161, 221, 119, 129, 146, 170, 156, 57, 144, 189, 106, 201, 102, 13, 245, 131, 180, 125, 41, 26, 184, 82, 105, 229, 160, 44]), proofDigest := (bytes [5, 43, 177, 20, 43, 145, 65, 217, 251, 241, 227, 77, 229, 213, 236, 99, 136, 172, 221, 132, 130, 21, 67, 230, 22, 38, 32, 8, 120, 139, 196, 252]), digest := (bytes [38, 238, 244, 237, 19, 102, 134, 67, 255, 223, 166, 62, 88, 132, 120, 38, 23, 234, 112, 247, 106, 254, 59, 151, 138, 102, 58, 65, 200, 148, 101, 31]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [171, 224, 63, 43, 249, 74, 225, 231, 62, 81, 99, 246, 21, 22, 245, 111, 89, 94, 177, 243, 37, 191, 68, 180, 9, 24, 201, 59, 114, 116, 96, 14]), layoutVersion := 1, digest := (bytes [195, 60, 175, 242, 0, 182, 128, 130, 166, 241, 208, 233, 227, 162, 249, 61, 247, 191, 144, 26, 215, 50, 223, 212, 108, 31, 169, 122, 166, 223, 167, 83]) }, rowWidth := 38, timeLen := 20, columnDigests := [(bytes [199, 57, 218, 242, 224, 219, 158, 68, 215, 187, 96, 181, 151, 77, 205, 24, 48, 176, 155, 147, 109, 207, 131, 76, 49, 50, 103, 236, 189, 78, 9, 147]), (bytes [99, 48, 0, 205, 223, 203, 201, 183, 80, 150, 15, 104, 75, 254, 20, 172, 5, 27, 49, 46, 89, 164, 236, 136, 72, 153, 142, 0, 42, 148, 252, 208]), (bytes [36, 195, 3, 23, 204, 207, 187, 92, 134, 65, 178, 127, 245, 52, 1, 162, 126, 151, 221, 177, 208, 31, 231, 155, 90, 58, 153, 245, 68, 0, 240, 103]), (bytes [89, 63, 211, 203, 102, 246, 143, 81, 89, 207, 248, 85, 99, 165, 30, 91, 192, 59, 192, 250, 16, 166, 139, 207, 219, 207, 36, 142, 232, 96, 192, 44]), (bytes [113, 127, 125, 130, 71, 31, 68, 221, 233, 32, 247, 34, 239, 167, 174, 36, 31, 184, 199, 64, 194, 125, 224, 240, 191, 198, 237, 167, 62, 90, 96, 14]), (bytes [186, 200, 182, 147, 241, 252, 231, 126, 240, 229, 127, 182, 218, 96, 185, 151, 145, 86, 52, 78, 20, 31, 94, 133, 56, 247, 201, 49, 168, 6, 115, 210]), (bytes [20, 239, 222, 15, 28, 249, 226, 194, 34, 201, 188, 165, 49, 102, 255, 52, 17, 120, 85, 66, 76, 236, 75, 106, 241, 40, 111, 2, 199, 49, 66, 129]), (bytes [155, 229, 31, 161, 157, 48, 177, 68, 31, 151, 237, 55, 220, 226, 115, 87, 178, 72, 240, 124, 163, 209, 241, 233, 81, 208, 232, 166, 72, 132, 207, 121]), (bytes [141, 140, 151, 173, 50, 143, 215, 38, 128, 21, 96, 159, 60, 16, 93, 194, 28, 165, 7, 118, 136, 8, 254, 34, 209, 124, 210, 88, 134, 172, 165, 242]), (bytes [199, 162, 226, 113, 228, 252, 225, 138, 196, 134, 111, 23, 169, 182, 26, 100, 208, 27, 39, 53, 145, 219, 86, 152, 192, 237, 175, 179, 167, 93, 188, 94]), (bytes [191, 167, 98, 84, 60, 165, 246, 85, 129, 174, 87, 162, 68, 168, 194, 224, 187, 111, 92, 227, 53, 121, 5, 48, 7, 228, 167, 191, 137, 229, 166, 170]), (bytes [160, 102, 96, 180, 246, 11, 52, 159, 119, 76, 141, 231, 133, 23, 9, 119, 228, 1, 70, 206, 126, 162, 179, 28, 156, 184, 163, 31, 182, 58, 88, 215]), (bytes [119, 144, 167, 4, 144, 100, 3, 176, 118, 116, 10, 43, 195, 7, 229, 110, 54, 108, 24, 115, 166, 12, 93, 185, 8, 236, 7, 93, 53, 189, 116, 238]), (bytes [160, 140, 215, 227, 142, 180, 183, 126, 61, 192, 126, 80, 155, 85, 239, 167, 248, 137, 93, 73, 1, 200, 114, 168, 112, 221, 50, 21, 238, 112, 66, 137]), (bytes [29, 191, 87, 134, 114, 120, 112, 77, 54, 230, 225, 160, 156, 69, 104, 233, 35, 230, 20, 201, 163, 119, 150, 230, 235, 74, 203, 254, 28, 129, 68, 144]), (bytes [220, 134, 74, 254, 168, 170, 90, 218, 220, 173, 45, 14, 192, 32, 17, 92, 118, 17, 21, 108, 194, 255, 107, 224, 122, 195, 197, 203, 150, 35, 246, 38]), (bytes [23, 221, 175, 82, 173, 40, 177, 63, 122, 124, 63, 200, 23, 59, 66, 72, 139, 28, 221, 165, 134, 118, 18, 108, 110, 25, 104, 195, 235, 31, 183, 105]), (bytes [19, 242, 208, 114, 246, 72, 120, 4, 108, 22, 97, 237, 194, 18, 147, 141, 70, 8, 138, 161, 44, 126, 1, 150, 233, 62, 99, 194, 228, 4, 7, 60]), (bytes [143, 63, 44, 207, 193, 170, 223, 121, 72, 38, 251, 158, 186, 24, 156, 134, 119, 200, 24, 69, 58, 205, 28, 146, 68, 123, 182, 59, 187, 70, 101, 157]), (bytes [82, 198, 219, 146, 209, 228, 0, 63, 23, 140, 218, 8, 118, 185, 16, 163, 209, 190, 40, 23, 2, 29, 193, 207, 208, 61, 181, 29, 83, 223, 140, 118]), (bytes [213, 212, 105, 129, 90, 226, 186, 46, 54, 94, 7, 8, 200, 118, 213, 207, 26, 95, 5, 248, 212, 29, 125, 167, 241, 209, 160, 70, 78, 145, 153, 124]), (bytes [110, 10, 95, 75, 51, 135, 244, 161, 129, 133, 205, 17, 204, 168, 179, 82, 234, 251, 49, 40, 61, 55, 155, 222, 255, 254, 189, 184, 151, 47, 122, 31]), (bytes [143, 33, 187, 119, 210, 61, 33, 128, 104, 91, 227, 144, 242, 32, 21, 215, 211, 250, 225, 212, 103, 252, 98, 115, 14, 243, 255, 123, 47, 157, 26, 243]), (bytes [215, 73, 51, 105, 58, 149, 81, 194, 219, 52, 130, 177, 222, 8, 21, 210, 5, 207, 49, 180, 184, 255, 192, 16, 55, 82, 71, 19, 253, 161, 96, 104]), (bytes [250, 98, 150, 222, 194, 20, 56, 122, 190, 148, 37, 175, 141, 61, 45, 142, 216, 103, 215, 157, 193, 179, 140, 10, 91, 3, 99, 9, 240, 124, 210, 173]), (bytes [190, 136, 248, 225, 222, 253, 46, 33, 200, 133, 253, 210, 70, 204, 87, 55, 169, 174, 37, 145, 73, 225, 153, 86, 46, 206, 245, 174, 40, 19, 104, 149]), (bytes [173, 186, 166, 20, 194, 0, 154, 126, 238, 199, 229, 202, 82, 199, 113, 9, 230, 155, 178, 88, 159, 104, 225, 33, 209, 141, 149, 119, 155, 197, 110, 213]), (bytes [81, 161, 204, 190, 177, 184, 85, 120, 28, 157, 158, 220, 28, 73, 128, 253, 140, 113, 246, 62, 211, 188, 122, 206, 220, 238, 176, 237, 117, 161, 0, 74]), (bytes [204, 150, 94, 210, 198, 197, 205, 40, 103, 192, 126, 176, 207, 85, 169, 214, 193, 164, 70, 147, 153, 222, 165, 162, 184, 105, 43, 246, 72, 81, 179, 31]), (bytes [112, 190, 127, 210, 196, 91, 121, 216, 190, 103, 234, 134, 56, 255, 143, 82, 145, 93, 119, 145, 12, 168, 183, 157, 150, 255, 107, 65, 170, 82, 21, 235]), (bytes [214, 89, 191, 109, 21, 218, 236, 154, 83, 18, 54, 215, 222, 109, 74, 135, 224, 173, 247, 174, 42, 210, 43, 167, 39, 41, 253, 77, 195, 146, 146, 214]), (bytes [130, 206, 12, 128, 116, 252, 135, 80, 244, 108, 186, 197, 44, 92, 183, 69, 200, 72, 211, 195, 131, 228, 33, 66, 82, 200, 179, 222, 35, 36, 46, 53]), (bytes [30, 174, 79, 121, 65, 219, 110, 233, 104, 173, 47, 250, 248, 186, 51, 18, 233, 106, 158, 31, 210, 255, 216, 247, 66, 63, 184, 92, 64, 177, 197, 23]), (bytes [246, 158, 186, 43, 36, 74, 166, 236, 79, 158, 243, 35, 212, 72, 68, 198, 116, 32, 121, 218, 154, 118, 208, 56, 160, 244, 61, 201, 85, 48, 159, 93]), (bytes [141, 183, 79, 72, 221, 229, 227, 58, 251, 55, 254, 17, 223, 169, 236, 10, 37, 101, 81, 83, 170, 118, 143, 227, 71, 5, 6, 200, 162, 35, 182, 112]), (bytes [185, 163, 191, 38, 99, 54, 152, 226, 199, 110, 164, 217, 233, 133, 253, 32, 30, 212, 79, 20, 215, 238, 152, 166, 233, 202, 69, 255, 252, 184, 201, 176]), (bytes [193, 67, 131, 128, 216, 120, 11, 160, 59, 118, 83, 134, 33, 180, 32, 153, 12, 167, 149, 198, 161, 255, 166, 30, 166, 91, 128, 93, 168, 129, 38, 230]), (bytes [136, 3, 111, 102, 197, 171, 236, 253, 23, 47, 92, 61, 161, 223, 251, 82, 79, 56, 23, 29, 95, 26, 73, 177, 249, 201, 202, 221, 26, 168, 179, 26])], familyDigest := (bytes [171, 224, 63, 43, 249, 74, 225, 231, 62, 81, 99, 246, 21, 22, 245, 111, 89, 94, 177, 243, 37, 191, 68, 180, 9, 24, 201, 59, 114, 116, 96, 14]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [171, 224, 63, 43, 249, 74, 225, 231, 62, 81, 99, 246, 21, 22, 245, 111, 89, 94, 177, 243, 37, 191, 68, 180, 9, 24, 201, 59, 114, 116, 96, 14]), layoutVersion := 1, digest := (bytes [195, 60, 175, 242, 0, 182, 128, 130, 166, 241, 208, 233, 227, 162, 249, 61, 247, 191, 144, 26, 215, 50, 223, 212, 108, 31, 169, 122, 166, 223, 167, 83]) }, logicalIndex := 0, digest := (bytes [44, 208, 166, 220, 7, 118, 202, 186, 32, 64, 247, 246, 176, 36, 60, 214, 15, 67, 63, 142, 244, 85, 221, 67, 105, 38, 45, 247, 155, 175, 4, 245]) }, valueDigest := (bytes [158, 63, 138, 206, 127, 145, 146, 109, 103, 153, 88, 114, 209, 198, 164, 199, 49, 182, 5, 151, 139, 25, 106, 81, 245, 88, 121, 14, 33, 120, 32, 196]), digest := (bytes [176, 201, 107, 186, 67, 164, 205, 98, 198, 118, 96, 140, 24, 206, 27, 122, 43, 121, 3, 221, 245, 101, 16, 164, 108, 55, 16, 184, 60, 138, 164, 156]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [171, 224, 63, 43, 249, 74, 225, 231, 62, 81, 99, 246, 21, 22, 245, 111, 89, 94, 177, 243, 37, 191, 68, 180, 9, 24, 201, 59, 114, 116, 96, 14]), layoutVersion := 1, digest := (bytes [195, 60, 175, 242, 0, 182, 128, 130, 166, 241, 208, 233, 227, 162, 249, 61, 247, 191, 144, 26, 215, 50, 223, 212, 108, 31, 169, 122, 166, 223, 167, 83]) }, logicalIndex := 19, digest := (bytes [95, 98, 214, 207, 168, 225, 165, 46, 72, 5, 204, 165, 163, 38, 141, 197, 68, 228, 12, 178, 99, 226, 246, 107, 247, 52, 36, 234, 17, 113, 63, 206]) }, valueDigest := (bytes [82, 160, 133, 135, 90, 74, 33, 242, 167, 29, 94, 199, 13, 129, 162, 84, 101, 207, 110, 195, 203, 13, 137, 237, 155, 115, 102, 78, 93, 59, 31, 37]), digest := (bytes [166, 225, 149, 216, 78, 142, 12, 228, 37, 240, 55, 30, 144, 48, 78, 28, 229, 56, 186, 2, 231, 23, 50, 115, 64, 99, 154, 101, 186, 197, 100, 255]) }), digest := (bytes [33, 31, 63, 90, 59, 250, 60, 157, 168, 213, 143, 188, 18, 195, 59, 75, 168, 114, 83, 102, 100, 133, 81, 79, 163, 29, 214, 62, 1, 183, 65, 48]) }
  , rootLaneCommitment := { timeLen := 20, commitments := { commitmentCount := 38, digest := (bytes [212, 205, 99, 165, 179, 213, 216, 52, 3, 111, 39, 206, 164, 185, 138, 173, 4, 18, 72, 230, 120, 223, 52, 220, 233, 175, 26, 2, 158, 238, 255, 174]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [212, 205, 99, 165, 179, 213, 216, 52, 3, 111, 39, 206, 164, 185, 138, 173, 4, 18, 72, 230, 120, 223, 52, 220, 233, 175, 26, 2, 158, 238, 255, 174]), layoutVersion := 3, digest := (bytes [108, 219, 176, 66, 40, 133, 237, 106, 119, 34, 250, 122, 114, 69, 60, 225, 151, 212, 179, 30, 218, 106, 205, 20, 247, 174, 89, 29, 93, 30, 175, 128]) }, logicalIndex := 0, digest := (bytes [211, 213, 209, 113, 179, 55, 161, 232, 121, 201, 243, 72, 119, 136, 63, 108, 133, 246, 161, 86, 238, 142, 145, 88, 113, 127, 217, 16, 223, 161, 88, 75]) }, valueDigest := (bytes [158, 63, 138, 206, 127, 145, 146, 109, 103, 153, 88, 114, 209, 198, 164, 199, 49, 182, 5, 151, 139, 25, 106, 81, 245, 88, 121, 14, 33, 120, 32, 196]), digest := (bytes [191, 83, 25, 35, 78, 235, 194, 227, 254, 254, 234, 224, 176, 9, 90, 171, 211, 218, 193, 16, 146, 5, 213, 132, 60, 208, 44, 15, 55, 232, 14, 220]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [212, 205, 99, 165, 179, 213, 216, 52, 3, 111, 39, 206, 164, 185, 138, 173, 4, 18, 72, 230, 120, 223, 52, 220, 233, 175, 26, 2, 158, 238, 255, 174]), layoutVersion := 3, digest := (bytes [108, 219, 176, 66, 40, 133, 237, 106, 119, 34, 250, 122, 114, 69, 60, 225, 151, 212, 179, 30, 218, 106, 205, 20, 247, 174, 89, 29, 93, 30, 175, 128]) }, logicalIndex := 19, digest := (bytes [105, 49, 34, 171, 7, 204, 146, 158, 175, 143, 55, 126, 234, 35, 10, 50, 47, 214, 49, 195, 242, 6, 48, 207, 226, 244, 123, 30, 15, 70, 204, 102]) }, valueDigest := (bytes [82, 160, 133, 135, 90, 74, 33, 242, 167, 29, 94, 199, 13, 129, 162, 84, 101, 207, 110, 195, 203, 13, 137, 237, 155, 115, 102, 78, 93, 59, 31, 37]), digest := (bytes [122, 22, 157, 76, 176, 180, 197, 55, 51, 178, 205, 194, 143, 161, 136, 221, 111, 214, 205, 82, 133, 124, 105, 171, 89, 209, 99, 80, 14, 216, 80, 60]) }), digest := (bytes [132, 218, 128, 216, 210, 30, 114, 205, 158, 193, 168, 74, 31, 216, 255, 49, 157, 128, 233, 88, 207, 242, 224, 154, 79, 27, 179, 137, 1, 11, 49, 84]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [33, 31, 63, 90, 59, 250, 60, 157, 168, 213, 143, 188, 18, 195, 59, 75, 168, 114, 83, 102, 100, 133, 81, 79, 163, 29, 214, 62, 1, 183, 65, 48]), rootLaneCommitmentDigest := (bytes [132, 218, 128, 216, 210, 30, 114, 205, 158, 193, 168, 74, 31, 216, 255, 49, 157, 128, 233, 88, 207, 242, 224, 154, 79, 27, 179, 137, 1, 11, 49, 84]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 20, digest := (bytes [63, 167, 53, 181, 40, 105, 105, 92, 184, 198, 65, 223, 185, 82, 6, 253, 77, 143, 221, 29, 34, 152, 46, 165, 163, 216, 220, 15, 81, 22, 7, 77]) }, statementDigest := (bytes [36, 155, 149, 100, 190, 91, 188, 216, 125, 113, 243, 71, 21, 87, 169, 138, 69, 3, 142, 167, 191, 54, 96, 236, 80, 178, 69, 51, 193, 235, 62, 100]), proofDigest := (bytes [4, 68, 47, 46, 191, 108, 1, 113, 249, 29, 108, 73, 175, 123, 14, 7, 124, 239, 135, 20, 92, 180, 80, 86, 127, 169, 148, 115, 219, 170, 185, 91]), digest := (bytes [205, 127, 238, 79, 18, 179, 165, 180, 84, 204, 50, 254, 220, 19, 108, 155, 119, 74, 122, 211, 237, 31, 211, 185, 204, 186, 49, 238, 206, 55, 188, 237]) }
  , digest := (bytes [29, 66, 224, 225, 150, 70, 133, 125, 182, 71, 86, 125, 111, 44, 218, 127, 207, 157, 130, 107, 143, 48, 162, 155, 221, 246, 241, 169, 241, 132, 177, 165])
}
}
    , exportedStatement := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , foldSchedule := Nightstream.FoldSchedule.wholeTrace
  , chunkCount := 1
  , stageClaimsDigest := (bytes [154, 191, 59, 142, 143, 78, 16, 57, 13, 122, 149, 108, 83, 186, 13, 160, 101, 219, 21, 202, 214, 211, 41, 112, 34, 249, 222, 108, 174, 63, 179, 237])
  , stagePackagesDigest := (bytes [27, 207, 142, 24, 29, 52, 215, 192, 49, 83, 98, 73, 13, 203, 80, 250, 150, 170, 175, 117, 0, 22, 29, 27, 195, 243, 22, 118, 42, 207, 134, 126])
  , kernelOpeningDigest := (bytes [141, 147, 194, 158, 1, 113, 164, 5, 52, 60, 204, 22, 214, 218, 60, 235, 163, 130, 167, 78, 77, 79, 166, 89, 20, 6, 80, 169, 90, 145, 220, 253])
  , preparedStepBindingsDigest := (bytes [56, 55, 65, 136, 166, 105, 55, 221, 32, 59, 92, 217, 19, 218, 150, 142, 9, 231, 253, 237, 17, 141, 61, 10, 157, 65, 174, 106, 188, 85, 117, 232])
  , executionDigest := (bytes [253, 56, 202, 101, 142, 132, 93, 134, 75, 217, 118, 33, 12, 112, 138, 94, 76, 57, 89, 198, 120, 58, 231, 25, 226, 162, 224, 124, 164, 228, 241, 216])
  , finalStateDigest := (bytes [64, 177, 68, 187, 81, 87, 252, 39, 65, 209, 64, 178, 63, 178, 69, 5, 247, 172, 14, 148, 78, 120, 110, 92, 118, 191, 130, 29, 111, 21, 65, 215])
  , transcriptFinalDigest := (bytes [120, 150, 198, 157, 183, 29, 181, 168, 84, 91, 217, 92, 129, 32, 61, 159, 114, 123, 152, 127, 69, 68, 165, 115, 230, 23, 147, 254, 240, 0, 112, 198])
  , mainLaneSurfaceDigest := (bytes [143, 226, 73, 81, 243, 97, 127, 178, 191, 48, 92, 215, 223, 10, 197, 109, 190, 17, 107, 76, 228, 152, 103, 1, 187, 241, 3, 112, 121, 130, 231, 111])
  , rootLaneColumnsDigest := (bytes [33, 31, 63, 90, 59, 250, 60, 157, 168, 213, 143, 188, 18, 195, 59, 75, 168, 114, 83, 102, 100, 133, 81, 79, 163, 29, 214, 62, 1, 183, 65, 48])
  , publicStepCount := 20
  , initialPc := 0
  , finalPc := 16
  , halted := true
  , digest := (bytes [163, 193, 85, 8, 214, 35, 229, 53, 178, 6, 102, 59, 215, 46, 78, 105, 238, 214, 203, 29, 95, 39, 99, 251, 32, 84, 230, 205, 40, 77, 122, 12])
}
    , exportedClaims := {
  accepted := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , statement := { proofStatementDigest := (bytes [163, 193, 85, 8, 214, 35, 229, 53, 178, 6, 102, 59, 215, 46, 78, 105, 238, 214, 203, 29, 95, 39, 99, 251, 32, 84, 230, 205, 40, 77, 122, 12]), kernelOpeningDigest := (bytes [141, 147, 194, 158, 1, 113, 164, 5, 52, 60, 204, 22, 214, 218, 60, 235, 163, 130, 167, 78, 77, 79, 166, 89, 20, 6, 80, 169, 90, 145, 220, 253]), digest := (bytes [144, 215, 103, 145, 172, 249, 166, 161, 141, 59, 236, 42, 248, 238, 241, 76, 54, 107, 151, 150, 4, 168, 208, 77, 196, 104, 101, 107, 22, 127, 55, 246]) }
  , mainLane := { mainLaneBundleDigest := (bytes [205, 127, 238, 79, 18, 179, 165, 180, 84, 204, 50, 254, 220, 19, 108, 155, 119, 74, 122, 211, 237, 31, 211, 185, 204, 186, 49, 238, 206, 55, 188, 237]), digest := (bytes [82, 163, 3, 158, 84, 96, 206, 212, 135, 83, 71, 12, 106, 112, 46, 129, 224, 94, 184, 229, 4, 2, 18, 178, 29, 135, 136, 84, 181, 39, 29, 149]) }
  , terminal := { finalStateDigest := (bytes [64, 177, 68, 187, 81, 87, 252, 39, 65, 209, 64, 178, 63, 178, 69, 5, 247, 172, 14, 148, 78, 120, 110, 92, 118, 191, 130, 29, 111, 21, 65, 215]), finalPc := 16, halted := true, digest := (bytes [65, 214, 99, 82, 157, 22, 8, 154, 247, 90, 125, 137, 111, 254, 52, 169, 48, 53, 71, 47, 13, 163, 140, 237, 14, 115, 94, 207, 169, 61, 138, 82]) }
  , digest := (bytes [111, 104, 92, 39, 242, 6, 131, 119, 207, 10, 120, 145, 139, 54, 58, 42, 22, 34, 167, 97, 82, 71, 252, 225, 133, 173, 0, 95, 75, 73, 48, 25])
}
  , mainLane := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { mainLaneBundleDigest := (bytes [205, 127, 238, 79, 18, 179, 165, 180, 84, 204, 50, 254, 220, 19, 108, 155, 119, 74, 122, 211, 237, 31, 211, 185, 204, 186, 49, 238, 206, 55, 188, 237]), digest := (bytes [90, 116, 241, 94, 105, 229, 100, 212, 180, 38, 230, 205, 183, 179, 46, 2, 88, 4, 231, 11, 31, 60, 12, 49, 255, 75, 100, 216, 172, 192, 137, 213]) }, digest := (bytes [249, 62, 148, 166, 103, 78, 94, 148, 19, 54, 58, 129, 47, 184, 159, 202, 159, 33, 32, 69, 83, 239, 87, 39, 31, 160, 93, 87, 53, 4, 118, 170]) }
  , opening := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , stages := { stageClaimsDigest := (bytes [154, 191, 59, 142, 143, 78, 16, 57, 13, 122, 149, 108, 83, 186, 13, 160, 101, 219, 21, 202, 214, 211, 41, 112, 34, 249, 222, 108, 174, 63, 179, 237]), stagePackagesDigest := (bytes [27, 207, 142, 24, 29, 52, 215, 192, 49, 83, 98, 73, 13, 203, 80, 250, 150, 170, 175, 117, 0, 22, 29, 27, 195, 243, 22, 118, 42, 207, 134, 126]), kernelOpeningDigest := (bytes [141, 147, 194, 158, 1, 113, 164, 5, 52, 60, 204, 22, 214, 218, 60, 235, 163, 130, 167, 78, 77, 79, 166, 89, 20, 6, 80, 169, 90, 145, 220, 253]), digest := (bytes [201, 126, 68, 8, 12, 116, 228, 86, 44, 99, 199, 31, 133, 224, 186, 35, 204, 143, 22, 31, 150, 228, 45, 193, 221, 131, 12, 152, 209, 215, 69, 32]) }
  , terminal := { preparedStepBindingsDigest := (bytes [56, 55, 65, 136, 166, 105, 55, 221, 32, 59, 92, 217, 19, 218, 150, 142, 9, 231, 253, 237, 17, 141, 61, 10, 157, 65, 174, 106, 188, 85, 117, 232]), executionDigest := (bytes [253, 56, 202, 101, 142, 132, 93, 134, 75, 217, 118, 33, 12, 112, 138, 94, 76, 57, 89, 198, 120, 58, 231, 25, 226, 162, 224, 124, 164, 228, 241, 216]), transcriptFinalDigest := (bytes [120, 150, 198, 157, 183, 29, 181, 168, 84, 91, 217, 92, 129, 32, 61, 159, 114, 123, 152, 127, 69, 68, 165, 115, 230, 23, 147, 254, 240, 0, 112, 198]), digest := (bytes [235, 30, 39, 129, 58, 85, 237, 64, 109, 223, 122, 186, 13, 214, 150, 135, 235, 234, 94, 108, 236, 65, 31, 203, 50, 201, 89, 254, 36, 79, 9, 57]) }
  , digest := (bytes [96, 35, 168, 198, 204, 70, 94, 181, 252, 242, 163, 156, 212, 109, 247, 112, 88, 167, 219, 57, 246, 27, 58, 6, 240, 6, 200, 240, 207, 172, 116, 85])
}
  , jointOpening := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { proofStatementDigest := (bytes [163, 193, 85, 8, 214, 35, 229, 53, 178, 6, 102, 59, 215, 46, 78, 105, 238, 214, 203, 29, 95, 39, 99, 251, 32, 84, 230, 205, 40, 77, 122, 12]), mainLaneClaimDigest := (bytes [249, 62, 148, 166, 103, 78, 94, 148, 19, 54, 58, 129, 47, 184, 159, 202, 159, 33, 32, 69, 83, 239, 87, 39, 31, 160, 93, 87, 53, 4, 118, 170]), kernelOpeningClaimDigest := (bytes [96, 35, 168, 198, 204, 70, 94, 181, 252, 242, 163, 156, 212, 109, 247, 112, 88, 167, 219, 57, 246, 27, 58, 6, 240, 6, 200, 240, 207, 172, 116, 85]), digest := (bytes [28, 193, 245, 124, 127, 90, 249, 199, 250, 201, 67, 151, 163, 220, 107, 106, 167, 99, 202, 249, 223, 222, 211, 102, 62, 73, 131, 22, 78, 123, 1, 20]) }, digest := (bytes [131, 92, 92, 75, 126, 238, 155, 148, 255, 21, 84, 90, 160, 23, 247, 201, 148, 245, 191, 80, 48, 81, 63, 145, 34, 3, 204, 188, 190, 162, 65, 121]) }
  , root0 := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), stages := { stage1Digest := (bytes [254, 135, 111, 142, 154, 116, 166, 185, 185, 222, 69, 53, 63, 69, 145, 188, 248, 151, 195, 191, 15, 203, 170, 159, 58, 111, 210, 59, 37, 159, 20, 59]), stage2Digest := (bytes [7, 82, 83, 13, 122, 202, 121, 111, 107, 12, 23, 144, 227, 48, 106, 126, 125, 114, 5, 27, 67, 29, 185, 192, 203, 20, 116, 55, 18, 178, 169, 18]), stage3Digest := (bytes [242, 180, 211, 44, 136, 191, 129, 103, 121, 27, 189, 177, 57, 84, 107, 37, 200, 205, 250, 244, 70, 251, 148, 129, 186, 236, 174, 139, 158, 109, 21, 76]), digest := (bytes [159, 188, 213, 135, 201, 41, 50, 56, 89, 243, 207, 156, 76, 149, 151, 236, 196, 59, 148, 141, 130, 221, 135, 211, 217, 229, 44, 106, 17, 88, 247, 88]) }, terminal := { root0Digest := (bytes [243, 33, 113, 153, 9, 235, 68, 117, 29, 132, 237, 169, 175, 129, 160, 239, 59, 177, 90, 147, 52, 212, 120, 200, 192, 235, 87, 137, 127, 175, 131, 194]), executionDigest := (bytes [253, 56, 202, 101, 142, 132, 93, 134, 75, 217, 118, 33, 12, 112, 138, 94, 76, 57, 89, 198, 120, 58, 231, 25, 226, 162, 224, 124, 164, 228, 241, 216]), finalStateDigest := (bytes [64, 177, 68, 187, 81, 87, 252, 39, 65, 209, 64, 178, 63, 178, 69, 5, 247, 172, 14, 148, 78, 120, 110, 92, 118, 191, 130, 29, 111, 21, 65, 215]), transcriptFinalDigest := (bytes [120, 150, 198, 157, 183, 29, 181, 168, 84, 91, 217, 92, 129, 32, 61, 159, 114, 123, 152, 127, 69, 68, 165, 115, 230, 23, 147, 254, 240, 0, 112, 198]), digest := (bytes [211, 61, 218, 162, 39, 130, 167, 129, 31, 174, 19, 79, 203, 166, 188, 64, 212, 151, 189, 104, 32, 253, 116, 92, 84, 28, 5, 171, 249, 65, 145, 147]) }, digest := (bytes [127, 140, 234, 181, 168, 45, 8, 196, 116, 176, 114, 36, 9, 232, 44, 79, 216, 2, 76, 230, 168, 69, 220, 138, 147, 50, 137, 215, 194, 229, 157, 240]) }
  , digest := (bytes [53, 244, 238, 44, 57, 32, 164, 54, 200, 144, 150, 67, 139, 32, 175, 27, 164, 37, 207, 8, 161, 103, 84, 219, 196, 127, 44, 63, 4, 42, 70, 41])
}
    , exportedKernelProof := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "multiply_high_mulh_mulhu_mulhsu_ecall", fixtureId := "multiply_high_mulh_mulhu_mulhsu_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.multiply, .controlFlow] }
  , executionDigest := (bytes [253, 56, 202, 101, 142, 132, 93, 134, 75, 217, 118, 33, 12, 112, 138, 94, 76, 57, 89, 198, 120, 58, 231, 25, 226, 162, 224, 124, 164, 228, 241, 216])
  , shape := { executionRowCount := 20, realRowCount := 4, effectRowCount := 4, commitRowCount := 4, digest := (bytes [59, 163, 65, 114, 71, 203, 144, 250, 133, 131, 27, 218, 175, 132, 145, 9, 167, 224, 25, 210, 57, 136, 160, 228, 226, 219, 137, 198, 45, 37, 220, 249]) }
  , digest := (bytes [87, 190, 113, 20, 186, 182, 14, 185, 37, 191, 147, 144, 5, 87, 60, 209, 224, 173, 239, 91, 134, 183, 254, 180, 78, 119, 90, 185, 106, 193, 86, 105])
}
  , stages := { summary := { stage1RowCount := 20, stage2RegisterReadCount := 34, stage2RegisterWriteCount := 19, stage2RamEventCount := 0, stage2TwistLinkCount := 20, stage3ContinuityCount := 4, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [255, 24, 93, 239, 18, 91, 171, 28, 223, 204, 202, 124, 227, 86, 233, 201, 83, 172, 80, 193, 136, 215, 72, 104, 247, 205, 80, 146, 165, 255, 200, 255]) }, digest := (bytes [245, 102, 156, 90, 74, 70, 146, 73, 212, 89, 104, 24, 161, 60, 41, 146, 100, 19, 24, 43, 92, 110, 220, 101, 4, 86, 90, 196, 253, 64, 18, 42]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [70, 47, 32, 181, 107, 177, 216, 251, 0, 96, 119, 64, 150, 0, 74, 134, 39, 166, 239, 171, 130, 128, 99, 70, 185, 223, 7, 31, 93, 150, 85, 55]), stage1Digest := (bytes [119, 218, 212, 143, 84, 5, 68, 70, 103, 149, 150, 166, 87, 83, 126, 28, 62, 243, 151, 29, 60, 52, 29, 156, 124, 167, 241, 115, 150, 56, 50, 228]), stage2Digest := (bytes [189, 140, 3, 161, 137, 109, 65, 178, 71, 224, 130, 138, 61, 59, 201, 89, 255, 58, 87, 9, 210, 58, 150, 166, 7, 97, 142, 52, 198, 124, 61, 7]), stage3Digest := (bytes [36, 225, 132, 194, 224, 112, 136, 254, 241, 228, 10, 51, 211, 162, 201, 21, 129, 198, 178, 230, 72, 16, 240, 160, 192, 242, 8, 234, 55, 33, 177, 139]), transcriptDigest := (bytes [120, 150, 198, 157, 183, 29, 181, 168, 84, 91, 217, 92, 129, 32, 61, 159, 114, 123, 152, 127, 69, 68, 165, 115, 230, 23, 147, 254, 240, 0, 112, 198]), executionDigest := (bytes [253, 56, 202, 101, 142, 132, 93, 134, 75, 217, 118, 33, 12, 112, 138, 94, 76, 57, 89, 198, 120, 58, 231, 25, 226, 162, 224, 124, 164, 228, 241, 216]), digest := (bytes [255, 249, 153, 248, 151, 143, 63, 2, 185, 112, 164, 47, 36, 214, 3, 20, 30, 60, 58, 8, 190, 192, 175, 58, 171, 177, 116, 180, 157, 92, 52, 245]) }, statementDigest := (bytes [65, 170, 247, 137, 42, 100, 251, 203, 22, 85, 243, 254, 99, 185, 112, 125, 180, 33, 208, 243, 113, 32, 49, 129, 63, 112, 67, 250, 127, 76, 52, 129]), proofDigest := (bytes [104, 146, 73, 104, 116, 95, 200, 172, 230, 213, 189, 116, 148, 86, 238, 55, 94, 87, 141, 7, 170, 31, 11, 133, 156, 193, 26, 80, 239, 191, 128, 227]), digest := (bytes [154, 191, 59, 142, 143, 78, 16, 57, 13, 122, 149, 108, 83, 186, 13, 160, 101, 219, 21, 202, 214, 211, 41, 112, 34, 249, 222, 108, 174, 63, 179, 237]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [253, 68, 102, 128, 114, 247, 96, 30, 42, 155, 72, 120, 189, 122, 83, 246, 73, 123, 104, 153, 131, 27, 149, 124, 249, 24, 106, 81, 205, 160, 156, 232]), stage1Digest := (bytes [6, 10, 87, 34, 241, 198, 152, 111, 25, 24, 54, 182, 89, 57, 247, 48, 242, 144, 226, 150, 167, 143, 175, 224, 254, 182, 192, 43, 164, 232, 67, 22]), stage2Digest := (bytes [218, 40, 31, 235, 102, 3, 46, 12, 84, 131, 99, 11, 21, 10, 80, 37, 106, 103, 252, 44, 250, 58, 169, 51, 76, 29, 215, 63, 181, 188, 27, 111]), stage3Digest := (bytes [11, 50, 217, 85, 206, 200, 239, 139, 234, 25, 96, 96, 132, 20, 133, 5, 36, 123, 115, 179, 2, 255, 142, 86, 179, 60, 240, 89, 255, 62, 179, 48]), digest := (bytes [179, 79, 124, 213, 197, 219, 93, 112, 48, 42, 73, 201, 179, 124, 255, 216, 54, 77, 106, 35, 178, 39, 18, 1, 199, 24, 17, 127, 89, 156, 94, 37]) }, digest := (bytes [27, 207, 142, 24, 29, 52, 215, 192, 49, 83, 98, 73, 13, 203, 80, 250, 150, 170, 175, 117, 0, 22, 29, 27, 195, 243, 22, 118, 42, 207, 134, 126]) }
  , kernelOpening := { openingDigest := (bytes [198, 84, 146, 64, 111, 119, 190, 121, 159, 108, 161, 239, 196, 219, 253, 57, 156, 179, 128, 200, 150, 72, 115, 128, 184, 62, 117, 82, 200, 134, 59, 132]), bindings := { claimDigest := (bytes [57, 252, 166, 206, 50, 86, 5, 153, 150, 113, 83, 200, 199, 104, 253, 16, 89, 102, 78, 215, 127, 45, 39, 160, 68, 94, 193, 22, 228, 124, 251, 217]), bindingsDigest := (bytes [229, 202, 10, 251, 106, 127, 222, 240, 249, 36, 93, 163, 113, 62, 72, 62, 57, 8, 91, 47, 197, 119, 41, 238, 165, 135, 41, 137, 39, 142, 226, 11]), preparedStepsDigest := (bytes [160, 151, 120, 21, 206, 145, 64, 91, 14, 148, 98, 135, 27, 128, 129, 141, 192, 57, 207, 232, 9, 243, 128, 103, 109, 149, 129, 179, 71, 87, 65, 181]), digest := (bytes [182, 190, 74, 60, 203, 251, 25, 255, 203, 111, 169, 173, 153, 233, 249, 22, 157, 151, 48, 46, 82, 90, 141, 149, 110, 70, 220, 144, 91, 87, 107, 117]) }, digest := (bytes [141, 147, 194, 158, 1, 113, 164, 5, 52, 60, 204, 22, 214, 218, 60, 235, 163, 130, 167, 78, 77, 79, 166, 89, 20, 6, 80, 169, 90, 145, 220, 253]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [56, 55, 65, 136, 166, 105, 55, 221, 32, 59, 92, 217, 19, 218, 150, 142, 9, 231, 253, 237, 17, 141, 61, 10, 157, 65, 174, 106, 188, 85, 117, 232]), terminal := { root0Digest := (bytes [243, 33, 113, 153, 9, 235, 68, 117, 29, 132, 237, 169, 175, 129, 160, 239, 59, 177, 90, 147, 52, 212, 120, 200, 192, 235, 87, 137, 127, 175, 131, 194]), executionDigest := (bytes [253, 56, 202, 101, 142, 132, 93, 134, 75, 217, 118, 33, 12, 112, 138, 94, 76, 57, 89, 198, 120, 58, 231, 25, 226, 162, 224, 124, 164, 228, 241, 216]), finalStateDigest := (bytes [64, 177, 68, 187, 81, 87, 252, 39, 65, 209, 64, 178, 63, 178, 69, 5, 247, 172, 14, 148, 78, 120, 110, 92, 118, 191, 130, 29, 111, 21, 65, 215]), transcriptFinalDigest := (bytes [120, 150, 198, 157, 183, 29, 181, 168, 84, 91, 217, 92, 129, 32, 61, 159, 114, 123, 152, 127, 69, 68, 165, 115, 230, 23, 147, 254, 240, 0, 112, 198]), finalPc := 16, halted := true, digest := (bytes [171, 30, 191, 224, 99, 223, 179, 117, 65, 45, 229, 73, 132, 2, 198, 34, 76, 148, 13, 19, 129, 37, 20, 65, 127, 7, 62, 77, 92, 35, 32, 125]) }, digest := (bytes [110, 101, 243, 133, 133, 41, 232, 139, 240, 162, 182, 159, 61, 123, 193, 9, 167, 76, 83, 71, 24, 83, 67, 116, 247, 59, 84, 55, 31, 113, 173, 156]) }, statementDigest := (bytes [112, 113, 21, 103, 107, 197, 161, 221, 119, 129, 146, 170, 156, 57, 144, 189, 106, 201, 102, 13, 245, 131, 180, 125, 41, 26, 184, 82, 105, 229, 160, 44]), proofDigest := (bytes [5, 43, 177, 20, 43, 145, 65, 217, 251, 241, 227, 77, 229, 213, 236, 99, 136, 172, 221, 132, 130, 21, 67, 230, 22, 38, 32, 8, 120, 139, 196, 252]), digest := (bytes [38, 238, 244, 237, 19, 102, 134, 67, 255, 223, 166, 62, 88, 132, 120, 38, 23, 234, 112, 247, 106, 254, 59, 151, 138, 102, 58, 65, 200, 148, 101, 31]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [171, 224, 63, 43, 249, 74, 225, 231, 62, 81, 99, 246, 21, 22, 245, 111, 89, 94, 177, 243, 37, 191, 68, 180, 9, 24, 201, 59, 114, 116, 96, 14]), layoutVersion := 1, digest := (bytes [195, 60, 175, 242, 0, 182, 128, 130, 166, 241, 208, 233, 227, 162, 249, 61, 247, 191, 144, 26, 215, 50, 223, 212, 108, 31, 169, 122, 166, 223, 167, 83]) }, rowWidth := 38, timeLen := 20, columnDigests := [(bytes [199, 57, 218, 242, 224, 219, 158, 68, 215, 187, 96, 181, 151, 77, 205, 24, 48, 176, 155, 147, 109, 207, 131, 76, 49, 50, 103, 236, 189, 78, 9, 147]), (bytes [99, 48, 0, 205, 223, 203, 201, 183, 80, 150, 15, 104, 75, 254, 20, 172, 5, 27, 49, 46, 89, 164, 236, 136, 72, 153, 142, 0, 42, 148, 252, 208]), (bytes [36, 195, 3, 23, 204, 207, 187, 92, 134, 65, 178, 127, 245, 52, 1, 162, 126, 151, 221, 177, 208, 31, 231, 155, 90, 58, 153, 245, 68, 0, 240, 103]), (bytes [89, 63, 211, 203, 102, 246, 143, 81, 89, 207, 248, 85, 99, 165, 30, 91, 192, 59, 192, 250, 16, 166, 139, 207, 219, 207, 36, 142, 232, 96, 192, 44]), (bytes [113, 127, 125, 130, 71, 31, 68, 221, 233, 32, 247, 34, 239, 167, 174, 36, 31, 184, 199, 64, 194, 125, 224, 240, 191, 198, 237, 167, 62, 90, 96, 14]), (bytes [186, 200, 182, 147, 241, 252, 231, 126, 240, 229, 127, 182, 218, 96, 185, 151, 145, 86, 52, 78, 20, 31, 94, 133, 56, 247, 201, 49, 168, 6, 115, 210]), (bytes [20, 239, 222, 15, 28, 249, 226, 194, 34, 201, 188, 165, 49, 102, 255, 52, 17, 120, 85, 66, 76, 236, 75, 106, 241, 40, 111, 2, 199, 49, 66, 129]), (bytes [155, 229, 31, 161, 157, 48, 177, 68, 31, 151, 237, 55, 220, 226, 115, 87, 178, 72, 240, 124, 163, 209, 241, 233, 81, 208, 232, 166, 72, 132, 207, 121]), (bytes [141, 140, 151, 173, 50, 143, 215, 38, 128, 21, 96, 159, 60, 16, 93, 194, 28, 165, 7, 118, 136, 8, 254, 34, 209, 124, 210, 88, 134, 172, 165, 242]), (bytes [199, 162, 226, 113, 228, 252, 225, 138, 196, 134, 111, 23, 169, 182, 26, 100, 208, 27, 39, 53, 145, 219, 86, 152, 192, 237, 175, 179, 167, 93, 188, 94]), (bytes [191, 167, 98, 84, 60, 165, 246, 85, 129, 174, 87, 162, 68, 168, 194, 224, 187, 111, 92, 227, 53, 121, 5, 48, 7, 228, 167, 191, 137, 229, 166, 170]), (bytes [160, 102, 96, 180, 246, 11, 52, 159, 119, 76, 141, 231, 133, 23, 9, 119, 228, 1, 70, 206, 126, 162, 179, 28, 156, 184, 163, 31, 182, 58, 88, 215]), (bytes [119, 144, 167, 4, 144, 100, 3, 176, 118, 116, 10, 43, 195, 7, 229, 110, 54, 108, 24, 115, 166, 12, 93, 185, 8, 236, 7, 93, 53, 189, 116, 238]), (bytes [160, 140, 215, 227, 142, 180, 183, 126, 61, 192, 126, 80, 155, 85, 239, 167, 248, 137, 93, 73, 1, 200, 114, 168, 112, 221, 50, 21, 238, 112, 66, 137]), (bytes [29, 191, 87, 134, 114, 120, 112, 77, 54, 230, 225, 160, 156, 69, 104, 233, 35, 230, 20, 201, 163, 119, 150, 230, 235, 74, 203, 254, 28, 129, 68, 144]), (bytes [220, 134, 74, 254, 168, 170, 90, 218, 220, 173, 45, 14, 192, 32, 17, 92, 118, 17, 21, 108, 194, 255, 107, 224, 122, 195, 197, 203, 150, 35, 246, 38]), (bytes [23, 221, 175, 82, 173, 40, 177, 63, 122, 124, 63, 200, 23, 59, 66, 72, 139, 28, 221, 165, 134, 118, 18, 108, 110, 25, 104, 195, 235, 31, 183, 105]), (bytes [19, 242, 208, 114, 246, 72, 120, 4, 108, 22, 97, 237, 194, 18, 147, 141, 70, 8, 138, 161, 44, 126, 1, 150, 233, 62, 99, 194, 228, 4, 7, 60]), (bytes [143, 63, 44, 207, 193, 170, 223, 121, 72, 38, 251, 158, 186, 24, 156, 134, 119, 200, 24, 69, 58, 205, 28, 146, 68, 123, 182, 59, 187, 70, 101, 157]), (bytes [82, 198, 219, 146, 209, 228, 0, 63, 23, 140, 218, 8, 118, 185, 16, 163, 209, 190, 40, 23, 2, 29, 193, 207, 208, 61, 181, 29, 83, 223, 140, 118]), (bytes [213, 212, 105, 129, 90, 226, 186, 46, 54, 94, 7, 8, 200, 118, 213, 207, 26, 95, 5, 248, 212, 29, 125, 167, 241, 209, 160, 70, 78, 145, 153, 124]), (bytes [110, 10, 95, 75, 51, 135, 244, 161, 129, 133, 205, 17, 204, 168, 179, 82, 234, 251, 49, 40, 61, 55, 155, 222, 255, 254, 189, 184, 151, 47, 122, 31]), (bytes [143, 33, 187, 119, 210, 61, 33, 128, 104, 91, 227, 144, 242, 32, 21, 215, 211, 250, 225, 212, 103, 252, 98, 115, 14, 243, 255, 123, 47, 157, 26, 243]), (bytes [215, 73, 51, 105, 58, 149, 81, 194, 219, 52, 130, 177, 222, 8, 21, 210, 5, 207, 49, 180, 184, 255, 192, 16, 55, 82, 71, 19, 253, 161, 96, 104]), (bytes [250, 98, 150, 222, 194, 20, 56, 122, 190, 148, 37, 175, 141, 61, 45, 142, 216, 103, 215, 157, 193, 179, 140, 10, 91, 3, 99, 9, 240, 124, 210, 173]), (bytes [190, 136, 248, 225, 222, 253, 46, 33, 200, 133, 253, 210, 70, 204, 87, 55, 169, 174, 37, 145, 73, 225, 153, 86, 46, 206, 245, 174, 40, 19, 104, 149]), (bytes [173, 186, 166, 20, 194, 0, 154, 126, 238, 199, 229, 202, 82, 199, 113, 9, 230, 155, 178, 88, 159, 104, 225, 33, 209, 141, 149, 119, 155, 197, 110, 213]), (bytes [81, 161, 204, 190, 177, 184, 85, 120, 28, 157, 158, 220, 28, 73, 128, 253, 140, 113, 246, 62, 211, 188, 122, 206, 220, 238, 176, 237, 117, 161, 0, 74]), (bytes [204, 150, 94, 210, 198, 197, 205, 40, 103, 192, 126, 176, 207, 85, 169, 214, 193, 164, 70, 147, 153, 222, 165, 162, 184, 105, 43, 246, 72, 81, 179, 31]), (bytes [112, 190, 127, 210, 196, 91, 121, 216, 190, 103, 234, 134, 56, 255, 143, 82, 145, 93, 119, 145, 12, 168, 183, 157, 150, 255, 107, 65, 170, 82, 21, 235]), (bytes [214, 89, 191, 109, 21, 218, 236, 154, 83, 18, 54, 215, 222, 109, 74, 135, 224, 173, 247, 174, 42, 210, 43, 167, 39, 41, 253, 77, 195, 146, 146, 214]), (bytes [130, 206, 12, 128, 116, 252, 135, 80, 244, 108, 186, 197, 44, 92, 183, 69, 200, 72, 211, 195, 131, 228, 33, 66, 82, 200, 179, 222, 35, 36, 46, 53]), (bytes [30, 174, 79, 121, 65, 219, 110, 233, 104, 173, 47, 250, 248, 186, 51, 18, 233, 106, 158, 31, 210, 255, 216, 247, 66, 63, 184, 92, 64, 177, 197, 23]), (bytes [246, 158, 186, 43, 36, 74, 166, 236, 79, 158, 243, 35, 212, 72, 68, 198, 116, 32, 121, 218, 154, 118, 208, 56, 160, 244, 61, 201, 85, 48, 159, 93]), (bytes [141, 183, 79, 72, 221, 229, 227, 58, 251, 55, 254, 17, 223, 169, 236, 10, 37, 101, 81, 83, 170, 118, 143, 227, 71, 5, 6, 200, 162, 35, 182, 112]), (bytes [185, 163, 191, 38, 99, 54, 152, 226, 199, 110, 164, 217, 233, 133, 253, 32, 30, 212, 79, 20, 215, 238, 152, 166, 233, 202, 69, 255, 252, 184, 201, 176]), (bytes [193, 67, 131, 128, 216, 120, 11, 160, 59, 118, 83, 134, 33, 180, 32, 153, 12, 167, 149, 198, 161, 255, 166, 30, 166, 91, 128, 93, 168, 129, 38, 230]), (bytes [136, 3, 111, 102, 197, 171, 236, 253, 23, 47, 92, 61, 161, 223, 251, 82, 79, 56, 23, 29, 95, 26, 73, 177, 249, 201, 202, 221, 26, 168, 179, 26])], familyDigest := (bytes [171, 224, 63, 43, 249, 74, 225, 231, 62, 81, 99, 246, 21, 22, 245, 111, 89, 94, 177, 243, 37, 191, 68, 180, 9, 24, 201, 59, 114, 116, 96, 14]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [171, 224, 63, 43, 249, 74, 225, 231, 62, 81, 99, 246, 21, 22, 245, 111, 89, 94, 177, 243, 37, 191, 68, 180, 9, 24, 201, 59, 114, 116, 96, 14]), layoutVersion := 1, digest := (bytes [195, 60, 175, 242, 0, 182, 128, 130, 166, 241, 208, 233, 227, 162, 249, 61, 247, 191, 144, 26, 215, 50, 223, 212, 108, 31, 169, 122, 166, 223, 167, 83]) }, logicalIndex := 0, digest := (bytes [44, 208, 166, 220, 7, 118, 202, 186, 32, 64, 247, 246, 176, 36, 60, 214, 15, 67, 63, 142, 244, 85, 221, 67, 105, 38, 45, 247, 155, 175, 4, 245]) }, valueDigest := (bytes [158, 63, 138, 206, 127, 145, 146, 109, 103, 153, 88, 114, 209, 198, 164, 199, 49, 182, 5, 151, 139, 25, 106, 81, 245, 88, 121, 14, 33, 120, 32, 196]), digest := (bytes [176, 201, 107, 186, 67, 164, 205, 98, 198, 118, 96, 140, 24, 206, 27, 122, 43, 121, 3, 221, 245, 101, 16, 164, 108, 55, 16, 184, 60, 138, 164, 156]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [171, 224, 63, 43, 249, 74, 225, 231, 62, 81, 99, 246, 21, 22, 245, 111, 89, 94, 177, 243, 37, 191, 68, 180, 9, 24, 201, 59, 114, 116, 96, 14]), layoutVersion := 1, digest := (bytes [195, 60, 175, 242, 0, 182, 128, 130, 166, 241, 208, 233, 227, 162, 249, 61, 247, 191, 144, 26, 215, 50, 223, 212, 108, 31, 169, 122, 166, 223, 167, 83]) }, logicalIndex := 19, digest := (bytes [95, 98, 214, 207, 168, 225, 165, 46, 72, 5, 204, 165, 163, 38, 141, 197, 68, 228, 12, 178, 99, 226, 246, 107, 247, 52, 36, 234, 17, 113, 63, 206]) }, valueDigest := (bytes [82, 160, 133, 135, 90, 74, 33, 242, 167, 29, 94, 199, 13, 129, 162, 84, 101, 207, 110, 195, 203, 13, 137, 237, 155, 115, 102, 78, 93, 59, 31, 37]), digest := (bytes [166, 225, 149, 216, 78, 142, 12, 228, 37, 240, 55, 30, 144, 48, 78, 28, 229, 56, 186, 2, 231, 23, 50, 115, 64, 99, 154, 101, 186, 197, 100, 255]) }), digest := (bytes [33, 31, 63, 90, 59, 250, 60, 157, 168, 213, 143, 188, 18, 195, 59, 75, 168, 114, 83, 102, 100, 133, 81, 79, 163, 29, 214, 62, 1, 183, 65, 48]) }
  , rootLaneCommitment := { timeLen := 20, commitments := { commitmentCount := 38, digest := (bytes [212, 205, 99, 165, 179, 213, 216, 52, 3, 111, 39, 206, 164, 185, 138, 173, 4, 18, 72, 230, 120, 223, 52, 220, 233, 175, 26, 2, 158, 238, 255, 174]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [212, 205, 99, 165, 179, 213, 216, 52, 3, 111, 39, 206, 164, 185, 138, 173, 4, 18, 72, 230, 120, 223, 52, 220, 233, 175, 26, 2, 158, 238, 255, 174]), layoutVersion := 3, digest := (bytes [108, 219, 176, 66, 40, 133, 237, 106, 119, 34, 250, 122, 114, 69, 60, 225, 151, 212, 179, 30, 218, 106, 205, 20, 247, 174, 89, 29, 93, 30, 175, 128]) }, logicalIndex := 0, digest := (bytes [211, 213, 209, 113, 179, 55, 161, 232, 121, 201, 243, 72, 119, 136, 63, 108, 133, 246, 161, 86, 238, 142, 145, 88, 113, 127, 217, 16, 223, 161, 88, 75]) }, valueDigest := (bytes [158, 63, 138, 206, 127, 145, 146, 109, 103, 153, 88, 114, 209, 198, 164, 199, 49, 182, 5, 151, 139, 25, 106, 81, 245, 88, 121, 14, 33, 120, 32, 196]), digest := (bytes [191, 83, 25, 35, 78, 235, 194, 227, 254, 254, 234, 224, 176, 9, 90, 171, 211, 218, 193, 16, 146, 5, 213, 132, 60, 208, 44, 15, 55, 232, 14, 220]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [212, 205, 99, 165, 179, 213, 216, 52, 3, 111, 39, 206, 164, 185, 138, 173, 4, 18, 72, 230, 120, 223, 52, 220, 233, 175, 26, 2, 158, 238, 255, 174]), layoutVersion := 3, digest := (bytes [108, 219, 176, 66, 40, 133, 237, 106, 119, 34, 250, 122, 114, 69, 60, 225, 151, 212, 179, 30, 218, 106, 205, 20, 247, 174, 89, 29, 93, 30, 175, 128]) }, logicalIndex := 19, digest := (bytes [105, 49, 34, 171, 7, 204, 146, 158, 175, 143, 55, 126, 234, 35, 10, 50, 47, 214, 49, 195, 242, 6, 48, 207, 226, 244, 123, 30, 15, 70, 204, 102]) }, valueDigest := (bytes [82, 160, 133, 135, 90, 74, 33, 242, 167, 29, 94, 199, 13, 129, 162, 84, 101, 207, 110, 195, 203, 13, 137, 237, 155, 115, 102, 78, 93, 59, 31, 37]), digest := (bytes [122, 22, 157, 76, 176, 180, 197, 55, 51, 178, 205, 194, 143, 161, 136, 221, 111, 214, 205, 82, 133, 124, 105, 171, 89, 209, 99, 80, 14, 216, 80, 60]) }), digest := (bytes [132, 218, 128, 216, 210, 30, 114, 205, 158, 193, 168, 74, 31, 216, 255, 49, 157, 128, 233, 88, 207, 242, 224, 154, 79, 27, 179, 137, 1, 11, 49, 84]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [33, 31, 63, 90, 59, 250, 60, 157, 168, 213, 143, 188, 18, 195, 59, 75, 168, 114, 83, 102, 100, 133, 81, 79, 163, 29, 214, 62, 1, 183, 65, 48]), rootLaneCommitmentDigest := (bytes [132, 218, 128, 216, 210, 30, 114, 205, 158, 193, 168, 74, 31, 216, 255, 49, 157, 128, 233, 88, 207, 242, 224, 154, 79, 27, 179, 137, 1, 11, 49, 84]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 20, digest := (bytes [63, 167, 53, 181, 40, 105, 105, 92, 184, 198, 65, 223, 185, 82, 6, 253, 77, 143, 221, 29, 34, 152, 46, 165, 163, 216, 220, 15, 81, 22, 7, 77]) }, statementDigest := (bytes [36, 155, 149, 100, 190, 91, 188, 216, 125, 113, 243, 71, 21, 87, 169, 138, 69, 3, 142, 167, 191, 54, 96, 236, 80, 178, 69, 51, 193, 235, 62, 100]), proofDigest := (bytes [4, 68, 47, 46, 191, 108, 1, 113, 249, 29, 108, 73, 175, 123, 14, 7, 124, 239, 135, 20, 92, 180, 80, 86, 127, 169, 148, 115, 219, 170, 185, 91]), digest := (bytes [205, 127, 238, 79, 18, 179, 165, 180, 84, 204, 50, 254, 220, 19, 108, 155, 119, 74, 122, 211, 237, 31, 211, 185, 204, 186, 49, 238, 206, 55, 188, 237]) }
  , digest := (bytes [29, 66, 224, 225, 150, 70, 133, 125, 182, 71, 86, 125, 111, 44, 218, 127, 207, 157, 130, 107, 143, 48, 162, 155, 221, 246, 241, 169, 241, 132, 177, 165])
}
    , transcript := {
  appLabel := (bytes [110, 101, 111, 46, 102, 111, 108, 100, 46, 110, 101, 120, 116, 47, 114, 118, 54, 52, 105, 109, 47, 112, 97, 114, 105, 116, 121, 95, 107, 101, 114, 110, 101, 108, 95, 118, 49])
  , events := [{
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 116, 114, 97, 110, 115, 99, 114, 105, 112, 116, 95, 115, 101, 101, 100])
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 109, 117, 108, 116, 105, 112, 108, 121, 45, 104, 105, 103, 104, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [12781167311334777, 12662, 12823906427971971140, 5458687368011659338, 248951889722183994, 6447366553477719410, 671691480699588116, 16458339740995496313], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [109, 117, 108, 116, 105, 112, 108, 121, 95, 104, 105, 103, 104, 95, 109, 117, 108, 104, 95, 109, 117, 108, 104, 117, 95, 109, 117, 108, 104, 115, 117, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [12781167311334777, 12662, 12823906427971971140, 5458687368011659338, 248951889722183994, 6447366553477719410, 671691480699588116, 16458339740995496313], absorbed := 2 }
  , cursorAfter := { stateWords := [27412359785313128, 27756, 2108779813393257755, 10371293853381360518, 16650352946910516604, 15704720784864639920, 634774211277878388, 2635468374773951633], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [35689395, 37860403, 40019123, 115]
  , cursorBefore := { stateWords := [27412359785313128, 27756, 2108779813393257755, 10371293853381360518, 16650352946910516604, 15704720784864639920, 634774211277878388, 2635468374773951633], absorbed := 2 }
  , cursorAfter := { stateWords := [8812575801016892909, 13040938893226428394, 9701684088077420472, 5819287778781878817, 17896264116935920441, 16593576036334108354, 18272699806094930130, 16560517447366102286], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 18446744073709551614, 18446744073709551613, 18446744073709551614, 3, 18446744073709551614, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [8812575801016892909, 13040938893226428394, 9701684088077420472, 5819287778781878817, 17896264116935920441, 16593576036334108354, 18272699806094930130, 16560517447366102286], absorbed := 0 }
  , cursorAfter := { stateWords := [0, 0, 16580090554124809443, 14270154524921358245, 4254892177879671707, 15516828335114826966, 1193383185617325903, 1696859638442303879], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [0, 0, 16580090554124809443, 14270154524921358245, 4254892177879671707, 15516828335114826966, 1193383185617325903, 1696859638442303879], absorbed := 2 }
  , cursorAfter := { stateWords := [13348506805888363, 30506403037277801, 34184295084289375, 0, 15284436219820320381, 4680745356388154385, 1520290972219069691, 3768744203301526206], absorbed := 4 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [243, 33, 113, 153, 9, 235, 68, 117, 29, 132, 237, 169, 175, 129, 160, 239, 59, 177, 90, 147, 52, 212, 120, 200, 192, 235, 87, 137, 127, 175, 131, 194])
  , u64s := []
  , cursorBefore := { stateWords := [13348506805888363, 30506403037277801, 34184295084289375, 0, 15284436219820320381, 4680745356388154385, 1520290972219069691, 3768744203301526206], absorbed := 4 }
  , cursorAfter := { stateWords := [14798716518789024, 38658741872654548, 3263410047, 16203063846249563458, 15952904281250505407, 11239127835845179134, 8682037629199545325, 12571069164232736769], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [14798716518789024, 38658741872654548, 3263410047, 16203063846249563458, 15952904281250505407, 11239127835845179134, 8682037629199545325, 12571069164232736769], absorbed := 3 }
  , cursorAfter := { stateWords := [12594224946114062434, 9120832401951012423, 15716666784263486997, 11771319206861947326, 14170695275895613368, 18155581864986460640, 8390403638239530622, 7721570034433765440], absorbed := 0 }
  , challengeOutput := (some 12594224946114062434)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [254, 135, 111, 142, 154, 116, 166, 185, 185, 222, 69, 53, 63, 69, 145, 188, 248, 151, 195, 191, 15, 203, 170, 159, 58, 111, 210, 59, 37, 159, 20, 59])
  , u64s := []
  , cursorBefore := { stateWords := [12594224946114062434, 9120832401951012423, 15716666784263486997, 11771319206861947326, 14170695275895613368, 18155581864986460640, 8390403638239530622, 7721570034433765440], absorbed := 0 }
  , cursorAfter := { stateWords := [4432971439848593, 16838398792673995, 991207205, 13523020166566597734, 9474816557060974975, 9682101722884499574, 11183025813400782569, 3504594574146367975], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [4432971439848593, 16838398792673995, 991207205, 13523020166566597734, 9474816557060974975, 9682101722884499574, 11183025813400782569, 3504594574146367975], absorbed := 3 }
  , cursorAfter := { stateWords := [7181907923970274102, 13984652350835454030, 14248157083981992134, 3489245716409723724, 11591148485536643942, 58840783525940945, 17639195001505837769, 4797479933805059576], absorbed := 0 }
  , challengeOutput := (some 7181907923970274102)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [7181907923970274102, 13984652350835454030, 14248157083981992134, 3489245716409723724, 11591148485536643942, 58840783525940945, 17639195001505837769, 4797479933805059576], absorbed := 0 }
  , cursorAfter := { stateWords := [4010680615921688272, 13559547375383272054, 12952106149071049557, 8601534984265556976, 9181871138784389685, 6401828817326474128, 2194921800358647068, 16636817962305181241], absorbed := 0 }
  , challengeOutput := (some 4010680615921688272)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [7, 82, 83, 13, 122, 202, 121, 111, 107, 12, 23, 144, 227, 48, 106, 126, 125, 114, 5, 27, 67, 29, 185, 192, 203, 20, 116, 55, 18, 178, 169, 18])
  , u64s := []
  , cursorBefore := { stateWords := [4010680615921688272, 13559547375383272054, 12952106149071049557, 8601534984265556976, 9181871138784389685, 6401828817326474128, 2194921800358647068, 16636817962305181241], absorbed := 0 }
  , cursorAfter := { stateWords := [18888533649227370, 15608756385659165, 313111058, 15518322506709063147, 2177833574961461427, 3085926819598395256, 10659100617218763088, 293927510401203621], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [18888533649227370, 15608756385659165, 313111058, 15518322506709063147, 2177833574961461427, 3085926819598395256, 10659100617218763088, 293927510401203621], absorbed := 3 }
  , cursorAfter := { stateWords := [16732273574652248418, 17216660654101797934, 8681142069474142655, 8589526100054592674, 12425421892153250114, 10855469906391529383, 15040391767145915989, 14904572834527225910], absorbed := 0 }
  , challengeOutput := (some 16732273574652248418)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [242, 180, 211, 44, 136, 191, 129, 103, 121, 27, 189, 177, 57, 84, 107, 37, 200, 205, 250, 244, 70, 251, 148, 129, 186, 236, 174, 139, 158, 109, 21, 76])
  , u64s := []
  , cursorBefore := { stateWords := [16732273574652248418, 17216660654101797934, 8681142069474142655, 8589526100054592674, 12425421892153250114, 10855469906391529383, 15040391767145915989, 14904572834527225910], absorbed := 0 }
  , cursorAfter := { stateWords := [19972606401193323, 39317353527350523, 1276472734, 230307616887654781, 12142287865684510284, 1060846835713975250, 903991690148070134, 15589771422270397194], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [253, 56, 202, 101, 142, 132, 93, 134, 75, 217, 118, 33, 12, 112, 138, 94, 76, 57, 89, 198, 120, 58, 231, 25, 226, 162, 224, 124, 164, 228, 241, 216])
  , u64s := []
  , cursorBefore := { stateWords := [19972606401193323, 39317353527350523, 1276472734, 230307616887654781, 12142287865684510284, 1060846835713975250, 903991690148070134, 15589771422270397194], absorbed := 3 }
  , cursorAfter := { stateWords := [33995083720973962, 35149887294793530, 3639731364, 11322723073178918445, 15677348921421630016, 3056688719395752326, 9239857230922062512, 8647286844324451561], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [64, 177, 68, 187, 81, 87, 252, 39, 65, 209, 64, 178, 63, 178, 69, 5, 247, 172, 14, 148, 78, 120, 110, 92, 118, 191, 130, 29, 111, 21, 65, 215])
  , u64s := []
  , cursorBefore := { stateWords := [33995083720973962, 35149887294793530, 3639731364, 11322723073178918445, 15677348921421630016, 3056688719395752326, 9239857230922062512, 8647286844324451561], absorbed := 3 }
  , cursorAfter := { stateWords := [22117838935754053, 8306533160742520, 3611366767, 15240032141194505930, 17094688214166531567, 3210725922644817130, 13724988163006776507, 17795306660117163208], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [22117838935754053, 8306533160742520, 3611366767, 15240032141194505930, 17094688214166531567, 3210725922644817130, 13724988163006776507, 17795306660117163208], absorbed := 3 }
  , cursorAfter := { stateWords := [6150446324893315326, 13940408834710205269, 3096927730202394539, 3312457634550628283, 18189760578090884427, 14404345729445534689, 2505855645016552390, 4862682994486841645], absorbed := 0 }
  , challengeOutput := (some 6150446324893315326)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [6150446324893315326, 13940408834710205269, 3096927730202394539, 3312457634550628283, 18189760578090884427, 14404345729445534689, 2505855645016552390, 4862682994486841645], absorbed := 0 }
  , cursorAfter := { stateWords := [12156655443619780216, 11474363165590510420, 8333141750803102578, 14298929851964528614, 10874228520263782992, 3844157008634569532, 7739098619381804857, 15111327435554719867], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [120, 150, 198, 157, 183, 29, 181, 168, 84, 91, 217, 92, 129, 32, 61, 159, 114, 123, 152, 127, 69, 68, 165, 115, 230, 23, 147, 254, 240, 0, 112, 198]))
}]
}
    , stage1 := stage1
    , stage2 := stage2
    , stage3 := stage3
    , rootExecution := rootExecution
    , stepComposition := stepComposition
    , soundnessAccounting := soundnessAccounting
    , kernelOpeningBundle := kernelOpeningBundle
    , digest := (bytes [125, 24, 175, 131, 238, 1, 103, 133, 17, 241, 225, 72, 69, 66, 194, 82, 44, 9, 243, 252, 241, 222, 147, 45, 87, 88, 234, 147, 121, 203, 81, 45])
  }

end Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors.Case_multiply_high_mulh_mulhu_mulhsu_ecall
