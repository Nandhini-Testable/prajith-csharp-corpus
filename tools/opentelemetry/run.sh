#!/usr/bin/env bash
# opentelemetry
set -uo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
. "$REPO_ROOT/tools/_skip.sh"

# --- why this tool has the status it has on this family -------------------
# OpenTelemetry 1.19.1 and its OTLP exporter are restored into the test project, and TracingSetup.cs in the test project wraps the run in a trace. Spans leave the process only when a collector is named; with none the export is dropped, which would be a structurally zero result. Note separately that tracing is not path coverage.

[ -n "${OTEL_EXPORTER_OTLP_ENDPOINT:-}" ] \
  || skip "OTEL_EXPORTER_OTLP_ENDPOINT is not set; spans would be exported nowhere"
require_restore
dotnet test "$REPO_ROOT/OrderKit.sln" --no-restore --nologo -v minimal \
  > "$(report_dir)/opentelemetry.log" 2>&1 || exit 1
exit 0
