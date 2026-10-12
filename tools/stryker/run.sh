#!/usr/bin/env bash
# stryker
set -uo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
. "$REPO_ROOT/tools/_skip.sh"

# --- why this tool has the status it has on this family -------------------
# MEASURED, not assumed: dotnet-stryker 4.0.0 (the pin in .config/dotnet-tools.json) stops at 'Initial build failed'. For a .NET Framework project it shells out to the legacy MSBuild 4.8, which cannot load an SDK-style project (MSB4041), and off Windows that MSBuild does not exist at all. No mutation report is written. A limit of Stryker on this family, not a setup gap. Also: the sheet makes it primary for 16 Data Flow metrics, which it cannot compute -- see roslyn-dataflow.
skip "dotnet-stryker 4.0.0 cannot build an SDK-style .NET Framework project"

exit 0
