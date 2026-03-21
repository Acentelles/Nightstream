# Chip8RootHandoffContext Spec

## Purpose

- **What it is**: the theorem-facing imported root-handoff context used by the
  CHIP-8 kernel when exporting prepared steps.
- **Key property**: `RootHandoffContextBound`.
- **Protocol role**: this owner makes the imported root encoding /
  Ajtai-commitment context explicit and binds it to the public `root_params_id`
  already fixed in `meta_pub`. It does not re-own the canonical root encoding
  theorem.

## Target Formulas

Define:

$$
\mathrm{RootHandoffContext}
:=
(\mathrm{rootParamsId}, \mathrm{RootEncode}, \mathrm{AjtaiCommit}).
$$

For one public CHIP-8 kernel input bundle `inputs`, define:

$$
\mathrm{RootHandoffContextBound}(inputs, rootCtx)
$$

to mean:

- `rootCtx.rootParamsId = inputs.pubMeta.rootParamsId`
- `RootParamsBound(inputs.rootParamsOf, inputs.pubMeta, inputs.publicInput.vmSpec)`

This is the exact theorem-facing binding imported by kernel export, digest, and
audit surfaces. Any kernel theorem surface that depends on prepared-step export
must depend on one explicit `RootHandoffContext`, not on hidden caller-chosen
`RootEncode` / `AjtaiCommit` functions.

## Ownership

This owner fixes:

- the exact imported root-handoff context shape;
- the exact theorem-facing relation tying that context to public
  `root_params_id`;
- the rule that kernel-facing theorem surfaces use the explicit context rather
  than raw free function parameters.

This owner does **not** fix:

- the canonical root witness encoding theorem itself;
- the root prover's internal commitment implementation;
- any root-owned opening boundary beyond the simple kernel handoff.
