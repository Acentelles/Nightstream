#![no_std]
#![no_main]

type GlDigest = [u64; 4];

const GL_ZERO: u64 = 0;
const ZERO_DIGEST: GlDigest = [0, 0, 0, 0];

#[inline]
fn gl_add(a: u64, b: u64) -> u64 {
    a.wrapping_add(b)
}

#[inline]
fn digest_eq(a: &GlDigest, b: &GlDigest) -> bool {
    a[0] == b[0] && a[1] == b[1] && a[2] == b[2] && a[3] == b[3]
}

#[inline]
fn poseidon2_squeeze_digest() -> GlDigest {
    [
        (nightstream_sdk::poseidon2::poseidon2_squeeze_word(0) as u64)
            | ((nightstream_sdk::poseidon2::poseidon2_squeeze_word(1) as u64) << 32),
        (nightstream_sdk::poseidon2::poseidon2_squeeze_word(2) as u64)
            | ((nightstream_sdk::poseidon2::poseidon2_squeeze_word(3) as u64) << 32),
        (nightstream_sdk::poseidon2::poseidon2_squeeze_word(4) as u64)
            | ((nightstream_sdk::poseidon2::poseidon2_squeeze_word(5) as u64) << 32),
        (nightstream_sdk::poseidon2::poseidon2_squeeze_word(6) as u64)
            | ((nightstream_sdk::poseidon2::poseidon2_squeeze_word(7) as u64) << 32),
    ]
}

#[inline]
fn poseidon2_finalize_to_digest() -> GlDigest {
    nightstream_sdk::poseidon2::poseidon2_finalize();
    poseidon2_squeeze_digest()
}

#[inline]
fn poseidon2_absorb_digest(d: &GlDigest) {
    nightstream_sdk::poseidon2::poseidon2_absorb_elem(d[0]);
    nightstream_sdk::poseidon2::poseidon2_absorb_elem(d[1]);
    nightstream_sdk::poseidon2::poseidon2_absorb_elem(d[2]);
    nightstream_sdk::poseidon2::poseidon2_absorb_elem(d[3]);
}

#[inline]
fn poseidon2_absorb_tag(tag: u64) {
    nightstream_sdk::poseidon2::poseidon2_absorb_elem(tag);
}

const MAX_INS: usize = 4;
const MAX_OUTS: usize = 2;
#[allow(dead_code)]
const MAX_DEPTH: usize = 63;

const TAG_MT_NODE: u64 = 1;
const TAG_NOTE: u64 = 2;
const TAG_PRF_NF: u64 = 3;
const TAG_PK: u64 = 4;
const TAG_ADDR: u64 = 5;
const TAG_NFKEY: u64 = 6;
const TAG_BL_BUCKET: u64 = 7;

const BL_DEPTH: u32 = 16;
const BL_BUCKET_SIZE: usize = 12;

const INPUT_ADDR: u32 = 0x104;
const OUTPUT_ADDR: u32 = 0x100;

struct RamReader {
    addr: u32,
}

impl RamReader {
    fn new(addr: u32) -> Self {
        Self { addr }
    }

    #[inline]
    fn read_u32(&mut self) -> u32 {
        let val = unsafe { core::ptr::read_volatile(self.addr as *const u32) };
        self.addr += 4;
        val
    }

    #[inline]
    fn read_u64(&mut self) -> u64 {
        let lo = self.read_u32() as u64;
        let hi = self.read_u32() as u64;
        lo | (hi << 32)
    }

    #[inline]
    fn read_digest(&mut self) -> GlDigest {
        let a0 = self.read_u64();
        let a1 = self.read_u64();
        let a2 = self.read_u64();
        let a3 = self.read_u64();
        [a0, a1, a2, a3]
    }
}

struct RamWriter {
    addr: u32,
}

impl RamWriter {
    fn new(addr: u32) -> Self {
        Self { addr }
    }

    #[inline]
    fn write_u32(&mut self, val: u32) {
        unsafe { core::ptr::write_volatile(self.addr as *mut u32, val) };
        self.addr += 4;
    }

