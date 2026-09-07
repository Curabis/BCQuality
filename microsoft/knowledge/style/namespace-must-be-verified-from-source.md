---
bc-version: [all]
domain: style
keywords: [namespace, verification, source-of-truth, using-statement]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Resolve a namespace from the referenced object's source or symbols, never by guessing

> Contributions welcome — open a PR to refine or extend this article.

## Description

Since Business Central 2024 release wave 1, Microsoft's own objects are organized under a deep `Microsoft.*` namespace tree that has been renamed and restructured repeatedly. When adding a `using` directive for an existing AL object (table, codeunit, page, enum, interface, etc.), guessing its namespace from the object's name, from an older codebase, or from general familiarity produces a statement that can look plausible, compile in isolation, and still resolve to the wrong object or fail in the AL Language Server that VS Code actually uses to report errors. The reliable sources are the object's own source file (its `namespace` declaration) or, for a dependency without accessible source, its AL symbol package — not the object's name or a remembered convention.

## Best Practice

When referencing an existing AL object, resolve its namespace from that object's actual source file or symbol definition — never infer or invent one from its name, functional area, or naming convention.

See sample: `namespace-must-be-verified-from-source.good.al`.

## Anti Pattern

Writing a `using` statement from memory, from an incomplete path, or from a plausible-looking guess. It can compile in one build environment while still failing to resolve in VS Code, because the two use different namespace resolution.

See sample: `namespace-must-be-verified-from-source.bad.al`.
