import TwistShout.OneHotEncoding

/-!
# OneHotEncodingInterface

Thin theorem-facing boundary for plain and `d`-dimensional one-hot encodings.
-/

namespace TwistShout

namespace OneHotEncodingInterface

abbrev AddressDigits := @TwistShout.AddressDigits
abbrev oneHot := @TwistShout.oneHot
abbrev tupleOneHot := @TwistShout.tupleOneHot
abbrev dOneHot := @TwistShout.dOneHot
abbrev productEncoding := @TwistShout.productEncoding
abbrev IsOneHotEncoding := @TwistShout.IsOneHotEncoding
abbrev IsDOneHotEncoding := @TwistShout.IsDOneHotEncoding

@[simp] theorem oneHot_self
  {K : Type*} [Zero K] [One K]
  {n : Nat}
  (z : Fin n) :
  oneHot (K := K) z z = 1 :=
  TwistShout.oneHot_self (K := K) z

theorem oneHot_eq_zero_of_ne
  {K : Type*} [Zero K] [One K]
  {n : Nat}
  {z k : Fin n}
  (hzk : k ≠ z) :
  oneHot (K := K) z k = 0 :=
  TwistShout.oneHot_eq_zero_of_ne (K := K) hzk

theorem sum_oneHot
  {K : Type*} [CommSemiring K]
  {n : Nat}
  (z : Fin n) :
  ∑ k, oneHot (K := K) z k = 1 :=
  TwistShout.sum_oneHot (K := K) z

theorem oneHot_isBitVec
  {K : Type*} [Field K]
  {n : Nat}
  (z : Fin n) :
  IsBitVec (oneHot (K := K) z) :=
  TwistShout.oneHot_isBitVec (K := K) z

theorem dOneHot_sum
  {K : Type*} [CommSemiring K]
  {d n : Nat}
  (z : AddressDigits d n)
  (i : Fin d) :
  ∑ k, dOneHot (K := K) z i k = 1 :=
  TwistShout.dOneHot_sum (K := K) z i

theorem dOneHot_isBitVec
  {K : Type*} [Field K]
  {d n : Nat}
  (z : AddressDigits d n)
  (i : Fin d) :
  IsBitVec (dOneHot (K := K) z i) :=
  TwistShout.dOneHot_isBitVec (K := K) z i

theorem productEncoding_dOneHot
  {K : Type*} [CommSemiring K]
  {d n : Nat}
  (z k : AddressDigits d n) :
  productEncoding (K := K) (dOneHot (K := K) z) k =
    tupleOneHot (K := K) z k :=
  TwistShout.productEncoding_dOneHot (K := K) z k

open Classical in
theorem productEncoding_eq_delta
  {K : Type*} [CommSemiring K]
  {d n : Nat}
  (z k : AddressDigits d n) :
  productEncoding (K := K) (dOneHot (K := K) z) k =
    (if k = z then 1 else 0) :=
  TwistShout.productEncoding_eq_delta (K := K) z k

theorem productEncoding_eq_one_of_eq
  {K : Type*} [CommSemiring K]
  {d n : Nat}
  {z k : AddressDigits d n}
  (hzk : k = z) :
  productEncoding (K := K) (dOneHot (K := K) z) k = 1 :=
  TwistShout.productEncoding_eq_one_of_eq (K := K) hzk

theorem productEncoding_eq_zero_of_ne
  {K : Type*} [CommSemiring K]
  {d n : Nat}
  {z k : AddressDigits d n}
  (hzk : k ≠ z) :
  productEncoding (K := K) (dOneHot (K := K) z) k = 0 :=
  TwistShout.productEncoding_eq_zero_of_ne (K := K) hzk

theorem IsOneHotEncoding.isBitVec
  {K : Type*} [Field K]
  {n : Nat}
  {v : Fin n → K}
  (hv : IsOneHotEncoding (K := K) v) :
  IsBitVec v :=
  TwistShout.IsOneHotEncoding.isBitVec (K := K) hv

theorem IsOneHotEncoding.sum_eq_one
  {K : Type*} [Field K]
  {n : Nat}
  {v : Fin n → K}
  (hv : IsOneHotEncoding (K := K) v) :
  ∑ k, v k = 1 :=
  TwistShout.IsOneHotEncoding.sum_eq_one (K := K) hv

theorem IsDOneHotEncoding.coord_isBitVec
  {K : Type*} [Field K]
  {d n : Nat}
  {v : Fin d → Fin n → K}
  (hv : IsDOneHotEncoding (K := K) v)
  (i : Fin d) :
  IsBitVec (v i) :=
  TwistShout.IsDOneHotEncoding.coord_isBitVec (K := K) hv i

theorem IsDOneHotEncoding.coord_sum_eq_one
  {K : Type*} [Field K]
  {d n : Nat}
  {v : Fin d → Fin n → K}
  (hv : IsDOneHotEncoding (K := K) v)
  (i : Fin d) :
  ∑ k, v i k = 1 :=
  TwistShout.IsDOneHotEncoding.coord_sum_eq_one (K := K) hv i

theorem IsDOneHotEncoding.product_eq_tupleOneHot
  {K : Type*} [Field K]
  {d n : Nat}
  {v : Fin d → Fin n → K}
  (hv : IsDOneHotEncoding (K := K) v) :
  ∃ z : AddressDigits d n,
    ∀ k, productEncoding (K := K) v k = tupleOneHot (K := K) z k :=
  TwistShout.IsDOneHotEncoding.product_eq_tupleOneHot (K := K) hv

theorem dOneHot_unique
  {K : Type*} [Field K]
  {d n : Nat}
  {v : Fin d → Fin n → K}
  {z : AddressDigits d n}
  (hv : IsDOneHotEncoding (K := K) v)
  (hprod : ∀ k, productEncoding (K := K) v k = tupleOneHot (K := K) z k) :
  v = dOneHot (K := K) z :=
  TwistShout.dOneHot_unique (K := K) hv hprod

end OneHotEncodingInterface

end TwistShout
