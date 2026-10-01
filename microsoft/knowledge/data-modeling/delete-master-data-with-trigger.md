---
bc-version: [all]
domain: data-modeling
keywords: [delete, deleteall, runtrigger, ondelete, master-data, currency, cleanup, data-migration]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Delete master and reference data with `Delete(true)` so the owning table's `OnDelete` decides

## Description

`Record.Delete()` and `Record.DeleteAll()` do not run `OnDelete` unless `RunTrigger` is `true`; the default is `false`. On a master or reference table, `OnDelete` is where Business Central decides whether the delete is safe and removes what the record owns. `Currency.OnDelete` refuses the delete while any **open** customer, vendor, or employee ledger entry uses the code, then deletes the currency's `Currency Exchange Rate` rows itself. `Customer.OnDelete` refuses when a job bills the customer, calls codeunit 361 `MoveEntries` (which refuses while ledger entries fall in an unclosed fiscal year or are still open, and otherwise detaches the closed history), and removes default dimensions, related data, and the contact link.

A cleanup, migration, or "remove obsolete codes" routine that calls `Delete()`/`DeleteAll()` without `true` on such a table skips all of it: it can remove a currency that open entries still use, and leaves exchange rates and other dependents orphaned. That a record *looks* obsolete — a superseded currency nobody posts in any more — is no evidence the guard would pass, and keeping a record that closed history still refers to is often the better choice. Where the master has a `Blocked` field, blocking rather than deleting is the usual way to retire it (see [`check-blocked-in-referencing-code-not-in-master`](check-blocked-in-referencing-code-not-in-master.md)); `Currency` has none.

## Best Practice

Outside the owning table's own triggers, delete master and reference records with `Delete(true)`/`DeleteAll(true)` and let `OnDelete` raise its error, as BCApps does when it removes items (`CatalogItemManagement`, `NewItem.Delete(true)`). This is the "trigger does work the caller depends on" case of [`pass-false-to-insert-when-trigger-not-needed`](../performance/pass-false-to-insert-when-trigger-not-needed.md); a hand-written reference check is no substitute for the guard.

Legitimate `false` deletes, not in scope: the owning table's own `OnDelete` cascade removing its dependents (`Currency.OnDelete` itself calls `CurrExchRate.DeleteAll()`; see [`owning-table-must-delete-dependents-in-ondelete`](owning-table-must-delete-dependents-in-ondelete.md)); temporary records and buffers; and a deliberate full reset whose caller first clears every reference itself, such as codeunit 1812 `"Data Migration Del G/L Account"` before a migration reload. Posted ledger entries are not master data; see [`do-not-modify-or-delete-posted-ledger-entries`](../finance/do-not-modify-or-delete-posted-ledger-entries.md).

See sample: [`delete-master-data-with-trigger.good.al`](delete-master-data-with-trigger.good.al).

## Anti Pattern

Code outside the owning table's `OnDelete` calls `Delete()`/`DeleteAll()` (or `false`) on a non-temporary master or reference table — `Currency`, `Customer`, `Vendor`, `Item`, `G/L Account`, or a custom equivalent with an `OnDelete` guard or cascade — typically from a filter on codes judged obsolete, without itself clearing every reference first.

See sample: [`delete-master-data-with-trigger.bad.al`](delete-master-data-with-trigger.bad.al).

## References

- [Record.Delete method](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-delete-method) and [Record.DeleteAll method](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-deleteall-method): `RunTrigger` "The default value is false."
- BCApps `src/Layers/W1/BaseApp/Finance/Currency/Currency.Table.al`, `OnDelete`, lines 797-820.
- BCApps `src/Layers/W1/BaseApp/Sales/Customer/Customer.Table.al`, `OnDelete`, lines 2401-2430; `src/Layers/W1/BaseApp/Utilities/MoveEntries.Codeunit.al`, `MoveCustEntries`, lines 126-167.
- BCApps `src/Layers/W1/BaseApp/Inventory/Item/Catalog/CatalogItemManagement.Codeunit.al`, line 419.
- BCApps `src/Layers/W1/BaseApp/System/DataMigration/DataMigrationDelGLAccount.Codeunit.al`, lines 18-41.
