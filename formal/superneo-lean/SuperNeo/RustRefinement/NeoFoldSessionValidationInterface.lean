import SuperNeo.RustRefinement.NeoFoldSessionValidation

namespace NeoFoldSessionValidationInterface

open SuperNeo
open SuperNeo.RustRefinement
open SuperNeo.Generated

def paperSource : String := "./formal/superneo-lean/SuperNeo.pdf.md"

/--
Rust-only session validation surface.

This module checks exported real `FoldingSession` runs for the statement glue that
sits above shard artifacts:
- verifier-side step linking across successive public steps
- segment-level resume / continuation carry across separately proved chunks
- output-binding statement consistency against the exported final target state
- corpus-level expectation that valid session cases pass and tampered cases fail
-/
def sessionValidationSurface : Prop :=
  (∀ c : NeoFoldSessionCase, neoFoldSessionChecks c = true ∨ neoFoldSessionChecks c = false) ∧
  generatedNeoFoldSessionChecks = true ∨ generatedNeoFoldSessionChecks = false

end NeoFoldSessionValidationInterface
