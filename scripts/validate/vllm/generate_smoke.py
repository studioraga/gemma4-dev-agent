#!/usr/bin/env python3

import os
import time

from vllm import LLM, SamplingParams


model = os.environ["MODEL_DIR"]

offload_gb = float(
    os.environ.get(
        "CPU_OFFLOAD_GB",
        "12",
    )
)

llm = LLM(
    model=model,
    trust_remote_code=False,
    tensor_parallel_size=1,
    max_model_len=512,
    gpu_memory_utilization=0.85,
    cpu_offload_gb=offload_gb,
    enforce_eager=True,
)

params = SamplingParams(
    temperature=0.0,
    max_tokens=8,
)

prompt = (
    "Return only the number that is "
    "the sum of 17 and 25."
)

start = time.perf_counter()

outputs = llm.generate(
    [prompt],
    params,
)

elapsed = time.perf_counter() - start

text = outputs[0].outputs[0].text

num_tokens = len(
    outputs[0].outputs[0].token_ids
)

print(
    "OUTPUT=",
    repr(text),
)

print(
    "OUTPUT_TOKENS=",
    num_tokens,
)

print(
    f"GENERATION_SECONDS={elapsed:.6f}"
)

assert num_tokens > 0

print(
    "M27_GENERATION_SMOKE=PASS"
)
