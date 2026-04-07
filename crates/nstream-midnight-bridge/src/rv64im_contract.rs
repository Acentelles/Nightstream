//! Owns RV64IM Midnight contract-install/update verifier-key wrappers.

pub use base_crypto::signatures::Signature as Rv64imContractSignature;
pub use coin_structure::contract::ContractAddress as Rv64imContractAddress;

use super::Rv64imBridgeError;
use serialize::{tagged_deserialize, tagged_serialize, Deserializable, Serializable, Tagged};
use std::borrow::Cow;
use std::io::{Read, Write};
use storage::{arena::ArenaKey, db::DB, storable::Loader, storage::Array, DefaultDB, Storable};
use transient_crypto::proofs::VerifierKey;

#[derive(Clone, Debug, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub struct Rv64imEntryPointBuf(pub Vec<u8>);

impl Rv64imEntryPointBuf {
    pub fn as_bytes(&self) -> &[u8] {
        &self.0
    }
}

impl Tagged for Rv64imEntryPointBuf {
    fn tag() -> Cow<'static, str> {
        Cow::Borrowed("entry-point")
    }

    fn tag_unique_factor() -> String {
        "vec(u8)".into()
    }
}

impl Serializable for Rv64imEntryPointBuf {
    fn serialize(&self, writer: &mut impl Write) -> Result<(), std::io::Error> {
        Serializable::serialize(&self.0, writer)
    }

    fn serialized_size(&self) -> usize {
        Serializable::serialized_size(&self.0)
    }
}

impl Deserializable for Rv64imEntryPointBuf {
    fn deserialize(reader: &mut impl Read, recursion_depth: u32) -> Result<Self, std::io::Error> {
        Ok(Self(Vec::<u8>::deserialize(reader, recursion_depth)?))
    }
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord, Hash)]
#[non_exhaustive]
pub enum Rv64imContractOperationVersion {
    V3,
}

impl Tagged for Rv64imContractOperationVersion {
    fn tag() -> Cow<'static, str> {
        Cow::Borrowed("contract-operation-version")
    }

    fn tag_unique_factor() -> String {
        "u8".into()
    }
}

impl Serializable for Rv64imContractOperationVersion {
    fn serialize(&self, writer: &mut impl Write) -> Result<(), std::io::Error> {
        match self {
            Self::V3 => Serializable::serialize(&2u8, writer),
        }
    }

    fn serialized_size(&self) -> usize {
        1
    }
}

impl Deserializable for Rv64imContractOperationVersion {
    fn deserialize(reader: &mut impl Read, recursion_depth: u32) -> Result<Self, std::io::Error> {
        let discriminant = u8::deserialize(reader, recursion_depth)?;
        match discriminant {
            0..=1 => Err(std::io::Error::new(
                std::io::ErrorKind::InvalidData,
                format!("Invalid old discriminant {discriminant}"),
            )),
            2 => Ok(Self::V3),
            _ => Err(std::io::Error::new(
                std::io::ErrorKind::InvalidData,
                format!("Unknown discriminant {discriminant}"),
            )),
        }
    }
}

#[derive(Clone, Debug, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub enum Rv64imContractOperationVersionedVerifierKey {
    V3(VerifierKey),
}

impl Rv64imContractOperationVersionedVerifierKey {
    pub fn verifier_key(&self) -> &VerifierKey {
        match self {
            Self::V3(verifier_key) => verifier_key,
        }
    }

    pub fn version(&self) -> Rv64imContractOperationVersion {
        match self {
            Self::V3(_) => Rv64imContractOperationVersion::V3,
        }
    }
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Rv64imContractVerifierKeyInsert {
    entry_point: Rv64imEntryPointBuf,
    verifier_key: Rv64imContractOperationVersionedVerifierKey,
}

impl Rv64imContractVerifierKeyInsert {
    pub fn new(entry_point: Rv64imEntryPointBuf, verifier_key: Rv64imContractOperationVersionedVerifierKey) -> Self {
        Self {
            entry_point,
            verifier_key,
        }
    }

