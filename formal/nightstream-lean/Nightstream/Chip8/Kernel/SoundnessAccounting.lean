import SuperNeo.ProofSystem.Negligible

/-!
Owns the exact parameterized soundness-accounting surface for the 3-stage CHIP-8
kernel. This file is about error-term decomposition only; it does not own the
underlying Shout/Twist/PCS/Fiat-Shamir theorem statements.
-/

namespace Nightstream.Chip8.SoundnessAccounting

open SuperNeo.ProofSystem

inductive Stage1ShoutChannel where
  | fetch
  | decode
  | alu
  | eq4
deriving DecidableEq, Repr

def stage1ShoutChannels : List Stage1ShoutChannel :=
  [.fetch, .decode, .alu, .eq4]

inductive AddressFamily where
  | fetch
  | decode
  | alu
  | eq4
  | regRaX
  | regRaY
  | regRaI
  | regWa
  | ramRa
  | ramWa
deriving DecidableEq, Repr

def stage1AddressFamily : Stage1ShoutChannel → AddressFamily
  | .fetch => .fetch
  | .decode => .decode
  | .alu => .alu
  | .eq4 => .eq4

def regAddressFamilies : List AddressFamily :=
  [.regRaX, .regRaY, .regRaI, .regWa]

def ramAddressFamilies : List AddressFamily :=
  [.ramRa, .ramWa]

inductive TwistReadFamily where
  | regX
  | regY
  | regI
  | ram
deriving DecidableEq, Repr

def regReadFamilies : List TwistReadFamily :=
  [.regX, .regY, .regI]

inductive TwistMemoryFamily where
  | reg
  | ram
deriving DecidableEq, Repr

structure KernelSoundnessTerms where
  epsShoutCore : Stage1ShoutChannel → ErrorFn
  epsAddr : AddressFamily → ErrorFn
  epsTwistRead : TwistReadFamily → ErrorFn
  epsTwistWrite : TwistMemoryFamily → ErrorFn
  epsTwistVal : TwistMemoryFamily → ErrorFn
  epsRamRafRead : ErrorFn
  epsRamRafWrite : ErrorFn
  epsShiftReduce : ErrorFn
  epsContinuity : ErrorFn
  epsRegRwBatch : ErrorFn
  epsRamRwBatch : ErrorFn
  epsLookupLink : ErrorFn
  epsTwistLink : ErrorFn
  epsPCS : ErrorFn
  epsFS : ErrorFn
  epsOuter : ErrorFn

structure PrimitiveNegligibility (terms : KernelSoundnessTerms) where
  negligibleShoutCore : ∀ c, IsNegligible (terms.epsShoutCore c)
  negligibleAddr : ∀ f, IsNegligible (terms.epsAddr f)
  negligibleTwistRead : ∀ f, IsNegligible (terms.epsTwistRead f)
  negligibleTwistWrite : ∀ f, IsNegligible (terms.epsTwistWrite f)
  negligibleTwistVal : ∀ f, IsNegligible (terms.epsTwistVal f)
  negligibleRamRafRead : IsNegligible terms.epsRamRafRead
  negligibleRamRafWrite : IsNegligible terms.epsRamRafWrite
  negligibleShiftReduce : IsNegligible terms.epsShiftReduce
  negligibleContinuity : IsNegligible terms.epsContinuity
  negligibleRegRwBatch : IsNegligible terms.epsRegRwBatch
  negligibleRamRwBatch : IsNegligible terms.epsRamRwBatch
  negligibleLookupLink : IsNegligible terms.epsLookupLink
  negligibleTwistLink : IsNegligible terms.epsTwistLink
  negligiblePCS : IsNegligible terms.epsPCS
  negligibleFS : IsNegligible terms.epsFS
  negligibleOuter : IsNegligible terms.epsOuter

def sumErrorFns : List ErrorFn → ErrorFn
  | [] => fun _ => 0
  | f :: fs => fun n => f n + sumErrorFns fs n

theorem isNegligible_of_le
  {f g : ErrorFn}
  (hLe : ∀ n, f n ≤ g n)
  (hg : IsNegligible g) :
  IsNegligible f := by
  intro c
  rcases hg c with ⟨N, hN⟩
  refine ⟨N, ?_⟩
  intro n hn
  exact le_trans (hLe n) (hN n hn)

