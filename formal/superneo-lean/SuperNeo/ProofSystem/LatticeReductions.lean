import SuperNeo.ProofSystem.Lattice
import SuperNeo.SamplingSet
import Init.GrindInstances.Ring.Fin

namespace SuperNeo.ProofSystem

/--
Boundary laws used by extractor linearity steps.
These are threaded explicitly until Ring/Norm closure discharges them.
-/
local instance : NeZero Goldilocks.q := ⟨Nat.ne_of_gt Goldilocks.q_pos⟩

structure LatticeReductionLaws (params : AjtaiParams) where
  normInfVec_subVec_le :
    ∀ (n : Nat) (v1 v2 : Array Coeffs),
      normInfVec (subVec n v1 v2) ≤ normInfVec v1 + normInfVec v2
  samplingCarrier : SamplingCarrier
  strongSampling : strongSamplingExpansionProp samplingCarrier params.relaxedExpansion
  deltaInDiff_of_deltaBound :
    ∀ (delta : Coeffs),
      normInfCoeffs delta < 4 * params.relaxedExpansion →
      samplingDiffSet samplingCarrier delta
  smulVec_comm :
    ∀ (delta1 delta2 : Coeffs) (v : Array Coeffs),
      smulVec delta1 (smulVec delta2 v) = smulVec delta2 (smulVec delta1 v)

private theorem f_sub_eq_add_neg (a b : F) : a - b = a + -b := by
  apply Fin.ext
  change (Goldilocks.q - b.val + a.val) % Goldilocks.q =
    (a.val + (Goldilocks.q - b.val) % Goldilocks.q) % Goldilocks.q
  calc
    (Goldilocks.q - b.val + a.val) % Goldilocks.q
        = (((Goldilocks.q - b.val) % Goldilocks.q) + (a.val % Goldilocks.q)) % Goldilocks.q := by
            simpa using (Nat.add_mod (Goldilocks.q - b.val) a.val Goldilocks.q)
    _ = (a.val + (Goldilocks.q - b.val) % Goldilocks.q) % Goldilocks.q := by
          have ha : a.val % Goldilocks.q = a.val := Nat.mod_eq_of_lt a.isLt
          simp [ha, Nat.add_comm]

private theorem f_mul_sub (a b c : F) : a * (b - c) = a * b - a * c := by
  calc
    a * (b - c) = a * (b + -c) := by
      simp [f_sub_eq_add_neg]
    _ = a * b + a * -c := by
      simpa using (Lean.Grind.Fin.left_distrib (n := Goldilocks.q) a b (-c))
    _ = a * b + -(a * c) := by
      have hneg : a * -c = -(a * c) := by
        calc
          a * -c = -c * a := by
            simpa using (Lean.Grind.Fin.mul_comm (n := Goldilocks.q) a (-c))
          _ = -(c * a) := by
            simpa using (Lean.Grind.Fin.neg_mul (n := Goldilocks.q) c a)
          _ = -(a * c) := by
            simpa using congrArg (fun t => -t) (Lean.Grind.Fin.mul_comm (n := Goldilocks.q) c a)
      simp [hneg]
    _ = a * b - a * c := by
      simp [f_sub_eq_add_neg]

private theorem f_neg_add (a b : F) : -(a + b) = -a + -b := by
  have hNegOneMul (x : F) : -x = (-1 : F) * x := by
    calc
      -x = -((1 : F) * x) := by
        have hone : (1 : F) * x = x := by
          calc
            (1 : F) * x = x * (1 : F) := by
              simpa using (Lean.Grind.Fin.mul_comm (n := Goldilocks.q) (1 : F) x)
            _ = x := by
              simpa using (Lean.Grind.Fin.mul_one (n := Goldilocks.q) x)
        simp [hone]
      _ = (-1 : F) * x := by
        simpa using (Lean.Grind.Fin.neg_mul (n := Goldilocks.q) (1 : F) x).symm
  have hA : ((-1 : F) * a) = -a := by
    simpa using (hNegOneMul a).symm
  have hB : ((-1 : F) * b) = -b := by
    simpa using (hNegOneMul b).symm
  calc
    -(a + b) = (-1 : F) * (a + b) := by
      simpa using hNegOneMul (a + b)
    _ = ((-1 : F) * a) + ((-1 : F) * b) := by
      simpa using (Lean.Grind.Fin.left_distrib (n := Goldilocks.q) (-1 : F) a b)
    _ = -a + -b := by
      simpa [hA, hB]

private theorem f_sub_add_sub (x y u v : F) :
    (x - y) + (u - v) = (x + u) - (y + v) := by
  calc
    (x - y) + (u - v) = (x + -y) + (u + -v) := by
      simp [f_sub_eq_add_neg]
    _ = x + (-y + (u + -v)) := by
      simpa using (Lean.Grind.Fin.add_assoc (n := Goldilocks.q) x (-y) (u + -v))
    _ = x + ((u + -y) + -v) := by
      have hcomm : -y + u = u + -y := by
        simpa using (Lean.Grind.Fin.add_comm (n := Goldilocks.q) (-y) u)
      calc
        x + (-y + (u + -v)) = x + ((-y + u) + -v) := by
          simp [Lean.Grind.Fin.add_assoc]
        _ = x + ((u + -y) + -v) := by
          simp [hcomm]
    _ = (x + u) + (-y + -v) := by
      calc
        x + ((u + -y) + -v) = x + (u + (-y + -v)) := by
          simpa using congrArg (fun t => x + t)
            (Lean.Grind.Fin.add_assoc (n := Goldilocks.q) u (-y) (-v))
        _ = (x + u) + (-y + -v) := by
          simpa using (Lean.Grind.Fin.add_assoc (n := Goldilocks.q) x u (-y + -v)).symm
    _ = (x + u) + (-(y + v)) := by
      simp [f_neg_add]
    _ = (x + u) - (y + v) := by
      simp [f_sub_eq_add_neg]

private theorem foldl_sub_linearity_F
  (l : List Nat)
  (t1 t2 : Nat → F)
  (acc1 acc2 : F) :
  l.foldl (fun acc j => acc + (t1 j - t2 j)) (acc1 - acc2) =
    (l.foldl (fun acc j => acc + t1 j) acc1) -
      (l.foldl (fun acc j => acc + t2 j) acc2) := by
  induction l generalizing acc1 acc2 with
  | nil =>
      simp
  | cons j js ih =>
      have hstep :
          (acc1 - acc2) + (t1 j - t2 j) =
            (acc1 + t1 j) - (acc2 + t2 j) := by
        simpa using f_sub_add_sub acc1 acc2 (t1 j) (t2 j)
      simpa [List.foldl, hstep] using ih (acc1 := acc1 + t1 j) (acc2 := acc2 + t2 j)

private theorem foldl_add_linearity_F
  (l : List Nat)
  (t1 t2 : Nat → F)
  (acc1 acc2 : F) :
  l.foldl (fun acc j => acc + (t1 j + t2 j)) (acc1 + acc2) =
    (l.foldl (fun acc j => acc + t1 j) acc1) +
      (l.foldl (fun acc j => acc + t2 j) acc2) := by
  induction l generalizing acc1 acc2 with
  | nil =>
      simp
  | cons j js ih =>
      have hstep :
          (acc1 + acc2) + (t1 j + t2 j) =
            (acc1 + t1 j) + (acc2 + t2 j) := by
        calc
          (acc1 + acc2) + (t1 j + t2 j)
              = acc1 + (acc2 + (t1 j + t2 j)) := by
                  simpa using
                    (Lean.Grind.Fin.add_assoc (n := Goldilocks.q) acc1 acc2 (t1 j + t2 j))
          _ = acc1 + (t1 j + (acc2 + t2 j)) := by
                have hMid : acc2 + (t1 j + t2 j) = t1 j + (acc2 + t2 j) := by
                  calc
                    acc2 + (t1 j + t2 j) = (acc2 + t1 j) + t2 j := by
                      simpa using
                        (Lean.Grind.Fin.add_assoc (n := Goldilocks.q) acc2 (t1 j) (t2 j)).symm
                    _ = (t1 j + acc2) + t2 j := by
                          simpa using congrArg (fun t => t + t2 j)
                            (Lean.Grind.Fin.add_comm (n := Goldilocks.q) acc2 (t1 j))
                    _ = t1 j + (acc2 + t2 j) := by
                          simpa using
                            (Lean.Grind.Fin.add_assoc (n := Goldilocks.q) (t1 j) acc2 (t2 j))
                simpa [hMid]
          _ = (acc1 + t1 j) + (acc2 + t2 j) := by
                simpa using
                  (Lean.Grind.Fin.add_assoc (n := Goldilocks.q) acc1 (t1 j) (acc2 + t2 j)).symm
      simpa [List.foldl, hstep] using ih (acc1 := acc1 + t1 j) (acc2 := acc2 + t2 j)

private theorem list_foldl_congr
  {α β : Type}
  (f g : α → β → α)
  (init : α)
  (l : List β)
  (hfg : ∀ acc b, f acc b = g acc b) :
  List.foldl f init l = List.foldl g init l := by
  induction l generalizing init with
  | nil =>
      simp
  | cons b bs ih =>
      simp [hfg, ih]

private theorem list_foldl_congr_mem
  {α β : Type}
  (f g : α → β → α)
  (init : α)
  (l : List β)
  (hfg : ∀ acc b, b ∈ l → f acc b = g acc b) :
  List.foldl f init l = List.foldl g init l := by
  induction l generalizing init with
  | nil =>
      simp
  | cons b bs ih =>
      have hHead : f init b = g init b := by
        exact hfg init b (by simp)
      calc
        List.foldl f init (b :: bs)
            = List.foldl f (f init b) bs := by
                rfl
        _ = List.foldl f (g init b) bs := by
              rw [hHead]
        _ = List.foldl g (g init b) bs := by
              apply ih
              intro acc b' hb'
              exact hfg acc b' (by simp [hb'])
        _ = List.foldl g init (b :: bs) := by
              rfl

