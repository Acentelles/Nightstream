import Nightstream.Rv64IM.Generated.Cases.Case_multiply_low_mul_mulw_ecall.Source
import Nightstream.Rv64IM.Generated.Cases.Case_multiply_low_mul_mulw_ecall.Derived
import Nightstream.Rv64IM.Generated.Cases.Case_multiply_high_mulh_mulhu_mulhsu_ecall.Source
import Nightstream.Rv64IM.Generated.Cases.Case_multiply_high_mulh_mulhu_mulhsu_ecall.Derived

namespace Nightstream.Rv64IM.Generated.Index.Multiply

open Nightstream.Rv64IM.Generated

def sourceCases : List ParitySourceCase :=
  [Nightstream.Rv64IM.Generated.Cases.Case_multiply_low_mul_mulw_ecall.sourceCase, Nightstream.Rv64IM.Generated.Cases.Case_multiply_high_mulh_mulhu_mulhsu_ecall.sourceCase]

def derivedCases : List ParityDerivedCase :=
  [Nightstream.Rv64IM.Generated.Cases.Case_multiply_low_mul_mulw_ecall.derivedCase, Nightstream.Rv64IM.Generated.Cases.Case_multiply_high_mulh_mulhu_mulhsu_ecall.derivedCase]

def parityCases : List (ParitySourceCase × ParityDerivedCase) :=
  [(Nightstream.Rv64IM.Generated.Cases.Case_multiply_low_mul_mulw_ecall.sourceCase, Nightstream.Rv64IM.Generated.Cases.Case_multiply_low_mul_mulw_ecall.derivedCase), (Nightstream.Rv64IM.Generated.Cases.Case_multiply_high_mulh_mulhu_mulhsu_ecall.sourceCase, Nightstream.Rv64IM.Generated.Cases.Case_multiply_high_mulh_mulhu_mulhsu_ecall.derivedCase)]

end Nightstream.Rv64IM.Generated.Index.Multiply
