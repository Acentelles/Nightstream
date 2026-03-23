use neo_ajtai::Commitment as Cmt;
use neo_math::{F, K};
use neo_memory::riscv::lookups::{
    POSEIDON2_ABSORB_FUNCT7, POSEIDON2_CUSTOM_OPCODE, POSEIDON2_FINALIZE_FUNCT7, POSEIDON2_SQUEEZE_FUNCT7, PROG_ID,
    REG_ID,
};
use neo_memory::witness::{LutInstance, MemInstance, StepInstanceBundle, StepWitnessBundle};
use p3_field::PrimeField64;

use crate::instruction_lookup::{
    build_time_claim_plan as build_instruction_lookup_time_claim_plan,
    time_claim_metas_for_instances as instruction_lookup_time_claim_metas_for_instances,
    InstructionLookupTimeClaimPlan,
};
use crate::PiCcsError;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct TimeClaimMeta {
    pub label: &'static [u8],
    pub degree_bound: usize,
    pub is_dynamic: bool,
}

pub const POSEIDON_CYCLE_CLAIM_METAS: [TimeClaimMeta; 9] = [
    TimeClaimMeta {
        label: b"poseidon/io_link",
        degree_bound: 4,
        is_dynamic: false,
    },
    TimeClaimMeta {
        label: b"poseidon/bitness",
        degree_bound: 3,
        is_dynamic: false,
    },
    TimeClaimMeta {
        label: b"poseidon/canonical_u64",
        degree_bound: 6,
        is_dynamic: false,
    },
    TimeClaimMeta {
        label: b"poseidon/sidecar_link",
        degree_bound: 4,
        is_dynamic: false,
    },
    TimeClaimMeta {
        label: b"poseidon/mode",
        degree_bound: 3,
        is_dynamic: false,
    },
    TimeClaimMeta {
        label: b"poseidon/link_cycle_inv",
        degree_bound: 4,
        is_dynamic: false,
    },
    TimeClaimMeta {
        label: b"poseidon/link_cycle_sum",
        degree_bound: 3,
        is_dynamic: true,
    },
    TimeClaimMeta {
        label: b"poseidon/cont_inv",
        degree_bound: 6,
        is_dynamic: false,
    },
    TimeClaimMeta {
        label: b"poseidon/cont_sum",
        degree_bound: 3,
        is_dynamic: false,
    },
];

pub const POSEIDON_LOCAL_TIME_CLAIM_METAS: [TimeClaimMeta; 5] = [
    TimeClaimMeta {
        label: b"poseidon/round",
        degree_bound: 10,
        is_dynamic: false,
    },
    TimeClaimMeta {
        label: b"poseidon/transition",
        degree_bound: 4,
        is_dynamic: false,
    },
    TimeClaimMeta {
        label: b"poseidon/cycle_local_link",
        degree_bound: 8,
        is_dynamic: false,
    },
    TimeClaimMeta {
        label: b"poseidon/link_local_inv",
        degree_bound: 5,
        is_dynamic: false,
    },
    TimeClaimMeta {
        label: b"poseidon/link_local_sum",
        degree_bound: 3,
        is_dynamic: true,
    },
];

#[inline]
pub fn poseidon_cycle_claim_metas() -> &'static [TimeClaimMeta] {
    &POSEIDON_CYCLE_CLAIM_METAS
}

#[inline]
pub fn poseidon_local_time_claim_metas() -> &'static [TimeClaimMeta] {
    &POSEIDON_LOCAL_TIME_CLAIM_METAS
}

#[derive(Clone, Debug)]
pub struct TwistTimeClaimIdx {
    pub read_check: usize,
    pub write_check: usize,
    pub bitness: usize,
    pub virtual_write_domain: Option<usize>,
    pub nonvirtual_arch_domain: Option<usize>,
    pub ell_addr: usize,
}

