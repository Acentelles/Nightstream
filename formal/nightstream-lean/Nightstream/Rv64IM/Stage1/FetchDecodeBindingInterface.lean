import Nightstream.Rv64IM.Stage1.FetchDecodeBinding

namespace Nightstream.Rv64IM

namespace FetchDecodeBindingInterface

abbrev DecodeHandoff := Nightstream.Rv64IM.DecodeHandoff
abbrev DecodedStage1Row := Nightstream.Rv64IM.DecodedStage1Row
abbrev DecodedStage1Row.toDecodeHandoff := @Nightstream.Rv64IM.DecodedStage1Row.toDecodeHandoff
abbrev DecodedStage1Row.advanceArchPc := @Nightstream.Rv64IM.DecodedStage1Row.advanceArchPc
abbrev DecodeHandoffBound := @Nightstream.Rv64IM.DecodeHandoffBound
abbrev X0WritePreserved := @Nightstream.Rv64IM.X0WritePreserved
abbrev NonFinalRdTargetBound := @Nightstream.Rv64IM.NonFinalRdTargetBound
abbrev FetchDecodeBound := @Nightstream.Rv64IM.FetchDecodeBound

abbrev decodeHandoffBound_refl := @Nightstream.Rv64IM.decodeHandoffBound_refl
abbrev advanceArchPc_eq_isLastInSequence := @Nightstream.Rv64IM.advanceArchPc_eq_isLastInSequence
abbrev fetchDecodeBound_bytecodeRow := @Nightstream.Rv64IM.fetchDecodeBound_bytecodeRow
abbrev fetchDecodeBound_valid := @Nightstream.Rv64IM.fetchDecodeBound_valid
abbrev fetchDecodeBound_handoff := @Nightstream.Rv64IM.fetchDecodeBound_handoff
abbrev fetchDecodeBound_x0Preserved := @Nightstream.Rv64IM.fetchDecodeBound_x0Preserved
abbrev fetchDecodeBound_nonFinalRdTarget :=
  @Nightstream.Rv64IM.fetchDecodeBound_nonFinalRdTarget

end FetchDecodeBindingInterface

end Nightstream.Rv64IM
