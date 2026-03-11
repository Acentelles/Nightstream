#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FORMAL_DIR="$ROOT/formal/superneo-lean"

cd "$ROOT"

echo "[sessions] regenerate Lean neo-fold artifact corpus"
cargo run --manifest-path "$FORMAL_DIR/rust-vectors/Cargo.toml" --bin protocol_artifacts

echo "[sessions] regenerate Lean neo-fold session artifacts"
cargo run --manifest-path "$FORMAL_DIR/rust-vectors/Cargo.toml" --bin session_artifacts

echo "[sessions] build Lean neo-fold refinement validators"
cd "$FORMAL_DIR"
lake build \
  SuperNeo.NeoFoldArtifactValidation \
  SuperNeo.RustRefinement.NeoFoldRefinement \
  SuperNeo.RustRefinement.NeoFoldRefinementInterface \
  SuperNeo.RustRefinement.NeoFoldRelationValidation \
  SuperNeo.RustRefinement.NeoFoldRelationValidationInterface \
  SuperNeo.RustRefinement.NeoFoldStepSemanticValidation \
  SuperNeo.RustRefinement.NeoFoldStepSemanticValidationInterface \
  ValidateNeoFoldRefinement \
  ValidateNeoFoldRelations \
  ValidateNeoFoldStepSemantics \
  SuperNeo.RustRefinement.NeoFoldSessionValidation \
  SuperNeo.RustRefinement.NeoFoldSessionValidationInterface \
  ValidateNeoFoldSessions

echo "[sessions] run Lean neo-fold artifact refinement validator"
lake exe validate-neo-fold-refinement

echo "[sessions] run Lean neo-fold relation validator"
lake exe validate-neo-fold-relations

echo "[sessions] run Lean neo-fold step-semantics validator"
lake exe validate-neo-fold-step-semantics

echo "[sessions] run Lean session refinement validator"
lake exe validate-neo-fold-sessions

cd "$ROOT"

echo "[sessions] verify generated neo-fold refinement artifacts are committed"
artifact_status="$(git status --porcelain --untracked-files=all -- \
  "$FORMAL_DIR/SuperNeo/Generated/NeoFoldArtifacts.lean" \
  "$FORMAL_DIR/SuperNeo/Generated/NeoFoldSessions.lean")"
if [[ -n "$artifact_status" ]]; then
  echo "[sessions] generated neo-fold refinement artifacts are dirty:" >&2
  echo "$artifact_status" >&2
  exit 1
fi

echo "[sessions] neo-fold refinement gates passed"
