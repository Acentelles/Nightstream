import SuperNeo.OracleExport

def main : IO UInt32 := do
  SuperNeo.exportOracleFiles
  pure 0
