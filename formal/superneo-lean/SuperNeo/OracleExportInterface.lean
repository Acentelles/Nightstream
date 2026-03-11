import SuperNeo.OracleExport

/-!
Contract interface for `SuperNeo.OracleExport`.

Spec: `./formal/superneo-lean/specs/OracleExport.spec.md`
Paper: `./formal/superneo-lean/SuperNeo.pdf.md`
  - Cross-check tooling: deterministic Lean-authored oracle export for Rust conformance.
-/

namespace SuperNeo

namespace OracleExportInterface

/-- [Role: Theorem-Target] Deterministically export all Lean-authored JSON oracle families. -/
abbrev exportOracleFiles := SuperNeo.exportOracleFiles

end OracleExportInterface

end SuperNeo
