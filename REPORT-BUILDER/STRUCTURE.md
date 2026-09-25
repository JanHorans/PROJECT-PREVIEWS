# REPORT BUILDER — Simplified Structure

The private repository intentionally has a small surface:

```text
REPORT-BUILDER/
├── README.md
├── VERSION
└── releases/
    └── stable source snapshot(s)
```

The approved stable source snapshot is stored with a recorded SHA-256 so a known baseline can be reproduced and audited.

## Design priorities

- local-first parsing;
- deterministic transformation where practical;
- traceable external enrichment;
- portable Windows operation;
- standalone reviewable output;
- narrow modules rather than a monolithic case platform.
