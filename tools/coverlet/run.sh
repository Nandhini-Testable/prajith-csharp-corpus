#!/usr/bin/env bash
# coverlet
set -uo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
. "$REPO_ROOT/tools/_skip.sh"

# --- why this tool has the status it has on this family -------------------
# coverlet.collector 6.0.0 is referenced by the test project, so `dotnet test --collect` produces Cobertura XML. Off Windows there is no .NET Framework test host, so the tests run on .NET 8 against the same build of the library.

require_restore
OUT="$(report_dir)"
dotnet test "$REPO_ROOT/OrderKit.sln" --no-restore --nologo \
  --collect:"XPlat Code Coverage" --results-directory "$OUT/coverlet" -v minimal \
  > "$OUT/coverlet.log" 2>&1 || exit 1
report="$(find "$OUT/coverlet" -name coverage.cobertura.xml | head -n 1)"
[ -n "$report" ] || exit 1
cp "$report" "$OUT/coverage.cobertura.xml"
grep -o '<coverage [^>]*' "$OUT/coverage.cobertura.xml" | head -n 1
exit 0
