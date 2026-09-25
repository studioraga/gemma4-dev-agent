#!/usr/bin/env bash
set -euo pipefail

ROOT="$(
    cd "$(dirname "${BASH_SOURCE[0]}")/../.." &&
    pwd
)"

STAMP="$(
    date -u +%Y%m%dT%H%M%SZ
)"

OUT="$ROOT/evidence/m1-preflight/runs/$STAMP"

mkdir -p "$OUT"

echo "=================================================="
echo " GEMMA 4 DEVELOPER AGENT"
echo " M1 / GATE G1"
echo " RUN=$STAMP"
echo "=================================================="

echo
echo ">>> NODE1"

"$ROOT/scripts/preflight/m1_qualify_node1.sh" \
    2>&1 |
    tee "$OUT/node1.log"

echo
echo ">>> NODE2"

ssh gemma4-node2 '
    cd ~/dev/pub/ai-sys1/gemma4-dev-agent &&
    ./scripts/preflight/m1_qualify_node2.sh
' 2>&1 |
    tee "$OUT/node2.log"

echo
echo ">>> MANIFEST"

{
    echo "run=$STAMP"

    echo "node1_host=$(hostname)"
    echo "node1_arch=$(uname -m)"

    echo "node1_gpu=$(
        nvidia-smi \
          --query-gpu=name \
          --format=csv,noheader |
          head -1
    )"

    echo "node1_driver=$(
        nvidia-smi \
          --query-gpu=driver_version \
          --format=csv,noheader |
          head -1
    )"

    echo "node1_compute_cap=$(
        nvidia-smi \
          --query-gpu=compute_cap \
          --format=csv,noheader |
          head -1
    )"

    echo "node1_cuda=$(
        /usr/local/cuda-13.3/bin/nvcc \
          --version |
          grep 'release' |
          sed 's/^[[:space:]]*//'
    )"

    echo "node1_docker=$(
        docker version \
          --format '{{.Server.Version}}'
    )"

    echo "node2_host=$(
        ssh gemma4-node2 hostname
    )"

    echo "node2_arch=$(
        ssh gemma4-node2 uname -m
    )"

    echo "node2_cuda=$(
        ssh gemma4-node2 \
          '/usr/local/cuda-12.6/bin/nvcc --version |
           grep release |
           sed "s/^[[:space:]]*//"'
    )"

    echo "node2_docker=$(
        ssh gemma4-node2 \
          'docker version --format "{{.Server.Version}}"'
    )"

    echo "git_commit=$(
        git -C "$ROOT" \
          rev-parse HEAD \
          2>/dev/null ||
          echo UNCOMMITTED
    )"

} |
tee "$OUT/manifest.txt"

echo
echo ">>> SHA256"

(
    cd "$OUT"

    sha256sum \
        node1.log \
        node2.log \
        manifest.txt

) |
tee "$OUT/SHA256SUMS"

echo
echo "=================================================="
echo " GATE G1: PASS"
echo " M1 COMPLETE"
echo " READY FOR M2"
echo "=================================================="
