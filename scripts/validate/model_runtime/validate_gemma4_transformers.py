#!/usr/bin/env python3

from __future__ import annotations

import importlib
import sys

import accelerate
import safetensors
import torch
import transformers


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
print("M2.6 Transformers / Gemma 4 Qualification")
print("=" * 58)

print("python =", sys.version.split()[0])
print("transformers =", transformers.__version__)
print("accelerate =", accelerate.__version__)
print("safetensors =", safetensors.__version__)
print("torch =", torch.__version__)

check(
    sys.version_info[:2] == (3, 12),
    "Python 3.12",
)

check(
    transformers.__version__ == "5.17.0",
    "Transformers 5.17.0",
)

check(
    accelerate.__version__ == "1.15.0",
    "Accelerate 1.15.0",
)

check(
    safetensors.__version__ == "0.8.0",
    "safetensors 0.8.0",
)

required_symbols = [
    "Gemma4Config",
    "Gemma4Processor",
]

for symbol in required_symbols:
    check(
        hasattr(transformers, symbol),
        f"Transformers exposes {symbol}",
    )

check(
    torch.__version__.startswith("2.14.0"),
    "qualified PyTorch remains installed",
)

check(
    torch.version.cuda == "13.0",
    "qualified PyTorch CUDA runtime remains 13.0",
)

print()
print(f"PASS={passes} FAIL={len(failures)}")

if failures:
    for item in failures:
        print(f"FAILED_CHECK={item}")

    print("RESULT=FAIL")
    raise SystemExit(1)

print("RESULT=PASS")
