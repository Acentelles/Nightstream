import SuperNeo.Ring
import SuperNeo.Thm3Core
import SuperNeo.Decomp
import SuperNeo.Generated.NeoFoldArtifacts

namespace SuperNeo

open F
open SuperNeo.Generated

private abbrev FMatrix := Array (Array F)

structure KExt where
  re : F
  im : F
deriving Repr, Inhabited, DecidableEq

namespace KExt

def ofKNat (x : KNat) : KExt :=
  { re := F.ofNat x.c0, im := F.ofNat x.c1 }

def ofF (x : F) : KExt :=
  { re := x, im := 0 }

instance : Zero KExt := ⟨{ re := 0, im := 0 }⟩
instance : One KExt := ⟨{ re := 1, im := 0 }⟩
instance : Add KExt := ⟨fun a b => { re := a.re + b.re, im := a.im + b.im }⟩
instance : Neg KExt := ⟨fun a => { re := -a.re, im := -a.im }⟩
instance : Sub KExt := ⟨fun a b => a + (-b)⟩

private def w : F := F.ofNat 7

instance : Mul KExt := ⟨fun a b =>
  { re := a.re * b.re + w * (a.im * b.im)
    im := a.re * b.im + a.im * b.re }⟩

def scaleBase (a : F) (x : KExt) : KExt :=
  { re := a * x.re, im := a * x.im }

def pow (x : KExt) (n : Nat) : KExt := Id.run do
  let mut acc : KExt := 1
  let mut i := 0
  while i < n do
    acc := acc * x
    i := i + 1
  return acc

end KExt

private def toF (x : Nat) : F := F.ofNat x

private def toFArray (xs : Array Nat) : Array F :=
  xs.map toF

private def toKArray (xs : Array KNat) : Array KExt :=
  xs.map KExt.ofKNat

private def fAt (m : Array (Array F)) (row col : Nat) : F :=
  if hRow : row < m.size then
    let r := m[row]'hRow
    if hCol : col < r.size then
      r[col]'hCol
    else
      0
  else
    0

private def kAt (m : Array (Array KExt)) (row col : Nat) : KExt :=
  if hRow : row < m.size then
    let r := m[row]'hRow
    if hCol : col < r.size then
      r[col]'hCol
    else
      0
  else
    0

