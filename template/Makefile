# Makefile for an nbdev3 + uv project

SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.NOTPARALLEL:
.DEFAULT_GOAL := help

UV      ?= uv
QUARTO  ?= quarto
UVRUN    = $(UV) run

NBS_DIR     ?= nbs
NBS_MD_DIR  ?= nbs_md
PROC_DIR    ?= _proc
RENDER_ONE  ?= 00_cli.ipynb
NB_TIMEOUT  ?= 600
CTX_CONFIG  ?= ctx.yaml
CTX_LOCAL   ?= ./.bin/ctx
CTX_INSTALL ?= ./scripts/install_ctx.sh

.PHONY: help \
  sync export nbs_md \
  nbdev_test pytest test test-fast test-nb \
  clean strip-outputs clean-nbs \
  proc exec-nbs proc-live \
  render render-live docs docs-refresh-live preview render-one render-core \
  clean-proc clean-docs clean-all \
  publish \
  ctx ctx-check ctx-install

help:
	@echo "Targets:"
	@echo ""
	@echo "  Environment:"
	@echo "    make sync              - Create/update .venv from pyproject.toml"
	@echo ""
	@echo "  Build / export:"
	@echo "    make export            - nbdev-export (generate package modules)"
	@echo "    make nbs_md            - export tracked notebooks as markdown into $(NBS_MD_DIR)/"
	@echo ""
	@echo "  Tests (two runners):"
	@echo "    make nbdev_test        - notebook-based tests via nbdev-test"
	@echo "    make pytest            - standard Python tests via pytest"
	@echo "    make test              - quality gate: nbdev_test then pytest"
	@echo "    make test-fast         - convenience: pytest only"
	@echo "    make test-nb           - convenience: nbdev_test only"
	@echo ""
	@echo "  Docs:"
	@echo "    make docs              - non-executing docs build (uses saved notebook outputs)"
	@echo "    make docs-refresh-live - execute notebooks then render docs"
	@echo "    make preview           - quarto preview from within $(PROC_DIR)"
	@echo "    make render-one        - render one page in $(PROC_DIR) (RENDER_ONE=$(RENDER_ONE))"
	@echo ""
	@echo "  Cleanup:"
	@echo "    make clean             - nbdev-clean"
	@echo "    make strip-outputs     - nbdev-clean --clear_all (DESTRUCTIVE)"
	@echo "    make clean-proc        - remove $(PROC_DIR)"
	@echo "    make clean-docs        - remove rendered docs output under $(PROC_DIR)"
	@echo "    make clean-all         - clean + clean-proc + clean-docs"
	@echo ""
	@echo "  Publish:"
	@echo "    make publish           - test + docs-refresh-live + nbs_md, then publish $(PROC_DIR)/_docs to gh-pages"
	@echo ""
	@echo "  CTX (optional):"
	@echo "    make ctx-check         - verify ctx is available locally or in PATH"
	@echo "    make ctx-install       - install ctx into ./.bin via scripts/install_ctx.sh"
	@echo "    make ctx               - run ctx notebook export and ctx build using $(CTX_CONFIG)"

sync:
	@echo "==> uv sync"
	$(UV) sync --group dev

export:
	@echo "==> nbdev-export"
	$(UVRUN) nbdev-export

