//! Owns the below-export RV64IM Phase 0 eval-claim theorem seam.
//!
//! The statement keeps the current carried side bundle stable and makes the
//! missing Phase 0 assumptions explicit: compact opened-object summaries and
//! exact stage-proof binding digests. The witness owns the real claim/witness
//! pairs built from accepted artifacts.

use std::collections::BTreeMap;

use neo_transcript::{Poseidon2Transcript, Transcript};
use serde::{Deserialize, Serialize};

use crate::rv64im::kernel::{
    build_rv64im_eval_claim_bundle_from_claim_witnesses,
    build_rv64im_eval_claim_bundle_from_claim_witnesses_trusted_local,
    build_rv64im_eval_claim_witnesses_from_accepted_artifact, derive_phase0_point, phase0_binding_digest,
    CommitmentContextId, FamilyEvalClaim, FamilyEvalClaimWitness, FamilyEvalSchemaId, OpenedAjtaiObjectId,
    Rv64imAcceptedProofArtifact, Rv64imEvalClaimBundle, SimpleKernelError,
};
use crate::rv64im::Rv64imProofStatement;

use super::{build_rv64im_side_proof_bundle_from_accepted_artifact, Rv64imSideProofBundle};

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64imPhase0OpenedObjectSummary {
    pub schema: FamilyEvalSchemaId,
    pub opened_object: OpenedAjtaiObjectId,
    pub commitment_context: CommitmentContextId,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64imPhase0OpenedObjectBundle {
    pub objects: Vec<Rv64imPhase0OpenedObjectSummary>,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64imPhase0StageProofBindingDigests {
    pub stage1_proof_digest: [u8; 32],
    pub stage2_proof_digest: [u8; 32],
    pub stage3_proof_digest: [u8; 32],
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Rv64imSideEvalClaimRelationStatement {
    pub public_statement: Rv64imProofStatement,
    pub side_bundle: Rv64imSideProofBundle,
    pub phase0_opened_objects: Rv64imPhase0OpenedObjectBundle,
    pub phase0_stage_proof_bindings: Rv64imPhase0StageProofBindingDigests,
    pub eval_claim_bundle: Rv64imEvalClaimBundle,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Rv64imSideEvalClaimRelationWitness {
    pub claim_witnesses: Vec<FamilyEvalClaimWitness>,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64imSideEvalClaimArtifact {
    pub statement_digest: [u8; 32],
    pub phase0_opened_objects: Rv64imPhase0OpenedObjectBundle,
    pub phase0_stage_proof_bindings: Rv64imPhase0StageProofBindingDigests,
    pub eval_claim_bundle: Rv64imEvalClaimBundle,
    pub digest: [u8; 32],
}

impl Rv64imPhase0OpenedObjectSummary {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/nightstream/rv64im/phase0_opened_object_summary");
        tr.append_u64s(
            b"neo.fold.next/nightstream/rv64im/phase0_opened_object_summary/meta",
            &[self.schema.tag()],
        );
        tr.append_message(
            b"neo.fold.next/nightstream/rv64im/phase0_opened_object_summary/opened_object_digest",
            &self.opened_object.digest,
        );
        tr.append_message(
            b"neo.fold.next/nightstream/rv64im/phase0_opened_object_summary/pp_seed_digest",
            &self.commitment_context.pp_seed_digest,
        );
        tr.append_message(
            b"neo.fold.next/nightstream/rv64im/phase0_opened_object_summary/module_shape_digest",
            &self.commitment_context.module_shape_digest,
        );
        tr.digest32()
    }
}

impl Rv64imPhase0OpenedObjectBundle {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/nightstream/rv64im/phase0_opened_object_bundle");
        tr.append_u64s(
            b"neo.fold.next/nightstream/rv64im/phase0_opened_object_bundle/count",
            &[self.objects.len() as u64],
        );
        for object in &self.objects {
            tr.append_message(
                b"neo.fold.next/nightstream/rv64im/phase0_opened_object_bundle/object_digest",
                &object.digest,
            );
        }
        tr.digest32()
    }

    fn summary_for_schema(
        &self,
        schema: FamilyEvalSchemaId,
    ) -> Result<&Rv64imPhase0OpenedObjectSummary, SimpleKernelError> {
        self.objects
            .iter()
            .find(|object| object.schema == schema)
            .ok_or_else(|| {
                SimpleKernelError::Bridge(format!(
                    "RV64IM side-eval-claim relation is missing the Phase 0 opened object for {:?}",
                    schema
                ))
            })
    }
}

impl Rv64imPhase0StageProofBindingDigests {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/nightstream/rv64im/phase0_stage_proof_bindings");
        tr.append_message(
            b"neo.fold.next/nightstream/rv64im/phase0_stage_proof_bindings/stage1",
            &self.stage1_proof_digest,
        );
        tr.append_message(
            b"neo.fold.next/nightstream/rv64im/phase0_stage_proof_bindings/stage2",
            &self.stage2_proof_digest,
        );
        tr.append_message(
            b"neo.fold.next/nightstream/rv64im/phase0_stage_proof_bindings/stage3",
            &self.stage3_proof_digest,
        );
        tr.digest32()
    }

    fn digest_for_schema(&self, schema: FamilyEvalSchemaId) -> [u8; 32] {
        match schema {
            FamilyEvalSchemaId::Stage1Rows => self.stage1_proof_digest,
            FamilyEvalSchemaId::Stage2RegisterReads
            | FamilyEvalSchemaId::Stage2RegisterWrites
            | FamilyEvalSchemaId::Stage2RamEvents
            | FamilyEvalSchemaId::Stage2TwistLinks => self.stage2_proof_digest,
            FamilyEvalSchemaId::Stage3Continuity => self.stage3_proof_digest,
        }
    }
}

impl Rv64imSideEvalClaimArtifact {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/nightstream/rv64im/side_eval_claim_artifact");
        tr.append_message(
            b"neo.fold.next/nightstream/rv64im/side_eval_claim_artifact/statement_digest",
            &self.statement_digest,
        );
        tr.append_message(
            b"neo.fold.next/nightstream/rv64im/side_eval_claim_artifact/phase0_opened_objects_digest",
            &self.phase0_opened_objects.digest,
        );
        tr.append_message(
            b"neo.fold.next/nightstream/rv64im/side_eval_claim_artifact/phase0_stage_proof_bindings_digest",
            &self.phase0_stage_proof_bindings.digest,
        );
        tr.append_message(
            b"neo.fold.next/nightstream/rv64im/side_eval_claim_artifact/eval_claim_bundle_digest",
            &self.eval_claim_bundle.digest,
        );
        tr.digest32()
    }
}

fn rv64im_side_eval_claim_relation_statement_digest_from_surfaces(
    public_statement: &Rv64imProofStatement,
    side_bundle: &Rv64imSideProofBundle,
    phase0_opened_objects: &Rv64imPhase0OpenedObjectBundle,
    phase0_stage_proof_bindings: &Rv64imPhase0StageProofBindingDigests,
    eval_claim_bundle: &Rv64imEvalClaimBundle,
) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/nightstream/rv64im/side_eval_claim_relation");
    tr.append_message(
        b"neo.fold.next/nightstream/rv64im/side_eval_claim_relation/public_statement_digest",
        &public_statement.digest,
    );
    tr.append_message(
        b"neo.fold.next/nightstream/rv64im/side_eval_claim_relation/side_bundle_digest",
        &side_bundle.digest,
    );
    tr.append_message(
        b"neo.fold.next/nightstream/rv64im/side_eval_claim_relation/phase0_opened_objects_digest",
        &phase0_opened_objects.digest,
    );
    tr.append_message(
        b"neo.fold.next/nightstream/rv64im/side_eval_claim_relation/phase0_stage_proof_bindings_digest",
        &phase0_stage_proof_bindings.digest,
    );
    tr.append_message(
        b"neo.fold.next/nightstream/rv64im/side_eval_claim_relation/eval_claim_bundle_digest",
        &eval_claim_bundle.digest,
    );
    tr.digest32()
}

