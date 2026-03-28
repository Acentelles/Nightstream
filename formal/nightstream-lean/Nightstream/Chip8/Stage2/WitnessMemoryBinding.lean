import Nightstream.Chip8.Stage1.DecodeAddressBinding
import Nightstream.Chip8.Stage1.Routing
import Nightstream.NonZeroInitTwist

open scoped BigOperators

namespace Nightstream.Chip8.WitnessMemoryBinding

open Nightstream.Chip8
open Nightstream.Chip8.FetchDecodeBinding
open Nightstream.Chip8.DecodeAddressBinding

structure MachineState where
  pc : Nat
  i : Nat
  v : Nat → Nat
  ram : Nat → Nat

structure InitialState where
  pc : Nat
  i : Nat
  v : Nat → Nat
  ram : Nat → Nat

structure RegisterAccess where
  addr : Nat
  value : Nat
deriving DecidableEq, Repr

structure RamAccess where
  addr : Nat
  value : Nat
deriving DecidableEq, Repr

structure StepMemoryTrace where
  registerReads : List RegisterAccess
  registerWrites : List RegisterAccess
  ramReads : List RamAccess
  ramWrites : List RamAccess
deriving DecidableEq, Repr

abbrev RegAddress := TwistShout.Address 1 5
abbrev RamAddress := TwistShout.Address 1 13

private def cubeNat
  {n : Nat}
  (b : Fin n → Bool) : Nat :=
  ∑ i : Fin n, if b i then 2 ^ i.1 else 0

def regAddressNat
  (a : RegAddress) : Nat :=
  cubeNat (a 0)

def ramAddressNat
  (a : RamAddress) : Nat :=
  cubeNat (a 0)

def vAccess (index value : Nat) : RegisterAccess :=
  ⟨index, value⟩

def iAccess (value : Nat) : RegisterAccess :=
  ⟨16, value⟩

def primaryIndex
  {Addr : Type*}
  (dec : DecodedStep Addr) : Nat :=
  activeXIndex dec

def yIndexOf
  {Addr : Type*}
  (dec : DecodedStep Addr) : Nat :=
  projectedYIndex dec

def primaryValue
  {Addr : Type*}
  (st : MachineState)
  (dec : DecodedStep Addr) : Nat :=
  st.v (primaryIndex dec)

def secondaryValue
  {Addr : Type*}
  (st : MachineState)
  (dec : DecodedStep Addr) : Nat :=
  if dec.usesY = 1 then st.v dec.y else 0

def currentRamAddr
  {Addr : Type*}
  (pre : MachineState)
  (dec : DecodedStep Addr) : Nat :=
  pre.i + primaryIndex dec

def burstLastValue
  {Addr : Type*}
  (dec : DecodedStep Addr) : Nat :=
  if dec.isMemOp = 1 then eq4Eval (primaryIndex dec) dec.xBound else 0

def ramAddrValue
  {Addr : Type*}
  (pre : MachineState)
  (dec : DecodedStep Addr) : Nat :=
  if dec.isMemOp = 1 then currentRamAddr pre dec else 0

def memValueOf
  {Addr : Type*}
  (pre post : MachineState)
  (dec : DecodedStep Addr) : Nat :=
  if dec.writesRam = 1 then
    primaryValue pre dec
  else if dec.readsRam = 1 then
    primaryValue post dec
  else
    0

def registerSlotValue
  (st : MachineState)
  (addr : Nat) : Nat :=
  if _ : addr < 16 then
    st.v addr
  else if addr = 16 then
    st.i
  else
    0

def ramSlotValue
  (st : MachineState)
  (addr : Nat) : Nat :=
  if _ : addr < ramSinkAddr then
    st.ram addr
  else
    0

def initialRegisterValue
  (init : InitialState)
  (addr : Nat) : Nat :=
  if _ : addr < 16 then
    init.v addr
  else if addr = 16 then
    init.i
  else
    0

def initialRamValue
  (init : InitialState)
  (addr : Nat) : Nat :=
  if _ : addr < ramSinkAddr then
    init.ram addr
  else
    0

def registerInitTable
  {K : Type*} [Field K]
  (init : InitialState) :
  TwistShout.PublicTable (K := K) 1 5 :=
  fun a => initialRegisterValue init (regAddressNat a)

def ramInitTable
  {K : Type*} [Field K]
  (init : InitialState) :
  TwistShout.PublicTable (K := K) 1 13 :=
  fun a => initialRamValue init (ramAddressNat a)

