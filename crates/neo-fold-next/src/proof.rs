//! Owns the generic session proof boundary.
//!
//! Ownership:
//! - the active SuperNeo backend spine types (`StepInput`, `RunProof`, `PackagedProof`)
//!
//! It does not own:
//! - the `Π_CCS -> Π_RLC -> Π_DEC` protocol logic
//! - frontend step-build records
//! - time-opening summary surfaces
//! - VM-specific trace execution

use neo_ajtai::Commitment;
use neo_ccs::{CcsClaim, CcsWitness, CeClaim, Mat};
use neo_math::{F, K};
use neo_reductions::api::{PiCcsProof, RotRho};
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct StepInput {
    pub label: String,
    pub mcs: CcsClaim<Commitment, F>,
    pub witness: CcsWitness<F>,
}

impl StepInput {
    pub fn instance(&self) -> PublicStep {
        PublicStep {
            label: self.label.clone(),
            mcs: self.mcs.clone(),
        }
    }

    pub fn public(&self) -> PublicStep {
        self.instance()
    }
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct PublicStep {
    pub label: String,
    pub mcs: CcsClaim<Commitment, F>,
}

#[derive(Clone, Debug, Default, Serialize, Deserialize)]
pub struct Carry {
    pub claims: Vec<CeClaim<Commitment, F, K>>,
    pub witnesses: Vec<Mat<F>>,
}

impl Carry {
    pub fn is_empty(&self) -> bool {
        self.claims.is_empty() && self.witnesses.is_empty()
    }
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct PiRlcArtifact {
    pub rhos: Vec<RotRho>,
    pub parent: CeClaim<Commitment, F, K>,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct PiDecArtifact {
    pub children: Vec<CeClaim<Commitment, F, K>>,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct StepProof {
    pub step: PublicStep,
    pub ccs_outputs: Vec<CeClaim<Commitment, F, K>>,
    pub ccs_proof: PiCcsProof,
    pub rlc: PiRlcArtifact,
    pub dec: PiDecArtifact,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct StepResult {
    pub proof: StepProof,
    pub next_main: Carry,
}

#[derive(Clone, Debug, Default, Serialize, Deserialize)]
pub struct RunProof {
    pub steps: Vec<StepProof>,
    pub final_main_claims: Vec<CeClaim<Commitment, F, K>>,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct PublicStatement {
    pub steps: Vec<PublicStep>,
    pub final_main_claims: Vec<CeClaim<Commitment, F, K>>,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct FinalProof {
    pub session: RunProof,
    pub statement_digest: [u8; 32],
    pub proof_digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct PackagedProof {
    pub statement: PublicStatement,
    pub proof: FinalProof,
}
