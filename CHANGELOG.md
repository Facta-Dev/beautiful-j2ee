# Changelog

All notable changes to this project are listed here. Versions follow
[Semantic Versioning](https://semver.org/), and the version lives in
`.claude-plugin/plugin.json`.

## [Unreleased]

### Added

- **Three skills for J2EE / Jakarta EE 11.** `j2ee-best-practices` steers new
  backend code toward Maven modules that enforce the
  domain/application/adapters/presentation layers, CDI constructor injection,
  JTA use-case transactions, JPA/Hibernate with optimistic locking,
  schema-level tenant isolation with PostgreSQL RLS, the transactional outbox
  and JMS, JAX-RS with DTOs and the platform error envelope, Jakarta Security
  and MicroProfile config/observability. `j2ee-review` reviews a resource, use
  case, adapter, module graph, outbox/JMS path, migration, security/tenant
  change or diff and ranks architecture and transaction/tenant contracts
  first. `j2ee-port` ports Spring Boot, Java EE 8 (`javax.*`), EJB/JSF or a
  legacy servlet app to Jakarta EE 11.
- **A drop-in Checkstyle config.** `lints/checkstyle.xml` pins naming,
  imports, braces, line length, magic numbers, TODO comments, string equality
  and utility-class rules; the README documents the SpotBugs gate.
- **A self-checking Java example and proof gates.** `examples/minimal/` compiles
  with `javac` and runs its own assertions; `scripts/check-build.sh` runs it.
  `scripts/check-lints.sh` runs Checkstyle on the clean control and the
  violation harness, with a visible SKIP when the tool is absent.
- **A validator and a test suite.** `scripts/check-skill.py` checks
  frontmatter, links, eval cases and the plugin manifests; the offline
  `scripts/check-examples.py` balances every Java block; `tests/` covers the
  validator, wording, lints config and gates.
- **A worked review.** `examples/review-widget.md` shows the report shape and
  the transaction/tenant-first ranking on a small widget endpoint.

[Unreleased]: https://github.com/Facta-Dev/beautiful-j2ee/compare/v0.1.0...HEAD
