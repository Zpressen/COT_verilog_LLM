#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Transform dataset:
- 丢弃 total_tokens > 3500 的样本
- 映射字段：
    problem description -> instruction
    code                -> output
    input               -> "" (置空)
"""

import json
from pathlib import Path

# =====================
#  直接在这里修改路径
# =====================
INPUT_FILE = Path("data_new/verilog_descriptions_6_cc.json")          # 原始 JSON 文件
OUTPUT_FILE = Path("data_new/verilog_descriptions_6_cc_converted.json")   # 输出文件
MAX_TOKENS = 3500                           # 最大 token 限制


def get_total_tokens(item):
    """安全地获取 total_tokens。"""
    tu = item.get("token_usage") or {}
    tok = tu.get("total_tokens")
    if isinstance(tok, (int, float)):
        return int(tok)
    tok = item.get("total_tokens")
    if isinstance(tok, (int, float)):
        return int(tok)
    return None


def get_instruction(item):
    """兼容不同键名。"""
    return (
        item.get("problem description")
        or item.get("problem_description")
        or item.get("problem")
        or ""
    )


def transform():
    with INPUT_FILE.open("r", encoding="utf-8") as f:
        data = json.load(f)

    out = []
    dropped_by_tokens = 0
    dropped_incomplete = 0

    for obj in data:
        total_tokens = get_total_tokens(obj)
        if total_tokens is not None and total_tokens > MAX_TOKENS:
            dropped_by_tokens += 1
            continue

        instruction = get_instruction(obj)
        output = obj.get("code", "")

        if instruction == "" and output == "":
            dropped_incomplete += 1
            continue

        out.append(
            {
                "input": "",
                "instruction": instruction,
                "output": output,
            }
        )

    with OUTPUT_FILE.open("w", encoding="utf-8") as f:
        json.dump(out, f, ensure_ascii=False, indent=2)

    print(
        f"转换完成 ✅\n"
        f"保留样本数: {len(out)}\n"
        f"丢弃（token>3500）: {dropped_by_tokens}\n"
        f"丢弃（内容不完整）: {dropped_incomplete}\n"
        f"输出文件: {OUTPUT_FILE.resolve()}"
    )


if __name__ == "__main__":
    transform()
