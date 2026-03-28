namespace Nightstream.Rv64IM

inductive AlignmentWidth where
  | byte
  | halfword
  | word
  | doubleword
deriving DecidableEq, Repr

def AlignmentWidth.bytes : AlignmentWidth → Nat
  | .byte => 1
  | .halfword => 2
  | .word => 4
  | .doubleword => 8

def NaturalAlignment (w : AlignmentWidth) (addr : Nat) : Prop :=
  addr % w.bytes = 0

def ArithmeticAlignmentFromLowByte (w : AlignmentWidth) (lowByte : Nat) : Prop :=
  lowByte % w.bytes = 0

theorem naturalAlignment_iff_arithmetic_from_lowByte
  (w : AlignmentWidth)
  (addr : Nat) :
  NaturalAlignment w addr ↔ ArithmeticAlignmentFromLowByte w (addr % 256) := by
  cases w <;> simp [NaturalAlignment, ArithmeticAlignmentFromLowByte, AlignmentWidth.bytes]

theorem naturalAlignment_iff_of_lowByte_eq_mod
  (w : AlignmentWidth)
  (addr lowByte : Nat)
  (hLowByte : lowByte = addr % 256) :
  NaturalAlignment w addr ↔ ArithmeticAlignmentFromLowByte w lowByte := by
  simpa [hLowByte] using naturalAlignment_iff_arithmetic_from_lowByte w addr

theorem naturalAlignment_of_arithmetic_from_lowByte
  (w : AlignmentWidth)
  (addr lowByte : Nat)
  (hLowByte : lowByte = addr % 256)
  (hArithmetic : ArithmeticAlignmentFromLowByte w lowByte) :
  NaturalAlignment w addr :=
  (naturalAlignment_iff_of_lowByte_eq_mod w addr lowByte hLowByte).2 hArithmetic

theorem arithmetic_from_lowByte_of_naturalAlignment
  (w : AlignmentWidth)
  (addr : Nat) :
  NaturalAlignment w addr →
    ArithmeticAlignmentFromLowByte w (addr % 256) := by
  intro hNatural
  exact (naturalAlignment_iff_arithmetic_from_lowByte w addr).1 hNatural

def FourByteTargetAlignment (addr : Nat) : Prop :=
  NaturalAlignment .word addr

theorem fourByteTargetAlignment_iff_lowByte
  (addr lowByte : Nat)
  (hLowByte : lowByte = addr % 256) :
  FourByteTargetAlignment addr ↔ ArithmeticAlignmentFromLowByte .word lowByte := by
  simpa [FourByteTargetAlignment] using
    naturalAlignment_iff_of_lowByte_eq_mod .word addr lowByte hLowByte

end Nightstream.Rv64IM