    pub fn entry_point(&self) -> &Rv64imEntryPointBuf {
        &self.entry_point
    }

    pub fn verifier_key(&self) -> &Rv64imContractOperationVersionedVerifierKey {
        &self.verifier_key
    }
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Rv64imContractVerifierKeyInsertUpdate {
    address: Rv64imContractAddress,
    counter: u32,
    insert: Rv64imContractVerifierKeyInsert,
}

impl Rv64imContractVerifierKeyInsertUpdate {
    pub fn new(address: Rv64imContractAddress, counter: u32, insert: Rv64imContractVerifierKeyInsert) -> Self {
        Self {
            address,
            counter,
            insert,
        }
    }

    pub fn address(&self) -> &Rv64imContractAddress {
        &self.address
    }

    pub fn counter(&self) -> u32 {
        self.counter
    }

    pub fn insert(&self) -> &Rv64imContractVerifierKeyInsert {
        &self.insert
    }

    pub fn data_to_sign(&self) -> Result<Vec<u8>, Rv64imBridgeError> {
        let updates: Array<Rv64imContractMaintenanceSingleUpdate> = vec![self.insert.as_single_update()].into();
        let mut data = Vec::new();
        data.extend(b"midnight:contract-update:");
        Serializable::serialize(&self.address, &mut data)
            .map_err(|err| Rv64imBridgeError::ArtifactEncode(err.to_string()))?;
        Serializable::serialize(&updates, &mut data)
            .map_err(|err| Rv64imBridgeError::ArtifactEncode(err.to_string()))?;
        Serializable::serialize(&self.counter, &mut data)
            .map_err(|err| Rv64imBridgeError::ArtifactEncode(err.to_string()))?;
        Ok(data)
    }
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Rv64imContractVerifierKeyInsertSignedUpdate {
    update: Rv64imContractVerifierKeyInsertUpdate,
    signatures: Vec<Rv64imContractSignaturesValue>,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Rv64imContractVerifierKeyInsertMaintainAction {
    signed_update: Rv64imContractVerifierKeyInsertSignedUpdate,
}

impl Rv64imContractVerifierKeyInsertSignedUpdate {
    pub fn new(update: Rv64imContractVerifierKeyInsertUpdate) -> Self {
        Self {
            update,
            signatures: Vec::new(),
        }
    }

    pub fn unsigned_update(&self) -> &Rv64imContractVerifierKeyInsertUpdate {
        &self.update
    }

    pub fn signatures(&self) -> &[Rv64imContractSignaturesValue] {
        &self.signatures
    }

    pub fn data_to_sign(&self) -> Result<Vec<u8>, Rv64imBridgeError> {
        self.update.data_to_sign()
    }

    pub fn add_signature(mut self, idx: u32, signature: Rv64imContractSignature) -> Self {
        self.signatures
            .push(Rv64imContractSignaturesValue(idx, signature));
        self.signatures.sort();
        self
    }

    pub fn signed_update_bytes(&self) -> Result<Vec<u8>, Rv64imBridgeError> {
        let maintenance_update = Rv64imContractMaintenanceUpdate::<DefaultDB> {
            address: *self.update.address(),
            updates: vec![self.update.insert().as_single_update()].into(),
            counter: self.update.counter(),
            signatures: self.signatures.clone().into(),
        };
        let mut bytes = Vec::new();
        tagged_serialize(&maintenance_update, &mut bytes)
            .map_err(|err| Rv64imBridgeError::ArtifactEncode(err.to_string()))?;
        Ok(bytes)
    }

    pub fn from_signed_update_bytes(bytes: &[u8]) -> Result<Self, Rv64imBridgeError> {
        let maintenance_update: Rv64imContractMaintenanceUpdate<DefaultDB> =
            tagged_deserialize(&mut &bytes[..]).map_err(|err| Rv64imBridgeError::ArtifactDecode(err.to_string()))?;
        Self::from_exact_maintenance_update(maintenance_update)
    }

    fn from_exact_maintenance_update(
        maintenance_update: Rv64imContractMaintenanceUpdate<DefaultDB>,
    ) -> Result<Self, Rv64imBridgeError> {
        let mut updates = maintenance_update.updates.iter_deref().cloned();
        let insert = match updates.next() {
            Some(Rv64imContractMaintenanceSingleUpdate::VerifierKeyInsert(entry_point, verifier_key)) => {
                Rv64imContractVerifierKeyInsert::new(entry_point, verifier_key)
            }
            None => {
                return Err(Rv64imBridgeError::ArtifactDecode(
                    "expected exactly one verifier-key insert update, found none".into(),
                ))
            }
        };
        if updates.next().is_some() {
            return Err(Rv64imBridgeError::ArtifactDecode(
                "expected exactly one verifier-key insert update, found multiple updates".into(),
            ));
        }
        Ok(Self {
            update: Rv64imContractVerifierKeyInsertUpdate::new(
                maintenance_update.address,
                maintenance_update.counter,
                insert,
            ),
            signatures: maintenance_update
                .signatures
                .iter_deref()
                .cloned()
                .collect(),
        })
    }

    fn as_exact_maintenance_update(&self) -> Rv64imContractMaintenanceUpdate<DefaultDB> {
        Rv64imContractMaintenanceUpdate::<DefaultDB> {
            address: *self.update.address(),
            updates: vec![self.update.insert().as_single_update()].into(),
            counter: self.update.counter(),
            signatures: self.signatures.clone().into(),
        }
    }
}

impl Rv64imContractVerifierKeyInsertMaintainAction {
    pub fn new(signed_update: Rv64imContractVerifierKeyInsertSignedUpdate) -> Self {
        Self { signed_update }
    }

    pub fn signed_update(&self) -> &Rv64imContractVerifierKeyInsertSignedUpdate {
        &self.signed_update
    }

    pub fn action_bytes(&self) -> Result<Vec<u8>, Rv64imBridgeError> {
        let action = Rv64imContractAction::Maintain(self.signed_update.as_exact_maintenance_update());
        let mut bytes = Vec::new();
        tagged_serialize(&action, &mut bytes).map_err(|err| Rv64imBridgeError::ArtifactEncode(err.to_string()))?;
        Ok(bytes)
    }

    pub fn from_action_bytes(bytes: &[u8]) -> Result<Self, Rv64imBridgeError> {
        let action: Rv64imContractAction =
            tagged_deserialize(&mut &bytes[..]).map_err(|err| Rv64imBridgeError::ArtifactDecode(err.to_string()))?;
        match action {
            Rv64imContractAction::Maintain(maintenance_update) => Ok(Self {
                signed_update: Rv64imContractVerifierKeyInsertSignedUpdate::from_exact_maintenance_update(
                    maintenance_update,
                )?,
            }),
        }
    }
}

#[derive(Clone, Debug, PartialEq, Eq, PartialOrd, Ord, Hash, Storable)]
#[storable(base)]
enum Rv64imContractMaintenanceSingleUpdate {
    VerifierKeyInsert(Rv64imEntryPointBuf, Rv64imContractOperationVersionedVerifierKey),
}

#[derive(Clone, Debug, PartialEq, Eq, PartialOrd, Ord, Hash, Storable)]
#[storable(base)]
pub struct Rv64imContractSignaturesValue(pub u32, pub Rv64imContractSignature);

impl Rv64imContractSignaturesValue {
    pub fn into_inner(&self) -> (u32, Rv64imContractSignature) {
        (self.0, self.1.clone())
    }
}

#[derive(Storable)]
#[tag = "contract-maintenance-update[v1]"]
#[storable(db = D)]
struct Rv64imContractMaintenanceUpdate<D: DB> {
    address: Rv64imContractAddress,
    updates: Array<Rv64imContractMaintenanceSingleUpdate, D>,
    counter: u32,
    signatures: Array<Rv64imContractSignaturesValue, D>,
}

#[derive(Clone)]
enum Rv64imContractAction {
    Maintain(Rv64imContractMaintenanceUpdate<DefaultDB>),
}

impl Rv64imContractVerifierKeyInsert {
    fn as_single_update(&self) -> Rv64imContractMaintenanceSingleUpdate {
        Rv64imContractMaintenanceSingleUpdate::VerifierKeyInsert(self.entry_point.clone(), self.verifier_key.clone())
    }
}

impl<D: DB> Clone for Rv64imContractMaintenanceUpdate<D> {
    fn clone(&self) -> Self {
        Self {
            address: self.address,
            updates: self.updates.clone(),
            counter: self.counter,
            signatures: self.signatures.clone(),
        }
    }
}

impl Tagged for Rv64imContractOperationVersionedVerifierKey {
    fn tag() -> Cow<'static, str> {
        Cow::Borrowed("contract-operation-versioned-verifier-key")
    }

    fn tag_unique_factor() -> String {
        format!("[[],[],{}]", VerifierKey::tag())
    }
}

impl Tagged for Rv64imContractVerifierKeyInsert {
    fn tag() -> Cow<'static, str> {
        Cow::Borrowed("nstream-rv64im-contract-verifier-key-insert[v1]")
    }

