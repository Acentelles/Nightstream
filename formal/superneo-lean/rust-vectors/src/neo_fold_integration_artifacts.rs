use bellpepper::gadgets::boolean::{AllocatedBit, Boolean};
use bellpepper_core::{Circuit, ConstraintSystem, Index, LinearCombination, SynthesisError, Variable};
use ff::PrimeField;
use neo_ajtai::{set_global_pp_seeded, AjtaiSModule};
use neo_ajtai::Commitment as Cmt;
use neo_ccs::relations::{CcsClaim, CcsWitness};
use neo_ccs::traits::SModuleHomomorphism;
use neo_ccs::{CcsMatrix, CcsStructure, CscMat, SparsePoly, Term};
use neo_fold::output_binding::OutputBindingConfig;
use neo_fold::pi_ccs::FoldingMode;
use neo_fold::shard::{
    fold_shard_prove_with_output_binding_and_audit, fold_shard_prove_with_witnesses_with_step_offset_and_audit,
    fold_shard_verify_with_output_binding, fold_shard_verify_with_step_offset, CommitMixers,
};
use neo_math::{D, Fq as F, K};
use neo_memory::ajtai::{commit_cols_for_ccs_m, encode_vector_for_ccs_m};
use neo_memory::cpu::build_bus_layout_for_instances;
use neo_memory::cpu::constraints::{extend_ccs_with_shared_cpu_bus_constraints, TwistCpuBinding};
use neo_memory::output_check::ProgramIO;
use neo_memory::witness::{StepInstanceBundle, StepWitnessBundle};
use neo_memory::{MemInit, witness::{MemInstance, MemWitness, TimeColumns}};
use neo_params::NeoParams;
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeCharacteristicRing;
use sha2::{Digest, Sha256};

use super::{artifact_from_proof, ArtifactRepr};

#[derive(ff::PrimeField)]
#[PrimeFieldModulus = "18446744069414584321"]
#[PrimeFieldGenerator = "7"]
#[PrimeFieldReprEndianness = "little"]
struct FpGoldilocks([u64; 2]);

const STATE_BYTES: usize = 32;
const PACK_CHUNK_BITS: usize = 32;
const AUX_FLAG: u32 = 1 << 31;

type Mixers = CommitMixers<fn(&[neo_ccs::Mat<F>], &[Cmt]) -> Cmt, fn(&[Cmt], u32) -> Cmt>;

fn fp_to_u64(x: &FpGoldilocks) -> u64 {
    let bytes = x.to_repr();
    u64::from_le_bytes(bytes.as_ref()[0..8].try_into().expect("repr is at least 8 bytes"))
}

struct TripletConstraintSystem {
    inputs: Vec<F>,
    aux: Vec<F>,
    num_constraints: u32,
    a_trips: Vec<(u32, u32, F)>,
    b_trips: Vec<(u32, u32, F)>,
    c_trips: Vec<(u32, u32, F)>,
}

impl TripletConstraintSystem {
    fn new() -> Self {
        Self {
            inputs: vec![F::ONE],
            aux: Vec::new(),
            num_constraints: 0,
            a_trips: Vec::new(),
            b_trips: Vec::new(),
            c_trips: Vec::new(),
        }
    }

    fn push_lc_trips(row: u32, lc: &LinearCombination<FpGoldilocks>, trips: &mut Vec<(u32, u32, F)>) {
        for (var, coeff) in lc.iter() {
            let value = fp_to_u64(coeff);
            if value == 0 {
                continue;
            }
            let col = match var.0 {
                Index::Input(i) => u32::try_from(i).expect("input index should fit in u32"),
                Index::Aux(i) => AUX_FLAG | u32::try_from(i).expect("aux index should fit in u32"),
            };
            trips.push((row, col, F::from_u64(value)));
        }
    }

    fn resolve_triplets(trips: Vec<(u32, u32, F)>, num_inputs: usize) -> Vec<(usize, usize, F)> {
        trips
            .into_iter()
            .map(|(row, col, value)| {
                let row = row as usize;
                if (col & AUX_FLAG) == 0 {
                    (row, col as usize, value)
                } else {
                    let aux_idx = (col & !AUX_FLAG) as usize;
                    (row, num_inputs + aux_idx, value)
                }
            })
            .collect()
    }
}

impl ConstraintSystem<FpGoldilocks> for TripletConstraintSystem {
    type Root = Self;

    fn new() -> Self {
        Self::new()
    }

