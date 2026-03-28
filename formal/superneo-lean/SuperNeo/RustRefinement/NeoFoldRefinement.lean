import SuperNeo.Generated.NeoFoldArtifactsCases
import SuperNeo.NeoFoldArtifactValidation
import SuperNeo.Generated.NeoFoldSessionsCases
import SuperNeo.RustRefinement.NeoFoldSessionValidation

namespace SuperNeo

namespace RustRefinement

open SuperNeo.Generated

/--
Paper-core CE claim view for Rust-exported `neo-fold` claims.

This erases implementation-sidecar metadata and keeps only the fields that
participate in the paper-level CE / folding relations.
-/
structure PaperCEClaim where
  commitment : NeoFoldCommitmentCase
  r : Array KNat
  sCol : Array KNat
  mIn : Nat
  xColIndices : Array Nat
  x : Array (Array Nat)
  yRing : Array (Array KNat)
  ct : Array KNat
  auxOpenings : Array KNat
  yZcol : Array KNat
deriving Repr, Inhabited, DecidableEq

/-- Rust-implementation sidecar metadata that is not part of the paper CE claim. -/
structure ImplCEClaimSidecar where
  foldDigest : Array Nat
  cStepCoords : Array Nat
  uOffset : Nat
  uLen : Nat
deriving Repr, Inhabited, DecidableEq

/-- Project a Rust-exported CE claim to its paper-core CE claim view. -/
def projectPaperCEClaim (claim : NeoFoldClaimCase) : PaperCEClaim :=
  { commitment := claim.commitment
    r := claim.r
    sCol := claim.sCol
    mIn := claim.mIn
    xColIndices := claim.xColIndices
    x := claim.x
    yRing := claim.yRing
    ct := claim.ct
    auxOpenings := claim.auxOpenings
    yZcol := claim.yZcol }

/-- Extract the implementation-only CE sidecar metadata. -/
def claimSidecar (claim : NeoFoldClaimCase) : ImplCEClaimSidecar :=
  { foldDigest := claim.foldDigest
    cStepCoords := claim.cStepCoords
    uOffset := claim.uOffset
    uLen := claim.uLen }

private def refToF (x : Nat) : F := F.ofNat x

private def refToKArray (xs : Array KNat) : Array KExt :=
  xs.map fun k => KExt.ofKNat k

private def refTakeDFieldCoeffs (row : Array Nat) : Coeffs :=
  Array.ofFn fun i : Fin D =>
    if h : i.1 < row.size then
      refToF row[i.1]
    else
      0

/--
Embed a paper-core CE claim back into the implementation claim shape by filling
implementation-only sidecars with canonical defaults.

This is used only in the Rust-refinement layer. It is not a paper object.
-/
def embedPaperCEClaim (claim : PaperCEClaim) : NeoFoldClaimCase :=
  { commitment := claim.commitment
    r := claim.r
    sCol := claim.sCol
    mIn := claim.mIn
    xColIndices := claim.xColIndices
    x := claim.x
    yRing := claim.yRing
    ct := claim.ct
    auxOpenings := claim.auxOpenings
    yZcol := claim.yZcol
    foldDigest := #[]
    cStepCoords := #[]
    uOffset := 0
    uLen := 0 }

/-- Equality of paper-core CE claims after erasing implementation sidecars. -/
def samePaperCEClaim (lhs rhs : NeoFoldClaimCase) : Prop :=
  projectPaperCEClaim lhs = projectPaperCEClaim rhs

/-- Projecting an embedded paper claim recovers the original paper claim. -/
@[simp] theorem projectPaperCEClaim_embedPaperCEClaim
  (claim : PaperCEClaim) :
  projectPaperCEClaim (embedPaperCEClaim claim) = claim := by
  rfl

/--
Implementation CE acceptance predicate from the Rust artifact validator.

This is intentionally phrased in the refinement layer so the conservative
extension statements remain separate from the paper modules.
-/
def implCEAccepts
  (ccs : NeoFoldCcsCase)
  (b : Nat)
  (claim : NeoFoldClaimCase)
  (witness : Array (Array Nat)) : Prop :=
  SuperNeo.implCheckClaimCEFromWitness ccs b claim witness = true

/--
Paper-core CE acceptance predicate induced by the implementation CE witness
check after erasing sidecars.

