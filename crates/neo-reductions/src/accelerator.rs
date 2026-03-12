use std::sync::{Arc, OnceLock};

use neo_ajtai::Commitment as Cmt;
use neo_ccs::crypto::poseidon2_goldilocks as p2;
use neo_ccs::{CcsClaim, CcsStructure, CcsWitness, CeClaim, Mat};
use neo_gpu::{
    connect, DeviceApi, ExecutionMode, FlatK, MojoSession, MojoSessionDiagnostics, MojoSplitNcEvaluator,
    ProverComputeBackend,
};
use neo_math::{from_complex, KExtensions, F as BaseF, K};
use neo_params::NeoParams;
use p3_field::{Field, PrimeCharacteristicRing, PrimeField64};
use p3_symmetric::Permutation;

use crate::engines::optimized_engine::oracle::{NcOracle, OptimizedOracle, SparseCache};
use crate::sumcheck::RoundOracle;
use crate::PiCcsError;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum BackendExecutionStatus {
    RustCpu,
    MojoCpu,
    MojoAccelerator(DeviceApi),
}

pub struct BackendContext {
    mojo_cfg: Option<neo_gpu::MojoBackendConfig>,
    requested_mojo: bool,
    allow_cpu_fallback: bool,
    connection: OnceLock<Result<Option<BackendConnection>, String>>,
}

struct BackendConnection {
    session: MojoSession,
    supports_split_nc: bool,
    supports_poseidon2: bool,
}

impl BackendContext {
    pub fn new(backend: &ProverComputeBackend) -> Result<Self, PiCcsError> {
        match backend {
            ProverComputeBackend::Cpu => Ok(Self {
                mojo_cfg: None,
                requested_mojo: false,
                allow_cpu_fallback: false,
                connection: OnceLock::new(),
            }),
            ProverComputeBackend::Mojo(cfg) => Ok(Self {
                mojo_cfg: Some(cfg.clone()),
                requested_mojo: true,
                allow_cpu_fallback: cfg.fallback_to_cpu,
                connection: OnceLock::new(),
            }),
        }
    }

    fn preferred_device_api_hint(&self) -> Option<DeviceApi> {
        let cfg = self.mojo_cfg.as_ref()?;
        match cfg.device_api {
            DeviceApi::Auto => cfg
                .device_api
                .candidate_order()
                .iter()
                .copied()
                .find(|api| *api != DeviceApi::Cpu)
                .or(Some(DeviceApi::Cpu)),
            api => Some(api),
        }
    }

    fn initialize_connection(&self) -> Result<Option<&BackendConnection>, PiCcsError> {
        let Some(cfg) = self.mojo_cfg.as_ref() else {
            return Ok(None);
        };
        let result = self.connection.get_or_init(|| match connect(cfg) {
            Ok(session) => {
                let supports_poseidon2 = session.supports_poseidon2_api();
                let supports_split_nc = session.declares_split_nc_api();
                if !supports_split_nc && !supports_poseidon2 {
                    if cfg.fallback_to_cpu {
                        Ok(None)
                    } else {
                        Err("Mojo backend loaded but does not expose Poseidon2 or Split-NC symbols".into())
                    }
                } else {
                    Ok(Some(BackendConnection {
                        session,
                        supports_split_nc,
                        supports_poseidon2,
                    }))
                }
            }
            Err(_err) if cfg.fallback_to_cpu => Ok(None),
            Err(err) => Err(format!("failed to initialize Mojo backend: {err}")),
        });
        result
            .as_ref()
            .map(|conn| conn.as_ref())
            .map_err(|err| PiCcsError::ProtocolError(err.clone()))
    }

    fn poseidon_session(&self) -> Result<Option<&MojoSession>, PiCcsError> {
        match self.initialize_connection()? {
            Some(conn) if conn.supports_poseidon2 => Ok(Some(&conn.session)),
            Some(_) if self.requested_mojo && !self.allow_cpu_fallback => Err(PiCcsError::ProtocolError(
                "Mojo backend loaded but does not expose Poseidon2 symbols".into(),
            )),
            _ => Ok(None),
        }
    }