private theorem coeffAt_mulRq
  (a b : Coeffs) (k : Nat) (hk : k < d) :
  coeffAt (mulRq a b) k =
    (List.range d).foldl
      (fun acc j =>
        let t := (k + d - j) % d
        acc + coeffAt a j * coeffAt b t)
      0 := by
  unfold coeffAt mulRq
  simp [Array.getD, hk, coeffAt]

private theorem coeffAt_eq_get_of_size_d
  (a : Coeffs) (ha : a.size = d) (i : Nat) (hi : i < d) :
  coeffAt a i = a[i]'(by simpa [ha] using hi) := by
  unfold coeffAt
  have his : i < a.size := by simpa [ha] using hi
  simp [hi, Array.getD, his]

private theorem get_eq_coeffAt_of_size_d
  (a : Coeffs) (ha : a.size = d) (i : Nat) (hi : i < d) :
  a[i]'(by simpa [ha] using hi) = coeffAt a i := by
  simpa using (coeffAt_eq_get_of_size_d a ha i hi).symm

private theorem coeffAt_subRq
  (x y : Coeffs) (k : Nat) (hk : k < d) :
  coeffAt (subRq x y) k = coeffAt x k - coeffAt y k := by
  unfold subRq coeffAt
  simp [hk, Array.getD]

private theorem coeffAt_vecAdd_of_size_d
  (x y : Coeffs)
  (hx : x.size = d) (hy : y.size = d)
  (k : Nat) (hk : k < d) :
  coeffAt (vecAdd x y) k = coeffAt x k + coeffAt y k := by
  have hxy : x.size = y.size := by simpa [hx, hy]
  have hkx : k < x.size := by simpa [hx] using hk
  have hky : k < y.size := by simpa [hy] using hk
  unfold coeffAt
  simp [vecAdd, hxy, hk, Array.getD, hkx, hky, coeffAt, hx, hy]

private theorem foldl_vecAdd_size_d
  (l : List Nat) (t : Nat → Coeffs) (init : Coeffs)
  (hinit : init.size = d)
  (ht : ∀ j, (t j).size = d) :
  (l.foldl (fun acc j => vecAdd acc (t j)) init).size = d := by
  induction l generalizing init with
  | nil =>
      simpa using hinit
  | cons j js ih =>
      have htj : (t j).size = d := ht j
      have hEq : init.size = (t j).size := by simpa [hinit, htj]
      have hinit' : (vecAdd init (t j)).size = d := by
        calc
          (vecAdd init (t j)).size = init.size := vecAdd_size_of_eq hEq
          _ = d := hinit
      simpa [List.foldl] using ih (init := vecAdd init (t j)) hinit'

private theorem coeffAt_foldl_vecAdd
  (l : List Nat) (t : Nat → Coeffs) (init : Coeffs)
  (hinit : init.size = d)
  (ht : ∀ j, (t j).size = d)
  (k : Nat) (hk : k < d) :
  coeffAt (l.foldl (fun acc j => vecAdd acc (t j)) init) k =
    l.foldl (fun acc j => acc + coeffAt (t j) k) (coeffAt init k) := by
  induction l generalizing init with
  | nil =>
      simp
  | cons j js ih =>
      have htj : (t j).size = d := ht j
      have hEq : init.size = (t j).size := by simpa [hinit, htj]
      have hinit' : (vecAdd init (t j)).size = d := by
        calc
          (vecAdd init (t j)).size = init.size := vecAdd_size_of_eq hEq
          _ = d := hinit
      have hCoeff :
          coeffAt (vecAdd init (t j)) k = coeffAt init k + coeffAt (t j) k := by
        exact coeffAt_vecAdd_of_size_d init (t j) hinit htj k hk
      calc
        coeffAt ((j :: js).foldl (fun acc j => vecAdd acc (t j)) init) k
            = coeffAt (js.foldl (fun acc j => vecAdd acc (t j)) (vecAdd init (t j))) k := by
                rfl
        _ = js.foldl (fun acc j => acc + coeffAt (t j) k) (coeffAt (vecAdd init (t j)) k) := by
              exact ih (init := vecAdd init (t j)) hinit'
        _ = js.foldl (fun acc j => acc + coeffAt (t j) k) (coeffAt init k + coeffAt (t j) k) := by
              rw [hCoeff]
        _ = (j :: js).foldl (fun acc j => acc + coeffAt (t j) k) (coeffAt init k) := by
              rfl

private theorem dotRq_size (xs ys : Array Coeffs) :
  (dotRq xs ys).size = d := by
  unfold dotRq
  have hinit : zeroRq.size = d := by simp [zeroRq, d]
  have ht : ∀ j, (mulRq (xs.getD j zeroRq) (ys.getD j zeroRq)).size = d := by
    intro j
    simp [mulRq_size]
  simpa using foldl_vecAdd_size_d
    (l := List.range (Nat.min xs.size ys.size))
    (t := fun j => mulRq (xs.getD j zeroRq) (ys.getD j zeroRq))
    (init := zeroRq)
    hinit
    ht

private theorem coeffAt_dotRq
  (xs ys : Array Coeffs) (k : Nat) (hk : k < d) :
  coeffAt (dotRq xs ys) k =
    (List.range (Nat.min xs.size ys.size)).foldl
      (fun acc j => acc + coeffAt (mulRq (xs.getD j zeroRq) (ys.getD j zeroRq)) k)
      0 := by
  unfold dotRq
  have hinit : zeroRq.size = d := by simp [zeroRq, d]
  have ht : ∀ j, (mulRq (xs.getD j zeroRq) (ys.getD j zeroRq)).size = d := by
    intro j
    simp [mulRq_size]
  simpa [coeffAt_zeroRq] using coeffAt_foldl_vecAdd
    (l := List.range (Nat.min xs.size ys.size))
    (t := fun j => mulRq (xs.getD j zeroRq) (ys.getD j zeroRq))
    (init := zeroRq)
    hinit
    ht
    k
    hk

private theorem subVec_getD_of_lt
  (n : Nat) (v1 v2 : Array Coeffs) (j : Nat) (hj : j < n) :
  (subVec n v1 v2).getD j zeroRq = subRq (v1.getD j zeroRq) (v2.getD j zeroRq) := by
  unfold subVec
  simp [Array.getD, hj]

set_option maxHeartbeats 800000 in
theorem mulRq_sub_right
  (a b c : Coeffs) :
  mulRq a (subRq b c) = subRq (mulRq a b) (mulRq a c) := by
  apply Array.ext
  · simp [mulRq, subRq]
  · intro i hi₁ hi₂
    have hi : i < d := by
      simpa [mulRq] using hi₁
    let t1 : Nat → F := fun j =>
      coeffAt a j * coeffAt b ((i + d - j) % d)
    let t2 : Nat → F := fun j =>
      coeffAt a j * coeffAt c ((i + d - j) % d)
    have hfold := foldl_sub_linearity_F (l := List.range d) t1 t2 0 0
    have hzero : ((0 : F) - 0) = 0 := by
      exact (F.sub_eq_zero_iff (0 : F) 0).2 rfl
    have hfold0 :
        (List.range d).foldl (fun acc j => acc + (t1 j - t2 j)) 0 =
          (List.range d).foldl (fun acc j => acc + t1 j) 0 -
            (List.range d).foldl (fun acc j => acc + t2 j) 0 := by
      simpa [hzero] using hfold
    have hterm :
        ∀ j,
          coeffAt a j * coeffAt (subRq b c) ((i + d - j) % d) =
            (t1 j - t2 j) := by
      intro j
      change
        coeffAt a j * coeffAt (subRq b c) ((i + d - j) % d) =
          coeffAt a j * coeffAt b ((i + d - j) % d) -
            coeffAt a j * coeffAt c ((i + d - j) % d)
      let k : Nat := (i + d - j) % d
      have hd : 0 < d := by
        have : 0 < (8 : Nat) := by decide
        simpa [d] using this
      have hmod : k < d := by
        dsimp [k]
        exact Nat.mod_lt _ hd
      have hsub :
          coeffAt (subRq b c) k = (coeffAt b k - coeffAt c k) := by
        unfold coeffAt subRq
        simp [Array.getD, hmod, coeffAt]
      rw [show coeffAt (subRq b c) ((i + d - j) % d) = coeffAt (subRq b c) k by rfl]
      rw [hsub]
      have hm :
          coeffAt a j * (coeffAt b k - coeffAt c k) =
            coeffAt a j * coeffAt b k - coeffAt a j * coeffAt c k := by
        simpa using f_mul_sub (coeffAt a j) (coeffAt b k) (coeffAt c k)
      simpa [coeffAt, k, t1, t2] using hm
    have hleft :
        (List.range d).foldl
            (fun acc j => acc + coeffAt a j * coeffAt (subRq b c) ((i + d - j) % d))
            0 =
          (List.range d).foldl (fun acc j => acc + (t1 j - t2 j)) 0 := by
      exact list_foldl_congr
        (fun acc j => acc + coeffAt a j * coeffAt (subRq b c) ((i + d - j) % d))
        (fun acc j => acc + (t1 j - t2 j))
        0
        (List.range d)
        (by
          intro acc j
          exact congrArg (fun t => acc + t) (hterm j))
    have hright :
        (List.range d).foldl (fun acc j => acc + t1 j) 0 -
          (List.range d).foldl (fun acc j => acc + t2 j) 0 =
            coeffAt (subRq (mulRq a b) (mulRq a c)) i := by
      calc
        (List.range d).foldl (fun acc j => acc + t1 j) 0 -
            (List.range d).foldl (fun acc j => acc + t2 j) 0
            = coeffAt (mulRq a b) i - coeffAt (mulRq a c) i := by
                simp [coeffAt_mulRq, t1, t2, hi]
        _ = coeffAt (subRq (mulRq a b) (mulRq a c)) i := by
              simp [subRq, coeffAt, mulRq_size, hi]
    have hmulExpand :
        coeffAt (mulRq a (subRq b c)) i =
          (List.range d).foldl
            (fun acc j => acc + coeffAt a j * coeffAt (subRq b c) ((i + d - j) % d))
            0 := by
      exact coeffAt_mulRq a (subRq b c) i hi
    have hmain :
        coeffAt (mulRq a (subRq b c)) i =
          coeffAt (subRq (mulRq a b) (mulRq a c)) i := by
      calc
        coeffAt (mulRq a (subRq b c)) i
            = (List.range d).foldl
                (fun acc j => acc + coeffAt a j * coeffAt (subRq b c) ((i + d - j) % d))
                0 := hmulExpand
        _ = (List.range d).foldl (fun acc j => acc + (t1 j - t2 j)) 0 := hleft
        _ = (List.range d).foldl (fun acc j => acc + t1 j) 0 -
              (List.range d).foldl (fun acc j => acc + t2 j) 0 := hfold0
        _ = coeffAt (subRq (mulRq a b) (mulRq a c)) i := by
              exact hright
    have hiL : i < d := by simpa [mulRq] using hi₁
    have hiR : i < d := by simpa [subRq] using hi₂
    simpa [coeffAt, subRq, hiL, hiR, Array.getD, hi₁, hi₂, mulRq_size] using hmain

