import Nightstream.Rv64IM.Generated.AcceptedProofArtifactTypes

set_option maxHeartbeats 0
set_option maxRecDepth 65536

namespace Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors.Case_control_flow_bltu_taken_skip_ecall

open Nightstream.Rv64IM.Generated

def stage1SemInputs : List SemInView :=
  [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, pc := 0, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 1, archRdBefore := 0, archImm := 1, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 1, rdBefore := 0, rdAfter := 1, imm := 1, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, pc := 4, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 2, archRdBefore := 0, archImm := 2, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 2, rdBefore := 0, rdAfter := 2, imm := 2, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := true, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, pc := 8, opcode := .bltu, traceOpcode := (some .bltu), traceVirtualOpcode := none, family := .controlFlow, archRs1 := 1, archRs1Value := 1, archRs2 := 2, archRs2Value := 2, archRd := 0, archRdBefore := 0, archImm := 8, rs1 := 1, rs1Value := 1, rs2 := 2, rs2Value := 2, rd := 0, rdBefore := 0, rdAfter := 0, imm := 8, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := false, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, pc := 16, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, archRs1 := 0, archRs1Value := 0, archRs2 := 0, archRs2Value := 0, archRd := 0, archRdBefore := 0, archImm := 0, rs1 := 0, rs1Value := 0, rs2 := 0, rs2Value := 0, rd := 0, rdBefore := 0, rdAfter := 0, imm := 0, effectiveAddr := none, memoryBefore := none, memoryAfter := none, memWidthBytes := none, memUnsigned := none, writesRd := false, writesRam := false, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true }]

def stage1RowBindings : List Stage1RowBindingView :=
  [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 1048723, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 4, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 1, rdAfter := 1, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 2097427, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 8, aluResult := 2, effectiveAddr := none, writesRd := true, rd := 2, rdAfter := 2, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 2155619, opcode := .bltu, traceOpcode := (some .bltu), traceVirtualOpcode := none, family := .controlFlow, nextPc := 16, aluResult := 1, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 16, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 20, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }]

def stage1 : Stage1ProofBundleView :=
  {
    semInputs := stage1SemInputs
    , rowBindings := stage1RowBindings
    , bytecodeDigest := (bytes [165, 221, 194, 130, 242, 18, 123, 73, 90, 105, 252, 53, 213, 243, 74, 69, 249, 251, 41, 227, 45, 247, 212, 136, 240, 4, 48, 216, 119, 90, 237, 168])
    , aluDigest := (bytes [84, 177, 175, 49, 41, 155, 11, 179, 51, 176, 144, 225, 1, 30, 92, 17, 173, 22, 25, 12, 135, 21, 206, 224, 146, 212, 96, 202, 64, 133, 165, 218])
    , branchDigest := (bytes [78, 204, 158, 84, 101, 214, 217, 81, 43, 253, 71, 227, 130, 83, 220, 223, 94, 101, 37, 33, 187, 102, 17, 111, 128, 224, 20, 185, 131, 56, 89, 143])
    , semantics := { semInputsDigest := (bytes [109, 50, 212, 247, 253, 37, 139, 30, 224, 207, 220, 190, 34, 17, 183, 130, 229, 12, 37, 235, 167, 34, 81, 230, 105, 16, 177, 19, 113, 126, 102, 67]), rowBindingsDigest := (bytes [22, 41, 236, 172, 204, 107, 132, 172, 129, 42, 247, 200, 148, 125, 112, 219, 79, 130, 99, 119, 20, 49, 142, 46, 34, 227, 204, 119, 171, 178, 218, 49]), sequenceCount := 4, helperRowCount := 0, digest := (bytes [243, 98, 234, 219, 66, 1, 251, 198, 147, 232, 68, 52, 70, 31, 122, 146, 61, 132, 185, 179, 14, 236, 186, 18, 155, 67, 134, 56, 135, 81, 226, 107]) }
    , addressCorrectnessDigest := (bytes [104, 209, 8, 173, 106, 121, 66, 33, 80, 179, 75, 213, 53, 116, 181, 69, 179, 76, 81, 88, 199, 192, 29, 130, 66, 11, 177, 53, 7, 210, 168, 138])
    , linkageDigest := (bytes [141, 205, 189, 138, 211, 105, 159, 127, 145, 30, 189, 200, 255, 250, 253, 192, 60, 108, 123, 66, 189, 87, 212, 156, 44, 93, 229, 196, 43, 176, 91, 248])
    , selectedOpening := { claim := { rowsFamilyDigest := (bytes [22, 41, 236, 172, 204, 107, 132, 172, 129, 42, 247, 200, 148, 125, 112, 219, 79, 130, 99, 119, 20, 49, 142, 46, 34, 227, 204, 119, 171, 178, 218, 49]), rowCount := 4, effectRowCount := 4, commitRowCount := 4, realRowCount := 4, preservesX0Count := 2, firstTraceIndex := 0, effectTraceIndex := 0, commitTraceIndex := 0, lastTraceIndex := 3, mix := 12597393124285258733, points := { first := { id := { object := { familyTag := 1, commitmentDigest := (bytes [22, 41, 236, 172, 204, 107, 132, 172, 129, 42, 247, 200, 148, 125, 112, 219, 79, 130, 99, 119, 20, 49, 142, 46, 34, 227, 204, 119, 171, 178, 218, 49]), layoutVersion := 1, digest := (bytes [29, 26, 194, 229, 40, 43, 238, 183, 107, 24, 95, 62, 90, 214, 247, 134, 93, 71, 224, 15, 145, 221, 194, 214, 33, 58, 199, 98, 220, 43, 165, 233]) }, logicalIndex := 0, digest := (bytes [234, 146, 166, 211, 86, 115, 91, 237, 73, 17, 99, 6, 60, 181, 120, 122, 253, 192, 240, 201, 251, 25, 227, 87, 41, 104, 206, 211, 137, 7, 145, 9]) }, valueDigest := (bytes [32, 177, 93, 4, 194, 84, 97, 173, 64, 18, 168, 81, 246, 234, 52, 254, 43, 233, 61, 198, 55, 106, 236, 15, 107, 29, 198, 148, 168, 64, 112, 25]), digest := (bytes [99, 55, 157, 231, 225, 234, 105, 66, 34, 108, 176, 139, 147, 63, 46, 214, 133, 48, 174, 112, 252, 101, 2, 182, 26, 92, 22, 244, 148, 246, 145, 140]) }, effect := { id := { object := { familyTag := 1, commitmentDigest := (bytes [22, 41, 236, 172, 204, 107, 132, 172, 129, 42, 247, 200, 148, 125, 112, 219, 79, 130, 99, 119, 20, 49, 142, 46, 34, 227, 204, 119, 171, 178, 218, 49]), layoutVersion := 1, digest := (bytes [29, 26, 194, 229, 40, 43, 238, 183, 107, 24, 95, 62, 90, 214, 247, 134, 93, 71, 224, 15, 145, 221, 194, 214, 33, 58, 199, 98, 220, 43, 165, 233]) }, logicalIndex := 0, digest := (bytes [234, 146, 166, 211, 86, 115, 91, 237, 73, 17, 99, 6, 60, 181, 120, 122, 253, 192, 240, 201, 251, 25, 227, 87, 41, 104, 206, 211, 137, 7, 145, 9]) }, valueDigest := (bytes [32, 177, 93, 4, 194, 84, 97, 173, 64, 18, 168, 81, 246, 234, 52, 254, 43, 233, 61, 198, 55, 106, 236, 15, 107, 29, 198, 148, 168, 64, 112, 25]), digest := (bytes [99, 55, 157, 231, 225, 234, 105, 66, 34, 108, 176, 139, 147, 63, 46, 214, 133, 48, 174, 112, 252, 101, 2, 182, 26, 92, 22, 244, 148, 246, 145, 140]) }, commit := { id := { object := { familyTag := 1, commitmentDigest := (bytes [22, 41, 236, 172, 204, 107, 132, 172, 129, 42, 247, 200, 148, 125, 112, 219, 79, 130, 99, 119, 20, 49, 142, 46, 34, 227, 204, 119, 171, 178, 218, 49]), layoutVersion := 1, digest := (bytes [29, 26, 194, 229, 40, 43, 238, 183, 107, 24, 95, 62, 90, 214, 247, 134, 93, 71, 224, 15, 145, 221, 194, 214, 33, 58, 199, 98, 220, 43, 165, 233]) }, logicalIndex := 0, digest := (bytes [234, 146, 166, 211, 86, 115, 91, 237, 73, 17, 99, 6, 60, 181, 120, 122, 253, 192, 240, 201, 251, 25, 227, 87, 41, 104, 206, 211, 137, 7, 145, 9]) }, valueDigest := (bytes [32, 177, 93, 4, 194, 84, 97, 173, 64, 18, 168, 81, 246, 234, 52, 254, 43, 233, 61, 198, 55, 106, 236, 15, 107, 29, 198, 148, 168, 64, 112, 25]), digest := (bytes [99, 55, 157, 231, 225, 234, 105, 66, 34, 108, 176, 139, 147, 63, 46, 214, 133, 48, 174, 112, 252, 101, 2, 182, 26, 92, 22, 244, 148, 246, 145, 140]) }, last := { id := { object := { familyTag := 1, commitmentDigest := (bytes [22, 41, 236, 172, 204, 107, 132, 172, 129, 42, 247, 200, 148, 125, 112, 219, 79, 130, 99, 119, 20, 49, 142, 46, 34, 227, 204, 119, 171, 178, 218, 49]), layoutVersion := 1, digest := (bytes [29, 26, 194, 229, 40, 43, 238, 183, 107, 24, 95, 62, 90, 214, 247, 134, 93, 71, 224, 15, 145, 221, 194, 214, 33, 58, 199, 98, 220, 43, 165, 233]) }, logicalIndex := 3, digest := (bytes [220, 18, 174, 132, 57, 176, 110, 164, 241, 133, 174, 198, 51, 27, 198, 173, 97, 249, 181, 125, 162, 187, 142, 220, 224, 245, 238, 66, 225, 217, 147, 55]) }, valueDigest := (bytes [42, 117, 137, 62, 203, 77, 127, 14, 91, 68, 2, 177, 38, 250, 164, 28, 55, 139, 198, 41, 209, 72, 143, 173, 84, 204, 135, 91, 62, 25, 137, 209]), digest := (bytes [252, 157, 194, 247, 18, 252, 227, 49, 171, 1, 213, 30, 163, 219, 56, 78, 9, 228, 235, 214, 118, 27, 192, 29, 150, 111, 20, 244, 208, 20, 116, 165]) } }, digest := (bytes [217, 67, 223, 152, 67, 177, 14, 5, 220, 45, 17, 123, 36, 237, 197, 54, 150, 249, 173, 65, 33, 37, 208, 4, 160, 43, 135, 117, 22, 76, 176, 34]) }, packaged := { statementDigest := (bytes [101, 241, 123, 150, 199, 41, 140, 45, 254, 226, 128, 1, 63, 221, 160, 215, 14, 206, 153, 255, 156, 163, 152, 49, 183, 218, 162, 241, 187, 212, 19, 226]), proofDigest := (bytes [57, 43, 51, 204, 14, 65, 140, 50, 222, 27, 235, 151, 123, 10, 159, 250, 52, 204, 168, 187, 9, 214, 52, 71, 56, 94, 230, 200, 196, 172, 157, 243]) }, digest := (bytes [128, 238, 161, 239, 189, 69, 242, 121, 172, 205, 232, 176, 32, 68, 44, 111, 49, 93, 186, 52, 195, 192, 189, 151, 225, 186, 218, 219, 91, 240, 105, 63]) }
    , digest := (bytes [240, 177, 187, 222, 68, 54, 189, 124, 103, 82, 147, 216, 94, 143, 220, 113, 195, 145, 241, 215, 35, 194, 34, 75, 74, 204, 17, 46, 91, 48, 21, 114])
  }

def stage2RegisterReads : List RegisterReadEventView :=
  [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 0, value := 0 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 0, value := 0 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 1, value := 1 }, { traceIndex := 2, stepIndex := 2, role := .rs2, reg := 2, value := 2 }]

def stage2RegisterWrites : List RegisterWriteEventView :=
  [{ traceIndex := 0, stepIndex := 0, reg := 1, previous := 0, next := 1 }, { traceIndex := 1, stepIndex := 1, reg := 2, previous := 0, next := 2 }]

def stage2RamEvents : List RamEventView :=
  []

def stage2TwistLinks : List TwistLinkEventView :=
  [{ traceIndex := 0, stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 1, family := .nativeAlu, routedWriteValue := (some 2), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 2, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 3, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]

def stage2 : Stage2ProofBundleView :=
  {
    registerReads := stage2RegisterReads
    , registerWrites := stage2RegisterWrites
    , ramEvents := stage2RamEvents
    , registerDigest := (bytes [196, 108, 16, 187, 102, 118, 63, 109, 139, 37, 124, 247, 188, 46, 37, 37, 214, 143, 201, 247, 229, 54, 192, 80, 250, 39, 51, 168, 147, 43, 110, 220])
    , ramDigest := (bytes [209, 217, 105, 43, 209, 229, 156, 61, 92, 164, 94, 232, 52, 214, 73, 229, 72, 188, 139, 122, 165, 123, 201, 212, 205, 15, 247, 197, 165, 154, 109, 246])
    , temporal := { twistLinks := stage2TwistLinks, registerTimelineDigest := (bytes [189, 159, 156, 148, 199, 111, 89, 239, 46, 58, 241, 67, 150, 18, 187, 30, 208, 15, 248, 160, 201, 78, 255, 6, 137, 203, 88, 124, 186, 183, 204, 92]), ramTimelineDigest := (bytes [8, 117, 17, 140, 128, 180, 240, 140, 250, 181, 90, 134, 147, 17, 197, 122, 220, 8, 66, 15, 193, 254, 11, 122, 115, 210, 233, 239, 55, 132, 31, 228]), twistLinksDigest := (bytes [21, 12, 155, 212, 103, 191, 69, 1, 49, 127, 79, 63, 240, 167, 215, 246, 229, 205, 28, 105, 122, 205, 39, 193, 142, 137, 158, 200, 115, 41, 217, 117]), digest := (bytes [108, 218, 233, 116, 72, 77, 182, 107, 231, 233, 112, 254, 219, 215, 105, 165, 119, 11, 255, 206, 189, 234, 151, 135, 49, 15, 31, 104, 162, 58, 206, 231]) }
    , semantics := { registerReadsFamilyDigest := (bytes [110, 103, 80, 7, 22, 21, 56, 228, 233, 200, 128, 181, 105, 71, 79, 242, 212, 29, 150, 40, 34, 157, 245, 71, 17, 251, 74, 54, 24, 188, 182, 217]), registerWritesFamilyDigest := (bytes [112, 198, 242, 39, 200, 216, 169, 22, 226, 218, 239, 187, 27, 237, 167, 185, 166, 68, 142, 235, 219, 57, 136, 234, 32, 48, 197, 63, 95, 127, 33, 157]), ramEventsFamilyDigest := (bytes [85, 17, 108, 38, 84, 5, 109, 213, 145, 137, 203, 96, 117, 127, 130, 193, 117, 29, 27, 219, 228, 58, 7, 214, 144, 155, 66, 38, 127, 8, 241, 95]), twistLinksFamilyDigest := (bytes [230, 136, 125, 208, 240, 44, 217, 229, 7, 147, 252, 166, 243, 167, 207, 61, 10, 65, 114, 9, 169, 141, 192, 92, 25, 223, 171, 76, 221, 80, 184, 79]), rowCount := 4, registerEventCount := 6, ramEventCount := 0, digest := (bytes [208, 250, 63, 100, 144, 29, 15, 224, 75, 176, 51, 235, 128, 103, 116, 27, 49, 123, 54, 186, 197, 99, 134, 45, 45, 189, 98, 186, 0, 216, 31, 102]) }
    , linkageDigest := (bytes [169, 41, 25, 20, 24, 21, 57, 7, 2, 150, 3, 97, 230, 0, 227, 57, 255, 79, 247, 239, 118, 131, 130, 19, 134, 241, 231, 255, 19, 232, 190, 123])
    , selectedOpening := { claim := { registerReadsFamilyDigest := (bytes [110, 103, 80, 7, 22, 21, 56, 228, 233, 200, 128, 181, 105, 71, 79, 242, 212, 29, 150, 40, 34, 157, 245, 71, 17, 251, 74, 54, 24, 188, 182, 217]), registerWritesFamilyDigest := (bytes [112, 198, 242, 39, 200, 216, 169, 22, 226, 218, 239, 187, 27, 237, 167, 185, 166, 68, 142, 235, 219, 57, 136, 234, 32, 48, 197, 63, 95, 127, 33, 157]), ramEventsFamilyDigest := (bytes [85, 17, 108, 38, 84, 5, 109, 213, 145, 137, 203, 96, 117, 127, 130, 193, 117, 29, 27, 219, 228, 58, 7, 214, 144, 155, 66, 38, 127, 8, 241, 95]), twistLinksFamilyDigest := (bytes [230, 136, 125, 208, 240, 44, 217, 229, 7, 147, 252, 166, 243, 167, 207, 61, 10, 65, 114, 9, 169, 141, 192, 92, 25, 223, 171, 76, 221, 80, 184, 79]), registerReadCount := 4, registerWriteCount := 2, ramEventCount := 0, twistLinkCount := 4, ramReadCount := 0, ramWriteCount := 0, regMix := 8403032955572713120, ramMix := 6883570667930004418, points := { firstRead := (some { id := { object := { familyTag := 2, commitmentDigest := (bytes [110, 103, 80, 7, 22, 21, 56, 228, 233, 200, 128, 181, 105, 71, 79, 242, 212, 29, 150, 40, 34, 157, 245, 71, 17, 251, 74, 54, 24, 188, 182, 217]), layoutVersion := 1, digest := (bytes [71, 95, 48, 2, 33, 216, 114, 246, 76, 41, 241, 44, 9, 120, 198, 95, 39, 173, 102, 131, 203, 213, 195, 227, 221, 27, 0, 152, 171, 176, 135, 26]) }, logicalIndex := 0, digest := (bytes [120, 44, 30, 201, 64, 235, 2, 233, 185, 134, 158, 123, 71, 204, 3, 242, 146, 26, 233, 72, 59, 220, 203, 229, 125, 44, 210, 83, 2, 2, 64, 29]) }, valueDigest := (bytes [165, 2, 50, 180, 56, 84, 68, 13, 37, 136, 82, 191, 49, 42, 150, 67, 180, 45, 199, 251, 168, 91, 53, 39, 20, 9, 70, 46, 155, 135, 100, 116]), digest := (bytes [99, 160, 125, 63, 139, 42, 229, 243, 11, 180, 53, 160, 94, 14, 0, 234, 108, 154, 54, 40, 156, 202, 69, 219, 230, 59, 207, 166, 77, 222, 108, 241]) }), lastRead := (some { id := { object := { familyTag := 2, commitmentDigest := (bytes [110, 103, 80, 7, 22, 21, 56, 228, 233, 200, 128, 181, 105, 71, 79, 242, 212, 29, 150, 40, 34, 157, 245, 71, 17, 251, 74, 54, 24, 188, 182, 217]), layoutVersion := 1, digest := (bytes [71, 95, 48, 2, 33, 216, 114, 246, 76, 41, 241, 44, 9, 120, 198, 95, 39, 173, 102, 131, 203, 213, 195, 227, 221, 27, 0, 152, 171, 176, 135, 26]) }, logicalIndex := 3, digest := (bytes [191, 68, 4, 242, 103, 185, 162, 121, 129, 5, 10, 83, 79, 2, 163, 96, 151, 112, 164, 147, 19, 171, 116, 248, 193, 225, 128, 62, 232, 11, 170, 179]) }, valueDigest := (bytes [250, 62, 150, 81, 123, 172, 248, 93, 73, 51, 85, 40, 123, 75, 80, 250, 190, 161, 59, 107, 75, 124, 31, 181, 132, 35, 105, 221, 0, 35, 16, 3]), digest := (bytes [139, 11, 91, 223, 201, 1, 65, 224, 217, 187, 206, 120, 84, 9, 73, 108, 226, 137, 216, 72, 116, 0, 231, 95, 42, 24, 241, 3, 78, 172, 235, 217]) }), firstWrite := (some { id := { object := { familyTag := 3, commitmentDigest := (bytes [112, 198, 242, 39, 200, 216, 169, 22, 226, 218, 239, 187, 27, 237, 167, 185, 166, 68, 142, 235, 219, 57, 136, 234, 32, 48, 197, 63, 95, 127, 33, 157]), layoutVersion := 1, digest := (bytes [121, 76, 152, 210, 144, 165, 144, 211, 48, 146, 61, 53, 67, 125, 37, 153, 189, 123, 157, 126, 119, 115, 177, 54, 199, 33, 147, 248, 255, 168, 56, 170]) }, logicalIndex := 0, digest := (bytes [249, 131, 16, 75, 38, 246, 148, 196, 114, 197, 219, 104, 162, 223, 87, 8, 18, 161, 141, 233, 115, 228, 255, 163, 91, 113, 114, 25, 93, 248, 82, 248]) }, valueDigest := (bytes [6, 10, 8, 56, 28, 171, 254, 84, 147, 137, 212, 118, 68, 203, 11, 50, 81, 93, 22, 116, 174, 122, 49, 175, 71, 153, 47, 12, 222, 137, 227, 111]), digest := (bytes [189, 197, 207, 148, 172, 232, 11, 250, 16, 65, 19, 236, 201, 28, 31, 58, 196, 227, 98, 19, 214, 191, 93, 89, 76, 39, 204, 156, 66, 182, 233, 135]) }), lastWrite := (some { id := { object := { familyTag := 3, commitmentDigest := (bytes [112, 198, 242, 39, 200, 216, 169, 22, 226, 218, 239, 187, 27, 237, 167, 185, 166, 68, 142, 235, 219, 57, 136, 234, 32, 48, 197, 63, 95, 127, 33, 157]), layoutVersion := 1, digest := (bytes [121, 76, 152, 210, 144, 165, 144, 211, 48, 146, 61, 53, 67, 125, 37, 153, 189, 123, 157, 126, 119, 115, 177, 54, 199, 33, 147, 248, 255, 168, 56, 170]) }, logicalIndex := 1, digest := (bytes [184, 70, 49, 240, 125, 212, 190, 36, 7, 70, 115, 157, 36, 56, 110, 49, 237, 127, 160, 154, 134, 226, 102, 85, 12, 148, 40, 216, 140, 16, 113, 83]) }, valueDigest := (bytes [142, 145, 124, 31, 17, 108, 66, 81, 205, 245, 222, 235, 189, 52, 147, 135, 222, 24, 42, 80, 137, 58, 166, 55, 108, 194, 244, 91, 6, 239, 102, 27]), digest := (bytes [43, 128, 62, 236, 31, 142, 10, 207, 225, 148, 25, 252, 43, 194, 143, 243, 194, 82, 235, 156, 126, 152, 118, 47, 107, 134, 30, 33, 155, 200, 98, 114]) }), firstRam := none, lastRam := none, firstTwist := (some { id := { object := { familyTag := 5, commitmentDigest := (bytes [230, 136, 125, 208, 240, 44, 217, 229, 7, 147, 252, 166, 243, 167, 207, 61, 10, 65, 114, 9, 169, 141, 192, 92, 25, 223, 171, 76, 221, 80, 184, 79]), layoutVersion := 1, digest := (bytes [255, 194, 152, 172, 114, 83, 227, 116, 194, 102, 7, 97, 38, 237, 86, 203, 18, 248, 194, 85, 18, 215, 83, 36, 17, 17, 1, 200, 255, 246, 228, 105]) }, logicalIndex := 0, digest := (bytes [32, 252, 204, 41, 202, 169, 9, 142, 23, 43, 161, 46, 83, 200, 173, 90, 53, 253, 177, 168, 111, 95, 50, 160, 247, 133, 159, 200, 184, 20, 246, 19]) }, valueDigest := (bytes [6, 253, 89, 93, 65, 90, 254, 218, 186, 126, 113, 33, 125, 252, 29, 228, 182, 189, 94, 78, 106, 243, 59, 186, 226, 215, 103, 192, 49, 144, 186, 83]), digest := (bytes [165, 50, 197, 222, 137, 67, 242, 179, 35, 9, 141, 101, 152, 23, 105, 198, 248, 185, 151, 173, 250, 23, 204, 22, 152, 117, 0, 47, 30, 98, 23, 35]) }), lastTwist := (some { id := { object := { familyTag := 5, commitmentDigest := (bytes [230, 136, 125, 208, 240, 44, 217, 229, 7, 147, 252, 166, 243, 167, 207, 61, 10, 65, 114, 9, 169, 141, 192, 92, 25, 223, 171, 76, 221, 80, 184, 79]), layoutVersion := 1, digest := (bytes [255, 194, 152, 172, 114, 83, 227, 116, 194, 102, 7, 97, 38, 237, 86, 203, 18, 248, 194, 85, 18, 215, 83, 36, 17, 17, 1, 200, 255, 246, 228, 105]) }, logicalIndex := 3, digest := (bytes [129, 54, 69, 167, 106, 202, 52, 8, 124, 152, 95, 194, 212, 7, 184, 163, 147, 230, 11, 122, 223, 243, 234, 30, 150, 44, 170, 209, 204, 81, 54, 23]) }, valueDigest := (bytes [192, 220, 106, 41, 104, 255, 230, 149, 225, 60, 106, 47, 173, 175, 166, 9, 41, 27, 129, 156, 118, 121, 84, 121, 134, 180, 118, 205, 49, 136, 155, 48]), digest := (bytes [2, 242, 154, 13, 129, 21, 194, 164, 2, 100, 39, 1, 88, 54, 192, 139, 59, 202, 201, 110, 15, 161, 28, 66, 185, 168, 14, 155, 129, 13, 46, 239]) }) }, digest := (bytes [195, 96, 143, 199, 168, 1, 239, 17, 211, 66, 1, 156, 242, 15, 162, 112, 4, 80, 163, 201, 39, 249, 46, 245, 234, 9, 212, 222, 249, 142, 55, 81]) }, packaged := { statementDigest := (bytes [3, 245, 230, 226, 205, 230, 17, 248, 227, 168, 132, 158, 129, 158, 135, 240, 248, 163, 17, 45, 206, 196, 247, 96, 83, 179, 166, 155, 240, 20, 154, 83]), proofDigest := (bytes [222, 42, 198, 231, 158, 167, 43, 35, 0, 180, 250, 230, 120, 227, 106, 115, 161, 116, 14, 44, 193, 109, 118, 237, 179, 105, 63, 92, 51, 192, 246, 222]) }, digest := (bytes [216, 184, 107, 187, 133, 97, 85, 65, 217, 240, 211, 65, 137, 181, 151, 92, 186, 241, 133, 206, 73, 117, 12, 179, 62, 14, 50, 89, 167, 219, 181, 178]) }
    , digest := (bytes [6, 200, 253, 66, 188, 22, 161, 216, 21, 105, 47, 132, 143, 173, 78, 51, 115, 56, 220, 105, 234, 17, 1, 82, 210, 97, 90, 248, 107, 104, 11, 93])
  }

def stage3Continuity : List ContinuityEventView :=
  [{ stepIndex := 0, pc := 0, nextPc := 4, successorPc := (some 4), finalStep := false, continuityHolds := true }, { stepIndex := 1, pc := 4, nextPc := 8, successorPc := (some 8), finalStep := false, continuityHolds := true }, { stepIndex := 2, pc := 8, nextPc := 16, successorPc := (some 16), finalStep := false, continuityHolds := true }, { stepIndex := 3, pc := 16, nextPc := 20, successorPc := none, finalStep := true, continuityHolds := true }]

def stage3 : Stage3ProofBundleView :=
  {
    continuity := stage3Continuity
    , halted := true
    , bridgeDigest := (bytes [91, 155, 151, 36, 255, 29, 65, 219, 97, 184, 149, 17, 61, 71, 65, 67, 235, 95, 174, 182, 147, 224, 135, 172, 219, 41, 164, 217, 0, 115, 255, 45])
    , semantics := { continuityDigest := (bytes [225, 36, 55, 237, 16, 70, 173, 226, 205, 215, 188, 143, 132, 20, 5, 220, 229, 9, 111, 156, 132, 73, 165, 86, 137, 203, 45, 225, 35, 181, 205, 156]), rootSemanticRowsDigest := (bytes [187, 214, 16, 175, 210, 180, 123, 3, 178, 25, 57, 10, 170, 225, 131, 2, 36, 93, 0, 55, 67, 192, 34, 126, 215, 227, 162, 223, 189, 167, 219, 5]), rowChunkRoutesDigest := (bytes [170, 16, 215, 245, 131, 192, 198, 120, 95, 134, 175, 93, 217, 74, 16, 26, 237, 138, 81, 110, 201, 10, 195, 254, 244, 178, 29, 18, 146, 128, 117, 178]), preparedStepBindingsDigest := (bytes [104, 75, 53, 178, 188, 110, 48, 89, 175, 93, 43, 239, 84, 67, 42, 71, 136, 216, 132, 80, 70, 124, 99, 86, 180, 239, 48, 149, 81, 95, 247, 49]), stage2TemporalDigest := (bytes [108, 218, 233, 116, 72, 77, 182, 107, 231, 233, 112, 254, 219, 215, 105, 165, 119, 11, 255, 206, 189, 234, 151, 135, 49, 15, 31, 104, 162, 58, 206, 231]), initialPc := 0, finalPc := 20, realRowCount := 4, firstRealStepIndex := 0, lastRealStepIndex := 3, digest := (bytes [95, 196, 61, 68, 114, 26, 246, 218, 128, 45, 27, 165, 143, 121, 106, 96, 206, 223, 120, 214, 69, 10, 66, 243, 247, 124, 158, 250, 183, 230, 9, 120]) }
    , linkageDigest := (bytes [10, 182, 179, 175, 72, 65, 94, 218, 57, 141, 2, 100, 166, 68, 130, 23, 154, 179, 69, 97, 76, 126, 129, 67, 107, 123, 149, 19, 225, 60, 141, 235])
    , selectedOpening := { claim := { continuityFamilyDigest := (bytes [178, 177, 3, 134, 28, 140, 16, 149, 40, 220, 221, 198, 83, 202, 237, 105, 228, 80, 184, 187, 23, 255, 100, 66, 229, 141, 99, 228, 121, 52, 39, 88]), continuityCount := 4, finalStepCount := 1, halted := true, allContinuityHold := true, continuityMix := 5434653513256456592, points := { firstContinuity := (some { id := { object := { familyTag := 6, commitmentDigest := (bytes [178, 177, 3, 134, 28, 140, 16, 149, 40, 220, 221, 198, 83, 202, 237, 105, 228, 80, 184, 187, 23, 255, 100, 66, 229, 141, 99, 228, 121, 52, 39, 88]), layoutVersion := 1, digest := (bytes [236, 90, 105, 33, 46, 31, 185, 17, 37, 216, 190, 237, 8, 199, 200, 149, 254, 224, 190, 206, 223, 121, 110, 130, 238, 225, 162, 254, 31, 249, 173, 150]) }, logicalIndex := 0, digest := (bytes [36, 4, 204, 3, 12, 51, 32, 211, 254, 81, 204, 224, 109, 243, 139, 63, 6, 61, 51, 231, 182, 115, 199, 54, 57, 226, 50, 162, 160, 40, 253, 38]) }, valueDigest := (bytes [7, 131, 85, 21, 57, 109, 53, 31, 137, 53, 98, 18, 170, 36, 28, 200, 149, 213, 171, 159, 119, 200, 36, 230, 30, 35, 30, 11, 252, 126, 240, 63]), digest := (bytes [159, 221, 198, 197, 117, 106, 171, 81, 126, 42, 45, 192, 53, 222, 104, 114, 206, 226, 149, 147, 249, 97, 130, 60, 203, 233, 175, 235, 13, 126, 42, 204]) }), lastContinuity := (some { id := { object := { familyTag := 6, commitmentDigest := (bytes [178, 177, 3, 134, 28, 140, 16, 149, 40, 220, 221, 198, 83, 202, 237, 105, 228, 80, 184, 187, 23, 255, 100, 66, 229, 141, 99, 228, 121, 52, 39, 88]), layoutVersion := 1, digest := (bytes [236, 90, 105, 33, 46, 31, 185, 17, 37, 216, 190, 237, 8, 199, 200, 149, 254, 224, 190, 206, 223, 121, 110, 130, 238, 225, 162, 254, 31, 249, 173, 150]) }, logicalIndex := 3, digest := (bytes [185, 131, 50, 144, 41, 2, 89, 43, 206, 251, 1, 1, 71, 14, 103, 59, 244, 113, 72, 157, 221, 62, 96, 81, 169, 115, 86, 73, 16, 35, 0, 164]) }, valueDigest := (bytes [252, 134, 254, 33, 173, 19, 91, 16, 165, 37, 97, 183, 229, 243, 58, 241, 249, 218, 169, 205, 3, 229, 51, 197, 80, 15, 234, 120, 189, 254, 221, 45]), digest := (bytes [7, 151, 236, 244, 72, 147, 236, 219, 52, 132, 206, 18, 122, 251, 235, 250, 29, 51, 30, 67, 170, 84, 135, 7, 20, 212, 173, 168, 155, 255, 130, 67]) }) }, digest := (bytes [139, 112, 163, 203, 31, 53, 11, 3, 79, 107, 237, 144, 34, 124, 49, 191, 68, 55, 159, 38, 124, 207, 11, 179, 0, 208, 212, 134, 216, 42, 204, 187]) }, packaged := { statementDigest := (bytes [132, 115, 41, 225, 252, 36, 55, 233, 110, 63, 175, 149, 97, 241, 233, 229, 246, 215, 109, 133, 198, 176, 224, 69, 107, 32, 155, 204, 22, 135, 192, 144]), proofDigest := (bytes [252, 249, 192, 13, 161, 220, 119, 25, 224, 148, 212, 120, 220, 113, 219, 40, 237, 174, 227, 111, 166, 101, 11, 220, 79, 84, 114, 251, 129, 47, 142, 79]) }, digest := (bytes [191, 206, 12, 122, 147, 242, 118, 171, 192, 141, 23, 50, 182, 146, 160, 145, 190, 115, 129, 12, 181, 246, 179, 115, 150, 246, 22, 106, 186, 48, 187, 98]) }
    , digest := (bytes [158, 232, 121, 30, 153, 255, 158, 212, 129, 193, 86, 152, 182, 102, 60, 175, 229, 215, 182, 52, 39, 178, 178, 129, 64, 13, 17, 124, 108, 63, 81, 98])
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
  , word := 2097427
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
  , rdAfter := 2
  , imm := 2
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
  traceIndex := 2
  , stepIndex := 2
  , sequenceIndex := 0
  , pc := 8
  , nextPc := 16
  , word := 2155619
  , opcode := .bltu
  , traceOpcode := (some .bltu)
  , traceVirtualOpcode := none
  , family := .controlFlow
  , rs1 := 1
  , rs1Value := 1
  , rs2 := 2
  , rs2Value := 2
  , rd := 0
  , rdBefore := 0
  , rdAfter := 0
  , imm := 8
  , aluResult := 1
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
  traceIndex := 3
  , stepIndex := 3
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
  [{ traceIndex := 0, values := [1, 0, 0, 4, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 4, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [48, 9, 158, 59, 120, 45, 200, 155, 8, 144, 252, 183, 179, 168, 71, 138, 10, 136, 117, 72, 217, 133, 28, 26, 240, 134, 159, 61, 227, 8, 46, 227]), digest := (bytes [77, 97, 131, 255, 203, 134, 45, 198, 175, 166, 39, 170, 211, 141, 143, 44, 217, 157, 82, 58, 43, 137, 198, 85, 25, 93, 188, 205, 7, 120, 191, 196]) }, { traceIndex := 1, values := [1, 4, 0, 8, 0, 0, 0, 0, 0, 2, 0, 2, 0, 2, 0, 8, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [70, 47, 160, 13, 120, 207, 76, 53, 140, 139, 215, 66, 174, 158, 191, 164, 156, 135, 35, 152, 61, 51, 245, 84, 21, 20, 177, 220, 125, 18, 171, 99]), digest := (bytes [123, 38, 216, 14, 132, 221, 27, 75, 187, 77, 180, 27, 106, 4, 35, 167, 230, 21, 181, 68, 139, 29, 238, 155, 107, 11, 219, 33, 49, 60, 48, 33]) }, { traceIndex := 2, values := [1, 8, 0, 16, 0, 1, 0, 2, 0, 0, 0, 8, 0, 1, 0, 12, 0, 16, 0, 0, 0, 0, 0, 0, 1, 2, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1], rowDigest := (bytes [236, 235, 115, 226, 223, 190, 156, 70, 62, 31, 145, 219, 207, 64, 150, 19, 182, 14, 182, 224, 137, 58, 215, 78, 34, 69, 137, 79, 53, 84, 170, 78]), digest := (bytes [187, 225, 17, 250, 215, 83, 96, 16, 131, 195, 190, 246, 84, 16, 199, 84, 227, 118, 70, 185, 38, 229, 161, 66, 233, 0, 202, 139, 133, 80, 241, 168]) }, { traceIndex := 3, values := [1, 16, 0, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], rowDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [196, 164, 211, 128, 251, 108, 127, 209, 13, 46, 5, 165, 45, 208, 166, 224, 83, 53, 211, 10, 49, 76, 179, 158, 125, 185, 30, 27, 57, 200, 134, 221]) }]

def rootExecutionPreparedBindings : List PreparedStepBindingView :=
  [{ traceIndex := 0, rowDigest := (bytes [48, 9, 158, 59, 120, 45, 200, 155, 8, 144, 252, 183, 179, 168, 71, 138, 10, 136, 117, 72, 217, 133, 28, 26, 240, 134, 159, 61, 227, 8, 46, 227]), rowOpeningDigest := (bytes [157, 29, 105, 164, 228, 100, 34, 43, 226, 130, 195, 108, 5, 73, 10, 134, 63, 113, 148, 49, 24, 192, 159, 83, 170, 86, 173, 32, 237, 192, 45, 56]), digest := (bytes [228, 186, 196, 100, 214, 97, 204, 91, 47, 206, 34, 198, 29, 200, 203, 87, 232, 28, 132, 169, 17, 190, 217, 45, 135, 51, 200, 19, 206, 178, 215, 73]) }, { traceIndex := 1, rowDigest := (bytes [70, 47, 160, 13, 120, 207, 76, 53, 140, 139, 215, 66, 174, 158, 191, 164, 156, 135, 35, 152, 61, 51, 245, 84, 21, 20, 177, 220, 125, 18, 171, 99]), rowOpeningDigest := (bytes [191, 31, 27, 147, 252, 38, 139, 205, 205, 141, 197, 235, 107, 61, 80, 86, 44, 248, 235, 192, 125, 99, 203, 43, 129, 246, 62, 213, 171, 133, 132, 116]), digest := (bytes [247, 148, 54, 20, 238, 174, 253, 221, 163, 249, 219, 25, 180, 52, 169, 57, 188, 8, 123, 36, 198, 117, 38, 214, 83, 51, 75, 134, 190, 238, 238, 200]) }, { traceIndex := 2, rowDigest := (bytes [236, 235, 115, 226, 223, 190, 156, 70, 62, 31, 145, 219, 207, 64, 150, 19, 182, 14, 182, 224, 137, 58, 215, 78, 34, 69, 137, 79, 53, 84, 170, 78]), rowOpeningDigest := (bytes [57, 157, 223, 145, 78, 32, 156, 75, 80, 159, 61, 82, 104, 145, 199, 23, 76, 140, 185, 59, 156, 23, 230, 223, 241, 71, 141, 1, 19, 173, 191, 114]), digest := (bytes [125, 219, 85, 40, 254, 129, 169, 245, 181, 42, 95, 78, 187, 123, 154, 16, 181, 190, 213, 17, 128, 26, 124, 87, 38, 185, 4, 114, 185, 203, 22, 218]) }, { traceIndex := 3, rowDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), rowOpeningDigest := (bytes [124, 166, 215, 100, 149, 36, 226, 108, 212, 188, 194, 29, 21, 167, 128, 220, 35, 18, 192, 205, 143, 231, 17, 59, 34, 46, 111, 237, 195, 188, 201, 110]), digest := (bytes [254, 99, 83, 87, 142, 13, 25, 128, 17, 223, 67, 18, 69, 171, 237, 57, 247, 99, 239, 18, 152, 182, 82, 245, 246, 112, 106, 248, 5, 254, 200, 205]) }]

