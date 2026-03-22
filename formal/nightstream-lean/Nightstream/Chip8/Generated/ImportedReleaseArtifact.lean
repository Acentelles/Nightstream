import Nightstream.Chip8.Generated.ReleaseArtifactVectors
import Nightstream.Chip8.Kernel.ExternalReleaseArtifact

namespace Nightstream.Chip8.Generated

def importedReleaseArtifactName : String := "jump_rows_2_seed_empty"

def importedReleaseArtifact : Nightstream.Chip8.ExternalReleaseArtifact.ImportedArtifact :=
  Nightstream.Chip8.ExternalReleaseArtifact.ofVectorCase
    (Nightstream.Chip8.Generated.releaseArtifactVectorCases.get ⟨0, by decide⟩)

end Nightstream.Chip8.Generated