theorem isNegligible_sumErrorFns
  {fs : List ErrorFn}
  (hfs : ∀ f, f ∈ fs → IsNegligible f) :
  IsNegligible (sumErrorFns fs) := by
  induction fs with
  | nil =>
      simpa [sumErrorFns] using
        (isNegligible_zero : IsNegligible (fun _ => 0))
  | cons f fs ih =>
      have hf : IsNegligible f := hfs f (by simp)
      have hRest : IsNegligible (sumErrorFns fs) := by
        apply ih
        intro g hg
        exact hfs g (by simp [hg])
      simpa [sumErrorFns] using isNegligible_add hf hRest

theorem isNegligible_sumErrorFns_map
  {α : Type*}
  (xs : List α)
  (f : α → ErrorFn)
  (h : ∀ x, x ∈ xs → IsNegligible (f x)) :
  IsNegligible (sumErrorFns (xs.map f)) := by
  induction xs with
  | nil =>
      simpa [sumErrorFns] using
        (isNegligible_zero : IsNegligible (fun _ => 0))
  | cons x xs ih =>
      have hx : IsNegligible (f x) := h x (by simp)
      have hRest : IsNegligible (sumErrorFns (xs.map f)) := by
        apply ih
        intro y hy
        exact h y (by simp [hy])
      simpa [sumErrorFns] using isNegligible_add hx hRest

def epsStage1 (terms : KernelSoundnessTerms) : ErrorFn :=
  fun n =>
    sumErrorFns (stage1ShoutChannels.map terms.epsShoutCore) n +
      sumErrorFns
        (stage1ShoutChannels.map fun c => terms.epsAddr (stage1AddressFamily c)) n

def epsStage2 (terms : KernelSoundnessTerms) : ErrorFn :=
  fun n =>
    sumErrorFns (regReadFamilies.map terms.epsTwistRead) n +
      terms.epsTwistWrite .reg n +
      terms.epsTwistVal .reg n +
      sumErrorFns (regAddressFamilies.map terms.epsAddr) n +
      terms.epsTwistRead .ram n +
      terms.epsTwistWrite .ram n +
      terms.epsTwistVal .ram n +
      terms.epsRamRafRead n +
      terms.epsRamRafWrite n +
      sumErrorFns (ramAddressFamilies.map terms.epsAddr) n

def epsStage3 (terms : KernelSoundnessTerms) : ErrorFn :=
  fun n => terms.epsShiftReduce n + terms.epsContinuity n

def epsBatch (terms : KernelSoundnessTerms) : ErrorFn :=
  fun n =>
    terms.epsRegRwBatch n +
      terms.epsRamRwBatch n +
      terms.epsLookupLink n +
      terms.epsTwistLink n

def epsTotalUpper (terms : KernelSoundnessTerms) : ErrorFn :=
  fun n =>
    epsStage1 terms n +
      epsStage2 terms n +
      epsStage3 terms n +
      epsBatch terms n +
      terms.epsPCS n +
      terms.epsFS n +
      terms.epsOuter n

structure KernelSoundnessAccounting where
  terms : KernelSoundnessTerms
  primitiveNegligibility : PrimitiveNegligibility terms
  epsTotal : ErrorFn
  epsTotal_bound : ∀ n, epsTotal n ≤ epsTotalUpper terms n

theorem stage1ShoutChannels_nodup : stage1ShoutChannels.Nodup := by
  native_decide

theorem regReadFamilies_nodup : regReadFamilies.Nodup := by
  native_decide

theorem regAddressFamilies_nodup : regAddressFamilies.Nodup := by
  native_decide

theorem ramAddressFamilies_nodup : ramAddressFamilies.Nodup := by
  native_decide

