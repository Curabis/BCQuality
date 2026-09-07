---
bc-version: [all]
domain: style
keywords: [folder-structure, feature-organization, source-layout, maintainability]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Organize AL source by business feature, not object type

## Description

Folder structure inside an AL app has no effect on compilation or runtime behavior — this is a repository-organization convention, not a platform requirement, and different projects reasonably choose differently. Grouping files by business feature or module (`src/Sales/Invoice/`, `src/NoSeries/`) rather than by AL object type (`src/Tables/`, `src/Pages/`, `src/Codeunits/`) keeps everything belonging to one feature physically together, which many teams find easier to navigate than jumping between object-type folders that share nothing but their AL object kind. Adopt this consistently on a project rather than mixing both schemes, but treat it as a team convention to apply deliberately, not a Microsoft-mandated structure.

Code genuinely shared across multiple features (utility codeunits, common interfaces, shared enums) belongs in a `Common` or `Shared` folder, not duplicated per feature and not left in a catch-all root.

## Best Practice

    src/
    ├── NoSeries/
    ├── Sales/
    │   ├── Invoice/
    │   └── Order/
    └── Common/

Each feature folder holds every object type it needs; shared code has one dedicated home.

## Anti Pattern

    src/
    ├── Tables/
    ├── Pages/
    └── Codeunits/

Finding everything related to one feature now requires searching multiple folders and mentally reassembling it from scattered pieces.
