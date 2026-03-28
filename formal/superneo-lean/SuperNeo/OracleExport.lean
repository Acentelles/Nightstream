import SuperNeo.CoeffMaps
import SuperNeo.Decomp
import SuperNeo.EqPoly
import SuperNeo.MLE
import SuperNeo.Embedding
import SuperNeo.BarLift
import SuperNeo.MatrixTransform
import SuperNeo.Interp
import SuperNeo.PolyLemmas
import SuperNeo.InvertibilityGoldilocks
import SuperNeo.Parameters

namespace SuperNeo

open F

private def fOfInt (x : Int) : F :=
  if h : 0 ≤ x then
    F.ofNat (Int.toNat x)
  else
    -F.ofNat (Int.toNat (-x))

private def coeffsOfInts (xs : List Int) : Array F :=
  let vals := xs.toArray.map fOfInt
  if vals.size < d then
    vals ++ Array.replicate (d - vals.size) 0
  else
    vals.extract 0 d

private def arrayOfInts (xs : List Int) : Array F :=
  xs.toArray.map fOfInt

private def deterministicVec (len start step : Nat) : Array F :=
  Array.ofFn fun i : Fin len => F.ofNat (start + step * i.1)

private def deterministicMatrix (rows cols start rowStep colStep : Nat) : Array (Array F) :=
  Array.ofFn fun r : Fin rows =>
    Array.ofFn fun c : Fin cols => F.ofNat (start + rowStep * r.1 + colStep * c.1)

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
      if idx > 0 then
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

private def weakInvertibilityWindowBool (bound : Nat) (coeffs : Coeffs) : Bool :=
  decide (normInfCoeffs coeffs ≤ bound)

private def strictInvertibilityWindowBool (bound : Nat) (coeffs : Coeffs) : Bool :=
  decide (0 < normInfCoeffs coeffs) && decide (normInfCoeffs coeffs < bound)

private def natOfF (x : F) : Nat := x.val

private def jsonString (s : String) : String :=
  "\"" ++ s ++ "\""

private def jsonBool (b : Bool) : String :=
  if b then "true" else "false"

private def jsonNatArray (xs : Array Nat) : String :=
  "[" ++ String.intercalate ", " (xs.toList.map toString) ++ "]"

private def jsonFArray (xs : Array F) : String :=
  jsonNatArray (xs.map natOfF)

private def jsonFMatrix (m : Array (Array F)) : String :=
  "[" ++ String.intercalate ", " (m.toList.map jsonFArray) ++ "]"

private def jsonFields (fields : Array (String × String)) : String :=
  "{" ++
    String.intercalate ", "
      (fields.toList.map fun (k, v) => jsonString k ++ ": " ++ v) ++
    "}"

private def ringCtCasesJson : String :=
  let bar := nativeBarMatrix
  let cases : Array String :=
    #[
      coeffsOfInts [1, -2, 3, 0, 5],
      coeffsOfInts [-3, 1, 4, -1, 5, -9],
      coeffsOfInts [2, 0, -1, 7, -3, 6]
    ] |>.zip #[
      coeffsOfInts [0, 1, -1, 2, -2],
      coeffsOfInts [8, -5, 3, -2, 1, 0],
      coeffsOfInts [3, 1, 4, 1, 5, 9]
    ] |>.mapIdx fun i (a, b) =>
      let prod := mulRqPhi a b
      let ctBarDot := ct (mulRqPhi (superneoBarBlock bar a) b)
      let dotVal := innerProduct a b
      jsonFields #[
        ("name", jsonString s!"ring_ct_{i}"),
        ("a", jsonFArray a),
        ("b", jsonFArray b),
        ("expected_product", jsonFArray prod),
        ("expected_ct_bar_dot", toString (natOfF ctBarDot)),
        ("expected_dot", toString (natOfF dotVal))
      ]
  jsonFields #[
    ("family", jsonString "ring_ct_v1"),
    ("version", "1"),
    ("cases", "[" ++ String.intercalate ", " cases.toList ++ "]")
  ]

private def coeffMapCasesJson : String :=
  let cases : Array String :=
    #[
      coeffsOfInts [1, 0, -1, 2, -2, 3],
      coeffsOfInts [-4, 5, 0, 6, -7, 8],
      coeffsOfInts [9, -2, 6, -5, 3, -5]
    ] |>.mapIdx fun i coeffs =>
      let roundtrip := cf (cfInv coeffs)
      jsonFields #[
        ("name", jsonString s!"coeff_map_{i}"),
        ("coeffs", jsonFArray coeffs),
        ("expected_roundtrip", jsonFArray roundtrip),
        ("expected_ct", toString coeffs[0]!.val)
      ]
  jsonFields #[
    ("family", jsonString "coeff_maps_v1"),
    ("version", "1"),
    ("cases", "[" ++ String.intercalate ", " cases.toList ++ "]")
  ]

