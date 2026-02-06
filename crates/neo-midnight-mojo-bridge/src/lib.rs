#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Quotient72 {
    pub q0: u32,
    pub q1: u32,
    pub q2: u32,
    pub r: u64,
}

pub mod prover;

#[cfg(feature = "build-mojo")]
mod mojo {
    use super::Quotient72;
    use libloading::Library;
    use std::sync::OnceLock;

    type ReduceFn = unsafe extern "C" fn(u64, u64, u64, *mut u32, *mut u32, *mut u32, *mut u64);

    static LIB: OnceLock<Library> = OnceLock::new();
    static REDUCE_FN: OnceLock<ReduceFn> = OnceLock::new();

    fn reduce_fn() -> ReduceFn {
        *REDUCE_FN.get_or_init(|| {
            let lib = LIB.get_or_init(|| {
                let path = env!("NEO_MIDNIGHT_BRIDGE_MOJO_LIB_PATH");
                unsafe { Library::new(path) }.unwrap_or_else(|e| panic!("failed to load Mojo dylib ({path}): {e}"))
            });

            let sym: libloading::Symbol<ReduceFn> = unsafe {
                lib.get(b"neo_midnight_bridge_reduce_u192_quotient72\0")
                    .expect("failed to load Mojo symbol neo_midnight_bridge_reduce_u192_quotient72")
            };
            *sym
        })
    }

    pub fn reduce_u192_quotient72(limbs: [u64; 3]) -> Quotient72 {
        let mut q0: u32 = 0;
        let mut q1: u32 = 0;
        let mut q2: u32 = 0;
        let mut r: u64 = 0;
        unsafe { (reduce_fn())(limbs[0], limbs[1], limbs[2], &mut q0, &mut q1, &mut q2, &mut r) };
        Quotient72 { q0, q1, q2, r }
    }
}

#[cfg(feature = "build-mojo")]
pub fn reduce_u192_quotient72(limbs: [u64; 3]) -> Quotient72 {
    mojo::reduce_u192_quotient72(limbs)
}

#[cfg(not(feature = "build-mojo"))]
pub fn reduce_u192_quotient72(_limbs: [u64; 3]) -> Quotient72 {
    panic!("neo-midnight-mojo-bridge: enable the `build-mojo` feature to compile the bundled Mojo library");
}
