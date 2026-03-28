//! Fresh test suite for the CHIP-8 3-stage kernel (chip8-kernel.md).

use neo_ccs::check_ccs_rowwise_zero;
use neo_fold_next::chip8::spec::{
    build_pad_row, decode_opcode, Chip8Opcode, Chip8Program, Chip8State, Chip8VmSpec, WITNESS_WIDTH,
};
use neo_fold_next::chip8::tables::{
    build_alu_table, build_decode_table, build_eq4_table, build_rom_table, decode_to_output, LookupKind,
};
use neo_fold_next::chip8::trace::Chip8TraceBuilder;
use neo_fold_next::vm::VmSpec;
use neo_math::F;
use p3_field::PrimeCharacteristicRing;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

fn f(v: u64) -> F {
    F::from_u64(v)
}

fn assert_satisfied(z: &[F], label: &str) {
    let vm = Chip8VmSpec::default();
    let ccs = &vm.core_ccs_spec().structure;
    let (x, w) = (&z[..1], &z[1..]);
    check_ccs_rowwise_zero(ccs, x, w).unwrap_or_else(|e| panic!("{label}: expected CCS satisfied, got: {e}"));
}

fn assert_rejected(z: &[F], label: &str) {
    let vm = Chip8VmSpec::default();
    let ccs = &vm.core_ccs_spec().structure;
    let (x, w) = (&z[..1], &z[1..]);
    assert!(
        check_ccs_rowwise_zero(ccs, x, w).is_err(),
        "{label}: expected CCS rejection, but the witness was accepted"
    );
}

// ===========================================================================
// 1. R1CS structural tests
// ===========================================================================

#[test]
fn ccs_has_19_constraint_rows() {
    let vm = Chip8VmSpec::default();
    let ccs = &vm.core_ccs_spec().structure;
    assert_eq!(ccs.n, 19, "expected 19 R1CS rows");
}

#[test]
fn pad_row_satisfies_19_r1cs_rows() {
    let pad = build_pad_row(0x100);
    assert_satisfied(&pad, "pad row at pc_word=0x100");
}

#[test]
fn pad_row_rejects_tampered_preserves_x() {
    let mut pad = build_pad_row(0x100);
    // Break the x-lane partition: set PreservesX = 0 (row 8 will fail).
    pad[15] = F::ZERO; // COL_PRESERVES_X = 15
    assert_rejected(&pad, "pad row with PreservesX zeroed");
}

#[test]
fn witness_width_is_24() {
    assert_eq!(WITNESS_WIDTH, 24);
}

// ===========================================================================
// 2. Decode table tests
// ===========================================================================

#[test]
fn decode_table_ld_imm() {
    let out = decode_to_output(0x6342); // LD V3, 0x42
    assert!(out.valid);
    assert_eq!(out.x_dec, 3);
    assert_eq!(out.kk_dec, 0x42);
    assert!(out.writes_lookup_to_x);
    assert!(!out.is_jump);
    assert_eq!(out.lookup_kind, LookupKind::Identity);
}

#[test]
fn decode_table_unsupported_returns_invalid() {
    let out = decode_to_output(0x0000);
    assert!(!out.valid);
}

#[test]
fn decode_table_all_9_opcodes_valid() {
    // One representative opcode per supported class.
    let samples: [(u16, Chip8Opcode); 9] = [
        (0x6042, Chip8Opcode::LdImm),     // 6xkk
        (0x7105, Chip8Opcode::AddImm),    // 7xkk
        (0x8120, Chip8Opcode::Mov),       // 8xy0
        (0x8124, Chip8Opcode::AddReg),    // 8xy4
        (0x3042, Chip8Opcode::SkipEqImm), // 3xkk
        (0x1234, Chip8Opcode::Jump),      // 1nnn
        (0xA300, Chip8Opcode::LdI),       // Annn
        (0xF255, Chip8Opcode::StoreRegs), // Fx55
        (0xF265, Chip8Opcode::LoadRegs),  // Fx65
    ];
    for (opcode, expected_id) in &samples {
        let out = decode_to_output(*opcode);
        assert!(out.valid, "opcode 0x{opcode:04x} should be valid");
        let decoded = decode_opcode(*opcode).unwrap();
        assert_eq!(decoded.opcode_id, *expected_id, "opcode 0x{opcode:04x} wrong id");
    }
}

// ===========================================================================
// 3. Decode exclusivity / negative tests
// ===========================================================================

