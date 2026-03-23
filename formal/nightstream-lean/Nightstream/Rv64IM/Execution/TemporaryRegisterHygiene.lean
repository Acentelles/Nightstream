namespace Nightstream.Rv64IM

def TemporaryRegisterHygiene
  (sequence : List Row)
  (isTempRegister : Register → Prop)
  (readsRegister writesRegister : Row → Register → Prop) :
  Prop :=
  ∀ (idx : Nat) row reg,
    sequence[idx]? = some row →
      isTempRegister reg →
        readsRegister row reg →
          ∃ (writeIdx : Nat), writeIdx < idx ∧ ∃ writeRow,
            sequence[writeIdx]? = some writeRow ∧ writesRegister writeRow reg

structure TemporaryRegisterHygieneProofPackage (Row Register : Type _) where
  sequence : List Row
  isTempRegister : Register → Prop
  readsRegister : Row → Register → Prop
  writesRegister : Row → Register → Prop
  hygiene :
    TemporaryRegisterHygiene sequence isTempRegister readsRegister writesRegister

end Nightstream.Rv64IM
