/* Tests for the html templating packages. They sit in html/, above h/, a/ and
hx/ rather than inside them, because the interesting behaviour is what an app
sees: the three packages composed through their public API. Nothing here
reaches for a private proc.

Nothing here closes a tag: every non-void element closes itself when the Odin
scope containing the call ends, so the shape of the block is the shape of the
markup. Several tests below exist only to pin that down. */
package html

import "core:io"
import "core:strings"
import "core:testing"

import "html:html/a"
import "html:html/h"
import "html:html/hx"

/* Renders into the temp allocator: every test's output dies at the next
free_all, so nothing here has to be deleted. */
@(private = "file")
rendered :: proc(t: ^testing.T, body: proc()) -> string {
	out, err := h.render_to_string(body, context.temp_allocator)
	testing.expect_value(t, err, nil)
	return out
}

/* Attributes rendered on their own, without an element around them. Note the
leading space in every expectation below: write_attrs emits one before each
attribute so the caller can concatenate straight after a tag name. */
@(private = "file")
attrs_to_string :: proc(t: ^testing.T, attrs: ..a.Attr) -> string {
	b := strings.builder_make(context.temp_allocator)
	err := a.write_attrs(strings.to_writer(&b), attrs)
	testing.expect_value(t, err, nil)
	return strings.to_string(b)
}

@(private = "file")
escaped_text :: proc(t: ^testing.T, s: string) -> string {
	b := strings.builder_make(context.temp_allocator)
	err := a.escape_text(strings.to_writer(&b), s)
	testing.expect_value(t, err, nil)
	return strings.to_string(b)
}

@(private = "file")
escaped_attr :: proc(t: ^testing.T, s: string) -> string {
	b := strings.builder_make(context.temp_allocator)
	err := a.escape_attr(strings.to_writer(&b), s)
	testing.expect_value(t, err, nil)
	return strings.to_string(b)
}

// ---------------------------------------------------------------- escaping

@(test)
test_text_escaping :: proc(t: ^testing.T) {
	testing.expect_value(t, escaped_text(t, ""), "")
	testing.expect_value(t, escaped_text(t, "plain"), "plain")
	testing.expect_value(t, escaped_text(t, "<script>alert(1)</script>"), "&lt;script&gt;alert(1)&lt;/script&gt;")

	// Replacements at both ends, so the trailing copy of the tail is exercised.
	testing.expect_value(t, escaped_text(t, "<>"), "&lt;&gt;")
	testing.expect_value(t, escaped_text(t, "&amp;"), "&amp;amp;")

	// Quotes can only escape an attribute value, never element content, so
	// text leaves them intact rather than littering the output with entities.
	testing.expect_value(t, escaped_text(t, `he said "hi" & 'bye'`), `he said "hi" &amp; 'bye'`)
}

@(test)
test_attr_escaping :: proc(t: ^testing.T) {
	// The attack this exists to stop: a value closing its own quote and
	// opening an event handler.
	testing.expect_value(t, escaped_attr(t, `" onclick="alert(1)`), `&quot; onclick=&quot;alert(1)`)
	testing.expect_value(t, escaped_attr(t, "it's"), "it&#39;s")
	testing.expect_value(t, escaped_attr(t, "?a=1&b=2"), "?a=1&amp;b=2")

	// '>' is left alone: inside a quoted value it cannot end the tag.
	testing.expect_value(t, escaped_attr(t, "a < b > c"), "a &lt; b > c")
}

// ---------------------------------------------------------------- attributes

@(test)
test_attr_values_render_by_type :: proc(t: ^testing.T) {
	testing.expect_value(t, attrs_to_string(t, a.id("main")), ` id="main"`)
	testing.expect_value(t, attrs_to_string(t, a.colspan(3)), ` colspan="3"`)
	testing.expect_value(t, attrs_to_string(t, a.tabindex(-1)), ` tabindex="-1"`)

	// HTML bare booleans: present or absent, never disabled="false".
	testing.expect_value(t, attrs_to_string(t, a.disabled(true)), ` disabled`)
	testing.expect_value(t, attrs_to_string(t, a.disabled(false)), "")

	// ARIA is not a bare boolean, and the generated aria_* procs know it.
	testing.expect_value(t, attrs_to_string(t, a.aria_hidden(false)), ` aria-hidden="false"`)
	testing.expect_value(t, attrs_to_string(t, a.aria_expanded(true)), ` aria-expanded="true"`)

	// String values are escaped on the way out.
	testing.expect_value(t, attrs_to_string(t, a.title(`a "b" & c`)), ` title="a &quot;b&quot; &amp; c"`)
}

