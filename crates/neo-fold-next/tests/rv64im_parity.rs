//! Focused tests for the sharded RV64IM exact-parity corpus.

use neo_fold_next::rv64im::build_all_parity_cases;

#[test]
fn parity_cases_reach_expected_halted_states() {
    let cases = build_all_parity_cases().expect("RV64IM parity cases");

    for (_source, derived) in cases {
        assert!(derived.kernel.halted, "{} should halt on ECALL", derived.manifest.name);

        match derived.manifest.name.as_str() {
            "vertical_add_sd_ld_ecall" => {
                assert_eq!(derived.kernel.final_pc, 20);
                assert_eq!(derived.kernel.final_registers[1], 5);
                assert_eq!(derived.kernel.final_registers[2], 10);
                assert_eq!(derived.kernel.final_registers[3], 10);
                assert_eq!(derived.kernel.final_memory.len(), 1);
                assert_eq!(derived.kernel.final_memory[0].addr, 0x1000);
                assert_eq!(derived.kernel.final_memory[0].value, 10);
            }
            "native_add_chain_x0_ecall" => {
                assert_eq!(derived.kernel.final_pc, 20);
                assert_eq!(derived.kernel.final_registers[0], 0, "x0 sink must be preserved");
                assert_eq!(derived.kernel.final_registers[1], 7);
                assert_eq!(derived.kernel.final_registers[2], 16);
                assert_eq!(derived.kernel.final_registers[3], 23);
                assert!(derived.kernel.final_memory.is_empty());
            }
            "aligned_negative_offset_roundtrip" => {
                assert_eq!(derived.kernel.final_pc, 16);
                assert_eq!(derived.kernel.final_registers[1], 42);
                assert_eq!(derived.kernel.final_registers[2], 42);
                assert_eq!(derived.kernel.final_registers[10], 0x2008);
                assert_eq!(derived.kernel.final_memory.len(), 2);
                assert_eq!(derived.kernel.final_memory[0].addr, 0x2000);
                assert_eq!(derived.kernel.final_memory[0].value, 42);
                assert_eq!(derived.kernel.final_memory[1].addr, 0x2008);
                assert_eq!(derived.kernel.final_memory[1].value, 99);
            }
            "control_flow_ecall_only" => {
                assert_eq!(derived.kernel.final_pc, 4);
                assert!(derived.kernel.final_memory.is_empty());
                assert!(derived
                    .kernel
                    .final_registers
                    .iter()
                    .all(|value| *value == 0));
            }
            name => panic!("unexpected RV64IM parity case {name}"),
        }
    }
}

#[test]
fn parity_case_artifacts_are_deterministic() {
    let first = build_all_parity_cases().expect("first parity case set");
    let second = build_all_parity_cases().expect("second parity case set");

    assert_eq!(first, second, "RV64IM parity corpus should be deterministic");
}
