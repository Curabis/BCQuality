---
bc-version: [all]
domain: ui
keywords: [notification, recall, notification-id, createguid, notification-lifecycle-mgt, sendnotification, sendnotificationwithadditionalcontext, recallnotificationsforrecord, handledelayedinsert, notification-context]
technologies: [al]
countries: [w1]
application-area: [all]
---

# A notification that must be recalled needs an Id the code can find again

## Description

`Notification.Recall()` withdraws the notification whose `Id` it carries. When `Id` is left unassigned, `Send()` assigns one. A later `Recall()` on a new `Notification` variable has no way to name that Id, so a warning sent that way cannot be withdrawn when its condition clears. It stays until the user dismisses it or the page instance closes. Microsoft Learn's own `Id`/`Recall` example uses a predefined Id "so that the notification can be recalled". `Recall()` does not fail on a notification that was never sent or was already recalled, so code with a known Id can recall unconditionally.

Which Id is right depends on how many instances can be shown at once:

- **At most one at a time** (one condition per page or task): a fixed GUID, returned from a procedure or assigned as a literal. Base App's `Analysis View.ShowResetNeededNotification` assigns a literal Id, calls `Recall()`, then sets the message and calls `Send()`. Learn does not document what `Send()` does when a notification with the same Id is already displayed, so recall first rather than relying on `Send()` to replace it.
- **One per record** (for example one warning per document line): a single fixed Id cannot tell the records apart. Use codeunit 1511 `"Notification Lifecycle Mgt."`. `SendNotification(Notification, RecId)` assigns `CreateGuid()` when `Id` is null, sends, and stores the Id against the `RecordId` in the temporary table `"Notification Context"`. `RecallNotificationsForRecord(RecId, HandleDelayedInsert)` recalls every tracked notification for that record. When one record can carry several independent warnings, pass a fixed GUID per reason to `SendNotificationWithAdditionalContext` and `RecallNotificationsForRecordWithAdditionalContext`. `Item-Check Avail.` does this: a `CreateGuid()` Id per notification, its fixed availability GUID as the additional context.

## Best Practice

Assign a fixed `Id` to any single-instance notification that the same code path can also withdraw, and recall it with that Id before re-sending updated content. See sample: [`notification-recall-needs-known-id.good.al`](notification-recall-needs-known-id.good.al).

For per-record notifications, send and recall through `"Notification Lifecycle Mgt."` instead of calling `Send()`/`Recall()` directly. The codeunit is `SingleInstance`, so tracking lasts for the session. While a record does not exist yet, its notification is stored under the table's empty `RecordId`. Pass `HandleDelayedInsert = true` when recalling for a record that may not be inserted yet, and `false` when recalling after the record is deleted, as Base App's own delete subscribers do. Base App's `"Notification Lifecycle Handler"` (codeunit 1508) moves tracked notifications on insert and rename, and recalls them on delete, only for the Base App tables it subscribes to, such as `Sales Line`. For another table, call `SetRecordID`, `UpdateRecordID`, and `RecallNotificationsForRecord` from that table's own insert, rename, and delete paths.

## Anti Pattern

Code that both sends and recalls a notification, for example `Send()` when a condition holds and `Recall()` in the `else` branch or when the condition clears, but never assigns `Id`, or assigns a fresh `CreateGuid()` and calls `Send()`/`Recall()` directly. The `Recall()` cannot reach the notification that was sent. A single fixed Id shared by notifications for several records, sent and recalled directly, is the per-record form of the same mistake. See sample: [`notification-recall-needs-known-id.bad.al`](notification-recall-needs-known-id.bad.al).

Not this pattern: a one-off informational notification that the code never recalls, which Learn's own Sales Order example sends without an Id; and a notification sent through `"Notification Lifecycle Mgt."` without an Id, because the codeunit assigns and tracks one.

## References

- [Notification.Id method](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/notification/notification-id-method): an unassigned Id is assigned at `Send()`; the example sets a predefined Id so the notification can be recalled.
- [Notification.Recall method](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/notification/notification-recall-method): recalling more than once, or before sending, does not fail.
- [Using nonintrusive notifications](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-notifications-developing): notifications remain for the page instance or until dismissed.
- [NotificationLifecycleMgt.Codeunit.al](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/BaseApp/Modules/System/Notifications/NotificationLifecycleMgt.Codeunit.al): `SendNotification` and `SendNotificationWithAdditionalContext` (lines 17-36), `RecallNotificationsForRecord` (38-44), `GetUsableRecordId` (177-191). [NotificationLifecycleHandler.Codeunit.al](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/BaseApp/System/Notifications/NotificationLifecycleHandler.Codeunit.al): `Sales Line` insert, rename, and delete subscribers (lines 27-52).
- Base App usage: [AnalysisView.Table.al](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/BaseApp/Finance/Analysis/AnalysisView.Table.al) (`ShowResetNeededNotification`, lines 1039-1051) and [ItemCheckAvail.Codeunit.al](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/BaseApp/Inventory/Availability/ItemCheckAvail.Codeunit.al) (recall at lines 89-90, `CreateGuid()` Id and send at 636-646).
