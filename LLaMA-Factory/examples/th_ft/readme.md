cd /home/tanhao/LLaMA-Factory
conda activate llama_factory
export WANDB_MODE=offline
CUDA_VISIBLE_DEVICES=0,1,3,5,6,7 llamafactory-cli train examples/th_ft/gemma3-27b.yaml 
或：
CUDA_VISIBLE_DEVICES=4,5,6,7
nohup llamafactory-cli train examples/th_ft/gemma3-27b.yaml > output.log 2>&1 &
# 新建 tmux 会话并启动训练
tmux new -s finetune 'nohup llamafactory-cli train examples/th_ft/DeepSeek-R1-0528-Qwen3-8B-run.yaml > output.log 2>&1'


ps -ef | grep -E '[p]ython.*llamafactory|[p]ython.*qwen3|[p]ython.*launcher\.py'
pstree -p | grep -A 5 llamafactory-cli
pkill -f "python.*LLaMA-Factory|python.*DeepSeek-R1-0528-Qwen3-8B-run.yaml|python.*launcher.py"


# 把整个 ./wandb 目录下的所有 run 转换并上传到 SwanLab
swanlab convert -t wandb-local --wb-dir ./wandb  --mode cloud

# 只转换其中一个 run（把 {run_dir_name} 替换为具体目录名，如 offline-run-2025...）
swanlab convert -t wandb-local --wb-dir ./wandb --wb-run-dir {run_dir_name} --mode cloud


登录modelscope
modelscope login --token ms-594fb02f-4a74-4007-bad7-8da7a8b6b93e
modelscope download --model chipcot/qwen3_32b_100Mnew_adapter --local_dir /home-ssd/Users/nsgm_xuh/qwen3_32b_100Mnew_adapter
modelscope upload chipcot/no_cot_8b_adapter /home/tanhao/project1/src/checkpoints_DeepSeek-R1-0528-Qwen3-8B-verilog/deepseek-1113/checkpoint-231
/home/tanhao/project1/src/checkpoints_DeepSeek-R1-0528-Qwen3-8B-verilog/deepseek-1103/checkpoint-231