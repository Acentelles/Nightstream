import Nightstream.Chip8.Stage2.TwistRoleSessions

namespace Nightstream.Chip8.TwistRoleSessionsInterface

-- ── Structures ──

abbrev RegisterRoleSessions := @Nightstream.Chip8.TwistRoleSessions.RegisterRoleSessions
abbrev LoadRamRoleSession := @Nightstream.Chip8.TwistRoleSessions.LoadRamRoleSession
abbrev StoreRamRoleSession := @Nightstream.Chip8.TwistRoleSessions.StoreRamRoleSession

-- ── Definitions: Session Construction ──

noncomputable abbrev registerRoleSessions_of_seed :=
  @Nightstream.Chip8.TwistRoleSessions.registerRoleSessions_of_seed
noncomputable abbrev loadRamRoleSession_of_seed :=
  @Nightstream.Chip8.TwistRoleSessions.loadRamRoleSession_of_seed
noncomputable abbrev storeRamRoleSession_of_seed :=
  @Nightstream.Chip8.TwistRoleSessions.storeRamRoleSession_of_seed

-- ── Theorems: Key & Value Equalities ──

abbrev twistSessionWitness_readKey_eq_key :=
  @Nightstream.Chip8.TwistRoleSessions.twistSessionWitness_readKey_eq_key
abbrev twistSessionWitness_writeKey_eq_key :=
  @Nightstream.Chip8.TwistRoleSessions.twistSessionWitness_writeKey_eq_key
abbrev twistSessionWitness_valKey_eq_key :=
  @Nightstream.Chip8.TwistRoleSessions.twistSessionWitness_valKey_eq_key
abbrev twistSessionWitness_readVal_eq_writeVal :=
  @Nightstream.Chip8.TwistRoleSessions.twistSessionWitness_readVal_eq_writeVal
abbrev twistSessionWitness_writeVal_eq_valClaimVal :=
  @Nightstream.Chip8.TwistRoleSessions.twistSessionWitness_writeVal_eq_valClaimVal
abbrev twistSessionWitness_readVal_eq_valClaimVal :=
  @Nightstream.Chip8.TwistRoleSessions.twistSessionWitness_readVal_eq_valClaimVal

-- ── Theorems: Claims Membership ──

abbrev registerSessionClaimsInΓ₃_of_seed :=
  @Nightstream.Chip8.TwistRoleSessions.registerSessionClaimsInΓ₃_of_seed
abbrev ramSessionClaimsInΓ₃_of_seed :=
  @Nightstream.Chip8.TwistRoleSessions.ramSessionClaimsInΓ₃_of_seed
abbrev registerRoleSessions_readXClaimsInΓ₃ :=
  @Nightstream.Chip8.TwistRoleSessions.registerRoleSessions_readXClaimsInΓ₃
abbrev registerRoleSessions_readYClaimsInΓ₃ :=
  @Nightstream.Chip8.TwistRoleSessions.registerRoleSessions_readYClaimsInΓ₃
abbrev registerRoleSessions_readIClaimsInΓ₃ :=
  @Nightstream.Chip8.TwistRoleSessions.registerRoleSessions_readIClaimsInΓ₃
abbrev registerRoleSessions_writeRegClaimsInΓ₃ :=
  @Nightstream.Chip8.TwistRoleSessions.registerRoleSessions_writeRegClaimsInΓ₃
abbrev loadRamRoleSession_claimsInΓ₃ :=
  @Nightstream.Chip8.TwistRoleSessions.loadRamRoleSession_claimsInΓ₃
abbrev storeRamRoleSession_claimsInΓ₃ :=
  @Nightstream.Chip8.TwistRoleSessions.storeRamRoleSession_claimsInΓ₃

-- ── Theorems: Value Coherence ──

abbrev registerRoleSessions_readXValue_eq_primaryValue :=
  @Nightstream.Chip8.TwistRoleSessions.registerRoleSessions_readXValue_eq_primaryValue
abbrev registerRoleSessions_readYValue_eq_secondaryValue :=
  @Nightstream.Chip8.TwistRoleSessions.registerRoleSessions_readYValue_eq_secondaryValue
abbrev registerRoleSessions_readIValue_eq_preI :=
  @Nightstream.Chip8.TwistRoleSessions.registerRoleSessions_readIValue_eq_preI
abbrev registerRoleSessions_writeRegValue_eq_registerWriteValue :=
  @Nightstream.Chip8.TwistRoleSessions.registerRoleSessions_writeRegValue_eq_registerWriteValue
abbrev registerRoleSessions_readX_valueCoherent :=
  @Nightstream.Chip8.TwistRoleSessions.registerRoleSessions_readX_valueCoherent
abbrev registerRoleSessions_readY_valueCoherent :=
  @Nightstream.Chip8.TwistRoleSessions.registerRoleSessions_readY_valueCoherent
abbrev registerRoleSessions_readI_valueCoherent :=
  @Nightstream.Chip8.TwistRoleSessions.registerRoleSessions_readI_valueCoherent
abbrev registerRoleSessions_writeReg_valueCoherent :=
  @Nightstream.Chip8.TwistRoleSessions.registerRoleSessions_writeReg_valueCoherent
abbrev loadRamRoleSession_readMemValue_eq_ramReadValue :=
  @Nightstream.Chip8.TwistRoleSessions.loadRamRoleSession_readMemValue_eq_ramReadValue
abbrev storeRamRoleSession_writeMemValue_eq_ramWriteValue :=
  @Nightstream.Chip8.TwistRoleSessions.storeRamRoleSession_writeMemValue_eq_ramWriteValue
abbrev loadRamRoleSession_valueCoherent :=
  @Nightstream.Chip8.TwistRoleSessions.loadRamRoleSession_valueCoherent
abbrev storeRamRoleSession_valueCoherent :=
  @Nightstream.Chip8.TwistRoleSessions.storeRamRoleSession_valueCoherent

end Nightstream.Chip8.TwistRoleSessionsInterface
