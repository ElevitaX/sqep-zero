# Brevet 04 — Système de Calibration de Confiance

**Inventeur:** Herbert Manfred Fulgence Vaty
**Organisation:** ElevitaX
**Date de création:** Janvier 2026
**Statut:** Préparation de dépôt

---

## 1. Titre de l'invention

**Système et méthode pour le calcul déterministe de scores de confiance dans un système d'intelligence artificielle**

*English: System and Method for Deterministic Confidence Score Calculation in an Artificial Intelligence System*

---

## 2. Domaine technique

- Intelligence artificielle
- Systèmes de décision
- Gestion de la connaissance
- Analyse de confiance

---

## 3. Problème technique résolu

### 3.1 Scores de confiance arbitraires

Les LLMs actuels produisent des scores de confiance qui sont :

| Problème | Impact |
|----------|--------|
| **Arbitraires** | Pas de méthode de calcul explicite |
| **Non-reproductibles** | Varient entre exécutions |
| **Non-justifiés** | Impossible de savoir d'où vient le score |
| **Mal calibrés** | 90% confiance ≠ 90% exactitude |
| **Opaques** | Boîte noire |

### 3.2 Besoin de confiance calibrée

Les secteurs critiques nécessitent :
- Savoir POURQUOI le système a telle confiance
- Confiance reproductible et vérifiable
- Corrélation entre score et exactitude réelle
- Décomposition du score en facteurs explicites

---

## 4. Description de l'invention

### 4.1 Principe fondamental

Le score de confiance est calculé à partir de **facteurs explicites et mesurables** :

```
Confiance = f(Autorité, Fraîcheur, Corroboration, Couverture)
```

Chaque facteur est :
- Défini explicitement
- Calculé de manière déterministe
- Traçable jusqu'à sa source

### 4.2 Architecture du système

```
┌─────────────────────────────────────────────────────────────┐
│               Confidence Calibration System                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐                                        │
│  │   Requête       │                                        │
│  └────────┬────────┘                                        │
│           │                                                 │
│           ▼                                                 │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              Fact Retrieval                            │ │
│  │              (Faits pertinents)                        │ │
│  └────────┬───────────────────────────────────────────────┘ │
│           │                                                 │
│           ▼                                                 │
│  ┌────────────────────────────────────────────────────────┐ │
│  │         Multi-Factor Confidence Calculator             │ │
│  │                                                        │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │ │
│  │  │   Authority  │  │  Freshness   │  │Corroboration │  │ │
│  │  │   Factor     │  │   Factor     │  │   Factor     │  │ │
│  │  │   (0.0-1.0)  │  │   (0.0-1.0)  │  │   (0.0-1.0)  │  │ │
│  │  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  │ │
│  │         │                 │                 │          │ │
│  │         └─────────────────┼─────────────────┘          │ │
│  │                           │                            │ │
│  │                    ┌──────▼──────┐                     │ │
│  │                    │  Aggregator │                     │ │
│  │                    │  (Weighted) │                     │ │
│  │                    └──────┬──────┘                     │ │
│  │                           │                            │ │
│  └───────────────────────────┼────────────────────────────┘ │
│                              │                              │
│                              ▼                              │
│                    ┌─────────────────┐                      │
│                    │  Final Score    │                      │
│                    │  + Breakdown    │                      │
│                    └─────────────────┘                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 4.3 Facteurs de confiance

#### 4.3.1 Facteur d'autorité (Authority)

Mesure la crédibilité de la source du fait.

```rust
struct AuthorityFactor {
    source_type: SourceType,    // documentation, user, inference
    source_id: String,
    base_authority: f64,        // 0.0 - 1.0
    verification_level: u8,     // 0 = non vérifié, 3 = triple vérifié
}

fn calculate_authority(fact: &Fact) -> f64 {
    let base = match fact.source_type {
        SourceType::OfficialDoc => 0.95,
        SourceType::VerifiedUser => 0.80,
        SourceType::Inference => 0.60,
        SourceType::Hypothesis => 0.40,
    };

    // Ajustement selon niveau de vérification
    base * (1.0 + 0.05 * fact.verification_level as f64).min(1.0)
}
```

#### 4.3.2 Facteur de fraîcheur (Freshness)

Mesure la pertinence temporelle de l'information.

```rust
struct FreshnessFactor {
    ingested_at: DateTime<Utc>,
    last_verified: DateTime<Utc>,
    decay_rate: f64,            // Taux de décroissance par jour
}