/// Deterministic claim schedule for Route A batched time claims (memory sidecar only).
///
/// This is a single source of truth for how indices into `batched_claimed_sums` /
/// `batched_final_values` map to each Shout/Twist instance.
#[derive(Clone, Debug)]
pub struct RouteATimeClaimPlan {
    pub claim_idx_start: usize,
    pub claim_idx_end: usize,
    pub instruction_lookup: InstructionLookupTimeClaimPlan,
    pub twist: Vec<TwistTimeClaimIdx>,
    pub booleanity_claim: Option<usize>,
    pub trace_opening_quiescence: Option<usize>,
    pub poseidon_io_link: Option<usize>,
    pub poseidon_bitness: Option<usize>,
    pub poseidon_canonical_u64: Option<usize>,
    pub poseidon_sidecar_link: Option<usize>,
    pub poseidon_mode: Option<usize>,
    pub poseidon_link_cycle_inv: Option<usize>,
    pub poseidon_link_cycle_sum: Option<usize>,
    pub poseidon_cont_inv: Option<usize>,
    pub poseidon_cont_sum: Option<usize>,
}

impl RouteATimeClaimPlan {
    fn is_poseidon_precompile_word(word: u32) -> bool {
        let opcode = word & 0x7f;
        if opcode != POSEIDON2_CUSTOM_OPCODE {
            return false;
        }
        let rd = ((word >> 7) & 0x1f) as u8;
        let funct3 = ((word >> 12) & 0x07) as u8;
        let rs1 = ((word >> 15) & 0x1f) as u8;
        let rs2 = ((word >> 20) & 0x1f) as u8;
        let funct7 = ((word >> 25) & 0x7f) as u8;
        match funct7 as u32 {
            POSEIDON2_ABSORB_FUNCT7 => funct3 == 0 && rd == 0,
            POSEIDON2_FINALIZE_FUNCT7 => funct3 == 0 && rd == 0 && rs1 == 0 && rs2 == 0,
            POSEIDON2_SQUEEZE_FUNCT7 => rs1 == 0 && rs2 == 0,
            _ => false,
        }
    }

    fn poseidon_stage_required_for_mem_instances<'a, I>(mem_insts: I) -> Result<bool, PiCcsError>
    where
        I: IntoIterator<Item = &'a MemInstance<Cmt, F>>,
    {
        let prog_inst = mem_insts.into_iter().find(|inst| inst.mem_id == PROG_ID.0);
        let Some(prog_inst) = prog_inst else {
            return Ok(false);
        };

        match &prog_inst.init {
            neo_memory::MemInit::Zero => Ok(false),
            neo_memory::MemInit::Sparse(pairs) => {
                for (addr, value) in pairs.iter() {
                    let word_u64 = value.as_canonical_u64();
                    if word_u64 > u32::MAX as u64 {
                        return Err(PiCcsError::ProtocolError(format!(
                            "poseidon stage probe: PROG init word does not fit u32 (addr={addr}, value={word_u64:#x})"
                        )));
                    }
                    let word = word_u64 as u32;
                    if Self::is_poseidon_precompile_word(word) {
                        return Ok(true);
                    }
                }
                Ok(false)
            }
        }
    }

    pub fn poseidon_stage_required_for_step_instance(step: &StepInstanceBundle<Cmt, F, K>) -> Result<bool, PiCcsError> {
        Self::poseidon_stage_required_for_mem_instances(step.mem_insts.iter())
    }

    pub fn poseidon_stage_required_for_step_witness(step: &StepWitnessBundle<Cmt, F, K>) -> Result<bool, PiCcsError> {
        Self::poseidon_stage_required_for_mem_instances(step.mem_instances.iter().map(|(inst, _)| inst))
    }

