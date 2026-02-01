# Brevet 03 — Architecture Transport-Invariante

**Inventeur:** Herbert Manfred Fulgence Vaty
**Organisation:** ElevitaX
**Date de création:** Janvier 2026
**Statut:** Préparation de dépôt

---

## 1. Titre de l'invention

**Système et méthode pour l'invariance comportementale d'un service IA à travers multiples protocoles de transport**

*English: System and Method for Behavioral Invariance of an AI Service Across Multiple Transport Protocols*

---

## 2. Domaine technique

- Architecture logicielle distribuée
- Protocoles de communication
- API design patterns
- Systèmes multi-canal

---

## 3. Problème technique résolu

### 3.1 Incohérences dans les systèmes multi-canal

Les systèmes IA modernes exposent plusieurs interfaces :

| Canal | Problème typique |
|-------|------------------|
| CLI | Logique embarquée différente |
| REST API | Sérialisation variable |
| WebSocket | État de session différent |
| SDK | Couche d'abstraction modifiante |
| gRPC | Conversion de types |

**Résultat :** Le même appel via différents canaux peut produire des résultats différents.

### 3.2 Impact sur la confiance

- Tests incomplets (un canal testé, pas les autres)
- Bugs spécifiques à un transport
- Comportement incohérent pour l'utilisateur
- Audit impossible (quel canal a produit quelle réponse ?)

---

## 4. Description de l'invention

### 4.1 Principe fondamental

Un **contrat canonique** unique définit le comportement. Tous les transports sont des **adaptateurs** qui ne modifient pas la logique.

```
                    ┌─────────────────┐
                    │  Canonical      │
                    │  Contract       │
                    │  (Request →     │
                    │   Response)     │
                    └────────┬────────┘
                             │
         ┌───────────────────┼───────────────────┐
         │                   │                   │
         ▼                   ▼                   ▼
    ┌─────────┐        ┌─────────┐        ┌─────────┐
    │   CLI   │        │  HTTP   │        │WebSocket│
    │Adapter  │        │Adapter  │        │Adapter  │
    └─────────┘        └─────────┘        └─────────┘
         │                   │                   │
         ▼                   ▼                   ▼
    Même résultat       Même résultat       Même résultat
```

### 4.2 Architecture du système

```
┌─────────────────────────────────────────────────────────────┐
│                Transport-Invariant Architecture             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              Canonical Contract Layer                  │ │
│  │                                                        │ │
│  │  ┌─────────────┐              ┌─────────────┐          │ │
│  │  │   Request   │──────────────│  Response   │          │ │
│  │  │   Schema    │   Execute    │   Schema    │          │ │
│  │  └─────────────┘              └─────────────┘          │ │
│  │                                                        │ │
│  │  - Intent (query/verify/ingest/explain)                │ │
│  │  - Payload (statement, fact, proof_id)                 │ │
│  │  - Options (language, narrator_mode)                   │ │
│  │                                                        │ │
│  └────────────────────────────────────────────────────────┘ │
│                            │                                │
│              ┌─────────────┼─────────────┐                  │
│              │             │             │                  │
│              ▼             ▼             ▼                  │
│  ┌───────────────┐ ┌───────────────┐ ┌───────────────┐      │
│  │ CLI Transport │ │HTTP Transport │ │ WS Transport  │      │
│  │               │ │               │ │               │      │
│  │ Parse args    │ │ Parse JSON    │ │ Parse frames  │      │
│  │ → Request     │ │ → Request     │ │ → Request     │      │
│  │               │ │               │ │               │      │
│  │ Response →    │ │ Response →    │ │ Response →    │      │
│  │ stdout/exit   │ │ JSON body     │ │ frames        │      │
│  └───────────────┘ └───────────────┘ └───────────────┘      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 4.3 Le contrat canonique

```rust
/// Request - Format canonique d'entrée
#[derive(Serialize, Deserialize)]
pub struct Request {
    pub intent: Intent,           // query, verify, ingest, explain
    pub payload: Payload,         // données spécifiques à l'intent
    pub options: Options,         // language, narrator_mode, dry_run
    pub request_id: String,       // identifiant unique
}