def rootExecutionRowChunkRoutes : List RowChunkRouteView :=
  [{ logicalIndex := 0, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 0, digest := (bytes [138, 198, 109, 126, 144, 82, 221, 43, 248, 202, 137, 103, 62, 226, 249, 152, 163, 187, 1, 254, 36, 33, 59, 16, 64, 166, 202, 8, 219, 57, 240, 59]) }, { logicalIndex := 1, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 1, digest := (bytes [44, 177, 82, 41, 218, 60, 100, 208, 26, 31, 151, 113, 109, 148, 57, 12, 223, 21, 76, 221, 70, 245, 191, 105, 57, 199, 8, 128, 181, 145, 89, 99]) }, { logicalIndex := 2, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 2, digest := (bytes [252, 248, 65, 24, 81, 241, 150, 170, 250, 116, 222, 30, 134, 191, 78, 195, 104, 119, 225, 210, 243, 186, 212, 107, 183, 31, 243, 201, 101, 148, 32, 72]) }, { logicalIndex := 3, chunkIndex := 0, chunkStartIndex := 0, chunkLocalIndex := 3, digest := (bytes [244, 11, 162, 13, 59, 43, 232, 47, 228, 2, 70, 126, 95, 10, 57, 40, 46, 107, 197, 81, 97, 39, 185, 163, 93, 60, 5, 66, 7, 231, 199, 134]) }]

def rootExecutionRowLocalCcsAcceptance : List RootRowLocalCcsAcceptanceView :=
  [{ traceIndex := 0, logicalIndex := 0, rowDigest := (bytes [48, 9, 158, 59, 120, 45, 200, 155, 8, 144, 252, 183, 179, 168, 71, 138, 10, 136, 117, 72, 217, 133, 28, 26, 240, 134, 159, 61, 227, 8, 46, 227]), rowOpeningDigest := (bytes [157, 29, 105, 164, 228, 100, 34, 43, 226, 130, 195, 108, 5, 73, 10, 134, 63, 113, 148, 49, 24, 192, 159, 83, 170, 86, 173, 32, 237, 192, 45, 56]), preparedStepBindingDigest := (bytes [228, 186, 196, 100, 214, 97, 204, 91, 47, 206, 34, 198, 29, 200, 203, 87, 232, 28, 132, 169, 17, 190, 217, 45, 135, 51, 200, 19, 206, 178, 215, 73]), rowChunkRouteDigest := (bytes [138, 198, 109, 126, 144, 82, 221, 43, 248, 202, 137, 103, 62, 226, 249, 152, 163, 187, 1, 254, 36, 33, 59, 16, 64, 166, 202, 8, 219, 57, 240, 59]), publicStepDigest := (bytes [176, 41, 96, 84, 84, 211, 190, 209, 187, 47, 137, 156, 111, 148, 42, 8, 243, 99, 64, 11, 14, 51, 190, 58, 185, 251, 119, 222, 238, 18, 74, 157]), digest := (bytes [199, 7, 133, 5, 250, 211, 78, 60, 56, 223, 47, 50, 190, 38, 11, 234, 238, 185, 61, 238, 101, 229, 10, 123, 191, 19, 162, 71, 98, 70, 198, 99]) }, { traceIndex := 1, logicalIndex := 1, rowDigest := (bytes [70, 47, 160, 13, 120, 207, 76, 53, 140, 139, 215, 66, 174, 158, 191, 164, 156, 135, 35, 152, 61, 51, 245, 84, 21, 20, 177, 220, 125, 18, 171, 99]), rowOpeningDigest := (bytes [191, 31, 27, 147, 252, 38, 139, 205, 205, 141, 197, 235, 107, 61, 80, 86, 44, 248, 235, 192, 125, 99, 203, 43, 129, 246, 62, 213, 171, 133, 132, 116]), preparedStepBindingDigest := (bytes [247, 148, 54, 20, 238, 174, 253, 221, 163, 249, 219, 25, 180, 52, 169, 57, 188, 8, 123, 36, 198, 117, 38, 214, 83, 51, 75, 134, 190, 238, 238, 200]), rowChunkRouteDigest := (bytes [44, 177, 82, 41, 218, 60, 100, 208, 26, 31, 151, 113, 109, 148, 57, 12, 223, 21, 76, 221, 70, 245, 191, 105, 57, 199, 8, 128, 181, 145, 89, 99]), publicStepDigest := (bytes [131, 0, 224, 130, 134, 176, 56, 209, 249, 226, 94, 133, 115, 71, 223, 183, 110, 38, 80, 32, 192, 43, 64, 242, 149, 103, 4, 34, 133, 223, 35, 244]), digest := (bytes [61, 207, 255, 151, 126, 79, 16, 186, 156, 141, 177, 89, 87, 202, 143, 138, 76, 109, 220, 26, 32, 241, 2, 98, 108, 108, 226, 0, 46, 134, 66, 87]) }, { traceIndex := 2, logicalIndex := 2, rowDigest := (bytes [236, 235, 115, 226, 223, 190, 156, 70, 62, 31, 145, 219, 207, 64, 150, 19, 182, 14, 182, 224, 137, 58, 215, 78, 34, 69, 137, 79, 53, 84, 170, 78]), rowOpeningDigest := (bytes [57, 157, 223, 145, 78, 32, 156, 75, 80, 159, 61, 82, 104, 145, 199, 23, 76, 140, 185, 59, 156, 23, 230, 223, 241, 71, 141, 1, 19, 173, 191, 114]), preparedStepBindingDigest := (bytes [125, 219, 85, 40, 254, 129, 169, 245, 181, 42, 95, 78, 187, 123, 154, 16, 181, 190, 213, 17, 128, 26, 124, 87, 38, 185, 4, 114, 185, 203, 22, 218]), rowChunkRouteDigest := (bytes [252, 248, 65, 24, 81, 241, 150, 170, 250, 116, 222, 30, 134, 191, 78, 195, 104, 119, 225, 210, 243, 186, 212, 107, 183, 31, 243, 201, 101, 148, 32, 72]), publicStepDigest := (bytes [28, 248, 179, 174, 212, 99, 0, 72, 236, 160, 202, 44, 162, 93, 135, 248, 233, 188, 212, 138, 179, 167, 108, 193, 31, 155, 39, 147, 24, 37, 124, 192]), digest := (bytes [207, 70, 51, 167, 65, 254, 182, 202, 155, 154, 239, 78, 27, 102, 223, 70, 55, 207, 111, 149, 144, 57, 1, 163, 133, 47, 93, 154, 139, 157, 223, 37]) }, { traceIndex := 3, logicalIndex := 3, rowDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), rowOpeningDigest := (bytes [124, 166, 215, 100, 149, 36, 226, 108, 212, 188, 194, 29, 21, 167, 128, 220, 35, 18, 192, 205, 143, 231, 17, 59, 34, 46, 111, 237, 195, 188, 201, 110]), preparedStepBindingDigest := (bytes [254, 99, 83, 87, 142, 13, 25, 128, 17, 223, 67, 18, 69, 171, 237, 57, 247, 99, 239, 18, 152, 182, 82, 245, 246, 112, 106, 248, 5, 254, 200, 205]), rowChunkRouteDigest := (bytes [244, 11, 162, 13, 59, 43, 232, 47, 228, 2, 70, 126, 95, 10, 57, 40, 46, 107, 197, 81, 97, 39, 185, 163, 93, 60, 5, 66, 7, 231, 199, 134]), publicStepDigest := (bytes [72, 142, 192, 218, 173, 197, 55, 221, 78, 31, 126, 194, 22, 139, 72, 204, 128, 208, 103, 242, 122, 221, 175, 246, 50, 244, 221, 89, 210, 23, 111, 183]), digest := (bytes [107, 5, 158, 158, 138, 134, 139, 188, 31, 141, 7, 103, 228, 247, 46, 13, 99, 3, 101, 231, 98, 248, 41, 235, 35, 4, 11, 206, 99, 162, 36, 70]) }]

def rootExecutionExecutionSemanticsRefinement : List RootExecutionSemanticsRefinementView :=
  [{ traceIndex := 0, logicalIndex := 0, semanticRowDigest := (bytes [77, 97, 131, 255, 203, 134, 45, 198, 175, 166, 39, 170, 211, 141, 143, 44, 217, 157, 82, 58, 43, 137, 198, 85, 25, 93, 188, 205, 7, 120, 191, 196]), rowLocalCcsAcceptanceDigest := (bytes [199, 7, 133, 5, 250, 211, 78, 60, 56, 223, 47, 50, 190, 38, 11, 234, 238, 185, 61, 238, 101, 229, 10, 123, 191, 19, 162, 71, 98, 70, 198, 99]), preparedStepBindingDigest := (bytes [228, 186, 196, 100, 214, 97, 204, 91, 47, 206, 34, 198, 29, 200, 203, 87, 232, 28, 132, 169, 17, 190, 217, 45, 135, 51, 200, 19, 206, 178, 215, 73]), publicStepDigest := (bytes [176, 41, 96, 84, 84, 211, 190, 209, 187, 47, 137, 156, 111, 148, 42, 8, 243, 99, 64, 11, 14, 51, 190, 58, 185, 251, 119, 222, 238, 18, 74, 157]), digest := (bytes [42, 73, 38, 202, 199, 218, 121, 237, 134, 53, 198, 123, 114, 217, 200, 134, 197, 29, 220, 187, 117, 158, 247, 214, 98, 59, 6, 107, 159, 28, 133, 75]) }, { traceIndex := 1, logicalIndex := 1, semanticRowDigest := (bytes [123, 38, 216, 14, 132, 221, 27, 75, 187, 77, 180, 27, 106, 4, 35, 167, 230, 21, 181, 68, 139, 29, 238, 155, 107, 11, 219, 33, 49, 60, 48, 33]), rowLocalCcsAcceptanceDigest := (bytes [61, 207, 255, 151, 126, 79, 16, 186, 156, 141, 177, 89, 87, 202, 143, 138, 76, 109, 220, 26, 32, 241, 2, 98, 108, 108, 226, 0, 46, 134, 66, 87]), preparedStepBindingDigest := (bytes [247, 148, 54, 20, 238, 174, 253, 221, 163, 249, 219, 25, 180, 52, 169, 57, 188, 8, 123, 36, 198, 117, 38, 214, 83, 51, 75, 134, 190, 238, 238, 200]), publicStepDigest := (bytes [131, 0, 224, 130, 134, 176, 56, 209, 249, 226, 94, 133, 115, 71, 223, 183, 110, 38, 80, 32, 192, 43, 64, 242, 149, 103, 4, 34, 133, 223, 35, 244]), digest := (bytes [205, 164, 94, 59, 229, 20, 6, 238, 182, 133, 31, 154, 110, 85, 236, 150, 185, 95, 48, 20, 213, 68, 125, 223, 248, 60, 110, 133, 163, 124, 240, 77]) }, { traceIndex := 2, logicalIndex := 2, semanticRowDigest := (bytes [187, 225, 17, 250, 215, 83, 96, 16, 131, 195, 190, 246, 84, 16, 199, 84, 227, 118, 70, 185, 38, 229, 161, 66, 233, 0, 202, 139, 133, 80, 241, 168]), rowLocalCcsAcceptanceDigest := (bytes [207, 70, 51, 167, 65, 254, 182, 202, 155, 154, 239, 78, 27, 102, 223, 70, 55, 207, 111, 149, 144, 57, 1, 163, 133, 47, 93, 154, 139, 157, 223, 37]), preparedStepBindingDigest := (bytes [125, 219, 85, 40, 254, 129, 169, 245, 181, 42, 95, 78, 187, 123, 154, 16, 181, 190, 213, 17, 128, 26, 124, 87, 38, 185, 4, 114, 185, 203, 22, 218]), publicStepDigest := (bytes [28, 248, 179, 174, 212, 99, 0, 72, 236, 160, 202, 44, 162, 93, 135, 248, 233, 188, 212, 138, 179, 167, 108, 193, 31, 155, 39, 147, 24, 37, 124, 192]), digest := (bytes [56, 148, 64, 159, 166, 203, 93, 252, 192, 1, 163, 45, 19, 91, 39, 227, 124, 229, 73, 198, 120, 128, 142, 155, 181, 115, 41, 41, 136, 107, 145, 185]) }, { traceIndex := 3, logicalIndex := 3, semanticRowDigest := (bytes [196, 164, 211, 128, 251, 108, 127, 209, 13, 46, 5, 165, 45, 208, 166, 224, 83, 53, 211, 10, 49, 76, 179, 158, 125, 185, 30, 27, 57, 200, 134, 221]), rowLocalCcsAcceptanceDigest := (bytes [107, 5, 158, 158, 138, 134, 139, 188, 31, 141, 7, 103, 228, 247, 46, 13, 99, 3, 101, 231, 98, 248, 41, 235, 35, 4, 11, 206, 99, 162, 36, 70]), preparedStepBindingDigest := (bytes [254, 99, 83, 87, 142, 13, 25, 128, 17, 223, 67, 18, 69, 171, 237, 57, 247, 99, 239, 18, 152, 182, 82, 245, 246, 112, 106, 248, 5, 254, 200, 205]), publicStepDigest := (bytes [72, 142, 192, 218, 173, 197, 55, 221, 78, 31, 126, 194, 22, 139, 72, 204, 128, 208, 103, 242, 122, 221, 175, 246, 50, 244, 221, 89, 210, 23, 111, 183]), digest := (bytes [216, 101, 236, 83, 88, 81, 162, 177, 227, 64, 20, 231, 234, 192, 76, 164, 70, 187, 252, 226, 72, 13, 177, 187, 230, 163, 239, 117, 233, 197, 145, 140]) }]

