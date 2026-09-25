#!/usr/bin/env bash
set -euo pipefail

echo "=== HOST ==="
hostnamectl || true
uname -a
cat /etc/os-release

echo
echo "=== CPU ==="
lscpu

echo
echo "=== MEMORY ==="
free -h

echo
echo "=== STORAGE ==="
df -hT /
df -hT "$HOME"
lsblk

echo
echo "=== GPU ==="
nvidia-smi || true

echo
echo "=== CUDA ==="
which nvcc || true
nvcc --version || true
ls -l /usr/local/cuda* 2>/dev/null || true

echo
echo "=== PYTHON ==="
python3 --version
python3 -m pip --version || true

echo
echo "=== GIT ==="
git --version

echo
echo "=== DOCKER ==="
docker --version || true
docker info || true

echo
echo "=== BUILD TOOLS ==="
gcc --version | head -1 || true
g++ --version | head -1 || true
cmake --version | head -1 || true
ninja --version || true

echo
echo "=== NETWORK ==="
ip -brief addr

echo
echo "=== LIMITS ==="
ulimit -a

echo
echo "=== DISK FREE ==="
df -BG / "$HOME"

cat /etc/nv_tegra_release || true
dpkg-query --show nvidia-jetpack 2>/dev/null || true
#egrastats --interval 1000 --count 1 || true

timeout 5 tegrastats --interval 1000 || true
