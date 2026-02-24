#!/usr/bin/env bash
set -euo pipefail

OPS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(pwd)"
source "$OPS_DIR/bootstrap.sh"

echo "operation mode: running nbdev_new with nbdev==${NBDEV_VERSION}"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

(
  cd "$tmp_dir"
  "$BOOTSTRAP_NBDEV_NEW" \
    --path "." \
    --repo "{{ project_name }}" \
    --branch "main" \
    --user "{{ repo_slug.split('/')[0] }}" \
    --author "{{ author_name }}" \
    --author_email "{{ author_email }}" \
    --description "{{ description }}" \
    --min_python "{{ min_python }}"
)

cp -a "$tmp_dir"/. "$ROOT_DIR"/
echo "operation mode: generated nbdev baseline and copied into project root"
