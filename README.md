<p align="center">
  <img src="assets/icon.png" alt="Beautiful J2EE: a coffee cup on a dark field" width="160">
</p>

# Beautiful J2EE

Three standard [Agent Skills](https://agentskills.io) and a lints config that
teach coding agents to write, review, port, and enforce idiomatic
**Java enterprise backends on J2EE / Jakarta EE 11**:

- **`j2ee-best-practices`** loads whenever an agent writes or changes a Java
  enterprise app, and steers it toward Maven-module boundaries, CDI
  construction, a use-case transaction, schema-level tenant isolation and a
  JAX-RS edge.
- **`j2ee-review`** reviews existing code — a resource, use case, JPA adapter,
  module graph, outbox/JMS path, migration, security or tenant change, or a
  diff — and writes a prioritized report where every finding cites the rule it
  breaks and shows the fix.
- **`j2ee-port`** ports Spring Boot, Java EE 8 (`javax.*`), EJB/JSF, or a
  legacy servlet app to Jakarta EE 11 with the same behavior, porting the
  original tests first.
- **`lints/`** is a drop-in Checkstyle config whose rules run in CI.

They work with Claude Code, OpenAI Codex, GitHub Copilot, Cursor, Gemini CLI,
and any other agent that reads the Agent Skills format.

## The playbooks

These skills are the runnable, machine-checked enforcement of the
[facta playbooks](https://github.com/Facta-Dev/ai-coding-playbook). That
repository carries the sixteen root playbooks — backend, Java/J2EE, frontend,
React Native, Android/Kotlin, iOS/Swift, desktop Qt, CLI, Chrome extension,
URLs, tests, security, audit, install, REA and the Claude Code kit — plus the
nine runnable kits (Go, Rust, Node.js, Python, Java, extension, desktop,
frontend-mobile, mobile-android), the model-routing guide and the
instruction-budget tooling. Start with
[`PLAYBOOK_JAVA_J2EE.md`](https://github.com/Facta-Dev/ai-coding-playbook/blob/main/PLAYBOOK_JAVA_J2EE.md)
for this stack, then use this repository as the worked example. The shared
contracts (`PLAYBOOK_URLS.md`, `PLAYBOOK_TESTS.md`, `PLAYBOOK_SECURITY.md`,
`PLAYBOOK_AUDIT.md`, `PLAYBOOK_CLAUDE_CODE.md`) apply across the series.

## Why

Java enterprise backends fail in ways a unit test alone does not catch:

- A resource opens its own transaction, so a failure leaves a partial effect.
- A JPA entity is returned from the API, with lazy proxies and over-posting.
- A repository forgets the tenant predicate; `tenant_id` and RLS are the
  second line.
- The outbox row commits separately from the domain row, so an event is lost.
- `hbm2ddl.auto=update` reaches staging and rewrites the schema.
- A secret lands in `microprofile-config.properties`.
- A framework-shaped service (`@Service`, field injection, a Spring context)
  survives a "port" to Jakarta EE.

Beautiful J2EE is the contract that catches those before review.

## Agent kit (Claude Code)

This repo carries the `{kit}` kit plane from
[`ai-coding-playbook`](https://github.com/Facta-Dev/ai-coding-playbook):
`.claude/agents`, `.claude/skills`, `.claude/commands`, and the
`model-routing:ollama` block in `CLAUDE.md`.

Verify or repair the wiring from the playbook checkout:

```
bash ai-coding-playbook/scripts/claude-kit/configure-repo.sh . --kit={kit} --check
```

`configure-repo.sh` is idempotent, never deletes, and backs up
`.claude/settings.json` under `.claude/backups/` before any merge.

## Install

### Claude Code

```bash
/plugin marketplace add Facta-Dev/beautiful-j2ee
/plugin install beautiful-j2ee@beautiful-j2ee
```

### OpenAI Codex and ChatGPT

The repository ships a portable `plugin.json` with the `com.openai` interface
block. Point Codex at the repository, or package it with:

```bash
python3 scripts/package-openai-plugin.py --out beautiful-j2ee.zip
```

### Any agent

Copy `skills/j2ee-best-practices`, `skills/j2ee-review`, and
`skills/j2ee-port` into your agent's skills directory. Each skill is a
`SKILL.md` plus a `references/` digest; no runtime, no network.

## A worked example

Without the skill, an agent writes a resource that owns the transaction and
leaks the entity:

```java
@Path("/widgets")
public class WidgetResource {
    @PersistenceContext
    EntityManager em;

    @POST
    @Path("/{id}/archive")
    @Transactional
    public Widget archive(@PathParam("id") String id) {
        WidgetEntity entity = em.find(WidgetEntity.class, id);
        entity.setStatus("ARCHIVED");
        return entity;
    }
}
```

Problems: the transaction is on the resource, the tenant predicate is absent,
the entity is returned to the client, and the event is never queued.

With the skill, the resource is thin and the use case owns the transaction:

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

The module graph, the transaction boundary and the tenant/RLS rules are in
[`skills/j2ee-best-practices/references/j2ee-architecture.md`](skills/j2ee-best-practices/references/j2ee-architecture.md).

## The architecture contract

```text
features/<slice>/presentation  ──►  application  ──►  domain
                                        ▲
                                        └── ports ◄── adapters (JPA, JMS, HTTP)
apps/api, apps/worker: composition root (CDI producers)
```

| Layer | Owns | Must not depend on |
|---|---|---|
| **domain** | Entities, rules, ports — plain Java | `jakarta.*`, JPA, JAX-RS |
| **application** | Use cases, transaction boundary | JPA, JAX-RS, JMS |
| **adapters** | JPA, JMS, HTTP clients, cache | presentation, other slices |
| **presentation** | JAX-RS resources, DTOs, error mapping | adapters, JPA |

The unbreakable rules:

1. A slice owns its capability, schema and tests.
2. The domain is plain Java.
3. The use case owns the JTA transaction.
4. Entities never cross the API.
5. CDI construction is explicit.
6. Tenant/ownership checks are in the use case; `tenant_id` + RLS are the
   second line.
7. Every async effect is idempotent.

## Architecture diagrams

The repo ships eight [Archify](https://github.com/tt-a1i/archify) diagrams under
[`docs/architecture/`](docs/architecture/README.md), each a standalone HTML page
you can open, pan and zoom in a browser.

| Diagram | Type | Shows |
|---|---|---|
| [c4-containers](docs/architecture/c4-containers.html) | architecture | `apps/api` and `apps/worker` on a Jakarta EE server, PostgreSQL with tenant RLS, the JMS broker, the OIDC issuer |
| [services-slices](docs/architecture/services-slices.architecture.html) | architecture | the `features/<slice>` module graph and the dependency walls it enforces |
| [auth-algorithm](docs/architecture/auth-algorithm.workflow.html) | workflow | token validation → tenant claim → permission and ownership → RLS → write → audit |
| [outbox-algorithm](docs/architecture/outbox-algorithm.workflow.html) | workflow | the transactional outbox: commit together, claim, publish, settle, dead-letter |
| [auth-sequence](docs/architecture/auth-sequence.sequence.html) | sequence | one request from the client to PostgreSQL and back |
| [outbox-sequence](docs/architecture/outbox-sequence.sequence.html) | sequence | the outbox drain and the at-least-once delivery |
| [database-dataflow](docs/architecture/database-dataflow.dataflow.html) | dataflow | where the state goes: tenant tables, the outbox row, the broker |
| [runtime-lifecycle](docs/architecture/runtime-lifecycle.lifecycle.html) | lifecycle | boot → composition → migrations → serve → request, with the fail-closed endings |

## The lints config

[`lints/checkstyle.xml`](lints/checkstyle.xml) is a copy-in Checkstyle config:
naming, imports (no star imports), braces, line length, magic numbers outside
tests, TODO comments, string equality and the utility-class rules.
[`lints/README.md`](lints/README.md) also documents the SpotBugs gate.

[`scripts/check-lints.sh`](scripts/check-lints.sh) runs Checkstyle on the clean
control and the violation harness. A missing tool prints a visible `SKIP`; CI
installs it and runs the same script. [`lints/check/`](lints/README.md) holds
the deliberate findings.

The Java example in
[`examples/minimal/`](examples/minimal/src/example/SelfCheck.java) is compiled
and self-checked by [`scripts/check-build.sh`](scripts/check-build.sh) with
`javac`/`java`; the offline
[`scripts/check-examples.py`](scripts/check-examples.py) balances every Java
block everywhere.

## What it does not do

- The skills contain instructions and reference text only. They make no
  network calls and collect no data ([PRIVACY.md](PRIVACY.md)).
- When a JDK/Maven toolchain is available, the skills run Maven, Checkstyle,
  SpotBugs and the tests; without one, they work from the code alone.
- The lint config is a copy-in unit, not a dependency.
- The skills do not replace a two-tenant database test or an app-server smoke
  test; they tell the agent what those must prove.

## Repository layout

```text
skills/
  j2ee-best-practices/  SKILL.md + references/ (Jakarta EE, patterns,
                        architecture, strict Java)
  j2ee-review/          SKILL.md (report format, ranking, waived gates)
  j2ee-port/            SKILL.md (Spring/Java EE 8/EJB/JSF → Jakarta EE)
docs/
  architecture/         eight Archify diagrams (C4, slices, auth,
                        outbox, dataflow, lifecycle) + their index
lints/
  checkstyle.xml        the drop-in rules
  check/                the violation harness + clean control
scripts/
  check-skill.py        frontmatter, links, evals, manifests
  check-examples.py     Java block balance (offline gate)
  check-build.sh        javac + self-check of the example
  check-lints.sh        Checkstyle clean/violation harness (SKIP if absent)
  package-openai-plugin.py
tests/                  validator, wording, lints-config and gate tests
examples/
  minimal/              a self-checking Java example
  review-widget.md      a full worked review
```

## Sources

- The Jakarta EE 11 specification and the Jakarta/MicroProfile guides (CDI,
  JPA, JTA, JMS, JAX-RS, Security, Config, Health, Metrics).
- The facta J2EE handbook (`PLAYBOOK_JAVA_J2EE.md`): Maven modules, layers,
  transactions, tenant isolation, outbox, deployment, testing.
- The Checkstyle and SpotBugs documentation.

## Contributing

Rule proposals are welcome; open an issue with the
[rule template](.github/ISSUE_TEMPLATE/propose-a-rule.yml) and a source. A
rule without a source and a failing example is a preference, not a rule. See
[CONTRIBUTING.md](CONTRIBUTING.md).

## Siblings

Beautiful J2EE is part of the Beautiful series for the facta playbooks:
[beautifulgo](https://github.com/Facta-Dev/beautifulgo),
[beautifulnodejs](https://github.com/Facta-Dev/beautifulnodejs),
[beautifulpython](https://github.com/Facta-Dev/beautifulpython),
[beautifulrust](https://github.com/Facta-Dev/beautifulrust),
[beautifulreact](https://github.com/Facta-Dev/beautifulreact),
[beautifulextension](https://github.com/Facta-Dev/beautifulextension),
[beautifulcli](https://github.com/Facta-Dev/beautifulcli),
[beautifulreactnative](https://github.com/Facta-Dev/beautifulreactnative),
[beautifulqt](https://github.com/Facta-Dev/beautifulqt),
[beautifulandroid](https://github.com/Facta-Dev/beautifulandroid) and
[beautifulios](https://github.com/Facta-Dev/beautifulios).

## License

MIT — see [LICENSE](LICENSE).
