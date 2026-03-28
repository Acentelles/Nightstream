import SuperNeo.Ring
import SuperNeo.CoeffMaps
import SuperNeo.Norm
import SuperNeo.Decomp
import SuperNeo.EqPoly
import SuperNeo.MLE
import SuperNeo.Embedding
import SuperNeo.BarLift
import SuperNeo.MatrixTransform
import SuperNeo.EvalLink
import SuperNeo.EvalHom
import SuperNeo.ModuleHom
import SuperNeo.InvertibilityAxioms
import SuperNeo.InvertibilityGoldilocks
import SuperNeo.SamplingSet
import SuperNeo.PolyLemmas
import SuperNeo.Dimensions
import SuperNeo.Parameters
import SuperNeo.Interp
import SuperNeo.Generated.Vectors

namespace SuperNeo

open F
open SuperNeo.Generated

private def toF (x : Nat) : F := F.ofNat x

private def toFArray (xs : Array Nat) : Array F :=
  xs.map toF

private def toFMatrix (m : Array (Array Nat)) : Array (Array F) :=
  m.map toFArray

private def toF3 (m : Array (Array (Array Nat))) : Array (Array (Array F)) :=
  m.map toFMatrix

private def sampleDiffNorm (a b : Array F) : Nat :=
  normInfCoeffs (vecAdd a (vecScale (-1) b))

private def strongSamplingCheck (cset : Array (Array F)) (bInv : Nat) : Bool :=
  (List.range cset.size).all fun i =>
    (List.range cset.size).all fun j =>
      if _h : i < j then
        decide (sampleDiffNorm cset[i]! cset[j]! < bInv)
      else
        true

private def empiricalExpansionRatio (rho v : Array F) : Nat :=
  normInfCoeffs (mulRq rho v) / Nat.max (normInfCoeffs v) 1

private def empiricalExpansionMax (cset vectors : Array (Array F)) : Nat :=
  (List.range cset.size).foldl
    (fun acc i =>
      (List.range vectors.size).foldl
        (fun innerAcc j => Nat.max innerAcc (empiricalExpansionRatio cset[i]! vectors[j]!))
        acc)
    0

private def moduleHomVec (factor : F) (bias : Array F) : VecModuleHom where
  map z := vecAdd (vecScale factor z) bias

private def moduleHomScalar (weights : Array F) (bias : F) : ScalarModuleHom where
  map z := dotBySize weights z + bias

private def zeroCoeffs : Coeffs :=
  Array.replicate d 0

private def rowBarMzRingExec (bar : Array (Array F)) (row z : Array F) : Coeffs :=
  let nR := min (row.size / d) (z.size / d)
  (List.range nR).foldl
    (fun acc j =>
      vecAdd acc (mulRqPhi (superneoBarBlock bar (extractBlock row j)) (extractBlock z j)))
    zeroCoeffs

private def barMzRingExec (bar : Array (Array F)) (m : Array (Array F)) (z : Array F) :
    Array Coeffs :=
  m.map (fun row => rowBarMzRingExec bar row z)

private def chiWeightExec (r : Array F) (j : Nat) : F :=
  eqPoly (bitsToFieldArray r.size j) r

private def rHatExec (r : Array F) (n : Nat) : Array F :=
  Array.ofFn fun i : Fin n => chiWeightExec r i.1

private def evalRingVectorExec (ys : Array Coeffs) (weights : Array F) : Coeffs :=
  if ys.size != weights.size then
    zeroCoeffs
  else
    (List.range ys.size).foldl
      (fun acc i => vecAdd acc (vecScale weights[i]! ys[i]!))
      zeroCoeffs

private def evalBarMzAtRingExec (bar : Array (Array F)) (m : Array (Array F))
    (z r : Array F) : Coeffs :=
  let ys := barMzRingExec bar m z
  let weights := rHatExec r ys.size
  evalRingVectorExec ys weights

private def polyEvalExec (coeffs : Array F) (x : F) : F :=
  coeffs.foldr (fun coeff acc => acc * x + coeff) 0

private def polyZero (n : Nat) : Array F :=
  Array.replicate n 0

private def polyOne (n : Nat) : Array F :=
  Array.ofFn fun i : Fin n => if i.1 = 0 then (1 : F) else 0

private def polyAddBounded (n : Nat) (a b : Array F) : Array F :=
  Array.ofFn fun i : Fin n => a.getD i.1 0 + b.getD i.1 0

private def polyScaleBounded (s : F) (coeffs : Array F) : Array F :=
  coeffs.map (fun coeff => s * coeff)

