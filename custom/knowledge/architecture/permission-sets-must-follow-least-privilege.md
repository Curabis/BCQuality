# CURABIS Architecture: Permission Sets Must Follow Least-Privilege Hierarchy

## Core Rule

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

```al
permissionset 50100 "PM365 - View"
{
    Access = Public;
    Assignable = true;
    Caption = 'Project Mgmt 365 - View';
    Permissions =
        tabledata "PM Project" = R,
        tabledata "PM Project Task" = R,
        page "PM Project List" = X,
        page "PM Project Card" = X;
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
```

## Relationship to CURABIS-ARCH-011

This rule is a **companion to CURABIS-ARCH-011** (`exposed-objects-must-be-in-a-permission-set`):

- **CURABIS-ARCH-011**: Every exposed object *must exist* in at least one permission set
- **This rule**: Permission sets *themselves* must follow the hierarchical least-privilege structure

Both must be satisfied simultaneously: it is not enough that objects appear in a permission set if that set grants excessive access.

## Anti-Pattern

```al
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
```

## BCApps Reference

BCApps Business Foundation defines exactly this tiered pattern:

```al
// BusFoundEdit.PermissionSet.al
permissionset 4 "Bus. Found. - Edit"
{
    Access = Public;
    Assignable = true;
    Caption = 'Business Foundation - Edit';
    IncludedPermissionSets = "Bus. Found. - View";
}
```

Microsoft uses Admin, Edit, View, Obj, and Read tiers with `IncludedPermissionSets` throughout BCApps — never a single flat "full access" set.

- **Source:** https://github.com/microsoft/BCApps/tree/main/src/Business%20Foundation/App/Permissions
- **Files:** `BusFoundAdmin`, `BusFoundEdit`, `BusFoundView`, `BusFoundObj`, `BusFoundRead`
- **Pattern:** Each tier inherits from the tier below via `IncludedPermissionSets`. Admin sets use `Assignable = false` to prevent accidental assignment to regular users.

## Verification

For each CURABIS app, confirm:
1. A `View` set exists for read-only roles
2. An `Edit` set exists and includes `View` via `IncludedPermissionSets`
3. An `Admin` set exists for setup objects, marked `Assignable = false`
4. No single flat set bundles both user-level and admin-level permissions