def RegisterShiftedTimeTable
  {K : Type*} [Field K]
  {t : Nat}
  (init : InitialState)
  (inc : TwistShout.TimeTable (K := K) 1 5 t) :
  TwistShout.TimeTable (K := K) 1 5 t :=
  NonZeroInitTwist.ShiftedTimeTable (K := K) (registerInitTable (K := K) init) inc

def RegisterShiftedVirtualValue
  {K : Type*} [Field K]
  {t : Nat}
  (init : InitialState)
  (inc : TwistShout.TimeTable (K := K) 1 5 t)
  (a : RegAddress)
  (rCycle : TwistShout.Point (K := K) t) : K :=
  NonZeroInitTwist.ShiftedVirtualValue (K := K) (registerInitTable (K := K) init) inc a rCycle

def RegisterShiftedValEvaluationExpression
  {K : Type*} [Field K]
  {t : Nat}
  (init : InitialState)
  (inc : TwistShout.TimeTable (K := K) 1 5 t)
  (rAddress : Fin 1 → TwistShout.Point (K := K) 5)
  (rCycle : TwistShout.Point (K := K) t) : K :=
  NonZeroInitTwist.ShiftedValEvaluationExpression
    (K := K) (registerInitTable (K := K) init) inc rAddress rCycle

def RamShiftedTimeTable
  {K : Type*} [Field K]
  {t : Nat}
  (init : InitialState)
  (inc : TwistShout.TimeTable (K := K) 1 13 t) :
  TwistShout.TimeTable (K := K) 1 13 t :=
  NonZeroInitTwist.ShiftedTimeTable (K := K) (ramInitTable (K := K) init) inc

def RamShiftedVirtualValue
  {K : Type*} [Field K]
  {t : Nat}
  (init : InitialState)
  (inc : TwistShout.TimeTable (K := K) 1 13 t)
  (a : RamAddress)
  (rCycle : TwistShout.Point (K := K) t) : K :=
  NonZeroInitTwist.ShiftedVirtualValue (K := K) (ramInitTable (K := K) init) inc a rCycle

def RamShiftedValEvaluationExpression
  {K : Type*} [Field K]
  {t : Nat}
  (init : InitialState)
  (inc : TwistShout.TimeTable (K := K) 1 13 t)
  (rAddress : Fin 1 → TwistShout.Point (K := K) 13)
  (rCycle : TwistShout.Point (K := K) t) : K :=
  NonZeroInitTwist.ShiftedValEvaluationExpression
    (K := K) (ramInitTable (K := K) init) inc rAddress rCycle

def registerReadXValue
  {Addr : Type*}
  (pre : MachineState)
  (dec : DecodedStep Addr) : Nat :=
  registerSlotValue pre (projectedNatAddressAt dec .regRaX)

def registerReadYValue
  {Addr : Type*}
  (pre : MachineState)
  (dec : DecodedStep Addr) : Nat :=
  registerSlotValue pre (projectedNatAddressAt dec .regRaY)

def registerReadIValue
  {Addr : Type*}
  (pre : MachineState)
  (dec : DecodedStep Addr) : Nat :=
  registerSlotValue pre (projectedNatAddressAt dec .regRaI)

def registerWriteValue
  {Addr : Type*}
  (post : MachineState)
  (dec : DecodedStep Addr) : Nat :=
  registerSlotValue post (projectedNatAddressAt dec .regWa)

def ramReadValue
  {Addr : Type*}
  (pre : MachineState)
  (dec : DecodedStep Addr) : Nat :=
  ramSlotValue pre (projectedNatAddressAt dec .ramRa)

def ramWriteValue
  {Addr : Type*}
  (post : MachineState)
  (dec : DecodedStep Addr) : Nat :=
  ramSlotValue post (projectedNatAddressAt dec .ramWa)

def registerWriteClaimValue
  {Addr : Type*}
  (post : MachineState)
  (dec : DecodedStep Addr) : Nat :=
  (dec.writesLookupToX + dec.writesMemToX) * primaryValue post dec +
    dec.writesNnnToI * post.i

def ramReadClaimValue
  {Addr : Type*}
  (pre post : MachineState)
  (dec : DecodedStep Addr) : Nat :=
  dec.readsRam * memValueOf pre post dec