This is not a replacement for the paper theorem. It is the projected
paper-core acceptance predicate used by the Rust-refinement layer.
-/
def paperCEAccepts
  (ccs : NeoFoldCcsCase)
  (b : Nat)
  (claim : PaperCEClaim)
  (witness : Array (Array Nat)) : Prop :=
  SuperNeo.implCheckClaimCEFromWitness ccs b (embedPaperCEClaim claim) witness = true

/--
The implementation CE witness check is invariant under erasing the
implementation-only CE sidecars.
-/
theorem implCheckClaimCEFromWitness_sidecarInvariant
  (ccs : NeoFoldCcsCase)
  (b : Nat)
  (claim : NeoFoldClaimCase)
  (witness : Array (Array Nat)) :
  SuperNeo.implCheckClaimCEFromWitness ccs b claim witness =
    SuperNeo.implCheckClaimCEFromWitness ccs b (embedPaperCEClaim (projectPaperCEClaim claim)) witness := by
  rfl

/--
Paper-core `Π_RLC` / `Π_DEC` lane view for Rust-exported lane artifacts.

This keeps the paper-facing lane data and erases claim sidecars transitively via
`projectPaperCEClaim`.
-/
structure PaperFoldLane where
  ccs : NeoFoldCcsCase
  foldBase : Nat
  inputs : Array PaperCEClaim
  rhoCount : Nat
  rhoCoeffs : Array (Array Nat)
  parent : PaperCEClaim
  children : Array PaperCEClaim
deriving Repr, Inhabited, DecidableEq

/-- Project a Rust-exported lane to its paper-core folding lane view. -/
def projectPaperFoldLane (lane : NeoFoldLaneCase) : PaperFoldLane :=
  { ccs := lane.ccs
    foldBase := lane.foldBase
    inputs := lane.inputs.map projectPaperCEClaim
    rhoCount := lane.rhoCount
    rhoCoeffs := lane.rhoCoeffs
    parent := projectPaperCEClaim lane.parent
    children := lane.children.map projectPaperCEClaim }

/-- Equality of paper-core lane views after erasing implementation sidecars. -/
def samePaperFoldLane (lhs rhs : NeoFoldLaneCase) : Prop :=
  projectPaperFoldLane lhs = projectPaperFoldLane rhs

/--
Embed a paper-core folding lane back into the implementation lane shape by
filling implementation-only claim sidecars with canonical defaults.

This is used only in the Rust-refinement layer. It is not a paper object.
-/
def embedPaperFoldLane (lane : PaperFoldLane) : NeoFoldLaneCase :=
  { ccs := lane.ccs
    foldBase := lane.foldBase
    inputs := lane.inputs.map embedPaperCEClaim
    rhoCount := lane.rhoCount
    rhoCoeffs := lane.rhoCoeffs
    parent := embedPaperCEClaim lane.parent
    children := lane.children.map embedPaperCEClaim }

/-- Projecting an embedded paper lane recovers the original paper lane. -/
@[simp] theorem projectPaperFoldLane_embedPaperFoldLane
  (lane : PaperFoldLane) :
  projectPaperFoldLane (embedPaperFoldLane lane) = lane := by
  cases lane with
  | mk ccs foldBase inputs rhoCount rhoCoeffs parent children =>
      have hMap :
          (projectPaperCEClaim ∘ embedPaperCEClaim) = id := by
        funext claim
        simp [Function.comp]
      have hInputs :
          Array.map (projectPaperCEClaim ∘ embedPaperCEClaim) inputs = inputs := by
        calc
          Array.map (projectPaperCEClaim ∘ embedPaperCEClaim) inputs
              = Array.map id inputs := by simpa [hMap]
          _ = inputs := by simp
      have hChildren :
          Array.map (projectPaperCEClaim ∘ embedPaperCEClaim) children = children := by
        calc
          Array.map (projectPaperCEClaim ∘ embedPaperCEClaim) children
              = Array.map id children := by simpa [hMap]
          _ = children := by simp
      simp [projectPaperFoldLane, embedPaperFoldLane, hInputs, hChildren]

