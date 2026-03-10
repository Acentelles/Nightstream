namespace SuperNeo.Generated

structure KNat where
  c0 : Nat
  c1 : Nat
deriving Repr, Inhabited, DecidableEq

structure NeoFoldSparseEntryCase where
  row : Nat
  col : Nat
  value : Nat
deriving Repr, Inhabited, DecidableEq

structure NeoFoldCcsMatrixCase where
  nrows : Nat
  ncols : Nat
  identity : Bool
  entries : Array NeoFoldSparseEntryCase
deriving Repr, Inhabited, DecidableEq

structure NeoFoldPolyTermCase where
  coeff : Nat
  exps : Array Nat
deriving Repr, Inhabited, DecidableEq

structure NeoFoldCcsCase where
  n : Nat
  m : Nat
  matrices : Array NeoFoldCcsMatrixCase
  polyTerms : Array NeoFoldPolyTermCase
deriving Repr, Inhabited, DecidableEq

structure NeoFoldCommitmentCase where
  cols : Array (Array Nat)
deriving Repr, Inhabited, DecidableEq

structure NeoFoldTranscriptCase where
  claimedSum : KNat
  degreeBound : Nat
  roundPolys : Array (Array KNat)
  challenges : Array KNat
  finalSum : KNat
deriving Repr, Inhabited, DecidableEq

structure NeoFoldBatchedTimeCase where
  claimedSums : Array KNat
  degreeBounds : Array Nat
  labels : Array String
  roundPolys : Array (Array (Array KNat))
  sharedChallenges : Array KNat
deriving Repr, Inhabited, DecidableEq

structure NeoFoldClaimCase where
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
  foldDigest : Array Nat
  cStepCoords : Array Nat
  uOffset : Nat
  uLen : Nat
deriving Repr, Inhabited, DecidableEq

structure NeoFoldLaneCase where
  ccs : NeoFoldCcsCase
  foldBase : Nat
  inputs : Array NeoFoldClaimCase
  rhoCount : Nat
  rhoCoeffs : Array (Array Nat)
  parent : NeoFoldClaimCase
  children : Array NeoFoldClaimCase
deriving Repr, Inhabited, DecidableEq

structure NeoFoldLaneWitnessCase where
  inputWitnessZ : Array (Array (Array Nat))
  parentWitnessZ : Array (Array Nat)
  childWitnessZ : Array (Array (Array Nat))
deriving Repr, Inhabited, DecidableEq

structure NeoFoldSegmentMetaCase where
  routeA : Bool
  publicSteps : Nat
  proofSteps : Nat
deriving Repr, Inhabited, DecidableEq

structure NeoFoldStepArtifactCase where
  routeA : Bool
  compressedSubsteps : Nat
  mcsBatchPublicInput : Array (Array Nat)
  mcsBatchPrivateInput : Array (Array Nat)
  mcsBatchWitnessZ : Array (Array (Array Nat))
  mcsBatchCommitments : Array NeoFoldCommitmentCase
  mcsPublicInput : Array Nat
  mcsPrivateInput : Array Nat
  mcsWitnessZ : Array (Array Nat)
  mcsCommitment : NeoFoldCommitmentCase
  piCcs : NeoFoldTranscriptCase
  piCcsNc : NeoFoldTranscriptCase
  cpuSumcheck : NeoFoldTranscriptCase
  shiftSumcheck : NeoFoldTranscriptCase
  batchedTime : NeoFoldBatchedTimeCase
  ccsOut : Array NeoFoldClaimCase
  mainLane : NeoFoldLaneCase
  mainLaneInputWitnessZ : Array (Array (Array Nat))
  mainLaneParentWitnessZ : Array (Array Nat)
  mainLaneChildWitnessZ : Array (Array (Array Nat))
  valLaneWitnesses : Array NeoFoldLaneWitnessCase
  valInputs : Array NeoFoldClaimCase
  valLanes : Array NeoFoldLaneCase
  wbLaneWitnesses : Array NeoFoldLaneWitnessCase
  wbInputs : Array NeoFoldClaimCase
  wbLanes : Array NeoFoldLaneCase
  wpLaneWitnesses : Array NeoFoldLaneWitnessCase
  wpInputs : Array NeoFoldClaimCase
  wpLanes : Array NeoFoldLaneCase
  stage8Lanes : Array NeoFoldLaneCase
deriving Repr, Inhabited, DecidableEq

structure NeoFoldArtifactCase where
  scenarioName : String
  shouldFail : Bool
  foldBase : Nat
  kRho : Nat
  publicStepCount : Nat
  proofStepCount : Nat
  ccs : NeoFoldCcsCase
  accInitMainWitnessZ : Array (Array (Array Nat))
  accInitMain : Array NeoFoldClaimCase
  finalMain : Array NeoFoldClaimCase
  finalVal : Array NeoFoldClaimCase
  steps : Array NeoFoldStepArtifactCase
  segmentMeta : Array NeoFoldSegmentMetaCase
deriving Repr, Inhabited, DecidableEq

end SuperNeo.Generated