def ramWriteClaimValue
  {Addr : Type*}
  (pre post : MachineState)
  (dec : DecodedStep Addr) : Nat :=
  dec.writesRam * memValueOf pre post dec

def WitnessBinds
  {K Addr : Type*}
  [Field K]
  (pre post : MachineState)
  (dec : DecodedStep Addr)
  (z : Nightstream.Chip8.Witness K) : Prop :=
  z 1 = (pre.pc : K) ∧
    z 2 = (post.pc : K) ∧
    z 3 = (primaryValue pre dec : K) ∧
    z 4 = (secondaryValue pre dec : K) ∧
    z 5 = (primaryValue post dec : K) ∧
    z 6 = (pre.i : K) ∧
    z 7 = (post.i : K) ∧
    z 8 = (dec.kk : K) ∧
    z 9 = (dec.nnnAddr : K) ∧
    z 10 = (dec.nnnWord : K) ∧
    z 20 = (primaryIndex dec : K) ∧
    z 21 = (yIndexOf dec : K) ∧
    z 22 = (burstLastValue dec : K) ∧
    z 23 = (ramAddrValue pre dec : K) ∧
    Nightstream.Chip8.flags z =
      Nightstream.Chip8.behaviorFlags (K := K) dec.behavior

def SourceColumnsBound
  {K Addr : Type*}
  [Field K]
  (pre : MachineState)
  (dec : DecodedStep Addr)
  (z : Nightstream.Chip8.Witness K) : Prop :=
  z 3 = (primaryValue pre dec : K) ∧
    z 4 = (secondaryValue pre dec : K) ∧
    z 6 = (pre.i : K)

def MemValueBound
  {K Addr : Type*}
  [Field K]
  (pre post : MachineState)
  (dec : DecodedStep Addr)
  (z : Nightstream.Chip8.Witness K) : Prop :=
  z 11 = (memValueOf pre post dec : K)

def Stage2LaneLinkBound
  {K Addr : Type*}
  [Field K]
  (pre post : MachineState)
  (dec : DecodedStep Addr)
  (z : Nightstream.Chip8.Witness K) : Prop :=
  z 3 = (primaryValue pre dec : K) ∧
    z 4 = (secondaryValue pre dec : K) ∧
    z 6 = (pre.i : K) ∧
    (((dec.writesLookupToX + dec.writesMemToX : Nat) : K) * z 5 +
        (dec.writesNnnToI : K) * z 7) =
      (registerWriteClaimValue post dec : K) ∧
    (dec.readsRam : K) * z 11 = (ramReadClaimValue pre post dec : K) ∧
    (dec.writesRam : K) * z 11 = (ramWriteClaimValue pre post dec : K)

def RamRafBound
  {K Addr : Type*}
  [Field K]
  (pre : MachineState)
  (dec : DecodedStep Addr)
  (z : Nightstream.Chip8.Witness K) : Prop :=
  (dec.readsRam : K) * z 23 = ((dec.readsRam * currentRamAddr pre dec : Nat) : K) ∧
    (dec.writesRam : K) * z 23 = ((dec.writesRam * currentRamAddr pre dec : Nat) : K)

def RegisterPortsBound
  {Addr : Type*}
  (pre post : MachineState)
  (dec : DecodedStep Addr) : Prop :=
  registerReadXValue pre dec = primaryValue pre dec ∧
    registerReadYValue pre dec = secondaryValue pre dec ∧
    registerReadIValue pre dec = pre.i ∧
    registerWriteValue post dec = registerWriteClaimValue post dec

def RamPortsBound
  {Addr : Type*}
  (pre post : MachineState)
  (dec : DecodedStep Addr) : Prop :=
  ramReadValue pre dec = ramReadClaimValue pre post dec ∧
    ramWriteValue post dec = ramWriteClaimValue pre post dec

def InitialStateBound
  (init : InitialState) : Prop :=
  (∀ addr, addr < 16 → initialRegisterValue init addr = init.v addr) ∧
    initialRegisterValue init 16 = init.i ∧
    initialRegisterValue init regSinkAddr = 0 ∧
    (∀ addr, addr < ramSinkAddr → initialRamValue init addr = init.ram addr) ∧
    initialRamValue init ramSinkAddr = 0

theorem initialStateBound_register
  {init : InitialState}
  (h : InitialStateBound init)
  {addr : Nat}
  (hAddr : addr < 16) :
  initialRegisterValue init addr = init.v addr := by
  exact h.1 addr hAddr

