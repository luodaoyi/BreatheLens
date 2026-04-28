# BreatheLens

BreatheLens is a local ResMed CPAP / APAP SD card analyzer. It reads the original SD card folder from a ResMed device, parses EDF files, and turns therapy data into daily tables, trend charts, leak review sheets, Excel reports, and pressure-adjustment suggestions.

The project is built for people who need a quick first look at ResMed data without uploading anything to a cloud service and without importing an OSCAR database. Select the folder that contains `STR.edf`, `DATALOG`, and `SETTINGS`, then analyze it locally.

## Languages

English is the default README. Full README files are also available in the same languages supported by the application UI.

| Language | README |
| --- | --- |
| English | [README.md](README.md) |
| 中文 | [docs/i18n/README.zh.md](docs/i18n/README.zh.md) |
| Deutsch | [docs/i18n/README.de.md](docs/i18n/README.de.md) |
| Français | [docs/i18n/README.fr.md](docs/i18n/README.fr.md) |
| Русский | [docs/i18n/README.ru.md](docs/i18n/README.ru.md) |
| Español | [docs/i18n/README.es.md](docs/i18n/README.es.md) |
| Português | [docs/i18n/README.pt.md](docs/i18n/README.pt.md) |
| 日本語 | [docs/i18n/README.ja.md](docs/i18n/README.ja.md) |
| 한국어 | [docs/i18n/README.ko.md](docs/i18n/README.ko.md) |
| العربية | [docs/i18n/README.ar.md](docs/i18n/README.ar.md) |

## Screenshots

The main screen provides a data overview, adjustment suggestions, language switching, and folder selection.

![BreatheLens main screen](docs/images/1.png)

Trend charts include a time axis. Hover over a point to inspect the date and value.

![BreatheLens charts](docs/images/2.png)

The STR daily summary table is useful for long-term therapy trends, pressure, leak, and AHI details.

![BreatheLens STR summary](docs/images/3.png)

The DATALOG page shows session duration and event statistics.

![BreatheLens DATALOG](docs/images/4.png)

The leak watch page helps identify high-leak days that should be checked first.

![BreatheLens leak watch](docs/images/5.png)

## Features

- Select a ResMed SD card data folder.
- Detect device model and serial number.
- Parse `STR.edf` daily therapy summaries.
- Parse `DATALOG/*_PLD.edf` session duration data.
- Parse `DATALOG/*_EVE.edf` respiratory event annotations.
- Show daily usage, AHI, CAI, OAI, 95% leak, and 95% pressure.
- Switch the UI language directly: Chinese, English, German, French, Russian, Spanish, Portuguese, Japanese, Korean, and Arabic.
- Parse large folders on a background thread while the UI stays responsive and shows live progress.
- Display built-in trend charts for AHI, 95% leak, and 95% pressure.
- Provide STR summary, DATALOG session/event details, and leak watch tables.
- Generate adjustment suggestions by checking leak priority, pressure ceiling behavior, and elevated central events.
- Export Excel workbooks with `Summary`, `STR_Daily`, `DATALOG_Daily`, `Leak_Watch`, `Suggestions`, and `Codebook` sheets.
- Provide a PySide6 + QML desktop UI with a simple green visual style.
- Build a single-file executable with Nuitka.

## Data Files

BreatheLens mainly reads these files:

| File | Purpose |
| --- | --- |
| `Identification.tgt` | Device model and serial number |
| `STR.edf` | Daily therapy summary, including AHI, leak, pressure, and settings |
| `DATALOG/*_PLD.edf` | Session duration and low-frequency therapy signals |
| `DATALOG/*_EVE.edf` | Respiratory event annotations |

Suggestions in the report are based on data trends. They are not a medical diagnosis and cannot replace professional care. If central apnea index stays high, oxygen levels are low at night, chest tightness or palpitations occur, or daytime sleepiness is obvious, take the original data to a clinician.

## Development

```powershell
uv venv .venv
uv sync
uv run python main.py
```

## Local Build

```powershell
uv run python build.py
```

Build output is written to `dist/`, for example:

```text
dist/BreatheLens.exe
dist/BreatheLens-windows-x64.zip
```

## GitHub Actions Release

The repository includes `.github/workflows/release.yml`.

- Pushing a `v*` tag builds and publishes a release.
- GitHub-hosted runners build:
  - Windows x64
  - Windows x86
  - Windows ARM64
  - macOS Apple Silicon arm64
  - macOS Intel x64
  - Linux x64
  - Linux ARM64
- Other platforms need self-hosted runners:
  - Linux x86: `self-hosted, linux, X86`
  - Linux LoongArch64: `self-hosted, linux, LoongArch64`

When manually running the workflow, enable `build_self_hosted` to build those self-hosted platforms. Nuitka + PySide6 should be compiled on the target operating system and architecture; without a matching runner, GitHub Actions cannot reliably cross-compile a Qt GUI application.

Release by tag:

```bash
git tag v0.1.0
git push origin v0.1.0
```

You can also run the workflow manually and provide `release_tag`, for example `v0.1.0`.

## License

MIT License. See [LICENSE](LICENSE).