/* The generic aria() helper takes a Value, so a bool reaches the bare-boolean
path and renders `aria-disabled` with no value -- which ARIA does not accept.
The generated aria_disabled() is the one that spells it "true". */
@(test)
test_generic_aria_helper_takes_a_string_not_a_bool :: proc(t: ^testing.T) {
	testing.expect_value(t, attrs_to_string(t, a.aria("disabled", true)), ` aria-disabled`)
	testing.expect_value(t, attrs_to_string(t, a.aria("disabled", "true")), ` aria-disabled="true"`)
	testing.expect_value(t, attrs_to_string(t, a.aria_disabled(true)), ` aria-disabled="true"`)
}

@(test)
test_prefixing_helpers :: proc(t: ^testing.T) {
	testing.expect_value(t, attrs_to_string(t, a.data("user-id", "u7")), ` data-user-id="u7"`)
	testing.expect_value(t, attrs_to_string(t, a.data("count", 3)), ` data-count="3"`)
	testing.expect_value(t, attrs_to_string(t, a.aria("label", "Close")), ` aria-label="Close"`)
	testing.expect_value(t, attrs_to_string(t, a.attr("popovertarget", "menu")), ` popovertarget="menu"`)
}

@(test)
test_attributes_are_omitted :: proc(t: ^testing.T) {
	// A nil value drops the attribute, so an optional field needs no branch.
	testing.expect_value(t, attrs_to_string(t, a.attr("title", nil)), "")

	// attr_if returns a zero Attr, whose empty name is skipped the same way.
	testing.expect_value(t, attrs_to_string(t, a.attr_if(false, a.id("x"))), "")
	testing.expect_value(t, attrs_to_string(t, a.attr_if(true, a.id("x"))), ` id="x"`)

	// Neither one disturbs its neighbours' order.
	testing.expect_value(
		t,
		attrs_to_string(t, a.id("x"), a.attr_if(false, a.class("gone")), a.role("row")),
		` id="x" role="row"`,
	)
}

@(test)
test_class_drops_empty_parts :: proc(t: ^testing.T) {
	// The point of dropping them: `cond ? "x" : ""` needs no branch.
	testing.expect_value(t, attrs_to_string(t, a.class("row", "", "row-admin")), ` class="row row-admin"`)
	testing.expect_value(t, attrs_to_string(t, a.class("only")), ` class="only"`)
	testing.expect_value(t, attrs_to_string(t, a.class("", "tail")), ` class="tail"`)

	// All parts empty still emits the attribute, empty.
	testing.expect_value(t, attrs_to_string(t, a.class("", "")), ` class=""`)
	testing.expect_value(t, attrs_to_string(t, a.class()), ` class=""`)

	// Parts are escaped individually.
	testing.expect_value(t, attrs_to_string(t, a.class(`a"b`, "c")), ` class="a&quot;b c"`)
}

/* class() clones its variadic parts, because the backing array lives in the
caller's frame and dies with the call. Build one somewhere else, let the stack
be overwritten, and only then render it. */
@(test)
test_class_survives_its_constructing_call :: proc(t: ^testing.T) {
	build :: proc(admin: bool) -> a.Attr {
		return a.class("row", admin ? "row-admin" : "")
	}

	churn :: proc() -> int {
		scratch: [512]int
		for &v, i in scratch {
			v = i * 3
		}
		return scratch[len(scratch) - 1]
	}

	attr := build(true)
	testing.expect_value(t, churn(), 511 * 3)
	testing.expect_value(t, attrs_to_string(t, attr), ` class="row row-admin"`)
}

