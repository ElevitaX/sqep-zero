# SQEP-Zero

**The Universal Standard for Cryptographic Proof of Digital Actions**

> *"Every action on your data deserves a receipt."*

[![Standard](https://img.shields.io/badge/Standard-v1.0%20Frozen-blue)](docs/SQEP-ZERO-WHITEPAPER.md)
[![License](https://img.shields.io/badge/License-MIT-green)](#license)
[![Rust](https://img.shields.io/badge/Rust-1.75+-orange)](https://www.rust-lang.org/)
[![Tests](https://img.shields.io/badge/Tests-679%20passing-brightgreen)](#)

---

## Ecosystem

SQEP-Zero is part of the **ElevitaX SQEP ecosystem**:

| Repository | Purpose |
|------------|---------|
| **[sqep-zero](https://github.com/ElevitaX/sqep-zero)** | HashChain & verifiable receipts — *the standard* |
| **[sqep-lite](https://github.com/ElevitaX/sqep-lite)** | Lightweight authenticated encryption library |

`sqep-lite` powers the cryptographic primitives used internally by SQEP-Zero.

---

## What is SQEP-Zero?

**SQEP-Zero** (Secure Quantum Encryption Protocol — Zero) is an open cryptographic standard that enables anyone to **prove** — not just claim — that a digital action occurred.

```
┌──────────────────────────────────────┐
│           SQEP RECEIPT               │
├──────────────────────────────────────┤
│  Action:     FILE_ENCRYPTED          │
│  Timestamp:  2026-01-31T10:30:00Z    │
│  Hash:       7c8d1e2f3a4b5c6d...     │
│  Prev Hash:  858a81309f473dac...     │
└──────────────────────────────────────┘
```

**Key innovation:** We hash the *action*, not the data — enabling proof without exposure.

---

## The Problem

Organizations make promises about data handling:
- "Your data is encrypted"
- "We comply with GDPR"
- "Our AI is transparent"

**But they can't prove it.**

Traditional logs can be altered. Audit trails can be deleted. Trust is required.

**SQEP-Zero changes this.** Every action generates a cryptographic receipt, linked in an immutable chain. Anyone can verify — no trust required, just math.

---

## The Standard (10 Principles)

1. **SQEP-Zero** is an open cryptographic standard for producing verifiable proof of digital actions.
2. A **Receipt** is a cryptographic record proving that a specific action occurred on data.
3. Each Receipt contains: action type, timestamp, actor reference, object reference, and a SHA-256 hash.
4. The **HashChain** links each Receipt to the previous one via `previous_hash`, forming an immutable chain.
5. The **Genesis Receipt** is the origin of any HashChain — it has no predecessor.
6. Chain integrity is verified by recalculating all hashes sequentially from Genesis to head.
7. SQEP-Zero hashes **actions**, never raw data — ensuring privacy, universality, and GDPR compliance.
8. Verification is public and requires no trust in the issuer — only the mathematical chain.
9. The standard is **use-case agnostic**: files, AI decisions, compliance, legal proof, or any domain.
10. **Every action on your data deserves a receipt.**

### Core Principle

> **"Security is a promise. Proof is a fact."**

---

## Genesis Block

The SQEP-Zero standard was frozen on January 31, 2026.

```
Hash:       858a81309f473dacc70e4a94b21a09a6d56241ae810ee6b9308e6a49d00038b7
Tag:        CHAIN_GENESIS
Authority:  ElevitaX
Chain ID:   SQEP-ELEVITAX-PROD-V1
Status:     FROZEN (immutable)
```

---

## Quick Start

### Verify the Chain

```bash
curl -s http://localhost:8080/v1/journal/verify | jq
```

```json
{
  "valid": true,
  "entries": 342
}
```

### Append a Receipt

```bash
curl -X POST http://localhost:8080/v1/journal/append \
  -H "Content-Type: application/json" \
  -d '{"tag": "FILE_ENCRYPTED", "message": "file_id=doc-001 algo=AES-256-GCM"}'
```

### Get Chain Head

```bash
curl -s http://localhost:8080/v1/journal/head | jq
```

---

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/v1/journal/append` | POST | Add a new Receipt |
| `/v1/journal/verify` | GET | Verify entire chain |
| `/v1/journal/head` | GET | Get latest Receipt hash |
| `/v1/journal/tail?n=10` | GET | Get last N Receipts |
| `/v1/journal/healthz` | GET | Health check |

---

## Use Cases

### GDPR Compliance
Every data access, modification, or deletion generates a Receipt. Prove compliance mathematically.

### AI Traceability
Every AI decision generates a Receipt linking input, model, and output. Explainability by design.

### Document Integrity
Hash documents at creation, chain the Receipt. Any modification is detectable.

### Financial Audit
Transaction logs become tamper-evident. Auditors verify math, not trust.

### Supply Chain
Every handoff generates a Receipt. Provenance verified end-to-end.

---

## Why Not Blockchain?

| Aspect | Blockchain | SQEP-Zero |
|--------|------------|-----------|
| Consensus required | Yes | No |
| Cryptocurrency | Usually | No |
| Latency | Minutes-hours | Milliseconds |
| Energy | High | Minimal |
| Offline operation | No | Yes |
| Complexity | High | Low |

**SQEP-Zero is designed for organizational sovereignty** — you control your chain.

---

## Technical Specs

| Metric | Value |
|--------|-------|
| Language | Rust |
| Hash Algorithm | SHA-256 |
| Storage Format | JSONL |
| Binary Size | ~15 MB |
| Memory | < 50 MB |
| External LLM | Not required |
| GPU | Not required |
| Offline | Yes |
| Platforms | Linux, Windows, macOS, ARM, Android |

---

## Build

```bash
# Clone
git clone https://github.com/ElevitaX/sqep-zero.git
cd sqep-zero

# Build (all features)
cargo build --release --features "api ed25519 hash-sha256 qpu-entropy"

# Run
./target/release/sqep-zero

# Test
cargo test
```

---

## Documentation

| Document | Description |
|----------|-------------|
| [Whitepaper (Technical)](docs/SQEP-ZERO-WHITEPAPER.md) | Full technical specification |
| [Whitepaper (Investors)](docs/SQEP-ZERO-WHITEPAPER-INVESTORS.md) | Business case and market |
| [Pitch Deck](docs/SQEP-ZERO-PITCH-DECK.md) | Presentation slides |

---

## Project Status

- [x] HashChain v1.0 — **FROZEN**
- [x] Genesis Receipt — **CREATED**
- [x] Public Verification API — **LIVE**
- [x] 679 Tests — **PASSING**
- [ ] SDK (JavaScript) — Coming Q3 2026
- [ ] SDK (Python) — Coming Q3 2026
- [ ] Multi-chain anchoring — Roadmap

---

## Contributing

SQEP-Zero is an open standard. Contributions welcome:

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

Please read the standard specification before contributing.

---

## License

MIT License — See [LICENSE](LICENSE)

The SQEP-Zero standard is open and free to implement.

---

## About ElevitaX

**ElevitaX** is the creator and reference implementation of SQEP-Zero.

We believe that in a world of digital promises, **proof is the only currency that matters**.

---

## Contact

- **Organization:** ElevitaX
- **Standard:** SQEP-Zero v1.0
- **Genesis:** `858a81309f473dacc70e4a94b21a09a6d56241ae810ee6b9308e6a49d00038b7`

---

> **"Security is a promise. Proof is a fact."**
