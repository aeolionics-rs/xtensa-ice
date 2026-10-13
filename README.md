# Xtensa backend: `Cannot select: i32 = Constant<2048>` for folded address constants that are multiples of 256

## Summary

Instruction selection for Xtensa aborts with `LLVM ERROR: Cannot select:
... i32 = Constant<N>` when a loop's address arithmetic folds to a constant
that is a multiple of 256 and outside the 12-bit signed `movi` range
(2048, 2304, 2560, 3072, 4096, 8192 all fail; 1024, 2044, 2556, -2048 and
32768 are fine). The same offsets compile when they are written directly or
when they are not multiples of 256, so this looks like an immediate that is
accepted as legal (the `addmi` shape, imm8 << 8) but has no pattern to
materialise it as a standalone value.

In practice this hits Rust code for `xtensa-esp32s3-espidf`: the standard
library's `BTreeMap` node code (`correct_childrens_parent_links`, inlined
into `do_merge`) walks the node's edge array from index `len + 1`. For a
value type of a particular size the edge array sits at offset 2044 in the
node, `2044 + 4 * (len + 1)` folds to `2048 + 4 * len`, and the crate fails
to compile. Growing or shrinking the value type by a byte makes it compile
again, so projects trip over this at random when a struct in a `BTreeMap`
changes size.

The crash reproduces with plain `llc` from esp-clang on a 17-line IR file
(below), so the bug is in the Xtensa backend of the LLVM fork, not in rustc.

## Versions

- esp-clang `esp-21.1.3_20260408` (`llc --version`: Espressif LLVM version 21.1.3, optimized build), Linux x86_64 host
- Also reproduced with the `llc` from the latest release, esp-clang `esp-22.1.4_20260825` (Espressif LLVM version 22.1.4): `loop-2048.ll`, the reduced function and the full crate IR all fail the same way at `-O1` and `-O2` (`llc-crash-22.1.4.txt`)
- Rust `esp` toolchain from espup 0.18.0: `rustc 1.97.0-nightly (8ea53bcd7 2026-07-08) (1.97.0.0)`, LLVM version 21.1.3, host `x86_64-unknown-linux-gnu`
- Target `xtensa-esp32s3-espidf` (rustc), triple `xtensa-unknown-none-elf` in the emitted IR; `-mcpu=esp32s3` makes no difference

## Minimal IR reproducer (`loop-2048.ll`)

```llvm
target datalayout = "e-m:e-p:32:32-v1:8:8-i64:64-i128:128-n32"
target triple = "xtensa-unknown-none-elf"

define void @f(ptr %node, i32 %len, i32 %end) {
entry:
  %edges = getelementptr inbounds nuw i8, ptr %node, i32 2044
  %start = add nuw nsw i32 %len, 1
  br label %loop
loop:
  %i = phi i32 [ %start, %entry ], [ %next, %loop ]
  %next = add nuw nsw i32 %i, 1
  %slot = getelementptr inbounds nuw ptr, ptr %edges, i32 %i
  %child = load ptr, ptr %slot, align 4
  %parent = getelementptr inbounds nuw i8, ptr %child, i32 2024
  store ptr %node, ptr %parent, align 4
  %done = icmp eq i32 %i, %end
  br i1 %done, label %exit, label %loop
exit:
  ret void
}
```

```
$ llc -O1 loop-2048.ll -o /dev/null
LLVM ERROR: Cannot select: 0x55cbd51aafd0: i32 = Constant<2048>
In function: f
```

`-O0` compiles it; `-O1` and `-O2` crash. Changing the base offset shows
which folded constants (base + 4) fail:

| `%edges` offset | folded constant | result |
|---|---|---|
| 1020 | 1024 | ok |
| 2040 | 2044 | ok |
| 2044 | 2048 | **crash** `Constant<2048>` |
| 2300 | 2304 | **crash** `Constant<2304>` |
| 2552 | 2556 | ok |
| 2556 | 2560 | **crash** `Constant<2560>` |
| 3068 | 3072 | **crash** `Constant<3072>` |
| 4092 | 4096 | **crash** `Constant<4096>` |
| 8188 | 8192 | **crash** `Constant<8192>` |
| 32764 | 32768 | ok |
| -2052 | -2048 | ok |

Every failing value is a multiple of 256 in [2048, 32512], i.e. outside
`movi`'s signed 12-bit immediate but inside `addmi`'s (imm8 << 8); values
below 2048 or above 32512, or not multiples of 256, work. With offset 2040
the working code materialises the constant with `movi a8, 2044` and feeds it
to `addx4`, so presumably the failing case wants the same `movi` but the
constant was classified as something `movi` can't take.

