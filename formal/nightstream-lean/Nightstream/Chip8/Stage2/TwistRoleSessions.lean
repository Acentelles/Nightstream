import Nightstream.Chip8.Stage2.EvidenceCoverageBounds

/-!
Owns extraction of explicit row-local Twist session witnesses from one
Stage-2 temporal seed. This file does not reconstruct trace-global timelines;
it only turns the seed's existential coverage facts into named register/RAM
session objects and exports their authenticated claim-membership facts.
-/

namespace Nightstream.Chip8.TwistRoleSessions

open Nightstream.Chip8
open Nightstream.Chip8.EvidenceCoverage
open Nightstream.Chip8.FetchDecodeBinding
open Nightstream.Chip8.DecodeAddressBinding

abbrev F := EvidenceCoverage.F
abbrev MachineState := WitnessMemoryBinding.MachineState

section Evidence

variable
  {AuxIndex EvalPoint AddressPoint CyclePoint AddressColumns Addr ValSurface
    Increment SessionKey : Type*}

structure RegisterRoleSessions
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  {Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {stepIdx : Nat}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  (seed :
    RegisterTemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ stepIdx pre post dec z) where
  readX :
    TwistSessionWitness (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation
  readX_mem : readX ∈ seed.registerRegistry.sessions
  readX_addr : AddressProvenanceAt dec stepIdx .regRaX readX.read.addr
  readX_val : readX.read.rv = WitnessMemoryBinding.registerReadXValue pre dec
  readY :
    TwistSessionWitness (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation
  readY_mem : readY ∈ seed.registerRegistry.sessions
  readY_addr : AddressProvenanceAt dec stepIdx .regRaY readY.read.addr
  readY_val : readY.read.rv = WitnessMemoryBinding.registerReadYValue pre dec
  readI :
    TwistSessionWitness (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation
  readI_mem : readI ∈ seed.registerRegistry.sessions
  readI_addr : AddressProvenanceAt dec stepIdx .regRaI readI.read.addr
  readI_val : readI.read.rv = WitnessMemoryBinding.registerReadIValue pre dec
  writeReg :
    TwistSessionWitness (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation
  writeReg_mem : writeReg ∈ seed.registerRegistry.sessions
  writeReg_addr : AddressProvenanceAt dec stepIdx .regWa writeReg.write.addr
  writeReg_val :
    writeReg.write.wv = WitnessMemoryBinding.registerWriteClaimValue post dec

structure LoadRamRoleSession
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  {Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {stepIdx : Nat}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  (seed :
    RamTemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ stepIdx pre post dec z) where
  readMem :
    TwistSessionWitness (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation
  readMem_mem : readMem ∈ seed.ramRegistry.sessions
  readMem_addr : AddressProvenanceAt dec stepIdx .readMem readMem.read.addr
  readMem_val :
    readMem.read.rv = WitnessMemoryBinding.ramReadClaimValue pre post dec

structure StoreRamRoleSession
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  {Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {stepIdx : Nat}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  (seed :
    RamTemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ stepIdx pre post dec z) where
  writeMem :
    TwistSessionWitness (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation
  writeMem_mem : writeMem ∈ seed.ramRegistry.sessions
  writeMem_addr : AddressProvenanceAt dec stepIdx .writeMem writeMem.write.addr
  writeMem_val :
    writeMem.write.wv = WitnessMemoryBinding.ramWriteClaimValue pre post dec

noncomputable def registerRoleSessions_of_seed
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  {Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {stepIdx : Nat}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  (seed :
    RegisterTemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ stepIdx pre post dec z) :
  RegisterRoleSessions readSessionKey pairedSessionKey validAddressColumns
    kernelAddressBound rwReadCheckExpression writeCheckExpression
    valEvaluationExpression readWriteMemoryRelation incrementRelation seed := by
  classical
  let readXv := Classical.choose seed.readXValueCovered
  have hReadXv :
      readXv ∈ seed.registerRegistry.sessions ∧
        AddressProvenanceAt dec stepIdx .regRaX readXv.read.addr ∧
          readXv.read.rv = WitnessMemoryBinding.registerReadXValue pre dec :=
    Classical.choose_spec seed.readXValueCovered
  let readYv := Classical.choose seed.readYValueCovered
  have hReadYv :
      readYv ∈ seed.registerRegistry.sessions ∧
        AddressProvenanceAt dec stepIdx .regRaY readYv.read.addr ∧
          readYv.read.rv = WitnessMemoryBinding.registerReadYValue pre dec :=
    Classical.choose_spec seed.readYValueCovered
  let readIv := Classical.choose seed.readIValueCovered
  have hReadIv :
      readIv ∈ seed.registerRegistry.sessions ∧
        AddressProvenanceAt dec stepIdx .regRaI readIv.read.addr ∧
          readIv.read.rv = WitnessMemoryBinding.registerReadIValue pre dec :=
    Classical.choose_spec seed.readIValueCovered
  let writeRegv := Classical.choose seed.writeRegValueCovered
  have hWritev :
      writeRegv ∈ seed.registerRegistry.sessions ∧
        AddressProvenanceAt dec stepIdx .regWa writeRegv.write.addr ∧
          writeRegv.write.wv =
            WitnessMemoryBinding.registerWriteClaimValue post dec :=
    Classical.choose_spec seed.writeRegValueCovered
  exact
    { readX := readXv
      readX_mem := hReadXv.1
      readX_addr := hReadXv.2.1
      readX_val := hReadXv.2.2
      readY := readYv
      readY_mem := hReadYv.1
      readY_addr := hReadYv.2.1
      readY_val := hReadYv.2.2
      readI := readIv
      readI_mem := hReadIv.1
      readI_addr := hReadIv.2.1
      readI_val := hReadIv.2.2
      writeReg := writeRegv
      writeReg_mem := hWritev.1
      writeReg_addr := hWritev.2.1
      writeReg_val := hWritev.2.2 }

noncomputable def loadRamRoleSession_of_seed
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  {Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {stepIdx : Nat}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  (seed :
    RamTemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ stepIdx pre post dec z)
  (hLoad : dec.opcodeId = .loadRegs) :
  LoadRamRoleSession readSessionKey pairedSessionKey validAddressColumns
    kernelAddressBound rwReadCheckExpression writeCheckExpression
    valEvaluationExpression readWriteMemoryRelation incrementRelation seed := by
  classical
  let readMemv := Classical.choose (seed.loadReadValueCovered hLoad)
  have hReadv :
      readMemv ∈ seed.ramRegistry.sessions ∧
        AddressProvenanceAt dec stepIdx .readMem readMemv.read.addr ∧
          readMemv.read.rv =
            WitnessMemoryBinding.ramReadClaimValue pre post dec :=
    Classical.choose_spec (seed.loadReadValueCovered hLoad)
  exact
    { readMem := readMemv
      readMem_mem := hReadv.1
      readMem_addr := hReadv.2.1
      readMem_val := hReadv.2.2 }

noncomputable def storeRamRoleSession_of_seed
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  {Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {stepIdx : Nat}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  (seed :
    RamTemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ stepIdx pre post dec z)
  (hStore : dec.opcodeId = .storeRegs) :
  StoreRamRoleSession readSessionKey pairedSessionKey validAddressColumns
    kernelAddressBound rwReadCheckExpression writeCheckExpression
    valEvaluationExpression readWriteMemoryRelation incrementRelation seed := by
  classical
  let writeMemv := Classical.choose (seed.storeWriteValueCovered hStore)
  have hWritev :
      writeMemv ∈ seed.ramRegistry.sessions ∧
        AddressProvenanceAt dec stepIdx .writeMem writeMemv.write.addr ∧
          writeMemv.write.wv =
            WitnessMemoryBinding.ramWriteClaimValue pre post dec :=
    Classical.choose_spec (seed.storeWriteValueCovered hStore)
  exact
    { writeMem := writeMemv
      writeMem_mem := hWritev.1
      writeMem_addr := hWritev.2.1
      writeMem_val := hWritev.2.2 }

theorem twistSessionWitness_readKey_eq_key
  {readSessionKey : EvalPoint → SessionKey}
  {pairedSessionKey : AddressPoint → CyclePoint → SessionKey}
  {validAddressColumns : AddressColumns → Addr → Prop}
  {kernelAddressBound : Addr → Prop}
  {rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F}
  {writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → F}
  {readWriteMemoryRelation : ValSurface → Addr → Nat → Prop}
  {incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop}
  {session :
    TwistSessionWitness (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation} :
  readSessionKey session.read.point = session.key := by
  exact session.provenance.1

theorem twistSessionWitness_writeKey_eq_key
  {readSessionKey : EvalPoint → SessionKey}
  {pairedSessionKey : AddressPoint → CyclePoint → SessionKey}
  {validAddressColumns : AddressColumns → Addr → Prop}
  {kernelAddressBound : Addr → Prop}
  {rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F}
  {writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → F}
  {readWriteMemoryRelation : ValSurface → Addr → Nat → Prop}
  {incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop}
  {session :
    TwistSessionWitness (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation} :
  pairedSessionKey session.write.qa session.write.qc = session.key := by
  exact session.provenance.2.1

theorem twistSessionWitness_valKey_eq_key
  {readSessionKey : EvalPoint → SessionKey}
  {pairedSessionKey : AddressPoint → CyclePoint → SessionKey}
  {validAddressColumns : AddressColumns → Addr → Prop}
  {kernelAddressBound : Addr → Prop}
  {rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F}
  {writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → F}
  {readWriteMemoryRelation : ValSurface → Addr → Nat → Prop}
  {incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop}
  {session :
    TwistSessionWitness (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation} :
  pairedSessionKey session.valClaim.qa session.valClaim.qc = session.key := by
  exact session.provenance.2.2.1

theorem twistSessionWitness_readVal_eq_writeVal
  {readSessionKey : EvalPoint → SessionKey}
  {pairedSessionKey : AddressPoint → CyclePoint → SessionKey}
  {validAddressColumns : AddressColumns → Addr → Prop}
  {kernelAddressBound : Addr → Prop}
  {rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F}
  {writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → F}
  {readWriteMemoryRelation : ValSurface → Addr → Nat → Prop}
  {incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop}
  {session :
    TwistSessionWitness (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation} :
  session.read.val = session.write.val := by
  exact session.provenance.2.2.2.1

theorem twistSessionWitness_writeVal_eq_valClaimVal
  {readSessionKey : EvalPoint → SessionKey}
  {pairedSessionKey : AddressPoint → CyclePoint → SessionKey}
  {validAddressColumns : AddressColumns → Addr → Prop}
  {kernelAddressBound : Addr → Prop}
  {rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F}
  {writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → F}
  {readWriteMemoryRelation : ValSurface → Addr → Nat → Prop}
  {incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop}
  {session :
    TwistSessionWitness (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation} :
  session.write.val = session.valClaim.val := by
  exact session.provenance.2.2.2.2

theorem twistSessionWitness_readVal_eq_valClaimVal
  {readSessionKey : EvalPoint → SessionKey}
  {pairedSessionKey : AddressPoint → CyclePoint → SessionKey}
  {validAddressColumns : AddressColumns → Addr → Prop}
  {kernelAddressBound : Addr → Prop}
  {rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F}
  {writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → F}
  {readWriteMemoryRelation : ValSurface → Addr → Nat → Prop}
  {incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop}
  {session :
    TwistSessionWitness (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation} :
  session.read.val = session.valClaim.val := by
  exact
    (twistSessionWitness_readVal_eq_writeVal (session := session)).trans
      (twistSessionWitness_writeVal_eq_valClaimVal (session := session))

theorem registerSessionClaimsInΓ₃_of_seed
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  {Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {stepIdx : Nat}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  (seed :
    RegisterTemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ stepIdx pre post dec z)
  {session :
    TwistSessionWitness (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation}
  (hMem : session ∈ seed.registerRegistry.sessions) :
  session.read.claim ∈ Γ₃ ∧
    session.write.claim ∈ Γ₃ ∧
    session.valClaim.claim ∈ Γ₃ := by
  exact (twistSessionClosed_membersInClaims seed.registerTwistClosed) session hMem

theorem ramSessionClaimsInΓ₃_of_seed
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  {Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {stepIdx : Nat}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  (seed :
    RamTemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ stepIdx pre post dec z)
  {session :
    TwistSessionWitness (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation}
  (hMem : session ∈ seed.ramRegistry.sessions) :
  session.read.claim ∈ Γ₃ ∧
    session.write.claim ∈ Γ₃ ∧
    session.valClaim.claim ∈ Γ₃ := by
  exact (twistSessionClosed_membersInClaims seed.ramTwistClosed) session hMem

theorem registerRoleSessions_readXClaimsInΓ₃
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  {Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {stepIdx : Nat}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  (seed :
    RegisterTemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ stepIdx pre post dec z) :
  let roles :=
    registerRoleSessions_of_seed readSessionKey pairedSessionKey
      validAddressColumns kernelAddressBound rwReadCheckExpression
      writeCheckExpression valEvaluationExpression readWriteMemoryRelation
      incrementRelation seed
  roles.readX.read.claim ∈ Γ₃ ∧
    roles.readX.write.claim ∈ Γ₃ ∧
    roles.readX.valClaim.claim ∈ Γ₃ := by
  dsimp
  exact registerSessionClaimsInΓ₃_of_seed
    readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
    rwReadCheckExpression writeCheckExpression valEvaluationExpression
    readWriteMemoryRelation incrementRelation seed
    ((registerRoleSessions_of_seed
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation seed).readX_mem)

theorem registerRoleSessions_readYClaimsInΓ₃
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  {Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {stepIdx : Nat}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  (seed :
    RegisterTemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ stepIdx pre post dec z) :
  let roles :=
    registerRoleSessions_of_seed readSessionKey pairedSessionKey
      validAddressColumns kernelAddressBound rwReadCheckExpression
      writeCheckExpression valEvaluationExpression readWriteMemoryRelation
      incrementRelation seed
  roles.readY.read.claim ∈ Γ₃ ∧
    roles.readY.write.claim ∈ Γ₃ ∧
    roles.readY.valClaim.claim ∈ Γ₃ := by
  dsimp
  exact registerSessionClaimsInΓ₃_of_seed
    readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
    rwReadCheckExpression writeCheckExpression valEvaluationExpression
    readWriteMemoryRelation incrementRelation seed
    ((registerRoleSessions_of_seed
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation seed).readY_mem)

theorem registerRoleSessions_readIClaimsInΓ₃
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  {Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {stepIdx : Nat}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  (seed :
    RegisterTemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ stepIdx pre post dec z) :
  let roles :=
    registerRoleSessions_of_seed readSessionKey pairedSessionKey
      validAddressColumns kernelAddressBound rwReadCheckExpression
      writeCheckExpression valEvaluationExpression readWriteMemoryRelation
      incrementRelation seed
  roles.readI.read.claim ∈ Γ₃ ∧
    roles.readI.write.claim ∈ Γ₃ ∧
    roles.readI.valClaim.claim ∈ Γ₃ := by
  dsimp
  exact registerSessionClaimsInΓ₃_of_seed
    readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
    rwReadCheckExpression writeCheckExpression valEvaluationExpression
    readWriteMemoryRelation incrementRelation seed
    ((registerRoleSessions_of_seed
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation seed).readI_mem)

theorem registerRoleSessions_writeRegClaimsInΓ₃
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  {Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {stepIdx : Nat}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  (seed :
    RegisterTemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ stepIdx pre post dec z) :
  let roles :=
    registerRoleSessions_of_seed readSessionKey pairedSessionKey
      validAddressColumns kernelAddressBound rwReadCheckExpression
      writeCheckExpression valEvaluationExpression readWriteMemoryRelation
      incrementRelation seed
  roles.writeReg.read.claim ∈ Γ₃ ∧
    roles.writeReg.write.claim ∈ Γ₃ ∧
    roles.writeReg.valClaim.claim ∈ Γ₃ := by
  dsimp
  exact registerSessionClaimsInΓ₃_of_seed
    readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
    rwReadCheckExpression writeCheckExpression valEvaluationExpression
    readWriteMemoryRelation incrementRelation seed
    ((registerRoleSessions_of_seed
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation seed).writeReg_mem)

theorem loadRamRoleSession_claimsInΓ₃
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  {Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {stepIdx : Nat}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  (seed :
    RamTemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ stepIdx pre post dec z)
  (hLoad : dec.opcodeId = .loadRegs) :
  let session :=
    loadRamRoleSession_of_seed readSessionKey pairedSessionKey
      validAddressColumns kernelAddressBound rwReadCheckExpression
      writeCheckExpression valEvaluationExpression readWriteMemoryRelation
      incrementRelation seed hLoad
  session.readMem.read.claim ∈ Γ₃ ∧
    session.readMem.write.claim ∈ Γ₃ ∧
    session.readMem.valClaim.claim ∈ Γ₃ := by
  dsimp
  exact ramSessionClaimsInΓ₃_of_seed
    readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
    rwReadCheckExpression writeCheckExpression valEvaluationExpression
    readWriteMemoryRelation incrementRelation seed
    ((loadRamRoleSession_of_seed
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation seed hLoad).readMem_mem)

theorem storeRamRoleSession_claimsInΓ₃
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  {Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {stepIdx : Nat}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  (seed :
    RamTemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ stepIdx pre post dec z)
  (hStore : dec.opcodeId = .storeRegs) :
  let session :=
    storeRamRoleSession_of_seed readSessionKey pairedSessionKey
      validAddressColumns kernelAddressBound rwReadCheckExpression
      writeCheckExpression valEvaluationExpression readWriteMemoryRelation
      incrementRelation seed hStore
  session.writeMem.read.claim ∈ Γ₃ ∧
    session.writeMem.write.claim ∈ Γ₃ ∧
    session.writeMem.valClaim.claim ∈ Γ₃ := by
  dsimp
  exact ramSessionClaimsInΓ₃_of_seed
    readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
    rwReadCheckExpression writeCheckExpression valEvaluationExpression
    readWriteMemoryRelation incrementRelation seed
    ((storeRamRoleSession_of_seed
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation seed hStore).writeMem_mem)

theorem registerRoleSessions_readXValue_eq_primaryValue
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  {Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {stepIdx : Nat}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {seed :
    RegisterTemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ stepIdx pre post dec z}
  (roles :
    RegisterRoleSessions readSessionKey pairedSessionKey validAddressColumns
      kernelAddressBound rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readWriteMemoryRelation incrementRelation seed) :
  roles.readX.read.rv = WitnessMemoryBinding.primaryValue pre dec := by
  exact roles.readX_val.trans seed.registerPorts.1

theorem registerRoleSessions_readYValue_eq_secondaryValue
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  {Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {stepIdx : Nat}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {seed :
    RegisterTemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ stepIdx pre post dec z}
  (roles :
    RegisterRoleSessions readSessionKey pairedSessionKey validAddressColumns
      kernelAddressBound rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readWriteMemoryRelation incrementRelation seed) :
  roles.readY.read.rv = WitnessMemoryBinding.secondaryValue pre dec := by
  exact roles.readY_val.trans seed.registerPorts.2.1

theorem registerRoleSessions_readIValue_eq_preI
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  {Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {stepIdx : Nat}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {seed :
    RegisterTemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ stepIdx pre post dec z}
  (roles :
    RegisterRoleSessions readSessionKey pairedSessionKey validAddressColumns
      kernelAddressBound rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readWriteMemoryRelation incrementRelation seed) :
  roles.readI.read.rv = pre.i := by
  exact roles.readI_val.trans seed.registerPorts.2.2.1

theorem registerRoleSessions_writeRegValue_eq_registerWriteValue
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  {Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {stepIdx : Nat}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {seed :
    RegisterTemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ stepIdx pre post dec z}
  (roles :
    RegisterRoleSessions readSessionKey pairedSessionKey validAddressColumns
      kernelAddressBound rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readWriteMemoryRelation incrementRelation seed) :
  roles.writeReg.write.wv = WitnessMemoryBinding.registerWriteValue post dec := by
  exact roles.writeReg_val.trans seed.registerPorts.2.2.2.symm

theorem registerRoleSessions_readX_valueCoherent
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  {Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {stepIdx : Nat}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {seed :
    RegisterTemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ stepIdx pre post dec z}
  (roles :
    RegisterRoleSessions readSessionKey pairedSessionKey validAddressColumns
      kernelAddressBound rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readWriteMemoryRelation incrementRelation seed) :
  roles.readX.read.val = roles.readX.write.val ∧
    roles.readX.write.val = roles.readX.valClaim.val := by
  exact
    ⟨twistSessionWitness_readVal_eq_writeVal (session := roles.readX),
      twistSessionWitness_writeVal_eq_valClaimVal (session := roles.readX)⟩

theorem registerRoleSessions_readY_valueCoherent
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  {Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {stepIdx : Nat}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {seed :
    RegisterTemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ stepIdx pre post dec z}
  (roles :
    RegisterRoleSessions readSessionKey pairedSessionKey validAddressColumns
      kernelAddressBound rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readWriteMemoryRelation incrementRelation seed) :
  roles.readY.read.val = roles.readY.write.val ∧
    roles.readY.write.val = roles.readY.valClaim.val := by
  exact
    ⟨twistSessionWitness_readVal_eq_writeVal (session := roles.readY),
      twistSessionWitness_writeVal_eq_valClaimVal (session := roles.readY)⟩

theorem registerRoleSessions_readI_valueCoherent
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  {Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {stepIdx : Nat}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {seed :
    RegisterTemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ stepIdx pre post dec z}
  (roles :
    RegisterRoleSessions readSessionKey pairedSessionKey validAddressColumns
      kernelAddressBound rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readWriteMemoryRelation incrementRelation seed) :
  roles.readI.read.val = roles.readI.write.val ∧
    roles.readI.write.val = roles.readI.valClaim.val := by
  exact
    ⟨twistSessionWitness_readVal_eq_writeVal (session := roles.readI),
      twistSessionWitness_writeVal_eq_valClaimVal (session := roles.readI)⟩

theorem registerRoleSessions_writeReg_valueCoherent
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  {Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {stepIdx : Nat}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {seed :
    RegisterTemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ stepIdx pre post dec z}
  (roles :
    RegisterRoleSessions readSessionKey pairedSessionKey validAddressColumns
      kernelAddressBound rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readWriteMemoryRelation incrementRelation seed) :
  roles.writeReg.read.val = roles.writeReg.write.val ∧
    roles.writeReg.write.val = roles.writeReg.valClaim.val := by
  exact
    ⟨twistSessionWitness_readVal_eq_writeVal (session := roles.writeReg),
      twistSessionWitness_writeVal_eq_valClaimVal (session := roles.writeReg)⟩

theorem loadRamRoleSession_readMemValue_eq_ramReadValue
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  {Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {stepIdx : Nat}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {seed :
    RamTemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ stepIdx pre post dec z}
  (session :
    LoadRamRoleSession readSessionKey pairedSessionKey validAddressColumns
      kernelAddressBound rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readWriteMemoryRelation incrementRelation seed) :
  session.readMem.read.rv = WitnessMemoryBinding.ramReadValue pre dec := by
  exact session.readMem_val.trans seed.ramPorts.1.symm

theorem loadRamRoleSession_valueCoherent
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  {Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {stepIdx : Nat}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {seed :
    RamTemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ stepIdx pre post dec z}
  (session :
    LoadRamRoleSession readSessionKey pairedSessionKey validAddressColumns
      kernelAddressBound rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readWriteMemoryRelation incrementRelation seed) :
  session.readMem.read.val = session.readMem.write.val ∧
    session.readMem.write.val = session.readMem.valClaim.val := by
  exact
    ⟨twistSessionWitness_readVal_eq_writeVal (session := session.readMem),
      twistSessionWitness_writeVal_eq_valClaimVal (session := session.readMem)⟩

theorem storeRamRoleSession_writeMemValue_eq_ramWriteValue
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  {Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {stepIdx : Nat}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {seed :
    RamTemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ stepIdx pre post dec z}
  (session :
    StoreRamRoleSession readSessionKey pairedSessionKey validAddressColumns
      kernelAddressBound rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readWriteMemoryRelation incrementRelation seed) :
  session.writeMem.write.wv = WitnessMemoryBinding.ramWriteValue post dec := by
  exact session.writeMem_val.trans seed.ramPorts.2.symm

theorem storeRamRoleSession_valueCoherent
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  {Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {stepIdx : Nat}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {seed :
    RamTemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ stepIdx pre post dec z}
  (session :
    StoreRamRoleSession readSessionKey pairedSessionKey validAddressColumns
      kernelAddressBound rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readWriteMemoryRelation incrementRelation seed) :
  session.writeMem.read.val = session.writeMem.write.val ∧
    session.writeMem.write.val = session.writeMem.valClaim.val := by
  exact
    ⟨twistSessionWitness_readVal_eq_writeVal (session := session.writeMem),
      twistSessionWitness_writeVal_eq_valClaimVal (session := session.writeMem)⟩

end Evidence

end Nightstream.Chip8.TwistRoleSessions
