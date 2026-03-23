namespace Nightstream.Rv64IM

structure ExpandedBytecodeRow (Pc BytecodeAddr : Type _) where
  unexpandedPc : Pc
  expandedPc : BytecodeAddr
  isFirstInSequence : Bool
  isLastInSequence : Bool
deriving DecidableEq, Repr

def ExpandedBytecodeEntrypointValid
  (Entrypoint : Pc → BytecodeAddr)
  (initialPc : Pc)
  (firstRow : ExpandedBytecodeRow Pc BytecodeAddr) :
  Prop :=
  firstRow.isFirstInSequence = true ∧
    firstRow.unexpandedPc = initialPc ∧
    firstRow.expandedPc = Entrypoint initialPc

def ExpandedBytecodeSuccessorValid
  (Entrypoint : Pc → BytecodeAddr)
  (succ : BytecodeAddr → BytecodeAddr)
  (row : ExpandedBytecodeRow Pc BytecodeAddr)
  (pcNext : Pc)
  (nextExpandedPc : BytecodeAddr) :
  Prop :=
  if row.isLastInSequence then
    nextExpandedPc = Entrypoint pcNext
  else
    nextExpandedPc = succ row.expandedPc

structure ExpandedBytecodeEntrypointProofPackage (Pc BytecodeAddr : Type _) where
  Entrypoint : Pc → BytecodeAddr
  initialPc : Pc
  firstRow : ExpandedBytecodeRow Pc BytecodeAddr
  entrypointValid :
    ExpandedBytecodeEntrypointValid
      (Pc := Pc)
      (BytecodeAddr := BytecodeAddr)
      Entrypoint
      initialPc
      firstRow

structure ExpandedBytecodeSuccessorProofPackage (Pc BytecodeAddr : Type _) where
  Entrypoint : Pc → BytecodeAddr
  succ : BytecodeAddr → BytecodeAddr
  row : ExpandedBytecodeRow Pc BytecodeAddr
  pcNext : Pc
  nextExpandedPc : BytecodeAddr
  successorValid :
    ExpandedBytecodeSuccessorValid
      (Pc := Pc)
      (BytecodeAddr := BytecodeAddr)
      Entrypoint
      succ
      row
      pcNext
      nextExpandedPc

end Nightstream.Rv64IM
