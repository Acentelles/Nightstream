import Nightstream.Chip8.Generated.StagedExecutionDigestBundleVectorTypes

set_option maxHeartbeats 1000000

namespace Nightstream.Chip8.Generated

def bundleMetaPub_jump_rows_2_seed_empty : MetaPub :=
  mkMetaPub
    (bytes [22, 187, 141, 224, 143, 145, 228, 95, 167, 196, 150, 146, 235, 86, 210, 231, 134, 120, 172, 42, 241, 169, 214, 101, 225, 25, 226, 124, 217, 129, 182, 151])
    (bytes [103, 158, 229, 36, 250, 1, 192, 124, 83, 166, 95, 21, 49, 91, 188, 147, 0, 30, 7, 172, 129, 103, 92, 126, 32, 62, 61, 115, 125, 236, 147, 13])
    (bytes [189, 190, 90, 108, 63, 185, 30, 242, 162, 217, 143, 247, 132, 0, 34, 111, 172, 112, 205, 125, 140, 160, 158, 162, 6, 66, 139, 153, 1, 228, 176, 63])
    (bytes [252, 53, 88, 100, 157, 168, 101, 100, 185, 63, 46, 173, 104, 81, 83, 78, 185, 171, 182, 33, 93, 65, 230, 74, 33, 76, 252, 38, 19, 164, 225, 32])
    (bytes [44, 203, 177, 233, 106, 15, 195, 147, 113, 218, 228, 82, 205, 30, 97, 138, 25, 43, 31, 200, 120, 254, 247, 191, 10, 64, 160, 212, 128, 63, 112, 154])
    (bytes [129, 236, 85, 122, 97, 54, 165, 185, 227, 219, 243, 227, 32, 97, 53, 94, 188, 103, 97, 19, 54, 202, 157, 205, 53, 144, 186, 216, 192, 191, 111, 179])
    (bytes [232, 177, 158, 18, 238, 178, 93, 209, 175, 28, 144, 3, 211, 116, 89, 118, 107, 23, 117, 66, 49, 127, 178, 232, 237, 172, 18, 213, 100, 196, 177, 220])
    1
    1
    1
    (bytes [36, 192, 145, 8, 246, 175, 123, 140, 9, 93, 61, 101, 155, 245, 148, 191, 146, 8, 169, 246, 169, 250, 68, 18, 197, 240, 131, 147, 57, 140, 244, 163])
    1
    1
    1
    1
    1
    1
    1
    1
    1
    2
    2
    257
    512
    1

def bundleMetaPub_jump_rows_3_seed_nonempty : MetaPub :=
  mkMetaPub
    (bytes [22, 187, 141, 224, 143, 145, 228, 95, 167, 196, 150, 146, 235, 86, 210, 231, 134, 120, 172, 42, 241, 169, 214, 101, 225, 25, 226, 124, 217, 129, 182, 151])
    (bytes [103, 158, 229, 36, 250, 1, 192, 124, 83, 166, 95, 21, 49, 91, 188, 147, 0, 30, 7, 172, 129, 103, 92, 126, 32, 62, 61, 115, 125, 236, 147, 13])
    (bytes [189, 190, 90, 108, 63, 185, 30, 242, 162, 217, 143, 247, 132, 0, 34, 111, 172, 112, 205, 125, 140, 160, 158, 162, 6, 66, 139, 153, 1, 228, 176, 63])
    (bytes [252, 53, 88, 100, 157, 168, 101, 100, 185, 63, 46, 173, 104, 81, 83, 78, 185, 171, 182, 33, 93, 65, 230, 74, 33, 76, 252, 38, 19, 164, 225, 32])
    (bytes [44, 203, 177, 233, 106, 15, 195, 147, 113, 218, 228, 82, 205, 30, 97, 138, 25, 43, 31, 200, 120, 254, 247, 191, 10, 64, 160, 212, 128, 63, 112, 154])
    (bytes [129, 236, 85, 122, 97, 54, 165, 185, 227, 219, 243, 227, 32, 97, 53, 94, 188, 103, 97, 19, 54, 202, 157, 205, 53, 144, 186, 216, 192, 191, 111, 179])
    (bytes [25, 249, 46, 73, 245, 248, 218, 250, 244, 67, 97, 132, 93, 33, 166, 171, 120, 252, 21, 154, 1, 111, 80, 197, 56, 205, 28, 197, 169, 33, 91, 41])
    1
    1
    1
    (bytes [36, 192, 145, 8, 246, 175, 123, 140, 9, 93, 61, 101, 155, 245, 148, 191, 146, 8, 169, 246, 169, 250, 68, 18, 197, 240, 131, 147, 57, 140, 244, 163])
    1
    1
    1
    1
    1
    1
    1
    1
    1
    3
    4
    257
    512
    2

