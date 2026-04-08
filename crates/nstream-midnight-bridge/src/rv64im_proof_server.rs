//! Owns RV64IM Midnight proof-server request payload wrappers and serialization.

use super::{
    build_rv64im_nightstream_midnight_proof_preimage, Rv64imBridgeError, Rv64imNightstreamBridgePreimage,
    RV64IM_NIGHTSTREAM_BRIDGE_KEY_LOCATION,
};
use serialize::{tagged_serialize, Deserializable, Serializable, Tagged};
use std::borrow::Cow;
use std::io::{Read, Write};
use std::sync::Arc;
use transient_crypto::curve::Fr;
use transient_crypto::proofs::{Proof, ProofPreimage, ProvingKeyMaterial};

#[derive(Clone, Debug)]
pub enum Rv64imProofServerPreimageVersioned {
    V2(Arc<ProofPreimage>),
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Rv64imProofServerRoute {
    Prove,
    Check,
}

impl Rv64imProofServerRoute {
    pub fn path(self) -> &'static str {
        match self {
            Self::Prove => "/prove",
            Self::Check => "/check",
        }
    }

    pub fn parse_response_body(self, body: &[u8]) -> Result<Rv64imProofServerResponse, Rv64imBridgeError> {
        match self {
            Self::Prove => parse_rv64im_nightstream_prove_response_body(body).map(Rv64imProofServerResponse::Prove),
            Self::Check => parse_rv64im_nightstream_check_response_body(body).map(Rv64imProofServerResponse::Check),
        }
    }
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Rv64imProofServerRequest {
    route: Rv64imProofServerRoute,
    body: Vec<u8>,
}

pub trait Rv64imProofServerProvider {
    fn execute(&self, request: &Rv64imProofServerRequest) -> Result<Vec<u8>, String>;
}

impl Rv64imProofServerRequest {
    pub fn path(&self) -> &'static str {
        self.route.path()
    }

    pub fn body(&self) -> &[u8] {
        &self.body
    }

    pub fn into_body(self) -> Vec<u8> {
        self.body
    }

    pub fn parse_response_body(&self, body: &[u8]) -> Result<Rv64imProofServerResponse, Rv64imBridgeError> {
        self.route.parse_response_body(body)
    }
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Rv64imProofServerResponse {
    Prove(Rv64imProofServerProofVersioned),
    Check(Rv64imProofServerCheckResponse),
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Rv64imProofServerProofVersioned {
    V2(Proof),
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Rv64imProofServerCheckResponse {
    skipped_output_blocks: Vec<Option<u64>>,
}

impl Rv64imProofServerCheckResponse {
    pub fn new(skipped_output_blocks: Vec<Option<u64>>) -> Self {
        Self { skipped_output_blocks }
    }

    pub fn skipped_output_blocks(&self) -> &[Option<u64>] {
        &self.skipped_output_blocks
    }

    pub fn into_skipped_output_blocks(self) -> Vec<Option<u64>> {
        self.skipped_output_blocks
    }
}

impl Tagged for Rv64imProofServerPreimageVersioned {
    fn tag() -> Cow<'static, str> {
        Cow::Borrowed("proof-preimage-versioned")
    }

    fn tag_unique_factor() -> String {
        "[proof-preimage]".to_owned()
    }
}

impl Serializable for Rv64imProofServerPreimageVersioned {
    fn serialize(&self, writer: &mut impl Write) -> std::io::Result<()> {
        match self {
            Self::V2(preimage) => {
                Serializable::serialize(&1u8, writer)?;
                preimage.as_ref().serialize(writer)
            }
        }
    }

    fn serialized_size(&self) -> usize {
        match self {
            Self::V2(preimage) => Serializable::serialized_size(&1u8) + preimage.as_ref().serialized_size(),
        }
    }
}

impl Deserializable for Rv64imProofServerPreimageVersioned {
    fn deserialize(reader: &mut impl Read, recursion_depth: u32) -> std::io::Result<Self> {
        let version = u8::deserialize(reader, recursion_depth)?;
        match version {
            1 => Ok(Self::V2(Arc::new(ProofPreimage::deserialize(
                reader,
                recursion_depth + 1,
            )?))),
            other => Err(std::io::Error::new(
                std::io::ErrorKind::InvalidData,
                format!("unsupported proof-preimage-versioned variant {other}"),
            )),
        }
    }
}

impl Tagged for Rv64imProofServerProofVersioned {
    fn tag() -> Cow<'static, str> {
        Cow::Borrowed("proof-versioned")
    }

    fn tag_unique_factor() -> String {
        format!("[[],{}]", Proof::tag())
    }
}

impl Serializable for Rv64imProofServerProofVersioned {
    fn serialize(&self, writer: &mut impl Write) -> std::io::Result<()> {
        match self {
            Self::V2(proof) => {
                Serializable::serialize(&1u8, writer)?;
                proof.serialize(writer)
            }
        }
    }

