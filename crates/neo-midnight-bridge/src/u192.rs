#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct U192 {
    /// Little-endian 64-bit limbs.
    pub limbs: [u64; 3],
}

impl U192 {
    pub const ZERO: Self = Self { limbs: [0, 0, 0] };

    pub fn from_u64(x: u64) -> Self {
        Self { limbs: [x, 0, 0] }
    }

    pub fn from_u128(x: u128) -> Self {
        Self {
            limbs: [x as u64, (x >> 64) as u64, 0],
        }
    }

    pub fn low_u128(self) -> u128 {
        (self.limbs[0] as u128) | ((self.limbs[1] as u128) << 64)
    }

    pub fn add_u64(self, x: u64) -> Self {
        let (l0, c0) = self.limbs[0].overflowing_add(x);
        let (l1, c1) = self.limbs[1].overflowing_add(c0 as u64);
        let (l2, c2) = self.limbs[2].overflowing_add(c1 as u64);
        debug_assert!(!c2, "U192 overflow in add_u64");
        Self { limbs: [l0, l1, l2] }
    }

    pub fn add_u128(self, x: u128) -> Self {
        let x0 = x as u64;
        let x1 = (x >> 64) as u64;
        let (l0, c0) = self.limbs[0].overflowing_add(x0);
        let (l1, c1) = self.limbs[1].overflowing_add(x1);
        let (l1, c1b) = l1.overflowing_add(c0 as u64);
        let (l2, c2) = self.limbs[2].overflowing_add((c1 as u64) + (c1b as u64));
        debug_assert!(!c2, "U192 overflow in add_u128");
        Self { limbs: [l0, l1, l2] }
    }

    pub fn add(self, other: Self) -> Self {
        let (l0, c0) = self.limbs[0].overflowing_add(other.limbs[0]);
        let (l1, c1) = self.limbs[1].overflowing_add(other.limbs[1]);
        let (l2, c2) = self.limbs[2].overflowing_add(other.limbs[2]);

        let (l1, c1b) = l1.overflowing_add(c0 as u64);
        let (l2, c2b) = l2.overflowing_add((c1 as u64) + (c1b as u64));
        debug_assert!(!(c2 || c2b), "U192 overflow in add");
        Self { limbs: [l0, l1, l2] }
    }

    pub fn sub_u64(self, x: u64) -> Self {
        let (l0, b0) = self.limbs[0].overflowing_sub(x);
        let (l1, b1) = self.limbs[1].overflowing_sub(b0 as u64);
        let (l2, b2) = self.limbs[2].overflowing_sub(b1 as u64);
        debug_assert!(!b2, "U192 underflow in sub_u64");
        Self { limbs: [l0, l1, l2] }
    }

    pub fn sub_u128(self, x: u128) -> Self {
        let x0 = x as u64;
        let x1 = (x >> 64) as u64;
        let (l0, b0) = self.limbs[0].overflowing_sub(x0);
        let (l1, b1) = self.limbs[1].overflowing_sub(x1);
        let (l1, b1b) = l1.overflowing_sub(b0 as u64);
        let borrow12 = (b1 as u64) + (b1b as u64);
        let (l2, b2) = self.limbs[2].overflowing_sub(borrow12);
        debug_assert!(!b2, "U192 underflow in sub_u128");
        Self { limbs: [l0, l1, l2] }
    }

    pub fn sub(self, other: Self) -> Self {
        let (l0, b0) = self.limbs[0].overflowing_sub(other.limbs[0]);
        let (l1, b1) = self.limbs[1].overflowing_sub(other.limbs[1]);
        let (l2, b2) = self.limbs[2].overflowing_sub(other.limbs[2]);

        let (l1, b1b) = l1.overflowing_sub(b0 as u64);
        let borrow12 = (b1 as u64) + (b1b as u64);
        let (l2, b2b) = l2.overflowing_sub(borrow12);
        debug_assert!(!(b2 || b2b), "U192 underflow in sub");
        Self { limbs: [l0, l1, l2] }
    }

    pub fn shl_small(self, shift: u32) -> Self {
        assert!(shift < 64, "shift must be <64");
        if shift == 0 {
            return self;
        }
        let a0 = self.limbs[0];
        let a1 = self.limbs[1];
        let a2 = self.limbs[2];
        let carry0 = a0 >> (64 - shift);
        let carry1 = a1 >> (64 - shift);
        let l0 = a0 << shift;
        let l1 = (a1 << shift) | carry0;
        let l2 = (a2 << shift) | carry1;
        Self { limbs: [l0, l1, l2] }
    }

    /// Multiply a 128-bit value by a 64-bit value, producing a 192-bit product.
    pub fn mul_u128_u64(x: u128, y: u64) -> Self {
        let x0 = x as u64;
        let x1 = (x >> 64) as u64;

        let prod0 = (x0 as u128) * (y as u128);
        let prod1 = (x1 as u128) * (y as u128);

        let l0 = prod0 as u64;
        let carry0 = (prod0 >> 64) as u64;

        let prod1_lo = prod1 as u64;
        let prod1_hi = (prod1 >> 64) as u64;

        let mid = (carry0 as u128) + (prod1_lo as u128);
        let l1 = mid as u64;
        let carry1 = (mid >> 64) as u64;

        let l2 = prod1_hi.wrapping_add(carry1);
        Self { limbs: [l0, l1, l2] }
    }

    /// Divide by a 64-bit divisor, returning (quotient, remainder).
    pub fn div_rem_u64(self, d: u64) -> (Self, u64) {
        assert!(d != 0, "division by zero");
        let d128 = d as u128;

        let mut rem: u128 = 0;
        let mut q = [0u64; 3];

        for (out_idx, limb) in self.limbs.iter().copied().enumerate().rev() {
            let dividend: u128 = (rem << 64) | (limb as u128);
            q[out_idx] = (dividend / d128) as u64;
            rem = dividend % d128;
        }

        (Self { limbs: q }, rem as u64)
    }
}

