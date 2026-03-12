use super::*;

pub(crate) enum CcsOracleDispatch<'a> {
    Optimized(neo_reductions::engines::optimized_engine::oracle::OptimizedOracle<'a, F>),
    #[cfg(feature = "paper-exact")]
    PaperExact(neo_reductions::engines::paper_exact_engine::oracle::PaperExactOracle<'a, F>),
}

impl<'a> RoundOracle for CcsOracleDispatch<'a> {
    fn evals_at(&mut self, points: &[K]) -> Vec<K> {
        match self {
            Self::Optimized(oracle) => oracle.evals_at(points),
            #[cfg(feature = "paper-exact")]
            Self::PaperExact(oracle) => oracle.evals_at(points),
        }
    }

    fn num_rounds(&self) -> usize {
        match self {
            Self::Optimized(oracle) => oracle.num_rounds(),
            #[cfg(feature = "paper-exact")]
            Self::PaperExact(oracle) => oracle.num_rounds(),
        }
    }

    fn degree_bound(&self) -> usize {
        match self {
            Self::Optimized(oracle) => oracle.degree_bound(),
            #[cfg(feature = "paper-exact")]
            Self::PaperExact(oracle) => oracle.degree_bound(),
        }
    }

    fn fold(&mut self, r: K) {
        match self {
            Self::Optimized(oracle) => oracle.fold(r),
            #[cfg(feature = "paper-exact")]
            Self::PaperExact(oracle) => oracle.fold(r),
        }
    }
}
