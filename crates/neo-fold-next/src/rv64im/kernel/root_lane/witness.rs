//! Owns the canonical `38 x T` RV64IM root-lane witness built once from execution rows.

use neo_math::F;
use neo_transcript::{Poseidon2Transcript, Transcript};
use serde::{Deserialize, Serialize};

use crate::proof::PublicStatement;
use crate::rv64im::ccs::{semantic_row_from_execution_row, RV64IM_ROOT_ROW_WIDTH};
use crate::rv64im::Rv64ExpandedRow;

use super::public_step_digest;
use super::simple::{PreparedStepBindingSummary, SimpleKernelError};

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

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct RootSemanticRow {
    pub trace_index: usize,
    pub values: Vec<F>,
    pub row_digest: [u8; 32],
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct RowChunkRoute {
    pub logical_index: u64,
    pub chunk_index: u64,
    pub chunk_start_index: u64,
    pub chunk_local_index: u64,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct RootExecutionBundle {
    pub execution_rows: Vec<Rv64ExpandedRow>,
    pub semantic_rows: Vec<RootSemanticRow>,
    pub semantic_rows_digest: [u8; 32],
    pub prepared_step_bindings: PreparedStepBindingSummary,
    pub row_chunk_routes: Vec<RowChunkRoute>,
    pub row_chunk_routes_digest: [u8; 32],
    pub row_local_ccs_acceptance: RootRowLocalCcsAcceptanceSummary,
    pub execution_semantics_refinement: RootExecutionSemanticsRefinementSummary,
    pub family_digest: [u8; 32],
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct RootRowLocalCcsAcceptance {
    pub trace_index: usize,
    pub logical_index: u64,
    pub row_digest: [u8; 32],
    pub row_opening_digest: [u8; 32],
    pub prepared_step_binding_digest: [u8; 32],
    pub row_chunk_route_digest: [u8; 32],
    pub public_step_digest: [u8; 32],
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct RootRowLocalCcsAcceptanceSummary {
    pub acceptances: Vec<RootRowLocalCcsAcceptance>,
    pub acceptance_count: u64,
    pub first_acceptance_digest: Option<[u8; 32]>,
    pub last_acceptance_digest: Option<[u8; 32]>,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct RootExecutionSemanticsRefinement {
    pub trace_index: usize,
    pub logical_index: u64,
    pub semantic_row_digest: [u8; 32],
    pub row_local_ccs_acceptance_digest: [u8; 32],
    pub prepared_step_binding_digest: [u8; 32],
    pub public_step_digest: [u8; 32],
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct RootExecutionSemanticsRefinementSummary {
    pub refinements: Vec<RootExecutionSemanticsRefinement>,
    pub refinement_count: u64,
    pub first_refinement_digest: Option<[u8; 32]>,
    pub last_refinement_digest: Option<[u8; 32]>,
    pub digest: [u8; 32],
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

impl RootSemanticRow {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/root_execution_semantic_row");
        tr.append_u64s(
            b"rv64im/root_execution_semantic_row/meta",
            &[self.trace_index as u64, self.values.len() as u64],
        );
        tr.append_message(b"rv64im/root_execution_semantic_row/row_digest", &self.row_digest);
        tr.digest32()
    }
}

impl RowChunkRoute {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/root_execution_row_chunk_route");
        tr.append_u64s(
            b"rv64im/root_execution_row_chunk_route/meta",
            &[
                self.logical_index,
                self.chunk_index,
                self.chunk_start_index,
                self.chunk_local_index,
            ],
        );
        tr.digest32()
    }
}

impl RootRowLocalCcsAcceptance {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/root_row_local_ccs_acceptance");
        tr.append_u64s(
            b"rv64im/root_row_local_ccs_acceptance/meta",
            &[self.trace_index as u64, self.logical_index],
        );
        tr.append_message(b"rv64im/root_row_local_ccs_acceptance/row_digest", &self.row_digest);
        tr.append_message(
            b"rv64im/root_row_local_ccs_acceptance/row_opening_digest",
            &self.row_opening_digest,
        );
        tr.append_message(
            b"rv64im/root_row_local_ccs_acceptance/prepared_step_binding_digest",
            &self.prepared_step_binding_digest,
        );
        tr.append_message(
            b"rv64im/root_row_local_ccs_acceptance/row_chunk_route_digest",
            &self.row_chunk_route_digest,
        );
        tr.append_message(
            b"rv64im/root_row_local_ccs_acceptance/public_step_digest",
            &self.public_step_digest,
        );
        tr.digest32()
    }
}

impl RootRowLocalCcsAcceptanceSummary {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/root_row_local_ccs_acceptance_summary");
        tr.append_u64s(
            b"rv64im/root_row_local_ccs_acceptance_summary/meta",
            &[self.acceptance_count, self.acceptances.len() as u64],
        );
        tr.append_u64s(
            b"rv64im/root_row_local_ccs_acceptance_summary/first_present",
            &[self.first_acceptance_digest.is_some() as u64],
        );
        if let Some(digest) = &self.first_acceptance_digest {
            tr.append_message(
                b"rv64im/root_row_local_ccs_acceptance_summary/first_acceptance_digest",
                digest,
            );
        }
        tr.append_u64s(
            b"rv64im/root_row_local_ccs_acceptance_summary/last_present",
            &[self.last_acceptance_digest.is_some() as u64],
        );
        if let Some(digest) = &self.last_acceptance_digest {
            tr.append_message(
                b"rv64im/root_row_local_ccs_acceptance_summary/last_acceptance_digest",
                digest,
            );
        }
        for acceptance in &self.acceptances {
            tr.append_message(
                b"rv64im/root_row_local_ccs_acceptance_summary/acceptance_digest",
                &acceptance.digest,
            );
        }
        tr.digest32()
    }
}

impl RootExecutionSemanticsRefinement {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/root_execution_semantics_refinement");
        tr.append_u64s(
            b"rv64im/root_execution_semantics_refinement/meta",
            &[self.trace_index as u64, self.logical_index],
        );
        tr.append_message(
            b"rv64im/root_execution_semantics_refinement/semantic_row_digest",
            &self.semantic_row_digest,
        );
        tr.append_message(
            b"rv64im/root_execution_semantics_refinement/row_local_ccs_acceptance_digest",
            &self.row_local_ccs_acceptance_digest,
        );
        tr.append_message(
            b"rv64im/root_execution_semantics_refinement/prepared_step_binding_digest",
            &self.prepared_step_binding_digest,
        );
        tr.append_message(
            b"rv64im/root_execution_semantics_refinement/public_step_digest",
            &self.public_step_digest,
        );
        tr.digest32()
    }
}

impl RootExecutionSemanticsRefinementSummary {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/root_execution_semantics_refinement_summary");
        tr.append_u64s(
            b"rv64im/root_execution_semantics_refinement_summary/meta",
            &[self.refinement_count, self.refinements.len() as u64],
        );
        tr.append_u64s(
            b"rv64im/root_execution_semantics_refinement_summary/first_present",
            &[self.first_refinement_digest.is_some() as u64],
        );
        if let Some(digest) = &self.first_refinement_digest {
            tr.append_message(
                b"rv64im/root_execution_semantics_refinement_summary/first_refinement_digest",
                digest,
            );
        }
        tr.append_u64s(
            b"rv64im/root_execution_semantics_refinement_summary/last_present",
            &[self.last_refinement_digest.is_some() as u64],
        );
        if let Some(digest) = &self.last_refinement_digest {
            tr.append_message(
                b"rv64im/root_execution_semantics_refinement_summary/last_refinement_digest",
                digest,
            );
        }
        for refinement in &self.refinements {
            tr.append_message(
                b"rv64im/root_execution_semantics_refinement_summary/refinement_digest",
                &refinement.digest,
            );
        }
        tr.digest32()
    }
}

impl RootExecutionBundle {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/root_execution_bundle");
        tr.append_message(
            b"rv64im/root_execution_bundle/semantic_rows_digest",
            &self.semantic_rows_digest,
        );
        tr.append_message(
            b"rv64im/root_execution_bundle/prepared_step_bindings",
            &self.prepared_step_bindings.digest,
        );
        tr.append_message(
            b"rv64im/root_execution_bundle/row_chunk_routes_digest",
            &self.row_chunk_routes_digest,
        );
        tr.append_message(
            b"rv64im/root_execution_bundle/row_local_ccs_acceptance_digest",
            &self.row_local_ccs_acceptance.digest,
        );
        tr.append_message(
            b"rv64im/root_execution_bundle/execution_semantics_refinement_digest",
            &self.execution_semantics_refinement.digest,
        );
        tr.append_message(b"rv64im/root_execution_bundle/family_digest", &self.family_digest);
        tr.append_u64s(
            b"rv64im/root_execution_bundle/meta",
            &[
                self.execution_rows.len() as u64,
                self.semantic_rows.len() as u64,
                self.row_chunk_routes.len() as u64,
                self.row_local_ccs_acceptance.acceptance_count,
                self.execution_semantics_refinement.refinement_count,
            ],
        );
        tr.digest32()
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

pub(crate) fn build_root_execution_semantic_rows(rows: &[Rv64ExpandedRow]) -> Vec<RootSemanticRow> {
    rows.iter()
        .map(|row| {
            let semantic_row = semantic_row_from_execution_row(row);
            let semantic_values = semantic_row.to_vec();
            let digest = root_lane_row_digest(row.trace_index as u64, &semantic_row);
            let row = RootSemanticRow {
                trace_index: row.trace_index,
                values: semantic_values,
                row_digest: digest,
                digest: [0; 32],
            };
            RootSemanticRow {
                digest: row.expected_digest(),
                ..row
            }
        })
        .collect()
}

pub(crate) fn root_execution_semantic_rows_digest(rows: &[RootSemanticRow]) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/root_execution_semantic_rows");
    tr.append_u64s(b"rv64im/root_execution_semantic_rows/len", &[rows.len() as u64]);
    for row in rows {
        tr.append_message(b"rv64im/root_execution_semantic_rows/row", &row.digest);
    }
    tr.digest32()
}

pub(crate) fn root_execution_row_chunk_routes_digest(routes: &[RowChunkRoute]) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/root_execution_row_chunk_routes");
    tr.append_u64s(b"rv64im/root_execution_row_chunk_routes/len", &[routes.len() as u64]);
    for route in routes {
        tr.append_message(b"rv64im/root_execution_row_chunk_routes/route", &route.digest);
    }
    tr.digest32()
}

