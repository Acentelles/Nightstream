use nstream_midnight_bridge::rv64im::{
    build_rv64im_contract_operation_versioned_verifier_key,
    build_rv64im_contract_operation_versioned_verifier_key_from_bytes, build_rv64im_contract_verifier_key_insert,
    build_rv64im_contract_verifier_key_insert_from_bytes, build_rv64im_contract_verifier_key_insert_maintain_action,
    build_rv64im_contract_verifier_key_insert_maintain_action_submit_request,
    build_rv64im_contract_verifier_key_insert_signed_update,
    build_rv64im_contract_verifier_key_insert_signed_update_submit_request,
    build_rv64im_contract_verifier_key_insert_update, build_rv64im_contract_verifier_key_insert_update_from_bytes,
    build_rv64im_entry_point, encode_rv64im_contract_address, encode_rv64im_contract_operation_versioned_verifier_key,
    encode_rv64im_contract_verifier_key_insert, encode_rv64im_contract_verifier_key_insert_maintain_action_bytes,
    encode_rv64im_contract_verifier_key_insert_signed_update,
    encode_rv64im_contract_verifier_key_insert_signed_update_bytes, encode_rv64im_contract_verifier_key_insert_update,
    encode_rv64im_entry_point, execute_rv64im_contract_action_submit_request,
    execute_rv64im_contract_verifier_key_insert_maintain_action_submit,
    execute_rv64im_contract_verifier_key_insert_signed_update_submit, parse_rv64im_contract_address,
    parse_rv64im_contract_operation_versioned_verifier_key, parse_rv64im_contract_verifier_key_insert,
    parse_rv64im_contract_verifier_key_insert_maintain_action_bytes,
    parse_rv64im_contract_verifier_key_insert_signed_update,
    parse_rv64im_contract_verifier_key_insert_signed_update_bytes, parse_rv64im_contract_verifier_key_insert_update,
    parse_rv64im_entry_point, parse_rv64im_verifier_key, Rv64imBridgeError, Rv64imContractActionSubmitProvider,
    Rv64imContractActionSubmitRequest, Rv64imContractAddress, Rv64imContractOperationVersion,
    Rv64imContractOperationVersionedVerifierKey, Rv64imContractSignature,
};
use serialize::{tagged_serialize, Deserializable, Serializable};
use transient_crypto::proofs::VerifierKey;

fn sample_verifier_key() -> VerifierKey {
    let mut bytes = Vec::new();
    Serializable::serialize(&vec![7u8, 8, 9, 10], &mut bytes).expect("serialize verifier key bytes");
    VerifierKey::deserialize(&mut &bytes[..], 0).expect("deserialize verifier key")
}

fn sample_contract_address() -> Rv64imContractAddress {
    Rv64imContractAddress::default()
}

fn sample_signature() -> Rv64imContractSignature {
    Rv64imContractSignature::default()
}

struct MockContractActionSubmitProvider {
    expected_request_body: Vec<u8>,
    response: Result<Vec<u8>, String>,
}

impl Rv64imContractActionSubmitProvider for MockContractActionSubmitProvider {
    fn execute(&self, request: &Rv64imContractActionSubmitRequest) -> Result<Vec<u8>, String> {
        assert_eq!(request.body(), self.expected_request_body.as_slice());
        self.response.clone()
    }
}

fn decode_hex(value: &str) -> Vec<u8> {
    assert_eq!(value.len() % 2, 0, "hex string must have even length");
    value
        .as_bytes()
        .chunks_exact(2)
        .map(|pair| {
            let hi = (pair[0] as char).to_digit(16).expect("valid hex digit");
            let lo = (pair[1] as char).to_digit(16).expect("valid hex digit");
            ((hi << 4) | lo) as u8
        })
        .collect()
}

#[test]
fn rv64im_contract_verifier_key_round_trips_through_local_wrapper() {
    let verifier_key = sample_verifier_key();
    let wrapped = build_rv64im_contract_operation_versioned_verifier_key(verifier_key.clone());

    let encoded = encode_rv64im_contract_operation_versioned_verifier_key(&wrapped)
        .expect("encode contract verifier key wrapper");
    let decoded =
        parse_rv64im_contract_operation_versioned_verifier_key(&encoded).expect("decode contract verifier key wrapper");

    assert_eq!(decoded, wrapped);
    assert_eq!(decoded.verifier_key(), &verifier_key);
    assert_eq!(decoded.version(), Rv64imContractOperationVersion::V3);
}

