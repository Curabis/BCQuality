---
bc-version: [all]
domain: architecture
keywords: [workspace, apps-workspace, vscode, docs, al-go, development-environment]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL development must use the apps workspace — with docs included

## Description

CURABIS AL-Go repos carry two VS Code workspace files: one at repo root
(`al.code-workspace`) and one under the apps folder
(`.apps/.apps.code-workspace`). Developers observed working in the ROOT
workspace lose the standard development context: the apps workspace is the
one that scopes VS Code to the app projects plus `.AL-Go`, carries the
project-level settings (e.g. `powershell.cwd` pointing at the test app), and
— per this rule — includes the repo's `docs/` folder, so Columbo specs,
decision records and cleanup checklists are visible and editable exactly
where development happens. The root workspace opens repo plumbing (workflows,
git internals) and none of that context.

## Rule

Daily AL development happens in the workspace under the apps folder —
`.apps/.apps.code-workspace` (or `Apps/` on repos not yet migrated to the
`.apps` layout). That workspace file must contain, as folder entries:

1. every AL app project folder (main + test)
2. `.AL-Go`
3. the repo's docs folder, added as a relative entry: `"path": "../docs"`

Reference layout (Jernpladsen): folders = Jernpladsen, Jernpladsen.Test,
.AL-Go, docs (`../docs`), with `powershell.cwd` set to the test app.

The root `al.code-workspace` remains for repo-plumbing work (workflow edits,
AL-Go settings) — it is not the development workspace.

## What NOT to do

- Do not open the root `al.code-workspace` for feature development — specs
  and decision records will be out of sight, and out of sight means the work
  drifts from what was agreed
- Do not add `docs` by copying files into the apps folder — it is ONE folder
  at repo root, referenced relatively, so specs stay single-sourced
- Do not put machine-absolute paths in the workspace file — it is
  git-committed and shared (same principle as
  `mcp-config-must-not-hardcode-developer-paths`)

## Signal to watch for

Rømer's inspection round: `.apps/*.code-workspace` (or `Apps/*.code-workspace`)
exists, and its `folders` array includes an entry ending in `docs`. A missing
workspace file or a missing docs entry is a finding; the standard authorizes
adding the docs entry as a silent correction (report it afterwards).

## Message to developer

When a developer is working in the root workspace or the apps workspace lacks
the docs folder, tell them: daily development belongs in
`.apps/.apps.code-workspace`, which must include the app projects, `.AL-Go`
and `../docs` — offer to add the missing docs entry now.
