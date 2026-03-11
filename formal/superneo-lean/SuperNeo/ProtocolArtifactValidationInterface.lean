import SuperNeo.ProtocolArtifactValidation

namespace SuperNeo

namespace ProtocolArtifactValidationInterface

/-- [Role: Theorem-Target] Executable protocol-artifact sanity checks. -/
abbrev allProtocolArtifactChecks := SuperNeo.allProtocolArtifactChecks

/-- [Role: Theorem-Target] The tampered Rust-exported protocol artifact is rejected by the executable checks. -/
abbrev tamperedProtocolArtifactChecks := SuperNeo.tamperedProtocolArtifactChecks

/-- [Role: Theorem-Target] One Rust-exported protocol artifact yields `protocolTargetProp`. -/
theorem protocolArtifact_protocolTargetProp :
  protocolTargetProp protocolArtifactContext :=
  SuperNeo.protocolArtifact_protocolTargetProp

/-- [Role: Theorem-Target] One Rust-exported protocol artifact yields `ccsRelation`. -/
theorem protocolArtifact_ccsRelation :
  ccsRelation protocolArtifactContext :=
  SuperNeo.protocolArtifact_ccsRelation

/-- [Role: Theorem-Target] One Rust-exported protocol artifact yields `ceRelation`. -/
theorem protocolArtifact_ceRelation :
  ceRelation protocolArtifactContext :=
  SuperNeo.protocolArtifact_ceRelation

/-- [Role: Theorem-Target] One Rust-exported protocol artifact yields `Π_CCS`. -/
theorem protocolArtifact_piCCS :
  piCCSStrongStatement protocolArtifactContext :=
  SuperNeo.protocolArtifact_piCCS

/-- [Role: Theorem-Target] One Rust-exported protocol artifact yields `Π_RLC`. -/
theorem protocolArtifact_piRLC :
  piRLCWeakStatement protocolArtifactContext :=
  SuperNeo.protocolArtifact_piRLC

/-- [Role: Theorem-Target] One Rust-exported protocol artifact yields `Π_DEC`. -/
theorem protocolArtifact_piDEC :
  piDECKnowledgeStatement protocolArtifactContext :=
  SuperNeo.protocolArtifact_piDEC

/-- [Role: Theorem-Target] The runtime protocol-artifact checks all pass. -/
theorem allProtocolArtifactChecks_true :
  allProtocolArtifactChecks = true :=
  SuperNeo.allProtocolArtifactChecks_true

/-- [Role: Theorem-Target] The runtime checks reject the tampered protocol artifact. -/
theorem tamperedProtocolArtifactChecks_false :
  tamperedProtocolArtifactChecks = false :=
  SuperNeo.tamperedProtocolArtifactChecks_false

end ProtocolArtifactValidationInterface

end SuperNeo
