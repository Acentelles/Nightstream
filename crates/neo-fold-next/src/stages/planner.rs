//! Owns `LoweredVmPlan -> StagePlan`.

use crate::families::LoweredVmPlan;
use crate::proof::ExtensionFamily;
use crate::stages::{ChunkModel, PlannedStage, StagePlan};

pub fn plan_vm(lowered: &LoweredVmPlan, chunk_model: ChunkModel) -> StagePlan {
    let mut stages = vec![
        PlannedStage {
            stage: 1,
            label: "outer_core",
            families: Vec::new(),
        },
        PlannedStage {
            stage: 2,
            label: "readonly_batch",
            families: Vec::new(),
        },
        PlannedStage {
            stage: 3,
            label: "register_history",
            families: Vec::new(),
        },
        PlannedStage {
            stage: 4,
            label: "ram_history",
            families: Vec::new(),
        },
        PlannedStage {
            stage: 5,
            label: "support_5",
            families: Vec::new(),
        },
        PlannedStage {
            stage: 6,
            label: "support_6",
            families: Vec::new(),
        },
        PlannedStage {
            stage: 7,
            label: "bridge_frontier",
            families: Vec::new(),
        },
    ];

    for family in lowered.families.iter().map(|placement| placement.family) {
        let idx = match family {
            ExtensionFamily::BytecodeFetch | ExtensionFamily::InstructionSemanticsLookup => 1,
            ExtensionFamily::RegisterHistory => 2,
            ExtensionFamily::RamHistory => 3,
        };
        stages[idx].families.push(family);
    }

    StagePlan {
        vm_name: lowered.vm_name,
        chunk_model,
        stages,
    }
}
