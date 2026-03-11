import Init
import SuperNeo.Checks

private def checkProofImportWall : IO Bool := do
  let pattern := "^import SuperNeo\\.(Checks|Generated|Regression|Golden)"
  let args := #[
    "-n",
    pattern,
    "SuperNeo/ProofSystem",
    "SuperNeo/FoldingProtocol.lean",
    "SuperNeo/SecurityModel.lean",
    "SuperNeo/EmbeddingTheory.lean",
    "SuperNeo/Primitives.lean"
  ]
  let out ← IO.Process.output { cmd := "rg", args := args }
  if out.exitCode == 1 then
    pure true
  else if out.exitCode == 0 then
    IO.println "proof_import_wall_violations:"
    IO.println out.stdout.trimAscii.toString
    pure false
  else
    IO.println "proof_import_wall_check_error:"
    if out.stderr.trimAscii.toString.isEmpty then
      IO.println out.stdout.trimAscii.toString
    else
      IO.println out.stderr.trimAscii.toString
    pure false

def main : IO UInt32 := do
  let okProofImportWall ← checkProofImportWall

  let okSuper := SuperNeo.checkSuperNeoCases
  let okRing := SuperNeo.checkRingMulCases
  let okNorm := SuperNeo.checkNormCases
  let okSplit := SuperNeo.checkSplitCases
  let okEq := SuperNeo.checkEqCases
  let okMle := SuperNeo.checkMleCases
  let okEmbeddingVec := SuperNeo.checkEmbeddingVecCases
  let okEmbeddingMatrix := SuperNeo.checkEmbeddingMatrixCases
  let okBarLiftVec := SuperNeo.checkBarLiftVecCases
  let okBarLiftMatrix := SuperNeo.checkBarLiftMatrixCases
  let okMatrixTransform := SuperNeo.checkMatrixTransformCases
  let okEvalLink := SuperNeo.checkEvalLinkCases
  let okEvalHom := SuperNeo.checkEvalHomCases
  let okModuleHom := SuperNeo.checkModuleHomCases
  let okInvertibility := SuperNeo.checkInvertibilityCases
  let okSampling := SuperNeo.checkSamplingCases
  let okEqLift := SuperNeo.checkEqLiftCases
  let okPolyLemmas := SuperNeo.checkPolyLemmaCases
  let okCoeffMaps := SuperNeo.checkCoeffMapCases
  let okParams := SuperNeo.checkParameterCases
  let okInterp := SuperNeo.checkInterpCases

  let allOk :=
    okProofImportWall && okSuper && okRing && okNorm && okSplit && okEq && okMle &&
      okEmbeddingVec && okEmbeddingMatrix &&
      okBarLiftVec && okBarLiftMatrix && okMatrixTransform &&
      okEvalLink && okEvalHom && okModuleHom && okInvertibility && okSampling &&
      okEqLift && okPolyLemmas && okCoeffMaps && okParams && okInterp

  IO.println s!"proof_import_wall={okProofImportWall}"
  IO.println s!"superneo_cases={okSuper}"
  IO.println s!"ring_mul_cases={okRing}"
  IO.println s!"norm_cases={okNorm}"
  IO.println s!"split_cases={okSplit}"
  IO.println s!"eq_cases={okEq}"
  IO.println s!"mle_cases={okMle}"
  IO.println s!"embedding_vec_cases={okEmbeddingVec}"
  IO.println s!"embedding_matrix_cases={okEmbeddingMatrix}"
  IO.println s!"bar_lift_vec_cases={okBarLiftVec}"
  IO.println s!"bar_lift_matrix_cases={okBarLiftMatrix}"
  IO.println s!"matrix_transform_cases={okMatrixTransform}"
  IO.println s!"eval_link_cases={okEvalLink}"
  IO.println s!"eval_hom_cases={okEvalHom}"
  IO.println s!"module_hom_cases={okModuleHom}"
  IO.println s!"invertibility_cases={okInvertibility}"
  IO.println s!"sampling_cases={okSampling}"
  IO.println s!"eq_lift_cases={okEqLift}"
  IO.println s!"poly_lemma_cases={okPolyLemmas}"
  IO.println s!"coeff_map_cases={okCoeffMaps}"
  IO.println s!"parameter_cases={okParams}"
  IO.println s!"interp_cases={okInterp}"

  if allOk then
    IO.println "all_checks=true"
    pure 0
  else
    IO.println "all_checks=false"
    pure 1