pub fn rv64im_side_eval_claim_relation_statement_digest(statement: &Rv64imSideEvalClaimRelationStatement) -> [u8; 32] {
    rv64im_side_eval_claim_relation_statement_digest_from_surfaces(
        &statement.public_statement,
        &statement.side_bundle,
        &statement.phase0_opened_objects,
        &statement.phase0_stage_proof_bindings,
        &statement.eval_claim_bundle,
    )
}

pub fn build_rv64im_phase0_opened_object_bundle_from_claim_witnesses(
    claim_witnesses: &[FamilyEvalClaimWitness],
) -> Result<Rv64imPhase0OpenedObjectBundle, SimpleKernelError> {
    let mut by_schema = BTreeMap::<FamilyEvalSchemaId, (&OpenedAjtaiObjectId, CommitmentContextId)>::new();
    for claim_witness in claim_witnesses {
        let schema = claim_witness.claim.payload.schema;
        let opened_object = &claim_witness.claim.opened_object;
        let commitment_context = claim_witness.claim.commitment_context;
        if let Some((expected_object, expected_context)) = by_schema.get(&schema) {
            if *expected_object != opened_object || *expected_context != commitment_context {
                return Err(SimpleKernelError::Bridge(format!(
                    "RV64IM side-eval-claim relation found inconsistent opened-object identities for {:?}",
                    schema
                )));
            }
            continue;
        }
        by_schema.insert(schema, (opened_object, commitment_context));
    }

    let mut objects = Vec::new();
    for schema in phase0_family_order() {
        let (opened_object, commitment_context) = by_schema.get(&schema).copied().ok_or_else(|| {
            SimpleKernelError::Bridge(format!(
                "RV64IM side-eval-claim relation is missing witnesses for {:?}",
                schema
            ))
        })?;
        let mut summary = Rv64imPhase0OpenedObjectSummary {
            schema,
            opened_object: opened_object.clone(),
            commitment_context,
            digest: [0; 32],
        };
        summary.digest = summary.expected_digest();
        objects.push(summary);
    }
    let mut bundle = Rv64imPhase0OpenedObjectBundle {
        objects,
        digest: [0; 32],
    };
    bundle.digest = bundle.expected_digest();
    Ok(bundle)
}

