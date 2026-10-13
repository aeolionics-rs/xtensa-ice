#!/bin/sh
# Reproduces the Xtensa "Cannot select: i32 = Constant<2048>" crash two ways.
# 1. The Rust crate, with the `esp` toolchain (espup) and the xtensa target.
# 2. The 17-line LLVM IR file with esp-clang's llc, if it is installed.
set -e
cd "$(dirname "$0")"

echo "== 1. cargo (esp toolchain, -Z build-std, xtensa-esp32s3-espidf)"
( cd btree_ice && cargo build --release ) || echo "== cargo build failed as expected"

LLC=$(ls -d ~/.espressif/tools/esp-clang/*/esp-clang/bin/llc 2>/dev/null | head -1)
if [ -n "$LLC" ]; then
  echo "== 2. llc on loop-2048.ll"
  "$LLC" -O1 loop-2048.ll -o /dev/null || echo "== llc failed as expected"
fi
