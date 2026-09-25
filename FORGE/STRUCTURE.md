# FORGE — Simplified Structure

The private repository is organized roughly as:

```text
FORGE/
├── app/          application shell / UI-facing code
├── components/   product components
├── contracts/    typed contracts and schemas
├── docs/         architecture and feature specifications
├── forge/        core implementation
├── registry/     registries / structured definitions
├── tests/        regression and acceptance tests
├── tools/        support tooling
├── README.md
└── ROADMAP.md
```

## Architectural boundaries

### Sources / collectors
External collectors remain independently useful and communicate with FORGE through explicit contracts.

### Deterministic core
Parsing, normalization, integrity, time semantics and reproducible transformations occur before neural interpretation.

### Symbolic / validation layer
Rules, contradiction checks and claim gates constrain what can become an accepted finding.

### Local intelligence
Local models and specialist agents operate over typed objects and emit proposals with provenance rather than silently rewriting the evidence model.

### Investigator views
Timeline, entities/relations, findings/hypotheses, reports and protocol drafts are views over the same typed and verified case material.