fn validate_rv64im_side_eval_claim_relation_inputs(
    public_statement: &Rv64imProofStatement,
    side_bundle: &Rv64imSideProofBundle,
    phase0_opened_objects: &Rv64imPhase0OpenedObjectBundle,
    phase0_stage_proof_bindings: &Rv64imPhase0StageProofBindingDigests,
    eval_claim_bundle: &Rv64imEvalClaimBundle,
) -> Result<(), SimpleKernelError> {
    if public_statement.digest != public_statement.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-eval-claim relation public statement digest mismatch".into(),
        ));
    }
    if side_bundle.digest != side_bundle.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-eval-claim relation side-proof bundle digest mismatch".into(),
        ));
    }
    if phase0_opened_objects.digest != phase0_opened_objects.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-eval-claim relation Phase 0 opened-object bundle digest mismatch".into(),
        ));
    }
    if phase0_stage_proof_bindings.digest != phase0_stage_proof_bindings.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-eval-claim relation Phase 0 stage-proof binding digest mismatch".into(),
        ));
    }
    if eval_claim_bundle.digest != eval_claim_bundle.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-eval-claim relation eval-claim bundle digest mismatch".into(),
        ));
    }
    Ok(())
}

pub fn build_rv64im_phase0_stage_proof_binding_digests_from_accepted_artifact(
    artifact: &Rv64imAcceptedProofArtifact,
) -> Rv64imPhase0StageProofBindingDigests {
    let mut digests = Rv64imPhase0StageProofBindingDigests {
        stage1_proof_digest: artifact.stage1.digest,
        stage2_proof_digest: artifact.stage2.digest,
        stage3_proof_digest: artifact.stage3.digest,
        digest: [0; 32],
    };
    digests.digest = digests.expected_digest();
    digests
}

pub fn build_rv64im_side_eval_claim_relation_statement(
    public_statement: &Rv64imProofStatement,
    side_bundle: &Rv64imSideProofBundle,
    phase0_opened_objects: &Rv64imPhase0OpenedObjectBundle,
    phase0_stage_proof_bindings: &Rv64imPhase0StageProofBindingDigests,
    eval_claim_bundle: &Rv64imEvalClaimBundle,
) -> Result<Rv64imSideEvalClaimRelationStatement, SimpleKernelError> {
    validate_rv64im_side_eval_claim_relation_inputs(
        public_statement,
        side_bundle,
        phase0_opened_objects,
        phase0_stage_proof_bindings,
        eval_claim_bundle,
    )?;
    Ok(Rv64imSideEvalClaimRelationStatement {
        public_statement: public_statement.clone(),
        side_bundle: side_bundle.clone(),
        phase0_opened_objects: phase0_opened_objects.clone(),
        phase0_stage_proof_bindings: phase0_stage_proof_bindings.clone(),
        eval_claim_bundle: eval_claim_bundle.clone(),
    })
}

