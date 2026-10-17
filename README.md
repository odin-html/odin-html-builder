# odin-html-builder

[![CI](https://github.com/odin-html/odin-html-builder/actions/workflows/ci.yml/badge.svg)](https://github.com/odin-html/odin-html-builder/actions/workflows/ci.yml)

An HTML builder for Odin, with no dependencies outside `core:`.

The one idea: **an element is an Odin scope.** Its closing tag is written when
the block that opened it ends, so the shape of the code is the shape of the
markup, and a missing or mismatched close cannot be written. Text and
attribute values are escaped by default. A render goes to any `io.Writer`, and
the builder knows nothing about HTTP — whatever serves the response owns that.

Part of [odin-html](https://github.com/odin-html); the component library
[odin-html-ui](https://github.com/odin-html/odin-html-ui) is built on it.

## Packages

- **`html/h`** — elements (one proc per HTML and SVG element), `text`, `raw`,
  `doctype`, components that take children, and `render` / `render_with` /
  `render_to_string`.
- **`html/a`** — attributes: one constructor per attribute, plus `class`,
  `data`, `aria`, `attr_if` and `join`, and the escapers.
- **`html/hx`** — htmx 4 attribute helpers (`hx.get`, `hx.target`, `hx.on`, …).

The doc comments carry the full contracts; start with `html/h/h.odin` and
`html/h/component.odin`.

## A page

```odin
import "core:os"

import "html:html/a"
import "html:html/h"
import "html:html/hx"

Item :: struct {
	name: string,
	done: bool,
}

todo_page :: proc(items: []Item) {
	h.doctype()
	{h.html(a.lang("en"))
		{h.head()
			{h.meta(a.charset("utf-8"))}
			{h.title(); h.text("Todo")}
		}
		{h.body()
			{h.ul(a.id("todo"))
				for item in items {
					{h.li(a.class("item", item.done ? "done" : ""))
						h.text(item.name)
					}
				}
			}
			{h.button(hx.post("/clear"), hx.target("#todo"))
				h.text("Clear done")
			}
		}
	}
}

items := []Item{{"Write <docs>", true}, {"Ship it", false}}
err := h.render_with(os.to_stream(os.stdout), todo_page, items)
```

writes

```html
<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>Todo</title></head><body><ul id="todo"><li class="item done">Write &lt;docs&gt;</li><li class="item">Ship it</li></ul><button hx-post="/clear" hx-target="#todo">Clear done</button></body></html>
```

Every block closes the element its first line opens; void elements get a block
too, `{h.meta(…)}`, so a brace always marks an element's extent. An empty class
part is dropped, and the text is escaped.

## A component that takes children

A component opens its wrapper with an `_open` variant inside `h.open_scope()`
and carries `@(deferred_none = h.close_all)`. The wrapper then closes at the end
of the *caller's* block, around whatever the caller wrote inside it:

```odin
@(deferred_none = h.close_all)
card :: proc(title: string) {
	{h.open_scope()
		{h.section_open(a.class("card"))
			{h.h2(); h.text(title)}
		}
	}
}

profile :: proc() {
	{card("Ada")
		{h.p(); h.text("Wrote the first program.")}
	}
}
```

`h.render(w, profile)` writes

```html
<section class="card"><h2>Ada</h2><p>Wrote the first program.</p></section>
```

**The braces around `card(…)` are not optional.** Without them the card closes
at the end of the enclosing scope, and everything written after it lands
inside. `open_scope` and `close_all` are one unit; `html/h/component.odin`
says why.

A render returns one `h.Error`: the writer's own `io.Error`, or the
`h.Failure` a component raised with `h.fail(.Not_Found)` to abandon the page.
The first error wins and later writes are dropped, so it is checked once, when
the render returns.

## Using it as a collection

The collection is this repository's root. Check it out beside your project and
declare it:

```sh
odin build . -collection:html=../odin-html-builder
```

Import the packages as `html:html/h`, `html:html/a` and `html:html/hx`, and
declare the same collection in `ols.json`. Attribute constructors that allocate
use `context.temp_allocator`, on the assumption that a render is bounded by an
arena the caller frees per request.

## Testing

```sh
make test    # the suite, with leaks and bad frees as failures
make check   # vet every package with -vet -strict-style
```

## License

MIT — see [LICENSE](LICENSE).
