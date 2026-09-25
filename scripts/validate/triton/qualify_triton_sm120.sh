#!/usr/bin/env bash
set -euo pipefail

NORMAL_CACHE=/tmp/gemma4-triton-gate-normal
NOPTX_CACHE=/tmp/gemma4-triton-gate-no-ptx

rm -rf \
  "$NORMAL_CACHE" \
  "$NOPTX_CACHE"

mkdir -p \
  "$NORMAL_CACHE" \
  "$NOPTX_CACHE"

echo "=================================================="
echo "M2.5 TRITON / BLACKWELL / SM120 QUALIFICATION"
echo "=================================================="

echo
echo "=== ENVIRONMENT ==="

uv run python - <<'PY'
import torch
import triton

print("torch =", torch.__version__)
print("torch_cuda =", torch.version.cuda)
print("triton =", triton.__version__)
print("device =", torch.cuda.get_device_name(0))
print("capability =", torch.cuda.get_device_capability(0))

assert triton.__version__ == "3.8.0"
assert torch.cuda.is_available()
assert torch.cuda.get_device_capability(0) == (12, 0)

print("ENVIRONMENT_GATE=PASS")
PY

echo
echo "=== COLD NORMAL ==="

TRITON_CACHE_DIR="$NORMAL_CACHE" \
uv run python \
  scripts/validate/triton/validate_triton_sm120.py

NORMAL_CUBIN="$(
  find "$NORMAL_CACHE" \
    -type f \
    -name 'add_kernel.cubin' \
    | head -1
)"

test -n "$NORMAL_CUBIN"
test -f "$NORMAL_CUBIN"

echo "NORMAL_CUBIN=$NORMAL_CUBIN"

/usr/local/cuda-13.3/bin/cuobjdump \
  --list-elf \
  "$NORMAL_CUBIN" \
  > /tmp/gemma4-triton-normal-cuobjdump.log 2>&1

grep -q \
  'sm_120' \
  /tmp/gemma4-triton-normal-cuobjdump.log

echo "COLD_NORMAL_SM120=PASS"

echo
echo "=== COLD NO PTX JIT ==="

CUDA_DISABLE_PTX_JIT=1 \
TRITON_CACHE_DIR="$NOPTX_CACHE" \
uv run python \
  scripts/validate/triton/validate_triton_sm120.py

NOPTX_CUBIN="$(
  find "$NOPTX_CACHE" \
    -type f \
    -name 'add_kernel.cubin' \
    | head -1
)"

test -n "$NOPTX_CUBIN"
test -f "$NOPTX_CUBIN"

echo "NOPTX_CUBIN=$NOPTX_CUBIN"

/usr/local/cuda-13.3/bin/cuobjdump \
  --list-elf \
  "$NOPTX_CUBIN" \
  > /tmp/gemma4-triton-no-ptx-cuobjdump.log 2>&1

grep -q \
  'sm_120' \
  /tmp/gemma4-triton-no-ptx-cuobjdump.log

echo "COLD_NO_PTX_SM120=PASS"

echo
echo "=== WARM NO PTX JIT ==="

CUDA_DISABLE_PTX_JIT=1 \
TRITON_CACHE_DIR="$NOPTX_CACHE" \
uv run python \
  scripts/validate/triton/validate_triton_sm120.py

echo "WARM_NO_PTX=PASS"

echo
echo "=================================================="
echo "TRITON_SM120_QUALIFICATION=PASS"
echo "=================================================="
