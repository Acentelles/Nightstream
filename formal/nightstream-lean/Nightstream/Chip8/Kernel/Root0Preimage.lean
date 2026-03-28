import Nightstream.Chip8.Kernel.MetaPubEncoding
import Nightstream.Chip8.Kernel.TranscriptSchedule

/-!
Owns the exact phase-0 `root0` preimage beneath any concrete hash function.
This file combines the canonical root0 commitment inventory with the exact
`meta_pub` absorb plan into one ordered theorem-facing input sequence. It does
not own Poseidon2 itself.
-/

namespace Nightstream.Chip8.Root0Preimage

open Nightstream.Chip8
open Nightstream.Chip8.MetaPubEncoding
open Nightstream.Chip8.TranscriptSchedule
open Nightstream.Chip8.ExactOpeningBoundary

section

variable {CommitmentDigest Digest RootParamsId : Type*}

structure Root0CommitmentDigestBinding (CommitmentDigest : Type*) where
  id : CommitmentId
  digest : CommitmentDigest
deriving DecidableEq, Repr

def root0CommitmentDigestBindingsConform
    (bindings : List (Root0CommitmentDigestBinding CommitmentDigest)) : Prop :=
  bindings.map Root0CommitmentDigestBinding.id = root0CommitmentIds

inductive Root0PreimageOp (CommitmentDigest Digest RootParamsId : Type*) where
  | absorbCommitment (label : String) (id : CommitmentId) (digest : CommitmentDigest)
  | absorbMeta (op : Root0MetaAbsorbOp Digest RootParamsId)
deriving DecidableEq, Repr

def root0PreimageOpLabel :
    Root0PreimageOp CommitmentDigest Digest RootParamsId → String
  | .absorbCommitment label _ _ => label
  | .absorbMeta op => root0MetaAbsorbOpLabel op

def root0CommitmentLabel : CommitmentId → String
  | .lane => "chip8/root0/c_lane"
  | .fetchRa => "chip8/root0/c_fetch_ra"
  | .decodeRa => "chip8/root0/c_decode_ra"
  | .aluRa => "chip8/root0/c_alu_ra"
  | .eq4Ra => "chip8/root0/c_eq4_ra"
  | .decodeHandoff => "chip8/root0/c_decode_handoff"
  | .regTwist => "chip8/root0/c_reg"
  | .ramTwist => "chip8/root0/c_ram"
  | .romTable => "chip8/root0/c_rom_table"
  | .decodeTable => "chip8/root0/c_decode_table"
  | .aluTable => "chip8/root0/c_alu_table"
  | .eq4Table => "chip8/root0/c_eq4_table"
  | .rootProver tag => s!"chip8/root0/invalid_root_prover/{tag}"

def root0CommitmentLabels : List String :=
  [ "chip8/root0/c_lane"
  , "chip8/root0/c_fetch_ra"
  , "chip8/root0/c_decode_ra"
  , "chip8/root0/c_alu_ra"
  , "chip8/root0/c_eq4_ra"
  , "chip8/root0/c_decode_handoff"
  , "chip8/root0/c_reg"
  , "chip8/root0/c_ram"
  , "chip8/root0/c_rom_table"
  , "chip8/root0/c_decode_table"
  , "chip8/root0/c_alu_table"
  , "chip8/root0/c_eq4_table"
  ]

def root0CommitmentAbsorbPlan
    (bindings : List (Root0CommitmentDigestBinding CommitmentDigest)) :
    List (Root0PreimageOp CommitmentDigest Digest RootParamsId) :=
  bindings.map fun binding =>
    Root0PreimageOp.absorbCommitment (root0CommitmentLabel binding.id) binding.id binding.digest

def root0MetaAbsorbPlanOps (pubMeta : KernelMetaPub Digest RootParamsId) :
    List (Root0PreimageOp CommitmentDigest Digest RootParamsId) :=
  (root0MetaPubAbsorbPlan pubMeta).map Root0PreimageOp.absorbMeta

def root0MetaPrefixAbsorbPlanOps (pubMeta : KernelMetaPub Digest RootParamsId) :
    List (Root0PreimageOp CommitmentDigest Digest RootParamsId) :=
  (root0MetaAbsorbPlanOps (CommitmentDigest := CommitmentDigest) pubMeta).take 3

def root0MetaSuffixAbsorbPlanOps (pubMeta : KernelMetaPub Digest RootParamsId) :
    List (Root0PreimageOp CommitmentDigest Digest RootParamsId) :=
  (root0MetaAbsorbPlanOps (CommitmentDigest := CommitmentDigest) pubMeta).drop 3

def root0Preimage
    (bindings : List (Root0CommitmentDigestBinding CommitmentDigest))
    (pubMeta : KernelMetaPub Digest RootParamsId) :
    List (Root0PreimageOp CommitmentDigest Digest RootParamsId) :=
  root0MetaPrefixAbsorbPlanOps (CommitmentDigest := CommitmentDigest) pubMeta ++
    root0CommitmentAbsorbPlan bindings ++
    root0MetaSuffixAbsorbPlanOps (CommitmentDigest := CommitmentDigest) pubMeta

@[simp] theorem root0CommitmentLabels_length :
    root0CommitmentLabels.length = 12 := by
  native_decide

@[simp] theorem root0CommitmentIds_map_labels :
    root0CommitmentIds.map root0CommitmentLabel = root0CommitmentLabels := by
  native_decide

