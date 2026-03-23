#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FORMAL_DIR="$ROOT/formal/nightstream-lean"
if command -v lake >/dev/null 2>&1; then
  LAKE_BIN="$(command -v lake)"
else
  LAKE_BIN="$HOME/.elan/bin/lake"
fi

cd "$ROOT"

echo "[conformance] regenerate Nightstream CHIP-8 vector fixtures"
cargo run --manifest-path "$FORMAL_DIR/rust-vectors/Cargo.toml" --bin chip8_rust_vectors
echo "[conformance] regenerate Nightstream RV64IM parity fixtures"
cargo run --manifest-path "$FORMAL_DIR/rust-vectors/Cargo.toml" --bin rv64im_rust_vectors

echo "[conformance] run Nightstream Lean regression gate"
cd "$FORMAL_DIR"
"$LAKE_BIN" build
"$LAKE_BIN" exe check

echo "[conformance] verify generated Nightstream artifacts are committed"
artifact_status="$(git status --porcelain --untracked-files=all -- \
  "$FORMAL_DIR/Nightstream/Chip8/Generated/TranscriptVectors.lean" \
  "$FORMAL_DIR/Nightstream/Chip8/Generated/StagedExecutionDigestBundleVectors" \
  "$FORMAL_DIR/Nightstream/Chip8/Generated/ReleaseArtifactVectors" \
  "$FORMAL_DIR/Nightstream/Chip8/Generated/ImportedOpeningTranscriptCases.lean" \
  "$FORMAL_DIR/Nightstream/Chip8/Generated/ImportedReleaseArtifact" \
  "$FORMAL_DIR/Nightstream/Rv64IM/Generated/Cases" \
  "$FORMAL_DIR/Nightstream/Rv64IM/Generated/Index" \
  "$FORMAL_DIR/Nightstream/Rv64IM/Generated/ImportedParityCorpus.lean")"
if [[ -n "$artifact_status" ]]; then
  echo "[conformance] generated Nightstream artifacts are dirty:" >&2
  echo "$artifact_status" >&2
  exit 1
fi

echo "[conformance] all Nightstream Lean↔Rust conformance gates passed"
