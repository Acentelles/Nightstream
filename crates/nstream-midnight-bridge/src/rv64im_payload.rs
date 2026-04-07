use super::*;

#[derive(Clone, Debug, PartialEq, Eq)]
struct DecodedRv64imMainResidualProofFields {
    public_statement_digest: [u8; 32],
    folded_statement_digest: [u8; 32],
    final_proof_digest: [u8; 32],
    kernel_export_proof_digest: [u8; 32],
    chunk_transition_digests: Vec<[u8; 32]>,
}

fn encode_rv64im_main_residual_proof_fields(out: &mut Vec<BridgeFieldWord>, proof: &Rv64imMainResidualProof) {
    encode_digest32_field_words(out, proof.public_statement_digest);
    encode_digest32_field_words(out, proof.decider_relation.relation_digest);
    encode_digest32_field_words(out, proof.decider_relation.final_proof_digest);
    let kernel_export_proof_digest = proof
        .decider_relation
        .base_component_digests
        .first()
        .copied()
        .unwrap_or([0; 32]);
    encode_digest32_field_words(out, kernel_export_proof_digest);
    out.push(proof.decider_relation.chunk_transition_bindings.len() as BridgeFieldWord);
    for binding in &proof.decider_relation.chunk_transition_bindings {
        encode_digest32_field_words(out, binding.transition_witness_digest);
    }
}

fn decode_rv64im_main_residual_proof_fields(
    words: &[BridgeFieldWord],
    cursor: &mut usize,
) -> Result<DecodedRv64imMainResidualProofFields, Rv64imBridgeError> {
    let public_statement_digest = decode_digest32_field_words(words, cursor, "main residual public_statement_digest")?;
    let folded_statement_digest = decode_digest32_field_words(words, cursor, "main residual folded_statement_digest")?;
    let final_proof_digest = decode_digest32_field_words(words, cursor, "main residual final_proof_digest")?;
    let kernel_export_proof_digest =
        decode_digest32_field_words(words, cursor, "main residual kernel_export_proof_digest")?;
    let transition_count = usize_from_word(
        take_word(words, cursor, "main residual chunk_transition_count")?,
        "main residual chunk_transition_count",
    )?;
    let mut chunk_transition_digests = Vec::with_capacity(transition_count);
    for _ in 0..transition_count {
        chunk_transition_digests.push(decode_digest32_field_words(
            words,
            cursor,
            "main residual chunk_transition_digest",
        )?);
    }
    Ok(DecodedRv64imMainResidualProofFields {
        public_statement_digest,
        folded_statement_digest,
        final_proof_digest,
        kernel_export_proof_digest,
        chunk_transition_digests,
    })
}

pub(super) fn encode_rv64im_nightstream_proof_fields(
    out: &mut Vec<BridgeFieldWord>,
    proof: &Rv64imNightstreamProof,
) -> Result<(), Rv64imBridgeError> {
    encode_digest32_field_words(out, proof.main_decider_proof.decider_target_digest);
    encode_rv64im_main_residual_proof_fields(out, &proof.main_residual_proof);
    encode_digest32_field_words(out, proof.side_proof_artifact.digest);
    encode_digest32_field_words(out, proof.opening_artifact.digest);
    encode_digest32_field_words(out, proof.linkage_artifact.digest);
    let proof_bytes = bincode::serialize(proof).map_err(|err| Rv64imBridgeError::WitnessEncode(err.to_string()))?;
    out.extend(encode_bytes_field_words(&proof_bytes));
    Ok(())
}

pub(super) fn decode_rv64im_nightstream_proof_fields(
    words: &[BridgeFieldWord],
    cursor: &mut usize,
) -> Result<Rv64imNightstreamProof, Rv64imBridgeError> {
    let main_decider_target_digest = decode_digest32_field_words(words, cursor, "main decider decider_target_digest")?;
    let main_residual_proof = decode_rv64im_main_residual_proof_fields(words, cursor)?;
    let side_proof_artifact_digest = decode_digest32_field_words(words, cursor, "side proof artifact digest")?;
    let opening_artifact_digest = decode_digest32_field_words(words, cursor, "opening artifact digest")?;
    let linkage_artifact_digest = decode_digest32_field_words(words, cursor, "linkage artifact digest")?;
    let proof_bytes = decode_bytes_field_words(words, cursor, "nightstream proof bytes")?;
    let proof = bincode::deserialize::<Rv64imNightstreamProof>(&proof_bytes)
        .map_err(|err| Rv64imBridgeError::WitnessDecode(err.to_string()))?;
    if proof.main_decider_proof.decider_target_digest != main_decider_target_digest {
        return Err(Rv64imBridgeError::WitnessDecode(
            "nightstream proof bytes do not match the carried main decider digest".into(),
        ));
    }
    if proof.main_residual_proof.public_statement_digest != main_residual_proof.public_statement_digest {
        return Err(Rv64imBridgeError::WitnessDecode(
            "nightstream proof bytes do not match the carried residual public statement digest".into(),
        ));
    }
    if proof.main_residual_proof.decider_relation.relation_digest != main_residual_proof.folded_statement_digest {
        return Err(Rv64imBridgeError::WitnessDecode(
            "nightstream proof bytes do not match the carried residual folded statement digest".into(),
        ));
    }
    if proof
        .main_residual_proof
        .decider_relation
        .final_proof_digest
        != main_residual_proof.final_proof_digest
    {
        return Err(Rv64imBridgeError::WitnessDecode(
            "nightstream proof bytes do not match the carried residual final proof digest".into(),
        ));
    }
    let decoded_kernel_export_digest = proof
        .main_residual_proof
        .decider_relation
        .base_component_digests
        .first()
        .copied()
        .ok_or_else(|| {
            Rv64imBridgeError::WitnessDecode(
                "nightstream proof bytes are missing the kernel export component digest".into(),
            )
        })?;
    if decoded_kernel_export_digest != main_residual_proof.kernel_export_proof_digest {
        return Err(Rv64imBridgeError::WitnessDecode(
            "nightstream proof bytes do not match the carried residual kernel export digest".into(),
        ));
    }
    let decoded_transition_digests: Vec<[u8; 32]> = proof
        .main_residual_proof
        .decider_relation
        .chunk_transition_bindings
        .iter()
        .map(|binding| binding.transition_witness_digest)
        .collect();
    if decoded_transition_digests != main_residual_proof.chunk_transition_digests {
        return Err(Rv64imBridgeError::WitnessDecode(
            "nightstream proof bytes do not match the carried residual transition digests".into(),
        ));
    }
    if proof.side_proof_artifact.digest != side_proof_artifact_digest {
        return Err(Rv64imBridgeError::WitnessDecode(
            "nightstream proof bytes do not match the carried side-proof digest".into(),
        ));
    }
    if proof.opening_artifact.digest != opening_artifact_digest {
        return Err(Rv64imBridgeError::WitnessDecode(
            "nightstream proof bytes do not match the carried opening-artifact digest".into(),
        ));
    }
    if proof.linkage_artifact.digest != linkage_artifact_digest {
        return Err(Rv64imBridgeError::WitnessDecode(
            "nightstream proof bytes do not match the carried linkage-artifact digest".into(),
        ));
    }
    Ok(proof)
}
