---
name: j2ee-port
description: >-
  Port an existing Java backend to idiomatic Jakarta EE 11 with the same
  behavior: Spring Boot, Java EE 8 / J2EE with `javax.*`, EJB/JSF, a legacy
  servlet app, or a framework-specific service. Use this skill whenever the
  user asks to migrate, convert, rewrite, or port a Java app or module to
  Jakarta EE, modernize `javax.*` to `jakarta.*`, or replace Spring/EJB with
  CDI. Trigger on port, migrate, convert to Jakarta EE, "upgrade from Java EE
  8", "move this Spring service to CDI", or a pasted Java file. Port the
  original tests first, keep behavior identical, and write a PORTING.md.
---

# J2EE port

A port preserves behavior while changing the implementation. The output is not
a Spring service with `jakarta.*` imports or a Java EE 8 app with a new
namespace; it is a Jakarta EE app a Java enterprise developer would have
written, with the same observable behavior and tests proving it.

## 1. The order of work

1. **Read the source and its tests.** The tests are the specification. If
   there are none, write characterization tests against the current behavior
   first.
2. **Port the tests first.** Same cases, same assertions, expressed in JUnit 5
   + the target runtime. A port without a failing test is a rewrite with hope.
3. **Map every endpoint, transaction, query, message, job, config key and
   security decision.**
4. **Define the Maven modules.** domain/application/adapters/presentation;
   the use case and the port come first.
5. **Port one use case at a time**, with the `Result` mapping and the tenant
   predicate.
6. **Run the gates.** `mvn verify`, Checkstyle, SpotBugs, Testcontainers, the
   built WAR/EAR on the server, the two-tenant tests.
7. **Write `PORTING.md`.** Every deliberate difference, every framework
   feature not reproduced, every schema/config change, and why.

## 2. Java EE 8 / J2EE → Jakarta EE 11

| Java EE 8 / J2EE | Jakarta EE 11 |
|---|---|
| `javax.persistence.*` | `jakarta.persistence.*` |
| `javax.ws.rs.*` | `jakarta.ws.rs.*` |
| `javax.inject.*` | `jakarta.inject.*` |
| `javax.transaction.*` | `jakarta.transaction.*` |
| `javax.validation.*` | `jakarta.validation.*` |
| `javax.security.*` | `jakarta.security.*` |
| `javax.jms.*` | `jakarta.jms.*` |
| `javax.servlet.*` | `jakarta.servlet.*` |
| `javax.ejb.*` | `jakarta.ejb.*` (legacy; prefer CDI) |
| `javax.faces.*` | `jakarta.faces.*` (legacy; no new SPA product) |
| `javax.json.*` | `jakarta.json.*` |
| JPA 2.2 | JPA 3.2 (Hibernate 7) |
| CDI 2.0 | CDI 4.1 |
| Bean Validation 2.0 | Bean Validation 3.1 |

- The namespace change is a source migration, not a dependency bump; do not
  mix `javax` and `jakarta` in one deployment.
- Replace EJB session beans with CDI beans + `@Transactional` use cases; keep
  EJB Lite only where a legacy contract requires it.
- Replace JSF/Faces screens with JAX-RS JSON for SPA/native clients; a
  server-rendered Faces screen needs an ADR.
- Replace `@EJB`/JNDI lookups with constructor injection.
- Replace container-managed entity managers in resources with adapters.

## 3. Spring Boot → Jakarta EE

| Spring | Jakarta EE |
|---|---|
| `@RestController` | JAX-RS resource |
| `@Service` | `@ApplicationScoped` use case |
| `@Repository` + Spring Data | JPA adapter + a port |
| `@Transactional` (Spring) | `@Transactional` (JTA) on the use case |
| `@Autowired` field injection | constructor injection |
| `application.yml` | MicroProfile Config |
| Spring Security filter chain | Jakarta Security + MicroProfile JWT |
| `@Scheduled` | `@Schedule`/`ManagedScheduledExecutorService` |
| Spring Events | CDI events (in-process) or the outbox (durable) |
| Actuator | MicroProfile Health/Metrics |
| Flyway (same) | Flyway (same) |

- Do not keep a Spring `ApplicationContext` inside the Jakarta app; that is
  two composition roots.
- Keep the behavior, not the annotations: a controller becomes a thin
  resource, a service becomes a use case, a repository becomes an adapter.
- The transaction boundary moves from the Spring service to the Jakarta use
  case; verify it once with an integration test.

## 4. Legacy servlet / EJB / JSF app

- **Servlets:** keep only the edge (filters, security, correlation); move the
  logic to use cases and JAX-RS.
- **EJB:** map session beans to CDI beans; `@Stateless` → `@ApplicationScoped`;
  `@TransactionAttribute` → `@Transactional`; message-driven beans remain only
  as JMS adapters.
- **JSF:** for a new product, replace the screen with a JAX-RS API and the SPA
  client. For an existing product, keep Faces behind an ADR and isolate it
  from the new API.
- **JNDI:** replace business-code lookups with constructor injection; keep
  JNDI for the datasource/broker configuration only.

## 5. Behavior parity checklist

- [ ] Every endpoint, method, status code and error code exists.
- [ ] Every transaction boundary is one use case; a failure rolls back both
      the domain write and the outbox.
- [ ] Every query has the tenant predicate; the schema has `tenant_id` + RLS.
- [ ] Every DTO validates; no entity crosses the API.
- [ ] Every async effect is idempotent; the message carries tenant and
      correlation.
- [ ] Every config key has the same default and precedence (MicroProfile
      ordinals).
- [ ] Every secret is in the vault/Secret, not in config.
- [ ] Migrations are the only schema change; `validate` in deployed profiles.
- [ ] The original tests pass, ported; new tests cover the two-tenant and
      outbox paths.
- [ ] The built WAR/EAR starts on the target server.
- [ ] `PORTING.md` lists every deliberate difference.

## 6. What not to do

- **Do not keep the source framework's shape.** A Spring context, an EJB
  service locator or a JSF backing bean in a new Jakarta module is a port that
  will be rewritten.
- **Do not mix `javax.*` and `jakarta.*`** in one deployment; the classloaders
  and the server will disagree.
- **Do not skip the tests.** A port validated only by clicking through it
  ships the source's bugs plus new ones.
- **Do not widen a permission or drop a tenant predicate** to make a port
  compile.
- **Do not silently change behavior.** Reproduce the source quirk, pin it with
  a test, and list the fix as a follow-up — or fix it deliberately and say so.

## 7. Cross-skill contract

- `j2ee-best-practices` is the target style; every ported module follows it.
- `j2ee-review` reviews the port before release and ranks a broken
  architecture contract above every other finding.
- The `lints/` config is the machine-checkable half; a port that needs a lint
  exception is a port that has not finished.
