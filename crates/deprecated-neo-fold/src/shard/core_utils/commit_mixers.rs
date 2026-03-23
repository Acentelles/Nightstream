use super::*;

/// Commitment mixers so the coordinator stays scheme-agnostic.
/// - `mix_rhos_commits(ρ, cs)` returns Σ ρ_i · c_i.
/// - `combine_b_pows(cs, b)` returns Σ \bar b^{i-1} c_i.
#[derive(Clone, Copy)]
pub struct CommitMixers<MR, MB>
where
    MR: Fn(&[Mat<F>], &[Cmt]) -> Cmt,
    MB: Fn(&[Cmt], u32) -> Cmt,
{
    pub mix_rhos_commits: MR,
    pub combine_b_pows: MB,
}
