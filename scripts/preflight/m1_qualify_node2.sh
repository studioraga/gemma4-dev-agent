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

echo "=================================================="
echo " GEMMA 4 DEVELOPER AGENT"
echo " M1 NODE2 QUALIFICATION"
echo "=================================================="

echo
echo "=== PLATFORM ==="

ARCH="$(uname -m)"

if [[ "$ARCH" == "aarch64" ]]; then
    pass "architecture = aarch64"
else
    fail "architecture expected aarch64; found $ARCH"
fi

if grep -Eq \
    'R36.*REVISION:[[:space:]]*4\.7' \
    /etc/nv_tegra_release
then
    pass "L4T R36.4.7"
else
    fail "expected L4T R36.4.7"
fi

JETPACK="$(
    dpkg-query -W \
      -f='${Version}' \
      nvidia-jetpack \
      2>/dev/null || true
)"

if [[ "$JETPACK" == 6.2.1* ]]; then
    pass "JetPack $JETPACK"
else
    fail "expected JetPack 6.2.1; found ${JETPACK:-missing}"
fi

echo
echo "=== TOOLS ==="

for cmd in \
    git \
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

echo
echo "=== SSH ==="

if systemctl is-active --quiet ssh; then
    pass "SSH daemon active"
else
    fail "SSH daemon inactive"
fi

if systemctl is-enabled --quiet ssh 2>/dev/null; then
    pass "SSH daemon enabled"
else
    warn "SSH daemon not enabled"
fi

if ss -ltn |
   grep -Eq '(:22[[:space:]])'
then
    pass "SSH port 22 listening"
else
    fail "SSH port 22 not listening"
fi

HOST_KEYS="$(
    find /etc/ssh \
      -maxdepth 1 \
      -type f \
      -name 'ssh_host_*_key.pub' \
      2>/dev/null |
      wc -l
)"

if (( HOST_KEYS > 0 )); then
    pass "SSH public host keys"
else
    fail "SSH public host keys missing"
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

if [[ "$DOCKER_ARCH" == "aarch64" ]]; then
    pass "Docker architecture = aarch64"
else
    fail "Docker architecture unexpected: $DOCKER_ARCH"
fi

if docker run --rm \
    ubuntu:22.04 \
    uname -m 2>/dev/null |
    grep -q '^aarch64$'
then
    pass "ARM64 container execution"
else
    fail "ARM64 container execution"
fi

echo
echo "=== CUDA ==="

ROOT="$(
    cd "$(dirname "${BASH_SOURCE[0]}")/../.." &&
    pwd
)"

if "$ROOT/scripts/preflight/check_cuda_node2.sh" \
    >/tmp/gemma4-m1-node2-cuda.log 2>&1
then
    pass "CUDA 12.6 / sm_87 runtime"
else
    cat /tmp/gemma4-m1-node2-cuda.log
    fail "CUDA 12.6 / sm_87 runtime"
fi

echo
echo "=== TELEMETRY ==="

if has_cmd tegrastats; then
    pass "tegrastats available"
else
    fail "tegrastats unavailable"
fi

echo
echo "--------------------------------------------------"
printf 'PASS=%d WARN=%d FAIL=%d\n' \
    "$PASS" "$WARN" "$FAIL"
echo "--------------------------------------------------"

if (( FAIL == 0 )); then
    echo "RESULT: NODE2 READY"
    exit 0
fi

echo "RESULT: NODE2 BLOCKED"
exit 1
