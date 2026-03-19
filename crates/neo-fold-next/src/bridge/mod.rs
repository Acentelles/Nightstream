//! Owns staged-to-backend export.

use crate::proof::{PublicStep, SessionExtensionAccumulator, StepBuild, StepInput};

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct BridgePublicView {
    pub chunk_count: usize,
    pub prepared_step_count: usize,
    pub compatibility_path: bool,
}

#[derive(Clone, Debug)]
pub struct BridgeOutput {
    pub prepared_steps: Vec<StepInput>,
    pub public_steps: Vec<PublicStep>,
    pub session_extensions: SessionExtensionAccumulator,
    pub public_bridge_view: BridgePublicView,
}

pub fn export_compat_steps(step_builds: Vec<StepBuild>) -> BridgeOutput {
    let mut prepared_steps = Vec::with_capacity(step_builds.len());
    let mut public_steps = Vec::with_capacity(step_builds.len());
    let mut session_extensions = SessionExtensionAccumulator::default();
    for build in step_builds {
        public_steps.push(build.public_step);
        session_extensions.push(build.extension_data);
        prepared_steps.push(build.prepared);
    }
    BridgeOutput {
        public_bridge_view: BridgePublicView {
            chunk_count: 1,
            prepared_step_count: prepared_steps.len(),
            compatibility_path: true,
        },
        prepared_steps,
        public_steps,
        session_extensions,
    }
}