    pub fn split_nc_session(&self) -> Result<Option<&MojoSession>, PiCcsError> {
        match self.initialize_connection()? {
            Some(conn) if conn.supports_split_nc => Ok(Some(&conn.session)),
            Some(_) if self.requested_mojo && !self.allow_cpu_fallback => Err(PiCcsError::ProtocolError(
                "Mojo backend loaded but does not expose Split-NC evaluator symbols".into(),
            )),
            _ => Ok(None),
        }
    }

    pub fn aux_session(&self) -> Result<Option<&MojoSession>, PiCcsError> {
        Ok(self.initialize_connection()?.map(|conn| &conn.session))
    }

    #[inline]
    pub fn split_nc_required(&self) -> bool {
        self.requested_mojo && !self.allow_cpu_fallback
    }

    #[inline]
    pub fn poseidon2_min_permutations(&self) -> usize {
        match self.preferred_device_api_hint() {
            Some(api) => api.activation_thresholds().poseidon2_batch_min_states,
            None => usize::MAX,
        }
    }

    #[inline]
    pub fn selected_device_api(&self) -> Option<DeviceApi> {
        match self.initialize_connection() {
            Ok(Some(conn)) => Some(conn.session.device_api()),
            Ok(None) => None,
            Err(_) => None,
        }
    }

    #[inline]
    pub fn split_nc_device_api_hint(&self) -> Option<DeviceApi> {
        self.preferred_device_api_hint()
    }

    pub fn poseidon2_execution_status(&self, total_permutations: usize) -> BackendExecutionStatus {
        let Some(api) = self.preferred_device_api_hint() else {
            return BackendExecutionStatus::RustCpu;
        };
        if api != DeviceApi::Cpu && total_permutations < api.activation_thresholds().poseidon2_batch_min_states {
            return BackendExecutionStatus::RustCpu;
        }
        let Some(session) = self.poseidon_session().unwrap_or_default() else {
            return BackendExecutionStatus::RustCpu;
        };
        match session.poseidon2_batch_execution_mode(total_permutations) {
            ExecutionMode::Cpu => BackendExecutionStatus::MojoCpu,
            ExecutionMode::HostFallback => BackendExecutionStatus::RustCpu,
            ExecutionMode::Accelerator => BackendExecutionStatus::MojoAccelerator(session.device_api()),
        }
    }

    pub fn fe_row_execution_status(&self, total_tasks: usize) -> BackendExecutionStatus {
        let Some(api) = self.split_nc_device_api_hint() else {
            return BackendExecutionStatus::RustCpu;
        };
        if api != DeviceApi::Cpu && total_tasks < api.activation_thresholds().fe_row_min_tasks {
            return BackendExecutionStatus::RustCpu;
        }
        let Ok(Some(session)) = self.split_nc_session() else {
            return BackendExecutionStatus::RustCpu;
        };
        match session.fe_row_execution_mode(total_tasks) {
            ExecutionMode::Cpu => BackendExecutionStatus::MojoCpu,
            ExecutionMode::HostFallback => BackendExecutionStatus::RustCpu,
            ExecutionMode::Accelerator => BackendExecutionStatus::MojoAccelerator(session.device_api()),
        }
    }

    pub fn nc_col_execution_status(&self, total_tasks: usize) -> BackendExecutionStatus {
        let Some(api) = self.split_nc_device_api_hint() else {
            return BackendExecutionStatus::RustCpu;
        };
        if api != DeviceApi::Cpu && total_tasks < api.activation_thresholds().nc_col_min_tasks {
            return BackendExecutionStatus::RustCpu;
        }
        let Ok(Some(session)) = self.split_nc_session() else {
            return BackendExecutionStatus::RustCpu;
        };
        match session.nc_col_execution_mode(total_tasks) {
            ExecutionMode::Cpu => BackendExecutionStatus::MojoCpu,
            ExecutionMode::HostFallback => BackendExecutionStatus::RustCpu,
            ExecutionMode::Accelerator => BackendExecutionStatus::MojoAccelerator(session.device_api()),
        }
    }

    pub fn split_nc_execution_status(&self, total_tasks: usize) -> BackendExecutionStatus {
        self.fe_row_execution_status(total_tasks)
    }

