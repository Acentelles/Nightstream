//! Owns the canonical `38 x T` RV64IM root-lane witness built once from execution rows.

use neo_math::F;
use neo_transcript::{Poseidon2Transcript, Transcript};

use crate::rv64im::ccs::{semantic_row_from_execution_row, RV64IM_ROOT_ROW_WIDTH};
use crate::rv64im::Rv64ExpandedRow;

pub(crate) fn next_power_of_two_len(len: usize) -> usize {
    len.max(1).next_power_of_two()
}

pub(crate) fn root_lane_row_digest(logical_index: u64, semantic_row: &[F; RV64IM_ROOT_ROW_WIDTH]) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/root_lane_row");
    tr.append_u64s(b"rv64im/root_lane_row/logical_index", &[logical_index]);
    tr.append_fields(b"rv64im/root_lane_row/semantic", semantic_row);
    tr.digest32()
}

pub(crate) fn root_lane_column_digest(column_index: u64, values: &[F]) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/root_lane_column");
    tr.append_u64s(b"rv64im/root_lane_column/meta", &[column_index, values.len() as u64]);
    tr.append_fields(b"rv64im/root_lane_column/values", values);
    tr.digest32()
}

pub(crate) fn root_lane_family_digest(column_digests: &[[u8; 32]]) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/root_lane_column_family");
    tr.append_u64s(
        b"rv64im/root_lane_column_family/column_count",
        &[column_digests.len() as u64],
    );
    for digest in column_digests {
        tr.append_message(b"rv64im/root_lane_column_family/column_digest", digest);
    }
    tr.digest32()
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub(crate) struct RootLaneWitness {
    pub semantic_rows: Vec<[F; RV64IM_ROOT_ROW_WIDTH]>,
    pub columns: Vec<Vec<F>>,
    pub padded_time_len: usize,
    pub first_row_digest: Option<[u8; 32]>,
    pub last_row_digest: Option<[u8; 32]>,
    pub column_digests: Vec<[u8; 32]>,
    pub family_digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub(crate) struct RootLanePublicWitness {
    pub columns: Vec<Vec<F>>,
    pub time_len: usize,
    pub padded_time_len: usize,
    pub first_row_digest: Option<[u8; 32]>,
    pub last_row_digest: Option<[u8; 32]>,
    pub column_digests: Vec<[u8; 32]>,
    pub family_digest: [u8; 32],
}

impl RootLaneWitness {
    pub fn time_len(&self) -> usize {
        self.semantic_rows.len()
    }

    pub fn padded_time_len(&self) -> usize {
        self.padded_time_len
    }
}

impl RootLanePublicWitness {
    pub fn padded_time_len(&self) -> usize {
        self.padded_time_len
    }
}

pub(crate) fn build_root_lane_witness(rows: &[Rv64ExpandedRow]) -> RootLaneWitness {
    let semantic_rows = rows
        .iter()
        .map(semantic_row_from_execution_row)
        .collect::<Vec<_>>();
    let time_len = semantic_rows.len();
    let padded_time_len = next_power_of_two_len(time_len);

    let mut columns = (0..RV64IM_ROOT_ROW_WIDTH)
        .map(|_| Vec::with_capacity(time_len))
        .collect::<Vec<_>>();
    let mut first_row_digest = None;
    let mut last_row_digest = None;

    for (logical_index, row) in semantic_rows.iter().enumerate() {
        if logical_index == 0 {
            first_row_digest = Some(root_lane_row_digest(logical_index as u64, row));
        }
        if logical_index + 1 == time_len {
            last_row_digest = Some(root_lane_row_digest(logical_index as u64, row));
        }
        for (column_index, value) in row.iter().enumerate() {
            columns[column_index].push(*value);
        }
    }

    let column_digests = columns
        .iter()
        .enumerate()
        .map(|(column_index, values)| root_lane_column_digest(column_index as u64, values))
        .collect::<Vec<_>>();
    let family_digest = root_lane_family_digest(&column_digests);

    RootLaneWitness {
        semantic_rows,
        columns,
        padded_time_len,
        first_row_digest,
        last_row_digest,
        column_digests,
        family_digest,
    }
}
