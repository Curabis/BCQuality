---
bc-version: [all]
domain: testing
keywords: [test, feature, scenario, given, when, then, tags, bdd, atdd, comments]
technologies: [al]
countries: [w1]
application-area: [all]
---

## Description

CURABIS test codeunits follow a four-level comment structure that traces directly
to BDD/ATDD (Behaviour-Driven / Acceptance-Test-Driven Development):

| Tag | Scope | Purpose |
|---|---|---|
| `// [FEATURE]` | Codeunit header | The domain or module under test (e.g. `Find Price`) |
| `// [SCENARIO]` | Per test procedure | One falsifiable business claim |
| `// [GIVEN]` | Inside test body | Preconditions and test data setup |
| `// [WHEN]` | Inside test body | The single action being tested |
| `// [THEN]` | Inside test body | Assertions |

The `[FEATURE]` tag appears once as a comment at the top of the codeunit (before
`{`) and names the functional area — not the object name. The `[SCENARIO]` tag
appears as a comment immediately above each `[Test]` procedure; it describes the
business scenario in plain language, complementing the procedure name.

This structure makes tests readable as a living specification. A product owner
or QA engineer can scan the `[FEATURE]` + `[SCENARIO]` tags to understand
what is covered without reading AL.

## Anti Pattern

    // WRONG: no structure — tests as anonymous procedures
    codeunit 99006 "Find Price Testing"
    {
        Subtype = Test;

        [Test]
        procedure Test1()   // what does this test?
        begin
            // setup mixed with assertions, no clear layers
            Customer.Insert(false);
            FindPriceMgt.GetSalesPrice(Customer."No.", Item."No.", '', Price, Disc);
            Assert.AreEqual(100, Price, '');
        end;
    }

## Best Practice

    // [FEATURE] Find Price — price cascade (Customer → Price Group → All Customers)
    codeunit 99006 "Find Price Testing"
    {
        Subtype = Test;

        var
            WarecoLib: Codeunit "Wareco Test Library";
            Assert: Codeunit "Library Assert";

        // [SCENARIO] Customer with a specific price list line gets that unit price
        [Test]
        procedure GetPrice_CustomerPrice_ReturnsUnitPrice()
        var
            Customer: Record Customer;
            Item: Record Item;
            UnitPrice, LineDiscPct: Decimal;
        begin
            // [GIVEN] a customer with a price list line at 100 LCY
            WarecoLib.GivenCustomerWithPrice(Customer, Item, '', 100);
            // [WHEN]
            FindPriceMgt.GetSalesPrice(Customer."No.", Item."No.", '', UnitPrice, LineDiscPct);
            // [THEN]
            Assert.AreEqual(100, UnitPrice, 'Unit price must match customer price list');
        end;
    }

Every further `[Test]` procedure in the codeunit repeats the same pattern: its
own `[SCENARIO]` comment above the attribute, and `[GIVEN]`/`[WHEN]`/`[THEN]`
layers inside the body.

## Relationship to procedure naming

The procedure name and the `[SCENARIO]` comment are complementary — they say the
same thing in different registers:

- Procedure name: `GetPrice_CustomerPrice_ReturnsUnitPrice` — machine-readable,
  shows up in test runner output.
- `[SCENARIO]` comment: `Customer with a specific price list line gets that unit price`
  — human-readable, business language.

Both must be present. Neither replaces the other.
