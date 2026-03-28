//! Owns the current canonical main-lane family summary and digest helpers for RV64IM step exports.

use neo_math::F;
use neo_transcript::{Poseidon2Transcript, Transcript, TranscriptProtocol};
use serde::{Deserialize, Serialize};

use super::canonical_openings::{AjtaiFamilyKind, AjtaiObjectId, SelectedOpeningRef};
use crate::proof::{PublicStep, StepInput};
use crate::rv64im::ccs::RV64IM_ROOT_ROW_WIDTH;

pub(crate) const RV64IM_MAIN_LANE_LAYOUT_V1: u64 = 1;

fn append_f_vec(tr: &mut Poseidon2Transcript, label: &'static [u8], values: &[F]) {
    tr.append_u64s(b"rv64im/main_lane/f_len", &[values.len() as u64]);
    tr.append_fields(label, values);
}

fn append_matrix(tr: &mut Poseidon2Transcript, label: &'static [u8], values: &[F], rows: usize, cols: usize) {
    tr.append_u64s(b"rv64im/main_lane/matrix_meta", &[rows as u64, cols as u64]);
    tr.append_fields(label, values);
}

pub(crate) fn append_public_step(tr: &mut Poseidon2Transcript, step: &PublicStep) {
    tr.append_message(b"rv64im/main_lane/label", step.label.as_bytes());
    tr.append_u64s(
        b"rv64im/main_lane/public_meta",
        &[step.mcs.m_in as u64, step.mcs.x.len() as u64],
    );
    tr.append_u64s(
        b"rv64im/main_lane/public_commitment_meta",
        &[step.mcs.c.d as u64, step.mcs.c.kappa as u64],
    );
    tr.absorb_commit_coords(&step.mcs.c.data);
    tr.append_fields(b"rv64im/main_lane/public_x", &step.mcs.x);
}

pub fn public_step_digest(step: &PublicStep) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/public_step");
    append_public_step(&mut tr, step);
    tr.digest32()
}

pub fn same_public_step(lhs: &PublicStep, rhs: &PublicStep) -> bool {
    lhs.label == rhs.label
        && lhs.mcs.m_in == rhs.mcs.m_in
        && lhs.mcs.x == rhs.mcs.x
        && lhs.mcs.c.d == rhs.mcs.c.d
        && lhs.mcs.c.kappa == rhs.mcs.c.kappa
        && lhs.mcs.c.data == rhs.mcs.c.data
}

pub fn prepared_step_digest(step: &StepInput) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/prepared_step");
    append_public_step(&mut tr, &step.instance());
    append_f_vec(&mut tr, b"rv64im/prepared_step/witness_w", &step.witness.w);
    append_matrix(
        &mut tr,
        b"rv64im/prepared_step/witness_Z",
        step.witness.Z.as_slice(),
        step.witness.Z.rows(),
        step.witness.Z.cols(),
    );
    tr.digest32()
}

pub fn public_step_family_digest(public_steps: &[PublicStep]) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/main_lane_public_step_family");
    tr.append_u64s(
        b"rv64im/main_lane_public_step_family/count",
        &[public_steps.len() as u64],
    );
    for step in public_steps {
        tr.append_message(
            b"rv64im/main_lane_public_step_family/public_step_digest",
            &public_step_digest(step),
        );
    }
    tr.digest32()
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct MainLaneFamilySummary {
    pub object: AjtaiObjectId,
    pub row_width: u64,
    pub public_step_count: u64,
    pub family_digest: [u8; 32],
    pub first_public_step: Option<SelectedOpeningRef>,
    pub last_public_step: Option<SelectedOpeningRef>,
    pub digest: [u8; 32],
}

impl MainLaneFamilySummary {
    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/main_lane_family_summary");
        tr.append_message(b"rv64im/main_lane_family_summary/object_digest", &self.object.digest);
        tr.append_u64s(
            b"rv64im/main_lane_family_summary/meta",
            &[self.row_width, self.public_step_count],
        );
        tr.append_message(b"rv64im/main_lane_family_summary/family_digest", &self.family_digest);
        tr.append_u64s(
            b"rv64im/main_lane_family_summary/first_present",
            &[self.first_public_step.is_some() as u64],
        );
        if let Some(reference) = &self.first_public_step {
            tr.append_message(
                b"rv64im/main_lane_family_summary/first_opening_digest",
                &reference.digest,
            );
        }
        tr.append_u64s(
            b"rv64im/main_lane_family_summary/last_present",
            &[self.last_public_step.is_some() as u64],
        );
        if let Some(reference) = &self.last_public_step {
            tr.append_message(
                b"rv64im/main_lane_family_summary/last_opening_digest",
                &reference.digest,
            );
        }
        tr.digest32()
    }

    pub fn opening_refs(&self) -> Vec<&SelectedOpeningRef> {
        let mut refs = Vec::new();
        if let Some(reference) = &self.first_public_step {
            refs.push(reference);
        }
        if let Some(reference) = &self.last_public_step {
            refs.push(reference);
        }
        refs
    }
}

pub fn build_main_lane_family_summary(public_steps: &[PublicStep]) -> MainLaneFamilySummary {
    let family_digest = public_step_family_digest(public_steps);
    let object = AjtaiObjectId::new(
        AjtaiFamilyKind::RootMainLanePublicSteps,
        family_digest,
        RV64IM_MAIN_LANE_LAYOUT_V1,
    );
    let first_public_step = public_steps.first().map(|step| {
        SelectedOpeningRef::from_parts(
            AjtaiFamilyKind::RootMainLanePublicSteps,
            family_digest,
            RV64IM_MAIN_LANE_LAYOUT_V1,
            0,
            public_step_digest(step),
        )
    });
    let last_public_step = public_steps.last().map(|step| {
        SelectedOpeningRef::from_parts(
            AjtaiFamilyKind::RootMainLanePublicSteps,
            family_digest,
            RV64IM_MAIN_LANE_LAYOUT_V1,
            public_steps.len().saturating_sub(1) as u64,
            public_step_digest(step),
        )
    });
    let summary = MainLaneFamilySummary {
        object,
        row_width: RV64IM_ROOT_ROW_WIDTH as u64,
        public_step_count: public_steps.len() as u64,
        family_digest,
        first_public_step,
        last_public_step,
        digest: [0; 32],
    };
    MainLaneFamilySummary {
        digest: summary.expected_digest(),
        ..summary
    }
}
