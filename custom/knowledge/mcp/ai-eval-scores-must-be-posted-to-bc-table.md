---
bc-version: [all]
domain: mcp
keywords: [ai-eval, scores, bc-table, hill-climbing, telemetry]
technologies: [al]
countries: [w1]
application-area: [all]
---
# CURABIS-MCP-008 — AI eval scores must be posted to the BC posting table

## Description

When an AI agent completes a hill climbing eval iteration on a BC sub-task, all
resulting scores — compile result, test score, BCQuality score, F1 score, verdict,
and model identity — must be posted to the `CUR Project AI Score` table in Business
Central via the designated MCP tool (`bc_post_ai_score`). Scores must **not** be
stored as task comments, local files, agent memory, inline in agent or knowledge
files, or any other location outside the BC posting table.

## Why

The `CUR Project AI Score` table is a **posting table**: one immutable entry per
iteration, clustered on `Entry No.` — the single source of truth for hill climbing
history on a sub-task. Alternate locations all break that guarantee: task comments
are 250-char, unstructured and unqueryable; local files are session- and
repo-scoped; agent memory is volatile; scores hard-coded in agent files are frozen
at time of writing. The BC table is what enables cross-project reporting, the
Court reviewing Edison's score data, the orchestrator reading prior iterations via
`bc_get_ai_scores`, and BC users seeing progress directly on the sub-task.

## Compliant

After each eval iteration, the orchestrator calls:

    bc_post_ai_score(
      projectNo   = "DEV2026-00010",
      subTaskNo   = "0014",
      iterationNo = 3,
      compile     = true,
      testScore   = 0.80,
      bcquality   = 0.86,
      f1Score     = 0.83,
      verdict     = "Keep",
      model       = "claude-sonnet-4-6"
    )

BC sets `Eval DateTime` automatically. A brief human-readable comment in addition
("Iteration 3: F1=0.83 → Keep") is allowed — the score itself is in BC.

## Non-compliant

    # Storing score as task comment only
    bc_add_comment(projectNo = "DEV2026-00010", subTaskNo = "0014",
                   comment = "Iter 3: compile OK tests 4/5 BCQ 6/7 F1=0.83 Keep")
    # -> unstructured text; not queryable; lost to reporting

    # Storing score in an agent file's "Hill climbing log" section
    # -> frozen, session-specific, wrong location

## False positive

Posting a human-readable summary comment **in addition to** calling
`bc_post_ai_score` is not a violation. The violation is using the comment or any
other location **instead of** the BC table.

## API reference

- Page: `CUR MCP Project AI Scores` (PAG6102906), entity `projectAIScores`
- Publisher: `curabis`, Group: `projectMgmt`, Version: `v2.0`
- Insert: allowed. Modify: never. Delete: never.
- `Eval DateTime` is set by BC `OnInsertRecord` — do not pass it.

## Eval at task boundaries (hill-climbing baseline and final)

To generate meaningful hill-climbing data, the project's eval script MUST run at
two moments per task:

| Moment | When | Verdict to post |
|---|---|---|
| **Baseline** | Before the first code change for a task | `"Baseline"` |
| **Final** | After all changes, before merging to track branch | `"Final"` |

The delta `Final.score - Baseline.score` is the task's quality impact: positive
means improved quality; negative means technical debt was introduced (note it in
the BC task comment); zero is neutral. Never skip the baseline "because the task
is small" — without it the delta cannot be computed and history is incomplete.

Each project declares its eval script in `CLAUDE.md`; that script emits the score
posted via `bc_post_ai_score` and appends to the project's eval history.

## Applies to

Agent files implementing hill climbing eval loops on BC sub-tasks, and all tasks
where the project declares an eval script in `CLAUDE.md`. Documentation-only
tasks (no code change) are exempt.