theorem negligible_epsStage1
  {terms : KernelSoundnessTerms}
  (hNeg : PrimitiveNegligibility terms) :
  IsNegligible (epsStage1 terms) := by
  have hCore :
      IsNegligible (sumErrorFns (stage1ShoutChannels.map terms.epsShoutCore)) := by
    apply isNegligible_sumErrorFns_map
    intro c hc
    exact hNeg.negligibleShoutCore c
  have hAddr :
      IsNegligible
        (sumErrorFns
          (stage1ShoutChannels.map fun c => terms.epsAddr (stage1AddressFamily c))) := by
    apply isNegligible_sumErrorFns_map
    intro c hc
    exact hNeg.negligibleAddr (stage1AddressFamily c)
  simpa [epsStage1] using isNegligible_add hCore hAddr

theorem negligible_epsStage2
  {terms : KernelSoundnessTerms}
  (hNeg : PrimitiveNegligibility terms) :
  IsNegligible (epsStage2 terms) := by
  have hRegReads :
      IsNegligible (sumErrorFns (regReadFamilies.map terms.epsTwistRead)) := by
    apply isNegligible_sumErrorFns_map
    intro family hFamily
    exact hNeg.negligibleTwistRead family
  have hRegAddrs :
      IsNegligible (sumErrorFns (regAddressFamilies.map terms.epsAddr)) := by
    apply isNegligible_sumErrorFns_map
    intro family hFamily
    exact hNeg.negligibleAddr family
  have hRamAddrs :
      IsNegligible (sumErrorFns (ramAddressFamilies.map terms.epsAddr)) := by
    apply isNegligible_sumErrorFns_map
    intro family hFamily
    exact hNeg.negligibleAddr family
  have h1 :
      IsNegligible
        (fun n => sumErrorFns (regReadFamilies.map terms.epsTwistRead) n +
          terms.epsTwistWrite .reg n) := by
    simpa using isNegligible_add hRegReads (hNeg.negligibleTwistWrite .reg)
  have h2 :
      IsNegligible
        (fun n => sumErrorFns (regReadFamilies.map terms.epsTwistRead) n +
          terms.epsTwistWrite .reg n + terms.epsTwistVal .reg n) := by
    simpa [add_assoc] using isNegligible_add h1 (hNeg.negligibleTwistVal .reg)
  have h3 :
      IsNegligible
        (fun n => sumErrorFns (regReadFamilies.map terms.epsTwistRead) n +
          terms.epsTwistWrite .reg n + terms.epsTwistVal .reg n +
          sumErrorFns (regAddressFamilies.map terms.epsAddr) n) := by
    simpa [add_assoc] using isNegligible_add h2 hRegAddrs
  have h4 :
      IsNegligible
        (fun n => sumErrorFns (regReadFamilies.map terms.epsTwistRead) n +
          terms.epsTwistWrite .reg n + terms.epsTwistVal .reg n +
          sumErrorFns (regAddressFamilies.map terms.epsAddr) n +
          terms.epsTwistRead .ram n) := by
    simpa [add_assoc] using isNegligible_add h3 (hNeg.negligibleTwistRead .ram)
  have h5 :
      IsNegligible
        (fun n => sumErrorFns (regReadFamilies.map terms.epsTwistRead) n +
          terms.epsTwistWrite .reg n + terms.epsTwistVal .reg n +
          sumErrorFns (regAddressFamilies.map terms.epsAddr) n +
          terms.epsTwistRead .ram n + terms.epsTwistWrite .ram n) := by
    simpa [add_assoc] using isNegligible_add h4 (hNeg.negligibleTwistWrite .ram)
  have h6 :
      IsNegligible
        (fun n => sumErrorFns (regReadFamilies.map terms.epsTwistRead) n +
          terms.epsTwistWrite .reg n + terms.epsTwistVal .reg n +
          sumErrorFns (regAddressFamilies.map terms.epsAddr) n +
          terms.epsTwistRead .ram n + terms.epsTwistWrite .ram n +
          terms.epsTwistVal .ram n) := by
    simpa [add_assoc] using isNegligible_add h5 (hNeg.negligibleTwistVal .ram)
  have h7 :
      IsNegligible
        (fun n => sumErrorFns (regReadFamilies.map terms.epsTwistRead) n +
          terms.epsTwistWrite .reg n + terms.epsTwistVal .reg n +
          sumErrorFns (regAddressFamilies.map terms.epsAddr) n +
          terms.epsTwistRead .ram n + terms.epsTwistWrite .ram n +
          terms.epsTwistVal .ram n + terms.epsRamRafRead n) := by
    simpa [add_assoc] using isNegligible_add h6 hNeg.negligibleRamRafRead
  have h8 :
      IsNegligible
        (fun n => sumErrorFns (regReadFamilies.map terms.epsTwistRead) n +
          terms.epsTwistWrite .reg n + terms.epsTwistVal .reg n +
          sumErrorFns (regAddressFamilies.map terms.epsAddr) n +
          terms.epsTwistRead .ram n + terms.epsTwistWrite .ram n +
          terms.epsTwistVal .ram n + terms.epsRamRafRead n +
          terms.epsRamRafWrite n) := by
    simpa [add_assoc] using isNegligible_add h7 hNeg.negligibleRamRafWrite
  simpa [epsStage2, add_assoc] using isNegligible_add h8 hRamAddrs

