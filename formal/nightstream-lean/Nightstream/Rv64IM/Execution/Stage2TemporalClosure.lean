namespace Nightstream.Rv64IM

structure Stage2TemporalContext (RegisterTimeline RamTimeline RowLinks : Type _) where
  regTimeline : RegisterTimeline
  ramTimeline : RamTimeline
  rowLinks : RowLinks
deriving Repr

def AdjacentStateClosed (State : Type _) (preState postState : Nat → State) (semanticRows : Nat) :
  Prop :=
  ∀ j, j + 1 < semanticRows → postState j = preState (j + 1)

structure Stage2TemporalClosureProofPackage
  (State RegisterTimeline RamTimeline RowLinks : Type _) where
  context : Stage2TemporalContext RegisterTimeline RamTimeline RowLinks
  semanticRows : Nat
  preState : Nat → State
  postState : Nat → State
  adjacentClosed : AdjacentStateClosed State preState postState semanticRows

end Nightstream.Rv64IM
