---
bc-version: [all]
domain: architecture
keywords: [permission-set, least-privilege, tiers, security]
technologies: [al]
countries: [w1]
application-area: [all]
---
# CURABIS Architecture: Permission Sets Must Follow Least-Privilege Hierarchy

## Description

Permission sets in CURABIS apps must be structured in access tiers following the least-privilege principle. Tiers must be **additive** — each tier includes the one below it via `IncludedPermissionSets`. No single permission set should bundle user-level and administrative access in a flat structure.

## Required Tier Structure

| Tier | Suffix | Purpose | Assignable |
|------|--------|---------|-----------|
| View | `View` | Read-only access to records and pages | Yes |
| Edit | `Edit` | Full data entry; includes View | Yes |
| Admin | `Admin` | Setup tables and configuration; includes Edit | No (restrict to admins) |
| Object | `Obj` | Object-level access for integration/automation | No |

## Key Principle

"Grant the minimum access required for the role. An end user who enters data needs Edit, not Admin. An integration service needs Obj, not a named user set."

## Implementation Pattern

    permissionset 50100 "PM365 - View"
    {
        Access = Public;
        Assignable = true;
        Caption = 'Project Mgmt 365 - View';
        Permissions =
            tabledata "PM Project" = R,
            page "PM Project List" = X;
    }

    permissionset 50101 "PM365 - Edit"
    {
        Access = Public;
        Assignable = true;
        Caption = 'Project Mgmt 365 - Edit';
        IncludedPermissionSets = "PM365 - View";
        Permissions =
            tabledata "PM Project" = RIMD,
            tabledata "PM Project Task" = RIMD,
            codeunit "PM Project Management" = X;
    }

    permissionset 50102 "PM365 - Admin"
    {
        Access = Public;
        Assignable = false;
        Caption = 'Project Mgmt 365 - Admin';
        IncludedPermissionSets = "PM365 - Edit";
        Permissions =
            tabledata "PM Setup" = RIMD,
            page "PM Setup" = X;
    }

## Relationship to CURABIS-ARCH-011

Companion to **CURABIS-ARCH-011** (`exposed-objects-must-be-in-a-permission-set`):
ARCH-011 requires every exposed object to *exist* in a permission set; this rule
requires the sets *themselves* to follow the tiered least-privilege structure.
Both must hold — objects in a set that grants excessive access is not enough.

## Anti-Pattern

    // Violation: flat "full access" set bundles user and admin access
    permissionset 50100 "PM365 - Full Access"
    {
        Assignable = true;
        Permissions =
            tabledata "PM Project" = RIMD,
            tabledata "PM Setup" = RIMD,    // admin data mixed with user data
            tabledata "PM Project Task" = RIMD,
            codeunit "PM Post Codeunit" = X;
    }

## BCApps Reference

BCApps Business Foundation defines exactly this tiered pattern: Microsoft uses
Admin, Edit, View, Obj, and Read tiers with `IncludedPermissionSets` throughout —
never a single flat "full access" set. Each tier inherits from the tier below;
Admin sets use `Assignable = false` to prevent accidental assignment to regular
users.

- **Source:** https://github.com/microsoft/BCApps/tree/main/src/Business%20Foundation/App/Permissions
- **Files:** `BusFoundAdmin`, `BusFoundEdit`, `BusFoundView`, `BusFoundObj`, `BusFoundRead`

## Verification

For each CURABIS app, confirm:
1. A `View` set exists for read-only roles
2. An `Edit` set exists and includes `View` via `IncludedPermissionSets`
3. An `Admin` set exists for setup objects, marked `Assignable = false`
4. No single flat set bundles both user-level and admin-level permissions