#[test]
fn rv64im_contract_verifier_key_builds_from_tagged_verifier_key_bytes() {
    let verifier_key = sample_verifier_key();
    let mut verifier_key_bytes = Vec::new();
    tagged_serialize(&verifier_key, &mut verifier_key_bytes).expect("serialize verifier key");

    let parsed_verifier_key = parse_rv64im_verifier_key(&verifier_key_bytes).expect("parse tagged verifier key");
    assert_eq!(parsed_verifier_key, verifier_key);

    let wrapped = build_rv64im_contract_operation_versioned_verifier_key_from_bytes(&verifier_key_bytes)
        .expect("build contract verifier key wrapper");
    assert_eq!(wrapped, Rv64imContractOperationVersionedVerifierKey::V3(verifier_key));
}

#[test]
fn rv64im_contract_verifier_key_rejects_raw_verifier_key_bytes() {
    let verifier_key = sample_verifier_key();
    let mut verifier_key_bytes = Vec::new();
    tagged_serialize(&verifier_key, &mut verifier_key_bytes).expect("serialize verifier key");

    let err = parse_rv64im_contract_operation_versioned_verifier_key(&verifier_key_bytes)
        .expect_err("raw verifier key bytes must not parse as versioned contract wrapper");
    assert!(format!("{err}").contains("artifact decode"));
}

#[test]
fn rv64im_contract_entry_point_round_trips_through_local_wrapper() {
    let entry_point = build_rv64im_entry_point(b"nightstream-rv64im".to_vec());
    let encoded = encode_rv64im_entry_point(&entry_point).expect("encode entry point");
    let decoded = parse_rv64im_entry_point(&encoded).expect("decode entry point");

    assert_eq!(decoded, entry_point);
    assert_eq!(decoded.as_bytes(), b"nightstream-rv64im");
}

#[test]
fn rv64im_contract_address_round_trips_through_tagged_helper() {
    let address = sample_contract_address();
    let encoded = encode_rv64im_contract_address(&address).expect("encode contract address");
    let decoded = parse_rv64im_contract_address(&encoded).expect("decode contract address");

    assert_eq!(decoded, address);
}

#[test]
fn rv64im_contract_verifier_key_insert_round_trips_through_local_wrapper() {
    let verifier_key = sample_verifier_key();
    let insert = build_rv64im_contract_verifier_key_insert(
        b"nightstream-rv64im".to_vec(),
        build_rv64im_contract_operation_versioned_verifier_key(verifier_key.clone()),
    );

    let encoded = encode_rv64im_contract_verifier_key_insert(&insert).expect("encode verifier key insert");
    let decoded = parse_rv64im_contract_verifier_key_insert(&encoded).expect("decode verifier key insert");

    assert_eq!(decoded, insert);
    assert_eq!(decoded.entry_point().as_bytes(), b"nightstream-rv64im");
    assert_eq!(decoded.verifier_key().verifier_key(), &verifier_key);
}

#[test]
fn rv64im_contract_verifier_key_insert_binds_entry_point_and_versioned_key() {
    let verifier_key = sample_verifier_key();
    let wrapped = build_rv64im_contract_operation_versioned_verifier_key(verifier_key.clone());
    let insert = build_rv64im_contract_verifier_key_insert(b"nightstream-rv64im".to_vec(), wrapped.clone());

    assert_eq!(insert.entry_point().as_bytes(), b"nightstream-rv64im");
    assert_eq!(insert.verifier_key(), &wrapped);
    assert_eq!(insert.verifier_key().version(), Rv64imContractOperationVersion::V3);
    assert_eq!(insert.verifier_key().verifier_key(), &verifier_key);
}

