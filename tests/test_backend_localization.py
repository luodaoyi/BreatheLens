from __future__ import annotations

import os
import sys
import unittest
import importlib
import importlib.util
from ctypes.util import find_library


os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")


def _build_result():
    parser_module = importlib.import_module("resmed_analyzer.parser")
    AnalysisResult = parser_module.AnalysisResult
    StrDay = parser_module.StrDay
    result = AnalysisResult(folder="/tmp/mock")
    result.device_name = "ResMed AirSense"
    result.serial = "123456"
    result.range_start = "2026-01-01"
    result.range_end = "2026-01-31"
    result.edf_count = 10
    result.summary.update(
        {
            "year_days": 30,
            "year_avg_usage_hr": 6.1,
            "year_avg_ahi": 2.8,
            "year_avg_leak95": 9.2,
            "last30_avg_ahi": 3.1,
            "last30_avg_leak95": 10.4,
            "last30_leak_over24_days": 1,
            "last30_avg_pressure95": 9.8,
            "last30_avg_cai": 1.4,
            "current_min_pressure": 6.0,
            "current_max_pressure": 12.0,
            "current_epr": 2.0,
            "current_humidity": 4.0,
        }
    )
    result.str_days = [
        StrDay(
            date="2026-01-01",
            duration_min=360,
            usage_hr=6.0,
            ahi=2.2,
            ai=1.0,
            hi=1.2,
            oai=0.8,
            cai=0.3,
            uai=0.0,
            leak95_lmin=8.0,
            leak50_lmin=4.0,
            leakmax_lmin=16.0,
            pressure95=9.5,
            pressure50=8.2,
            min_pressure=6.0,
            max_pressure=12.0,
            epr_level=2.0,
            humidity=4.0,
            tube_temp_c=27.0,
            csr_min=0.0,
        )
    ]
    return result


class BackendLocalizationTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        if importlib.util.find_spec("PySide6") is None or find_library("GL") is None:
            raise unittest.SkipTest("PySide6/OpenGL runtime not available in this environment")
        qgui = importlib.import_module("PySide6.QtGui").QGuiApplication
        cls._app = qgui.instance() or qgui(sys.argv)

    def test_language_switch_updates_summary_and_export_suggestions(self) -> None:
        Backend = importlib.import_module("resmed_analyzer.backend").Backend
        backend = Backend()
        backend._on_analysis_finished(_build_result())

        self.assertIn("设备：", backend.summary)
        self.assertIsNotNone(backend._result)
        assert backend._result is not None
        self.assertTrue(any("AHI 参考" in line for line in backend._result.suggestions))

        backend.setLanguage("en")

        self.assertEqual("en", backend.language)
        self.assertIn("Device:", backend.summary)
        self.assertIn("AHI reference", backend.suggestions)
        self.assertTrue(any("AHI reference" in line for line in backend._result.suggestions))


if __name__ == "__main__":
    unittest.main()
