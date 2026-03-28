import SuperNeo.Generated.NeoFoldArtifacts
import SuperNeo.NeoFoldArtifactValidation
import SuperNeo.RustRefinement.NeoFoldRefinement

namespace SuperNeo

namespace RustRefinement

/--
Executable Boolean view of the projected paper-core per-step folding relation
obligations for one exported `neo-fold` artifact.
-/
def paperArtifactRelationChecks (artifact : Generated.NeoFoldArtifactCase) : Bool :=
  (List.range artifact.steps.size).all fun idx =>
    SuperNeo.paperStepRelationChecks artifact idx (artifact.steps[idx]!)

/--
If the executable Boolean projected relation predicate holds, then the
paper-core per-step folding relation proposition holds.
-/
theorem paperArtifactRelationChecks_implies_paperArtifactStepRelationsAccepts
    (artifact : Generated.NeoFoldArtifactCase) :
    paperArtifactRelationChecks artifact = true ->
      paperArtifactStepRelationsAccepts artifact := by
  intro hChecks
  simpa [paperArtifactRelationChecks, paperArtifactStepRelationsAccepts, List.all_eq_true]
    using hChecks

/--
Accepted implementation artifacts satisfy the executable projected paper-core
per-step folding relation checks.
-/
theorem implArtifactChecks_implies_paperArtifactRelationChecks
    (artifact : Generated.NeoFoldArtifactCase) :
    SuperNeo.implArtifactChecks artifact = true ->
      paperArtifactRelationChecks artifact = true := by
  intro hAccept
  have hProp :
      paperArtifactStepRelationsAccepts artifact :=
    implArtifactChecks_refines_paperArtifactStepRelationsAccepts artifact hAccept
  simpa [paperArtifactRelationChecks, paperArtifactStepRelationsAccepts, List.all_eq_true]
    using hProp

/--
Executable Boolean view of the projected paper-core per-step folding relation
checks over the generated valid `neo-fold` artifact corpus.
-/
def generatedNeoFoldArtifactCases_paperRelationChecks : Array Bool :=
  Generated.neoFoldArtifactCases.map paperArtifactRelationChecks

/--
Corpus-level executable result for projected paper-core per-step folding
relations over the generated valid `neo-fold` artifact corpus.
-/
def generatedNeoFoldArtifactRelationChecks : Bool :=
  generatedNeoFoldArtifactCases_paperRelationChecks.all id

/--
Executable Boolean view of the projected paper-core per-step folding relation
checks over the generated valid `neo-fold` artifact corpus.

This is the right corpus-level signal for real exported artifacts whose
projected paper-core step relations hold even when the stronger implementation
artifact acceptance predicate is intentionally stricter.
-/
def generatedNeoFoldArtifactCases_relationRefinementChecks : Array Bool :=
  generatedNeoFoldArtifactCases_paperRelationChecks

/--
Corpus-level executable result for projected paper-core per-step folding
relations over the generated valid `neo-fold` artifact corpus.
-/
def generatedNeoFoldArtifactRelationRefinementChecks : Bool :=
  generatedNeoFoldArtifactRelationChecks

end RustRefinement

end SuperNeo
