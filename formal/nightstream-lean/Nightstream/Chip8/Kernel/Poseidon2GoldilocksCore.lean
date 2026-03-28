import Nightstream.Chip8.Kernel.Root0Digest

/-!
Owns the exact concrete width-8 Poseidon2-over-Goldilocks permutation used by
the CHIP-8 simple-kernel transcript. This file freezes the generated round
constants and exports the concrete `Poseidon2Width8Core` consumed by the
generic digest/challenge owners.
-/

namespace Nightstream.Chip8.Poseidon2GoldilocksCore

open Nightstream.Chip8.Root0Digest

abbrev FieldElem := SuperNeo.F
abbrev State := Root0Digest.State

def width : Nat := 8
def roundsF : Nat := 8
def roundsP : Nat := 22

def zeroIdx : Fin 8 := ⟨0, by decide⟩

def ofWord (n : Nat) : FieldElem :=
  SuperNeo.F.ofNat n

def mkStateF
    (x0 x1 x2 x3 x4 x5 x6 x7 : FieldElem) : State :=
  { x0 := x0
  , x1 := x1
  , x2 := x2
  , x3 := x3
  , x4 := x4
  , x5 := x5
  , x6 := x6
  , x7 := x7 }

def mkState
    (x0 x1 x2 x3 x4 x5 x6 x7 : Nat) : State :=
  mkStateF
    (ofWord x0) (ofWord x1) (ofWord x2) (ofWord x3)
    (ofWord x4) (ofWord x5) (ofWord x6) (ofWord x7)

def stateWords (st : State) : List Nat :=
  [ (st ⟨0, by decide⟩).val
  , (st ⟨1, by decide⟩).val
  , (st ⟨2, by decide⟩).val
  , (st ⟨3, by decide⟩).val
  , (st ⟨4, by decide⟩).val
  , (st ⟨5, by decide⟩).val
  , (st ⟨6, by decide⟩).val
  , (st ⟨7, by decide⟩).val
  ]

def sbox (x : FieldElem) : FieldElem :=
  SuperNeo.F.pow x 7

def addRoundConstants (st rc : State) : State :=
  mkStateF
    (st ⟨0, by decide⟩ + rc ⟨0, by decide⟩)
    (st ⟨1, by decide⟩ + rc ⟨1, by decide⟩)
    (st ⟨2, by decide⟩ + rc ⟨2, by decide⟩)
    (st ⟨3, by decide⟩ + rc ⟨3, by decide⟩)
    (st ⟨4, by decide⟩ + rc ⟨4, by decide⟩)
    (st ⟨5, by decide⟩ + rc ⟨5, by decide⟩)
    (st ⟨6, by decide⟩ + rc ⟨6, by decide⟩)
    (st ⟨7, by decide⟩ + rc ⟨7, by decide⟩)

def sboxAll (st : State) : State :=
  mkStateF
    (sbox (st ⟨0, by decide⟩))
    (sbox (st ⟨1, by decide⟩))
    (sbox (st ⟨2, by decide⟩))
    (sbox (st ⟨3, by decide⟩))
    (sbox (st ⟨4, by decide⟩))
    (sbox (st ⟨5, by decide⟩))
    (sbox (st ⟨6, by decide⟩))
    (sbox (st ⟨7, by decide⟩))

def applyMat4
    (x0 x1 x2 x3 : FieldElem) :
    FieldElem × FieldElem × FieldElem × FieldElem :=
  let t01 := x0 + x1
  let t23 := x2 + x3
  let t0123 := t01 + t23
  let t01123 := t0123 + x1
  let t01233 := t0123 + x3
  let y3 := t01233 + (x0 + x0)
  let y1 := t01123 + (x2 + x2)
  let y0 := t01123 + t01
  let y2 := t01233 + t23
  (y0, y1, y2, y3)

def externalLinearLayer (st : State) : State :=
  let (a0, a1, a2, a3) :=
    applyMat4 (st ⟨0, by decide⟩) (st ⟨1, by decide⟩) (st ⟨2, by decide⟩) (st ⟨3, by decide⟩)
  let (b0, b1, b2, b3) :=
    applyMat4 (st ⟨4, by decide⟩) (st ⟨5, by decide⟩) (st ⟨6, by decide⟩) (st ⟨7, by decide⟩)
  let s0 := a0 + b0
  let s1 := a1 + b1
  let s2 := a2 + b2
  let s3 := a3 + b3
  mkStateF
    (a0 + s0) (a1 + s1) (a2 + s2) (a3 + s3)
    (b0 + s0) (b1 + s1) (b2 + s2) (b3 + s3)

