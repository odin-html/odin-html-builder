---
id: contract-level-doc-comments-on-the
level: task
title: "Contract-level doc comments on the generated public procedures"
short_code: "HTML-T-0002"
created_at: 2026-10-17T18:06:45.564262+00:00
updated_at: 2026-10-17T18:07:04.737368+00:00
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
triage_trigger: "before v0.1.0 is tagged"
triaged_on: 2026-10-17
---

# Contract-level doc comments on the generated public procedures

## Objective

**Triage (2026-10-17):** later, before v0.1.0 is tagged — a success criterion of the first release, not of the import

`HTML-V-0001` makes contract-level doc comments on every public procedure a success criterion: what it writes, what it escapes, what it allocates. The generated element and attribute procedures have none today; their contract is stated once, in the file comments.

Give every public procedure a doc comment, through the generator where the procedure is generated (see `HTML-T-0001`).

## Acceptance Criteria

- [ ] Every public procedure in `html/a`, `html/h` and `html/hx` carries a doc comment.
- [ ] Generated procedures get theirs from the generator, not by hand.
