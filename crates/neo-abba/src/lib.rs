#![forbid(unsafe_code)]
#![allow(missing_docs)]
#![cfg_attr(docsrs, feature(doc_auto_cfg))]

//! neo-abba: ABBA commitment scheme from commutators of quaternions.
//!
//! Drop-in replacement for neo-ajtai. Achieves 25% commitment size reduction
//! by exploiting the traceless subspace T_0 of the quaternion algebra.

pub mod commit;
pub mod decomp;
pub mod error;
pub mod s_module;
pub mod types;

pub use commit::{
    commit, s_lincomb, s_mul, s_mul_add, scale_commitment, scale_commitment_add_inplace, setup, try_commit,
    verify_open, verify_split_open,
};
pub use decomp::{assert_range_b, decomp_b, split_b, DecompStyle};
pub use error::{AbbaError, AbbaResult};
pub use s_module::AbbaSModule;
pub use types::{Commitment, PP};
