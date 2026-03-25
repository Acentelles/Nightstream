import Nightstream.Rv64IM.Execution.ExactOpcodeFamilySemantics
import Nightstream.Rv64IM.Execution.MultiplyOpcodeSemantics
import Nightstream.Rv64IM.Execution.UnsignedDivRemOpcodeSemantics
import Nightstream.Rv64IM.Execution.SignedDivRemOpcodeSemantics

/-!
Owns theorem-facing hard-op concrete-to-reference lowering consequences above
exact opcode-family semantics. This file packages the reusable refinement facts
for multiply and DIV/REM families without re-owning exact opcode semantics,
case-backed imported-row checks, or trace/kernel closure.
-/

namespace Nightstream.Rv64IM

theorem normalizedReference_of_mulRefinedMultiplyOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : MulConcreteLoweringRefinesReference rows) :
  normalizeMulConcreteCore? rows = some mulReferenceLowering :=
  normalizedReference_of_mulRefinedMultiplyOpcodeSemantics h

theorem sequenceMetadataBound_of_mulRefinedMultiplyOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : MulConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  sequenceMetadataBound_of_mulRefinedMultiplyOpcodeSemantics h

theorem uniqueCommitRow_of_mulRefinedMultiplyOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : MulConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows mulEffectRowIndex :=
  uniqueCommitRow_of_mulRefinedMultiplyOpcodeSemantics h

theorem normalizedReference_of_mulhuRefinedMultiplyOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : MulhuConcreteLoweringRefinesReference rows) :
  normalizeMulhuConcreteCore? rows = some mulhuReferenceLowering :=
  normalizedReference_of_mulhuRefinedMultiplyOpcodeSemantics h

theorem sequenceMetadataBound_of_mulhuRefinedMultiplyOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : MulhuConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  sequenceMetadataBound_of_mulhuRefinedMultiplyOpcodeSemantics h

theorem uniqueCommitRow_of_mulhuRefinedMultiplyOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : MulhuConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows mulhuEffectRowIndex :=
  uniqueCommitRow_of_mulhuRefinedMultiplyOpcodeSemantics h

theorem normalizedReference_of_mulwRefinedMultiplyOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : MulwConcreteLoweringRefinesReference rows) :
  normalizeMulwConcreteCore? rows = some mulwReferenceLowering :=
  normalizedReference_of_mulwRefinedMultiplyOpcodeSemantics h

theorem sequenceMetadataBound_of_mulwRefinedMultiplyOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : MulwConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  sequenceMetadataBound_of_mulwRefinedMultiplyOpcodeSemantics h

theorem uniqueCommitRow_of_mulwRefinedMultiplyOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : MulwConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows mulwEffectRowIndex :=
  uniqueCommitRow_of_mulwRefinedMultiplyOpcodeSemantics h

theorem normalizedReference_of_mulhRefinedMultiplyOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : MulhConcreteLoweringRefinesReference rows) :
  normalizeMulhConcreteCore? rows = some mulhReferenceLowering :=
  normalizedReference_of_mulhRefinedMultiplyOpcodeSemantics h

theorem sequenceMetadataBound_of_mulhRefinedMultiplyOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : MulhConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  sequenceMetadataBound_of_mulhRefinedMultiplyOpcodeSemantics h

theorem closureSuffixScratchOnly_of_mulhRefinedMultiplyOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : MulhConcreteLoweringRefinesReference rows) :
  mulhClosureSuffixScratchOnly rows :=
  closureSuffixScratchOnly_of_mulhRefinedMultiplyOpcodeSemantics h

theorem uniqueCommitRow_of_mulhRefinedMultiplyOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : MulhConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows mulhEffectRowIndex :=
  uniqueCommitRow_of_mulhRefinedMultiplyOpcodeSemantics h

