#!/usr/bin/env python3

from __future__ import annotations

import os
import re
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
        "M27_TEST=CODING_CHAT_V2",
        flush=True,
    )

    print(
        f"M27_CPU_OFFLOAD_GB="
        f"{CPU_OFFLOAD_GB}",
        flush=True,
    )

    load_start = time.perf_counter()

    llm = LLM(
        model=MODEL_DIR,
        trust_remote_code=False,
        tensor_parallel_size=1,
        max_model_len=1024,
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
        max_tokens=128,
    )

    messages = [
        {
            "role": "user",
            "content": (
                "Write only Python code.\n\n"
                "Implement exactly this function:\n\n"
                "def add(a: int, b: int) -> int:\n"
                "    ...\n\n"
                "The function must return a + b."
            ),
        }
    ]

    start = time.perf_counter()

    outputs = llm.chat(
        messages,
        sampling_params=params,
    )

    elapsed = (
        time.perf_counter()
        - start
    )

    out = outputs[0].outputs[0]

    text = out.text.strip()

    print(
        "=== OUTPUT ===",
        flush=True,
    )

    print(
        text,
        flush=True,
    )

    print(
        "OUTPUT_REPR=",
        repr(out.text),
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
        f"{elapsed:.6f}",
        flush=True,
    )

    if elapsed > 0:
        rate = (
            len(out.token_ids)
            / elapsed
        )

        print(
            f"OUTPUT_TOKENS_PER_SECOND="
            f"{rate:.6f}",
            flush=True,
        )

    has_function = bool(
        re.search(
            r"def\s+add\s*\(",
            text,
        )
    )

    has_return = bool(
        re.search(
            r"return\s+a\s*\+\s*b",
            text,
        )
    )

    semantic_pass = (
        has_function
        and has_return
    )

    print(
        "CODING_HAS_FUNCTION="
        + (
            "PASS"
            if has_function
            else "FAIL"
        ),
        flush=True,
    )

    print(
        "CODING_HAS_RETURN="
        + (
            "PASS"
            if has_return
            else "FAIL"
        ),
        flush=True,
    )

    print(
        "CODING_SEMANTIC_RESULT="
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
        "M27_CODING_CHAT_V2=PASS",
        flush=True,
    )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
