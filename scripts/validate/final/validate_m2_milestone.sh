#!/usr/bin/env bash

set -euo pipefail

grep -q \
  'SYSTEM_PYTHON_PROVENANCE=PASS' \
  evidence/m2-environment/final/python-interpreter-provenance-corrected.log

grep -q \
  'PROJECT_VENV_PROVENANCE=PASS' \
  evidence/m2-environment/final/python-interpreter-provenance-corrected.log

grep -q \
  'PROJECT_VENV_BASES_ON_SYSTEM_PYTHON=PASS' \
  evidence/m2-environment/final/python-interpreter-provenance-corrected.log

grep -q \
  'PROJECT_VENV_LINEAGE=PASS' \
  validation/m2/final/python-venv-lineage.log

grep -q \
  'RESULT=PASS' \
  validation/m2/final/m24-pytorch-regression.log

grep -q \
  'RESULT=PASS' \
  validation/m2/final/m24-pytorch-no-ptx-regression.log

grep -q \
  'TRITON_SM120_QUALIFICATION=PASS' \
  validation/m2/final/m25-triton-regression.log

grep -q \
  'M25_SM120A_EVIDENCE=PASS' \
  validation/m2/final/m25-sm120a-evidence.log \
  2>/dev/null \
  || grep -q \
    'sm_120a' \
    validation/m2/final/m25-sm120a-evidence.log

grep -q \
  'RESULT=PASS' \
  validation/m2/final/m26-transformers-regression.log

grep -q \
  'RESULT=PASS' \
  validation/m2/final/m26-locked-metadata-regression.log

grep -q \
  'M26_TORCHVISION_FINAL=PASS' \
  validation/m2/final/m26-torchvision-cuda-regression.log

grep -q \
  'M27_EVIDENCE_GATE=PASS' \
  validation/m2/final/m27-evidence-regression.log

grep -q \
  'M2_CORE_VERSION_GATE=PASS' \
  validation/m2/final/m2-core-version-gate.log

grep -q \
  '^M2:$' \
  evidence/m2-environment/final/M2-MILESTONE-QUALIFICATION.txt

grep -q \
  '^  QUALIFIED$' \
  evidence/m2-environment/final/M2-MILESTONE-QUALIFICATION.txt

echo \
  "M2_FINAL_ACCEPTANCE_GATE=PASS"