#[test]
fn rv64im_contract_verifier_key_insert_builds_from_raw_verifier_key_bytes() {
    let verifier_key = sample_verifier_key();
    let mut verifier_key_bytes = Vec::new();
    tagged_serialize(&verifier_key, &mut verifier_key_bytes).expect("serialize verifier key");

    let insert =
        build_rv64im_contract_verifier_key_insert_from_bytes(b"nightstream-rv64im".to_vec(), &verifier_key_bytes)
            .expect("build verifier key insert");

    assert_eq!(insert.entry_point().as_bytes(), b"nightstream-rv64im");
    assert_eq!(insert.verifier_key().version(), Rv64imContractOperationVersion::V3);
    assert_eq!(insert.verifier_key().verifier_key(), &verifier_key);
}

#[test]
fn rv64im_contract_verifier_key_insert_update_round_trips_through_local_wrapper() {
    let address = sample_contract_address();
    let verifier_key = sample_verifier_key();
    let update = build_rv64im_contract_verifier_key_insert_update(
        address,
        7,
        b"nightstream-rv64im".to_vec(),
        build_rv64im_contract_operation_versioned_verifier_key(verifier_key.clone()),
    );

    let encoded =
        encode_rv64im_contract_verifier_key_insert_update(&update).expect("encode verifier key insert update");
    let decoded =
        parse_rv64im_contract_verifier_key_insert_update(&encoded).expect("decode verifier key insert update");

    assert_eq!(decoded, update);
    assert_eq!(decoded.address(), &address);
    assert_eq!(decoded.counter(), 7);
    assert_eq!(decoded.insert().entry_point().as_bytes(), b"nightstream-rv64im");
    assert_eq!(decoded.insert().verifier_key().verifier_key(), &verifier_key);
}

#[test]
fn rv64im_contract_verifier_key_insert_update_builds_from_tagged_bytes() {
    let address = sample_contract_address();
    let address_bytes = encode_rv64im_contract_address(&address).expect("encode contract address");
    let verifier_key = sample_verifier_key();
    let mut verifier_key_bytes = Vec::new();
    tagged_serialize(&verifier_key, &mut verifier_key_bytes).expect("serialize verifier key");

    let update = build_rv64im_contract_verifier_key_insert_update_from_bytes(
        &address_bytes,
        9,
        b"nightstream-rv64im".to_vec(),
        &verifier_key_bytes,
    )
    .expect("build verifier key insert update");

    assert_eq!(update.address(), &address);
    assert_eq!(update.counter(), 9);
    assert_eq!(update.insert().entry_point().as_bytes(), b"nightstream-rv64im");
    assert_eq!(
        update.insert().verifier_key().version(),
        Rv64imContractOperationVersion::V3
    );
    assert_eq!(update.insert().verifier_key().verifier_key(), &verifier_key);
}

#[test]
fn rv64im_contract_verifier_key_insert_update_data_to_sign_matches_midnight() {
    let update = build_rv64im_contract_verifier_key_insert_update(
        sample_contract_address(),
        11,
        b"nightstream-rv64im".to_vec(),
        build_rv64im_contract_operation_versioned_verifier_key(sample_verifier_key()),
    );

    let local = update.data_to_sign().expect("local data_to_sign");
    let midnight = decode_hex(
        "6d69646e696768743a636f6e74726163742d7570646174653a00000000000000000000000000000000000000000000000000000000000000000c006802486e6967687473747265616d2d72763634696d02100708090a04000801040404002c",
    );

    assert_eq!(local, midnight);
}

#[test]
fn rv64im_contract_verifier_key_insert_signed_update_round_trips_through_local_wrapper() {
    let signed_update =
        build_rv64im_contract_verifier_key_insert_signed_update(build_rv64im_contract_verifier_key_insert_update(
            sample_contract_address(),
            13,
            b"nightstream-rv64im".to_vec(),
            build_rv64im_contract_operation_versioned_verifier_key(sample_verifier_key()),
        ))
        .add_signature(2, sample_signature());

    let encoded =
        encode_rv64im_contract_verifier_key_insert_signed_update(&signed_update).expect("encode signed update");
    let decoded = parse_rv64im_contract_verifier_key_insert_signed_update(&encoded).expect("decode signed update");

    assert_eq!(decoded, signed_update);
}

