import SuperNeo.Generated.NeoFoldSessions
import SuperNeo.RustRefinement.NeoFoldRefinement
import SuperNeo.RustRefinement.NeoFoldSessionValidation

open SuperNeo
open SuperNeo.Generated
open SuperNeo.RustRefinement

private def scenarioNames : Array String :=
  neoFoldSessionCases.map fun c => c.scenarioName

private def scenarioChecks : Array Bool :=
  neoFoldSessionCaseChecks

def main : IO UInt32 := do
  let implOk := generatedNeoFoldSessionChecks
  let paperOk := generatedNeoFoldSessionRefinementChecks
  let ok := implOk && paperOk
  IO.println s!"neo_fold_session_checks={implOk}"
  IO.println s!"neo_fold_session_paper_refinement_checks={paperOk}"
  if !ok then
    IO.println s!"neo_fold_session_scenarios={reprStr scenarioNames}"
    IO.println s!"neo_fold_session_scenario_checks={reprStr scenarioChecks}"
    IO.println s!"neo_fold_session_paper_glue_checks={reprStr generatedNeoFoldSessionCases_paperSessionGlueChecks}"
  pure (if ok then 0 else 1)
