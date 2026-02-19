# AGENTS.md

Context for future assistants working in this repo.

## nbdev workflow expectations

After each change, run this sequence from repo root:

```bash
make sync
make export
uv run {{ cli_name }}
make test
make docs
make nbs_md
```

Docs workflow semantics:
- `make docs` is a non-executing docs build. It renders from current notebook outputs.
- Use `make docs-refresh-live` only when you intentionally want to refresh notebook outputs before docs rendering.
- `make publish` should run tests and `docs-refresh-live` before publishing.

Test workflow semantics:
- `make nbdev_test` runs notebook-based tests.
- `make pytest` runs standard Python tests.
- `make test` is the quality gate and runs both.
- Optional convenience aliases: `make test-nb` and `make test-fast`.

Then do notebook-flow verification:
- Generated code in `{{ package_name }}/*.py` matches notebook intent.
- Generated docs in `_proc/_docs/*.md` match notebook content.
- Generated notebook markdown in `nbs_md/*.md` is present and up to date for changed notebooks.
- Notebook narrative still matches implementation (no stale prose, misplaced verify cells, or broken Define -> use -> verify flow).

Treat notebook-flow verification as two required passes:
- Pass A (flow/structure integrity): check Define -> use -> verify placement and readability.
- Pass B (semantic integrity): check prose/examples/assertions against current behavior.

For notebook-flow verification, do all of the following after `make docs`:
- Review changed notebooks in `nbs/*.ipynb` (and optionally their markdown mirrors if generated).
- Confirm each changed helper/function has:
  - a markdown intent cell immediately before it,
  - a usage/example cell immediately after it,
  - and a verify/assert cell near that usage.
- Confirm explanatory markdown matches current argument names/defaults and return shapes.
- Confirm examples/asserts validate real behavior (not only trivial checks).
- If mismatches are found, update prose/examples/asserts in the same change set as code fixes.

If any compile/runtime errors occur, fix them and repeat the sequence.

If any outputs or docs are not as expected, create a timestamped TODO file:
`YYYY-MM-DDTHHMMSS-TODOs.md`, describe the issues, and ask the user to review before making improvements.

## Python environment rule

- Do not use system/base Python directly for project work.
- Always run tooling through `uv`, for example:
  - `uv run python ...`
  - `uv run <tool> ...`
  - `uv sync`
- Run `uv`/`make` commands from repo root so `[tool.uv]` config in `pyproject.toml` is applied.

## Local skills

- This repo includes a local skill at `.agents/skills/notebook-flow-verification/`.
- Use that skill for detailed two-pass notebook-flow verification and helper scripts.
- Prefer script entrypoints in `.agents/skills/notebook-flow-verification/scripts/` when applicable.

## CTX integration (optional)

- Optional CTX config is in `ctx.yaml`.
- Installer script is `scripts/install_ctx.sh`.
- Make targets:
  - `make ctx-check` to verify `ctx` availability,
  - `make ctx-install` to install locally into `./.bin`,
  - `make ctx` to run notebook export + CTX build.

## nbdev import rule (nbdev3)

- In notebooks, prefer absolute imports (e.g., `from {{ package_name }}.module import fn`).
- Relative imports can cause nbdev export errors; this is a practical rule based on export/import rewriting.

## Literate programming best practices

- Lead each notebook with a short introduction that states scope and outlines sections.
- Keep code cells small and focused; add short markdown explanation before each block.
- Define -> use -> verify:
  - put intent markdown before definitions,
  - include immediate usage/examples after definitions,
  - include nearby verifies/asserts.
- When changing code in a notebook section, update surrounding prose/examples/asserts in the same edit pass.
- Keep imports in their own cell (avoid mixing imports and runtime logic in one cell).
- Do not split a single function/class definition across multiple cells.
- Keep documentation/tests/examples near the code they explain.
- Do not run `nbdev-prepare` during normal workflow; it can overwrite `README.md`.

## Permissions policy

- Pre-authorized to run standard workflow commands with escalated permissions when required (network or IPC): `make sync`, `make export`, `make nbdev_test`, `make pytest`, `make test`, `make docs`, `make docs-refresh-live`, `uv sync`, `uv run ...`.
- Use escalated permissions for `nbdev-test` when multiprocessing semaphores are blocked; prefer normal permissions otherwise.
- AGENTS.md is policy only; permissions still require the escalated flag when sandbox enforces it.

Plain language: network + IPC for standard workflow is pre-approved; proceed without re-asking.

## Logging

- Use Python `logging` module for runtime output (avoid bare `print` in library code).
- Initialize logging centrally and pass loggers into worker functions.
- Log key milestones and warnings with enough context for debugging.
