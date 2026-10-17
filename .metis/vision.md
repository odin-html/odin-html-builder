---
id: odin-html-builder
level: vision
title: "odin-html-builder"
short_code: "HTML-V-0001"
created_at: 2026-10-17T17:54:52.647529+00:00
updated_at: 2026-10-17T17:54:52.647529+00:00
archived: false

tags:
  - "#vision"
  - "#phase/draft"


exit_criteria_met: false
initiative_id: NULL
---

# odin-html-builder Vision

## Purpose

odin-html-builder writes HTML from Odin. It is a library of primitives, not a
framework: a builder whose elements are Odin scopes, a typed attribute model
with escaping by default, and htmx attribute helpers — three packages that
depend only on `core:` and know nothing about HTTP, routing or a page's
lifecycle. Whatever serves the response owns those.

The packages:

- **`html/h`** — elements and rendering. One proc per HTML (and SVG) element,
  `_open` variants for components that take children, `text`/`textf`/`raw`/
  `doctype`/`comment`, the `render` / `render_with` / `render_to_string` entry
  points, and the render's failure model (`Failure`, `fail`, `failed`).
- **`html/a`** — attributes. `Attr` and `Value`, one constructor per attribute,
  `attr`/`attr_if`/`class`/`data`/`aria`/`join`, the escapers and
  `write_attrs`, and `name_is_safe` for attribute names derived from data.
- **`html/hx`** — htmx 4.0 attribute helpers, in their own namespace so that
  `hx.target` and `a.title` read apart at the call site, with `on`/`on_htmx`
  for event handlers and the `inherited`/`merge` modifiers.

It is the foundation of the odin-html family. odin-html-ui, the component
library, is built on it in a sibling repository and depends on it alone.

## Current State

**Extracted and working, not yet released (2026-10-17).** The three packages
and their suite were extracted into this repository as they stood in the
application they were written for; the code is unchanged by the move but for
its import paths. The repository has no commits and no tag yet.

- The collection is the repository root, as in the odin-rdf family:
  `-collection:html=<path to odin-html-builder>`, and the packages import each
  other as `html:html/a`, `html:html/h`, `html:html/hx`.
- `html/html_test.odin` holds the suite: **43 tests**, all passing under
  `make test` with leaks and bad frees promoted to failures, exercising the
  three packages composed through their public API only. `make check` vets
  every package with `-vet -strict-style`, clean.
- CI runs both on ubuntu, macos and windows, on Odin `latest`.
- `html/h/elements.odin`, `html/a/attributes.odin` and `html/hx/htmx.odin` are
  generated lists — the code's own comments say so — but the generator did not
  come with the extraction. Until it does, they are maintained by hand.

## Future State

A tagged `v0.1.0` that odin-html-ui pins in CI the way odin-rdf's consumers
pin odin-rdf-parser, so a red build in either repository means that
repository broke. After that the builder grows only on a consumer's evidence:
a capability odin-html-ui or odin-html-app needs and cannot express, stated
with the code that cannot be written.

## Principles

These are the design as the code's own comments state it; a change that
breaks one is a change to this vision, not to a file.

1. **The block is the element.** Every non-void element carries
   `@(deferred_out = close)`, so its closing tag is written when the *caller's*
   scope ends — a block, an `if` branch, a loop body, or a proc body. The
   shape of the code is the shape of the markup. There is no tag stack, and a
   mismatched or missing close is not expressible. Void elements close
   nothing but are written in a block too, `{h.br()}`, so a brace always marks
   an element's extent; the block costs nothing. What this cannot express is
   an open and a close in different scopes: branch around the whole subtree.
2. **The sink lives in the context, not in a parameter.** `render` installs
   its `State` in `context.user_ptr`, and Odin passes the context down
   implicitly, so a component is a plain `proc()` with no writer threaded
   through it. That is what makes the design work without closures; data
   reaches a component as an explicit parameter (`render_with`).
