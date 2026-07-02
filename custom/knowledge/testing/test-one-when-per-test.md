---
bc-version: [all]
domain: testing
keywords: [test, when, scenario, single-action, bdd, atdd, given-when-then]
technologies: [al]
countries: [w1]
application-area: [all]
---

## Description

Each test procedure must contain exactly **one** `[WHEN]` block — one action that
triggers the behaviour under test. A test with multiple WHENs ("do A, then do B,
then check C") is really two or more tests in disguise. Split them.

This constraint serves two purposes:

1. **Failure isolation** — when the test fails you know which action caused it.
2. **Readable specification** — each test reads as a single, falsifiable claim
   about the system's behaviour.

A scenario that genuinely requires a precondition action (e.g. "post an order so
that a ledger entry exists") belongs in `[GIVEN]`. Only the action being asserted
belongs in `[WHEN]`.

## Anti Pattern

    // WRONG: two actions in one test
    [Test]
    procedure GetPrice_ThenGetDiscount_ReturnsCorrectValues()
    var
        UnitPrice, LineDiscPct: Decimal;
    begin
        // [GIVEN] ...
        // [WHEN] first action
        FindPriceMgt.GetSalesPrice(CustomerNo, ItemNo, '', UnitPrice, LineDiscPct);
        // [WHEN] second action — this is a second test in disguise
        FindPriceMgt.GetSalesPriceTiers(CustomerNo, ItemNo, '', TempBuffer);
        // [THEN] asserting two unrelated things
        Assert.AreEqual(100, UnitPrice, '');
        Assert.IsFalse(TempBuffer.IsEmpty(), '');
    end;

## Best Practice

    // CORRECT: split into two focused tests

    [Test]
    procedure GetPrice_CustomerPrice_ReturnsCorrectUnitPrice()
    var
        UnitPrice, LineDiscPct: Decimal;
    begin
        // [GIVEN] a customer with a price list line at 100
        WarecoLib.GivenCustomerWithPrice(Customer, Item, '', 100);
        // [WHEN]
        FindPriceMgt.GetSalesPrice(Customer."No.", Item."No.", '', UnitPrice, LineDiscPct);
        // [THEN]
        Assert.AreEqual(100, UnitPrice, 'Unit price must match price list');
    end;

    [Test]
    procedure GetPriceTiers_CustomerTier_ReturnsOneTierLine()
    var
        TempBuffer: Record "Find Price Tier Buffer" temporary;
    begin
        // [GIVEN] a customer with a tier price at min qty 10
        WarecoLib.GivenCustomerWithTierPrice(Customer, Item, '', 10, 90);
        // [WHEN]
        FindPriceMgt.GetSalesPriceTiers(Customer."No.", Item."No.", '', TempBuffer);
        // [THEN]
        Assert.AreEqual(1, TempBuffer.Count(), 'Exactly one tier line expected');
    end;

## Flow tests — the deliberate exception

A **flow test** verifies the accumulated outcome of a multi-round business
flow (partial receipt then invoicing, multiple posting rounds against one
document). The sequence IS the scenario — splitting it loses the interaction
under test. Multiple `[WHEN]` blocks are permitted when ALL of these hold:

1. The name declares the flow (`SVPartialFlowTests`,
   `ReceiveThenInvoice_QuantitiesAreCorrect`).
2. Each `[WHEN]` is labelled as a round of ONE scenario ("Runde 1: kun
   modtagelse"), not as an unrelated action.
3. The `[THEN]` asserts the accumulated end-state. If the assertions
   decompose cleanly per action, it is two tests in disguise: split.

Unit-level tests keep the strict one-WHEN rule without exception. (Edison
eval 2026-07-02, Jernpladsen @ b7656b1: five deliberate round-labelled flow
procedures in SVPartialFlowTests — the rule previously gave no verdict.)

## Naming implication

The procedure name should make the single WHEN self-evident.
A name with "And" or "Then" in the middle is a strong signal to split:

- `GetPrice_AndDiscount_ReturnsValues` → split
- `GetPrice_CustomerPrice_ReturnsUnitPrice` → good
- `ReceiveThenInvoice_QuantitiesAreCorrect` → legitimate flow test IF the
  flow-test conditions above are met
