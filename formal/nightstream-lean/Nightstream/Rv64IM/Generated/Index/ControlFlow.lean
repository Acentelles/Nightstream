import Nightstream.Rv64IM.Generated.Cases.Case_vertical_add_sd_ld_ecall.Source
import Nightstream.Rv64IM.Generated.Cases.Case_vertical_add_sd_ld_ecall.Derived
import Nightstream.Rv64IM.Generated.Cases.Case_native_add_chain_x0_ecall.Source
import Nightstream.Rv64IM.Generated.Cases.Case_native_add_chain_x0_ecall.Derived
import Nightstream.Rv64IM.Generated.Cases.Case_aligned_negative_offset_roundtrip.Source
import Nightstream.Rv64IM.Generated.Cases.Case_aligned_negative_offset_roundtrip.Derived
import Nightstream.Rv64IM.Generated.Cases.Case_control_flow_ecall_only.Source
import Nightstream.Rv64IM.Generated.Cases.Case_control_flow_ecall_only.Derived

namespace Nightstream.Rv64IM.Generated.Index.ControlFlow

open Nightstream.Rv64IM.Generated

def sourceCases : List ParitySourceCase :=
  [Nightstream.Rv64IM.Generated.Cases.Case_vertical_add_sd_ld_ecall.sourceCase, Nightstream.Rv64IM.Generated.Cases.Case_native_add_chain_x0_ecall.sourceCase, Nightstream.Rv64IM.Generated.Cases.Case_aligned_negative_offset_roundtrip.sourceCase, Nightstream.Rv64IM.Generated.Cases.Case_control_flow_ecall_only.sourceCase]

def derivedCases : List ParityDerivedCase :=
  [Nightstream.Rv64IM.Generated.Cases.Case_vertical_add_sd_ld_ecall.derivedCase, Nightstream.Rv64IM.Generated.Cases.Case_native_add_chain_x0_ecall.derivedCase, Nightstream.Rv64IM.Generated.Cases.Case_aligned_negative_offset_roundtrip.derivedCase, Nightstream.Rv64IM.Generated.Cases.Case_control_flow_ecall_only.derivedCase]

def parityCases : List (ParitySourceCase × ParityDerivedCase) :=
  [(Nightstream.Rv64IM.Generated.Cases.Case_vertical_add_sd_ld_ecall.sourceCase, Nightstream.Rv64IM.Generated.Cases.Case_vertical_add_sd_ld_ecall.derivedCase), (Nightstream.Rv64IM.Generated.Cases.Case_native_add_chain_x0_ecall.sourceCase, Nightstream.Rv64IM.Generated.Cases.Case_native_add_chain_x0_ecall.derivedCase), (Nightstream.Rv64IM.Generated.Cases.Case_aligned_negative_offset_roundtrip.sourceCase, Nightstream.Rv64IM.Generated.Cases.Case_aligned_negative_offset_roundtrip.derivedCase), (Nightstream.Rv64IM.Generated.Cases.Case_control_flow_ecall_only.sourceCase, Nightstream.Rv64IM.Generated.Cases.Case_control_flow_ecall_only.derivedCase)]

end Nightstream.Rv64IM.Generated.Index.ControlFlow
