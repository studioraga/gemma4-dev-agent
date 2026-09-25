#!/usr/bin/env python3

from __future__ import annotations

import sys

import numpy as np
import torch


passes = 0
failures: list[str] = []


def check(condition: bool, message: str) -> None:
    global passes

    if condition:
        print(f"[PASS] {message}")
        passes += 1
    else:
        print(f"[FAIL] {message}")
        failures.append(message)


print("Gemma 4 Developer Agent")
print("PyTorch / NumPy Interoperability Qualification")
print("=" * 58)

print(f"python={sys.version.split()[0]}")
print(f"torch={torch.__version__}")
print(f"numpy={np.__version__}")

check(
    sys.version_info[:2] == (3, 12),
    "Python 3.12",
)

check(
    torch.__version__.startswith("2.14.0"),
    f"PyTorch 2.14.0 ({torch.__version__})",
)

# NumPy -> CPU torch tensor
a = np.arange(
    1024,
    dtype=np.float32,
)

t = torch.from_numpy(a)

check(
    t.dtype == torch.float32,
    "NumPy float32 -> torch.float32",
)

check(
    t.shape == (1024,),
    "NumPy -> torch shape preserved",
)

check(
    np.array_equal(
        t.numpy(),
        a,
    ),
    "NumPy -> torch -> NumPy round-trip",
)

# CPU torch -> NumPy
cpu = torch.arange(
    1024,
    dtype=torch.float32,
)

cpu_np = cpu.numpy()

check(
    isinstance(cpu_np, np.ndarray),
    "torch CPU tensor -> NumPy ndarray",
)

check(
    np.array_equal(
        cpu_np,
        np.arange(1024, dtype=np.float32),
    ),
    "torch CPU -> NumPy correctness",
)

# CUDA -> CPU -> NumPy
check(
    torch.cuda.is_available(),
    "CUDA available",
)

gpu = torch.arange(
    1024,
    dtype=torch.float32,
    device="cuda",
)

gpu_result = (
    gpu * 2.0 + 3.0
)

torch.cuda.synchronize()

gpu_np = gpu_result.cpu().numpy()

expected = (
    np.arange(1024, dtype=np.float32)
    * 2.0
    + 3.0
)

check(
    np.array_equal(
        gpu_np,
        expected,
    ),
    "CUDA -> CPU -> NumPy correctness",
)

print()
print(f"PASS={passes} FAIL={len(failures)}")

if failures:
    for item in failures:
        print(f"FAILED_CHECK={item}")

    print("RESULT=FAIL")
    raise SystemExit(1)

print("RESULT=PASS")
