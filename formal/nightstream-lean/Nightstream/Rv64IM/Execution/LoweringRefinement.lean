import Nightstream.Rv64IM.Generated.ParityTypes

/-!
Owns execution-level refinement predicates that relate imported concrete lowered
row sequences to the RV64IM reference lowering catalog. This owner currently
covers the multiply family, including Jolt-like multi-row concrete lowerings.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated

abbrev ImportedLoweringRow := ExpandedRowView

def inlineScratchRegisterBase : Nat := 40
def inlineScratchRegisterLimit : Nat := 48

private def isInlineScratchRegisterB (reg : Nat) : Bool :=
  decide (inlineScratchRegisterBase ≤ reg ∧ reg < inlineScratchRegisterLimit)

def isInlineScratchRegister (reg : Nat) : Prop :=
  isInlineScratchRegisterB reg = true

inductive MulReferenceStep where
  | mul
deriving DecidableEq, Repr

inductive MulhuReferenceStep where
  | mulhu
deriving DecidableEq, Repr

inductive MulwReferenceStep where
  | mul
  | signExtendWord
deriving DecidableEq, Repr

inductive MulhReferenceStep where
  | movsignRs1
  | movsignRs2
  | mulhuUnsigned
  | mulSignRs2
  | mulSignRs1
  | addHighCorrection
  | addArchitectural
deriving DecidableEq, Repr

inductive MulhsuReferenceStep where
  | movsignRs1
  | andiSignMask
  | xorUnsignedPart
  | addUnsignedCorrection
  | mulhuUnsigned
  | mulLow
  | xorHighWithSign
  | xorLowWithSign
  | addCarrySeed
  | sltuCarryOut
  | addArchitectural
deriving DecidableEq, Repr

inductive UnsignedDivRemReferenceStep where
  | adviceQuotient
  | assertValidDiv0
  | assertMulNoOverflow
  | mulProduct
  | assertProductLteDividend
  | subRemainder
  | assertValidUnsignedRemainder
  | moveArchitectural
  | signExtendWord
deriving DecidableEq, Repr

inductive SignedDivRemReferenceStep where
  | changeDivisor
  | adviceQuotient
  | mulProduct
  | subRemainder
  | assertSignedDivIdentity
  | assertSignedRemainderBounds
  | moveArchitectural
  | signExtendWord
deriving DecidableEq, Repr

def mulReferenceLowering : List MulReferenceStep := [.mul]
def mulhuReferenceLowering : List MulhuReferenceStep := [.mulhu]
def mulwReferenceLowering : List MulwReferenceStep := [.mul, .signExtendWord]

def mulhReferenceLowering : List MulhReferenceStep :=
  [ .movsignRs1
  , .movsignRs2
  , .mulhuUnsigned
  , .mulSignRs2
  , .mulSignRs1
  , .addHighCorrection
  , .addArchitectural
  ]

def mulhsuReferenceLowering : List MulhsuReferenceStep :=
  [ .movsignRs1
  , .andiSignMask
  , .xorUnsignedPart
  , .addUnsignedCorrection
  , .mulhuUnsigned
  , .mulLow
  , .xorHighWithSign
  , .xorLowWithSign
  , .addCarrySeed
  , .sltuCarryOut
  , .addArchitectural
  ]

def divuReferenceLowering : List UnsignedDivRemReferenceStep :=
  [ .adviceQuotient
  , .assertValidDiv0
  , .assertMulNoOverflow
  , .mulProduct
  , .assertProductLteDividend
  , .subRemainder
  , .assertValidUnsignedRemainder
  , .moveArchitectural
  ]

def remuReferenceLowering : List UnsignedDivRemReferenceStep :=
  divuReferenceLowering

def divuwReferenceLowering : List UnsignedDivRemReferenceStep :=
  divuReferenceLowering ++ [.signExtendWord]

def remuwReferenceLowering : List UnsignedDivRemReferenceStep :=
  remuReferenceLowering ++ [.signExtendWord]

def divReferenceLowering : List SignedDivRemReferenceStep :=
  [ .changeDivisor
  , .adviceQuotient
  , .mulProduct
  , .subRemainder
  , .assertSignedDivIdentity
  , .assertSignedRemainderBounds
  , .moveArchitectural
  ]

def remReferenceLowering : List SignedDivRemReferenceStep :=
  divReferenceLowering

def divwReferenceLowering : List SignedDivRemReferenceStep :=
  divReferenceLowering ++ [.signExtendWord]

def remwReferenceLowering : List SignedDivRemReferenceStep :=
  remReferenceLowering ++ [.signExtendWord]

def mulEffectRowIndex : Nat := 0
def mulhuEffectRowIndex : Nat := 0
def mulwEffectRowIndex : Nat := 1
def mulhEffectRowIndex : Nat := 6
def mulhsuEffectRowIndex : Nat := 10
def divuEffectRowIndex : Nat := 7
def remuEffectRowIndex : Nat := 7
def divuwEffectRowIndex : Nat := 8
def remuwEffectRowIndex : Nat := 8
def divEffectRowIndex : Nat := 6
def remEffectRowIndex : Nat := 6
def divwEffectRowIndex : Nat := 7
def remwEffectRowIndex : Nat := 7

private def expectedVirtualSequenceRemaining (rows : List ImportedLoweringRow) (idx : Nat) :
    Option Nat :=
  if rows.length = 1 then
    none
  else
    some (rows.length - idx - 1)

private def rowSequenceMetadataBoundAux
    (rows : List ImportedLoweringRow) : Nat → List ImportedLoweringRow → Bool
  | _, [] => true
  | idx, row :: rest =>
      decide (row.sequenceIndex = idx) &&
        decide (row.isFirstInSequence = decide (idx = 0)) &&
        decide (row.virtualSequenceRemaining = expectedVirtualSequenceRemaining rows idx) &&
        rowSequenceMetadataBoundAux rows (idx + 1) rest

private def rowSequenceMetadataBoundB (rows : List ImportedLoweringRow) : Bool :=
  rowSequenceMetadataBoundAux rows 0 rows

def rowSequenceMetadataBound (rows : List ImportedLoweringRow) : Prop :=
  rowSequenceMetadataBoundB rows = true

private def isInlineScratchCleanupRowB (row : ImportedLoweringRow) : Bool :=
  decide (row.traceOpcode = some .addi) &&
    decide (row.traceVirtualOpcode = none) &&
    decide (row.rs1 = 0) &&
    decide (row.rs2 = 0) &&
    decide (row.imm = 0) &&
    isInlineScratchRegisterB row.rd &&
    decide (row.writesRd = true) &&
    decide (row.writesRam = false)

def isInlineScratchCleanupRow (row : ImportedLoweringRow) : Prop :=
  isInlineScratchCleanupRowB row = true

private def closureSuffixRowsAfter (effectRowIndex : Nat) (rows : List ImportedLoweringRow) :
    List ImportedLoweringRow :=
  rows.drop (effectRowIndex + 1)

private def closureSuffixScratchOnlyAfterB (effectRowIndex : Nat)
    (rows : List ImportedLoweringRow) : Bool :=
  (closureSuffixRowsAfter effectRowIndex rows).all isInlineScratchCleanupRowB

def mulhClosureSuffixRows (rows : List ImportedLoweringRow) : List ImportedLoweringRow :=
  closureSuffixRowsAfter mulhEffectRowIndex rows

def mulhsuClosureSuffixRows (rows : List ImportedLoweringRow) : List ImportedLoweringRow :=
  closureSuffixRowsAfter mulhsuEffectRowIndex rows

def divuClosureSuffixRows (rows : List ImportedLoweringRow) : List ImportedLoweringRow :=
  closureSuffixRowsAfter divuEffectRowIndex rows

def remuClosureSuffixRows (rows : List ImportedLoweringRow) : List ImportedLoweringRow :=
  closureSuffixRowsAfter remuEffectRowIndex rows

def divuwClosureSuffixRows (rows : List ImportedLoweringRow) : List ImportedLoweringRow :=
  closureSuffixRowsAfter divuwEffectRowIndex rows

def remuwClosureSuffixRows (rows : List ImportedLoweringRow) : List ImportedLoweringRow :=
  closureSuffixRowsAfter remuwEffectRowIndex rows

def divClosureSuffixRows (rows : List ImportedLoweringRow) : List ImportedLoweringRow :=
  closureSuffixRowsAfter divEffectRowIndex rows

