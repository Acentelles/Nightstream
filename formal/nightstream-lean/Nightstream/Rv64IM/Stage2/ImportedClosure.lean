import Nightstream.Rv64IM.Generated.ParityTypes

/-!
Owns the imported Stage 2 closure bridge from concrete committed execution rows
to the imported Stage 2 summary view used by RV64IM parity and higher theorem
interfaces.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated

private def listFlatMap (xs : List α) (f : α → List β) : List β :=
  xs.foldr (fun x acc => f x ++ acc) []

def rowReadsRs1 (row : ExpandedRowView) : Bool :=
  match row.traceOpcode, row.traceVirtualOpcode with
  | some .addi, _ | some .add, _ | some .sub, _ | some .addiw, _ | some .addw, _ | some .subw, _
  | some .andi, _ | some .and, _
  | some .ori, _ | some .or, _ | some .xori, _ | some .xor, _
  | some .slti, _ | some .slt, _ | some .sltiu, _ | some .sltu, _
  | some .slli, _ | some .sll, _ | some .srli, _ | some .srl, _
  | some .srai, _ | some .sra, _ | some .slliw, _ | some .sllw, _ | some .srliw, _ | some .srlw, _
  | some .sraiw, _ | some .sraw, _ | some .mul, _ | some .mulhu, _
  | some .div, _ | some .divu, _ | some .rem, _ | some .remu, _
  | some .divw, _ | some .divuw, _ | some .remw, _ | some .remuw, _
  | some .lb, _ | some .lbu, _ | some .lh, _ | some .lhu, _
  | some .lw, _ | some .lwu, _ | some .ld, _
  | some .sb, _ | some .sh, _ | some .sw, _ | some .sd, _
  | some .jalr, _
  | some .beq, _ | some .bne, _ | some .blt, _ | some .bge, _ | some .bltu, _ | some .bgeu, _ => true
  | _, some _ => true
  | _, _ => false

def rowReadsRs2 (row : ExpandedRowView) : Bool :=
  match row.traceOpcode with
  | some .add | some .sub | some .addw | some .subw | some .and | some .or | some .xor
  | some .slt | some .sltu | some .sll | some .srl | some .sra | some .sllw | some .srlw | some .sraw
  | some .mul | some .mulhu
  | some .div | some .divu | some .rem | some .remu
  | some .divw | some .divuw | some .remw | some .remuw
  | some .sb | some .sh | some .sw | some .sd
  | some .beq | some .bne | some .blt | some .bge | some .bltu | some .bgeu => true
  | _ =>
      match row.traceVirtualOpcode with
      | some .advice | some .changeDivisor | some .assertValidDiv0 | some .assertMulNoOverflow
      | some .assertLte | some .assertValidUnsignedRemainder | some .assertSignedDivIdentity
      | some .assertSignedRemainderBounds => true
      | _ => false

def stage2RegisterReadEventsOfRow (row : ExpandedRowView) : List RegisterReadEventView :=
  let rs1Reads :=
    if rowReadsRs1 row then
      [{ traceIndex := row.traceIndex, stepIndex := row.stepIndex, role := .rs1, reg := row.rs1, value := row.rs1Value }]
    else
      []
  let rs2Reads :=
    if rowReadsRs2 row then
      [{ traceIndex := row.traceIndex, stepIndex := row.stepIndex, role := .rs2, reg := row.rs2, value := row.rs2Value }]
    else
      []
  rs1Reads ++ rs2Reads

def stage2RegisterWriteEventsOfRow (row : ExpandedRowView) : List RegisterWriteEventView :=
  if row.writesRd then
    [{ traceIndex := row.traceIndex, stepIndex := row.stepIndex, reg := row.rd, previous := row.rdBefore, next := row.rdAfter }]
  else
    []

def stage2RamEventsOfRow (row : ExpandedRowView) : List RamEventView :=
  match row.effectiveAddr, row.memoryBefore with
  | some addr, some before =>
      [ { traceIndex := row.traceIndex
        , stepIndex := row.stepIndex
        , kind := if row.writesRam then .write else .read
        , addr := addr
        , previous := before
        , next := row.memoryAfter.getD before } ]
  | _, _ => []

def stage2TwistLinkOfRow (row : ExpandedRowView) : TwistLinkEventView :=
  { traceIndex := row.traceIndex
  , stepIndex := row.stepIndex
  , family := row.family
  , routedWriteValue := if row.writesRd then some row.rdAfter else none
  , routedMemoryBefore := row.memoryBefore
  , routedMemoryAfter := row.memoryAfter }

def stage2SummaryOfExecutionRows (rows : List ExpandedRowView) : Stage2SummaryView :=
  let registerReads :=
    listFlatMap rows stage2RegisterReadEventsOfRow
  let registerWrites :=
    listFlatMap rows stage2RegisterWriteEventsOfRow
  let ramEvents :=
    listFlatMap rows stage2RamEventsOfRow
  let twistLinks :=
    rows.map stage2TwistLinkOfRow
  { registerReads := registerReads
  , registerWrites := registerWrites
  , ramEvents := ramEvents
  , twistLinks := twistLinks }

def ImportedStage2Closure (rows : List ExpandedRowView) (stage2 : Stage2SummaryView) : Prop :=
  stage2 = stage2SummaryOfExecutionRows rows

instance (rows : List ExpandedRowView) (stage2 : Stage2SummaryView) :
    Decidable (ImportedStage2Closure rows stage2) := by
  unfold ImportedStage2Closure
  infer_instance

def importedStage2ClosureCheck (rows : List ExpandedRowView) (stage2 : Stage2SummaryView) : Bool :=
  decide (ImportedStage2Closure rows stage2)

@[simp] theorem stage2SummaryOfExecutionRows_twistLinks (rows : List ExpandedRowView) :
    (stage2SummaryOfExecutionRows rows).twistLinks = rows.map stage2TwistLinkOfRow := rfl

theorem stage2Summary_eq_stage2SummaryOfExecutionRows_of_importedStage2Closure
    {rows : List ExpandedRowView}
    {stage2 : Stage2SummaryView}
    (h : ImportedStage2Closure rows stage2) :
    stage2 = stage2SummaryOfExecutionRows rows :=
  h

theorem stage2TwistLinks_length_eq_executionRows_length_of_importedStage2Closure
    {rows : List ExpandedRowView}
    {stage2 : Stage2SummaryView}
    (h : ImportedStage2Closure rows stage2) :
    stage2.twistLinks.length = rows.length := by
  cases h
  simp [stage2SummaryOfExecutionRows]

end Nightstream.Rv64IM
