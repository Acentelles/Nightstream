use neo_ajtai::Commitment as Cmt;
use neo_math::F;
use neo_memory::riscv::lookups::RiscvOpcode;
use neo_memory::witness::LutInstance;

use crate::memory_sidecar::claim_plan::TimeClaimMeta;

#[derive(Clone, Debug)]
pub struct InstructionLookupLaneTimeClaimIdx {
    pub value: Option<usize>,
    pub adapter: Option<usize>,
    pub gamma_group: Option<usize>,
}

#[derive(Clone, Debug)]
pub struct InstructionLookupInstanceTimeClaimIdx {
    pub lanes: Vec<InstructionLookupLaneTimeClaimIdx>,
    pub bitness: Option<usize>,
    pub ell_addr: usize,
}

#[derive(Clone, Debug)]
pub struct InstructionLookupGammaGroupLaneRef {
    pub flat_lane_idx: usize,
    pub inst_idx: usize,
    pub lane_idx: usize,
}

#[derive(Clone, Debug)]
pub struct InstructionLookupGammaGroupSpec {
    pub key: u64,
    pub ell_addr: usize,
    pub lanes: Vec<InstructionLookupGammaGroupLaneRef>,
}

#[derive(Clone, Debug)]
pub struct InstructionLookupGammaGroupTimeClaimIdx {
    pub key: u64,
    pub ell_addr: usize,
    pub lanes: Vec<InstructionLookupGammaGroupLaneRef>,
    pub value: usize,
    pub adapter: usize,
    pub bitness: usize,
}

#[derive(Clone, Debug, Default)]
pub struct InstructionLookupTimeClaimPlan {
    pub instances: Vec<InstructionLookupInstanceTimeClaimIdx>,
    pub gamma_groups: Vec<InstructionLookupGammaGroupTimeClaimIdx>,
}

pub fn derive_gamma_groups_for_instances<'a, LI>(lut_insts: LI) -> Vec<InstructionLookupGammaGroupSpec>
where
    LI: IntoIterator<Item = &'a LutInstance<Cmt, F>>,
{
    let lut_insts: Vec<&LutInstance<Cmt, F>> = lut_insts.into_iter().collect();

    let mut grouped: std::collections::BTreeMap<u64, Vec<InstructionLookupGammaGroupLaneRef>> =
        std::collections::BTreeMap::new();
    let mut grouped_ell: std::collections::BTreeMap<u64, usize> = std::collections::BTreeMap::new();

    let mut flat_lane_idx = 0usize;
    for (inst_idx, lut_inst) in lut_insts.iter().enumerate() {
        let lanes = lut_inst.lanes.max(1);
        let ell_addr = lut_inst.d * lut_inst.ell;
        let is_packed = matches!(
            lut_inst.table_spec,
            Some(neo_memory::witness::LutTableSpec::RiscvOpcodePacked { .. })
        );
        let is_gamma_candidate = !is_packed && lut_inst.addr_group.is_some();
        for lane_idx in 0..lanes {
            if is_gamma_candidate {
                if let Some(addr_group) = lut_inst.addr_group {
                    let key = (addr_group << 32) | lane_idx as u64;
                    grouped
                        .entry(key)
                        .or_default()
                        .push(InstructionLookupGammaGroupLaneRef {
                            flat_lane_idx,
                            inst_idx,
                            lane_idx,
                        });
                    grouped_ell.entry(key).or_insert(ell_addr);
                }
            }
            flat_lane_idx += 1;
        }
    }

    let mut out = Vec::new();
    for (key, lanes) in grouped {
        if lanes.len() <= 1 {
            continue;
        }
        if let Some(&ell_addr) = grouped_ell.get(&key) {
            out.push(InstructionLookupGammaGroupSpec { key, ell_addr, lanes });
        }
    }
    out
}

