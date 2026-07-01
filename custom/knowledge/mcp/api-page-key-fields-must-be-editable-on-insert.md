---
bc-version: [all]
domain: mcp
keywords: [api-page, key-fields, editable, insert, odata]
technologies: [al]
countries: [w1]
application-area: [all]
---
# CURABIS MCP: ODataKeyFields Editability Rule

## Description

Key fields declared in `ODataKeyFields` cannot have `Editable = false` when the API page permits inserts and **the field is consumer-provided**. This restriction causes the OData layer to reject the field as an unknown property during POST operations.

## Why It Matters

When a field is marked read-only, Business Central removes it from the OData write schema. If a consumer attempts to POST a new record with that key field in the request body, the system cannot match it to any writable property and returns a `BadRequest` error.

## Problematic vs. Correct Approach

**Incorrect:**
    field(projectNo; Rec."Project No.")
    {
        Editable = false;  // prevents API inserts when consumer must supply the value
    }

**Correct:**
    field(projectNo; Rec."Project No.")
    {
        // No Editable = false — consumer supplies this on POST
    }

## Key Takeaways

- Every **consumer-provided** field referenced in `ODataKeyFields` on pages where `InsertAllowed = true` must remain editable
- The OData specification itself enforces immutability of key fields post-creation — no additional markup required
- Non-key fields can still use `Editable = false` without triggering this issue
- Test create operations via your OData endpoint to verify compliance

## BCApps Reference

BCApps `BCPTSuiteAPI.Page.al` uses `ODataKeyFields = SystemId` with `SystemId` marked `Editable = false`. This is a **valid exception** — `SystemId` is a system-generated GUID that BC assigns automatically on insert. The consumer never provides it in a POST body, so marking it non-editable does not break API inserts.

- **Source:** https://github.com/microsoft/BCApps/blob/main/src/Tools/Performance%20Toolkit/App/src/BCPTSuiteAPI.Page.al
- **Clarification from BCApps:** The rule distinguishes two key field types:
  - **Auto-generated keys** (`SystemId`, auto-numbered codes): May be `Editable = false` — BC supplies the value, not the consumer.
  - **Consumer-provided keys** (`"Project No."`, `"Code"`, `"Entry No."`): Must remain editable — the POST request must include this value and BC must accept it.
