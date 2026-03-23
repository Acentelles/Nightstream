import Nightstream.Chip8.Stage2.RegisterSessionBoundary

namespace Nightstream.Chip8

namespace RegisterSessionBoundaryInterface

abbrev RegisterSessionKey := Nightstream.Chip8.RegisterSessionBoundary.RegisterSessionKey
abbrev RegisterSessionKeyBound :=
  Nightstream.Chip8.RegisterSessionBoundary.RegisterSessionKeyBound

abbrev regRaXKey := @Nightstream.Chip8.RegisterSessionBoundary.regRaXKey
abbrev regRaYKey := @Nightstream.Chip8.RegisterSessionBoundary.regRaYKey
abbrev regRaIKey := @Nightstream.Chip8.RegisterSessionBoundary.regRaIKey
abbrev regWaKey := @Nightstream.Chip8.RegisterSessionBoundary.regWaKey

abbrev regRaXKey_bound_of_activeXIndexBound :=
  @Nightstream.Chip8.RegisterSessionBoundary.regRaXKey_bound_of_activeXIndexBound
abbrev regRaYKey_bound_of_shape :=
  @Nightstream.Chip8.RegisterSessionBoundary.regRaYKey_bound_of_shape
abbrev regRaYKey_sink_iff_not_usesY :=
  @Nightstream.Chip8.RegisterSessionBoundary.regRaYKey_sink_iff_not_usesY
abbrev regRaIKey_is_i :=
  @Nightstream.Chip8.RegisterSessionBoundary.regRaIKey_is_i
abbrev regRaIKey_bound :=
  @Nightstream.Chip8.RegisterSessionBoundary.regRaIKey_bound
abbrev regWaKey_bound_of_shape :=
  @Nightstream.Chip8.RegisterSessionBoundary.regWaKey_bound_of_shape
abbrev regWaKey_sink_iff_no_lane_write :=
  @Nightstream.Chip8.RegisterSessionBoundary.regWaKey_sink_iff_no_lane_write

end RegisterSessionBoundaryInterface

end Nightstream.Chip8
