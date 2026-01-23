#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
START_DIR="$(pwd)"
OUT_DIR="$START_DIR/_tmp_hello_project"

rm -rf "$OUT_DIR"

uvx copier copy --defaults "$ROOT_DIR" "$OUT_DIR"

cd "$OUT_DIR"

rm -f hello_cli/cli.py

make sync
make export
uv run hello-cli
uv run hello-cli --name Alice
uv run python -m hello_cli --name Alice
make test
make docs

echo "Smoke test complete: $OUT_DIR"
echo "Open in your browser: $OUT_DIR/_proc/_docs/index.html"
