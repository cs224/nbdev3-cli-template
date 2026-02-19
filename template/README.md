# {{ project_name }}

{{ description }}.

Dual-use project:
- CLI tool for routine use (`uv run {{ cli_name }} ...`)
- Notebook-first nbdev project where notebooks in `nbs/` are the source of truth and exported code is generated in `{{ package_name }}/`

## What this project does

- Provides a tiny `argparse`-based hello-world CLI.
- Demonstrates notebook-first development with nbdev export/test/docs flow.
- Keeps pytest and notebook tests side-by-side.

## Entry points

- CLI:
  ```bash
  uv run {{ cli_name }} --help
  ```
- Notebook landing page: `nbs/index.ipynb`
- CLI notebook: `nbs/00_cli.ipynb`
- Notebook tests: `nbs/99_tests.ipynb`

## Quickstart

```bash
cd {{ project_name }}
make sync

uv run {{ cli_name }}
uv run {{ cli_name }} --name Alice
uv run python -m {{ package_name }} --name Alice
```

## Developer workflow

### 1) Bootstrap tooling

```bash
cd {{ project_name }}
uv sync --group dev
```

### 2) Run the standard workflow

```bash
cd {{ project_name }}
make sync
make export
uv run {{ cli_name }}
make test
make docs
make nbs_md
```

### 3) Notebook-flow verification (required)

Treat verification as two passes:
- Pass A: flow/structure integrity (Define -> use -> verify ordering and proximity)
- Pass B: semantic integrity (prose/examples/assertions match current behavior)

This repo includes a local skill for this:
- `.agents/skills/notebook-flow-verification/`

## Tests

Two complementary test systems are kept separate:

```bash
make nbdev_test   # notebook-based tests
make pytest       # standard Python tests
make test         # quality gate: nbdev_test + pytest
```

Convenience aliases:
- `make test-nb` (nbdev only)
- `make test-fast` (pytest only)

## Docs

Docs are rendered with Quarto from preprocessed notebooks in `_proc/`.

- `make docs` renders docs without executing notebooks (uses saved outputs).
- `make docs-refresh-live` executes notebooks, then renders docs.
- `make preview` starts local Quarto preview from `_proc/`.
- `make render-one RENDER_ONE=00_cli.ipynb` renders one page inside `_proc/`.

## Notebook markdown mirror

- `nbs_md/` stores markdown exports of tracked notebooks from `nbs/`.
- Regenerate with:
  ```bash
  make nbs_md
  ```
- This is useful for notebook-flow review and lightweight diffs of narrative changes.

## CTX integration (optional)

This project includes optional CTX integration for building notebook-derived context bundles.

- Config file: `ctx.yaml`
- Installer script: `scripts/install_ctx.sh`
- Make targets:
  - `make ctx-check` verifies `ctx` is available (local `./.bin/ctx` or PATH)
  - `make ctx-install` installs `ctx` into `./.bin` (network required)
  - `make ctx` runs notebook markdown export + CTX build

## Publishing docs

```bash
cd {{ project_name }}
make publish
```

`make publish` runs:
- `make test`
- `make docs-refresh-live`
- `make nbs_md`

Then it publishes `_proc/_docs` to `gh-pages` using `ghp-import`.

## Notebook usage (nbclassic)

- Notebook: `nbs/index.ipynb`
- One-off launch:
  ```bash
  uvx --with notebook --with nbclassic jupyter nbclassic nbs/index.ipynb
  ```
- Using project deps:
  ```bash
  uv sync --group dev
  uv run jupyter nbclassic nbs/index.ipynb
  ```

## Notes

- This project uses nbdev3 notebooks in `nbs/`.
- Avoid `uv run nbdev-prepare`; it can overwrite `README.md`.
- `pyproject.toml` is the canonical config (project metadata + `[tool.nbdev]`).
