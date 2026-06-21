---
name: bc-mcp-find-active-task-for-branch
description: >
  Standard recipe for finding the BC sub-task linked to the current git branch,
  including exact action names and field names for each BC MCP endpoint.
layer: 2
category: mcp
---

# BC MCP: Find Active Task for Branch

## Description

When committing, closing a branch, or updating dev status, the agent must
look up the BC sub-task linked to the current branch. This recipe documents
the exact steps and action names to do it efficiently with minimal roundtrips.

Do **not** start with `bc_actions_search` — it fetches and searches the full
action catalog and is slow. Use `bc_actions_describe` with the known action
name to get a schema, then `bc_actions_invoke` to call it.

## Known action names

Derived from the AL page source (EntityName property + PAG + page ID):

| Page | EntityName (AL) | List action | Modify action | Create action |
|---|---|---|---|---|
| 6102900 CUR MCP Active Tasks | `activeTask` | `List_activeTask_PAG6102900` | `Modify_activeTask_PAG6102900` | — |
| 6102901 CUR MCP Projects | `project` | `List_project_PAG6102901` | — | — |
| 6102902 CUR MCP Task Comments | `taskComment` | `List_taskComment_PAG6102902` | `Modify_taskComment_PAG6102902` | `Create_TaskComment_PAG6102902` |
| 6102904 CUR MCP Project Repository | `projectRepository` | `List_projectRepository_PAG6102904` | `Modify_projectRepository_PAG6102904` | — |
| 6102905 CUR MCP Create Task | `newTask` | — | — | `Create_newTask_PAG6102905` |
| 50009 consultants | `consultant` | `List_consultant_PAG50009` | — | — |

> **Note:** Verify action names after a fresh session with `bc_actions_search`
> if any of the above return an error. The naming convention is
> `{Verb}_{EntityNamePascalCase}_PAG{PageId}`.

## Standard recipe: find task for current branch

```
1. git branch --show-current          → e.g. "PriceLookup"
2. git remote get-url origin          → e.g. "https://github.com/Curabis/Wareco.git"
3. bc_actions_invoke List_project_PAG6102901
      filter: "gitHubRepository eq 'https://github.com/Curabis/Wareco.git'"
   → get projectNo (e.g. "W-2024-001")
4. bc_actions_invoke List_activeTask_PAG6102900
      filter: "projectNo eq 'W-2024-001' and gitHubBranch eq 'PriceLookup'"
   → get taskId (global commit-message ID), taskNo, description, status
```

If step 3 returns no project, the repo is not linked — see `[[bc-mcp-link-repo-to-project]]`.
If step 4 returns no task, the branch has no registered task — create one or ask the PM.

## Key fields on active tasks

| Field | Description |
|---|---|
| `taskId` | **Global unique ID — use in commit messages** |
| `taskNo` | Sequential within project — use for customer portal links |
| `projectNo` | Parent project |
| `description` | Task description |
| `status` | BC-managed: Created → Accepted → In progress → Finished → Invoiced |
| `gitHubBranch` | Writable — set when starting work |
| `gitHubDevStatus` | Writable — Backlog / In Progress / Done / On Hold |
| `gitHubRepository` | **Obsolete** — always read repo from project, not from task |

## Writable fields — and what is forbidden

Only write `gitHubBranch` and `gitHubDevStatus` on active tasks.
Never write `status` — it controls time registration and invoicing in BC.
Never write `gitHubRepository` on the task (obsolete, will be removed in v29).

## Developer identity under S2S auth

The bridge runs as app identity `BC_DevelopmentMCP`. To attribute work:

```
1. git config user.email             → developer's git email
2. bc_actions_invoke List_consultant_PAG50009
      filter: "email eq 'mic.dieringer@gmail.com'"
   → get employeeCode (e.g. "MID")
3. Use employeeCode to filter "my tasks":
   List_activeTask_PAG6102900 filter: "taskResponsible eq 'MID'"
4. Sign status comments: end with "— Michael" so attribution survives S2S
```

Some developers use personal email for git but have a Curabis email as secondary
on GitHub. If the git email doesn't match, try the `@curabis.dk` variant.