private def polyMulLinearBounded (n : Nat) (coeffs : Array F) (root : F) : Array F :=
  Array.ofFn fun i : Fin n =>
    let idx := i.1
    let prev :=
      if hPrev : idx > 0 then
        coeffs.getD (idx - 1) 0
      else
        0
    prev - root * coeffs.getD idx 0

private def interpolateCoeffsExec (xs ys : Array F) : Array F :=
  let n := xs.size
  (List.range n).foldl
    (fun acc i =>
      let numer :=
        (List.range n).foldl
          (fun cur j =>
            if i = j then
              cur
            else
              polyMulLinearBounded n cur xs[j]!)
          (polyOne n)
      let denom :=
        (List.range n).foldl
          (fun cur j =>
            if i = j then
              cur
            else
              cur * (xs[i]! - xs[j]!))
          1
      let scaled := polyScaleBounded (ys[i]! * F.inv denom) numer
      polyAddBounded n acc scaled)
    (polyZero n)

private def hasRingDegreeShapeBool (coeffs : Coeffs) : Bool :=
  coeffs.size == d

private def invertibilityWindowBool (bound : Nat) (coeffs : Coeffs) : Bool :=
  decide (normInfCoeffs coeffs ≤ bound)

private def strictInvertibilityWindowBool (bound : Nat) (coeffs : Coeffs) : Bool :=
  decide (0 < normInfCoeffs coeffs) && decide (normInfCoeffs coeffs < bound)

private def derivedInvertibilityAtBound (bound : Nat) (coeffs : Coeffs) : Bool :=
  if hShape : coeffs.size = d then
    if hPos : 0 < normInfCoeffs coeffs then
      if hLt : normInfCoeffs coeffs < bound then
        if hFive : bound = 5 then
          let _hInv : invertibleRq coeffs :=
            lowNormInvertibilityAssumption_five_goldilocks coeffs hShape
              (by simpa [strictInvertibilityWindowProp, hFive] using And.intro hPos hLt)
          true
        else if hPaper : bound = goldilocksPaperBInv then
          let _hInv : invertibleRq coeffs :=
            lowNormInvertibilityAssumption_paperBInv_goldilocks coeffs hShape
              (by simpa [strictInvertibilityWindowProp, hPaper] using And.intro hPos hLt)
          true
        else
          false
      else
        false
    else
      false
  else
    false

private def checkSuperCase (bar : Array (Array F)) (c : SuperNeoCase) : Bool :=
  let a := toFArray c.a
  let b := toFArray c.b
  let lhs := ct (mulRqPhi (superneoBarBlock bar a) b)
  let rhs := dot a b
  let expCt := toF c.expectedCt
  let expDot := toF c.expectedDot
  decide (lhs = expCt ∧ rhs = expDot ∧ lhs = rhs)

private def checkRingCase (c : RingMulCase) : Bool :=
  let a := toFArray c.a
  let b := toFArray c.b
  let got := mulRqPhi a b
  let exp := toFArray c.expected
  decide (got = exp)

private def checkNormCase (c : NormCase) : Bool :=
  let a := toFArray c.a
  decide (normInfCoeffs a = c.expectedNorm)

private def checkSplitCase (c : SplitCase) : Bool :=
  let input := toFArray c.input
  let gotDigits := splitBalancedVec input c.base c.k
  let expDigits := toFMatrix c.expectedDigits
  let gotRecomposed := recomposeSplitDigits gotDigits c.base
  let expRecomposed := toFArray c.expectedRecomposed
  decide
    (gotDigits = expDigits ∧ gotRecomposed = expRecomposed ∧ gotRecomposed = input) &&
      digitsWithinBase gotDigits c.base

private def checkEqCase (c : EqCase) : Bool :=
  let x := toFArray c.x
  let y := toFArray c.y
  let expected := toF c.expected
  let got := eqPoly x y
  let indicatorOk := true
  decide (got = expected) && indicatorOk

private def checkMleCase (c : MleCase) : Bool :=
  let v := toFArray c.v
  let r := toFArray c.r
  let gotInner := mleByInnerProduct v r
  let gotFold := mleByFoldingExec v r
  let expInner := toF c.expectedInner
  let expFold := toF c.expectedFold
  decide (gotInner = expInner ∧ gotFold = expFold ∧ gotInner = gotFold) && mleIdentity v r

private def checkEmbeddingVecCase (c : EmbeddingVecCase) : Bool :=
  let input := toFArray c.input
  let gotBlocks := embedVec input
  let expBlocks := toFMatrix c.expectedBlocks
  decide (gotBlocks = expBlocks ∧ unembedVec gotBlocks = input) && embeddingVecRoundTrip input