    pub fn commit_mix_execution_status(&self, total_tasks: usize) -> BackendExecutionStatus {
        let Some(_api) = self.preferred_device_api_hint() else {
            return BackendExecutionStatus::RustCpu;
        };
        let Ok(Some(session)) = self.aux_session() else {
            return BackendExecutionStatus::RustCpu;
        };
        match session.rq_mul_execution_mode(total_tasks) {
            ExecutionMode::Cpu => BackendExecutionStatus::MojoCpu,
            ExecutionMode::HostFallback => BackendExecutionStatus::RustCpu,
            ExecutionMode::Accelerator => BackendExecutionStatus::MojoAccelerator(session.device_api()),
        }
    }

    pub fn commit_many_execution_status(&self, total_tasks: usize) -> BackendExecutionStatus {
        self.commit_mix_execution_status(total_tasks)
    }

    pub fn diagnostics_snapshot(&self) -> MojoSessionDiagnostics {
        match self.connection.get() {
            Some(Ok(Some(conn))) => conn.session.diagnostics_snapshot(),
            _ => MojoSessionDiagnostics::default(),
        }
    }
}

#[inline]
fn add_goldilocks_u64(lhs: u64, rhs: BaseF) -> u64 {
    (BaseF::from_u64(lhs) + rhs).as_canonical_u64()
}

#[inline]
fn flat_k_from_ext(x: K) -> FlatK {
    let (re, im) = x.to_limbs_u64();
    FlatK { re, im }
}

#[inline]
fn ext_k_from_flat(x: FlatK) -> K {
    from_complex(BaseF::from_u64(x.re), BaseF::from_u64(x.im))
}

#[inline]
fn poseidon2_permute_state_cpu_u64x8(state: &mut [u64; p2::WIDTH]) {
    let mut felt_state = state.map(BaseF::from_u64);
    felt_state = p2::permutation().permute(felt_state);
    for (dst, src) in state.iter_mut().zip(felt_state.into_iter()) {
        *dst = src.as_canonical_u64();
    }
}

pub fn poseidon2_digest32_many_with_context(
    backend_ctx: &BackendContext,
    inputs: &[Vec<BaseF>],
) -> Result<Option<Vec<[u8; 32]>>, PiCcsError> {
    if inputs.is_empty() {
        return Ok(Some(Vec::new()));
    }

    let total_permutations = inputs
        .iter()
        .map(|input| input.len().div_ceil(p2::RATE) + 1)
        .sum::<usize>();
    if matches!(
        backend_ctx.poseidon2_execution_status(total_permutations),
        BackendExecutionStatus::RustCpu
    ) {
        return Ok(None);
    }

    let Some(session) = backend_ctx.poseidon_session()? else {
        return Ok(None);
    };

    let max_chunks = inputs
        .iter()
        .map(|input| input.len().div_ceil(p2::RATE))
        .max()
        .unwrap_or(0);
    let mut states = vec![[0u64; p2::WIDTH]; inputs.len()];
    let mut batch = Vec::<[u64; p2::WIDTH]>::with_capacity(inputs.len());
    let mut batch_indices = Vec::<usize>::with_capacity(inputs.len());

    for chunk_idx in 0..max_chunks {
        batch.clear();
        batch_indices.clear();
        let start = chunk_idx * p2::RATE;
        for (input_idx, input) in inputs.iter().enumerate() {
            if start >= input.len() {
                continue;
            }
            let end = (start + p2::RATE).min(input.len());
            for (lane, x) in input[start..end].iter().enumerate() {
                states[input_idx][lane] = add_goldilocks_u64(states[input_idx][lane], *x);
            }
            batch_indices.push(input_idx);
            batch.push(states[input_idx]);
        }

        match session.poseidon2_batch_execution_mode(batch.len()) {
            ExecutionMode::Cpu | ExecutionMode::Accelerator => session
                .permute_poseidon2_batch_u64x8(&mut batch)
                .map_err(|err| PiCcsError::ProtocolError(format!("batched Poseidon2 permutation failed: {err}")))?,
            ExecutionMode::HostFallback => {
                for state in &mut batch {
                    poseidon2_permute_state_cpu_u64x8(state);
                }
            }
        }

        for (input_idx, state) in batch_indices.iter().copied().zip(batch.iter().copied()) {
            states[input_idx] = state;
        }
    }

    batch.clear();
    for state in &mut states {
        state[0] = add_goldilocks_u64(state[0], BaseF::ONE);
        batch.push(*state);
    }

    match session.poseidon2_batch_execution_mode(batch.len()) {
        ExecutionMode::Cpu | ExecutionMode::Accelerator => session
            .permute_poseidon2_batch_u64x8(&mut batch)
            .map_err(|err| PiCcsError::ProtocolError(format!("final batched Poseidon2 permutation failed: {err}")))?,
        ExecutionMode::HostFallback => {
            for state in &mut batch {
                poseidon2_permute_state_cpu_u64x8(state);
            }
        }
    }

    let mut digests = Vec::with_capacity(batch.len());
    for state in batch {
        let mut out = [0u8; 32];
        for (i, limb) in state[..p2::DIGEST_LEN].iter().enumerate() {
            out[i * 8..(i + 1) * 8].copy_from_slice(&limb.to_le_bytes());
        }
        digests.push(out);
    }
    Ok(Some(digests))
}

