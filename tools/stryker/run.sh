#!/usr/bin/env bash
# stryker
set -uo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
. "$REPO_ROOT/tools/_skip.sh"

# --- why this tool has the status it has on this family -------------------
# dotnet-stryker 4.0.0 is pinned in .config/dotnet-tools.json and mutates this family: it restores the solution, mutates the library, runs the tests against each mutant and writes a mutation report. Also: the sheet makes it primary for 16 Data Flow metrics, which it cannot compute -- see roslyn-dataflow.

require_restore
dotnet tool restore >/dev/null 2>&1 || missing "dotnet tool restore failed"
OUT="$(report_dir)/stryker"
cd "$REPO_ROOT" || exit 1
dotnet stryker --reporter json --output "$OUT" \
  --test-project "$REPO_ROOT/tests/OrderKit.Tests/OrderKit.Tests.csproj" > "$(report_dir)/stryker.log" 2>&1 || exit 1
find "$OUT" -name mutation-report.json | grep -q . || exit 1
grep -o 'The final mutation score is [0-9.]* %' "$(report_dir)/stryker.log" | tail -n 1
exit 0
