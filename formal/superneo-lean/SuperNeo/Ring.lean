import SuperNeo.Field
import SuperNeo.Dimensions
import Init.Data.List.Perm
import Init.Data.List.Range
import Init.Data.List.Nat.Range
import Init.Data.Nat.Div.Basic
import Init.Data.Nat.Lemmas
import Init.GrindInstances.Ring.Fin

namespace SuperNeo

open F
local instance : NeZero Goldilocks.q := ⟨Nat.ne_of_gt Goldilocks.q_pos⟩

/-- Coefficient vector representation for ring elements. -/
abbrev Coeffs := Array F

def D : Nat := d

/-- Canonical ring-degree shape predicate for coefficient vectors. -/
def hasRingDegreeShape (a : Coeffs) : Prop :=
  a.size = d

/-- Shape precondition bundle for ring multiplication inputs. -/
def ringMulShapeProp (a b : Coeffs) : Prop :=
  hasRingDegreeShape a ∧ hasRingDegreeShape b


def vecAdd (a b : Array F) : Array F :=
  if h : a.size = b.size then
    Array.ofFn (fun i : Fin a.size =>
      a[i.1]'i.2 + b[i.1]'(by simpa [h] using i.2))
  else
    #[]

def vecScale (s : F) (a : Array F) : Array F :=
  a.map (fun x => s * x)

def linComb2Vec (ρ1 ρ2 : F) (z1 z2 : Array F) : Array F :=
  vecAdd (vecScale ρ1 z1) (vecScale ρ2 z2)

def ct (a : Coeffs) : F :=
  a.getD 0 0

def coeffAt (a : Coeffs) (i : Nat) : F :=
  if i < d then a.getD i 0 else 0

/--
Schoolbook-style cyclic multiplication skeleton modulo `d`.

This is a minimal executable kernel for early theorem work; quotient-specific
identities are layered later.
-/
def mulRq (a b : Coeffs) : Coeffs :=
  Array.ofFn (fun i : Fin d =>
    (List.range d).foldl
      (fun acc j =>
        let k := (i.1 + d - j) % d
        acc + coeffAt a j * coeffAt b k)
      0)

/-- Compact bar-block placeholder used by executable cross-check harnesses. -/
def superneoBarBlock (_bar : Array (Array F)) (a : Array F) : Coeffs :=
  a

def zeroRq : Coeffs :=
  Array.replicate d 0

def oneRq : Coeffs :=
  (Array.replicate d 0).set! 0 1

@[simp] theorem vecScale_size (s : F) (a : Array F) :
    (vecScale s a).size = a.size := by
  simp [vecScale]

theorem vecAdd_size_of_eq {a b : Array F} (h : a.size = b.size) :
    (vecAdd a b).size = a.size := by
  simp [vecAdd, h]

theorem vecAdd_size_of_ne {a b : Array F} (h : a.size ≠ b.size) :
    (vecAdd a b).size = 0 := by
  simp [vecAdd, h]

theorem linComb2Vec_size_of_eq
    {ρ1 ρ2 : F} {z1 z2 : Array F} (h : z1.size = z2.size) :
    (linComb2Vec ρ1 ρ2 z1 z2).size = z1.size := by
  unfold linComb2Vec
  simp [vecScale_size, vecAdd_size_of_eq, h]

theorem mulRq_size (a b : Coeffs) : (mulRq a b).size = d := by
  simp [mulRq]

