# SQEP-LLM Technical Specification v0.2

## Deep Logic — Not Deep Learning

SQEP-LLM is a **deterministic reasoning engine** that operates without GPU acceleration. It replaces probabilistic token prediction with **logical inference chains** grounded in verifiable facts.

---

## 1. Core Primitives

### 1.1 Fact
A **Fact** is an immutable, hash-verified statement derived from:
- User input (transcriptions, documents)
- System observations (journal entries, proofs)
- External sources (with provenance chain)

```rust
struct Fact {
    id: Sha256Hash,
    content: String,
    source: FactSource,
    timestamp: i64,
    confidence: f32,  // 0.0-1.0, derived from source trust
}
```

**Confidence levels:**
- `1.0` — Cryptographic proof (hash-chain verified)
- `0.9` — Direct user statement
- `0.7` — Inferred from trusted facts
- `0.5` — External LLM suggestion (advisory only)

> **Confidence is a decision weight, not a truth claim.**
>
> A user input at 0.9 can be factually wrong. An inference at 0.8 can be invalidated later.
> Confidence reflects *source trust*, not *objective truth*.

### 1.2 Thought
A **Thought** is an intermediate reasoning step linking facts to conclusions.

> **A Thought has no epistemic value by itself.**

```rust
struct Thought {
    id: Sha256Hash,
    premise: Vec<FactId>,      // Input facts
    inference_rule: RuleId,    // Which rule was applied
    conclusion: String,        // Derived statement
    validity: bool,            // Can be invalidated by new facts
}
```

**Thought Constraints:**
- A Thought is **never a proof**
- A Thought is **never persistent by default**
- A Thought may be:
  - Journaled (optional, for debug/audit)
  - Reconstituted from facts + rules
  - Discarded after decision is made

### 1.3 Proof
A **Proof** is a complete, verifiable reasoning chain from facts to conclusion.

```rust
struct Proof {
    id: Sha256Hash,
    facts: Vec<Fact>,
    thoughts: Vec<Thought>,
    conclusion: String,
    hash_chain: Vec<Sha256Hash>,  // Verifiable trail
}
```

### 1.4 Hypothesis
A **Hypothesis** is an unproven statement requiring validation.

```rust
struct Hypothesis {
    id: Sha256Hash,
    statement: String,
    supporting_facts: Vec<FactId>,
    contradicting_facts: Vec<FactId>,
    status: HypothesisStatus,  // Pending | Validated | Refuted | Dormant
    origin: HypothesisOrigin,  // User | SqepLlm | ExternalLlm
}
```

**Hypothesis Lifecycle:**

```
                    ┌──────────────┐
                    │   CREATED    │
                    │  (Pending)   │
                    └──────┬───────┘
                           │
            ┌──────────────┼──────────────┐
            │              │              │
            ▼              ▼              ▼
     ┌──────────┐   ┌──────────┐   ┌──────────┐
     │ VALIDATED│   │ REFUTED  │   │ DORMANT  │
     │ → Fact   │   │ → Discard│   │ → Archive│
     └──────────┘   └──────────┘   └──────────┘
```

- **Created by:** User input, SQEP-LLM inference, or External LLM advisory
- **Validated:** Promoted to Fact (confidence ≥ 0.7, no contradictions)
- **Refuted:** Contradicts existing facts → permanently rejected
- **Dormant:** Insufficient evidence → archived for future resolution

---

## 2. Cognitive Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER INPUT                              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    QUAGGY (Orchestrator)                        │
│  - Intent classification                                        │
│  - Context extraction                                           │
│  - Response formatting                                          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                 SQEP-LLM (Deep Logic Engine)                    │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐       │
│  │  Fact Store   │  │ Inference     │  │ Proof Builder │       │
│  │  (Memory)     │──│ Engine        │──│               │       │
│  └───────────────┘  └───────────────┘  └───────────────┘       │
│                              │                                  │
│                              ▼                                  │
│                    ┌───────────────┐                           │
│                    │ Confidence    │                           │
│                    │ Evaluator     │                           │
│                    └───────────────┘                           │
└─────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┴───────────────┐
              │ confidence < threshold?       │
              └───────────────┬───────────────┘
                    YES       │       NO
                    │         │         │
                    ▼         │         ▼
┌─────────────────────────┐   │   ┌─────────────────────────┐
│  EXTERNAL LLM (Ollama)  │   │   │  DIRECT RESPONSE        │
│  - Advisory only        │   │   │  (High confidence)      │
│  - Suggestions tagged   │   │   └─────────────────────────┘
│  - Never authoritative  │   │
└─────────────────────────┘   │
                    │         │
                    ▼         │
┌─────────────────────────┐   │
│  VALIDATION GATE        │   │
│  - Check against facts  │   │
│  - Reject contradictions│   │
└─────────────────────────┘   │
                    │         │
                    └────┬────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                      RESPONSE OUTPUT                            │
│  - Journaled with hash                                         │
│  - Provenance attached                                         │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. Inference Rules

SQEP-LLM uses a fixed set of **deterministic inference rules**:

