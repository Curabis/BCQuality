# AL Language Namespace Verification Rule

## Core Requirement

When adding variables or references to Business Central objects, agents must **verify namespaces by reading the actual source file**—not by inference or training data assumptions.

## Key Principle

The documentation emphasizes: *"The authoritative source for a namespace is always the object's own source file."* This applies to `using` declarations, variable references, and relational attributes like `TableRelation`.

## Verification Process

The prescribed workflow involves three steps:

1. **Locate** the object's source file using glob patterns or symbol search
2. **Read** the namespace declaration from line one
3. **Add** the verified namespace to the consuming file's `using` statements

## Critical Distinction

A file may compile in an agent's local build but display errors in VS Code because the AL Language Server uses different namespace resolution. *"The definitive compilation result is what VS Code shows—not the agent's internal build."*

## What to Avoid

The anti-pattern warns against incomplete namespaces like `using SettlementVoucher;` and guessed namespaces such as `using Microsoft.Purchases.Vendor;` without verification.

## Pre-Delivery Checklist

Before delivering code, agents must:
- Enumerate all `using` statements
- Confirm each namespace derives from actual source inspection or symbol lookup
- Correct any assumed namespaces by re-reading the source

This rule reflects that Microsoft's namespace structure changed significantly from BC24 onward, making assumptions increasingly unreliable.

## BCApps Reference

BCApps is the authoritative source for all Microsoft namespace paths post-BC24. The entire `Microsoft.*` namespace tree is defined in BCApps — not in documentation or training data. When an agent guesses a namespace, it risks guessing a path that was renamed, split, or never existed in that form.

- **Source:** https://github.com/microsoft/BCApps/tree/main/src
- **Example:** `BCPTSuiteAPI.Page.al` declares `namespace System.Tooling;` — guessing `System.Performance` or `Microsoft.BC.Tools` would compile locally but break in VS Code's language server.
- **Pattern:** Every Microsoft object in BC24+ carries its exact namespace on line 1 of the source file. Reading that line is the only reliable verification method.
