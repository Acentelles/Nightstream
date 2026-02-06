from collections import List
from pathlib import Path
from sys import argv
from sys.ffi import OwnedDLHandle

from nmb.domain import EvaluationDomain
from nmb.blake2b import Blake2bState
from nmb.fq import Fq
from nmb.gpu.dispatch import cuda_available
from nmb.params_kzg import ParamsKZGParsed, commit_coeff, commit_lagrange, parse_params_kzg
from nmb.reader import Reader
from nmb.transcript import CircuitTranscript


comptime _NB_COMMITTED_INSTANCES: Int = 1


struct AnyColumn(Copyable, ImplicitlyCopyable, Movable):
    # 0 = Instance, 1 = Advice, 2 = Fixed (matches artifacts write_any_column_parts).
    var kind: UInt8
    var index: Int

    fn __init__(out self, kind: UInt8, index: Int):
        self.kind = kind
        self.index = index

    fn __copyinit__(out self, existing: Self):
        self.kind = existing.kind
        self.index = existing.index


struct Query(Copyable, ImplicitlyCopyable, Movable):
    var col: Int
    var rot: Int

    fn __init__(out self, col: Int, rot: Int):
        self.col = col
        self.rot = rot

    fn __copyinit__(out self, existing: Self):
        self.col = existing.col
        self.rot = existing.rot


struct ExprNode(Copyable, ImplicitlyCopyable, Movable):
    # Tags match `neo-midnight-bridge-artifacts/src/nmbp.rs::write_expr`.
    var tag: UInt8
    # Inclusive start index of this expression's postorder range in `nodes`.
    # For any expression root `r`, the expression is exactly `nodes[nodes[r].expr_start..=r]`.
    var expr_start: Int
    var col: Int
    var rot: Int
    var idx: Int
    var left: Int
    var right: Int
    var scalar: Fq

    fn __init__(
        out self,
        tag: UInt8,
        expr_start: Int,
        col: Int,
        rot: Int,
        idx: Int,
        left: Int,
        right: Int,
        scalar: Fq,
    ):
        self.tag = tag
        self.expr_start = expr_start
        self.col = col
        self.rot = rot
        self.idx = idx
        self.left = left
        self.right = right
        self.scalar = scalar

    fn __copyinit__(out self, existing: Self):
        self.tag = existing.tag
        self.expr_start = existing.expr_start
        self.col = existing.col
        self.rot = existing.rot
        self.idx = existing.idx
        self.left = existing.left
        self.right = existing.right
        self.scalar = existing.scalar


struct LookupInfo(Copyable, Movable):
    var input_roots: List[Int]
    var table_roots: List[Int]

    fn __init__(out self, var input_roots: List[Int], var table_roots: List[Int]):
        self.input_roots = input_roots^
        self.table_roots = table_roots^

    fn __copyinit__(out self, existing: Self):
        self.input_roots = existing.input_roots.copy()
        self.table_roots = existing.table_roots.copy()


struct TrashInfo(Copyable, Movable):
    var selector_root: Int
    var constraint_roots: List[Int]

    fn __init__(out self, selector_root: Int, var constraint_roots: List[Int]):
        self.selector_root = selector_root
        self.constraint_roots = constraint_roots^

    fn __copyinit__(out self, existing: Self):
        self.selector_root = existing.selector_root
        self.constraint_roots = existing.constraint_roots.copy()


struct CsInfo(Movable):
    var num_fixed: Int
    var num_advice: Int
    var num_instance: Int
    var num_challenges: Int
    var blinding_factors: Int
    var degree: Int

    var advice_phases: List[UInt8]
    var challenge_phases: List[UInt8]

    var gate_roots: List[Int]
    var fixed_queries: List[Query]
    var advice_queries: List[Query]
    var instance_queries: List[Query]

    var perm_columns: List[AnyColumn]
    var lookups: List[LookupInfo]
    var trashcans: List[TrashInfo]

    fn __init__(
        out self,
        num_fixed: Int,
        num_advice: Int,
        num_instance: Int,
        num_challenges: Int,
        blinding_factors: Int,
        degree: Int,
        var advice_phases: List[UInt8],
        var challenge_phases: List[UInt8],
        var gate_roots: List[Int],
        var fixed_queries: List[Query],
        var advice_queries: List[Query],
        var instance_queries: List[Query],
        var perm_columns: List[AnyColumn],
        var lookups: List[LookupInfo],
        var trashcans: List[TrashInfo],
    ):
        self.num_fixed = num_fixed
        self.num_advice = num_advice
        self.num_instance = num_instance
        self.num_challenges = num_challenges
        self.blinding_factors = blinding_factors
        self.degree = degree
        self.advice_phases = advice_phases^
        self.challenge_phases = challenge_phases^
        self.gate_roots = gate_roots^
        self.fixed_queries = fixed_queries^
        self.advice_queries = advice_queries^
        self.instance_queries = instance_queries^
        self.perm_columns = perm_columns^
        self.lookups = lookups^
        self.trashcans = trashcans^


struct ParsedCs(Movable):
    var cs: CsInfo
    var nodes: List[ExprNode]

    fn __init__(out self, var cs: CsInfo, var nodes: List[ExprNode]):
        self.cs = cs^
        self.nodes = nodes^


struct NmbpV3(Movable):
    var relation_kind: Int
    var params_json: List[Byte]
    var k: Int
    var n: Int
    var params_bytes: List[Byte]
    var vk_transcript_repr: List[Byte]
    var pk_bytes: List[Byte]
    var cs_bytes: List[Byte]

    fn __init__(
        out self,
        relation_kind: Int,
        var params_json: List[Byte],
        k: Int,
        n: Int,
        var params_bytes: List[Byte],
        var vk_transcript_repr: List[Byte],
        var pk_bytes: List[Byte],
        var cs_bytes: List[Byte],
    ):
        self.relation_kind = relation_kind
        self.params_json = params_json^
        self.k = k
        self.n = n
        self.params_bytes = params_bytes^
        self.vk_transcript_repr = vk_transcript_repr^
        self.pk_bytes = pk_bytes^
        self.cs_bytes = cs_bytes^


struct NmbwsV2(Movable):
    var k: Int
    var n: Int
    var usable_rows: Int
    var instance_provided_lens: List[Int]
    var instance_cols: List[List[Fq]]
    var advice_cols: List[List[Fq]]

    fn __init__(
        out self,
        k: Int,
        n: Int,
        usable_rows: Int,
        var instance_provided_lens: List[Int],
        var instance_cols: List[List[Fq]],
        var advice_cols: List[List[Fq]],
    ):
        self.k = k
        self.n = n
        self.usable_rows = usable_rows
        self.instance_provided_lens = instance_provided_lens^
        self.instance_cols = instance_cols^
        self.advice_cols = advice_cols^


struct ParsedPk(Movable):
    var fixed_values: List[List[Fq]]
    var perm_permutations: List[List[Fq]]

    fn __init__(out self, var fixed_values: List[List[Fq]], var perm_permutations: List[List[Fq]]):
        self.fixed_values = fixed_values^
        self.perm_permutations = perm_permutations^


struct ProverQuery(Copyable, ImplicitlyCopyable, Movable):
    var point: Fq
    var poly_id: Int

    fn __init__(out self, point: Fq, poly_id: Int):
        self.point = point
        self.poly_id = poly_id

    fn __copyinit__(out self, existing: Self):
        self.point = existing.point
        self.poly_id = existing.poly_id


struct IntermediateSets(Movable):
    var poly_ids: List[Int]
    var poly_set_index: List[Int]
    var point_sets: List[List[Fq]]

    fn __init__(
        out self,
        var poly_ids: List[Int],
        var poly_set_index: List[Int],
        var point_sets: List[List[Fq]],
    ):
        self.poly_ids = poly_ids^
        self.poly_set_index = poly_set_index^
        self.point_sets = point_sets^