/-- Embedding the projected paper lane matches validator-side sidecar erasure. -/
@[simp] theorem embedProjectPaperFoldLane_eq_normalizeLaneSidecars
  (lane : NeoFoldLaneCase) :
  embedPaperFoldLane (projectPaperFoldLane lane) = SuperNeo.normalizeLaneSidecars lane := by
  cases lane
  simp [embedPaperFoldLane, projectPaperFoldLane, SuperNeo.normalizeLaneSidecars,
    SuperNeo.normalizeClaimSidecars, embedPaperCEClaim, projectPaperCEClaim]

/--
Paper-core CE refinement target.

Any future implementation-level CE acceptance predicate must imply acceptance of
the projected paper-core CE claim.
-/
def CERefinementStatement
  (implCEAccept : NeoFoldClaimCase -> Array (Array Nat) -> Prop)
  (paperCEAccept : PaperCEClaim -> Array (Array Nat) -> Prop) : Prop :=
  ∀ claim witness,
    implCEAccept claim witness →
      paperCEAccept (projectPaperCEClaim claim) witness

/--
Concrete CE refinement theorem for the current Rust artifact validator.

If the implementation-level CE witness check accepts a Rust-exported claim,
then the projected paper-core CE claim also accepts under the induced
paper-core acceptance predicate.
-/
theorem implCEAccepts_refines_paperCEAccepts
  (ccs : NeoFoldCcsCase)
  (b : Nat) :
  CERefinementStatement
    (implCEAccepts ccs b)
    (paperCEAccepts ccs b) := by
  intro claim witness hAccept
  unfold implCEAccepts at hAccept
  unfold paperCEAccepts
  simpa [implCheckClaimCEFromWitness_sidecarInvariant] using hAccept

/--
Paper-core `Π_RLC` refinement target.

Any future implementation-level `Π_RLC` acceptance predicate must imply
acceptance of the projected paper-core lane relation.
-/
def PiRLCRefinementStatement
  (implPiRLCAccept : NeoFoldLaneCase -> NeoFoldLaneWitnessCase -> Prop)
  (paperPiRLCAccept : PaperFoldLane -> NeoFoldLaneWitnessCase -> Prop) : Prop :=
  ∀ lane chain,
    implPiRLCAccept lane chain →
      paperPiRLCAccept (projectPaperFoldLane lane) chain

/--
Implementation-side `Π_RLC` parent acceptance predicate from the Rust
`neo-fold` artifact validator.
-/
def implPiRLCParentAccepts (lane : NeoFoldLaneCase) : Prop :=
  SuperNeo.implRlcParentChecks lane = true

/--
Projected paper-core `Π_RLC` parent acceptance predicate induced by the
implementation core parent check after erasing claim sidecars.
-/
def paperPiRLCParentAccepts (lane : PaperFoldLane) : Prop :=
  SuperNeo.implRlcParentCoreChecks (embedPaperFoldLane lane) = true

/--
Concrete `Π_RLC` parent refinement theorem for the current Rust artifact
validator.

If the implementation-level `Π_RLC` parent predicate accepts a Rust-exported
lane, then the projected paper-core lane also satisfies the induced paper-core
parent predicate.
-/
theorem implPiRLCParentAccepts_refines_paperPiRLCParentAccepts :
    ∀ lane,
      implPiRLCParentAccepts lane →
        paperPiRLCParentAccepts (projectPaperFoldLane lane) := by
  intro lane hAccept
  unfold implPiRLCParentAccepts at hAccept
  unfold paperPiRLCParentAccepts
  simpa [embedProjectPaperFoldLane_eq_normalizeLaneSidecars] using
    (SuperNeo.implRlcParentChecks_implies_core lane hAccept)

/--
Paper-core `Π_DEC` refinement target.

Any future implementation-level `Π_DEC` acceptance predicate must imply
acceptance of the projected paper-core lane relation.
-/
def PiDECRefinementStatement
  (implPiDECAccept : NeoFoldLaneCase -> NeoFoldLaneWitnessCase -> Prop)
  (paperPiDECAccept : PaperFoldLane -> NeoFoldLaneWitnessCase -> Prop) : Prop :=
  ∀ lane chain,
    implPiDECAccept lane chain →
      paperPiDECAccept (projectPaperFoldLane lane) chain

