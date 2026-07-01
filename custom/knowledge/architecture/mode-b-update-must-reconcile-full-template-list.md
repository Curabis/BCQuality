---
bc-version: [all]
domain: architecture
keywords: [mode-b, curabis-standard, auto-update, agents, template-reconciliation, setup]
technologies: [al]
countries: [w1]
application-area: [all]
---

## Description

Mode B updates ("Opdater CURABIS Standard fra BCQuality") are meant to keep a
project's `.github/.agents/` directory in sync with BCQuality's template list
in `curabis-standard.agent.md`. In practice, an update can run, correctly bump
the stored BCQuality SHA, and still leave a brand-new template file uninstalled
— because the update only touched files that were already present locally and
had changed upstream, rather than reconciling against the full template list.

This was observed when a new agent template was added to BCQuality's Mode B
template table and two subsequent Mode B runs (each correctly advancing the
stored SHA) both skipped installing it. Each run only modified files that
already existed locally — neither run compared the full Mode B template table
against what was actually present in `.github/.agents/`.

## Rule

Every time Mode B executes (auto-update or manual "Opdater CURABIS Standard"),
Claude must diff the **complete** template file list from `curabis-standard.agent.md`
against the files present in `.github/.agents/` — not just the files that changed
in this update. Any template file missing locally must be fetched and installed
before the update is considered complete.

## What NOT to do

- Do not treat a successful SHA bump as proof that all templates are installed
- Do not limit the update to files that already exist locally and were flagged as changed
- Do not assume a template file is optional just because it wasn't part of the diff
- Do not close out a Mode B run without an explicit reconciliation pass

## Signal to watch for

After any Mode B run, compare the list of files in `curabis-standard.agent.md`'s
Mode B template table against:

```
Get-ChildItem .github/.agents/*.agent.md | Select-Object -ExpandProperty BaseName
```

Any template file present in the table but absent from the directory is a gap —
install it, then surface it per `claude-md-must-reference-all-agents.md` if it
also needs a CLAUDE.md reference.

## Message to developer

When a reconciliation gap is found, output exactly this before continuing:

```
⚠️ Mode B kørte, men følgende template-fil(er) blev ikke installeret:

  - <agent-navn>.agent.md

Vil du have mig til at installere den/dem nu?
```

Do not continue with other activity until the developer has responded.
