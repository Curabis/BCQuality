---
bc-version: [all]
domain: architecture
keywords: [bcquality, knowledge-mirror, machine-local, repo-hygiene, sync, curabis-standard, claude-md]
technologies: [al]
countries: [w1]
application-area: [all]
---

## Description

The three-layer BCQuality knowledge mirror (custom/community/microsoft +
INDEX.md) can technically live in two places: inside each project repository
(`.github/.agents/bcquality-knowledge/`, setup v6) or once per developer
machine (`~/.claude/bcquality-knowledge/`, setup v7+). CURABIS developers
switch between many repositories every day. With per-repo mirrors, every repo
carries its own copy that goes stale on its own schedule — N repos are
permanently out of sync with each other and with upstream, every re-sync
pollutes the project's git history with hundreds of files of upstream rule
churn, and a review can be judged by whichever rule vintage that particular
repo happens to carry.

## Rule

The BCQuality knowledge mirror is machine-local, never repo-local. It lives at
`~/.claude/bcquality-knowledge/` on each developer's machine, populated by
`~/.claude/sync-bcquality-knowledge.ps1`, and is shared by every CURABIS repo
on that machine. One sync per machine per upstream change covers all repos.

Project CLAUDE.md files point at the machine mirror using
`~/.claude/...` / `%USERPROFILE%` — never a literal `C:\Users\<name>\...`
path — and include the self-heal instruction (if the mirror or sync script is
missing, fetch the script as raw bytes from BCQuality and run it) so a fresh
clone works on a fresh machine.

CI and cloud agents have no developer machine: they fetch the rules themselves
via `.github/bcquality.config.yaml` (repo + ref + enabled-layers) — not from a
committed mirror.

## What NOT to do

- Do not commit `.github/.agents/bcquality-knowledge/` (or any knowledge
  mirror) into a project repository
- Do not point a project CLAUDE.md at one developer's literal profile path
  (`C:\Users\mid\...`) — that breaks every other developer on the project
- Do not deploy `sync-bcquality-knowledge.ps1` into `.github/.agents/` — its
  destination follows the script's own location, which is what created
  repo-local mirrors in the first place
- Do not assume "the repo builds, so the rules are current" — mirror freshness
  is a machine concern, gated by the machine's BCQuality version marker

## Signal to watch for

At session start or during Mode B, any of these means the project predates
setup v7 and needs the Mode B v6-era cleanup (remove the repo mirror,
gitignore the path, repoint CLAUDE.md at the machine mirror):

- `.github/.agents/bcquality-knowledge/` exists in the repository
- CLAUDE.md contains a literal developer profile path (`C:\Users\<name>\.claude\...`)
- CLAUDE.md points its BCQuality section at `.github/.agents/bcquality-knowledge/`

## Message to developer

When a repo-local mirror or hardcoded mirror path is found, tell the developer
before continuing: this repo uses an obsolete BCQuality mirror model
(repo-local mirror and/or hardcoded developer path in CLAUDE.md); the standard
is the machine-local mirror in `~/.claude/bcquality-knowledge/`; offer to run
"Opdater CURABIS Standard fra BCQuality" to migrate now.
