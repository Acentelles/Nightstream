import Nightstream.ClaimedMemorySemantics

namespace Nightstream

namespace ClaimedMemorySemanticsInterface

abbrev ShoutReadOnlySound := @Nightstream.ShoutReadOnlySound
abbrev NoPriorWrite := @Nightstream.NoPriorWrite
abbrev LatestWriteAt := @Nightstream.LatestWriteAt
abbrev TwistReadWriteSound := @Nightstream.TwistReadWriteSound
abbrev TwistReadWriteSoundZeroInit := @Nightstream.TwistReadWriteSoundZeroInit

abbrev shoutReadOnlySound_value := @Nightstream.shoutReadOnlySound_value
abbrev twistReadWriteSound_reads_initial_when_no_prior_write :=
  @Nightstream.twistReadWriteSound_reads_initial_when_no_prior_write
abbrev twistReadWriteSound_reads_latest_write :=
  @Nightstream.twistReadWriteSound_reads_latest_write
abbrev twistReadWriteSoundZeroInit_eq := @Nightstream.twistReadWriteSoundZeroInit_eq

end ClaimedMemorySemanticsInterface

end Nightstream