private def checkEmbeddingMatrixCase (c : EmbeddingMatrixCase) : Bool :=
  let input := toFMatrix c.input
  let gotBlocks := embedMatrix input
  let expBlocks := toF3 c.expectedBlocks
  decide (gotBlocks = expBlocks ∧ unembedMatrix gotBlocks = input) && embeddingMatrixRoundTrip input

private def checkBarLiftVecCase (bar : Array (Array F)) (c : BarLiftVecCase) : Bool :=
  let v := toFArray c.v
  let w := toFArray c.w
  let scalar := toF c.scalar
  let gotV := barLiftVector bar v
  let gotW := barLiftVector bar w
  let gotAdd := barLiftVector bar (vecAdd v w)
  let gotScale := barLiftVector bar (vecScale scalar v)
  let expV := toFArray c.expectedLiftV
  let expW := toFArray c.expectedLiftW
  let expAdd := toFArray c.expectedLiftAdd
  let expScale := toFArray c.expectedLiftScale
  let addLinear :=
    decide (barLiftVector bar (vecAdd v w) = vecAdd (barLiftVector bar v) (barLiftVector bar w))
  let scaleLinear :=
    decide (barLiftVector bar (vecScale scalar v) = vecScale scalar (barLiftVector bar v))
  decide (gotV = expV ∧ gotW = expW ∧ gotAdd = expAdd ∧ gotScale = expScale) &&
    addLinear && scaleLinear

private def checkBarLiftMatrixCase (bar : Array (Array F)) (c : BarLiftMatrixCase) : Bool :=
  let input := toFMatrix c.input
  let got := barLiftMatrix bar input
  let exp := toFMatrix c.expectedLifted
  decide (got = exp)

private def checkMatrixTransformCase (bar : Array (Array F)) (c : MatrixTransformCase) : Bool :=
  let m := toFMatrix c.matrix
  let z := toFArray c.z
  let gotMz := matrixVecDirect m z
  let gotCtBar := matrixVecCtBar bar m z
  let expMz := toFArray c.expectedMz
  let expCtBar := toFArray c.expectedCtBarMz
  decide (gotMz = expMz ∧ gotCtBar = expCtBar ∧ gotMz = gotCtBar) &&
    matrixTransformIdentity bar m z

private def checkEvalLinkCase (bar : Array (Array F)) (c : EvalLinkCase) : Bool :=
  let m := toFMatrix c.matrix
  let z := toFArray c.z
  let r := toFArray c.r
  let gotY := evalBarMzAtRingExec bar m z r
  let expY := toFArray c.expectedY
  let expCt := toF c.expectedCtY
  decide (gotY = expY ∧ ct gotY = expCt)

private def checkEvalHomCase (bar : Array (Array F)) (c : EvalHomCase) : Bool :=
  let m := toFMatrix c.matrix
  let z1 := toFArray c.z1
  let z2 := toFArray c.z2
  let r := toFArray c.r
  let rho1 := toF c.rho1
  let rho2 := toF c.rho2
  let gotY1 := evalBarMzAtRingExec bar m z1 r
  let gotY2 := evalBarMzAtRingExec bar m z2 r
  let gotYLin := vecAdd (vecScale rho1 gotY1) (vecScale rho2 gotY2)
  let gotYDirect := evalBarMzAtRingExec bar m (linComb2Vec rho1 rho2 z1 z2) r
  let expY1 := toFArray c.expectedY1
  let expY2 := toFArray c.expectedY2
  let expYLin := toFArray c.expectedYLin
  let expYDirect := toFArray c.expectedYDirect
  decide
      (gotY1 = expY1 ∧ gotY2 = expY2 ∧ gotYLin = expYLin ∧ gotYDirect = expYDirect ∧
        gotYLin = gotYDirect)

private def checkSamplingCase (c : SamplingCase) : Bool :=
  let cset := toFMatrix c.cset
  let vectors := toFMatrix c.vectors
  let gotStrong := strongSamplingCheck cset c.bInv
  let gotMaxRhoNorm := cset.foldl (fun acc rho => Nat.max acc (normInfCoeffs rho)) 0
  let gotBound := 2 * D * gotMaxRhoNorm
  let gotEmpirical := empiricalExpansionMax cset vectors
  decide
    (gotStrong = c.expectedStrong ∧
      gotMaxRhoNorm = c.expectedMaxRhoNorm ∧
      gotBound = c.expectedBound ∧
      gotEmpirical = c.expectedEmpirical)

