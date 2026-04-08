//! Owns the below-export RV64IM side-terminal theorem seam.
//!
//! The statement is restricted to already-carried Nightstream surfaces.
//! The witness is the union of the claim-side and opening-side native theorem
//! witnesses. This freezes the exact fixed-shape terminal target that a later
//! compact side-lane proof/decider should compress, without widening the
//! published Nightstream boundary.

use neo_transcript::{Poseidon2Transcript, Transcript};
use serde::{Deserialize, Serialize};

use crate::rv64im::kernel::{Rv64imAcceptedProofArtifact, Rv64imProofStatement, SimpleKernelError};

use super::{
    build_rv64im_side_claim_relation_statement, build_rv64im_side_claim_relation_witness_from_accepted_artifact,
    build_rv64im_side_opening_relation_statement, build_rv64im_side_opening_relation_witness_from_accepted_artifact,
    verify_rv64im_side_claim_relation, verify_rv64im_side_opening_relation, Rv64imSideClaimRelationStatement,
    Rv64imSideClaimRelationWitness, Rv64imSideOpeningRelationStatement, Rv64imSideOpeningRelationWitness,
    Rv64imSideProofBundle,
};

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct Rv64imSideTerminalRelationStatement {
    pub public_statement: Rv64imProofStatement,
    pub side_bundle: Rv64imSideProofBundle,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imSideTerminalRelationWitness {
    pub claims: Rv64imSideClaimRelationWitness,
    pub openings: Rv64imSideOpeningRelationWitness,
}

impl Rv64imSideTerminalRelationWitness {
    pub fn digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/nightstream/rv64im/side_terminal_relation_witness");
        tr.append_message(
            b"neo.fold.next/nightstream/rv64im/side_terminal_relation_witness/claims",
            &self.claims.digest(),
        );
        tr.append_message(
            b"neo.fold.next/nightstream/rv64im/side_terminal_relation_witness/openings",
            &self.openings.digest(),
        );
        tr.digest32()
    }
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imSideTerminalWitnessArtifact {
    pub statement_digest: [u8; 32],
    pub witness: Rv64imSideTerminalRelationWitness,
    pub digest: [u8; 32],
}

impl PartialEq for Rv64imSideTerminalWitnessArtifact {
    fn eq(&self, other: &Self) -> bool {
        self.statement_digest == other.statement_digest
            && self.digest == other.digest
            && self.witness.digest() == other.witness.digest()
    }
}

impl Eq for Rv64imSideTerminalWitnessArtifact {}

impl Rv64imSideTerminalWitnessArtifact {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/nightstream/rv64im/side_terminal_witness_artifact");
        tr.append_message(
            b"neo.fold.next/nightstream/rv64im/side_terminal_witness_artifact/statement_digest",
            &self.statement_digest,
        );
        tr.append_message(
            b"neo.fold.next/nightstream/rv64im/side_terminal_witness_artifact/witness_digest",
            &self.witness.digest(),
        );
        tr.digest32()
    }
}

pub(crate) fn rv64im_side_terminal_relation_statement_digest(
    statement: &Rv64imSideTerminalRelationStatement,
) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/nightstream/rv64im/side_terminal_relation");
    tr.append_message(
        b"neo.fold.next/nightstream/rv64im/side_terminal_relation/public_statement_digest",
        &statement.public_statement.digest,
    );
    tr.append_message(
        b"neo.fold.next/nightstream/rv64im/side_terminal_relation/side_bundle_digest",
        &statement.side_bundle.digest,
    );
    tr.digest32()
}

pub fn build_rv64im_side_terminal_relation_statement(
    public_statement: &Rv64imProofStatement,
    side_bundle: &Rv64imSideProofBundle,
) -> Result<Rv64imSideTerminalRelationStatement, SimpleKernelError> {
    if public_statement.digest != public_statement.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-terminal relation public statement digest mismatch".into(),
        ));
    }
    if side_bundle.digest != side_bundle.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-terminal relation side-proof bundle digest mismatch".into(),
        ));
    }
    Ok(Rv64imSideTerminalRelationStatement {
        public_statement: public_statement.clone(),
        side_bundle: side_bundle.clone(),
    })
}

