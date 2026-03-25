import Nightstream.Rv64IM.Generated.Cases.Case_narrow_memory_load_extract_extend_ecall.Source
import Nightstream.Rv64IM.Generated.Cases.Case_narrow_memory_load_extract_extend_ecall.Derived
import Nightstream.Rv64IM.Generated.Cases.Case_narrow_memory_store_blend_ecall.Source
import Nightstream.Rv64IM.Generated.Cases.Case_narrow_memory_store_blend_ecall.Derived

namespace Nightstream.Rv64IM.Generated.Index.NarrowMemory

open Nightstream.Rv64IM.Generated

def sourceCases : List ParitySourceCase :=
  [Nightstream.Rv64IM.Generated.Cases.Case_narrow_memory_load_extract_extend_ecall.sourceCase, Nightstream.Rv64IM.Generated.Cases.Case_narrow_memory_store_blend_ecall.sourceCase]

def derivedCases : List ParityDerivedCase :=
  [Nightstream.Rv64IM.Generated.Cases.Case_narrow_memory_load_extract_extend_ecall.derivedCase, Nightstream.Rv64IM.Generated.Cases.Case_narrow_memory_store_blend_ecall.derivedCase]

def parityCases : List (ParitySourceCase × ParityDerivedCase) :=
  [(Nightstream.Rv64IM.Generated.Cases.Case_narrow_memory_load_extract_extend_ecall.sourceCase, Nightstream.Rv64IM.Generated.Cases.Case_narrow_memory_load_extract_extend_ecall.derivedCase), (Nightstream.Rv64IM.Generated.Cases.Case_narrow_memory_store_blend_ecall.sourceCase, Nightstream.Rv64IM.Generated.Cases.Case_narrow_memory_store_blend_ecall.derivedCase)]

end Nightstream.Rv64IM.Generated.Index.NarrowMemory
