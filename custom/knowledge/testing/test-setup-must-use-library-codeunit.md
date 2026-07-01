---
bc-version: [all]
domain: testing
keywords: [testing, test-setup, library-codeunit, initialization]
technologies: [al]
countries: [w1]
application-area: [all]
---
# CURABIS Test Library Standards

## Description

The documentation establishes three critical testing practices for CURABIS AL applications:

1. **Centralized Setup**: "all test setup is centralized in a dedicated Test Library codeunit" rather than individual test procedures calling BC standard libraries directly.

2. **Suppress Commits**: `SetSuppressCommit(true)` must execute before `Run()` to isolate test data and prevent cross-test contamination.

3. **Assertion After asserterror**: Every `asserterror` statement requires a subsequent `Assert.ExpectedErrorCode()` or `Assert.ExpectedError()` call to validate the specific error, preventing false passes from unexpected exceptions.

## Key Violations

The anti-patterns section highlights three common mistakes:

- Bypassing the test library by directly invoking BC standard codeunits like `LibraryInventory`
- Executing posting operations without suppressing commits, which "commits to test database"
- Using "naked asserterror" that "passes on any error, not just the expected one"

## Correct Implementation

The best practice section demonstrates the preferred approach: delegating setup operations to the test library (e.g., `SVLib.GivenScrapItem()`), enabling `SuppressCommit` before posting operations, and pairing error assertions with specific error code validations.

These guidelines ensure test isolation, maintainability, and reliability across CURABIS test suites.

## BCApps Reference

The test library pattern originates from BCApps. The Microsoft-maintained test framework libraries (`Library - ERM`, `Library - Inventory`, `Library - Sales`, `Library - Utility`, etc.) are defined in BCApps and establish the canonical pattern for centralized, reusable test setup. CURABIS's own Test Library codeunit follows this same structural model.

- **Source:** https://github.com/microsoft/BCApps/tree/main/src/Tools/Test%20Framework
- **Pattern:** Microsoft never writes inline setup logic inside individual test procedures. All setup is routed through library codeunits that can be reused, versioned, and maintained independently of the test cases themselves.
- **Why this matters:** BCApps Test Framework is the ground truth for how BC testing is intended to work. Deviating from this pattern creates test suites that are harder to maintain and more likely to share state across tests.
