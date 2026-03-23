import Nightstream.Rv64IM.Execution.ExecutionSemantics

namespace Nightstream.Rv64IM

structure ChunkInput (State Row : Type _) where
  initialState : State
  semanticRows : Nat
  rows : List Row
  exactActivePrefix : rows.length = semanticRows

def FullHaltedChunkInput
  {State Row : Type _}
  (chunk : ChunkInput State Row)
  (terminatingRow : Row → Prop) : Prop :=
  ∃ idx row,
    chunk.rows[idx]? = some row ∧
      idx + 1 = chunk.semanticRows ∧
      terminatingRow row

theorem chunkRowsLength
  {State Row : Type _}
  (chunk : ChunkInput State Row) :
  chunk.rows.length = chunk.semanticRows :=
  chunk.exactActivePrefix

end Nightstream.Rv64IM