/* Later duplicates winning is what lets a component write its defaults first
and append the caller's attributes after them. */
@(test)
test_later_attributes_override_earlier :: proc(t: ^testing.T) {
	testing.expect_value(t, attrs_to_string(t, a.class("default"), a.class("caller")), ` class="caller"`)

	// An override can turn an attribute off, either by being false...
	testing.expect_value(t, attrs_to_string(t, a.disabled(true), a.disabled(false)), "")
	// ...or by being nil, which removes it outright.
	testing.expect_value(t, attrs_to_string(t, a.title("old"), a.attr("title", nil)), "")

	// Only the duplicate moves; everything else keeps its position.
	testing.expect_value(
		t,
		attrs_to_string(t, a.id("a"), a.class("first"), a.role("row"), a.class("last")),
		` id="a" role="row" class="last"`,
	)
}

@(test)
test_join_concatenates_groups :: proc(t: ^testing.T) {
	sortable := []a.Attr{a.aria_sort("ascending"), a.class("sortable")}

	merged := a.join(sortable, {a.class("wide")})
	testing.expect_value(t, len(merged), 3)
	// Group order is preserved, so override semantics survive the join.
	testing.expect_value(t, attrs_to_string(t, ..merged), ` aria-sort="ascending" class="wide"`)

	testing.expect_value(t, len(a.join()), 0)
	testing.expect_value(t, len(a.join(sortable, {})), 2)
}

/* An escaped value behind a handler name is still an XSS, so any name derived
from data has to pass this before it is rendered. */
@(test)
test_name_is_safe :: proc(t: ^testing.T) {
	testing.expect(t, a.name_is_safe("data-user-id"), "hyphens are fine")
	testing.expect(t, a.name_is_safe("hx-on:click"), "colons are fine")
	testing.expect(t, a.name_is_safe("x_1.y"), "underscores, digits and dots are fine")

	testing.expect(t, !a.name_is_safe(""), "an empty name would render as a stray space")
	testing.expect(t, !a.name_is_safe("onclick"), "event handlers are rejected")
	testing.expect(t, !a.name_is_safe("ONCLICK"), "shouting does not help")
	// Attribute names are case-insensitive to the parser, so the check has to
	// be too -- OnClick fires exactly like onclick.
	testing.expect(t, !a.name_is_safe("OnClick"), "mixed case is still an event handler")
	testing.expect(t, !a.name_is_safe("on"), "the prefix alone is enough to reject")

	testing.expect(t, !a.name_is_safe("class name"), "a space would start a second attribute")
	testing.expect(t, !a.name_is_safe(`x"`), "a quote would close the value")
	testing.expect(t, !a.name_is_safe("x>y"), "a bracket would close the tag")
	testing.expect(t, !a.name_is_safe("x=y"), "an equals sign would split the name")
}

// ---------------------------------------------------------------- elements

@(test)
test_blocks_close_their_elements :: proc(t: ^testing.T) {
	out := rendered(t, proc() {
		{h.div(a.id("outer"))
			{h.p()
				h.text("hi")
			}
			{h.span()
				h.em()
			}
		}
	})
	testing.expect_value(t, out, `<div id="outer"><p>hi</p><span><em></em></span></div>`)
}

/* Any scope Odin closes will do, not just a bare block: a loop body and an if
branch close what they opened, and so does a proc body -- which is what lets a
component open an element and simply stop, with no block of its own. */
@(test)
test_every_kind_of_scope_closes :: proc(t: ^testing.T) {
	wrapper :: proc() {
		h.section()
		h.text("in a proc")
	}

	out := rendered(t, proc() {
		for i in 0 ..< 2 {
			{h.li()
				h.textf("%d", i)
			}
		}
		if true {
			{h.b()
				h.text("yes")
			}
		}
		wrapper()
	})
	testing.expect_value(t, out, `<li>0</li><li>1</li><b>yes</b><section>in a proc</section>`)
}

