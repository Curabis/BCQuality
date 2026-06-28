# CURABIS Testing: BCPT Scenarios Must Be App-Specific

## Core Rule

A PerformanceTest app must include BCPT scenario codeunits that exercise the **host app's own business flows** — not only the generic Microsoft scenarios (sales orders, purchase orders, GL entries). Generic scenarios measure BC's baseline performance; app-specific scenarios are the only way to detect performance regressions in the extension's own code.

## Key Principle

"A PerformanceTest app that contains only Microsoft's shipped BCPT samples provides no regression signal for the extension it was built to test."

## What Must Be Included

For every major business flow in the host app, create a corresponding `BCPT*` codeunit that:

1. Is a `SingleInstance = true` codeunit
2. Implements `"BCPT Test Param. Provider"` interface
3. Wraps the key operation in `BCPTTestContext.StartScenario()` / `BCPTTestContext.EndScenario()` blocks
4. Sets up all required data in a local `InitTest()` procedure — never depends on hardcoded records

## Example: Project Management App

```al
codeunit 80100 "BCPT Create Project" implements "BCPT Test Param. Provider"
{
    SingleInstance = true;

    trigger OnRun()
    begin
        if not IsInitialized then begin
            InitTest();
            IsInitialized := true;
        end;
        CreateProject(GlobalBCPTTestContext);
    end;

    var
        GlobalBCPTTestContext: Codeunit "BCPT Test Context";
        IsInitialized: Boolean;

    local procedure InitTest()
    begin
        // Set up any required BC configuration
    end;

    local procedure CreateProject(var BCPTTestContext: Codeunit "BCPT Test Context")
    begin
        BCPTTestContext.StartScenario('Create Project Header');
        // ... create project
        BCPTTestContext.EndScenario('Create Project Header');
        BCPTTestContext.UserWait();

        BCPTTestContext.StartScenario('Add Project Task');
        // ... add task
        BCPTTestContext.EndScenario('Add Project Task');
    end;

    procedure GetDefaultParameters(): Text[1000]
    begin
        exit('');
    end;

    procedure ValidateParameters(Parameters: Text[1000])
    begin
    end;
}
```

## Suggested Scenarios for Project Management Apps

| Scenario codeunit | What it measures |
|---|---|
| `BCPT Create Project` | Header + task creation overhead |
| `BCPT Post Time Entry` | Time registration and FlowField recalc performance |
| `BCPT Open Project List` | Page rendering under load |
| `BCPT Open Active Task List` | Filtered list performance |
| `BCPT Calculate Project Budget` | Aggregation codeunit performance |

## Anti-Pattern

A PerformanceTest app that only contains Microsoft's generic samples:
- `BCPTCreateSOWithNLines`
- `BCPTOpenCustomerList`
- `BCPTPostItemJournal`

...tests *Business Central*, not *your extension*. A regression in your codeunit will go undetected.

## BCApps Reference

The BCPT scenario pattern — `SingleInstance`, `"BCPT Test Param. Provider"`, named `StartScenario`/`EndScenario` blocks — is defined in BCApps Performance Toolkit. Microsoft's shipped samples are intended as **starting points and baselines**, not as complete test coverage for an extension.

- **Framework source:** https://github.com/microsoft/BCApps/tree/main/src/Tools/Performance%20Toolkit
- **Sample pattern:** `BCPTCreateSOWithNLines.Codeunit.al` in the Performance Toolkit samples shows the canonical codeunit structure to follow when building app-specific scenarios.
