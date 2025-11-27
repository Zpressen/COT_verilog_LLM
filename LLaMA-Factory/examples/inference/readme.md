cd /home/tanhao/LLaMA-Factory/examples/inference
conda activate llama_factory
CUDA_VISIBLE_DEVICES=1,2,4,5 API_PORT=8005 llamafactory-cli api DeepSeek-R1-0528-Qwen3-8B_lora_sft.yaml

ps aux | grep llamafactory

合并模型：
llamafactory-cli export merge_model_lora.yaml