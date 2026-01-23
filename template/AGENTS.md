# AGENTS.md

Context for future assistants working in this repo.

## nbdev workflow expectations

After each change, run the standard workflow:

```bash
cd {{ project_name }}
make sync
make export
uv run {{ cli_name }}
make test
make docs
```

Then verify:
- Generated code in `{{ package_name }}/*.py` matches expectations.
- Generated docs in `_proc/_docs/*.md` match the notebook content and literate programming best practices.

If any compile/runtime errors occur, fix them and repeat the sequence.

If any outputs or docs are not as expected, create a timestamped TODO file:
`YYYY-MM-DDTHHMMSS-TODOs.md`, describe the issues, and ask the user to review before making improvements.

## nbdev import rule (nbdev2)

- In notebooks, prefer absolute imports (e.g., `from {{ package_name }}.module import fn`).
- Relative imports can cause nbdev export errors; nbdev2 rewrites absolute imports to relative ones during export, so this is a practical rule based on the import‑rewrite mechanism (not a hard prohibition).

## Literate programming best practices

- Lead each notebook with a short introduction that states scope and outlines sections; use clear markdown headings for structure.
- Keep code cells small and focused, and add a short markdown explanation before each code block.
- Demonstrate key functions immediately after defining them with a small example or check.
- Keep imports in their own cell (avoid mixing imports and computation in one cell) to reduce doc-build execution surprises.
- Keep documentation, tests, and examples near the code they explain.
- You cannot split a single Python function/class definition across multiple cells; instead, refactor long functions into smaller helpers and describe each helper in its own markdown+code section.

## Permissions policy

- Pre-authorized to run normal workflow commands with escalated permissions when required (network or IPC): `make sync`, `uv sync`, `uv run ...`, `make test`, `make docs`.
- Use escalated permissions for `nbdev_test` when multiprocessing semaphores are blocked; prefer normal permissions otherwise.
- This note is a standing authorization for network + IPC during the standard workflow.
- AGENTS.md is policy only; permissions still require the escalated flag in tool calls when the sandbox enforces it.

Plain language: You have already approved network + IPC for the standard workflow, so the assistant should proceed without asking.
The escalated flag is just the technical switch needed by the sandbox to run those commands; it does not mean new approval is required each time.

## Logging

- Use the standard `logging` module for all runtime output (avoid bare `print` in library code).
- Initialize logging through a shared helper and pass loggers into worker functions.
- Log key milestones, counts, and warnings with context that helps debugging.