#[test]
fn decode_exclusivity_jump_not_branch() {
    let out = decode_to_output(0x1234); // Jump
    assert!(out.is_jump);
    assert!(!out.is_branch);
    assert!(!out.is_memop);
}

#[test]
fn decode_exclusivity_branch_not_jump() {
    let out = decode_to_output(0x3042); // SkipEqImm
    assert!(out.is_branch);
    assert!(!out.is_jump);
    assert!(!out.is_memop);
}

#[test]
fn decode_exclusivity_memop_not_jump_or_branch() {
    let out = decode_to_output(0xF255); // StoreRegs
    assert!(out.is_memop);
    assert!(!out.is_jump);
    assert!(!out.is_branch);
}

// ===========================================================================
// 4. Table construction tests
// ===========================================================================

#[test]
fn rom_table_loads_program() {
    let program = Chip8Program::from_opcodes(&[0x6042, 0x1200]);
    // Program starts at byte 0x200, word address 0x100.
    // Use pad_pc_word that does not collide with program words.
    let pad_pc_word = 0x000; // word 0, outside program range
    let rom = build_rom_table(&program, pad_pc_word);
    assert_eq!(rom[0x100], f(0x6042), "first opcode at word 0x100");
    assert_eq!(rom[0x101], f(0x1200), "second opcode at word 0x101");
    // Pad self-loop at word 0x000: Jump(2 * 0) = 0x1000
    assert_eq!(rom[0x000], f(0x1000), "pad self-loop opcode");
}

#[test]
fn alu_table_add8lo() {
    let table = build_alu_table();
    // (100 + 200) mod 256 = 44
    assert_eq!(table[100 * 256 + 200], f(44));
    // (0 + 0) mod 256 = 0
    assert_eq!(table[0], f(0));
    // (255 + 1) mod 256 = 0
    assert_eq!(table[255 * 256 + 1], f(0));
    // (128 + 128) mod 256 = 0
    assert_eq!(table[128 * 256 + 128], f(0));
}

#[test]
fn eq4_table_equality() {
    let table = build_eq4_table();
    assert_eq!(table[5 * 16 + 5], F::ONE, "Eq4(5,5) = 1");
    assert_eq!(table[5 * 16 + 6], F::ZERO, "Eq4(5,6) = 0");
    // Diagonal: all 16 entries should be 1
    for i in 0..16 {
        assert_eq!(table[i * 16 + i], F::ONE, "Eq4({i},{i}) should be 1");
    }
}

#[test]
fn decode_table_column_count() {
    let cols = build_decode_table();
    assert_eq!(cols.len(), 22, "decode table should have 22 output columns");
    assert_eq!(cols[0].len(), 65536, "each column should have 65536 entries");
}

// ===========================================================================
// 5. CCS satisfaction for hand-built witness rows
// ===========================================================================

/// LD V0, 0x42 at word-PC 0x100 -> PC_NEXT = 0x101
#[test]
fn ccs_ld_imm_row_satisfies() {
    use neo_fold_next::chip8::spec::*;
    let mut z = [F::ZERO; WITNESS_WIDTH];
    z[COL_ONE] = F::ONE;
    z[COL_PC] = f(0x100);
    z[COL_PC_NEXT] = f(0x101);
    z[COL_REG_X] = f(0);
    z[COL_REG_Y] = f(0);
    z[COL_REG_X_NEXT] = f(0x42);
    z[COL_I_REG] = f(0);
    z[COL_I_NEXT] = f(0);
    z[COL_KK] = f(0x42);
    z[COL_NNN_ADDR] = f(0);
    z[COL_NNN_WORD] = f(0);
    z[COL_MEM_VALUE] = f(0);
    z[COL_LOOKUP_OUTPUT] = f(0x42); // Identity(kk) = 0x42
    z[COL_WRITES_LOOKUP_TO_X] = F::ONE;
    z[COL_WRITES_MEM_TO_X] = F::ZERO;
    z[COL_PRESERVES_X] = F::ZERO;
    z[COL_WRITES_NNN_TO_I] = F::ZERO;
    z[COL_IS_JUMP] = F::ZERO;
    z[COL_IS_BRANCH] = F::ZERO;
    z[COL_IS_MEMOP] = F::ZERO;
    z[COL_X_IDX] = f(0);
    z[COL_Y_IDX] = f(0);
    z[COL_BURST_LAST] = F::ZERO;
    z[COL_RAM_ADDR] = F::ZERO;
    assert_satisfied(&z, "ld_imm hand-built");
}

