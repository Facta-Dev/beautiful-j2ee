# J2EE architecture contract

The module and layer contract from the facta J2EE handbook, reduced to what a
Java enterprise backend must keep. The Maven reactor and ArchUnit enforce it.

## 1. Modules and layers

| Layer | Module | Contains | Must not depend on |
|---|---|---|---|
| **domain** | `features/<slice>/domain` | Entities, value objects, rules, ports — plain Java | `jakarta.*`, JPA, JAX-RS, the server |
| **application** | `features/<slice>/application` | Use cases, transaction boundary, orchestration | JPA, JAX-RS, JMS, entities |
| **adapters** | `features/<slice>/adapters` | JPA, JMS, HTTP clients, cache | presentation, other slices' internals |
| **presentation** | `features/<slice>/presentation` | JAX-RS resources, DTOs, error mapping | adapters, JPA, other slices' internals |
| **contracts** | `features/<slice>/contracts` | Published API/event types | everything else |
| **apps** | `apps/api`, `apps/worker` | Composition root, CDI wiring | business rules |

- A module's `pom.xml` dependencies are the complete list of what it may
  import; a forbidden artifact fails Enforcer/compilation.
- Domain modules use the plain `maven-compiler-plugin`, not a Jakarta API
  dependency in `compile` scope.
- One slice never imports another slice's entities/repositories; it uses the
  other slice's `contracts` and a port.

## 2. Ports

| Port | Declared by | Implemented by |
|---|---|---|
| `WidgetRepository` | feature domain | JPA adapter |
| `Outbox` | feature application | JPA/JMS adapter |
| `SessionStore` | application | OIDC/token adapter |
| `Clock` | domain | system clock (tests use a fake) |
| `Notifier` | application | JMS/mail adapter |
| `TokenVerifier` | application | MicroProfile JWT/OIDC adapter |
| `PermissionChecker` | application | policy adapter |

A port uses domain types; no `EntityManager`, `HttpServletRequest` or JMS
type crosses into the domain.

## 3. Composition root

- `apps/api` and `apps/worker` build the CDI graph; a producer returns the
  port type, not the implementation.
- The use case receives its ports through the constructor.
- Tests build the same graph with fakes; the use case never changes.

## 4. Transactions

- The use case is the transaction boundary (`@Transactional` JTA).
- The resource/repository never opens a transaction.
- The outbox row commits with the domain row.
- No XA; a distributed effect is an idempotent async job.

## 5. Tenant isolation

- `tenant_id NOT NULL` on every table, first in every index and predicate.
- Schema per slice; no cross-slice FK/join.
- PostgreSQL RLS + a non-bypass application role; `app.tenant_id` set per
  transaction by the adapter.
- The use case checks permission + ownership; the database is the second line.

## 6. Presentation

- JAX-RS resources are thin; DTOs are records with Bean Validation.
- The error envelope is the platform's; one mapper per family.
- OpenAPI generated; cursor pagination; `ETag`/`If-Match` and
  `Idempotency-Key`.
- CORS allowlist; CSRF for cookie sessions; no JSF for new SPA products.

## 7. Security

- Jakarta Security + MicroProfile JWT/OIDC; the container realm is a
  deployment option.
- Tenant from the validated token/job; roles only shape the UX.
- Secrets from a vault/Secret; TLS only; audit admin actions.

## 8. Configuration and observability

- MicroProfile Config default ordinals: system properties 400 > env 300 >
  `microprofile-config.properties` 100.
- Health readiness/liveness; metrics for latency/errors/queue/pool; OTel
  traces; `correlationId` across HTTP/JMS/outbox.

## 9. Deployment

- WAR/EAR or bootable jar/micro; server config as code.
- Migrations as a deploy step; expand/contract; rolling with readiness gates;
  tested rollback.

## 10. Testing

- JUnit 5 + fake ports; Weld SE for CDI; Testcontainers for PostgreSQL/Artemis.
- REST Assured for the API; ArchUnit + Enforcer for the modules.
- Two-tenant isolation and outbox idempotency are release blockers.
- The built WAR/EAR starts on the target server.

## 11. Enforcement map

| Rule | Where |
|---|---|
| domain has no `jakarta.*` | module scope + ArchUnit |
| resource has no business rule/transaction | ArchUnit + review |
| entities never cross the API | ArchUnit + review |
| no cross-slice import | Enforcer/ArchUnit |
| no main-thread/raw thread in the server | Checkstyle/review |
| no secret outside the vault | review + secret scan |
| tenant predicate + RLS | two-tenant tests + migration review |

When a change needs an exception, re-cut the layout; do not add a dependency
or a suppression. A config exception is a contract change.
