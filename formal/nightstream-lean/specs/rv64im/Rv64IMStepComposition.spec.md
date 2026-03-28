# Rv64IMStepComposition Spec

## Purpose

- **What it is**: The central execution proof owner that composes stage-local RV64IM bounds into opcode-class execution-correctness packages.
- **What it is not**: It is not the stage-local definition of fetch, Twist, or continuity, and it does not own transcript logic.
- **Protocol role**: It packages the exact proof inventory needed to discharge committed-sequence correctness for each supported opcode class.

## Opcode-Class Order

The canonical opcode-class order is:

1. `nativeAlu`
2. `wordShift`
3. `controlFlow`
4. `narrowMemory`
5. `multiply`
6. `unsignedDivRem`
7. `signedDivRem`

`OpcodeProofsOrdered(proofs)` means the proof list matches that exact order.

## Central Package

`StepCompositionProofPackage` packages:

- bytecode fetch/decode binding,
- execution-row binding,
- the theorem-facing equality that the authenticated execution row is the same
  decoded Stage-1 row consumed by fetch/decode binding,
- register history projection,
- RAM history projection,
- concrete Twist linkage,
- Stage-3 continuity package,
- committed-sequence correctness,
- advice-sequence correctness,
- temporary-register hygiene,
- one global execution-semantics package,
- opcode-class proof packages in canonical order,
- exact decoded-row/opcode binding for the word-shift family,
- unsigned and signed DIV/REM theorem packages.
- exact decoded-row/opcode binding for the unsigned and signed DIV/REM families.

Each `OpcodeClassProof` carries:

- the opcode class it proves,
- an `ExecutionSemanticsProofPackage`,
- a theorem that every row in that package belongs to that opcode class.

In addition, the package carries one fixed family-level committed/advice
sequence proof package for each canonical opcode family:

- `nativeAlu`
- `wordShift`
- `controlFlow`
- `narrowMemory`
- `multiply`
- `unsignedDivRem`
- `signedDivRem`

## Derived Consequences

From a `StepCompositionProofPackage` one must be able to extract:

- committed-sequence determinism,
- advice-sequence determinism,
- execution correctness for each opcode-class proof,
- the exact concrete Twist binding package for the authenticated register/RAM lanes,
- the exact Stage-2 linkage batch for those lanes,
- the register-only and RAM-only linkage consequences,
- the authenticated register write-value consequence on active register writes,
- the authenticated RAM load-value consequence on active loads,
- the authenticated RAM store-payload consequence on active stores,
- the authenticated zero-row RAM `memVal = 0` consequence on inactive RAM rows,
- exact opcode-proof ordering,
- the canonical proof object for each opcode class in the fixed order,
- the fixed committed/advice sequence proof package for each canonical opcode family,
- for any row inside an opcode-class proof, a theorem that the row’s `opcodeClass` agrees with that proof’s class,
- the exact Stage-1 linkage package for the authenticated execution row,
- the exact equality `executionRow.row = decodedRow`,
- the authenticated taken-target alignment discharge for the execution row,
- the authenticated Stage-1 unsigned no-overflow support relation,
- the exact native-ALU opcode write contract, including the `rd = x0` sink case
  and the non-`x0` active/passive architectural write split,
- the exact multiply opcode write contract, including the `rd = x0` sink case,
- the Stage-1 to Stage-2 register-write activation bridge from
  `writesAluToRd ∨ writesMemToRd` to `registerLane.writesRd`,
- the theorem-facing representation bridge from Stage-1 `ALU_OUT` as a `Word`
  to the authenticated Stage-2 limb pair used for routed writeback,
- the full theorem-facing word/limb representation isomorphism needed to move
  exact arithmetic claims back and forth between Stage-1 `Word` values and the
  authenticated Stage-2 limb-pair representation,
- theorem-facing encoded native-ALU and multiply operator inventories,
- theorem-facing word-level native-ALU and multiply operator inventories,
- the exact compatibility boundary stating that the theorem-facing native-ALU
  and multiply word operators encode to the same authenticated limb-pair
  operators carried by the routed writeback surface,
- the exact encoded native-ALU result boundary from opcode, authenticated
  operands, encoded immediate / `pc`, and routed encoded writeback,
- the exact encoded multiply result boundary from opcode, authenticated
  operands, and routed encoded writeback,
- the exact limb-level writeback-routing boundary matching the kernel row-local
  equations:
  `writesAluToRd -> rdNext = aluWritebackValue`,
  `writesMemToRd -> rdNext = memVal`,
  `preservesRd -> rdNext = 0`,
- the exact encoded ALU-output equalities
  `wordToLimbPair(executionRow.lane.aluOut) = aluWritebackValue` and
  `wordToLimbPair(executionRow.results.aluResult) = aluWritebackValue`,
- the authenticated register read-value equalities
  `rvRs1 = rs1` and `rvRs2 = rs2`,
- the authenticated routed ALU writeback consequence
  `wvReg = aluWritebackValue` on active ALU writes,
- the authenticated routed memory writeback consequence
  `wvReg = memVal` on active memory-to-rd writes,
- the exact helper proof packages for narrow loads and narrow stores,
- the exact helper-result bridge from authenticated aligned-word inputs to
  `wordToNat(executionRow.results.aluResult)` through `extractExtend`,
- the exact helper-result bridge from authenticated aligned-word input plus
  authenticated `RS2` to `wordToNat(executionRow.results.aluResult)` through
  `blend`,