theorem effectRowPrecedesCommitRow_of_mulhRefinedMultiplyOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : MulhConcreteLoweringRefinesReference rows) :
  mulhEffectRowIndex ≤ rows.length - 1 :=
  effectRowPrecedesCommitRow_of_mulhRefinedMultiplyOpcodeSemantics h

theorem normalizedReference_of_mulhsuRefinedMultiplyOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : MulhsuConcreteLoweringRefinesReference rows) :
  normalizeMulhsuConcreteCore? rows = some mulhsuReferenceLowering :=
  normalizedReference_of_mulhsuRefinedMultiplyOpcodeSemantics h

theorem sequenceMetadataBound_of_mulhsuRefinedMultiplyOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : MulhsuConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  sequenceMetadataBound_of_mulhsuRefinedMultiplyOpcodeSemantics h

theorem closureSuffixScratchOnly_of_mulhsuRefinedMultiplyOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : MulhsuConcreteLoweringRefinesReference rows) :
  mulhsuClosureSuffixScratchOnly rows :=
  closureSuffixScratchOnly_of_mulhsuRefinedMultiplyOpcodeSemantics h

theorem uniqueCommitRow_of_mulhsuRefinedMultiplyOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : MulhsuConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows mulhsuEffectRowIndex :=
  uniqueCommitRow_of_mulhsuRefinedMultiplyOpcodeSemantics h

theorem effectRowPrecedesCommitRow_of_mulhsuRefinedMultiplyOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : MulhsuConcreteLoweringRefinesReference rows) :
  mulhsuEffectRowIndex ≤ rows.length - 1 :=
  effectRowPrecedesCommitRow_of_mulhsuRefinedMultiplyOpcodeSemantics h

theorem normalizedReference_of_divuRefinedUnsignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : DivuConcreteLoweringRefinesReference rows) :
  normalizeDivuConcreteCore? rows = some divuReferenceLowering :=
  normalizedReference_of_divuRefinedUnsignedDivRemOpcodeSemantics h

theorem sequenceMetadataBound_of_divuRefinedUnsignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : DivuConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  sequenceMetadataBound_of_divuRefinedUnsignedDivRemOpcodeSemantics h

theorem closureSuffixScratchOnly_of_divuRefinedUnsignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : DivuConcreteLoweringRefinesReference rows) :
  divuClosureSuffixScratchOnly rows :=
  closureSuffixScratchOnly_of_divuRefinedUnsignedDivRemOpcodeSemantics h

theorem uniqueCommitRow_of_divuRefinedUnsignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : DivuConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows divuEffectRowIndex :=
  uniqueCommitRow_of_divuRefinedUnsignedDivRemOpcodeSemantics h

theorem effectRowPrecedesCommitRow_of_divuRefinedUnsignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : DivuConcreteLoweringRefinesReference rows) :
  divuEffectRowIndex ≤ rows.length - 1 :=
  effectRowPrecedesCommitRow_of_divuRefinedUnsignedDivRemOpcodeSemantics h

theorem normalizedReference_of_remuRefinedUnsignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : RemuConcreteLoweringRefinesReference rows) :
  normalizeRemuConcreteCore? rows = some remuReferenceLowering :=
  normalizedReference_of_remuRefinedUnsignedDivRemOpcodeSemantics h

theorem sequenceMetadataBound_of_remuRefinedUnsignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : RemuConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  sequenceMetadataBound_of_remuRefinedUnsignedDivRemOpcodeSemantics h

theorem closureSuffixScratchOnly_of_remuRefinedUnsignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : RemuConcreteLoweringRefinesReference rows) :
  remuClosureSuffixScratchOnly rows :=
  closureSuffixScratchOnly_of_remuRefinedUnsignedDivRemOpcodeSemantics h

theorem uniqueCommitRow_of_remuRefinedUnsignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : RemuConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows remuEffectRowIndex :=
  uniqueCommitRow_of_remuRefinedUnsignedDivRemOpcodeSemantics h

