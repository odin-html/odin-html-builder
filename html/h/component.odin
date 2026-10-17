/* Components that hand an element to their caller's block.

An element written the ordinary way closes when the Odin scope containing the
call ends, which is what makes {h.div()} an element rather than a pair of
calls. A component that takes children needs the opposite: it opens a wrapper,
and the *caller's* block supplies what goes inside, so the closing tag has to
be written after the component proc has already returned.

The _open variants in elements.odin do that half. They write an opening tag and
record it instead of deferring a close of their own:

    @(deferred_none = h.close_all)
    card :: proc(props := Props{}) {
        {h.open_scope()
            {h.div_open(a.class("card", props.class))
                // the caller's children land here
            }
        }
    }

    {card()                        ->  <div class="card"><p>hi</p></div>
        {h.p(); h.text("hi")}
    }

open_scope() and @(deferred_none = h.close_all) are one unit. The first pushes
a mark; the second closes every tag recorded above that mark, innermost first,
and pops it. The mark is what keeps nesting straight: a component invoked
inside another component's block closes back to its own mark and leaves the
outer one untouched. Half a pair is silent -- a close_all with no mark of its
own would pop into its parent's region and close the parent's tags early -- so
the two are worth counting per file in review or in a lint.

open_scope() defers nothing. Its block is written for the same reason {h.br()}
is: so that a brace always marks an element's extent. What pops the mark is
close_all, not the brace.

Two things follow from the close landing in the caller's scope:

- Braces at the call site are not optional for these components. A bare
  card() defers its close to the end of the caller's *enclosing* scope, so
  everything written afterwards ends up inside the card.
- A component must close everything it opens except what it hands over. An
  element left open inside the component body closes at the end of that body,
  which is still before the children -- so the markup stays well formed, but
  the children become siblings of it rather than its content.

This is not the tag stack h.odin does without. Ordinary elements never touch
`pending`; only a component does, and only between its open_scope and the end
of its caller's block, so the depth here is the component nesting depth rather
than the depth of the document. A missing or mismatched close is still not
expressible for elements. What a component can get wrong is which scope its
close lands in, and that is what the pairing rule and the checks below are
for. */
package h

/* A mark is an empty tag name. That reuses the convention the rest of the
package already has -- a.attr_if returns a zero Attr and write_attrs skips it
-- and it means an element can never be confused for a mark, because a tag with
no name cannot be written in the first place. */
@(private)
MARK :: ""

/* Bounded by how deeply components nest, not by how large the document is:
every entry is popped at the end of the block that pushed it. 128 is far past
any real tree, and overflowing it is a template bug rather than a load
condition, so it fails the render instead of growing. */
@(private)
PENDING_MAX :: 128

@(private)
Pending :: struct {
	tags:  [PENDING_MAX]string,
	n:     int,
	marks: int, // counted rather than searched for, so _open stays O(1)
}

/* Opens a component's scope. Pairs with @(deferred_none = close_all) on the
same proc -- see the file comment; neither half is meaningful alone. */
open_scope :: proc() {
	push(MARK)
	st().pending.marks += 1
}

/* Closes back to the innermost mark. Written as the deferred half of a
component, so it runs at the end of the *caller's* block, after the children. */
close_all :: proc() {
	state := st()
	if state.pending.marks == 0 {
		// A component with the attribute but no open_scope(). Popping anyway
		// would close tags belonging to the enclosing component.
		malformed(state)
		return
	}
	for state.pending.n > 0 {
		state.pending.n -= 1
		name := state.pending.tags[state.pending.n]
		if name == MARK {
			state.pending.marks -= 1
			return
		}
		close(name)
	}
	// marks said there was one and the stack disagrees, which only happens
	// after an overflow already failed the render.
	malformed(state)
}

/* Elements the generated list does not have, for the same use as h.elem:

       {h.open_scope()
           {h.elem_open("my-widget", a.attr("value", "7"))
           }
       }

The name is read a second time when close_all runs, which is now in the
caller's scope rather than this one -- a name built at runtime has to outlive
that, not merely this block. */
elem_open :: proc(name: string, attrs: ..Attr) {
	open_pending(name, attrs)
}

/* Writes an opening tag whose close belongs to the caller's block. Recording
one under no mark at all would hand it to whichever close_all ran next, which
is the single failure this design cannot detect after the fact -- so it is
refused here, where the mistake is. */
@(private)
open_pending :: proc(name: string, attrs: []Attr) {
	state := st()
	if state.pending.marks == 0 {
		malformed(state)
		return
	}
	write_open_tag(name, attrs)
	push(name)
}

@(private)
push :: proc(name: string) {
	state := st()
	if state.pending.n >= PENDING_MAX {
		malformed(state)
		return
	}
	state.pending.tags[state.pending.n] = name
	state.pending.n += 1
}

/* Structural misuse: a component missing half of its pair, or a tag opened
where nothing can close it. There is no io.Error meaning "the template is
wrong", and .Invalid_Write is the nearest -- the writer was asked for output
that cannot be produced. Sticky like any other error, so the render fails
rather than returning markup that is quietly misnested. */
@(private)
malformed :: proc(state: ^State) {
	if state.err == nil {
		state.err = .Invalid_Write
	}
}
