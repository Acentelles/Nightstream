//! Owns RV64IM Midnight contract-action submission request and receipt helpers.

use super::{
    build_rv64im_contract_verifier_key_insert_maintain_action,
    encode_rv64im_contract_verifier_key_insert_maintain_action_bytes, Rv64imBridgeError,
    Rv64imContractVerifierKeyInsertMaintainAction, Rv64imContractVerifierKeyInsertSignedUpdate,
};

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Rv64imContractActionSubmitRequest {
    body: Vec<u8>,
}

impl Rv64imContractActionSubmitRequest {
    pub fn body(&self) -> &[u8] {
        &self.body
    }

    pub fn into_body(self) -> Vec<u8> {
        self.body
    }
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Rv64imContractActionSubmitReceipt {
    bytes: Vec<u8>,
}

impl Rv64imContractActionSubmitReceipt {
    pub fn as_bytes(&self) -> &[u8] {
        &self.bytes
    }

    pub fn into_bytes(self) -> Vec<u8> {
        self.bytes
    }
}

pub trait Rv64imContractActionSubmitProvider {
    fn execute(&self, request: &Rv64imContractActionSubmitRequest) -> Result<Vec<u8>, String>;
}

pub fn build_rv64im_contract_verifier_key_insert_maintain_action_submit_request(
    action: &Rv64imContractVerifierKeyInsertMaintainAction,
) -> Result<Rv64imContractActionSubmitRequest, Rv64imBridgeError> {
    Ok(Rv64imContractActionSubmitRequest {
        body: encode_rv64im_contract_verifier_key_insert_maintain_action_bytes(action)?,
    })
}

pub fn build_rv64im_contract_verifier_key_insert_signed_update_submit_request(
    signed_update: &Rv64imContractVerifierKeyInsertSignedUpdate,
) -> Result<Rv64imContractActionSubmitRequest, Rv64imBridgeError> {
    let action = build_rv64im_contract_verifier_key_insert_maintain_action(signed_update.clone());
    build_rv64im_contract_verifier_key_insert_maintain_action_submit_request(&action)
}

pub fn execute_rv64im_contract_action_submit_request(
    provider: &impl Rv64imContractActionSubmitProvider,
    request: &Rv64imContractActionSubmitRequest,
) -> Result<Rv64imContractActionSubmitReceipt, Rv64imBridgeError> {
    let bytes = provider
        .execute(request)
        .map_err(Rv64imBridgeError::Transport)?;
    Ok(Rv64imContractActionSubmitReceipt { bytes })
}

pub fn execute_rv64im_contract_verifier_key_insert_maintain_action_submit(
    provider: &impl Rv64imContractActionSubmitProvider,
    action: &Rv64imContractVerifierKeyInsertMaintainAction,
) -> Result<Rv64imContractActionSubmitReceipt, Rv64imBridgeError> {
    let request = build_rv64im_contract_verifier_key_insert_maintain_action_submit_request(action)?;
    execute_rv64im_contract_action_submit_request(provider, &request)
}

pub fn execute_rv64im_contract_verifier_key_insert_signed_update_submit(
    provider: &impl Rv64imContractActionSubmitProvider,
    signed_update: &Rv64imContractVerifierKeyInsertSignedUpdate,
) -> Result<Rv64imContractActionSubmitReceipt, Rv64imBridgeError> {
    let request = build_rv64im_contract_verifier_key_insert_signed_update_submit_request(signed_update)?;
    execute_rv64im_contract_action_submit_request(provider, &request)
}
