#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
filter_code_by_length_json.py

规则：
- 仅处理 JSON（保持原结构：顶层数组 / 含 data/items 的字典 / 单条对象）。
- 以 output 的“空白分词”数量作为 token 近似计数。
- token < 100           -> 随机保留 30%，其余丢弃
- 100 <= token <= 300   -> 全部保留
- token > 300           -> 随机保留 50%，其余丢弃
- 输出：
  1) 过滤后数据（保持原结构）
  2) 被丢弃样本集合（JSON 数组）
- 控制台打印各区间保留/丢弃统计与总计。

如需更精确的 tokenizer，可把 token_count_simple 替换为你的 BPE/模型分词器。
"""

import json
import os
import random
import re
from typing import List, Dict, Any, Tuple, Optional

# ======== 修改这里：输入与输出路径（全部 JSON）========
INPUT_JSON_PATH       = "/home/tanhao/codegen/dataset_complete/new_cot_dataset/verilog_descriptions_1n2_copyinput.json"
OUTPUT_FILTERED_PATH  = "/home/tanhao/codegen/process_dataset/verilog_descriptions_1n2_filter.json"
OUTPUT_DROPPED_PATH   = "dataset_complete/train_dataset/formal_agent_dataset4_nouse.json"
# ======================================================

# 阈值与抽样比例
SHORT_MAX = 200          # 归为短
LONG_MIN  = 1500         # 归为长
KEEP_RATIO_SHORT = 0.20 # 短样本保留比例
KEEP_RATIO_LONG  = 0.90 # 长样本保留比例
RANDOM_SEED = 42

TOKEN_PATTERN = re.compile(r"\S+")

def token_count_simple(text: Optional[str]) -> int:
    return len(TOKEN_PATTERN.findall(text or ""))

def _extract_items_and_container(data: Any) -> Tuple[List[Dict[str, Any]], str]:
    """
    返回 (items, container_type)
    container_type: "list" 顶层数组; "dict:data" 顶层字典的 data 列表; "dict:items" 顶层字典的 items 列表; "single" 单条对象
    """
    if isinstance(data, list):
        return data, "list"
    if isinstance(data, dict):
        if isinstance(data.get("data"), list):
            return data["data"], "dict:data"
        if isinstance(data.get("items"), list):
            return data["items"], "dict:items"
        return [data], "single"
    raise ValueError("输入 JSON 必须是数组或字典。")

def _write_back_container(container_type: str, orig_data: Any, items: List[Dict[str, Any]]) -> Any:
    if container_type == "list":
        return items
    if container_type == "dict:data":
        orig_data["data"] = items
        return orig_data
    if container_type == "dict:items":
        orig_data["items"] = items
        return orig_data
    if container_type == "single":
        return items[0] if items else {}
    raise RuntimeError("未知 container_type")

def main():
    random.seed(RANDOM_SEED)

    with open(INPUT_JSON_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)

    items, container_type = _extract_items_and_container(data)

    short_pool: List[Dict[str, Any]] = []   # <100
    mid_pool:   List[Dict[str, Any]] = []   # 100..300
    long_pool:  List[Dict[str, Any]] = []   # >300

    # 分桶
    for obj in items:
        out_txt = obj.get("input", "")
        n_tok = token_count_simple(out_txt)
        if n_tok <= SHORT_MAX:
            short_pool.append(obj)
        elif n_tok >= LONG_MIN:
            long_pool.append(obj)
        else:
            mid_pool.append(obj)

    # 短样本：随机保留 30%
    k_short = int(round(len(short_pool) * KEEP_RATIO_SHORT))
    keep_idx_short = set(random.sample(range(len(short_pool)), k_short)) if short_pool else set()
    kept_short = [obj for i, obj in enumerate(short_pool) if i in keep_idx_short]
    dropped_short = [obj for i, obj in enumerate(short_pool) if i not in keep_idx_short]

    # 中样本：全部保留
    kept_mid = list(mid_pool)
    dropped_mid: List[Dict[str, Any]] = []

    # 长样本：随机保留 50%
    k_long = int(round(len(long_pool) * KEEP_RATIO_LONG))
    keep_idx_long = set(random.sample(range(len(long_pool)), k_long)) if long_pool else set()
    kept_long = [obj for i, obj in enumerate(long_pool) if i in keep_idx_long]
    dropped_long = [obj for i, obj in enumerate(long_pool) if i not in keep_idx_long]

    # 汇总
    kept_all = kept_short + kept_mid + kept_long
    dropped_all = dropped_short + dropped_mid + dropped_long

    # 写回保持原结构
    filtered_data = _write_back_container(container_type, data, kept_all)
    with open(OUTPUT_FILTERED_PATH, "w", encoding="utf-8") as f:
        json.dump(filtered_data, f, ensure_ascii=False, indent=2)

    # 丢弃样本单独保存为 JSON 数组
    with open(OUTPUT_DROPPED_PATH, "w", encoding="utf-8") as f:
        json.dump(dropped_all, f, ensure_ascii=False, indent=2)

    # 统计
    total = len(items)
    kept_count = len(kept_all)
    dropped_count = len(dropped_all)
    print("===== 统计信息（JSON 模式）=====")
    print(f"总样本数:                       {total}")
    print(f"短样本 (<100)    : 总 {len(short_pool)} | 保留 {len(kept_short)} | 丢弃 {len(dropped_short)}")
    print(f"中样本 (100..300): 总 {len(mid_pool)}   | 保留 {len(kept_mid)}   | 丢弃 {len(dropped_mid)}")
    print(f"长样本 (>300)    : 总 {len(long_pool)} | 保留 {len(kept_long)} | 丢弃 {len(dropped_long)}")
    print("--------------------------------")
    print(f"保留后总数:                     {kept_count}")
    print(f"丢弃总数:                       {dropped_count}")
    print(f"保留文件(JSON):                 {OUTPUT_FILTERED_PATH}")
    print(f"丢弃文件(JSON):                 {OUTPUT_DROPPED_PATH}")

if __name__ == "__main__":
    main()
