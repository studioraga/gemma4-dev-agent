#!/usr/bin/env python3

import os
import time

from vllm import LLM


model = os.environ["MODEL_DIR"]

start = time.perf_counter()

print(
    "M27_LOAD_MODE=NO_OFFLOAD",
    flush=True,
)

llm = LLM(
    model=model,
    trust_remote_code=False,
    tensor_parallel_size=1,
    max_model_len=512,
    gpu_memory_utilization=0.85,
    cpu_offload_gb=0,
    enforce_eager=True,
)

elapsed = time.perf_counter() - start

print(
    f"M27_MODEL_LOAD_SECONDS={elapsed:.3f}",
    flush=True,
)

print(
    "M27_NO_OFFLOAD_LOAD=PASS",
    flush=True,
)