def internalDiagConstants : State :=
  mkState
    0xa98811a1fed4e3a5
    0x1cc48b54f377e2a0
    0xe40cd4f6c5609a26
    0x11de79ebca97a4a3
    0x9177c73d8b7e929c
    0x2a6fe8085797e791
    0x3de6e93329f8d5ad
    0x3f7af9125da962fe

def internalLinearLayer (st : State) : State :=
  let sum :=
    st ⟨0, by decide⟩ + st ⟨1, by decide⟩ + st ⟨2, by decide⟩ + st ⟨3, by decide⟩ +
    st ⟨4, by decide⟩ + st ⟨5, by decide⟩ + st ⟨6, by decide⟩ + st ⟨7, by decide⟩
  mkStateF
    (st ⟨0, by decide⟩ * internalDiagConstants ⟨0, by decide⟩ + sum)
    (st ⟨1, by decide⟩ * internalDiagConstants ⟨1, by decide⟩ + sum)
    (st ⟨2, by decide⟩ * internalDiagConstants ⟨2, by decide⟩ + sum)
    (st ⟨3, by decide⟩ * internalDiagConstants ⟨3, by decide⟩ + sum)
    (st ⟨4, by decide⟩ * internalDiagConstants ⟨4, by decide⟩ + sum)
    (st ⟨5, by decide⟩ * internalDiagConstants ⟨5, by decide⟩ + sum)
    (st ⟨6, by decide⟩ * internalDiagConstants ⟨6, by decide⟩ + sum)
    (st ⟨7, by decide⟩ * internalDiagConstants ⟨7, by decide⟩ + sum)

def initialExternalRoundConstants : List State :=
  [ mkState
      0xd72c679be7acba89 0x1eb3303782cacb2c 0x1a29c7742ae7b7c9 0xf34ce36724144a7e
      0xe8b9bb649cde2cac 0x06302f9249f49ace 0x1228a063da8a5baf 0xf2602654da3ec4ef
  , mkState
      0x1aac6f6a1765e240 0x24e16376dc21c3e4 0xef3c305ec4749118 0x65fa532443599bbe
      0x958fff13922ef213 0x1894c926caf97b7a 0x8295f23df6c4f619 0xe6a525607408b748
  , mkState
      0x1aac719cc4a3db7a 0x25374389e483204a 0xac89e6d5cd8ae62d 0x273b729ad9f2652d
      0x4682a57d1d9652b4 0xe988f24e380e5eb5 0x7f9f9c8b8f9ab50a 0x209f9e4ea9785aed
  , mkState
      0x297b1ab3bdd90944 0x3c819d768bc4b578 0xdf4aec4dc41f239b 0x5b9ef5fd9691f05c
      0xb47c02376fa5fe8a 0xedb3b9a501652399 0x725d2a4fdaa48191 0x786877c2063a1347
  ]

def terminalExternalRoundConstants : List State :=
  [ mkState
      0xe4533560f50fd971 0xf80f29068f742817 0x2a12d15875a56e8f 0xfcca876663423c5d
      0xfc61ab4199037a4d 0x9a95a9944630ccbe 0xd18790f2bcc1dd5a 0x1c1d89e54a1ccf9d
  , mkState
      0x8a30bf677649afa1 0xa0593ff36bfa0220 0x870497689b3b1051 0x3ad6b087d866ca14
      0x3cee928735b631cc 0xf4e88ea42de31399 0x6a761066d029fe21 0x3a6afb251445703e
  , mkState
      0x5b82801d0b3de132 0x74720af105506572 0x65a54b33c98f181b 0xf6c1e89cbe03d87c
      0xddaf57949d933aff 0xb75f5326911e93d8 0x657cbc4d219e8b61 0x903e6273d7c52d6b
  , mkState
      0x259c3cc418dfd53a 0x26e102c04bb9612a 0xdc940a606ab805b2 0xbb7ff248689fbf75
      0x6ddf6afac02b97a9 0xc010d9bf9ca9cd3f 0x5c9b386aab3da5b5 0x3eba1c3a9a01e8f9
  ]