    fn alloc<FN, A, AR>(&mut self, _annotation: A, f: FN) -> Result<Variable, SynthesisError>
    where
        FN: FnOnce() -> Result<FpGoldilocks, SynthesisError>,
        A: FnOnce() -> AR,
        AR: Into<String>,
    {
        let idx = self.aux.len();
        let value = f()?;
        self.aux.push(F::from_u64(fp_to_u64(&value)));
        Ok(Variable::new_unchecked(Index::Aux(idx)))
    }

    fn alloc_input<FN, A, AR>(&mut self, _annotation: A, f: FN) -> Result<Variable, SynthesisError>
    where
        FN: FnOnce() -> Result<FpGoldilocks, SynthesisError>,
        A: FnOnce() -> AR,
        AR: Into<String>,
    {
        let idx = self.inputs.len();
        let value = f()?;
        self.inputs.push(F::from_u64(fp_to_u64(&value)));
        Ok(Variable::new_unchecked(Index::Input(idx)))
    }

    fn enforce<A, AR, LA, LB, LC>(&mut self, _annotation: A, a: LA, b: LB, c: LC)
    where
        A: FnOnce() -> AR,
        AR: Into<String>,
        LA: FnOnce(LinearCombination<FpGoldilocks>) -> LinearCombination<FpGoldilocks>,
        LB: FnOnce(LinearCombination<FpGoldilocks>) -> LinearCombination<FpGoldilocks>,
        LC: FnOnce(LinearCombination<FpGoldilocks>) -> LinearCombination<FpGoldilocks>,
    {
        let row = self.num_constraints;
        self.num_constraints += 1;

        let a_lc = a(LinearCombination::zero());
        let b_lc = b(LinearCombination::zero());
        let c_lc = c(LinearCombination::zero());

        Self::push_lc_trips(row, &a_lc, &mut self.a_trips);
        Self::push_lc_trips(row, &b_lc, &mut self.b_trips);
        Self::push_lc_trips(row, &c_lc, &mut self.c_trips);
    }

    fn push_namespace<NR, N>(&mut self, _name_fn: N)
    where
        NR: Into<String>,
        N: FnOnce() -> NR,
    {
    }

    fn pop_namespace(&mut self) {}

    fn get_root(&mut self) -> &mut Self::Root {
        self
    }
}

struct Sha256StateChainCircuit {
    prev_state: [u8; STATE_BYTES],
}

#[derive(Clone, Copy, Default)]
struct DummyCommit;

impl SModuleHomomorphism<F, Cmt> for DummyCommit {
    fn commit(&self, z: &neo_ccs::Mat<F>) -> Cmt {
        Cmt::zeros(z.rows(), 1)
    }

    fn project_x(&self, z: &neo_ccs::Mat<F>, m_in: usize) -> neo_ccs::Mat<F> {
        let rows = z.rows();
        let mut out = neo_ccs::Mat::zero(rows, m_in, F::ZERO);
        for r in 0..rows {
            for c in 0..m_in.min(z.cols()) {
                out[(r, c)] = z[(r, c)];
            }
        }
        out
    }
}

impl Circuit<FpGoldilocks> for Sha256StateChainCircuit {
    fn synthesize<CS: ConstraintSystem<FpGoldilocks>>(self, cs: &mut CS) -> Result<(), SynthesisError> {
        let prev_bit_values: Vec<_> = bellpepper::gadgets::multipack::bytes_to_bits(&self.prev_state)
            .into_iter()
            .map(Some)
            .collect();

        let prev_bits = prev_bit_values
            .into_iter()
            .enumerate()
            .map(|(i, bit)| AllocatedBit::alloc(cs.namespace(|| format!("prev bit {i}")), bit))
            .map(|bit| bit.map(Boolean::from))
            .collect::<Result<Vec<_>, _>>()?;

        for (chunk_idx, chunk_bits) in prev_bits.chunks(PACK_CHUNK_BITS).enumerate() {
            bellpepper::gadgets::multipack::pack_into_inputs(
                cs.namespace(|| format!("prev_state_chunk_{chunk_idx}")),
                chunk_bits,
            )?;
        }

        let hash_bits = bellpepper::gadgets::sha256::sha256(cs.namespace(|| "sha256"), &prev_bits)?;
        for (chunk_idx, chunk_bits) in hash_bits.chunks(PACK_CHUNK_BITS).enumerate() {
            bellpepper::gadgets::multipack::pack_into_inputs(
                cs.namespace(|| format!("next_state_chunk_{chunk_idx}")),
                chunk_bits,
            )?;
        }

        Ok(())
    }
}

