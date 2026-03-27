import os
import re
import argparse
from typing import List, Optional

try:
    # 优先使用新版 langchain_openai
    from langchain_openai import ChatOpenAI
except ImportError:
    from langchain.chat_models import ChatOpenAI


# ================= 配置 =================

RTLLM_ROOT = os.path.dirname(os.path.abspath(__file__))

# RTLLM v1.1 使用的 30 个设计任务（与 auto_run_iverilog.py 一致）
DESIGN_LIST = [
    "accu",
    "adder_8bit", "adder_16bit", "adder_32bit", "adder_pipe_64bit",
    "asyn_fifo",
    "calendar",
    "counter_12",
    "edge_detect",
    "freq_div",
    "fsm",
    "JC_counter",
    "multi_16bit", "multi_booth_8bit", "multi_pipe_4bit", "multi_pipe_8bit",
    "parallel2serial",
    "pe",
    "pulse_detect",
    "radix2_div",
    "RAM",
    "right_shifter",
    "serial2parallel",
    "signal_generator",
    "synchronizer",
    "alu",
    "div_16bit",
    "traffic_light",
    "width_8to16",
]


# ================= 工具函数 =================

def find_design_dir(design: str) -> Optional[str]:
    """
    RTLLM v1.1: 每个设计目录就在仓库根目录下:
        RTLLM_ROOT/<design>/
    目录中包含 design_description.txt。
    """
    ddir = os.path.join(RTLLM_ROOT, design)
    spec_path = os.path.join(ddir, "design_description.txt")
    if os.path.isdir(ddir) and os.path.exists(spec_path):
        return ddir
    return None


def load_spec(design: str) -> Optional[str]:
    ddir = find_design_dir(design)
    if not ddir:
        return None
    spec_path = os.path.join(ddir, "design_description.txt")
    with open(spec_path, "r", encoding="utf-8") as f:
        return f.read()


def strip_think_blocks(text: str) -> str:
    """移除 <think>...</think> 中的内容（支持多段）。"""
    return re.sub(r"<think>.*?</think>", "", text, flags=re.DOTALL | re.IGNORECASE)


def extract_between_begin_done(text: str) -> Optional[str]:
    """从 [BEGIN] ... [DONE] 中提取代码块，取第一段。"""
    m = re.search(r"\[BEGIN\](.*?)(?:\[DONE\]|$)", text, flags=re.DOTALL | re.IGNORECASE)
    if m:
        return m.group(1)
    return None


def extract_code_fallback(text: str) -> str:
    """
    当没有 [BEGIN]/[DONE] 时的降级策略：
    1. 优先取 ```verilog ``` 或 ``` ``` 代码块；
    2. 否则返回全文。
    """
    m = re.search(r"```verilog(.*?)(```|$)", text, flags=re.DOTALL | re.IGNORECASE)
    if m:
        return m.group(1)

    m = re.search(r"```(.*?)(```|$)", text, flags=re.DOTALL)
    if m:
        return m.group(1)

    return text


def sanitize_verilog(text: str) -> str:
    """
    清洗得到最终 Verilog：
    - 去掉 CoT (<think> 块)
    - 提取 [BEGIN]/[DONE]
    - 去掉多余空白
    """
    if not text:
        return ""

    text = strip_think_blocks(text)

    code = extract_between_begin_done(text)
    if code is None:
        code = extract_code_fallback(text)

    code = code.strip()
    code = re.sub(r"\[BEGIN\]", "", code, flags=re.IGNORECASE)
    code = re.sub(r"\[DONE\]", "", code, flags=re.IGNORECASE)

    return code.strip() + "\n"


def build_prompt(spec: str, design: str) -> List[dict]:
    """
    构造对话消息：
    - 允许在 <think> 里思考
    - 最终 Verilog 必须放在 [BEGIN] 和 [DONE] 之间
    """
    system_msg = (
        "You are an expert RTL/Verilog designer. "
        f"Given a design specification, you must output a single synthesizable Verilog module "
        f"that correctly implements the described behavior for design `{design}`.\n"
    )

    user_msg = (
        "Design specification:\n"
        "--------------------\n"
        f"{spec}\n"
        "--------------------\n"
        "Now provide the Verilog implementation as required."
    )

    return [
        {"role": "system", "content": system_msg},
        {"role": "user", "content": user_msg},
    ]


