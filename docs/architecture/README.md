# beautiful-j2ee — Architecture Diagrams

Rendered with [Archify](https://github.com/tt-a1i/archify). Each entry is a standalone,
explorable HTML page (inline SVG, dark/light themes, live motion) paired with its source
JSON candidate. The set documents the Jakarta EE 11 backend this repo's skills contract
builds and its lints enforce: JAX-RS resources over CDI use cases, a plain-Java domain,
JPA/JTA with the use case as the transaction boundary, PostgreSQL with `tenant_id` and
row-level security, the transactional outbox over JMS, MicroProfile Health/Config/Metrics,
and the Maven module graph that keeps the layers apart.

| Diagram | Type | What it shows | JSON | HTML |
|---|---|---|---|---|
| c4-containers | architecture | Container view: API clients → a Jakarta EE server running `apps/api` and `apps/worker` as the two composition roots, PostgreSQL as the only persistence boundary with tenant RLS, a JMS broker for at-least-once delivery, and the OIDC/JWT issuer that validates the token — with the skills, the lints config and the CI gates as the delivery mechanism | [json](c4-containers.json) | [html](c4-containers.html) |
| services-slices | architecture | Module topology: the `apps/api` and `apps/worker` composition roots over one `features/<slice>` cut into presentation, application, domain, contracts and adapters, plus the shared kernel and the per-slice schema — every wall labeled with the rule that keeps it (the module dependency rule, plain-Java domain, the use-case transaction, Enforcer + ArchUnit + Checkstyle) | [json](services-slices.architecture.json) | [html](services-slices.architecture.html) |
| auth-algorithm | workflow | The trust algorithm as gated steps: bearer token → MicroProfile JWT validation → tenant claim from the validated token → permission and ownership inside the use case → the `tenant_id` predicate under RLS → the domain write → the audit row, with the 403 branch on the typed `AppError` | [json](auth-algorithm.workflow.json) | [html](auth-algorithm.workflow.html) |
| outbox-algorithm | workflow | The transactional outbox: the domain row and the outbox row commit in one JTA transaction, the worker claims the due rows with `FOR UPDATE SKIP LOCKED`, publishes through JMS or HTTP, settles the row, backs off on failure and ends in a dead-letter row an admin can see | [json](outbox-algorithm.workflow.json) | [html](outbox-algorithm.workflow.html) |
| auth-sequence | sequence | One request end to end across the client, the JAX-RS resource, Jakarta Security, the use case and PostgreSQL — token validation, the tenant claim, the transaction with `app.tenant_id` and the tenant predicate, and the `Result` mapped to a DTO or a typed error | [json](auth-sequence.sequence.json) | [html](auth-sequence.sequence.html) |
| outbox-sequence | sequence | The delivery trace: append in the same transaction, claim, publish, settle, and the consumer deduplicating by the idempotency key because JMS delivers at-least-once | [json](outbox-sequence.sequence.json) | [html](outbox-sequence.sequence.html) |
| database-dataflow | dataflow | Where the state goes: the client and the OIDC issuer into the use case, the use case into the `tenant_id`-first tables and the outbox row in one transaction, and the worker out to the broker — with the schema discipline and the RLS second line named | [json](database-dataflow.dataflow.json) | [html](database-dataflow.dataflow.html) |
| runtime-lifecycle | lifecycle | Process runtime states: config boot with the MicroProfile ordinals → CDI composition → migrations as a deploy step → serving → the request served, with the fail-closed boot, the aborted rollout, the degraded readiness gate, the forbidden request and the outbox drain as explicit endings | [json](runtime-lifecycle.lifecycle.json) | [html](runtime-lifecycle.lifecycle.html) |

Authored with Archify, sibling set of the facta backend kits. The repository content is
grounded in the digests the skills carry (`skills/j2ee-best-practices/references/jakarta-ee.md`,
`j2ee-architecture.md`, `j2ee-patterns.md`), in `PLAYBOOK_JAVA_J2EE.md` and in the Java
template under `src/main/java/com/example/app/`. The diagrams are conceptual and
source-backed, not a capture of a running deployment: this repo ships the contract
(skills plus `lints/`), so the containers shown are the ones the contract builds. Two roles
are adapted to what the repo actually has — the **auth** diagrams show a resource-server
trust boundary (MicroProfile JWT/OIDC validation, the tenant claim, the use-case
permission and ownership check) instead of a signup/login flow, because the repo defines
no credential-issuance service; and the **data-flow** role points at PostgreSQL with
tenant RLS rather than a client-side store, because the contract's only persistence
boundary is the database.
