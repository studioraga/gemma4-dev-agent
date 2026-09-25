#!/usr/bin/env bash
set -euo pipefail

echo "=== CGROUP ==="

CGROUP_FS="$(stat -fc %T /sys/fs/cgroup)"

echo "filesystem=$CGROUP_FS"

if [[ "$CGROUP_FS" != "cgroup2fs" ]]; then
    echo "CGROUP_V2=FAIL"
    exit 1
fi

echo "CGROUP_V2=PASS"

echo
echo "=== OVERLAY ==="

if grep -qw overlay /proc/filesystems; then
    echo "OVERLAY=PASS"
else
    echo "OVERLAY=FAIL"
    exit 1
fi

echo
echo "=== APPARMOR ==="

if command -v aa-enabled >/dev/null 2>&1 &&
   aa-enabled
then
    echo "APPARMOR=PASS"
else
    echo "APPARMOR=WARN"
fi

echo
echo "=== DOCKER SECURITY OPTIONS ==="

DOCKER_SECURITY="$(
    docker info \
      --format '{{json .SecurityOptions}}'
)"

echo "$DOCKER_SECURITY"

if grep -qi seccomp <<<"$DOCKER_SECURITY"; then
    echo "DOCKER_SECCOMP=PASS"
else
    echo "DOCKER_SECCOMP=FAIL"
    exit 1
fi

if grep -qi apparmor <<<"$DOCKER_SECURITY"; then
    echo "DOCKER_APPARMOR=PASS"
else
    echo "DOCKER_APPARMOR=WARN"
fi

echo
echo "CONTAINER_SECURITY=PASS"
