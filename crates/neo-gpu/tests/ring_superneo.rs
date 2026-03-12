use std::ffi::OsString;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::sync::OnceLock;

use libloading::Library;
use neo_gpu::{connect, DeviceApi, FlatK, FlatRq, MojoBackendConfig};
use neo_math::{ct, superneo_bar_block, superneo_bar_matrix, Fq, KExtensions, Rq, D, K};
use p3_field::{PrimeCharacteristicRing, PrimeField64};

type RqMulFn = unsafe extern "C" fn(u64, *mut u64, *mut u64, *mut u64) -> i32;
type RqCtFn = unsafe extern "C" fn(*mut u64, *mut u64) -> i32;
type SuperneoBarBlockFn = unsafe extern "C" fn(*mut u64, *mut u64, *mut u64) -> i32;
type SuperneoRowDotBlocksFn = unsafe extern "C" fn(*mut u64, u64, *mut u64, u64, *mut u64) -> i32;

fn real_mojo_library_name() -> &'static str {
    #[cfg(target_os = "macos")]
    {
        "libnightstream_mojo_gpu.dylib"
    }
    #[cfg(target_os = "linux")]
    {
        "libnightstream_mojo_gpu.so"
    }
    #[cfg(target_os = "windows")]
    {
        "nightstream_mojo_gpu.dll"
    }
}

fn pixi_bin() -> OsString {
    if let Some(home) = std::env::var_os("HOME") {
        let candidate = PathBuf::from(home).join(".pixi").join("bin").join("pixi");
        if candidate.is_file() {
            return candidate.into_os_string();
        }
    }
    OsString::from("pixi")
}

fn build_real_mojo_library() -> &'static Path {
    static LIB_PATH: OnceLock<PathBuf> = OnceLock::new();
    LIB_PATH.get_or_init(|| {
        let project_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
            .join("..")
            .join("..")
            .join("gpu")
            .join("mojo");
        let output_dir = project_dir.join("build");
        let output = output_dir.join(real_mojo_library_name());
        std::fs::create_dir_all(&output_dir).expect("create mojo build directory");

        let status = Command::new(pixi_bin())
            .arg("run")
            .arg("mojo")
            .arg("build")
            .arg("--emit")
            .arg("shared-lib")
            .arg("src/lib.mojo")
            .arg("-o")
            .arg(&output)
            .current_dir(&project_dir)
            .status()
            .expect("spawn mojo build");
        assert!(status.success(), "real mojo gpu build failed");

        output
            .canonicalize()
            .expect("canonical real mojo gpu library path")
    })
}

fn rq_mul_cpu(lhs: [u64; D], rhs: [u64; D]) -> [u64; D] {
    Rq(lhs.map(Fq::from_u64))
        .mul(&Rq(rhs.map(Fq::from_u64)))
        .0
        .map(|x| x.as_canonical_u64())
}

fn rq_ct_cpu(words: [u64; D]) -> u64 {
    ct(&Rq(words.map(Fq::from_u64))).as_canonical_u64()
}

fn bar_block_cpu(matrix: &[[Fq; D]; D], block: [u64; D]) -> [u64; D] {
    let mut out = [Fq::ZERO; D];
    let block_f = block.map(Fq::from_u64);
    for row in 0..D {
        let mut acc = Fq::ZERO;
        for (col, value) in block_f.iter().enumerate() {
            acc += matrix[row][col] * *value;
        }
        out[row] = acc;
    }
    out.map(|x| x.as_canonical_u64())
}

fn superneo_row_dot_cpu(bar_blocks: &[[u64; D]], z: &[FlatK]) -> FlatK {
    let mut acc = K::ZERO;
    for (blk_idx, block) in bar_blocks.iter().enumerate() {
        let base = blk_idx * D;
        let mut z_re = [Fq::ZERO; D];
        let mut z_im = [Fq::ZERO; D];
        for i in 0..D {
            if base + i < z.len() {
                z_re[i] = Fq::from_u64(z[base + i].re);
                z_im[i] = Fq::from_u64(z[base + i].im);
            }
        }
        let a_ring = Rq(block.map(Fq::from_u64));
        let re = ct(&a_ring.mul(&Rq(z_re)));
        let im = ct(&a_ring.mul(&Rq(z_im)));
        acc += K::from_coeffs([re, im]);
    }
    let [re, im] = acc.as_coeffs();
    FlatK {
        re: re.as_canonical_u64(),
        im: im.as_canonical_u64(),
    }
}

fn sample_block(seed: u64) -> [u64; D] {
    std::array::from_fn(|i| seed.wrapping_mul(17).wrapping_add((i as u64) * 9 + 3))
}

fn sample_z(len: usize, seed: u64) -> Vec<FlatK> {
    (0..len)
        .map(|i| FlatK {
            re: seed.wrapping_mul(31).wrapping_add((i as u64) * 7 + 5),
            im: seed.wrapping_mul(13).wrapping_add((i as u64) * 11 + 1),
        })
        .collect()
}

