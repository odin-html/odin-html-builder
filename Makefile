# Odin source collection. The collection is this repository's root, as in the
# odin-rdf family: packages are imported as `html:html/a`, `html:html/h` and
# `html:html/hx`, by this repository's own sources and by a consumer that
# declares -collection:html=<path to odin-html-builder>. ols.json declares the
# same collection so the language server resolves what the compiler does.
COLL := -collection:html=.

# Every package. `html` holds the suite (html/html_test.odin), which drives the
# three packages through their public API and so imports all of them; the
# other three are named anyway, so that `check` vets each package on its own
# rather than only through what the suite happens to reach.
PKGS := html html/a html/h html/hx

.PHONY: all help test check clean

all: test

# The description of a target is the `##` on its own recipe line, which is what
# help greps for. A target with no `##` is internal and stays out of it.
help: ## Show available targets
	@awk 'BEGIN {FS = ":.*## "}; /^[a-zA-Z0-9_.-]+:.*## / {printf "%-16s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# The test runner tracks allocations per test but only warns about leaks and bad
# frees by default, which a passing build hides. Promote them to failures.
TEST_FLAGS := -define:ODIN_TEST_FAIL_ON_BAD_MEMORY=true $(COLL)

test: ## Run the test suite
	odin test html $(TEST_FLAGS)

check: ## Vet every package with -vet -strict-style
	@for pkg in $(PKGS); do \
		echo "-- $$pkg --"; \
		odin check $$pkg -no-entry-point -vet -strict-style $(COLL) || exit 1; \
	done

clean: ## Remove build/
	rm -rf build
