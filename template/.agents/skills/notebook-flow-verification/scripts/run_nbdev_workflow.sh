#!/usr/bin/env bash
set -euo pipefail

# uv-first runner
UVRUN="uv run"

# Prefer Makefile targets if they exist, but execute via uv to ensure venv context.
if [ -f Makefile ]; then
  for t in export test docs; do
    if make -n "$t" >/dev/null 2>&1; then
      # docs is optional; it's okay to run, but SKILL.md must not use docs output for verification
      $UVRUN make "$t"
    fi
  done
else
  # Fallback to nbdev CLIs (still via uv)
  $UVRUN nbdev-export
  $UVRUN nbdev-test
  # docs optional: only run if the command exists in the environment
  if $UVRUN bash -lc 'command -v nbdev-docs >/dev/null 2>&1'; then
    $UVRUN nbdev-docs
  fi
fi