nbs_md:
	@echo "==> export notebooks to $(NBS_MD_DIR)/"
	mkdir -p $(NBS_MD_DIR)
	rm -f $(NBS_MD_DIR)/*.md
	rm -rf $(NBS_MD_DIR)/*_files
	$(UVRUN) python -m jupyter nbconvert --to markdown --output-dir $(NBS_MD_DIR) $$(git ls-files '$(NBS_DIR)/*.ipynb')

nbdev_test:
	@echo "==> nbdev-test"
	$(UVRUN) nbdev-test --n_workers 0

pytest:
	@echo "==> pytest"
	$(UVRUN) pytest

test: nbdev_test pytest
	@echo "Done: nbdev_test + pytest"

test-fast: pytest
	@echo "Done: pytest (fast)"

test-nb: nbdev_test
	@echo "Done: nbdev_test (notebook suite)"

clean:
	@echo "==> nbdev-clean"
	$(UVRUN) nbdev-clean

strip-outputs:
	@echo "==> nbdev-clean --clear_all"
	$(UVRUN) nbdev-clean --clear_all

clean-nbs: strip-outputs
	@echo "Done: clean-nbs (alias for strip-outputs)"

# Preprocess notebooks for docs without executing them.
proc:
	@echo "==> nbdev-proc-nbs"
	$(UVRUN) nbdev-proc-nbs

# Execute notebooks to refresh saved outputs.
exec-nbs:
	@echo "==> execute notebooks inside $(NBS_DIR)"
	$(UVRUN) python -m jupyter nbconvert --to notebook --inplace --execute --ExecutePreprocessor.timeout=$(NB_TIMEOUT) $(NBS_DIR)/*.ipynb

proc-live: exec-nbs
	@echo "==> nbdev-proc-nbs"
	$(UVRUN) nbdev-proc-nbs

render: proc
	@echo "==> quarto render (full site) inside $(PROC_DIR)"
	cd $(PROC_DIR) && $(QUARTO) render

render-live: proc-live
	@echo "==> quarto render (full site) inside $(PROC_DIR)"
	cd $(PROC_DIR) && $(QUARTO) render

docs:
	@echo "==> uv sync --group dev"
	$(UV) sync --group dev
	$(MAKE) render
	@echo "Done: docs"

docs-refresh-live:
	@echo "==> uv sync --group dev"
	$(UV) sync --group dev
	$(MAKE) render-live
	@echo "Done: docs-refresh-live"

preview: proc
	@echo "==> quarto preview inside $(PROC_DIR)"
	cd $(PROC_DIR) && $(QUARTO) preview

render-one: proc
	@echo "==> quarto render (single file): $(RENDER_ONE)"
	cd $(PROC_DIR) && $(QUARTO) render $(RENDER_ONE)

render-core: render-one

clean-proc:
	@echo "==> rm -rf $(PROC_DIR)"
	rm -rf $(PROC_DIR)

clean-docs:
	@echo "==> rm -rf $(PROC_DIR)/_docs $(PROC_DIR)/_site"
	rm -rf $(PROC_DIR)/_docs $(PROC_DIR)/_site

clean-all: clean clean-proc clean-docs
	@echo "Done: clean-all"

quarto-inspect:
	@echo "Quarto Inspect:"
	cd $(PROC_DIR) && quarto inspect . | jq .

publish: test docs-refresh-live nbs_md
	@echo "==> ghp-import (publish $(PROC_DIR)/_docs to gh-pages)"
	$(UVRUN) ghp-import -n -p -f $(PROC_DIR)/_docs
	@echo "Done: publish (gh-pages updated from $(PROC_DIR)/_docs)"

ctx-check:
	@set -e; \
	CTX_BIN="$(CTX_LOCAL)"; \
	if [ ! -x "$$CTX_BIN" ]; then \
	  if command -v ctx >/dev/null 2>&1; then \
	    CTX_BIN="$$(command -v ctx)"; \
	  else \
	    echo "ERROR: CTX binary not found at '$(CTX_LOCAL)' and 'ctx' is not in PATH."; \
	    if [ -f "$(CTX_INSTALL)" ]; then \
	      echo "Fix: run 'make ctx-install' (network required)"; \
	    fi; \
	    exit 1; \
	  fi; \
	fi

ctx: ctx-check
	@set -e; \
	CTX_BIN="$(CTX_LOCAL)"; \
	if [ ! -x "$$CTX_BIN" ]; then \
	  CTX_BIN="$$(command -v ctx)"; \
	fi; \
	"$$CTX_BIN" tool:run nb-export --no-interaction --config-file "$(CTX_CONFIG)"; \
	"$$CTX_BIN" build --config-file "$(CTX_CONFIG)"

ctx-install:
	@set -e; \
	if [ ! -f "$(CTX_INSTALL)" ]; then \
	  echo "ERROR: install script not found at '$(CTX_INSTALL)'"; \
	  exit 1; \
	fi; \
	sh "$(CTX_INSTALL)"
