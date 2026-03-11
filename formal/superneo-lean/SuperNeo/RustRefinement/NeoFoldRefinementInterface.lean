import SuperNeo.RustRefinement.NeoFoldRefinement

/-!
Contract interface for `SuperNeo.RustRefinement.NeoFoldRefinement`.

Spec: `./formal/superneo-lean/specs/RustRefinement/NeoFoldRefinement.spec.md`
Paper: `./formal/superneo-lean/SuperNeo.pdf.md`
  - Rust refinement only: implementation-sidecar claims must conservatively
    refine the paper-core CE / Π_RLC / Π_DEC semantics.
-/

namespace SuperNeo

namespace RustRefinementInterface

/-- [Role: Theorem-Target] Paper-core CE claim view for Rust-exported claims. -/
abbrev PaperCEClaim := SuperNeo.RustRefinement.PaperCEClaim

/-- [Role: Theorem-Target] Implementation-only sidecar metadata on CE claims. -/
abbrev ImplCEClaimSidecar := SuperNeo.RustRefinement.ImplCEClaimSidecar

/-- [Role: Theorem-Target] Project a Rust-exported CE claim to its paper-core view. -/
abbrev projectPaperCEClaim := SuperNeo.RustRefinement.projectPaperCEClaim

/-- [Role: Theorem-Target] Extract the implementation-only CE sidecar metadata. -/
abbrev claimSidecar := SuperNeo.RustRefinement.claimSidecar

/-- [Role: Theorem-Target] Embed a paper-core CE claim into the implementation claim shape. -/
abbrev embedPaperCEClaim := SuperNeo.RustRefinement.embedPaperCEClaim

/-- [Role: Theorem-Target] Equality of paper-core CE claims after erasing sidecars. -/
abbrev samePaperCEClaim := SuperNeo.RustRefinement.samePaperCEClaim

/-- [Role: Theorem-Target] Projecting an embedded paper CE claim is identity. -/
theorem projectPaperCEClaim_embedPaperCEClaim
  (claim : PaperCEClaim) :
  projectPaperCEClaim (embedPaperCEClaim claim) = claim :=
  SuperNeo.RustRefinement.projectPaperCEClaim_embedPaperCEClaim claim

/-- [Role: Theorem-Target] Paper-core folding-lane view for Rust-exported lanes. -/
abbrev PaperFoldLane := SuperNeo.RustRefinement.PaperFoldLane

/-- [Role: Theorem-Target] Project a Rust-exported lane to its paper-core view. -/
abbrev projectPaperFoldLane := SuperNeo.RustRefinement.projectPaperFoldLane

/-- [Role: Theorem-Target] Equality of paper-core lanes after erasing sidecars. -/
abbrev samePaperFoldLane := SuperNeo.RustRefinement.samePaperFoldLane

/-- [Role: Theorem-Target] Embed a paper-core lane into the implementation lane shape. -/
abbrev embedPaperFoldLane := SuperNeo.RustRefinement.embedPaperFoldLane

/-- [Role: Theorem-Target] Projecting an embedded paper lane is identity. -/
theorem projectPaperFoldLane_embedPaperFoldLane
  (lane : PaperFoldLane) :
  projectPaperFoldLane (embedPaperFoldLane lane) = lane :=
  SuperNeo.RustRefinement.projectPaperFoldLane_embedPaperFoldLane lane

/-- [Role: Theorem-Target] CE refinement target shape. -/
abbrev CERefinementStatement := SuperNeo.RustRefinement.CERefinementStatement

/-- [Role: Theorem-Target] Implementation CE acceptance predicate from the Rust validator. -/
abbrev implCEAccepts := SuperNeo.RustRefinement.implCEAccepts

/-- [Role: Theorem-Target] Projected paper-core CE acceptance predicate. -/
abbrev paperCEAccepts := SuperNeo.RustRefinement.paperCEAccepts

/-- [Role: Theorem-Target] The Rust CE witness check is invariant under erasing sidecars. -/
theorem implCheckClaimCEFromWitness_sidecarInvariant
  (ccs : SuperNeo.Generated.NeoFoldCcsCase)
  (b : Nat)
  (claim : SuperNeo.Generated.NeoFoldClaimCase)
  (witness : Array (Array Nat)) :
  SuperNeo.implCheckClaimCEFromWitness ccs b claim witness =
    SuperNeo.implCheckClaimCEFromWitness ccs b (embedPaperCEClaim (projectPaperCEClaim claim)) witness :=
  SuperNeo.RustRefinement.implCheckClaimCEFromWitness_sidecarInvariant ccs b claim witness

