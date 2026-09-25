#!/usr/bin/env bash
set -euo pipefail

ROOT="$(
    cd "$(dirname "${BASH_SOURCE[0]}")/../.." &&
    pwd
)"

NVCC=/usr/local/cuda-13.3/bin/nvcc
SRC="$ROOT/scripts/preflight/cuda/cuda_smoke.cu"
BIN=/tmp/gemma4_cuda_smoke_node1

echo "=== NODE1 CUDA QUALIFICATION ==="

echo
echo "GPU:"
nvidia-smi \
  --query-gpu=name,driver_version,compute_cap \
  --format=csv,noheader

echo
echo "NVCC:"
"$NVCC" --version

echo
echo "BUILD:"
"$NVCC" \
    -O2 \
    -arch=sm_120 \
    "$SRC" \
    -o "$BIN"

echo "BUILD=PASS"

echo
echo "CUBIN:"
"$NVCC" --version >/dev/null

/usr/local/cuda-13.3/bin/cuobjdump \
    --list-elf "$BIN" \
    | grep 'sm_120'

echo
echo "RUN:"
OUTPUT="$("$BIN" 2>&1)"

printf '%s\n' "$OUTPUT"

grep -q 'CUDA_CC=12.0' <<<"$OUTPUT"
grep -q 'CUDA_RESULT=42' <<<"$OUTPUT"
grep -q 'CUDA_SMOKE=PASS' <<<"$OUTPUT"

echo
echo "NODE1_CUDA=PASS"