private def takeDFieldCoeffs (row : Array Nat) : Coeffs :=
  Array.ofFn fun i : Fin D =>
    if h : i.1 < row.size then
      toF (row[i.1]'h)
    else
      0

private def takeDKCoeffs (row : Array KNat) : Array KExt :=
  Array.ofFn fun i : Fin D =>
    if h : i.1 < row.size then
      KExt.ofKNat (row[i.1]'h)
    else
      0

private def matrixColCoeffs (m : Array (Array Nat)) (col : Nat) : Coeffs :=
  Array.ofFn fun i : Fin D => fAt (m.map toFArray) i.1 col

private def kVecAdd (xs ys : Array KExt) : Array KExt :=
  if h : xs.size = ys.size then
    Array.ofFn fun i : Fin xs.size =>
      xs[i.1]'i.2 + ys[i.1]'(by simpa [h] using i.2)
  else
    #[]

private def nextPow2AtLeastTwo (n : Nat) : Nat :=
  max 2 n.nextPowerOfTwo

private def ellOfSize (n : Nat) : Nat :=
  Nat.log2 (nextPow2AtLeastTwo n)

private def tensorPoint (r : Array KExt) : Array KExt := Id.run do
  let ell := r.size
  let n := 2 ^ ell
  let mut out := Array.replicate n (1 : KExt)
  let mut i := 0
  while i < ell do
    let ri := r[i]!
    let stride := 2 ^ i
    let block := 2 ^ (ell - i - 1)
    let oneMinus := (1 : KExt) - ri
    let mut idx := 0
    let mut blockIdx := 0
    while blockIdx < block do
      let mut j := 0
      while j < stride do
        let a := out[idx + j]!
        out := out.set! (idx + j) (a * oneMinus)
        j := j + 1
      let mut j2 := 0
      while j2 < stride do
        let a := out[idx + stride + j2]!
        out := out.set! (idx + stride + j2) (a * ri)
        j2 := j2 + 1
      idx := idx + 2 * stride
      blockIdx := blockIdx + 1
    i := i + 1
  return out

private def evalPolyK (coeffs : Array KExt) (x : KExt) : KExt :=
  coeffs.foldr (fun coeff acc => coeff + x * acc) 0

private def roundsHaveDegree (roundPolys : Array (Array KExt)) (degreeBound : Nat) : Bool :=
  (List.range roundPolys.size).all fun idx =>
    decide (roundPolys[idx]!.size = degreeBound + 1)

private def sumcheckComputedFinal?
    (claimedSum : KExt)
    (degreeBound : Nat)
    (roundPolys : Array (Array KExt))
    (challenges : Array KExt) : Option KExt := Id.run do
  if roundPolys.size != challenges.size then
    return none
  if !(roundsHaveDegree roundPolys degreeBound) then
    return none
  if roundPolys.size = 0 then
    return some claimedSum
  let firstRound := roundPolys[0]!
  if evalPolyK firstRound 0 + evalPolyK firstRound 1 != claimedSum then
    return none
  let mut running := evalPolyK firstRound challenges[0]!
  let mut idx := 1
  while idx < roundPolys.size do
    let roundPoly := roundPolys[idx]!
    if evalPolyK roundPoly 0 + evalPolyK roundPoly 1 != running then
      return none
    running := evalPolyK roundPoly challenges[idx]!
    idx := idx + 1
  return some running

private def transcriptChecks (t : NeoFoldTranscriptCase) : Bool :=
  match sumcheckComputedFinal?
      (KExt.ofKNat t.claimedSum)
      t.degreeBound
      (t.roundPolys.map toKArray)
      (t.challenges.map KExt.ofKNat) with
  | some finalValue => decide (finalValue = KExt.ofKNat t.finalSum)
  | none => false

private def optionalTranscriptChecks (t : NeoFoldTranscriptCase) : Bool :=
  if t.roundPolys.isEmpty then
    decide (t.claimedSum = t.finalSum)
  else
    transcriptChecks t

private def batchedTimeShapeChecks (t : NeoFoldBatchedTimeCase) : Bool :=
  decide (t.claimedSums.size = t.degreeBounds.size) &&
    decide (t.claimedSums.size = t.labels.size) &&
    decide (t.claimedSums.size = t.roundPolys.size)

private def batchedClaimChecks (t : NeoFoldBatchedTimeCase) : Bool :=
  let claimed := t.claimedSums.map KExt.ofKNat
  let shared := t.sharedChallenges.map KExt.ofKNat
  (List.range claimed.size).all fun idx =>
    match sumcheckComputedFinal?
        claimed[idx]!
        t.degreeBounds[idx]!
        ((t.roundPolys[idx]!).map toKArray)
        shared with
    | some _ => true
    | none => false

private def batchedTimeChecks (t : NeoFoldBatchedTimeCase) : Bool :=
  batchedTimeShapeChecks t && batchedClaimChecks t

private def findLabelIndex? (labels : Array String) (target : String) : Option Nat := Id.run do
  let mut idx := 0
  while idx < labels.size do
    if labels[idx]! = target then
      return some idx
    idx := idx + 1
  return none

private def claimCommitmentShape (c : NeoFoldClaimCase) : Bool :=
  (List.range c.commitment.cols.size).all fun idx =>
    decide ((c.commitment.cols[idx]!).size = D)

private def claimXShape (c : NeoFoldClaimCase) : Bool :=
  decide (c.x.size = D) &&
    decide (c.xColIndices.size = c.mIn) &&
    (List.range c.x.size).all fun idx =>
      decide ((c.x[idx]!).size = c.mIn)

private def claimBasicShapeChecks (ccs : NeoFoldCcsCase) (c : NeoFoldClaimCase) : Bool :=
  let ellN := ellOfSize ccs.n
  let ellM := ellOfSize ccs.m
  let t := ccs.matrices.size
  let dPad := nextPow2AtLeastTwo D
  claimCommitmentShape c &&
    claimXShape c &&
    decide (c.mIn ≤ ccs.m) &&
    c.xColIndices.all (fun idx => decide (idx < ccs.m)) &&
    decide (c.r.size = ellN) &&
    decide (t ≤ c.yRing.size) &&
    decide (t ≤ c.ct.size) &&
    (List.range c.yRing.size).all fun idx =>
      let row := c.yRing[idx]!
      decide (row.size = D ∨ row.size = dPad) &&
        (if row.size = dPad then
          (List.range (dPad - D)).all fun off =>
            decide (row[D + off]! = { c0 := 0, c1 := 0 })
        else
          true)
    &&
    (if c.sCol.isEmpty && c.yZcol.isEmpty then
      true
    else
      decide (c.sCol.size = ellM) &&
        decide (c.yZcol.size = dPad))

private def claimCtConstantTermChecks (c : NeoFoldClaimCase) : Bool :=
  decide (c.ct.size = c.yRing.size) &&
    (List.range c.ct.size).all fun idx =>
      let row := c.yRing[idx]!
      !row.isEmpty &&
        decide (c.ct[idx]! = row[0]!)

private def meBatchInvariantChecks (batch : Array NeoFoldClaimCase) : Bool :=
  match batch[0]? with
  | none => true
  | some first =>
      claimXShape first &&
        let yLen := first.yRing.size
        let yRowLen := first.yRing[0]?.map (·.size) |>.getD 0
        let ctLen := first.ct.size
        (List.range batch.size).all fun idx =>
          let claim := batch[idx]!
          decide (claim.r = first.r) &&
            decide (claim.mIn = first.mIn) &&
            claimXShape claim &&
            decide (claim.yRing.size = yLen) &&
            (List.range claim.yRing.size).all fun rowIdx =>
              decide ((claim.yRing[rowIdx]!).size = yRowLen) &&
            decide (claim.ct.size = ctLen)

private def requiredKRhoMin (b count : Nat) : Nat := Id.run do
  if count = 0 || b < 2 then
    return 0
  let lhs := count * (4 * D) * (b - 1)
  let mut k := 0
  let mut pow := 1
  while lhs >= pow do
    k := k + 1
    pow := pow * b
  return k

private def requiredDecChildrenMin (kRho b inputCount : Nat) : Nat :=
  max kRho (requiredKRhoMin b inputCount)

private def rhoCoeffShapeChecks (lane : NeoFoldLaneCase) : Bool :=
  decide (lane.rhoCoeffs.size = lane.inputs.size) &&
    lane.rhoCoeffs.all (fun rho => decide (rho.size = D))

structure NeoFoldClaimShapeBreakdown where
  commitmentShape : Bool
  xShape : Bool
  mInBound : Bool
  rSize : Bool
  yRingSize : Bool
  ctSize : Bool
  yRowsOk : Bool
  sColYZcolOk : Bool
deriving Repr, Inhabited

private def claimShapeBreakdown
    (ccs : NeoFoldCcsCase)
    (c : NeoFoldClaimCase) : NeoFoldClaimShapeBreakdown :=
  let ellN := ellOfSize ccs.n
  let ellM := ellOfSize ccs.m
  let t := ccs.matrices.size
  let dPad := nextPow2AtLeastTwo D
  let yRowsOk :=
    (List.range c.yRing.size).all fun idx =>
      let row := c.yRing[idx]!
      decide (row.size = D ∨ row.size = dPad) &&
        (if row.size = dPad then
          (List.range (dPad - D)).all fun off =>
            decide (row[D + off]! = { c0 := 0, c1 := 0 })
        else
          true)
  let sColYZcolOk :=
    if c.sCol.isEmpty && c.yZcol.isEmpty then
      true
    else
      decide (c.sCol.size = ellM) &&
        decide (c.yZcol.size = dPad)
  { commitmentShape := claimCommitmentShape c
    xShape := claimXShape c
    mInBound := decide (c.mIn ≤ ccs.m)
    rSize := decide (c.r.size = ellN)
    yRingSize := decide (t ≤ c.yRing.size)
    ctSize := decide (t ≤ c.ct.size)
    yRowsOk := yRowsOk
    sColYZcolOk := sColYZcolOk }

private def packedCols (m : Nat) : Nat :=
  (m + D - 1) / D

private inductive WitnessLayout where
  | packed
  | dense
deriving DecidableEq

private def witnessLayout? (z : Array (Array Nat)) (expectedM : Nat) : Option WitnessLayout :=
  if expectedM = 0 || z.size ≠ D then
    none
  else
    let wantPacked := packedCols expectedM
    let packedShape :=
      (List.range z.size).all fun idx =>
        decide ((z[idx]!).size = wantPacked)
    let denseShape :=
      (List.range z.size).all fun idx =>
        decide ((z[idx]!).size = expectedM)
    if packedShape then
      some .packed
    else if denseShape then
      some .dense
    else
      none

private def witnessShapeChecks (z : Array (Array Nat)) (expectedM : Nat) : Bool :=
  match witnessLayout? z expectedM with
  | some .packed =>
      let wantCols := packedCols expectedM
      (List.range (wantCols * D - expectedM)).all fun off =>
        let c := expectedM + off
        let blk := c / D
        let digit := c % D
        decide (z[digit]![blk]! = 0)
  | some .dense =>
      true
  | none =>
      false

private def witnessGet (z : Array (Array Nat)) (expectedM rho col : Nat) : F :=
  match witnessLayout? z expectedM with
  | some .packed =>
      if rho < D && col < expectedM then
        let blk := col / D
        let off := col % D
        if off = rho then
          toF z[rho]![blk]!
        else
          0
      else
        0
  | some .dense =>
      if rho < D && col < expectedM then
        toF z[rho]![col]!
      else
        0
  | none =>
      0

private def projectXFromWitness (z : Array (Array Nat)) (expectedM mIn : Nat) : FMatrix :=
  Array.ofFn fun rho : Fin D =>
    Array.ofFn fun c : Fin mIn =>
      witnessGet z expectedM rho.1 c.1

private def projectXFromWitnessAtIndices
    (z : Array (Array Nat))
    (expectedM : Nat)
    (xColIndices : Array Nat) : FMatrix :=
  Array.ofFn fun rho : Fin D =>
    Array.ofFn fun c : Fin xColIndices.size =>
      if c.1 % D = rho.1 then
        witnessGet z expectedM ((xColIndices[c.1]!) % D) (xColIndices[c.1]!)
      else
        0

private def projectXFromPublicInputs (x : Array Nat) : FMatrix :=
  Array.ofFn fun rho : Fin D =>
    Array.ofFn fun c : Fin x.size =>
      if c.1 % D = rho.1 then
        toF x[c.1]!
      else
        0

private def sparseMatrixTransposeMul
    (m : NeoFoldCcsMatrixCase)
    (rb : Array KExt)
    (nEff : Nat) : Array KExt :=
  if m.identity then
    Array.ofFn fun c : Fin m.ncols =>
      if c.1 < nEff && c.1 < m.nrows && c.1 < rb.size then
        rb[c.1]!
      else
        0
  else
    let base := Array.replicate m.ncols (0 : KExt)
    m.entries.foldl (fun acc entry =>
      if entry.row < nEff && entry.row < rb.size && entry.col < m.ncols then
        acc.set! entry.col (acc[entry.col]! + KExt.scaleBase (toF entry.value) rb[entry.row]!)
      else
        acc) base

private def sparseMatrixMulF
    (m : NeoFoldCcsMatrixCase)
    (z : Array F) : Array F :=
  if m.identity then
    Array.ofFn fun r : Fin m.nrows =>
      if r.1 < z.size && r.1 < m.ncols then
        z[r.1]!
      else
        0
  else
    let base := Array.replicate m.nrows (0 : F)
    m.entries.foldl (fun acc entry =>
      if entry.row < m.nrows && entry.col < z.size then
        acc.set! entry.row (acc[entry.row]! + toF entry.value * z[entry.col]!)
      else
        acc) base

private def evalPolyTerm (point : Array F) (term : NeoFoldPolyTermCase) : F :=
  (List.range term.exps.size).foldl
      (fun acc idx => acc * (point[idx]!) ^ (term.exps[idx]!))
      (toF term.coeff)

private def evalSparsePoly (point : Array F) (terms : Array NeoFoldPolyTermCase) : F :=
  (List.range terms.size).foldl
    (fun acc idx => acc + evalPolyTerm point (terms[idx]!))
    0

private def ccsRowwiseZeroChecks
    (ccs : NeoFoldCcsCase)
    (x : Array Nat)
    (w : Array Nat) : Bool :=
  decide (x.size + w.size = ccs.m) &&
    let z := (toFArray x).append (toFArray w)
    let mz := ccs.matrices.map (fun m => sparseMatrixMulF m z)
    (List.range ccs.n).all fun row =>
      let point := Array.ofFn fun j : Fin ccs.matrices.size =>
        fAt mz j.1 row
      decide (evalSparsePoly point ccs.polyTerms = 0)

private def logicalWitnessFromEncoded
    (z : Array (Array Nat))
    (expectedM : Nat) : Array F :=
  Array.ofFn fun col : Fin expectedM =>
    witnessGet z expectedM (col.1 % D) col.1

private def ccsRowwiseZeroChecksFromWitness
    (ccs : NeoFoldCcsCase)
    (witness : Array (Array Nat)) : Bool :=
  witnessShapeChecks witness ccs.m &&
    let z := logicalWitnessFromEncoded witness ccs.m
    let mz := ccs.matrices.map (fun m => sparseMatrixMulF m z)
    (List.range ccs.n).all fun row =>
      let point := Array.ofFn fun j : Fin ccs.matrices.size =>
        fAt mz j.1 row
      decide (evalSparsePoly point ccs.polyTerms = 0)

private def computeYRow
    (ccs : NeoFoldCcsCase)
    (z : Array (Array Nat))
    (r : Array KNat)
    (matrixIdx : Nat) : Array KExt :=
  let chiR := tensorPoint (toKArray r)
  let m := ccs.matrices[matrixIdx]!
  let blockCount := packedCols m.ncols
  let witnessBlockCoeffs := fun blk : Nat =>
    Array.ofFn fun i : Fin D =>
      let col := blk * D + i.1
      if h : col < m.ncols then
        witnessGet z ccs.m (col % D) col
      else
        0
  let rowCap := Nat.min (Nat.min m.nrows ccs.n) chiR.size
  let emptyBlocks : Array Coeffs := Array.replicate blockCount zeroRq
  let addWeightedCoeff :=
    fun (blocks : Array Coeffs) (blk off : Nat) (coeff : F) =>
      if hBlk : blk < blocks.size then
        let row := blocks[blk]'hBlk
        if hOff : off < row.size then
          blocks.set! blk (row.set! off (row[off]'hOff + coeff))
        else
          blocks
      else
        blocks
  let weightedBlocks :=
    if m.identity then
      (List.range (Nat.min rowCap m.ncols)).foldl
        (fun (acc : Array Coeffs × Array Coeffs) row =>
          let w := chiR[row]!
          if w = 0 then
            acc
          else
            let blk := row / D
            let off := row % D
            (addWeightedCoeff acc.1 blk off w.re, addWeightedCoeff acc.2 blk off w.im))
        (emptyBlocks, emptyBlocks)
    else
      m.entries.foldl
        (fun (acc : Array Coeffs × Array Coeffs) entry =>
          if entry.row < rowCap && entry.col < m.ncols then
            let w := chiR[entry.row]!
            if w = 0 then
              acc
            else
              let blk := entry.col / D
              let off := entry.col % D
              let val := toF entry.value
              (addWeightedCoeff acc.1 blk off (w.re * val),
                addWeightedCoeff acc.2 blk off (w.im * val))
          else
            acc)
        (emptyBlocks, emptyBlocks)
  let reIm :=
    (List.range blockCount).foldl
      (fun (acc : Coeffs × Coeffs) blk =>
        let zBlk := witnessBlockCoeffs blk
        let aBarRe := superneoBarBlock nativeBarMatrix weightedBlocks.1[blk]!
        let aBarIm := superneoBarBlock nativeBarMatrix weightedBlocks.2[blk]!
        (vecAdd acc.1 (mulRq aBarRe zBlk), vecAdd acc.2 (mulRq aBarIm zBlk)))
      (zeroRq, zeroRq)
  Array.ofFn fun i : Fin D =>
    { re := reIm.1[i]!, im := reIm.2[i]! }

private def computeYZcol
    (ccs : NeoFoldCcsCase)
    (z : Array (Array Nat))
    (sCol : Array KNat) : Array KExt :=
  let chiS := tensorPoint (toKArray sCol)
  let dPad := nextPow2AtLeastTwo D
  let head :=
    Array.ofFn fun rho : Fin D =>
      (List.range ccs.m).foldl
        (fun acc col =>
          acc + KExt.scaleBase (witnessGet z ccs.m rho.1 col) chiS[col]!)
        0
  head.append (Array.replicate (dPad - D) 0)

private def balancedDigitsAtColumn
    (z : Array (Array Nat))
    (expectedM : Nat)
    (b col : Nat) : Array KExt :=
  let raw := witnessGet z expectedM (col % D) col
  let digits := splitBalancedScalar raw b D
  Array.ofFn fun rho : Fin D => KExt.ofF (digits[rho.1]!)

private def computeYZcolDigits
    (b : Nat)
    (ccs : NeoFoldCcsCase)
    (z : Array (Array Nat))
    (sCol : Array KNat)
    (dPad : Nat) : Array KExt :=
  let chiS := tensorPoint (toKArray sCol)
  let head :=
    Array.ofFn fun rho : Fin D =>
      (List.range ccs.m).foldl
        (fun acc col =>
          let digit := balancedDigitsAtColumn z ccs.m b col
          acc + digit[rho.1]! * chiS[col]!)
        0
  head.append (Array.replicate (dPad - D) 0)

private def currentBatchSizeChecks (step : NeoFoldStepArtifactCase) : Bool :=
  let n := step.mcsBatchCommitments.size
  decide (step.mcsBatchPublicInput.size = n) &&
    decide (step.mcsBatchPrivateInput.size = n) &&
    decide (step.mcsBatchWitnessZ.size = n)

private def checkCurrentStepCE
    (ccs : NeoFoldCcsCase)
    (b : Nat)
    (step : NeoFoldStepArtifactCase)
    : Bool :=
  currentBatchSizeChecks step &&
    let currentCount := step.mcsBatchCommitments.size
    decide (currentCount ≤ step.ccsOut.size) &&
    (List.range currentCount).all fun idx =>
      let claim := step.ccsOut[idx]!
      let witness := step.mcsBatchWitnessZ[idx]!
      let x := step.mcsBatchPublicInput[idx]!
      let w := step.mcsBatchPrivateInput[idx]!
      let commitment := step.mcsBatchCommitments[idx]!
      witnessShapeChecks witness ccs.m &&
        claimBasicShapeChecks ccs claim &&
        ccsRowwiseZeroChecksFromWitness ccs witness &&
        decide (projectXFromPublicInputs x = claim.x.map toFArray) &&
        decide (claim.commitment = commitment) &&
        (List.range ccs.matrices.size).all fun j =>
          let want := computeYRow ccs witness claim.r j
          let got := toKArray claim.yRing[j]!
          decide (got.take D = want) &&
            decide (claim.ct[j]! = claim.yRing[j]![0]!)
        &&
        (if claim.sCol.isEmpty && claim.yZcol.isEmpty then
          true
        else
          decide (toKArray claim.yZcol =
            computeYZcolDigits b ccs witness claim.sCol claim.yZcol.size))

structure NeoFoldCurrentStepCEBreakdown where
  batchSizeAligned : Bool
  witnessShape : Bool
  claimShape : Bool
  ccsZero : Bool
  projectedX : Bool
  commitment : Bool
  yRows : Bool
  yZcol : Bool
deriving Repr, Inhabited

private def currentStepCEBreakdown
    (ccs : NeoFoldCcsCase)
    (b : Nat)
    (step : NeoFoldStepArtifactCase)
    : NeoFoldCurrentStepCEBreakdown :=
  let claim? := step.ccsOut[0]?
  let witness := step.mcsBatchWitnessZ[0]?.getD step.mcsWitnessZ
  let x := step.mcsBatchPublicInput[0]?.getD step.mcsPublicInput
  let commitment := step.mcsBatchCommitments[0]?.getD step.mcsCommitment
  let yRows :=
    match claim? with
    | none => false
    | some claim =>
        (List.range ccs.matrices.size).all fun j =>
          let want := computeYRow ccs witness claim.r j
          let got := toKArray claim.yRing[j]!
          decide (got.take D = want) &&
            decide (claim.ct[j]! = claim.yRing[j]![0]!)
  let yZcol :=
    match claim? with
    | none => false
    | some claim =>
        if claim.sCol.isEmpty && claim.yZcol.isEmpty then
          true
        else
          decide (toKArray claim.yZcol =
            computeYZcolDigits b ccs witness claim.sCol claim.yZcol.size)
  match claim? with
  | none =>
      { batchSizeAligned := currentBatchSizeChecks step
        witnessShape := false
        claimShape := false
        ccsZero := false
        projectedX := false
        commitment := false
        yRows := false
        yZcol := false }
  | some claim =>
      { batchSizeAligned := currentBatchSizeChecks step
        witnessShape := witnessShapeChecks witness ccs.m
        claimShape := claimBasicShapeChecks ccs claim
        ccsZero := ccsRowwiseZeroChecksFromWitness ccs witness
        projectedX := decide (projectXFromPublicInputs x = claim.x.map toFArray)
        commitment := decide (claim.commitment = commitment)
        yRows := yRows
        yZcol := yZcol }

private def checkClaimCEFromWitness
    (ccs : NeoFoldCcsCase)
    (_b : Nat)
    (claim : NeoFoldClaimCase)
    (witness : Array (Array Nat)) : Bool :=
  witnessShapeChecks witness ccs.m &&
    claimBasicShapeChecks ccs claim &&
    ccsRowwiseZeroChecksFromWitness ccs witness &&
    decide (projectXFromWitnessAtIndices witness ccs.m claim.xColIndices = claim.x.map toFArray) &&
    (List.range ccs.matrices.size).all fun j =>
      let want := computeYRow ccs witness claim.r j
      let got := toKArray claim.yRing[j]!
      decide (got.take D = want) &&
        decide (claim.ct[j]! = claim.yRing[j]![0]!)

/--
Public Rust-artifact CE witness check.

This is the implementation-level CE acceptance predicate used by the
`neo-fold` artifact validator. It is intentionally exported so the
Rust-refinement layer can prove that implementation acceptance conservatively
refines the paper-core CE claim after erasing implementation sidecars.
-/
def implCheckClaimCEFromWitness
    (ccs : NeoFoldCcsCase)
    (b : Nat)
    (claim : NeoFoldClaimCase)
    (witness : Array (Array Nat)) : Bool :=
  checkClaimCEFromWitness ccs b claim witness

/--
Normalize implementation-only CE sidecars to canonical defaults.

This is a Rust-validation helper only. It is not a paper object.
-/
def normalizeClaimSidecars (claim : NeoFoldClaimCase) : NeoFoldClaimCase :=
  { claim with
    foldDigest := #[]
    cStepCoords := #[]
    uOffset := 0
    uLen := 0 }

/--
Normalize refinement-only claim metadata to canonical defaults.

Unlike `normalizeClaimSidecars`, this also canonicalizes `xColIndices`. Those
indices are Rust-export/refinement metadata for witness projection and are not
part of the public claim equality surface used by final-obligation checks.
-/
def normalizeClaimRefinementMetadata (claim : NeoFoldClaimCase) : NeoFoldClaimCase :=
  { normalizeClaimSidecars claim with
    xColIndices := Array.range claim.mIn }

@[simp] theorem normalizeClaimSidecars_commitment (claim : NeoFoldClaimCase) :
    (normalizeClaimSidecars claim).commitment = claim.commitment := rfl
@[simp] theorem normalizeClaimSidecars_r (claim : NeoFoldClaimCase) :
    (normalizeClaimSidecars claim).r = claim.r := rfl
@[simp] theorem normalizeClaimSidecars_sCol (claim : NeoFoldClaimCase) :
    (normalizeClaimSidecars claim).sCol = claim.sCol := rfl
@[simp] theorem normalizeClaimSidecars_mIn (claim : NeoFoldClaimCase) :
    (normalizeClaimSidecars claim).mIn = claim.mIn := rfl
@[simp] theorem normalizeClaimSidecars_x (claim : NeoFoldClaimCase) :
    (normalizeClaimSidecars claim).x = claim.x := rfl
@[simp] theorem normalizeClaimSidecars_xColIndices (claim : NeoFoldClaimCase) :
    (normalizeClaimSidecars claim).xColIndices = claim.xColIndices := rfl
@[simp] theorem normalizeClaimSidecars_yRing (claim : NeoFoldClaimCase) :
    (normalizeClaimSidecars claim).yRing = claim.yRing := rfl
@[simp] theorem normalizeClaimSidecars_ct (claim : NeoFoldClaimCase) :
    (normalizeClaimSidecars claim).ct = claim.ct := rfl
@[simp] theorem normalizeClaimSidecars_auxOpenings (claim : NeoFoldClaimCase) :
    (normalizeClaimSidecars claim).auxOpenings = claim.auxOpenings := rfl
@[simp] theorem normalizeClaimSidecars_yZcol (claim : NeoFoldClaimCase) :
    (normalizeClaimSidecars claim).yZcol = claim.yZcol := rfl
@[simp] theorem normalizeClaimSidecars_foldDigest (claim : NeoFoldClaimCase) :
    (normalizeClaimSidecars claim).foldDigest = #[] := rfl
@[simp] theorem normalizeClaimSidecars_cStepCoords (claim : NeoFoldClaimCase) :
    (normalizeClaimSidecars claim).cStepCoords = #[] := rfl
@[simp] theorem normalizeClaimSidecars_uOffset (claim : NeoFoldClaimCase) :
    (normalizeClaimSidecars claim).uOffset = 0 := rfl
@[simp] theorem normalizeClaimSidecars_uLen (claim : NeoFoldClaimCase) :
    (normalizeClaimSidecars claim).uLen = 0 := rfl

@[simp] theorem checkClaimCEFromWitness_normalizeClaimSidecars
    (ccs : NeoFoldCcsCase)
    (b : Nat)
    (claim : NeoFoldClaimCase)
    (witness : Array (Array Nat)) :
    checkClaimCEFromWitness ccs b (normalizeClaimSidecars claim) witness =
      checkClaimCEFromWitness ccs b claim witness := by
  simp [checkClaimCEFromWitness, normalizeClaimSidecars,
    claimBasicShapeChecks, claimCommitmentShape, claimXShape]

@[simp] theorem getBang_map_normalizeClaimSidecars_commitment
    (claims : Array NeoFoldClaimCase)
    (idx : Nat) :
    ((claims.map normalizeClaimSidecars)[idx]!).commitment =
      (claims[idx]!).commitment := by
  by_cases h : idx < claims.size <;> simp [h, normalizeClaimSidecars]

@[simp] theorem getBang_map_normalizeClaimSidecars_r
    (claims : Array NeoFoldClaimCase)
    (idx : Nat) :
    ((claims.map normalizeClaimSidecars)[idx]!).r =
      (claims[idx]!).r := by
  by_cases h : idx < claims.size <;> simp [h, normalizeClaimSidecars]

@[simp] theorem getBang_map_normalizeClaimSidecars_sCol
    (claims : Array NeoFoldClaimCase)
    (idx : Nat) :
    ((claims.map normalizeClaimSidecars)[idx]!).sCol =
      (claims[idx]!).sCol := by
  by_cases h : idx < claims.size <;> simp [h, normalizeClaimSidecars]

@[simp] theorem getBang_map_normalizeClaimSidecars_mIn
    (claims : Array NeoFoldClaimCase)
    (idx : Nat) :
    ((claims.map normalizeClaimSidecars)[idx]!).mIn =
      (claims[idx]!).mIn := by
  by_cases h : idx < claims.size <;> simp [h, normalizeClaimSidecars]

@[simp] theorem getBang_map_normalizeClaimSidecars_xColIndices
    (claims : Array NeoFoldClaimCase)
    (idx : Nat) :
    ((claims.map normalizeClaimSidecars)[idx]!).xColIndices =
      (claims[idx]!).xColIndices := by
  by_cases h : idx < claims.size <;> simp [h, normalizeClaimSidecars]

@[simp] theorem getBang_map_normalizeClaimSidecars_x
    (claims : Array NeoFoldClaimCase)
    (idx : Nat) :
    ((claims.map normalizeClaimSidecars)[idx]!).x =
      (claims[idx]!).x := by
  by_cases h : idx < claims.size <;> simp [h, normalizeClaimSidecars]

@[simp] theorem getBang_map_normalizeClaimSidecars_yRing
    (claims : Array NeoFoldClaimCase)
    (idx : Nat) :
    ((claims.map normalizeClaimSidecars)[idx]!).yRing =
      (claims[idx]!).yRing := by
  by_cases h : idx < claims.size <;> simp [h, normalizeClaimSidecars]

@[simp] theorem getBang_map_normalizeClaimSidecars_ct
    (claims : Array NeoFoldClaimCase)
    (idx : Nat) :
    ((claims.map normalizeClaimSidecars)[idx]!).ct =
      (claims[idx]!).ct := by
  by_cases h : idx < claims.size <;> simp [h, normalizeClaimSidecars]

@[simp] theorem getBang_map_normalizeClaimSidecars_auxOpenings
    (claims : Array NeoFoldClaimCase)
    (idx : Nat) :
    ((claims.map normalizeClaimSidecars)[idx]!).auxOpenings =
      (claims[idx]!).auxOpenings := by
  by_cases h : idx < claims.size <;> simp [h, normalizeClaimSidecars]

@[simp] theorem getBang_map_normalizeClaimSidecars_yZcol
    (claims : Array NeoFoldClaimCase)
    (idx : Nat) :
    ((claims.map normalizeClaimSidecars)[idx]!).yZcol =
      (claims[idx]!).yZcol := by
  by_cases h : idx < claims.size <;> simp [h, normalizeClaimSidecars]

@[simp] theorem get?_map_normalizeClaimSidecars
    (claims : Array NeoFoldClaimCase)
    (idx : Nat) :
    (claims.map normalizeClaimSidecars)[idx]? =
      (claims[idx]?).map normalizeClaimSidecars := by
  by_cases h : idx < claims.size <;> simp [h, normalizeClaimSidecars]

@[simp] theorem claimBasicShapeChecks_normalizeClaimSidecars
    (ccs : NeoFoldCcsCase)
    (claim : NeoFoldClaimCase) :
    claimBasicShapeChecks ccs (normalizeClaimSidecars claim) =
      claimBasicShapeChecks ccs claim := by
  simp [claimBasicShapeChecks, claimCommitmentShape, claimXShape, normalizeClaimSidecars]

@[simp] theorem claimCtConstantTermChecks_normalizeClaimSidecars
    (claim : NeoFoldClaimCase) :
    claimCtConstantTermChecks (normalizeClaimSidecars claim) =
      claimCtConstantTermChecks claim := by
  simp [claimCtConstantTermChecks, normalizeClaimSidecars]

@[simp] theorem meBatchInvariantChecks_map_normalizeClaimSidecars
    (claims : Array NeoFoldClaimCase) :
    meBatchInvariantChecks (claims.map normalizeClaimSidecars) =
      meBatchInvariantChecks claims := by
  cases hHead : claims[0]? <;> simp [meBatchInvariantChecks, claimXShape, hHead]

private def mainLaneInputWitnessChecks (step : NeoFoldStepArtifactCase) : Bool :=
  let lane := step.mainLane
  let currentCount := step.mcsBatchCommitments.size
  decide (step.mainLaneInputWitnessZ.size = lane.inputs.size) &&
    (List.range lane.inputs.size).all fun idx =>
      let claim := lane.inputs[idx]!
      let witness := step.mainLaneInputWitnessZ[idx]!
      if idx < currentCount then
        let x := step.mcsBatchPublicInput[idx]!
        let commitment := step.mcsBatchCommitments[idx]!
        witnessShapeChecks witness lane.ccs.m &&
          claimBasicShapeChecks lane.ccs claim &&
          claimCtConstantTermChecks claim &&
          ccsRowwiseZeroChecksFromWitness lane.ccs witness &&
          decide (projectXFromPublicInputs x = claim.x.map toFArray) &&
          decide (claim.commitment = commitment) &&
          (List.range lane.ccs.matrices.size).all fun j =>
            let want := computeYRow lane.ccs witness claim.r j
            let got := toKArray claim.yRing[j]!
            decide (got.take D = want) &&
              decide (claim.ct[j]! = claim.yRing[j]![0]!) &&
          (if claim.sCol.isEmpty && claim.yZcol.isEmpty then
            true
          else
            decide (toKArray claim.yZcol =
              computeYZcolDigits lane.foldBase lane.ccs witness claim.sCol claim.yZcol.size))
      else
        checkClaimCEFromWitness lane.ccs lane.foldBase claim witness

private def mainLaneParentWitnessChecks (step : NeoFoldStepArtifactCase) : Bool :=
  checkClaimCEFromWitness
    step.mainLane.ccs
    step.mainLane.foldBase
    step.mainLane.parent
    step.mainLaneParentWitnessZ

private def mainLaneChildWitnessChecks
    (isTerminal : Bool)
    (step : NeoFoldStepArtifactCase) : Bool :=
  let lane := step.mainLane
  if isTerminal && lane.children.isEmpty then
    step.mainLaneChildWitnessZ.isEmpty
  else
    decide (step.mainLaneChildWitnessZ.size = lane.children.size) &&
      (List.range lane.children.size).all fun idx =>
        checkClaimCEFromWitness
          lane.ccs
          lane.foldBase
          (lane.children[idx]!)
          (step.mainLaneChildWitnessZ[idx]!)

private def rhoMulFColumn (rhoCoeffs col : Array Nat) : Coeffs :=
  mulRq (toFArray rhoCoeffs) (takeDFieldCoeffs col)

private def rhoMulFCoeffs (rhoCoeffs : Array Nat) (col : Coeffs) : Coeffs :=
  mulRq (toFArray rhoCoeffs) col

private def witnessBlocks
    (z : Array (Array Nat))
    (expectedM : Nat) : Array Coeffs :=
  Array.ofFn fun blk : Fin (packedCols expectedM) =>
    Array.ofFn fun off : Fin D =>
      let col := blk.1 * D + off.1
      if h : col < expectedM then
        witnessGet z expectedM (col % D) col
      else
        0

private def mixWitnessBlocksRLC
    (rhoCoeffs : Array (Array Nat))
    (inputWitnessZ : Array (Array (Array Nat)))
    (expectedM : Nat) : Array Coeffs :=
  Array.ofFn fun blk : Fin (packedCols expectedM) =>
    (List.range inputWitnessZ.size).foldl
      (fun acc idx =>
        vecAdd acc <|
          rhoMulFCoeffs
            (rhoCoeffs[idx]!)
            ((witnessBlocks (inputWitnessZ[idx]!) expectedM)[blk.1]!))
      zeroRq

private def recomposeChildWitnessBlocks
    (b : Nat)
    (childWitnessZ : Array (Array (Array Nat)))
    (expectedM : Nat) : Array Coeffs :=
  Array.ofFn fun blk : Fin (packedCols expectedM) =>
    (List.range childWitnessZ.size).foldl
      (fun acc idx =>
        vecAdd acc <|
          vecScale
            (toF (b ^ idx))
            ((witnessBlocks (childWitnessZ[idx]!) expectedM)[blk.1]!))
      zeroRq

private def rlcWitnessChecks
    (expectedM : Nat)
    (rhoCoeffs : Array (Array Nat))
    (inputWitnessZ : Array (Array (Array Nat)))
    (parentWitnessZ : Array (Array Nat)) : Bool :=
  decide (rhoCoeffs.size = inputWitnessZ.size) &&
    witnessShapeChecks parentWitnessZ expectedM &&
    (List.range inputWitnessZ.size).all fun idx =>
      witnessShapeChecks (inputWitnessZ[idx]!) expectedM &&
        decide (
          mixWitnessBlocksRLC rhoCoeffs inputWitnessZ expectedM =
            witnessBlocks parentWitnessZ expectedM)

private def decWitnessChecks
    (b expectedM : Nat)
    (parentWitnessZ : Array (Array Nat))
    (childWitnessZ : Array (Array (Array Nat))) : Bool :=
  witnessShapeChecks parentWitnessZ expectedM &&
    (List.range childWitnessZ.size).all fun idx =>
      witnessShapeChecks (childWitnessZ[idx]!) expectedM &&
        decide (
          recomposeChildWitnessBlocks b childWitnessZ expectedM =
            witnessBlocks parentWitnessZ expectedM)

private def laneWitnessChainChecks
    (lane : NeoFoldLaneCase)
    (chain : NeoFoldLaneWitnessCase) : Bool :=
  decide (chain.inputWitnessZ.size = lane.inputs.size) &&
    decide (chain.childWitnessZ.size = lane.children.size) &&
    (List.range lane.inputs.size).all fun idx =>
      checkClaimCEFromWitness lane.ccs lane.foldBase (lane.inputs[idx]!) (chain.inputWitnessZ[idx]!)
    &&
    checkClaimCEFromWitness lane.ccs lane.foldBase lane.parent chain.parentWitnessZ
    &&
    (List.range lane.children.size).all fun idx =>
      checkClaimCEFromWitness lane.ccs lane.foldBase (lane.children[idx]!) (chain.childWitnessZ[idx]!)
    &&
    rlcWitnessChecks lane.ccs.m lane.rhoCoeffs chain.inputWitnessZ chain.parentWitnessZ &&
    decWitnessChecks lane.foldBase lane.ccs.m chain.parentWitnessZ chain.childWitnessZ

private def laneWitnessArrayChecks
    (lanes : Array NeoFoldLaneCase)
    (chains : Array NeoFoldLaneWitnessCase) : Bool :=
  decide (chains.size = lanes.size) &&
    (List.range lanes.size).all fun idx =>
      laneWitnessChainChecks (lanes[idx]!) (chains[idx]!)

structure NeoFoldWitnessChainBreakdown where
  inputCount : Bool
  childCount : Bool
  inputShapes : Bool
  inputClaims : Bool
  parentShape : Bool
  parentClaim : Bool
  childShapes : Bool
  childClaims : Bool
  rlcWitness : Bool
  decWitness : Bool
deriving Repr, Inhabited

private def laneWitnessChainBreakdown
    (lane : NeoFoldLaneCase)
    (chain : NeoFoldLaneWitnessCase) : NeoFoldWitnessChainBreakdown :=
  { inputCount := decide (chain.inputWitnessZ.size = lane.inputs.size)
    childCount := decide (chain.childWitnessZ.size = lane.children.size)
    inputShapes :=
      (List.range chain.inputWitnessZ.size).all fun idx =>
        witnessShapeChecks (chain.inputWitnessZ[idx]!) lane.ccs.m
    inputClaims :=
      decide (chain.inputWitnessZ.size = lane.inputs.size) &&
        (List.range lane.inputs.size).all fun idx =>
          checkClaimCEFromWitness lane.ccs lane.foldBase (lane.inputs[idx]!) (chain.inputWitnessZ[idx]!)
    parentShape := witnessShapeChecks chain.parentWitnessZ lane.ccs.m
    parentClaim := checkClaimCEFromWitness lane.ccs lane.foldBase lane.parent chain.parentWitnessZ
    childShapes :=
      (List.range chain.childWitnessZ.size).all fun idx =>
        witnessShapeChecks (chain.childWitnessZ[idx]!) lane.ccs.m
    childClaims :=
      decide (chain.childWitnessZ.size = lane.children.size) &&
        (List.range lane.children.size).all fun idx =>
          checkClaimCEFromWitness lane.ccs lane.foldBase (lane.children[idx]!) (chain.childWitnessZ[idx]!)
    rlcWitness := rlcWitnessChecks lane.ccs.m lane.rhoCoeffs chain.inputWitnessZ chain.parentWitnessZ
    decWitness := decWitnessChecks lane.foldBase lane.ccs.m chain.parentWitnessZ chain.childWitnessZ }

structure NeoFoldMainLaneWitnessBreakdown where
  inputCount : Bool
  currentInputs : Bool
  carriedInputs : Bool
  parentShape : Bool
  parentClaim : Bool
  childCount : Bool
  childShapes : Bool
  childClaims : Bool
  rlcWitness : Bool
  decWitness : Bool
deriving Repr, Inhabited

private def mainLaneRlcWitnessChecks (step : NeoFoldStepArtifactCase) : Bool :=
  rlcWitnessChecks
    step.mainLane.ccs.m
    step.mainLane.rhoCoeffs
    step.mainLaneInputWitnessZ
    step.mainLaneParentWitnessZ

private def mainLaneDecWitnessChecks
    (isTerminal : Bool)
    (step : NeoFoldStepArtifactCase) : Bool :=
  let lane := step.mainLane
  if isTerminal && lane.children.isEmpty then
    step.mainLaneChildWitnessZ.isEmpty
  else
    decide (step.mainLaneChildWitnessZ.size = lane.children.size) &&
      decWitnessChecks
        lane.foldBase
        lane.ccs.m
        step.mainLaneParentWitnessZ
        step.mainLaneChildWitnessZ

private def mainLaneWitnessBreakdown
    (isTerminal : Bool)
    (step : NeoFoldStepArtifactCase) : NeoFoldMainLaneWitnessBreakdown :=
  let lane := step.mainLane
  let currentCount := step.mcsBatchCommitments.size
  { inputCount := decide (step.mainLaneInputWitnessZ.size = lane.inputs.size)
    currentInputs :=
      (List.range (min currentCount step.mainLaneInputWitnessZ.size)).all fun idx =>
        let claim := lane.inputs[idx]!
        let witness := step.mainLaneInputWitnessZ[idx]!
        let x := step.mcsBatchPublicInput[idx]!
        let commitment := step.mcsBatchCommitments[idx]!
        witnessShapeChecks witness lane.ccs.m &&
          claimBasicShapeChecks lane.ccs claim &&
          claimCtConstantTermChecks claim &&
          ccsRowwiseZeroChecksFromWitness lane.ccs witness &&
          decide (projectXFromPublicInputs x = claim.x.map toFArray) &&
          decide (claim.commitment = commitment) &&
          (List.range lane.ccs.matrices.size).all fun j =>
            let want := computeYRow lane.ccs witness claim.r j
            let got := toKArray claim.yRing[j]!
            decide (got.take D = want) &&
              decide (claim.ct[j]! = claim.yRing[j]![0]!) &&
          (if claim.sCol.isEmpty && claim.yZcol.isEmpty then
            true
          else
            decide (toKArray claim.yZcol =
              computeYZcolDigits lane.foldBase lane.ccs witness claim.sCol claim.yZcol.size))
    carriedInputs :=
      (List.range lane.inputs.size).all fun idx =>
        if idx < currentCount then
          true
        else
          checkClaimCEFromWitness lane.ccs lane.foldBase (lane.inputs[idx]!) (step.mainLaneInputWitnessZ[idx]!)
    parentShape := witnessShapeChecks step.mainLaneParentWitnessZ lane.ccs.m
    parentClaim := checkClaimCEFromWitness lane.ccs lane.foldBase lane.parent step.mainLaneParentWitnessZ
    childCount :=
      if isTerminal && lane.children.isEmpty then
        step.mainLaneChildWitnessZ.isEmpty
      else
        decide (step.mainLaneChildWitnessZ.size = lane.children.size)
    childShapes :=
      (List.range step.mainLaneChildWitnessZ.size).all fun idx =>
        witnessShapeChecks (step.mainLaneChildWitnessZ[idx]!) lane.ccs.m
    childClaims :=
      (if isTerminal && lane.children.isEmpty then
        true
      else
        decide (step.mainLaneChildWitnessZ.size = lane.children.size)) &&
        (List.range lane.children.size).all fun idx =>
          checkClaimCEFromWitness lane.ccs lane.foldBase (lane.children[idx]!) (step.mainLaneChildWitnessZ[idx]!)
    rlcWitness := mainLaneRlcWitnessChecks step
    decWitness := mainLaneDecWitnessChecks isTerminal step }

private def kRowReCoeffs (row : Array KNat) : Coeffs :=
  Array.ofFn fun i : Fin D =>
    if h : i.1 < row.size then
      toF (row[i.1]'h).c0
    else
      0

private def kRowImCoeffs (row : Array KNat) : Coeffs :=
  Array.ofFn fun i : Fin D =>
    if h : i.1 < row.size then
      toF (row[i.1]'h).c1
    else
      0

private def rhoMulKRow (rhoCoeffs : Array Nat) (row : Array KNat) : Array KExt :=
  let rho := toFArray rhoCoeffs
  let re := mulRq rho (kRowReCoeffs row)
  let im := mulRq rho (kRowImCoeffs row)
  Id.run do
    let mut out := Array.replicate D (0 : KExt)
    let mut i := 0
    while i < D do
      out := out.set! i { re := re[i]!, im := im[i]! }
      i := i + 1
    return out

private def mixCommitmentsRLC (rhoCoeffs : Array (Array Nat)) (claims : Array NeoFoldClaimCase) : NeoFoldCommitmentCase :=
  let kappa :=
    match claims[0]? with
    | some claim => claim.commitment.cols.size
    | none => 0
  let cols :=
    Array.ofFn fun col : Fin kappa =>
      let mixed :=
        (List.range claims.size).foldl
          (fun acc idx => vecAdd acc (rhoMulFColumn (rhoCoeffs[idx]!) (claims[idx]!.commitment.cols[col.1]!)))
          (Array.replicate D 0)
      mixed.map fun x => x.val
  { cols := cols }

private theorem neoFoldCommitmentCase_eq_of_cols_eq
    {lhs rhs : NeoFoldCommitmentCase}
    (hCols : lhs.cols = rhs.cols) :
    lhs = rhs := by
  cases lhs
  cases rhs
  cases hCols
  rfl

private def mixXColumnsRLC (rhoCoeffs : Array (Array Nat)) (claims : Array NeoFoldClaimCase) : FMatrix :=
  match claims[0]? with
  | none => #[]
  | some first =>
      Array.ofFn fun rho : Fin D =>
        Array.ofFn fun col : Fin first.mIn =>
          (List.range claims.size).foldl
            (fun acc idx =>
              let term := rhoMulFCoeffs (rhoCoeffs[idx]!) (matrixColCoeffs (claims[idx]!.x) col.1)
              acc + term[rho.1]!)
            0

private def mixYRowsRLCIdx
    (rhoCoeffs : Array (Array Nat))
    (claims : Array NeoFoldClaimCase)
    (j : Nat) : Array KExt :=
  let dPad := (claims[0]!).yRing[j]!.size
  let head :=
    (List.range claims.size).foldl
      (fun acc idx => kVecAdd acc (rhoMulKRow (rhoCoeffs[idx]!) (claims[idx]!.yRing[j]!)))
      (Array.replicate D 0)
  head.append (Array.replicate (dPad - D) 0)

private def mixAuxOpeningsRLC
    (rhoCoeffs : Array (Array Nat))
    (claims : Array NeoFoldClaimCase) : Array KExt :=
  match claims[0]? with
  | none => #[]
  | some first =>
      Array.ofFn fun i : Fin first.auxOpenings.size =>
        (List.range claims.size).foldl
          (fun acc idx =>
            acc + KExt.scaleBase (toF ((rhoCoeffs[idx]!)[0]!)) (KExt.ofKNat ((claims[idx]!.auxOpenings)[i.1]!)))
          0

private def mixYZcolRLC
    (rhoCoeffs : Array (Array Nat))
    (claims : Array NeoFoldClaimCase) : Array KExt :=
  match claims[0]? with
  | none => #[]
  | some first =>
      if first.yZcol.isEmpty then
        #[]
      else
        let dPad := first.yZcol.size
        let head :=
          (List.range claims.size).foldl
            (fun acc idx => kVecAdd acc (rhoMulKRow (rhoCoeffs[idx]!) (claims[idx]!.yZcol)))
            (Array.replicate D 0)
        head.append (Array.replicate (dPad - D) 0)

@[simp] theorem mixCommitmentsRLC_map_normalizeClaimSidecars
    (rhoCoeffs : Array (Array Nat))
    (claims : Array NeoFoldClaimCase) :
    mixCommitmentsRLC rhoCoeffs (claims.map normalizeClaimSidecars) =
      mixCommitmentsRLC rhoCoeffs claims := by
  apply neoFoldCommitmentCase_eq_of_cols_eq
  have hKappa :
      (match (claims.map normalizeClaimSidecars)[0]? with
      | some claim => claim.commitment.cols.size
      | none => 0) =
      (match claims[0]? with
      | some claim => claim.commitment.cols.size
      | none => 0) := by
    cases hHead : claims[0]? <;> simp [hHead, normalizeClaimSidecars]
  apply Array.ext
  · simpa [mixCommitmentsRLC] using hKappa
  · intro col hColNorm hCol
    simp [mixCommitmentsRLC, rhoMulFColumn, takeDFieldCoeffs, hColNorm, hCol]

@[simp] theorem mixXColumnsRLC_map_normalizeClaimSidecars
    (rhoCoeffs : Array (Array Nat))
    (claims : Array NeoFoldClaimCase) :
    mixXColumnsRLC rhoCoeffs (claims.map normalizeClaimSidecars) =
      mixXColumnsRLC rhoCoeffs claims := by
  cases hHead : claims[0]? <;> simp [mixXColumnsRLC, hHead, rhoMulFCoeffs, matrixColCoeffs]

@[simp] theorem mixYRowsRLCIdx_map_normalizeClaimSidecars
    (rhoCoeffs : Array (Array Nat))
    (claims : Array NeoFoldClaimCase)
    (j : Nat) :
    mixYRowsRLCIdx rhoCoeffs (claims.map normalizeClaimSidecars) j =
      mixYRowsRLCIdx rhoCoeffs claims j := by
  simp [mixYRowsRLCIdx, rhoMulKRow, kRowReCoeffs, kRowImCoeffs]

@[simp] theorem mixAuxOpeningsRLC_map_normalizeClaimSidecars
    (rhoCoeffs : Array (Array Nat))
    (claims : Array NeoFoldClaimCase) :
    mixAuxOpeningsRLC rhoCoeffs (claims.map normalizeClaimSidecars) =
      mixAuxOpeningsRLC rhoCoeffs claims := by
  cases hHead : claims[0]? <;> simp [mixAuxOpeningsRLC, hHead]

@[simp] theorem mixYZcolRLC_map_normalizeClaimSidecars
    (rhoCoeffs : Array (Array Nat))
    (claims : Array NeoFoldClaimCase) :
    mixYZcolRLC rhoCoeffs (claims.map normalizeClaimSidecars) =
      mixYZcolRLC rhoCoeffs claims := by
  cases hHead : claims[0]? <;> simp [mixYZcolRLC, hHead, rhoMulKRow, kRowReCoeffs, kRowImCoeffs]

private def rlcParentChecks (ccs : NeoFoldCcsCase) (lane : NeoFoldLaneCase) : Bool :=
  let inputs := lane.inputs
  match inputs[0]? with
  | none => false
  | some first =>
      claimBasicShapeChecks ccs first &&
        claimCtConstantTermChecks first &&
        meBatchInvariantChecks inputs &&
        decide (lane.rhoCount = inputs.size) &&
        rhoCoeffShapeChecks lane &&
        inputs.all (claimBasicShapeChecks ccs) &&
        inputs.all claimCtConstantTermChecks &&
        claimCtConstantTermChecks lane.parent &&
        inputs.all fun inst =>
          decide (inst.auxOpenings.size = first.auxOpenings.size) &&
        decide (lane.parent.commitment = mixCommitmentsRLC lane.rhoCoeffs inputs) &&
        decide (lane.parent.x = (mixXColumnsRLC lane.rhoCoeffs inputs).map (fun row => row.map fun x => x.val)) &&
        decide (lane.parent.r = first.r) &&
        decide (lane.parent.sCol = first.sCol) &&
        decide (lane.parent.mIn = first.mIn) &&
        decide (lane.parent.cStepCoords = first.cStepCoords) &&
        decide (lane.parent.uOffset = first.uOffset) &&
        decide (lane.parent.uLen = first.uLen) &&
        decide (lane.parent.foldDigest = first.foldDigest) &&
        decide (lane.parent.auxOpenings = (mixAuxOpeningsRLC lane.rhoCoeffs inputs).map fun x => { c0 := x.re.val, c1 := x.im.val }) &&
        decide (lane.parent.yZcol =
          (mixYZcolRLC lane.rhoCoeffs inputs).map fun x => { c0 := x.re.val, c1 := x.im.val }) &&
        (List.range first.yRing.size).all fun j =>
          let want := mixYRowsRLCIdx lane.rhoCoeffs inputs j
          decide (toKArray lane.parent.yRing[j]! = want) &&
            decide (lane.parent.ct[j]! = lane.parent.yRing[j]![0]!)

/--
Public Rust-artifact `Π_RLC` parent check.

This is the implementation-level lane-parent acceptance predicate used by the
`neo-fold` artifact validator. It is exported so the Rust-refinement layer can
prove that the stronger implementation statement conservatively refines the
paper-core lane relation after erasing implementation sidecars.
-/
def implRlcParentChecks (lane : NeoFoldLaneCase) : Bool :=
  rlcParentChecks lane.ccs lane

/--
Implementation-level `Π_RLC` core parent check with Rust-only sidecar equalities removed.

This stays in the Rust artifact-validation layer. It is used by the refinement
layer to state that the richer implementation check is a conservative
extension of the paper-core parent relation.
-/
def implRlcParentCoreChecks (lane : NeoFoldLaneCase) : Bool :=
  let inputs := lane.inputs
  match inputs[0]? with
  | none => false
  | some first =>
      claimBasicShapeChecks lane.ccs first &&
        claimCtConstantTermChecks first &&
        meBatchInvariantChecks inputs &&
        decide (lane.rhoCount = inputs.size) &&
        rhoCoeffShapeChecks lane &&
        inputs.all (claimBasicShapeChecks lane.ccs) &&
        inputs.all claimCtConstantTermChecks &&
        claimCtConstantTermChecks lane.parent &&
        inputs.all fun inst =>
          decide (inst.auxOpenings.size = first.auxOpenings.size) &&
        decide (lane.parent.commitment = mixCommitmentsRLC lane.rhoCoeffs inputs) &&
        decide (lane.parent.x = (mixXColumnsRLC lane.rhoCoeffs inputs).map (fun row => row.map fun x => x.val)) &&
        decide (lane.parent.r = first.r) &&
        decide (lane.parent.sCol = first.sCol) &&
        decide (lane.parent.mIn = first.mIn) &&
        decide (lane.parent.auxOpenings = (mixAuxOpeningsRLC lane.rhoCoeffs inputs).map fun x => { c0 := x.re.val, c1 := x.im.val }) &&
        decide (lane.parent.yZcol =
          (mixYZcolRLC lane.rhoCoeffs inputs).map fun x => { c0 := x.re.val, c1 := x.im.val }) &&
        (List.range first.yRing.size).all fun j =>
          let want := mixYRowsRLCIdx lane.rhoCoeffs inputs j
          decide (toKArray lane.parent.yRing[j]! = want) &&
            decide (lane.parent.ct[j]! = lane.parent.yRing[j]![0]!)

/--
The full Rust `Π_RLC` parent check is a conservative extension of the core
parent relation obtained by erasing Rust-only sidecar equalities.
-/
theorem implRlcParentChecks_implies_core
    (lane : NeoFoldLaneCase) :
    implRlcParentChecks lane = true →
      implRlcParentCoreChecks lane = true := by
  intro hAccept
  cases lane with
  | mk ccs foldBase inputs rhoCount rhoCoeffs parent children =>
      cases hHead : inputs[0]? with
      | none =>
          simp [implRlcParentChecks, rlcParentChecks, implRlcParentCoreChecks, hHead] at hAccept
      | some first =>
          simp [implRlcParentChecks, rlcParentChecks, implRlcParentCoreChecks, hHead] at hAccept ⊢
          rcases hAccept with ⟨hOuter, hInputs⟩
          rcases hOuter with ⟨hOuter, hParentCt⟩
          rcases hOuter with ⟨hOuter, hInputsCt⟩
          rcases hOuter with ⟨hOuter, hInputsShape⟩
          rcases hOuter with ⟨hOuter, hRhoShape⟩
          rcases hOuter with ⟨hOuter, hSize⟩
          rcases hOuter with ⟨hOuter, hBatch⟩
          rcases hOuter with ⟨hFirstShape, hFirstCt⟩
          refine ⟨?_, ?_⟩
          · repeat' constructor
            · exact hFirstShape
            · exact hFirstCt
            · exact hBatch
            · exact hSize
            · exact hRhoShape
            · exact hInputsShape
            · exact hInputsCt
            · exact hParentCt
          · intro i hi
            have hInput := hInputs i hi
            rcases hInput with ⟨hInputOuter, hRows⟩
            rcases hInputOuter with ⟨hInputOuter, hYZ⟩
            rcases hInputOuter with ⟨hInputOuter, hAux⟩
            rcases hInputOuter with ⟨hInputOuter, _hDigest⟩
            rcases hInputOuter with ⟨hInputOuter, _hLen⟩
            rcases hInputOuter with ⟨hInputOuter, _hOffset⟩
            rcases hInputOuter with ⟨hInputOuter, _hCoords⟩
            rcases hInputOuter with ⟨hInputOuter, hMIn⟩
            rcases hInputOuter with ⟨hInputOuter, hSCol⟩
            rcases hInputOuter with ⟨hInputOuter, hR⟩
            rcases hInputOuter with ⟨hInputOuter, hXCols⟩
            rcases hInputOuter with ⟨hAuxSize, hCommitment⟩
            repeat' constructor
            · exact hAuxSize
            · exact hCommitment
            · exact hXCols
            · exact hR
            · exact hSCol
            · exact hMIn
            · exact hAux
            · exact hYZ
            · exact hRows

/--
Normalize implementation-only sidecars throughout one Rust-exported folding
lane.

This is used to state that the Rust parent checks are conservative with respect
to the paper-core lane obtained by erasing sidecars.
-/
def normalizeLaneSidecars (lane : NeoFoldLaneCase) : NeoFoldLaneCase :=
  { lane with
    inputs := lane.inputs.map normalizeClaimSidecars
    parent := normalizeClaimSidecars lane.parent
    children := lane.children.map normalizeClaimSidecars }

/--
Normalize implementation-only claim sidecars throughout one Rust-exported step.

This is a Rust-validation helper only. It erases claim sidecars recursively
through the step-local claims and lanes, without changing any paper-semantic
module.
-/
def normalizeStepSidecars (step : NeoFoldStepArtifactCase) : NeoFoldStepArtifactCase :=
  { step with
    ccsOut := step.ccsOut.map normalizeClaimSidecars
    mainLane := normalizeLaneSidecars step.mainLane
    valInputs := step.valInputs.map normalizeClaimSidecars
    valLanes := step.valLanes.map normalizeLaneSidecars
    wbInputs := step.wbInputs.map normalizeClaimSidecars
    wbLanes := step.wbLanes.map normalizeLaneSidecars
    wpInputs := step.wpInputs.map normalizeClaimSidecars
    wpLanes := step.wpLanes.map normalizeLaneSidecars
    stage8Lanes := step.stage8Lanes.map normalizeLaneSidecars }

/--
Normalize implementation-only claim sidecars throughout one Rust-exported
`neo-fold` artifact.

This is a Rust-validation helper only. It erases claim sidecars recursively
through the accumulator claims and the exported proof steps.
-/
def normalizeArtifactSidecars (artifact : NeoFoldArtifactCase) : NeoFoldArtifactCase :=
  { artifact with
    accInitMain := artifact.accInitMain.map normalizeClaimSidecars
    finalMain := artifact.finalMain.map normalizeClaimSidecars
    finalVal := artifact.finalVal.map normalizeClaimSidecars
    steps := artifact.steps.map normalizeStepSidecars }

@[simp] theorem rhoCoeffShapeChecks_normalizeLaneSidecars
    (lane : NeoFoldLaneCase) :
    rhoCoeffShapeChecks (normalizeLaneSidecars lane) =
      rhoCoeffShapeChecks lane := by
  cases lane
  simp [rhoCoeffShapeChecks, normalizeLaneSidecars]

@[simp] theorem rhoCoeffShapeChecks_normalized_components
    (ccs : NeoFoldCcsCase)
    (foldBase : Nat)
    (inputs : Array NeoFoldClaimCase)
    (rhoCount : Nat)
    (rhoCoeffs : Array (Array Nat))
    (parent : NeoFoldClaimCase)
    (children : Array NeoFoldClaimCase) :
    rhoCoeffShapeChecks
      { ccs := ccs
        foldBase := foldBase
        inputs := inputs.map normalizeClaimSidecars
        rhoCount := rhoCount
        rhoCoeffs := rhoCoeffs
        parent := normalizeClaimSidecars parent
        children := children.map normalizeClaimSidecars } =
    rhoCoeffShapeChecks
      { ccs := ccs
        foldBase := foldBase
        inputs := inputs
        rhoCount := rhoCount
        rhoCoeffs := rhoCoeffs
        parent := parent
        children := children } := by
  simp [rhoCoeffShapeChecks]

@[simp] theorem implRlcParentCoreChecks_normalizeLaneSidecars
    (lane : NeoFoldLaneCase) :
    implRlcParentCoreChecks (normalizeLaneSidecars lane) =
      implRlcParentCoreChecks lane := by
  cases lane with
  | mk ccs foldBase inputs rhoCount rhoCoeffs parent children =>
      cases hHead : inputs[0]? <;>
        simp [normalizeLaneSidecars, implRlcParentCoreChecks, hHead]

@[simp] theorem implRlcParentChecks_normalizeLaneSidecars
    (lane : NeoFoldLaneCase) :
    implRlcParentChecks (normalizeLaneSidecars lane) =
      implRlcParentCoreChecks lane := by
  cases lane with
  | mk ccs foldBase inputs rhoCount rhoCoeffs parent children =>
      cases hHead : inputs[0]? <;>
        simp [normalizeLaneSidecars, implRlcParentChecks, rlcParentChecks,
          implRlcParentCoreChecks, hHead]

private def fPow (x : F) (n : Nat) : F := Id.run do
  let mut acc : F := 1
  let mut i := 0
  while i < n do
    acc := acc * x
    i := i + 1
  return acc

private def kPow (x : KExt) (n : Nat) : KExt := Id.run do
  let mut acc : KExt := 1
  let mut i := 0
  while i < n do
    acc := acc * x
    i := i + 1
  return acc

private def decCtChecks (b : Nat) (children : Array NeoFoldClaimCase) (parent : NeoFoldClaimCase) : Bool :=
  let bK := KExt.ofF (toF b)
  (List.range parent.ct.size).all fun idx =>
    let want :=
      (List.range children.size).foldl
        (fun acc childIdx =>
          acc + kPow bK childIdx * KExt.ofKNat ((children[childIdx]!.ct)[idx]!))
        0
    decide (KExt.ofKNat (parent.ct[idx]!) = want)

private def decCommitmentChecks (b : Nat) (children : Array NeoFoldClaimCase) (parent : NeoFoldClaimCase) : Bool :=
  let kappa := parent.commitment.cols.size
  children.all (fun c => decide (c.commitment.cols.size = kappa)) &&
    (List.range kappa).all fun col =>
      let want :=
        (List.range children.size).foldl
          (fun acc idx =>
            vecAdd acc (vecScale (toF (b ^ idx)) (takeDFieldCoeffs (children[idx]!.commitment.cols[col]!))))
          (Array.replicate D 0)
      decide (parent.commitment.cols[col]! = want.map fun x => x.val)

private def decXChecks (b : Nat) (children : Array NeoFoldClaimCase) (parent : NeoFoldClaimCase) : Bool :=
  match children[0]? with
  | none => false
  | some first =>
      (List.range D).all fun rho =>
        (List.range first.mIn).all fun col =>
          let want :=
            (List.range children.size).foldl
              (fun acc idx => acc + toF (b ^ idx) * toF ((children[idx]!.x)[rho]![col]!))
              0
          decide (toF (parent.x[rho]![col]!) = want)

private def decYChecks (b : Nat) (children : Array NeoFoldClaimCase) (parent : NeoFoldClaimCase) : Bool :=
  match children[0]? with
  | none => false
  | some first =>
      let bK := KExt.ofF (toF b)
      (List.range first.yRing.size).all fun j =>
        let rowLen := (first.yRing[j]!).size
        (List.range rowLen).all fun idx =>
          let want :=
            (List.range children.size).foldl
              (fun acc childIdx =>
                acc + kPow bK childIdx * KExt.ofKNat ((children[childIdx]!.yRing[j]!)[idx]!))
              0
          decide (KExt.ofKNat ((parent.yRing[j]!)[idx]!) = want)

private def decAuxChecks (b : Nat) (children : Array NeoFoldClaimCase) (parent : NeoFoldClaimCase) : Bool :=
  let bK := KExt.ofF (toF b)
  (List.range parent.auxOpenings.size).all fun idx =>
    let want :=
      (List.range children.size).foldl
        (fun acc childIdx =>
          acc + kPow bK childIdx * KExt.ofKNat ((children[childIdx]!.auxOpenings)[idx]!))
        0
    decide (KExt.ofKNat (parent.auxOpenings[idx]!) = want)

private def decYZcolChecks (b : Nat) (children : Array NeoFoldClaimCase) (parent : NeoFoldClaimCase) : Bool :=
  if parent.yZcol.isEmpty then
    children.all (fun child => child.yZcol.isEmpty)
  else
    children.all fun child =>
      decide (child.sCol = parent.sCol) &&
        decide (child.yZcol.size = parent.yZcol.size)

@[simp] theorem decCtChecks_map_normalizeClaimSidecars
    (b : Nat)
    (children : Array NeoFoldClaimCase)
    (parent : NeoFoldClaimCase) :
    decCtChecks b (children.map normalizeClaimSidecars) (normalizeClaimSidecars parent) =
      decCtChecks b children parent := by
  simp [decCtChecks]

@[simp] theorem decCommitmentChecks_map_normalizeClaimSidecars
    (b : Nat)
    (children : Array NeoFoldClaimCase)
    (parent : NeoFoldClaimCase) :
    decCommitmentChecks b (children.map normalizeClaimSidecars) (normalizeClaimSidecars parent) =
      decCommitmentChecks b children parent := by
  simp [decCommitmentChecks, takeDFieldCoeffs]

@[simp] theorem decXChecks_map_normalizeClaimSidecars
    (b : Nat)
    (children : Array NeoFoldClaimCase)
    (parent : NeoFoldClaimCase) :
    decXChecks b (children.map normalizeClaimSidecars) (normalizeClaimSidecars parent) =
      decXChecks b children parent := by
  cases hHead : children[0]? <;> simp [decXChecks, hHead]

@[simp] theorem decYChecks_map_normalizeClaimSidecars
    (b : Nat)
    (children : Array NeoFoldClaimCase)
    (parent : NeoFoldClaimCase) :
    decYChecks b (children.map normalizeClaimSidecars) (normalizeClaimSidecars parent) =
      decYChecks b children parent := by
  cases hHead : children[0]? <;> simp [decYChecks, hHead]

@[simp] theorem decAuxChecks_map_normalizeClaimSidecars
    (b : Nat)
    (children : Array NeoFoldClaimCase)
    (parent : NeoFoldClaimCase) :
    decAuxChecks b (children.map normalizeClaimSidecars) (normalizeClaimSidecars parent) =
      decAuxChecks b children parent := by
  simp [decAuxChecks]

@[simp] theorem decYZcolChecks_map_normalizeClaimSidecars
    (b : Nat)
    (children : Array NeoFoldClaimCase)
    (parent : NeoFoldClaimCase) :
    decYZcolChecks b (children.map normalizeClaimSidecars) (normalizeClaimSidecars parent) =
      decYZcolChecks b children parent := by
  by_cases hEmpty : parent.yZcol.isEmpty
  · simp [decYZcolChecks, hEmpty]
  · simp [decYZcolChecks, hEmpty]

private def decParentChecks (ccs : NeoFoldCcsCase) (b kRho : Nat) (lane : NeoFoldLaneCase) : Bool :=
  let children := lane.children
  match children[0]? with
  | none => false
  | some first =>
      children.all (claimBasicShapeChecks ccs) &&
        children.all claimCtConstantTermChecks &&
        meBatchInvariantChecks children &&
        claimBasicShapeChecks ccs lane.parent &&
        claimCtConstantTermChecks lane.parent &&
        decide (children.size ≥ requiredDecChildrenMin kRho b lane.inputs.size) &&
        decide (lane.parent.r = first.r) &&
        decide (lane.parent.mIn = first.mIn) &&
        children.all fun child =>
          decide (child.foldDigest = lane.parent.foldDigest) &&
          decide (child.yRing.size = lane.parent.yRing.size) &&
            decide (child.ct.size = lane.parent.ct.size) &&
            decide (child.auxOpenings.size = lane.parent.auxOpenings.size) &&
        decCommitmentChecks b children lane.parent &&
        decXChecks b children lane.parent &&
        decYChecks b children lane.parent &&
        decCtChecks b children lane.parent &&
        decAuxChecks b children lane.parent &&
        decYZcolChecks b children lane.parent &&
        (List.range lane.parent.ct.size).all fun idx =>
          decide (lane.parent.ct[idx]! = lane.parent.yRing[idx]![0]!)

/--
Public Rust-artifact `Π_DEC` parent check.

This is the implementation-level decomposition-parent acceptance predicate used
by the `neo-fold` artifact validator. It is exported so the Rust-refinement
layer can prove that the stronger implementation statement conservatively
refines the paper-core lane relation after erasing implementation sidecars.
-/
def implDecParentChecks (kRho : Nat) (lane : NeoFoldLaneCase) : Bool :=
  decParentChecks lane.ccs lane.foldBase kRho lane

/--
Implementation-level `Π_DEC` core parent check with Rust-only sidecar digest
equality removed.

This stays in the Rust artifact-validation layer and isolates the paper-core
part of the decomposition parent relation.
-/
def implDecParentCoreChecks (kRho : Nat) (lane : NeoFoldLaneCase) : Bool :=
  let children := lane.children
  match children[0]? with
  | none => false
  | some first =>
      children.all (claimBasicShapeChecks lane.ccs) &&
        children.all claimCtConstantTermChecks &&
        meBatchInvariantChecks children &&
        claimBasicShapeChecks lane.ccs lane.parent &&
        claimCtConstantTermChecks lane.parent &&
        decide (children.size ≥ requiredDecChildrenMin kRho lane.foldBase lane.inputs.size) &&
        decide (lane.parent.r = first.r) &&
        decide (lane.parent.mIn = first.mIn) &&
        children.all fun child =>
          decide (child.yRing.size = lane.parent.yRing.size) &&
            decide (child.ct.size = lane.parent.ct.size) &&
            decide (child.auxOpenings.size = lane.parent.auxOpenings.size) &&
        decCommitmentChecks lane.foldBase children lane.parent &&
        decXChecks lane.foldBase children lane.parent &&
        decYChecks lane.foldBase children lane.parent &&
        decCtChecks lane.foldBase children lane.parent &&
        decAuxChecks lane.foldBase children lane.parent &&
        decYZcolChecks lane.foldBase children lane.parent &&
        (List.range lane.parent.ct.size).all fun idx =>
          decide (lane.parent.ct[idx]! = lane.parent.yRing[idx]![0]!)

@[simp] theorem implDecParentCoreChecks_normalizeLaneSidecars
    (kRho : Nat)
    (lane : NeoFoldLaneCase) :
    implDecParentCoreChecks kRho (normalizeLaneSidecars lane) =
      implDecParentCoreChecks kRho lane := by
  cases lane with
  | mk ccs foldBase inputs rhoCount rhoCoeffs parent children =>
      cases hHead : children[0]? <;>
        simp [normalizeLaneSidecars, implDecParentCoreChecks, hHead]

@[simp] theorem implDecParentChecks_normalizeLaneSidecars
    (kRho : Nat)
    (lane : NeoFoldLaneCase) :
    implDecParentChecks kRho (normalizeLaneSidecars lane) =
      implDecParentCoreChecks kRho lane := by
  cases lane with
  | mk ccs foldBase inputs rhoCount rhoCoeffs parent children =>
      cases hHead : children[0]? <;>
        simp [normalizeLaneSidecars, implDecParentChecks, decParentChecks,
          implDecParentCoreChecks, hHead]

/--
The full Rust `Π_DEC` parent check is a conservative extension of the core
parent relation obtained by erasing Rust-only sidecar digest equality.
-/
theorem implDecParentChecks_implies_core
    (kRho : Nat)
    (lane : NeoFoldLaneCase) :
    implDecParentChecks kRho lane = true →
      implDecParentCoreChecks kRho lane = true := by
  intro hAccept
  cases lane with
  | mk ccs foldBase inputs rhoCount rhoCoeffs parent children =>
      cases hHead : children[0]? with
      | none =>
          simp [implDecParentChecks, decParentChecks, implDecParentCoreChecks, hHead] at hAccept
      | some first =>
          simp [implDecParentChecks, decParentChecks, implDecParentCoreChecks, hHead] at hAccept ⊢
          rcases hAccept with ⟨hOuter, hChildren⟩
          rcases hOuter with ⟨hOuter, hMIn⟩
          rcases hOuter with ⟨hOuter, hR⟩
          rcases hOuter with ⟨hOuter, hChildBound⟩
          rcases hOuter with ⟨hOuter, hParentCt⟩
          rcases hOuter with ⟨hOuter, hParentShape⟩
          rcases hOuter with ⟨hOuter, hBatch⟩
          rcases hOuter with ⟨hChildrenShape, hChildrenCt⟩
          refine ⟨?_, ?_⟩
          · repeat' constructor
            · exact hChildrenShape
            · exact hChildrenCt
            · exact hBatch
            · exact hParentShape
            · exact hParentCt
            · exact hChildBound
            · exact hR
            · exact hMIn
          · intro i hi
            have hChild := hChildren i hi
            rcases hChild with ⟨hChildOuter, hCtHead⟩
            rcases hChildOuter with ⟨hChildOuter, hYZ⟩
            rcases hChildOuter with ⟨hChildOuter, hAux⟩
            rcases hChildOuter with ⟨hChildOuter, hCtRows⟩
            rcases hChildOuter with ⟨hChildOuter, hYRows⟩
            rcases hChildOuter with ⟨hChildOuter, hXCols⟩
            rcases hChildOuter with ⟨hChildOuter, hCommitment⟩
            rcases hChildOuter with ⟨hChildOuter, hAuxSize⟩
            rcases hChildOuter with ⟨hChildOuter, hCtSize⟩
            rcases hChildOuter with ⟨_hDigest, hYSize⟩
            repeat' constructor
            · exact hYSize
            · exact hCtSize
            · exact hAuxSize
            · exact hCommitment
            · exact hXCols
            · exact hYRows
            · exact hCtRows
            · exact hAux
            · exact hYZ
            · exact hCtHead

private def laneChecks (kRho : Nat) (lane : NeoFoldLaneCase) : Bool :=
  !lane.inputs.isEmpty &&
    !lane.children.isEmpty &&
    rlcParentChecks lane.ccs lane &&
    decParentChecks lane.ccs lane.foldBase kRho lane

/--
Public Rust-artifact folding-lane check.

This is the implementation-level lane acceptance predicate used by the
Rust-refinement layer. It keeps the validator-owned notion of a well-formed
lane in the artifact module, without changing any paper-semantic module.
-/
def implFoldLaneChecks (kRho : Nat) (lane : NeoFoldLaneCase) : Bool :=
  laneChecks kRho lane

/--
If the public Rust folding-lane check accepts, then the embedded implementation
`Π_RLC` parent check also accepts.
-/
theorem implFoldLaneChecks_implies_rlcParentChecks
    (kRho : Nat)
    (lane : NeoFoldLaneCase) :
    implFoldLaneChecks kRho lane = true →
      implRlcParentChecks lane = true := by
  intro hAccept
  have hConj :
      ((¬lane.inputs = #[] ∧ ¬lane.children = #[]) ∧ rlcParentChecks lane.ccs lane = true) ∧
        decParentChecks lane.ccs lane.foldBase kRho lane = true := by
    simpa [implFoldLaneChecks, laneChecks, implRlcParentChecks] using hAccept
  exact hConj.1.2

/--
If the public Rust folding-lane check accepts, then the embedded implementation
`Π_DEC` parent check also accepts.
-/
theorem implFoldLaneChecks_implies_decParentChecks
    (kRho : Nat)
    (lane : NeoFoldLaneCase) :
    implFoldLaneChecks kRho lane = true →
      implDecParentChecks kRho lane = true := by
  intro hAccept
  have hConj :
      ((¬lane.inputs = #[] ∧ ¬lane.children = #[]) ∧ rlcParentChecks lane.ccs lane = true) ∧
        decParentChecks lane.ccs lane.foldBase kRho lane = true := by
    simpa [implFoldLaneChecks, laneChecks, implDecParentChecks] using hAccept
  exact hConj.2

/--
The public Rust folding-lane check is conservative with respect to sidecar
erasure on the same lane.
-/
theorem implFoldLaneChecks_refines_normalizeLaneSidecars
    (kRho : Nat)
    (lane : NeoFoldLaneCase) :
    implFoldLaneChecks kRho lane = true →
      implFoldLaneChecks kRho (normalizeLaneSidecars lane) = true := by
  intro hAccept
  have hConj :
      ((¬lane.inputs = #[] ∧ ¬lane.children = #[]) ∧ implRlcParentChecks lane = true) ∧
        implDecParentChecks kRho lane = true := by
    simpa [implFoldLaneChecks, laneChecks, implRlcParentChecks, implDecParentChecks] using hAccept
  have hRlcCore := implRlcParentChecks_implies_core lane hConj.1.2
  have hDecCore := implDecParentChecks_implies_core kRho lane hConj.2
  have hNorm :
      ((¬(normalizeLaneSidecars lane).inputs = #[] ∧ ¬(normalizeLaneSidecars lane).children = #[]) ∧
          implRlcParentChecks (normalizeLaneSidecars lane) = true) ∧
        implDecParentChecks kRho (normalizeLaneSidecars lane) = true := by
    constructor
    · constructor
      · constructor
        · simpa [normalizeLaneSidecars] using hConj.1.1.1
        · simpa [normalizeLaneSidecars] using hConj.1.1.2
      · simpa [implRlcParentChecks_normalizeLaneSidecars] using hRlcCore
    · simpa [implDecParentChecks_normalizeLaneSidecars] using hDecCore
  simpa [implFoldLaneChecks, laneChecks, implRlcParentChecks, implDecParentChecks] using hNorm

private def mainLaneChecks (kRho : Nat) (isTerminal : Bool) (step : NeoFoldStepArtifactCase) : Bool :=
  let lane := step.mainLane
  !lane.inputs.isEmpty &&
    mainLaneInputWitnessChecks step &&
    rlcParentChecks lane.ccs lane &&
    mainLaneParentWitnessChecks step &&
    mainLaneRlcWitnessChecks step &&
    if isTerminal && lane.children.isEmpty then
      mainLaneChildWitnessChecks true step &&
        mainLaneDecWitnessChecks true step
    else
      !lane.children.isEmpty &&
        decParentChecks lane.ccs lane.foldBase kRho lane &&
        mainLaneChildWitnessChecks false step &&
          mainLaneDecWitnessChecks false step

structure NeoFoldRlcParentBreakdown where
  firstShape : Bool
  firstCtConstant : Bool
  batchInvariants : Bool
  rhoCount : Bool
  rhoCoeffShape : Bool
  inputsShape : Bool
  inputsCtConstant : Bool
  sharedAuxLen : Bool
  parentCtConstant : Bool
  commitment : Bool
  xCols : Bool
  rShared : Bool
  sColShared : Bool
  mInShared : Bool
  cStepCoordsShared : Bool
  uOffsetShared : Bool
  uLenShared : Bool
  foldDigestShared : Bool
  auxOpenings : Bool
  yZcol : Bool
  yRows : Bool
deriving Repr, Inhabited

private def rlcParentBreakdown (ccs : NeoFoldCcsCase) (lane : NeoFoldLaneCase) :
    NeoFoldRlcParentBreakdown :=
  let inputs := lane.inputs
  match inputs[0]? with
  | none =>
      { firstShape := false
        firstCtConstant := false
        batchInvariants := false
        rhoCount := false
        rhoCoeffShape := false
        inputsShape := false
        inputsCtConstant := false
        sharedAuxLen := false
        parentCtConstant := false
        commitment := false
        xCols := false
        rShared := false
        sColShared := false
        mInShared := false
        cStepCoordsShared := false
        uOffsetShared := false
        uLenShared := false
        foldDigestShared := false
        auxOpenings := false
        yZcol := false
        yRows := false }
  | some first =>
      { firstShape := claimBasicShapeChecks ccs first
        firstCtConstant := claimCtConstantTermChecks first
        batchInvariants := meBatchInvariantChecks inputs
        rhoCount := decide (lane.rhoCount = inputs.size)
        rhoCoeffShape := rhoCoeffShapeChecks lane
        inputsShape := inputs.all (claimBasicShapeChecks ccs)
        inputsCtConstant := inputs.all claimCtConstantTermChecks
        sharedAuxLen := inputs.all fun inst => decide (inst.auxOpenings.size = first.auxOpenings.size)
        parentCtConstant := claimCtConstantTermChecks lane.parent
        commitment := decide (lane.parent.commitment = mixCommitmentsRLC lane.rhoCoeffs inputs)
        xCols := decide (lane.parent.x = (mixXColumnsRLC lane.rhoCoeffs inputs).map (fun row => row.map fun x => x.val))
        rShared := decide (lane.parent.r = first.r)
        sColShared := decide (lane.parent.sCol = first.sCol)
        mInShared := decide (lane.parent.mIn = first.mIn)
        cStepCoordsShared := decide (lane.parent.cStepCoords = first.cStepCoords)
        uOffsetShared := decide (lane.parent.uOffset = first.uOffset)
        uLenShared := decide (lane.parent.uLen = first.uLen)
        foldDigestShared := decide (lane.parent.foldDigest = first.foldDigest)
        auxOpenings := decide
          (lane.parent.auxOpenings =
            (mixAuxOpeningsRLC lane.rhoCoeffs inputs).map fun x => { c0 := x.re.val, c1 := x.im.val })
        yZcol := decide
          (lane.parent.yZcol =
            (mixYZcolRLC lane.rhoCoeffs inputs).map fun x => { c0 := x.re.val, c1 := x.im.val })
        yRows := (List.range first.yRing.size).all fun j =>
          let want := mixYRowsRLCIdx lane.rhoCoeffs inputs j
          decide (toKArray lane.parent.yRing[j]! = want) &&
            decide (lane.parent.ct[j]! = lane.parent.yRing[j]![0]!) }

structure NeoFoldDecParentBreakdown where
  childrenShape : Bool
  childrenCtConstant : Bool
  childBatchInvariants : Bool
  parentShape : Bool
  parentCtConstant : Bool
  childCountLowerBound : Bool
  rShared : Bool
  mInShared : Bool
  childYRingLens : Bool
  childCtLens : Bool
  childAuxLens : Bool
  commitment : Bool
  xCols : Bool
  yRows : Bool
  auxOpenings : Bool
  yZcol : Bool
  ctRows : Bool
deriving Repr, Inhabited

private def decParentBreakdown (ccs : NeoFoldCcsCase) (b kRho : Nat) (lane : NeoFoldLaneCase) :
    NeoFoldDecParentBreakdown :=
  let children := lane.children
  match children[0]? with
  | none =>
      { childrenShape := false
        childrenCtConstant := false
        childBatchInvariants := false
        parentShape := false
        parentCtConstant := false
        childCountLowerBound := false
        rShared := false
        mInShared := false
        childYRingLens := false
        childCtLens := false
        childAuxLens := false
        commitment := false
        xCols := false
        yRows := false
        auxOpenings := false
        yZcol := false
        ctRows := false }
  | some first =>
      { childrenShape := children.all (claimBasicShapeChecks ccs)
        childrenCtConstant := children.all claimCtConstantTermChecks
        childBatchInvariants := meBatchInvariantChecks children
        parentShape := claimBasicShapeChecks ccs lane.parent
        parentCtConstant := claimCtConstantTermChecks lane.parent
        childCountLowerBound := decide (children.size ≥ requiredDecChildrenMin kRho b lane.inputs.size)
        rShared := decide (lane.parent.r = first.r)
        mInShared := decide (lane.parent.mIn = first.mIn)
        childYRingLens := children.all fun child =>
          decide (child.yRing.size = lane.parent.yRing.size)
        childCtLens := children.all fun child =>
          decide (child.ct.size = lane.parent.ct.size)
        childAuxLens := children.all fun child =>
          decide (child.auxOpenings.size = lane.parent.auxOpenings.size)
        commitment := decCommitmentChecks b children lane.parent
        xCols := decXChecks b children lane.parent
        yRows := decYChecks b children lane.parent
        auxOpenings := decAuxChecks b children lane.parent
        yZcol := decYZcolChecks b children lane.parent
        ctRows := decCtChecks b children lane.parent &&
          (List.range lane.parent.ct.size).all fun idx =>
            decide (lane.parent.ct[idx]! = lane.parent.yRing[idx]![0]!) }

structure NeoFoldLaneCheckBreakdown where
  inputsNonempty : Bool
  childrenNonempty : Bool
  rlcParent : Bool
  decParent : Bool
  rlcDetail : NeoFoldRlcParentBreakdown
  decDetail : NeoFoldDecParentBreakdown
deriving Repr, Inhabited

private def laneCheckBreakdown
    (kRho : Nat)
    (lane : NeoFoldLaneCase) : NeoFoldLaneCheckBreakdown :=
  { inputsNonempty := !lane.inputs.isEmpty
    childrenNonempty := !lane.children.isEmpty
    rlcParent := rlcParentChecks lane.ccs lane
    decParent := decParentChecks lane.ccs lane.foldBase kRho lane
    rlcDetail := rlcParentBreakdown lane.ccs lane
    decDetail := decParentBreakdown lane.ccs lane.foldBase kRho lane }

private def laneArrayChecks
    (kRho : Nat)
    (inputs : Array NeoFoldClaimCase)
    (lanes : Array NeoFoldLaneCase)
    (expectSingletonInputs : Bool) : Bool :=
  decide (inputs.size = lanes.size) &&
    (List.range lanes.size).all fun idx =>
      let lane := lanes[idx]!
      laneChecks kRho lane &&
        (if expectSingletonInputs then
          decide (lane.inputs.size = 1) &&
            decide (lane.inputs[0]! = inputs[idx]!)
        else
          true)

private def ccsOutChecks (artifact : NeoFoldArtifactCase) (step : NeoFoldStepArtifactCase) : Bool :=
  let currentCount := step.mcsBatchCommitments.size
  decide (step.ccsOut.size = step.mainLane.inputs.size) &&
    decide (step.ccsOut = step.mainLane.inputs) &&
    currentBatchSizeChecks step &&
    !step.ccsOut.isEmpty &&
    decide (currentCount > 0) &&
    step.ccsOut.all (claimBasicShapeChecks artifact.ccs) &&
    step.ccsOut.all claimCtConstantTermChecks &&
    meBatchInvariantChecks step.ccsOut &&
    step.ccsOut.all (fun claim =>
      decide (claim.r.size ≤ step.piCcs.challenges.size) &&
        decide (claim.r = step.piCcs.challenges.take claim.r.size)) &&
    checkCurrentStepCE artifact.ccs artifact.foldBase step &&
    (List.range step.ccsOut.size).all fun idx =>
      if idx < currentCount then
        true
      else
        let claim := step.ccsOut[idx]!
        let inp := step.mainLane.inputs[idx]!
        decide (claim.commitment = inp.commitment) &&
          decide (claim.mIn = inp.mIn) &&
          decide (claim.x = inp.x)

structure NeoFoldCcsOutCheckBreakdown where
  sizeEq : Bool
  inputsEq : Bool
  batchSizeAligned : Bool
  nonempty : Bool
  allShapes : Bool
  allCtConstant : Bool
  batchInvariants : Bool
  firstShapeDetail : NeoFoldClaimShapeBreakdown
  allRPrefixes : Bool
  currentCE : Bool
  carriedClaims : Bool
  currentCEDetail : NeoFoldCurrentStepCEBreakdown
deriving Repr, Inhabited

private def ccsOutCheckBreakdown
    (artifact : NeoFoldArtifactCase)
    (step : NeoFoldStepArtifactCase) : NeoFoldCcsOutCheckBreakdown :=
  match step.ccsOut[0]? with
  | none =>
      { sizeEq := decide (step.ccsOut.size = step.mainLane.inputs.size)
        inputsEq := decide (step.ccsOut = step.mainLane.inputs)
        batchSizeAligned := currentBatchSizeChecks step
        nonempty := false
        allShapes := false
        allCtConstant := false
        batchInvariants := false
        firstShapeDetail := {
          commitmentShape := false
          xShape := false
          mInBound := false
          rSize := false
          yRingSize := false
          ctSize := false
          yRowsOk := false
          sColYZcolOk := false }
        allRPrefixes := false
        currentCE := false
        carriedClaims := false
        currentCEDetail := {
          batchSizeAligned := currentBatchSizeChecks step
          witnessShape := false
          claimShape := false
          ccsZero := false
          projectedX := false
          commitment := false
          yRows := false
          yZcol := false } }
  | some first =>
      let currentCount := step.mcsBatchCommitments.size
      { sizeEq := decide (step.ccsOut.size = step.mainLane.inputs.size)
        inputsEq := decide (step.ccsOut = step.mainLane.inputs)
        batchSizeAligned := currentBatchSizeChecks step
        nonempty := !step.ccsOut.isEmpty && decide (currentCount > 0)
        allShapes := step.ccsOut.all (claimBasicShapeChecks artifact.ccs)
        allCtConstant := step.ccsOut.all claimCtConstantTermChecks
        batchInvariants := meBatchInvariantChecks step.ccsOut
        firstShapeDetail := claimShapeBreakdown artifact.ccs first
        allRPrefixes := step.ccsOut.all fun claim =>
          decide (claim.r.size ≤ step.piCcs.challenges.size) &&
            decide (claim.r = step.piCcs.challenges.take claim.r.size)
        currentCE := checkCurrentStepCE artifact.ccs artifact.foldBase step
        carriedClaims := (List.range step.ccsOut.size).all fun idx =>
          if idx < currentCount then
            true
          else
            let claim := step.ccsOut[idx]!
            let inp := step.mainLane.inputs[idx]!
            decide (claim.commitment = inp.commitment) &&
              decide (claim.mIn = inp.mIn) &&
              decide (claim.x = inp.x)
        currentCEDetail := currentStepCEBreakdown artifact.ccs artifact.foldBase step }

private def cpuMetadataChecks (step : NeoFoldStepArtifactCase) : Bool :=
  match step.ccsOut[0]? with
  | none => false
  | some rowPoint =>
      if step.cpuSumcheck.roundPolys.isEmpty then
        decide (step.cpuSumcheck.claimedSum = { c0 := 0, c1 := 0 }) &&
          decide (step.cpuSumcheck.challenges = #[])
      else
        decide (step.cpuSumcheck.claimedSum = step.piCcs.claimedSum) &&
          decide (step.cpuSumcheck.roundPolys = step.piCcs.roundPolys.take step.cpuSumcheck.roundPolys.size) &&
          decide (step.cpuSumcheck.challenges = rowPoint.r) &&
          decide (step.cpuSumcheck.roundPolys.size = rowPoint.r.size)

private def shiftMetadataChecks (step : NeoFoldStepArtifactCase) : Bool :=
  match findLabelIndex? step.batchedTime.labels "control/next_pc_linear" with
  | some idx =>
      decide (step.shiftSumcheck.claimedSum = step.batchedTime.claimedSums[idx]!) &&
        decide (step.shiftSumcheck.roundPolys = step.batchedTime.roundPolys[idx]!) &&
        decide (step.shiftSumcheck.challenges = step.batchedTime.sharedChallenges)
  | none =>
      decide (step.shiftSumcheck.claimedSum = { c0 := 0, c1 := 0 }) &&
        decide (step.shiftSumcheck.roundPolys = #[]) &&
        decide (step.shiftSumcheck.challenges = step.batchedTime.sharedChallenges)

structure NeoFoldShiftMetadataBreakdown where
  hasLabel : Bool
  claimedSum : Bool
  roundPolys : Bool
  challenges : Bool
deriving Repr, Inhabited

private def shiftMetadataBreakdown
    (step : NeoFoldStepArtifactCase) : NeoFoldShiftMetadataBreakdown :=
  match findLabelIndex? step.batchedTime.labels "control/next_pc_linear" with
  | some idx =>
      { hasLabel := true
        claimedSum := decide (step.shiftSumcheck.claimedSum = step.batchedTime.claimedSums[idx]!)
        roundPolys := decide (step.shiftSumcheck.roundPolys = step.batchedTime.roundPolys[idx]!)
        challenges := decide (step.shiftSumcheck.challenges = step.batchedTime.sharedChallenges) }
  | none =>
      { hasLabel := false
        claimedSum := decide (step.shiftSumcheck.claimedSum = { c0 := 0, c1 := 0 })
        roundPolys := decide (step.shiftSumcheck.roundPolys = #[])
        challenges := decide (step.shiftSumcheck.challenges = step.batchedTime.sharedChallenges) }

private def routeABoolMatches (step : NeoFoldStepArtifactCase) : Bool :=
  decide (
    step.routeA =
      (!step.batchedTime.claimedSums.isEmpty ||
        !step.valLanes.isEmpty ||
        !step.wbLanes.isEmpty ||
        !step.wpLanes.isEmpty ||
        !step.stage8Lanes.isEmpty))

private def stepChecks
    (artifact : NeoFoldArtifactCase)
    (stepIdx : Nat)
    (step : NeoFoldStepArtifactCase) : Bool :=
  let isTerminal := stepIdx + 1 = artifact.steps.size
  transcriptChecks step.piCcs &&
    transcriptChecks step.piCcsNc &&
    transcriptChecks step.cpuSumcheck &&
    optionalTranscriptChecks step.shiftSumcheck &&
    batchedTimeChecks step.batchedTime &&
    ccsOutChecks artifact step &&
    cpuMetadataChecks step &&
    shiftMetadataChecks step &&
    decide (step.piCcsNc.claimedSum = { c0 := 0, c1 := 0 }) &&
    routeABoolMatches step &&
    mainLaneChecks artifact.kRho isTerminal step &&
    laneArrayChecks artifact.kRho step.valInputs step.valLanes true &&
    laneWitnessArrayChecks step.valLanes step.valLaneWitnesses &&
    laneArrayChecks artifact.kRho step.wbInputs step.wbLanes true &&
    laneWitnessArrayChecks step.wbLanes step.wbLaneWitnesses &&
    laneArrayChecks artifact.kRho step.wpInputs step.wpLanes true &&
    laneWitnessArrayChecks step.wpLanes step.wpLaneWitnesses &&
    (List.range step.stage8Lanes.size).all fun idx =>
      laneChecks artifact.kRho (step.stage8Lanes[idx]!)

private def finalValFromStep (step : NeoFoldStepArtifactCase) : Array NeoFoldClaimCase :=
  ((step.valLanes.foldl (fun acc lane => acc ++ lane.children) #[])
    ++ (step.wbLanes.foldl (fun acc lane => acc ++ lane.children) #[]))
    ++ ((step.wpLanes.foldl (fun acc lane => acc ++ lane.children) #[])
      ++ (step.stage8Lanes.foldl (fun acc lane => acc ++ lane.children) #[]))

private def computedFinalMain (artifact : NeoFoldArtifactCase) : Array NeoFoldClaimCase :=
  match artifact.steps.back? with
  | some step => step.mainLane.children
  | none => artifact.accInitMain

private def computedFinalVal (artifact : NeoFoldArtifactCase) : Array NeoFoldClaimCase :=
  artifact.steps.foldl (fun acc step => acc ++ finalValFromStep step) #[]

private def initialAccumulatorChecks (artifact : NeoFoldArtifactCase) : Bool :=
  match artifact.steps[0]? with
  | none => decide (artifact.accInitMain = artifact.finalMain) && artifact.finalVal.isEmpty
  | some first =>
      decide (first.ccsOut.size = artifact.accInitMain.size + first.mcsBatchCommitments.size) &&
        (List.range artifact.accInitMain.size).all fun idx =>
          let out := first.ccsOut[idx + first.mcsBatchCommitments.size]!
          let acc := artifact.accInitMain[idx]!
          decide (out.commitment = acc.commitment) &&
            decide (out.mIn = acc.mIn) &&
            decide (out.x = acc.x)

private def chainChecks (artifact : NeoFoldArtifactCase) : Bool :=
  initialAccumulatorChecks artifact &&
    (List.range artifact.steps.size).all fun idx =>
      if h : idx + 1 < artifact.steps.size then
        let cur := artifact.steps[idx]!
        let nxt := artifact.steps[idx + 1]!
        decide (nxt.ccsOut.size = cur.mainLane.children.size + nxt.mcsBatchCommitments.size) &&
          (List.range cur.mainLane.children.size).all fun childIdx =>
            let out := nxt.ccsOut[childIdx + nxt.mcsBatchCommitments.size]!
            let child := cur.mainLane.children[childIdx]!
            decide (out.commitment = child.commitment) &&
              decide (out.mIn = child.mIn) &&
              decide (out.x = child.x)
      else
        true

def initialAccumulatorWitnessChecks (artifact : NeoFoldArtifactCase) : Bool :=
  decide (artifact.accInitMainWitnessZ.size = artifact.accInitMain.size) &&
    (List.range artifact.accInitMain.size).all fun idx =>
      witnessShapeChecks
        (artifact.accInitMainWitnessZ[idx]!)
        artifact.ccs.m
    &&
    match artifact.steps[0]? with
    | none => artifact.accInitMainWitnessZ.isEmpty
    | some first =>
        decide (
          first.mainLaneInputWitnessZ.size =
            first.mcsBatchCommitments.size + artifact.accInitMainWitnessZ.size) &&
          (List.range artifact.accInitMainWitnessZ.size).all fun idx =>
            decide (
              first.mainLaneInputWitnessZ[first.mcsBatchCommitments.size + idx]! =
                artifact.accInitMainWitnessZ[idx]!)

private def chainWitnessChecks (artifact : NeoFoldArtifactCase) : Bool :=
  initialAccumulatorWitnessChecks artifact &&
    (List.range artifact.steps.size).all fun idx =>
      if h : idx + 1 < artifact.steps.size then
        let cur := artifact.steps[idx]!
        let nxt := artifact.steps[idx + 1]!
        decide (
          nxt.mainLaneInputWitnessZ.size =
            nxt.mcsBatchCommitments.size + cur.mainLaneChildWitnessZ.size) &&
          (List.range cur.mainLaneChildWitnessZ.size).all fun childIdx =>
            decide (
              nxt.mainLaneInputWitnessZ[nxt.mcsBatchCommitments.size + childIdx]! =
                cur.mainLaneChildWitnessZ[childIdx]!)
      else
        true

private def finalObligationChecks (artifact : NeoFoldArtifactCase) : Bool :=
  decide
      (artifact.finalMain.map normalizeClaimRefinementMetadata =
        (computedFinalMain artifact).map normalizeClaimRefinementMetadata) &&
    decide
      (artifact.finalVal.map normalizeClaimRefinementMetadata =
        (computedFinalVal artifact).map normalizeClaimRefinementMetadata)

private def segmentMetaChecks (artifact : NeoFoldArtifactCase) : Bool :=
  if artifact.segmentMeta.isEmpty then
    if artifact.steps.isEmpty then
      decide (artifact.publicStepCount = 0) &&
        decide (artifact.proofStepCount = 0)
    else
      decide (artifact.proofStepCount = artifact.steps.size) &&
        decide (artifact.publicStepCount ≥ artifact.steps.size)
  else
    let proofStepsSum := artifact.segmentMeta.foldl (fun acc entry => acc + entry.proofSteps) 0
    let publicStepsSum := artifact.segmentMeta.foldl (fun acc entry => acc + entry.publicSteps) 0
    decide (artifact.proofStepCount = artifact.steps.size) &&
      decide (publicStepsSum = artifact.publicStepCount) &&
      decide (proofStepsSum = artifact.proofStepCount) &&
      (Id.run do
        let mut proofCursor := 0
        for idx in [0:artifact.segmentMeta.size] do
          let entry := artifact.segmentMeta[idx]!
          if !(entry.publicSteps > 0 && entry.proofSteps > 0) then
            return false
          if entry.proofSteps > entry.publicSteps then
            return false
          if proofCursor + entry.proofSteps > artifact.steps.size then
            return false
          let covered := artifact.steps.extract proofCursor (proofCursor + entry.proofSteps)
          if entry.routeA then
            if !(entry.proofSteps = entry.publicSteps) then
              return false
            if !(covered.all fun step => step.routeA) then
              return false
          else if covered.any fun step => step.routeA then
            return false
          proofCursor := proofCursor + entry.proofSteps
        return proofCursor = artifact.steps.size)

private def artifactChecks (artifact : NeoFoldArtifactCase) : Bool :=
  (List.range artifact.steps.size).all (fun idx => stepChecks artifact idx artifact.steps[idx]!) &&
    chainChecks artifact &&
    chainWitnessChecks artifact &&
    finalObligationChecks artifact &&
    segmentMetaChecks artifact

/--
Public Rust-artifact acceptance predicate for exported `neo-fold` cases.

This stays in the validator layer and is intentionally separate from the paper
theorem modules.
-/
def implArtifactChecks (artifact : NeoFoldArtifactCase) : Bool :=
  artifactChecks artifact

/--
Paper-core main-lane relation checks for one exported step.

This erases Rust-only claim sidecars and keeps only the core `Π_RLC` / `Π_DEC`
parent obligations that belong to the folding relation itself.
-/
def paperMainLaneRelationChecks
    (kRho : Nat)
    (isTerminal : Bool)
    (step : NeoFoldStepArtifactCase) : Bool :=
  let lane := normalizeLaneSidecars step.mainLane
  !lane.inputs.isEmpty &&
    implRlcParentCoreChecks lane &&
    if isTerminal && lane.children.isEmpty then
      true
    else
      !lane.children.isEmpty &&
        implDecParentCoreChecks kRho lane

/--
Paper-core auxiliary-lane relation checks for one exported step.

This preserves the singleton-input linkage while erasing Rust-only claim
sidecars from both the lane input and the exported auxiliary input claim.
-/
def paperLaneArrayRelationChecks
    (kRho : Nat)
    (inputs : Array NeoFoldClaimCase)
    (lanes : Array NeoFoldLaneCase)
    (expectSingletonInputs : Bool) : Bool :=
  decide (inputs.size = lanes.size) &&
    (List.range lanes.size).all fun idx =>
      let lane := lanes[idx]!
      let laneCore := normalizeLaneSidecars lane
      implFoldLaneChecks kRho laneCore &&
        (if expectSingletonInputs then
          decide (laneCore.inputs.size = 1) &&
            decide (laneCore.inputs[0]! = normalizeClaimSidecars (inputs[idx]!))
        else
          true)

/--
Paper-core per-step folding relation checks for one exported step.

This captures the relation layer of the Rust artifact after erasing
implementation-only claim sidecars.
-/
def paperStepRelationChecks
    (artifact : NeoFoldArtifactCase)
    (stepIdx : Nat)
    (step : NeoFoldStepArtifactCase) : Bool :=
  let isTerminal := stepIdx + 1 = artifact.steps.size
  paperMainLaneRelationChecks artifact.kRho isTerminal step &&
    paperLaneArrayRelationChecks artifact.kRho step.valInputs step.valLanes true &&
    paperLaneArrayRelationChecks artifact.kRho step.wbInputs step.wbLanes true &&
    paperLaneArrayRelationChecks artifact.kRho step.wpInputs step.wpLanes true &&
    (List.range step.stage8Lanes.size).all fun idx =>
      implFoldLaneChecks artifact.kRho (normalizeLaneSidecars (step.stage8Lanes[idx]!))

/--
Projected paper-core per-step semantic checks for one exported step.

This is strictly stronger than the relation-only predicate. It keeps the
projected current-step CE semantics and witness-chain obligations that matter
for the Rust refinement layer, while still staying outside the paper modules.
-/
def paperStepSemanticChecks
    (artifact : NeoFoldArtifactCase)
    (stepIdx : Nat)
    (step : NeoFoldStepArtifactCase) : Bool :=
  let isTerminal := stepIdx + 1 = artifact.steps.size
  checkCurrentStepCE artifact.ccs artifact.foldBase step &&
    mainLaneInputWitnessChecks step &&
    mainLaneParentWitnessChecks step &&
    mainLaneRlcWitnessChecks step &&
    mainLaneChildWitnessChecks isTerminal step &&
    mainLaneDecWitnessChecks isTerminal step &&
    laneWitnessArrayChecks step.valLanes step.valLaneWitnesses &&
    laneWitnessArrayChecks step.wbLanes step.wbLaneWitnesses &&
    laneWitnessArrayChecks step.wpLanes step.wpLaneWitnesses

theorem mainLaneChecks_implies_paperMainLaneRelationChecks
    (kRho : Nat)
    (isTerminal : Bool)
    (step : NeoFoldStepArtifactCase) :
    mainLaneChecks kRho isTerminal step = true ->
      paperMainLaneRelationChecks kRho isTerminal step = true := by
  intro h
  by_cases hTerminal : isTerminal && step.mainLane.children.isEmpty
  · have hConj :
        ((((!step.mainLane.inputs.isEmpty = true ∧ mainLaneInputWitnessChecks step = true) ∧
              rlcParentChecks step.mainLane.ccs step.mainLane = true) ∧
            mainLaneParentWitnessChecks step = true) ∧
          mainLaneRlcWitnessChecks step = true) ∧
        mainLaneChildWitnessChecks true step = true ∧
        mainLaneDecWitnessChecks true step = true := by
      simpa [mainLaneChecks, hTerminal]
        using h
    have hInputs : ¬step.mainLane.inputs = #[] := by
      simpa using hConj.1.1.1.1.1
    have hRlcCore : implRlcParentCoreChecks step.mainLane = true := by
      exact implRlcParentChecks_implies_core step.mainLane hConj.1.1.1.2
    have hRlcCoreNorm : implRlcParentCoreChecks (normalizeLaneSidecars step.mainLane) = true := by
      simpa using hRlcCore
    have hTerminalPieces : isTerminal = true ∧ step.mainLane.children = #[] := by
      have hBool : isTerminal = true ∧ step.mainLane.children.isEmpty = true := by
        simpa using hTerminal
      exact ⟨hBool.1, by simpa using hBool.2⟩
    have hGoal :
        (¬step.mainLane.inputs = #[] ∧
          implRlcParentCoreChecks (normalizeLaneSidecars step.mainLane) = true) ∧
          (isTerminal = true ∧ step.mainLane.children = #[] ∨
            ¬step.mainLane.children = #[] ∧
              implDecParentCoreChecks kRho (normalizeLaneSidecars step.mainLane) = true) := by
      constructor
      · exact ⟨hInputs, hRlcCoreNorm⟩
      · exact Or.inl hTerminalPieces
    simpa [paperMainLaneRelationChecks, normalizeLaneSidecars] using hGoal
  · have hConj :
        ((((!step.mainLane.inputs.isEmpty = true ∧ mainLaneInputWitnessChecks step = true) ∧
              rlcParentChecks step.mainLane.ccs step.mainLane = true) ∧
            mainLaneParentWitnessChecks step = true) ∧
          mainLaneRlcWitnessChecks step = true) ∧
        ((!step.mainLane.children.isEmpty = true ∧
              decParentChecks step.mainLane.ccs step.mainLane.foldBase kRho step.mainLane = true) ∧
            mainLaneChildWitnessChecks false step = true) ∧
        mainLaneDecWitnessChecks false step = true := by
      simpa [mainLaneChecks, hTerminal]
        using h
    have hInputs : ¬step.mainLane.inputs = #[] := by
      simpa using hConj.1.1.1.1.1
    have hRlcCore : implRlcParentCoreChecks step.mainLane = true := by
      exact implRlcParentChecks_implies_core step.mainLane hConj.1.1.1.2
    have hRlcCoreNorm : implRlcParentCoreChecks (normalizeLaneSidecars step.mainLane) = true := by
      simpa using hRlcCore
    have hChildren : ¬step.mainLane.children = #[] := by
      simpa using hConj.2.1.1.1
    have hDecCore : implDecParentCoreChecks kRho step.mainLane = true := by
      exact implDecParentChecks_implies_core kRho step.mainLane hConj.2.1.1.2
    have hDecCoreNorm : implDecParentCoreChecks kRho (normalizeLaneSidecars step.mainLane) = true := by
      simpa using hDecCore
    have hGoal :
        (¬step.mainLane.inputs = #[] ∧
          implRlcParentCoreChecks (normalizeLaneSidecars step.mainLane) = true) ∧
          (isTerminal = true ∧ step.mainLane.children = #[] ∨
            ¬step.mainLane.children = #[] ∧
              implDecParentCoreChecks kRho (normalizeLaneSidecars step.mainLane) = true) := by
      constructor
      · exact ⟨hInputs, hRlcCoreNorm⟩
      · exact Or.inr ⟨hChildren, hDecCoreNorm⟩
    simpa [paperMainLaneRelationChecks, normalizeLaneSidecars, hTerminal] using hGoal

theorem laneArrayChecks_implies_paperLaneArrayRelationChecks
    (kRho : Nat)
    (inputs : Array NeoFoldClaimCase)
    (lanes : Array NeoFoldLaneCase)
    (expectSingletonInputs : Bool) :
    laneArrayChecks kRho inputs lanes expectSingletonInputs = true ->
      paperLaneArrayRelationChecks kRho inputs lanes expectSingletonInputs = true := by
  intro h
  by_cases hExpect : expectSingletonInputs
  · simp [laneArrayChecks, paperLaneArrayRelationChecks, hExpect] at h ⊢
    rcases h with ⟨hSize, hAll⟩
    constructor
    · exact hSize
    · intro idx hIdx
      have hLane := hAll idx hIdx
      rcases hLane with ⟨hLaneCore, hInputEq⟩
      rcases hInputEq with ⟨hOne, hEq⟩
      have hOneNorm : (normalizeLaneSidecars (lanes[idx]!)).inputs.size = 1 := by
        simpa [normalizeLaneSidecars] using hOne
      have hEqNorm :
          (normalizeLaneSidecars (lanes[idx]!)).inputs[0]! =
            normalizeClaimSidecars (inputs[idx]!) := by
        simpa [normalizeLaneSidecars, hOne] using congrArg normalizeClaimSidecars hEq
      constructor
      · exact implFoldLaneChecks_refines_normalizeLaneSidecars kRho (lanes[idx]!) hLaneCore
      · constructor
        · exact hOneNorm
        · exact hEqNorm
  · simp [laneArrayChecks, paperLaneArrayRelationChecks, hExpect] at h ⊢
    rcases h with ⟨hSize, hAll⟩
    constructor
    · exact hSize
    · intro idx hIdx
      exact implFoldLaneChecks_refines_normalizeLaneSidecars kRho (lanes[idx]!) (hAll idx hIdx)

theorem stepChecks_implies_paperStepRelationChecks
    (artifact : NeoFoldArtifactCase)
    (stepIdx : Nat)
    (step : NeoFoldStepArtifactCase) :
    stepChecks artifact stepIdx step = true ->
      paperStepRelationChecks artifact stepIdx step = true := by
  intro h
  have hConj := by
    simpa [stepChecks, List.all_eq_true] using h
  have hStage8 := hConj.2
  have h1 := hConj.1
  have hWpW := h1.2
  have h2 := h1.1
  have hWp := h2.2
  have h3 := h2.1
  have hWbW := h3.2
  have h4 := h3.1
  have hWb := h4.2
  have h5 := h4.1
  have hValW := h5.2
  have h6 := h5.1
  have hVal := h6.2
  have h7 := h6.1
  have hMain := h7.2
  have hStage8Norm :
      ∀ x : Nat, x < step.stage8Lanes.size →
        implFoldLaneChecks artifact.kRho (normalizeLaneSidecars (step.stage8Lanes[x]!)) = true := by
    intro idx hIdx
    exact implFoldLaneChecks_refines_normalizeLaneSidecars artifact.kRho
      (step.stage8Lanes[idx]!) (hStage8 idx hIdx)
  have hMainPaper :
      paperMainLaneRelationChecks artifact.kRho (decide (stepIdx + 1 = artifact.steps.size)) step = true :=
    mainLaneChecks_implies_paperMainLaneRelationChecks artifact.kRho
      (decide (stepIdx + 1 = artifact.steps.size)) step hMain
  have hValPaper :
      paperLaneArrayRelationChecks artifact.kRho step.valInputs step.valLanes true = true :=
    laneArrayChecks_implies_paperLaneArrayRelationChecks artifact.kRho
      step.valInputs step.valLanes true hVal
  have hWbPaper :
      paperLaneArrayRelationChecks artifact.kRho step.wbInputs step.wbLanes true = true :=
    laneArrayChecks_implies_paperLaneArrayRelationChecks artifact.kRho
      step.wbInputs step.wbLanes true hWb
  have hWpPaper :
      paperLaneArrayRelationChecks artifact.kRho step.wpInputs step.wpLanes true = true :=
    laneArrayChecks_implies_paperLaneArrayRelationChecks artifact.kRho
      step.wpInputs step.wpLanes true hWp
  have hGoal :
      ((((paperMainLaneRelationChecks artifact.kRho (decide (stepIdx + 1 = artifact.steps.size)) step = true ∧
            paperLaneArrayRelationChecks artifact.kRho step.valInputs step.valLanes true = true) ∧
          paperLaneArrayRelationChecks artifact.kRho step.wbInputs step.wbLanes true = true) ∧
        paperLaneArrayRelationChecks artifact.kRho step.wpInputs step.wpLanes true = true) ∧
      (∀ x : Nat, x < step.stage8Lanes.size →
        implFoldLaneChecks artifact.kRho (normalizeLaneSidecars (step.stage8Lanes[x]!)) = true)) := by
    exact ⟨⟨⟨⟨hMainPaper, hValPaper⟩, hWbPaper⟩, hWpPaper⟩, hStage8Norm⟩
  simpa [paperStepRelationChecks, List.all_eq_true] using hGoal

theorem stepChecks_implies_paperStepSemanticChecks
    (artifact : NeoFoldArtifactCase)
    (stepIdx : Nat)
    (step : NeoFoldStepArtifactCase) :
    stepChecks artifact stepIdx step = true ->
      paperStepSemanticChecks artifact stepIdx step = true := by
  intro h
  have hConj := by
    simpa [stepChecks, List.all_eq_true] using h
  have hStage8 := hConj.2
  have h1 := hConj.1
  have hWpW := h1.2
  have h2 := h1.1
  have hWp := h2.2
  have h3 := h2.1
  have hWbW := h3.2
  have h4 := h3.1
  have hWb := h4.2
  have h5 := h4.1
  have hValW := h5.2
  have h6 := h5.1
  have hVal := h6.2
  have h7 := h6.1
  have hMain := h7.2
  have hCurrent := h7.1.2
  have hGoal :
      ((((((((checkCurrentStepCE artifact.ccs artifact.foldBase step = true ∧
                  mainLaneInputWitnessChecks step = true) ∧
                mainLaneParentWitnessChecks step = true) ∧
              mainLaneRlcWitnessChecks step = true) ∧
            mainLaneChildWitnessChecks (decide (stepIdx + 1 = artifact.steps.size)) step = true) ∧
          mainLaneDecWitnessChecks (decide (stepIdx + 1 = artifact.steps.size)) step = true) ∧
        laneWitnessArrayChecks step.valLanes step.valLaneWitnesses = true) ∧
      laneWitnessArrayChecks step.wbLanes step.wbLaneWitnesses = true) ∧
      laneWitnessArrayChecks step.wpLanes step.wpLaneWitnesses = true := by
    exact ⟨⟨⟨⟨⟨⟨⟨hCurrent, hMain.1.1.1.1.1⟩, hMain.1.1.1.2⟩,
      hMain.1.1.2⟩, hMain.2.1⟩, hMain.2.2⟩, hValW⟩, hWbW⟩, hWpW⟩
  simpa [paperStepSemanticChecks] using hGoal

/--
Paper-core initial accumulator linkage obtained by erasing Rust-only claim
sidecars in the degenerate zero-step case.

The nondegenerate case already checks only paper fields (`commitment`, `mIn`,
`x`), so it is identical to the implementation check.
-/
def paperInitialAccumulatorChecks (artifact : NeoFoldArtifactCase) : Bool :=
  match artifact.steps[0]? with
  | none =>
      decide
          (artifact.accInitMain.map normalizeClaimSidecars =
            artifact.finalMain.map normalizeClaimSidecars) &&
        artifact.finalVal.isEmpty
  | some first =>
      decide (first.ccsOut.size = artifact.accInitMain.size + first.mcsBatchCommitments.size) &&
        (List.range artifact.accInitMain.size).all fun idx =>
          let out := first.ccsOut[idx + first.mcsBatchCommitments.size]!
          let acc := artifact.accInitMain[idx]!
          decide (out.commitment = acc.commitment) &&
            decide (out.mIn = acc.mIn) &&
            decide (out.x = acc.x)

/--
Paper-core chain linkage obtained by erasing Rust-only claim sidecars where the
artifact-level implementation checker compares whole exported claims.
-/
def paperChainChecks (artifact : NeoFoldArtifactCase) : Bool :=
  paperInitialAccumulatorChecks artifact &&
    (List.range artifact.steps.size).all fun idx =>
      if h : idx + 1 < artifact.steps.size then
        let cur := artifact.steps[idx]!
        let nxt := artifact.steps[idx + 1]!
        decide (nxt.ccsOut.size = cur.mainLane.children.size + nxt.mcsBatchCommitments.size) &&
          (List.range cur.mainLane.children.size).all fun childIdx =>
            let out := nxt.ccsOut[childIdx + nxt.mcsBatchCommitments.size]!
            let child := cur.mainLane.children[childIdx]!
            decide (out.commitment = child.commitment) &&
              decide (out.mIn = child.mIn) &&
              decide (out.x = child.x)
      else
        true

/--
Paper-core final exported claims obtained by erasing Rust-only sidecars.
-/
def paperFinalObligationChecks (artifact : NeoFoldArtifactCase) : Bool :=
  decide
      (artifact.finalMain.map normalizeClaimRefinementMetadata =
        (computedFinalMain artifact).map normalizeClaimRefinementMetadata) &&
    decide
      (artifact.finalVal.map normalizeClaimRefinementMetadata =
        (computedFinalVal artifact).map normalizeClaimRefinementMetadata)

theorem initialAccumulatorChecks_implies_paperInitialAccumulatorChecks
    (artifact : NeoFoldArtifactCase) :
    initialAccumulatorChecks artifact = true ->
      paperInitialAccumulatorChecks artifact = true := by
  cases hHead : artifact.steps[0]? with
  | none =>
      intro h
      simp [initialAccumulatorChecks, paperInitialAccumulatorChecks, hHead] at h ⊢
      rcases h with ⟨hEq, hEmpty⟩
      constructor
      · exact congrArg (fun claims => claims.map normalizeClaimSidecars) hEq
      · exact hEmpty
  | some first =>
      intro h
      simpa [initialAccumulatorChecks, paperInitialAccumulatorChecks, hHead] using h

theorem chainChecks_implies_paperChainChecks
    (artifact : NeoFoldArtifactCase) :
    chainChecks artifact = true ->
      paperChainChecks artifact = true := by
  intro h
  simp [chainChecks, paperChainChecks] at h ⊢
  exact ⟨
    initialAccumulatorChecks_implies_paperInitialAccumulatorChecks artifact h.1,
    h.2
  ⟩

theorem finalObligationChecks_implies_paperFinalObligationChecks
    (artifact : NeoFoldArtifactCase) :
    finalObligationChecks artifact = true ->
      paperFinalObligationChecks artifact = true := by
  intro h
  simpa [finalObligationChecks, paperFinalObligationChecks] using h

theorem implArtifactChecks_implies_chainChecks
    (artifact : NeoFoldArtifactCase) :
    implArtifactChecks artifact = true -> chainChecks artifact = true := by
  intro h
  simp [implArtifactChecks, artifactChecks] at h
  exact h.1.1.1.2

theorem implArtifactChecks_implies_finalObligationChecks
    (artifact : NeoFoldArtifactCase) :
    implArtifactChecks artifact = true -> finalObligationChecks artifact = true := by
  intro h
  simp [implArtifactChecks, artifactChecks] at h
  exact h.1.2

theorem implArtifactChecks_implies_paperStepRelationChecks
    (artifact : NeoFoldArtifactCase)
    (stepIdx : Nat)
    (hIdx : stepIdx < artifact.steps.size) :
    implArtifactChecks artifact = true ->
      paperStepRelationChecks artifact stepIdx (artifact.steps[stepIdx]!) = true := by
  intro h
  have hConj :
      ((((∀ idx : Nat, idx < artifact.steps.size →
              stepChecks artifact idx (artifact.steps[idx]!) = true) ∧
            chainChecks artifact = true) ∧
          chainWitnessChecks artifact = true) ∧
        finalObligationChecks artifact = true) ∧
      segmentMetaChecks artifact = true := by
    simpa [implArtifactChecks, artifactChecks, List.all_eq_true] using h
  have hSteps :
      ∀ idx, idx < artifact.steps.size →
        stepChecks artifact idx (artifact.steps[idx]!) = true := by
    exact hConj.1.1.1.1
  have hStep :
      stepChecks artifact stepIdx (artifact.steps[stepIdx]!) = true := by
    exact hSteps stepIdx hIdx
  exact stepChecks_implies_paperStepRelationChecks artifact stepIdx (artifact.steps[stepIdx]!) hStep

theorem implArtifactChecks_implies_paperStepSemanticChecks
    (artifact : NeoFoldArtifactCase)
    (stepIdx : Nat)
    (hIdx : stepIdx < artifact.steps.size) :
    implArtifactChecks artifact = true ->
      paperStepSemanticChecks artifact stepIdx (artifact.steps[stepIdx]!) = true := by
  intro h
  have hConj :
      ((((∀ idx : Nat, idx < artifact.steps.size →
              stepChecks artifact idx (artifact.steps[idx]!) = true) ∧
            chainChecks artifact = true) ∧
          chainWitnessChecks artifact = true) ∧
        finalObligationChecks artifact = true) ∧
      segmentMetaChecks artifact = true := by
    simpa [implArtifactChecks, artifactChecks, List.all_eq_true] using h
  have hStep :
      stepChecks artifact stepIdx (artifact.steps[stepIdx]!) = true := by
    exact hConj.1.1.1.1 stepIdx hIdx
  exact stepChecks_implies_paperStepSemanticChecks artifact stepIdx (artifact.steps[stepIdx]!) hStep

theorem chainWitnessChecks_implies_initialAccumulatorWitnessChecks
    (artifact : NeoFoldArtifactCase) :
    chainWitnessChecks artifact = true ->
      initialAccumulatorWitnessChecks artifact = true := by
  intro h
  simp [chainWitnessChecks] at h
  exact h.1

theorem implArtifactChecks_implies_chainWitnessChecks
    (artifact : NeoFoldArtifactCase) :
    implArtifactChecks artifact = true -> chainWitnessChecks artifact = true := by
  intro h
  simp [implArtifactChecks, artifactChecks] at h
  exact h.1.1.2

private def validArtifacts : Array NeoFoldArtifactCase :=
  neoFoldArtifactCases

def neoFoldArtifactScenarioNames : Array String :=
  validArtifacts.map (·.scenarioName)

structure NeoFoldStepCheckBreakdown where
  transcriptPiCcs : Bool
  transcriptPiCcsNc : Bool
  transcriptCpu : Bool
  transcriptShift : Bool
  batchedTime : Bool
  ccsOut : Bool
  cpuMetadata : Bool
  shiftMetadata : Bool
  piCcsNcZero : Bool
  routeABit : Bool
  mainLane : Bool
  mainLaneInputs : Bool
  mainLaneParent : Bool
  mainLaneChildren : Bool
  mainLaneWitness : Bool
  valLanes : Bool
  valLaneWitnesses : Bool
  wbLanes : Bool
  wbLaneWitnesses : Bool
  wpLanes : Bool
  wpLaneWitnesses : Bool
  stage8Lanes : Bool
  ccsOutDetail : NeoFoldCcsOutCheckBreakdown
  shiftDetail : NeoFoldShiftMetadataBreakdown
  mainLaneDetail : NeoFoldLaneCheckBreakdown
  mainLaneWitnessDetail : NeoFoldMainLaneWitnessBreakdown
  valLaneDetails : Array NeoFoldLaneCheckBreakdown
  valLaneWitnessDetails : Array NeoFoldWitnessChainBreakdown
  wbLaneWitnessDetails : Array NeoFoldWitnessChainBreakdown
  wpLaneWitnessDetails : Array NeoFoldWitnessChainBreakdown
  stage8LaneDetails : Array NeoFoldLaneCheckBreakdown
deriving Repr, Inhabited

structure NeoFoldStepCheckSummary where
  transcriptPiCcs : Bool
  transcriptPiCcsNc : Bool
  transcriptCpu : Bool
  transcriptShift : Bool
  batchedTime : Bool
  ccsOut : Bool
  cpuMetadata : Bool
  shiftMetadata : Bool
  piCcsNcZero : Bool
  routeABit : Bool
  mainLane : Bool
  mainLaneInputs : Bool
  mainLaneParent : Bool
  mainLaneChildren : Bool
  mainLaneWitness : Bool
  valLanes : Bool
  valLaneWitnesses : Bool
  wbLanes : Bool
  wbLaneWitnesses : Bool
  wpLanes : Bool
  wpLaneWitnesses : Bool
  stage8Lanes : Bool
deriving Repr, Inhabited

private def stepCheckBreakdown
    (artifact : NeoFoldArtifactCase)
    (stepIdx : Nat)
    (step : NeoFoldStepArtifactCase) : NeoFoldStepCheckBreakdown :=
  let isTerminal := stepIdx + 1 = artifact.steps.size
  let mainLaneInputsOk := mainLaneInputWitnessChecks step
  let mainLaneParentOk :=
    rlcParentChecks step.mainLane.ccs step.mainLane &&
      mainLaneParentWitnessChecks step &&
      mainLaneRlcWitnessChecks step
  let mainLaneChildrenOk :=
    if isTerminal && step.mainLane.children.isEmpty then
      mainLaneChildWitnessChecks true step &&
        mainLaneDecWitnessChecks true step
    else
      !step.mainLane.children.isEmpty &&
        decParentChecks step.mainLane.ccs step.mainLane.foldBase artifact.kRho step.mainLane &&
        mainLaneChildWitnessChecks false step &&
          mainLaneDecWitnessChecks false step
  { transcriptPiCcs := transcriptChecks step.piCcs
    transcriptPiCcsNc := transcriptChecks step.piCcsNc
    transcriptCpu := transcriptChecks step.cpuSumcheck
    transcriptShift := optionalTranscriptChecks step.shiftSumcheck
    batchedTime := batchedTimeChecks step.batchedTime
    ccsOut := ccsOutChecks artifact step
    cpuMetadata := cpuMetadataChecks step
    shiftMetadata := shiftMetadataChecks step
    piCcsNcZero := decide (step.piCcsNc.claimedSum = { c0 := 0, c1 := 0 })
    routeABit := routeABoolMatches step
    mainLane := mainLaneChecks artifact.kRho isTerminal step
    mainLaneInputs := mainLaneInputsOk
    mainLaneParent := mainLaneParentOk
    mainLaneChildren := mainLaneChildrenOk
    mainLaneWitness := mainLaneRlcWitnessChecks step && mainLaneDecWitnessChecks isTerminal step
    valLanes := laneArrayChecks artifact.kRho step.valInputs step.valLanes true
    valLaneWitnesses := laneWitnessArrayChecks step.valLanes step.valLaneWitnesses
    wbLanes := laneArrayChecks artifact.kRho step.wbInputs step.wbLanes true
    wbLaneWitnesses := laneWitnessArrayChecks step.wbLanes step.wbLaneWitnesses
    wpLanes := laneArrayChecks artifact.kRho step.wpInputs step.wpLanes true
    wpLaneWitnesses := laneWitnessArrayChecks step.wpLanes step.wpLaneWitnesses
    stage8Lanes :=
      (List.range step.stage8Lanes.size).all fun idx =>
        laneChecks artifact.kRho (step.stage8Lanes[idx]!)
    ccsOutDetail := ccsOutCheckBreakdown artifact step
    shiftDetail := shiftMetadataBreakdown step
    mainLaneDetail := laneCheckBreakdown artifact.kRho step.mainLane
    mainLaneWitnessDetail := mainLaneWitnessBreakdown isTerminal step
    valLaneDetails := step.valLanes.map (laneCheckBreakdown artifact.kRho)
    valLaneWitnessDetails := Array.ofFn fun idx : Fin step.valLanes.size =>
      match step.valLaneWitnesses[idx.1]? with
      | some chain => laneWitnessChainBreakdown (step.valLanes[idx.1]!) chain
      | none => default
    wbLaneWitnessDetails := Array.ofFn fun idx : Fin step.wbLanes.size =>
      match step.wbLaneWitnesses[idx.1]? with
      | some chain => laneWitnessChainBreakdown (step.wbLanes[idx.1]!) chain
      | none => default
    wpLaneWitnessDetails := Array.ofFn fun idx : Fin step.wpLanes.size =>
      match step.wpLaneWitnesses[idx.1]? with
      | some chain => laneWitnessChainBreakdown (step.wpLanes[idx.1]!) chain
      | none => default
    stage8LaneDetails := step.stage8Lanes.map (laneCheckBreakdown artifact.kRho) }

private def witnessChainFirstFail
    (lane : NeoFoldLaneCase)
    (chain : NeoFoldLaneWitnessCase) : String :=
  if !(decide (chain.inputWitnessZ.size = lane.inputs.size)) then "inputCount"
  else if !(decide (chain.childWitnessZ.size = lane.children.size)) then "childCount"
  else if !((List.range chain.inputWitnessZ.size).all fun idx =>
      witnessShapeChecks (chain.inputWitnessZ[idx]!) lane.ccs.m) then "inputShapes"
  else if !((List.range lane.inputs.size).all fun idx =>
      checkClaimCEFromWitness lane.ccs lane.foldBase (lane.inputs[idx]!) (chain.inputWitnessZ[idx]!)) then
    "inputClaims"
  else if !checkClaimCEFromWitness lane.ccs lane.foldBase lane.parent chain.parentWitnessZ then
    "parentClaim"
  else if !((List.range chain.childWitnessZ.size).all fun idx =>
      witnessShapeChecks (chain.childWitnessZ[idx]!) lane.ccs.m) then "childShapes"
  else if !((List.range lane.children.size).all fun idx =>
      checkClaimCEFromWitness lane.ccs lane.foldBase (lane.children[idx]!) (chain.childWitnessZ[idx]!)) then
    "childClaims"
  else if !rlcWitnessChecks lane.ccs.m lane.rhoCoeffs chain.inputWitnessZ chain.parentWitnessZ then
    "rlcWitness"
  else if !decWitnessChecks lane.foldBase lane.ccs.m chain.parentWitnessZ chain.childWitnessZ then
    "decWitness"
  else "ok"

private def mainLaneWitnessFirstFail
    (isTerminal : Bool)
    (step : NeoFoldStepArtifactCase) : String :=
  let lane := step.mainLane
  let currentCount := step.mcsBatchCommitments.size
  if !(decide (step.mainLaneInputWitnessZ.size = lane.inputs.size)) then "inputCount"
  else if !((List.range (min currentCount step.mainLaneInputWitnessZ.size)).all fun idx =>
      let claim := lane.inputs[idx]!
      let witness := step.mainLaneInputWitnessZ[idx]!
      let x := step.mcsBatchPublicInput[idx]!
      let commitment := step.mcsBatchCommitments[idx]!
      witnessShapeChecks witness lane.ccs.m &&
        claimBasicShapeChecks lane.ccs claim &&
        claimCtConstantTermChecks claim &&
        ccsRowwiseZeroChecksFromWitness lane.ccs witness &&
        decide (projectXFromPublicInputs x = claim.x.map toFArray) &&
        decide (claim.commitment = commitment) &&
        (List.range lane.ccs.matrices.size).all fun j =>
          let want := computeYRow lane.ccs witness claim.r j
          let got := toKArray claim.yRing[j]!
          decide (got.take D = want) &&
            decide (claim.ct[j]! = claim.yRing[j]![0]!) &&
        (if claim.sCol.isEmpty && claim.yZcol.isEmpty then
          true
        else
          decide (toKArray claim.yZcol =
            computeYZcolDigits lane.foldBase lane.ccs witness claim.sCol claim.yZcol.size))) then
    "currentInputs"
  else if !((List.range lane.inputs.size).all fun idx =>
      if idx < currentCount then
        true
      else
        checkClaimCEFromWitness lane.ccs lane.foldBase (lane.inputs[idx]!) (step.mainLaneInputWitnessZ[idx]!)) then
    "carriedInputs"
  else if !checkClaimCEFromWitness lane.ccs lane.foldBase lane.parent step.mainLaneParentWitnessZ then
    "parentClaim"
  else if !(if isTerminal && lane.children.isEmpty then
      step.mainLaneChildWitnessZ.isEmpty
    else
      decide (step.mainLaneChildWitnessZ.size = lane.children.size)) then
    "childCount"
  else if !((List.range step.mainLaneChildWitnessZ.size).all fun idx =>
      witnessShapeChecks (step.mainLaneChildWitnessZ[idx]!) lane.ccs.m) then
    "childShapes"
  else if !((List.range lane.children.size).all fun idx =>
      checkClaimCEFromWitness lane.ccs lane.foldBase (lane.children[idx]!) (step.mainLaneChildWitnessZ[idx]!)) then
    "childClaims"
  else if !mainLaneRlcWitnessChecks step then "rlcWitness"
  else if !mainLaneDecWitnessChecks isTerminal step then "decWitness"
  else "ok"

structure NeoFoldArtifactCheckSummary where
  stepChecks : Bool
  chainChecks : Bool
  finalObligations : Bool
  segmentMeta : Bool
deriving Repr, Inhabited

def artifactCheckSummary (artifact : NeoFoldArtifactCase) : NeoFoldArtifactCheckSummary :=
  { stepChecks :=
      (List.range artifact.steps.size).all
        (fun stepIdx => stepChecks artifact stepIdx artifact.steps[stepIdx]!)
    chainChecks := chainChecks artifact
    finalObligations := finalObligationChecks artifact
    segmentMeta := segmentMetaChecks artifact }

def artifactFirstFail? (artifact : NeoFoldArtifactCase) : Option String :=
  if !(artifactCheckSummary artifact).stepChecks then
    let rec findStep? (idx : Nat) : Option String :=
      if h : idx < artifact.steps.size then
        let step := artifact.steps[idx]
        let isTerminal := idx + 1 = artifact.steps.size
        if !transcriptChecks step.piCcs then some s!"step[{idx}].transcriptPiCcs"
        else if !transcriptChecks step.piCcsNc then some s!"step[{idx}].transcriptPiCcsNc"
        else if !transcriptChecks step.cpuSumcheck then some s!"step[{idx}].transcriptCpu"
        else if !optionalTranscriptChecks step.shiftSumcheck then some s!"step[{idx}].transcriptShift"
        else if !batchedTimeChecks step.batchedTime then some s!"step[{idx}].batchedTime"
        else if !ccsOutChecks artifact step then some s!"step[{idx}].ccsOut"
        else if !cpuMetadataChecks step then some s!"step[{idx}].cpuMetadata"
        else if !shiftMetadataChecks step then some s!"step[{idx}].shiftMetadata"
        else if !(decide (step.piCcsNc.claimedSum = { c0 := 0, c1 := 0 })) then some s!"step[{idx}].piCcsNcZero"
        else if !routeABoolMatches step then some s!"step[{idx}].routeABit"
        else if !mainLaneChecks artifact.kRho isTerminal step then some s!"step[{idx}].mainLane"
        else if !(mainLaneRlcWitnessChecks step && mainLaneDecWitnessChecks isTerminal step) then
          some s!"step[{idx}].mainLaneWitness"
        else if !laneArrayChecks artifact.kRho step.valInputs step.valLanes true then some s!"step[{idx}].valLanes"
        else if !laneWitnessArrayChecks step.valLanes step.valLaneWitnesses then some s!"step[{idx}].valLaneWitnesses"
        else if !laneArrayChecks artifact.kRho step.wbInputs step.wbLanes true then some s!"step[{idx}].wbLanes"
        else if !laneWitnessArrayChecks step.wbLanes step.wbLaneWitnesses then some s!"step[{idx}].wbLaneWitnesses"
        else if !laneArrayChecks artifact.kRho step.wpInputs step.wpLanes true then some s!"step[{idx}].wpLanes"
        else if !laneWitnessArrayChecks step.wpLanes step.wpLaneWitnesses then some s!"step[{idx}].wpLaneWitnesses"
        else if !((List.range step.stage8Lanes.size).all fun laneIdx =>
          laneChecks artifact.kRho (step.stage8Lanes[laneIdx]!)) then some s!"step[{idx}].stage8Lanes"
        else
          findStep? (idx + 1)
      else
        none
    findStep? 0
  else if !(artifactCheckSummary artifact).chainChecks then
    some "chainChecks"
  else if !(artifactCheckSummary artifact).finalObligations then
    some "finalObligations"
  else if !(artifactCheckSummary artifact).segmentMeta then
    some "segmentMeta"
  else
    none

def neoFoldArtifactCheckSummaryAt? (idx : Nat) : Option NeoFoldArtifactCheckSummary :=
  validArtifacts[idx]?.map fun artifact =>
    artifactCheckSummary artifact

def neoFoldArtifactStepCheckSummariesAt? (idx : Nat) : Option (Array NeoFoldStepCheckSummary) :=
  validArtifacts[idx]?.map fun artifact =>
    Array.ofFn fun stepIdx : Fin artifact.steps.size =>
      let step := artifact.steps[stepIdx.1]!
      let isTerminal := stepIdx.1 + 1 = artifact.steps.size
      let mainLaneInputsOk := mainLaneInputWitnessChecks step
      let mainLaneParentOk :=
        rlcParentChecks step.mainLane.ccs step.mainLane &&
          mainLaneParentWitnessChecks step &&
          mainLaneRlcWitnessChecks step
      let mainLaneChildrenOk :=
        if isTerminal && step.mainLane.children.isEmpty then
          mainLaneChildWitnessChecks true step &&
            mainLaneDecWitnessChecks true step
        else
          !step.mainLane.children.isEmpty &&
            decParentChecks step.mainLane.ccs step.mainLane.foldBase artifact.kRho step.mainLane &&
            mainLaneChildWitnessChecks false step &&
              mainLaneDecWitnessChecks false step
      { transcriptPiCcs := transcriptChecks step.piCcs
        transcriptPiCcsNc := transcriptChecks step.piCcsNc
        transcriptCpu := transcriptChecks step.cpuSumcheck
        transcriptShift := optionalTranscriptChecks step.shiftSumcheck
        batchedTime := batchedTimeChecks step.batchedTime
        ccsOut := ccsOutChecks artifact step
        cpuMetadata := cpuMetadataChecks step
        shiftMetadata := shiftMetadataChecks step
        piCcsNcZero := decide (step.piCcsNc.claimedSum = { c0 := 0, c1 := 0 })
        routeABit := routeABoolMatches step
        mainLane := mainLaneChecks artifact.kRho isTerminal step
        mainLaneInputs := mainLaneInputsOk
        mainLaneParent := mainLaneParentOk
        mainLaneChildren := mainLaneChildrenOk
        mainLaneWitness := mainLaneRlcWitnessChecks step && mainLaneDecWitnessChecks isTerminal step
        valLanes := laneArrayChecks artifact.kRho step.valInputs step.valLanes true
        valLaneWitnesses := laneWitnessArrayChecks step.valLanes step.valLaneWitnesses
        wbLanes := laneArrayChecks artifact.kRho step.wbInputs step.wbLanes true
        wbLaneWitnesses := laneWitnessArrayChecks step.wbLanes step.wbLaneWitnesses
        wpLanes := laneArrayChecks artifact.kRho step.wpInputs step.wpLanes true
        wpLaneWitnesses := laneWitnessArrayChecks step.wpLanes step.wpLaneWitnesses
        stage8Lanes :=
          (List.range step.stage8Lanes.size).all fun laneIdx =>
            laneChecks artifact.kRho (step.stage8Lanes[laneIdx]!) }

def neoFoldArtifactStepCheckSummaryAt?
    (artifactIdx stepIdx : Nat) : Option NeoFoldStepCheckSummary :=
  validArtifacts[artifactIdx]?.bind fun artifact =>
    artifact.steps[stepIdx]?.map fun step =>
      let isTerminal := stepIdx + 1 = artifact.steps.size
      { transcriptPiCcs := transcriptChecks step.piCcs
        transcriptPiCcsNc := transcriptChecks step.piCcsNc
        transcriptCpu := transcriptChecks step.cpuSumcheck
        transcriptShift := optionalTranscriptChecks step.shiftSumcheck
        batchedTime := batchedTimeChecks step.batchedTime
        ccsOut := ccsOutChecks artifact step
        cpuMetadata := cpuMetadataChecks step
        shiftMetadata := shiftMetadataChecks step
        piCcsNcZero := decide (step.piCcsNc.claimedSum = { c0 := 0, c1 := 0 })
        routeABit := routeABoolMatches step
        mainLane := mainLaneChecks artifact.kRho isTerminal step
        mainLaneInputs := mainLaneInputWitnessChecks step
        mainLaneParent :=
          rlcParentChecks step.mainLane.ccs step.mainLane &&
            mainLaneParentWitnessChecks step &&
            mainLaneRlcWitnessChecks step
        mainLaneChildren :=
          if isTerminal && step.mainLane.children.isEmpty then
            mainLaneChildWitnessChecks true step &&
              mainLaneDecWitnessChecks true step
          else
            !step.mainLane.children.isEmpty &&
              decParentChecks step.mainLane.ccs step.mainLane.foldBase artifact.kRho step.mainLane &&
              mainLaneChildWitnessChecks false step &&
                mainLaneDecWitnessChecks false step
        mainLaneWitness := mainLaneRlcWitnessChecks step && mainLaneDecWitnessChecks isTerminal step
        valLanes := laneArrayChecks artifact.kRho step.valInputs step.valLanes true
        valLaneWitnesses := laneWitnessArrayChecks step.valLanes step.valLaneWitnesses
        wbLanes := laneArrayChecks artifact.kRho step.wbInputs step.wbLanes true
        wbLaneWitnesses := laneWitnessArrayChecks step.wbLanes step.wbLaneWitnesses
        wpLanes := laneArrayChecks artifact.kRho step.wpInputs step.wpLanes true
        wpLaneWitnesses := laneWitnessArrayChecks step.wpLanes step.wpLaneWitnesses
        stage8Lanes :=
          (List.range step.stage8Lanes.size).all fun laneIdx =>
            laneChecks artifact.kRho (step.stage8Lanes[laneIdx]!) }

def neoFoldArtifactFirstFailAt?
    (artifactIdx stepIdx : Nat) : Option String :=
  validArtifacts[artifactIdx]?.bind fun artifact =>
    artifact.steps[stepIdx]?.map fun step =>
      let isTerminal := stepIdx + 1 = artifact.steps.size
      if !transcriptChecks step.piCcs then "transcriptPiCcs"
      else if !transcriptChecks step.piCcsNc then "transcriptPiCcsNc"
      else if !transcriptChecks step.cpuSumcheck then "transcriptCpu"
      else if !optionalTranscriptChecks step.shiftSumcheck then "transcriptShift"
      else if !batchedTimeChecks step.batchedTime then "batchedTime"
      else if !ccsOutChecks artifact step then "ccsOut"
      else if !cpuMetadataChecks step then "cpuMetadata"
      else if !shiftMetadataChecks step then "shiftMetadata"
      else if !(decide (step.piCcsNc.claimedSum = { c0 := 0, c1 := 0 })) then "piCcsNcZero"
      else if !routeABoolMatches step then "routeABit"
      else if !mainLaneChecks artifact.kRho isTerminal step then "mainLane"
      else if !(mainLaneRlcWitnessChecks step && mainLaneDecWitnessChecks isTerminal step) then
        "mainLaneWitness"
      else if !laneArrayChecks artifact.kRho step.valInputs step.valLanes true then "valLanes"
      else if !laneWitnessArrayChecks step.valLanes step.valLaneWitnesses then "valLaneWitnesses"
      else if !laneArrayChecks artifact.kRho step.wbInputs step.wbLanes true then "wbLanes"
      else if !laneWitnessArrayChecks step.wbLanes step.wbLaneWitnesses then "wbLaneWitnesses"
      else if !laneArrayChecks artifact.kRho step.wpInputs step.wpLanes true then "wpLanes"
      else if !laneWitnessArrayChecks step.wpLanes step.wpLaneWitnesses then "wpLaneWitnesses"
      else if !((List.range step.stage8Lanes.size).all fun laneIdx =>
        laneChecks artifact.kRho (step.stage8Lanes[laneIdx]!)) then "stage8Lanes"
      else "ok"

def neoFoldArtifactMainLaneWitnessFirstFailAt?
    (artifactIdx stepIdx : Nat) : Option String :=
  validArtifacts[artifactIdx]?.bind fun artifact =>
    artifact.steps[stepIdx]?.map fun step =>
      mainLaneWitnessFirstFail (stepIdx + 1 = artifact.steps.size) step

def neoFoldArtifactValLaneWitnessFirstFailsAt?
    (artifactIdx stepIdx : Nat) : Option (Array String) :=
  validArtifacts[artifactIdx]?.bind fun artifact =>
    artifact.steps[stepIdx]?.map fun step =>
      Array.ofFn fun laneIdx : Fin step.valLanes.size =>
        match step.valLaneWitnesses[laneIdx.1]? with
        | some chain => witnessChainFirstFail (step.valLanes[laneIdx.1]!) chain
        | none => "missing"

def neoFoldArtifactWbLaneWitnessFirstFailsAt?
    (artifactIdx stepIdx : Nat) : Option (Array String) :=
  validArtifacts[artifactIdx]?.bind fun artifact =>
    artifact.steps[stepIdx]?.map fun step =>
      Array.ofFn fun laneIdx : Fin step.wbLanes.size =>
        match step.wbLaneWitnesses[laneIdx.1]? with
        | some chain => witnessChainFirstFail (step.wbLanes[laneIdx.1]!) chain
        | none => "missing"

def neoFoldArtifactWpLaneWitnessFirstFailsAt?
    (artifactIdx stepIdx : Nat) : Option (Array String) :=
  validArtifacts[artifactIdx]?.bind fun artifact =>
    artifact.steps[stepIdx]?.map fun step =>
      Array.ofFn fun laneIdx : Fin step.wpLanes.size =>
        match step.wpLaneWitnesses[laneIdx.1]? with
        | some chain => witnessChainFirstFail (step.wpLanes[laneIdx.1]!) chain
        | none => "missing"

def neoFoldArtifactCcsOutFirstFailAt?
    (artifactIdx stepIdx : Nat) : Option String :=
  validArtifacts[artifactIdx]?.bind fun artifact =>
    artifact.steps[stepIdx]?.map fun step =>
      let currentCount := step.mcsBatchCommitments.size
      if !(decide (step.ccsOut.size = step.mainLane.inputs.size)) then "sizeEq"
      else if !(decide (step.ccsOut = step.mainLane.inputs)) then "inputsEq"
      else if !currentBatchSizeChecks step then "batchSizeAligned"
      else if step.ccsOut.isEmpty then "nonempty"
      else if !(decide (currentCount > 0)) then "currentCountPositive"
      else if !step.ccsOut.all (claimBasicShapeChecks artifact.ccs) then "allShapes"
      else if !step.ccsOut.all claimCtConstantTermChecks then "allCtConstant"
      else if !meBatchInvariantChecks step.ccsOut then "batchInvariants"
      else if !step.ccsOut.all (fun claim =>
        decide (claim.r.size ≤ step.piCcs.challenges.size) &&
          decide (claim.r = step.piCcs.challenges.take claim.r.size)) then "allRPrefixes"
      else if !checkCurrentStepCE artifact.ccs artifact.foldBase step then "currentCE"
      else if !(List.range step.ccsOut.size).all fun idx =>
        if idx < currentCount then
          true
        else
          let claim := step.ccsOut[idx]!
          let inp := step.mainLane.inputs[idx]!
          decide (claim.commitment = inp.commitment) &&
            decide (claim.mIn = inp.mIn) &&
            decide (claim.x = inp.x) then "carriedClaims"
      else "ok"

def neoFoldArtifactCurrentCEFirstFailAt?
    (artifactIdx stepIdx : Nat) : Option String :=
  validArtifacts[artifactIdx]?.bind fun artifact =>
    artifact.steps[stepIdx]?.map fun step =>
      let currentCount := step.mcsBatchCommitments.size
      if !currentBatchSizeChecks step then "batchSizeAligned"
      else if !(decide (currentCount ≤ step.ccsOut.size)) then "currentCountLeCcsOut"
      else
        match step.ccsOut[0]? with
        | none => "emptyCurrent"
        | some claim =>
            let witness := step.mcsBatchWitnessZ[0]!
            let x := step.mcsBatchPublicInput[0]!
            let commitment := step.mcsBatchCommitments[0]!
            if !witnessShapeChecks witness artifact.ccs.m then "witnessShape"
            else if !claimBasicShapeChecks artifact.ccs claim then "claimShape"
            else if !ccsRowwiseZeroChecksFromWitness artifact.ccs witness then "ccsZero"
            else if !(decide (projectXFromPublicInputs x = claim.x.map toFArray)) then "projectedX"
            else if !(decide (claim.commitment = commitment)) then "commitment"
            else if !((List.range artifact.ccs.matrices.size).all fun j =>
              let want := computeYRow artifact.ccs witness claim.r j
              let got := toKArray claim.yRing[j]!
              decide (got.take D = want) &&
                decide (claim.ct[j]! = claim.yRing[j]![0]!)) then "yRows"
            else if !(if claim.sCol.isEmpty && claim.yZcol.isEmpty then
              true
            else
              decide (toKArray claim.yZcol =
                computeYZcolDigits artifact.foldBase artifact.ccs witness claim.sCol claim.yZcol.size)) then "yZcol"
            else "ok"

private def tamperValLane (artifact : NeoFoldArtifactCase) : NeoFoldArtifactCase :=
  if h : 0 < artifact.steps.size then
    let step := artifact.steps[0]!
    { artifact with
        scenarioName := artifact.scenarioName ++ "/tampered_val_lane"
        shouldFail := true
        steps := artifact.steps.set! 0 { step with valLanes := #[] } }
  else
    artifact

private def tamperPiCcsFinal (artifact : NeoFoldArtifactCase) : NeoFoldArtifactCase :=
  if h : 0 < artifact.steps.size then
    let step := artifact.steps[0]!
    { artifact with
        scenarioName := artifact.scenarioName ++ "/tampered_pi_ccs_final"
        shouldFail := true
        steps := artifact.steps.set! 0
          { step with
              piCcs := { step.piCcs with
                finalSum := { step.piCcs.finalSum with c0 := step.piCcs.finalSum.c0 + 1 } } } }
  else
    artifact

private def tamperMainWitness (artifact : NeoFoldArtifactCase) : NeoFoldArtifactCase :=
  if hStep : 1 < artifact.steps.size then
    let step := artifact.steps[1]!
    if hRow : 0 < step.mainLaneParentWitnessZ.size then
      let row := step.mainLaneParentWitnessZ[0]!
      if hCoeff : 0 < row.size then
        let row' := row.set! 0 (row[0]! + 1)
        { artifact with
            scenarioName := artifact.scenarioName ++ "/tampered_main_witness"
            shouldFail := true
            steps := artifact.steps.set! 1
              { step with mainLaneParentWitnessZ := step.mainLaneParentWitnessZ.set! 0 row' } }
      else
        artifact
    else
      artifact
  else
    artifact

private def tamperCarriedWitness (artifact : NeoFoldArtifactCase) : NeoFoldArtifactCase :=
  if hStep : 0 < artifact.steps.size then
    let step := artifact.steps[0]!
    if hAcc : 0 < artifact.accInitMainWitnessZ.size then
      let carryIdx := step.mcsBatchCommitments.size
      if hCarry : carryIdx < step.mainLaneInputWitnessZ.size then
        let witness := step.mainLaneInputWitnessZ[carryIdx]!
        if hRow : 0 < witness.size then
          let row := witness[0]!
          if hCol : 0 < row.size then
            let row' := row.set! 0 (row[0]! + 1)
            let witness' := witness.set! 0 row'
            { artifact with
                scenarioName := artifact.scenarioName ++ "/tampered_carried_witness"
                shouldFail := true
                steps := artifact.steps.set! 0
                  { step with mainLaneInputWitnessZ := step.mainLaneInputWitnessZ.set! carryIdx witness' } }
          else
            artifact
        else
          artifact
      else
        artifact
    else
      artifact
  else
    artifact

private def tamperValLaneWitness (artifact : NeoFoldArtifactCase) : NeoFoldArtifactCase :=
  if hStep : 0 < artifact.steps.size then
    let step := artifact.steps[0]!
    if hLane : 0 < step.valLaneWitnesses.size then
      let chain := step.valLaneWitnesses[0]!
      if hInput : 0 < chain.inputWitnessZ.size then
        let witness := chain.inputWitnessZ[0]!
        if hRow : 0 < witness.size then
          let row := witness[0]!
          if hCol : 0 < row.size then
            let row' := row.set! 0 (row[0]! + 1)
            let witness' := witness.set! 0 row'
            let chain' := { chain with inputWitnessZ := chain.inputWitnessZ.set! 0 witness' }
            { artifact with
                scenarioName := artifact.scenarioName ++ "/tampered_val_lane_witness"
                shouldFail := true
                steps := artifact.steps.set! 0
                  { step with valLaneWitnesses := step.valLaneWitnesses.set! 0 chain' } }
          else
            artifact
        else
          artifact
      else
        artifact
    else
      artifact
  else
    artifact

private def tamperMainChildWitness (artifact : NeoFoldArtifactCase) : NeoFoldArtifactCase :=
  if hStep : 0 < artifact.steps.size then
    let stepIdx := artifact.steps.size - 1
    let step := artifact.steps[stepIdx]!
    if hChild : 0 < step.mainLaneChildWitnessZ.size then
      let witness := step.mainLaneChildWitnessZ[0]!
      if hRow : 0 < witness.size then
        let row := witness[0]!
        if hCol : 0 < row.size then
          let row' := row.set! 0 (row[0]! + 1)
          let witness' := witness.set! 0 row'
          { artifact with
              scenarioName := artifact.scenarioName ++ "/tampered_main_child_witness"
              shouldFail := true
              steps := artifact.steps.set! stepIdx
                { step with mainLaneChildWitnessZ := step.mainLaneChildWitnessZ.set! 0 witness' } }
        else
          artifact
      else
        artifact
    else
      artifact
  else
    artifact

private def tamperedArtifacts : Array NeoFoldArtifactCase :=
  #[
    tamperPiCcsFinal validArtifacts[0]!,
    tamperValLane validArtifacts[1]!,
    tamperMainWitness validArtifacts[1]!,
    tamperCarriedWitness validArtifacts[3]!,
    tamperValLaneWitness validArtifacts[1]!,
    tamperMainChildWitness validArtifacts[2]!
  ]

def allNeoFoldArtifactChecks : Bool :=
  validArtifacts.all artifactChecks

def tamperedNeoFoldArtifactChecks : Bool :=
  tamperedArtifacts.all artifactChecks

def validArtifactCheckResults : Array (String × Bool) :=
  validArtifacts.map fun artifact => (artifact.scenarioName, artifactChecks artifact)

def tamperedArtifactCheckResults : Array (String × Bool) :=
  tamperedArtifacts.map fun artifact => (artifact.scenarioName, artifactChecks artifact)

-- Temporary diagnostics are run from external scratch scripts while this module evolves.

end SuperNeo
