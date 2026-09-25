#!/usr/bin/env python3

import os
import time

from vllm import LLM, SamplingParams


model = os.environ["MODEL_DIR"]

offload_gb = float(
    os.environ["CPU_OFFLOAD_GB"]
)

llm = LLM(
    model=model,
    trust_remote_code=False,
    tensor_parallel_size=1,
    max_model_len=1024,
    gpu_memory_utilization=0.85,
    cpu_offload_gb=offload_gb,
    enforce_eager=True,
)

params = SamplingParams(
    temperature=0.0,
    max_tokens=128,
)

prompt = """Write only Python code.

Implement:

def add(a: int, b: int) -> int:
    ...

Return a + b.
"""

start = time.perf_counter()

outputs = llm.generate(
    [prompt],
    params,
)

elapsed = time.perf_counter() - start

out = outputs[0].outputs[0]

print("=== OUTPUT ===")
print(out.text)

print()
print(
    "output_tokens =",
    len(out.token_ids),
)

print(
    f"elapsed_seconds = {elapsed:.6f}"
)

if elapsed > 0:
    print(
        "output_tokens_per_second =",
        len(out.token_ids) / elapsed,
    )

assert len(out.token_ids) > 0

print(
    "M27_CODING_SMOKE=PASS"
)
