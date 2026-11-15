## 2.0.1 - 2026-11-04

- Restore active mention queries after newlines and tabs, matching multiline draft restoration.
- Guard invalid caret offsets while preserving the controller owner's editing value.
- Retain pending debounce cancellation and callback cleanup on disposal.

## 2.0.0 - 2026-11-04

- Require Flutter >=3.47.0 and Dart >=3.13.0 <4.0.0 for this SDK update.
- Refresh package and example dependency constraints to current stable releases as of 2026-11-04, subject to documented upstream compatibility constraints.
- Validate with Flutter 3.47.8 / Dart 3.13.7 using fix, format, static analysis, and package/example tests.
- Cancel pending mention searches and clear the search callback on dispose; tolerate callback removal while a search is pending.
- Render mention spans when no base text style is supplied.
- Migrate the example Android plugins and web bootstrap to current Flutter workflows.

## 0.0.1

* TODO: Describe initial release.