private def decompCasesJson : String :=
  let mkCase (name : String) (input : Array F) (base k : Nat) : String :=
    let digits := splitBalancedVec input base k
    let recomposed := recomposeSplitDigits digits base
    jsonFields #[
      ("name", jsonString name),
      ("input", jsonFArray input),
      ("base", toString base),
      ("k", toString k),
      ("expected_digits_row_major", jsonFMatrix digits),
      ("expected_recomposed", jsonFArray recomposed)
    ]
  let cases := #[
    mkCase "decomp_b2" (arrayOfInts [0, 1, -1, 2, -2, 3, -3, 4]) 2 8
  ]
  jsonFields #[
    ("family", jsonString "decomp_v1"),
    ("version", "1"),
    ("cases", "[" ++ String.intercalate ", " cases.toList ++ "]")
  ]

private def mleTensorCasesJson : String :=
  let mkCase (name : String) (v r : Array F) : String :=
    let tensor := rHatExec r v.size
    let innerVal := mleByInnerProduct v r
    let foldVal := mleByFoldingExec v r
    jsonFields #[
      ("name", jsonString name),
      ("v", jsonFArray v),
      ("r", jsonFArray r),
      ("expected_tensor", jsonFArray tensor),
      ("expected_inner", toString (natOfF innerVal)),
      ("expected_fold", toString (natOfF foldVal))
    ]
  let cases := #[
    mkCase "mle_tensor_0" (deterministicVec 8 3 5) (arrayOfInts [2, 3, 5]),
    mkCase "mle_tensor_1" (deterministicVec 8 7 9) (arrayOfInts [1, 4, 6])
  ]
  jsonFields #[
    ("family", jsonString "mle_tensor_v1"),
    ("version", "1"),
    ("cases", "[" ++ String.intercalate ", " cases.toList ++ "]")
  ]

private def embeddingBarCasesJson : String :=
  let vecInput := deterministicVec (2 * d) 5 3
  let vecBar := barLiftVector nativeBarMatrix vecInput
  let matrixInput := deterministicMatrix 2 (2 * d) 11 17 5
  let matrixBar := barLiftMatrix nativeBarMatrix matrixInput
  jsonFields #[
    ("family", jsonString "embedding_bar_v1"),
    ("version", "1"),
    ("vector_case", jsonFields #[
      ("input", jsonFArray vecInput),
      ("expected_blocks", jsonFMatrix (embedVec vecInput)),
      ("expected_bar_lift", jsonFArray vecBar)
    ]),
    ("matrix_case", jsonFields #[
      ("input", jsonFMatrix matrixInput),
      ("expected_blocks", "[" ++
        String.intercalate ", "
          ((embedMatrix matrixInput).toList.map jsonFMatrix) ++ "]"),
      ("expected_bar_lift", jsonFMatrix matrixBar)
    ])
  ]

private def matrixEvalCasesJson : String :=
  let matrix := deterministicMatrix 4 (2 * d) 13 19 7
  let z := deterministicVec (2 * d) 17 11
  let r := arrayOfInts [2, 7]
  let z1 := deterministicVec (2 * d) 23 3
  let z2 := deterministicVec (2 * d) 29 5
  let rho1 := F.ofNat 3
  let rho2 := F.ofNat 11
  let mz := matrixVecDirect matrix z
  let ctBarMz := matrixVecCtBar nativeBarMatrix matrix z
  let y := evalBarMzAtRingExec nativeBarMatrix matrix z r
  let y1 := evalBarMzAtRingExec nativeBarMatrix matrix z1 r
  let y2 := evalBarMzAtRingExec nativeBarMatrix matrix z2 r
  let yLin := vecAdd (vecScale rho1 y1) (vecScale rho2 y2)
  let yDirect := evalBarMzAtRingExec nativeBarMatrix matrix (linComb2Vec rho1 rho2 z1 z2) r
  jsonFields #[
    ("family", jsonString "matrix_eval_v1"),
    ("version", "1"),
    ("matrix_transform_case", jsonFields #[
      ("matrix", jsonFMatrix matrix),
      ("z", jsonFArray z),
      ("expected_mz", jsonFArray mz),
      ("expected_ct_bar_mz", jsonFArray ctBarMz)
    ]),
    ("eval_link_case", jsonFields #[
      ("matrix", jsonFMatrix matrix),
      ("z", jsonFArray z),
      ("r", jsonFArray r),
      ("expected_y", jsonFArray y),
      ("expected_ct_y", toString (natOfF (ct y)))
    ]),
    ("eval_hom_case", jsonFields #[
      ("matrix", jsonFMatrix matrix),
      ("z1", jsonFArray z1),
      ("z2", jsonFArray z2),
      ("r", jsonFArray r),
      ("rho1", toString (natOfF rho1)),
      ("rho2", toString (natOfF rho2)),
      ("expected_y1", jsonFArray y1),
      ("expected_y2", jsonFArray y2),
      ("expected_y_lin", jsonFArray yLin),
      ("expected_y_direct", jsonFArray yDirect)
    ])
  ]

