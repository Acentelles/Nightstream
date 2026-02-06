use anyhow::{anyhow, Result};
use neo_midnight_bridge::relations::SparsePolyRepr;
use serde::{Deserialize, Serialize};

/// Stable discriminants for on-disk artifacts.
///
/// WARNING: Values are part of the `.nmbp` / `.nmbws` formats. Do not renumber.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[repr(u32)]
pub enum RelationKind {
    GoldilocksMul = 1,
    SumcheckSingleRound = 2,
    PiCcsSumcheck = 3,
    PiCcsSumcheckNc = 4,
    PiCcsFeTerminalK1 = 5,
    PiCcsNcTerminalK1 = 6,
    PiCcsNcChunk = 7,
    PiCcsFeChunk = 8,
    PiCcsNcChunkAggSumcheck = 9,
    PiCcsFeChunkAggSumcheck = 10,
}

impl RelationKind {
    pub fn from_str(s: &str) -> Result<Self> {
        match s {
            "goldilocks_mul" => Ok(Self::GoldilocksMul),
            "sumcheck_single_round" => Ok(Self::SumcheckSingleRound),
            "pi_ccs_sumcheck" => Ok(Self::PiCcsSumcheck),
            "pi_ccs_sumcheck_nc" => Ok(Self::PiCcsSumcheckNc),
            "pi_ccs_fe_terminal_k1" => Ok(Self::PiCcsFeTerminalK1),
            "pi_ccs_nc_terminal_k1" => Ok(Self::PiCcsNcTerminalK1),
            "pi_ccs_nc_chunk" => Ok(Self::PiCcsNcChunk),
            "pi_ccs_fe_chunk" => Ok(Self::PiCcsFeChunk),
            "pi_ccs_nc_chunk_agg_sumcheck" => Ok(Self::PiCcsNcChunkAggSumcheck),
            "pi_ccs_fe_chunk_agg_sumcheck" => Ok(Self::PiCcsFeChunkAggSumcheck),
            _ => Err(anyhow!("unknown relation kind: {s}")),
        }
    }

    pub fn as_u32(self) -> u32 {
        self as u32
    }
}

/// Versioned relation parameters encoded as UTF-8 JSON inside `.nmbp`.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum RelationParamsV1 {
    GoldilocksMul { version: u32 },
    SumcheckSingleRound { version: u32, n_coeffs: usize },
    PiCcsSumcheck {
        version: u32,
        n_rounds: usize,
        poly_len: usize,
    },
    PiCcsSumcheckNc {
        version: u32,
        n_rounds: usize,
        poly_len: usize,
    },
    PiCcsFeTerminalK1 {
        version: u32,
        ell_n: usize,
        ell_d: usize,
        poly: SparsePolyRepr,
    },
    PiCcsNcTerminalK1 {
        version: u32,
        ell_d: usize,
        ell_m: usize,
        b: u32,
    },
    PiCcsNcChunk {
        version: u32,
        ell_d: usize,
        b: u32,
        start_exp: usize,
        count: usize,
    },
    PiCcsFeChunk {
        version: u32,
        ell_d: usize,
        k_total: usize,
        t: usize,
        start_idx: usize,
        count: usize,
    },
    PiCcsNcChunkAggSumcheck {
        version: u32,
        n_rounds: usize,
        poly_len: usize,
        ell_d: usize,
        ell_m: usize,
        b: u32,
        start_exp: usize,
        count: usize,
        n_chunks: usize,
        chunk_index: usize,
    },
    PiCcsFeChunkAggSumcheck {
        version: u32,
        n_rounds: usize,
        poly_len: usize,
        ell_n: usize,
        ell_d: usize,
        k_total: usize,
        poly: SparsePolyRepr,
        start_idx: usize,
        count: usize,
        n_chunks: usize,
        chunk_index: usize,
    },
}

impl RelationParamsV1 {
    pub fn kind(&self) -> RelationKind {
        match self {
            RelationParamsV1::GoldilocksMul { .. } => RelationKind::GoldilocksMul,
            RelationParamsV1::SumcheckSingleRound { .. } => RelationKind::SumcheckSingleRound,
            RelationParamsV1::PiCcsSumcheck { .. } => RelationKind::PiCcsSumcheck,
            RelationParamsV1::PiCcsSumcheckNc { .. } => RelationKind::PiCcsSumcheckNc,
            RelationParamsV1::PiCcsFeTerminalK1 { .. } => RelationKind::PiCcsFeTerminalK1,
            RelationParamsV1::PiCcsNcTerminalK1 { .. } => RelationKind::PiCcsNcTerminalK1,
            RelationParamsV1::PiCcsNcChunk { .. } => RelationKind::PiCcsNcChunk,
            RelationParamsV1::PiCcsFeChunk { .. } => RelationKind::PiCcsFeChunk,
            RelationParamsV1::PiCcsNcChunkAggSumcheck { .. } => RelationKind::PiCcsNcChunkAggSumcheck,
            RelationParamsV1::PiCcsFeChunkAggSumcheck { .. } => RelationKind::PiCcsFeChunkAggSumcheck,
        }
    }
}
