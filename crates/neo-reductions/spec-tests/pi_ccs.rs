//! Spec-derived invariant tests for PiCCS.spec.md
//!
//! Each test corresponds to a row in the Invariant Obligations table.
//! Full prove/verify roundtrips are covered by existing integration tests.

#[path = "common/mod.rs"]
mod common;

use neo_math::K;
use neo_reductions::error::PiCcsError;
use neo_reductions::pi_ccs::FoldingMode;
use p3_field::PrimeCharacteristicRing;

// ---------------------------------------------------------------------------
// 1. FoldingMode variants exist
// ---------------------------------------------------------------------------

/// PiCCS.spec.md: FoldingMode enum has expected variants
#[test]
fn folding_mode_variants_exist() {
    let _optimized = FoldingMode::Optimized;
    let _debug = format!("{_optimized:?}");

    #[cfg(feature = "paper-exact")]
    {
        let _paper_exact = FoldingMode::PaperExact;
    }
}

// ---------------------------------------------------------------------------
// 2. PiCcsError variants carry context
// ---------------------------------------------------------------------------

/// PiCCS.spec.md: PiCcsError provides context strings
#[test]
fn error_variants_have_context() {
    let err = PiCcsError::InvalidInput("test context".into());
    let msg = format!("{err}");
    assert!(msg.contains("test context"), "error should contain context: {msg}");

    let err2 = PiCcsError::SumcheckError("sc context".into());
    let msg2 = format!("{err2}");
    assert!(msg2.contains("sc context"), "error should contain context: {msg2}");

    let err3 = PiCcsError::ProtocolError("proto context".into());
    let msg3 = format!("{err3}");
    assert!(msg3.contains("proto context"), "error should contain context: {msg3}");

    let err4 = PiCcsError::ExtensionPolicyFailed("ext context".into());
    let msg4 = format!("{err4}");
    assert!(msg4.contains("ext context"), "error should contain context: {msg4}");

    let err5 = PiCcsError::TranscriptError("tr context".into());
    let msg5 = format!("{err5}");
    assert!(msg5.contains("tr context"), "error should contain context: {msg5}");
}

// ---------------------------------------------------------------------------
// 3. Challenges struct fields
// ---------------------------------------------------------------------------

/// PiCCS.spec.md: Challenges struct has expected fields
#[test]
fn challenges_struct_fields() {
    let c = neo_reductions::Challenges {
        alpha: vec![K::ZERO; 2],
        beta_a: vec![K::ZERO; 2],
        beta_r: vec![K::ZERO; 3],
        beta_m: vec![K::ZERO; 1],
        gamma: K::ONE,
    };

    assert_eq!(c.alpha.len(), 2);
    assert_eq!(c.beta_a.len(), 2);
    assert_eq!(c.beta_r.len(), 3);
    assert_eq!(c.beta_m.len(), 1);
    assert_eq!(c.gamma, K::ONE);
}

// ---------------------------------------------------------------------------
// 4. PiCcsProof construction
// ---------------------------------------------------------------------------

/// PiCCS.spec.md: PiCcsProof can be constructed
#[test]
fn proof_construction() {
    let proof = neo_reductions::PiCcsProof::new(vec![], None);
    // Verify it has expected fields accessible
    assert!(proof.sumcheck_rounds.is_empty());
}
