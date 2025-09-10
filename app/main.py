import os
import json
from fastapi import FastAPI
from pydantic import BaseModel
import urllib.request

app = FastAPI()

USE_OLLAMA = os.getenv("USE_OLLAMA", "0") == "1"
OLLAMA_URL = os.getenv("OLLAMA_URL", "http://host.docker.internal:11434")
OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "llama3.1")

class ChatIn(BaseModel):
    message: str

@app.get("/healthz")
def healthz():
    return {"ok": True}

def call_ollama(prompt: str) -> str:
    url = f"{OLLAMA_URL}/api/generate"
    body = {"model": OLLAMA_MODEL, "prompt": prompt, "stream": False}
    data = json.dumps(body).encode("utf-8")
    req = urllib.request.Request(url, data=data, method="POST")
    req.add_header("Content-Type", "application/json")
    with urllib.request.urlopen(req, timeout=180) as resp:
        payload = json.loads(resp.read().decode("utf-8"))
        return payload.get("response", "").strip()

@app.post("/chat")
def chat(inp: ChatIn):
    prompt = (inp.message or "").strip()
    if not prompt:
        return {"reply": ""}
    try:
        if USE_OLLAMA:
            reply = call_ollama(prompt)
        else:
            return {"error": "Setea USE_OLLAMA=1 para usar Ollama del host"}
        return {"reply": reply}
    except Exception as e:
        return {"error": str(e)}