fn calculate_freshness(fact: &Fact, now: DateTime<Utc>) -> f64 {
    let age_days = (now - fact.last_verified).num_days() as f64;

    // Décroissance exponentielle
    let decay = (-fact.decay_rate * age_days).exp();

    decay.max(0.1)  // Minimum 10% pour éviter zéro
}
```

#### 4.3.3 Facteur de corroboration (Corroboration)

Mesure le nombre de sources indépendantes confirmant le fait.

```rust
struct CorroborationFactor {
    supporting_facts: Vec<FactId>,
    contradicting_facts: Vec<FactId>,
}

fn calculate_corroboration(fact: &Fact, knowledge_base: &KB) -> f64 {
    let supporting = find_supporting_facts(fact, knowledge_base).len();
    let contradicting = find_contradicting_facts(fact, knowledge_base).len();

    if contradicting > 0 {
        // Réduction si contradictions
        return 0.5 * supporting as f64 / (supporting + contradicting) as f64;
    }

    // Bonus logarithmique pour sources multiples
    (1.0 + (supporting as f64).ln() * 0.1).min(1.0)
}
```

#### 4.3.4 Facteur de couverture (Coverage)

Mesure à quel point la requête est couverte par les faits trouvés.

```rust
fn calculate_coverage(query_tokens: &[Token], matched_facts: &[Fact]) -> f64 {
    let query_concepts: HashSet<_> = query_tokens.iter()
        .filter(|t| t.is_significant())
        .collect();

    let covered_concepts: HashSet<_> = matched_facts.iter()
        .flat_map(|f| f.tokens.iter())
        .filter(|t| t.is_significant())
        .collect();

    let intersection = query_concepts.intersection(&covered_concepts).count();

    intersection as f64 / query_concepts.len() as f64
}
```

### 4.4 Agrégation des facteurs

```rust
struct ConfidenceWeights {
    authority: f64,      // Poids du facteur autorité
    freshness: f64,      // Poids du facteur fraîcheur
    corroboration: f64,  // Poids du facteur corroboration
    coverage: f64,       // Poids du facteur couverture
}

impl Default for ConfidenceWeights {
    fn default() -> Self {
        Self {
            authority: 0.35,
            freshness: 0.20,
            corroboration: 0.25,
            coverage: 0.20,
        }
    }
}

fn aggregate_confidence(factors: &ConfidenceFactors, weights: &ConfidenceWeights) -> f64 {
    let weighted_sum =
        factors.authority * weights.authority +
        factors.freshness * weights.freshness +
        factors.corroboration * weights.corroboration +
        factors.coverage * weights.coverage;

    // Normalisation
    let total_weight = weights.authority + weights.freshness +
                       weights.corroboration + weights.coverage;

    weighted_sum / total_weight
}
```

### 4.5 Sortie avec décomposition

```json
{
  "confidence": 0.87,
  "confidence_breakdown": {
    "authority": {
      "score": 0.95,
      "weight": 0.35,
      "contribution": 0.3325,
      "source": "official_documentation"
    },
    "freshness": {
      "score": 0.90,
      "weight": 0.20,
      "contribution": 0.18,
      "age_days": 5
    },
    "corroboration": {
      "score": 0.80,
      "weight": 0.25,
      "contribution": 0.20,
      "supporting_facts": 3,
      "contradicting_facts": 0
    },
    "coverage": {
      "score": 0.75,
      "weight": 0.20,
      "contribution": 0.15,
      "matched_tokens": 6,
      "total_tokens": 8
    }
  }
}
```

---

## 5. Nouveauté et activité inventive

### 5.1 Ce qui distingue l'invention

| Aspect | État de l'art (LLMs) | Notre invention |
|--------|---------------------|-----------------|
| Calcul | Softmax sur logits | Formule explicite multi-facteurs |
| Traçabilité | Aucune | Décomposition complète |
| Reproductibilité | Non | Oui, déterministe |
| Justification | "Le modèle pense..." | Facteurs mesurables |
| Calibration | Variable | Corrélée à l'exactitude |

### 5.2 Recherche d'antériorité

**Approches explorées :**
- **Softmax confidence (LLMs)** — Non interprétable, mal calibré
- **Bayesian confidence** — Complexe, pas déterministe
- **Fuzzy logic** — Pas de traçabilité par facteur
- **Certainty factors (MYCIN)** — Pas de fraîcheur temporelle

**Conclusion :** Aucun système connu ne combine multi-facteurs explicites, décomposition traçable, et calcul déterministe.

---

## 6. Revendications (Claims)

### Revendication principale

**1.** Système de calcul de score de confiance pour intelligence artificielle comprenant :
- un calculateur de facteur d'autorité configuré pour évaluer la crédibilité de la source d'un fait ;
- un calculateur de facteur de fraîcheur configuré pour évaluer la pertinence temporelle d'un fait avec décroissance ;
- un calculateur de facteur de corroboration configuré pour évaluer le nombre de sources confirmantes et contradictoires ;
- un calculateur de facteur de couverture configuré pour évaluer le taux de correspondance entre requête et faits ;
- un agrégateur configuré pour combiner les facteurs selon des poids prédéfinis ;
- un module de décomposition configuré pour produire une explication détaillée de chaque contribution.

### Revendications dépendantes

**2.** Système selon la revendication 1, caractérisé en ce que le facteur de fraîcheur utilise une décroissance exponentielle avec un taux configurable.

**3.** Système selon la revendication 1, caractérisé en ce que le facteur d'autorité est calculé à partir d'une hiérarchie de types de sources (documentation officielle, utilisateur vérifié, inférence, hypothèse).

**4.** Système selon la revendication 1, caractérisé en ce que le facteur de corroboration réduit le score en présence de faits contradictoires.

**5.** Système selon la revendication 1, caractérisé en ce que les poids d'agrégation sont configurables par domaine d'application.

**6.** Système selon la revendication 1, caractérisé en ce que la sortie inclut une décomposition JSON avec score, poids et contribution de chaque facteur.

**7.** Méthode de calcul de score de confiance déterministe comprenant les étapes de :
- calculer un score d'autorité basé sur le type et niveau de vérification de la source ;
- calculer un score de fraîcheur basé sur l'âge du fait avec décroissance temporelle ;
- calculer un score de corroboration basé sur les faits confirmants et contradictoires ;
- calculer un score de couverture basé sur le taux de tokens correspondants ;
- agréger les scores selon des poids prédéfinis ;
- produire une décomposition explicative des contributions.

**8.** Méthode selon la revendication 7, caractérisée en ce que deux exécutions avec les mêmes entrées produisent le même score de confiance.

**9.** Produit programme d'ordinateur comprenant des instructions qui, lorsqu'exécutées par un processeur, mettent en œuvre le système selon la revendication 1.

---

## 7. Implémentation de référence

### 7.1 Fichiers sources clés

| Fichier | Rôle |
|---------|------|
| `src/ai/sqep_llm/trust.rs` | Calcul de confiance |
| `src/ai/sqep_llm/quality.rs` | Facteur d'autorité |
| `src/ai/sqep_llm/temporal.rs` | Facteur de fraîcheur |
| `src/ai/sqep_llm/stability.rs` | Facteur de corroboration |

### 7.2 Structure de données

```rust
#[derive(Debug, Serialize)]
pub struct ConfidenceResult {
    pub score: f64,
    pub breakdown: ConfidenceBreakdown,
}