pub(crate) fn build_root_execution_row_chunk_routes(statement: &PublicStatement) -> Vec<RowChunkRoute> {
    let mut routes = Vec::with_capacity(statement.public_step_count());
    for (chunk_index, chunk) in statement.chunks.iter().enumerate() {
        for (chunk_local_index, _) in chunk.steps.iter().enumerate() {
            let route = RowChunkRoute {
                logical_index: (chunk.start_index + chunk_local_index) as u64,
                chunk_index: chunk_index as u64,
                chunk_start_index: chunk.start_index as u64,
                chunk_local_index: chunk_local_index as u64,
                digest: [0; 32],
            };
            routes.push(RowChunkRoute {
                digest: route.expected_digest(),
                ..route
            });
        }
    }
    routes
}

pub(crate) fn root_execution_public_step_digests(statement: &PublicStatement) -> Vec<[u8; 32]> {
    statement
        .chunks
        .iter()
        .flat_map(|chunk| chunk.steps.iter().map(public_step_digest))
        .collect()
}

pub(crate) fn build_root_row_local_ccs_acceptance_summary(
    prepared_step_bindings: &PreparedStepBindingSummary,
    row_chunk_routes: &[RowChunkRoute],
    public_step_digests: &[[u8; 32]],
) -> Result<RootRowLocalCcsAcceptanceSummary, SimpleKernelError> {
    let binding_len = prepared_step_bindings.bindings.len();
    if prepared_step_bindings.binding_count != binding_len as u64
        || binding_len != row_chunk_routes.len()
        || binding_len != public_step_digests.len()
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root row-local CCS acceptance inputs are misaligned".into(),
        ));
    }

    let mut acceptances = Vec::with_capacity(binding_len);
    for (logical_index, ((binding, route), public_step_digest)) in prepared_step_bindings
        .bindings
        .iter()
        .zip(row_chunk_routes.iter())
        .zip(public_step_digests.iter())
        .enumerate()
    {
        if route.logical_index != logical_index as u64 {
            return Err(SimpleKernelError::Bridge(
                "RV64IM root row-to-chunk routing lost logical row order".into(),
            ));
        }
        let acceptance = RootRowLocalCcsAcceptance {
            trace_index: binding.trace_index,
            logical_index: route.logical_index,
            row_digest: binding.row_digest,
            row_opening_digest: binding.row_opening_digest,
            prepared_step_binding_digest: binding.digest,
            row_chunk_route_digest: route.digest,
            public_step_digest: *public_step_digest,
            digest: [0; 32],
        };
        acceptances.push(RootRowLocalCcsAcceptance {
            digest: acceptance.expected_digest(),
            ..acceptance
        });
    }
    let summary = RootRowLocalCcsAcceptanceSummary {
        acceptance_count: acceptances.len() as u64,
        first_acceptance_digest: acceptances.first().map(|acceptance| acceptance.digest),
        last_acceptance_digest: acceptances.last().map(|acceptance| acceptance.digest),
        acceptances,
        digest: [0; 32],
    };
    Ok(RootRowLocalCcsAcceptanceSummary {
        digest: summary.expected_digest(),
        ..summary
    })
}

