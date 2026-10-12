#!/usr/bin/env bash
# stryker
set -uo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
. "$REPO_ROOT/tools/_skip.sh"

# --- why this tool has the status it has on this family -------------------
# MEASURED, not assumed: dotnet-stryker 4.0.0 (the pin in .config/dotnet-tools.json) restores and analyses this solution, then aborts with 'Stryker.NET could not compile the project after mutation'. Its bundled Roslyn predates C# 14 and rejects the `field` keyword in Diagnostics.cs, so no mutation report is written. A language-version limit of that Stryker release, not a setup gap. Also: the sheet makes it primary for 16 Data Flow metrics, which it cannot compute -- see roslyn-dataflow.
skip "dotnet-stryker 4.0.0 cannot compile C# 14 sources after mutation"

exit 0
