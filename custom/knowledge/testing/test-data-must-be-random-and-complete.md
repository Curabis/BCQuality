# CURABIS Test Data Guidelines

## Core Principle

"CURABIS tests assume an empty database. All test data must be created programmatically — never assume existing records or hardcode codes, numbers, or names that may or may not exist in a given environment."

## Three Mandatory Rules

**Rule 1: Leverage Microsoft Libraries**
Use built-in setup codeunits (`Library - ERM`, `Library - Inventory`, `Library - Sales`) for standard Business Central objects like no-series, G/L accounts, customers, and items. These generate collision-free random codes.

**Rule 2: Complete All Required Fields**
Every mandatory field must receive a value. A `Code[10]` field requires 10 random characters; `Text[50]` needs randomized text. Partial setups violating this principle are prohibited.

**Rule 3: Create Custom Procedures for Domain-Specific Tables**
For CURABIS-exclusive tables, build dedicated setup functions in Test Library following Microsoft's patterns: programmatic creation with random values unless the test documents a fixed contract requirement.

## Critical Exception

Integration and flow tests validating external contracts (JSON structures, EDIFACT messages, counterparty codes) may use hardcoded values. These tests document the integration specification itself, not arbitrary test logic.

## Anti-Patterns to Avoid

- Conditional hardcoded lookups assuming pre-existing data
- Shortened field values not matching declared field length
- Underfilled required fields

## Implementation Example

Generate randomized payment method codes via `LibraryUtility.GenerateRandomCode()` rather than assuming 'CASH' exists. Create source codes through `LibraryERM.CreateSourceCode()` and retrieve no-series using `LibraryUtility.GetGlobalNoSeriesCode()`.

## BCApps Reference

The randomization helpers central to this rule — `LibraryUtility.GenerateRandomCode()`, `LibraryERM.CreateSourceCode()`, `LibraryUtility.GetGlobalNoSeriesCode()` — are implemented and maintained in BCApps. BCApps test code never hardcodes record identifiers like `'CASH'`, `'10000'`, or `'70000'`; all test data is generated programmatically.

- **Source:** https://github.com/microsoft/BCApps/tree/main/src/Tools/Test%20Framework
- **Pattern:** BCApps test codeunits create every required record from scratch using library helpers that guarantee uniqueness per test run. The CURABIS rule mirrors this approach exactly.
- **Note:** The `BCPTCreateSOWithNLines.Codeunit.al` sample in BCApps uses `Customer.get('10000')` as a fallback — this is a BCPT performance scenario (not a correctness test) and explicitly acknowledges this deviation. Correctness tests must never do this.
