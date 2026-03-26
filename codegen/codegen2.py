import json
import time
import threading
from concurrent.futures import ThreadPoolExecutor
from openai import OpenAI
import re

# 配置DeepSeek API
llm_config = {
    'model': "deepseek-chat",
    'api_key': "",
    'base_url': "https://api.deepseek.com/v1"
}

# COT Prompt from cot_prompt.doc
COT_Prompt = """You are an expert Verilog RTL designer skilled in chain-of-thought reasoning. Given a problem description and corresponding Verilog code, your task is to generate a natural, step-by-step chain-of-thought (CoT) reasoning trace that explains how you would design a solution to implement the described functionality. The CoT should mimic a hardware engineer's internal monologue, starting with a brief problem evaluation, extracting circuit information, decomposing into sub-tasks, reasoning through key design elements with a focus on state transitions (especially for FSMs), and concluding with integration and validation. Do not cross-reference or validate your reasoning against the provided Verilog code; focus on a purely independent design process as if you are designing from scratch. 

First, assess the problem difficulty based on the description and code to guide CoT length:

- Simple: Basic logic (e.g., combinational gates, simple counters) with few states or inputs – generate a concise CoT (<400 tokens).

- Medium: Moderate complexity (e.g., FSMs with 3-5 states, basic sequential logic) – generate a medium-length CoT (<800 tokens).

- Hard: High complexity (e.g., multi-stage pipelines, complex timing, error handling) – generate a detailed CoT (<1600 tokens).

For very simple problems, reason concisely. For medium and hard problems, follow these steps in your reasoning, weaving them naturally into a cohesive, concise narrative without redundancy:

1. Problem Overview: Briefly summarize the module's functionality and requirements in 1-2 sentences.

2. Circuit Information Extraction: Extract key circuit elements from the problem description, including signals with descriptions, state transition descriptions, and signal examples (e.g., input sequences or waveforms), formatted as:

signals: <signal1 name>: <signal1 description>, 

<signal2 name>: <signal2 description>, 

...,

    state_transitions: <current_state> (<output>) --<input_condition>--> <next_state>, ...

    signal_examples: <example1 text>, <example2 text>, ...

Ensure extractions are faithful to the description without adding or modifying content. For FSMs, prioritize detailed state transitions in bullet-point or table-like formats. For sequential logic, note clock edges and reset behaviors. 

3. Task Decomposition: Break the implementation into sub-tasks (e.g., define module interface, register states, implement state transitions, assign outputs). Focus on one signal or logic block per sub-task, extracting relevant context from the problem description and linking to the extracted circuit information (e.g., signals, transitions, examples), formatted as:

subtask_id: 1, content: <task description>;
subtask_id: 2, content: <task description>;
      ......;
4. Signal-Specific Reasoning: For each sub-task, reason through the design process, emphasizing state transitions for FSMs (e.g., using a state table or bullet-point transitions derived from the extracted circuit information) and adhering to hardware design rules (e.g., use `logic` for ports, `always @(*)` for combinational logic, no duplicate assignments). Base your design entirely on the problem description and extracted circuit information, imagining you are creating the solution from scratch. Use the extracted signals, transitions, and examples to enrich reasoning and avoid high-level overviews.
5. Module Integration: Describe how sub-task code integrates into the complete module, ensuring prior code is preserved and the implementation aligns with the problem requirements.
6. Validation and Debugging: Briefly reflect on potential issues (e.g., timing, reset behavior) and simulate a concise debugging process (e.g., waveform tracing for mismatches, backtracing signals using the extracted transitions). 

Problem Description: {problem_description}

Verilog Code: {code}

Ensure the CoT is natural, flowing like a designer's thought process, concise yet detailed, and avoids rigid headings or unnecessary repetition. The data you generate will be used by me for fine-tuning large models, ensuring the highest possible data quality. 

Output only the CoT in `<think> </think>` tags, with no additional explanations."""

def count_tokens(text):
    """近似计算token数，使用单词数作为估计"""
    words = text.split()
    return len(words)