- theorem-facing native aligned-memory opcode inventories for `LD` and `SD`,
- exact decoded-row flag agreement for those native aligned-memory opcodes,
- the theorem-facing decoded-row to RAM-lane role bridge
  `ramLane.isLoad = decodedRow.isLoad` and
  `ramLane.isStore = decodedRow.isStore`,
- the exact native aligned-memory architectural write contract, including the
  `rd = x0` sink case for `LD` and the passive architectural write split for
  `SD`,
- the theorem-facing word-shift ALU-role descriptor,
- the exact word-shift decoded-row/opcode binding,
- the exact seven-proof canonical decomposition of the opcode-proof list,
- temporary-register hygiene,
- the unsigned no-overflow guard,
- unsigned DIV/REM soundness,
- unsigned DIV/REM decoded-row opcode binding,
- unsigned DIV/REM determinism,
- signed DIV/REM decoded-row opcode binding,
- signed divisor-adjustment correctness,
- dividend-sign remainder reconstruction,
- signed DIV/REM soundness.

The resulting theorem-facing surface is the input boundary for the dedicated
execution-level family owners:

- `Rv64IMNativeAluSemantics`
- `Rv64IMWordShiftSemantics`
- `Rv64IMControlFlowSemantics`
- `Rv64IMNarrowMemorySemantics`
- `Rv64IMMultiplySemantics`
- `Rv64IMUnsignedDivRemSemantics`
- `Rv64IMSignedDivRemSemantics`

In particular the theorem-facing surface must let consumers extract, from one package, the proof
objects for:

1. `nativeAlu`
2. `wordShift`
3. `controlFlow`
4. `narrowMemory`
5. `multiply`
6. `unsignedDivRem`
7. `signedDivRem`

and the module must expose one theorem whose witness fixes the exact list shape

`[nativeAlu, wordShift, controlFlow, narrowMemory, multiply, unsignedDivRem, signedDivRem]`.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Execution/StepComposition.lean` | Opcode-class composition and derived execution consequences |
| `Nightstream/Rv64IM/Execution/StepCompositionInterface.lean` | Theorem-facing re-export surface |

## Proof Obligations

- The opcode-class theorem order is fixed and not prover-chosen.
- Word-shift proofs include the corrected `SRAW/SRAIW` semantics.
- The exact word-shift opcode bound is surfaced at the same theorem layer as
  the unsigned and signed DIV/REM opcode bounds; it may not be hidden only
  inside later family, trace, or kernel wrappers.
- Control-flow proofs include taken-target alignment.
- Narrow-memory proofs consume the exact helper relations from `NarrowMemoryHelpers`.
- Unsigned DIV/REM proofs include the `MULU_NO_OVERFLOW` guard.
- Signed DIV/REM proofs include `CHANGE_DIVISOR` and dividend-sign remainder reconstruction.
- Stage-2 linkage is surfaced at the same theorem layer as Stage-1 linkage; it is not hidden behind trace-only or kernel-only wrappers.
- The fixed per-family committed/advice sequence proof packages are surfaced at
  the same theorem layer as opcode-class execution correctness; they may not be
  hidden only inside later family, trace, or kernel wrappers.
- Register-write activation is surfaced at the same theorem layer as opcode
  write contracts; later execution, trace, and kernel owners may rely on it to
  justify authenticated architectural writeback, but may not silently assume it.
- The exact row-local writeback-routing equalities from `riscv-kernel.md`
  (`RD_NEXT = ALU_OUT`, `RD_NEXT = MEM_VAL`, `RD_NEXT = 0`) must remain
  theorem-visible at the same layer as Stage-1 and Stage-2 linkage, not hidden
  behind later execution, trace, or kernel wrappers.
- The row-local `ALU_OUT_LO/HI` binding from `riscv-kernel.md` must remain
  theorem-visible through an explicit theorem-facing representation bridge from
  Stage-1 `ALU_OUT : Word` to the authenticated routed Stage-2 limb pair; later
  owners may not treat `aluWritebackValue` as an opaque unrelated witness.
- The representation bridge must be strong enough to recover both directions:
  `limbPairToWord (wordToLimbPair w) = w` and
  `wordToLimbPair (limbPairToWord p) = p`; later execution, trace, and kernel
  owners may rely on injectivity and exact decoding, but may not assume them
  without this theorem-facing boundary.
- The theorem-facing surface must also expose the encoded arithmetic target
  chosen by the exact native-ALU and multiply opcode together with the
  authenticated operands; later owners may not invent that encoded operator
  layer outside `Rv64IMStepComposition`.
- The theorem-facing surface must also expose the exact word-level operator
  inventories and their compatibility with the authenticated encoded operators;
  later owners may not invent a separate word-level arithmetic evaluator
  outside `Rv64IMStepComposition`.
- The theorem-facing surface must also expose the exact Stage-1 helper proof
  packages and the exact helper-result bridge from authenticated aligned-word
  inputs to `executionRow.results.aluResult`; later execution, trace, and
  kernel owners may not silently assume the `extractExtend` / `blend`
  equalities without this boundary.
- The theorem-facing surface must also expose the native aligned-memory
  decoded-row to RAM-lane role bridge and the native `LD` / `SD`
  architectural write contract; later execution, trace, and kernel owners may
  not silently assume that `ramLane.isLoad` / `ramLane.isStore` match the
  decoded row or that `LD` / `SD` satisfy the row-local write-routing
  equations without this boundary.

## Out of Scope

- transcript schedule
- bridge opening provenance
- kernel-level soundness accounting
