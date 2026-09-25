#!/usr/bin/env python3

from __future__ import annotations

import os
import time

from vllm import LLM, SamplingParams


MODEL_DIR = os.environ["MODEL_DIR"]

CPU_OFFLOAD_GB = float(
    os.environ.get(
        "CPU_OFFLOAD_GB",
        "12",
    )
)


def main() -> int:
    print(
        "M27_TEST=SEMANTIC_CHAT_V2",
        flush=True,
    )

    print(
        f"M27_CPU_OFFLOAD_GB={CPU_OFFLOAD_GB}",
        flush=True,
    )

    load_start = time.perf_counter()

    llm = LLM(
        model=MODEL_DIR,
        trust_remote_code=False,
        tensor_parallel_size=1,
        max_model_len=512,
        gpu_memory_utilization=0.85,
        cpu_offload_gb=CPU_OFFLOAD_GB,
        enforce_eager=True,
    )

    load_seconds = (
        time.perf_counter()
        - load_start
    )

    print(
        f"M27_MODEL_LOAD_SECONDS="
        f"{load_seconds:.6f}",
        flush=True,
    )

    params = SamplingParams(
        temperature=0.0,
        max_tokens=32,
    )

    messages = [
        {
            "role": "user",
            "content": (
                "What is 17 + 25? "
                "Reply with only the number."
            ),
        }
    ]

    start = time.perf_counter()

    outputs = llm.chat(
        messages,
        sampling_params=params,
    )

    generation_seconds = (
        time.perf_counter()
        - start
    )

    out = outputs[0].outputs[0]

    text = out.text.strip()

    print(
        "OUTPUT_REPR=",
        repr(out.text),
        flush=True,
    )

    print(
        "OUTPUT_STRIPPED=",
        repr(text),
        flush=True,
    )

    print(
        "OUTPUT_TOKEN_IDS=",
        out.token_ids,
        flush=True,
    )

    print(
        "OUTPUT_TOKENS=",
        len(out.token_ids),
        flush=True,
    )

    print(
        f"GENERATION_SECONDS="
        f"{generation_seconds:.6f}",
        flush=True,
    )

    semantic_pass = (
        text == "42"
        or text.startswith("42")
    )

    print(
        "SEMANTIC_EXPECTED=42",
        flush=True,
    )

    print(
        "SEMANTIC_RESULT="
        + (
            "PASS"
            if semantic_pass
            else "FAIL"
        ),
        flush=True,
    )

    if not semantic_pass:
        return 2

    print(
        "M27_SEMANTIC_CHAT_V2=PASS",
        flush=True,
    )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
