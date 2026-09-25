#!/usr/bin/env python3

import os
import time

from vllm import LLM


model = os.environ["MODEL_DIR"]

offload_gb = float(
    os.environ.get(
        "CPU_OFFLOAD_GB",
        "12",
    )
)

start = time.perf_counter()

print(
    f"M27_CPU_OFFLOAD_GB={offload_gb}",
    flush=True,
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

elapsed = time.perf_counter() - start

print(
    f"M27_MODEL_LOAD_SECONDS={elapsed:.3f}",
    flush=True,
)

print(
    "M27_CPU_OFFLOAD_LOAD=PASS",
    flush=True,
)
