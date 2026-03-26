import Nightstream.Rv64IM.Kernel.PublicProofBoundary

/-!
Owns the canonical theorem-facing accepted public proof object. At this layer,
that object is exactly the Rust-shaped public proof boundary
(`statement / claims / kernelProof`) together with the accepted-proof witness
that discharges it.
-/

namespace Nightstream.Rv64IM

abbrev AcceptedPublicProof
  (BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
    BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding
    Statement ClaimBundle KernelProofBundle :
    Type _) [OfNat Limb 0] :=
  PublicProofBoundary
    BytecodeAddr
    Pc
    RegIdx
    VirtualOpcode
    AluOp
    BranchOp
    MemWidth
    DivRemKind
    RamAddr
    Word
    StateLocation
    RegisterTimeline
    RamTimeline
    Limb
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    PreparedStep
    ProgramImage
    LoweringVersion
    RomTable
    BytecodeTable
    RomCommit
    BytecodeCommit
    Source
    CommitmentId
    Point
    PolynomialId
    Value
    Digest
    ExactOpeningWitness
    OpeningRefinement
    RowProjectionWitness
    BridgeBinding
    Statement
    ClaimBundle
    KernelProofBundle

end Nightstream.Rv64IM
