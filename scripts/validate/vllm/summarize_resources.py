#!/usr/bin/env python3

from __future__ import annotations

import argparse
from pathlib import Path


def parse_value(
    fields: list[str],
    name: str,
) -> int | None:
    prefix = name + "="

    for field in fields:
        if field.startswith(prefix):
            return int(
                field[len(prefix):]
            )

    return None


def main() -> int:
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "resource_log",
        type=Path,
    )

    args = parser.parse_args()

    path = args.resource_log

    if not path.is_file():
        print(
            f"RESOURCE_SUMMARY_ERROR="
            f"file_not_found:{path}"
        )
        return 2

    samples = 0

    peak_vram = None
    min_ram_available = None

    first_timestamp = None
    last_timestamp = None

    malformed = 0

    for raw in path.read_text().splitlines():
        line = raw.strip()

        if not line:
            continue

        fields = line.split()

        if not fields:
            continue

        timestamp = fields[0]

        ram_available = parse_value(
            fields,
            "ram_available",
        )

        vram_used = parse_value(
            fields,
            "vram_used_mib",
        )

        if (
            ram_available is None
            or vram_used is None
        ):
            malformed += 1
            continue

        samples += 1

        if first_timestamp is None:
            first_timestamp = timestamp

        last_timestamp = timestamp

        if (
            peak_vram is None
            or vram_used > peak_vram
        ):
            peak_vram = vram_used

        if (
            min_ram_available is None
            or ram_available
            < min_ram_available
        ):
            min_ram_available = (
                ram_available
            )

    print(
        f"resource_samples={samples}"
    )

    print(
        f"malformed_samples={malformed}"
    )

    print(
        f"first_timestamp="
        f"{first_timestamp}"
    )

    print(
        f"last_timestamp="
        f"{last_timestamp}"
    )

    if peak_vram is not None:
        print(
            f"peak_vram_used_mib="
            f"{peak_vram}"
        )

    if min_ram_available is not None:
        print(
            f"min_ram_available_bytes="
            f"{min_ram_available}"
        )

        gib = (
            min_ram_available
            / (1024 ** 3)
        )

        print(
            f"min_ram_available_gib="
            f"{gib:.3f}"
        )

    if samples == 0:
        print(
            "RESOURCE_SUMMARY=FAIL"
        )
        return 1

    print(
        "RESOURCE_SUMMARY=PASS"
    )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