/// Jump 0x200 at word-PC 0x100 -> PC_NEXT = 0x100 (NNN_WORD = 0x200/2)
#[test]
fn ccs_jump_row_satisfies() {
    use neo_fold_next::chip8::spec::*;
    let mut z = [F::ZERO; WITNESS_WIDTH];
    z[COL_ONE] = F::ONE;
    z[COL_PC] = f(0x100);
    z[COL_PC_NEXT] = f(0x100); // Jump to word 0x100
    z[COL_NNN_ADDR] = f(0x200);
    z[COL_NNN_WORD] = f(0x100);
    z[COL_PRESERVES_X] = F::ONE;
    z[COL_IS_JUMP] = F::ONE;
    assert_satisfied(&z, "jump hand-built");
}

/// Jump row with tampered PC_NEXT should be rejected.
#[test]
fn ccs_jump_rejects_wrong_pc_next() {
    use neo_fold_next::chip8::spec::*;
    let mut z = [F::ZERO; WITNESS_WIDTH];
    z[COL_ONE] = F::ONE;
    z[COL_PC] = f(0x100);
    z[COL_PC_NEXT] = f(0x200); // wrong: should be NNN_WORD = 0x100
    z[COL_NNN_ADDR] = f(0x200);
    z[COL_NNN_WORD] = f(0x100);
    z[COL_PRESERVES_X] = F::ONE;
    z[COL_IS_JUMP] = F::ONE;
    assert_rejected(&z, "jump with tampered PC_NEXT");
}

// ===========================================================================
// 6. Execution / micro-stepping tests
// ===========================================================================

#[test]
fn execute_ld_imm_advances_pc() {
    let program = Chip8Program::from_opcodes(&[0x6042]); // LD V0, 0x42
    let state = Chip8State::with_program(&program).unwrap();
    let steps = Chip8TraceBuilder::<()>::execute_program(&program, &state, 1).unwrap();
    assert_eq!(steps.len(), 1);
    assert_eq!(steps[0].next.v[0], 0x42);
    assert_eq!(steps[0].next.pc, 0x202); // byte PC advanced by 2
}

#[test]
fn execute_jump_self_loop() {
    // Jump 0x200 -> self loop
    let program = Chip8Program::from_opcodes(&[0x1200]);
    let state = Chip8State::with_program(&program).unwrap();
    let steps = Chip8TraceBuilder::<()>::execute_program(&program, &state, 3).unwrap();
    assert_eq!(steps.len(), 3);
    for step in &steps {
        assert_eq!(step.next.pc, 0x200);
    }
}

#[test]
fn execute_store_regs_writes_memory() {
    // LdI 0x300; LD V0, 0xAA; LD V1, 0xBB; LD V2, 0xCC; StoreRegs V2
    let program = Chip8Program::from_opcodes(&[
        0xA300, // LdI 0x300
        0x60AA, // LD V0, 0xAA
        0x61BB, // LD V1, 0xBB
        0x62CC, // LD V2, 0xCC
        0xF255, // StoreRegs V2 (stores V0..V2)
        0x1200, // Jump 0x200 (so PC doesn't escape)
    ]);
    let state = Chip8State::with_program(&program).unwrap();
    let steps = Chip8TraceBuilder::<()>::execute_program(&program, &state, 5).unwrap();
    let final_state = &steps[4].next;
    assert_eq!(final_state.memory[0x300], 0xAA);
    assert_eq!(final_state.memory[0x301], 0xBB);
    assert_eq!(final_state.memory[0x302], 0xCC);
}

#[test]
fn execute_skip_eq_branches_when_equal() {
    // LD V0, 0x42; SkipEq V0, 0x42; LD V1, 0xFF (skipped); LD V2, 0x01
    let program = Chip8Program::from_opcodes(&[
        0x6042, // LD V0, 0x42
        0x3042, // SE V0, 0x42 -> skip next
        0x61FF, // LD V1, 0xFF (skipped)
        0x6201, // LD V2, 0x01
        0x1200, // Jump self
    ]);
    let state = Chip8State::with_program(&program).unwrap();
    let steps = Chip8TraceBuilder::<()>::execute_program(&program, &state, 3).unwrap();
    // After LD V0, 0x42: pc = 0x202
    // After SE V0, 0x42 (equal -> skip): pc = 0x206 (skips 0x204)
    // After LD V2, 0x01: pc = 0x208
    assert_eq!(steps[1].next.pc, 0x206, "SE should skip when equal");
    assert_eq!(steps[2].next.v[2], 0x01, "V2 should be loaded");
    assert_eq!(steps[2].next.v[1], 0x00, "V1 should NOT be loaded (skipped)");
}