theorem effectRowPrecedesCommitRow_of_remuRefinedUnsignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : RemuConcreteLoweringRefinesReference rows) :
  remuEffectRowIndex ≤ rows.length - 1 :=
  effectRowPrecedesCommitRow_of_remuRefinedUnsignedDivRemOpcodeSemantics h

theorem normalizedReference_of_divuwRefinedUnsignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : DivuwConcreteLoweringRefinesReference rows) :
  normalizeDivuwConcreteCore? rows = some divuwReferenceLowering :=
  normalizedReference_of_divuwRefinedUnsignedDivRemOpcodeSemantics h

theorem sequenceMetadataBound_of_divuwRefinedUnsignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : DivuwConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  sequenceMetadataBound_of_divuwRefinedUnsignedDivRemOpcodeSemantics h

theorem closureSuffixScratchOnly_of_divuwRefinedUnsignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : DivuwConcreteLoweringRefinesReference rows) :
  divuwClosureSuffixScratchOnly rows :=
  closureSuffixScratchOnly_of_divuwRefinedUnsignedDivRemOpcodeSemantics h

theorem uniqueCommitRow_of_divuwRefinedUnsignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : DivuwConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows divuwEffectRowIndex :=
  uniqueCommitRow_of_divuwRefinedUnsignedDivRemOpcodeSemantics h

theorem effectRowPrecedesCommitRow_of_divuwRefinedUnsignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : DivuwConcreteLoweringRefinesReference rows) :
  divuwEffectRowIndex ≤ rows.length - 1 :=
  effectRowPrecedesCommitRow_of_divuwRefinedUnsignedDivRemOpcodeSemantics h

theorem normalizedReference_of_remuwRefinedUnsignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : RemuwConcreteLoweringRefinesReference rows) :
  normalizeRemuwConcreteCore? rows = some remuwReferenceLowering :=
  normalizedReference_of_remuwRefinedUnsignedDivRemOpcodeSemantics h

theorem sequenceMetadataBound_of_remuwRefinedUnsignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : RemuwConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  sequenceMetadataBound_of_remuwRefinedUnsignedDivRemOpcodeSemantics h

theorem closureSuffixScratchOnly_of_remuwRefinedUnsignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : RemuwConcreteLoweringRefinesReference rows) :
  remuwClosureSuffixScratchOnly rows :=
  closureSuffixScratchOnly_of_remuwRefinedUnsignedDivRemOpcodeSemantics h

theorem uniqueCommitRow_of_remuwRefinedUnsignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : RemuwConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows remuwEffectRowIndex :=
  uniqueCommitRow_of_remuwRefinedUnsignedDivRemOpcodeSemantics h

theorem effectRowPrecedesCommitRow_of_remuwRefinedUnsignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : RemuwConcreteLoweringRefinesReference rows) :
  remuwEffectRowIndex ≤ rows.length - 1 :=
  effectRowPrecedesCommitRow_of_remuwRefinedUnsignedDivRemOpcodeSemantics h

theorem normalizedReference_of_divRefinedSignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : DivConcreteLoweringRefinesReference rows) :
  normalizeDivConcreteCore? rows = some divReferenceLowering :=
  normalizedReference_of_divRefinedSignedDivRemOpcodeSemantics h

theorem sequenceMetadataBound_of_divRefinedSignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : DivConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  sequenceMetadataBound_of_divRefinedSignedDivRemOpcodeSemantics h

theorem closureSuffixScratchOnly_of_divRefinedSignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : DivConcreteLoweringRefinesReference rows) :
  divClosureSuffixScratchOnly rows :=
  closureSuffixScratchOnly_of_divRefinedSignedDivRemOpcodeSemantics h

theorem uniqueCommitRow_of_divRefinedSignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : DivConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows divEffectRowIndex :=
  uniqueCommitRow_of_divRefinedSignedDivRemOpcodeSemantics h

theorem effectRowPrecedesCommitRow_of_divRefinedSignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : DivConcreteLoweringRefinesReference rows) :
  divEffectRowIndex ≤ rows.length - 1 :=
  effectRowPrecedesCommitRow_of_divRefinedSignedDivRemOpcodeSemantics h

