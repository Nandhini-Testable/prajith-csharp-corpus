# OrderKit - CS_VNET5_SDKMSBUILD_CPM_MONO

One branch of the C# tool-evaluation corpus. Test **data**, not a product: tool
execution is not part of the build, and evaluation happens later.

## Branch

`CS_VNET5_SDKMSBUILD_CPM_MONO`

## Cell

| Axis | Value |
|---|---|
| Bundler | SDK-style MSBuild |
| Package manager | Central Package Management |
| Architecture | Monolith |

Projects:

- `OrderKit` (`src/OrderKit`)

## Target framework

`net5.0` - .NET 5

The unification release: one .NET, no more Core/Framework split, and the first target framework whose moniker drops the platform word entirely. Out of support since 8 May 2022. packages.config is still dead here, so six of the 24 cells remain impossible -- the grid's loss at the netcoreapp3.0 crossing was permanent, not transitional.

## Language version

C# 9.0, taken as the default of the target framework. `LangVersion` is deliberately
never written to any project file, which is what keeps the family axis one number
instead of two.

The domain layer is written to that language subset exactly, and the lock is
verified by execution rather than asserted:

```
csc -langversion:9.0   ->  clean
csc -langversion:8.0   ->  error CS8025: Feature 'async function' is not available
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
| dotnet list package --vulnerable | active | The planted pins are PackageReference items, so `dotnet list package --vulnerable` reads |
| Coverlet | active | coverlet.collector 6.0.0 is referenced by the test project, with its version in Director |
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
| Coverlet (`coverlet.collector`) | 6.0.0 | `Directory.Packages.props` |
| Microsoft.CodeAnalysis.NetAnalyzers | 8.0.0 | `Directory.Packages.props` |
| SonarAnalyzer.CSharp | 9.32.0.97167 | `Directory.Packages.props` |
| SecurityCodeScan.VS2019 | 5.6.7 | `Directory.Packages.props` |
| OpenTelemetry + OTLP exporter | 1.19.1 | `Directory.Packages.props` |
| AltCover (`altcover.global`) | 8.8.173 | `.config/dotnet-tools.json` |
| Stryker.NET (`dotnet-stryker`) | 4.0.0 | `.config/dotnet-tools.json` |
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
`api.nuget.org`. A bare `dotnet restore OrderKit.sln` is enough on a fresh clone.

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
