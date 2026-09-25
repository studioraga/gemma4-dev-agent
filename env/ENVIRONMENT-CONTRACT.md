# Gemma 4 Developer Agent — M2 Environment Contract

## M1 release baseline

Release tag:

    m1-infra-preflight-v0.1.0

Release commit:

    16222fea306c5118458302ab3c780f8bd8bf0752

M2 must not modify the qualified M1 host driver, CUDA or platform
configuration unless a later evidence-based compatibility decision
explicitly requires it.

---

## Node1

Role:

- primary development
- Gemma inference
- training/research
- SWE-bench
- orchestration

Architecture:

    x86_64

Operating system:

    Ubuntu 24.04

Python baseline:

    CPython 3.12.3
    host executable: /usr/bin/python3

GPU:

    NVIDIA GeForce RTX 5060 Ti

Compute capability:

    12.0 / sm_120

NVIDIA driver:

    580.159.03

Host CUDA toolkit:

    CUDA 13.3

M1-qualified CUDA behavior:

    native sm_120 execution PASS

Known limitation:

    CUDA 13.3 PTX JIT must not be assumed with the current R580 driver.

---

## Node2

Role:

- heterogeneous ARM64 validation
- remote build/test execution
- cross-platform verification

Architecture:

    aarch64

Platform:

    NVIDIA Jetson Orin

Python baseline:

    Python 3.10.x

L4T:

    R36.4.7

JetPack:

    6.2.1+b38

CUDA:

    12.6

Compute capability:

    8.7 / sm_87

---

## Python environment policy

Project Python packages must not be installed into system Python.

Node1 uses a project-local uv-managed environment.

Node2 uses a separate validation environment compatible with its
JetPack/Python/CUDA stack.

---

## GPU dependency admission policy

Import success alone is insufficient.

Every GPU dependency must demonstrate actual device execution.

On Node1, CUDA-containing or CUDA-generating packages must additionally
demonstrate at least one of:

1. native sm_120 support;
2. successful source compilation for sm_120;
3. another independently verified compatible execution path.

Packages requiring explicit qualification include:

- PyTorch
- Triton
- vLLM
- FlashAttention
- bitsandbytes
- quantization kernels
- custom CUDA extensions
- Gemma runtime kernels

---

## Reproducibility policy

For every admitted dependency record:

- exact version
- package/index source
- Python version
- CUDA relationship
- GPU architecture support
- validation command
- validation result
- reproducibility evidence
- hashes where applicable

Only qualified versions may enter the release lock file.