def remClosureSuffixRows (rows : List ImportedLoweringRow) : List ImportedLoweringRow :=
  closureSuffixRowsAfter remEffectRowIndex rows

def divwClosureSuffixRows (rows : List ImportedLoweringRow) : List ImportedLoweringRow :=
  closureSuffixRowsAfter divwEffectRowIndex rows

def remwClosureSuffixRows (rows : List ImportedLoweringRow) : List ImportedLoweringRow :=
  closureSuffixRowsAfter remwEffectRowIndex rows

def mulhClosureSuffixScratchOnly (rows : List ImportedLoweringRow) : Prop :=
  closureSuffixScratchOnlyAfterB mulhEffectRowIndex rows = true

def mulhsuClosureSuffixScratchOnly (rows : List ImportedLoweringRow) : Prop :=
  closureSuffixScratchOnlyAfterB mulhsuEffectRowIndex rows = true

def divuClosureSuffixScratchOnly (rows : List ImportedLoweringRow) : Prop :=
  closureSuffixScratchOnlyAfterB divuEffectRowIndex rows = true

def remuClosureSuffixScratchOnly (rows : List ImportedLoweringRow) : Prop :=
  closureSuffixScratchOnlyAfterB remuEffectRowIndex rows = true

def divuwClosureSuffixScratchOnly (rows : List ImportedLoweringRow) : Prop :=
  closureSuffixScratchOnlyAfterB divuwEffectRowIndex rows = true

def remuwClosureSuffixScratchOnly (rows : List ImportedLoweringRow) : Prop :=
  closureSuffixScratchOnlyAfterB remuwEffectRowIndex rows = true

def divClosureSuffixScratchOnly (rows : List ImportedLoweringRow) : Prop :=
  closureSuffixScratchOnlyAfterB divEffectRowIndex rows = true

def remClosureSuffixScratchOnly (rows : List ImportedLoweringRow) : Prop :=
  closureSuffixScratchOnlyAfterB remEffectRowIndex rows = true

def divwClosureSuffixScratchOnly (rows : List ImportedLoweringRow) : Prop :=
  closureSuffixScratchOnlyAfterB divwEffectRowIndex rows = true

def remwClosureSuffixScratchOnly (rows : List ImportedLoweringRow) : Prop :=
  closureSuffixScratchOnlyAfterB remwEffectRowIndex rows = true

private def uniqueRealRowAtAux (target current : Nat) : List ImportedLoweringRow → Bool
  | [] => true
  | row :: rest =>
      (if current = target then row.isReal else !row.isReal) &&
        uniqueRealRowAtAux target (current + 1) rest

private def uniqueRealRowAtB (rows : List ImportedLoweringRow) (idx : Nat) : Bool :=
  decide (idx < rows.length) && uniqueRealRowAtAux idx 0 rows

def uniqueRealRowAt (rows : List ImportedLoweringRow) (idx : Nat) : Prop :=
  uniqueRealRowAtB rows idx = true

private def uniqueFlaggedRowAtAux
    (target current : Nat)
    (flag : ImportedLoweringRow → Bool) : List ImportedLoweringRow → Bool
  | [] => true
  | row :: rest =>
      (if current = target then flag row else !(flag row)) &&
        uniqueFlaggedRowAtAux target (current + 1) flag rest

private def uniqueEffectRowAtB (rows : List ImportedLoweringRow) (idx : Nat) : Bool :=
  decide (idx < rows.length) && uniqueFlaggedRowAtAux idx 0 (fun row => row.isEffectRow) rows

def uniqueEffectRowAt (rows : List ImportedLoweringRow) (idx : Nat) : Prop :=
  uniqueEffectRowAtB rows idx = true

private def uniqueCommitRowAtB (rows : List ImportedLoweringRow) (idx : Nat) : Bool :=
  decide (idx < rows.length) && uniqueFlaggedRowAtAux idx 0 (fun row => row.isCommitRow) rows

def uniqueCommitRowAt (rows : List ImportedLoweringRow) (idx : Nat) : Prop :=
  uniqueCommitRowAtB rows idx = true

private def singleRowConcreteShapeB (opcode traceOpcode : Opcode) : List ImportedLoweringRow → Bool
  | [row] =>
      decide (row.opcode = opcode) &&
        decide (row.traceOpcode = some traceOpcode) &&
        decide (row.traceVirtualOpcode = none) &&
        decide (row.rd < 32) &&
        decide (row.rs1 < 32) &&
        decide (row.rs2 < 32) &&
        decide (row.writesRd = true) &&
        decide (row.writesRam = false) &&
        decide (row.isReal = true)
  | _ => false

def mulConcreteCoreShape (rows : List ImportedLoweringRow) : Prop :=
  singleRowConcreteShapeB .mul .mul rows = true

def mulhuConcreteCoreShape (rows : List ImportedLoweringRow) : Prop :=
  singleRowConcreteShapeB .mulhu .mulhu rows = true

def normalizeMulConcreteCore? (rows : List ImportedLoweringRow) :
    Option (List MulReferenceStep) :=
  if singleRowConcreteShapeB .mul .mul rows then
    some mulReferenceLowering
  else
    none

def normalizeMulhuConcreteCore? (rows : List ImportedLoweringRow) :
    Option (List MulhuReferenceStep) :=
  if singleRowConcreteShapeB .mulhu .mulhu rows then
    some mulhuReferenceLowering
  else
    none

private def mulwConcreteCoreShapeB : List ImportedLoweringRow → Bool
  | [r0, r1] =>
      let archRd := r0.rd
      decide (r0.opcode = .mulw) &&
        decide (r1.opcode = .mulw) &&
        decide (archRd < 32) &&
        decide (r0.rs1 < 32) &&
        decide (r0.rs2 < 32) &&
        decide (r0.traceOpcode = some .mul) &&
        decide (r0.traceVirtualOpcode = none) &&
        decide (r0.writesRd = true) &&
        decide (r0.writesRam = false) &&
        decide (r0.isReal = false) &&
        decide (r1.traceOpcode = none) &&
        decide (r1.traceVirtualOpcode = some .signExtendWord) &&
        decide (r1.rd = archRd) &&
        decide (r1.rs1 = archRd) &&
        decide (r1.rs2 = 0) &&
        decide (r1.imm = 0) &&
        decide (r1.writesRd = true) &&
        decide (r1.writesRam = false) &&
        decide (r1.isReal = true)
  | _ => false

def mulwConcreteCoreShape (rows : List ImportedLoweringRow) : Prop :=
  mulwConcreteCoreShapeB rows = true

def normalizeMulwConcreteCore? (rows : List ImportedLoweringRow) :
    Option (List MulwReferenceStep) :=
  if mulwConcreteCoreShapeB rows then
    some mulwReferenceLowering
  else
    none

private def mulhConcreteCoreShapeB : List ImportedLoweringRow → Bool
  | [r0, r1, r2, r3, r4, r5, r6] =>
      let archRs1 := r0.rs1
      let archRs2 := r1.rs1
      let sx := r0.rd
      let sy := r1.rd
      let h0 := r4.rd
      let archRd := r6.rd
      decide (r0.opcode = .mulh) &&
        decide (r1.opcode = .mulh) &&
        decide (r2.opcode = .mulh) &&
        decide (r3.opcode = .mulh) &&
        decide (r4.opcode = .mulh) &&
        decide (r5.opcode = .mulh) &&
        decide (r6.opcode = .mulh) &&
        decide (archRs1 < 32) &&
        decide (archRs2 < 32) &&
        decide (archRd < 32) &&
        isInlineScratchRegisterB sx &&
        isInlineScratchRegisterB sy &&
        isInlineScratchRegisterB h0 &&
        decide (sx ≠ sy) &&
        decide (sx ≠ h0) &&
        decide (sy ≠ h0) &&
        decide (r0.traceOpcode = none) &&
        decide (r0.traceVirtualOpcode = some .movsign) &&
        decide (r0.rs2 = 0) &&
        decide (r0.imm = 0) &&
        decide (r1.traceOpcode = none) &&
        decide (r1.traceVirtualOpcode = some .movsign) &&
        decide (r1.rs2 = 0) &&
        decide (r1.imm = 0) &&
        decide (r2.traceOpcode = some .mul) &&
        decide (r2.traceVirtualOpcode = none) &&
        decide (r2.rd = sx) &&
        decide (r2.rs1 = sx) &&
        decide (r2.rs2 = archRs2) &&
        decide (r3.traceOpcode = some .mul) &&
        decide (r3.traceVirtualOpcode = none) &&
        decide (r3.rd = sy) &&
        decide (r3.rs1 = sy) &&
        decide (r3.rs2 = archRs1) &&
        decide (r4.traceOpcode = some .mulhu) &&
        decide (r4.traceVirtualOpcode = none) &&
        decide (r4.rs1 = archRs1) &&
        decide (r4.rs2 = archRs2) &&
        decide (r5.traceOpcode = some .add) &&
        decide (r5.traceVirtualOpcode = none) &&
        decide (r5.rd = h0) &&
        decide (r5.rs1 = h0) &&
        decide (r5.rs2 = sx) &&
        decide (r6.traceOpcode = some .add) &&
        decide (r6.traceVirtualOpcode = none) &&
        decide (r6.rd = archRd) &&
        decide (r6.rs1 = h0) &&
        decide (r6.rs2 = sy) &&
        decide (r6.writesRd = true) &&
        decide (r6.writesRam = false) &&
        decide (r6.isReal = true)
  | _ => false