    fn serialized_size(&self) -> usize {
        match self {
            Self::V2(proof) => proof.serialized_size() + 1,
        }
    }
}

impl Deserializable for Rv64imProofServerProofVersioned {
    fn deserialize(reader: &mut impl Read, recursion_depth: u32) -> std::io::Result<Self> {
        let discrim = u8::deserialize(reader, recursion_depth)?;
        match discrim {
            1 => Ok(Self::V2(Proof::deserialize(reader, recursion_depth)?)),
            0 => Err(std::io::Error::new(
                std::io::ErrorKind::InvalidData,
                format!("invalid old discriminant for proof-versioned: {discrim}"),
            )),
            _ => Err(std::io::Error::new(
                std::io::ErrorKind::InvalidData,
                format!("unknown discriminant for proof-versioned: {discrim}"),
            )),
        }
    }
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Rv64imProofServerWrappedIr(pub Vec<u8>);

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Rv64imProofServerResolverPolicy {
    BridgeKeyLocation,
}

impl Rv64imProofServerResolverPolicy {
    pub fn key_location(self) -> &'static str {
        match self {
            Self::BridgeKeyLocation => RV64IM_NIGHTSTREAM_BRIDGE_KEY_LOCATION,
        }
    }
}

#[derive(Clone, Debug, PartialEq, Eq)]
enum Rv64imProofServerCheckMaterial {
    ResolverBacked,
    EmbeddedIr(Vec<u8>),
}

#[derive(Clone)]
enum Rv64imProofServerProvingMaterial {
    ResolverBacked,
    EmbeddedProvingData(ProvingKeyMaterial),
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Rv64imProofServerCheckRequestPolicy {
    resolver_policy: Option<Rv64imProofServerResolverPolicy>,
    check_material: Rv64imProofServerCheckMaterial,
}

impl Rv64imProofServerCheckRequestPolicy {
    pub fn resolver_backed() -> Self {
        Self {
            resolver_policy: Some(Rv64imProofServerResolverPolicy::BridgeKeyLocation),
            check_material: Rv64imProofServerCheckMaterial::ResolverBacked,
        }
    }

    pub fn embedded_ir(ir_source: Vec<u8>) -> Self {
        Self {
            resolver_policy: None,
            check_material: Rv64imProofServerCheckMaterial::EmbeddedIr(ir_source),
        }
    }

    pub fn resolver_policy(&self) -> Option<Rv64imProofServerResolverPolicy> {
        self.resolver_policy
    }
}

#[derive(Clone)]
pub struct Rv64imProofServerProveRequestPolicy {
    resolver_policy: Option<Rv64imProofServerResolverPolicy>,
    proving_material: Rv64imProofServerProvingMaterial,
}

impl Rv64imProofServerProveRequestPolicy {
    pub fn resolver_backed() -> Self {
        Self {
            resolver_policy: Some(Rv64imProofServerResolverPolicy::BridgeKeyLocation),
            proving_material: Rv64imProofServerProvingMaterial::ResolverBacked,
        }
    }