3. **Components hand an element to their caller.** A component that takes
   children opens its wrapper with an `_open` variant inside `h.open_scope()`
   and carries `@(deferred_none = h.close_all)`; the caller's block supplies
   the children and `close_all` closes back to the component's own mark,
   innermost first. `open_scope` and `close_all` are one unit and neither
   half is meaningful alone. The pending list is bounded by component nesting
   depth, not document size (128, past any real tree); overflowing it is a
   template bug, so it fails the render instead of growing. Ordinary elements
   never touch it.
4. **Errors are sticky and checked once.** A render ends badly in two ways —
   the writer failing underneath it (`io.Error`), or a component deciding
   there is no page (`Failure`) — and both are held in one sticky `Error`:
   the first is what is reported, every write after it is dropped, and the
   caller checks once at the end. `Error` is `#shared_nil`, so a nil
   `io.Error` is a nil `Error`. Structural misuse (half a component pair, a tag
   opened where nothing can close it, an unclosed component at the end) fails
   the render as `.Invalid_Write` rather than returning quietly misnested
   markup — already written bytes cannot be taken back, but they are never
   reported as complete.
5. **A component fails the page without a return value.** `h.fail(.Not_Found)`
   from five levels down abandons the render, and no intermediate caller has
   to know a component it calls can fail. `Failure` is four kinds of nothing
   — `Not_Found`, `Not_Permitted`, `Invalid`, `Internal` — deliberately not an
   HTTP status: this package writes to an `io.Writer` and has never known what
   a request is, so the transport maps a kind to a status. A component drawing
   a fallback in its own box is not a failure and does not use this.
6. **Escaped by default, raw by name.** `text` escapes `& < >`; attribute
   values escape `& < " '`, which is what stops a value breaking out of its
   quote. `raw` is unescaped and exists for `<script>` and `<style>`, the
   raw-text elements — and is therefore the one place interpolating user data
   is an injection. Attribute names are a bigger surface than values, so a
   name derived from data goes through `a.name_is_safe`, which refuses `on*`
   case-insensitively.
7. **Attributes are typed values.** `nil` omits the attribute, `string` and
   `int` render as `name="value"`, `bool` is HTML's bare boolean, and
   `[]string` is a class list joined with spaces with empty parts dropped — so
   a conditional needs no branch at the call site. A zero `Attr` (`attr_if`'s
   false case) is skipped. **Later duplicates win**, so a component applies its
   defaults first and the caller's attributes override them. ARIA and htmx
   have no bare booleans, and their helpers spell `"true"`/`"false"`.
8. **A render is bounded by a per-request arena.** Anything an attribute
   constructor allocates comes from `context.temp_allocator`, on the
   assumption that the caller frees it per request.
9. **Dependencies run one way:** `h → a`, `hx → a`, and `a` knows nothing
   about elements. Nothing outside `core:`.

## Contract with odin-html-ui

odin-html-ui is built on this repository and nothing else, through the same
`html:` collection. What it relies on, and what therefore needs a version
decision to change:

- the element procs and their `_open` variants in `html/h`, `h.elem` /
  `h.elem_open`, and the `open_scope` / `@(deferred_none = h.close_all)`
  pairing as principle 3 states it — every one of its components is written
  that way;
- `render_to_string` and the sticky `Error`, through which its own suites
  assert markup;
- `a.Attr`, `a.join`, `a.attr_if`, `a.class`, `a.data`, `a.aria`, and the
  later-duplicate-wins rule, which is how a component's defaults yield to its
  caller's attributes;
- the `hx` helpers it renders onto interactive components;
- the import paths `html:html/a`, `html:html/h`, `html:html/hx`.

odin-html-ui owns what a component looks like and which classes it carries;
this repository owns how markup is written. A component that needs something
the builder cannot express states it here with the code it cannot write,
rather than working around it in the component.

## Success Criteria

- `v0.1.0` tagged, and odin-html-ui pinning it in CI.
- The suite green on all three runners, with leaks and bad frees as failures.
- Every public procedure carries a contract-level doc comment.
- No dependency outside `core:`.

## Constraints

- Odin only, `core:` only. No servers, no HTTP, no routing: a library, not an
  application.
- Public. Needs are stated against the family's placeholder consumer
  `odin-html-app` with evidence that stands on its own.
- The element and attribute lists are generated in form; until the generator
  is in this repository, an edit to them is by hand and must keep that form.
