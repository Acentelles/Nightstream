import TwistShout.EqPoly

/-!
# EqPolyInterface

Thin theorem-facing boundary for the multilinear equality polynomial used
throughout the Twist/Shout paper.
-/

namespace TwistShout

namespace EqPolyInterface

def IsBit {K : Type*} [Field K] (x : K) : Prop :=
  TwistShout.IsBit x

def IsBitVec {K : Type*} [Field K] {n : Nat} (v : Fin n → K) : Prop :=
  TwistShout.IsBitVec v

def eqTerm {K : Type*} [Field K] (x y : K) : K :=
  TwistShout.eqTerm x y

def eqPoly {K : Type*} [Field K] {n : Nat} (x y : Fin n → K) : K :=
  TwistShout.eqPoly x y

@[simp] theorem isBit_zero
  {K : Type*} [Field K] :
  IsBit (0 : K) :=
  TwistShout.isBit_zero

@[simp] theorem isBit_one
  {K : Type*} [Field K] :
  IsBit (1 : K) :=
  TwistShout.isBit_one

open Classical in
theorem eqTerm_eq_delta_of_isBit
  {K : Type*} [Field K]
  {x y : K}
  (hx : IsBit x)
  (hy : IsBit y) :
  eqTerm x y = (if x = y then 1 else 0) :=
  TwistShout.eqTerm_eq_delta_of_isBit hx hy

@[simp] theorem eqPoly_zero
  {K : Type*} [Field K]
  (x y : Fin 0 → K) :
  eqPoly x y = 1 :=
  TwistShout.eqPoly_zero x y

theorem eqPoly_succ
  {K : Type*} [Field K]
  {n : Nat}
  (x y : Fin (n + 1) → K) :
  eqPoly x y =
    eqTerm (x 0) (y 0) * eqPoly (fun i => x i.succ) (fun i => y i.succ) :=
  TwistShout.eqPoly_succ x y

theorem eqPoly_eq_one_of_eq_of_isBitVec
  {K : Type*} [Field K]
  {n : Nat}
  {x y : Fin n → K}
  (hxy : x = y)
  (hx : IsBitVec x) :
  eqPoly x y = 1 :=
  TwistShout.eqPoly_eq_one_of_eq_of_isBitVec hxy hx

theorem eqPoly_eq_zero_of_ne_of_isBitVec
  {K : Type*} [Field K]
  {n : Nat}
  {x y : Fin n → K}
  (hxy : x ≠ y)
  (hx : IsBitVec x)
  (hy : IsBitVec y) :
  eqPoly x y = 0 :=
  TwistShout.eqPoly_eq_zero_of_ne_of_isBitVec hxy hx hy

open Classical in
theorem eqPoly_eq_delta_of_isBitVec
  {K : Type*} [Field K]
  {n : Nat}
  {x y : Fin n → K}
  (hx : IsBitVec x)
  (hy : IsBitVec y) :
  eqPoly x y = (if x = y then 1 else 0) :=
  TwistShout.eqPoly_eq_delta_of_isBitVec hx hy

end EqPolyInterface

end TwistShout
