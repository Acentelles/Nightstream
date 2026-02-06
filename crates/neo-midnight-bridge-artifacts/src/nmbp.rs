use crate::nmbws::{write_fq_repr, FqReprBytes};
use crate::relation::{RelationKind, RelationParamsV1};
use anyhow::{anyhow, Result};
use ff::PrimeField;
use midnight_proofs::poly::commitment::Params;
use midnight_proofs::plonk::{self, ConstraintSystem, Expression};
use midnight_proofs::utils::SerdeFormat;
use midnight_zk_stdlib::Relation;
use rand_core::SeedableRng;
use rand_chacha::ChaCha20Rng;

type F = midnight_curves::Fq;
type E = midnight_curves::Bls12;
type ParamsKZG = midnight_proofs::poly::kzg::params::ParamsKZG<E>;

const NMBP_MAGIC: &[u8; 4] = b"NMBP";
const NMBP_VERSION_V3: u32 = 3;

#[derive(Clone, Debug)]
pub struct NmbpV3 {
    pub relation_kind: RelationKind,
    pub relation_params_json: Vec<u8>,
    pub k: u32,
    pub n: u32,
    pub params_bytes: Vec<u8>,
    pub vk_bytes: Vec<u8>,
    pub vk_transcript_repr: FqReprBytes,
    pub pk_bytes: Vec<u8>,
    pub cs_bytes: Vec<u8>,
}

impl NmbpV3 {
    pub fn to_bytes(&self) -> Vec<u8> {
        let mut out = Vec::new();
        out.extend_from_slice(NMBP_MAGIC);
        out.extend_from_slice(&NMBP_VERSION_V3.to_le_bytes());

        out.extend_from_slice(&self.relation_kind.as_u32().to_le_bytes());
        write_len_prefixed(&mut out, &self.relation_params_json);
        out.extend_from_slice(&self.k.to_le_bytes());
        out.extend_from_slice(&self.n.to_le_bytes());

        write_len_prefixed(&mut out, &self.params_bytes);
        write_len_prefixed(&mut out, &self.vk_bytes);
        out.extend_from_slice(&self.vk_transcript_repr);
        write_len_prefixed(&mut out, &self.pk_bytes);
        write_len_prefixed(&mut out, &self.cs_bytes);
        out
    }
}

fn write_len_prefixed(out: &mut Vec<u8>, bytes: &[u8]) {
    let len: u32 = bytes.len().try_into().expect("len fits u32");
    out.extend_from_slice(&len.to_le_bytes());
    out.extend_from_slice(bytes);
}

fn write_u32(out: &mut Vec<u8>, v: u32) {
    out.extend_from_slice(&v.to_le_bytes());
}

fn write_u8(out: &mut Vec<u8>, v: u8) {
    out.push(v);
}

fn write_i32(out: &mut Vec<u8>, v: i32) {
    out.extend_from_slice(&v.to_le_bytes());
}

fn write_string(out: &mut Vec<u8>, s: &str) {
    write_len_prefixed(out, s.as_bytes());
}

fn write_any_column_parts(out: &mut Vec<u8>, col_type: plonk::Any, index: usize) {
    use plonk::Any;
    match col_type {
        Any::Instance => {
            write_u8(out, 0);
            write_u32(out, index as u32);
        }
        Any::Advice(advice) => {
            write_u8(out, 1);
            write_u32(out, index as u32);
            write_u8(out, advice.phase());
        }
        Any::Fixed => {
            write_u8(out, 2);
            write_u32(out, index as u32);
        }
    }
}

