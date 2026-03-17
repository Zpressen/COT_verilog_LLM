
# Total data entries: 28434
# Max tokens per entry: 139090
# Average tokens per entry: 2555.47


import json
import os
from transformers import AutoTokenizer

# 定义文件路径和模型路径
merged_file_path = '/home/tanhao/codegen/process_dataset/1n2_filter_clearinput_merged.json'
llm_model_path = '/home/tanhao/.cache/huggingface/hub/models--Qwen--Qwen3-0.6B/snapshots/e6de91484c29aa9480d55605af694f39b081c455'
filtered_file_path = '/home/tanhao/codegen/dataset_complete/train_dataset/formal_agent_dataset5.json'

try:
    # 尝试加载tokenizer
    # 注意：如果您的Qwen模型需要特定的trust_remote_code=True，请添加
    tokenizer = AutoTokenizer.from_pretrained(llm_model_path, trust_remote_code=True)
    print(f"Tokenizer loaded from {llm_model_path}")
except Exception as e:
    print(f"Error loading tokenizer from {llm_model_path}: {e}")
    print("Please ensure 'transformers' library is installed and the model path is correct.")
    print("You might need to install it: pip install transformers sentencepiece")
    print("If Qwen model requires specific dependencies, install them as well.")
    tokenizer = None # 如果加载失败，将tokenizer设为None

if not os.path.exists(merged_file_path):
    print(f"Error: Merged JSON file not found at {merged_file_path}")
else:
    try:
        with open(merged_file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)

        if not isinstance(data, list):
            print("Warning: The merged JSON file does not contain a list of objects. Processing as a single object.")
            data = [data]

        total_entries = len(data)
        token_counts = []
        filtered_data = []
        removed_entries_count = 0

        for i, entry in enumerate(data):
            text_to_tokenize = ""
            if 'input' in entry and isinstance(entry['input'], str):
                text_to_tokenize += entry['input'] + "\n"
            if 'instruction' in entry and isinstance(entry['instruction'], str):
                text_to_tokenize += entry['instruction'] + "\n"
            if 'output' in entry and isinstance(entry['output'], str):
                text_to_tokenize += entry['output'] + "\n"
            
            if tokenizer and text_to_tokenize:
                tokens = tokenizer.encode(text_to_tokenize, add_special_tokens=False)
                current_token_count = len(tokens)
                token_counts.append(current_token_count)

                if current_token_count <= 4096:
                    filtered_data.append(entry)
                else:
                    removed_entries_count += 1
            else:
                # 如果tokenizer未加载或没有文本，则跳过或记录
                # 这里选择跳过token计算，只统计条目数
                filtered_data.append(entry) # 如果无法计算token，则默认保留

        print(f"\nTotal data entries: {total_entries}")
        print(f"Entries removed (tokens > 4096): {removed_entries_count}")
        print(f"Entries kept: {len(filtered_data)}")

        if token_counts:
            max_tokens = max(token_counts)
            avg_tokens = sum(token_counts) / len(token_counts)
            print(f"Max tokens per entry: {max_tokens}")
            print(f"Average tokens per entry: {avg_tokens:.2f}")
        else:
            print("No token counts could be calculated (tokenizer not loaded or no valid text found).")

        # 将符合条件的数据写入新文件
        with open(filtered_file_path, 'w', encoding='utf-8') as f:
            json.dump(filtered_data, f, ensure_ascii=False, indent=4)
        print(f"Filtered data saved to {filtered_file_path}")

    except json.JSONDecodeError as e:
        print(f"Error decoding JSON from {merged_file_path}: {e}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")