#!/usr/bin/env bash
set -euo pipefail

NBS_PATH="$(
  uv run python - <<'PY'
import sys
try:
  import tomllib
except Exception:
  import tomli as tomllib  # type: ignore
from pathlib import Path
p = Path("pyproject.toml")
data = tomllib.loads(p.read_text())
nb = (data.get("tool", {}).get("nbdev", {}) or {})
print(nb.get("nbs_path", "nbs"))
PY
)"

# staged + unstaged
{ git diff --name-only; git diff --cached --name-only; } \
  | awk 'NF' \
  | sort -u \
  | grep -E "^${NBS_PATH}/.*\.ipynb$" || true
