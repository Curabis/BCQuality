---
bc-version: [all]
domain: data-modeling
keywords: [insert, runtrigger, oninsert, master-data, no-series, customer, item, import]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Create master records with `Insert(true)` unless the caller does the trigger's work itself

## Description

`Record.Insert()` does not run `OnInsert`: `RunTrigger` defaults to `false`. On a standard master table that trigger initializes the record. `Customer.OnInsert` assigns `No.` and `No. Series` from Sales & Receivables Setup when `No.` is blank, then defaults `Invoice Disc. Code` and the salesperson, creates the contact, syncs `Global Dimension 1/2 Code` from existing Default Dimension rows (`DimMgt.UpdateDefaultDim` creates no default dimensions), calls `UpdateReferencedIds`, and sets the last-modified timestamp. `Item.OnInsert` assigns `No.`, `No. Series`, and `Costing Method` when `No.` is blank and always runs the dimension sync and `UpdateReferencedIds`.

A bare `Insert()` produces a row that looks complete but lacks what downstream code assumes: with a blank `No.` the key stays blank; with a supplied `No.` the contact, defaults, and timestamps are silently missing. This is the caller-side counterpart of [`master-table-no-from-number-series-in-oninsert`](master-table-no-from-number-series-in-oninsert.md): that design only works when callers run the trigger.

## Best Practice

When code creates a record in `Customer`, `Vendor`, `Item`, `G/L Account`, `Contact`, or a custom master with initializing `OnInsert` logic, call `Insert(true)`, then validate fields and `Modify(true)`. Importing from an external source is not an exception: BCApps' data-migration facades (`CustomerDataMigrationFacade`, `ItemDataMigrationFacade`, `GLAccDataMigrationFacade`) use `Insert(true)`. This is the "trigger does work the caller depends on" case of [`pass-false-to-insert-when-trigger-not-needed`](../performance/pass-false-to-insert-when-trigger-not-needed.md); the decision stays per call.

Legitimate `Insert()` calls, not in scope: temporary records and buffer or staging tables; a caller that visibly assigns what the trigger would and then applies a template (`CatalogItemManagement.CreateNewItem` sets `No.` and `Costing Method` before `Item.Insert()`); and an XMLport that round-trips complete rows exported from Business Central (`ExportItemData`). `Modify()` without the trigger is routine on masters for technical fields and is not covered. Upgrade code that bypasses triggers is covered by [`datatransfer-skips-triggers-and-subscribers`](../upgrade/datatransfer-skips-triggers-and-subscribers.md).

See sample: [`master-data-must-be-inserted-with-trigger.good.al`](master-data-must-be-inserted-with-trigger.good.al).

## Anti Pattern

Code creates a non-temporary master record with `Init`, field assignments or `Validate` calls, and `Insert()`/`Insert(false)`, without itself assigning the number and the other fields `OnInsert` would set.

See sample: [`master-data-must-be-inserted-with-trigger.bad.al`](master-data-must-be-inserted-with-trigger.bad.al).

## References

- [Record.Insert(Boolean) method](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-insert-boolean-method): "If this parameter is false, the code in the OnInsert trigger is not executed. The default value is false."
- BCApps `src/Layers/W1/BaseApp/Sales/Customer/Customer.Table.al`, `OnInsert`, lines 2432-2472; `src/Layers/W1/BaseApp/Inventory/Item/Item.Table.al`, `OnInsert`, from line 2587.
- BCApps `src/Layers/W1/BaseApp/Finance/Dimension/DimensionManagement.Codeunit.al`, `UpdateDefaultDim`, lines 894-913.
- BCApps `src/Layers/W1/BaseApp/Inventory/Item/Catalog/CatalogItemManagement.Codeunit.al`, `CreateNewItem`, lines 545-565; `src/Layers/W1/BaseApp/Inventory/Item/ExportItemData.XmlPort.al`, line 405.
- BCApps `src/Layers/W1/BaseApp/System/DataMigration/`: `CustomerDataMigrationFacade.Codeunit.al` line 67, `ItemDataMigrationFacade.Codeunit.al` line 76, `GLAccDataMigrationFacade.Codeunit.al` line 77.
