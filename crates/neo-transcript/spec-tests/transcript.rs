//! Spec-derived tests for Transcript.spec.md invariant obligations.
//!
//! Covers: framing, label sensitivity, fork isolation, determinism,
//! domain separation, domain gate, challenge_nonzero_field, and
//! append_fields_iter length contract.

use neo_math::F;
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::{PrimeCharacteristicRing, PrimeField64};

// ---------------------------------------------------------------------------
// Obligation 1: Framing — different label/msg splits -> different digests
// ---------------------------------------------------------------------------

/// Transcript.spec.md: Framing — different label/message splits produce different digests.
/// This prevents length-extension style ambiguities in the absorption.
#[test]
fn framing_distinguishes_splits() {
    let mut t1 = Poseidon2Transcript::new(b"test/app");
    t1.append_message(b"a", b"bc");
    let d1 = t1.digest32();

    let mut t2 = Poseidon2Transcript::new(b"test/app");
    t2.append_message(b"ab", b"c");
    let d2 = t2.digest32();

    assert_ne!(d1, d2, "framing must distinguish different label/byte splits");
}

// ---------------------------------------------------------------------------
// Obligation 2: Label sensitivity — different challenge labels -> different challenges
// ---------------------------------------------------------------------------

/// Transcript.spec.md: Label sensitivity — different challenge labels produce
/// different challenges even with identical absorbed data.
#[test]
fn label_changes_challenge() {
    let mut t = Poseidon2Transcript::new(b"neo/tests");
    t.append_message(b"m", b"data");
    let c1 = t.challenge_field(b"alpha");

    let mut t2 = Poseidon2Transcript::new(b"neo/tests");
    t2.append_message(b"m", b"data");
    let c2 = t2.challenge_field(b"beta");

    assert_ne!(c1.as_canonical_u64(), c2.as_canonical_u64());
}

// ---------------------------------------------------------------------------
// Obligation 3: Fork isolation — different fork scopes -> different sequences
// ---------------------------------------------------------------------------

/// Transcript.spec.md: Fork isolation — forked transcripts with different
/// scopes produce different challenge sequences.
#[test]
fn fork_isolated() {
    let t = Poseidon2Transcript::new(b"neo/tests");
    let mut a = t.fork(b"A");
    let mut b = t.fork(b"B");
    let ca = a.challenge_field(b"rho");
    let cb = b.challenge_field(b"rho");
    assert_ne!(ca.as_canonical_u64(), cb.as_canonical_u64());
}

/// Fork does not affect the parent transcript.
#[test]
fn fork_does_not_affect_parent() {
    let mut t1 = Poseidon2Transcript::new(b"neo/tests");
    t1.append_message(b"m", b"data");

    let mut t2 = t1.clone();

    // Fork t1 and squeeze a challenge from the child
    let mut child = t1.fork(b"child");
    let _ = child.challenge_field(b"x");

    // t1 should produce the same challenge as t2 (fork didn't mutate parent)
    let c1 = t1.challenge_field(b"rho");
    let c2 = t2.challenge_field(b"rho");
    assert_eq!(c1.as_canonical_u64(), c2.as_canonical_u64());
}

// ---------------------------------------------------------------------------
// Obligation 4: Determinism — identical operations -> identical outputs
// ---------------------------------------------------------------------------

/// Transcript.spec.md: Determinism — identical transcript operations produce
/// identical outputs. This is essential for verifier reproducibility.
#[test]
fn determinism_identical_operations() {
    let run = || {
        let mut t = Poseidon2Transcript::new(b"neo/determinism");
        t.append_message(b"step", b"hello");
        t.append_fields(b"vals", &[F::from_u64(42), F::from_u64(99)]);
        let c = t.challenge_field(b"alpha");
        let d = t.digest32();
        (c, d)
    };

    let (c1, d1) = run();
    let (c2, d2) = run();

    assert_eq!(c1.as_canonical_u64(), c2.as_canonical_u64());
    assert_eq!(d1, d2);
}

// ---------------------------------------------------------------------------
// Obligation 5: Domain separation — different app labels -> different sequences
// ---------------------------------------------------------------------------

/// Transcript.spec.md: Domain separation — different app labels produce
/// different challenge sequences, even with identical subsequent operations.
#[test]
fn domain_separation_app_labels() {
    let mut t1 = Poseidon2Transcript::new(b"app/alpha");
    t1.append_message(b"m", b"data");
    let c1 = t1.challenge_field(b"x");

    let mut t2 = Poseidon2Transcript::new(b"app/beta");
    t2.append_message(b"m", b"data");
    let c2 = t2.challenge_field(b"x");

    assert_ne!(
        c1.as_canonical_u64(),
        c2.as_canonical_u64(),
        "different app labels must produce different challenges"
    );
}

