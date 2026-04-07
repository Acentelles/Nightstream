---
name: multi-ai-council
description: Use when the user wants a hard question, proposal, design, review, tradeoff analysis, or difficult debugging problem answered by a council of Claude, Codex, and Gemini through this repo's local multi-ai CLI. Trigger for requests like "ask multiple AIs", "use the council", "get another model's take", "high-confidence review", "difficult question", or "compare top models on this".
---

# Multi-AI Council

Use this skill when one model's answer is not enough and the user would benefit from a multi-model pass.

This repo already provides the real execution entrypoint:

- `multi-ai`

The default base path is the current working directory. That means the council naturally runs against the repo or folder you invoke it from.

## When to use it

Prefer this skill for:

- difficult architecture or design tradeoffs
- proposal/spec review
- high-stakes correctness or soundness questions
- bug analysis where multiple perspectives are useful
- "ask Claude, Codex, and Gemini" style requests

Do not use it for:

- trivial factual questions
- simple rewrites
- tasks where the overhead of a council would dominate the value

## First decision: `run` mode vs `review` mode

The most important choice is the worker mode, not the preset.

Use `--mode run` when you want open-ended answers:

- architecture questions
- design tradeoffs
- brainstorming
- explanation or synthesis
- "what is the best approach?" style prompts

In `run` mode, providers answer freely in text and the leader synthesizes.

Use `--mode review` when you want concrete issues:

- code review
- spec review
- proposal review
- soundness/risk review
- "find problems, fake progress, missing invariants, or correctness holes"

In `review` mode, providers return structured findings, the council merges and deduplicates them, and the leader synthesizes from that findings set.

Short mental model:

- `--mode run` = ask several models, then synthesize
- `--mode review` = ask several models for findings, merge them, optionally debate them, then synthesize

## Debate

If you specifically want debate, use `--mode review --debate`.

Important current behavior:

- real debate runs in `review` mode
- do not rely on `--debate` in `run` mode for the same behavior

So:

- open-ended hard question: `--mode run`
- review/findings/risk pass: `--mode review`
- review with actual debate: `--mode review --debate`

## Presets

- `fast`: quick pass; best for exploratory `--mode run`
- `default`: normal general-purpose pass
- `review`: good default preset for `--mode review`
- `rigor`: use for the hardest review questions when extra rigor is worth the time

Presets tune the pass. Modes change the worker contract. Do not confuse them.

## Workflow

1. Choose the mode first:
   - `--mode run` for open-ended answers
   - `--mode review` for findings
2. Choose the preset that matches the depth you want.
3. Run `multi-ai` from the current workspace:

```bash
multi-ai run --mode review --preset review "Review this proposal for correctness and soundness."
```

4. Read the JSON or final text output.
5. Summarize the leader answer for the user.
6. If useful, call out disagreements, merged findings, or notable worker failures.

## Notes

- The council uses the local `multi-ai` CLI, not direct API calls.
- The final answer comes from the configured leader after the worker phase.
- The CLI entrypoint is still `multi-ai run`; the choice is `--mode run` vs `--mode review`.
- If the user wants raw worker outputs too, prefer `--json` and inspect the `providers` object.

## Examples

General hard question:

```bash
multi-ai run --mode run --preset default "What is the best architecture for this feature?"
```

Spec review:

```bash
multi-ai run --mode review --preset review "Review tmp/spec.md for correctness, soundness, and missing edge cases."
```

Review with actual debate:

```bash
multi-ai run --mode review --preset rigor --debate --json "Review this design in detail."
```
