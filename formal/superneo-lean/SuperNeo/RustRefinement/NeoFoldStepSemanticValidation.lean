import SuperNeo.Generated.NeoFoldArtifacts
import SuperNeo.NeoFoldArtifactValidation

namespace SuperNeo

namespace RustRefinement

/--
Executable Boolean view of the projected paper-core per-step semantic
obligations for one exported `neo-fold` artifact.

This is stronger than the relation-only validator: it reuses the exported
current-step CE and witness-chain checks that the Rust artifact validator
already computes.
-/
def paperArtifactStepSemanticChecks (artifact : Generated.NeoFoldArtifactCase) : Bool :=
  (List.range artifact.steps.size).all fun idx =>
    SuperNeo.paperStepSemanticChecks artifact idx (artifact.steps[idx]!)

/--
If the executable Boolean projected step-semantic predicate holds, then every
step in the artifact satisfies the projected paper-core semantic obligations.
-/
def paperArtifactStepSemanticsAccepts
    (artifact : Generated.NeoFoldArtifactCase) : Prop :=
  ∀ idx, idx < artifact.steps.size →
    SuperNeo.paperStepSemanticChecks artifact idx (artifact.steps[idx]!) = true

theorem paperArtifactStepSemanticChecks_implies_paperArtifactStepSemanticsAccepts
    (artifact : Generated.NeoFoldArtifactCase) :
    paperArtifactStepSemanticChecks artifact = true ->
      paperArtifactStepSemanticsAccepts artifact := by
  intro hChecks idx hIdx
  simpa [paperArtifactStepSemanticChecks, List.all_eq_true] using hChecks idx hIdx

/--
Accepted implementation artifacts satisfy the executable projected paper-core
per-step semantic checks.
-/
theorem implArtifactChecks_implies_paperArtifactStepSemanticChecks
    (artifact : Generated.NeoFoldArtifactCase) :
    SuperNeo.implArtifactChecks artifact = true ->
      paperArtifactStepSemanticChecks artifact = true := by
  intro hAccept
  simp [paperArtifactStepSemanticChecks, List.all_eq_true]
  intro idx hIdx
  exact SuperNeo.implArtifactChecks_implies_paperStepSemanticChecks artifact idx hIdx hAccept

/--
Executable Boolean view of the projected paper-core per-step semantic checks
over the generated valid `neo-fold` artifact corpus.
-/
def generatedNeoFoldArtifactCases_paperStepSemanticChecks : Array Bool :=
  Generated.neoFoldArtifactCases.map paperArtifactStepSemanticChecks

/--
Corpus-level executable result for projected paper-core per-step semantic
checks over the generated valid `neo-fold` artifact corpus.
-/
def generatedNeoFoldArtifactStepSemanticChecks : Bool :=
  generatedNeoFoldArtifactCases_paperStepSemanticChecks.all id

end RustRefinement

end SuperNeo
