# Issue text for espressif/llvm-project

Filed as https://github.com/espressif/llvm-project/issues/141 on
2026-10-13. Espressif's repositories share one bug-report form; the headings
below are its fields, in order, with the text that was submitted.

Title:

    [Xtensa] Cannot select: i32 = Constant<2048> for a folded address constant that is a multiple of 256

## Checklist

- [x] Checked the issue tracker for similar issues to ensure this is not a duplicate
- [x] Read the documentation to confirm the issue is not addressed there and your configuration is set correctly
- [x] Tested with the latest version to ensure the issue hasn't been fixed

## How often does this bug occur?

always

## Expected behavior

`llc` compiles the 17-line function below for Xtensa at every optimisation
level. The address constant it needs, 2048, is an ordinary 32-bit immediate
that the backend can materialise with `movi` plus `addmi`, or from a
constant pool, as it does for 2044 or 2556.

## Actual behavior (suspected bug)

Instruction selection aborts with `LLVM ERROR: Cannot select: ... i32 =
Constant<2048>` at `-O1` and above. `-O0` compiles it.

The trigger is a loop whose address arithmetic folds a base offset of 2044
and a start index of `len + 1` into a bare constant 2048. Varying the base
offset shows the pattern: every failing constant is a multiple of 256 in
[2048, 32512], which is exactly the range outside `movi`'s 12-bit signed
immediate but inside `addmi`'s (imm8 << 8). Constants below 2048, above
32512, or not multiples of 256 compile. It looks as if such a constant is
accepted as a legal immediate (the `addmi` shape) but has no pattern to
materialise it as a standalone value.

| `%edges` offset | folded constant | result |
|---|---|---|
| 1020 | 1024 | ok |
| 2040 | 2044 | ok |
| 2044 | 2048 | crash `Constant<2048>` |
| 2300 | 2304 | crash `Constant<2304>` |
| 2552 | 2556 | ok |
| 2556 | 2560 | crash `Constant<2560>` |
| 3068 | 3072 | crash `Constant<3072>` |
| 4092 | 4096 | crash `Constant<4096>` |
| 8188 | 8192 | crash `Constant<8192>` |
| 32764 | 32768 | ok |
| -2052 | -2048 | ok |

Writing the offset directly (`getelementptr i8, ptr %p, i32 2048` with a
load or store, with or without a variable index) compiles, as does the
loop when the start index is a plain argument rather than `%len + 1`.

In practice this breaks Rust code for `xtensa-esp32s3-espidf`, where the
standard library's `BTreeMap` node code walks the node's edge array from
index `len + 1`. For value types of certain sizes (184, 231 and 254 bytes
on the 32-bit target) the edge array sits at an offset that folds to one of
these constants and the crate fails to compile; changing the value type's
size by a byte makes it compile again, so projects hit this at random when
a struct in a `BTreeMap` changes size. Reproducer and details in
https://github.com/aeolionics-rs/xtensa-ice.

## Error logs or terminal output

```
$ llc --version
Espressif LLVM version 21.1.3
  Optimized build.
  Default target: riscv32-esp-unknown-elf

$ llc -O1 loop-2048.ll -o /dev/null
LLVM ERROR: Cannot select: 0x55cbd51aafd0: i32 = Constant<2048>
In function: f
PLEASE submit a bug report to https://github.com/espressif/esp-llvm-embedded-toolchain/issues and include the crash backtrace.
Stack dump:
0.	Program arguments: llc -O1 loop-2048.ll -o /dev/null
1.	Running pass 'Function Pass Manager' on module 'loop-2048.ll'.
2.	Running pass 'Xtensa DAG->DAG Pattern Instruction Selection' on function '@f'
 #7 llvm::SelectionDAGISel::CannotYetSelect(llvm::SDNode*)
 #8 llvm::SelectionDAGISel::SelectCodeCommon(llvm::SDNode*, unsigned char const*, unsigned int)
 #9 (anonymous namespace)::XtensaDAGToDAGISel::Select(llvm::SDNode*) XtensaISelDAGToDAG.cpp:0:0
#10 llvm::SelectionDAGISel::DoInstructionSelection()
#11 llvm::SelectionDAGISel::CodeGenAndEmitDAG()
#12 llvm::SelectionDAGISel::SelectAllBasicBlocks(llvm::Function const&)
#13 llvm::SelectionDAGISel::runOnMachineFunction(llvm::MachineFunction&)
```

(Full backtraces: `llc-crash.txt` for 21.1.3 and `llc-crash-22.1.4.txt`
for 22.1.4 in https://github.com/aeolionics-rs/xtensa-ice.)

## Steps to reproduce the behavior

1. Save this as `loop-2048.ll`:

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

2. Run esp-clang's `llc -O1 loop-2048.ll -o /dev/null`. It aborts as above,
   with the `llc` from esp-22.1.4_20260825 as well as esp-21.1.3_20260408.
   `-O0` compiles it; `-O2` aborts. `-mcpu=esp32s3` makes no difference.
3. Change the `2044` in `%edges` to `2040` or `2552`: compiles. To `2300`
   or `4092`: aborts with `Constant<2304>` or `Constant<4096>`.

To see it from Rust (no ESP-IDF needed, the crate doesn't link): in
https://github.com/aeolionics-rs/xtensa-ice, `cd btree_ice && cargo build --release` with the `esp`
toolchain (espup) fails the same way in
`alloc::collections::btree::node::NodeRef<Mut, u8, [u8; 184], Internal>::correct_childrens_parent_links`.
`repro.sh` runs both.

## Project release version

esp-22.1.4_20260825 (latest release; Espressif LLVM version 22.1.4), and
esp-21.1.3_20260408 as shipped in the `esp` Rust toolchain (`rustc
1.97.0-nightly (8ea53bcd7 2026-07-08)`, LLVM 21.1.3). Both fail
identically.

## System architecture

Intel/AMD 64-bit (modern PC, older Mac)

## Operating system

Linux

## Operating system version

Ubuntu 26.04.1 LTS, kernel 7.0.0

## Shell

Bash

## Additional context

- The Rust reproducer, the crate's full IR, the one failing function cut
  from it (80 lines, also rejected by `llc -O1`) and the raw sweep logs are
  in https://github.com/aeolionics-rs/xtensa-ice.
- Sizes swept for `BTreeMap<u8, [u8; N]>`: even N from 150 to 260 plus
  some odd ones; only 184 (`Constant<2048>`), 231 (`Constant<2560>`) and
  254 (`Constant<2816>`) fail. At N = 184 the node layout is values at 0
  (11 × 184 = 2024), parent pointer 2024, parent index 2028, len 2030,
  keys 2032, edges 2044, so the failing constant is `edges + 4`.
- Rust `opt-level` 1, 2, 3 and s crash; 0 and z compile. The same crate
  for the host target with the same toolchain compiles.
- Workarounds: store `Box<T>` in the map, change the value type's size, or
  build with `opt-level = "z"`.
- Possibly related, another "Cannot select" on 21.1.3 with a different
  cause (constant-pool address): https://github.com/esp-rs/rust/issues/282
- Found by Jeremy Boynes with Claude (Anthropic) doing the reduction.