    fn tag_unique_factor() -> String {
        format!(
            "({},{})",
            Rv64imEntryPointBuf::tag(),
            Rv64imContractOperationVersionedVerifierKey::tag()
        )
    }
}

impl Serializable for Rv64imContractVerifierKeyInsert {
    fn serialize(&self, writer: &mut impl Write) -> Result<(), std::io::Error> {
        Serializable::serialize(&self.entry_point, writer)?;
        Serializable::serialize(&self.verifier_key, writer)
    }

    fn serialized_size(&self) -> usize {
        Serializable::serialized_size(&self.entry_point) + Serializable::serialized_size(&self.verifier_key)
    }
}

impl Deserializable for Rv64imContractVerifierKeyInsert {
    fn deserialize(reader: &mut impl Read, recursion_depth: u32) -> Result<Self, std::io::Error> {
        Ok(Self {
            entry_point: Deserializable::deserialize(reader, recursion_depth)?,
            verifier_key: Deserializable::deserialize(reader, recursion_depth)?,
        })
    }
}

impl Tagged for Rv64imContractVerifierKeyInsertUpdate {
    fn tag() -> Cow<'static, str> {
        Cow::Borrowed("nstream-rv64im-contract-verifier-key-insert-update[v1]")
    }

    fn tag_unique_factor() -> String {
        format!(
            "({},u32,{})",
            Rv64imContractAddress::tag(),
            Rv64imContractVerifierKeyInsert::tag()
        )
    }
}

impl Tagged for Rv64imContractVerifierKeyInsertSignedUpdate {
    fn tag() -> Cow<'static, str> {
        Cow::Borrowed("nstream-rv64im-contract-verifier-key-insert-signed-update[v1]")
    }

