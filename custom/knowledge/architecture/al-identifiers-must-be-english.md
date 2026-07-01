---
bc-version: [all]
domain: architecture
keywords: [identifiers, naming, english, captions, translation]
technologies: [al]
countries: [w1]
application-area: [all]
---
# AL Naming Convention: English Identifiers Only

## Description

All AL identifiers must be written in English, regardless of the developer's native language. "Translations are handled separately via XLIFF files — never by writing Danish, German or other language identifiers in AL source code."

## What This Covers

The rule applies to:
- Variable and procedure names
- Parameter and field names
- Object identifiers (tables, codeunits, pages, enums, reports)
- Enum value names
- Label identifiers and default text

Captions and ToolTips may use target language in source files but require XLIFF translations for supported locales.

## Practical Example

**Wrong approach:** Using Danish identifiers like `Beløb` (amount) or `BeregnTotalbeløb` (calculate total amount)

**Correct approach:** Write `Amount: Decimal` and `CalculateTotalAmount()` in code, with Danish translations managed separately through XLIFF configuration files.

## Developer Conversation Handling

When developers describe requirements in their native language—such as "opret en variabel til beløbet"—the agent translates the *intent* into English identifiers (`Amount: Decimal`) rather than transliterating the original words directly into code.

This separation ensures source code remains universally readable while localization remains flexible and maintainable.

## BCApps Reference

The entire BCApps codebase — maintained by Microsoft engineers across many nationalities, including Danes — uses exclusively English identifiers without exception. Across hundreds of thousands of lines of AL, no native-language identifiers appear anywhere in the source.

- **Source:** https://github.com/microsoft/BCApps
- **Pattern:** Every variable, procedure, field, and object name in BCApps is English. All localization is handled via caption properties and XLIFF files — never by changing identifier names.
- **Why this matters:** BCApps is a multi-contributor open source project. Non-English identifiers would make the code unreadable to international contributors — the same argument applies to any CURABIS PTE shared across teams.