fn write_expr(out: &mut Vec<u8>, expr: &Expression<F>) {
    match expr {
        Expression::Constant(c) => {
            write_u8(out, 0);
            write_fq_repr(out, *c);
        }
        Expression::Selector(sel) => {
            write_u8(out, 1);
            write_u32(out, sel.index() as u32);
            write_u8(out, sel.is_simple() as u8);
        }
        Expression::Fixed(q) => {
            write_u8(out, 2);
            write_u32(out, q.column_index() as u32);
            write_i32(out, q.rotation().0);
        }
        Expression::Advice(q) => {
            write_u8(out, 3);
            write_u32(out, q.column_index() as u32);
            write_i32(out, q.rotation().0);
            write_u8(out, q.phase());
        }
        Expression::Instance(q) => {
            write_u8(out, 4);
            write_u32(out, q.column_index() as u32);
            write_i32(out, q.rotation().0);
        }
        Expression::Challenge(ch) => {
            write_u8(out, 5);
            write_u32(out, ch.index() as u32);
            write_u8(out, ch.phase());
        }
        Expression::Negated(a) => {
            write_u8(out, 6);
            write_expr(out, a);
        }
        Expression::Sum(a, b) => {
            write_u8(out, 7);
            write_expr(out, a);
            write_expr(out, b);
        }
        Expression::Product(a, b) => {
            write_u8(out, 8);
            write_expr(out, a);
            write_expr(out, b);
        }
        Expression::Scaled(a, s) => {
            write_u8(out, 9);
            write_expr(out, a);
            write_fq_repr(out, *s);
        }
    }
}

fn write_cs(out: &mut Vec<u8>, cs: &ConstraintSystem<F>) {
    write_u32(out, cs.num_fixed_columns() as u32);
    write_u32(out, cs.num_advice_columns() as u32);
    write_u32(out, cs.num_instance_columns() as u32);
    write_u32(out, cs.num_selectors() as u32);
    write_u32(out, cs.num_challenges() as u32);

    write_u32(out, cs.blinding_factors() as u32);
    write_u32(out, cs.degree() as u32);

    let advice_phases = cs.advice_column_phase();
    write_u32(out, advice_phases.len() as u32);
    out.extend_from_slice(&advice_phases);

    let challenge_phases = cs.challenge_phase();
    write_u32(out, challenge_phases.len() as u32);
    out.extend_from_slice(&challenge_phases);

    // Unblinded advice columns are not exposed by midnight-proofs' public API.
    // We include an empty list for now; current bridge circuits do not rely on it.
    write_u32(out, 0);

    write_u32(out, cs.gates().len() as u32);
    for gate in cs.gates() {
        write_string(out, gate.name());
        write_u32(out, gate.polynomials().len() as u32);
        for (i, poly) in gate.polynomials().iter().enumerate() {
            write_string(out, gate.constraint_name(i));
            write_expr(out, poly);
        }
    }

    // Queries
    write_u32(out, cs.fixed_queries().len() as u32);
    for (col, rot) in cs.fixed_queries() {
        write_u32(out, col.index() as u32);
        write_i32(out, rot.0);
    }
    write_u32(out, cs.advice_queries().len() as u32);
    for (col, rot) in cs.advice_queries() {
        write_u32(out, col.index() as u32);
        write_u8(out, col.column_type().phase());
        write_i32(out, rot.0);
    }
    write_u32(out, cs.instance_queries().len() as u32);
    for (col, rot) in cs.instance_queries() {
        write_u32(out, col.index() as u32);
        write_i32(out, rot.0);
    }

    // Permutation
    let perm_cols = cs.permutation().get_columns();
    write_u32(out, perm_cols.len() as u32);
    for col in perm_cols {
        write_any_column_parts(out, *col.column_type(), col.index());
    }

    // Lookups
    write_u32(out, cs.lookups().len() as u32);
    for lookup in cs.lookups() {
        write_string(out, lookup.name());
        let m = lookup.input_expressions().len();
        write_u32(out, m as u32);
        for (inp, tbl) in lookup
            .input_expressions()
            .iter()
            .zip(lookup.table_expressions().iter())
        {
            write_expr(out, inp);
            write_expr(out, tbl);
        }
    }

    // Trash
    write_u32(out, cs.trashcans().len() as u32);
    for trash in cs.trashcans() {
        write_string(out, trash.name());
        write_expr(out, trash.selector());
        write_u32(out, trash.constraint_expressions().len() as u32);
        for e in trash.constraint_expressions() {
            write_expr(out, e);
        }
    }

    // Constants
    write_u32(out, cs.constants().len() as u32);
    for c in cs.constants() {
        write_u32(out, c.index() as u32);
    }

    // General column annotations
    let ann = cs.general_column_annotations();
    write_u32(out, ann.len() as u32);
    for (col, label) in ann.iter() {
        // `metadata::Column` wraps `Any` + index.
        write_any_column_parts(out, col.column_type(), col.index());
        write_string(out, label);
    }
}

