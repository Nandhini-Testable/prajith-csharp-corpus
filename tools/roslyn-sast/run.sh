#!/usr/bin/env bash
# roslyn-sast
set -uo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
. "$REPO_ROOT/tools/_skip.sh"

# --- why this tool has the status it has on this family -------------------
# The sheet says 'roslyn sast', also not a package. Resolved here to SecurityCodeScan.VS2019 5.6.7 + Microsoft.CodeAnalysis.NetAnalyzers 8.0.0, referenced as analyzer packages.

require_restore
OUT="$(report_dir)/roslyn-sast.sarif"
sarif_build "$OUT" || exit 1
python3 - "$OUT" CA SCS <<'PY'
import json, sys
doc = json.load(open(sys.argv[1], encoding="utf-8-sig"))
rules = [r["ruleId"] for run in doc["runs"] for r in run.get("results", [])]
mine = [r for r in rules if r.startswith(tuple(sys.argv[2:])) and not r.startswith("SA")]
if not mine:
    sys.exit("STRUCTURALLY ZERO: the SARIF log holds no NetAnalyzers or SecurityCodeScan diagnostics, so the "
             "analyzer was not loaded.")
print("roslyn-sast: %d diagnostics across %d rules" % (len(mine), len(set(mine))))
PY
exit $?