theorem negligible_epsStage3
  {terms : KernelSoundnessTerms}
  (hNeg : PrimitiveNegligibility terms) :
  IsNegligible (epsStage3 terms) := by
  simpa [epsStage3] using
    isNegligible_add hNeg.negligibleShiftReduce hNeg.negligibleContinuity

theorem negligible_epsBatch
  {terms : KernelSoundnessTerms}
  (hNeg : PrimitiveNegligibility terms) :
  IsNegligible (epsBatch terms) := by
  have h1 :
      IsNegligible (fun n => terms.epsRegRwBatch n + terms.epsRamRwBatch n) := by
    simpa using isNegligible_add hNeg.negligibleRegRwBatch hNeg.negligibleRamRwBatch
  have h2 :
      IsNegligible
        (fun n => terms.epsRegRwBatch n + terms.epsRamRwBatch n +
          terms.epsLookupLink n) := by
    simpa [add_assoc] using isNegligible_add h1 hNeg.negligibleLookupLink
  simpa [epsBatch, add_assoc] using isNegligible_add h2 hNeg.negligibleTwistLink

theorem negligible_epsTotalUpper
  {terms : KernelSoundnessTerms}
  (hNeg : PrimitiveNegligibility terms) :
  IsNegligible (epsTotalUpper terms) := by
  have h1 : IsNegligible (epsStage1 terms) := negligible_epsStage1 hNeg
  have h2 : IsNegligible (epsStage2 terms) := negligible_epsStage2 hNeg
  have h3 : IsNegligible (epsStage3 terms) := negligible_epsStage3 hNeg
  have h4 : IsNegligible (epsBatch terms) := negligible_epsBatch hNeg
  have h12 :
      IsNegligible (fun n => epsStage1 terms n + epsStage2 terms n) := by
    simpa using isNegligible_add h1 h2
  have h123 :
      IsNegligible
        (fun n => epsStage1 terms n + epsStage2 terms n + epsStage3 terms n) := by
    simpa [add_assoc] using isNegligible_add h12 h3
  have h1234 :
      IsNegligible
        (fun n =>
          epsStage1 terms n + epsStage2 terms n + epsStage3 terms n +
            epsBatch terms n) := by
    simpa [add_assoc] using isNegligible_add h123 h4
  have h12345 :
      IsNegligible
        (fun n =>
          epsStage1 terms n + epsStage2 terms n + epsStage3 terms n +
            epsBatch terms n + terms.epsPCS n) := by
    simpa [add_assoc] using isNegligible_add h1234 hNeg.negligiblePCS
  have h123456 :
      IsNegligible
        (fun n =>
          epsStage1 terms n + epsStage2 terms n + epsStage3 terms n +
            epsBatch terms n + terms.epsPCS n + terms.epsFS n) := by
    simpa [add_assoc] using isNegligible_add h12345 hNeg.negligibleFS
  simpa [epsTotalUpper, add_assoc] using isNegligible_add h123456 hNeg.negligibleOuter

theorem KernelSoundnessAccounting.negligible_epsTotal
  (accounting : KernelSoundnessAccounting) :
  IsNegligible accounting.epsTotal := by
  apply isNegligible_of_le accounting.epsTotal_bound
  exact negligible_epsTotalUpper accounting.primitiveNegligibility

end Nightstream.Chip8.SoundnessAccounting
