use anyhow::Context;
use blake2b_simd::State as TranscriptHash;
use midnight_curves::Bls12;
use midnight_proofs::circuit::Value;
use midnight_proofs::dev::cost_model::circuit_model;
use midnight_proofs::poly::kzg::params::ParamsKZG;
use midnight_proofs::utils::SerdeFormat;
use midnight_zk_stdlib::Relation;
use neo_math::{F, K, KExtensions, D};
use neo_midnight_bridge::k_field::KRepr;
use neo_midnight_bridge::relations::{
    PiCcsFeChunkAggSumcheckInstance, PiCcsFeChunkAggSumcheckRelation, PiCcsFeChunkAggSumcheckWitness, PiCcsFeChunkInstance,
    PiCcsFeChunkRelation, PiCcsFeChunkWitness, PiCcsNcChunkAggSumcheckInstance, PiCcsNcChunkAggSumcheckRelation,
    PiCcsNcChunkAggSumcheckWitness, PiCcsNcChunkInstance, PiCcsNcChunkRelation, PiCcsNcChunkWitness, SparsePolyRepr,
    SparsePolyTermRepr,
};
use neo_midnight_bridge_artifacts::nmbp::export_package_with_params_v3;
use neo_midnight_bridge_artifacts::nmbws::export_witness_snapshot_v2;
use neo_midnight_bridge_artifacts::relation::{RelationKind, RelationParamsV1};
use p3_field::{PrimeCharacteristicRing, PrimeField64};
use rand_chacha::{rand_core::SeedableRng, ChaCha20Rng};
use std::cmp;
use std::collections::BTreeMap;
use std::fs;
use std::path::PathBuf;
use std::process::Command;

const MIDNIGHT_MAX_K: u32 = 17;

type E = midnight_curves::Bls12;
type ParamsKZGNative = midnight_proofs::poly::kzg::params::ParamsKZG<E>;

#[derive(Default)]
struct KzgParamsCache {
    by_k: BTreeMap<u32, ParamsKZGNative>,
}

impl KzgParamsCache {
    fn get(&mut self, k: u32) -> &ParamsKZGNative {
        self.by_k.entry(k).or_insert_with(|| {
            let mut seed = [0u8; 32];
            seed[0] = 0xA5;
            seed[1] = (k & 0xFF) as u8;
            seed[2] = ((k >> 8) & 0xFF) as u8;
            seed[3] = ((k >> 16) & 0xFF) as u8;
            seed[4] = ((k >> 24) & 0xFF) as u8;
            ParamsKZGNative::unsafe_setup(k, ChaCha20Rng::from_seed(seed))
        })
    }
}

fn k_to_repr(k: &K) -> KRepr {
    let (c0, c1) = k.to_limbs_u64();
    KRepr { c0, c1 }
}

fn host_mle_eval(values: &[K], alpha: &[K]) -> K {
    assert_eq!(values.len(), 1usize << alpha.len());
    let mut cur = values.to_vec();
    for a in alpha {
        let next_len = cur.len() / 2;
        let mut next = Vec::with_capacity(next_len);
        for j in 0..next_len {
            let v0 = cur[2 * j];
            let v1 = cur[2 * j + 1];
            next.push(v0 + (*a) * (v1 - v0));
        }
        cur = next;
    }
    assert_eq!(cur.len(), 1);
    cur[0]
}

fn host_range_product(val: K, b: u32) -> K {
    let lo = -((b as i64) - 1);
    let hi = (b as i64) - 1;
    let mut prod = K::ONE;
    for t in lo..=hi {
        prod *= val - K::from(F::from_i64(t));
    }
    prod
}

fn host_chunk_sum(y_zcols: &[Vec<K>], alpha: &[K], gamma: K, b: u32, start_exp: usize) -> K {
    let mut g = K::ONE;
    for _ in 0..start_exp {
        g *= gamma;
    }
    let mut acc = K::ZERO;
    for yz in y_zcols {
        let val = host_mle_eval(yz, alpha);
        let rp = host_range_product(val, b);
        acc += g * rp;
        g *= gamma;
    }
    acc
}