// ===========================================================================
// 7. Decode-to-CCS consistency: build witness via execution, verify CCS
// ===========================================================================

#[test]
fn execution_produces_ccs_satisfying_rows() {
    // Small program: LD V0, 0x42; AddImm V0, 0x10; Jump 0x200
    let program = Chip8Program::from_opcodes(&[
        0x6042, // LD V0, 0x42
        0x7010, // ADD V0, 0x10
        0x1200, // Jump 0x200
    ]);
    let state = Chip8State::with_program(&program).unwrap();
    let steps = Chip8TraceBuilder::<()>::execute_program(&program, &state, 3).unwrap();
    // Manually build witness rows and check CCS for each.
    for step in &steps {
        let dec_out = decode_to_output(step.trace.opcode);
        let decoded = decode_opcode(step.trace.opcode).unwrap();
        let prev = &step.prev;
        let next = &step.next;

        use neo_fold_next::chip8::spec::*;
        let pc_word = prev.pc / 2;
        let pc_next_word = next.pc / 2;

        let reg_x = prev.v[decoded.x as usize];
        let reg_y = if dec_out.uses_y { prev.v[decoded.y as usize] } else { 0 };
        let reg_x_next = next.v[decoded.x as usize];

        let lookup_output = match dec_out.lookup_kind {
            LookupKind::Identity => match dec_out.lhs_selector {
                neo_fold_next::chip8::tables::OperandSelector::Kk => decoded.kk as u16,
                neo_fold_next::chip8::tables::OperandSelector::RegY => reg_y as u16,
                _ => 0,
            },
            LookupKind::Add8Lo => {
                let lhs = match dec_out.lhs_selector {
                    neo_fold_next::chip8::tables::OperandSelector::RegX => reg_x,
                    _ => 0,
                };
                let rhs = match dec_out.rhs_selector {
                    neo_fold_next::chip8::tables::OperandSelector::Kk => decoded.kk,
                    neo_fold_next::chip8::tables::OperandSelector::RegY => reg_y,
                    _ => 0,
                };
                ((lhs as u16) + (rhs as u16)) % 256
            }
            _ => 0,
        };

        let mut z = [F::ZERO; WITNESS_WIDTH];
        z[COL_ONE] = F::ONE;
        z[COL_PC] = f(pc_word as u64);
        z[COL_PC_NEXT] = f(pc_next_word as u64);
        z[COL_REG_X] = f(reg_x as u64);
        z[COL_REG_Y] = f(reg_y as u64);
        z[COL_REG_X_NEXT] = f(reg_x_next as u64);
        z[COL_I_REG] = f(prev.i as u64);
        z[COL_I_NEXT] = f(next.i as u64);
        z[COL_KK] = f(decoded.kk as u64);
        z[COL_NNN_ADDR] = f(decoded.nnn as u64);
        z[COL_NNN_WORD] = f((decoded.nnn / 2) as u64);
        z[COL_LOOKUP_OUTPUT] = f(lookup_output as u64);

        if dec_out.writes_lookup_to_x {
            z[COL_WRITES_LOOKUP_TO_X] = F::ONE;
        }
        if dec_out.writes_mem_to_x {
            z[COL_WRITES_MEM_TO_X] = F::ONE;
        }
        if dec_out.preserves_x {
            z[COL_PRESERVES_X] = F::ONE;
        }
        if dec_out.writes_nnn_to_i {
            z[COL_WRITES_NNN_TO_I] = F::ONE;
        }
        if dec_out.is_jump {
            z[COL_IS_JUMP] = F::ONE;
        }
        if dec_out.is_branch {
            z[COL_IS_BRANCH] = F::ONE;
        }
        if dec_out.is_memop {
            z[COL_IS_MEMOP] = F::ONE;
        }
        z[COL_X_IDX] = f(decoded.x as u64);
        z[COL_Y_IDX] = f(decoded.y as u64);
        z[COL_BURST_LAST] = F::ZERO;
        z[COL_RAM_ADDR] = F::ZERO;

        assert_satisfied(&z, &format!("execution row opcode=0x{:04x}", step.trace.opcode));
    }
}
