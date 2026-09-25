#!/usr/bin/env python3

from __future__ import annotations

import sys

import torch
import triton
import triton.language as tl


@triton.jit
def add_kernel(
    x_ptr,
    y_ptr,
    out_ptr,
    n_elements: tl.constexpr,
    BLOCK_SIZE: tl.constexpr,
):
    pid = tl.program_id(axis=0)

    offsets = (
        pid * BLOCK_SIZE
        + tl.arange(0, BLOCK_SIZE)
    )

    mask = offsets < n_elements

    x = tl.load(
        x_ptr + offsets,
        mask=mask,
    )

    y = tl.load(
        y_ptr + offsets,
        mask=mask,
    )

    tl.store(
        out_ptr + offsets,
        x + y,
        mask=mask,
    )


def main() -> int:
    print("Gemma 4 Developer Agent")
    print("M2.5 Triton / sm_120 Qualification")
    print("=" * 56)

    print("python =", sys.version.split()[0])
    print("torch =", torch.__version__)
    print("triton =", triton.__version__)
    print(
        "device =",
        torch.cuda.get_device_name(0),
    )
    print(
        "capability =",
        torch.cuda.get_device_capability(0),
    )

    assert torch.cuda.is_available()
    assert (
        torch.cuda.get_device_capability(0)
        == (12, 0)
    )

    n = 1_000_003

    torch.manual_seed(1234)

    x = torch.randn(
        n,
        device="cuda",
        dtype=torch.float32,
    )

    y = torch.randn(
        n,
        device="cuda",
        dtype=torch.float32,
    )

    out = torch.empty_like(x)

    block = 256

    grid = (
        triton.cdiv(n, block),
    )

    add_kernel[grid](
        x,
        y,
        out,
        n,
        BLOCK_SIZE=block,
    )

    torch.cuda.synchronize()

    expected = x + y

    max_error = (
        out - expected
    ).abs().max().item()

    print(
        "max_error =",
        max_error,
    )

    assert torch.allclose(
        out,
        expected,
        rtol=1e-5,
        atol=1e-6,
    )

    print("TRITON_VECTOR_ADD=PASS")
    print("RESULT=PASS")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