/-- Right-zero law for `mulRq`, derived from subtraction-linearity. -/
theorem mulRq_zero_right (a : Coeffs) :
  mulRq a zeroRq = zeroRq := by
  have hSubZero : subRq zeroRq zeroRq = zeroRq := subRq_self zeroRq
  calc
    mulRq a zeroRq
        = mulRq a (subRq zeroRq zeroRq) := by
            simpa [hSubZero]
    _ = subRq (mulRq a zeroRq) (mulRq a zeroRq) := by
          simpa using (mulRq_sub_right a zeroRq zeroRq)
    _ = zeroRq := by
          exact subRq_self (mulRq a zeroRq)

/-- Left-zero law for `mulRq`. -/
theorem mulRq_zero_left (a : Coeffs) :
  mulRq zeroRq a = zeroRq := by
  calc
    mulRq zeroRq a = mulRq a zeroRq := by
      simpa using (mulRq_comm zeroRq a)
    _ = zeroRq := mulRq_zero_right a

set_option maxHeartbeats 800000 in
theorem mulRq_vecAdd_right
  (a b c : Coeffs)
  (hb : b.size = d)
  (hc : c.size = d) :
  mulRq a (vecAdd b c) = vecAdd (mulRq a b) (mulRq a c) := by
  have hEq : (mulRq a b).size = (mulRq a c).size := by
    simp [mulRq_size]
  have hsizeR : (vecAdd (mulRq a b) (mulRq a c)).size = d := by
    calc
      (vecAdd (mulRq a b) (mulRq a c)).size = (mulRq a b).size := vecAdd_size_of_eq hEq
      _ = d := mulRq_size a b
  apply Array.ext
  · exact (mulRq_size a (vecAdd b c)).trans hsizeR.symm
  · intro i hi₁ hi₂
    have hi : i < d := by simpa [mulRq_size] using hi₁
    have hiR : i < d := by simpa [hsizeR] using hi₂
    let t1 : Nat → F := fun j => coeffAt a j * coeffAt b ((i + d - j) % d)
    let t2 : Nat → F := fun j => coeffAt a j * coeffAt c ((i + d - j) % d)
    have hterm :
        ∀ j,
          coeffAt a j * coeffAt (vecAdd b c) ((i + d - j) % d) =
            (t1 j + t2 j) := by
      intro j
      let k : Nat := (i + d - j) % d
      have hk : k < d := by
        dsimp [k]
        exact Nat.mod_lt _ d_pos
      have hVec :
          coeffAt (vecAdd b c) k = coeffAt b k + coeffAt c k := by
        exact coeffAt_vecAdd_of_size_d b c hb hc k hk
      have hMul :
          coeffAt a j * (coeffAt b k + coeffAt c k) =
            coeffAt a j * coeffAt b k + coeffAt a j * coeffAt c k := by
        simpa using
          (Lean.Grind.Fin.left_distrib (n := Goldilocks.q)
            (coeffAt a j) (coeffAt b k) (coeffAt c k))
      calc
        coeffAt a j * coeffAt (vecAdd b c) ((i + d - j) % d)
            = coeffAt a j * coeffAt (vecAdd b c) k := by
                rfl
        _ = coeffAt a j * (coeffAt b k + coeffAt c k) := by
              rw [hVec]
        _ = coeffAt a j * coeffAt b k + coeffAt a j * coeffAt c k := hMul
        _ = t1 j + t2 j := by
              simp [t1, t2, k]
    have hleft :
        (List.range d).foldl
            (fun acc j => acc + coeffAt a j * coeffAt (vecAdd b c) ((i + d - j) % d))
            0 =
          (List.range d).foldl (fun acc j => acc + (t1 j + t2 j)) 0 := by
      exact list_foldl_congr
        (fun acc j => acc + coeffAt a j * coeffAt (vecAdd b c) ((i + d - j) % d))
        (fun acc j => acc + (t1 j + t2 j))
        0
        (List.range d)
        (by
          intro acc j
          exact congrArg (fun t => acc + t) (hterm j))
    have hfold := foldl_add_linearity_F (l := List.range d) t1 t2 0 0
    have hzero : ((0 : F) + 0) = 0 := by
      simp
    have hfold0 :
        (List.range d).foldl (fun acc j => acc + (t1 j + t2 j)) 0 =
          (List.range d).foldl (fun acc j => acc + t1 j) 0 +
            (List.range d).foldl (fun acc j => acc + t2 j) 0 := by
      simpa [hzero] using hfold
    have hright :
        (List.range d).foldl (fun acc j => acc + t1 j) 0 +
          (List.range d).foldl (fun acc j => acc + t2 j) 0 =
            coeffAt (vecAdd (mulRq a b) (mulRq a c)) i := by
      have hVecCoeff :
          coeffAt (vecAdd (mulRq a b) (mulRq a c)) i =
            coeffAt (mulRq a b) i + coeffAt (mulRq a c) i := by
        exact coeffAt_vecAdd_of_size_d (mulRq a b) (mulRq a c)
          (mulRq_size a b)
          (mulRq_size a c)
          i
          hi
      calc
        (List.range d).foldl (fun acc j => acc + t1 j) 0 +
            (List.range d).foldl (fun acc j => acc + t2 j) 0
            = coeffAt (mulRq a b) i + coeffAt (mulRq a c) i := by
                simp [coeffAt_mulRq, t1, t2, hi]
        _ = coeffAt (vecAdd (mulRq a b) (mulRq a c)) i := by
              symm
              exact hVecCoeff
    have hmulExpand :
        coeffAt (mulRq a (vecAdd b c)) i =
          (List.range d).foldl
            (fun acc j => acc + coeffAt a j * coeffAt (vecAdd b c) ((i + d - j) % d))
            0 := by
      exact coeffAt_mulRq a (vecAdd b c) i hi
    have hmain :
        coeffAt (mulRq a (vecAdd b c)) i =
          coeffAt (vecAdd (mulRq a b) (mulRq a c)) i := by
      calc
        coeffAt (mulRq a (vecAdd b c)) i
            = (List.range d).foldl
                (fun acc j => acc + coeffAt a j * coeffAt (vecAdd b c) ((i + d - j) % d))
                0 := hmulExpand
        _ = (List.range d).foldl (fun acc j => acc + (t1 j + t2 j)) 0 := hleft
        _ = (List.range d).foldl (fun acc j => acc + t1 j) 0 +
              (List.range d).foldl (fun acc j => acc + t2 j) 0 := hfold0
        _ = coeffAt (vecAdd (mulRq a b) (mulRq a c)) i := by
              exact hright
    have hiL : i < d := by simpa [mulRq_size] using hi₁
    simpa [coeffAt, hiL, hiR, Array.getD, hi₁, hi₂, hsizeR] using hmain

private theorem smulVec_getD_of_lt
  (delta : Coeffs) (v : Array Coeffs) (j : Nat)
  (hj : j < v.size) :
  (smulVec delta v).getD j zeroRq = mulRq delta (v.getD j zeroRq) := by
  simp [smulVec, Array.getD, hj]

private theorem mulRq_mul_swap_of_smulVec_comm
  {params : AjtaiParams}
  (laws : LatticeReductionLaws params)
  (a delta v : Coeffs) :
  mulRq a (mulRq delta v) = mulRq delta (mulRq a v) := by
  let one : Array Coeffs := #[v]
  have hComm : smulVec a (smulVec delta one) = smulVec delta (smulVec a one) :=
    laws.smulVec_comm a delta one
  have hGet := congrArg (fun t => t.getD 0 zeroRq) hComm
  simpa [one, smulVec] using hGet