    fn tag_unique_factor() -> String {
        format!(
            "({},vec({}))",
            Rv64imContractVerifierKeyInsertUpdate::tag(),
            Rv64imContractSignaturesValue::tag()
        )
    }
}

impl Tagged for Rv64imContractVerifierKeyInsertMaintainAction {
    fn tag() -> Cow<'static, str> {
        Cow::Borrowed("nstream-rv64im-contract-verifier-key-insert-maintain-action[v1]")
    }

    fn tag_unique_factor() -> String {
        Rv64imContractVerifierKeyInsertSignedUpdate::tag().to_string()
    }
}

impl Tagged for Rv64imContractMaintenanceSingleUpdate {
    fn tag() -> Cow<'static, str> {
        Cow::Borrowed("maintenance-update-single-update[v1]")
    }

    fn tag_unique_factor() -> String {
        "[(contract-maintenance-authority[v1]),(entry-point,contract-operation-version),(entry-point,contract-operation-versioned-verifier-key)]".into()
    }
}

impl Tagged for Rv64imContractAction {
    fn tag() -> Cow<'static, str> {
        Cow::Borrowed("contract-action[v6]")
    }

    fn tag_unique_factor() -> String {
        "[contract-call[v3],contract-deploy[v4],contract-maintenance-update[v1]]".into()
    }
}

