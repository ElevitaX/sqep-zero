# Brevet 06 — Narrateur Déterministe

**Inventeur:** Herbert Manfred Fulgence Vaty
**Organisation:** ElevitaX
**Date de création:** Janvier 2026
**Statut:** Préparation de dépôt

---

## 1. Titre de l'invention

**Système et méthode pour la génération déterministe de narratifs en langage naturel à partir de preuves structurées**

*English: System and Method for Deterministic Natural Language Narrative Generation from Structured Proofs*

---

## 2. Domaine technique

- Génération de langage naturel (NLG)
- Intelligence artificielle explicable (XAI)
- Systèmes de templates
- Communication homme-machine

---

## 3. Problème technique résolu

### 3.1 Hallucinations dans la génération de texte

Les LLMs génératifs :

| Problème | Impact |
|----------|--------|
| **Hallucinations** | Inventent des faits inexistants |
| **Incohérence** | Texte différent à chaque fois |
| **Embellissement** | Ajoutent des détails non fondés |
| **Perte de précision** | Déforment les données sources |
| **Non-vérifiabilité** | Impossible de tracer l'origine |

### 3.2 Besoin d'explications fiables

Les domaines critiques nécessitent :
- Explications exactement fidèles aux données
- Reproductibilité du texte généré
- Absence totale d'invention
- Traçabilité vers les preuves

---

## 4. Description de l'invention

### 4.1 Principe fondamental

Le Narrateur transforme des **preuves structurées** en **texte naturel** via des **templates déterministes**, sans aucune génération probabiliste.

```
Preuve structurée → Templates → Texte naturel (déterministe)
```

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Proof {        │     │  Template {     │     │  "The statement │
│    status:      │────▶│    pattern:     │────▶│   is VERIFIED   │
│      VERIFIED   │     │    "The {stmt}  │     │   with 95%      │
│    confidence:  │     │     is {status} │     │   confidence,   │
│      0.95       │     │     with {conf} │     │   based on..."  │
│    facts: [...] │     │     ..."        │     │                 │
│  }              │     │  }              │     └─────────────────┘
└─────────────────┘     └─────────────────┘
```

### 4.2 Architecture du système

```
┌─────────────────────────────────────────────────────────────────┐
│                  Deterministic Narrator System                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                     Input: Proof/Decision                │   │
│  └────────────────────────────┬─────────────────────────────┘   │
│                               │                                 │
│                               ▼                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                  Mode Selector                           │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │   │
│  │  │ Structured  │  │  Executive  │  │   Machine   │       │   │
│  │  │ (detailed)  │  │  (brief)    │  │   (JSON)    │       │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘       │   │
│  └────────────────────────────┬─────────────────────────────┘   │
│                               │                                 │
│                               ▼                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │               Language Selector                          │   │
│  │         ┌──────────┐     ┌──────────┐                    │   │
│  │         │ English  │     │ Français │                    │   │
│  │         └──────────┘     └──────────┘                    │   │
│  └────────────────────────────┬─────────────────────────────┘   │
│                               │                                 │
│                               ▼                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │               Template Engine                            │   │
│  │                                                          │   │
│  │  1. Sélectionner le template selon intent + status       │   │
│  │  2. Extraire les variables de la preuve                  │   │
│  │  3. Substituer les placeholders                          │   │
│  │  4. Assembler les sections                               │   │
│  │                                                          │   │
│  └────────────────────────────┬─────────────────────────────┘   │
│                               │                                 │
│                               ▼                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │               Output: Deterministic Narrative            │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 4.3 Structure des templates

```rust
#[derive(Clone)]
pub struct NarrativeTemplate {
    pub intent: Intent,
    pub status: Status,
    pub language: Language,
    pub mode: NarratorMode,

    pub header: &'static str,
    pub body: &'static str,
    pub confidence_section: &'static str,
    pub proof_section: &'static str,
    pub footer: &'static str,
}

// Exemple de template (Verify + Success + English + Structured)
const TEMPLATE_VERIFY_SUCCESS_EN_STRUCTURED: NarrativeTemplate = NarrativeTemplate {
    intent: Intent::Verify,
    status: Status::Success,
    language: Language::En,
    mode: NarratorMode::Structured,

    header: "## Verification Result\n\n",

    body: "The statement \"{statement}\" has been **{status}**.\n\n",

    confidence_section: "### Confidence\n\n\
        - **Score:** {confidence_percent}%\n\
        - **Authority:** {authority_score}\n\
        - **Freshness:** {freshness_score}\n\
        - **Corroboration:** {corroboration_count} supporting fact(s)\n\n",

    proof_section: "### Proof Chain\n\n\
        - **Proof ID:** `{proof_id}`\n\
        - **Facts used:** {facts_count}\n\
        - **Deduction steps:** {steps_count}\n\n",

    footer: "---\n*Verified by SQEP-LLM — Deterministic Cognitive Engine*\n",
};
```

