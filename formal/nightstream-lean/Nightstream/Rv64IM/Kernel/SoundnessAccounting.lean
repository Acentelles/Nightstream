import SuperNeo.ProofSystem.Negligible

namespace Nightstream.Rv64IM

open SuperNeo.ProofSystem

inductive Stage1ShoutChannel where
  | bytecode
  | alu
  | branch
deriving DecidableEq, Repr

def stage1ShoutChannels : List Stage1ShoutChannel :=
  [.bytecode, .alu, .branch]

inductive AddressFamily where
  | bytecode
  | alu
  | branch
  | reg
  | ram
deriving DecidableEq, Repr

def stage1AddressFamilies : List AddressFamily :=
  [.bytecode, .alu, .branch]

inductive TwistMemoryFamily where
  | reg
  | ram
deriving DecidableEq, Repr

def twistMemoryFamilies : List TwistMemoryFamily :=
  [.reg, .ram]

structure KernelSoundnessTerms where
  epsShoutCore : Stage1ShoutChannel → ErrorFn
  epsAddr : AddressFamily → ErrorFn
  epsTwistRw : TwistMemoryFamily → ErrorFn
  epsTwistVal : TwistMemoryFamily → ErrorFn
  epsRamRaf : ErrorFn
  epsStage1Linkage : ErrorFn
  epsStage2Linkage : ErrorFn
  epsContinuity : ErrorFn
  epsOpeningProvenance : ErrorFn
  epsProgramBinding : ErrorFn
  epsPCS : ErrorFn
  epsFS : ErrorFn
  epsOuter : ErrorFn

structure PrimitiveNegligibility (terms : KernelSoundnessTerms) where
  negligibleShoutCore : ∀ c, IsNegligible (terms.epsShoutCore c)
  negligibleAddr : ∀ f, IsNegligible (terms.epsAddr f)
  negligibleTwistRw : ∀ f, IsNegligible (terms.epsTwistRw f)
  negligibleTwistVal : ∀ f, IsNegligible (terms.epsTwistVal f)
  negligibleRamRaf : IsNegligible terms.epsRamRaf
  negligibleStage1Linkage : IsNegligible terms.epsStage1Linkage
  negligibleStage2Linkage : IsNegligible terms.epsStage2Linkage
  negligibleContinuity : IsNegligible terms.epsContinuity
  negligibleOpeningProvenance : IsNegligible terms.epsOpeningProvenance
  negligibleProgramBinding : IsNegligible terms.epsProgramBinding
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
      (sumErrorFns (stage1AddressFamilies.map terms.epsAddr) n +
        terms.epsStage1Linkage n)

def epsStage2 (terms : KernelSoundnessTerms) : ErrorFn :=
  fun n =>
    sumErrorFns (twistMemoryFamilies.map terms.epsTwistRw) n +
      (sumErrorFns (twistMemoryFamilies.map terms.epsTwistVal) n +
        (terms.epsAddr .reg n +
          terms.epsAddr .ram n +
          (terms.epsRamRaf n + terms.epsStage2Linkage n)))

def epsStage3 (terms : KernelSoundnessTerms) : ErrorFn :=
  fun n =>
    terms.epsContinuity n +
      terms.epsOpeningProvenance n

def epsKernelBinding (terms : KernelSoundnessTerms) : ErrorFn :=
  fun n =>
    terms.epsProgramBinding n +
      (terms.epsPCS n + (terms.epsFS n + terms.epsOuter n))

def epsTotalUpper (terms : KernelSoundnessTerms) : ErrorFn :=
  fun n =>
    epsStage1 terms n +
      (epsStage2 terms n + (epsStage3 terms n + epsKernelBinding terms n))

structure KernelSoundnessAccounting where
  terms : KernelSoundnessTerms
  primitiveNegligibility : PrimitiveNegligibility terms
  epsTotal : ErrorFn
  epsTotal_bound : ∀ n, epsTotal n ≤ epsTotalUpper terms n

theorem stage1ShoutChannels_nodup : stage1ShoutChannels.Nodup := by
  native_decide

theorem stage1AddressFamilies_nodup : stage1AddressFamilies.Nodup := by
  native_decide

theorem twistMemoryFamilies_nodup : twistMemoryFamilies.Nodup := by
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
      IsNegligible (sumErrorFns (stage1AddressFamilies.map terms.epsAddr)) := by
    apply isNegligible_sumErrorFns_map
    intro f hf
    exact hNeg.negligibleAddr f
  simpa [epsStage1] using
    isNegligible_add hCore (isNegligible_add hAddr hNeg.negligibleStage1Linkage)

theorem negligible_epsStage2
  {terms : KernelSoundnessTerms}
  (hNeg : PrimitiveNegligibility terms) :
  IsNegligible (epsStage2 terms) := by
  have hRw :
      IsNegligible (sumErrorFns (twistMemoryFamilies.map terms.epsTwistRw)) := by
    apply isNegligible_sumErrorFns_map
    intro f hf
    exact hNeg.negligibleTwistRw f
  have hVal :
      IsNegligible (sumErrorFns (twistMemoryFamilies.map terms.epsTwistVal)) := by
    apply isNegligible_sumErrorFns_map
    intro f hf
    exact hNeg.negligibleTwistVal f
  have hAddrRegRam :
      IsNegligible (fun n => terms.epsAddr .reg n + terms.epsAddr .ram n) := by
    exact isNegligible_add (hNeg.negligibleAddr .reg) (hNeg.negligibleAddr .ram)
  simpa [epsStage2] using
    isNegligible_add hRw <|
      isNegligible_add hVal <|
        isNegligible_add hAddrRegRam <|
          isNegligible_add hNeg.negligibleRamRaf hNeg.negligibleStage2Linkage

theorem negligible_epsStage3
  {terms : KernelSoundnessTerms}
  (hNeg : PrimitiveNegligibility terms) :
  IsNegligible (epsStage3 terms) := by
  simpa [epsStage3] using
    isNegligible_add hNeg.negligibleContinuity hNeg.negligibleOpeningProvenance

theorem negligible_epsKernelBinding
  {terms : KernelSoundnessTerms}
  (hNeg : PrimitiveNegligibility terms) :
  IsNegligible (epsKernelBinding terms) := by
  simpa [epsKernelBinding] using
    isNegligible_add hNeg.negligibleProgramBinding <|
      isNegligible_add hNeg.negligiblePCS <|
        isNegligible_add hNeg.negligibleFS hNeg.negligibleOuter

theorem negligible_epsTotalUpper
  {terms : KernelSoundnessTerms}
  (hNeg : PrimitiveNegligibility terms) :
  IsNegligible (epsTotalUpper terms) := by
  simpa [epsTotalUpper] using
    isNegligible_add
      (negligible_epsStage1 hNeg)
      (isNegligible_add
        (negligible_epsStage2 hNeg)
        (isNegligible_add
          (negligible_epsStage3 hNeg)
          (negligible_epsKernelBinding hNeg)))

theorem negligible_epsTotal
  (accounting : KernelSoundnessAccounting) :
  IsNegligible accounting.epsTotal := by
  apply isNegligible_of_le accounting.epsTotal_bound
  exact negligible_epsTotalUpper accounting.primitiveNegligibility

end Nightstream.Rv64IM
