import SuperNeo.Generated.NeoFoldArtifacts
import SuperNeo.RustRefinement.NeoFoldStepSemanticValidation

open SuperNeo
open SuperNeo.Generated
open SuperNeo.RustRefinement

private def scenarioNames : Array String :=
  neoFoldArtifactCases.map fun artifact => artifact.scenarioName

private def scenarioChecks : Array Bool :=
  generatedNeoFoldArtifactCases_paperStepSemanticChecks

def main : IO UInt32 := do
  let ok := generatedNeoFoldArtifactStepSemanticChecks
  IO.println s!"neo_fold_step_semantic_checks={ok}"
  if !ok then
    IO.println s!"neo_fold_step_semantic_scenarios={reprStr scenarioNames}"
    IO.println s!"neo_fold_step_semantic_scenario_checks={reprStr scenarioChecks}"
  pure (if ok then 0 else 1)