### 3.1 Direct Match
```
IF query ∈ Facts THEN return Fact
```

### 3.2 Semantic Similarity (Candidate Activation)
```
IF similarity(query, Fact) > 0.8 THEN activate Fact as candidate
```
Similarity computed via TF-IDF or BM25 (no neural embeddings required).

> **Similarity ≠ Inference.**
>
> Semantic similarity is used for **candidate activation** only.
> All final decisions remain **deductive** — similarity merely selects
> which facts enter the reasoning process.

### 3.3 Deductive Chain
```
IF A → B AND B → C THEN A → C
```

### 3.4 Negation
```
IF A AND ¬A THEN contradiction (reject hypothesis)
```

### 3.5 Confidence Propagation
```
confidence(conclusion) = min(confidence(premises)) × rule_weight
```

---

## 4. Memory Store

### 4.1 Structure
```
sqep_memories.jsonl
├── bootstrap entries (system knowledge)
├── learned facts (user interactions)
└── validated hypotheses (promoted to facts)
```

### 4.2 Entry Format
```json
{
  "id": "sha256:abc123...",
  "prompt": "what is sqep",
  "response": "SQEP is a quantum-era protocol...",
  "confidence": 1.0,
  "source": "bootstrap",
  "timestamp": 1706570400,
  "tags": ["sqep", "security", "protocol"]
}
```

### 4.3 Learning Protocol
1. User asks question → Quaggy processes
2. SQEP-LLM generates response (or consults external LLM)
3. Response is **validated** against existing facts
4. If valid and confidence > 0.7: store as new fact
5. Hash entry and append to memory

**Anti-Pollution Rules:**
- Never learn from error responses
- Never learn hallucinated content (detected via contradiction)
- Require minimum response quality (length, structure)

---

## 5. Minimal Cognitive API

The cognitive API is the **frozen contract** between Quaggy and SQEP-LLM.
Once defined, all integrations (Candle, external LLMs) must conform to this interface.

### 5.1 Core Operations

| Operation | Purpose | Mutates State? |
|-----------|---------|----------------|
| `ingest_fact` | Add verified knowledge | Yes |
| `ingest_hypothesis` | Add unverified claim | Yes |
| `reason` | Query with proof generation | No |
| `explain` | Human-readable justification | No |
| `verify` | Check statement against facts | No |

### 5.2 Rust Trait Definition

```rust
/// The minimal cognitive interface for SQEP-LLM.
/// All implementations (local, Candle, hybrid) must satisfy this trait.
pub trait CognitiveEngine {
    /// Ingest a verified fact into the knowledge base.
    /// Returns the fact ID (hash) if successful.
    fn ingest_fact(&mut self, content: &str, source: FactSource) -> Result<FactId, CognitiveError>;

    /// Ingest an unverified hypothesis for later validation.
    /// Hypotheses are never treated as facts until validated.
    fn ingest_hypothesis(&mut self, statement: &str, origin: HypothesisOrigin) -> Result<HypothesisId, CognitiveError>;

    /// Reason about a query and produce a response with proof.
    /// This is the main entry point for answering questions.
    fn reason(&self, query: &str) -> ReasoningResult;

    /// Generate a human-readable explanation for a proof.
    /// Used by the Narrator to translate proofs into natural language.
    fn explain(&self, proof_id: &ProofId) -> Option<String>;

    /// Verify a statement against the current knowledge base.
    /// Returns validation status without modifying state.
    fn verify(&self, statement: &str) -> VerificationResult;
}
```

### 5.3 Data Structures

```rust
pub struct ReasoningResult {
    pub response: String,
    pub confidence: f32,
    pub proof: Option<Proof>,
    pub activated_facts: Vec<FactId>,
    pub source: ResponseSource,  // Direct | Inferred | Advisory
}

pub struct VerificationResult {
    pub status: VerificationStatus,  // Confirmed | Contradicted | Unknown
    pub supporting: Vec<FactId>,
    pub contradicting: Vec<FactId>,
    pub confidence: f32,
}

pub enum CognitiveError {
    InvalidContent,
    ContradictionDetected { fact_id: FactId },
    StorageFailed,
    InsufficientConfidence,
}

pub enum FactSource {
    Bootstrap,      // System knowledge (confidence: 1.0)
    UserDirect,     // User statement (confidence: 0.9)
    Inferred,       // Derived from facts (confidence: 0.7-0.9)
    ExternalLlm,    // Advisory only (confidence: 0.5)
    Transcription,  // Archive content (confidence: 0.85)
}

pub enum HypothesisOrigin {
    User,
    SqepLlm,
    ExternalLlm,
}

pub enum ResponseSource {
    Direct,    // Exact match from Fact Store
    Inferred,  // Derived through reasoning
    Advisory,  // From external LLM (tagged)
}
```

### 5.4 HTTP API

