# Custom layer

This folder is the template for partner- and customer-specific overrides. Use it to add knowledge and skills that apply to your organization but are not appropriate for the shared Microsoft or Community layers.

## Structure

```
custom/
├── knowledge/    # Your organization's knowledge files (same format as /microsoft/knowledge/)
└── skills/       # Your organization's action skills
```

## How to use

Fork or clone BCQuality into your own repository and add your content here. Knowledge files in `/custom/knowledge/` follow the same frontmatter schema and section requirements as every other layer. Action skills in `/custom/skills/` follow the Action Skill template defined in `/skills/`.

When agents consume BCQuality, the custom layer is loaded alongside Microsoft and Community — your overrides apply automatically.

---

# CURABIS — BCQuality customizations

## Developer onboarding (new machine)

Two files must be placed on the developer's machine. Everything else is automatic.

### 1. Global Claude Code instructions

Copy [`setup/machine/CLAUDE.md`](setup/machine/CLAUDE.md) to `~/.claude/CLAUDE.md`
and fill in your name and username.

This file tells Claude Code about CURABIS Standard in every session —
including brand-new, unconfigured repositories.

### 2. BC MCP credentials

Create `~/.bc-mcp.config.json` with your BC service-to-service credentials:

```json
{
  "tenantId": "<your-tenant-id>",
  "clientId": "<your-client-id>",
  "clientSecret": "<your-client-secret>",
  "baseUrl": "https://api.businesscentral.dynamics.com"
}
```

**Never commit this file.** It contains secrets.

## Configuring a new project

Once the two machine files are in place, open any AL-Go repository in VS Code
and tell Claude Code:

> "Konfigurer dette projekt til CURABIS Standard"

Claude fetches [`setup/curabis-standard.agent.md`](setup/curabis-standard.agent.md)
and writes all project files automatically:
`CLAUDE.md`, `.mcp.json`, `.github/.agents/`, `cspell.json`, `projectmemory/`.

The BC MCP bridge (`bc-mcp-bridge.js`) is also installed to `~/.claude/`
from this repo — so it stays up to date every time setup is re-run.

## Folder structure

```
custom/
  README.md                          ← this file
  knowledge/
    architecture/                    ← AL architecture rules
    testing/                         ← test quality rules
    mcp/                             ← BC MCP / API page rules
  setup/
    curabis-standard.agent.md        ← project setup agent
    bc-mcp-bridge.js                 ← BC MCP bridge (authoritative copy)
    machine/
      CLAUDE.md                      ← global Claude Code instructions template
    templates/
      bcquality.agent.md             ← BCQuality review agent (per project)
      immanuel.agent.md              ← Rule guardian agent (per project)
      cspell.json                    ← Standard spell-check config
```
