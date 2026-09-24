---
bc-version: [all]
domain: data-modeling
keywords: [price-calculation, price-calculation-handler, price-calculation-setup, integration-event, pricing]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Activate a new Price Calculation Handler through OnFindSupportedSetup, not just by implementing it

## Description

`enum 7011 "Price Calculation Handler"` (`implements "Price
Calculation"`) is how a new pricing engine plugs into Business Central —
extend the enum with a value pointing at a codeunit that implements the
`Price Calculation` interface. That alone does not make the new handler
usable on any document. `codeunit 7001 "Price Calculation Mgt."` decides
which handler applies to a given line by looking up `table 7006 "Price
Calculation Setup"`, a table of `(Code, Method, Type, Asset Type,
Implementation, Enabled, Default)` rows populated at startup by its own
`OnFindSupportedSetup` event — every implementation codeunit is expected
to subscribe to that event and insert its own setup row(s). A handler
enum value with no matching setup row is real and selectable in the enum
itself, but never chosen for any actual sale, purchase, or job line,
because `Price Calculation Mgt.` has no setup row that names it. A setup
row that exists but doesn't match is just as invisible: `FindSetup`
filters candidates with `SetRange(Default, true)` and `SetRange(Method,
DtldPriceCalcSetup.Method)` (a document's blank Method is normalized to
`"Lowest Price"` before that filter runs), so a row inserted without
`Default := true`, or with a `Method` that doesn't match, is never
selected either — same symptom, different cause.

## Best Practice

Ship a new `Price Calculation Handler` value together with an
`OnFindSupportedSetup` subscriber that inserts at least one `Price
Calculation Setup` record naming it as the `Implementation`, for the
relevant `Method` (e.g. `"Lowest Price"`), `Type` (`Sale`/`Purchase`), and
`Asset Type` — with `Default := true`, since `FindSetup` only considers
rows where `Default` is set when resolving a handler for a line.

See sample: `activate-new-price-calculation-handler-via-onfindsupportedsetup.good.al`.

## Anti Pattern

Extending `Price Calculation Handler` and implementing the `Price
Calculation` interface, without subscribing to `OnFindSupportedSetup` to
insert a setup record. The new handler exists, compiles, and can even be
selected manually if a user creates their own `Price Calculation Setup`
row through the UI — but ships with no default row, so it's never active
for anyone until someone notices it's missing and configures it by hand.

See sample: `activate-new-price-calculation-handler-via-onfindsupportedsetup.bad.al`.

## Source

BCApps (`src/Layers/W1/BaseApp/Pricing/Calculation/`):
`PriceCalculationHandler.Enum.al` (`enum 7011 "Price Calculation Handler"
implements "Price Calculation"`); `PriceCalculationMgt.Codeunit.al`
(`local procedure OnFindSupportedSetup(var TempPriceCalculationSetup:
Record "Price Calculation Setup" temporary)`, called during setup
resolution, and `procedure FindSetup(...)`, which requires
`SetRange(Default, true)` and a matching `SetRange(Method,
DtldPriceCalcSetup.Method)` before a row can be selected);
`PriceCalculationSetup.Table.al` (`table 7006 "Price Calculation Setup"`:
`Code` (Code[100]), `Method` (Enum "Price Calculation Method"), `Type`
(Enum "Price Type"), `"Asset Type"` (Enum "Price Asset Type"),
`Implementation` (Enum "Price Calculation Handler"), `Enabled` (Boolean),
`Default` (Boolean)).

BCApps (`src/Layers/W1/BaseApp/Pricing/PriceList/`): `PriceType.Enum.al`
(`enum 7009 "Price Type"`: `Any`(0)/`Sale`(1)/`Purchase`(2)).

Microsoft Learn, "Extending Price Calculations": "For the new codeunit,
you must extend the Price Calculation Handler enum that implements Price
Calculation interface... Afterwards you can insert a record in the Price
Calculation Setup table... Each codeunit that implements the Price
Calculation interface must subscribe to the OnFindSupportedSetup() event
of the Price Calculation Mgt codeunit to fill the price calculation setup
table with new options."
(https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-extending-best-price-calculations)
