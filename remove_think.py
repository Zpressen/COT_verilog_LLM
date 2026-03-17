import json
import re

# 正则表达式模式，匹配<think>和</think>之间的内容（包括多行和变体）
pattern = re.compile(r'<think>[\s\S]*?<\s*/\s*think>', re.IGNORECASE)

def remove_think_tags(text):
    """删除文本中的<think>和</think>标签及其内容"""
    return pattern.sub('', text)

# 读取JSON文件
with open('dataset_complete/full8.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# 处理每个条目的output字段
for item in data:
    if 'output' in item:
        item['output'] = remove_think_tags(item['output'])

# 将处理后的数据写入新文件（或覆盖原文件）
with open('dataset_complete/full_removed8.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("处理完成！输出文件：full_processed.json")