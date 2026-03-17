from transformers import AutoTokenizer

# 加载模型的分词器
model_path ="/home/tanhao/Qwen3-30B-A3B-Thinking-2507"
tokenizer = AutoTokenizer.from_pretrained(model_path, trust_remote_code=True)

# 查看聊天模板内容
print(tokenizer.chat_template)