fn build_sha256_chain_ccs() -> (CcsStructure<F>, usize) {
    let mut cs = TripletConstraintSystem::new();
    Sha256StateChainCircuit {
        prev_state: [0u8; STATE_BYTES],
    }
    .synthesize(&mut cs)
    .expect("circuit synthesis should succeed");

    let TripletConstraintSystem {
        inputs,
        aux,
        num_constraints,
        a_trips,
        b_trips,
        c_trips,
    } = cs;

    let n = num_constraints as usize;
    let num_inputs = inputs.len();
    let num_variables = num_inputs + aux.len();
    let m = n.max(num_variables);

    let a_trips = TripletConstraintSystem::resolve_triplets(a_trips, num_inputs);
    let b_trips = TripletConstraintSystem::resolve_triplets(b_trips, num_inputs);
    let c_trips = TripletConstraintSystem::resolve_triplets(c_trips, num_inputs);

    let f_base = SparsePoly::new(
        3,
        vec![
            Term {
                coeff: F::ONE,
                exps: vec![1, 1, 0],
            },
            Term {
                coeff: -F::ONE,
                exps: vec![0, 0, 1],
            },
        ],
    );

    let matrices = vec![
        CcsMatrix::Csc(CscMat::from_triplets(a_trips, n, m)),
        CcsMatrix::Csc(CscMat::from_triplets(b_trips, n, m)),
        CcsMatrix::Csc(CscMat::from_triplets(c_trips, n, m)),
    ];
    (
        CcsStructure::new_sparse(matrices, f_base).expect("valid R1CS->CCS structure"),
        num_inputs,
    )
}

fn build_sha256_chain_witness(prev_state: [u8; STATE_BYTES]) -> (Vec<F>, usize) {
    let mut cs = TripletConstraintSystem::new();
    Sha256StateChainCircuit { prev_state }
        .synthesize(&mut cs)
        .expect("circuit synthesis should succeed");

    let m_in = cs.inputs.len();
    let mut witness = cs.inputs;
    witness.extend(cs.aux);
    (witness, m_in)
}

fn pad_witness_to_m(mut z: Vec<F>, m_target: usize) -> Vec<F> {
    z.resize(m_target, F::ZERO);
    z
}

fn build_step<L: SModuleHomomorphism<F, neo_ajtai::Commitment>>(
    params: &NeoParams,
    committer: &L,
    m_in: usize,
    z: Vec<F>,
) -> StepWitnessBundle<neo_ajtai::Commitment, F, K> {
    let z_mat = encode_vector_for_ccs_m(params, z.len(), &z).expect("encode witness for CCS width");
    let c = committer.commit(&z_mat);
    let x = z[..m_in].to_vec();
    let w = z[m_in..].to_vec();
    StepWitnessBundle::from((CcsClaim { c, x, m_in }, CcsWitness { w, Z: z_mat }))
}

fn empty_identity_first_r1cs_ccs(n: usize) -> CcsStructure<F> {
    let i_n = neo_ccs::Mat::identity(n);
    let a = neo_ccs::Mat::zero(n, n, F::ZERO);
    let b = neo_ccs::Mat::zero(n, n, F::ZERO);
    let c = neo_ccs::Mat::zero(n, n, F::ZERO);
    let f = SparsePoly::new(
        4,
        vec![
            Term {
                coeff: F::ONE,
                exps: vec![0, 1, 1, 0],
            },
            Term {
                coeff: -F::ONE,
                exps: vec![0, 0, 0, 1],
            },
        ],
    );
    CcsStructure::new(vec![i_n, a, b, c], f).expect("CCS")
}

fn default_mixers() -> Mixers {
    crate::common_setup::default_mixers()
}

fn create_mcs_from_z(params: &NeoParams, l: &DummyCommit, m_in: usize, z: Vec<F>) -> (CcsClaim<Cmt, F>, CcsWitness<F>) {
    let z_mat = encode_vector_for_ccs_m(params, z.len(), &z).expect("encode packed witness");
    let c = l.commit(&z_mat);
    let x = z[..m_in].to_vec();
    let w = z[m_in..].to_vec();
    (CcsClaim { c, x, m_in }, CcsWitness { w, Z: z_mat })
}

fn sha256_state(state: &[u8; STATE_BYTES]) -> [u8; STATE_BYTES] {
    let digest = Sha256::digest(state);
    let mut out = [0u8; STATE_BYTES];
    out.copy_from_slice(digest.as_ref());
    out
}

