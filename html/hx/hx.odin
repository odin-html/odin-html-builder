// htmx 4.0 attribute helpers. Separate package so hx.target and attr.title
// do not collide, and so the call site reads hx.* vs a.* at a glance.
package hx

import "core:strings"
import "html:html/a"

Attr :: a.Attr
Value :: a.Value

// htmx spells booleans as the literal strings "true"/"false" -- there are no
// bare boolean htmx attributes. Passing a bool straight into Value would
// emit a bare `hx-boost` with no value, which htmx ignores. So:
//
//   hx.boost(tf(enabled))     -> hx-boost="true"
//   hx.preserve("true")       -> hx-preserve="true"
//
// hx-boost also accepts a config string ("swap:outerSync target:#main"),
// which is why the generated procs take Value rather than bool.
tf :: proc(b: bool) -> string {
	return b ? "true" : "false"
}

// ---------------------------------------------------------------------------
// hx-on
//
// The event name is part of the attribute name, so this cannot be generated.
//
// Gotcha worth remembering: the DOM lowercases attribute names, so
// hx-on:htmx:beforeRequest silently never fires. Use the colon-separated
// spelling, hx-on:htmx:before:request.
// ---------------------------------------------------------------------------

on :: proc(event, script: string) -> Attr {
	return {strings.concatenate({"hx-on:", event}, context.temp_allocator), script}
}

// The hx-on:: shorthand, which drops the "htmx" segment:
//   on_htmx("before:request", "...")  ->  hx-on::before:request="..."
on_htmx :: proc(event, script: string) -> Attr {
	return {strings.concatenate({"hx-on::", event}, context.temp_allocator), script}
}

// ---------------------------------------------------------------------------
// Modifiers
//
// Change this if you set htmx.config.metaCharacter.
// ---------------------------------------------------------------------------

META :: ":"

mod :: proc(a: Attr, m: string) -> Attr {
	return {strings.concatenate({a.name, META, m}, context.temp_allocator), a.value}
}

// Inheritance is opt-in as of 4.0, so this is on every layout wrapper rather
// than being a corner case:
//   hx.inherited(hx.target("#out"))  ->  hx-target:inherited="#out"
inherited :: proc(a: Attr) -> Attr {
	return mod(a, "inherited")
}

// Keeps inherited selectors and adds to them, e.g. hx-disable:merge.
merge :: proc(a: Attr) -> Attr {
	return mod(a, "merge")
}