    #[inline]
    fn write_u64(&mut self, val: u64) {
        self.write_u32(val as u32);
        self.write_u32((val >> 32) as u32);
    }

    #[inline]
    fn write_digest(&mut self, d: &GlDigest) {
        self.write_u64(d[0]);
        self.write_u64(d[1]);
        self.write_u64(d[2]);
        self.write_u64(d[3]);
    }
}

fn derive_pk_spend(spend_sk: &GlDigest) -> GlDigest {
    poseidon2_absorb_tag(TAG_PK);
    poseidon2_absorb_digest(spend_sk);
    poseidon2_finalize_to_digest()
}

fn derive_nf_key(domain: &GlDigest, spend_sk: &GlDigest) -> GlDigest {
    poseidon2_absorb_tag(TAG_NFKEY);
    poseidon2_absorb_digest(domain);
    poseidon2_absorb_digest(spend_sk);
    poseidon2_finalize_to_digest()
}

fn derive_address(domain: &GlDigest, pk_spend: &GlDigest, pk_ivk: &GlDigest) -> GlDigest {
    poseidon2_absorb_tag(TAG_ADDR);
    poseidon2_absorb_digest(domain);
    poseidon2_absorb_digest(pk_spend);
    poseidon2_absorb_digest(pk_ivk);
    poseidon2_finalize_to_digest()
}

fn note_commitment(
    domain: &GlDigest,
    value: u64,
    rho: &GlDigest,
    recipient: &GlDigest,
    sender_id: &GlDigest,
) -> GlDigest {
    poseidon2_absorb_tag(TAG_NOTE);
    poseidon2_absorb_digest(domain);
    nightstream_sdk::poseidon2::poseidon2_absorb_elem(value);
    nightstream_sdk::poseidon2::poseidon2_absorb_elem(GL_ZERO);
    poseidon2_absorb_digest(rho);
    poseidon2_absorb_digest(recipient);
    poseidon2_absorb_digest(sender_id);
    poseidon2_finalize_to_digest()
}

fn derive_nullifier(domain: &GlDigest, nf_key: &GlDigest, rho: &GlDigest) -> GlDigest {
    poseidon2_absorb_tag(TAG_PRF_NF);
    poseidon2_absorb_digest(domain);
    poseidon2_absorb_digest(nf_key);
    poseidon2_absorb_digest(rho);
    poseidon2_finalize_to_digest()
}

fn mt_node(level: u64, left: &GlDigest, right: &GlDigest) -> GlDigest {
    poseidon2_absorb_tag(TAG_MT_NODE);
    nightstream_sdk::poseidon2::poseidon2_absorb_elem(level);
    poseidon2_absorb_digest(left);
    poseidon2_absorb_digest(right);
    poseidon2_finalize_to_digest()
}

fn merkle_root(leaf: &GlDigest, pos: u32, reader: &mut RamReader, depth: u32) -> GlDigest {
    let mut cur = *leaf;
    let mut p = pos;

    let mut lvl = 0u32;
    while lvl < depth {
        let sib = reader.read_digest();
        cur = if (p & 1) == 0 {
            mt_node(lvl as u64, &cur, &sib)
        } else {
            mt_node(lvl as u64, &sib, &cur)
        };
        p >>= 1;
        lvl += 1;
    }

    cur
}

fn assert_digest_limbs_all_diff(a: &GlDigest, b: &GlDigest) {
    assert!(a[0] != b[0]);
    assert!(a[1] != b[1]);
    assert!(a[2] != b[2]);
    assert!(a[3] != b[3]);
}

fn bl_bucket_leaf(entries: &[GlDigest; BL_BUCKET_SIZE]) -> GlDigest {
    poseidon2_absorb_tag(TAG_BL_BUCKET);
    let mut i = 0usize;
    while i < BL_BUCKET_SIZE {
        poseidon2_absorb_digest(&entries[i]);
        i += 1;
    }
    poseidon2_finalize_to_digest()
}