private theorem map_rotate_range_eq
  (r : Nat)
  (hr : r < d) :
  List.map (fun j => (r + j) % d) (List.range d) =
    List.range' r (d - r) ++ List.range r := by
  have hle : r ≤ d := Nat.le_of_lt hr
  have hsplit :
      List.range d =
        List.range (d - r) ++ (List.range r).map ((d - r) + ·) := by
    have h := List.range_add (n := d - r) (m := r)
    simpa [Nat.sub_add_cancel hle] using h
  rw [hsplit, List.map_append]
  have hpart1 :
      List.map (fun j => (r + j) % d) (List.range (d - r)) =
        List.range' r (d - r) := by
    have hmap :
        List.map (fun j => (r + j) % d) (List.range (d - r)) =
          List.map (fun j => r + j) (List.range (d - r)) := by
      apply List.map_congr_left
      intro a ha
      have haLt : a < d - r := by simpa [List.mem_range] using ha
      have hlt : r + a < d := by omega
      simp [Nat.mod_eq_of_lt hlt]
    calc
      List.map (fun j => (r + j) % d) (List.range (d - r))
          = List.map (fun j => r + j) (List.range (d - r)) := hmap
      _ = List.range' r (d - r) := by
            symm
            simpa using (List.range'_eq_map_range (s := r) (n := d - r))
  have hpart2 :
      List.map (fun x => (r + ((d - r) + x)) % d) (List.range r) =
        List.range r := by
    calc
      List.map (fun x => (r + ((d - r) + x)) % d) (List.range r)
          = List.map (fun x => x) (List.range r) := by
            apply List.map_congr_left
            intro a ha
            have haLt : a < r := by simpa [List.mem_range] using ha
            have had : a < d := Nat.lt_trans haLt hr
            have hrd : r + ((d - r) + a) = d + a := by omega
            simp [hrd, Nat.mod_eq_of_lt had]
      _ = List.range r := by simp
  simpa [hpart1, hpart2]

private theorem perm_rotate_range
  (r : Nat)
  (hr : r < d) :
  List.Perm (List.map (fun j => (r + j) % d) (List.range d)) (List.range d) := by
  rw [map_rotate_range_eq r hr]
  have hle : r ≤ d := Nat.le_of_lt hr
  have hsplit : List.range d = List.range r ++ List.range' r (d - r) := by
    have h := List.range_add (n := r) (m := d - r)
    simpa [Nat.add_sub_cancel' hle, List.range'_eq_map_range] using h
  exact (List.perm_append_comm (l₁ := List.range' r (d-r)) (l₂ := List.range r)).trans
    (List.Perm.of_eq hsplit.symm)

private theorem perm_modSub_range
  (i : Nat) :
  List.Perm
    (List.map (fun j => (i + d - j) % d) (List.range d))
    (List.range d) := by
  let r : Nat := (i + 1) % d
  have hr : r < d := by
    dsimp [r]
    exact Nat.mod_lt _ d_pos
  have hsubToRev :
      List.map (fun j => (i + d - j) % d) (List.range d) =
        List.map (fun x => (r + x) % d) (List.reverse (List.range d)) := by
    have hmapSub :
        List.map (fun j => (i + d - j) % d) (List.range d) =
          List.map (fun j => (r + (d - 1 - j)) % d) (List.range d) := by
      apply List.map_congr_left
      intro a ha
      have haLt : a < d := by simpa [List.mem_range] using ha
      have hEq₁ : i + d - a = (i + 1) + (d - 1 - a) := by omega
      calc
        (i + d - a) % d
            = ((i + 1) + (d - 1 - a)) % d := by simp [hEq₁]
        _ = (((i + 1) % d) + (d - 1 - a)) % d := by
              simpa using (Nat.add_mod (i + 1) (d - 1 - a) d)
        _ = (r + (d - 1 - a)) % d := by
              simp [r]
    have hrev :
        List.map (fun j => d - 1 - j) (List.range d) = List.reverse (List.range d) := by
      simpa [List.range_eq_range', Nat.zero_add] using
        (List.reverse_range' (s := 0) (n := d)).symm
    calc
      List.map (fun j => (i + d - j) % d) (List.range d)
          = List.map (fun j => (r + (d - 1 - j)) % d) (List.range d) := hmapSub
      _ = List.map (fun x => (r + x) % d) (List.map (fun j => d - 1 - j) (List.range d)) := by
            simp [List.map_map]
      _ = List.map (fun x => (r + x) % d) (List.reverse (List.range d)) := by
            simp [hrev]
  have hPerm1 :
      List.Perm
        (List.map (fun x => (r + x) % d) (List.reverse (List.range d)))
        (List.map (fun x => (r + x) % d) (List.range d)) :=
    (List.reverse_perm (l := List.range d)).map _
  have hPerm2 :
      List.Perm (List.map (fun x => (r + x) % d) (List.range d)) (List.range d) :=
    perm_rotate_range r hr
  exact (List.Perm.of_eq hsubToRev).trans (hPerm1.trans hPerm2)

private theorem mod_sub_involutive
  (i j : Nat)
  (hj : j < d) :
  ((i + d - ((i + d - j) % d)) % d) = j := by
  let x := i + d - j
  let q := x / d
  let t := x % d
  have hx : t + d * q = x := by
    simp [x, q, t, Nat.mod_add_div]
  have hEq : i + d - t = j + d * q := by
    have : i + d - j = t + d * q := by
      simpa [x, q, t] using hx.symm
    omega
  have hEq2 : i + d - ((i + d - j) % d) = j + d * q := by
    simpa [x, t] using hEq
  calc
    ((i + d - ((i + d - j) % d)) % d)
        = ((j + d * q) % d) := by simp [hEq2]
    _ = j % d := by
          simpa [Nat.add_comm, Nat.add_left_comm, Nat.add_assoc] using
            (Nat.add_mul_mod_self_left j q d)
    _ = j := Nat.mod_eq_of_lt hj

private theorem list_foldl_congr_mem
  {α β : Type}
  (f g : α → β → α)
  (init : α)
  (l : List β)
  (hfg : ∀ acc b, b ∈ l → f acc b = g acc b) :
  List.foldl f init l = List.foldl g init l := by
  induction l generalizing init with
  | nil => simp
  | cons b bs ih =>
      have hHead : f init b = g init b := by
        exact hfg init b (by simp)
      calc
        List.foldl f init (b :: bs)
            = List.foldl f (f init b) bs := by rfl
        _ = List.foldl f (g init b) bs := by rw [hHead]
        _ = List.foldl g (g init b) bs := by
              apply ih
              intro acc b' hb'
              exact hfg acc b' (by simp [hb'])
        _ = List.foldl g init (b :: bs) := by rfl

private theorem f_right_distrib (a b c : F) : (a + b) * c = a * c + b * c := by
  calc
    (a + b) * c = c * (a + b) := by
      simpa using (Lean.Grind.Fin.mul_comm (n := Goldilocks.q) (a + b) c)
    _ = c * a + c * b := by
      simpa using (Lean.Grind.Fin.left_distrib (n := Goldilocks.q) c a b)
    _ = a * c + b * c := by
      simp [Lean.Grind.Fin.mul_comm]

private theorem f_mul_zero (a : F) : a * 0 = 0 := by
  calc
    a * 0 = 0 * a := by
      simpa using (Lean.Grind.Fin.mul_comm (n := Goldilocks.q) a 0)
    _ = 0 := by
      simpa using (Lean.Grind.Fin.zero_mul (n := Goldilocks.q) a)

private theorem f_add_left_comm (a b c : F) : a + (b + c) = b + (a + c) := by
  calc
    a + (b + c) = (a + b) + c := by
      simpa using (Lean.Grind.Fin.add_assoc (n := Goldilocks.q) a b c).symm
    _ = (b + a) + c := by
      simpa using congrArg (fun t => t + c) (Lean.Grind.Fin.add_comm (n := Goldilocks.q) a b)
    _ = b + (a + c) := by
      simpa using (Lean.Grind.Fin.add_assoc (n := Goldilocks.q) b a c)

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
      have hInit :
          (acc1 + acc2) + (t1 j + t2 j) =
            (acc1 + t1 j) + (acc2 + t2 j) := by
        calc
          (acc1 + acc2) + (t1 j + t2 j)
              = acc1 + (acc2 + (t1 j + t2 j)) := by
                  simpa using (Lean.Grind.Fin.add_assoc (n := Goldilocks.q) acc1 acc2 (t1 j + t2 j))
          _ = acc1 + (t1 j + (acc2 + t2 j)) := by
                exact congrArg (fun t => acc1 + t) (f_add_left_comm acc2 (t1 j) (t2 j))
          _ = (acc1 + t1 j) + (acc2 + t2 j) := by
                simpa using (Lean.Grind.Fin.add_assoc (n := Goldilocks.q) acc1 (t1 j) (acc2 + t2 j)).symm
      calc
        (j :: js).foldl (fun acc j => acc + (t1 j + t2 j)) (acc1 + acc2)
            = js.foldl (fun acc j => acc + (t1 j + t2 j)) ((acc1 + acc2) + (t1 j + t2 j)) := by
                simp [List.foldl]
        _ = js.foldl (fun acc j => acc + (t1 j + t2 j)) ((acc1 + t1 j) + (acc2 + t2 j)) := by
              simp [hInit]
        _ = js.foldl (fun acc j => acc + t1 j) (acc1 + t1 j) +
              js.foldl (fun acc j => acc + t2 j) (acc2 + t2 j) := by
              simpa using ih (acc1 := acc1 + t1 j) (acc2 := acc2 + t2 j)
        _ = (j :: js).foldl (fun acc j => acc + t1 j) acc1 +
              (j :: js).foldl (fun acc j => acc + t2 j) acc2 := by
              simp [List.foldl]

private theorem foldl_mul_right_distrib_F
  (l : List Nat)
  (t : Nat → F)
  (acc c : F) :
  (l.foldl (fun a j => a + t j) acc) * c =
    l.foldl (fun a j => a + t j * c) (acc * c) := by
  induction l generalizing acc with
  | nil =>
      simp
  | cons j js ih =>
      calc
        ((j :: js).foldl (fun a k => a + t k) acc) * c
            = (js.foldl (fun a k => a + t k) (acc + t j)) * c := by
                simp [List.foldl]
        _ = js.foldl (fun a k => a + t k * c) ((acc + t j) * c) := by
              simpa using ih (acc := acc + t j)
        _ = js.foldl (fun a k => a + t k * c) (acc * c + t j * c) := by
              simp [f_right_distrib]
        _ = (j :: js).foldl (fun a k => a + t k * c) (acc * c) := by
              simp [List.foldl, Lean.Grind.Fin.add_assoc]

private theorem foldl_mul_left_distrib_F
  (l : List Nat)
  (t : Nat → F)
  (acc c : F) :
  c * (l.foldl (fun a j => a + t j) acc) =
    l.foldl (fun a j => a + c * t j) (c * acc) := by
  induction l generalizing acc with
  | nil =>
      simp
  | cons j js ih =>
      calc
        c * ((j :: js).foldl (fun a k => a + t k) acc)
            = c * (js.foldl (fun a k => a + t k) (acc + t j)) := by
                simp [List.foldl]
        _ = js.foldl (fun a k => a + c * t k) (c * (acc + t j)) := by
              simpa using ih (acc := acc + t j)
        _ = js.foldl (fun a k => a + c * t k) (c * acc + c * t j) := by
              simp [Lean.Grind.Fin.left_distrib]
        _ = (j :: js).foldl (fun a k => a + c * t k) (c * acc) := by
              simp [List.foldl, Lean.Grind.Fin.add_assoc]

private theorem foldl_add_from_init_F
  (l : List Nat)
  (t : Nat → F)
  (init : F) :
  l.foldl (fun acc j => acc + t j) init =
    init + l.foldl (fun acc j => acc + t j) 0 := by
  induction l generalizing init with
  | nil =>
      simp
  | cons j js ih =>
      calc
        (j :: js).foldl (fun acc k => acc + t k) init
            = js.foldl (fun acc k => acc + t k) (init + t j) := by
                simp [List.foldl]
        _ = (init + t j) + js.foldl (fun acc k => acc + t k) 0 := by
              simpa using ih (init := init + t j)
        _ = init + (t j + js.foldl (fun acc k => acc + t k) 0) := by
              simpa using (Lean.Grind.Fin.add_assoc (n := Goldilocks.q) init (t j)
                (js.foldl (fun acc k => acc + t k) 0))
        _ = init + js.foldl (fun acc k => acc + t k) (t j) := by
              have hInitJ := ih (init := t j)
              simpa [hInitJ]
        _ = init + (j :: js).foldl (fun acc k => acc + t k) 0 := by
              simp [List.foldl]

private theorem foldl_keep_init
  (l : List Nat)
  (init : F) :
  l.foldl (fun acc _ => acc) init = init := by
  induction l generalizing init with
  | nil =>
      simp
  | cons j js ih =>
      simpa [List.foldl] using ih (init := init)

private theorem double_sum_swap
  (l1 l2 : List Nat)
  (f : Nat → Nat → F) :
  l1.foldl
      (fun acc j => acc + l2.foldl (fun acc2 k => acc2 + f j k) 0)
      0
    =
  l2.foldl
      (fun acc k => acc + l1.foldl (fun acc2 j => acc2 + f j k) 0)
      0 := by
  induction l1 with
  | nil =>
      induction l2 with
      | nil => simp
      | cons k ks ih2 =>
          simpa [List.foldl] using (foldl_keep_init ks 0).symm
  | cons j js ih =>
      let s1 : Nat → F := fun k => f j k
      let s2 : Nat → F := fun k => js.foldl (fun acc2 j' => acc2 + f j' k) 0
      have hDecomp :
          l2.foldl
              (fun acc k => acc + (j :: js).foldl (fun acc2 j' => acc2 + f j' k) 0)
              0
            =
          l2.foldl (fun acc k => acc + (s1 k + s2 k)) 0 := by
        apply list_foldl_congr_mem
        intro acc k hk
        have hInner :
            (j :: js).foldl (fun acc2 j' => acc2 + f j' k) 0 =
              f j k + js.foldl (fun acc2 j' => acc2 + f j' k) 0 := by
          have hInit := foldl_add_from_init_F
            (l := js)
            (t := fun j' => f j' k)
            (init := f j k)
          simpa [List.foldl] using hInit
        simpa [s1, s2, hInner]
      calc
        (j :: js).foldl
            (fun acc j' => acc + l2.foldl (fun acc2 k => acc2 + f j' k) 0)
            0
            =
          js.foldl
            (fun acc j' => acc + l2.foldl (fun acc2 k => acc2 + f j' k) 0)
            (l2.foldl (fun acc2 k => acc2 + f j k) 0) := by
              simp [List.foldl]
        _ =
          l2.foldl (fun acc2 k => acc2 + f j k) 0
            +
          js.foldl
            (fun acc j' => acc + l2.foldl (fun acc2 k => acc2 + f j' k) 0)
            0 := by
              simpa using foldl_add_from_init_F
                (l := js)
                (t := fun j' => l2.foldl (fun acc2 k => acc2 + f j' k) 0)
                (init := l2.foldl (fun acc2 k => acc2 + f j k) 0)
        _ =
          l2.foldl (fun acc2 k => acc2 + f j k) 0
            +
          l2.foldl
            (fun acc2 k => acc2 + js.foldl (fun acc3 j' => acc3 + f j' k) 0)
            0 := by
              simpa using congrArg (fun t => l2.foldl (fun acc2 k => acc2 + f j k) 0 + t) ih
        _ =
          l2.foldl (fun acc2 k => acc2 + s1 k) 0
            +
          l2.foldl (fun acc2 k => acc2 + s2 k) 0 := by
              simp [s1, s2]
        _ = l2.foldl (fun acc2 k => acc2 + (s1 k + s2 k)) 0 := by
              simpa using (foldl_add_linearity_F
                (l := l2)
                (t1 := s1)
                (t2 := s2)
                (acc1 := 0)
                (acc2 := 0)).symm
        _ =
          l2.foldl
            (fun acc k => acc + (j :: js).foldl (fun acc2 j' => acc2 + f j' k) 0)
            0 := by
              simpa [List.foldl] using hDecomp.symm

