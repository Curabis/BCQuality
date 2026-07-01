---
bc-version: [all]
domain: testing
keywords: [test, ui, testpage, naming, suffix, codeunit, page-testing]
technologies: [al]
countries: [w1]
application-area: [all]
---

## Description

Test codeunits that interact with pages via `TestPage` must carry a `_UT` suffix
(Unit Test — UI layer) in their name. This distinguishes them from codeunits that
test business logic directly by calling codeunit/table procedures.

The suffix signals to every reader that the codeunit opens pages, uses
`TestPage.OpenNew()`, reads FactBox parts, or drives field validates through
the page's `OnValidate` triggers — i.e. it exercises the UI layer, not just
the logic layer.

**Convention:**

| Layer tested | Suffix | Example |
|---|---|---|
| Business logic (codeunits, tables) | *(none)* | `FindPriceTesting` |
| Page / UI layer (`TestPage`) | `_UT` | `FindPriceTesting_UT` |

A codeunit may contain **only** UI tests or **only** logic tests — never mix both
in the same codeunit.

## Anti Pattern

    // WRONG: UI test codeunit without _UT suffix
    codeunit 99007 "Find Price Page Testing"
    {
        Subtype = Test;
        // contains TestPage calls — should be named "Find Price Testing_UT"
        ...
    }

    // WRONG: mixing direct codeunit calls and TestPage calls in the same codeunit
    codeunit 99007 "Find Price Testing"
    {
        Subtype = Test;

        [Test]
        procedure GetPrice_LogicTest()   // logic test — fine here
        begin
            FindPriceMgt.GetSalesPrice(...);
        end;

        [Test]
        procedure Page_ShowsPrice_UT()   // UI test — belongs in separate _UT codeunit
        var
            FindPricePage: TestPage "Find Price";
        begin
            FindPricePage.OpenNew();
            ...
        end;
    }

## Best Practice

    // CORRECT: separate codeunits per layer

    // Logic tests — no _UT suffix
    codeunit 99006 "Find Price Testing"
    {
        Subtype = Test;
        [Test]
        procedure GetPrice_CustomerPrice_ReturnsUnitPrice()
        begin
            FindPriceMgt.GetSalesPrice(...);
        end;
    }

    // UI tests — _UT suffix
    codeunit 99007 "Find Price Testing_UT"
    {
        Subtype = Test;
        [Test]
        procedure Page_EnterCustomerAndItem_FactBoxShowsPrice()
        var
            FindPricePage: TestPage "Find Price";
        begin
            FindPricePage.OpenNew();
            FindPricePage.CustomerNo.SetValue(Customer."No.");
            FindPricePage.ItemNo.SetValue(Item."No.");
            Assert.AreEqual('100,00', FindPricePage.FindPriceInfo.UnitPrice.Value(), '');
        end;
    }

## Object ID allocation

Allocate adjacent IDs for the two related codeunits (e.g. 99006 logic, 99007 UI)
so they sort together in the object list and their relationship is self-evident.
