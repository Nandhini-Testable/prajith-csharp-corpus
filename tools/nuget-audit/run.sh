#!/usr/bin/env bash
# nuget-audit
set -uo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
. "$REPO_ROOT/tools/_skip.sh"

# --- why this tool has the status it has on this family -------------------
# Paket.Restore.targets turns paket.lock into PackageReference items at restore, so `dotnet list package --vulnerable` reads the planted pins like any other project. `--no-restore` is left out: an 8.0 SDK rejects it and prints its help text instead of a report.

require_restore
OUT="$(report_dir)/vulnerable.json"
dotnet list "$REPO_ROOT/OrderKit.sln" package --vulnerable --include-transitive \
  --format json > "$OUT" 2>/dev/null || exit 1
python3 - "$OUT" <<'PY'
import json, sys
doc = json.load(open(sys.argv[1], encoding="utf-8-sig"))
hits = set()
for project in doc.get("projects", []):
    for fw in project.get("frameworks", []):
        for pkg in fw.get("topLevelPackages", []) + fw.get("transitivePackages", []):
            if pkg.get("vulnerabilities"):
                hits.add((pkg["id"], pkg["resolvedVersion"]))
if not hits:
    sys.exit("STRUCTURALLY ZERO: no vulnerable package reported. Five are planted; "
             "an empty list means the advisory feed was not read.")
print("nuget-audit: %d vulnerable packages" % len(hits))
PY
exit $?