def mulhConcreteCoreShape (rows : List ImportedLoweringRow) : Prop :=
  mulhConcreteCoreShapeB rows = true

def normalizeMulhConcreteCore? (rows : List ImportedLoweringRow) :
    Option (List MulhReferenceStep) :=
  if mulhConcreteCoreShapeB rows then
    some mulhReferenceLowering
  else
    none

private def mulhsuConcreteCoreShapeB : List ImportedLoweringRow → Bool
  | [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10] =>
      let archRs1 := r0.rs1
      let archRs2 := r4.rs2
      let v0 := r0.rd
      let v1 := r1.rd
      let v2 := r2.rd
      let v3 := r4.rd
      let archRd := r10.rd
      decide (r0.opcode = .mulhsu) &&
        decide (r1.opcode = .mulhsu) &&
        decide (r2.opcode = .mulhsu) &&
        decide (r3.opcode = .mulhsu) &&
        decide (r4.opcode = .mulhsu) &&
        decide (r5.opcode = .mulhsu) &&
        decide (r6.opcode = .mulhsu) &&
        decide (r7.opcode = .mulhsu) &&
        decide (r8.opcode = .mulhsu) &&
        decide (r9.opcode = .mulhsu) &&
        decide (r10.opcode = .mulhsu) &&
        decide (archRs1 < 32) &&
        decide (archRs2 < 32) &&
        decide (archRd < 32) &&
        isInlineScratchRegisterB v0 &&
        isInlineScratchRegisterB v1 &&
        isInlineScratchRegisterB v2 &&
        isInlineScratchRegisterB v3 &&
        decide (v0 ≠ v1) &&
        decide (v0 ≠ v2) &&
        decide (v0 ≠ v3) &&
        decide (v1 ≠ v2) &&
        decide (v1 ≠ v3) &&
        decide (v2 ≠ v3) &&
        decide (r0.traceOpcode = none) &&
        decide (r0.traceVirtualOpcode = some .movsign) &&
        decide (r0.rs2 = 0) &&
        decide (r0.imm = 0) &&
        decide (r1.traceOpcode = some .andi) &&
        decide (r1.traceVirtualOpcode = none) &&
        decide (r1.rd = v1) &&
        decide (r1.rs1 = v0) &&
        decide (r1.rs2 = 0) &&
        decide (r1.imm = 1) &&
        decide (r2.traceOpcode = some .xor) &&
        decide (r2.traceVirtualOpcode = none) &&
        decide (r2.rd = v2) &&
        decide (r2.rs1 = archRs1) &&
        decide (r2.rs2 = v0) &&
        decide (r3.traceOpcode = some .add) &&
        decide (r3.traceVirtualOpcode = none) &&
        decide (r3.rd = v2) &&
        decide (r3.rs1 = v2) &&
        decide (r3.rs2 = v1) &&
        decide (r4.traceOpcode = some .mulhu) &&
        decide (r4.traceVirtualOpcode = none) &&
        decide (r4.rd = v3) &&
        decide (r4.rs1 = v2) &&
        decide (r4.rs2 = archRs2) &&
        decide (r5.traceOpcode = some .mul) &&
        decide (r5.traceVirtualOpcode = none) &&
        decide (r5.rd = v2) &&
        decide (r5.rs1 = v2) &&
        decide (r5.rs2 = archRs2) &&
        decide (r6.traceOpcode = some .xor) &&
        decide (r6.traceVirtualOpcode = none) &&
        decide (r6.rd = v3) &&
        decide (r6.rs1 = v3) &&
        decide (r6.rs2 = v0) &&
        decide (r7.traceOpcode = some .xor) &&
        decide (r7.traceVirtualOpcode = none) &&
        decide (r7.rd = v2) &&
        decide (r7.rs1 = v2) &&
        decide (r7.rs2 = v0) &&
        decide (r8.traceOpcode = some .add) &&
        decide (r8.traceVirtualOpcode = none) &&
        decide (r8.rd = v0) &&
        decide (r8.rs1 = v2) &&
        decide (r8.rs2 = v1) &&
        decide (r9.traceOpcode = some .sltu) &&
        decide (r9.traceVirtualOpcode = none) &&
        decide (r9.rd = v0) &&
        decide (r9.rs1 = v0) &&
        decide (r9.rs2 = v2) &&
        decide (r10.traceOpcode = some .add) &&
        decide (r10.traceVirtualOpcode = none) &&
        decide (r10.rd = archRd) &&
        decide (r10.rs1 = v3) &&
        decide (r10.rs2 = v0) &&
        decide (r10.writesRd = true) &&
        decide (r10.writesRam = false) &&
        decide (r10.isReal = true)
  | _ => false

def mulhsuConcreteCoreShape (rows : List ImportedLoweringRow) : Prop :=
  mulhsuConcreteCoreShapeB rows = true

def normalizeMulhsuConcreteCore? (rows : List ImportedLoweringRow) :
    Option (List MulhsuReferenceStep) :=
  if mulhsuConcreteCoreShapeB rows then
    some mulhsuReferenceLowering
  else
    none

