---
bc-version: [all]
domain: security
keywords: [permission-set, api-page, web-service, exposure, access-control]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Every exposed object must belong to a permission set

## Description

An object that is reachable from outside the app's own UI is only usable if it is also granted execute access through a permission set. Three distinct mechanisms make an object reachable this way, and each needs to be checked on its own terms: a page or query published through the **Web Services** configuration page; a custom REST endpoint declared with `PageType = API` / `QueryType = API`; or an individual codeunit method exposed with the `[ServiceEnabled]` attribute (a method-level attribute — it does not apply to pages or queries as a property). When such an object is left out of every permission set, it becomes both unusable (no caller, human or service, can reach it) and invisible in review: nobody deliberately decided who may call it. Exposure without a matching grant is not a safe default; it is an endpoint nobody is governing.

## Best Practice

Give every exposed object an explicit execute entry (`page "..." = X`, `query "..." = X`) in a permission set shipped by the app. Route sensitive endpoints into a dedicated, non-default admin permission set so reaching them requires a deliberate grant rather than being included by default. If an object should never be reachable from outside the app, remove the exposure itself (drop `PageType = API` / `ServiceEnabled`) rather than leaving an orphaned endpoint with no permission-set membership.

See sample: `exposed-objects-must-be-in-a-permission-set.good.al`.

## Anti Pattern

Granting access to the underlying table data while forgetting to grant execute access to the exposed page or query itself. The table looks fully covered by a permission set, but the API/service layer in front of it has no `= X` entry anywhere, so the endpoint silently fails for every caller even though the data permissions look complete.

See sample: `exposed-objects-must-be-in-a-permission-set.bad.al`.
