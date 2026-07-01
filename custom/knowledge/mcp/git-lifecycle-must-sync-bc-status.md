---
bc-version: [all]
domain: mcp
keywords: [git, lifecycle, bc-status, dev-status, sync]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Git lifecycle must sync BC subtask dev status

## Description

Every AL feature branch is linked to a BC subtask. The `gitHubDevStatus` and
`gitHubBranch` fields on the subtask must reflect the real state of the branch
at all times — automatically, without manual steps.

## Track branch

Each project declares its **track branch** in `CLAUDE.md` — the merge target for
all feature branches in the current development track:

| Declaration in CLAUDE.md | Meaning |
|---|---|
| `trackBranch: main` (or absent) | Simple project: merge directly to `main` |
| `trackBranch: purchase` | Multi-track: merge to `purchase`; `main` stays clean for hotfixes |

The track branch is the authoritative "done" marker. A task is `Done` when its
feature branch is merged into the track branch — not necessarily `main`.

## Branch naming convention

Branches must follow this pattern so automation can parse the BC task reference —
type is `feature`/`bugfix`/`hotfix`, projectNo matches `[A-Z]{2,4}\d{4}-\d{5}`,
taskNo is a plain or zero-padded integer, description is optional:

    <type>/<projectNo>-<taskNo>[-optional-description]

    Valid:   feature/DEV2023-00027-004-bc-agent-semantic-tools
             bugfix/DEV2023-00027-003-odata-string-key
             feature/DEV2023-00027-4
    Invalid: my-feature / fix-thing / DEV2023-00027   (no automation)

## Status mapping

| Git event | gitHubDevStatus | gitHubBranch |
| --- | --- | --- |
| New branch created (`git checkout -b`) | `In Progress` | `<branch-name>` |
| Branch abandoned (switch away without committing) | `Backlog` | `""` |
| Merged to track branch | `Done` | `<track-branch>` |
| Branch parked (manual) | `On Hold` | `<branch-name>` |

## Automated implementation (git hooks)

Two git hooks in `.githooks/` (activated via `git config core.hooksPath .githooks`)
call `Scripts/Invoke-BCGitSync.ps1`: `post-checkout` detects branch creation and
abandonment; `post-commit` detects commits/merges on the track branch. The script
calls the BC OData API directly (same credentials as `bc-agent.js`), never blocks
the git operation, and ignores branches that do not follow the naming convention.

## Claude-driven synchronization

When Claude executes git operations, the hooks may not fire — hooks unconfigured,
or branch name outside the convention. **Claude MUST call BC MCP explicitly at
two points:**

| Moment | BC MCP action |
|---|---|
| Feature branch created | `gitHubDevStatus = "In Progress"`, `gitHubBranch = <branch>` |
| Feature branch merged to track branch | `gitHubDevStatus = "Done"`, `gitHubBranch = <track-branch>` |

Steps: find the active task using the recipe in
`[[bc-mcp-find-active-task-for-branch]]`, then call
`Modify_activeTask_PAG6102900` with the two writable fields. This applies
regardless of branch naming and regardless of whether hooks are also active —
if both run they write identical values.

## Safety rules

CURABIS-BCMCP-008 The sync script NEVER writes BC subtask `status`
  (Created/Accepted/In progress/Finished/Invoiced). It only writes
  `gitHubDevStatus` and `gitHubBranch` (see CURABIS-BCMCP-001).

CURABIS-BCMCP-009 The sync script exits 0 on all errors. It must never
  block a git commit, checkout, or merge. BC sync is best-effort.

CURABIS-BCMCP-010 Only tasks in `activeTasks` (status = Accepted or In progress)
  are updated. A branch against a `Created` task is silently ignored until the
  task is approved in BC.

## BCApps reference

Branch naming and git workflow integration follow
[microsoft/BCApps](https://github.com/microsoft/BCApps) conventions — see its
`.github/CONTRIBUTING.md` for feature-branch and work-item-referencing patterns.
