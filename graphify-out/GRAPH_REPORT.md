# Graph Report - .  (2026-11-22)

## Corpus Check
- cluster-only mode — file stats not available

## Summary
- 661 nodes · 883 edges · 88 communities (52 shown, 36 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 3 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `762cf2ad`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- CheckSkillTests
- Path
- J2EE architecture contract
- interface
- What You Must Do When Invoked
- YamlParser
- Beautiful J2EE
- J2EE / Jakarta EE best practices
- 2. Categories, in ranking order
- .main
- Jakarta EE platform digest
- BestPractices
- A worked review: the widget archive endpoint
- J2EE patterns
- Java strict for J2EE
- graphify reference: extra exports and benchmark
- check_repo
- J2EE port
- PackageTests
- run
- <app> API Designer Agent
- <app> Migration Reviewer Agent
- <app> Architect Agent
- <app> Build Resolver Agent
- <app> Code Explorer Agent
- <app> Code Reviewer Agent
- <app> Planner Agent
- <app> TDD Guide Agent
- <app> Security Reviewer Agent
- <app> Test Author Agent
- <app> add-slice skill
- <app> Claim Check skill
- <app> Clean-Room Rebuild skill
- <app> Corpus Retrieval skill
- <app> Diagnosing Bugs skill
- <app> Domain Modeling skill
- <app> Grilling skill
- <app> learn skill
- <app> plan skill
- <app> Research skill
- <app> review skill
- <app> ship skill
- <app> spec skill
- <app> Test-Driven Development skill
- <app> Verified Status skill
- graphify reference: query, path, explain
- build
- CheckstyleConfig
- Violations
- beautiful-j2ee — agent instructions
- graphify reference: add a URL and watch a folder
- graphify reference: commit hook and native CLAUDE.md integration
- graphify reference: incremental update and cluster-only
- guard-bash.sh
- /add-slice
- /claim-check
- /clean-room-rebuild
- /corpus-retrieval
- /diagnosing-bugs
- /domain-modeling
- /grilling
- /learn
- /plan
- /research
- /review
- /ship
- /spec
- /tdd
- /verified-status
- Playbooks for `beautiful-j2ee` — load on demand
- graphify reference: GitHub clone and cross-repo merge
- graphify reference: transcribe video and audio
- Clean
- CLAUDE.md
- README.md
- CREDITS.md
- CREDITS.md
- CREDITS.md
- CREDITS.md
- CREDITS.md
- extraction-spec.md
- CREDITS.md
- CREDITS.md
- CREDITS.md
- CREDITS.md
- check-build.sh
- check-lints.sh

## God Nodes (most connected - your core abstractions)
1. `CheckSkillTests` - 37 edges
2. `build_valid_repo()` - 32 edges
3. `Checker` - 26 edges
4. `write()` - 24 edges
5. `YamlParser` - 16 edges
6. `Beautiful J2EE` - 15 edges
7. `J2EE / Jakarta EE best practices` - 15 edges
8. `interface` - 14 edges
9. `What You Must Do When Invoked` - 12 edges
10. `J2EE architecture contract` - 12 edges

## Surprising Connections (you probably didn't know these)
- `problems_to_json()` --references--> `Any`  [EXTRACTED]
  scripts/check-skill.py →   _Bridges community 5 → community 1_

## Import Cycles
- None detected.

## Communities (88 total, 36 thin omitted)

### Community 0 - "CheckSkillTests"
Cohesion: 0.16
Nodes (10): add_portable_plugin(), build_valid_repo(), CheckSkillTests, error_messages(), formatted(), load_checker(), png_header(), portable_with() (+2 more)

### Community 1 - "Path"
Cohesion: 0.16
Nodes (17): check_repo(), Checker, _fold_block(), format_problem(), _is_relative(), _json_key_line(), main(), _normalize_url() (+9 more)

### Community 2 - "J2EE architecture contract"
Cohesion: 0.06
Nodes (26): Added, Changelog, [Unreleased], Contributing, Good first contributions, License, Making a change, Style (+18 more)

### Community 3 - "interface"
Cohesion: 0.07
Nodes (29): author, name, url, interface, publication, description, extensions, com.openai (+21 more)

### Community 4 - "What You Must Do When Invoked"
Cohesion: 0.08
Nodes (24): For /graphify add and --watch, For /graphify query, For the commit hook and native CLAUDE.md integration, For --update and --cluster-only, /graphify, Honesty Rules, Interpreter guard for subcommands, Part A - Structural extraction for code files (+16 more)

### Community 5 - "YamlParser"
Cohesion: 0.25
Nodes (8): Any, Exception, _parse_quoted(), parse_yaml(), Small YAML subset: maps, lists, quoted scalars, | and > blocks., _split_flow(), YamlError, YamlParser

### Community 6 - "Beautiful J2EE"
Cohesion: 0.11
Nodes (18): A worked example, Agent kit (Claude Code), Any agent, Architecture diagrams, Beautiful J2EE, Claude Code, Contributing, Install (+10 more)

### Community 7 - "J2EE / Jakarta EE best practices"
Cohesion: 0.12
Nodes (15): 10. Configuration and observability, 11. Deployment, 12. Testing, 13. Cross-skill contract, 1. Mindset, 2. Before you hand back code, 3. Platform facts, 4. Architecture: Maven modules + vertical slices (+7 more)

### Community 8 - "2. Categories, in ranking order"
Cohesion: 0.12
Nodes (15): 1. Report shape, 2. Categories, in ranking order, 3. Waived gates, 4. How to review, 5. Worked example, 6. Cross-skill contract, Architecture contracts (always Must fix, ranked first), Configuration and observability (+7 more)

### Community 9 - ".main"
Cohesion: 0.25
Nodes (6): SelfCheck, Status, ARCHIVED, READY, Widget, WidgetService

### Community 10 - "Jakarta EE platform digest"
Cohesion: 0.18
Nodes (10): 1. Versions and namespace, 2. CDI, 3. Persistence and transactions, 4. Messaging and concurrency, 5. Presentation, 6. Security, 7. Configuration and observability, 8. Deployment (+2 more)

### Community 11 - "BestPractices"
Cohesion: 0.29
Nodes (4): BestPractices, bp_body(), ReviewSkill, rv_body()

### Community 12 - "A worked review: the widget archive endpoint"
Cohesion: 0.20
Nodes (9): A worked review: the widget archive endpoint, Must fix, Should fix, The fixed module, The module under review, The report, Verdict, Waived gates (+1 more)

### Community 13 - "J2EE patterns"
Cohesion: 0.20
Nodes (9): 1. The use case owns the transaction, 2. The JPA adapter, 3. The outbox, 4. JAX-RS resource, 5. Error mapping, 6. Tenant isolation, 7. Configuration, 8. Testing (+1 more)

### Community 14 - "Java strict for J2EE"
Cohesion: 0.20
Nodes (9): 1. The subset, 2. Result, 3. Records and value objects, 4. Nullability, 5. Exceptions, 6. Concurrency, 7. Checkstyle and SpotBugs, 8. Review questions (+1 more)

### Community 15 - "graphify reference: extra exports and benchmark"
Cohesion: 0.22
Nodes (8): graphify reference: extra exports and benchmark, Step 6b - Wiki (only if --wiki flag), Step 7 - Neo4j export (only if --neo4j or --neo4j-push flag), Step 7a - FalkorDB export (only if --falkordb or --falkordb-push flag), Step 7b - SVG export (only if --svg flag), Step 7c - GraphML export (only if --graphml flag), Step 7d - MCP server (only if --mcp flag), Step 8 - Token reduction benchmark (only if total_words > 5000)

### Community 16 - "check_repo"
Cohesion: 0.39
Nodes (8): check_balance(), check_repo(), cpp_blocks(), doc_files(), main(), Path, Yield (start_line, code) for each java fenced block., Return (line_offset, message) or None. Comments/literals are skipped.

### Community 17 - "J2EE port"
Cohesion: 0.22
Nodes (8): 1. The order of work, 2. Java EE 8 / J2EE → Jakarta EE 11, 3. Spring Boot → Jakarta EE, 4. Legacy servlet / EJB / JSF app, 5. Behavior parity checklist, 6. What not to do, 7. Cross-skill contract, J2EE port

### Community 19 - "run"
Cohesion: 0.36
Nodes (4): CompletedProcess, BuildGate, Gates, run()

### Community 20 - "<app> API Designer Agent"
Cohesion: 0.29
Nodes (6): <app> API Designer Agent, Core Mission, Expertise Areas, Guiding Principles, Output Format, Quality Standards

### Community 21 - "<app> Migration Reviewer Agent"
Cohesion: 0.29
Nodes (6): <app> Migration Reviewer Agent, Core Mission, Expertise Areas, Guiding Principles, Output Format, Quality Standards

### Community 22 - "<app> Architect Agent"
Cohesion: 0.29
Nodes (6): <app> Architect Agent, Core Mission, Expertise Areas, Guiding Principles, Output Format, Quality Standards

### Community 23 - "<app> Build Resolver Agent"
Cohesion: 0.29
Nodes (6): <app> Build Resolver Agent, Core Mission, Expertise Areas, Guiding Principles, Output Format, Quality Standards

### Community 24 - "<app> Code Explorer Agent"
Cohesion: 0.29
Nodes (6): <app> Code Explorer Agent, Core Mission, Expertise Areas, Guiding Principles, Output Format, Quality Standards

### Community 25 - "<app> Code Reviewer Agent"
Cohesion: 0.29
Nodes (6): <app> Code Reviewer Agent, Core Mission, Expertise Areas, Guiding Principles, Output Format, Quality Standards

### Community 26 - "<app> Planner Agent"
Cohesion: 0.29
Nodes (6): <app> Planner Agent, Core Mission, Expertise Areas, Guiding Principles, Output Format, Quality Standards

### Community 27 - "<app> TDD Guide Agent"
Cohesion: 0.29
Nodes (6): <app> TDD Guide Agent, Core Mission, Expertise Areas, Guiding Principles, Output Format, Quality Standards

### Community 28 - "<app> Security Reviewer Agent"
Cohesion: 0.29
Nodes (6): <app> Security Reviewer Agent, Core Mission, Expertise Areas, Guiding Principles, Output Format, Quality Standards

### Community 29 - "<app> Test Author Agent"
Cohesion: 0.29
Nodes (6): <app> Test Author Agent, Core Mission, Expertise Areas, Guiding Principles, Output Format, Quality Standards

### Community 30 - "<app> add-slice skill"
Cohesion: 0.29
Nodes (6): <app> add-slice skill, Core Principles, Output Format, Research References, Rules, When to Activate

### Community 31 - "<app> Claim Check skill"
Cohesion: 0.29
Nodes (6): <app> Claim Check skill, Core Principles, Output Format, Research References, Rules, When to Activate

### Community 32 - "<app> Clean-Room Rebuild skill"
Cohesion: 0.29
Nodes (6): <app> Clean-Room Rebuild skill, Core Principles, Output Format, Research References, Rules, When to Activate

### Community 33 - "<app> Corpus Retrieval skill"
Cohesion: 0.29
Nodes (6): <app> Corpus Retrieval skill, Core Principles, Output Format, Research References, Rules, When to Activate

### Community 34 - "<app> Diagnosing Bugs skill"
Cohesion: 0.29
Nodes (6): <app> Diagnosing Bugs skill, Core Principles, Output Format, Research References, Rules, When to Activate

### Community 35 - "<app> Domain Modeling skill"
Cohesion: 0.29
Nodes (6): <app> Domain Modeling skill, Core Principles, Output Format, Research References, Rules, When to Activate

### Community 36 - "<app> Grilling skill"
Cohesion: 0.29
Nodes (6): <app> Grilling skill, Core Principles, Output Format, Research References, Rules, When to Activate

### Community 37 - "<app> learn skill"
Cohesion: 0.29
Nodes (6): <app> learn skill, Core Principles, Output Format, Research References, Rules, When to Activate

### Community 38 - "<app> plan skill"
Cohesion: 0.29
Nodes (6): <app> plan skill, Core Principles, Output Format, Research References, Rules, When to Activate

### Community 39 - "<app> Research skill"
Cohesion: 0.29
Nodes (6): <app> Research skill, Core Principles, Output Format, Research References, Rules, When to Activate

### Community 40 - "<app> review skill"
Cohesion: 0.29
Nodes (6): <app> review skill, Core Principles, Output Format, Research References, Rules, When to Activate

### Community 41 - "<app> ship skill"
Cohesion: 0.29
Nodes (6): <app> ship skill, Core Principles, Output Format, Research References, Rules, When to Activate

### Community 42 - "<app> spec skill"
Cohesion: 0.29
Nodes (6): <app> spec skill, Core Principles, Output Format, Research References, Rules, When to Activate

### Community 43 - "<app> Test-Driven Development skill"
Cohesion: 0.29
Nodes (6): <app> Test-Driven Development skill, Core Principles, Output Format, Research References, Rules, When to Activate

### Community 44 - "<app> Verified Status skill"
Cohesion: 0.29
Nodes (6): <app> Verified Status skill, Core Principles, Output Format, Research References, Rules, When to Activate

### Community 45 - "graphify reference: query, path, explain"
Cohesion: 0.33
Nodes (5): For /graphify explain, For /graphify path, graphify reference: query, path, explain, Step 0 — Constrained query expansion (REQUIRED before traversal), Step 1 — Traversal

### Community 46 - "build"
Cohesion: 0.53
Nodes (5): build(), main(), package_files(), Path, Files to package, relative to root, in a stable order.

### Community 49 - "beautiful-j2ee — agent instructions"
Cohesion: 0.50
Nodes (3): beautiful-j2ee — agent instructions, graphify, Model routing (Claude Code + Ollama)

### Community 50 - "graphify reference: add a URL and watch a folder"
Cohesion: 0.50
Nodes (3): For /graphify add, For --watch, graphify reference: add a URL and watch a folder

### Community 51 - "graphify reference: commit hook and native CLAUDE.md integration"
Cohesion: 0.50
Nodes (3): For git commit hook, For native CLAUDE.md integration, graphify reference: commit hook and native CLAUDE.md integration

### Community 52 - "graphify reference: incremental update and cluster-only"
Cohesion: 0.50
Nodes (3): For --cluster-only, For --update (incremental re-extraction), graphify reference: incremental update and cluster-only

### Community 53 - "guard-bash.sh"
Cohesion: 0.83
Nodes (3): has(), has_i(), guard-bash.sh script

## Knowledge Gaps
- **326 isolated node(s):** `READY`, `ARCHIVED`, `$schema`, `name`, `version` (+321 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **36 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Beautiful J2EE` connect `Beautiful J2EE` to `J2EE architecture contract`?**
  _High betweenness centrality (0.003) - this node is a cross-community bridge._
- **What connects `READY`, `ARCHIVED`, `$schema` to the rest of the system?**
  _332 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `J2EE architecture contract` be split into smaller, more focused modules?**
  _Cohesion score 0.06060606060606061 - nodes in this community are weakly interconnected._
- **Should `interface` be split into smaller, more focused modules?**
  _Cohesion score 0.06666666666666667 - nodes in this community are weakly interconnected._
- **Should `What You Must Do When Invoked` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._
- **Should `Beautiful J2EE` be split into smaller, more focused modules?**
  _Cohesion score 0.1111111111111111 - nodes in this community are weakly interconnected._
- **Should `J2EE / Jakarta EE best practices` be split into smaller, more focused modules?**
  _Cohesion score 0.125 - nodes in this community are weakly interconnected._