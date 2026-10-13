#!/bin/bash
# Usage: sweep.sh N1 N2 ... ; prints N and whether the build crashed.
cd "$(dirname "$0")/btree_ice"
for N in "$@"; do
  sed -i "s/^pub const N: usize = .*/pub const N: usize = $N;/" src/lib.rs
  out=$(cargo build --release 2>&1)
  if echo "$out" | grep -q "Cannot select"; then
    echo "$N CRASH $(echo "$out" | grep -o 'Constant<[0-9]*>' | head -1)"
  elif echo "$out" | grep -q "^error"; then
    echo "$N ERROR"
  else
    echo "$N ok"
  fi
done