def rootExecution : RootExecutionBundleView :=
  {
    executionRows := rootExecutionExecutionRows
    , semanticRows := rootExecutionSemanticRows
    , semanticRowsDigest := (bytes [187, 214, 16, 175, 210, 180, 123, 3, 178, 25, 57, 10, 170, 225, 131, 2, 36, 93, 0, 55, 67, 192, 34, 126, 215, 227, 162, 223, 189, 167, 219, 5])
    , preparedStepBindings := { bindings := rootExecutionPreparedBindings, bindingCount := 4, firstBindingDigest := (some (bytes [228, 186, 196, 100, 214, 97, 204, 91, 47, 206, 34, 198, 29, 200, 203, 87, 232, 28, 132, 169, 17, 190, 217, 45, 135, 51, 200, 19, 206, 178, 215, 73])), lastBindingDigest := (some (bytes [254, 99, 83, 87, 142, 13, 25, 128, 17, 223, 67, 18, 69, 171, 237, 57, 247, 99, 239, 18, 152, 182, 82, 245, 246, 112, 106, 248, 5, 254, 200, 205])), digest := (bytes [104, 75, 53, 178, 188, 110, 48, 89, 175, 93, 43, 239, 84, 67, 42, 71, 136, 216, 132, 80, 70, 124, 99, 86, 180, 239, 48, 149, 81, 95, 247, 49]) }
    , rowChunkRoutes := rootExecutionRowChunkRoutes
    , rowChunkRoutesDigest := (bytes [170, 16, 215, 245, 131, 192, 198, 120, 95, 134, 175, 93, 217, 74, 16, 26, 237, 138, 81, 110, 201, 10, 195, 254, 244, 178, 29, 18, 146, 128, 117, 178])
    , rowLocalCcsAcceptance := { acceptances := rootExecutionRowLocalCcsAcceptance, acceptanceCount := 4, firstAcceptanceDigest := (some (bytes [199, 7, 133, 5, 250, 211, 78, 60, 56, 223, 47, 50, 190, 38, 11, 234, 238, 185, 61, 238, 101, 229, 10, 123, 191, 19, 162, 71, 98, 70, 198, 99])), lastAcceptanceDigest := (some (bytes [107, 5, 158, 158, 138, 134, 139, 188, 31, 141, 7, 103, 228, 247, 46, 13, 99, 3, 101, 231, 98, 248, 41, 235, 35, 4, 11, 206, 99, 162, 36, 70])), digest := (bytes [4, 58, 162, 12, 169, 110, 118, 124, 246, 156, 136, 241, 39, 142, 170, 167, 41, 212, 222, 239, 169, 49, 251, 37, 109, 72, 204, 64, 188, 227, 212, 111]) }
    , executionSemanticsRefinement := { refinements := rootExecutionExecutionSemanticsRefinement, refinementCount := 4, firstRefinementDigest := (some (bytes [42, 73, 38, 202, 199, 218, 121, 237, 134, 53, 198, 123, 114, 217, 200, 134, 197, 29, 220, 187, 117, 158, 247, 214, 98, 59, 6, 107, 159, 28, 133, 75])), lastRefinementDigest := (some (bytes [216, 101, 236, 83, 88, 81, 162, 177, 227, 64, 20, 231, 234, 192, 76, 164, 70, 187, 252, 226, 72, 13, 177, 187, 230, 163, 239, 117, 233, 197, 145, 140])), digest := (bytes [228, 246, 64, 128, 58, 125, 113, 142, 17, 73, 55, 229, 20, 235, 141, 203, 4, 203, 192, 239, 58, 42, 222, 40, 237, 1, 144, 74, 70, 164, 62, 36]) }
    , familyDigest := (bytes [60, 226, 26, 9, 218, 106, 1, 219, 145, 76, 252, 6, 9, 158, 230, 215, 33, 119, 133, 248, 125, 83, 74, 254, 42, 99, 109, 35, 207, 217, 240, 185])
    , digest := (bytes [140, 83, 96, 196, 82, 205, 200, 112, 86, 67, 80, 0, 246, 29, 200, 34, 170, 52, 182, 85, 119, 49, 187, 250, 106, 234, 198, 23, 173, 176, 231, 57])
  }

def kernelOpeningBundle : SimpleKernelOpeningBundleView :=
  {
    claim := { bindings := { stageClaimBundleDigest := (bytes [111, 175, 105, 140, 80, 17, 142, 93, 248, 164, 96, 185, 48, 162, 95, 31, 129, 229, 91, 133, 255, 51, 20, 113, 142, 90, 183, 115, 215, 9, 119, 221]), stagePackageBundleDigest := (bytes [103, 100, 104, 36, 35, 103, 162, 168, 213, 214, 209, 209, 132, 135, 142, 250, 213, 132, 243, 119, 145, 105, 161, 140, 83, 177, 48, 60, 14, 167, 180, 141]), stage1PackageDigest := (bytes [128, 238, 161, 239, 189, 69, 242, 121, 172, 205, 232, 176, 32, 68, 44, 111, 49, 93, 186, 52, 195, 192, 189, 151, 225, 186, 218, 219, 91, 240, 105, 63]), stage2PackageDigest := (bytes [216, 184, 107, 187, 133, 97, 85, 65, 217, 240, 211, 65, 137, 181, 151, 92, 186, 241, 133, 206, 73, 117, 12, 179, 62, 14, 50, 89, 167, 219, 181, 178]), stage3PackageDigest := (bytes [191, 206, 12, 122, 147, 242, 118, 171, 192, 141, 23, 50, 182, 146, 160, 145, 190, 115, 129, 12, 181, 246, 179, 115, 150, 246, 22, 106, 186, 48, 187, 98]), preparedStepBindingsDigest := (bytes [104, 75, 53, 178, 188, 110, 48, 89, 175, 93, 43, 239, 84, 67, 42, 71, 136, 216, 132, 80, 70, 124, 99, 86, 180, 239, 48, 149, 81, 95, 247, 49]), bindingCount := 4, stage1RowCount := 4, stage2RegisterReadCount := 4, stage2RegisterWriteCount := 2, stage2RamEventCount := 0, stage3ContinuityCount := 4, points := { firstBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [104, 75, 53, 178, 188, 110, 48, 89, 175, 93, 43, 239, 84, 67, 42, 71, 136, 216, 132, 80, 70, 124, 99, 86, 180, 239, 48, 149, 81, 95, 247, 49]), layoutVersion := 1, digest := (bytes [157, 74, 213, 92, 21, 143, 104, 70, 167, 57, 133, 96, 213, 203, 180, 11, 176, 28, 44, 178, 209, 200, 8, 14, 117, 149, 32, 226, 53, 179, 240, 190]) }, logicalIndex := 0, digest := (bytes [211, 211, 70, 182, 184, 53, 141, 104, 134, 60, 73, 233, 229, 174, 3, 170, 14, 87, 169, 15, 16, 178, 49, 220, 228, 214, 47, 236, 184, 72, 75, 86]) }, valueDigest := (bytes [228, 186, 196, 100, 214, 97, 204, 91, 47, 206, 34, 198, 29, 200, 203, 87, 232, 28, 132, 169, 17, 190, 217, 45, 135, 51, 200, 19, 206, 178, 215, 73]), digest := (bytes [23, 19, 112, 187, 209, 190, 78, 196, 238, 107, 34, 112, 45, 5, 137, 181, 104, 243, 215, 11, 107, 132, 84, 255, 27, 52, 22, 136, 180, 178, 199, 227]) }), lastBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [104, 75, 53, 178, 188, 110, 48, 89, 175, 93, 43, 239, 84, 67, 42, 71, 136, 216, 132, 80, 70, 124, 99, 86, 180, 239, 48, 149, 81, 95, 247, 49]), layoutVersion := 1, digest := (bytes [157, 74, 213, 92, 21, 143, 104, 70, 167, 57, 133, 96, 213, 203, 180, 11, 176, 28, 44, 178, 209, 200, 8, 14, 117, 149, 32, 226, 53, 179, 240, 190]) }, logicalIndex := 3, digest := (bytes [24, 182, 29, 173, 165, 19, 193, 165, 43, 159, 171, 21, 131, 127, 249, 93, 242, 6, 204, 106, 212, 65, 95, 179, 2, 236, 154, 152, 35, 118, 80, 105]) }, valueDigest := (bytes [254, 99, 83, 87, 142, 13, 25, 128, 17, 223, 67, 18, 69, 171, 237, 57, 247, 99, 239, 18, 152, 182, 82, 245, 246, 112, 106, 248, 5, 254, 200, 205]), digest := (bytes [9, 192, 76, 175, 82, 254, 212, 243, 74, 103, 105, 91, 175, 109, 201, 122, 157, 192, 148, 154, 74, 141, 89, 84, 250, 28, 123, 69, 63, 95, 90, 85]) }) }, digest := (bytes [4, 71, 49, 234, 114, 227, 234, 76, 205, 198, 212, 82, 116, 208, 111, 207, 198, 4, 57, 209, 146, 91, 49, 81, 194, 229, 217, 245, 158, 148, 132, 74]) }, preparedSteps := { executionDigest := (bytes [141, 81, 95, 195, 231, 84, 171, 240, 150, 119, 148, 108, 81, 62, 93, 105, 24, 74, 13, 118, 229, 236, 2, 205, 125, 30, 81, 145, 166, 192, 80, 84]), finalStateDigest := (bytes [145, 232, 119, 42, 209, 144, 217, 53, 205, 241, 241, 70, 26, 199, 99, 90, 150, 109, 80, 126, 52, 204, 98, 226, 231, 236, 152, 221, 67, 149, 32, 60]), transcriptFinalDigest := (bytes [32, 9, 174, 199, 85, 101, 126, 146, 43, 45, 60, 37, 147, 31, 232, 252, 13, 140, 146, 138, 4, 31, 72, 38, 94, 151, 226, 196, 134, 177, 219, 179]), preparedStepCount := 4, finalPc := 20, halted := true, points := { firstPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [192, 237, 17, 53, 235, 29, 69, 55, 72, 94, 126, 40, 158, 253, 226, 47, 115, 226, 118, 182, 238, 41, 184, 33, 102, 49, 153, 185, 96, 71, 8, 3]), layoutVersion := 3, digest := (bytes [201, 236, 21, 58, 166, 238, 253, 205, 43, 109, 28, 246, 241, 38, 130, 177, 148, 193, 63, 77, 7, 120, 159, 109, 253, 43, 61, 69, 115, 94, 174, 88]) }, logicalIndex := 0, digest := (bytes [176, 163, 215, 61, 193, 203, 148, 52, 42, 158, 76, 174, 148, 4, 72, 111, 177, 60, 17, 171, 220, 102, 81, 247, 70, 125, 58, 43, 236, 26, 94, 45]) }, valueDigest := (bytes [48, 9, 158, 59, 120, 45, 200, 155, 8, 144, 252, 183, 179, 168, 71, 138, 10, 136, 117, 72, 217, 133, 28, 26, 240, 134, 159, 61, 227, 8, 46, 227]), digest := (bytes [234, 196, 19, 209, 186, 228, 212, 26, 38, 142, 39, 225, 81, 151, 86, 95, 113, 78, 96, 219, 206, 214, 155, 189, 52, 238, 232, 200, 40, 66, 250, 181]) }), lastPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [192, 237, 17, 53, 235, 29, 69, 55, 72, 94, 126, 40, 158, 253, 226, 47, 115, 226, 118, 182, 238, 41, 184, 33, 102, 49, 153, 185, 96, 71, 8, 3]), layoutVersion := 3, digest := (bytes [201, 236, 21, 58, 166, 238, 253, 205, 43, 109, 28, 246, 241, 38, 130, 177, 148, 193, 63, 77, 7, 120, 159, 109, 253, 43, 61, 69, 115, 94, 174, 88]) }, logicalIndex := 3, digest := (bytes [236, 197, 73, 220, 3, 71, 76, 31, 216, 219, 236, 53, 55, 174, 245, 177, 142, 213, 29, 54, 114, 245, 162, 1, 207, 96, 239, 222, 68, 233, 246, 139]) }, valueDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [183, 180, 41, 104, 220, 26, 126, 24, 172, 193, 152, 11, 61, 109, 89, 163, 114, 254, 104, 154, 139, 107, 198, 57, 21, 41, 181, 174, 163, 37, 161, 52]) }) }, digest := (bytes [34, 79, 165, 242, 223, 67, 169, 120, 62, 107, 187, 25, 230, 103, 232, 248, 222, 106, 165, 57, 214, 145, 122, 74, 200, 15, 128, 103, 201, 163, 227, 88]) }, digest := (bytes [72, 7, 3, 5, 173, 99, 193, 180, 81, 164, 158, 216, 223, 154, 53, 146, 6, 46, 137, 251, 184, 226, 234, 166, 27, 2, 53, 110, 232, 232, 135, 156]) }
    , bindings := { claim := { stageClaimBundleDigest := (bytes [111, 175, 105, 140, 80, 17, 142, 93, 248, 164, 96, 185, 48, 162, 95, 31, 129, 229, 91, 133, 255, 51, 20, 113, 142, 90, 183, 115, 215, 9, 119, 221]), stagePackageBundleDigest := (bytes [103, 100, 104, 36, 35, 103, 162, 168, 213, 214, 209, 209, 132, 135, 142, 250, 213, 132, 243, 119, 145, 105, 161, 140, 83, 177, 48, 60, 14, 167, 180, 141]), stage1PackageDigest := (bytes [128, 238, 161, 239, 189, 69, 242, 121, 172, 205, 232, 176, 32, 68, 44, 111, 49, 93, 186, 52, 195, 192, 189, 151, 225, 186, 218, 219, 91, 240, 105, 63]), stage2PackageDigest := (bytes [216, 184, 107, 187, 133, 97, 85, 65, 217, 240, 211, 65, 137, 181, 151, 92, 186, 241, 133, 206, 73, 117, 12, 179, 62, 14, 50, 89, 167, 219, 181, 178]), stage3PackageDigest := (bytes [191, 206, 12, 122, 147, 242, 118, 171, 192, 141, 23, 50, 182, 146, 160, 145, 190, 115, 129, 12, 181, 246, 179, 115, 150, 246, 22, 106, 186, 48, 187, 98]), preparedStepBindingsDigest := (bytes [104, 75, 53, 178, 188, 110, 48, 89, 175, 93, 43, 239, 84, 67, 42, 71, 136, 216, 132, 80, 70, 124, 99, 86, 180, 239, 48, 149, 81, 95, 247, 49]), bindingCount := 4, stage1RowCount := 4, stage2RegisterReadCount := 4, stage2RegisterWriteCount := 2, stage2RamEventCount := 0, stage3ContinuityCount := 4, points := { firstBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [104, 75, 53, 178, 188, 110, 48, 89, 175, 93, 43, 239, 84, 67, 42, 71, 136, 216, 132, 80, 70, 124, 99, 86, 180, 239, 48, 149, 81, 95, 247, 49]), layoutVersion := 1, digest := (bytes [157, 74, 213, 92, 21, 143, 104, 70, 167, 57, 133, 96, 213, 203, 180, 11, 176, 28, 44, 178, 209, 200, 8, 14, 117, 149, 32, 226, 53, 179, 240, 190]) }, logicalIndex := 0, digest := (bytes [211, 211, 70, 182, 184, 53, 141, 104, 134, 60, 73, 233, 229, 174, 3, 170, 14, 87, 169, 15, 16, 178, 49, 220, 228, 214, 47, 236, 184, 72, 75, 86]) }, valueDigest := (bytes [228, 186, 196, 100, 214, 97, 204, 91, 47, 206, 34, 198, 29, 200, 203, 87, 232, 28, 132, 169, 17, 190, 217, 45, 135, 51, 200, 19, 206, 178, 215, 73]), digest := (bytes [23, 19, 112, 187, 209, 190, 78, 196, 238, 107, 34, 112, 45, 5, 137, 181, 104, 243, 215, 11, 107, 132, 84, 255, 27, 52, 22, 136, 180, 178, 199, 227]) }), lastBinding := (some { id := { object := { familyTag := 7, commitmentDigest := (bytes [104, 75, 53, 178, 188, 110, 48, 89, 175, 93, 43, 239, 84, 67, 42, 71, 136, 216, 132, 80, 70, 124, 99, 86, 180, 239, 48, 149, 81, 95, 247, 49]), layoutVersion := 1, digest := (bytes [157, 74, 213, 92, 21, 143, 104, 70, 167, 57, 133, 96, 213, 203, 180, 11, 176, 28, 44, 178, 209, 200, 8, 14, 117, 149, 32, 226, 53, 179, 240, 190]) }, logicalIndex := 3, digest := (bytes [24, 182, 29, 173, 165, 19, 193, 165, 43, 159, 171, 21, 131, 127, 249, 93, 242, 6, 204, 106, 212, 65, 95, 179, 2, 236, 154, 152, 35, 118, 80, 105]) }, valueDigest := (bytes [254, 99, 83, 87, 142, 13, 25, 128, 17, 223, 67, 18, 69, 171, 237, 57, 247, 99, 239, 18, 152, 182, 82, 245, 246, 112, 106, 248, 5, 254, 200, 205]), digest := (bytes [9, 192, 76, 175, 82, 254, 212, 243, 74, 103, 105, 91, 175, 109, 201, 122, 157, 192, 148, 154, 74, 141, 89, 84, 250, 28, 123, 69, 63, 95, 90, 85]) }) }, digest := (bytes [4, 71, 49, 234, 114, 227, 234, 76, 205, 198, 212, 82, 116, 208, 111, 207, 198, 4, 57, 209, 146, 91, 49, 81, 194, 229, 217, 245, 158, 148, 132, 74]) }, packaged := { statementDigest := (bytes [74, 151, 107, 103, 161, 185, 63, 168, 72, 194, 135, 131, 243, 207, 65, 76, 110, 204, 204, 171, 34, 4, 38, 232, 13, 67, 16, 179, 245, 182, 40, 125]), proofDigest := (bytes [166, 196, 23, 250, 58, 176, 233, 252, 54, 187, 181, 28, 235, 186, 128, 11, 9, 215, 233, 88, 23, 39, 186, 98, 232, 74, 186, 10, 190, 212, 74, 95]) }, digest := (bytes [149, 116, 242, 126, 164, 207, 175, 13, 120, 99, 112, 63, 4, 242, 128, 143, 42, 164, 96, 35, 17, 48, 144, 46, 91, 215, 0, 135, 132, 42, 78, 187]) }
    , preparedSteps := { claim := { executionDigest := (bytes [141, 81, 95, 195, 231, 84, 171, 240, 150, 119, 148, 108, 81, 62, 93, 105, 24, 74, 13, 118, 229, 236, 2, 205, 125, 30, 81, 145, 166, 192, 80, 84]), finalStateDigest := (bytes [145, 232, 119, 42, 209, 144, 217, 53, 205, 241, 241, 70, 26, 199, 99, 90, 150, 109, 80, 126, 52, 204, 98, 226, 231, 236, 152, 221, 67, 149, 32, 60]), transcriptFinalDigest := (bytes [32, 9, 174, 199, 85, 101, 126, 146, 43, 45, 60, 37, 147, 31, 232, 252, 13, 140, 146, 138, 4, 31, 72, 38, 94, 151, 226, 196, 134, 177, 219, 179]), preparedStepCount := 4, finalPc := 20, halted := true, points := { firstPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [192, 237, 17, 53, 235, 29, 69, 55, 72, 94, 126, 40, 158, 253, 226, 47, 115, 226, 118, 182, 238, 41, 184, 33, 102, 49, 153, 185, 96, 71, 8, 3]), layoutVersion := 3, digest := (bytes [201, 236, 21, 58, 166, 238, 253, 205, 43, 109, 28, 246, 241, 38, 130, 177, 148, 193, 63, 77, 7, 120, 159, 109, 253, 43, 61, 69, 115, 94, 174, 88]) }, logicalIndex := 0, digest := (bytes [176, 163, 215, 61, 193, 203, 148, 52, 42, 158, 76, 174, 148, 4, 72, 111, 177, 60, 17, 171, 220, 102, 81, 247, 70, 125, 58, 43, 236, 26, 94, 45]) }, valueDigest := (bytes [48, 9, 158, 59, 120, 45, 200, 155, 8, 144, 252, 183, 179, 168, 71, 138, 10, 136, 117, 72, 217, 133, 28, 26, 240, 134, 159, 61, 227, 8, 46, 227]), digest := (bytes [234, 196, 19, 209, 186, 228, 212, 26, 38, 142, 39, 225, 81, 151, 86, 95, 113, 78, 96, 219, 206, 214, 155, 189, 52, 238, 232, 200, 40, 66, 250, 181]) }), lastPreparedStep := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [192, 237, 17, 53, 235, 29, 69, 55, 72, 94, 126, 40, 158, 253, 226, 47, 115, 226, 118, 182, 238, 41, 184, 33, 102, 49, 153, 185, 96, 71, 8, 3]), layoutVersion := 3, digest := (bytes [201, 236, 21, 58, 166, 238, 253, 205, 43, 109, 28, 246, 241, 38, 130, 177, 148, 193, 63, 77, 7, 120, 159, 109, 253, 43, 61, 69, 115, 94, 174, 88]) }, logicalIndex := 3, digest := (bytes [236, 197, 73, 220, 3, 71, 76, 31, 216, 219, 236, 53, 55, 174, 245, 177, 142, 213, 29, 54, 114, 245, 162, 1, 207, 96, 239, 222, 68, 233, 246, 139]) }, valueDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [183, 180, 41, 104, 220, 26, 126, 24, 172, 193, 152, 11, 61, 109, 89, 163, 114, 254, 104, 154, 139, 107, 198, 57, 21, 41, 181, 174, 163, 37, 161, 52]) }) }, digest := (bytes [34, 79, 165, 242, 223, 67, 169, 120, 62, 107, 187, 25, 230, 103, 232, 248, 222, 106, 165, 57, 214, 145, 122, 74, 200, 15, 128, 103, 201, 163, 227, 88]) }, packaged := { statementDigest := (bytes [127, 52, 37, 202, 110, 128, 64, 201, 193, 61, 181, 128, 139, 48, 73, 188, 99, 42, 160, 12, 227, 112, 178, 1, 159, 4, 29, 103, 113, 113, 40, 40]), proofDigest := (bytes [87, 116, 229, 114, 54, 224, 222, 15, 94, 64, 165, 179, 73, 104, 158, 23, 34, 138, 248, 183, 81, 55, 118, 227, 77, 205, 187, 118, 166, 31, 10, 134]) }, digest := (bytes [233, 105, 218, 32, 202, 0, 161, 146, 196, 241, 173, 181, 115, 83, 214, 12, 56, 149, 55, 215, 144, 203, 125, 119, 222, 110, 131, 153, 184, 8, 22, 154]) }
    , digest := (bytes [135, 255, 68, 0, 28, 26, 183, 27, 46, 170, 97, 38, 17, 25, 126, 144, 233, 156, 153, 183, 12, 240, 110, 144, 219, 45, 105, 230, 158, 183, 103, 136])
  }