fn bl_bucket_pos(id: &GlDigest) -> u32 {
    (id[0] as u32) & ((1u32 << BL_DEPTH) - 1)
}

fn assert_not_blacklisted(id: &GlDigest, blacklist_root: &GlDigest, reader: &mut RamReader) {
    let mut entries = [ZERO_DIGEST; BL_BUCKET_SIZE];
    for e in entries.iter_mut() {
        *e = reader.read_digest();
    }
    let _bucket_inv = reader.read_u64();
    for entry in &entries {
        assert_digest_limbs_all_diff(id, entry);
    }

    let leaf = bl_bucket_leaf(&entries);
    let pos = bl_bucket_pos(id);
    let root = merkle_root(&leaf, pos, reader, BL_DEPTH);
    assert!(digest_eq(&root, blacklist_root));
}

const NOTE_PLAIN_LEN: usize = 272;
const NOTE_PLAIN_WORDS: usize = NOTE_PLAIN_LEN / 8;

const TAG_FVK_COMMIT: u64 = 100;
const TAG_VIEW_KDF: u64 = 101;
const TAG_VIEW_STREAM: u64 = 102;
const TAG_CT_HASH: u64 = 103;
const TAG_VIEW_MAC: u64 = 104;

/// FVK commitment: H(TAG_FVK_COMMIT, fvk[0..4])
fn view_fvk_commitment(fvk: &GlDigest) -> GlDigest {
    poseidon2_absorb_tag(TAG_FVK_COMMIT);
    poseidon2_absorb_digest(fvk);
    poseidon2_finalize_to_digest()
}

/// View KDF: H(TAG_VIEW_KDF, fvk[0..4], cm[0..4])
fn view_kdf(fvk: &GlDigest, cm: &GlDigest) -> GlDigest {
    poseidon2_absorb_tag(TAG_VIEW_KDF);
    poseidon2_absorb_digest(fvk);
    poseidon2_absorb_digest(cm);
    poseidon2_finalize_to_digest()
}

/// Stream block: H(TAG_VIEW_STREAM, k[0..4], ctr)
fn view_stream_block(k: &GlDigest, ctr: u32) -> GlDigest {
    poseidon2_absorb_tag(TAG_VIEW_STREAM);
    poseidon2_absorb_digest(k);
    nightstream_sdk::poseidon2::poseidon2_absorb_elem(ctr as u64);
    poseidon2_finalize_to_digest()
}

/// Ciphertext hash: H(TAG_CT_HASH, packed_ct_bytes..., byte_len)
fn view_ct_hash_from_plain(k: &GlDigest, pt: &[u64; NOTE_PLAIN_WORDS]) -> GlDigest {
    poseidon2_absorb_tag(TAG_CT_HASH);
    let mut ctr: u32 = 0;
    let mut off: usize = 0;
    while off < NOTE_PLAIN_WORDS {
        let ks = view_stream_block(k, ctr);
        ctr += 1;
        let take = if off + 4 <= NOTE_PLAIN_WORDS {
            4
        } else {
            NOTE_PLAIN_WORDS - off
        };
        let mut j = 0usize;
        while j < take {
            let ct_word = pt[off + j] ^ ks[j];
            nightstream_sdk::poseidon2::poseidon2_absorb_elem(ct_word);
            j += 1;
        }
        off += take;
    }

    nightstream_sdk::poseidon2::poseidon2_absorb_elem(NOTE_PLAIN_LEN as u64);
    poseidon2_finalize_to_digest()
}

/// View MAC: H(TAG_VIEW_MAC, k[0..4], cm[0..4], ct_h[0..4])
fn view_mac(k: &GlDigest, cm: &GlDigest, ct_h: &GlDigest) -> GlDigest {
    poseidon2_absorb_tag(TAG_VIEW_MAC);
    poseidon2_absorb_digest(k);
    poseidon2_absorb_digest(cm);
    poseidon2_absorb_digest(ct_h);
    poseidon2_finalize_to_digest()
}

