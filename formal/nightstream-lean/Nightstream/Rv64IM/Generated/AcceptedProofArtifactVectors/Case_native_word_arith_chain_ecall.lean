import Nightstream.Rv64IM.Generated.AcceptedProofArtifactTypes

set_option maxHeartbeats 0
set_option maxRecDepth 65536

namespace Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors.Case_native_word_arith_chain_ecall

open Nightstream.Rv64IM.Generated

def stage1SemInputs : List SemInView :=
  [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, pc := 0, opcode := .addiw, traceOpcode := (some .addiw), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 1, archRdBefore := 0, archImm := -1, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 1, rdBefore := 0, rdAfter := 18446744073709551615, imm := -1, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, pc := 4, opcode := .addiw, traceOpcode := (some .addiw), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 1, archRs1Value := 18446744073709551615, archRs2 := 0, archRs2Value := 0, archRd := 2, archRdBefore := 0, archImm := 2, rs1 := 1, rs1Value := 18446744073709551615, rs2 := 0, rs2Value := 0, rd := 2, rdBefore := 0, rdAfter := 1, imm := 2, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, pc := 8, opcode := .addw, traceOpcode := (some .addw), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 3, archRs1Value := 2147483647, archRs2 := 4, archRs2Value := 2, archRd := 7, archRdBefore := 0, archImm := 0, rs1 := 3, rs1Value := 2147483647, rs2 := 4, rs2Value := 2, rd := 7, rdBefore := 0, rdAfter := 18446744071562067969, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, pc := 12, opcode := .subw, traceOpcode := (some .subw), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 5, archRs1Value := 0, archRs2 := 6, archRs2Value := 1, archRd := 8, archRdBefore := 0, archImm := 0, rs1 := 5, rs1Value := 0, rs2 := 6, rs2Value := 1, rd := 8, rdBefore := 0, rdAfter := 18446744073709551615, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 4, stepIndex := 4, sequenceIndex := 0, pc := 16, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 0, archRdBefore := 0, archImm := 0, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 0, rdBefore := 0, rdAfter := 0, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := false, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }]

def stage1RowBindings : List Stage1RowBindingView :=
  [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 4293918875, opcode := .addiw, traceOpcode := (some .addiw), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 4, aluResult := 18446744073709551615, effectiveAddr := none, writesRd := true, rd := 1, rdAfter := 18446744073709551615, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 2130203, opcode := .addiw, traceOpcode := (some .addiw), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 8, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 2, rdAfter := 1, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 4293563, opcode := .addw, traceOpcode := (some .addw), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 12, aluResult := 18446744071562067969, effectiveAddr := none, writesRd := true, rd := 7, rdAfter := 18446744071562067969, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 12, fetchedWord := 1080198203, opcode := .subw, traceOpcode := (some .subw), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 16, aluResult := 18446744073709551615, effectiveAddr := none, writesRd := true, rd := 8, rdAfter := 18446744073709551615, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 4, stepIndex := 4, sequenceIndex := 0, fetchPc := 16, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 20, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }]

def stage1 : Stage1ProofBundleView :=
  {
    semInputs := stage1SemInputs
    , rowBindings := stage1RowBindings
    , bytecodeDigest := (bytes [213, 102, 155, 178, 126, 43, 197, 6, 188, 208, 65, 126, 29, 90, 109, 178, 161, 140, 15, 143, 145, 239, 161, 248, 133, 51, 37, 209, 231, 248, 109, 138])
    , aluDigest := (bytes [20, 221, 232, 145, 167, 22, 82, 245, 200, 181, 210, 111, 96, 162, 247, 118, 25, 44, 65, 75, 37, 88, 239, 143, 74, 106, 70, 18, 129, 40, 124, 255])
    , branchDigest := (bytes [148, 157, 127, 66, 178, 225, 8, 222, 148, 20, 240, 76, 203, 244, 71, 71, 213, 50, 242, 213, 29, 15, 207, 133, 183, 188, 146, 18, 169, 205, 89, 223])
    , semantics := { semInputsDigest := (bytes [130, 71, 38, 124, 62, 120, 12, 16, 107, 135, 18, 209, 198, 155, 234, 137, 56, 235, 35, 214, 43, 105, 88, 9, 15, 204, 151, 13, 28, 69, 83, 105]), rowBindingsDigest := (bytes [188, 101, 165, 154, 116, 34, 74, 26, 190, 106, 211, 181, 83, 72, 96, 176, 93, 62, 45, 20, 100, 70, 151, 131, 26, 150, 136, 183, 12, 109, 134, 108]), sequenceCount := 5, helperRowCount := 0, digest := (bytes [191, 60, 207, 142, 2, 114, 190, 38, 5, 135, 231, 36, 81, 254, 207, 62, 128, 198, 42, 239, 139, 52, 222, 11, 198, 252, 153, 6, 86, 191, 88, 129]) }
    , addressCorrectnessDigest := (bytes [78, 218, 73, 152, 165, 166, 173, 91, 25, 110, 221, 227, 243, 161, 191, 87, 132, 227, 159, 244, 183, 7, 230, 202, 45, 203, 79, 84, 59, 83, 30, 87])
    , linkageDigest := (bytes [169, 102, 69, 230, 104, 138, 229, 249, 58, 98, 118, 102, 19, 62, 135, 115, 37, 40, 241, 171, 91, 54, 40, 252, 222, 92, 148, 100, 44, 149, 83, 88])
    , selectedOpening := { claim := { rowsFamilyDigest := (bytes [188, 101, 165, 154, 116, 34, 74, 26, 190, 106, 211, 181, 83, 72, 96, 176, 93, 62, 45, 20, 100, 70, 151, 131, 26, 150, 136, 183, 12, 109, 134, 108]), rowCount := 5, effectRowCount := 5, commitRowCount := 5, realRowCount := 5, preservesX0Count := 1, firstTraceIndex := 0, effectTraceIndex := 0, commitTraceIndex := 0, lastTraceIndex := 4, mix := 10558873659545640745, points := { first := { id := { object := { familyTag := 1, commitmentDigest := (bytes [188, 101, 165, 154, 116, 34, 74, 26, 190, 106, 211, 181, 83, 72, 96, 176, 93, 62, 45, 20, 100, 70, 151, 131, 26, 150, 136, 183, 12, 109, 134, 108]), layoutVersion := 1, digest := (bytes [127, 160, 237, 62, 224, 185, 148, 137, 47, 194, 106, 165, 59, 72, 205, 240, 153, 209, 106, 250, 186, 118, 4, 112, 138, 169, 137, 22, 243, 143, 121, 110]) }, logicalIndex := 0, digest := (bytes [175, 156, 171, 141, 50, 193, 116, 187, 162, 171, 173, 14, 130, 55, 16, 121, 129, 89, 10, 193, 7, 39, 5, 23, 103, 110, 195, 252, 160, 185, 190, 50]) }, valueDigest := (bytes [88, 46, 229, 34, 125, 248, 73, 145, 132, 101, 35, 117, 241, 79, 15, 46, 214, 71, 161, 62, 237, 167, 69, 110, 126, 164, 10, 231, 163, 188, 24, 245]), digest := (bytes [116, 154, 199, 110, 192, 45, 243, 12, 87, 144, 33, 13, 121, 170, 250, 166, 48, 190, 127, 21, 190, 120, 239, 78, 96, 106, 243, 134, 95, 11, 251, 195]) }, effect := { id := { object := { familyTag := 1, commitmentDigest := (bytes [188, 101, 165, 154, 116, 34, 74, 26, 190, 106, 211, 181, 83, 72, 96, 176, 93, 62, 45, 20, 100, 70, 151, 131, 26, 150, 136, 183, 12, 109, 134, 108]), layoutVersion := 1, digest := (bytes [127, 160, 237, 62, 224, 185, 148, 137, 47, 194, 106, 165, 59, 72, 205, 240, 153, 209, 106, 250, 186, 118, 4, 112, 138, 169, 137, 22, 243, 143, 121, 110]) }, logicalIndex := 0, digest := (bytes [175, 156, 171, 141, 50, 193, 116, 187, 162, 171, 173, 14, 130, 55, 16, 121, 129, 89, 10, 193, 7, 39, 5, 23, 103, 110, 195, 252, 160, 185, 190, 50]) }, valueDigest := (bytes [88, 46, 229, 34, 125, 248, 73, 145, 132, 101, 35, 117, 241, 79, 15, 46, 214, 71, 161, 62, 237, 167, 69, 110, 126, 164, 10, 231, 163, 188, 24, 245]), digest := (bytes [116, 154, 199, 110, 192, 45, 243, 12, 87, 144, 33, 13, 121, 170, 250, 166, 48, 190, 127, 21, 190, 120, 239, 78, 96, 106, 243, 134, 95, 11, 251, 195]) }, commit := { id := { object := { familyTag := 1, commitmentDigest := (bytes [188, 101, 165, 154, 116, 34, 74, 26, 190, 106, 211, 181, 83, 72, 96, 176, 93, 62, 45, 20, 100, 70, 151, 131, 26, 150, 136, 183, 12, 109, 134, 108]), layoutVersion := 1, digest := (bytes [127, 160, 237, 62, 224, 185, 148, 137, 47, 194, 106, 165, 59, 72, 205, 240, 153, 209, 106, 250, 186, 118, 4, 112, 138, 169, 137, 22, 243, 143, 121, 110]) }, logicalIndex := 0, digest := (bytes [175, 156, 171, 141, 50, 193, 116, 187, 162, 171, 173, 14, 130, 55, 16, 121, 129, 89, 10, 193, 7, 39, 5, 23, 103, 110, 195, 252, 160, 185, 190, 50]) }, valueDigest := (bytes [88, 46, 229, 34, 125, 248, 73, 145, 132, 101, 35, 117, 241, 79, 15, 46, 214, 71, 161, 62, 237, 167, 69, 110, 126, 164, 10, 231, 163, 188, 24, 245]), digest := (bytes [116, 154, 199, 110, 192, 45, 243, 12, 87, 144, 33, 13, 121, 170, 250, 166, 48, 190, 127, 21, 190, 120, 239, 78, 96, 106, 243, 134, 95, 11, 251, 195]) }, last := { id := { object := { familyTag := 1, commitmentDigest := (bytes [188, 101, 165, 154, 116, 34, 74, 26, 190, 106, 211, 181, 83, 72, 96, 176, 93, 62, 45, 20, 100, 70, 151, 131, 26, 150, 136, 183, 12, 109, 134, 108]), layoutVersion := 1, digest := (bytes [127, 160, 237, 62, 224, 185, 148, 137, 47, 194, 106, 165, 59, 72, 205, 240, 153, 209, 106, 250, 186, 118, 4, 112, 138, 169, 137, 22, 243, 143, 121, 110]) }, logicalIndex := 4, digest := (bytes [137, 246, 175, 131, 77, 85, 153, 111, 179, 18, 20, 210, 255, 172, 138, 174, 167, 190, 68, 225, 152, 120, 67, 9, 133, 103, 81, 34, 94, 243, 208, 151]) }, valueDigest := (bytes [80, 178, 26, 49, 69, 161, 230, 123, 68, 254, 88, 88, 229, 248, 207, 138, 245, 172, 71, 139, 39, 139, 170, 107, 237, 65, 83, 59, 93, 8, 204, 99]), digest := (bytes [70, 248, 186, 168, 208, 135, 176, 98, 121, 174, 239, 47, 61, 232, 59, 78, 201, 54, 96, 24, 73, 25, 29, 20, 39, 148, 85, 117, 110, 194, 112, 45]) } }, digest := (bytes [194, 249, 77, 49, 78, 97, 100, 220, 187, 247, 163, 99, 68, 144, 44, 29, 51, 136, 35, 182, 87, 108, 180, 236, 122, 169, 27, 61, 205, 16, 183, 238]) }, packaged := { statementDigest := (bytes [226, 110, 240, 92, 37, 26, 140, 200, 76, 184, 7, 227, 69, 29, 37, 20, 125, 53, 108, 130, 119, 202, 41, 138, 149, 233, 53, 111, 108, 196, 98, 71]), proofDigest := (bytes [89, 106, 143, 98, 171, 153, 115, 29, 70, 116, 32, 133, 151, 147, 206, 143, 213, 129, 208, 158, 175, 98, 69, 17, 130, 88, 62, 43, 248, 208, 204, 192]) }, digest := (bytes [173, 33, 149, 207, 246, 124, 144, 30, 221, 155, 50, 196, 200, 246, 153, 154, 92, 39, 21, 130, 0, 14, 85, 196, 68, 61, 42, 199, 208, 35, 228, 147]) }
    , digest := (bytes [111, 239, 163, 234, 255, 70, 207, 168, 71, 114, 211, 143, 177, 169, 208, 75, 8, 232, 248, 19, 156, 90, 100, 83, 22, 164, 175, 104, 80, 61, 82, 229])
  }

def stage2RegisterReads : List RegisterReadEventView :=
  [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 0, value := 0 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 1, value := 18446744073709551615 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 3, value := 2147483647 }, { traceIndex := 2, stepIndex := 2, role := .rs2, reg := 4, value := 2 }, { traceIndex := 3, stepIndex := 3, role := .rs1, reg := 5, value := 0 }, { traceIndex := 3, stepIndex := 3, role := .rs2, reg := 6, value := 1 }]

def stage2RegisterWrites : List RegisterWriteEventView :=
  [{ traceIndex := 0, stepIndex := 0, reg := 1, previous := 0, next := 18446744073709551615 }, { traceIndex := 1, stepIndex := 1, reg := 2, previous := 0, next := 1 }, { traceIndex := 2, stepIndex := 2, reg := 7, previous := 0, next := 18446744071562067969 }, { traceIndex := 3, stepIndex := 3, reg := 8, previous := 0, next := 18446744073709551615 }]

def stage2RamEvents : List RamEventView :=
  []