def stepComposition : StepCompositionSurfaceView :=
  {
    stage1SemanticsDigest := (bytes [243, 98, 234, 219, 66, 1, 251, 198, 147, 232, 68, 52, 70, 31, 122, 146, 61, 132, 185, 179, 14, 236, 186, 18, 155, 67, 134, 56, 135, 81, 226, 107])
    , stage2SemanticsDigest := (bytes [208, 250, 63, 100, 144, 29, 15, 224, 75, 176, 51, 235, 128, 103, 116, 27, 49, 123, 54, 186, 197, 99, 134, 45, 45, 189, 98, 186, 0, 216, 31, 102])
    , stage2TemporalDigest := (bytes [108, 218, 233, 116, 72, 77, 182, 107, 231, 233, 112, 254, 219, 215, 105, 165, 119, 11, 255, 206, 189, 234, 151, 135, 49, 15, 31, 104, 162, 58, 206, 231])
    , stage3SemanticsDigest := (bytes [95, 196, 61, 68, 114, 26, 246, 218, 128, 45, 27, 165, 143, 121, 106, 96, 206, 223, 120, 214, 69, 10, 66, 243, 247, 124, 158, 250, 183, 230, 9, 120])
    , rootExecutionDigest := (bytes [140, 83, 96, 196, 82, 205, 200, 112, 86, 67, 80, 0, 246, 29, 200, 34, 170, 52, 182, 85, 119, 49, 187, 250, 106, 234, 198, 23, 173, 176, 231, 57])
    , preparedStepBindingsDigest := (bytes [104, 75, 53, 178, 188, 110, 48, 89, 175, 93, 43, 239, 84, 67, 42, 71, 136, 216, 132, 80, 70, 124, 99, 86, 180, 239, 48, 149, 81, 95, 247, 49])
    , rowChunkRoutesDigest := (bytes [170, 16, 215, 245, 131, 192, 198, 120, 95, 134, 175, 93, 217, 74, 16, 26, 237, 138, 81, 110, 201, 10, 195, 254, 244, 178, 29, 18, 146, 128, 117, 178])
    , realRowCount := 4
    , preparedStepCount := 4
    , firstRealStepIndex := 0
    , lastRealStepIndex := 3
    , initialPc := 0
    , finalPc := 20
    , halted := true
    , digest := (bytes [52, 30, 31, 198, 60, 245, 75, 48, 188, 56, 52, 128, 211, 128, 116, 66, 125, 224, 189, 95, 9, 148, 144, 233, 32, 151, 146, 35, 224, 89, 204, 144])
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
    name := "control_flow_bltu_taken_skip_ecall"
    , source := {
  manifest := { name := "control_flow_bltu_taken_skip_ecall", fixtureId := "control_flow_bltu_taken_skip_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.controlFlow, .nativeAlu] }
  , startPc := 0
  , programWords := [1048723, 2097427, 2155619, 115, 115]
  , initialRegisters := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , initialMemory := []
  , transcriptSeed := (bytes [114, 118, 54, 52, 105, 109, 45, 99, 111, 110, 116, 114, 111, 108, 45, 102, 108, 111, 119, 45, 98, 108, 116, 117, 45, 118, 49])
}
    , derived := {
  manifest := { name := "control_flow_bltu_taken_skip_ecall", fixtureId := "control_flow_bltu_taken_skip_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.controlFlow, .nativeAlu] }
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
  , word := 2097427
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
  , rdAfter := 2
  , imm := 2
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
  traceIndex := 2
  , stepIndex := 2
  , sequenceIndex := 0
  , pc := 8
  , nextPc := 16
  , word := 2155619
  , opcode := .bltu
  , traceOpcode := (some .bltu)
  , traceVirtualOpcode := none
  , family := .controlFlow
  , rs1 := 1
  , rs1Value := 1
  , rs2 := 2
  , rs2Value := 2
  , rd := 0
  , rdBefore := 0
  , rdAfter := 0
  , imm := 8
  , aluResult := 1
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
  traceIndex := 3
  , stepIndex := 3
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
  , stage1 := { rows := [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 1048723, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 4, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 1, rdAfter := 1, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 2097427, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 8, aluResult := 2, effectiveAddr := none, writesRd := true, rd := 2, rdAfter := 2, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 2155619, opcode := .bltu, traceOpcode := (some .bltu), traceVirtualOpcode := none, family := .controlFlow, nextPc := 16, aluResult := 1, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 16, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 20, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }] }
  , stage2 := {
  registerReads := [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 0, value := 0 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 0, value := 0 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 1, value := 1 }, { traceIndex := 2, stepIndex := 2, role := .rs2, reg := 2, value := 2 }]
  , registerWrites := [{ traceIndex := 0, stepIndex := 0, reg := 1, previous := 0, next := 1 }, { traceIndex := 1, stepIndex := 1, reg := 2, previous := 0, next := 2 }]
  , ramEvents := []
  , twistLinks := [{ traceIndex := 0, stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 1, family := .nativeAlu, routedWriteValue := (some 2), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 2, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 3, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]
}
  , stage3 := {
  continuity := [{ stepIndex := 0, pc := 0, nextPc := 4, successorPc := (some 4), finalStep := false, continuityHolds := true }, { stepIndex := 1, pc := 4, nextPc := 8, successorPc := (some 8), finalStep := false, continuityHolds := true }, { stepIndex := 2, pc := 8, nextPc := 16, successorPc := (some 16), finalStep := false, continuityHolds := true }, { stepIndex := 3, pc := 16, nextPc := 20, successorPc := none, finalStep := true, continuityHolds := true }]
  , halted := true
}
  , transcript := {
  appLabel := (bytes [110, 101, 111, 46, 102, 111, 108, 100, 46, 110, 101, 120, 116, 47, 114, 118, 54, 52, 105, 109, 47, 112, 97, 114, 105, 116, 121, 95, 107, 101, 114, 110, 101, 108, 95, 118, 49])
  , events := [{
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 116, 114, 97, 110, 115, 99, 114, 105, 112, 116, 95, 115, 101, 101, 100])
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 99, 111, 110, 116, 114, 111, 108, 45, 102, 108, 111, 119, 45, 98, 108, 116, 117, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [27634538711377453, 54383638574188, 1823709644592138771, 15695669540104460710, 8188744055654938720, 6008164579518882152, 10584698648648697023, 6532369056394176230], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [99, 111, 110, 116, 114, 111, 108, 95, 102, 108, 111, 119, 95, 98, 108, 116, 117, 95, 116, 97, 107, 101, 110, 95, 115, 107, 105, 112, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [27634538711377453, 54383638574188, 1823709644592138771, 15695669540104460710, 8188744055654938720, 6008164579518882152, 10584698648648697023, 6532369056394176230], absorbed := 2 }
  , cursorAfter := { stateWords := [119212746171743, 12208028352350156733, 13116747255023234155, 14361117635213581249, 10512020492052434381, 12419906133025396461, 15979211480460189741, 1777931489941413951], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [1048723, 2097427, 2155619, 115, 115]
  , cursorBefore := { stateWords := [119212746171743, 12208028352350156733, 13116747255023234155, 14361117635213581249, 10512020492052434381, 12419906133025396461, 15979211480460189741, 1777931489941413951], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 16397939035672565642, 11641441053675113354, 16521885663412804258, 3932218136266550266, 5914036218258353172, 16396554047951467107, 194808442544638140], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [0, 16397939035672565642, 11641441053675113354, 16521885663412804258, 3932218136266550266, 5914036218258353172, 16396554047951467107, 194808442544638140], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 0, 0, 881487480932087110, 12013070208049965127, 13175601915555830455, 15818305995734650527, 17566464973142032050], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [0, 0, 0, 881487480932087110, 12013070208049965127, 13175601915555830455, 15818305995734650527, 17566464973142032050], absorbed := 3 }
  , cursorAfter := { stateWords := [0, 5659295860271643948, 17196621751330026985, 11816108413138352063, 7731328996701478098, 2208618711023935331, 5184172702489234712, 4012119732739570676], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [129, 249, 195, 4, 194, 62, 5, 111, 3, 163, 217, 146, 174, 130, 122, 238, 234, 192, 21, 127, 252, 112, 84, 85, 106, 53, 39, 158, 101, 145, 151, 55])
  , u64s := []
  , cursorBefore := { stateWords := [0, 5659295860271643948, 17196621751330026985, 11816108413138352063, 7731328996701478098, 2208618711023935331, 5184172702489234712, 4012119732739570676], absorbed := 1 }
  , cursorAfter := { stateWords := [4092868761203551035, 5735683149795635746, 16451237304497144096, 15660729885261835049, 4993037928439025236, 4058496521599560720, 1830960361648420361, 3978819030440664472], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [4092868761203551035, 5735683149795635746, 16451237304497144096, 15660729885261835049, 4993037928439025236, 4058496521599560720, 1830960361648420361, 3978819030440664472], absorbed := 0 }
  , cursorAfter := { stateWords := [12597393124285258733, 4007867179351945362, 4850091778944820385, 17991037833033007994, 476015916384254308, 14419281049321754399, 7561257148764249156, 1132223698927151629], absorbed := 0 }
  , challengeOutput := (some 12597393124285258733)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [79, 54, 35, 89, 181, 60, 120, 62, 23, 216, 151, 8, 213, 60, 71, 0, 66, 90, 147, 125, 53, 147, 210, 191, 92, 59, 24, 230, 4, 58, 45, 9])
  , u64s := []
  , cursorBefore := { stateWords := [12597393124285258733, 4007867179351945362, 4850091778944820385, 17991037833033007994, 476015916384254308, 14419281049321754399, 7561257148764249156, 1132223698927151629], absorbed := 0 }
  , cursorAfter := { stateWords := [15056245593604167, 64765887881663123, 153958916, 9997542546738313031, 16853801998999087846, 13982512411198372988, 8554071259391645168, 13108539371935154626], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [15056245593604167, 64765887881663123, 153958916, 9997542546738313031, 16853801998999087846, 13982512411198372988, 8554071259391645168, 13108539371935154626], absorbed := 3 }
  , cursorAfter := { stateWords := [8403032955572713120, 10194722622930340936, 17038147923175873622, 6655223517539784936, 13617601525376964849, 2293126206090744488, 4903383980242401457, 18359890104668421032], absorbed := 0 }
  , challengeOutput := (some 8403032955572713120)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [8403032955572713120, 10194722622930340936, 17038147923175873622, 6655223517539784936, 13617601525376964849, 2293126206090744488, 4903383980242401457, 18359890104668421032], absorbed := 0 }
  , cursorAfter := { stateWords := [6883570667930004418, 4347745747494188624, 16976776541035948748, 5246595802583663249, 222760462322422117, 9882636753605636144, 16541711643128801052, 18376981885606520272], absorbed := 0 }
  , challengeOutput := (some 6883570667930004418)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [59, 77, 145, 209, 31, 130, 112, 69, 30, 34, 112, 204, 73, 72, 47, 51, 247, 164, 118, 200, 178, 22, 87, 88, 74, 116, 115, 132, 88, 127, 97, 100])
  , u64s := []
  , cursorBefore := { stateWords := [6883570667930004418, 4347745747494188624, 16976776541035948748, 5246595802583663249, 222760462322422117, 9882636753605636144, 16541711643128801052, 18376981885606520272], absorbed := 0 }
  , cursorAfter := { stateWords := [50322957753856815, 37281640226510614, 1684111192, 7216131882496189275, 17059082051772819397, 392206444769693843, 6967327010175071487, 2617740938094769044], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [50322957753856815, 37281640226510614, 1684111192, 7216131882496189275, 17059082051772819397, 392206444769693843, 6967327010175071487, 2617740938094769044], absorbed := 3 }
  , cursorAfter := { stateWords := [5434653513256456592, 2019440646099219393, 14502873697191680645, 18414208927306151731, 16466704025794420414, 6222860899880621933, 467525259224987042, 2024518562970414523], absorbed := 0 }
  , challengeOutput := (some 5434653513256456592)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [198, 81, 7, 250, 152, 135, 65, 159, 231, 42, 117, 161, 26, 121, 63, 197, 123, 212, 231, 113, 35, 37, 159, 177, 226, 104, 247, 68, 136, 30, 16, 163])
  , u64s := []
  , cursorBefore := { stateWords := [5434653513256456592, 2019440646099219393, 14502873697191680645, 18414208927306151731, 16466704025794420414, 6222860899880621933, 467525259224987042, 2024518562970414523], absorbed := 0 }
  , cursorAfter := { stateWords := [9976864701138239, 19412328268275493, 2735742600, 8224034729581685552, 14602704957001709965, 14970224487669671009, 12214536921972360220, 8804407349145409156], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [141, 81, 95, 195, 231, 84, 171, 240, 150, 119, 148, 108, 81, 62, 93, 105, 24, 74, 13, 118, 229, 236, 2, 205, 125, 30, 81, 145, 166, 192, 80, 84])
  , u64s := []
  , cursorBefore := { stateWords := [9976864701138239, 19412328268275493, 2735742600, 8224034729581685552, 14602704957001709965, 14970224487669671009, 12214536921972360220, 8804407349145409156], absorbed := 3 }
  , cursorAfter := { stateWords := [64587569116506461, 40903063024501484, 1414578342, 14196438228949969798, 18403734006346840136, 13405937549382790609, 7173023050622960964, 10786742084945241388], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [145, 232, 119, 42, 209, 144, 217, 53, 205, 241, 241, 70, 26, 199, 99, 90, 150, 109, 80, 126, 52, 204, 98, 226, 231, 236, 152, 221, 67, 149, 32, 60])
  , u64s := []
  , cursorBefore := { stateWords := [64587569116506461, 40903063024501484, 1414578342, 14196438228949969798, 18403734006346840136, 13405937549382790609, 7173023050622960964, 10786742084945241388], absorbed := 3 }
  , cursorAfter := { stateWords := [14775582690007651, 62374113123132108, 1008768323, 8094561612940107350, 5686126895398755498, 17866238643063324752, 1175931973497704862, 4453093798857192440], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [14775582690007651, 62374113123132108, 1008768323, 8094561612940107350, 5686126895398755498, 17866238643063324752, 1175931973497704862, 4453093798857192440], absorbed := 3 }
  , cursorAfter := { stateWords := [6072416836816506878, 3629861325522078768, 10966163059651396786, 11527671172202609175, 11198492021099575808, 9824312880916574066, 853475271184614411, 5712062166666301321], absorbed := 0 }
  , challengeOutput := (some 6072416836816506878)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [6072416836816506878, 3629861325522078768, 10966163059651396786, 11527671172202609175, 11198492021099575808, 9824312880916574066, 853475271184614411, 5712062166666301321], absorbed := 0 }
  , cursorAfter := { stateWords := [10555985995699718432, 18223850609000066347, 2758488876129618957, 12960147545075652446, 7628832371191976516, 2123629962868476640, 5111925167032223623, 6695332481206384055], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [32, 9, 174, 199, 85, 101, 126, 146, 43, 45, 60, 37, 147, 31, 232, 252, 13, 140, 146, 138, 4, 31, 72, 38, 94, 151, 226, 196, 134, 177, 219, 179]))
}]
}
  , kernel := {
  root0Digest := (bytes [129, 249, 195, 4, 194, 62, 5, 111, 3, 163, 217, 146, 174, 130, 122, 238, 234, 192, 21, 127, 252, 112, 84, 85, 106, 53, 39, 158, 101, 145, 151, 55])
  , stage1Digest := (bytes [79, 54, 35, 89, 181, 60, 120, 62, 23, 216, 151, 8, 213, 60, 71, 0, 66, 90, 147, 125, 53, 147, 210, 191, 92, 59, 24, 230, 4, 58, 45, 9])
  , stage2Digest := (bytes [59, 77, 145, 209, 31, 130, 112, 69, 30, 34, 112, 204, 73, 72, 47, 51, 247, 164, 118, 200, 178, 22, 87, 88, 74, 116, 115, 132, 88, 127, 97, 100])
  , stage3Digest := (bytes [198, 81, 7, 250, 152, 135, 65, 159, 231, 42, 117, 161, 26, 121, 63, 197, 123, 212, 231, 113, 35, 37, 159, 177, 226, 104, 247, 68, 136, 30, 16, 163])
  , executionDigest := (bytes [141, 81, 95, 195, 231, 84, 171, 240, 150, 119, 148, 108, 81, 62, 93, 105, 24, 74, 13, 118, 229, 236, 2, 205, 125, 30, 81, 145, 166, 192, 80, 84])
  , finalStateDigest := (bytes [145, 232, 119, 42, 209, 144, 217, 53, 205, 241, 241, 70, 26, 199, 99, 90, 150, 109, 80, 126, 52, 204, 98, 226, 231, 236, 152, 221, 67, 149, 32, 60])
  , stage1Mix := 12597393124285258733
  , stage2RegMix := 8403032955572713120
  , stage2RamMix := 6883570667930004418
  , stage3ContinuityMix := 5434653513256456592
  , kernelFinalMix := 6072416836816506878
  , transcriptFinalDigest := (bytes [32, 9, 174, 199, 85, 101, 126, 146, 43, 45, 60, 37, 147, 31, 232, 252, 13, 140, 146, 138, 4, 31, 72, 38, 94, 151, 226, 196, 134, 177, 219, 179])
  , finalPc := 20
  , finalRegisters := [0, 1, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , finalMemory := []
  , halted := true
}
}
    , kernelProof := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "control_flow_bltu_taken_skip_ecall", fixtureId := "control_flow_bltu_taken_skip_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.controlFlow, .nativeAlu] }
  , executionDigest := (bytes [141, 81, 95, 195, 231, 84, 171, 240, 150, 119, 148, 108, 81, 62, 93, 105, 24, 74, 13, 118, 229, 236, 2, 205, 125, 30, 81, 145, 166, 192, 80, 84])
  , shape := { executionRowCount := 4, realRowCount := 4, effectRowCount := 4, commitRowCount := 4, digest := (bytes [45, 178, 181, 197, 132, 60, 130, 1, 239, 208, 160, 249, 86, 246, 26, 179, 94, 235, 136, 250, 242, 5, 139, 0, 36, 216, 225, 255, 232, 86, 248, 123]) }
  , digest := (bytes [112, 166, 159, 48, 54, 154, 39, 37, 66, 206, 161, 92, 96, 250, 218, 45, 224, 115, 130, 186, 10, 130, 140, 49, 180, 165, 5, 252, 146, 53, 197, 246])
}
  , stages := { summary := { stage1RowCount := 4, stage2RegisterReadCount := 4, stage2RegisterWriteCount := 2, stage2RamEventCount := 0, stage2TwistLinkCount := 4, stage3ContinuityCount := 4, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [188, 146, 61, 220, 245, 51, 7, 161, 36, 1, 199, 100, 62, 187, 19, 182, 215, 124, 14, 176, 250, 206, 43, 76, 0, 125, 203, 144, 45, 193, 111, 34]) }, digest := (bytes [109, 34, 58, 13, 68, 111, 109, 31, 96, 208, 232, 119, 140, 198, 44, 192, 184, 71, 199, 65, 42, 115, 36, 133, 68, 13, 13, 169, 75, 7, 175, 245]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [111, 175, 105, 140, 80, 17, 142, 93, 248, 164, 96, 185, 48, 162, 95, 31, 129, 229, 91, 133, 255, 51, 20, 113, 142, 90, 183, 115, 215, 9, 119, 221]), stage1Digest := (bytes [25, 73, 79, 186, 228, 183, 73, 233, 189, 112, 167, 162, 152, 240, 148, 29, 213, 232, 86, 138, 230, 177, 213, 88, 19, 177, 166, 227, 154, 2, 137, 129]), stage2Digest := (bytes [87, 113, 117, 191, 83, 10, 169, 77, 43, 16, 164, 94, 124, 182, 38, 228, 106, 208, 172, 111, 233, 21, 133, 202, 82, 216, 170, 88, 72, 152, 172, 175]), stage3Digest := (bytes [241, 139, 61, 96, 28, 236, 184, 76, 31, 31, 90, 170, 231, 105, 75, 206, 127, 224, 133, 83, 235, 74, 203, 217, 94, 188, 29, 205, 255, 17, 30, 140]), transcriptDigest := (bytes [32, 9, 174, 199, 85, 101, 126, 146, 43, 45, 60, 37, 147, 31, 232, 252, 13, 140, 146, 138, 4, 31, 72, 38, 94, 151, 226, 196, 134, 177, 219, 179]), executionDigest := (bytes [141, 81, 95, 195, 231, 84, 171, 240, 150, 119, 148, 108, 81, 62, 93, 105, 24, 74, 13, 118, 229, 236, 2, 205, 125, 30, 81, 145, 166, 192, 80, 84]), digest := (bytes [152, 125, 92, 134, 22, 78, 58, 40, 178, 14, 88, 98, 132, 45, 212, 206, 247, 51, 80, 130, 128, 238, 181, 75, 151, 196, 76, 172, 107, 14, 225, 214]) }, statementDigest := (bytes [70, 55, 113, 218, 38, 87, 230, 174, 16, 225, 19, 209, 254, 176, 6, 240, 27, 30, 246, 106, 124, 118, 255, 131, 49, 64, 127, 143, 155, 66, 98, 78]), proofDigest := (bytes [185, 142, 210, 249, 201, 142, 197, 199, 27, 226, 48, 201, 108, 60, 49, 85, 206, 93, 253, 241, 106, 76, 1, 188, 62, 66, 238, 11, 178, 124, 11, 52]), digest := (bytes [65, 26, 100, 145, 74, 120, 199, 240, 89, 3, 83, 20, 165, 222, 220, 132, 16, 139, 115, 218, 43, 141, 174, 246, 216, 76, 38, 234, 113, 208, 59, 40]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [103, 100, 104, 36, 35, 103, 162, 168, 213, 214, 209, 209, 132, 135, 142, 250, 213, 132, 243, 119, 145, 105, 161, 140, 83, 177, 48, 60, 14, 167, 180, 141]), stage1Digest := (bytes [128, 238, 161, 239, 189, 69, 242, 121, 172, 205, 232, 176, 32, 68, 44, 111, 49, 93, 186, 52, 195, 192, 189, 151, 225, 186, 218, 219, 91, 240, 105, 63]), stage2Digest := (bytes [216, 184, 107, 187, 133, 97, 85, 65, 217, 240, 211, 65, 137, 181, 151, 92, 186, 241, 133, 206, 73, 117, 12, 179, 62, 14, 50, 89, 167, 219, 181, 178]), stage3Digest := (bytes [191, 206, 12, 122, 147, 242, 118, 171, 192, 141, 23, 50, 182, 146, 160, 145, 190, 115, 129, 12, 181, 246, 179, 115, 150, 246, 22, 106, 186, 48, 187, 98]), digest := (bytes [92, 51, 58, 231, 23, 44, 141, 7, 152, 143, 177, 47, 203, 132, 212, 147, 101, 53, 133, 183, 197, 36, 119, 86, 92, 3, 179, 0, 36, 176, 221, 65]) }, digest := (bytes [73, 38, 46, 25, 162, 161, 168, 126, 50, 68, 64, 188, 123, 230, 56, 144, 178, 143, 86, 192, 105, 252, 131, 99, 17, 48, 126, 45, 175, 212, 0, 248]) }
  , kernelOpening := { openingDigest := (bytes [135, 255, 68, 0, 28, 26, 183, 27, 46, 170, 97, 38, 17, 25, 126, 144, 233, 156, 153, 183, 12, 240, 110, 144, 219, 45, 105, 230, 158, 183, 103, 136]), bindings := { claimDigest := (bytes [72, 7, 3, 5, 173, 99, 193, 180, 81, 164, 158, 216, 223, 154, 53, 146, 6, 46, 137, 251, 184, 226, 234, 166, 27, 2, 53, 110, 232, 232, 135, 156]), bindingsDigest := (bytes [149, 116, 242, 126, 164, 207, 175, 13, 120, 99, 112, 63, 4, 242, 128, 143, 42, 164, 96, 35, 17, 48, 144, 46, 91, 215, 0, 135, 132, 42, 78, 187]), preparedStepsDigest := (bytes [233, 105, 218, 32, 202, 0, 161, 146, 196, 241, 173, 181, 115, 83, 214, 12, 56, 149, 55, 215, 144, 203, 125, 119, 222, 110, 131, 153, 184, 8, 22, 154]), digest := (bytes [172, 163, 69, 48, 75, 207, 123, 188, 19, 211, 93, 217, 188, 92, 156, 157, 10, 254, 7, 67, 201, 59, 118, 164, 136, 136, 135, 76, 188, 191, 93, 201]) }, digest := (bytes [98, 125, 147, 223, 161, 241, 121, 194, 165, 244, 173, 162, 241, 95, 161, 250, 36, 69, 79, 223, 249, 222, 177, 96, 162, 15, 42, 137, 44, 132, 239, 46]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [104, 75, 53, 178, 188, 110, 48, 89, 175, 93, 43, 239, 84, 67, 42, 71, 136, 216, 132, 80, 70, 124, 99, 86, 180, 239, 48, 149, 81, 95, 247, 49]), terminal := { root0Digest := (bytes [129, 249, 195, 4, 194, 62, 5, 111, 3, 163, 217, 146, 174, 130, 122, 238, 234, 192, 21, 127, 252, 112, 84, 85, 106, 53, 39, 158, 101, 145, 151, 55]), executionDigest := (bytes [141, 81, 95, 195, 231, 84, 171, 240, 150, 119, 148, 108, 81, 62, 93, 105, 24, 74, 13, 118, 229, 236, 2, 205, 125, 30, 81, 145, 166, 192, 80, 84]), finalStateDigest := (bytes [145, 232, 119, 42, 209, 144, 217, 53, 205, 241, 241, 70, 26, 199, 99, 90, 150, 109, 80, 126, 52, 204, 98, 226, 231, 236, 152, 221, 67, 149, 32, 60]), transcriptFinalDigest := (bytes [32, 9, 174, 199, 85, 101, 126, 146, 43, 45, 60, 37, 147, 31, 232, 252, 13, 140, 146, 138, 4, 31, 72, 38, 94, 151, 226, 196, 134, 177, 219, 179]), finalPc := 20, halted := true, digest := (bytes [225, 32, 249, 166, 241, 155, 145, 184, 164, 62, 114, 94, 104, 63, 167, 0, 111, 80, 146, 51, 93, 63, 190, 95, 156, 193, 159, 235, 2, 235, 102, 175]) }, digest := (bytes [193, 17, 222, 111, 188, 222, 235, 46, 185, 0, 160, 47, 237, 245, 35, 115, 29, 15, 128, 180, 246, 161, 27, 227, 150, 166, 31, 20, 132, 222, 66, 93]) }, statementDigest := (bytes [170, 31, 192, 204, 63, 201, 243, 188, 60, 231, 196, 188, 54, 215, 172, 146, 110, 74, 203, 63, 19, 192, 42, 92, 220, 206, 84, 194, 169, 96, 168, 182]), proofDigest := (bytes [189, 114, 29, 77, 63, 243, 61, 174, 87, 81, 74, 108, 167, 238, 255, 56, 205, 191, 131, 133, 251, 114, 9, 30, 219, 153, 60, 82, 165, 81, 165, 73]), digest := (bytes [222, 91, 48, 24, 92, 170, 51, 29, 108, 115, 89, 129, 252, 146, 235, 29, 165, 42, 72, 223, 231, 116, 42, 203, 141, 146, 81, 224, 106, 228, 41, 119]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [60, 226, 26, 9, 218, 106, 1, 219, 145, 76, 252, 6, 9, 158, 230, 215, 33, 119, 133, 248, 125, 83, 74, 254, 42, 99, 109, 35, 207, 217, 240, 185]), layoutVersion := 1, digest := (bytes [131, 223, 208, 63, 140, 78, 62, 114, 188, 153, 94, 55, 121, 186, 251, 10, 174, 8, 144, 40, 101, 129, 149, 23, 39, 106, 59, 2, 139, 213, 27, 184]) }, rowWidth := 38, timeLen := 4, columnDigests := [(bytes [212, 186, 229, 172, 74, 68, 211, 103, 24, 241, 21, 82, 209, 33, 189, 99, 223, 36, 129, 167, 9, 173, 76, 108, 178, 222, 90, 225, 89, 142, 8, 14]), (bytes [56, 58, 241, 13, 94, 161, 102, 38, 209, 85, 101, 10, 115, 74, 68, 15, 139, 16, 65, 164, 142, 61, 38, 80, 159, 19, 8, 220, 33, 174, 155, 155]), (bytes [29, 30, 250, 119, 67, 192, 190, 83, 169, 199, 126, 126, 209, 9, 207, 51, 13, 31, 240, 215, 38, 77, 233, 53, 71, 218, 94, 76, 41, 218, 33, 58]), (bytes [181, 122, 105, 181, 35, 180, 95, 214, 79, 41, 41, 2, 114, 48, 216, 55, 223, 211, 166, 64, 24, 33, 244, 234, 111, 10, 124, 63, 69, 70, 27, 116]), (bytes [235, 168, 211, 18, 219, 164, 123, 11, 1, 214, 235, 228, 142, 231, 19, 191, 111, 116, 112, 196, 167, 65, 6, 113, 150, 204, 141, 39, 111, 24, 165, 153]), (bytes [242, 28, 35, 169, 87, 104, 212, 237, 236, 149, 250, 219, 103, 80, 207, 126, 166, 205, 108, 128, 249, 85, 204, 223, 195, 102, 69, 23, 26, 53, 12, 57]), (bytes [91, 136, 102, 108, 254, 142, 77, 48, 97, 138, 138, 188, 220, 213, 55, 183, 133, 216, 230, 69, 191, 7, 253, 203, 112, 162, 85, 64, 74, 16, 34, 24]), (bytes [145, 208, 161, 0, 15, 127, 128, 193, 17, 127, 54, 222, 14, 0, 56, 94, 162, 110, 235, 214, 215, 110, 110, 82, 30, 10, 209, 128, 138, 179, 97, 121]), (bytes [13, 51, 13, 112, 10, 98, 204, 18, 53, 169, 156, 155, 63, 147, 114, 64, 241, 138, 154, 179, 238, 77, 114, 193, 171, 122, 197, 145, 246, 175, 206, 33]), (bytes [142, 21, 17, 77, 228, 49, 25, 177, 110, 190, 40, 43, 77, 239, 100, 234, 232, 124, 233, 138, 18, 189, 28, 101, 61, 173, 87, 220, 21, 69, 47, 137]), (bytes [32, 64, 97, 165, 48, 228, 106, 97, 58, 99, 14, 168, 63, 135, 66, 111, 135, 195, 225, 237, 39, 221, 23, 227, 16, 4, 135, 55, 248, 191, 135, 167]), (bytes [160, 5, 243, 183, 153, 60, 211, 231, 77, 120, 63, 81, 113, 147, 36, 148, 46, 54, 237, 238, 168, 176, 4, 184, 126, 205, 7, 60, 5, 32, 148, 213]), (bytes [238, 189, 198, 6, 199, 30, 93, 193, 29, 126, 221, 61, 73, 119, 129, 87, 55, 227, 133, 106, 170, 178, 160, 203, 102, 209, 230, 172, 220, 2, 72, 166]), (bytes [43, 8, 73, 107, 92, 98, 192, 143, 194, 86, 81, 10, 28, 138, 74, 179, 89, 196, 21, 18, 77, 39, 42, 122, 78, 216, 30, 91, 90, 243, 230, 0]), (bytes [74, 226, 37, 10, 152, 135, 71, 32, 121, 204, 236, 95, 238, 168, 237, 37, 113, 198, 64, 103, 189, 79, 90, 86, 18, 168, 112, 176, 240, 27, 29, 182]), (bytes [220, 193, 230, 244, 243, 14, 93, 42, 216, 108, 251, 253, 94, 191, 212, 189, 13, 211, 94, 236, 218, 138, 122, 7, 190, 222, 130, 249, 182, 150, 137, 189]), (bytes [223, 89, 191, 11, 110, 102, 31, 137, 129, 115, 137, 48, 64, 221, 208, 112, 235, 228, 24, 226, 254, 59, 16, 16, 192, 134, 30, 101, 212, 162, 156, 187]), (bytes [156, 22, 213, 157, 3, 147, 139, 132, 146, 22, 57, 209, 56, 31, 20, 20, 229, 105, 89, 38, 226, 230, 110, 49, 208, 70, 178, 10, 75, 21, 225, 62]), (bytes [89, 6, 118, 169, 105, 54, 5, 121, 26, 253, 91, 160, 13, 78, 211, 28, 177, 107, 187, 177, 10, 185, 35, 168, 191, 215, 99, 41, 155, 74, 182, 15]), (bytes [16, 1, 45, 207, 125, 115, 77, 40, 96, 249, 191, 96, 68, 155, 161, 144, 89, 205, 15, 173, 177, 139, 3, 87, 248, 132, 221, 254, 91, 235, 118, 133]), (bytes [2, 197, 213, 149, 21, 90, 236, 108, 141, 146, 26, 38, 0, 78, 135, 95, 223, 228, 221, 179, 125, 245, 167, 198, 49, 196, 48, 128, 192, 39, 124, 49]), (bytes [130, 134, 127, 131, 40, 47, 149, 206, 210, 112, 225, 17, 66, 25, 14, 78, 65, 235, 99, 73, 206, 90, 67, 148, 19, 78, 146, 25, 197, 149, 108, 61]), (bytes [8, 234, 67, 158, 76, 76, 170, 16, 58, 161, 138, 98, 35, 61, 115, 114, 104, 189, 45, 62, 96, 35, 11, 160, 56, 73, 223, 212, 106, 84, 224, 145]), (bytes [0, 189, 116, 3, 67, 124, 251, 249, 47, 128, 49, 73, 210, 47, 86, 252, 162, 78, 171, 9, 96, 183, 112, 195, 81, 120, 202, 223, 242, 24, 76, 51]), (bytes [81, 144, 1, 221, 155, 166, 187, 155, 181, 172, 254, 158, 176, 149, 110, 161, 164, 146, 156, 197, 231, 227, 176, 108, 72, 168, 128, 97, 162, 214, 166, 78]), (bytes [238, 147, 134, 181, 8, 29, 128, 200, 221, 198, 65, 181, 234, 22, 117, 159, 112, 0, 90, 214, 190, 69, 86, 72, 209, 196, 234, 23, 145, 109, 49, 190]), (bytes [150, 94, 21, 115, 92, 3, 250, 46, 250, 39, 23, 156, 66, 177, 198, 103, 242, 34, 109, 175, 253, 18, 181, 44, 23, 6, 9, 9, 119, 235, 11, 108]), (bytes [135, 215, 141, 47, 156, 11, 54, 54, 3, 72, 179, 247, 223, 155, 104, 7, 155, 222, 232, 159, 97, 172, 115, 97, 167, 121, 212, 57, 156, 44, 117, 203]), (bytes [84, 95, 115, 25, 213, 106, 24, 56, 216, 206, 94, 157, 100, 187, 198, 197, 93, 1, 173, 134, 90, 112, 47, 80, 254, 7, 54, 249, 32, 132, 243, 167]), (bytes [130, 198, 251, 47, 44, 43, 143, 92, 82, 195, 92, 157, 42, 215, 42, 26, 5, 251, 108, 34, 34, 0, 80, 113, 213, 113, 25, 247, 190, 124, 74, 52]), (bytes [234, 182, 234, 160, 23, 192, 246, 199, 173, 187, 203, 106, 254, 25, 134, 196, 2, 40, 181, 117, 170, 220, 56, 86, 63, 246, 0, 182, 78, 16, 61, 77]), (bytes [40, 254, 204, 213, 6, 140, 117, 235, 134, 79, 86, 81, 169, 63, 60, 118, 8, 156, 87, 198, 194, 60, 29, 160, 125, 250, 15, 187, 147, 220, 29, 92]), (bytes [18, 187, 180, 226, 104, 66, 42, 243, 22, 156, 53, 240, 151, 142, 203, 83, 91, 143, 153, 183, 211, 14, 178, 15, 249, 35, 88, 211, 226, 167, 221, 238]), (bytes [164, 40, 127, 229, 211, 147, 121, 221, 253, 56, 242, 238, 25, 160, 231, 5, 98, 88, 35, 198, 216, 51, 242, 34, 196, 132, 1, 62, 202, 49, 246, 41]), (bytes [122, 105, 77, 66, 174, 33, 37, 82, 171, 117, 60, 146, 152, 71, 176, 9, 4, 214, 95, 111, 117, 16, 77, 11, 22, 12, 202, 53, 36, 93, 76, 79]), (bytes [190, 26, 99, 184, 175, 199, 251, 124, 134, 183, 220, 35, 196, 195, 152, 135, 36, 169, 87, 198, 14, 22, 245, 143, 20, 239, 221, 18, 139, 77, 165, 236]), (bytes [80, 33, 41, 82, 68, 242, 18, 200, 209, 172, 125, 228, 155, 229, 192, 181, 222, 62, 254, 113, 197, 197, 209, 167, 162, 245, 86, 19, 189, 248, 96, 43]), (bytes [90, 10, 190, 250, 226, 23, 47, 210, 182, 164, 148, 175, 37, 226, 99, 192, 247, 166, 149, 66, 95, 29, 230, 232, 50, 99, 224, 203, 78, 177, 221, 250])], familyDigest := (bytes [60, 226, 26, 9, 218, 106, 1, 219, 145, 76, 252, 6, 9, 158, 230, 215, 33, 119, 133, 248, 125, 83, 74, 254, 42, 99, 109, 35, 207, 217, 240, 185]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [60, 226, 26, 9, 218, 106, 1, 219, 145, 76, 252, 6, 9, 158, 230, 215, 33, 119, 133, 248, 125, 83, 74, 254, 42, 99, 109, 35, 207, 217, 240, 185]), layoutVersion := 1, digest := (bytes [131, 223, 208, 63, 140, 78, 62, 114, 188, 153, 94, 55, 121, 186, 251, 10, 174, 8, 144, 40, 101, 129, 149, 23, 39, 106, 59, 2, 139, 213, 27, 184]) }, logicalIndex := 0, digest := (bytes [102, 193, 167, 113, 19, 197, 238, 244, 130, 208, 64, 28, 70, 92, 155, 50, 117, 135, 113, 248, 136, 248, 151, 3, 160, 8, 204, 52, 13, 32, 213, 27]) }, valueDigest := (bytes [48, 9, 158, 59, 120, 45, 200, 155, 8, 144, 252, 183, 179, 168, 71, 138, 10, 136, 117, 72, 217, 133, 28, 26, 240, 134, 159, 61, 227, 8, 46, 227]), digest := (bytes [157, 29, 105, 164, 228, 100, 34, 43, 226, 130, 195, 108, 5, 73, 10, 134, 63, 113, 148, 49, 24, 192, 159, 83, 170, 86, 173, 32, 237, 192, 45, 56]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [60, 226, 26, 9, 218, 106, 1, 219, 145, 76, 252, 6, 9, 158, 230, 215, 33, 119, 133, 248, 125, 83, 74, 254, 42, 99, 109, 35, 207, 217, 240, 185]), layoutVersion := 1, digest := (bytes [131, 223, 208, 63, 140, 78, 62, 114, 188, 153, 94, 55, 121, 186, 251, 10, 174, 8, 144, 40, 101, 129, 149, 23, 39, 106, 59, 2, 139, 213, 27, 184]) }, logicalIndex := 3, digest := (bytes [42, 14, 11, 181, 92, 135, 182, 1, 141, 107, 200, 170, 222, 89, 64, 23, 196, 173, 115, 96, 143, 146, 210, 88, 108, 166, 105, 221, 234, 228, 143, 165]) }, valueDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [124, 166, 215, 100, 149, 36, 226, 108, 212, 188, 194, 29, 21, 167, 128, 220, 35, 18, 192, 205, 143, 231, 17, 59, 34, 46, 111, 237, 195, 188, 201, 110]) }), digest := (bytes [221, 121, 206, 183, 151, 219, 178, 140, 208, 65, 59, 55, 61, 251, 94, 139, 124, 108, 51, 165, 202, 100, 78, 163, 69, 159, 201, 110, 122, 253, 116, 183]) }
  , rootLaneCommitment := { timeLen := 4, commitments := { commitmentCount := 38, digest := (bytes [192, 237, 17, 53, 235, 29, 69, 55, 72, 94, 126, 40, 158, 253, 226, 47, 115, 226, 118, 182, 238, 41, 184, 33, 102, 49, 153, 185, 96, 71, 8, 3]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [192, 237, 17, 53, 235, 29, 69, 55, 72, 94, 126, 40, 158, 253, 226, 47, 115, 226, 118, 182, 238, 41, 184, 33, 102, 49, 153, 185, 96, 71, 8, 3]), layoutVersion := 3, digest := (bytes [201, 236, 21, 58, 166, 238, 253, 205, 43, 109, 28, 246, 241, 38, 130, 177, 148, 193, 63, 77, 7, 120, 159, 109, 253, 43, 61, 69, 115, 94, 174, 88]) }, logicalIndex := 0, digest := (bytes [176, 163, 215, 61, 193, 203, 148, 52, 42, 158, 76, 174, 148, 4, 72, 111, 177, 60, 17, 171, 220, 102, 81, 247, 70, 125, 58, 43, 236, 26, 94, 45]) }, valueDigest := (bytes [48, 9, 158, 59, 120, 45, 200, 155, 8, 144, 252, 183, 179, 168, 71, 138, 10, 136, 117, 72, 217, 133, 28, 26, 240, 134, 159, 61, 227, 8, 46, 227]), digest := (bytes [234, 196, 19, 209, 186, 228, 212, 26, 38, 142, 39, 225, 81, 151, 86, 95, 113, 78, 96, 219, 206, 214, 155, 189, 52, 238, 232, 200, 40, 66, 250, 181]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [192, 237, 17, 53, 235, 29, 69, 55, 72, 94, 126, 40, 158, 253, 226, 47, 115, 226, 118, 182, 238, 41, 184, 33, 102, 49, 153, 185, 96, 71, 8, 3]), layoutVersion := 3, digest := (bytes [201, 236, 21, 58, 166, 238, 253, 205, 43, 109, 28, 246, 241, 38, 130, 177, 148, 193, 63, 77, 7, 120, 159, 109, 253, 43, 61, 69, 115, 94, 174, 88]) }, logicalIndex := 3, digest := (bytes [236, 197, 73, 220, 3, 71, 76, 31, 216, 219, 236, 53, 55, 174, 245, 177, 142, 213, 29, 54, 114, 245, 162, 1, 207, 96, 239, 222, 68, 233, 246, 139]) }, valueDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [183, 180, 41, 104, 220, 26, 126, 24, 172, 193, 152, 11, 61, 109, 89, 163, 114, 254, 104, 154, 139, 107, 198, 57, 21, 41, 181, 174, 163, 37, 161, 52]) }), digest := (bytes [141, 143, 90, 112, 155, 41, 142, 170, 186, 118, 48, 253, 234, 233, 236, 85, 63, 77, 89, 42, 7, 3, 3, 83, 178, 89, 118, 201, 61, 171, 222, 38]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [221, 121, 206, 183, 151, 219, 178, 140, 208, 65, 59, 55, 61, 251, 94, 139, 124, 108, 51, 165, 202, 100, 78, 163, 69, 159, 201, 110, 122, 253, 116, 183]), rootLaneCommitmentDigest := (bytes [141, 143, 90, 112, 155, 41, 142, 170, 186, 118, 48, 253, 234, 233, 236, 85, 63, 77, 89, 42, 7, 3, 3, 83, 178, 89, 118, 201, 61, 171, 222, 38]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 4, digest := (bytes [31, 115, 81, 186, 95, 69, 142, 3, 165, 129, 219, 15, 136, 124, 218, 48, 84, 173, 203, 2, 196, 241, 239, 30, 35, 37, 239, 33, 221, 205, 34, 226]) }, statementDigest := (bytes [215, 58, 13, 112, 249, 122, 159, 176, 47, 114, 90, 228, 190, 64, 141, 159, 65, 189, 236, 253, 227, 128, 85, 167, 170, 176, 162, 73, 61, 197, 121, 184]), proofDigest := (bytes [232, 129, 203, 10, 148, 72, 221, 136, 48, 38, 161, 187, 138, 65, 189, 148, 13, 231, 220, 85, 13, 238, 35, 26, 255, 49, 125, 206, 63, 155, 126, 21]), digest := (bytes [135, 8, 111, 37, 24, 70, 42, 18, 173, 6, 44, 252, 136, 179, 24, 52, 60, 161, 238, 214, 232, 27, 40, 127, 3, 170, 34, 222, 185, 123, 205, 117]) }
  , digest := (bytes [90, 94, 215, 127, 211, 168, 177, 202, 163, 46, 19, 214, 97, 31, 199, 145, 189, 186, 220, 159, 233, 9, 221, 200, 10, 133, 233, 41, 240, 147, 15, 5])
}
    , exportedProof := {
  claim := {
  accepted := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , statement := { proofStatementDigest := (bytes [122, 52, 50, 123, 204, 17, 136, 106, 135, 88, 191, 54, 111, 207, 151, 155, 170, 52, 221, 135, 91, 123, 9, 231, 95, 161, 110, 6, 178, 38, 88, 141]), kernelOpeningDigest := (bytes [98, 125, 147, 223, 161, 241, 121, 194, 165, 244, 173, 162, 241, 95, 161, 250, 36, 69, 79, 223, 249, 222, 177, 96, 162, 15, 42, 137, 44, 132, 239, 46]), digest := (bytes [209, 213, 140, 173, 19, 168, 9, 9, 161, 12, 201, 164, 82, 46, 57, 156, 93, 153, 204, 19, 10, 102, 64, 200, 134, 198, 116, 82, 33, 75, 102, 180]) }
  , mainLane := { mainLaneBundleDigest := (bytes [135, 8, 111, 37, 24, 70, 42, 18, 173, 6, 44, 252, 136, 179, 24, 52, 60, 161, 238, 214, 232, 27, 40, 127, 3, 170, 34, 222, 185, 123, 205, 117]), digest := (bytes [103, 53, 101, 55, 118, 16, 139, 246, 19, 127, 136, 198, 171, 147, 146, 115, 215, 251, 181, 204, 167, 29, 152, 112, 67, 235, 174, 98, 97, 9, 101, 157]) }
  , terminal := { finalStateDigest := (bytes [145, 232, 119, 42, 209, 144, 217, 53, 205, 241, 241, 70, 26, 199, 99, 90, 150, 109, 80, 126, 52, 204, 98, 226, 231, 236, 152, 221, 67, 149, 32, 60]), finalPc := 20, halted := true, digest := (bytes [208, 124, 234, 99, 149, 213, 99, 232, 239, 53, 203, 49, 65, 171, 56, 50, 252, 44, 110, 99, 126, 26, 6, 160, 104, 4, 205, 132, 52, 67, 122, 29]) }
  , digest := (bytes [66, 97, 0, 60, 71, 145, 126, 100, 159, 236, 5, 10, 48, 213, 231, 38, 25, 90, 109, 122, 47, 187, 159, 223, 235, 156, 123, 174, 217, 54, 97, 186])
}
  , mainLane := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { mainLaneBundleDigest := (bytes [135, 8, 111, 37, 24, 70, 42, 18, 173, 6, 44, 252, 136, 179, 24, 52, 60, 161, 238, 214, 232, 27, 40, 127, 3, 170, 34, 222, 185, 123, 205, 117]), digest := (bytes [251, 55, 201, 131, 182, 8, 22, 177, 207, 116, 149, 110, 154, 200, 85, 20, 218, 50, 79, 1, 199, 36, 36, 133, 253, 125, 129, 127, 8, 214, 202, 56]) }, digest := (bytes [162, 56, 49, 194, 55, 31, 53, 156, 149, 118, 22, 178, 201, 185, 192, 101, 204, 59, 169, 177, 124, 149, 255, 129, 248, 37, 202, 31, 104, 109, 210, 64]) }
  , opening := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , stages := { stageClaimsDigest := (bytes [65, 26, 100, 145, 74, 120, 199, 240, 89, 3, 83, 20, 165, 222, 220, 132, 16, 139, 115, 218, 43, 141, 174, 246, 216, 76, 38, 234, 113, 208, 59, 40]), stagePackagesDigest := (bytes [73, 38, 46, 25, 162, 161, 168, 126, 50, 68, 64, 188, 123, 230, 56, 144, 178, 143, 86, 192, 105, 252, 131, 99, 17, 48, 126, 45, 175, 212, 0, 248]), kernelOpeningDigest := (bytes [98, 125, 147, 223, 161, 241, 121, 194, 165, 244, 173, 162, 241, 95, 161, 250, 36, 69, 79, 223, 249, 222, 177, 96, 162, 15, 42, 137, 44, 132, 239, 46]), digest := (bytes [85, 187, 90, 30, 125, 50, 58, 187, 67, 218, 232, 199, 54, 165, 230, 114, 254, 249, 237, 153, 182, 105, 36, 54, 66, 79, 129, 193, 225, 61, 68, 91]) }
  , terminal := { preparedStepBindingsDigest := (bytes [104, 75, 53, 178, 188, 110, 48, 89, 175, 93, 43, 239, 84, 67, 42, 71, 136, 216, 132, 80, 70, 124, 99, 86, 180, 239, 48, 149, 81, 95, 247, 49]), executionDigest := (bytes [141, 81, 95, 195, 231, 84, 171, 240, 150, 119, 148, 108, 81, 62, 93, 105, 24, 74, 13, 118, 229, 236, 2, 205, 125, 30, 81, 145, 166, 192, 80, 84]), transcriptFinalDigest := (bytes [32, 9, 174, 199, 85, 101, 126, 146, 43, 45, 60, 37, 147, 31, 232, 252, 13, 140, 146, 138, 4, 31, 72, 38, 94, 151, 226, 196, 134, 177, 219, 179]), digest := (bytes [87, 182, 97, 166, 111, 149, 178, 14, 155, 45, 146, 138, 245, 216, 140, 149, 186, 96, 39, 8, 81, 119, 68, 114, 226, 115, 20, 41, 184, 45, 64, 122]) }
  , digest := (bytes [195, 184, 240, 146, 133, 189, 150, 25, 91, 109, 3, 74, 173, 134, 96, 162, 167, 129, 76, 91, 122, 15, 77, 163, 251, 107, 120, 179, 193, 176, 78, 71])
}
  , jointOpening := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { proofStatementDigest := (bytes [122, 52, 50, 123, 204, 17, 136, 106, 135, 88, 191, 54, 111, 207, 151, 155, 170, 52, 221, 135, 91, 123, 9, 231, 95, 161, 110, 6, 178, 38, 88, 141]), mainLaneClaimDigest := (bytes [162, 56, 49, 194, 55, 31, 53, 156, 149, 118, 22, 178, 201, 185, 192, 101, 204, 59, 169, 177, 124, 149, 255, 129, 248, 37, 202, 31, 104, 109, 210, 64]), kernelOpeningClaimDigest := (bytes [195, 184, 240, 146, 133, 189, 150, 25, 91, 109, 3, 74, 173, 134, 96, 162, 167, 129, 76, 91, 122, 15, 77, 163, 251, 107, 120, 179, 193, 176, 78, 71]), digest := (bytes [209, 170, 87, 77, 56, 90, 111, 124, 37, 248, 156, 90, 143, 164, 137, 230, 226, 213, 107, 89, 207, 180, 131, 104, 0, 5, 131, 129, 162, 122, 168, 113]) }, digest := (bytes [35, 92, 73, 174, 244, 58, 177, 82, 124, 240, 93, 221, 167, 121, 160, 103, 112, 195, 18, 53, 56, 175, 161, 66, 164, 36, 241, 55, 167, 116, 170, 102]) }
  , root0 := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), stages := { stage1Digest := (bytes [79, 54, 35, 89, 181, 60, 120, 62, 23, 216, 151, 8, 213, 60, 71, 0, 66, 90, 147, 125, 53, 147, 210, 191, 92, 59, 24, 230, 4, 58, 45, 9]), stage2Digest := (bytes [59, 77, 145, 209, 31, 130, 112, 69, 30, 34, 112, 204, 73, 72, 47, 51, 247, 164, 118, 200, 178, 22, 87, 88, 74, 116, 115, 132, 88, 127, 97, 100]), stage3Digest := (bytes [198, 81, 7, 250, 152, 135, 65, 159, 231, 42, 117, 161, 26, 121, 63, 197, 123, 212, 231, 113, 35, 37, 159, 177, 226, 104, 247, 68, 136, 30, 16, 163]), digest := (bytes [147, 76, 248, 17, 76, 51, 33, 217, 79, 25, 20, 23, 176, 183, 195, 225, 136, 159, 93, 141, 203, 55, 253, 138, 241, 122, 92, 25, 99, 124, 35, 178]) }, terminal := { root0Digest := (bytes [129, 249, 195, 4, 194, 62, 5, 111, 3, 163, 217, 146, 174, 130, 122, 238, 234, 192, 21, 127, 252, 112, 84, 85, 106, 53, 39, 158, 101, 145, 151, 55]), executionDigest := (bytes [141, 81, 95, 195, 231, 84, 171, 240, 150, 119, 148, 108, 81, 62, 93, 105, 24, 74, 13, 118, 229, 236, 2, 205, 125, 30, 81, 145, 166, 192, 80, 84]), finalStateDigest := (bytes [145, 232, 119, 42, 209, 144, 217, 53, 205, 241, 241, 70, 26, 199, 99, 90, 150, 109, 80, 126, 52, 204, 98, 226, 231, 236, 152, 221, 67, 149, 32, 60]), transcriptFinalDigest := (bytes [32, 9, 174, 199, 85, 101, 126, 146, 43, 45, 60, 37, 147, 31, 232, 252, 13, 140, 146, 138, 4, 31, 72, 38, 94, 151, 226, 196, 134, 177, 219, 179]), digest := (bytes [253, 47, 122, 16, 124, 129, 141, 81, 162, 68, 60, 83, 135, 22, 91, 85, 181, 98, 15, 46, 10, 222, 0, 229, 21, 217, 1, 121, 49, 65, 152, 151]) }, digest := (bytes [4, 116, 205, 118, 152, 173, 211, 205, 113, 177, 245, 57, 149, 71, 160, 104, 44, 149, 64, 76, 115, 215, 148, 43, 144, 162, 64, 58, 124, 129, 42, 60]) }
  , digest := (bytes [204, 23, 59, 134, 247, 245, 50, 148, 219, 45, 18, 46, 82, 107, 8, 151, 46, 69, 87, 116, 193, 170, 83, 156, 170, 156, 183, 210, 196, 21, 128, 165])
}
  , statement := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , foldSchedule := Nightstream.FoldSchedule.wholeTrace
  , chunkCount := 1
  , stageClaimsDigest := (bytes [65, 26, 100, 145, 74, 120, 199, 240, 89, 3, 83, 20, 165, 222, 220, 132, 16, 139, 115, 218, 43, 141, 174, 246, 216, 76, 38, 234, 113, 208, 59, 40])
  , stagePackagesDigest := (bytes [73, 38, 46, 25, 162, 161, 168, 126, 50, 68, 64, 188, 123, 230, 56, 144, 178, 143, 86, 192, 105, 252, 131, 99, 17, 48, 126, 45, 175, 212, 0, 248])
  , kernelOpeningDigest := (bytes [98, 125, 147, 223, 161, 241, 121, 194, 165, 244, 173, 162, 241, 95, 161, 250, 36, 69, 79, 223, 249, 222, 177, 96, 162, 15, 42, 137, 44, 132, 239, 46])
  , preparedStepBindingsDigest := (bytes [104, 75, 53, 178, 188, 110, 48, 89, 175, 93, 43, 239, 84, 67, 42, 71, 136, 216, 132, 80, 70, 124, 99, 86, 180, 239, 48, 149, 81, 95, 247, 49])
  , executionDigest := (bytes [141, 81, 95, 195, 231, 84, 171, 240, 150, 119, 148, 108, 81, 62, 93, 105, 24, 74, 13, 118, 229, 236, 2, 205, 125, 30, 81, 145, 166, 192, 80, 84])
  , finalStateDigest := (bytes [145, 232, 119, 42, 209, 144, 217, 53, 205, 241, 241, 70, 26, 199, 99, 90, 150, 109, 80, 126, 52, 204, 98, 226, 231, 236, 152, 221, 67, 149, 32, 60])
  , transcriptFinalDigest := (bytes [32, 9, 174, 199, 85, 101, 126, 146, 43, 45, 60, 37, 147, 31, 232, 252, 13, 140, 146, 138, 4, 31, 72, 38, 94, 151, 226, 196, 134, 177, 219, 179])
  , mainLaneSurfaceDigest := (bytes [206, 3, 202, 216, 146, 106, 86, 175, 104, 58, 209, 97, 164, 0, 227, 213, 164, 134, 78, 92, 146, 178, 89, 102, 45, 254, 150, 26, 216, 79, 9, 62])
  , rootLaneColumnsDigest := (bytes [221, 121, 206, 183, 151, 219, 178, 140, 208, 65, 59, 55, 61, 251, 94, 139, 124, 108, 51, 165, 202, 100, 78, 163, 69, 159, 201, 110, 122, 253, 116, 183])
  , publicStepCount := 4
  , initialPc := 0
  , finalPc := 20
  , halted := true
  , digest := (bytes [122, 52, 50, 123, 204, 17, 136, 106, 135, 88, 191, 54, 111, 207, 151, 155, 170, 52, 221, 135, 91, 123, 9, 231, 95, 161, 110, 6, 178, 38, 88, 141])
}
  , kernel := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "control_flow_bltu_taken_skip_ecall", fixtureId := "control_flow_bltu_taken_skip_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.controlFlow, .nativeAlu] }
  , executionDigest := (bytes [141, 81, 95, 195, 231, 84, 171, 240, 150, 119, 148, 108, 81, 62, 93, 105, 24, 74, 13, 118, 229, 236, 2, 205, 125, 30, 81, 145, 166, 192, 80, 84])
  , shape := { executionRowCount := 4, realRowCount := 4, effectRowCount := 4, commitRowCount := 4, digest := (bytes [45, 178, 181, 197, 132, 60, 130, 1, 239, 208, 160, 249, 86, 246, 26, 179, 94, 235, 136, 250, 242, 5, 139, 0, 36, 216, 225, 255, 232, 86, 248, 123]) }
  , digest := (bytes [112, 166, 159, 48, 54, 154, 39, 37, 66, 206, 161, 92, 96, 250, 218, 45, 224, 115, 130, 186, 10, 130, 140, 49, 180, 165, 5, 252, 146, 53, 197, 246])
}
  , stages := { summary := { stage1RowCount := 4, stage2RegisterReadCount := 4, stage2RegisterWriteCount := 2, stage2RamEventCount := 0, stage2TwistLinkCount := 4, stage3ContinuityCount := 4, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [188, 146, 61, 220, 245, 51, 7, 161, 36, 1, 199, 100, 62, 187, 19, 182, 215, 124, 14, 176, 250, 206, 43, 76, 0, 125, 203, 144, 45, 193, 111, 34]) }, digest := (bytes [109, 34, 58, 13, 68, 111, 109, 31, 96, 208, 232, 119, 140, 198, 44, 192, 184, 71, 199, 65, 42, 115, 36, 133, 68, 13, 13, 169, 75, 7, 175, 245]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [111, 175, 105, 140, 80, 17, 142, 93, 248, 164, 96, 185, 48, 162, 95, 31, 129, 229, 91, 133, 255, 51, 20, 113, 142, 90, 183, 115, 215, 9, 119, 221]), stage1Digest := (bytes [25, 73, 79, 186, 228, 183, 73, 233, 189, 112, 167, 162, 152, 240, 148, 29, 213, 232, 86, 138, 230, 177, 213, 88, 19, 177, 166, 227, 154, 2, 137, 129]), stage2Digest := (bytes [87, 113, 117, 191, 83, 10, 169, 77, 43, 16, 164, 94, 124, 182, 38, 228, 106, 208, 172, 111, 233, 21, 133, 202, 82, 216, 170, 88, 72, 152, 172, 175]), stage3Digest := (bytes [241, 139, 61, 96, 28, 236, 184, 76, 31, 31, 90, 170, 231, 105, 75, 206, 127, 224, 133, 83, 235, 74, 203, 217, 94, 188, 29, 205, 255, 17, 30, 140]), transcriptDigest := (bytes [32, 9, 174, 199, 85, 101, 126, 146, 43, 45, 60, 37, 147, 31, 232, 252, 13, 140, 146, 138, 4, 31, 72, 38, 94, 151, 226, 196, 134, 177, 219, 179]), executionDigest := (bytes [141, 81, 95, 195, 231, 84, 171, 240, 150, 119, 148, 108, 81, 62, 93, 105, 24, 74, 13, 118, 229, 236, 2, 205, 125, 30, 81, 145, 166, 192, 80, 84]), digest := (bytes [152, 125, 92, 134, 22, 78, 58, 40, 178, 14, 88, 98, 132, 45, 212, 206, 247, 51, 80, 130, 128, 238, 181, 75, 151, 196, 76, 172, 107, 14, 225, 214]) }, statementDigest := (bytes [70, 55, 113, 218, 38, 87, 230, 174, 16, 225, 19, 209, 254, 176, 6, 240, 27, 30, 246, 106, 124, 118, 255, 131, 49, 64, 127, 143, 155, 66, 98, 78]), proofDigest := (bytes [185, 142, 210, 249, 201, 142, 197, 199, 27, 226, 48, 201, 108, 60, 49, 85, 206, 93, 253, 241, 106, 76, 1, 188, 62, 66, 238, 11, 178, 124, 11, 52]), digest := (bytes [65, 26, 100, 145, 74, 120, 199, 240, 89, 3, 83, 20, 165, 222, 220, 132, 16, 139, 115, 218, 43, 141, 174, 246, 216, 76, 38, 234, 113, 208, 59, 40]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [103, 100, 104, 36, 35, 103, 162, 168, 213, 214, 209, 209, 132, 135, 142, 250, 213, 132, 243, 119, 145, 105, 161, 140, 83, 177, 48, 60, 14, 167, 180, 141]), stage1Digest := (bytes [128, 238, 161, 239, 189, 69, 242, 121, 172, 205, 232, 176, 32, 68, 44, 111, 49, 93, 186, 52, 195, 192, 189, 151, 225, 186, 218, 219, 91, 240, 105, 63]), stage2Digest := (bytes [216, 184, 107, 187, 133, 97, 85, 65, 217, 240, 211, 65, 137, 181, 151, 92, 186, 241, 133, 206, 73, 117, 12, 179, 62, 14, 50, 89, 167, 219, 181, 178]), stage3Digest := (bytes [191, 206, 12, 122, 147, 242, 118, 171, 192, 141, 23, 50, 182, 146, 160, 145, 190, 115, 129, 12, 181, 246, 179, 115, 150, 246, 22, 106, 186, 48, 187, 98]), digest := (bytes [92, 51, 58, 231, 23, 44, 141, 7, 152, 143, 177, 47, 203, 132, 212, 147, 101, 53, 133, 183, 197, 36, 119, 86, 92, 3, 179, 0, 36, 176, 221, 65]) }, digest := (bytes [73, 38, 46, 25, 162, 161, 168, 126, 50, 68, 64, 188, 123, 230, 56, 144, 178, 143, 86, 192, 105, 252, 131, 99, 17, 48, 126, 45, 175, 212, 0, 248]) }
  , kernelOpening := { openingDigest := (bytes [135, 255, 68, 0, 28, 26, 183, 27, 46, 170, 97, 38, 17, 25, 126, 144, 233, 156, 153, 183, 12, 240, 110, 144, 219, 45, 105, 230, 158, 183, 103, 136]), bindings := { claimDigest := (bytes [72, 7, 3, 5, 173, 99, 193, 180, 81, 164, 158, 216, 223, 154, 53, 146, 6, 46, 137, 251, 184, 226, 234, 166, 27, 2, 53, 110, 232, 232, 135, 156]), bindingsDigest := (bytes [149, 116, 242, 126, 164, 207, 175, 13, 120, 99, 112, 63, 4, 242, 128, 143, 42, 164, 96, 35, 17, 48, 144, 46, 91, 215, 0, 135, 132, 42, 78, 187]), preparedStepsDigest := (bytes [233, 105, 218, 32, 202, 0, 161, 146, 196, 241, 173, 181, 115, 83, 214, 12, 56, 149, 55, 215, 144, 203, 125, 119, 222, 110, 131, 153, 184, 8, 22, 154]), digest := (bytes [172, 163, 69, 48, 75, 207, 123, 188, 19, 211, 93, 217, 188, 92, 156, 157, 10, 254, 7, 67, 201, 59, 118, 164, 136, 136, 135, 76, 188, 191, 93, 201]) }, digest := (bytes [98, 125, 147, 223, 161, 241, 121, 194, 165, 244, 173, 162, 241, 95, 161, 250, 36, 69, 79, 223, 249, 222, 177, 96, 162, 15, 42, 137, 44, 132, 239, 46]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [104, 75, 53, 178, 188, 110, 48, 89, 175, 93, 43, 239, 84, 67, 42, 71, 136, 216, 132, 80, 70, 124, 99, 86, 180, 239, 48, 149, 81, 95, 247, 49]), terminal := { root0Digest := (bytes [129, 249, 195, 4, 194, 62, 5, 111, 3, 163, 217, 146, 174, 130, 122, 238, 234, 192, 21, 127, 252, 112, 84, 85, 106, 53, 39, 158, 101, 145, 151, 55]), executionDigest := (bytes [141, 81, 95, 195, 231, 84, 171, 240, 150, 119, 148, 108, 81, 62, 93, 105, 24, 74, 13, 118, 229, 236, 2, 205, 125, 30, 81, 145, 166, 192, 80, 84]), finalStateDigest := (bytes [145, 232, 119, 42, 209, 144, 217, 53, 205, 241, 241, 70, 26, 199, 99, 90, 150, 109, 80, 126, 52, 204, 98, 226, 231, 236, 152, 221, 67, 149, 32, 60]), transcriptFinalDigest := (bytes [32, 9, 174, 199, 85, 101, 126, 146, 43, 45, 60, 37, 147, 31, 232, 252, 13, 140, 146, 138, 4, 31, 72, 38, 94, 151, 226, 196, 134, 177, 219, 179]), finalPc := 20, halted := true, digest := (bytes [225, 32, 249, 166, 241, 155, 145, 184, 164, 62, 114, 94, 104, 63, 167, 0, 111, 80, 146, 51, 93, 63, 190, 95, 156, 193, 159, 235, 2, 235, 102, 175]) }, digest := (bytes [193, 17, 222, 111, 188, 222, 235, 46, 185, 0, 160, 47, 237, 245, 35, 115, 29, 15, 128, 180, 246, 161, 27, 227, 150, 166, 31, 20, 132, 222, 66, 93]) }, statementDigest := (bytes [170, 31, 192, 204, 63, 201, 243, 188, 60, 231, 196, 188, 54, 215, 172, 146, 110, 74, 203, 63, 19, 192, 42, 92, 220, 206, 84, 194, 169, 96, 168, 182]), proofDigest := (bytes [189, 114, 29, 77, 63, 243, 61, 174, 87, 81, 74, 108, 167, 238, 255, 56, 205, 191, 131, 133, 251, 114, 9, 30, 219, 153, 60, 82, 165, 81, 165, 73]), digest := (bytes [222, 91, 48, 24, 92, 170, 51, 29, 108, 115, 89, 129, 252, 146, 235, 29, 165, 42, 72, 223, 231, 116, 42, 203, 141, 146, 81, 224, 106, 228, 41, 119]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [60, 226, 26, 9, 218, 106, 1, 219, 145, 76, 252, 6, 9, 158, 230, 215, 33, 119, 133, 248, 125, 83, 74, 254, 42, 99, 109, 35, 207, 217, 240, 185]), layoutVersion := 1, digest := (bytes [131, 223, 208, 63, 140, 78, 62, 114, 188, 153, 94, 55, 121, 186, 251, 10, 174, 8, 144, 40, 101, 129, 149, 23, 39, 106, 59, 2, 139, 213, 27, 184]) }, rowWidth := 38, timeLen := 4, columnDigests := [(bytes [212, 186, 229, 172, 74, 68, 211, 103, 24, 241, 21, 82, 209, 33, 189, 99, 223, 36, 129, 167, 9, 173, 76, 108, 178, 222, 90, 225, 89, 142, 8, 14]), (bytes [56, 58, 241, 13, 94, 161, 102, 38, 209, 85, 101, 10, 115, 74, 68, 15, 139, 16, 65, 164, 142, 61, 38, 80, 159, 19, 8, 220, 33, 174, 155, 155]), (bytes [29, 30, 250, 119, 67, 192, 190, 83, 169, 199, 126, 126, 209, 9, 207, 51, 13, 31, 240, 215, 38, 77, 233, 53, 71, 218, 94, 76, 41, 218, 33, 58]), (bytes [181, 122, 105, 181, 35, 180, 95, 214, 79, 41, 41, 2, 114, 48, 216, 55, 223, 211, 166, 64, 24, 33, 244, 234, 111, 10, 124, 63, 69, 70, 27, 116]), (bytes [235, 168, 211, 18, 219, 164, 123, 11, 1, 214, 235, 228, 142, 231, 19, 191, 111, 116, 112, 196, 167, 65, 6, 113, 150, 204, 141, 39, 111, 24, 165, 153]), (bytes [242, 28, 35, 169, 87, 104, 212, 237, 236, 149, 250, 219, 103, 80, 207, 126, 166, 205, 108, 128, 249, 85, 204, 223, 195, 102, 69, 23, 26, 53, 12, 57]), (bytes [91, 136, 102, 108, 254, 142, 77, 48, 97, 138, 138, 188, 220, 213, 55, 183, 133, 216, 230, 69, 191, 7, 253, 203, 112, 162, 85, 64, 74, 16, 34, 24]), (bytes [145, 208, 161, 0, 15, 127, 128, 193, 17, 127, 54, 222, 14, 0, 56, 94, 162, 110, 235, 214, 215, 110, 110, 82, 30, 10, 209, 128, 138, 179, 97, 121]), (bytes [13, 51, 13, 112, 10, 98, 204, 18, 53, 169, 156, 155, 63, 147, 114, 64, 241, 138, 154, 179, 238, 77, 114, 193, 171, 122, 197, 145, 246, 175, 206, 33]), (bytes [142, 21, 17, 77, 228, 49, 25, 177, 110, 190, 40, 43, 77, 239, 100, 234, 232, 124, 233, 138, 18, 189, 28, 101, 61, 173, 87, 220, 21, 69, 47, 137]), (bytes [32, 64, 97, 165, 48, 228, 106, 97, 58, 99, 14, 168, 63, 135, 66, 111, 135, 195, 225, 237, 39, 221, 23, 227, 16, 4, 135, 55, 248, 191, 135, 167]), (bytes [160, 5, 243, 183, 153, 60, 211, 231, 77, 120, 63, 81, 113, 147, 36, 148, 46, 54, 237, 238, 168, 176, 4, 184, 126, 205, 7, 60, 5, 32, 148, 213]), (bytes [238, 189, 198, 6, 199, 30, 93, 193, 29, 126, 221, 61, 73, 119, 129, 87, 55, 227, 133, 106, 170, 178, 160, 203, 102, 209, 230, 172, 220, 2, 72, 166]), (bytes [43, 8, 73, 107, 92, 98, 192, 143, 194, 86, 81, 10, 28, 138, 74, 179, 89, 196, 21, 18, 77, 39, 42, 122, 78, 216, 30, 91, 90, 243, 230, 0]), (bytes [74, 226, 37, 10, 152, 135, 71, 32, 121, 204, 236, 95, 238, 168, 237, 37, 113, 198, 64, 103, 189, 79, 90, 86, 18, 168, 112, 176, 240, 27, 29, 182]), (bytes [220, 193, 230, 244, 243, 14, 93, 42, 216, 108, 251, 253, 94, 191, 212, 189, 13, 211, 94, 236, 218, 138, 122, 7, 190, 222, 130, 249, 182, 150, 137, 189]), (bytes [223, 89, 191, 11, 110, 102, 31, 137, 129, 115, 137, 48, 64, 221, 208, 112, 235, 228, 24, 226, 254, 59, 16, 16, 192, 134, 30, 101, 212, 162, 156, 187]), (bytes [156, 22, 213, 157, 3, 147, 139, 132, 146, 22, 57, 209, 56, 31, 20, 20, 229, 105, 89, 38, 226, 230, 110, 49, 208, 70, 178, 10, 75, 21, 225, 62]), (bytes [89, 6, 118, 169, 105, 54, 5, 121, 26, 253, 91, 160, 13, 78, 211, 28, 177, 107, 187, 177, 10, 185, 35, 168, 191, 215, 99, 41, 155, 74, 182, 15]), (bytes [16, 1, 45, 207, 125, 115, 77, 40, 96, 249, 191, 96, 68, 155, 161, 144, 89, 205, 15, 173, 177, 139, 3, 87, 248, 132, 221, 254, 91, 235, 118, 133]), (bytes [2, 197, 213, 149, 21, 90, 236, 108, 141, 146, 26, 38, 0, 78, 135, 95, 223, 228, 221, 179, 125, 245, 167, 198, 49, 196, 48, 128, 192, 39, 124, 49]), (bytes [130, 134, 127, 131, 40, 47, 149, 206, 210, 112, 225, 17, 66, 25, 14, 78, 65, 235, 99, 73, 206, 90, 67, 148, 19, 78, 146, 25, 197, 149, 108, 61]), (bytes [8, 234, 67, 158, 76, 76, 170, 16, 58, 161, 138, 98, 35, 61, 115, 114, 104, 189, 45, 62, 96, 35, 11, 160, 56, 73, 223, 212, 106, 84, 224, 145]), (bytes [0, 189, 116, 3, 67, 124, 251, 249, 47, 128, 49, 73, 210, 47, 86, 252, 162, 78, 171, 9, 96, 183, 112, 195, 81, 120, 202, 223, 242, 24, 76, 51]), (bytes [81, 144, 1, 221, 155, 166, 187, 155, 181, 172, 254, 158, 176, 149, 110, 161, 164, 146, 156, 197, 231, 227, 176, 108, 72, 168, 128, 97, 162, 214, 166, 78]), (bytes [238, 147, 134, 181, 8, 29, 128, 200, 221, 198, 65, 181, 234, 22, 117, 159, 112, 0, 90, 214, 190, 69, 86, 72, 209, 196, 234, 23, 145, 109, 49, 190]), (bytes [150, 94, 21, 115, 92, 3, 250, 46, 250, 39, 23, 156, 66, 177, 198, 103, 242, 34, 109, 175, 253, 18, 181, 44, 23, 6, 9, 9, 119, 235, 11, 108]), (bytes [135, 215, 141, 47, 156, 11, 54, 54, 3, 72, 179, 247, 223, 155, 104, 7, 155, 222, 232, 159, 97, 172, 115, 97, 167, 121, 212, 57, 156, 44, 117, 203]), (bytes [84, 95, 115, 25, 213, 106, 24, 56, 216, 206, 94, 157, 100, 187, 198, 197, 93, 1, 173, 134, 90, 112, 47, 80, 254, 7, 54, 249, 32, 132, 243, 167]), (bytes [130, 198, 251, 47, 44, 43, 143, 92, 82, 195, 92, 157, 42, 215, 42, 26, 5, 251, 108, 34, 34, 0, 80, 113, 213, 113, 25, 247, 190, 124, 74, 52]), (bytes [234, 182, 234, 160, 23, 192, 246, 199, 173, 187, 203, 106, 254, 25, 134, 196, 2, 40, 181, 117, 170, 220, 56, 86, 63, 246, 0, 182, 78, 16, 61, 77]), (bytes [40, 254, 204, 213, 6, 140, 117, 235, 134, 79, 86, 81, 169, 63, 60, 118, 8, 156, 87, 198, 194, 60, 29, 160, 125, 250, 15, 187, 147, 220, 29, 92]), (bytes [18, 187, 180, 226, 104, 66, 42, 243, 22, 156, 53, 240, 151, 142, 203, 83, 91, 143, 153, 183, 211, 14, 178, 15, 249, 35, 88, 211, 226, 167, 221, 238]), (bytes [164, 40, 127, 229, 211, 147, 121, 221, 253, 56, 242, 238, 25, 160, 231, 5, 98, 88, 35, 198, 216, 51, 242, 34, 196, 132, 1, 62, 202, 49, 246, 41]), (bytes [122, 105, 77, 66, 174, 33, 37, 82, 171, 117, 60, 146, 152, 71, 176, 9, 4, 214, 95, 111, 117, 16, 77, 11, 22, 12, 202, 53, 36, 93, 76, 79]), (bytes [190, 26, 99, 184, 175, 199, 251, 124, 134, 183, 220, 35, 196, 195, 152, 135, 36, 169, 87, 198, 14, 22, 245, 143, 20, 239, 221, 18, 139, 77, 165, 236]), (bytes [80, 33, 41, 82, 68, 242, 18, 200, 209, 172, 125, 228, 155, 229, 192, 181, 222, 62, 254, 113, 197, 197, 209, 167, 162, 245, 86, 19, 189, 248, 96, 43]), (bytes [90, 10, 190, 250, 226, 23, 47, 210, 182, 164, 148, 175, 37, 226, 99, 192, 247, 166, 149, 66, 95, 29, 230, 232, 50, 99, 224, 203, 78, 177, 221, 250])], familyDigest := (bytes [60, 226, 26, 9, 218, 106, 1, 219, 145, 76, 252, 6, 9, 158, 230, 215, 33, 119, 133, 248, 125, 83, 74, 254, 42, 99, 109, 35, 207, 217, 240, 185]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [60, 226, 26, 9, 218, 106, 1, 219, 145, 76, 252, 6, 9, 158, 230, 215, 33, 119, 133, 248, 125, 83, 74, 254, 42, 99, 109, 35, 207, 217, 240, 185]), layoutVersion := 1, digest := (bytes [131, 223, 208, 63, 140, 78, 62, 114, 188, 153, 94, 55, 121, 186, 251, 10, 174, 8, 144, 40, 101, 129, 149, 23, 39, 106, 59, 2, 139, 213, 27, 184]) }, logicalIndex := 0, digest := (bytes [102, 193, 167, 113, 19, 197, 238, 244, 130, 208, 64, 28, 70, 92, 155, 50, 117, 135, 113, 248, 136, 248, 151, 3, 160, 8, 204, 52, 13, 32, 213, 27]) }, valueDigest := (bytes [48, 9, 158, 59, 120, 45, 200, 155, 8, 144, 252, 183, 179, 168, 71, 138, 10, 136, 117, 72, 217, 133, 28, 26, 240, 134, 159, 61, 227, 8, 46, 227]), digest := (bytes [157, 29, 105, 164, 228, 100, 34, 43, 226, 130, 195, 108, 5, 73, 10, 134, 63, 113, 148, 49, 24, 192, 159, 83, 170, 86, 173, 32, 237, 192, 45, 56]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [60, 226, 26, 9, 218, 106, 1, 219, 145, 76, 252, 6, 9, 158, 230, 215, 33, 119, 133, 248, 125, 83, 74, 254, 42, 99, 109, 35, 207, 217, 240, 185]), layoutVersion := 1, digest := (bytes [131, 223, 208, 63, 140, 78, 62, 114, 188, 153, 94, 55, 121, 186, 251, 10, 174, 8, 144, 40, 101, 129, 149, 23, 39, 106, 59, 2, 139, 213, 27, 184]) }, logicalIndex := 3, digest := (bytes [42, 14, 11, 181, 92, 135, 182, 1, 141, 107, 200, 170, 222, 89, 64, 23, 196, 173, 115, 96, 143, 146, 210, 88, 108, 166, 105, 221, 234, 228, 143, 165]) }, valueDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [124, 166, 215, 100, 149, 36, 226, 108, 212, 188, 194, 29, 21, 167, 128, 220, 35, 18, 192, 205, 143, 231, 17, 59, 34, 46, 111, 237, 195, 188, 201, 110]) }), digest := (bytes [221, 121, 206, 183, 151, 219, 178, 140, 208, 65, 59, 55, 61, 251, 94, 139, 124, 108, 51, 165, 202, 100, 78, 163, 69, 159, 201, 110, 122, 253, 116, 183]) }
  , rootLaneCommitment := { timeLen := 4, commitments := { commitmentCount := 38, digest := (bytes [192, 237, 17, 53, 235, 29, 69, 55, 72, 94, 126, 40, 158, 253, 226, 47, 115, 226, 118, 182, 238, 41, 184, 33, 102, 49, 153, 185, 96, 71, 8, 3]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [192, 237, 17, 53, 235, 29, 69, 55, 72, 94, 126, 40, 158, 253, 226, 47, 115, 226, 118, 182, 238, 41, 184, 33, 102, 49, 153, 185, 96, 71, 8, 3]), layoutVersion := 3, digest := (bytes [201, 236, 21, 58, 166, 238, 253, 205, 43, 109, 28, 246, 241, 38, 130, 177, 148, 193, 63, 77, 7, 120, 159, 109, 253, 43, 61, 69, 115, 94, 174, 88]) }, logicalIndex := 0, digest := (bytes [176, 163, 215, 61, 193, 203, 148, 52, 42, 158, 76, 174, 148, 4, 72, 111, 177, 60, 17, 171, 220, 102, 81, 247, 70, 125, 58, 43, 236, 26, 94, 45]) }, valueDigest := (bytes [48, 9, 158, 59, 120, 45, 200, 155, 8, 144, 252, 183, 179, 168, 71, 138, 10, 136, 117, 72, 217, 133, 28, 26, 240, 134, 159, 61, 227, 8, 46, 227]), digest := (bytes [234, 196, 19, 209, 186, 228, 212, 26, 38, 142, 39, 225, 81, 151, 86, 95, 113, 78, 96, 219, 206, 214, 155, 189, 52, 238, 232, 200, 40, 66, 250, 181]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [192, 237, 17, 53, 235, 29, 69, 55, 72, 94, 126, 40, 158, 253, 226, 47, 115, 226, 118, 182, 238, 41, 184, 33, 102, 49, 153, 185, 96, 71, 8, 3]), layoutVersion := 3, digest := (bytes [201, 236, 21, 58, 166, 238, 253, 205, 43, 109, 28, 246, 241, 38, 130, 177, 148, 193, 63, 77, 7, 120, 159, 109, 253, 43, 61, 69, 115, 94, 174, 88]) }, logicalIndex := 3, digest := (bytes [236, 197, 73, 220, 3, 71, 76, 31, 216, 219, 236, 53, 55, 174, 245, 177, 142, 213, 29, 54, 114, 245, 162, 1, 207, 96, 239, 222, 68, 233, 246, 139]) }, valueDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [183, 180, 41, 104, 220, 26, 126, 24, 172, 193, 152, 11, 61, 109, 89, 163, 114, 254, 104, 154, 139, 107, 198, 57, 21, 41, 181, 174, 163, 37, 161, 52]) }), digest := (bytes [141, 143, 90, 112, 155, 41, 142, 170, 186, 118, 48, 253, 234, 233, 236, 85, 63, 77, 89, 42, 7, 3, 3, 83, 178, 89, 118, 201, 61, 171, 222, 38]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [221, 121, 206, 183, 151, 219, 178, 140, 208, 65, 59, 55, 61, 251, 94, 139, 124, 108, 51, 165, 202, 100, 78, 163, 69, 159, 201, 110, 122, 253, 116, 183]), rootLaneCommitmentDigest := (bytes [141, 143, 90, 112, 155, 41, 142, 170, 186, 118, 48, 253, 234, 233, 236, 85, 63, 77, 89, 42, 7, 3, 3, 83, 178, 89, 118, 201, 61, 171, 222, 38]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 4, digest := (bytes [31, 115, 81, 186, 95, 69, 142, 3, 165, 129, 219, 15, 136, 124, 218, 48, 84, 173, 203, 2, 196, 241, 239, 30, 35, 37, 239, 33, 221, 205, 34, 226]) }, statementDigest := (bytes [215, 58, 13, 112, 249, 122, 159, 176, 47, 114, 90, 228, 190, 64, 141, 159, 65, 189, 236, 253, 227, 128, 85, 167, 170, 176, 162, 73, 61, 197, 121, 184]), proofDigest := (bytes [232, 129, 203, 10, 148, 72, 221, 136, 48, 38, 161, 187, 138, 65, 189, 148, 13, 231, 220, 85, 13, 238, 35, 26, 255, 49, 125, 206, 63, 155, 126, 21]), digest := (bytes [135, 8, 111, 37, 24, 70, 42, 18, 173, 6, 44, 252, 136, 179, 24, 52, 60, 161, 238, 214, 232, 27, 40, 127, 3, 170, 34, 222, 185, 123, 205, 117]) }
  , digest := (bytes [90, 94, 215, 127, 211, 168, 177, 202, 163, 46, 19, 214, 97, 31, 199, 145, 189, 186, 220, 159, 233, 9, 221, 200, 10, 133, 233, 41, 240, 147, 15, 5])
}
}
    , exportedStatement := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , foldSchedule := Nightstream.FoldSchedule.wholeTrace
  , chunkCount := 1
  , stageClaimsDigest := (bytes [65, 26, 100, 145, 74, 120, 199, 240, 89, 3, 83, 20, 165, 222, 220, 132, 16, 139, 115, 218, 43, 141, 174, 246, 216, 76, 38, 234, 113, 208, 59, 40])
  , stagePackagesDigest := (bytes [73, 38, 46, 25, 162, 161, 168, 126, 50, 68, 64, 188, 123, 230, 56, 144, 178, 143, 86, 192, 105, 252, 131, 99, 17, 48, 126, 45, 175, 212, 0, 248])
  , kernelOpeningDigest := (bytes [98, 125, 147, 223, 161, 241, 121, 194, 165, 244, 173, 162, 241, 95, 161, 250, 36, 69, 79, 223, 249, 222, 177, 96, 162, 15, 42, 137, 44, 132, 239, 46])
  , preparedStepBindingsDigest := (bytes [104, 75, 53, 178, 188, 110, 48, 89, 175, 93, 43, 239, 84, 67, 42, 71, 136, 216, 132, 80, 70, 124, 99, 86, 180, 239, 48, 149, 81, 95, 247, 49])
  , executionDigest := (bytes [141, 81, 95, 195, 231, 84, 171, 240, 150, 119, 148, 108, 81, 62, 93, 105, 24, 74, 13, 118, 229, 236, 2, 205, 125, 30, 81, 145, 166, 192, 80, 84])
  , finalStateDigest := (bytes [145, 232, 119, 42, 209, 144, 217, 53, 205, 241, 241, 70, 26, 199, 99, 90, 150, 109, 80, 126, 52, 204, 98, 226, 231, 236, 152, 221, 67, 149, 32, 60])
  , transcriptFinalDigest := (bytes [32, 9, 174, 199, 85, 101, 126, 146, 43, 45, 60, 37, 147, 31, 232, 252, 13, 140, 146, 138, 4, 31, 72, 38, 94, 151, 226, 196, 134, 177, 219, 179])
  , mainLaneSurfaceDigest := (bytes [206, 3, 202, 216, 146, 106, 86, 175, 104, 58, 209, 97, 164, 0, 227, 213, 164, 134, 78, 92, 146, 178, 89, 102, 45, 254, 150, 26, 216, 79, 9, 62])
  , rootLaneColumnsDigest := (bytes [221, 121, 206, 183, 151, 219, 178, 140, 208, 65, 59, 55, 61, 251, 94, 139, 124, 108, 51, 165, 202, 100, 78, 163, 69, 159, 201, 110, 122, 253, 116, 183])
  , publicStepCount := 4
  , initialPc := 0
  , finalPc := 20
  , halted := true
  , digest := (bytes [122, 52, 50, 123, 204, 17, 136, 106, 135, 88, 191, 54, 111, 207, 151, 155, 170, 52, 221, 135, 91, 123, 9, 231, 95, 161, 110, 6, 178, 38, 88, 141])
}
    , exportedClaims := {
  accepted := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , statement := { proofStatementDigest := (bytes [122, 52, 50, 123, 204, 17, 136, 106, 135, 88, 191, 54, 111, 207, 151, 155, 170, 52, 221, 135, 91, 123, 9, 231, 95, 161, 110, 6, 178, 38, 88, 141]), kernelOpeningDigest := (bytes [98, 125, 147, 223, 161, 241, 121, 194, 165, 244, 173, 162, 241, 95, 161, 250, 36, 69, 79, 223, 249, 222, 177, 96, 162, 15, 42, 137, 44, 132, 239, 46]), digest := (bytes [209, 213, 140, 173, 19, 168, 9, 9, 161, 12, 201, 164, 82, 46, 57, 156, 93, 153, 204, 19, 10, 102, 64, 200, 134, 198, 116, 82, 33, 75, 102, 180]) }
  , mainLane := { mainLaneBundleDigest := (bytes [135, 8, 111, 37, 24, 70, 42, 18, 173, 6, 44, 252, 136, 179, 24, 52, 60, 161, 238, 214, 232, 27, 40, 127, 3, 170, 34, 222, 185, 123, 205, 117]), digest := (bytes [103, 53, 101, 55, 118, 16, 139, 246, 19, 127, 136, 198, 171, 147, 146, 115, 215, 251, 181, 204, 167, 29, 152, 112, 67, 235, 174, 98, 97, 9, 101, 157]) }
  , terminal := { finalStateDigest := (bytes [145, 232, 119, 42, 209, 144, 217, 53, 205, 241, 241, 70, 26, 199, 99, 90, 150, 109, 80, 126, 52, 204, 98, 226, 231, 236, 152, 221, 67, 149, 32, 60]), finalPc := 20, halted := true, digest := (bytes [208, 124, 234, 99, 149, 213, 99, 232, 239, 53, 203, 49, 65, 171, 56, 50, 252, 44, 110, 99, 126, 26, 6, 160, 104, 4, 205, 132, 52, 67, 122, 29]) }
  , digest := (bytes [66, 97, 0, 60, 71, 145, 126, 100, 159, 236, 5, 10, 48, 213, 231, 38, 25, 90, 109, 122, 47, 187, 159, 223, 235, 156, 123, 174, 217, 54, 97, 186])
}
  , mainLane := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { mainLaneBundleDigest := (bytes [135, 8, 111, 37, 24, 70, 42, 18, 173, 6, 44, 252, 136, 179, 24, 52, 60, 161, 238, 214, 232, 27, 40, 127, 3, 170, 34, 222, 185, 123, 205, 117]), digest := (bytes [251, 55, 201, 131, 182, 8, 22, 177, 207, 116, 149, 110, 154, 200, 85, 20, 218, 50, 79, 1, 199, 36, 36, 133, 253, 125, 129, 127, 8, 214, 202, 56]) }, digest := (bytes [162, 56, 49, 194, 55, 31, 53, 156, 149, 118, 22, 178, 201, 185, 192, 101, 204, 59, 169, 177, 124, 149, 255, 129, 248, 37, 202, 31, 104, 109, 210, 64]) }
  , opening := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , stages := { stageClaimsDigest := (bytes [65, 26, 100, 145, 74, 120, 199, 240, 89, 3, 83, 20, 165, 222, 220, 132, 16, 139, 115, 218, 43, 141, 174, 246, 216, 76, 38, 234, 113, 208, 59, 40]), stagePackagesDigest := (bytes [73, 38, 46, 25, 162, 161, 168, 126, 50, 68, 64, 188, 123, 230, 56, 144, 178, 143, 86, 192, 105, 252, 131, 99, 17, 48, 126, 45, 175, 212, 0, 248]), kernelOpeningDigest := (bytes [98, 125, 147, 223, 161, 241, 121, 194, 165, 244, 173, 162, 241, 95, 161, 250, 36, 69, 79, 223, 249, 222, 177, 96, 162, 15, 42, 137, 44, 132, 239, 46]), digest := (bytes [85, 187, 90, 30, 125, 50, 58, 187, 67, 218, 232, 199, 54, 165, 230, 114, 254, 249, 237, 153, 182, 105, 36, 54, 66, 79, 129, 193, 225, 61, 68, 91]) }
  , terminal := { preparedStepBindingsDigest := (bytes [104, 75, 53, 178, 188, 110, 48, 89, 175, 93, 43, 239, 84, 67, 42, 71, 136, 216, 132, 80, 70, 124, 99, 86, 180, 239, 48, 149, 81, 95, 247, 49]), executionDigest := (bytes [141, 81, 95, 195, 231, 84, 171, 240, 150, 119, 148, 108, 81, 62, 93, 105, 24, 74, 13, 118, 229, 236, 2, 205, 125, 30, 81, 145, 166, 192, 80, 84]), transcriptFinalDigest := (bytes [32, 9, 174, 199, 85, 101, 126, 146, 43, 45, 60, 37, 147, 31, 232, 252, 13, 140, 146, 138, 4, 31, 72, 38, 94, 151, 226, 196, 134, 177, 219, 179]), digest := (bytes [87, 182, 97, 166, 111, 149, 178, 14, 155, 45, 146, 138, 245, 216, 140, 149, 186, 96, 39, 8, 81, 119, 68, 114, 226, 115, 20, 41, 184, 45, 64, 122]) }
  , digest := (bytes [195, 184, 240, 146, 133, 189, 150, 25, 91, 109, 3, 74, 173, 134, 96, 162, 167, 129, 76, 91, 122, 15, 77, 163, 251, 107, 120, 179, 193, 176, 78, 71])
}
  , jointOpening := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), binding := { proofStatementDigest := (bytes [122, 52, 50, 123, 204, 17, 136, 106, 135, 88, 191, 54, 111, 207, 151, 155, 170, 52, 221, 135, 91, 123, 9, 231, 95, 161, 110, 6, 178, 38, 88, 141]), mainLaneClaimDigest := (bytes [162, 56, 49, 194, 55, 31, 53, 156, 149, 118, 22, 178, 201, 185, 192, 101, 204, 59, 169, 177, 124, 149, 255, 129, 248, 37, 202, 31, 104, 109, 210, 64]), kernelOpeningClaimDigest := (bytes [195, 184, 240, 146, 133, 189, 150, 25, 91, 109, 3, 74, 173, 134, 96, 162, 167, 129, 76, 91, 122, 15, 77, 163, 251, 107, 120, 179, 193, 176, 78, 71]), digest := (bytes [209, 170, 87, 77, 56, 90, 111, 124, 37, 248, 156, 90, 143, 164, 137, 230, 226, 213, 107, 89, 207, 180, 131, 104, 0, 5, 131, 129, 162, 122, 168, 113]) }, digest := (bytes [35, 92, 73, 174, 244, 58, 177, 82, 124, 240, 93, 221, 167, 121, 160, 103, 112, 195, 18, 53, 56, 175, 161, 66, 164, 36, 241, 55, 167, 116, 170, 102]) }
  , root0 := { rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212]), stages := { stage1Digest := (bytes [79, 54, 35, 89, 181, 60, 120, 62, 23, 216, 151, 8, 213, 60, 71, 0, 66, 90, 147, 125, 53, 147, 210, 191, 92, 59, 24, 230, 4, 58, 45, 9]), stage2Digest := (bytes [59, 77, 145, 209, 31, 130, 112, 69, 30, 34, 112, 204, 73, 72, 47, 51, 247, 164, 118, 200, 178, 22, 87, 88, 74, 116, 115, 132, 88, 127, 97, 100]), stage3Digest := (bytes [198, 81, 7, 250, 152, 135, 65, 159, 231, 42, 117, 161, 26, 121, 63, 197, 123, 212, 231, 113, 35, 37, 159, 177, 226, 104, 247, 68, 136, 30, 16, 163]), digest := (bytes [147, 76, 248, 17, 76, 51, 33, 217, 79, 25, 20, 23, 176, 183, 195, 225, 136, 159, 93, 141, 203, 55, 253, 138, 241, 122, 92, 25, 99, 124, 35, 178]) }, terminal := { root0Digest := (bytes [129, 249, 195, 4, 194, 62, 5, 111, 3, 163, 217, 146, 174, 130, 122, 238, 234, 192, 21, 127, 252, 112, 84, 85, 106, 53, 39, 158, 101, 145, 151, 55]), executionDigest := (bytes [141, 81, 95, 195, 231, 84, 171, 240, 150, 119, 148, 108, 81, 62, 93, 105, 24, 74, 13, 118, 229, 236, 2, 205, 125, 30, 81, 145, 166, 192, 80, 84]), finalStateDigest := (bytes [145, 232, 119, 42, 209, 144, 217, 53, 205, 241, 241, 70, 26, 199, 99, 90, 150, 109, 80, 126, 52, 204, 98, 226, 231, 236, 152, 221, 67, 149, 32, 60]), transcriptFinalDigest := (bytes [32, 9, 174, 199, 85, 101, 126, 146, 43, 45, 60, 37, 147, 31, 232, 252, 13, 140, 146, 138, 4, 31, 72, 38, 94, 151, 226, 196, 134, 177, 219, 179]), digest := (bytes [253, 47, 122, 16, 124, 129, 141, 81, 162, 68, 60, 83, 135, 22, 91, 85, 181, 98, 15, 46, 10, 222, 0, 229, 21, 217, 1, 121, 49, 65, 152, 151]) }, digest := (bytes [4, 116, 205, 118, 152, 173, 211, 205, 113, 177, 245, 57, 149, 71, 160, 104, 44, 149, 64, 76, 115, 215, 148, 43, 144, 162, 64, 58, 124, 129, 42, 60]) }
  , digest := (bytes [204, 23, 59, 134, 247, 245, 50, 148, 219, 45, 18, 46, 82, 107, 8, 151, 46, 69, 87, 116, 193, 170, 83, 156, 170, 156, 183, 210, 196, 21, 128, 165])
}
    , exportedKernelProof := {
  rootParamsId := (bytes [127, 171, 188, 220, 82, 144, 205, 186, 34, 139, 167, 217, 253, 83, 220, 67, 198, 79, 231, 47, 85, 22, 87, 191, 85, 70, 134, 150, 140, 200, 205, 212])
  , trace := {
  manifest := { name := "control_flow_bltu_taken_skip_ecall", fixtureId := "control_flow_bltu_taken_skip_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.controlFlow, .nativeAlu] }
  , executionDigest := (bytes [141, 81, 95, 195, 231, 84, 171, 240, 150, 119, 148, 108, 81, 62, 93, 105, 24, 74, 13, 118, 229, 236, 2, 205, 125, 30, 81, 145, 166, 192, 80, 84])
  , shape := { executionRowCount := 4, realRowCount := 4, effectRowCount := 4, commitRowCount := 4, digest := (bytes [45, 178, 181, 197, 132, 60, 130, 1, 239, 208, 160, 249, 86, 246, 26, 179, 94, 235, 136, 250, 242, 5, 139, 0, 36, 216, 225, 255, 232, 86, 248, 123]) }
  , digest := (bytes [112, 166, 159, 48, 54, 154, 39, 37, 66, 206, 161, 92, 96, 250, 218, 45, 224, 115, 130, 186, 10, 130, 140, 49, 180, 165, 5, 252, 146, 53, 197, 246])
}
  , stages := { summary := { stage1RowCount := 4, stage2RegisterReadCount := 4, stage2RegisterWriteCount := 2, stage2RamEventCount := 0, stage2TwistLinkCount := 4, stage3ContinuityCount := 4, stage3Halted := true, transcriptEventCount := 17, digest := (bytes [188, 146, 61, 220, 245, 51, 7, 161, 36, 1, 199, 100, 62, 187, 19, 182, 215, 124, 14, 176, 250, 206, 43, 76, 0, 125, 203, 144, 45, 193, 111, 34]) }, digest := (bytes [109, 34, 58, 13, 68, 111, 109, 31, 96, 208, 232, 119, 140, 198, 44, 192, 184, 71, 199, 65, 42, 115, 36, 133, 68, 13, 13, 169, 75, 7, 175, 245]) }
  , stageClaims := { summary := { claimBundleDigest := (bytes [111, 175, 105, 140, 80, 17, 142, 93, 248, 164, 96, 185, 48, 162, 95, 31, 129, 229, 91, 133, 255, 51, 20, 113, 142, 90, 183, 115, 215, 9, 119, 221]), stage1Digest := (bytes [25, 73, 79, 186, 228, 183, 73, 233, 189, 112, 167, 162, 152, 240, 148, 29, 213, 232, 86, 138, 230, 177, 213, 88, 19, 177, 166, 227, 154, 2, 137, 129]), stage2Digest := (bytes [87, 113, 117, 191, 83, 10, 169, 77, 43, 16, 164, 94, 124, 182, 38, 228, 106, 208, 172, 111, 233, 21, 133, 202, 82, 216, 170, 88, 72, 152, 172, 175]), stage3Digest := (bytes [241, 139, 61, 96, 28, 236, 184, 76, 31, 31, 90, 170, 231, 105, 75, 206, 127, 224, 133, 83, 235, 74, 203, 217, 94, 188, 29, 205, 255, 17, 30, 140]), transcriptDigest := (bytes [32, 9, 174, 199, 85, 101, 126, 146, 43, 45, 60, 37, 147, 31, 232, 252, 13, 140, 146, 138, 4, 31, 72, 38, 94, 151, 226, 196, 134, 177, 219, 179]), executionDigest := (bytes [141, 81, 95, 195, 231, 84, 171, 240, 150, 119, 148, 108, 81, 62, 93, 105, 24, 74, 13, 118, 229, 236, 2, 205, 125, 30, 81, 145, 166, 192, 80, 84]), digest := (bytes [152, 125, 92, 134, 22, 78, 58, 40, 178, 14, 88, 98, 132, 45, 212, 206, 247, 51, 80, 130, 128, 238, 181, 75, 151, 196, 76, 172, 107, 14, 225, 214]) }, statementDigest := (bytes [70, 55, 113, 218, 38, 87, 230, 174, 16, 225, 19, 209, 254, 176, 6, 240, 27, 30, 246, 106, 124, 118, 255, 131, 49, 64, 127, 143, 155, 66, 98, 78]), proofDigest := (bytes [185, 142, 210, 249, 201, 142, 197, 199, 27, 226, 48, 201, 108, 60, 49, 85, 206, 93, 253, 241, 106, 76, 1, 188, 62, 66, 238, 11, 178, 124, 11, 52]), digest := (bytes [65, 26, 100, 145, 74, 120, 199, 240, 89, 3, 83, 20, 165, 222, 220, 132, 16, 139, 115, 218, 43, 141, 174, 246, 216, 76, 38, 234, 113, 208, 59, 40]) }
  , stagePackages := { summary := { packageBundleDigest := (bytes [103, 100, 104, 36, 35, 103, 162, 168, 213, 214, 209, 209, 132, 135, 142, 250, 213, 132, 243, 119, 145, 105, 161, 140, 83, 177, 48, 60, 14, 167, 180, 141]), stage1Digest := (bytes [128, 238, 161, 239, 189, 69, 242, 121, 172, 205, 232, 176, 32, 68, 44, 111, 49, 93, 186, 52, 195, 192, 189, 151, 225, 186, 218, 219, 91, 240, 105, 63]), stage2Digest := (bytes [216, 184, 107, 187, 133, 97, 85, 65, 217, 240, 211, 65, 137, 181, 151, 92, 186, 241, 133, 206, 73, 117, 12, 179, 62, 14, 50, 89, 167, 219, 181, 178]), stage3Digest := (bytes [191, 206, 12, 122, 147, 242, 118, 171, 192, 141, 23, 50, 182, 146, 160, 145, 190, 115, 129, 12, 181, 246, 179, 115, 150, 246, 22, 106, 186, 48, 187, 98]), digest := (bytes [92, 51, 58, 231, 23, 44, 141, 7, 152, 143, 177, 47, 203, 132, 212, 147, 101, 53, 133, 183, 197, 36, 119, 86, 92, 3, 179, 0, 36, 176, 221, 65]) }, digest := (bytes [73, 38, 46, 25, 162, 161, 168, 126, 50, 68, 64, 188, 123, 230, 56, 144, 178, 143, 86, 192, 105, 252, 131, 99, 17, 48, 126, 45, 175, 212, 0, 248]) }
  , kernelOpening := { openingDigest := (bytes [135, 255, 68, 0, 28, 26, 183, 27, 46, 170, 97, 38, 17, 25, 126, 144, 233, 156, 153, 183, 12, 240, 110, 144, 219, 45, 105, 230, 158, 183, 103, 136]), bindings := { claimDigest := (bytes [72, 7, 3, 5, 173, 99, 193, 180, 81, 164, 158, 216, 223, 154, 53, 146, 6, 46, 137, 251, 184, 226, 234, 166, 27, 2, 53, 110, 232, 232, 135, 156]), bindingsDigest := (bytes [149, 116, 242, 126, 164, 207, 175, 13, 120, 99, 112, 63, 4, 242, 128, 143, 42, 164, 96, 35, 17, 48, 144, 46, 91, 215, 0, 135, 132, 42, 78, 187]), preparedStepsDigest := (bytes [233, 105, 218, 32, 202, 0, 161, 146, 196, 241, 173, 181, 115, 83, 214, 12, 56, 149, 55, 215, 144, 203, 125, 119, 222, 110, 131, 153, 184, 8, 22, 154]), digest := (bytes [172, 163, 69, 48, 75, 207, 123, 188, 19, 211, 93, 217, 188, 92, 156, 157, 10, 254, 7, 67, 201, 59, 118, 164, 136, 136, 135, 76, 188, 191, 93, 201]) }, digest := (bytes [98, 125, 147, 223, 161, 241, 121, 194, 165, 244, 173, 162, 241, 95, 161, 250, 36, 69, 79, 223, 249, 222, 177, 96, 162, 15, 42, 137, 44, 132, 239, 46]) }
  , kernelClaims := { summary := { preparedStepBindingsDigest := (bytes [104, 75, 53, 178, 188, 110, 48, 89, 175, 93, 43, 239, 84, 67, 42, 71, 136, 216, 132, 80, 70, 124, 99, 86, 180, 239, 48, 149, 81, 95, 247, 49]), terminal := { root0Digest := (bytes [129, 249, 195, 4, 194, 62, 5, 111, 3, 163, 217, 146, 174, 130, 122, 238, 234, 192, 21, 127, 252, 112, 84, 85, 106, 53, 39, 158, 101, 145, 151, 55]), executionDigest := (bytes [141, 81, 95, 195, 231, 84, 171, 240, 150, 119, 148, 108, 81, 62, 93, 105, 24, 74, 13, 118, 229, 236, 2, 205, 125, 30, 81, 145, 166, 192, 80, 84]), finalStateDigest := (bytes [145, 232, 119, 42, 209, 144, 217, 53, 205, 241, 241, 70, 26, 199, 99, 90, 150, 109, 80, 126, 52, 204, 98, 226, 231, 236, 152, 221, 67, 149, 32, 60]), transcriptFinalDigest := (bytes [32, 9, 174, 199, 85, 101, 126, 146, 43, 45, 60, 37, 147, 31, 232, 252, 13, 140, 146, 138, 4, 31, 72, 38, 94, 151, 226, 196, 134, 177, 219, 179]), finalPc := 20, halted := true, digest := (bytes [225, 32, 249, 166, 241, 155, 145, 184, 164, 62, 114, 94, 104, 63, 167, 0, 111, 80, 146, 51, 93, 63, 190, 95, 156, 193, 159, 235, 2, 235, 102, 175]) }, digest := (bytes [193, 17, 222, 111, 188, 222, 235, 46, 185, 0, 160, 47, 237, 245, 35, 115, 29, 15, 128, 180, 246, 161, 27, 227, 150, 166, 31, 20, 132, 222, 66, 93]) }, statementDigest := (bytes [170, 31, 192, 204, 63, 201, 243, 188, 60, 231, 196, 188, 54, 215, 172, 146, 110, 74, 203, 63, 19, 192, 42, 92, 220, 206, 84, 194, 169, 96, 168, 182]), proofDigest := (bytes [189, 114, 29, 77, 63, 243, 61, 174, 87, 81, 74, 108, 167, 238, 255, 56, 205, 191, 131, 133, 251, 114, 9, 30, 219, 153, 60, 82, 165, 81, 165, 73]), digest := (bytes [222, 91, 48, 24, 92, 170, 51, 29, 108, 115, 89, 129, 252, 146, 235, 29, 165, 42, 72, 223, 231, 116, 42, 203, 141, 146, 81, 224, 106, 228, 41, 119]) }
  , rootLaneColumns := { object := { familyTag := 0, commitmentDigest := (bytes [60, 226, 26, 9, 218, 106, 1, 219, 145, 76, 252, 6, 9, 158, 230, 215, 33, 119, 133, 248, 125, 83, 74, 254, 42, 99, 109, 35, 207, 217, 240, 185]), layoutVersion := 1, digest := (bytes [131, 223, 208, 63, 140, 78, 62, 114, 188, 153, 94, 55, 121, 186, 251, 10, 174, 8, 144, 40, 101, 129, 149, 23, 39, 106, 59, 2, 139, 213, 27, 184]) }, rowWidth := 38, timeLen := 4, columnDigests := [(bytes [212, 186, 229, 172, 74, 68, 211, 103, 24, 241, 21, 82, 209, 33, 189, 99, 223, 36, 129, 167, 9, 173, 76, 108, 178, 222, 90, 225, 89, 142, 8, 14]), (bytes [56, 58, 241, 13, 94, 161, 102, 38, 209, 85, 101, 10, 115, 74, 68, 15, 139, 16, 65, 164, 142, 61, 38, 80, 159, 19, 8, 220, 33, 174, 155, 155]), (bytes [29, 30, 250, 119, 67, 192, 190, 83, 169, 199, 126, 126, 209, 9, 207, 51, 13, 31, 240, 215, 38, 77, 233, 53, 71, 218, 94, 76, 41, 218, 33, 58]), (bytes [181, 122, 105, 181, 35, 180, 95, 214, 79, 41, 41, 2, 114, 48, 216, 55, 223, 211, 166, 64, 24, 33, 244, 234, 111, 10, 124, 63, 69, 70, 27, 116]), (bytes [235, 168, 211, 18, 219, 164, 123, 11, 1, 214, 235, 228, 142, 231, 19, 191, 111, 116, 112, 196, 167, 65, 6, 113, 150, 204, 141, 39, 111, 24, 165, 153]), (bytes [242, 28, 35, 169, 87, 104, 212, 237, 236, 149, 250, 219, 103, 80, 207, 126, 166, 205, 108, 128, 249, 85, 204, 223, 195, 102, 69, 23, 26, 53, 12, 57]), (bytes [91, 136, 102, 108, 254, 142, 77, 48, 97, 138, 138, 188, 220, 213, 55, 183, 133, 216, 230, 69, 191, 7, 253, 203, 112, 162, 85, 64, 74, 16, 34, 24]), (bytes [145, 208, 161, 0, 15, 127, 128, 193, 17, 127, 54, 222, 14, 0, 56, 94, 162, 110, 235, 214, 215, 110, 110, 82, 30, 10, 209, 128, 138, 179, 97, 121]), (bytes [13, 51, 13, 112, 10, 98, 204, 18, 53, 169, 156, 155, 63, 147, 114, 64, 241, 138, 154, 179, 238, 77, 114, 193, 171, 122, 197, 145, 246, 175, 206, 33]), (bytes [142, 21, 17, 77, 228, 49, 25, 177, 110, 190, 40, 43, 77, 239, 100, 234, 232, 124, 233, 138, 18, 189, 28, 101, 61, 173, 87, 220, 21, 69, 47, 137]), (bytes [32, 64, 97, 165, 48, 228, 106, 97, 58, 99, 14, 168, 63, 135, 66, 111, 135, 195, 225, 237, 39, 221, 23, 227, 16, 4, 135, 55, 248, 191, 135, 167]), (bytes [160, 5, 243, 183, 153, 60, 211, 231, 77, 120, 63, 81, 113, 147, 36, 148, 46, 54, 237, 238, 168, 176, 4, 184, 126, 205, 7, 60, 5, 32, 148, 213]), (bytes [238, 189, 198, 6, 199, 30, 93, 193, 29, 126, 221, 61, 73, 119, 129, 87, 55, 227, 133, 106, 170, 178, 160, 203, 102, 209, 230, 172, 220, 2, 72, 166]), (bytes [43, 8, 73, 107, 92, 98, 192, 143, 194, 86, 81, 10, 28, 138, 74, 179, 89, 196, 21, 18, 77, 39, 42, 122, 78, 216, 30, 91, 90, 243, 230, 0]), (bytes [74, 226, 37, 10, 152, 135, 71, 32, 121, 204, 236, 95, 238, 168, 237, 37, 113, 198, 64, 103, 189, 79, 90, 86, 18, 168, 112, 176, 240, 27, 29, 182]), (bytes [220, 193, 230, 244, 243, 14, 93, 42, 216, 108, 251, 253, 94, 191, 212, 189, 13, 211, 94, 236, 218, 138, 122, 7, 190, 222, 130, 249, 182, 150, 137, 189]), (bytes [223, 89, 191, 11, 110, 102, 31, 137, 129, 115, 137, 48, 64, 221, 208, 112, 235, 228, 24, 226, 254, 59, 16, 16, 192, 134, 30, 101, 212, 162, 156, 187]), (bytes [156, 22, 213, 157, 3, 147, 139, 132, 146, 22, 57, 209, 56, 31, 20, 20, 229, 105, 89, 38, 226, 230, 110, 49, 208, 70, 178, 10, 75, 21, 225, 62]), (bytes [89, 6, 118, 169, 105, 54, 5, 121, 26, 253, 91, 160, 13, 78, 211, 28, 177, 107, 187, 177, 10, 185, 35, 168, 191, 215, 99, 41, 155, 74, 182, 15]), (bytes [16, 1, 45, 207, 125, 115, 77, 40, 96, 249, 191, 96, 68, 155, 161, 144, 89, 205, 15, 173, 177, 139, 3, 87, 248, 132, 221, 254, 91, 235, 118, 133]), (bytes [2, 197, 213, 149, 21, 90, 236, 108, 141, 146, 26, 38, 0, 78, 135, 95, 223, 228, 221, 179, 125, 245, 167, 198, 49, 196, 48, 128, 192, 39, 124, 49]), (bytes [130, 134, 127, 131, 40, 47, 149, 206, 210, 112, 225, 17, 66, 25, 14, 78, 65, 235, 99, 73, 206, 90, 67, 148, 19, 78, 146, 25, 197, 149, 108, 61]), (bytes [8, 234, 67, 158, 76, 76, 170, 16, 58, 161, 138, 98, 35, 61, 115, 114, 104, 189, 45, 62, 96, 35, 11, 160, 56, 73, 223, 212, 106, 84, 224, 145]), (bytes [0, 189, 116, 3, 67, 124, 251, 249, 47, 128, 49, 73, 210, 47, 86, 252, 162, 78, 171, 9, 96, 183, 112, 195, 81, 120, 202, 223, 242, 24, 76, 51]), (bytes [81, 144, 1, 221, 155, 166, 187, 155, 181, 172, 254, 158, 176, 149, 110, 161, 164, 146, 156, 197, 231, 227, 176, 108, 72, 168, 128, 97, 162, 214, 166, 78]), (bytes [238, 147, 134, 181, 8, 29, 128, 200, 221, 198, 65, 181, 234, 22, 117, 159, 112, 0, 90, 214, 190, 69, 86, 72, 209, 196, 234, 23, 145, 109, 49, 190]), (bytes [150, 94, 21, 115, 92, 3, 250, 46, 250, 39, 23, 156, 66, 177, 198, 103, 242, 34, 109, 175, 253, 18, 181, 44, 23, 6, 9, 9, 119, 235, 11, 108]), (bytes [135, 215, 141, 47, 156, 11, 54, 54, 3, 72, 179, 247, 223, 155, 104, 7, 155, 222, 232, 159, 97, 172, 115, 97, 167, 121, 212, 57, 156, 44, 117, 203]), (bytes [84, 95, 115, 25, 213, 106, 24, 56, 216, 206, 94, 157, 100, 187, 198, 197, 93, 1, 173, 134, 90, 112, 47, 80, 254, 7, 54, 249, 32, 132, 243, 167]), (bytes [130, 198, 251, 47, 44, 43, 143, 92, 82, 195, 92, 157, 42, 215, 42, 26, 5, 251, 108, 34, 34, 0, 80, 113, 213, 113, 25, 247, 190, 124, 74, 52]), (bytes [234, 182, 234, 160, 23, 192, 246, 199, 173, 187, 203, 106, 254, 25, 134, 196, 2, 40, 181, 117, 170, 220, 56, 86, 63, 246, 0, 182, 78, 16, 61, 77]), (bytes [40, 254, 204, 213, 6, 140, 117, 235, 134, 79, 86, 81, 169, 63, 60, 118, 8, 156, 87, 198, 194, 60, 29, 160, 125, 250, 15, 187, 147, 220, 29, 92]), (bytes [18, 187, 180, 226, 104, 66, 42, 243, 22, 156, 53, 240, 151, 142, 203, 83, 91, 143, 153, 183, 211, 14, 178, 15, 249, 35, 88, 211, 226, 167, 221, 238]), (bytes [164, 40, 127, 229, 211, 147, 121, 221, 253, 56, 242, 238, 25, 160, 231, 5, 98, 88, 35, 198, 216, 51, 242, 34, 196, 132, 1, 62, 202, 49, 246, 41]), (bytes [122, 105, 77, 66, 174, 33, 37, 82, 171, 117, 60, 146, 152, 71, 176, 9, 4, 214, 95, 111, 117, 16, 77, 11, 22, 12, 202, 53, 36, 93, 76, 79]), (bytes [190, 26, 99, 184, 175, 199, 251, 124, 134, 183, 220, 35, 196, 195, 152, 135, 36, 169, 87, 198, 14, 22, 245, 143, 20, 239, 221, 18, 139, 77, 165, 236]), (bytes [80, 33, 41, 82, 68, 242, 18, 200, 209, 172, 125, 228, 155, 229, 192, 181, 222, 62, 254, 113, 197, 197, 209, 167, 162, 245, 86, 19, 189, 248, 96, 43]), (bytes [90, 10, 190, 250, 226, 23, 47, 210, 182, 164, 148, 175, 37, 226, 99, 192, 247, 166, 149, 66, 95, 29, 230, 232, 50, 99, 224, 203, 78, 177, 221, 250])], familyDigest := (bytes [60, 226, 26, 9, 218, 106, 1, 219, 145, 76, 252, 6, 9, 158, 230, 215, 33, 119, 133, 248, 125, 83, 74, 254, 42, 99, 109, 35, 207, 217, 240, 185]), firstRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [60, 226, 26, 9, 218, 106, 1, 219, 145, 76, 252, 6, 9, 158, 230, 215, 33, 119, 133, 248, 125, 83, 74, 254, 42, 99, 109, 35, 207, 217, 240, 185]), layoutVersion := 1, digest := (bytes [131, 223, 208, 63, 140, 78, 62, 114, 188, 153, 94, 55, 121, 186, 251, 10, 174, 8, 144, 40, 101, 129, 149, 23, 39, 106, 59, 2, 139, 213, 27, 184]) }, logicalIndex := 0, digest := (bytes [102, 193, 167, 113, 19, 197, 238, 244, 130, 208, 64, 28, 70, 92, 155, 50, 117, 135, 113, 248, 136, 248, 151, 3, 160, 8, 204, 52, 13, 32, 213, 27]) }, valueDigest := (bytes [48, 9, 158, 59, 120, 45, 200, 155, 8, 144, 252, 183, 179, 168, 71, 138, 10, 136, 117, 72, 217, 133, 28, 26, 240, 134, 159, 61, 227, 8, 46, 227]), digest := (bytes [157, 29, 105, 164, 228, 100, 34, 43, 226, 130, 195, 108, 5, 73, 10, 134, 63, 113, 148, 49, 24, 192, 159, 83, 170, 86, 173, 32, 237, 192, 45, 56]) }), lastRow := (some { id := { object := { familyTag := 0, commitmentDigest := (bytes [60, 226, 26, 9, 218, 106, 1, 219, 145, 76, 252, 6, 9, 158, 230, 215, 33, 119, 133, 248, 125, 83, 74, 254, 42, 99, 109, 35, 207, 217, 240, 185]), layoutVersion := 1, digest := (bytes [131, 223, 208, 63, 140, 78, 62, 114, 188, 153, 94, 55, 121, 186, 251, 10, 174, 8, 144, 40, 101, 129, 149, 23, 39, 106, 59, 2, 139, 213, 27, 184]) }, logicalIndex := 3, digest := (bytes [42, 14, 11, 181, 92, 135, 182, 1, 141, 107, 200, 170, 222, 89, 64, 23, 196, 173, 115, 96, 143, 146, 210, 88, 108, 166, 105, 221, 234, 228, 143, 165]) }, valueDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [124, 166, 215, 100, 149, 36, 226, 108, 212, 188, 194, 29, 21, 167, 128, 220, 35, 18, 192, 205, 143, 231, 17, 59, 34, 46, 111, 237, 195, 188, 201, 110]) }), digest := (bytes [221, 121, 206, 183, 151, 219, 178, 140, 208, 65, 59, 55, 61, 251, 94, 139, 124, 108, 51, 165, 202, 100, 78, 163, 69, 159, 201, 110, 122, 253, 116, 183]) }
  , rootLaneCommitment := { timeLen := 4, commitments := { commitmentCount := 38, digest := (bytes [192, 237, 17, 53, 235, 29, 69, 55, 72, 94, 126, 40, 158, 253, 226, 47, 115, 226, 118, 182, 238, 41, 184, 33, 102, 49, 153, 185, 96, 71, 8, 3]) }, firstSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [192, 237, 17, 53, 235, 29, 69, 55, 72, 94, 126, 40, 158, 253, 226, 47, 115, 226, 118, 182, 238, 41, 184, 33, 102, 49, 153, 185, 96, 71, 8, 3]), layoutVersion := 3, digest := (bytes [201, 236, 21, 58, 166, 238, 253, 205, 43, 109, 28, 246, 241, 38, 130, 177, 148, 193, 63, 77, 7, 120, 159, 109, 253, 43, 61, 69, 115, 94, 174, 88]) }, logicalIndex := 0, digest := (bytes [176, 163, 215, 61, 193, 203, 148, 52, 42, 158, 76, 174, 148, 4, 72, 111, 177, 60, 17, 171, 220, 102, 81, 247, 70, 125, 58, 43, 236, 26, 94, 45]) }, valueDigest := (bytes [48, 9, 158, 59, 120, 45, 200, 155, 8, 144, 252, 183, 179, 168, 71, 138, 10, 136, 117, 72, 217, 133, 28, 26, 240, 134, 159, 61, 227, 8, 46, 227]), digest := (bytes [234, 196, 19, 209, 186, 228, 212, 26, 38, 142, 39, 225, 81, 151, 86, 95, 113, 78, 96, 219, 206, 214, 155, 189, 52, 238, 232, 200, 40, 66, 250, 181]) }), lastSelectedRow := (some { id := { object := { familyTag := 10, commitmentDigest := (bytes [192, 237, 17, 53, 235, 29, 69, 55, 72, 94, 126, 40, 158, 253, 226, 47, 115, 226, 118, 182, 238, 41, 184, 33, 102, 49, 153, 185, 96, 71, 8, 3]), layoutVersion := 3, digest := (bytes [201, 236, 21, 58, 166, 238, 253, 205, 43, 109, 28, 246, 241, 38, 130, 177, 148, 193, 63, 77, 7, 120, 159, 109, 253, 43, 61, 69, 115, 94, 174, 88]) }, logicalIndex := 3, digest := (bytes [236, 197, 73, 220, 3, 71, 76, 31, 216, 219, 236, 53, 55, 174, 245, 177, 142, 213, 29, 54, 114, 245, 162, 1, 207, 96, 239, 222, 68, 233, 246, 139]) }, valueDigest := (bytes [154, 1, 96, 224, 15, 221, 97, 141, 119, 115, 174, 5, 122, 170, 158, 243, 169, 158, 244, 85, 108, 241, 140, 114, 54, 233, 139, 12, 70, 96, 193, 61]), digest := (bytes [183, 180, 41, 104, 220, 26, 126, 24, 172, 193, 152, 11, 61, 109, 89, 163, 114, 254, 104, 154, 139, 107, 198, 57, 21, 41, 181, 174, 163, 37, 161, 52]) }), digest := (bytes [141, 143, 90, 112, 155, 41, 142, 170, 186, 118, 48, 253, 234, 233, 236, 85, 63, 77, 89, 42, 7, 3, 3, 83, 178, 89, 118, 201, 61, 171, 222, 38]) }
  , mainLane := { binding := { rootLaneColumnsDigest := (bytes [221, 121, 206, 183, 151, 219, 178, 140, 208, 65, 59, 55, 61, 251, 94, 139, 124, 108, 51, 165, 202, 100, 78, 163, 69, 159, 201, 110, 122, 253, 116, 183]), rootLaneCommitmentDigest := (bytes [141, 143, 90, 112, 155, 41, 142, 170, 186, 118, 48, 253, 234, 233, 236, 85, 63, 77, 89, 42, 7, 3, 3, 83, 178, 89, 118, 201, 61, 171, 222, 38]), foldSchedule := Nightstream.FoldSchedule.wholeTrace, chunkCount := 1, publicStepCount := 4, digest := (bytes [31, 115, 81, 186, 95, 69, 142, 3, 165, 129, 219, 15, 136, 124, 218, 48, 84, 173, 203, 2, 196, 241, 239, 30, 35, 37, 239, 33, 221, 205, 34, 226]) }, statementDigest := (bytes [215, 58, 13, 112, 249, 122, 159, 176, 47, 114, 90, 228, 190, 64, 141, 159, 65, 189, 236, 253, 227, 128, 85, 167, 170, 176, 162, 73, 61, 197, 121, 184]), proofDigest := (bytes [232, 129, 203, 10, 148, 72, 221, 136, 48, 38, 161, 187, 138, 65, 189, 148, 13, 231, 220, 85, 13, 238, 35, 26, 255, 49, 125, 206, 63, 155, 126, 21]), digest := (bytes [135, 8, 111, 37, 24, 70, 42, 18, 173, 6, 44, 252, 136, 179, 24, 52, 60, 161, 238, 214, 232, 27, 40, 127, 3, 170, 34, 222, 185, 123, 205, 117]) }
  , digest := (bytes [90, 94, 215, 127, 211, 168, 177, 202, 163, 46, 19, 214, 97, 31, 199, 145, 189, 186, 220, 159, 233, 9, 221, 200, 10, 133, 233, 41, 240, 147, 15, 5])
}
    , transcript := {
  appLabel := (bytes [110, 101, 111, 46, 102, 111, 108, 100, 46, 110, 101, 120, 116, 47, 114, 118, 54, 52, 105, 109, 47, 112, 97, 114, 105, 116, 121, 95, 107, 101, 114, 110, 101, 108, 95, 118, 49])
  , events := [{
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 116, 114, 97, 110, 115, 99, 114, 105, 112, 116, 95, 115, 101, 101, 100])
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 99, 111, 110, 116, 114, 111, 108, 45, 102, 108, 111, 119, 45, 98, 108, 116, 117, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [27634538711377453, 54383638574188, 1823709644592138771, 15695669540104460710, 8188744055654938720, 6008164579518882152, 10584698648648697023, 6532369056394176230], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [99, 111, 110, 116, 114, 111, 108, 95, 102, 108, 111, 119, 95, 98, 108, 116, 117, 95, 116, 97, 107, 101, 110, 95, 115, 107, 105, 112, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [27634538711377453, 54383638574188, 1823709644592138771, 15695669540104460710, 8188744055654938720, 6008164579518882152, 10584698648648697023, 6532369056394176230], absorbed := 2 }
  , cursorAfter := { stateWords := [119212746171743, 12208028352350156733, 13116747255023234155, 14361117635213581249, 10512020492052434381, 12419906133025396461, 15979211480460189741, 1777931489941413951], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [1048723, 2097427, 2155619, 115, 115]
  , cursorBefore := { stateWords := [119212746171743, 12208028352350156733, 13116747255023234155, 14361117635213581249, 10512020492052434381, 12419906133025396461, 15979211480460189741, 1777931489941413951], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 16397939035672565642, 11641441053675113354, 16521885663412804258, 3932218136266550266, 5914036218258353172, 16396554047951467107, 194808442544638140], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [0, 16397939035672565642, 11641441053675113354, 16521885663412804258, 3932218136266550266, 5914036218258353172, 16396554047951467107, 194808442544638140], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 0, 0, 881487480932087110, 12013070208049965127, 13175601915555830455, 15818305995734650527, 17566464973142032050], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [0, 0, 0, 881487480932087110, 12013070208049965127, 13175601915555830455, 15818305995734650527, 17566464973142032050], absorbed := 3 }
  , cursorAfter := { stateWords := [0, 5659295860271643948, 17196621751330026985, 11816108413138352063, 7731328996701478098, 2208618711023935331, 5184172702489234712, 4012119732739570676], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [129, 249, 195, 4, 194, 62, 5, 111, 3, 163, 217, 146, 174, 130, 122, 238, 234, 192, 21, 127, 252, 112, 84, 85, 106, 53, 39, 158, 101, 145, 151, 55])
  , u64s := []
  , cursorBefore := { stateWords := [0, 5659295860271643948, 17196621751330026985, 11816108413138352063, 7731328996701478098, 2208618711023935331, 5184172702489234712, 4012119732739570676], absorbed := 1 }
  , cursorAfter := { stateWords := [4092868761203551035, 5735683149795635746, 16451237304497144096, 15660729885261835049, 4993037928439025236, 4058496521599560720, 1830960361648420361, 3978819030440664472], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [4092868761203551035, 5735683149795635746, 16451237304497144096, 15660729885261835049, 4993037928439025236, 4058496521599560720, 1830960361648420361, 3978819030440664472], absorbed := 0 }
  , cursorAfter := { stateWords := [12597393124285258733, 4007867179351945362, 4850091778944820385, 17991037833033007994, 476015916384254308, 14419281049321754399, 7561257148764249156, 1132223698927151629], absorbed := 0 }
  , challengeOutput := (some 12597393124285258733)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [79, 54, 35, 89, 181, 60, 120, 62, 23, 216, 151, 8, 213, 60, 71, 0, 66, 90, 147, 125, 53, 147, 210, 191, 92, 59, 24, 230, 4, 58, 45, 9])
  , u64s := []
  , cursorBefore := { stateWords := [12597393124285258733, 4007867179351945362, 4850091778944820385, 17991037833033007994, 476015916384254308, 14419281049321754399, 7561257148764249156, 1132223698927151629], absorbed := 0 }
  , cursorAfter := { stateWords := [15056245593604167, 64765887881663123, 153958916, 9997542546738313031, 16853801998999087846, 13982512411198372988, 8554071259391645168, 13108539371935154626], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [15056245593604167, 64765887881663123, 153958916, 9997542546738313031, 16853801998999087846, 13982512411198372988, 8554071259391645168, 13108539371935154626], absorbed := 3 }
  , cursorAfter := { stateWords := [8403032955572713120, 10194722622930340936, 17038147923175873622, 6655223517539784936, 13617601525376964849, 2293126206090744488, 4903383980242401457, 18359890104668421032], absorbed := 0 }
  , challengeOutput := (some 8403032955572713120)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [8403032955572713120, 10194722622930340936, 17038147923175873622, 6655223517539784936, 13617601525376964849, 2293126206090744488, 4903383980242401457, 18359890104668421032], absorbed := 0 }
  , cursorAfter := { stateWords := [6883570667930004418, 4347745747494188624, 16976776541035948748, 5246595802583663249, 222760462322422117, 9882636753605636144, 16541711643128801052, 18376981885606520272], absorbed := 0 }
  , challengeOutput := (some 6883570667930004418)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [59, 77, 145, 209, 31, 130, 112, 69, 30, 34, 112, 204, 73, 72, 47, 51, 247, 164, 118, 200, 178, 22, 87, 88, 74, 116, 115, 132, 88, 127, 97, 100])
  , u64s := []
  , cursorBefore := { stateWords := [6883570667930004418, 4347745747494188624, 16976776541035948748, 5246595802583663249, 222760462322422117, 9882636753605636144, 16541711643128801052, 18376981885606520272], absorbed := 0 }
  , cursorAfter := { stateWords := [50322957753856815, 37281640226510614, 1684111192, 7216131882496189275, 17059082051772819397, 392206444769693843, 6967327010175071487, 2617740938094769044], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [50322957753856815, 37281640226510614, 1684111192, 7216131882496189275, 17059082051772819397, 392206444769693843, 6967327010175071487, 2617740938094769044], absorbed := 3 }
  , cursorAfter := { stateWords := [5434653513256456592, 2019440646099219393, 14502873697191680645, 18414208927306151731, 16466704025794420414, 6222860899880621933, 467525259224987042, 2024518562970414523], absorbed := 0 }
  , challengeOutput := (some 5434653513256456592)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [198, 81, 7, 250, 152, 135, 65, 159, 231, 42, 117, 161, 26, 121, 63, 197, 123, 212, 231, 113, 35, 37, 159, 177, 226, 104, 247, 68, 136, 30, 16, 163])
  , u64s := []
  , cursorBefore := { stateWords := [5434653513256456592, 2019440646099219393, 14502873697191680645, 18414208927306151731, 16466704025794420414, 6222860899880621933, 467525259224987042, 2024518562970414523], absorbed := 0 }
  , cursorAfter := { stateWords := [9976864701138239, 19412328268275493, 2735742600, 8224034729581685552, 14602704957001709965, 14970224487669671009, 12214536921972360220, 8804407349145409156], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [141, 81, 95, 195, 231, 84, 171, 240, 150, 119, 148, 108, 81, 62, 93, 105, 24, 74, 13, 118, 229, 236, 2, 205, 125, 30, 81, 145, 166, 192, 80, 84])
  , u64s := []
  , cursorBefore := { stateWords := [9976864701138239, 19412328268275493, 2735742600, 8224034729581685552, 14602704957001709965, 14970224487669671009, 12214536921972360220, 8804407349145409156], absorbed := 3 }
  , cursorAfter := { stateWords := [64587569116506461, 40903063024501484, 1414578342, 14196438228949969798, 18403734006346840136, 13405937549382790609, 7173023050622960964, 10786742084945241388], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [145, 232, 119, 42, 209, 144, 217, 53, 205, 241, 241, 70, 26, 199, 99, 90, 150, 109, 80, 126, 52, 204, 98, 226, 231, 236, 152, 221, 67, 149, 32, 60])
  , u64s := []
  , cursorBefore := { stateWords := [64587569116506461, 40903063024501484, 1414578342, 14196438228949969798, 18403734006346840136, 13405937549382790609, 7173023050622960964, 10786742084945241388], absorbed := 3 }
  , cursorAfter := { stateWords := [14775582690007651, 62374113123132108, 1008768323, 8094561612940107350, 5686126895398755498, 17866238643063324752, 1175931973497704862, 4453093798857192440], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [14775582690007651, 62374113123132108, 1008768323, 8094561612940107350, 5686126895398755498, 17866238643063324752, 1175931973497704862, 4453093798857192440], absorbed := 3 }
  , cursorAfter := { stateWords := [6072416836816506878, 3629861325522078768, 10966163059651396786, 11527671172202609175, 11198492021099575808, 9824312880916574066, 853475271184614411, 5712062166666301321], absorbed := 0 }
  , challengeOutput := (some 6072416836816506878)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [6072416836816506878, 3629861325522078768, 10966163059651396786, 11527671172202609175, 11198492021099575808, 9824312880916574066, 853475271184614411, 5712062166666301321], absorbed := 0 }
  , cursorAfter := { stateWords := [10555985995699718432, 18223850609000066347, 2758488876129618957, 12960147545075652446, 7628832371191976516, 2123629962868476640, 5111925167032223623, 6695332481206384055], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [32, 9, 174, 199, 85, 101, 126, 146, 43, 45, 60, 37, 147, 31, 232, 252, 13, 140, 146, 138, 4, 31, 72, 38, 94, 151, 226, 196, 134, 177, 219, 179]))
}]
}
    , stage1 := stage1
    , stage2 := stage2
    , stage3 := stage3
    , rootExecution := rootExecution
    , stepComposition := stepComposition
    , soundnessAccounting := soundnessAccounting
    , kernelOpeningBundle := kernelOpeningBundle
    , digest := (bytes [47, 101, 111, 213, 10, 208, 125, 50, 30, 149, 136, 57, 141, 121, 180, 224, 23, 221, 135, 137, 179, 51, 126, 62, 223, 59, 234, 139, 4, 20, 154, 205])
  }

end Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors.Case_control_flow_bltu_taken_skip_ecall