pub fn build_rv64im_side_eval_claim_relation_witness_from_accepted_artifact(
    artifact: &Rv64imAcceptedProofArtifact,
) -> Result<Rv64imSideEvalClaimRelationWitness, SimpleKernelError> {
    Ok(Rv64imSideEvalClaimRelationWitness {
        claim_witnesses: build_rv64im_eval_claim_witnesses_from_accepted_artifact(artifact)?,
    })
}

pub fn build_rv64im_side_eval_claim_relation_from_accepted_artifact(
    artifact: &Rv64imAcceptedProofArtifact,
) -> Result<(Rv64imSideEvalClaimRelationStatement, Rv64imSideEvalClaimRelationWitness), SimpleKernelError> {
    let side_bundle = build_rv64im_side_proof_bundle_from_accepted_artifact(artifact)?;
    let witness = build_rv64im_side_eval_claim_relation_witness_from_accepted_artifact(artifact)?;
    let phase0_opened_objects =
        build_rv64im_phase0_opened_object_bundle_from_claim_witnesses(&witness.claim_witnesses)?;
    let phase0_stage_proof_bindings = build_rv64im_phase0_stage_proof_binding_digests_from_accepted_artifact(artifact);
    let eval_claim_bundle = build_rv64im_eval_claim_bundle_from_claim_witnesses(&witness.claim_witnesses)?;
    let statement = build_rv64im_side_eval_claim_relation_statement(
        &artifact.statement,
        &side_bundle,
        &phase0_opened_objects,
        &phase0_stage_proof_bindings,
        &eval_claim_bundle,
    )?;
    Ok((statement, witness))
}

pub fn verify_rv64im_side_eval_claim_relation(
    statement: &Rv64imSideEvalClaimRelationStatement,
    witness: &Rv64imSideEvalClaimRelationWitness,
) -> Result<(), SimpleKernelError> {
    verify_rv64im_side_eval_claim_relation_surfaces(statement, &witness.claim_witnesses)
}

fn verify_rv64im_side_eval_claim_relation_surfaces(
    statement: &Rv64imSideEvalClaimRelationStatement,
    claim_witnesses: &[FamilyEvalClaimWitness],
) -> Result<(), SimpleKernelError> {
    if statement.public_statement.digest != statement.public_statement.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-eval-claim relation public statement digest mismatch".into(),
        ));
    }
    if statement.side_bundle.digest != statement.side_bundle.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-eval-claim relation side-proof bundle digest mismatch".into(),
        ));
    }
    if statement.phase0_opened_objects.digest != statement.phase0_opened_objects.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-eval-claim relation Phase 0 opened-object bundle digest mismatch".into(),
        ));
    }
    if statement.phase0_stage_proof_bindings.digest != statement.phase0_stage_proof_bindings.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-eval-claim relation Phase 0 stage-proof binding digest mismatch".into(),
        ));
    }
    if statement.eval_claim_bundle.digest != statement.eval_claim_bundle.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-eval-claim relation eval-claim bundle digest mismatch".into(),
        ));
    }

    let expected_opened_objects = build_rv64im_phase0_opened_object_bundle_from_claim_witnesses(claim_witnesses)?;
    if expected_opened_objects != statement.phase0_opened_objects {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-eval-claim relation opened-object summaries do not match the carried Phase 0 bundle".into(),
        ));
    }

    let expected_claim_bundle = build_rv64im_eval_claim_bundle_from_claim_witnesses(claim_witnesses)?;
    if expected_claim_bundle != statement.eval_claim_bundle {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-eval-claim relation claim witnesses do not match the carried eval-claim bundle".into(),
        ));
    }

    verify_phase0_claim_bindings(statement, claim_witnesses)?;
    verify_phase0_claim_coverage(claim_witnesses)?;
    Ok(())
}

