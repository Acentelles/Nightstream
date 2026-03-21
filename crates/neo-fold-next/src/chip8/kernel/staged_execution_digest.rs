//! Owns the exact staged execution digest export over one authenticated kernel chunk.

use crate::chip8::spec::{Chip8State, WITNESS_WIDTH};

use super::stage3_digest::{build_kernel_stage3_digest_surfaces_from_frames, KernelStage3DigestSurface};
use super::{
    build_kernel_exact_frames, KernelFrameDecodeView, KernelMetaPub, KernelStepAux, SimpleKernelError,
    SimpleKernelOutput, SimpleKernelProof, SimpleKernelPublicInput,
};

#[derive(Clone, Debug, PartialEq)]
pub struct KernelDigestPublicSurface {
    pub public: SimpleKernelPublicInput,
    pub meta_pub: KernelMetaPub,
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelStage1DigestSurface {
    pub pre: Chip8State,
    pub dec: KernelFrameDecodeView,
    pub row: [neo_math::F; WITNESS_WIDTH],
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelStage2DigestSurface {
    pub pre: Chip8State,
    pub post: Chip8State,
    pub dec: KernelFrameDecodeView,
    pub row: [neo_math::F; WITNESS_WIDTH],
    pub kernel_aux: KernelStepAux,
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelExecutionResultSurface {
    pub step_idx: usize,
    pub pre: Chip8State,
    pub post: Chip8State,
    pub dec: KernelFrameDecodeView,
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelStagedExecutionDigest {
    pub stage1: KernelStage1DigestSurface,
    pub stage2: KernelStage2DigestSurface,
    pub stage3: KernelStage3DigestSurface,
    pub result: KernelExecutionResultSurface,
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelStagedExecutionDigestBundle {
    pub public: KernelDigestPublicSurface,
    pub digests: Vec<KernelStagedExecutionDigest>,
}

pub fn build_kernel_staged_execution_digest_bundle(
    public: &SimpleKernelPublicInput,
    proof: &SimpleKernelProof,
    output: &SimpleKernelOutput,
) -> Result<KernelStagedExecutionDigestBundle, SimpleKernelError> {
    let frames = build_kernel_exact_frames(public, proof)?;
    let stage3_surfaces = build_kernel_stage3_digest_surfaces_from_frames(public, proof, output, &frames)?;
    if frames.len() != stage3_surfaces.len() {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "staged digest frame count {} != stage3 digest count {}",
            frames.len(),
            stage3_surfaces.len()
        )));
    }

    let digests = frames
        .into_iter()
        .zip(stage3_surfaces.into_iter())
        .map(|(frame, stage3)| KernelStagedExecutionDigest {
            stage1: KernelStage1DigestSurface {
                pre: frame.pre.clone(),
                dec: frame.dec.clone(),
                row: frame.row,
            },
            stage2: KernelStage2DigestSurface {
                pre: frame.pre.clone(),
                post: frame.post.clone(),
                dec: frame.dec.clone(),
                row: frame.row,
                kernel_aux: frame.kernel_aux.clone(),
            },
            result: KernelExecutionResultSurface {
                step_idx: frame.step_idx,
                pre: frame.pre,
                post: frame.post,
                dec: frame.dec,
            },
            stage3,
        })
        .collect();

    Ok(KernelStagedExecutionDigestBundle {
        public: KernelDigestPublicSurface {
            public: public.clone(),
            meta_pub: proof.meta_pub.clone(),
        },
        digests,
    })
}

pub fn verify_kernel_staged_execution_digest_bundle(
    public: &SimpleKernelPublicInput,
    proof: &SimpleKernelProof,
    output: &SimpleKernelOutput,
    bundle: &KernelStagedExecutionDigestBundle,
) -> Result<(), String> {
    let expected = build_kernel_staged_execution_digest_bundle(public, proof, output)
        .map_err(|err| format!("staged execution digest build failed: {err}"))?;
    if bundle != &expected {
        return Err("staged execution digest bundle mismatch".into());
    }
    Ok(())
}
