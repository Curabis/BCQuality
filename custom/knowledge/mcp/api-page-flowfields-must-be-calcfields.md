---
bc-version: [all]
domain: mcp
keywords: [api-page, flowfield, calcfields, odata]
technologies: [al]
countries: [w1]
application-area: [all]
---
# CURABIS MCP: FlowFields on API Pages Rule Summary

## Description
**FlowFields on API pages must be explicitly calculated** via `CalcFields()` in the `OnAfterGetRecord` trigger, or they return empty values in OData responses.

## Key Points

**Why it matters:** "FlowFields are not stored in the database. Business Central only calculates them on demand." Regular pages auto-calculate during rendering, but API pages don't—external consumers receive raw empty values otherwise.

**What to do:** Every FlowField exposed in an API page's layout section requires inclusion in a `CalcFields()` call within `OnAfterGetRecord`. Multiple fields can be combined in one call.

**What doesn't need it:** Stored (non-FlowField) fields require no CalcFields processing.

## Implementation Pattern

The provided example demonstrates proper implementation:

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Elapsed time (Chargeable)", "Customer Name");
    end;

## Verification Approach

Audit API pages by:
1. Identifying every field bound to FlowField sources in the layout
2. Confirming each appears in the `OnAfterGetRecord` CalcFields statement
3. Flagging any missing FlowField as a defect (silent empty return to consumers)

This rule prevents data gaps in API integrations caused by overlooked calculation requirements.

## BCApps Reference

BCApps API pages implement `CalcFields()` in `OnAfterGetRecord` for all FlowField-sourced fields. The BCPT Suite API page demonstrates the correct pattern for API pages with computed data.

- **Source:** https://github.com/microsoft/BCApps/blob/main/src/Tools/Performance%20Toolkit/App/src/BCPTSuiteAPI.Page.al
- **Additional API pages:** https://github.com/microsoft/BCApps/tree/main/src/Tools/Performance%20Toolkit/App/src
- **Pattern:** Any FlowField appearing in an API page layout is explicitly calculated before the record is returned. Microsoft does not rely on implicit calculation in API contexts.