pub fn build_rv64im_side_eval_claim_artifact(
    statement: &Rv64imSideEvalClaimRelationStatement,
    witness: &Rv64imSideEvalClaimRelationWitness,
) -> Result<Rv64imSideEvalClaimArtifact, SimpleKernelError> {
    verify_rv64im_side_eval_claim_relation(statement, witness)?;
    let mut artifact = Rv64imSideEvalClaimArtifact {
        statement_digest: rv64im_side_eval_claim_relation_statement_digest(statement),
        phase0_opened_objects: statement.phase0_opened_objects.clone(),
        phase0_stage_proof_bindings: statement.phase0_stage_proof_bindings.clone(),
        eval_claim_bundle: statement.eval_claim_bundle.clone(),
        digest: [0; 32],
    };
    artifact.digest = artifact.expected_digest();
    Ok(artifact)
}

pub fn build_rv64im_side_eval_claim_artifact_from_accepted_artifact(
    artifact: &Rv64imAcceptedProofArtifact,
) -> Result<Rv64imSideEvalClaimArtifact, SimpleKernelError> {
    let (statement, witness) = build_rv64im_side_eval_claim_relation_from_accepted_artifact(artifact)?;
    build_rv64im_side_eval_claim_artifact(&statement, &witness)
}

pub fn build_rv64im_side_eval_claim_artifact_from_accepted_artifact_and_side_bundle(
    public_statement: &Rv64imProofStatement,
    side_bundle: &Rv64imSideProofBundle,
    artifact: &Rv64imAcceptedProofArtifact,
) -> Result<Rv64imSideEvalClaimArtifact, SimpleKernelError> {
    let witness = build_rv64im_side_eval_claim_relation_witness_from_accepted_artifact(artifact)?;
    let phase0_stage_proof_bindings = build_rv64im_phase0_stage_proof_binding_digests_from_accepted_artifact(artifact);
    build_rv64im_side_eval_claim_artifact_from_claim_witnesses_and_side_bundle(
        public_statement,
        side_bundle,
        &phase0_stage_proof_bindings,
        &witness.claim_witnesses,
    )
}

pub(super) fn build_rv64im_side_eval_claim_artifact_from_claim_witnesses_and_side_bundle(
    public_statement: &Rv64imProofStatement,
    side_bundle: &Rv64imSideProofBundle,
    phase0_stage_proof_bindings: &Rv64imPhase0StageProofBindingDigests,
    claim_witnesses: &[FamilyEvalClaimWitness],
) -> Result<Rv64imSideEvalClaimArtifact, SimpleKernelError> {
    let phase0_opened_objects = build_rv64im_phase0_opened_object_bundle_from_claim_witnesses(claim_witnesses)?;
    let eval_claim_bundle = build_rv64im_eval_claim_bundle_from_claim_witnesses(claim_witnesses)?;
    validate_rv64im_side_eval_claim_relation_inputs(
        public_statement,
        side_bundle,
        &phase0_opened_objects,
        phase0_stage_proof_bindings,
        &eval_claim_bundle,
    )?;
    build_rv64im_side_eval_claim_artifact_from_trusted_surfaces(
        public_statement,
        side_bundle,
        phase0_opened_objects,
        phase0_stage_proof_bindings,
        eval_claim_bundle,
    )
}

pub(super) fn build_rv64im_side_eval_claim_artifact_from_claim_witnesses_and_trusted_side_bundle(
    public_statement: &Rv64imProofStatement,
    side_bundle: &Rv64imSideProofBundle,
    phase0_stage_proof_bindings: &Rv64imPhase0StageProofBindingDigests,
    claim_witnesses: &[FamilyEvalClaimWitness],
) -> Result<Rv64imSideEvalClaimArtifact, SimpleKernelError> {
    if phase0_stage_proof_bindings.digest != phase0_stage_proof_bindings.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-eval-claim artifact Phase 0 stage-proof binding digest mismatch".into(),
        ));
    }

    let phase0_opened_objects = build_rv64im_phase0_opened_object_bundle_from_claim_witnesses(claim_witnesses)?;
    let eval_claim_bundle = build_rv64im_eval_claim_bundle_from_claim_witnesses_trusted_local(claim_witnesses)?;
    build_rv64im_side_eval_claim_artifact_from_trusted_surfaces(
        public_statement,
        side_bundle,
        phase0_opened_objects,
        phase0_stage_proof_bindings,
        eval_claim_bundle,
    )
}