/-- [Role: Theorem-Target] Concrete CE refinement theorem for the current Rust validator. -/
theorem implCEAccepts_refines_paperCEAccepts
  (ccs : SuperNeo.Generated.NeoFoldCcsCase)
  (b : Nat) :
  CERefinementStatement
    (implCEAccepts ccs b)
    (paperCEAccepts ccs b) :=
  SuperNeo.RustRefinement.implCEAccepts_refines_paperCEAccepts ccs b

/-- [Role: Theorem-Target] `Π_RLC` refinement target shape. -/
abbrev PiRLCRefinementStatement := SuperNeo.RustRefinement.PiRLCRefinementStatement

/-- [Role: Theorem-Target] Implementation-side `Π_RLC` parent acceptance predicate. -/
abbrev implPiRLCParentAccepts := SuperNeo.RustRefinement.implPiRLCParentAccepts

/-- [Role: Theorem-Target] Projected paper-core `Π_RLC` parent acceptance predicate. -/
abbrev paperPiRLCParentAccepts := SuperNeo.RustRefinement.paperPiRLCParentAccepts

/-- [Role: Theorem-Target] `Π_DEC` refinement target shape. -/
abbrev PiDECRefinementStatement := SuperNeo.RustRefinement.PiDECRefinementStatement

/-- [Role: Theorem-Target] Implementation-side `Π_DEC` parent acceptance predicate. -/
abbrev implPiDECParentAccepts := SuperNeo.RustRefinement.implPiDECParentAccepts

/-- [Role: Theorem-Target] Projected paper-core `Π_DEC` parent acceptance predicate. -/
abbrev paperPiDECParentAccepts := SuperNeo.RustRefinement.paperPiDECParentAccepts

/-- [Role: Theorem-Target] Full implementation-side folding-lane acceptance predicate. -/
abbrev implFoldLaneAccepts := SuperNeo.RustRefinement.implFoldLaneAccepts

/-- [Role: Theorem-Target] Full projected paper-core folding-lane acceptance predicate. -/
abbrev paperFoldLaneAccepts := SuperNeo.RustRefinement.paperFoldLaneAccepts

/-- [Role: Theorem-Target] Full folding-lane refinement target shape. -/
abbrev FoldLaneRefinementStatement := SuperNeo.RustRefinement.FoldLaneRefinementStatement

/-- [Role: Theorem-Target] Concrete `Π_RLC` parent refinement theorem. -/
theorem implPiRLCParentAccepts_refines_paperPiRLCParentAccepts
  (lane : SuperNeo.Generated.NeoFoldLaneCase) :
  implPiRLCParentAccepts lane →
    paperPiRLCParentAccepts (projectPaperFoldLane lane) :=
  SuperNeo.RustRefinement.implPiRLCParentAccepts_refines_paperPiRLCParentAccepts lane

/-- [Role: Theorem-Target] Concrete `Π_DEC` parent refinement theorem. -/
theorem implPiDECParentAccepts_refines_paperPiDECParentAccepts
  (kRho : Nat)
  (lane : SuperNeo.Generated.NeoFoldLaneCase) :
  implPiDECParentAccepts kRho lane →
    paperPiDECParentAccepts kRho (projectPaperFoldLane lane) :=
  SuperNeo.RustRefinement.implPiDECParentAccepts_refines_paperPiDECParentAccepts kRho lane

/-- [Role: Theorem-Target] Concrete full folding-lane refinement theorem. -/
theorem implFoldLaneAccepts_refines_paperFoldLaneAccepts
  (kRho : Nat) :
  FoldLaneRefinementStatement
    (implFoldLaneAccepts kRho)
    (paperFoldLaneAccepts kRho) :=
  SuperNeo.RustRefinement.implFoldLaneAccepts_refines_paperFoldLaneAccepts kRho

/-- [Role: Theorem-Target] Whole-artifact refinement target shape. -/
abbrev ArtifactRefinementStatement := SuperNeo.RustRefinement.ArtifactRefinementStatement

/-- [Role: Theorem-Target] Paper-core artifact obligations currently covered by the refinement layer. -/
abbrev paperArtifactCoreAccepts := SuperNeo.RustRefinement.paperArtifactCoreAccepts

/-- [Role: Theorem-Target] Projected per-step paper-core folding relation obligations. -/
abbrev paperArtifactStepRelationsAccepts := SuperNeo.RustRefinement.paperArtifactStepRelationsAccepts

/-- [Role: Theorem-Target] Strongest current whole-artifact paper-core obligations. -/
abbrev paperArtifactFullAccepts := SuperNeo.RustRefinement.paperArtifactFullAccepts

/-- [Role: Theorem-Target] Executable Boolean view of the strongest current paper-core artifact predicate. -/
abbrev paperArtifactFullChecks := SuperNeo.RustRefinement.paperArtifactFullChecks