fn sha256_bytes(bytes: &[u8]) -> [u8; STATE_BYTES] {
    let digest = Sha256::digest(bytes);
    let mut out = [0u8; STATE_BYTES];
    out.copy_from_slice(digest.as_ref());
    out
}

pub(super) fn continuation_sha256_artifacts() -> Vec<ArtifactRepr> {
    let (ccs, m_in) = build_sha256_chain_ccs();
    let params = NeoParams::goldilocks_auto_r1cs_ccs(ccs.n.max(ccs.m)).expect("params");
    let seed = [42u8; 32];
    let m_commit = commit_cols_for_ccs_m(ccs.m);
    set_global_pp_seeded(D, params.kappa as usize, m_commit, seed).expect("set_global_pp_seeded");
    let committer = AjtaiSModule::from_global_for_dims(D, m_commit).expect("AjtaiSModule init");
    let mixers = crate::common_setup::default_mixers();

    let y0 = sha256_bytes(b"abc");
    let y1 = sha256_state(&y0);
    let _y2 = sha256_state(&y1);

    let (w0, m_in0) = build_sha256_chain_witness(y0);
    let (w1, m_in1) = build_sha256_chain_witness(y1);
    assert_eq!(m_in0, m_in);
    assert_eq!(m_in1, m_in);

    let step0 = build_step(&params, &committer, m_in, pad_witness_to_m(w0, ccs.m));
    let step1 = build_step(&params, &committer, m_in, pad_witness_to_m(w1, ccs.m));
    let step1_instance = StepInstanceBundle::from(&step1);

    let mut tr_prefix = Poseidon2Transcript::new(b"neo.fold/shard_continuation");
    let (_proof0, out0, wits0, _audit0) = fold_shard_prove_with_witnesses_with_step_offset_and_audit(
        FoldingMode::Optimized,
        &mut tr_prefix,
        &params,
        &ccs,
        core::slice::from_ref(&step0),
        &[],
        &[],
        &committer,
        mixers,
        0,
    )
    .expect("prove prefix");

    let mut tr_suffix = Poseidon2Transcript::new(b"neo.fold/shard_continuation");
    let (proof1, _out1, wits1, audit1) = fold_shard_prove_with_witnesses_with_step_offset_and_audit(
        FoldingMode::Optimized,
        &mut tr_suffix,
        &params,
        &ccs,
        core::slice::from_ref(&step1),
        &out0.obligations.main,
        &wits0.final_main_wits,
        &committer,
        mixers,
        1,
    )
    .expect("prove extension");

    let mut tr_verify = Poseidon2Transcript::new(b"neo.fold/shard_continuation");
    let _ = fold_shard_verify_with_step_offset(
        FoldingMode::Optimized,
        &mut tr_verify,
        &params,
        &ccs,
        core::slice::from_ref(&step1_instance),
        &out0.obligations.main,
        &proof1,
        mixers,
        1,
    )
    .expect("verify extension");

    vec![artifact_from_proof(
        "sha256_shard_continuation_suffix",
        false,
        1,
        params.b,
        params.k_rho,
        &params,
        &ccs,
        &committer,
        core::slice::from_ref(&step1),
        &out0.obligations.main,
        &wits0.final_main_wits,
        &wits1.final_main_wits,
        &proof1,
        &audit1,
    )]
}

