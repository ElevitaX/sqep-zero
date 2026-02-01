# SQEP-Zero · Secure Quantum-Enhanced Processing

SQUEP.AI — Next-gen cryptography and perceptual intelligence.
Rust (Axum) backend + web UIs (SZ, QTV, Chat) with the QSeed enhancer for fluid, sharp video under tight bandwidth.

<p align="left">
  <img src="https://img.shields.io/badge/Rust-1.78%2B-orange" />
  <img src="https://img.shields.io/badge/Axum-HTTP%20server-blue" />
  <img src="https://img.shields.io/badge/Node.js-18%2B-brightgreen" />
  <img src="https://img.shields.io/badge/Hls.js-enabled-informational" />
  <img src="https://img.shields.io/badge/WebGPU%2FGPU-accelerated-lightgrey" />
  <img src="https://img.shields.io/badge/License-Internal-lightgrey" />
</p>

---

## Overview

| Module | Description |
|-------|-------------|
| Core API | Rust/Axum backend handling encryption, decryption, key wrapping, pairing, journal, QPU. |
| QSeed (Perceptual Core) | AI-assisted enhancer and smoothness governor; secure wrap_key endpoint. |
| SZ (SigmaZero Tools) | Web UI for /v0/encrypt, /v0/decrypt, /qseed/wrap_key. |
| QTV (Quaggy TV) | Hls.js demo player + QSeed enhancer and adaptive buffer tuning. |
| Chat (Quaggy Chat) | Themed chat UI connected to the same Axum API. |

Stack: Rust (Axum, Tower-HTTP, Tokio) - Node/Express (proxy/static) - HTML/JS + Hls.js - WebGPU/WebGL as available.

---

## Architecture

```
Browser (SZ / QTV / Chat)
        |
        v
Nginx @ sqep.ai
  ├── /            → Node/Express (8090)  [static + dev proxy]
  └── /api/*       → Axum (8080)          [v0, v1, qseed]
        |
        v
Axum (Rust)
  ├── /v0          (encrypt, decrypt, wrap_key legacy)
  ├── /v1          (journal, node, transfer, qpu, pairing)
  └── /qseed       (enhance, wrap_key)
        |
        v
QSeed / SigmaZeroBrain (state isolated)
+ ProofJournal (persistence-ready)
```

A vector diagram lives in docs/sqep_arch.svg (included in this package).

---

## Features

### Crypto
- /api/v0/encrypt and /api/v0/decrypt (Base64 payload in/out, binary-safe .sqep files)
- /api/qseed/wrap_key supports password mode today; future-ready for HKDF + AEAD

### QSeed Enhancer
- Real-time frame validation and adaptive strength
- Smoothness governor keeps motion stable and prevents flicker
- GPU-accelerated path when available

### UX / i18n / Themes
- EN/FR toggle (persistent)
- Unified design tokens and radial gradient background
- Responsive top bar shared across SZ, QTV, Chat

---

## Local Dev

### Prereqs
- Rust 1.78+ (rustup toolchain install stable)
- Node.js 18+
- jq (optional for CLI examples)

### Run Backend
```bash
# from repo root
cargo run --release --bin sqep-zero
# default listen (example): 0.0.0.0:8080
```

### Run Web (Node/Express)
```bash
cd web
npm i
node server.js
# default listen: 0.0.0.0:8090
```

### Quick API Checks
```bash
# encrypt
curl -sX POST http://127.0.0.1:8090/api/v0/encrypt   -H 'content-type: application/json'   -d '{"data_b64":""}' | jq .

# wrap key (password mode demo)
curl -sX POST http://127.0.0.1:8090/api/qseed/wrap_key   -H 'content-type: application/json'   -d '{"mode":"password","key":"ABCD","password":"hunter2"}' | jq .
```

---

## Project Layout
```
sqep-zero/
├─ src/
│  ├─ api/            # Axum endpoints (v0, v1, qseed)
│  ├─ ai/             # SigmaZeroBrain hooks
│  ├─ journal/        # ProofJournal
│  └─ main.rs
├─ web/
│  ├─ server.js       # Express proxy/static
│  ├─ chat/           # Quaggy Chat
│  ├─ qtv/            # QSeed TV
│  └─ sz/             # SigmaZero Tools
└─ docs/
   └─ sqep_arch.svg
```

---

## Deployment (Own Server, Nginx + systemd)

A complete step-by-step guide is provided in DEPLOY-sqep-ai.md in the repo root.

---

## Philosophy

Security through Intelligence, and Intelligence through Security.

(c) 2025 LevitaX / SQUEP.AI. Internal license until open publication.
