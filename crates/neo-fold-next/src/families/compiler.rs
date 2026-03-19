//! Owns `VmSpec -> LoweredVmPlan` lowering.

use crate::families::{FamilyPlacement, LoweredVmPlan};
use crate::proof::ExtensionFamily;
use crate::vm::VmSpec;

pub fn lower_vm_spec<V: VmSpec>(vm: &V) -> LoweredVmPlan {
    let mut families = vec![FamilyPlacement {
        family: ExtensionFamily::BytecodeFetch,
        preferred_stage: 2,
    }];

    let has_twist = !vm.twist_tables().is_empty();
    if has_twist {
        families.push(FamilyPlacement {
            family: ExtensionFamily::RegisterHistory,
            preferred_stage: 3,
        });
        families.push(FamilyPlacement {
            family: ExtensionFamily::RamHistory,
            preferred_stage: 4,
        });
    }

    LoweredVmPlan {
        vm_name: vm.name(),
        witness_width: vm.core_ccs_spec().witness_width,
        families,
    }
}
