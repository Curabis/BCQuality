---
bc-version: [15..]
domain: events
keywords: [getdatabasetabletriggersetup, onaftergetdatabasetabletriggersetup, globaltriggermanagement, global-triggers, ondatabaseinsert, ondatabasemodify, ondatabasedelete, ondatabaserename, change-log, var-parameter]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Database trigger setup flags may only be set to true

## Description

The `OnDatabaseInsert`, `OnDatabaseModify`, `OnDatabaseDelete`, and `OnDatabaseRename` events let one subscriber react to writes on any table, receiving the record as a `RecordRef`. They are opt-in per table: before raising them, the platform raises `GetDatabaseTableTriggerSetup(TableId; var OnDatabaseInsert; var OnDatabaseModify; var OnDatabaseDelete; var OnDatabaseRename)` on the system codeunit `Global Triggers` (2000000002), and every interested feature turns on the flags it needs for that table. Codeunit 49 `GlobalTriggerManagement` subscribes to it, collects the Dataverse integration and API webhook flags, raises its own integration event `OnAfterGetDatabaseTableTriggerSetup` with the same four `var` Booleans, and then adds the change log flags.

The four Booleans are shared by every subscriber in the chain, and subscribers run in no particular order. A subscriber that assigns `false`, or assigns an expression that can be `false` such as `OnDatabaseModify := MySetup.Get(TableId)`, overwrites what another feature already set for that table. The table then stops raising the database events, and features that rely on them (the change log, Dataverse synchronization, API webhook notifications, data archiving) stop working for it with no error. `GlobalTriggerManagement` asks the change log last in the normal execution context, and its comment says it does not want anyone to disable change log management. That ordering protects only the change log flags, and only against `OnAfterGetDatabaseTableTriggerSetup` subscribers. It does not protect the other features' flags, and it does not protect anything against another direct subscriber to `Global Triggers`.

## Best Practice

Subscribe to `GlobalTriggerManagement`'s integration events, `OnAfterGetDatabaseTableTriggerSetup` to opt in and `OnAfterOnDatabaseInsert`, `OnAfterOnDatabaseModify`, `OnAfterOnDatabaseDelete`, or `OnAfterOnDatabaseRename` to react. Microsoft Learn does not recommend subscribing directly to the events of system codeunits 2000000001..2000000010. Some Microsoft apps do, for example `Data Archive Db Subscriber`, and those subscriptions still compile and run.

In the setup subscriber, only turn on flags: `if IsTracked(TableId) then OnDatabaseModify := true;`, or `OnDatabaseModify := OnDatabaseModify or IsTracked(TableId);` as `Change Log Management` does. Turn on only the operations and tables the feature needs. In the handler, check `RecRef.Number` against the feature's own setup and skip temporary records, because the events also fire for every table another feature opted in. A statement such as `if not OnDatabaseDelete then OnDatabaseDelete := false;`, which appears in BCApps, cannot clear a flag and is not this anti-pattern.

See sample: [`database-trigger-setup-flags-may-only-be-set-to-true.good.al`](database-trigger-setup-flags-may-only-be-set-to-true.good.al).

## Anti Pattern

In a subscriber to `GetDatabaseTableTriggerSetup` (`Global Triggers`) or `OnAfterGetDatabaseTableTriggerSetup` (`GlobalTriggerManagement`), any assignment to one of the four `var` flags that can store `false` when the flag was already `true`. This includes a literal `false`, an assignment from a lookup or Boolean expression without `or` on the flag's current value, and `Clear` on the parameter.

A second, weaker signal: a subscriber to `OnDatabaseInsert`/`Modify`/`Delete`/`Rename` or to `OnAfterOnDatabase*` when the app has no setup subscriber that turns on the matching flag. The handler then runs only for tables that some other feature happened to opt in. Check the whole app before flagging this, because the opt-in can live in a different codeunit than the handler.

See sample: [`database-trigger-setup-flags-may-only-be-set-to-true.bad.al`](database-trigger-setup-flags-may-only-be-set-to-true.bad.al).

## References

- [Transitioning from codeunit 1 to system codeunits](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/upgrade/transition-from-codeunit1): `GetDatabaseTableTriggerSetup` and `OnDatabase*` moved to codeunit 49 `GlobalTriggerManagement`. It also advises against subscribing directly to system codeunits 2000000001..2000000010 and recommends the integration events instead.
- [Event types, global events](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-event-types#global-events): the codeunit 49 integration events. [Subscribing to events](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-subscribing-to-events): subscribers run one at a time in no particular order.
- `Global Triggers` (2000000002) in the System symbols: `GetDatabaseTableTriggerSetup` with four `var Boolean` parameters, and `OnDatabaseInsert/Modify/Delete(RecRef)` and `OnDatabaseRename(RecRef, xRecRef)`.
- [GlobalTriggerManagement.Codeunit.al](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/BaseApp/GlobalTriggerManagement.Codeunit.al): setup subscriber and change log comment (lines 51-65), `OnAfterGetDatabaseTableTriggerSetup` (173-174), `OnAfterOnDatabase*` (178-194).
- Only-true assignments in BCApps: `ChangeLogManagement.Codeunit.al` lines 85-88 (`or`), `APIWebhookNotificationMgt.Codeunit.al` 224-227, `CRMIntegrationManagement.Codeunit.al` 3748-3753, `MasterDataManagement.Codeunit.al` 1511-1516, and `DataArchiveDbSubscriber.Codeunit.al` 27-32 (turns on only `OnDatabaseDelete`, and skips temporary records in its handler).
