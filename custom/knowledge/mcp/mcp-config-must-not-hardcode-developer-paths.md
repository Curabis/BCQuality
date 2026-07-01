---
bc-version: [all]
domain: mcp
keywords: [mcp-config, hardcoded-paths, userprofile, portability]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Shared MCP configuration must not hardcode developer-specific paths

## Description

A git-committed `.mcp.json` must not hardcode an absolute path that is specific to
one developer's machine — a repository clone location on a particular drive or
folder, or a home-directory path containing a specific username. Any such path
must be resolved via Claude Code's built-in environment-variable expansion instead.

## Why

`.mcp.json` is shared and committed — every developer who clones the repository
inherits the exact same file. A path baked in for the machine of whoever wrote the
file (e.g. `C:\Curabis\ProjectX\...` or `C:\Users\<username>\.claude\bridge.js`)
works only for that one person. Every other developer's MCP servers silently fail
to start, and the failure looks like a runtime problem rather than a configuration
one — wasting time in the wrong place (see `mcp-server-must-be-verified-at-session-start.md`,
which detects the symptom but not this root cause).

## How to fix

Claude Code expands two forms of variable inside `.mcp.json`'s `command`, `args`,
`env`, `url`, and `headers` fields:

- `${VAR}` — any OS environment variable, e.g. `${USERPROFILE}` on Windows resolves
  to the current user's home directory.
- `${CLAUDE_PROJECT_DIR:-default}` — the project root directory that Claude Code
  itself sets when it spawns a stdio MCP server. The `:-default` fallback is
  required because the variable is only available in the spawned process's
  environment, not at config-parse time.

Example:

    {
      "mcpServers": {
        "example": {
          "command": "powershell",
          "args": ["-File", "${CLAUDE_PROJECT_DIR:-.}\\.vscode\\launch-server.ps1"]
        },
        "bridge": {
          "command": "node",
          "args": ["${USERPROFILE}\\.claude\\bridge.js"]
        }
      }
    }

## What NOT to do

- Do not hardcode a drive letter + folder path that reflects one developer's clone
  location.
- Do not hardcode `C:\Users\<name>\...` — every developer has a different username.
- Do not "fix it locally" by editing the committed file to match your own machine —
  that only moves the breakage to the next developer who pulls.

## Applies to

All CURABIS projects that configure MCP servers in `.mcp.json`.
