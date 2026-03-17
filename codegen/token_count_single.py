#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
统计数据集中单一字段（'input'、'instruction' 或 'output'）的 token 数分布。
"""

import json
import os
import math
from statistics import mean, median, pstdev
from transformers import AutoTokenizer

# ====== 配置 ======
merged_file_path = '/home/tanhao/codegen/process_dataset/verilog_descriptions_1n2_filter.json'
llm_model_path   = '/home/tanhao/.cache/huggingface/hub/models--Qwen--Qwen3-0.6B/snapshots/e6de91484c29aa9480d55605af694f39b081c455'

# 选择要统计的字段，可改为 'input'、'instruction' 或 'output'
target_field = 'input'

bins = [0,50, 100, 200,300, 400, 500, 800, math.inf]


def compute_percentile(sorted_vals, p):
    if not sorted_vals:
        return float('nan')
    if p <= 0:
        return float(sorted_vals[0])
    if p >= 100:
        return float(sorted_vals[-1])
    k = (len(sorted_vals) - 1) * (p / 100.0)
    f, c = math.floor(k), math.ceil(k)
    if f == c:
        return float(sorted_vals[int(k)])
    d0 = sorted_vals[f] * (c - k)
    d1 = sorted_vals[c] * (k - f)
    return float(d0 + d1)


def bucketize(values, edges):
    counts = [0] * (len(edges) - 1)
    for v in values:
        for i in range(len(edges) - 1):
            if edges[i] <= v < edges[i + 1]:
                counts[i] += 1
                break
    return counts


def format_bin_label(left, right):
    def fmt(x):
        return "∞" if math.isinf(x) else f"{int(x)}"
    return f"[{fmt(left)}, +∞)" if math.isinf(right) else f"[{fmt(left)}, {fmt(right)})"


def main():
    try:
        tokenizer = AutoTokenizer.from_pretrained(llm_model_path, trust_remote_code=True)
        print(f"Tokenizer loaded from {llm_model_path}")
    except Exception as e:
        print(f"Error loading tokenizer: {e}")
        return

    if not os.path.exists(merged_file_path):
        print(f"Error: file not found at {merged_file_path}")
        return

    with open(merged_file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    if not isinstance(data, list):
        data = [data]

    print(f"Total entries: {len(data)}")

    token_counts = []
    for i, entry in enumerate(data):
        text = entry.get(target_field, "")
        if not isinstance(text, str):
            text = ""
        try:
            tokens = tokenizer.encode(text, add_special_tokens=False)
            token_counts.append(len(tokens))
        except Exception as e:
            print(f"[WARN] Entry {i} failed: {e}")
            token_counts.append(0)

    token_counts_sorted = sorted(token_counts)
    total = len(token_counts_sorted)
    print("\n===== Overall =====")
    print(f"Min: {token_counts_sorted[0]}")
    print(f"Max: {token_counts_sorted[-1]}")
    print(f"Mean: {mean(token_counts_sorted):.2f}")
    print(f"Median: {median(token_counts_sorted):.2f}")
    print(f"Std: {pstdev(token_counts_sorted) if total > 1 else 0.0:.2f}")

    print("\n===== Percentiles =====")
    for p in [50, 75, 90, 95, 99]:
        print(f"P{p}: {compute_percentile(token_counts_sorted, p):.2f}")

    print("\n===== Histogram =====")
    hist = bucketize(token_counts_sorted, bins)
    labels = [format_bin_label(bins[i], bins[i+1]) for i in range(len(bins)-1)]
    for lbl, c in zip(labels, hist):
        print(f"{lbl:<12} : {c:>7d}  ({c*100/total:6.2f}%)")


if __name__ == "__main__":
    main()