fn host_fe_chunk_sum(
    y_rows_flat: &[Vec<K>],
    alpha_prime: &[K],
    gamma: K,
    k_total: usize,
    t: usize,
    start_idx: usize,
    count: usize,
) -> K {
    assert_eq!(y_rows_flat.len(), (k_total - 1) * t);
    assert!(start_idx + count <= y_rows_flat.len());

    // γ^i for i=0..k_total, and γ^k_total.
    let mut gamma_pows: Vec<K> = Vec::with_capacity(k_total + 1);
    gamma_pows.push(K::ONE);
    for i in 0..k_total {
        gamma_pows.push(gamma_pows[i] * gamma);
    }
    let gamma_to_k_total = gamma_pows[k_total];

    // (γ^k_total)^j for j=0..t-1.
    let mut gamma_k_pows: Vec<K> = Vec::with_capacity(t);
    gamma_k_pows.push(K::ONE);
    for j in 1..t {
        gamma_k_pows.push(gamma_k_pows[j - 1] * gamma_to_k_total);
    }

    let mut acc = K::ZERO;
    for flat in start_idx..start_idx + count {
        let out_idx = flat / t;
        let j = flat % t;
        let i_abs = out_idx + 1;

        let weight = gamma_pows[i_abs] * gamma_k_pows[j];
        let y_eval = host_mle_eval(&y_rows_flat[flat], alpha_prime);
        acc += weight * y_eval;
    }
    acc
}

fn choose_max_count_under_k(
    max_count: usize,
    mut model_for_count: impl FnMut(usize) -> (u32, usize),
) -> usize {
    let mut lo = 1usize;
    let mut hi = max_count;
    let mut best = 1usize;

    while lo <= hi {
        let mid = (lo + hi) / 2;
        let (k, _rows) = model_for_count(mid);
        if k <= MIDNIGHT_MAX_K {
            best = mid;
            lo = mid + 1;
        } else {
            hi = mid - 1;
        }
    }

    best
}

#[derive(Clone)]
struct MojoProofJob {
    pkg_path: PathBuf,
    ws_path: PathBuf,
    proof_path: PathBuf,
}

enum VerifyTask {
    NcChunk {
        job: MojoProofJob,
        pkg: neo_midnight_bridge_artifacts::nmbp::NmbpV3,
        rel: PiCcsNcChunkRelation,
        instance: PiCcsNcChunkInstance,
    },
    NcChunkAggSumcheck {
        job: MojoProofJob,
        pkg: neo_midnight_bridge_artifacts::nmbp::NmbpV3,
        rel: PiCcsNcChunkAggSumcheckRelation,
        instance: PiCcsNcChunkAggSumcheckInstance,
    },
    FeChunk {
        job: MojoProofJob,
        pkg: neo_midnight_bridge_artifacts::nmbp::NmbpV3,
        rel: PiCcsFeChunkRelation,
        instance: PiCcsFeChunkInstance,
    },
    FeChunkAggSumcheck {
        job: MojoProofJob,
        pkg: neo_midnight_bridge_artifacts::nmbp::NmbpV3,
        rel: PiCcsFeChunkAggSumcheckRelation,
        instance: PiCcsFeChunkAggSumcheckInstance,
    },
}

fn write_job_files(
    dir: &PathBuf,
    job_id: usize,
    pkg: &neo_midnight_bridge_artifacts::nmbp::NmbpV3,
    ws: &neo_midnight_bridge_artifacts::nmbws::NmbwsV2,
) -> anyhow::Result<MojoProofJob> {
    let pkg_path = dir.join(format!("job_{job_id}.nmbp"));
    let ws_path = dir.join(format!("job_{job_id}.nmbws"));
    let proof_path = dir.join(format!("job_{job_id}.proof.bin"));
    fs::write(&pkg_path, pkg.to_bytes()).context("write pkg")?;
    fs::write(&ws_path, ws.to_bytes()).context("write ws")?;
    Ok(MojoProofJob {
        pkg_path,
        ws_path,
        proof_path,
    })
}