impl Tagged for Rv64imContractSignaturesValue {
    fn tag() -> Cow<'static, str> {
        Cow::Borrowed("maintenance-update-signatures-value[v1]")
    }

    fn tag_unique_factor() -> String {
        format!("(u32,{})", Rv64imContractSignature::tag())
    }
}

impl Serializable for Rv64imContractSignaturesValue {
    fn serialize(&self, writer: &mut impl Write) -> Result<(), std::io::Error> {
        Serializable::serialize(&self.0, writer)?;
        Serializable::serialize(&self.1, writer)
    }

    fn serialized_size(&self) -> usize {
        Serializable::serialized_size(&self.0) + Serializable::serialized_size(&self.1)
    }
}

impl Deserializable for Rv64imContractSignaturesValue {
    fn deserialize(reader: &mut impl Read, recursion_depth: u32) -> Result<Self, std::io::Error> {
        Ok(Self(
            Deserializable::deserialize(reader, recursion_depth)?,
            Deserializable::deserialize(reader, recursion_depth)?,
        ))
    }
}

impl Serializable for Rv64imContractVerifierKeyInsertMaintainAction {
    fn serialize(&self, writer: &mut impl Write) -> Result<(), std::io::Error> {
        Serializable::serialize(&self.signed_update, writer)
    }

    fn serialized_size(&self) -> usize {
        Serializable::serialized_size(&self.signed_update)
    }
}

impl Deserializable for Rv64imContractVerifierKeyInsertMaintainAction {
    fn deserialize(reader: &mut impl Read, recursion_depth: u32) -> Result<Self, std::io::Error> {
        Ok(Self {
            signed_update: Deserializable::deserialize(reader, recursion_depth)?,
        })
    }
}

impl Serializable for Rv64imContractVerifierKeyInsertSignedUpdate {
    fn serialize(&self, writer: &mut impl Write) -> Result<(), std::io::Error> {
        Serializable::serialize(&self.update, writer)?;
        Serializable::serialize(&self.signatures, writer)
    }

    fn serialized_size(&self) -> usize {
        Serializable::serialized_size(&self.update) + Serializable::serialized_size(&self.signatures)
    }
}

impl Serializable for Rv64imContractAction {
    fn serialize(&self, writer: &mut impl Write) -> Result<(), std::io::Error> {
        match self {
            Self::Maintain(maintenance_update) => {
                Serializable::serialize(&2u8, writer)?;
                Serializable::serialize(maintenance_update, writer)
            }
        }
    }

    fn serialized_size(&self) -> usize {
        match self {
            Self::Maintain(maintenance_update) => 1 + Serializable::serialized_size(maintenance_update),
        }
    }
}

impl Deserializable for Rv64imContractVerifierKeyInsertSignedUpdate {
    fn deserialize(reader: &mut impl Read, recursion_depth: u32) -> Result<Self, std::io::Error> {
        Ok(Self {
            update: Deserializable::deserialize(reader, recursion_depth)?,
            signatures: Deserializable::deserialize(reader, recursion_depth)?,
        })
    }
}

impl Serializable for Rv64imContractMaintenanceSingleUpdate {
    fn serialize(&self, writer: &mut impl Write) -> Result<(), std::io::Error> {
        match self {
            Self::VerifierKeyInsert(entry_point, verifier_key) => {
                Serializable::serialize(&2u8, writer)?;
                Serializable::serialize(entry_point, writer)?;
                Serializable::serialize(verifier_key, writer)
            }
        }
    }

    fn serialized_size(&self) -> usize {
        match self {
            Self::VerifierKeyInsert(entry_point, verifier_key) => {
                1 + Serializable::serialized_size(entry_point) + Serializable::serialized_size(verifier_key)
            }
        }
    }
}

impl Deserializable for Rv64imContractMaintenanceSingleUpdate {
    fn deserialize(reader: &mut impl Read, recursion_depth: u32) -> Result<Self, std::io::Error> {
        match u8::deserialize(reader, recursion_depth)? {
            2 => Ok(Self::VerifierKeyInsert(
                Deserializable::deserialize(reader, recursion_depth)?,
                Deserializable::deserialize(reader, recursion_depth)?,
            )),
            discriminant => Err(std::io::Error::new(
                std::io::ErrorKind::InvalidData,
                format!("unsupported maintenance single update discriminant {discriminant}"),
            )),
        }
    }
}