def stage2TwistLinks : List TwistLinkEventView :=
  [{ traceIndex := 0, stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 1, family := .nativeAlu, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 2, family := .nativeAlu, routedWriteValue := (some 18446744071562067969), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 3, family := .nativeAlu, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 4, stepIndex := 4, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]

def stage2 : Stage2ProofBundleView :=
  {
    registerReads := stage2RegisterReads
    , registerWrites := stage2RegisterWrites
    , ramEvents := stage2RamEvents
    , registerDigest := (bytes [189, 41, 190, 148, 182, 224, 15, 208, 55, 189, 3, 237, 222, 90, 17, 91, 187, 190, 41, 182, 204, 0, 103, 126, 53, 70, 177, 53, 97, 189, 116, 188])
    , ramDigest := (bytes [209, 217, 105, 43, 209, 229, 156, 61, 92, 164, 94, 232, 52, 214, 73, 229, 72, 188, 139, 122, 165, 123, 201, 212, 205, 15, 247, 197, 165, 154, 109, 246])
    , temporal := { twistLinks := stage2TwistLinks, registerTimelineDigest := (bytes [126, 173, 30, 200, 238, 155, 9, 233, 18, 55, 36, 218, 6, 236, 51, 185, 216, 30, 127, 44, 52, 12, 230, 207, 94, 36, 68, 61, 187, 57, 38, 124]), ramTimelineDigest := (bytes [8, 117, 17, 140, 128, 180, 240, 140, 250, 181, 90, 134, 147, 17, 197, 122, 220, 8, 66, 15, 193, 254, 11, 122, 115, 210, 233, 239, 55, 132, 31, 228]), twistLinksDigest := (bytes [160, 0, 165, 88, 11, 88, 57, 226, 47, 80, 11, 240, 191, 250, 114, 178, 246, 95, 57, 61, 104, 153, 74, 162, 189, 135, 172, 244, 198, 121, 126, 115]), digest := (bytes [144, 57, 60, 147, 57, 107, 146, 148, 125, 231, 133, 111, 183, 196, 186, 145, 128, 39, 219, 237, 85, 174, 166, 55, 110, 62, 232, 234, 234, 195, 168, 149]) }
    , semantics := { registerReadsFamilyDigest := (bytes [219, 52, 114, 13, 77, 176, 179, 74, 81, 67, 236, 239, 123, 202, 164, 132, 34, 97, 105, 225, 232, 38, 196, 98, 156, 26, 67, 203, 197, 23, 76, 242]), registerWritesFamilyDigest := (bytes [63, 201, 151, 43, 196, 117, 82, 173, 232, 83, 253, 174, 198, 202, 122, 222, 183, 183, 191, 212, 123, 131, 66, 128, 124, 186, 24, 168, 26, 178, 252, 156]), ramEventsFamilyDigest := (bytes [85, 17, 108, 38, 84, 5, 109, 213, 145, 137, 203, 96, 117, 127, 130, 193, 117, 29, 27, 219, 228, 58, 7, 214, 144, 155, 66, 38, 127, 8, 241, 95]), twistLinksFamilyDigest := (bytes [145, 7, 176, 110, 228, 30, 110, 174, 142, 253, 93, 219, 65, 126, 52, 120, 153, 172, 211, 89, 110, 204, 173, 110, 238, 194, 151, 95, 251, 102, 157, 215]), rowCount := 5, registerEventCount := 10, ramEventCount := 0, digest := (bytes [137, 195, 246, 219, 70, 227, 48, 210, 143, 8, 247, 98, 105, 43, 57, 87, 6, 131, 205, 96, 31, 122, 156, 175, 233, 81, 55, 55, 87, 13, 2, 122]) }
    , linkageDigest := (bytes [161, 76, 236, 71, 53, 53, 128, 186, 32, 204, 125, 27, 167, 247, 130, 183, 30, 126, 103, 234, 145, 107, 166, 160, 181, 209, 36, 14, 198, 12, 138, 209])
    , selectedOpening := { claim := { registerReadsFamilyDigest := (bytes [219, 52, 114, 13, 77, 176, 179, 74, 81, 67, 236, 239, 123, 202, 164, 132, 34, 97, 105, 225, 232, 38, 196, 98, 156, 26, 67, 203, 197, 23, 76, 242]), registerWritesFamilyDigest := (bytes [63, 201, 151, 43, 196, 117, 82, 173, 232, 83, 253, 174, 198, 202, 122, 222, 183, 183, 191, 212, 123, 131, 66, 128, 124, 186, 24, 168, 26, 178, 252, 156]), ramEventsFamilyDigest := (bytes [85, 17, 108, 38, 84, 5, 109, 213, 145, 137, 203, 96, 117, 127, 130, 193, 117, 29, 27, 219, 228, 58, 7, 214, 144, 155, 66, 38, 127, 8, 241, 95]), twistLinksFamilyDigest := (bytes [145, 7, 176, 110, 228, 30, 110, 174, 142, 253, 93, 219, 65, 126, 52, 120, 153, 172, 211, 89, 110, 204, 173, 110, 238, 194, 151, 95, 251, 102, 157, 215]), registerReadCount := 6, registerWriteCount := 4, ramEventCount := 0, twistLinkCount := 5, ramReadCount := 0, ramWriteCount := 0, regMix := 8944266866017282416, ramMix := 13660259816919425627, points := { firstRead := (some { id := { object := { familyTag := 2, commitmentDigest := (bytes [219, 52, 114, 13, 77, 176, 179, 74, 81, 67, 236, 239, 123, 202, 164, 132, 34, 97, 105, 225, 232, 38, 196, 98, 156, 26, 67, 203, 197, 23, 76, 242]), layoutVersion := 1, digest := (bytes [221, 226, 194, 230, 229, 72, 118, 144, 93, 255, 209, 21, 93, 35, 85, 100, 64, 129, 196, 154, 153, 243, 202, 57, 41, 67, 235, 251, 183, 149, 234, 74]) }, logicalIndex := 0, digest := (bytes [113, 237, 139, 40, 155, 210, 250, 223, 117, 232, 55, 100, 203, 48, 131, 253, 85, 134, 189, 146, 204, 177, 120, 15, 246, 74, 113, 157, 50, 194, 194, 135]) }, valueDigest := (bytes [165, 2, 50, 180, 56, 84, 68, 13, 37, 136, 82, 191, 49, 42, 150, 67, 180, 45, 199, 251, 168, 91, 53, 39, 20, 9, 70, 46, 155, 135, 100, 116]), digest := (bytes [176, 16, 177, 153, 238, 176, 83, 109, 35, 162, 218, 173, 58, 48, 39, 254, 205, 117, 126, 125, 156, 227, 101, 191, 79, 29, 127, 87, 186, 14, 252, 59]) }), lastRead := (some { id := { object := { familyTag := 2, commitmentDigest := (bytes [219, 52, 114, 13, 77, 176, 179, 74, 81, 67, 236, 239, 123, 202, 164, 132, 34, 97, 105, 225, 232, 38, 196, 98, 156, 26, 67, 203, 197, 23, 76, 242]), layoutVersion := 1, digest := (bytes [221, 226, 194, 230, 229, 72, 118, 144, 93, 255, 209, 21, 93, 35, 85, 100, 64, 129, 196, 154, 153, 243, 202, 57, 41, 67, 235, 251, 183, 149, 234, 74]) }, logicalIndex := 5, digest := (bytes [206, 224, 171, 203, 19, 56, 91, 20, 160, 68, 131, 126, 98, 16, 67, 92, 252, 130, 33, 61, 207, 132, 69, 171, 130, 146, 245, 147, 224, 226, 218, 23]) }, valueDigest := (bytes [7, 176, 8, 206, 248, 93, 225, 149, 217, 182, 58, 129, 14, 161, 196, 91, 132, 75, 55, 202, 142, 48, 127, 131, 248, 222, 194, 168, 62, 161, 13, 188]), digest := (bytes [239, 252, 200, 201, 185, 131, 16, 180, 183, 179, 235, 169, 79, 175, 60, 103, 221, 66, 121, 169, 24, 170, 0, 17, 157, 164, 3, 222, 105, 214, 96, 223]) }), firstWrite := (some { id := { object := { familyTag := 3, commitmentDigest := (bytes [63, 201, 151, 43, 196, 117, 82, 173, 232, 83, 253, 174, 198, 202, 122, 222, 183, 183, 191, 212, 123, 131, 66, 128, 124, 186, 24, 168, 26, 178, 252, 156]), layoutVersion := 1, digest := (bytes [221, 243, 71, 184, 157, 93, 188, 12, 214, 37, 117, 155, 74, 232, 138, 1, 231, 114, 77, 223, 132, 195, 168, 211, 71, 56, 59, 173, 238, 255, 240, 200]) }, logicalIndex := 0, digest := (bytes [194, 221, 250, 66, 54, 174, 79, 143, 137, 109, 66, 64, 112, 25, 195, 181, 223, 63, 240, 244, 23, 106, 204, 95, 81, 70, 104, 240, 50, 162, 64, 207]) }, valueDigest := (bytes [73, 175, 249, 106, 163, 84, 49, 4, 122, 98, 125, 56, 99, 1, 90, 255, 89, 80, 68, 237, 88, 57, 187, 224, 2, 195, 250, 214, 36, 107, 236, 89]), digest := (bytes [87, 25, 138, 84, 222, 163, 254, 174, 194, 231, 5, 254, 236, 186, 205, 102, 76, 66, 218, 64, 155, 135, 136, 188, 189, 227, 222, 18, 95, 145, 145, 121]) }), lastWrite := (some { id := { object := { familyTag := 3, commitmentDigest := (bytes [63, 201, 151, 43, 196, 117, 82, 173, 232, 83, 253, 174, 198, 202, 122, 222, 183, 183, 191, 212, 123, 131, 66, 128, 124, 186, 24, 168, 26, 178, 252, 156]), layoutVersion := 1, digest := (bytes [221, 243, 71, 184, 157, 93, 188, 12, 214, 37, 117, 155, 74, 232, 138, 1, 231, 114, 77, 223, 132, 195, 168, 211, 71, 56, 59, 173, 238, 255, 240, 200]) }, logicalIndex := 3, digest := (bytes [119, 64, 80, 192, 44, 146, 25, 70, 154, 203, 10, 202, 109, 128, 238, 234, 242, 5, 74, 31, 202, 56, 188, 93, 166, 244, 3, 31, 55, 132, 213, 35]) }, valueDigest := (bytes [26, 232, 97, 215, 117, 203, 127, 115, 68, 34, 71, 78, 227, 216, 154, 57, 186, 35, 77, 70, 15, 66, 22, 55, 110, 181, 26, 70, 251, 106, 239, 120]), digest := (bytes [221, 46, 47, 151, 76, 53, 17, 141, 38, 56, 55, 43, 41, 205, 121, 20, 205, 186, 80, 24, 164, 193, 60, 142, 48, 10, 157, 144, 251, 45, 14, 231]) }), firstRam := none, lastRam := none, firstTwist := (some { id := { object := { familyTag := 5, commitmentDigest := (bytes [145, 7, 176, 110, 228, 30, 110, 174, 142, 253, 93, 219, 65, 126, 52, 120, 153, 172, 211, 89, 110, 204, 173, 110, 238, 194, 151, 95, 251, 102, 157, 215]), layoutVersion := 1, digest := (bytes [133, 209, 176, 247, 101, 124, 93, 5, 73, 0, 138, 35, 89, 29, 63, 211, 117, 230, 128, 35, 125, 193, 131, 153, 99, 81, 236, 78, 96, 1, 149, 219]) }, logicalIndex := 0, digest := (bytes [223, 109, 166, 234, 182, 14, 115, 114, 83, 82, 151, 98, 151, 105, 231, 177, 27, 103, 238, 2, 30, 28, 135, 45, 211, 231, 244, 45, 7, 17, 186, 44]) }, valueDigest := (bytes [152, 210, 9, 226, 48, 227, 125, 163, 175, 47, 209, 131, 157, 49, 214, 35, 77, 147, 136, 211, 94, 27, 18, 44, 164, 188, 250, 227, 46, 121, 208, 238]), digest := (bytes [44, 57, 100, 10, 218, 57, 175, 26, 95, 175, 29, 95, 52, 254, 20, 237, 45, 226, 176, 28, 17, 188, 215, 17, 220, 24, 222, 188, 158, 35, 74, 26]) }), lastTwist := (some { id := { object := { familyTag := 5, commitmentDigest := (bytes [145, 7, 176, 110, 228, 30, 110, 174, 142, 253, 93, 219, 65, 126, 52, 120, 153, 172, 211, 89, 110, 204, 173, 110, 238, 194, 151, 95, 251, 102, 157, 215]), layoutVersion := 1, digest := (bytes [133, 209, 176, 247, 101, 124, 93, 5, 73, 0, 138, 35, 89, 29, 63, 211, 117, 230, 128, 35, 125, 193, 131, 153, 99, 81, 236, 78, 96, 1, 149, 219]) }, logicalIndex := 4, digest := (bytes [87, 147, 103, 8, 164, 18, 27, 95, 99, 51, 53, 140, 84, 123, 200, 244, 190, 81, 123, 54, 128, 11, 22, 155, 218, 177, 43, 61, 199, 188, 153, 112]) }, valueDigest := (bytes [222, 14, 37, 177, 188, 230, 71, 93, 144, 22, 98, 93, 2, 239, 167, 13, 4, 68, 129, 81, 87, 184, 54, 32, 144, 210, 18, 143, 160, 134, 36, 170]), digest := (bytes [38, 85, 238, 179, 102, 20, 149, 73, 255, 9, 103, 60, 190, 175, 204, 41, 165, 26, 82, 182, 139, 136, 119, 180, 236, 243, 147, 136, 36, 13, 25, 35]) }) }, digest := (bytes [144, 145, 114, 6, 151, 181, 79, 138, 142, 116, 33, 211, 221, 145, 83, 192, 118, 197, 114, 170, 85, 175, 112, 23, 247, 57, 28, 149, 60, 131, 135, 45]) }, packaged := { statementDigest := (bytes [176, 116, 228, 147, 27, 238, 68, 181, 197, 116, 84, 135, 234, 203, 86, 235, 59, 225, 45, 195, 73, 219, 155, 206, 225, 152, 229, 118, 172, 205, 135, 20]), proofDigest := (bytes [141, 143, 45, 4, 212, 135, 143, 7, 134, 185, 101, 87, 168, 16, 239, 245, 227, 50, 122, 158, 247, 61, 160, 209, 192, 64, 137, 106, 217, 206, 150, 139]) }, digest := (bytes [40, 195, 49, 80, 144, 193, 37, 148, 42, 214, 173, 133, 9, 128, 62, 61, 85, 4, 200, 87, 144, 38, 157, 54, 166, 133, 181, 248, 119, 11, 41, 186]) }
    , digest := (bytes [57, 170, 245, 4, 189, 83, 36, 24, 38, 108, 46, 54, 193, 203, 181, 124, 202, 97, 70, 81, 116, 92, 249, 208, 88, 224, 158, 235, 231, 77, 157, 13])
  }

def stage3Continuity : List ContinuityEventView :=
  [{ stepIndex := 0, pc := 0, nextPc := 4, successorPc := (some 4), finalStep := false, continuityHolds := true }, { stepIndex := 1, pc := 4, nextPc := 8, successorPc := (some 8), finalStep := false, continuityHolds := true }, { stepIndex := 2, pc := 8, nextPc := 12, successorPc := (some 12), finalStep := false, continuityHolds := true }, { stepIndex := 3, pc := 12, nextPc := 16, successorPc := (some 16), finalStep := false, continuityHolds := true }, { stepIndex := 4, pc := 16, nextPc := 20, successorPc := none, finalStep := true, continuityHolds := true }]

def stage3 : Stage3ProofBundleView :=
  {
    continuity := stage3Continuity
    , halted := true
    , bridgeDigest := (bytes [108, 122, 228, 150, 225, 104, 207, 4, 223, 64, 63, 38, 40, 135, 54, 145, 245, 148, 210, 198, 252, 37, 140, 223, 104, 6, 11, 236, 117, 121, 222, 177])
    , semantics := { continuityDigest := (bytes [113, 144, 165, 117, 2, 23, 60, 214, 235, 214, 31, 246, 32, 212, 211, 7, 206, 201, 156, 63, 29, 37, 105, 63, 79, 95, 223, 52, 30, 184, 74, 89]), rootSemanticRowsDigest := (bytes [130, 16, 4, 176, 253, 220, 67, 250, 46, 179, 234, 171, 79, 64, 144, 149, 138, 103, 119, 21, 248, 56, 215, 237, 26, 77, 101, 6, 248, 79, 69, 158]), rowChunkRoutesDigest := (bytes [17, 91, 99, 15, 11, 236, 55, 95, 29, 64, 142, 221, 223, 108, 122, 237, 32, 185, 12, 250, 217, 143, 221, 95, 118, 207, 92, 60, 104, 225, 196, 181]), preparedStepBindingsDigest := (bytes [91, 117, 19, 85, 154, 0, 166, 170, 125, 60, 174, 129, 137, 154, 174, 169, 226, 246, 107, 48, 0, 2, 213, 88, 23, 96, 42, 187, 137, 2, 41, 26]), stage2TemporalDigest := (bytes [144, 57, 60, 147, 57, 107, 146, 148, 125, 231, 133, 111, 183, 196, 186, 145, 128, 39, 219, 237, 85, 174, 166, 55, 110, 62, 232, 234, 234, 195, 168, 149]), initialPc := 0, finalPc := 20, realRowCount := 5, firstRealStepIndex := 0, lastRealStepIndex := 4, digest := (bytes [2, 98, 244, 254, 249, 180, 251, 77, 151, 107, 132, 46, 149, 159, 135, 249, 181, 108, 88, 176, 96, 120, 174, 170, 183, 230, 82, 229, 217, 100, 11, 245]) }
    , linkageDigest := (bytes [82, 68, 117, 234, 234, 51, 223, 230, 88, 143, 115, 251, 104, 139, 78, 90, 211, 250, 16, 212, 113, 153, 109, 46, 111, 140, 7, 89, 33, 146, 109, 60])
    , selectedOpening := { claim := { continuityFamilyDigest := (bytes [180, 21, 202, 67, 212, 116, 149, 242, 73, 2, 254, 74, 208, 185, 115, 209, 229, 157, 227, 181, 78, 244, 25, 29, 82, 77, 170, 252, 145, 102, 124, 182]), continuityCount := 5, finalStepCount := 1, halted := true, allContinuityHold := true, continuityMix := 17263612136838009662, points := { firstContinuity := (some { id := { object := { familyTag := 6, commitmentDigest := (bytes [180, 21, 202, 67, 212, 116, 149, 242, 73, 2, 254, 74, 208, 185, 115, 209, 229, 157, 227, 181, 78, 244, 25, 29, 82, 77, 170, 252, 145, 102, 124, 182]), layoutVersion := 1, digest := (bytes [197, 249, 85, 212, 218, 101, 152, 186, 19, 30, 36, 185, 152, 165, 209, 83, 127, 197, 28, 107, 221, 36, 65, 234, 79, 144, 20, 55, 123, 91, 148, 38]) }, logicalIndex := 0, digest := (bytes [135, 2, 138, 56, 98, 95, 181, 59, 112, 48, 52, 204, 46, 180, 117, 79, 81, 155, 36, 255, 244, 98, 41, 249, 179, 137, 245, 2, 152, 230, 83, 35]) }, valueDigest := (bytes [7, 131, 85, 21, 57, 109, 53, 31, 137, 53, 98, 18, 170, 36, 28, 200, 149, 213, 171, 159, 119, 200, 36, 230, 30, 35, 30, 11, 252, 126, 240, 63]), digest := (bytes [225, 52, 168, 222, 40, 147, 187, 132, 92, 200, 35, 10, 97, 76, 58, 203, 54, 182, 172, 214, 174, 127, 114, 107, 246, 49, 116, 83, 102, 231, 50, 247]) }), lastContinuity := (some { id := { object := { familyTag := 6, commitmentDigest := (bytes [180, 21, 202, 67, 212, 116, 149, 242, 73, 2, 254, 74, 208, 185, 115, 209, 229, 157, 227, 181, 78, 244, 25, 29, 82, 77, 170, 252, 145, 102, 124, 182]), layoutVersion := 1, digest := (bytes [197, 249, 85, 212, 218, 101, 152, 186, 19, 30, 36, 185, 152, 165, 209, 83, 127, 197, 28, 107, 221, 36, 65, 234, 79, 144, 20, 55, 123, 91, 148, 38]) }, logicalIndex := 4, digest := (bytes [59, 120, 172, 250, 102, 117, 237, 222, 163, 236, 2, 151, 147, 71, 229, 87, 204, 46, 208, 175, 16, 115, 154, 231, 8, 218, 118, 159, 106, 155, 179, 177]) }, valueDigest := (bytes [78, 141, 235, 113, 13, 200, 242, 233, 5, 141, 141, 77, 19, 78, 184, 2, 187, 100, 140, 5, 110, 219, 176, 65, 169, 115, 213, 24, 209, 59, 174, 122]), digest := (bytes [32, 72, 38, 207, 217, 2, 6, 111, 100, 238, 67, 192, 170, 240, 177, 100, 84, 19, 190, 114, 176, 150, 214, 214, 239, 213, 82, 176, 88, 198, 114, 246]) }) }, digest := (bytes [182, 247, 64, 8, 126, 102, 49, 191, 16, 195, 11, 63, 205, 198, 226, 37, 51, 118, 190, 171, 113, 18, 150, 97, 141, 43, 55, 161, 12, 230, 157, 244]) }, packaged := { statementDigest := (bytes [31, 112, 79, 219, 77, 201, 73, 127, 209, 204, 55, 48, 106, 110, 251, 20, 98, 132, 165, 111, 102, 227, 187, 177, 87, 107, 190, 150, 132, 101, 61, 248]), proofDigest := (bytes [119, 167, 57, 36, 55, 11, 25, 195, 131, 220, 158, 206, 109, 247, 169, 86, 109, 215, 159, 53, 137, 244, 59, 100, 4, 152, 62, 73, 189, 67, 55, 181]) }, digest := (bytes [222, 201, 157, 144, 205, 9, 149, 155, 9, 164, 122, 0, 0, 97, 212, 97, 34, 22, 78, 10, 168, 239, 51, 12, 115, 132, 210, 180, 79, 66, 248, 179]) }
    , digest := (bytes [238, 95, 162, 193, 175, 19, 247, 226, 71, 108, 28, 62, 187, 138, 106, 167, 89, 138, 241, 227, 37, 14, 55, 228, 80, 100, 23, 94, 161, 111, 134, 49])
  }

def rootExecutionExecutionRows : List ExpandedRowView :=
  [{
  traceIndex := 0
  , stepIndex := 0
  , sequenceIndex := 0
  , pc := 0
  , nextPc := 4
  , word := 4293918875
  , opcode := .addiw
  , traceOpcode := (some .addiw)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 0
  , rs1Value := 0
  , rs2 := 0
  , rs2Value := 0
  , rd := 1
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
  traceIndex := 1
  , stepIndex := 1
  , sequenceIndex := 0
  , pc := 4
  , nextPc := 8
  , word := 2130203
  , opcode := .addiw
  , traceOpcode := (some .addiw)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 18446744073709551615
  , rs2 := 0
  , rs2Value := 0
  , rd := 2
  , rdBefore := 0
  , rdAfter := 1
  , imm := 2
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
  traceIndex := 2
  , stepIndex := 2
  , sequenceIndex := 0
  , pc := 8
  , nextPc := 12
  , word := 4293563
  , opcode := .addw
  , traceOpcode := (some .addw)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 3
  , rs1Value := 2147483647
  , rs2 := 4
  , rs2Value := 2
  , rd := 7
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
  , word := 1080198203
  , opcode := .subw
  , traceOpcode := (some .subw)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 5
  , rs1Value := 0
  , rs2 := 6
  , rs2Value := 1
  , rd := 8
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
  [{ traceIndex := 0, values := [1, 0, 0, 4, 0, 0, 0, 0, 0, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [59, 110, 73, 184, 21, 134, 14, 247, 63, 174, 178, 199, 142, 253, 82, 19, 165, 139, 8, 196, 235, 194, 3, 121, 51, 124, 231, 35, 211, 16, 32, 52]), digest := (bytes [149, 139, 19, 34, 118, 90, 19, 4, 52, 25, 83, 142, 194, 138, 57, 197, 246, 189, 203, 198, 215, 227, 168, 97, 227, 226, 140, 68, 186, 83, 202, 182]) }, { traceIndex := 1, values := [1, 4, 0, 8, 0, 4294967295, 4294967295, 0, 0, 1, 0, 2, 0, 1, 0, 8, 0, 0, 0, 0, 0, 0, 0, 2, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [230, 238, 245, 201, 43, 253, 133, 252, 134, 124, 68, 117, 135, 91, 42, 243, 23, 65, 162, 194, 69, 75, 36, 58, 169, 113, 90, 254, 90, 21, 220, 160]), digest := (bytes [129, 22, 184, 109, 189, 56, 245, 10, 153, 194, 36, 133, 123, 224, 78, 146, 78, 186, 1, 70, 230, 111, 199, 179, 0, 93, 167, 174, 1, 88, 31, 22]) }, { traceIndex := 2, values := [1, 8, 0, 12, 0, 2147483647, 0, 2, 0, 2147483649, 4294967295, 0, 0, 2147483649, 4294967295, 12, 0, 0, 0, 0, 0, 0, 0, 7, 3, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1], rowDigest := (bytes [12, 240, 32, 134, 251, 91, 200, 11, 51, 253, 209, 184, 159, 91, 162, 90, 29, 11, 155, 107, 180, 135, 97, 131, 201, 140, 237, 0, 9, 2, 217, 113]), digest := (bytes [252, 66, 209, 177, 119, 125, 56, 177, 215, 254, 227, 72, 92, 149, 179, 9, 234, 73, 2, 207, 58, 49, 223, 185, 135, 111, 23, 166, 6, 63, 85, 98]) }, { traceIndex := 3, values := [1, 12, 0, 16, 0, 0, 0, 1, 0, 4294967295, 4294967295, 0, 0, 4294967295, 4294967295, 16, 0, 0, 0, 0, 0, 0, 0, 8, 5, 6, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1], rowDigest := (bytes [96, 254, 16, 152, 44, 113, 66, 83, 167, 31, 130, 157, 70, 156, 157, 78, 181, 51, 44, 189, 153, 103, 41, 245, 124, 142, 146, 189, 18, 54, 204, 162]), digest := (bytes [59, 242, 201, 114, 122, 232, 98, 97, 10, 102, 170, 223, 123, 149, 216, 235, 201, 239, 228, 24, 135, 185, 147, 83, 32, 96, 208, 212, 234, 105, 239, 16]) }, { traceIndex := 4, values := [1, 16, 0, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [247, 8, 91, 86, 174, 60, 198, 248, 80, 76, 136, 253, 192, 49, 138, 233, 64, 183, 153, 201, 60, 173, 121, 212, 113, 120, 175, 228, 9, 127, 13, 255]), digest := (bytes [240, 235, 255, 76, 153, 52, 106, 255, 177, 158, 252, 199, 149, 118, 183, 94, 220, 38, 144, 227, 121, 141, 204, 78, 177, 0, 122, 124, 105, 74, 208, 125]) }]

def rootExecutionPreparedBindings : List PreparedStepBindingView :=
  [{ traceIndex := 0, rowDigest := (bytes [59, 110, 73, 184, 21, 134, 14, 247, 63, 174, 178, 199, 142, 253, 82, 19, 165, 139, 8, 196, 235, 194, 3, 121, 51, 124, 231, 35, 211, 16, 32, 52]), rowOpeningDigest := (bytes [107, 83, 143, 13, 16, 195, 28, 191, 30, 23, 48, 73, 127, 45, 146, 223, 29, 40, 32, 36, 96, 122, 180, 245, 149, 85, 174, 218, 110, 201, 84, 5]), digest := (bytes [25, 11, 217, 92, 88, 160, 212, 211, 136, 141, 82, 184, 177, 46, 81, 157, 179, 159, 135, 132, 224, 119, 249, 41, 240, 241, 220, 197, 133, 119, 124, 255]) }, { traceIndex := 1, rowDigest := (bytes [230, 238, 245, 201, 43, 253, 133, 252, 134, 124, 68, 117, 135, 91, 42, 243, 23, 65, 162, 194, 69, 75, 36, 58, 169, 113, 90, 254, 90, 21, 220, 160]), rowOpeningDigest := (bytes [140, 174, 11, 215, 32, 181, 13, 97, 99, 20, 253, 160, 174, 61, 94, 186, 34, 46, 172, 2, 255, 20, 243, 229, 3, 72, 138, 198, 212, 235, 143, 228]), digest := (bytes [249, 22, 187, 225, 248, 171, 155, 153, 105, 101, 94, 62, 111, 82, 210, 190, 38, 207, 178, 78, 24, 218, 15, 166, 52, 174, 171, 162, 152, 236, 214, 240]) }, { traceIndex := 2, rowDigest := (bytes [12, 240, 32, 134, 251, 91, 200, 11, 51, 253, 209, 184, 159, 91, 162, 90, 29, 11, 155, 107, 180, 135, 97, 131, 201, 140, 237, 0, 9, 2, 217, 113]), rowOpeningDigest := (bytes [61, 8, 5, 163, 250, 51, 85, 13, 119, 208, 180, 165, 231, 3, 14, 161, 237, 54, 64, 85, 39, 123, 57, 223, 93, 90, 43, 102, 138, 78, 107, 64]), digest := (bytes [43, 25, 106, 116, 9, 218, 47, 144, 216, 59, 181, 182, 213, 177, 29, 254, 154, 191, 197, 238, 169, 88, 152, 219, 53, 171, 80, 4, 80, 150, 220, 21]) }, { traceIndex := 3, rowDigest := (bytes [96, 254, 16, 152, 44, 113, 66, 83, 167, 31, 130, 157, 70, 156, 157, 78, 181, 51, 44, 189, 153, 103, 41, 245, 124, 142, 146, 189, 18, 54, 204, 162]), rowOpeningDigest := (bytes [187, 171, 244, 139, 107, 178, 159, 0, 140, 101, 83, 218, 99, 195, 44, 137, 40, 28, 109, 189, 232, 130, 44, 224, 199, 139, 145, 242, 103, 144, 106, 82]), digest := (bytes [78, 81, 81, 144, 250, 123, 134, 114, 148, 73, 196, 112, 136, 108, 161, 29, 1, 169, 189, 106, 255, 146, 129, 131, 102, 244, 84, 147, 82, 138, 141, 219]) }, { traceIndex := 4, rowDigest := (bytes [247, 8, 91, 86, 174, 60, 198, 248, 80, 76, 136, 253, 192, 49, 138, 233, 64, 183, 153, 201, 60, 173, 121, 212, 113, 120, 175, 228, 9, 127, 13, 255]), rowOpeningDigest := (bytes [185, 244, 106, 195, 5, 46, 56, 8, 140, 244, 184, 72, 72, 170, 174, 7, 161, 225, 151, 205, 116, 150, 66, 233, 90, 246, 89, 180, 145, 7, 221, 136]), digest := (bytes [55, 215, 43, 161, 102, 58, 94, 235, 254, 110, 43, 252, 137, 128, 118, 79, 3, 90, 208, 135, 125, 233, 113, 110, 141, 69, 220, 22, 255, 129, 201, 119]) }]

def rootExecutionRowChunkRoutes : List RowChunkRouteView :=
  [{ logicalIndex := 0, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 0, digest := (bytes [138, 198, 109, 126, 144, 82, 221, 43, 248, 202, 137, 103, 62, 226, 249, 152, 163, 187, 1, 254, 36, 33, 59, 16, 64, 166, 202, 8, 219, 57, 240, 59]) }, { logicalIndex := 1, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 1, digest := (bytes [44, 177, 82, 41, 218, 60, 100, 208, 26, 31, 151, 113, 109, 148, 57, 12, 223, 21, 76, 221, 70, 245, 191, 105, 57, 199, 8, 128, 181, 145, 89, 99]) }, { logicalIndex := 2, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 2, digest := (bytes [252, 248, 65, 24, 81, 241, 150, 170, 250, 116, 222, 30, 134, 191, 78, 195, 104, 119, 225, 210, 243, 186, 212, 107, 183, 31, 243, 201, 101, 148, 32, 72]) }, { logicalIndex := 3, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 3, digest := (bytes [244, 11, 162, 13, 59, 43, 232, 47, 228, 2, 70, 126, 95, 10, 57, 40, 46, 107, 197, 81, 97, 39, 185, 163, 93, 60, 5, 66, 7, 231, 199, 134]) }, { logicalIndex := 4, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 4, digest := (bytes [98, 247, 204, 83, 252, 219, 248, 73, 49, 206, 229, 79, 169, 242, 28, 56, 7, 100, 18, 197, 133, 200, 133, 20, 161, 230, 126, 175, 98, 0, 158, 25]) }]

def rootExecutionRowLocalCcsAcceptance : List RootRowLocalCcsAcceptanceView :=
  [{ traceIndex := 0, logicalIndex := 0, rowDigest := (bytes [59, 110, 73, 184, 21, 134, 14, 247, 63, 174, 178, 199, 142, 253, 82, 19, 165, 139, 8, 196, 235, 194, 3, 121, 51, 124, 231, 35, 211, 16, 32, 52]), rowOpeningDigest := (bytes [107, 83, 143, 13, 16, 195, 28, 191, 30, 23, 48, 73, 127, 45, 146, 223, 29, 40, 32, 36, 96, 122, 180, 245, 149, 85, 174, 218, 110, 201, 84, 5]), preparedStepBindingDigest := (bytes [25, 11, 217, 92, 88, 160, 212, 211, 136, 141, 82, 184, 177, 46, 81, 157, 179, 159, 135, 132, 224, 119, 249, 41, 240, 241, 220, 197, 133, 119, 124, 255]), rowChunkRouteDigest := (bytes [138, 198, 109, 126, 144, 82, 221, 43, 248, 202, 137, 103, 62, 226, 249, 152, 163, 187, 1, 254, 36, 33, 59, 16, 64, 166, 202, 8, 219, 57, 240, 59]), publicStepDigest := (bytes [23, 18, 247, 230, 186, 1, 79, 67, 192, 72, 168, 22, 247, 81, 178, 236, 130, 231, 105, 186, 196, 204, 4, 183, 1, 21, 11, 161, 179, 66, 54, 0]), digest := (bytes [242, 78, 55, 66, 68, 229, 151, 60, 121, 160, 42, 153, 103, 194, 86, 81, 193, 118, 205, 144, 152, 245, 130, 127, 69, 246, 73, 197, 94, 135, 14, 255]) }, { traceIndex := 1, logicalIndex := 1, rowDigest := (bytes [230, 238, 245, 201, 43, 253, 133, 252, 134, 124, 68, 117, 135, 91, 42, 243, 23, 65, 162, 194, 69, 75, 36, 58, 169, 113, 90, 254, 90, 21, 220, 160]), rowOpeningDigest := (bytes [140, 174, 11, 215, 32, 181, 13, 97, 99, 20, 253, 160, 174, 61, 94, 186, 34, 46, 172, 2, 255, 20, 243, 229, 3, 72, 138, 198, 212, 235, 143, 228]), preparedStepBindingDigest := (bytes [249, 22, 187, 225, 248, 171, 155, 153, 105, 101, 94, 62, 111, 82, 210, 190, 38, 207, 178, 78, 24, 218, 15, 166, 52, 174, 171, 162, 152, 236, 214, 240]), rowChunkRouteDigest := (bytes [44, 177, 82, 41, 218, 60, 100, 208, 26, 31, 151, 113, 109, 148, 57, 12, 223, 21, 76, 221, 70, 245, 191, 105, 57, 199, 8, 128, 181, 145, 89, 99]), publicStepDigest := (bytes [169, 238, 191, 157, 149, 229, 220, 197, 41, 135, 145, 140, 131, 63, 87, 242, 209, 139, 108, 122, 24, 215, 100, 105, 222, 238, 140, 137, 45, 239, 116, 244]), digest := (bytes [229, 50, 38, 119, 2, 184, 101, 220, 68, 253, 167, 111, 216, 197, 87, 240, 18, 41, 53, 237, 104, 252, 251, 210, 116, 38, 198, 129, 164, 65, 122, 190]) }, { traceIndex := 2, logicalIndex := 2, rowDigest := (bytes [12, 240, 32, 134, 251, 91, 200, 11, 51, 253, 209, 184, 159, 91, 162, 90, 29, 11, 155, 107, 180, 135, 97, 131, 201, 140, 237, 0, 9, 2, 217, 113]), rowOpeningDigest := (bytes [61, 8, 5, 163, 250, 51, 85, 13, 119, 208, 180, 165, 231, 3, 14, 161, 237, 54, 64, 85, 39, 123, 57, 223, 93, 90, 43, 102, 138, 78, 107, 64]), preparedStepBindingDigest := (bytes [43, 25, 106, 116, 9, 218, 47, 144, 216, 59, 181, 182, 213, 177, 29, 254, 154, 191, 197, 238, 169, 88, 152, 219, 53, 171, 80, 4, 80, 150, 220, 21]), rowChunkRouteDigest := (bytes [252, 248, 65, 24, 81, 241, 150, 170, 250, 116, 222, 30, 134, 191, 78, 195, 104, 119, 225, 210, 243, 186, 212, 107, 183, 31, 243, 201, 101, 148, 32, 72]), publicStepDigest := (bytes [148, 175, 96, 71, 239, 216, 134, 235, 166, 48, 145, 60, 71, 212, 90, 151, 160, 148, 144, 34, 67, 139, 175, 51, 234, 89, 156, 156, 215, 11, 22, 91]), digest := (bytes [56, 149, 172, 69, 71, 118, 222, 77, 70, 255, 247, 70, 74, 152, 81, 212, 40, 208, 228, 72, 123, 62, 97, 49, 1, 174, 161, 43, 201, 102, 206, 11]) }, { traceIndex := 3, logicalIndex := 3, rowDigest := (bytes [96, 254, 16, 152, 44, 113, 66, 83, 167, 31, 130, 157, 70, 156, 157, 78, 181, 51, 44, 189, 153, 103, 41, 245, 124, 142, 146, 189, 18, 54, 204, 162]), rowOpeningDigest := (bytes [187, 171, 244, 139, 107, 178, 159, 0, 140, 101, 83, 218, 99, 195, 44, 137, 40, 28, 109, 189, 232, 130, 44, 224, 199, 139, 145, 242, 103, 144, 106, 82]), preparedStepBindingDigest := (bytes [78, 81, 81, 144, 250, 123, 134, 114, 148, 73, 196, 112, 136, 108, 161, 29, 1, 169, 189, 106, 255, 146, 129, 131, 102, 244, 84, 147, 82, 138, 141, 219]), rowChunkRouteDigest := (bytes [244, 11, 162, 13, 59, 43, 232, 47, 228, 2, 70, 126, 95, 10, 57, 40, 46, 107, 197, 81, 97, 39, 185, 163, 93, 60, 5, 66, 7, 231, 199, 134]), publicStepDigest := (bytes [133, 211, 227, 205, 105, 126, 116, 94, 129, 194, 170, 198, 117, 232, 129, 131, 52, 142, 251, 205, 35, 36, 162, 184, 200, 108, 208, 199, 167, 12, 0, 217]), digest := (bytes [237, 208, 85, 179, 96, 68, 56, 84, 67, 189, 167, 253, 168, 126, 154, 243, 147, 1, 184, 122, 111, 194, 85, 26, 106, 100, 76, 10, 16, 68, 228, 114]) }, { traceIndex := 4, logicalIndex := 4, rowDigest := (bytes [247, 8, 91, 86, 174, 60, 198, 248, 80, 76, 136, 253, 192, 49, 138, 233, 64, 183, 153, 201, 60, 173, 121, 212, 113, 120, 175, 228, 9, 127, 13, 255]), rowOpeningDigest := (bytes [185, 244, 106, 195, 5, 46, 56, 8, 140, 244, 184, 72, 72, 170, 174, 7, 161, 225, 151, 205, 116, 150, 66, 233, 90, 246, 89, 180, 145, 7, 221, 136]), preparedStepBindingDigest := (bytes [55, 215, 43, 161, 102, 58, 94, 235, 254, 110, 43, 252, 137, 128, 118, 79, 3, 90, 208, 135, 125, 233, 113, 110, 141, 69, 220, 22, 255, 129, 201, 119]), rowChunkRouteDigest := (bytes [98, 247, 204, 83, 252, 219, 248, 73, 49, 206, 229, 79, 169, 242, 28, 56, 7, 100, 18, 197, 133, 200, 133, 20, 161, 230, 126, 175, 98, 0, 158, 25]), publicStepDigest := (bytes [72, 142, 192, 218, 173, 197, 55, 221, 78, 31, 126, 194, 22, 139, 72, 204, 128, 208, 103, 242, 122, 221, 175, 246, 50, 244, 221, 89, 210, 23, 111, 183]), digest := (bytes [30, 8, 165, 157, 117, 36, 13, 199, 225, 180, 226, 172, 22, 197, 84, 36, 233, 40, 70, 77, 17, 201, 164, 159, 196, 249, 64, 47, 34, 20, 195, 83]) }]

def rootExecutionExecutionSemanticsRefinement : List RootExecutionSemanticsRefinementView :=
  [{ traceIndex := 0, logicalIndex := 0, semanticRowDigest := (bytes [149, 139, 19, 34, 118, 90, 19, 4, 52, 25, 83, 142, 194, 138, 57, 197, 246, 189, 203, 198, 215, 227, 168, 97, 227, 226, 140, 68, 186, 83, 202, 182]), rowLocalCcsAcceptanceDigest := (bytes [242, 78, 55, 66, 68, 229, 151, 60, 121, 160, 42, 153, 103, 194, 86, 81, 193, 118, 205, 144, 152, 245, 130, 127, 69, 246, 73, 197, 94, 135, 14, 255]), preparedStepBindingDigest := (bytes [25, 11, 217, 92, 88, 160, 212, 211, 136, 141, 82, 184, 177, 46, 81, 157, 179, 159, 135, 132, 224, 119, 249, 41, 240, 241, 220, 197, 133, 119, 124, 255]), publicStepDigest := (bytes [23, 18, 247, 230, 186, 1, 79, 67, 192, 72, 168, 22, 247, 81, 178, 236, 130, 231, 105, 186, 196, 204, 4, 183, 1, 21, 11, 161, 179, 66, 54, 0]), digest := (bytes [216, 82, 7, 195, 77, 207, 144, 197, 249, 213, 40, 131, 237, 217, 25, 114, 41, 199, 122, 67, 137, 194, 248, 228, 141, 96, 95, 247, 73, 161, 186, 143]) }, { traceIndex := 1, logicalIndex := 1, semanticRowDigest := (bytes [129, 22, 184, 109, 189, 56, 245, 10, 153, 194, 36, 133, 123, 224, 78, 146, 78, 186, 1, 70, 230, 111, 199, 179, 0, 93, 167, 174, 1, 88, 31, 22]), rowLocalCcsAcceptanceDigest := (bytes [229, 50, 38, 119, 2, 184, 101, 220, 68, 253, 167, 111, 216, 197, 87, 240, 18, 41, 53, 237, 104, 252, 251, 210, 116, 38, 198, 129, 164, 65, 122, 190]), preparedStepBindingDigest := (bytes [249, 22, 187, 225, 248, 171, 155, 153, 105, 101, 94, 62, 111, 82, 210, 190, 38, 207, 178, 78, 24, 218, 15, 166, 52, 174, 171, 162, 152, 236, 214, 240]), publicStepDigest := (bytes [169, 238, 191, 157, 149, 229, 220, 197, 41, 135, 145, 140, 131, 63, 87, 242, 209, 139, 108, 122, 24, 215, 100, 105, 222, 238, 140, 137, 45, 239, 116, 244]), digest := (bytes [63, 201, 14, 239, 238, 227, 1, 213, 42, 78, 139, 34, 160, 0, 38, 19, 198, 201, 180, 168, 68, 41, 128, 1, 59, 253, 19, 77, 81, 149, 75, 58]) }, { traceIndex := 2, logicalIndex := 2, semanticRowDigest := (bytes [252, 66, 209, 177, 119, 125, 56, 177, 215, 254, 227, 72, 92, 149, 179, 9, 234, 73, 2, 207, 58, 49, 223, 185, 135, 111, 23, 166, 6, 63, 85, 98]), rowLocalCcsAcceptanceDigest := (bytes [56, 149, 172, 69, 71, 118, 222, 77, 70, 255, 247, 70, 74, 152, 81, 212, 40, 208, 228, 72, 123, 62, 97, 49, 1, 174, 161, 43, 201, 102, 206, 11]), preparedStepBindingDigest := (bytes [43, 25, 106, 116, 9, 218, 47, 144, 216, 59, 181, 182, 213, 177, 29, 254, 154, 191, 197, 238, 169, 88, 152, 219, 53, 171, 80, 4, 80, 150, 220, 21]), publicStepDigest := (bytes [148, 175, 96, 71, 239, 216, 134, 235, 166, 48, 145, 60, 71, 212, 90, 151, 160, 148, 144, 34, 67, 139, 175, 51, 234, 89, 156, 156, 215, 11, 22, 91]), digest := (bytes [34, 19, 122, 72, 9, 243, 190, 40, 236, 69, 61, 41, 174, 194, 120, 191, 72, 204, 252, 228, 40, 194, 23, 182, 255, 151, 37, 24, 126, 50, 29, 221]) }, { traceIndex := 3, logicalIndex := 3, semanticRowDigest := (bytes [59, 242, 201, 114, 122, 232, 98, 97, 10, 102, 170, 223, 123, 149, 216, 235, 201, 239, 228, 24, 135, 185, 147, 83, 32, 96, 208, 212, 234, 105, 239, 16]), rowLocalCcsAcceptanceDigest := (bytes [237, 208, 85, 179, 96, 68, 56, 84, 67, 189, 167, 253, 168, 126, 154, 243, 147, 1, 184, 122, 111, 194, 85, 26, 106, 100, 76, 10, 16, 68, 228, 114]), preparedStepBindingDigest := (bytes [78, 81, 81, 144, 250, 123, 134, 114, 148, 73, 196, 112, 136, 108, 161, 29, 1, 169, 189, 106, 255, 146, 129, 131, 102, 244, 84, 147, 82, 138, 141, 219]), publicStepDigest := (bytes [133, 211, 227, 205, 105, 126, 116, 94, 129, 194, 170, 198, 117, 232, 129, 131, 52, 142, 251, 205, 35, 36, 162, 184, 200, 108, 208, 199, 167, 12, 0, 217]), digest := (bytes [91, 120, 149, 225, 129, 10, 134, 106, 129, 210, 85, 9, 19, 226, 166, 13, 136, 184, 201, 176, 3, 82, 103, 66, 65, 87, 46, 158, 188, 191, 161, 225]) }, { traceIndex := 4, logicalIndex := 4, semanticRowDigest := (bytes [240, 235, 255, 76, 153, 52, 106, 255, 177, 158, 252, 199, 149, 118, 183, 94, 220, 38, 144, 227, 121, 141, 204, 78, 177, 0, 122, 124, 105, 74, 208, 125]), rowLocalCcsAcceptanceDigest := (bytes [30, 8, 165, 157, 117, 36, 13, 199, 225, 180, 226, 172, 22, 197, 84, 36, 233, 40, 70, 77, 17, 201, 164, 159, 196, 249, 64, 47, 34, 20, 195, 83]), preparedStepBindingDigest := (bytes [55, 215, 43, 161, 102, 58, 94, 235, 254, 110, 43, 252, 137, 128, 118, 79, 3, 90, 208, 135, 125, 233, 113, 110, 141, 69, 220, 22, 255, 129, 201, 119]), publicStepDigest := (bytes [72, 142, 192, 218, 173, 197, 55, 221, 78, 31, 126, 194, 22, 139, 72, 204, 128, 208, 103, 242, 122, 221, 175, 246, 50, 244, 221, 89, 210, 23, 111, 183]), digest := (bytes [184, 212, 188, 161, 148, 226, 192, 178, 26, 186, 30, 229, 234, 78, 240, 220, 50, 140, 151, 158, 100, 122, 186, 230, 26, 130, 219, 212, 234, 125, 253, 8]) }]

def rootExecution : RootExecutionBundleView :=
  {
    executionRows := rootExecutionExecutionRows
    , semanticRows := rootExecutionSemanticRows
    , semanticRowsDigest := (bytes [130, 16, 4, 176, 253, 220, 67, 250, 46, 179, 234, 171, 79, 64, 144, 149, 138, 103, 119, 21, 248, 56, 215, 237, 26, 77, 101, 6, 248, 79, 69, 158])
    , preparedStepBindings := { bindings := rootExecutionPreparedBindings, bindingCount := 5, firstBindingDigest := (some (bytes [25, 11, 217, 92, 88, 160, 212, 211, 136, 141, 82, 184, 177, 46, 81, 157, 179, 159, 135, 132, 224, 119, 249, 41, 240, 241, 220, 197, 133, 119, 124, 255])), lastBindingDigest := (some (bytes [55, 215, 43, 161, 102, 58, 94, 235, 254, 110, 43, 252, 137, 128, 118, 79, 3, 90, 208, 135, 125, 233, 113, 110, 141, 69, 220, 22, 255, 129, 201, 119])), digest := (bytes [91, 117, 19, 85, 154, 0, 166, 170, 125, 60, 174, 129, 137, 154, 174, 169, 226, 246, 107, 48, 0, 2, 213, 88, 23, 96, 42, 187, 137, 2, 41, 26]) }
    , rowChunkRoutes := rootExecutionRowChunkRoutes
    , rowChunkRoutesDigest := (bytes [17, 91, 99, 15, 11, 236, 55, 95, 29, 64, 142, 221, 223, 108, 122, 237, 32, 185, 12, 250, 217, 143, 221, 95, 118, 207, 92, 60, 104, 225, 196, 181])
    , rowLocalCcsAcceptance := { acceptances := rootExecutionRowLocalCcsAcceptance, acceptanceCount := 5, firstAcceptanceDigest := (some (bytes [242, 78, 55, 66, 68, 229, 151, 60, 121, 160, 42, 153, 103, 194, 86, 81, 193, 118, 205, 144, 152, 245, 130, 127, 69, 246, 73, 197, 94, 135, 14, 255])), lastAcceptanceDigest := (some (bytes [30, 8, 165, 157, 117, 36, 13, 199, 225, 180, 226, 172, 22, 197, 84, 36, 233, 40, 70, 77, 17, 201, 164, 159, 196, 249, 64, 47, 34, 20, 195, 83])), digest := (bytes [145, 194, 58, 226, 80, 152, 46, 143, 16, 224, 237, 225, 231, 248, 225, 106, 84, 48, 162, 215, 147, 92, 67, 231, 132, 249, 93, 43, 118, 197, 175, 38]) }
    , executionSemanticsRefinement := { refinements := rootExecutionExecutionSemanticsRefinement, refinementCount := 5, firstRefinementDigest := (some (bytes [216, 82, 7, 195, 77, 207, 144, 197, 249, 213, 40, 131, 237, 217, 25, 114, 41, 199, 122, 67, 137, 194, 248, 228, 141, 96, 95, 247, 73, 161, 186, 143])), lastRefinementDigest := (some (bytes [184, 212, 188, 161, 148, 226, 192, 178, 26, 186, 30, 229, 234, 78, 240, 220, 50, 140, 151, 158, 100, 122, 186, 230, 26, 130, 219, 212, 234, 125, 253, 8])), digest := (bytes [234, 155, 175, 0, 66, 157, 11, 40, 103, 232, 72, 9, 164, 40, 207, 149, 230, 114, 134, 3, 76, 104, 250, 82, 145, 212, 117, 64, 72, 106, 105, 164]) }
    , familyDigest := (bytes [12, 128, 33, 184, 242, 229, 158, 205, 212, 22, 196, 91, 161, 165, 57, 3, 196, 29, 120, 223, 240, 72, 12, 96, 48, 101, 55, 21, 177, 142, 153, 177])
    , digest := (bytes [26, 54, 39, 123, 40, 48, 2, 200, 251, 250, 238, 160, 55, 66, 94, 122, 133, 15, 69, 148, 123, 89, 163, 221, 5, 8, 20, 202, 64, 38, 112, 222])
  }

def kernelOpeningBundle : SimpleKernelOpeningBundleView :=
  {
    claim := { bindings := { stageClaimBundleDigest := (bytes [5, 245, 86, 44, 48, 35, 206, 23, 23, 151, 216, 75, 178, 190, 248, 233, 7, 179, 116, 14, 179, 235, 120, 40, 233, 57, 73, 158, 114, 7, 98, 165]), stagePackageBundleDigest := (bytes [42, 28, 148, 226, 172, 23, 43, 227, 239, 241, 11, 57, 168, 79, 19, 242, 239, 206, 95, 113, 70, 47, 198, 183, 22, 102, 191, 183, 121, 181, 215, 20]), stage1PackageDigest := (bytes [173, 33, 149, 207, 246, 124, 144, 30, 221, 155, 50, 196, 200, 246, 153, 154, 92, 39, 21, 130, 0, 14, 85, 196, 68, 61, 42, 199, 208, 35, 228, 147]), stage2PackageDigest := (bytes [40, 195, 49, 80, 144, 193, 37, 148, 42, 214, 173, 133, 9, 128, 62, 61, 85, 4, 200, 87, 144, 38, 157, 54, 166, 133, 181, 248, 119, 11, 41, 186]), stage3PackageDigest := (bytes [222, 201, 157, 144, 205, 9, 149, 155, 9, 164, 122, 0, 0, 97, 212, 97, 34, 22, 78, 10, 168, 239, 51, 12, 115, 132, 210, 180, 79, 66, 248, 179]), preparedStepBindingsDigest := (bytes [91, 117, 19, 85, 154, 0, 166, 170, 125, 60, 174, 129, 137, 154, 174, 169, 226, 246, 107, 48, 0, 2, 213, 88, 23, 96, 42, 187, 137, 2, 41, 26]), bindingCount := 5, stage1RowCount := 5, stage2RegisterReadCount := 6, stage2RegisterWriteCount := 4, stage2RamEventCount := 0, stage3ContinuityCount := 5, points := { firstBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [91, 117, 19, 85, 154, 0, 166, 170, 125, 60, 174, 129, 137, 154, 174, 169, 226, 246, 107, 48, 0, 2, 213, 88, 23, 96, 42, 187, 137, 2, 41, 26]), layoutVersion := 1, digest := (bytes [177, 142, 16, 91, 93, 83, 8, 195, 247, 240, 124, 49, 194, 92, 26, 213, 126, 242, 75, 12, 132, 147, 184, 212, 60, 1, 107, 133, 77, 156, 151, 125]) }, logicalIndex := 0, digest := (bytes [195, 121, 72, 27, 210, 170, 185, 19, 91, 76, 195, 93, 195, 208, 10, 46, 50, 59, 227, 21, 166, 1, 60, 73, 5, 203, 244, 39, 30, 110, 226, 116]) }, valueDigest := (bytes [25, 11, 217, 92, 88, 160, 212, 211, 136, 141, 82, 184, 177, 46, 81, 157, 179, 159, 135, 132, 224, 119, 249, 41, 240, 241, 220, 197, 133, 119, 124, 255]), digest := (bytes [63, 203, 205, 196, 145, 86, 250, 209, 35, 91, 30, 125, 72, 188, 29, 141, 255, 133, 162, 106, 200, 103, 244, 44, 254, 187, 102, 4, 94, 32, 100, 184]) }), lastBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [91, 117, 19, 85, 154, 0, 166, 170, 125, 60, 174, 129, 137, 154, 174, 169, 226, 246, 107, 48, 0, 2, 213, 88, 23, 96, 42, 187, 137, 2, 41, 26]), layoutVersion := 1, digest := (bytes [177, 142, 16, 91, 93, 83, 8, 195, 247, 240, 124, 49, 194, 92, 26, 213, 126, 242, 75, 12, 132, 147, 184, 212, 60, 1, 107, 133, 77, 156, 151, 125]) }, logicalIndex := 4, digest := (bytes [69, 240, 9, 197, 91, 230, 97, 217, 42, 237, 64, 8, 208, 65, 14, 70, 170, 222, 215, 24, 31, 5, 47, 217, 58, 182, 241, 196, 132, 33, 109, 102]) }, valueDigest := (bytes [55, 215, 43, 161, 102, 58, 94, 235, 254, 110, 43, 252, 137, 128, 118, 79, 3, 90, 208, 135, 125, 233, 113, 110, 141, 69, 220, 22, 255, 129, 201, 119]), digest := (bytes [122, 210, 27, 39, 17, 155, 206, 211, 118, 136, 86, 192, 162, 123, 193, 234, 14, 73, 99, 211, 255, 24, 71, 183, 114, 215, 154, 127, 137, 80, 212, 150]) }) }, digest := (bytes [87, 191, 225, 12, 141, 179, 75, 17, 44, 70, 203, 126, 194, 203, 228, 143, 246, 139, 170, 196, 108, 70, 140, 165, 85, 178, 171, 45, 112, 36, 239, 0]) }, preparedSteps := { executionDigest := (bytes [12, 149, 33, 173, 171, 165, 54, 175, 9, 253, 234, 193, 13, 243, 189, 0, 121, 246, 75, 0, 67, 138, 71, 71, 204, 153, 161, 108, 26, 195, 251, 119]), finalStateDigest := (bytes [210, 76, 200, 21, 4, 69, 15, 25, 203, 33, 125, 2, 33, 189, 7, 17, 57, 53, 132, 53, 135, 156, 153, 112, 132, 50, 0, 120, 169, 124, 149, 40]), transcriptFinalDigest := (bytes [149, 175, 127, 64, 128, 109, 150, 249, 47, 57, 9, 242, 150, 54, 116, 94, 21, 122, 154, 133, 58, 143, 232, 51, 183, 46, 158, 33, 79, 174, 114, 118]), preparedStepCount := 5, finalPc := 20, halted := true, points := { firstPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [167, 134, 219, 115, 157, 1, 205, 216, 94, 200, 200, 185, 201, 29, 37, 30, 211, 219, 133, 246, 131, 127, 123, 204, 232, 247, 119, 255, 193, 111, 1, 3]), layoutVersion := 3, digest := (bytes [144, 1, 205, 205, 173, 23, 147, 240, 200, 216, 98, 186, 0, 44, 155, 17, 176, 29, 96, 184, 112, 37, 176, 54, 69, 12, 228, 43, 239, 187, 60, 244]) }, logicalIndex := 0, digest := (bytes [164, 80, 240, 165, 212, 106, 222, 27, 57, 122, 141, 225, 118, 133, 86, 173, 131, 2, 96, 85, 250, 193, 23, 124, 202, 22, 99, 160, 205, 211, 23, 21]) }, valueDigest := (bytes [59, 110, 73, 184, 21, 134, 14, 247, 63, 174, 178, 199, 142, 253, 82, 19, 165, 139, 8, 196, 235, 194, 3, 121, 51, 124, 231, 35, 211, 16, 32, 52]), digest := (bytes [239, 168, 197, 147, 208, 9, 141, 65, 93, 2, 147, 148, 71, 241, 158, 64, 43, 208, 77, 43, 187, 99, 136, 72, 199, 241, 17, 207, 187, 5, 220, 233]) }), lastPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [167, 134, 219, 115, 157, 1, 205, 216, 94, 200, 200, 185, 201, 29, 37, 30, 211, 219, 133, 246, 131, 127, 123, 204, 232, 247, 119, 255, 193, 111, 1, 3]), layoutVersion := 3, digest := (bytes [144, 1, 205, 205, 173, 23, 147, 240, 200, 216, 98, 186, 0, 44, 155, 17, 176, 29, 96, 184, 112, 37, 176, 54, 69, 12, 228, 43, 239, 187, 60, 244]) }, logicalIndex := 4, digest := (bytes [233, 101, 132, 148, 29, 173, 255, 87, 170, 115, 152, 184, 118, 32, 29, 187, 121, 72, 151, 174, 244, 84, 50, 230, 8, 34, 46, 40, 195, 220, 138, 156]) }, valueDigest := (bytes [247, 8, 91, 86, 174, 60, 198, 248, 80, 76, 136, 253, 192, 49, 138, 233, 64, 183, 153, 201, 60, 173, 121, 212, 113, 120, 175, 228, 9, 127, 13, 255]), digest := (bytes [92, 168, 23, 179, 76, 166, 139, 146, 145, 9, 165, 172, 55, 156, 201, 2, 123, 33, 172, 111, 248, 121, 159, 66, 43, 245, 188, 10, 10, 211, 195, 202]) }) }, digest := (bytes [109, 5, 213, 113, 210, 76, 156, 248, 147, 153, 138, 35, 121, 113, 104, 49, 19, 157, 148, 158, 14, 240, 128, 80, 17, 2, 201, 125, 68, 32, 49, 24]) }, digest := (bytes [37, 141, 200, 179, 134, 39, 202, 221, 107, 178, 217, 246, 199, 214, 186, 248, 173, 82, 127, 54, 6, 24, 181, 224, 108, 54, 65, 27, 119, 66, 54, 145]) }
    , bindings := { claim := { stageClaimBundleDigest := (bytes [5, 245, 86, 44, 48, 35, 206, 23, 23, 151, 216, 75, 178, 190, 248, 233, 7, 179, 116, 14, 179, 235, 120, 40, 233, 57, 73, 158, 114, 7, 98, 165]), stagePackageBundleDigest := (bytes [42, 28, 148, 226, 172, 23, 43, 227, 239, 241, 11, 57, 168, 79, 19, 242, 239, 206, 95, 113, 70, 47, 198, 183, 22, 102, 191, 183, 121, 181, 215, 20]), stage1PackageDigest := (bytes [173, 33, 149, 207, 246, 124, 144, 30, 221, 155, 50, 196, 200, 246, 153, 154, 92, 39, 21, 130, 0, 14, 85, 196, 68, 61, 42, 199, 208, 35, 228, 147]), stage2PackageDigest := (bytes [40, 195, 49, 80, 144, 193, 37, 148, 42, 214, 173, 133, 9, 128, 62, 61, 85, 4, 200, 87, 144, 38, 157, 54, 166, 133, 181, 248, 119, 11, 41, 186]), stage3PackageDigest := (bytes [222, 201, 157, 144, 205, 9, 149, 155, 9, 164, 122, 0, 0, 97, 212, 97, 34, 22, 78, 10, 168, 239, 51, 12, 115, 132, 210, 180, 79, 66, 248, 179]), preparedStepBindingsDigest := (bytes [91, 117, 19, 85, 154, 0, 166, 170, 125, 60, 174, 129, 137, 154, 174, 169, 226, 246, 107, 48, 0, 2, 213, 88, 23, 96, 42, 187, 137, 2, 41, 26]), bindingCount := 5, stage1RowCount := 5, stage2RegisterReadCount := 6, stage2RegisterWriteCount := 4, stage2RamEventCount := 0, stage3ContinuityCount := 5, points := { firstBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [91, 117, 19, 85, 154, 0, 166, 170, 125, 60, 174, 129, 137, 154, 174, 169, 226, 246, 107, 48, 0, 2, 213, 88, 23, 96, 42, 187, 137, 2, 41, 26]), layoutVersion := 1, digest := (bytes [177, 142, 16, 91, 93, 83, 8, 195, 247, 240, 124, 49, 194, 92, 26, 213, 126, 242, 75, 12, 132, 147, 184, 212, 60, 1, 107, 133, 77, 156, 151, 125]) }, logicalIndex := 0, digest := (bytes [195, 121, 72, 27, 210, 170, 185, 19, 91, 76, 195, 93, 195, 208, 10, 46, 50, 59, 227, 21, 166, 1, 60, 73, 5, 203, 244, 39, 30, 110, 226, 116]) }, valueDigest := (bytes [25, 11, 217, 92, 88, 160, 212, 211, 136, 141, 82, 184, 177, 46, 81, 157, 179, 159, 135, 132, 224, 119, 249, 41, 240, 241, 220, 197, 133, 119, 124, 255]), digest := (bytes [63, 203, 205, 196, 145, 86, 250, 209, 35, 91, 30, 125, 72, 188, 29, 141, 255, 133, 162, 106, 200, 103, 244, 44, 254, 187, 102, 4, 94, 32, 100, 184]) }), lastBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [91, 117, 19, 85, 154, 0, 166, 170, 125, 60, 174, 129, 137, 154, 174, 169, 226, 246, 107, 48, 0, 2, 213, 88, 23, 96, 42, 187, 137, 2, 41, 26]), layoutVersion := 1, digest := (bytes [177, 142, 16, 91, 93, 83, 8, 195, 247, 240, 124, 49, 194, 92, 26, 213, 126, 242, 75, 12, 132, 147, 184, 212, 60, 1, 107, 133, 77, 156, 151, 125]) }, logicalIndex := 4, digest := (bytes [69, 240, 9, 197, 91, 230, 97, 217, 42, 237, 64, 8, 208, 65, 14, 70, 170, 222, 215, 24, 31, 5, 47, 217, 58, 182, 241, 196, 132, 33, 109, 102]) }, valueDigest := (bytes [55, 215, 43, 161, 102, 58, 94, 235, 254, 110, 43, 252, 137, 128, 118, 79, 3, 90, 208, 135, 125, 233, 113, 110, 141, 69, 220, 22, 255, 129, 201, 119]), digest := (bytes [122, 210, 27, 39, 17, 155, 206, 211, 118, 136, 86, 192, 162, 123, 193, 234, 14, 73, 99, 211, 255, 24, 71, 183, 114, 215, 154, 127, 137, 80, 212, 150]) }) }, digest := (bytes [87, 191, 225, 12, 141, 179, 75, 17, 44, 70, 203, 126, 194, 203, 228, 143, 246, 139, 170, 196, 108, 70, 140, 165, 85, 178, 171, 45, 112, 36, 239, 0]) }, packaged := { statementDigest := (bytes [7, 7, 19, 174, 164, 95, 211, 22, 127, 216, 138, 157, 219, 182, 117, 155, 80, 243, 235, 81, 252, 133, 235, 189, 249, 4, 192, 15, 35, 95, 48, 8]), proofDigest := (bytes [118, 189, 213, 24, 149, 231, 185, 37, 161, 199, 181, 133, 65, 146, 223, 127, 241, 209, 0, 6, 238, 179, 9, 124, 180, 86, 88, 58, 8, 47, 164, 135]) }, digest := (bytes [149, 191, 73, 110, 39, 119, 255, 151, 218, 126, 114, 100, 146, 0, 188, 23, 15, 13, 222, 104, 3, 168, 49, 106, 39, 146, 178, 236, 141, 37, 161, 65]) }
    , preparedSteps := { claim := { executionDigest := (bytes [12, 149, 33, 173, 171, 165, 54, 175, 9, 253, 234, 193, 13, 243, 189, 0, 121, 246, 75, 0, 67, 138, 71, 71, 204, 153, 161, 108, 26, 195, 251, 119]), finalStateDigest := (bytes [210, 76, 200, 21, 4, 69, 15, 25, 203, 33, 125, 2, 33, 189, 7, 17, 57, 53, 132, 53, 135, 156, 153, 112, 132, 50, 0, 120, 169, 124, 149, 40]), transcriptFinalDigest := (bytes [149, 175, 127, 64, 128, 109, 150, 249, 47, 57, 9, 242, 150, 54, 116, 94, 21, 122, 154, 133, 58, 143, 232, 51, 183, 46, 158, 33, 79, 174, 114, 118]), preparedStepCount := 5, finalPc := 20, halted := true, points := { firstPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [167, 134, 219, 115, 157, 1, 205, 216, 94, 200, 200, 185, 201, 29, 37, 30, 211, 219, 133, 246, 131, 127, 123, 204, 232, 247, 119, 255, 193, 111, 1, 3]), layoutVersion := 3, digest := (bytes [144, 1, 205, 205, 173, 23, 147, 240, 200, 216, 98, 186, 0, 44, 155, 17, 176, 29, 96, 184, 112, 37, 176, 54, 69, 12, 228, 43, 239, 187, 60, 244]) }, logicalIndex := 0, digest := (bytes [164, 80, 240, 165, 212, 106, 222, 27, 57, 122, 141, 225, 118, 133, 86, 173, 131, 2, 96, 85, 250, 193, 23, 124, 202, 22, 99, 160, 205, 211, 23, 21]) }, valueDigest := (bytes [59, 110, 73, 184, 21, 134, 14, 247, 63, 174, 178, 199, 142, 253, 82, 19, 165, 139, 8, 196, 235, 194, 3, 121, 51, 124, 231, 35, 211, 16, 32, 52]), digest := (bytes [239, 168, 197, 147, 208, 9, 141, 65, 93, 2, 147, 148, 71, 241, 158, 64, 43, 208, 77, 43, 187, 99, 136, 72, 199, 241, 17, 207, 187, 5, 220, 233]) }), lastPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [167, 134, 219, 115, 157, 1, 205, 216, 94, 200, 200, 185, 201, 29, 37, 30, 211, 219, 133, 246, 131, 127, 123, 204, 232, 247, 119, 255, 193, 111, 1, 3]), layoutVersion := 3, digest := (bytes [144, 1, 205, 205, 173, 23, 147, 240, 200, 216, 98, 186, 0, 44, 155, 17, 176, 29, 96, 184, 112, 37, 176, 54, 69, 12, 228, 43, 239, 187, 60, 244]) }, logicalIndex := 4, digest := (bytes [233, 101, 132, 148, 29, 173, 255, 87, 170, 115, 152, 184, 118, 32, 29, 187, 121, 72, 151, 174, 244, 84, 50, 230, 8, 34, 46, 40, 195, 220, 138, 156]) }, valueDigest := (bytes [247, 8, 91, 86, 174, 60, 198, 248, 80, 76, 136, 253, 192, 49, 138, 233, 64, 183, 153, 201, 60, 173, 121, 212, 113, 120, 175, 228, 9, 127, 13, 255]), digest := (bytes [92, 168, 23, 179, 76, 166, 139, 146, 145, 9, 165, 172, 55, 156, 201, 2, 123, 33, 172, 111, 248, 121, 159, 66, 43, 245, 188, 10, 10, 211, 195, 202]) }) }, digest := (bytes [109, 5, 213, 113, 210, 76, 156, 248, 147, 153, 138, 35, 121, 113, 104, 49, 19, 157, 148, 158, 14, 240, 128, 80, 17, 2, 201, 125, 68, 32, 49, 24]) }, packaged := { statementDigest := (bytes [166, 170, 195, 74, 0, 172, 95, 100, 244, 16, 222, 100, 193, 95, 161, 192, 124, 241, 10, 219, 96, 214, 153, 201, 134, 183, 49, 59, 206, 195, 51, 206]), proofDigest := (bytes [234, 202, 128, 112, 130, 120, 16, 174, 238, 58, 13, 219, 178, 73, 57, 34, 85, 235, 130, 83, 18, 157, 102, 239, 174, 219, 226, 115, 193, 26, 154, 35]) }, digest := (bytes [53, 129, 152, 171, 12, 185, 8, 176, 222, 244, 34, 155, 41, 246, 204, 193, 27, 51, 167, 35, 60, 210, 247, 205, 13, 30, 235, 238, 137, 43, 209, 239]) }
    , digest := (bytes [134, 6, 74, 102, 60, 207, 81, 179, 42, 149, 224, 30, 111, 152, 122, 230, 149, 119, 220, 106, 229, 132, 67, 229, 113, 234, 105, 43, 219, 157, 32, 239])
  }

