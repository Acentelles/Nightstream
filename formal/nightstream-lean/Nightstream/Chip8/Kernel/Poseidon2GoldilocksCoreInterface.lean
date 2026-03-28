import Nightstream.Chip8.Kernel.Poseidon2GoldilocksCore

namespace Nightstream.Chip8

namespace Poseidon2GoldilocksCoreInterface

abbrev FieldElem := Nightstream.Chip8.Poseidon2GoldilocksCore.FieldElem
abbrev State := Nightstream.Chip8.Poseidon2GoldilocksCore.State
abbrev width := Nightstream.Chip8.Poseidon2GoldilocksCore.width
abbrev roundsF := Nightstream.Chip8.Poseidon2GoldilocksCore.roundsF
abbrev roundsP := Nightstream.Chip8.Poseidon2GoldilocksCore.roundsP
abbrev zeroIdx := Nightstream.Chip8.Poseidon2GoldilocksCore.zeroIdx
abbrev ofWord := Nightstream.Chip8.Poseidon2GoldilocksCore.ofWord
abbrev mkStateF := Nightstream.Chip8.Poseidon2GoldilocksCore.mkStateF
abbrev mkState := Nightstream.Chip8.Poseidon2GoldilocksCore.mkState
abbrev stateWords := Nightstream.Chip8.Poseidon2GoldilocksCore.stateWords
abbrev sbox := Nightstream.Chip8.Poseidon2GoldilocksCore.sbox
abbrev addRoundConstants := Nightstream.Chip8.Poseidon2GoldilocksCore.addRoundConstants
abbrev sboxAll := Nightstream.Chip8.Poseidon2GoldilocksCore.sboxAll
abbrev applyMat4 := Nightstream.Chip8.Poseidon2GoldilocksCore.applyMat4
abbrev externalLinearLayer := Nightstream.Chip8.Poseidon2GoldilocksCore.externalLinearLayer
abbrev internalDiagConstants := Nightstream.Chip8.Poseidon2GoldilocksCore.internalDiagConstants
abbrev internalLinearLayer := Nightstream.Chip8.Poseidon2GoldilocksCore.internalLinearLayer
abbrev initialExternalRoundConstants := Nightstream.Chip8.Poseidon2GoldilocksCore.initialExternalRoundConstants
abbrev terminalExternalRoundConstants := Nightstream.Chip8.Poseidon2GoldilocksCore.terminalExternalRoundConstants
abbrev internalRoundConstants := Nightstream.Chip8.Poseidon2GoldilocksCore.internalRoundConstants
abbrev externalRound := Nightstream.Chip8.Poseidon2GoldilocksCore.externalRound
abbrev internalRound := Nightstream.Chip8.Poseidon2GoldilocksCore.internalRound
abbrev permuteInitial := Nightstream.Chip8.Poseidon2GoldilocksCore.permuteInitial
abbrev permuteInternal := Nightstream.Chip8.Poseidon2GoldilocksCore.permuteInternal
abbrev permuteTerminal := Nightstream.Chip8.Poseidon2GoldilocksCore.permuteTerminal
abbrev permute := Nightstream.Chip8.Poseidon2GoldilocksCore.permute
abbrev concreteCore := Nightstream.Chip8.Poseidon2GoldilocksCore.concreteCore
abbrev rangeState := Nightstream.Chip8.Poseidon2GoldilocksCore.rangeState
abbrev onesState := Nightstream.Chip8.Poseidon2GoldilocksCore.onesState
abbrev permuteZeroExpectedWords := Nightstream.Chip8.Poseidon2GoldilocksCore.permuteZeroExpectedWords
abbrev permuteRangeExpectedWords := Nightstream.Chip8.Poseidon2GoldilocksCore.permuteRangeExpectedWords
abbrev permuteOnesExpectedWords := Nightstream.Chip8.Poseidon2GoldilocksCore.permuteOnesExpectedWords

abbrev stateWords_length := @Nightstream.Chip8.Poseidon2GoldilocksCore.stateWords_length
abbrev initialExternalRoundConstants_length := Nightstream.Chip8.Poseidon2GoldilocksCore.initialExternalRoundConstants_length
abbrev terminalExternalRoundConstants_length := Nightstream.Chip8.Poseidon2GoldilocksCore.terminalExternalRoundConstants_length
abbrev internalRoundConstants_length := Nightstream.Chip8.Poseidon2GoldilocksCore.internalRoundConstants_length
abbrev permuteZeroExpectedWords_length := Nightstream.Chip8.Poseidon2GoldilocksCore.permuteZeroExpectedWords_length
abbrev permuteRangeExpectedWords_length := Nightstream.Chip8.Poseidon2GoldilocksCore.permuteRangeExpectedWords_length
abbrev permuteOnesExpectedWords_length := Nightstream.Chip8.Poseidon2GoldilocksCore.permuteOnesExpectedWords_length

end Poseidon2GoldilocksCoreInterface

end Nightstream.Chip8
