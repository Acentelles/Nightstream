namespace Nightstream.Rv64IM

structure ProgramBindingPublicInput
  (ProgramImage LoweringVersion RomCommit BytecodeCommit : Type _) where
  programImage : ProgramImage
  loweringVersion : LoweringVersion
  romCommitment : RomCommit
  bytecodeCommitment : BytecodeCommit
deriving Repr

def ProgramBinding
  (deriveRom : ProgramImage → RomTable)
  (deriveBytecode : RomTable → LoweringVersion → BytecodeTable)
  (commitRom : RomTable → RomCommit)
  (commitBytecode : BytecodeTable → BytecodeCommit)
  (publicInput :
    ProgramBindingPublicInput ProgramImage LoweringVersion RomCommit BytecodeCommit) :
  Prop :=
  let romTable := deriveRom publicInput.programImage
  let bytecodeTable := deriveBytecode romTable publicInput.loweringVersion
  publicInput.romCommitment = commitRom romTable ∧
    publicInput.bytecodeCommitment = commitBytecode bytecodeTable

structure ProgramBindingProofPackage
  (ProgramImage LoweringVersion RomTable BytecodeTable RomCommit BytecodeCommit : Type _) where
  publicInput :
    ProgramBindingPublicInput ProgramImage LoweringVersion RomCommit BytecodeCommit
  deriveRom : ProgramImage → RomTable
  deriveBytecode : RomTable → LoweringVersion → BytecodeTable
  commitRom : RomTable → RomCommit
  commitBytecode : BytecodeTable → BytecodeCommit
  binding :
    ProgramBinding
      deriveRom
      deriveBytecode
      commitRom
      commitBytecode
      publicInput

end Nightstream.Rv64IM