theorem initialStateBound_i
  {init : InitialState}
  (h : InitialStateBound init) :
  initialRegisterValue init 16 = init.i := by
  exact h.2.1

theorem initialStateBound_regSink
  {init : InitialState}
  (h : InitialStateBound init) :
  initialRegisterValue init regSinkAddr = 0 := by
  exact h.2.2.1

theorem initialStateBound_ram
  {init : InitialState}
  (h : InitialStateBound init)
  {addr : Nat}
  (hAddr : addr < ramSinkAddr) :
  initialRamValue init addr = init.ram addr := by
  exact h.2.2.2.1 addr hAddr

theorem initialStateBound_ramSink
  {init : InitialState}
  (h : InitialStateBound init) :
  initialRamValue init ramSinkAddr = 0 := by
  exact h.2.2.2.2

theorem registerInitTable_active
  {K : Type*} [Field K]
  {init : InitialState}
  {a : RegAddress}
  (h : InitialStateBound init)
  (hAddr : regAddressNat a < 16) :
  registerInitTable (K := K) init a = init.v (regAddressNat a) := by
  simpa [registerInitTable] using
    congrArg (fun n : Nat => (n : K)) (initialStateBound_register h hAddr)

theorem registerInitTable_i
  {K : Type*} [Field K]
  {init : InitialState}
  {a : RegAddress}
  (h : InitialStateBound init)
  (hAddr : regAddressNat a = 16) :
  registerInitTable (K := K) init a = init.i := by
  simpa [registerInitTable, hAddr] using
    congrArg (fun n : Nat => (n : K)) (initialStateBound_i h)

theorem registerInitTable_sink
  {K : Type*} [Field K]
  {init : InitialState}
  {a : RegAddress}
  (h : InitialStateBound init)
  (hAddr : regAddressNat a = regSinkAddr) :
  registerInitTable (K := K) init a = 0 := by
  simpa [registerInitTable, hAddr] using
    congrArg (fun n : Nat => (n : K)) (initialStateBound_regSink h)

theorem ramInitTable_active
  {K : Type*} [Field K]
  {init : InitialState}
  {a : RamAddress}
  (h : InitialStateBound init)
  (hAddr : ramAddressNat a < ramSinkAddr) :
  ramInitTable (K := K) init a = init.ram (ramAddressNat a) := by
  simpa [ramInitTable] using
    congrArg (fun n : Nat => (n : K)) (initialStateBound_ram h hAddr)

theorem ramInitTable_sink
  {K : Type*} [Field K]
  {init : InitialState}
  {a : RamAddress}
  (h : InitialStateBound init)
  (hAddr : ramAddressNat a = ramSinkAddr) :
  ramInitTable (K := K) init a = 0 := by
  simpa [ramInitTable, hAddr] using
    congrArg (fun n : Nat => (n : K)) (initialStateBound_ramSink h)

theorem registerShiftedVirtualValue_at_bitCycle
  {K : Type*} [Field K]
  {t : Nat}
  (init : InitialState)
  (inc : TwistShout.TimeTable (K := K) 1 5 t)
  (a : RegAddress)
  (j : TwistShout.CycleCube t) :
  RegisterShiftedVirtualValue init inc a (TwistShout.bitVec (K := K) j) =
    RegisterShiftedTimeTable init inc a j := by
  exact NonZeroInitTwist.shiftedVirtualValue_at_bitCycle
    (K := K) (registerInitTable (K := K) init) inc a j

theorem registerShiftedValEvaluationExpression_eq_timeTableMLE
  {K : Type*} [Field K]
  {t : Nat}
  (init : InitialState)
  (inc : TwistShout.TimeTable (K := K) 1 5 t)
  (rAddress : Fin 1 → TwistShout.Point (K := K) 5)
  (rCycle : TwistShout.Point (K := K) t) :
  TwistShout.timeTableMLE (K := K) (RegisterShiftedTimeTable init inc) rAddress rCycle =
    RegisterShiftedValEvaluationExpression init inc rAddress rCycle := by
  exact NonZeroInitTwist.shiftedValEvaluationExpression_eq_timeTableMLE
    (K := K) (registerInitTable (K := K) init) inc rAddress rCycle

