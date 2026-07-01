---
bc-version: [all]
domain: architecture
keywords: [dependency, source, add-repo, github, curabis, closed-source, test, symbol, black-box]
technologies: [al]
countries: [w1]
application-area: [all]
---

## Description

CURABIS develops and maintains several AL apps that are consumed as dependencies
across many customer projects (Danelec, Jernpladsen, Wareco, KLB, etc.). When a
customer project imports one of these apps, it typically arrives as a compiled
`.app` symbol package in `.alpackages/` — not as source code.

This makes the app look like a closed external dependency. It is not.

Before treating any CURABIS-owned dependency app as a black box, the agent
must check whether its source is available via `add_repo` (GitHub). Reverse-
engineering compiled symbol packages (`SymbolReference.json`, `.app` manifest
inspection) is always an inferior substitute for reading the actual production
source, and produces lower-confidence tests and code reviews.

## Known CURABIS app repos

| App name | GitHub repo | Notes |
|---|---|---|
| Contract Management 365 app | https://github.com/Curabis/ContractMgmt365app.git | Main contract engine; depended on by most CURABIS customer projects |
| Project Management 365 app | https://github.com/Curabis/ProjectMgmt365app.git | |
| Cross Channel Management 365 app | https://github.com/Curabis/WebStore.git | |
| Summatim | https://github.com/MichaelDieringer/-summatim.git | Currently restricted — only mid has access; add_repo will fail for other team members |

*Expand this table when new CURABIS apps are created. If an app is not listed here,
ask `mid` whether source is available before reverting to symbol inspection.*

## Microsoft BCApps

Microsoft's own standard objects (Base Application, System Application, test
framework libraries: Library-Sales, Library-ERM, Library-Purchase, etc.) are
available at:

- https://github.com/microsoft/BCApps

Use `add_repo microsoft/BCApps` when you need to understand internals of
Microsoft standard codeunits (e.g. Sales-Post, Gen. Jnl.-Post Line, Copy Document
Mgt.) that are referenced by event subscribers but whose source is not visible in
the current project.

## Anti Pattern

    // WRONG: reverse-engineering the compiled symbol package instead of reading source
    // Agent parses SymbolReference.json from .alpackages/*.app to learn
    // Contract Management table fields and public procedure signatures.
    // Result: incomplete picture, missed validation logic, excluded feature from tests.

## Best Practice

    // CORRECT: add the source repo and read it directly
    add_repo Curabis/ContractMgmt365app

    // Then read the actual table definitions, codeunits, and any Test Library
    // codeunits that may already exist in the repo's own test app.

    // If no Test Library exists in the dependency's test app:
    // build GIVEN helpers in the consuming project's own Test Library codeunit
    // based on the REAL table field definitions and trigger logic you can now read.

## When to apply this rule

Apply at the start of any task involving:
- Writing tests for production code that uses event subscribers on CURABIS-owned
  codeunits or tables
- Calling public procedures from a CURABIS-owned app's codeunits
- Building GIVEN helpers for a CURABIS-owned app's tables
- Code-reviewing changes to codeunits that extend CURABIS-owned apps

If `add_repo` fails due to access restrictions (see table above), flag the
limitation explicitly rather than silently falling back to symbol inspection.