/-- [Role: Theorem-Target] Boolean paper-core artifact checks imply the strongest current paper-core artifact proposition. -/
theorem paperArtifactFullChecks_implies_paperArtifactFullAccepts
  (artifact : SuperNeo.Generated.NeoFoldArtifactCase) :
  paperArtifactFullChecks artifact = true ->
    paperArtifactFullAccepts artifact :=
  SuperNeo.RustRefinement.paperArtifactFullChecks_implies_paperArtifactFullAccepts artifact

/--
[Role: Theorem-Target] Concrete whole-artifact core refinement theorem.

If the implementation artifact checker accepts, then the projected paper-core
chain and final exported-claim obligations hold.
-/
theorem implArtifactChecks_refines_paperArtifactCoreAccepts :
  ArtifactRefinementStatement
    (fun artifact => SuperNeo.implArtifactChecks artifact = true)
    paperArtifactCoreAccepts :=
  SuperNeo.RustRefinement.implArtifactChecks_refines_paperArtifactCoreAccepts

/--
[Role: Theorem-Target] Whole-artifact refinement theorem for projected
per-step folding relations.
-/
theorem implArtifactChecks_refines_paperArtifactStepRelationsAccepts :
  ArtifactRefinementStatement
    (fun artifact => SuperNeo.implArtifactChecks artifact = true)
    paperArtifactStepRelationsAccepts :=
  SuperNeo.RustRefinement.implArtifactChecks_refines_paperArtifactStepRelationsAccepts

/--
[Role: Theorem-Target] Strongest current whole-artifact refinement theorem.
-/
theorem implArtifactChecks_refines_paperArtifactFullAccepts :
  ArtifactRefinementStatement
    (fun artifact => SuperNeo.implArtifactChecks artifact = true)
    paperArtifactFullAccepts :=
  SuperNeo.RustRefinement.implArtifactChecks_refines_paperArtifactFullAccepts

/-- [Role: Theorem-Target] Boolean view of the strongest current paper-core refinement predicate over the generated valid `neo-fold` corpus. -/
abbrev generatedNeoFoldArtifactCases_paperArtifactFullChecks :=
  SuperNeo.RustRefinement.generatedNeoFoldArtifactCases_paperArtifactFullChecks

/-- [Role: Theorem-Target] Current paper-core session-glue obligations for exported `neo-fold` sessions. -/
abbrev paperSessionGlueAccepts := SuperNeo.RustRefinement.paperSessionGlueAccepts

/-- [Role: Theorem-Target] Whole-session refinement target shape for the Rust-only session layer. -/
abbrev SessionRefinementStatement := SuperNeo.RustRefinement.SessionRefinementStatement

/-- [Role: Theorem-Target] Executable Boolean view of the current paper-core session-glue predicate. -/
abbrev paperSessionGlueChecks := SuperNeo.RustRefinement.paperSessionGlueChecks

/-- [Role: Theorem-Target] Boolean session-glue checks imply the current session-glue proposition. -/
theorem paperSessionGlueChecks_implies_paperSessionGlueAccepts
  (session : SuperNeo.Generated.NeoFoldSessionCase) :
  paperSessionGlueChecks session = true ->
    paperSessionGlueAccepts session :=
  SuperNeo.RustRefinement.paperSessionGlueChecks_implies_paperSessionGlueAccepts session

/-- [Role: Theorem-Target] Concrete whole-session refinement theorem for the current Rust-only session validator. -/
theorem implSessionChecks_refines_paperSessionGlueAccepts :
  SessionRefinementStatement
    (fun session => SuperNeo.RustRefinement.neoFoldSessionChecks session = true)
    paperSessionGlueAccepts :=
  SuperNeo.RustRefinement.implSessionChecks_refines_paperSessionGlueAccepts

/-- [Role: Theorem-Target] Executable Boolean view of the current paper-core session-glue predicate over the generated session corpus. -/
abbrev generatedNeoFoldSessionCases_paperSessionGlueChecks :=
  SuperNeo.RustRefinement.generatedNeoFoldSessionCases_paperSessionGlueChecks

/-- [Role: Theorem-Target] Valid generated sessions satisfy the theorem-backed paper-core session-glue predicate. -/
abbrev validGeneratedNeoFoldSessionCases_paperSessionGlueChecks :=
  SuperNeo.RustRefinement.validGeneratedNeoFoldSessionCases_paperSessionGlueChecks

/-- [Role: Theorem-Target] Combined session-refinement corpus result over valid and tampered generated sessions. -/
abbrev generatedNeoFoldSessionRefinementChecks :=
  SuperNeo.RustRefinement.generatedNeoFoldSessionRefinementChecks

end RustRefinementInterface

end SuperNeo
