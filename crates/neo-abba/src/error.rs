//! Error types for ABBA commitment operations.

#[derive(Debug, Clone, PartialEq, Eq, thiserror::Error)]
pub enum AbbaError {
    #[error("Invalid dimensions: {0}")]
    InvalidDimensions(String),

    #[error("Size mismatch: expected {expected}, got {actual}")]
    SizeMismatch { expected: usize, actual: usize },

    #[error("Empty input")]
    EmptyInput,

    #[error("Verification failed")]
    VerificationFailed,
}

pub type AbbaResult<T> = Result<T, AbbaError>;