def stepComposition : StepCompositionSurfaceView :=
  {
    stage1SemanticsDigest := (bytes [191, 60, 207, 142, 2, 114, 190, 38, 5, 135, 231, 36, 81, 254, 207, 62, 128, 198, 42, 239, 139, 52, 222, 11, 198, 252, 153, 6, 86, 191, 88, 129])
    , stage2SemanticsDigest := (bytes [137, 195, 246, 219, 70, 227, 48, 210, 143, 8, 247, 98, 105, 43, 57, 87, 6, 131, 205, 96, 31, 122, 156, 175, 233, 81, 55, 55, 87, 13, 2, 122])
    , stage2TemporalDigest := (bytes [144, 57, 60, 147, 57, 107, 146, 148, 125, 231, 133, 111, 183, 196, 186, 145, 128, 39, 219, 237, 85, 174, 166, 55, 110, 62, 232, 234, 234, 195, 168, 149])
    , stage3SemanticsDigest := (bytes [2, 98, 244, 254, 249, 180, 251, 77, 151, 107, 132, 46, 149, 159, 135, 249, 181, 108, 88, 176, 96, 120, 174, 170, 183, 230, 82, 229, 217, 100, 11, 245])
    , rootExecutionDigest := (bytes [26, 54, 39, 123, 40, 48, 2, 200, 251, 250, 238, 160, 55, 66, 94, 122, 133, 15, 69, 148, 123, 89, 163, 221, 5, 8, 20, 202, 64, 38, 112, 222])
    , preparedStepBindingsDigest := (bytes [91, 117, 19, 85, 154, 0, 166, 170, 125, 60, 174, 129, 137, 154, 174, 169, 226, 246, 107, 48, 0, 2, 213, 88, 23, 96, 42, 187, 137, 2, 41, 26])
    , rowChunkRoutesDigest := (bytes [17, 91, 99, 15, 11, 236, 55, 95, 29, 64, 142, 221, 223, 108, 122, 237, 32, 185, 12, 250, 217, 143, 221, 95, 118, 207, 92, 60, 104, 225, 196, 181])
    , realRowCount := 5
    , preparedStepCount := 5
    , firstRealStepIndex := 0
    , lastRealStepIndex := 4
    , initialPc := 0
    , finalPc := 20
    , halted := true
    , digest := (bytes [121, 57, 119, 191, 31, 58, 76, 117, 164, 240, 200, 84, 185, 71, 88, 214, 40, 205, 196, 115, 48, 186, 203, 146, 158, 246, 19, 253, 12, 111, 83, 35])
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
    name := "native_word_arith_chain_ecall"
    , source := {
  manifest := { name := "native_word_arith_chain_ecall", fixtureId := "native_word_arith_chain_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , startPc := 0
  , programWords := [4293918875, 2130203, 4293563, 1080198203, 115]
  , initialRegisters := [0, 0, 0, 2147483647, 2, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , initialMemory := []
  , transcriptSeed := (bytes [114, 118, 54, 52, 105, 109, 45, 110, 97, 116, 105, 118, 101, 45, 119, 111, 114, 100, 45, 97, 114, 105, 116, 104, 45, 118, 49])
}
    , derived := {
  manifest := { name := "native_word_arith_chain_ecall", fixtureId := "native_word_arith_chain_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , executionRows := [{
  traceIndex := 0
  , stepIndex := 0
  , sequenceIndex := 0
  , pc := 0
  , nextPc := 4
  , word := 4293918875
  , opcode := .addiw
  , traceOpcode := (some .addiw)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 0
  , rs1Value := 0
  , rs2 := 0
  , rs2Value := 0
  , rd := 1
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
  traceIndex := 1
  , stepIndex := 1
  , sequenceIndex := 0
  , pc := 4
  , nextPc := 8
  , word := 2130203
  , opcode := .addiw
  , traceOpcode := (some .addiw)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 1
  , rs1Value := 18446744073709551615
  , rs2 := 0
  , rs2Value := 0
  , rd := 2
  , rdBefore := 0
  , rdAfter := 1
  , imm := 2
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
  traceIndex := 2
  , stepIndex := 2
  , sequenceIndex := 0
  , pc := 8
  , nextPc := 12
  , word := 4293563
  , opcode := .addw
  , traceOpcode := (some .addw)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 3
  , rs1Value := 2147483647
  , rs2 := 4
  , rs2Value := 2
  , rd := 7
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
  , word := 1080198203
  , opcode := .subw
  , traceOpcode := (some .subw)
  , traceVirtualOpcode := none
  , family := .nativeAlu
  , rs1 := 5
  , rs1Value := 0
  , rs2 := 6
  , rs2Value := 1
  , rd := 8
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
  , stage1 := { rows := [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 4293918875, opcode := .addiw, traceOpcode := (some .addiw), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 4, aluResult := 18446744073709551615, effectiveAddr := none, writesRd := true, rd := 1, rdAfter := 18446744073709551615, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 2130203, opcode := .addiw, traceOpcode := (some .addiw), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 8, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 2, rdAfter := 1, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 4293563, opcode := .addw, traceOpcode := (some .addw), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 12, aluResult := 18446744071562067969, effectiveAddr := none, writesRd := true, rd := 7, rdAfter := 18446744071562067969, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 12, fetchedWord := 1080198203, opcode := .subw, traceOpcode := (some .subw), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 16, aluResult := 18446744073709551615, effectiveAddr := none, writesRd := true, rd := 8, rdAfter := 18446744073709551615, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 4, stepIndex := 4, sequenceIndex := 0, fetchPc := 16, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 20, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }] }
  , stage2 := {
  registerReads := [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 0, value := 0 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 1, value := 18446744073709551615 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 3, value := 2147483647 }, { traceIndex := 2, stepIndex := 2, role := .rs2, reg := 4, value := 2 }, { traceIndex := 3, stepIndex := 3, role := .rs1, reg := 5, value := 0 }, { traceIndex := 3, stepIndex := 3, role := .rs2, reg := 6, value := 1 }]
  , registerWrites := [{ traceIndex := 0, stepIndex := 0, reg := 1, previous := 0, next := 18446744073709551615 }, { traceIndex := 1, stepIndex := 1, reg := 2, previous := 0, next := 1 }, { traceIndex := 2, stepIndex := 2, reg := 7, previous := 0, next := 18446744071562067969 }, { traceIndex := 3, stepIndex := 3, reg := 8, previous := 0, next := 18446744073709551615 }]
  , ramEvents := []
  , twistLinks := [{ traceIndex := 0, stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 1, family := .nativeAlu, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 2, family := .nativeAlu, routedWriteValue := (some 18446744071562067969), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 3, family := .nativeAlu, routedWriteValue := (some 18446744073709551615), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 4, stepIndex := 4, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]
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
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 110, 97, 116, 105, 118, 101, 45, 119, 111, 114, 100, 45, 97, 114, 105, 116, 104, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [32194994931658615, 54383637722217, 94828755958258816, 10905788041622594868, 8841251816071870994, 13391653407446453246, 17446101127387435910, 7137168547377178156], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [110, 97, 116, 105, 118, 101, 95, 119, 111, 114, 100, 95, 97, 114, 105, 116, 104, 95, 99, 104, 97, 105, 110, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [32194994931658615, 54383637722217, 94828755958258816, 10905788041622594868, 8841251816071870994, 13391653407446453246, 17446101127387435910, 7137168547377178156], absorbed := 2 }
  , cursorAfter := { stateWords := [108, 8046472682260722215, 11003244355940537497, 8262967534387851701, 397115538058000933, 14291341217137120322, 5063051282974981007, 6543922063873665818], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [4293918875, 2130203, 4293563, 1080198203, 115]
  , cursorBefore := { stateWords := [108, 8046472682260722215, 11003244355940537497, 8262967534387851701, 397115538058000933, 14291341217137120322, 5063051282974981007, 6543922063873665818], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 6311794259304343875, 786608718250716959, 6100874164208755578, 2245851268550729477, 2299296669935983130, 2102865596656109285, 12771573547685203882], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 0, 0, 2147483647, 2, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [0, 6311794259304343875, 786608718250716959, 6100874164208755578, 2245851268550729477, 2299296669935983130, 2102865596656109285, 12771573547685203882], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 0, 0, 7729746327826397575, 6599925485313333755, 9380419606129479895, 6316302456827070885, 16537807392675284847], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [0, 0, 0, 7729746327826397575, 6599925485313333755, 9380419606129479895, 6316302456827070885, 16537807392675284847], absorbed := 3 }
  , cursorAfter := { stateWords := [0, 12812810021020622332, 16771512372732572291, 17691475649520698636, 7640299194629275762, 10369745949424242134, 17621312550387929647, 16140505857922087759], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [92, 172, 22, 138, 218, 1, 129, 66, 224, 89, 66, 175, 77, 144, 188, 74, 225, 81, 33, 159, 113, 152, 248, 210, 237, 253, 25, 73, 246, 251, 115, 40])
  , u64s := []
  , cursorBefore := { stateWords := [0, 12812810021020622332, 16771512372732572291, 17691475649520698636, 7640299194629275762, 10369745949424242134, 17621312550387929647, 16140505857922087759], absorbed := 1 }
  , cursorAfter := { stateWords := [7954902538515988277, 304032984545023206, 10859090316681308649, 1051498967781084287, 15597103504361850509, 7639111287890164627, 1032102716464711104, 4950509479344129651], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [7954902538515988277, 304032984545023206, 10859090316681308649, 1051498967781084287, 15597103504361850509, 7639111287890164627, 1032102716464711104, 4950509479344129651], absorbed := 0 }
  , cursorAfter := { stateWords := [10558873659545640745, 7460298059074088280, 12827188633621840837, 16788346924928290626, 9765819397153587279, 79730547694703652, 6899519008508010761, 18355073430232124729], absorbed := 0 }
  , challengeOutput := (some 10558873659545640745)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [49, 161, 13, 124, 3, 254, 251, 63, 149, 85, 118, 87, 149, 41, 33, 106, 239, 224, 235, 122, 124, 115, 70, 243, 63, 43, 7, 106, 43, 13, 29, 169])
  , u64s := []
  , cursorBefore := { stateWords := [10558873659545640745, 7460298059074088280, 12827188633621840837, 16788346924928290626, 9765819397153587279, 79730547694703652, 6899519008508010761, 18355073430232124729], absorbed := 0 }
  , cursorAfter := { stateWords := [35038050621811233, 29844229869225587, 2837253419, 14854758017280570924, 4753849291562509336, 17737008842207180361, 10221970253532858519, 13455280429100110128], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [35038050621811233, 29844229869225587, 2837253419, 14854758017280570924, 4753849291562509336, 17737008842207180361, 10221970253532858519, 13455280429100110128], absorbed := 3 }
  , cursorAfter := { stateWords := [8944266866017282416, 9083455127191587360, 15870788478240046116, 261411158637596961, 13497636338210299392, 7056894553339275005, 3922081986380945488, 7961356374822133845], absorbed := 0 }
  , challengeOutput := (some 8944266866017282416)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [8944266866017282416, 9083455127191587360, 15870788478240046116, 261411158637596961, 13497636338210299392, 7056894553339275005, 3922081986380945488, 7961356374822133845], absorbed := 0 }
  , cursorAfter := { stateWords := [13660259816919425627, 5443145891308723178, 3950869399485430737, 3465726298619999636, 17114001414304282808, 18361815826803384454, 11206596754129769351, 1492281674423093212], absorbed := 0 }
  , challengeOutput := (some 13660259816919425627)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [76, 67, 196, 204, 58, 160, 47, 32, 132, 98, 117, 189, 46, 75, 241, 54, 49, 21, 50, 72, 228, 63, 229, 152, 90, 2, 115, 124, 210, 7, 178, 52])
  , u64s := []
  , cursorBefore := { stateWords := [13660259816919425627, 5443145891308723178, 3950869399485430737, 3465726298619999636, 17114001414304282808, 18361815826803384454, 11206596754129769351, 1492281674423093212], absorbed := 0 }
  , cursorAfter := { stateWords := [64255674631141105, 35029351059219775, 884082642, 10963030985313958329, 9231525161699478297, 7184243167855036890, 4915572341140035318, 1204668759425625746], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [64255674631141105, 35029351059219775, 884082642, 10963030985313958329, 9231525161699478297, 7184243167855036890, 4915572341140035318, 1204668759425625746], absorbed := 3 }
  , cursorAfter := { stateWords := [17263612136838009662, 13675245253044482734, 18189201110177164880, 10969121987671422452, 5530659556502629132, 756279455560595800, 13966163538592164266, 5192032729948296536], absorbed := 0 }
  , challengeOutput := (some 17263612136838009662)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [2, 183, 132, 95, 231, 115, 83, 2, 8, 179, 51, 169, 210, 224, 230, 178, 60, 35, 73, 58, 195, 121, 109, 163, 86, 206, 95, 244, 250, 18, 169, 79])
  , u64s := []
  , cursorBefore := { stateWords := [17263612136838009662, 13675245253044482734, 18189201110177164880, 10969121987671422452, 5530659556502629132, 756279455560595800, 13966163538592164266, 5192032729948296536], absorbed := 0 }
  , cursorAfter := { stateWords := [54951706256782054, 68785234138852729, 1336480506, 5717146340749330168, 6508766975942125165, 17493974153028014702, 15761774315220503075, 2603304443319835626], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [12, 149, 33, 173, 171, 165, 54, 175, 9, 253, 234, 193, 13, 243, 189, 0, 121, 246, 75, 0, 67, 138, 71, 71, 204, 153, 161, 108, 26, 195, 251, 119])
  , u64s := []
  , cursorBefore := { stateWords := [54951706256782054, 68785234138852729, 1336480506, 5717146340749330168, 6508766975942125165, 17493974153028014702, 15761774315220503075, 2603304443319835626], absorbed := 3 }
  , cursorAfter := { stateWords := [18859149697286333, 30576979414042506, 2012988186, 7418949465302731250, 7786578273095239209, 5462410187322239503, 2647912887876074060, 3741130172918810497], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [210, 76, 200, 21, 4, 69, 15, 25, 203, 33, 125, 2, 33, 189, 7, 17, 57, 53, 132, 53, 135, 156, 153, 112, 132, 50, 0, 120, 169, 124, 149, 40])
  , u64s := []
  , cursorBefore := { stateWords := [18859149697286333, 30576979414042506, 2012988186, 7418949465302731250, 7786578273095239209, 5462410187322239503, 2647912887876074060, 3741130172918810497], absorbed := 3 }
  , cursorAfter := { stateWords := [38057963800826119, 33777214175615388, 680885417, 338818507502728935, 10922502945274482062, 3756922488108390693, 4388242078426305734, 50998364504691158], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [38057963800826119, 33777214175615388, 680885417, 338818507502728935, 10922502945274482062, 3756922488108390693, 4388242078426305734, 50998364504691158], absorbed := 3 }
  , cursorAfter := { stateWords := [1122637793534170640, 8865404261055412735, 15682186193226367635, 11087978790780904066, 10088335413447909684, 12063018804202447092, 7846450942697976053, 17981690237755468257], absorbed := 0 }
  , challengeOutput := (some 1122637793534170640)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [1122637793534170640, 8865404261055412735, 15682186193226367635, 11087978790780904066, 10088335413447909684, 12063018804202447092, 7846450942697976053, 17981690237755468257], absorbed := 0 }
  , cursorAfter := { stateWords := [17984682559556005781, 6806124958797347119, 3740396972043565589, 8535075898710175415, 13795396721678529870, 8029699745718555254, 13832823551608342223, 14647473703533060395], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [149, 175, 127, 64, 128, 109, 150, 249, 47, 57, 9, 242, 150, 54, 116, 94, 21, 122, 154, 133, 58, 143, 232, 51, 183, 46, 158, 33, 79, 174, 114, 118]))
}]
}
  , kernel := {
  root0Digest := (bytes [92, 172, 22, 138, 218, 1, 129, 66, 224, 89, 66, 175, 77, 144, 188, 74, 225, 81, 33, 159, 113, 152, 248, 210, 237, 253, 25, 73, 246, 251, 115, 40])
  , stage1Digest := (bytes [49, 161, 13, 124, 3, 254, 251, 63, 149, 85, 118, 87, 149, 41, 33, 106, 239, 224, 235, 122, 124, 115, 70, 243, 63, 43, 7, 106, 43, 13, 29, 169])
  , stage2Digest := (bytes [76, 67, 196, 204, 58, 160, 47, 32, 132, 98, 117, 189, 46, 75, 241, 54, 49, 21, 50, 72, 228, 63, 229, 152, 90, 2, 115, 124, 210, 7, 178, 52])
  , stage3Digest := (bytes [2, 183, 132, 95, 231, 115, 83, 2, 8, 179, 51, 169, 210, 224, 230, 178, 60, 35, 73, 58, 195, 121, 109, 163, 86, 206, 95, 244, 250, 18, 169, 79])
  , executionDigest := (bytes [12, 149, 33, 173, 171, 165, 54, 175, 9, 253, 234, 193, 13, 243, 189, 0, 121, 246, 75, 0, 67, 138, 71, 71, 204, 153, 161, 108, 26, 195, 251, 119])
  , finalStateDigest := (bytes [210, 76, 200, 21, 4, 69, 15, 25, 203, 33, 125, 2, 33, 189, 7, 17, 57, 53, 132, 53, 135, 156, 153, 112, 132, 50, 0, 120, 169, 124, 149, 40])
  , stage1Mix := 10558873659545640745
  , stage2RegMix := 8944266866017282416
  , stage2RamMix := 13660259816919425627
  , stage3ContinuityMix := 17263612136838009662
  , kernelFinalMix := 1122637793534170640
  , transcriptFinalDigest := (bytes [149, 175, 127, 64, 128, 109, 150, 249, 47, 57, 9, 242, 150, 54, 116, 94, 21, 122, 154, 133, 58, 143, 232, 51, 183, 46, 158, 33, 79, 174, 114, 118])
  , finalPc := 20
  , finalRegisters := [0, 18446744073709551615, 1, 2147483647, 2, 0, 1, 18446744071562067969, 18446744073709551615, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , finalMemory := []
  , halted := true
}
}
    , kernelProof := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "native_word_arith_chain_ecall", fixtureId := "native_word_arith_chain_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , executionDigest := (bytes [12, 149, 33, 173, 171, 165, 54, 175, 9, 253, 234, 193, 13, 243, 189, 0, 121, 246, 75, 0, 67, 138, 71, 71, 204, 153, 161, 108, 26, 195, 251, 119])
  , shape := { executionRowCount := 5, realRowCount := 5, effectRowCount := 5, commitRowCount := 5, digest := (bytes [11, 168, 18, 205, 239, 69, 109, 190, 207, 168, 250, 196, 121, 176, 87, 55, 1, 249, 85, 208, 31, 220, 81, 235, 69, 31, 18, 110, 121, 74, 49, 211]) }
  , digest := (bytes [237, 198, 241, 48, 7, 169, 70, 117, 171, 145, 195, 33, 223, 53, 103, 217, 135, 47, 118, 29, 78, 225, 253, 145, 100, 107, 48, 71, 135, 126, 59, 181])
}
  , stages := { summary := { stage1RowCount := 5, stage2RegisterReadCount := 6, stage2RegisterWriteCount := 4, stage2RamEventCount := 0, stage2TwistLinkCount := 5, stage3ContinuityCount := 5, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [141, 225, 99, 203, 82, 127, 237, 231, 19, 157, 248, 93, 40, 201, 74, 206, 185, 2, 158, 150, 189, 173, 215, 197, 174, 38, 24, 73, 140, 149, 161, 210]) }, digest := (bytes [94, 183, 250, 237, 90, 36, 42, 5, 30, 222, 209, 88, 215, 36, 250, 190, 9, 95, 62, 125, 98, 81, 23, 75, 18, 45, 20, 187, 243, 210, 134, 195]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [5, 245, 86, 44, 48, 35, 206, 23, 23, 151, 216, 75, 178, 190, 248, 233, 7, 179, 116, 14, 179, 235, 120, 40, 233, 57, 73, 158, 114, 7, 98, 165]), stage1Digest := (bytes [120, 45, 134, 165, 38, 22, 189, 162, 15, 159, 62, 105, 182, 125, 90, 92, 125, 105, 17, 254, 251, 89, 25, 53, 41, 5, 239, 10, 228, 25, 134, 212]), stage2Digest := (bytes [140, 174, 152, 65, 127, 9, 176, 100, 246, 57, 156, 189, 188, 142, 198, 193, 111, 221, 113, 220, 203, 205, 192, 138, 193, 171, 117, 81, 112, 196, 154, 255]), stage3Digest := (bytes [203, 140, 63, 160, 179, 160, 171, 82, 223, 2, 32, 73, 21, 112, 190, 222, 133, 97, 45, 221, 193, 128, 37, 148, 220, 120, 81, 206, 4, 164, 16, 21]), transcriptDigest := (bytes [149, 175, 127, 64, 128, 109, 150, 249, 47, 57, 9, 242, 150, 54, 116, 94, 21, 122, 154, 133, 58, 143, 232, 51, 183, 46, 158, 33, 79, 174, 114, 118]), executionDigest := (bytes [12, 149, 33, 173, 171, 165, 54, 175, 9, 253, 234, 193, 13, 243, 189, 0, 121, 246, 75, 0, 67, 138, 71, 71, 204, 153, 161, 108, 26, 195, 251, 119]), digest := (bytes [136, 68, 64, 48, 69, 162, 130, 118, 13, 69, 29, 124, 40, 66, 48, 38, 133, 95, 79, 130, 16, 245, 24, 50, 7, 47, 218, 93, 202, 73, 235, 203]) }, statementDigest := (bytes [79, 157, 238, 179, 239, 65, 51, 133, 238, 206, 153, 182, 101, 77, 208, 221, 185, 192, 32, 122, 196, 223, 117, 116, 54, 12, 242, 144, 210, 37, 104, 44]), proofDigest := (bytes [77, 107, 216, 116, 214, 73, 234, 208, 109, 191, 21, 81, 234, 10, 224, 123, 55, 238, 218, 141, 192, 146, 212, 44, 129, 19, 104, 177, 253, 78, 16, 163]), digest := (bytes [24, 67, 172, 80, 154, 139, 100, 179, 186, 37, 117, 247, 148, 160, 191, 96, 193, 250, 127, 117, 89, 12, 45, 38, 60, 19, 0, 15, 5, 74, 220, 234]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [42, 28, 148, 226, 172, 23, 43, 227, 239, 241, 11, 57, 168, 79, 19, 242, 239, 206, 95, 113, 70, 47, 198, 183, 22, 102, 191, 183, 121, 181, 215, 20]), stage1Digest := (bytes [173, 33, 149, 207, 246, 124, 144, 30, 221, 155, 50, 196, 200, 246, 153, 154, 92, 39, 21, 130, 0, 14, 85, 196, 68, 61, 42, 199, 208, 35, 228, 147]), stage2Digest := (bytes [40, 195, 49, 80, 144, 193, 37, 148, 42, 214, 173, 133, 9, 128, 62, 61, 85, 4, 200, 87, 144, 38, 157, 54, 166, 133, 181, 248, 119, 11, 41, 186]), stage3Digest := (bytes [222, 201, 157, 144, 205, 9, 149, 155, 9, 164, 122, 0, 0, 97, 212, 97, 34, 22, 78, 10, 168, 239, 51, 12, 115, 132, 210, 180, 79, 66, 248, 179]), digest := (bytes [34, 229, 118, 191, 44, 225, 185, 97, 119, 232, 110, 62, 220, 242, 134, 149, 215, 79, 100, 210, 137, 43, 33, 23, 31, 184, 109, 60, 112, 19, 77, 157]) }, digest := (bytes [167, 215, 127, 189, 210, 168, 232, 105, 57, 174, 5, 55, 38, 139, 206, 201, 112, 90, 173, 216, 21, 102, 167, 254, 97, 193, 101, 156, 198, 73, 167, 58]) }
  , kernelOpening := { openingDigest := (bytes [134, 6, 74, 102, 60, 207, 81, 179, 42, 149, 224, 30, 111, 152, 122, 230, 149, 119, 220, 106, 229, 132, 67, 229, 113, 234, 105, 43, 219, 157, 32, 239]), bindings := { claimDigest := (bytes [37, 141, 200, 179, 134, 39, 202, 221, 107, 178, 217, 246, 199, 214, 186, 248, 173, 82, 127, 54, 6, 24, 181, 224, 108, 54, 65, 27, 119, 66, 54, 145]), bindingsDigest := (bytes [149, 191, 73, 110, 39, 119, 255, 151, 218, 126, 114, 100, 146, 0, 188, 23, 15, 13, 222, 104, 3, 168, 49, 106, 39, 146, 178, 236, 141, 37, 161, 65]), preparedStepsDigest := (bytes [53, 129, 152, 171, 12, 185, 8, 176, 222, 244, 34, 155, 41, 246, 204, 193, 27, 51, 167, 35, 60, 210, 247, 205, 13, 30, 235, 238, 137, 43, 209, 239]), digest := (bytes [57, 106, 249, 50, 114, 82, 172, 144, 243, 187, 158, 190, 64, 139, 167, 49, 66, 235, 56, 209, 30, 40, 159, 139, 142, 35, 165, 22, 115, 6, 111, 213]) }, digest := (bytes [180, 209, 173, 8, 241, 238, 36, 202, 102, 195, 251, 219, 15, 82, 106, 169, 144, 78, 190, 126, 19, 103, 232, 61, 87, 46, 16, 192, 192, 140, 88, 187]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [91, 117, 19, 85, 154, 0, 166, 170, 125, 60, 174, 129, 137, 154, 174, 169, 226, 246, 107, 48, 0, 2, 213, 88, 23, 96, 42, 187, 137, 2, 41, 26]), terminal := { root0Digest := (bytes [92, 172, 22, 138, 218, 1, 129, 66, 224, 89, 66, 175, 77, 144, 188, 74, 225, 81, 33, 159, 113, 152, 248, 210, 237, 253, 25, 73, 246, 251, 115, 40]), executionDigest := (bytes [12, 149, 33, 173, 171, 165, 54, 175, 9, 253, 234, 193, 13, 243, 189, 0, 121, 246, 75, 0, 67, 138, 71, 71, 204, 153, 161, 108, 26, 195, 251, 119]), finalStateDigest := (bytes [210, 76, 200, 21, 4, 69, 15, 25, 203, 33, 125, 2, 33, 189, 7, 17, 57, 53, 132, 53, 135, 156, 153, 112, 132, 50, 0, 120, 169, 124, 149, 40]), transcriptFinalDigest := (bytes [149, 175, 127, 64, 128, 109, 150, 249, 47, 57, 9, 242, 150, 54, 116, 94, 21, 122, 154, 133, 58, 143, 232, 51, 183, 46, 158, 33, 79, 174, 114, 118]), finalPc := 20, halted := true, digest := (bytes [169, 52, 131, 71, 40, 207, 253, 76, 79, 242, 88, 172, 34, 168, 24, 174, 233, 107, 52, 94, 154, 206, 178, 159, 234, 57, 35, 97, 71, 102, 35, 37]) }, digest := (bytes [48, 171, 241, 50, 149, 155, 71, 186, 48, 176, 108, 158, 198, 217, 102, 29, 101, 239, 173, 64, 150, 62, 46, 101, 234, 42, 221, 179, 207, 92, 62, 89]) }, statementDigest := (bytes [26, 78, 82, 70, 43, 25, 25, 18, 51, 112, 123, 154, 221, 133, 6, 141, 50, 225, 102, 236, 26, 65, 120, 114, 83, 135, 241, 68, 148, 19, 245, 188]), proofDigest := (bytes [83, 211, 112, 244, 44, 66, 168, 23, 6, 208, 190, 237, 168, 140, 94, 237, 1, 89, 119, 237, 156, 66, 58, 251, 150, 108, 87, 145, 28, 253, 145, 92]), digest := (bytes [203, 105, 159, 116, 170, 8, 55, 230, 195, 210, 94, 190, 244, 70, 86, 202, 206, 126, 64, 132, 255, 203, 23, 61, 84, 218, 109, 128, 217, 118, 65, 221]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [12, 128, 33, 184, 242, 229, 158, 205, 212, 22, 196, 91, 161, 165, 57, 3, 196, 29, 120, 223, 240, 72, 12, 96, 48, 101, 55, 21, 177, 142, 153, 177]), layoutVersion := 1, digest := (bytes [93, 23, 86, 205, 206, 29, 138, 233, 139, 64, 144, 44, 188, 38, 173, 57, 129, 205, 187, 114, 72, 255, 147, 152, 246, 183, 217, 134, 82, 228, 245, 143]) }, rowWidth := 38, timeLen := 5, columnDigests := [(bytes [113, 50, 60, 138, 88, 147, 143, 114, 209, 102, 140, 109, 141, 130, 13, 65, 154, 83, 29, 54, 165, 27, 195, 207, 252, 83, 167, 120, 56, 155, 143, 109]), (bytes [164, 156, 12, 202, 128, 158, 166, 79, 50, 246, 26, 100, 33, 104, 153, 108, 231, 66, 5, 3, 94, 76, 41, 81, 13, 128, 233, 62, 40, 19, 215, 212]), (bytes [104, 86, 253, 80, 246, 180, 248, 154, 56, 26, 223, 106, 196, 169, 105, 55, 112, 123, 51, 7, 215, 60, 203, 20, 133, 2, 161, 155, 25, 94, 39, 31]), (bytes [4, 37, 191, 199, 27, 131, 127, 106, 23, 23, 164, 92, 246, 105, 210, 216, 164, 185, 128, 142, 255, 92, 5, 246, 36, 198, 85, 173, 19, 19, 230, 153]), (bytes [63, 82, 148, 11, 209, 51, 62, 242, 159, 229, 6, 212, 45, 165, 107, 74, 200, 142, 213, 63, 249, 218, 45, 61, 117, 144, 214, 116, 85, 207, 59, 178]), (bytes [135, 104, 199, 153, 173, 201, 75, 134, 70, 18, 19, 189, 63, 130, 156, 52, 6, 175, 190, 48, 104, 93, 33, 237, 146, 100, 186, 232, 141, 151, 72, 215]), (bytes [226, 196, 248, 68, 93, 218, 167, 109, 161, 97, 173, 192, 140, 226, 161, 133, 128, 128, 121, 149, 231, 35, 250, 86, 108, 3, 170, 250, 242, 53, 65, 16]), (bytes [242, 242, 101, 98, 26, 91, 84, 151, 121, 175, 196, 177, 72, 163, 109, 105, 54, 47, 137, 164, 180, 216, 27, 147, 168, 81, 30, 37, 98, 14, 115, 141]), (bytes [16, 166, 173, 204, 197, 96, 81, 23, 174, 247, 123, 173, 160, 1, 215, 78, 87, 237, 64, 153, 255, 223, 20, 26, 202, 114, 66, 221, 15, 90, 40, 102]), (bytes [95, 167, 51, 135, 163, 194, 94, 133, 95, 39, 204, 239, 193, 121, 232, 160, 79, 58, 5, 1, 233, 121, 174, 139, 228, 69, 205, 116, 216, 10, 31, 69]), (bytes [241, 173, 53, 128, 105, 157, 241, 38, 55, 78, 236, 46, 128, 91, 224, 201, 53, 225, 75, 79, 208, 168, 40, 94, 162, 246, 121, 91, 155, 167, 56, 195]), (bytes [130, 73, 215, 107, 115, 238, 24, 240, 163, 172, 98, 239, 249, 7, 88, 74, 134, 169, 33, 214, 106, 105, 129, 148, 132, 138, 211, 59, 46, 99, 155, 6]), (bytes [125, 74, 15, 65, 60, 142, 27, 20, 181, 112, 204, 235, 34, 180, 170, 93, 149, 71, 125, 7, 245, 82, 48, 159, 125, 51, 165, 153, 20, 14, 42, 41]), (bytes [47, 127, 69, 74, 208, 2, 35, 122, 30, 16, 16, 195, 229, 93, 160, 57, 71, 210, 192, 207, 192, 225, 37, 232, 26, 169, 245, 182, 141, 197, 100, 97]), (bytes [199, 85, 136, 172, 196, 182, 121, 174, 25, 97, 234, 74, 98, 160, 163, 107, 154, 194, 63, 232, 61, 118, 173, 180, 48, 227, 165, 168, 197, 141, 243, 230]), (bytes [218, 15, 164, 119, 26, 89, 153, 76, 195, 50, 55, 158, 39, 57, 253, 24, 64, 230, 89, 54, 164, 47, 223, 90, 24, 194, 243, 188, 112, 39, 74, 0]), (bytes [249, 165, 44, 168, 18, 125, 65, 76, 51, 110, 93, 193, 12, 212, 163, 81, 53, 26, 162, 66, 63, 100, 116, 243, 112, 137, 118, 14, 176, 24, 222, 159]), (bytes [11, 185, 133, 252, 50, 244, 35, 237, 167, 173, 175, 155, 13, 76, 146, 252, 114, 4, 198, 228, 91, 62, 90, 251, 253, 108, 66, 173, 181, 43, 114, 60]), (bytes [118, 104, 94, 12, 171, 3, 100, 43, 163, 51, 98, 0, 105, 201, 187, 207, 164, 190, 117, 22, 243, 3, 26, 197, 37, 180, 195, 107, 243, 137, 220, 124]), (bytes [164, 26, 251, 214, 133, 166, 36, 43, 117, 5, 240, 52, 163, 40, 219, 81, 176, 185, 168, 189, 219, 54, 240, 69, 240, 249, 122, 226, 140, 80, 170, 67]), (bytes [166, 212, 193, 165, 216, 77, 223, 22, 85, 148, 36, 46, 240, 197, 91, 192, 178, 249, 84, 99, 56, 189, 17, 175, 26, 146, 194, 235, 103, 203, 78, 106]), (bytes [117, 242, 101, 249, 21, 218, 127, 164, 230, 14, 233, 247, 199, 35, 201, 180, 129, 56, 152, 49, 20, 39, 58, 252, 143, 181, 103, 38, 215, 227, 205, 255]), (bytes [222, 141, 194, 19, 109, 181, 115, 128, 236, 90, 109, 50, 95, 37, 244, 239, 168, 246, 17, 195, 87, 245, 230, 227, 255, 210, 73, 185, 49, 105, 109, 248]), (bytes [6, 254, 110, 187, 235, 232, 26, 224, 177, 208, 223, 63, 151, 116, 244, 68, 181, 38, 182, 164, 169, 160, 199, 77, 149, 179, 23, 120, 151, 178, 148, 93]), (bytes [140, 52, 163, 89, 55, 243, 29, 183, 25, 178, 87, 57, 109, 247, 133, 42, 53, 246, 249, 12, 226, 144, 235, 217, 39, 192, 123, 2, 224, 49, 95, 76]), (bytes [181, 45, 69, 158, 65, 145, 43, 151, 232, 63, 217, 66, 85, 8, 179, 187, 244, 58, 114, 255, 75, 18, 179, 199, 200, 112, 8, 236, 243, 16, 186, 249]), (bytes [102, 140, 9, 232, 29, 171, 94, 46, 215, 126, 135, 247, 204, 222, 182, 180, 95, 97, 36, 110, 94, 7, 203, 183, 0, 33, 2, 183, 177, 137, 38, 65]), (bytes [167, 92, 69, 232, 129, 215, 150, 22, 142, 134, 186, 133, 122, 187, 98, 237, 109, 67, 169, 68, 16, 1, 0, 92, 129, 181, 145, 172, 134, 6, 57, 205]), (bytes [100, 60, 107, 51, 83, 82, 9, 140, 176, 45, 55, 192, 93, 71, 222, 103, 180, 46, 64, 171, 208, 105, 248, 228, 140, 207, 120, 66, 72, 214, 145, 73]), (bytes [231, 38, 189, 225, 191, 28, 138, 109, 137, 172, 136, 41, 0, 71, 10, 98, 82, 251, 63, 57, 134, 215, 207, 171, 22, 74, 131, 24, 248, 187, 249, 139]), (bytes [97, 115, 66, 52, 209, 119, 244, 26, 211, 179, 72, 158, 73, 50, 167, 139, 193, 248, 17, 168, 194, 18, 40, 36, 247, 217, 33, 69, 229, 217, 187, 137]), (bytes [104, 29, 194, 189, 239, 145, 194, 228, 166, 76, 154, 100, 169, 199, 26, 134, 252, 202, 252, 43, 213, 142, 242, 213, 255, 181, 81, 2, 47, 120, 226, 78]), (bytes [235, 49, 191, 128, 17, 252, 43, 130, 234, 138, 63, 235, 22, 122, 39, 9, 154, 168, 135, 151, 54, 180, 125, 133, 235, 6, 32, 243, 247, 58, 14, 141]), (bytes [203, 190, 166, 159, 209, 140, 180, 196, 75, 57, 130, 2, 89, 126, 203, 127, 16, 89, 187, 132, 95, 49, 171, 164, 127, 162, 189, 129, 74, 157, 57, 123]), (bytes [133, 97, 222, 172, 108, 224, 100, 38, 133, 82, 44, 62, 153, 42, 213, 206, 217, 200, 97, 197, 218, 106, 13, 74, 224, 64, 192, 64, 26, 89, 139, 91]), (bytes [170, 154, 45, 6, 188, 185, 88, 196, 229, 167, 43, 205, 233, 108, 55, 179, 176, 186, 4, 153, 204, 108, 150, 247, 84, 185, 23, 182, 159, 241, 182, 243]), (bytes [115, 151, 31, 42, 19, 22, 27, 97, 49, 213, 126, 77, 7, 8, 14, 238, 203, 249, 232, 13, 112, 30, 96, 119, 42, 123, 67, 145, 170, 250, 236, 255]), (bytes [142, 185, 27, 84, 132, 190, 160, 121, 218, 162, 8, 170, 126, 198, 197, 139, 11, 168, 143, 88, 101, 75, 56, 240, 14, 204, 255, 67, 55, 121, 123, 195])], familyDigest := (bytes [12, 128, 33, 184, 242, 229, 158, 205, 212, 22, 196, 91, 161, 165, 57, 3, 196, 29, 120, 223, 240, 72, 12, 96, 48, 101, 55, 21, 177, 142, 153, 177]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [12, 128, 33, 184, 242, 229, 158, 205, 212, 22, 196, 91, 161, 165, 57, 3, 196, 29, 120, 223, 240, 72, 12, 96, 48, 101, 55, 21, 177, 142, 153, 177]), layoutVersion := 1, digest := (bytes [93, 23, 86, 205, 206, 29, 138, 233, 139, 64, 144, 44, 188, 38, 173, 57, 129, 205, 187, 114, 72, 255, 147, 152, 246, 183, 217, 134, 82, 228, 245, 143]) }, logicalIndex := 0, digest := (bytes [40, 153, 170, 234, 161, 158, 8, 182, 204, 130, 187, 230, 253, 2, 237, 116, 148, 12, 32, 189, 142, 149, 79, 41, 100, 176, 44, 56, 190, 210, 171, 125]) }, valueDigest := (bytes [59, 110, 73, 184, 21, 134, 14, 247, 63, 174, 178, 199, 142, 253, 82, 19, 165, 139, 8, 196, 235, 194, 3, 121, 51, 124, 231, 35, 211, 16, 32, 52]), digest := (bytes [107, 83, 143, 13, 16, 195, 28, 191, 30, 23, 48, 73, 127, 45, 146, 223, 29, 40, 32, 36, 96, 122, 180, 245, 149, 85, 174, 218, 110, 201, 84, 5]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [12, 128, 33, 184, 242, 229, 158, 205, 212, 22, 196, 91, 161, 165, 57, 3, 196, 29, 120, 223, 240, 72, 12, 96, 48, 101, 55, 21, 177, 142, 153, 177]), layoutVersion := 1, digest := (bytes [93, 23, 86, 205, 206, 29, 138, 233, 139, 64, 144, 44, 188, 38, 173, 57, 129, 205, 187, 114, 72, 255, 147, 152, 246, 183, 217, 134, 82, 228, 245, 143]) }, logicalIndex := 4, digest := (bytes [194, 12, 167, 103, 234, 76, 20, 49, 226, 134, 176, 114, 169, 245, 18, 142, 145, 27, 92, 50, 250, 244, 171, 207, 55, 205, 46, 129, 52, 49, 92, 99]) }, valueDigest := (bytes [247, 8, 91, 86, 174, 60, 198, 248, 80, 76, 136, 253, 192, 49, 138, 233, 64, 183, 153, 201, 60, 173, 121, 212, 113, 120, 175, 228, 9, 127, 13, 255]), digest := (bytes [185, 244, 106, 195, 5, 46, 56, 8, 140, 244, 184, 72, 72, 170, 174, 7, 161, 225, 151, 205, 116, 150, 66, 233, 90, 246, 89, 180, 145, 7, 221, 136]) }), digest := (bytes [213, 185, 142, 63, 202, 223, 100, 7, 247, 41, 30, 235, 165, 158, 145, 96, 6, 239, 117, 42, 138, 247, 217, 129, 87, 17, 62, 125, 247, 55, 111, 115]) }
  , rootLaneCommitment := { timeLen := 5, commitments := { commitmentCount := 38, digest := (bytes [167, 134, 219, 115, 157, 1, 205, 216, 94, 200, 200, 185, 201, 29, 37, 30, 211, 219, 133, 246, 131, 127, 123, 204, 232, 247, 119, 255, 193, 111, 1, 3]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [167, 134, 219, 115, 157, 1, 205, 216, 94, 200, 200, 185, 201, 29, 37, 30, 211, 219, 133, 246, 131, 127, 123, 204, 232, 247, 119, 255, 193, 111, 1, 3]), layoutVersion := 3, digest := (bytes [144, 1, 205, 205, 173, 23, 147, 240, 200, 216, 98, 186, 0, 44, 155, 17, 176, 29, 96, 184, 112, 37, 176, 54, 69, 12, 228, 43, 239, 187, 60, 244]) }, logicalIndex := 0, digest := (bytes [164, 80, 240, 165, 212, 106, 222, 27, 57, 122, 141, 225, 118, 133, 86, 173, 131, 2, 96, 85, 250, 193, 23, 124, 202, 22, 99, 160, 205, 211, 23, 21]) }, valueDigest := (bytes [59, 110, 73, 184, 21, 134, 14, 247, 63, 174, 178, 199, 142, 253, 82, 19, 165, 139, 8, 196, 235, 194, 3, 121, 51, 124, 231, 35, 211, 16, 32, 52]), digest := (bytes [239, 168, 197, 147, 208, 9, 141, 65, 93, 2, 147, 148, 71, 241, 158, 64, 43, 208, 77, 43, 187, 99, 136, 72, 199, 241, 17, 207, 187, 5, 220, 233]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [167, 134, 219, 115, 157, 1, 205, 216, 94, 200, 200, 185, 201, 29, 37, 30, 211, 219, 133, 246, 131, 127, 123, 204, 232, 247, 119, 255, 193, 111, 1, 3]), layoutVersion := 3, digest := (bytes [144, 1, 205, 205, 173, 23, 147, 240, 200, 216, 98, 186, 0, 44, 155, 17, 176, 29, 96, 184, 112, 37, 176, 54, 69, 12, 228, 43, 239, 187, 60, 244]) }, logicalIndex := 4, digest := (bytes [233, 101, 132, 148, 29, 173, 255, 87, 170, 115, 152, 184, 118, 32, 29, 187, 121, 72, 151, 174, 244, 84, 50, 230, 8, 34, 46, 40, 195, 220, 138, 156]) }, valueDigest := (bytes [247, 8, 91, 86, 174, 60, 198, 248, 80, 76, 136, 253, 192, 49, 138, 233, 64, 183, 153, 201, 60, 173, 121, 212, 113, 120, 175, 228, 9, 127, 13, 255]), digest := (bytes [92, 168, 23, 179, 76, 166, 139, 146, 145, 9, 165, 172, 55, 156, 201, 2, 123, 33, 172, 111, 248, 121, 159, 66, 43, 245, 188, 10, 10, 211, 195, 202]) }), digest := (bytes [119, 102, 74, 99, 233, 1, 220, 252, 149, 243, 0, 95, 112, 208, 28, 185, 56, 110, 175, 7, 228, 222, 66, 2, 6, 250, 230, 147, 202, 195, 106, 115]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [213, 185, 142, 63, 202, 223, 100, 7, 247, 41, 30, 235, 165, 158, 145, 96, 6, 239, 117, 42, 138, 247, 217, 129, 87, 17, 62, 125, 247, 55, 111, 115]), rootLaneCommitmentDigest := (bytes [119, 102, 74, 99, 233, 1, 220, 252, 149, 243, 0, 95, 112, 208, 28, 185, 56, 110, 175, 7, 228, 222, 66, 2, 6, 250, 230, 147, 202, 195, 106, 115]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 5, digest := (bytes [7, 132, 62, 118, 193, 167, 35, 55, 254, 245, 39, 205, 152, 212, 106, 245, 47, 132, 119, 36, 155, 239, 98, 59, 213, 78, 70, 207, 183, 105, 29, 39]) }, statementDigest := (bytes [119, 120, 234, 77, 68, 190, 62, 147, 225, 68, 229, 74, 209, 203, 43, 127, 39, 96, 171, 195, 168, 197, 18, 37, 146, 54, 179, 203, 150, 199, 213, 96]), proofDigest := (bytes [162, 235, 108, 114, 17, 211, 197, 55, 156, 142, 12, 232, 226, 57, 188, 57, 144, 131, 54, 251, 242, 149, 148, 126, 25, 211, 20, 223, 141, 64, 101, 188]), digest := (bytes [222, 82, 238, 140, 53, 221, 99, 9, 8, 44, 143, 219, 247, 90, 225, 228, 22, 134, 48, 59, 224, 198, 23, 39, 187, 209, 66, 75, 107, 204, 90, 253]) }
  , digest := (bytes [191, 175, 215, 16, 74, 149, 88, 119, 244, 156, 42, 255, 251, 140, 78, 22, 184, 135, 209, 230, 234, 193, 124, 119, 86, 184, 225, 140, 213, 163, 111, 127])
}
    , exportedProof := {
  claim := {
  accepted := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , statement := { proofStatementDigest := (bytes [151, 64, 94, 196, 181, 102, 86, 239, 147, 153, 73, 133, 113, 232, 103, 42, 130, 178, 220, 92, 93, 84, 20, 2, 198, 240, 164, 43, 138, 161, 34, 106]), kernelOpeningDigest := (bytes [180, 209, 173, 8, 241, 238, 36, 202, 102, 195, 251, 219, 15, 82, 106, 169, 144, 78, 190, 126, 19, 103, 232, 61, 87, 46, 16, 192, 192, 140, 88, 187]), digest := (bytes [202, 189, 206, 160, 207, 14, 4, 165, 16, 130, 247, 229, 48, 201, 145, 70, 104, 53, 169, 236, 60, 118, 64, 194, 141, 225, 131, 184, 208, 32, 50, 25]) }
  , mainLane := { mainLaneBundleDigest := (bytes [222, 82, 238, 140, 53, 221, 99, 9, 8, 44, 143, 219, 247, 90, 225, 228, 22, 134, 48, 59, 224, 198, 23, 39, 187, 209, 66, 75, 107, 204, 90, 253]), digest := (bytes [87, 152, 179, 127, 87, 224, 203, 69, 49, 14, 152, 242, 26, 86, 43, 223, 55, 130, 127, 21, 190, 140, 112, 49, 160, 84, 25, 210, 249, 117, 12, 198]) }
  , terminal := { finalStateDigest := (bytes [210, 76, 200, 21, 4, 69, 15, 25, 203, 33, 125, 2, 33, 189, 7, 17, 57, 53, 132, 53, 135, 156, 153, 112, 132, 50, 0, 120, 169, 124, 149, 40]), finalPc := 20, halted := true, digest := (bytes [34, 51, 39, 156, 194, 141, 142, 101, 226, 114, 44, 92, 171, 211, 129, 122, 46, 89, 112, 7, 211, 98, 219, 85, 148, 241, 33, 145, 250, 73, 186, 142]) }
  , digest := (bytes [215, 118, 2, 103, 231, 2, 243, 156, 11, 39, 204, 119, 74, 147, 175, 156, 215, 134, 28, 2, 222, 121, 233, 50, 52, 196, 249, 36, 145, 230, 124, 72])
}
  , mainLane := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { mainLaneBundleDigest := (bytes [222, 82, 238, 140, 53, 221, 99, 9, 8, 44, 143, 219, 247, 90, 225, 228, 22, 134, 48, 59, 224, 198, 23, 39, 187, 209, 66, 75, 107, 204, 90, 253]), digest := (bytes [207, 41, 113, 238, 118, 196, 200, 203, 80, 153, 238, 226, 232, 209, 37, 111, 253, 78, 85, 154, 112, 227, 108, 21, 116, 190, 72, 17, 171, 109, 68, 127]) }, digest := (bytes [74, 89, 138, 223, 98, 135, 84, 135, 173, 9, 88, 65, 87, 60, 151, 159, 173, 191, 90, 182, 243, 207, 57, 224, 218, 221, 188, 167, 37, 166, 41, 185]) }
  , opening := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , stages := { stageClaimsDigest := (bytes [24, 67, 172, 80, 154, 139, 100, 179, 186, 37, 117, 247, 148, 160, 191, 96, 193, 250, 127, 117, 89, 12, 45, 38, 60, 19, 0, 15, 5, 74, 220, 234]), stagePackagesDigest := (bytes [167, 215, 127, 189, 210, 168, 232, 105, 57, 174, 5, 55, 38, 139, 206, 201, 112, 90, 173, 216, 21, 102, 167, 254, 97, 193, 101, 156, 198, 73, 167, 58]), kernelOpeningDigest := (bytes [180, 209, 173, 8, 241, 238, 36, 202, 102, 195, 251, 219, 15, 82, 106, 169, 144, 78, 190, 126, 19, 103, 232, 61, 87, 46, 16, 192, 192, 140, 88, 187]), digest := (bytes [213, 173, 168, 212, 148, 23, 168, 103, 236, 248, 199, 67, 166, 26, 133, 216, 239, 220, 162, 200, 55, 200, 197, 205, 131, 20, 110, 118, 13, 159, 167, 142]) }
  , terminal := { preparedStepBindingsDigest := (bytes [91, 117, 19, 85, 154, 0, 166, 170, 125, 60, 174, 129, 137, 154, 174, 169, 226, 246, 107, 48, 0, 2, 213, 88, 23, 96, 42, 187, 137, 2, 41, 26]), executionDigest := (bytes [12, 149, 33, 173, 171, 165, 54, 175, 9, 253, 234, 193, 13, 243, 189, 0, 121, 246, 75, 0, 67, 138, 71, 71, 204, 153, 161, 108, 26, 195, 251, 119]), transcriptFinalDigest := (bytes [149, 175, 127, 64, 128, 109, 150, 249, 47, 57, 9, 242, 150, 54, 116, 94, 21, 122, 154, 133, 58, 143, 232, 51, 183, 46, 158, 33, 79, 174, 114, 118]), digest := (bytes [181, 191, 114, 27, 189, 42, 0, 39, 105, 3, 210, 240, 14, 28, 42, 70, 224, 55, 3, 140, 20, 199, 27, 248, 196, 42, 255, 213, 255, 131, 177, 30]) }
  , digest := (bytes [173, 130, 55, 186, 7, 65, 148, 78, 131, 27, 108, 241, 34, 199, 49, 216, 199, 41, 174, 211, 89, 224, 102, 253, 111, 160, 202, 232, 106, 81, 45, 58])
}
  , jointOpening := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { proofStatementDigest := (bytes [151, 64, 94, 196, 181, 102, 86, 239, 147, 153, 73, 133, 113, 232, 103, 42, 130, 178, 220, 92, 93, 84, 20, 2, 198, 240, 164, 43, 138, 161, 34, 106]), mainLaneClaimDigest := (bytes [74, 89, 138, 223, 98, 135, 84, 135, 173, 9, 88, 65, 87, 60, 151, 159, 173, 191, 90, 182, 243, 207, 57, 224, 218, 221, 188, 167, 37, 166, 41, 185]), kernelOpeningClaimDigest := (bytes [173, 130, 55, 186, 7, 65, 148, 78, 131, 27, 108, 241, 34, 199, 49, 216, 199, 41, 174, 211, 89, 224, 102, 253, 111, 160, 202, 232, 106, 81, 45, 58]), digest := (bytes [104, 69, 166, 88, 52, 27, 71, 51, 43, 9, 201, 104, 17, 235, 161, 82, 94, 178, 202, 188, 181, 78, 68, 226, 211, 83, 90, 128, 194, 174, 28, 235]) }, digest := (bytes [180, 99, 111, 41, 124, 216, 160, 1, 63, 165, 228, 229, 26, 105, 246, 83, 87, 86, 225, 83, 166, 88, 174, 87, 0, 42, 19, 116, 214, 36, 214, 131]) }
  , root0 := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), stages := { stage1Digest := (bytes [49, 161, 13, 124, 3, 254, 251, 63, 149, 85, 118, 87, 149, 41, 33, 106, 239, 224, 235, 122, 124, 115, 70, 243, 63, 43, 7, 106, 43, 13, 29, 169]), stage2Digest := (bytes [76, 67, 196, 204, 58, 160, 47, 32, 132, 98, 117, 189, 46, 75, 241, 54, 49, 21, 50, 72, 228, 63, 229, 152, 90, 2, 115, 124, 210, 7, 178, 52]), stage3Digest := (bytes [2, 183, 132, 95, 231, 115, 83, 2, 8, 179, 51, 169, 210, 224, 230, 178, 60, 35, 73, 58, 195, 121, 109, 163, 86, 206, 95, 244, 250, 18, 169, 79]), digest := (bytes [95, 177, 190, 211, 37, 161, 240, 94, 158, 179, 86, 14, 106, 165, 80, 7, 244, 149, 79, 73, 214, 32, 18, 197, 27, 215, 38, 45, 183, 254, 69, 220]) }, terminal := { root0Digest := (bytes [92, 172, 22, 138, 218, 1, 129, 66, 224, 89, 66, 175, 77, 144, 188, 74, 225, 81, 33, 159, 113, 152, 248, 210, 237, 253, 25, 73, 246, 251, 115, 40]), executionDigest := (bytes [12, 149, 33, 173, 171, 165, 54, 175, 9, 253, 234, 193, 13, 243, 189, 0, 121, 246, 75, 0, 67, 138, 71, 71, 204, 153, 161, 108, 26, 195, 251, 119]), finalStateDigest := (bytes [210, 76, 200, 21, 4, 69, 15, 25, 203, 33, 125, 2, 33, 189, 7, 17, 57, 53, 132, 53, 135, 156, 153, 112, 132, 50, 0, 120, 169, 124, 149, 40]), transcriptFinalDigest := (bytes [149, 175, 127, 64, 128, 109, 150, 249, 47, 57, 9, 242, 150, 54, 116, 94, 21, 122, 154, 133, 58, 143, 232, 51, 183, 46, 158, 33, 79, 174, 114, 118]), digest := (bytes [8, 248, 7, 124, 149, 107, 104, 199, 139, 182, 120, 245, 100, 248, 191, 235, 151, 77, 246, 40, 22, 49, 65, 132, 119, 130, 127, 78, 80, 15, 146, 28]) }, digest := (bytes [219, 249, 35, 249, 11, 140, 233, 20, 16, 11, 198, 46, 191, 246, 111, 230, 35, 164, 100, 235, 153, 206, 135, 203, 216, 122, 111, 237, 8, 78, 241, 53]) }
  , digest := (bytes [45, 184, 67, 23, 245, 194, 84, 46, 229, 19, 200, 101, 59, 29, 115, 17, 230, 106, 202, 214, 13, 29, 186, 238, 8, 85, 144, 41, 197, 51, 159, 205])
}
  , statement := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , foldSchedule := Nightstream.FoldSchedule.wholeTrace
  , chunkCount := 1
  , stageClaimsDigest := (bytes [24, 67, 172, 80, 154, 139, 100, 179, 186, 37, 117, 247, 148, 160, 191, 96, 193, 250, 127, 117, 89, 12, 45, 38, 60, 19, 0, 15, 5, 74, 220, 234])
  , stagePackagesDigest := (bytes [167, 215, 127, 189, 210, 168, 232, 105, 57, 174, 5, 55, 38, 139, 206, 201, 112, 90, 173, 216, 21, 102, 167, 254, 97, 193, 101, 156, 198, 73, 167, 58])
  , kernelOpeningDigest := (bytes [180, 209, 173, 8, 241, 238, 36, 202, 102, 195, 251, 219, 15, 82, 106, 169, 144, 78, 190, 126, 19, 103, 232, 61, 87, 46, 16, 192, 192, 140, 88, 187])
  , preparedStepBindingsDigest := (bytes [91, 117, 19, 85, 154, 0, 166, 170, 125, 60, 174, 129, 137, 154, 174, 169, 226, 246, 107, 48, 0, 2, 213, 88, 23, 96, 42, 187, 137, 2, 41, 26])
  , executionDigest := (bytes [12, 149, 33, 173, 171, 165, 54, 175, 9, 253, 234, 193, 13, 243, 189, 0, 121, 246, 75, 0, 67, 138, 71, 71, 204, 153, 161, 108, 26, 195, 251, 119])
  , finalStateDigest := (bytes [210, 76, 200, 21, 4, 69, 15, 25, 203, 33, 125, 2, 33, 189, 7, 17, 57, 53, 132, 53, 135, 156, 153, 112, 132, 50, 0, 120, 169, 124, 149, 40])
  , transcriptFinalDigest := (bytes [149, 175, 127, 64, 128, 109, 150, 249, 47, 57, 9, 242, 150, 54, 116, 94, 21, 122, 154, 133, 58, 143, 232, 51, 183, 46, 158, 33, 79, 174, 114, 118])
  , mainLaneSurfaceDigest := (bytes [227, 156, 93, 89, 60, 223, 40, 203, 246, 245, 252, 241, 230, 47, 201, 241, 123, 249, 195, 68, 120, 147, 172, 144, 48, 174, 113, 243, 169, 61, 226, 23])
  , rootLaneColumnsDigest := (bytes [213, 185, 142, 63, 202, 223, 100, 7, 247, 41, 30, 235, 165, 158, 145, 96, 6, 239, 117, 42, 138, 247, 217, 129, 87, 17, 62, 125, 247, 55, 111, 115])
  , publicStepCount := 5
  , initialPc := 0
  , finalPc := 20
  , halted := true
  , digest := (bytes [151, 64, 94, 196, 181, 102, 86, 239, 147, 153, 73, 133, 113, 232, 103, 42, 130, 178, 220, 92, 93, 84, 20, 2, 198, 240, 164, 43, 138, 161, 34, 106])
}
  , kernel := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "native_word_arith_chain_ecall", fixtureId := "native_word_arith_chain_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , executionDigest := (bytes [12, 149, 33, 173, 171, 165, 54, 175, 9, 253, 234, 193, 13, 243, 189, 0, 121, 246, 75, 0, 67, 138, 71, 71, 204, 153, 161, 108, 26, 195, 251, 119])
  , shape := { executionRowCount := 5, realRowCount := 5, effectRowCount := 5, commitRowCount := 5, digest := (bytes [11, 168, 18, 205, 239, 69, 109, 190, 207, 168, 250, 196, 121, 176, 87, 55, 1, 249, 85, 208, 31, 220, 81, 235, 69, 31, 18, 110, 121, 74, 49, 211]) }
  , digest := (bytes [237, 198, 241, 48, 7, 169, 70, 117, 171, 145, 195, 33, 223, 53, 103, 217, 135, 47, 118, 29, 78, 225, 253, 145, 100, 107, 48, 71, 135, 126, 59, 181])
}
  , stages := { summary := { stage1RowCount := 5, stage2RegisterReadCount := 6, stage2RegisterWriteCount := 4, stage2RamEventCount := 0, stage2TwistLinkCount := 5, stage3ContinuityCount := 5, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [141, 225, 99, 203, 82, 127, 237, 231, 19, 157, 248, 93, 40, 201, 74, 206, 185, 2, 158, 150, 189, 173, 215, 197, 174, 38, 24, 73, 140, 149, 161, 210]) }, digest := (bytes [94, 183, 250, 237, 90, 36, 42, 5, 30, 222, 209, 88, 215, 36, 250, 190, 9, 95, 62, 125, 98, 81, 23, 75, 18, 45, 20, 187, 243, 210, 134, 195]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [5, 245, 86, 44, 48, 35, 206, 23, 23, 151, 216, 75, 178, 190, 248, 233, 7, 179, 116, 14, 179, 235, 120, 40, 233, 57, 73, 158, 114, 7, 98, 165]), stage1Digest := (bytes [120, 45, 134, 165, 38, 22, 189, 162, 15, 159, 62, 105, 182, 125, 90, 92, 125, 105, 17, 254, 251, 89, 25, 53, 41, 5, 239, 10, 228, 25, 134, 212]), stage2Digest := (bytes [140, 174, 152, 65, 127, 9, 176, 100, 246, 57, 156, 189, 188, 142, 198, 193, 111, 221, 113, 220, 203, 205, 192, 138, 193, 171, 117, 81, 112, 196, 154, 255]), stage3Digest := (bytes [203, 140, 63, 160, 179, 160, 171, 82, 223, 2, 32, 73, 21, 112, 190, 222, 133, 97, 45, 221, 193, 128, 37, 148, 220, 120, 81, 206, 4, 164, 16, 21]), transcriptDigest := (bytes [149, 175, 127, 64, 128, 109, 150, 249, 47, 57, 9, 242, 150, 54, 116, 94, 21, 122, 154, 133, 58, 143, 232, 51, 183, 46, 158, 33, 79, 174, 114, 118]), executionDigest := (bytes [12, 149, 33, 173, 171, 165, 54, 175, 9, 253, 234, 193, 13, 243, 189, 0, 121, 246, 75, 0, 67, 138, 71, 71, 204, 153, 161, 108, 26, 195, 251, 119]), digest := (bytes [136, 68, 64, 48, 69, 162, 130, 118, 13, 69, 29, 124, 40, 66, 48, 38, 133, 95, 79, 130, 16, 245, 24, 50, 7, 47, 218, 93, 202, 73, 235, 203]) }, statementDigest := (bytes [79, 157, 238, 179, 239, 65, 51, 133, 238, 206, 153, 182, 101, 77, 208, 221, 185, 192, 32, 122, 196, 223, 117, 116, 54, 12, 242, 144, 210, 37, 104, 44]), proofDigest := (bytes [77, 107, 216, 116, 214, 73, 234, 208, 109, 191, 21, 81, 234, 10, 224, 123, 55, 238, 218, 141, 192, 146, 212, 44, 129, 19, 104, 177, 253, 78, 16, 163]), digest := (bytes [24, 67, 172, 80, 154, 139, 100, 179, 186, 37, 117, 247, 148, 160, 191, 96, 193, 250, 127, 117, 89, 12, 45, 38, 60, 19, 0, 15, 5, 74, 220, 234]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [42, 28, 148, 226, 172, 23, 43, 227, 239, 241, 11, 57, 168, 79, 19, 242, 239, 206, 95, 113, 70, 47, 198, 183, 22, 102, 191, 183, 121, 181, 215, 20]), stage1Digest := (bytes [173, 33, 149, 207, 246, 124, 144, 30, 221, 155, 50, 196, 200, 246, 153, 154, 92, 39, 21, 130, 0, 14, 85, 196, 68, 61, 42, 199, 208, 35, 228, 147]), stage2Digest := (bytes [40, 195, 49, 80, 144, 193, 37, 148, 42, 214, 173, 133, 9, 128, 62, 61, 85, 4, 200, 87, 144, 38, 157, 54, 166, 133, 181, 248, 119, 11, 41, 186]), stage3Digest := (bytes [222, 201, 157, 144, 205, 9, 149, 155, 9, 164, 122, 0, 0, 97, 212, 97, 34, 22, 78, 10, 168, 239, 51, 12, 115, 132, 210, 180, 79, 66, 248, 179]), digest := (bytes [34, 229, 118, 191, 44, 225, 185, 97, 119, 232, 110, 62, 220, 242, 134, 149, 215, 79, 100, 210, 137, 43, 33, 23, 31, 184, 109, 60, 112, 19, 77, 157]) }, digest := (bytes [167, 215, 127, 189, 210, 168, 232, 105, 57, 174, 5, 55, 38, 139, 206, 201, 112, 90, 173, 216, 21, 102, 167, 254, 97, 193, 101, 156, 198, 73, 167, 58]) }
  , kernelOpening := { openingDigest := (bytes [134, 6, 74, 102, 60, 207, 81, 179, 42, 149, 224, 30, 111, 152, 122, 230, 149, 119, 220, 106, 229, 132, 67, 229, 113, 234, 105, 43, 219, 157, 32, 239]), bindings := { claimDigest := (bytes [37, 141, 200, 179, 134, 39, 202, 221, 107, 178, 217, 246, 199, 214, 186, 248, 173, 82, 127, 54, 6, 24, 181, 224, 108, 54, 65, 27, 119, 66, 54, 145]), bindingsDigest := (bytes [149, 191, 73, 110, 39, 119, 255, 151, 218, 126, 114, 100, 146, 0, 188, 23, 15, 13, 222, 104, 3, 168, 49, 106, 39, 146, 178, 236, 141, 37, 161, 65]), preparedStepsDigest := (bytes [53, 129, 152, 171, 12, 185, 8, 176, 222, 244, 34, 155, 41, 246, 204, 193, 27, 51, 167, 35, 60, 210, 247, 205, 13, 30, 235, 238, 137, 43, 209, 239]), digest := (bytes [57, 106, 249, 50, 114, 82, 172, 144, 243, 187, 158, 190, 64, 139, 167, 49, 66, 235, 56, 209, 30, 40, 159, 139, 142, 35, 165, 22, 115, 6, 111, 213]) }, digest := (bytes [180, 209, 173, 8, 241, 238, 36, 202, 102, 195, 251, 219, 15, 82, 106, 169, 144, 78, 190, 126, 19, 103, 232, 61, 87, 46, 16, 192, 192, 140, 88, 187]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [91, 117, 19, 85, 154, 0, 166, 170, 125, 60, 174, 129, 137, 154, 174, 169, 226, 246, 107, 48, 0, 2, 213, 88, 23, 96, 42, 187, 137, 2, 41, 26]), terminal := { root0Digest := (bytes [92, 172, 22, 138, 218, 1, 129, 66, 224, 89, 66, 175, 77, 144, 188, 74, 225, 81, 33, 159, 113, 152, 248, 210, 237, 253, 25, 73, 246, 251, 115, 40]), executionDigest := (bytes [12, 149, 33, 173, 171, 165, 54, 175, 9, 253, 234, 193, 13, 243, 189, 0, 121, 246, 75, 0, 67, 138, 71, 71, 204, 153, 161, 108, 26, 195, 251, 119]), finalStateDigest := (bytes [210, 76, 200, 21, 4, 69, 15, 25, 203, 33, 125, 2, 33, 189, 7, 17, 57, 53, 132, 53, 135, 156, 153, 112, 132, 50, 0, 120, 169, 124, 149, 40]), transcriptFinalDigest := (bytes [149, 175, 127, 64, 128, 109, 150, 249, 47, 57, 9, 242, 150, 54, 116, 94, 21, 122, 154, 133, 58, 143, 232, 51, 183, 46, 158, 33, 79, 174, 114, 118]), finalPc := 20, halted := true, digest := (bytes [169, 52, 131, 71, 40, 207, 253, 76, 79, 242, 88, 172, 34, 168, 24, 174, 233, 107, 52, 94, 154, 206, 178, 159, 234, 57, 35, 97, 71, 102, 35, 37]) }, digest := (bytes [48, 171, 241, 50, 149, 155, 71, 186, 48, 176, 108, 158, 198, 217, 102, 29, 101, 239, 173, 64, 150, 62, 46, 101, 234, 42, 221, 179, 207, 92, 62, 89]) }, statementDigest := (bytes [26, 78, 82, 70, 43, 25, 25, 18, 51, 112, 123, 154, 221, 133, 6, 141, 50, 225, 102, 236, 26, 65, 120, 114, 83, 135, 241, 68, 148, 19, 245, 188]), proofDigest := (bytes [83, 211, 112, 244, 44, 66, 168, 23, 6, 208, 190, 237, 168, 140, 94, 237, 1, 89, 119, 237, 156, 66, 58, 251, 150, 108, 87, 145, 28, 253, 145, 92]), digest := (bytes [203, 105, 159, 116, 170, 8, 55, 230, 195, 210, 94, 190, 244, 70, 86, 202, 206, 126, 64, 132, 255, 203, 23, 61, 84, 218, 109, 128, 217, 118, 65, 221]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [12, 128, 33, 184, 242, 229, 158, 205, 212, 22, 196, 91, 161, 165, 57, 3, 196, 29, 120, 223, 240, 72, 12, 96, 48, 101, 55, 21, 177, 142, 153, 177]), layoutVersion := 1, digest := (bytes [93, 23, 86, 205, 206, 29, 138, 233, 139, 64, 144, 44, 188, 38, 173, 57, 129, 205, 187, 114, 72, 255, 147, 152, 246, 183, 217, 134, 82, 228, 245, 143]) }, rowWidth := 38, timeLen := 5, columnDigests := [(bytes [113, 50, 60, 138, 88, 147, 143, 114, 209, 102, 140, 109, 141, 130, 13, 65, 154, 83, 29, 54, 165, 27, 195, 207, 252, 83, 167, 120, 56, 155, 143, 109]), (bytes [164, 156, 12, 202, 128, 158, 166, 79, 50, 246, 26, 100, 33, 104, 153, 108, 231, 66, 5, 3, 94, 76, 41, 81, 13, 128, 233, 62, 40, 19, 215, 212]), (bytes [104, 86, 253, 80, 246, 180, 248, 154, 56, 26, 223, 106, 196, 169, 105, 55, 112, 123, 51, 7, 215, 60, 203, 20, 133, 2, 161, 155, 25, 94, 39, 31]), (bytes [4, 37, 191, 199, 27, 131, 127, 106, 23, 23, 164, 92, 246, 105, 210, 216, 164, 185, 128, 142, 255, 92, 5, 246, 36, 198, 85, 173, 19, 19, 230, 153]), (bytes [63, 82, 148, 11, 209, 51, 62, 242, 159, 229, 6, 212, 45, 165, 107, 74, 200, 142, 213, 63, 249, 218, 45, 61, 117, 144, 214, 116, 85, 207, 59, 178]), (bytes [135, 104, 199, 153, 173, 201, 75, 134, 70, 18, 19, 189, 63, 130, 156, 52, 6, 175, 190, 48, 104, 93, 33, 237, 146, 100, 186, 232, 141, 151, 72, 215]), (bytes [226, 196, 248, 68, 93, 218, 167, 109, 161, 97, 173, 192, 140, 226, 161, 133, 128, 128, 121, 149, 231, 35, 250, 86, 108, 3, 170, 250, 242, 53, 65, 16]), (bytes [242, 242, 101, 98, 26, 91, 84, 151, 121, 175, 196, 177, 72, 163, 109, 105, 54, 47, 137, 164, 180, 216, 27, 147, 168, 81, 30, 37, 98, 14, 115, 141]), (bytes [16, 166, 173, 204, 197, 96, 81, 23, 174, 247, 123, 173, 160, 1, 215, 78, 87, 237, 64, 153, 255, 223, 20, 26, 202, 114, 66, 221, 15, 90, 40, 102]), (bytes [95, 167, 51, 135, 163, 194, 94, 133, 95, 39, 204, 239, 193, 121, 232, 160, 79, 58, 5, 1, 233, 121, 174, 139, 228, 69, 205, 116, 216, 10, 31, 69]), (bytes [241, 173, 53, 128, 105, 157, 241, 38, 55, 78, 236, 46, 128, 91, 224, 201, 53, 225, 75, 79, 208, 168, 40, 94, 162, 246, 121, 91, 155, 167, 56, 195]), (bytes [130, 73, 215, 107, 115, 238, 24, 240, 163, 172, 98, 239, 249, 7, 88, 74, 134, 169, 33, 214, 106, 105, 129, 148, 132, 138, 211, 59, 46, 99, 155, 6]), (bytes [125, 74, 15, 65, 60, 142, 27, 20, 181, 112, 204, 235, 34, 180, 170, 93, 149, 71, 125, 7, 245, 82, 48, 159, 125, 51, 165, 153, 20, 14, 42, 41]), (bytes [47, 127, 69, 74, 208, 2, 35, 122, 30, 16, 16, 195, 229, 93, 160, 57, 71, 210, 192, 207, 192, 225, 37, 232, 26, 169, 245, 182, 141, 197, 100, 97]), (bytes [199, 85, 136, 172, 196, 182, 121, 174, 25, 97, 234, 74, 98, 160, 163, 107, 154, 194, 63, 232, 61, 118, 173, 180, 48, 227, 165, 168, 197, 141, 243, 230]), (bytes [218, 15, 164, 119, 26, 89, 153, 76, 195, 50, 55, 158, 39, 57, 253, 24, 64, 230, 89, 54, 164, 47, 223, 90, 24, 194, 243, 188, 112, 39, 74, 0]), (bytes [249, 165, 44, 168, 18, 125, 65, 76, 51, 110, 93, 193, 12, 212, 163, 81, 53, 26, 162, 66, 63, 100, 116, 243, 112, 137, 118, 14, 176, 24, 222, 159]), (bytes [11, 185, 133, 252, 50, 244, 35, 237, 167, 173, 175, 155, 13, 76, 146, 252, 114, 4, 198, 228, 91, 62, 90, 251, 253, 108, 66, 173, 181, 43, 114, 60]), (bytes [118, 104, 94, 12, 171, 3, 100, 43, 163, 51, 98, 0, 105, 201, 187, 207, 164, 190, 117, 22, 243, 3, 26, 197, 37, 180, 195, 107, 243, 137, 220, 124]), (bytes [164, 26, 251, 214, 133, 166, 36, 43, 117, 5, 240, 52, 163, 40, 219, 81, 176, 185, 168, 189, 219, 54, 240, 69, 240, 249, 122, 226, 140, 80, 170, 67]), (bytes [166, 212, 193, 165, 216, 77, 223, 22, 85, 148, 36, 46, 240, 197, 91, 192, 178, 249, 84, 99, 56, 189, 17, 175, 26, 146, 194, 235, 103, 203, 78, 106]), (bytes [117, 242, 101, 249, 21, 218, 127, 164, 230, 14, 233, 247, 199, 35, 201, 180, 129, 56, 152, 49, 20, 39, 58, 252, 143, 181, 103, 38, 215, 227, 205, 255]), (bytes [222, 141, 194, 19, 109, 181, 115, 128, 236, 90, 109, 50, 95, 37, 244, 239, 168, 246, 17, 195, 87, 245, 230, 227, 255, 210, 73, 185, 49, 105, 109, 248]), (bytes [6, 254, 110, 187, 235, 232, 26, 224, 177, 208, 223, 63, 151, 116, 244, 68, 181, 38, 182, 164, 169, 160, 199, 77, 149, 179, 23, 120, 151, 178, 148, 93]), (bytes [140, 52, 163, 89, 55, 243, 29, 183, 25, 178, 87, 57, 109, 247, 133, 42, 53, 246, 249, 12, 226, 144, 235, 217, 39, 192, 123, 2, 224, 49, 95, 76]), (bytes [181, 45, 69, 158, 65, 145, 43, 151, 232, 63, 217, 66, 85, 8, 179, 187, 244, 58, 114, 255, 75, 18, 179, 199, 200, 112, 8, 236, 243, 16, 186, 249]), (bytes [102, 140, 9, 232, 29, 171, 94, 46, 215, 126, 135, 247, 204, 222, 182, 180, 95, 97, 36, 110, 94, 7, 203, 183, 0, 33, 2, 183, 177, 137, 38, 65]), (bytes [167, 92, 69, 232, 129, 215, 150, 22, 142, 134, 186, 133, 122, 187, 98, 237, 109, 67, 169, 68, 16, 1, 0, 92, 129, 181, 145, 172, 134, 6, 57, 205]), (bytes [100, 60, 107, 51, 83, 82, 9, 140, 176, 45, 55, 192, 93, 71, 222, 103, 180, 46, 64, 171, 208, 105, 248, 228, 140, 207, 120, 66, 72, 214, 145, 73]), (bytes [231, 38, 189, 225, 191, 28, 138, 109, 137, 172, 136, 41, 0, 71, 10, 98, 82, 251, 63, 57, 134, 215, 207, 171, 22, 74, 131, 24, 248, 187, 249, 139]), (bytes [97, 115, 66, 52, 209, 119, 244, 26, 211, 179, 72, 158, 73, 50, 167, 139, 193, 248, 17, 168, 194, 18, 40, 36, 247, 217, 33, 69, 229, 217, 187, 137]), (bytes [104, 29, 194, 189, 239, 145, 194, 228, 166, 76, 154, 100, 169, 199, 26, 134, 252, 202, 252, 43, 213, 142, 242, 213, 255, 181, 81, 2, 47, 120, 226, 78]), (bytes [235, 49, 191, 128, 17, 252, 43, 130, 234, 138, 63, 235, 22, 122, 39, 9, 154, 168, 135, 151, 54, 180, 125, 133, 235, 6, 32, 243, 247, 58, 14, 141]), (bytes [203, 190, 166, 159, 209, 140, 180, 196, 75, 57, 130, 2, 89, 126, 203, 127, 16, 89, 187, 132, 95, 49, 171, 164, 127, 162, 189, 129, 74, 157, 57, 123]), (bytes [133, 97, 222, 172, 108, 224, 100, 38, 133, 82, 44, 62, 153, 42, 213, 206, 217, 200, 97, 197, 218, 106, 13, 74, 224, 64, 192, 64, 26, 89, 139, 91]), (bytes [170, 154, 45, 6, 188, 185, 88, 196, 229, 167, 43, 205, 233, 108, 55, 179, 176, 186, 4, 153, 204, 108, 150, 247, 84, 185, 23, 182, 159, 241, 182, 243]), (bytes [115, 151, 31, 42, 19, 22, 27, 97, 49, 213, 126, 77, 7, 8, 14, 238, 203, 249, 232, 13, 112, 30, 96, 119, 42, 123, 67, 145, 170, 250, 236, 255]), (bytes [142, 185, 27, 84, 132, 190, 160, 121, 218, 162, 8, 170, 126, 198, 197, 139, 11, 168, 143, 88, 101, 75, 56, 240, 14, 204, 255, 67, 55, 121, 123, 195])], familyDigest := (bytes [12, 128, 33, 184, 242, 229, 158, 205, 212, 22, 196, 91, 161, 165, 57, 3, 196, 29, 120, 223, 240, 72, 12, 96, 48, 101, 55, 21, 177, 142, 153, 177]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [12, 128, 33, 184, 242, 229, 158, 205, 212, 22, 196, 91, 161, 165, 57, 3, 196, 29, 120, 223, 240, 72, 12, 96, 48, 101, 55, 21, 177, 142, 153, 177]), layoutVersion := 1, digest := (bytes [93, 23, 86, 205, 206, 29, 138, 233, 139, 64, 144, 44, 188, 38, 173, 57, 129, 205, 187, 114, 72, 255, 147, 152, 246, 183, 217, 134, 82, 228, 245, 143]) }, logicalIndex := 0, digest := (bytes [40, 153, 170, 234, 161, 158, 8, 182, 204, 130, 187, 230, 253, 2, 237, 116, 148, 12, 32, 189, 142, 149, 79, 41, 100, 176, 44, 56, 190, 210, 171, 125]) }, valueDigest := (bytes [59, 110, 73, 184, 21, 134, 14, 247, 63, 174, 178, 199, 142, 253, 82, 19, 165, 139, 8, 196, 235, 194, 3, 121, 51, 124, 231, 35, 211, 16, 32, 52]), digest := (bytes [107, 83, 143, 13, 16, 195, 28, 191, 30, 23, 48, 73, 127, 45, 146, 223, 29, 40, 32, 36, 96, 122, 180, 245, 149, 85, 174, 218, 110, 201, 84, 5]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [12, 128, 33, 184, 242, 229, 158, 205, 212, 22, 196, 91, 161, 165, 57, 3, 196, 29, 120, 223, 240, 72, 12, 96, 48, 101, 55, 21, 177, 142, 153, 177]), layoutVersion := 1, digest := (bytes [93, 23, 86, 205, 206, 29, 138, 233, 139, 64, 144, 44, 188, 38, 173, 57, 129, 205, 187, 114, 72, 255, 147, 152, 246, 183, 217, 134, 82, 228, 245, 143]) }, logicalIndex := 4, digest := (bytes [194, 12, 167, 103, 234, 76, 20, 49, 226, 134, 176, 114, 169, 245, 18, 142, 145, 27, 92, 50, 250, 244, 171, 207, 55, 205, 46, 129, 52, 49, 92, 99]) }, valueDigest := (bytes [247, 8, 91, 86, 174, 60, 198, 248, 80, 76, 136, 253, 192, 49, 138, 233, 64, 183, 153, 201, 60, 173, 121, 212, 113, 120, 175, 228, 9, 127, 13, 255]), digest := (bytes [185, 244, 106, 195, 5, 46, 56, 8, 140, 244, 184, 72, 72, 170, 174, 7, 161, 225, 151, 205, 116, 150, 66, 233, 90, 246, 89, 180, 145, 7, 221, 136]) }), digest := (bytes [213, 185, 142, 63, 202, 223, 100, 7, 247, 41, 30, 235, 165, 158, 145, 96, 6, 239, 117, 42, 138, 247, 217, 129, 87, 17, 62, 125, 247, 55, 111, 115]) }
  , rootLaneCommitment := { timeLen := 5, commitments := { commitmentCount := 38, digest := (bytes [167, 134, 219, 115, 157, 1, 205, 216, 94, 200, 200, 185, 201, 29, 37, 30, 211, 219, 133, 246, 131, 127, 123, 204, 232, 247, 119, 255, 193, 111, 1, 3]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [167, 134, 219, 115, 157, 1, 205, 216, 94, 200, 200, 185, 201, 29, 37, 30, 211, 219, 133, 246, 131, 127, 123, 204, 232, 247, 119, 255, 193, 111, 1, 3]), layoutVersion := 3, digest := (bytes [144, 1, 205, 205, 173, 23, 147, 240, 200, 216, 98, 186, 0, 44, 155, 17, 176, 29, 96, 184, 112, 37, 176, 54, 69, 12, 228, 43, 239, 187, 60, 244]) }, logicalIndex := 0, digest := (bytes [164, 80, 240, 165, 212, 106, 222, 27, 57, 122, 141, 225, 118, 133, 86, 173, 131, 2, 96, 85, 250, 193, 23, 124, 202, 22, 99, 160, 205, 211, 23, 21]) }, valueDigest := (bytes [59, 110, 73, 184, 21, 134, 14, 247, 63, 174, 178, 199, 142, 253, 82, 19, 165, 139, 8, 196, 235, 194, 3, 121, 51, 124, 231, 35, 211, 16, 32, 52]), digest := (bytes [239, 168, 197, 147, 208, 9, 141, 65, 93, 2, 147, 148, 71, 241, 158, 64, 43, 208, 77, 43, 187, 99, 136, 72, 199, 241, 17, 207, 187, 5, 220, 233]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [167, 134, 219, 115, 157, 1, 205, 216, 94, 200, 200, 185, 201, 29, 37, 30, 211, 219, 133, 246, 131, 127, 123, 204, 232, 247, 119, 255, 193, 111, 1, 3]), layoutVersion := 3, digest := (bytes [144, 1, 205, 205, 173, 23, 147, 240, 200, 216, 98, 186, 0, 44, 155, 17, 176, 29, 96, 184, 112, 37, 176, 54, 69, 12, 228, 43, 239, 187, 60, 244]) }, logicalIndex := 4, digest := (bytes [233, 101, 132, 148, 29, 173, 255, 87, 170, 115, 152, 184, 118, 32, 29, 187, 121, 72, 151, 174, 244, 84, 50, 230, 8, 34, 46, 40, 195, 220, 138, 156]) }, valueDigest := (bytes [247, 8, 91, 86, 174, 60, 198, 248, 80, 76, 136, 253, 192, 49, 138, 233, 64, 183, 153, 201, 60, 173, 121, 212, 113, 120, 175, 228, 9, 127, 13, 255]), digest := (bytes [92, 168, 23, 179, 76, 166, 139, 146, 145, 9, 165, 172, 55, 156, 201, 2, 123, 33, 172, 111, 248, 121, 159, 66, 43, 245, 188, 10, 10, 211, 195, 202]) }), digest := (bytes [119, 102, 74, 99, 233, 1, 220, 252, 149, 243, 0, 95, 112, 208, 28, 185, 56, 110, 175, 7, 228, 222, 66, 2, 6, 250, 230, 147, 202, 195, 106, 115]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [213, 185, 142, 63, 202, 223, 100, 7, 247, 41, 30, 235, 165, 158, 145, 96, 6, 239, 117, 42, 138, 247, 217, 129, 87, 17, 62, 125, 247, 55, 111, 115]), rootLaneCommitmentDigest := (bytes [119, 102, 74, 99, 233, 1, 220, 252, 149, 243, 0, 95, 112, 208, 28, 185, 56, 110, 175, 7, 228, 222, 66, 2, 6, 250, 230, 147, 202, 195, 106, 115]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 5, digest := (bytes [7, 132, 62, 118, 193, 167, 35, 55, 254, 245, 39, 205, 152, 212, 106, 245, 47, 132, 119, 36, 155, 239, 98, 59, 213, 78, 70, 207, 183, 105, 29, 39]) }, statementDigest := (bytes [119, 120, 234, 77, 68, 190, 62, 147, 225, 68, 229, 74, 209, 203, 43, 127, 39, 96, 171, 195, 168, 197, 18, 37, 146, 54, 179, 203, 150, 199, 213, 96]), proofDigest := (bytes [162, 235, 108, 114, 17, 211, 197, 55, 156, 142, 12, 232, 226, 57, 188, 57, 144, 131, 54, 251, 242, 149, 148, 126, 25, 211, 20, 223, 141, 64, 101, 188]), digest := (bytes [222, 82, 238, 140, 53, 221, 99, 9, 8, 44, 143, 219, 247, 90, 225, 228, 22, 134, 48, 59, 224, 198, 23, 39, 187, 209, 66, 75, 107, 204, 90, 253]) }
  , digest := (bytes [191, 175, 215, 16, 74, 149, 88, 119, 244, 156, 42, 255, 251, 140, 78, 22, 184, 135, 209, 230, 234, 193, 124, 119, 86, 184, 225, 140, 213, 163, 111, 127])
}
}
    , exportedStatement := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , foldSchedule := Nightstream.FoldSchedule.wholeTrace
  , chunkCount := 1
  , stageClaimsDigest := (bytes [24, 67, 172, 80, 154, 139, 100, 179, 186, 37, 117, 247, 148, 160, 191, 96, 193, 250, 127, 117, 89, 12, 45, 38, 60, 19, 0, 15, 5, 74, 220, 234])
  , stagePackagesDigest := (bytes [167, 215, 127, 189, 210, 168, 232, 105, 57, 174, 5, 55, 38, 139, 206, 201, 112, 90, 173, 216, 21, 102, 167, 254, 97, 193, 101, 156, 198, 73, 167, 58])
  , kernelOpeningDigest := (bytes [180, 209, 173, 8, 241, 238, 36, 202, 102, 195, 251, 219, 15, 82, 106, 169, 144, 78, 190, 126, 19, 103, 232, 61, 87, 46, 16, 192, 192, 140, 88, 187])
  , preparedStepBindingsDigest := (bytes [91, 117, 19, 85, 154, 0, 166, 170, 125, 60, 174, 129, 137, 154, 174, 169, 226, 246, 107, 48, 0, 2, 213, 88, 23, 96, 42, 187, 137, 2, 41, 26])
  , executionDigest := (bytes [12, 149, 33, 173, 171, 165, 54, 175, 9, 253, 234, 193, 13, 243, 189, 0, 121, 246, 75, 0, 67, 138, 71, 71, 204, 153, 161, 108, 26, 195, 251, 119])
  , finalStateDigest := (bytes [210, 76, 200, 21, 4, 69, 15, 25, 203, 33, 125, 2, 33, 189, 7, 17, 57, 53, 132, 53, 135, 156, 153, 112, 132, 50, 0, 120, 169, 124, 149, 40])
  , transcriptFinalDigest := (bytes [149, 175, 127, 64, 128, 109, 150, 249, 47, 57, 9, 242, 150, 54, 116, 94, 21, 122, 154, 133, 58, 143, 232, 51, 183, 46, 158, 33, 79, 174, 114, 118])
  , mainLaneSurfaceDigest := (bytes [227, 156, 93, 89, 60, 223, 40, 203, 246, 245, 252, 241, 230, 47, 201, 241, 123, 249, 195, 68, 120, 147, 172, 144, 48, 174, 113, 243, 169, 61, 226, 23])
  , rootLaneColumnsDigest := (bytes [213, 185, 142, 63, 202, 223, 100, 7, 247, 41, 30, 235, 165, 158, 145, 96, 6, 239, 117, 42, 138, 247, 217, 129, 87, 17, 62, 125, 247, 55, 111, 115])
  , publicStepCount := 5
  , initialPc := 0
  , finalPc := 20
  , halted := true
  , digest := (bytes [151, 64, 94, 196, 181, 102, 86, 239, 147, 153, 73, 133, 113, 232, 103, 42, 130, 178, 220, 92, 93, 84, 20, 2, 198, 240, 164, 43, 138, 161, 34, 106])
}
    , exportedClaims := {
  accepted := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , statement := { proofStatementDigest := (bytes [151, 64, 94, 196, 181, 102, 86, 239, 147, 153, 73, 133, 113, 232, 103, 42, 130, 178, 220, 92, 93, 84, 20, 2, 198, 240, 164, 43, 138, 161, 34, 106]), kernelOpeningDigest := (bytes [180, 209, 173, 8, 241, 238, 36, 202, 102, 195, 251, 219, 15, 82, 106, 169, 144, 78, 190, 126, 19, 103, 232, 61, 87, 46, 16, 192, 192, 140, 88, 187]), digest := (bytes [202, 189, 206, 160, 207, 14, 4, 165, 16, 130, 247, 229, 48, 201, 145, 70, 104, 53, 169, 236, 60, 118, 64, 194, 141, 225, 131, 184, 208, 32, 50, 25]) }
  , mainLane := { mainLaneBundleDigest := (bytes [222, 82, 238, 140, 53, 221, 99, 9, 8, 44, 143, 219, 247, 90, 225, 228, 22, 134, 48, 59, 224, 198, 23, 39, 187, 209, 66, 75, 107, 204, 90, 253]), digest := (bytes [87, 152, 179, 127, 87, 224, 203, 69, 49, 14, 152, 242, 26, 86, 43, 223, 55, 130, 127, 21, 190, 140, 112, 49, 160, 84, 25, 210, 249, 117, 12, 198]) }
  , terminal := { finalStateDigest := (bytes [210, 76, 200, 21, 4, 69, 15, 25, 203, 33, 125, 2, 33, 189, 7, 17, 57, 53, 132, 53, 135, 156, 153, 112, 132, 50, 0, 120, 169, 124, 149, 40]), finalPc := 20, halted := true, digest := (bytes [34, 51, 39, 156, 194, 141, 142, 101, 226, 114, 44, 92, 171, 211, 129, 122, 46, 89, 112, 7, 211, 98, 219, 85, 148, 241, 33, 145, 250, 73, 186, 142]) }
  , digest := (bytes [215, 118, 2, 103, 231, 2, 243, 156, 11, 39, 204, 119, 74, 147, 175, 156, 215, 134, 28, 2, 222, 121, 233, 50, 52, 196, 249, 36, 145, 230, 124, 72])
}
  , mainLane := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { mainLaneBundleDigest := (bytes [222, 82, 238, 140, 53, 221, 99, 9, 8, 44, 143, 219, 247, 90, 225, 228, 22, 134, 48, 59, 224, 198, 23, 39, 187, 209, 66, 75, 107, 204, 90, 253]), digest := (bytes [207, 41, 113, 238, 118, 196, 200, 203, 80, 153, 238, 226, 232, 209, 37, 111, 253, 78, 85, 154, 112, 227, 108, 21, 116, 190, 72, 17, 171, 109, 68, 127]) }, digest := (bytes [74, 89, 138, 223, 98, 135, 84, 135, 173, 9, 88, 65, 87, 60, 151, 159, 173, 191, 90, 182, 243, 207, 57, 224, 218, 221, 188, 167, 37, 166, 41, 185]) }
  , opening := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , stages := { stageClaimsDigest := (bytes [24, 67, 172, 80, 154, 139, 100, 179, 186, 37, 117, 247, 148, 160, 191, 96, 193, 250, 127, 117, 89, 12, 45, 38, 60, 19, 0, 15, 5, 74, 220, 234]), stagePackagesDigest := (bytes [167, 215, 127, 189, 210, 168, 232, 105, 57, 174, 5, 55, 38, 139, 206, 201, 112, 90, 173, 216, 21, 102, 167, 254, 97, 193, 101, 156, 198, 73, 167, 58]), kernelOpeningDigest := (bytes [180, 209, 173, 8, 241, 238, 36, 202, 102, 195, 251, 219, 15, 82, 106, 169, 144, 78, 190, 126, 19, 103, 232, 61, 87, 46, 16, 192, 192, 140, 88, 187]), digest := (bytes [213, 173, 168, 212, 148, 23, 168, 103, 236, 248, 199, 67, 166, 26, 133, 216, 239, 220, 162, 200, 55, 200, 197, 205, 131, 20, 110, 118, 13, 159, 167, 142]) }
  , terminal := { preparedStepBindingsDigest := (bytes [91, 117, 19, 85, 154, 0, 166, 170, 125, 60, 174, 129, 137, 154, 174, 169, 226, 246, 107, 48, 0, 2, 213, 88, 23, 96, 42, 187, 137, 2, 41, 26]), executionDigest := (bytes [12, 149, 33, 173, 171, 165, 54, 175, 9, 253, 234, 193, 13, 243, 189, 0, 121, 246, 75, 0, 67, 138, 71, 71, 204, 153, 161, 108, 26, 195, 251, 119]), transcriptFinalDigest := (bytes [149, 175, 127, 64, 128, 109, 150, 249, 47, 57, 9, 242, 150, 54, 116, 94, 21, 122, 154, 133, 58, 143, 232, 51, 183, 46, 158, 33, 79, 174, 114, 118]), digest := (bytes [181, 191, 114, 27, 189, 42, 0, 39, 105, 3, 210, 240, 14, 28, 42, 70, 224, 55, 3, 140, 20, 199, 27, 248, 196, 42, 255, 213, 255, 131, 177, 30]) }
  , digest := (bytes [173, 130, 55, 186, 7, 65, 148, 78, 131, 27, 108, 241, 34, 199, 49, 216, 199, 41, 174, 211, 89, 224, 102, 253, 111, 160, 202, 232, 106, 81, 45, 58])
}
  , jointOpening := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { proofStatementDigest := (bytes [151, 64, 94, 196, 181, 102, 86, 239, 147, 153, 73, 133, 113, 232, 103, 42, 130, 178, 220, 92, 93, 84, 20, 2, 198, 240, 164, 43, 138, 161, 34, 106]), mainLaneClaimDigest := (bytes [74, 89, 138, 223, 98, 135, 84, 135, 173, 9, 88, 65, 87, 60, 151, 159, 173, 191, 90, 182, 243, 207, 57, 224, 218, 221, 188, 167, 37, 166, 41, 185]), kernelOpeningClaimDigest := (bytes [173, 130, 55, 186, 7, 65, 148, 78, 131, 27, 108, 241, 34, 199, 49, 216, 199, 41, 174, 211, 89, 224, 102, 253, 111, 160, 202, 232, 106, 81, 45, 58]), digest := (bytes [104, 69, 166, 88, 52, 27, 71, 51, 43, 9, 201, 104, 17, 235, 161, 82, 94, 178, 202, 188, 181, 78, 68, 226, 211, 83, 90, 128, 194, 174, 28, 235]) }, digest := (bytes [180, 99, 111, 41, 124, 216, 160, 1, 63, 165, 228, 229, 26, 105, 246, 83, 87, 86, 225, 83, 166, 88, 174, 87, 0, 42, 19, 116, 214, 36, 214, 131]) }
  , root0 := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), stages := { stage1Digest := (bytes [49, 161, 13, 124, 3, 254, 251, 63, 149, 85, 118, 87, 149, 41, 33, 106, 239, 224, 235, 122, 124, 115, 70, 243, 63, 43, 7, 106, 43, 13, 29, 169]), stage2Digest := (bytes [76, 67, 196, 204, 58, 160, 47, 32, 132, 98, 117, 189, 46, 75, 241, 54, 49, 21, 50, 72, 228, 63, 229, 152, 90, 2, 115, 124, 210, 7, 178, 52]), stage3Digest := (bytes [2, 183, 132, 95, 231, 115, 83, 2, 8, 179, 51, 169, 210, 224, 230, 178, 60, 35, 73, 58, 195, 121, 109, 163, 86, 206, 95, 244, 250, 18, 169, 79]), digest := (bytes [95, 177, 190, 211, 37, 161, 240, 94, 158, 179, 86, 14, 106, 165, 80, 7, 244, 149, 79, 73, 214, 32, 18, 197, 27, 215, 38, 45, 183, 254, 69, 220]) }, terminal := { root0Digest := (bytes [92, 172, 22, 138, 218, 1, 129, 66, 224, 89, 66, 175, 77, 144, 188, 74, 225, 81, 33, 159, 113, 152, 248, 210, 237, 253, 25, 73, 246, 251, 115, 40]), executionDigest := (bytes [12, 149, 33, 173, 171, 165, 54, 175, 9, 253, 234, 193, 13, 243, 189, 0, 121, 246, 75, 0, 67, 138, 71, 71, 204, 153, 161, 108, 26, 195, 251, 119]), finalStateDigest := (bytes [210, 76, 200, 21, 4, 69, 15, 25, 203, 33, 125, 2, 33, 189, 7, 17, 57, 53, 132, 53, 135, 156, 153, 112, 132, 50, 0, 120, 169, 124, 149, 40]), transcriptFinalDigest := (bytes [149, 175, 127, 64, 128, 109, 150, 249, 47, 57, 9, 242, 150, 54, 116, 94, 21, 122, 154, 133, 58, 143, 232, 51, 183, 46, 158, 33, 79, 174, 114, 118]), digest := (bytes [8, 248, 7, 124, 149, 107, 104, 199, 139, 182, 120, 245, 100, 248, 191, 235, 151, 77, 246, 40, 22, 49, 65, 132, 119, 130, 127, 78, 80, 15, 146, 28]) }, digest := (bytes [219, 249, 35, 249, 11, 140, 233, 20, 16, 11, 198, 46, 191, 246, 111, 230, 35, 164, 100, 235, 153, 206, 135, 203, 216, 122, 111, 237, 8, 78, 241, 53]) }
  , digest := (bytes [45, 184, 67, 23, 245, 194, 84, 46, 229, 19, 200, 101, 59, 29, 115, 17, 230, 106, 202, 214, 13, 29, 186, 238, 8, 85, 144, 41, 197, 51, 159, 205])
}
    , exportedKernelProof := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "native_word_arith_chain_ecall", fixtureId := "native_word_arith_chain_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , executionDigest := (bytes [12, 149, 33, 173, 171, 165, 54, 175, 9, 253, 234, 193, 13, 243, 189, 0, 121, 246, 75, 0, 67, 138, 71, 71, 204, 153, 161, 108, 26, 195, 251, 119])
  , shape := { executionRowCount := 5, realRowCount := 5, effectRowCount := 5, commitRowCount := 5, digest := (bytes [11, 168, 18, 205, 239, 69, 109, 190, 207, 168, 250, 196, 121, 176, 87, 55, 1, 249, 85, 208, 31, 220, 81, 235, 69, 31, 18, 110, 121, 74, 49, 211]) }
  , digest := (bytes [237, 198, 241, 48, 7, 169, 70, 117, 171, 145, 195, 33, 223, 53, 103, 217, 135, 47, 118, 29, 78, 225, 253, 145, 100, 107, 48, 71, 135, 126, 59, 181])
}
  , stages := { summary := { stage1RowCount := 5, stage2RegisterReadCount := 6, stage2RegisterWriteCount := 4, stage2RamEventCount := 0, stage2TwistLinkCount := 5, stage3ContinuityCount := 5, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [141, 225, 99, 203, 82, 127, 237, 231, 19, 157, 248, 93, 40, 201, 74, 206, 185, 2, 158, 150, 189, 173, 215, 197, 174, 38, 24, 73, 140, 149, 161, 210]) }, digest := (bytes [94, 183, 250, 237, 90, 36, 42, 5, 30, 222, 209, 88, 215, 36, 250, 190, 9, 95, 62, 125, 98, 81, 23, 75, 18, 45, 20, 187, 243, 210, 134, 195]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [5, 245, 86, 44, 48, 35, 206, 23, 23, 151, 216, 75, 178, 190, 248, 233, 7, 179, 116, 14, 179, 235, 120, 40, 233, 57, 73, 158, 114, 7, 98, 165]), stage1Digest := (bytes [120, 45, 134, 165, 38, 22, 189, 162, 15, 159, 62, 105, 182, 125, 90, 92, 125, 105, 17, 254, 251, 89, 25, 53, 41, 5, 239, 10, 228, 25, 134, 212]), stage2Digest := (bytes [140, 174, 152, 65, 127, 9, 176, 100, 246, 57, 156, 189, 188, 142, 198, 193, 111, 221, 113, 220, 203, 205, 192, 138, 193, 171, 117, 81, 112, 196, 154, 255]), stage3Digest := (bytes [203, 140, 63, 160, 179, 160, 171, 82, 223, 2, 32, 73, 21, 112, 190, 222, 133, 97, 45, 221, 193, 128, 37, 148, 220, 120, 81, 206, 4, 164, 16, 21]), transcriptDigest := (bytes [149, 175, 127, 64, 128, 109, 150, 249, 47, 57, 9, 242, 150, 54, 116, 94, 21, 122, 154, 133, 58, 143, 232, 51, 183, 46, 158, 33, 79, 174, 114, 118]), executionDigest := (bytes [12, 149, 33, 173, 171, 165, 54, 175, 9, 253, 234, 193, 13, 243, 189, 0, 121, 246, 75, 0, 67, 138, 71, 71, 204, 153, 161, 108, 26, 195, 251, 119]), digest := (bytes [136, 68, 64, 48, 69, 162, 130, 118, 13, 69, 29, 124, 40, 66, 48, 38, 133, 95, 79, 130, 16, 245, 24, 50, 7, 47, 218, 93, 202, 73, 235, 203]) }, statementDigest := (bytes [79, 157, 238, 179, 239, 65, 51, 133, 238, 206, 153, 182, 101, 77, 208, 221, 185, 192, 32, 122, 196, 223, 117, 116, 54, 12, 242, 144, 210, 37, 104, 44]), proofDigest := (bytes [77, 107, 216, 116, 214, 73, 234, 208, 109, 191, 21, 81, 234, 10, 224, 123, 55, 238, 218, 141, 192, 146, 212, 44, 129, 19, 104, 177, 253, 78, 16, 163]), digest := (bytes [24, 67, 172, 80, 154, 139, 100, 179, 186, 37, 117, 247, 148, 160, 191, 96, 193, 250, 127, 117, 89, 12, 45, 38, 60, 19, 0, 15, 5, 74, 220, 234]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [42, 28, 148, 226, 172, 23, 43, 227, 239, 241, 11, 57, 168, 79, 19, 242, 239, 206, 95, 113, 70, 47, 198, 183, 22, 102, 191, 183, 121, 181, 215, 20]), stage1Digest := (bytes [173, 33, 149, 207, 246, 124, 144, 30, 221, 155, 50, 196, 200, 246, 153, 154, 92, 39, 21, 130, 0, 14, 85, 196, 68, 61, 42, 199, 208, 35, 228, 147]), stage2Digest := (bytes [40, 195, 49, 80, 144, 193, 37, 148, 42, 214, 173, 133, 9, 128, 62, 61, 85, 4, 200, 87, 144, 38, 157, 54, 166, 133, 181, 248, 119, 11, 41, 186]), stage3Digest := (bytes [222, 201, 157, 144, 205, 9, 149, 155, 9, 164, 122, 0, 0, 97, 212, 97, 34, 22, 78, 10, 168, 239, 51, 12, 115, 132, 210, 180, 79, 66, 248, 179]), digest := (bytes [34, 229, 118, 191, 44, 225, 185, 97, 119, 232, 110, 62, 220, 242, 134, 149, 215, 79, 100, 210, 137, 43, 33, 23, 31, 184, 109, 60, 112, 19, 77, 157]) }, digest := (bytes [167, 215, 127, 189, 210, 168, 232, 105, 57, 174, 5, 55, 38, 139, 206, 201, 112, 90, 173, 216, 21, 102, 167, 254, 97, 193, 101, 156, 198, 73, 167, 58]) }
  , kernelOpening := { openingDigest := (bytes [134, 6, 74, 102, 60, 207, 81, 179, 42, 149, 224, 30, 111, 152, 122, 230, 149, 119, 220, 106, 229, 132, 67, 229, 113, 234, 105, 43, 219, 157, 32, 239]), bindings := { claimDigest := (bytes [37, 141, 200, 179, 134, 39, 202, 221, 107, 178, 217, 246, 199, 214, 186, 248, 173, 82, 127, 54, 6, 24, 181, 224, 108, 54, 65, 27, 119, 66, 54, 145]), bindingsDigest := (bytes [149, 191, 73, 110, 39, 119, 255, 151, 218, 126, 114, 100, 146, 0, 188, 23, 15, 13, 222, 104, 3, 168, 49, 106, 39, 146, 178, 236, 141, 37, 161, 65]), preparedStepsDigest := (bytes [53, 129, 152, 171, 12, 185, 8, 176, 222, 244, 34, 155, 41, 246, 204, 193, 27, 51, 167, 35, 60, 210, 247, 205, 13, 30, 235, 238, 137, 43, 209, 239]), digest := (bytes [57, 106, 249, 50, 114, 82, 172, 144, 243, 187, 158, 190, 64, 139, 167, 49, 66, 235, 56, 209, 30, 40, 159, 139, 142, 35, 165, 22, 115, 6, 111, 213]) }, digest := (bytes [180, 209, 173, 8, 241, 238, 36, 202, 102, 195, 251, 219, 15, 82, 106, 169, 144, 78, 190, 126, 19, 103, 232, 61, 87, 46, 16, 192, 192, 140, 88, 187]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [91, 117, 19, 85, 154, 0, 166, 170, 125, 60, 174, 129, 137, 154, 174, 169, 226, 246, 107, 48, 0, 2, 213, 88, 23, 96, 42, 187, 137, 2, 41, 26]), terminal := { root0Digest := (bytes [92, 172, 22, 138, 218, 1, 129, 66, 224, 89, 66, 175, 77, 144, 188, 74, 225, 81, 33, 159, 113, 152, 248, 210, 237, 253, 25, 73, 246, 251, 115, 40]), executionDigest := (bytes [12, 149, 33, 173, 171, 165, 54, 175, 9, 253, 234, 193, 13, 243, 189, 0, 121, 246, 75, 0, 67, 138, 71, 71, 204, 153, 161, 108, 26, 195, 251, 119]), finalStateDigest := (bytes [210, 76, 200, 21, 4, 69, 15, 25, 203, 33, 125, 2, 33, 189, 7, 17, 57, 53, 132, 53, 135, 156, 153, 112, 132, 50, 0, 120, 169, 124, 149, 40]), transcriptFinalDigest := (bytes [149, 175, 127, 64, 128, 109, 150, 249, 47, 57, 9, 242, 150, 54, 116, 94, 21, 122, 154, 133, 58, 143, 232, 51, 183, 46, 158, 33, 79, 174, 114, 118]), finalPc := 20, halted := true, digest := (bytes [169, 52, 131, 71, 40, 207, 253, 76, 79, 242, 88, 172, 34, 168, 24, 174, 233, 107, 52, 94, 154, 206, 178, 159, 234, 57, 35, 97, 71, 102, 35, 37]) }, digest := (bytes [48, 171, 241, 50, 149, 155, 71, 186, 48, 176, 108, 158, 198, 217, 102, 29, 101, 239, 173, 64, 150, 62, 46, 101, 234, 42, 221, 179, 207, 92, 62, 89]) }, statementDigest := (bytes [26, 78, 82, 70, 43, 25, 25, 18, 51, 112, 123, 154, 221, 133, 6, 141, 50, 225, 102, 236, 26, 65, 120, 114, 83, 135, 241, 68, 148, 19, 245, 188]), proofDigest := (bytes [83, 211, 112, 244, 44, 66, 168, 23, 6, 208, 190, 237, 168, 140, 94, 237, 1, 89, 119, 237, 156, 66, 58, 251, 150, 108, 87, 145, 28, 253, 145, 92]), digest := (bytes [203, 105, 159, 116, 170, 8, 55, 230, 195, 210, 94, 190, 244, 70, 86, 202, 206, 126, 64, 132, 255, 203, 23, 61, 84, 218, 109, 128, 217, 118, 65, 221]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [12, 128, 33, 184, 242, 229, 158, 205, 212, 22, 196, 91, 161, 165, 57, 3, 196, 29, 120, 223, 240, 72, 12, 96, 48, 101, 55, 21, 177, 142, 153, 177]), layoutVersion := 1, digest := (bytes [93, 23, 86, 205, 206, 29, 138, 233, 139, 64, 144, 44, 188, 38, 173, 57, 129, 205, 187, 114, 72, 255, 147, 152, 246, 183, 217, 134, 82, 228, 245, 143]) }, rowWidth := 38, timeLen := 5, columnDigests := [(bytes [113, 50, 60, 138, 88, 147, 143, 114, 209, 102, 140, 109, 141, 130, 13, 65, 154, 83, 29, 54, 165, 27, 195, 207, 252, 83, 167, 120, 56, 155, 143, 109]), (bytes [164, 156, 12, 202, 128, 158, 166, 79, 50, 246, 26, 100, 33, 104, 153, 108, 231, 66, 5, 3, 94, 76, 41, 81, 13, 128, 233, 62, 40, 19, 215, 212]), (bytes [104, 86, 253, 80, 246, 180, 248, 154, 56, 26, 223, 106, 196, 169, 105, 55, 112, 123, 51, 7, 215, 60, 203, 20, 133, 2, 161, 155, 25, 94, 39, 31]), (bytes [4, 37, 191, 199, 27, 131, 127, 106, 23, 23, 164, 92, 246, 105, 210, 216, 164, 185, 128, 142, 255, 92, 5, 246, 36, 198, 85, 173, 19, 19, 230, 153]), (bytes [63, 82, 148, 11, 209, 51, 62, 242, 159, 229, 6, 212, 45, 165, 107, 74, 200, 142, 213, 63, 249, 218, 45, 61, 117, 144, 214, 116, 85, 207, 59, 178]), (bytes [135, 104, 199, 153, 173, 201, 75, 134, 70, 18, 19, 189, 63, 130, 156, 52, 6, 175, 190, 48, 104, 93, 33, 237, 146, 100, 186, 232, 141, 151, 72, 215]), (bytes [226, 196, 248, 68, 93, 218, 167, 109, 161, 97, 173, 192, 140, 226, 161, 133, 128, 128, 121, 149, 231, 35, 250, 86, 108, 3, 170, 250, 242, 53, 65, 16]), (bytes [242, 242, 101, 98, 26, 91, 84, 151, 121, 175, 196, 177, 72, 163, 109, 105, 54, 47, 137, 164, 180, 216, 27, 147, 168, 81, 30, 37, 98, 14, 115, 141]), (bytes [16, 166, 173, 204, 197, 96, 81, 23, 174, 247, 123, 173, 160, 1, 215, 78, 87, 237, 64, 153, 255, 223, 20, 26, 202, 114, 66, 221, 15, 90, 40, 102]), (bytes [95, 167, 51, 135, 163, 194, 94, 133, 95, 39, 204, 239, 193, 121, 232, 160, 79, 58, 5, 1, 233, 121, 174, 139, 228, 69, 205, 116, 216, 10, 31, 69]), (bytes [241, 173, 53, 128, 105, 157, 241, 38, 55, 78, 236, 46, 128, 91, 224, 201, 53, 225, 75, 79, 208, 168, 40, 94, 162, 246, 121, 91, 155, 167, 56, 195]), (bytes [130, 73, 215, 107, 115, 238, 24, 240, 163, 172, 98, 239, 249, 7, 88, 74, 134, 169, 33, 214, 106, 105, 129, 148, 132, 138, 211, 59, 46, 99, 155, 6]), (bytes [125, 74, 15, 65, 60, 142, 27, 20, 181, 112, 204, 235, 34, 180, 170, 93, 149, 71, 125, 7, 245, 82, 48, 159, 125, 51, 165, 153, 20, 14, 42, 41]), (bytes [47, 127, 69, 74, 208, 2, 35, 122, 30, 16, 16, 195, 229, 93, 160, 57, 71, 210, 192, 207, 192, 225, 37, 232, 26, 169, 245, 182, 141, 197, 100, 97]), (bytes [199, 85, 136, 172, 196, 182, 121, 174, 25, 97, 234, 74, 98, 160, 163, 107, 154, 194, 63, 232, 61, 118, 173, 180, 48, 227, 165, 168, 197, 141, 243, 230]), (bytes [218, 15, 164, 119, 26, 89, 153, 76, 195, 50, 55, 158, 39, 57, 253, 24, 64, 230, 89, 54, 164, 47, 223, 90, 24, 194, 243, 188, 112, 39, 74, 0]), (bytes [249, 165, 44, 168, 18, 125, 65, 76, 51, 110, 93, 193, 12, 212, 163, 81, 53, 26, 162, 66, 63, 100, 116, 243, 112, 137, 118, 14, 176, 24, 222, 159]), (bytes [11, 185, 133, 252, 50, 244, 35, 237, 167, 173, 175, 155, 13, 76, 146, 252, 114, 4, 198, 228, 91, 62, 90, 251, 253, 108, 66, 173, 181, 43, 114, 60]), (bytes [118, 104, 94, 12, 171, 3, 100, 43, 163, 51, 98, 0, 105, 201, 187, 207, 164, 190, 117, 22, 243, 3, 26, 197, 37, 180, 195, 107, 243, 137, 220, 124]), (bytes [164, 26, 251, 214, 133, 166, 36, 43, 117, 5, 240, 52, 163, 40, 219, 81, 176, 185, 168, 189, 219, 54, 240, 69, 240, 249, 122, 226, 140, 80, 170, 67]), (bytes [166, 212, 193, 165, 216, 77, 223, 22, 85, 148, 36, 46, 240, 197, 91, 192, 178, 249, 84, 99, 56, 189, 17, 175, 26, 146, 194, 235, 103, 203, 78, 106]), (bytes [117, 242, 101, 249, 21, 218, 127, 164, 230, 14, 233, 247, 199, 35, 201, 180, 129, 56, 152, 49, 20, 39, 58, 252, 143, 181, 103, 38, 215, 227, 205, 255]), (bytes [222, 141, 194, 19, 109, 181, 115, 128, 236, 90, 109, 50, 95, 37, 244, 239, 168, 246, 17, 195, 87, 245, 230, 227, 255, 210, 73, 185, 49, 105, 109, 248]), (bytes [6, 254, 110, 187, 235, 232, 26, 224, 177, 208, 223, 63, 151, 116, 244, 68, 181, 38, 182, 164, 169, 160, 199, 77, 149, 179, 23, 120, 151, 178, 148, 93]), (bytes [140, 52, 163, 89, 55, 243, 29, 183, 25, 178, 87, 57, 109, 247, 133, 42, 53, 246, 249, 12, 226, 144, 235, 217, 39, 192, 123, 2, 224, 49, 95, 76]), (bytes [181, 45, 69, 158, 65, 145, 43, 151, 232, 63, 217, 66, 85, 8, 179, 187, 244, 58, 114, 255, 75, 18, 179, 199, 200, 112, 8, 236, 243, 16, 186, 249]), (bytes [102, 140, 9, 232, 29, 171, 94, 46, 215, 126, 135, 247, 204, 222, 182, 180, 95, 97, 36, 110, 94, 7, 203, 183, 0, 33, 2, 183, 177, 137, 38, 65]), (bytes [167, 92, 69, 232, 129, 215, 150, 22, 142, 134, 186, 133, 122, 187, 98, 237, 109, 67, 169, 68, 16, 1, 0, 92, 129, 181, 145, 172, 134, 6, 57, 205]), (bytes [100, 60, 107, 51, 83, 82, 9, 140, 176, 45, 55, 192, 93, 71, 222, 103, 180, 46, 64, 171, 208, 105, 248, 228, 140, 207, 120, 66, 72, 214, 145, 73]), (bytes [231, 38, 189, 225, 191, 28, 138, 109, 137, 172, 136, 41, 0, 71, 10, 98, 82, 251, 63, 57, 134, 215, 207, 171, 22, 74, 131, 24, 248, 187, 249, 139]), (bytes [97, 115, 66, 52, 209, 119, 244, 26, 211, 179, 72, 158, 73, 50, 167, 139, 193, 248, 17, 168, 194, 18, 40, 36, 247, 217, 33, 69, 229, 217, 187, 137]), (bytes [104, 29, 194, 189, 239, 145, 194, 228, 166, 76, 154, 100, 169, 199, 26, 134, 252, 202, 252, 43, 213, 142, 242, 213, 255, 181, 81, 2, 47, 120, 226, 78]), (bytes [235, 49, 191, 128, 17, 252, 43, 130, 234, 138, 63, 235, 22, 122, 39, 9, 154, 168, 135, 151, 54, 180, 125, 133, 235, 6, 32, 243, 247, 58, 14, 141]), (bytes [203, 190, 166, 159, 209, 140, 180, 196, 75, 57, 130, 2, 89, 126, 203, 127, 16, 89, 187, 132, 95, 49, 171, 164, 127, 162, 189, 129, 74, 157, 57, 123]), (bytes [133, 97, 222, 172, 108, 224, 100, 38, 133, 82, 44, 62, 153, 42, 213, 206, 217, 200, 97, 197, 218, 106, 13, 74, 224, 64, 192, 64, 26, 89, 139, 91]), (bytes [170, 154, 45, 6, 188, 185, 88, 196, 229, 167, 43, 205, 233, 108, 55, 179, 176, 186, 4, 153, 204, 108, 150, 247, 84, 185, 23, 182, 159, 241, 182, 243]), (bytes [115, 151, 31, 42, 19, 22, 27, 97, 49, 213, 126, 77, 7, 8, 14, 238, 203, 249, 232, 13, 112, 30, 96, 119, 42, 123, 67, 145, 170, 250, 236, 255]), (bytes [142, 185, 27, 84, 132, 190, 160, 121, 218, 162, 8, 170, 126, 198, 197, 139, 11, 168, 143, 88, 101, 75, 56, 240, 14, 204, 255, 67, 55, 121, 123, 195])], familyDigest := (bytes [12, 128, 33, 184, 242, 229, 158, 205, 212, 22, 196, 91, 161, 165, 57, 3, 196, 29, 120, 223, 240, 72, 12, 96, 48, 101, 55, 21, 177, 142, 153, 177]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [12, 128, 33, 184, 242, 229, 158, 205, 212, 22, 196, 91, 161, 165, 57, 3, 196, 29, 120, 223, 240, 72, 12, 96, 48, 101, 55, 21, 177, 142, 153, 177]), layoutVersion := 1, digest := (bytes [93, 23, 86, 205, 206, 29, 138, 233, 139, 64, 144, 44, 188, 38, 173, 57, 129, 205, 187, 114, 72, 255, 147, 152, 246, 183, 217, 134, 82, 228, 245, 143]) }, logicalIndex := 0, digest := (bytes [40, 153, 170, 234, 161, 158, 8, 182, 204, 130, 187, 230, 253, 2, 237, 116, 148, 12, 32, 189, 142, 149, 79, 41, 100, 176, 44, 56, 190, 210, 171, 125]) }, valueDigest := (bytes [59, 110, 73, 184, 21, 134, 14, 247, 63, 174, 178, 199, 142, 253, 82, 19, 165, 139, 8, 196, 235, 194, 3, 121, 51, 124, 231, 35, 211, 16, 32, 52]), digest := (bytes [107, 83, 143, 13, 16, 195, 28, 191, 30, 23, 48, 73, 127, 45, 146, 223, 29, 40, 32, 36, 96, 122, 180, 245, 149, 85, 174, 218, 110, 201, 84, 5]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [12, 128, 33, 184, 242, 229, 158, 205, 212, 22, 196, 91, 161, 165, 57, 3, 196, 29, 120, 223, 240, 72, 12, 96, 48, 101, 55, 21, 177, 142, 153, 177]), layoutVersion := 1, digest := (bytes [93, 23, 86, 205, 206, 29, 138, 233, 139, 64, 144, 44, 188, 38, 173, 57, 129, 205, 187, 114, 72, 255, 147, 152, 246, 183, 217, 134, 82, 228, 245, 143]) }, logicalIndex := 4, digest := (bytes [194, 12, 167, 103, 234, 76, 20, 49, 226, 134, 176, 114, 169, 245, 18, 142, 145, 27, 92, 50, 250, 244, 171, 207, 55, 205, 46, 129, 52, 49, 92, 99]) }, valueDigest := (bytes [247, 8, 91, 86, 174, 60, 198, 248, 80, 76, 136, 253, 192, 49, 138, 233, 64, 183, 153, 201, 60, 173, 121, 212, 113, 120, 175, 228, 9, 127, 13, 255]), digest := (bytes [185, 244, 106, 195, 5, 46, 56, 8, 140, 244, 184, 72, 72, 170, 174, 7, 161, 225, 151, 205, 116, 150, 66, 233, 90, 246, 89, 180, 145, 7, 221, 136]) }), digest := (bytes [213, 185, 142, 63, 202, 223, 100, 7, 247, 41, 30, 235, 165, 158, 145, 96, 6, 239, 117, 42, 138, 247, 217, 129, 87, 17, 62, 125, 247, 55, 111, 115]) }
  , rootLaneCommitment := { timeLen := 5, commitments := { commitmentCount := 38, digest := (bytes [167, 134, 219, 115, 157, 1, 205, 216, 94, 200, 200, 185, 201, 29, 37, 30, 211, 219, 133, 246, 131, 127, 123, 204, 232, 247, 119, 255, 193, 111, 1, 3]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [167, 134, 219, 115, 157, 1, 205, 216, 94, 200, 200, 185, 201, 29, 37, 30, 211, 219, 133, 246, 131, 127, 123, 204, 232, 247, 119, 255, 193, 111, 1, 3]), layoutVersion := 3, digest := (bytes [144, 1, 205, 205, 173, 23, 147, 240, 200, 216, 98, 186, 0, 44, 155, 17, 176, 29, 96, 184, 112, 37, 176, 54, 69, 12, 228, 43, 239, 187, 60, 244]) }, logicalIndex := 0, digest := (bytes [164, 80, 240, 165, 212, 106, 222, 27, 57, 122, 141, 225, 118, 133, 86, 173, 131, 2, 96, 85, 250, 193, 23, 124, 202, 22, 99, 160, 205, 211, 23, 21]) }, valueDigest := (bytes [59, 110, 73, 184, 21, 134, 14, 247, 63, 174, 178, 199, 142, 253, 82, 19, 165, 139, 8, 196, 235, 194, 3, 121, 51, 124, 231, 35, 211, 16, 32, 52]), digest := (bytes [239, 168, 197, 147, 208, 9, 141, 65, 93, 2, 147, 148, 71, 241, 158, 64, 43, 208, 77, 43, 187, 99, 136, 72, 199, 241, 17, 207, 187, 5, 220, 233]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [167, 134, 219, 115, 157, 1, 205, 216, 94, 200, 200, 185, 201, 29, 37, 30, 211, 219, 133, 246, 131, 127, 123, 204, 232, 247, 119, 255, 193, 111, 1, 3]), layoutVersion := 3, digest := (bytes [144, 1, 205, 205, 173, 23, 147, 240, 200, 216, 98, 186, 0, 44, 155, 17, 176, 29, 96, 184, 112, 37, 176, 54, 69, 12, 228, 43, 239, 187, 60, 244]) }, logicalIndex := 4, digest := (bytes [233, 101, 132, 148, 29, 173, 255, 87, 170, 115, 152, 184, 118, 32, 29, 187, 121, 72, 151, 174, 244, 84, 50, 230, 8, 34, 46, 40, 195, 220, 138, 156]) }, valueDigest := (bytes [247, 8, 91, 86, 174, 60, 198, 248, 80, 76, 136, 253, 192, 49, 138, 233, 64, 183, 153, 201, 60, 173, 121, 212, 113, 120, 175, 228, 9, 127, 13, 255]), digest := (bytes [92, 168, 23, 179, 76, 166, 139, 146, 145, 9, 165, 172, 55, 156, 201, 2, 123, 33, 172, 111, 248, 121, 159, 66, 43, 245, 188, 10, 10, 211, 195, 202]) }), digest := (bytes [119, 102, 74, 99, 233, 1, 220, 252, 149, 243, 0, 95, 112, 208, 28, 185, 56, 110, 175, 7, 228, 222, 66, 2, 6, 250, 230, 147, 202, 195, 106, 115]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [213, 185, 142, 63, 202, 223, 100, 7, 247, 41, 30, 235, 165, 158, 145, 96, 6, 239, 117, 42, 138, 247, 217, 129, 87, 17, 62, 125, 247, 55, 111, 115]), rootLaneCommitmentDigest := (bytes [119, 102, 74, 99, 233, 1, 220, 252, 149, 243, 0, 95, 112, 208, 28, 185, 56, 110, 175, 7, 228, 222, 66, 2, 6, 250, 230, 147, 202, 195, 106, 115]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 5, digest := (bytes [7, 132, 62, 118, 193, 167, 35, 55, 254, 245, 39, 205, 152, 212, 106, 245, 47, 132, 119, 36, 155, 239, 98, 59, 213, 78, 70, 207, 183, 105, 29, 39]) }, statementDigest := (bytes [119, 120, 234, 77, 68, 190, 62, 147, 225, 68, 229, 74, 209, 203, 43, 127, 39, 96, 171, 195, 168, 197, 18, 37, 146, 54, 179, 203, 150, 199, 213, 96]), proofDigest := (bytes [162, 235, 108, 114, 17, 211, 197, 55, 156, 142, 12, 232, 226, 57, 188, 57, 144, 131, 54, 251, 242, 149, 148, 126, 25, 211, 20, 223, 141, 64, 101, 188]), digest := (bytes [222, 82, 238, 140, 53, 221, 99, 9, 8, 44, 143, 219, 247, 90, 225, 228, 22, 134, 48, 59, 224, 198, 23, 39, 187, 209, 66, 75, 107, 204, 90, 253]) }
  , digest := (bytes [191, 175, 215, 16, 74, 149, 88, 119, 244, 156, 42, 255, 251, 140, 78, 22, 184, 135, 209, 230, 234, 193, 124, 119, 86, 184, 225, 140, 213, 163, 111, 127])
}
    , transcript := {
  appLabel := (bytes [110, 101, 111, 46, 102, 111, 108, 100, 46, 110, 101, 120, 116, 47, 114, 118, 54, 52, 105, 109, 47, 112, 97, 114, 105, 116, 121, 95, 107, 101, 114, 110, 101, 108, 95, 118, 49])
  , events := [{
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 116, 114, 97, 110, 115, 99, 114, 105, 112, 116, 95, 115, 101, 101, 100])
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 110, 97, 116, 105, 118, 101, 45, 119, 111, 114, 100, 45, 97, 114, 105, 116, 104, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [32194994931658615, 54383637722217, 94828755958258816, 10905788041622594868, 8841251816071870994, 13391653407446453246, 17446101127387435910, 7137168547377178156], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [110, 97, 116, 105, 118, 101, 95, 119, 111, 114, 100, 95, 97, 114, 105, 116, 104, 95, 99, 104, 97, 105, 110, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [32194994931658615, 54383637722217, 94828755958258816, 10905788041622594868, 8841251816071870994, 13391653407446453246, 17446101127387435910, 7137168547377178156], absorbed := 2 }
  , cursorAfter := { stateWords := [108, 8046472682260722215, 11003244355940537497, 8262967534387851701, 397115538058000933, 14291341217137120322, 5063051282974981007, 6543922063873665818], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [4293918875, 2130203, 4293563, 1080198203, 115]
  , cursorBefore := { stateWords := [108, 8046472682260722215, 11003244355940537497, 8262967534387851701, 397115538058000933, 14291341217137120322, 5063051282974981007, 6543922063873665818], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 6311794259304343875, 786608718250716959, 6100874164208755578, 2245851268550729477, 2299296669935983130, 2102865596656109285, 12771573547685203882], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 0, 0, 2147483647, 2, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [0, 6311794259304343875, 786608718250716959, 6100874164208755578, 2245851268550729477, 2299296669935983130, 2102865596656109285, 12771573547685203882], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 0, 0, 7729746327826397575, 6599925485313333755, 9380419606129479895, 6316302456827070885, 16537807392675284847], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [0, 0, 0, 7729746327826397575, 6599925485313333755, 9380419606129479895, 6316302456827070885, 16537807392675284847], absorbed := 3 }
  , cursorAfter := { stateWords := [0, 12812810021020622332, 16771512372732572291, 17691475649520698636, 7640299194629275762, 10369745949424242134, 17621312550387929647, 16140505857922087759], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [92, 172, 22, 138, 218, 1, 129, 66, 224, 89, 66, 175, 77, 144, 188, 74, 225, 81, 33, 159, 113, 152, 248, 210, 237, 253, 25, 73, 246, 251, 115, 40])
  , u64s := []
  , cursorBefore := { stateWords := [0, 12812810021020622332, 16771512372732572291, 17691475649520698636, 7640299194629275762, 10369745949424242134, 17621312550387929647, 16140505857922087759], absorbed := 1 }
  , cursorAfter := { stateWords := [7954902538515988277, 304032984545023206, 10859090316681308649, 1051498967781084287, 15597103504361850509, 7639111287890164627, 1032102716464711104, 4950509479344129651], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [7954902538515988277, 304032984545023206, 10859090316681308649, 1051498967781084287, 15597103504361850509, 7639111287890164627, 1032102716464711104, 4950509479344129651], absorbed := 0 }
  , cursorAfter := { stateWords := [10558873659545640745, 7460298059074088280, 12827188633621840837, 16788346924928290626, 9765819397153587279, 79730547694703652, 6899519008508010761, 18355073430232124729], absorbed := 0 }
  , challengeOutput := (some 10558873659545640745)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [49, 161, 13, 124, 3, 254, 251, 63, 149, 85, 118, 87, 149, 41, 33, 106, 239, 224, 235, 122, 124, 115, 70, 243, 63, 43, 7, 106, 43, 13, 29, 169])
  , u64s := []
  , cursorBefore := { stateWords := [10558873659545640745, 7460298059074088280, 12827188633621840837, 16788346924928290626, 9765819397153587279, 79730547694703652, 6899519008508010761, 18355073430232124729], absorbed := 0 }
  , cursorAfter := { stateWords := [35038050621811233, 29844229869225587, 2837253419, 14854758017280570924, 4753849291562509336, 17737008842207180361, 10221970253532858519, 13455280429100110128], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [35038050621811233, 29844229869225587, 2837253419, 14854758017280570924, 4753849291562509336, 17737008842207180361, 10221970253532858519, 13455280429100110128], absorbed := 3 }
  , cursorAfter := { stateWords := [8944266866017282416, 9083455127191587360, 15870788478240046116, 261411158637596961, 13497636338210299392, 7056894553339275005, 3922081986380945488, 7961356374822133845], absorbed := 0 }
  , challengeOutput := (some 8944266866017282416)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [8944266866017282416, 9083455127191587360, 15870788478240046116, 261411158637596961, 13497636338210299392, 7056894553339275005, 3922081986380945488, 7961356374822133845], absorbed := 0 }
  , cursorAfter := { stateWords := [13660259816919425627, 5443145891308723178, 3950869399485430737, 3465726298619999636, 17114001414304282808, 18361815826803384454, 11206596754129769351, 1492281674423093212], absorbed := 0 }
  , challengeOutput := (some 13660259816919425627)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [76, 67, 196, 204, 58, 160, 47, 32, 132, 98, 117, 189, 46, 75, 241, 54, 49, 21, 50, 72, 228, 63, 229, 152, 90, 2, 115, 124, 210, 7, 178, 52])
  , u64s := []
  , cursorBefore := { stateWords := [13660259816919425627, 5443145891308723178, 3950869399485430737, 3465726298619999636, 17114001414304282808, 18361815826803384454, 11206596754129769351, 1492281674423093212], absorbed := 0 }
  , cursorAfter := { stateWords := [64255674631141105, 35029351059219775, 884082642, 10963030985313958329, 9231525161699478297, 7184243167855036890, 4915572341140035318, 1204668759425625746], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [64255674631141105, 35029351059219775, 884082642, 10963030985313958329, 9231525161699478297, 7184243167855036890, 4915572341140035318, 1204668759425625746], absorbed := 3 }
  , cursorAfter := { stateWords := [17263612136838009662, 13675245253044482734, 18189201110177164880, 10969121987671422452, 5530659556502629132, 756279455560595800, 13966163538592164266, 5192032729948296536], absorbed := 0 }
  , challengeOutput := (some 17263612136838009662)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [2, 183, 132, 95, 231, 115, 83, 2, 8, 179, 51, 169, 210, 224, 230, 178, 60, 35, 73, 58, 195, 121, 109, 163, 86, 206, 95, 244, 250, 18, 169, 79])
  , u64s := []
  , cursorBefore := { stateWords := [17263612136838009662, 13675245253044482734, 18189201110177164880, 10969121987671422452, 5530659556502629132, 756279455560595800, 13966163538592164266, 5192032729948296536], absorbed := 0 }
  , cursorAfter := { stateWords := [54951706256782054, 68785234138852729, 1336480506, 5717146340749330168, 6508766975942125165, 17493974153028014702, 15761774315220503075, 2603304443319835626], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [12, 149, 33, 173, 171, 165, 54, 175, 9, 253, 234, 193, 13, 243, 189, 0, 121, 246, 75, 0, 67, 138, 71, 71, 204, 153, 161, 108, 26, 195, 251, 119])
  , u64s := []
  , cursorBefore := { stateWords := [54951706256782054, 68785234138852729, 1336480506, 5717146340749330168, 6508766975942125165, 17493974153028014702, 15761774315220503075, 2603304443319835626], absorbed := 3 }
  , cursorAfter := { stateWords := [18859149697286333, 30576979414042506, 2012988186, 7418949465302731250, 7786578273095239209, 5462410187322239503, 2647912887876074060, 3741130172918810497], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [210, 76, 200, 21, 4, 69, 15, 25, 203, 33, 125, 2, 33, 189, 7, 17, 57, 53, 132, 53, 135, 156, 153, 112, 132, 50, 0, 120, 169, 124, 149, 40])
  , u64s := []
  , cursorBefore := { stateWords := [18859149697286333, 30576979414042506, 2012988186, 7418949465302731250, 7786578273095239209, 5462410187322239503, 2647912887876074060, 3741130172918810497], absorbed := 3 }
  , cursorAfter := { stateWords := [38057963800826119, 33777214175615388, 680885417, 338818507502728935, 10922502945274482062, 3756922488108390693, 4388242078426305734, 50998364504691158], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [38057963800826119, 33777214175615388, 680885417, 338818507502728935, 10922502945274482062, 3756922488108390693, 4388242078426305734, 50998364504691158], absorbed := 3 }
  , cursorAfter := { stateWords := [1122637793534170640, 8865404261055412735, 15682186193226367635, 11087978790780904066, 10088335413447909684, 12063018804202447092, 7846450942697976053, 17981690237755468257], absorbed := 0 }
  , challengeOutput := (some 1122637793534170640)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [1122637793534170640, 8865404261055412735, 15682186193226367635, 11087978790780904066, 10088335413447909684, 12063018804202447092, 7846450942697976053, 17981690237755468257], absorbed := 0 }
  , cursorAfter := { stateWords := [17984682559556005781, 6806124958797347119, 3740396972043565589, 8535075898710175415, 13795396721678529870, 8029699745718555254, 13832823551608342223, 14647473703533060395], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [149, 175, 127, 64, 128, 109, 150, 249, 47, 57, 9, 242, 150, 54, 116, 94, 21, 122, 154, 133, 58, 143, 232, 51, 183, 46, 158, 33, 79, 174, 114, 118]))
}]
}
    , stage1 := stage1
    , stage2 := stage2
    , stage3 := stage3
    , rootExecution := rootExecution
    , stepComposition := stepComposition
    , soundnessAccounting := soundnessAccounting
    , kernelOpeningBundle := kernelOpeningBundle
    , digest := (bytes [199, 54, 99, 138, 228, 65, 242, 162, 120, 204, 165, 238, 223, 181, 149, 196, 87, 50, 200, 249, 88, 46, 236, 146, 145, 72, 158, 251, 192, 203, 129, 222])
  }

end Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors.Case_native_word_arith_chain_ecall
