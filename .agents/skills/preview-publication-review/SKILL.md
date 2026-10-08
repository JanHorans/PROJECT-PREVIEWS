---
name: preview-publication-review
description: Review PROJECT-PREVIEWS public documentation for accuracy, scope claims and disclosure safety before publishing a refreshed technical preview.
---

# PROJECT-PREVIEWS: preview-publication-review

Activate only when this kind of project review is requested. Do not run autonomously.

## Source of truth
- First follow any applicable `AGENTS.md` and `CLAUDE.md` and then read: README.md; the target project's preview README, ARCHITECTURE, STRUCTURE, ROADMAP and DETAILS files actually present.
- Identify branch/revision, current documented stage and exact change under review.
- Never conflate roadmap, fixture, asserted history and verified operational evidence.

## Review checklist
- Evaluate: separate FORGE, Report Builder and ATLAS scope; claims of implementation versus roadmap; freshness dates; source/provenance consistency; no private details or internal-only assumptions; third-party attribution.
- Report `PASS / FAIL / UNKNOWN / NOT RUN` per relevant gate, with specific evidence and limitations.
- If local offline tests are documented and safe, propose or run them only when permissions and environment permit; never invent evidence or install dependencies silently.
- Give prioritized blockers and one safe next action; separate recommendation from permission to execute.

## Safety
Documentation-only public repository. Never copy private source, production URLs, secrets, internal infrastructure details, customer data or real forensic evidence into previews. Do not push public material without separate review.
- Do not access production or reveal/export secrets and personal data.
- Never merge, deploy, publish, tag or make irreversible changes from this review skill.
- Repository policy always takes precedence over this optional procedure.
