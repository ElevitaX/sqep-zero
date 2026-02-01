# SQEP-Zero

**Le Standard Universel de Preuve Cryptographique des Actions Numériques**

> *"Chaque action sur vos données mérite un reçu."*

[![Standard](https://img.shields.io/badge/Standard-v1.0%20Figé-blue)](docs/SQEP-ZERO-WHITEPAPER.md)
[![License](https://img.shields.io/badge/License-MIT-green)](#license)
[![Rust](https://img.shields.io/badge/Rust-1.75+-orange)](https://www.rust-lang.org/)
[![Tests](https://img.shields.io/badge/Tests-679%20passants-brightgreen)](#)

---

## Qu'est-ce que SQEP-Zero ?

**SQEP-Zero** (Secure Quantum Encryption Protocol — Zero) est un standard cryptographique ouvert qui permet à quiconque de **prouver** — pas seulement affirmer — qu'une action numérique a eu lieu.

```
┌──────────────────────────────────────┐
│           REÇU SQEP                  │
├──────────────────────────────────────┤
│  Action:     FILE_ENCRYPTED          │
│  Timestamp:  2026-01-31T10:30:00Z    │
│  Hash:       7c8d1e2f3a4b5c6d...     │
│  Hash préc:  858a81309f473dac...     │
└──────────────────────────────────────┘
```

**Innovation clé :** On hash l'*action*, pas les données — preuve sans exposition.

---

## Le Problème

Les entreprises font des promesses sur leurs données :
- "Vos données sont chiffrées"
- "Nous respectons le RGPD"
- "Notre IA est transparente"

**Mais elles ne peuvent pas le prouver.**

Les logs traditionnels peuvent être modifiés. Les pistes d'audit peuvent être supprimées. La confiance est requise.

**SQEP-Zero change la donne.** Chaque action génère un reçu cryptographique, lié dans une chaîne immuable. N'importe qui peut vérifier — pas besoin de confiance, juste des mathématiques.

---

## Le Standard (10 Principes)

1. **SQEP-Zero** est un standard cryptographique ouvert pour produire des preuves vérifiables d'actions numériques.
2. Un **Reçu** (Receipt) est un enregistrement cryptographique prouvant qu'une action spécifique a eu lieu sur des données.
3. Chaque Reçu contient : type d'action, horodatage, référence acteur, référence objet, et un hash SHA-256.
4. La **HashChain** lie chaque Reçu au précédent via `previous_hash`, formant une chaîne immuable.
5. Le **Genesis Receipt** est l'origine de toute HashChain — il n'a pas de prédécesseur.
6. L'intégrité de la chaîne est vérifiée en recalculant tous les hashs séquentiellement du Genesis à la tête.
7. SQEP-Zero hash les **actions**, jamais les données brutes — garantissant confidentialité, universalité et conformité RGPD.
8. La vérification est publique et ne requiert aucune confiance en l'émetteur — seulement la chaîne mathématique.
9. Le standard est **agnostique au cas d'usage** : fichiers, décisions IA, conformité, preuve légale, ou tout domaine.
10. **Chaque action sur vos données mérite un reçu.**

### Principe Fondamental

> **"La sécurité est une promesse. La preuve est un fait."**

---

## Bloc Genesis

Le standard SQEP-Zero a été figé le 31 janvier 2026.

```
Hash:       858a81309f473dacc70e4a94b21a09a6d56241ae810ee6b9308e6a49d00038b7
Tag:        CHAIN_GENESIS
Autorité:   ElevitaX
Chain ID:   SQEP-ELEVITAX-PROD-V1
Status:     FIGÉ (immuable)
```

---

## Démarrage Rapide

### Vérifier la Chaîne

```bash
curl -s http://localhost:8080/v1/journal/verify | jq
```

```json
{
  "valid": true,
  "entries": 342
}
```

### Ajouter un Reçu

```bash
curl -X POST http://localhost:8080/v1/journal/append \
  -H "Content-Type: application/json" \
  -d '{"tag": "FILE_ENCRYPTED", "message": "file_id=doc-001 algo=AES-256-GCM"}'
```

### Obtenir la Tête de Chaîne

```bash
curl -s http://localhost:8080/v1/journal/head | jq
```

---

## Points d'API

| Endpoint | Méthode | Description |
|----------|---------|-------------|
| `/v1/journal/append` | POST | Ajouter un nouveau Reçu |
| `/v1/journal/verify` | GET | Vérifier toute la chaîne |
| `/v1/journal/head` | GET | Obtenir le hash du dernier Reçu |
| `/v1/journal/tail?n=10` | GET | Obtenir les N derniers Reçus |
| `/v1/journal/healthz` | GET | Vérification de santé |

---

## Cas d'Usage

### Conformité RGPD
Chaque accès, modification ou suppression de données génère un Reçu. Prouvez la conformité mathématiquement.

### Traçabilité IA
Chaque décision IA génère un Reçu liant entrée, modèle et sortie. Explicabilité par conception.

### Intégrité Documentaire
Hashage des documents à la création, chaînage du Reçu. Toute modification est détectable.

### Audit Financier
Les logs de transactions deviennent inviolables. Les auditeurs vérifient les maths, pas la confiance.

### Chaîne d'Approvisionnement
Chaque transfert génère un Reçu. Provenance vérifiée de bout en bout.

---

## Pourquoi pas Blockchain ?

| Aspect | Blockchain | SQEP-Zero |
|--------|------------|-----------|
| Consensus requis | Oui | Non |
| Crypto-monnaie | Souvent | Non |
| Latence | Minutes-heures | Millisecondes |
| Énergie | Élevée | Minimale |
| Fonctionnement offline | Non | Oui |
| Complexité | Haute | Faible |

**SQEP-Zero est conçu pour la souveraineté organisationnelle** — vous contrôlez votre chaîne.

---

## Spécifications Techniques

| Métrique | Valeur |
|----------|--------|
| Langage | Rust |
| Algorithme de hash | SHA-256 |
| Format de stockage | JSONL |
| Taille binaire | ~15 Mo |
| Mémoire | < 50 Mo |
| LLM externe | Non requis |
| GPU | Non requis |
| Offline | Oui |
| Plateformes | Linux, Windows, macOS, ARM, Android |

---

## Compilation

```bash
# Cloner
git clone https://github.com/ElevitaX/sqep-zero.git
cd sqep-zero

# Compiler (toutes les fonctionnalités)
cargo build --release --features "api ed25519 hash-sha256 qpu-entropy"

# Lancer
./target/release/sqep-zero

# Tester
cargo test
```

---

## Documentation

| Document | Description |
|----------|-------------|
| [Whitepaper (Technique)](docs/SQEP-ZERO-WHITEPAPER.md) | Spécification technique complète |
| [Whitepaper (Investisseurs)](docs/SQEP-ZERO-WHITEPAPER-INVESTORS.md) | Business case et marché |
| [Pitch Deck](docs/SQEP-ZERO-PITCH-DECK.md) | Diapositives de présentation |

---

## État du Projet

- [x] HashChain v1.0 — **FIGÉ**
- [x] Genesis Receipt — **CRÉÉ**
- [x] API de Vérification Publique — **EN LIGNE**
- [x] 679 Tests — **PASSANTS**
- [ ] SDK (JavaScript) — Prévu Q3 2026
- [ ] SDK (Python) — Prévu Q3 2026
- [ ] Ancrage multi-chaînes — Feuille de route

---

## Contribuer

SQEP-Zero est un standard ouvert. Contributions bienvenues :

1. Forker le dépôt
2. Créer une branche de fonctionnalité
3. Soumettre une pull request

Veuillez lire la spécification du standard avant de contribuer.

---

## Licence

Licence MIT — Voir [LICENSE](LICENSE)

Le standard SQEP-Zero est ouvert et libre d'implémentation.

---

## À Propos d'ElevitaX

**ElevitaX** est le créateur et l'implémentation de référence de SQEP-Zero.

Nous croyons que dans un monde de promesses numériques, **la preuve est la seule monnaie qui compte**.

---

## Contact

- **Organisation :** ElevitaX
- **Standard :** SQEP-Zero v1.0
- **Genesis :** `858a81309f473dacc70e4a94b21a09a6d56241ae810ee6b9308e6a49d00038b7`

---

> **"La sécurité est une promesse. La preuve est un fait."**
