# A worked review: the widget archive endpoint

The subject is a small JAX-RS endpoint that archives a widget. It works on a
single tenant, and it has five findings that a review must rank in a useful
order. The fixed version follows the contract in `j2ee-best-practices`.

## The module under review

```java
@Path("/widgets")
public class WidgetResource {
    @PersistenceContext
    EntityManager em;

    @POST
    @Path("/{id}/archive")
    @Transactional
    public WidgetEntity archive(@PathParam("id") String id) {
        WidgetEntity entity = em.find(WidgetEntity.class, id);
        entity.setStatus("ARCHIVED");
        return entity;
    }
}
```

## The report

### Verdict

The endpoint works for one tenant and leaks the entity, the transaction and
the tenant boundary. Not safe to ship; the transaction placement is first
because it is the one every resource copies.

### Must fix

1. `WidgetResource.java:8` — `@Transactional` is on the **resource**, and the
   entity is mutated directly. Rule: *the use case owns the JTA transaction;
   the resource is thin*. Fix: an `ArchiveWidget` use case with
   `@Transactional`; the resource calls it and maps the `Result`.
2. `WidgetResource.java:11` — `em.find` has no tenant predicate and the table
   has no `tenant_id`/RLS. Rule: *tenant isolation is in the use case and the
   schema*. Fix: `findById(tenant, id)`, `tenant_id NOT NULL` + RLS with a
   non-bypass application role.
3. `WidgetResource.java:13` — the method returns `WidgetEntity`. Rule:
   *entities never cross the API boundary*. Fix: a `WidgetDto` record; the
   adapter maps entity → domain → DTO.
4. `WidgetResource.java:12` — no outbox row, no idempotency key, no version
   check. Rule: *the domain row and the outbox row commit together; a replay
   is idempotent*. Fix: `outbox.append(tenant, WidgetArchived.of(widget), key)`
   in the same transaction; `@Version`/`If-Match` for the conflict.
5. `persistence.xml` — `hbm2ddl.auto=update` is deployed. Rule: *Flyway is the
   only schema authority; `validate` in deployed profiles*. Fix: a Flyway
   migration and `validate`.

### Should fix

6. `WidgetResource.java:5` — field injection of `EntityManager`. Fix:
   constructor injection in the adapter; the resource injects the use-case
   port.
7. `WidgetResource.java:10` — no `Idempotency-Key` header. Fix: require it for
   the mutation and store the outcome.
8. `WidgetResource.java:8` — a missing authz check; `@RolesAllowed` alone is
   not ownership. Fix: permission + ownership in the use case.

### Waived gates

None. The diff does not touch the lint config, the tests, or the migration
step.

## The fixed module

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
                .fold(Response::ok, this::error);
    }
}
```

## What changed, and why it matters

| Finding | The fixed version |
|---|---|
| Transaction on the resource | `@Transactional` on the use case |
| No tenant predicate/RLS | tenant in the port + `tenant_id`/RLS |
| Entity returned from the API | DTO record + adapter mapping |
| No outbox/idempotency/version | same-transaction outbox + key + `@Version` |
| `hbm2ddl.auto=update` | Flyway + `validate` |

The review is short on purpose. Five Must-fix findings, each with a location,
a rule, and a fix, is a better review than twenty comments that repeat the
same contract in different words.
