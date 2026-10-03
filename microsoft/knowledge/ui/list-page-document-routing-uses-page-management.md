---
bc-version: [all]
domain: ui
keywords: [page-management, pagerun, show-document, document-type, cardpageid, list-page, page-run, getconditionalcardpageid, onconditionalcardpageidnotfound]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Open documents from a mixed-type list through Page Management

## Description

Some tables back several document pages, chosen by a type field. `Sales Header` rows open as Sales Quote, Sales Order, Sales Invoice, Sales Credit Memo, Blanket Sales Order, or Sales Return Order, depending on `Document Type`. A list over such a table cannot use one `CardPageID`. Codeunit 700 `"Page Management"` already holds that mapping. `PageRun(Rec)` resolves the page through `GetPageID`. That calls `GetConditionalCardPageID`, which handles `Sales Header`, `Purchase Header`, their archives, general and item journal batches and lines, requisition worksheets, and several other tables. When no conditional page applies, it falls back to the default card or lookup page. Base App's own lists call it: the `Show Document` actions on `Sales List` and `Purchase List`, `Sales Lines` (after getting the header), and `Navigate` for posted documents.

A hand-written `case Rec."Document Type" of ... Page.Run(Page::"Sales Order", Rec)` copies that mapping into a single action. The copy misses document types added later. It also bypasses routing that other extensions add through Page Management's events (`OnBeforeGetConditionalCardPageID`, `OnAfterGetPageID`, `OnPageRunAtFieldOnBeforeRunPage`).

## Best Practice

In the list's open-document action, call `PageManagement.PageRun(Rec)`, or `PageRunModal` or `PageRunList` as needed. `PageRun` returns `false` without opening anything when `GuiAllowed` is false or no page resolves. See sample: [`list-page-document-routing-uses-page-management.good.al`](list-page-document-routing-uses-page-management.good.al).

For a new table whose rows map to different pages, register the mapping once and then use `PageRun` everywhere. Subscribe to `OnConditionalCardPageIDNotFound`, which is raised only for tables the codeunit does not route itself. Microsoft's IRS Forms and Sustainability apps register their tables this way. `OnBeforeGetConditionalCardPageID` is the `IsHandled` alternative, used by the Quality Management app.

## Anti Pattern

An action trigger that switches on `Document Type`, or a similar type field, of a table that Page Management already routes, and calls `Page.Run(Page::..., Rec)` in each branch. Base App still has a few of these, for example `Sales Line Archive List`. The result is a duplicated mapping, not a runtime error, so report it as minor. See sample: [`list-page-document-routing-uses-page-management.bad.al`](list-page-document-routing-uses-page-management.bad.al).

Not this pattern:

- Opening one known document type directly. `Opportunity` creates a quote and runs `Sales Quote`, and a single-type list such as `Sales Order List` sets `CardPageID = "Sales Order"`.
- A table that Page Management does not route. `Assembly List` switches on `Assembly Header."Document Type"` itself. Registering the table through `OnConditionalCardPageIDNotFound` is an improvement there, not a defect fix.

## References

- [PageManagement.Codeunit.al](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/BaseApp/Utilities/PageManagement.Codeunit.al): `PageRun` (lines 44-47), `PageRunAtField` with the `GuiAllowed` exit (75-100), `GetPageID` fallback order (112-138), `GetConditionalCardPageID` (194-263; unrouted tables raise `OnConditionalCardPageIDNotFound` at 258), `GetSalesHeaderPageID` (289-315), integration events (671-719).
- Callers: [SalesList.Page.al](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/BaseApp/Sales/Document/SalesList.Page.al) (`ShowDocument`, lines 188-202; no `CardPageID`), [PurchaseList.Page.al](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/BaseApp/Purchases/Document/PurchaseList.Page.al) (line 200), [SalesLines.Page.al](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/BaseApp/Sales/Document/SalesLines.Page.al) (lines 224-230), [Navigate.Page.al](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/BaseApp/Foundation/Navigate/Navigate.Page.al) (from line 1564).
- Subscribers: [IRS1099BaseAppSubscribers.Codeunit.al](https://github.com/microsoft/BCApps/blob/main/src/Apps/US/IRSForms/app/src/Extensions/IRS1099BaseAppSubscribers.Codeunit.al) (lines 149-156), [SustWorkflowEventHandling.Codeunit.al](https://github.com/microsoft/BCApps/blob/main/src/Apps/W1/Sustainability/app/src/Workflow/SustWorkflowEventHandling.Codeunit.al) (lines 184-193), [QltyUtilitiesIntegration.Codeunit.al](https://github.com/microsoft/BCApps/blob/main/src/Apps/W1/Quality%20Management/app/src/Integration/Utilities/QltyUtilitiesIntegration.Codeunit.al) (lines 20-28).
- Counterexamples: [SalesLineArchiveList.Page.al](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/BaseApp/Sales/Archive/SalesLineArchiveList.Page.al) (lines 106-121), [AssemblyList.Page.al](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/BaseApp/Assembly/Document/AssemblyList.Page.al) (lines 111-121), [Opportunity.Table.al](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/BaseApp/CRM/Opportunity/Opportunity.Table.al) (lines 1221-1223), [SalesOrderList.Page.al](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/BaseApp/Sales/Document/SalesOrderList.Page.al) (line 44).
