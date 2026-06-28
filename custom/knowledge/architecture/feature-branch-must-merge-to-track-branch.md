---
name: feature-branch-must-merge-to-track-branch
title: Feature branches must merge into the project's declared track branch
category: architecture
severity: required
---

# Feature branches must merge into the project's declared track branch

## Rule

When a project declares a track branch in `CLAUDE.md`, all feature branches
MUST merge into that track branch — not into `main` directly. `main` is
reserved for releases and hotfixes.

## Track branch declaration

The track branch is declared once in `CLAUDE.md`:

```yaml
# Declares the integration target for this development sprint/module
trackBranch: purchase
```

If no `trackBranch` is declared, `main` is the default and feature branches
merge there directly.

## Why

In multi-module or multi-sprint projects, a named track branch acts as an
integration buffer:

| Without track branch | With track branch |
|---|---|
| Every feature branch merges to `main` | Features collect on track branch |
| `main` accumulates partial, in-flight work | `main` stays clean for hotfixes |
| A hotfix requires reverting or cherry-picking | A hotfix branches from `main` unaffected |

The rule protects the invariant: **`main` is deployable at any moment.**

## Merge requirements

1. Feature branch must compile and pass before merge
2. Merge uses `--no-ff` to preserve branch history in the log
3. After merge: BC dev status is set to `Done` (see `[[git-lifecycle-must-sync-bc-status]]`)

## The branching model

```
main
 └── <track-branch>          (e.g. "purchase" — lives for one sprint/module)
       └── feature/<name>    ← development happens here
       └── feature/<name>
       └── bugfix/<name>
 └── hotfix/<name>           ← branches from main, merges back to main
```

At release: track-branch → main (via PR, after full QA).

## Non-compliant

```bash
# Merging a feature directly to main when a track branch is declared in CLAUDE.md
git checkout main
git merge feature/my-feature   # violates rule
```

## Compliant

```bash
# Read track branch from CLAUDE.md → merge there
git checkout purchase
git merge --no-ff feature/my-feature
# Then sync BC: gitHubDevStatus = "Done"
```

## Scope

Applies to every CURABIS project with a `trackBranch` declaration in `CLAUDE.md`.
Projects without a declaration use `main` as the track branch — no change needed.