#[test]
#[ignore = "requires local Mojo toolchain"]
fn real_mojo_rq_mul_and_ct_match_cpu_reference() {
    let library_path = build_real_mojo_library();
    let lib = unsafe { Library::new(library_path) }.expect("load real mojo gpu library");
    let rq_mul = unsafe {
        *lib.get::<RqMulFn>(b"nightstream_gpu_rq_mul_u64x54\0")
            .expect("load rq mul symbol")
    };
    let rq_ct = unsafe {
        *lib.get::<RqCtFn>(b"nightstream_gpu_rq_ct_u64x54\0")
            .expect("load rq ct symbol")
    };

    for seed in [3u64, 7, 29] {
        let lhs = sample_block(seed);
        let rhs = sample_block(seed + 100);
        let cpu = rq_mul_cpu(lhs, rhs);

        let mut lhs_words = lhs;
        let mut rhs_words = rhs;
        let mut out_words = [0u64; D];
        let status = unsafe {
            rq_mul(
                1,
                lhs_words.as_mut_ptr(),
                rhs_words.as_mut_ptr(),
                out_words.as_mut_ptr(),
            )
        };
        assert_eq!(status, 0, "rq mul status");
        assert_eq!(out_words, cpu, "rq mul parity seed={seed}");

        let mut ct_out = [0u64; 1];
        let status = unsafe { rq_ct(out_words.as_mut_ptr(), ct_out.as_mut_ptr()) };
        assert_eq!(status, 0, "rq ct status");
        assert_eq!(ct_out[0], rq_ct_cpu(cpu), "rq ct parity seed={seed}");
    }
}

#[test]
#[ignore = "requires local Mojo toolchain"]
fn real_mojo_superneo_bar_block_matches_cpu_reference() {
    let library_path = build_real_mojo_library();
    let lib = unsafe { Library::new(library_path) }.expect("load real mojo gpu library");
    let bar_block = unsafe {
        *lib.get::<SuperneoBarBlockFn>(b"nightstream_gpu_superneo_bar_block_u64x54\0")
            .expect("load superneo bar block symbol")
    };

    let matrix = superneo_bar_matrix();
    let mut matrix_words = [0u64; D * D];
    for row in 0..D {
        for col in 0..D {
            matrix_words[row * D + col] = matrix[row][col].as_canonical_u64();
        }
    }

    for seed in [5u64, 11, 23] {
        let block = sample_block(seed);
        let cpu = superneo_bar_block(block.map(Fq::from_u64)).map(|x| x.as_canonical_u64());
        let expected = bar_block_cpu(matrix, block);
        assert_eq!(cpu, expected, "rust matrix helper parity seed={seed}");

        let mut matrix_mut = matrix_words;
        let mut block_mut = block;
        let mut out_words = [0u64; D];
        let status = unsafe { bar_block(matrix_mut.as_mut_ptr(), block_mut.as_mut_ptr(), out_words.as_mut_ptr()) };
        assert_eq!(status, 0, "superneo bar block status");
        assert_eq!(out_words, cpu, "superneo bar block parity seed={seed}");
    }
}

#[test]
#[ignore = "requires local Mojo toolchain"]
fn real_mojo_superneo_row_dot_blocks_matches_cpu_reference() {
    let library_path = build_real_mojo_library();
    let lib = unsafe { Library::new(library_path) }.expect("load real mojo gpu library");
    let row_dot = unsafe {
        *lib.get::<SuperneoRowDotBlocksFn>(b"nightstream_gpu_superneo_row_dot_blocks\0")
            .expect("load superneo row dot symbol")
    };

    let matrix = superneo_bar_matrix();
    let original_blocks = [sample_block(41), sample_block(97)];
    let transformed_blocks: Vec<[u64; D]> = original_blocks
        .iter()
        .map(|block| bar_block_cpu(matrix, *block))
        .collect();
    let z = sample_z(D + 13, 55);
    let cpu = superneo_row_dot_cpu(&transformed_blocks, &z);

    let mut bar_words = transformed_blocks
        .iter()
        .flat_map(|block| block.iter().copied())
        .collect::<Vec<_>>();
    let mut z_words = z
        .iter()
        .flat_map(|value| [value.re, value.im])
        .collect::<Vec<_>>();
    let mut out_words = [0u64; 2];
    let status = unsafe {
        row_dot(
            bar_words.as_mut_ptr(),
            transformed_blocks.len() as u64,
            z_words.as_mut_ptr(),
            z.len() as u64,
            out_words.as_mut_ptr(),
        )
    };
    assert_eq!(status, 0, "superneo row dot status");
    assert_eq!(
        FlatK {
            re: out_words[0],
            im: out_words[1]
        },
        cpu
    );
}

#[test]
#[ignore = "requires local Mojo toolchain"]
fn real_mojo_session_ring_and_superneo_match_cpu_reference() {
    let session = connect(&MojoBackendConfig::new(DeviceApi::Cpu).with_library_path(build_real_mojo_library()))
        .expect("open real mojo session");

    let lhs = sample_block(17);
    let rhs = sample_block(117);
    let lhs_rq = FlatRq { coeffs: lhs };
    let rhs_rq = FlatRq { coeffs: rhs };
    let rq_mul = session.rq_mul_u64x54(&lhs_rq, &rhs_rq).expect("rq mul");
    assert_eq!(rq_mul.coeffs, rq_mul_cpu(lhs, rhs));
    assert_eq!(session.rq_ct_u64x54(&rq_mul).expect("rq ct"), rq_ct_cpu(rq_mul.coeffs));

    let matrix = superneo_bar_matrix();
    let matrix_words = std::array::from_fn(|row| std::array::from_fn(|col| matrix[row][col].as_canonical_u64()));
    let block = sample_block(33);
    let bar_block = session
        .superneo_bar_block_u64x54(&matrix_words, &block)
        .expect("superneo bar block");
    assert_eq!(bar_block, bar_block_cpu(matrix, block));

    let other_block = sample_block(77);
    let bar_blocks = vec![
        session
            .superneo_bar_block_u64x54(&matrix_words, &block)
            .expect("bar block 0"),
        session
            .superneo_bar_block_u64x54(&matrix_words, &other_block)
            .expect("bar block 1"),
    ];
    let z = sample_z(D + 13, 55);
    let dot = session
        .superneo_row_dot_blocks(&bar_blocks, &z)
        .expect("superneo row dot");
    assert_eq!(dot, superneo_row_dot_cpu(&bar_blocks, &z));
}
