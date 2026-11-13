# Beautiful J2EE lints

The drop-in unit that turns the j2ee-best-practices skill into red-on-save
output:

- `checkstyle.xml` — the copy-in rules: naming, imports (no star imports),
  braces, line length (120), magic numbers outside tests, TODO comments,
  string equality, utility-class and equality/hash rules.
- **SpotBugs** — the second gate for null handling, ignored return values,
  equality and resource leaks. Use the SpotBugs plugin with an exclude filter
  reviewed like code; a new `@SuppressFBWarnings` names the rule and the
  reason.

## Running it

```bash
checkstyle -c lints/checkstyle.xml src
mvn -q spotbugs:check
```

`scripts/check-lints.sh` runs Checkstyle on the repository's clean control and
violation harness when Checkstyle is installed. When it is missing it prints a
visible `SKIP` and exits 0 — the gate runs in CI, where the tool is pinned,
never silently downgraded on a machine that has it.

## The check project

`lints/check/Clean.java` must stay quiet; `lints/check/Violations.java` holds
deliberate findings (a magic number, a star import, missing braces, a TODO, an
empty block). CI fails if either expectation breaks.

A `// CHECKSTYLE:OFF` or an `@SuppressFBWarnings` in product code names the
rule and the reason on the narrowest declaration. A module-wide suppression or
a disabled rule is a finding, not a fix.
