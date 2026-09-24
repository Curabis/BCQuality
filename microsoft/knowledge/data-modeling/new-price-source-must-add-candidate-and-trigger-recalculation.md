---
bc-version: [all]
domain: data-modeling
keywords: [price-calculation, price-source, onafteraddsources, recalculation, pricing]
technologies: [al]
countries: [w1]
application-area: [all]
---

# A new price source needs both a calculation candidate and a recalculation trigger

## Description

Making a custom field usable as a price source on a sales line is two
separate, independent pieces of wiring, and doing only one produces a
line that looks like it's using the new source without ever actually
being priced by it. `codeunit "Sales Line - Price"` publishes
`OnAfterAddSources(SalesHeader: Record "Sales Header"; SalesLine: Record
"Sales Line"; PriceType: Enum "Price Type"; var PriceSourceList: Codeunit
"Price Source List")` — subscribing here and calling
`PriceSourceList.Add(SourceType, SourceNo)` makes the source a candidate
the calculation considers. But nothing about that subscription causes
the price to be *recalculated* when the source field's value changes on
an existing line. That's the second, separate piece: `Sales Line`'s own
`procedure UpdateUnitPriceByField(CalledByFieldNo: Integer)` must be
called from the source field's own trigger — the same way Microsoft's
own Location example is wired from a `Sales Line` validation event, not
from the price source registration itself.

Add the source without wiring recalculation, and the failure hides
easily: a *new* line still prices correctly, because the field already
holds its value when calculation first runs on insert. The gap only
shows up when someone *changes* the source field's value on an existing
line — the price silently keeps its old value until something unrelated
happens to trigger recalculation.

## Best Practice

Wire both halves together whenever a field becomes a price source: an
`OnAfterAddSources` subscriber that adds it via `PriceSourceList.Add`, and
a trigger on the field itself (its own `OnValidate`, or a matching
`OnAfterValidate` integration event) that calls
`SalesLine.UpdateUnitPriceByField(SalesLine.FieldNo(<TheField>))`.

See sample: [`new-price-source-must-add-candidate-and-trigger-recalculation.good.al`](new-price-source-must-add-candidate-and-trigger-recalculation.good.al).

## Anti Pattern

Subscribing to `OnAfterAddSources` to register a custom field as a price
source, without also triggering recalculation from that field's own
validation. The field is a genuine, working calculation candidate — new
lines price correctly — but editing the field on an existing line leaves
the unit price stale, with nothing to indicate why.

See sample: [`new-price-source-must-add-candidate-and-trigger-recalculation.bad.al`](new-price-source-must-add-candidate-and-trigger-recalculation.bad.al).

## Source

BCApps (`src/Layers/W1/BaseApp/`): `Sales/Pricing/SalesLinePrice.Codeunit.al`
(`local procedure OnAfterAddSources(SalesHeader: Record "Sales Header";
SalesLine: Record "Sales Line"; PriceType: Enum "Price Type"; var
PriceSourceList: Codeunit "Price Source List")`); `Pricing/Source/PriceSourceList.Codeunit.al`
(`procedure Add(SourceType: Enum "Price Source Type"; SourceNo: Code[20])`);
`Sales/Document/SalesLine.Table.al` (`procedure
UpdateUnitPriceByField(CalledByFieldNo: Integer)`).

Microsoft Learn, "Extending Price Calculations" (Location example): "To
recalculate the price, we can subscribe to events that pass the sales
line by reference... We'll call the UpdateUnitPriceByLocationCode()
method, which is a simplified version of the UpdateUnitPriceByField()
method... To add the location in the source list for price calculations,
we'll subscribe to the OnAfterAddSources event of Codeunit 'Sales Line -
Price,' and add the Location Code as a source."
(https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-extending-best-price-calculations)
