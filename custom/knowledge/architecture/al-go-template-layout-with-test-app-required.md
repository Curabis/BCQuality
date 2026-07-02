---
bc-version: [all]
domain: architecture
keywords: [al-go, template, layout, test-app, migration, structural-readiness, flags]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL-Go template layout with a test app is required

## Description

CURABIS repos must follow the AL-Go template layout: an apps folder
(`.apps/`, reference form) containing one project folder per app, a
`.AL-Go/` settings folder, and an apps-level workspace file. Repos that
predate the template — AL source flat in the repo root — cannot run AL-Go's
`CreateTestApp` workflow, which means **no test cases can be created**, which
means the repo is outside the quality standard entirely: no tests, no eval
floor, no BCQuality review evidence.

A 2026-07-02 portfolio inventory (29 repos) found 3 customer-relevant flat
repos blocked from test creation, and 11 template-compliant repos that simply
had no test app yet (one `CreateTestApp` workflow run each — not a migration).

## Rule

1. Every CURABIS repo follows the AL-Go template layout: apps folder with one
   project per app, `.AL-Go/`, and an apps-level `*.code-workspace` (see
   `al-development-must-use-apps-workspace` for its required content).
2. Every main app has a test app companion (`<App>.Test`) so test cases can
   be written from day one.
3. **When BCQuality is implemented on a repo (CURABIS Standard Mode A) or
   updated (Mode B), the structural flags are raised immediately** — Rømer's
   inspection round includes these stations, and setup reports the findings
   before configuration proceeds. A repo may be configured while
   non-compliant, but never silently: the flags go in the setup report.
4. Structural findings are report-only. Migration from flat layout is a
   deliberate, planned change (data in `app.json`, pipelines, workspace) —
   never a silent correction.

## What NOT to do

- Do not attach BCQuality to a repo without reporting its structural state —
  a configured repo that cannot host tests gives false confidence
- Do not silently restructure a repo during setup or update
- Do not treat a missing test app in a template-compliant repo as a
  migration case — it is one `CreateTestApp` workflow run
- Do not write new AL features in a flat repo without flagging that tests
  cannot accompany them

## Signal to watch for

Rømer's inspection round: no apps folder containing `app.json` project
subfolders (flat layout — blocked), or a main app project without a matching
`*.Test` project (missing test app — one workflow run).

## Message to developer

When a structural gap is found during BCQuality implementation or update,
report before proceeding: this repo is on flat/pre-template layout (tests
cannot be created until it is migrated to the AL-Go template) — or: this repo
lacks a test app for <App>; run AL-Go's CreateTestApp workflow. Configuration
may continue, but the flag stands in the report until resolved.