/--
Implementation-side `Π_DEC` parent acceptance predicate from the Rust
`neo-fold` artifact validator.
-/
def implPiDECParentAccepts (kRho : Nat) (lane : NeoFoldLaneCase) : Prop :=
  SuperNeo.implDecParentChecks kRho lane = true

/--
Projected paper-core `Π_DEC` parent acceptance predicate induced by the
implementation core parent check after erasing claim sidecars.
-/
def paperPiDECParentAccepts (kRho : Nat) (lane : PaperFoldLane) : Prop :=
  SuperNeo.implDecParentCoreChecks kRho (embedPaperFoldLane lane) = true

/--
Concrete `Π_DEC` parent refinement theorem for the current Rust artifact
validator.

If the implementation-level `Π_DEC` parent predicate accepts a Rust-exported
lane, then the projected paper-core lane also satisfies the induced paper-core
parent predicate.
-/
theorem implPiDECParentAccepts_refines_paperPiDECParentAccepts
    (kRho : Nat) :
    ∀ lane,
      implPiDECParentAccepts kRho lane →
        paperPiDECParentAccepts kRho (projectPaperFoldLane lane) := by
  intro lane hAccept
  unfold implPiDECParentAccepts at hAccept
  unfold paperPiDECParentAccepts
  simpa [embedProjectPaperFoldLane_eq_normalizeLaneSidecars] using
    (SuperNeo.implDecParentChecks_implies_core kRho lane hAccept)

/--
Implementation-side full folding-lane acceptance predicate from the Rust
artifact validator.
-/
def implFoldLaneAccepts (kRho : Nat) (lane : NeoFoldLaneCase) : Prop :=
  SuperNeo.implFoldLaneChecks kRho lane = true

/--
Projected paper-core full folding-lane acceptance predicate induced by the
implementation parent checks after erasing Rust-only sidecars.
-/
def paperFoldLaneAccepts (kRho : Nat) (lane : PaperFoldLane) : Prop :=
  paperPiRLCParentAccepts lane ∧ paperPiDECParentAccepts kRho lane

/--
Paper-core full folding-lane refinement target.

Any future implementation-level full folding-lane acceptance predicate must
imply the projected paper-core `Π_RLC` and `Π_DEC` parent predicates.
-/
def FoldLaneRefinementStatement
  (implFoldLaneAccept : NeoFoldLaneCase -> Prop)
  (paperFoldLaneAccept : PaperFoldLane -> Prop) : Prop :=
  ∀ lane,
    implFoldLaneAccept lane →
      paperFoldLaneAccept (projectPaperFoldLane lane)

/--
Concrete full folding-lane refinement theorem for the current Rust artifact
validator.

If the implementation-level folding-lane predicate accepts a Rust-exported
lane, then the projected paper-core lane satisfies both induced paper-core
`Π_RLC` and `Π_DEC` parent predicates.
-/
theorem implFoldLaneAccepts_refines_paperFoldLaneAccepts
    (kRho : Nat) :
    FoldLaneRefinementStatement
      (implFoldLaneAccepts kRho)
      (paperFoldLaneAccepts kRho) := by
  intro lane hAccept
  constructor
  · exact implPiRLCParentAccepts_refines_paperPiRLCParentAccepts lane
      (SuperNeo.implFoldLaneChecks_implies_rlcParentChecks kRho lane hAccept)
  · exact implPiDECParentAccepts_refines_paperPiDECParentAccepts kRho lane
      (SuperNeo.implFoldLaneChecks_implies_decParentChecks kRho lane hAccept)

/--
Whole-artifact refinement target.

The implementation-level `neo-fold` artifact acceptance predicate must imply
the corresponding paper-core acceptance predicate after erasing implementation
sidecars throughout the artifact.
-/
def ArtifactRefinementStatement
  (implArtifactAccept : NeoFoldArtifactCase -> Prop)
  (paperArtifactAccept : NeoFoldArtifactCase -> Prop) : Prop :=
  ∀ artifact,
    implArtifactAccept artifact →
      paperArtifactAccept artifact

/--
Paper-core artifact obligations currently covered by the Rust refinement layer.

This intentionally tracks only the exported chain/final obligations after
erasing Rust-only sidecars. It does not change the paper-semantic theorem
modules.
-/
def paperArtifactCoreAccepts (artifact : NeoFoldArtifactCase) : Prop :=
  SuperNeo.paperChainChecks artifact ∧
    SuperNeo.paperFinalObligationChecks artifact