fn build_rv64im_side_eval_claim_artifact_from_trusted_surfaces(
    public_statement: &Rv64imProofStatement,
    side_bundle: &Rv64imSideProofBundle,
    phase0_opened_objects: Rv64imPhase0OpenedObjectBundle,
    phase0_stage_proof_bindings: &Rv64imPhase0StageProofBindingDigests,
    eval_claim_bundle: Rv64imEvalClaimBundle,
) -> Result<Rv64imSideEvalClaimArtifact, SimpleKernelError> {
    let mut artifact = Rv64imSideEvalClaimArtifact {
        statement_digest: rv64im_side_eval_claim_relation_statement_digest_from_surfaces(
            public_statement,
            side_bundle,
            &phase0_opened_objects,
            phase0_stage_proof_bindings,
            &eval_claim_bundle,
        ),
        phase0_opened_objects,
        phase0_stage_proof_bindings: phase0_stage_proof_bindings.clone(),
        eval_claim_bundle,
        digest: [0; 32],
    };
    artifact.digest = artifact.expected_digest();
    Ok(artifact)
}

pub fn build_rv64im_side_eval_claim_relation_statement_from_artifact(
    public_statement: &Rv64imProofStatement,
    side_bundle: &Rv64imSideProofBundle,
    artifact: &Rv64imSideEvalClaimArtifact,
) -> Result<Rv64imSideEvalClaimRelationStatement, SimpleKernelError> {
    if artifact.digest != artifact.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-eval-claim artifact digest mismatch".into(),
        ));
    }
    build_rv64im_side_eval_claim_relation_statement(
        public_statement,
        side_bundle,
        &artifact.phase0_opened_objects,
        &artifact.phase0_stage_proof_bindings,
        &artifact.eval_claim_bundle,
    )
}

pub fn verify_rv64im_side_eval_claim_artifact(
    public_statement: &Rv64imProofStatement,
    side_bundle: &Rv64imSideProofBundle,
    artifact: &Rv64imSideEvalClaimArtifact,
) -> Result<(), SimpleKernelError> {
    let statement =
        build_rv64im_side_eval_claim_relation_statement_from_artifact(public_statement, side_bundle, artifact)?;
    if artifact.statement_digest != rv64im_side_eval_claim_relation_statement_digest(&statement) {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-eval-claim artifact statement digest does not match the carried relation statement".into(),
        ));
    }
    verify_phase0_claim_bundle_bindings(&statement)?;
    verify_phase0_claim_bundle_coverage(&statement)?;
    Ok(())
}

fn verify_phase0_claim_bundle_bindings(
    statement: &Rv64imSideEvalClaimRelationStatement,
) -> Result<(), SimpleKernelError> {
    for claim in &statement.eval_claim_bundle.claims {
        verify_phase0_claim_surface(statement, claim)?;
    }
    Ok(())
}

fn verify_phase0_claim_bundle_coverage(
    statement: &Rv64imSideEvalClaimRelationStatement,
) -> Result<(), SimpleKernelError> {
    for schema in phase0_family_order() {
        let expected_slots = expected_slots_for_schema(schema);
        let actual_slots = statement
            .eval_claim_bundle
            .claims
            .iter()
            .filter(|claim| claim.payload.schema == schema)
            .map(|claim| claim.id.slot)
            .collect::<Vec<_>>();
        if actual_slots != expected_slots {
            return Err(SimpleKernelError::Bridge(format!(
                "RV64IM side-eval-claim artifact {:?} slot coverage mismatch: expected {:?}, got {:?}",
                schema, expected_slots, actual_slots
            )));
        }
    }
    Ok(())
}

fn verify_phase0_claim_bindings(
    statement: &Rv64imSideEvalClaimRelationStatement,
    claim_witnesses: &[FamilyEvalClaimWitness],
) -> Result<(), SimpleKernelError> {
    for claim_witness in claim_witnesses {
        verify_phase0_claim_surface(statement, &claim_witness.claim)?;
    }
    Ok(())
}