#[test]
fn rv64im_contract_verifier_key_insert_signed_update_sorts_signatures_canonically() {
    let signed_update =
        build_rv64im_contract_verifier_key_insert_signed_update(build_rv64im_contract_verifier_key_insert_update(
            sample_contract_address(),
            14,
            b"nightstream-rv64im".to_vec(),
            build_rv64im_contract_operation_versioned_verifier_key(sample_verifier_key()),
        ))
        .add_signature(7, sample_signature())
        .add_signature(3, sample_signature());

    let signature_indices: Vec<u32> = signed_update
        .signatures()
        .iter()
        .map(|value| value.into_inner().0)
        .collect();
    assert_eq!(signature_indices, vec![3, 7]);
}

#[test]
fn rv64im_contract_verifier_key_insert_signed_update_keeps_data_to_sign_unchanged() {
    let unsigned_update = build_rv64im_contract_verifier_key_insert_update(
        sample_contract_address(),
        15,
        b"nightstream-rv64im".to_vec(),
        build_rv64im_contract_operation_versioned_verifier_key(sample_verifier_key()),
    );
    let signed_update = build_rv64im_contract_verifier_key_insert_signed_update(unsigned_update.clone())
        .add_signature(4, sample_signature());

    assert_eq!(
        signed_update
            .data_to_sign()
            .expect("signed update data_to_sign"),
        unsigned_update
            .data_to_sign()
            .expect("unsigned update data_to_sign")
    );
}

#[test]
fn rv64im_contract_verifier_key_insert_signed_update_bytes_match_midnight() {
    let signed_update =
        build_rv64im_contract_verifier_key_insert_signed_update(build_rv64im_contract_verifier_key_insert_update(
            sample_contract_address(),
            16,
            b"nightstream-rv64im".to_vec(),
            build_rv64im_contract_operation_versioned_verifier_key(sample_verifier_key()),
        ))
        .add_signature(7, sample_signature())
        .add_signature(3, sample_signature());

    let local = signed_update
        .signed_update_bytes()
        .expect("signed update bytes");
    let midnight = decode_hex(
        "6d69646e696768743a636f6e74726163742d6d61696e74656e616e63652d7570646174655b76315d3a20006802486e6967687473747265616d2d72763634696d02100708090a04000801040005010c148959f09f2948c7d4357504ebb365cfd2e0840a83e0591398c2eb82a239ba2867555ec09d114666d11b3e9943f69e117c123ff5d0fe485f9debb49ca4428ffb0005011c148959f09f2948c7d4357504ebb365cfd2e0840a83e0591398c2eb82a239ba2867555ec09d114666d11b3e9943f69e117c123ff5d0fe485f9debb49ca4428ffb040c080104041014030401041008081408040808041884000000000000000000000000000000000000000000000000000000000000000040",
    );

    assert_eq!(local, midnight);
}

#[test]
fn rv64im_contract_verifier_key_insert_signed_update_exact_bytes_round_trip_through_bridge() {
    let signed_update =
        build_rv64im_contract_verifier_key_insert_signed_update(build_rv64im_contract_verifier_key_insert_update(
            sample_contract_address(),
            17,
            b"nightstream-rv64im".to_vec(),
            build_rv64im_contract_operation_versioned_verifier_key(sample_verifier_key()),
        ))
        .add_signature(9, sample_signature())
        .add_signature(1, sample_signature());

    let encoded = encode_rv64im_contract_verifier_key_insert_signed_update_bytes(&signed_update)
        .expect("encode exact signed update");
    let decoded =
        parse_rv64im_contract_verifier_key_insert_signed_update_bytes(&encoded).expect("decode exact signed update");

    assert_eq!(decoded, signed_update);
}

