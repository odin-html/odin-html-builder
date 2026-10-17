// Attribute values and rendering. Knows nothing about elements, so the
// dependency runs one way: h -> a, hx -> a.
package a

import "core:io"
import "core:slice"
import "core:strconv"
import "core:strings"

// nil      omits the attribute entirely
// string   escaped, rendered as name="value"
// int      rendered as name="42"
// bool     HTML bare boolean: true -> `disabled`, false -> omitted.
//          NOTE: htmx does NOT use bare booleans -- see package hx.
// []string joined with spaces, empty parts dropped (class lists)
Value :: union {
	string,
	int,
	bool,
	[]string,
}

Attr :: struct {
	name:  string,
	value: Value,
}

// ---------------------------------------------------------------------------
// Constructors
//
// Anything returning heap memory uses context.temp_allocator, on the
// assumption that a render is bounded by an arena you free per request.
// ---------------------------------------------------------------------------

attr :: proc(name: string, v: Value) -> Attr {
	return {name, v}
}

// A zero Attr has an empty name and is skipped by write_attrs.
attr_if :: proc(cond: bool, a: Attr) -> Attr {
	return cond ? a : Attr{}
}

// class("row", admin ? "row-admin" : "") -- empty parts are dropped, so
// conditionals need no branch at the call site.
//
// The clone is NOT optional: a variadic parameter's backing array dies with
// the call, so returning `parts` directly would hand back a dangling slice.
class :: proc(parts: ..string) -> Attr {
	return {"class", slice.clone(parts, context.temp_allocator)}
}

data :: proc(key: string, v: Value) -> Attr {
	return {strings.concatenate({"data-", key}, context.temp_allocator), v}
}

// For ARIA attributes the generator does not cover. Pass "true"/"false"
// rather than a bool: ARIA has no bare booleans, and a bool would take the
// bare-boolean path below and render a valueless -- and therefore invalid --
// aria-disabled. The generated aria_disabled() and friends already do this.
aria :: proc(key: string, v: Value) -> Attr {
	return {strings.concatenate({"aria-", key}, context.temp_allocator), v}
}

// Merge attribute groups for a single `..` spread:
//   h.th(..a.join(sortable("name", .Asc), {a.class("wide")}))
join :: proc(groups: ..[]Attr) -> []Attr {
	n := 0
	for g in groups {
		n += len(g)
	}
	out := make([]Attr, n, context.temp_allocator)
	i := 0
	for g in groups {
		copy(out[i:], g)
		i += len(g)
	}
	return out
}

// ---------------------------------------------------------------------------
// Escaping
// ---------------------------------------------------------------------------

@(private)
ws :: proc(w: io.Writer, s: string) -> io.Error {
	_, err := io.write_string(w, s)
	return err
}

// Element content. Does NOT make content safe for <script> or <style>:
// those are raw-text elements and escaping there corrupts the payload.
escape_text :: proc(w: io.Writer, s: string) -> io.Error {
	start := 0
	for i in 0 ..< len(s) {
		repl: string
		switch s[i] {
		case '&':
			repl = "&amp;"
		case '<':
			repl = "&lt;"
		case '>':
			repl = "&gt;"
		case:
			continue
		}
		ws(w, s[start:i]) or_return
		ws(w, repl) or_return
		start = i + 1
	}
	return ws(w, s[start:])
}

// Attribute values. Quotes must go, or a value can break out of the
// attribute and inject new ones.
escape_attr :: proc(w: io.Writer, s: string) -> io.Error {
	start := 0
	for i in 0 ..< len(s) {
		repl: string
		switch s[i] {
		case '&':
			repl = "&amp;"
		case '<':
			repl = "&lt;"
		case '"':
			repl = "&quot;"
		case '\'':
			repl = "&#39;"
		case:
			continue
		}
		ws(w, s[start:i]) or_return
		ws(w, repl) or_return
		start = i + 1
	}
	return ws(w, s[start:])
}

// ---------------------------------------------------------------------------
// Rendering
// ---------------------------------------------------------------------------

// Later duplicates win, so a component can apply defaults and append caller
// attributes to override them. O(n^2) in the attribute count, which is fine
// for the handful an element carries.
write_attrs :: proc(w: io.Writer, attrs: []Attr) -> io.Error {
	for a, i in attrs {
		if a.name == "" || a.value == nil {
			continue
		}

		overridden := false
		for b in attrs[i + 1:] {
			if b.name == a.name {
				overridden = true
				break
			}
		}
		if overridden {
			continue
		}

		if b, is_bool := a.value.(bool); is_bool {
			if b {
				ws(w, " ") or_return
				ws(w, a.name) or_return
			}
			continue
		}

		ws(w, " ") or_return
		ws(w, a.name) or_return
		ws(w, `="`) or_return

		#partial switch v in a.value {
		case string:
			escape_attr(w, v) or_return
		case int:
			buf: [24]u8
			ws(w, strconv.write_int(buf[:], i64(v), 10)) or_return
		case []string:
			first := true
			for p in v {
				if p == "" {
					continue
				}
				if !first {
					ws(w, " ") or_return
				}
				escape_attr(w, p) or_return
				first = false
			}
		}

		ws(w, `"`) or_return
	}
	return nil
}

// Attribute names are a bigger attack surface than values: an escaped value
// behind an `onclick` name is still an XSS. Call this on any name derived
// from data rather than written as a literal.
name_is_safe :: proc(name: string) -> bool {
	if len(name) == 0 {
		return false
	}
	// Matched case-insensitively: the parser lowercases attribute names, so
	// OnClick is a live handler just like onclick.
	if len(name) >= 2 && (name[0] | 0x20) == 'o' && (name[1] | 0x20) == 'n' {
		return false
	}
	for i in 0 ..< len(name) {
		c := name[i]
		switch {
		case c >= 'a' && c <= 'z', c >= 'A' && c <= 'Z':
		case c >= '0' && c <= '9':
		case c == '-', c == '_', c == ':', c == '.':
		case:
			return false
		}
	}
	return true
}
