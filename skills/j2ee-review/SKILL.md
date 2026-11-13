---
name: j2ee-review
description: >-
  Review a J2EE / Jakarta EE change — a JAX-RS resource, a CDI use case, a
  JPA adapter, a Maven module boundary, a transaction/outbox path, a JMS
  listener, a migration, a security or tenant-isolation change, or a diff —
  and produce a prioritized report where every finding cites the file and
  line, the rule it breaks, and the smallest fix. Use this skill whenever the
  user asks to review, audit, critique, or "find problems in" a Java
  enterprise app, endpoint, module graph or persistence layer. Trigger on
  review, audit, code review, PR review, "what is wrong with this endpoint",
  "check this transaction", "review this JPA mapping", or a pasted .java file.
  Architecture and transaction/tenant contracts always rank first.
---

# J2EE review

A review is a prioritized list of findings, not a rewrite. Read the whole
change first. Every finding has four parts: **location** (file and line),
**severity**, **the rule it breaks** (named or quoted), and **the smallest
fix**. If you cannot cite a rule or a user-visible consequence, it is not a
finding; it is a preference for the Notes section, if anywhere.

## 1. Report shape

```text
## Verdict
<one paragraph: what this change does, whether it is safe to ship, and the
single most important thing to fix>

## Must fix
1. <file>:<line> — <finding>. Rule: <rule or contract>. Fix: <smallest fix>.

## Should fix
...

## Notes
...

## Waived gates
...
```

- **Must fix** blocks merge or release: a broken layer or transaction
  boundary, a cross-tenant read, a secret outside the vault, an outbox that
  loses an effect, a missing state, a schema change without a migration.
- **Should fix** is worth doing in this change or the next: an N+1, a chatty
  JPA graph, a missing metric, a slow startup.
- **Notes** is optional. Do not pad the report to look thorough.

## 2. Categories, in ranking order

### Architecture contracts (always Must fix, ranked first)

A broken architecture contract (ranked above everything) is a Must fix even
when the endpoint works. Check:

- A **domain** module imports `jakarta.*`, JPA, JAX-RS or a vendor API.
- A **resource** contains a business rule, uses an `EntityManager` or opens a
  transaction.
- A **use case** sees `HttpServletRequest`, `SecurityContext`, `JMSContext` or
  an entity manager.
- A **repository** returns an entity to the application/API.
- A feature imports another slice's internals or tables.
- `@Transactional` on a resource, repository or listener instead of the use
  case.
- A client-side permission check presented as server authorization.

### Transactions and persistence

- A transaction per repository call instead of one per use case; partial
  effects on failure.
- XA/distributed transaction where an outbox would do.
- Lazy loading after the transaction (Open Session in View); an N+1 on a list
  endpoint.
- Missing `@Version` on a mutable aggregate; a conflict mapped to 500.
- `hbm2ddl.auto=create/update` in a deployed profile; a migration edited after
  release.
- A cross-slice FK/join; a table without `tenant_id NOT NULL` or the standard
  columns.
- A raw JDBC/connection use that bypasses RLS or the JTA transaction.

### Messaging, batch and async

- The domain row and the outbox row not in the same transaction.
- A JMS consumer that is not idempotent; a message without `tenantId` or an
  idempotency key.
- `new Thread`, `Executors` or an unmanaged timer inside the server.
- A job without a bound, a backoff, a dead-letter or a cancellation path.
- A long operation held open instead of a run row + `202`.
- An MDB/listener with business logic instead of a call to the use case.

### Presentation and API

- An entity in the response; over-posting into an entity; a DTO without
  validation.
- The error envelope drifted; a stack trace/SQL/secret in a response.
- A `try/catch` in every resource instead of an `ExceptionMapper`.
- A missing authz matrix row; a status code that does not match the error
  kind.
- An unbounded page, no cursor, a missing `ETag`/`Idempotency-Key` on a
  mutation.
- CORS wildcard; CSRF missing on a cookie session; a Faces screen for a new
  SPA-backed product.

### Security and multi-tenancy

- Tenant from a query string/unverified header instead of the token/job.
- A repository query without the tenant predicate; RLS absent or bypassable by
  the application role.
- A secret in `microprofile-config.properties`, `persistence.xml`, logs, the
  image or a response.
- `@RolesAllowed` presented as tenant/ownership isolation.
- An auth flow in a custom login form instead of OIDC/JWT; a token logged.
- Missing audit row for an admin action.

### Configuration and observability

- A wrong MicroProfile Config precedence assumption (default ordinals:
  system properties 400 > env 300 > `microprofile-config.properties` 100).
- A secret in a ConfigSource; profile config as a code branch.
- No readiness/liveness split; a deep dependency check on the liveness path.
- No `correlationId` across HTTP/JMS/outbox; logs without `tenantId`/`slice`.
- A queue depth/age, outbox/DLQ or pool saturation with no metric.

### Deployment

- Migrations on app start; a schema change with no deploy step.
- Server config edited in the admin console instead of the image/Helm.
- Mutable session state on a node; sticky sessions as the only plan.
- A rollback that cannot run against the new schema.
- Pools/heap left at defaults; container flags missing.

### Tests

- No use-case test for the denial/ownership paths; no two-tenant isolation
  test.
- No migration fixture; no outbox idempotency test; no JMS redelivery test.
- No ArchUnit/Enforcer rule for the layer that changed.
- A test that asserts implementation instead of behavior.

## 3. Waived gates

If the diff deletes or weakens a lint, a test, a type, a transaction or an
isolation check, flag the deletion itself, loudly — even when the new code
looks fine. Look for:

- A new `// CHECKSTYLE:OFF` **without a reason**; a module-wide suppression; a
  Checkstyle rule removed or a threshold raised.
- A new `@SuppressFBWarnings` without a reason; a SpotBugs exclude added
  broadly.
- A Maven Enforcer exclusion; an ArchUnit rule deleted; a module dependency
  added to cross a layer.
- A skipped test without an owner and expiry; a migration fixture deleted; a
  two-tenant test removed.
- `hbm2ddl.auto` changed to `update`; RLS disabled; a role granted BYPASSRLS.
- A secret moved into a config file "temporarily".

State the deletion, the reason it claims, and what it would take to keep the
gate. "Temporarily" is not a reason; an expiring waiver with an owner is.

## 4. How to review

1. **Read the change twice.** First for intent, then for the diff.
2. **Run the gates if you can:** `mvn verify`, Checkstyle, SpotBugs, the
   two-tenant tests, the built WAR/EAR on the target server.
3. **Check the transaction boundary, the tenant predicate and the module
   graph first.** They are the expensive findings; style is cheap.
4. **Cite evidence.** File and line for every Must fix; a rule name or a
   quoted contract for every finding.
5. **Propose the smallest fix.** "Rewrite the service" is not a fix; "move
   `@Transactional` to the use case and write the outbox row in the same
   transaction" is.
6. **Stop when the change is safe.** An empty Should-fix section is a valid
   review.

## 5. Worked example

`examples/review-widget.md` is a full review of a small widget archive
endpoint: the resource, the use case and the JPA adapter, the findings in
ranking order, and the fixed module. It shows the transaction violation first,
then the tenant gap, then the entity leak, then the outbox.

## 6. Cross-skill contract

- `j2ee-best-practices` defines the rules this review cites. When a finding
  and the skill disagree, the skill is the source.
- `j2ee-port` produces the change; this review checks it before release.
- The `lints/` config is the machine-checkable subset. A finding the config
  can catch should become a rule, not a repeated comment.
