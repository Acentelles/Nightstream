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

private def runChip8TranscriptParity : IO Bool := do
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
  let okChip8TranscriptParity ← runChip8TranscriptParity
  IO.println s!"proof_import_wall={okProofImportWall}"
  IO.println s!"chip8_transcript_parity={okChip8TranscriptParity}"
  if okProofImportWall && okChip8TranscriptParity then
    IO.println "all_checks=true"
    pure 0
  else
    IO.println "all_checks=false"
    pure 1
