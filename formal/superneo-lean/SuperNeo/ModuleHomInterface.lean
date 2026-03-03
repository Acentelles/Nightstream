import SuperNeo.ModuleHom

/-!
Contract interface for `SuperNeo.ModuleHom`.

Spec: `specs/ModuleHom.spec.md`

Paper anchors:
- Theorem 5, Section 5, lines 390-400: R_F-module homomorphisms L and L_in.
-/

namespace SuperNeo

namespace ModuleHomInterface

/-! ## Core Structures -/

/-- [Role: Definitional] Vector-valued module-hom map surface. -/
abbrev VecModuleHom := SuperNeo.VecModuleHom

/-- [Role: Definitional] Scalar-valued module-hom map surface. -/
abbrev ScalarModuleHom := SuperNeo.ScalarModuleHom

/-- [Role: Definitional] One-point vector linearity proposition pair. -/
abbrev vecModulePropPair := SuperNeo.vecModulePropPair

/-- [Role: Definitional] One-point scalar linearity proposition pair. -/
abbrev scalarModulePropPair := SuperNeo.scalarModulePropPair

/-- [Role: Definitional] Executable check form for vector one-point linearity. -/
abbrev vecModuleCheckPair := SuperNeo.vecModuleCheckPair

/-- [Role: Definitional] Executable check form for scalar one-point linearity. -/
abbrev scalarModuleCheckPair := SuperNeo.scalarModuleCheckPair

/-- [Role: Definitional] Executable additivity check for vector maps. -/
abbrev preservesAddVec := SuperNeo.preservesAddVec

/-- [Role: Definitional] Executable scaling check for vector maps. -/
abbrev preservesScaleVec := SuperNeo.preservesScaleVec

/-- [Role: Definitional] Executable additivity check for scalar maps. -/
abbrev preservesAddScalar := SuperNeo.preservesAddScalar

/-- [Role: Definitional] Executable scaling check for scalar maps. -/
abbrev preservesScaleScalar := SuperNeo.preservesScaleScalar

/-! ## Key Theorems -/

/-- [Role: Theorem-Target] `preservesAddVec = true` implies vector additivity. -/
abbrev preservesAddVec_sound := SuperNeo.preservesAddVec_sound

/-- [Role: Theorem-Target] `preservesScaleVec = true` implies vector scaling law. -/
abbrev preservesScaleVec_sound := SuperNeo.preservesScaleVec_sound

/-- [Role: Theorem-Target] `preservesAddScalar = true` implies scalar additivity. -/
abbrev preservesAddScalar_sound := SuperNeo.preservesAddScalar_sound

/-- [Role: Theorem-Target] `preservesScaleScalar = true` implies scalar scaling law. -/
abbrev preservesScaleScalar_sound := SuperNeo.preservesScaleScalar_sound

/-- [Role: Theorem-Target] Vector additivity + shape premise implies `preservesAddVec = true`. -/
abbrev preservesAddVec_complete := SuperNeo.preservesAddVec_complete

/-- [Role: Theorem-Target] Vector scaling law implies `preservesScaleVec = true`. -/
abbrev preservesScaleVec_complete := SuperNeo.preservesScaleVec_complete

/-- [Role: Theorem-Target] Scalar additivity + shape premise implies `preservesAddScalar = true`. -/
abbrev preservesAddScalar_complete := SuperNeo.preservesAddScalar_complete

/-- [Role: Theorem-Target] Scalar scaling law implies `preservesScaleScalar = true`. -/
abbrev preservesScaleScalar_complete := SuperNeo.preservesScaleScalar_complete

/-- [Role: Theorem-Target] Check-pair success implies vector proposition pair. -/
abbrev vecModulePropPair_of_checkPair := SuperNeo.vecModulePropPair_of_checkPair

/-- [Role: Theorem-Target] Vector proposition pair implies check-pair success. -/
abbrev vecModuleCheckPair_of_propPair := SuperNeo.vecModuleCheckPair_of_propPair

/-- [Role: Theorem-Target] Check-pair success implies scalar proposition pair. -/
abbrev scalarModulePropPair_of_checkPair := SuperNeo.scalarModulePropPair_of_checkPair

/-- [Role: Theorem-Target] Scalar proposition pair implies check-pair success. -/
abbrev scalarModuleCheckPair_of_propPair := SuperNeo.scalarModuleCheckPair_of_propPair

/-! ## Universal Contracts -/

/--
[Role: Definitional] Theorem-facing universal vector module-hom contract:
`map(x+y)=map(x)+map(y)` and `map(s•x)=s•map(x)` for all inputs.
-/
abbrev vecModuleAssumption := SuperNeo.vecModuleAssumption

/--
[Role: Definitional] Theorem-facing universal scalar module-hom contract:
`map(x+y)=map(x)+map(y)` and `map(s•x)=s*map(x)` for all inputs.
-/
abbrev scalarModuleAssumption := SuperNeo.scalarModuleAssumption

/-- [Role: Definitional] Check-facing universal vector contract. -/
abbrev vecModuleCheckAssumption := SuperNeo.vecModuleCheckAssumption

/-- [Role: Definitional] Check-facing universal scalar contract. -/
abbrev scalarModuleCheckAssumption := SuperNeo.scalarModuleCheckAssumption

/-- [Role: Theorem-Target] Universal vector check contract implies universal vector theorem contract. -/
abbrev vecModuleAssumption_of_checkAssumption := SuperNeo.vecModuleAssumption_of_checkAssumption

/-- [Role: Theorem-Target] Universal vector theorem contract implies universal vector check contract. -/
abbrev vecModuleCheckAssumption_of_assumption := SuperNeo.vecModuleCheckAssumption_of_assumption

/-- [Role: Theorem-Target] Universal scalar check contract implies universal scalar theorem contract. -/
abbrev scalarModuleAssumption_of_checkAssumption := SuperNeo.scalarModuleAssumption_of_checkAssumption

/-- [Role: Theorem-Target] Universal scalar theorem contract implies universal scalar check contract. -/
abbrev scalarModuleCheckAssumption_of_assumption := SuperNeo.scalarModuleCheckAssumption_of_assumption

end ModuleHomInterface

end SuperNeo