fn encode_note_plain(
    domain: &GlDigest,
    value: u64,
    rho: &GlDigest,
    recipient: &GlDigest,
    sender_id: &GlDigest,
    cm_ins: &[GlDigest; MAX_INS],
    n_in: u32,
) -> [u64; NOTE_PLAIN_WORDS] {
    let mut pt = [0u64; NOTE_PLAIN_WORDS];
    pt[..4].copy_from_slice(domain);
    pt[4] = value;
    pt[6..10].copy_from_slice(rho);
    pt[10..14].copy_from_slice(recipient);
    pt[14..18].copy_from_slice(sender_id);
    let mut i = 0usize;
    while i < MAX_INS {
        let off = 18 + i * 4;
        if (i as u32) < n_in {
            pt[off..off + 4].copy_from_slice(&cm_ins[i]);
        }
        i += 1;
    }
    pt
}

#[nightstream_sdk::provable]
fn note_spend() -> ! {
    let mut r = RamReader::new(INPUT_ADDR);
    let mut w = RamWriter::new(OUTPUT_ADDR);

    let domain = r.read_digest();
    let spend_sk = r.read_digest();
    let pk_ivk_owner = r.read_digest();
    let depth = r.read_u32();
    let anchor = r.read_digest();
    let n_in = r.read_u32();

    assert!(n_in <= MAX_INS as u32);

    let pk_spend_owner = derive_pk_spend(&spend_sk);
    let nf_key = derive_nf_key(&domain, &spend_sk);
    let recipient_owner = derive_address(&domain, &pk_spend_owner, &pk_ivk_owner);
    let sender_id = recipient_owner;

    let mut sum_in: u64 = GL_ZERO;
    let mut input_rhos: [GlDigest; MAX_INS] = [ZERO_DIGEST; MAX_INS];
    let mut input_cms: [GlDigest; MAX_INS] = [ZERO_DIGEST; MAX_INS];

    for i in 0..n_in as usize {
        let value_in = r.read_u64();
        let rho_in = r.read_digest();
        let sender_id_in = r.read_digest();
        let pos = r.read_u32();

        sum_in = gl_add(sum_in, value_in);
        assert!(value_in != GL_ZERO);

        let cm = note_commitment(&domain, value_in, &rho_in, &recipient_owner, &sender_id_in);
        input_cms[i] = cm;
        input_rhos[i] = rho_in;

        let root = merkle_root(&cm, pos, &mut r, depth);
        assert!(digest_eq(&root, &anchor));
    }

    let mut nullifiers: [GlDigest; MAX_INS] = [ZERO_DIGEST; MAX_INS];
    for i in 0..n_in as usize {
        let nullifier_pub = r.read_digest();
        let nf = derive_nullifier(&domain, &nf_key, &input_rhos[i]);
        assert!(digest_eq(&nf, &nullifier_pub));
        nullifiers[i] = nullifier_pub;
    }

    for i in 0..n_in as usize {
        for j in (i + 1)..n_in as usize {
            assert!(!digest_eq(&nullifiers[i], &nullifiers[j]));
        }
    }

    let withdraw_amount = r.read_u64();
    let withdraw_to = r.read_digest();
    let n_out = r.read_u32();

    assert!(n_out <= MAX_OUTS as u32);

    if withdraw_amount == 0 {
        assert!(n_out >= 1);
        assert!(digest_eq(&withdraw_to, &ZERO_DIGEST));
    } else {
        assert!(n_out <= 1);
        assert!(!digest_eq(&withdraw_to, &ZERO_DIGEST));
    }

    let mut out_sum: u64 = GL_ZERO;
    let mut output_values: [u64; MAX_OUTS] = [0; MAX_OUTS];
    let mut output_rhos: [GlDigest; MAX_OUTS] = [ZERO_DIGEST; MAX_OUTS];
    let mut output_cms: [GlDigest; MAX_OUTS] = [ZERO_DIGEST; MAX_OUTS];
    let mut output_rcps: [GlDigest; MAX_OUTS] = [ZERO_DIGEST; MAX_OUTS];

    for j in 0..n_out as usize {
        let value_out = r.read_u64();
        output_values[j] = value_out;
        let rho_out = r.read_digest();
        let pk_spend_out = r.read_digest();
        let pk_ivk_out = r.read_digest();

        out_sum = gl_add(out_sum, value_out);
        assert!(value_out != GL_ZERO);

        let rcp = derive_address(&domain, &pk_spend_out, &pk_ivk_out);
        let cm = note_commitment(&domain, value_out, &rho_out, &rcp, &sender_id);

        output_rhos[j] = rho_out;
        output_cms[j] = cm;
        output_rcps[j] = rcp;
    }

    let mut cm_outs_pub: [GlDigest; MAX_OUTS] = [ZERO_DIGEST; MAX_OUTS];
    for j in 0..n_out as usize {
        let cm_pub = r.read_digest();
        assert!(digest_eq(&output_cms[j], &cm_pub));
        cm_outs_pub[j] = cm_pub;
    }

    let rhs = gl_add(withdraw_amount, out_sum);
    assert!(sum_in == rhs);

    if withdraw_amount > 0 && n_out == 1 {
        assert!(digest_eq(&output_rcps[0], &sender_id));
    }
    if withdraw_amount == 0 && n_out == 2 {
        assert!(digest_eq(&output_rcps[1], &sender_id));
    }

    for j in 0..n_out as usize {
        for i in 0..n_in as usize {
            assert_digest_limbs_all_diff(&output_rhos[j], &input_rhos[i]);
        }
    }
    if n_out == 2 {
        assert_digest_limbs_all_diff(&output_rhos[0], &output_rhos[1]);
    }

    let _inv_enforce = r.read_u64();

    let blacklist_root = r.read_digest();
    assert_not_blacklisted(&sender_id, &blacklist_root, &mut r);

    if withdraw_amount == 0 {
        assert_not_blacklisted(&output_rcps[0], &blacklist_root, &mut r);
    }

    let mut output_pts: [[u64; NOTE_PLAIN_WORDS]; MAX_OUTS] = [[0u64; NOTE_PLAIN_WORDS]; MAX_OUTS];
    let mut j = 0usize;
    while j < n_out as usize {
        output_pts[j] = encode_note_plain(
            &domain,
            output_values[j],
            &output_rhos[j],
            &output_rcps[j],
            &sender_id,
            &input_cms,
            n_in,
        );
        j += 1;
    }
    let n_viewers = r.read_u32();

    w.write_digest(&anchor);
    w.write_u32(n_in);
    for i in 0..n_in as usize {
        w.write_digest(&nullifiers[i]);
    }
    w.write_u64(withdraw_amount);
    w.write_digest(&withdraw_to);
    w.write_u32(n_out);
    for j in 0..n_out as usize {
        w.write_digest(&cm_outs_pub[j]);
    }
    w.write_digest(&blacklist_root);

    w.write_u32(n_viewers);

    for _v in 0..n_viewers as usize {
        let fvk_commitment_pub = r.read_digest();
        let fvk = r.read_digest();

        let computed_fvk_cm = view_fvk_commitment(&fvk);
        assert!(digest_eq(&computed_fvk_cm, &fvk_commitment_pub));

        for j in 0..n_out as usize {
            let ct_hash_pub = r.read_digest();
            let mac_pub = r.read_digest();

            let k = view_kdf(&fvk, &output_cms[j]);
            let ct_h = view_ct_hash_from_plain(&k, &output_pts[j]);
            assert!(digest_eq(&ct_h, &ct_hash_pub));

            let mac = view_mac(&k, &output_cms[j], &ct_h);
            assert!(digest_eq(&mac, &mac_pub));

            w.write_digest(&output_cms[j]);
            w.write_digest(&fvk_commitment_pub);
            w.write_digest(&ct_hash_pub);
            w.write_digest(&mac_pub);
        }
    }
    nightstream_sdk::halt();
}
