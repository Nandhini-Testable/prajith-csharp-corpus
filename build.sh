#!/usr/bin/env bash
set -euo pipefail
dotnet msbuild OrderKit.sln -t:Restore
dotnet msbuild OrderKit.sln -t:Build -p:Configuration=Release
dotnet test OrderKit.sln -c Release --no-build