/* Nesting used to be capped by the tag stack. There is no stack now, so the
only limit is Odin's own -- worth a test, since the depth this reaches would
have tripped the old MAX_DEPTH assert. */
@(test)
test_deep_nesting :: proc(t: ^testing.T) {
	DEPTH :: 64

	nest :: proc(n: int) {
		if n == 0 {
			return
		}

		{h.div()
			nest(n - 1)
		}
	}

	out := rendered(t, proc() {
		nest(DEPTH)
	})

	opened := strings.repeat("<div>", DEPTH, context.temp_allocator)
	closed := strings.repeat("</div>", DEPTH, context.temp_allocator)
	testing.expect_value(t, out, strings.concatenate({opened, closed}, context.temp_allocator))
}

@(test)
test_void_elements_have_no_closing_tag :: proc(t: ^testing.T) {
	out := rendered(t, proc() {
		{h.div()
			{h.img(a.src("/logo.png"), a.alt("Logo"))}
			{h.br()}
			{h.input(a.type("checkbox"), a.checked(true), a.name("agree"))}
		}
	})
	testing.expect_value(
		t,
		out,
		`<div><img src="/logo.png" alt="Logo"><br><input type="checkbox" checked name="agree"></div>`,
	)
}

@(test)
test_text_is_escaped_and_raw_is_not :: proc(t: ^testing.T) {
	out := rendered(
		t,
		proc() {
			{ h.p(); h.text("<b>& you</b>") }
			// <script> is raw text: escaping here would corrupt the payload, which
			// is also why nothing user-supplied may go through raw().
			{h.script()
				h.raw("if (a < b && c > d) { run(); }")
			}
		},
	)
	testing.expect_value(t, out, "<p>&lt;b&gt;&amp; you&lt;/b&gt;</p><script>if (a < b && c > d) { run(); }</script>")
}

@(test)
test_textf_formats_then_escapes :: proc(t: ^testing.T) {
	out := rendered(t, proc() {
		{h.span()
			h.textf("%d < %d & rising", 3, 5)
		}
	})
	testing.expect_value(t, out, "<span>3 &lt; 5 &amp; rising</span>")
}

@(test)
test_doctype_and_comment :: proc(t: ^testing.T) {
	out := rendered(
	t,
	proc() {
		h.doctype()
		// A `--` inside a comment ends it early in some parsers, so it is
		// defanged rather than passed through.
		h.comment("nav -- start")
		{h.html(a.lang("en"))}
	},
	)
	testing.expect_value(t, out, `<!DOCTYPE html><!--nav - - start--><html lang="en"></html>`)
}

@(test)
test_custom_elements_via_elem :: proc(t: ^testing.T) {
	out := rendered(t, proc() {
		{h.elem("my-widget", a.attr("value", "7"))
			h.text("x")
		}
		{h.void_el("my-marker")}
	})
	testing.expect_value(t, out, `<my-widget value="7">x</my-widget><my-marker>`)
}

// ---------------------------------------------------------------- rendering

@(private = "file")
list_item :: proc(label: string) {
	h.li()
	h.text(label)
}

/* The sink lives in context.user_ptr, which Odin threads down implicitly, so a
nested component is a plain proc() with no writer parameter. That is the whole
reason the design works without closures. */
@(test)
test_nested_components_share_the_sink :: proc(t: ^testing.T) {
	out := rendered(t, proc() {
		{h.ul()
			list_item("one")
			list_item("two")
		}
	})
	testing.expect_value(t, out, "<ul><li>one</li><li>two</li></ul>")
}

/* Each entry point installs its own State on the stack, so nothing carries
from one render into the next. */
@(test)
test_renders_are_independent :: proc(t: ^testing.T) {
	first := rendered(t, proc() {
		{h.div()}
	})
	second := rendered(t, proc() {
		{h.span()}
	})
	testing.expect_value(t, first, "<div></div>")
	testing.expect_value(t, second, "<span></span>")
}

@(test)
test_render_writes_to_any_writer :: proc(t: ^testing.T) {
	b := strings.builder_make(context.temp_allocator)
	err := h.render(strings.to_writer(&b), proc() {
		{h.h1(a.class("title"))
			h.text("Hello")
		}
	})
	testing.expect_value(t, err, nil)
	testing.expect_value(t, strings.to_string(b), `<h1 class="title">Hello</h1>`)
}

// ---------------------------------------------------------------- error path

