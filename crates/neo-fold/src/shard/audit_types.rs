use neo_ccs::Mat;
use neo_math::F;

#[derive(Clone, Debug)]
pub struct LaneWitnessAudit<FF> {
    pub input_witnesses: Vec<Mat<FF>>,
    pub parent_witness: Mat<FF>,
    pub child_witnesses: Vec<Mat<FF>>,
}

impl<FF> LaneWitnessAudit<FF> {
    pub fn new(input_witnesses: Vec<Mat<FF>>, parent_witness: Mat<FF>, child_witnesses: Vec<Mat<FF>>) -> Self {
        Self {
            input_witnesses,
            parent_witness,
            child_witnesses,
        }
    }
}

#[derive(Clone, Debug)]
pub struct StepWitnessAudit<FF> {
    pub main_lane: LaneWitnessAudit<FF>,
    pub val_lanes: Vec<LaneWitnessAudit<FF>>,
    pub booleanity_lanes: Vec<LaneWitnessAudit<FF>>,
    pub trace_opening_lanes: Vec<LaneWitnessAudit<FF>>,
}

#[derive(Clone, Debug, Default)]
pub struct ShardProofAudit<FF> {
    pub steps: Vec<StepWitnessAudit<FF>>,
}

impl StepWitnessAudit<F> {
    pub fn new(
        main_lane: LaneWitnessAudit<F>,
        val_lanes: Vec<LaneWitnessAudit<F>>,
        booleanity_lanes: Vec<LaneWitnessAudit<F>>,
        trace_opening_lanes: Vec<LaneWitnessAudit<F>>,
    ) -> Self {
        Self {
            main_lane,
            val_lanes,
            booleanity_lanes,
            trace_opening_lanes,
        }
    }
}
