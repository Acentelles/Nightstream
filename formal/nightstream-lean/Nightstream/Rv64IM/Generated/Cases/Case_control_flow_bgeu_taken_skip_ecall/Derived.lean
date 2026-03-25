import Nightstream.Rv64IM.Generated.ParityTypes

namespace Nightstream.Rv64IM.Generated.Cases.Case_control_flow_bgeu_taken_skip_ecall

open Nightstream.Rv64IM.Generated

def derivedCase : ParityDerivedCase :=
  {
  manifest := { name := "control_flow_bgeu_taken_skip_ecall", fixtureId := "control_flow_bgeu_taken_skip_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.controlFlow, .nativeAlu] }
  , executionRows := [{
  traceIndex := 0
  , stepIndex := 0
  , sequenceIndex := 0
  , pc := 0
  , nextPc := 4
  , word := 2097299
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
  traceIndex := 1
  , stepIndex := 1
  , sequenceIndex := 0
  , pc := 4
  , nextPc := 8
  , word := 1048851
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
  traceIndex := 2
  , stepIndex := 2
  , sequenceIndex := 0
  , pc := 8
  , nextPc := 16
  , word := 2159715
  , opcode := .bgeu
  , traceOpcode := (some .bgeu)
  , traceVirtualOpcode := none
  , family := .controlFlow
  , rs1 := 1
  , rs1Value := 2
  , rs2 := 2
  , rs2Value := 1
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
  , stage1 := { rows := [{ traceIndex := 0, stepIndex := 0, sequenceIndex := 0, fetchPc := 0, fetchedWord := 2097299, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 4, aluResult := 2, effectiveAddr := none, writesRd := true, rd := 1, rdAfter := 2, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 1, stepIndex := 1, sequenceIndex := 0, fetchPc := 4, fetchedWord := 1048851, opcode := .addi, traceOpcode := (some .addi), traceVirtualOpcode := none, family := .nativeAlu, nextPc := 8, aluResult := 1, effectiveAddr := none, writesRd := true, rd := 2, rdAfter := 1, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := false }, { traceIndex := 2, stepIndex := 2, sequenceIndex := 0, fetchPc := 8, fetchedWord := 2159715, opcode := .bgeu, traceOpcode := (some .bgeu), traceVirtualOpcode := none, family := .controlFlow, nextPc := 16, aluResult := 1, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }, { traceIndex := 3, stepIndex := 3, sequenceIndex := 0, fetchPc := 16, fetchedWord := 115, opcode := .ecall, traceOpcode := (some .ecall), traceVirtualOpcode := none, family := .controlFlow, nextPc := 20, aluResult := 0, effectiveAddr := none, writesRd := false, rd := 0, rdAfter := 0, isFirstInSequence := true, virtualSequenceRemaining := none, isEffectRow := true, isCommitRow := true, isReal := true, preservesX0 := true }] }
  , stage2 := {
  registerReads := [{ traceIndex := 0, stepIndex := 0, role := .rs1, reg := 0, value := 0 }, { traceIndex := 1, stepIndex := 1, role := .rs1, reg := 0, value := 0 }, { traceIndex := 2, stepIndex := 2, role := .rs1, reg := 1, value := 2 }, { traceIndex := 2, stepIndex := 2, role := .rs2, reg := 2, value := 1 }]
  , registerWrites := [{ traceIndex := 0, stepIndex := 0, reg := 1, previous := 0, next := 2 }, { traceIndex := 1, stepIndex := 1, reg := 2, previous := 0, next := 1 }]
  , ramEvents := []
  , twistLinks := [{ traceIndex := 0, stepIndex := 0, family := .nativeAlu, routedWriteValue := (some 2), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 1, stepIndex := 1, family := .nativeAlu, routedWriteValue := (some 1), routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 2, stepIndex := 2, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }, { traceIndex := 3, stepIndex := 3, family := .controlFlow, routedWriteValue := none, routedMemoryBefore := none, routedMemoryAfter := none }]
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
  , message := (bytes [114, 118, 54, 52, 105, 109, 45, 99, 111, 110, 116, 114, 111, 108, 45, 102, 108, 111, 119, 45, 98, 103, 101, 117, 45, 118, 49])
  , u64s := []
  , cursorBefore := { stateWords := [26873663679783280, 26859305687999851, 12662, 10603402672439567961, 8106184020323377289, 7999721045538746544, 17131201872370716762, 2311972242268433741], absorbed := 3 }
  , cursorAfter := { stateWords := [27634538711377453, 54383638570343, 1823709644592138771, 15695669540104460710, 8188744055654938720, 6008164579518882152, 10584698648648697023, 6532369056394176230], absorbed := 2 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 99, 97, 115, 101, 95, 110, 97, 109, 101])
  , message := (bytes [99, 111, 110, 116, 114, 111, 108, 95, 102, 108, 111, 119, 95, 98, 103, 101, 117, 95, 116, 97, 107, 101, 110, 95, 115, 107, 105, 112, 95, 101, 99, 97, 108, 108])
  , u64s := []
  , cursorBefore := { stateWords := [27634538711377453, 54383638570343, 1823709644592138771, 15695669540104460710, 8188744055654938720, 6008164579518882152, 10584698648648697023, 6532369056394176230], absorbed := 2 }
  , cursorAfter := { stateWords := [119212746171743, 4115465076320722641, 10265791983627518635, 543941533280415099, 6470597071131417095, 3459529626164976671, 6538594751029149855, 9202376365345449052], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 112, 114, 111, 103, 114, 97, 109, 95, 119, 111, 114, 100, 115])
  , message := (bytes [])
  , u64s := [2097299, 1048851, 2159715, 115, 115]
  , cursorBefore := { stateWords := [119212746171743, 4115465076320722641, 10265791983627518635, 543941533280415099, 6470597071131417095, 3459529626164976671, 6538594751029149855, 9202376365345449052], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 7631244085689216595, 8440193799965894114, 14388964891207711840, 2056782885545757663, 1529144530094235108, 2253812106308094552, 13023645497027124897], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 114, 101, 103, 115])
  , message := (bytes [])
  , u64s := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , cursorBefore := { stateWords := [0, 7631244085689216595, 8440193799965894114, 14388964891207711840, 2056782885545757663, 1529144530094235108, 2253812106308094552, 13023645497027124897], absorbed := 1 }
  , cursorAfter := { stateWords := [0, 0, 0, 8054943088534077807, 13846332591903095255, 12463867618150028911, 14586359305607902986, 11717871853396826665], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendU64s
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 105, 110, 105, 116, 105, 97, 108, 95, 109, 101, 109, 111, 114, 121])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [0, 0, 0, 8054943088534077807, 13846332591903095255, 12463867618150028911, 14586359305607902986, 11717871853396826665], absorbed := 3 }
  , cursorAfter := { stateWords := [0, 230873779471710420, 6964603481912124136, 11370762658102756114, 607388998938196074, 10350170456409138927, 12953860084092507636, 1082719992604845587], absorbed := 1 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 114, 111, 111, 116, 48, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [136, 28, 209, 27, 97, 186, 22, 192, 232, 198, 243, 170, 46, 6, 247, 29, 121, 48, 129, 111, 147, 109, 255, 41, 26, 208, 224, 144, 114, 105, 103, 152])
  , u64s := []
  , cursorBefore := { stateWords := [0, 230873779471710420, 6964603481912124136, 11370762658102756114, 607388998938196074, 10350170456409138927, 12953860084092507636, 1082719992604845587], absorbed := 1 }
  , cursorAfter := { stateWords := [2491980700698988972, 14068472359300423438, 17519047032954281148, 16448807135216549510, 14756161607341614720, 14989551616862978022, 13957537584803479485, 2382084973428616934], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 49, 47, 114, 111, 119, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [2491980700698988972, 14068472359300423438, 17519047032954281148, 16448807135216549510, 14756161607341614720, 14989551616862978022, 13957537584803479485, 2382084973428616934], absorbed := 0 }
  , cursorAfter := { stateWords := [2302652608239151864, 7130242139247192989, 1536477261163950027, 6314366652416881261, 9774956454389601012, 1241629233521582540, 11522590400807307548, 5735015773736746616], absorbed := 0 }
  , challengeOutput := (some 2302652608239151864)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 49, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [38, 1, 111, 25, 28, 52, 17, 93, 213, 60, 148, 249, 31, 250, 244, 14, 78, 84, 6, 40, 66, 110, 230, 118, 128, 211, 149, 94, 100, 248, 222, 19])
  , u64s := []
  , cursorBefore := { stateWords := [2302652608239151864, 7130242139247192989, 1536477261163950027, 6314366652416881261, 9774956454389601012, 1241629233521582540, 11522590400807307548, 5735015773736746616], absorbed := 0 }
  , cursorAfter := { stateWords := [18621356112219892, 26623383436715630, 333379684, 10485438589329696725, 14876902141821514848, 15276347457467243244, 16519611062992214112, 7256149985783836630], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 101, 103, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [18621356112219892, 26623383436715630, 333379684, 10485438589329696725, 14876902141821514848, 15276347457467243244, 16519611062992214112, 7256149985783836630], absorbed := 3 }
  , cursorAfter := { stateWords := [10806869914316609246, 15806731556035115430, 12389253343389949275, 16729553705511047762, 6582825377533277016, 16734122218319710901, 8005843161548042819, 3880364712725972742], absorbed := 0 }
  , challengeOutput := (some 10806869914316609246)
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 50, 47, 114, 97, 109, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [10806869914316609246, 15806731556035115430, 12389253343389949275, 16729553705511047762, 6582825377533277016, 16734122218319710901, 8005843161548042819, 3880364712725972742], absorbed := 0 }
  , cursorAfter := { stateWords := [1959622797672027888, 17651696247336291884, 11720460566859635632, 6919812372420016008, 5499717622967941681, 2853279359317452701, 14759054242794873370, 6243048439933786052], absorbed := 0 }
  , challengeOutput := (some 1959622797672027888)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 50, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [166, 190, 44, 132, 128, 151, 204, 56, 245, 149, 250, 100, 68, 251, 133, 216, 118, 141, 212, 118, 201, 209, 68, 33, 74, 28, 127, 220, 47, 90, 112, 230])
  , u64s := []
  , cursorBefore := { stateWords := [1959622797672027888, 17651696247336291884, 11720460566859635632, 6919812372420016008, 5499717622967941681, 2853279359317452701, 14759054242794873370, 6243048439933786052], absorbed := 0 }
  , cursorAfter := { stateWords := [56707125597362309, 62064254355850449, 3866122799, 12929877950451745014, 1756846508717143854, 9609595341734835927, 17484194971466081028, 13465387111089516922], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 115, 116, 97, 103, 101, 51, 47, 99, 111, 110, 116, 105, 110, 117, 105, 116, 121, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [56707125597362309, 62064254355850449, 3866122799, 12929877950451745014, 1756846508717143854, 9609595341734835927, 17484194971466081028, 13465387111089516922], absorbed := 3 }
  , cursorAfter := { stateWords := [2657263387322609258, 17421979329178809139, 9787209125109745185, 7491875297347501185, 1989378684025500775, 9005104167904948773, 10165090286127097813, 11761285918797788840], absorbed := 0 }
  , challengeOutput := (some 2657263387322609258)
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 115, 116, 97, 103, 101, 51, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [198, 81, 7, 250, 152, 135, 65, 159, 231, 42, 117, 161, 26, 121, 63, 197, 123, 212, 231, 113, 35, 37, 159, 177, 226, 104, 247, 68, 136, 30, 16, 163])
  , u64s := []
  , cursorBefore := { stateWords := [2657263387322609258, 17421979329178809139, 9787209125109745185, 7491875297347501185, 1989378684025500775, 9005104167904948773, 10165090286127097813, 11761285918797788840], absorbed := 0 }
  , cursorAfter := { stateWords := [9976864701138239, 19412328268275493, 2735742600, 4589826518242105380, 16312361777310826010, 14330958536230969493, 7763975302023814306, 2351550924013014552], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 101, 120, 101, 99, 117, 116, 105, 111, 110, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [216, 222, 179, 38, 20, 54, 249, 142, 177, 39, 183, 229, 29, 226, 13, 225, 74, 252, 72, 165, 4, 145, 80, 197, 205, 158, 197, 254, 151, 248, 6, 131])
  , u64s := []
  , cursorBefore := { stateWords := [9976864701138239, 19412328268275493, 2735742600, 4589826518242105380, 16312361777310826010, 14330958536230969493, 7763975302023814306, 2351550924013014552], absorbed := 3 }
  , cursorAfter := { stateWords := [1307632795836685, 71711929932271761, 2198272151, 5006567380650827533, 12695412723250713982, 2202973391026883564, 4455388109040917094, 12391254929522659973], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .appendMessage
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 115, 116, 97, 116, 101, 95, 100, 105, 103, 101, 115, 116])
  , message := (bytes [207, 244, 140, 140, 253, 220, 153, 85, 210, 72, 78, 149, 45, 76, 101, 175, 63, 107, 102, 240, 184, 237, 98, 242, 203, 60, 16, 255, 244, 31, 162, 249])
  , u64s := []
  , cursorBefore := { stateWords := [1307632795836685, 71711929932271761, 2198272151, 5006567380650827533, 12695412723250713982, 2202973391026883564, 4455388109040917094, 12391254929522659973], absorbed := 3 }
  , cursorAfter := { stateWords := [52055718391426917, 71793972366959341, 4188151796, 14720217363501469615, 5839986288202124512, 15842499204513090931, 4209314985581236974, 3003143283336044558], absorbed := 3 }
  , challengeOutput := none
  , digestOutput := none
}, {
  kind := .challengeField
  , label := (bytes [114, 118, 54, 52, 105, 109, 47, 107, 101, 114, 110, 101, 108, 47, 102, 105, 110, 97, 108, 95, 109, 105, 120])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [52055718391426917, 71793972366959341, 4188151796, 14720217363501469615, 5839986288202124512, 15842499204513090931, 4209314985581236974, 3003143283336044558], absorbed := 3 }
  , cursorAfter := { stateWords := [1727357311060009140, 392412233049723249, 5376223040815207962, 5545438250291612210, 18191948353196698425, 2930334182322678240, 5188326213335546338, 3654734493943723780], absorbed := 0 }
  , challengeOutput := (some 1727357311060009140)
  , digestOutput := none
}, {
  kind := .digest32
  , label := (bytes [])
  , message := (bytes [])
  , u64s := []
  , cursorBefore := { stateWords := [1727357311060009140, 392412233049723249, 5376223040815207962, 5545438250291612210, 18191948353196698425, 2930334182322678240, 5188326213335546338, 3654734493943723780], absorbed := 0 }
  , cursorAfter := { stateWords := [59161777613820636, 1016857791896753430, 17948570178771726550, 176994180626937866, 2116920300628803648, 7782557740171667341, 9568767961969140595, 10469167577974212368], absorbed := 0 }
  , challengeOutput := none
  , digestOutput := (some (bytes [220, 210, 243, 194, 82, 47, 210, 0, 22, 21, 24, 49, 198, 154, 28, 14, 214, 176, 219, 99, 123, 33, 22, 249, 10, 120, 148, 255, 68, 207, 116, 2]))
}]
}
  , kernel := {
  root0Digest := (bytes [136, 28, 209, 27, 97, 186, 22, 192, 232, 198, 243, 170, 46, 6, 247, 29, 121, 48, 129, 111, 147, 109, 255, 41, 26, 208, 224, 144, 114, 105, 103, 152])
  , stage1Digest := (bytes [38, 1, 111, 25, 28, 52, 17, 93, 213, 60, 148, 249, 31, 250, 244, 14, 78, 84, 6, 40, 66, 110, 230, 118, 128, 211, 149, 94, 100, 248, 222, 19])
  , stage2Digest := (bytes [166, 190, 44, 132, 128, 151, 204, 56, 245, 149, 250, 100, 68, 251, 133, 216, 118, 141, 212, 118, 201, 209, 68, 33, 74, 28, 127, 220, 47, 90, 112, 230])
  , stage3Digest := (bytes [198, 81, 7, 250, 152, 135, 65, 159, 231, 42, 117, 161, 26, 121, 63, 197, 123, 212, 231, 113, 35, 37, 159, 177, 226, 104, 247, 68, 136, 30, 16, 163])
  , executionDigest := (bytes [216, 222, 179, 38, 20, 54, 249, 142, 177, 39, 183, 229, 29, 226, 13, 225, 74, 252, 72, 165, 4, 145, 80, 197, 205, 158, 197, 254, 151, 248, 6, 131])
  , finalStateDigest := (bytes [207, 244, 140, 140, 253, 220, 153, 85, 210, 72, 78, 149, 45, 76, 101, 175, 63, 107, 102, 240, 184, 237, 98, 242, 203, 60, 16, 255, 244, 31, 162, 249])
  , stage1Mix := 2302652608239151864
  , stage2RegMix := 10806869914316609246
  , stage2RamMix := 1959622797672027888
  , stage3ContinuityMix := 2657263387322609258
  , kernelFinalMix := 1727357311060009140
  , transcriptFinalDigest := (bytes [220, 210, 243, 194, 82, 47, 210, 0, 22, 21, 24, 49, 198, 154, 28, 14, 214, 176, 219, 99, 123, 33, 22, 249, 10, 120, 148, 255, 68, 207, 116, 2])
  , finalPc := 20
  , finalRegisters := [0, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , finalMemory := []
  , halted := true
}
}

end Nightstream.Rv64IM.Generated.Cases.Case_control_flow_bgeu_taken_skip_ecall
