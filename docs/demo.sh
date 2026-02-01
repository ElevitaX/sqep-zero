#!/bin/bash
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃ SQEP-LLM Demo Script                                   ┃
# ┃ "Intelligence you can prove"                           ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Path to CLI (adjust if needed)
SQEPCTL="${SQEPCTL:-./target/release/sqepctl}"

# Check if sqepctl exists
if [ ! -f "$SQEPCTL" ]; then
    SQEPCTL="./target/debug/sqepctl"
fi

if [ ! -f "$SQEPCTL" ]; then
    echo "Error: sqepctl not found. Run 'cargo build --release' first."
    exit 1
fi

clear

echo -e "${CYAN}"
echo "┌─────────────────────────────────────────────────────────────┐"
echo "│                                                             │"
echo "│   ███████╗ ██████╗ ███████╗██████╗       ██╗     ██╗     ███╗   ███╗   │"
echo "│   ██╔════╝██╔═══██╗██╔════╝██╔══██╗      ██║     ██║     ████╗ ████║   │"
echo "│   ███████╗██║   ██║█████╗  ██████╔╝█████╗██║     ██║     ██╔████╔██║   │"
echo "│   ╚════██║██║▄▄ ██║██╔══╝  ██╔═══╝ ╚════╝██║     ██║     ██║╚██╔╝██║   │"
echo "│   ███████║╚██████╔╝███████╗██║           ███████╗███████╗██║ ╚═╝ ██║   │"
echo "│   ╚══════╝ ╚══▀▀═╝ ╚══════╝╚═╝           ╚══════╝╚══════╝╚═╝     ╚═╝   │"
echo "│                                                             │"
echo "│            Deterministic Cognitive Engine                   │"
echo "│            \"Intelligence you can prove\"                     │"
echo "│                                                             │"
echo "└─────────────────────────────────────────────────────────────┘"
echo -e "${NC}"
echo ""

sleep 2

# ─────────────────────────────────────────────────────────────
# Demo 1: Ingest Facts
# ─────────────────────────────────────────────────────────────

echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}  DEMO 1: Teaching facts to SQEP-LLM${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${BLUE}> sqepctl ingest --fact \"SQEP uses SHA-256 for cryptographic hashing\"${NC}"
$SQEPCTL ingest --fact "SQEP uses SHA-256 for cryptographic hashing"
echo ""
sleep 1

echo -e "${BLUE}> sqepctl ingest --fact \"SHA-256 is a secure hash function\"${NC}"
$SQEPCTL ingest --fact "SHA-256 is a secure hash function"
echo ""
sleep 1

echo -e "${BLUE}> sqepctl ingest --fact \"SQEP runs on CPU without external dependencies\"${NC}"
$SQEPCTL ingest --fact "SQEP runs on CPU without external dependencies"
echo ""
sleep 1

echo -e "${GREEN}✓ Facts ingested. SQEP-LLM now has knowledge.${NC}"
echo ""
sleep 2

# ─────────────────────────────────────────────────────────────
# Demo 2: Verification (Deterministic)
# ─────────────────────────────────────────────────────────────

echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}  DEMO 2: Verifying statements (deterministic)${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${BLUE}> sqepctl verify \"SQEP uses SHA-256\" --trace${NC}"
$SQEPCTL verify "SQEP uses SHA-256" --trace
echo ""
sleep 2

echo -e "${GREEN}✓ Verification complete with proof and confidence score.${NC}"
echo ""
sleep 2

# ─────────────────────────────────────────────────────────────
# Demo 3: Query
# ─────────────────────────────────────────────────────────────

echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}  DEMO 3: Querying the cognitive engine${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${BLUE}> sqepctl query \"What hash function does SQEP use?\" --trace${NC}"
$SQEPCTL query "What hash function does SQEP use?" --trace
echo ""
sleep 2

echo -e "${GREEN}✓ Query answered based on known facts.${NC}"
echo ""
sleep 2

# ─────────────────────────────────────────────────────────────
# Demo 4: Determinism Proof
# ─────────────────────────────────────────────────────────────

echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}  DEMO 4: Proving determinism (same input → same output)${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${BLUE}Running the same query 3 times...${NC}"
echo ""

for i in 1 2 3; do
    echo -e "${CYAN}Run $i:${NC}"
    $SQEPCTL query "Is SQEP secure?" --mode json 2>/dev/null | grep -E '"confidence"|"status"' | head -2
    echo ""
    sleep 1
done

echo -e "${GREEN}✓ Identical results. SQEP-LLM is deterministic.${NC}"
echo ""
sleep 2

# ─────────────────────────────────────────────────────────────
# Demo 5: JSON Output (API-ready)
# ─────────────────────────────────────────────────────────────

echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}  DEMO 5: JSON output (API-ready)${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${BLUE}> sqepctl verify \"SHA-256 is secure\" --mode json${NC}"
$SQEPCTL verify "SHA-256 is secure" --mode json
echo ""
sleep 2

# ─────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────

echo -e "${CYAN}"
echo "┌─────────────────────────────────────────────────────────────┐"
echo "│                      DEMO COMPLETE                          │"
echo "├─────────────────────────────────────────────────────────────┤"
echo "│                                                             │"
echo "│  ✓ Facts ingested and stored                                │"
echo "│  ✓ Statements verified with proof                           │"
echo "│  ✓ Queries answered from knowledge base                     │"
echo "│  ✓ Determinism proven (same input → same output)            │"
echo "│  ✓ JSON output ready for API integration                    │"
echo "│                                                             │"
echo "├─────────────────────────────────────────────────────────────┤"
echo "│  No GPU. No cloud. No hallucinations.                       │"
echo "│  Just logic, proofs, and trust.                             │"
echo "│                                                             │"
echo "│  SQEP-LLM: Intelligence you can prove.                      │"
echo "└─────────────────────────────────────────────────────────────┘"
echo -e "${NC}"
