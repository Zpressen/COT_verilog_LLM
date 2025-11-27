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
        "Rules:\n"
        "1. You may first think step by step inside <think>...</think>.\n"
        "2. The final answer MUST be ONLY Verilog code wrapped between [BEGIN] and [DONE].\n"
        "3. Do not add '```verilog' before the output code.\n"
        "4. Ensure the module name matches the testbench expectation and avoid extra top modules.\n"
    )

    user_msg = (
        "Below is an example of a clean, synthesizable Verilog RTL design that combines:\n"
        "- parameterized widths,\n"
        "- multiple clocks,\n"
        "- combinational logic with always @*,\n"
        "- sequential logic with posedge clk / negedge rst,\n"
        "- and a submodule instantiation.\n"
        "Study its coding style carefully. After the example, you must implement the NEW task "
        "using the SAME coding style:\n"
        "- exactly ONE top-level module for the required design;\n"
        "- pure Verilog-2001 style (wire/reg, always @*, always @(posedge clk or negedge rst));\n"
        "- no delays (#), no initial blocks, no interface/logic/always_ff;\n"
        "- no testbench code; only the RTL module(s) needed by the design;\n"
        "- final answer wrapped between [BEGIN] and [DONE] with ONLY Verilog code.\n\n"

        "==================== Example RTL Module (for style only) ====================\n"
        "Example: a small unit that performs a simple iterative operation and stores data\n"
        "through a dual-clock RAM-like submodule. This is NOT part of the benchmark.\n\n"

        "[BEGIN]\n"
        "module example_iter_fifo_style #(\n"
        "    parameter WIDTH     = 8,\n"
        "    parameter DEPTH     = 8,\n"
        "    parameter PTR_WIDTH = 3\n"
        ")(\n"
        "    input  wire                   wclk,\n"
        "    input  wire                   rclk,\n"
        "    input  wire                   rst_n,\n"
        "    // control for an iterative operation (similar to a small divider)\n"
        "    input  wire                   start,\n"
        "    input  wire                   sign,\n"
        "    input  wire [WIDTH-1:0]       dividend,\n"
        "    input  wire [WIDTH-1:0]       divisor,\n"
        "    // simple FIFO-like write/read enables\n"
        "    input  wire                   w_en,\n"
        "    input  wire                   r_en,\n"
        "    // outputs\n"
        "    output reg                    res_valid,\n"
        "    output reg  [2*WIDTH-1:0]     result,\n"
        "    output reg  [WIDTH-1:0]       rdata\n"
        ");\n\n"
        "    // internal registers\n"
        "    reg [WIDTH-1:0]      divd_reg;\n"
        "    reg [WIDTH-1:0]      divs_reg;\n"
        "    reg [2*WIDTH-1:0]    sr;\n"
        "    reg [3:0]            cnt;\n"
        "    reg                  busy;\n\n"
        "    // simple write/read pointers (binary only for example)\n"
        "    reg [PTR_WIDTH-1:0]  wptr;\n"
        "    reg [PTR_WIDTH-1:0]  rptr;\n\n"
        "    wire                  ram_wen;\n"
        "    wire                  ram_ren;\n"
        "    wire [WIDTH-1:0]      ram_rdata;\n\n"
        "    assign ram_wen = w_en && !busy;\n"
        "    assign ram_ren = r_en;\n\n"
        "    // instantiate a small dual-clock RAM-like submodule\n"
        "    example_dual_clock_ram #(\n"
        "        .WIDTH (WIDTH),\n"
        "        .DEPTH (DEPTH)\n"
        "    ) u_ram (\n"
        "        .wclk  (wclk),\n"
        "        .rclk  (rclk),\n"
        "        .rst_n (rst_n),\n"
        "        .wen   (ram_wen),\n"
        "        .waddr (wptr),\n"
        "        .wdata (dividend),\n"
        "        .ren   (ram_ren),\n"
        "        .raddr (rptr),\n"
        "        .rdata (ram_rdata)\n"
        "    );\n\n"
        "    // combinational block to form next shift-register value (similar to radix-2 step)\n"
        "    reg [2*WIDTH-1:0] sr_next;\n"
        "    always @* begin\n"
        "        sr_next = sr;\n"
        "        if (busy) begin\n"
        "            // simple left shift and subtract example (no full algorithm here)\n"
        "            sr_next = {sr[2*WIDTH-2:0], 1'b0};\n"
        "            if (sr[2*WIDTH-1:WIDTH] >= divs_reg) begin\n"
        "                sr_next[2*WIDTH-1:WIDTH] = sr[2*WIDTH-1:WIDTH] - divs_reg;\n"
        "                sr_next[0]               = 1'b1;\n"
        "            end\n"
        "        end\n"
        "    end\n\n"
        "    // main sequential logic: state, counters, result valid\n"
        "    always @(posedge wclk or negedge rst_n) begin\n"
        "        if (!rst_n) begin\n"
        "            divd_reg  <= {WIDTH{1'b0}};\n"
        "            divs_reg  <= {WIDTH{1'b0}};\n"
        "            sr        <= {2*WIDTH{1'b0}};\n"
        "            cnt       <= 4'd0;\n"
        "            busy      <= 1'b0;\n"
        "            res_valid <= 1'b0;\n"
        "            result    <= {2*WIDTH{1'b0}};\n"
        "            wptr      <= {PTR_WIDTH{1'b0}};\n"
        "        end else begin\n"
        "            res_valid <= 1'b0;\n"
        "            if (start && !busy) begin\n"
        "                // latch inputs and start an iterative process\n"
        "                divd_reg <= dividend;\n"
        "                divs_reg <= divisor;\n"
        "                sr       <= {{WIDTH{1'b0}}, dividend};\n"
        "                cnt      <= 4'd0;\n"
        "                busy     <= 1'b1;\n"
        "            end else if (busy) begin\n"
        "                sr  <= sr_next;\n"
        "                cnt <= cnt + 1'b1;\n"
        "                if (cnt == (WIDTH-1)) begin\n"
        "                    busy      <= 1'b0;\n"
        "                    res_valid <= 1'b1;\n"
        "                    result    <= sr_next;\n"
        "                end\n"
        "            end\n"
        "            // simple write pointer update\n"
        "            if (ram_wen) begin\n"
        "                wptr <= wptr + 1'b1;\n"
        "            end\n"
        "        end\n"
        "    end\n\n"
        "    // read pointer and data capture on read clock\n"
        "    always @(posedge rclk or negedge rst_n) begin\n"
        "        if (!rst_n) begin\n"
        "            rptr  <= {PTR_WIDTH{1'b0}};\n"
        "            rdata <= {WIDTH{1'b0}};\n"
        "        end else begin\n"
        "            if (ram_ren) begin\n"
        "                rdata <= ram_rdata;\n"
        "                rptr  <= rptr + 1'b1;\n"
        "            end\n"
        "        end\n"
        "    end\n\n"
        "endmodule\n\n"
        "// Simple dual-clock RAM example submodule (for style only)\n"
        "module example_dual_clock_ram #(\n"
        "    parameter WIDTH = 8,\n"
        "    parameter DEPTH = 8\n"
        ")(\n"
        "    input  wire                 wclk,\n"
        "    input  wire                 rclk,\n"
        "    input  wire                 rst_n,\n"
        "    input  wire                 wen,\n"
        "    input  wire [$clog2(DEPTH)-1:0] waddr,\n"
        "    input  wire [WIDTH-1:0]     wdata,\n"
        "    input  wire                 ren,\n"
        "    input  wire [$clog2(DEPTH)-1:0] raddr,\n"
        "    output reg  [WIDTH-1:0]     rdata\n"
        ");\n\n"
        "    reg [WIDTH-1:0] mem [0:DEPTH-1];\n\n"
        "    // write port\n"
        "    always @(posedge wclk or negedge rst_n) begin\n"
        "        if (!rst_n) begin\n"
        "            // no special init\n"
        "        end else if (wen) begin\n"
        "            mem[waddr] <= wdata;\n"
        "        end\n"
        "    end\n\n"
        "    // read port\n"
        "    always @(posedge rclk or negedge rst_n) begin\n"
        "        if (!rst_n) begin\n"
        "            rdata <= {WIDTH{1'b0}};\n"
        "        end else if (ren) begin\n"
        "            rdata <= mem[raddr];\n"
        "        end\n"
        "    end\n\n"
        "endmodule\n"
        "[DONE]\n\n"

        "==================== New Task (You must solve) ====================\n"
        "Design specification:\n"
        "--------------------\n"
        f"{spec}\n"
        "--------------------\n"
        "Now provide the Verilog implementation for this NEW design, following the SAME style as the example:\n"
        "- exactly ONE required top-level module (plus any small submodules if the spec explicitly asks);\n"
        "- pure synthesizable Verilog-2001 (wire/reg, always @*, always @(posedge clk or negedge rst));\n"
        "- no delays (#), no initial blocks, no testbench code;\n"
        "- final answer MUST be ONLY Verilog code wrapped between [BEGIN] and [DONE]."
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

    # llm = ChatOpenAI(
    #     model=model,
    #     temperature=temperature,
    #     top_p=top_p,
    #     max_tokens=25000,
    #     openai_api_base="https://dashscope.aliyuncs.com/compatible-mode/v1",
    #     openai_api_key="sk-f77691082dbd41c4b3db7137991c041d",
    #     extra_body={"enable_thinking": True}
    # )
    llm = ChatOpenAI(
        model=model,
        temperature=temperature,
        top_p=top_p,
        max_tokens=25000,
        openai_api_base="http://0.0.0.0:8005/v1",
        openai_api_key="no",
    )

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
    parser.add_argument("--out_dir", type=str, default="_qwen3-100m-5",
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
