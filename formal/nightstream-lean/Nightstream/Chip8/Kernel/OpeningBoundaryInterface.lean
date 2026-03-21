import Nightstream.Chip8.Kernel.OpeningBoundary

namespace Nightstream.Chip8

namespace OpeningBoundaryInterface

-- ── Types ──

abbrev OpeningSource := ExactOpeningBoundary.OpeningSource
abbrev CommitmentId := ExactOpeningBoundary.CommitmentId
abbrev LaneColumn := ExactOpeningBoundary.LaneColumn

-- ── Definitions (polynomial ID enumerations) ──

abbrev laneColumnPolynomialId := ExactOpeningBoundary.laneColumnPolynomialId
abbrev laneLookupPolynomialIds := ExactOpeningBoundary.laneLookupPolynomialIds
abbrev laneTwistPolynomialIds := ExactOpeningBoundary.laneTwistPolynomialIds
abbrev laneShiftPolynomialIds := ExactOpeningBoundary.laneShiftPolynomialIds
abbrev laneStartPolynomialIds := ExactOpeningBoundary.laneStartPolynomialIds
abbrev laneFinalPolynomialIds := ExactOpeningBoundary.laneFinalPolynomialIds
abbrev laneRowBindingPolynomialIds := ExactOpeningBoundary.laneRowBindingPolynomialIds
abbrev decodeHandoffPolynomialIds := ExactOpeningBoundary.decodeHandoffPolynomialIds
abbrev regTwistPolynomialIds := ExactOpeningBoundary.regTwistPolynomialIds
abbrev ramTwistPolynomialIds := ExactOpeningBoundary.ramTwistPolynomialIds
abbrev singletonPolynomialIds := ExactOpeningBoundary.singletonPolynomialIds
abbrev decodeTablePolynomialIds := ExactOpeningBoundary.decodeTablePolynomialIds

-- ── Structures ──

abbrev OpeningClaim := ExactOpeningBoundary.OpeningClaim
abbrev claimMatches := @ExactOpeningBoundary.claimMatches
abbrev ExactOpeningWitness := ExactOpeningBoundary.ExactOpeningWitness
abbrev OpeningRefinement := ExactOpeningBoundary.OpeningRefinement
abbrev AcceptedDirectOpening := ExactOpeningBoundary.AcceptedDirectOpening
abbrev KernelOpeningManifest := ExactOpeningBoundary.KernelOpeningManifest
abbrev RootOpeningManifest := ExactOpeningBoundary.RootOpeningManifest
abbrev KernelPoints := ExactOpeningBoundary.KernelPoints
abbrev LaneShiftProof := ExactOpeningBoundary.LaneShiftProof

-- ── Definitions (ordering and classification) ──

abbrev commitmentIdOrder := ExactOpeningBoundary.commitmentIdOrder
abbrev isKernelCommitment := ExactOpeningBoundary.isKernelCommitment
abbrev isRootCommitment := ExactOpeningBoundary.isRootCommitment
abbrev strictlyIncreasing := ExactOpeningBoundary.strictlyIncreasing

-- ── Constraints ──

abbrev SimpleKernelManifestOrder := @ExactOpeningBoundary.SimpleKernelManifestOrder
abbrev CanonicalManifestOrder := @ExactOpeningBoundary.CanonicalManifestOrder
abbrev KernelManifestShape := @ExactOpeningBoundary.KernelManifestShape
abbrev RootManifestShape := @ExactOpeningBoundary.RootManifestShape
abbrev RootManifestEmpty := @ExactOpeningBoundary.RootManifestEmpty
abbrev SimpleBoundaryGlobalFoldPlanAbsent :=
  @ExactOpeningBoundary.SimpleBoundaryGlobalFoldPlanAbsent
abbrev FamilyLocalFoldBucketConforms :=
  @ExactOpeningBoundary.FamilyLocalFoldBucketConforms
abbrev KernelOpeningBoundary := @ExactOpeningBoundary.ExactKernelOpeningBoundary
abbrev LaneShiftAppearsInManifest := @ExactOpeningBoundary.LaneShiftAppearsInManifest
abbrev LaneShiftSourceOpeningAppearsInManifest :=
  @ExactOpeningBoundary.LaneShiftSourceOpeningAppearsInManifest

-- ── Theorems ──

abbrev laneShift_not_openingClaim := @ExactOpeningBoundary.laneShift_not_openingClaim
abbrev laneShiftSourceOpeningAppears_of_kernelManifestShape :=
  @ExactOpeningBoundary.laneShiftSourceOpeningAppears_of_kernelManifestShape
abbrev laneShiftSourceOpeningAppears_of_exactKernelOpeningBoundary :=
  @ExactOpeningBoundary.laneShiftSourceOpeningAppears_of_exactKernelOpeningBoundary
abbrev kernelOpeningBoundary_conforms := @ExactOpeningBoundary.exact_kernelOpeningBoundary_conforms
abbrev rootManifestEmpty_of_kernelOpeningBoundary :=
  @ExactOpeningBoundary.rootManifestEmpty_of_exactKernelOpeningBoundary
abbrev kernel_root_commitments_disjoint :=
  @ExactOpeningBoundary.exact_kernel_root_commitments_disjoint

end OpeningBoundaryInterface

end Nightstream.Chip8