/* A writer that accepts a fixed number of bytes and then fails every write.
`writes_after_failure` is the interesting field: once the sticky error is set,
h must stop touching the writer entirely. */
@(private = "file")
Failing_Writer :: struct {
	budget:               int,
	sink:                 strings.Builder,
	failed:               bool,
	writes_after_failure: int,
}

@(private = "file")
failing_writer :: proc(fw: ^Failing_Writer) -> io.Writer {
	return io.Writer{procedure = failing_writer_proc, data = fw}
}

@(private = "file")
failing_writer_proc :: proc(
	stream_data: rawptr,
	mode: io.Stream_Mode,
	p: []byte,
	offset: i64,
	whence: io.Seek_From,
) -> (
	n: i64,
	err: io.Error,
) {
	fw := cast(^Failing_Writer)stream_data
	#partial switch mode {
	case .Write:
		if fw.failed {
			fw.writes_after_failure += 1
			return 0, .Short_Write
		}
		if len(p) > fw.budget {
			fw.failed = true
			return 0, .Short_Write
		}
		fw.budget -= len(p)
		strings.write_bytes(&fw.sink, p)
		return i64(len(p)), nil
	case .Query:
		return io.query_utility({.Write, .Query})
	}
	return 0, .Unsupported
}

@(test)
test_write_errors_are_sticky :: proc(t: ^testing.T) {
	// Enough for "<" and "div", not for the class attribute that follows.
	fw := Failing_Writer {
		budget = 4,
		sink   = strings.builder_make(context.temp_allocator),
	}

	err := h.render(failing_writer(&fw), proc() {
		{h.div(a.class("x"))
			h.text("body")
		}
	})

	testing.expect_value(t, err, io.Error.Short_Write)
	testing.expect_value(t, strings.to_string(fw.sink), "<div")
	// The first failure wins and everything after it is dropped, so a broken
	// socket does not turn into a wall of write errors.
	testing.expect_value(t, fw.writes_after_failure, 0)
}

/* Closing tags are deferred, so they run on the way out of a render that has
already failed -- every one of them, four scopes deep. The sticky check is what
keeps that unwind from hammering a dead writer. */
@(test)
test_failed_render_stays_quiet_while_unwinding :: proc(t: ^testing.T) {
	fw := Failing_Writer {
		budget = 0,
		sink   = strings.builder_make(context.temp_allocator),
	}

	err := h.render(failing_writer(&fw), proc() {
		{h.table()
			{h.tbody()
				{h.tr()
					{h.td()
						h.text("cell")
					}
				}
			}
		}
	})

	testing.expect_value(t, err, io.Error.Short_Write)
	testing.expect_value(t, strings.to_string(fw.sink), "")
	testing.expect_value(t, fw.writes_after_failure, 0)
}

// ---------------------------------------------------------------- htmx

@(test)
test_hx_booleans_are_strings :: proc(t: ^testing.T) {
	testing.expect_value(t, hx.tf(true), "true")
	testing.expect_value(t, hx.tf(false), "false")
	testing.expect_value(t, attrs_to_string(t, hx.boost(hx.tf(true))), ` hx-boost="true"`)
	testing.expect_value(t, attrs_to_string(t, hx.boost(hx.tf(false))), ` hx-boost="false"`)

	// The trap tf() exists to avoid: a bool reaches the bare-boolean path and
	// renders an empty hx-boost, which htmx ignores.
	testing.expect_value(t, attrs_to_string(t, hx.boost(true)), ` hx-boost`)

	// hx-boost also takes a config string, which is why these procs take Value.
	testing.expect_value(
		t,
		attrs_to_string(t, hx.boost("swap:outerSync target:#main")),
		` hx-boost="swap:outerSync target:#main"`,
	)
}

@(test)
test_hx_on_builds_the_attribute_name :: proc(t: ^testing.T) {
	testing.expect_value(t, attrs_to_string(t, hx.on("click", "go()")), ` hx-on:click="go()"`)

	// The shorthand drops the "htmx" segment. Colon-separated, because the DOM
	// lowercases names and hx-on:htmx:beforeRequest would never fire.
	testing.expect_value(t, attrs_to_string(t, hx.on_htmx("before:request", "go()")), ` hx-on::before:request="go()"`)

	// The script is an attribute value like any other, so it cannot break out.
	testing.expect_value(t, attrs_to_string(t, hx.on("click", `alert("x")`)), ` hx-on:click="alert(&quot;x&quot;)"`)
}