pub fn build_rv64im_side_terminal_relation_witness_from_accepted_artifact(
    artifact: &Rv64imAcceptedProofArtifact,
) -> Rv64imSideTerminalRelationWitness {
    Rv64imSideTerminalRelationWitness {
        claims: build_rv64im_side_claim_relation_witness_from_accepted_artifact(artifact),
        openings: build_rv64im_side_opening_relation_witness_from_accepted_artifact(artifact),
    }
}

pub fn build_rv64im_side_terminal_relation_from_accepted_artifact(
    artifact: &Rv64imAcceptedProofArtifact,
) -> Result<(Rv64imSideTerminalRelationStatement, Rv64imSideTerminalRelationWitness), SimpleKernelError> {
    let side_bundle = super::build_rv64im_side_proof_bundle_from_accepted_artifact(artifact)?;
    let statement = build_rv64im_side_terminal_relation_statement(&artifact.statement, &side_bundle)?;
    let witness = build_rv64im_side_terminal_relation_witness_from_accepted_artifact(artifact);
    Ok((statement, witness))
}

pub fn build_rv64im_side_terminal_witness_artifact(
    statement: &Rv64imSideTerminalRelationStatement,
    witness: &Rv64imSideTerminalRelationWitness,
) -> Result<Rv64imSideTerminalWitnessArtifact, SimpleKernelError> {
    verify_rv64im_side_terminal_relation(statement, witness)?;
    let mut artifact = Rv64imSideTerminalWitnessArtifact {
        statement_digest: rv64im_side_terminal_relation_statement_digest(statement),
        witness: witness.clone(),
        digest: [0; 32],
    };
    artifact.digest = artifact.expected_digest();
    Ok(artifact)
}

pub fn build_rv64im_side_terminal_witness_artifact_from_accepted_artifact(
    artifact: &Rv64imAcceptedProofArtifact,
) -> Result<Rv64imSideTerminalWitnessArtifact, SimpleKernelError> {
    let (statement, witness) = build_rv64im_side_terminal_relation_from_accepted_artifact(artifact)?;
    build_rv64im_side_terminal_witness_artifact(&statement, &witness)
}

pub fn verify_rv64im_side_terminal_witness_artifact(
    statement: &Rv64imSideTerminalRelationStatement,
    artifact: &Rv64imSideTerminalWitnessArtifact,
) -> Result<(), SimpleKernelError> {
    verify_rv64im_side_terminal_relation(statement, &artifact.witness)?;
    if artifact.statement_digest != rv64im_side_terminal_relation_statement_digest(statement) {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-terminal witness artifact statement digest does not match the carried relation statement"
                .into(),
        ));
    }
    if artifact.digest != artifact.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-terminal witness artifact digest mismatch".into(),
        ));
    }
    Ok(())
}

pub fn verify_rv64im_side_terminal_relation(
    statement: &Rv64imSideTerminalRelationStatement,
    witness: &Rv64imSideTerminalRelationWitness,
) -> Result<(), SimpleKernelError> {
    if statement.public_statement.digest != statement.public_statement.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-terminal relation public statement digest mismatch".into(),
        ));
    }
    if statement.side_bundle.digest != statement.side_bundle.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-terminal relation side-proof bundle digest mismatch".into(),
        ));
    }

    let claim_statement: Rv64imSideClaimRelationStatement =
        build_rv64im_side_claim_relation_statement(&statement.public_statement, &statement.side_bundle)?;
    verify_rv64im_side_claim_relation(&claim_statement, &witness.claims)?;

    let opening_statement: Rv64imSideOpeningRelationStatement =
        build_rv64im_side_opening_relation_statement(&statement.public_statement, &statement.side_bundle)?;
    verify_rv64im_side_opening_relation(&opening_statement, &witness.openings)?;
    Ok(())
}
