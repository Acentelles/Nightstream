use neo_math::{Fq as F, D};

#[derive(Clone)]
pub(crate) struct SuperNeoCase {
    pub(crate) a: [F; D],
    pub(crate) b: [F; D],
    pub(crate) expected_ct: F,
    pub(crate) expected_dot: F,
}

#[derive(Clone)]
pub(crate) struct RingMulCase {
    pub(crate) a: [F; D],
    pub(crate) b: [F; D],
    pub(crate) expected: [F; D],
}

#[derive(Clone)]
pub(crate) struct NormCase {
    pub(crate) a: [F; D],
    pub(crate) expected_norm: u64,
}

#[derive(Clone)]
pub(crate) struct SplitCase {
    pub(crate) input: Vec<F>,
    pub(crate) base: u64,
    pub(crate) k: u64,
    pub(crate) expected_digits: Vec<Vec<F>>,
    pub(crate) expected_recomposed: Vec<F>,
}

#[derive(Clone)]
pub(crate) struct EqCase {
    pub(crate) x: Vec<F>,
    pub(crate) y: Vec<F>,
    pub(crate) expected: F,
}

#[derive(Clone)]
pub(crate) struct MleCase {
    pub(crate) v: Vec<F>,
    pub(crate) r: Vec<F>,
    pub(crate) expected_inner: F,
    pub(crate) expected_fold: F,
}

#[derive(Clone)]
pub(crate) struct EmbeddingVecCase {
    pub(crate) input: Vec<F>,
    pub(crate) expected_blocks: Vec<Vec<F>>,
}

#[derive(Clone)]
pub(crate) struct EmbeddingMatrixCase {
    pub(crate) input: Vec<Vec<F>>,
    pub(crate) expected_blocks: Vec<Vec<Vec<F>>>,
}

#[derive(Clone)]
pub(crate) struct BarLiftVecCase {
    pub(crate) v: Vec<F>,
    pub(crate) w: Vec<F>,
    pub(crate) scalar: F,
    pub(crate) expected_lift_v: Vec<F>,
    pub(crate) expected_lift_w: Vec<F>,
    pub(crate) expected_lift_add: Vec<F>,
    pub(crate) expected_lift_scale: Vec<F>,
}

#[derive(Clone)]
pub(crate) struct BarLiftMatrixCase {
    pub(crate) input: Vec<Vec<F>>,
    pub(crate) expected_lifted: Vec<Vec<F>>,
}

#[derive(Clone)]
pub(crate) struct MatrixTransformCase {
    pub(crate) matrix: Vec<Vec<F>>,
    pub(crate) z: Vec<F>,
    pub(crate) expected_mz: Vec<F>,
    pub(crate) expected_ct_bar_mz: Vec<F>,
}

#[derive(Clone)]
pub(crate) struct EvalLinkCase {
    pub(crate) matrix: Vec<Vec<F>>,
    pub(crate) z: Vec<F>,
    pub(crate) r: Vec<F>,
    pub(crate) expected_y: Vec<F>,
    pub(crate) expected_ct_y: F,
}

#[derive(Clone)]
pub(crate) struct EvalHomCase {
    pub(crate) matrix: Vec<Vec<F>>,
    pub(crate) z1: Vec<F>,
    pub(crate) z2: Vec<F>,
    pub(crate) r: Vec<F>,
    pub(crate) rho1: F,
    pub(crate) rho2: F,
    pub(crate) expected_y1: Vec<F>,
    pub(crate) expected_y2: Vec<F>,
    pub(crate) expected_y_lin: Vec<F>,
    pub(crate) expected_y_direct: Vec<F>,
}

#[derive(Clone)]
pub(crate) struct SamplingCase {
    pub(crate) cset: Vec<Vec<F>>,
    pub(crate) vectors: Vec<Vec<F>>,
    pub(crate) b_inv: u64,
    pub(crate) expected_strong: bool,
    pub(crate) expected_max_rho_norm: u64,
    pub(crate) expected_bound: u64,
    pub(crate) expected_empirical: u64,
}

#[derive(Clone)]
pub(crate) struct EqLiftCase {
    pub(crate) q_vals: Vec<F>,
    pub(crate) z: Vec<F>,
    pub(crate) expected_sum: F,
    pub(crate) is_boolean_point: bool,
    pub(crate) expected_at_boolean: F,
}

#[derive(Clone)]
pub(crate) struct InterpCase {
    pub(crate) xs: Vec<F>,
    pub(crate) ys: Vec<F>,
    pub(crate) expected_coeffs: Vec<F>,
    pub(crate) eval_point: F,
    pub(crate) expected_eval_at: F,
}

#[derive(Clone)]
pub(crate) struct ModuleHomCase {
    pub(crate) scalar: F,
    pub(crate) x: Vec<F>,
    pub(crate) y: Vec<F>,
    pub(crate) vec_factor: F,
    pub(crate) vec_bias: Vec<F>,
    pub(crate) scalar_weights: Vec<F>,
    pub(crate) scalar_bias: F,
    pub(crate) expected_vec_check: bool,
    pub(crate) expected_scalar_check: bool,
}

#[derive(Clone)]
pub(crate) struct InvertibilityCase {
    pub(crate) coeffs: Vec<F>,
    pub(crate) bound: u64,
    pub(crate) expected_shape: bool,
    pub(crate) expected_weak_window: bool,
    pub(crate) expected_strict_window: bool,
    pub(crate) expected_derivable_invertible: bool,
}