    pub fn time_claim_metas_for_instances<'a, LI, MI>(
        lut_insts: LI,
        mem_insts: MI,
        booleanity_enabled: bool,
        trace_opening_enabled: bool,
        poseidon_cycle_enabled: bool,
        ob_reg_exact_linkage_degree_bound: Option<usize>,
        ob_inc_total_degree_bound: Option<usize>,
    ) -> Vec<TimeClaimMeta>
    where
        LI: IntoIterator<Item = &'a LutInstance<Cmt, F>>,
        MI: IntoIterator<Item = &'a MemInstance<Cmt, F>>,
    {
        let mem_insts: Vec<&MemInstance<Cmt, F>> = mem_insts.into_iter().collect();
        let mut out = Vec::new();
        out.extend(instruction_lookup_time_claim_metas_for_instances(lut_insts));

        for mem_inst in mem_insts {
            let ell_addr = mem_inst.d * mem_inst.ell;

            out.push(TimeClaimMeta {
                label: b"twist/read_check",
                degree_bound: 3 + ell_addr,
                is_dynamic: true,
            });
            out.push(TimeClaimMeta {
                label: b"twist/write_check",
                degree_bound: 3 + ell_addr,
                is_dynamic: true,
            });

            out.push(TimeClaimMeta {
                label: b"twist/bitness",
                degree_bound: 3,
                is_dynamic: false,
            });
            if mem_inst.mem_id == REG_ID.0 {
                out.push(TimeClaimMeta {
                    label: b"twist/virtual_write_domain",
                    degree_bound: 4,
                    is_dynamic: false,
                });
                out.push(TimeClaimMeta {
                    label: b"twist/nonvirtual_arch_domain",
                    degree_bound: 4,
                    is_dynamic: false,
                });
            }
        }

        if booleanity_enabled {
            out.push(TimeClaimMeta {
                label: b"booleanity/check",
                degree_bound: 3,
                is_dynamic: false,
            });
        }

        if trace_opening_enabled {
            out.push(TimeClaimMeta {
                label: b"trace_opening/quiescence",
                degree_bound: 3,
                is_dynamic: false,
            });
        }

        if poseidon_cycle_enabled {
            out.extend_from_slice(&POSEIDON_CYCLE_CLAIM_METAS);
        }

        if let Some(degree_bound) = ob_reg_exact_linkage_degree_bound {
            out.push(TimeClaimMeta {
                label: crate::output_binding::OB_REG_EXACT_LINKAGE_LABEL,
                degree_bound,
                is_dynamic: false,
            });
        }

        if let Some(degree_bound) = ob_inc_total_degree_bound {
            out.push(TimeClaimMeta {
                label: crate::output_binding::OB_INC_TOTAL_LABEL,
                degree_bound,
                is_dynamic: true,
            });
        }

        out
    }

    /// Returns the full ordered metadata list for the Route A batched-time sumcheck.
    ///
    /// This is a single source of truth for claim ordering and expected degree bounds/labels.
    /// Claim indices returned by [`RouteATimeClaimPlan::build`] refer to the memory-only suffix
    /// of this list, starting at `claim_idx_start` (typically 0).
    pub fn time_claim_metas_for_step(
        step: &StepInstanceBundle<Cmt, F, K>,
        booleanity_enabled: bool,
        trace_opening_enabled: bool,
        poseidon_cycle_enabled: bool,
        ob_reg_exact_linkage_degree_bound: Option<usize>,
        ob_inc_total_degree_bound: Option<usize>,
    ) -> Vec<TimeClaimMeta> {
        Self::time_claim_metas_for_instances(
            step.lut_insts.iter(),
            step.mem_insts.iter(),
            booleanity_enabled,
            trace_opening_enabled,
            poseidon_cycle_enabled,
            ob_reg_exact_linkage_degree_bound,
            ob_inc_total_degree_bound,
        )
    }

    pub fn build(
        step: &StepInstanceBundle<Cmt, F, K>,
        claim_idx_start: usize,
        booleanity_enabled: bool,
        trace_opening_enabled: bool,
        poseidon_cycle_enabled: bool,
    ) -> Result<RouteATimeClaimPlan, PiCcsError> {
        let mut idx = claim_idx_start;
        let (instruction_lookup, next_idx) = build_instruction_lookup_time_claim_plan(step.lut_insts.iter(), idx);
        idx = next_idx;
        let mut twist = Vec::with_capacity(step.mem_insts.len());

        for mem_inst in &step.mem_insts {
            let ell_addr = mem_inst.d * mem_inst.ell;
            let read_check = idx;
            idx += 1;
            let write_check = idx;
            idx += 1;

            let bitness = idx;
            idx += 1;
            let virtual_write_domain = if mem_inst.mem_id == REG_ID.0 {
                let out = idx;
                idx += 1;
                Some(out)
            } else {
                None
            };
            let nonvirtual_arch_domain = if mem_inst.mem_id == REG_ID.0 {
                let out = idx;
                idx += 1;
                Some(out)
            } else {
                None
            };

            twist.push(TwistTimeClaimIdx {
                read_check,
                write_check,
                bitness,
                virtual_write_domain,
                nonvirtual_arch_domain,
                ell_addr,
            });
        }

        let booleanity_claim = if booleanity_enabled {
            let out = idx;
            idx += 1;
            Some(out)
        } else {
            None
        };

        let trace_opening_quiescence = if trace_opening_enabled {
            let out = idx;
            idx += 1;
            Some(out)
        } else {
            None
        };

        let poseidon_io_link = if poseidon_cycle_enabled {
            let out = idx;
            idx += 1;
            Some(out)
        } else {
            None
        };
        let poseidon_bitness = if poseidon_cycle_enabled {
            let out = idx;
            idx += 1;
            Some(out)
        } else {
            None
        };
        let poseidon_canonical_u64 = if poseidon_cycle_enabled {
            let out = idx;
            idx += 1;
            Some(out)
        } else {
            None
        };
        let poseidon_sidecar_link = if poseidon_cycle_enabled {
            let out = idx;
            idx += 1;
            Some(out)
        } else {
            None
        };
        let poseidon_mode = if poseidon_cycle_enabled {
            let out = idx;
            idx += 1;
            Some(out)
        } else {
            None
        };
        let poseidon_link_cycle_inv = if poseidon_cycle_enabled {
            let out = idx;
            idx += 1;
            Some(out)
        } else {
            None
        };
        let poseidon_link_cycle_sum = if poseidon_cycle_enabled {
            let out = idx;
            idx += 1;
            Some(out)
        } else {
            None
        };
        let poseidon_cont_inv = if poseidon_cycle_enabled {
            let out = idx;
            idx += 1;
            Some(out)
        } else {
            None
        };
        let poseidon_cont_sum = if poseidon_cycle_enabled {
            let out = idx;
            idx += 1;
            Some(out)
        } else {
            None
        };

        if idx < claim_idx_start {
            return Err(PiCcsError::ProtocolError("RouteATimeClaimPlan index underflow".into()));
        }

        Ok(RouteATimeClaimPlan {
            claim_idx_start,
            claim_idx_end: idx,
            instruction_lookup,
            twist,
            booleanity_claim,
            trace_opening_quiescence,
            poseidon_io_link,
            poseidon_bitness,
            poseidon_canonical_u64,
            poseidon_sidecar_link,
            poseidon_mode,
            poseidon_link_cycle_inv,
            poseidon_link_cycle_sum,
            poseidon_cont_inv,
            poseidon_cont_sum,
        })
    }
}