    pub fn embedded_proving_data(proving_data: ProvingKeyMaterial) -> Self {
        Self {
            resolver_policy: None,
            proving_material: Rv64imProofServerProvingMaterial::EmbeddedProvingData(proving_data),
        }
    }

    pub fn resolver_policy(&self) -> Option<Rv64imProofServerResolverPolicy> {
        self.resolver_policy
    }
}

impl Tagged for Rv64imProofServerWrappedIr {
    fn tag() -> Cow<'static, str> {
        Cow::Borrowed("wrapped-ir")
    }

    fn tag_unique_factor() -> String {
        "wrapped-ir".to_owned()
    }
}

impl Serializable for Rv64imProofServerWrappedIr {
    fn serialize(&self, writer: &mut impl Write) -> std::io::Result<()> {
        self.0.serialize(writer)
    }

    fn serialized_size(&self) -> usize {
        self.0.serialized_size()
    }
}

impl Deserializable for Rv64imProofServerWrappedIr {
    fn deserialize(reader: &mut impl Read, recursion_depth: u32) -> std::io::Result<Self> {
        Ok(Self(Vec::<u8>::deserialize(reader, recursion_depth + 1)?))
    }
}

pub fn build_rv64im_nightstream_proof_server_request_body(
    preimage: &Rv64imNightstreamBridgePreimage,
    request_policy: Rv64imProofServerProveRequestPolicy,
) -> Result<Vec<u8>, Rv64imBridgeError> {
    verify_rv64im_proof_server_resolver_policy(preimage, request_policy.resolver_policy())?;
    let midnight_preimage = build_rv64im_nightstream_midnight_proof_preimage(preimage)?;
    let proving_data = match request_policy.proving_material {
        Rv64imProofServerProvingMaterial::ResolverBacked => None,
        Rv64imProofServerProvingMaterial::EmbeddedProvingData(proving_data) => Some(proving_data),
    };
    let request = (
        Rv64imProofServerPreimageVersioned::V2(Arc::new(midnight_preimage)),
        proving_data,
        Option::<Fr>::None,
    );
    let mut body = Vec::new();
    tagged_serialize(&request, &mut body).map_err(|err| Rv64imBridgeError::RequestEncode(err.to_string()))?;
    Ok(body)
}

pub fn build_rv64im_nightstream_prove_request(
    preimage: &Rv64imNightstreamBridgePreimage,
    request_policy: Rv64imProofServerProveRequestPolicy,
) -> Result<Rv64imProofServerRequest, Rv64imBridgeError> {
    Ok(Rv64imProofServerRequest {
        route: Rv64imProofServerRoute::Prove,
        body: build_rv64im_nightstream_proof_server_request_body(preimage, request_policy)?,
    })
}

pub fn execute_rv64im_proof_server_request(
    provider: &impl Rv64imProofServerProvider,
    request: &Rv64imProofServerRequest,
) -> Result<Rv64imProofServerResponse, Rv64imBridgeError> {
    let response_body = provider
        .execute(request)
        .map_err(Rv64imBridgeError::Transport)?;
    request.parse_response_body(&response_body)
}

pub fn execute_rv64im_nightstream_prove_request(
    provider: &impl Rv64imProofServerProvider,
    preimage: &Rv64imNightstreamBridgePreimage,
    request_policy: Rv64imProofServerProveRequestPolicy,
) -> Result<Rv64imProofServerProofVersioned, Rv64imBridgeError> {
    let request = build_rv64im_nightstream_prove_request(preimage, request_policy)?;
    match execute_rv64im_proof_server_request(provider, &request)? {
        Rv64imProofServerResponse::Prove(proof) => Ok(proof),
        Rv64imProofServerResponse::Check(_) => Err(Rv64imBridgeError::InvalidEncoding(
            "RV64IM Nightstream prove request produced check response".into(),
        )),
    }
}

pub fn build_rv64im_nightstream_check_request_body(
    preimage: &Rv64imNightstreamBridgePreimage,
    request_policy: Rv64imProofServerCheckRequestPolicy,
) -> Result<Vec<u8>, Rv64imBridgeError> {
    verify_rv64im_proof_server_resolver_policy(preimage, request_policy.resolver_policy())?;
    let midnight_preimage = build_rv64im_nightstream_midnight_proof_preimage(preimage)?;
    let wrapped_ir = match request_policy.check_material {
        Rv64imProofServerCheckMaterial::ResolverBacked => None,
        Rv64imProofServerCheckMaterial::EmbeddedIr(ir_source) => Some(Rv64imProofServerWrappedIr(ir_source)),
    };
    let request = (
        Rv64imProofServerPreimageVersioned::V2(Arc::new(midnight_preimage)),
        wrapped_ir,
    );
    let mut body = Vec::new();
    tagged_serialize(&request, &mut body).map_err(|err| Rv64imBridgeError::RequestEncode(err.to_string()))?;
    Ok(body)
}

pub fn build_rv64im_nightstream_check_request(
    preimage: &Rv64imNightstreamBridgePreimage,
    request_policy: Rv64imProofServerCheckRequestPolicy,
) -> Result<Rv64imProofServerRequest, Rv64imBridgeError> {
    Ok(Rv64imProofServerRequest {
        route: Rv64imProofServerRoute::Check,
        body: build_rv64im_nightstream_check_request_body(preimage, request_policy)?,
    })
}

pub fn execute_rv64im_nightstream_check_request(
    provider: &impl Rv64imProofServerProvider,
    preimage: &Rv64imNightstreamBridgePreimage,
    request_policy: Rv64imProofServerCheckRequestPolicy,
) -> Result<Rv64imProofServerCheckResponse, Rv64imBridgeError> {
    let request = build_rv64im_nightstream_check_request(preimage, request_policy)?;
    match execute_rv64im_proof_server_request(provider, &request)? {
        Rv64imProofServerResponse::Check(response) => Ok(response),
        Rv64imProofServerResponse::Prove(_) => Err(Rv64imBridgeError::InvalidEncoding(
            "RV64IM Nightstream check request produced prove response".into(),
        )),
    }
}

pub fn parse_rv64im_nightstream_prove_response_body(
    body: &[u8],
) -> Result<Rv64imProofServerProofVersioned, Rv64imBridgeError> {
    serialize::tagged_deserialize(&body[..]).map_err(|err| Rv64imBridgeError::ResponseDecode(err.to_string()))
}

pub fn parse_rv64im_nightstream_check_response_body(
    body: &[u8],
) -> Result<Rv64imProofServerCheckResponse, Rv64imBridgeError> {
    let skipped_output_blocks: Vec<Option<u64>> =
        serialize::tagged_deserialize(&body[..]).map_err(|err| Rv64imBridgeError::ResponseDecode(err.to_string()))?;
    Ok(Rv64imProofServerCheckResponse::new(skipped_output_blocks))
}

fn verify_rv64im_proof_server_resolver_policy(
    preimage: &Rv64imNightstreamBridgePreimage,
    resolver_policy: Option<Rv64imProofServerResolverPolicy>,
) -> Result<(), Rv64imBridgeError> {
    let Some(resolver_policy) = resolver_policy else {
        return Ok(());
    };
    let expected_key_location = resolver_policy.key_location();
    if preimage.key_location != expected_key_location {
        return Err(Rv64imBridgeError::InvalidEncoding(format!(
            "RV64IM Nightstream proof-server resolver policy requires key_location {}",
            expected_key_location
        )));
    }
    Ok(())
}
