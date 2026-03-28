import Nightstream.Chip8.Stage2.EvidenceCoverageCore

/-!
Owns the theorem-facing root-handoff context imported by the CHIP-8 kernel. It
binds the root encoding / commitment functions used for prepared-step export to
the public `rootParamsId` already fixed in `meta_pub`; it does not re-own the
canonical root encoding scheme itself.
-/

namespace Nightstream.Chip8.RootHandoffContext

open Nightstream.Chip8

set_option linter.dupNamespace false in
structure RootHandoffContext (RootParamsId W Z Commitment K : Type*) where
  rootParamsId : RootParamsId
  rootEncode : ContinuityBridge.RootEncode W Z K
  ajtaiCommit : Z → Commitment

def RootHandoffContextBound
  {DigestRom DigestSchedule RootParamsId VmSpec TranscriptSeed : Type}
  {W Z Commitment : Type*}
  (inputs :
    EvidenceCoverage.ExecutionInputContext DigestRom DigestSchedule RootParamsId
      VmSpec TranscriptSeed)
  (rootCtx : RootHandoffContext RootParamsId W Z Commitment EvidenceCoverage.F) :
  Prop :=
  rootCtx.rootParamsId = inputs.pubMeta.rootParamsId ∧
    @RomScheduleBinding.RootParamsBound DigestRom RootParamsId VmSpec
      inputs.rootParamsOf inputs.pubMeta inputs.publicInput.vmSpec

theorem rootParamsId_eq_of_bound
  {DigestRom DigestSchedule RootParamsId VmSpec TranscriptSeed : Type}
  {W Z Commitment : Type*}
  {inputs :
    EvidenceCoverage.ExecutionInputContext DigestRom DigestSchedule RootParamsId
      VmSpec TranscriptSeed}
  {rootCtx :
    RootHandoffContext RootParamsId W Z Commitment EvidenceCoverage.F}
  (h : RootHandoffContextBound inputs rootCtx) :
  rootCtx.rootParamsId = inputs.pubMeta.rootParamsId :=
  h.1

theorem rootParamsBound_of_bound
  {DigestRom DigestSchedule RootParamsId VmSpec TranscriptSeed : Type}
  {W Z Commitment : Type*}
  {inputs :
    EvidenceCoverage.ExecutionInputContext DigestRom DigestSchedule RootParamsId
      VmSpec TranscriptSeed}
  {rootCtx :
    RootHandoffContext RootParamsId W Z Commitment EvidenceCoverage.F}
  (h : RootHandoffContextBound inputs rootCtx) :
  @RomScheduleBinding.RootParamsBound DigestRom RootParamsId VmSpec
    inputs.rootParamsOf inputs.pubMeta inputs.publicInput.vmSpec :=
  h.2

end Nightstream.Chip8.RootHandoffContext