def internalRoundConstants : List FieldElem :=
  [ ofWord 0x67d6184d5ea5fcfe
  , ofWord 0x302edf3a1b784ab0
  , ofWord 0x7ac5aea122da27f2
  , ofWord 0x3d7e234fad5cc287
  , ofWord 0xc7996ce7c8310e86
  , ofWord 0xd90059ca8eee0fc8
  , ofWord 0xc98879052e16d8e7
  , ofWord 0x3c622ee5557474db
  , ofWord 0xc3f3c7222f3aeb69
  , ofWord 0x07548fa82c00f654
  , ofWord 0xd56ea1123363578c
  , ofWord 0xbc59a21856abb7eb
  , ofWord 0x0ad3e0e2a5a3203d
  , ofWord 0x92fb9ee729612129
  , ofWord 0x19aac61cc077ed02
  , ofWord 0x65f011723421bba6
  , ofWord 0xca59b23c7001ba57
  , ofWord 0x79cf23880b0bbba6
  , ofWord 0x18687250bb553ae7
  , ofWord 0x86a27245417a1134
  , ofWord 0xd9ae528f43c0edac
  , ofWord 0x4eb82ba4da413ecb
  ]

def externalRound (rc st : State) : State :=
  externalLinearLayer (sboxAll (addRoundConstants st rc))

def internalRound (rc : FieldElem) (st : State) : State :=
  let updated :=
    st.set zeroIdx (sbox (st zeroIdx + rc))
  internalLinearLayer updated

def permuteInitial (st : State) : State :=
  initialExternalRoundConstants.foldl externalRound (externalLinearLayer st)

def permuteInternal (st : State) : State :=
  internalRoundConstants.foldl (fun acc rc => internalRound rc acc) st

def permuteTerminal (st : State) : State :=
  terminalExternalRoundConstants.foldl externalRound st

def permute (st : State) : State :=
  permuteTerminal (permuteInternal (permuteInitial st))

def concreteCore : Poseidon2Width8Core :=
  { permute := permute }

def rangeState : State :=
  mkState 0 1 2 3 4 5 6 7

def onesState : State :=
  mkState 1 1 1 1 1 1 1 1

@[simp] theorem stateWords_length (st : State) :
    (stateWords st).length = 8 := by
  simp [stateWords]

@[simp] theorem initialExternalRoundConstants_length :
    initialExternalRoundConstants.length = 4 := by
  native_decide

@[simp] theorem terminalExternalRoundConstants_length :
    terminalExternalRoundConstants.length = 4 := by
  native_decide

@[simp] theorem internalRoundConstants_length :
    internalRoundConstants.length = 22 := by
  native_decide

def permuteZeroExpectedWords : List Nat :=
  [ 0xba8abf210c4155db
  , 0xc44930f92f36d105
  , 0x4a0340723db684a5
  , 0x7468691927167c04
  , 0xb19e792a6f7ea26e
  , 0x4a11318a3720929c
  , 0x63cffa76c33edc29
  , 0x7798f995e580b2ef
  ]

def permuteRangeExpectedWords : List Nat :=
  [ 0x1c9952232b59fd38
  , 0x1957d7eada39ab97
  , 0xf8098786dd42858f
  , 0x2366cee702910d3a
  , 0x0ed0db57ffc0b1b1
  , 0xdb14ca8b76e45925
  , 0x0db915d6e57f0f9e
  , 0x809cb01e50d578a0
  ]

def permuteOnesExpectedWords : List Nat :=
  [ 0x2622afd36eeb4362
  , 0x759d58e62c3acb38
  , 0xfb9535abed16535e
  , 0x630dad8bba719fc8
  , 0x113145dc53da3d05
  , 0x79dd650f0a10598f
  , 0x53e5fde526c51278
  , 0xb6e579f6cc225a85
  ]

@[simp] theorem permuteZeroExpectedWords_length :
    permuteZeroExpectedWords.length = 8 := by
  native_decide

@[simp] theorem permuteRangeExpectedWords_length :
    permuteRangeExpectedWords.length = 8 := by
  native_decide

@[simp] theorem permuteOnesExpectedWords_length :
    permuteOnesExpectedWords.length = 8 := by
  native_decide

end Nightstream.Chip8.Poseidon2GoldilocksCore