pub(super) fn output_binding_artifacts() -> Vec<ArtifactRepr> {
    let n = 64usize;
    let base_ccs = empty_identity_first_r1cs_ccs(n);
    let mut params = NeoParams::goldilocks_auto_r1cs_ccs(n).expect("params");
    params.k_rho = 16;
    let l = DummyCommit;
    let mixers = default_mixers();

    let m_in = 1usize;
    let const_one_col = 0usize;

    let mem_inst = MemInstance::<Cmt, F> {
        mem_id: 0,
        comms: Vec::new(),
        k: 4,
        d: 1,
        n_side: 4,
        steps: 1,
        lanes: 1,
        ell: 2,
        init: MemInit::Zero,
    };
    let mem_wit = MemWitness { mats: Vec::new() };

    const COL_HAS_READ: usize = 1;
    const COL_HAS_WRITE: usize = 2;
    const COL_READ_ADDR: usize = 3;
    const COL_WRITE_ADDR: usize = 4;
    const COL_RV: usize = 5;
    const COL_WV: usize = 6;
    const COL_INC: usize = 7;

    let twist_cpu = vec![TwistCpuBinding {
        has_read: COL_HAS_READ,
        has_write: COL_HAS_WRITE,
        read_addr: COL_READ_ADDR,
        write_addr: COL_WRITE_ADDR,
        rv: COL_RV,
        wv: COL_WV,
        inc: Some(COL_INC),
    }];

    let ccs = extend_ccs_with_shared_cpu_bus_constraints(
        &base_ccs,
        m_in,
        const_one_col,
        &[],
        &twist_cpu,
        &[],
        &[mem_inst.clone()],
    )
    .expect("output-binding CCS should extend");

    let bus = build_bus_layout_for_instances(
        ccs.m,
        m_in,
        1,
        core::iter::empty(),
        core::iter::once(mem_inst.d * mem_inst.ell),
    )
    .expect("bus layout should build");

    let mut z = vec![F::ZERO; ccs.m];
    z[0] = F::ONE;
    z[COL_HAS_READ] = F::ZERO;
    z[COL_HAS_WRITE] = F::ONE;
    z[COL_READ_ADDR] = F::ZERO;
    z[COL_WRITE_ADDR] = F::from_u64(2);
    z[COL_RV] = F::ZERO;
    z[COL_WV] = F::from_u64(7);
    z[COL_INC] = F::from_u64(7);

    let twist = &bus.twist_cols[0].lanes[0];
    for col_id in twist.ra_bits.clone() {
        z[bus.bus_cell(col_id, 0)] = F::ZERO;
    }
    let wa_bits = [F::ZERO, F::ONE];
    for (i, col_id) in twist.wa_bits.clone().enumerate() {
        z[bus.bus_cell(col_id, 0)] = wa_bits[i];
    }
    z[bus.bus_cell(twist.has_read, 0)] = F::ZERO;
    z[bus.bus_cell(twist.has_write, 0)] = F::ONE;
    z[bus.bus_cell(twist.wv, 0)] = F::from_u64(7);
    z[bus.bus_cell(twist.rv, 0)] = F::ZERO;
    z[bus.bus_cell(twist.inc, 0)] = F::from_u64(7);

    let (mcs_inst, mcs_wit) = create_mcs_from_z(&params, &l, m_in, z);
    let steps_witness: Vec<StepWitnessBundle<Cmt, F, K>> =
        vec![crate::common_setup::canonicalize_step_time_columns(StepWitnessBundle {
            mcs: (mcs_inst, mcs_wit),
            lut_instances: vec![],
            mem_instances: vec![(mem_inst, mem_wit)],
            time_columns: TimeColumns::default(),
            _phantom: std::marker::PhantomData,
        })];
    let steps_public: Vec<StepInstanceBundle<Cmt, F, K>> =
        steps_witness.iter().map(StepInstanceBundle::from).collect();

    let ob_cfg = OutputBindingConfig::new(2, ProgramIO::new().with_output(2, F::from_u64(7)));
    let final_memory_state = vec![F::ZERO, F::ZERO, F::from_u64(7), F::ZERO];
    let acc_init: Vec<neo_ccs::relations::CeClaim<Cmt, F, K>> = Vec::new();
    let acc_wit_init: Vec<neo_ccs::Mat<F>> = Vec::new();

    let mut tr_prove = Poseidon2Transcript::new(b"output-binding-e2e");
    let (proof, _outputs, wits, audit) = fold_shard_prove_with_output_binding_and_audit(
        FoldingMode::Optimized,
        &mut tr_prove,
        &params,
        &ccs,
        &steps_witness,
        &acc_init,
        &acc_wit_init,
        &l,
        mixers,
        &ob_cfg,
        &final_memory_state,
    )
    .expect("output-binding proof should succeed");

    let mut tr_verify = Poseidon2Transcript::new(b"output-binding-e2e");
    let _ = fold_shard_verify_with_output_binding(
        FoldingMode::Optimized,
        &mut tr_verify,
        &params,
        &ccs,
        &steps_public,
        &acc_init,
        &proof,
        mixers,
        &ob_cfg,
    )
    .expect("output-binding proof should verify");

    vec![artifact_from_proof(
        "output_binding_e2e_valid",
        false,
        steps_witness.len(),
        params.b,
        params.k_rho,
        &params,
        &ccs,
        &l,
        &steps_witness,
        &acc_init,
        &acc_wit_init,
        &wits.final_main_wits,
        &proof,
        &audit,
    )]
}