fn os_random_bytes(n: Int) raises -> List[Byte]:
    if n < 0:
        raise Error("os_random_bytes: negative length")
    var out = List[Byte]()
    for _ in range(n):
        out.append(Byte(0))

    if n == 0:
        return out^

    # Prefer `getentropy` (portable-ish, max 256 bytes). Fallback to
    # `arc4random_buf` on platforms that expose it.
    var lib = OwnedDLHandle()
    var ptr = out.unsafe_ptr()
    if lib.check_symbol("getentropy"):
        if n > 256:
            raise Error("os_random_bytes: getentropy supports <= 256 bytes")
        var rc: Int32 = lib.call["getentropy", Int32](ptr, n)
        if rc != 0:
            raise Error("os_random_bytes: getentropy failed")
    elif lib.check_symbol("arc4random_buf"):
        lib.call["arc4random_buf", NoneType](ptr, n)
    else:
        raise Error("os_random_bytes: no OS entropy source (getentropy/arc4random_buf)")
    return out^


struct RngBlake2b(Movable):
    var key: List[Byte]
    var ctr: UInt64

    fn __init__(out self, var key: List[Byte], ctr: UInt64):
        self.key = key^
        self.ctr = ctr

    @staticmethod
    fn from_os_entropy() raises -> RngBlake2b:
        return RngBlake2b(os_random_bytes(32), 0)

    fn next_fq(mut self) raises -> Fq:
        # Hash(key, ctr_le) -> 64 bytes, then map to field.
        var st = Blake2bState.init_keyed(self.key.copy())
        var msg = List[Byte]()
        var c = self.ctr
        for _ in range(8):
            msg.append(Byte(UInt8(c & 0xFF)))
            c >>= 8
        st.update(msg)
        self.ctr = self.ctr &+ 1
        return Fq.from_uniform_bytes(st.digest())


fn read_i32_le(mut r: Reader) raises -> Int:
    var u = Int(r.read_u32_le())
    if u >= 0x8000_0000:
        u -= 0x1_0000_0000
    return u


fn get_rotation_idx(idx: Int, rot: Int, rot_scale: Int, isize: Int) -> Int:
    var x = idx + (rot * rot_scale)
    x = x % isize
    if x < 0:
        x += isize
    return x


fn read_nmbp_v3(pkg_bytes: List[Byte]) raises -> NmbpV3:
    var r = Reader(pkg_bytes)
    r.expect_magic(78, 77, 66, 80)  # NMBP
    var ver = r.read_u32_le()
    if ver != 3:
        raise Error("NMBP: unsupported version")

    var relation_kind = Int(r.read_u32_le())
    var params_json_len = Int(r.read_u32_le())
    var params_json = r.read_bytes(params_json_len)

    var k = Int(r.read_u32_le())
    var n = Int(r.read_u32_le())

    var params_len = Int(r.read_u32_le())
    var params_bytes = r.read_bytes(params_len)

    var vk_len = Int(r.read_u32_le())
    r.skip(vk_len)  # vk_bytes (unused for proving)
    var vk_transcript_repr = r.read_bytes(32)

    var pk_len = Int(r.read_u32_le())
    var pk_bytes = r.read_bytes(pk_len)

    var cs_len = Int(r.read_u32_le())
    var cs_bytes = r.read_bytes(cs_len)

    if r.remaining() != 0:
        raise Error("trailing bytes in NMBP")

    return NmbpV3(
        relation_kind,
        params_json^,
        k,
        n,
        params_bytes^,
        vk_transcript_repr^,
        pk_bytes^,
        cs_bytes^,
    )


fn read_nmbws_v2(ws_bytes: List[Byte]) raises -> NmbwsV2:
    var r = Reader(ws_bytes)
    r.expect_magic(78, 77, 66, 87)  # NMBW
    var ver = r.read_u32_le()
    if ver != 2:
        raise Error("NMBW: unsupported version")

    var k = Int(r.read_u32_le())
    var n = Int(r.read_u32_le())
    var usable_rows = Int(r.read_u32_le())

    var inst_cols = Int(r.read_u32_le())
    var instance_provided_lens = List[Int]()
    var instance_cols = List[List[Fq]]()
    for _ in range(inst_cols):
        instance_provided_lens.append(Int(r.read_u32_le()))
        var col_len = Int(r.read_u32_le())
        var col = List[Fq]()
        for _ in range(col_len):
            col.append(Fq.from_repr_le(r.read_bytes(32)))
        instance_cols.append(col^)

    var adv_cols = Int(r.read_u32_le())
    var advice_cols = List[List[Fq]]()
    for _ in range(adv_cols):
        var col_len = Int(r.read_u32_le())
        var col = List[Fq]()
        for _ in range(col_len):
            col.append(Fq.from_repr_le(r.read_bytes(32)))
        advice_cols.append(col^)

    if r.remaining() != 0:
        raise Error("trailing bytes in NMBW")

    return NmbwsV2(
        k,
        n,
        usable_rows,
        instance_provided_lens^,
        instance_cols^,
        advice_cols^,
    )


fn batch_invert(values: List[Fq]) raises -> List[Fq]:
    var out = values.copy()
    var n = len(out)
    if n == 0:
        return out^

    var prefix = List[Fq]()
    var acc = Fq.one()
    for i in range(n):
        prefix.append(acc)
        if not out[i].is_zero():
            acc = acc.mul(out[i])

    var acc_inv = acc.invert()
    for i in range(n):
        var j = (n - 1) - i
        var v = out[j]
        if v.is_zero():
            continue
        out[j] = acc_inv.mul(prefix[j])
        acc_inv = acc_inv.mul(v)

    return out^


fn batch_invert_no_zeros(values: List[Fq]) raises -> List[Fq]:
    var out = values.copy()
    var n = len(out)
    if n == 0:
        return out^

    var prefix = List[Fq]()
    var acc = Fq.one()
    for i in range(n):
        if out[i].is_zero():
            raise Error("batch_invert_no_zeros: zero element")
        prefix.append(acc)
        acc = acc.mul(out[i])

    var acc_inv = acc.invert()
    for i in range(n):
        var j = (n - 1) - i
        var v = out[j]
        out[j] = acc_inv.mul(prefix[j])
        acc_inv = acc_inv.mul(v)

    return out^


fn eval_polynomial(poly: List[Fq], point: Fq) -> Fq:
    var acc = Fq.zero()
    for i in range(len(poly)):
        var j = (len(poly) - 1) - i
        acc = acc.mul(point).add(poly[j])
    return acc


fn kate_division(poly: List[Fq], point: Fq) -> List[Fq]:
    # Returns quotient of poly / (X - point), discarding remainder.
    var b = point.neg()
    if len(poly) < 2:
        return List[Fq]()
    var q = List[Fq]()
    for _ in range(len(poly) - 1):
        q.append(Fq.zero())
    var tmp = Fq.zero()
    for i in range(len(q)):
        var qi = (len(q) - 1) - i
        var ri = (len(poly) - 1) - i
        var lead = poly[ri].sub(tmp)
        q[qi] = lead
        tmp = lead.mul(b)
    return q^


fn poly_add(a: List[Fq], b: List[Fq]) raises -> List[Fq]:
    if len(a) != len(b):
        raise Error("poly_add: length mismatch")
    var out = List[Fq]()
    for i in range(len(a)):
        out.append(a[i].add(b[i]))
    return out^


fn poly_scale(poly: List[Fq], s: Fq) -> List[Fq]:
    var out = List[Fq]()
    for v in poly:
        out.append(v.mul(s))
    return out^


fn poly_sub_const(poly_in: List[Fq], c: Fq) -> List[Fq]:
    var poly = poly_in.copy()
    if len(poly) > 0:
        poly[0] = poly[0].sub(c)
    return poly^


