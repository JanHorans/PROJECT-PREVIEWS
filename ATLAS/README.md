# ATLAS — Technical Preview

## What it is

ATLAS is a self-hosted internal communication and operational coordination platform.

It began as an internally controlled alternative to consumer messaging tools and grew into an operational workspace combining communication, mapping, location-oriented situational overview and command functions.

## Core domains

```text
ATLAS
├── Communication
│   └── Matrix Synapse + Element
├── Portal
│   └── common user entry point
├── Command
│   └── operational coordination
├── Map
│   └── operational map + tile services
├── Dashboard
│   └── operational / location-oriented overview
└── Identity
    └── users, roles, onboarding / offboarding
```

## Simplified architecture

```text
Users
  |
  v
HTTPS / reverse proxy
  |
  +----------------------+----------------------+------------------+
  |                      |                      |                  |
  v                      v                      v                  v
Portal               Element Web           Command              Map
                         |                                       |
                         v                                       v
                    Matrix Synapse                         Tile services
                         |
                         v
                     PostgreSQL
```

See [STRUCTURE.md](STRUCTURE.md) and [ROADMAP.md](ROADMAP.md).
