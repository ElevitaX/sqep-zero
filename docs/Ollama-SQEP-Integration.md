# SQEP-Zero + Ollama Integration Guide (Quaggy AI Teacher)

This document extends the main deployment setup by adding **Ollama** (local LLM hosting)
and connecting it to **Quaggy**, your AI assistant layer inside the SQEP ecosystem.

---

## 1️⃣ Install SQEP-Zero (Core)

Already included in the main deployment guide.  
Make sure you’ve built your backend successfully:

```bash
cd ~/sqep-zero
cargo build --release
```

Optional system-wide install:
```bash
sudo cp target/release/sqep-zero /usr/local/bin/sqep-zero
```

---

## 2️⃣ Install Ollama (Pop!_OS / Ubuntu)

Ollama is a local LLM runner — perfect for privacy and offline reasoning.

```bash
curl -fsSL https://ollama.com/install.sh | sh
ollama --version
```

After installation, the Ollama service will start automatically (`systemctl status ollama`).  
If not, run manually:

```bash
ollama serve &
```

Check it’s listening:
```bash
curl http://127.0.0.1:11434/api/tags
```

---

## 3️⃣ Choose and Download Your Coder Model

The following LLMs are currently top-rated for code generation and reasoning (as of Nov 2025):

| Model | Type | Notes |
|--------|------|-------|
| **deepseek-coder:33b** | Large Code LLM | Best accuracy, multi-language, heavy RAM load (~64GB). |
| **codellama:70b** | Meta | Great documentation and refactoring ability (~48GB). |
| **mistral-coder:7b** | Lightweight | Fast inference, works on mid-tier GPUs or CPUs (~8GB). |

### Download the model you prefer:
```bash
ollama pull deepseek-coder:33b
# or for lower memory
ollama pull mistral-coder:7b
```

Confirm it’s available:
```bash
ollama list
```

Run a quick test:
```bash
ollama run deepseek-coder
```

---

## 4️⃣ Connect Quaggy to Ollama

Your Quaggy chat backend (Node or Axum bridge) can call Ollama’s local API directly.

Add the following to your **.env** file (in `/opt/sqep-zero/.env` or project root):

```env
OLLAMA_HOST=http://127.0.0.1:11434
OLLAMA_MODEL=deepseek-coder:33b
```

Then use this snippet in your **Node/Express chat API** to query Ollama dynamically:

```js
// example: quaggy/ollamaBridge.js
import fetch from "node-fetch";

export async function queryOllama(prompt) {
  const response = await fetch(`${process.env.OLLAMA_HOST}/api/generate`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      model: process.env.OLLAMA_MODEL,
      prompt,
      stream: false
    })
  });

  const data = await response.json();
  return data.response || "";
}
```

Usage example inside Quaggy chat controller:

```js
import { queryOllama } from "./ollamaBridge.js";

app.post("/api/chat", async (req, res) => {
  const userMessage = req.body.message;
  const aiReply = await queryOllama(userMessage);
  res.json({ reply: aiReply });
});
```

---

## 5️⃣ Verify Quaggy + Ollama Integration

Once your backend is running:

```bash
curl -X POST http://localhost:8090/api/chat   -H "Content-Type: application/json"   -d '{"message": "Explain how to build a Rust Axum route"}' | jq .
```

Expected output (trimmed):
```json
{
  "reply": "To define a route in Axum, first import Router and handler..."
}
```

You can now use **Quaggy** as your local coding assistant, powered by **SQEP-Zero** and **Ollama**.

---

## 6️⃣ Optional Enhancements

✅ Add authentication for Ollama API (reverse proxy under /api/ai).  
✅ Configure GPU acceleration (CUDA / ROCm).  
✅ Use Ollama’s built-in `modelfile` to create a fine-tuned “SQEP-Teacher” persona.  

Example modelfile (`~/.ollama/models/sqep-teacher`):
```
FROM deepseek-coder:33b
SYSTEM "You are Quaggy, a secure AI teacher assisting in cryptography, code, and system reasoning."
PARAMETER temperature 0.4
PARAMETER top_p 0.9
```

Load it:
```bash
ollama create sqep-teacher -f ~/.ollama/models/sqep-teacher
ollama run sqep-teacher
```

---

## ✅ Summary

✔ SQEP-Zero backend and web layers deployed  
✔ Ollama installed locally on Pop!_OS  
✔ DeepSeek or Mistral model pulled  
✔ Quaggy chat connected to local LLM API  
✔ Optional SQEP-Teacher persona for consistent replies

---

**LevitaX / SQUEP.AI — November 2025**  
*"Securing the future through adaptive intelligence."*
