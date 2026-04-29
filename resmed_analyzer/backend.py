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
    languageChanged = Signal()

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
        self._language = "zh"
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

    @Property(str, notify=languageChanged)
    def language(self) -> str:
        return self._language

    @Slot(str)
    def setLanguage(self, code: str) -> None:
        supported = {"zh", "en", "de", "fr", "ru", "es", "pt", "ja", "ko", "ar"}
        value = (code or "zh").strip().lower()
        if value not in supported:
            value = "en"
        if self._language == value:
            return
        self._language = value
        self.languageChanged.emit()
        if self._result is None:
            return
        localized_suggestions = self._make_suggestions(self._result, self._language)
        self._result.suggestions = localized_suggestions
        self._summary = self._make_summary(self._result, self._language)
        self.summaryChanged.emit()
        self._suggestions = "\n".join(f"{i + 1}. {x}" for i, x in enumerate(localized_suggestions))
        self.suggestionsChanged.emit()

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
        localized_suggestions = self._make_suggestions(result, self._language)
        self._result.suggestions = localized_suggestions
        self._summary = self._make_summary(result, self._language)
        self.summaryChanged.emit()
        self._suggestions = "\n".join(f"{i + 1}. {x}" for i, x in enumerate(localized_suggestions))
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
    def _make_summary(result: AnalysisResult, language: str = "zh") -> str:
        s = result.summary
        summary_templates = {
            "zh": (
                "设备：{device}  SN：{serial}\n"
                "范围：{start} 至 {end}，EDF {edf} 个，空文件 {zero} 个。\n"
                "近一年：{days} 天，平均使用 {usage:.2f} h，AHI {ahi:.2f}，95%漏气 {leak:.1f} L/min。\n"
                "近30天：AHI {ahi30:.2f}，95%漏气 {leak30:.1f} L/min，漏气>=24 共 {leak_days} 天。\n"
                "当前：压力 {min_p:.1f}-{max_p:.1f} cmH2O，EPR {epr:.0f}，湿度 {humidity:.0f}。"
            ),
            "en": (
                "Device: {device}  SN: {serial}\n"
                "Range: {start} to {end}, EDF files: {edf}, zero-byte files: {zero}.\n"
                "Last year: {days} days, average usage {usage:.2f} h, AHI {ahi:.2f}, 95% leak {leak:.1f} L/min.\n"
                "Last 30 days: AHI {ahi30:.2f}, 95% leak {leak30:.1f} L/min, leak>=24 on {leak_days} days.\n"
                "Current: pressure {min_p:.1f}-{max_p:.1f} cmH2O, EPR {epr:.0f}, humidity {humidity:.0f}."
            ),
            "de": (
                "Gerät: {device}  SN: {serial}\n"
                "Zeitraum: {start} bis {end}, EDF-Dateien: {edf}, leere Dateien: {zero}.\n"
                "Letztes Jahr: {days} Tage, Nutzung Ø {usage:.2f} h, AHI {ahi:.2f}, 95%-Leck {leak:.1f} L/min.\n"
                "Letzte 30 Tage: AHI {ahi30:.2f}, 95%-Leck {leak30:.1f} L/min, Leck>=24 an {leak_days} Tagen.\n"
                "Aktuell: Druck {min_p:.1f}-{max_p:.1f} cmH2O, EPR {epr:.0f}, Befeuchtung {humidity:.0f}."
            ),
            "fr": (
                "Appareil : {device}  SN : {serial}\n"
                "Période : {start} à {end}, fichiers EDF : {edf}, fichiers vides : {zero}.\n"
                "Sur 1 an : {days} jours, usage moyen {usage:.2f} h, AHI {ahi:.2f}, fuite 95% {leak:.1f} L/min.\n"
                "30 derniers jours : AHI {ahi30:.2f}, fuite 95% {leak30:.1f} L/min, fuite>=24 pendant {leak_days} jours.\n"
                "Actuel : pression {min_p:.1f}-{max_p:.1f} cmH2O, EPR {epr:.0f}, humidité {humidity:.0f}."
            ),
            "ru": (
                "Устройство: {device}  SN: {serial}\n"
                "Период: {start}–{end}, EDF файлов: {edf}, пустых файлов: {zero}.\n"
                "За год: {days} дней, среднее использование {usage:.2f} ч, AHI {ahi:.2f}, утечка 95% {leak:.1f} L/min.\n"
                "За 30 дней: AHI {ahi30:.2f}, утечка 95% {leak30:.1f} L/min, утечка>=24 в течение {leak_days} дней.\n"
                "Сейчас: давление {min_p:.1f}-{max_p:.1f} cmH2O, EPR {epr:.0f}, влажность {humidity:.0f}."
            ),
            "es": (
                "Dispositivo: {device}  SN: {serial}\n"
                "Rango: {start} a {end}, archivos EDF: {edf}, archivos vacíos: {zero}.\n"
                "Último año: {days} días, uso medio {usage:.2f} h, AHI {ahi:.2f}, fuga 95% {leak:.1f} L/min.\n"
                "Últimos 30 días: AHI {ahi30:.2f}, fuga 95% {leak30:.1f} L/min, fuga>=24 en {leak_days} días.\n"
                "Actual: presión {min_p:.1f}-{max_p:.1f} cmH2O, EPR {epr:.0f}, humedad {humidity:.0f}."
            ),
            "pt": (
                "Dispositivo: {device}  SN: {serial}\n"
                "Período: {start} a {end}, arquivos EDF: {edf}, arquivos vazios: {zero}.\n"
                "Último ano: {days} dias, uso médio {usage:.2f} h, AHI {ahi:.2f}, fuga 95% {leak:.1f} L/min.\n"
                "Últimos 30 dias: AHI {ahi30:.2f}, fuga 95% {leak30:.1f} L/min, fuga>=24 em {leak_days} dias.\n"
                "Atual: pressão {min_p:.1f}-{max_p:.1f} cmH2O, EPR {epr:.0f}, umidade {humidity:.0f}."
            ),
            "ja": (
                "機器: {device}  SN: {serial}\n"
                "期間: {start} ～ {end}、EDFファイル {edf} 件、空ファイル {zero} 件。\n"
                "直近1年: {days}日、平均使用 {usage:.2f} 時間、AHI {ahi:.2f}、95%リーク {leak:.1f} L/min。\n"
                "直近30日: AHI {ahi30:.2f}、95%リーク {leak30:.1f} L/min、リーク>=24 は {leak_days} 日。\n"
                "現在: 圧力 {min_p:.1f}-{max_p:.1f} cmH2O、EPR {epr:.0f}、加湿 {humidity:.0f}。"
            ),
            "ko": (
                "장치: {device}  SN: {serial}\n"
                "범위: {start} ~ {end}, EDF 파일 {edf}개, 빈 파일 {zero}개.\n"
                "최근 1년: {days}일, 평균 사용 {usage:.2f}시간, AHI {ahi:.2f}, 95% 누출 {leak:.1f} L/min.\n"
                "최근 30일: AHI {ahi30:.2f}, 95% 누출 {leak30:.1f} L/min, 누출>=24인 날 {leak_days}일.\n"
                "현재: 압력 {min_p:.1f}-{max_p:.1f} cmH2O, EPR {epr:.0f}, 습도 {humidity:.0f}."
            ),
            "ar": (
                "الجهاز: {device}  SN: {serial}\n"
                "النطاق: {start} إلى {end}، ملفات EDF: {edf}، الملفات الفارغة: {zero}.\n"
                "آخر سنة: {days} يومًا، متوسط الاستخدام {usage:.2f} ساعة، AHI {ahi:.2f}، تسرب 95% {leak:.1f} L/min.\n"
                "آخر 30 يومًا: AHI {ahi30:.2f}، تسرب 95% {leak30:.1f} L/min، تسرب>=24 خلال {leak_days} يومًا.\n"
                "الحالي: الضغط {min_p:.1f}-{max_p:.1f} cmH2O، EPR {epr:.0f}، الرطوبة {humidity:.0f}."
            ),
        }
        template = summary_templates.get(language, summary_templates["en"])
        return template.format(
            device=result.device_name,
            serial=result.serial,
            start=result.range_start,
            end=result.range_end,
            edf=result.edf_count,
            zero=len(result.zero_edfs),
            days=int(s.get("year_days", 0)),
            usage=float(s.get("year_avg_usage_hr", 0)),
            ahi=float(s.get("year_avg_ahi", 0)),
            leak=float(s.get("year_avg_leak95", 0)),
            ahi30=float(s.get("last30_avg_ahi", 0)),
            leak30=float(s.get("last30_avg_leak95", 0)),
            leak_days=int(s.get("last30_leak_over24_days", 0)),
            min_p=float(s.get("current_min_pressure", 0)),
            max_p=float(s.get("current_max_pressure", 0)),
            epr=float(s.get("current_epr", 0)),
            humidity=float(s.get("current_humidity", 0)),
        )

    @staticmethod
    def _make_suggestions(result: AnalysisResult, language: str = "zh") -> list[str]:
        s = result.summary
        ahi = float(s.get("year_avg_ahi", 0))
        leak30 = float(s.get("last30_avg_leak95", 0))
        leak_over30 = int(s.get("last30_leak_over24_days", 0))
        pressure = float(s.get("last30_avg_pressure95", 0))
        max_pressure = float(s.get("current_max_pressure", 0))
        cai30 = float(s.get("last30_avg_cai", 0))

        tips: list[str] = []
        if language == "zh":
            tips.append(f"AHI 参考：近一年约 {ahi:.2f}。")
            tips.append(f"漏气重点：近30天95%漏气 {leak30:.1f} L/min，达到24线的天数 {leak_over30}。")
            tips.append(f"压力关系：近30天95%压力 {pressure:.2f}，当前上限 {max_pressure:.1f} cmH2O。")
            tips.append(f"中枢事件：近30天 CAI {cai30:.2f}。")
            tips.append("调参建议：一次只改一项，连续观察 5-7 晚。")
            return tips
        localized = {
            "en": [
                f"AHI reference: about {ahi:.2f} over the last year.",
                f"Leak focus: last-30-day 95% leak is {leak30:.1f} L/min, with {leak_over30} days at or above 24.",
                f"Pressure relation: last-30-day 95% pressure is {pressure:.2f}, current max is {max_pressure:.1f} cmH2O.",
                f"Central events: last-30-day CAI is {cai30:.2f}.",
                "Adjustment rule: change one setting at a time and observe for 5-7 nights.",
            ],
            "de": [
                f"AHI-Referenz: im letzten Jahr etwa {ahi:.2f}.",
                f"Leckage-Fokus: 95%-Leckage der letzten 30 Tage {leak30:.1f} L/min, {leak_over30} Tage bei oder über 24.",
                f"Druckbezug: 95%-Druck der letzten 30 Tage {pressure:.2f}, aktuelles Maximum {max_pressure:.1f} cmH2O.",
                f"Zentrale Ereignisse: CAI der letzten 30 Tage {cai30:.2f}.",
                "Anpassungsregel: jeweils nur eine Einstellung ändern und 5-7 Nächte beobachten.",
            ],
            "fr": [
                f"Référence AHI : environ {ahi:.2f} sur la dernière année.",
                f"Point fuite : fuite 95% sur 30 jours = {leak30:.1f} L/min, {leak_over30} jours à 24 ou plus.",
                f"Relation pression : pression 95% sur 30 jours = {pressure:.2f}, maximum actuel = {max_pressure:.1f} cmH2O.",
                f"Événements centraux : CAI sur 30 jours = {cai30:.2f}.",
                "Règle d'ajustement : modifier un seul paramètre à la fois et observer 5-7 nuits.",
            ],
            "ru": [
                f"Ориентир AHI: около {ahi:.2f} за последний год.",
                f"Утечки: 95% утечка за 30 дней {leak30:.1f} L/min, дней >=24: {leak_over30}.",
                f"Давление: 95% давление за 30 дней {pressure:.2f}, текущий максимум {max_pressure:.1f} cmH2O.",
                f"Центральные события: CAI за 30 дней {cai30:.2f}.",
                "Правило настройки: меняйте только один параметр и наблюдайте 5-7 ночей.",
            ],
            "es": [
                f"Referencia AHI: alrededor de {ahi:.2f} en el último año.",
                f"Enfoque en fuga: fuga 95% de 30 días {leak30:.1f} L/min, {leak_over30} días en 24 o más.",
                f"Relación de presión: presión 95% de 30 días {pressure:.2f}, máximo actual {max_pressure:.1f} cmH2O.",
                f"Eventos centrales: CAI de 30 días {cai30:.2f}.",
                "Regla de ajuste: cambie una sola opción cada vez y observe 5-7 noches.",
            ],
            "pt": [
                f"Referência de AHI: cerca de {ahi:.2f} no último ano.",
                f"Foco em fuga: fuga de 95% em 30 dias {leak30:.1f} L/min, {leak_over30} dias em 24 ou mais.",
                f"Relação de pressão: pressão de 95% em 30 dias {pressure:.2f}, máximo atual {max_pressure:.1f} cmH2O.",
                f"Eventos centrais: CAI em 30 dias {cai30:.2f}.",
                "Regra de ajuste: altere apenas uma configuração por vez e observe por 5-7 noites.",
            ],
            "ja": [
                f"AHIの目安: 直近1年で約 {ahi:.2f}。",
                f"リーク重点: 直近30日の95%リークは {leak30:.1f} L/min、24以上の日数は {leak_over30} 日。",
                f"圧力関係: 直近30日の95%圧力は {pressure:.2f}、現在の上限は {max_pressure:.1f} cmH2O。",
                f"中枢イベント: 直近30日のCAIは {cai30:.2f}。",
                "調整ルール: 1回に1項目だけ変更し、5-7日観察してください。",
            ],
            "ko": [
                f"AHI 기준: 최근 1년 약 {ahi:.2f}.",
                f"누출 포인트: 최근 30일 95% 누출 {leak30:.1f} L/min, 24 이상인 날 {leak_over30}일.",
                f"압력 관계: 최근 30일 95% 압력 {pressure:.2f}, 현재 최대값 {max_pressure:.1f} cmH2O.",
                f"중추성 이벤트: 최근 30일 CAI {cai30:.2f}.",
                "조정 원칙: 한 번에 한 항목만 바꾸고 5-7일 관찰하세요.",
            ],
            "ar": [
                f"مرجع AHI: حوالي {ahi:.2f} خلال آخر سنة.",
                f"تركيز التسرب: تسرب 95% خلال 30 يومًا هو {leak30:.1f} L/min، وعدد الأيام عند 24 أو أكثر هو {leak_over30}.",
                f"علاقة الضغط: ضغط 95% خلال 30 يومًا هو {pressure:.2f}، والحد الأقصى الحالي {max_pressure:.1f} cmH2O.",
                f"الأحداث المركزية: قيمة CAI خلال 30 يومًا هي {cai30:.2f}.",
                "قاعدة الضبط: غيّر إعدادًا واحدًا فقط في كل مرة وراقب لمدة 5-7 ليالٍ.",
            ],
        }
        return localized.get(language, localized["en"])
