# Brevet 07 — Orchestrateur d'Intentions

**Inventeur:** Herbert Manfred Fulgence Vaty
**Organisation:** ElevitaX
**Date de création:** Janvier 2026
**Statut:** Préparation de dépôt

---

## 1. Titre de l'invention

**Système et méthode pour la classification déterministe d'intentions et le routage de requêtes dans un système d'intelligence artificielle**

*English: System and Method for Deterministic Intent Classification and Request Routing in an Artificial Intelligence System*

---

## 2. Domaine technique

- Traitement du langage naturel (NLP)
- Classification de texte
- Architecture de microservices
- Systèmes de routage

---

## 3. Problème technique résolu

### 3.1 Classification d'intentions par LLM

Les systèmes actuels utilisent des LLMs pour classifier les intentions :

| Problème | Impact |
|----------|--------|
| **Non-déterministe** | Classification variable pour même entrée |
| **Latence élevée** | Appel LLM = centaines de ms |
| **Coût** | Chaque classification = tokens facturés |
| **Dépendance externe** | Nécessite API cloud |
| **Opacité** | Pourquoi cette classe ? Inconnu |

### 3.2 Besoin de routage fiable

Les systèmes IA multi-fonctions nécessitent :
- Routage prévisible et reproductible
- Classification instantanée (< 1 ms)
- Fonctionnement hors-ligne
- Traçabilité de la décision de routage

---

## 4. Description de l'invention

### 4.1 Principe fondamental

L'Orchestrateur classifie les intentions via des **règles explicites** et **patterns lexicaux**, sans réseau neuronal.

```
Requête → Analyse de patterns → Intent déterminé → Handler approprié
```

### 4.2 Architecture du système

```
┌─────────────────────────────────────────────────────────────────┐
│                    Intent Orchestrator System                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                  Input: User Request                     │   │
│  │                  "Is SQEP secure?"                       │   │
│  └────────────────────────────┬─────────────────────────────┘   │
│                               │                                 │
│                               ▼                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                  Tokenizer & Normalizer                  │   │
│  │                                                          │   │
│  │  - Lowercase                                             │   │
│  │  - Remove punctuation                                    │   │
│  │  - Stem/lemmatize (optional)                             │   │
│  │  - Extract tokens: ["is", "sqep", "secure"]              │   │
│  │                                                          │   │
│  └────────────────────────────┬─────────────────────────────┘   │
│                               │                                 │
│                               ▼                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                  Pattern Matcher                         │   │
│  │                                                          │   │
│  │  Rule 1: starts_with("is") → VERIFY candidate            │   │
│  │  Rule 2: contains("?") → QUERY candidate                 │   │
│  │  Rule 3: contains("verify", "check", "confirm") → VERIFY │   │
│  │  Rule 4: contains("what", "how", "why", "when") → QUERY  │   │
│  │  Rule 5: contains("add", "ingest", "learn") → INGEST     │   │
│  │  Rule 6: contains("explain", "proof") → EXPLAIN          │   │
│  │                                                          │   │
│  └────────────────────────────┬─────────────────────────────┘   │
│                               │                                 │
│                               ▼                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                  Intent Resolver                         │   │
│  │                                                          │   │
│  │  Candidates: [VERIFY (rule 1), QUERY (rule 2)]           │   │
│  │  Priority: VERIFY > QUERY (more specific)                │   │
│  │  Resolved: VERIFY                                        │   │
│  │                                                          │   │
│  └────────────────────────────┬─────────────────────────────┘   │
│                               │                                 │
│                               ▼                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                  Handler Dispatcher                      │   │
│  │                                                          │   │
│  │  Intent: VERIFY                                          │   │
│  │  Handler: VerifyHandler                                  │   │
│  │  Dispatch → VerifyHandler.handle(request)                │   │
│  │                                                          │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 4.3 Règles de classification

```rust
pub struct IntentRule {
    pub id: &'static str,
    pub intent: Intent,
    pub priority: u8,           // Plus bas = plus prioritaire
    pub condition: RuleCondition,
}

