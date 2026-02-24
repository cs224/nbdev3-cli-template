#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
START_DIR="$(pwd)"
STATE_OUT_DIR="$START_DIR/_tmp_hello_project_state"
OP_OUT_DIR="$START_DIR/_tmp_hello_project_operation"

rm -rf "$STATE_OUT_DIR" "$OP_OUT_DIR"

smoke_one() {
  local mode="$1"
  local out_dir="$2"

  uvx copier copy --trust --defaults "$ROOT_DIR" "$out_dir" -d generation_mode="$mode"

  cd "$out_dir"

  rm -f hello_cli/cli.py

  make sync
  make export
  uv run hello-cli
  uv run hello-cli --name Alice
  uv run python -m hello_cli --name Alice
  make test
  make docs
}

smoke_one "state" "$STATE_OUT_DIR"
cd "$START_DIR"
smoke_one "operation" "$OP_OUT_DIR"

echo "Smoke test complete:"
echo "- state: $STATE_OUT_DIR"
echo "- operation: $OP_OUT_DIR"
echo "Open in your browser: $STATE_OUT_DIR/_proc/_docs/index.html"