set_option maxHeartbeats 1200000 in
private theorem foldl_pull_mulRq_smul
  {params : AjtaiParams}
  (laws : LatticeReductionLaws params)
  (l : List Nat)
  (xs v : Array Coeffs)
  (delta acc : Coeffs)
  (hacc : acc.size = d) :
  l.foldl
      (fun a j => vecAdd a (mulRq (xs.getD j zeroRq) (mulRq delta (v.getD j zeroRq))))
      (mulRq delta acc) =
    mulRq delta
      (l.foldl
        (fun a j => vecAdd a (mulRq (xs.getD j zeroRq) (v.getD j zeroRq)))
        acc) := by
  induction l generalizing acc with
  | nil =>
      simpa [mulRq_zero_right]
  | cons j js ih =>
      let term : Coeffs := mulRq (xs.getD j zeroRq) (v.getD j zeroRq)
      have htermSize : term.size = d := by simp [term, mulRq_size]
      have hSwap :
          mulRq (xs.getD j zeroRq) (mulRq delta (v.getD j zeroRq)) =
            mulRq delta term := by
        simpa [term] using
          mulRq_mul_swap_of_smulVec_comm (params := params) laws (xs.getD j zeroRq) delta (v.getD j zeroRq)
      have hStep :
          vecAdd (mulRq delta acc) (mulRq (xs.getD j zeroRq) (mulRq delta (v.getD j zeroRq))) =
            mulRq delta (vecAdd acc term) := by
        calc
          vecAdd (mulRq delta acc) (mulRq (xs.getD j zeroRq) (mulRq delta (v.getD j zeroRq)))
              = vecAdd (mulRq delta acc) (mulRq delta term) := by
                  rw [hSwap]
          _ = mulRq delta (vecAdd acc term) := by
                symm
                exact mulRq_vecAdd_right delta acc term hacc htermSize
      have hEqSize : acc.size = term.size := by simpa [hacc, htermSize]
      have hAcc' : (vecAdd acc term).size = d := by
        calc
          (vecAdd acc term).size = acc.size := vecAdd_size_of_eq hEqSize
          _ = d := hacc
      calc
        (j :: js).foldl
            (fun a j => vecAdd a (mulRq (xs.getD j zeroRq) (mulRq delta (v.getD j zeroRq))))
            (mulRq delta acc)
            = js.foldl
                (fun a j => vecAdd a (mulRq (xs.getD j zeroRq) (mulRq delta (v.getD j zeroRq))))
                (vecAdd (mulRq delta acc) (mulRq (xs.getD j zeroRq) (mulRq delta (v.getD j zeroRq)))) := by
                  simp [List.foldl]
        _ = js.foldl
              (fun a j => vecAdd a (mulRq (xs.getD j zeroRq) (mulRq delta (v.getD j zeroRq))))
              (mulRq delta (vecAdd acc term)) := by
                rw [hStep]
        _ = mulRq delta
              (js.foldl
                (fun a j => vecAdd a (mulRq (xs.getD j zeroRq) (v.getD j zeroRq)))
                (vecAdd acc term)) := by
                exact ih (acc := vecAdd acc term) hAcc'
        _ = mulRq delta
              ((j :: js).foldl
                (fun a j => vecAdd a (mulRq (xs.getD j zeroRq) (v.getD j zeroRq)))
                acc) := by
                rfl

set_option maxHeartbeats 4000000 in
theorem dotRq_smulVec_derived
  {params : AjtaiParams}
  (laws : LatticeReductionLaws params)
  (xs v : Array Coeffs)
  (delta : Coeffs) :
  dotRq xs (smulVec delta v) = mulRq delta (dotRq xs v) := by
  let n := Nat.min xs.size v.size
  have hmin : Nat.min xs.size (smulVec delta v).size = n := by
    simp [n, smulVec]
  have hfoldGet :
      (List.range n).foldl
          (fun a j => vecAdd a (mulRq (xs.getD j zeroRq) ((smulVec delta v).getD j zeroRq)))
          zeroRq
        =
      (List.range n).foldl
          (fun a j => vecAdd a (mulRq (xs.getD j zeroRq) (mulRq delta (v.getD j zeroRq))))
          zeroRq := by
    exact list_foldl_congr_mem
      (fun a j => vecAdd a (mulRq (xs.getD j zeroRq) ((smulVec delta v).getD j zeroRq)))
      (fun a j => vecAdd a (mulRq (xs.getD j zeroRq) (mulRq delta (v.getD j zeroRq))))
      zeroRq
      (List.range n)
      (by
        intro a j hjMem
        have hjn : j < n := by simpa [List.mem_range] using hjMem
        have hjv : j < v.size := Nat.lt_of_lt_of_le hjn (Nat.min_le_right _ _)
        have hGet : (smulVec delta v).getD j zeroRq = mulRq delta (v.getD j zeroRq) :=
          smulVec_getD_of_lt delta v j hjv
        exact congrArg (fun t => vecAdd a (mulRq (xs.getD j zeroRq) t)) hGet)
  calc
    dotRq xs (smulVec delta v)
        = (List.range n).foldl
            (fun a j => vecAdd a (mulRq (xs.getD j zeroRq) ((smulVec delta v).getD j zeroRq)))
            zeroRq := by
              unfold dotRq
              simp [hmin, n]
    _ = (List.range n).foldl
          (fun a j => vecAdd a (mulRq (xs.getD j zeroRq) (mulRq delta (v.getD j zeroRq))))
          zeroRq := hfoldGet
    _ = (List.range n).foldl
          (fun a j => vecAdd a (mulRq (xs.getD j zeroRq) (mulRq delta (v.getD j zeroRq))))
          (mulRq delta zeroRq) := by
            simpa [mulRq_zero_right]
    _ = mulRq delta
          ((List.range n).foldl
            (fun a j => vecAdd a (mulRq (xs.getD j zeroRq) (v.getD j zeroRq)))
            zeroRq) := by
            exact foldl_pull_mulRq_smul
              (params := params)
              laws
              (List.range n)
              xs
              v
              delta
              zeroRq
              zeroRq_size
    _ = mulRq delta (dotRq xs v) := by
          have hDot :
              (List.range n).foldl
                (fun a j => vecAdd a (mulRq (xs.getD j zeroRq) (v.getD j zeroRq)))
                zeroRq = dotRq xs v := by
            unfold dotRq
            simp [n]
          exact congrArg (fun t => mulRq delta t) hDot

theorem matVecMul_smulVec_derived
  {params : AjtaiParams}
  (laws : LatticeReductionLaws params)
  (matrixFlat : Array Coeffs)
  (delta : Coeffs)
  (v : Array Coeffs) :
  matVecMul params matrixFlat (smulVec delta v) =
    smulVec delta (matVecMul params matrixFlat v) := by
  apply Array.ext
  · simp [matVecMul, smulVec]
  · intro i hiL hiR
    calc
      (matVecMul params matrixFlat (smulVec delta v))[i]'hiL
          = dotRq (matRow params.msgLen matrixFlat i) (smulVec delta v) := by
              simp [matVecMul]
      _ = mulRq delta (dotRq (matRow params.msgLen matrixFlat i) v) := by
            exact dotRq_smulVec_derived (params := params) laws (matRow params.msgLen matrixFlat i) v delta
      _ = (smulVec delta (matVecMul params matrixFlat v))[i]'hiR := by
            simp [smulVec, matVecMul]


