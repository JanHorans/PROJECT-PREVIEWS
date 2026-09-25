# ATLAS — Roadmap Preview

## Important context

The private repository baseline was last captured on **2026-08-19** and deliberately focuses on infrastructure stabilization and reproducibility.

The running product has progressed further in some user-facing areas — especially the operational map, dashboard and location-oriented overview — than the older repository roadmap alone suggests.

## Infrastructure roadmap

### Capture current production state
Inventory the running deployment, persistent data, services, networks, volumes, configuration and recovery dependencies.

### Git as source of truth
Normalize deployable configuration and remove undocumented production-only state.

### Reliability / recovery
Add health checks, backups, restore procedures and tested recovery paths.

### Product stabilization
Clarify responsibilities of communication, portal, command, map and identity components and remove unnecessary overlap.

### Security baseline
Review exposed services, proxying, accounts, registration, credential handling and certificate lifecycle.

### ATLAS v1 direction
A stable, recoverable and documented platform combining communication with operational map, command and internal tools that genuinely belong in the shared environment.

## Guiding rule

ATLAS should remain a set of clear operational services rather than absorbing every internal tool into one monolith.
