import Nightstream.Chip8.Generated.ImportedReleaseArtifact.Case_jump_rows_2_seed_empty
import Nightstream.Chip8.Generated.ImportedReleaseArtifact.Case_jump_rows_3_seed_nonempty
import Nightstream.Chip8.Generated.ImportedReleaseArtifact.Case_mixed_ldimm_addimm_10

namespace Nightstream.Chip8.Generated

open Nightstream.Chip8.Generated.ImportedReleaseArtifact

def importedReleaseArtifacts : List (String × Nightstream.Chip8.ExternalReleaseArtifact.ImportedArtifact) :=
  [
    ("jump_rows_2_seed_empty", importedReleaseArtifact_jump_rows_2_seed_empty),
    ("jump_rows_3_seed_nonempty", importedReleaseArtifact_jump_rows_3_seed_nonempty),
    ("mixed_ldimm_addimm_10", importedReleaseArtifact_mixed_ldimm_addimm_10)
  ]

def importedReleaseArtifactNames : List String :=
  importedReleaseArtifacts.map Prod.fst

def importedReleaseArtifactValues : List Nightstream.Chip8.ExternalReleaseArtifact.ImportedArtifact :=
  importedReleaseArtifacts.map Prod.snd

end Nightstream.Chip8.Generated
