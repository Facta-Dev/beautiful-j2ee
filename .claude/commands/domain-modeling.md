---
name: domain-modeling
description: "Sharpen the <app> domain model: terms, GLOSSARY.md and ADRs."
division: core
---

# /domain-modeling

## Delegate

Delegate to the **domain-modeling** skill.

Activate when the <app> domain language is in question: an ambiguous or
overloaded term, a described behavior that the code contradicts, a
`GLOSSARY.md` entry to write or correct, or a decision worth an ADR. The
skill challenges conflicting terms, resolves vocabulary into the glossary
inline, cross-references the code, and records an ADR only when the decision
is hard to reverse, surprising and a real trade-off.

Do not activate for reading existing vocabulary, for writing tests (use
`tdd`), or for a diff review (use `review`).
