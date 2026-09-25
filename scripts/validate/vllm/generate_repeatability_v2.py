#!/usr/bin/env python3

from __future__ import annotations

import os

from vllm import LLM, SamplingParams


MODEL_DIR = os.environ["MODEL_DIR"]

OFFLOAD = float(
    os.environ.get(
        "CPU_OFFLOAD_GB",
        "12",
    )
)


def main() -> int:
    llm = LLM(
        model=MODEL_DIR,
        trust_remote_code=False,
        tensor_parallel_size=1,
        max_model_len=512,
        gpu_memory_utilization=0.85,
        cpu_offload_gb=OFFLOAD,
        enforce_eager=True,
    )

    params = SamplingParams(
        temperature=0.0,
        max_tokens=32,
    )

    tests = [
        (
            "What is 7 + 8? "
            "Reply with only the number.",
            "15",
        ),
        (
            "What is 6 * 9? "
            "Reply with only the number.",
            "54",
        ),
        (
            "What is 100 - 37? "
            "Reply with only the number.",
            "63",
        ),
    ]

    failures = 0

    for index, (
        prompt,
        expected,
    ) in enumerate(
        tests,
        start=1,
    ):
        result = llm.chat(
            [
                {
                    "role": "user",
                    "content": prompt,
                }
            ],
            sampling_params=params,
        )

        output = (
            result[0]
            .outputs[0]
        )

        text = output.text.strip()

        passed = (
            text == expected
            or text.startswith(
                expected
            )
        )

        print(
            f"TEST={index}"
        )

        print(
            f"PROMPT={prompt!r}"
        )

        print(
            f"EXPECTED={expected!r}"
        )

        print(
            f"OUTPUT={text!r}"
        )

        print(
            "RESULT="
            + (
                "PASS"
                if passed
                else "FAIL"
            )
        )

        if not passed:
            failures += 1

    print(
        f"PASS={len(tests) - failures}"
    )

    print(
        f"FAIL={failures}"
    )

    if failures:
        print(
            "M27_REPEATABILITY=FAIL"
        )
        return 1

    print(
        "M27_REPEATABILITY=PASS"
    )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