pub struct SplitNcOptimizedOracle<'a, 'ctx, Ff>
where
    Ff: Field + PrimeCharacteristicRing + PrimeField64 + Copy + Send + Sync,
    K: From<Ff>,
{
    inner: OptimizedOracle<'a, Ff>,
    backend_ctx: &'ctx BackendContext,
    fe_evaluator: Option<MojoSplitNcEvaluator<'ctx>>,
    split_nc_device_api: Option<DeviceApi>,
    split_nc_required: bool,
}

impl<'a, 'ctx, Ff> SplitNcOptimizedOracle<'a, 'ctx, Ff>
where
    Ff: Field + PrimeCharacteristicRing + PrimeField64 + Copy + Send + Sync,
    K: From<Ff>,
{
    #[allow(clippy::too_many_arguments)]
    pub fn new_with_sparse(
        s: &'a CcsStructure<Ff>,
        params: &'a NeoParams,
        mcs_witnesses: &'a [CcsWitness<Ff>],
        me_witnesses: &'a [Mat<Ff>],
        ch: crate::engines::optimized_engine::Challenges,
        ell_d: usize,
        ell_n: usize,
        d_sc: usize,
        r_inputs: Option<&[K]>,
        sparse: Arc<SparseCache<Ff>>,
        backend_ctx: &'ctx BackendContext,
    ) -> Result<Self, PiCcsError> {
        let inner = OptimizedOracle::new_with_sparse(
            s,
            params,
            mcs_witnesses,
            me_witnesses,
            ch,
            ell_d,
            ell_n,
            d_sc,
            r_inputs,
            sparse,
        );
        let split_nc_required = backend_ctx.split_nc_required();
        let split_nc_device_api = backend_ctx.split_nc_device_api_hint();
        Ok(Self {
            inner,
            backend_ctx,
            fe_evaluator: None,
            split_nc_device_api,
            split_nc_required,
        })
    }

    pub fn build_me_outputs_from_ajtai_precomp<L>(
        &mut self,
        mcs_list: &[CcsClaim<Cmt, Ff>],
        me_inputs: &[CeClaim<Cmt, Ff, K>],
        s_col: &[K],
        fold_digest: [u8; 32],
        l: &L,
    ) -> Vec<CeClaim<Cmt, Ff, K>>
    where
        L: neo_ccs::traits::SModuleHomomorphism<Ff, Cmt>,
    {
        self.inner
            .build_me_outputs_from_ajtai_precomp(mcs_list, me_inputs, s_col, fold_digest, l)
    }
}

