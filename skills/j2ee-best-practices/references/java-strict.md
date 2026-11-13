# Java strict for J2EE

The Java 21 subset and the type patterns that make an enterprise backend hard
to break.

## 1. The subset

- Java 21 LTS; records for value objects; sealed interfaces for closed unions.
- `final` classes by default; composition over inheritance; no setters.
- Nullability is explicit: `Optional` for a lookup result, never for a field
  or a parameter; no returning `null` from a public method without a reason.
- `var` for locals when the type is obvious; explicit types at boundaries.
- No `@SuppressWarnings`/`@SuppressFBWarnings`/`CHECKSTYLE:OFF` without a
  reason on the narrowest declaration.

## 2. Result

```java
public sealed interface Result<T> permits Success, Failure {
    record Success<T>(T value) implements Result<T> {}
    record Failure<T>(AppError error) implements Result<T> {}
}
```

- Expected failures are values; exceptions are for invariant violations.
- A resource maps `Result` to a response; a use case never throws for
  "not found" or "conflict".

## 3. Records and value objects

```java
public record WidgetId(String value) {
    public WidgetId {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("WidgetId must not be blank");
        }
    }
}
```

- Invariants in the compact constructor.
- A record is immutable; a mutable aggregate uses a final class with
  behaviour.
- Type the id; do not pass a raw `String` where a `WidgetId` is expected.

## 4. Nullability

- `Optional<T>` for a repository lookup; `orElseGet` for the not-found path.
- No `Optional` in a field, a record component or a method parameter.
- `Objects.requireNonNull` at a constructor boundary; a validation error is a
  `Result`, not an NPE.

## 5. Exceptions

- A domain exception (`WidgetInvariantViolation`) for a programmer/invariant
  error; map it to 500 and log it.
- `AppError` for expected failures; map it to 4xx.
- Never catch `Exception` and return 500 in a resource; one mapper per family.
- Never log and rethrow the same exception.

## 6. Concurrency

- Managed executor/scheduler only; no `new Thread`, `Executors` or unmanaged
  `Timer`.
- `@ApplicationScoped` beans are stateless; request state is `@RequestScoped`.
- A shared cache is a port with explicit concurrency; no mutable singleton.
- Blocking I/O is never on the request thread if it can be a job.

## 7. Checkstyle and SpotBugs

- Checkstyle: naming, imports (no star imports), braces, line length,
  `MagicNumber` outside tests, `TODO` comments.
- SpotBugs: null handling, ignored return values, equality, resource leaks;
  excludes are reviewed like code.
- A suppression names the rule and the reason; a module-wide suppression is a
  finding.

## 8. Review questions

1. Is the state a closed union/record instead of booleans?
2. Is the transaction on the use case?
3. Is the tenant predicate present, and is RLS the second line?
4. Is the id a value type, or can a raw string stand in?
5. Is every external value parsed/validated once?
6. Is the error a value, and is the status mapped correctly?
7. Is the suppression narrow and explained?
