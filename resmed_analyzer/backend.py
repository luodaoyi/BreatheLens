from __future__ import annotations

from pathlib import Path
import traceback

from PySide6.QtCore import QObject, Property, Signal, Slot, QThread, QUrl

from .exporter import export_excel
from .models import SimpleTableModel
from .parser import AnalysisResult, parse_folder


class AnalysisWorker(QObject):
    progress = Signal(int, str)
    finished = Signal(object)
    failed = Signal(str)

    def __init__(self, folder: str) -> None:
        super().__init__()
        self._folder = folder

    @Slot()
    def run(self) -> None:
        try:
            result = parse_folder(self._folder, progress=lambda value, message: self.progress.emit(value, message))
            self.finished.emit(result)
        except Exception as exc:
            traceback.print_exc()
            self.failed.emit(str(exc))


class Backend(QObject):
    busyChanged = Signal()
    statusChanged = Signal()
    summaryChanged = Signal()
    suggestionsChanged = Signal()
    folderChanged = Signal()
    progressChanged = Signal()
    tableHeadersChanged = Signal()
    tableTitleChanged = Signal()
    chartSeriesChanged = Signal()

    def __init__(self) -> None:
        super().__init__()
        self._busy = False
        self._status = "请选择瑞思迈 SD 卡数据文件夹。"
        self._summary = "未分析"
        self._suggestions = ""
        self._folder = ""
        self._progress = 0
        self._table_headers: list[str] = []
        self._table_title = "每日汇总"
        self._table_mode = 0
        self._chart_series: list[dict] = []
        self._result: AnalysisResult | None = None
        self._thread: QThread | None = None
        self._worker: AnalysisWorker | None = None
        self.tableModel = SimpleTableModel()

    def _set_busy(self, value: bool) -> None:
        if self._busy != value:
            self._busy = value
            self.busyChanged.emit()

    def _set_status(self, value: str) -> None:
        self._status = value
        self.statusChanged.emit()

    def _set_progress(self, value: int) -> None:
        value = max(0, min(100, int(value)))
        if self._progress != value:
            self._progress = value
            self.progressChanged.emit()

    @Property(bool, notify=busyChanged)
    def busy(self) -> bool:
        return self._busy

    @Property(str, notify=statusChanged)
    def status(self) -> str:
        return self._status

    @Property(str, notify=summaryChanged)
    def summary(self) -> str:
        return self._summary

    @Property(str, notify=suggestionsChanged)
    def suggestions(self) -> str:
        return self._suggestions

    @Property(str, notify=folderChanged)
    def folder(self) -> str:
        return self._folder

    @Property(int, notify=progressChanged)
    def progress(self) -> int:
        return self._progress

    @Property("QVariantList", notify=tableHeadersChanged)
    def tableHeaders(self) -> list[str]:
        return self._table_headers

    @Property(str, notify=tableTitleChanged)
    def tableTitle(self) -> str:
        return self._table_title

    @Property("QVariantList", notify=chartSeriesChanged)
    def chartSeries(self) -> list[dict]:
        return self._chart_series

    @Slot(str)
    def analyze(self, folder_url: str) -> None:
        folder = self._url_to_path(folder_url)
        if not folder:
            self._set_status("未选择目录。")
            return
        if self._busy:
            return
        self._set_busy(True)
        self._set_progress(0)
        self._set_status("正在启动分析线程...")
        self._thread = QThread()
        self._worker = AnalysisWorker(folder)
        self._worker.moveToThread(self._thread)
        self._thread.started.connect(self._worker.run)
        self._worker.progress.connect(self._on_analysis_progress)
        self._worker.finished.connect(self._on_analysis_finished)
        self._worker.failed.connect(self._on_analysis_failed)
        self._worker.finished.connect(self._thread.quit)
        self._worker.failed.connect(self._thread.quit)
        self._thread.finished.connect(self._worker.deleteLater)
        self._thread.finished.connect(self._thread.deleteLater)
        self._thread.finished.connect(self._clear_worker_refs)
        self._thread.start()

    @Slot(str)
    def exportExcel(self, folder_url: str = "") -> None:
        if self._result is None:
            self._set_status("请先分析数据。")
            return
        if self._busy:
            self._set_status("当前正在分析，请稍后再导出。")
            return
        target_dir = self._url_to_path(folder_url) if folder_url else str(Path(self._result.folder) / "outputs")
        if not target_dir:
            target_dir = str(Path(self._result.folder) / "outputs")
        self._set_busy(True)
        try:
            output = Path(target_dir) / "resmed_analysis_gui.xlsx"
            export_excel(self._result, output)
            self._set_status(f"Excel 已导出：{output}")
        except Exception as exc:
            self._set_status(f"导出失败：{exc}")
            traceback.print_exc()
        finally:
            self._set_busy(False)

    @Slot(int)
    def setTableMode(self, mode: int) -> None:
        self._table_mode = int(mode)
        self._refresh_table()

    @Slot(int, str)
    def _on_analysis_progress(self, value: int, message: str) -> None:
        self._set_progress(value)
        self._set_status(message)

    @Slot(object)
    def _on_analysis_finished(self, result: AnalysisResult) -> None:
        self._result = result
        self._folder = result.folder
        self.folderChanged.emit()
        self._summary = self._make_summary(result)
        self.summaryChanged.emit()
        self._suggestions = "\n".join(f"{i + 1}. {x}" for i, x in enumerate(result.suggestions))
        self.suggestionsChanged.emit()
        self._chart_series = self._make_chart_series(result)
        self.chartSeriesChanged.emit()
        self._table_mode = 0
        self._refresh_table()
        self._set_progress(100)
        self._set_status(f"解析完成：{len(result.str_days)} 条汇总日，{len(result.data_days)} 个 DATALOG 使用日。")
        self._set_busy(False)

    @Slot(str)
    def _on_analysis_failed(self, message: str) -> None:
        self._set_status(f"解析失败：{message}")
        self._set_busy(False)

    @Slot()
    def _clear_worker_refs(self) -> None:
        self._thread = None
        self._worker = None

    def _set_table(self, title: str, headers: list[str], rows: list[list]) -> None:
        self._table_title = title
        self.tableTitleChanged.emit()
        self._table_headers = headers
        self.tableHeadersChanged.emit()
        self.tableModel.set_table(headers, rows)

    def _refresh_table(self) -> None:
        if self._result is None:
            self._set_table("每日汇总", [], [])
            return
        if self._table_mode == 1:
            self._set_table(
                "DATALOG 会话与事件",
                ["日期", "使用(h)", "时长(min)", "会话", "事件", "估算AHI", "CA", "OA", "H", "UA", "跳过"],
                [
                    [d.date, d.usage_hr, d.duration_min, d.sessions, d.total_events, d.estimated_ahi, d.central_apnea, d.obstructive_apnea, d.hypopnea, d.apnea, d.skipped_files]
                    for d in self._result.data_days
                ],
            )
            return
        if self._table_mode == 2:
            leak_days = [d for d in self._result.str_days if d.leak95_lmin >= 24]
            self._set_table(
                "漏气观察",
                ["日期", "95%漏气", "AHI", "使用(h)", "95%压力", "CAI", "OAI"],
                [[d.date, d.leak95_lmin, d.ahi, d.usage_hr, d.pressure95, d.cai, d.oai] for d in leak_days],
            )
            return
        self._set_table(
            "STR 每日汇总",
            ["日期", "使用(h)", "AHI", "CAI", "OAI", "95%漏气", "95%压力", "最小压", "最大压"],
            [
                [d.date, d.usage_hr, d.ahi, d.cai, d.oai, d.leak95_lmin, d.pressure95, d.min_pressure, d.max_pressure]
                for d in self._result.str_days
            ],
        )

    @staticmethod
    def _make_chart_series(result: AnalysisResult) -> list[dict]:
        days = result.str_days[-180:]

        def points(getter) -> list[dict]:
            return [{"date": d.date, "label": d.date[5:], "value": round(float(getter(d)), 2)} for d in days]

        return [
            {"title": "AHI 趋势", "unit": "次/小时", "color": "#07C160", "warning": 5.0, "points": points(lambda d: d.ahi)},
            {"title": "95%漏气趋势", "unit": "L/min", "color": "#E11D48", "warning": 24.0, "points": points(lambda d: d.leak95_lmin)},
            {"title": "95%压力趋势", "unit": "cmH2O", "color": "#2563EB", "warning": 0.0, "points": points(lambda d: d.pressure95)},
        ]

    @staticmethod
    def _url_to_path(value: str) -> str:
        if not value:
            return ""
        url = QUrl(value)
        if url.isValid() and url.isLocalFile():
            return url.toLocalFile()
        return value

    @staticmethod
    def _make_summary(result: AnalysisResult) -> str:
        s = result.summary
        return (
            f"设备：{result.device_name}  SN：{result.serial}\n"
            f"范围：{result.range_start} 至 {result.range_end}，EDF {result.edf_count} 个，空文件 {len(result.zero_edfs)} 个。\n"
            f"近一年：{int(s.get('year_days', 0))} 天，平均使用 {float(s.get('year_avg_usage_hr', 0)):.2f} h，"
            f"AHI {float(s.get('year_avg_ahi', 0)):.2f}，95%漏气 {float(s.get('year_avg_leak95', 0)):.1f} L/min。\n"
            f"近30天：AHI {float(s.get('last30_avg_ahi', 0)):.2f}，95%漏气 {float(s.get('last30_avg_leak95', 0)):.1f} L/min，"
            f"漏气>=24 共 {int(s.get('last30_leak_over24_days', 0))} 天。\n"
            f"当前：压力 {float(s.get('current_min_pressure', 0)):.1f}-{float(s.get('current_max_pressure', 0)):.1f} cmH2O，"
            f"EPR {float(s.get('current_epr', 0)):.0f}，湿度 {float(s.get('current_humidity', 0)):.0f}。"
        )