theorem registerTimeTableMLE_shifted_at_bitAddress
  {K : Type*} [Field K]
  {t : Nat}
  (init : InitialState)
  (inc : TwistShout.TimeTable (K := K) 1 5 t)
  (a : RegAddress)
  (rCycle : TwistShout.Point (K := K) t) :
  TwistShout.timeTableMLE (K := K) (RegisterShiftedTimeTable init inc)
      (TwistShout.bitAddress (K := K) a) rCycle =
    RegisterShiftedVirtualValue init inc a rCycle := by
  exact NonZeroInitTwist.timeTableMLE_shiftedTimeTable_at_bitAddress
    (K := K) (registerInitTable (K := K) init) inc a rCycle

theorem ramShiftedVirtualValue_at_bitCycle
  {K : Type*} [Field K]
  {t : Nat}
  (init : InitialState)
  (inc : TwistShout.TimeTable (K := K) 1 13 t)
  (a : RamAddress)
  (j : TwistShout.CycleCube t) :
  RamShiftedVirtualValue init inc a (TwistShout.bitVec (K := K) j) =
    RamShiftedTimeTable init inc a j := by
  exact NonZeroInitTwist.shiftedVirtualValue_at_bitCycle
    (K := K) (ramInitTable (K := K) init) inc a j

theorem ramShiftedValEvaluationExpression_eq_timeTableMLE
  {K : Type*} [Field K]
  {t : Nat}
  (init : InitialState)
  (inc : TwistShout.TimeTable (K := K) 1 13 t)
  (rAddress : Fin 1 → TwistShout.Point (K := K) 13)
  (rCycle : TwistShout.Point (K := K) t) :
  TwistShout.timeTableMLE (K := K) (RamShiftedTimeTable init inc) rAddress rCycle =
    RamShiftedValEvaluationExpression init inc rAddress rCycle := by
  exact NonZeroInitTwist.shiftedValEvaluationExpression_eq_timeTableMLE
    (K := K) (ramInitTable (K := K) init) inc rAddress rCycle

theorem ramTimeTableMLE_shifted_at_bitAddress
  {K : Type*} [Field K]
  {t : Nat}
  (init : InitialState)
  (inc : TwistShout.TimeTable (K := K) 1 13 t)
  (a : RamAddress)
  (rCycle : TwistShout.Point (K := K) t) :
  TwistShout.timeTableMLE (K := K) (RamShiftedTimeTable init inc)
      (TwistShout.bitAddress (K := K) a) rCycle =
    RamShiftedVirtualValue init inc a rCycle := by
  exact NonZeroInitTwist.timeTableMLE_shiftedTimeTable_at_bitAddress
    (K := K) (ramInitTable (K := K) init) inc a rCycle

theorem initialStateBound_exact
  (init : InitialState) :
  InitialStateBound init := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · intro addr hAddr
    simp [initialRegisterValue, hAddr]
  · simp [initialRegisterValue]
  · simp [initialRegisterValue, regSinkAddr]
  · intro addr hAddr
    simp [initialRamValue, hAddr]
  · simp [initialRamValue, ramSinkAddr]

def LocalMemoryBound
  {K Addr : Type*}
  [Field K]
  (pre post : MachineState)
  (dec : DecodedStep Addr)
  (z : Nightstream.Chip8.Witness K) : Prop :=
  WitnessBinds (K := K) pre post dec z ∧
    MemValueBound (K := K) pre post dec z ∧
    Stage2LaneLinkBound (K := K) pre post dec z

def MemoryBound
  {K Addr : Type*}
  [Field K]
  (pre post : MachineState)
  (init : InitialState)
  (dec : DecodedStep Addr)
  (z : Nightstream.Chip8.Witness K) : Prop :=
  LocalMemoryBound (K := K) pre post dec z ∧
    RegisterPortsBound pre post dec ∧
    RamPortsBound pre post dec ∧
    RamRafBound (K := K) pre dec z ∧
    InitialStateBound init

def registerReadsExpected
  {Addr : Type*}
  (pre : MachineState)
  (_post : MachineState)
  (dec : DecodedStep Addr) : List RegisterAccess :=
  [⟨projectedNatAddressAt dec .regRaX, registerReadXValue pre dec⟩,
    ⟨projectedNatAddressAt dec .regRaY, registerReadYValue pre dec⟩,
    ⟨projectedNatAddressAt dec .regRaI, registerReadIValue pre dec⟩]

def registerWritesExpected
  {Addr : Type*}
  (_pre : MachineState)
  (post : MachineState)
  (dec : DecodedStep Addr) : List RegisterAccess :=
  [⟨projectedNatAddressAt dec .regWa, registerWriteValue post dec⟩]