#[test]
fn rv64im_contract_verifier_key_insert_signed_update_exact_bytes_parse_midnight_golden() {
    let midnight = decode_hex(
        "6d69646e696768743a636f6e74726163742d6d61696e74656e616e63652d7570646174655b76315d3a20006802486e6967687473747265616d2d72763634696d02100708090a04000801040005010c148959f09f2948c7d4357504ebb365cfd2e0840a83e0591398c2eb82a239ba2867555ec09d114666d11b3e9943f69e117c123ff5d0fe485f9debb49ca4428ffb0005011c148959f09f2948c7d4357504ebb365cfd2e0840a83e0591398c2eb82a239ba2867555ec09d114666d11b3e9943f69e117c123ff5d0fe485f9debb49ca4428ffb040c080104041014030401041008081408040808041884000000000000000000000000000000000000000000000000000000000000000040",
    );

    let parsed =
        parse_rv64im_contract_verifier_key_insert_signed_update_bytes(&midnight).expect("parse midnight signed update");
    let signature_indices: Vec<u32> = parsed
        .signatures()
        .iter()
        .map(|value| value.into_inner().0)
        .collect();

    assert_eq!(parsed.unsigned_update().address(), &sample_contract_address());
    assert_eq!(parsed.unsigned_update().counter(), 16);
    assert_eq!(
        parsed.unsigned_update().insert().entry_point().as_bytes(),
        b"nightstream-rv64im"
    );
    assert_eq!(signature_indices, vec![3, 7]);
    assert_eq!(
        encode_rv64im_contract_verifier_key_insert_signed_update_bytes(&parsed)
            .expect("re-encode midnight signed update"),
        midnight
    );
}

#[test]
fn rv64im_contract_verifier_key_insert_maintain_action_exact_bytes_round_trip_through_bridge() {
    let action = build_rv64im_contract_verifier_key_insert_maintain_action(
        build_rv64im_contract_verifier_key_insert_signed_update(build_rv64im_contract_verifier_key_insert_update(
            sample_contract_address(),
            18,
            b"nightstream-rv64im".to_vec(),
            build_rv64im_contract_operation_versioned_verifier_key(sample_verifier_key()),
        ))
        .add_signature(5, sample_signature())
        .add_signature(2, sample_signature()),
    );

    let encoded =
        encode_rv64im_contract_verifier_key_insert_maintain_action_bytes(&action).expect("encode maintain action");
    let decoded =
        parse_rv64im_contract_verifier_key_insert_maintain_action_bytes(&encoded).expect("decode maintain action");

    assert_eq!(decoded, action);
}

#[test]
fn rv64im_contract_verifier_key_insert_maintain_action_bytes_match_midnight_shape() {
    let action = build_rv64im_contract_verifier_key_insert_maintain_action(
        build_rv64im_contract_verifier_key_insert_signed_update(build_rv64im_contract_verifier_key_insert_update(
            sample_contract_address(),
            16,
            b"nightstream-rv64im".to_vec(),
            build_rv64im_contract_operation_versioned_verifier_key(sample_verifier_key()),
        ))
        .add_signature(7, sample_signature())
        .add_signature(3, sample_signature()),
    );

    let local =
        encode_rv64im_contract_verifier_key_insert_maintain_action_bytes(&action).expect("encode maintain action");
    let midnight = decode_hex(
        "6d69646e696768743a636f6e74726163742d616374696f6e5b76365d3a0220006802486e6967687473747265616d2d72763634696d02100708090a04000801040005010c148959f09f2948c7d4357504ebb365cfd2e0840a83e0591398c2eb82a239ba2867555ec09d114666d11b3e9943f69e117c123ff5d0fe485f9debb49ca4428ffb0005011c148959f09f2948c7d4357504ebb365cfd2e0840a83e0591398c2eb82a239ba2867555ec09d114666d11b3e9943f69e117c123ff5d0fe485f9debb49ca4428ffb040c080104041014030401041008081408040808041884000000000000000000000000000000000000000000000000000000000000000040",
    );

    assert_eq!(local, midnight);
    let parsed =
        parse_rv64im_contract_verifier_key_insert_maintain_action_bytes(&midnight).expect("parse maintain action");
    assert_eq!(parsed, action);
}

#[test]
fn rv64im_contract_verifier_key_insert_maintain_action_submit_request_uses_exact_action_bytes() {
    let action = build_rv64im_contract_verifier_key_insert_maintain_action(
        build_rv64im_contract_verifier_key_insert_signed_update(build_rv64im_contract_verifier_key_insert_update(
            sample_contract_address(),
            19,
            b"nightstream-rv64im".to_vec(),
            build_rv64im_contract_operation_versioned_verifier_key(sample_verifier_key()),
        ))
        .add_signature(8, sample_signature()),
    );

    let request = build_rv64im_contract_verifier_key_insert_maintain_action_submit_request(&action)
        .expect("build submit request");
    let exact_action_bytes =
        encode_rv64im_contract_verifier_key_insert_maintain_action_bytes(&action).expect("encode maintain action");

    assert_eq!(request.body(), exact_action_bytes.as_slice());
}

