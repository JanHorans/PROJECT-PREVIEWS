# FORGE — Technical Preview

## What it is

FORGE is a portable, local-first, neuro-symbolic digital-forensics workstation.

The goal is to unify heterogeneous digital evidence into one typed case model, preserve provenance, correlate events and entities, and produce investigator-readable output without allowing AI proposals to silently become facts.

```text
SOURCES
  CaseCapture / mobile extraction / mail / web artifacts / logs / PCAP / OSINT / future adapters
      |
      v
FORGE CASE CONTRACT
      |
      v
DETERMINISTIC + SYMBOLIC CORE
      |
      v
LOCAL INTELLIGENCE ENGINE
      |
      v
VALIDATION
      |
      v
INVESTIGATOR OUTPUT
  timeline / relations / findings / hypotheses / unknowns / report / protocol draft
```

## Authority model

FORGE keeps these layers distinct:

1. source evidence;
2. deterministic derived data;
3. symbolic findings;
4. neural proposals;
5. validated findings;
6. external context.

A neural proposal is never authoritative by itself.

## Current implemented path

The private development repository currently implements a workstation flow covering:

- New / Open Case;
- a shared FORGE Case Contract;
- CaseCapture import;
- mobile-source import;
- immutable and verified source copies;
- local AI runtime integration;
- Analyze Case orchestration;
- Unified Timeline v1;
- Entities / Relations v1;
- Findings / Hypotheses / Unknowns v1;
- Human-readable Report v1;
- Protocol Draft v1;
- Smart Case Search v1.

Smart Case Search is intentionally deterministic and read-only. It returns typed case objects with source/evidence backreferences instead of generating a free-form factual answer.

## Suggested technical review

See also:

- [ARCHITECTURE.md](ARCHITECTURE.md) — deeper system architecture and layer boundaries
- [DETAILS.md](DETAILS.md) — compact implementation-oriented notes
- [STRUCTURE.md](STRUCTURE.md) — repository shape
- [ROADMAP.md](ROADMAP.md) — current direction and maturity

The most interesting engineering questions are provenance preservation, epistemic separation, local-AI validation, portability and contract-first integration.
