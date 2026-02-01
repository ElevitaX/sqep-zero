Great choice. Here’s a quick, practical plan to try **Qwen** with Ollama and fall back to **TinyLlama** if it’s too heavy—plus the exact commands to switch in seconds.

## 1) Pull a Qwen coder model (start “medium-small”)

```bash
# good first try for coding:
ollama pull qwen2.5-coder:7b

# quick test:
ollama run qwen2.5-coder:7b
```

* Qwen2.5-Coder comes in 0.5B / 1.5B / 3B / 7B / 14B / 32B sizes; 7B is a solid balance for many servers (you can go down to 3B/1.5B if needed). Source: Ollama model card (Ollama, accessed Nov 2025). ([Ollama][1])

> Tip on memory: Ollama often runs models in ~4-bit quantization by default to fit consumer hardware; if you hit memory errors, pick a smaller model or a lower-memory quant. Source: Ollama library guidance (Ollama, accessed Nov 2025). ([Ollama][2])

## 2) Point Quaggy at Qwen (so it becomes your “teacher”)

Set your env and restart your chat/web service:

```bash
# e.g., /opt/sqep-zero/.env
echo 'OLLAMA_HOST=http://127.0.0.1:11434' | sudo tee -a /opt/sqep-zero/.env
echo 'OLLAMA_MODEL=qwen2.5-coder:7b' | sudo tee -a /opt/sqep-zero/.env

# restart your service that calls Ollama
sudo systemctl restart sqep-web.service
```

(Using an env var like `OLLAMA_MODEL` is a simple, standard pattern to route your app to a different model.)

## 3) If Qwen is too large or slow, switch instantly

### Option A — try a **smaller Qwen**

```bash
ollama pull qwen2.5-coder:3b
# then switch:
sudo sed -i 's/OLLAMA_MODEL=.*/OLLAMA_MODEL=qwen2.5-coder:3b/' /opt/sqep-zero/.env
sudo systemctl restart sqep-web.service
```

(Available sizes are documented by Qwen/Ollama. Ollama library & HF model cards, accessed Nov 2025.) ([Ollama][1])

### Option B — fall back to **TinyLlama** (very light)

```bash
ollama pull tinyllama:latest
sudo sed -i 's/OLLAMA_MODEL=.*/OLLAMA_MODEL=tinyllama:latest/' /opt/sqep-zero/.env
sudo systemctl restart sqep-web.service
```

* TinyLlama is ~1.1B parameters (~638 MB download on Ollama) and designed for minimal RAM/VRAM. Sources: Ollama model page; TinyLlama HF card (Ollama & TinyLlama team, accessed Nov 2025). ([Ollama][3])

## 4) Free disk if you pulled a model you won’t use

```bash
# list what’s installed
ollama list

# remove a heavy model
ollama rm qwen2.5-coder:14b
```

(From Ollama CLI usage; see the official library pages.) ([Ollama][4])

## 5) How to tell it’s “too big” (and what to do)

* **Symptoms:** model fails to load, swaps heavily, or replies crawl.
* **Fixes (in order):**

  1. Switch to **smaller size** (7B → 3B → 1.5B). ([Ollama][5])
  2. Ensure **4-bit quant** (Ollama defaults often are low-bit; choose the tag variants with lower memory if offered). ([Ollama][2])
  3. Fall back to **TinyLlama** for guaranteed light usage. ([Ollama][3])

---

### Quick sanity checks

```bash
# verify Ollama is up
curl http://127.0.0.1:11434/api/tags

# see service logs for your web/chat bridge
journalctl -u sqep-web -n 200 --no-pager
```

(Using Ollama’s local REST API on :11434 is standard; see Ollama docs, accessed Nov 2025.) ([Ollama Documentation][6])

If you want, I can generate a tiny **switch script** (`quaggy-model-switch.sh`) that toggles between `qwen2.5-coder:7b`, `qwen2.5-coder:3b`, and `tinyllama:latest` and restarts your service automatically.

[1]: https://ollama.com/library/qwen2.5-coder?utm_source=chatgpt.com "qwen2.5-coder - ollama.com"
[2]: https://ollama.com/library/wizardlm%3A7b-q4_K_M?utm_source=chatgpt.com "wizardlm:7b-q4_K_M - ollama.com"
[3]: https://ollama.com/library/tinyllama?utm_source=chatgpt.com "tinyllama"
[4]: https://ollama.com/library?utm_source=chatgpt.com "library - Ollama"
[5]: https://www.ollama.com/library/qwen2.5-coder%3A7b?utm_source=chatgpt.com "qwen2.5-coder:7b - ollama.com"
[6]: https://docs.ollama.com/windows?utm_source=chatgpt.com "Windows - Ollama"

