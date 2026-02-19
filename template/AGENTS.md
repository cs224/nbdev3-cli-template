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
- Review changed notebooks in `nbs/*.ipynb` (and optionally their markdown mirrors if generated) and confirm section order is still Define → use → verify.
- Confirm each changed helper/function has:
  - a markdown intent cell immediately before it,
  - a usage/example cell immediately after it,
  - and a verify/assert cell near that usage.
- Confirm explanatory markdown matches current argument names/defaults and return shapes.
- Confirm examples/asserts validate real behavior (not only trivial checks).
- Confirm semantic correctness for each changed section:
  - markdown claims about behavior/performance/failure modes still match reality,
  - examples and asserts validate real behavior (not only `callable()`),
  - defaults mentioned in prose/CLI examples match implementation defaults,
  - retry/strict/fallback descriptions match the actual error-handling code path,
  - “incremental/idempotent/backfill” claims still hold with the current window/query logic.
- If mismatches are found, update prose/examples/asserts in the same change set as code fixes.

If any compile/runtime errors occur, fix them and repeat the sequence.

If any outputs or docs are not as expected, create a timestamped TODO file:
`YYYY-MM-DDTHHMMSS-TODOs.md`, describe the issues, and ask the user to review before making improvements.

## Python environment rule

- Do not use system/base Python directly for project work.
- Always run tooling through `uv`, for example:
  - `uv run python ...`
  - `uv run <tool> ...`
  - `uv sync` / `uv pip ...`
- If a package is needed for development workflows, add it in `pyproject.toml` under the `dev` dependency group and use it through `uv`.
- This project is configured with a repo-local uv cache in `nym-node-reward-tracker/pyproject.toml`:
  - `[tool.uv] cache-dir = "./.uv-cache"`
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
- Relative imports in notebooks can cause nbdev export errors; nbdev3’s export rewrites absolute imports to relative ones, so this is a practical rule based on the import‑rewrite mechanism (not a hard prohibition).

## Literate programming best practices

- At the very top of notebooks, include these two hidden cells in this exact order to widen notebook layout during execution:
  ```python
  #| hide
  from IPython.display import display, HTML
  ```
  ```python
  #| hide
  for css in ["<style>.container { width:70% !important; }</style>", "<style>:root { --jp-notebook-max-width: 70% !important; }</style>"]:
      display(HTML(css))
  ```
  Keep them as two separate cells.
- Lead each notebook with a short introduction that states scope and outlines sections; use clear markdown headings for structure.
- Keep code cells small and focused; add short markdown explanation before each block.
- Demonstrate key functions immediately after defining them with a small example or check.
- Define -> use -> verify:
  - put intent markdown before definitions,
  - include immediate usage/examples after definitions,
  - include nearby verifies/asserts.
- When modifying code in an existing notebook section, update the surrounding human-readable cells in the same edit pass:
  - update the pre-code intent markdown to match the new behavior,
  - keep the example/use cell aligned with the current API,
  - and keep/adjust the verify cell so it validates the new behavior.
- Do not leave “implementation drift” where code changes but prose/examples/assertions still describe old behavior.
- Keep documentation/tests/examples near the code they explain.
- Do not move code blocks in ways that separate them from their local Define → use → verify trio, unless you also move/update the trio together.
- “Notebook integrity” means both structure and meaning; do not mark notebook work complete unless both pass.
- Keep imports in their own cell (avoid mixing imports and computation in one cell) to reduce doc-build execution surprises.
- nbdev3 warning guardrail: for non-`#| export` cells, never mix `import ...` / `from ... import ...` lines with runtime code (`assert`, `with`, function calls, etc.) in the same cell. Use an import-only cell immediately followed by a usage/verify cell.
- MissingIDField guardrail: every notebook cell must have an `id` field (nbformat warning today, future hard error). After notebook edits, run a quick ID check before docs refresh:
  ```bash
  cd nym-node-reward-tracker
  uv run python - <<'PY'
  import json
  from pathlib import Path
  bad=[]
  for p in sorted(Path("nbs").glob("*.ipynb")):
      nb=json.loads(p.read_text())
      miss=[i for i,c in enumerate(nb["cells"]) if "id" not in c]
      if miss: bad.append((p, miss))
  if bad:
      for p, miss in bad:
          print(f"{p}: missing ids in cells {miss}")
      raise SystemExit(1)
  print("OK: all notebook cells contain ids")
  PY
  ```
- Preflight before `make docs` / `make docs-refresh-live`: run `uv run nbdev-proc-nbs` and treat `Found cells containing imports and other code` as a must-fix warning (split the offending cell into import-only + code cell in the same section).
- Do not run `nbdev-prepare` during normal workflow; it can overwrite `README.md`.
- You cannot split a single Python function/class definition across multiple cells; instead, refactor long functions into smaller helpers and describe each helper in its own markdown+code section.
- For every notebook containing `#| export` cells, add this hidden footer cell at the very bottom:
  ```python
  #| hide
  import nbdev; nbdev.nbdev_export()
  ```

## Permissions policy

- Pre-authorized to run standard workflow commands with escalated permissions when required (network or IPC): `make sync`, `make export`, `make nbdev_test`, `make pytest`, `make test`, `make docs`, `make docs-refresh-live`, `uv sync`, `uv run ...`.
- `make publish` is excluded from standing authorization; ask the user before running publish.
- Use escalated permissions for `nbdev-test` when multiprocessing semaphores are blocked; prefer normal permissions otherwise.
- AGENTS.md is policy only; permissions still require the escalated flag when sandbox enforces it.
- Local cache policy: when running `uv`/`make` in this repo, use the configured local uv cache (`nym-node-reward-tracker/.uv-cache`) and avoid ad-hoc external cache overrides.

Plain language: network + IPC for standard workflow is pre-approved; proceed without re-asking.

## Logging

- Use Python `logging` module for runtime output (avoid bare `print` in library code).
- Initialize logging centrally and pass loggers into worker functions.
- Log key milestones and warnings with enough context for debugging.
