#!/usr/bin/env bash
set -euo pipefail

OPS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(pwd)"
OVERLAY_DIR="$OPS_DIR/overlay"
REMOVE_MANIFEST="$OPS_DIR/remove_manifest.txt"

if [ -d "$OVERLAY_DIR" ]; then
  cp -a "$OVERLAY_DIR"/. "$ROOT_DIR"/
fi

if [ -f "$REMOVE_MANIFEST" ]; then
  while IFS= read -r rel_path; do
    [ -z "$rel_path" ] && continue
    case "$rel_path" in
      \#*) continue ;;
    esac
    case "$rel_path" in
      /*|*..*)
        echo "invalid manifest path: $rel_path" >&2
        exit 1
        ;;
    esac
    rm -rf "$ROOT_DIR/$rel_path"
  done < "$REMOVE_MANIFEST"
fi

echo "operation mode: overlays applied"
