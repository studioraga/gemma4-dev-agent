# M2 — Reproducible Development & Model Runtime

## Objective

Freeze an evidence-backed local development and model-runtime
foundation for subsequent swegemma agent development.

## Components

### M2.4
PyTorch / NVIDIA Blackwell qualification.

### M2.5
Triton native Blackwell qualification, including sm_120a evidence.

### M2.6
Transformers, tokenizer, processor, torchvision, safetensors, and
Gemma 4 metadata/runtime qualification.

### M2.7
Exact Gemma 4 31B W4A16 functional feasibility using an isolated
vLLM runtime.

### M2.8
Final provenance correction, cross-milestone regression,
competition-parity boundary, repository-layout contract, security
freeze, and milestone tag.

## Competition Boundary

M2 is not swegemma harness parity.

The competition's 4x L4 serving topology, Python 3.13 repository
sandbox, graph tools, embeddings, offline wheel environment,
two-container verification lifecycle, and declarative submission
compiler are qualified starting in M3 and M4.

## Exit Criteria

- System Python provenance PASS
- Project venv provenance PASS
- M2.4 regression PASS
- M2.5 regression PASS
- M2.6 regression PASS
- M2.7 evidence regression PASS
- runtime separation PASS
- competition-parity boundary documented
- repository layout contract documented
- repository security/hygiene PASS
- final evidence hashes PASS
- annotated M2 tag pushed and verified
