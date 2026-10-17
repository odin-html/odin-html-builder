# odin-html-builder

[![CI](https://github.com/odin-html/odin-html-builder/actions/workflows/ci.yml/badge.svg)](https://github.com/odin-html/odin-html-builder/actions/workflows/ci.yml)

An HTML builder for Odin, with no dependencies outside `core:`. Elements are
Odin scopes: an element's closing tag is written when the block that opened it
ends, so the shape of the code is the shape of the markup and a missing or
mismatched close cannot be written. Text and attribute values are escaped by
default, a render goes to any `io.Writer`, and the builder knows nothing about
HTTP — whatever serves the response owns that.

This is deliberately a low-level library. The component library built on it,
odin-html-ui, lives in its own repository.

## Packages

| Package     | Description                                                                                       |
| ----------- | ------------------------------------------------------------------------------------------------- |
| `html/h`    | Elements and rendering: one proc per HTML and SVG element, `_open` variants for components, `text` / `raw` / `doctype` / `comment`, `render` / `render_with` / `render_to_string`, and the failure model |
| `html/a`    | Attributes: `Attr` and `Value`, one constructor per attribute, `attr_if` / `class` / `data` / `aria` / `join`, the escapers, and `name_is_safe` |
| `html/hx`   | htmx 4.0 attribute helpers, `on` / `on_htmx` for event handlers, and the `inherited` / `merge` modifiers |

The doc comments in each package carry the full contracts; start with
`html/h/h.odin` (elements and rendering), `html/h/component.odin` (components
that take children) and `html/h/failure.odin` (giving up on a page from inside
it).

## Example

```odin
import "html:html/a"
import "html:html/h"
import "html:html/hx"

User :: struct {
	id:         string,
	name:       string,
	role:       string,
	suspended:  bool,
	detail_url: string,
}

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

// err := h.render_with(w, user_table, users)   // w: any io.Writer
```

Every block closes the element its first line opens. An empty class part is
dropped, a false `attr_if` omits its attribute, and text and values are
escaped, so for an admin named `Ada <admin>` the first row is

```html
<tr class="row row-admin" data-user-id="u1" hx-get="/users/u1" hx-on:click="this.classList.add(&#39;seen&#39;)"><td>Ada &lt;admin&gt;</td><td>admin</td></tr>
```

The example is compiled and its output asserted by `test_documented_example`
in `html/html_test.odin`.

A component that takes children opens its wrapper with an `_open` variant and
closes it at the end of its *caller's* block:

```odin
@(deferred_none = h.close_all)
card :: proc() {
	{h.open_scope()
		{h.div_open(a.class("card"))
		}
	}
}

{card()                       // <div class="card"><p>hi</p></div>
	{h.p(); h.text("hi")}
}
```

`h.open_scope()` and `@(deferred_none = h.close_all)` are one unit; see
`html/h/component.odin` for why, and for the two rules that follow from it.

A render reports one `h.Error`: the writer's own `io.Error`, or the `h.Failure`
a component raised with `h.fail(.Not_Found)` to abandon the page. Either is
sticky — the first wins and every write after it is dropped — so it is
checked once, when the render returns.

## Using it as a collection

The collection is this repository's root. Check it out beside your project and
declare it:

```sh
odin build . -collection:html=../odin-html-builder
```

and import the packages as `html:html/a`, `html:html/h` and `html:html/hx`.
Declare the same collection in your `ols.json` so the language server resolves
what the compiler does.

Attribute constructors that allocate use `context.temp_allocator`, on the
assumption that a render is bounded by an arena the caller frees per request.

## Testing

```sh
make test    # the suite, with leaks and bad frees as failures
make check   # vet every package with -vet -strict-style
```

or, without make:

```sh
odin test html -collection:html=. -define:ODIN_TEST_FAIL_ON_BAD_MEMORY=true
odin check html/h -no-entry-point -vet -strict-style -collection:html=.
```

## License

MIT — see [LICENSE](LICENSE).