def ramReadsExpected
  {Addr : Type*}
  (pre : MachineState)
  (_post : MachineState)
  (dec : DecodedStep Addr) : List RamAccess :=
  [⟨projectedNatAddressAt dec .ramRa, ramReadValue pre dec⟩]

def ramWritesExpected
  {Addr : Type*}
  (_pre : MachineState)
  (post : MachineState)
  (dec : DecodedStep Addr) : List RamAccess :=
  [⟨projectedNatAddressAt dec .ramWa, ramWriteValue post dec⟩]

def expectedMemoryTrace
  {Addr : Type*}
  (pre post : MachineState)
  (dec : DecodedStep Addr) : StepMemoryTrace :=
  ⟨registerReadsExpected pre post dec,
    registerWritesExpected pre post dec,
    ramReadsExpected pre post dec,
    ramWritesExpected pre post dec⟩

def TraceMatches
  {Addr : Type*}
  (pre post : MachineState)
  (dec : DecodedStep Addr)
  (tr : StepMemoryTrace) : Prop :=
  tr = expectedMemoryTrace pre post dec

theorem witnessBinds_pc
  {K Addr : Type*}
  [Field K]
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness K}
  (h : WitnessBinds (K := K) pre post dec z) :
  z 1 = (pre.pc : K) := by
  exact h.1

theorem witnessBinds_pcNext
  {K Addr : Type*}
  [Field K]
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness K}
  (h : WitnessBinds (K := K) pre post dec z) :
  z 2 = (post.pc : K) := by
  exact h.2.1

theorem witnessBinds_vx
  {K Addr : Type*}
  [Field K]
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness K}
  (h : WitnessBinds (K := K) pre post dec z) :
  z 3 = (primaryValue pre dec : K) := by
  exact h.2.2.1

theorem witnessBinds_vy
  {K Addr : Type*}
  [Field K]
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness K}
  (h : WitnessBinds (K := K) pre post dec z) :
  z 4 = (secondaryValue pre dec : K) := by
  exact h.2.2.2.1

theorem witnessBinds_vxNext
  {K Addr : Type*}
  [Field K]
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness K}
  (h : WitnessBinds (K := K) pre post dec z) :
  z 5 = (primaryValue post dec : K) := by
  exact h.2.2.2.2.1

theorem witnessBinds_iReg
  {K Addr : Type*}
  [Field K]
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness K}
  (h : WitnessBinds (K := K) pre post dec z) :
  z 6 = (pre.i : K) := by
  exact h.2.2.2.2.2.1

theorem witnessBinds_iNext
  {K Addr : Type*}
  [Field K]
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness K}
  (h : WitnessBinds (K := K) pre post dec z) :
  z 7 = (post.i : K) := by
  exact h.2.2.2.2.2.2.1

theorem witnessBinds_kk
  {K Addr : Type*}
  [Field K]
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness K}
  (h : WitnessBinds (K := K) pre post dec z) :
  z 8 = (dec.kk : K) := by
  exact h.2.2.2.2.2.2.2.1

theorem witnessBinds_nnnAddr
  {K Addr : Type*}
  [Field K]
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness K}
  (h : WitnessBinds (K := K) pre post dec z) :
  z 9 = (dec.nnnAddr : K) := by
  exact h.2.2.2.2.2.2.2.2.1

theorem witnessBinds_nnnWord
  {K Addr : Type*}
  [Field K]
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness K}
  (h : WitnessBinds (K := K) pre post dec z) :
  z 10 = (dec.nnnWord : K) := by
  exact h.2.2.2.2.2.2.2.2.2.1

theorem witnessBinds_xIdx
  {K Addr : Type*}
  [Field K]
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness K}
  (h : WitnessBinds (K := K) pre post dec z) :
  z 20 = (primaryIndex dec : K) := by
  exact h.2.2.2.2.2.2.2.2.2.2.1

theorem witnessBinds_yIdx
  {K Addr : Type*}
  [Field K]
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness K}
  (h : WitnessBinds (K := K) pre post dec z) :
  z 21 = (yIndexOf dec : K) := by
  exact h.2.2.2.2.2.2.2.2.2.2.2.1

