# ATLAS — Simplified Structure

The private ATLAS-Core repository currently centers on infrastructure and product documentation:

```text
ATLAS-Core/
├── README.md
├── ARCHITECTURE.md
├── ROADMAP.md
├── STATE.md
└── docs/
    └── MIGRATION.md
```

## Technical boundaries

### Communication
Matrix Synapse + Element provide the communication layer, with PostgreSQL persistence.

### Portal
Common entry point into the internal platform.

### Command
Operational coordination and command-oriented workflows.

### Map / dashboard
Operational mapping, tile services and location-oriented situational overview.

### Identity
Accounts, roles, onboarding and offboarding.

### Infrastructure principle
Git should describe reproducible configuration and recovery procedures, while runtime databases, message history, media, secrets and private keys remain outside Git.
