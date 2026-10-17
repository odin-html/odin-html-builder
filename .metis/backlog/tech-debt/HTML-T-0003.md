---
id: readme-examples-are-not-compiled
level: task
title: "README examples are not compiled by a test"
short_code: "HTML-T-0003"
created_at: 2026-10-17T18:13:49.793410+00:00
updated_at: 2026-10-17T18:13:55.449060+00:00
parent: 
blocked_by: []
archived: false

tags:
  - "#task"
  - "#phase/backlog"
  - "#tech-debt"


exit_criteria_met: false
initiative_id: NULL
triage: later
triage_trigger: "before v0.1.0 is tagged, or at the next README edit"
triaged_on: 2026-10-17
---

# README examples are not compiled by a test

## Objective

**Triage (2026-10-17):** later, before v0.1.0 is tagged, or at the next README edit — the examples are correct today; drift starts with the next change

The family convention, as in odin-rdf, is that README examples are compiled and their output asserted in `tests/readme`, so a README cannot drift from the code. The README's two examples (a page, and a component that takes children) were checked by hand when written, and no test holds them. The same gap exists in odin-html-ui; this item covers the builder, the pattern then carries over.

## Acceptance Criteria

- [ ] `tests/readme` compiles both README examples and asserts the output the README shows.
- [ ] `make test` and CI run it.