impl<'a, 'ctx, Ff> SplitNcOptimizedOracle<'a, 'ctx, Ff>
where
    Ff: Field + PrimeCharacteristicRing + PrimeField64 + Copy + Send + Sync,
    K: From<Ff>,
{
    #[inline]
    fn should_use_backend(&self, point_count: usize) -> bool {
        let Some(api) = self.split_nc_device_api else {
            return false;
        };
        let Some(total_tasks) = self.inner.fe_row_total_tasks(point_count) else {
            return false;
        };
        matches!(
            split_nc_execution_mode_for(api, total_tasks, api.activation_thresholds().fe_row_min_tasks),
            ExecutionMode::Cpu | ExecutionMode::Accelerator
        )
    }

    fn ensure_fe_evaluator(&mut self) -> bool {
        if self.fe_evaluator.is_some() {
            return true;
        }
        let Ok(Some(session)) = self.backend_ctx.split_nc_session() else {
            return false;
        };
        match session.create_fe_evaluator(&self.inner.fe_row_snapshot_bytes()) {
            Ok(evaluator) => {
                self.fe_evaluator = Some(evaluator);
                true
            }
            Err(err) if self.split_nc_required => {
                panic!("failed to initialize Mojo FE evaluator: {err}");
            }
            Err(_) => false,
        }
    }

    fn drop_fe_evaluator(&mut self, context: &str, err: impl std::fmt::Display) {
        if self.split_nc_required {
            panic!("{context}: {err}");
        }
        self.fe_evaluator = None;
    }
}

impl<'a, 'ctx, Ff> RoundOracle for SplitNcOptimizedOracle<'a, 'ctx, Ff>
where
    Ff: Field + PrimeCharacteristicRing + PrimeField64 + Copy + Send + Sync,
    K: From<Ff>,
{
    fn evals_at(&mut self, points: &[K]) -> Vec<K> {
        if self.should_use_backend(points.len()) && self.ensure_fe_evaluator() {
            let flat_points = points
                .iter()
                .copied()
                .map(flat_k_from_ext)
                .collect::<Vec<_>>();
            let gpu_out = {
                let evaluator = self
                    .fe_evaluator
                    .as_ref()
                    .expect("checked by should_use_gpu");
                evaluator.evals_at(&flat_points)
            };
            match gpu_out {
                Ok(out) => return out.into_iter().map(ext_k_from_flat).collect(),
                Err(err) => self.drop_fe_evaluator("Mojo FE evals_at failed", err),
            }
        }
        self.inner.evals_at(points)
    }

    fn num_rounds(&self) -> usize {
        self.inner.num_rounds()
    }

    fn degree_bound(&self) -> usize {
        self.inner.degree_bound()
    }

    fn fold(&mut self, r: K) {
        if self.fe_evaluator.is_some() && self.inner.round_idx < self.inner.ell_n {
            let challenge = flat_k_from_ext(r);
            let gpu_result = {
                let evaluator = self.fe_evaluator.as_mut().expect("checked by round bounds");
                evaluator.fold(challenge)
            };
            if let Err(err) = gpu_result {
                self.drop_fe_evaluator("Mojo FE fold failed", err);
            }
        }
        self.inner.fold(r);
        if self.inner.round_idx >= self.inner.ell_n {
            self.fe_evaluator = None;
        }
    }
}

pub struct SplitNcNcOracle<'a, 'ctx, Ff>
where
    Ff: Field + PrimeCharacteristicRing + PrimeField64 + Copy + Send + Sync,
    K: From<Ff>,
{
    inner: NcOracle<'a, Ff>,
    backend_ctx: &'ctx BackendContext,
    nc_evaluator: Option<MojoSplitNcEvaluator<'ctx>>,
    split_nc_device_api: Option<DeviceApi>,
    split_nc_required: bool,
}

impl<'a, 'ctx, Ff> SplitNcNcOracle<'a, 'ctx, Ff>
where
    Ff: Field + PrimeCharacteristicRing + PrimeField64 + Copy + Send + Sync,
    K: From<Ff>,
{
    #[allow(clippy::too_many_arguments)]
    pub fn new(
        s: &'a CcsStructure<Ff>,
        params: &'a NeoParams,
        mcs_witnesses: &'a [CcsWitness<Ff>],
        me_witnesses: &'a [Mat<Ff>],
        ch: crate::engines::optimized_engine::Challenges,
        ell_d: usize,
        ell_m: usize,
        d_sc: usize,
        backend_ctx: &'ctx BackendContext,
    ) -> Result<Self, PiCcsError> {
        let inner = NcOracle::new(s, params, mcs_witnesses, me_witnesses, ch, ell_d, ell_m, d_sc);
        let split_nc_required = backend_ctx.split_nc_required();
        let split_nc_device_api = backend_ctx.split_nc_device_api_hint();
        Ok(Self {
            inner,
            backend_ctx,
            nc_evaluator: None,
            split_nc_device_api,
            split_nc_required,
        })
    }
}