fn run_mojo_prove_many_from_snapshot(
    manifest_dir: &PathBuf,
    tasks: &[VerifyTask],
    extra_mojo_args: &[&str],
) -> anyhow::Result<()> {
    if tasks.is_empty() {
        return Ok(());
    }

    let mojo_prog = manifest_dir.join("mojo/plonk_prove_many_from_snapshot.mojo");
    let mut cmd = Command::new("mojo");
    cmd.arg("run");
    for a in extra_mojo_args {
        cmd.arg(a);
    }
    cmd.arg(mojo_prog.to_str().unwrap());

    for t in tasks {
        let job = match t {
            VerifyTask::NcChunk { job, .. } => job,
            VerifyTask::NcChunkAggSumcheck { job, .. } => job,
            VerifyTask::FeChunk { job, .. } => job,
            VerifyTask::FeChunkAggSumcheck { job, .. } => job,
        };
        cmd.arg(job.pkg_path.to_str().unwrap())
            .arg(job.ws_path.to_str().unwrap())
            .arg(job.proof_path.to_str().unwrap());
    }

    let status = cmd.status().context("run mojo plonk_prove_many_from_snapshot")?;
    anyhow::ensure!(status.success(), "mojo plonk_prove_many_from_snapshot failed");
    Ok(())
}