private def checkEqLiftCase (c : EqLiftCase) : Bool :=
  let qVals := toFArray c.qVals
  let z := toFArray c.z
  let got := eqLiftFromTable qVals z
  let exp := toF c.expectedSum
  let boolOk :=
    if c.isBooleanPoint then
      decide (got = toF c.expectedAtBoolean)
    else
      true
  decide (got = exp) && boolOk

private def checkInterpCase (c : InterpCase) : Bool :=
  let xs := toFArray c.xs
  let ys := toFArray c.ys
  let expectedCoeffs := toFArray c.expectedCoeffs
  let evalPoint := toF c.evalPoint
  let expectedEvalAt := toF c.expectedEvalAt
  let gotCoeffs := interpolateCoeffsExec xs ys
  let gotEval := polyEvalExec expectedCoeffs evalPoint
  decide
    (gotCoeffs = expectedCoeffs ∧ gotEval = expectedEvalAt)

def checkSuperNeoCases : Bool :=
  let bar := toFMatrix barMatrixU64
  superneoCases.all (checkSuperCase bar)

def checkRingMulCases : Bool :=
  ringMulCases.all checkRingCase

def checkNormCases : Bool :=
  normCases.all checkNormCase

def checkSplitCases : Bool :=
  splitCases.all checkSplitCase

def checkEqCases : Bool :=
  eqCases.all checkEqCase

def checkMleCases : Bool :=
  mleCases.all checkMleCase

def checkEmbeddingVecCases : Bool :=
  embeddingVecCases.all checkEmbeddingVecCase

def checkEmbeddingMatrixCases : Bool :=
  embeddingMatrixCases.all checkEmbeddingMatrixCase

def checkBarLiftVecCases : Bool :=
  let bar := toFMatrix barMatrixU64
  barLiftVecCases.all (checkBarLiftVecCase bar)

def checkBarLiftMatrixCases : Bool :=
  let bar := toFMatrix barMatrixU64
  barLiftMatrixCases.all (checkBarLiftMatrixCase bar)

def checkMatrixTransformCases : Bool :=
  let bar := toFMatrix barMatrixU64
  matrixTransformCases.all (checkMatrixTransformCase bar)

def checkEvalLinkCases : Bool :=
  let bar := toFMatrix barMatrixU64
  evalLinkCases.all (checkEvalLinkCase bar)

def checkEvalHomCases : Bool :=
  let bar := toFMatrix barMatrixU64
  evalHomCases.all (checkEvalHomCase bar)

def checkSamplingCases : Bool :=
  samplingCases.all checkSamplingCase

def checkEqLiftCases : Bool :=
  eqLiftCases.all checkEqLiftCase

def checkModuleHomCases : Bool :=
  moduleHomCases.all fun c =>
    let scalar := toF c.scalar
    let x := toFArray c.x
    let y := toFArray c.y
    let vecH := moduleHomVec (toF c.vecFactor) (toFArray c.vecBias)
    let scalarH := moduleHomScalar (toFArray c.scalarWeights) (toF c.scalarBias)
    let gotVec := vecModuleCheckPair vecH scalar x y
    let gotScalar := scalarModuleCheckPair scalarH scalar x y
    decide (gotVec = c.expectedVecCheck ∧ gotScalar = c.expectedScalarCheck)

def checkInvertibilityCases : Bool :=
  invertibilityCases.all fun c =>
    let coeffs := toFArray c.coeffs
    let gotShape := hasRingDegreeShapeBool coeffs
    let gotWeak := invertibilityWindowBool c.bound coeffs
    let gotStrict := strictInvertibilityWindowBool c.bound coeffs
    let gotDerivable := derivedInvertibilityAtBound c.bound coeffs
    decide
      (gotShape = c.expectedShape ∧
        gotWeak = c.expectedWeakWindow ∧
        gotStrict = c.expectedStrictWindow ∧
        gotDerivable = c.expectedDerivableInvertible)

def checkPolyLemmaCases : Bool :=
  polyLemmaSanity

def checkCoeffMapCases : Bool :=
  let fromSuper := superneoCases.all (fun c => coeffMapRoundTrip (toFArray c.a) && coeffMapRoundTrip (toFArray c.b))
  let fromRing := ringMulCases.all (fun c => coeffMapRoundTrip (toFArray c.a) && coeffMapRoundTrip (toFArray c.b))
  fromSuper && fromRing && mleSanity && embeddingSanity

def checkParameterCases : Bool :=
  goldilocksShapeSanity && Parameters.Goldilocks.sanity

def checkInterpCases : Bool :=
  interpCases.all checkInterpCase

end SuperNeo
