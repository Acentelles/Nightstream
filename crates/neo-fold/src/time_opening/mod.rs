pub mod joint_lane;
pub mod manifest;
pub mod me_adapter;
pub mod reduction;

/// Decomposition base for joint-opening time-column commitments/openings.
///
/// This must stay aligned with the concrete SuperNeo Goldilocks parameters.
pub const JOINT_OPENING_TIME_DECOMP_BASE: u32 = 2;

/// Exact-transport slice width for time-opening column commitments.
///
/// Raw Goldilocks field elements are split into two bounded base-field slices
/// before balanced base-`b` digit decomposition so the joint-opening path stays
/// paper-faithful at `b = 2`.
pub const JOINT_OPENING_TIME_SLICE_BITS: usize = 32;

/// Number of exact-transport slices per logical time-column entry.
pub const JOINT_OPENING_TIME_SLICE_COUNT: usize = 2;