/// Response - Format canonique de sortie
#[derive(Serialize, Deserialize)]
pub struct Response {
    pub request_id: String,       // même ID que la requête
    pub intent: Intent,           // écho de l'intent
    pub status: Status,           // Success, Rejected, Error
    pub confidence: f64,          // 0.0 - 1.0
    pub decision: Option<Decision>,
    pub proof: Option<Proof>,
    pub narrative: Option<Narrative>,
    pub verification: Option<Verification>,
    pub errors: Vec<Error>,
}
```

### 4.4 Sérialisation canonique JSON

Pour garantir l'invariance, la sérialisation JSON est **canonique** :

```rust
/// Sérialisation JSON canonique (déterministe)
fn canonical_json<T: Serialize>(value: &T) -> String {
    // 1. Sérialiser en JSON
    let json = serde_json::to_value(value).unwrap();

    // 2. Trier les clés récursivement
    let sorted = sort_json_keys(&json);

    // 3. Formater sans espaces superflus
    serde_json::to_string(&sorted).unwrap()
}
```

Règles :
- Clés d'objets triées alphabétiquement
- Pas d'espaces après `:` et `,`
- Nombres sans trailing zeros
- UTF-8 NFC normalization

### 4.5 Preuve d'invariance

Le système inclut des tests automatisés qui prouvent l'invariance :

```rust
#[test]
fn test_transport_invariance() {
    let request = Request::query("Is SQEP secure?");

    // Exécution via CLI (local)
    let cli_response = LocalTransport::new().execute(request.clone());

    // Exécution via HTTP
    let http_response = HttpTransport::new("localhost:8090").execute(request.clone());

    // Sérialisation canonique des deux réponses
    let cli_json = canonical_json(&cli_response);
    let http_json = canonical_json(&http_response);

    // IDENTIQUES
    assert_eq!(cli_json, http_json);
}
```

---

## 5. Nouveauté et activité inventive

### 5.1 Ce qui distingue l'invention

| Aspect | État de l'art | Notre invention |
|--------|---------------|-----------------|
| Contrat | Implicite, par convention | Explicite, formalisé |
| Sérialisation | Variable selon transport | Canonique, déterministe |
| Vérification | Tests manuels | Preuve automatisée |
| Multi-canal | Comportements divergents | Invariance garantie |

### 5.2 Recherche d'antériorité

**Patterns explorés :**
- **REST best practices** — Conventions, pas garanties
- **gRPC** — Schéma unique, mais pas de preuve d'invariance
- **GraphQL** — Schéma, mais implémentation variable
- **Hexagonal Architecture** — Ports/adapters, mais pas de vérification

**Conclusion :** Aucun système connu ne fournit de preuve cryptographique d'invariance comportementale entre transports.

---

## 6. Revendications (Claims)

### Revendication principale

**1.** Système de service IA multi-transport comprenant :
- un contrat canonique définissant un schéma de requête et un schéma de réponse ;
- un exécuteur de contrat configuré pour transformer une requête en réponse de manière déterministe ;
- une pluralité d'adaptateurs de transport (CLI, HTTP, WebSocket) configurés pour convertir les formats spécifiques au transport vers et depuis le contrat canonique ;
- un sérialiseur canonique configuré pour produire une représentation JSON déterministe ;
- un module de vérification d'invariance configuré pour prouver que deux transports produisent des réponses identiques.

### Revendications dépendantes

**2.** Système selon la revendication 1, caractérisé en ce que le sérialiseur canonique trie les clés d'objets JSON alphabétiquement.

**3.** Système selon la revendication 1, caractérisé en ce que chaque adaptateur de transport ne contient aucune logique métier, uniquement des conversions de format.

**4.** Système selon la revendication 1, caractérisé en ce que le module de vérification compare les hashs SHA-256 des réponses sérialisées.

**5.** Système selon la revendication 1, caractérisé en ce que le contrat canonique inclut : un intent (query, verify, ingest, explain), un payload, des options, et un identifiant de requête.

**6.** Système selon la revendication 1, caractérisé en ce que la réponse canonique inclut : un status, une confidence, une decision, une proof, et une narrative.

**7.** Méthode pour garantir l'invariance comportementale d'un service IA comprenant les étapes de :
- définir un contrat canonique avec schémas de requête et réponse ;
- implémenter un exécuteur de contrat déterministe ;
- créer des adaptateurs de transport sans logique métier ;
- sérialiser les réponses de manière canonique ;
- vérifier l'égalité des réponses entre transports.

**8.** Méthode selon la revendication 7, caractérisée en ce que la vérification est automatisée via une suite de tests.

**9.** Méthode selon la revendication 7, caractérisée en ce que deux requêtes identiques via des transports différents produisent des réponses bit-à-bit identiques après sérialisation canonique.

**10.** Produit programme d'ordinateur comprenant des instructions qui, lorsqu'exécutées par un processeur, mettent en œuvre le système selon la revendication 1.

---

## 7. Implémentation de référence

### 7.1 Fichiers sources clés

| Fichier | Rôle |
|---------|------|
| `src/ai/sqep_llm/contract.rs` | Définition Request/Response |
| `src/ai/sqep_llm/executor.rs` | ContractExecutor |
| `src/bin/sqepctl.rs` | CLI Transport |
| `src/bin/sqep-http.rs` | HTTP Transport |
| `src/ai/sqep_llm/contract_parity_tests.rs` | Tests d'invariance |

### 7.2 Trait Transport

```rust
/// Abstraction de transport
trait Transport {
    fn execute(&mut self, req: Request) -> Result<Response, TransportError>;
}

