from __future__ import annotations

from pathlib import Path
import traceback

from PySide6.QtCore import QObject, Property, Signal, Slot, QUrl

from .exporter import export_excel
from .models import SimpleTableModel
from .parser import AnalysisResult, parse_folder


class Backend(QObject):
    busyChanged = Signal()
    statusChanged = Signal()
    summaryChanged = Signal()
    suggestionsChanged = Signal()
    folderChanged = Signal()

    def __init__(self) -> None:
        super().__init__()
        self._busy = False
        self._status = "请选择瑞思迈 SD 卡数据文件夹。"
        self._summary = "未分析"
        self._suggestions = ""
        self._folder = ""
        self._result: AnalysisResult | None = None
        self.tableModel = SimpleTableModel()

    def _set_busy(self, value: bool) -> None:
        if self._busy != value:
            self._busy = value
            self.busyChanged.emit()

    def _set_status(self, value: str) -> None:
        self._status = value
        self.statusChanged.emit()

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

    @Slot(str)
    def analyze(self, folder_url: str) -> None:
        folder = self._url_to_path(folder_url)
        if not folder:
            self._set_status("未选择目录。")
            return
        self._set_busy(True)
        self._set_status("正在解析 EDF 数据...")
        try:
            result = parse_folder(folder)
            self._result = result
            self._folder = result.folder
            self.folderChanged.emit()
            self._summary = self._make_summary(result)
            self.summaryChanged.emit()
            self._suggestions = "\n".join(f"{i + 1}. {x}" for i, x in enumerate(result.suggestions))
            self.suggestionsChanged.emit()
            self.tableModel.set_table(
                [
                    "日期",
                    "使用(h)",
                    "AHI",
                    "CAI",
                    "OAI",
                    "95%漏气",
                    "95%压力",
                    "最小压",
                    "最大压",
                ],
                [
                    [
                        d.date,
                        d.usage_hr,
                        d.ahi,
                        d.cai,
                        d.oai,
                        d.leak95_lmin,
                        d.pressure95,
                        d.min_pressure,
                        d.max_pressure,
                    ]
                    for d in result.str_days
                ],
            )
            self._set_status(f"解析完成：{len(result.str_days)} 条汇总日，{len(result.data_days)} 个 DATALOG 使用日。")
        except Exception as exc:
            self._set_status(f"解析失败：{exc}")
            traceback.print_exc()
        finally:
            self._set_busy(False)

    @Slot(str)
    def exportExcel(self, folder_url: str = "") -> None:
        if self._result is None:
            self._set_status("请先分析数据。")
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