theorem witnessBinds_burstLast
  {K Addr : Type*}
  [Field K]
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness K}
  (h : WitnessBinds (K := K) pre post dec z) :
  z 22 = (burstLastValue dec : K) := by
  exact h.2.2.2.2.2.2.2.2.2.2.2.2.1

theorem witnessBinds_ramAddr
  {K Addr : Type*}
  [Field K]
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness K}
  (h : WitnessBinds (K := K) pre post dec z) :
  z 23 = (ramAddrValue pre dec : K) := by
  exact h.2.2.2.2.2.2.2.2.2.2.2.2.2.1

theorem witnessBinds_nnn
  {K Addr : Type*}
  [Field K]
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness K}
  (h : WitnessBinds (K := K) pre post dec z) :
  z 9 = (dec.nnn : K) := by
  simpa [DecodedCore.nnn, DecodedStep.toDecodedCore] using witnessBinds_nnnAddr h

theorem witnessBinds_flags
  {K Addr : Type*}
  [Field K]
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness K}
  (h : WitnessBinds (K := K) pre post dec z) :
  Nightstream.Chip8.flags z =
    Nightstream.Chip8.behaviorFlags (K := K) dec.behavior := by
  exact h.2.2.2.2.2.2.2.2.2.2.2.2.2.2

theorem witnessBinds_flags_mem_decodeImage
  {K Addr : Type*}
  [Field K]
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness K}
  (h : WitnessBinds (K := K) pre post dec z) :
  Nightstream.Chip8.flags z ∈ Nightstream.Chip8.decodeImage (K := K) := by
  rw [witnessBinds_flags h]
  exact behaviorOfOpcode_mem_decodeImage dec.opcodeId

theorem sourceColumnsBound_vx
  {K Addr : Type*}
  [Field K]
  {pre : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness K}
  (h : SourceColumnsBound (K := K) pre dec z) :
  z 3 = (primaryValue pre dec : K) := by
  exact h.1

theorem sourceColumnsBound_vy
  {K Addr : Type*}
  [Field K]
  {pre : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness K}
  (h : SourceColumnsBound (K := K) pre dec z) :
  z 4 = (secondaryValue pre dec : K) := by
  exact h.2.1

theorem sourceColumnsBound_iReg
  {K Addr : Type*}
  [Field K]
  {pre : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness K}
  (h : SourceColumnsBound (K := K) pre dec z) :
  z 6 = (pre.i : K) := by
  exact h.2.2

theorem localMemoryBound_witness
  {K Addr : Type*}
  [Field K]
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness K}
  (h : LocalMemoryBound (K := K) pre post dec z) :
  WitnessBinds (K := K) pre post dec z := by
  exact h.1

theorem localMemoryBound_memValue
  {K Addr : Type*}
  [Field K]
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness K}
  (h : LocalMemoryBound (K := K) pre post dec z) :
  z 11 = (memValueOf pre post dec : K) := by
  exact h.2.1

theorem memoryBound_vx
  {K Addr : Type*}
  [Field K]
  {pre post : MachineState}
  {init : InitialState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness K}
  (h : MemoryBound (K := K) pre post init dec z) :
  z 3 = (primaryValue pre dec : K) := by
  exact witnessBinds_vx h.1.1

theorem memoryBound_vy
  {K Addr : Type*}
  [Field K]
  {pre post : MachineState}
  {init : InitialState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness K}
  (h : MemoryBound (K := K) pre post init dec z) :
  z 4 = (secondaryValue pre dec : K) := by
  exact witnessBinds_vy h.1.1

theorem memoryBound_iReg
  {K Addr : Type*}
  [Field K]
  {pre post : MachineState}
  {init : InitialState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness K}
  (h : MemoryBound (K := K) pre post init dec z) :
  z 6 = (pre.i : K) := by
  exact witnessBinds_iReg h.1.1

theorem memoryBound_memValue
  {K Addr : Type*}
  [Field K]
  {pre post : MachineState}
  {init : InitialState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness K}
  (h : MemoryBound (K := K) pre post init dec z) :
  z 11 = (memValueOf pre post dec : K) := by
  exact localMemoryBound_memValue h.1

theorem memoryBound_storeRegs_value
  {K Addr : Type*}
  [Field K]
  {pre post : MachineState}
  {init : InitialState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness K}
  (hMem : MemoryBound (K := K) pre post init dec z)
  (hWrite : dec.writesRam = 1) :
  z 11 = (primaryValue pre dec : K) := by
  simpa [memValueOf, hWrite] using memoryBound_memValue hMem

