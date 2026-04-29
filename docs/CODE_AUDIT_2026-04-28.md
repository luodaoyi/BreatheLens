# BreatheLens Code Audit (2026-04-28)

## Scope

- Backend localization flow (`resmed_analyzer/backend.py`)
- Parser summary/suggestion generation (`resmed_analyzer/parser.py`)
- UI language bridge (`ui/Main.qml`)
- Current automated test setup (`tests/`, `pyproject.toml`)

## Checks Executed

1. `python -m compileall resmed_analyzer tests`
2. `pytest -q`
3. `uv run python -c "import PySide6; print(PySide6.__version__)"`
4. `uv run python -m pytest -q`

## Findings

### 1) Test pipeline is not reproducible in a clean environment (High)

- `pytest -q` fails in the base environment because `PySide6` is not available there.
- `uv run python -m pytest -q` fails because `pytest` is not installed in the uv environment.
- Root cause: `pyproject.toml` does not declare a development dependency group for testing tools.

**Impact**

- CI or local contributors cannot run tests consistently with a single documented command.
- Past claims of "all tests passed" are easy to become inaccurate across environments.

**Recommendation**

- Add a test dependency group (e.g. `pytest`) to `pyproject.toml`.
- Document a single canonical command, for example:
  - `uv sync --group dev`
  - `uv run python -m pytest -q`

---

### 2) Mixed localization responsibilities between parser and backend (Medium)

- Parser still builds Chinese `result.suggestions`.
- Backend overwrites suggestions based on selected UI language.

**Impact**

- Logic duplication and possible drift in suggestion content.
- Unclear source of truth for "final suggestions".

**Recommendation**

- Keep parser responsible for metrics only.
- Centralize human-readable suggestion text generation in backend (or in one dedicated i18n module).

---

### 3) Runtime status/progress text remains Chinese-only (Medium)

- Several backend status paths still emit hardcoded Chinese strings.
- UI localizes one initial status in QML, but dynamic status/progress strings from backend remain untranslated.

**Impact**

- In non-Chinese UI modes, users still see mixed-language runtime feedback.

**Recommendation**

- Introduce backend status keys + i18n table, or emit structured status codes and localize in QML.

## Audit Conclusion

- The codebase now has meaningful unit + UI test coverage additions.
- Main residual risk is **test execution reproducibility** across environments.
- Secondary risk is **localization architecture consistency** (parser/backend split and runtime status text).

## Follow-up Audit Update (Round 2)

- Converted automated tests from `pytest` style fixtures to `unittest` so GUI/unit tests can run without requiring `pytest` in the runtime environment.
- Kept tests headless via `QT_QPA_PLATFORM=offscreen` in each test module.
- Added environment guards so tests are skipped (not failed) when OpenGL runtime (`libGL.so.1`) is unavailable in minimal containers.
- Recommended canonical command updated to:
  - `uv run python -m unittest discover -s tests -p "test_*.py"`