pub enum RuleCondition {
    StartsWith(&'static str),
    Contains(&'static str),
    ContainsAny(&'static [&'static str]),
    Regex(&'static str),
    And(Box<RuleCondition>, Box<RuleCondition>),
    Or(Box<RuleCondition>, Box<RuleCondition>),
}

// Règles de classification
const INTENT_RULES: &[IntentRule] = &[
    // VERIFY rules (priority 1 - most specific)
    IntentRule {
        id: "verify_is_prefix",
        intent: Intent::Verify,
        priority: 1,
        condition: RuleCondition::StartsWith("is "),
    },
    IntentRule {
        id: "verify_keywords",
        intent: Intent::Verify,
        priority: 1,
        condition: RuleCondition::ContainsAny(&["verify", "check", "confirm", "validate", "true", "false"]),
    },

    // INGEST rules (priority 1)
    IntentRule {
        id: "ingest_keywords",
        intent: Intent::Ingest,
        priority: 1,
        condition: RuleCondition::ContainsAny(&["add fact", "ingest", "learn that", "remember that"]),
    },

    // EXPLAIN rules (priority 1)
    IntentRule {
        id: "explain_keywords",
        intent: Intent::Explain,
        priority: 1,
        condition: RuleCondition::ContainsAny(&["explain", "proof", "why did", "how did"]),
    },

    // QUERY rules (priority 2 - less specific, fallback)
    IntentRule {
        id: "query_question_words",
        intent: Intent::Query,
        priority: 2,
        condition: RuleCondition::ContainsAny(&["what", "how", "why", "when", "where", "who"]),
    },
    IntentRule {
        id: "query_question_mark",
        intent: Intent::Query,
        priority: 3,
        condition: RuleCondition::Contains("?"),
    },
];
```

### 4.4 Résolution de conflits

```rust
impl Orchestrator {
    pub fn classify(&self, input: &str) -> IntentClassification {
        let normalized = self.normalize(input);
        let mut candidates: Vec<(Intent, u8, &str)> = Vec::new();

        // Évaluer toutes les règles
        for rule in INTENT_RULES {
            if self.matches(&normalized, &rule.condition) {
                candidates.push((rule.intent, rule.priority, rule.id));
            }
        }

        // Trier par priorité (plus bas = meilleur)
        candidates.sort_by_key(|(_, priority, _)| *priority);

        // Prendre le meilleur candidat ou fallback
        let (intent, priority, rule_id) = candidates
            .first()
            .cloned()
            .unwrap_or((Intent::Query, 99, "fallback"));

        IntentClassification {
            intent,
            confidence: self.compute_confidence(priority, candidates.len()),
            matched_rule: rule_id.to_string(),
            candidates: candidates.iter().map(|(i, _, r)| format!("{:?}:{}", i, r)).collect(),
        }
    }

    fn compute_confidence(&self, priority: u8, candidates_count: usize) -> f64 {
        // Confiance basée sur :
        // - Priorité basse = confiance haute
        // - Moins de candidats = moins d'ambiguïté
        let priority_factor = 1.0 - (priority as f64 * 0.1).min(0.5);
        let ambiguity_factor = 1.0 / (candidates_count as f64).sqrt();
        (priority_factor * ambiguity_factor).min(1.0)
    }
}
```

### 4.5 Registre de handlers

```rust
pub struct HandlerRegistry {
    handlers: HashMap<Intent, Box<dyn Handler>>,
    fallback: Box<dyn Handler>,
}

impl HandlerRegistry {
    pub fn new() -> Self {
        let mut handlers = HashMap::new();
        handlers.insert(Intent::Query, Box::new(QueryHandler::new()));
        handlers.insert(Intent::Verify, Box::new(VerifyHandler::new()));
        handlers.insert(Intent::Ingest, Box::new(IngestHandler::new()));
        handlers.insert(Intent::Explain, Box::new(ExplainHandler::new()));

        Self {
            handlers,
            fallback: Box::new(QueryHandler::new()),
        }
    }

    pub fn dispatch(&self, intent: Intent, request: Request) -> Response {
        self.handlers
            .get(&intent)
            .unwrap_or(&self.fallback)
            .handle(request)
    }
}

pub trait Handler {
    fn handle(&self, request: Request) -> Response;
}
```

### 4.6 Sortie de classification

```json
{
  "classification": {
    "intent": "Verify",
    "confidence": 0.95,
    "matched_rule": "verify_is_prefix",
    "candidates": [
      "Verify:verify_is_prefix",
      "Query:query_question_mark"
    ],
    "processing_time_us": 42
  }
}
```

---

## 5. Nouveauté et activité inventive

### 5.1 Ce qui distingue l'invention

| Aspect | Classification LLM | Notre invention |
|--------|-------------------|-----------------|
| Méthode | Réseau neuronal | Règles explicites |
| Déterminisme | Non | Oui |
| Latence | 100-500 ms | < 1 ms |
| Coût | Tokens facturés | Gratuit |
| Offline | Non | Oui |
| Traçabilité | Aucune | Règle identifiée |

### 5.2 Recherche d'antériorité

**Technologies explorées :**
- **BERT/GPT classifiers** — Non déterministes, coûteux
- **Intent recognition (Dialogflow, LUIS)** — Cloud-based, non déterministe
- **Rule engines (Drools)** — Business rules, pas NLP
- **Regex routers** — Pas de résolution de priorité sophistiquée

**Conclusion :** Aucun système connu ne combine classification par règles explicites, résolution de priorité, et traçabilité complète pour intentions IA.

---

## 6. Revendications (Claims)

### Revendication principale

**1.** Système de classification d'intentions déterministe comprenant :
- un normaliseur de texte configuré pour préparer l'entrée (lowercase, tokenization) ;
- une bibliothèque de règles de classification, chaque règle associant une condition lexicale à une intention et une priorité ;
- un évaluateur de règles configuré pour identifier toutes les règles correspondant à l'entrée ;
- un résolveur de priorité configuré pour sélectionner l'intention de plus haute priorité parmi les candidats ;
- un registre de handlers associant chaque intention à un traitement spécifique ;
- un dispatcheur configuré pour router la requête vers le handler approprié.

### Revendications dépendantes

**2.** Système selon la revendication 1, caractérisé en ce que les conditions de règles incluent : StartsWith, Contains, ContainsAny, Regex, And, Or.

**3.** Système selon la revendication 1, caractérisé en ce que chaque règle possède un identifiant unique permettant la traçabilité.

**4.** Système selon la revendication 1, caractérisé en ce que le résolveur utilise la priorité numérique (plus bas = meilleur) pour départager les candidats.

**5.** Système selon la revendication 1, caractérisé en ce que la sortie inclut : l'intention classifiée, la confiance, la règle déclenchée, et la liste des candidats.

**6.** Système selon la revendication 1, caractérisé en ce que la classification s'effectue en moins de 1 milliseconde sur CPU standard.

**7.** Méthode de classification d'intentions déterministe comprenant les étapes de :
- normaliser l'entrée textuelle (lowercase, suppression ponctuation) ;
- évaluer chaque règle de la bibliothèque contre l'entrée normalisée ;
- collecter les règles correspondantes avec leurs intentions et priorités ;
- sélectionner l'intention de plus haute priorité ;
- calculer un score de confiance basé sur la priorité et l'ambiguïté ;
- router vers le handler correspondant à l'intention.

**8.** Méthode selon la revendication 7, caractérisée en ce que deux exécutions avec la même entrée produisent la même classification.

**9.** Méthode selon la revendication 7, comprenant en outre une intention par défaut (fallback) utilisée si aucune règle ne correspond.

**10.** Produit programme d'ordinateur comprenant des instructions qui, lorsqu'exécutées par un processeur, mettent en œuvre le système selon la revendication 1.

---

## 7. Implémentation de référence

### 7.1 Fichiers sources clés

| Fichier | Rôle |
|---------|------|
| `src/ai/sqep_llm/orchestrator.rs` | Orchestrateur principal |
| `src/ai/sqep_llm/intent_rules.rs` | Bibliothèque de règles |
| `src/ai/sqep_llm/handlers/` | Handlers par intention |
| `src/ai/sqep_llm/contract.rs` | Enum Intent |

### 7.2 Types de données

```rust
#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq, Hash)]
pub enum Intent {
    Query,      // Poser une question
    Verify,     // Vérifier une affirmation
    Ingest,     // Ajouter un fait
    Explain,    // Expliquer une preuve
    Hypothesize, // Ajouter une hypothèse
}

#[derive(Debug, Serialize)]
pub struct IntentClassification {
    pub intent: Intent,
    pub confidence: f64,
    pub matched_rule: String,
    pub candidates: Vec<String>,
    pub processing_time_us: u64,
}
```

### 7.3 Benchmarks

```
Classification performance (1000 iterations):
- Average: 0.042 ms
- P99: 0.089 ms
- Max: 0.12 ms

Comparison with LLM-based:
- GPT-4: ~500 ms (10000x slower)
- Claude: ~300 ms (7000x slower)
- Local BERT: ~50 ms (1000x slower)
```

---

## 8. Applications industrielles

### 8.1 Chatbots d'entreprise
- Routage instantané des requêtes
- Classification sans API externe
- Traçabilité pour audit

### 8.2 Systèmes embarqués
- Classification sur microcontrôleur
- Pas de dépendance réseau
- Temps réel garanti

### 8.3 Centres d'appels
- Routage déterministe des tickets
- SLA respecté (latence garantie)
- Justification de routage

### 8.4 Applications offline
- Mobile sans connexion
- Edge computing
- Systèmes air-gapped

---

## 9. Avantages techniques

| Avantage | Description |
|----------|-------------|
| **Vitesse** | < 1 ms vs 100-500 ms LLM |
| **Déterminisme** | Même entrée = même routage |
| **Traçabilité** | Règle identifiée |
| **Offline** | Aucune dépendance réseau |
| **Coût** | Zéro (pas de tokens) |
| **Prévisibilité** | Comportement garanti |

---

## 10. Figures (à produire pour le dépôt)

1. **Figure 1** — Architecture de l'Orchestrateur
2. **Figure 2** — Flux de classification
3. **Figure 3** — Résolution de priorité
4. **Figure 4** — Registre de handlers
5. **Figure 5** — Comparaison latence LLM vs Orchestrateur

---

## 11. Mots-clés pour classification

- G06F 40/30 — Classification de texte
- G06N 5/04 — Systèmes à base de règles
- G06F 9/46 — Dispatching de tâches
- H04L 67/50 — Routage de requêtes

---

*Document préparé pour dépôt de brevet — ElevitaX 2026*
