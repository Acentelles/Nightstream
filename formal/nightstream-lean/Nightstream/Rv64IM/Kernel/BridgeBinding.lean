import Nightstream.Rv64IM.Kernel.OpeningProvenance
import Nightstream.Rv64IM.Stage3.Stage3Refinement

namespace Nightstream.Rv64IM

structure KernelBridgeBindingWitness
  (Pc Row PreparedStep Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding : Type _)
  (stage3 : Stage3ProofPackage Pc Row PreparedStep) where
  provenance :
    OpeningProvenanceProofPackage
      Source
      CommitmentId
      Point
      PolynomialId
      Value
      Digest
      ExactOpeningWitness
      OpeningRefinement
      RowProjectionWitness
      BridgeBinding
      PreparedStep
  exportedStepIndex : Nat
  exportedBinding : RowProjectionBinding Row PreparedStep
  exportedBindingAtIndex :
    stage3.rowBindings[exportedStepIndex]? = some exportedBinding
  samePreparedStep :
    provenance.chain.preparedStep = exportedBinding.preparedStep

def KernelBridgeTraceBound
  (stage3 : Stage3ProofPackage Pc Row PreparedStep)
  (bindings :
    List
      (KernelBridgeBindingWitness
        Pc
        Row
        PreparedStep
        Source
        CommitmentId
        Point
        PolynomialId
        Value
        Digest
        ExactOpeningWitness
        OpeningRefinement
        RowProjectionWitness
        BridgeBinding
        stage3)) : Prop :=
  bindings.length = stage3.rowBindings.length ∧
    ∀ j, j < stage3.rowBindings.length →
      ∃ w, bindings[j]? = some w ∧ w.exportedStepIndex = j

theorem preparedStep_mem_rowBindings_of_kernelBridgeBindingWitness
  {Pc Row PreparedStep Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding : Type _}
  {stage3 : Stage3ProofPackage Pc Row PreparedStep}
  (w :
    KernelBridgeBindingWitness
      Pc
      Row
      PreparedStep
      Source
      CommitmentId
      Point
      PolynomialId
      Value
      Digest
      ExactOpeningWitness
      OpeningRefinement
      RowProjectionWitness
      BridgeBinding
      stage3) :
  w.exportedBinding ∈ stage3.rowBindings := by
  exact List.mem_of_getElem? w.exportedBindingAtIndex

theorem kernelBridgeBindingWitness_at_index_of_kernelBridgeTraceBound
  {Pc Row PreparedStep Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding : Type _}
  {stage3 : Stage3ProofPackage Pc Row PreparedStep}
  {bindings :
    List
      (KernelBridgeBindingWitness
        Pc
        Row
        PreparedStep
        Source
        CommitmentId
        Point
        PolynomialId
        Value
        Digest
        ExactOpeningWitness
        OpeningRefinement
        RowProjectionWitness
        BridgeBinding
        stage3)}
  (hBound : KernelBridgeTraceBound stage3 bindings)
  {j : Nat}
  (hJ : j < stage3.rowBindings.length) :
  ∃ w, bindings[j]? = some w ∧ w.exportedStepIndex = j :=
  hBound.2 j hJ

theorem exactBridgeBindingAtIndex_of_kernelBridgeTraceBound
  {Pc Row PreparedStep Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding : Type _}
  {stage3 : Stage3ProofPackage Pc Row PreparedStep}
  {bindings :
    List
      (KernelBridgeBindingWitness
        Pc
        Row
        PreparedStep
        Source
        CommitmentId
        Point
        PolynomialId
        Value
        Digest
        ExactOpeningWitness
        OpeningRefinement
        RowProjectionWitness
        BridgeBinding
        stage3)}
  (hBound : KernelBridgeTraceBound stage3 bindings)
  {j : Nat}
  (hJ : j < stage3.rowBindings.length) :
  ∃ w,
    bindings[j]? = some w ∧
      stage3.rowBindings[j]? = some w.exportedBinding ∧
      w.provenance.chain.preparedStep = w.exportedBinding.preparedStep := by
  rcases kernelBridgeBindingWitness_at_index_of_kernelBridgeTraceBound hBound hJ with
    ⟨w, hBinding, hIndex⟩
  refine ⟨w, hBinding, ?_, w.samePreparedStep⟩
  simpa [hIndex] using w.exportedBindingAtIndex

theorem preparedStep_exported_of_kernelBridgeBindingWitness
  {Pc Row PreparedStep Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding : Type _}
  {stage3 : Stage3ProofPackage Pc Row PreparedStep}
  (w :
    KernelBridgeBindingWitness
      Pc
      Row
      PreparedStep
      Source
      CommitmentId
      Point
      PolynomialId
      Value
      Digest
      ExactOpeningWitness
      OpeningRefinement
      RowProjectionWitness
      BridgeBinding
      stage3) :
  w.provenance.chain.preparedStep ∈
    stage3.rowBindings.map RowProjectionBinding.preparedStep := by
  rw [w.samePreparedStep]
  exact List.mem_map.mpr
    ⟨w.exportedBinding, preparedStep_mem_rowBindings_of_kernelBridgeBindingWitness w, rfl⟩

theorem preparedStep_exported_at_index_of_kernelBridgeTraceBound
  {Pc Row PreparedStep Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding : Type _}
  {stage3 : Stage3ProofPackage Pc Row PreparedStep}
  {bindings :
    List
      (KernelBridgeBindingWitness
        Pc
        Row
        PreparedStep
        Source
        CommitmentId
        Point
        PolynomialId
        Value
        Digest
        ExactOpeningWitness
        OpeningRefinement
        RowProjectionWitness
        BridgeBinding
        stage3)}
  (hBound : KernelBridgeTraceBound stage3 bindings)
  {j : Nat}
  (hJ : j < stage3.rowBindings.length) :
  ∃ step,
    bindings[j]?.map (fun w => w.provenance.chain.preparedStep) = some step ∧
      stage3.rowBindings[j]?.map RowProjectionBinding.preparedStep = some step := by
  rcases exactBridgeBindingAtIndex_of_kernelBridgeTraceBound hBound hJ with
    ⟨w, hBinding, hRow, hStep⟩
  refine ⟨w.provenance.chain.preparedStep, ?_, ?_⟩
  · simp [hBinding]
  · simp [hRow, hStep]

end Nightstream.Rv64IM
