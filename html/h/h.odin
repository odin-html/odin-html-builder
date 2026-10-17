// Element rendering. The output sink lives in context.user_ptr, so nested
// components are plain proc() with no writer threaded through them -- which
// is what makes the whole design work without closures.
package h

import "core:fmt"
import "core:io"
import "core:strings"
import "html:html/a"

// Re-exported so the generated element file needs no import. That matters:
// if that file imported package a, the name would collide with the <a>
// element proc.
Attr :: a.Attr
Value :: a.Value

/* err carries both ways a render ends badly: the writer failing underneath one
that was going fine, and a component deciding there is no page at all -- see
failure.odin. Sticky either way, so the first is what gets reported and
everything after it is dropped; checked once at the end. */
State :: struct {
	w:       io.Writer,
	err:     Error,
	pending: Pending, // tags a component handed to its caller -- component.odin
}

@(private)
st :: proc() -> ^State {
	return cast(^State)context.user_ptr
}

@(private)
ws :: proc(s: string) {
	state := st()
	if state.err != nil {
		return
	}
	_, err := io.write_string(state.w, s)
	if err != nil {
		state.err = err
	}
}

// ---------------------------------------------------------------------------
// Tags
//
// Every non-void element carries @(deferred_out = close), which Odin runs when
// the *caller's* scope ends rather than when the element proc returns. So the
// block is the element, and there is nothing to close by hand:
//
//   {h.div(a.class("card"))
//       h.text("hi")
//   }                        ->  <div class="card">hi</div>
//
//   {h.td(); h.text(name)}   ->  <td>Ada</td>, on one line
//
// Any scope Odin closes will do -- an if branch, a loop body, or a proc body,
// which is why a component needs no block of its own:
//
//   card :: proc() {
//       h.div(a.class("card"))
//       h.text("hi")
//   }                        ->  </div> lands at the end of card()
//
// Void elements close nothing, but get a block too -- {h.br()}, {h.meta()} --
// so that a brace always marks an element's extent the way <> does in XHTML
// rather than sometimes marking one and sometimes not. The block around a call
// that defers nothing is free: it compiles to the same instructions.
//
// What this cannot express is an open and a close in different scopes, i.e. a
// wrapper element applied conditionally. Branch around the whole subtree and
// put the shared part in a proc() both arms call.
//
// One formatting wrinkle: an element block directly under a closing `}` of an
// if is rejected by -strict-style, which reads the `{` as a brace that should
// have been attached to an else. A blank line or a comment between the two is
// enough. Loops and blocks do not have this problem.
// ---------------------------------------------------------------------------

@(private)
write_open_tag :: proc(name: string, attrs: []Attr) {
	state := st()
	ws("<")
	ws(name)
	if state.err == nil {
		if err := a.write_attrs(state.w, attrs); err != nil {
			state.err = err
		}
	}
	ws(">")
}

// Returns the tag name only so that deferred_out can hand it straight back to
// close(). That round trip is what replaced the tag stack: the pairing is the
// caller's scope, so a mismatched or missing close is not expressible.
@(private)
open :: proc(name: string, attrs: []Attr) -> string {
	write_open_tag(name, attrs)
	return name
}

@(private)
close :: proc(name: string) {
	ws("</")
	ws(name)
	ws(">")
}

// Elements the generator does not know about. Closes like any other:
//
//   {h.elem("my-widget", a.attr("value", "7"))
//       h.text("x")
//   }
//
// The generated elements pass a literal, but a name built at runtime has to
// outlive the block, because that is where it is read a second time: do not
// free the allocation it came from before the block ends.
@(deferred_out = close)
elem :: proc(name: string, attrs: ..Attr) -> string {
	return open(name, attrs)
}

// A void element is an open tag and nothing else, so nothing closes it -- but
// write it in a block anyway, per the convention above.
void_el :: proc(name: string, attrs: ..Attr) {
	write_open_tag(name, attrs)
}

// ---------------------------------------------------------------------------
// Content
// ---------------------------------------------------------------------------

text :: proc(s: string) {
	state := st()
	if state.err != nil {
		return
	}
	if err := a.escape_text(state.w, s); err != nil {
		state.err = err
	}
}

textf :: proc(format: string, args: ..any) {
	text(fmt.tprintf(format, ..args))
}

// Unescaped. Required inside <script> and <style>, which are raw-text
// elements where escaping would corrupt the payload -- and consequently the
// one place where interpolating user data is an injection, not an escape bug.
raw :: proc(s: string) {
	ws(s)
}

doctype :: proc() {
	ws("<!DOCTYPE html>")
}

comment :: proc(s: string) {
	ws("<!--")
	cleaned, _ := strings.replace_all(s, "--", "- -", context.temp_allocator)
	ws(cleaned)
	ws("-->")
}

// ---------------------------------------------------------------------------
// Entry points
//
// These install the State in context.user_ptr. Odin passes context down
// implicitly, so every proc reachable from `body` sees the same sink.
// ---------------------------------------------------------------------------

render :: proc(w: io.Writer, body: proc()) -> Error {
	state := State {
		w = w,
	}
	context.user_ptr = &state
	body()
	return finish(&state)
}

/* A component whose close_all never ran leaves its tags in `pending`. The
markup is already on the wire and cannot be taken back, so the one useful thing
left is to refuse to report it as complete. */
@(private)
finish :: proc(state: ^State) -> Error {
	if state.pending.n != 0 {
		malformed(state)
	}
	return state.err
}

// Closures do not exist, so the way to give a component its data is an
// explicit parameter.
render_with :: proc(w: io.Writer, body: proc(data: $T), data: T) -> Error {
	state := State {
		w = w,
	}
	context.user_ptr = &state
	body(data)
	return finish(&state)
}

render_to_string :: proc(body: proc(), allocator := context.allocator) -> (string, Error) {
	b := strings.builder_make(allocator)
	err := render(strings.to_writer(&b), body)
	return strings.to_string(b), err
}
