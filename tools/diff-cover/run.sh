#!/usr/bin/env bash
# diff-cover
set -uo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
. "$REPO_ROOT/tools/_skip.sh"

# --- why this tool has the status it has on this family -------------------
# Class C: reads Cobertura/OpenCover XML. Coverlet now produces one on this branch, so diff-cover has something to read wherever it is installed.

require_cmd diff-cover
OUT="$(report_dir)"
[ -s "$OUT/coverage.cobertura.xml" ] || bash "$REPO_ROOT/tools/coverlet/run.sh" >/dev/null || exit 1
cd "$REPO_ROOT" || exit 1
diff-cover "$OUT/coverage.cobertura.xml" --compare-branch HEAD~1 \
  --json-report "$OUT/diff-cover.json" > "$OUT/diff-cover.txt" 2>&1 || exit 1
exit 0
