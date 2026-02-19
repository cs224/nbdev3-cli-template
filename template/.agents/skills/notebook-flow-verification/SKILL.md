---
name: notebook-flow-verification
description: >
  For any nbdev3+ project using uv: run export+test (optionally docs) without nbdev-prepare,
  then perform two-pass notebook-flow verification (Pass A: Define→use→verify structure,
  Pass B: semantic correctness) using source notebooks (*.ipynb) and exported Python modules
  as the sources of truth (do not rely on docs/_proc or nbconvert-to-markdown exports).
---

# notebook-flow verification (nbdev, two pass)

## Assumptions / constraints (non-negotiable)
- Repo root contains `pyproject.toml` and uses `uv` for the project environment.
- Do NOT use `nbdev-prepare` (it can overwrite README.md).
- Verification must be based on:
  1) source notebooks (`*.ipynb`), and
  2) exported Python modules (nbdev export output).
  Do NOT use documentation render structure (`_proc/_docs`, site output) as a verification source.
  Do NOT rely on nbconvert-to-markdown exports (e.g. `--to markdown`) as a verification source.

## Local helper resources (optional but preferred when present)
This skill ships with helper scripts. Codex will NOT run them automatically—run them only when instructed here.

When you need to run a helper script, locate it by checking these paths in order and picking the first executable:
1) `./.agents/skills/notebook-flow-verification/scripts/<script>`
2) `~/.agents/skills/notebook-flow-verification/scripts/<script>`
3) `~/.codex/skills/notebook-flow-verification/scripts/<script>`

Scripts:
- `list_changed_notebooks.sh`  (enumerate changed notebooks)
- `run_nbdev_workflow.sh`      (run export/test/(optional docs) using uv)

If a script is not found/executable, follow the inline procedure below.

## Step 0 — Read nbdev config and infer paths
Use `pyproject.toml` (`[tool.nbdev]`) as the authoritative config store for nbdev settings.

Infer:
- `NBS_PATH` (default: `nbs`)
- `LIB_PATH` (export destination, e.g. package folder)
- (Optional) `DOC_PATH` (ignore for verification; only relevant if building docs)

If `NBS_PATH` or `LIB_PATH` are missing, fall back to conventional defaults:
- notebooks: `nbs/`
- exports: locate the importable package under repo root (single top-level package dir), or read from existing nbdev tooling output.

## Step 1 — Enumerate notebooks for FULL project review (and optionally prioritize)

Goal:
- Always build `ALL_NOTEBOOKS` = every tracked `*.ipynb` under `NBS_PATH`.
- Optionally build `CHANGED_NOTEBOOKS` for prioritization only (do not limit scope).

### 1A) Build ALL_NOTEBOOKS (authoritative scope)
Preferred (git-tracked, stable, excludes checkpoints automatically):
- `git ls-files | grep -E "^${NBS_PATH}/.*\.ipynb$" | sort -u`

Fallback (if not a git repo):
- `find "${NBS_PATH}" -type f -name '*.ipynb' -print | sort -u`

`ALL_NOTEBOOKS` is the inspection set for Pass A and Pass B.

### 1B) Build CHANGED_NOTEBOOKS (optional prioritization, not scope)
Preferred:
- Run `list_changed_notebooks.sh` (see "Local helper resources") to list changed notebooks.

Otherwise:
- Combine staged + unstaged changes:
  - `git diff --name-only`
  - `git diff --cached --name-only`
- Filter to notebooks under `NBS_PATH` with `.ipynb` suffix.

Use `CHANGED_NOTEBOOKS` only to decide the review order:
- Review changed notebooks first, then the rest.

### 1C) Export-impact notes (optional, after export)
After running export (Step 2), you may record:
- `git diff --name-only -- "${LIB_PATH}"`

This is informational only; full review still covers ALL_NOTEBOOKS.

## Step 2 — Run the standard workflow (export → test → optional docs) using uv
Preferred:
- Run `run_nbdev_workflow.sh` (see "Local helper resources").

Otherwise (inline):
1) Ensure the environment works:
   - If `uv run python -c "print('ok')"` fails due to missing deps, run `uv sync` (and only then retry).
2) Run export:
   - `uv run nbdev-export`  (or project’s `make export`, but still via uv)
3) Run tests:
   - `uv run nbdev-test` (or project’s `make test`, but still via uv)
4) Docs build is optional:
   - If the repo has a docs target, you may run it (`make docs`), but do NOT use docs output as a verification source.

If any compile/runtime error occurs:
- fix it
- repeat Step 2 until clean.

## Step 3 — Pass A (flow/structure integrity): Define → use → verify (ipynb-first)

If `CHANGED_NOTEBOOKS` is non-empty, review those first, then review the remainder of `ALL_NOTEBOOKS`.

For EACH notebook in `ALL_NOTEBOOKS`, verify structure using the notebook itself:

A. Identify each changed definition:
- Functions/classes/helpers introduced or modified.

B. For each definition, ensure local trio exists and is ordered:
1) Intent markdown cell immediately BEFORE the definition cell.
2) Usage/example cell immediately AFTER the definition (close proximity).
3) Verify/assert cell close to that usage (assertions / invariants / meaningful checks).

C. Structural hygiene:
- Imports in their own cell.
- Do not split a single def/class across multiple cells.
- No “orphan” verify cells far away from the usage they verify.

If you need a deterministic aid, run a quick nbformat-based scan (inline; do NOT generate markdown):
- Load the notebook via `nbformat`, iterate cells, and flag:
  - code cells starting with `def ` or `class `
  - missing preceding markdown cell
  - missing nearby usage + assert cells within the next few cells

Fix violations in the notebook (move/update prose + example + verify together), then re-run Step 2.

## Step 4 — Pass B (semantic integrity): truthfulness vs current behavior

For EACH notebook (and each section within it):
- Prose matches current argument names/defaults and return shapes.
- Examples validate real behavior (not trivial checks).
- Error-handling claims (retry/strict/fallback) match actual code paths.
- Any “incremental/idempotent/backfill” claims still hold with current logic.

Validation sources:
- The exported code in `LIB_PATH` (after nbdev-export).
- The test results from `nbdev-test` (and/or project tests).
- If behavior is log-sensitive or API/network-sensitive, validate against observed runtime output from a real run (only when appropriate for the repo).

If mismatches are found:
- update prose/examples/asserts in the same change set as the code change
- rerun Step 2
- redo Pass A + Pass B for affected notebooks.

## Step 5 — Export consistency check (exports are the contract)
Confirm:
- Exported `.py` modules under `LIB_PATH` reflect the notebook intent and public API.
- No unexpected export diffs (use `git diff` to inspect).

## Step 6 — If outputs are still not as expected
Create a timestamped TODO file in repo root:
- `YYYY-MM-DDTHHMMSS-TODOs.md`

Use the provided template (if accessible) from:
- `templates/TODOs.md` under the same skill search path rules as scripts.

Include:
- symptoms + file paths
- what changed
- what you tried
- what decision/info you need from the user

Stop and request review before speculative refactors.

