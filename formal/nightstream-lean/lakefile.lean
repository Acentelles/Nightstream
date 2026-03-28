import Lake
open Lake DSL

package «nightstream_lean» where
  version := v!"0.1.0"

require superneo_lean from "../superneo-lean"
require twist_shout_lean from "../twist-shout-lean"

@[default_target]
lean_lib Nightstream where
  -- Bridge library over the standalone SuperNeo and Twist/Shout theorem packages.
  -- The theorem package does not need native objects for downstream execution.
  nativeFacets := fun _ => #[]

lean_exe check where
  root := `Main
