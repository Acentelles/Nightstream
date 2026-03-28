import Nightstream.Rv64IM.Generated.Cases.Case_vertical_add_sd_ld_ecall.Source
import Nightstream.Rv64IM.Generated.Cases.Case_vertical_add_sd_ld_ecall.Derived
import Nightstream.Rv64IM.Generated.Cases.Case_aligned_negative_offset_roundtrip.Source
import Nightstream.Rv64IM.Generated.Cases.Case_aligned_negative_offset_roundtrip.Derived

namespace Nightstream.Rv64IM.Generated.Index.AlignedMemory

open Nightstream.Rv64IM.Generated

def sourceCases : List ParitySourceCase :=
  [Nightstream.Rv64IM.Generated.Cases.Case_vertical_add_sd_ld_ecall.sourceCase, Nightstream.Rv64IM.Generated.Cases.Case_aligned_negative_offset_roundtrip.sourceCase]

def derivedCases : List ParityDerivedCase :=
  [Nightstream.Rv64IM.Generated.Cases.Case_vertical_add_sd_ld_ecall.derivedCase, Nightstream.Rv64IM.Generated.Cases.Case_aligned_negative_offset_roundtrip.derivedCase]

def parityCases : List (ParitySourceCase × ParityDerivedCase) :=
  [(Nightstream.Rv64IM.Generated.Cases.Case_vertical_add_sd_ld_ecall.sourceCase, Nightstream.Rv64IM.Generated.Cases.Case_vertical_add_sd_ld_ecall.derivedCase), (Nightstream.Rv64IM.Generated.Cases.Case_aligned_negative_offset_roundtrip.sourceCase, Nightstream.Rv64IM.Generated.Cases.Case_aligned_negative_offset_roundtrip.derivedCase)]

end Nightstream.Rv64IM.Generated.Index.AlignedMemory
