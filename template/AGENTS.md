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

## Permissions policy

- Pre-authorized to run normal workflow commands with escalated permissions when required (network or IPC): `make sync`, `uv sync`, `uv run ...`, `make test`, `make docs`.
- Use escalated permissions for `nbdev_test` when multiprocessing semaphores are blocked; prefer normal permissions otherwise.
- This note is a standing authorization for network + IPC during the standard workflow.
- AGENTS.md is policy only; permissions still require the escalated flag in tool calls when the sandbox enforces it.

Plain language: You have already approved network + IPC for the standard workflow, so the assistant should proceed without asking.
The escalated flag is just the technical switch needed by the sandbox to run those commands; it does not mean new approval is required each time.
