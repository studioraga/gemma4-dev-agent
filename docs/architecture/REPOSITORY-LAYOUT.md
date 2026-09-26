# Repository Layout Contract

This repository evolves toward the following structure beginning
with M3.

```text
gemma4-dev-agent/
├── docs/
│   ├── competition/
│   ├── architecture/
│   ├── research/
│   └── milestones/
│
├── competition/
│   ├── baseline/
│   └── optimized/
│
├── data/
│   ├── manifests/
│   ├── splits/
│   └── derived/
│
├── harness/
│   └── validation/
│
├── training/
│   ├── sft/
│   ├── preference/
│   ├── lora/
│   └── datasets/
│
├── evaluation/
│   ├── configs/
│   ├── analysis/
│   └── failure_taxonomy/
│
├── scripts/
│   ├── validate/
│   ├── dataset/
│   ├── harness/
│   ├── training/
│   ├── evaluate/
│   └── package/
│
├── evidence/
└── validation/
```
