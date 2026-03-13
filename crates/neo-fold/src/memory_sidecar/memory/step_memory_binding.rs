use super::*;
// ============================================================================
// Transcript binding
// ============================================================================

pub(crate) fn bind_shout_table_spec(tr: &mut Poseidon2Transcript, spec: &Option<LutTableSpec>) {
    let Some(spec) = spec else {
        return;
    };

    match spec {
        LutTableSpec::RiscvOpcode { opcode, xlen } => {
            let opcode_id = neo_memory::riscv::lookups::RiscvShoutTables::new(*xlen)
                .opcode_to_id(*opcode)
                .0 as u64;
            tr.append_u64s(b"shout/table_spec/meta_u64", &[1u64, opcode_id, *xlen as u64, 0u64]);
        }
        LutTableSpec::RiscvOpcodePacked { opcode, xlen } => {
            let opcode_id = neo_memory::riscv::lookups::RiscvShoutTables::new(*xlen)
                .opcode_to_id(*opcode)
                .0 as u64;
            tr.append_u64s(b"shout/table_spec/meta_u64", &[2u64, opcode_id, *xlen as u64, 0u64]);
        }
        LutTableSpec::IdentityU32 => {
            tr.append_u64s(b"shout/table_spec/meta_u64", &[3u64, 0, 0, 0]);
        }
        _ => unreachable!("unsupported shout table spec in neo-fold transcript binding"),
    }
}

#[inline]
fn compute_mem_init_digest(init: &MemInit<F>) -> [u8; 32] {
    match init {
        MemInit::Zero => digest_fields(b"twist/init/zero", &[]),
        MemInit::Sparse(pairs) => {
            let mut fs = Vec::with_capacity(2 * pairs.len());
            for (addr, val) in pairs.iter() {
                fs.push(F::from_u64(*addr));
                fs.push(*val);
            }
            digest_fields(b"twist/init/sparse", &fs)
        }
    }
}

pub(crate) fn absorb_step_memory_impl<'a, LI, MI>(tr: &mut Poseidon2Transcript, mut lut_insts: LI, mut mem_insts: MI)
where
    LI: ExactSizeIterator<Item = &'a LutInstance<Cmt, F>>,
    MI: ExactSizeIterator<Item = &'a MemInstance<Cmt, F>>,
{
    tr.append_message(b"step/absorb_memory_start", &[]);
    tr.append_u64s(b"step/lut_count", &[lut_insts.len() as u64]);
    for (i, inst) in lut_insts.by_ref().enumerate() {
        tr.append_u64s(
            b"step/lut_meta_u64",
            &[
                i as u64,
                inst.table_id as u64,
                inst.k as u64,
                inst.d as u64,
                inst.n_side as u64,
                inst.steps as u64,
                inst.ell as u64,
                inst.lanes.max(1) as u64,
            ],
        );
        bind_shout_table_spec(tr, &inst.table_spec);
        let table_digest = digest_fields(b"shout/table", &inst.table);
        tr.append_bytes_packed(b"shout/table_digest", &table_digest);

        tr.append_u64s(b"shout/comms_len", &[inst.comms.len() as u64]);
        if !inst.comms.is_empty() {
            let comm_lens: Vec<u64> = inst
                .comms
                .iter()
                .map(|comm| comm.data.len() as u64)
                .collect();
            tr.append_u64s(b"shout/comm_lens", &comm_lens);
            let total_fields = inst.comms.iter().map(|comm| comm.data.len()).sum::<usize>();
            #[cfg(debug_assertions)]
            {
                let lens_sum: usize = comm_lens.iter().map(|&x| x as usize).sum();
                debug_assert_eq!(lens_sum, total_fields, "shout/comm_lens sum mismatch");
            }
            tr.append_fields_iter(
                b"shout/comm_data_flat",
                total_fields,
                inst.comms.iter().flat_map(|comm| comm.data.iter().copied()),
            );
        }
    }
    tr.append_u64s(b"step/mem_count", &[mem_insts.len() as u64]);
    for (i, inst) in mem_insts.by_ref().enumerate() {
        tr.append_u64s(
            b"step/mem_meta_u64",
            &[
                i as u64,
                inst.mem_id as u64,
                inst.k as u64,
                inst.d as u64,
                inst.n_side as u64,
                inst.steps as u64,
                inst.ell as u64,
                inst.lanes.max(1) as u64,
            ],
        );
        let init_digest = compute_mem_init_digest(&inst.init);
        tr.append_bytes_packed(b"twist/init_digest", &init_digest);

        tr.append_u64s(b"twist/comms_len", &[inst.comms.len() as u64]);
        if !inst.comms.is_empty() {
            let comm_lens: Vec<u64> = inst
                .comms
                .iter()
                .map(|comm| comm.data.len() as u64)
                .collect();
            tr.append_u64s(b"twist/comm_lens", &comm_lens);
            let total_fields = inst.comms.iter().map(|comm| comm.data.len()).sum::<usize>();
            #[cfg(debug_assertions)]
            {
                let lens_sum: usize = comm_lens.iter().map(|&x| x as usize).sum();
                debug_assert_eq!(lens_sum, total_fields, "twist/comm_lens sum mismatch");
            }
            tr.append_fields_iter(
                b"twist/comm_data_flat",
                total_fields,
                inst.comms.iter().flat_map(|comm| comm.data.iter().copied()),
            );
        }
    }
    tr.append_message(b"step/absorb_memory_end", &[]);
}