private def unsignedDivRemCoreShapeB
    (opcode : Opcode)
    (moveSourceIsRemainder : Bool)
    (wordOp : Bool) : List ImportedLoweringRow → Bool
  | [r0, r1, r2, r3, r4, r5, r6, r7] =>
      if wordOp then
        false
      else
        let archRs1 := r0.rs1
        let archRs2 := r0.rs2
        let v0 := r0.rd
        let v1 := r2.rd
        let v2 := r5.rd
        let archRd := r7.rd
        let moveSource := if moveSourceIsRemainder then v2 else v0
        decide (r0.opcode = opcode) &&
          decide (r1.opcode = opcode) &&
          decide (r2.opcode = opcode) &&
          decide (r3.opcode = opcode) &&
          decide (r4.opcode = opcode) &&
          decide (r5.opcode = opcode) &&
          decide (r6.opcode = opcode) &&
          decide (r7.opcode = opcode) &&
          decide (archRs1 < 32) &&
          decide (archRs2 < 32) &&
          decide (archRd < 32) &&
          isInlineScratchRegisterB v0 &&
          isInlineScratchRegisterB v1 &&
          isInlineScratchRegisterB v2 &&
          decide (v0 ≠ v1) &&
          decide (v0 ≠ v2) &&
          decide (v1 ≠ v2) &&
          decide (r0.traceOpcode = none) &&
          decide (r0.traceVirtualOpcode = some .advice) &&
          decide (r0.rs2 = archRs2) &&
          decide (r1.traceOpcode = none) &&
          decide (r1.traceVirtualOpcode = some .assertValidDiv0) &&
          decide (r1.rd = v0) &&
          decide (r1.rs1 = archRs2) &&
          decide (r1.rs2 = v0) &&
          decide (r2.traceOpcode = none) &&
          decide (r2.traceVirtualOpcode = some .assertMulNoOverflow) &&
          decide (r2.rd = v1) &&
          decide (r2.rs1 = v0) &&
          decide (r2.rs2 = archRs2) &&
          decide (r3.traceOpcode = some .mul) &&
          decide (r3.traceVirtualOpcode = none) &&
          decide (r3.rd = v1) &&
          decide (r3.rs1 = v0) &&
          decide (r3.rs2 = archRs2) &&
          decide (r4.traceOpcode = none) &&
          decide (r4.traceVirtualOpcode = some .assertLte) &&
          decide (r4.rd = v1) &&
          decide (r4.rs1 = v1) &&
          decide (r4.rs2 = archRs1) &&
          decide (r5.traceOpcode = some .sub) &&
          decide (r5.traceVirtualOpcode = none) &&
          decide (r5.rd = v2) &&
          decide (r5.rs1 = archRs1) &&
          decide (r5.rs2 = v1) &&
          decide (r6.traceOpcode = none) &&
          decide (r6.traceVirtualOpcode = some .assertValidUnsignedRemainder) &&
          decide (r6.rd = v2) &&
          decide (r6.rs1 = v2) &&
          decide (r6.rs2 = archRs2) &&
          decide (r7.traceOpcode = none) &&
          decide (r7.traceVirtualOpcode = some .move) &&
          decide (r7.rd = archRd) &&
          decide (r7.rs1 = moveSource) &&
          decide (r7.rs2 = 0) &&
          decide (r7.imm = 0) &&
          decide (r7.writesRd = true) &&
          decide (r7.writesRam = false) &&
          decide (r7.isReal = true)
  | [r0, r1, r2, r3, r4, r5, r6, r7, r8] =>
      if !wordOp then
        false
      else
        let archRs1 := r0.rs1
        let archRs2 := r0.rs2
        let v0 := r0.rd
        let v1 := r2.rd
        let v2 := r5.rd
        let archRd := r7.rd
        let moveSource := if moveSourceIsRemainder then v2 else v0
        decide (r0.opcode = opcode) &&
          decide (r1.opcode = opcode) &&
          decide (r2.opcode = opcode) &&
          decide (r3.opcode = opcode) &&
          decide (r4.opcode = opcode) &&
          decide (r5.opcode = opcode) &&
          decide (r6.opcode = opcode) &&
          decide (r7.opcode = opcode) &&
          decide (r8.opcode = opcode) &&
          decide (archRs1 < 32) &&
          decide (archRs2 < 32) &&
          decide (archRd < 32) &&
          isInlineScratchRegisterB v0 &&
          isInlineScratchRegisterB v1 &&
          isInlineScratchRegisterB v2 &&
          decide (v0 ≠ v1) &&
          decide (v0 ≠ v2) &&
          decide (v1 ≠ v2) &&
          decide (r0.traceOpcode = none) &&
          decide (r0.traceVirtualOpcode = some .advice) &&
          decide (r0.rs2 = archRs2) &&
          decide (r1.traceOpcode = none) &&
          decide (r1.traceVirtualOpcode = some .assertValidDiv0) &&
          decide (r1.rd = v0) &&
          decide (r1.rs1 = archRs2) &&
          decide (r1.rs2 = v0) &&
          decide (r2.traceOpcode = none) &&
          decide (r2.traceVirtualOpcode = some .assertMulNoOverflow) &&
          decide (r2.rd = v1) &&
          decide (r2.rs1 = v0) &&
          decide (r2.rs2 = archRs2) &&
          decide (r3.traceOpcode = some .mul) &&
          decide (r3.traceVirtualOpcode = none) &&
          decide (r3.rd = v1) &&
          decide (r3.rs1 = v0) &&
          decide (r3.rs2 = archRs2) &&
          decide (r4.traceOpcode = none) &&
          decide (r4.traceVirtualOpcode = some .assertLte) &&
          decide (r4.rd = v1) &&
          decide (r4.rs1 = v1) &&
          decide (r4.rs2 = archRs1) &&
          decide (r5.traceOpcode = some .sub) &&
          decide (r5.traceVirtualOpcode = none) &&
          decide (r5.rd = v2) &&
          decide (r5.rs1 = archRs1) &&
          decide (r5.rs2 = v1) &&
          decide (r6.traceOpcode = none) &&
          decide (r6.traceVirtualOpcode = some .assertValidUnsignedRemainder) &&
          decide (r6.rd = v2) &&
          decide (r6.rs1 = v2) &&
          decide (r6.rs2 = archRs2) &&
          decide (r7.traceOpcode = none) &&
          decide (r7.traceVirtualOpcode = some .move) &&
          decide (r7.rd = archRd) &&
          decide (r7.rs1 = moveSource) &&
          decide (r7.rs2 = 0) &&
          decide (r7.imm = 0) &&
          decide (r7.writesRd = true) &&
          decide (r7.writesRam = false) &&
          decide (r7.isReal = false) &&
          decide (r8.traceOpcode = none) &&
          decide (r8.traceVirtualOpcode = some .signExtendWord) &&
          decide (r8.rd = archRd) &&
          decide (r8.rs1 = archRd) &&
          decide (r8.rs2 = 0) &&
          decide (r8.imm = 0) &&
          decide (r8.writesRd = true) &&
          decide (r8.writesRam = false) &&
          decide (r8.isReal = true)
  | _ => false

def divuConcreteCoreShape (rows : List ImportedLoweringRow) : Prop :=
  unsignedDivRemCoreShapeB .divu false false rows = true

def remuConcreteCoreShape (rows : List ImportedLoweringRow) : Prop :=
  unsignedDivRemCoreShapeB .remu true false rows = true

def divuwConcreteCoreShape (rows : List ImportedLoweringRow) : Prop :=
  unsignedDivRemCoreShapeB .divuw false true rows = true

def remuwConcreteCoreShape (rows : List ImportedLoweringRow) : Prop :=
  unsignedDivRemCoreShapeB .remuw true true rows = true

def normalizeDivuConcreteCore? (rows : List ImportedLoweringRow) :
    Option (List UnsignedDivRemReferenceStep) :=
  if unsignedDivRemCoreShapeB .divu false false rows then
    some divuReferenceLowering
  else
    none

def normalizeRemuConcreteCore? (rows : List ImportedLoweringRow) :
    Option (List UnsignedDivRemReferenceStep) :=
  if unsignedDivRemCoreShapeB .remu true false rows then
    some remuReferenceLowering
  else
    none

def normalizeDivuwConcreteCore? (rows : List ImportedLoweringRow) :
    Option (List UnsignedDivRemReferenceStep) :=
  if unsignedDivRemCoreShapeB .divuw false true rows then
    some divuwReferenceLowering
  else
    none

def normalizeRemuwConcreteCore? (rows : List ImportedLoweringRow) :
    Option (List UnsignedDivRemReferenceStep) :=
  if unsignedDivRemCoreShapeB .remuw true true rows then
    some remuwReferenceLowering
  else
    none