fn fq_eq(a: Fq, b: Fq) -> Bool:
    return a.l0 == b.l0 and a.l1 == b.l1 and a.l2 == b.l2 and a.l3 == b.l3


fn fq_lt(a: Fq, b: Fq) -> Bool:
    # Deterministic order by Montgomery limbs (sufficient for grouping equals).
    if a.l3 != b.l3:
        return a.l3 < b.l3
    if a.l2 != b.l2:
        return a.l2 < b.l2
    if a.l1 != b.l1:
        return a.l1 < b.l1
    return a.l0 < b.l0


fn sort_fq_in_place(mut v: List[Fq]):
    if len(v) < 2:
        return

    var lo_stack = List[Int]()
    var hi_stack = List[Int]()
    lo_stack.append(0)
    hi_stack.append(len(v) - 1)

    while len(lo_stack) > 0:
        var lo = lo_stack.pop()
        var hi = hi_stack.pop()
        if lo >= hi:
            continue

        var i = lo
        var j = hi
        var pivot = v[(lo + hi) // 2]

        while i <= j:
            while fq_lt(v[i], pivot):
                i += 1
            while fq_lt(pivot, v[j]):
                j -= 1
            if i <= j:
                var tmp = v[i]
                v[i] = v[j]
                v[j] = tmp
                i += 1
                j -= 1

        if lo < j:
            lo_stack.append(lo)
            hi_stack.append(j)
        if i < hi:
            lo_stack.append(i)
            hi_stack.append(hi)


fn sort_ints_in_place(mut v: List[Int]):
    if len(v) < 2:
        return

    var lo_stack = List[Int]()
    var hi_stack = List[Int]()
    lo_stack.append(0)
    hi_stack.append(len(v) - 1)

    while len(lo_stack) > 0:
        var lo = lo_stack.pop()
        var hi = hi_stack.pop()
        if lo >= hi:
            continue

        var i = lo
        var j = hi
        var pivot = v[(lo + hi) // 2]

        while i <= j:
            while v[i] < pivot:
                i += 1
            while pivot < v[j]:
                j -= 1
            if i <= j:
                var tmp = v[i]
                v[i] = v[j]
                v[j] = tmp
                i += 1
                j -= 1

        if lo < j:
            lo_stack.append(lo)
            hi_stack.append(j)
        if i < hi:
            lo_stack.append(i)
            hi_stack.append(hi)


fn _parse_expr_inner(mut r: Reader, mut nodes: List[ExprNode], expr_start: Int) raises -> Int:
    var tag = r.read_u8()
    if tag == 0:
        nodes.append(ExprNode(tag, expr_start, 0, 0, 0, -1, -1, Fq.from_repr_le(r.read_bytes(32))))
        return len(nodes) - 1
    if tag == 1:
        raise Error("Selector expressions are not supported (expected selectors converted to fixed during keygen)")
    if tag == 2:
        var col = Int(r.read_u32_le())
        var rot = read_i32_le(r)
        nodes.append(ExprNode(tag, expr_start, col, rot, 0, -1, -1, Fq.zero()))
        return len(nodes) - 1
    if tag == 3:
        var col = Int(r.read_u32_le())
        var rot = read_i32_le(r)
        _ = r.read_u8()  # phase
        nodes.append(ExprNode(tag, expr_start, col, rot, 0, -1, -1, Fq.zero()))
        return len(nodes) - 1
    if tag == 4:
        var col = Int(r.read_u32_le())
        var rot = read_i32_le(r)
        nodes.append(ExprNode(tag, expr_start, col, rot, 0, -1, -1, Fq.zero()))
        return len(nodes) - 1
    if tag == 5:
        var idx = Int(r.read_u32_le())
        _ = r.read_u8()  # phase
        nodes.append(ExprNode(tag, expr_start, 0, 0, idx, -1, -1, Fq.zero()))
        return len(nodes) - 1
    if tag == 6:
        var a = _parse_expr_inner(r, nodes, expr_start)
        nodes.append(ExprNode(tag, expr_start, 0, 0, 0, a, -1, Fq.zero()))
        return len(nodes) - 1
    if tag == 7 or tag == 8:
        var a = _parse_expr_inner(r, nodes, expr_start)
        var b = _parse_expr_inner(r, nodes, expr_start)
        nodes.append(ExprNode(tag, expr_start, 0, 0, 0, a, b, Fq.zero()))
        return len(nodes) - 1
    if tag == 9:
        var a = _parse_expr_inner(r, nodes, expr_start)
        nodes.append(ExprNode(tag, expr_start, 0, 0, 0, a, -1, Fq.from_repr_le(r.read_bytes(32))))
        return len(nodes) - 1
    raise Error("parse_expr: invalid tag")


fn parse_expr(mut r: Reader, mut nodes: List[ExprNode]) raises -> Int:
    # `write_expr` encodes trees; our parser appends nodes in postorder. Track the
    # start offset so evaluation can run iteratively without recursion.
    var expr_start = len(nodes)
    return _parse_expr_inner(r, nodes, expr_start)


fn parse_cs(cs_bytes: List[Byte]) raises -> ParsedCs:
    var r = Reader(cs_bytes)
    var num_fixed = Int(r.read_u32_le())
    var num_advice = Int(r.read_u32_le())
    var num_instance = Int(r.read_u32_le())
    _ = r.read_u32_le()  # selectors
    var num_challenges = Int(r.read_u32_le())

    var blinding_factors = Int(r.read_u32_le())
    var degree = Int(r.read_u32_le())

    var advice_phases_len = Int(r.read_u32_le())
    var advice_phases = List[UInt8]()
    for _ in range(advice_phases_len):
        advice_phases.append(r.read_u8())

    var challenge_phases_len = Int(r.read_u32_le())
    var challenge_phases = List[UInt8]()
    for _ in range(challenge_phases_len):
        challenge_phases.append(r.read_u8())

    var unblinded_count = Int(r.read_u32_le())
    for _ in range(unblinded_count):
        _ = r.read_u32_le()

    var nodes = List[ExprNode]()
    var gate_roots = List[Int]()

    var gates_len = Int(r.read_u32_le())
    for _ in range(gates_len):
        var gate_name_len = Int(r.read_u32_le())
        r.skip(gate_name_len)
        var polys_len = Int(r.read_u32_le())
        for _ in range(polys_len):
            var cname_len = Int(r.read_u32_le())
            r.skip(cname_len)
            gate_roots.append(parse_expr(r, nodes))

    var fixed_queries = List[Query]()
    var fixed_q_len = Int(r.read_u32_le())
    for _ in range(fixed_q_len):
        fixed_queries.append(Query(Int(r.read_u32_le()), read_i32_le(r)))

    var advice_queries = List[Query]()
    var advice_q_len = Int(r.read_u32_le())
    for _ in range(advice_q_len):
        var col = Int(r.read_u32_le())
        _ = r.read_u8()  # phase
        advice_queries.append(Query(col, read_i32_le(r)))

    var instance_queries = List[Query]()
    var inst_q_len = Int(r.read_u32_le())
    for _ in range(inst_q_len):
        instance_queries.append(Query(Int(r.read_u32_le()), read_i32_le(r)))

    var perm_columns = List[AnyColumn]()
    var perm_cols = Int(r.read_u32_le())
    for _ in range(perm_cols):
        var kind = r.read_u8()
        var idx = Int(r.read_u32_le())
        if kind == 1:
            _ = r.read_u8()  # phase
        perm_columns.append(AnyColumn(kind, idx))

    var lookups = List[LookupInfo]()
    var lookups_len = Int(r.read_u32_le())
    for _ in range(lookups_len):
        var name_len = Int(r.read_u32_le())
        r.skip(name_len)
        var m = Int(r.read_u32_le())
        var input_roots = List[Int]()
        var table_roots = List[Int]()
        for _ in range(m):
            input_roots.append(parse_expr(r, nodes))
            table_roots.append(parse_expr(r, nodes))
        lookups.append(LookupInfo(input_roots^, table_roots^))

    var trashcans = List[TrashInfo]()
    var trash_len = Int(r.read_u32_le())
    for _ in range(trash_len):
        var tname_len = Int(r.read_u32_le())
        r.skip(tname_len)
        var selector_root = parse_expr(r, nodes)
        var c_len = Int(r.read_u32_le())
        var constraint_roots = List[Int]()
        for _ in range(c_len):
            constraint_roots.append(parse_expr(r, nodes))
        trashcans.append(TrashInfo(selector_root, constraint_roots^))

    # Constants list (skip).
    var constants_len = Int(r.read_u32_le())
    for _ in range(constants_len):
        _ = r.read_u32_le()

    # General column annotations (skip).
    var ann_len = Int(r.read_u32_le())
    for _ in range(ann_len):
        var col_ty = r.read_u8()
        _ = r.read_u32_le()
        if col_ty == 1:
            _ = r.read_u8()
        var label_len = Int(r.read_u32_le())
        r.skip(label_len)

    if r.remaining() != 0:
        raise Error("trailing bytes in CS")

    var cs = CsInfo(
        num_fixed,
        num_advice,
        num_instance,
        num_challenges,
        blinding_factors,
        degree,
        advice_phases^,
        challenge_phases^,
        gate_roots^,
        fixed_queries^,
        advice_queries^,
        instance_queries^,
        perm_columns^,
        lookups^,
        trashcans^,
    )
    return ParsedCs(cs^, nodes^)


fn parse_pk_polys(pk_bytes: List[Byte], num_fixed: Int, num_perm_cols: Int, n: Int) raises -> ParsedPk:
    var r = Reader(pk_bytes)
    _ = r.read_u8()  # version
    _ = r.read_u8()  # k
    var fixed_count = Int(r.read_u32_le())
    if fixed_count != num_fixed:
        raise Error("pk: fixed_count mismatch")

    r.skip((num_fixed + num_perm_cols) * 96)

    var fixed_values_polys = Int(r.read_u32_be())
    if fixed_values_polys != num_fixed:
        raise Error("pk: fixed_values_polys mismatch")

    var fixed_values = List[List[Fq]]()
    for _ in range(fixed_values_polys):
        var poly_len = Int(r.read_u32_be())
        if poly_len != n:
            raise Error("pk: fixed poly len mismatch")
        var poly = List[Fq]()
        for _ in range(poly_len):
            poly.append(Fq.from_raw_bytes_le(r.read_bytes(32)))
        fixed_values.append(poly^)

    var perm_polys = Int(r.read_u32_be())
    if perm_polys != num_perm_cols:
        raise Error("pk: perm polys mismatch")

    var perm_permutations = List[List[Fq]]()
    for _ in range(perm_polys):
        var poly_len = Int(r.read_u32_be())
        if poly_len != n:
            raise Error("pk: perm poly len mismatch")
        var poly = List[Fq]()
        for _ in range(poly_len):
            poly.append(Fq.from_raw_bytes_le(r.read_bytes(32)))
        perm_permutations.append(poly^)

    if r.remaining() != 0:
        raise Error("trailing bytes in pk_bytes")

    return ParsedPk(fixed_values^, perm_permutations^)


fn eval_expr(
    node_id: Int,
    nodes: List[ExprNode],
    idx: Int,
    rot_scale: Int,
    isize: Int,
    fixed: List[List[Fq]],
    advice: List[List[Fq]],
    instance: List[List[Fq]],
    challenges: List[Fq],
) raises -> Fq:
    var root = nodes[node_id]
    var start = root.expr_start
    if start < 0 or start > node_id:
        raise Error("eval_expr: bad expr_start")

    var stack = List[Fq]()
    for i in range(start, node_id + 1):
        var node = nodes[i]
        var tag = node.tag
        if tag == 0:
            stack.append(node.scalar)
        elif tag == 2:
            stack.append(fixed[node.col][get_rotation_idx(idx, node.rot, rot_scale, isize)])
        elif tag == 3:
            stack.append(advice[node.col][get_rotation_idx(idx, node.rot, rot_scale, isize)])
        elif tag == 4:
            stack.append(instance[node.col][get_rotation_idx(idx, node.rot, rot_scale, isize)])
        elif tag == 5:
            stack.append(challenges[node.idx])
        elif tag == 6:
            if len(stack) < 1:
                raise Error("eval_expr: stack underflow (neg)")
            var a = stack.pop()
            stack.append(a.neg())
        elif tag == 7:
            if len(stack) < 2:
                raise Error("eval_expr: stack underflow (sum)")
            var b = stack.pop()
            var a = stack.pop()
            stack.append(a.add(b))
        elif tag == 8:
            if len(stack) < 2:
                raise Error("eval_expr: stack underflow (product)")
            var b = stack.pop()
            var a = stack.pop()
            stack.append(a.mul(b))
        elif tag == 9:
            if len(stack) < 1:
                raise Error("eval_expr: stack underflow (scale)")
            var a = stack.pop()
            stack.append(a.mul(node.scalar))
        else:
            raise Error("eval_expr: invalid tag")

    if len(stack) != 1:
        raise Error("eval_expr: bad final stack size")
    return stack.pop()


fn compress_expressions(
    roots: List[Int],
    nodes: List[ExprNode],
    theta: Fq,
    fixed: List[List[Fq]],
    advice: List[List[Fq]],
    instance: List[List[Fq]],
    challenges: List[Fq],
    n: Int,
) raises -> List[Fq]:
    var acc = List[Fq]()
    for _ in range(n):
        acc.append(Fq.zero())
    for root in roots:
        for i in range(n):
            acc[i] = acc[i].mul(theta).add(eval_expr(root, nodes, i, 1, n, fixed, advice, instance, challenges))
    return acc^


fn build_intermediate_sets(queries: List[ProverQuery]) raises -> IntermediateSets:
    # Unique points by insertion order.
    var points = List[Fq]()

    # Unique polynomials by insertion order, with their point indices.
    var poly_ids = List[Int]()
    var poly_point_indices = List[List[Int]]()

    for q in queries:
        # point index
        var point_idx = -1
        for i in range(len(points)):
            if fq_eq(points[i], q.point):
                point_idx = i
                break
        if point_idx < 0:
            points.append(q.point)
            point_idx = len(points) - 1

        # poly id
        var pos = -1
        for i in range(len(poly_ids)):
            if poly_ids[i] == q.poly_id:
                pos = i
                break
        if pos < 0:
            poly_ids.append(q.poly_id)
            var l = List[Int]()
            l.append(point_idx)
            poly_point_indices.append(l^)
        else:
            for existing in poly_point_indices[pos]:
                if existing == point_idx:
                    raise Error("duplicated query")
            poly_point_indices[pos].append(point_idx)

    # Unique point-index sets in insertion order.
    var set_keys = List[List[Int]]()
    var poly_set_index = List[Int]()

    for pts_raw in poly_point_indices:
        var pts = pts_raw.copy()
        sort_ints_in_place(pts)

        var found = False
        var set_idx = 0
        for j in range(len(set_keys)):
            if len(set_keys[j]) != len(pts):
                continue
            var same = True
            for k in range(len(pts)):
                if set_keys[j][k] != pts[k]:
                    same = False
                    break
            if same:
                found = True
                set_idx = j
                break
        if not found:
            set_keys.append(pts^)
            set_idx = len(set_keys) - 1
        poly_set_index.append(set_idx)

    var point_sets = List[List[Fq]]()
    for set_key in set_keys:
        var ps = List[Fq]()
        for pi in set_key:
            ps.append(points[pi])
        point_sets.append(ps^)

    return IntermediateSets(poly_ids^, poly_set_index^, point_sets^)


fn multi_open(
    params: ParamsKZGParsed,
    use_cuda: Bool,
    polys: List[List[Fq]],
    queries: List[ProverQuery],
    var transcript: CircuitTranscript,
) raises -> CircuitTranscript:
    var x1 = transcript.squeeze_challenge_fq()
    var x2 = transcript.squeeze_challenge_fq()

    var sets = build_intermediate_sets(queries)

    var n = params.n

    # Build q_polys per point set.
    var q_polys = List[List[Fq]]()
    for set_idx in range(len(sets.point_sets)):
        var acc = List[Fq]()
        for _ in range(n):
            acc.append(Fq.zero())

        var power = Fq.one()
        for i in range(len(sets.poly_ids)):
            if sets.poly_set_index[i] != set_idx:
                continue
            var poly_id = sets.poly_ids[i]
            for j in range(n):
                acc[j] = acc[j].add(polys[poly_id][j].mul(power))
            power = power.mul(x1)
        q_polys.append(acc^)

    # Compute f_poly.
    var f_poly = List[Fq]()
    for _ in range(n):
        f_poly.append(Fq.zero())

    var power2 = Fq.one()
    for set_idx in range(len(sets.point_sets)):
        var tmp = q_polys[set_idx].copy()
        for p in sets.point_sets[set_idx]:
            tmp = kate_division(tmp, p)
        while len(tmp) < n:
            tmp.append(Fq.zero())
        for j in range(n):
            f_poly[j] = f_poly[j].add(tmp[j].mul(power2))
        power2 = power2.mul(x2)

    transcript.write_g1_bytes(commit_coeff(params, f_poly, use_cuda))

    var x3 = transcript.squeeze_challenge_fq()
    for q_poly in q_polys:
        transcript.write_fq(eval_polynomial(q_poly, x3))

    var x4 = transcript.squeeze_challenge_fq()

    var final_poly = List[Fq]()
    for _ in range(n):
        final_poly.append(Fq.zero())

    var power4 = Fq.one()
    for q_poly in q_polys:
        for j in range(n):
            final_poly[j] = final_poly[j].add(q_poly[j].mul(power4))
        power4 = power4.mul(x4)
    for j in range(n):
        final_poly[j] = final_poly[j].add(f_poly[j].mul(power4))

    var v = eval_polynomial(final_poly, x3)
    var pi_poly = kate_division(poly_sub_const(final_poly, v), x3)
    while len(pi_poly) < n:
        pi_poly.append(Fq.zero())
    transcript.write_g1_bytes(commit_coeff(params, pi_poly, use_cuda))

    return transcript^


fn prove_from_snapshot_parsed(
    pkg: NmbpV3,
    mut ws: NmbwsV2,
    params: ParamsKZGParsed,
    use_cuda: Bool,
) raises -> List[Byte]:
    if pkg.k != ws.k or pkg.n != ws.n:
        raise Error("k/n mismatch between package and snapshot")

    if params.k != pkg.k or params.n != pkg.n:
        raise Error("k/n mismatch between params and package")

    var parsed = parse_cs(pkg.cs_bytes)

    if parsed.cs.num_instance != len(ws.instance_cols) or parsed.cs.num_advice != len(ws.advice_cols):
        raise Error("snapshot column count mismatch")

    var domain = EvaluationDomain(parsed.cs.degree, pkg.k, use_cuda)

    var pk = parse_pk_polys(pkg.pk_bytes, parsed.cs.num_fixed, len(parsed.cs.perm_columns), pkg.n)

    # Fixed polys: coeff + coset.
    var fixed_polys = List[List[Fq]]()
    var fixed_cosets = List[List[Fq]]()
    for poly_l in pk.fixed_values:
        fixed_polys.append(domain.lagrange_to_coeff(poly_l))
    for poly_c in fixed_polys:
        fixed_cosets.append(domain.coeff_to_extended(poly_c))

    # Permutation pk polys: coeff + coset.
    var perm_pk_polys = List[List[Fq]]()
    var perm_pk_cosets = List[List[Fq]]()
    for poly_l in pk.perm_permutations:
        perm_pk_polys.append(domain.lagrange_to_coeff(poly_l))
    for poly_c in perm_pk_polys:
        perm_pk_cosets.append(domain.coeff_to_extended(poly_c))

    # Transcript init + VK hash.
    var transcript = CircuitTranscript.init()
    transcript.common_fq(Fq.from_repr_le(pkg.vk_transcript_repr))

    # Instances (hash public instances, commit committed instances).
    for i in range(len(ws.instance_cols)):
        if i < _NB_COMMITTED_INSTANCES:
            transcript.common_g1_bytes(commit_lagrange(params, ws.instance_cols[i], use_cuda))
        else:
            var provided_len = ws.instance_provided_lens[i]
            transcript.common_fq(Fq.from_u64(UInt64(provided_len)))
            for j in range(provided_len):
                transcript.common_fq(ws.instance_cols[i][j])

    # Advice commitments (phase-aware). Challenges are sampled per phase.
    var rng = RngBlake2b.from_os_entropy()
    var unusable_rows_start = pkg.n - (parsed.cs.blinding_factors + 1)

    var challenges = List[Fq]()
    for _ in range(parsed.cs.num_challenges):
        challenges.append(Fq.zero())

    var max_phase: UInt8 = 0
    for p in parsed.cs.advice_phases:
        if p > max_phase:
            max_phase = p

    for phase in range(Int(max_phase) + 1):
        # Collect advice columns in this phase (sorted).
        var cols = List[Int]()
        for i in range(len(parsed.cs.advice_phases)):
            if Int(parsed.cs.advice_phases[i]) == phase:
                cols.append(i)
        sort_ints_in_place(cols)

        for col_idx in cols:
            for row in range(unusable_rows_start, pkg.n):
                ws.advice_cols[col_idx][row] = rng.next_fq()
            transcript.write_g1_bytes(commit_lagrange(params, ws.advice_cols[col_idx], use_cuda))

        for i in range(len(parsed.cs.challenge_phases)):
            if Int(parsed.cs.challenge_phases[i]) == phase:
                challenges[i] = transcript.squeeze_challenge_fq()

    # theta
    var theta = transcript.squeeze_challenge_fq()

    # Lookup permuted commitments + products (supports any # of lookups).
    var lookup_product_polys = List[List[Fq]]()
    var lookup_input_polys = List[List[Fq]]()
    var lookup_table_polys = List[List[Fq]]()

    var lookup_compressed_inputs = List[List[Fq]]()
    var lookup_compressed_tables = List[List[Fq]]()
    var lookup_permuted_inputs = List[List[Fq]]()
    var lookup_permuted_tables = List[List[Fq]]()

    for info in parsed.cs.lookups:
        var cin = compress_expressions(
            info.input_roots,
            parsed.nodes,
            theta,
            pk.fixed_values,
            ws.advice_cols,
            ws.instance_cols,
            challenges,
            pkg.n,
        )
        var ctbl = compress_expressions(
            info.table_roots,
            parsed.nodes,
            theta,
            pk.fixed_values,
            ws.advice_cols,
            ws.instance_cols,
            challenges,
            pkg.n,
        )

        # Permute pair (Mojo tuple workaround: inline implementation).
        var usable_rows = pkg.n - (parsed.cs.blinding_factors + 1)
        var permuted_input = cin.copy()
        while len(permuted_input) > usable_rows:
            _ = permuted_input.pop()
        sort_fq_in_place(permuted_input)

        # Build table counts.
        var table_keys = List[Fq]()
        var table_counts = List[UInt32]()
        for i in range(usable_rows):
            var v = ctbl[i]
            var found = False
            for j in range(len(table_keys)):
                if fq_eq(table_keys[j], v):
                    table_counts[j] = table_counts[j] + 1
                    found = True
                    break
            if not found:
                table_keys.append(v)
                table_counts.append(UInt32(1))

        var permuted_table = List[Fq]()
        for _ in range(usable_rows):
            permuted_table.append(Fq.zero())
        var repeated_rows = List[Int]()

        for row in range(usable_rows):
            var input_value = permuted_input[row]
            if row == 0 or not fq_eq(input_value, permuted_input[row - 1]):
                permuted_table[row] = input_value
                var dec_ok = False
                for j in range(len(table_keys)):
                    if fq_eq(table_keys[j], input_value):
                        if table_counts[j] == 0:
                            raise Error("lookup: table underflow")
                        table_counts[j] = table_counts[j] - 1
                        dec_ok = True
                        break
                if not dec_ok:
                    raise Error("lookup: input not in table")
            else:
                repeated_rows.append(row)

        for j in range(len(table_keys)):
            var key = table_keys[j]
            var cnt = Int(table_counts[j])
            for _ in range(cnt):
                permuted_table[repeated_rows.pop()] = key

        if len(repeated_rows) != 0:
            raise Error("lookup: repeated rows not empty")

        for _ in range(parsed.cs.blinding_factors + 1):
            permuted_input.append(rng.next_fq())
            permuted_table.append(rng.next_fq())

        transcript.write_g1_bytes(commit_lagrange(params, permuted_input, use_cuda))
        transcript.write_g1_bytes(commit_lagrange(params, permuted_table, use_cuda))

        lookup_compressed_inputs.append(cin^)
        lookup_compressed_tables.append(ctbl^)

        lookup_input_polys.append(domain.lagrange_to_coeff(permuted_input))
        lookup_table_polys.append(domain.lagrange_to_coeff(permuted_table))

        lookup_permuted_inputs.append(permuted_input^)
        lookup_permuted_tables.append(permuted_table^)

    # beta, gamma
    var beta = transcript.squeeze_challenge_fq()
    var gamma = transcript.squeeze_challenge_fq()

    # Permutation commit (z polys).
    var perm_product_polys = List[List[Fq]]()
    if len(parsed.cs.perm_columns) != 0:
        var chunk_len = parsed.cs.degree - 2
        if chunk_len <= 0:
            raise Error("perm: bad degree")

        # omega^i table (base domain).
        var omega_powers = List[Fq]()
        var cur = Fq.one()
        for _ in range(pkg.n):
            omega_powers.append(cur)
            cur = cur.mul(domain.omega)

        var deltaomega_base = Fq.one()
        var last_z = Fq.one()

        var col_start = 0
        while col_start < len(parsed.cs.perm_columns):
            var col_end = col_start + chunk_len
            if col_end > len(parsed.cs.perm_columns):
                col_end = len(parsed.cs.perm_columns)

            var modified = List[Fq]()
            for _ in range(pkg.n):
                modified.append(Fq.one())

            # Denominator.
            for j in range(col_start, col_end):
                var column = parsed.cs.perm_columns[j]
                for i in range(pkg.n):
                    if column.kind == 0:
                        modified[i] = modified[i].mul(
                            beta.mul(pk.perm_permutations[j][i])
                            .add(gamma)
                            .add(ws.instance_cols[column.index][i])
                        )
                    elif column.kind == 1:
                        modified[i] = modified[i].mul(
                            beta.mul(pk.perm_permutations[j][i])
                            .add(gamma)
                            .add(ws.advice_cols[column.index][i])
                        )
                    else:
                        modified[i] = modified[i].mul(
                            beta.mul(pk.perm_permutations[j][i])
                            .add(gamma)
                            .add(pk.fixed_values[column.index][i])
                        )

            modified = batch_invert_no_zeros(modified)

            # Numerator.
            for j in range(col_start, col_end):
                var column = parsed.cs.perm_columns[j]
                for i in range(pkg.n):
                    var deltaomega = deltaomega_base.mul(omega_powers[i])
                    if column.kind == 0:
                        modified[i] = modified[i].mul(
                            deltaomega.mul(beta)
                            .add(gamma)
                            .add(ws.instance_cols[column.index][i])
                        )
                    elif column.kind == 1:
                        modified[i] = modified[i].mul(
                            deltaomega.mul(beta)
                            .add(gamma)
                            .add(ws.advice_cols[column.index][i])
                        )
                    else:
                        modified[i] = modified[i].mul(
                            deltaomega.mul(beta)
                            .add(gamma)
                            .add(pk.fixed_values[column.index][i])
                        )
                deltaomega_base = deltaomega_base.mul(Fq.delta())

            var z = List[Fq]()
            z.append(last_z)
            for row in range(1, pkg.n):
                z.append(z[row - 1].mul(modified[row - 1]))

            for i in range(pkg.n - parsed.cs.blinding_factors, pkg.n):
                z[i] = rng.next_fq()
            last_z = z[pkg.n - (parsed.cs.blinding_factors + 1)]

            transcript.write_g1_bytes(commit_lagrange(params, z, use_cuda))
            perm_product_polys.append(domain.lagrange_to_coeff(z))

            col_start = col_end

    # Lookup product polynomials.
    for i in range(len(parsed.cs.lookups)):
        var lookup_product = List[Fq]()
        for j in range(pkg.n):
            lookup_product.append(beta.add(lookup_permuted_inputs[i][j]).mul(gamma.add(lookup_permuted_tables[i][j])))

        lookup_product = batch_invert_no_zeros(lookup_product)
        for j in range(pkg.n):
            lookup_product[j] = lookup_product[j].mul(lookup_compressed_inputs[i][j].add(beta))
            lookup_product[j] = lookup_product[j].mul(lookup_compressed_tables[i][j].add(gamma))

        var take_len = pkg.n - parsed.cs.blinding_factors
        var z = List[Fq]()
        z.append(Fq.one())
        for j in range(1, take_len):
            z.append(z[j - 1].mul(lookup_product[j - 1]))
        for _ in range(parsed.cs.blinding_factors):
            z.append(rng.next_fq())
        if len(z) != pkg.n:
            raise Error("lookup: bad product length")

        transcript.write_g1_bytes(commit_lagrange(params, z, use_cuda))
        lookup_product_polys.append(domain.lagrange_to_coeff(z))

    # trash challenge (always)
    var trash_challenge = transcript.squeeze_challenge_fq()

    # Trashcans.
    var trash_polys = List[List[Fq]]()
    for info in parsed.cs.trashcans:
        var compressed = compress_expressions(
            info.constraint_roots,
            parsed.nodes,
            trash_challenge,
            pk.fixed_values,
            ws.advice_cols,
            ws.instance_cols,
            challenges,
            pkg.n,
        )
        transcript.write_g1_bytes(commit_lagrange(params, compressed, use_cuda))
        trash_polys.append(domain.lagrange_to_coeff(compressed))

    # Vanishing random poly commitment.
    var random_poly = List[Fq]()
    for _ in range(pkg.n):
        random_poly.append(rng.next_fq())
    transcript.write_g1_bytes(commit_coeff(params, random_poly, use_cuda))

    # y
    var y = transcript.squeeze_challenge_fq()

    # Convert advice/instance polys to coeff + coset.
    var advice_polys = List[List[Fq]]()
    var advice_cosets = List[List[Fq]]()
    for poly_l in ws.advice_cols:
        advice_polys.append(domain.lagrange_to_coeff(poly_l))
    for poly_c in advice_polys:
        advice_cosets.append(domain.coeff_to_extended(poly_c))

    var instance_polys = List[List[Fq]]()
    var instance_cosets = List[List[Fq]]()
    for poly_l in ws.instance_cols:
        instance_polys.append(domain.lagrange_to_coeff(poly_l))
    for poly_c in instance_polys:
        instance_cosets.append(domain.coeff_to_extended(poly_c))

    var trash_cosets = List[List[Fq]]()
    for poly_c in trash_polys:
        trash_cosets.append(domain.coeff_to_extended(poly_c))

    # l0, l_last, l_active
    # (inline compute_lagrange_polys)
    var l0_l = List[Fq]()
    for _ in range(pkg.n):
        l0_l.append(Fq.zero())
    l0_l[0] = Fq.one()
    var l0 = domain.coeff_to_extended(domain.lagrange_to_coeff(l0_l))

    var l_blind_l = List[Fq]()
    for _ in range(pkg.n):
        l_blind_l.append(Fq.zero())
    for i in range(parsed.cs.blinding_factors):
        l_blind_l[pkg.n - 1 - i] = Fq.one()
    var l_blind = domain.coeff_to_extended(domain.lagrange_to_coeff(l_blind_l))

    var l_last_l = List[Fq]()
    for _ in range(pkg.n):
        l_last_l.append(Fq.zero())
    l_last_l[pkg.n - parsed.cs.blinding_factors - 1] = Fq.one()
    var l_last = domain.coeff_to_extended(domain.lagrange_to_coeff(l_last_l))

    var l_active = List[Fq]()
    for i in range(len(l_last)):
        l_active.append(Fq.one().sub(l_last[i].add(l_blind[i])))

    # Evaluate h on extended domain.
    var size = domain.extended_len()
    var rot_scale = 1 << (domain.extended_k - domain.k)
    var isize = size

    var h_ext = List[Fq]()
    for _ in range(size):
        h_ext.append(Fq.zero())

    # Custom gates compressed with y.
    for idx in range(size):
        var acc = Fq.zero()
        for root in parsed.cs.gate_roots:
            acc = acc.mul(y).add(eval_expr(root, parsed.nodes, idx, rot_scale, isize, fixed_cosets, advice_cosets, instance_cosets, challenges))
        h_ext[idx] = acc

    # Permutation constraints (if any).
    if len(parsed.cs.perm_columns) != 0:
        var chunk_len = parsed.cs.degree - 2
        var last_rot = -(parsed.cs.blinding_factors + 1)
        var beta_term = Fq.one()
        var omega_ext = domain.extended_omega
        var delta_start = beta.mul(domain.g_coset)

        var perm_prod_cosets = List[List[Fq]]()
        for poly in perm_product_polys:
            perm_prod_cosets.append(domain.coeff_to_extended(poly))

        for idx in range(size):
            var v = h_ext[idx]
            var r_next = get_rotation_idx(idx, 1, rot_scale, isize)
            var r_last = get_rotation_idx(idx, last_rot, rot_scale, isize)

            v = v.mul(y).add(Fq.one().sub(perm_prod_cosets[0][idx]).mul(l0[idx]))
            var last_set = perm_prod_cosets[len(perm_prod_cosets) - 1][idx]
            v = v.mul(y).add(last_set.mul(last_set).sub(last_set).mul(l_last[idx]))
            for set_idx in range(1, len(perm_prod_cosets)):
                v = v.mul(y).add(perm_prod_cosets[set_idx][idx].sub(perm_prod_cosets[set_idx - 1][r_last]).mul(l0[idx]))

            var current_delta = delta_start.mul(beta_term)
            var col_start = 0
            var set_idx = 0
            while col_start < len(parsed.cs.perm_columns):
                var col_end = col_start + chunk_len
                if col_end > len(parsed.cs.perm_columns):
                    col_end = len(parsed.cs.perm_columns)

                var left = perm_prod_cosets[set_idx][r_next]
                for j in range(col_start, col_end):
                    var column = parsed.cs.perm_columns[j]
                    var perm = perm_pk_cosets[j][idx]
                    if column.kind == 0:
                        left = left.mul(instance_cosets[column.index][idx].add(beta.mul(perm)).add(gamma))
                    elif column.kind == 1:
                        left = left.mul(advice_cosets[column.index][idx].add(beta.mul(perm)).add(gamma))
                    else:
                        left = left.mul(fixed_cosets[column.index][idx].add(beta.mul(perm)).add(gamma))

                var right = perm_prod_cosets[set_idx][idx]
                for j in range(col_start, col_end):
                    var column = parsed.cs.perm_columns[j]
                    if column.kind == 0:
                        right = right.mul(instance_cosets[column.index][idx].add(current_delta).add(gamma))
                    elif column.kind == 1:
                        right = right.mul(advice_cosets[column.index][idx].add(current_delta).add(gamma))
                    else:
                        right = right.mul(fixed_cosets[column.index][idx].add(current_delta).add(gamma))
                    current_delta = current_delta.mul(Fq.delta())

                v = v.mul(y).add(left.sub(right).mul(l_active[idx]))

                col_start = col_end
                set_idx += 1

            h_ext[idx] = v
            beta_term = beta_term.mul(omega_ext)

    # Lookup constraints.
    for i in range(len(parsed.cs.lookups)):
        var info = parsed.cs.lookups[i].copy()
        var product_coset = domain.coeff_to_extended(lookup_product_polys[i])
        var input_coset = domain.coeff_to_extended(lookup_input_polys[i])
        var table_coset = domain.coeff_to_extended(lookup_table_polys[i])

        for idx in range(size):
            var v = h_ext[idx]
            var r_next = get_rotation_idx(idx, 1, rot_scale, isize)
            var r_prev = get_rotation_idx(idx, -1, rot_scale, isize)

            var lc_inp = Fq.zero()
            var lc_tbl = Fq.zero()
            for root in info.input_roots:
                lc_inp = lc_inp.mul(theta).add(eval_expr(root, parsed.nodes, idx, rot_scale, isize, fixed_cosets, advice_cosets, instance_cosets, challenges))
            for root in info.table_roots:
                lc_tbl = lc_tbl.mul(theta).add(eval_expr(root, parsed.nodes, idx, rot_scale, isize, fixed_cosets, advice_cosets, instance_cosets, challenges))
            var table_value = lc_inp.add(beta).mul(lc_tbl.add(gamma))

            var a_minus_s = input_coset[idx].sub(table_coset[idx])

            v = v.mul(y).add(Fq.one().sub(product_coset[idx]).mul(l0[idx]))
            v = v.mul(y).add(product_coset[idx].mul(product_coset[idx]).sub(product_coset[idx]).mul(l_last[idx]))
            v = v.mul(y).add(
                product_coset[r_next]
                    .mul(input_coset[idx].add(beta))
                    .mul(table_coset[idx].add(gamma))
                    .sub(product_coset[idx].mul(table_value))
                    .mul(l_active[idx])
            )
            v = v.mul(y).add(a_minus_s.mul(l0[idx]))
            v = v.mul(y).add(a_minus_s.mul(input_coset[idx].sub(input_coset[r_prev])).mul(l_active[idx]))
            h_ext[idx] = v

    # Trashcans constraints.
    for i in range(len(parsed.cs.trashcans)):
        var info = parsed.cs.trashcans[i].copy()
        var trash_poly = trash_cosets[i].copy()
        for idx in range(size):
            var v = h_ext[idx]
            var compressed = Fq.zero()
            for root in info.constraint_roots:
                compressed = compressed.mul(trash_challenge).add(
                    eval_expr(
                        root,
                        parsed.nodes,
                        idx,
                        rot_scale,
                        isize,
                        fixed_cosets,
                        advice_cosets,
                        instance_cosets,
                        challenges,
                    )
                )
            var q = eval_expr(
                info.selector_root,
                parsed.nodes,
                idx,
                rot_scale,
                isize,
                fixed_cosets,
                advice_cosets,
                instance_cosets,
                challenges,
            )
            v = v.mul(y).add(compressed.sub(Fq.one().sub(q).mul(trash_poly[idx])))
            h_ext[idx] = v

    # Vanishing construct: divide by t(X), extended_to_coeff, split into pieces, commit each.
    var h_div = domain.divide_by_vanishing_poly(h_ext)
    var h_coeff_ext = domain.extended_to_coeff(h_div)

    var qdeg = domain.quotient_poly_degree
    var limb_len = pkg.n - 1
    var total_len = limb_len * qdeg
    while len(h_coeff_ext) > total_len:
        _ = h_coeff_ext.pop()

    var h_pieces = List[List[Fq]]()
    var off = 0
    for _ in range(qdeg):
        var piece = List[Fq]()
        for j in range(limb_len):
            piece.append(h_coeff_ext[off + j])
        off += limb_len
        h_pieces.append(piece^)

    for i in range(1, len(h_pieces)):
        var t = rng.next_fq()
        h_pieces[i - 1].append(t)
        h_pieces[i][0] = h_pieces[i][0].sub(t)
    h_pieces[len(h_pieces) - 1].append(Fq.zero())

    var h_piece_polys = h_pieces^
    for i in range(len(h_piece_polys)):
        if len(h_piece_polys[i]) != pkg.n:
            raise Error("h piece length mismatch")
        transcript.write_g1_bytes(commit_coeff(params, h_piece_polys[i], use_cuda))

    # x
    var x = transcript.squeeze_challenge_fq()

    # Write evals: committed instances, advice, fixed.
    for q in parsed.cs.instance_queries:
        if q.col < _NB_COMMITTED_INSTANCES:
            transcript.write_fq(eval_polynomial(instance_polys[q.col], domain.rotate_omega(x, q.rot)))
    for q in parsed.cs.advice_queries:
        transcript.write_fq(eval_polynomial(advice_polys[q.col], domain.rotate_omega(x, q.rot)))
    for q in parsed.cs.fixed_queries:
        transcript.write_fq(eval_polynomial(fixed_polys[q.col], domain.rotate_omega(x, q.rot)))

    # Vanishing evaluate: x-dependent combination + random eval.
    var exp = List[UInt64]()
    exp.append(UInt64(pkg.n - 1))
    var split = x.pow(exp)
    var h_poly = h_piece_polys[len(h_piece_polys) - 1].copy()
    for i in range(len(h_piece_polys) - 1):
        var j = (len(h_piece_polys) - 2) - i
        h_poly = poly_add(poly_scale(h_poly, split), h_piece_polys[j])

    transcript.write_fq(eval_polynomial(random_poly, x))

    # pk.permutation.evaluate: permutation polys at x.
    for poly in perm_pk_polys:
        transcript.write_fq(eval_polynomial(poly, x))

    # permutation evaluated: product evals.
    var x_next = domain.rotate_omega(x, 1)
    var x_last = domain.rotate_omega(x, -(parsed.cs.blinding_factors + 1))
    for i in range(len(perm_product_polys)):
        transcript.write_fq(eval_polynomial(perm_product_polys[i], x))
        transcript.write_fq(eval_polynomial(perm_product_polys[i], x_next))
        if i < len(perm_product_polys) - 1:
            transcript.write_fq(eval_polynomial(perm_product_polys[i], x_last))

    # lookup evaluated
    var x_inv = domain.rotate_omega(x, -1)
    for i in range(len(parsed.cs.lookups)):
        transcript.write_fq(eval_polynomial(lookup_product_polys[i], x))
        transcript.write_fq(eval_polynomial(lookup_product_polys[i], x_next))
        transcript.write_fq(eval_polynomial(lookup_input_polys[i], x))
        transcript.write_fq(eval_polynomial(lookup_input_polys[i], x_inv))
        transcript.write_fq(eval_polynomial(lookup_table_polys[i], x))

    # trash evaluated
    for poly in trash_polys:
        transcript.write_fq(eval_polynomial(poly, x))

    # Build polynomial registry for multi_open.
    var polys = List[List[Fq]]()

    var id_instance_base = len(polys)
    for p in instance_polys:
        polys.append(p.copy())
    var id_advice_base = len(polys)
    for p in advice_polys:
        polys.append(p.copy())
    var id_fixed_base = len(polys)
    for p in fixed_polys:
        polys.append(p.copy())
    var id_perm_pk_base = len(polys)
    for p in perm_pk_polys:
        polys.append(p.copy())
    var id_perm_prod_base = len(polys)
    for p in perm_product_polys:
        polys.append(p.copy())
    var id_lookup_base = len(polys)
    for i in range(len(parsed.cs.lookups)):
        polys.append(lookup_product_polys[i].copy())
        polys.append(lookup_input_polys[i].copy())
        polys.append(lookup_table_polys[i].copy())
    var id_trash_base = len(polys)
    for p in trash_polys:
        polys.append(p.copy())
    var id_h_poly = len(polys)
    polys.append(h_poly^)
    var id_random_poly = len(polys)
    polys.append(random_poly^)

    # Build query list (order matters).
    var queries = List[ProverQuery]()

    for q in parsed.cs.instance_queries:
        if q.col < _NB_COMMITTED_INSTANCES:
            queries.append(ProverQuery(domain.rotate_omega(x, q.rot), id_instance_base + q.col))
    for q in parsed.cs.advice_queries:
        queries.append(ProverQuery(domain.rotate_omega(x, q.rot), id_advice_base + q.col))
    # permutation product queries
    for set_idx in range(len(perm_product_polys)):
        queries.append(ProverQuery(x, id_perm_prod_base + set_idx))
        queries.append(ProverQuery(x_next, id_perm_prod_base + set_idx))
    for i in range(len(perm_product_polys) - 1):
        var j = (len(perm_product_polys) - 2) - i
        queries.append(ProverQuery(x_last, id_perm_prod_base + j))
    # lookup queries
    for i in range(len(parsed.cs.lookups)):
        var base = id_lookup_base + (i * 3)
        queries.append(ProverQuery(x, base + 0))
        queries.append(ProverQuery(x, base + 1))
        queries.append(ProverQuery(x, base + 2))
        queries.append(ProverQuery(x_inv, base + 1))
        queries.append(ProverQuery(x_next, base + 0))
    # trash queries
    for i in range(len(trash_polys)):
        queries.append(ProverQuery(x, id_trash_base + i))
    # fixed queries
    for q in parsed.cs.fixed_queries:
        queries.append(ProverQuery(domain.rotate_omega(x, q.rot), id_fixed_base + q.col))
    # permutation pk polys at x
    for i in range(len(perm_pk_polys)):
        queries.append(ProverQuery(x, id_perm_pk_base + i))
    # vanishing open
    queries.append(ProverQuery(x, id_h_poly))
    queries.append(ProverQuery(x, id_random_poly))

    transcript = multi_open(params, use_cuda, polys, queries, transcript^)

    return transcript^.finalize()


fn prove_from_snapshot_bytes(pkg_bytes: List[Byte], ws_bytes: List[Byte]) raises -> List[Byte]:
    var pkg = read_nmbp_v3(pkg_bytes)
    var ws = read_nmbws_v2(ws_bytes)

    if pkg.k != ws.k or pkg.n != ws.n:
        raise Error("k/n mismatch between package and snapshot")

    var use_cuda = cuda_available()
    var params = parse_params_kzg(pkg.params_bytes, use_cuda)
    if params.k != pkg.k or params.n != pkg.n:
        raise Error("k/n mismatch between params and package")

    return prove_from_snapshot_parsed(pkg, ws, params, use_cuda)


fn main() raises:
    var args = argv()
    if len(args) != 4:
        print("Usage: mojo plonk_prove_from_snapshot.mojo <pkg.nmbp> <snapshot.nmbws> <out_proof.bin>")
        return

    var proof_bytes = prove_from_snapshot_bytes(
        Path(args[1]).read_bytes(),
        Path(args[2]).read_bytes(),
    )
    Path(args[3]).write_bytes(proof_bytes)
