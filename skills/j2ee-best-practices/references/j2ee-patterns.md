# J2EE patterns

The patterns a Java enterprise backend needs, with the failure mode each
prevents.

## 1. The use case owns the transaction

```java
@ApplicationScoped
public final class ArchiveWidgetService implements ArchiveWidget {
    private final WidgetRepository widgets;
    private final Outbox outbox;
    private final Clock clock;

    @Inject
    public ArchiveWidgetService(WidgetRepository widgets, Outbox outbox, Clock clock) {
        this.widgets = widgets;
        this.outbox = outbox;
        this.clock = clock;
    }

    @Override
    @Transactional
    public Result<Widget> archive(TenantId tenant, WidgetId id, Version expected, IdempotencyKey key) {
        return widgets.find(tenant, id)
                .map(widget -> {
                    if (!widget.version().equals(expected)) {
                        return Result.<Widget>failure(AppError.conflict());
                    }
                    Widget archived = widget.archive(clock.now());
                    widgets.save(tenant, archived);
                    outbox.append(tenant, WidgetArchived.of(archived), key);
                    return Result.success(archived);
                })
                .orElseGet(() -> Result.failure(AppError.notFound()));
    }
}
```

- One transaction for the domain write and the outbox row.
- The use case depends on ports, not on `EntityManager`.
- Authorization (permission + ownership) runs before the write.

## 2. The JPA adapter

- `@PersistenceContext EntityManager` in the adapter; map domain ↔ entity.
- `@Version` on the entity; `OptimisticLockException` → `conflict`.
- Fetch joins or DTO projections for the list endpoints; no lazy loading after
  the transaction.
- The adapter sets `app.tenant_id` on the transaction before the first query
  (PostgreSQL RLS).

## 3. The outbox

1. Write the domain row and the outbox row in one JTA transaction.
2. The worker polls due rows with `FOR UPDATE SKIP LOCKED`.
3. Send through JMS/HTTP; mark sent; on failure back off with jitter.
4. A dead-letter row is visible to admins.
5. The consumer deduplicates by the idempotency key.

## 4. JAX-RS resource

```java
@Path("/api/v1/app/widgets")
@Produces(MediaType.APPLICATION_JSON)
public final class WidgetResource {
    private final ArchiveWidget archiveWidget;

    @Inject
    public WidgetResource(ArchiveWidget archiveWidget) {
        this.archiveWidget = archiveWidget;
    }

    @POST
    @Path("/{id}/archive")
    public Response archive(@PathParam("id") WidgetId id,
                            @HeaderParam("If-Match") String expected,
                            @HeaderParam("Idempotency-Key") IdempotencyKey key) {
        return archiveWidget.archive(currentTenant(), id, Version.parse(expected), key)
                .fold(Response::ok, this::toResponse);
    }
}
```

- Parse, validate, call one use case, map the `Result`.
- No entity, no `EntityManager`, no `@Transactional`.

## 5. Error mapping

- One `ExceptionMapper` per family: `AppException`, `ConstraintViolation`,
  `OptimisticLockException`, unknown.
- Map the typed error to 401/403/404/409/422/429/5xx.
- Never leak a stack trace, SQL or an internal id; return the correlation id.

## 6. Tenant isolation

- `tenant_id NOT NULL` on every table, first in every index/predicate.
- PostgreSQL RLS with a non-bypass application role; `app.tenant_id` set per
  transaction.
- No cross-slice FK/join; a cross-slice read goes through a contract/port.
- Two-tenant tests: a missing predicate returns zero rows; a cross-tenant write
  fails.

## 7. Configuration

- MicroProfile Config; system properties > env > properties file.
- Secrets from a vault/Secret; profile config is a file/ConfigMap, not a
  branch.
- Managed policy (where present) wins and reports its source.

## 8. Testing

- JUnit 5 + fake ports for the use case; Weld SE for CDI.
- Testcontainers for JPA, migrations, outbox and JMS.
- REST Assured for status/envelope/validation/authz.
- ArchUnit + Maven Enforcer for the module graph.
- Two-tenant isolation and outbox idempotency are release blockers.
