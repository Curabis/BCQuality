---
bc-version: [all]
domain: architecture
keywords: [commit-message, bc-task, task-id, traceability, git]
technologies: [al]
countries: [w1]
application-area: [all]
---
﻿---
name: commit-message-must-include-bc-task-id
description: >
  Every commit message must begin with the BC task ID in [#id] format,
  where id is the global taskId from the CUR MCP Active Tasks page.
layer: 2
category: architecture
---

# Commit Message Must Include BC Task ID

## Description

Every commit must reference the BC sub-task it belongs to by prefixing the
message with `[#taskId]`, where `taskId` is the globally unique, sequential
task identifier from the **CUR MCP Active Tasks** page (field `taskId`).

This links code history directly to customer-facing work items in BC, enables
time registration traceability, and is consistent with the convention already
used across Curabis teams.

## Anti Pattern

    Add Price Lookup feature — FindPrice page, tier prices, currency conversion

No traceability. Impossible to find the BC task from git history.

## Best Practice

    [#8738] Add Price Lookup feature — FindPrice page, tier prices, currency conversion
    [#8738] Add 22 UI tests for PRICING LOOKUP feature
    [#8738] Add translations, shared project memory and cspell config

## The two task numbers — use taskId, not taskNo

The sub-task has two numbers — do not confuse them:

| Field | Description | Use for |
|---|---|---|
| `taskNo` | Sequential within the project (e.g. 42) | Referencing within a project |
| `taskId` | Globally unique across all projects (e.g. 8738) | **Commit messages** |

Always use `taskId` in commit messages. It is unambiguous across all projects
and repos.

> **Gotcha:** Users and conversations refer to tasks by `taskNo` — e.g. "opgave 51"
> or "task 42". This is the natural shorthand and is correct for conversation.
> But `taskNo` is NOT what goes in the commit message. Always look up `taskId`
> from the MCP response before committing — they are different fields.

## How to find the taskId before committing

1. Get the current branch: `git branch --show-current`
2. Find the linked project via BC MCP (see `[[bc-mcp-find-active-task-for-branch]]`)
3. In the MCP response, read the **`taskId`** field — NOT `taskNo`
4. Prefix every commit on this branch with `[#taskId]`

If no task exists for the branch, create one first (see bc-mcp.agent.md
create-task workflow) or ask the project manager to register the work.

## Scope

All commits that reach the main branch — feature, fix, test, chore, docs.
Merge commits and auto-generated commits (renovate, al-go) are exempt.
