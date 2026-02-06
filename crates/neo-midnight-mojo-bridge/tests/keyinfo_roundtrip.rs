use anyhow::{anyhow, Context};
use neo_midnight_bridge::relations::GoldilocksMulRelation;
use neo_midnight_bridge_artifacts::nmbp::export_package_v3;
use neo_midnight_bridge_artifacts::relation::{RelationKind, RelationParamsV1};
use std::fs;
use std::path::PathBuf;
use std::process::Command;

fn read_u8(buf: &[u8], pos: &mut usize) -> anyhow::Result<u8> {
    let b = *buf.get(*pos).ok_or_else(|| anyhow!("unexpected EOF"))?;
    *pos += 1;
    Ok(b)
}

fn read_u32_le(buf: &[u8], pos: &mut usize) -> anyhow::Result<u32> {
    let end = pos.checked_add(4).ok_or_else(|| anyhow!("overflow"))?;
    let bytes: [u8; 4] = buf.get(*pos..end).ok_or_else(|| anyhow!("unexpected EOF"))?.try_into()?;
    *pos = end;
    Ok(u32::from_le_bytes(bytes))
}

fn read_u32_be(buf: &[u8], pos: &mut usize) -> anyhow::Result<u32> {
    let end = pos.checked_add(4).ok_or_else(|| anyhow!("overflow"))?;
    let bytes: [u8; 4] = buf.get(*pos..end).ok_or_else(|| anyhow!("unexpected EOF"))?.try_into()?;
    *pos = end;
    Ok(u32::from_be_bytes(bytes))
}

fn skip(buf: &[u8], pos: &mut usize, n: usize) -> anyhow::Result<()> {
    let end = pos.checked_add(n).ok_or_else(|| anyhow!("overflow"))?;
    if end > buf.len() {
        return Err(anyhow!("unexpected EOF"));
    }
    *pos = end;
    Ok(())
}

fn skip_string(buf: &[u8], pos: &mut usize) -> anyhow::Result<()> {
    let n = read_u32_le(buf, pos)? as usize;
    skip(buf, pos, n)
}

fn skip_expr(buf: &[u8], pos: &mut usize) -> anyhow::Result<()> {
    let tag = read_u8(buf, pos)?;
    match tag {
        0 => skip(buf, pos, 32),                    // Constant
        1 => skip(buf, pos, 4 + 1),                 // Selector
        2 => skip(buf, pos, 4 + 4),                 // Fixed
        3 => skip(buf, pos, 4 + 4 + 1),             // Advice
        4 => skip(buf, pos, 4 + 4),                 // Instance
        5 => skip(buf, pos, 4 + 1),                 // Challenge
        6 => skip_expr(buf, pos),                   // Negated
        7 | 8 => {
            skip_expr(buf, pos)?;
            skip_expr(buf, pos)
        } // Sum / Product
        9 => {
            skip_expr(buf, pos)?;
            skip(buf, pos, 32)
        } // Scaled
        _ => Err(anyhow!("invalid expr tag: {tag}")),
    }
}