@(test)
test_hx_modifiers_suffix_the_name :: proc(t: ^testing.T) {
	testing.expect_value(t, attrs_to_string(t, hx.inherited(hx.target("#main"))), ` hx-target:inherited="#main"`)
	testing.expect_value(t, attrs_to_string(t, hx.merge(hx.disable("true"))), ` hx-disable:merge="true"`)
	testing.expect_value(
		t,
		attrs_to_string(t, hx.mod(hx.swap("innerHTML"), "transition")),
		` hx-swap:transition="innerHTML"`,
	)

	// A modifier changes the name, so an inherited attribute and a local one
	// are distinct and neither overrides the other.
	testing.expect_value(
		t,
		attrs_to_string(t, hx.inherited(hx.target("#a")), hx.target("#b")),
		` hx-target:inherited="#a" hx-target="#b"`,
	)
}

// ---------------------------------------------------------------- integration

User :: struct {
	id:         string,
	name:       string,
	role:       string,
	suspended:  bool,
	detail_url: string,
}

/* The example from the README, verbatim. If this stops compiling or its
output changes, the documented usage is wrong. */
@(private = "file")
user_table :: proc(users: []User) {
	{h.table(a.class("w-full"))
		{h.tbody(hx.inherited(hx.target("#rows")))
			for u in users {
				{h.tr(
					a.class("row", u.role == "admin" ? "row-admin" : ""),
					a.data("user-id", u.id),
					a.attr_if(u.suspended, a.aria_disabled(true)),
					hx.get(u.detail_url),
					hx.on("click", "this.classList.add('seen')"),
				)
					{h.td()
						h.text(u.name)
					}
					{h.td()
						h.text(u.role)
					}
				}
			}
		}
	}
}

@(test)
test_documented_example :: proc(t: ^testing.T) {
	users := []User {
		{id = "u1", name = "Ada <admin>", role = "admin", suspended = false, detail_url = "/users/u1"},
		{id = "u2", name = "Bob", role = "viewer", suspended = true, detail_url = "/users/u2?ref=a&b"},
	}

	b := strings.builder_make(context.temp_allocator)
	err := h.render_with(strings.to_writer(&b), user_table, users)
	testing.expect_value(t, err, nil)

	expected := strings.concatenate(
		{
			`<table class="w-full">`,
			`<tbody hx-target:inherited="#rows">`,
			// Not suspended, so attr_if drops the aria attribute entirely.
			`<tr class="row row-admin" data-user-id="u1" hx-get="/users/u1"`,
			` hx-on:click="this.classList.add(&#39;seen&#39;)">`,
			`<td>Ada &lt;admin&gt;</td><td>admin</td>`,
			`</tr>`,
			// Not an admin, so the empty class part vanishes; suspended, so
			// aria-disabled appears.
			`<tr class="row" data-user-id="u2" aria-disabled="true" hx-get="/users/u2?ref=a&amp;b"`,
			` hx-on:click="this.classList.add(&#39;seen&#39;)">`,
			`<td>Bob</td><td>viewer</td>`,
			`</tr>`,
			`</tbody></table>`,
		},
		context.temp_allocator,
	)
	testing.expect_value(t, strings.to_string(b), expected)
}

@(test)
test_full_document :: proc(t: ^testing.T) {
	out := rendered(t, proc() {
		h.doctype()
		{h.html(a.lang("en"))
			{h.head()
				{h.meta(a.charset("utf-8"))}
				{h.title()
					h.text("Users & Groups")
				}
			}
			{h.body(a.class("app"))
				{h.main_(a.id("rows"))}
			}
		}
	})
	testing.expect_value(
		t,
		out,
		`<!DOCTYPE html><html lang="en"><head><meta charset="utf-8">` +
		`<title>Users &amp; Groups</title></head>` +
		`<body class="app"><main id="rows"></main></body></html>`,
	)
}

// -------------------------------------------------------------- components

