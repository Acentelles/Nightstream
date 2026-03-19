//! Owns the staged proving skeleton and planner-facing stage types.

pub mod planner;

use crate::proof::OpeningClaim;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum ChunkModel {
    CompatibilityPerCpuStep,
    WholeTraceChunk,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct StageChallenge {
    pub epoch: u8,
    pub label: &'static str,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct FrontierPoint {
    pub stage: u8,
    pub label: &'static str,
}

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct OpeningAccumulator {
    pub claims: Vec<OpeningClaim>,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Stage1 {
    pub challenge: StageChallenge,
    pub frontier: FrontierPoint,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Stage2 {
    pub challenge: StageChallenge,
    pub frontier: FrontierPoint,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Stage3 {
    pub challenge: StageChallenge,
    pub frontier: FrontierPoint,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Stage4 {
    pub challenge: StageChallenge,
    pub frontier: FrontierPoint,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Stage5 {
    pub challenge: StageChallenge,
    pub frontier: FrontierPoint,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Stage6 {
    pub challenge: StageChallenge,
    pub frontier: FrontierPoint,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Stage7 {
    pub challenge: StageChallenge,
    pub frontier: FrontierPoint,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct PlannedStage {
    pub stage: u8,
    pub label: &'static str,
    pub families: Vec<crate::proof::ExtensionFamily>,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct StagePlan {
    pub vm_name: &'static str,
    pub chunk_model: ChunkModel,
    pub stages: Vec<PlannedStage>,
}
