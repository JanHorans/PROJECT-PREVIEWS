# PROJECT PREVIEWS

Public technical previews of three independent internal projects.

This repository is documentation-only. It contains no private source code, credentials, production data or case material.

## How to read this repository

The three projects solve different problems and should be reviewed independently.

### FORGE

Portable local-first neuro-symbolic digital-forensics workstation.

Recommended reading:

1. [FORGE/README.md](FORGE/README.md) — product overview
2. [FORGE/ARCHITECTURE.md](FORGE/ARCHITECTURE.md) — deeper architecture
3. [FORGE/STRUCTURE.md](FORGE/STRUCTURE.md) — repository shape
4. [FORGE/ROADMAP.md](FORGE/ROADMAP.md) — current direction
5. [FORGE/DETAILS.md](FORGE/DETAILS.md) — compact technical notes

Main engineering themes: typed case contracts, provenance, deterministic processing before model-assisted analysis, explicit authority layers, local runtime portability and bounded investigator views.

### REPORT BUILDER

Portable Windows analytical helper for structured data, timelines, network-address enrichment and standalone exports.

Recommended reading:

1. [REPORT-BUILDER/README.md](REPORT-BUILDER/README.md)
2. [REPORT-BUILDER/TECHNICAL_DETAILS.md](REPORT-BUILDER/TECHNICAL_DETAILS.md)
3. [REPORT-BUILDER/STRUCTURE.md](REPORT-BUILDER/STRUCTURE.md)
4. [REPORT-BUILDER/ROADMAP.md](REPORT-BUILDER/ROADMAP.md)

Main engineering themes: local-first parsing, deterministic analysis, module independence, traceable enrichment and portable standalone output.

### ATLAS

Self-hosted internal communication and coordination platform.

Recommended reading:

1. [ATLAS/README.md](ATLAS/README.md)
2. [ATLAS/STRUCTURE.md](ATLAS/STRUCTURE.md)
3. [ATLAS/ROADMAP.md](ATLAS/ROADMAP.md)

Main engineering themes: separation of communication and structured shared state, clear service responsibilities, reproducible deployment and recovery-oriented infrastructure.

## Review mindset

These previews are not product marketing. They are intentionally written so another technical person can inspect:

- what problem each project is trying to solve;
- where the architectural boundaries are;
- which parts already exist;
- what remains experimental;
- which technical trade-offs are deliberate;
- where criticism or alternative designs would be useful.

_Last preview refresh: 2026-09-25._