pub(crate) fn build_root_execution_semantics_refinement_summary(
    semantic_rows: &[RootSemanticRow],
    prepared_step_bindings: &PreparedStepBindingSummary,
    row_local_ccs_acceptance: &RootRowLocalCcsAcceptanceSummary,
    public_step_digests: &[[u8; 32]],
) -> Result<RootExecutionSemanticsRefinementSummary, SimpleKernelError> {
    let binding_len = prepared_step_bindings.bindings.len();
    if semantic_rows.len() != binding_len
        || row_local_ccs_acceptance.acceptances.len() != binding_len
        || public_step_digests.len() != binding_len
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root execution-semantics refinement inputs are misaligned".into(),
        ));
    }

    let mut refinements = Vec::with_capacity(binding_len);
    for (logical_index, (((semantic_row, binding), acceptance), public_step_digest)) in semantic_rows
        .iter()
        .zip(prepared_step_bindings.bindings.iter())
        .zip(row_local_ccs_acceptance.acceptances.iter())
        .zip(public_step_digests.iter())
        .enumerate()
    {
        if semantic_row.trace_index != binding.trace_index || semantic_row.trace_index != acceptance.trace_index {
            return Err(SimpleKernelError::Bridge(
                "RV64IM root execution-semantics refinement lost trace-index alignment".into(),
            ));
        }
        if acceptance.logical_index != logical_index as u64
            || acceptance.row_digest != semantic_row.row_digest
            || acceptance.prepared_step_binding_digest != binding.digest
            || acceptance.public_step_digest != *public_step_digest
        {
            return Err(SimpleKernelError::Bridge(
                "RV64IM root execution-semantics refinement lost row-local protocol alignment".into(),
            ));
        }
        let refinement = RootExecutionSemanticsRefinement {
            trace_index: semantic_row.trace_index,
            logical_index: acceptance.logical_index,
            semantic_row_digest: semantic_row.digest,
            row_local_ccs_acceptance_digest: acceptance.digest,
            prepared_step_binding_digest: binding.digest,
            public_step_digest: *public_step_digest,
            digest: [0; 32],
        };
        refinements.push(RootExecutionSemanticsRefinement {
            digest: refinement.expected_digest(),
            ..refinement
        });
    }
    let summary = RootExecutionSemanticsRefinementSummary {
        refinement_count: refinements.len() as u64,
        first_refinement_digest: refinements.first().map(|refinement| refinement.digest),
        last_refinement_digest: refinements.last().map(|refinement| refinement.digest),
        refinements,
        digest: [0; 32],
    };
    Ok(RootExecutionSemanticsRefinementSummary {
        digest: summary.expected_digest(),
        ..summary
    })
}