#[test]
fn rv64im_contract_submit_provider_executes_maintain_action_request() {
    let action = build_rv64im_contract_verifier_key_insert_maintain_action(
        build_rv64im_contract_verifier_key_insert_signed_update(build_rv64im_contract_verifier_key_insert_update(
            sample_contract_address(),
            20,
            b"nightstream-rv64im".to_vec(),
            build_rv64im_contract_operation_versioned_verifier_key(sample_verifier_key()),
        ))
        .add_signature(6, sample_signature()),
    );
    let expected_request_body =
        encode_rv64im_contract_verifier_key_insert_maintain_action_bytes(&action).expect("encode maintain action");
    let provider = MockContractActionSubmitProvider {
        expected_request_body,
        response: Ok(vec![1u8, 2, 3, 4]),
    };

    let receipt = execute_rv64im_contract_verifier_key_insert_maintain_action_submit(&provider, &action)
        .expect("execute maintain action submit");

    assert_eq!(receipt.as_bytes(), &[1u8, 2, 3, 4]);
}

#[test]
fn rv64im_contract_submit_provider_maps_transport_failures() {
    let action = build_rv64im_contract_verifier_key_insert_maintain_action(
        build_rv64im_contract_verifier_key_insert_signed_update(build_rv64im_contract_verifier_key_insert_update(
            sample_contract_address(),
            21,
            b"nightstream-rv64im".to_vec(),
            build_rv64im_contract_operation_versioned_verifier_key(sample_verifier_key()),
        ))
        .add_signature(10, sample_signature()),
    );
    let request = build_rv64im_contract_verifier_key_insert_maintain_action_submit_request(&action)
        .expect("build submit request");
    let provider = MockContractActionSubmitProvider {
        expected_request_body: request.body().to_vec(),
        response: Err("mock submit failed".into()),
    };

    let err = execute_rv64im_contract_action_submit_request(&provider, &request).expect_err("map transport failure");
    assert!(matches!(err, Rv64imBridgeError::Transport(message) if message == "mock submit failed"));
}

#[test]
fn rv64im_contract_signed_update_submit_request_matches_maintain_action_submit_request() {
    let signed_update =
        build_rv64im_contract_verifier_key_insert_signed_update(build_rv64im_contract_verifier_key_insert_update(
            sample_contract_address(),
            22,
            b"nightstream-rv64im".to_vec(),
            build_rv64im_contract_operation_versioned_verifier_key(sample_verifier_key()),
        ))
        .add_signature(11, sample_signature());
    let action = build_rv64im_contract_verifier_key_insert_maintain_action(signed_update.clone());

    let signed_update_request = build_rv64im_contract_verifier_key_insert_signed_update_submit_request(&signed_update)
        .expect("build signed update submit request");
    let action_request = build_rv64im_contract_verifier_key_insert_maintain_action_submit_request(&action)
        .expect("build maintain action submit request");

    assert_eq!(signed_update_request.body(), action_request.body());
}

#[test]
fn rv64im_contract_submit_provider_executes_signed_update_request() {
    let signed_update =
        build_rv64im_contract_verifier_key_insert_signed_update(build_rv64im_contract_verifier_key_insert_update(
            sample_contract_address(),
            23,
            b"nightstream-rv64im".to_vec(),
            build_rv64im_contract_operation_versioned_verifier_key(sample_verifier_key()),
        ))
        .add_signature(12, sample_signature());
    let expected_request_body = build_rv64im_contract_verifier_key_insert_signed_update_submit_request(&signed_update)
        .expect("build signed update submit request")
        .into_body();
    let provider = MockContractActionSubmitProvider {
        expected_request_body,
        response: Ok(vec![9u8, 8, 7]),
    };

    let receipt = execute_rv64im_contract_verifier_key_insert_signed_update_submit(&provider, &signed_update)
        .expect("execute signed update submit");

    assert_eq!(receipt.as_bytes(), &[9u8, 8, 7]);
}
