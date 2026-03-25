import Nightstream.Rv64IM.Generated.Cases.Case_signed_divrem_chain_ecall.Source
import Nightstream.Rv64IM.Generated.Cases.Case_signed_divrem_chain_ecall.Derived

namespace Nightstream.Rv64IM.Generated.Index.SignedDivRem

open Nightstream.Rv64IM.Generated

def sourceCases : List ParitySourceCase :=
  [Nightstream.Rv64IM.Generated.Cases.Case_signed_divrem_chain_ecall.sourceCase]

def derivedCases : List ParityDerivedCase :=
  [Nightstream.Rv64IM.Generated.Cases.Case_signed_divrem_chain_ecall.derivedCase]

def parityCases : List (ParitySourceCase × ParityDerivedCase) :=
  [(Nightstream.Rv64IM.Generated.Cases.Case_signed_divrem_chain_ecall.sourceCase, Nightstream.Rv64IM.Generated.Cases.Case_signed_divrem_chain_ecall.derivedCase)]

end Nightstream.Rv64IM.Generated.Index.SignedDivRem
