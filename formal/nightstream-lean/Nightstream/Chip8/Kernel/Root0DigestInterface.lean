import Nightstream.Chip8.Kernel.Root0Digest

namespace Nightstream.Chip8

namespace Root0DigestInterface

abbrev State := Nightstream.Chip8.Root0Digest.State
abbrev rate := Nightstream.Chip8.Root0Digest.rate
abbrev width := Nightstream.Chip8.Root0Digest.width
abbrev Poseidon2Width8Core := Nightstream.Chip8.Root0Digest.Poseidon2Width8Core
abbrev zeroState := Nightstream.Chip8.Root0Digest.zeroState
abbrev Cursor := Nightstream.Chip8.Root0Digest.Cursor
abbrev emptyCursor := Nightstream.Chip8.Root0Digest.emptyCursor
abbrev permuteCursor := Nightstream.Chip8.Root0Digest.permuteCursor
abbrev absorbElem := Nightstream.Chip8.Root0Digest.absorbElem
abbrev absorbFields := Nightstream.Chip8.Root0Digest.absorbFields
abbrev appendMessageCursor := Nightstream.Chip8.Root0Digest.appendMessageCursor
abbrev appendU64sCursor := Nightstream.Chip8.Root0Digest.appendU64sCursor
abbrev digestCursor := Nightstream.Chip8.Root0Digest.digestCursor
abbrev challengeFieldCursor := Nightstream.Chip8.Root0Digest.challengeFieldCursor
abbrev challengeFieldValue := Nightstream.Chip8.Root0Digest.challengeFieldValue
abbrev applyOp := Nightstream.Chip8.Root0Digest.applyOp
abbrev runOps := Nightstream.Chip8.Root0Digest.runOps
abbrev firstDigestWords := Nightstream.Chip8.Root0Digest.firstDigestWords
abbrev natToLeBytes := Nightstream.Chip8.Root0Digest.natToLeBytes
abbrev wordToLeBytes8 := Nightstream.Chip8.Root0Digest.wordToLeBytes8
abbrev wordsToLeBytes := Nightstream.Chip8.Root0Digest.wordsToLeBytes
abbrev digestWords := Nightstream.Chip8.Root0Digest.digestWords
abbrev digestBytes := Nightstream.Chip8.Root0Digest.digestBytes
abbrev root0DigestCursor := @Nightstream.Chip8.Root0Digest.root0DigestCursor
abbrev root0DigestWords := @Nightstream.Chip8.Root0Digest.root0DigestWords
abbrev root0DigestBytes := @Nightstream.Chip8.Root0Digest.root0DigestBytes

abbrev emptyCursor_absorbed := Nightstream.Chip8.Root0Digest.emptyCursor_absorbed
abbrev permuteCursor_absorbed := @Nightstream.Chip8.Root0Digest.permuteCursor_absorbed
abbrev digestCursor_absorbed := @Nightstream.Chip8.Root0Digest.digestCursor_absorbed
abbrev challengeFieldCursor_absorbed := @Nightstream.Chip8.Root0Digest.challengeFieldCursor_absorbed
abbrev firstDigestWords_length := @Nightstream.Chip8.Root0Digest.firstDigestWords_length
abbrev wordToLeBytes8_length := @Nightstream.Chip8.Root0Digest.wordToLeBytes8_length
abbrev wordsToLeBytes_length := @Nightstream.Chip8.Root0Digest.wordsToLeBytes_length
abbrev digestWords_length := @Nightstream.Chip8.Root0Digest.digestWords_length
abbrev digestBytes_length := @Nightstream.Chip8.Root0Digest.digestBytes_length
abbrev root0DigestCursor_absorbed := @Nightstream.Chip8.Root0Digest.root0DigestCursor_absorbed
abbrev root0DigestWords_length := @Nightstream.Chip8.Root0Digest.root0DigestWords_length
abbrev root0DigestBytes_length := @Nightstream.Chip8.Root0Digest.root0DigestBytes_length

end Root0DigestInterface

end Nightstream.Chip8
