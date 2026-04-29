from __future__ import annotations

import os
import sys
import unittest
import importlib
import importlib.util
from pathlib import Path
from ctypes.util import find_library


os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")


class MainQmlTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        if importlib.util.find_spec("PySide6") is None or find_library("GL") is None:
            raise unittest.SkipTest("PySide6/OpenGL runtime not available in this environment")
        qgui = importlib.import_module("PySide6.QtGui").QGuiApplication
        cls._app = qgui.instance() or qgui(sys.argv)

    def test_main_qml_loads_and_language_bridge_works(self) -> None:
        qtcore = importlib.import_module("PySide6.QtCore")
        qml = importlib.import_module("PySide6.QtQml")
        Backend = importlib.import_module("resmed_analyzer.backend").Backend
        Q_ARG = qtcore.Q_ARG
        QMetaObject = qtcore.QMetaObject
        Qt = qtcore.Qt
        QQmlApplicationEngine = qml.QQmlApplicationEngine

        backend = Backend()
        engine = QQmlApplicationEngine()
        engine.rootContext().setContextProperty("backend", backend)
        engine.rootContext().setContextProperty("tableModel", backend.tableModel)

        qml_path = Path(__file__).resolve().parents[1] / "ui" / "Main.qml"
        engine.load(str(qml_path))
        self.assertTrue(engine.rootObjects(), "QML root object failed to load")

        root = engine.rootObjects()[0]
        ok = QMetaObject.invokeMethod(root, "applyLanguage", Qt.ConnectionType.DirectConnection, Q_ARG("QString", "en"))
        self.assertTrue(ok)
        self.assertEqual("en", backend.language)


if __name__ == "__main__":
    unittest.main()
