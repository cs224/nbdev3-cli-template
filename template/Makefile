# Makefile for an nbdev3 + uv project

SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.NOTPARALLEL:

UV      ?= uv
QUARTO  ?= quarto
UVRUN    = $(UV) run

NBS_DIR  ?= nbs
PROC_DIR ?= _proc
CLI_NB   ?= $(NBS_DIR)/00_cli.ipynb

.PHONY: help sync export nbdev_test pytest test clean clean-nbs proc render docs

help:
	@echo "Targets:"
	@echo "  make sync       - Create/update .venv from pyproject.toml"
	@echo "  make export     - nbdev-export (generate package modules)"
	@echo "  make nbdev_test - nbdev-test (notebook-based tests)"
	@echo "  make pytest     - pytest (standard tests)"
	@echo "  make test       - nbdev_test + pytest"
	@echo "  make clean      - nbdev-clean"
	@echo "  make clean-nbs  - nbdev-clean --clear_all (strip outputs)"
	@echo "  make docs       - proc + quarto render (requires Quarto)"
	@echo "  make preview    - quarto preview (live server) from within _proc"
	@echo "  make render-core - render only $(CLI_NB) from within _proc"
	@echo "  make clean-proc - remove _proc"
	@echo "  make clean-docs - remove _docs/_site"
	@echo "  make clean-all  - clean-proc + clean-docs"
	@echo "  make publish    - publish _proc/_docs to gh-pages"

## Ensure environment is ready (optional)
sync:
	@echo "==> uv sync"
	$(UV) sync

## Step 1: export library code from notebooks
export:
	@echo "==> nbdev-export"
	$(UVRUN) nbdev-export

## Step 2a: nbdev tests
nbdev_test:
	@echo "==> nbdev-test"
	$(UVRUN) nbdev-test

## Step 2b: pytest suite
pytest:
	@echo "==> pytest"
	$(UVRUN) pytest

## Combined tests
test: nbdev_test pytest
	@echo "Done: nbdev_test + pytest"

## Step 3: nbdev clean
clean:
	@echo "==> nbdev-clean"
	$(UVRUN) nbdev-clean

clean-nbs:
	@echo "==> nbdev-clean --clear_all"
	$(UVRUN) nbdev-clean --clear_all

## Step 4: preprocess notebooks for docs (generates/updates _proc)
proc:
	@echo "==> execute notebooks inside $(NBS_DIR)"
	$(UVRUN) jupyter nbconvert --to notebook --inplace --execute --ExecutePreprocessor.timeout=600 $(NBS_DIR)/*.ipynb
	@echo "==> nbdev-proc-nbs"
	$(UVRUN) nbdev-proc-nbs

## Step 5: render documentation (FULL SITE)
render: proc
	@echo "==> quarto render (full site) inside $(PROC_DIR)"
	cd $(PROC_DIR) && $(QUARTO) render

## High-level docs target (alias for proc+render)
docs:
	@echo "==> uv sync --group dev"
	$(UV) sync --group dev
	$(MAKE) render
	@echo "Done: docs"


## Live preview server
preview: proc
	@echo "==> quarto preview inside $(PROC_DIR)"
	cd $(PROC_DIR) && $(QUARTO) preview

# ---- Optional: single-page render for faster iteration ----
render-core: proc
	@echo "==> quarto render (single file): $(CORE_NB)"
	cd $(PROC_DIR) && $(QUARTO) render $(CLI_NB)

# ---- Cleanup helpers ----
clean-proc:
	@echo "==> rm -rf $(PROC_DIR)"
	rm -rf $(PROC_DIR)

clean-docs:
	@echo "==> rm -rf _docs _site (if present in repo root)"
	rm -rf _docs _site

clean-all: clean-proc clean-docs
	@echo "Done: clean-all"

quarto-inspect:
	@echo "Quarto Inspect:"
	cd $(PROC_DIR) && quarto inspect . | jq .

## Publish docs in _proc/_docs to gh-pages (GitHub Pages)
publish: docs
	@echo "==> ghp-import (publish _proc/_docs to gh-pages)"
	$(UVRUN) ghp-import -n -p -f _proc/_docs
	@echo "Done: publish (gh-pages updated from _proc/_docs)"