/--
Paper-core per-step folding relation obligations for one Rust-exported artifact.

This packages the projected per-step lane relations after erasing Rust-only
claim sidecars.
-/
def paperArtifactStepRelationsAccepts (artifact : NeoFoldArtifactCase) : Prop :=
  ∀ idx, idx < artifact.steps.size →
    SuperNeo.paperStepRelationChecks artifact idx (artifact.steps[idx]!) = true

/--
Strongest whole-artifact paper-core predicate currently covered by the Rust
refinement layer.

This combines:
- projected chain/final obligations,
- projected per-step folding relation obligations.
-/
def paperArtifactFullAccepts (artifact : NeoFoldArtifactCase) : Prop :=
  paperArtifactCoreAccepts artifact ∧
    paperArtifactStepRelationsAccepts artifact

/--
First whole-artifact conservative-extension theorem for Rust-exported
`neo-fold` artifacts.

If the full implementation artifact checker accepts, then the projected
paper-core chain and final exported-claim obligations also hold.
-/
theorem implArtifactChecks_refines_paperArtifactCoreAccepts :
    ArtifactRefinementStatement
      (fun artifact => SuperNeo.implArtifactChecks artifact = true)
      paperArtifactCoreAccepts := by
  intro artifact hAccept
  constructor
  · exact SuperNeo.chainChecks_implies_paperChainChecks artifact
      (SuperNeo.implArtifactChecks_implies_chainChecks artifact hAccept)
  · exact SuperNeo.finalObligationChecks_implies_paperFinalObligationChecks artifact
      (SuperNeo.implArtifactChecks_implies_finalObligationChecks artifact hAccept)

/--
Whole-artifact refinement theorem for the projected per-step folding relation
layer.
-/
theorem implArtifactChecks_refines_paperArtifactStepRelationsAccepts :
    ArtifactRefinementStatement
      (fun artifact => SuperNeo.implArtifactChecks artifact = true)
      paperArtifactStepRelationsAccepts := by
  intro artifact hAccept idx hIdx
  exact SuperNeo.implArtifactChecks_implies_paperStepRelationChecks artifact idx hIdx hAccept

/--
Strongest current whole-artifact conservative-extension theorem for
Rust-exported `neo-fold` artifacts.

If the implementation artifact checker accepts, then the projected paper-core
chain/final obligations and per-step folding relations all hold.
-/
theorem implArtifactChecks_refines_paperArtifactFullAccepts :
    ArtifactRefinementStatement
      (fun artifact => SuperNeo.implArtifactChecks artifact = true)
      paperArtifactFullAccepts := by
  intro artifact hAccept
  constructor
  · exact implArtifactChecks_refines_paperArtifactCoreAccepts artifact hAccept
  · exact implArtifactChecks_refines_paperArtifactStepRelationsAccepts
      artifact hAccept

/--
Executable Boolean view of the strongest current paper-core artifact predicate.
-/
def paperArtifactFullChecks (artifact : NeoFoldArtifactCase) : Bool :=
  SuperNeo.paperChainChecks artifact &&
    SuperNeo.paperFinalObligationChecks artifact &&
    (List.range artifact.steps.size).all fun idx =>
      SuperNeo.paperStepRelationChecks artifact idx (artifact.steps[idx]!)

/--
If the executable Boolean paper-core artifact predicate holds, then the
strongest current paper-core artifact proposition also holds.
-/
theorem paperArtifactFullChecks_implies_paperArtifactFullAccepts
    (artifact : NeoFoldArtifactCase) :
    paperArtifactFullChecks artifact = true ->
      paperArtifactFullAccepts artifact := by
  intro hChecks
  have hDecomp :
      (SuperNeo.paperChainChecks artifact = true ∧
          SuperNeo.paperFinalObligationChecks artifact = true) ∧
        (List.range artifact.steps.size).all
          (fun idx => SuperNeo.paperStepRelationChecks artifact idx (artifact.steps[idx]!)) = true := by
    simpa [paperArtifactFullChecks] using hChecks
  let hChain := hDecomp.1.1
  let hFinal := hDecomp.1.2
  let hSteps := hDecomp.2
  constructor
  · exact ⟨hChain, hFinal⟩
  · simpa [paperArtifactStepRelationsAccepts, List.all_eq_true] using hSteps

