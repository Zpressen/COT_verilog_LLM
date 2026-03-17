import json

# 输入文件路径
input_file = "/home/tanhao/codegen/process_dataset/verilog_descriptions_1n2_filter.json"      # 你的原始 JSON 文件
output_file = "/home/tanhao/codegen/process_dataset/verilog_descriptions_1n2_filter_clearinput.json"  # 输出文件路径

# 读取 JSON 数据
with open(input_file, "r", encoding="utf-8") as f:
    data = json.load(f)

# 清空每个条目的 input 内容
for item in data:
    if "input" in item:
        item["input"] = ""

# 保存为新的 JSON 文件
with open(output_file, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=4)

print(f"处理完成，已保存为：{output_file}")
