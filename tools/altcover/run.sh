#!/usr/bin/env bash
# altcover
set -uo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
. "$REPO_ROOT/tools/_skip.sh"

# --- why this tool has the status it has on this family -------------------
# altcover.global 8.8.173 is pinned in .config/dotnet-tools.json. It instruments the built test output in place, so no project file names it.

require_restore
dotnet tool restore >/dev/null 2>&1 || missing "dotnet tool restore failed"
OUT="$(report_dir)"
dotnet build "$REPO_ROOT/OrderKit.sln" --no-restore --nologo -v quiet >/dev/null 2>&1 || exit 1
BIN="$(dirname "$(find "$REPO_ROOT/tests" -path '*/bin/*' -name OrderKit.Tests.dll | head -n 1)")"
[ -d "$BIN" ] || exit 1
rm -rf "$BIN/__Saved" "$BIN/__Instrumented"
cd "$REPO_ROOT" || exit 1
dotnet altcover --save "--report=$OUT/altcover.xml" --reportFormat=NCover \
  '--assemblyFilter=.*\.Tests$' "--inputDirectory=$BIN" --inplace \
  > "$OUT/altcover.log" 2>&1 || exit 1
dotnet altcover Runner "--recorderDirectory=$BIN" --executable=dotnet -- \
  test "$BIN/OrderKit.Tests.dll" --nologo -v minimal >> "$OUT/altcover.log" 2>&1 || exit 1
[ -s "$OUT/altcover.xml" ] || exit 1
grep 'Visited Points' "$OUT/altcover.log" | tail -n 1
exit 0
