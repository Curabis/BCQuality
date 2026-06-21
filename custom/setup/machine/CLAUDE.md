<!-- cspell:disable -->
# CURABIS — Global Claude Code Instructions

These instructions apply to every Claude Code session, regardless of project.

## CURABIS Standard project setup

When working in a repository that has no `CLAUDE.md`, or when the user says
**"Konfigurer dette projekt til CURABIS Standard"**, fetch and follow the setup agent:

```
https://raw.githubusercontent.com/Curabis/BCQuality/main/custom/setup/curabis-standard.agent.md
```

This agent configures the repository with BCQuality rules, BC MCP bridge,
Immanuel (rule guardian), and project memory — from a single command.

## Identity

- Organization: CURABIS ApS
- BC MCP bridge is installed at `~/.claude/bc-mcp-bridge.js`
- BC MCP credentials are at `~/.bc-mcp.config.json` (never commit this file)

<!-- Replace the two lines below with your own details -->
- User: [Your Name] (username: [your-username])
