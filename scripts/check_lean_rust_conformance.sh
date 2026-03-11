#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FORMAL_DIR="$ROOT/formal/superneo-lean"

cd "$ROOT"

echo "[conformance] regenerate Lean vector fixtures"
cargo run --manifest-path "$FORMAL_DIR/rust-vectors/Cargo.toml" --bin superneo-rust-vectors

echo "[conformance] regenerate Lean protocol artifacts"
cargo run --manifest-path "$FORMAL_DIR/rust-vectors/Cargo.toml" --bin protocol_artifacts

echo "[conformance] export Lean-authored JSON oracles"
cd "$FORMAL_DIR"
lake exe export-oracles

echo "[conformance] build Lean formalization"
lake build

echo "[conformance] run Lean regression gate"
lake exe check

echo "[conformance] run Lean protocol artifact validation"
lake env lean --run ValidateProtocolArtifacts.lean

echo "[conformance] run Lean neo-fold artifact validation"
lake env lean --run ValidateNeoFoldArtifacts.lean

cd "$ROOT"

echo "[conformance] run Rust release oracle tests"
cargo test -p neo-math --release --test lean_oracles
cargo test -p neo-ajtai --release --test lean_oracles
cargo test -p neo-ccs --release --test lean_oracles

echo "[conformance] audit Lean sources"
bash "$ROOT/scripts/audit_formal_lean.sh"

echo "[conformance] verify generated artifacts are committed"
artifact_status="$(git status --porcelain --untracked-files=all -- \
  "$FORMAL_DIR/SuperNeo/Generated/Vectors.lean" \
  "$FORMAL_DIR/SuperNeo/Generated/Cases.lean" \
  "$FORMAL_DIR/SuperNeo/Generated/ProtocolArtifacts.lean" \
  "$FORMAL_DIR/SuperNeo/Generated/NeoFoldArtifacts.lean" \
  "$FORMAL_DIR/generated-oracles")"
if [[ -n "$artifact_status" ]]; then
  echo "[conformance] generated artifacts are dirty:" >&2
  echo "$artifact_status" >&2
  exit 1
fi

echo "[conformance] all Lean↔Rust conformance gates passed"
