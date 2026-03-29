import Nightstream.Rv64IM.ProofCompleteAudit

/-!
Interface for the executable RV64IM proof-completeness audit.
-/

namespace Nightstream.Rv64IM

namespace ProofCompleteAuditInterface

def implementationModule : String := "Nightstream.Rv64IM.ProofCompleteAudit"

def exportedModuleNames : List String :=
  [ "Nightstream.Rv64IM.Generated.AcceptedProofArtifactCorpus"
  , "Nightstream.Rv64IM.ProofCompleteAudit"
  ]

abbrev proofCompleteRustExportBlockers :=
  Nightstream.Rv64IM.proofCompleteRustExportBlockers
abbrev uniqueProofCompleteRustExportBlockers :=
  Nightstream.Rv64IM.uniqueProofCompleteRustExportBlockers
abbrev proofCompleteStaticFailures :=
  Nightstream.Rv64IM.proofCompleteStaticFailures
abbrev uniqueProofCompleteClosureBlockers :=
  Nightstream.Rv64IM.uniqueProofCompleteClosureBlockers

def entrypointContract : Prop := True

theorem entrypointContract_true : entrypointContract := by
  trivial

end ProofCompleteAuditInterface

end Nightstream.Rv64IM
