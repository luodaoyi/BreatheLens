from __future__ import annotations

from pathlib import Path
import os
import sys
import traceback

from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication, QIcon
from PySide6.QtQml import QQmlApplicationEngine

from .backend import Backend


APP_NAME = "BreatheLens"


def resource_path(*parts: str) -> Path:
    roots: list[Path] = []
    frozen_root = getattr(sys, "_MEIPASS", None)
    if frozen_root:
        roots.append(Path(frozen_root))
    roots.extend(
        [
            Path(__file__).resolve().parents[1],
            Path(sys.executable).resolve().parent,
            Path.cwd(),
        ]
    )
    for root in roots:
        candidate = root.joinpath(*parts)
        if candidate.exists():
            return candidate
    return roots[0].joinpath(*parts)


def log_startup_error(message: str) -> None:
    log_dir = Path(os.environ.get("LOCALAPPDATA", Path.home())) / APP_NAME / "logs"
    log_dir.mkdir(parents=True, exist_ok=True)
    (log_dir / "startup.log").write_text(message, encoding="utf-8")


def main() -> int:
    os.environ.setdefault("QT_QUICK_CONTROLS_STYLE", "Basic")
    try:
        app = QGuiApplication(sys.argv)
        app.setApplicationName(APP_NAME)
        app.setOrganizationName("Local")

        icon = resource_path("ui", "app.ico")
        if icon.exists():
            app.setWindowIcon(QIcon(str(icon)))

        backend = Backend()
        engine = QQmlApplicationEngine()
        engine.rootContext().setContextProperty("backend", backend)
        engine.rootContext().setContextProperty("tableModel", backend.tableModel)
        qml = resource_path("ui", "Main.qml")
        engine.load(QUrl.fromLocalFile(str(qml)))
        if not engine.rootObjects():
            log_startup_error(f"QML 加载失败：{qml}")
            return 1
        return app.exec()
    except Exception:
        log_startup_error(traceback.format_exc())
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