fn verify_phase0_claim_surface(
    statement: &Rv64imSideEvalClaimRelationStatement,
    claim: &FamilyEvalClaim,
) -> Result<(), SimpleKernelError> {
    let summary = statement
        .phase0_opened_objects
        .summary_for_schema(claim.payload.schema)?;
    if claim.opened_object != summary.opened_object || claim.commitment_context != summary.commitment_context {
        return Err(SimpleKernelError::Bridge(format!(
            "RV64IM side-eval-claim relation {:?} claim does not match the carried opened-object summary",
            claim.payload.schema
        )));
    }

    let expected_binding_digest = phase0_binding_digest(
        &summary.opened_object,
        claim.payload.schema,
        claim.id.slot,
        family_binding_anchor_digest(&statement.side_bundle, claim.payload.schema),
        statement
            .phase0_stage_proof_bindings
            .digest_for_schema(claim.payload.schema),
    );
    if expected_binding_digest != claim.binding_digest {
        return Err(SimpleKernelError::Bridge(format!(
            "RV64IM side-eval-claim relation {:?} binding digest does not match the carried theorem surfaces",
            claim.payload.schema
        )));
    }

    let expected_point = derive_phase0_point(
        &summary.opened_object,
        &summary.commitment_context,
        claim.payload.schema,
        claim.id.slot,
        claim.binding_digest,
    );
    if expected_point != claim.point {
        return Err(SimpleKernelError::Bridge(format!(
            "RV64IM side-eval-claim relation {:?} point does not match the carried Phase 0 derivation",
            claim.payload.schema
        )));
    }

    Ok(())
}

fn verify_phase0_claim_coverage(claim_witnesses: &[FamilyEvalClaimWitness]) -> Result<(), SimpleKernelError> {
    for schema in phase0_family_order() {
        let expected_slots = expected_slots_for_schema(schema);
        let actual_slots = claim_witnesses
            .iter()
            .filter(|claim| claim.claim.payload.schema == schema)
            .map(|claim| claim.claim.id.slot)
            .collect::<Vec<_>>();
        if actual_slots != expected_slots {
            return Err(SimpleKernelError::Bridge(format!(
                "RV64IM side-eval-claim relation {:?} slot coverage mismatch: expected {:?}, got {:?}",
                schema, expected_slots, actual_slots
            )));
        }
    }
    Ok(())
}

fn phase0_family_order() -> [FamilyEvalSchemaId; 6] {
    [
        FamilyEvalSchemaId::Stage1Rows,
        FamilyEvalSchemaId::Stage2RegisterReads,
        FamilyEvalSchemaId::Stage2RegisterWrites,
        FamilyEvalSchemaId::Stage2RamEvents,
        FamilyEvalSchemaId::Stage2TwistLinks,
        FamilyEvalSchemaId::Stage3Continuity,
    ]
}

fn expected_slots_for_schema(schema: FamilyEvalSchemaId) -> Vec<u32> {
    match schema {
        FamilyEvalSchemaId::Stage1Rows => vec![0, 1, 2, 3],
        FamilyEvalSchemaId::Stage2RegisterReads
        | FamilyEvalSchemaId::Stage2RegisterWrites
        | FamilyEvalSchemaId::Stage2RamEvents
        | FamilyEvalSchemaId::Stage2TwistLinks
        | FamilyEvalSchemaId::Stage3Continuity => vec![0],
    }
}

fn family_binding_anchor_digest(side_bundle: &Rv64imSideProofBundle, schema: FamilyEvalSchemaId) -> [u8; 32] {
    match schema {
        FamilyEvalSchemaId::Stage1Rows => side_bundle.stage1.rows_digest,
        FamilyEvalSchemaId::Stage2RegisterReads => side_bundle.stage2.claim.register_reads_family_digest,
        FamilyEvalSchemaId::Stage2RegisterWrites => side_bundle.stage2.claim.register_writes_family_digest,
        FamilyEvalSchemaId::Stage2RamEvents => side_bundle.stage2.claim.ram_events_family_digest,
        FamilyEvalSchemaId::Stage2TwistLinks => side_bundle.stage2.claim.twist_links_family_digest,
        FamilyEvalSchemaId::Stage3Continuity => side_bundle.stage3.claim.continuity_family_digest,
    }
}