private def signedDivRemCoreShapeB
    (opcode : Opcode)
    (moveSourceIsRemainder : Bool)
    (wordOp : Bool) : List ImportedLoweringRow → Bool
  | [r0, r1, r2, r3, r4, r5, r6] =>
      if wordOp then
        false
      else
        let archRs1 := r0.rs1
        let archRs2 := r0.rs2
        let v0 := r0.rd
        let v1 := r1.rd
        let v2 := r2.rd
        let v3 := r3.rd
        let archRd := r6.rd
        let moveSource := if moveSourceIsRemainder then v3 else v1
        decide (r0.opcode = opcode) &&
          decide (r1.opcode = opcode) &&
          decide (r2.opcode = opcode) &&
          decide (r3.opcode = opcode) &&
          decide (r4.opcode = opcode) &&
          decide (r5.opcode = opcode) &&
          decide (r6.opcode = opcode) &&
          decide (archRs1 < 32) &&
          decide (archRs2 < 32) &&
          decide (archRd < 32) &&
          isInlineScratchRegisterB v0 &&
          isInlineScratchRegisterB v1 &&
          isInlineScratchRegisterB v2 &&
          isInlineScratchRegisterB v3 &&
          decide (v0 ≠ v1) &&
          decide (v0 ≠ v2) &&
          decide (v0 ≠ v3) &&
          decide (v1 ≠ v2) &&
          decide (v1 ≠ v3) &&
          decide (v2 ≠ v3) &&
          decide (r0.traceOpcode = none) &&
          decide (r0.traceVirtualOpcode = some .changeDivisor) &&
          decide (r0.rs2 = archRs2) &&
          decide (r0.imm = 0) &&
          decide (r1.traceOpcode = none) &&
          decide (r1.traceVirtualOpcode = some .advice) &&
          decide (r1.rs1 = archRs1) &&
          decide (r1.rs2 = archRs2) &&
          decide (r1.imm = 0) &&
          decide (r2.traceOpcode = some .mul) &&
          decide (r2.traceVirtualOpcode = none) &&
          decide (r2.rd = v2) &&
          decide (r2.rs1 = v1) &&
          decide (r2.rs2 = v0) &&
          decide (r3.traceOpcode = some .sub) &&
          decide (r3.traceVirtualOpcode = none) &&
          decide (r3.rd = v3) &&
          decide (r3.rs1 = archRs1) &&
          decide (r3.rs2 = v2) &&
          decide (r4.traceOpcode = none) &&
          decide (r4.traceVirtualOpcode = some .assertSignedDivIdentity) &&
          decide (r4.rd = v1) &&
          decide (r4.rs1 = archRs1) &&
          decide (r4.rs2 = v0) &&
          decide (r4.imm = 0) &&
          decide (r5.traceOpcode = none) &&
          decide (r5.traceVirtualOpcode = some .assertSignedRemainderBounds) &&
          decide (r5.rd = v3) &&
          decide (r5.rs1 = v3) &&
          decide (r5.rs2 = v0) &&
          decide (r5.imm = 0) &&
          decide (r6.traceOpcode = none) &&
          decide (r6.traceVirtualOpcode = some .move) &&
          decide (r6.rd = archRd) &&
          decide (r6.rs1 = moveSource) &&
          decide (r6.rs2 = 0) &&
          decide (r6.imm = 0) &&
          decide (r6.writesRd = true) &&
          decide (r6.writesRam = false) &&
          decide (r6.isReal = true)
  | [r0, r1, r2, r3, r4, r5, r6, r7] =>
      if !wordOp then
        false
      else
        let archRs1 := r0.rs1
        let archRs2 := r0.rs2
        let v0 := r0.rd
        let v1 := r1.rd
        let v2 := r2.rd
        let v3 := r3.rd
        let archRd := r6.rd
        let moveSource := if moveSourceIsRemainder then v3 else v1
        decide (r0.opcode = opcode) &&
          decide (r1.opcode = opcode) &&
          decide (r2.opcode = opcode) &&
          decide (r3.opcode = opcode) &&
          decide (r4.opcode = opcode) &&
          decide (r5.opcode = opcode) &&
          decide (r6.opcode = opcode) &&
          decide (r7.opcode = opcode) &&
          decide (archRs1 < 32) &&
          decide (archRs2 < 32) &&
          decide (archRd < 32) &&
          isInlineScratchRegisterB v0 &&
          isInlineScratchRegisterB v1 &&
          isInlineScratchRegisterB v2 &&
          isInlineScratchRegisterB v3 &&
          decide (v0 ≠ v1) &&
          decide (v0 ≠ v2) &&
          decide (v0 ≠ v3) &&
          decide (v1 ≠ v2) &&
          decide (v1 ≠ v3) &&
          decide (v2 ≠ v3) &&
          decide (r0.traceOpcode = none) &&
          decide (r0.traceVirtualOpcode = some .changeDivisor) &&
          decide (r0.rs2 = archRs2) &&
          decide (r0.imm = 0) &&
          decide (r1.traceOpcode = none) &&
          decide (r1.traceVirtualOpcode = some .advice) &&
          decide (r1.rs1 = archRs1) &&
          decide (r1.rs2 = archRs2) &&
          decide (r1.imm = 0) &&
          decide (r2.traceOpcode = some .mul) &&
          decide (r2.traceVirtualOpcode = none) &&
          decide (r2.rd = v2) &&
          decide (r2.rs1 = v1) &&
          decide (r2.rs2 = v0) &&
          decide (r3.traceOpcode = some .sub) &&
          decide (r3.traceVirtualOpcode = none) &&
          decide (r3.rd = v3) &&
          decide (r3.rs1 = archRs1) &&
          decide (r3.rs2 = v2) &&
          decide (r4.traceOpcode = none) &&
          decide (r4.traceVirtualOpcode = some .assertSignedDivIdentity) &&
          decide (r4.rd = v1) &&
          decide (r4.rs1 = archRs1) &&
          decide (r4.rs2 = v0) &&
          decide (r4.imm = 0) &&
          decide (r5.traceOpcode = none) &&
          decide (r5.traceVirtualOpcode = some .assertSignedRemainderBounds) &&
          decide (r5.rd = v3) &&
          decide (r5.rs1 = v3) &&
          decide (r5.rs2 = v0) &&
          decide (r5.imm = 0) &&
          decide (r6.traceOpcode = none) &&
          decide (r6.traceVirtualOpcode = some .move) &&
          decide (r6.rd = archRd) &&
          decide (r6.rs1 = moveSource) &&
          decide (r6.rs2 = 0) &&
          decide (r6.imm = 0) &&
          decide (r6.writesRd = true) &&
          decide (r6.writesRam = false) &&
          decide (r6.isReal = false) &&
          decide (r7.traceOpcode = none) &&
          decide (r7.traceVirtualOpcode = some .signExtendWord) &&
          decide (r7.rd = archRd) &&
          decide (r7.rs1 = archRd) &&
          decide (r7.rs2 = 0) &&
          decide (r7.imm = 0) &&
          decide (r7.writesRd = true) &&
          decide (r7.writesRam = false) &&
          decide (r7.isReal = true)
  | _ => false

def divConcreteCoreShape (rows : List ImportedLoweringRow) : Prop :=
  signedDivRemCoreShapeB .div false false rows = true

def remConcreteCoreShape (rows : List ImportedLoweringRow) : Prop :=
  signedDivRemCoreShapeB .rem true false rows = true

def divwConcreteCoreShape (rows : List ImportedLoweringRow) : Prop :=
  signedDivRemCoreShapeB .divw false true rows = true

def remwConcreteCoreShape (rows : List ImportedLoweringRow) : Prop :=
  signedDivRemCoreShapeB .remw true true rows = true

def normalizeDivConcreteCore? (rows : List ImportedLoweringRow) :
    Option (List SignedDivRemReferenceStep) :=
  if signedDivRemCoreShapeB .div false false rows then
    some divReferenceLowering
  else
    none

def normalizeRemConcreteCore? (rows : List ImportedLoweringRow) :
    Option (List SignedDivRemReferenceStep) :=
  if signedDivRemCoreShapeB .rem true false rows then
    some remReferenceLowering
  else
    none

def normalizeDivwConcreteCore? (rows : List ImportedLoweringRow) :
    Option (List SignedDivRemReferenceStep) :=
  if signedDivRemCoreShapeB .divw false true rows then
    some divwReferenceLowering
  else
    none

def normalizeRemwConcreteCore? (rows : List ImportedLoweringRow) :
    Option (List SignedDivRemReferenceStep) :=
  if signedDivRemCoreShapeB .remw true true rows then
    some remwReferenceLowering
  else
    none

def MulConcreteLoweringRefinesReference (rows : List ImportedLoweringRow) : Prop :=
  normalizeMulConcreteCore? rows = some mulReferenceLowering ∧
    rowSequenceMetadataBound rows ∧
    uniqueEffectRowAt rows mulEffectRowIndex ∧
    uniqueCommitRowAt rows mulEffectRowIndex ∧
    uniqueRealRowAt rows mulEffectRowIndex

def MulhuConcreteLoweringRefinesReference (rows : List ImportedLoweringRow) : Prop :=
  normalizeMulhuConcreteCore? rows = some mulhuReferenceLowering ∧
    rowSequenceMetadataBound rows ∧
    uniqueEffectRowAt rows mulhuEffectRowIndex ∧
    uniqueCommitRowAt rows mulhuEffectRowIndex ∧
    uniqueRealRowAt rows mulhuEffectRowIndex

def MulwConcreteLoweringRefinesReference (rows : List ImportedLoweringRow) : Prop :=
  normalizeMulwConcreteCore? rows = some mulwReferenceLowering ∧
    rowSequenceMetadataBound rows ∧
    uniqueEffectRowAt rows mulwEffectRowIndex ∧
    uniqueCommitRowAt rows mulwEffectRowIndex ∧
    uniqueRealRowAt rows mulwEffectRowIndex