pub fn time_claim_metas_for_instances<'a, LI>(lut_insts: LI) -> Vec<TimeClaimMeta>
where
    LI: IntoIterator<Item = &'a LutInstance<Cmt, F>>,
{
    let lut_insts: Vec<&LutInstance<Cmt, F>> = lut_insts.into_iter().collect();
    let gamma_groups = derive_gamma_groups_for_instances(lut_insts.iter().copied());
    let mut lane_gamma_map: std::collections::HashMap<(usize, usize), usize> = std::collections::HashMap::new();
    for (g_idx, g) in gamma_groups.iter().enumerate() {
        for lane in g.lanes.iter() {
            lane_gamma_map.insert((lane.inst_idx, lane.lane_idx), g_idx);
        }
    }
    let mut gamma_value_degree_bounds = vec![0usize; gamma_groups.len()];
    let mut gamma_adapter_degree_bounds = vec![0usize; gamma_groups.len()];
    let mut out = Vec::new();

    for (inst_idx, lut_inst) in lut_insts.iter().enumerate() {
        let ell_addr = lut_inst.d * lut_inst.ell;
        let lanes = lut_inst.lanes.max(1);
        let packed_opcode = match &lut_inst.table_spec {
            Some(neo_memory::witness::LutTableSpec::RiscvOpcodePacked { opcode, xlen })
                if neo_memory::riscv::packed::rv_packed_supported_opcode(*opcode, *xlen) =>
            {
                Some(*opcode)
            }
            _ => None,
        };

        let (value_degree_bound, adapter_degree_bound) = match packed_opcode {
            Some(RiscvOpcode::And | RiscvOpcode::Andn | RiscvOpcode::Or | RiscvOpcode::Xor) => (8, 6),
            Some(RiscvOpcode::Add | RiscvOpcode::Sub) => (3, 2),
            Some(RiscvOpcode::Eq | RiscvOpcode::Neq) => (34, 3),
            Some(RiscvOpcode::Mul | RiscvOpcode::VirtualMulWord) => (4, 2),
            Some(RiscvOpcode::Mulh) => (4, 5),
            Some(RiscvOpcode::Mulhu) => (4, 2),
            Some(RiscvOpcode::Mulhsu) => (4, 4),
            Some(RiscvOpcode::Slt) => (3, 3),
            Some(
                RiscvOpcode::Divu | RiscvOpcode::VirtualDivuWord | RiscvOpcode::Remu | RiscvOpcode::VirtualRemuWord,
            ) => (5, 4),
            Some(RiscvOpcode::Div | RiscvOpcode::VirtualDivWord | RiscvOpcode::Rem | RiscvOpcode::VirtualRemWord) => {
                (7, 6)
            }
            Some(RiscvOpcode::Sll) => (8, 2),
            Some(RiscvOpcode::Srl | RiscvOpcode::Sra | RiscvOpcode::VirtualMovsignWord) => (8, 8),
            Some(RiscvOpcode::Sltu) => (3, 3),
            _ => (3, 2 + ell_addr),
        };

        let mut has_ungrouped_lane = false;
        for lane_idx in 0..lanes {
            if let Some(&g_idx) = lane_gamma_map.get(&(inst_idx, lane_idx)) {
                gamma_value_degree_bounds[g_idx] = gamma_value_degree_bounds[g_idx].max(value_degree_bound);
                gamma_adapter_degree_bounds[g_idx] = gamma_adapter_degree_bounds[g_idx].max(adapter_degree_bound);
            } else {
                has_ungrouped_lane = true;
                out.push(TimeClaimMeta {
                    label: b"instruction_lookup/value",
                    degree_bound: value_degree_bound,
                    is_dynamic: true,
                });
                out.push(TimeClaimMeta {
                    label: b"instruction_lookup/adapter",
                    degree_bound: adapter_degree_bound,
                    is_dynamic: true,
                });
            }
        }

        if has_ungrouped_lane {
            out.push(TimeClaimMeta {
                label: b"instruction_lookup/bitness",
                degree_bound: 3,
                is_dynamic: false,
            });
        }
    }

    for (g_idx, _) in gamma_groups.iter().enumerate() {
        out.push(TimeClaimMeta {
            label: b"instruction_lookup/value",
            degree_bound: gamma_value_degree_bounds[g_idx],
            is_dynamic: true,
        });
        out.push(TimeClaimMeta {
            label: b"instruction_lookup/adapter",
            degree_bound: gamma_adapter_degree_bounds[g_idx],
            is_dynamic: true,
        });
        out.push(TimeClaimMeta {
            label: b"instruction_lookup/bitness",
            degree_bound: 3,
            is_dynamic: false,
        });
    }

    out
}

pub fn build_time_claim_plan<'a, LI>(lut_insts: LI, claim_idx_start: usize) -> (InstructionLookupTimeClaimPlan, usize)
where
    LI: IntoIterator<Item = &'a LutInstance<Cmt, F>>,
{
    let lut_insts: Vec<&LutInstance<Cmt, F>> = lut_insts.into_iter().collect();
    let gamma_specs = derive_gamma_groups_for_instances(lut_insts.iter().copied());
    let mut lane_gamma_map: std::collections::HashMap<(usize, usize), usize> = std::collections::HashMap::new();
    for (g_idx, g) in gamma_specs.iter().enumerate() {
        for lane in g.lanes.iter() {
            lane_gamma_map.insert((lane.inst_idx, lane.lane_idx), g_idx);
        }
    }

    let mut idx = claim_idx_start;
    let mut instances = Vec::with_capacity(lut_insts.len());
    for (inst_idx, lut_inst) in lut_insts.iter().enumerate() {
        let ell_addr = lut_inst.d * lut_inst.ell;
        let lanes = lut_inst.lanes.max(1);
        let mut lane_claims = Vec::with_capacity(lanes);
        let mut has_ungrouped_lane = false;
        for lane_idx in 0..lanes {
            let gamma_group = lane_gamma_map.get(&(inst_idx, lane_idx)).copied();
            let (value, adapter) = if gamma_group.is_some() {
                (None, None)
            } else {
                has_ungrouped_lane = true;
                let value = idx;
                idx += 1;
                let adapter = idx;
                idx += 1;
                (Some(value), Some(adapter))
            };
            lane_claims.push(InstructionLookupLaneTimeClaimIdx {
                value,
                adapter,
                gamma_group,
            });
        }

        let bitness = if has_ungrouped_lane {
            let out = idx;
            idx += 1;
            Some(out)
        } else {
            None
        };

        instances.push(InstructionLookupInstanceTimeClaimIdx {
            lanes: lane_claims,
            bitness,
            ell_addr,
        });
    }

    let mut gamma_groups = Vec::with_capacity(gamma_specs.len());
    for spec in gamma_specs {
        let value = idx;
        idx += 1;
        let adapter = idx;
        idx += 1;
        let bitness = idx;
        idx += 1;
        gamma_groups.push(InstructionLookupGammaGroupTimeClaimIdx {
            key: spec.key,
            ell_addr: spec.ell_addr,
            lanes: spec.lanes,
            value,
            adapter,
            bitness,
        });
    }

    (
        InstructionLookupTimeClaimPlan {
            instances,
            gamma_groups,
        },
        idx,
    )
}
