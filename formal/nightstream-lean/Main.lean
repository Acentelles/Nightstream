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

private def runNightstreamProtocolParity : IO Bool := do
  let buildOut ← IO.Process.output {
    cmd := "lake"
    args := #[
      "build",
      "Nightstream.Chip8.Checks",
      "Nightstream.Rv64IM.Checks",
      "Nightstream.Rv64IM.AcceptedArtifactChecks",
      "Nightstream.Rv64IM.AcceptedArtifactCompleteness"
    ]
  }
  let buildStdout := buildOut.stdout.trimAscii.toString
  let buildStderr := buildOut.stderr.trimAscii.toString
  unless buildStdout.isEmpty do
    IO.println buildStdout
  unless buildStderr.isEmpty do
    IO.eprintln buildStderr
  if buildOut.exitCode ≠ 0 then
    pure false
  else
    let out ← IO.Process.output {
      cmd := "lake"
      args := #["env", "lean", "--run", "CheckCli.lean"]
    }
    let stdout := out.stdout.trimAscii.toString
    let stderr := out.stderr.trimAscii.toString
    unless stdout.isEmpty do
      IO.println stdout
    unless stderr.isEmpty do
      IO.eprintln stderr
    pure (out.exitCode == 0)

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
