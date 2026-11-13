# Jakarta EE platform digest

The platform facts a Java enterprise backend depends on, with the design
consequence. The Jakarta EE specification is the source.

## 1. Versions and namespace

- **Jakarta EE 11**, `jakarta.*` namespace. J2EE 1.4 / Java EE 8 used
  `javax.*`; never mix the two in one deployment.
- **Java 21 LTS** is the safe baseline; Java 25 LTS once the server and
  libraries certify it (verify).
- CDI 4.1, JPA 3.2 (Hibernate 7), JAX-RS 4, Bean Validation 3.1, Jakarta
  Security 4, Jakarta Messaging 3.1, JTA 2, Concurrency 3.1.
- WildFly, Payara and Open Liberty ship Jakarta EE 11-compatible releases
  (verify the exact version).
- MicroProfile: Config 3.1, Health 4, Metrics 5, JWT 2.1, OpenTelemetry 2
  (verify).

## 2. CDI

- `@ApplicationScoped` for stateless services/use cases; `@RequestScoped` for
  request state; `@Dependent` for small helpers; `@Singleton` only for an
  immutable holder.
- Constructor injection; no field injection, no `BeanManager` service locator
  in business code.
- Producers return ports, not implementations; the composition root wires the
  graph.
- No mutable state in an `@ApplicationScoped` bean.

## 3. Persistence and transactions

- JPA entities live in adapters; the domain is plain Java.
- `@PersistenceContext` in the adapter; the `EntityManager` is
  transaction-scoped.
- `@Transactional` (JTA) on the use-case entry method, never on a resource or
  repository.
- `@Version` on mutable aggregates; a conflict is a typed error, not a 500.
- Fetch joins/projections inside the transaction; no lazy loading after it.
- Flyway/Liquibase is the schema authority; `hbm2ddl.auto=validate` in deployed
  profiles.

## 4. Messaging and concurrency

- JMS 3.1 + ActiveMQ Artemis; an MDB or a CDI listener adapter calls the use
  case.
- JMS is at-least-once: consumers are idempotent; messages carry `tenantId`,
  `correlationId` and an idempotency key.
- The transactional outbox is the courier; the domain row and the outbox row
  commit together.
- Jakarta Concurrency (`ManagedExecutorService`,
  `ManagedScheduledExecutorService`), never `new Thread`/`Executors` in a
  managed server.
- Long operations create a run row and return `202`.

## 5. Presentation

- JAX-RS resources are thin; DTOs are records with Bean Validation.
- The error envelope is
  `{ "error": { "code", "message", "requiredPermission", "correlationId" } }`;
  one `ExceptionMapper` per family.
- OpenAPI generated; cursor pagination; `ETag`/`If-Match` and
  `Idempotency-Key`.
- CORS allowlist; CSRF for cookie sessions.
- JSF/Faces is legacy for new SPA-backed products.

## 6. Security

- Jakarta Security (`SecurityContext`, `@RolesAllowed`) + MicroProfile JWT/OIDC,
  or an app-managed OIDC adapter.
- The container realm is a deployment option; tenant/ownership stays in the use
  case.
- Tenant from the validated token or job payload; `tenant_id` + PostgreSQL RLS
  with a non-bypass application role.
- Secrets from a vault/Kubernetes Secret; TLS only; Argon2id passwords; MFA for
  admins; audit admin actions.

## 7. Configuration and observability

- MicroProfile Config default ordinals: system properties 400 > environment
  variables 300 > `microprofile-config.properties` 100. Env-first needs a
  custom `ConfigSource`.
- MicroProfile Health readiness/liveness; Metrics for latency, errors, queue
  depth/age, outbox/DLQ, pools.
- OpenTelemetry traces with `correlationId`; structured logs with tenant,
  slice and use case.

## 8. Deployment

- WAR/EAR on WildFly/Payara/Open Liberty, or a bootable jar/micro distribution.
- Server config as code; migrations as a deploy step; stateless nodes; rolling
  with readiness gates; expand/contract; tested rollback.

## 9. Testing

- JUnit 5 for domain/use cases; Weld SE for CDI; Testcontainers for
  PostgreSQL/Artemis; REST Assured for the API; ArchUnit + Enforcer for the
  modules; two-tenant isolation; server smoke.