private def polyCasesJson : String :=
  let qVals := deterministicVec 8 31 7
  let zBool := arrayOfInts [1, 0, 1]
  let zNonBool := arrayOfInts [2, 3, 5]
  let xs := arrayOfInts [0, 1, 2, 3]
  let coeffs := arrayOfInts [7, 13, 29, 5]
  let ys := xs.map (polyEvalExec coeffs)
  let interp := interpolateCoeffsExec xs ys
  let evalPoint := F.ofNat 17
  jsonFields #[
    ("family", jsonString "poly_v1"),
    ("version", "1"),
    ("eq_lift_cases", "[" ++ String.intercalate ", " #[
      jsonFields #[
        ("name", jsonString "eq_lift_bool"),
        ("q_vals", jsonFArray qVals),
        ("z", jsonFArray zBool),
        ("expected_sum", toString (natOfF (eqLiftFromTable qVals zBool))),
        ("expected_at_boolean", toString (natOfF qVals[5]!))
      ],
      jsonFields #[
        ("name", jsonString "eq_lift_non_bool"),
        ("q_vals", jsonFArray qVals),
        ("z", jsonFArray zNonBool),
        ("expected_sum", toString (natOfF (eqLiftFromTable qVals zNonBool)))
      ]
    ].toList ++ "]"),
    ("interp_cases", "[" ++ String.intercalate ", " #[
      jsonFields #[
        ("name", jsonString "interp_0"),
        ("xs", jsonFArray xs),
        ("ys", jsonFArray ys),
        ("expected_coeffs", jsonFArray interp),
        ("eval_point", toString (natOfF evalPoint)),
        ("expected_eval_at", toString (natOfF (polyEvalExec interp evalPoint)))
      ]
    ].toList ++ "]")
  ]

private def invertibilityCasesJson : String :=
  let mkCase (name : String) (coeffs : Coeffs) (bound : Nat) : String :=
    jsonFields #[
      ("name", jsonString name),
      ("coeffs", jsonFArray coeffs),
      ("bound", toString bound),
      ("expected_shape", jsonBool (coeffs.size == d)),
      ("expected_weak_window", jsonBool (weakInvertibilityWindowBool bound coeffs)),
      ("expected_strict_window", jsonBool (strictInvertibilityWindowBool bound coeffs)),
      ("expected_norm", toString (normInfCoeffs coeffs))
    ]
  let cases := #[
    mkCase "invertibility_zero" zeroCoeffs goldilocksPaperBInv,
    mkCase "invertibility_small"
      (coeffsOfInts [1, -2, 3, -1, 4, -3, 2, 1]) 5,
    mkCase "invertibility_paper"
      (coeffsOfInts [322, -71, 285, -291, -372, -174, -45, 370]) goldilocksPaperBInv
  ]
  jsonFields #[
    ("family", jsonString "invertibility_v1"),
    ("version", "1"),
    ("cases", "[" ++ String.intercalate ", " cases.toList ++ "]")
  ]

private def oracleFiles : Array (String × String) :=
  #[
    ("generated-oracles/ring_ct_v1.json", ringCtCasesJson),
    ("generated-oracles/coeff_maps_v1.json", coeffMapCasesJson),
    ("generated-oracles/decomp_v1.json", decompCasesJson),
    ("generated-oracles/mle_tensor_v1.json", mleTensorCasesJson),
    ("generated-oracles/embedding_bar_v1.json", embeddingBarCasesJson),
    ("generated-oracles/matrix_eval_v1.json", matrixEvalCasesJson),
    ("generated-oracles/poly_v1.json", polyCasesJson),
    ("generated-oracles/invertibility_v1.json", invertibilityCasesJson)
  ]

def exportOracleFiles : IO Unit := do
  IO.FS.createDirAll "generated-oracles"
  for (path, contents) in oracleFiles do
    IO.FS.writeFile path (contents ++ "\n")
    IO.println s!"wrote {path}"

end SuperNeo
