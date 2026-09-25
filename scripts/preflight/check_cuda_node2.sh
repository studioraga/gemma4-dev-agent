#!/usr/bin/env bash
set -euo pipefail

ROOT="$(
    cd "$(dirname "${BASH_SOURCE[0]}")/../.." &&
    pwd
)"

NVCC=/usr/local/cuda-12.6/bin/nvcc
SRC="$ROOT/scripts/preflight/cuda/cuda_smoke.cu"
BIN=/tmp/gemma4_cuda_smoke_node2

echo "=== NODE2 CUDA QUALIFICATION ==="

echo
echo "NVCC:"
"$NVCC" --version

echo
echo "BUILD:"
"$NVCC" \
    -O2 \
    -arch=sm_87 \
    "$SRC" \
    -o "$BIN"

echo "BUILD=PASS"

echo
echo "RUN:"
OUTPUT="$("$BIN" 2>&1)"

printf '%s\n' "$OUTPUT"

grep -q 'CUDA_CC=8.7' <<<"$OUTPUT"
grep -q 'CUDA_RESULT=42' <<<"$OUTPUT"
grep -q 'CUDA_SMOKE=PASS' <<<"$OUTPUT"

echo
echo "NODE2_CUDA=PASS"
