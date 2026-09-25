#!/usr/bin/env python3

from pathlib import Path

import torch
import torchvision

from transformers import (
    AutoConfig,
    AutoProcessor,
    AutoTokenizer,
)


META = Path("/tmp/gemma4-31b-metadata")


def main() -> int:
    print("Gemma 4 Developer Agent")
    print("M2.6 Locked Gemma 4 Metadata Gate")
    print("=" * 48)

    assert META.is_dir()

    cfg = AutoConfig.from_pretrained(
        META,
        local_files_only=True,
    )

    assert cfg.model_type == "gemma4"

    print("[PASS] Gemma4Config")

    tok = AutoTokenizer.from_pretrained(
        META,
        local_files_only=True,
    )

    encoded = tok(
        "Fix the failing Python unit test."
    )

    assert encoded["input_ids"]

    print("[PASS] Gemma tokenizer")

    rendered = tok.apply_chat_template(
        [
            {
                "role": "user",
                "content": (
                    "Fix the failing test and "
                    "explain the patch."
                ),
            }
        ],
        tokenize=False,
        add_generation_prompt=True,
    )

    assert rendered

    print("[PASS] chat template")

    processor = AutoProcessor.from_pretrained(
        META,
        local_files_only=True,
    )

    assert (
        type(processor).__name__
        == "Gemma4Processor"
    )

    print("[PASS] Gemma4Processor")

    assert torchvision.extension._has_ops()

    print("[PASS] torchvision native ops")

    assert torch.cuda.is_available()
    assert (
        torch.cuda.get_device_capability(0)
        == (12, 0)
    )

    print("[PASS] CUDA cc 12.0")

    weights = list(
        META.rglob("*.safetensors")
    )

    assert not weights

    print("[PASS] no model weights")

    print("RESULT=PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