def MulhConcreteLoweringRefinesReference (rows : List ImportedLoweringRow) : Prop :=
  normalizeMulhConcreteCore? rows = some mulhReferenceLowering ∧
    rowSequenceMetadataBound rows ∧
    rows.length > mulhEffectRowIndex ∧
    uniqueEffectRowAt rows mulhEffectRowIndex ∧
    mulhClosureSuffixScratchOnly rows ∧
    uniqueCommitRowAt rows mulhEffectRowIndex ∧
    uniqueRealRowAt rows mulhEffectRowIndex

def MulhsuConcreteLoweringRefinesReference (rows : List ImportedLoweringRow) : Prop :=
  normalizeMulhsuConcreteCore? rows = some mulhsuReferenceLowering ∧
    rowSequenceMetadataBound rows ∧
    rows.length > mulhsuEffectRowIndex ∧
    uniqueEffectRowAt rows mulhsuEffectRowIndex ∧
    mulhsuClosureSuffixScratchOnly rows ∧
    uniqueCommitRowAt rows mulhsuEffectRowIndex ∧
    uniqueRealRowAt rows mulhsuEffectRowIndex

def DivuConcreteLoweringRefinesReference (rows : List ImportedLoweringRow) : Prop :=
  normalizeDivuConcreteCore? rows = some divuReferenceLowering ∧
    rowSequenceMetadataBound rows ∧
    rows.length > divuEffectRowIndex ∧
    uniqueEffectRowAt rows divuEffectRowIndex ∧
    divuClosureSuffixScratchOnly rows ∧
    uniqueCommitRowAt rows divuEffectRowIndex ∧
    uniqueRealRowAt rows divuEffectRowIndex

def RemuConcreteLoweringRefinesReference (rows : List ImportedLoweringRow) : Prop :=
  normalizeRemuConcreteCore? rows = some remuReferenceLowering ∧
    rowSequenceMetadataBound rows ∧
    rows.length > remuEffectRowIndex ∧
    uniqueEffectRowAt rows remuEffectRowIndex ∧
    remuClosureSuffixScratchOnly rows ∧
    uniqueCommitRowAt rows remuEffectRowIndex ∧
    uniqueRealRowAt rows remuEffectRowIndex

def DivuwConcreteLoweringRefinesReference (rows : List ImportedLoweringRow) : Prop :=
  normalizeDivuwConcreteCore? rows = some divuwReferenceLowering ∧
    rowSequenceMetadataBound rows ∧
    rows.length > divuwEffectRowIndex ∧
    uniqueEffectRowAt rows divuwEffectRowIndex ∧
    divuwClosureSuffixScratchOnly rows ∧
    uniqueCommitRowAt rows divuwEffectRowIndex ∧
    uniqueRealRowAt rows divuwEffectRowIndex

def RemuwConcreteLoweringRefinesReference (rows : List ImportedLoweringRow) : Prop :=
  normalizeRemuwConcreteCore? rows = some remuwReferenceLowering ∧
    rowSequenceMetadataBound rows ∧
    rows.length > remuwEffectRowIndex ∧
    uniqueEffectRowAt rows remuwEffectRowIndex ∧
    remuwClosureSuffixScratchOnly rows ∧
    uniqueCommitRowAt rows remuwEffectRowIndex ∧
    uniqueRealRowAt rows remuwEffectRowIndex

def DivConcreteLoweringRefinesReference (rows : List ImportedLoweringRow) : Prop :=
  normalizeDivConcreteCore? rows = some divReferenceLowering ∧
    rowSequenceMetadataBound rows ∧
    rows.length > divEffectRowIndex ∧
    uniqueEffectRowAt rows divEffectRowIndex ∧
    divClosureSuffixScratchOnly rows ∧
    uniqueCommitRowAt rows divEffectRowIndex ∧
    uniqueRealRowAt rows divEffectRowIndex

def RemConcreteLoweringRefinesReference (rows : List ImportedLoweringRow) : Prop :=
  normalizeRemConcreteCore? rows = some remReferenceLowering ∧
    rowSequenceMetadataBound rows ∧
    rows.length > remEffectRowIndex ∧
    uniqueEffectRowAt rows remEffectRowIndex ∧
    remClosureSuffixScratchOnly rows ∧
    uniqueCommitRowAt rows remEffectRowIndex ∧
    uniqueRealRowAt rows remEffectRowIndex

def DivwConcreteLoweringRefinesReference (rows : List ImportedLoweringRow) : Prop :=
  normalizeDivwConcreteCore? rows = some divwReferenceLowering ∧
    rowSequenceMetadataBound rows ∧
    rows.length > divwEffectRowIndex ∧
    uniqueEffectRowAt rows divwEffectRowIndex ∧
    divwClosureSuffixScratchOnly rows ∧
    uniqueCommitRowAt rows divwEffectRowIndex ∧
    uniqueRealRowAt rows divwEffectRowIndex

def RemwConcreteLoweringRefinesReference (rows : List ImportedLoweringRow) : Prop :=
  normalizeRemwConcreteCore? rows = some remwReferenceLowering ∧
    rowSequenceMetadataBound rows ∧
    rows.length > remwEffectRowIndex ∧
    uniqueEffectRowAt rows remwEffectRowIndex ∧
    remwClosureSuffixScratchOnly rows ∧
    uniqueCommitRowAt rows remwEffectRowIndex ∧
    uniqueRealRowAt rows remwEffectRowIndex

instance instDecidableMulConcreteLoweringRefinesReference (rows : List ImportedLoweringRow) :
    Decidable (MulConcreteLoweringRefinesReference rows) := by
  unfold MulConcreteLoweringRefinesReference rowSequenceMetadataBound uniqueEffectRowAt uniqueCommitRowAt uniqueRealRowAt
  infer_instance

instance instDecidableMulhuConcreteLoweringRefinesReference (rows : List ImportedLoweringRow) :
    Decidable (MulhuConcreteLoweringRefinesReference rows) := by
  unfold MulhuConcreteLoweringRefinesReference rowSequenceMetadataBound uniqueEffectRowAt uniqueCommitRowAt uniqueRealRowAt
  infer_instance

instance instDecidableMulwConcreteLoweringRefinesReference (rows : List ImportedLoweringRow) :
    Decidable (MulwConcreteLoweringRefinesReference rows) := by
  unfold MulwConcreteLoweringRefinesReference rowSequenceMetadataBound uniqueEffectRowAt uniqueCommitRowAt uniqueRealRowAt
  infer_instance

instance instDecidableMulhConcreteLoweringRefinesReference (rows : List ImportedLoweringRow) :
    Decidable (MulhConcreteLoweringRefinesReference rows) := by
  unfold MulhConcreteLoweringRefinesReference rowSequenceMetadataBound uniqueEffectRowAt mulhClosureSuffixScratchOnly uniqueCommitRowAt uniqueRealRowAt
  infer_instance

instance instDecidableMulhsuConcreteLoweringRefinesReference (rows : List ImportedLoweringRow) :
    Decidable (MulhsuConcreteLoweringRefinesReference rows) := by
  unfold MulhsuConcreteLoweringRefinesReference rowSequenceMetadataBound uniqueEffectRowAt mulhsuClosureSuffixScratchOnly uniqueCommitRowAt uniqueRealRowAt
  infer_instance

instance instDecidableDivuConcreteLoweringRefinesReference (rows : List ImportedLoweringRow) :
    Decidable (DivuConcreteLoweringRefinesReference rows) := by
  unfold DivuConcreteLoweringRefinesReference rowSequenceMetadataBound uniqueEffectRowAt divuClosureSuffixScratchOnly uniqueCommitRowAt uniqueRealRowAt
  infer_instance

instance instDecidableRemuConcreteLoweringRefinesReference (rows : List ImportedLoweringRow) :
    Decidable (RemuConcreteLoweringRefinesReference rows) := by
  unfold RemuConcreteLoweringRefinesReference rowSequenceMetadataBound uniqueEffectRowAt remuClosureSuffixScratchOnly uniqueCommitRowAt uniqueRealRowAt
  infer_instance