impl<'a, 'ctx, Ff> SplitNcNcOracle<'a, 'ctx, Ff>
where
    Ff: Field + PrimeCharacteristicRing + PrimeField64 + Copy + Send + Sync,
    K: From<Ff>,
{
    #[inline]
    fn should_use_backend(&self, point_count: usize) -> bool {
        let Some(api) = self.split_nc_device_api else {
            return false;
        };
        let Some(total_tasks) = self.inner.nc_col_total_tasks(point_count) else {
            return false;
        };
        matches!(
            split_nc_execution_mode_for(api, total_tasks, api.activation_thresholds().nc_col_min_tasks),
            ExecutionMode::Cpu | ExecutionMode::Accelerator
        )
    }

    fn ensure_nc_evaluator(&mut self) -> bool {
        if self.nc_evaluator.is_some() {
            return true;
        }
        let Ok(Some(session)) = self.backend_ctx.split_nc_session() else {
            return false;
        };
        match session.create_nc_evaluator(&self.inner.nc_col_snapshot_bytes()) {
            Ok(evaluator) => {
                self.nc_evaluator = Some(evaluator);
                true
            }
            Err(err) if self.split_nc_required => {
                panic!("failed to initialize Mojo NC evaluator: {err}");
            }
            Err(_) => false,
        }
    }

    fn drop_nc_evaluator(&mut self, context: &str, err: impl std::fmt::Display) {
        if self.split_nc_required {
            panic!("{context}: {err}");
        }
        self.nc_evaluator = None;
    }
}

impl<'a, 'ctx, Ff> RoundOracle for SplitNcNcOracle<'a, 'ctx, Ff>
where
    Ff: Field + PrimeCharacteristicRing + PrimeField64 + Copy + Send + Sync,
    K: From<Ff>,
{
    fn evals_at(&mut self, points: &[K]) -> Vec<K> {
        if self.should_use_backend(points.len()) && self.ensure_nc_evaluator() {
            let flat_points = points
                .iter()
                .copied()
                .map(flat_k_from_ext)
                .collect::<Vec<_>>();
            let gpu_out = {
                let evaluator = self
                    .nc_evaluator
                    .as_ref()
                    .expect("checked by should_use_gpu");
                evaluator.evals_at(&flat_points)
            };
            match gpu_out {
                Ok(out) => return out.into_iter().map(ext_k_from_flat).collect(),
                Err(err) => self.drop_nc_evaluator("Mojo NC evals_at failed", err),
            }
        }
        self.inner.evals_at(points)
    }

    fn num_rounds(&self) -> usize {
        self.inner.num_rounds()
    }

    fn degree_bound(&self) -> usize {
        self.inner.degree_bound()
    }

    fn fold(&mut self, r: K) {
        if self.nc_evaluator.is_some() && self.inner.round_idx < self.inner.ell_m {
            let challenge = flat_k_from_ext(r);
            let gpu_result = {
                let evaluator = self.nc_evaluator.as_mut().expect("checked by round bounds");
                evaluator.fold(challenge)
            };
            if let Err(err) = gpu_result {
                self.drop_nc_evaluator("Mojo NC fold failed", err);
            }
        }
        self.inner.fold(r);
        if self.inner.round_idx >= self.inner.ell_m {
            self.nc_evaluator = None;
        }
    }
}

#[inline]
fn split_nc_execution_mode_for(api: DeviceApi, total_tasks: usize, min_tasks: usize) -> ExecutionMode {
    match api {
        DeviceApi::Cpu => ExecutionMode::Cpu,
        DeviceApi::Cuda | DeviceApi::Metal | DeviceApi::Hip if total_tasks >= min_tasks => ExecutionMode::Accelerator,
        DeviceApi::Cuda | DeviceApi::Metal | DeviceApi::Hip | DeviceApi::Auto => ExecutionMode::HostFallback,
    }
}
