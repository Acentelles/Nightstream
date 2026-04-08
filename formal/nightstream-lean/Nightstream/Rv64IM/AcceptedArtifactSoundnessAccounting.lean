import Nightstream.Rv64IM.Generated.AcceptedProofArtifactTypes
import Nightstream.Rv64IM.Kernel.SoundnessAccounting

/-!
Owns the canonical accepted-artifact soundness-accounting surface for RV64IM.
This owner fixes the protocol taxonomy that the exported artifact must name so
Lean can audit that the artifact and the theorem-facing accounting live over
the same channel and family decomposition.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated

private def stage1ShoutChannelName : Stage1ShoutChannel → String
  | .bytecode => "bytecode"
  | .alu => "alu"
  | .branch => "branch"

private def addressFamilyName : AddressFamily → String
  | .bytecode => "bytecode"
  | .alu => "alu"
  | .branch => "branch"
  | .reg => "reg"
  | .ram => "ram"

private def twistMemoryFamilyName : TwistMemoryFamily → String
  | .reg => "reg"
  | .ram => "ram"

def canonicalStage1ShoutChannelNames : List String :=
  stage1ShoutChannels.map stage1ShoutChannelName

def canonicalStage1AddressFamilyNames : List String :=
  stage1AddressFamilies.map addressFamilyName

def canonicalStage2AddressFamilyNames : List String :=
  [AddressFamily.reg, AddressFamily.ram].map addressFamilyName

def canonicalTwistMemoryFamilyNames : List String :=
  twistMemoryFamilies.map twistMemoryFamilyName

def canonicalScalarSoundnessTermNames : List String :=
  [ "ram_raf"
  , "stage1_linkage"
  , "stage2_linkage"
  , "continuity"
  , "opening_provenance"
  , "program_binding"
  , "pcs"
  , "fs"
  , "outer"
  ]

def soundnessAccountingSurfaceMatchesCanonical
    (surface : KernelSoundnessAccountingSurfaceView) : Bool :=
  surface.schemaVersion = 1 &&
    decide (surface.stage1ShoutChannels = canonicalStage1ShoutChannelNames) &&
    decide (surface.stage1AddressFamilies = canonicalStage1AddressFamilyNames) &&
    decide (surface.stage2AddressFamilies = canonicalStage2AddressFamilyNames) &&
    decide (surface.twistMemoryFamilies = canonicalTwistMemoryFamilyNames) &&
    decide (surface.scalarTerms = canonicalScalarSoundnessTermNames) &&
    surface.schemaDigest ≠ [] &&
    surface.digest ≠ []

end Nightstream.Rv64IM