private theorem foldl_add_eq_of_perm
  (l1 l2 : List Nat)
  (hperm : l1.Perm l2)
  (f : Nat → F)
  (init : F) :
  l1.foldl (fun acc j => acc + f j) init =
    l2.foldl (fun acc j => acc + f j) init := by
  induction hperm generalizing init with
  | nil => simp
  | @cons x l1 l2 hperm ih =>
      simpa [List.foldl] using ih (init := init + f x)
  | @swap x y l =>
      have hInit : init + f y + f x = init + f x + f y := by
        calc
          init + f y + f x = init + (f y + f x) := by
            simpa using (Lean.Grind.Fin.add_assoc (n := Goldilocks.q) init (f y) (f x))
          _ = init + (f x + f y) := by
            simpa using congrArg (fun t => init + t)
              (Lean.Grind.Fin.add_comm (n := Goldilocks.q) (f y) (f x))
          _ = init + f x + f y := by
            simpa using (Lean.Grind.Fin.add_assoc (n := Goldilocks.q) init (f x) (f y)).symm
      simpa [List.foldl, hInit]
  | @trans l1 l2 l3 h12 h23 ih12 ih23 =>
      exact (ih12 init).trans (ih23 init)

private theorem foldl_range_rotate
  (r : Nat)
  (hr : r < d)
  (f : Nat → F) :
  (List.range d).foldl (fun acc j => acc + f j) 0 =
    (List.range d).foldl (fun acc j => acc + f ((r + j) % d)) 0 := by
  have hperm :
      (List.map (fun j => (r + j) % d) (List.range d)).Perm (List.range d) :=
    perm_rotate_range r hr
  have hPermFold :
      (List.map (fun j => (r + j) % d) (List.range d)).foldl
          (fun acc j => acc + f j)
          0
        =
      (List.range d).foldl (fun acc j => acc + f j) 0 := by
    exact foldl_add_eq_of_perm _ _ hperm f 0
  calc
    (List.range d).foldl (fun acc j => acc + f j) 0
        =
      (List.map (fun j => (r + j) % d) (List.range d)).foldl
          (fun acc j => acc + f j)
          0 := by
            simpa using hPermFold.symm
    _ =
      (List.range d).foldl (fun acc j => acc + f ((r + j) % d)) 0 := by
        simp [List.foldl_map]

