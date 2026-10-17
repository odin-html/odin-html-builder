/* Giving up on a page from inside it.

A component that discovers there is no page to render -- the record is gone, the
caller may not see it, the input does not parse -- has no way to say so through
its return value, because a component returns nothing and giving every one of
them a return would mean giving it to the many that can never fail. And a
component five levels down cannot reach the handler that would send the status.

So it says so through the render instead:

    item_show :: proc(view: Item) {
        if !view.found {h.fail(.Not_Found);return}

        {h.h1();h.text(view.name)}
    }

fail is sticky, exactly like the write error it sits beside, and everything
after it writes nothing. Which is the property worth having: no intermediate
caller has to know that a component it calls can fail, and none of them can
forget to pass it on. The call site is `item_show(view)` and stays that way.

The `return` is an optimisation, not a correctness requirement -- the writes
below it are already no-ops. Write one where the code after would dereference
the thing just reported missing, or would do real work for a page nobody will
see; leave it out where the rest is just markup.

What this is not: a component drawing a fallback in its own box. A node whose
props will not decode does not fail the page -- the other nodes are fine and the
answer is a note where its contents would go. That failure is a return value,
local to whatever composes those nodes, and that composer has its own error for
it.
The test is whether a response still exists afterwards. If it does, do not
touch this file.

The two halves of Error stay separate because they mean different things to
whoever is listening. An io.Error is the writer failing underneath a render that
was going fine, and is nobody's fault but the socket's; a Failure is the render
deciding there is nothing to write. The caller that owns the response turns the
second into a status and the first into a 500.

#shared_nil so that a nil io.Error is a nil Error rather than a union carrying
one -- the usual Odin trap of a union holding a nil member being itself
non-nil. Without it every render would report failure. */
package h

import "core:io"

/* Deliberately not http.Status. This package writes to an io.Writer and has
never known what a request is; the mapping to a status code lives with the
caller's HTTP layer, which does. Four outcomes rather than a code per case, because
the point of the enum is that a component picks the *kind* of nothing it has,
and the transport decides how to say it. */
Failure :: enum {
	None = 0,
	Not_Found,
	Not_Permitted,
	Invalid,
	Internal,
}

Error :: union #shared_nil {
	io.Error,
	Failure,
}

/* Abandons the response. First failure wins, like the write error: a component
that fails inside a component that already failed does not overwrite what the
first one said, which keeps the reported cause the earliest one rather than the
innermost. */
fail :: proc(f: Failure) {
	if f == .None {
		return
	}

	state := st()
	if state.err == nil {
		state.err = f
	}
}

/* Whether the render has been abandoned, for the caller that would otherwise do
real work for a page nobody will see -- a loop over every node in a graph, a
query per row. Skipping is an optimisation and never changes the output, since
every write after a failure is already dropped. */
failed :: proc() -> bool {
	return st().err != nil
}
