---
bc-version: [all]
domain: architecture
keywords: [mode-b, curabis-standard, auto-update, agents, per-repository, sha-gate, race-condition]
technologies: [al]
countries: [w1]
application-area: [all]
---

## Description

`.github/.agents/` is a per-repository artifact — every CURABIS project has its
own, independent copy. But the BCQuality version marker that gates whether
Mode B runs (`~/.claude/.bcquality-version`) is a single file shared across
every local repository on the developer's machine. This mismatch creates a
race condition: whichever project's session happens to be the first to notice
a BCQuality change runs Mode B and advances the shared marker — every other
local project then sees "SHA unchanged" and silently skips its own Mode B
reconciliation, even though its `.github/.agents/` was never checked against
the new template state.

This was observed directly: two Mode B runs in one project advanced the shared
marker to a given SHA. Any other CURABIS project opened afterward would see
that same SHA as already current and skip Mode B entirely — permanently
missing any template file (e.g. a newly added agent) that arrived in that
BCQuality change, unless the developer manually re-triggers the update in
that specific project.

## Rule

Mode B reconciliation (diffing the template file list against `.github/.agents/`)
must be tracked with a marker local to each repository — not solely by the
shared global BCQuality version file. A suggested mechanism: maintain a local,
git-ignored per-repo marker (e.g. `.github/.agents/.bcquality-version`) recording
the BCQuality SHA against which *this* repository's Mode B reconciliation last
ran. The global marker may still gate whether the shared knowledge-file cache
needs re-fetching from the network — but it must never be the sole gate for
whether Mode B executes for a given repository.

## What NOT to do

- Do not treat "global SHA unchanged" as proof that this repository's agents are current
- Do not skip Mode B for a repository just because another project's session already advanced the shared marker
- Do not rely on developer memory to manually re-run "Opdater CURABIS Standard" in every sibling project after a BCQuality change
- Do not conflate the network-cache-freshness concern (global, fine to share) with the per-repo-reconciliation concern (must not be shared)

## Signal to watch for

At session start, compare:

```
Local per-repo marker: .github/.agents/.bcquality-version (if present)
```

against the current BCQuality main SHA. If they differ (or the local marker is
missing), run Mode B reconciliation for this repository regardless of what the
global `~/.claude/.bcquality-version` file says.

## Message to developer

When a per-repo reconciliation gap is found, output exactly this before continuing:

```
⚠️ Dette repository er ikke reconciled mod seneste BCQuality-SHA, selvom den
globale versions-fil allerede er opdateret (formentlig af et andet projekt).
Kører Mode B-reconciliation for dette repo nu.
```

Do not silently skip Mode B just because the global marker looks current.