pub fn absorb_step_memory(
    tr: &mut Poseidon2Transcript,
    lut_insts: &[LutInstance<Cmt, F>],
    mem_insts: &[MemInstance<Cmt, F>],
) {
    absorb_step_memory_impl(tr, lut_insts.iter(), mem_insts.iter());
}

pub(crate) fn absorb_step_memory_witness(tr: &mut Poseidon2Transcript, step: &StepWitnessBundle<Cmt, F, K>) {
    tr.append_message(b"step/absorb_memory_start", &[]);
    tr.append_u64s(b"step/lut_count", &[step.lut_instances.len() as u64]);
    for (i, (inst, _)) in step.lut_instances.iter().enumerate() {
        tr.append_u64s(
            b"step/lut_meta_u64",
            &[
                i as u64,
                inst.table_id as u64,
                inst.k as u64,
                inst.d as u64,
                inst.n_side as u64,
                inst.steps as u64,
                inst.ell as u64,
                inst.lanes.max(1) as u64,
            ],
        );
        bind_shout_table_spec(tr, &inst.table_spec);
        let table_digest = digest_fields(b"shout/table", &inst.table);
        tr.append_bytes_packed(b"shout/table_digest", &table_digest);

        tr.append_u64s(b"shout/comms_len", &[inst.comms.len() as u64]);
        if !inst.comms.is_empty() {
            let comm_lens: Vec<u64> = inst
                .comms
                .iter()
                .map(|comm| comm.data.len() as u64)
                .collect();
            tr.append_u64s(b"shout/comm_lens", &comm_lens);
            let total_fields = inst.comms.iter().map(|comm| comm.data.len()).sum::<usize>();
            #[cfg(debug_assertions)]
            {
                let lens_sum: usize = comm_lens.iter().map(|&x| x as usize).sum();
                debug_assert_eq!(lens_sum, total_fields, "shout/comm_lens sum mismatch");
            }
            tr.append_fields_iter(
                b"shout/comm_data_flat",
                total_fields,
                inst.comms.iter().flat_map(|comm| comm.data.iter().copied()),
            );
        }
    }

    tr.append_u64s(b"step/mem_count", &[step.mem_instances.len() as u64]);
    for (i, (inst, _)) in step.mem_instances.iter().enumerate() {
        tr.append_u64s(
            b"step/mem_meta_u64",
            &[
                i as u64,
                inst.mem_id as u64,
                inst.k as u64,
                inst.d as u64,
                inst.n_side as u64,
                inst.steps as u64,
                inst.ell as u64,
                inst.lanes.max(1) as u64,
            ],
        );
        let init_digest = compute_mem_init_digest(&inst.init);
        tr.append_bytes_packed(b"twist/init_digest", &init_digest);

        tr.append_u64s(b"twist/comms_len", &[inst.comms.len() as u64]);
        if !inst.comms.is_empty() {
            let comm_lens: Vec<u64> = inst
                .comms
                .iter()
                .map(|comm| comm.data.len() as u64)
                .collect();
            tr.append_u64s(b"twist/comm_lens", &comm_lens);
            let total_fields = inst.comms.iter().map(|comm| comm.data.len()).sum::<usize>();
            #[cfg(debug_assertions)]
            {
                let lens_sum: usize = comm_lens.iter().map(|&x| x as usize).sum();
                debug_assert_eq!(lens_sum, total_fields, "twist/comm_lens sum mismatch");
            }
            tr.append_fields_iter(
                b"twist/comm_data_flat",
                total_fields,
                inst.comms.iter().flat_map(|comm| comm.data.iter().copied()),
            );
        }
    }
    tr.append_message(b"step/absorb_memory_end", &[]);
}
