# {{ project_name }}

{{ description }}

## Quickstart

```bash
make sync
uv run {{ cli_name }}
uv run {{ cli_name }} --name Alice
uv run python -m {{ package_name }} --name Alice
```

## Development

```bash
make export
make test
```

## nbdev workflow (cheat sheet)

```bash
make sync                           # install deps (incl. nbdev)
uv run nbdev-install-hooks          # install git/nbdev pre-commit hooks (optional, see below)
uv run nbdev-prepare                # export, strip outputs, run tests; **WILL OVERWRITE YOUR README.md**!!
make export                         # only export notebooks -> python
make nbdev_test                     # run tests in notebooks
```

- `pyproject.toml` configures lib name, paths, version, repo slug.
- Code cells use `#| export` to mark what becomes part of the module.
- Docs can be built with `make docs` (renders into `_proc/_docs`).

## Publishing docs (local -> GitHub Pages)

- Build locally: `UV_OFFLINE=1 make docs` (renders into `_proc/_docs`).
- Publish explicitly: `uv sync --group dev` (first time to install `ghp-import`), then `make publish`. This runs `ghp-import -n -p -f _proc/_docs` to push the rendered site to the `gh-pages` branch.
- One-time repo setup after pushing to GitHub: Settings -> Pages -> **Source: Deploy from a branch**, Branch: `gh-pages` / folder `/(root)`. The site will be served at `https://{{ repo_slug.split('/')[0] }}.github.io/{{ project_name }}`.

### What does `uv run nbdev-install-hooks` do? Can I work without it?

- The command installs git/nbdev pre-commit hooks that automatically: export notebooks to code (`nbdev-export`), strip outputs, and fail the commit if notebooks aren't cleaned. It's convenient automation but optional.
- To work without hooks: skip `nbdev-install-hooks`. Instead, run these manually before pushing/committing:
  ```bash
  make export             # sync notebooks -> python
  make nbdev_test         # optional: run nbdev tests
  uv run nbdev-prepare    # full cycle: export, clean outputs, run tests; **WILL OVERWRITE YOUR README.md**!!
  ```
  Ensure you commit both the notebook and the exported python files under `{{ package_name }}/`.

## Tests (pytest vs nbdev_test)

- `make pytest` runs the standard `pytest` suite in `tests/`. This verifies CLI behavior using normal Python unit tests.
- `make nbdev_test` runs nbdev's notebook tests. It **executes notebooks in `nbs/`** in order (fresh kernel per notebook) and treats any exceptions or failed `assert` statements in code cells as test failures. This is why many projects keep a `99_tests.ipynb` notebook with assertions.
  - “Cells marked for testing” means code cells that contain test logic (usually `assert` statements) in notebooks. You don’t need a special filename, but it’s common to group tests in a dedicated notebook.
  - “Other nbdev test hooks” means nbdev respects notebook test flags. Cells tagged with `#| notest` are skipped by `nbdev-test`. This lets you keep demo or expensive cells in notebooks without running them as tests.


## Notebook (nbdev + nbclassic)

- Notebook: `nbs/index.ipynb`
- Ways to launch nbclassic with the right deps:
  1) No install, one-off via uvx:  
     `uvx --with notebook --with nbclassic jupyter nbclassic nbs/index.ipynb`
  2) Project deps:
     ```bash
     uv sync
     uv run jupyter nbclassic nbs/index.ipynb
     ```

## Notes

- This project uses nbdev3 notebooks in `nbs/`.
- Avoid `nbdev-prepare`; it overwrites `README.md`.
