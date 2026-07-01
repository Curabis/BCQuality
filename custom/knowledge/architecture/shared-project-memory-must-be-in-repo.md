---
bc-version: [all]
domain: architecture
keywords: [projectmemory, shared-memory, repo, team-knowledge]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Shared Project Memory Must Be in the Repository

## Description

When Claude learns something relevant to the project — a business rule, an architectural
decision, a known limitation, a scope boundary — that knowledge must be written to the
repository's `projectmemory/` folder, not to the local user memory store
(`~/.claude/projects/.../memory/`).

Local memory is invisible to other team members and disappears when someone works on
a different machine. Version-controlled memory is shared, attributed, and persistent.

## Anti Pattern

    # Stored only on Michael's laptop — Tod and SJG never see this
    ~/.claude/projects/d--MyProject/memory/project-pricing-vat-scope.md

A rule observed by one developer stays siloed. The next session on another machine —
or by another team member — starts from zero.

## Best Practice

    # In the git repository — committed, shared, visible to all
    projectmemory/
      memoryupdates_mid.md   ← Michael's observations
      memoryupdates_tod.md   ← Tod's observations
      memoryupdates_sjg.md   ← SJG's observations

Each file is named after the user who triggered the observation. All files are read
by every team member's Claude session at start, via an instruction in `CLAUDE.md`:

    ## Shared project memory

    At session start, read **all files** in `projectmemory/` — they contain shared
    project observations from all team members and are version-controlled in git.

    When you learn something project-relevant, write it to
    `projectmemory/memoryupdates_<username>.md` for the active user.

    User-specific preferences (tone, workflow habits) stay in the local
    `~/.claude/projects/.../memory/` folder as before.

## What belongs in projectmemory vs local memory

| projectmemory/ (shared, in git) | local memory (personal, not shared) |
|---|---|
| Business rules ("B2B only, no VAT") | User's preferred communication language |
| Architectural decisions and rationale | Workflow habits and preferences |
| Scope boundaries ("IC via ChangeCompany only") | Personal shortcuts or shortcuts |
| Known technical debt and migration status | Role and seniority (already known by the team) |
| Test coverage scope | |
| Company/entity structure | |

## Implementation checklist

- [ ] Create `projectmemory/` folder in repo root
- [ ] Add `projectmemory/**` to `cspell.json` ignorePaths (notes are often in the team's native language)
- [ ] Add the read-at-session-start instruction to `CLAUDE.md`
- [ ] When learning something project-relevant, write to `projectmemory/memoryupdates_<username>.md`
- [ ] Commit and push — knowledge is only shared once it is in git