private theorem mod_shift_sub
  (x j : Nat) (hj : j < d) :
  ((x % d) + d - j) % d = (x + d - j) % d := by
  by_cases h0 : j = 0
  · subst h0
    calc
      ((x % d) + d - 0) % d = ((x % d) + d) % d := by simp
      _ = x % d := by simpa using (Nat.add_mod_right (x % d) d)
      _ = (x + d) % d := by simpa using (Nat.add_mod_right x d).symm
      _ = (x + d - 0) % d := by simp
  · have hjPos : 0 < j := Nat.pos_of_ne_zero h0
    have hjLe : j ≤ d := Nat.le_of_lt hj
    have hdjLt : d - j < d := Nat.sub_lt d_pos hjPos
    calc
      ((x % d) + d - j) % d = ((x % d) + (d - j)) % d := by
        rw [Nat.add_sub_assoc hjLe]
      _ = (((x % d) % d) + ((d - j) % d)) % d := by
        simpa using (Nat.add_mod (x % d) (d - j) d)
      _ = ((x % d) + (d - j)) % d := by
        simp [Nat.mod_eq_of_lt hdjLt]
      _ = (x + (d - j)) % d := by
          have hAdd : (x + (d - j)) % d = ((x % d) + ((d - j) % d)) % d := by
            simpa using (Nat.add_mod x (d - j) d)
          have hDJ : (d - j) % d = d - j := Nat.mod_eq_of_lt hdjLt
          simpa [hDJ] using hAdd.symm
      _ = (x + d - j) % d := by
        rw [Nat.add_sub_assoc hjLe]

