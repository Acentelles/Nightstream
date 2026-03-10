import SuperNeo.Generated.NeoFoldArtifactsCases

import SuperNeo.Generated.NeoFoldArtifactCase2Defs0
import SuperNeo.Generated.NeoFoldArtifactCase2Defs1
import SuperNeo.Generated.NeoFoldArtifactCase2Defs2
import SuperNeo.Generated.NeoFoldArtifactCase2Defs3
import SuperNeo.Generated.NeoFoldArtifactCase2Defs4
import SuperNeo.Generated.NeoFoldArtifactCase2Defs5
import SuperNeo.Generated.NeoFoldArtifactCase2Defs6
import SuperNeo.Generated.NeoFoldArtifactCase2Defs7
import SuperNeo.Generated.NeoFoldArtifactCase2Defs8
import SuperNeo.Generated.NeoFoldArtifactCase2Defs9
import SuperNeo.Generated.NeoFoldArtifactCase2Defs10
import SuperNeo.Generated.NeoFoldArtifactCase2Defs11
import SuperNeo.Generated.NeoFoldArtifactCase2Defs12
import SuperNeo.Generated.NeoFoldArtifactCase2Defs13
import SuperNeo.Generated.NeoFoldArtifactCase2Defs14
import SuperNeo.Generated.NeoFoldArtifactCase2Defs15
import SuperNeo.Generated.NeoFoldArtifactCase2Defs16

namespace SuperNeo.Generated

def neoFoldArtifactCase2 : NeoFoldArtifactCase :=
  { scenarioName := "twist_shout_4step", shouldFail := false, foldBase := 2, kRho := 16, publicStepCount := 4, proofStepCount := 4, ccs := { n := 32, m := 32, matrices := #[{ nrows := 32, ncols := 32, identity := true, entries := #[] }], polyTerms := #[] }, accInitMainWitnessZ := #[], accInitMain := #[], finalMain := #[case2Claim0, case2Claim1, case2Claim2, case2Claim3, case2Claim4, case2Claim5, case2Claim6, case2Claim7, case2Claim8, case2Claim9, case2Claim10, case2Claim11, case2Claim12, case2Claim13, case2Claim14, case2Claim15], finalVal := #[case2Claim16, case2Claim17, case2Claim18, case2Claim19, case2Claim20, case2Claim21, case2Claim22, case2Claim23, case2Claim24, case2Claim25, case2Claim26, case2Claim27, case2Claim28, case2Claim29, case2Claim29, case2Claim29, case2Claim30, case2Claim31, case2Claim32, case2Claim33, case2Claim34, case2Claim35, case2Claim36, case2Claim37, case2Claim38, case2Claim39, case2Claim40, case2Claim41, case2Claim42, case2Claim43, case2Claim44, case2Claim45, case2Claim46, case2Claim47, case2Claim48, case2Claim49, case2Claim50, case2Claim51, case2Claim52, case2Claim53, case2Claim54, case2Claim55, case2Claim56, case2Claim57, case2Claim58, case2Claim59, case2Claim60, case2Claim61, case2Claim62, case2Claim63, case2Claim64, case2Claim65, case2Claim66, case2Claim67, case2Claim68, case2Claim69, case2Claim70, case2Claim71, case2Claim72, case2Claim73, case2Claim74, case2Claim75, case2Claim76, case2Claim77, case2Claim78, case2Claim79, case2Claim80, case2Claim81, case2Claim82, case2Claim83, case2Claim84, case2Claim85, case2Claim86, case2Claim87, case2Claim88, case2Claim88, case2Claim88, case2Claim89, case2Claim90, case2Claim91, case2Claim92, case2Claim93, case2Claim94, case2Claim95, case2Claim96, case2Claim97, case2Claim98, case2Claim99, case2Claim100, case2Claim101, case2Claim102, case2Claim103, case2Claim104, case2Claim105, case2Claim106, case2Claim107, case2Claim108, case2Claim109, case2Claim110, case2Claim111, case2Claim112, case2Claim113, case2Claim114, case2Claim115, case2Claim116, case2Claim117, case2Claim118, case2Claim119, case2Claim120, case2Claim121, case2Claim122, case2Claim123, case2Claim124, case2Claim125, case2Claim126, case2Claim127, case2Claim128, case2Claim129, case2Claim130, case2Claim130, case2Claim130, case2Claim131, case2Claim132, case2Claim133, case2Claim134, case2Claim135, case2Claim136, case2Claim137, case2Claim138, case2Claim139, case2Claim140, case2Claim141, case2Claim142, case2Claim143, case2Claim144, case2Claim145, case2Claim146, case2Claim147, case2Claim148, case2Claim149, case2Claim150, case2Claim151, case2Claim152, case2Claim153, case2Claim154, case2Claim155, case2Claim156, case2Claim157, case2Claim158, case2Claim159, case2Claim160, case2Claim161, case2Claim162, case2Claim163, case2Claim164, case2Claim165, case2Claim166, case2Claim167, case2Claim168, case2Claim169, case2Claim170, case2Claim171, case2Claim172, case2Claim173, case2Claim174, case2Claim175, case2Claim176, case2Claim177, case2Claim178, case2Claim179, case2Claim180, case2Claim181, case2Claim182, case2Claim183, case2Claim184, case2Claim185, case2Claim186, case2Claim187, case2Claim188, case2Claim189, case2Claim190, case2Claim191, case2Claim192, case2Claim193, case2Claim194, case2Claim195, case2Claim196, case2Claim197, case2Claim198, case2Claim199, case2Claim200, case2Claim201, case2Claim202, case2Claim203, case2Claim204, case2Claim204, case2Claim204, case2Claim205, case2Claim206, case2Claim207, case2Claim208, case2Claim209, case2Claim210, case2Claim211, case2Claim212, case2Claim213, case2Claim214, case2Claim215, case2Claim216, case2Claim217, case2Claim218, case2Claim219, case2Claim220, case2Claim221, case2Claim222, case2Claim223, case2Claim224, case2Claim225, case2Claim226, case2Claim227, case2Claim228, case2Claim229, case2Claim230, case2Claim231, case2Claim232], steps := #[case2Step0, case2Step1, case2Step2, case2Step3], segmentMeta := #[{ routeA := true, publicSteps := 4, proofSteps := 4 }] }

end SuperNeo.Generated