instance instDecidableDivuwConcreteLoweringRefinesReference (rows : List ImportedLoweringRow) :
    Decidable (DivuwConcreteLoweringRefinesReference rows) := by
  unfold DivuwConcreteLoweringRefinesReference rowSequenceMetadataBound uniqueEffectRowAt divuwClosureSuffixScratchOnly uniqueCommitRowAt uniqueRealRowAt
  infer_instance

instance instDecidableRemuwConcreteLoweringRefinesReference (rows : List ImportedLoweringRow) :
    Decidable (RemuwConcreteLoweringRefinesReference rows) := by
  unfold RemuwConcreteLoweringRefinesReference rowSequenceMetadataBound uniqueEffectRowAt remuwClosureSuffixScratchOnly uniqueCommitRowAt uniqueRealRowAt
  infer_instance

instance instDecidableDivConcreteLoweringRefinesReference (rows : List ImportedLoweringRow) :
    Decidable (DivConcreteLoweringRefinesReference rows) := by
  unfold DivConcreteLoweringRefinesReference rowSequenceMetadataBound uniqueEffectRowAt divClosureSuffixScratchOnly uniqueCommitRowAt uniqueRealRowAt
  infer_instance

instance instDecidableRemConcreteLoweringRefinesReference (rows : List ImportedLoweringRow) :
    Decidable (RemConcreteLoweringRefinesReference rows) := by
  unfold RemConcreteLoweringRefinesReference rowSequenceMetadataBound uniqueEffectRowAt remClosureSuffixScratchOnly uniqueCommitRowAt uniqueRealRowAt
  infer_instance

instance instDecidableDivwConcreteLoweringRefinesReference (rows : List ImportedLoweringRow) :
    Decidable (DivwConcreteLoweringRefinesReference rows) := by
  unfold DivwConcreteLoweringRefinesReference rowSequenceMetadataBound uniqueEffectRowAt divwClosureSuffixScratchOnly uniqueCommitRowAt uniqueRealRowAt
  infer_instance

instance instDecidableRemwConcreteLoweringRefinesReference (rows : List ImportedLoweringRow) :
    Decidable (RemwConcreteLoweringRefinesReference rows) := by
  unfold RemwConcreteLoweringRefinesReference rowSequenceMetadataBound uniqueEffectRowAt remwClosureSuffixScratchOnly uniqueCommitRowAt uniqueRealRowAt
  infer_instance

private theorem effectRowIndex_lt_length_of_lengthGt
  {rows : List ImportedLoweringRow}
  {effectIdx : Nat}
  (hLen : rows.length > effectIdx) :
  effectIdx < rows.length := by
  omega

private theorem effectRow_precedesCommitRow_of_lengthGt
  {rows : List ImportedLoweringRow}
  {effectIdx : Nat}
  (hLen : rows.length > effectIdx) :
  effectIdx ≤ rows.length - 1 := by
  omega

theorem normalizedReference_of_mulConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : MulConcreteLoweringRefinesReference rows) :
  normalizeMulConcreteCore? rows = some mulReferenceLowering :=
  h.1

theorem sequenceMetadataBound_of_mulConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : MulConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  h.2.1

theorem uniqueCommitRow_of_mulConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : MulConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows mulEffectRowIndex :=
  h.2.2.2.2

theorem normalizedReference_of_mulhuConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : MulhuConcreteLoweringRefinesReference rows) :
  normalizeMulhuConcreteCore? rows = some mulhuReferenceLowering :=
  h.1

theorem sequenceMetadataBound_of_mulhuConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : MulhuConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  h.2.1

theorem uniqueCommitRow_of_mulhuConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : MulhuConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows mulhuEffectRowIndex :=
  h.2.2.2.2

theorem normalizedReference_of_mulwConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : MulwConcreteLoweringRefinesReference rows) :
  normalizeMulwConcreteCore? rows = some mulwReferenceLowering :=
  h.1

theorem sequenceMetadataBound_of_mulwConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : MulwConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  h.2.1

theorem uniqueCommitRow_of_mulwConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : MulwConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows mulwEffectRowIndex :=
  h.2.2.2.2

theorem normalizedReference_of_mulhConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : MulhConcreteLoweringRefinesReference rows) :
  normalizeMulhConcreteCore? rows = some mulhReferenceLowering :=
  h.1

theorem sequenceMetadataBound_of_mulhConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : MulhConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  h.2.1

theorem effectRowIndex_lt_length_of_mulhConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : MulhConcreteLoweringRefinesReference rows) :
  mulhEffectRowIndex < rows.length := by
  have hLen : rows.length > mulhEffectRowIndex := h.2.2.1
  exact effectRowIndex_lt_length_of_lengthGt hLen

theorem closureSuffixScratchOnly_of_mulhConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : MulhConcreteLoweringRefinesReference rows) :
  mulhClosureSuffixScratchOnly rows :=
  h.2.2.2.2.1

theorem uniqueCommitRow_of_mulhConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : MulhConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows mulhEffectRowIndex :=
  h.2.2.2.2.2.2

theorem effectRow_precedesCommitRow_of_mulhConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : MulhConcreteLoweringRefinesReference rows) :
  mulhEffectRowIndex ≤ rows.length - 1 := by
  have hLen : rows.length > mulhEffectRowIndex := h.2.2.1
  exact effectRow_precedesCommitRow_of_lengthGt hLen

theorem normalizedReference_of_mulhsuConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : MulhsuConcreteLoweringRefinesReference rows) :
  normalizeMulhsuConcreteCore? rows = some mulhsuReferenceLowering :=
  h.1

theorem sequenceMetadataBound_of_mulhsuConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : MulhsuConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  h.2.1

theorem effectRowIndex_lt_length_of_mulhsuConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : MulhsuConcreteLoweringRefinesReference rows) :
  mulhsuEffectRowIndex < rows.length := by
  have hLen : rows.length > mulhsuEffectRowIndex := h.2.2.1
  exact effectRowIndex_lt_length_of_lengthGt hLen

theorem closureSuffixScratchOnly_of_mulhsuConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : MulhsuConcreteLoweringRefinesReference rows) :
  mulhsuClosureSuffixScratchOnly rows :=
  h.2.2.2.2.1

theorem uniqueCommitRow_of_mulhsuConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : MulhsuConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows mulhsuEffectRowIndex :=
  h.2.2.2.2.2.2

theorem effectRow_precedesCommitRow_of_mulhsuConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : MulhsuConcreteLoweringRefinesReference rows) :
  mulhsuEffectRowIndex ≤ rows.length - 1 := by
  have hLen : rows.length > mulhsuEffectRowIndex := h.2.2.1
  exact effectRow_precedesCommitRow_of_lengthGt hLen

theorem normalizedReference_of_divuConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : DivuConcreteLoweringRefinesReference rows) :
  normalizeDivuConcreteCore? rows = some divuReferenceLowering :=
  h.1

theorem sequenceMetadataBound_of_divuConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : DivuConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  h.2.1

theorem effectRowIndex_lt_length_of_divuConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : DivuConcreteLoweringRefinesReference rows) :
  divuEffectRowIndex < rows.length := by
  have hLen : rows.length > divuEffectRowIndex := h.2.2.1
  exact effectRowIndex_lt_length_of_lengthGt hLen

theorem closureSuffixScratchOnly_of_divuConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : DivuConcreteLoweringRefinesReference rows) :
  divuClosureSuffixScratchOnly rows :=
  h.2.2.2.2.1

theorem uniqueCommitRow_of_divuConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : DivuConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows divuEffectRowIndex :=
  h.2.2.2.2.2.2

theorem effectRow_precedesCommitRow_of_divuConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : DivuConcreteLoweringRefinesReference rows) :
  divuEffectRowIndex ≤ rows.length - 1 := by
  have hLen : rows.length > divuEffectRowIndex := h.2.2.1
  exact effectRow_precedesCommitRow_of_lengthGt hLen

theorem normalizedReference_of_remuConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : RemuConcreteLoweringRefinesReference rows) :
  normalizeRemuConcreteCore? rows = some remuReferenceLowering :=
  h.1

theorem sequenceMetadataBound_of_remuConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : RemuConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  h.2.1

theorem effectRowIndex_lt_length_of_remuConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : RemuConcreteLoweringRefinesReference rows) :
  remuEffectRowIndex < rows.length := by
  have hLen : rows.length > remuEffectRowIndex := h.2.2.1
  exact effectRowIndex_lt_length_of_lengthGt hLen

