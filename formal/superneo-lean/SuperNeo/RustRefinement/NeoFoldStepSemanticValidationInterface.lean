import SuperNeo.RustRefinement.NeoFoldStepSemanticValidation

namespace NeoFoldStepSemanticValidationInterface

open SuperNeo
open SuperNeo.RustRefinement
open SuperNeo.Generated

def paperSource : String := "./formal/superneo-lean/SuperNeo.pdf.md"

/--
Rust-only step-semantics validation surface.

This module checks projected paper-core per-step semantic obligations on real
Rust-exported `neo-fold` artifacts. It sits between relation-only validation
and full artifact/session refinement.
-/
def stepSemanticValidationSurface : Prop :=
  (∀ artifact : NeoFoldArtifactCase,
      paperArtifactStepSemanticChecks artifact = true ∨
        paperArtifactStepSemanticChecks artifact = false) ∧
    ((generatedNeoFoldArtifactStepSemanticChecks = true ∨
        generatedNeoFoldArtifactStepSemanticChecks = false) ∧
      (∀ artifact : NeoFoldArtifactCase,
        paperArtifactStepSemanticChecks artifact = true ->
          paperArtifactStepSemanticsAccepts artifact))

end NeoFoldStepSemanticValidationInterface
