# -*- coding: utf-8 -*-
"""
统计多个数据集中 output 字段中：
- <think>...</think> 的思维链 token 数
- 剩余代码 token 数
- 总体 token 数
分词器与 token_count.py 一致（AutoTokenizer）。
"""

import json, re, os
from typing import List, Tuple
from transformers import AutoTokenizer

# ======= 配置区 =======
DATASETS = [
    "/home/tanhao/codegen/dataset_complete/train_dataset/formal_agent_dataset.json",  # 改为你的第一个数据集路径
    "/home/tanhao/codegen/dataset_complete/train_dataset/formal_agent_dataset5.json",  # 改为你的第二个数据集路径
]
# 你的本地分词器路径（与 token_count.py 相同）
TOKENIZER_PATH = "/home/tanhao/.cache/huggingface/hub/models--Qwen--Qwen3-0.6B/snapshots/e6de91484c29aa9480d55605af694f39b081c455"
# ======================

# 初始化分词器
print(f"Loading tokenizer from: {TOKENIZER_PATH}")
tokenizer = AutoTokenizer.from_pretrained(TOKENIZER_PATH, trust_remote_code=True)

def count_tokens(text: str) -> int:
    """计算字符串 token 数"""
    if not text or not isinstance(text, str):
        return 0
    return len(tokenizer.encode(text, add_special_tokens=False))

def split_think_and_code(output_text: str) -> Tuple[str, str]:
    """分离出 <think>...</think> 内容与剩余代码"""
    if not output_text or not isinstance(output_text, str):
        return "", ""
    pattern = re.compile(r"<\s*think\s*>(.*?)<\s*/\s*think\s*>", flags=re.IGNORECASE | re.DOTALL)
    think_contents = [m.group(1).strip() for m in pattern.finditer(output_text)]
    think_text = "\n".join(think_contents)
    # 去掉思维链部分
    remainder = pattern.sub("", output_text)
    # 去掉常见包裹符号
    remainder = re.sub(r"\[BEGIN\]|\[DONE\]|\[END\]", "", remainder, flags=re.IGNORECASE)
    remainder = re.sub(r"```[a-zA-Z0-9_+-]*", "", remainder)
    remainder = remainder.strip()
    return think_text, remainder

def load_json_dataset(path: str):
    """读取 JSON 或 JSONL 数据集"""
    data = []
    with open(path, "r", encoding="utf-8") as f:
        first = f.read(1)
        f.seek(0)
        if first == "[":
            data = json.load(f)
        else:
            for line in f:
                line = line.strip()
                if line:
                    data.append(json.loads(line))
    return data

# ========== 主逻辑 ==========
total_count = 0
think_token_sum = 0
code_token_sum = 0
total_token_sum = 0

for path in DATASETS:
    print(f"\nProcessing dataset: {path}")
    dataset = load_json_dataset(path)
    print(f"  Entries: {len(dataset)}")
    for sample in dataset:
        out = sample.get("output", "")
        think_text, code_text = split_think_and_code(out)
        think_token_sum += count_tokens(think_text)
        code_token_sum += count_tokens(code_text)
        total_token_sum += count_tokens(out)
    total_count += len(dataset)

# ===== 汇总输出 =====
print("\n=== Overall Statistics ===")
print(f"Total samples:          {total_count}")
print(f"Total think tokens:     {think_token_sum}")
print(f"Total code tokens:      {code_token_sum}")
print(f"Total output tokens:    {total_token_sum}")
if total_count > 0:
    print(f"Average think tokens:   {think_token_sum / total_count:.2f}")
    print(f"Average code tokens:    {code_token_sum / total_count:.2f}")
    print(f"Average output tokens:  {total_token_sum / total_count:.2f}")

# 也可保存结果到 JSON 文件
summary = {
    "total_samples": total_count,
    "think_tokens_sum": think_token_sum,
    "code_tokens_sum": code_token_sum,
    "output_tokens_sum": total_token_sum,
    "think_tokens_avg": think_token_sum / total_count if total_count else 0,
    "code_tokens_avg": code_token_sum / total_count if total_count else 0,
    "output_tokens_avg": total_token_sum / total_count if total_count else 0,
}
out_path = "dataset_token_summary.json"
with open(out_path, "w", encoding="utf-8") as f:
    json.dump(summary, f, ensure_ascii=False, indent=2)
print(f"\nSaved summary to {out_path}")
