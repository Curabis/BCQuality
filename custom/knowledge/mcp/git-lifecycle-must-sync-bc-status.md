---
rule: CURABIS-BCMCP-008
title: Git lifecycle must sync BC subtask dev status
severity: warning
domain: git, mcp, bc-integration
applies-to: [feature branches, bugfix branches, hotfix branches]
---

# Git lifecycle must sync BC subtask dev status

Every AL feature branch is linked to a BC subtask. The `gitHubDevStatus` and
`gitHubBranch` fields on the subtask must reflect the real state of the branch
at all times — automatically, without manual steps.

## Track branch

Each project declares its **track branch** in `CLAUDE.md` — the branch that is
the merge target for all feature branches in the current development track:

| Declaration in CLAUDE.md | Meaning |
|---|---|
| `trackBranch: main` (or absent) | Simple project: merge directly to `main` |
| `trackBranch: purchase` | Multi-track: merge to `purchase`; `main` stays clean for hotfixes |

The track branch is the authoritative "done" marker. A task is `Done` when its
feature branch is merged into the track branch — not necessarily `main`.

## Branch naming convention

Branches must follow this pattern so automation can parse the BC task reference:

```
<type>/<projectNo>-<taskNo>[-optional-description]
```

| Segment | Format | Example |
| --- | --- | --- |
| type | `feature`, `bugfix`, `hotfix` | `feature` |
| projectNo | `[A-Z]{2,4}\d{4}-\d{5}` | `DEV2023-00027` |
| taskNo | zero-padded or plain integer | `004` or `4` |
| description | optional, hyphen-separated | `bc-agent-semantic-tools` |

**Valid examples:**
```
feature/DEV2023-00027-004-bc-agent-semantic-tools
bugfix/DEV2023-00027-003-odata-string-key
hotfix/DEV2023-00012-001-invoicing-crash
feature/DEV2023-00027-4
```

**Invalid (no automation):**
```
my-feature
fix-thing
DEV2023-00027
```

## Status mapping

| Git event | gitHubDevStatus | gitHubBranch |
| --- | --- | --- |
| New branch created (`git checkout -b`) | `In Progress` | `<branch-name>` |
| Branch abandoned (switch away without committing) | `Backlog` | `""` |
| Merged to track branch | `Done` | `<track-branch>` |
| Branch parked (manual) | `On Hold` | `<branch-name>` |

## Automated implementation (git hooks)

Automation is provided by two git hooks in `.githooks/` (activated via
`git config core.hooksPath .githooks`) that call
`Scripts/Invoke-BCGitSync.ps1`:

- `post-checkout` — detects branch creation and branch abandonment
- `post-commit` — detects commits/merges on the track branch

`Invoke-BCGitSync.ps1` calls the BC OData API directly (same credentials as
`bc-agent.js`) and never blocks the git operation — all errors are swallowed
with a warning.

Git hooks require that branch names follow the `<type>/<projectNo>-<taskNo>`
naming convention. Branches that do not follow this format are ignored by hooks.

## Claude-driven synchronization

When Claude executes git operations, the git hooks may not fire — either because
hooks are not configured, or because the branch name does not follow the
`<type>/<projectNo>-<taskNo>` convention.

**Claude MUST call BC MCP explicitly at two points:**

| Moment | BC MCP action |
|---|---|
| Feature branch created | `gitHubDevStatus = "In Progress"`, `gitHubBranch = <branch>` |
| Feature branch merged to track branch | `gitHubDevStatus = "Done"`, `gitHubBranch = <track-branch>` |

Steps:
1. Find the active task using the recipe in `[[bc-mcp-find-active-task-for-branch]]`
2. Call `Modify_activeTask_PAG6102900` with the two writable fields

This requirement applies regardless of branch naming format and regardless of
whether git hooks are also active. If both run, there is no conflict — they write
identical values.

## Safety rules

CURABIS-BCMCP-008 The sync script NEVER writes BC subtask `status`
  (Created/Accepted/In progress/Finished/Invoiced). It only writes
  `gitHubDevStatus` and `gitHubBranch`. These are the only two fields
  the agent is allowed to modify (see CURABIS-BCMCP-001).

CURABIS-BCMCP-009 The sync script exits 0 on all errors. It must never
  block a git commit, checkout, or merge. BC sync is best-effort.

CURABIS-BCMCP-010 Only tasks in `activeTasks` (status = Accepted or In progress)
  are updated. A branch against a `Created` task is silently ignored until the
  task is approved in BC.

## BCApps reference

Branch naming conventions and git workflow integration follow the patterns used
in [microsoft/BCApps](https://github.com/microsoft/BCApps) — see
`.github/CONTRIBUTING.md` for Microsoft's own conventions on feature branches
and PR titles that reference work items.