/* Components hand an element to the caller's block instead of closing it
themselves, so what these pin down is which scope each closing tag lands in.
See html/h/component.odin for the mechanism. */

@(private = "file")
rendered_err :: proc(body: proc()) -> (string, h.Error) {
	return h.render_to_string(body, context.temp_allocator)
}

@(private = "file")
@(deferred_none = h.close_all)
card :: proc() {
	{h.open_scope()
		{h.div_open(a.class("card"))
		}
	}
}

@(private = "file")
@(deferred_none = h.close_all)
card_header :: proc() {
	{h.open_scope()
		{h.div_open(a.class("card-header"))
		}
	}
}

@(test)
test_component_takes_children :: proc(t: ^testing.T) {
	out := rendered(t, proc() {
		{card()
			{h.p()
				h.text("hi")
			}
		}
	})
	testing.expect_value(t, out, `<div class="card"><p>hi</p></div>`)
}

/* The case a single shared stack with no marks would get wrong: the inner
component must close back to its own mark and leave the outer one alone. If it
drained everything, the card's </div> would land at the header's block end and
"body" would fall outside the card. */
@(test)
test_component_nested_in_component :: proc(t: ^testing.T) {
	out := rendered(t, proc() {
		{card()
			{card_header()
				h.text("Title")
			}
			h.text("body")
		}
	})
	testing.expect_value(t, out, `<div class="card"><div class="card-header">Title</div>body</div>`)
}

@(test)
test_component_siblings :: proc(t: ^testing.T) {
	out := rendered(t, proc() {
		{card()
			h.text("a")
		}
		{card()
			h.text("b")
		}
	})
	testing.expect_value(t, out, `<div class="card">a</div><div class="card">b</div>`)
}

/* A component closing its own tbody but handing over the table: the caller's
tfoot is a sibling of tbody, inside the table. */
@(private = "file")
@(deferred_none = h.close_all)
table_shell :: proc() {
	{h.open_scope()
		{h.table_open(a.class("w-full"))
			{h.tbody()
				{h.tr()
					{h.td()
						h.text("Ada")
					}
				}
			}
		}
	}
}

@(test)
test_component_trailing_slot :: proc(t: ^testing.T) {
	out := rendered(t, proc() {
		{table_shell()
			{h.tfoot()
				{h.tr()
					{h.td()
						h.text("1 user")
					}
				}
			}
		}
	})
	testing.expect_value(
		t,
		out,
		`<table class="w-full"><tbody><tr><td>Ada</td></tr></tbody>` +
		`<tfoot><tr><td>1 user</td></tr></tfoot></table>`,
	)
}

/* Two tags handed over at once. close_all unwinds them innermost first, so
the caller's rows land inside the tbody rather than beside it. */
@(private = "file")
@(deferred_none = h.close_all)
user_rows :: proc() {
	{h.open_scope()
		{h.table_open(a.class("w-full"))
			{h.tbody_open(hx.inherited(hx.target("#rows")))
			}
		}
	}
}

@(test)
test_component_two_tags :: proc(t: ^testing.T) {
	out := rendered(t, proc() {
		{user_rows()
			{h.tr()
				{h.td()
					h.text("Ada")
				}
			}
		}
	})
	testing.expect_value(
		t,
		out,
		`<table class="w-full"><tbody hx-target:inherited="#rows">` + `<tr><td>Ada</td></tr></tbody></table>`,
	)
}

/* A wrapper applied conditionally -- inexpressible for a plain element, since
its open and close would sit in different scopes, but fine at a component
boundary: the mark is pushed either way and the drain closes one tag or none. */
@(private = "file")
@(deferred_none = h.close_all)
maybe_card :: proc(wrap: bool) {
	{h.open_scope()
		if wrap {
			{h.div_open(a.class("card"))
			}
		}
	}
}

@(test)
test_component_conditional_wrapper :: proc(t: ^testing.T) {
	wrapped := rendered(t, proc() {
		{maybe_card(true)
			h.text("x")
		}
	})
	testing.expect_value(t, wrapped, `<div class="card">x</div>`)

	bare := rendered(t, proc() {
		{maybe_card(false)
			h.text("x")
		}
	})
	testing.expect_value(t, bare, "x")
}

