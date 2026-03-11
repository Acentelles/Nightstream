import SuperNeo.Generated.NeoFoldSessions

namespace SuperNeo

namespace RustRefinement

open SuperNeo.Generated

private def natAt (xs : Array Nat) (idx : Nat) : Nat :=
  if h : idx < xs.size then
    xs[idx]'h
  else
    0

private def optNatAt (xs : Array (Option Nat)) (idx : Nat) : Option Nat :=
  if h : idx < xs.size then
    xs[idx]'h
  else
    none

def sessionStepLinkChecks (c : NeoFoldSessionCase) : Bool :=
  let n := c.stepXs.size
  if n ≤ 1 then
    true
  else
    (List.range (n - 1)).all fun stepIdx =>
      let prev := c.stepXs[stepIdx]!
      let next := c.stepXs[stepIdx + 1]!
      c.stepLinkPairs.all fun pair =>
        let prevIdx := pair.1
        let nextIdx := pair.2
        decide (prevIdx < prev.size) &&
          decide (nextIdx < next.size) &&
          decide (natAt prev prevIdx = natAt next nextIdx)

private def sumNatArray (xs : Array Nat) : Nat :=
  xs.foldl (· + ·) 0

def sessionSegmentCarryChecks (c : NeoFoldSessionCase) : Bool :=
  let segCounts := c.segmentProofStepCounts
  let segInit := c.segmentInitialAccumulatorSizes
  let segFinal := c.segmentFinalAccumulatorSizes
  let segInitMainDigests := c.segmentInitialMainDigests
  let segFinalMainDigests := c.segmentFinalMainDigests
  let segInitValDigests := c.segmentInitialValDigests
  let segFinalValDigests := c.segmentFinalValDigests
  let segs := segCounts.size
  decide (segs > 0) &&
    decide (segs = segInit.size) &&
    decide (segs = segFinal.size) &&
    decide (segs = segInitMainDigests.size) &&
    decide (segs = segFinalMainDigests.size) &&
    decide (segs = segInitValDigests.size) &&
    decide (segs = segFinalValDigests.size) &&
    decide (sumNatArray segCounts = c.proofStepCount) &&
    decide (natAt segInit 0 = 0) &&
    decide (natAt segInitMainDigests 0 = 0) &&
    segCounts.all fun n => decide (n > 0) &&
    (List.range (segs - 1)).all fun idx =>
      decide (natAt segInit (idx + 1) = natAt segFinal idx) &&
        decide (natAt segInitMainDigests (idx + 1) = natAt segFinalMainDigests idx)

def sessionOutputBindingShapeChecks (ob : NeoFoldSessionOutputBindingCase) : Bool :=
  ob.proofHasOutputBinding &&
    decide (ob.finalState.size = 2 ^ ob.numBits) &&
    ob.claims.all fun claim =>
      decide (claim.addr < ob.finalState.size) &&
        decide (natAt ob.finalState claim.addr = claim.value)

def sessionOutputBindingChecks (c : NeoFoldSessionCase) : Bool :=
  match c.outputBinding with
  | none => true
  | some ob => sessionOutputBindingShapeChecks ob

def sessionShapeChecks (c : NeoFoldSessionCase) : Bool :=
  decide (c.stepXs.size = c.publicStepCount) &&
    decide (c.foldCount = c.publicStepCount) &&
    decide (c.proofStepCount > 0)

def neoFoldSessionChecks (c : NeoFoldSessionCase) : Bool :=
  sessionShapeChecks c &&
    sessionSegmentCarryChecks c &&
    sessionStepLinkChecks c &&
    sessionOutputBindingChecks c

def neoFoldSessionCaseChecks : Array Bool :=
  neoFoldSessionCases.map neoFoldSessionChecks

def validNeoFoldSessionCasesAllCheck : Bool :=
  (List.range neoFoldSessionCases.size).all fun idx =>
    let c := neoFoldSessionCases[idx]!
    if c.shouldFail then
      true
    else
      neoFoldSessionCaseChecks[idx]!

def tamperedNeoFoldSessionCasesAllReject : Bool :=
  (List.range neoFoldSessionCases.size).all fun idx =>
    let c := neoFoldSessionCases[idx]!
    if c.shouldFail then
      !neoFoldSessionCaseChecks[idx]!
    else
      true

def generatedNeoFoldSessionChecks : Bool :=
  validNeoFoldSessionCasesAllCheck && tamperedNeoFoldSessionCasesAllReject

end RustRefinement

end SuperNeo
