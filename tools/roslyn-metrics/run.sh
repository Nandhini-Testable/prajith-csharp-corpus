#!/usr/bin/env bash
# roslyn-metrics
set -uo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
. "$REPO_ROOT/tools/_skip.sh"

# --- why this tool has the status it has on this family -------------------
# The sheet says 'Roslyn', which is a compiler platform, not a package. Resolved here to SonarAnalyzer.CSharp 9.32.0.97167 (rule S3776 is cognitive complexity), referenced as an analyzer package.

require_restore
OUT="$(report_dir)/roslyn-metrics.sarif"
sarif_build "$OUT" || exit 1
python3 - "$OUT" S <<'PY'
import json, sys
doc = json.load(open(sys.argv[1], encoding="utf-8-sig"))
rules = [r["ruleId"] for run in doc["runs"] for r in run.get("results", [])]
mine = [r for r in rules if r.startswith(tuple(sys.argv[2:])) and not r.startswith("SA")]
if not mine:
    sys.exit("STRUCTURALLY ZERO: the SARIF log holds no SonarAnalyzer diagnostics, so the "
             "analyzer was not loaded.")
print("roslyn-metrics: %d diagnostics across %d rules" % (len(mine), len(set(mine))))
PY
exit $?