private theorem mod_add_sub_cancel_of_lt
  (r j : Nat)
  (hr : r < d)
  (hj : j < d) :
  (((r + j) % d) + d - r) % d = j := by
  by_cases hsum : r + j < d
  · have hmod : (r + j) % d = r + j := Nat.mod_eq_of_lt hsum
    have hinside : (r + j) + d - r = j + d := by omega
    calc
      (((r + j) % d) + d - r) % d = ((r + j) + d - r) % d := by simp [hmod]
      _ = (j + d) % d := by simp [hinside]
      _ = j % d := by simpa using (Nat.add_mod_right j d)
      _ = j := Nat.mod_eq_of_lt hj
  · have hsumge : d ≤ r + j := Nat.le_of_not_gt hsum
    have hlt : r + j - d < d := by omega
    have hmod1 : (r + j) % d = (r + j - d) % d := Nat.mod_eq_sub_mod hsumge
    have hmod2 : (r + j - d) % d = r + j - d := Nat.mod_eq_of_lt hlt
    have hmod : (r + j) % d = r + j - d := by simpa [hmod2] using hmod1
    have hinside : (r + j - d) + d - r = j := by omega
    calc
      (((r + j) % d) + d - r) % d = ((r + j - d) + d - r) % d := by simp [hmod]
      _ = j % d := by simp [hinside]
      _ = j := Nat.mod_eq_of_lt hj

private theorem mod_nested_sub_eq
  (i j k : Nat)
  (hj : j < d)
  (hk : k < d) :
  (((i + d - k) % d) + d - j) % d = (i + d - ((k + j) % d)) % d := by
  have hL : (((i + d - k) % d) + d - j) % d = (i + d - k + d - j) % d := by
    simpa using mod_shift_sub (x := i + d - k) j hj
  by_cases hsum : k + j < d
  · have hmod : (k + j) % d = k + j := Nat.mod_eq_of_lt hsum
    have hR1 : (i + d - ((k + j) % d)) % d = (i + d - (k + j)) % d := by
      simp [hmod]
    have hE : (i + d - k + d - j) % d = (i + d - (k + j) + d) % d := by
      have hInside1 : i + d - k + d - j = (i + d - (k + j)) + d := by
        omega
      simp [hInside1]
    calc
      (((i + d - k) % d) + d - j) % d = (i + d - k + d - j) % d := hL
      _ = (i + d - (k + j) + d) % d := hE
      _ = (i + d - (k + j)) % d := by
            simpa [Nat.add_comm] using (Nat.add_mod_right (i + d - (k + j)) d)
      _ = (i + d - ((k + j) % d)) % d := by
            simpa [hR1] using rfl
  · have hsumge : d ≤ k + j := Nat.le_of_not_gt hsum
    have hlt : k + j - d < d := by omega
    have hmod1 : (k + j) % d = (k + j - d) % d := Nat.mod_eq_sub_mod hsumge
    have hmod2 : (k + j - d) % d = k + j - d := Nat.mod_eq_of_lt hlt
    have hmod : (k + j) % d = k + j - d := by simpa [hmod2] using hmod1
    have hR2 : (i + d - ((k + j) % d)) % d = (i + d - (k + j - d)) % d := by
      simp [hmod]
    have hInside2 : i + d - (k + j - d) = i + d - k + d - j := by omega
    calc
      (((i + d - k) % d) + d - j) % d = (i + d - k + d - j) % d := hL
      _ = (i + d - (k + j - d)) % d := by simp [hInside2]
      _ = (i + d - ((k + j) % d)) % d := by simpa [hR2] using rfl

