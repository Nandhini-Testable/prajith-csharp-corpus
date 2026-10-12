#!/usr/bin/env bash
# stryker
set -uo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
. "$REPO_ROOT/tools/_skip.sh"

# --- why this tool has the status it has on this family -------------------
# MEASURED, not assumed: dotnet-stryker 4.0.0 (the pin in .config/dotnet-tools.json) restores and analyses this solution, then aborts with 'Stryker.NET could not compile the project after mutation'. Its bundled Roslyn predates C# 13 and rejects the newer syntax in the domain layer. No mutation report is written. A limit of that Stryker release on this family, not a setup gap. Also: the sheet makes it primary for 16 Data Flow metrics, which it cannot compute -- see roslyn-dataflow.
skip "dotnet-stryker 4.0.0 cannot compile C# 13 sources after mutation"

exit 0