impl Deserializable for Rv64imContractAction {
    fn deserialize(reader: &mut impl Read, recursion_depth: u32) -> Result<Self, std::io::Error> {
        match u8::deserialize(reader, recursion_depth)? {
            2 => Ok(Self::Maintain(Deserializable::deserialize(reader, recursion_depth)?)),
            discriminant => Err(std::io::Error::new(
                std::io::ErrorKind::InvalidData,
                format!("unsupported contract action discriminant {discriminant}"),
            )),
        }
    }
}

impl Serializable for Rv64imContractVerifierKeyInsertUpdate {
    fn serialize(&self, writer: &mut impl Write) -> Result<(), std::io::Error> {
        Serializable::serialize(&self.address, writer)?;
        Serializable::serialize(&self.counter, writer)?;
        Serializable::serialize(&self.insert, writer)
    }

    fn serialized_size(&self) -> usize {
        Serializable::serialized_size(&self.address)
            + Serializable::serialized_size(&self.counter)
            + Serializable::serialized_size(&self.insert)
    }
}

impl Deserializable for Rv64imContractVerifierKeyInsertUpdate {
    fn deserialize(reader: &mut impl Read, recursion_depth: u32) -> Result<Self, std::io::Error> {
        Ok(Self {
            address: Deserializable::deserialize(reader, recursion_depth)?,
            counter: Deserializable::deserialize(reader, recursion_depth)?,
            insert: Deserializable::deserialize(reader, recursion_depth)?,
        })
    }
}

impl Serializable for Rv64imContractOperationVersionedVerifierKey {
    fn serialize(&self, writer: &mut impl Write) -> Result<(), std::io::Error> {
        match self {
            Self::V3(verifier_key) => {
                Serializable::serialize(&2u8, writer)?;
                Serializable::serialize(verifier_key, writer)
            }
        }
    }

    fn serialized_size(&self) -> usize {
        match self {
            Self::V3(verifier_key) => 1 + Serializable::serialized_size(verifier_key),
        }
    }
}

impl Deserializable for Rv64imContractOperationVersionedVerifierKey {
    fn deserialize(reader: &mut impl Read, recursion_depth: u32) -> Result<Self, std::io::Error> {
        let discriminant = u8::deserialize(reader, recursion_depth)?;
        match discriminant {
            0..=1 => Err(std::io::Error::new(
                std::io::ErrorKind::InvalidData,
                format!("Invalid old discriminant {discriminant}"),
            )),
            2 => Ok(Self::V3(Deserializable::deserialize(reader, recursion_depth)?)),
            _ => Err(std::io::Error::new(
                std::io::ErrorKind::InvalidData,
                format!("Unknown discriminant {discriminant}"),
            )),
        }
    }
}

pub fn build_rv64im_contract_operation_versioned_verifier_key(
    verifier_key: VerifierKey,
) -> Rv64imContractOperationVersionedVerifierKey {
    Rv64imContractOperationVersionedVerifierKey::V3(verifier_key)
}

pub fn build_rv64im_entry_point(entry_point: impl Into<Vec<u8>>) -> Rv64imEntryPointBuf {
    Rv64imEntryPointBuf(entry_point.into())
}

pub fn parse_rv64im_contract_address(bytes: &[u8]) -> Result<Rv64imContractAddress, Rv64imBridgeError> {
    tagged_deserialize(&mut &bytes[..]).map_err(|err| Rv64imBridgeError::ArtifactDecode(err.to_string()))
}

pub fn encode_rv64im_contract_address(address: &Rv64imContractAddress) -> Result<Vec<u8>, Rv64imBridgeError> {
    let mut bytes = Vec::new();
    tagged_serialize(address, &mut bytes).map_err(|err| Rv64imBridgeError::ArtifactEncode(err.to_string()))?;
    Ok(bytes)
}