```
POST /api/sqep-llm/ingest/fact
  { "content": "...", "source": "user_direct" }
  → { "id": "sha256:...", "stored": true }

POST /api/sqep-llm/ingest/hypothesis
  { "statement": "...", "origin": "user" }
  → { "id": "sha256:...", "status": "pending" }

POST /api/sqep-llm/reason
  { "query": "...", "context": [...] }
  → { "response": "...", "confidence": 0.9, "proof_id": "...", "source": "inferred" }

GET /api/sqep-llm/explain/:proof_id
  → { "explanation": "This conclusion follows from...", "facts_used": [...] }

POST /api/sqep-llm/verify
  { "statement": "..." }
  → { "status": "confirmed", "supporting": [...], "contradicting": [], "confidence": 0.95 }
```

### 5.5 Operation Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER QUERY                              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    reason(query)                                │
│  1. Activate candidate facts (similarity)                       │
│  2. Apply inference rules                                       │
│  3. Build proof chain                                           │
│  4. Evaluate confidence                                         │
└─────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┴───────────────┐
              │ confidence >= threshold?      │
              └───────────────┬───────────────┘
                    NO        │       YES
                    │         │         │
                    ▼         │         ▼
┌─────────────────────────┐   │   ┌─────────────────────────┐
│  Consult External LLM   │   │   │  Return ReasoningResult │
│  → ingest_hypothesis()  │   │   │  (Direct or Inferred)   │
│  → verify()             │   │   └─────────────────────────┘
│  → reason() again       │   │
└─────────────────────────┘   │
                    │         │
                    ▼         │
┌─────────────────────────┐   │
│  Return ReasoningResult │   │
│  (Advisory, conf=0.5)   │───┘
└─────────────────────────┘
```

---

## 6. Determinism Guarantees

| Property | Guarantee |
|----------|-----------|
| **Reproducibility** | Same input + same memory → same output |
| **Verifiability** | Every response has hash-chain proof |
| **No Hallucination** | Responses derived only from stored facts |
| **Auditability** | Complete reasoning trace available |

---

## 7. External LLM Integration (Optional)

External LLMs (Ollama, OpenAI, etc.) serve as **advisors**, not authorities.

### 7.1 When to Consult
- SQEP-LLM confidence < 0.5
- No matching facts in memory
- User explicitly requests creative content

### 7.2 Response Handling
```rust
fn handle_external_response(response: &str) -> Option<Hypothesis> {
    // 1. Parse as hypothesis (not fact)
    let hyp = Hypothesis::new(response, confidence: 0.5);

    // 2. Check for contradictions
    if self.contradicts_facts(&hyp) {
        return None;  // Reject
    }

    // 3. Return for user consideration
    Some(hyp)
}
```

### 7.3 Trust Levels
| Source | Trust | Use Case |
|--------|-------|----------|
| Hash-verified journal | 1.0 | System state |
| User statement | 0.9 | Direct knowledge |
| SQEP-LLM inference | 0.7-0.9 | Derived facts |
| External LLM | 0.5 | Advisory only |

---

## 8. Implementation Phases

### Phase 1: Core Engine (Current)
- [x] Memory store (JSONL)
- [x] Smart fallback responses
- [x] Basic semantic matching
- [ ] Confidence scoring
- [ ] Proof building

### Phase 2: Cognitive API Implementation (Next)
- [ ] Implement `CognitiveEngine` trait
- [ ] `ingest_fact` with hash verification
- [ ] `ingest_hypothesis` with lifecycle
- [ ] `reason` with proof generation
- [ ] `explain` for Narrator bridge
- [ ] `verify` for contradiction detection

### Phase 2b: Inference Engine
- [ ] Rule-based deduction
- [ ] Contradiction detection
- [ ] Hypothesis validation

### Phase 3: Candle Integration (Assistive Only)
- [ ] Local embeddings (no GPU)
- [ ] Efficient similarity search
- [ ] Optional quantized models

> **Candle Constraints:**
> - Never a source of truth
> - No write access to Fact Store
> - Never makes final decisions
> - Used strictly for candidate activation and similarity scoring

### Phase 4: Full Autonomy
- [ ] Self-improving memory
- [ ] Automatic fact extraction
- [ ] Distributed proof verification

---

## 9. Design Principles

1. **Logic over Statistics**: Prefer deterministic rules over probabilistic inference
2. **Proof over Prediction**: Every claim must be traceable to facts
3. **Memory over Model**: Knowledge lives in verified data, not learned weights
4. **Transparency over Performance**: Slower but explainable beats fast but opaque
5. **Autonomy over Dependency**: Function fully without external services

---

## 10. Glossary

| Term | Definition |
|------|------------|
| **Deep Logic** | Deterministic reasoning through explicit rules |
| **Fact** | Verified, immutable knowledge unit |
| **Thought** | Intermediate inference step |
| **Proof** | Complete reasoning chain |
| **Hypothesis** | Unverified claim awaiting validation |
| **Confidence** | Trust score (0.0-1.0) based on source |
| **Memory Poisoning** | Learning incorrect or adversarial data |
| **Hash Chain** | SHA-256 linked list for verification |

---

*SQEP-LLM: Intelligence through proof, not probability.*