private theorem inner_reindex_sub
  (b c : Coeffs)
  (i k : Nat)
  (hk : k < d) :
  (List.range d).foldl
      (fun acc j =>
        acc + coeffAt b ((j + d - k) % d) * coeffAt c ((i + d - j) % d))
      0
    =
  (List.range d).foldl
      (fun acc j =>
        acc + coeffAt b j * coeffAt c ((i + d - ((k + j) % d)) % d))
      0 := by
  let f : Nat → F := fun x =>
    coeffAt b ((x + d - k) % d) * coeffAt c ((i + d - x) % d)
  have hRot :
      (List.range d).foldl (fun acc j => acc + f j) 0 =
        (List.range d).foldl (fun acc j => acc + f ((k + j) % d)) 0 :=
    foldl_range_rotate k hk f
  calc
    (List.range d).foldl
        (fun acc j =>
          acc + coeffAt b ((j + d - k) % d) * coeffAt c ((i + d - j) % d))
        0
        =
      (List.range d).foldl (fun acc j => acc + f j) 0 := by
          simp [f]
    _ =
      (List.range d).foldl (fun acc j => acc + f ((k + j) % d)) 0 := hRot
    _ =
      (List.range d).foldl
        (fun acc j =>
          acc + coeffAt b j * coeffAt c ((i + d - ((k + j) % d)) % d))
        0 := by
          apply list_foldl_congr_mem
          intro acc j hjMem
          have hj : j < d := by simpa [List.mem_range] using hjMem
          have hIdxB : (((k + j) % d) + d - k) % d = j :=
            mod_add_sub_cancel_of_lt k j hk hj
          simp [f, hIdxB]

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


set_option maxHeartbeats 800000 in
theorem mulRq_comm (a b : Coeffs) : mulRq a b = mulRq b a := by
  apply Array.ext
  · simp [mulRq]
  · intro i hi₁ hi₂
    have hi : i < d := by simpa [mulRq] using hi₁
    let f : Nat → F := fun j => coeffAt a j * coeffAt b ((i + d - j) % d)
    let g : Nat → F := fun j => coeffAt b j * coeffAt a ((i + d - j) % d)
    have hperm :
      List.Perm
        (List.map (fun j => (i + d - j) % d) (List.range d))
        (List.range d) := perm_modSub_range i
    have hpermFold :
        (List.range d).foldl (fun acc j => acc + g j) 0 =
          (List.map (fun j => (i + d - j) % d) (List.range d)).foldl (fun acc j => acc + g j) 0 := by
      symm
      exact foldl_add_eq_of_perm _ _ hperm g 0
    have hmapFold :
        (List.map (fun j => (i + d - j) % d) (List.range d)).foldl (fun acc j => acc + g j) 0 =
          (List.range d).foldl (fun acc j => acc + g ((i + d - j) % d)) 0 := by
      simp [List.foldl_map]
    have hgTof :
        (List.range d).foldl (fun acc j => acc + g ((i + d - j) % d)) 0 =
          (List.range d).foldl (fun acc j => acc + f j) 0 := by
      apply list_foldl_congr_mem
      intro acc j hj
      have hjd : j < d := by simpa [List.mem_range] using hj
      have hInvol : ((i + d - ((i + d - j) % d)) % d) = j := mod_sub_involutive i j hjd
      have hm : g ((i + d - j) % d) = f j := by
        unfold g f
        rw [hInvol]
        simpa using (Lean.Grind.Fin.mul_comm (n := Goldilocks.q)
          (coeffAt b ((i + d - j) % d)) (coeffAt a j))
      simpa [hm]
    have hCoeff : coeffAt (mulRq a b) i = coeffAt (mulRq b a) i := by
      calc
        coeffAt (mulRq a b) i
            = (List.range d).foldl (fun acc j => acc + f j) 0 := by
                simpa [f] using coeffAt_mulRq a b i hi
        _ = (List.range d).foldl (fun acc j => acc + g j) 0 := by
              simpa [hpermFold, hmapFold, hgTof]
        _ = coeffAt (mulRq b a) i := by
              symm
              simpa [g] using coeffAt_mulRq b a i hi
    have hiR : i < d := by simpa [mulRq] using hi₂
    simpa [coeffAt, hi, hiR, Array.getD, hi₁, hi₂, mulRq_size] using hCoeff