fn run_mojo_plonk_kzg_pi_ccs_step1_bundle_poseidon2_batch_40_roundtrip(extra_mojo_args: &[&str]) -> anyhow::Result<()> {
    // Skip if Mojo is not installed.
    if Command::new("mojo").arg("--version").output().is_err() {
        eprintln!("skipping: `mojo` not found in PATH");
        return Ok(());
    }

    let manifest_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    let json_path = manifest_dir.join("../neo-fold/poseidon2-tests/poseidon2_ic_circuit_batch_40.json");
    let json = fs::read_to_string(&json_path).context("read poseidon2 batch-40 json")?;
    let export = neo_fold::test_export::parse_test_export_json(&json).context("parse test-export json")?;

    let target_folding_steps: usize = 2;
    let mut session = neo_fold::test_export::TestExportSession::new_from_circuit_json(&json)
        .map_err(|e| anyhow::anyhow!("session init failed: {e}"))?;
    for i in 0..target_folding_steps {
        let z = &export.witness[i % export.witness.len()];
        session
            .add_step_witness_u64(z)
            .map_err(|e| anyhow::anyhow!("add witness step failed: {e}"))?;
    }

    let (fold_run, _step_ms) = session
        .fold_and_prove_with_step_timings()
        .map_err(|e| anyhow::anyhow!("fold_and_prove failed: {e}"))?;
    assert_eq!(fold_run.steps.len(), target_folding_steps);
    assert!(session
        .verify(&fold_run)
        .map_err(|e| anyhow::anyhow!("verify failed: {e}"))?);

    let s = session.ccs();
    let m_pad = s.m.next_power_of_two().max(2);
    let ell_m = m_pad.trailing_zeros() as usize;
    let n_pad = s.n.next_power_of_two().max(2);
    let ell_n = n_pad.trailing_zeros() as usize;
    let d_pad = D.next_power_of_two();
    let ell_d = d_pad.trailing_zeros() as usize;
    let params_b = session.params().b;

    // Use step 1 (k_total > 1).
    let step1 = &fold_run.steps[1];
    let pi = &step1.fold.ccs_proof;
    let k_total = step1.fold.ccs_out.len();
    assert!(k_total > 1, "expected step1 k_total > 1");

    let dir = std::env::temp_dir().join(format!("neo-midnight-mojo-bridge-{}", std::process::id()));
    let _ = fs::remove_dir_all(&dir);
    fs::create_dir_all(&dir).context("create temp dir")?;
    let mut next_job_id: usize = 0;
    let mut tasks: Vec<VerifyTask> = Vec::new();

    let mut params_cache = KzgParamsCache::default();

    // -----------------------------
    // NC bundle
    // -----------------------------
    let want_nc_chals = ell_m + ell_d;
    assert_eq!(pi.sumcheck_challenges_nc.len(), want_nc_chals);
    let (_s_col_prime, alpha_prime_nc) = pi.sumcheck_challenges_nc.split_at(ell_m);
    let gamma = pi.challenges_public.gamma;

    let chunk_size = choose_max_count_under_k(k_total, |count| {
        let rel_try = PiCcsNcChunkRelation {
            ell_d,
            b: params_b,
            start_exp: k_total, // worst-case exponent
            count,
        };
        let circuit_try = midnight_zk_stdlib::MidnightCircuit::from_relation(&rel_try);
        let model_try = circuit_model::<_, 48, 32>(&circuit_try);
        (model_try.k, model_try.rows)
    });

    let y_zcols_all: Vec<Vec<K>> = step1
        .fold
        .ccs_out
        .iter()
        .map(|out| out.y_zcol.clone())
        .collect();
    assert_eq!(y_zcols_all.len(), k_total);

    let mut chunk_instances: Vec<KRepr> = Vec::new();
    for start_i in (0..k_total).step_by(chunk_size) {
        let count = cmp::min(chunk_size, k_total - start_i);
        let start_exp = start_i + 1;
        let yz_slice = &y_zcols_all[start_i..start_i + count];
        let chunk_sum = host_chunk_sum(yz_slice, alpha_prime_nc, gamma, params_b, start_exp);
        chunk_instances.push(k_to_repr(&chunk_sum));
    }

    let agg_chunk_index = chunk_instances.len().saturating_sub(1);
    let n_rounds_nc = pi.sumcheck_rounds_nc.len();
    let poly_len_nc = pi.sumcheck_rounds_nc[0].len();
    let initial_sum_nc = pi.sc_initial_sum_nc.as_ref().map(k_to_repr).unwrap_or(KRepr::ZERO);

    let inst_agg = PiCcsNcChunkAggSumcheckInstance {
        bundle_digest: [0u128; 2],
        sumcheck_challenges: pi.sumcheck_challenges_nc.iter().map(k_to_repr).collect(),
        gamma: k_to_repr(&gamma),
        beta_a: pi.challenges_public.beta_a.iter().map(k_to_repr).collect(),
        beta_m: pi.challenges_public.beta_m.iter().map(k_to_repr).collect(),
        chunk_sums: chunk_instances.clone(),
        initial_sum: initial_sum_nc,
        final_sum_nc: k_to_repr(&pi.sumcheck_final_nc),
    };

    for (chunk_idx, start_i) in (0..k_total).step_by(chunk_size).enumerate() {
        let count = cmp::min(chunk_size, k_total - start_i);
        let start_exp = start_i + 1;
        let yz_slice = &y_zcols_all[start_i..start_i + count];

        if chunk_idx == agg_chunk_index {
            let rel = PiCcsNcChunkAggSumcheckRelation {
                n_rounds: n_rounds_nc,
                poly_len: poly_len_nc,
                ell_d,
                ell_m,
                b: params_b,
                start_exp,
                count,
                n_chunks: chunk_instances.len(),
                chunk_index: chunk_idx,
            };
            let witness = PiCcsNcChunkAggSumcheckWitness {
                rounds: pi
                    .sumcheck_rounds_nc
                    .iter()
                    .map(|r| r.iter().map(k_to_repr).collect())
                    .collect(),
                y_zcol: yz_slice
                    .iter()
                    .map(|yz| yz.iter().map(k_to_repr).collect())
                    .collect(),
            };

            let circuit = midnight_zk_stdlib::MidnightCircuit::from_relation(&rel);
            let model = circuit_model::<_, 48, 32>(&circuit);
            assert!(model.k <= MIDNIGHT_MAX_K, "expected k<=MIDNIGHT_MAX_K for chunk+agg+sumcheck");

            let params = params_cache.get(model.k);
            let pkg = export_package_with_params_v3(
                RelationKind::PiCcsNcChunkAggSumcheck,
                &RelationParamsV1::PiCcsNcChunkAggSumcheck {
                    version: 1,
                    n_rounds: rel.n_rounds,
                    poly_len: rel.poly_len,
                    ell_d,
                    ell_m,
                    b: params_b,
                    start_exp,
                    count,
                    n_chunks: rel.n_chunks,
                    chunk_index: rel.chunk_index,
                },
                &rel,
                params,
            )?;

            let pi = PiCcsNcChunkAggSumcheckRelation::format_instance(&inst_agg).expect("format_instance");
            let com_inst = PiCcsNcChunkAggSumcheckRelation::format_committed_instances(&witness);
            let circuit = midnight_zk_stdlib::MidnightCircuit::new(
                &rel,
                Value::known(inst_agg.clone()),
                Value::known(witness),
                None,
            );
            let ws = export_witness_snapshot_v2(pkg.k, &circuit, vec![com_inst, pi])?;
            let job = write_job_files(&dir, next_job_id, &pkg, &ws)?;
            next_job_id += 1;
            tasks.push(VerifyTask::NcChunkAggSumcheck {
                job,
                pkg,
                rel,
                instance: inst_agg.clone(),
            });
        } else {
            let rel = PiCcsNcChunkRelation {
                ell_d,
                b: params_b,
                start_exp,
                count,
            };
            let instance = PiCcsNcChunkInstance {
                bundle_digest: [0u128; 2],
                chunk_sum: chunk_instances[chunk_idx],
                alpha_prime: alpha_prime_nc.iter().map(k_to_repr).collect(),
                gamma: k_to_repr(&gamma),
            };
            let witness = PiCcsNcChunkWitness {
                y_zcol: yz_slice
                    .iter()
                    .map(|yz| yz.iter().map(k_to_repr).collect())
                    .collect(),
            };

            let circuit = midnight_zk_stdlib::MidnightCircuit::from_relation(&rel);
            let model = circuit_model::<_, 48, 32>(&circuit);
            assert!(model.k <= MIDNIGHT_MAX_K, "expected k<=MIDNIGHT_MAX_K for nc chunk");

            let params = params_cache.get(model.k);
            let pkg = export_package_with_params_v3(
                RelationKind::PiCcsNcChunk,
                &RelationParamsV1::PiCcsNcChunk {
                    version: 1,
                    ell_d,
                    b: params_b,
                    start_exp,
                    count,
                },
                &rel,
                params,
            )?;

            let pi = PiCcsNcChunkRelation::format_instance(&instance).expect("format_instance");
            let com_inst = PiCcsNcChunkRelation::format_committed_instances(&witness);
            let circuit = midnight_zk_stdlib::MidnightCircuit::new(
                &rel,
                Value::known(instance.clone()),
                Value::known(witness),
                None,
            );
            let ws = export_witness_snapshot_v2(pkg.k, &circuit, vec![com_inst, pi])?;
            let job = write_job_files(&dir, next_job_id, &pkg, &ws)?;
            next_job_id += 1;
            tasks.push(VerifyTask::NcChunk {
                job,
                pkg,
                rel,
                instance,
            });
        }
    }

    // -----------------------------
    // FE bundle
    // -----------------------------
    let n_rounds_fe = pi.sumcheck_rounds.len();
    let poly_len_fe = pi.sumcheck_rounds[0].len();
    let initial_sum_fe = pi.sc_initial_sum.as_ref().map(k_to_repr).unwrap_or(KRepr::ZERO);
    let final_sum_fe = k_to_repr(&pi.sumcheck_final);

    let want_fe_chals = ell_n + ell_d;
    assert_eq!(pi.sumcheck_challenges.len(), want_fe_chals);
    let (_r_prime_fe, alpha_prime_fe) = pi.sumcheck_challenges.split_at(ell_n);

    let poly_terms: Vec<SparsePolyTermRepr> =
        s.f.terms()
            .iter()
            .map(|t| SparsePolyTermRepr {
                coeff: t.coeff.as_canonical_u64(),
                exps: t.exps.clone(),
            })
            .collect();
    let poly = SparsePolyRepr {
        t: s.t(),
        terms: poly_terms,
    };

    // me_inputs_r is taken from the step-0 DEC children, which are step-1 ME inputs.
    assert!(
        !fold_run.steps[0].fold.dec_children.is_empty(),
        "expected step-0 dec_children non-empty"
    );
    let me_inputs_r = &fold_run.steps[0].fold.dec_children[0].r;
    assert_eq!(me_inputs_r.len(), ell_n);

    let out0 = &step1.fold.ccs_out[0];
    let t_fe = s.t();
    assert_eq!(out0.y_scalars.len(), t_fe);

    let mut y_rows_flat: Vec<Vec<K>> = Vec::with_capacity((k_total - 1) * t_fe);
    for (i_abs, out) in step1.fold.ccs_out.iter().enumerate().skip(1) {
        assert_eq!(out.y.len(), t_fe, "ccs_out[{i_abs}].y len mismatch");
        for j in 0..t_fe {
            assert_eq!(
                out.y[j].len(),
                1usize << ell_d,
                "ccs_out[{i_abs}].y[{j}] must be padded"
            );
            y_rows_flat.push(out.y[j].clone());
        }
    }
    let total_pairs = y_rows_flat.len();
    assert_eq!(total_pairs, (k_total - 1) * t_fe);

    let fe_chunk_size = choose_max_count_under_k(total_pairs, |count| {
        let rel_try = PiCcsFeChunkRelation {
            ell_d,
            k_total,
            t: t_fe,
            start_idx: total_pairs.saturating_sub(count),
            count,
        };
        let circuit_try = midnight_zk_stdlib::MidnightCircuit::from_relation(&rel_try);
        let model_try = circuit_model::<_, 48, 32>(&circuit_try);
        (model_try.k, model_try.rows)
    });

    let mut fe_chunk_instances: Vec<KRepr> = Vec::new();
    for start_idx in (0..total_pairs).step_by(fe_chunk_size) {
        let count = cmp::min(fe_chunk_size, total_pairs - start_idx);
        let cs = host_fe_chunk_sum(
            &y_rows_flat,
            alpha_prime_fe,
            pi.challenges_public.gamma,
            k_total,
            t_fe,
            start_idx,
            count,
        );
        fe_chunk_instances.push(k_to_repr(&cs));
    }

    // Prove each FE chunk (bind chunk sums).
    for (chunk_idx, start_idx) in (0..total_pairs).step_by(fe_chunk_size).enumerate() {
        let count = cmp::min(fe_chunk_size, total_pairs - start_idx);
        let y_rows = y_rows_flat[start_idx..start_idx + count]
            .iter()
            .map(|row| row.iter().map(k_to_repr).collect::<Vec<_>>())
            .collect::<Vec<_>>();

        let rel = PiCcsFeChunkRelation {
            ell_d,
            k_total,
            t: t_fe,
            start_idx,
            count,
        };
        let instance = PiCcsFeChunkInstance {
            bundle_digest: [0u128; 2],
            chunk_sum: fe_chunk_instances[chunk_idx],
            alpha_prime: alpha_prime_fe.iter().map(k_to_repr).collect(),
            gamma: k_to_repr(&pi.challenges_public.gamma),
        };
        let witness = PiCcsFeChunkWitness { y_rows };

        let circuit = midnight_zk_stdlib::MidnightCircuit::from_relation(&rel);
        let model = circuit_model::<_, 48, 32>(&circuit);
        assert!(model.k <= MIDNIGHT_MAX_K, "expected k<=MIDNIGHT_MAX_K for fe chunk");

        let params = params_cache.get(model.k);
        let pkg = export_package_with_params_v3(
            RelationKind::PiCcsFeChunk,
            &RelationParamsV1::PiCcsFeChunk {
                version: 1,
                ell_d,
                k_total,
                t: t_fe,
                start_idx,
                count,
            },
            &rel,
            params,
        )?;

        let pi = PiCcsFeChunkRelation::format_instance(&instance).expect("format_instance");
        let com_inst = PiCcsFeChunkRelation::format_committed_instances(&witness);
        let circuit = midnight_zk_stdlib::MidnightCircuit::new(
            &rel,
            Value::known(instance.clone()),
            Value::known(witness),
            None,
        );
        let ws = export_witness_snapshot_v2(pkg.k, &circuit, vec![com_inst, pi])?;
        let job = write_job_files(&dir, next_job_id, &pkg, &ws)?;
        next_job_id += 1;
        tasks.push(VerifyTask::FeChunk {
            job,
            pkg,
            rel,
            instance,
        });
    }

    // One combined proof for: FE sumcheck + FE terminal identity aggregate (no chunk binding).
    let rel_fe_sc_agg = PiCcsFeChunkAggSumcheckRelation {
        n_rounds: n_rounds_fe,
        poly_len: poly_len_fe,
        ell_n,
        ell_d,
        k_total,
        poly: poly.clone(),
        start_idx: 0,
        count: 0,
        n_chunks: fe_chunk_instances.len(),
        chunk_index: 0,
    };
    let inst_fe_sc_agg = PiCcsFeChunkAggSumcheckInstance {
        bundle_digest: [0u128; 2],
        sumcheck_challenges: pi.sumcheck_challenges.iter().map(k_to_repr).collect(),
        gamma: k_to_repr(&pi.challenges_public.gamma),
        alpha: pi.challenges_public.alpha.iter().map(k_to_repr).collect(),
        beta_a: pi.challenges_public.beta_a.iter().map(k_to_repr).collect(),
        beta_r: pi.challenges_public.beta_r.iter().map(k_to_repr).collect(),
        chunk_sums: fe_chunk_instances.clone(),
        initial_sum: initial_sum_fe,
        final_sum: final_sum_fe,
    };
    let wit_fe_sc_agg = PiCcsFeChunkAggSumcheckWitness {
        rounds: pi
            .sumcheck_rounds
            .iter()
            .map(|r| r.iter().map(k_to_repr).collect())
            .collect(),
        me_inputs_r: me_inputs_r.iter().map(k_to_repr).collect(),
        y_scalars_0: out0.y_scalars.iter().map(k_to_repr).collect(),
        y_rows: Vec::new(),
    };

    let circuit_fe_sc_agg = midnight_zk_stdlib::MidnightCircuit::from_relation(&rel_fe_sc_agg);
    let model_fe_sc_agg = circuit_model::<_, 48, 32>(&circuit_fe_sc_agg);
    assert!(model_fe_sc_agg.k <= MIDNIGHT_MAX_K, "expected k<=MIDNIGHT_MAX_K for fe sumcheck+agg");

    let params_fe_sc_agg = params_cache.get(model_fe_sc_agg.k);
    let pkg_fe_sc_agg = export_package_with_params_v3(
        RelationKind::PiCcsFeChunkAggSumcheck,
        &RelationParamsV1::PiCcsFeChunkAggSumcheck {
            version: 1,
            n_rounds: rel_fe_sc_agg.n_rounds,
            poly_len: rel_fe_sc_agg.poly_len,
            ell_n,
            ell_d,
            k_total,
            poly: rel_fe_sc_agg.poly.clone(),
            start_idx: rel_fe_sc_agg.start_idx,
            count: rel_fe_sc_agg.count,
            n_chunks: rel_fe_sc_agg.n_chunks,
            chunk_index: rel_fe_sc_agg.chunk_index,
        },
        &rel_fe_sc_agg,
        params_fe_sc_agg,
    )?;

    let pi = PiCcsFeChunkAggSumcheckRelation::format_instance(&inst_fe_sc_agg).expect("format_instance");
    let com_inst = PiCcsFeChunkAggSumcheckRelation::format_committed_instances(&wit_fe_sc_agg);
    let circuit = midnight_zk_stdlib::MidnightCircuit::new(
        &rel_fe_sc_agg,
        Value::known(inst_fe_sc_agg.clone()),
        Value::known(wit_fe_sc_agg),
        None,
    );
    let ws = export_witness_snapshot_v2(pkg_fe_sc_agg.k, &circuit, vec![com_inst, pi])?;
    let job = write_job_files(&dir, next_job_id, &pkg_fe_sc_agg, &ws)?;
    tasks.push(VerifyTask::FeChunkAggSumcheck {
        job,
        pkg: pkg_fe_sc_agg,
        rel: rel_fe_sc_agg,
        instance: inst_fe_sc_agg.clone(),
    });

    // Batch-prove all tasks in one Mojo process (caches parsed KZG params by k).
    tasks.sort_by_key(|t| match t {
        VerifyTask::NcChunk { pkg, .. } => pkg.k,
        VerifyTask::NcChunkAggSumcheck { pkg, .. } => pkg.k,
        VerifyTask::FeChunk { pkg, .. } => pkg.k,
        VerifyTask::FeChunkAggSumcheck { pkg, .. } => pkg.k,
    });
    run_mojo_prove_many_from_snapshot(&manifest_dir, &tasks, extra_mojo_args)?;

    // Verify all proofs in Rust.
    for t in tasks {
        let (pkg, proof_path) = match &t {
            VerifyTask::NcChunk { pkg, job, .. } => (pkg, &job.proof_path),
            VerifyTask::NcChunkAggSumcheck { pkg, job, .. } => (pkg, &job.proof_path),
            VerifyTask::FeChunk { pkg, job, .. } => (pkg, &job.proof_path),
            VerifyTask::FeChunkAggSumcheck { pkg, job, .. } => (pkg, &job.proof_path),
        };
        let proof = fs::read(proof_path).context("read proof")?;

        let mut params_reader: &[u8] = &pkg.params_bytes;
        let params: ParamsKZG<Bls12> = ParamsKZG::read_custom(&mut params_reader, SerdeFormat::RawBytesUnchecked)
            .context("ParamsKZG::read_custom")?;
        let params_v = params.verifier_params();

        match t {
            VerifyTask::NcChunk {
                pkg: _,
                job: _,
                rel,
                instance,
            } => {
                let vk = midnight_zk_stdlib::setup_vk(&params, &rel);
                midnight_zk_stdlib::verify::<PiCcsNcChunkRelation, TranscriptHash>(&params_v, &vk, &instance, None, &proof)
                    .expect("verify nc chunk");
            }
            VerifyTask::NcChunkAggSumcheck {
                pkg: _,
                job: _,
                rel,
                instance,
            } => {
                let vk = midnight_zk_stdlib::setup_vk(&params, &rel);
                midnight_zk_stdlib::verify::<PiCcsNcChunkAggSumcheckRelation, TranscriptHash>(
                    &params_v, &vk, &instance, None, &proof,
                )
                .expect("verify nc chunk+agg+sumcheck");
            }
            VerifyTask::FeChunk {
                pkg: _,
                job: _,
                rel,
                instance,
            } => {
                let vk = midnight_zk_stdlib::setup_vk(&params, &rel);
                midnight_zk_stdlib::verify::<PiCcsFeChunkRelation, TranscriptHash>(&params_v, &vk, &instance, None, &proof)
                    .expect("verify fe chunk");
            }
            VerifyTask::FeChunkAggSumcheck {
                pkg: _,
                job: _,
                rel,
                instance,
            } => {
                let vk = midnight_zk_stdlib::setup_vk(&params, &rel);
                midnight_zk_stdlib::verify::<PiCcsFeChunkAggSumcheckRelation, TranscriptHash>(
                    &params_v, &vk, &instance, None, &proof,
                )
                .expect("verify fe sumcheck+agg");
            }
        }
    }

    Ok(())
}

#[test]
#[ignore = "benchmark-style bundle parity; run with --ignored --nocapture"]
fn mojo_plonk_kzg_pi_ccs_step1_bundle_poseidon2_batch_40_roundtrip() -> anyhow::Result<()> {
    run_mojo_plonk_kzg_pi_ccs_step1_bundle_poseidon2_batch_40_roundtrip(&[])
}

#[cfg(target_os = "macos")]
#[test]
#[ignore = "benchmark-style bundle parity (Metal FFT enabled); run with --ignored --nocapture"]
fn mojo_plonk_kzg_pi_ccs_step1_bundle_poseidon2_batch_40_roundtrip_metal_fft() -> anyhow::Result<()> {
    run_mojo_plonk_kzg_pi_ccs_step1_bundle_poseidon2_batch_40_roundtrip(&["-D", "NMB_ENABLE_METAL_GPU=true"])
}
