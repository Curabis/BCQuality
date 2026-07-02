---
bc-version: [all]
domain: architecture
keywords: [agents, repo-local, divergence, regelsanity, court, governance, universalization]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Repo-local agents and rules must be universalized or removed

## Description

CURABIS repos must behave identically. A developer who adds an agent or a
quality rule directly to one repo's `.github/.agents/` (instead of proposing
it for BCQuality) creates silent divergence: that repo reviews, routes, or
behaves differently from every other repo, and the improvement — if it is one
— never reaches the rest of the portfolio.

This happened in practice: `edison.agent.md` was created locally in one repo.
It was invisible to all other repos for weeks, while `court.agent.md`
(deployed everywhere) declared a hard dependency on Edison's scorecards — a
dependency no other repo could satisfy. The agent was good; the placement
made it a liability.

Repo-specific agents and quality rules do not produce better quality. They
produce N repos with N behaviours. Domain-specific knowledge (business rules,
scope, customer context) belongs in `projectmemory/` and `docs/specs/` —
process and quality standards belong in BCQuality, or nowhere.

## Rule

Any agent file or quality/process rule found in a repo that is not part of
the BCQuality-deployed set has exactly two futures, and silence is not one
of them:

1. **Universalize** — route it through the governance pipeline: Francis files
   the observation, Immanuel universalizes, Michael merges to BCQuality, the
   next stable promote deploys it to every repo. If the addition raises a
   portfolio-level question (overlap with existing agents, structural change),
   the Court hears it as a RegelSanity case — no Edison scorecards required
   for divergence cases; the file itself and the question "universal or out?"
   suffice.
2. **Remove** — if it does not generalize, it does not belong in the repo.

Detection is Mode B's job: reconciliation must flag files present in
`.github/.agents/` that are NOT in the setup template list — extras, not just
missing files.

## What NOT to do

- Do not keep a locally added agent because it is useful — usefulness is the
  argument FOR universalizing it, not for keeping it private
- Do not delete a local agent without the routing step; it may be the best
  idea in the portfolio (Edison was)
- Do not put quality or process rules in a project's CLAUDE.md or
  projectmemory/ to avoid the governance pipeline
- Do not treat this as bureaucracy — one promote deploys to every repo;
  universalizing is cheaper than maintaining a private fork of the standard

## Signal to watch for

During Mode B or at session start: a file in `.github/.agents/` whose name
does not appear in the setup template table in `curabis-standard.agent.md`.

## Message to developer

When a repo-local agent or rule is found, tell the developer: this repo
carries a local agent/rule that no other CURABIS repo has; per RegelSanity it
must either be proposed for BCQuality (offer to route it to Francis and
Immanuel now) or removed — and ask which of the two they want.
