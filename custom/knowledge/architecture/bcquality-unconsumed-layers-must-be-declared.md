---
bc-version: [all]
domain: architecture
keywords: [bcquality, knowledge-layer, microsoft, community, custom, session-start, consumption]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Unconsumed BCQuality layers must be declared

## Description

BCQuality knowledge is organized in three layers — `microsoft/`, `community/`,
`custom/` — and BCQuality's own documentation states all three are enabled by
default when an agent consumes the repo. Tooling that builds a local cache or
a session-start briefing from BCQuality can end up wiring only one layer
(typically `custom/`, because it is small enough to preload in full) while
silently never touching the other two. Nothing errors, nothing warns — the
session proceeds under the impression that BCQuality is fully consulted when
only a fraction of it actually is.

## Best Practice

Any component that fetches, caches, or reads BCQuality knowledge on behalf of
an agent must state explicitly which layers it covers, next to the fetch logic
itself (e.g. in the CLAUDE.md instruction or the agent file's Source section) —
not left to be inferred from reading the code. A layer excluded because of
scale (a large layer unsuited to full preload) requires either a filtered or
on-demand retrieval path, or an explicit written note that the layer is out of
scope for that tooling.

## Anti Pattern

Wiring a knowledge cache to one layer's fetch filter and describing the result
in prose as "BCQuality knowledge" without naming which layers are actually
included. This creates the false impression that the full rulebook — including
Microsoft's official guidance — informs every session, when in fact only the
custom layer does.
