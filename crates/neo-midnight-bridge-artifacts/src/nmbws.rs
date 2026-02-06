use anyhow::{anyhow, Result};
use ff::PrimeField;
use midnight_proofs::dev::{CellValue, InstanceValue, MockProver};
use midnight_proofs::plonk::Circuit;

pub type F = midnight_curves::Fq;
pub type FqReprBytes = [u8; 32];

const NMBWS_MAGIC: &[u8; 4] = b"NMBW";
const NMBWS_VERSION_V2: u32 = 2;

pub fn write_fq_repr(out: &mut Vec<u8>, x: F) {
    out.extend_from_slice(x.to_repr().as_ref());
}

#[derive(Clone, Debug)]
pub struct NmbwsV2 {
    pub k: u32,
    pub n: u32,
    pub usable_rows: u32,
    /// For each instance column, the number of provided (non-padding) values.
    ///
    /// This is required for transcript compatibility: public instance columns
    /// hash only `len` + the provided values, not the padded zeros.
    pub instance_provided_lens: Vec<u32>,
    pub instance_cols: Vec<Vec<FqReprBytes>>,
    pub advice_cols: Vec<Vec<FqReprBytes>>,
}

impl NmbwsV2 {
    pub fn to_bytes(&self) -> Vec<u8> {
        let mut out = Vec::new();
        out.extend_from_slice(NMBWS_MAGIC);
        out.extend_from_slice(&NMBWS_VERSION_V2.to_le_bytes());
        out.extend_from_slice(&self.k.to_le_bytes());
        out.extend_from_slice(&self.n.to_le_bytes());
        out.extend_from_slice(&self.usable_rows.to_le_bytes());

        write_u32(&mut out, self.instance_cols.len() as u32);
        for (provided_len, col) in self
            .instance_provided_lens
            .iter()
            .copied()
            .zip(self.instance_cols.iter())
        {
            write_u32(&mut out, provided_len);
            write_u32(&mut out, col.len() as u32);
            for x in col {
                out.extend_from_slice(x);
            }
        }

        write_u32(&mut out, self.advice_cols.len() as u32);
        for col in &self.advice_cols {
            write_u32(&mut out, col.len() as u32);
            for x in col {
                out.extend_from_slice(x);
            }
        }

        out
    }
}

fn write_u32(out: &mut Vec<u8>, v: u32) {
    out.extend_from_slice(&v.to_le_bytes());
}

pub fn export_witness_snapshot_v2<C: Circuit<F>>(
    k: u32,
    circuit: &C,
    instance_columns: Vec<Vec<F>>,
) -> Result<NmbwsV2> {
    let instance_provided_lens = instance_columns.iter().map(|v| v.len() as u32).collect::<Vec<_>>();
    let prover = MockProver::<F>::run(k, circuit, instance_columns)?;
    let n = 1u32.checked_shl(k).ok_or_else(|| anyhow!("k too large: {k}"))?;

    let usable = prover.usable_rows();
    if usable.start != 0 {
        return Err(anyhow!("unexpected usable_rows start={}", usable.start));
    }
    let usable_rows: u32 = usable.end.try_into()?;

    let instance_cols = prover
        .instance()
        .iter()
        .map(|col| {
            col.iter()
                .map(|v| match v {
                    InstanceValue::Assigned(x) => {
                        let mut repr = [0u8; 32];
                        repr.copy_from_slice(x.to_repr().as_ref());
                        repr
                    }
                    InstanceValue::Padding => [0u8; 32],
                })
                .collect::<Vec<_>>()
        })
        .collect::<Vec<_>>();

    let advice_cols = prover
        .advice()
        .iter()
        .map(|col| {
            col.iter()
                .map(|v| match v {
                    CellValue::Assigned(x) => {
                        let mut repr = [0u8; 32];
                        repr.copy_from_slice(x.to_repr().as_ref());
                        repr
                    }
                    CellValue::Unassigned | CellValue::Poison(_) => [0u8; 32],
                })
                .collect::<Vec<_>>()
        })
        .collect::<Vec<_>>();

    Ok(NmbwsV2 {
        k,
        n,
        usable_rows,
        instance_provided_lens,
        instance_cols,
        advice_cols,
    })
}