def extract_description_and_code(item):
    """
    Extract problem_description (combining input and instruction) and code from the item.
    Input's description part (before module) is placed before instruction.
    Code is identified starting from the first 'module' keyword.
    """
    instruction = item.get('instruction', '')
    input_text = item.get('input', '')

    # Find the start of the module definition in input
    module_match = re.search(r'module\s+\w+', input_text, re.IGNORECASE | re.DOTALL)
    if module_match:
        desc_end = module_match.start()
        input_description = input_text[:desc_end].strip()
        code = input_text[desc_end:].strip()
    else:
        # Fallback: split at first non-comment line or approximate
        lines = input_text.split('\n')
        code_start = 0
        for i, line in enumerate(lines):
            if line.strip().startswith('module') or (not line.strip().startswith('//') and 'input' in line.lower()):
                code_start = i
                break
        input_description = '\n'.join(lines[:code_start]).strip()
        code = '\n'.join(lines[code_start:]).strip()

    # Combine input_description and instruction for problem_description (input first, then instruction)
    problem_description = input_description + '\n\n' + instruction if instruction else input_description

    return problem_description, code

def get_deepseek_response(problem_description, code, client):
    """调用DeepSeek API获取CoT响应"""
    question = COT_Prompt.format(problem_description=problem_description, code=code)
    conversation_history = [
        {"role": "system", "content": "You are an expert Verilog RTL designer."},
        {"role": "user", "content": question}
    ]

    try:
        response = client.chat.completions.create(
            model=llm_config['model'],
            messages=conversation_history,
            temperature=0.7,
            max_tokens=6000,  # Adjusted for CoT length
            stream=False
        )
        return response.choices[0].message.content
    except Exception as e:
        print(f"API调用错误: {str(e)}")
        return None

def process_single_item(item, index, total, results, lock, output_file):
    """处理单个数据集条目"""
    print(f"处理条目 {index + 1}/{total}")

    # 为每个线程创建独立的API客户端
    client = OpenAI(api_key=llm_config['api_key'], base_url=llm_config['base_url'])

    # 从 item 提取 problem_description（input description + instruction）和 code
    problem_description, code = extract_description_and_code(item)

    # 获取API响应
    response = get_deepseek_response(problem_description, code, client)

    if response:
        try:
            # 解析响应中的<think>和</think>
            if '<think>' in response and '</think>' in response:
                think_content = response.split('<think>')[1].split('</think>')[0].strip()
            else:
                think_content = response.strip()  # Fallback if tags missing

            # 计算 think 内容的 token 数（近似为单词数）
            token_count = count_tokens(think_content)
            print(f"条目 {index + 1} 的 think 输出 token 数: {token_count}")

            # 更新 item，添加 think 字段，保持原始 input 和 instruction 分开
            updated_item = item.copy()
            updated_item['think'] = think_content

            result = {
                "input": item,
                "output": updated_item  # Updated version with think added
            }
        except Exception as e:
            print(f"解析响应失败: {str(e)}")
            updated_item = item.copy()
            updated_item['think'] = f"响应解析失败: {str(e)}"
            token_count = count_tokens(updated_item['think'])
            print(f"条目 {index + 1} 的 think 输出 token 数: {token_count}")
            result = {
                "input": item,
                "output": updated_item
            }
    else:
        updated_item = item.copy()
        updated_item['think'] = "API调用失败"
        token_count = count_tokens(updated_item['think'])
        print(f"条目 {index + 1} 的 think 输出 token 数: {token_count}")
        result = {
            "input": item,
            "output": updated_item
        }

    # 使用锁保护共享资源
    with lock:
        results.append(result)
        # 保存进度：直接保存更新后的数组（仅 output 部分）
        updated_results = [r['output'] for r in results]  # Only save the updated items
        with open(output_file, 'w') as f:
            json.dump(updated_results, f, indent=2)

    print(f"条目 {index + 1} 处理完成")
    return result

def process_dataset(input_file, output_file, max_workers=5):
    """批量处理数据集（并行版）"""
    # 读取输入数据（JSON数组）
    with open(input_file, 'r', encoding='utf-8') as f:
        dataset = json.load(f)

    results = []
    lock = threading.Lock()
    total_items = len(dataset)

    # 使用线程池并行处理
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = []
        for i, item in enumerate(dataset):
            future = executor.submit(
                process_single_item,
                item, i, total_items,
                results, lock, output_file
            )
            futures.append(future)

        # 等待所有任务完成
        for future in futures:
            future.result()  # 可以处理异常或获取结果

    print(f"处理完成！结果已保存至 {output_file}")
    return [r['output'] for r in results]  # Return the updated dataset


# 使用示例
if __name__ == "__main__":
    input_json = "dataset_complete/full_removed8.json"  
    output_json = "dataset_complete/generated_cot_dataset8.json"

    # 设置并发工作线程数（根据API限制调整）
    process_dataset(input_json, output_json, max_workers=10)