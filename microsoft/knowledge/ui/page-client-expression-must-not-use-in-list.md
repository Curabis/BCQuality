---
bc-version: [all]
domain: ui
keywords: [client-expression, in-list, inlistexpression, al0573, al0322, enabled, visible, editable, dynamic-enable]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Page client-expression properties must not use an `in [...]` list

## Description

`Enabled`, `Visible`, `Editable`, and `StyleExpr` on page controls can be bound to a client expression instead of a literal. The documented dynamic forms are a global Boolean page variable, a Boolean field, or a Boolean expression over fields such as `"Credit Limit" > "Sales YTD"`; plain `=`/`<>`/`>` comparisons combined with `and`/`or`/`not` are valid. An `in [...]` set-membership test, such as `Rec.Status in [Rec.Status::New, Rec.Status::"Needs Review"]`, is not: the compiler reports it as "InListExpression is not valid for client expressions. Client expressions can only use simple data types and field references."

The severity depends on the control. On a page field the diagnostic is already an error (AL0322). On an action, group, or part it is AL0573, a warning that "will become an error in a future release", so the code still builds and is easy to ship, suppress in a ruleset, or carry forward. A procedure call in the same property position is rejected by the same diagnostics, so moving the list test into a method called from the property does not fix it.

## Best Practice

Express the condition in a form a client expression accepts. For a short list, rewrite the membership as an `or` chain of field comparisons, which keeps the property a live client expression. For a longer or computed condition, evaluate it in AL (an `in [...]` list is fine there), store the result in a global page `Boolean` variable, and bind the property to that variable. Recompute the variable wherever its inputs change: `OnAfterGetRecord` for record navigation, and the `OnValidate` of each page field the condition reads for in-place edits.

For `Visible` on field and action controls, the Visible property documentation requires the variable to be resolved in `OnInit` or `OnOpenPage`; do not rely on per-record recomputation to show and hide those controls. `Enabled` and `Editable` have no such restriction. See sample: [`page-client-expression-must-not-use-in-list.good.al`](page-client-expression-must-not-use-in-list.good.al).

## Anti Pattern

A page or pageextension control property `Enabled`, `Visible`, `Editable`, or `StyleExpr` whose value contains `in [`, typically an enum or option field tested against several values. Reviewer signal: the `in [` token appears directly in the property value rather than inside a trigger or procedure body. Replacing it with a call to a procedure that performs the same test is the same defect in a different shape.

Do not flag plain comparisons joined with `and`/`or`, such as `Enabled = (Rec.Status = Rec.Status::New) or (Rec.Status = Rec.Status::"Needs Review");`; they compile cleanly and are common in the base application. Do not flag `in [...]` used inside procedures or triggers that assign a Boolean variable. See sample: [`page-client-expression-must-not-use-in-list.bad.al`](page-client-expression-must-not-use-in-list.bad.al).

## References

- [Enabled property](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-enabled-property): dynamic values are a Boolean variable, a Boolean field, or a Boolean expression such as "Credit Limit > Sales YTD"; variables must be global page variables.
- [Visible property](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-visible-property): variables for field and action controls must be resolved by `OnInit` or `OnOpenPage`.
- [Compiler warning AL0573](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al573) and [compiler error AL0322](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al322). The Learn pages show only the `{0}` template; the compiler's message for this case is "InListExpression is not valid for client expressions. Client expressions can only use simple data types and field references." (AL compiler 30.0: AL0573 for action, group, and part properties; AL0322 for page field properties).
- Comparison-based client expressions in BCApps, for example `Enabled = Rec.Status <> Rec.Status::Running;` in [BCPTSetupCard.Page.al](https://github.com/microsoft/BCApps/blob/main/src/Tools/Performance%20Toolkit/App/src/BCPTSetupCard.Page.al). BCApps contains no page client expression that uses an `in [...]` list.
