#!/usr/bin/env bash
set -euo pipefail

NBDEV_VERSION="{{ nbdev_version }}"
MIN_PYTHON="{{ min_python }}"
OPS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP_VENV="$OPS_DIR/.bootstrap-venv"
BOOTSTRAP_PY="$BOOTSTRAP_VENV/bin/python"
BOOTSTRAP_NBDEV_NEW="$BOOTSTRAP_VENV/bin/nbdev-new"

if ! command -v uv >/dev/null 2>&1; then
  echo "operation mode requires uv on PATH" >&2
  exit 1
fi

if [ ! -x "$BOOTSTRAP_NBDEV_NEW" ]; then
  echo "operation mode bootstrap: creating minimal env (python=$MIN_PYTHON, nbdev=$NBDEV_VERSION)"
  uv venv --python "$MIN_PYTHON" "$BOOTSTRAP_VENV"
  uv pip install --python "$BOOTSTRAP_PY" "nbdev==${NBDEV_VERSION}"
else
  echo "operation mode bootstrap: reusing $BOOTSTRAP_VENV"
fi

export NBDEV_VERSION BOOTSTRAP_VENV BOOTSTRAP_PY BOOTSTRAP_NBDEV_NEW
