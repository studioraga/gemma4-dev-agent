#!/usr/bin/env python3

from __future__ import annotations

import importlib.metadata
import json
from pathlib import Path

import torch
import triton
import vllm


MODEL_DIR = Path(
    "/tmp/gemma4-31b-metadata"
)


def main() -> int:
    passes = 0
    failures: list[str] = []

    def check(
        condition: bool,
        label: str,
    ) -> None:
        nonlocal passes

        if condition:
            print(f"[PASS] {label}")
            passes += 1
        else:
            print(f"[FAIL] {label}")
            failures.append(label)

    print("Gemma 4 Developer Agent")
    print("M2.7 vLLM Admission Gate")
    print("=" * 50)

    print(
        "vllm =",
        vllm.__version__,
    )

    print(
        "torch =",
        torch.__version__,
    )

    print(
        "torch CUDA =",
        torch.version.cuda,
    )

    print(
        "triton =",
        triton.__version__,
    )

    check(
        vllm.__version__ == "0.30.0",
        "vLLM 0.30.0",
    )

    check(
        torch.cuda.is_available(),
        "CUDA available",
    )

    check(
        torch.cuda.get_device_capability(0)
        == (12, 0),
        "Blackwell compute capability 12.0",
    )

    config = json.loads(
        (MODEL_DIR / "config.json").read_text()
    )

    check(
        config.get("model_type") == "gemma4",
        "Gemma 4 model type",
    )

    qconfig = config.get(
        "quantization_config"
    )

    check(
        qconfig is not None,
        "quantization config exists",
    )

    check(
        "compressed"
        in json.dumps(qconfig).lower(),
        "compressed-tensors metadata",
    )

    weight_files = list(
        MODEL_DIR.rglob("*.safetensors")
    )

    check(
        not weight_files,
        "full model weights not yet downloaded",
    )

    print()
    print(
        f"PASS={passes} "
        f"FAIL={len(failures)}"
    )

    if failures:
        for item in failures:
            print(
                "FAILED_CHECK=",
                item,
            )

        print("RESULT=FAIL")
        return 1

    print("RESULT=PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