pub fn export_package_v3<R: Relation + Clone>(
    relation_kind: RelationKind,
    relation_params: &RelationParamsV1,
    relation: &R,
    rng_seed: [u8; 32],
) -> Result<NmbpV3> {
    if relation_params.kind() != relation_kind {
        return Err(anyhow!(
            "relation_kind {:?} does not match relation_params {:?}",
            relation_kind,
            relation_params.kind()
        ));
    }

    let circuit = midnight_zk_stdlib::MidnightCircuit::from_relation(relation);
    let k = circuit.min_k();

    let params: ParamsKZG = ParamsKZG::unsafe_setup(k, ChaCha20Rng::from_seed(rng_seed));
    export_package_with_params_v3(relation_kind, relation_params, relation, &params)
}

pub fn export_package_with_params_v3<R: Relation + Clone>(
    relation_kind: RelationKind,
    relation_params: &RelationParamsV1,
    relation: &R,
    params: &ParamsKZG,
) -> Result<NmbpV3> {
    if relation_params.kind() != relation_kind {
        return Err(anyhow!(
            "relation_kind {:?} does not match relation_params {:?}",
            relation_kind,
            relation_params.kind()
        ));
    }

    let circuit = midnight_zk_stdlib::MidnightCircuit::from_relation(relation);
    let min_k = circuit.min_k();
    let k = params.max_k();
    if k < min_k {
        return Err(anyhow!(
            "params.max_k={k} is smaller than circuit.min_k={min_k}"
        ));
    }
    let n: u32 = 1u32
        .checked_shl(k)
        .ok_or_else(|| anyhow!("k too large: {k}"))?;

    let vk = midnight_zk_stdlib::setup_vk(params, relation);
    let pk = midnight_zk_stdlib::setup_pk(relation, &vk);

    let mut params_bytes = Vec::new();
    params
        .write_custom(&mut params_bytes, SerdeFormat::RawBytesUnchecked)
        .map_err(|e| anyhow!("ParamsKZG::write_custom failed: {e}"))?;

    let mut vk_bytes = Vec::new();
    vk.vk()
        .write(&mut vk_bytes, SerdeFormat::RawBytesUnchecked)
        .map_err(|e| anyhow!("VerifyingKey::write failed: {e}"))?;

    let mut vk_transcript_repr: FqReprBytes = [0u8; 32];
    vk_transcript_repr.copy_from_slice(vk.vk().transcript_repr().to_repr().as_ref());

    let mut pk_bytes = Vec::new();
    pk.pk()
        .write(&mut pk_bytes, SerdeFormat::RawBytesUnchecked)
        .map_err(|e| anyhow!("ProvingKey::write failed: {e}"))?;

    let mut cs_bytes = Vec::new();
    write_cs(&mut cs_bytes, vk.vk().cs());

    let relation_params_json = serde_json::to_vec(relation_params)?;
    Ok(NmbpV3 {
        relation_kind,
        relation_params_json,
        k,
        n,
        params_bytes,
        vk_bytes,
        vk_transcript_repr,
        pk_bytes,
        cs_bytes,
    })
}
