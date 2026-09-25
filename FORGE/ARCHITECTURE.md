# FORGE — Architecture Preview

## 1. Product boundary

FORGE is not intended to be a replacement for every acquisition or commercial forensic suite.

Its architectural role is to become the **case-level integration and reasoning layer** above multiple evidence sources.

```text
acquisition / export tools
        |
        v
source adapters
        |
        v
FORGE Case Contract
        |
        +--------------------+
        |                    |
        v                    v
deterministic core      knowledge layer
        |                    |
        +---------+----------+
                  |
                  v
            symbolic engine
                  |
                  v
          specialist agents
                  |
                  v
          local neural model
                  |
                  v
           neural proposals
                  |
                  v
           validation gates
                  |
                  v
         investigator views
```

The important architectural decision is that AI sits **inside** the analysis pipeline rather than above the entire application as an unrestricted chatbot.

## 2. Source verticals

Current and planned evidence verticals include:

- CaseCapture / Windows acquisition;
- mobile extraction;
- e-mail and mail headers;
- saved HTML and web artifacts;
- browser exports;
- network logs / PCAP;
- APK / application artifacts;
- generic structured logs;
- OSINT enrichment.

Each source family should terminate in the same typed case contract.

That means a new parser or collector should not require the entire application to understand its native output format.

## 3. FORGE Case Contract

The Case Contract is the interoperability boundary.

Conceptually it contains typed objects such as:

```text
CASE
SOURCE
EVIDENCE
ENTITY
EVENT
RELATION
FINDING
CLAIM
PROVENANCE
```

The purpose is not merely schema neatness. It gives downstream components a stable language for:

- integrity;
- chronology;
- source identity;
- evidence references;
- relationships;
- epistemic state;
- reproducible analysis.

## 4. Deterministic core

The deterministic layer handles operations that should be reproducible:

- source verification;
- normalization;
- timestamp semantics;
- indexing;
- deduplication where rules permit it;
- typed projection;
- explicit relation handling;
- bounded correlation.

The guiding rule is that facts that can be derived deterministically should not be delegated to a language model.

## 5. Symbolic layer

Symbolic rules express bounded domain knowledge.

Examples include:

- whether a stronger deterministic finding safely implies a weaker statement;
- which evidence combinations are sufficient for a particular bounded finding;
- contradictions between claims;
- conditions under which a proposal must remain uncertain.

This is where FORGE becomes genuinely neuro-symbolic rather than “an LLM with prompts”.

## 6. Local intelligence layer

The neural model is treated as an analytical component.

It may:

- propose connections worth review;
- summarize already selected case objects;
- propose hypotheses;
- help classify or prioritize analytical questions.

It may not:

- rewrite source evidence;
- promote its own proposal to fact;
- hide uncertainty;
- create causal or attribution claims without support.

The runtime is local-first and intended to travel with the portable workstation.

## 7. Specialist-agent model

The architecture reserves bounded specialist roles such as:

- Timeline;
- Remote Access;
- Browser/Web;
- Mail;
- Phone;
- IOC/Infrastructure;
- Identity;
- Correlation;
- Contradiction;
- OSINT;
- Report.

An agent receives typed case objects and bounded tools.

A conceptual output looks like:

```json
{
  "agent": "remote-access",
  "authority": "neural_proposal",
  "proposal_type": "possible_related_sequence",
  "supporting_ids": ["event:...", "evidence:..."],
  "contradicting_ids": [],
  "requires_validation": true
}
```

The important part is not the JSON syntax; it is that the proposal explicitly identifies its authority and evidence backreferences.

## 8. Validation and publication

Accepted analytical output is not simply whatever the model returned.

The intended path is:

```text
proposal
  -> literal / structural checks
  -> authority checks
  -> contradiction checks
  -> evidence backreference validation
  -> claim-boundary validation
  -> publish or reject
```

Incomplete or malformed neural output fails closed rather than being silently published.

## 9. Investigator-facing views

Current implemented views share the same verified case material:

```text
Timeline
Entities / Relations
Findings / Hypotheses / Unknowns
Smart Case Search
Human-readable Report
Protocol Draft
```

A view should not invent new facts merely because it renders existing objects differently.

## 10. Portability boundary

The target deployment is an external-drive workstation.

The operator should not need:

- a separate Python installation;
- a separate backend checkout;
- a system-wide model runtime;
- cloud access for core analysis.

Machine capability detection, local model loading and safe analysis budgets belong to the application/runtime boundary.
