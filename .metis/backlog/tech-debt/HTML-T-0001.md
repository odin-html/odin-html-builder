---
id: the-element-attribute-and-htmx
level: task
title: "The element, attribute and htmx lists have no generator"
short_code: "HTML-T-0001"
created_at: 2026-10-17T18:06:44.421377+00:00
updated_at: 2026-10-17T18:07:03.343367+00:00
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
triage_trigger: "when an element, attribute or htmx attribute has to be added"
triaged_on: 2026-10-17
---

# The element, attribute and htmx lists have no generator

## Objective

**Triage (2026-10-17):** later, when an element, attribute or htmx attribute has to be added — the hand-maintained lists are correct today; drift starts with the first edit

`html/h/elements.odin`, `html/a/attributes.odin` and `html/hx/htmx.odin` say in their own comments that they are generated lists, one proc per element, attribute or htmx attribute. The generator was not part of the import, so today the lists are maintained by hand, and a hand edit can drift from the shape the rest of each list has.

Bring the generator into this repository (or write it), so that adding an element or attribute is a regeneration, not an edit.

## Acceptance Criteria

- [ ] A generator in this repository reproduces the three files byte for byte from its input.
- [ ] The files' headers name the generator and how to run it.
- [ ] `make check` and `make test` stay green.