### 4.4 Processus de génération

```rust
impl Narrator {
    pub fn narrate(&self, response: &Response) -> Narrative {
        // 1. Sélectionner le template approprié
        let template = self.select_template(
            response.intent,
            response.status,
            self.language,
            self.mode,
        );

        // 2. Extraire les variables de la réponse
        let vars = self.extract_variables(response);

        // 3. Générer chaque section
        let header = self.substitute(&template.header, &vars);
        let body = self.substitute(&template.body, &vars);
        let confidence = self.substitute(&template.confidence_section, &vars);
        let proof = self.substitute(&template.proof_section, &vars);
        let footer = self.substitute(&template.footer, &vars);

        // 4. Assembler le narratif
        let text = format!("{}{}{}{}{}", header, body, confidence, proof, footer);

        Narrative {
            text,
            language: self.language,
            mode: self.mode,
            generated_at: Utc::now(),
        }
    }

    fn substitute(&self, template: &str, vars: &HashMap<String, String>) -> String {
        let mut result = template.to_string();
        for (key, value) in vars {
            result = result.replace(&format!("{{{}}}", key), value);
        }
        result
    }
}
```

### 4.5 Modes de narration

#### Mode Structured (détaillé)
```markdown
## Verification Result

The statement "SQEP uses SHA-256" has been **VERIFIED**.

### Confidence
- **Score:** 95.0%
- **Authority:** 0.95 (official documentation)
- **Freshness:** 0.98 (5 days old)
- **Corroboration:** 3 supporting fact(s)

### Proof Chain
- **Proof ID:** `proof-a1b2c3d4`
- **Facts used:** 2
- **Deduction steps:** 3

---
*Verified by SQEP-LLM — Deterministic Cognitive Engine*
```

#### Mode Executive (bref)
```
VERIFIED: "SQEP uses SHA-256" (95% confidence, proof: proof-a1b2c3d4)
```

#### Mode Machine (JSON)
```json
{
  "status": "VERIFIED",
  "statement": "SQEP uses SHA-256",
  "confidence": 0.95,
  "proof_id": "proof-a1b2c3d4"
}
```

### 4.6 Support multilingue

```rust
// Templates français
const TEMPLATE_VERIFY_SUCCESS_FR_STRUCTURED: NarrativeTemplate = NarrativeTemplate {
    intent: Intent::Verify,
    status: Status::Success,
    language: Language::Fr,
    mode: NarratorMode::Structured,

    header: "## Résultat de vérification\n\n",

    body: "L'affirmation « {statement} » a été **{status_fr}**.\n\n",

    confidence_section: "### Confiance\n\n\
        - **Score :** {confidence_percent}%\n\
        - **Autorité :** {authority_score}\n\
        - **Fraîcheur :** {freshness_score}\n\
        - **Corroboration :** {corroboration_count} fait(s) de soutien\n\n",

    // ...
};
```

---

## 5. Nouveauté et activité inventive

### 5.1 Ce qui distingue l'invention

| Aspect | LLMs génératifs | Notre invention |
|--------|-----------------|-----------------|
| Méthode | Prédiction probabiliste | Substitution de templates |
| Déterminisme | Non | Oui |
| Hallucination | Risque élevé | Impossible |
| Fidélité | Variable | 100% fidèle aux données |
| Reproductibilité | Non | Même entrée = même texte |

### 5.2 Recherche d'antériorité

**Technologies explorées :**
- **GPT/Claude** — Génératifs, non déterministes
- **Template engines (Jinja, Handlebars)** — Web, pas IA explicable
- **NLG rule-based (SimpleNLG)** — Grammaire, pas preuves
- **Report generators** — Données tabulaires, pas raisonnement

**Conclusion :** Aucun système connu ne génère de narratifs déterministes à partir de preuves de raisonnement IA.

---

## 6. Revendications (Claims)

### Revendication principale

