import json

# ===== 修改为你的文件路径 =====
INPUT_PATH  = "dataset_complete/new_cot_dataset/verilog_descriptions_2_cc_cot_cleanheader.json"
OUTPUT_PATH = "dataset_complete/new_cot_dataset/verilog_descriptions_2_cc_cot_copyinput.json"
# =================================

def main():
    with open(INPUT_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)

    if not isinstance(data, list):
        raise ValueError("JSON 顶层必须是数组格式 [ {...}, {...} ]")

    for sample in data:
        if "output" in sample:
            sample["input"] = sample["output"]

    with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"✅ 已处理 {len(data)} 条数据，结果保存到：{OUTPUT_PATH}")

if __name__ == "__main__":
    main()