fn parse_cs_summary(cs_bytes: &[u8]) -> anyhow::Result<(u32, u32, u32, u32, u32, u32)> {
    let mut pos = 0usize;
    let fixed = read_u32_le(cs_bytes, &mut pos)?;
    let advice = read_u32_le(cs_bytes, &mut pos)?;
    let instance = read_u32_le(cs_bytes, &mut pos)?;
    let _selectors = read_u32_le(cs_bytes, &mut pos)?;
    let _challenges = read_u32_le(cs_bytes, &mut pos)?;

    let blinding = read_u32_le(cs_bytes, &mut pos)?;
    let degree = read_u32_le(cs_bytes, &mut pos)?;

    let advice_phases_len = read_u32_le(cs_bytes, &mut pos)? as usize;
    skip(cs_bytes, &mut pos, advice_phases_len)?;
    let challenge_phases_len = read_u32_le(cs_bytes, &mut pos)? as usize;
    skip(cs_bytes, &mut pos, challenge_phases_len)?;

    let _unblinded_advice = read_u32_le(cs_bytes, &mut pos)?;

    let gates_len = read_u32_le(cs_bytes, &mut pos)? as usize;
    for _ in 0..gates_len {
        skip_string(cs_bytes, &mut pos)?; // gate name
        let polys_len = read_u32_le(cs_bytes, &mut pos)? as usize;
        for _ in 0..polys_len {
            skip_string(cs_bytes, &mut pos)?; // constraint name
            skip_expr(cs_bytes, &mut pos)?;
        }
    }

    let fixed_q_len = read_u32_le(cs_bytes, &mut pos)? as usize;
    for _ in 0..fixed_q_len {
        _ = read_u32_le(cs_bytes, &mut pos)?;
        _ = read_u32_le(cs_bytes, &mut pos)?;
    }

    let advice_q_len = read_u32_le(cs_bytes, &mut pos)? as usize;
    for _ in 0..advice_q_len {
        _ = read_u32_le(cs_bytes, &mut pos)?;
        _ = read_u8(cs_bytes, &mut pos)?;
        _ = read_u32_le(cs_bytes, &mut pos)?;
    }

    let inst_q_len = read_u32_le(cs_bytes, &mut pos)? as usize;
    for _ in 0..inst_q_len {
        _ = read_u32_le(cs_bytes, &mut pos)?;
        _ = read_u32_le(cs_bytes, &mut pos)?;
    }

    let perm_cols = read_u32_le(cs_bytes, &mut pos)?;
    Ok((fixed, advice, instance, blinding, degree, perm_cols))
}

fn parse_vk_summary(vk_bytes: &[u8]) -> anyhow::Result<(u8, u32)> {
    let mut pos = 0usize;
    _ = read_u8(vk_bytes, &mut pos)?; // version byte
    let k = read_u8(vk_bytes, &mut pos)?;
    let fixed = read_u32_le(vk_bytes, &mut pos)?;
    Ok((k, fixed))
}

fn parse_pk_summary(pk_bytes: &[u8], perm_cols: u32) -> anyhow::Result<(u8, u32, u32, u32, u32, u32)> {
    let mut pos = 0usize;
    _ = read_u8(pk_bytes, &mut pos)?; // version byte
    let k = read_u8(pk_bytes, &mut pos)?;
    let fixed = read_u32_le(pk_bytes, &mut pos)?;

    // Skip vk commitments: fixed + permutation (uncompressed points, 96 bytes each).
    let skip_points = (fixed as usize)
        .checked_add(perm_cols as usize)
        .ok_or_else(|| anyhow!("overflow"))?
        .checked_mul(96)
        .ok_or_else(|| anyhow!("overflow"))?;
    skip(pk_bytes, &mut pos, skip_points)?;

    // fixed_values polys (big-endian u32 lengths).
    let fixed_values_polys = read_u32_be(pk_bytes, &mut pos)?;
    let mut fixed_values_poly_len = 0u32;
    for i in 0..fixed_values_polys {
        let poly_len = read_u32_be(pk_bytes, &mut pos)?;
        if i == 0 {
            fixed_values_poly_len = poly_len;
        }
        skip(pk_bytes, &mut pos, (poly_len as usize) * 32)?;
    }

    // permutation proving key polys.
    let perm_polys = read_u32_be(pk_bytes, &mut pos)?;
    let mut perm_poly_len = 0u32;
    for i in 0..perm_polys {
        let poly_len = read_u32_be(pk_bytes, &mut pos)?;
        if i == 0 {
            perm_poly_len = poly_len;
        }
        skip(pk_bytes, &mut pos, (poly_len as usize) * 32)?;
    }

    if pos != pk_bytes.len() {
        return Err(anyhow!("trailing bytes in pk_bytes: {} remaining", pk_bytes.len() - pos));
    }
    Ok((
        k,
        fixed,
        fixed_values_polys,
        fixed_values_poly_len,
        perm_polys,
        perm_poly_len,
    ))
}