Writing the offset directly (`getelementptr i8, ptr %p, i32 2048` followed
by a load or store, with or without a variable index) compiles, as does the
loop when the start index is a plain argument instead of `%len + 1`. The
fold of `2044 + 4` into the induction variable's start is what produces the
bare constant.

## Rust reproducer (`btree_ice/`)

A library crate with nothing but a `BTreeMap<u8, [u8; 184]>`:

`Cargo.toml`
```toml
[package]
name = "btree_ice"
version = "0.1.0"
edition = "2024"

[lib]
crate-type = ["lib"]

[profile.release]
opt-level = "s"
```

`rust-toolchain.toml`
```toml
[toolchain]
channel = "esp"
```

`.cargo/config.toml`
```toml
[build]
target = "xtensa-esp32s3-espidf"

[unstable]
build-std = ["std", "panic_abort"]
```

`src/lib.rs`
```rust
use std::collections::BTreeMap;

/// Change N to vary the value size.
pub const N: usize = 184;

pub type Map = BTreeMap<u8, [u8; N]>;

pub fn insert(map: &mut Map, key: u8, value: [u8; N]) {
    map.insert(key, value);
}

pub fn remove(map: &mut Map, key: u8) -> Option<[u8; N]> {
    map.remove(&key)
}
```

```
$ cargo build --release
   Compiling btree_ice v0.1.0 (…/btree_ice)
rustc-LLVM ERROR: Cannot select: 0x7283dc696ea0: i32 = Constant<2048>
In function: _RINvMsp_NtNtNtCsbIaysLmJLTs_5alloc11collections5btree4nodeINtB6_7NodeRefNtNtB6_6marker3MuthAhjb8_NtB1a_8InternalE30correct_childrens_parent_linksINtNtNtCsdKk7EqVcRUz_4core3ops5range5RangejEECs8pLgv9eiclp_9btree_ice
error: could not compile `btree_ice` (lib)
```

No ESP-IDF is needed: the crate doesn't link. (`cargo rustc --release --
--emit=llvm-ir` writes the IR before the crash; `btree_ice-n184-full.ll` is
that output and `btree-do_merge-reduced.ll` is the one failing function cut
out of it, 80 lines, which `llc -O1` also rejects.)

Value sizes swept (`[u8; N]`, even N from 150 to 260 plus a few odd ones):

| N | result |
|---|---|
| 150–182, 186–230, 232–252, 256–260, 181, 183, 185, 187, 207, 253, 255 | ok |
| 184 | **crash** `Constant<2048>` |
| 231 | **crash** `Constant<2560>` |
| 254 | **crash** `Constant<2816>` |

With N = 184 the node layout on this 32-bit target is: values at 0
(11 × 184 = 2024), parent pointer at 2024, parent index at 2028, len at
2030, keys at 2032, edges at 2044. The crashing constants are
`edges + 4` for 184 and `edges` for 231 and 254, all multiples of 256.

Other observations at N = 184:

| | result |
|---|---|
| `opt-level` 1, 2, 3, s | crash |
| `opt-level` 0, z | ok |
| host target (`--target x86_64-unknown-linux-gnu`, same toolchain) | ok |
| value as a struct (`[u64; 20]` + `[u32; 6]`, or a struct wrapping `[u8; 184]`) | crash |

## Workaround

Keep the value type out of the node: `BTreeMap<u8, Box<T>>` compiles, as
does changing the size of `T` by a byte or two. Building with `opt-level =
"z"` also avoids it.

## Where to file

The crash message points to
https://github.com/espressif/esp-llvm-embedded-toolchain/issues. The fault
is in instruction selection (`XtensaDAGToDAGISel::Select` →
`SelectionDAGISel::CannotYetSelect`, see `llc-crash.txt` for the backtrace),
which lives in the Xtensa backend of https://github.com/espressif/llvm-project,
so that is the repository that can fix it; the embedded-toolchain repo only
packages it. Since Rust users hit it through the `esp` toolchain, a
cross-reference in https://github.com/esp-rs/rust would let them find the
workaround, but the fix doesn't belong there.

## Files

- `loop-2048.ll`: the 17-line IR reproducer
- `btree-do_merge-reduced.ll`: the failing function from the Rust crate's IR, reduced
- `btree_ice-n184-full.ll`: the crate's full IR at N = 184
- `btree_ice/`: the Rust crate
- `llc-crash.txt`: full `llc` output with backtrace (21.1.3); `llc-crash-22.1.4.txt`: the same with 22.1.4
- `ISSUE.md`: the report laid out in the fields of Espressif's bug-report form, ready to paste
- `sweep-array.log`, `sweep-odd.log`, `optlevels.log`: raw sweep results
- `repro.sh`: runs the cargo build and the `llc` reproducer
