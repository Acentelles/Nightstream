import SuperNeo.NeoFoldArtifactValidation

/-!
Contract interface for `SuperNeo.NeoFoldArtifactValidation`.

Spec: `./formal/superneo-lean/specs/NeoFoldArtifactValidation.spec.md`
Paper: `./formal/superneo-lean/SuperNeo.pdf.md`
  - Cross-check tooling: Lean validation of Rust-exported `neo-fold` proof artifacts.
-/

namespace SuperNeo

namespace NeoFoldArtifactValidationInterface

/-- [Role: Theorem-Target] Executable `neo-fold` artifact checks on the valid exported proof family. -/
abbrev allNeoFoldArtifactChecks := SuperNeo.allNeoFoldArtifactChecks

/-- [Role: Theorem-Target] Executable `neo-fold` artifact checks on the tampered exported proof family. -/
abbrev tamperedNeoFoldArtifactChecks := SuperNeo.tamperedNeoFoldArtifactChecks

/-- [Role: Theorem-Target] The valid exported `neo-fold` artifact family passes Lean validation. -/
theorem allNeoFoldArtifactChecks_true :
  allNeoFoldArtifactChecks = true :=
  SuperNeo.allNeoFoldArtifactChecks_true

/-- [Role: Theorem-Target] The tampered exported `neo-fold` artifact family fails Lean validation. -/
theorem tamperedNeoFoldArtifactChecks_false :
  tamperedNeoFoldArtifactChecks = false :=
  SuperNeo.tamperedNeoFoldArtifactChecks_false

end NeoFoldArtifactValidationInterface

end SuperNeo
