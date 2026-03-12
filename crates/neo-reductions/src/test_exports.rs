use neo_math::K;
use p3_field::{Field, PrimeCharacteristicRing, PrimeField64};

use crate::engines::optimized_engine::oracle::{NcOracle, OptimizedOracle};

#[doc(hidden)]
pub fn fe_row_snapshot_bytes_for_testing<'a, F>(oracle: &OptimizedOracle<'a, F>) -> Vec<u8>
where
    F: Field + PrimeCharacteristicRing + PrimeField64 + Copy + Send + Sync,
    K: From<F>,
{
    oracle.fe_row_snapshot_bytes()
}

#[doc(hidden)]
pub fn fe_row_snapshot_cur_len_for_testing<'a, F>(oracle: &OptimizedOracle<'a, F>) -> usize
where
    F: Field + PrimeCharacteristicRing + PrimeField64 + Copy + Send + Sync,
    K: From<F>,
{
    oracle.fe_row_snapshot().cur_len as usize
}

#[doc(hidden)]
pub fn fe_row_snapshot_has_eval_gate_for_testing<'a, F>(oracle: &OptimizedOracle<'a, F>) -> bool
where
    F: Field + PrimeCharacteristicRing + PrimeField64 + Copy + Send + Sync,
    K: From<F>,
{
    let snapshot = oracle.fe_row_snapshot();
    !snapshot.eq_r_inputs_tbl.is_empty() && !snapshot.eval_tbl.is_empty()
}

#[doc(hidden)]
pub fn nc_col_snapshot_bytes_for_testing<'a, F>(oracle: &NcOracle<'a, F>) -> Vec<u8>
where
    F: Field + PrimeCharacteristicRing + PrimeField64 + Copy + Send + Sync,
    K: From<F>,
{
    oracle.nc_col_snapshot_bytes()
}

#[doc(hidden)]
pub fn nc_col_snapshot_cur_len_for_testing<'a, F>(oracle: &NcOracle<'a, F>) -> usize
where
    F: Field + PrimeCharacteristicRing + PrimeField64 + Copy + Send + Sync,
    K: From<F>,
{
    oracle.nc_col_snapshot().cur_len as usize
}

#[doc(hidden)]
pub fn nc_col_snapshot_num_tables_for_testing<'a, F>(oracle: &NcOracle<'a, F>) -> usize
where
    F: Field + PrimeCharacteristicRing + PrimeField64 + Copy + Send + Sync,
    K: From<F>,
{
    oracle.nc_col_snapshot().num_tables as usize
}
