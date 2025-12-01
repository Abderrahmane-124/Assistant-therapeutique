from transformers import AutoTokenizer, AutoModelForCausalLM
import torch

model_name = "Revolc/AssistantTherapeutique"

print(f"Loading model: {model_name}")

tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(
    model_name,
    torch_dtype=torch.float16 if torch.cuda.is_available() else torch.float32,
    device_map="auto"
)

print(f"✓ Model loaded successfully on: {model.device}")

# Test prompt (using your training format)
prompt = """
### Constraints:
- Respond in 2–3 sentences maximum
- Be concise and calm
- Give only the essential advice
- Offer your help
- Be honest 
- Don't lie to be nice

### Instruction:
today i was walking, not at the side but at the middle of the road, and a car honked at me. I got verry upset and angry, like who does he think he is to honk at me ??? who is wrong here ?

### Response:
"""

print(f"\n{'='*50}\nTesting model...\n{'='*50}")

# Tokenize
inputs = tokenizer(prompt, return_tensors="pt").to(model.device)

# Generate
with torch.no_grad():
    outputs = model.generate(
        **inputs,
        max_new_tokens=200,
        temperature=0.4,
        top_p=0.9,
        do_sample=True,
        pad_token_id=tokenizer.eos_token_id
    )

# Decode
response = tokenizer.decode(outputs[0], skip_special_tokens=True)

print(f"\nRESPONSE:\n{response}")
print(f"{'='*50}")