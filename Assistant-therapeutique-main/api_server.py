from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from transformers import AutoTokenizer, AutoModelForCausalLM
import torch
import uvicorn

app = FastAPI(title="Therapeutic Assistant API")

# Enable CORS for Flutter frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your Flutter app's origin
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global variables for model and tokenizer
model = None
tokenizer = None
device = None

class ChatRequest(BaseModel):
    message: str
    max_tokens: int = 200
    temperature: float = 0.4

class ChatResponse(BaseModel):
    response: str
    status: str

@app.on_event("startup")
async def load_model():
    """Load the model when the server starts"""
    global model, tokenizer, device
    
    model_name = "Revolc/AssistantTherapeutique"
    print(f"Loading model: {model_name}")
    
    try:
        tokenizer = AutoTokenizer.from_pretrained(model_name)
        model = AutoModelForCausalLM.from_pretrained(
            model_name,
            torch_dtype=torch.float16 if torch.cuda.is_available() else torch.float32,
            device_map="auto"
        )
        device = model.device
        print(f"✓ Model loaded successfully on: {device}")
    except Exception as e:
        print(f"Error loading model: {e}")
        raise

@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "status": "online",
        "model": "Revolc/AssistantTherapeutique",
        "device": str(device) if device else "not loaded"
    }

@app.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    """
    Send a message to the therapeutic assistant and get a response
    """
    if model is None or tokenizer is None:
        raise HTTPException(status_code=503, detail="Model not loaded")
    
    try:
        # Format the prompt with constraints
        prompt = f"""### Constraints:
- Respond in 2–3 sentences maximum
- Be concise and calm
- Give only the essential advice
- Offer your help
- Be honest 
- Don't lie to be nice

### Instruction:
{request.message}

### Response:
"""
        
        # Tokenize
        inputs = tokenizer(prompt, return_tensors="pt").to(device)
        
        # Generate response
        with torch.no_grad():
            outputs = model.generate(
                **inputs,
                max_new_tokens=request.max_tokens,
                temperature=request.temperature,
                top_p=0.9,
                do_sample=True,
                pad_token_id=tokenizer.eos_token_id
            )
        
        # Decode the response
        full_response = tokenizer.decode(outputs[0], skip_special_tokens=True)
        
        # Extract only the generated response (after "### Response:")
        if "### Response:" in full_response:
            response_text = full_response.split("### Response:")[-1].strip()
        else:
            response_text = full_response.strip()
        
        return ChatResponse(
            response=response_text,
            status="success"
        )
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generating response: {str(e)}")

@app.get("/health")
async def health_check():
    """Check if the model is loaded and ready"""
    return {
        "model_loaded": model is not None,
        "tokenizer_loaded": tokenizer is not None,
        "device": str(device) if device else None,
        "cuda_available": torch.cuda.is_available()
    }

if __name__ == "__main__":
    # Run the server
    uvicorn.run(app, host="0.0.0.0", port=8000)