theorem memoryBound_loadRegs_value
  {K Addr : Type*}
  [Field K]
  {pre post : MachineState}
  {init : InitialState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness K}
  (hMem : MemoryBound (K := K) pre post init dec z)
  (hNoWrite : dec.writesRam ≠ 1)
  (hRead : dec.readsRam = 1) :
  z 11 = (primaryValue post dec : K) := by
  have hVal := memoryBound_memValue hMem
  simp [memValueOf, hNoWrite, hRead] at hVal
  exact hVal

theorem memoryBound_nonMemOp_value_zero
  {K Addr : Type*}
  [Field K]
  {pre post : MachineState}
  {init : InitialState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness K}
  (hMem : MemoryBound (K := K) pre post init dec z)
  (hNoWrite : dec.writesRam ≠ 1)
  (hNoRead : dec.readsRam ≠ 1) :
  z 11 = (0 : K) := by
  have hVal := memoryBound_memValue hMem
  simp [memValueOf, hNoWrite, hNoRead] at hVal
  exact hVal

theorem memoryBound_registerPorts
  {K Addr : Type*}
  [Field K]
  {pre post : MachineState}
  {init : InitialState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness K}
  (h : MemoryBound (K := K) pre post init dec z) :
  RegisterPortsBound pre post dec := by
  exact h.2.1

theorem memoryBound_ramPorts
  {K Addr : Type*}
  [Field K]
  {pre post : MachineState}
  {init : InitialState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness K}
  (h : MemoryBound (K := K) pre post init dec z) :
  RamPortsBound pre post dec := by
  exact h.2.2.1

theorem memoryBound_ramRaf
  {K Addr : Type*}
  [Field K]
  {pre post : MachineState}
  {init : InitialState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness K}
  (h : MemoryBound (K := K) pre post init dec z) :
  RamRafBound (K := K) pre dec z := by
  exact h.2.2.2.1

theorem memoryBound_initialState
  {K Addr : Type*}
  [Field K]
  {pre post : MachineState}
  {init : InitialState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness K}
  (h : MemoryBound (K := K) pre post init dec z) :
  InitialStateBound init := by
  exact h.2.2.2.2

theorem traceMatches_registerReads
  {Addr : Type*}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {tr : StepMemoryTrace}
  (h : TraceMatches pre post dec tr) :
  tr.registerReads = registerReadsExpected pre post dec := by
  simpa [TraceMatches, expectedMemoryTrace] using congrArg StepMemoryTrace.registerReads h

theorem traceMatches_registerWrites
  {Addr : Type*}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {tr : StepMemoryTrace}
  (h : TraceMatches pre post dec tr) :
  tr.registerWrites = registerWritesExpected pre post dec := by
  simpa [TraceMatches, expectedMemoryTrace] using congrArg StepMemoryTrace.registerWrites h

theorem traceMatches_ramReads
  {Addr : Type*}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {tr : StepMemoryTrace}
  (h : TraceMatches pre post dec tr) :
  tr.ramReads = ramReadsExpected pre post dec := by
  simpa [TraceMatches, expectedMemoryTrace] using congrArg StepMemoryTrace.ramReads h

theorem traceMatches_ramWrites
  {Addr : Type*}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {tr : StepMemoryTrace}
  (h : TraceMatches pre post dec tr) :
  tr.ramWrites = ramWritesExpected pre post dec := by
  simpa [TraceMatches, expectedMemoryTrace] using congrArg StepMemoryTrace.ramWrites h

theorem storeRegs_trace_counts
  {Addr : Type*}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  (_hOpcode : dec.opcodeId = .storeRegs) :
  (expectedMemoryTrace pre post dec).registerReads.length = 3 ∧
    (expectedMemoryTrace pre post dec).ramWrites.length = 1 := by
  constructor <;> simp [expectedMemoryTrace, registerReadsExpected, ramWritesExpected]

theorem loadRegs_trace_counts
  {Addr : Type*}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  (_hOpcode : dec.opcodeId = .loadRegs) :
  (expectedMemoryTrace pre post dec).ramReads.length = 1 ∧
    (expectedMemoryTrace pre post dec).registerWrites.length = 1 := by
  constructor <;> simp [expectedMemoryTrace, ramReadsExpected, registerWritesExpected]

end Nightstream.Chip8.WitnessMemoryBinding