/* An _open outside any component has nothing that can close it, and recording
it would hand it to whichever close_all ran next. Refused where the mistake is,
before the tag is written. */
@(test)
test_open_without_scope_fails :: proc(t: ^testing.T) {
	out, err := rendered_err(proc() {
		{h.div_open(a.class("x"))
		}
	})
	testing.expect_value(t, err, io.Error.Invalid_Write)
	testing.expect_value(t, out, "")
}

/* The other half of the pair missing: open_scope() with no
@(deferred_none = h.close_all) on the proc. Nothing closes the div, so the
render is reported as failed rather than returning truncated markup. */
@(private = "file")
leaky :: proc() {
	{h.open_scope()
		{h.div_open(a.class("x"))
		}
	}
}

@(test)
test_unclosed_component_fails_render :: proc(t: ^testing.T) {
	_, err := rendered_err(proc() {
		{leaky()
			h.text("x")
		}
	})
	testing.expect_value(t, err, io.Error.Invalid_Write)
}

/* close_all with no mark of its own would pop into the enclosing component's
region and close its tags early, so it fails instead. */
@(test)
test_close_all_without_scope_fails :: proc(t: ^testing.T) {
	_, err := rendered_err(proc() {
		h.close_all()
	})
	testing.expect_value(t, err, io.Error.Invalid_Write)
}

// ---------------------------------------------------------------- failure
/*
Giving up on a page from inside it. Separate from the error path above because
it is a different event with the same plumbing: those are a render going wrong,
these are a render deciding there is nothing to write. See h/failure.odin.
*/

@(private = "file")
gone :: proc() {
	h.fail(.Not_Found)
}

/* The whole mechanism in one expectation: a component fails, the writes after
it are dropped, and the entry point reports which failure it was. What the
caller does with that is the HTTP layer's business. */
@(test)
test_failure_is_reported_and_stops_output :: proc(t: ^testing.T) {
	out, err := rendered_err(proc() {
		{h.div()
			gone()
			h.text("never written")
		}
	})
	testing.expect_value(t, err, h.Failure.Not_Found)
	testing.expect_value(t, out, "<div>")
}

/* No caller between the failure and the entry point knows it can happen, and
none of them passes it on -- that is the property the sticky flag buys over a
returned error, and the reason a component keeps its bare proc() signature. */
@(private = "file")
outer :: proc() {
	{h.section()
		middle()
	}
}

@(private = "file")
middle :: proc() {
	{h.article()
		gone()
	}
}

@(test)
test_failure_needs_no_intermediate_caller :: proc(t: ^testing.T) {
	_, err := rendered_err(outer)
	testing.expect_value(t, err, h.Failure.Not_Found)
}

/* First failure wins, like the write error beside it: the reported cause is the
earliest rather than the innermost, and a component failing inside one that has
already failed cannot rewrite the answer. */
@(test)
test_first_failure_wins :: proc(t: ^testing.T) {
	_, err := rendered_err(proc() {
		h.fail(.Not_Permitted)
		h.fail(.Not_Found)
	})
	testing.expect_value(t, err, h.Failure.Not_Permitted)
}

/* .None is not a failure and must not become one, or a caller forwarding a
zero value would abandon a page that was fine. */
@(test)
test_failing_with_none_is_not_a_failure :: proc(t: ^testing.T) {
	out, err := rendered_err(proc() {
		h.fail(.None)
		{ h.p(); h.text("still here") }
	})
	testing.expect_value(t, err, nil)
	testing.expect_value(t, out, "<p>still here</p>")
}

/* For the caller that would otherwise do real work for a page nobody will see.
Skipping is an optimisation only -- the writes it skips are already dropped. */
@(test)
test_failed_reports_the_state :: proc(t: ^testing.T) {
	seen: [2]bool
	@(static) probe: ^[2]bool
	probe = &seen

	_, _ = rendered_err(proc() {
		probe[0] = h.failed()
		h.fail(.Invalid)
		probe[1] = h.failed()
	})

	testing.expect_value(t, seen[0], false)
	testing.expect_value(t, seen[1], true)
}
