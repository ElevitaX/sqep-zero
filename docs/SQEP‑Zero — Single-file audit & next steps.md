# SQEP‑Zero — Single-file audit & next steps

## Purpose

A single, shareable file to: 1) record test results and red flags, 2) provide a lightweight checklist for reviewers, and 3) capture prioritized next actions for finishing PhotonMUX and related subsystems.

---

## How to use this file

* Save it alongside your project export (PDF/zip).
* Use the **Test log** section to paste terminal output, timestamps, and short descriptions of each test run.
* Use the **Reviewer notes** block for an external reviewer or teammate to add their findings.
* Mark items `OPEN`, `IN PROGRESS`, or `DONE` in the Action list.

---

## 1) Quick metadata

* Project: SQEP‑Zero / LevitaX
* Export filename: `Project Export — sqep-zero.pdf` (adjust if different)
* Created: {{DATE}}
* Author / Owner: (add owner name)

---

## 2) Test log (template)

* **Test ID:** TL-001
* **Date / Time:**
* **Environment:** (OS, node/tauri/rust versions, QPU attached? local/remote)
* **Input:** (file used, password/hint, API endpoint)
* **Expected:** (e.g., file decrypts cleanly, no leakage)
* **Actual:** (paste output)
* **Notes / Next steps:**

> Repeat entries for each discrete test. Keep raw outputs below the entry or attach as separate text files.

---

## 3) Red flags / security checks (check each, add details)

* [ ] Passwords reused or weak entropy indicated in logs
* [ ] Secrets accidentally committed (look for base64 private keys / PEM blocks)
* [ ] Unhandled exceptions that reveal stack traces or file paths in logs
* [ ] Unsafe temporary files written to world-readable locations
* [ ] Insecure default config values (e.g., debug=true, permissive CORS)
* [ ] Crypto pitfalls: reused IVs, custom crypto construction, homegrown KDFs
* [ ] Permissions: files owned by root or wrong user on deployment
* [ ] Network: plaintext fallback endpoints, telemetry endpoints not documented
* [ ] Third-party libs with known CVEs (list and pin versions)

*For each checked item, paste evidence (log lines, file paths, code snippet) and recommended remediation.*

---

## 4) Functional checks (short list)

* Encryption / decryption round-trip using sample files of different types (text, image, zip).
* Refusal behavior on unsupported file types (confirm behavior and error codes).
* Performance: time to encrypt/decrypt standard sample (measure and record).
* Integration: local AI ↔ server AI switching (test endpoints and sample conversation exchange).

---

## 5) PhotonMUX — prioritized next steps (draft)

1. **Interface contract** — define the input/output message schema for PhotonMUX (JSON schema). Include fields for `source_id`, `timestamp`, `payload_type`, `encoding`, `signature`, `routing_hint`.
2. **Encryption envelope** — choose an envelope format (e.g., AES‑GCM for content + RSA/ECDH for key exchange). Document KDF, nonce/IV handling, and key rotation plan.
3. **Transport** — decide transport layer(s): WebSocket for low-latency, fallback HTTPS chunked upload for constrained networks.
4. **Compression & AI augmentation** — define optional preprocessor hooks for AI-based perceptual compression (configurable per-filetype).
5. **Authentication & peer‑to‑peer linking** — token / mTLS / short‑lived API keys for server-mediated connections and direct API URLs for friend-to-friend connections.
6. **Failure modes & safety** — document graceful degradation, refuse-open policy for unknown file types, and logging sanitization.
7. **Test harness** — minimal harness that runs round-trip tests with mocked peers, measures latency, and checks for data leakage.

---

## 6) Reviewer checklist (for each PR / export)

* [ ] Export includes only intended artifacts
* [ ] No credentials or private keys in export
* [ ] Repro steps provided and validated
* [ ] Minimal harness included to verify encryption/decryption
* [ ] Build instructions and runtime env documented (versions)

---

## 7) Suggested single-file format options

* **Markdown README** (simple, human-editable) — recommended.
* **TOML/JSON manifest + logs/** (machine-parseable)
* **Combined**: `README.md` + `audit.json` in zip for tooling.

---

## 8) Immediate next actions (suggested, ordered)

1. Populate the *Test log* with the most recent successful run (include exact command lines and output).
2. Run the Red flags checklist against the export (grep for `BEGIN RSA PRIVATE KEY`, `BEGIN PRIVATE KEY`, `-----BEGIN`, `aws_secret`, `.env` patterns).
3. Draft PhotonMUX JSON schema and paste it in the file under a `PhotonMUX` heading.
4. Create a small test harness (Node / Rust / Tauri) that performs: encrypt → send (local) → receive → decrypt and logs timings.
5. Share this single-file export with one trusted reviewer (use friend API URL approach you described) and have them fill the Reviewer notes.

---

## 9) Notes / context (scratchpad)

* This file is intentionally compact so it can live alongside the export and be the authoritative audit artifact.
* If you want, I can next generate:

  * a PhotonMUX JSON schema draft, or
  * a small Node-based test harness (single-file) to run the round-trip tests.

---

*End of document.*

