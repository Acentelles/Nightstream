import SuperNeo.Thm3Core
import SuperNeo.ArithmeticObligations

/-!
Protocol-target layer.

This module binds Theorem-3 and arithmetic obligations into one target context,
then derives the core target proposition used by protocol relations.
-/

namespace SuperNeo

/-- Core protocol target context used by relation/reduction layers. -/
structure ProtocolTargetContext where
  bar : Array (Array F)
  m : Array (Array F)
  r : Array F
  rho1 : F
  rho2 : F
  hVec : VecModuleHom
  hScal : ScalarModuleHom
  splitScalar : F
  kSplit : Nat
  invDelta : Coeffs
  cset : Array Coeffs
  samples : Array Coeffs
  xs : Array F
  ys : Array F
  qVals : Array F
  coeffs : Array F
  xEval : F
  expectedEval : F

/-- Assumption bundle for protocol-target derivation. -/
structure ProtocolTargetAssumptions (ctx : ProtocolTargetContext) where
  thm3 : thm3CoreAssumption ctx.bar
  arithmetic : ArithmeticObligations
    ctx.bar ctx.m ctx.r ctx.rho1 ctx.rho2
    ctx.hVec ctx.hScal
    ctx.splitScalar ctx.kSplit
    ctx.invDelta ctx.cset ctx.samples
    ctx.xs ctx.ys ctx.qVals ctx.coeffs
    ctx.xEval ctx.expectedEval
  invDeltaInvertible : invertibleRq ctx.invDelta

/--
Native protocol-target assumptions.

This variant closes Theorem-3 through the canonical native bar matrix and does
not require an explicit `thm3CoreAssumption` field.
-/
structure ProtocolTargetNativeAssumptions (ctx : ProtocolTargetContext) where
  barNative : ctx.bar = nativeBarMatrix
  arithmetic : ArithmeticObligations
    ctx.bar ctx.m ctx.r ctx.rho1 ctx.rho2
    ctx.hVec ctx.hScal
    ctx.splitScalar ctx.kSplit
    ctx.invDelta ctx.cset ctx.samples
    ctx.xs ctx.ys ctx.qVals ctx.coeffs
    ctx.xEval ctx.expectedEval
  invDeltaInvertible : invertibleRq ctx.invDelta

/--
Compatibility constructor: derive protocol-target assumptions from a low-norm
invertibility boundary and the arithmetic invertibility window.
-/
def ProtocolTargetAssumptions.of_lowNormBoundary
  {ctx : ProtocolTargetContext}
  (thm3 : thm3CoreAssumption ctx.bar)
  (arithmetic : ArithmeticObligations
    ctx.bar ctx.m ctx.r ctx.rho1 ctx.rho2
    ctx.hVec ctx.hScal
    ctx.splitScalar ctx.kSplit
    ctx.invDelta ctx.cset ctx.samples
    ctx.xs ctx.ys ctx.qVals ctx.coeffs
    ctx.xEval ctx.expectedEval)
  (hLowNorm : lowNormInvertibilityAssumption Goldilocks.halfQ) :
  ProtocolTargetAssumptions ctx where
  thm3 := thm3
  arithmetic := arithmetic
  invDeltaInvertible :=
    invertibleRq_of_lowNormAssumption hLowNorm arithmetic.invertibilityWindow

/--
Compatibility constructor: derive native protocol-target assumptions from a
low-norm invertibility boundary and the arithmetic invertibility window.
-/
def ProtocolTargetNativeAssumptions.of_lowNormBoundary
  {ctx : ProtocolTargetContext}
  (barNative : ctx.bar = nativeBarMatrix)
  (arithmetic : ArithmeticObligations
    ctx.bar ctx.m ctx.r ctx.rho1 ctx.rho2
    ctx.hVec ctx.hScal
    ctx.splitScalar ctx.kSplit
    ctx.invDelta ctx.cset ctx.samples
    ctx.xs ctx.ys ctx.qVals ctx.coeffs
    ctx.xEval ctx.expectedEval)
  (hLowNorm : lowNormInvertibilityAssumption Goldilocks.halfQ) :
  ProtocolTargetNativeAssumptions ctx where
  barNative := barNative
  arithmetic := arithmetic
  invDeltaInvertible :=
    invertibleRq_of_lowNormAssumption hLowNorm arithmetic.invertibilityWindow

/-- Protocol-target proposition (compact protocol-math-target style surface). -/
def protocolTargetProp (ctx : ProtocolTargetContext) : Prop :=
  thm3CoreAssumption ctx.bar ∧
  splitBase2TerminalZeroProp ctx.splitScalar ctx.kSplit ∧
  evalHomAssumption ctx.bar ctx.m ctx.r ctx.rho1 ctx.rho2 ∧
  vecModuleAssumption ctx.hVec ∧
  scalarModuleAssumption ctx.hScal ∧
  samplingExpansionProp ctx.cset ctx.samples ∧
  ctx.qVals.size = (2 ^ ctx.r.size) ∧
  mleEval ctx.qVals ctx.r = mleInnerProductForm ctx.qVals ctx.r ∧
  interpolationProp ctx.xs ctx.ys ctx.coeffs ctx.xEval ctx.expectedEval ∧
  invertibleRq ctx.invDelta

/-- Derive the protocol target from explicit theorem/assumption inputs. -/
theorem protocolTargetProp_of_assumptions
  {ctx : ProtocolTargetContext}
  (h : ProtocolTargetAssumptions ctx) :
  protocolTargetProp ctx := by
  refine ⟨h.thm3, h.arithmetic.splitTerminalZero, h.arithmetic.evalHom,
    h.arithmetic.vecModule, h.arithmetic.scalarModule, h.arithmetic.sampling,
    h.arithmetic.mleTableSize, h.arithmetic.mleIdentityAtR, h.arithmetic.interpolation, ?_⟩
  exact h.invDeltaInvertible

/--
Derive protocol target from native assumptions, closing Theorem-3 by rewriting
`ctx.bar` to `nativeBarMatrix`.
-/
theorem protocolTargetProp_of_native_assumptions
  {ctx : ProtocolTargetContext}
  (h : ProtocolTargetNativeAssumptions ctx) :
  protocolTargetProp ctx := by
  rcases h with ⟨hBar, hArithmetic, hInvDelta⟩
  have hThm3 : thm3CoreAssumption ctx.bar := by
    simpa [hBar] using thm3CoreAssumption_native
  refine ⟨hThm3, hArithmetic.splitTerminalZero, hArithmetic.evalHom,
    hArithmetic.vecModule, hArithmetic.scalarModule, hArithmetic.sampling,
    hArithmetic.mleTableSize, hArithmetic.mleIdentityAtR, hArithmetic.interpolation, ?_⟩
  exact hInvDelta
end SuperNeo
