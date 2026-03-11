import SuperNeo.RustRefinement.NeoFoldRelationValidation

namespace NeoFoldRelationValidationInterface

open SuperNeo
open SuperNeo.RustRefinement
open SuperNeo.Generated

def paperSource : String := "./formal/superneo-lean/SuperNeo.pdf.md"

/--
Rust-only relation validation surface.

This module checks projected paper-core per-step folding relation obligations on
real Rust-exported `neo-fold` artifacts.
-/
def relationValidationSurface : Prop :=
  (∀ artifact : NeoFoldArtifactCase,
      paperArtifactRelationChecks artifact = true ∨
        paperArtifactRelationChecks artifact = false) ∧
    ((generatedNeoFoldArtifactRelationChecks = true ∨
        generatedNeoFoldArtifactRelationChecks = false) ∧
      (generatedNeoFoldArtifactRelationRefinementChecks = true ∨
        generatedNeoFoldArtifactRelationRefinementChecks = false))

end NeoFoldRelationValidationInterface