/// Transport local (CLI)
struct LocalTransport {
    executor: ContractExecutor,
}

impl Transport for LocalTransport {
    fn execute(&mut self, req: Request) -> Result<Response, TransportError> {
        Ok(self.executor.execute(req))
    }
}

/// Transport HTTP
struct HttpTransport {
    endpoint: String,
}

impl Transport for HttpTransport {
    fn execute(&mut self, req: Request) -> Result<Response, TransportError> {
        let json = serde_json::to_string(&req)?;
        let resp = ureq::post(&self.endpoint)
            .set("Content-Type", "application/json")
            .send_string(&json)?;
        Ok(serde_json::from_str(&resp.into_string()?)?)
    }
}
```

### 7.3 Tests de parité (679 tests)

```rust
#[test]
fn test_parity_query() {
    let req = Request::query("test");
    let local = LocalTransport::new().execute(req.clone());
    let http = HttpTransport::new("localhost:8090").execute(req);
    assert_eq!(canonical(local), canonical(http));
}

#[test]
fn test_parity_verify() { /* ... */ }

#[test]
fn test_parity_ingest() { /* ... */ }

#[test]
fn test_parity_explain() { /* ... */ }

// ... 679 tests au total
```

---

## 8. Applications industrielles

### 8.1 API publiques
- Garantie de cohérence pour les clients
- Documentation fidèle au comportement réel
- Tests automatisés de conformité

### 8.2 Microservices
- Services interchangeables via différents protocoles
- Migration de transport sans régression
- Load balancing multi-protocole

### 8.3 Systèmes embarqués
- Même comportement CLI local et API cloud
- Déploiement edge avec parité cloud
- Tests unifiés cross-plateforme

### 8.4 Conformité et audit
- Preuve que CLI et API font la même chose
- Audit simplifié (un contrat, pas N implémentations)
- Certification unique pour tous les canaux

---

## 9. Avantages techniques

| Avantage | Description |
|----------|-------------|
| **Cohérence** | Même résultat, quel que soit le canal |
| **Testabilité** | Une suite de tests pour tous les transports |
| **Maintenabilité** | Un seul contrat à maintenir |
| **Confiance** | Preuve d'invariance vérifiable |
| **Évolutivité** | Nouveau transport = nouvel adaptateur |
| **Audit** | Un comportement, pas N variations |

---

## 10. Figures (à produire pour le dépôt)

1. **Figure 1** — Architecture générale avec contrat canonique
2. **Figure 2** — Flux de données à travers les adaptateurs
3. **Figure 3** — Processus de sérialisation canonique
4. **Figure 4** — Test d'invariance automatisé
5. **Figure 5** — Comparaison avec architecture traditionnelle

---

## 11. Mots-clés pour classification

- G06F 9/54 — Communication inter-programmes
- H04L 67/02 — Services de communication
- G06F 16/25 — Intégration de données
- G06Q 10/10 — Gestion administrative

---

*Document préparé pour dépôt de brevet — ElevitaX 2026*
