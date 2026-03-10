import SuperNeo.Generated.NeoFoldArtifacts
import SuperNeo.RustRefinement.NeoFoldRefinement

open SuperNeo
open SuperNeo.Generated
open SuperNeo.RustRefinement

private def scenarioNames : Array String :=
  neoFoldArtifactCases.map fun artifact => artifact.scenarioName

private def scenarioChecks : Array Bool :=
  SuperNeo.RustRefinement.generatedNeoFoldArtifactCases_paperArtifactFullChecks

def main : IO UInt32 := do
  let ok := scenarioChecks.all id
  IO.println s!"neo_fold_paper_refinement_checks={ok}"
  if !ok then
    IO.println s!"neo_fold_paper_refinement_scenarios={reprStr scenarioNames}"
    IO.println s!"neo_fold_paper_refinement_scenario_checks={reprStr scenarioChecks}"
  pure (if ok then 0 else 1)
