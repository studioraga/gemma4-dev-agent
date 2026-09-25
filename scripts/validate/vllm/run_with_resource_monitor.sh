#!/usr/bin/env bash

set -uo pipefail

if [[ $# -lt 3 ]]; then
    echo \
      "usage: $0 <resource-log> <run-log> <command...>" \
      >&2
    exit 2
fi

RESOURCE_LOG="$1"
RUN_LOG="$2"

shift 2

MON_PID=""

cleanup_monitor() {
    if [[ -n "${MON_PID}" ]]; then
        kill "${MON_PID}" \
          2>/dev/null \
          || true

        wait "${MON_PID}" \
          2>/dev/null \
          || true

        MON_PID=""
    fi
}

trap cleanup_monitor EXIT INT TERM

./scripts/validate/vllm/monitor_resources.sh \
  > "${RESOURCE_LOG}" \
  2>&1 &

MON_PID=$!

sleep 2

set +e

"$@" \
  2>&1 \
  | tee "${RUN_LOG}"

RUN_RC=${PIPESTATUS[0]}

set -e

cleanup_monitor

echo
echo "RUN_RC=${RUN_RC}"

echo
echo "=== RESOURCE SUMMARY ==="

SUMMARY_RC=0

/tmp/gemma4-m27-vllm-candidate/bin/python \
  scripts/validate/vllm/summarize_resources.py \
  "${RESOURCE_LOG}" \
  || SUMMARY_RC=$?

echo "RESOURCE_SUMMARY_RC=${SUMMARY_RC}"

if [[ "${RUN_RC}" -ne 0 ]]; then
    exit "${RUN_RC}"
fi

if [[ "${SUMMARY_RC}" -ne 0 ]]; then
    exit "${SUMMARY_RC}"
fi

exit 0
