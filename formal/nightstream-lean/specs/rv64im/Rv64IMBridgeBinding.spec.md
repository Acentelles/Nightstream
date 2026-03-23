# Rv64IMBridgeBinding

## Purpose

Defines the theorem-facing binding between Stage 3 exported prepared steps and
the kernel opening-provenance chains that justify them.

## Binding object

A bridge-binding witness contains:

- one opening-provenance proof package,
- one exported row index,
- one exported Stage 3 row-binding object,
- a proof that the exported row-binding is the row-binding at that index,
- a proof that the prepared step named by the provenance chain is exactly the
  prepared step exported at that row.

## Trace-level condition

`KernelBridgeTraceBound` states:

- the bridge-binding witness list has the same length as the Stage 3 exported
  row-binding list, and
- for every exported Stage 3 row-binding index `j`, the bridge-binding witness
  at index `j` exists and names that same exported row-binding index.

## Required theorem consequence

The interface must prove:

- every prepared step named by a kernel bridge-binding witness is a prepared
  step that is actually exported by Stage 3,
- every exported Stage 3 row-binding index has a bridge-binding witness at that
  same index,
- and at each exported index, the provenance-chain prepared step is exactly the
  prepared step exported by the Stage 3 row-binding at that index.
