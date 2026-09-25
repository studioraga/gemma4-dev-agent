#!/usr/bin/env bash
set -uo pipefail

PASS=0
FAIL=0
WARN=0

pass()
{
    printf '[PASS] %s\n' "$1"
    PASS=$((PASS + 1))
}

fail()
{
    printf '[FAIL] %s\n' "$1"
    FAIL=$((FAIL + 1))
}

warn()
{
    printf '[WARN] %s\n' "$1"
    WARN=$((WARN + 1))
}

has_cmd()
{
    command -v "$1" >/dev/null 2>&1
}

ROOT="$(
    cd "$(dirname "${BASH_SOURCE[0]}")/../.." &&
    pwd
)"

echo "=================================================="
echo " GEMMA 4 DEVELOPER AGENT"
echo " M1 NODE1 QUALIFICATION"
echo "=================================================="

echo
echo "=== PLATFORM ==="

ARCH="$(uname -m)"

if [[ "$ARCH" == "x86_64" ]]; then
    pass "architecture = x86_64"
else
    fail "architecture expected x86_64; found $ARCH"
fi

if [[ -r /etc/os-release ]]; then
    . /etc/os-release

    if [[ "${ID:-}" == "ubuntu" ]]; then
        pass "Ubuntu ${VERSION_ID:-unknown}"
    else
        fail "Ubuntu not detected"
    fi
else
    fail "/etc/os-release unavailable"
fi

MEM_KIB="$(
    awk '/MemTotal:/ {print $2}' \
      /proc/meminfo
)"

MEM_GIB=$((MEM_KIB / 1024 / 1024))

if (( MEM_GIB >= 32 )); then
    pass "RAM >= 32 GiB (${MEM_GIB} GiB)"
else
    fail "RAM below 32 GiB"
fi

FREE_KIB="$(
    df -Pk "$HOME" |
    awk 'NR == 2 {print $4}'
)"

FREE_GIB=$((FREE_KIB / 1024 / 1024))

if (( FREE_GIB >= 150 )); then
    pass "free disk >= 150 GiB (${FREE_GIB} GiB)"
else
    fail "free disk below 150 GiB (${FREE_GIB} GiB)"
fi

echo
echo "=== TOOLS ==="

for cmd in \
    git \
    curl \
    wget \
    jq \
    zip \
    unzip \
    rsync \
    ssh \
    python3 \
    gcc \
    g++ \
    cmake \
    ninja \
    docker
do
    if has_cmd "$cmd"; then
        pass "$cmd"
    else
        fail "$cmd unavailable"
    fi
done

if git lfs version >/dev/null 2>&1; then
    pass "Git LFS"
else
    fail "Git LFS"
fi

TMPDIR_VENV="$(
    mktemp -d
)"

if python3 -m venv \
    "$TMPDIR_VENV/test" >/dev/null 2>&1
then
    pass "Python venv"
else
    fail "Python venv"
fi

rm -rf "$TMPDIR_VENV"

echo
echo "=== GPU / CUDA ==="

if nvidia-smi >/dev/null 2>&1; then
    GPU="$(
        nvidia-smi \
          --query-gpu=name \
          --format=csv,noheader |
          head -1
    )"

    pass "NVIDIA GPU: $GPU"
else
    fail "NVIDIA GPU unavailable"
fi

CC="$(
    nvidia-smi \
      --query-gpu=compute_cap \
      --format=csv,noheader \
      2>/dev/null |
      head -1
)"

if [[ "$CC" == "12.0" ]]; then
    pass "GPU compute capability 12.0 / sm_120"
else
    fail "expected compute capability 12.0; found $CC"
fi

if "$ROOT/scripts/preflight/check_cuda_node1.sh" \
    >/tmp/gemma4-m1-node1-cuda.log 2>&1
then
    pass "CUDA 13.3 native sm_120 runtime"
else
    cat /tmp/gemma4-m1-node1-cuda.log
    fail "CUDA 13.3 native sm_120 runtime"
fi

DRIVER="$(
    nvidia-smi \
      --query-gpu=driver_version \
      --format=csv,noheader \
      2>/dev/null |
      head -1
)"

if [[ "$DRIVER" == 580.* ]]; then
    warn \
      "R580 + CUDA 13.3: native sm_120 qualified; CUDA 13.3 PTX JIT not assumed"
fi

echo
echo "=== DOCKER ==="

if docker info >/dev/null 2>&1; then
    pass "Docker daemon/user access"
else
    fail "Docker daemon/user access"
fi

DOCKER_ARCH="$(
    docker info \
      --format '{{.Architecture}}' \
      2>/dev/null
)"

if [[ "$DOCKER_ARCH" == "x86_64" ]]; then
    pass "Docker architecture = x86_64"
else
    fail "Docker architecture unexpected: $DOCKER_ARCH"
fi

if docker run --rm \
    hello-world >/dev/null 2>&1
then
    pass "Docker amd64 execution"
else
    fail "Docker amd64 execution"
fi

if "$ROOT/scripts/preflight/check_container_security.sh" \
    >/tmp/gemma4-m1-security.log 2>&1
then
    pass "container security primitives"
else
    cat /tmp/gemma4-m1-security.log
    fail "container security primitives"
fi

if command -v nvidia-ctk >/dev/null 2>&1; then
    pass "NVIDIA Container Toolkit"
else
    warn "NVIDIA Container Toolkit deferred to M2/M4"
fi

echo
echo "=== NODE2 ==="

if ssh \
    -o BatchMode=yes \
    -o ConnectTimeout=5 \
    gemma4-node2 \
    true >/dev/null 2>&1
then
    pass "Node1 -> Node2 SSH"
else
    fail "Node1 -> Node2 SSH"
fi

if ssh \
    -o BatchMode=yes \
    gemma4-node2 \
    'docker info >/dev/null 2>&1'
then
    pass "Node1 -> Node2 Docker"
else
    fail "Node1 -> Node2 Docker"
fi

if ssh \
    -o BatchMode=yes \
    gemma4-node2 \
    'docker run --rm ubuntu:22.04 uname -m' \
    2>/dev/null |
    grep -q '^aarch64$'
then
    pass "remote ARM64 container"
else
    fail "remote ARM64 container"
fi

echo
echo "--------------------------------------------------"
printf 'PASS=%d WARN=%d FAIL=%d\n' \
    "$PASS" "$WARN" "$FAIL"
echo "--------------------------------------------------"

if (( FAIL == 0 )); then
    echo "RESULT: NODE1 READY FOR M2"
    exit 0
fi

echo "RESULT: NODE1 BLOCKED"
exit 1
