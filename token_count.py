#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
统计数据集中每条样本的 token 数分布（不做过滤/删除）。
- 与现有 check.py 的分词器与数据拼接方式保持一致：
  将 entry 的 'input'、'instruction'、'output' 三段文本（若存在且为 str）用换行拼接后再分词。
- 输出总体统计、分位数、分桶直方分布；
- 可选保存逐条 token 计数到 CSV，以及将统计结果保存为 JSON。
"""

import json
import os
import math
from statistics import mean, median, pstdev
from typing import List, Dict, Any, Tuple
from transformers import AutoTokenizer

# ====== 路径与配置 ======
merged_file_path = 'dataset_complete/train_dataset/formal_agent_dataset5.json'
llm_model_path   = '/home/tanhao/.cache/huggingface/hub/models--Qwen--Qwen3-0.6B/snapshots/e6de91484c29aa9480d55605af694f39b081c455'

# 是否导出结果文件
save_per_entry_csv = False
per_entry_csv_path = '/home/tanhao/data_process/dataset/token_counts_per_entry.csv'

save_summary_json  = False
summary_json_path  = '/home/tanhao/data_process/dataset/token_stats_summary.json'

# 直方分布的分桶边界（左闭右开），可自行调整
# 例如：0-128, 128-256, 256-512, 512-1k, 1k-2k, 2k-4k, 4k-8k, 8k-16k, 16k-32k, 32k-64k, 64k+
bins = [0,1024, 2048, 3072,4096, 5120, 6144, 8192, 16384, math.inf]

def safe_get_text(entry: Dict[str, Any]) -> str:
    """按既有逻辑拼接文本。  for key in ('input', 'instruction', 'output'): """
    parts = []
    for key in ('input', 'instruction', 'output'):
        v = entry.get(key)
        if isinstance(v, str) and v:
            parts.append(v)
    return "\n".join(parts)


def compute_percentile(sorted_vals: List[int], p: float) -> float:
    """
    计算 p 分位数（0-100），最近秩法的线性插值版本。
    """
    if not sorted_vals:
        return float('nan')
    if p <= 0:
        return float(sorted_vals[0])
    if p >= 100:
        return float(sorted_vals[-1])

    k = (len(sorted_vals) - 1) * (p / 100.0)
    f = math.floor(k)
    c = math.ceil(k)
    if f == c:
        return float(sorted_vals[int(k)])
    d0 = sorted_vals[f] * (c - k)
    d1 = sorted_vals[c] * (k - f)
    return float(d0 + d1)


def bucketize(values: List[int], edges: List[float]) -> List[int]:
    """按照给定分桶边界统计频数（左闭右开，最后一个桶右边界为 +inf）。"""
    counts = [0] * (len(edges) - 1)
    for v in values:
        # 二分查找也可以；这里数据量可接受，直接线性扫描足够清晰
        for i in range(len(edges) - 1):
            if edges[i] <= v < edges[i + 1]:
                counts[i] += 1
                break
    return counts


def format_bin_label(left: float, right: float) -> str:
    def fmt(x: float) -> str:
        if math.isinf(x):
            return "∞"
        return f"{int(x)}"
    lb = fmt(left)
    rb = fmt(right)
    if math.isinf(right):
        return f"[{lb}, +∞)"
    return f"[{lb}, {rb})"


def main():
    # 1) 加载 tokenizer
    try:
        tokenizer = AutoTokenizer.from_pretrained(llm_model_path, trust_remote_code=True)
        print(f"Tokenizer loaded from {llm_model_path}")
    except Exception as e:
        print(f"Error loading tokenizer from {llm_model_path}: {e}")
        print("请确认 transformers 及模型依赖已安装，或更换为可用的本地/在线模型路径。")
        return

    # 2) 读取数据
    if not os.path.exists(merged_file_path):
        print(f"Error: Merged JSON file not found at {merged_file_path}")
        return

    try:
        with open(merged_file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        if not isinstance(data, list):
            print("Warning: merged JSON 不是列表。将按单一对象处理为列表。")
            data = [data]
    except json.JSONDecodeError as e:
        print(f"JSON 解析错误: {e}")
        return

    total_entries = len(data)
    print(f"Total entries: {total_entries}")

    # 3) 逐条统计 token 数
    token_counts: List[int] = []
    for i, entry in enumerate(data):
        text = safe_get_text(entry)
        if not text:
            token_counts.append(0)
            continue
        try:
            # 与原脚本一致：不加特殊 token
            tokens = tokenizer.encode(text, add_special_tokens=False)
            token_counts.append(len(tokens))
        except Exception as e:
            print(f"[WARN] 第 {i} 条样本分词失败，记为 0。原因：{e}")
            token_counts.append(0)

        # 简单的进度提示
        if (i + 1) % 5000 == 0:
            print(f"Processed {i + 1}/{total_entries} entries...")

    if not token_counts:
        print("未得到有效 token 统计。")
        return

    # 4) 统计指标
    token_counts_sorted = sorted(token_counts)
    min_tokens = token_counts_sorted[0]
    max_tokens = token_counts_sorted[-1]
    avg_tokens = mean(token_counts_sorted)
    med_tokens = median(token_counts_sorted)
    std_tokens = pstdev(token_counts_sorted) if len(token_counts_sorted) > 1 else 0.0

    # 常用分位数
    pcts = [50, 75, 90, 95, 97, 98, 99, 99.5, 99.9]
    pct_values = {f"P{p}": compute_percentile(token_counts_sorted, p) for p in pcts}

    # 5) 分桶直方分布
    hist_counts = bucketize(token_counts_sorted, bins)
    bin_labels = [format_bin_label(bins[i], bins[i+1]) for i in range(len(bins)-1)]
    hist_pct = [c * 100.0 / total_entries for c in hist_counts]

    # 6) 打印结果
    print("\n===== Overall =====")
    print(f"Min tokens: {min_tokens}")
    print(f"Max tokens: {max_tokens}")
    print(f"Mean tokens: {avg_tokens:.2f}")
    print(f"Median tokens: {med_tokens:.2f}")
    print(f"Std tokens: {std_tokens:.2f}")

    print("\n===== Percentiles =====")
    for k in pct_values:
        print(f"{k}: {pct_values[k]:.2f}")

    print("\n===== Histogram (left-closed, right-open) =====")
    width = max(len(lbl) for lbl in bin_labels)
    for lbl, c, r in zip(bin_labels, hist_counts, hist_pct):
        print(f"{lbl:<{width}} : {c:>7d}  ({r:6.2f}%)")

    # 7) 可选导出
    if save_per_entry_csv:
        try:
            with open(per_entry_csv_path, 'w', encoding='utf-8') as f:
                f.write("index,token_count\n")
                for i, tc in enumerate(token_counts):
                    f.write(f"{i},{tc}\n")
            print(f"\nPer-entry token counts saved to: {per_entry_csv_path}")
        except Exception as e:
            print(f"[WARN] 保存 CSV 失败：{e}")

    if save_summary_json:
        summary = {
            "total_entries": total_entries,
            "min": int(min_tokens),
            "max": int(max_tokens),
            "mean": avg_tokens,
            "median": med_tokens,
            "std": std_tokens,
            "percentiles": pct_values,
            "histogram": [{"bin": lbl, "count": int(c), "ratio": r/100.0}
                          for lbl, c, r in zip(bin_labels, hist_counts, hist_pct)],
            "bins": bins
        }
        try:
            with open(summary_json_path, 'w', encoding='utf-8') as f:
                json.dump(summary, f, ensure_ascii=False, indent=2)
            print(f"Summary saved to: {summary_json_path}")
        except Exception as e:
            print(f"[WARN] 保存 JSON 失败：{e}")


if __name__ == "__main__":
    main()
