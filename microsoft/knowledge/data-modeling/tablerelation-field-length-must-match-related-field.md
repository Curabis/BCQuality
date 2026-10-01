---
bc-version: [all]
domain: data-modeling
keywords: [tablerelation, field-length, code, text, conditional-relation, lookup]
technologies: [al]
countries: [w1]
application-area: [all]
---

# A TableRelation field's length must match the related field

## Description

`TableRelation` points a field at another table, or at a specific field of it with `Table.Field`. The relation is also used to validate entries and to drive the lookup. A referencing field that is shorter than the related field compiles without a length diagnostic: verified with AL compiler 30.0 and the CodeCop, UICop and PerTenantExtensionCop analyzers. Compare `AL0685`, which does warn about an analogous length mismatch for a FlowField's `CalcFormula` target.

A shorter field compiles cleanly and works for every value that happens to fit. It fails only when a real related value is longer than the field. For example, a `Code[10]` field related to a table with a `Code[20]` key fails when a user picks a 15-character code through the lookup. The runtime error reads "The length of the string is N, but it must be less than or equal to M characters."

The length Business Central's own relation check expects depends on whether the field has an unconditional relation:

- **At least one unconditional relation**, either a plain `TableRelation = X` or an unconditional branch: the field must have the **exact** length of the longest related field and the same type.
- **Only conditional relations** (`if (...) X else if (...) Y`): the field must be **at least** as long as the longest related field. A longer field is accepted, and a `Code` relation may be stored in a `Text` field.

The check is codeunit 134926 "Table Relation Test" in the BC test app. Its validation test is `[Scope('OnPrem')]`, so it runs only on an on-premises test surface. It is not a compile-time guarantee. See [`table-relation-test-exclude-known-invalid-relations-via-event.md`](../testing/table-relation-test-exclude-known-invalid-relations-via-event.md) for how that check evaluates relations and how to exclude a known exception.

## Best Practice

Before you add or change a `TableRelation`, read the declared type and length of every related field from its table definition. Lengths vary from table to table, so don't assume a typical `Code[10]` or `Code[20]`. Then size the field:

- For an unconditional relation, give it the same type and exact length as the related field.
- For an all-conditional relation, make it at least as long as the longest branch target.

When a `tableextension` adds a branch with `modify(...)`, check the new target's length against the field's existing declaration too.

See sample: [`tablerelation-field-length-must-match-related-field.good.al`](tablerelation-field-length-must-match-related-field.good.al).

## Anti Pattern

A field whose declared `Code`/`Text` length is shorter than the field it relates to. One example is a `Code[10]` field with `TableRelation` to a table keyed on `Code[20]`. Another is a conditional relation where one branch targets a longer field than the declaration. Both compile without a diagnostic and fail at runtime once a real, longer value is used.

A field that is longer than its related field under an unconditional relation is a lesser deviation. It holds every valid value, but it fails Business Central's relation test and accepts values that can never satisfy the relation.

See sample: [`tablerelation-field-length-must-match-related-field.bad.al`](tablerelation-field-length-must-match-related-field.bad.al).

Related: [`transferfields-mirrored-fields-must-match-type-and-length.md`](transferfields-mirrored-fields-must-match-type-and-length.md) covers the same length-mismatch failure between fields that `TransferFields` connects.

## Source

- [TableRelation property](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-tablerelation-property): syntax `<TableName>[.<FieldName>]`, conditional `IF ... ELSE` relations, and use of the relation to validate entries.
- [Compiler Warning (future error) AL0685](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al685): the analogous FlowField length diagnostic, which warns that the mismatch "could result in a runtime error".
- BCApps [`src/Layers/W1/Tests/Misc/TableRelationTest.Codeunit.al`](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/Tests/Misc/TableRelationTest.Codeunit.al): line 46 says "Fields must have the exact length of the largest field they relate to". Lines 68-84 apply `Field.Len < MaxRelatedFieldLength` when every relation is conditional and `Field.Len <> MaxRelatedFieldLength` otherwise. Line 15 is `[Scope('OnPrem')]`.
- BCApps [`src/Apps/W1/Subcontracting/Test/Tests/SubcCommentsAttachmentTest.Codeunit.al`](https://github.com/microsoft/BCApps/blob/main/src/Apps/W1/Subcontracting/Test/Tests/SubcCommentsAttachmentTest.Codeunit.al) line 295 asserts the runtime text "The length of the string is 101".
