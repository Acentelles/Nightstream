import SuperNeo.Generated.NeoFoldArtifacts
import SuperNeo.RustRefinement.NeoFoldRelationValidation

open SuperNeo
open SuperNeo.Generated
open SuperNeo.RustRefinement

private def scenarioNames : Array String :=
  neoFoldArtifactCases.map fun artifact => artifact.scenarioName

private def scenarioChecks : Array Bool :=
  generatedNeoFoldArtifactCases_paperRelationChecks

def main : IO UInt32 := do
  let ok := generatedNeoFoldArtifactRelationChecks
  IO.println s!"neo_fold_relation_checks={ok}"
  if !ok then
    IO.println s!"neo_fold_relation_scenarios={reprStr scenarioNames}"
    IO.println s!"neo_fold_relation_scenario_checks={reprStr scenarioChecks}"
  pure (if ok then 0 else 1)
