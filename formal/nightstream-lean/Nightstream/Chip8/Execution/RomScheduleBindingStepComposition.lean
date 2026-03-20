import Nightstream.Chip8.Kernel.RomScheduleBinding
import Nightstream.Chip8.Execution.StepComposition

/-!
Owns the tiny downstream adapter from public-input/schedule authentication into
`StepComposition`-facing theorem surfaces. The core `RomScheduleBinding` module
stays below composition; this file depends on composition on purpose.
-/

namespace Nightstream.Chip8.RomScheduleBinding

open Nightstream.Chip8
open Nightstream.Chip8.FetchDecodeBinding
open Nightstream.Chip8.DecodeAddressBinding
open Nightstream.Chip8.StepComposition

theorem fetchDecodeBound_of_sharedDigest
  {Digest : Type*}
  {hashProgram : Program → Digest}
  (hInj : Function.Injective hashProgram)
  {romHash : PublicDigest Digest}
  {rom₁ rom₂ : Program}
  {pc : Nat}
  {dec : DecodedStep Addr}
  (h₁ : RomHashBound hashProgram romHash rom₁)
  (h₂ : RomHashBound hashProgram romHash rom₂)
  (hFetch : StepComposition.FetchDecodeBound rom₁ pc dec) :
  StepComposition.FetchDecodeBound rom₂ pc dec := by
  have hRom : rom₁ = rom₂ := rom_eq_of_sharedDigest hInj h₁ h₂
  subst hRom
  exact hFetch

theorem stepCompositionScheduleBound_of_authenticatedStepSchedule
  {hashSchedule : ExternalSchedule → Digest}
  {scheduleLength : ExternalSchedule → Nat}
  {scheduleHash : PublicDigest Digest}
  {publishedLength : Nat}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {pre post : StepComposition.MachineState}
  {dec : DecodedStep Addr}
  (_h :
    AuthenticatedStepSchedule hashSchedule scheduleLength scheduleHash
      publishedLength σ stepIdx) :
  StepComposition.ScheduleBound σ stepIdx pre post dec := by
  trivial

end Nightstream.Chip8.RomScheduleBinding