#[derive(Clone, Debug)]
pub struct TwistValEvalClaimPlan {
    pub has_prev: bool,
    pub claims_per_mem: usize,
    pub claim_count: usize,
    pub labels: Vec<&'static [u8]>,
    pub degree_bounds: Vec<usize>,
    pub bind_tags: Vec<u8>,
}

impl TwistValEvalClaimPlan {
    pub fn build<'a, I>(mem_insts: I, has_prev: bool) -> Self
    where
        I: IntoIterator<Item = &'a MemInstance<Cmt, F>>,
    {
        let mem_insts: Vec<&MemInstance<Cmt, F>> = mem_insts.into_iter().collect();
        let n_mem = mem_insts.len();
        let claims_per_mem = if has_prev { 3 } else { 2 };
        let claim_count = claims_per_mem * n_mem;

        let mut labels: Vec<&'static [u8]> = Vec::with_capacity(claim_count);
        let mut degree_bounds = Vec::with_capacity(claim_count);
        let mut bind_tags = Vec::with_capacity(claim_count);

        for inst in mem_insts {
            let ell_addr = inst.d * inst.ell;

            labels.push(b"twist/val_eval_lt".as_slice());
            degree_bounds.push(ell_addr + 3);
            bind_tags.push(0);

            labels.push(b"twist/val_eval_total".as_slice());
            degree_bounds.push(ell_addr + 2);
            bind_tags.push(1);

            if has_prev {
                labels.push(b"twist/rollover_prev_total".as_slice());
                degree_bounds.push(ell_addr + 2);
                bind_tags.push(2);
            }
        }

        Self {
            has_prev,
            claims_per_mem,
            claim_count,
            labels,
            degree_bounds,
            bind_tags,
        }
    }

    #[inline]
    pub fn base(&self, mem_idx: usize) -> usize {
        self.claims_per_mem * mem_idx
    }
}