**1.** Système de génération de narratifs déterministes comprenant :
- une bibliothèque de templates structurés organisés par intent, status, langue et mode ;
- un sélecteur de template configuré pour choisir le template approprié selon les paramètres de la réponse ;
- un extracteur de variables configuré pour identifier les valeurs à substituer depuis la preuve/décision ;
- un moteur de substitution configuré pour remplacer les placeholders par les valeurs extraites ;
- un assembleur de sections configuré pour produire le narratif final.

### Revendications dépendantes

**2.** Système selon la revendication 1, caractérisé en ce que les templates sont organisés en sections : header, body, confidence_section, proof_section, footer.

**3.** Système selon la revendication 1, caractérisé en ce que le système supporte plusieurs langues (anglais, français) avec templates distincts par langue.

**4.** Système selon la revendication 1, caractérisé en ce que le système supporte plusieurs modes : structured (détaillé), executive (bref), machine (JSON).

**5.** Système selon la revendication 1, caractérisé en ce que deux exécutions avec la même entrée produisent un narratif identique caractère par caractère.

**6.** Système selon la revendication 1, caractérisé en ce que le narratif généré ne contient aucune information non présente dans la preuve/décision source.

**7.** Méthode de génération de narratif déterministe comprenant les étapes de :
- recevoir une réponse contenant une décision et/ou une preuve ;
- sélectionner un template selon l'intent, le status, la langue et le mode ;
- extraire les variables de la réponse (statement, confidence, proof_id, etc.) ;
- substituer les placeholders du template par les valeurs extraites ;
- assembler les sections pour former le narratif final.

**8.** Méthode selon la revendication 7, caractérisée en ce que la substitution est purement textuelle sans aucune génération de contenu.

**9.** Produit programme d'ordinateur comprenant des instructions qui, lorsqu'exécutées par un processeur, mettent en œuvre le système selon la revendication 1.

---

## 7. Implémentation de référence

### 7.1 Fichiers sources clés

| Fichier | Rôle |
|---------|------|
| `src/ai/sqep_llm/narrator.rs` | Moteur de narration |
| `src/ai/sqep_llm/templates/` | Bibliothèque de templates |
| `src/ai/sqep_llm/contract.rs` | NarratorMode, Language |

### 7.2 Structure de sortie

```rust
#[derive(Serialize, Deserialize)]
pub struct Narrative {
    pub text: String,
    pub language: Language,
    pub mode: NarratorMode,
    pub generated_at: DateTime<Utc>,
}

#[derive(Serialize, Deserialize, Clone, Copy)]
pub enum Language {
    En,
    Fr,
}

#[derive(Serialize, Deserialize, Clone, Copy)]
pub enum NarratorMode {
    Structured,
    Executive,
    Machine,
}
```

### 7.3 Exemple d'utilisation

```rust
let narrator = Narrator::new(Language::En, NarratorMode::Structured);

let response = engine.execute(Request::verify("SQEP uses SHA-256"));

let narrative = narrator.narrate(&response);

println!("{}", narrative.text);
// Sortie déterministe, identique à chaque exécution
```

---

## 8. Applications industrielles

### 8.1 Rapports automatisés
- Génération de rapports d'audit déterministes
- Documentation de décisions IA
- Comptes-rendus de vérification

### 8.2 Communication réglementaire
- Explications RGPD Article 22
- Documentation pour régulateurs
- Justifications de décisions de crédit

### 8.3 Interface utilisateur
- Réponses chatbot sans hallucination
- Aide en ligne fidèle aux données
- FAQ automatisées

### 8.4 Multilingue
- Même logique, langues différentes
- Localisation sans dérive sémantique
- Conformité internationale

---

## 9. Avantages techniques

| Avantage | Description |
|----------|-------------|
| **Zéro hallucination** | Impossible d'inventer |
| **Reproductibilité** | Même entrée = même texte |
| **Fidélité** | 100% fidèle aux données |
| **Multilingue** | Templates par langue |
| **Multi-mode** | Détaillé, bref, machine |
| **Vérifiabilité** | Narratif traçable aux sources |

---

## 10. Figures (à produire pour le dépôt)

1. **Figure 1** — Architecture du système Narrateur
2. **Figure 2** — Flux de génération de narratif
3. **Figure 3** — Structure d'un template
4. **Figure 4** — Exemple de sortie Structured
5. **Figure 5** — Comparaison avec génération LLM

---

## 11. Mots-clés pour classification

- G06F 40/56 — Génération de langage naturel
- G06N 5/04 — Systèmes explicables
- G06F 40/20 — Traduction automatique
- G06Q 10/10 — Rapports automatisés

---

*Document préparé pour dépôt de brevet — ElevitaX 2026*