theorem normalizedReference_of_remRefinedSignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : RemConcreteLoweringRefinesReference rows) :
  normalizeRemConcreteCore? rows = some remReferenceLowering :=
  normalizedReference_of_remRefinedSignedDivRemOpcodeSemantics h

theorem sequenceMetadataBound_of_remRefinedSignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : RemConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  sequenceMetadataBound_of_remRefinedSignedDivRemOpcodeSemantics h

theorem closureSuffixScratchOnly_of_remRefinedSignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : RemConcreteLoweringRefinesReference rows) :
  remClosureSuffixScratchOnly rows :=
  closureSuffixScratchOnly_of_remRefinedSignedDivRemOpcodeSemantics h

theorem uniqueCommitRow_of_remRefinedSignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : RemConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows remEffectRowIndex :=
  uniqueCommitRow_of_remRefinedSignedDivRemOpcodeSemantics h

theorem effectRowPrecedesCommitRow_of_remRefinedSignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : RemConcreteLoweringRefinesReference rows) :
  remEffectRowIndex ≤ rows.length - 1 :=
  effectRowPrecedesCommitRow_of_remRefinedSignedDivRemOpcodeSemantics h

theorem normalizedReference_of_divwRefinedSignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : DivwConcreteLoweringRefinesReference rows) :
  normalizeDivwConcreteCore? rows = some divwReferenceLowering :=
  normalizedReference_of_divwRefinedSignedDivRemOpcodeSemantics h

theorem sequenceMetadataBound_of_divwRefinedSignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : DivwConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  sequenceMetadataBound_of_divwRefinedSignedDivRemOpcodeSemantics h

theorem closureSuffixScratchOnly_of_divwRefinedSignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : DivwConcreteLoweringRefinesReference rows) :
  divwClosureSuffixScratchOnly rows :=
  closureSuffixScratchOnly_of_divwRefinedSignedDivRemOpcodeSemantics h

theorem uniqueCommitRow_of_divwRefinedSignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : DivwConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows divwEffectRowIndex :=
  uniqueCommitRow_of_divwRefinedSignedDivRemOpcodeSemantics h

theorem effectRowPrecedesCommitRow_of_divwRefinedSignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : DivwConcreteLoweringRefinesReference rows) :
  divwEffectRowIndex ≤ rows.length - 1 :=
  effectRowPrecedesCommitRow_of_divwRefinedSignedDivRemOpcodeSemantics h

theorem normalizedReference_of_remwRefinedSignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : RemwConcreteLoweringRefinesReference rows) :
  normalizeRemwConcreteCore? rows = some remwReferenceLowering :=
  normalizedReference_of_remwRefinedSignedDivRemOpcodeSemantics h

theorem sequenceMetadataBound_of_remwRefinedSignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : RemwConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  sequenceMetadataBound_of_remwRefinedSignedDivRemOpcodeSemantics h

theorem closureSuffixScratchOnly_of_remwRefinedSignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : RemwConcreteLoweringRefinesReference rows) :
  remwClosureSuffixScratchOnly rows :=
  closureSuffixScratchOnly_of_remwRefinedSignedDivRemOpcodeSemantics h

theorem uniqueCommitRow_of_remwRefinedSignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : RemwConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows remwEffectRowIndex :=
  uniqueCommitRow_of_remwRefinedSignedDivRemOpcodeSemantics h

theorem effectRowPrecedesCommitRow_of_remwRefinedSignedDivRemOpcodeSemantics_of_hardOpLoweringRefinementSemantics
  {rows : List ImportedLoweringRow}
  (h : RemwConcreteLoweringRefinesReference rows) :
  remwEffectRowIndex ≤ rows.length - 1 :=
  effectRowPrecedesCommitRow_of_remwRefinedSignedDivRemOpcodeSemantics h

end Nightstream.Rv64IM