theorem closureSuffixScratchOnly_of_remuConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : RemuConcreteLoweringRefinesReference rows) :
  remuClosureSuffixScratchOnly rows :=
  h.2.2.2.2.1

theorem uniqueCommitRow_of_remuConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : RemuConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows remuEffectRowIndex :=
  h.2.2.2.2.2.2

theorem effectRow_precedesCommitRow_of_remuConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : RemuConcreteLoweringRefinesReference rows) :
  remuEffectRowIndex ≤ rows.length - 1 := by
  have hLen : rows.length > remuEffectRowIndex := h.2.2.1
  exact effectRow_precedesCommitRow_of_lengthGt hLen

theorem normalizedReference_of_divuwConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : DivuwConcreteLoweringRefinesReference rows) :
  normalizeDivuwConcreteCore? rows = some divuwReferenceLowering :=
  h.1

theorem sequenceMetadataBound_of_divuwConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : DivuwConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  h.2.1

theorem effectRowIndex_lt_length_of_divuwConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : DivuwConcreteLoweringRefinesReference rows) :
  divuwEffectRowIndex < rows.length := by
  have hLen : rows.length > divuwEffectRowIndex := h.2.2.1
  exact effectRowIndex_lt_length_of_lengthGt hLen

theorem closureSuffixScratchOnly_of_divuwConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : DivuwConcreteLoweringRefinesReference rows) :
  divuwClosureSuffixScratchOnly rows :=
  h.2.2.2.2.1

theorem uniqueCommitRow_of_divuwConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : DivuwConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows divuwEffectRowIndex :=
  h.2.2.2.2.2.2

theorem effectRow_precedesCommitRow_of_divuwConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : DivuwConcreteLoweringRefinesReference rows) :
  divuwEffectRowIndex ≤ rows.length - 1 := by
  have hLen : rows.length > divuwEffectRowIndex := h.2.2.1
  exact effectRow_precedesCommitRow_of_lengthGt hLen

theorem normalizedReference_of_remuwConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : RemuwConcreteLoweringRefinesReference rows) :
  normalizeRemuwConcreteCore? rows = some remuwReferenceLowering :=
  h.1

theorem sequenceMetadataBound_of_remuwConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : RemuwConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  h.2.1

theorem effectRowIndex_lt_length_of_remuwConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : RemuwConcreteLoweringRefinesReference rows) :
  remuwEffectRowIndex < rows.length := by
  have hLen : rows.length > remuwEffectRowIndex := h.2.2.1
  exact effectRowIndex_lt_length_of_lengthGt hLen

theorem closureSuffixScratchOnly_of_remuwConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : RemuwConcreteLoweringRefinesReference rows) :
  remuwClosureSuffixScratchOnly rows :=
  h.2.2.2.2.1

theorem uniqueCommitRow_of_remuwConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : RemuwConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows remuwEffectRowIndex :=
  h.2.2.2.2.2.2

theorem effectRow_precedesCommitRow_of_remuwConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : RemuwConcreteLoweringRefinesReference rows) :
  remuwEffectRowIndex ≤ rows.length - 1 := by
  have hLen : rows.length > remuwEffectRowIndex := h.2.2.1
  exact effectRow_precedesCommitRow_of_lengthGt hLen

theorem normalizedReference_of_divConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : DivConcreteLoweringRefinesReference rows) :
  normalizeDivConcreteCore? rows = some divReferenceLowering :=
  h.1

theorem sequenceMetadataBound_of_divConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : DivConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  h.2.1

theorem effectRowIndex_lt_length_of_divConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : DivConcreteLoweringRefinesReference rows) :
  divEffectRowIndex < rows.length := by
  have hLen : rows.length > divEffectRowIndex := h.2.2.1
  exact effectRowIndex_lt_length_of_lengthGt hLen

theorem closureSuffixScratchOnly_of_divConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : DivConcreteLoweringRefinesReference rows) :
  divClosureSuffixScratchOnly rows :=
  h.2.2.2.2.1

theorem uniqueCommitRow_of_divConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : DivConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows divEffectRowIndex :=
  h.2.2.2.2.2.2

theorem effectRow_precedesCommitRow_of_divConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : DivConcreteLoweringRefinesReference rows) :
  divEffectRowIndex ≤ rows.length - 1 := by
  have hLen : rows.length > divEffectRowIndex := h.2.2.1
  exact effectRow_precedesCommitRow_of_lengthGt hLen

theorem normalizedReference_of_remConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : RemConcreteLoweringRefinesReference rows) :
  normalizeRemConcreteCore? rows = some remReferenceLowering :=
  h.1

theorem sequenceMetadataBound_of_remConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : RemConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  h.2.1

theorem effectRowIndex_lt_length_of_remConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : RemConcreteLoweringRefinesReference rows) :
  remEffectRowIndex < rows.length := by
  have hLen : rows.length > remEffectRowIndex := h.2.2.1
  exact effectRowIndex_lt_length_of_lengthGt hLen

theorem closureSuffixScratchOnly_of_remConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : RemConcreteLoweringRefinesReference rows) :
  remClosureSuffixScratchOnly rows :=
  h.2.2.2.2.1

theorem uniqueCommitRow_of_remConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : RemConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows remEffectRowIndex :=
  h.2.2.2.2.2.2

theorem effectRow_precedesCommitRow_of_remConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : RemConcreteLoweringRefinesReference rows) :
  remEffectRowIndex ≤ rows.length - 1 := by
  have hLen : rows.length > remEffectRowIndex := h.2.2.1
  exact effectRow_precedesCommitRow_of_lengthGt hLen

theorem normalizedReference_of_divwConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : DivwConcreteLoweringRefinesReference rows) :
  normalizeDivwConcreteCore? rows = some divwReferenceLowering :=
  h.1

theorem sequenceMetadataBound_of_divwConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : DivwConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  h.2.1

theorem effectRowIndex_lt_length_of_divwConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : DivwConcreteLoweringRefinesReference rows) :
  divwEffectRowIndex < rows.length := by
  have hLen : rows.length > divwEffectRowIndex := h.2.2.1
  exact effectRowIndex_lt_length_of_lengthGt hLen

theorem closureSuffixScratchOnly_of_divwConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : DivwConcreteLoweringRefinesReference rows) :
  divwClosureSuffixScratchOnly rows :=
  h.2.2.2.2.1

theorem uniqueCommitRow_of_divwConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : DivwConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows divwEffectRowIndex :=
  h.2.2.2.2.2.2

theorem effectRow_precedesCommitRow_of_divwConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : DivwConcreteLoweringRefinesReference rows) :
  divwEffectRowIndex ≤ rows.length - 1 := by
  have hLen : rows.length > divwEffectRowIndex := h.2.2.1
  exact effectRow_precedesCommitRow_of_lengthGt hLen

theorem normalizedReference_of_remwConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : RemwConcreteLoweringRefinesReference rows) :
  normalizeRemwConcreteCore? rows = some remwReferenceLowering :=
  h.1

theorem sequenceMetadataBound_of_remwConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : RemwConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  h.2.1

theorem effectRowIndex_lt_length_of_remwConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : RemwConcreteLoweringRefinesReference rows) :
  remwEffectRowIndex < rows.length := by
  have hLen : rows.length > remwEffectRowIndex := h.2.2.1
  exact effectRowIndex_lt_length_of_lengthGt hLen

theorem closureSuffixScratchOnly_of_remwConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : RemwConcreteLoweringRefinesReference rows) :
  remwClosureSuffixScratchOnly rows :=
  h.2.2.2.2.1

theorem uniqueCommitRow_of_remwConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : RemwConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows remwEffectRowIndex :=
  h.2.2.2.2.2.2

theorem effectRow_precedesCommitRow_of_remwConcreteLoweringRefinesReference
  {rows : List ImportedLoweringRow}
  (h : RemwConcreteLoweringRefinesReference rows) :
  remwEffectRowIndex ≤ rows.length - 1 := by
  have hLen : rows.length > remwEffectRowIndex := h.2.2.1
  exact effectRow_precedesCommitRow_of_lengthGt hLen

end Nightstream.Rv64IM
