import Init

private def checkProofImportWall : IO Bool := do
  let pattern := "^import Nightstream\\.(Checks|Generated|Regression|Golden)"
  let args := #[
    "-n",
    pattern,
    "Nightstream",
    "Nightstream.lean"
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

private def printProcessOutput (out : IO.Process.Output) : IO Unit := do
  let stdout := out.stdout.trimAscii.toString
  let stderr := out.stderr.trimAscii.toString
  if !stdout.isEmpty then
    IO.println stdout
  if !stderr.isEmpty then
    IO.println stderr

private def runProcessChecked (cmd : String) (args : Array String) : IO Bool := do
  let out ← IO.Process.output { cmd := cmd, args := args }
  printProcessOutput out
  pure (out.exitCode == 0)

private def runNightstreamProtocolParity : IO Bool := do
  let okBuild ←
    runProcessChecked "lake" #["build", "Nightstream.CheckCli"]
  if !okBuild then
    pure false
  else
    runProcessChecked "lake" #["env", "lean", "--run", "CheckCli.lean"]

def main : IO UInt32 := do
  let okProofImportWall ← checkProofImportWall
  let okNightstreamProtocolParity ← runNightstreamProtocolParity
  IO.println s!"proof_import_wall={okProofImportWall}"
  IO.println s!"nightstream_protocol_parity={okNightstreamProtocolParity}"
  if okProofImportWall && okNightstreamProtocolParity then
    IO.println "all_checks=true"
    pure 0
  else
    IO.println "all_checks=false"
    pure 1
