namespace Nightstream

def ShoutReadOnlySound
  {T : Nat}
  {Address Value : Type}
  (table : Address → Value)
  (raf : Fin T → Address)
  (rv : Fin T → Value) : Prop :=
  ∀ j, rv j = table (raf j)

def NoPriorWrite
  {T : Nat}
  {Address : Type}
  (waf : Fin T → Address)
  (address : Address)
  (j : Fin T) : Prop :=
  ∀ j', j' < j → waf j' ≠ address

def LatestWriteAt
  {T : Nat}
  {Address : Type}
  (waf : Fin T → Address)
  (address : Address)
  (jWrite jRead : Fin T) : Prop :=
  jWrite < jRead ∧
    waf jWrite = address ∧
    ∀ j', j' < jRead → waf j' = address → j' ≤ jWrite

def TwistReadWriteSound
  {T : Nat}
  {Address Value : Type}
  (init : Address → Value)
  (raf : Fin T → Address)
  (rv : Fin T → Value)
  (waf : Fin T → Address)
  (wv : Fin T → Value) : Prop :=
  ∀ j,
    (NoPriorWrite waf (raf j) j → rv j = init (raf j)) ∧
    (∀ jWrite, LatestWriteAt waf (raf j) jWrite j → rv j = wv jWrite)

def TwistReadWriteSoundZeroInit
  {T : Nat}
  {Address Value : Type}
  [Zero Value]
  (raf : Fin T → Address)
  (rv : Fin T → Value)
  (waf : Fin T → Address)
  (wv : Fin T → Value) : Prop :=
  TwistReadWriteSound (fun _ => 0) raf rv waf wv

theorem shoutReadOnlySound_value
  {T : Nat}
  {Address Value : Type}
  {table : Address → Value}
  {raf : Fin T → Address}
  {rv : Fin T → Value}
  (hSound : ShoutReadOnlySound table raf rv)
  (j : Fin T) :
  rv j = table (raf j) := by
  exact hSound j

theorem twistReadWriteSound_reads_initial_when_no_prior_write
  {T : Nat}
  {Address Value : Type}
  {init : Address → Value}
  {raf : Fin T → Address}
  {rv : Fin T → Value}
  {waf : Fin T → Address}
  {wv : Fin T → Value}
  (hSound : TwistReadWriteSound init raf rv waf wv)
  {j : Fin T}
  (hNoPrior : NoPriorWrite waf (raf j) j) :
  rv j = init (raf j) := by
  exact (hSound j).1 hNoPrior

theorem twistReadWriteSound_reads_latest_write
  {T : Nat}
  {Address Value : Type}
  {init : Address → Value}
  {raf : Fin T → Address}
  {rv : Fin T → Value}
  {waf : Fin T → Address}
  {wv : Fin T → Value}
  (hSound : TwistReadWriteSound init raf rv waf wv)
  {j jWrite : Fin T}
  (hLatest : LatestWriteAt waf (raf j) jWrite j) :
  rv j = wv jWrite := by
  exact (hSound j).2 jWrite hLatest

theorem twistReadWriteSoundZeroInit_eq
  {T : Nat}
  {Address Value : Type}
  [Zero Value]
  {raf : Fin T → Address}
  {rv : Fin T → Value}
  {waf : Fin T → Address}
  {wv : Fin T → Value} :
  TwistReadWriteSoundZeroInit raf rv waf wv =
    TwistReadWriteSound (fun _ => (0 : Value)) raf rv waf wv := by
  rfl

end Nightstream
