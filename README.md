# OrderKit - CS_VNETCOREAPP30_DOTNETCLI_NUGETPACKAGESCONFIG_MICRO

One branch of the C# tool-evaluation corpus. Test **data**, not a product: tool
execution is not part of the build, and evaluation happens later.

> **This cell cannot exist.** `dotnet restore` has never supported packages.config. NuGet's packages.config path is implemented in MSBuild.exe / nuget.exe only.
>
> The branch ships the artifacts the cell definition demands, plus this notice. It is *not* quietly backed by a working configuration -- a branch labelled one thing that ran another underneath is the exact silent success this corpus exists to catch.

## Branch

`CS_VNETCOREAPP30_DOTNETCLI_NUGETPACKAGESCONFIG_MICRO`

## Cell

| Axis | Value |
|---|---|
| Bundler | .NET CLI |
| Package manager | NuGet (packages.config) |
| Architecture | Microservices |

Projects:

- `OrderKit.Domain` (`src/OrderKit.Domain`)
- `OrderKit.Contracts` (`src/OrderKit.Contracts`)
- `OrderKit.Pricing` (`src/Services/OrderKit.Pricing`)
- `OrderKit.Risk` (`src/Services/OrderKit.Risk`)
- `OrderKit.Reporting` (`src/Services/OrderKit.Reporting`)

## Target framework

`netcoreapp3.0` - .NET Core 3.0

In support until 3 March 2020, and above the netstandard2.0 boundary, so Coverlet and OpenTelemetry are held out by NuGet alone (exit 4) rather than by the target framework (exit 3). This is also the first target FIRST family off the .NET Framework line, and the crossing the netfx472 record predicted. packages.config does not exist on .NET Core at all, so SIX of the 24 cells are now impossible rather than four -- the grid did not survive the crossing intact, and that is the finding, not a defect. Out of support since 3 March 2020 (3.0 was superseded by 3.1 within months), which is why it is the shortest-lived target framework in the corpus.

## Language version

C# 8.0, taken as the default of the target framework. `LangVersion` is deliberately
never written to any project file, which is what keeps the family axis one number
instead of two.

The domain layer is written to that language subset exactly, and the lock is
verified by execution rather than asserted:

```
csc -langversion:8.0   ->  clean
csc -langversion:7.3   ->  error CS8025: Feature 'async function' is not available
```

## Supported tools

11 of the 19 tools in the roster are expected to fire on this branch. The rest exit
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
| dotnet list package --vulnerable | skipped | Requires PackageReference and an SDK-style project. Structurally impossible on the packa |
| Coverlet | active | coverlet.collector 6.0.0 is a PackageReference in the test project, since packages.confi |
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
| Coverlet (`coverlet.collector`) | 6.0.0 | the project files |
| Microsoft.CodeAnalysis.NetAnalyzers | 8.0.0 | the project files |
| SonarAnalyzer.CSharp | 9.32.0.97167 | the project files |
| SecurityCodeScan.VS2019 | 5.6.7 | the project files |
| OpenTelemetry + OTLP exporter | 1.19.1 | the project files |
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
`api.nuget.org`. The build and test tooling is declared as PackageReference, because an SDK-style
project cannot consume `packages.config`. The planted pins stay in
`packages.config` and stay inert: see `PACKAGES-CONFIG.INERT.md`.

## Test

```bash
dotnet test OrderKit.sln
```

19 test methods are declared; NUnit expands them to 21 cases, all passing.

The library is always built for the target framework above. No current test host
runs that framework, so the test project alone compiles for .NET 8 and exercises
that same build of the library.

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
