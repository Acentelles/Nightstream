namespace Nightstream.Chip8

inductive ExtensionFamily where
  | bytecodeFetch
  | instructionSemanticsLookup
  | registerHistory
  | ramHistory
deriving DecidableEq, Repr

end Nightstream.Chip8
