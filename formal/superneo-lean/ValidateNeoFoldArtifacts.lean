import SuperNeo.NeoFoldArtifactValidation

private def scenarioCount : Nat :=
  SuperNeo.neoFoldArtifactScenarioNames.size

private def scenarioSummaries : Array (Option SuperNeo.NeoFoldArtifactCheckSummary) :=
  Array.ofFn fun idx : Fin scenarioCount =>
    SuperNeo.neoFoldArtifactCheckSummaryAt? idx.1

private def scenarioStepSummaries :
    Array (Option (Array SuperNeo.NeoFoldStepCheckSummary)) :=
  Array.ofFn fun idx : Fin scenarioCount =>
    SuperNeo.neoFoldArtifactStepCheckSummariesAt? idx.1

private def scenarioChecks : Array Bool :=
  scenarioSummaries.map fun summary =>
    match summary with
    | some s => s.stepChecks && s.chainChecks && s.finalObligations && s.segmentMeta
    | none => false

private def scenarioStepChecks : Array Bool :=
  scenarioStepSummaries.map fun steps? =>
    match steps? with
    | some steps => steps.all fun step =>
        step.transcriptPiCcs &&
          step.transcriptPiCcsNc &&
          step.transcriptCpu &&
          step.transcriptShift &&
          step.batchedTime &&
          step.ccsOut &&
          step.cpuMetadata &&
          step.shiftMetadata &&
          step.piCcsNcZero &&
          step.routeABit &&
          step.mainLane &&
          step.mainLaneInputs &&
          step.mainLaneParent &&
          step.mainLaneChildren &&
          step.mainLaneWitness &&
          step.valLanes &&
          step.valLaneWitnesses &&
          step.wbLanes &&
          step.wbLaneWitnesses &&
          step.wpLanes &&
          step.wpLaneWitnesses &&
          step.stage8Lanes
    | none => false

private def scenarioFirstFails : Array (Array String) :=
  Array.ofFn fun artifactIdx : Fin scenarioCount =>
    match SuperNeo.neoFoldArtifactStepCheckSummariesAt? artifactIdx.1 with
    | some steps =>
        Array.ofFn fun stepIdx : Fin steps.size =>
          (SuperNeo.neoFoldArtifactFirstFailAt? artifactIdx.1 stepIdx.1).getD "missing"
    | none => #[]

private def scenarioMainLaneWitnessFirstFails : Array (Array String) :=
  Array.ofFn fun artifactIdx : Fin scenarioCount =>
    match SuperNeo.neoFoldArtifactStepCheckSummariesAt? artifactIdx.1 with
    | some steps =>
        Array.ofFn fun stepIdx : Fin steps.size =>
          (SuperNeo.neoFoldArtifactMainLaneWitnessFirstFailAt? artifactIdx.1 stepIdx.1).getD "missing"
    | none => #[]

private def scenarioValLaneWitnessFirstFails : Array (Array (Array String)) :=
  Array.ofFn fun artifactIdx : Fin scenarioCount =>
    match SuperNeo.neoFoldArtifactStepCheckSummariesAt? artifactIdx.1 with
    | some steps =>
        Array.ofFn fun stepIdx : Fin steps.size =>
          (SuperNeo.neoFoldArtifactValLaneWitnessFirstFailsAt? artifactIdx.1 stepIdx.1).getD #[]
    | none => #[]

private def scenarioWbLaneWitnessFirstFails : Array (Array (Array String)) :=
  Array.ofFn fun artifactIdx : Fin scenarioCount =>
    match SuperNeo.neoFoldArtifactStepCheckSummariesAt? artifactIdx.1 with
    | some steps =>
        Array.ofFn fun stepIdx : Fin steps.size =>
          (SuperNeo.neoFoldArtifactWbLaneWitnessFirstFailsAt? artifactIdx.1 stepIdx.1).getD #[]
    | none => #[]

private def scenarioWpLaneWitnessFirstFails : Array (Array (Array String)) :=
  Array.ofFn fun artifactIdx : Fin scenarioCount =>
    match SuperNeo.neoFoldArtifactStepCheckSummariesAt? artifactIdx.1 with
    | some steps =>
        Array.ofFn fun stepIdx : Fin steps.size =>
          (SuperNeo.neoFoldArtifactWpLaneWitnessFirstFailsAt? artifactIdx.1 stepIdx.1).getD #[]
    | none => #[]

private def scenarioChainChecks : Array Bool :=
  scenarioSummaries.map fun summary =>
    match summary with
    | some s => s.chainChecks
    | none => false

private def scenarioFinalChecks : Array Bool :=
  scenarioSummaries.map fun summary =>
    match summary with
    | some s => s.finalObligations
    | none => false

private def scenarioSegmentChecks : Array Bool :=
  scenarioSummaries.map fun summary =>
    match summary with
    | some s => s.segmentMeta
    | none => false

def main : IO UInt32 := do
  let okValid := SuperNeo.allNeoFoldArtifactChecks
  let okTampered := SuperNeo.tamperedNeoFoldArtifactChecks
  IO.println s!"neo_fold_artifact_checks={okValid}"
  IO.println s!"tampered_neo_fold_artifact_checks={okTampered}"
  if !okValid then
    IO.println s!"neo_fold_artifact_scenarios={reprStr SuperNeo.neoFoldArtifactScenarioNames}"
    IO.println s!"neo_fold_artifact_scenario_checks={reprStr scenarioChecks}"
    IO.println s!"neo_fold_artifact_step_checks={reprStr scenarioStepChecks}"
    IO.println s!"neo_fold_artifact_step_first_fails={reprStr scenarioFirstFails}"
    IO.println s!"neo_fold_artifact_main_lane_witness_first_fails={reprStr scenarioMainLaneWitnessFirstFails}"
    IO.println s!"neo_fold_artifact_val_lane_witness_first_fails={reprStr scenarioValLaneWitnessFirstFails}"
    IO.println s!"neo_fold_artifact_wb_lane_witness_first_fails={reprStr scenarioWbLaneWitnessFirstFails}"
    IO.println s!"neo_fold_artifact_wp_lane_witness_first_fails={reprStr scenarioWpLaneWitnessFirstFails}"
    IO.println s!"neo_fold_artifact_chain_checks={reprStr scenarioChainChecks}"
    IO.println s!"neo_fold_artifact_final_checks={reprStr scenarioFinalChecks}"
    IO.println s!"neo_fold_artifact_segment_checks={reprStr scenarioSegmentChecks}"
  pure (if okValid && not okTampered then 0 else 1)