# ================= 生成主逻辑 =================

def generate_for_designs(
    model: str,
    temperature: float,
    top_p: float,
    samples: int,
    out_dir_name: str,
):
    """
    v1.1 版：
    - 从 RTLLM_ROOT/<design>/design_description.txt 读取描述；
    - 调用本地 ChatOpenAI 兼容模型生成 Verilog；
    - 解析 CoT + [BEGIN]/[DONE]；
    - 保存到 <out_dir_name>/tX/<design>.v （例如 dp-8b-100m-0/t1/adder_8bit.v）。
    """
    out_root = os.path.join(RTLLM_ROOT, out_dir_name)
    os.makedirs(out_root, exist_ok=True)

    llm = ChatOpenAI(
        model=model,
        temperature=temperature,
        top_p=top_p,
        max_tokens=15000,
        openai_api_base="https://dashscope.aliyuncs.com/compatible-mode/v1",
        openai_api_key="",
        extra_body={"enable_thinking": True}
    )
    # llm = ChatOpenAI(
    #     model=model,
    #     temperature=temperature,
    #     top_p=top_p,
    #     max_tokens=25000,
    #     openai_api_base="http://0.0.0.0:8005/v1",
    #     openai_api_key="no",
    # )

    # 预读所有 spec
    design_specs = {}
    for d in DESIGN_LIST:
        spec = load_spec(d)
        if spec is None:
            print(f"[WARN] {d}: design_description.txt not found, skip.")
        else:
            design_specs[d] = spec

    if not design_specs:
        print("[FATAL] No design_description.txt found for any design.")
        return

    print(f"[INFO] Found {len(design_specs)} designs with specs.")
    print(f"[INFO] Generating {samples} sample(s) per design into {out_root}/tX/...")

    for sample_idx in range(1, samples + 1):
        t_dir = os.path.join(out_root, f"t{sample_idx}")
        os.makedirs(t_dir, exist_ok=True)
        print(f"\n[INFO] === Generating round t{sample_idx} ===")

        for design, spec in design_specs.items():
            out_path = os.path.join(t_dir, f"{design}.v")

            # 已存在则跳过，避免覆盖
            if os.path.exists(out_path):
                print(f"[SKIP] {out_path} already exists.")
                continue

            messages = build_prompt(spec, design)

            try:
                # === 生成模型输出（流式方式，支持 enable_thinking） ===
                raw_chunks = []

                try:
                    stream = llm.stream(
                        messages,
                        extra_body={"enable_thinking": True}   # ⭐ 必须放这里
                    )

                    for chunk in stream:
                        # chunk.content 是当前 token 片段
                        if hasattr(chunk, "content") and chunk.content:
                            raw_chunks.append(chunk.content)

                except Exception as e:
                    print(f"[ERR] LLM stream failed for {design} (t{sample_idx}): {e}")
                    continue

                # 拼接整个输出
                raw_text = "".join(raw_chunks)

            except Exception as e:
                print(f"[ERR] LLM call failed for {design} (t{sample_idx}): {e}")
                continue

            verilog_code = sanitize_verilog(raw_text)

            if not verilog_code.strip():
                print(f"[WARN] Empty code for {design} (t{sample_idx}), skip.")
                continue

            with open(out_path, "w", encoding="utf-8") as f:
                f.write(verilog_code)

            print(f"[OK] {design} -> {out_path}")


# ================= CLI =================

def main():
    parser = argparse.ArgumentParser(
        description="Generate Verilog for RTLLM v1.1 using local ChatOpenAI-compatible model."
    )
    parser.add_argument("--model", type=str, default="qwen3-32b", help="Model name for ChatOpenAI")
    parser.add_argument("--temperature", type=float, default=0.8)
    parser.add_argument("--top_p", type=float, default=0.9)
    parser.add_argument("--samples", type=int, default=5,
                        help="Number of samples per design (t1..tN)")
    parser.add_argument("--out_dir", type=str, default="_dp-8b-1",
                        help="Output parent directory name (will contain t1/t2/...)")
    args = parser.parse_args()

    generate_for_designs(
        model=args.model,
        temperature=args.temperature,
        top_p=args.top_p,
        samples=args.samples,
        out_dir_name=args.out_dir,
    )


if __name__ == "__main__":
    main()