set_option maxHeartbeats 800000 in
theorem dotRq_subVec_linearity
  {params : AjtaiParams}
  (xs v1 v2 : Array Coeffs)
  (hv1 : v1.size = params.msgLen)
  (hv2 : v2.size = params.msgLen) :
  dotRq xs (subVec params.msgLen v1 v2) = subRq (dotRq xs v1) (dotRq xs v2) := by
  apply Array.ext
  · simp [dotRq_size, subRq]
  · intro i hi₁ hi₂
    have hi : i < d := by
      simpa [dotRq_size] using hi₁
    let n : Nat := Nat.min xs.size params.msgLen
    let t1 : Nat → F := fun j =>
      coeffAt (mulRq (xs.getD j zeroRq) (v1.getD j zeroRq)) i
    let t2 : Nat → F := fun j =>
      coeffAt (mulRq (xs.getD j zeroRq) (v2.getD j zeroRq)) i
    let tL : Nat → F := fun j =>
      coeffAt (mulRq (xs.getD j zeroRq) ((subVec params.msgLen v1 v2).getD j zeroRq)) i
    have htermL :
        ∀ j, j < n → tL j = t1 j - t2 j := by
      intro j hj
      have hjMsg : j < params.msgLen := Nat.lt_of_lt_of_le hj (Nat.min_le_right _ _)
      have hGet :
          (subVec params.msgLen v1 v2).getD j zeroRq =
            subRq (v1.getD j zeroRq) (v2.getD j zeroRq) :=
        subVec_getD_of_lt params.msgLen v1 v2 j hjMsg
      have hMul :
          mulRq (xs.getD j zeroRq) ((subVec params.msgLen v1 v2).getD j zeroRq) =
            subRq
              (mulRq (xs.getD j zeroRq) (v1.getD j zeroRq))
              (mulRq (xs.getD j zeroRq) (v2.getD j zeroRq)) := by
        rw [hGet]
        exact mulRq_sub_right (xs.getD j zeroRq) (v1.getD j zeroRq) (v2.getD j zeroRq)
      have hCoeff :
          coeffAt
              (subRq
                (mulRq (xs.getD j zeroRq) (v1.getD j zeroRq))
                (mulRq (xs.getD j zeroRq) (v2.getD j zeroRq)))
              i
            =
          coeffAt (mulRq (xs.getD j zeroRq) (v1.getD j zeroRq)) i -
            coeffAt (mulRq (xs.getD j zeroRq) (v2.getD j zeroRq)) i := by
        exact coeffAt_subRq
          (mulRq (xs.getD j zeroRq) (v1.getD j zeroRq))
          (mulRq (xs.getD j zeroRq) (v2.getD j zeroRq))
          i
          hi
      calc
        tL j = coeffAt
                (subRq
                  (mulRq (xs.getD j zeroRq) (v1.getD j zeroRq))
                  (mulRq (xs.getD j zeroRq) (v2.getD j zeroRq)))
                i := by
                  simpa [tL] using congrArg (fun z => coeffAt z i) hMul
        _ = coeffAt (mulRq (xs.getD j zeroRq) (v1.getD j zeroRq)) i -
              coeffAt (mulRq (xs.getD j zeroRq) (v2.getD j zeroRq)) i := hCoeff
        _ = t1 j - t2 j := by
              simp [t1, t2]
    have hleftFold :
        (List.range n).foldl (fun acc j => acc + tL j) 0 =
          (List.range n).foldl (fun acc j => acc + (t1 j - t2 j)) 0 := by
      exact list_foldl_congr_mem
        (fun acc j => acc + tL j)
        (fun acc j => acc + (t1 j - t2 j))
        0
        (List.range n)
        (by
          intro acc j hjMem
          have hj : j < n := by simpa [List.mem_range] using hjMem
          exact congrArg (fun t => acc + t) (htermL j hj))
    have hfold := foldl_sub_linearity_F (l := List.range n) t1 t2 0 0
    have hzero : ((0 : F) - 0) = 0 := by
      exact (F.sub_eq_zero_iff (0 : F) 0).2 rfl
    have hfold0 :
        (List.range n).foldl (fun acc j => acc + (t1 j - t2 j)) 0 =
          (List.range n).foldl (fun acc j => acc + t1 j) 0 -
            (List.range n).foldl (fun acc j => acc + t2 j) 0 := by
      simpa [hzero] using hfold
    have hLeft :
        coeffAt (dotRq xs (subVec params.msgLen v1 v2)) i =
          (List.range n).foldl (fun acc j => acc + tL j) 0 := by
      have hSubSize : (subVec params.msgLen v1 v2).size = params.msgLen := by
        simp [subVec_size]
      calc
        coeffAt (dotRq xs (subVec params.msgLen v1 v2)) i
            = (List.range (Nat.min xs.size (subVec params.msgLen v1 v2).size)).foldl
                (fun acc j =>
                  acc + coeffAt (mulRq (xs.getD j zeroRq) ((subVec params.msgLen v1 v2).getD j zeroRq)) i)
                0 := coeffAt_dotRq xs (subVec params.msgLen v1 v2) i hi
        _ = (List.range n).foldl (fun acc j => acc + tL j) 0 := by
              simp [n, hSubSize, tL]
    have hRight1 :
        coeffAt (dotRq xs v1) i = (List.range n).foldl (fun acc j => acc + t1 j) 0 := by
      calc
        coeffAt (dotRq xs v1) i
            = (List.range (Nat.min xs.size v1.size)).foldl
                (fun acc j => acc + coeffAt (mulRq (xs.getD j zeroRq) (v1.getD j zeroRq)) i)
                0 := coeffAt_dotRq xs v1 i hi
        _ = (List.range n).foldl (fun acc j => acc + t1 j) 0 := by
              simp [n, hv1, t1]
    have hRight2 :
        coeffAt (dotRq xs v2) i = (List.range n).foldl (fun acc j => acc + t2 j) 0 := by
      calc
        coeffAt (dotRq xs v2) i
            = (List.range (Nat.min xs.size v2.size)).foldl
                (fun acc j => acc + coeffAt (mulRq (xs.getD j zeroRq) (v2.getD j zeroRq)) i)
                0 := coeffAt_dotRq xs v2 i hi
        _ = (List.range n).foldl (fun acc j => acc + t2 j) 0 := by
              simp [n, hv2, t2]
    have hmainCoeff :
        coeffAt (dotRq xs (subVec params.msgLen v1 v2)) i =
          coeffAt (subRq (dotRq xs v1) (dotRq xs v2)) i := by
      calc
        coeffAt (dotRq xs (subVec params.msgLen v1 v2)) i
            = (List.range n).foldl (fun acc j => acc + tL j) 0 := hLeft
        _ = (List.range n).foldl (fun acc j => acc + (t1 j - t2 j)) 0 := hleftFold
        _ = (List.range n).foldl (fun acc j => acc + t1 j) 0 -
              (List.range n).foldl (fun acc j => acc + t2 j) 0 := hfold0
        _ = coeffAt (dotRq xs v1) i - coeffAt (dotRq xs v2) i := by
              rw [hRight1, hRight2]
        _ = coeffAt (subRq (dotRq xs v1) (dotRq xs v2)) i := by
              symm
              exact coeffAt_subRq (dotRq xs v1) (dotRq xs v2) i hi
    have hiR : i < d := by simpa [subRq] using hi₂
    simpa [coeffAt, subRq, hi, hiR, Array.getD, hi₁, hi₂, dotRq_size] using hmainCoeff

set_option maxHeartbeats 800000 in
theorem subRq_eq_zero_of_shapes
  (x y : Coeffs)
  (hx : hasRingDegreeShape x)
  (hy : hasRingDegreeShape y)
  (hsub : subRq x y = zeroRq) :
  x = y := by
  apply Array.ext
  · exact hx.trans hy.symm
  · intro i hix hiy
    have hixd : i < d := by
      calc
        i < x.size := hix
        _ = d := hx
    have hiyd : i < d := by
      calc
        i < y.size := hiy
        _ = d := hy
    have hCoeffSub :
        coeffAt x i - coeffAt y i = (0 : F) := by
      have hEqCoeff :
          coeffAt (subRq x y) i = coeffAt zeroRq i := by
        simpa using congrArg (fun a => coeffAt a i) hsub
      calc
        coeffAt x i - coeffAt y i = coeffAt (subRq x y) i := by
          symm
          exact coeffAt_subRq x y i hixd
        _ = coeffAt zeroRq i := hEqCoeff
        _ = 0 := coeffAt_zeroRq i
    have hCoeff : coeffAt x i = coeffAt y i :=
      (F.sub_eq_zero_iff (coeffAt x i) (coeffAt y i)).1 hCoeffSub
    calc
      x[i]'hix = coeffAt x i := (get_eq_coeffAt_of_size_d x hx i hixd)
      _ = coeffAt y i := hCoeff
      _ = y[i]'hiy := (coeffAt_eq_get_of_size_d y hy i hiyd)