/--
Boolean view of the strongest current paper-core refinement predicate over the
generated valid `neo-fold` corpus.

This is intended for executable validation and CI reporting inside the Rust
refinement layer.
-/
def generatedNeoFoldArtifactCases_paperArtifactFullChecks : Array Bool :=
  Generated.neoFoldArtifactCases.map paperArtifactFullChecks

/--
Paper-core session-glue obligations currently covered by the Rust refinement
layer.

This captures the session-level statement glue that sits above individual shard
artifacts:
- public-step shape,
- step linking,
- resumed-segment carry for the main accumulator,
- output-binding statement consistency.
-/
def paperSessionGlueAccepts (session : NeoFoldSessionCase) : Prop :=
  ((SuperNeo.RustRefinement.sessionShapeChecks session = true ∧
      SuperNeo.RustRefinement.sessionSegmentCarryChecks session = true) ∧
    SuperNeo.RustRefinement.sessionStepLinkChecks session = true) ∧
    SuperNeo.RustRefinement.sessionOutputBindingChecks session = true

/-- Whole-session refinement target for the current Rust-only session layer. -/
def SessionRefinementStatement
  (implSessionAccept : NeoFoldSessionCase -> Prop)
  (paperSessionAccept : NeoFoldSessionCase -> Prop) : Prop :=
  ∀ session,
    implSessionAccept session →
      paperSessionAccept session

/-- Executable Boolean view of the current paper-core session-glue predicate. -/
def paperSessionGlueChecks (session : NeoFoldSessionCase) : Bool :=
  SuperNeo.RustRefinement.sessionShapeChecks session &&
    SuperNeo.RustRefinement.sessionSegmentCarryChecks session &&
    SuperNeo.RustRefinement.sessionStepLinkChecks session &&
    SuperNeo.RustRefinement.sessionOutputBindingChecks session

/-- The executable session-glue Boolean lifts to the current session-glue proposition. -/
theorem paperSessionGlueChecks_implies_paperSessionGlueAccepts
    (session : NeoFoldSessionCase) :
    paperSessionGlueChecks session = true ->
      paperSessionGlueAccepts session := by
  intro hChecks
  simpa [paperSessionGlueAccepts, paperSessionGlueChecks, Bool.and_eq_true, and_assoc] using hChecks

/--
Concrete whole-session refinement theorem for the current Rust-only session
validator.

If the implementation session checker accepts, then the current paper-core
session-glue obligations hold for that exported session.
-/
theorem implSessionChecks_refines_paperSessionGlueAccepts :
    SessionRefinementStatement
      (fun session => SuperNeo.RustRefinement.neoFoldSessionChecks session = true)
      paperSessionGlueAccepts := by
  intro session hAccept
  simpa [SessionRefinementStatement, paperSessionGlueAccepts,
    SuperNeo.RustRefinement.neoFoldSessionChecks, Bool.and_eq_true, and_assoc] using hAccept

/--
Executable Boolean view of the current paper-core session-glue predicate over
the generated session corpus.
-/
def generatedNeoFoldSessionCases_paperSessionGlueChecks : Array Bool :=
  Generated.neoFoldSessionCases.map paperSessionGlueChecks

/--
Executable Boolean view of the theorem-backed session-glue refinement result
over the generated valid session corpus.

Tampered session cases are excluded here; their rejection remains part of the
implementation-side session validator.
-/
def validGeneratedNeoFoldSessionCases_paperSessionGlueChecks : Bool :=
  (List.range Generated.neoFoldSessionCases.size).all fun idx =>
    let session := Generated.neoFoldSessionCases[idx]!
    if session.shouldFail then
      true
    else
      paperSessionGlueChecks session

/--
Combined session-refinement corpus result.

This requires:
- all valid generated sessions satisfy the theorem-backed paper-core
  session-glue predicate, and
- all tampered generated sessions are rejected by the implementation session
  validator.
-/
def generatedNeoFoldSessionRefinementChecks : Bool :=
  validGeneratedNeoFoldSessionCases_paperSessionGlueChecks &&
    SuperNeo.RustRefinement.tamperedNeoFoldSessionCasesAllReject

end RustRefinement

end SuperNeo
