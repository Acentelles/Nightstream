import SuperNeo.ProtocolArtifactValidation

def main : IO UInt32 := do
  let okValid := SuperNeo.allProtocolArtifactChecks
  let okTampered := SuperNeo.tamperedProtocolArtifactChecks
  IO.println s!"protocol_artifact_checks={okValid}"
  IO.println s!"tampered_protocol_artifact_checks={okTampered}"
  pure (if okValid && not okTampered then 0 else 1)