private theorem allRingDegreeShape_get_of_lt
  {v : Array Coeffs}
  (hShape : allRingDegreeShape v)
  {i : Nat}
  (hi : i < v.size) :
  hasRingDegreeShape (v[i]'hi) :=
  hShape ⟨i, hi⟩

private theorem allRingDegreeShape_smulVec
  (delta : Coeffs) (v : Array Coeffs) :
  allRingDegreeShape (smulVec delta v) := by
  intro i
  rcases i with ⟨idx, hidx⟩
  have hMap :
      (smulVec delta v)[idx]'hidx =
        mulRq delta (v[idx]'(by simpa [smulVec] using hidx)) := by
    simp [smulVec]
  unfold hasRingDegreeShape
  simpa [hMap, mulRq_size]

theorem subVec_ne_zero_of_ne
  (n : Nat) (v1 v2 : Array Coeffs) :
  v1.size = n →
  v2.size = n →
  allRingDegreeShape v1 →
  allRingDegreeShape v2 →
  v1 ≠ v2 →
  subVec n v1 v2 ≠ zeroVec n := by
  intro hv1 hv2 hShape1 hShape2 hNe hEq
  apply hNe
  apply Array.ext
  · simpa [hv1, hv2]
  · intro i hi1 hi2
    have hi : i < n := by simpa [hv1] using hi1
    have hi2' : i < v2.size := by simpa [hv2] using hi
    have hEntry :
        (subVec n v1 v2).getD i zeroRq = (zeroVec n).getD i zeroRq := by
      simpa using congrArg (fun a => a.getD i zeroRq) hEq
    have hSub : subRq (v1.getD i zeroRq) (v2.getD i zeroRq) = zeroRq := by
      have hSubVec :
          (subVec n v1 v2).getD i zeroRq =
            subRq (v1.getD i zeroRq) (v2.getD i zeroRq) :=
        subVec_getD_of_lt n v1 v2 i hi
      have hEq0 :
          subRq (v1.getD i zeroRq) (v2.getD i zeroRq) =
            (zeroVec n).getD i zeroRq := by
        exact hSubVec.symm.trans hEntry
      simpa [zeroVec, hi] using hEq0
    have hShapeI1 : hasRingDegreeShape (v1.getD i zeroRq) := by
      have hShapeAt : hasRingDegreeShape (v1[i]'hi1) := allRingDegreeShape_get_of_lt hShape1 hi1
      simpa [Array.getD, hi1] using hShapeAt
    have hShapeI2 : hasRingDegreeShape (v2.getD i zeroRq) := by
      have hShapeAt : hasRingDegreeShape (v2[i]'hi2') := allRingDegreeShape_get_of_lt hShape2 hi2'
      simpa [Array.getD, hi2'] using hShapeAt
    have hEqGet : v1.getD i zeroRq = v2.getD i zeroRq :=
      subRq_eq_zero_of_shapes _ _ hShapeI1 hShapeI2 hSub
    calc
      v1[i]'hi1 = v1.getD i zeroRq := by simp [Array.getD, hi1]
      _ = v2.getD i zeroRq := hEqGet
      _ = v2[i]'hi2 := by simp [Array.getD, hi2]

set_option maxHeartbeats 800000 in
theorem matVecMul_subVec
  {params : AjtaiParams}
  (matrixFlat : Array Coeffs)
  (v1 v2 : Array Coeffs)
  (hv1 : v1.size = params.msgLen)
  (hv2 : v2.size = params.msgLen) :
  matVecMul params matrixFlat (subVec params.msgLen v1 v2) =
    subVec params.kappa (matVecMul params matrixFlat v1) (matVecMul params matrixFlat v2) := by
  apply Array.ext
  · simp [matVecMul, subVec]
  · intro i hi1 hi2
    have hiK : i < params.kappa := by simpa [matVecMul] using hi1
    have hGet :
        (matVecMul params matrixFlat (subVec params.msgLen v1 v2)).getD i zeroRq =
          subRq
            ((matVecMul params matrixFlat v1).getD i zeroRq)
            ((matVecMul params matrixFlat v2).getD i zeroRq) := by
      calc
        (matVecMul params matrixFlat (subVec params.msgLen v1 v2)).getD i zeroRq
            = dotRq (matRow params.msgLen matrixFlat i) (subVec params.msgLen v1 v2) := by
                simp [matVecMul, Array.getD, hiK]
        _ = subRq (dotRq (matRow params.msgLen matrixFlat i) v1)
              (dotRq (matRow params.msgLen matrixFlat i) v2) := by
              exact dotRq_subVec_linearity (params := params)
                (matRow params.msgLen matrixFlat i) v1 v2 hv1 hv2
        _ = subRq
              ((matVecMul params matrixFlat v1).getD i zeroRq)
              ((matVecMul params matrixFlat v2).getD i zeroRq) := by
              simp [matVecMul, Array.getD, hiK]
    calc
      (matVecMul params matrixFlat (subVec params.msgLen v1 v2))[i]'hi1
          = (matVecMul params matrixFlat (subVec params.msgLen v1 v2)).getD i zeroRq := by
              simp [Array.getD, hi1]
      _ = subRq
            ((matVecMul params matrixFlat v1).getD i zeroRq)
            ((matVecMul params matrixFlat v2).getD i zeroRq) := hGet
      _ = (subVec params.kappa (matVecMul params matrixFlat v1) (matVecMul params matrixFlat v2)).getD i zeroRq := by
            simp [subVec, hiK]
      _ = (subVec params.kappa (matVecMul params matrixFlat v1) (matVecMul params matrixFlat v2))[i]'hi2 := by
            simp [Array.getD, hiK]

private theorem acc_le_foldl_max_of_fn
  {α : Type}
  (l : List α)
  (f : α → Nat)
  (acc : Nat) :
  acc ≤ l.foldl (fun a x => Nat.max a (f x)) acc := by
  induction l generalizing acc with
  | nil =>
      simp
  | cons a t ih =>
      have h₁ : acc ≤ Nat.max acc (f a) := Nat.le_max_left _ _
      have h₂ : Nat.max acc (f a) ≤ t.foldl (fun b x => Nat.max b (f x)) (Nat.max acc (f a)) :=
        ih (acc := Nat.max acc (f a))
      simpa [List.foldl] using Nat.le_trans h₁ h₂

private theorem le_foldl_max_of_mem_fn
  {α : Type}
  (l : List α)
  (f : α → Nat)
  (acc : Nat)
  (x : α)
  (hx : x ∈ l) :
  f x ≤ l.foldl (fun a y => Nat.max a (f y)) acc := by
  induction l generalizing acc with
  | nil =>
      cases hx
  | cons a t ih =>
      simp at hx
      rcases hx with hxa | hxt
      · subst hxa
        have h₁ : f x ≤ Nat.max acc (f x) := Nat.le_max_right _ _
        have h₂ : Nat.max acc (f x) ≤ t.foldl (fun b y => Nat.max b (f y)) (Nat.max acc (f x)) :=
          acc_le_foldl_max_of_fn t f (Nat.max acc (f x))
        simpa [List.foldl] using Nat.le_trans h₁ h₂
      · have hTail : f x ≤ t.foldl (fun b y => Nat.max b (f y)) (Nat.max acc (f a)) :=
          ih (acc := Nat.max acc (f a)) hxt
        simpa [List.foldl] using hTail

private theorem foldl_max_le_of_forall_le_fn
  {α : Type}
  (l : List α)
  (f : α → Nat)
  (acc m : Nat)
  (hAcc : acc ≤ m)
  (hAll : ∀ x ∈ l, f x ≤ m) :
  l.foldl (fun a y => Nat.max a (f y)) acc ≤ m := by
  induction l generalizing acc with
  | nil =>
      simpa using hAcc
  | cons a t ih =>
      have ha : f a ≤ m := hAll a (by simp)
      have hAcc' : Nat.max acc (f a) ≤ m := (Nat.max_le).2 ⟨hAcc, ha⟩
      have hAll' : ∀ x ∈ t, f x ≤ m := by
        intro x hx
        exact hAll x (by simp [hx])
      simpa [List.foldl] using ih (acc := Nat.max acc (f a)) hAcc' hAll'

private theorem normInfCoeffs_le_normInfVec_of_mem
  {v : Array Coeffs} {x : Coeffs}
  (hx : x ∈ v.toList) :
  normInfCoeffs x ≤ normInfVec v := by
  unfold normInfVec
  rw [← Array.foldl_toList]
  exact le_foldl_max_of_mem_fn v.toList normInfCoeffs 0 x hx

private theorem normInfVec_smulVec_le_of_diff
  {params : AjtaiParams}
  (laws : LatticeReductionLaws params)
  (delta : Coeffs)
  (v : Array Coeffs)
  (B : Nat)
  (hδ : samplingDiffSet laws.samplingCarrier delta)
  (hB : normInfVec v ≤ B) :
  normInfVec (smulVec delta v) ≤ 4 * params.relaxedExpansion * B := by
  unfold normInfVec smulVec
  rw [← Array.foldl_toList, Array.toList_map]
  refine foldl_max_le_of_forall_le_fn
    (l := v.toList.map (fun x => mulRq delta x))
    (f := normInfCoeffs)
    (acc := 0)
    (m := 4 * params.relaxedExpansion * B)
    (by exact Nat.zero_le _)
    ?_
  intro x hx
  rcases List.mem_map.mp hx with ⟨z, hzMem, rfl⟩
  have hzNorm : normInfCoeffs z ≤ B := by
    exact Nat.le_trans (normInfCoeffs_le_normInfVec_of_mem hzMem) hB
  exact laws.strongSampling delta hδ z B hzNorm

/-- Norm-transfer boundary for extracted witness from a standard binding collision. -/
theorem bindingCollision_subWitness_norm_lt_msisNormBound
  {params : AjtaiParams}
  (laws : LatticeReductionLaws params)
  (hExpPos : 0 < params.relaxedExpansion)
  (coll : BindingCollision params) :
  normInfVec (subVec params.msgLen coll.opening1.witness coll.opening2.witness) <
    params.msisNormBound := by
  rcases coll.opens1 with ⟨_hCwf1, _hOwf1, hNs1, _hEq1⟩
  rcases coll.opens2 with ⟨_hCwf2, _hOwf2, hNs2, _hEq2⟩

  have hSubLe :
    normInfVec (subVec params.msgLen coll.opening1.witness coll.opening2.witness) ≤
      coll.opening1.normBound + coll.opening2.normBound := by
    have h :=
      laws.normInfVec_subVec_le (n := params.msgLen)
        coll.opening1.witness coll.opening2.witness
    exact Nat.le_trans h (Nat.add_le_add hNs1 hNs2)

  have hSumLt :
      coll.opening1.normBound + coll.opening2.normBound <
        params.bindingNormBound + params.bindingNormBound :=
    Nat.add_lt_add coll.bounded1 coll.bounded2

  have hLtBB :
      normInfVec (subVec params.msgLen coll.opening1.witness coll.opening2.witness) <
        params.bindingNormBound + params.bindingNormBound :=
    Nat.lt_of_le_of_lt hSubLe hSumLt

  have h1le : 1 ≤ params.relaxedExpansion :=
    Nat.succ_le_of_lt hExpPos

  have h8le : 8 ≤ 8 * params.relaxedExpansion := by
    simpa using (Nat.mul_le_mul_left 8 h1le)

  have h2le8 : (2 : Nat) ≤ 8 := by decide
  have h2le : (2 : Nat) ≤ 8 * params.relaxedExpansion :=
    Nat.le_trans h2le8 h8le

  have hBBLe : params.bindingNormBound + params.bindingNormBound ≤ params.msisNormBound := by
    unfold AjtaiParams.msisNormBound
    have h := Nat.mul_le_mul_right params.bindingNormBound h2le
    simpa [Nat.two_mul, Nat.mul_assoc] using h

  exact Nat.lt_of_lt_of_le hLtBB hBBLe

/-- Norm-transfer boundary for extracted witness from a relaxed binding collision. -/
theorem relaxedBindingCollision_subWitness_norm_lt_msisNormBound
  {params : AjtaiParams}
  (laws : LatticeReductionLaws params)
  (hExpPos : 0 < params.relaxedExpansion)
  (coll : RelaxedBindingCollision params) :
  normInfVec
      (subVec params.msgLen
        (smulVec coll.delta1 coll.opening2.witness)
        (smulVec coll.delta2 coll.opening1.witness)) <
    params.msisNormBound := by
  rcases coll.opens1 with ⟨_hCwf1, _hOwf1, hNs1, _hEq1⟩
  rcases coll.opens2 with ⟨_hCwf2, _hOwf2, hNs2, _hEq2⟩

  have h4pos : 0 < (4 : Nat) := by decide
  have hPos : 0 < 4 * params.relaxedExpansion :=
    Nat.mul_pos h4pos hExpPos

  let w1 := smulVec coll.delta1 coll.opening2.witness
  let w2 := smulVec coll.delta2 coll.opening1.witness

  have hδ1Diff :
      samplingDiffSet laws.samplingCarrier coll.delta1 :=
    laws.deltaInDiff_of_deltaBound coll.delta1 coll.deltaBound1
  have hδ2Diff :
      samplingDiffSet laws.samplingCarrier coll.delta2 :=
    laws.deltaInDiff_of_deltaBound coll.delta2 coll.deltaBound2

  have hw1_le :
      normInfVec w1 ≤ (4 * params.relaxedExpansion) * coll.opening2.normBound :=
    by
      simpa [w1] using
        normInfVec_smulVec_le_of_diff
          (params := params)
          laws
          coll.delta1
          coll.opening2.witness
          coll.opening2.normBound
          hδ1Diff
          hNs2

  have hw2_le :
      normInfVec w2 ≤ (4 * params.relaxedExpansion) * coll.opening1.normBound := by
    simpa [w2] using
      normInfVec_smulVec_le_of_diff
        (params := params)
        laws
        coll.delta2
        coll.opening1.witness
        coll.opening1.normBound
        hδ2Diff
        hNs1

  have hsub_le :
      normInfVec (subVec params.msgLen w1 w2) ≤ normInfVec w1 + normInfVec w2 :=
    laws.normInfVec_subVec_le (n := params.msgLen) w1 w2

  have htotal_le :
      normInfVec (subVec params.msgLen w1 w2) ≤
        (4 * params.relaxedExpansion) * coll.opening2.normBound +
        (4 * params.relaxedExpansion) * coll.opening1.normBound := by
    exact Nat.le_trans hsub_le (Nat.add_le_add hw1_le hw2_le)

  have h1lt :
      (4 * params.relaxedExpansion) * coll.opening2.normBound <
        (4 * params.relaxedExpansion) * params.bindingNormBound :=
    Nat.mul_lt_mul_of_pos_left coll.bounded2 hPos

  have h2lt :
      (4 * params.relaxedExpansion) * coll.opening1.normBound <
        (4 * params.relaxedExpansion) * params.bindingNormBound :=
    Nat.mul_lt_mul_of_pos_left coll.bounded1 hPos

  have hsumlt :
      (4 * params.relaxedExpansion) * coll.opening2.normBound +
      (4 * params.relaxedExpansion) * coll.opening1.normBound <
      (4 * params.relaxedExpansion) * params.bindingNormBound +
      (4 * params.relaxedExpansion) * params.bindingNormBound :=
    Nat.add_lt_add h1lt h2lt

  have hlt :
      normInfVec (subVec params.msgLen w1 w2) <
      (4 * params.relaxedExpansion) * params.bindingNormBound +
      (4 * params.relaxedExpansion) * params.bindingNormBound :=
    Nat.lt_of_le_of_lt htotal_le hsumlt

  have hRhs :
      (4 * params.relaxedExpansion) * params.bindingNormBound +
      (4 * params.relaxedExpansion) * params.bindingNormBound =
      params.msisNormBound := by
    unfold AjtaiParams.msisNormBound
    calc
      (4 * params.relaxedExpansion) * params.bindingNormBound +
          (4 * params.relaxedExpansion) * params.bindingNormBound
          = 2 * ((4 * params.relaxedExpansion) * params.bindingNormBound) := by
              simpa using
                (Eq.symm (Nat.two_mul ((4 * params.relaxedExpansion) * params.bindingNormBound)))
      _ = (2 * (4 * params.relaxedExpansion)) * params.bindingNormBound := by
              simp [Nat.mul_assoc]
      _ = (8 * params.relaxedExpansion) * params.bindingNormBound := by
              simp [Nat.mul_left_comm, Nat.mul_comm]
      _ = 8 * params.relaxedExpansion * params.bindingNormBound := by
              simp [Nat.mul_assoc]

  exact lt_of_lt_of_eq hlt hRhs

/--
Extractor: a standard Ajtai binding collision yields a homogeneous MSIS witness.
-/
theorem msisBreakEvent_of_bindingCollision
  {params : AjtaiParams}
  (laws : LatticeReductionLaws params)
  (hExpPos : 0 < params.relaxedExpansion)
  (coll : BindingCollision params) :
  MSISBreakEvent params := by
  rcases coll.opens1 with ⟨hCwf1, hOwf1, _hNs1, hEq1⟩
  rcases coll.opens2 with ⟨_hCwf2, hOwf2, _hNs2, hEq2⟩
  let chal : MSISChallenge params :=
    ⟨Commitment.ppMatrixFlat params coll.commitment, zeroVec params.kappa⟩
  refine ⟨chal, rfl, ?_⟩
  let w := subVec params.msgLen coll.opening1.witness coll.opening2.witness
  refine ⟨{
    witness := w
    bounded := ?_
    satisfies := ?_
  }⟩
  · refine ⟨by simp [w], ?_, ?_⟩
    · have hwNeZero :
        subVec params.msgLen coll.opening1.witness coll.opening2.witness ≠
          zeroVec params.msgLen := by
        exact subVec_ne_zero_of_ne params.msgLen coll.opening1.witness coll.opening2.witness
          hOwf1.1
          hOwf2.1
          hOwf1.2
          hOwf2.2
          coll.distinct
      simpa [w, zeroVec] using hwNeZero
    · simpa [w] using
        bindingCollision_subWitness_norm_lt_msisNormBound (params := params) laws hExpPos coll
  · refine ⟨?_, ?_⟩
    · refine ⟨?_, ?_⟩
      · exact Commitment.ppMatrixFlat_size_of_wf (params := params) (c := coll.commitment) hCwf1
      · simp [chal, zeroVec]
    · calc
        matVecMul params chal.matrix w
            = subVec params.kappa
                (matVecMul params chal.matrix coll.opening1.witness)
                (matVecMul params chal.matrix coll.opening2.witness) := by
                simpa [w] using
                  matVecMul_subVec (params := params) chal.matrix coll.opening1.witness coll.opening2.witness
                    hOwf1.1
                    hOwf2.1
        _ = subVec params.kappa
              (Commitment.valueVec params coll.commitment)
              (Commitment.valueVec params coll.commitment) := by
              simp [chal, hEq1, hEq2]
        _ = zeroVec params.kappa := by
              simpa using subVec_self params.kappa (Commitment.valueVec params coll.commitment)
        _ = chal.target := by
              rfl

/--
Extractor: a relaxed Ajtai binding collision yields a homogeneous MSIS witness.
-/
theorem msisBreakEvent_of_relaxedBindingCollision
  {params : AjtaiParams}
  (laws : LatticeReductionLaws params)
  (hExpPos : 0 < params.relaxedExpansion)
  (coll : RelaxedBindingCollision params) :
  MSISBreakEvent params := by
  rcases coll.opens1 with ⟨hCwf1, hOwf1, _hNs1, hEq1⟩
  rcases coll.opens2 with ⟨_hCwf2, hOwf2, _hNs2, hEq2⟩
  let chal : MSISChallenge params :=
    ⟨Commitment.ppMatrixFlat params coll.commitment, zeroVec params.kappa⟩
  refine ⟨chal, rfl, ?_⟩
  let w1 := smulVec coll.delta1 coll.opening2.witness
  let w2 := smulVec coll.delta2 coll.opening1.witness
  let w := subVec params.msgLen w1 w2
  refine ⟨{
    witness := w
    bounded := ?_
    satisfies := ?_
  }⟩
  · refine ⟨by simp [w], ?_, ?_⟩
    · have hwNeZero : subVec params.msgLen w1 w2 ≠ zeroVec params.msgLen := by
        have hw1Size : w1.size = params.msgLen := by
          simpa [w1, smulVec] using hOwf2.1
        have hw2Size : w2.size = params.msgLen := by
          simpa [w2, smulVec] using hOwf1.1
        exact subVec_ne_zero_of_ne params.msgLen w1 w2
          hw1Size
          hw2Size
          (by simpa [w1] using allRingDegreeShape_smulVec coll.delta1 coll.opening2.witness)
          (by simpa [w2] using allRingDegreeShape_smulVec coll.delta2 coll.opening1.witness)
          (by simpa [w1, w2] using coll.distinct)
      simpa [w, zeroVec] using hwNeZero
    · simpa [w, w1, w2] using
        relaxedBindingCollision_subWitness_norm_lt_msisNormBound (params := params) laws hExpPos coll
  · refine ⟨?_, ?_⟩
    · refine ⟨?_, ?_⟩
      · exact Commitment.ppMatrixFlat_size_of_wf (params := params) (c := coll.commitment) hCwf1
      · simp [chal, zeroVec]
    · calc
        matVecMul params chal.matrix w
            = subVec params.kappa
                (matVecMul params chal.matrix w1)
                (matVecMul params chal.matrix w2) := by
                simpa [w] using matVecMul_subVec (params := params) chal.matrix w1 w2
                  (by simpa [w1, smulVec] using hOwf2.1)
                  (by simpa [w2, smulVec] using hOwf1.1)
        _ = subVec params.kappa
              (smulVec coll.delta1 (matVecMul params chal.matrix coll.opening2.witness))
              (smulVec coll.delta2 (matVecMul params chal.matrix coll.opening1.witness)) := by
              simp [w1, w2, matVecMul_smulVec_derived (params := params) laws]
        _ = subVec params.kappa
              (smulVec coll.delta1 (smulVec coll.delta2 (Commitment.valueVec params coll.commitment)))
              (smulVec coll.delta2 (smulVec coll.delta1 (Commitment.valueVec params coll.commitment))) := by
              simp [chal, hEq1, hEq2]
        _ = subVec params.kappa
              (smulVec coll.delta2 (smulVec coll.delta1 (Commitment.valueVec params coll.commitment)))
              (smulVec coll.delta2 (smulVec coll.delta1 (Commitment.valueVec params coll.commitment))) := by
              simp [laws.smulVec_comm]
        _ = zeroVec params.kappa := by
              simpa using
                subVec_self params.kappa
                  (smulVec coll.delta2 (smulVec coll.delta1 (Commitment.valueVec params coll.commitment)))
        _ = chal.target := by
              rfl

/-- Truth-valued probability model: `Pr P = 1` iff `P`, else `0`. -/
noncomputable def truthProb : ProbModel where
  Pr := fun P => by
    classical
    exact if P then (1 : Rat) else 0
  prNonneg := by
    intro P
    classical
    by_cases hP : P
    · simp [hP]
      exact (by decide : (0 : Rat) ≤ 1)
    · simp [hP]
      exact (by decide : (0 : Rat) ≤ 0)
  prLeOne := by
    intro P
    classical
    by_cases hP : P
    · simp [hP]
      exact (by decide : (1 : Rat) ≤ 1)
    · simp [hP]
      exact (by decide : (0 : Rat) ≤ 1)

/--
Under the current eventually-zero negligible model, MSIS hardness implies the
canonical homogeneous MSIS break event is impossible.
-/
theorem no_msisBreakEvent_of_hardness
  {params : AjtaiParams}
  (h : MSISHardnessAssumption params) :
  ¬ MSISBreakEvent params := by
  rcases h with ⟨eps, hNeg, hBound⟩
  rcases hNeg 0 with ⟨N, hZero⟩
  have hEps0 : eps N = 0 := hZero N (Nat.le_refl N)
  intro hBreak
  have hLe :
      MSISAdvantage truthProb (canonicalMSISGame params) N ≤ (eps N : Rat) :=
    hBound truthProb N
  have hAdvOne :
      MSISAdvantage truthProb (canonicalMSISGame params) N = (1 : Rat) := by
    classical
    simp [MSISAdvantage, canonicalMSISGame, truthProb, hBreak]
  have hOneLe : (1 : Rat) ≤ (eps N : Rat) := by
    simpa [hAdvOne] using hLe
  have hOneLeZero : (1 : Rat) ≤ 0 := by
    simpa [hEps0] using hOneLe
  exact (by decide : ¬ ((1 : Rat) ≤ 0)) hOneLeZero

/--
Under the current eventually-zero negligible model, an Ajtai binding-advantage
bound implies no binding collision can exist.
-/
theorem no_ajtaiBindingCollision_of_advantageBound
  {params : AjtaiParams}
  {eps : ErrorFn}
  (hBound : AjtaiBindingAdvantageBound params eps)
  (hNeg : IsNegligible eps) :
  AjtaiBindingAssumption params := by
  rcases hNeg 0 with ⟨N, hZero⟩
  have hEps0 : eps N = 0 := hZero N (Nat.le_refl N)
  intro hColl
  have hLe :
      AjtaiBindingAdvantage truthProb (canonicalAjtaiBindingGame params) N ≤ (eps N : Rat) :=
    hBound truthProb N
  have hAdvOne :
      AjtaiBindingAdvantage truthProb (canonicalAjtaiBindingGame params) N = (1 : Rat) := by
    classical
    simp [AjtaiBindingAdvantage, canonicalAjtaiBindingGame, truthProb, hColl]
  have hOneLe : (1 : Rat) ≤ (eps N : Rat) := by
    simpa [hAdvOne] using hLe
  have hOneLeZero : (1 : Rat) ≤ 0 := by
    simpa [hEps0] using hOneLe
  exact (by decide : ¬ ((1 : Rat) ≤ 0)) hOneLeZero

/--
Under the current eventually-zero negligible model, an Ajtai relaxed-binding
advantage bound implies no relaxed binding collision can exist.
-/
theorem no_ajtaiRelaxedBindingCollision_of_advantageBound
  {params : AjtaiParams}
  {eps : ErrorFn}
  (hBound : AjtaiRelaxedBindingAdvantageBound params eps)
  (hNeg : IsNegligible eps) :
  AjtaiRelaxedBindingAssumption params := by
  rcases hNeg 0 with ⟨N, hZero⟩
  have hEps0 : eps N = 0 := hZero N (Nat.le_refl N)
  intro hColl
  have hLe :
      AjtaiRelaxedBindingAdvantage truthProb (canonicalAjtaiRelaxedBindingGame params) N ≤ (eps N : Rat) :=
    hBound truthProb N
  have hAdvOne :
      AjtaiRelaxedBindingAdvantage truthProb (canonicalAjtaiRelaxedBindingGame params) N = (1 : Rat) := by
    classical
    simp [AjtaiRelaxedBindingAdvantage, canonicalAjtaiRelaxedBindingGame, truthProb, hColl]
  have hOneLe : (1 : Rat) ≤ (eps N : Rat) := by
    simpa [hAdvOne] using hLe
  have hOneLeZero : (1 : Rat) ≤ 0 := by
    simpa [hEps0] using hOneLe
  exact (by decide : ¬ ((1 : Rat) ≤ 0)) hOneLeZero

namespace AjtaiBindingBoundary

/-- Canonical hardness view for an Ajtai binding boundary package. -/
def hardness
  {params : AjtaiParams}
  (h : AjtaiBindingBoundary params) : AjtaiBindingAssumption params :=
  no_ajtaiBindingCollision_of_advantageBound h.advantageBound h.negligibleEpsBinding

/-- Canonical hardness derivation from package fields. -/
theorem hardnessFromFields
  {params : AjtaiParams}
  (h : AjtaiBindingBoundary params) : AjtaiBindingAssumption params :=
  h.hardness

/-- Normalize any package by overwriting redundant `hardness` proof from aligned fields. -/
def normalize
  {params : AjtaiParams}
  (h : AjtaiBindingBoundary params) : AjtaiBindingBoundary params :=
  h

theorem normalize_hardnessFromFields
  {params : AjtaiParams}
  (h : AjtaiBindingBoundary params) :
  (normalize h).hardness = h.hardnessFromFields := by
  rfl

end AjtaiBindingBoundary

namespace AjtaiRelaxedBindingBoundary

/-- Canonical hardness view for an Ajtai relaxed-binding boundary package. -/
def hardness
  {params : AjtaiParams}
  (h : AjtaiRelaxedBindingBoundary params) : AjtaiRelaxedBindingAssumption params :=
  no_ajtaiRelaxedBindingCollision_of_advantageBound h.advantageBound h.negligibleEpsRelaxedBinding

/-- Canonical relaxed-hardness derivation from package fields. -/
theorem hardnessFromFields
  {params : AjtaiParams}
  (h : AjtaiRelaxedBindingBoundary params) : AjtaiRelaxedBindingAssumption params :=
  h.hardness

/-- Normalize any relaxed package by overwriting redundant `hardness` proof from aligned fields. -/
def normalize
  {params : AjtaiParams}
  (h : AjtaiRelaxedBindingBoundary params) : AjtaiRelaxedBindingBoundary params :=
  h

theorem normalize_hardnessFromFields
  {params : AjtaiParams}
  (h : AjtaiRelaxedBindingBoundary params) :
  (normalize h).hardness = h.hardnessFromFields := by
  rfl

end AjtaiRelaxedBindingBoundary

/--
Abstract reduction interface from MSIS hardness to Ajtai commitment security.
This remains theorem-facing only; implication theorems are derived below.
-/
structure MSISToAjtaiReductions (params : AjtaiParams) where
  laws : LatticeReductionLaws params
  relaxedExpansionPos : 0 < params.relaxedExpansion
  epsBinding : ErrorFn
  epsRelaxedBinding : ErrorFn
  bindingAdvantageBound : AjtaiBindingAdvantageBound params epsBinding
  relaxedBindingAdvantageBound : AjtaiRelaxedBindingAdvantageBound params epsRelaxedBinding
  negligibleEpsBinding : IsNegligible epsBinding
  negligibleEpsRelaxedBinding : IsNegligible epsRelaxedBinding

namespace MSISToAjtaiReductions

/-- Derived Ajtai binding boundary from MSIS hardness, via explicit extractor. -/
theorem toBinding
  {params : AjtaiParams}
  (hRed : MSISToAjtaiReductions params)
  (hMsis : MSISHardnessAssumption params) :
  AjtaiBindingAssumption params := by
  intro hColl
  rcases hColl with ⟨coll⟩
  have hBreak : MSISBreakEvent params :=
    msisBreakEvent_of_bindingCollision (params := params) hRed.laws hRed.relaxedExpansionPos coll
  exact (no_msisBreakEvent_of_hardness (params := params) hMsis) hBreak

/-- Derived Ajtai relaxed-binding boundary from MSIS hardness, via explicit extractor. -/
theorem toRelaxedBinding
  {params : AjtaiParams}
  (hRed : MSISToAjtaiReductions params)
  (hMsis : MSISHardnessAssumption params) :
  AjtaiRelaxedBindingAssumption params := by
  intro hColl
  rcases hColl with ⟨coll⟩
  have hBreak : MSISBreakEvent params :=
    msisBreakEvent_of_relaxedBindingCollision (params := params) hRed.laws hRed.relaxedExpansionPos coll
  exact (no_msisBreakEvent_of_hardness (params := params) hMsis) hBreak

end MSISToAjtaiReductions

/-- Derive Ajtai binding from MSIS via the declared reduction surface. -/
theorem ajtaiBinding_of_msis
  {params : AjtaiParams}
  (hRed : MSISToAjtaiReductions params)
  (hMsis : MSISHardnessAssumption params) :
  AjtaiBindingAssumption params := by
  exact hRed.toBinding hMsis

/-- Derive Ajtai relaxed binding from MSIS via the declared reduction surface. -/
theorem ajtaiRelaxedBinding_of_msis
  {params : AjtaiParams}
  (hRed : MSISToAjtaiReductions params)
  (hMsis : MSISHardnessAssumption params) :
  AjtaiRelaxedBindingAssumption params := by
  exact hRed.toRelaxedBinding hMsis

/-- Package both Ajtai boundaries derived from MSIS under one reduction interface. -/
theorem ajtaiBoundaries_of_msis
  {params : AjtaiParams}
  (hRed : MSISToAjtaiReductions params)
  (hMsis : MSISHardnessAssumption params) :
  AjtaiBindingAssumption params ∧ AjtaiRelaxedBindingAssumption params := by
  exact ⟨ajtaiBinding_of_msis hRed hMsis, ajtaiRelaxedBinding_of_msis hRed hMsis⟩

/-- Build the canonical Ajtai binding boundary package from MSIS hardness + reduction surface. -/
def ajtaiBindingBoundary_of_msis
  {params : AjtaiParams}
  (hRed : MSISToAjtaiReductions params)
  (_hMsis : MSISHardnessAssumption params) :
  AjtaiBindingBoundary params where
  epsBinding := hRed.epsBinding
  advantageBound := hRed.bindingAdvantageBound
  negligibleEpsBinding := hRed.negligibleEpsBinding

/-- Build the canonical Ajtai relaxed-binding boundary package from MSIS hardness + reduction surface. -/
def ajtaiRelaxedBindingBoundary_of_msis
  {params : AjtaiParams}
  (hRed : MSISToAjtaiReductions params)
  (_hMsis : MSISHardnessAssumption params) :
  AjtaiRelaxedBindingBoundary params where
  epsRelaxedBinding := hRed.epsRelaxedBinding
  advantageBound := hRed.relaxedBindingAdvantageBound
  negligibleEpsRelaxedBinding := hRed.negligibleEpsRelaxedBinding

end SuperNeo.ProofSystem