pub fn parse_rv64im_verifier_key(bytes: &[u8]) -> Result<VerifierKey, Rv64imBridgeError> {
    tagged_deserialize(&mut &bytes[..]).map_err(|err| Rv64imBridgeError::ArtifactDecode(err.to_string()))
}

pub fn build_rv64im_contract_operation_versioned_verifier_key_from_bytes(
    bytes: &[u8],
) -> Result<Rv64imContractOperationVersionedVerifierKey, Rv64imBridgeError> {
    Ok(build_rv64im_contract_operation_versioned_verifier_key(
        parse_rv64im_verifier_key(bytes)?,
    ))
}

pub fn encode_rv64im_contract_operation_versioned_verifier_key(
    verifier_key: &Rv64imContractOperationVersionedVerifierKey,
) -> Result<Vec<u8>, Rv64imBridgeError> {
    let mut bytes = Vec::new();
    tagged_serialize(verifier_key, &mut bytes).map_err(|err| Rv64imBridgeError::ArtifactEncode(err.to_string()))?;
    Ok(bytes)
}

pub fn parse_rv64im_contract_operation_versioned_verifier_key(
    bytes: &[u8],
) -> Result<Rv64imContractOperationVersionedVerifierKey, Rv64imBridgeError> {
    tagged_deserialize(&mut &bytes[..]).map_err(|err| Rv64imBridgeError::ArtifactDecode(err.to_string()))
}

pub fn encode_rv64im_entry_point(entry_point: &Rv64imEntryPointBuf) -> Result<Vec<u8>, Rv64imBridgeError> {
    let mut bytes = Vec::new();
    tagged_serialize(entry_point, &mut bytes).map_err(|err| Rv64imBridgeError::ArtifactEncode(err.to_string()))?;
    Ok(bytes)
}

pub fn parse_rv64im_entry_point(bytes: &[u8]) -> Result<Rv64imEntryPointBuf, Rv64imBridgeError> {
    tagged_deserialize(&mut &bytes[..]).map_err(|err| Rv64imBridgeError::ArtifactDecode(err.to_string()))
}

pub fn build_rv64im_contract_verifier_key_insert(
    entry_point: impl Into<Vec<u8>>,
    verifier_key: Rv64imContractOperationVersionedVerifierKey,
) -> Rv64imContractVerifierKeyInsert {
    Rv64imContractVerifierKeyInsert::new(build_rv64im_entry_point(entry_point), verifier_key)
}

pub fn encode_rv64im_contract_verifier_key_insert(
    insert: &Rv64imContractVerifierKeyInsert,
) -> Result<Vec<u8>, Rv64imBridgeError> {
    let mut bytes = Vec::new();
    tagged_serialize(insert, &mut bytes).map_err(|err| Rv64imBridgeError::ArtifactEncode(err.to_string()))?;
    Ok(bytes)
}

pub fn parse_rv64im_contract_verifier_key_insert(
    bytes: &[u8],
) -> Result<Rv64imContractVerifierKeyInsert, Rv64imBridgeError> {
    tagged_deserialize(&mut &bytes[..]).map_err(|err| Rv64imBridgeError::ArtifactDecode(err.to_string()))
}

pub fn build_rv64im_contract_verifier_key_insert_from_bytes(
    entry_point: impl Into<Vec<u8>>,
    verifier_key_bytes: &[u8],
) -> Result<Rv64imContractVerifierKeyInsert, Rv64imBridgeError> {
    Ok(build_rv64im_contract_verifier_key_insert(
        entry_point,
        build_rv64im_contract_operation_versioned_verifier_key_from_bytes(verifier_key_bytes)?,
    ))
}

pub fn build_rv64im_contract_verifier_key_insert_update(
    address: Rv64imContractAddress,
    counter: u32,
    entry_point: impl Into<Vec<u8>>,
    verifier_key: Rv64imContractOperationVersionedVerifierKey,
) -> Rv64imContractVerifierKeyInsertUpdate {
    Rv64imContractVerifierKeyInsertUpdate::new(
        address,
        counter,
        build_rv64im_contract_verifier_key_insert(entry_point, verifier_key),
    )
}

