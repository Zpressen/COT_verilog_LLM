import json
import re

# ===== 配置部分 =====
file1 = "/home/tanhao/codegen/dataset_complete/train_dataset/formal_agent_dataset.json"   # 第一个文件
file2 = "/home/tanhao/codegen/dataset_complete/train_dataset/formal_agent_dataset5.json"       # 第二个文件
output_file = "/home/tanhao/codegen/dataset_complete/train_dataset/no_cot_dataset.json"

# ===== 函数：清理 <think> 标签 =====
def clean_think(text: str) -> str:
    if not isinstance(text, str):
        return text
    # 删除 <think>...</think> 段落（含跨行）
    text = re.sub(r"<think>.*?</think>", "", text, flags=re.DOTALL | re.IGNORECASE)
    # 删除空白行
    return text.strip()

# ===== 读取两个数据集 =====
def load_json(file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        return json.load(f)

data1 = load_json(file1)
data2 = load_json(file2)

# ===== 清洗并合并 =====
merged = []
for dataset in [data1, data2]:
    for item in dataset:
        if "output" in item:
            item["output"] = clean_think(item["output"])
        merged.append(item)

# ===== 保存新文件 =====
with open(output_file, "w", encoding="utf-8") as f:
    json.dump(merged, f, ensure_ascii=False, indent=2)

print(f"✅ 已清理并合并数据，共 {len(merged)} 条，保存到 {output_file}")