set_option maxHeartbeats 6000000 in
theorem mulRq_assoc (a b c : Coeffs) : mulRq (mulRq a b) c = mulRq a (mulRq b c) := by
  apply Array.ext
  · simp [mulRq]
  · intro i hiL hiR
    have hi : i < d := by simpa [mulRq] using hiL
    let canon : F :=
      (List.range d).foldl
        (fun acc k =>
          acc + coeffAt a k *
            ((List.range d).foldl
              (fun acc2 j =>
                acc2 + coeffAt b j * coeffAt c ((i + d - ((k + j) % d)) % d))
              0))
        0
    have hLeft : coeffAt (mulRq (mulRq a b) c) i = canon := by
      have h0 :
          coeffAt (mulRq (mulRq a b) c) i =
            (List.range d).foldl
              (fun acc j =>
                acc + coeffAt (mulRq a b) j * coeffAt c ((i + d - j) % d))
              0 := by
        simpa using coeffAt_mulRq (mulRq a b) c i hi
      have h1 :
          (List.range d).foldl
              (fun acc j =>
                acc + coeffAt (mulRq a b) j * coeffAt c ((i + d - j) % d))
              0
            =
          (List.range d).foldl
              (fun acc j =>
                acc +
                  ((List.range d).foldl
                    (fun acc2 k =>
                      acc2 + coeffAt a k * coeffAt b ((j + d - k) % d))
                    0) * coeffAt c ((i + d - j) % d))
              0 := by
        apply list_foldl_congr_mem
        intro acc j hjMem
        have hj : j < d := by simpa [List.mem_range] using hjMem
        have hABj :
            coeffAt (mulRq a b) j =
              (List.range d).foldl
                (fun acc2 k => acc2 + coeffAt a k * coeffAt b ((j + d - k) % d))
                0 := by
          simpa using coeffAt_mulRq a b j hj
        exact congrArg (fun t => acc + t * coeffAt c ((i + d - j) % d)) hABj
      have h2 :
          (List.range d).foldl
              (fun acc j =>
                acc +
                  ((List.range d).foldl
                    (fun acc2 k =>
                      acc2 + coeffAt a k * coeffAt b ((j + d - k) % d))
                    0) * coeffAt c ((i + d - j) % d))
              0
            =
          (List.range d).foldl
              (fun acc j =>
                acc +
                  (List.range d).foldl
                    (fun acc2 k =>
                      acc2 + (coeffAt a k * coeffAt b ((j + d - k) % d)) * coeffAt c ((i + d - j) % d))
                    0)
              0 := by
        apply list_foldl_congr_mem
        intro acc j hjMem
        have hDist := foldl_mul_right_distrib_F
          (l := List.range d)
          (t := fun k => coeffAt a k * coeffAt b ((j + d - k) % d))
          (acc := 0)
          (c := coeffAt c ((i + d - j) % d))
        have hZeroInit : (0 : F) * coeffAt c ((i + d - j) % d) = 0 := by
          simpa using (Lean.Grind.Fin.zero_mul (n := Goldilocks.q) (coeffAt c ((i + d - j) % d)))
        calc
          acc +
              ((List.range d).foldl (fun acc2 k => acc2 + coeffAt a k * coeffAt b ((j + d - k) % d)) 0 *
                coeffAt c ((i + d - j) % d))
              =
          acc +
              (List.range d).foldl
                (fun acc2 k =>
                  acc2 + (coeffAt a k * coeffAt b ((j + d - k) % d)) * coeffAt c ((i + d - j) % d))
                ((0 : F) * coeffAt c ((i + d - j) % d)) := by
                rw [hDist.symm]
          _ =
            acc +
              (List.range d).foldl
                (fun acc2 k =>
                  acc2 + (coeffAt a k * coeffAt b ((j + d - k) % d)) * coeffAt c ((i + d - j) % d))
                0 := by
                simp [hZeroInit]
      have h3 :
          (List.range d).foldl
              (fun acc j =>
                acc +
                  (List.range d).foldl
                    (fun acc2 k =>
                      acc2 + (coeffAt a k * coeffAt b ((j + d - k) % d)) * coeffAt c ((i + d - j) % d))
                    0)
              0
            =
          (List.range d).foldl
              (fun acc k =>
                acc +
                  (List.range d).foldl
                    (fun acc2 j =>
                      acc2 + (coeffAt a k * coeffAt b ((j + d - k) % d)) * coeffAt c ((i + d - j) % d))
                    0)
              0 := by
        simpa using double_sum_swap
          (l1 := List.range d)
          (l2 := List.range d)
          (f := fun j k =>
            (coeffAt a k * coeffAt b ((j + d - k) % d)) * coeffAt c ((i + d - j) % d))
      have h4 :
          (List.range d).foldl
              (fun acc k =>
                acc +
                  (List.range d).foldl
                    (fun acc2 j =>
                      acc2 + (coeffAt a k * coeffAt b ((j + d - k) % d)) * coeffAt c ((i + d - j) % d))
                    0)
              0
            =
          (List.range d).foldl
              (fun acc k =>
                acc +
                  coeffAt a k *
                    ((List.range d).foldl
                      (fun acc2 j =>
                        acc2 + coeffAt b ((j + d - k) % d) * coeffAt c ((i + d - j) % d))
                      0))
              0 := by
        apply list_foldl_congr_mem
        intro acc k hkMem
        have hAssoc :
            (List.range d).foldl
                (fun acc2 j =>
                  acc2 + (coeffAt a k * coeffAt b ((j + d - k) % d)) * coeffAt c ((i + d - j) % d))
                0
              =
            (List.range d).foldl
                (fun acc2 j =>
                  acc2 + coeffAt a k * (coeffAt b ((j + d - k) % d) * coeffAt c ((i + d - j) % d)))
                0 := by
          apply list_foldl_congr_mem
          intro acc2 j hjMem
          simpa using congrArg
            (fun t => acc2 + t)
            (Lean.Grind.Fin.mul_assoc (n := Goldilocks.q)
              (coeffAt a k)
              (coeffAt b ((j + d - k) % d))
              (coeffAt c ((i + d - j) % d)))
        have hFactor :=
          foldl_mul_left_distrib_F
            (l := List.range d)
            (t := fun j => coeffAt b ((j + d - k) % d) * coeffAt c ((i + d - j) % d))
            (acc := 0)
            (c := coeffAt a k)
        have hFactor' :
            (List.range d).foldl
                (fun acc2 j =>
                  acc2 + coeffAt a k * (coeffAt b ((j + d - k) % d) * coeffAt c ((i + d - j) % d)))
                0
              =
            coeffAt a k *
              ((List.range d).foldl
                (fun acc2 j =>
                  acc2 + coeffAt b ((j + d - k) % d) * coeffAt c ((i + d - j) % d))
                0) := by
          simpa [f_mul_zero] using hFactor.symm
        simpa [hAssoc] using congrArg (fun t => acc + t) hFactor'
      have h5 :
          (List.range d).foldl
              (fun acc k =>
                acc +
                  coeffAt a k *
                    ((List.range d).foldl
                      (fun acc2 j =>
                        acc2 + coeffAt b ((j + d - k) % d) * coeffAt c ((i + d - j) % d))
                      0))
              0
            =
          canon := by
        unfold canon
        apply list_foldl_congr_mem
        intro acc k hkMem
        have hk : k < d := by simpa [List.mem_range] using hkMem
        have hReindex := inner_reindex_sub b c i k hk
        exact congrArg (fun t => acc + coeffAt a k * t) hReindex
      exact h0.trans (h1.trans (h2.trans (h3.trans (h4.trans h5))))
    have hRight : coeffAt (mulRq a (mulRq b c)) i = canon := by
      have h0 :
          coeffAt (mulRq a (mulRq b c)) i =
            (List.range d).foldl
              (fun acc k =>
                acc + coeffAt a k * coeffAt (mulRq b c) ((i + d - k) % d))
              0 := by
        simpa using coeffAt_mulRq a (mulRq b c) i hi
      have h1 :
          (List.range d).foldl
              (fun acc k =>
                acc + coeffAt a k * coeffAt (mulRq b c) ((i + d - k) % d))
              0
            =
          (List.range d).foldl
              (fun acc k =>
                acc +
                  coeffAt a k *
                    ((List.range d).foldl
                      (fun acc2 j =>
                        acc2 + coeffAt b j * coeffAt c ((((i + d - k) % d) + d - j) % d))
                      0))
              0 := by
        apply list_foldl_congr_mem
        intro acc k hkMem
        have hk : k < d := by simpa [List.mem_range] using hkMem
        have hBCk :
            coeffAt (mulRq b c) ((i + d - k) % d) =
              (List.range d).foldl
                (fun acc2 j =>
                  acc2 + coeffAt b j * coeffAt c ((((i + d - k) % d) + d - j) % d))
                0 := by
          have hik : (i + d - k) % d < d := Nat.mod_lt _ d_pos
          simpa using coeffAt_mulRq b c ((i + d - k) % d) hik
        exact congrArg (fun t => acc + coeffAt a k * t) hBCk
      have h2 :
          (List.range d).foldl
              (fun acc k =>
                acc +
                  coeffAt a k *
                    ((List.range d).foldl
                      (fun acc2 j =>
                        acc2 + coeffAt b j * coeffAt c ((((i + d - k) % d) + d - j) % d))
                      0))
              0
            =
          canon := by
        unfold canon
        apply list_foldl_congr_mem
        intro acc k hkMem
        have hk : k < d := by simpa [List.mem_range] using hkMem
        have hIdx :
            (List.range d).foldl
                (fun acc2 j =>
                  acc2 + coeffAt b j * coeffAt c ((((i + d - k) % d) + d - j) % d))
                0
              =
            (List.range d).foldl
                (fun acc2 j =>
                  acc2 + coeffAt b j * coeffAt c ((i + d - ((k + j) % d)) % d))
                0 := by
          apply list_foldl_congr_mem
          intro acc2 j hjMem
          have hj : j < d := by simpa [List.mem_range] using hjMem
          have hMod := mod_nested_sub_eq i j k hj hk
          simpa [hMod]
        exact congrArg (fun t => acc + coeffAt a k * t) hIdx
      exact h0.trans (h1.trans h2)
    have hCoeff : coeffAt (mulRq (mulRq a b) c) i = coeffAt (mulRq a (mulRq b c)) i := by
      exact hLeft.trans hRight.symm
    have hiR' : i < d := by simpa [mulRq] using hiR
    simpa [coeffAt, hi, hiR', Array.getD, hiL, hiR, mulRq_size] using hCoeff

theorem zeroRq_size : zeroRq.size = d := by
  simp [zeroRq, d]

theorem oneRq_size : oneRq.size = d := by
  simp [oneRq, d]

theorem hasRingDegreeShape_zeroRq : hasRingDegreeShape zeroRq := by
  simp [hasRingDegreeShape, zeroRq, d]

theorem hasRingDegreeShape_oneRq : hasRingDegreeShape oneRq := by
  simp [hasRingDegreeShape, oneRq, d]

theorem hasRingDegreeShape_mulRq (a b : Coeffs) : hasRingDegreeShape (mulRq a b) := by
  simp [hasRingDegreeShape, mulRq_size]

theorem ct_zeroRq : ct zeroRq = 0 := by
  simp [ct, zeroRq, d]

theorem ct_oneRq : ct oneRq = 1 := by
  simp [ct, oneRq, d]

theorem coeffAt_zeroRq (i : Nat) : coeffAt zeroRq i = 0 := by
  unfold coeffAt zeroRq
  by_cases hi : i < d
  · simp [Array.getD, hi]
  · simp [Array.getD, hi]

theorem ringMulShapeProp_of_shapes
    {a b : Coeffs}
    (ha : hasRingDegreeShape a)
    (hb : hasRingDegreeShape b) :
    ringMulShapeProp a b := by
  exact And.intro ha hb

theorem ringMulShapeProp_left
    {a b : Coeffs}
    (h : ringMulShapeProp a b) :
    hasRingDegreeShape a := h.1

theorem ringMulShapeProp_right
    {a b : Coeffs}
    (h : ringMulShapeProp a b) :
    hasRingDegreeShape b := h.2

@[simp] theorem linComb2Vec_def
    (ρ1 ρ2 : F) (z1 z2 : Array F) :
    linComb2Vec ρ1 ρ2 z1 z2 = vecAdd (vecScale ρ1 z1) (vecScale ρ2 z2) := rfl

def allCanonical (a : Coeffs) : Bool :=
  a.all F.canonicalCheck

end SuperNeo
