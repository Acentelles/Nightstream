import SuperNeo.NeoFoldArtifactValidation

private def parseNatArg? (args : List String) : Option Nat :=
  match args with
  | s :: _ => s.toNat?
  | [] => none

private def printStepDetails
    (artifactIdx stepIdx : Nat)
    (summary : SuperNeo.NeoFoldStepCheckSummary) : IO Unit := do
  IO.println s!"step[{stepIdx}].summary={reprStr summary}"
  IO.println s!"step[{stepIdx}].firstFail={reprStr (SuperNeo.neoFoldArtifactFirstFailAt? artifactIdx stepIdx)}"
  IO.println s!"step[{stepIdx}].mainLaneWitnessFirstFail={reprStr (SuperNeo.neoFoldArtifactMainLaneWitnessFirstFailAt? artifactIdx stepIdx)}"
  IO.println s!"step[{stepIdx}].valLaneWitnessFirstFails={reprStr (SuperNeo.neoFoldArtifactValLaneWitnessFirstFailsAt? artifactIdx stepIdx)}"
  IO.println s!"step[{stepIdx}].wbLaneWitnessFirstFails={reprStr (SuperNeo.neoFoldArtifactWbLaneWitnessFirstFailsAt? artifactIdx stepIdx)}"
  IO.println s!"step[{stepIdx}].wpLaneWitnessFirstFails={reprStr (SuperNeo.neoFoldArtifactWpLaneWitnessFirstFailsAt? artifactIdx stepIdx)}"

def main (args : List String) : IO UInt32 := do
  let some idx := parseNatArg? args
    | do
        IO.println "usage: validate-neo-fold-artifact-scenario <scenario-index>"
        pure 2
  match SuperNeo.neoFoldArtifactScenarioNames[idx]? with
  | some name =>
      IO.println s!"scenario={name}"
      match SuperNeo.Generated.neoFoldArtifactCases[idx]? with
      | some artifact =>
          if artifact.steps.isEmpty then
            IO.println "steps=#[]"
          else
            for stepIdx in List.range artifact.steps.size do
              match SuperNeo.neoFoldArtifactStepCheckSummaryAt? idx stepIdx with
              | some stepSummary =>
                  printStepDetails idx stepIdx stepSummary
              | none =>
                  IO.println s!"step[{stepIdx}].summary=missing"
          pure 0
      | none =>
          IO.println "steps=missing_artifact"
          pure 1
  | none =>
      IO.println s!"unknown scenario index: {idx}"
      pure 1
