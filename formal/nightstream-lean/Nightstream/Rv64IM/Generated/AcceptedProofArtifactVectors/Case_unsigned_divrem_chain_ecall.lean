import Nightstream.Rv64IM.Generated.AcceptedProofArtifactTypes

set_option maxHeartbeats 0
set_option maxRecDepth 65536

namespace Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors.Case_unsigned_divrem_chain_ecall

open Nightstream.Rv64IM.Generated

def stage1SemInputs : List SemInView :=
  [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, pc := 0, opcode := .divu, traceOpcode := none, traceVirtualOpcode := (some .advice), family := .unsignedDivRem, archRs1 := 1, archRs1Value := 20, archRs2 := 2, archRs2Value := 6, archRd := 5, archRdBefore := 0, archImm := 0, rs1 := 1, rs1Value := 20, rs2 := 2, rs2Value := 6, rd := 5, rdBefore := 0, rdAfter := 3, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := (some 2), isEffectRow := true, isCommitRow := false, isReal := false }, { traceIndex := 1, stepIndex := 0, sequenceIndex := 1, pc := 0, opcode := .divu, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .unsignedDivRem, archRs1 := 1, archRs1Value := 20, archRs2 := 2, archRs2Value := 6, archRd := 5, archRdBefore := 0, archImm := 0, rs1 := 5, rs1Value := 3, rs2 := 2, rs2Value := 6, rd := 40, rdBefore := 0, rdAfter := 18, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 1), isEffectRow := false, isCommitRow := false, isReal := false }, { traceIndex := 2, stepIndex := 0, sequenceIndex := 2, pc := 0, opcode := .divu, traceOpcode := (some .sub), traceVirtualOpcode := none, family := .unsignedDivRem, archRs1 := 1, archRs1Value := 20, archRs2 := 2, archRs2Value := 6, archRd := 5, archRdBefore := 0, archImm := 0, rs1 := 1, rs1Value := 20, rs2 := 40, rs2Value := 18, rd := 41, rdBefore := 0, rdAfter := 2, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 0), isEffectRow := false, isCommitRow := true, isReal := true }, { traceIndex := 3, stepIndex := 1, sequenceIndex := 0, pc := 4, opcode := .remu, traceOpcode := none, traceVirtualOpcode := (some .advice), family := .unsignedDivRem, archRs1 := 1, archRs1Value := 20, archRs2 := 2, archRs2Value := 6, archRd := 6, archRdBefore := 0, archImm := 0, rs1 := 1, rs1Value := 20, rs2 := 2, rs2Value := 6, rd := 40, rdBefore := 0, rdAfter := 3, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := (some 2), isEffectRow := false, isCommitRow := false, isReal := false }, { traceIndex := 4, stepIndex := 1, sequenceIndex := 1, pc := 4, opcode := .remu, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .unsignedDivRem, archRs1 := 1, archRs1Value := 20, archRs2 := 2, archRs2Value := 6, archRd := 6, archRdBefore := 0, archImm := 0, rs1 := 40, rs1Value := 3, rs2 := 2, rs2Value := 6, rd := 41, rdBefore := 0, rdAfter := 18, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 1), isEffectRow := false, isCommitRow := false, isReal := false }, { traceIndex := 5, stepIndex := 1, sequenceIndex := 2, pc := 4, opcode := .remu, traceOpcode := (some .sub), traceVirtualOpcode := none, family := .unsignedDivRem, archRs1 := 1, archRs1Value := 20, archRs2 := 2, archRs2Value := 6, archRd := 6, archRdBefore := 0, archImm := 0, rs1 := 1, rs1Value := 20, rs2 := 41, rs2Value := 18, rd := 6, rdBefore := 0, rdAfter := 2, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 0), isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 6, stepIndex := 2, sequenceIndex := 0, pc := 8, opcode := .divuw, traceOpcode := none, traceVirtualOpcode := (some .advice), family := .unsignedDivRem, archRs1 := 3, archRs1Value := 18446744073709551615, archRs2 := 4, archRs2Value := 3, archRd := 7, archRdBefore := 0, archImm := 0, rs1 := 3, rs1Value := 18446744073709551615, rs2 := 4, rs2Value := 3, rd := 7, rdBefore := 0, rdAfter := 1431655765, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := (some 3), isEffectRow := false, isCommitRow := false, isReal := false }, { traceIndex := 7, stepIndex := 2, sequenceIndex := 1, pc := 8, opcode := .divuw, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .unsignedDivRem, archRs1 := 3, archRs1Value := 18446744073709551615, archRs2 := 4, archRs2Value := 3, archRd := 7, archRdBefore := 0, archImm := 0, rs1 := 7, rs1Value := 1431655765, rs2 := 4, rs2Value := 3, rd := 40, rdBefore := 0, rdAfter := 4294967295, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 2), isEffectRow := false, isCommitRow := false, isReal := false }, { traceIndex := 8, stepIndex := 2, sequenceIndex := 2, pc := 8, opcode := .divuw, traceOpcode := (some .sub), traceVirtualOpcode := none, family := .unsignedDivRem, archRs1 := 3, archRs1Value := 18446744073709551615, archRs2 := 4, archRs2Value := 3, archRd := 7, archRdBefore := 0, archImm := 0, rs1 := 3, rs1Value := 18446744073709551615, rs2 := 40, rs2Value := 4294967295, rd := 41, rdBefore := 0, rdAfter := 18446744069414584320, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 1), isEffectRow := false, isCommitRow := false, isReal := false }, { traceIndex := 9, stepIndex := 2, sequenceIndex := 3, pc := 8, opcode := .divuw, traceOpcode := none, traceVirtualOpcode := (some .signExtendWord), family := .unsignedDivRem, archRs1 := 3, archRs1Value := 18446744073709551615, archRs2 := 4, archRs2Value := 3, archRd := 7, archRdBefore := 0, archImm := 0, rs1 := 7, rs1Value := 1431655765, rs2 := 0, rs2Value := 0, rd := 7, rdBefore := 1431655765, rdAfter := 1431655765, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 0), isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 10, stepIndex := 3, sequenceIndex := 0, pc := 12, opcode := .remuw, traceOpcode := none, traceVirtualOpcode := (some .advice), family := .unsignedDivRem, archRs1 := 3, archRs1Value := 18446744073709551615, archRs2 := 4, archRs2Value := 3, archRd := 8, archRdBefore := 0, archImm := 0, rs1 := 3, rs1Value := 18446744073709551615, rs2 := 4, rs2Value := 3, rd := 40, rdBefore := 0, rdAfter := 1431655765, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := (some 3), isEffectRow := false, isCommitRow := false, isReal := false }, { traceIndex := 11, stepIndex := 3, sequenceIndex := 1, pc := 12, opcode := .remuw, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .unsignedDivRem, archRs1 := 3, archRs1Value := 18446744073709551615, archRs2 := 4, archRs2Value := 3, archRd := 8, archRdBefore := 0, archImm := 0, rs1 := 40, rs1Value := 1431655765, rs2 := 4, rs2Value := 3, rd := 41, rdBefore := 0, rdAfter := 4294967295, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 2), isEffectRow := false, isCommitRow := false, isReal := false }, { traceIndex := 12, stepIndex := 3, sequenceIndex := 2, pc := 12, opcode := .remuw, traceOpcode := (some .sub), traceVirtualOpcode := none, family := .unsignedDivRem, archRs1 := 3, archRs1Value := 18446744073709551615, archRs2 := 4, archRs2Value := 3, archRd := 8, archRdBefore := 0, archImm := 0, rs1 := 3, rs1Value := 18446744073709551615, rs2 := 41, rs2Value := 4294967295, rd := 8, rdBefore := 0, rdAfter := 18446744069414584320, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 1), isEffectRow := false, isCommitRow := false, isReal := false }, { traceIndex := 13, stepIndex := 3, sequenceIndex := 3, pc := 12, opcode := .remuw, traceOpcode := none, traceVirtualOpcode := (some .signExtendWord), family := .unsignedDivRem, archRs1 := 3, archRs1Value := 18446744073709551615, archRs2 := 4, archRs2Value := 3, archRd := 8, archRdBefore := 0, archImm := 0, rs1 := 8, rs1Value := 18446744069414584320, rs2 := 0, rs2Value := 0, rd := 8, rdBefore := 18446744069414584320, rdAfter := 0, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 0), isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 14, stepIndex := 4, sequenceIndex := 0, pc := 16, opcode := .divu, traceOpcode := none, traceVirtualOpcode := (some .advice), family := .unsignedDivRem, archRs1 := 9, archRs1Value := 9, archRs2 := 10, archRs2Value := 0, archRd := 11, archRdBefore := 0, archImm := 0, rs1 := 9, rs1Value := 9, rs2 := 10, rs2Value := 0, rd := 11, rdBefore := 0, rdAfter := 18446744073709551615, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := (some 2), isEffectRow := true, isCommitRow := false, isReal := false }, { traceIndex := 15, stepIndex := 4, sequenceIndex := 1, pc := 16, opcode := .divu, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .unsignedDivRem, archRs1 := 9, archRs1Value := 9, archRs2 := 10, archRs2Value := 0, archRd := 11, archRdBefore := 0, archImm := 0, rs1 := 11, rs1Value := 18446744073709551615, rs2 := 10, rs2Value := 0, rd := 40, rdBefore := 0, rdAfter := 0, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 1), isEffectRow := false, isCommitRow := false, isReal := false }, { traceIndex := 16, stepIndex := 4, sequenceIndex := 2, pc := 16, opcode := .divu, traceOpcode := (some .sub), traceVirtualOpcode := none, family := .unsignedDivRem, archRs1 := 9, archRs1Value := 9, archRs2 := 10, archRs2Value := 0, archRd := 11, archRdBefore := 0, archImm := 0, rs1 := 9, rs1Value := 9, rs2 := 40, rs2Value := 0, rd := 41, rdBefore := 0, rdAfter := 9, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 0), isEffectRow := false, isCommitRow := true, isReal := true }, { traceIndex := 17, stepIndex := 5, sequenceIndex := 0, pc := 20, opcode := .remu, traceOpcode := none, traceVirtualOpcode := (some .advice), family := .unsignedDivRem, archRs1 := 9, archRs1Value := 9, archRs2 := 10, archRs2Value := 0, archRd := 12, archRdBefore := 0, archImm := 0, rs1 := 9, rs1Value := 9, rs2 := 10, rs2Value := 0, rd := 40, rdBefore := 0, rdAfter := 18446744073709551615, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := (some 2), isEffectRow := false, isCommitRow := false, isReal := false }, { traceIndex := 18, stepIndex := 5, sequenceIndex := 1, pc := 20, opcode := .remu, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .unsignedDivRem, archRs1 := 9, archRs1Value := 9, archRs2 := 10, archRs2Value := 0, archRd := 12, archRdBefore := 0, archImm := 0, rs1 := 40, rs1Value := 18446744073709551615, rs2 := 10, rs2Value := 0, rd := 41, rdBefore := 0, rdAfter := 0, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 1), isEffectRow := false, isCommitRow := false, isReal := false }, { traceIndex := 19, stepIndex := 5, sequenceIndex := 2, pc := 20, opcode := .remu, traceOpcode := (some .sub), traceVirtualOpcode := none, family := .unsignedDivRem, archRs1 := 9, archRs1Value := 9, archRs2 := 10, archRs2Value := 0, archRd := 12, archRdBefore := 0, archImm := 0, rs1 := 9, rs1Value := 9, rs2 := 41, rs2Value := 0, rd := 12, rdBefore := 0, rdAfter := 9, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 0), isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 20, stepIndex := 6, sequenceIndex := 0, pc := 24, opcode := .divuw, traceOpcode := none, traceVirtualOpcode := (some .advice), family := .unsignedDivRem, archRs1 := 13, archRs1Value := 18446744071562067969, archRs2 := 14, archRs2Value := 0, archRd := 15, archRdBefore := 0, archImm := 0, rs1 := 13, rs1Value := 18446744071562067969, rs2 := 14, rs2Value := 0, rd := 15, rdBefore := 0, rdAfter := 4294967295, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := (some 3), isEffectRow := false, isCommitRow := false, isReal := false }, { traceIndex := 21, stepIndex := 6, sequenceIndex := 1, pc := 24, opcode := .divuw, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .unsignedDivRem, archRs1 := 13, archRs1Value := 18446744071562067969, archRs2 := 14, archRs2Value := 0, archRd := 15, archRdBefore := 0, archImm := 0, rs1 := 15, rs1Value := 4294967295, rs2 := 14, rs2Value := 0, rd := 40, rdBefore := 0, rdAfter := 0, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 2), isEffectRow := false, isCommitRow := false, isReal := false }, { traceIndex := 22, stepIndex := 6, sequenceIndex := 2, pc := 24, opcode := .divuw, traceOpcode := (some .sub), traceVirtualOpcode := none, family := .unsignedDivRem, archRs1 := 13, archRs1Value := 18446744071562067969, archRs2 := 14, archRs2Value := 0, archRd := 15, archRdBefore := 0, archImm := 0, rs1 := 13, rs1Value := 18446744071562067969, rs2 := 40, rs2Value := 0, rd := 41, rdBefore := 0, rdAfter := 18446744071562067969, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 1), isEffectRow := false, isCommitRow := false, isReal := false }, { traceIndex := 23, stepIndex := 6, sequenceIndex := 3, pc := 24, opcode := .divuw, traceOpcode := none, traceVirtualOpcode := (some .signExtendWord), family := .unsignedDivRem, archRs1 := 13, archRs1Value := 18446744071562067969, archRs2 := 14, archRs2Value := 0, archRd := 15, archRdBefore := 0, archImm := 0, rs1 := 15, rs1Value := 4294967295, rs2 := 0, rs2Value := 0, rd := 15, rdBefore := 4294967295, rdAfter := 18446744073709551615, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 0), isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 24, stepIndex := 7, sequenceIndex := 0, pc := 28, opcode := .remuw, traceOpcode := none, traceVirtualOpcode := (some .advice), family := .unsignedDivRem, archRs1 := 13, archRs1Value := 18446744071562067969, archRs2 := 14, archRs2Value := 0, archRd := 16, archRdBefore := 0, archImm := 0, rs1 := 13, rs1Value := 18446744071562067969, rs2 := 14, rs2Value := 0, rd := 40, rdBefore := 0, rdAfter := 4294967295, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := (some 3), isEffectRow := false, isCommitRow := false, isReal := false }, { traceIndex := 25, stepIndex := 7, sequenceIndex := 1, pc := 28, opcode := .remuw, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .unsignedDivRem, archRs1 := 13, archRs1Value := 18446744071562067969, archRs2 := 14, archRs2Value := 0, archRd := 16, archRdBefore := 0, archImm := 0, rs1 := 40, rs1Value := 4294967295, rs2 := 14, rs2Value := 0, rd := 41, rdBefore := 0, rdAfter := 0, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 2), isEffectRow := false, isCommitRow := false, isReal := false }, { traceIndex := 26, stepIndex := 7, sequenceIndex := 2, pc := 28, opcode := .remuw, traceOpcode := (some .sub), traceVirtualOpcode := none, family := .unsignedDivRem, archRs1 := 13, archRs1Value := 18446744071562067969, archRs2 := 14, archRs2Value := 0, archRd := 16, archRdBefore := 0, archImm := 0, rs1 := 13, rs1Value := 18446744071562067969, rs2 := 41, rs2Value := 0, rd := 16, rdBefore := 0, rdAfter := 18446744071562067969, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 1), isEffectRow := false, isCommitRow := false, isReal := false }, { traceIndex := 27, stepIndex := 7, sequenceIndex := 3, pc := 28, opcode := .remuw, traceOpcode := none, traceVirtualOpcode := (some .signExtendWord), family := .unsignedDivRem, archRs1 := 13, archRs1Value := 18446744071562067969, archRs2 := 14, archRs2Value := 0, archRd := 16, archRdBefore := 0, archImm := 0, rs1 := 16, rs1Value := 18446744071562067969, rs2 := 0, rs2Value := 0, rd := 16, rdBefore := 18446744071562067969, rdAfter := 18446744071562067969, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := false, virtualSequenceRemaining := (some 0), isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 28, stepIndex := 8, sequenceIndex := 0, pc := 32, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 0, archRdBefore := 0, archImm := 0, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 0, rdBefore := 0, rdAfter := 0, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := false, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }]

def stage1RowBindings : List Stage1RowBindingView :=
  [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 35705523, opcode := .divu, traceOpcode := none, traceVirtualOpcode := (some .advice), family := .unsignedDivRem, nextPc := 0, aluResult := 3, effectiveAddr := none, writesRd := true, rd := 5, rdAfter := 3, isFirstInSequence := true, virtualSequenceRemaining := (some 2), isEffectRow := true, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 1, stepIndex := 0, sequenceIndex := 1, fetchPc := 0, fetchedWord := 35705523, opcode := .divu, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .unsignedDivRem, nextPc := 0, aluResult := 18, effectiveAddr := none, writesRd := true, rd := 40, rdAfter := 18, isFirstInSequence := false, virtualSequenceRemaining := (some 1), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 2, stepIndex := 0, sequenceIndex := 2, fetchPc := 0, fetchedWord := 35705523, opcode := .divu, traceOpcode := (some .sub), traceVirtualOpcode := none, family := .unsignedDivRem, nextPc := 4, aluResult := 2, effectiveAddr := none, writesRd := true, rd := 41, rdAfter := 2, isFirstInSequence := false, virtualSequenceRemaining := (some 0), isEffectRow := false, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 3, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 35713843, opcode := .remu, traceOpcode := none, traceVirtualOpcode := (some .advice), family := .unsignedDivRem, nextPc := 4, aluResult := 3, effectiveAddr := none, writesRd := true, rd := 40, rdAfter := 3, isFirstInSequence := true, virtualSequenceRemaining := (some 2), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 4, stepIndex := 1, sequenceIndex := 1, fetchPc := 4, fetchedWord := 35713843, opcode := .remu, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .unsignedDivRem, nextPc := 4, aluResult := 18, effectiveAddr := none, writesRd := true, rd := 41, rdAfter := 18, isFirstInSequence := false, virtualSequenceRemaining := (some 1), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 5, stepIndex := 1, sequenceIndex := 2, fetchPc := 4, fetchedWord := 35713843, opcode := .remu, traceOpcode := (some .sub), traceVirtualOpcode := none, family := .unsignedDivRem, nextPc := 8, aluResult := 2, effectiveAddr := none, writesRd := true, rd := 6, rdAfter := 2, isFirstInSequence := false, virtualSequenceRemaining := (some 0), isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 6, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 37868475, opcode := .divuw, traceOpcode := none, traceVirtualOpcode := (some .advice), family := .unsignedDivRem, nextPc := 8, aluResult := 1431655765, effectiveAddr := none, writesRd := true, rd := 7, rdAfter := 1431655765, isFirstInSequence := true, virtualSequenceRemaining := (some 3), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 7, stepIndex := 2, sequenceIndex := 1, fetchPc := 8, fetchedWord := 37868475, opcode := .divuw, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .unsignedDivRem, nextPc := 8, aluResult := 4294967295, effectiveAddr := none, writesRd := true, rd := 40, rdAfter := 4294967295, isFirstInSequence := false, virtualSequenceRemaining := (some 2), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 8, stepIndex := 2, sequenceIndex := 2, fetchPc := 8, fetchedWord := 37868475, opcode := .divuw, traceOpcode := (some .sub), traceVirtualOpcode := none, family := .unsignedDivRem, nextPc := 8, aluResult := 18446744069414584320, effectiveAddr := none, writesRd := true, rd := 41, rdAfter := 18446744069414584320, isFirstInSequence := false, virtualSequenceRemaining := (some 1), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 9, stepIndex := 2, sequenceIndex := 3, fetchPc := 8, fetchedWord := 37868475, opcode := .divuw, traceOpcode := none, traceVirtualOpcode := (some .signExtendWord), family := .unsignedDivRem, nextPc := 12, aluResult := 1431655765, effectiveAddr := none, writesRd := true, rd := 7, rdAfter := 1431655765, isFirstInSequence := false, virtualSequenceRemaining := (some 0), isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 10, stepIndex := 3, sequenceIndex := 0, fetchPc := 12, fetchedWord := 37876795, opcode := .remuw, traceOpcode := none, traceVirtualOpcode := (some .advice), family := .unsignedDivRem, nextPc := 12, aluResult := 1431655765, effectiveAddr := none, writesRd := true, rd := 40, rdAfter := 1431655765, isFirstInSequence := true, virtualSequenceRemaining := (some 3), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 11, stepIndex := 3, sequenceIndex := 1, fetchPc := 12, fetchedWord := 37876795, opcode := .remuw, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .unsignedDivRem, nextPc := 12, aluResult := 4294967295, effectiveAddr := none, writesRd := true, rd := 41, rdAfter := 4294967295, isFirstInSequence := false, virtualSequenceRemaining := (some 2), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 12, stepIndex := 3, sequenceIndex := 2, fetchPc := 12, fetchedWord := 37876795, opcode := .remuw, traceOpcode := (some .sub), traceVirtualOpcode := none, family := .unsignedDivRem, nextPc := 12, aluResult := 18446744069414584320, effectiveAddr := none, writesRd := true, rd := 8, rdAfter := 18446744069414584320, isFirstInSequence := false, virtualSequenceRemaining := (some 1), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 13, stepIndex := 3, sequenceIndex := 3, fetchPc := 12, fetchedWord := 37876795, opcode := .remuw, traceOpcode := none, traceVirtualOpcode := (some .signExtendWord), family := .unsignedDivRem, nextPc := 16, aluResult := 0, effectiveAddr := none, writesRd := true, rd := 8, rdAfter := 0, isFirstInSequence := false, virtualSequenceRemaining := (some 0), isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 14, stepIndex := 4, sequenceIndex := 0, fetchPc := 16, fetchedWord := 44357043, opcode := .divu, traceOpcode := none, traceVirtualOpcode := (some .advice), family := .unsignedDivRem, nextPc := 16, aluResult := 18446744073709551615, effectiveAddr := none, writesRd := true, rd := 11, rdAfter := 18446744073709551615, isFirstInSequence := true, virtualSequenceRemaining := (some 2), isEffectRow := true, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 15, stepIndex := 4, sequenceIndex := 1, fetchPc := 16, fetchedWord := 44357043, opcode := .divu, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .unsignedDivRem, nextPc := 16, aluResult := 0, effectiveAddr := none, writesRd := true, rd := 40, rdAfter := 0, isFirstInSequence := false, virtualSequenceRemaining := (some 1), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 16, stepIndex := 4, sequenceIndex := 2, fetchPc := 16, fetchedWord := 44357043, opcode := .divu, traceOpcode := (some .sub), traceVirtualOpcode := none, family := .unsignedDivRem, nextPc := 20, aluResult := 9, effectiveAddr := none, writesRd := true, rd := 41, rdAfter := 9, isFirstInSequence := false, virtualSequenceRemaining := (some 0), isEffectRow := false, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 17, stepIndex := 5, sequenceIndex := 0, fetchPc := 20, fetchedWord := 44365363, opcode := .remu, traceOpcode := none, traceVirtualOpcode := (some .advice), family := .unsignedDivRem, nextPc := 20, aluResult := 18446744073709551615, effectiveAddr := none, writesRd := true, rd := 40, rdAfter := 18446744073709551615, isFirstInSequence := true, virtualSequenceRemaining := (some 2), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 18, stepIndex := 5, sequenceIndex := 1, fetchPc := 20, fetchedWord := 44365363, opcode := .remu, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .unsignedDivRem, nextPc := 20, aluResult := 0, effectiveAddr := none, writesRd := true, rd := 41, rdAfter := 0, isFirstInSequence := false, virtualSequenceRemaining := (some 1), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 19, stepIndex := 5, sequenceIndex := 2, fetchPc := 20, fetchedWord := 44365363, opcode := .remu, traceOpcode := (some .sub), traceVirtualOpcode := none, family := .unsignedDivRem, nextPc := 24, aluResult := 9, effectiveAddr := none, writesRd := true, rd := 12, rdAfter := 9, isFirstInSequence := false, virtualSequenceRemaining := (some 0), isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 20, stepIndex := 6, sequenceIndex := 0, fetchPc := 24, fetchedWord := 48682939, opcode := .divuw, traceOpcode := none, traceVirtualOpcode := (some .advice), family := .unsignedDivRem, nextPc := 24, aluResult := 4294967295, effectiveAddr := none, writesRd := true, rd := 15, rdAfter := 4294967295, isFirstInSequence := true, virtualSequenceRemaining := (some 3), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 21, stepIndex := 6, sequenceIndex := 1, fetchPc := 24, fetchedWord := 48682939, opcode := .divuw, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .unsignedDivRem, nextPc := 24, aluResult := 0, effectiveAddr := none, writesRd := true, rd := 40, rdAfter := 0, isFirstInSequence := false, virtualSequenceRemaining := (some 2), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 22, stepIndex := 6, sequenceIndex := 2, fetchPc := 24, fetchedWord := 48682939, opcode := .divuw, traceOpcode := (some .sub), traceVirtualOpcode := none, family := .unsignedDivRem, nextPc := 24, aluResult := 18446744071562067969, effectiveAddr := none, writesRd := true, rd := 41, rdAfter := 18446744071562067969, isFirstInSequence := false, virtualSequenceRemaining := (some 1), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 23, stepIndex := 6, sequenceIndex := 3, fetchPc := 24, fetchedWord := 48682939, opcode := .divuw, traceOpcode := none, traceVirtualOpcode := (some .signExtendWord), family := .unsignedDivRem, nextPc := 28, aluResult := 18446744073709551615, effectiveAddr := none, writesRd := true, rd := 15, rdAfter := 18446744073709551615, isFirstInSequence := false, virtualSequenceRemaining := (some 0), isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 24, stepIndex := 7, sequenceIndex := 0, fetchPc := 28, fetchedWord := 48691259, opcode := .remuw, traceOpcode := none, traceVirtualOpcode := (some .advice), family := .unsignedDivRem, nextPc := 28, aluResult := 4294967295, effectiveAddr := none, writesRd := true, rd := 40, rdAfter := 4294967295, isFirstInSequence := true, virtualSequenceRemaining := (some 3), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 25, stepIndex := 7, sequenceIndex := 1, fetchPc := 28, fetchedWord := 48691259, opcode := .remuw, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .unsignedDivRem, nextPc := 28, aluResult := 0, effectiveAddr := none, writesRd := true, rd := 41, rdAfter := 0, isFirstInSequence := false, virtualSequenceRemaining := (some 2), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 26, stepIndex := 7, sequenceIndex := 2, fetchPc := 28, fetchedWord := 48691259, opcode := .remuw, traceOpcode := (some .sub), traceVirtualOpcode := none, family := .unsignedDivRem, nextPc := 28, aluResult := 18446744071562067969, effectiveAddr := none, writesRd := true, rd := 16, rdAfter := 18446744071562067969, isFirstInSequence := false, virtualSequenceRemaining := (some 1), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 27, stepIndex := 7, sequenceIndex := 3, fetchPc := 28, fetchedWord := 48691259, opcode := .remuw, traceOpcode := none, traceVirtualOpcode := (some .signExtendWord), family := .unsignedDivRem, nextPc := 32, aluResult := 18446744071562067969, effectiveAddr := none, writesRd := true, rd := 16, rdAfter := 18446744071562067969, isFirstInSequence := false, virtualSequenceRemaining := (some 0), isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 28, stepIndex := 8, sequenceIndex := 0, fetchPc := 32, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 36, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }]

def stage1 : Stage1ProofBundleView :=
  {
    semInputs := stage1SemInputs
    , rowBindings := stage1RowBindings
    , bytecodeDigest := (bytes [27, 40, 29, 44, 95, 89, 204, 2, 96, 79, 248, 255, 210, 152, 239, 238, 184, 141, 7, 122, 112, 40, 114, 8, 157, 15, 132, 47, 221, 92, 138, 11])
    , aluDigest := (bytes [48, 6, 86, 28, 167, 228, 172, 226, 147, 18, 247, 154, 67, 141, 103, 97, 221, 140, 83, 189, 173, 193, 82, 80, 44, 128, 66, 141, 224, 147, 91, 146])
    , branchDigest := (bytes [218, 8, 1, 197, 192, 200, 144, 24, 115, 193, 93, 156, 247, 25, 212, 30, 36, 31, 206, 5, 58, 235, 140, 100, 206, 24, 229, 109, 69, 123, 28, 45])
    , semantics := { semInputsDigest := (bytes [242, 208, 14, 11, 31, 194, 165, 128, 4, 236, 86, 100, 116, 197, 55, 213, 162, 162, 235, 251, 24, 149, 117, 186, 217, 128, 6, 160, 146, 217, 183, 4]), rowBindingsDigest := (bytes [5, 142, 128, 241, 169, 112, 225, 3, 82, 126, 145, 48, 105, 35, 172, 135, 103, 122, 13, 10, 207, 112, 106, 118, 44, 65, 7, 244, 30, 176, 249, 149]), sequenceCount := 9, helperRowCount := 20, digest := (bytes [151, 73, 188, 62, 1, 160, 205, 232, 46, 120, 106, 111, 186, 165, 144, 112, 153, 155, 231, 104, 55, 176, 101, 4, 243, 217, 52, 115, 2, 180, 124, 74]) }
    , addressCorrectnessDigest := (bytes [20, 236, 69, 154, 109, 188, 165, 95, 238, 149, 30, 6, 65, 9, 157, 201, 235, 209, 37, 208, 143, 215, 247, 220, 118, 243, 44, 177, 157, 224, 62, 20])
    , linkageDigest := (bytes [92, 122, 202, 18, 114, 57, 238, 180, 39, 197, 65, 213, 91, 46, 79, 63, 32, 214, 197, 62, 152, 234, 212, 149, 224, 112, 200, 236, 237, 25, 1, 240])
    , selectedOpening := { claim := { rowsFamilyDigest := (bytes [5, 142, 128, 241, 169, 112, 225, 3, 82, 126, 145, 48, 105, 35, 172, 135, 103, 122, 13, 10, 207, 112, 106, 118, 44, 65, 7, 244, 30, 176, 249, 149]), rowCount := 29, effectRowCount := 9, commitRowCount := 9, realRowCount := 9, preservesX0Count := 1, firstTraceIndex := 0, effectTraceIndex := 0, commitTraceIndex := 2, lastTraceIndex := 28, mix := 2114760318709056228, points := { first := { id := { object := { familyTag := 1, commitmentDigest := (bytes [5, 142, 128, 241, 169, 112, 225, 3, 82, 126, 145, 48, 105, 35, 172, 135, 103, 122, 13, 10, 207, 112, 106, 118, 44, 65, 7, 244, 30, 176, 249, 149]), layoutVersion := 1, digest := (bytes [236, 205, 119, 230, 169, 185, 111, 143, 182, 162, 107, 147, 29, 145, 254, 144, 75, 109, 120, 184, 178, 35, 222, 104, 46, 99, 200, 135, 129, 129, 227, 227]) }, logicalIndex := 0, digest := (bytes [72, 7, 190, 138, 239, 53, 207, 63, 161, 179, 4, 114, 196, 149, 41, 21, 20, 154, 102, 60, 52, 242, 231, 171, 156, 61, 53, 208, 130, 246, 171, 173]) }, valueDigest := (bytes [86, 210, 77, 166, 239, 97, 247, 154, 89, 157, 124, 119, 70, 95, 109, 92, 93, 84, 85, 162, 191, 56, 45, 246, 5, 114, 34, 126, 233, 212, 154, 243]), digest := (bytes [199, 188, 102, 98, 151, 25, 193, 14, 192, 211, 208, 30, 69, 111, 99, 57, 48, 35, 58, 20, 62, 84, 255, 161, 205, 98, 54, 152, 98, 30, 241, 16]) }, effect := { id := { object := { familyTag := 1, commitmentDigest := (bytes [5, 142, 128, 241, 169, 112, 225, 3, 82, 126, 145, 48, 105, 35, 172, 135, 103, 122, 13, 10, 207, 112, 106, 118, 44, 65, 7, 244, 30, 176, 249, 149]), layoutVersion := 1, digest := (bytes [236, 205, 119, 230, 169, 185, 111, 143, 182, 162, 107, 147, 29, 145, 254, 144, 75, 109, 120, 184, 178, 35, 222, 104, 46, 99, 200, 135, 129, 129, 227, 227]) }, logicalIndex := 0, digest := (bytes [72, 7, 190, 138, 239, 53, 207, 63, 161, 179, 4, 114, 196, 149, 41, 21, 20, 154, 102, 60, 52, 242, 231, 171, 156, 61, 53, 208, 130, 246, 171, 173]) }, valueDigest := (bytes [86, 210, 77, 166, 239, 97, 247, 154, 89, 157, 124, 119, 70, 95, 109, 92, 93, 84, 85, 162, 191, 56, 45, 246, 5, 114, 34, 126, 233, 212, 154, 243]), digest := (bytes [199, 188, 102, 98, 151, 25, 193, 14, 192, 211, 208, 30, 69, 111, 99, 57, 48, 35, 58, 20, 62, 84, 255, 161, 205, 98, 54, 152, 98, 30, 241, 16]) }, commit := { id := { object := { familyTag := 1, commitmentDigest := (bytes [5, 142, 128, 241, 169, 112, 225, 3, 82, 126, 145, 48, 105, 35, 172, 135, 103, 122, 13, 10, 207, 112, 106, 118, 44, 65, 7, 244, 30, 176, 249, 149]), layoutVersion := 1, digest := (bytes [236, 205, 119, 230, 169, 185, 111, 143, 182, 162, 107, 147, 29, 145, 254, 144, 75, 109, 120, 184, 178, 35, 222, 104, 46, 99, 200, 135, 129, 129, 227, 227]) }, logicalIndex := 2, digest := (bytes [103, 215, 176, 180, 9, 163, 190, 120, 169, 78, 153, 57, 16, 186, 173, 170, 125, 41, 6, 214, 123, 180, 84, 205, 108, 196, 229, 123, 170, 5, 114, 146]) }, valueDigest := (bytes [214, 170, 245, 194, 118, 150, 118, 240, 132, 181, 177, 211, 22, 136, 191, 183, 104, 133, 213, 44, 202, 228, 15, 27, 176, 69, 78, 213, 18, 3, 218, 116]), digest := (bytes [82, 156, 19, 119, 241, 42, 30, 220, 203, 13, 68, 97, 143, 188, 67, 155, 226, 228, 172, 185, 196, 130, 242, 150, 142, 126, 22, 245, 17, 197, 74, 33]) }, last := { id := { object := { familyTag := 1, commitmentDigest := (bytes [5, 142, 128, 241, 169, 112, 225, 3, 82, 126, 145, 48, 105, 35, 172, 135, 103, 122, 13, 10, 207, 112, 106, 118, 44, 65, 7, 244, 30, 176, 249, 149]), layoutVersion := 1, digest := (bytes [236, 205, 119, 230, 169, 185, 111, 143, 182, 162, 107, 147, 29, 145, 254, 144, 75, 109, 120, 184, 178, 35, 222, 104, 46, 99, 200, 135, 129, 129, 227, 227]) }, logicalIndex := 28, digest := (bytes [27, 201, 7, 70, 11, 41, 104, 252, 15, 170, 216, 104, 159, 241, 222, 243, 22, 192, 162, 191, 114, 165, 226, 172, 147, 246, 71, 115, 125, 143, 213, 233]) }, valueDigest := (bytes [117, 2, 130, 217, 186, 127, 114, 150, 180, 34, 16, 174, 228, 51, 84, 94, 116, 45, 197, 54, 146, 14, 152, 153, 25, 241, 178, 19, 154, 39, 120, 101]), digest := (bytes [108, 164, 124, 229, 191, 246, 21, 228, 99, 201, 13, 229, 116, 131, 143, 154, 214, 42, 143, 82, 243, 14, 89, 122, 117, 147, 54, 149, 230, 128, 96, 240]) } }, digest := (bytes [155, 116, 32, 24, 173, 79, 148, 240, 100, 65, 236, 185, 206, 34, 198, 229, 176, 208, 194, 8, 122, 49, 31, 30, 231, 214, 148, 84, 68, 205, 188, 100]) }, packaged := { statementDigest := (bytes [39, 18, 202, 103, 242, 130, 126, 228, 122, 201, 162, 83, 70, 190, 248, 74, 234, 38, 69, 249, 69, 40, 57, 79, 145, 108, 129, 67, 196, 48, 88, 34]), proofDigest := (bytes [130, 227, 236, 146, 73, 254, 23, 190, 137, 140, 13, 113, 246, 142, 11, 10, 23, 99, 49, 181, 218, 32, 175, 15, 158, 179, 129, 169, 193, 83, 22, 226]) }, digest := (bytes [84, 206, 142, 168, 93, 56, 75, 141, 229, 55, 180, 100, 199, 16, 42, 116, 200, 87, 88, 19, 121, 131, 122, 152, 187, 79, 10, 207, 157, 128, 75, 64]) }
    , digest := (bytes [84, 40, 244, 250, 230, 63, 133, 195, 131, 46, 82, 27, 63, 171, 190, 101, 209, 2, 118, 245, 181, 25, 172, 123, 147, 98, 123, 38, 15, 236, 242, 210])
  }

def stage2RegisterReads : List RegisterReadEventView :=
  [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 1, value := 20 }, { traceIndex := 0, stepIndex := 0, role := .rs2, reg := 2, value := 6 }, { traceIndex := 1, stepIndex := 0, role := .rs1, reg := 5, value := 3 }, { traceIndex := 1, stepIndex := 0, role := .rs2, reg := 2, value := 6 }, { traceIndex := 2, stepIndex := 0, role := .rs1, reg := 1, value := 20 }, { traceIndex := 2, stepIndex := 0, role := .rs2, reg := 40, value := 18 }, { traceIndex := 3, stepIndex := 1, role := .rs1, reg := 1, value := 20 }, { traceIndex := 3, stepIndex := 1, role := .rs2, reg := 2, value := 6 }, { traceIndex := 4, stepIndex := 1, role := .rs1, reg := 40, value := 3 }, { traceIndex := 4, stepIndex := 1, role := .rs2, reg := 2, value := 6 }, { traceIndex := 5, stepIndex := 1, role := .rs1, reg := 1, value := 20 }, { traceIndex := 5, stepIndex := 1, role := .rs2, reg := 41, value := 18 }, { traceIndex := 6, stepIndex := 2, role := .rs1, reg := 3, value := 18446744073709551615 }, { traceIndex := 6, stepIndex := 2, role := .rs2, reg := 4, value := 3 }, { traceIndex := 7, stepIndex := 2, role := .rs1, reg := 7, value := 1431655765 }, { traceIndex := 7, stepIndex := 2, role := .rs2, reg := 4, value := 3 }, { traceIndex := 8, stepIndex := 2, role := .rs1, reg := 3, value := 18446744073709551615 }, { traceIndex := 8, stepIndex := 2, role := .rs2, reg := 40, value := 4294967295 }, { traceIndex := 9, stepIndex := 2, role := .rs1, reg := 7, value := 1431655765 }, { traceIndex := 10, stepIndex := 3, role := .rs1, reg := 3, value := 18446744073709551615 }, { traceIndex := 10, stepIndex := 3, role := .rs2, reg := 4, value := 3 }, { traceIndex := 11, stepIndex := 3, role := .rs1, reg := 40, value := 1431655765 }, { traceIndex := 11, stepIndex := 3, role := .rs2, reg := 4, value := 3 }, { traceIndex := 12, stepIndex := 3, role := .rs1, reg := 3, value := 18446744073709551615 }, { traceIndex := 12, stepIndex := 3, role := .rs2, reg := 41, value := 4294967295 }, { traceIndex := 13, stepIndex := 3, role := .rs1, reg := 8, value := 18446744069414584320 }, { traceIndex := 14, stepIndex := 4, role := .rs1, reg := 9, value := 9 }, { traceIndex := 14, stepIndex := 4, role := .rs2, reg := 10, value := 0 }, { traceIndex := 15, stepIndex := 4, role := .rs1, reg := 11, value := 18446744073709551615 }, { traceIndex := 15, stepIndex := 4, role := .rs2, reg := 10, value := 0 }, { traceIndex := 16, stepIndex := 4, role := .rs1, reg := 9, value := 9 }, { traceIndex := 16, stepIndex := 4, role := .rs2, reg := 40, value := 0 }, { traceIndex := 17, stepIndex := 5, role := .rs1, reg := 9, value := 9 }, { traceIndex := 17, stepIndex := 5, role := .rs2, reg := 10, value := 0 }, { traceIndex := 18, stepIndex := 5, role := .rs1, reg := 40, value := 18446744073709551615 }, { traceIndex := 18, stepIndex := 5, role := .rs2, reg := 10, value := 0 }, { traceIndex := 19, stepIndex := 5, role := .rs1, reg := 9, value := 9 }, { traceIndex := 19, stepIndex := 5, role := .rs2, reg := 41, value := 0 }, { traceIndex := 20, stepIndex := 6, role := .rs1, reg := 13, value := 18446744071562067969 }, { traceIndex := 20, stepIndex := 6, role := .rs2, reg := 14, value := 0 }, { traceIndex := 21, stepIndex := 6, role := .rs1, reg := 15, value := 4294967295 }, { traceIndex := 21, stepIndex := 6, role := .rs2, reg := 14, value := 0 }, { traceIndex := 22, stepIndex := 6, role := .rs1, reg := 13, value := 18446744071562067969 }, { traceIndex := 22, stepIndex := 6, role := .rs2, reg := 40, value := 0 }, { traceIndex := 23, stepIndex := 6, role := .rs1, reg := 15, value := 4294967295 }, { traceIndex := 24, stepIndex := 7, role := .rs1, reg := 13, value := 18446744071562067969 }, { traceIndex := 24, stepIndex := 7, role := .rs2, reg := 14, value := 0 }, { traceIndex := 25, stepIndex := 7, role := .rs1, reg := 40, value := 4294967295 }, { traceIndex := 25, stepIndex := 7, role := .rs2, reg := 14, value := 0 }, { traceIndex := 26, stepIndex := 7, role := .rs1, reg := 13, value := 18446744071562067969 }, { traceIndex := 26, stepIndex := 7, role := .rs2, reg := 41, value := 0 }, { traceIndex := 27, stepIndex := 7, role := .rs1, reg := 16, value := 18446744071562067969 }]

def stage2RegisterWrites : List RegisterWriteEventView :=
  [{ traceIndex := 0, stepIndex := 0, reg := 5, previous := 0, next := 3 }, { traceIndex := 1, stepIndex := 0, reg := 40, previous := 0, next := 18 }, { traceIndex := 2, stepIndex := 0, reg := 41, previous := 0, next := 2 }, { traceIndex := 3, stepIndex := 1, reg := 40, previous := 0, next := 3 }, { traceIndex := 4, stepIndex := 1, reg := 41, previous := 0, next := 18 }, { traceIndex := 5, stepIndex := 1, reg := 6, previous := 0, next := 2 }, { traceIndex := 6, stepIndex := 2, reg := 7, previous := 0, next := 1431655765 }, { traceIndex := 7, stepIndex := 2, reg := 40, previous := 0, next := 4294967295 }, { traceIndex := 8, stepIndex := 2, reg := 41, previous := 0, next := 18446744069414584320 }, { traceIndex := 9, stepIndex := 2, reg := 7, previous := 1431655765, next := 1431655765 }, { traceIndex := 10, stepIndex := 3, reg := 40, previous := 0, next := 1431655765 }, { traceIndex := 11, stepIndex := 3, reg := 41, previous := 0, next := 4294967295 }, { traceIndex := 12, stepIndex := 3, reg := 8, previous := 0, next := 18446744069414584320 }, { traceIndex := 13, stepIndex := 3, reg := 8, previous := 18446744069414584320, next := 0 }, { traceIndex := 14, stepIndex := 4, reg := 11, previous := 0, next := 18446744073709551615 }, { traceIndex := 15, stepIndex := 4, reg := 40, previous := 0, next := 0 }, { traceIndex := 16, stepIndex := 4, reg := 41, previous := 0, next := 9 }, { traceIndex := 17, stepIndex := 5, reg := 40, previous := 0, next := 18446744073709551615 }, { traceIndex := 18, stepIndex := 5, reg := 41, previous := 0, next := 0 }, { traceIndex := 19, stepIndex := 5, reg := 12, previous := 0, next := 9 }, { traceIndex := 20, stepIndex := 6, reg := 15, previous := 0, next := 4294967295 }, { traceIndex := 21, stepIndex := 6, reg := 40, previous := 0, next := 0 }, { traceIndex := 22, stepIndex := 6, reg := 41, previous := 0, next := 18446744071562067969 }, { traceIndex := 23, stepIndex := 6, reg := 15, previous := 4294967295, next := 18446744073709551615 }, { traceIndex := 24, stepIndex := 7, reg := 40, previous := 0, next := 4294967295 }, { traceIndex := 25, stepIndex := 7, reg := 41, previous := 0, next := 0 }, { traceIndex := 26, stepIndex := 7, reg := 16, previous := 0, next := 18446744071562067969 }, { traceIndex := 27, stepIndex := 7, reg := 16, previous := 18446744071562067969, next := 18446744071562067969 }]

def stage2RamEvents : List RamEventView :=
  []

def stage2TwistLinks : List TwistLinkEventView :=
  [{ traceIndex := 0, stepIndex := 0, family := .unsignedDivRem, routedWriteValue := (some 3), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 0, family := .unsignedDivRem, routedWriteValue := (some 18), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 0, family := .unsignedDivRem, routedWriteValue := (some 2), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 1, family := .unsignedDivRem, routedWriteValue := (some 3), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 4, stepIndex := 1, family := .unsignedDivRem, routedWriteValue := (some 18), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 5, stepIndex := 1, family := .unsignedDivRem, routedWriteValue := (some 2), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 6, stepIndex := 2, family := .unsignedDivRem, routedWriteValue := (some 1431655765), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 7, stepIndex := 2, family := .unsignedDivRem, routedWriteValue := (some 4294967295), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 8, stepIndex := 2, family := .unsignedDivRem, routedWriteValue := (some 18446744069414584320), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 9, stepIndex := 2, family := .unsignedDivRem, routedWriteValue := (some 1431655765), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 10, stepIndex := 3, family := .unsignedDivRem, routedWriteValue := (some 1431655765), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 11, stepIndex := 3, family := .unsignedDivRem, routedWriteValue := (some 4294967295), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 12, stepIndex := 3, family := .unsignedDivRem, routedWriteValue := (some 18446744069414584320), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 13, stepIndex := 3, family := .unsignedDivRem, routedWriteValue := (some 0), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 14, stepIndex := 4, family := .unsignedDivRem, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 15, stepIndex := 4, family := .unsignedDivRem, routedWriteValue := (some 0), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 16, stepIndex := 4, family := .unsignedDivRem, routedWriteValue := (some 9), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 17, stepIndex := 5, family := .unsignedDivRem, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 18, stepIndex := 5, family := .unsignedDivRem, routedWriteValue := (some 0), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 19, stepIndex := 5, family := .unsignedDivRem, routedWriteValue := (some 9), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 20, stepIndex := 6, family := .unsignedDivRem, routedWriteValue := (some 4294967295), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 21, stepIndex := 6, family := .unsignedDivRem, routedWriteValue := (some 0), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 22, stepIndex := 6, family := .unsignedDivRem, routedWriteValue := (some 18446744071562067969), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 23, stepIndex := 6, family := .unsignedDivRem, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 24, stepIndex := 7, family := .unsignedDivRem, routedWriteValue := (some 4294967295), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 25, stepIndex := 7, family := .unsignedDivRem, routedWriteValue := (some 0), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 26, stepIndex := 7, family := .unsignedDivRem, routedWriteValue := (some 18446744071562067969), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 27, stepIndex := 7, family := .unsignedDivRem, routedWriteValue := (some 18446744071562067969), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 28, stepIndex := 8, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]

def stage2 : Stage2ProofBundleView :=
  {
    registerReads := stage2RegisterReads
    , registerWrites := stage2RegisterWrites
    , ramEvents := stage2RamEvents
    , registerDigest := (bytes [84, 43, 214, 38, 79, 30, 178, 48, 237, 169, 193, 4, 174, 251, 21, 14, 109, 47, 175, 131, 9, 151, 213, 145, 55, 26, 118, 130, 17, 108, 233, 217])
    , ramDigest := (bytes [209, 217, 105, 43, 209, 229, 156, 61, 92, 164, 94, 232, 52, 214, 73, 229, 72, 188, 139, 122, 165, 123, 201, 212, 205, 15, 247, 197, 165, 154, 109, 246])
    , temporal := { twistLinks := stage2TwistLinks, registerTimelineDigest := (bytes [13, 167, 150, 149, 29, 155, 131, 202, 247, 243, 166, 224, 80, 203, 89, 49, 4, 130, 243, 197, 219, 52, 27, 175, 19, 94, 105, 181, 226, 82, 212, 0]), ramTimelineDigest := (bytes [8, 117, 17, 140, 128, 180, 240, 140, 250, 181, 90, 134, 147, 17, 197, 122, 220, 8, 66, 15, 193, 254, 11, 122, 115, 210, 233, 239, 55, 132, 31, 228]), twistLinksDigest := (bytes [246, 91, 25, 203, 128, 244, 236, 184, 54, 33, 98, 81, 69, 144, 61, 149, 155, 172, 168, 68, 36, 132, 141, 228, 142, 15, 40, 217, 248, 251, 97, 173]), digest := (bytes [195, 152, 255, 192, 176, 27, 136, 196, 249, 38, 175, 31, 110, 44, 158, 128, 23, 103, 151, 52, 56, 71, 124, 144, 217, 67, 251, 124, 11, 175, 215, 69]) }
    , semantics := { registerReadsFamilyDigest := (bytes [118, 232, 63, 89, 183, 157, 191, 52, 127, 120, 119, 53, 183, 36, 52, 182, 144, 179, 24, 167, 158, 84, 98, 241, 252, 101, 0, 75, 152, 198, 212, 112]), registerWritesFamilyDigest := (bytes [47, 191, 144, 116, 50, 195, 195, 111, 170, 185, 81, 175, 247, 107, 44, 122, 103, 160, 224, 252, 179, 180, 48, 17, 47, 68, 97, 83, 241, 83, 63, 184]), ramEventsFamilyDigest := (bytes [85, 17, 108, 38, 84, 5, 109, 213, 145, 137, 203, 96, 117, 127, 130, 193, 117, 29, 27, 219, 228, 58, 7, 214, 144, 155, 66, 38, 127, 8, 241, 95]), twistLinksFamilyDigest := (bytes [238, 28, 69, 147, 210, 95, 14, 101, 37, 142, 215, 250, 83, 73, 114, 171, 159, 247, 22, 75, 134, 99, 140, 89, 68, 217, 145, 62, 222, 173, 164, 12]), rowCount := 29, registerEventCount := 80, ramEventCount := 0, digest := (bytes [71, 165, 103, 60, 176, 119, 41, 187, 9, 96, 98, 141, 232, 143, 131, 238, 73, 116, 248, 225, 225, 131, 8, 236, 116, 166, 89, 24, 117, 165, 214, 1]) }
    , linkageDigest := (bytes [150, 72, 141, 50, 0, 199, 106, 155, 164, 163, 229, 146, 16, 253, 84, 213, 139, 243, 4, 159, 78, 69, 197, 70, 57, 86, 55, 50, 25, 227, 32, 240])
    , selectedOpening := { claim := { registerReadsFamilyDigest := (bytes [118, 232, 63, 89, 183, 157, 191, 52, 127, 120, 119, 53, 183, 36, 52, 182, 144, 179, 24, 167, 158, 84, 98, 241, 252, 101, 0, 75, 152, 198, 212, 112]), registerWritesFamilyDigest := (bytes [47, 191, 144, 116, 50, 195, 195, 111, 170, 185, 81, 175, 247, 107, 44, 122, 103, 160, 224, 252, 179, 180, 48, 17, 47, 68, 97, 83, 241, 83, 63, 184]), ramEventsFamilyDigest := (bytes [85, 17, 108, 38, 84, 5, 109, 213, 145, 137, 203, 96, 117, 127, 130, 193, 117, 29, 27, 219, 228, 58, 7, 214, 144, 155, 66, 38, 127, 8, 241, 95]), twistLinksFamilyDigest := (bytes [238, 28, 69, 147, 210, 95, 14, 101, 37, 142, 215, 250, 83, 73, 114, 171, 159, 247, 22, 75, 134, 99, 140, 89, 68, 217, 145, 62, 222, 173, 164, 12]), registerReadCount := 52, registerWriteCount := 28, ramEventCount := 0, twistLinkCount := 29, ramReadCount := 0, ramWriteCount := 0, regMix := 9623998399562321865, ramMix := 8802110342888801535, points := { firstRead := (some { id := { object := { familyTag := 2, commitmentDigest := (bytes [118, 232, 63, 89, 183, 157, 191, 52, 127, 120, 119, 53, 183, 36, 52, 182, 144, 179, 24, 167, 158, 84, 98, 241, 252, 101, 0, 75, 152, 198, 212, 112]), layoutVersion := 1, digest := (bytes [186, 255, 209, 180, 225, 47, 209, 29, 61, 164, 90, 206, 77, 109, 160, 92, 165, 171, 251, 31, 181, 237, 145, 237, 207, 185, 189, 39, 185, 72, 192, 81]) }, logicalIndex := 0, digest := (bytes [88, 245, 0, 204, 90, 17, 40, 96, 223, 238, 172, 116, 226, 136, 68, 186, 122, 41, 170, 17, 85, 53, 201, 236, 21, 222, 57, 69, 226, 124, 215, 11]) }, valueDigest := (bytes [60, 203, 96, 243, 192, 147, 12, 107, 3, 223, 109, 79, 83, 117, 243, 34, 120, 207, 65, 86, 18, 66, 32, 189, 51, 70, 92, 17, 113, 246, 70, 226]), digest := (bytes [163, 156, 168, 127, 77, 169, 253, 232, 248, 191, 62, 143, 246, 11, 49, 42, 127, 105, 215, 220, 220, 30, 48, 63, 29, 3, 255, 246, 156, 191, 153, 253]) }), lastRead := (some { id := { object := { familyTag := 2, commitmentDigest := (bytes [118, 232, 63, 89, 183, 157, 191, 52, 127, 120, 119, 53, 183, 36, 52, 182, 144, 179, 24, 167, 158, 84, 98, 241, 252, 101, 0, 75, 152, 198, 212, 112]), layoutVersion := 1, digest := (bytes [186, 255, 209, 180, 225, 47, 209, 29, 61, 164, 90, 206, 77, 109, 160, 92, 165, 171, 251, 31, 181, 237, 145, 237, 207, 185, 189, 39, 185, 72, 192, 81]) }, logicalIndex := 51, digest := (bytes [137, 64, 194, 43, 193, 214, 213, 44, 237, 199, 239, 204, 213, 51, 172, 161, 234, 6, 167, 219, 195, 104, 161, 137, 89, 96, 136, 109, 214, 219, 225, 99]) }, valueDigest := (bytes [186, 254, 159, 247, 24, 97, 120, 49, 147, 91, 110, 228, 193, 6, 12, 83, 2, 57, 172, 160, 44, 254, 77, 2, 14, 83, 236, 142, 128, 106, 62, 128]), digest := (bytes [22, 254, 211, 23, 195, 58, 12, 108, 240, 146, 15, 60, 136, 28, 243, 181, 197, 152, 74, 245, 203, 222, 95, 52, 247, 191, 84, 58, 58, 99, 89, 122]) }), firstWrite := (some { id := { object := { familyTag := 3, commitmentDigest := (bytes [47, 191, 144, 116, 50, 195, 195, 111, 170, 185, 81, 175, 247, 107, 44, 122, 103, 160, 224, 252, 179, 180, 48, 17, 47, 68, 97, 83, 241, 83, 63, 184]), layoutVersion := 1, digest := (bytes [39, 222, 241, 115, 220, 10, 66, 73, 163, 13, 110, 71, 120, 33, 35, 45, 117, 116, 90, 54, 211, 195, 136, 130, 5, 58, 138, 48, 139, 96, 89, 76]) }, logicalIndex := 0, digest := (bytes [46, 80, 161, 81, 100, 135, 177, 246, 248, 158, 38, 223, 116, 39, 248, 14, 86, 154, 208, 117, 255, 234, 248, 247, 75, 176, 63, 156, 221, 236, 51, 17]) }, valueDigest := (bytes [19, 209, 14, 20, 152, 127, 237, 220, 245, 195, 136, 31, 202, 161, 9, 12, 217, 77, 63, 179, 19, 144, 238, 246, 208, 219, 185, 15, 73, 85, 223, 35]), digest := (bytes [199, 91, 110, 4, 64, 241, 66, 173, 139, 107, 185, 230, 111, 34, 225, 71, 78, 230, 50, 157, 18, 191, 216, 232, 127, 81, 0, 77, 25, 115, 158, 162]) }), lastWrite := (some { id := { object := { familyTag := 3, commitmentDigest := (bytes [47, 191, 144, 116, 50, 195, 195, 111, 170, 185, 81, 175, 247, 107, 44, 122, 103, 160, 224, 252, 179, 180, 48, 17, 47, 68, 97, 83, 241, 83, 63, 184]), layoutVersion := 1, digest := (bytes [39, 222, 241, 115, 220, 10, 66, 73, 163, 13, 110, 71, 120, 33, 35, 45, 117, 116, 90, 54, 211, 195, 136, 130, 5, 58, 138, 48, 139, 96, 89, 76]) }, logicalIndex := 27, digest := (bytes [141, 100, 183, 106, 213, 69, 175, 84, 153, 6, 163, 110, 157, 242, 203, 76, 65, 239, 34, 69, 183, 217, 136, 92, 245, 117, 155, 92, 192, 5, 255, 231]) }, valueDigest := (bytes [80, 109, 179, 80, 76, 153, 162, 9, 19, 164, 2, 119, 70, 6, 163, 242, 50, 120, 181, 158, 223, 35, 21, 175, 215, 5, 72, 153, 209, 105, 222, 173]), digest := (bytes [84, 203, 193, 179, 196, 86, 58, 144, 157, 115, 204, 177, 60, 30, 183, 46, 72, 46, 129, 111, 45, 176, 9, 44, 13, 62, 75, 252, 201, 134, 68, 116]) }), firstRam := none, lastRam := none, firstTwist := (some { id := { object := { familyTag := 5, commitmentDigest := (bytes [238, 28, 69, 147, 210, 95, 14, 101, 37, 142, 215, 250, 83, 73, 114, 171, 159, 247, 22, 75, 134, 99, 140, 89, 68, 217, 145, 62, 222, 173, 164, 12]), layoutVersion := 1, digest := (bytes [60, 97, 246, 12, 214, 46, 36, 71, 155, 156, 56, 150, 137, 218, 94, 201, 224, 215, 95, 183, 162, 217, 155, 206, 199, 78, 82, 129, 169, 79, 103, 2]) }, logicalIndex := 0, digest := (bytes [162, 93, 132, 51, 238, 51, 37, 118, 92, 130, 168, 54, 68, 243, 247, 247, 189, 108, 200, 218, 130, 124, 206, 135, 16, 100, 75, 81, 61, 81, 151, 38]) }, valueDigest := (bytes [144, 56, 168, 95, 163, 38, 86, 141, 108, 221, 1, 187, 174, 228, 208, 87, 252, 14, 54, 246, 139, 154, 126, 213, 143, 46, 251, 41, 252, 99, 88, 146]), digest := (bytes [133, 222, 48, 116, 112, 205, 147, 22, 204, 103, 154, 41, 94, 160, 5, 105, 147, 188, 198, 212, 243, 181, 91, 135, 53, 249, 33, 245, 18, 128, 119, 31]) }), lastTwist := (some { id := { object := { familyTag := 5, commitmentDigest := (bytes [238, 28, 69, 147, 210, 95, 14, 101, 37, 142, 215, 250, 83, 73, 114, 171, 159, 247, 22, 75, 134, 99, 140, 89, 68, 217, 145, 62, 222, 173, 164, 12]), layoutVersion := 1, digest := (bytes [60, 97, 246, 12, 214, 46, 36, 71, 155, 156, 56, 150, 137, 218, 94, 201, 224, 215, 95, 183, 162, 217, 155, 206, 199, 78, 82, 129, 169, 79, 103, 2]) }, logicalIndex := 28, digest := (bytes [55, 230, 248, 200, 18, 245, 144, 218, 240, 119, 254, 110, 141, 68, 116, 198, 63, 42, 140, 21, 223, 108, 225, 240, 113, 76, 37, 101, 253, 139, 137, 130]) }, valueDigest := (bytes [40, 145, 47, 83, 13, 153, 200, 154, 8, 166, 104, 124, 150, 110, 35, 90, 8, 208, 87, 54, 106, 11, 22, 182, 195, 111, 37, 1, 150, 219, 233, 133]), digest := (bytes [140, 139, 221, 123, 54, 37, 4, 138, 143, 252, 129, 119, 88, 0, 134, 42, 80, 82, 135, 241, 126, 4, 64, 61, 56, 126, 22, 166, 10, 211, 113, 251]) }) }, digest := (bytes [169, 99, 140, 94, 38, 142, 251, 159, 186, 238, 126, 184, 234, 245, 237, 39, 215, 177, 36, 194, 61, 60, 91, 167, 207, 202, 65, 64, 99, 117, 84, 179]) }, packaged := { statementDigest := (bytes [200, 101, 32, 148, 215, 4, 108, 110, 200, 166, 3, 203, 35, 243, 68, 95, 127, 244, 119, 142, 134, 53, 82, 114, 118, 141, 54, 137, 54, 173, 87, 152]), proofDigest := (bytes [103, 42, 9, 83, 143, 23, 184, 197, 228, 195, 234, 10, 1, 110, 238, 24, 63, 25, 136, 255, 207, 45, 147, 251, 52, 183, 188, 93, 212, 83, 132, 225]) }, digest := (bytes [233, 244, 5, 85, 164, 65, 201, 245, 154, 6, 245, 55, 160, 133, 24, 0, 98, 0, 72, 170, 44, 114, 128, 216, 10, 232, 185, 75, 115, 11, 21, 57]) }
    , digest := (bytes [207, 76, 151, 40, 68, 199, 101, 173, 39, 47, 89, 181, 86, 79, 203, 128, 205, 112, 19, 153, 214, 174, 78, 161, 165, 123, 103, 160, 239, 71, 186, 136])
  }

def stage3Continuity : List ContinuityEventView :=
  [{ stepIndex := 0, pc := 0, nextPc := 4, successorPc := (some 4), finalStep := false, continuityHolds := true }, { stepIndex := 1, pc := 4, nextPc := 8, successorPc := (some 8), finalStep := false, continuityHolds := true }, { stepIndex := 2, pc := 8, nextPc := 12, successorPc := (some 12), finalStep := false, continuityHolds := true }, { stepIndex := 3, pc := 12, nextPc := 16, successorPc := (some 16), finalStep := false, continuityHolds := true }, { stepIndex := 4, pc := 16, nextPc := 20, successorPc := (some 20), finalStep := false, continuityHolds := true }, { stepIndex := 5, pc := 20, nextPc := 24, successorPc := (some 24), finalStep := false, continuityHolds := true }, { stepIndex := 6, pc := 24, nextPc := 28, successorPc := (some 28), finalStep := false, continuityHolds := true }, { stepIndex := 7, pc := 28, nextPc := 32, successorPc := (some 32), finalStep := false, continuityHolds := true }, { stepIndex := 8, pc := 32, nextPc := 36, successorPc := none, finalStep := true, continuityHolds := true }]

def stage3 : Stage3ProofBundleView :=
  {
    continuity := stage3Continuity
    , halted := true
    , bridgeDigest := (bytes [243, 92, 69, 219, 78, 54, 140, 108, 176, 70, 97, 74, 146, 123, 130, 133, 101, 143, 95, 112, 164, 43, 212, 254, 117, 159, 139, 83, 238, 74, 161, 237])
    , semantics := { continuityDigest := (bytes [75, 208, 112, 42, 251, 249, 181, 184, 126, 24, 178, 201, 99, 153, 96, 232, 72, 5, 20, 78, 255, 28, 71, 137, 247, 36, 44, 214, 6, 191, 13, 60]), rootSemanticRowsDigest := (bytes [210, 210, 168, 160, 209, 151, 81, 112, 167, 212, 124, 1, 116, 109, 147, 236, 155, 192, 231, 25, 27, 147, 69, 192, 118, 170, 69, 253, 3, 28, 48, 8]), rowChunkRoutesDigest := (bytes [157, 56, 49, 88, 58, 136, 76, 107, 255, 120, 158, 198, 111, 202, 189, 3, 228, 179, 63, 132, 138, 132, 211, 15, 30, 108, 63, 231, 4, 55, 240, 227]), preparedStepBindingsDigest := (bytes [122, 127, 230, 234, 20, 88, 54, 132, 38, 4, 241, 103, 237, 27, 91, 231, 123, 166, 255, 110, 210, 175, 85, 2, 174, 249, 69, 66, 249, 6, 108, 229]), stage2TemporalDigest := (bytes [195, 152, 255, 192, 176, 27, 136, 196, 249, 38, 175, 31, 110, 44, 158, 128, 23, 103, 151, 52, 56, 71, 124, 144, 217, 67, 251, 124, 11, 175, 215, 69]), initialPc := 0, finalPc := 36, realRowCount := 9, firstRealStepIndex := 0, lastRealStepIndex := 8, digest := (bytes [243, 239, 35, 61, 103, 231, 77, 91, 40, 229, 166, 118, 83, 233, 33, 208, 140, 96, 68, 173, 102, 218, 100, 207, 213, 43, 87, 72, 215, 101, 124, 198]) }
    , linkageDigest := (bytes [80, 62, 113, 173, 106, 197, 118, 88, 179, 7, 225, 32, 107, 62, 77, 190, 201, 81, 64, 127, 54, 137, 206, 6, 185, 25, 218, 105, 169, 75, 37, 12])
    , selectedOpening := { claim := { continuityFamilyDigest := (bytes [59, 125, 58, 22, 102, 80, 138, 22, 105, 90, 21, 115, 179, 235, 126, 216, 240, 238, 10, 161, 63, 80, 97, 187, 94, 88, 79, 98, 225, 147, 49, 78]), continuityCount := 9, finalStepCount := 1, halted := true, allContinuityHold := true, continuityMix := 548968070038829395, points := { firstContinuity := (some { id := { object := { familyTag := 6, commitmentDigest := (bytes [59, 125, 58, 22, 102, 80, 138, 22, 105, 90, 21, 115, 179, 235, 126, 216, 240, 238, 10, 161, 63, 80, 97, 187, 94, 88, 79, 98, 225, 147, 49, 78]), layoutVersion := 1, digest := (bytes [127, 209, 20, 108, 139, 45, 71, 159, 200, 59, 214, 14, 213, 53, 225, 238, 17, 211, 15, 245, 6, 75, 222, 177, 25, 174, 66, 7, 50, 166, 232, 231]) }, logicalIndex := 0, digest := (bytes [88, 221, 104, 248, 17, 230, 94, 48, 174, 1, 254, 246, 71, 234, 70, 79, 224, 223, 155, 103, 92, 40, 11, 12, 159, 68, 192, 221, 74, 12, 24, 94]) }, valueDigest := (bytes [7, 131, 85, 21, 57, 109, 53, 31, 137, 53, 98, 18, 170, 36, 28, 200, 149, 213, 171, 159, 119, 200, 36, 230, 30, 35, 30, 11, 252, 126, 240, 63]), digest := (bytes [2, 118, 36, 122, 181, 243, 191, 39, 254, 42, 47, 251, 150, 61, 68, 187, 160, 145, 151, 150, 245, 51, 238, 49, 102, 167, 210, 235, 85, 198, 172, 250]) }), lastContinuity := (some { id := { object := { familyTag := 6, commitmentDigest := (bytes [59, 125, 58, 22, 102, 80, 138, 22, 105, 90, 21, 115, 179, 235, 126, 216, 240, 238, 10, 161, 63, 80, 97, 187, 94, 88, 79, 98, 225, 147, 49, 78]), layoutVersion := 1, digest := (bytes [127, 209, 20, 108, 139, 45, 71, 159, 200, 59, 214, 14, 213, 53, 225, 238, 17, 211, 15, 245, 6, 75, 222, 177, 25, 174, 66, 7, 50, 166, 232, 231]) }, logicalIndex := 8, digest := (bytes [148, 102, 253, 198, 214, 87, 213, 49, 241, 110, 143, 157, 53, 20, 246, 26, 167, 73, 203, 31, 168, 219, 245, 223, 139, 85, 10, 203, 131, 83, 128, 254]) }, valueDigest := (bytes [23, 136, 225, 13, 183, 210, 9, 190, 149, 62, 176, 243, 205, 247, 62, 86, 45, 117, 83, 25, 171, 227, 173, 0, 30, 203, 141, 206, 77, 117, 200, 54]), digest := (bytes [192, 79, 214, 223, 107, 14, 6, 139, 169, 39, 136, 179, 184, 63, 145, 21, 4, 74, 90, 80, 99, 63, 65, 47, 156, 231, 216, 132, 77, 50, 1, 0]) }) }, digest := (bytes [109, 13, 218, 99, 8, 86, 183, 59, 253, 100, 127, 196, 146, 113, 204, 238, 65, 155, 254, 117, 144, 119, 232, 148, 72, 67, 80, 132, 219, 213, 50, 51]) }, packaged := { statementDigest := (bytes [252, 45, 105, 113, 154, 107, 17, 10, 108, 253, 210, 168, 31, 113, 80, 50, 30, 48, 71, 148, 158, 173, 109, 33, 25, 151, 25, 187, 131, 30, 99, 108]), proofDigest := (bytes [18, 167, 169, 38, 241, 220, 74, 73, 94, 81, 128, 63, 55, 68, 237, 161, 94, 107, 206, 1, 8, 89, 66, 62, 203, 197, 135, 120, 107, 238, 149, 19]) }, digest := (bytes [248, 162, 12, 203, 170, 40, 43, 20, 152, 3, 84, 198, 147, 220, 41, 13, 65, 180, 249, 53, 251, 90, 130, 174, 144, 179, 189, 160, 32, 203, 228, 148]) }
    , digest := (bytes [255, 222, 205, 79, 107, 70, 217, 80, 213, 9, 213, 80, 249, 156, 94, 51, 112, 176, 3, 197, 236, 64, 69, 33, 129, 0, 240, 143, 0, 10, 85, 169])
  }

def rootExecutionExecutionRows : List ExpandedRowView :=
  [{
  traceIndex := 0
  , stepIndex := 0
  , sequenceIndex := 0
  , pc := 0
  , nextPc := 0
  , word := 35705523
  , opcode := .divu
  , traceOpcode := none
  , traceVirtualOpcode := (some .advice)
  , family := .unsignedDivRem
  , rs1 := 1
  , rs1Value := 20
  , rs2 := 2
  , rs2Value := 6
  , rd := 5
  , rdBefore := 0
  , rdAfter := 3
  , imm := 0
  , aluResult := 3
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := true
  , virtualSequenceRemaining := (some 2)
  , isEffectRow := true
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 1
  , stepIndex := 0
  , sequenceIndex := 1
  , pc := 0
  , nextPc := 0
  , word := 35705523
  , opcode := .divu
  , traceOpcode := (some .mul)
  , traceVirtualOpcode := none
  , family := .unsignedDivRem
  , rs1 := 5
  , rs1Value := 3
  , rs2 := 2
  , rs2Value := 6
  , rd := 40
  , rdBefore := 0
  , rdAfter := 18
  , imm := 0
  , aluResult := 18
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
  traceIndex := 2
  , stepIndex := 0
  , sequenceIndex := 2
  , pc := 0
  , nextPc := 4
  , word := 35705523
  , opcode := .divu
  , traceOpcode := (some .sub)
  , traceVirtualOpcode := none
  , family := .unsignedDivRem
  , rs1 := 1
  , rs1Value := 20
  , rs2 := 40
  , rs2Value := 18
  , rd := 41
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
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 0)
  , isEffectRow := false
  , isCommitRow := true
  , isReal := true
}, {
  traceIndex := 3
  , stepIndex := 1
  , sequenceIndex := 0
  , pc := 4
  , nextPc := 4
  , word := 35713843
  , opcode := .remu
  , traceOpcode := none
  , traceVirtualOpcode := (some .advice)
  , family := .unsignedDivRem
  , rs1 := 1
  , rs1Value := 20
  , rs2 := 2
  , rs2Value := 6
  , rd := 40
  , rdBefore := 0
  , rdAfter := 3
  , imm := 0
  , aluResult := 3
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := true
  , virtualSequenceRemaining := (some 2)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 4
  , stepIndex := 1
  , sequenceIndex := 1
  , pc := 4
  , nextPc := 4
  , word := 35713843
  , opcode := .remu
  , traceOpcode := (some .mul)
  , traceVirtualOpcode := none
  , family := .unsignedDivRem
  , rs1 := 40
  , rs1Value := 3
  , rs2 := 2
  , rs2Value := 6
  , rd := 41
  , rdBefore := 0
  , rdAfter := 18
  , imm := 0
  , aluResult := 18
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
  traceIndex := 5
  , stepIndex := 1
  , sequenceIndex := 2
  , pc := 4
  , nextPc := 8
  , word := 35713843
  , opcode := .remu
  , traceOpcode := (some .sub)
  , traceVirtualOpcode := none
  , family := .unsignedDivRem
  , rs1 := 1
  , rs1Value := 20
  , rs2 := 41
  , rs2Value := 18
  , rd := 6
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
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 0)
  , isEffectRow := true
  , isCommitRow := true
  , isReal := true
}, {
  traceIndex := 6
  , stepIndex := 2
  , sequenceIndex := 0
  , pc := 8
  , nextPc := 8
  , word := 37868475
  , opcode := .divuw
  , traceOpcode := none
  , traceVirtualOpcode := (some .advice)
  , family := .unsignedDivRem
  , rs1 := 3
  , rs1Value := 18446744073709551615
  , rs2 := 4
  , rs2Value := 3
  , rd := 7
  , rdBefore := 0
  , rdAfter := 1431655765
  , imm := 0
  , aluResult := 1431655765
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := true
  , virtualSequenceRemaining := (some 3)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 7
  , stepIndex := 2
  , sequenceIndex := 1
  , pc := 8
  , nextPc := 8
  , word := 37868475
  , opcode := .divuw
  , traceOpcode := (some .mul)
  , traceVirtualOpcode := none
  , family := .unsignedDivRem
  , rs1 := 7
  , rs1Value := 1431655765
  , rs2 := 4
  , rs2Value := 3
  , rd := 40
  , rdBefore := 0
  , rdAfter := 4294967295
  , imm := 0
  , aluResult := 4294967295
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
  traceIndex := 8
  , stepIndex := 2
  , sequenceIndex := 2
  , pc := 8
  , nextPc := 8
  , word := 37868475
  , opcode := .divuw
  , traceOpcode := (some .sub)
  , traceVirtualOpcode := none
  , family := .unsignedDivRem
  , rs1 := 3
  , rs1Value := 18446744073709551615
  , rs2 := 40
  , rs2Value := 4294967295
  , rd := 41
  , rdBefore := 0
  , rdAfter := 18446744069414584320
  , imm := 0
  , aluResult := 18446744069414584320
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
  traceIndex := 9
  , stepIndex := 2
  , sequenceIndex := 3
  , pc := 8
  , nextPc := 12
  , word := 37868475
  , opcode := .divuw
  , traceOpcode := none
  , traceVirtualOpcode := (some .signExtendWord)
  , family := .unsignedDivRem
  , rs1 := 7
  , rs1Value := 1431655765
  , rs2 := 0
  , rs2Value := 0
  , rd := 7
  , rdBefore := 1431655765
  , rdAfter := 1431655765
  , imm := 0
  , aluResult := 1431655765
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
  traceIndex := 10
  , stepIndex := 3
  , sequenceIndex := 0
  , pc := 12
  , nextPc := 12
  , word := 37876795
  , opcode := .remuw
  , traceOpcode := none
  , traceVirtualOpcode := (some .advice)
  , family := .unsignedDivRem
  , rs1 := 3
  , rs1Value := 18446744073709551615
  , rs2 := 4
  , rs2Value := 3
  , rd := 40
  , rdBefore := 0
  , rdAfter := 1431655765
  , imm := 0
  , aluResult := 1431655765
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := true
  , virtualSequenceRemaining := (some 3)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 11
  , stepIndex := 3
  , sequenceIndex := 1
  , pc := 12
  , nextPc := 12
  , word := 37876795
  , opcode := .remuw
  , traceOpcode := (some .mul)
  , traceVirtualOpcode := none
  , family := .unsignedDivRem
  , rs1 := 40
  , rs1Value := 1431655765
  , rs2 := 4
  , rs2Value := 3
  , rd := 41
  , rdBefore := 0
  , rdAfter := 4294967295
  , imm := 0
  , aluResult := 4294967295
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
  traceIndex := 12
  , stepIndex := 3
  , sequenceIndex := 2
  , pc := 12
  , nextPc := 12
  , word := 37876795
  , opcode := .remuw
  , traceOpcode := (some .sub)
  , traceVirtualOpcode := none
  , family := .unsignedDivRem
  , rs1 := 3
  , rs1Value := 18446744073709551615
  , rs2 := 41
  , rs2Value := 4294967295
  , rd := 8
  , rdBefore := 0
  , rdAfter := 18446744069414584320
  , imm := 0
  , aluResult := 18446744069414584320
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
  traceIndex := 13
  , stepIndex := 3
  , sequenceIndex := 3
  , pc := 12
  , nextPc := 16
  , word := 37876795
  , opcode := .remuw
  , traceOpcode := none
  , traceVirtualOpcode := (some .signExtendWord)
  , family := .unsignedDivRem
  , rs1 := 8
  , rs1Value := 18446744069414584320
  , rs2 := 0
  , rs2Value := 0
  , rd := 8
  , rdBefore := 18446744069414584320
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
  traceIndex := 14
  , stepIndex := 4
  , sequenceIndex := 0
  , pc := 16
  , nextPc := 16
  , word := 44357043
  , opcode := .divu
  , traceOpcode := none
  , traceVirtualOpcode := (some .advice)
  , family := .unsignedDivRem
  , rs1 := 9
  , rs1Value := 9
  , rs2 := 10
  , rs2Value := 0
  , rd := 11
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
  , virtualSequenceRemaining := (some 2)
  , isEffectRow := true
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 15
  , stepIndex := 4
  , sequenceIndex := 1
  , pc := 16
  , nextPc := 16
  , word := 44357043
  , opcode := .divu
  , traceOpcode := (some .mul)
  , traceVirtualOpcode := none
  , family := .unsignedDivRem
  , rs1 := 11
  , rs1Value := 18446744073709551615
  , rs2 := 10
  , rs2Value := 0
  , rd := 40
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
  , virtualSequenceRemaining := (some 1)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 16
  , stepIndex := 4
  , sequenceIndex := 2
  , pc := 16
  , nextPc := 20
  , word := 44357043
  , opcode := .divu
  , traceOpcode := (some .sub)
  , traceVirtualOpcode := none
  , family := .unsignedDivRem
  , rs1 := 9
  , rs1Value := 9
  , rs2 := 40
  , rs2Value := 0
  , rd := 41
  , rdBefore := 0
  , rdAfter := 9
  , imm := 0
  , aluResult := 9
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 0)
  , isEffectRow := false
  , isCommitRow := true
  , isReal := true
}, {
  traceIndex := 17
  , stepIndex := 5
  , sequenceIndex := 0
  , pc := 20
  , nextPc := 20
  , word := 44365363
  , opcode := .remu
  , traceOpcode := none
  , traceVirtualOpcode := (some .advice)
  , family := .unsignedDivRem
  , rs1 := 9
  , rs1Value := 9
  , rs2 := 10
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
  , virtualSequenceRemaining := (some 2)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 18
  , stepIndex := 5
  , sequenceIndex := 1
  , pc := 20
  , nextPc := 20
  , word := 44365363
  , opcode := .remu
  , traceOpcode := (some .mul)
  , traceVirtualOpcode := none
  , family := .unsignedDivRem
  , rs1 := 40
  , rs1Value := 18446744073709551615
  , rs2 := 10
  , rs2Value := 0
  , rd := 41
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
  , virtualSequenceRemaining := (some 1)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 19
  , stepIndex := 5
  , sequenceIndex := 2
  , pc := 20
  , nextPc := 24
  , word := 44365363
  , opcode := .remu
  , traceOpcode := (some .sub)
  , traceVirtualOpcode := none
  , family := .unsignedDivRem
  , rs1 := 9
  , rs1Value := 9
  , rs2 := 41
  , rs2Value := 0
  , rd := 12
  , rdBefore := 0
  , rdAfter := 9
  , imm := 0
  , aluResult := 9
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
  traceIndex := 20
  , stepIndex := 6
  , sequenceIndex := 0
  , pc := 24
  , nextPc := 24
  , word := 48682939
  , opcode := .divuw
  , traceOpcode := none
  , traceVirtualOpcode := (some .advice)
  , family := .unsignedDivRem
  , rs1 := 13
  , rs1Value := 18446744071562067969
  , rs2 := 14
  , rs2Value := 0
  , rd := 15
  , rdBefore := 0
  , rdAfter := 4294967295
  , imm := 0
  , aluResult := 4294967295
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := true
  , virtualSequenceRemaining := (some 3)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 21
  , stepIndex := 6
  , sequenceIndex := 1
  , pc := 24
  , nextPc := 24
  , word := 48682939
  , opcode := .divuw
  , traceOpcode := (some .mul)
  , traceVirtualOpcode := none
  , family := .unsignedDivRem
  , rs1 := 15
  , rs1Value := 4294967295
  , rs2 := 14
  , rs2Value := 0
  , rd := 40
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
  , virtualSequenceRemaining := (some 2)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 22
  , stepIndex := 6
  , sequenceIndex := 2
  , pc := 24
  , nextPc := 24
  , word := 48682939
  , opcode := .divuw
  , traceOpcode := (some .sub)
  , traceVirtualOpcode := none
  , family := .unsignedDivRem
  , rs1 := 13
  , rs1Value := 18446744071562067969
  , rs2 := 40
  , rs2Value := 0
  , rd := 41
  , rdBefore := 0
  , rdAfter := 18446744071562067969
  , imm := 0
  , aluResult := 18446744071562067969
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
  traceIndex := 23
  , stepIndex := 6
  , sequenceIndex := 3
  , pc := 24
  , nextPc := 28
  , word := 48682939
  , opcode := .divuw
  , traceOpcode := none
  , traceVirtualOpcode := (some .signExtendWord)
  , family := .unsignedDivRem
  , rs1 := 15
  , rs1Value := 4294967295
  , rs2 := 0
  , rs2Value := 0
  , rd := 15
  , rdBefore := 4294967295
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
  traceIndex := 24
  , stepIndex := 7
  , sequenceIndex := 0
  , pc := 28
  , nextPc := 28
  , word := 48691259
  , opcode := .remuw
  , traceOpcode := none
  , traceVirtualOpcode := (some .advice)
  , family := .unsignedDivRem
  , rs1 := 13
  , rs1Value := 18446744071562067969
  , rs2 := 14
  , rs2Value := 0
  , rd := 40
  , rdBefore := 0
  , rdAfter := 4294967295
  , imm := 0
  , aluResult := 4294967295
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := true
  , virtualSequenceRemaining := (some 3)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 25
  , stepIndex := 7
  , sequenceIndex := 1
  , pc := 28
  , nextPc := 28
  , word := 48691259
  , opcode := .remuw
  , traceOpcode := (some .mul)
  , traceVirtualOpcode := none
  , family := .unsignedDivRem
  , rs1 := 40
  , rs1Value := 4294967295
  , rs2 := 14
  , rs2Value := 0
  , rd := 41
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
  , virtualSequenceRemaining := (some 2)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 26
  , stepIndex := 7
  , sequenceIndex := 2
  , pc := 28
  , nextPc := 28
  , word := 48691259
  , opcode := .remuw
  , traceOpcode := (some .sub)
  , traceVirtualOpcode := none
  , family := .unsignedDivRem
  , rs1 := 13
  , rs1Value := 18446744071562067969
  , rs2 := 41
  , rs2Value := 0
  , rd := 16
  , rdBefore := 0
  , rdAfter := 18446744071562067969
  , imm := 0
  , aluResult := 18446744071562067969
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
  traceIndex := 27
  , stepIndex := 7
  , sequenceIndex := 3
  , pc := 28
  , nextPc := 32
  , word := 48691259
  , opcode := .remuw
  , traceOpcode := none
  , traceVirtualOpcode := (some .signExtendWord)
  , family := .unsignedDivRem
  , rs1 := 16
  , rs1Value := 18446744071562067969
  , rs2 := 0
  , rs2Value := 0
  , rd := 16
  , rdBefore := 18446744071562067969
  , rdAfter := 18446744071562067969
  , imm := 0
  , aluResult := 18446744071562067969
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
  traceIndex := 28
  , stepIndex := 8
  , sequenceIndex := 0
  , pc := 32
  , nextPc := 36
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
  [{ traceIndex := 0, values := [1, 0, 0, 0, 0, 20, 0, 6, 0, 3, 0, 0, 0, 3, 0, 4, 0, 0, 0, 0, 0, 0, 0, 5, 1, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], rowDigest := (bytes [15, 203, 82, 147, 182, 107, 150, 168, 159, 107, 204, 115, 170, 200, 12, 67, 125, 81, 225, 219, 175, 26, 58, 39, 55, 35, 134, 130, 62, 126, 3, 37]), digest := (bytes [160, 225, 50, 185, 210, 13, 73, 20, 214, 234, 155, 255, 235, 134, 75, 183, 210, 59, 17, 197, 116, 101, 161, 172, 131, 122, 83, 196, 194, 100, 16, 24]) }, { traceIndex := 1, values := [1, 0, 0, 0, 0, 3, 0, 6, 0, 18, 0, 0, 0, 18, 0, 4, 0, 0, 0, 0, 0, 0, 0, 40, 5, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], rowDigest := (bytes [60, 215, 205, 5, 39, 54, 187, 203, 122, 19, 181, 4, 207, 239, 83, 130, 97, 87, 236, 195, 81, 5, 54, 170, 123, 142, 70, 92, 18, 71, 210, 101]), digest := (bytes [189, 122, 139, 107, 118, 236, 136, 81, 191, 253, 213, 201, 173, 103, 248, 132, 37, 204, 49, 169, 112, 11, 179, 119, 250, 122, 232, 2, 146, 113, 225, 32]) }, { traceIndex := 2, values := [1, 0, 0, 4, 0, 20, 0, 18, 0, 2, 0, 0, 0, 2, 0, 4, 0, 0, 0, 0, 0, 0, 0, 41, 1, 40, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1], rowDigest := (bytes [234, 210, 6, 75, 123, 215, 192, 55, 102, 167, 88, 17, 211, 123, 119, 187, 62, 221, 213, 145, 171, 56, 145, 138, 7, 216, 31, 70, 22, 159, 13, 227]), digest := (bytes [75, 22, 202, 119, 180, 232, 196, 137, 255, 230, 216, 234, 203, 185, 92, 83, 86, 31, 35, 204, 103, 92, 214, 96, 139, 157, 118, 56, 21, 113, 179, 110]) }, { traceIndex := 3, values := [1, 4, 0, 4, 0, 20, 0, 6, 0, 3, 0, 0, 0, 3, 0, 8, 0, 0, 0, 0, 0, 0, 0, 40, 1, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], rowDigest := (bytes [65, 249, 157, 11, 211, 22, 178, 35, 126, 90, 217, 122, 86, 6, 98, 56, 162, 126, 166, 245, 230, 152, 213, 66, 154, 215, 167, 61, 24, 253, 6, 65]), digest := (bytes [21, 108, 252, 24, 157, 6, 24, 118, 180, 69, 47, 98, 186, 176, 68, 155, 45, 91, 41, 37, 173, 65, 117, 251, 66, 253, 216, 67, 65, 3, 164, 176]) }, { traceIndex := 4, values := [1, 4, 0, 4, 0, 3, 0, 6, 0, 18, 0, 0, 0, 18, 0, 8, 0, 0, 0, 0, 0, 0, 0, 41, 40, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], rowDigest := (bytes [5, 188, 109, 109, 12, 189, 183, 15, 65, 224, 200, 252, 72, 66, 253, 216, 12, 180, 201, 18, 189, 217, 69, 205, 220, 76, 137, 88, 85, 5, 73, 175]), digest := (bytes [126, 217, 16, 165, 99, 126, 224, 66, 83, 182, 161, 49, 183, 96, 188, 25, 130, 19, 235, 225, 23, 148, 5, 113, 84, 245, 42, 44, 96, 49, 189, 52]) }, { traceIndex := 5, values := [1, 4, 0, 8, 0, 20, 0, 18, 0, 2, 0, 0, 0, 2, 0, 8, 0, 0, 0, 0, 0, 0, 0, 6, 1, 41, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1], rowDigest := (bytes [203, 187, 38, 132, 54, 47, 238, 25, 245, 166, 17, 232, 148, 88, 7, 85, 228, 101, 33, 46, 72, 175, 19, 207, 221, 139, 136, 138, 8, 147, 208, 92]), digest := (bytes [59, 249, 4, 162, 100, 104, 48, 130, 251, 213, 9, 123, 197, 23, 95, 115, 92, 212, 209, 148, 212, 129, 10, 60, 58, 156, 233, 91, 93, 7, 1, 132]) }, { traceIndex := 6, values := [1, 8, 0, 8, 0, 4294967295, 4294967295, 3, 0, 1431655765, 0, 0, 0, 1431655765, 0, 12, 0, 0, 0, 0, 0, 0, 0, 7, 3, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], rowDigest := (bytes [233, 166, 25, 231, 225, 27, 180, 155, 246, 201, 194, 117, 252, 224, 156, 252, 246, 21, 189, 110, 206, 191, 63, 239, 114, 70, 42, 116, 160, 96, 111, 30]), digest := (bytes [103, 139, 104, 174, 233, 11, 209, 136, 244, 178, 215, 246, 168, 126, 82, 83, 199, 15, 43, 73, 213, 18, 119, 92, 77, 202, 248, 59, 53, 56, 60, 255]) }, { traceIndex := 7, values := [1, 8, 0, 8, 0, 1431655765, 0, 3, 0, 4294967295, 0, 0, 0, 4294967295, 0, 12, 0, 0, 0, 0, 0, 0, 0, 40, 7, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], rowDigest := (bytes [182, 232, 106, 215, 202, 126, 234, 142, 167, 155, 209, 183, 156, 95, 19, 192, 47, 97, 22, 38, 70, 60, 174, 217, 79, 199, 17, 248, 52, 56, 40, 37]), digest := (bytes [216, 70, 95, 232, 21, 13, 203, 78, 41, 198, 171, 100, 156, 140, 241, 133, 226, 241, 25, 181, 244, 56, 186, 141, 59, 7, 184, 16, 245, 136, 129, 119]) }, { traceIndex := 8, values := [1, 8, 0, 8, 0, 4294967295, 4294967295, 4294967295, 0, 0, 4294967295, 0, 0, 0, 4294967295, 12, 0, 0, 0, 0, 0, 0, 0, 41, 3, 40, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], rowDigest := (bytes [108, 83, 91, 238, 228, 103, 102, 176, 31, 203, 62, 17, 94, 17, 86, 174, 92, 53, 163, 93, 174, 237, 47, 238, 174, 140, 185, 114, 28, 183, 239, 13]), digest := (bytes [254, 252, 9, 112, 167, 98, 64, 58, 182, 189, 144, 85, 30, 99, 189, 74, 178, 6, 189, 11, 53, 13, 122, 67, 132, 217, 195, 154, 227, 56, 238, 221]) }, { traceIndex := 9, values := [1, 8, 0, 12, 0, 1431655765, 0, 0, 0, 1431655765, 0, 0, 0, 1431655765, 0, 12, 0, 0, 0, 0, 0, 0, 0, 7, 7, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [108, 236, 183, 209, 126, 5, 80, 10, 119, 222, 68, 29, 162, 149, 38, 169, 124, 53, 135, 138, 24, 146, 3, 1, 141, 219, 5, 244, 117, 90, 162, 76]), digest := (bytes [52, 237, 29, 102, 60, 36, 173, 1, 116, 250, 237, 49, 20, 240, 235, 233, 163, 124, 16, 48, 170, 204, 86, 131, 51, 233, 2, 149, 253, 157, 4, 117]) }, { traceIndex := 10, values := [1, 12, 0, 12, 0, 4294967295, 4294967295, 3, 0, 1431655765, 0, 0, 0, 1431655765, 0, 16, 0, 0, 0, 0, 0, 0, 0, 40, 3, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], rowDigest := (bytes [239, 83, 168, 7, 178, 9, 84, 59, 37, 164, 102, 44, 110, 160, 202, 170, 150, 73, 194, 127, 151, 252, 9, 16, 134, 170, 176, 116, 186, 172, 99, 209]), digest := (bytes [131, 236, 87, 69, 34, 0, 11, 195, 75, 99, 124, 212, 146, 155, 230, 168, 3, 176, 163, 77, 13, 240, 34, 216, 105, 220, 177, 238, 116, 207, 217, 1]) }, { traceIndex := 11, values := [1, 12, 0, 12, 0, 1431655765, 0, 3, 0, 4294967295, 0, 0, 0, 4294967295, 0, 16, 0, 0, 0, 0, 0, 0, 0, 41, 40, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], rowDigest := (bytes [96, 125, 2, 85, 205, 238, 154, 207, 237, 21, 160, 105, 158, 49, 1, 246, 221, 196, 150, 49, 30, 36, 120, 127, 129, 16, 56, 208, 29, 106, 114, 183]), digest := (bytes [106, 87, 15, 190, 230, 56, 131, 88, 122, 236, 36, 27, 187, 74, 122, 83, 67, 75, 218, 179, 239, 148, 171, 183, 158, 245, 224, 134, 214, 119, 73, 181]) }, { traceIndex := 12, values := [1, 12, 0, 12, 0, 4294967295, 4294967295, 4294967295, 0, 0, 4294967295, 0, 0, 0, 4294967295, 16, 0, 0, 0, 0, 0, 0, 0, 8, 3, 41, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], rowDigest := (bytes [153, 198, 105, 125, 50, 184, 161, 62, 58, 197, 108, 63, 123, 87, 40, 13, 112, 208, 43, 70, 48, 116, 252, 150, 34, 22, 164, 54, 223, 72, 103, 21]), digest := (bytes [16, 201, 185, 147, 99, 217, 237, 202, 92, 38, 238, 96, 91, 232, 40, 19, 80, 6, 135, 112, 151, 177, 117, 235, 213, 106, 109, 79, 174, 10, 108, 195]) }, { traceIndex := 13, values := [1, 12, 0, 16, 0, 0, 4294967295, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 0, 0, 0, 0, 0, 0, 8, 8, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [18, 145, 34, 20, 195, 164, 234, 231, 212, 120, 2, 175, 127, 120, 243, 76, 250, 108, 14, 150, 248, 44, 32, 156, 134, 80, 103, 4, 253, 63, 36, 12]), digest := (bytes [108, 118, 132, 172, 73, 94, 4, 235, 180, 48, 196, 81, 22, 205, 244, 189, 36, 227, 120, 250, 101, 46, 167, 46, 159, 4, 76, 95, 113, 219, 62, 136]) }, { traceIndex := 14, values := [1, 16, 0, 16, 0, 9, 0, 0, 0, 4294967295, 4294967295, 0, 0, 4294967295, 4294967295, 20, 0, 0, 0, 0, 0, 0, 0, 11, 9, 10, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], rowDigest := (bytes [92, 206, 44, 178, 19, 66, 44, 254, 104, 252, 200, 245, 46, 89, 244, 37, 10, 62, 102, 48, 162, 176, 186, 12, 24, 220, 158, 22, 59, 176, 167, 8]), digest := (bytes [238, 241, 80, 38, 50, 2, 29, 167, 91, 132, 106, 232, 121, 19, 195, 245, 183, 43, 205, 47, 133, 242, 30, 86, 52, 215, 134, 116, 33, 135, 69, 219]) }, { traceIndex := 15, values := [1, 16, 0, 16, 0, 4294967295, 4294967295, 0, 0, 0, 0, 0, 0, 0, 0, 20, 0, 0, 0, 0, 0, 0, 0, 40, 11, 10, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], rowDigest := (bytes [80, 18, 238, 187, 77, 110, 104, 248, 24, 180, 69, 117, 29, 193, 25, 93, 78, 140, 82, 141, 103, 181, 78, 134, 24, 108, 24, 134, 101, 3, 27, 163]), digest := (bytes [4, 132, 64, 193, 168, 21, 16, 134, 152, 231, 227, 202, 145, 159, 243, 216, 231, 143, 1, 248, 155, 96, 200, 246, 195, 136, 149, 179, 255, 241, 29, 181]) }, { traceIndex := 16, values := [1, 16, 0, 20, 0, 9, 0, 0, 0, 9, 0, 0, 0, 9, 0, 20, 0, 0, 0, 0, 0, 0, 0, 41, 9, 40, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1], rowDigest := (bytes [3, 60, 2, 136, 126, 60, 95, 89, 237, 139, 230, 198, 12, 27, 158, 210, 126, 220, 0, 66, 184, 126, 170, 60, 44, 113, 235, 237, 127, 19, 158, 235]), digest := (bytes [61, 30, 66, 125, 28, 235, 200, 212, 200, 23, 34, 129, 225, 237, 110, 24, 124, 136, 60, 6, 24, 172, 122, 24, 227, 89, 186, 4, 114, 232, 154, 22]) }, { traceIndex := 17, values := [1, 20, 0, 20, 0, 9, 0, 0, 0, 4294967295, 4294967295, 0, 0, 4294967295, 4294967295, 24, 0, 0, 0, 0, 0, 0, 0, 40, 9, 10, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], rowDigest := (bytes [249, 190, 82, 196, 202, 11, 70, 179, 40, 235, 54, 245, 123, 4, 16, 211, 191, 180, 138, 95, 189, 197, 0, 43, 3, 65, 134, 177, 151, 230, 41, 161]), digest := (bytes [74, 47, 120, 175, 110, 56, 110, 240, 208, 26, 120, 135, 1, 174, 74, 29, 86, 219, 103, 142, 247, 29, 250, 96, 16, 243, 75, 236, 230, 190, 167, 151]) }, { traceIndex := 18, values := [1, 20, 0, 20, 0, 4294967295, 4294967295, 0, 0, 0, 0, 0, 0, 0, 0, 24, 0, 0, 0, 0, 0, 0, 0, 41, 40, 10, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], rowDigest := (bytes [43, 52, 173, 127, 231, 252, 165, 229, 216, 76, 36, 175, 230, 60, 16, 30, 215, 105, 212, 189, 152, 82, 64, 250, 53, 182, 107, 61, 61, 121, 172, 111]), digest := (bytes [78, 176, 172, 185, 235, 161, 170, 97, 190, 168, 43, 108, 189, 37, 193, 221, 189, 172, 64, 90, 173, 188, 50, 252, 253, 58, 118, 79, 132, 50, 155, 140]) }, { traceIndex := 19, values := [1, 20, 0, 24, 0, 9, 0, 0, 0, 9, 0, 0, 0, 9, 0, 24, 0, 0, 0, 0, 0, 0, 0, 12, 9, 41, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1], rowDigest := (bytes [226, 223, 249, 52, 202, 180, 31, 236, 69, 187, 172, 19, 2, 217, 37, 36, 13, 72, 27, 43, 3, 242, 194, 182, 118, 207, 176, 221, 212, 17, 179, 122]), digest := (bytes [13, 7, 186, 112, 52, 116, 157, 229, 53, 239, 107, 228, 220, 121, 107, 32, 222, 226, 73, 108, 77, 7, 107, 210, 133, 18, 85, 22, 111, 129, 229, 199]) }, { traceIndex := 20, values := [1, 24, 0, 24, 0, 2147483649, 4294967295, 0, 0, 4294967295, 0, 0, 0, 4294967295, 0, 28, 0, 0, 0, 0, 0, 0, 0, 15, 13, 14, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], rowDigest := (bytes [243, 74, 109, 28, 147, 9, 125, 238, 14, 57, 120, 137, 242, 238, 60, 216, 126, 193, 90, 121, 178, 138, 94, 247, 15, 168, 229, 20, 12, 36, 110, 36]), digest := (bytes [54, 210, 85, 250, 125, 21, 186, 237, 92, 169, 10, 209, 209, 151, 121, 213, 25, 220, 43, 19, 64, 21, 213, 97, 231, 117, 80, 244, 141, 136, 27, 8]) }, { traceIndex := 21, values := [1, 24, 0, 24, 0, 4294967295, 0, 0, 0, 0, 0, 0, 0, 0, 0, 28, 0, 0, 0, 0, 0, 0, 0, 40, 15, 14, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], rowDigest := (bytes [215, 249, 136, 180, 67, 12, 57, 40, 198, 173, 116, 97, 234, 252, 17, 154, 253, 238, 142, 159, 175, 87, 179, 216, 157, 91, 208, 156, 126, 17, 253, 58]), digest := (bytes [173, 42, 28, 185, 132, 152, 209, 244, 195, 174, 33, 91, 48, 124, 106, 227, 211, 132, 56, 188, 76, 82, 185, 128, 176, 180, 144, 43, 153, 135, 191, 232]) }, { traceIndex := 22, values := [1, 24, 0, 24, 0, 2147483649, 4294967295, 0, 0, 2147483649, 4294967295, 0, 0, 2147483649, 4294967295, 28, 0, 0, 0, 0, 0, 0, 0, 41, 13, 40, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], rowDigest := (bytes [85, 214, 216, 191, 28, 229, 228, 16, 239, 214, 169, 98, 30, 176, 198, 57, 91, 186, 251, 84, 4, 37, 118, 153, 22, 22, 106, 68, 36, 238, 139, 55]), digest := (bytes [252, 47, 52, 97, 85, 184, 205, 166, 163, 31, 209, 44, 188, 120, 178, 100, 54, 79, 97, 147, 104, 246, 105, 34, 78, 200, 158, 10, 134, 103, 17, 130]) }, { traceIndex := 23, values := [1, 24, 0, 28, 0, 4294967295, 0, 0, 0, 4294967295, 4294967295, 0, 0, 4294967295, 4294967295, 28, 0, 0, 0, 0, 0, 0, 0, 15, 15, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [83, 196, 28, 180, 237, 223, 82, 38, 157, 237, 214, 79, 100, 104, 36, 32, 187, 130, 1, 97, 72, 243, 149, 238, 208, 116, 114, 52, 52, 148, 169, 124]), digest := (bytes [250, 106, 21, 155, 137, 175, 93, 14, 44, 150, 60, 179, 184, 34, 52, 74, 245, 30, 68, 193, 56, 33, 240, 88, 224, 239, 231, 14, 118, 27, 195, 94]) }, { traceIndex := 24, values := [1, 28, 0, 28, 0, 2147483649, 4294967295, 0, 0, 4294967295, 0, 0, 0, 4294967295, 0, 32, 0, 0, 0, 0, 0, 0, 0, 40, 13, 14, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], rowDigest := (bytes [82, 17, 49, 84, 46, 121, 110, 215, 43, 64, 204, 105, 161, 63, 107, 19, 112, 132, 156, 75, 62, 62, 170, 26, 90, 199, 243, 125, 110, 96, 162, 149]), digest := (bytes [206, 85, 130, 209, 39, 172, 127, 232, 136, 72, 254, 39, 163, 72, 132, 11, 218, 44, 26, 60, 133, 139, 44, 144, 226, 167, 69, 117, 188, 186, 31, 54]) }, { traceIndex := 25, values := [1, 28, 0, 28, 0, 4294967295, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32, 0, 0, 0, 0, 0, 0, 0, 41, 40, 14, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], rowDigest := (bytes [138, 213, 132, 226, 17, 110, 19, 195, 174, 202, 92, 78, 73, 19, 119, 131, 254, 232, 223, 144, 82, 203, 203, 140, 142, 157, 45, 78, 221, 246, 109, 253]), digest := (bytes [31, 108, 0, 208, 93, 16, 132, 158, 68, 235, 103, 38, 101, 124, 121, 166, 59, 211, 143, 41, 209, 29, 231, 152, 200, 186, 207, 5, 246, 200, 242, 56]) }, { traceIndex := 26, values := [1, 28, 0, 28, 0, 2147483649, 4294967295, 0, 0, 2147483649, 4294967295, 0, 0, 2147483649, 4294967295, 32, 0, 0, 0, 0, 0, 0, 0, 16, 13, 41, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], rowDigest := (bytes [77, 184, 158, 212, 115, 243, 78, 243, 182, 24, 233, 243, 31, 201, 152, 166, 22, 180, 127, 214, 70, 224, 61, 51, 233, 105, 8, 162, 205, 65, 199, 157]), digest := (bytes [27, 139, 236, 157, 139, 238, 154, 103, 70, 160, 44, 15, 13, 166, 205, 73, 102, 100, 166, 33, 215, 40, 31, 223, 122, 167, 200, 146, 129, 214, 238, 80]) }, { traceIndex := 27, values := [1, 28, 0, 32, 0, 2147483649, 4294967295, 0, 0, 2147483649, 4294967295, 0, 0, 2147483649, 4294967295, 32, 0, 0, 0, 0, 0, 0, 0, 16, 16, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [123, 11, 210, 67, 192, 198, 179, 24, 238, 128, 249, 226, 206, 74, 13, 210, 175, 223, 180, 51, 121, 202, 63, 90, 242, 104, 199, 20, 18, 34, 157, 225]), digest := (bytes [223, 115, 29, 116, 61, 21, 167, 105, 126, 15, 222, 184, 241, 111, 127, 124, 120, 2, 255, 20, 184, 40, 203, 79, 36, 248, 45, 66, 18, 123, 230, 158]) }, { traceIndex := 28, values := [1, 32, 0, 36, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 36, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [191, 59, 111, 91, 175, 174, 193, 106, 252, 237, 179, 109, 105, 90, 100, 212, 35, 239, 230, 162, 83, 17, 88, 13, 240, 150, 187, 164, 56, 114, 73, 39]), digest := (bytes [202, 28, 105, 135, 163, 253, 177, 177, 239, 16, 236, 124, 48, 166, 182, 126, 254, 203, 225, 152, 144, 53, 118, 11, 223, 4, 58, 41, 118, 117, 83, 22]) }]

def rootExecutionPreparedBindings : List PreparedStepBindingView :=
  [{ traceIndex := 0, rowDigest := (bytes [15, 203, 82, 147, 182, 107, 150, 168, 159, 107, 204, 115, 170, 200, 12, 67, 125, 81, 225, 219, 175, 26, 58, 39, 55, 35, 134, 130, 62, 126, 3, 37]), rowOpeningDigest := (bytes [45, 161, 238, 241, 198, 238, 221, 31, 180, 58, 220, 162, 22, 61, 238, 251, 249, 195, 29, 205, 227, 246, 79, 201, 151, 86, 233, 105, 224, 236, 143, 125]), digest := (bytes [196, 127, 115, 228, 145, 235, 105, 203, 91, 30, 41, 234, 216, 138, 118, 223, 152, 13, 133, 59, 128, 32, 23, 132, 0, 186, 217, 35, 34, 46, 143, 135]) }, { traceIndex := 1, rowDigest := (bytes [60, 215, 205, 5, 39, 54, 187, 203, 122, 19, 181, 4, 207, 239, 83, 130, 97, 87, 236, 195, 81, 5, 54, 170, 123, 142, 70, 92, 18, 71, 210, 101]), rowOpeningDigest := (bytes [104, 42, 149, 156, 47, 166, 5, 20, 4, 43, 116, 17, 15, 4, 132, 168, 152, 128, 216, 129, 33, 49, 90, 31, 217, 102, 199, 127, 220, 42, 199, 231]), digest := (bytes [0, 254, 8, 79, 59, 114, 109, 146, 23, 15, 216, 107, 171, 8, 193, 37, 127, 32, 182, 209, 172, 8, 154, 103, 229, 122, 197, 165, 217, 204, 197, 239]) }, { traceIndex := 2, rowDigest := (bytes [234, 210, 6, 75, 123, 215, 192, 55, 102, 167, 88, 17, 211, 123, 119, 187, 62, 221, 213, 145, 171, 56, 145, 138, 7, 216, 31, 70, 22, 159, 13, 227]), rowOpeningDigest := (bytes [108, 67, 6, 5, 19, 147, 107, 135, 248, 219, 112, 97, 254, 142, 187, 94, 163, 27, 83, 247, 104, 224, 121, 135, 210, 151, 115, 52, 144, 133, 58, 162]), digest := (bytes [135, 20, 39, 193, 36, 204, 146, 160, 15, 213, 4, 70, 122, 160, 105, 102, 201, 123, 227, 203, 211, 48, 150, 49, 244, 14, 201, 29, 67, 181, 0, 229]) }, { traceIndex := 3, rowDigest := (bytes [65, 249, 157, 11, 211, 22, 178, 35, 126, 90, 217, 122, 86, 6, 98, 56, 162, 126, 166, 245, 230, 152, 213, 66, 154, 215, 167, 61, 24, 253, 6, 65]), rowOpeningDigest := (bytes [163, 171, 238, 234, 63, 49, 20, 0, 37, 42, 138, 105, 240, 183, 43, 5, 229, 100, 254, 43, 31, 159, 70, 147, 102, 184, 56, 255, 251, 191, 85, 99]), digest := (bytes [60, 115, 87, 171, 60, 35, 12, 17, 85, 133, 80, 196, 74, 54, 8, 39, 95, 60, 47, 125, 220, 65, 47, 161, 75, 135, 129, 96, 79, 31, 71, 64]) }, { traceIndex := 4, rowDigest := (bytes [5, 188, 109, 109, 12, 189, 183, 15, 65, 224, 200, 252, 72, 66, 253, 216, 12, 180, 201, 18, 189, 217, 69, 205, 220, 76, 137, 88, 85, 5, 73, 175]), rowOpeningDigest := (bytes [109, 244, 103, 115, 60, 54, 209, 49, 16, 150, 64, 84, 31, 175, 235, 79, 254, 193, 57, 72, 133, 88, 172, 205, 168, 248, 224, 192, 85, 84, 177, 216]), digest := (bytes [101, 37, 166, 90, 81, 113, 151, 115, 176, 55, 21, 227, 97, 32, 103, 5, 78, 185, 217, 114, 168, 93, 188, 106, 227, 177, 169, 55, 122, 243, 169, 196]) }, { traceIndex := 5, rowDigest := (bytes [203, 187, 38, 132, 54, 47, 238, 25, 245, 166, 17, 232, 148, 88, 7, 85, 228, 101, 33, 46, 72, 175, 19, 207, 221, 139, 136, 138, 8, 147, 208, 92]), rowOpeningDigest := (bytes [99, 168, 114, 146, 67, 82, 73, 248, 0, 140, 246, 241, 181, 193, 62, 27, 159, 246, 192, 164, 237, 22, 97, 5, 72, 215, 123, 215, 95, 214, 133, 240]), digest := (bytes [46, 217, 235, 86, 53, 49, 64, 92, 149, 99, 129, 130, 131, 81, 170, 99, 88, 224, 44, 8, 11, 215, 13, 175, 103, 31, 197, 104, 155, 205, 101, 209]) }, { traceIndex := 6, rowDigest := (bytes [233, 166, 25, 231, 225, 27, 180, 155, 246, 201, 194, 117, 252, 224, 156, 252, 246, 21, 189, 110, 206, 191, 63, 239, 114, 70, 42, 116, 160, 96, 111, 30]), rowOpeningDigest := (bytes [241, 127, 139, 88, 1, 193, 51, 102, 185, 93, 41, 32, 184, 142, 43, 195, 19, 34, 251, 92, 5, 153, 163, 57, 150, 190, 179, 28, 116, 23, 192, 100]), digest := (bytes [29, 53, 226, 48, 18, 54, 210, 123, 145, 16, 39, 215, 46, 150, 209, 66, 255, 214, 248, 236, 157, 238, 192, 225, 237, 130, 58, 41, 80, 93, 10, 253]) }, { traceIndex := 7, rowDigest := (bytes [182, 232, 106, 215, 202, 126, 234, 142, 167, 155, 209, 183, 156, 95, 19, 192, 47, 97, 22, 38, 70, 60, 174, 217, 79, 199, 17, 248, 52, 56, 40, 37]), rowOpeningDigest := (bytes [211, 136, 186, 167, 132, 33, 226, 65, 96, 98, 88, 159, 63, 151, 157, 230, 168, 101, 14, 117, 233, 231, 244, 236, 54, 144, 63, 70, 194, 196, 202, 38]), digest := (bytes [106, 15, 90, 142, 228, 22, 167, 202, 104, 76, 19, 100, 3, 24, 121, 177, 235, 236, 165, 152, 126, 94, 228, 123, 229, 23, 154, 236, 141, 79, 23, 242]) }, { traceIndex := 8, rowDigest := (bytes [108, 83, 91, 238, 228, 103, 102, 176, 31, 203, 62, 17, 94, 17, 86, 174, 92, 53, 163, 93, 174, 237, 47, 238, 174, 140, 185, 114, 28, 183, 239, 13]), rowOpeningDigest := (bytes [58, 96, 252, 191, 37, 6, 215, 128, 115, 182, 135, 208, 87, 142, 34, 247, 183, 190, 157, 222, 50, 92, 138, 150, 94, 93, 32, 88, 42, 11, 240, 136]), digest := (bytes [231, 156, 236, 58, 138, 7, 35, 114, 64, 133, 231, 42, 246, 241, 98, 92, 109, 25, 247, 254, 165, 93, 187, 39, 64, 29, 131, 168, 158, 46, 14, 107]) }, { traceIndex := 9, rowDigest := (bytes [108, 236, 183, 209, 126, 5, 80, 10, 119, 222, 68, 29, 162, 149, 38, 169, 124, 53, 135, 138, 24, 146, 3, 1, 141, 219, 5, 244, 117, 90, 162, 76]), rowOpeningDigest := (bytes [10, 99, 238, 158, 124, 34, 23, 117, 218, 238, 194, 208, 241, 27, 183, 89, 52, 237, 226, 7, 198, 21, 175, 95, 197, 118, 149, 104, 161, 214, 252, 112]), digest := (bytes [153, 248, 112, 176, 139, 43, 160, 136, 128, 19, 111, 11, 12, 249, 212, 168, 146, 205, 144, 135, 139, 135, 214, 168, 137, 199, 186, 148, 246, 115, 254, 150]) }, { traceIndex := 10, rowDigest := (bytes [239, 83, 168, 7, 178, 9, 84, 59, 37, 164, 102, 44, 110, 160, 202, 170, 150, 73, 194, 127, 151, 252, 9, 16, 134, 170, 176, 116, 186, 172, 99, 209]), rowOpeningDigest := (bytes [239, 101, 77, 177, 93, 51, 202, 117, 153, 100, 193, 18, 79, 8, 28, 153, 233, 13, 227, 42, 186, 177, 115, 126, 30, 207, 229, 162, 57, 189, 14, 15]), digest := (bytes [252, 42, 71, 185, 29, 217, 106, 230, 161, 152, 122, 167, 46, 178, 244, 100, 89, 151, 96, 238, 137, 165, 207, 211, 246, 44, 245, 0, 4, 181, 209, 140]) }, { traceIndex := 11, rowDigest := (bytes [96, 125, 2, 85, 205, 238, 154, 207, 237, 21, 160, 105, 158, 49, 1, 246, 221, 196, 150, 49, 30, 36, 120, 127, 129, 16, 56, 208, 29, 106, 114, 183]), rowOpeningDigest := (bytes [134, 0, 3, 239, 55, 153, 96, 151, 191, 102, 63, 88, 67, 42, 170, 195, 228, 30, 192, 43, 190, 237, 152, 235, 29, 157, 225, 147, 246, 25, 11, 102]), digest := (bytes [250, 202, 190, 200, 71, 238, 137, 43, 217, 25, 41, 69, 44, 117, 155, 2, 26, 60, 33, 18, 136, 37, 142, 5, 239, 33, 191, 25, 88, 86, 236, 169]) }, { traceIndex := 12, rowDigest := (bytes [153, 198, 105, 125, 50, 184, 161, 62, 58, 197, 108, 63, 123, 87, 40, 13, 112, 208, 43, 70, 48, 116, 252, 150, 34, 22, 164, 54, 223, 72, 103, 21]), rowOpeningDigest := (bytes [206, 41, 179, 151, 171, 189, 188, 51, 236, 2, 83, 158, 92, 155, 73, 86, 57, 23, 130, 178, 6, 98, 171, 132, 80, 83, 17, 15, 60, 13, 158, 194]), digest := (bytes [43, 165, 115, 225, 22, 64, 11, 233, 223, 106, 242, 232, 98, 23, 72, 183, 169, 127, 186, 62, 160, 224, 201, 244, 95, 0, 156, 103, 161, 44, 250, 2]) }, { traceIndex := 13, rowDigest := (bytes [18, 145, 34, 20, 195, 164, 234, 231, 212, 120, 2, 175, 127, 120, 243, 76, 250, 108, 14, 150, 248, 44, 32, 156, 134, 80, 103, 4, 253, 63, 36, 12]), rowOpeningDigest := (bytes [188, 151, 192, 185, 49, 214, 22, 68, 74, 26, 196, 96, 144, 88, 242, 49, 42, 165, 200, 156, 195, 201, 33, 123, 72, 117, 119, 205, 222, 4, 64, 99]), digest := (bytes [37, 175, 91, 93, 45, 175, 62, 80, 210, 34, 77, 91, 41, 37, 204, 225, 252, 39, 3, 217, 174, 179, 205, 91, 239, 120, 141, 200, 105, 128, 133, 228]) }, { traceIndex := 14, rowDigest := (bytes [92, 206, 44, 178, 19, 66, 44, 254, 104, 252, 200, 245, 46, 89, 244, 37, 10, 62, 102, 48, 162, 176, 186, 12, 24, 220, 158, 22, 59, 176, 167, 8]), rowOpeningDigest := (bytes [92, 177, 140, 7, 191, 27, 72, 59, 194, 166, 149, 9, 17, 136, 27, 249, 14, 21, 16, 76, 187, 90, 146, 91, 43, 80, 216, 120, 123, 209, 124, 87]), digest := (bytes [235, 80, 228, 103, 26, 224, 215, 213, 212, 112, 29, 125, 161, 70, 106, 186, 190, 160, 79, 78, 195, 103, 144, 25, 110, 31, 76, 13, 3, 161, 196, 63]) }, { traceIndex := 15, rowDigest := (bytes [80, 18, 238, 187, 77, 110, 104, 248, 24, 180, 69, 117, 29, 193, 25, 93, 78, 140, 82, 141, 103, 181, 78, 134, 24, 108, 24, 134, 101, 3, 27, 163]), rowOpeningDigest := (bytes [224, 177, 126, 88, 199, 156, 146, 22, 16, 74, 90, 173, 142, 119, 248, 25, 92, 21, 241, 17, 132, 36, 197, 102, 93, 99, 15, 161, 239, 129, 171, 62]), digest := (bytes [33, 235, 216, 195, 247, 160, 99, 149, 109, 234, 63, 7, 71, 98, 110, 252, 184, 249, 179, 196, 196, 76, 56, 30, 219, 179, 18, 197, 240, 109, 79, 243]) }, { traceIndex := 16, rowDigest := (bytes [3, 60, 2, 136, 126, 60, 95, 89, 237, 139, 230, 198, 12, 27, 158, 210, 126, 220, 0, 66, 184, 126, 170, 60, 44, 113, 235, 237, 127, 19, 158, 235]), rowOpeningDigest := (bytes [101, 72, 204, 222, 183, 188, 171, 126, 67, 130, 83, 231, 216, 33, 47, 25, 41, 23, 106, 249, 76, 234, 58, 49, 135, 204, 235, 170, 26, 24, 61, 160]), digest := (bytes [2, 219, 133, 56, 196, 251, 194, 17, 236, 27, 178, 68, 44, 148, 242, 33, 39, 66, 44, 198, 183, 230, 214, 214, 43, 106, 247, 89, 89, 73, 234, 1]) }, { traceIndex := 17, rowDigest := (bytes [249, 190, 82, 196, 202, 11, 70, 179, 40, 235, 54, 245, 123, 4, 16, 211, 191, 180, 138, 95, 189, 197, 0, 43, 3, 65, 134, 177, 151, 230, 41, 161]), rowOpeningDigest := (bytes [124, 203, 46, 89, 234, 186, 2, 249, 11, 133, 115, 1, 94, 162, 140, 65, 24, 120, 245, 24, 36, 5, 51, 82, 177, 23, 56, 162, 7, 85, 163, 244]), digest := (bytes [237, 72, 157, 178, 170, 209, 31, 81, 70, 177, 213, 254, 119, 180, 18, 50, 182, 213, 168, 64, 48, 82, 27, 14, 29, 179, 74, 237, 186, 77, 167, 253]) }, { traceIndex := 18, rowDigest := (bytes [43, 52, 173, 127, 231, 252, 165, 229, 216, 76, 36, 175, 230, 60, 16, 30, 215, 105, 212, 189, 152, 82, 64, 250, 53, 182, 107, 61, 61, 121, 172, 111]), rowOpeningDigest := (bytes [164, 14, 206, 42, 110, 168, 54, 197, 101, 234, 101, 4, 237, 189, 222, 94, 178, 214, 141, 232, 143, 93, 246, 174, 155, 21, 251, 191, 46, 157, 178, 191]), digest := (bytes [191, 58, 14, 98, 131, 172, 108, 55, 57, 60, 200, 47, 47, 67, 30, 190, 119, 135, 48, 28, 73, 90, 52, 224, 230, 71, 199, 160, 196, 190, 60, 50]) }, { traceIndex := 19, rowDigest := (bytes [226, 223, 249, 52, 202, 180, 31, 236, 69, 187, 172, 19, 2, 217, 37, 36, 13, 72, 27, 43, 3, 242, 194, 182, 118, 207, 176, 221, 212, 17, 179, 122]), rowOpeningDigest := (bytes [205, 138, 200, 124, 172, 228, 187, 10, 136, 31, 129, 4, 45, 210, 119, 90, 107, 109, 171, 19, 3, 32, 57, 66, 212, 24, 122, 238, 86, 94, 251, 56]), digest := (bytes [102, 182, 137, 118, 211, 205, 105, 72, 254, 128, 72, 129, 223, 65, 203, 33, 118, 90, 217, 39, 29, 244, 110, 3, 5, 121, 214, 51, 39, 199, 178, 16]) }, { traceIndex := 20, rowDigest := (bytes [243, 74, 109, 28, 147, 9, 125, 238, 14, 57, 120, 137, 242, 238, 60, 216, 126, 193, 90, 121, 178, 138, 94, 247, 15, 168, 229, 20, 12, 36, 110, 36]), rowOpeningDigest := (bytes [113, 70, 120, 39, 6, 36, 196, 53, 21, 21, 122, 120, 113, 117, 2, 207, 185, 171, 186, 104, 250, 240, 190, 82, 187, 190, 72, 74, 107, 193, 195, 173]), digest := (bytes [16, 88, 82, 90, 127, 215, 86, 150, 28, 228, 157, 96, 11, 117, 129, 70, 230, 201, 22, 94, 109, 33, 97, 164, 176, 23, 108, 52, 28, 143, 227, 9]) }, { traceIndex := 21, rowDigest := (bytes [215, 249, 136, 180, 67, 12, 57, 40, 198, 173, 116, 97, 234, 252, 17, 154, 253, 238, 142, 159, 175, 87, 179, 216, 157, 91, 208, 156, 126, 17, 253, 58]), rowOpeningDigest := (bytes [7, 149, 64, 67, 162, 83, 226, 161, 120, 122, 99, 116, 29, 230, 74, 60, 240, 203, 163, 49, 141, 134, 201, 136, 241, 195, 133, 94, 221, 223, 200, 131]), digest := (bytes [42, 5, 21, 56, 61, 20, 168, 207, 214, 33, 12, 156, 116, 19, 0, 224, 170, 206, 33, 83, 33, 63, 14, 45, 241, 75, 37, 45, 181, 234, 234, 16]) }, { traceIndex := 22, rowDigest := (bytes [85, 214, 216, 191, 28, 229, 228, 16, 239, 214, 169, 98, 30, 176, 198, 57, 91, 186, 251, 84, 4, 37, 118, 153, 22, 22, 106, 68, 36, 238, 139, 55]), rowOpeningDigest := (bytes [128, 201, 59, 237, 94, 60, 249, 119, 133, 15, 31, 159, 134, 13, 41, 100, 201, 107, 38, 146, 216, 48, 61, 220, 109, 118, 224, 186, 190, 244, 117, 253]), digest := (bytes [75, 242, 7, 92, 255, 227, 231, 31, 214, 18, 223, 107, 154, 25, 183, 127, 194, 42, 121, 34, 154, 77, 164, 205, 209, 24, 99, 10, 99, 232, 177, 41]) }, { traceIndex := 23, rowDigest := (bytes [83, 196, 28, 180, 237, 223, 82, 38, 157, 237, 214, 79, 100, 104, 36, 32, 187, 130, 1, 97, 72, 243, 149, 238, 208, 116, 114, 52, 52, 148, 169, 124]), rowOpeningDigest := (bytes [141, 78, 53, 81, 203, 64, 136, 242, 163, 111, 61, 119, 133, 213, 129, 202, 208, 209, 159, 20, 46, 115, 60, 104, 48, 228, 0, 224, 65, 106, 173, 220]), digest := (bytes [181, 68, 113, 70, 124, 131, 94, 29, 169, 232, 141, 149, 49, 78, 71, 166, 2, 228, 138, 222, 166, 5, 89, 155, 226, 110, 20, 94, 50, 184, 49, 121]) }, { traceIndex := 24, rowDigest := (bytes [82, 17, 49, 84, 46, 121, 110, 215, 43, 64, 204, 105, 161, 63, 107, 19, 112, 132, 156, 75, 62, 62, 170, 26, 90, 199, 243, 125, 110, 96, 162, 149]), rowOpeningDigest := (bytes [123, 180, 33, 123, 122, 239, 169, 218, 170, 29, 173, 160, 80, 73, 65, 66, 115, 30, 24, 128, 166, 23, 71, 235, 214, 47, 78, 207, 150, 213, 202, 97]), digest := (bytes [148, 245, 199, 127, 3, 0, 139, 3, 46, 192, 134, 40, 115, 34, 101, 102, 120, 45, 87, 48, 199, 148, 137, 235, 30, 137, 225, 33, 16, 161, 168, 122]) }, { traceIndex := 25, rowDigest := (bytes [138, 213, 132, 226, 17, 110, 19, 195, 174, 202, 92, 78, 73, 19, 119, 131, 254, 232, 223, 144, 82, 203, 203, 140, 142, 157, 45, 78, 221, 246, 109, 253]), rowOpeningDigest := (bytes [101, 162, 197, 194, 51, 193, 86, 137, 169, 183, 254, 95, 41, 219, 171, 178, 153, 108, 174, 27, 243, 197, 76, 127, 157, 65, 104, 201, 9, 108, 1, 204]), digest := (bytes [247, 191, 143, 255, 26, 119, 247, 116, 193, 201, 48, 243, 127, 163, 101, 178, 238, 215, 64, 127, 186, 98, 98, 244, 138, 2, 25, 208, 87, 49, 31, 126]) }, { traceIndex := 26, rowDigest := (bytes [77, 184, 158, 212, 115, 243, 78, 243, 182, 24, 233, 243, 31, 201, 152, 166, 22, 180, 127, 214, 70, 224, 61, 51, 233, 105, 8, 162, 205, 65, 199, 157]), rowOpeningDigest := (bytes [93, 25, 196, 143, 159, 61, 233, 191, 163, 224, 2, 47, 156, 121, 41, 115, 137, 77, 55, 160, 224, 67, 17, 168, 218, 222, 110, 96, 12, 203, 16, 168]), digest := (bytes [34, 234, 181, 238, 156, 187, 169, 107, 14, 210, 176, 12, 28, 194, 244, 221, 55, 85, 155, 195, 242, 8, 117, 145, 209, 187, 63, 214, 250, 67, 144, 38]) }, { traceIndex := 27, rowDigest := (bytes [123, 11, 210, 67, 192, 198, 179, 24, 238, 128, 249, 226, 206, 74, 13, 210, 175, 223, 180, 51, 121, 202, 63, 90, 242, 104, 199, 20, 18, 34, 157, 225]), rowOpeningDigest := (bytes [192, 168, 152, 125, 225, 160, 61, 204, 151, 99, 69, 213, 187, 51, 157, 35, 188, 224, 166, 0, 233, 112, 220, 89, 24, 205, 195, 121, 245, 118, 205, 84]), digest := (bytes [209, 99, 245, 95, 136, 28, 186, 77, 180, 154, 92, 124, 63, 228, 177, 123, 51, 121, 82, 107, 62, 120, 146, 135, 248, 219, 24, 35, 174, 42, 63, 214]) }, { traceIndex := 28, rowDigest := (bytes [191, 59, 111, 91, 175, 174, 193, 106, 252, 237, 179, 109, 105, 90, 100, 212, 35, 239, 230, 162, 83, 17, 88, 13, 240, 150, 187, 164, 56, 114, 73, 39]), rowOpeningDigest := (bytes [180, 81, 197, 89, 123, 21, 57, 248, 239, 158, 190, 71, 240, 70, 71, 207, 10, 185, 191, 205, 239, 154, 252, 215, 220, 242, 31, 7, 28, 106, 157, 137]), digest := (bytes [210, 164, 188, 10, 200, 87, 23, 227, 108, 94, 15, 153, 245, 204, 108, 191, 76, 213, 158, 176, 59, 20, 86, 180, 2, 103, 191, 35, 54, 77, 76, 101]) }]

def rootExecutionRowChunkRoutes : List RowChunkRouteView :=
  [{ logicalIndex := 0, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 0, digest := (bytes [138, 198, 109, 126, 144, 82, 221, 43, 248, 202, 137, 103, 62, 226, 249, 152, 163, 187, 1, 254, 36, 33, 59, 16, 64, 166, 202, 8, 219, 57, 240, 59]) }, { logicalIndex := 1, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 1, digest := (bytes [44, 177, 82, 41, 218, 60, 100, 208, 26, 31, 151, 113, 109, 148, 57, 12, 223, 21, 76, 221, 70, 245, 191, 105, 57, 199, 8, 128, 181, 145, 89, 99]) }, { logicalIndex := 2, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 2, digest := (bytes [252, 248, 65, 24, 81, 241, 150, 170, 250, 116, 222, 30, 134, 191, 78, 195, 104, 119, 225, 210, 243, 186, 212, 107, 183, 31, 243, 201, 101, 148, 32, 72]) }, { logicalIndex := 3, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 3, digest := (bytes [244, 11, 162, 13, 59, 43, 232, 47, 228, 2, 70, 126, 95, 10, 57, 40, 46, 107, 197, 81, 97, 39, 185, 163, 93, 60, 5, 66, 7, 231, 199, 134]) }, { logicalIndex := 4, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 4, digest := (bytes [98, 247, 204, 83, 252, 219, 248, 73, 49, 206, 229, 79, 169, 242, 28, 56, 7, 100, 18, 197, 133, 200, 133, 20, 161, 230, 126, 175, 98, 0, 158, 25]) }, { logicalIndex := 5, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 5, digest := (bytes [108, 248, 244, 125, 120, 190, 11, 202, 47, 205, 44, 110, 48, 43, 171, 224, 142, 98, 82, 106, 183, 21, 141, 205, 208, 18, 234, 19, 43, 61, 139, 151]) }, { logicalIndex := 6, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 6, digest := (bytes [213, 163, 43, 1, 32, 112, 128, 155, 10, 34, 241, 205, 79, 46, 234, 45, 239, 83, 213, 254, 45, 65, 13, 152, 217, 78, 36, 105, 42, 193, 181, 13]) }, { logicalIndex := 7, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 7, digest := (bytes [199, 10, 5, 135, 58, 125, 195, 205, 65, 103, 137, 179, 210, 215, 124, 50, 45, 181, 46, 62, 43, 114, 240, 192, 142, 94, 31, 202, 153, 102, 209, 54]) }, { logicalIndex := 8, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 8, digest := (bytes [243, 104, 100, 66, 94, 61, 218, 185, 138, 159, 201, 38, 53, 64, 18, 187, 81, 105, 239, 11, 139, 137, 248, 62, 130, 187, 188, 172, 131, 72, 106, 73]) }, { logicalIndex := 9, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 9, digest := (bytes [11, 164, 4, 249, 84, 107, 210, 66, 134, 110, 223, 149, 172, 176, 94, 254, 45, 42, 247, 93, 171, 29, 160, 56, 115, 52, 76, 84, 241, 17, 162, 122]) }, { logicalIndex := 10, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 10, digest := (bytes [163, 19, 52, 250, 55, 230, 68, 230, 28, 108, 101, 226, 50, 126, 176, 29, 159, 73, 227, 92, 77, 232, 226, 141, 7, 245, 241, 158, 73, 79, 99, 112]) }, { logicalIndex := 11, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 11, digest := (bytes [115, 116, 77, 106, 67, 232, 252, 146, 254, 38, 128, 153, 91, 223, 186, 248, 84, 234, 139, 247, 166, 27, 192, 52, 214, 24, 163, 76, 113, 87, 73, 143]) }, { logicalIndex := 12, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 12, digest := (bytes [151, 66, 233, 32, 5, 102, 244, 23, 80, 146, 192, 205, 244, 38, 63, 33, 134, 114, 135, 193, 174, 45, 168, 58, 244, 117, 162, 37, 125, 67, 17, 62]) }, { logicalIndex := 13, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 13, digest := (bytes [41, 1, 15, 89, 18, 198, 149, 21, 97, 142, 177, 33, 73, 111, 64, 204, 143, 105, 217, 48, 102, 83, 246, 243, 173, 192, 38, 246, 224, 129, 45, 221]) }, { logicalIndex := 14, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 14, digest := (bytes [246, 114, 135, 161, 178, 53, 206, 202, 196, 23, 121, 2, 47, 67, 239, 255, 15, 108, 83, 19, 64, 41, 233, 11, 253, 188, 14, 168, 173, 26, 141, 186]) }, { logicalIndex := 15, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 15, digest := (bytes [79, 33, 106, 58, 58, 186, 35, 70, 104, 72, 32, 206, 250, 47, 17, 78, 164, 156, 202, 60, 4, 146, 2, 224, 119, 5, 201, 23, 142, 93, 70, 32]) }, { logicalIndex := 16, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 16, digest := (bytes [211, 34, 171, 22, 120, 105, 79, 121, 69, 20, 10, 127, 162, 66, 130, 188, 210, 78, 27, 72, 237, 50, 100, 77, 221, 113, 39, 105, 3, 213, 42, 194]) }, { logicalIndex := 17, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 17, digest := (bytes [60, 116, 47, 157, 204, 40, 115, 180, 217, 145, 21, 136, 79, 49, 254, 121, 95, 213, 49, 82, 223, 81, 194, 204, 134, 195, 0, 211, 19, 86, 61, 237]) }, { logicalIndex := 18, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 18, digest := (bytes [119, 226, 246, 158, 218, 188, 209, 157, 129, 189, 208, 34, 161, 104, 149, 56, 200, 191, 153, 38, 201, 203, 147, 192, 166, 54, 208, 235, 159, 89, 230, 186]) }, { logicalIndex := 19, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 19, digest := (bytes [36, 56, 152, 150, 197, 106, 152, 50, 184, 7, 202, 30, 2, 107, 151, 112, 42, 108, 53, 20, 127, 122, 215, 160, 56, 16, 143, 203, 177, 54, 117, 157]) }, { logicalIndex := 20, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 20, digest := (bytes [175, 161, 152, 169, 212, 44, 28, 237, 62, 161, 111, 36, 225, 238, 175, 168, 126, 124, 94, 199, 102, 84, 6, 23, 22, 110, 134, 97, 27, 99, 119, 51]) }, { logicalIndex := 21, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 21, digest := (bytes [107, 33, 148, 18, 57, 24, 111, 169, 130, 203, 225, 98, 31, 93, 70, 167, 54, 179, 109, 13, 53, 193, 215, 160, 26, 47, 50, 80, 219, 201, 236, 86]) }, { logicalIndex := 22, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 22, digest := (bytes [205, 165, 144, 36, 117, 252, 55, 216, 225, 56, 59, 30, 32, 152, 100, 14, 73, 89, 105, 6, 40, 16, 250, 86, 54, 14, 59, 23, 209, 50, 12, 145]) }, { logicalIndex := 23, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 23, digest := (bytes [144, 13, 76, 31, 18, 82, 10, 229, 180, 194, 78, 46, 24, 135, 133, 58, 218, 200, 164, 32, 187, 49, 130, 195, 240, 89, 13, 127, 75, 85, 61, 83]) }, { logicalIndex := 24, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 24, digest := (bytes [55, 9, 133, 133, 236, 94, 107, 93, 187, 23, 107, 33, 32, 52, 166, 77, 230, 118, 77, 174, 42, 199, 76, 188, 8, 251, 22, 242, 79, 248, 96, 36]) }, { logicalIndex := 25, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 25, digest := (bytes [184, 2, 230, 66, 121, 227, 199, 165, 233, 126, 60, 5, 105, 80, 187, 89, 63, 227, 96, 93, 147, 5, 90, 100, 170, 188, 210, 92, 89, 136, 139, 91]) }, { logicalIndex := 26, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 26, digest := (bytes [186, 89, 149, 14, 226, 103, 20, 141, 27, 245, 104, 229, 151, 236, 225, 46, 26, 205, 77, 237, 207, 9, 69, 41, 84, 242, 229, 169, 211, 222, 151, 252]) }, { logicalIndex := 27, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 27, digest := (bytes [208, 31, 174, 213, 242, 147, 69, 105, 32, 112, 74, 113, 87, 34, 254, 122, 119, 11, 29, 140, 61, 224, 171, 148, 149, 64, 215, 159, 139, 154, 156, 136]) }, { logicalIndex := 28, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 28, digest := (bytes [45, 72, 46, 205, 6, 43, 60, 210, 0, 42, 204, 59, 73, 189, 105, 129, 157, 7, 70, 114, 191, 132, 14, 19, 88, 15, 246, 110, 73, 20, 129, 1]) }]

def rootExecutionRowLocalCcsAcceptance : List RootRowLocalCcsAcceptanceView :=
  [{ traceIndex := 0, logicalIndex := 0, rowDigest := (bytes [15, 203, 82, 147, 182, 107, 150, 168, 159, 107, 204, 115, 170, 200, 12, 67, 125, 81, 225, 219, 175, 26, 58, 39, 55, 35, 134, 130, 62, 126, 3, 37]), rowOpeningDigest := (bytes [45, 161, 238, 241, 198, 238, 221, 31, 180, 58, 220, 162, 22, 61, 238, 251, 249, 195, 29, 205, 227, 246, 79, 201, 151, 86, 233, 105, 224, 236, 143, 125]), preparedStepBindingDigest := (bytes [196, 127, 115, 228, 145, 235, 105, 203, 91, 30, 41, 234, 216, 138, 118, 223, 152, 13, 133, 59, 128, 32, 23, 132, 0, 186, 217, 35, 34, 46, 143, 135]), rowChunkRouteDigest := (bytes [138, 198, 109, 126, 144, 82, 221, 43, 248, 202, 137, 103, 62, 226, 249, 152, 163, 187, 1, 254, 36, 33, 59, 16, 64, 166, 202, 8, 219, 57, 240, 59]), publicStepDigest := (bytes [193, 37, 92, 24, 187, 176, 90, 242, 63, 61, 191, 129, 205, 1, 88, 178, 30, 47, 113, 40, 68, 36, 220, 38, 178, 165, 68, 84, 227, 170, 20, 136]), digest := (bytes [156, 156, 155, 41, 158, 85, 226, 133, 159, 253, 176, 119, 137, 19, 137, 181, 80, 20, 157, 220, 131, 119, 99, 249, 54, 139, 22, 246, 175, 115, 255, 169]) }, { traceIndex := 1, logicalIndex := 1, rowDigest := (bytes [60, 215, 205, 5, 39, 54, 187, 203, 122, 19, 181, 4, 207, 239, 83, 130, 97, 87, 236, 195, 81, 5, 54, 170, 123, 142, 70, 92, 18, 71, 210, 101]), rowOpeningDigest := (bytes [104, 42, 149, 156, 47, 166, 5, 20, 4, 43, 116, 17, 15, 4, 132, 168, 152, 128, 216, 129, 33, 49, 90, 31, 217, 102, 199, 127, 220, 42, 199, 231]), preparedStepBindingDigest := (bytes [0, 254, 8, 79, 59, 114, 109, 146, 23, 15, 216, 107, 171, 8, 193, 37, 127, 32, 182, 209, 172, 8, 154, 103, 229, 122, 197, 165, 217, 204, 197, 239]), rowChunkRouteDigest := (bytes [44, 177, 82, 41, 218, 60, 100, 208, 26, 31, 151, 113, 109, 148, 57, 12, 223, 21, 76, 221, 70, 245, 191, 105, 57, 199, 8, 128, 181, 145, 89, 99]), publicStepDigest := (bytes [236, 217, 27, 253, 146, 72, 34, 10, 6, 80, 72, 237, 181, 64, 76, 49, 42, 47, 138, 142, 12, 255, 130, 64, 134, 154, 100, 118, 71, 221, 155, 251]), digest := (bytes [142, 147, 55, 222, 15, 212, 191, 214, 138, 53, 112, 164, 78, 194, 204, 223, 3, 247, 12, 183, 207, 119, 111, 59, 34, 61, 130, 218, 165, 166, 80, 171]) }, { traceIndex := 2, logicalIndex := 2, rowDigest := (bytes [234, 210, 6, 75, 123, 215, 192, 55, 102, 167, 88, 17, 211, 123, 119, 187, 62, 221, 213, 145, 171, 56, 145, 138, 7, 216, 31, 70, 22, 159, 13, 227]), rowOpeningDigest := (bytes [108, 67, 6, 5, 19, 147, 107, 135, 248, 219, 112, 97, 254, 142, 187, 94, 163, 27, 83, 247, 104, 224, 121, 135, 210, 151, 115, 52, 144, 133, 58, 162]), preparedStepBindingDigest := (bytes [135, 20, 39, 193, 36, 204, 146, 160, 15, 213, 4, 70, 122, 160, 105, 102, 201, 123, 227, 203, 211, 48, 150, 49, 244, 14, 201, 29, 67, 181, 0, 229]), rowChunkRouteDigest := (bytes [252, 248, 65, 24, 81, 241, 150, 170, 250, 116, 222, 30, 134, 191, 78, 195, 104, 119, 225, 210, 243, 186, 212, 107, 183, 31, 243, 201, 101, 148, 32, 72]), publicStepDigest := (bytes [234, 224, 86, 28, 29, 15, 94, 144, 172, 104, 204, 41, 123, 162, 176, 16, 198, 115, 90, 141, 59, 140, 78, 147, 231, 119, 19, 137, 152, 211, 180, 58]), digest := (bytes [166, 111, 57, 22, 220, 175, 69, 160, 99, 120, 143, 17, 180, 119, 125, 36, 52, 110, 158, 231, 216, 124, 76, 72, 205, 126, 109, 91, 164, 184, 14, 162]) }, { traceIndex := 3, logicalIndex := 3, rowDigest := (bytes [65, 249, 157, 11, 211, 22, 178, 35, 126, 90, 217, 122, 86, 6, 98, 56, 162, 126, 166, 245, 230, 152, 213, 66, 154, 215, 167, 61, 24, 253, 6, 65]), rowOpeningDigest := (bytes [163, 171, 238, 234, 63, 49, 20, 0, 37, 42, 138, 105, 240, 183, 43, 5, 229, 100, 254, 43, 31, 159, 70, 147, 102, 184, 56, 255, 251, 191, 85, 99]), preparedStepBindingDigest := (bytes [60, 115, 87, 171, 60, 35, 12, 17, 85, 133, 80, 196, 74, 54, 8, 39, 95, 60, 47, 125, 220, 65, 47, 161, 75, 135, 129, 96, 79, 31, 71, 64]), rowChunkRouteDigest := (bytes [244, 11, 162, 13, 59, 43, 232, 47, 228, 2, 70, 126, 95, 10, 57, 40, 46, 107, 197, 81, 97, 39, 185, 163, 93, 60, 5, 66, 7, 231, 199, 134]), publicStepDigest := (bytes [1, 14, 51, 172, 24, 168, 217, 150, 155, 179, 29, 38, 113, 124, 12, 207, 242, 224, 162, 128, 181, 70, 159, 98, 142, 53, 38, 32, 221, 119, 4, 200]), digest := (bytes [158, 150, 203, 237, 190, 89, 205, 156, 25, 254, 216, 32, 192, 214, 31, 39, 185, 127, 255, 85, 61, 87, 172, 223, 90, 126, 195, 122, 237, 139, 39, 160]) }, { traceIndex := 4, logicalIndex := 4, rowDigest := (bytes [5, 188, 109, 109, 12, 189, 183, 15, 65, 224, 200, 252, 72, 66, 253, 216, 12, 180, 201, 18, 189, 217, 69, 205, 220, 76, 137, 88, 85, 5, 73, 175]), rowOpeningDigest := (bytes [109, 244, 103, 115, 60, 54, 209, 49, 16, 150, 64, 84, 31, 175, 235, 79, 254, 193, 57, 72, 133, 88, 172, 205, 168, 248, 224, 192, 85, 84, 177, 216]), preparedStepBindingDigest := (bytes [101, 37, 166, 90, 81, 113, 151, 115, 176, 55, 21, 227, 97, 32, 103, 5, 78, 185, 217, 114, 168, 93, 188, 106, 227, 177, 169, 55, 122, 243, 169, 196]), rowChunkRouteDigest := (bytes [98, 247, 204, 83, 252, 219, 248, 73, 49, 206, 229, 79, 169, 242, 28, 56, 7, 100, 18, 197, 133, 200, 133, 20, 161, 230, 126, 175, 98, 0, 158, 25]), publicStepDigest := (bytes [6, 241, 152, 74, 78, 254, 152, 193, 205, 93, 194, 234, 5, 178, 127, 199, 122, 244, 39, 79, 88, 168, 255, 173, 51, 123, 7, 3, 136, 238, 91, 231]), digest := (bytes [144, 69, 253, 31, 189, 20, 171, 136, 100, 63, 232, 176, 151, 4, 150, 218, 27, 142, 116, 22, 143, 65, 215, 68, 3, 131, 38, 23, 176, 131, 235, 236]) }, { traceIndex := 5, logicalIndex := 5, rowDigest := (bytes [203, 187, 38, 132, 54, 47, 238, 25, 245, 166, 17, 232, 148, 88, 7, 85, 228, 101, 33, 46, 72, 175, 19, 207, 221, 139, 136, 138, 8, 147, 208, 92]), rowOpeningDigest := (bytes [99, 168, 114, 146, 67, 82, 73, 248, 0, 140, 246, 241, 181, 193, 62, 27, 159, 246, 192, 164, 237, 22, 97, 5, 72, 215, 123, 215, 95, 214, 133, 240]), preparedStepBindingDigest := (bytes [46, 217, 235, 86, 53, 49, 64, 92, 149, 99, 129, 130, 131, 81, 170, 99, 88, 224, 44, 8, 11, 215, 13, 175, 103, 31, 197, 104, 155, 205, 101, 209]), rowChunkRouteDigest := (bytes [108, 248, 244, 125, 120, 190, 11, 202, 47, 205, 44, 110, 48, 43, 171, 224, 142, 98, 82, 106, 183, 21, 141, 205, 208, 18, 234, 19, 43, 61, 139, 151]), publicStepDigest := (bytes [29, 245, 36, 93, 39, 132, 17, 66, 134, 241, 114, 152, 62, 210, 142, 64, 213, 165, 141, 49, 185, 207, 180, 0, 49, 219, 100, 206, 210, 41, 184, 73]), digest := (bytes [83, 251, 114, 245, 92, 170, 236, 50, 70, 79, 247, 158, 18, 218, 78, 144, 161, 172, 173, 226, 236, 183, 65, 70, 141, 165, 1, 249, 234, 1, 57, 240]) }, { traceIndex := 6, logicalIndex := 6, rowDigest := (bytes [233, 166, 25, 231, 225, 27, 180, 155, 246, 201, 194, 117, 252, 224, 156, 252, 246, 21, 189, 110, 206, 191, 63, 239, 114, 70, 42, 116, 160, 96, 111, 30]), rowOpeningDigest := (bytes [241, 127, 139, 88, 1, 193, 51, 102, 185, 93, 41, 32, 184, 142, 43, 195, 19, 34, 251, 92, 5, 153, 163, 57, 150, 190, 179, 28, 116, 23, 192, 100]), preparedStepBindingDigest := (bytes [29, 53, 226, 48, 18, 54, 210, 123, 145, 16, 39, 215, 46, 150, 209, 66, 255, 214, 248, 236, 157, 238, 192, 225, 237, 130, 58, 41, 80, 93, 10, 253]), rowChunkRouteDigest := (bytes [213, 163, 43, 1, 32, 112, 128, 155, 10, 34, 241, 205, 79, 46, 234, 45, 239, 83, 213, 254, 45, 65, 13, 152, 217, 78, 36, 105, 42, 193, 181, 13]), publicStepDigest := (bytes [209, 47, 242, 158, 15, 5, 129, 10, 54, 205, 95, 5, 49, 89, 208, 184, 152, 72, 250, 50, 219, 27, 103, 168, 11, 7, 252, 166, 129, 36, 182, 82]), digest := (bytes [142, 156, 185, 64, 28, 126, 69, 68, 245, 35, 195, 134, 236, 113, 242, 127, 57, 87, 14, 224, 153, 98, 146, 86, 153, 85, 186, 46, 214, 108, 156, 92]) }, { traceIndex := 7, logicalIndex := 7, rowDigest := (bytes [182, 232, 106, 215, 202, 126, 234, 142, 167, 155, 209, 183, 156, 95, 19, 192, 47, 97, 22, 38, 70, 60, 174, 217, 79, 199, 17, 248, 52, 56, 40, 37]), rowOpeningDigest := (bytes [211, 136, 186, 167, 132, 33, 226, 65, 96, 98, 88, 159, 63, 151, 157, 230, 168, 101, 14, 117, 233, 231, 244, 236, 54, 144, 63, 70, 194, 196, 202, 38]), preparedStepBindingDigest := (bytes [106, 15, 90, 142, 228, 22, 167, 202, 104, 76, 19, 100, 3, 24, 121, 177, 235, 236, 165, 152, 126, 94, 228, 123, 229, 23, 154, 236, 141, 79, 23, 242]), rowChunkRouteDigest := (bytes [199, 10, 5, 135, 58, 125, 195, 205, 65, 103, 137, 179, 210, 215, 124, 50, 45, 181, 46, 62, 43, 114, 240, 192, 142, 94, 31, 202, 153, 102, 209, 54]), publicStepDigest := (bytes [132, 152, 180, 181, 130, 190, 239, 195, 170, 79, 191, 237, 56, 162, 73, 132, 131, 179, 76, 38, 155, 215, 200, 68, 77, 0, 5, 237, 251, 108, 171, 25]), digest := (bytes [17, 244, 13, 160, 199, 131, 233, 110, 242, 246, 79, 79, 168, 31, 56, 224, 194, 100, 139, 16, 185, 62, 97, 56, 39, 78, 90, 120, 85, 13, 196, 175]) }, { traceIndex := 8, logicalIndex := 8, rowDigest := (bytes [108, 83, 91, 238, 228, 103, 102, 176, 31, 203, 62, 17, 94, 17, 86, 174, 92, 53, 163, 93, 174, 237, 47, 238, 174, 140, 185, 114, 28, 183, 239, 13]), rowOpeningDigest := (bytes [58, 96, 252, 191, 37, 6, 215, 128, 115, 182, 135, 208, 87, 142, 34, 247, 183, 190, 157, 222, 50, 92, 138, 150, 94, 93, 32, 88, 42, 11, 240, 136]), preparedStepBindingDigest := (bytes [231, 156, 236, 58, 138, 7, 35, 114, 64, 133, 231, 42, 246, 241, 98, 92, 109, 25, 247, 254, 165, 93, 187, 39, 64, 29, 131, 168, 158, 46, 14, 107]), rowChunkRouteDigest := (bytes [243, 104, 100, 66, 94, 61, 218, 185, 138, 159, 201, 38, 53, 64, 18, 187, 81, 105, 239, 11, 139, 137, 248, 62, 130, 187, 188, 172, 131, 72, 106, 73]), publicStepDigest := (bytes [187, 3, 122, 174, 10, 173, 71, 220, 42, 228, 173, 11, 201, 192, 112, 200, 58, 4, 65, 224, 134, 5, 78, 117, 227, 34, 39, 194, 148, 180, 167, 116]), digest := (bytes [184, 122, 159, 68, 168, 4, 202, 102, 65, 193, 52, 149, 164, 165, 236, 27, 14, 178, 105, 83, 53, 175, 22, 61, 254, 203, 88, 145, 93, 230, 253, 181]) }, { traceIndex := 9, logicalIndex := 9, rowDigest := (bytes [108, 236, 183, 209, 126, 5, 80, 10, 119, 222, 68, 29, 162, 149, 38, 169, 124, 53, 135, 138, 24, 146, 3, 1, 141, 219, 5, 244, 117, 90, 162, 76]), rowOpeningDigest := (bytes [10, 99, 238, 158, 124, 34, 23, 117, 218, 238, 194, 208, 241, 27, 183, 89, 52, 237, 226, 7, 198, 21, 175, 95, 197, 118, 149, 104, 161, 214, 252, 112]), preparedStepBindingDigest := (bytes [153, 248, 112, 176, 139, 43, 160, 136, 128, 19, 111, 11, 12, 249, 212, 168, 146, 205, 144, 135, 139, 135, 214, 168, 137, 199, 186, 148, 246, 115, 254, 150]), rowChunkRouteDigest := (bytes [11, 164, 4, 249, 84, 107, 210, 66, 134, 110, 223, 149, 172, 176, 94, 254, 45, 42, 247, 93, 171, 29, 160, 56, 115, 52, 76, 84, 241, 17, 162, 122]), publicStepDigest := (bytes [223, 55, 102, 109, 37, 172, 32, 139, 178, 120, 189, 72, 226, 111, 134, 45, 140, 143, 247, 128, 220, 185, 93, 44, 211, 211, 231, 53, 232, 175, 57, 168]), digest := (bytes [86, 56, 171, 11, 227, 53, 249, 210, 16, 101, 224, 123, 230, 152, 23, 143, 60, 124, 157, 41, 142, 149, 77, 153, 0, 8, 27, 204, 216, 27, 184, 181]) }, { traceIndex := 10, logicalIndex := 10, rowDigest := (bytes [239, 83, 168, 7, 178, 9, 84, 59, 37, 164, 102, 44, 110, 160, 202, 170, 150, 73, 194, 127, 151, 252, 9, 16, 134, 170, 176, 116, 186, 172, 99, 209]), rowOpeningDigest := (bytes [239, 101, 77, 177, 93, 51, 202, 117, 153, 100, 193, 18, 79, 8, 28, 153, 233, 13, 227, 42, 186, 177, 115, 126, 30, 207, 229, 162, 57, 189, 14, 15]), preparedStepBindingDigest := (bytes [252, 42, 71, 185, 29, 217, 106, 230, 161, 152, 122, 167, 46, 178, 244, 100, 89, 151, 96, 238, 137, 165, 207, 211, 246, 44, 245, 0, 4, 181, 209, 140]), rowChunkRouteDigest := (bytes [163, 19, 52, 250, 55, 230, 68, 230, 28, 108, 101, 226, 50, 126, 176, 29, 159, 73, 227, 92, 77, 232, 226, 141, 7, 245, 241, 158, 73, 79, 99, 112]), publicStepDigest := (bytes [233, 56, 105, 231, 20, 85, 142, 180, 26, 28, 176, 229, 237, 31, 102, 101, 48, 210, 164, 204, 55, 118, 175, 6, 41, 51, 7, 37, 149, 63, 254, 118]), digest := (bytes [139, 21, 240, 249, 179, 200, 91, 117, 90, 165, 150, 202, 36, 66, 0, 107, 56, 190, 191, 230, 138, 162, 64, 98, 214, 59, 75, 23, 31, 125, 17, 215]) }, { traceIndex := 11, logicalIndex := 11, rowDigest := (bytes [96, 125, 2, 85, 205, 238, 154, 207, 237, 21, 160, 105, 158, 49, 1, 246, 221, 196, 150, 49, 30, 36, 120, 127, 129, 16, 56, 208, 29, 106, 114, 183]), rowOpeningDigest := (bytes [134, 0, 3, 239, 55, 153, 96, 151, 191, 102, 63, 88, 67, 42, 170, 195, 228, 30, 192, 43, 190, 237, 152, 235, 29, 157, 225, 147, 246, 25, 11, 102]), preparedStepBindingDigest := (bytes [250, 202, 190, 200, 71, 238, 137, 43, 217, 25, 41, 69, 44, 117, 155, 2, 26, 60, 33, 18, 136, 37, 142, 5, 239, 33, 191, 25, 88, 86, 236, 169]), rowChunkRouteDigest := (bytes [115, 116, 77, 106, 67, 232, 252, 146, 254, 38, 128, 153, 91, 223, 186, 248, 84, 234, 139, 247, 166, 27, 192, 52, 214, 24, 163, 76, 113, 87, 73, 143]), publicStepDigest := (bytes [21, 54, 67, 10, 2, 141, 39, 26, 198, 113, 133, 154, 25, 109, 18, 2, 71, 133, 213, 42, 106, 23, 61, 186, 223, 77, 224, 39, 185, 170, 8, 58]), digest := (bytes [134, 114, 86, 126, 60, 56, 188, 18, 17, 242, 128, 91, 27, 13, 6, 34, 46, 121, 167, 185, 35, 102, 35, 198, 33, 78, 108, 95, 53, 51, 173, 215]) }, { traceIndex := 12, logicalIndex := 12, rowDigest := (bytes [153, 198, 105, 125, 50, 184, 161, 62, 58, 197, 108, 63, 123, 87, 40, 13, 112, 208, 43, 70, 48, 116, 252, 150, 34, 22, 164, 54, 223, 72, 103, 21]), rowOpeningDigest := (bytes [206, 41, 179, 151, 171, 189, 188, 51, 236, 2, 83, 158, 92, 155, 73, 86, 57, 23, 130, 178, 6, 98, 171, 132, 80, 83, 17, 15, 60, 13, 158, 194]), preparedStepBindingDigest := (bytes [43, 165, 115, 225, 22, 64, 11, 233, 223, 106, 242, 232, 98, 23, 72, 183, 169, 127, 186, 62, 160, 224, 201, 244, 95, 0, 156, 103, 161, 44, 250, 2]), rowChunkRouteDigest := (bytes [151, 66, 233, 32, 5, 102, 244, 23, 80, 146, 192, 205, 244, 38, 63, 33, 134, 114, 135, 193, 174, 45, 168, 58, 244, 117, 162, 37, 125, 67, 17, 62]), publicStepDigest := (bytes [59, 213, 30, 142, 244, 61, 145, 71, 192, 107, 204, 4, 108, 78, 126, 39, 62, 194, 187, 86, 137, 59, 49, 1, 214, 189, 112, 153, 50, 246, 83, 76]), digest := (bytes [148, 16, 150, 78, 164, 17, 199, 197, 177, 187, 85, 110, 132, 146, 5, 253, 68, 172, 237, 121, 79, 163, 249, 131, 10, 206, 199, 119, 76, 43, 99, 223]) }, { traceIndex := 13, logicalIndex := 13, rowDigest := (bytes [18, 145, 34, 20, 195, 164, 234, 231, 212, 120, 2, 175, 127, 120, 243, 76, 250, 108, 14, 150, 248, 44, 32, 156, 134, 80, 103, 4, 253, 63, 36, 12]), rowOpeningDigest := (bytes [188, 151, 192, 185, 49, 214, 22, 68, 74, 26, 196, 96, 144, 88, 242, 49, 42, 165, 200, 156, 195, 201, 33, 123, 72, 117, 119, 205, 222, 4, 64, 99]), preparedStepBindingDigest := (bytes [37, 175, 91, 93, 45, 175, 62, 80, 210, 34, 77, 91, 41, 37, 204, 225, 252, 39, 3, 217, 174, 179, 205, 91, 239, 120, 141, 200, 105, 128, 133, 228]), rowChunkRouteDigest := (bytes [41, 1, 15, 89, 18, 198, 149, 21, 97, 142, 177, 33, 73, 111, 64, 204, 143, 105, 217, 48, 102, 83, 246, 243, 173, 192, 38, 246, 224, 129, 45, 221]), publicStepDigest := (bytes [248, 226, 79, 38, 26, 255, 65, 252, 107, 98, 215, 51, 193, 111, 34, 194, 206, 67, 199, 248, 80, 229, 124, 52, 189, 40, 44, 130, 138, 37, 79, 111]), digest := (bytes [106, 161, 161, 33, 227, 253, 56, 144, 54, 123, 221, 140, 114, 226, 226, 29, 16, 196, 174, 29, 76, 205, 235, 25, 62, 222, 161, 67, 205, 98, 5, 167]) }, { traceIndex := 14, logicalIndex := 14, rowDigest := (bytes [92, 206, 44, 178, 19, 66, 44, 254, 104, 252, 200, 245, 46, 89, 244, 37, 10, 62, 102, 48, 162, 176, 186, 12, 24, 220, 158, 22, 59, 176, 167, 8]), rowOpeningDigest := (bytes [92, 177, 140, 7, 191, 27, 72, 59, 194, 166, 149, 9, 17, 136, 27, 249, 14, 21, 16, 76, 187, 90, 146, 91, 43, 80, 216, 120, 123, 209, 124, 87]), preparedStepBindingDigest := (bytes [235, 80, 228, 103, 26, 224, 215, 213, 212, 112, 29, 125, 161, 70, 106, 186, 190, 160, 79, 78, 195, 103, 144, 25, 110, 31, 76, 13, 3, 161, 196, 63]), rowChunkRouteDigest := (bytes [246, 114, 135, 161, 178, 53, 206, 202, 196, 23, 121, 2, 47, 67, 239, 255, 15, 108, 83, 19, 64, 41, 233, 11, 253, 188, 14, 168, 173, 26, 141, 186]), publicStepDigest := (bytes [179, 175, 223, 127, 94, 70, 50, 158, 248, 6, 220, 0, 246, 87, 218, 56, 173, 97, 235, 21, 50, 212, 238, 169, 243, 189, 86, 119, 176, 86, 241, 42]), digest := (bytes [101, 9, 194, 180, 29, 20, 192, 228, 209, 189, 34, 151, 83, 84, 245, 44, 84, 158, 201, 255, 93, 229, 85, 158, 69, 61, 54, 141, 149, 4, 73, 12]) }, { traceIndex := 15, logicalIndex := 15, rowDigest := (bytes [80, 18, 238, 187, 77, 110, 104, 248, 24, 180, 69, 117, 29, 193, 25, 93, 78, 140, 82, 141, 103, 181, 78, 134, 24, 108, 24, 134, 101, 3, 27, 163]), rowOpeningDigest := (bytes [224, 177, 126, 88, 199, 156, 146, 22, 16, 74, 90, 173, 142, 119, 248, 25, 92, 21, 241, 17, 132, 36, 197, 102, 93, 99, 15, 161, 239, 129, 171, 62]), preparedStepBindingDigest := (bytes [33, 235, 216, 195, 247, 160, 99, 149, 109, 234, 63, 7, 71, 98, 110, 252, 184, 249, 179, 196, 196, 76, 56, 30, 219, 179, 18, 197, 240, 109, 79, 243]), rowChunkRouteDigest := (bytes [79, 33, 106, 58, 58, 186, 35, 70, 104, 72, 32, 206, 250, 47, 17, 78, 164, 156, 202, 60, 4, 146, 2, 224, 119, 5, 201, 23, 142, 93, 70, 32]), publicStepDigest := (bytes [129, 186, 188, 57, 62, 175, 27, 96, 34, 244, 37, 188, 239, 0, 187, 15, 187, 26, 61, 226, 92, 117, 169, 157, 185, 49, 128, 162, 137, 135, 47, 16]), digest := (bytes [181, 64, 246, 68, 29, 225, 234, 63, 53, 133, 203, 79, 141, 210, 148, 162, 65, 177, 254, 146, 220, 136, 149, 15, 75, 200, 45, 43, 120, 114, 230, 162]) }, { traceIndex := 16, logicalIndex := 16, rowDigest := (bytes [3, 60, 2, 136, 126, 60, 95, 89, 237, 139, 230, 198, 12, 27, 158, 210, 126, 220, 0, 66, 184, 126, 170, 60, 44, 113, 235, 237, 127, 19, 158, 235]), rowOpeningDigest := (bytes [101, 72, 204, 222, 183, 188, 171, 126, 67, 130, 83, 231, 216, 33, 47, 25, 41, 23, 106, 249, 76, 234, 58, 49, 135, 204, 235, 170, 26, 24, 61, 160]), preparedStepBindingDigest := (bytes [2, 219, 133, 56, 196, 251, 194, 17, 236, 27, 178, 68, 44, 148, 242, 33, 39, 66, 44, 198, 183, 230, 214, 214, 43, 106, 247, 89, 89, 73, 234, 1]), rowChunkRouteDigest := (bytes [211, 34, 171, 22, 120, 105, 79, 121, 69, 20, 10, 127, 162, 66, 130, 188, 210, 78, 27, 72, 237, 50, 100, 77, 221, 113, 39, 105, 3, 213, 42, 194]), publicStepDigest := (bytes [83, 196, 3, 4, 191, 54, 233, 167, 152, 9, 15, 76, 63, 170, 190, 214, 143, 172, 54, 25, 232, 196, 59, 251, 250, 96, 202, 100, 126, 82, 185, 248]), digest := (bytes [91, 162, 2, 224, 36, 181, 55, 117, 162, 50, 226, 75, 178, 8, 40, 199, 206, 226, 242, 168, 59, 109, 45, 28, 71, 147, 106, 138, 84, 167, 203, 236]) }, { traceIndex := 17, logicalIndex := 17, rowDigest := (bytes [249, 190, 82, 196, 202, 11, 70, 179, 40, 235, 54, 245, 123, 4, 16, 211, 191, 180, 138, 95, 189, 197, 0, 43, 3, 65, 134, 177, 151, 230, 41, 161]), rowOpeningDigest := (bytes [124, 203, 46, 89, 234, 186, 2, 249, 11, 133, 115, 1, 94, 162, 140, 65, 24, 120, 245, 24, 36, 5, 51, 82, 177, 23, 56, 162, 7, 85, 163, 244]), preparedStepBindingDigest := (bytes [237, 72, 157, 178, 170, 209, 31, 81, 70, 177, 213, 254, 119, 180, 18, 50, 182, 213, 168, 64, 48, 82, 27, 14, 29, 179, 74, 237, 186, 77, 167, 253]), rowChunkRouteDigest := (bytes [60, 116, 47, 157, 204, 40, 115, 180, 217, 145, 21, 136, 79, 49, 254, 121, 95, 213, 49, 82, 223, 81, 194, 204, 134, 195, 0, 211, 19, 86, 61, 237]), publicStepDigest := (bytes [228, 145, 93, 134, 250, 15, 253, 165, 113, 210, 59, 248, 135, 168, 123, 72, 142, 183, 176, 118, 87, 54, 136, 93, 134, 102, 33, 95, 49, 143, 128, 115]), digest := (bytes [69, 223, 163, 118, 201, 36, 91, 59, 19, 241, 71, 80, 154, 199, 247, 76, 18, 11, 43, 117, 55, 114, 147, 86, 137, 75, 252, 114, 131, 229, 19, 176]) }, { traceIndex := 18, logicalIndex := 18, rowDigest := (bytes [43, 52, 173, 127, 231, 252, 165, 229, 216, 76, 36, 175, 230, 60, 16, 30, 215, 105, 212, 189, 152, 82, 64, 250, 53, 182, 107, 61, 61, 121, 172, 111]), rowOpeningDigest := (bytes [164, 14, 206, 42, 110, 168, 54, 197, 101, 234, 101, 4, 237, 189, 222, 94, 178, 214, 141, 232, 143, 93, 246, 174, 155, 21, 251, 191, 46, 157, 178, 191]), preparedStepBindingDigest := (bytes [191, 58, 14, 98, 131, 172, 108, 55, 57, 60, 200, 47, 47, 67, 30, 190, 119, 135, 48, 28, 73, 90, 52, 224, 230, 71, 199, 160, 196, 190, 60, 50]), rowChunkRouteDigest := (bytes [119, 226, 246, 158, 218, 188, 209, 157, 129, 189, 208, 34, 161, 104, 149, 56, 200, 191, 153, 38, 201, 203, 147, 192, 166, 54, 208, 235, 159, 89, 230, 186]), publicStepDigest := (bytes [80, 43, 151, 162, 33, 9, 64, 167, 26, 5, 106, 178, 229, 12, 164, 154, 183, 8, 11, 231, 61, 40, 128, 248, 198, 91, 242, 154, 234, 231, 33, 65]), digest := (bytes [223, 42, 132, 101, 51, 37, 121, 7, 30, 249, 44, 69, 251, 206, 82, 249, 109, 112, 1, 156, 206, 228, 134, 130, 243, 243, 182, 254, 207, 116, 100, 31]) }, { traceIndex := 19, logicalIndex := 19, rowDigest := (bytes [226, 223, 249, 52, 202, 180, 31, 236, 69, 187, 172, 19, 2, 217, 37, 36, 13, 72, 27, 43, 3, 242, 194, 182, 118, 207, 176, 221, 212, 17, 179, 122]), rowOpeningDigest := (bytes [205, 138, 200, 124, 172, 228, 187, 10, 136, 31, 129, 4, 45, 210, 119, 90, 107, 109, 171, 19, 3, 32, 57, 66, 212, 24, 122, 238, 86, 94, 251, 56]), preparedStepBindingDigest := (bytes [102, 182, 137, 118, 211, 205, 105, 72, 254, 128, 72, 129, 223, 65, 203, 33, 118, 90, 217, 39, 29, 244, 110, 3, 5, 121, 214, 51, 39, 199, 178, 16]), rowChunkRouteDigest := (bytes [36, 56, 152, 150, 197, 106, 152, 50, 184, 7, 202, 30, 2, 107, 151, 112, 42, 108, 53, 20, 127, 122, 215, 160, 56, 16, 143, 203, 177, 54, 117, 157]), publicStepDigest := (bytes [60, 21, 177, 105, 104, 254, 99, 115, 0, 78, 65, 158, 138, 100, 152, 30, 223, 157, 130, 246, 105, 28, 199, 122, 155, 119, 167, 175, 196, 80, 59, 41]), digest := (bytes [246, 77, 168, 209, 228, 252, 196, 94, 56, 88, 65, 169, 239, 237, 244, 204, 197, 117, 224, 241, 154, 115, 222, 217, 131, 14, 215, 47, 241, 161, 219, 142]) }, { traceIndex := 20, logicalIndex := 20, rowDigest := (bytes [243, 74, 109, 28, 147, 9, 125, 238, 14, 57, 120, 137, 242, 238, 60, 216, 126, 193, 90, 121, 178, 138, 94, 247, 15, 168, 229, 20, 12, 36, 110, 36]), rowOpeningDigest := (bytes [113, 70, 120, 39, 6, 36, 196, 53, 21, 21, 122, 120, 113, 117, 2, 207, 185, 171, 186, 104, 250, 240, 190, 82, 187, 190, 72, 74, 107, 193, 195, 173]), preparedStepBindingDigest := (bytes [16, 88, 82, 90, 127, 215, 86, 150, 28, 228, 157, 96, 11, 117, 129, 70, 230, 201, 22, 94, 109, 33, 97, 164, 176, 23, 108, 52, 28, 143, 227, 9]), rowChunkRouteDigest := (bytes [175, 161, 152, 169, 212, 44, 28, 237, 62, 161, 111, 36, 225, 238, 175, 168, 126, 124, 94, 199, 102, 84, 6, 23, 22, 110, 134, 97, 27, 99, 119, 51]), publicStepDigest := (bytes [214, 188, 158, 69, 192, 112, 37, 42, 113, 16, 169, 133, 146, 31, 6, 181, 128, 150, 53, 178, 120, 45, 198, 69, 59, 139, 9, 153, 39, 224, 17, 38]), digest := (bytes [124, 177, 0, 189, 106, 179, 63, 43, 6, 223, 143, 57, 113, 131, 191, 26, 199, 156, 80, 135, 167, 139, 102, 173, 44, 206, 51, 9, 152, 160, 187, 96]) }, { traceIndex := 21, logicalIndex := 21, rowDigest := (bytes [215, 249, 136, 180, 67, 12, 57, 40, 198, 173, 116, 97, 234, 252, 17, 154, 253, 238, 142, 159, 175, 87, 179, 216, 157, 91, 208, 156, 126, 17, 253, 58]), rowOpeningDigest := (bytes [7, 149, 64, 67, 162, 83, 226, 161, 120, 122, 99, 116, 29, 230, 74, 60, 240, 203, 163, 49, 141, 134, 201, 136, 241, 195, 133, 94, 221, 223, 200, 131]), preparedStepBindingDigest := (bytes [42, 5, 21, 56, 61, 20, 168, 207, 214, 33, 12, 156, 116, 19, 0, 224, 170, 206, 33, 83, 33, 63, 14, 45, 241, 75, 37, 45, 181, 234, 234, 16]), rowChunkRouteDigest := (bytes [107, 33, 148, 18, 57, 24, 111, 169, 130, 203, 225, 98, 31, 93, 70, 167, 54, 179, 109, 13, 53, 193, 215, 160, 26, 47, 50, 80, 219, 201, 236, 86]), publicStepDigest := (bytes [174, 203, 235, 188, 172, 16, 167, 38, 31, 11, 118, 231, 201, 103, 183, 232, 131, 148, 138, 138, 254, 135, 80, 41, 211, 174, 255, 94, 91, 172, 217, 73]), digest := (bytes [180, 153, 210, 204, 109, 77, 144, 228, 87, 1, 185, 250, 178, 62, 33, 2, 253, 78, 47, 57, 63, 192, 115, 163, 225, 14, 77, 182, 29, 145, 73, 184]) }, { traceIndex := 22, logicalIndex := 22, rowDigest := (bytes [85, 214, 216, 191, 28, 229, 228, 16, 239, 214, 169, 98, 30, 176, 198, 57, 91, 186, 251, 84, 4, 37, 118, 153, 22, 22, 106, 68, 36, 238, 139, 55]), rowOpeningDigest := (bytes [128, 201, 59, 237, 94, 60, 249, 119, 133, 15, 31, 159, 134, 13, 41, 100, 201, 107, 38, 146, 216, 48, 61, 220, 109, 118, 224, 186, 190, 244, 117, 253]), preparedStepBindingDigest := (bytes [75, 242, 7, 92, 255, 227, 231, 31, 214, 18, 223, 107, 154, 25, 183, 127, 194, 42, 121, 34, 154, 77, 164, 205, 209, 24, 99, 10, 99, 232, 177, 41]), rowChunkRouteDigest := (bytes [205, 165, 144, 36, 117, 252, 55, 216, 225, 56, 59, 30, 32, 152, 100, 14, 73, 89, 105, 6, 40, 16, 250, 86, 54, 14, 59, 23, 209, 50, 12, 145]), publicStepDigest := (bytes [74, 210, 250, 72, 141, 87, 15, 253, 2, 76, 159, 125, 123, 172, 90, 6, 212, 0, 218, 56, 229, 235, 37, 49, 219, 63, 200, 57, 109, 86, 156, 135]), digest := (bytes [19, 75, 137, 87, 133, 237, 246, 229, 182, 178, 94, 195, 35, 247, 110, 76, 5, 241, 155, 206, 158, 107, 54, 180, 173, 91, 68, 75, 194, 240, 136, 46]) }, { traceIndex := 23, logicalIndex := 23, rowDigest := (bytes [83, 196, 28, 180, 237, 223, 82, 38, 157, 237, 214, 79, 100, 104, 36, 32, 187, 130, 1, 97, 72, 243, 149, 238, 208, 116, 114, 52, 52, 148, 169, 124]), rowOpeningDigest := (bytes [141, 78, 53, 81, 203, 64, 136, 242, 163, 111, 61, 119, 133, 213, 129, 202, 208, 209, 159, 20, 46, 115, 60, 104, 48, 228, 0, 224, 65, 106, 173, 220]), preparedStepBindingDigest := (bytes [181, 68, 113, 70, 124, 131, 94, 29, 169, 232, 141, 149, 49, 78, 71, 166, 2, 228, 138, 222, 166, 5, 89, 155, 226, 110, 20, 94, 50, 184, 49, 121]), rowChunkRouteDigest := (bytes [144, 13, 76, 31, 18, 82, 10, 229, 180, 194, 78, 46, 24, 135, 133, 58, 218, 200, 164, 32, 187, 49, 130, 195, 240, 89, 13, 127, 75, 85, 61, 83]), publicStepDigest := (bytes [56, 10, 230, 104, 107, 76, 89, 251, 24, 142, 43, 5, 73, 41, 101, 53, 31, 187, 15, 195, 201, 51, 5, 21, 139, 186, 144, 62, 183, 77, 18, 172]), digest := (bytes [252, 66, 30, 100, 230, 187, 15, 46, 99, 230, 42, 106, 64, 27, 185, 62, 118, 106, 204, 137, 38, 211, 181, 49, 124, 199, 94, 156, 12, 252, 68, 30]) }, { traceIndex := 24, logicalIndex := 24, rowDigest := (bytes [82, 17, 49, 84, 46, 121, 110, 215, 43, 64, 204, 105, 161, 63, 107, 19, 112, 132, 156, 75, 62, 62, 170, 26, 90, 199, 243, 125, 110, 96, 162, 149]), rowOpeningDigest := (bytes [123, 180, 33, 123, 122, 239, 169, 218, 170, 29, 173, 160, 80, 73, 65, 66, 115, 30, 24, 128, 166, 23, 71, 235, 214, 47, 78, 207, 150, 213, 202, 97]), preparedStepBindingDigest := (bytes [148, 245, 199, 127, 3, 0, 139, 3, 46, 192, 134, 40, 115, 34, 101, 102, 120, 45, 87, 48, 199, 148, 137, 235, 30, 137, 225, 33, 16, 161, 168, 122]), rowChunkRouteDigest := (bytes [55, 9, 133, 133, 236, 94, 107, 93, 187, 23, 107, 33, 32, 52, 166, 77, 230, 118, 77, 174, 42, 199, 76, 188, 8, 251, 22, 242, 79, 248, 96, 36]), publicStepDigest := (bytes [148, 254, 130, 118, 137, 66, 127, 238, 121, 13, 77, 105, 122, 70, 195, 67, 241, 71, 31, 153, 148, 40, 49, 56, 215, 111, 9, 237, 245, 157, 100, 163]), digest := (bytes [113, 151, 184, 118, 181, 91, 215, 6, 210, 136, 237, 234, 82, 211, 35, 66, 186, 197, 113, 201, 169, 170, 45, 74, 60, 189, 75, 243, 33, 159, 73, 194]) }, { traceIndex := 25, logicalIndex := 25, rowDigest := (bytes [138, 213, 132, 226, 17, 110, 19, 195, 174, 202, 92, 78, 73, 19, 119, 131, 254, 232, 223, 144, 82, 203, 203, 140, 142, 157, 45, 78, 221, 246, 109, 253]), rowOpeningDigest := (bytes [101, 162, 197, 194, 51, 193, 86, 137, 169, 183, 254, 95, 41, 219, 171, 178, 153, 108, 174, 27, 243, 197, 76, 127, 157, 65, 104, 201, 9, 108, 1, 204]), preparedStepBindingDigest := (bytes [247, 191, 143, 255, 26, 119, 247, 116, 193, 201, 48, 243, 127, 163, 101, 178, 238, 215, 64, 127, 186, 98, 98, 244, 138, 2, 25, 208, 87, 49, 31, 126]), rowChunkRouteDigest := (bytes [184, 2, 230, 66, 121, 227, 199, 165, 233, 126, 60, 5, 105, 80, 187, 89, 63, 227, 96, 93, 147, 5, 90, 100, 170, 188, 210, 92, 89, 136, 139, 91]), publicStepDigest := (bytes [8, 193, 202, 144, 121, 142, 204, 76, 166, 146, 213, 198, 159, 99, 140, 28, 116, 128, 109, 5, 16, 224, 62, 160, 179, 124, 104, 134, 199, 114, 5, 56]), digest := (bytes [237, 223, 25, 162, 142, 34, 206, 90, 111, 162, 104, 233, 169, 50, 93, 1, 46, 252, 77, 134, 167, 132, 143, 9, 94, 233, 99, 57, 81, 132, 138, 196]) }, { traceIndex := 26, logicalIndex := 26, rowDigest := (bytes [77, 184, 158, 212, 115, 243, 78, 243, 182, 24, 233, 243, 31, 201, 152, 166, 22, 180, 127, 214, 70, 224, 61, 51, 233, 105, 8, 162, 205, 65, 199, 157]), rowOpeningDigest := (bytes [93, 25, 196, 143, 159, 61, 233, 191, 163, 224, 2, 47, 156, 121, 41, 115, 137, 77, 55, 160, 224, 67, 17, 168, 218, 222, 110, 96, 12, 203, 16, 168]), preparedStepBindingDigest := (bytes [34, 234, 181, 238, 156, 187, 169, 107, 14, 210, 176, 12, 28, 194, 244, 221, 55, 85, 155, 195, 242, 8, 117, 145, 209, 187, 63, 214, 250, 67, 144, 38]), rowChunkRouteDigest := (bytes [186, 89, 149, 14, 226, 103, 20, 141, 27, 245, 104, 229, 151, 236, 225, 46, 26, 205, 77, 237, 207, 9, 69, 41, 84, 242, 229, 169, 211, 222, 151, 252]), publicStepDigest := (bytes [247, 10, 172, 205, 96, 237, 51, 255, 153, 236, 247, 247, 201, 200, 115, 116, 99, 137, 183, 78, 4, 214, 120, 230, 152, 123, 98, 45, 223, 114, 241, 22]), digest := (bytes [79, 39, 237, 230, 69, 26, 156, 238, 218, 24, 231, 5, 43, 223, 158, 232, 85, 190, 5, 170, 102, 76, 213, 26, 254, 47, 239, 152, 164, 66, 115, 84]) }, { traceIndex := 27, logicalIndex := 27, rowDigest := (bytes [123, 11, 210, 67, 192, 198, 179, 24, 238, 128, 249, 226, 206, 74, 13, 210, 175, 223, 180, 51, 121, 202, 63, 90, 242, 104, 199, 20, 18, 34, 157, 225]), rowOpeningDigest := (bytes [192, 168, 152, 125, 225, 160, 61, 204, 151, 99, 69, 213, 187, 51, 157, 35, 188, 224, 166, 0, 233, 112, 220, 89, 24, 205, 195, 121, 245, 118, 205, 84]), preparedStepBindingDigest := (bytes [209, 99, 245, 95, 136, 28, 186, 77, 180, 154, 92, 124, 63, 228, 177, 123, 51, 121, 82, 107, 62, 120, 146, 135, 248, 219, 24, 35, 174, 42, 63, 214]), rowChunkRouteDigest := (bytes [208, 31, 174, 213, 242, 147, 69, 105, 32, 112, 74, 113, 87, 34, 254, 122, 119, 11, 29, 140, 61, 224, 171, 148, 149, 64, 215, 159, 139, 154, 156, 136]), publicStepDigest := (bytes [114, 178, 94, 141, 69, 24, 24, 246, 216, 73, 196, 154, 203, 134, 193, 111, 154, 72, 114, 52, 174, 210, 27, 169, 199, 12, 96, 17, 163, 171, 176, 190]), digest := (bytes [64, 244, 217, 32, 255, 4, 101, 96, 150, 115, 96, 211, 35, 28, 26, 189, 4, 189, 222, 178, 169, 224, 98, 120, 57, 241, 76, 67, 18, 100, 155, 173]) }, { traceIndex := 28, logicalIndex := 28, rowDigest := (bytes [191, 59, 111, 91, 175, 174, 193, 106, 252, 237, 179, 109, 105, 90, 100, 212, 35, 239, 230, 162, 83, 17, 88, 13, 240, 150, 187, 164, 56, 114, 73, 39]), rowOpeningDigest := (bytes [180, 81, 197, 89, 123, 21, 57, 248, 239, 158, 190, 71, 240, 70, 71, 207, 10, 185, 191, 205, 239, 154, 252, 215, 220, 242, 31, 7, 28, 106, 157, 137]), preparedStepBindingDigest := (bytes [210, 164, 188, 10, 200, 87, 23, 227, 108, 94, 15, 153, 245, 204, 108, 191, 76, 213, 158, 176, 59, 20, 86, 180, 2, 103, 191, 35, 54, 77, 76, 101]), rowChunkRouteDigest := (bytes [45, 72, 46, 205, 6, 43, 60, 210, 0, 42, 204, 59, 73, 189, 105, 129, 157, 7, 70, 114, 191, 132, 14, 19, 88, 15, 246, 110, 73, 20, 129, 1]), publicStepDigest := (bytes [43, 205, 225, 49, 199, 214, 85, 211, 218, 162, 212, 148, 50, 128, 69, 219, 183, 162, 76, 90, 250, 152, 77, 26, 7, 54, 186, 155, 225, 144, 116, 152]), digest := (bytes [44, 87, 87, 214, 79, 125, 24, 110, 90, 208, 126, 192, 67, 106, 97, 58, 241, 129, 159, 146, 146, 47, 123, 114, 95, 62, 20, 164, 8, 110, 238, 150]) }]

def rootExecutionExecutionSemanticsRefinement : List RootExecutionSemanticsRefinementView :=
  [{ traceIndex := 0, logicalIndex := 0, semanticRowDigest := (bytes [160, 225, 50, 185, 210, 13, 73, 20, 214, 234, 155, 255, 235, 134, 75, 183, 210, 59, 17, 197, 116, 101, 161, 172, 131, 122, 83, 196, 194, 100, 16, 24]), rowLocalCcsAcceptanceDigest := (bytes [156, 156, 155, 41, 158, 85, 226, 133, 159, 253, 176, 119, 137, 19, 137, 181, 80, 20, 157, 220, 131, 119, 99, 249, 54, 139, 22, 246, 175, 115, 255, 169]), preparedStepBindingDigest := (bytes [196, 127, 115, 228, 145, 235, 105, 203, 91, 30, 41, 234, 216, 138, 118, 223, 152, 13, 133, 59, 128, 32, 23, 132, 0, 186, 217, 35, 34, 46, 143, 135]), publicStepDigest := (bytes [193, 37, 92, 24, 187, 176, 90, 242, 63, 61, 191, 129, 205, 1, 88, 178, 30, 47, 113, 40, 68, 36, 220, 38, 178, 165, 68, 84, 227, 170, 20, 136]), digest := (bytes [73, 14, 242, 215, 198, 4, 73, 15, 92, 209, 0, 39, 189, 125, 76, 174, 198, 87, 114, 199, 115, 164, 220, 40, 103, 14, 250, 63, 213, 239, 107, 27]) }, { traceIndex := 1, logicalIndex := 1, semanticRowDigest := (bytes [189, 122, 139, 107, 118, 236, 136, 81, 191, 253, 213, 201, 173, 103, 248, 132, 37, 204, 49, 169, 112, 11, 179, 119, 250, 122, 232, 2, 146, 113, 225, 32]), rowLocalCcsAcceptanceDigest := (bytes [142, 147, 55, 222, 15, 212, 191, 214, 138, 53, 112, 164, 78, 194, 204, 223, 3, 247, 12, 183, 207, 119, 111, 59, 34, 61, 130, 218, 165, 166, 80, 171]), preparedStepBindingDigest := (bytes [0, 254, 8, 79, 59, 114, 109, 146, 23, 15, 216, 107, 171, 8, 193, 37, 127, 32, 182, 209, 172, 8, 154, 103, 229, 122, 197, 165, 217, 204, 197, 239]), publicStepDigest := (bytes [236, 217, 27, 253, 146, 72, 34, 10, 6, 80, 72, 237, 181, 64, 76, 49, 42, 47, 138, 142, 12, 255, 130, 64, 134, 154, 100, 118, 71, 221, 155, 251]), digest := (bytes [58, 80, 1, 181, 194, 242, 170, 53, 11, 239, 246, 67, 94, 160, 254, 174, 105, 41, 254, 221, 230, 80, 161, 129, 3, 174, 41, 55, 116, 82, 88, 251]) }, { traceIndex := 2, logicalIndex := 2, semanticRowDigest := (bytes [75, 22, 202, 119, 180, 232, 196, 137, 255, 230, 216, 234, 203, 185, 92, 83, 86, 31, 35, 204, 103, 92, 214, 96, 139, 157, 118, 56, 21, 113, 179, 110]), rowLocalCcsAcceptanceDigest := (bytes [166, 111, 57, 22, 220, 175, 69, 160, 99, 120, 143, 17, 180, 119, 125, 36, 52, 110, 158, 231, 216, 124, 76, 72, 205, 126, 109, 91, 164, 184, 14, 162]), preparedStepBindingDigest := (bytes [135, 20, 39, 193, 36, 204, 146, 160, 15, 213, 4, 70, 122, 160, 105, 102, 201, 123, 227, 203, 211, 48, 150, 49, 244, 14, 201, 29, 67, 181, 0, 229]), publicStepDigest := (bytes [234, 224, 86, 28, 29, 15, 94, 144, 172, 104, 204, 41, 123, 162, 176, 16, 198, 115, 90, 141, 59, 140, 78, 147, 231, 119, 19, 137, 152, 211, 180, 58]), digest := (bytes [176, 119, 146, 34, 81, 59, 76, 4, 208, 216, 134, 223, 222, 100, 36, 75, 170, 132, 222, 25, 214, 95, 30, 40, 16, 52, 153, 12, 130, 18, 152, 42]) }, { traceIndex := 3, logicalIndex := 3, semanticRowDigest := (bytes [21, 108, 252, 24, 157, 6, 24, 118, 180, 69, 47, 98, 186, 176, 68, 155, 45, 91, 41, 37, 173, 65, 117, 251, 66, 253, 216, 67, 65, 3, 164, 176]), rowLocalCcsAcceptanceDigest := (bytes [158, 150, 203, 237, 190, 89, 205, 156, 25, 254, 216, 32, 192, 214, 31, 39, 185, 127, 255, 85, 61, 87, 172, 223, 90, 126, 195, 122, 237, 139, 39, 160]), preparedStepBindingDigest := (bytes [60, 115, 87, 171, 60, 35, 12, 17, 85, 133, 80, 196, 74, 54, 8, 39, 95, 60, 47, 125, 220, 65, 47, 161, 75, 135, 129, 96, 79, 31, 71, 64]), publicStepDigest := (bytes [1, 14, 51, 172, 24, 168, 217, 150, 155, 179, 29, 38, 113, 124, 12, 207, 242, 224, 162, 128, 181, 70, 159, 98, 142, 53, 38, 32, 221, 119, 4, 200]), digest := (bytes [197, 200, 62, 221, 79, 208, 185, 122, 167, 80, 97, 149, 67, 4, 126, 25, 229, 110, 181, 77, 226, 23, 118, 128, 221, 119, 140, 84, 22, 109, 199, 115]) }, { traceIndex := 4, logicalIndex := 4, semanticRowDigest := (bytes [126, 217, 16, 165, 99, 126, 224, 66, 83, 182, 161, 49, 183, 96, 188, 25, 130, 19, 235, 225, 23, 148, 5, 113, 84, 245, 42, 44, 96, 49, 189, 52]), rowLocalCcsAcceptanceDigest := (bytes [144, 69, 253, 31, 189, 20, 171, 136, 100, 63, 232, 176, 151, 4, 150, 218, 27, 142, 116, 22, 143, 65, 215, 68, 3, 131, 38, 23, 176, 131, 235, 236]), preparedStepBindingDigest := (bytes [101, 37, 166, 90, 81, 113, 151, 115, 176, 55, 21, 227, 97, 32, 103, 5, 78, 185, 217, 114, 168, 93, 188, 106, 227, 177, 169, 55, 122, 243, 169, 196]), publicStepDigest := (bytes [6, 241, 152, 74, 78, 254, 152, 193, 205, 93, 194, 234, 5, 178, 127, 199, 122, 244, 39, 79, 88, 168, 255, 173, 51, 123, 7, 3, 136, 238, 91, 231]), digest := (bytes [48, 226, 55, 158, 38, 155, 212, 138, 140, 10, 58, 69, 239, 4, 173, 132, 30, 207, 253, 1, 246, 95, 212, 164, 67, 113, 209, 230, 32, 188, 214, 39]) }, { traceIndex := 5, logicalIndex := 5, semanticRowDigest := (bytes [59, 249, 4, 162, 100, 104, 48, 130, 251, 213, 9, 123, 197, 23, 95, 115, 92, 212, 209, 148, 212, 129, 10, 60, 58, 156, 233, 91, 93, 7, 1, 132]), rowLocalCcsAcceptanceDigest := (bytes [83, 251, 114, 245, 92, 170, 236, 50, 70, 79, 247, 158, 18, 218, 78, 144, 161, 172, 173, 226, 236, 183, 65, 70, 141, 165, 1, 249, 234, 1, 57, 240]), preparedStepBindingDigest := (bytes [46, 217, 235, 86, 53, 49, 64, 92, 149, 99, 129, 130, 131, 81, 170, 99, 88, 224, 44, 8, 11, 215, 13, 175, 103, 31, 197, 104, 155, 205, 101, 209]), publicStepDigest := (bytes [29, 245, 36, 93, 39, 132, 17, 66, 134, 241, 114, 152, 62, 210, 142, 64, 213, 165, 141, 49, 185, 207, 180, 0, 49, 219, 100, 206, 210, 41, 184, 73]), digest := (bytes [100, 7, 73, 239, 237, 157, 118, 6, 191, 150, 213, 186, 37, 62, 224, 47, 104, 164, 88, 119, 68, 246, 100, 136, 91, 149, 56, 85, 5, 74, 171, 169]) }, { traceIndex := 6, logicalIndex := 6, semanticRowDigest := (bytes [103, 139, 104, 174, 233, 11, 209, 136, 244, 178, 215, 246, 168, 126, 82, 83, 199, 15, 43, 73, 213, 18, 119, 92, 77, 202, 248, 59, 53, 56, 60, 255]), rowLocalCcsAcceptanceDigest := (bytes [142, 156, 185, 64, 28, 126, 69, 68, 245, 35, 195, 134, 236, 113, 242, 127, 57, 87, 14, 224, 153, 98, 146, 86, 153, 85, 186, 46, 214, 108, 156, 92]), preparedStepBindingDigest := (bytes [29, 53, 226, 48, 18, 54, 210, 123, 145, 16, 39, 215, 46, 150, 209, 66, 255, 214, 248, 236, 157, 238, 192, 225, 237, 130, 58, 41, 80, 93, 10, 253]), publicStepDigest := (bytes [209, 47, 242, 158, 15, 5, 129, 10, 54, 205, 95, 5, 49, 89, 208, 184, 152, 72, 250, 50, 219, 27, 103, 168, 11, 7, 252, 166, 129, 36, 182, 82]), digest := (bytes [141, 13, 205, 51, 38, 128, 197, 235, 156, 187, 197, 46, 186, 2, 47, 111, 116, 161, 230, 183, 70, 73, 65, 251, 34, 146, 38, 51, 155, 67, 25, 139]) }, { traceIndex := 7, logicalIndex := 7, semanticRowDigest := (bytes [216, 70, 95, 232, 21, 13, 203, 78, 41, 198, 171, 100, 156, 140, 241, 133, 226, 241, 25, 181, 244, 56, 186, 141, 59, 7, 184, 16, 245, 136, 129, 119]), rowLocalCcsAcceptanceDigest := (bytes [17, 244, 13, 160, 199, 131, 233, 110, 242, 246, 79, 79, 168, 31, 56, 224, 194, 100, 139, 16, 185, 62, 97, 56, 39, 78, 90, 120, 85, 13, 196, 175]), preparedStepBindingDigest := (bytes [106, 15, 90, 142, 228, 22, 167, 202, 104, 76, 19, 100, 3, 24, 121, 177, 235, 236, 165, 152, 126, 94, 228, 123, 229, 23, 154, 236, 141, 79, 23, 242]), publicStepDigest := (bytes [132, 152, 180, 181, 130, 190, 239, 195, 170, 79, 191, 237, 56, 162, 73, 132, 131, 179, 76, 38, 155, 215, 200, 68, 77, 0, 5, 237, 251, 108, 171, 25]), digest := (bytes [181, 244, 198, 31, 12, 189, 8, 18, 187, 1, 182, 54, 110, 147, 68, 188, 60, 139, 93, 183, 33, 223, 226, 128, 164, 118, 110, 207, 153, 241, 153, 232]) }, { traceIndex := 8, logicalIndex := 8, semanticRowDigest := (bytes [254, 252, 9, 112, 167, 98, 64, 58, 182, 189, 144, 85, 30, 99, 189, 74, 178, 6, 189, 11, 53, 13, 122, 67, 132, 217, 195, 154, 227, 56, 238, 221]), rowLocalCcsAcceptanceDigest := (bytes [184, 122, 159, 68, 168, 4, 202, 102, 65, 193, 52, 149, 164, 165, 236, 27, 14, 178, 105, 83, 53, 175, 22, 61, 254, 203, 88, 145, 93, 230, 253, 181]), preparedStepBindingDigest := (bytes [231, 156, 236, 58, 138, 7, 35, 114, 64, 133, 231, 42, 246, 241, 98, 92, 109, 25, 247, 254, 165, 93, 187, 39, 64, 29, 131, 168, 158, 46, 14, 107]), publicStepDigest := (bytes [187, 3, 122, 174, 10, 173, 71, 220, 42, 228, 173, 11, 201, 192, 112, 200, 58, 4, 65, 224, 134, 5, 78, 117, 227, 34, 39, 194, 148, 180, 167, 116]), digest := (bytes [80, 225, 33, 194, 50, 3, 143, 84, 59, 29, 149, 212, 15, 133, 120, 43, 51, 79, 177, 234, 61, 65, 171, 222, 162, 34, 220, 61, 246, 9, 56, 253]) }, { traceIndex := 9, logicalIndex := 9, semanticRowDigest := (bytes [52, 237, 29, 102, 60, 36, 173, 1, 116, 250, 237, 49, 20, 240, 235, 233, 163, 124, 16, 48, 170, 204, 86, 131, 51, 233, 2, 149, 253, 157, 4, 117]), rowLocalCcsAcceptanceDigest := (bytes [86, 56, 171, 11, 227, 53, 249, 210, 16, 101, 224, 123, 230, 152, 23, 143, 60, 124, 157, 41, 142, 149, 77, 153, 0, 8, 27, 204, 216, 27, 184, 181]), preparedStepBindingDigest := (bytes [153, 248, 112, 176, 139, 43, 160, 136, 128, 19, 111, 11, 12, 249, 212, 168, 146, 205, 144, 135, 139, 135, 214, 168, 137, 199, 186, 148, 246, 115, 254, 150]), publicStepDigest := (bytes [223, 55, 102, 109, 37, 172, 32, 139, 178, 120, 189, 72, 226, 111, 134, 45, 140, 143, 247, 128, 220, 185, 93, 44, 211, 211, 231, 53, 232, 175, 57, 168]), digest := (bytes [84, 127, 84, 40, 58, 244, 3, 156, 35, 178, 214, 69, 197, 132, 201, 34, 170, 251, 201, 32, 237, 78, 72, 155, 238, 247, 148, 47, 59, 67, 129, 69]) }, { traceIndex := 10, logicalIndex := 10, semanticRowDigest := (bytes [131, 236, 87, 69, 34, 0, 11, 195, 75, 99, 124, 212, 146, 155, 230, 168, 3, 176, 163, 77, 13, 240, 34, 216, 105, 220, 177, 238, 116, 207, 217, 1]), rowLocalCcsAcceptanceDigest := (bytes [139, 21, 240, 249, 179, 200, 91, 117, 90, 165, 150, 202, 36, 66, 0, 107, 56, 190, 191, 230, 138, 162, 64, 98, 214, 59, 75, 23, 31, 125, 17, 215]), preparedStepBindingDigest := (bytes [252, 42, 71, 185, 29, 217, 106, 230, 161, 152, 122, 167, 46, 178, 244, 100, 89, 151, 96, 238, 137, 165, 207, 211, 246, 44, 245, 0, 4, 181, 209, 140]), publicStepDigest := (bytes [233, 56, 105, 231, 20, 85, 142, 180, 26, 28, 176, 229, 237, 31, 102, 101, 48, 210, 164, 204, 55, 118, 175, 6, 41, 51, 7, 37, 149, 63, 254, 118]), digest := (bytes [225, 162, 136, 45, 21, 113, 140, 143, 45, 114, 101, 226, 25, 188, 49, 155, 142, 137, 144, 58, 243, 98, 67, 80, 92, 71, 106, 151, 81, 245, 240, 97]) }, { traceIndex := 11, logicalIndex := 11, semanticRowDigest := (bytes [106, 87, 15, 190, 230, 56, 131, 88, 122, 236, 36, 27, 187, 74, 122, 83, 67, 75, 218, 179, 239, 148, 171, 183, 158, 245, 224, 134, 214, 119, 73, 181]), rowLocalCcsAcceptanceDigest := (bytes [134, 114, 86, 126, 60, 56, 188, 18, 17, 242, 128, 91, 27, 13, 6, 34, 46, 121, 167, 185, 35, 102, 35, 198, 33, 78, 108, 95, 53, 51, 173, 215]), preparedStepBindingDigest := (bytes [250, 202, 190, 200, 71, 238, 137, 43, 217, 25, 41, 69, 44, 117, 155, 2, 26, 60, 33, 18, 136, 37, 142, 5, 239, 33, 191, 25, 88, 86, 236, 169]), publicStepDigest := (bytes [21, 54, 67, 10, 2, 141, 39, 26, 198, 113, 133, 154, 25, 109, 18, 2, 71, 133, 213, 42, 106, 23, 61, 186, 223, 77, 224, 39, 185, 170, 8, 58]), digest := (bytes [19, 250, 80, 105, 143, 220, 85, 150, 125, 209, 55, 252, 112, 161, 119, 2, 170, 117, 176, 76, 116, 238, 223, 80, 43, 135, 148, 31, 126, 44, 41, 92]) }, { traceIndex := 12, logicalIndex := 12, semanticRowDigest := (bytes [16, 201, 185, 147, 99, 217, 237, 202, 92, 38, 238, 96, 91, 232, 40, 19, 80, 6, 135, 112, 151, 177, 117, 235, 213, 106, 109, 79, 174, 10, 108, 195]), rowLocalCcsAcceptanceDigest := (bytes [148, 16, 150, 78, 164, 17, 199, 197, 177, 187, 85, 110, 132, 146, 5, 253, 68, 172, 237, 121, 79, 163, 249, 131, 10, 206, 199, 119, 76, 43, 99, 223]), preparedStepBindingDigest := (bytes [43, 165, 115, 225, 22, 64, 11, 233, 223, 106, 242, 232, 98, 23, 72, 183, 169, 127, 186, 62, 160, 224, 201, 244, 95, 0, 156, 103, 161, 44, 250, 2]), publicStepDigest := (bytes [59, 213, 30, 142, 244, 61, 145, 71, 192, 107, 204, 4, 108, 78, 126, 39, 62, 194, 187, 86, 137, 59, 49, 1, 214, 189, 112, 153, 50, 246, 83, 76]), digest := (bytes [5, 81, 24, 68, 190, 227, 26, 241, 138, 60, 180, 101, 91, 229, 224, 62, 78, 247, 177, 84, 245, 209, 75, 15, 139, 131, 52, 234, 54, 225, 198, 19]) }, { traceIndex := 13, logicalIndex := 13, semanticRowDigest := (bytes [108, 118, 132, 172, 73, 94, 4, 235, 180, 48, 196, 81, 22, 205, 244, 189, 36, 227, 120, 250, 101, 46, 167, 46, 159, 4, 76, 95, 113, 219, 62, 136]), rowLocalCcsAcceptanceDigest := (bytes [106, 161, 161, 33, 227, 253, 56, 144, 54, 123, 221, 140, 114, 226, 226, 29, 16, 196, 174, 29, 76, 205, 235, 25, 62, 222, 161, 67, 205, 98, 5, 167]), preparedStepBindingDigest := (bytes [37, 175, 91, 93, 45, 175, 62, 80, 210, 34, 77, 91, 41, 37, 204, 225, 252, 39, 3, 217, 174, 179, 205, 91, 239, 120, 141, 200, 105, 128, 133, 228]), publicStepDigest := (bytes [248, 226, 79, 38, 26, 255, 65, 252, 107, 98, 215, 51, 193, 111, 34, 194, 206, 67, 199, 248, 80, 229, 124, 52, 189, 40, 44, 130, 138, 37, 79, 111]), digest := (bytes [100, 185, 31, 131, 179, 174, 214, 4, 34, 22, 141, 116, 36, 70, 209, 192, 10, 151, 128, 238, 104, 252, 153, 97, 224, 125, 17, 98, 103, 214, 10, 74]) }, { traceIndex := 14, logicalIndex := 14, semanticRowDigest := (bytes [238, 241, 80, 38, 50, 2, 29, 167, 91, 132, 106, 232, 121, 19, 195, 245, 183, 43, 205, 47, 133, 242, 30, 86, 52, 215, 134, 116, 33, 135, 69, 219]), rowLocalCcsAcceptanceDigest := (bytes [101, 9, 194, 180, 29, 20, 192, 228, 209, 189, 34, 151, 83, 84, 245, 44, 84, 158, 201, 255, 93, 229, 85, 158, 69, 61, 54, 141, 149, 4, 73, 12]), preparedStepBindingDigest := (bytes [235, 80, 228, 103, 26, 224, 215, 213, 212, 112, 29, 125, 161, 70, 106, 186, 190, 160, 79, 78, 195, 103, 144, 25, 110, 31, 76, 13, 3, 161, 196, 63]), publicStepDigest := (bytes [179, 175, 223, 127, 94, 70, 50, 158, 248, 6, 220, 0, 246, 87, 218, 56, 173, 97, 235, 21, 50, 212, 238, 169, 243, 189, 86, 119, 176, 86, 241, 42]), digest := (bytes [206, 93, 86, 67, 144, 133, 8, 171, 136, 100, 82, 132, 19, 158, 151, 165, 18, 214, 87, 3, 112, 121, 106, 191, 157, 66, 127, 55, 129, 49, 248, 173]) }, { traceIndex := 15, logicalIndex := 15, semanticRowDigest := (bytes [4, 132, 64, 193, 168, 21, 16, 134, 152, 231, 227, 202, 145, 159, 243, 216, 231, 143, 1, 248, 155, 96, 200, 246, 195, 136, 149, 179, 255, 241, 29, 181]), rowLocalCcsAcceptanceDigest := (bytes [181, 64, 246, 68, 29, 225, 234, 63, 53, 133, 203, 79, 141, 210, 148, 162, 65, 177, 254, 146, 220, 136, 149, 15, 75, 200, 45, 43, 120, 114, 230, 162]), preparedStepBindingDigest := (bytes [33, 235, 216, 195, 247, 160, 99, 149, 109, 234, 63, 7, 71, 98, 110, 252, 184, 249, 179, 196, 196, 76, 56, 30, 219, 179, 18, 197, 240, 109, 79, 243]), publicStepDigest := (bytes [129, 186, 188, 57, 62, 175, 27, 96, 34, 244, 37, 188, 239, 0, 187, 15, 187, 26, 61, 226, 92, 117, 169, 157, 185, 49, 128, 162, 137, 135, 47, 16]), digest := (bytes [121, 237, 222, 159, 112, 37, 238, 186, 56, 119, 168, 162, 87, 238, 185, 26, 170, 16, 46, 240, 235, 131, 90, 18, 186, 51, 248, 126, 7, 189, 147, 91]) }, { traceIndex := 16, logicalIndex := 16, semanticRowDigest := (bytes [61, 30, 66, 125, 28, 235, 200, 212, 200, 23, 34, 129, 225, 237, 110, 24, 124, 136, 60, 6, 24, 172, 122, 24, 227, 89, 186, 4, 114, 232, 154, 22]), rowLocalCcsAcceptanceDigest := (bytes [91, 162, 2, 224, 36, 181, 55, 117, 162, 50, 226, 75, 178, 8, 40, 199, 206, 226, 242, 168, 59, 109, 45, 28, 71, 147, 106, 138, 84, 167, 203, 236]), preparedStepBindingDigest := (bytes [2, 219, 133, 56, 196, 251, 194, 17, 236, 27, 178, 68, 44, 148, 242, 33, 39, 66, 44, 198, 183, 230, 214, 214, 43, 106, 247, 89, 89, 73, 234, 1]), publicStepDigest := (bytes [83, 196, 3, 4, 191, 54, 233, 167, 152, 9, 15, 76, 63, 170, 190, 214, 143, 172, 54, 25, 232, 196, 59, 251, 250, 96, 202, 100, 126, 82, 185, 248]), digest := (bytes [244, 29, 127, 184, 70, 213, 226, 36, 147, 244, 101, 99, 121, 181, 164, 201, 157, 114, 11, 216, 127, 80, 206, 51, 184, 4, 242, 148, 18, 36, 43, 246]) }, { traceIndex := 17, logicalIndex := 17, semanticRowDigest := (bytes [74, 47, 120, 175, 110, 56, 110, 240, 208, 26, 120, 135, 1, 174, 74, 29, 86, 219, 103, 142, 247, 29, 250, 96, 16, 243, 75, 236, 230, 190, 167, 151]), rowLocalCcsAcceptanceDigest := (bytes [69, 223, 163, 118, 201, 36, 91, 59, 19, 241, 71, 80, 154, 199, 247, 76, 18, 11, 43, 117, 55, 114, 147, 86, 137, 75, 252, 114, 131, 229, 19, 176]), preparedStepBindingDigest := (bytes [237, 72, 157, 178, 170, 209, 31, 81, 70, 177, 213, 254, 119, 180, 18, 50, 182, 213, 168, 64, 48, 82, 27, 14, 29, 179, 74, 237, 186, 77, 167, 253]), publicStepDigest := (bytes [228, 145, 93, 134, 250, 15, 253, 165, 113, 210, 59, 248, 135, 168, 123, 72, 142, 183, 176, 118, 87, 54, 136, 93, 134, 102, 33, 95, 49, 143, 128, 115]), digest := (bytes [52, 57, 53, 219, 51, 175, 125, 148, 99, 211, 17, 20, 22, 216, 135, 32, 88, 192, 41, 30, 210, 140, 135, 5, 126, 179, 206, 144, 144, 255, 154, 174]) }, { traceIndex := 18, logicalIndex := 18, semanticRowDigest := (bytes [78, 176, 172, 185, 235, 161, 170, 97, 190, 168, 43, 108, 189, 37, 193, 221, 189, 172, 64, 90, 173, 188, 50, 252, 253, 58, 118, 79, 132, 50, 155, 140]), rowLocalCcsAcceptanceDigest := (bytes [223, 42, 132, 101, 51, 37, 121, 7, 30, 249, 44, 69, 251, 206, 82, 249, 109, 112, 1, 156, 206, 228, 134, 130, 243, 243, 182, 254, 207, 116, 100, 31]), preparedStepBindingDigest := (bytes [191, 58, 14, 98, 131, 172, 108, 55, 57, 60, 200, 47, 47, 67, 30, 190, 119, 135, 48, 28, 73, 90, 52, 224, 230, 71, 199, 160, 196, 190, 60, 50]), publicStepDigest := (bytes [80, 43, 151, 162, 33, 9, 64, 167, 26, 5, 106, 178, 229, 12, 164, 154, 183, 8, 11, 231, 61, 40, 128, 248, 198, 91, 242, 154, 234, 231, 33, 65]), digest := (bytes [43, 74, 24, 33, 80, 88, 69, 62, 246, 135, 138, 63, 24, 210, 21, 38, 144, 202, 172, 160, 188, 35, 214, 215, 165, 117, 77, 182, 94, 159, 159, 114]) }, { traceIndex := 19, logicalIndex := 19, semanticRowDigest := (bytes [13, 7, 186, 112, 52, 116, 157, 229, 53, 239, 107, 228, 220, 121, 107, 32, 222, 226, 73, 108, 77, 7, 107, 210, 133, 18, 85, 22, 111, 129, 229, 199]), rowLocalCcsAcceptanceDigest := (bytes [246, 77, 168, 209, 228, 252, 196, 94, 56, 88, 65, 169, 239, 237, 244, 204, 197, 117, 224, 241, 154, 115, 222, 217, 131, 14, 215, 47, 241, 161, 219, 142]), preparedStepBindingDigest := (bytes [102, 182, 137, 118, 211, 205, 105, 72, 254, 128, 72, 129, 223, 65, 203, 33, 118, 90, 217, 39, 29, 244, 110, 3, 5, 121, 214, 51, 39, 199, 178, 16]), publicStepDigest := (bytes [60, 21, 177, 105, 104, 254, 99, 115, 0, 78, 65, 158, 138, 100, 152, 30, 223, 157, 130, 246, 105, 28, 199, 122, 155, 119, 167, 175, 196, 80, 59, 41]), digest := (bytes [90, 22, 24, 111, 171, 225, 206, 240, 190, 220, 65, 157, 76, 169, 34, 71, 139, 27, 227, 36, 110, 63, 20, 135, 98, 199, 82, 58, 191, 176, 217, 143]) }, { traceIndex := 20, logicalIndex := 20, semanticRowDigest := (bytes [54, 210, 85, 250, 125, 21, 186, 237, 92, 169, 10, 209, 209, 151, 121, 213, 25, 220, 43, 19, 64, 21, 213, 97, 231, 117, 80, 244, 141, 136, 27, 8]), rowLocalCcsAcceptanceDigest := (bytes [124, 177, 0, 189, 106, 179, 63, 43, 6, 223, 143, 57, 113, 131, 191, 26, 199, 156, 80, 135, 167, 139, 102, 173, 44, 206, 51, 9, 152, 160, 187, 96]), preparedStepBindingDigest := (bytes [16, 88, 82, 90, 127, 215, 86, 150, 28, 228, 157, 96, 11, 117, 129, 70, 230, 201, 22, 94, 109, 33, 97, 164, 176, 23, 108, 52, 28, 143, 227, 9]), publicStepDigest := (bytes [214, 188, 158, 69, 192, 112, 37, 42, 113, 16, 169, 133, 146, 31, 6, 181, 128, 150, 53, 178, 120, 45, 198, 69, 59, 139, 9, 153, 39, 224, 17, 38]), digest := (bytes [50, 111, 150, 136, 190, 121, 76, 195, 139, 105, 92, 130, 195, 41, 64, 207, 144, 131, 217, 200, 115, 110, 1, 251, 100, 45, 104, 186, 76, 41, 193, 92]) }, { traceIndex := 21, logicalIndex := 21, semanticRowDigest := (bytes [173, 42, 28, 185, 132, 152, 209, 244, 195, 174, 33, 91, 48, 124, 106, 227, 211, 132, 56, 188, 76, 82, 185, 128, 176, 180, 144, 43, 153, 135, 191, 232]), rowLocalCcsAcceptanceDigest := (bytes [180, 153, 210, 204, 109, 77, 144, 228, 87, 1, 185, 250, 178, 62, 33, 2, 253, 78, 47, 57, 63, 192, 115, 163, 225, 14, 77, 182, 29, 145, 73, 184]), preparedStepBindingDigest := (bytes [42, 5, 21, 56, 61, 20, 168, 207, 214, 33, 12, 156, 116, 19, 0, 224, 170, 206, 33, 83, 33, 63, 14, 45, 241, 75, 37, 45, 181, 234, 234, 16]), publicStepDigest := (bytes [174, 203, 235, 188, 172, 16, 167, 38, 31, 11, 118, 231, 201, 103, 183, 232, 131, 148, 138, 138, 254, 135, 80, 41, 211, 174, 255, 94, 91, 172, 217, 73]), digest := (bytes [25, 97, 226, 14, 28, 1, 84, 111, 19, 203, 33, 43, 231, 3, 6, 228, 142, 155, 236, 80, 221, 251, 159, 27, 61, 168, 177, 185, 48, 151, 131, 140]) }, { traceIndex := 22, logicalIndex := 22, semanticRowDigest := (bytes [252, 47, 52, 97, 85, 184, 205, 166, 163, 31, 209, 44, 188, 120, 178, 100, 54, 79, 97, 147, 104, 246, 105, 34, 78, 200, 158, 10, 134, 103, 17, 130]), rowLocalCcsAcceptanceDigest := (bytes [19, 75, 137, 87, 133, 237, 246, 229, 182, 178, 94, 195, 35, 247, 110, 76, 5, 241, 155, 206, 158, 107, 54, 180, 173, 91, 68, 75, 194, 240, 136, 46]), preparedStepBindingDigest := (bytes [75, 242, 7, 92, 255, 227, 231, 31, 214, 18, 223, 107, 154, 25, 183, 127, 194, 42, 121, 34, 154, 77, 164, 205, 209, 24, 99, 10, 99, 232, 177, 41]), publicStepDigest := (bytes [74, 210, 250, 72, 141, 87, 15, 253, 2, 76, 159, 125, 123, 172, 90, 6, 212, 0, 218, 56, 229, 235, 37, 49, 219, 63, 200, 57, 109, 86, 156, 135]), digest := (bytes [223, 185, 136, 246, 204, 230, 247, 231, 245, 8, 185, 191, 67, 108, 10, 246, 158, 204, 78, 228, 148, 235, 180, 251, 64, 9, 158, 150, 207, 13, 241, 98]) }, { traceIndex := 23, logicalIndex := 23, semanticRowDigest := (bytes [250, 106, 21, 155, 137, 175, 93, 14, 44, 150, 60, 179, 184, 34, 52, 74, 245, 30, 68, 193, 56, 33, 240, 88, 224, 239, 231, 14, 118, 27, 195, 94]), rowLocalCcsAcceptanceDigest := (bytes [252, 66, 30, 100, 230, 187, 15, 46, 99, 230, 42, 106, 64, 27, 185, 62, 118, 106, 204, 137, 38, 211, 181, 49, 124, 199, 94, 156, 12, 252, 68, 30]), preparedStepBindingDigest := (bytes [181, 68, 113, 70, 124, 131, 94, 29, 169, 232, 141, 149, 49, 78, 71, 166, 2, 228, 138, 222, 166, 5, 89, 155, 226, 110, 20, 94, 50, 184, 49, 121]), publicStepDigest := (bytes [56, 10, 230, 104, 107, 76, 89, 251, 24, 142, 43, 5, 73, 41, 101, 53, 31, 187, 15, 195, 201, 51, 5, 21, 139, 186, 144, 62, 183, 77, 18, 172]), digest := (bytes [31, 184, 97, 154, 92, 138, 129, 76, 80, 126, 31, 14, 193, 8, 19, 94, 50, 33, 202, 230, 144, 51, 120, 35, 254, 232, 84, 4, 223, 116, 172, 52]) }, { traceIndex := 24, logicalIndex := 24, semanticRowDigest := (bytes [206, 85, 130, 209, 39, 172, 127, 232, 136, 72, 254, 39, 163, 72, 132, 11, 218, 44, 26, 60, 133, 139, 44, 144, 226, 167, 69, 117, 188, 186, 31, 54]), rowLocalCcsAcceptanceDigest := (bytes [113, 151, 184, 118, 181, 91, 215, 6, 210, 136, 237, 234, 82, 211, 35, 66, 186, 197, 113, 201, 169, 170, 45, 74, 60, 189, 75, 243, 33, 159, 73, 194]), preparedStepBindingDigest := (bytes [148, 245, 199, 127, 3, 0, 139, 3, 46, 192, 134, 40, 115, 34, 101, 102, 120, 45, 87, 48, 199, 148, 137, 235, 30, 137, 225, 33, 16, 161, 168, 122]), publicStepDigest := (bytes [148, 254, 130, 118, 137, 66, 127, 238, 121, 13, 77, 105, 122, 70, 195, 67, 241, 71, 31, 153, 148, 40, 49, 56, 215, 111, 9, 237, 245, 157, 100, 163]), digest := (bytes [51, 48, 230, 217, 74, 20, 233, 145, 180, 20, 164, 192, 252, 209, 119, 220, 82, 164, 233, 77, 131, 92, 220, 233, 147, 97, 156, 99, 87, 140, 85, 249]) }, { traceIndex := 25, logicalIndex := 25, semanticRowDigest := (bytes [31, 108, 0, 208, 93, 16, 132, 158, 68, 235, 103, 38, 101, 124, 121, 166, 59, 211, 143, 41, 209, 29, 231, 152, 200, 186, 207, 5, 246, 200, 242, 56]), rowLocalCcsAcceptanceDigest := (bytes [237, 223, 25, 162, 142, 34, 206, 90, 111, 162, 104, 233, 169, 50, 93, 1, 46, 252, 77, 134, 167, 132, 143, 9, 94, 233, 99, 57, 81, 132, 138, 196]), preparedStepBindingDigest := (bytes [247, 191, 143, 255, 26, 119, 247, 116, 193, 201, 48, 243, 127, 163, 101, 178, 238, 215, 64, 127, 186, 98, 98, 244, 138, 2, 25, 208, 87, 49, 31, 126]), publicStepDigest := (bytes [8, 193, 202, 144, 121, 142, 204, 76, 166, 146, 213, 198, 159, 99, 140, 28, 116, 128, 109, 5, 16, 224, 62, 160, 179, 124, 104, 134, 199, 114, 5, 56]), digest := (bytes [68, 63, 45, 229, 36, 203, 223, 117, 38, 61, 226, 33, 115, 62, 50, 108, 124, 28, 120, 216, 5, 66, 235, 151, 107, 81, 132, 2, 12, 172, 237, 243]) }, { traceIndex := 26, logicalIndex := 26, semanticRowDigest := (bytes [27, 139, 236, 157, 139, 238, 154, 103, 70, 160, 44, 15, 13, 166, 205, 73, 102, 100, 166, 33, 215, 40, 31, 223, 122, 167, 200, 146, 129, 214, 238, 80]), rowLocalCcsAcceptanceDigest := (bytes [79, 39, 237, 230, 69, 26, 156, 238, 218, 24, 231, 5, 43, 223, 158, 232, 85, 190, 5, 170, 102, 76, 213, 26, 254, 47, 239, 152, 164, 66, 115, 84]), preparedStepBindingDigest := (bytes [34, 234, 181, 238, 156, 187, 169, 107, 14, 210, 176, 12, 28, 194, 244, 221, 55, 85, 155, 195, 242, 8, 117, 145, 209, 187, 63, 214, 250, 67, 144, 38]), publicStepDigest := (bytes [247, 10, 172, 205, 96, 237, 51, 255, 153, 236, 247, 247, 201, 200, 115, 116, 99, 137, 183, 78, 4, 214, 120, 230, 152, 123, 98, 45, 223, 114, 241, 22]), digest := (bytes [219, 182, 5, 0, 167, 133, 67, 89, 9, 59, 152, 9, 193, 95, 64, 72, 55, 194, 25, 30, 205, 130, 175, 121, 29, 11, 238, 157, 57, 122, 125, 41]) }, { traceIndex := 27, logicalIndex := 27, semanticRowDigest := (bytes [223, 115, 29, 116, 61, 21, 167, 105, 126, 15, 222, 184, 241, 111, 127, 124, 120, 2, 255, 20, 184, 40, 203, 79, 36, 248, 45, 66, 18, 123, 230, 158]), rowLocalCcsAcceptanceDigest := (bytes [64, 244, 217, 32, 255, 4, 101, 96, 150, 115, 96, 211, 35, 28, 26, 189, 4, 189, 222, 178, 169, 224, 98, 120, 57, 241, 76, 67, 18, 100, 155, 173]), preparedStepBindingDigest := (bytes [209, 99, 245, 95, 136, 28, 186, 77, 180, 154, 92, 124, 63, 228, 177, 123, 51, 121, 82, 107, 62, 120, 146, 135, 248, 219, 24, 35, 174, 42, 63, 214]), publicStepDigest := (bytes [114, 178, 94, 141, 69, 24, 24, 246, 216, 73, 196, 154, 203, 134, 193, 111, 154, 72, 114, 52, 174, 210, 27, 169, 199, 12, 96, 17, 163, 171, 176, 190]), digest := (bytes [39, 162, 200, 255, 56, 218, 237, 36, 183, 164, 53, 174, 184, 221, 54, 17, 143, 96, 229, 79, 7, 135, 56, 204, 192, 167, 71, 148, 248, 246, 108, 154]) }, { traceIndex := 28, logicalIndex := 28, semanticRowDigest := (bytes [202, 28, 105, 135, 163, 253, 177, 177, 239, 16, 236, 124, 48, 166, 182, 126, 254, 203, 225, 152, 144, 53, 118, 11, 223, 4, 58, 41, 118, 117, 83, 22]), rowLocalCcsAcceptanceDigest := (bytes [44, 87, 87, 214, 79, 125, 24, 110, 90, 208, 126, 192, 67, 106, 97, 58, 241, 129, 159, 146, 146, 47, 123, 114, 95, 62, 20, 164, 8, 110, 238, 150]), preparedStepBindingDigest := (bytes [210, 164, 188, 10, 200, 87, 23, 227, 108, 94, 15, 153, 245, 204, 108, 191, 76, 213, 158, 176, 59, 20, 86, 180, 2, 103, 191, 35, 54, 77, 76, 101]), publicStepDigest := (bytes [43, 205, 225, 49, 199, 214, 85, 211, 218, 162, 212, 148, 50, 128, 69, 219, 183, 162, 76, 90, 250, 152, 77, 26, 7, 54, 186, 155, 225, 144, 116, 152]), digest := (bytes [99, 105, 65, 95, 237, 26, 57, 125, 37, 31, 117, 138, 25, 43, 104, 229, 239, 246, 24, 233, 128, 43, 100, 59, 241, 162, 12, 39, 158, 148, 77, 198]) }]

def rootExecution : RootExecutionBundleView :=
  {
    executionRows := rootExecutionExecutionRows
    , semanticRows := rootExecutionSemanticRows
    , semanticRowsDigest := (bytes [210, 210, 168, 160, 209, 151, 81, 112, 167, 212, 124, 1, 116, 109, 147, 236, 155, 192, 231, 25, 27, 147, 69, 192, 118, 170, 69, 253, 3, 28, 48, 8])
    , preparedStepBindings := { bindings := rootExecutionPreparedBindings, bindingCount := 29, firstBindingDigest := (some (bytes [196, 127, 115, 228, 145, 235, 105, 203, 91, 30, 41, 234, 216, 138, 118, 223, 152, 13, 133, 59, 128, 32, 23, 132, 0, 186, 217, 35, 34, 46, 143, 135])), lastBindingDigest := (some (bytes [210, 164, 188, 10, 200, 87, 23, 227, 108, 94, 15, 153, 245, 204, 108, 191, 76, 213, 158, 176, 59, 20, 86, 180, 2, 103, 191, 35, 54, 77, 76, 101])), digest := (bytes [122, 127, 230, 234, 20, 88, 54, 132, 38, 4, 241, 103, 237, 27, 91, 231, 123, 166, 255, 110, 210, 175, 85, 2, 174, 249, 69, 66, 249, 6, 108, 229]) }
    , rowChunkRoutes := rootExecutionRowChunkRoutes
    , rowChunkRoutesDigest := (bytes [157, 56, 49, 88, 58, 136, 76, 107, 255, 120, 158, 198, 111, 202, 189, 3, 228, 179, 63, 132, 138, 132, 211, 15, 30, 108, 63, 231, 4, 55, 240, 227])
    , rowLocalCcsAcceptance := { acceptances := rootExecutionRowLocalCcsAcceptance, acceptanceCount := 29, firstAcceptanceDigest := (some (bytes [156, 156, 155, 41, 158, 85, 226, 133, 159, 253, 176, 119, 137, 19, 137, 181, 80, 20, 157, 220, 131, 119, 99, 249, 54, 139, 22, 246, 175, 115, 255, 169])), lastAcceptanceDigest := (some (bytes [44, 87, 87, 214, 79, 125, 24, 110, 90, 208, 126, 192, 67, 106, 97, 58, 241, 129, 159, 146, 146, 47, 123, 114, 95, 62, 20, 164, 8, 110, 238, 150])), digest := (bytes [117, 101, 137, 232, 233, 194, 204, 142, 202, 40, 197, 112, 130, 13, 117, 175, 232, 250, 122, 241, 242, 131, 193, 241, 225, 117, 88, 222, 24, 228, 110, 33]) }
    , executionSemanticsRefinement := { refinements := rootExecutionExecutionSemanticsRefinement, refinementCount := 29, firstRefinementDigest := (some (bytes [73, 14, 242, 215, 198, 4, 73, 15, 92, 209, 0, 39, 189, 125, 76, 174, 198, 87, 114, 199, 115, 164, 220, 40, 103, 14, 250, 63, 213, 239, 107, 27])), lastRefinementDigest := (some (bytes [99, 105, 65, 95, 237, 26, 57, 125, 37, 31, 117, 138, 25, 43, 104, 229, 239, 246, 24, 233, 128, 43, 100, 59, 241, 162, 12, 39, 158, 148, 77, 198])), digest := (bytes [51, 179, 151, 55, 140, 160, 156, 110, 215, 160, 51, 106, 116, 83, 81, 217, 133, 216, 125, 197, 188, 175, 168, 35, 144, 113, 34, 87, 159, 72, 67, 92]) }
    , familyDigest := (bytes [62, 154, 7, 200, 147, 245, 58, 185, 116, 64, 224, 46, 160, 35, 75, 87, 202, 13, 0, 146, 57, 39, 202, 76, 37, 197, 28, 178, 16, 93, 198, 238])
    , digest := (bytes [123, 201, 239, 26, 230, 117, 95, 47, 52, 201, 205, 87, 67, 31, 70, 164, 233, 232, 42, 186, 14, 182, 49, 15, 66, 125, 178, 165, 255, 154, 41, 96])
  }

def kernelOpeningBundle : SimpleKernelOpeningBundleView :=
  {
    claim := { bindings := { stageClaimBundleDigest := (bytes [245, 72, 75, 42, 73, 229, 163, 53, 146, 214, 107, 216, 213, 85, 133, 116, 173, 47, 114, 185, 134, 203, 104, 165, 250, 92, 247, 14, 227, 198, 71, 208]), stagePackageBundleDigest := (bytes [202, 244, 4, 158, 46, 125, 232, 78, 96, 136, 208, 229, 133, 159, 55, 23, 25, 188, 40, 64, 162, 32, 87, 74, 10, 162, 215, 241, 22, 9, 27, 112]), stage1PackageDigest := (bytes [84, 206, 142, 168, 93, 56, 75, 141, 229, 55, 180, 100, 199, 16, 42, 116, 200, 87, 88, 19, 121, 131, 122, 152, 187, 79, 10, 207, 157, 128, 75, 64]), stage2PackageDigest := (bytes [233, 244, 5, 85, 164, 65, 201, 245, 154, 6, 245, 55, 160, 133, 24, 0, 98, 0, 72, 170, 44, 114, 128, 216, 10, 232, 185, 75, 115, 11, 21, 57]), stage3PackageDigest := (bytes [248, 162, 12, 203, 170, 40, 43, 20, 152, 3, 84, 198, 147, 220, 41, 13, 65, 180, 249, 53, 251, 90, 130, 174, 144, 179, 189, 160, 32, 203, 228, 148]), preparedStepBindingsDigest := (bytes [122, 127, 230, 234, 20, 88, 54, 132, 38, 4, 241, 103, 237, 27, 91, 231, 123, 166, 255, 110, 210, 175, 85, 2, 174, 249, 69, 66, 249, 6, 108, 229]), bindingCount := 29, stage1RowCount := 29, stage2RegisterReadCount := 52, stage2RegisterWriteCount := 28, stage2RamEventCount := 0, stage3ContinuityCount := 9, points := { firstBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [122, 127, 230, 234, 20, 88, 54, 132, 38, 4, 241, 103, 237, 27, 91, 231, 123, 166, 255, 110, 210, 175, 85, 2, 174, 249, 69, 66, 249, 6, 108, 229]), layoutVersion := 1, digest := (bytes [215, 6, 107, 99, 9, 197, 39, 196, 223, 108, 143, 237, 212, 231, 138, 42, 173, 166, 236, 60, 74, 36, 18, 156, 222, 155, 22, 13, 80, 190, 95, 159]) }, logicalIndex := 0, digest := (bytes [171, 49, 1, 12, 69, 14, 15, 201, 249, 204, 167, 237, 104, 209, 29, 108, 202, 78, 193, 126, 84, 186, 212, 151, 104, 222, 125, 110, 105, 134, 37, 235]) }, valueDigest := (bytes [196, 127, 115, 228, 145, 235, 105, 203, 91, 30, 41, 234, 216, 138, 118, 223, 152, 13, 133, 59, 128, 32, 23, 132, 0, 186, 217, 35, 34, 46, 143, 135]), digest := (bytes [203, 112, 20, 17, 113, 59, 197, 164, 202, 156, 132, 37, 95, 192, 97, 147, 190, 206, 71, 113, 152, 141, 206, 159, 215, 125, 89, 37, 22, 227, 20, 131]) }), lastBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [122, 127, 230, 234, 20, 88, 54, 132, 38, 4, 241, 103, 237, 27, 91, 231, 123, 166, 255, 110, 210, 175, 85, 2, 174, 249, 69, 66, 249, 6, 108, 229]), layoutVersion := 1, digest := (bytes [215, 6, 107, 99, 9, 197, 39, 196, 223, 108, 143, 237, 212, 231, 138, 42, 173, 166, 236, 60, 74, 36, 18, 156, 222, 155, 22, 13, 80, 190, 95, 159]) }, logicalIndex := 28, digest := (bytes [171, 95, 136, 199, 207, 5, 220, 122, 141, 201, 129, 6, 239, 80, 68, 163, 14, 62, 45, 85, 255, 197, 79, 186, 195, 70, 166, 243, 177, 37, 43, 105]) }, valueDigest := (bytes [210, 164, 188, 10, 200, 87, 23, 227, 108, 94, 15, 153, 245, 204, 108, 191, 76, 213, 158, 176, 59, 20, 86, 180, 2, 103, 191, 35, 54, 77, 76, 101]), digest := (bytes [194, 117, 10, 236, 136, 85, 123, 199, 51, 29, 154, 128, 208, 86, 3, 153, 199, 132, 45, 44, 12, 184, 174, 96, 105, 136, 167, 90, 131, 116, 154, 204]) }) }, digest := (bytes [124, 208, 101, 209, 62, 21, 140, 193, 138, 37, 15, 244, 160, 205, 171, 166, 3, 198, 190, 195, 16, 50, 133, 17, 101, 77, 250, 179, 207, 49, 218, 161]) }, preparedSteps := { executionDigest := (bytes [74, 202, 66, 25, 106, 38, 91, 108, 83, 143, 56, 156, 203, 227, 101, 222, 4, 137, 150, 5, 195, 49, 240, 232, 104, 115, 55, 93, 227, 232, 236, 253]), finalStateDigest := (bytes [182, 31, 54, 213, 113, 159, 201, 136, 65, 181, 111, 174, 113, 197, 150, 29, 93, 126, 40, 13, 253, 225, 7, 190, 200, 101, 176, 45, 199, 60, 8, 160]), transcriptFinalDigest := (bytes [12, 192, 210, 153, 196, 189, 212, 22, 158, 203, 243, 19, 37, 237, 245, 141, 129, 40, 74, 48, 7, 211, 157, 135, 182, 198, 7, 50, 149, 140, 10, 64]), preparedStepCount := 29, finalPc := 36, halted := true, points := { firstPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [2, 195, 15, 176, 74, 156, 14, 145, 205, 30, 105, 114, 34, 141, 242, 217, 105, 100, 117, 46, 249, 188, 28, 111, 72, 195, 48, 19, 21, 39, 77, 21]), layoutVersion := 3, digest := (bytes [107, 210, 58, 64, 103, 214, 200, 23, 157, 252, 53, 151, 94, 117, 179, 18, 97, 24, 125, 232, 65, 255, 83, 37, 252, 49, 227, 196, 7, 172, 22, 254]) }, logicalIndex := 0, digest := (bytes [132, 75, 176, 50, 98, 124, 10, 163, 65, 72, 164, 172, 236, 29, 57, 36, 144, 74, 213, 185, 85, 221, 229, 157, 190, 66, 127, 60, 109, 248, 105, 36]) }, valueDigest := (bytes [15, 203, 82, 147, 182, 107, 150, 168, 159, 107, 204, 115, 170, 200, 12, 67, 125, 81, 225, 219, 175, 26, 58, 39, 55, 35, 134, 130, 62, 126, 3, 37]), digest := (bytes [143, 201, 227, 113, 227, 52, 190, 147, 201, 197, 250, 34, 101, 210, 119, 246, 66, 86, 0, 57, 190, 96, 107, 156, 186, 34, 219, 71, 26, 85, 5, 244]) }), lastPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [2, 195, 15, 176, 74, 156, 14, 145, 205, 30, 105, 114, 34, 141, 242, 217, 105, 100, 117, 46, 249, 188, 28, 111, 72, 195, 48, 19, 21, 39, 77, 21]), layoutVersion := 3, digest := (bytes [107, 210, 58, 64, 103, 214, 200, 23, 157, 252, 53, 151, 94, 117, 179, 18, 97, 24, 125, 232, 65, 255, 83, 37, 252, 49, 227, 196, 7, 172, 22, 254]) }, logicalIndex := 28, digest := (bytes [228, 49, 68, 70, 171, 104, 219, 143, 14, 198, 244, 25, 53, 98, 211, 75, 148, 14, 190, 247, 181, 218, 158, 239, 149, 181, 105, 155, 187, 206, 1, 129]) }, valueDigest := (bytes [191, 59, 111, 91, 175, 174, 193, 106, 252, 237, 179, 109, 105, 90, 100, 212, 35, 239, 230, 162, 83, 17, 88, 13, 240, 150, 187, 164, 56, 114, 73, 39]), digest := (bytes [0, 246, 160, 121, 86, 247, 118, 202, 26, 120, 220, 155, 194, 122, 193, 229, 214, 70, 4, 38, 18, 243, 44, 123, 80, 244, 64, 114, 215, 121, 214, 30]) }) }, digest := (bytes [27, 204, 171, 240, 12, 168, 36, 14, 208, 180, 185, 130, 62, 84, 230, 173, 109, 139, 159, 254, 41, 227, 61, 151, 142, 239, 59, 167, 140, 78, 18, 180]) }, digest := (bytes [58, 79, 60, 5, 44, 217, 210, 184, 12, 93, 193, 41, 184, 126, 53, 85, 15, 125, 156, 137, 120, 193, 126, 139, 36, 248, 235, 179, 121, 12, 254, 237]) }
    , bindings := { claim := { stageClaimBundleDigest := (bytes [245, 72, 75, 42, 73, 229, 163, 53, 146, 214, 107, 216, 213, 85, 133, 116, 173, 47, 114, 185, 134, 203, 104, 165, 250, 92, 247, 14, 227, 198, 71, 208]), stagePackageBundleDigest := (bytes [202, 244, 4, 158, 46, 125, 232, 78, 96, 136, 208, 229, 133, 159, 55, 23, 25, 188, 40, 64, 162, 32, 87, 74, 10, 162, 215, 241, 22, 9, 27, 112]), stage1PackageDigest := (bytes [84, 206, 142, 168, 93, 56, 75, 141, 229, 55, 180, 100, 199, 16, 42, 116, 200, 87, 88, 19, 121, 131, 122, 152, 187, 79, 10, 207, 157, 128, 75, 64]), stage2PackageDigest := (bytes [233, 244, 5, 85, 164, 65, 201, 245, 154, 6, 245, 55, 160, 133, 24, 0, 98, 0, 72, 170, 44, 114, 128, 216, 10, 232, 185, 75, 115, 11, 21, 57]), stage3PackageDigest := (bytes [248, 162, 12, 203, 170, 40, 43, 20, 152, 3, 84, 198, 147, 220, 41, 13, 65, 180, 249, 53, 251, 90, 130, 174, 144, 179, 189, 160, 32, 203, 228, 148]), preparedStepBindingsDigest := (bytes [122, 127, 230, 234, 20, 88, 54, 132, 38, 4, 241, 103, 237, 27, 91, 231, 123, 166, 255, 110, 210, 175, 85, 2, 174, 249, 69, 66, 249, 6, 108, 229]), bindingCount := 29, stage1RowCount := 29, stage2RegisterReadCount := 52, stage2RegisterWriteCount := 28, stage2RamEventCount := 0, stage3ContinuityCount := 9, points := { firstBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [122, 127, 230, 234, 20, 88, 54, 132, 38, 4, 241, 103, 237, 27, 91, 231, 123, 166, 255, 110, 210, 175, 85, 2, 174, 249, 69, 66, 249, 6, 108, 229]), layoutVersion := 1, digest := (bytes [215, 6, 107, 99, 9, 197, 39, 196, 223, 108, 143, 237, 212, 231, 138, 42, 173, 166, 236, 60, 74, 36, 18, 156, 222, 155, 22, 13, 80, 190, 95, 159]) }, logicalIndex := 0, digest := (bytes [171, 49, 1, 12, 69, 14, 15, 201, 249, 204, 167, 237, 104, 209, 29, 108, 202, 78, 193, 126, 84, 186, 212, 151, 104, 222, 125, 110, 105, 134, 37, 235]) }, valueDigest := (bytes [196, 127, 115, 228, 145, 235, 105, 203, 91, 30, 41, 234, 216, 138, 118, 223, 152, 13, 133, 59, 128, 32, 23, 132, 0, 186, 217, 35, 34, 46, 143, 135]), digest := (bytes [203, 112, 20, 17, 113, 59, 197, 164, 202, 156, 132, 37, 95, 192, 97, 147, 190, 206, 71, 113, 152, 141, 206, 159, 215, 125, 89, 37, 22, 227, 20, 131]) }), lastBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [122, 127, 230, 234, 20, 88, 54, 132, 38, 4, 241, 103, 237, 27, 91, 231, 123, 166, 255, 110, 210, 175, 85, 2, 174, 249, 69, 66, 249, 6, 108, 229]), layoutVersion := 1, digest := (bytes [215, 6, 107, 99, 9, 197, 39, 196, 223, 108, 143, 237, 212, 231, 138, 42, 173, 166, 236, 60, 74, 36, 18, 156, 222, 155, 22, 13, 80, 190, 95, 159]) }, logicalIndex := 28, digest := (bytes [171, 95, 136, 199, 207, 5, 220, 122, 141, 201, 129, 6, 239, 80, 68, 163, 14, 62, 45, 85, 255, 197, 79, 186, 195, 70, 166, 243, 177, 37, 43, 105]) }, valueDigest := (bytes [210, 164, 188, 10, 200, 87, 23, 227, 108, 94, 15, 153, 245, 204, 108, 191, 76, 213, 158, 176, 59, 20, 86, 180, 2, 103, 191, 35, 54, 77, 76, 101]), digest := (bytes [194, 117, 10, 236, 136, 85, 123, 199, 51, 29, 154, 128, 208, 86, 3, 153, 199, 132, 45, 44, 12, 184, 174, 96, 105, 136, 167, 90, 131, 116, 154, 204]) }) }, digest := (bytes [124, 208, 101, 209, 62, 21, 140, 193, 138, 37, 15, 244, 160, 205, 171, 166, 3, 198, 190, 195, 16, 50, 133, 17, 101, 77, 250, 179, 207, 49, 218, 161]) }, packaged := { statementDigest := (bytes [234, 84, 103, 42, 99, 234, 32, 44, 157, 30, 86, 2, 188, 238, 123, 147, 75, 240, 246, 110, 9, 133, 177, 108, 120, 157, 4, 225, 127, 62, 255, 81]), proofDigest := (bytes [137, 80, 48, 57, 0, 162, 27, 1, 209, 108, 75, 59, 197, 223, 135, 48, 48, 133, 15, 52, 246, 157, 156, 180, 186, 145, 33, 56, 203, 173, 137, 205]) }, digest := (bytes [98, 122, 12, 239, 168, 23, 243, 235, 43, 254, 227, 125, 21, 191, 120, 14, 197, 0, 137, 95, 184, 231, 127, 220, 153, 170, 197, 125, 76, 153, 34, 171]) }
    , preparedSteps := { claim := { executionDigest := (bytes [74, 202, 66, 25, 106, 38, 91, 108, 83, 143, 56, 156, 203, 227, 101, 222, 4, 137, 150, 5, 195, 49, 240, 232, 104, 115, 55, 93, 227, 232, 236, 253]), finalStateDigest := (bytes [182, 31, 54, 213, 113, 159, 201, 136, 65, 181, 111, 174, 113, 197, 150, 29, 93, 126, 40, 13, 253, 225, 7, 190, 200, 101, 176, 45, 199, 60, 8, 160]), transcriptFinalDigest := (bytes [12, 192, 210, 153, 196, 189, 212, 22, 158, 203, 243, 19, 37, 237, 245, 141, 129, 40, 74, 48, 7, 211, 157, 135, 182, 198, 7, 50, 149, 140, 10, 64]), preparedStepCount := 29, finalPc := 36, halted := true, points := { firstPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [2, 195, 15, 176, 74, 156, 14, 145, 205, 30, 105, 114, 34, 141, 242, 217, 105, 100, 117, 46, 249, 188, 28, 111, 72, 195, 48, 19, 21, 39, 77, 21]), layoutVersion := 3, digest := (bytes [107, 210, 58, 64, 103, 214, 200, 23, 157, 252, 53, 151, 94, 117, 179, 18, 97, 24, 125, 232, 65, 255, 83, 37, 252, 49, 227, 196, 7, 172, 22, 254]) }, logicalIndex := 0, digest := (bytes [132, 75, 176, 50, 98, 124, 10, 163, 65, 72, 164, 172, 236, 29, 57, 36, 144, 74, 213, 185, 85, 221, 229, 157, 190, 66, 127, 60, 109, 248, 105, 36]) }, valueDigest := (bytes [15, 203, 82, 147, 182, 107, 150, 168, 159, 107, 204, 115, 170, 200, 12, 67, 125, 81, 225, 219, 175, 26, 58, 39, 55, 35, 134, 130, 62, 126, 3, 37]), digest := (bytes [143, 201, 227, 113, 227, 52, 190, 147, 201, 197, 250, 34, 101, 210, 119, 246, 66, 86, 0, 57, 190, 96, 107, 156, 186, 34, 219, 71, 26, 85, 5, 244]) }), lastPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [2, 195, 15, 176, 74, 156, 14, 145, 205, 30, 105, 114, 34, 141, 242, 217, 105, 100, 117, 46, 249, 188, 28, 111, 72, 195, 48, 19, 21, 39, 77, 21]), layoutVersion := 3, digest := (bytes [107, 210, 58, 64, 103, 214, 200, 23, 157, 252, 53, 151, 94, 117, 179, 18, 97, 24, 125, 232, 65, 255, 83, 37, 252, 49, 227, 196, 7, 172, 22, 254]) }, logicalIndex := 28, digest := (bytes [228, 49, 68, 70, 171, 104, 219, 143, 14, 198, 244, 25, 53, 98, 211, 75, 148, 14, 190, 247, 181, 218, 158, 239, 149, 181, 105, 155, 187, 206, 1, 129]) }, valueDigest := (bytes [191, 59, 111, 91, 175, 174, 193, 106, 252, 237, 179, 109, 105, 90, 100, 212, 35, 239, 230, 162, 83, 17, 88, 13, 240, 150, 187, 164, 56, 114, 73, 39]), digest := (bytes [0, 246, 160, 121, 86, 247, 118, 202, 26, 120, 220, 155, 194, 122, 193, 229, 214, 70, 4, 38, 18, 243, 44, 123, 80, 244, 64, 114, 215, 121, 214, 30]) }) }, digest := (bytes [27, 204, 171, 240, 12, 168, 36, 14, 208, 180, 185, 130, 62, 84, 230, 173, 109, 139, 159, 254, 41, 227, 61, 151, 142, 239, 59, 167, 140, 78, 18, 180]) }, packaged := { statementDigest := (bytes [7, 12, 199, 212, 187, 113, 131, 18, 65, 119, 2, 191, 69, 114, 235, 238, 130, 191, 76, 39, 178, 155, 104, 158, 147, 115, 167, 151, 253, 231, 89, 156]), proofDigest := (bytes [115, 159, 82, 105, 162, 255, 41, 58, 7, 252, 19, 187, 200, 141, 218, 36, 251, 107, 135, 199, 174, 253, 94, 232, 1, 61, 70, 70, 123, 12, 170, 233]) }, digest := (bytes [241, 188, 244, 234, 213, 229, 19, 141, 178, 83, 184, 95, 217, 231, 124, 251, 178, 198, 193, 160, 225, 156, 159, 131, 198, 255, 189, 217, 235, 245, 110, 247]) }
    , digest := (bytes [191, 138, 72, 200, 97, 143, 211, 249, 193, 138, 167, 4, 198, 38, 157, 94, 2, 19, 193, 51, 126, 165, 91, 115, 203, 137, 149, 175, 245, 167, 100, 184])
  }

def stepComposition : StepCompositionSurfaceView :=
  {
    stage1SemanticsDigest := (bytes [151, 73, 188, 62, 1, 160, 205, 232, 46, 120, 106, 111, 186, 165, 144, 112, 153, 155, 231, 104, 55, 176, 101, 4, 243, 217, 52, 115, 2, 180, 124, 74])
    , stage2SemanticsDigest := (bytes [71, 165, 103, 60, 176, 119, 41, 187, 9, 96, 98, 141, 232, 143, 131, 238, 73, 116, 248, 225, 225, 131, 8, 236, 116, 166, 89, 24, 117, 165, 214, 1])
    , stage2TemporalDigest := (bytes [195, 152, 255, 192, 176, 27, 136, 196, 249, 38, 175, 31, 110, 44, 158, 128, 23, 103, 151, 52, 56, 71, 124, 144, 217, 67, 251, 124, 11, 175, 215, 69])
    , stage3SemanticsDigest := (bytes [243, 239, 35, 61, 103, 231, 77, 91, 40, 229, 166, 118, 83, 233, 33, 208, 140, 96, 68, 173, 102, 218, 100, 207, 213, 43, 87, 72, 215, 101, 124, 198])
    , rootExecutionDigest := (bytes [123, 201, 239, 26, 230, 117, 95, 47, 52, 201, 205, 87, 67, 31, 70, 164, 233, 232, 42, 186, 14, 182, 49, 15, 66, 125, 178, 165, 255, 154, 41, 96])
    , preparedStepBindingsDigest := (bytes [122, 127, 230, 234, 20, 88, 54, 132, 38, 4, 241, 103, 237, 27, 91, 231, 123, 166, 255, 110, 210, 175, 85, 2, 174, 249, 69, 66, 249, 6, 108, 229])
    , rowChunkRoutesDigest := (bytes [157, 56, 49, 88, 58, 136, 76, 107, 255, 120, 158, 198, 111, 202, 189, 3, 228, 179, 63, 132, 138, 132, 211, 15, 30, 108, 63, 231, 4, 55, 240, 227])
    , realRowCount := 9
    , preparedStepCount := 29
    , firstRealStepIndex := 0
    , lastRealStepIndex := 8
    , initialPc := 0
    , finalPc := 36
    , halted := true
    , digest := (bytes [107, 41, 240, 109, 155, 112, 153, 151, 79, 166, 87, 66, 178, 127, 38, 48, 168, 166, 103, 167, 90, 160, 245, 174, 65, 228, 77, 180, 42, 163, 97, 110])
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
    name := "unsigned_divrem_chain_ecall"
    , source := {
  manifest := { name := "unsigned_divrem_chain_ecall", fixtureId := "unsigned_divrem_chain_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.unsignedDivRem, .controlFlow] }
  , startPc := 0
  , programWords := [35705523, 35713843, 37868475, 37876795, 44357043, 44365363, 48682939, 48691259, 115]
  , initialRegisters := [0, 20, 6, 18446744073709551615, 3, 0, 0, 0, 0, 9, 0, 0, 0, 18446744071562067969, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , initialMemory := []
  , transcriptSeed := (bytes [114, 118, 54, 52, 105, 109, 45, 117, 110, 115, 105, 103, 110, 101, 100, 45, 100, 105, 118, 114, 101, 109, 45, 118, 49])
}
    , derived := {
  manifest := { name := "unsigned_divrem_chain_ecall", fixtureId := "unsigned_divrem_chain_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.unsignedDivRem, .controlFlow] }
  , executionRows := [{
  traceIndex := 0
  , stepIndex := 0
  , sequenceIndex := 0
  , pc := 0
  , nextPc := 0
  , word := 35705523
  , opcode := .divu
  , traceOpcode := none
  , traceVirtualOpcode := (some .advice)
  , family := .unsignedDivRem
  , rs1 := 1
  , rs1Value := 20
  , rs2 := 2
  , rs2Value := 6
  , rd := 5
  , rdBefore := 0
  , rdAfter := 3
  , imm := 0
  , aluResult := 3
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := true
  , virtualSequenceRemaining := (some 2)
  , isEffectRow := true
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 1
  , stepIndex := 0
  , sequenceIndex := 1
  , pc := 0
  , nextPc := 0
  , word := 35705523
  , opcode := .divu
  , traceOpcode := (some .mul)
  , traceVirtualOpcode := none
  , family := .unsignedDivRem
  , rs1 := 5
  , rs1Value := 3
  , rs2 := 2
  , rs2Value := 6
  , rd := 40
  , rdBefore := 0
  , rdAfter := 18
  , imm := 0
  , aluResult := 18
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
  traceIndex := 2
  , stepIndex := 0
  , sequenceIndex := 2
  , pc := 0
  , nextPc := 4
  , word := 35705523
  , opcode := .divu
  , traceOpcode := (some .sub)
  , traceVirtualOpcode := none
  , family := .unsignedDivRem
  , rs1 := 1
  , rs1Value := 20
  , rs2 := 40
  , rs2Value := 18
  , rd := 41
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
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 0)
  , isEffectRow := false
  , isCommitRow := true
  , isReal := true
}, {
  traceIndex := 3
  , stepIndex := 1
  , sequenceIndex := 0
  , pc := 4
  , nextPc := 4
  , word := 35713843
  , opcode := .remu
  , traceOpcode := none
  , traceVirtualOpcode := (some .advice)
  , family := .unsignedDivRem
  , rs1 := 1
  , rs1Value := 20
  , rs2 := 2
  , rs2Value := 6
  , rd := 40
  , rdBefore := 0
  , rdAfter := 3
  , imm := 0
  , aluResult := 3
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := true
  , virtualSequenceRemaining := (some 2)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 4
  , stepIndex := 1
  , sequenceIndex := 1
  , pc := 4
  , nextPc := 4
  , word := 35713843
  , opcode := .remu
  , traceOpcode := (some .mul)
  , traceVirtualOpcode := none
  , family := .unsignedDivRem
  , rs1 := 40
  , rs1Value := 3
  , rs2 := 2
  , rs2Value := 6
  , rd := 41
  , rdBefore := 0
  , rdAfter := 18
  , imm := 0
  , aluResult := 18
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
  traceIndex := 5
  , stepIndex := 1
  , sequenceIndex := 2
  , pc := 4
  , nextPc := 8
  , word := 35713843
  , opcode := .remu
  , traceOpcode := (some .sub)
  , traceVirtualOpcode := none
  , family := .unsignedDivRem
  , rs1 := 1
  , rs1Value := 20
  , rs2 := 41
  , rs2Value := 18
  , rd := 6
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
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 0)
  , isEffectRow := true
  , isCommitRow := true
  , isReal := true
}, {
  traceIndex := 6
  , stepIndex := 2
  , sequenceIndex := 0
  , pc := 8
  , nextPc := 8
  , word := 37868475
  , opcode := .divuw
  , traceOpcode := none
  , traceVirtualOpcode := (some .advice)
  , family := .unsignedDivRem
  , rs1 := 3
  , rs1Value := 18446744073709551615
  , rs2 := 4
  , rs2Value := 3
  , rd := 7
  , rdBefore := 0
  , rdAfter := 1431655765
  , imm := 0
  , aluResult := 1431655765
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := true
  , virtualSequenceRemaining := (some 3)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 7
  , stepIndex := 2
  , sequenceIndex := 1
  , pc := 8
  , nextPc := 8
  , word := 37868475
  , opcode := .divuw
  , traceOpcode := (some .mul)
  , traceVirtualOpcode := none
  , family := .unsignedDivRem
  , rs1 := 7
  , rs1Value := 1431655765
  , rs2 := 4
  , rs2Value := 3
  , rd := 40
  , rdBefore := 0
  , rdAfter := 4294967295
  , imm := 0
  , aluResult := 4294967295
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
  traceIndex := 8
  , stepIndex := 2
  , sequenceIndex := 2
  , pc := 8
  , nextPc := 8
  , word := 37868475
  , opcode := .divuw
  , traceOpcode := (some .sub)
  , traceVirtualOpcode := none
  , family := .unsignedDivRem
  , rs1 := 3
  , rs1Value := 18446744073709551615
  , rs2 := 40
  , rs2Value := 4294967295
  , rd := 41
  , rdBefore := 0
  , rdAfter := 18446744069414584320
  , imm := 0
  , aluResult := 18446744069414584320
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
  traceIndex := 9
  , stepIndex := 2
  , sequenceIndex := 3
  , pc := 8
  , nextPc := 12
  , word := 37868475
  , opcode := .divuw
  , traceOpcode := none
  , traceVirtualOpcode := (some .signExtendWord)
  , family := .unsignedDivRem
  , rs1 := 7
  , rs1Value := 1431655765
  , rs2 := 0
  , rs2Value := 0
  , rd := 7
  , rdBefore := 1431655765
  , rdAfter := 1431655765
  , imm := 0
  , aluResult := 1431655765
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
  traceIndex := 10
  , stepIndex := 3
  , sequenceIndex := 0
  , pc := 12
  , nextPc := 12
  , word := 37876795
  , opcode := .remuw
  , traceOpcode := none
  , traceVirtualOpcode := (some .advice)
  , family := .unsignedDivRem
  , rs1 := 3
  , rs1Value := 18446744073709551615
  , rs2 := 4
  , rs2Value := 3
  , rd := 40
  , rdBefore := 0
  , rdAfter := 1431655765
  , imm := 0
  , aluResult := 1431655765
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := true
  , virtualSequenceRemaining := (some 3)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 11
  , stepIndex := 3
  , sequenceIndex := 1
  , pc := 12
  , nextPc := 12
  , word := 37876795
  , opcode := .remuw
  , traceOpcode := (some .mul)
  , traceVirtualOpcode := none
  , family := .unsignedDivRem
  , rs1 := 40
  , rs1Value := 1431655765
  , rs2 := 4
  , rs2Value := 3
  , rd := 41
  , rdBefore := 0
  , rdAfter := 4294967295
  , imm := 0
  , aluResult := 4294967295
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
  traceIndex := 12
  , stepIndex := 3
  , sequenceIndex := 2
  , pc := 12
  , nextPc := 12
  , word := 37876795
  , opcode := .remuw
  , traceOpcode := (some .sub)
  , traceVirtualOpcode := none
  , family := .unsignedDivRem
  , rs1 := 3
  , rs1Value := 18446744073709551615
  , rs2 := 41
  , rs2Value := 4294967295
  , rd := 8
  , rdBefore := 0
  , rdAfter := 18446744069414584320
  , imm := 0
  , aluResult := 18446744069414584320
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
  traceIndex := 13
  , stepIndex := 3
  , sequenceIndex := 3
  , pc := 12
  , nextPc := 16
  , word := 37876795
  , opcode := .remuw
  , traceOpcode := none
  , traceVirtualOpcode := (some .signExtendWord)
  , family := .unsignedDivRem
  , rs1 := 8
  , rs1Value := 18446744069414584320
  , rs2 := 0
  , rs2Value := 0
  , rd := 8
  , rdBefore := 18446744069414584320
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
  traceIndex := 14
  , stepIndex := 4
  , sequenceIndex := 0
  , pc := 16
  , nextPc := 16
  , word := 44357043
  , opcode := .divu
  , traceOpcode := none
  , traceVirtualOpcode := (some .advice)
  , family := .unsignedDivRem
  , rs1 := 9
  , rs1Value := 9
  , rs2 := 10
  , rs2Value := 0
  , rd := 11
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
  , virtualSequenceRemaining := (some 2)
  , isEffectRow := true
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 15
  , stepIndex := 4
  , sequenceIndex := 1
  , pc := 16
  , nextPc := 16
  , word := 44357043
  , opcode := .divu
  , traceOpcode := (some .mul)
  , traceVirtualOpcode := none
  , family := .unsignedDivRem
  , rs1 := 11
  , rs1Value := 18446744073709551615
  , rs2 := 10
  , rs2Value := 0
  , rd := 40
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
  , virtualSequenceRemaining := (some 1)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 16
  , stepIndex := 4
  , sequenceIndex := 2
  , pc := 16
  , nextPc := 20
  , word := 44357043
  , opcode := .divu
  , traceOpcode := (some .sub)
  , traceVirtualOpcode := none
  , family := .unsignedDivRem
  , rs1 := 9
  , rs1Value := 9
  , rs2 := 40
  , rs2Value := 0
  , rd := 41
  , rdBefore := 0
  , rdAfter := 9
  , imm := 0
  , aluResult := 9
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := false
  , virtualSequenceRemaining := (some 0)
  , isEffectRow := false
  , isCommitRow := true
  , isReal := true
}, {
  traceIndex := 17
  , stepIndex := 5
  , sequenceIndex := 0
  , pc := 20
  , nextPc := 20
  , word := 44365363
  , opcode := .remu
  , traceOpcode := none
  , traceVirtualOpcode := (some .advice)
  , family := .unsignedDivRem
  , rs1 := 9
  , rs1Value := 9
  , rs2 := 10
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
  , virtualSequenceRemaining := (some 2)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 18
  , stepIndex := 5
  , sequenceIndex := 1
  , pc := 20
  , nextPc := 20
  , word := 44365363
  , opcode := .remu
  , traceOpcode := (some .mul)
  , traceVirtualOpcode := none
  , family := .unsignedDivRem
  , rs1 := 40
  , rs1Value := 18446744073709551615
  , rs2 := 10
  , rs2Value := 0
  , rd := 41
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
  , virtualSequenceRemaining := (some 1)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 19
  , stepIndex := 5
  , sequenceIndex := 2
  , pc := 20
  , nextPc := 24
  , word := 44365363
  , opcode := .remu
  , traceOpcode := (some .sub)
  , traceVirtualOpcode := none
  , family := .unsignedDivRem
  , rs1 := 9
  , rs1Value := 9
  , rs2 := 41
  , rs2Value := 0
  , rd := 12
  , rdBefore := 0
  , rdAfter := 9
  , imm := 0
  , aluResult := 9
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
  traceIndex := 20
  , stepIndex := 6
  , sequenceIndex := 0
  , pc := 24
  , nextPc := 24
  , word := 48682939
  , opcode := .divuw
  , traceOpcode := none
  , traceVirtualOpcode := (some .advice)
  , family := .unsignedDivRem
  , rs1 := 13
  , rs1Value := 18446744071562067969
  , rs2 := 14
  , rs2Value := 0
  , rd := 15
  , rdBefore := 0
  , rdAfter := 4294967295
  , imm := 0
  , aluResult := 4294967295
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := true
  , virtualSequenceRemaining := (some 3)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 21
  , stepIndex := 6
  , sequenceIndex := 1
  , pc := 24
  , nextPc := 24
  , word := 48682939
  , opcode := .divuw
  , traceOpcode := (some .mul)
  , traceVirtualOpcode := none
  , family := .unsignedDivRem
  , rs1 := 15
  , rs1Value := 4294967295
  , rs2 := 14
  , rs2Value := 0
  , rd := 40
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
  , virtualSequenceRemaining := (some 2)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 22
  , stepIndex := 6
  , sequenceIndex := 2
  , pc := 24
  , nextPc := 24
  , word := 48682939
  , opcode := .divuw
  , traceOpcode := (some .sub)
  , traceVirtualOpcode := none
  , family := .unsignedDivRem
  , rs1 := 13
  , rs1Value := 18446744071562067969
  , rs2 := 40
  , rs2Value := 0
  , rd := 41
  , rdBefore := 0
  , rdAfter := 18446744071562067969
  , imm := 0
  , aluResult := 18446744071562067969
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
  traceIndex := 23
  , stepIndex := 6
  , sequenceIndex := 3
  , pc := 24
  , nextPc := 28
  , word := 48682939
  , opcode := .divuw
  , traceOpcode := none
  , traceVirtualOpcode := (some .signExtendWord)
  , family := .unsignedDivRem
  , rs1 := 15
  , rs1Value := 4294967295
  , rs2 := 0
  , rs2Value := 0
  , rd := 15
  , rdBefore := 4294967295
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
  traceIndex := 24
  , stepIndex := 7
  , sequenceIndex := 0
  , pc := 28
  , nextPc := 28
  , word := 48691259
  , opcode := .remuw
  , traceOpcode := none
  , traceVirtualOpcode := (some .advice)
  , family := .unsignedDivRem
  , rs1 := 13
  , rs1Value := 18446744071562067969
  , rs2 := 14
  , rs2Value := 0
  , rd := 40
  , rdBefore := 0
  , rdAfter := 4294967295
  , imm := 0
  , aluResult := 4294967295
  , effectiveAddr := none
  , memoryBefore := none
  , memoryAfter := none
  , writesRd := true
  , writesRam := false
  , halted := false
  , isFirstInSequence := true
  , virtualSequenceRemaining := (some 3)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 25
  , stepIndex := 7
  , sequenceIndex := 1
  , pc := 28
  , nextPc := 28
  , word := 48691259
  , opcode := .remuw
  , traceOpcode := (some .mul)
  , traceVirtualOpcode := none
  , family := .unsignedDivRem
  , rs1 := 40
  , rs1Value := 4294967295
  , rs2 := 14
  , rs2Value := 0
  , rd := 41
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
  , virtualSequenceRemaining := (some 2)
  , isEffectRow := false
  , isCommitRow := false
  , isReal := false
}, {
  traceIndex := 26
  , stepIndex := 7
  , sequenceIndex := 2
  , pc := 28
  , nextPc := 28
  , word := 48691259
  , opcode := .remuw
  , traceOpcode := (some .sub)
  , traceVirtualOpcode := none
  , family := .unsignedDivRem
  , rs1 := 13
  , rs1Value := 18446744071562067969
  , rs2 := 41
  , rs2Value := 0
  , rd := 16
  , rdBefore := 0
  , rdAfter := 18446744071562067969
  , imm := 0
  , aluResult := 18446744071562067969
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
  traceIndex := 27
  , stepIndex := 7
  , sequenceIndex := 3
  , pc := 28
  , nextPc := 32
  , word := 48691259
  , opcode := .remuw
  , traceOpcode := none
  , traceVirtualOpcode := (some .signExtendWord)
  , family := .unsignedDivRem
  , rs1 := 16
  , rs1Value := 18446744071562067969
  , rs2 := 0
  , rs2Value := 0
  , rd := 16
  , rdBefore := 18446744071562067969
  , rdAfter := 18446744071562067969
  , imm := 0
  , aluResult := 18446744071562067969
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
  traceIndex := 28
  , stepIndex := 8
  , sequenceIndex := 0
  , pc := 32
  , nextPc := 36
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
  , stage1 := { rows := [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 35705523, opcode := .divu, traceOpcode := none, traceVirtualOpcode := (some .advice), family := .unsignedDivRem, nextPc := 0, aluResult := 3, effectiveAddr := none, writesRd := true, rd := 5, rdAfter := 3, isFirstInSequence := true, virtualSequenceRemaining := (some 2), isEffectRow := true, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 1, stepIndex := 0, sequenceIndex := 1, fetchPc := 0, fetchedWord := 35705523, opcode := .divu, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .unsignedDivRem, nextPc := 0, aluResult := 18, effectiveAddr := none, writesRd := true, rd := 40, rdAfter := 18, isFirstInSequence := false, virtualSequenceRemaining := (some 1), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 2, stepIndex := 0, sequenceIndex := 2, fetchPc := 0, fetchedWord := 35705523, opcode := .divu, traceOpcode := (some .sub), traceVirtualOpcode := none, family := .unsignedDivRem, nextPc := 4, aluResult := 2, effectiveAddr := none, writesRd := true, rd := 41, rdAfter := 2, isFirstInSequence := false, virtualSequenceRemaining := (some 0), isEffectRow := false, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 3, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 35713843, opcode := .remu, traceOpcode := none, traceVirtualOpcode := (some .advice), family := .unsignedDivRem, nextPc := 4, aluResult := 3, effectiveAddr := none, writesRd := true, rd := 40, rdAfter := 3, isFirstInSequence := true, virtualSequenceRemaining := (some 2), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 4, stepIndex := 1, sequenceIndex := 1, fetchPc := 4, fetchedWord := 35713843, opcode := .remu, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .unsignedDivRem, nextPc := 4, aluResult := 18, effectiveAddr := none, writesRd := true, rd := 41, rdAfter := 18, isFirstInSequence := false, virtualSequenceRemaining := (some 1), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 5, stepIndex := 1, sequenceIndex := 2, fetchPc := 4, fetchedWord := 35713843, opcode := .remu, traceOpcode := (some .sub), traceVirtualOpcode := none, family := .unsignedDivRem, nextPc := 8, aluResult := 2, effectiveAddr := none, writesRd := true, rd := 6, rdAfter := 2, isFirstInSequence := false, virtualSequenceRemaining := (some 0), isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 6, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 37868475, opcode := .divuw, traceOpcode := none, traceVirtualOpcode := (some .advice), family := .unsignedDivRem, nextPc := 8, aluResult := 1431655765, effectiveAddr := none, writesRd := true, rd := 7, rdAfter := 1431655765, isFirstInSequence := true, virtualSequenceRemaining := (some 3), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 7, stepIndex := 2, sequenceIndex := 1, fetchPc := 8, fetchedWord := 37868475, opcode := .divuw, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .unsignedDivRem, nextPc := 8, aluResult := 4294967295, effectiveAddr := none, writesRd := true, rd := 40, rdAfter := 4294967295, isFirstInSequence := false, virtualSequenceRemaining := (some 2), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 8, stepIndex := 2, sequenceIndex := 2, fetchPc := 8, fetchedWord := 37868475, opcode := .divuw, traceOpcode := (some .sub), traceVirtualOpcode := none, family := .unsignedDivRem, nextPc := 8, aluResult := 18446744069414584320, effectiveAddr := none, writesRd := true, rd := 41, rdAfter := 18446744069414584320, isFirstInSequence := false, virtualSequenceRemaining := (some 1), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 9, stepIndex := 2, sequenceIndex := 3, fetchPc := 8, fetchedWord := 37868475, opcode := .divuw, traceOpcode := none, traceVirtualOpcode := (some .signExtendWord), family := .unsignedDivRem, nextPc := 12, aluResult := 1431655765, effectiveAddr := none, writesRd := true, rd := 7, rdAfter := 1431655765, isFirstInSequence := false, virtualSequenceRemaining := (some 0), isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 10, stepIndex := 3, sequenceIndex := 0, fetchPc := 12, fetchedWord := 37876795, opcode := .remuw, traceOpcode := none, traceVirtualOpcode := (some .advice), family := .unsignedDivRem, nextPc := 12, aluResult := 1431655765, effectiveAddr := none, writesRd := true, rd := 40, rdAfter := 1431655765, isFirstInSequence := true, virtualSequenceRemaining := (some 3), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 11, stepIndex := 3, sequenceIndex := 1, fetchPc := 12, fetchedWord := 37876795, opcode := .remuw, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .unsignedDivRem, nextPc := 12, aluResult := 4294967295, effectiveAddr := none, writesRd := true, rd := 41, rdAfter := 4294967295, isFirstInSequence := false, virtualSequenceRemaining := (some 2), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 12, stepIndex := 3, sequenceIndex := 2, fetchPc := 12, fetchedWord := 37876795, opcode := .remuw, traceOpcode := (some .sub), traceVirtualOpcode := none, family := .unsignedDivRem, nextPc := 12, aluResult := 18446744069414584320, effectiveAddr := none, writesRd := true, rd := 8, rdAfter := 18446744069414584320, isFirstInSequence := false, virtualSequenceRemaining := (some 1), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 13, stepIndex := 3, sequenceIndex := 3, fetchPc := 12, fetchedWord := 37876795, opcode := .remuw, traceOpcode := none, traceVirtualOpcode := (some .signExtendWord), family := .unsignedDivRem, nextPc := 16, aluResult := 0, effectiveAddr := none, writesRd := true, rd := 8, rdAfter := 0, isFirstInSequence := false, virtualSequenceRemaining := (some 0), isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 14, stepIndex := 4, sequenceIndex := 0, fetchPc := 16, fetchedWord := 44357043, opcode := .divu, traceOpcode := none, traceVirtualOpcode := (some .advice), family := .unsignedDivRem, nextPc := 16, aluResult := 18446744073709551615, effectiveAddr := none, writesRd := true, rd := 11, rdAfter := 18446744073709551615, isFirstInSequence := true, virtualSequenceRemaining := (some 2), isEffectRow := true, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 15, stepIndex := 4, sequenceIndex := 1, fetchPc := 16, fetchedWord := 44357043, opcode := .divu, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .unsignedDivRem, nextPc := 16, aluResult := 0, effectiveAddr := none, writesRd := true, rd := 40, rdAfter := 0, isFirstInSequence := false, virtualSequenceRemaining := (some 1), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 16, stepIndex := 4, sequenceIndex := 2, fetchPc := 16, fetchedWord := 44357043, opcode := .divu, traceOpcode := (some .sub), traceVirtualOpcode := none, family := .unsignedDivRem, nextPc := 20, aluResult := 9, effectiveAddr := none, writesRd := true, rd := 41, rdAfter := 9, isFirstInSequence := false, virtualSequenceRemaining := (some 0), isEffectRow := false, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 17, stepIndex := 5, sequenceIndex := 0, fetchPc := 20, fetchedWord := 44365363, opcode := .remu, traceOpcode := none, traceVirtualOpcode := (some .advice), family := .unsignedDivRem, nextPc := 20, aluResult := 18446744073709551615, effectiveAddr := none, writesRd := true, rd := 40, rdAfter := 18446744073709551615, isFirstInSequence := true, virtualSequenceRemaining := (some 2), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 18, stepIndex := 5, sequenceIndex := 1, fetchPc := 20, fetchedWord := 44365363, opcode := .remu, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .unsignedDivRem, nextPc := 20, aluResult := 0, effectiveAddr := none, writesRd := true, rd := 41, rdAfter := 0, isFirstInSequence := false, virtualSequenceRemaining := (some 1), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 19, stepIndex := 5, sequenceIndex := 2, fetchPc := 20, fetchedWord := 44365363, opcode := .remu, traceOpcode := (some .sub), traceVirtualOpcode := none, family := .unsignedDivRem, nextPc := 24, aluResult := 9, effectiveAddr := none, writesRd := true, rd := 12, rdAfter := 9, isFirstInSequence := false, virtualSequenceRemaining := (some 0), isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 20, stepIndex := 6, sequenceIndex := 0, fetchPc := 24, fetchedWord := 48682939, opcode := .divuw, traceOpcode := none, traceVirtualOpcode := (some .advice), family := .unsignedDivRem, nextPc := 24, aluResult := 4294967295, effectiveAddr := none, writesRd := true, rd := 15, rdAfter := 4294967295, isFirstInSequence := true, virtualSequenceRemaining := (some 3), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 21, stepIndex := 6, sequenceIndex := 1, fetchPc := 24, fetchedWord := 48682939, opcode := .divuw, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .unsignedDivRem, nextPc := 24, aluResult := 0, effectiveAddr := none, writesRd := true, rd := 40, rdAfter := 0, isFirstInSequence := false, virtualSequenceRemaining := (some 2), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 22, stepIndex := 6, sequenceIndex := 2, fetchPc := 24, fetchedWord := 48682939, opcode := .divuw, traceOpcode := (some .sub), traceVirtualOpcode := none, family := .unsignedDivRem, nextPc := 24, aluResult := 18446744071562067969, effectiveAddr := none, writesRd := true, rd := 41, rdAfter := 18446744071562067969, isFirstInSequence := false, virtualSequenceRemaining := (some 1), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 23, stepIndex := 6, sequenceIndex := 3, fetchPc := 24, fetchedWord := 48682939, opcode := .divuw, traceOpcode := none, traceVirtualOpcode := (some .signExtendWord), family := .unsignedDivRem, nextPc := 28, aluResult := 18446744073709551615, effectiveAddr := none, writesRd := true, rd := 15, rdAfter := 18446744073709551615, isFirstInSequence := false, virtualSequenceRemaining := (some 0), isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 24, stepIndex := 7, sequenceIndex := 0, fetchPc := 28, fetchedWord := 48691259, opcode := .remuw, traceOpcode := none, traceVirtualOpcode := (some .advice), family := .unsignedDivRem, nextPc := 28, aluResult := 4294967295, effectiveAddr := none, writesRd := true, rd := 40, rdAfter := 4294967295, isFirstInSequence := true, virtualSequenceRemaining := (some 3), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 25, stepIndex := 7, sequenceIndex := 1, fetchPc := 28, fetchedWord := 48691259, opcode := .remuw, traceOpcode := (some .mul), traceVirtualOpcode := none, family := .unsignedDivRem, nextPc := 28, aluResult := 0, effectiveAddr := none, writesRd := true, rd := 41, rdAfter := 0, isFirstInSequence := false, virtualSequenceRemaining := (some 2), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 26, stepIndex := 7, sequenceIndex := 2, fetchPc := 28, fetchedWord := 48691259, opcode := .remuw, traceOpcode := (some .sub), traceVirtualOpcode := none, family := .unsignedDivRem, nextPc := 28, aluResult := 18446744071562067969, effectiveAddr := none, writesRd := true, rd := 16, rdAfter := 18446744071562067969, isFirstInSequence := false, virtualSequenceRemaining := (some 1), isEffectRow := false, isCommitRow := false, isReal := false, preservesX0 := false }, { traceIndex := 27, stepIndex := 7, sequenceIndex := 3, fetchPc := 28, fetchedWord := 48691259, opcode := .remuw, traceOpcode := none, traceVirtualOpcode := (some .signExtendWord), family := .unsignedDivRem, nextPc := 32, aluResult := 18446744071562067969, effectiveAddr := none, writesRd := true, rd := 16, rdAfter := 18446744071562067969, isFirstInSequence := false, virtualSequenceRemaining := (some 0), isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 28, stepIndex := 8, sequenceIndex := 0, fetchPc := 32, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 36, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }] }
  , stage2 := {
  registerReads := [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 1, value := 20 }, { traceIndex := 0, stepIndex := 0, role := .rs2, reg := 2, value := 6 }, { traceIndex := 1, stepIndex := 0, role := .rs1, reg := 5, value := 3 }, { traceIndex := 1, stepIndex := 0, role := .rs2, reg := 2, value := 6 }, { traceIndex := 2, stepIndex := 0, role := .rs1, reg := 1, value := 20 }, { traceIndex := 2, stepIndex := 0, role := .rs2, reg := 40, value := 18 }, { traceIndex := 3, stepIndex := 1, role := .rs1, reg := 1, value := 20 }, { traceIndex := 3, stepIndex := 1, role := .rs2, reg := 2, value := 6 }, { traceIndex := 4, stepIndex := 1, role := .rs1, reg := 40, value := 3 }, { traceIndex := 4, stepIndex := 1, role := .rs2, reg := 2, value := 6 }, { traceIndex := 5, stepIndex := 1, role := .rs1, reg := 1, value := 20 }, { traceIndex := 5, stepIndex := 1, role := .rs2, reg := 41, value := 18 }, { traceIndex := 6, stepIndex := 2, role := .rs1, reg := 3, value := 18446744073709551615 }, { traceIndex := 6, stepIndex := 2, role := .rs2, reg := 4, value := 3 }, { traceIndex := 7, stepIndex := 2, role := .rs1, reg := 7, value := 1431655765 }, { traceIndex := 7, stepIndex := 2, role := .rs2, reg := 4, value := 3 }, { traceIndex := 8, stepIndex := 2, role := .rs1, reg := 3, value := 18446744073709551615 }, { traceIndex := 8, stepIndex := 2, role := .rs2, reg := 40, value := 4294967295 }, { traceIndex := 9, stepIndex := 2, role := .rs1, reg := 7, value := 1431655765 }, { traceIndex := 10, stepIndex := 3, role := .rs1, reg := 3, value := 18446744073709551615 }, { traceIndex := 10, stepIndex := 3, role := .rs2, reg := 4, value := 3 }, { traceIndex := 11, stepIndex := 3, role := .rs1, reg := 40, value := 1431655765 }, { traceIndex := 11, stepIndex := 3, role := .rs2, reg := 4, value := 3 }, { traceIndex := 12, stepIndex := 3, role := .rs1, reg := 3, value := 18446744073709551615 }, { traceIndex := 12, stepIndex := 3, role := .rs2, reg := 41, value := 4294967295 }, { traceIndex := 13, stepIndex := 3, role := .rs1, reg := 8, value := 18446744069414584320 }, { traceIndex := 14, stepIndex := 4, role := .rs1, reg := 9, value := 9 }, { traceIndex := 14, stepIndex := 4, role := .rs2, reg := 10, value := 0 }, { traceIndex := 15, stepIndex := 4, role := .rs1, reg := 11, value := 18446744073709551615 }, { traceIndex := 15, stepIndex := 4, role := .rs2, reg := 10, value := 0 }, { traceIndex := 16, stepIndex := 4, role := .rs1, reg := 9, value := 9 }, { traceIndex := 16, stepIndex := 4, role := .rs2, reg := 40, value := 0 }, { traceIndex := 17, stepIndex := 5, role := .rs1, reg := 9, value := 9 }, { traceIndex := 17, stepIndex := 5, role := .rs2, reg := 10, value := 0 }, { traceIndex := 18, stepIndex := 5, role := .rs1, reg := 40, value := 18446744073709551615 }, { traceIndex := 18, stepIndex := 5, role := .rs2, reg := 10, value := 0 }, { traceIndex := 19, stepIndex := 5, role := .rs1, reg := 9, value := 9 }, { traceIndex := 19, stepIndex := 5, role := .rs2, reg := 41, value := 0 }, { traceIndex := 20, stepIndex := 6, role := .rs1, reg := 13, value := 18446744071562067969 }, { traceIndex := 20, stepIndex := 6, role := .rs2, reg := 14, value := 0 }, { traceIndex := 21, stepIndex := 6, role := .rs1, reg := 15, value := 4294967295 }, { traceIndex := 21, stepIndex := 6, role := .rs2, reg := 14, value := 0 }, { traceIndex := 22, stepIndex := 6, role := .rs1, reg := 13, value := 18446744071562067969 }, { traceIndex := 22, stepIndex := 6, role := .rs2, reg := 40, value := 0 }, { traceIndex := 23, stepIndex := 6, role := .rs1, reg := 15, value := 4294967295 }, { traceIndex := 24, stepIndex := 7, role := .rs1, reg := 13, value := 18446744071562067969 }, { traceIndex := 24, stepIndex := 7, role := .rs2, reg := 14, value := 0 }, { traceIndex := 25, stepIndex := 7, role := .rs1, reg := 40, value := 4294967295 }, { traceIndex := 25, stepIndex := 7, role := .rs2, reg := 14, value := 0 }, { traceIndex := 26, stepIndex := 7, role := .rs1, reg := 13, value := 18446744071562067969 }, { traceIndex := 26, stepIndex := 7, role := .rs2, reg := 41, value := 0 }, { traceIndex := 27, stepIndex := 7, role := .rs1, reg := 16, value := 18446744071562067969 }]
  , registerWrites := [{ traceIndex := 0, stepIndex := 0, reg := 5, previous := 0, next := 3 }, { traceIndex := 1, stepIndex := 0, reg := 40, previous := 0, next := 18 }, { traceIndex := 2, stepIndex := 0, reg := 41, previous := 0, next := 2 }, { traceIndex := 3, stepIndex := 1, reg := 40, previous := 0, next := 3 }, { traceIndex := 4, stepIndex := 1, reg := 41, previous := 0, next := 18 }, { traceIndex := 5, stepIndex := 1, reg := 6, previous := 0, next := 2 }, { traceIndex := 6, stepIndex := 2, reg := 7, previous := 0, next := 1431655765 }, { traceIndex := 7, stepIndex := 2, reg := 40, previous := 0, next := 4294967295 }, { traceIndex := 8, stepIndex := 2, reg := 41, previous := 0, next := 18446744069414584320 }, { traceIndex := 9, stepIndex := 2, reg := 7, previous := 1431655765, next := 1431655765 }, { traceIndex := 10, stepIndex := 3, reg := 40, previous := 0, next := 1431655765 }, { traceIndex := 11, stepIndex := 3, reg := 41, previous := 0, next := 4294967295 }, { traceIndex := 12, stepIndex := 3, reg := 8, previous := 0, next := 18446744069414584320 }, { traceIndex := 13, stepIndex := 3, reg := 8, previous := 18446744069414584320, next := 0 }, { traceIndex := 14, stepIndex := 4, reg := 11, previous := 0, next := 18446744073709551615 }, { traceIndex := 15, stepIndex := 4, reg := 40, previous := 0, next := 0 }, { traceIndex := 16, stepIndex := 4, reg := 41, previous := 0, next := 9 }, { traceIndex := 17, stepIndex := 5, reg := 40, previous := 0, next := 18446744073709551615 }, { traceIndex := 18, stepIndex := 5, reg := 41, previous := 0, next := 0 }, { traceIndex := 19, stepIndex := 5, reg := 12, previous := 0, next := 9 }, { traceIndex := 20, stepIndex := 6, reg := 15, previous := 0, next := 4294967295 }, { traceIndex := 21, stepIndex := 6, reg := 40, previous := 0, next := 0 }, { traceIndex := 22, stepIndex := 6, reg := 41, previous := 0, next := 18446744071562067969 }, { traceIndex := 23, stepIndex := 6, reg := 15, previous := 4294967295, next := 18446744073709551615 }, { traceIndex := 24, stepIndex := 7, reg := 40, previous := 0, next := 4294967295 }, { traceIndex := 25, stepIndex := 7, reg := 41, previous := 0, next := 0 }, { traceIndex := 26, stepIndex := 7, reg := 16, previous := 0, next := 18446744071562067969 }, { traceIndex := 27, stepIndex := 7, reg := 16, previous := 18446744071562067969, next := 18446744071562067969 }]
  , ramEvents := []
  , twistLinks := [{ traceIndex := 0, stepIndex := 0, family := .unsignedDivRem, routedWriteValue := (some 3), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 0, family := .unsignedDivRem, routedWriteValue := (some 18), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 0, family := .unsignedDivRem, routedWriteValue := (some 2), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 1, family := .unsignedDivRem, routedWriteValue := (some 3), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 4, stepIndex := 1, family := .unsignedDivRem, routedWriteValue := (some 18), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 5, stepIndex := 1, family := .unsignedDivRem, routedWriteValue := (some 2), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 6, stepIndex := 2, family := .unsignedDivRem, routedWriteValue := (some 1431655765), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 7, stepIndex := 2, family := .unsignedDivRem, routedWriteValue := (some 4294967295), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 8, stepIndex := 2, family := .unsignedDivRem, routedWriteValue := (some 18446744069414584320), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 9, stepIndex := 2, family := .unsignedDivRem, routedWriteValue := (some 1431655765), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 10, stepIndex := 3, family := .unsignedDivRem, routedWriteValue := (some 1431655765), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 11, stepIndex := 3, family := .unsignedDivRem, routedWriteValue := (some 4294967295), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 12, stepIndex := 3, family := .unsignedDivRem, routedWriteValue := (some 18446744069414584320), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 13, stepIndex := 3, family := .unsignedDivRem, routedWriteValue := (some 0), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 14, stepIndex := 4, family := .unsignedDivRem, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 15, stepIndex := 4, family := .unsignedDivRem, routedWriteValue := (some 0), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 16, stepIndex := 4, family := .unsignedDivRem, routedWriteValue := (some 9), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 17, stepIndex := 5, family := .unsignedDivRem, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 18, stepIndex := 5, family := .unsignedDivRem, routedWriteValue := (some 0), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 19, stepIndex := 5, family := .unsignedDivRem, routedWriteValue := (some 9), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 20, stepIndex := 6, family := .unsignedDivRem, routedWriteValue := (some 4294967295), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 21, stepIndex := 6, family := .unsignedDivRem, routedWriteValue := (some 0), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 22, stepIndex := 6, family := .unsignedDivRem, routedWriteValue := (some 18446744071562067969), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 23, stepIndex := 6, family := .unsignedDivRem, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 24, stepIndex := 7, family := .unsignedDivRem, routedWriteValue := (some 4294967295), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 25, stepIndex := 7, family := .unsignedDivRem, routedWriteValue := (some 0), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 26, stepIndex := 7, family := .unsignedDivRem, routedWriteValue := (some 18446744071562067969), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 27, stepIndex := 7, family := .unsignedDivRem, routedWriteValue := (some 18446744071562067969), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 28, stepIndex := 8, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]
}
  , stage3 := {
  continuity := [{ stepIndex := 0, pc := 0, nextPc := 4, successorPc := (some 4), finalStep := false, continuityHolds := true }, { stepIndex := 1, pc := 4, nextPc := 8, successorPc := (some 8), finalStep := false, continuityHolds := true }, { stepIndex := 2, pc := 8, nextPc := 12, successorPc := (some 12), finalStep := false, continuityHolds := true }, { stepIndex := 3, pc := 12, nextPc := 16, successorPc := (some 16), finalStep := false, continuityHolds := true }, { stepIndex := 4, pc := 16, nextPc := 20, successorPc := (some 20), finalStep := false, continuityHolds := true }, { stepIndex := 5, pc := 20, nextPc := 24, successorPc := (some 24), finalStep := false, continuityHolds := true }, { stepIndex := 6, pc := 24, nextPc := 28, successorPc := (some 28), finalStep := false, continuityHolds := true }, { stepIndex := 7, pc := 28, nextPc := 32, successorPc := (some 32), finalStep := false, continuityHolds := true }, { stepIndex := 8, pc := 32, nextPc := 36, successorPc := none, finalStep := true, continuityHolds := true }]
  , halted := true
}
  , transcript := {
  appLabel := (bytes [110, 101, 111, 46, 102, 111, 108, 100, 46, 110, 101, 120, 116, 47, 114, 118, 54, 52, 105, 109, 47, 112, 97, 114, 105, 116, 121, 95, 107, 101, 114, 110, 101, 108, 95, 118, 49])
  , events := [{
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 116, 114, 97, 110, 115, 99, 114, 105, 112, 116, 95, 115, 101, 101, 100])
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 117, 110, 115, 105, 103, 110, 101, 100, 45, 100, 105, 118, 114, 101, 109, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [28554825547656548, 829828461, 9489343540124783034, 8764360071562206332, 3057429044872953003, 16976988586773791792, 11845825237008666244, 4664927791211211994], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [117, 110, 115, 105, 103, 110, 101, 100, 95, 100, 105, 118, 114, 101, 109, 95, 99, 104, 97, 105, 110, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [28554825547656548, 829828461, 9489343540124783034, 8764360071562206332, 3057429044872953003, 16976988586773791792, 11845825237008666244, 4664927791211211994], absorbed := 2 }
  , cursorAfter := { stateWords := [18175593511046709288, 6946588854182484443, 13843204130628353059, 17688189384403402368, 17000273702055328877, 1954126954125802051, 3973770870684416971, 6046732314966795874], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [35705523, 35713843, 37868475, 37876795, 44357043, 44365363, 48682939, 48691259, 115]
  , cursorBefore := { stateWords := [18175593511046709288, 6946588854182484443, 13843204130628353059, 17688189384403402368, 17000273702055328877, 1954126954125802051, 3973770870684416971, 6046732314966795874], absorbed := 0 }
  , cursorAfter := { stateWords := [294604563585449092, 3995859309777676657, 1826205592368470438, 17148638130241902376, 4410555781729330190, 4540423293514818421, 7986033658079626101, 14913088229562338250], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 20, 6, 18446744073709551615, 3, 0, 0, 0, 0, 9, 0, 0, 0, 18446744071562067969, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [294604563585449092, 3995859309777676657, 1826205592368470438, 17148638130241902376, 4410555781729330190, 4540423293514818421, 7986033658079626101, 14913088229562338250], absorbed := 0 }
  , cursorAfter := { stateWords := [0, 0, 18338580670858670552, 13303765742222026440, 18227812615345073622, 16789938747818192746, 7660224135226390384, 12066798474568919220], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [0, 0, 18338580670858670552, 13303765742222026440, 18227812615345073622, 16789938747818192746, 7660224135226390384, 12066798474568919220], absorbed := 2 }
  , cursorAfter := { stateWords := [13348506805888363, 30506403037277801, 34184295084289375, 0, 16626093163639875086, 853605333882032129, 4049040664230904676, 9140411641582566077], absorbed := 4 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [112, 237, 148, 129, 8, 187, 27, 103, 196, 62, 229, 65, 80, 123, 21, 108, 248, 197, 118, 80, 87, 178, 35, 86, 12, 75, 11, 46, 200, 11, 70, 74])
  , u64s := []
  , cursorBefore := { stateWords := [13348506805888363, 30506403037277801, 34184295084289375, 0, 16626093163639875086, 853605333882032129, 4049040664230904676, 9140411641582566077], absorbed := 4 }
  , cursorAfter := { stateWords := [24576794031582229, 12960265886114738, 1246104520, 1891803635427246789, 13176233635853993198, 13067209805577138283, 7890629802312393150, 3028786327060893511], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [24576794031582229, 12960265886114738, 1246104520, 1891803635427246789, 13176233635853993198, 13067209805577138283, 7890629802312393150, 3028786327060893511], absorbed := 3 }
  , cursorAfter := { stateWords := [2114760318709056228, 7332565857313712330, 8719415735850429070, 8736709448451869642, 14683097368001922279, 13215671756815992144, 9886648886077009744, 5086976942534876258], absorbed := 0 }
  , challengeOutput := (some 2114760318709056228)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [194, 252, 99, 144, 188, 159, 214, 228, 231, 171, 68, 72, 228, 177, 15, 240, 107, 157, 37, 137, 34, 45, 224, 66, 91, 32, 164, 62, 84, 65, 17, 143])
  , u64s := []
  , cursorBefore := { stateWords := [2114760318709056228, 7332565857313712330, 8719415735850429070, 8736709448451869642, 14683097368001922279, 13215671756815992144, 9886648886077009744, 5086976942534876258], absorbed := 0 }
  , cursorAfter := { stateWords := [9720943856054287, 17631907433078829, 2400272724, 16568033319234264143, 11246549393723949337, 3886138295018278798, 15764416691444559047, 16637667278800296938], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [9720943856054287, 17631907433078829, 2400272724, 16568033319234264143, 11246549393723949337, 3886138295018278798, 15764416691444559047, 16637667278800296938], absorbed := 3 }
  , cursorAfter := { stateWords := [9623998399562321865, 4105603081408161910, 4751007992593884961, 18288276714983694149, 3319719550033343846, 1990847649040725373, 10861070053045217384, 142079268111627146], absorbed := 0 }
  , challengeOutput := (some 9623998399562321865)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [9623998399562321865, 4105603081408161910, 4751007992593884961, 18288276714983694149, 3319719550033343846, 1990847649040725373, 10861070053045217384, 142079268111627146], absorbed := 0 }
  , cursorAfter := { stateWords := [8802110342888801535, 5419848404505140344, 13239104648930224864, 12402328666011142850, 6161298538837734102, 1146713592379336030, 5355403749465642584, 9487351222646020794], absorbed := 0 }
  , challengeOutput := (some 8802110342888801535)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [195, 56, 19, 82, 10, 216, 77, 152, 169, 234, 25, 78, 251, 192, 104, 239, 137, 52, 112, 2, 63, 204, 59, 153, 50, 225, 142, 65, 73, 170, 42, 196])
  , u64s := []
  , cursorBefore := { stateWords := [8802110342888801535, 5419848404505140344, 13239104648930224864, 12402328666011142850, 6161298538837734102, 1146713592379336030, 5355403749465642584, 9487351222646020794], absorbed := 0 }
  , cursorAfter := { stateWords := [17735604473818984, 18452971353881548, 3291130441, 3616115055102231937, 14052811418320705276, 5649898703827695104, 12196512873867634186, 8459611689393984612], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [17735604473818984, 18452971353881548, 3291130441, 3616115055102231937, 14052811418320705276, 5649898703827695104, 12196512873867634186, 8459611689393984612], absorbed := 3 }
  , cursorAfter := { stateWords := [548968070038829395, 16240021376208380512, 4336986931399666685, 17063588956229792450, 18373717032598611015, 7454368206699925205, 6915979662246002859, 14067174015319125265], absorbed := 0 }
  , challengeOutput := (some 548968070038829395)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [80, 77, 243, 233, 190, 184, 52, 23, 82, 127, 172, 195, 183, 255, 127, 86, 245, 226, 157, 206, 2, 214, 47, 191, 184, 177, 70, 30, 242, 179, 62, 115])
  , u64s := []
  , cursorBefore := { stateWords := [548968070038829395, 16240021376208380512, 4336986931399666685, 17063588956229792450, 18373717032598611015, 7454368206699925205, 6915979662246002859, 14067174015319125265], absorbed := 0 }
  , cursorAfter := { stateWords := [790127466337919, 8521978424012758, 1933489138, 14118226142409643476, 5636626556418141687, 5146204121686868138, 5813425710226704663, 3432237320070440371], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [74, 202, 66, 25, 106, 38, 91, 108, 83, 143, 56, 156, 203, 227, 101, 222, 4, 137, 150, 5, 195, 49, 240, 232, 104, 115, 55, 93, 227, 232, 236, 253])
  , u64s := []
  , cursorBefore := { stateWords := [790127466337919, 8521978424012758, 1933489138, 14118226142409643476, 5636626556418141687, 5146204121686868138, 5813425710226704663, 3432237320070440371], absorbed := 3 }
  , cursorAfter := { stateWords := [54893764560608869, 26238141654954033, 4260161763, 4029004789297720123, 4207896458049662805, 5487101462387058563, 5798831122825369606, 9810116389510024144], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [182, 31, 54, 213, 113, 159, 201, 136, 65, 181, 111, 174, 113, 197, 150, 29, 93, 126, 40, 13, 253, 225, 7, 190, 200, 101, 176, 45, 199, 60, 8, 160])
  , u64s := []
  , cursorBefore := { stateWords := [54893764560608869, 26238141654954033, 4260161763, 4029004789297720123, 4207896458049662805, 5487101462387058563, 5798831122825369606, 9810116389510024144], absorbed := 3 }
  , cursorAfter := { stateWords := [71227636677680534, 12860325158062049, 2684894407, 10517842318081291684, 707559344843132510, 9304322026659064738, 2313881270804506576, 5033264401807177475], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [71227636677680534, 12860325158062049, 2684894407, 10517842318081291684, 707559344843132510, 9304322026659064738, 2313881270804506576, 5033264401807177475], absorbed := 3 }
  , cursorAfter := { stateWords := [16824818285799363036, 14516401473560369504, 6781304114410902302, 432764352883285124, 5961912157393274262, 11835148470266970466, 12238340288431517965, 2899380087059870968], absorbed := 0 }
  , challengeOutput := (some 16824818285799363036)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [16824818285799363036, 14516401473560369504, 6781304114410902302, 432764352883285124, 5961912157393274262, 11835148470266970466, 12238340288431517965, 2899380087059870968], absorbed := 0 }
  , cursorAfter := { stateWords := [1645148415989039116, 10229342872146267038, 9772198794292242561, 4614655340611880630, 8148963032799206072, 4667036217784725552, 8481883072410979, 10681842667011045012], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [12, 192, 210, 153, 196, 189, 212, 22, 158, 203, 243, 19, 37, 237, 245, 141, 129, 40, 74, 48, 7, 211, 157, 135, 182, 198, 7, 50, 149, 140, 10, 64]))
}]
}
  , kernel := {
  root0Digest := (bytes [112, 237, 148, 129, 8, 187, 27, 103, 196, 62, 229, 65, 80, 123, 21, 108, 248, 197, 118, 80, 87, 178, 35, 86, 12, 75, 11, 46, 200, 11, 70, 74])
  , stage1Digest := (bytes [194, 252, 99, 144, 188, 159, 214, 228, 231, 171, 68, 72, 228, 177, 15, 240, 107, 157, 37, 137, 34, 45, 224, 66, 91, 32, 164, 62, 84, 65, 17, 143])
  , stage2Digest := (bytes [195, 56, 19, 82, 10, 216, 77, 152, 169, 234, 25, 78, 251, 192, 104, 239, 137, 52, 112, 2, 63, 204, 59, 153, 50, 225, 142, 65, 73, 170, 42, 196])
  , stage3Digest := (bytes [80, 77, 243, 233, 190, 184, 52, 23, 82, 127, 172, 195, 183, 255, 127, 86, 245, 226, 157, 206, 2, 214, 47, 191, 184, 177, 70, 30, 242, 179, 62, 115])
  , executionDigest := (bytes [74, 202, 66, 25, 106, 38, 91, 108, 83, 143, 56, 156, 203, 227, 101, 222, 4, 137, 150, 5, 195, 49, 240, 232, 104, 115, 55, 93, 227, 232, 236, 253])
  , finalStateDigest := (bytes [182, 31, 54, 213, 113, 159, 201, 136, 65, 181, 111, 174, 113, 197, 150, 29, 93, 126, 40, 13, 253, 225, 7, 190, 200, 101, 176, 45, 199, 60, 8, 160])
  , stage1Mix := 2114760318709056228
  , stage2RegMix := 9623998399562321865
  , stage2RamMix := 8802110342888801535
  , stage3ContinuityMix := 548968070038829395
  , kernelFinalMix := 16824818285799363036
  , transcriptFinalDigest := (bytes [12, 192, 210, 153, 196, 189, 212, 22, 158, 203, 243, 19, 37, 237, 245, 141, 129, 40, 74, 48, 7, 211, 157, 135, 182, 198, 7, 50, 149, 140, 10, 64])
  , finalPc := 36
  , finalRegisters := [0, 20, 6, 18446744073709551615, 3, 3, 2, 1431655765, 0, 9, 0, 18446744073709551615, 9, 18446744071562067969, 0, 18446744073709551615, 18446744071562067969, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , finalMemory := []
  , halted := true
}
}
    , kernelProof := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "unsigned_divrem_chain_ecall", fixtureId := "unsigned_divrem_chain_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.unsignedDivRem, .controlFlow] }
  , executionDigest := (bytes [74, 202, 66, 25, 106, 38, 91, 108, 83, 143, 56, 156, 203, 227, 101, 222, 4, 137, 150, 5, 195, 49, 240, 232, 104, 115, 55, 93, 227, 232, 236, 253])
  , shape := { executionRowCount := 29, realRowCount := 9, effectRowCount := 9, commitRowCount := 9, digest := (bytes [24, 132, 44, 43, 87, 247, 238, 104, 161, 144, 32, 235, 250, 233, 3, 16, 164, 116, 139, 60, 35, 7, 93, 96, 191, 234, 80, 117, 232, 254, 76, 234]) }
  , digest := (bytes [181, 238, 6, 82, 65, 2, 82, 192, 131, 249, 105, 136, 215, 253, 37, 131, 86, 148, 25, 38, 28, 163, 255, 218, 66, 233, 235, 6, 42, 133, 57, 142])
}
  , stages := { summary := { stage1RowCount := 29, stage2RegisterReadCount := 52, stage2RegisterWriteCount := 28, stage2RamEventCount := 0, stage2TwistLinkCount := 29, stage3ContinuityCount := 9, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [91, 118, 203, 75, 35, 44, 12, 201, 53, 12, 56, 211, 203, 113, 194, 87, 211, 57, 109, 234, 227, 160, 16, 44, 52, 145, 24, 0, 94, 199, 86, 12]) }, digest := (bytes [133, 72, 142, 180, 234, 189, 148, 240, 162, 217, 30, 145, 225, 31, 232, 81, 72, 123, 80, 136, 134, 158, 29, 147, 163, 200, 66, 61, 227, 236, 100, 117]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [245, 72, 75, 42, 73, 229, 163, 53, 146, 214, 107, 216, 213, 85, 133, 116, 173, 47, 114, 185, 134, 203, 104, 165, 250, 92, 247, 14, 227, 198, 71, 208]), stage1Digest := (bytes [8, 10, 70, 35, 185, 90, 227, 79, 241, 72, 179, 33, 38, 114, 54, 133, 109, 62, 127, 17, 154, 28, 229, 43, 255, 142, 150, 108, 205, 106, 215, 40]), stage2Digest := (bytes [203, 109, 106, 163, 136, 226, 225, 78, 218, 232, 24, 23, 216, 70, 236, 1, 18, 239, 5, 143, 83, 125, 115, 135, 35, 127, 89, 72, 100, 175, 181, 155]), stage3Digest := (bytes [220, 38, 60, 55, 60, 34, 226, 1, 163, 13, 73, 152, 205, 63, 225, 187, 60, 26, 212, 34, 168, 63, 107, 178, 205, 150, 211, 14, 53, 254, 107, 141]), transcriptDigest := (bytes [12, 192, 210, 153, 196, 189, 212, 22, 158, 203, 243, 19, 37, 237, 245, 141, 129, 40, 74, 48, 7, 211, 157, 135, 182, 198, 7, 50, 149, 140, 10, 64]), executionDigest := (bytes [74, 202, 66, 25, 106, 38, 91, 108, 83, 143, 56, 156, 203, 227, 101, 222, 4, 137, 150, 5, 195, 49, 240, 232, 104, 115, 55, 93, 227, 232, 236, 253]), digest := (bytes [101, 25, 139, 85, 148, 244, 221, 76, 159, 125, 103, 233, 98, 154, 13, 211, 154, 254, 215, 55, 149, 170, 200, 46, 244, 18, 85, 17, 187, 226, 194, 138]) }, statementDigest := (bytes [210, 17, 226, 113, 48, 32, 145, 113, 31, 176, 17, 212, 130, 44, 196, 231, 103, 179, 213, 51, 106, 250, 6, 228, 50, 185, 144, 86, 150, 64, 116, 44]), proofDigest := (bytes [156, 41, 101, 247, 81, 233, 165, 13, 175, 60, 109, 142, 46, 65, 107, 223, 135, 113, 32, 52, 158, 178, 207, 35, 150, 53, 26, 12, 9, 214, 225, 148]), digest := (bytes [113, 5, 129, 162, 39, 178, 145, 40, 126, 199, 229, 224, 231, 199, 124, 27, 38, 154, 83, 89, 56, 19, 163, 19, 16, 245, 79, 232, 84, 249, 149, 143]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [202, 244, 4, 158, 46, 125, 232, 78, 96, 136, 208, 229, 133, 159, 55, 23, 25, 188, 40, 64, 162, 32, 87, 74, 10, 162, 215, 241, 22, 9, 27, 112]), stage1Digest := (bytes [84, 206, 142, 168, 93, 56, 75, 141, 229, 55, 180, 100, 199, 16, 42, 116, 200, 87, 88, 19, 121, 131, 122, 152, 187, 79, 10, 207, 157, 128, 75, 64]), stage2Digest := (bytes [233, 244, 5, 85, 164, 65, 201, 245, 154, 6, 245, 55, 160, 133, 24, 0, 98, 0, 72, 170, 44, 114, 128, 216, 10, 232, 185, 75, 115, 11, 21, 57]), stage3Digest := (bytes [248, 162, 12, 203, 170, 40, 43, 20, 152, 3, 84, 198, 147, 220, 41, 13, 65, 180, 249, 53, 251, 90, 130, 174, 144, 179, 189, 160, 32, 203, 228, 148]), digest := (bytes [232, 24, 197, 155, 24, 237, 95, 194, 116, 198, 217, 85, 95, 37, 180, 138, 102, 146, 78, 30, 169, 15, 90, 144, 147, 214, 170, 43, 245, 212, 142, 138]) }, digest := (bytes [21, 177, 110, 213, 218, 127, 92, 48, 71, 84, 132, 202, 179, 18, 150, 197, 231, 121, 123, 155, 210, 218, 156, 31, 86, 14, 94, 218, 64, 74, 110, 62]) }
  , kernelOpening := { openingDigest := (bytes [191, 138, 72, 200, 97, 143, 211, 249, 193, 138, 167, 4, 198, 38, 157, 94, 2, 19, 193, 51, 126, 165, 91, 115, 203, 137, 149, 175, 245, 167, 100, 184]), bindings := { claimDigest := (bytes [58, 79, 60, 5, 44, 217, 210, 184, 12, 93, 193, 41, 184, 126, 53, 85, 15, 125, 156, 137, 120, 193, 126, 139, 36, 248, 235, 179, 121, 12, 254, 237]), bindingsDigest := (bytes [98, 122, 12, 239, 168, 23, 243, 235, 43, 254, 227, 125, 21, 191, 120, 14, 197, 0, 137, 95, 184, 231, 127, 220, 153, 170, 197, 125, 76, 153, 34, 171]), preparedStepsDigest := (bytes [241, 188, 244, 234, 213, 229, 19, 141, 178, 83, 184, 95, 217, 231, 124, 251, 178, 198, 193, 160, 225, 156, 159, 131, 198, 255, 189, 217, 235, 245, 110, 247]), digest := (bytes [20, 6, 182, 137, 33, 163, 220, 89, 111, 169, 163, 104, 236, 100, 231, 251, 211, 39, 169, 209, 35, 224, 96, 234, 227, 229, 116, 97, 22, 213, 93, 172]) }, digest := (bytes [28, 82, 111, 203, 143, 45, 58, 36, 78, 238, 215, 216, 169, 16, 233, 168, 216, 92, 0, 220, 175, 17, 155, 108, 36, 207, 212, 75, 238, 112, 75, 177]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [122, 127, 230, 234, 20, 88, 54, 132, 38, 4, 241, 103, 237, 27, 91, 231, 123, 166, 255, 110, 210, 175, 85, 2, 174, 249, 69, 66, 249, 6, 108, 229]), terminal := { root0Digest := (bytes [112, 237, 148, 129, 8, 187, 27, 103, 196, 62, 229, 65, 80, 123, 21, 108, 248, 197, 118, 80, 87, 178, 35, 86, 12, 75, 11, 46, 200, 11, 70, 74]), executionDigest := (bytes [74, 202, 66, 25, 106, 38, 91, 108, 83, 143, 56, 156, 203, 227, 101, 222, 4, 137, 150, 5, 195, 49, 240, 232, 104, 115, 55, 93, 227, 232, 236, 253]), finalStateDigest := (bytes [182, 31, 54, 213, 113, 159, 201, 136, 65, 181, 111, 174, 113, 197, 150, 29, 93, 126, 40, 13, 253, 225, 7, 190, 200, 101, 176, 45, 199, 60, 8, 160]), transcriptFinalDigest := (bytes [12, 192, 210, 153, 196, 189, 212, 22, 158, 203, 243, 19, 37, 237, 245, 141, 129, 40, 74, 48, 7, 211, 157, 135, 182, 198, 7, 50, 149, 140, 10, 64]), finalPc := 36, halted := true, digest := (bytes [59, 206, 20, 120, 239, 34, 156, 60, 113, 110, 27, 56, 27, 222, 197, 46, 134, 197, 77, 158, 110, 53, 49, 132, 134, 25, 149, 40, 174, 95, 59, 78]) }, digest := (bytes [46, 240, 34, 221, 181, 172, 209, 111, 193, 202, 64, 215, 26, 155, 138, 202, 36, 175, 37, 190, 17, 114, 7, 75, 93, 156, 128, 164, 23, 215, 96, 0]) }, statementDigest := (bytes [152, 165, 76, 254, 110, 85, 173, 45, 214, 249, 70, 188, 231, 198, 153, 212, 137, 1, 186, 150, 51, 237, 64, 178, 188, 81, 59, 229, 18, 51, 160, 242]), proofDigest := (bytes [216, 172, 107, 144, 190, 133, 113, 64, 238, 150, 20, 80, 179, 148, 46, 55, 164, 6, 83, 167, 119, 78, 41, 241, 52, 165, 202, 63, 222, 113, 191, 255]), digest := (bytes [1, 238, 175, 142, 127, 18, 11, 182, 150, 173, 181, 78, 116, 153, 144, 183, 131, 4, 46, 229, 90, 216, 194, 199, 25, 1, 229, 38, 74, 22, 155, 152]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [62, 154, 7, 200, 147, 245, 58, 185, 116, 64, 224, 46, 160, 35, 75, 87, 202, 13, 0, 146, 57, 39, 202, 76, 37, 197, 28, 178, 16, 93, 198, 238]), layoutVersion := 1, digest := (bytes [72, 20, 132, 106, 165, 238, 87, 32, 230, 222, 113, 145, 147, 49, 100, 223, 93, 208, 51, 219, 74, 178, 167, 73, 24, 194, 222, 170, 30, 92, 62, 246]) }, rowWidth := 38, timeLen := 29, columnDigests := [(bytes [225, 144, 71, 219, 98, 150, 176, 137, 117, 152, 218, 12, 231, 77, 180, 251, 202, 38, 51, 2, 145, 159, 54, 17, 197, 124, 89, 195, 83, 238, 136, 81]), (bytes [146, 158, 140, 155, 179, 185, 149, 183, 251, 209, 198, 147, 38, 37, 140, 69, 160, 9, 216, 55, 192, 190, 59, 26, 216, 217, 62, 24, 127, 85, 137, 142]), (bytes [142, 34, 112, 18, 173, 54, 6, 140, 104, 236, 245, 165, 32, 207, 224, 204, 82, 82, 62, 69, 74, 161, 107, 70, 38, 3, 105, 29, 53, 149, 156, 128]), (bytes [177, 65, 50, 144, 245, 110, 233, 171, 232, 225, 119, 68, 4, 55, 249, 173, 251, 72, 195, 139, 226, 128, 143, 115, 199, 221, 154, 3, 72, 2, 83, 115]), (bytes [187, 110, 30, 154, 212, 74, 138, 163, 178, 1, 214, 45, 7, 177, 164, 84, 240, 36, 178, 64, 217, 239, 121, 230, 186, 117, 115, 88, 47, 101, 88, 247]), (bytes [169, 151, 16, 42, 183, 14, 65, 149, 6, 102, 30, 248, 238, 152, 25, 94, 198, 232, 194, 105, 153, 30, 91, 175, 34, 125, 241, 252, 15, 216, 76, 157]), (bytes [69, 222, 94, 63, 123, 239, 52, 203, 118, 204, 96, 88, 131, 44, 220, 53, 199, 109, 252, 221, 217, 182, 189, 85, 59, 232, 124, 251, 182, 226, 86, 249]), (bytes [158, 79, 224, 220, 254, 240, 26, 24, 34, 166, 48, 240, 165, 20, 200, 161, 31, 138, 115, 24, 228, 82, 220, 226, 70, 171, 225, 32, 38, 171, 101, 148]), (bytes [247, 133, 122, 61, 3, 181, 179, 2, 78, 121, 199, 99, 188, 155, 129, 167, 43, 7, 104, 123, 237, 51, 187, 22, 241, 150, 190, 38, 197, 98, 2, 20]), (bytes [233, 241, 59, 183, 115, 16, 155, 112, 147, 254, 37, 9, 198, 213, 255, 240, 142, 160, 77, 159, 152, 40, 123, 72, 163, 100, 215, 222, 18, 213, 248, 209]), (bytes [25, 189, 217, 85, 137, 71, 57, 168, 127, 18, 14, 178, 71, 101, 16, 248, 186, 217, 126, 171, 0, 120, 231, 48, 103, 99, 103, 74, 172, 118, 225, 1]), (bytes [251, 57, 85, 182, 134, 20, 27, 50, 49, 220, 118, 202, 190, 3, 143, 75, 130, 31, 127, 91, 71, 143, 150, 228, 39, 35, 60, 29, 131, 71, 39, 0]), (bytes [133, 122, 33, 147, 47, 160, 190, 209, 160, 150, 0, 77, 38, 48, 162, 196, 160, 164, 2, 129, 207, 137, 136, 250, 155, 128, 120, 36, 81, 44, 253, 222]), (bytes [40, 128, 59, 105, 74, 174, 48, 74, 184, 54, 190, 56, 96, 87, 192, 47, 253, 241, 23, 15, 124, 138, 14, 203, 251, 156, 155, 174, 116, 135, 47, 72]), (bytes [53, 244, 115, 22, 63, 240, 250, 109, 33, 19, 55, 63, 40, 28, 3, 202, 100, 147, 84, 59, 5, 95, 249, 90, 190, 191, 37, 62, 163, 169, 52, 189]), (bytes [131, 250, 236, 20, 8, 99, 18, 117, 217, 85, 133, 126, 4, 189, 51, 39, 25, 47, 47, 41, 93, 172, 80, 115, 27, 45, 128, 252, 31, 5, 206, 195]), (bytes [89, 61, 248, 224, 67, 160, 200, 219, 241, 254, 16, 244, 90, 48, 115, 25, 130, 84, 52, 147, 39, 142, 246, 176, 80, 152, 132, 95, 200, 49, 201, 248]), (bytes [34, 68, 71, 45, 18, 40, 1, 102, 204, 90, 252, 15, 188, 232, 150, 239, 238, 10, 156, 192, 2, 238, 172, 50, 238, 60, 78, 29, 84, 74, 152, 177]), (bytes [159, 44, 169, 53, 34, 215, 40, 87, 157, 79, 201, 156, 129, 131, 163, 240, 166, 165, 47, 251, 235, 27, 218, 15, 52, 43, 205, 37, 72, 232, 255, 240]), (bytes [101, 185, 21, 255, 183, 119, 49, 133, 193, 6, 195, 53, 13, 64, 166, 139, 241, 113, 47, 248, 95, 119, 234, 106, 233, 40, 164, 167, 223, 251, 49, 164]), (bytes [168, 134, 175, 127, 124, 235, 234, 224, 126, 84, 90, 179, 59, 107, 156, 102, 170, 123, 197, 54, 201, 107, 166, 55, 133, 242, 61, 198, 177, 28, 199, 166]), (bytes [131, 99, 176, 212, 241, 178, 229, 254, 243, 185, 144, 61, 54, 128, 21, 148, 105, 32, 116, 244, 80, 109, 39, 120, 94, 146, 185, 122, 98, 38, 125, 96]), (bytes [166, 137, 73, 4, 167, 238, 68, 129, 29, 111, 251, 56, 90, 45, 113, 96, 158, 150, 92, 141, 233, 178, 47, 207, 193, 232, 115, 123, 239, 109, 225, 81]), (bytes [109, 228, 106, 126, 1, 154, 101, 178, 99, 186, 169, 23, 190, 246, 6, 119, 133, 155, 169, 224, 104, 241, 168, 246, 26, 9, 245, 243, 159, 43, 193, 40]), (bytes [84, 71, 236, 195, 91, 244, 24, 129, 137, 205, 211, 129, 8, 108, 110, 4, 32, 103, 214, 34, 178, 142, 210, 138, 208, 159, 59, 233, 67, 117, 61, 177]), (bytes [215, 155, 157, 52, 106, 37, 10, 21, 143, 252, 226, 76, 12, 127, 111, 32, 62, 181, 75, 2, 72, 157, 245, 86, 27, 193, 119, 139, 213, 205, 211, 216]), (bytes [176, 156, 235, 147, 154, 227, 33, 241, 138, 17, 161, 227, 206, 89, 144, 172, 187, 187, 144, 2, 142, 67, 14, 164, 107, 205, 212, 89, 28, 207, 3, 12]), (bytes [124, 225, 65, 157, 149, 211, 123, 1, 114, 195, 64, 64, 70, 84, 85, 216, 233, 231, 253, 168, 237, 186, 106, 149, 149, 180, 108, 164, 197, 230, 255, 37]), (bytes [189, 65, 69, 91, 107, 106, 95, 158, 138, 149, 69, 103, 187, 116, 129, 248, 236, 235, 178, 249, 158, 57, 202, 59, 246, 51, 68, 78, 45, 103, 141, 148]), (bytes [60, 7, 219, 141, 178, 20, 175, 53, 193, 27, 181, 210, 212, 131, 112, 160, 200, 211, 210, 155, 50, 165, 51, 57, 58, 245, 219, 216, 32, 119, 115, 81]), (bytes [0, 241, 216, 6, 85, 233, 44, 163, 138, 25, 159, 156, 224, 140, 134, 57, 72, 140, 223, 209, 59, 9, 192, 229, 14, 251, 82, 157, 172, 21, 47, 73]), (bytes [220, 105, 109, 147, 191, 51, 134, 2, 29, 157, 72, 171, 79, 94, 51, 12, 175, 162, 154, 108, 2, 147, 247, 135, 227, 131, 107, 210, 127, 72, 20, 193]), (bytes [244, 155, 95, 10, 221, 240, 103, 187, 35, 194, 33, 54, 48, 100, 87, 121, 218, 115, 120, 167, 175, 123, 202, 115, 67, 230, 88, 80, 237, 214, 35, 19]), (bytes [76, 183, 241, 70, 105, 220, 125, 240, 46, 244, 80, 170, 139, 218, 70, 76, 38, 121, 105, 137, 50, 252, 43, 36, 186, 13, 80, 147, 251, 223, 13, 176]), (bytes [25, 109, 229, 191, 89, 237, 100, 249, 118, 122, 177, 62, 97, 27, 178, 71, 199, 215, 79, 119, 156, 97, 6, 148, 83, 95, 44, 254, 206, 210, 162, 180]), (bytes [154, 210, 102, 237, 124, 137, 226, 136, 9, 149, 91, 159, 118, 88, 107, 15, 229, 106, 238, 129, 85, 65, 104, 111, 8, 252, 131, 2, 196, 196, 82, 17]), (bytes [99, 160, 92, 133, 199, 2, 200, 7, 232, 31, 183, 118, 192, 5, 209, 191, 18, 76, 91, 162, 17, 123, 81, 154, 193, 172, 240, 228, 196, 150, 59, 119]), (bytes [255, 151, 239, 15, 190, 208, 229, 150, 31, 114, 213, 241, 235, 219, 84, 51, 158, 153, 120, 86, 41, 221, 168, 180, 76, 247, 19, 170, 58, 37, 126, 249])], familyDigest := (bytes [62, 154, 7, 200, 147, 245, 58, 185, 116, 64, 224, 46, 160, 35, 75, 87, 202, 13, 0, 146, 57, 39, 202, 76, 37, 197, 28, 178, 16, 93, 198, 238]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [62, 154, 7, 200, 147, 245, 58, 185, 116, 64, 224, 46, 160, 35, 75, 87, 202, 13, 0, 146, 57, 39, 202, 76, 37, 197, 28, 178, 16, 93, 198, 238]), layoutVersion := 1, digest := (bytes [72, 20, 132, 106, 165, 238, 87, 32, 230, 222, 113, 145, 147, 49, 100, 223, 93, 208, 51, 219, 74, 178, 167, 73, 24, 194, 222, 170, 30, 92, 62, 246]) }, logicalIndex := 0, digest := (bytes [157, 243, 0, 60, 241, 246, 254, 190, 204, 2, 60, 216, 77, 95, 223, 233, 200, 143, 150, 107, 143, 60, 45, 118, 175, 106, 167, 10, 36, 24, 167, 77]) }, valueDigest := (bytes [15, 203, 82, 147, 182, 107, 150, 168, 159, 107, 204, 115, 170, 200, 12, 67, 125, 81, 225, 219, 175, 26, 58, 39, 55, 35, 134, 130, 62, 126, 3, 37]), digest := (bytes [45, 161, 238, 241, 198, 238, 221, 31, 180, 58, 220, 162, 22, 61, 238, 251, 249, 195, 29, 205, 227, 246, 79, 201, 151, 86, 233, 105, 224, 236, 143, 125]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [62, 154, 7, 200, 147, 245, 58, 185, 116, 64, 224, 46, 160, 35, 75, 87, 202, 13, 0, 146, 57, 39, 202, 76, 37, 197, 28, 178, 16, 93, 198, 238]), layoutVersion := 1, digest := (bytes [72, 20, 132, 106, 165, 238, 87, 32, 230, 222, 113, 145, 147, 49, 100, 223, 93, 208, 51, 219, 74, 178, 167, 73, 24, 194, 222, 170, 30, 92, 62, 246]) }, logicalIndex := 28, digest := (bytes [233, 62, 123, 247, 47, 66, 12, 137, 97, 219, 154, 120, 8, 135, 37, 192, 34, 157, 217, 24, 146, 73, 251, 131, 32, 163, 221, 254, 78, 216, 51, 34]) }, valueDigest := (bytes [191, 59, 111, 91, 175, 174, 193, 106, 252, 237, 179, 109, 105, 90, 100, 212, 35, 239, 230, 162, 83, 17, 88, 13, 240, 150, 187, 164, 56, 114, 73, 39]), digest := (bytes [180, 81, 197, 89, 123, 21, 57, 248, 239, 158, 190, 71, 240, 70, 71, 207, 10, 185, 191, 205, 239, 154, 252, 215, 220, 242, 31, 7, 28, 106, 157, 137]) }), digest := (bytes [38, 137, 143, 183, 203, 147, 94, 154, 15, 226, 51, 246, 88, 62, 137, 224, 176, 66, 88, 191, 172, 42, 75, 9, 199, 148, 179, 224, 80, 184, 102, 237]) }
  , rootLaneCommitment := { timeLen := 29, commitments := { commitmentCount := 38, digest := (bytes [2, 195, 15, 176, 74, 156, 14, 145, 205, 30, 105, 114, 34, 141, 242, 217, 105, 100, 117, 46, 249, 188, 28, 111, 72, 195, 48, 19, 21, 39, 77, 21]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [2, 195, 15, 176, 74, 156, 14, 145, 205, 30, 105, 114, 34, 141, 242, 217, 105, 100, 117, 46, 249, 188, 28, 111, 72, 195, 48, 19, 21, 39, 77, 21]), layoutVersion := 3, digest := (bytes [107, 210, 58, 64, 103, 214, 200, 23, 157, 252, 53, 151, 94, 117, 179, 18, 97, 24, 125, 232, 65, 255, 83, 37, 252, 49, 227, 196, 7, 172, 22, 254]) }, logicalIndex := 0, digest := (bytes [132, 75, 176, 50, 98, 124, 10, 163, 65, 72, 164, 172, 236, 29, 57, 36, 144, 74, 213, 185, 85, 221, 229, 157, 190, 66, 127, 60, 109, 248, 105, 36]) }, valueDigest := (bytes [15, 203, 82, 147, 182, 107, 150, 168, 159, 107, 204, 115, 170, 200, 12, 67, 125, 81, 225, 219, 175, 26, 58, 39, 55, 35, 134, 130, 62, 126, 3, 37]), digest := (bytes [143, 201, 227, 113, 227, 52, 190, 147, 201, 197, 250, 34, 101, 210, 119, 246, 66, 86, 0, 57, 190, 96, 107, 156, 186, 34, 219, 71, 26, 85, 5, 244]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [2, 195, 15, 176, 74, 156, 14, 145, 205, 30, 105, 114, 34, 141, 242, 217, 105, 100, 117, 46, 249, 188, 28, 111, 72, 195, 48, 19, 21, 39, 77, 21]), layoutVersion := 3, digest := (bytes [107, 210, 58, 64, 103, 214, 200, 23, 157, 252, 53, 151, 94, 117, 179, 18, 97, 24, 125, 232, 65, 255, 83, 37, 252, 49, 227, 196, 7, 172, 22, 254]) }, logicalIndex := 28, digest := (bytes [228, 49, 68, 70, 171, 104, 219, 143, 14, 198, 244, 25, 53, 98, 211, 75, 148, 14, 190, 247, 181, 218, 158, 239, 149, 181, 105, 155, 187, 206, 1, 129]) }, valueDigest := (bytes [191, 59, 111, 91, 175, 174, 193, 106, 252, 237, 179, 109, 105, 90, 100, 212, 35, 239, 230, 162, 83, 17, 88, 13, 240, 150, 187, 164, 56, 114, 73, 39]), digest := (bytes [0, 246, 160, 121, 86, 247, 118, 202, 26, 120, 220, 155, 194, 122, 193, 229, 214, 70, 4, 38, 18, 243, 44, 123, 80, 244, 64, 114, 215, 121, 214, 30]) }), digest := (bytes [150, 62, 140, 172, 232, 178, 145, 115, 116, 114, 88, 213, 56, 166, 39, 55, 80, 244, 202, 250, 116, 153, 16, 155, 166, 156, 246, 97, 75, 108, 0, 65]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [38, 137, 143, 183, 203, 147, 94, 154, 15, 226, 51, 246, 88, 62, 137, 224, 176, 66, 88, 191, 172, 42, 75, 9, 199, 148, 179, 224, 80, 184, 102, 237]), rootLaneCommitmentDigest := (bytes [150, 62, 140, 172, 232, 178, 145, 115, 116, 114, 88, 213, 56, 166, 39, 55, 80, 244, 202, 250, 116, 153, 16, 155, 166, 156, 246, 97, 75, 108, 0, 65]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 29, digest := (bytes [211, 98, 237, 242, 215, 31, 14, 15, 184, 13, 191, 171, 253, 34, 21, 29, 65, 28, 97, 73, 72, 62, 243, 8, 57, 223, 199, 211, 62, 146, 193, 73]) }, statementDigest := (bytes [7, 54, 218, 74, 91, 87, 126, 77, 113, 29, 100, 248, 179, 47, 55, 221, 251, 156, 123, 73, 245, 179, 210, 212, 194, 170, 217, 229, 66, 118, 179, 0]), proofDigest := (bytes [227, 177, 167, 54, 118, 140, 153, 71, 128, 178, 68, 36, 4, 94, 19, 13, 124, 70, 73, 221, 181, 240, 4, 207, 23, 61, 79, 232, 254, 140, 120, 56]), digest := (bytes [0, 140, 31, 32, 123, 73, 34, 6, 104, 48, 110, 75, 192, 245, 251, 55, 159, 231, 142, 107, 171, 235, 15, 157, 150, 238, 207, 182, 36, 55, 202, 100]) }
  , digest := (bytes [236, 173, 150, 123, 212, 185, 6, 179, 2, 88, 193, 125, 198, 47, 99, 169, 201, 113, 124, 81, 200, 14, 52, 145, 93, 10, 22, 243, 17, 92, 156, 200])
}
    , exportedProof := {
  claim := {
  accepted := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , statement := { proofStatementDigest := (bytes [32, 181, 152, 217, 168, 93, 39, 204, 129, 242, 203, 24, 188, 141, 39, 140, 94, 224, 84, 53, 160, 178, 146, 251, 174, 88, 139, 148, 162, 178, 115, 208]), kernelOpeningDigest := (bytes [28, 82, 111, 203, 143, 45, 58, 36, 78, 238, 215, 216, 169, 16, 233, 168, 216, 92, 0, 220, 175, 17, 155, 108, 36, 207, 212, 75, 238, 112, 75, 177]), digest := (bytes [44, 13, 115, 98, 242, 163, 215, 133, 186, 43, 125, 20, 199, 160, 193, 22, 245, 222, 143, 238, 84, 116, 66, 112, 177, 100, 92, 201, 226, 107, 97, 122]) }
  , mainLane := { mainLaneBundleDigest := (bytes [0, 140, 31, 32, 123, 73, 34, 6, 104, 48, 110, 75, 192, 245, 251, 55, 159, 231, 142, 107, 171, 235, 15, 157, 150, 238, 207, 182, 36, 55, 202, 100]), digest := (bytes [112, 169, 119, 145, 153, 75, 115, 250, 124, 119, 173, 76, 205, 10, 250, 80, 204, 224, 38, 18, 160, 29, 32, 109, 213, 58, 21, 237, 53, 243, 187, 189]) }
  , terminal := { finalStateDigest := (bytes [182, 31, 54, 213, 113, 159, 201, 136, 65, 181, 111, 174, 113, 197, 150, 29, 93, 126, 40, 13, 253, 225, 7, 190, 200, 101, 176, 45, 199, 60, 8, 160]), finalPc := 36, halted := true, digest := (bytes [203, 187, 208, 63, 190, 89, 203, 226, 159, 52, 250, 7, 117, 54, 218, 9, 197, 176, 163, 91, 194, 29, 49, 62, 18, 251, 128, 12, 176, 3, 70, 112]) }
  , digest := (bytes [143, 171, 77, 9, 59, 226, 5, 53, 143, 139, 17, 88, 165, 75, 36, 16, 202, 4, 203, 191, 173, 5, 101, 38, 37, 80, 184, 127, 140, 42, 231, 109])
}
  , mainLane := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { mainLaneBundleDigest := (bytes [0, 140, 31, 32, 123, 73, 34, 6, 104, 48, 110, 75, 192, 245, 251, 55, 159, 231, 142, 107, 171, 235, 15, 157, 150, 238, 207, 182, 36, 55, 202, 100]), digest := (bytes [119, 54, 9, 98, 44, 115, 125, 210, 117, 162, 126, 187, 147, 66, 83, 66, 179, 43, 94, 194, 122, 44, 209, 21, 86, 67, 201, 23, 64, 52, 50, 220]) }, digest := (bytes [108, 237, 252, 249, 209, 228, 62, 176, 244, 253, 89, 245, 195, 134, 130, 123, 64, 16, 61, 85, 50, 172, 82, 145, 248, 136, 73, 133, 180, 197, 157, 200]) }
  , opening := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , stages := { stageClaimsDigest := (bytes [113, 5, 129, 162, 39, 178, 145, 40, 126, 199, 229, 224, 231, 199, 124, 27, 38, 154, 83, 89, 56, 19, 163, 19, 16, 245, 79, 232, 84, 249, 149, 143]), stagePackagesDigest := (bytes [21, 177, 110, 213, 218, 127, 92, 48, 71, 84, 132, 202, 179, 18, 150, 197, 231, 121, 123, 155, 210, 218, 156, 31, 86, 14, 94, 218, 64, 74, 110, 62]), kernelOpeningDigest := (bytes [28, 82, 111, 203, 143, 45, 58, 36, 78, 238, 215, 216, 169, 16, 233, 168, 216, 92, 0, 220, 175, 17, 155, 108, 36, 207, 212, 75, 238, 112, 75, 177]), digest := (bytes [5, 213, 65, 25, 22, 206, 225, 111, 83, 167, 83, 121, 159, 21, 9, 47, 240, 181, 23, 117, 203, 81, 12, 208, 144, 52, 137, 6, 124, 43, 199, 56]) }
  , terminal := { preparedStepBindingsDigest := (bytes [122, 127, 230, 234, 20, 88, 54, 132, 38, 4, 241, 103, 237, 27, 91, 231, 123, 166, 255, 110, 210, 175, 85, 2, 174, 249, 69, 66, 249, 6, 108, 229]), executionDigest := (bytes [74, 202, 66, 25, 106, 38, 91, 108, 83, 143, 56, 156, 203, 227, 101, 222, 4, 137, 150, 5, 195, 49, 240, 232, 104, 115, 55, 93, 227, 232, 236, 253]), transcriptFinalDigest := (bytes [12, 192, 210, 153, 196, 189, 212, 22, 158, 203, 243, 19, 37, 237, 245, 141, 129, 40, 74, 48, 7, 211, 157, 135, 182, 198, 7, 50, 149, 140, 10, 64]), digest := (bytes [79, 230, 202, 60, 75, 25, 28, 83, 137, 150, 87, 247, 147, 154, 163, 170, 149, 75, 116, 34, 185, 180, 199, 66, 219, 43, 113, 91, 127, 201, 229, 194]) }
  , digest := (bytes [78, 96, 39, 208, 7, 210, 182, 30, 243, 231, 203, 61, 143, 197, 176, 91, 214, 100, 7, 142, 216, 91, 137, 18, 224, 249, 19, 13, 51, 68, 17, 57])
}
  , jointOpening := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { proofStatementDigest := (bytes [32, 181, 152, 217, 168, 93, 39, 204, 129, 242, 203, 24, 188, 141, 39, 140, 94, 224, 84, 53, 160, 178, 146, 251, 174, 88, 139, 148, 162, 178, 115, 208]), mainLaneClaimDigest := (bytes [108, 237, 252, 249, 209, 228, 62, 176, 244, 253, 89, 245, 195, 134, 130, 123, 64, 16, 61, 85, 50, 172, 82, 145, 248, 136, 73, 133, 180, 197, 157, 200]), kernelOpeningClaimDigest := (bytes [78, 96, 39, 208, 7, 210, 182, 30, 243, 231, 203, 61, 143, 197, 176, 91, 214, 100, 7, 142, 216, 91, 137, 18, 224, 249, 19, 13, 51, 68, 17, 57]), digest := (bytes [95, 137, 138, 81, 1, 86, 244, 166, 100, 197, 225, 118, 27, 167, 162, 55, 148, 35, 81, 160, 48, 235, 27, 152, 115, 150, 105, 160, 34, 223, 66, 130]) }, digest := (bytes [104, 37, 188, 98, 104, 64, 166, 96, 168, 76, 234, 102, 124, 179, 71, 160, 150, 114, 0, 25, 200, 7, 7, 169, 7, 211, 199, 92, 38, 179, 215, 119]) }
  , root0 := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), stages := { stage1Digest := (bytes [194, 252, 99, 144, 188, 159, 214, 228, 231, 171, 68, 72, 228, 177, 15, 240, 107, 157, 37, 137, 34, 45, 224, 66, 91, 32, 164, 62, 84, 65, 17, 143]), stage2Digest := (bytes [195, 56, 19, 82, 10, 216, 77, 152, 169, 234, 25, 78, 251, 192, 104, 239, 137, 52, 112, 2, 63, 204, 59, 153, 50, 225, 142, 65, 73, 170, 42, 196]), stage3Digest := (bytes [80, 77, 243, 233, 190, 184, 52, 23, 82, 127, 172, 195, 183, 255, 127, 86, 245, 226, 157, 206, 2, 214, 47, 191, 184, 177, 70, 30, 242, 179, 62, 115]), digest := (bytes [64, 67, 12, 118, 183, 29, 157, 56, 210, 197, 101, 75, 99, 201, 9, 36, 68, 164, 229, 55, 101, 186, 134, 207, 95, 213, 181, 214, 40, 27, 211, 89]) }, terminal := { root0Digest := (bytes [112, 237, 148, 129, 8, 187, 27, 103, 196, 62, 229, 65, 80, 123, 21, 108, 248, 197, 118, 80, 87, 178, 35, 86, 12, 75, 11, 46, 200, 11, 70, 74]), executionDigest := (bytes [74, 202, 66, 25, 106, 38, 91, 108, 83, 143, 56, 156, 203, 227, 101, 222, 4, 137, 150, 5, 195, 49, 240, 232, 104, 115, 55, 93, 227, 232, 236, 253]), finalStateDigest := (bytes [182, 31, 54, 213, 113, 159, 201, 136, 65, 181, 111, 174, 113, 197, 150, 29, 93, 126, 40, 13, 253, 225, 7, 190, 200, 101, 176, 45, 199, 60, 8, 160]), transcriptFinalDigest := (bytes [12, 192, 210, 153, 196, 189, 212, 22, 158, 203, 243, 19, 37, 237, 245, 141, 129, 40, 74, 48, 7, 211, 157, 135, 182, 198, 7, 50, 149, 140, 10, 64]), digest := (bytes [23, 45, 241, 252, 188, 146, 163, 251, 215, 141, 225, 10, 201, 72, 83, 157, 158, 59, 46, 33, 165, 191, 154, 128, 87, 234, 163, 57, 90, 183, 5, 7]) }, digest := (bytes [198, 218, 189, 196, 168, 32, 253, 49, 106, 134, 139, 150, 251, 23, 157, 43, 84, 217, 184, 82, 117, 205, 228, 164, 90, 226, 46, 46, 194, 54, 138, 140]) }
  , digest := (bytes [215, 76, 129, 92, 101, 191, 150, 231, 240, 224, 180, 253, 144, 97, 202, 240, 4, 72, 213, 239, 8, 210, 216, 98, 67, 200, 186, 20, 128, 31, 13, 72])
}
  , statement := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , foldSchedule := Nightstream.FoldSchedule.wholeTrace
  , chunkCount := 1
  , stageClaimsDigest := (bytes [113, 5, 129, 162, 39, 178, 145, 40, 126, 199, 229, 224, 231, 199, 124, 27, 38, 154, 83, 89, 56, 19, 163, 19, 16, 245, 79, 232, 84, 249, 149, 143])
  , stagePackagesDigest := (bytes [21, 177, 110, 213, 218, 127, 92, 48, 71, 84, 132, 202, 179, 18, 150, 197, 231, 121, 123, 155, 210, 218, 156, 31, 86, 14, 94, 218, 64, 74, 110, 62])
  , kernelOpeningDigest := (bytes [28, 82, 111, 203, 143, 45, 58, 36, 78, 238, 215, 216, 169, 16, 233, 168, 216, 92, 0, 220, 175, 17, 155, 108, 36, 207, 212, 75, 238, 112, 75, 177])
  , preparedStepBindingsDigest := (bytes [122, 127, 230, 234, 20, 88, 54, 132, 38, 4, 241, 103, 237, 27, 91, 231, 123, 166, 255, 110, 210, 175, 85, 2, 174, 249, 69, 66, 249, 6, 108, 229])
  , executionDigest := (bytes [74, 202, 66, 25, 106, 38, 91, 108, 83, 143, 56, 156, 203, 227, 101, 222, 4, 137, 150, 5, 195, 49, 240, 232, 104, 115, 55, 93, 227, 232, 236, 253])
  , finalStateDigest := (bytes [182, 31, 54, 213, 113, 159, 201, 136, 65, 181, 111, 174, 113, 197, 150, 29, 93, 126, 40, 13, 253, 225, 7, 190, 200, 101, 176, 45, 199, 60, 8, 160])
  , transcriptFinalDigest := (bytes [12, 192, 210, 153, 196, 189, 212, 22, 158, 203, 243, 19, 37, 237, 245, 141, 129, 40, 74, 48, 7, 211, 157, 135, 182, 198, 7, 50, 149, 140, 10, 64])
  , mainLaneSurfaceDigest := (bytes [21, 32, 89, 65, 203, 237, 252, 46, 138, 210, 129, 189, 128, 176, 97, 244, 115, 49, 134, 130, 131, 98, 65, 189, 54, 16, 104, 109, 135, 127, 217, 164])
  , rootLaneColumnsDigest := (bytes [38, 137, 143, 183, 203, 147, 94, 154, 15, 226, 51, 246, 88, 62, 137, 224, 176, 66, 88, 191, 172, 42, 75, 9, 199, 148, 179, 224, 80, 184, 102, 237])
  , publicStepCount := 29
  , initialPc := 0
  , finalPc := 36
  , halted := true
  , digest := (bytes [32, 181, 152, 217, 168, 93, 39, 204, 129, 242, 203, 24, 188, 141, 39, 140, 94, 224, 84, 53, 160, 178, 146, 251, 174, 88, 139, 148, 162, 178, 115, 208])
}
  , kernel := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "unsigned_divrem_chain_ecall", fixtureId := "unsigned_divrem_chain_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.unsignedDivRem, .controlFlow] }
  , executionDigest := (bytes [74, 202, 66, 25, 106, 38, 91, 108, 83, 143, 56, 156, 203, 227, 101, 222, 4, 137, 150, 5, 195, 49, 240, 232, 104, 115, 55, 93, 227, 232, 236, 253])
  , shape := { executionRowCount := 29, realRowCount := 9, effectRowCount := 9, commitRowCount := 9, digest := (bytes [24, 132, 44, 43, 87, 247, 238, 104, 161, 144, 32, 235, 250, 233, 3, 16, 164, 116, 139, 60, 35, 7, 93, 96, 191, 234, 80, 117, 232, 254, 76, 234]) }
  , digest := (bytes [181, 238, 6, 82, 65, 2, 82, 192, 131, 249, 105, 136, 215, 253, 37, 131, 86, 148, 25, 38, 28, 163, 255, 218, 66, 233, 235, 6, 42, 133, 57, 142])
}
  , stages := { summary := { stage1RowCount := 29, stage2RegisterReadCount := 52, stage2RegisterWriteCount := 28, stage2RamEventCount := 0, stage2TwistLinkCount := 29, stage3ContinuityCount := 9, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [91, 118, 203, 75, 35, 44, 12, 201, 53, 12, 56, 211, 203, 113, 194, 87, 211, 57, 109, 234, 227, 160, 16, 44, 52, 145, 24, 0, 94, 199, 86, 12]) }, digest := (bytes [133, 72, 142, 180, 234, 189, 148, 240, 162, 217, 30, 145, 225, 31, 232, 81, 72, 123, 80, 136, 134, 158, 29, 147, 163, 200, 66, 61, 227, 236, 100, 117]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [245, 72, 75, 42, 73, 229, 163, 53, 146, 214, 107, 216, 213, 85, 133, 116, 173, 47, 114, 185, 134, 203, 104, 165, 250, 92, 247, 14, 227, 198, 71, 208]), stage1Digest := (bytes [8, 10, 70, 35, 185, 90, 227, 79, 241, 72, 179, 33, 38, 114, 54, 133, 109, 62, 127, 17, 154, 28, 229, 43, 255, 142, 150, 108, 205, 106, 215, 40]), stage2Digest := (bytes [203, 109, 106, 163, 136, 226, 225, 78, 218, 232, 24, 23, 216, 70, 236, 1, 18, 239, 5, 143, 83, 125, 115, 135, 35, 127, 89, 72, 100, 175, 181, 155]), stage3Digest := (bytes [220, 38, 60, 55, 60, 34, 226, 1, 163, 13, 73, 152, 205, 63, 225, 187, 60, 26, 212, 34, 168, 63, 107, 178, 205, 150, 211, 14, 53, 254, 107, 141]), transcriptDigest := (bytes [12, 192, 210, 153, 196, 189, 212, 22, 158, 203, 243, 19, 37, 237, 245, 141, 129, 40, 74, 48, 7, 211, 157, 135, 182, 198, 7, 50, 149, 140, 10, 64]), executionDigest := (bytes [74, 202, 66, 25, 106, 38, 91, 108, 83, 143, 56, 156, 203, 227, 101, 222, 4, 137, 150, 5, 195, 49, 240, 232, 104, 115, 55, 93, 227, 232, 236, 253]), digest := (bytes [101, 25, 139, 85, 148, 244, 221, 76, 159, 125, 103, 233, 98, 154, 13, 211, 154, 254, 215, 55, 149, 170, 200, 46, 244, 18, 85, 17, 187, 226, 194, 138]) }, statementDigest := (bytes [210, 17, 226, 113, 48, 32, 145, 113, 31, 176, 17, 212, 130, 44, 196, 231, 103, 179, 213, 51, 106, 250, 6, 228, 50, 185, 144, 86, 150, 64, 116, 44]), proofDigest := (bytes [156, 41, 101, 247, 81, 233, 165, 13, 175, 60, 109, 142, 46, 65, 107, 223, 135, 113, 32, 52, 158, 178, 207, 35, 150, 53, 26, 12, 9, 214, 225, 148]), digest := (bytes [113, 5, 129, 162, 39, 178, 145, 40, 126, 199, 229, 224, 231, 199, 124, 27, 38, 154, 83, 89, 56, 19, 163, 19, 16, 245, 79, 232, 84, 249, 149, 143]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [202, 244, 4, 158, 46, 125, 232, 78, 96, 136, 208, 229, 133, 159, 55, 23, 25, 188, 40, 64, 162, 32, 87, 74, 10, 162, 215, 241, 22, 9, 27, 112]), stage1Digest := (bytes [84, 206, 142, 168, 93, 56, 75, 141, 229, 55, 180, 100, 199, 16, 42, 116, 200, 87, 88, 19, 121, 131, 122, 152, 187, 79, 10, 207, 157, 128, 75, 64]), stage2Digest := (bytes [233, 244, 5, 85, 164, 65, 201, 245, 154, 6, 245, 55, 160, 133, 24, 0, 98, 0, 72, 170, 44, 114, 128, 216, 10, 232, 185, 75, 115, 11, 21, 57]), stage3Digest := (bytes [248, 162, 12, 203, 170, 40, 43, 20, 152, 3, 84, 198, 147, 220, 41, 13, 65, 180, 249, 53, 251, 90, 130, 174, 144, 179, 189, 160, 32, 203, 228, 148]), digest := (bytes [232, 24, 197, 155, 24, 237, 95, 194, 116, 198, 217, 85, 95, 37, 180, 138, 102, 146, 78, 30, 169, 15, 90, 144, 147, 214, 170, 43, 245, 212, 142, 138]) }, digest := (bytes [21, 177, 110, 213, 218, 127, 92, 48, 71, 84, 132, 202, 179, 18, 150, 197, 231, 121, 123, 155, 210, 218, 156, 31, 86, 14, 94, 218, 64, 74, 110, 62]) }
  , kernelOpening := { openingDigest := (bytes [191, 138, 72, 200, 97, 143, 211, 249, 193, 138, 167, 4, 198, 38, 157, 94, 2, 19, 193, 51, 126, 165, 91, 115, 203, 137, 149, 175, 245, 167, 100, 184]), bindings := { claimDigest := (bytes [58, 79, 60, 5, 44, 217, 210, 184, 12, 93, 193, 41, 184, 126, 53, 85, 15, 125, 156, 137, 120, 193, 126, 139, 36, 248, 235, 179, 121, 12, 254, 237]), bindingsDigest := (bytes [98, 122, 12, 239, 168, 23, 243, 235, 43, 254, 227, 125, 21, 191, 120, 14, 197, 0, 137, 95, 184, 231, 127, 220, 153, 170, 197, 125, 76, 153, 34, 171]), preparedStepsDigest := (bytes [241, 188, 244, 234, 213, 229, 19, 141, 178, 83, 184, 95, 217, 231, 124, 251, 178, 198, 193, 160, 225, 156, 159, 131, 198, 255, 189, 217, 235, 245, 110, 247]), digest := (bytes [20, 6, 182, 137, 33, 163, 220, 89, 111, 169, 163, 104, 236, 100, 231, 251, 211, 39, 169, 209, 35, 224, 96, 234, 227, 229, 116, 97, 22, 213, 93, 172]) }, digest := (bytes [28, 82, 111, 203, 143, 45, 58, 36, 78, 238, 215, 216, 169, 16, 233, 168, 216, 92, 0, 220, 175, 17, 155, 108, 36, 207, 212, 75, 238, 112, 75, 177]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [122, 127, 230, 234, 20, 88, 54, 132, 38, 4, 241, 103, 237, 27, 91, 231, 123, 166, 255, 110, 210, 175, 85, 2, 174, 249, 69, 66, 249, 6, 108, 229]), terminal := { root0Digest := (bytes [112, 237, 148, 129, 8, 187, 27, 103, 196, 62, 229, 65, 80, 123, 21, 108, 248, 197, 118, 80, 87, 178, 35, 86, 12, 75, 11, 46, 200, 11, 70, 74]), executionDigest := (bytes [74, 202, 66, 25, 106, 38, 91, 108, 83, 143, 56, 156, 203, 227, 101, 222, 4, 137, 150, 5, 195, 49, 240, 232, 104, 115, 55, 93, 227, 232, 236, 253]), finalStateDigest := (bytes [182, 31, 54, 213, 113, 159, 201, 136, 65, 181, 111, 174, 113, 197, 150, 29, 93, 126, 40, 13, 253, 225, 7, 190, 200, 101, 176, 45, 199, 60, 8, 160]), transcriptFinalDigest := (bytes [12, 192, 210, 153, 196, 189, 212, 22, 158, 203, 243, 19, 37, 237, 245, 141, 129, 40, 74, 48, 7, 211, 157, 135, 182, 198, 7, 50, 149, 140, 10, 64]), finalPc := 36, halted := true, digest := (bytes [59, 206, 20, 120, 239, 34, 156, 60, 113, 110, 27, 56, 27, 222, 197, 46, 134, 197, 77, 158, 110, 53, 49, 132, 134, 25, 149, 40, 174, 95, 59, 78]) }, digest := (bytes [46, 240, 34, 221, 181, 172, 209, 111, 193, 202, 64, 215, 26, 155, 138, 202, 36, 175, 37, 190, 17, 114, 7, 75, 93, 156, 128, 164, 23, 215, 96, 0]) }, statementDigest := (bytes [152, 165, 76, 254, 110, 85, 173, 45, 214, 249, 70, 188, 231, 198, 153, 212, 137, 1, 186, 150, 51, 237, 64, 178, 188, 81, 59, 229, 18, 51, 160, 242]), proofDigest := (bytes [216, 172, 107, 144, 190, 133, 113, 64, 238, 150, 20, 80, 179, 148, 46, 55, 164, 6, 83, 167, 119, 78, 41, 241, 52, 165, 202, 63, 222, 113, 191, 255]), digest := (bytes [1, 238, 175, 142, 127, 18, 11, 182, 150, 173, 181, 78, 116, 153, 144, 183, 131, 4, 46, 229, 90, 216, 194, 199, 25, 1, 229, 38, 74, 22, 155, 152]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [62, 154, 7, 200, 147, 245, 58, 185, 116, 64, 224, 46, 160, 35, 75, 87, 202, 13, 0, 146, 57, 39, 202, 76, 37, 197, 28, 178, 16, 93, 198, 238]), layoutVersion := 1, digest := (bytes [72, 20, 132, 106, 165, 238, 87, 32, 230, 222, 113, 145, 147, 49, 100, 223, 93, 208, 51, 219, 74, 178, 167, 73, 24, 194, 222, 170, 30, 92, 62, 246]) }, rowWidth := 38, timeLen := 29, columnDigests := [(bytes [225, 144, 71, 219, 98, 150, 176, 137, 117, 152, 218, 12, 231, 77, 180, 251, 202, 38, 51, 2, 145, 159, 54, 17, 197, 124, 89, 195, 83, 238, 136, 81]), (bytes [146, 158, 140, 155, 179, 185, 149, 183, 251, 209, 198, 147, 38, 37, 140, 69, 160, 9, 216, 55, 192, 190, 59, 26, 216, 217, 62, 24, 127, 85, 137, 142]), (bytes [142, 34, 112, 18, 173, 54, 6, 140, 104, 236, 245, 165, 32, 207, 224, 204, 82, 82, 62, 69, 74, 161, 107, 70, 38, 3, 105, 29, 53, 149, 156, 128]), (bytes [177, 65, 50, 144, 245, 110, 233, 171, 232, 225, 119, 68, 4, 55, 249, 173, 251, 72, 195, 139, 226, 128, 143, 115, 199, 221, 154, 3, 72, 2, 83, 115]), (bytes [187, 110, 30, 154, 212, 74, 138, 163, 178, 1, 214, 45, 7, 177, 164, 84, 240, 36, 178, 64, 217, 239, 121, 230, 186, 117, 115, 88, 47, 101, 88, 247]), (bytes [169, 151, 16, 42, 183, 14, 65, 149, 6, 102, 30, 248, 238, 152, 25, 94, 198, 232, 194, 105, 153, 30, 91, 175, 34, 125, 241, 252, 15, 216, 76, 157]), (bytes [69, 222, 94, 63, 123, 239, 52, 203, 118, 204, 96, 88, 131, 44, 220, 53, 199, 109, 252, 221, 217, 182, 189, 85, 59, 232, 124, 251, 182, 226, 86, 249]), (bytes [158, 79, 224, 220, 254, 240, 26, 24, 34, 166, 48, 240, 165, 20, 200, 161, 31, 138, 115, 24, 228, 82, 220, 226, 70, 171, 225, 32, 38, 171, 101, 148]), (bytes [247, 133, 122, 61, 3, 181, 179, 2, 78, 121, 199, 99, 188, 155, 129, 167, 43, 7, 104, 123, 237, 51, 187, 22, 241, 150, 190, 38, 197, 98, 2, 20]), (bytes [233, 241, 59, 183, 115, 16, 155, 112, 147, 254, 37, 9, 198, 213, 255, 240, 142, 160, 77, 159, 152, 40, 123, 72, 163, 100, 215, 222, 18, 213, 248, 209]), (bytes [25, 189, 217, 85, 137, 71, 57, 168, 127, 18, 14, 178, 71, 101, 16, 248, 186, 217, 126, 171, 0, 120, 231, 48, 103, 99, 103, 74, 172, 118, 225, 1]), (bytes [251, 57, 85, 182, 134, 20, 27, 50, 49, 220, 118, 202, 190, 3, 143, 75, 130, 31, 127, 91, 71, 143, 150, 228, 39, 35, 60, 29, 131, 71, 39, 0]), (bytes [133, 122, 33, 147, 47, 160, 190, 209, 160, 150, 0, 77, 38, 48, 162, 196, 160, 164, 2, 129, 207, 137, 136, 250, 155, 128, 120, 36, 81, 44, 253, 222]), (bytes [40, 128, 59, 105, 74, 174, 48, 74, 184, 54, 190, 56, 96, 87, 192, 47, 253, 241, 23, 15, 124, 138, 14, 203, 251, 156, 155, 174, 116, 135, 47, 72]), (bytes [53, 244, 115, 22, 63, 240, 250, 109, 33, 19, 55, 63, 40, 28, 3, 202, 100, 147, 84, 59, 5, 95, 249, 90, 190, 191, 37, 62, 163, 169, 52, 189]), (bytes [131, 250, 236, 20, 8, 99, 18, 117, 217, 85, 133, 126, 4, 189, 51, 39, 25, 47, 47, 41, 93, 172, 80, 115, 27, 45, 128, 252, 31, 5, 206, 195]), (bytes [89, 61, 248, 224, 67, 160, 200, 219, 241, 254, 16, 244, 90, 48, 115, 25, 130, 84, 52, 147, 39, 142, 246, 176, 80, 152, 132, 95, 200, 49, 201, 248]), (bytes [34, 68, 71, 45, 18, 40, 1, 102, 204, 90, 252, 15, 188, 232, 150, 239, 238, 10, 156, 192, 2, 238, 172, 50, 238, 60, 78, 29, 84, 74, 152, 177]), (bytes [159, 44, 169, 53, 34, 215, 40, 87, 157, 79, 201, 156, 129, 131, 163, 240, 166, 165, 47, 251, 235, 27, 218, 15, 52, 43, 205, 37, 72, 232, 255, 240]), (bytes [101, 185, 21, 255, 183, 119, 49, 133, 193, 6, 195, 53, 13, 64, 166, 139, 241, 113, 47, 248, 95, 119, 234, 106, 233, 40, 164, 167, 223, 251, 49, 164]), (bytes [168, 134, 175, 127, 124, 235, 234, 224, 126, 84, 90, 179, 59, 107, 156, 102, 170, 123, 197, 54, 201, 107, 166, 55, 133, 242, 61, 198, 177, 28, 199, 166]), (bytes [131, 99, 176, 212, 241, 178, 229, 254, 243, 185, 144, 61, 54, 128, 21, 148, 105, 32, 116, 244, 80, 109, 39, 120, 94, 146, 185, 122, 98, 38, 125, 96]), (bytes [166, 137, 73, 4, 167, 238, 68, 129, 29, 111, 251, 56, 90, 45, 113, 96, 158, 150, 92, 141, 233, 178, 47, 207, 193, 232, 115, 123, 239, 109, 225, 81]), (bytes [109, 228, 106, 126, 1, 154, 101, 178, 99, 186, 169, 23, 190, 246, 6, 119, 133, 155, 169, 224, 104, 241, 168, 246, 26, 9, 245, 243, 159, 43, 193, 40]), (bytes [84, 71, 236, 195, 91, 244, 24, 129, 137, 205, 211, 129, 8, 108, 110, 4, 32, 103, 214, 34, 178, 142, 210, 138, 208, 159, 59, 233, 67, 117, 61, 177]), (bytes [215, 155, 157, 52, 106, 37, 10, 21, 143, 252, 226, 76, 12, 127, 111, 32, 62, 181, 75, 2, 72, 157, 245, 86, 27, 193, 119, 139, 213, 205, 211, 216]), (bytes [176, 156, 235, 147, 154, 227, 33, 241, 138, 17, 161, 227, 206, 89, 144, 172, 187, 187, 144, 2, 142, 67, 14, 164, 107, 205, 212, 89, 28, 207, 3, 12]), (bytes [124, 225, 65, 157, 149, 211, 123, 1, 114, 195, 64, 64, 70, 84, 85, 216, 233, 231, 253, 168, 237, 186, 106, 149, 149, 180, 108, 164, 197, 230, 255, 37]), (bytes [189, 65, 69, 91, 107, 106, 95, 158, 138, 149, 69, 103, 187, 116, 129, 248, 236, 235, 178, 249, 158, 57, 202, 59, 246, 51, 68, 78, 45, 103, 141, 148]), (bytes [60, 7, 219, 141, 178, 20, 175, 53, 193, 27, 181, 210, 212, 131, 112, 160, 200, 211, 210, 155, 50, 165, 51, 57, 58, 245, 219, 216, 32, 119, 115, 81]), (bytes [0, 241, 216, 6, 85, 233, 44, 163, 138, 25, 159, 156, 224, 140, 134, 57, 72, 140, 223, 209, 59, 9, 192, 229, 14, 251, 82, 157, 172, 21, 47, 73]), (bytes [220, 105, 109, 147, 191, 51, 134, 2, 29, 157, 72, 171, 79, 94, 51, 12, 175, 162, 154, 108, 2, 147, 247, 135, 227, 131, 107, 210, 127, 72, 20, 193]), (bytes [244, 155, 95, 10, 221, 240, 103, 187, 35, 194, 33, 54, 48, 100, 87, 121, 218, 115, 120, 167, 175, 123, 202, 115, 67, 230, 88, 80, 237, 214, 35, 19]), (bytes [76, 183, 241, 70, 105, 220, 125, 240, 46, 244, 80, 170, 139, 218, 70, 76, 38, 121, 105, 137, 50, 252, 43, 36, 186, 13, 80, 147, 251, 223, 13, 176]), (bytes [25, 109, 229, 191, 89, 237, 100, 249, 118, 122, 177, 62, 97, 27, 178, 71, 199, 215, 79, 119, 156, 97, 6, 148, 83, 95, 44, 254, 206, 210, 162, 180]), (bytes [154, 210, 102, 237, 124, 137, 226, 136, 9, 149, 91, 159, 118, 88, 107, 15, 229, 106, 238, 129, 85, 65, 104, 111, 8, 252, 131, 2, 196, 196, 82, 17]), (bytes [99, 160, 92, 133, 199, 2, 200, 7, 232, 31, 183, 118, 192, 5, 209, 191, 18, 76, 91, 162, 17, 123, 81, 154, 193, 172, 240, 228, 196, 150, 59, 119]), (bytes [255, 151, 239, 15, 190, 208, 229, 150, 31, 114, 213, 241, 235, 219, 84, 51, 158, 153, 120, 86, 41, 221, 168, 180, 76, 247, 19, 170, 58, 37, 126, 249])], familyDigest := (bytes [62, 154, 7, 200, 147, 245, 58, 185, 116, 64, 224, 46, 160, 35, 75, 87, 202, 13, 0, 146, 57, 39, 202, 76, 37, 197, 28, 178, 16, 93, 198, 238]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [62, 154, 7, 200, 147, 245, 58, 185, 116, 64, 224, 46, 160, 35, 75, 87, 202, 13, 0, 146, 57, 39, 202, 76, 37, 197, 28, 178, 16, 93, 198, 238]), layoutVersion := 1, digest := (bytes [72, 20, 132, 106, 165, 238, 87, 32, 230, 222, 113, 145, 147, 49, 100, 223, 93, 208, 51, 219, 74, 178, 167, 73, 24, 194, 222, 170, 30, 92, 62, 246]) }, logicalIndex := 0, digest := (bytes [157, 243, 0, 60, 241, 246, 254, 190, 204, 2, 60, 216, 77, 95, 223, 233, 200, 143, 150, 107, 143, 60, 45, 118, 175, 106, 167, 10, 36, 24, 167, 77]) }, valueDigest := (bytes [15, 203, 82, 147, 182, 107, 150, 168, 159, 107, 204, 115, 170, 200, 12, 67, 125, 81, 225, 219, 175, 26, 58, 39, 55, 35, 134, 130, 62, 126, 3, 37]), digest := (bytes [45, 161, 238, 241, 198, 238, 221, 31, 180, 58, 220, 162, 22, 61, 238, 251, 249, 195, 29, 205, 227, 246, 79, 201, 151, 86, 233, 105, 224, 236, 143, 125]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [62, 154, 7, 200, 147, 245, 58, 185, 116, 64, 224, 46, 160, 35, 75, 87, 202, 13, 0, 146, 57, 39, 202, 76, 37, 197, 28, 178, 16, 93, 198, 238]), layoutVersion := 1, digest := (bytes [72, 20, 132, 106, 165, 238, 87, 32, 230, 222, 113, 145, 147, 49, 100, 223, 93, 208, 51, 219, 74, 178, 167, 73, 24, 194, 222, 170, 30, 92, 62, 246]) }, logicalIndex := 28, digest := (bytes [233, 62, 123, 247, 47, 66, 12, 137, 97, 219, 154, 120, 8, 135, 37, 192, 34, 157, 217, 24, 146, 73, 251, 131, 32, 163, 221, 254, 78, 216, 51, 34]) }, valueDigest := (bytes [191, 59, 111, 91, 175, 174, 193, 106, 252, 237, 179, 109, 105, 90, 100, 212, 35, 239, 230, 162, 83, 17, 88, 13, 240, 150, 187, 164, 56, 114, 73, 39]), digest := (bytes [180, 81, 197, 89, 123, 21, 57, 248, 239, 158, 190, 71, 240, 70, 71, 207, 10, 185, 191, 205, 239, 154, 252, 215, 220, 242, 31, 7, 28, 106, 157, 137]) }), digest := (bytes [38, 137, 143, 183, 203, 147, 94, 154, 15, 226, 51, 246, 88, 62, 137, 224, 176, 66, 88, 191, 172, 42, 75, 9, 199, 148, 179, 224, 80, 184, 102, 237]) }
  , rootLaneCommitment := { timeLen := 29, commitments := { commitmentCount := 38, digest := (bytes [2, 195, 15, 176, 74, 156, 14, 145, 205, 30, 105, 114, 34, 141, 242, 217, 105, 100, 117, 46, 249, 188, 28, 111, 72, 195, 48, 19, 21, 39, 77, 21]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [2, 195, 15, 176, 74, 156, 14, 145, 205, 30, 105, 114, 34, 141, 242, 217, 105, 100, 117, 46, 249, 188, 28, 111, 72, 195, 48, 19, 21, 39, 77, 21]), layoutVersion := 3, digest := (bytes [107, 210, 58, 64, 103, 214, 200, 23, 157, 252, 53, 151, 94, 117, 179, 18, 97, 24, 125, 232, 65, 255, 83, 37, 252, 49, 227, 196, 7, 172, 22, 254]) }, logicalIndex := 0, digest := (bytes [132, 75, 176, 50, 98, 124, 10, 163, 65, 72, 164, 172, 236, 29, 57, 36, 144, 74, 213, 185, 85, 221, 229, 157, 190, 66, 127, 60, 109, 248, 105, 36]) }, valueDigest := (bytes [15, 203, 82, 147, 182, 107, 150, 168, 159, 107, 204, 115, 170, 200, 12, 67, 125, 81, 225, 219, 175, 26, 58, 39, 55, 35, 134, 130, 62, 126, 3, 37]), digest := (bytes [143, 201, 227, 113, 227, 52, 190, 147, 201, 197, 250, 34, 101, 210, 119, 246, 66, 86, 0, 57, 190, 96, 107, 156, 186, 34, 219, 71, 26, 85, 5, 244]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [2, 195, 15, 176, 74, 156, 14, 145, 205, 30, 105, 114, 34, 141, 242, 217, 105, 100, 117, 46, 249, 188, 28, 111, 72, 195, 48, 19, 21, 39, 77, 21]), layoutVersion := 3, digest := (bytes [107, 210, 58, 64, 103, 214, 200, 23, 157, 252, 53, 151, 94, 117, 179, 18, 97, 24, 125, 232, 65, 255, 83, 37, 252, 49, 227, 196, 7, 172, 22, 254]) }, logicalIndex := 28, digest := (bytes [228, 49, 68, 70, 171, 104, 219, 143, 14, 198, 244, 25, 53, 98, 211, 75, 148, 14, 190, 247, 181, 218, 158, 239, 149, 181, 105, 155, 187, 206, 1, 129]) }, valueDigest := (bytes [191, 59, 111, 91, 175, 174, 193, 106, 252, 237, 179, 109, 105, 90, 100, 212, 35, 239, 230, 162, 83, 17, 88, 13, 240, 150, 187, 164, 56, 114, 73, 39]), digest := (bytes [0, 246, 160, 121, 86, 247, 118, 202, 26, 120, 220, 155, 194, 122, 193, 229, 214, 70, 4, 38, 18, 243, 44, 123, 80, 244, 64, 114, 215, 121, 214, 30]) }), digest := (bytes [150, 62, 140, 172, 232, 178, 145, 115, 116, 114, 88, 213, 56, 166, 39, 55, 80, 244, 202, 250, 116, 153, 16, 155, 166, 156, 246, 97, 75, 108, 0, 65]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [38, 137, 143, 183, 203, 147, 94, 154, 15, 226, 51, 246, 88, 62, 137, 224, 176, 66, 88, 191, 172, 42, 75, 9, 199, 148, 179, 224, 80, 184, 102, 237]), rootLaneCommitmentDigest := (bytes [150, 62, 140, 172, 232, 178, 145, 115, 116, 114, 88, 213, 56, 166, 39, 55, 80, 244, 202, 250, 116, 153, 16, 155, 166, 156, 246, 97, 75, 108, 0, 65]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 29, digest := (bytes [211, 98, 237, 242, 215, 31, 14, 15, 184, 13, 191, 171, 253, 34, 21, 29, 65, 28, 97, 73, 72, 62, 243, 8, 57, 223, 199, 211, 62, 146, 193, 73]) }, statementDigest := (bytes [7, 54, 218, 74, 91, 87, 126, 77, 113, 29, 100, 248, 179, 47, 55, 221, 251, 156, 123, 73, 245, 179, 210, 212, 194, 170, 217, 229, 66, 118, 179, 0]), proofDigest := (bytes [227, 177, 167, 54, 118, 140, 153, 71, 128, 178, 68, 36, 4, 94, 19, 13, 124, 70, 73, 221, 181, 240, 4, 207, 23, 61, 79, 232, 254, 140, 120, 56]), digest := (bytes [0, 140, 31, 32, 123, 73, 34, 6, 104, 48, 110, 75, 192, 245, 251, 55, 159, 231, 142, 107, 171, 235, 15, 157, 150, 238, 207, 182, 36, 55, 202, 100]) }
  , digest := (bytes [236, 173, 150, 123, 212, 185, 6, 179, 2, 88, 193, 125, 198, 47, 99, 169, 201, 113, 124, 81, 200, 14, 52, 145, 93, 10, 22, 243, 17, 92, 156, 200])
}
}
    , exportedStatement := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , foldSchedule := Nightstream.FoldSchedule.wholeTrace
  , chunkCount := 1
  , stageClaimsDigest := (bytes [113, 5, 129, 162, 39, 178, 145, 40, 126, 199, 229, 224, 231, 199, 124, 27, 38, 154, 83, 89, 56, 19, 163, 19, 16, 245, 79, 232, 84, 249, 149, 143])
  , stagePackagesDigest := (bytes [21, 177, 110, 213, 218, 127, 92, 48, 71, 84, 132, 202, 179, 18, 150, 197, 231, 121, 123, 155, 210, 218, 156, 31, 86, 14, 94, 218, 64, 74, 110, 62])
  , kernelOpeningDigest := (bytes [28, 82, 111, 203, 143, 45, 58, 36, 78, 238, 215, 216, 169, 16, 233, 168, 216, 92, 0, 220, 175, 17, 155, 108, 36, 207, 212, 75, 238, 112, 75, 177])
  , preparedStepBindingsDigest := (bytes [122, 127, 230, 234, 20, 88, 54, 132, 38, 4, 241, 103, 237, 27, 91, 231, 123, 166, 255, 110, 210, 175, 85, 2, 174, 249, 69, 66, 249, 6, 108, 229])
  , executionDigest := (bytes [74, 202, 66, 25, 106, 38, 91, 108, 83, 143, 56, 156, 203, 227, 101, 222, 4, 137, 150, 5, 195, 49, 240, 232, 104, 115, 55, 93, 227, 232, 236, 253])
  , finalStateDigest := (bytes [182, 31, 54, 213, 113, 159, 201, 136, 65, 181, 111, 174, 113, 197, 150, 29, 93, 126, 40, 13, 253, 225, 7, 190, 200, 101, 176, 45, 199, 60, 8, 160])
  , transcriptFinalDigest := (bytes [12, 192, 210, 153, 196, 189, 212, 22, 158, 203, 243, 19, 37, 237, 245, 141, 129, 40, 74, 48, 7, 211, 157, 135, 182, 198, 7, 50, 149, 140, 10, 64])
  , mainLaneSurfaceDigest := (bytes [21, 32, 89, 65, 203, 237, 252, 46, 138, 210, 129, 189, 128, 176, 97, 244, 115, 49, 134, 130, 131, 98, 65, 189, 54, 16, 104, 109, 135, 127, 217, 164])
  , rootLaneColumnsDigest := (bytes [38, 137, 143, 183, 203, 147, 94, 154, 15, 226, 51, 246, 88, 62, 137, 224, 176, 66, 88, 191, 172, 42, 75, 9, 199, 148, 179, 224, 80, 184, 102, 237])
  , publicStepCount := 29
  , initialPc := 0
  , finalPc := 36
  , halted := true
  , digest := (bytes [32, 181, 152, 217, 168, 93, 39, 204, 129, 242, 203, 24, 188, 141, 39, 140, 94, 224, 84, 53, 160, 178, 146, 251, 174, 88, 139, 148, 162, 178, 115, 208])
}
    , exportedClaims := {
  accepted := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , statement := { proofStatementDigest := (bytes [32, 181, 152, 217, 168, 93, 39, 204, 129, 242, 203, 24, 188, 141, 39, 140, 94, 224, 84, 53, 160, 178, 146, 251, 174, 88, 139, 148, 162, 178, 115, 208]), kernelOpeningDigest := (bytes [28, 82, 111, 203, 143, 45, 58, 36, 78, 238, 215, 216, 169, 16, 233, 168, 216, 92, 0, 220, 175, 17, 155, 108, 36, 207, 212, 75, 238, 112, 75, 177]), digest := (bytes [44, 13, 115, 98, 242, 163, 215, 133, 186, 43, 125, 20, 199, 160, 193, 22, 245, 222, 143, 238, 84, 116, 66, 112, 177, 100, 92, 201, 226, 107, 97, 122]) }
  , mainLane := { mainLaneBundleDigest := (bytes [0, 140, 31, 32, 123, 73, 34, 6, 104, 48, 110, 75, 192, 245, 251, 55, 159, 231, 142, 107, 171, 235, 15, 157, 150, 238, 207, 182, 36, 55, 202, 100]), digest := (bytes [112, 169, 119, 145, 153, 75, 115, 250, 124, 119, 173, 76, 205, 10, 250, 80, 204, 224, 38, 18, 160, 29, 32, 109, 213, 58, 21, 237, 53, 243, 187, 189]) }
  , terminal := { finalStateDigest := (bytes [182, 31, 54, 213, 113, 159, 201, 136, 65, 181, 111, 174, 113, 197, 150, 29, 93, 126, 40, 13, 253, 225, 7, 190, 200, 101, 176, 45, 199, 60, 8, 160]), finalPc := 36, halted := true, digest := (bytes [203, 187, 208, 63, 190, 89, 203, 226, 159, 52, 250, 7, 117, 54, 218, 9, 197, 176, 163, 91, 194, 29, 49, 62, 18, 251, 128, 12, 176, 3, 70, 112]) }
  , digest := (bytes [143, 171, 77, 9, 59, 226, 5, 53, 143, 139, 17, 88, 165, 75, 36, 16, 202, 4, 203, 191, 173, 5, 101, 38, 37, 80, 184, 127, 140, 42, 231, 109])
}
  , mainLane := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { mainLaneBundleDigest := (bytes [0, 140, 31, 32, 123, 73, 34, 6, 104, 48, 110, 75, 192, 245, 251, 55, 159, 231, 142, 107, 171, 235, 15, 157, 150, 238, 207, 182, 36, 55, 202, 100]), digest := (bytes [119, 54, 9, 98, 44, 115, 125, 210, 117, 162, 126, 187, 147, 66, 83, 66, 179, 43, 94, 194, 122, 44, 209, 21, 86, 67, 201, 23, 64, 52, 50, 220]) }, digest := (bytes [108, 237, 252, 249, 209, 228, 62, 176, 244, 253, 89, 245, 195, 134, 130, 123, 64, 16, 61, 85, 50, 172, 82, 145, 248, 136, 73, 133, 180, 197, 157, 200]) }
  , opening := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , stages := { stageClaimsDigest := (bytes [113, 5, 129, 162, 39, 178, 145, 40, 126, 199, 229, 224, 231, 199, 124, 27, 38, 154, 83, 89, 56, 19, 163, 19, 16, 245, 79, 232, 84, 249, 149, 143]), stagePackagesDigest := (bytes [21, 177, 110, 213, 218, 127, 92, 48, 71, 84, 132, 202, 179, 18, 150, 197, 231, 121, 123, 155, 210, 218, 156, 31, 86, 14, 94, 218, 64, 74, 110, 62]), kernelOpeningDigest := (bytes [28, 82, 111, 203, 143, 45, 58, 36, 78, 238, 215, 216, 169, 16, 233, 168, 216, 92, 0, 220, 175, 17, 155, 108, 36, 207, 212, 75, 238, 112, 75, 177]), digest := (bytes [5, 213, 65, 25, 22, 206, 225, 111, 83, 167, 83, 121, 159, 21, 9, 47, 240, 181, 23, 117, 203, 81, 12, 208, 144, 52, 137, 6, 124, 43, 199, 56]) }
  , terminal := { preparedStepBindingsDigest := (bytes [122, 127, 230, 234, 20, 88, 54, 132, 38, 4, 241, 103, 237, 27, 91, 231, 123, 166, 255, 110, 210, 175, 85, 2, 174, 249, 69, 66, 249, 6, 108, 229]), executionDigest := (bytes [74, 202, 66, 25, 106, 38, 91, 108, 83, 143, 56, 156, 203, 227, 101, 222, 4, 137, 150, 5, 195, 49, 240, 232, 104, 115, 55, 93, 227, 232, 236, 253]), transcriptFinalDigest := (bytes [12, 192, 210, 153, 196, 189, 212, 22, 158, 203, 243, 19, 37, 237, 245, 141, 129, 40, 74, 48, 7, 211, 157, 135, 182, 198, 7, 50, 149, 140, 10, 64]), digest := (bytes [79, 230, 202, 60, 75, 25, 28, 83, 137, 150, 87, 247, 147, 154, 163, 170, 149, 75, 116, 34, 185, 180, 199, 66, 219, 43, 113, 91, 127, 201, 229, 194]) }
  , digest := (bytes [78, 96, 39, 208, 7, 210, 182, 30, 243, 231, 203, 61, 143, 197, 176, 91, 214, 100, 7, 142, 216, 91, 137, 18, 224, 249, 19, 13, 51, 68, 17, 57])
}
  , jointOpening := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { proofStatementDigest := (bytes [32, 181, 152, 217, 168, 93, 39, 204, 129, 242, 203, 24, 188, 141, 39, 140, 94, 224, 84, 53, 160, 178, 146, 251, 174, 88, 139, 148, 162, 178, 115, 208]), mainLaneClaimDigest := (bytes [108, 237, 252, 249, 209, 228, 62, 176, 244, 253, 89, 245, 195, 134, 130, 123, 64, 16, 61, 85, 50, 172, 82, 145, 248, 136, 73, 133, 180, 197, 157, 200]), kernelOpeningClaimDigest := (bytes [78, 96, 39, 208, 7, 210, 182, 30, 243, 231, 203, 61, 143, 197, 176, 91, 214, 100, 7, 142, 216, 91, 137, 18, 224, 249, 19, 13, 51, 68, 17, 57]), digest := (bytes [95, 137, 138, 81, 1, 86, 244, 166, 100, 197, 225, 118, 27, 167, 162, 55, 148, 35, 81, 160, 48, 235, 27, 152, 115, 150, 105, 160, 34, 223, 66, 130]) }, digest := (bytes [104, 37, 188, 98, 104, 64, 166, 96, 168, 76, 234, 102, 124, 179, 71, 160, 150, 114, 0, 25, 200, 7, 7, 169, 7, 211, 199, 92, 38, 179, 215, 119]) }
  , root0 := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), stages := { stage1Digest := (bytes [194, 252, 99, 144, 188, 159, 214, 228, 231, 171, 68, 72, 228, 177, 15, 240, 107, 157, 37, 137, 34, 45, 224, 66, 91, 32, 164, 62, 84, 65, 17, 143]), stage2Digest := (bytes [195, 56, 19, 82, 10, 216, 77, 152, 169, 234, 25, 78, 251, 192, 104, 239, 137, 52, 112, 2, 63, 204, 59, 153, 50, 225, 142, 65, 73, 170, 42, 196]), stage3Digest := (bytes [80, 77, 243, 233, 190, 184, 52, 23, 82, 127, 172, 195, 183, 255, 127, 86, 245, 226, 157, 206, 2, 214, 47, 191, 184, 177, 70, 30, 242, 179, 62, 115]), digest := (bytes [64, 67, 12, 118, 183, 29, 157, 56, 210, 197, 101, 75, 99, 201, 9, 36, 68, 164, 229, 55, 101, 186, 134, 207, 95, 213, 181, 214, 40, 27, 211, 89]) }, terminal := { root0Digest := (bytes [112, 237, 148, 129, 8, 187, 27, 103, 196, 62, 229, 65, 80, 123, 21, 108, 248, 197, 118, 80, 87, 178, 35, 86, 12, 75, 11, 46, 200, 11, 70, 74]), executionDigest := (bytes [74, 202, 66, 25, 106, 38, 91, 108, 83, 143, 56, 156, 203, 227, 101, 222, 4, 137, 150, 5, 195, 49, 240, 232, 104, 115, 55, 93, 227, 232, 236, 253]), finalStateDigest := (bytes [182, 31, 54, 213, 113, 159, 201, 136, 65, 181, 111, 174, 113, 197, 150, 29, 93, 126, 40, 13, 253, 225, 7, 190, 200, 101, 176, 45, 199, 60, 8, 160]), transcriptFinalDigest := (bytes [12, 192, 210, 153, 196, 189, 212, 22, 158, 203, 243, 19, 37, 237, 245, 141, 129, 40, 74, 48, 7, 211, 157, 135, 182, 198, 7, 50, 149, 140, 10, 64]), digest := (bytes [23, 45, 241, 252, 188, 146, 163, 251, 215, 141, 225, 10, 201, 72, 83, 157, 158, 59, 46, 33, 165, 191, 154, 128, 87, 234, 163, 57, 90, 183, 5, 7]) }, digest := (bytes [198, 218, 189, 196, 168, 32, 253, 49, 106, 134, 139, 150, 251, 23, 157, 43, 84, 217, 184, 82, 117, 205, 228, 164, 90, 226, 46, 46, 194, 54, 138, 140]) }
  , digest := (bytes [215, 76, 129, 92, 101, 191, 150, 231, 240, 224, 180, 253, 144, 97, 202, 240, 4, 72, 213, 239, 8, 210, 216, 98, 67, 200, 186, 20, 128, 31, 13, 72])
}
    , exportedKernelProof := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "unsigned_divrem_chain_ecall", fixtureId := "unsigned_divrem_chain_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.unsignedDivRem, .controlFlow] }
  , executionDigest := (bytes [74, 202, 66, 25, 106, 38, 91, 108, 83, 143, 56, 156, 203, 227, 101, 222, 4, 137, 150, 5, 195, 49, 240, 232, 104, 115, 55, 93, 227, 232, 236, 253])
  , shape := { executionRowCount := 29, realRowCount := 9, effectRowCount := 9, commitRowCount := 9, digest := (bytes [24, 132, 44, 43, 87, 247, 238, 104, 161, 144, 32, 235, 250, 233, 3, 16, 164, 116, 139, 60, 35, 7, 93, 96, 191, 234, 80, 117, 232, 254, 76, 234]) }
  , digest := (bytes [181, 238, 6, 82, 65, 2, 82, 192, 131, 249, 105, 136, 215, 253, 37, 131, 86, 148, 25, 38, 28, 163, 255, 218, 66, 233, 235, 6, 42, 133, 57, 142])
}
  , stages := { summary := { stage1RowCount := 29, stage2RegisterReadCount := 52, stage2RegisterWriteCount := 28, stage2RamEventCount := 0, stage2TwistLinkCount := 29, stage3ContinuityCount := 9, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [91, 118, 203, 75, 35, 44, 12, 201, 53, 12, 56, 211, 203, 113, 194, 87, 211, 57, 109, 234, 227, 160, 16, 44, 52, 145, 24, 0, 94, 199, 86, 12]) }, digest := (bytes [133, 72, 142, 180, 234, 189, 148, 240, 162, 217, 30, 145, 225, 31, 232, 81, 72, 123, 80, 136, 134, 158, 29, 147, 163, 200, 66, 61, 227, 236, 100, 117]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [245, 72, 75, 42, 73, 229, 163, 53, 146, 214, 107, 216, 213, 85, 133, 116, 173, 47, 114, 185, 134, 203, 104, 165, 250, 92, 247, 14, 227, 198, 71, 208]), stage1Digest := (bytes [8, 10, 70, 35, 185, 90, 227, 79, 241, 72, 179, 33, 38, 114, 54, 133, 109, 62, 127, 17, 154, 28, 229, 43, 255, 142, 150, 108, 205, 106, 215, 40]), stage2Digest := (bytes [203, 109, 106, 163, 136, 226, 225, 78, 218, 232, 24, 23, 216, 70, 236, 1, 18, 239, 5, 143, 83, 125, 115, 135, 35, 127, 89, 72, 100, 175, 181, 155]), stage3Digest := (bytes [220, 38, 60, 55, 60, 34, 226, 1, 163, 13, 73, 152, 205, 63, 225, 187, 60, 26, 212, 34, 168, 63, 107, 178, 205, 150, 211, 14, 53, 254, 107, 141]), transcriptDigest := (bytes [12, 192, 210, 153, 196, 189, 212, 22, 158, 203, 243, 19, 37, 237, 245, 141, 129, 40, 74, 48, 7, 211, 157, 135, 182, 198, 7, 50, 149, 140, 10, 64]), executionDigest := (bytes [74, 202, 66, 25, 106, 38, 91, 108, 83, 143, 56, 156, 203, 227, 101, 222, 4, 137, 150, 5, 195, 49, 240, 232, 104, 115, 55, 93, 227, 232, 236, 253]), digest := (bytes [101, 25, 139, 85, 148, 244, 221, 76, 159, 125, 103, 233, 98, 154, 13, 211, 154, 254, 215, 55, 149, 170, 200, 46, 244, 18, 85, 17, 187, 226, 194, 138]) }, statementDigest := (bytes [210, 17, 226, 113, 48, 32, 145, 113, 31, 176, 17, 212, 130, 44, 196, 231, 103, 179, 213, 51, 106, 250, 6, 228, 50, 185, 144, 86, 150, 64, 116, 44]), proofDigest := (bytes [156, 41, 101, 247, 81, 233, 165, 13, 175, 60, 109, 142, 46, 65, 107, 223, 135, 113, 32, 52, 158, 178, 207, 35, 150, 53, 26, 12, 9, 214, 225, 148]), digest := (bytes [113, 5, 129, 162, 39, 178, 145, 40, 126, 199, 229, 224, 231, 199, 124, 27, 38, 154, 83, 89, 56, 19, 163, 19, 16, 245, 79, 232, 84, 249, 149, 143]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [202, 244, 4, 158, 46, 125, 232, 78, 96, 136, 208, 229, 133, 159, 55, 23, 25, 188, 40, 64, 162, 32, 87, 74, 10, 162, 215, 241, 22, 9, 27, 112]), stage1Digest := (bytes [84, 206, 142, 168, 93, 56, 75, 141, 229, 55, 180, 100, 199, 16, 42, 116, 200, 87, 88, 19, 121, 131, 122, 152, 187, 79, 10, 207, 157, 128, 75, 64]), stage2Digest := (bytes [233, 244, 5, 85, 164, 65, 201, 245, 154, 6, 245, 55, 160, 133, 24, 0, 98, 0, 72, 170, 44, 114, 128, 216, 10, 232, 185, 75, 115, 11, 21, 57]), stage3Digest := (bytes [248, 162, 12, 203, 170, 40, 43, 20, 152, 3, 84, 198, 147, 220, 41, 13, 65, 180, 249, 53, 251, 90, 130, 174, 144, 179, 189, 160, 32, 203, 228, 148]), digest := (bytes [232, 24, 197, 155, 24, 237, 95, 194, 116, 198, 217, 85, 95, 37, 180, 138, 102, 146, 78, 30, 169, 15, 90, 144, 147, 214, 170, 43, 245, 212, 142, 138]) }, digest := (bytes [21, 177, 110, 213, 218, 127, 92, 48, 71, 84, 132, 202, 179, 18, 150, 197, 231, 121, 123, 155, 210, 218, 156, 31, 86, 14, 94, 218, 64, 74, 110, 62]) }
  , kernelOpening := { openingDigest := (bytes [191, 138, 72, 200, 97, 143, 211, 249, 193, 138, 167, 4, 198, 38, 157, 94, 2, 19, 193, 51, 126, 165, 91, 115, 203, 137, 149, 175, 245, 167, 100, 184]), bindings := { claimDigest := (bytes [58, 79, 60, 5, 44, 217, 210, 184, 12, 93, 193, 41, 184, 126, 53, 85, 15, 125, 156, 137, 120, 193, 126, 139, 36, 248, 235, 179, 121, 12, 254, 237]), bindingsDigest := (bytes [98, 122, 12, 239, 168, 23, 243, 235, 43, 254, 227, 125, 21, 191, 120, 14, 197, 0, 137, 95, 184, 231, 127, 220, 153, 170, 197, 125, 76, 153, 34, 171]), preparedStepsDigest := (bytes [241, 188, 244, 234, 213, 229, 19, 141, 178, 83, 184, 95, 217, 231, 124, 251, 178, 198, 193, 160, 225, 156, 159, 131, 198, 255, 189, 217, 235, 245, 110, 247]), digest := (bytes [20, 6, 182, 137, 33, 163, 220, 89, 111, 169, 163, 104, 236, 100, 231, 251, 211, 39, 169, 209, 35, 224, 96, 234, 227, 229, 116, 97, 22, 213, 93, 172]) }, digest := (bytes [28, 82, 111, 203, 143, 45, 58, 36, 78, 238, 215, 216, 169, 16, 233, 168, 216, 92, 0, 220, 175, 17, 155, 108, 36, 207, 212, 75, 238, 112, 75, 177]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [122, 127, 230, 234, 20, 88, 54, 132, 38, 4, 241, 103, 237, 27, 91, 231, 123, 166, 255, 110, 210, 175, 85, 2, 174, 249, 69, 66, 249, 6, 108, 229]), terminal := { root0Digest := (bytes [112, 237, 148, 129, 8, 187, 27, 103, 196, 62, 229, 65, 80, 123, 21, 108, 248, 197, 118, 80, 87, 178, 35, 86, 12, 75, 11, 46, 200, 11, 70, 74]), executionDigest := (bytes [74, 202, 66, 25, 106, 38, 91, 108, 83, 143, 56, 156, 203, 227, 101, 222, 4, 137, 150, 5, 195, 49, 240, 232, 104, 115, 55, 93, 227, 232, 236, 253]), finalStateDigest := (bytes [182, 31, 54, 213, 113, 159, 201, 136, 65, 181, 111, 174, 113, 197, 150, 29, 93, 126, 40, 13, 253, 225, 7, 190, 200, 101, 176, 45, 199, 60, 8, 160]), transcriptFinalDigest := (bytes [12, 192, 210, 153, 196, 189, 212, 22, 158, 203, 243, 19, 37, 237, 245, 141, 129, 40, 74, 48, 7, 211, 157, 135, 182, 198, 7, 50, 149, 140, 10, 64]), finalPc := 36, halted := true, digest := (bytes [59, 206, 20, 120, 239, 34, 156, 60, 113, 110, 27, 56, 27, 222, 197, 46, 134, 197, 77, 158, 110, 53, 49, 132, 134, 25, 149, 40, 174, 95, 59, 78]) }, digest := (bytes [46, 240, 34, 221, 181, 172, 209, 111, 193, 202, 64, 215, 26, 155, 138, 202, 36, 175, 37, 190, 17, 114, 7, 75, 93, 156, 128, 164, 23, 215, 96, 0]) }, statementDigest := (bytes [152, 165, 76, 254, 110, 85, 173, 45, 214, 249, 70, 188, 231, 198, 153, 212, 137, 1, 186, 150, 51, 237, 64, 178, 188, 81, 59, 229, 18, 51, 160, 242]), proofDigest := (bytes [216, 172, 107, 144, 190, 133, 113, 64, 238, 150, 20, 80, 179, 148, 46, 55, 164, 6, 83, 167, 119, 78, 41, 241, 52, 165, 202, 63, 222, 113, 191, 255]), digest := (bytes [1, 238, 175, 142, 127, 18, 11, 182, 150, 173, 181, 78, 116, 153, 144, 183, 131, 4, 46, 229, 90, 216, 194, 199, 25, 1, 229, 38, 74, 22, 155, 152]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [62, 154, 7, 200, 147, 245, 58, 185, 116, 64, 224, 46, 160, 35, 75, 87, 202, 13, 0, 146, 57, 39, 202, 76, 37, 197, 28, 178, 16, 93, 198, 238]), layoutVersion := 1, digest := (bytes [72, 20, 132, 106, 165, 238, 87, 32, 230, 222, 113, 145, 147, 49, 100, 223, 93, 208, 51, 219, 74, 178, 167, 73, 24, 194, 222, 170, 30, 92, 62, 246]) }, rowWidth := 38, timeLen := 29, columnDigests := [(bytes [225, 144, 71, 219, 98, 150, 176, 137, 117, 152, 218, 12, 231, 77, 180, 251, 202, 38, 51, 2, 145, 159, 54, 17, 197, 124, 89, 195, 83, 238, 136, 81]), (bytes [146, 158, 140, 155, 179, 185, 149, 183, 251, 209, 198, 147, 38, 37, 140, 69, 160, 9, 216, 55, 192, 190, 59, 26, 216, 217, 62, 24, 127, 85, 137, 142]), (bytes [142, 34, 112, 18, 173, 54, 6, 140, 104, 236, 245, 165, 32, 207, 224, 204, 82, 82, 62, 69, 74, 161, 107, 70, 38, 3, 105, 29, 53, 149, 156, 128]), (bytes [177, 65, 50, 144, 245, 110, 233, 171, 232, 225, 119, 68, 4, 55, 249, 173, 251, 72, 195, 139, 226, 128, 143, 115, 199, 221, 154, 3, 72, 2, 83, 115]), (bytes [187, 110, 30, 154, 212, 74, 138, 163, 178, 1, 214, 45, 7, 177, 164, 84, 240, 36, 178, 64, 217, 239, 121, 230, 186, 117, 115, 88, 47, 101, 88, 247]), (bytes [169, 151, 16, 42, 183, 14, 65, 149, 6, 102, 30, 248, 238, 152, 25, 94, 198, 232, 194, 105, 153, 30, 91, 175, 34, 125, 241, 252, 15, 216, 76, 157]), (bytes [69, 222, 94, 63, 123, 239, 52, 203, 118, 204, 96, 88, 131, 44, 220, 53, 199, 109, 252, 221, 217, 182, 189, 85, 59, 232, 124, 251, 182, 226, 86, 249]), (bytes [158, 79, 224, 220, 254, 240, 26, 24, 34, 166, 48, 240, 165, 20, 200, 161, 31, 138, 115, 24, 228, 82, 220, 226, 70, 171, 225, 32, 38, 171, 101, 148]), (bytes [247, 133, 122, 61, 3, 181, 179, 2, 78, 121, 199, 99, 188, 155, 129, 167, 43, 7, 104, 123, 237, 51, 187, 22, 241, 150, 190, 38, 197, 98, 2, 20]), (bytes [233, 241, 59, 183, 115, 16, 155, 112, 147, 254, 37, 9, 198, 213, 255, 240, 142, 160, 77, 159, 152, 40, 123, 72, 163, 100, 215, 222, 18, 213, 248, 209]), (bytes [25, 189, 217, 85, 137, 71, 57, 168, 127, 18, 14, 178, 71, 101, 16, 248, 186, 217, 126, 171, 0, 120, 231, 48, 103, 99, 103, 74, 172, 118, 225, 1]), (bytes [251, 57, 85, 182, 134, 20, 27, 50, 49, 220, 118, 202, 190, 3, 143, 75, 130, 31, 127, 91, 71, 143, 150, 228, 39, 35, 60, 29, 131, 71, 39, 0]), (bytes [133, 122, 33, 147, 47, 160, 190, 209, 160, 150, 0, 77, 38, 48, 162, 196, 160, 164, 2, 129, 207, 137, 136, 250, 155, 128, 120, 36, 81, 44, 253, 222]), (bytes [40, 128, 59, 105, 74, 174, 48, 74, 184, 54, 190, 56, 96, 87, 192, 47, 253, 241, 23, 15, 124, 138, 14, 203, 251, 156, 155, 174, 116, 135, 47, 72]), (bytes [53, 244, 115, 22, 63, 240, 250, 109, 33, 19, 55, 63, 40, 28, 3, 202, 100, 147, 84, 59, 5, 95, 249, 90, 190, 191, 37, 62, 163, 169, 52, 189]), (bytes [131, 250, 236, 20, 8, 99, 18, 117, 217, 85, 133, 126, 4, 189, 51, 39, 25, 47, 47, 41, 93, 172, 80, 115, 27, 45, 128, 252, 31, 5, 206, 195]), (bytes [89, 61, 248, 224, 67, 160, 200, 219, 241, 254, 16, 244, 90, 48, 115, 25, 130, 84, 52, 147, 39, 142, 246, 176, 80, 152, 132, 95, 200, 49, 201, 248]), (bytes [34, 68, 71, 45, 18, 40, 1, 102, 204, 90, 252, 15, 188, 232, 150, 239, 238, 10, 156, 192, 2, 238, 172, 50, 238, 60, 78, 29, 84, 74, 152, 177]), (bytes [159, 44, 169, 53, 34, 215, 40, 87, 157, 79, 201, 156, 129, 131, 163, 240, 166, 165, 47, 251, 235, 27, 218, 15, 52, 43, 205, 37, 72, 232, 255, 240]), (bytes [101, 185, 21, 255, 183, 119, 49, 133, 193, 6, 195, 53, 13, 64, 166, 139, 241, 113, 47, 248, 95, 119, 234, 106, 233, 40, 164, 167, 223, 251, 49, 164]), (bytes [168, 134, 175, 127, 124, 235, 234, 224, 126, 84, 90, 179, 59, 107, 156, 102, 170, 123, 197, 54, 201, 107, 166, 55, 133, 242, 61, 198, 177, 28, 199, 166]), (bytes [131, 99, 176, 212, 241, 178, 229, 254, 243, 185, 144, 61, 54, 128, 21, 148, 105, 32, 116, 244, 80, 109, 39, 120, 94, 146, 185, 122, 98, 38, 125, 96]), (bytes [166, 137, 73, 4, 167, 238, 68, 129, 29, 111, 251, 56, 90, 45, 113, 96, 158, 150, 92, 141, 233, 178, 47, 207, 193, 232, 115, 123, 239, 109, 225, 81]), (bytes [109, 228, 106, 126, 1, 154, 101, 178, 99, 186, 169, 23, 190, 246, 6, 119, 133, 155, 169, 224, 104, 241, 168, 246, 26, 9, 245, 243, 159, 43, 193, 40]), (bytes [84, 71, 236, 195, 91, 244, 24, 129, 137, 205, 211, 129, 8, 108, 110, 4, 32, 103, 214, 34, 178, 142, 210, 138, 208, 159, 59, 233, 67, 117, 61, 177]), (bytes [215, 155, 157, 52, 106, 37, 10, 21, 143, 252, 226, 76, 12, 127, 111, 32, 62, 181, 75, 2, 72, 157, 245, 86, 27, 193, 119, 139, 213, 205, 211, 216]), (bytes [176, 156, 235, 147, 154, 227, 33, 241, 138, 17, 161, 227, 206, 89, 144, 172, 187, 187, 144, 2, 142, 67, 14, 164, 107, 205, 212, 89, 28, 207, 3, 12]), (bytes [124, 225, 65, 157, 149, 211, 123, 1, 114, 195, 64, 64, 70, 84, 85, 216, 233, 231, 253, 168, 237, 186, 106, 149, 149, 180, 108, 164, 197, 230, 255, 37]), (bytes [189, 65, 69, 91, 107, 106, 95, 158, 138, 149, 69, 103, 187, 116, 129, 248, 236, 235, 178, 249, 158, 57, 202, 59, 246, 51, 68, 78, 45, 103, 141, 148]), (bytes [60, 7, 219, 141, 178, 20, 175, 53, 193, 27, 181, 210, 212, 131, 112, 160, 200, 211, 210, 155, 50, 165, 51, 57, 58, 245, 219, 216, 32, 119, 115, 81]), (bytes [0, 241, 216, 6, 85, 233, 44, 163, 138, 25, 159, 156, 224, 140, 134, 57, 72, 140, 223, 209, 59, 9, 192, 229, 14, 251, 82, 157, 172, 21, 47, 73]), (bytes [220, 105, 109, 147, 191, 51, 134, 2, 29, 157, 72, 171, 79, 94, 51, 12, 175, 162, 154, 108, 2, 147, 247, 135, 227, 131, 107, 210, 127, 72, 20, 193]), (bytes [244, 155, 95, 10, 221, 240, 103, 187, 35, 194, 33, 54, 48, 100, 87, 121, 218, 115, 120, 167, 175, 123, 202, 115, 67, 230, 88, 80, 237, 214, 35, 19]), (bytes [76, 183, 241, 70, 105, 220, 125, 240, 46, 244, 80, 170, 139, 218, 70, 76, 38, 121, 105, 137, 50, 252, 43, 36, 186, 13, 80, 147, 251, 223, 13, 176]), (bytes [25, 109, 229, 191, 89, 237, 100, 249, 118, 122, 177, 62, 97, 27, 178, 71, 199, 215, 79, 119, 156, 97, 6, 148, 83, 95, 44, 254, 206, 210, 162, 180]), (bytes [154, 210, 102, 237, 124, 137, 226, 136, 9, 149, 91, 159, 118, 88, 107, 15, 229, 106, 238, 129, 85, 65, 104, 111, 8, 252, 131, 2, 196, 196, 82, 17]), (bytes [99, 160, 92, 133, 199, 2, 200, 7, 232, 31, 183, 118, 192, 5, 209, 191, 18, 76, 91, 162, 17, 123, 81, 154, 193, 172, 240, 228, 196, 150, 59, 119]), (bytes [255, 151, 239, 15, 190, 208, 229, 150, 31, 114, 213, 241, 235, 219, 84, 51, 158, 153, 120, 86, 41, 221, 168, 180, 76, 247, 19, 170, 58, 37, 126, 249])], familyDigest := (bytes [62, 154, 7, 200, 147, 245, 58, 185, 116, 64, 224, 46, 160, 35, 75, 87, 202, 13, 0, 146, 57, 39, 202, 76, 37, 197, 28, 178, 16, 93, 198, 238]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [62, 154, 7, 200, 147, 245, 58, 185, 116, 64, 224, 46, 160, 35, 75, 87, 202, 13, 0, 146, 57, 39, 202, 76, 37, 197, 28, 178, 16, 93, 198, 238]), layoutVersion := 1, digest := (bytes [72, 20, 132, 106, 165, 238, 87, 32, 230, 222, 113, 145, 147, 49, 100, 223, 93, 208, 51, 219, 74, 178, 167, 73, 24, 194, 222, 170, 30, 92, 62, 246]) }, logicalIndex := 0, digest := (bytes [157, 243, 0, 60, 241, 246, 254, 190, 204, 2, 60, 216, 77, 95, 223, 233, 200, 143, 150, 107, 143, 60, 45, 118, 175, 106, 167, 10, 36, 24, 167, 77]) }, valueDigest := (bytes [15, 203, 82, 147, 182, 107, 150, 168, 159, 107, 204, 115, 170, 200, 12, 67, 125, 81, 225, 219, 175, 26, 58, 39, 55, 35, 134, 130, 62, 126, 3, 37]), digest := (bytes [45, 161, 238, 241, 198, 238, 221, 31, 180, 58, 220, 162, 22, 61, 238, 251, 249, 195, 29, 205, 227, 246, 79, 201, 151, 86, 233, 105, 224, 236, 143, 125]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [62, 154, 7, 200, 147, 245, 58, 185, 116, 64, 224, 46, 160, 35, 75, 87, 202, 13, 0, 146, 57, 39, 202, 76, 37, 197, 28, 178, 16, 93, 198, 238]), layoutVersion := 1, digest := (bytes [72, 20, 132, 106, 165, 238, 87, 32, 230, 222, 113, 145, 147, 49, 100, 223, 93, 208, 51, 219, 74, 178, 167, 73, 24, 194, 222, 170, 30, 92, 62, 246]) }, logicalIndex := 28, digest := (bytes [233, 62, 123, 247, 47, 66, 12, 137, 97, 219, 154, 120, 8, 135, 37, 192, 34, 157, 217, 24, 146, 73, 251, 131, 32, 163, 221, 254, 78, 216, 51, 34]) }, valueDigest := (bytes [191, 59, 111, 91, 175, 174, 193, 106, 252, 237, 179, 109, 105, 90, 100, 212, 35, 239, 230, 162, 83, 17, 88, 13, 240, 150, 187, 164, 56, 114, 73, 39]), digest := (bytes [180, 81, 197, 89, 123, 21, 57, 248, 239, 158, 190, 71, 240, 70, 71, 207, 10, 185, 191, 205, 239, 154, 252, 215, 220, 242, 31, 7, 28, 106, 157, 137]) }), digest := (bytes [38, 137, 143, 183, 203, 147, 94, 154, 15, 226, 51, 246, 88, 62, 137, 224, 176, 66, 88, 191, 172, 42, 75, 9, 199, 148, 179, 224, 80, 184, 102, 237]) }
  , rootLaneCommitment := { timeLen := 29, commitments := { commitmentCount := 38, digest := (bytes [2, 195, 15, 176, 74, 156, 14, 145, 205, 30, 105, 114, 34, 141, 242, 217, 105, 100, 117, 46, 249, 188, 28, 111, 72, 195, 48, 19, 21, 39, 77, 21]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [2, 195, 15, 176, 74, 156, 14, 145, 205, 30, 105, 114, 34, 141, 242, 217, 105, 100, 117, 46, 249, 188, 28, 111, 72, 195, 48, 19, 21, 39, 77, 21]), layoutVersion := 3, digest := (bytes [107, 210, 58, 64, 103, 214, 200, 23, 157, 252, 53, 151, 94, 117, 179, 18, 97, 24, 125, 232, 65, 255, 83, 37, 252, 49, 227, 196, 7, 172, 22, 254]) }, logicalIndex := 0, digest := (bytes [132, 75, 176, 50, 98, 124, 10, 163, 65, 72, 164, 172, 236, 29, 57, 36, 144, 74, 213, 185, 85, 221, 229, 157, 190, 66, 127, 60, 109, 248, 105, 36]) }, valueDigest := (bytes [15, 203, 82, 147, 182, 107, 150, 168, 159, 107, 204, 115, 170, 200, 12, 67, 125, 81, 225, 219, 175, 26, 58, 39, 55, 35, 134, 130, 62, 126, 3, 37]), digest := (bytes [143, 201, 227, 113, 227, 52, 190, 147, 201, 197, 250, 34, 101, 210, 119, 246, 66, 86, 0, 57, 190, 96, 107, 156, 186, 34, 219, 71, 26, 85, 5, 244]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [2, 195, 15, 176, 74, 156, 14, 145, 205, 30, 105, 114, 34, 141, 242, 217, 105, 100, 117, 46, 249, 188, 28, 111, 72, 195, 48, 19, 21, 39, 77, 21]), layoutVersion := 3, digest := (bytes [107, 210, 58, 64, 103, 214, 200, 23, 157, 252, 53, 151, 94, 117, 179, 18, 97, 24, 125, 232, 65, 255, 83, 37, 252, 49, 227, 196, 7, 172, 22, 254]) }, logicalIndex := 28, digest := (bytes [228, 49, 68, 70, 171, 104, 219, 143, 14, 198, 244, 25, 53, 98, 211, 75, 148, 14, 190, 247, 181, 218, 158, 239, 149, 181, 105, 155, 187, 206, 1, 129]) }, valueDigest := (bytes [191, 59, 111, 91, 175, 174, 193, 106, 252, 237, 179, 109, 105, 90, 100, 212, 35, 239, 230, 162, 83, 17, 88, 13, 240, 150, 187, 164, 56, 114, 73, 39]), digest := (bytes [0, 246, 160, 121, 86, 247, 118, 202, 26, 120, 220, 155, 194, 122, 193, 229, 214, 70, 4, 38, 18, 243, 44, 123, 80, 244, 64, 114, 215, 121, 214, 30]) }), digest := (bytes [150, 62, 140, 172, 232, 178, 145, 115, 116, 114, 88, 213, 56, 166, 39, 55, 80, 244, 202, 250, 116, 153, 16, 155, 166, 156, 246, 97, 75, 108, 0, 65]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [38, 137, 143, 183, 203, 147, 94, 154, 15, 226, 51, 246, 88, 62, 137, 224, 176, 66, 88, 191, 172, 42, 75, 9, 199, 148, 179, 224, 80, 184, 102, 237]), rootLaneCommitmentDigest := (bytes [150, 62, 140, 172, 232, 178, 145, 115, 116, 114, 88, 213, 56, 166, 39, 55, 80, 244, 202, 250, 116, 153, 16, 155, 166, 156, 246, 97, 75, 108, 0, 65]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 29, digest := (bytes [211, 98, 237, 242, 215, 31, 14, 15, 184, 13, 191, 171, 253, 34, 21, 29, 65, 28, 97, 73, 72, 62, 243, 8, 57, 223, 199, 211, 62, 146, 193, 73]) }, statementDigest := (bytes [7, 54, 218, 74, 91, 87, 126, 77, 113, 29, 100, 248, 179, 47, 55, 221, 251, 156, 123, 73, 245, 179, 210, 212, 194, 170, 217, 229, 66, 118, 179, 0]), proofDigest := (bytes [227, 177, 167, 54, 118, 140, 153, 71, 128, 178, 68, 36, 4, 94, 19, 13, 124, 70, 73, 221, 181, 240, 4, 207, 23, 61, 79, 232, 254, 140, 120, 56]), digest := (bytes [0, 140, 31, 32, 123, 73, 34, 6, 104, 48, 110, 75, 192, 245, 251, 55, 159, 231, 142, 107, 171, 235, 15, 157, 150, 238, 207, 182, 36, 55, 202, 100]) }
  , digest := (bytes [236, 173, 150, 123, 212, 185, 6, 179, 2, 88, 193, 125, 198, 47, 99, 169, 201, 113, 124, 81, 200, 14, 52, 145, 93, 10, 22, 243, 17, 92, 156, 200])
}
    , transcript := {
  appLabel := (bytes [110, 101, 111, 46, 102, 111, 108, 100, 46, 110, 101, 120, 116, 47, 114, 118, 54, 52, 105, 109, 47, 112, 97, 114, 105, 116, 121, 95, 107, 101, 114, 110, 101, 108, 95, 118, 49])
  , events := [{
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 116, 114, 97, 110, 115, 99, 114, 105, 112, 116, 95, 115, 101, 101, 100])
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 117, 110, 115, 105, 103, 110, 101, 100, 45, 100, 105, 118, 114, 101, 109, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [28554825547656548, 829828461, 9489343540124783034, 8764360071562206332, 3057429044872953003, 16976988586773791792, 11845825237008666244, 4664927791211211994], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [117, 110, 115, 105, 103, 110, 101, 100, 95, 100, 105, 118, 114, 101, 109, 95, 99, 104, 97, 105, 110, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [28554825547656548, 829828461, 9489343540124783034, 8764360071562206332, 3057429044872953003, 16976988586773791792, 11845825237008666244, 4664927791211211994], absorbed := 2 }
  , cursorAfter := { stateWords := [18175593511046709288, 6946588854182484443, 13843204130628353059, 17688189384403402368, 17000273702055328877, 1954126954125802051, 3973770870684416971, 6046732314966795874], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [35705523, 35713843, 37868475, 37876795, 44357043, 44365363, 48682939, 48691259, 115]
  , cursorBefore := { stateWords := [18175593511046709288, 6946588854182484443, 13843204130628353059, 17688189384403402368, 17000273702055328877, 1954126954125802051, 3973770870684416971, 6046732314966795874], absorbed := 0 }
  , cursorAfter := { stateWords := [294604563585449092, 3995859309777676657, 1826205592368470438, 17148638130241902376, 4410555781729330190, 4540423293514818421, 7986033658079626101, 14913088229562338250], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 20, 6, 18446744073709551615, 3, 0, 0, 0, 0, 9, 0, 0, 0, 18446744071562067969, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [294604563585449092, 3995859309777676657, 1826205592368470438, 17148638130241902376, 4410555781729330190, 4540423293514818421, 7986033658079626101, 14913088229562338250], absorbed := 0 }
  , cursorAfter := { stateWords := [0, 0, 18338580670858670552, 13303765742222026440, 18227812615345073622, 16789938747818192746, 7660224135226390384, 12066798474568919220], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [0, 0, 18338580670858670552, 13303765742222026440, 18227812615345073622, 16789938747818192746, 7660224135226390384, 12066798474568919220], absorbed := 2 }
  , cursorAfter := { stateWords := [13348506805888363, 30506403037277801, 34184295084289375, 0, 16626093163639875086, 853605333882032129, 4049040664230904676, 9140411641582566077], absorbed := 4 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [112, 237, 148, 129, 8, 187, 27, 103, 196, 62, 229, 65, 80, 123, 21, 108, 248, 197, 118, 80, 87, 178, 35, 86, 12, 75, 11, 46, 200, 11, 70, 74])
  , u64s := []
  , cursorBefore := { stateWords := [13348506805888363, 30506403037277801, 34184295084289375, 0, 16626093163639875086, 853605333882032129, 4049040664230904676, 9140411641582566077], absorbed := 4 }
  , cursorAfter := { stateWords := [24576794031582229, 12960265886114738, 1246104520, 1891803635427246789, 13176233635853993198, 13067209805577138283, 7890629802312393150, 3028786327060893511], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [24576794031582229, 12960265886114738, 1246104520, 1891803635427246789, 13176233635853993198, 13067209805577138283, 7890629802312393150, 3028786327060893511], absorbed := 3 }
  , cursorAfter := { stateWords := [2114760318709056228, 7332565857313712330, 8719415735850429070, 8736709448451869642, 14683097368001922279, 13215671756815992144, 9886648886077009744, 5086976942534876258], absorbed := 0 }
  , challengeOutput := (some 2114760318709056228)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [194, 252, 99, 144, 188, 159, 214, 228, 231, 171, 68, 72, 228, 177, 15, 240, 107, 157, 37, 137, 34, 45, 224, 66, 91, 32, 164, 62, 84, 65, 17, 143])
  , u64s := []
  , cursorBefore := { stateWords := [2114760318709056228, 7332565857313712330, 8719415735850429070, 8736709448451869642, 14683097368001922279, 13215671756815992144, 9886648886077009744, 5086976942534876258], absorbed := 0 }
  , cursorAfter := { stateWords := [9720943856054287, 17631907433078829, 2400272724, 16568033319234264143, 11246549393723949337, 3886138295018278798, 15764416691444559047, 16637667278800296938], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [9720943856054287, 17631907433078829, 2400272724, 16568033319234264143, 11246549393723949337, 3886138295018278798, 15764416691444559047, 16637667278800296938], absorbed := 3 }
  , cursorAfter := { stateWords := [9623998399562321865, 4105603081408161910, 4751007992593884961, 18288276714983694149, 3319719550033343846, 1990847649040725373, 10861070053045217384, 142079268111627146], absorbed := 0 }
  , challengeOutput := (some 9623998399562321865)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [9623998399562321865, 4105603081408161910, 4751007992593884961, 18288276714983694149, 3319719550033343846, 1990847649040725373, 10861070053045217384, 142079268111627146], absorbed := 0 }
  , cursorAfter := { stateWords := [8802110342888801535, 5419848404505140344, 13239104648930224864, 12402328666011142850, 6161298538837734102, 1146713592379336030, 5355403749465642584, 9487351222646020794], absorbed := 0 }
  , challengeOutput := (some 8802110342888801535)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [195, 56, 19, 82, 10, 216, 77, 152, 169, 234, 25, 78, 251, 192, 104, 239, 137, 52, 112, 2, 63, 204, 59, 153, 50, 225, 142, 65, 73, 170, 42, 196])
  , u64s := []
  , cursorBefore := { stateWords := [8802110342888801535, 5419848404505140344, 13239104648930224864, 12402328666011142850, 6161298538837734102, 1146713592379336030, 5355403749465642584, 9487351222646020794], absorbed := 0 }
  , cursorAfter := { stateWords := [17735604473818984, 18452971353881548, 3291130441, 3616115055102231937, 14052811418320705276, 5649898703827695104, 12196512873867634186, 8459611689393984612], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [17735604473818984, 18452971353881548, 3291130441, 3616115055102231937, 14052811418320705276, 5649898703827695104, 12196512873867634186, 8459611689393984612], absorbed := 3 }
  , cursorAfter := { stateWords := [548968070038829395, 16240021376208380512, 4336986931399666685, 17063588956229792450, 18373717032598611015, 7454368206699925205, 6915979662246002859, 14067174015319125265], absorbed := 0 }
  , challengeOutput := (some 548968070038829395)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [80, 77, 243, 233, 190, 184, 52, 23, 82, 127, 172, 195, 183, 255, 127, 86, 245, 226, 157, 206, 2, 214, 47, 191, 184, 177, 70, 30, 242, 179, 62, 115])
  , u64s := []
  , cursorBefore := { stateWords := [548968070038829395, 16240021376208380512, 4336986931399666685, 17063588956229792450, 18373717032598611015, 7454368206699925205, 6915979662246002859, 14067174015319125265], absorbed := 0 }
  , cursorAfter := { stateWords := [790127466337919, 8521978424012758, 1933489138, 14118226142409643476, 5636626556418141687, 5146204121686868138, 5813425710226704663, 3432237320070440371], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [74, 202, 66, 25, 106, 38, 91, 108, 83, 143, 56, 156, 203, 227, 101, 222, 4, 137, 150, 5, 195, 49, 240, 232, 104, 115, 55, 93, 227, 232, 236, 253])
  , u64s := []
  , cursorBefore := { stateWords := [790127466337919, 8521978424012758, 1933489138, 14118226142409643476, 5636626556418141687, 5146204121686868138, 5813425710226704663, 3432237320070440371], absorbed := 3 }
  , cursorAfter := { stateWords := [54893764560608869, 26238141654954033, 4260161763, 4029004789297720123, 4207896458049662805, 5487101462387058563, 5798831122825369606, 9810116389510024144], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [182, 31, 54, 213, 113, 159, 201, 136, 65, 181, 111, 174, 113, 197, 150, 29, 93, 126, 40, 13, 253, 225, 7, 190, 200, 101, 176, 45, 199, 60, 8, 160])
  , u64s := []
  , cursorBefore := { stateWords := [54893764560608869, 26238141654954033, 4260161763, 4029004789297720123, 4207896458049662805, 5487101462387058563, 5798831122825369606, 9810116389510024144], absorbed := 3 }
  , cursorAfter := { stateWords := [71227636677680534, 12860325158062049, 2684894407, 10517842318081291684, 707559344843132510, 9304322026659064738, 2313881270804506576, 5033264401807177475], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [71227636677680534, 12860325158062049, 2684894407, 10517842318081291684, 707559344843132510, 9304322026659064738, 2313881270804506576, 5033264401807177475], absorbed := 3 }
  , cursorAfter := { stateWords := [16824818285799363036, 14516401473560369504, 6781304114410902302, 432764352883285124, 5961912157393274262, 11835148470266970466, 12238340288431517965, 2899380087059870968], absorbed := 0 }
  , challengeOutput := (some 16824818285799363036)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [16824818285799363036, 14516401473560369504, 6781304114410902302, 432764352883285124, 5961912157393274262, 11835148470266970466, 12238340288431517965, 2899380087059870968], absorbed := 0 }
  , cursorAfter := { stateWords := [1645148415989039116, 10229342872146267038, 9772198794292242561, 4614655340611880630, 8148963032799206072, 4667036217784725552, 8481883072410979, 10681842667011045012], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [12, 192, 210, 153, 196, 189, 212, 22, 158, 203, 243, 19, 37, 237, 245, 141, 129, 40, 74, 48, 7, 211, 157, 135, 182, 198, 7, 50, 149, 140, 10, 64]))
}]
}
    , stage1 := stage1
    , stage2 := stage2
    , stage3 := stage3
    , rootExecution := rootExecution
    , stepComposition := stepComposition
    , soundnessAccounting := soundnessAccounting
    , kernelOpeningBundle := kernelOpeningBundle
    , digest := (bytes [196, 88, 230, 122, 34, 133, 90, 19, 107, 224, 47, 14, 239, 187, 3, 237, 11, 159, 65, 204, 126, 93, 67, 47, 93, 164, 55, 176, 221, 167, 124, 212])
  }

end Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors.Case_unsigned_divrem_chain_ecall