pub fn build_rv64im_contract_verifier_key_insert_update_from_bytes(
    address_bytes: &[u8],
    counter: u32,
    entry_point: impl Into<Vec<u8>>,
    verifier_key_bytes: &[u8],
) -> Result<Rv64imContractVerifierKeyInsertUpdate, Rv64imBridgeError> {
    Ok(build_rv64im_contract_verifier_key_insert_update(
        parse_rv64im_contract_address(address_bytes)?,
        counter,
        entry_point,
        build_rv64im_contract_operation_versioned_verifier_key_from_bytes(verifier_key_bytes)?,
    ))
}

pub fn encode_rv64im_contract_verifier_key_insert_update(
    update: &Rv64imContractVerifierKeyInsertUpdate,
) -> Result<Vec<u8>, Rv64imBridgeError> {
    let mut bytes = Vec::new();
    tagged_serialize(update, &mut bytes).map_err(|err| Rv64imBridgeError::ArtifactEncode(err.to_string()))?;
    Ok(bytes)
}

pub fn parse_rv64im_contract_verifier_key_insert_update(
    bytes: &[u8],
) -> Result<Rv64imContractVerifierKeyInsertUpdate, Rv64imBridgeError> {
    tagged_deserialize(&mut &bytes[..]).map_err(|err| Rv64imBridgeError::ArtifactDecode(err.to_string()))
}

pub fn build_rv64im_contract_verifier_key_insert_signed_update(
    update: Rv64imContractVerifierKeyInsertUpdate,
) -> Rv64imContractVerifierKeyInsertSignedUpdate {
    Rv64imContractVerifierKeyInsertSignedUpdate::new(update)
}

pub fn build_rv64im_contract_verifier_key_insert_maintain_action(
    signed_update: Rv64imContractVerifierKeyInsertSignedUpdate,
) -> Rv64imContractVerifierKeyInsertMaintainAction {
    Rv64imContractVerifierKeyInsertMaintainAction::new(signed_update)
}

pub fn encode_rv64im_contract_verifier_key_insert_signed_update(
    update: &Rv64imContractVerifierKeyInsertSignedUpdate,
) -> Result<Vec<u8>, Rv64imBridgeError> {
    let mut bytes = Vec::new();
    tagged_serialize(update, &mut bytes).map_err(|err| Rv64imBridgeError::ArtifactEncode(err.to_string()))?;
    Ok(bytes)
}

pub fn parse_rv64im_contract_verifier_key_insert_signed_update(
    bytes: &[u8],
) -> Result<Rv64imContractVerifierKeyInsertSignedUpdate, Rv64imBridgeError> {
    tagged_deserialize(&mut &bytes[..]).map_err(|err| Rv64imBridgeError::ArtifactDecode(err.to_string()))
}

pub fn encode_rv64im_contract_verifier_key_insert_signed_update_bytes(
    update: &Rv64imContractVerifierKeyInsertSignedUpdate,
) -> Result<Vec<u8>, Rv64imBridgeError> {
    update.signed_update_bytes()
}

pub fn parse_rv64im_contract_verifier_key_insert_signed_update_bytes(
    bytes: &[u8],
) -> Result<Rv64imContractVerifierKeyInsertSignedUpdate, Rv64imBridgeError> {
    Rv64imContractVerifierKeyInsertSignedUpdate::from_signed_update_bytes(bytes)
}

pub fn encode_rv64im_contract_verifier_key_insert_maintain_action_bytes(
    action: &Rv64imContractVerifierKeyInsertMaintainAction,
) -> Result<Vec<u8>, Rv64imBridgeError> {
    action.action_bytes()
}

pub fn parse_rv64im_contract_verifier_key_insert_maintain_action_bytes(
    bytes: &[u8],
) -> Result<Rv64imContractVerifierKeyInsertMaintainAction, Rv64imBridgeError> {
    Rv64imContractVerifierKeyInsertMaintainAction::from_action_bytes(bytes)
}
