# SQEP-Zero — Dependances Systeme

Ce fichier liste toutes les dependances externes necessaires pour faire fonctionner SQEP-Zero.

---

## 1. Mise a jour du systeme (Ubuntu/Debian)

```bash
sudo apt update && sudo apt upgrade -y
```

---

## 2. Dependances obligatoires

### FFmpeg (Traitement audio/video)

Necessaire pour extraire l'audio des fichiers video avant transcription.

```bash
sudo apt install -y ffmpeg
```

Verification:
```bash
ffmpeg -version
```

### Build tools (Compilation Rust)

```bash
sudo apt install -y build-essential pkg-config libssl-dev
```

### SQLite (Base de donnees)

```bash
sudo apt install -y sqlite3 libsqlite3-dev
```

---

## 3. Ollama (LLM local)

Ollama permet d'executer des modeles de langage localement (Mistral, LLaMA, etc.).

### Installation

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

### Demarrage du service

```bash
ollama serve
```

Ou en arriere-plan:
```bash
nohup ollama serve > /dev/null 2>&1 &
```

### Telecharger un modele (Mistral recommande)

```bash
ollama pull mistral
```

Autres modeles utiles:
```bash
ollama pull llama3.2        # Plus leger
ollama pull mixtral         # Plus puissant
```

Verification:
```bash
ollama list
```

---

## 4. Whisper (Transcription audio)

Whisper est utilise pour transcrire l'audio en texte.

### Option A: whisper.cpp (Recommande - plus rapide)

```bash
# Cloner le repo
git clone https://github.com/ggerganov/whisper.cpp.git
cd whisper.cpp

# Compiler
make

# Telecharger un modele (medium recommande pour le francais)
./models/download-ggml-model.sh medium

# Tester
./main -m models/ggml-medium.bin -f samples/jfk.wav
```

Ensuite, configurer la variable d'environnement:
```bash
export SQEP_WHISPER_CMD="/chemin/vers/whisper.cpp/main"
export SQEP_WHISPER_MODEL="/chemin/vers/whisper.cpp/models/ggml-medium.bin"
```

### Option B: OpenAI Whisper (Python)

```bash
pip install openai-whisper
```

---

## 5. Rust (Compilation du projet)

### Installation de Rust

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env
```

Verification:
```bash
rustc --version
cargo --version
```

---

## 6. Variables d'environnement

Creer un fichier `.env` dans le dossier `src/`:

```bash
cp .env.example .env
```

Variables importantes:

```env
# LLM (Ollama)
SQEP_OLLAMA_URL=http://127.0.0.1:11434
SQEP_OLLAMA_MODEL=mistral

# Whisper
SQEP_WHISPER_CMD=/chemin/vers/whisper.cpp/main
SQEP_WHISPER_MODEL=/chemin/vers/whisper.cpp/models/ggml-medium.bin

# Archives
SQEP_TRAVAIL_ROOT=/TRAVAIL
SQEP_ARCHIVES_ROOT=/ARCHIVES

# API
SQEP_API_PORT=8080
```

---

## 7. Checklist rapide

```
[ ] sudo apt update && sudo apt upgrade -y
[ ] sudo apt install -y ffmpeg build-essential pkg-config libssl-dev sqlite3 libsqlite3-dev
[ ] curl -fsSL https://ollama.com/install.sh | sh
[ ] ollama pull mistral
[ ] Installer whisper.cpp ou openai-whisper
[ ] curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
[ ] Configurer .env
[ ] cargo build --release
```

---

## 8. Demarrage

```bash
# Terminal 1: Ollama
ollama serve

# Terminal 2: SQEP-Zero
cd /home/hcl/sqep0/src
cargo run --release
```

L'API sera disponible sur `http://localhost:8080`

---

## 9. Verification des services

```bash
# Verifier FFmpeg
ffmpeg -version

# Verifier Ollama
curl http://localhost:11434/api/tags

# Verifier SQEP-Zero
curl http://localhost:8080/health
```

---

## 10. Problemes courants

### "failed to spawn ffmpeg"
→ FFmpeg n'est pas installe. Executer: `sudo apt install -y ffmpeg`

### "connection refused" sur Ollama
→ Ollama n'est pas demarre. Executer: `ollama serve`

### Transcription lente
→ Utiliser un modele Whisper plus petit (`tiny` ou `small`) ou compiler whisper.cpp avec support GPU

### Erreur de compilation Rust
→ Installer les build tools: `sudo apt install -y build-essential pkg-config libssl-dev`

---

*Document mis a jour: Janvier 2026*
