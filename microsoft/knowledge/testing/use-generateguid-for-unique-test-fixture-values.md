---
bc-version: [all]
domain: testing
keywords: [generateguid, library-utility, test-fixtures, uniqueness, generaterandomcode, maxstrlen]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Generate unique test fixture values with LibraryUtility helpers, not hardcoded literals

## Description

A fixture helper that assigns a hardcoded literal to a primary-key or descriptive field collides the moment two tests, or two runs of the same test, create that fixture without cleanup, and a literal longer than the field allows raises a truncation or insert error. `LibraryUtility.GenerateGUID()` is not a real GUID — it is a `Code[10]` number-series value (`GU00000000`–`GU99999999`) — and it returns the full 10 characters unshortened. Truncating it yourself with `CopyStr(..., 1, MaxStrLen(ShorterField))` for a field under 10 characters is unsafe: the changing digits sit at the right end and are exactly what gets cut off, so consecutive calls into a short field can produce the same truncated value. `GenerateGUID()` is only safe as-is for a field that holds the full 10 characters.

## Best Practice

For a field that holds the full 10 characters, assign `LibraryUtility.GenerateGUID()` directly. For a shorter or arbitrary-length field, use `LibraryUtility.GenerateRandomCode(FieldNo, TableNo)` (or `GenerateRandomCodeWithLength`/`GenerateRandomXMLText(Length)` for a specific length) instead of truncating a GUID yourself — these generate the value and verify it is actually unique against the target table, rather than relying on the number series alone.

See sample: `use-generateguid-for-unique-test-fixture-values.good.al`.

## Anti Pattern

Hardcoding a fixture value such as `'TEST001'` or a short descriptive literal, which collides across parallel or repeated test runs. Equally an anti-pattern: truncating `GenerateGUID()`'s result with `CopyStr(..., 1, MaxStrLen(Field))` for a field shorter than 10 characters — the truncation removes the part of the value that actually varies.

See sample: `use-generateguid-for-unique-test-fixture-values.bad.al`.