#[test]
fn mojo_keyinfo_matches_rust_parsing() -> anyhow::Result<()> {
    // Skip if Mojo is not installed.
    if Command::new("mojo").arg("--version").output().is_err() {
        eprintln!("skipping: `mojo` not found in PATH");
        return Ok(());
    }

    let rel = GoldilocksMulRelation;
    let pkg = export_package_v3(
        RelationKind::GoldilocksMul,
        &RelationParamsV1::GoldilocksMul { version: 1 },
        &rel,
        [0x42u8; 32],
    )
    .expect("export_package_v3");

    let (cs_fixed, cs_advice, cs_instance, cs_blinding, cs_degree, perm_cols) =
        parse_cs_summary(&pkg.cs_bytes)?;
    let (vk_k, vk_fixed) = parse_vk_summary(&pkg.vk_bytes)?;
    let (pk_k, pk_fixed, fixed_values_polys, fixed_values_poly_len, perm_polys, perm_poly_len) =
        parse_pk_summary(&pkg.pk_bytes, perm_cols)?;

    // Run Mojo keyinfo on the exported package.
    let dir = std::env::temp_dir().join(format!("neo-midnight-mojo-bridge-{}", std::process::id()));
    let _ = fs::remove_dir_all(&dir);
    fs::create_dir_all(&dir).context("create temp dir")?;

    let pkg_path = dir.join("goldilocks_mul.nmbp");
    let out_path = dir.join("keyinfo.bin");
    fs::write(&pkg_path, pkg.to_bytes()).context("write pkg")?;

    let manifest_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    let mojo_prog = manifest_dir.join("mojo/keyinfo.mojo");

    let status = Command::new("mojo")
        .args([
            "run",
            mojo_prog.to_str().unwrap(),
            pkg_path.to_str().unwrap(),
            out_path.to_str().unwrap(),
        ])
        .status()
        .context("run mojo keyinfo")?;
    assert!(status.success(), "mojo keyinfo failed");

    let out = fs::read(&out_path).context("read keyinfo.bin")?;
    if out.len() != 76 {
        return Err(anyhow!("unexpected keyinfo.bin length: {}", out.len()));
    }
    if &out[0..4] != b"NMBI" {
        return Err(anyhow!("bad magic in keyinfo.bin"));
    }

    let mut pos = 4usize;
    let out_ver = read_u32_le(&out, &mut pos)?;
    let pkg_ver = read_u32_le(&out, &mut pos)?;
    let pkg_k = read_u32_le(&out, &mut pos)?;
    let pkg_n = read_u32_le(&out, &mut pos)?;

    let out_cs_fixed = read_u32_le(&out, &mut pos)?;
    let out_cs_advice = read_u32_le(&out, &mut pos)?;
    let out_cs_instance = read_u32_le(&out, &mut pos)?;
    let out_cs_blinding = read_u32_le(&out, &mut pos)?;
    let out_cs_degree = read_u32_le(&out, &mut pos)?;
    let out_perm_cols = read_u32_le(&out, &mut pos)?;

    let out_vk_k = read_u32_le(&out, &mut pos)?;
    let out_pk_k = read_u32_le(&out, &mut pos)?;
    let out_vk_fixed = read_u32_le(&out, &mut pos)?;
    let out_pk_fixed = read_u32_le(&out, &mut pos)?;

    let out_fixed_values_polys = read_u32_le(&out, &mut pos)?;
    let out_fixed_values_poly_len = read_u32_le(&out, &mut pos)?;
    let out_perm_polys = read_u32_le(&out, &mut pos)?;
    let out_perm_poly_len = read_u32_le(&out, &mut pos)?;

    assert_eq!(out_ver, 1);
    assert_eq!(pkg_ver, 3);
    assert_eq!(pkg_k, pkg.k);
    assert_eq!(pkg_n, pkg.n);

    assert_eq!(out_cs_fixed, cs_fixed);
    assert_eq!(out_cs_advice, cs_advice);
    assert_eq!(out_cs_instance, cs_instance);
    assert_eq!(out_cs_blinding, cs_blinding);
    assert_eq!(out_cs_degree, cs_degree);
    assert_eq!(out_perm_cols, perm_cols);

    assert_eq!(out_vk_k, vk_k as u32);
    assert_eq!(out_pk_k, pk_k as u32);
    assert_eq!(out_vk_fixed, vk_fixed);
    assert_eq!(out_pk_fixed, pk_fixed);

    assert_eq!(out_fixed_values_polys, fixed_values_polys);
    assert_eq!(out_fixed_values_poly_len, fixed_values_poly_len);
    assert_eq!(out_perm_polys, perm_polys);
    assert_eq!(out_perm_poly_len, perm_poly_len);
    assert_eq!(fixed_values_poly_len, pkg.n);
    assert_eq!(perm_poly_len, pkg.n);
    Ok(())
}
