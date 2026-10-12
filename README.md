# OrderKit - CS_VNET7_DOTNETCLI_PAKET_MICRO

One branch of the C# tool-evaluation corpus. Test **data**, not a product: tool
execution is not part of the build, and evaluation happens later.

## Branch

`CS_VNET7_DOTNETCLI_PAKET_MICRO`

## Cell

| Axis | Value |
|---|---|
| Bundler | .NET CLI |
| Package manager | Paket |
| Architecture | Microservices |

Projects:

- `OrderKit.Domain` (`src/OrderKit.Domain`)
- `OrderKit.Contracts` (`src/OrderKit.Contracts`)
- `OrderKit.Pricing` (`src/Services/OrderKit.Pricing`)
- `OrderKit.Risk` (`src/Services/OrderKit.Risk`)
- `OrderKit.Reporting` (`src/Services/OrderKit.Reporting`)

## Target framework

`net7.0` - .NET 7

An STS release, out of support since 14 May 2024 -- earlier than the LTS below it, which is the point of the STS/LTS split and the only place in this corpus where a HIGHER target framework left support SOONER. packages.config remains dead, so six of the 24 cells stay impossible.

## Language version

C# 11.0, taken as the default of the target framework. `LangVersion` is deliberately
never written to any project file, which is what keeps the family axis one number
instead of two.

The domain layer is written to that language subset exactly, and the lock is
verified by execution rather than asserted:

```
csc -langversion:11.0   ->  clean
csc -langversion:10.0   ->  error CS8025: Feature 'async function' is not available
```

## Supported tools

12 of the 19 tools in the roster are expected to fire on this branch. The rest exit
3 (cannot run here) or 4 (absent from this host), each with its reason in both
`run.sh` and `trigger.yaml`.

**A tool that does not fire is a result, not a failure.** The source-level tools
below never load a compiler, so they remain the built-in negative control: if the
build-backed tools go dark, these still distinguish "correctly detected nothing"
from "the scan never ran".

- Lizard
- jscpd
- Semgrep
- PyDriller
- git log --numstat

| Tool | Status | Why |
|---|---|---|
| Lizard | active | Python tokeniser. Class B: own parser, never loads a compiler, so the TFM is irrelevant  |
| jscpd | active | Node, own tokeniser. Class B. |
| Dolos | not-installed | Node, tree-sitter C# grammar. Class B, and the sheet's declaration ('C# language-version |
| Semgrep | active | Python, tree-sitter C# grammar. Class B. |
| Opengrep | not-installed | Standalone binary, absent from this host. Class B when present. NOTE: the sheet declares |
| Trivy | not-installed | Standalone Go binary, absent from this host. Class C: reads manifests/lockfiles. |
| PyDriller | active | Python, reads git only. Class C: never touches the source language. |
| git log --numstat | active | stdlib git. Class C. Counts Co-authored-by trailers, not just the author field -- the Ty |
| diff-cover | active | Class C: reads Cobertura/OpenCover XML. Coverlet now produces one on this branch, so dif |
| Roslyn analyzers (cognitive complexity) | active | The sheet says 'Roslyn', which is a compiler platform, not a package. Resolved here to S |
| Roslyn SAST analyzers | active | The sheet says 'roslyn sast', also not a package. Resolved here to SecurityCodeScan.VS20 |
| Roslyn SemanticModel.AnalyzeDataFlow | not-installed | PROPOSED REPAIR, not in the source sheet. The sheet assigns Data Flow to Stryker.NET, a  |
| dotnet list package --vulnerable | active | Paket.Restore.targets turns paket.lock into PackageReference items at restore, so `dotne |
| Coverlet | active | coverlet.collector 6.0.0 is restored by Paket into the test project, so `dotnet test --c |
| AltCover | active | altcover.global 8.8.173 is pinned in .config/dotnet-tools.json. It instruments the built |
| MiniCover | skipped | MiniCover 3.10.0 declares .NET SDK 8.0/9.0/10.0 only -- verified against its own MiniCov |
| Stryker.NET | active | dotnet-stryker 4.0.0 is pinned in .config/dotnet-tools.json and mutates this family: it  |
| OpenTelemetry (.NET) + OTLP exporter | skipped | OpenTelemetry 1.19.1 and its OTLP exporter are restored into the test project, and Traci |
| unilyze | absent | NOT A TOOL. The only package of this name anywhere is PyPI `unilyze` 0.2.1, 'Get detaile |

## Tool versions

Tool pins follow the C# sheet of the Whitebox Tools Registry. `dataset.json`
`toolPins` is the machine-readable copy.

| Tool | Version | Declared in |
|---|---|---|
| Coverlet (`coverlet.collector`) | 6.0.0 | `paket.dependencies` |
| Microsoft.CodeAnalysis.NetAnalyzers | 8.0.0 | `paket.dependencies` |
| SonarAnalyzer.CSharp | 9.32.0.97167 | `paket.dependencies` |
| SecurityCodeScan.VS2019 | 5.6.7 | `paket.dependencies` |
| OpenTelemetry + OTLP exporter | 1.19.1 | `paket.dependencies` |
| AltCover (`altcover.global`) | 8.8.173 | `.config/dotnet-tools.json` |
| Stryker.NET (`dotnet-stryker`) | 4.0.0 | `.config/dotnet-tools.json` |
| Paket | 9.0.2 | `.config/dotnet-tools.json` |
| Lizard | 1.17.10 | scanning host |
| jscpd | 4.0.5 | scanning host |
| Semgrep | 1.50.0 | scanning host |
| PyDriller | 2.7 | scanning host |

Two pins are not the registry's own. It lists AltCover 8.8.0, which was never
published as a tool; 8.8.173 is the release of that line. It lists no version for
OpenTelemetry.

## Build

```bash
./build.sh
```

The prerequisites are a .NET SDK that satisfies `global.json` and access to
`api.nuget.org`. A bare `dotnet restore OrderKit.sln` is enough on a fresh clone:
`.paket/Paket.Restore.targets` restores the Paket tool from
`.config/dotnet-tools.json`, and Paket then restores the packages in `paket.lock`.

## Test

```bash
dotnet test OrderKit.sln
```

19 test methods are declared; NUnit expands them to 21 cases, all passing.

This runtime is out of support and rarely installed, so the test project sets
`RollForward` and its host starts on the nearest newer runtime.

## Tool entry points

```bash
python3 tools/tool_integration.py            # banner
python3 tools/tool_integration.py --verify   # every runner present and executable
python3 tools/tool_integration.py --run      # run them all, compare to dataset.json
python3 tools/full_check.py                  # cross-file consistency audit
```

## What is expected to fire

`dataset.json` asserts the answer rather than describing it, so a platform that
reports nothing for a given tool can be *proven* correct instead of assumed correct.
Every runner's expected exit code is recorded there, and
`tool_integration.py --run` exits **2** if any tool produces a result the dataset
does not already record - a new finding, as distinct from a measurement.