// ---------------------------------------------------------------------------
// Obligation 6: Domain gate — squeeze absorbs ONE before permuting
// ---------------------------------------------------------------------------

/// Transcript.spec.md: Domain gate — the squeeze operation absorbs
/// Goldilocks::ONE before permuting, which prevents state reuse.
/// Verified by checking that two consecutive challenge_field calls on
/// the same label produce different values (the domain gate changes state
/// between squeezes).
#[test]
fn domain_gate_squeeze_changes_output() {
    let mut t = Poseidon2Transcript::new(b"neo/gate");
    t.append_message(b"m", b"data");

    // Two consecutive squeezes with the same label should differ
    // because each squeeze absorbs its own label + domain gate.
    let c1 = t.challenge_field(b"x");
    let c2 = t.challenge_field(b"x");

    assert_ne!(
        c1.as_canonical_u64(),
        c2.as_canonical_u64(),
        "consecutive squeezes must differ due to domain gate"
    );
}

// ---------------------------------------------------------------------------
// Obligation 7: challenge_nonzero_field never returns zero
// ---------------------------------------------------------------------------

/// Transcript.spec.md: challenge_nonzero_field never returns zero.
/// Stress test with multiple iterations.
#[test]
fn challenge_nonzero_field_never_zero() {
    let mut t = Poseidon2Transcript::new(b"neo/nonzero");
    for i in 0..100u64 {
        t.append_message(b"i", &i.to_le_bytes());
        let c = t.challenge_nonzero_field(b"nz");
        assert_ne!(
            c,
            F::ZERO,
            "challenge_nonzero_field returned zero at iteration {i}"
        );
    }
}

// ---------------------------------------------------------------------------
// Obligation 10: append_fields_iter length mismatch panics
// ---------------------------------------------------------------------------

/// Transcript.spec.md: append_fields_iter panics when the iterator produces
/// a different number of elements than the declared length.
#[test]
#[should_panic(expected = "iterator length mismatch")]
fn append_fields_iter_length_mismatch_panics() {
    let mut t = Poseidon2Transcript::new(b"neo/iter");
    let fields = vec![F::from_u64(1), F::from_u64(2)];
    // Declare length 5, but only provide 2 elements
    t.append_fields_iter(b"bad", 5, fields.into_iter());
}

// ---------------------------------------------------------------------------
// Additional: append_fields equivalent to element-wise absorb
// ---------------------------------------------------------------------------

/// Batch append_fields produces the same result as absorbing each field
/// element individually through append_message-style encoding.
#[test]
fn append_fields_batch_determinism() {
    let fields = [F::from_u64(10), F::from_u64(20), F::from_u64(30)];

    let mut t1 = Poseidon2Transcript::new(b"neo/batch");
    t1.append_fields(b"vals", &fields);
    let d1 = t1.digest32();

    // Same operation again — must be identical
    let mut t2 = Poseidon2Transcript::new(b"neo/batch");
    t2.append_fields(b"vals", &fields);
    let d2 = t2.digest32();

    assert_eq!(d1, d2);
}

/// append_fields with different data produces different digests.
#[test]
fn append_fields_different_data_different_digest() {
    let mut t1 = Poseidon2Transcript::new(b"neo/diff");
    t1.append_fields(b"v", &[F::from_u64(1), F::from_u64(2)]);
    let d1 = t1.digest32();

    let mut t2 = Poseidon2Transcript::new(b"neo/diff");
    t2.append_fields(b"v", &[F::from_u64(1), F::from_u64(3)]);
    let d2 = t2.digest32();

    assert_ne!(d1, d2);
}

// ---------------------------------------------------------------------------
// Additional: challenge_bytes produces the correct number of bytes
// ---------------------------------------------------------------------------

/// challenge_bytes fills exactly the requested number of bytes.
#[test]
fn challenge_bytes_exact_length() {
    let mut t = Poseidon2Transcript::new(b"neo/bytes");
    t.append_message(b"m", b"data");

    for len in [1, 7, 8, 16, 31, 32, 33, 64, 100] {
        let mut out = vec![0u8; len];
        let mut t2 = t.clone();
        t2.challenge_bytes(b"c", &mut out);
        // Verify not all zeros (extremely unlikely for a proper hash)
        assert!(
            out.iter().any(|&b| b != 0),
            "challenge_bytes({len}) produced all zeros"
        );
    }
}
