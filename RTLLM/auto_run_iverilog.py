import os
import tqdm
import subprocess
from scipy.special import comb

# ================= 配置 =================

RTLLM_ROOT = os.path.dirname(os.path.abspath(__file__))

# 修改为你的生成目录，例如 dp-8b-100m-0
GEN_ROOT = os.path.join(RTLLM_ROOT, "_qwen3-100m-5")

PASS_K_CONFIG = 5   # v1.1 只算 pass@1

# v1.1 官方使用的 29 条任务
DESIGN_LIST = [
    'accu',
    'adder_8bit', 'adder_16bit', 'adder_32bit', 'adder_pipe_64bit',
    'asyn_fifo',
    'calendar',
    'counter_12',
    'edge_detect',
    'freq_div',
    'fsm',
    'JC_counter',
    'multi_16bit', 'multi_booth_8bit', 'multi_pipe_4bit', 'multi_pipe_8bit',
    'parallel2serial',
    'pe',
    'pulse_detect',
    'radix2_div',
    'RAM',
    'right_shifter',
    'serial2parallel',
    'signal_generator',
    'synchronizer',
    'alu',
    'div_16bit',
    'traffic_light',
    'width_8to16'
]


# =============== v1.1 目录结构：设计目录就在 RTLLM_ROOT 下 ===============

def find_design_dir(design):
    """RTLLM v1.1: 设计目录是 RTLLM_ROOT/<design>"""
    design_dir = os.path.join(RTLLM_ROOT, design)
    tb = os.path.join(design_dir, "testbench.v")
    if os.path.isdir(design_dir) and os.path.exists(tb):
        return design_dir
    return None


DESIGN_DIR_MAP = {d: find_design_dir(d) for d in DESIGN_LIST}


# =============== 工具函数 =================

def run_cmd(cmd_list, timeout=8):
    try:
        cp = subprocess.run(
            cmd_list,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            timeout=timeout,
            text=True
        )
        return (1 if cp.returncode == 0 else 0), (cp.stdout or "")
    except subprocess.TimeoutExpired as e:
        return 0, e.stdout or ""


def cal_atk(dic_list, n, k):
    if n == 0:
        return 0.0, 0.0
    k = min(k, n)

    def pass_at_k(key):
        vals = []
        for d in dic_list.keys():
            c = dic_list[d][key]
            if c < 0 or c > n:
                vals.append(0.0)
            else:
                vals.append(1 - comb(n - c, k) / comb(n, k))
        return sum(vals) / len(vals)

    return pass_at_k('syntax_success'), pass_at_k('func_success')


def build_result_dict():
    return {d: {"syntax_success": 0, "func_success": 0} for d in DESIGN_LIST}


def collect_test_dirs():
    dirs = []
    for i in range(1, PASS_K_CONFIG + 1):
        d = os.path.join(GEN_ROOT, f"t{i}")
        if os.path.isdir(d):
            dirs.append(f"t{i}")
        else:
            break
    return dirs


# =============== 核心测试逻辑 =================

def test_one_batch(t_dir_name, result_dic, progress_bar):
    t_dir = os.path.join(GEN_ROOT, t_dir_name)

    for design in DESIGN_LIST:
        design_dir = DESIGN_DIR_MAP.get(design)
        if design_dir is None:
            progress_bar.update(1)
            continue

        tb_path = os.path.join(design_dir, "testbench.v")
        gen_v = os.path.join(t_dir, f"{design}.v")

        if not (os.path.exists(tb_path) and os.path.exists(gen_v)):
            progress_bar.update(1)
            continue

        os.chdir(design_dir)

        # 编译
        ok_compile, out_compile = run_cmd(
            ["iverilog", "-g2012", "-o", "simv", "testbench.v", gen_v],
            timeout=15
        )

        if ok_compile and os.path.exists("simv"):
            result_dic[design]["syntax_success"] += 1

            ok_sim, out_sim = run_cmd(["vvp", "simv"], timeout=15)

            with open("output.txt", "w") as f:
                f.write(out_sim)

            if ok_sim and ("Pass" in out_sim or "pass" in out_sim):
                result_dic[design]["func_success"] += 1

        if os.path.exists("simv"):
            os.remove("simv")

        os.chdir(RTLLM_ROOT)
        progress_bar.update(1)

    return result_dic


# =============== 写结果 =================

def save_results_to_txt(result_dic, n, test_dirs, pass_k_used):
    out_path = os.path.join(GEN_ROOT, "rtllm_iverilog_result.txt")

    syntax_p, func_p = cal_atk(result_dic, n, pass_k_used)

    total_syntax = sum(1 for d in DESIGN_LIST if result_dic[d]['syntax_success'] > 0)
    total_func   = sum(1 for d in DESIGN_LIST if result_dic[d]['func_success'] > 0)

    with open(out_path, "w") as f:
        f.write("RTLLM v1.1 Icarus Verilog Evaluation Result\n")
        f.write(f"Test dirs: {test_dirs}\n")
        f.write(f"Samples(n): {n}\n")
        f.write(f"pass@k: {pass_k_used}\n\n")

        for d in DESIGN_LIST:
            f.write(f"{d}: syntax={result_dic[d]['syntax_success']}, "
                    f"func={result_dic[d]['func_success']}\n")

        f.write("\n=== Summary ===\n")
        f.write(f"syntax pass@{pass_k_used}: {syntax_p:.6f}\n")
        f.write(f"func   pass@{pass_k_used}: {func_p:.6f}\n")
        f.write(f"syntax success: {total_syntax}/{len(DESIGN_LIST)}\n")
        f.write(f"func   success: {total_func}/{len(DESIGN_LIST)}\n")

    print(f"\n结果已保存到: {out_path}")


# =============== 主函数 =================

def main():
    test_dirs = collect_test_dirs()
    if not test_dirs:
        print("没有找到 t1，请检查生成目录 GEN_ROOT")
        return

    n = len(test_dirs)
    pass_k = min(PASS_K_CONFIG, n)

    print(f"使用样本目录: {test_dirs}")
    print(f"共 {n} 个样本，统计 pass@{pass_k}")

    result_dic = build_result_dict()
    total_steps = n * len(DESIGN_LIST)
    progress_bar = tqdm.tqdm(total=total_steps)

    for t in test_dirs:
        test_one_batch(t, result_dic, progress_bar)

    progress_bar.close()

    syntax_p, func_p = cal_atk(result_dic, n, pass_k)
    print(f"syntax pass@{pass_k}: {syntax_p:.6f}")
    print(f"func   pass@{pass_k}: {func_p:.6f}")

    save_results_to_txt(result_dic, n, test_dirs, pass_k)


if __name__ == "__main__":
    main()