#[derive(Debug, Serialize)]
pub struct ConfidenceBreakdown {
    pub authority: FactorContribution,
    pub freshness: FactorContribution,
    pub corroboration: FactorContribution,
    pub coverage: FactorContribution,
}

#[derive(Debug, Serialize)]
pub struct FactorContribution {
    pub score: f64,
    pub weight: f64,
    pub contribution: f64,
    pub details: serde_json::Value,
}
```

---

## 8. Applications industrielles

### 8.1 Décisions automatisées réglementées
- Score de confiance auditable pour conformité RGPD
- Justification des décisions de crédit
- Diagnostic médical avec niveau de certitude explicable

### 8.2 Systèmes critiques
- Confiance calibrée pour décisions à haut risque
- Seuils de confiance pour escalade humaine
- Traçabilité pour incidents

### 8.3 Recherche d'information
- Ranking des résultats par confiance explicable
- Filtrage des sources peu fiables
- Détection d'obsolescence

---

## 9. Avantages techniques

| Avantage | Description |
|----------|-------------|
| **Explicabilité** | Chaque facteur visible et mesurable |
| **Reproductibilité** | Même calcul = même score |
| **Calibration** | Score corrélé à l'exactitude réelle |
| **Configurabilité** | Poids ajustables par domaine |
| **Auditabilité** | Décomposition pour vérification |
| **Conformité** | Satisfait exigences réglementaires |

---

## 10. Figures (à produire pour le dépôt)

1. **Figure 1** — Architecture du système de calibration
2. **Figure 2** — Calcul du facteur d'autorité
3. **Figure 3** — Courbe de décroissance temporelle
4. **Figure 4** — Agrégation pondérée des facteurs
5. **Figure 5** — Exemple de décomposition de confiance

---

## 11. Mots-clés pour classification

- G06N 5/04 — Systèmes d'inférence
- G06F 16/90 — Évaluation de pertinence
- G06N 7/00 — Systèmes à base de connaissances
- G06Q 10/06 — Systèmes d'aide à la décision

---

*Document préparé pour dépôt de brevet — ElevitaX 2026*
