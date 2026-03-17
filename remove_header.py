import json
import re

# ======================
# 🔧 在这里修改路径
# ======================
INPUT_PATH  = "dataset_complete/new_cot_dataset/verilog_descriptions_2_cc_cot.json"
OUTPUT_PATH = "dataset_complete/new_cot_dataset/verilog_descriptions_2_cc_cot_cleanheader.json"
# ======================

def remove_before_module(verilog_text: str) -> str:
    """去掉 module 之前的所有内容"""
    pattern = re.compile(r'(?<![\w$])module\b')
    match = pattern.search(verilog_text)
    if match:
        return verilog_text[match.start():].strip()
    return verilog_text.strip()

def clean_dataset():
    with open(INPUT_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)

    if isinstance(data, dict):  # 单条样本
        items = [data]
    else:
        items = data

    total, modified = 0, 0
    for item in items:
        total += 1
        if "output" in item and isinstance(item["output"], str):
            original = item["output"]
            cleaned = remove_before_module(original)
            if cleaned != original:
                modified += 1
                item["output"] = cleaned

    with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
        json.dump(items, f, ensure_ascii=False, indent=2)

    print(f"✅ 已处理 {total} 条数据，清理了 {modified} 条。")
    print(f"👉 输出文件已保存到：{OUTPUT_PATH}")

if __name__ == "__main__":
    clean_dataset()