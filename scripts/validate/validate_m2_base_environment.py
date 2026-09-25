#!/usr/bin/env python3

from __future__ import annotations

import platform
import shutil
import subprocess
import sys
from pathlib import Path


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
print("M2 Base Environment Qualification")
print("=" * 50)

check(
    sys.version_info[:2] == (3, 12),
    f"Python 3.12 ({sys.version.split()[0]})",
)

check(
    sys.prefix != sys.base_prefix,
    "project virtual environment active",
)

check(
    platform.python_implementation() == "CPython",
    f"CPython runtime ({platform.python_implementation()})",
)

check(
    platform.machine() == "x86_64",
    f"Node1 architecture x86_64 ({platform.machine()})",
)

check(
    shutil.which("uv") is not None,
    "uv executable available",
)

nvcc = Path("/usr/local/cuda-13.3/bin/nvcc")

check(
    nvcc.is_file(),
    "CUDA 13.3 nvcc present",
)

if nvcc.is_file():
    proc = subprocess.run(
        [str(nvcc), "--version"],
        text=True,
        capture_output=True,
        check=False,
    )

    check(
        proc.returncode == 0,
        "nvcc executable works",
    )

    check(
        "release 13.3" in proc.stdout,
        "CUDA toolkit release 13.3",
    )

nvidia_smi = shutil.which("nvidia-smi")

check(
    nvidia_smi is not None,
    "nvidia-smi available",
)

if nvidia_smi:
    proc = subprocess.run(
        [
            nvidia_smi,
            "--query-gpu=name,driver_version,compute_cap",
            "--format=csv,noheader",
        ],
        text=True,
        capture_output=True,
        check=False,
    )

    check(
        proc.returncode == 0,
        "nvidia-smi query works",
    )

    output = proc.stdout.strip()

    print(f"GPU_QUERY={output}")

    check(
        "NVIDIA GeForce RTX 5060 Ti" in output,
        "expected RTX 5060 Ti",
    )

    check(
        "580.159.03" in output,
        "qualified R580 driver",
    )

    check(
        "12.0" in output,
        "compute capability 12.0 / sm_120",
    )

print()
print(f"PASS={passes} FAIL={len(failures)}")

if failures:
    print("RESULT=FAIL")
    for failure in failures:
        print(f"FAILED_CHECK={failure}")
    raise SystemExit(1)

print("RESULT=PASS")
