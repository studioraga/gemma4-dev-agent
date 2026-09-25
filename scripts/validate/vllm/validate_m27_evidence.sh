#!/usr/bin/env bash

set -euo pipefail

grep -q \
  'M27_SEMANTIC_CHAT_V2=PASS' \
  validation/m2/vllm/semantic-chat-v2.log

grep -q \
  'M27_CODING_CHAT_V2=PASS' \
  validation/m2/vllm/coding-chat-v2.log

grep -q \
  'M27_REPEATABILITY=PASS' \
  validation/m2/vllm/repeatability-v2.log

grep -q \
  'CODING_SEMANTIC_RESULT=PASS' \
  validation/m2/vllm/coding-chat-v2.log

grep -q \
  'RESULT=PASS' \
  validation/m2/vllm/m27-admission-gate.log

grep -q \
  'QUALIFIED_WITH_CPU_OFFLOAD' \
  evidence/m2-environment/vllm/M2.7-QUALIFICATION.txt

grep -q \
  'MarlinLinearKernel for CompressedTensorsWNA16' \
  validation/m2/vllm/quantization-runtime-observed-v2.log

grep -q \
  'UVAOffloader' \
  validation/m2/vllm/quantization-runtime-observed-v2.log

echo "M27_EVIDENCE_GATE=PASS"