@[simp] theorem root0CommitmentAbsorbPlan_length
    (bindings : List (Root0CommitmentDigestBinding CommitmentDigest)) :
    (root0CommitmentAbsorbPlan (Digest := Digest) (RootParamsId := RootParamsId) bindings).length =
      bindings.length := by
  simp [root0CommitmentAbsorbPlan]

@[simp] theorem root0MetaAbsorbPlanOps_length (pubMeta : KernelMetaPub Digest RootParamsId) :
    (root0MetaAbsorbPlanOps (CommitmentDigest := CommitmentDigest) pubMeta).length = 12 := by
  simp [root0MetaAbsorbPlanOps]

@[simp] theorem root0MetaPrefixAbsorbPlanOps_length (pubMeta : KernelMetaPub Digest RootParamsId) :
    (root0MetaPrefixAbsorbPlanOps (CommitmentDigest := CommitmentDigest) pubMeta).length = 3 := by
  simp [root0MetaPrefixAbsorbPlanOps]

@[simp] theorem root0MetaSuffixAbsorbPlanOps_length (pubMeta : KernelMetaPub Digest RootParamsId) :
    (root0MetaSuffixAbsorbPlanOps (CommitmentDigest := CommitmentDigest) pubMeta).length = 9 := by
  simp [root0MetaSuffixAbsorbPlanOps]

@[simp] theorem root0CommitmentAbsorbPlan_labels
    (bindings : List (Root0CommitmentDigestBinding CommitmentDigest)) :
    (root0CommitmentAbsorbPlan (Digest := Digest) (RootParamsId := RootParamsId) bindings).map
        root0PreimageOpLabel =
      bindings.map (fun binding => root0CommitmentLabel binding.id) := by
  simp [root0CommitmentAbsorbPlan, root0PreimageOpLabel]

@[simp] theorem root0MetaAbsorbPlanOps_labels (pubMeta : KernelMetaPub Digest RootParamsId) :
    (root0MetaAbsorbPlanOps (CommitmentDigest := CommitmentDigest) pubMeta).map root0PreimageOpLabel =
      root0MetaPubLabels := by
  simp [root0MetaAbsorbPlanOps, root0PreimageOpLabel, root0MetaAbsorbOpLabel,
    root0MetaPubAbsorbPlan, root0MetaPubLabels]

@[simp] theorem root0MetaPrefixAbsorbPlanOps_labels (pubMeta : KernelMetaPub Digest RootParamsId) :
    (root0MetaPrefixAbsorbPlanOps (CommitmentDigest := CommitmentDigest) pubMeta).map root0PreimageOpLabel =
      root0MetaPubLabels.take 3 := by
  simp [root0MetaPrefixAbsorbPlanOps, root0MetaAbsorbPlanOps_labels]

@[simp] theorem root0MetaSuffixAbsorbPlanOps_labels (pubMeta : KernelMetaPub Digest RootParamsId) :
    (root0MetaSuffixAbsorbPlanOps (CommitmentDigest := CommitmentDigest) pubMeta).map root0PreimageOpLabel =
      root0MetaPubLabels.drop 3 := by
  simp [root0MetaSuffixAbsorbPlanOps, root0MetaAbsorbPlanOps_labels]

theorem root0CommitmentAbsorbPlan_labels_of_conform
    {bindings : List (Root0CommitmentDigestBinding CommitmentDigest)}
    (hConform : root0CommitmentDigestBindingsConform bindings) :
    (root0CommitmentAbsorbPlan (Digest := Digest) (RootParamsId := RootParamsId) bindings).map
        root0PreimageOpLabel =
      root0CommitmentLabels := by
  rw [root0CommitmentAbsorbPlan_labels]
  simpa using
    (congrArg (List.map root0CommitmentLabel) hConform).trans root0CommitmentIds_map_labels

theorem root0Preimage_labels_of_conform
    {bindings : List (Root0CommitmentDigestBinding CommitmentDigest)}
    {pubMeta : KernelMetaPub Digest RootParamsId}
    (hConform : root0CommitmentDigestBindingsConform bindings) :
    (root0Preimage bindings pubMeta).map root0PreimageOpLabel =
      root0MetaPubLabels.take 3 ++ root0CommitmentLabels ++ root0MetaPubLabels.drop 3 := by
  simp [root0Preimage, root0CommitmentAbsorbPlan_labels_of_conform hConform,
    root0MetaPrefixAbsorbPlanOps_labels, root0MetaSuffixAbsorbPlanOps_labels]

theorem root0Preimage_length_of_conform
    {bindings : List (Root0CommitmentDigestBinding CommitmentDigest)}
    {pubMeta : KernelMetaPub Digest RootParamsId}
    (hConform : root0CommitmentDigestBindingsConform bindings) :
    (root0Preimage bindings pubMeta).length = 24 := by
  unfold root0CommitmentDigestBindingsConform at hConform
  have hLen : bindings.length = 12 := by
    simpa [root0CommitmentIds] using congrArg List.length hConform
  simp [root0Preimage, root0CommitmentAbsorbPlan_length, hLen]

@[simp] theorem root0Preimage_drop_prefix_and_commitments
    (bindings : List (Root0CommitmentDigestBinding CommitmentDigest))
    (pubMeta : KernelMetaPub Digest RootParamsId) :
    (root0Preimage bindings pubMeta).drop (3 + bindings.length) =
      root0MetaSuffixAbsorbPlanOps (CommitmentDigest := CommitmentDigest) pubMeta := by
  rw [root0Preimage, List.append_assoc, List.drop_append]
  simp

end

end Nightstream.Chip8.Root0Preimage
