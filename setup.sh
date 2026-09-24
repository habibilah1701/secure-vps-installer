#!/usr/bin/env bash
# Convenience entrypoint. The installer itself remains install.sh.
set -Eeuo pipefail
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
exec "$SCRIPT_DIR/install.sh" "$@"
