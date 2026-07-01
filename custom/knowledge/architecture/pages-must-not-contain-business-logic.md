---
bc-version: [all]
domain: architecture
keywords: [pages, business-logic, codeunit, separation-of-concerns]
technologies: [al]
countries: [w1]
application-area: [all]
---
# CURABIS Architecture: Page Presentation vs. Business Logic

## Description

In CURABIS codebases, pages serve exclusively as presentation layers. All business logic—including calculations, validations, and record modifications—must reside in codeunits, not in page triggers or actions. This standard is more rigorous than general Business Central guidance and applies uniformly across all CURABIS PTE applications.

## Key Principle

"A page procedure that calculates a value and assigns it to a field, calls `Rec.Modify()` directly, or implements business rules is an architecture violation even if it compiles."

## Permitted Exceptions

Two specific scenarios allow deviation from this rule:

1. **Setup Pages**: May directly read and write their own setup records
2. **Conversion Pages**: The designated "Run Conversion" page may invoke the conversion codeunit directly

## Anti-Pattern Examples

Pages should not contain:
- Direct calculations (e.g., `Rec."Total Amount" := Rec.Quantity * Rec."Unit Price"`)
- Calls to `Rec.Modify()` within page triggers
- Business rule validation logic embedded in page triggers

## Best Practice Implementation

Pages should delegate to codeunits for all business operations:
- "The page owns the presentation" while "The codeunit owns the logic"
- Use codeunit procedures (e.g., `SVManagement.RecalculateLine(Rec)`) for calculations and modifications
- Route all validations through codeunits rather than page triggers

This separation ensures maintainability, testability, and consistency across CURABIS applications.

## BCApps Reference

Microsoft's own BCApps repository confirms this pattern. In the Performance Toolkit, `BCPTSetupCard.Page.al` and `BCPTSetupList.Page.al` contain no business logic — all operations are delegated to `BCPTStartTests.Codeunit.al` and `BCPTHeader.Codeunit.al`. This is consistent across all BCApps pages.

- **Source:** https://github.com/microsoft/BCApps/tree/main/src/Tools/Performance%20Toolkit/App/src
- **Pattern:** Pages only bind data and invoke actions; codeunits own all state mutations and business rules. Microsoft applies this uniformly across thousands of pages in BCApps.