def stagedExecutionDigestBundleVectorCases : List StagedExecutionDigestBundleVectorCase :=
  [
    mkStagedExecutionDigestBundleVectorCase
      "jump_rows_2_seed_empty"
      (mkDigestPublicView
      (mkPublicInputView
      (bytes [18, 0])
      256
      (zeroBytes 16)
      0
      (zeroBytes 4096)
      (bytes []))
      bundleMetaPub_jump_rows_2_seed_empty)
      [(mkFrameSourceView 0 (mkFrameDecodeView .jump 2 0 0 512 4608 256 0 0 false false 0) (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096)) (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096)) ([1, 256, 256, 0, 0, 0, 0, 0, 0, 512, 256, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0])), (mkFrameSourceView 1 (mkFrameDecodeView .jump 2 0 0 512 4608 256 0 0 false false 0) (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096)) (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096)) ([1, 256, 256, 0, 0, 0, 0, 0, 0, 512, 256, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0]))]
      [(mkStage3View
        0
        2
        (pair 2806822068884985329 3971483951204023518)
        (pair 2048699827344869662 9483888510897047926)
        (mkStage3ShiftClaimView
        .lane
        ([pair 4201995758964131243 14196911805183005647])
        ([.pc, .xIdx, .isMemOp])
        ([.shiftPc, .shiftXIdx, .shiftIsMemOp])
        ([pair 12646985800642876987 18045903617238249926, pair 0 0, pair 0 0]))
        (mkStage3ShiftWitnessView
        (pair 12646985800642876987 18045903617238249926)
        (pair 0 0)
        (pair 0 0)
        ([[pair 12646985800642876987 18045903617238249926, pair 17399274806315122258 1202521356529003185, pair 6847227531871169397 17645063165061915531]]))
        (mkStage3CurrentRowView 0 1 256 0 0 0)
        (mkStage3RowClaimView 0 ([false]) ([pair 256 0, pair 256 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 512 0, pair 256 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 1 0, pair 0 0, pair 1 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0]))
        (bytes [126, 31, 96, 184, 149, 69, 13, 137, 58, 7, 51, 209, 110, 41, 33, 0, 75, 42, 60, 115, 31, 232, 192, 69, 152, 250, 24, 155, 121, 169, 229, 198])), (mkStage3View
        1
        2
        (pair 2806822068884985329 3971483951204023518)
        (pair 2048699827344869662 9483888510897047926)
        (mkStage3ShiftClaimView
        .lane
        ([pair 4201995758964131243 14196911805183005647])
        ([.pc, .xIdx, .isMemOp])
        ([.shiftPc, .shiftXIdx, .shiftIsMemOp])
        ([pair 12646985800642876987 18045903617238249926, pair 0 0, pair 0 0]))
        (mkStage3ShiftWitnessView
        (pair 12646985800642876987 18045903617238249926)
        (pair 0 0)
        (pair 0 0)
        ([[pair 12646985800642876987 18045903617238249926, pair 17399274806315122258 1202521356529003185, pair 6847227531871169397 17645063165061915531]]))
        (mkStage3CurrentRowView 1 0 256 0 0 0)
        (mkStage3RowClaimView 1 ([true]) ([pair 256 0, pair 256 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 512 0, pair 256 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 1 0, pair 0 0, pair 1 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0]))
        (bytes [126, 31, 96, 184, 149, 69, 13, 137, 58, 7, 51, 209, 110, 41, 33, 0, 75, 42, 60, 115, 31, 232, 192, 69, 152, 250, 24, 155, 121, 169, 229, 198]))]
      (mkStagedExecutionDigestBundleView
      (mkDigestPublicView
      (mkPublicInputView
      (bytes [18, 0])
      256
      (zeroBytes 16)
      0
      (zeroBytes 4096)
      (bytes []))
      bundleMetaPub_jump_rows_2_seed_empty)
      [(mkStagedExecutionDigestView
      (mkStage1View
        (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096))
        (mkFrameDecodeView .jump 2 0 0 512 4608 256 0 0 false false 0)
        ([1, 256, 256, 0, 0, 0, 0, 0, 0, 512, 256, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0]))
      (mkStage2View
        (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096))
        (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096))
        (mkFrameDecodeView .jump 2 0 0 512 4608 256 0 0 false false 0)
        ([1, 256, 256, 0, 0, 0, 0, 0, 0, 512, 256, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0]))
      (mkStage3View
        0
        2
        (pair 2806822068884985329 3971483951204023518)
        (pair 2048699827344869662 9483888510897047926)
        (mkStage3ShiftClaimView
        .lane
        ([pair 4201995758964131243 14196911805183005647])
        ([.pc, .xIdx, .isMemOp])
        ([.shiftPc, .shiftXIdx, .shiftIsMemOp])
        ([pair 12646985800642876987 18045903617238249926, pair 0 0, pair 0 0]))
        (mkStage3ShiftWitnessView
        (pair 12646985800642876987 18045903617238249926)
        (pair 0 0)
        (pair 0 0)
        ([[pair 12646985800642876987 18045903617238249926, pair 17399274806315122258 1202521356529003185, pair 6847227531871169397 17645063165061915531]]))
        (mkStage3CurrentRowView 0 1 256 0 0 0)
        (mkStage3RowClaimView 0 ([false]) ([pair 256 0, pair 256 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 512 0, pair 256 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 1 0, pair 0 0, pair 1 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0]))
        (bytes [126, 31, 96, 184, 149, 69, 13, 137, 58, 7, 51, 209, 110, 41, 33, 0, 75, 42, 60, 115, 31, 232, 192, 69, 152, 250, 24, 155, 121, 169, 229, 198]))
      (mkExecutionResultView
        0
        (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096))
        (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096))
        (mkFrameDecodeView .jump 2 0 0 512 4608 256 0 0 false false 0))), (mkStagedExecutionDigestView
      (mkStage1View
        (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096))
        (mkFrameDecodeView .jump 2 0 0 512 4608 256 0 0 false false 0)
        ([1, 256, 256, 0, 0, 0, 0, 0, 0, 512, 256, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0]))
      (mkStage2View
        (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096))
        (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096))
        (mkFrameDecodeView .jump 2 0 0 512 4608 256 0 0 false false 0)
        ([1, 256, 256, 0, 0, 0, 0, 0, 0, 512, 256, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0]))
      (mkStage3View
        1
        2
        (pair 2806822068884985329 3971483951204023518)
        (pair 2048699827344869662 9483888510897047926)
        (mkStage3ShiftClaimView
        .lane
        ([pair 4201995758964131243 14196911805183005647])
        ([.pc, .xIdx, .isMemOp])
        ([.shiftPc, .shiftXIdx, .shiftIsMemOp])
        ([pair 12646985800642876987 18045903617238249926, pair 0 0, pair 0 0]))
        (mkStage3ShiftWitnessView
        (pair 12646985800642876987 18045903617238249926)
        (pair 0 0)
        (pair 0 0)
        ([[pair 12646985800642876987 18045903617238249926, pair 17399274806315122258 1202521356529003185, pair 6847227531871169397 17645063165061915531]]))
        (mkStage3CurrentRowView 1 0 256 0 0 0)
        (mkStage3RowClaimView 1 ([true]) ([pair 256 0, pair 256 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 512 0, pair 256 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 1 0, pair 0 0, pair 1 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0]))
        (bytes [126, 31, 96, 184, 149, 69, 13, 137, 58, 7, 51, 209, 110, 41, 33, 0, 75, 42, 60, 115, 31, 232, 192, 69, 152, 250, 24, 155, 121, 169, 229, 198]))
      (mkExecutionResultView
        1
        (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096))
        (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096))
        (mkFrameDecodeView .jump 2 0 0 512 4608 256 0 0 false false 0)))]),
    mkStagedExecutionDigestBundleVectorCase
      "jump_rows_3_seed_nonempty"
      (mkDigestPublicView
      (mkPublicInputView
      (bytes [18, 0])
      256
      (zeroBytes 16)
      0
      (zeroBytes 4096)
      (bytes [99, 104, 105, 112, 56, 45, 116, 114, 97, 110, 115, 99, 114, 105, 112, 116, 45, 115, 101, 101, 100, 45, 118, 49]))
      bundleMetaPub_jump_rows_3_seed_nonempty)
      [(mkFrameSourceView 0 (mkFrameDecodeView .jump 2 0 0 512 4608 256 0 0 false false 0) (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096)) (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096)) ([1, 256, 256, 0, 0, 0, 0, 0, 0, 512, 256, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0])), (mkFrameSourceView 1 (mkFrameDecodeView .jump 2 0 0 512 4608 256 0 0 false false 0) (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096)) (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096)) ([1, 256, 256, 0, 0, 0, 0, 0, 0, 512, 256, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0])), (mkFrameSourceView 2 (mkFrameDecodeView .jump 2 0 0 512 4608 256 0 0 false false 0) (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096)) (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096)) ([1, 256, 256, 0, 0, 0, 0, 0, 0, 512, 256, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0]))]
      [(mkStage3View
        0
        3
        (pair 1136800374147296423 1755481479147389656)
        (pair 8666352296045149794 17144351712453045142)
        (mkStage3ShiftClaimView
        .lane
        ([pair 9800601118975603008 4663101122188452279, pair 11088416307407920185 7508095264614072439])
        ([.pc, .xIdx, .isMemOp])
        ([.shiftPc, .shiftXIdx, .shiftIsMemOp])
        ([pair 6008278049199208749 14148955047869604976, pair 0 0, pair 0 0]))
        (mkStage3ShiftWitnessView
        (pair 6008278049199208749 14148955047869604976)
        (pair 0 0)
        (pair 0 0)
        ([[pair 2164011993418418330 14835739547328809321, pair 16559891966446618346 12141174175232274507, pair 3567106165330338064 9229789916808880469], [pair 12900111175590763523 14857417548511884672, pair 8706256671127097018 4852169196939729979, pair 2810939593383838873 7482829073691657081]]))
        (mkStage3CurrentRowView 0 1 256 0 0 0)
        (mkStage3RowClaimView 0 ([false, false]) ([pair 256 0, pair 256 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 512 0, pair 256 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 1 0, pair 0 0, pair 1 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0]))
        (bytes [126, 31, 96, 184, 149, 69, 13, 137, 58, 7, 51, 209, 110, 41, 33, 0, 75, 42, 60, 115, 31, 232, 192, 69, 152, 250, 24, 155, 121, 169, 229, 198])), (mkStage3View
        1
        3
        (pair 1136800374147296423 1755481479147389656)
        (pair 8666352296045149794 17144351712453045142)
        (mkStage3ShiftClaimView
        .lane
        ([pair 9800601118975603008 4663101122188452279, pair 11088416307407920185 7508095264614072439])
        ([.pc, .xIdx, .isMemOp])
        ([.shiftPc, .shiftXIdx, .shiftIsMemOp])
        ([pair 6008278049199208749 14148955047869604976, pair 0 0, pair 0 0]))
        (mkStage3ShiftWitnessView
        (pair 6008278049199208749 14148955047869604976)
        (pair 0 0)
        (pair 0 0)
        ([[pair 2164011993418418330 14835739547328809321, pair 16559891966446618346 12141174175232274507, pair 3567106165330338064 9229789916808880469], [pair 12900111175590763523 14857417548511884672, pair 8706256671127097018 4852169196939729979, pair 2810939593383838873 7482829073691657081]]))
        (mkStage3CurrentRowView 1 1 256 0 0 0)
        (mkStage3RowClaimView 1 ([true, false]) ([pair 256 0, pair 256 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 512 0, pair 256 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 1 0, pair 0 0, pair 1 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0]))
        (bytes [126, 31, 96, 184, 149, 69, 13, 137, 58, 7, 51, 209, 110, 41, 33, 0, 75, 42, 60, 115, 31, 232, 192, 69, 152, 250, 24, 155, 121, 169, 229, 198])), (mkStage3View
        2
        3
        (pair 1136800374147296423 1755481479147389656)
        (pair 8666352296045149794 17144351712453045142)
        (mkStage3ShiftClaimView
        .lane
        ([pair 9800601118975603008 4663101122188452279, pair 11088416307407920185 7508095264614072439])
        ([.pc, .xIdx, .isMemOp])
        ([.shiftPc, .shiftXIdx, .shiftIsMemOp])
        ([pair 6008278049199208749 14148955047869604976, pair 0 0, pair 0 0]))
        (mkStage3ShiftWitnessView
        (pair 6008278049199208749 14148955047869604976)
        (pair 0 0)
        (pair 0 0)
        ([[pair 2164011993418418330 14835739547328809321, pair 16559891966446618346 12141174175232274507, pair 3567106165330338064 9229789916808880469], [pair 12900111175590763523 14857417548511884672, pair 8706256671127097018 4852169196939729979, pair 2810939593383838873 7482829073691657081]]))
        (mkStage3CurrentRowView 2 0 256 0 0 0)
        (mkStage3RowClaimView 2 ([false, true]) ([pair 256 0, pair 256 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 512 0, pair 256 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 1 0, pair 0 0, pair 1 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0]))
        (bytes [126, 31, 96, 184, 149, 69, 13, 137, 58, 7, 51, 209, 110, 41, 33, 0, 75, 42, 60, 115, 31, 232, 192, 69, 152, 250, 24, 155, 121, 169, 229, 198]))]
      (mkStagedExecutionDigestBundleView
      (mkDigestPublicView
      (mkPublicInputView
      (bytes [18, 0])
      256
      (zeroBytes 16)
      0
      (zeroBytes 4096)
      (bytes [99, 104, 105, 112, 56, 45, 116, 114, 97, 110, 115, 99, 114, 105, 112, 116, 45, 115, 101, 101, 100, 45, 118, 49]))
      bundleMetaPub_jump_rows_3_seed_nonempty)
      [(mkStagedExecutionDigestView
      (mkStage1View
        (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096))
        (mkFrameDecodeView .jump 2 0 0 512 4608 256 0 0 false false 0)
        ([1, 256, 256, 0, 0, 0, 0, 0, 0, 512, 256, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0]))
      (mkStage2View
        (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096))
        (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096))
        (mkFrameDecodeView .jump 2 0 0 512 4608 256 0 0 false false 0)
        ([1, 256, 256, 0, 0, 0, 0, 0, 0, 512, 256, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0]))
      (mkStage3View
        0
        3
        (pair 1136800374147296423 1755481479147389656)
        (pair 8666352296045149794 17144351712453045142)
        (mkStage3ShiftClaimView
        .lane
        ([pair 9800601118975603008 4663101122188452279, pair 11088416307407920185 7508095264614072439])
        ([.pc, .xIdx, .isMemOp])
        ([.shiftPc, .shiftXIdx, .shiftIsMemOp])
        ([pair 6008278049199208749 14148955047869604976, pair 0 0, pair 0 0]))
        (mkStage3ShiftWitnessView
        (pair 6008278049199208749 14148955047869604976)
        (pair 0 0)
        (pair 0 0)
        ([[pair 2164011993418418330 14835739547328809321, pair 16559891966446618346 12141174175232274507, pair 3567106165330338064 9229789916808880469], [pair 12900111175590763523 14857417548511884672, pair 8706256671127097018 4852169196939729979, pair 2810939593383838873 7482829073691657081]]))
        (mkStage3CurrentRowView 0 1 256 0 0 0)
        (mkStage3RowClaimView 0 ([false, false]) ([pair 256 0, pair 256 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 512 0, pair 256 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 1 0, pair 0 0, pair 1 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0]))
        (bytes [126, 31, 96, 184, 149, 69, 13, 137, 58, 7, 51, 209, 110, 41, 33, 0, 75, 42, 60, 115, 31, 232, 192, 69, 152, 250, 24, 155, 121, 169, 229, 198]))
      (mkExecutionResultView
        0
        (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096))
        (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096))
        (mkFrameDecodeView .jump 2 0 0 512 4608 256 0 0 false false 0))), (mkStagedExecutionDigestView
      (mkStage1View
        (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096))
        (mkFrameDecodeView .jump 2 0 0 512 4608 256 0 0 false false 0)
        ([1, 256, 256, 0, 0, 0, 0, 0, 0, 512, 256, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0]))
      (mkStage2View
        (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096))
        (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096))
        (mkFrameDecodeView .jump 2 0 0 512 4608 256 0 0 false false 0)
        ([1, 256, 256, 0, 0, 0, 0, 0, 0, 512, 256, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0]))
      (mkStage3View
        1
        3
        (pair 1136800374147296423 1755481479147389656)
        (pair 8666352296045149794 17144351712453045142)
        (mkStage3ShiftClaimView
        .lane
        ([pair 9800601118975603008 4663101122188452279, pair 11088416307407920185 7508095264614072439])
        ([.pc, .xIdx, .isMemOp])
        ([.shiftPc, .shiftXIdx, .shiftIsMemOp])
        ([pair 6008278049199208749 14148955047869604976, pair 0 0, pair 0 0]))
        (mkStage3ShiftWitnessView
        (pair 6008278049199208749 14148955047869604976)
        (pair 0 0)
        (pair 0 0)
        ([[pair 2164011993418418330 14835739547328809321, pair 16559891966446618346 12141174175232274507, pair 3567106165330338064 9229789916808880469], [pair 12900111175590763523 14857417548511884672, pair 8706256671127097018 4852169196939729979, pair 2810939593383838873 7482829073691657081]]))
        (mkStage3CurrentRowView 1 1 256 0 0 0)
        (mkStage3RowClaimView 1 ([true, false]) ([pair 256 0, pair 256 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 512 0, pair 256 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 1 0, pair 0 0, pair 1 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0]))
        (bytes [126, 31, 96, 184, 149, 69, 13, 137, 58, 7, 51, 209, 110, 41, 33, 0, 75, 42, 60, 115, 31, 232, 192, 69, 152, 250, 24, 155, 121, 169, 229, 198]))
      (mkExecutionResultView
        1
        (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096))
        (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096))
        (mkFrameDecodeView .jump 2 0 0 512 4608 256 0 0 false false 0))), (mkStagedExecutionDigestView
      (mkStage1View
        (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096))
        (mkFrameDecodeView .jump 2 0 0 512 4608 256 0 0 false false 0)
        ([1, 256, 256, 0, 0, 0, 0, 0, 0, 512, 256, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0]))
      (mkStage2View
        (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096))
        (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096))
        (mkFrameDecodeView .jump 2 0 0 512 4608 256 0 0 false false 0)
        ([1, 256, 256, 0, 0, 0, 0, 0, 0, 512, 256, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0]))
      (mkStage3View
        2
        3
        (pair 1136800374147296423 1755481479147389656)
        (pair 8666352296045149794 17144351712453045142)
        (mkStage3ShiftClaimView
        .lane
        ([pair 9800601118975603008 4663101122188452279, pair 11088416307407920185 7508095264614072439])
        ([.pc, .xIdx, .isMemOp])
        ([.shiftPc, .shiftXIdx, .shiftIsMemOp])
        ([pair 6008278049199208749 14148955047869604976, pair 0 0, pair 0 0]))
        (mkStage3ShiftWitnessView
        (pair 6008278049199208749 14148955047869604976)
        (pair 0 0)
        (pair 0 0)
        ([[pair 2164011993418418330 14835739547328809321, pair 16559891966446618346 12141174175232274507, pair 3567106165330338064 9229789916808880469], [pair 12900111175590763523 14857417548511884672, pair 8706256671127097018 4852169196939729979, pair 2810939593383838873 7482829073691657081]]))
        (mkStage3CurrentRowView 2 0 256 0 0 0)
        (mkStage3RowClaimView 2 ([false, true]) ([pair 256 0, pair 256 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 512 0, pair 256 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 1 0, pair 0 0, pair 1 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0, pair 0 0]))
        (bytes [126, 31, 96, 184, 149, 69, 13, 137, 58, 7, 51, 209, 110, 41, 33, 0, 75, 42, 60, 115, 31, 232, 192, 69, 152, 250, 24, 155, 121, 169, 229, 198]))
      (mkExecutionResultView
        2
        (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096))
        (mkMachineStateView 512 0 (zeroBytes 16) (zeroBytes 4096))
        (mkFrameDecodeView .jump 2 0 0 512 4608 256 0 0 false false 0)))])
  ]

end Nightstream.Chip8.Generated
