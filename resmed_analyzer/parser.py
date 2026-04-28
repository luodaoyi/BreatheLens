from __future__ import annotations

from dataclasses import dataclass, field
from datetime import date, timedelta
from pathlib import Path
import re
from typing import Callable

from .edf import read_annotation_text, read_header, read_records


ProgressCallback = Callable[[int, str], None]


@dataclass
class StrDay:
    date: str
    duration_min: float
    usage_hr: float
    ahi: float
    ai: float
    hi: float
    oai: float
    cai: float
    uai: float
    leak95_lmin: float
    leak50_lmin: float
    leakmax_lmin: float
    pressure95: float
    pressure50: float
    min_pressure: float
    max_pressure: float
    epr_level: float
    humidity: float
    tube_temp_c: float
    csr_min: float


@dataclass
class DataDay:
    date: str
    duration_min: float = 0.0
    sessions: int = 0
    central_apnea: int = 0
    obstructive_apnea: int = 0
    hypopnea: int = 0
    apnea: int = 0
    rera: int = 0
    csr_events: int = 0
    skipped_files: int = 0

    @property
    def usage_hr(self) -> float:
        return self.duration_min / 60.0

    @property
    def total_events(self) -> int:
        return self.central_apnea + self.obstructive_apnea + self.hypopnea + self.apnea

    @property
    def estimated_ahi(self) -> float:
        return self.total_events / self.usage_hr if self.usage_hr > 0 else 0.0


@dataclass
class AnalysisResult:
    folder: str
    device_name: str = ""
    serial: str = ""
    range_start: str = ""
    range_end: str = ""
    edf_count: int = 0
    zero_edfs: list[str] = field(default_factory=list)
    invalid_str_dates: list[str] = field(default_factory=list)
    missing_dates: list[str] = field(default_factory=list)
    str_days: list[StrDay] = field(default_factory=list)
    data_days: list[DataDay] = field(default_factory=list)
    summary: dict[str, float | int | str] = field(default_factory=dict)
    suggestions: list[str] = field(default_factory=list)


def _unix_days_to_date(value: float | None) -> str:
    if value is None or value <= 0:
        return ""
    return (date(1970, 1, 1) + timedelta(days=round(value))).isoformat()


def _num(row: dict, key: str, default: float = 0.0) -> float:
    value = row.get(key)
    if value is None:
        return default
    try:
        return float(value)
    except (TypeError, ValueError):
        return default


def _device_info(folder: Path) -> tuple[str, str]:
    target = folder / "Identification.tgt"
    if not target.exists():
        return "ResMed Device", ""
    text = target.read_text("latin1", errors="ignore")
    product = re.search(r"#PNA\s+([^\r\n]+)", text)
    serial = re.search(r"#SRN\s+([^\r\n]+)", text)
    return (
        product.group(1).replace("_", " ") if product else "ResMed Device",
        serial.group(1).strip() if serial else "",
    )


def _event_names(text: str) -> list[str]:
    names = []
    for match in re.finditer(r"\x15[^\x14]*\x14([^\x14\x00]+)", text):
        name = match.group(1).strip()
        if name and name != "Recording starts":
            names.append(name)
    return names


def _stats(values: list[float]) -> dict[str, float]:
    vals = [v for v in values if v is not None]
    if not vals:
        return {"avg": 0.0, "median": 0.0, "max": 0.0, "min": 0.0}
    ordered = sorted(vals)
    return {
        "avg": sum(vals) / len(vals),
        "median": ordered[len(ordered) // 2],
        "max": ordered[-1],
        "min": ordered[0],
    }


def _summarize_str(days: list[StrDay], prefix: str) -> dict[str, float | int]:
    if not days:
        return {
            f"{prefix}_days": 0,
            f"{prefix}_avg_usage_hr": 0.0,
            f"{prefix}_avg_ahi": 0.0,
            f"{prefix}_avg_leak95": 0.0,
            f"{prefix}_leak_over24_days": 0,
            f"{prefix}_avg_pressure95": 0.0,
            f"{prefix}_avg_cai": 0.0,
            f"{prefix}_avg_oai": 0.0,
        }
    return {
        f"{prefix}_days": len(days),
        f"{prefix}_days4h": sum(1 for d in days if d.duration_min >= 240),
        f"{prefix}_avg_usage_hr": _stats([d.usage_hr for d in days])["avg"],
        f"{prefix}_median_usage_hr": _stats([d.usage_hr for d in days])["median"],
        f"{prefix}_avg_ahi": _stats([d.ahi for d in days])["avg"],
        f"{prefix}_median_ahi": _stats([d.ahi for d in days])["median"],
        f"{prefix}_max_ahi": _stats([d.ahi for d in days])["max"],
        f"{prefix}_avg_leak95": _stats([d.leak95_lmin for d in days])["avg"],
        f"{prefix}_median_leak95": _stats([d.leak95_lmin for d in days])["median"],
        f"{prefix}_leak_over24_days": sum(1 for d in days if d.leak95_lmin >= 24),
        f"{prefix}_avg_pressure95": _stats([d.pressure95 for d in days])["avg"],
        f"{prefix}_avg_cai": _stats([d.cai for d in days])["avg"],
        f"{prefix}_avg_oai": _stats([d.oai for d in days])["avg"],
    }


def _build_suggestions(result: AnalysisResult) -> list[str]:
    s = result.summary
    tips: list[str] = []
    ahi = float(s.get("year_avg_ahi", 0))
    leak30 = float(s.get("last30_avg_leak95", 0))
    leak_over30 = int(s.get("last30_leak_over24_days", 0))
    pressure = float(s.get("last30_avg_pressure95", 0))
    max_pressure = float(s.get("current_max_pressure", 0))
    cai30 = float(s.get("last30_avg_cai", 0))

    if ahi < 2:
        tips.append(f"疗效良好：近一年 AHI 约 {ahi:.2f}，不宜为追求更低数字而贸然加压。")
    elif ahi < 5:
        tips.append(f"疗效尚可：AHI 约 {ahi:.2f}，先看症状与漏气，不急改模式。")
    else:
        tips.append(f"AHI 偏高：AHI 约 {ahi:.2f}，需先排除漏气，必要时带数据问医生。")

    if leak_over30 >= 5 or leak30 >= 12:
        tips.append(f"优先处理漏气：近30天 95%漏气均值 {leak30:.1f} L/min，且 {leak_over30} 天达到 24 L/min 关注线。先查面罩垫、头带、口漏和睡姿。")
    else:
        tips.append(f"漏气可接受：近30天 95%漏气均值 {leak30:.1f} L/min，继续保持面罩密封。")

    if max_pressure > 0 and pressure < max_pressure - 1:
        tips.append(f"压力未顶上限：近30天 95%压力约 {pressure:.2f} cmH2O，低于上限 {max_pressure:.1f}。当前不建议先调高最大压力。")
    else:
        tips.append("压力接近上限：若漏气正常且阻塞事件仍多，可考虑小幅提高最大压力，但须逐步观察。")

    if cai30 >= 3:
        tips.append(f"中枢事件需谨慎：近30天 CAI 约 {cai30:.2f}。若继续升高或伴不适，暂停自行加压并咨询医生。")
    else:
        tips.append(f"中枢事件不高：近30天 CAI 约 {cai30:.2f}，以漏气排查为主。")

    tips.append("调整规则：一次只改一项，每次观察 5-7 晚；若漏气变大、睡眠变差或 CAI 上升，退回原设置。")
    return tips


def parse_folder(folder: str | Path, progress: ProgressCallback | None = None) -> AnalysisResult:
    base = Path(folder)
    if not base.exists() or not base.is_dir():
        raise FileNotFoundError(f"目录不存在：{base}")

    def report(value: int, message: str) -> None:
        if progress:
            progress(max(0, min(100, value)), message)

    report(1, "正在扫描 EDF 文件...")
    result = AnalysisResult(folder=str(base))
    result.device_name, result.serial = _device_info(base)
    edfs = sorted(base.rglob("*.edf"))
    result.edf_count = len(edfs)
    result.zero_edfs = [str(p.relative_to(base)) for p in edfs if p.stat().st_size == 0]
    report(8, f"发现 {result.edf_count} 个 EDF 文件。")

    str_file = base / "STR.edf"
    if str_file.exists():
        report(10, "正在解析 STR.edf 每日汇总...")
        parsed = read_records(str_file)
        if parsed:
            _, rows = parsed
            for row in rows:
                day = _unix_days_to_date(_num(row, "Date", 0))
                if not day:
                    continue
                duration = _num(row, "Duration", -1)
                ahi = _num(row, "AHI", -1)
                if duration < 0 or ahi < 0:
                    result.invalid_str_dates.append(day)
                    continue
                if duration == 0:
                    continue
                result.str_days.append(
                    StrDay(
                        date=day,
                        duration_min=duration,
                        usage_hr=duration / 60.0,
                        ahi=ahi,
                        ai=_num(row, "AI"),
                        hi=_num(row, "HI"),
                        oai=_num(row, "OAI"),
                        cai=_num(row, "CAI"),
                        uai=_num(row, "UAI"),
                        leak95_lmin=_num(row, "Leak.95") * 60,
                        leak50_lmin=_num(row, "Leak.50") * 60,
                        leakmax_lmin=_num(row, "Leak.Max") * 60,
                        pressure95=_num(row, "MaskPress.95"),
                        pressure50=_num(row, "MaskPress.50"),
                        min_pressure=_num(row, "S.AS.MinPress"),
                        max_pressure=_num(row, "S.AS.MaxPress"),
                        epr_level=_num(row, "S.EPR.Level"),
                        humidity=_num(row, "S.HumLevel"),
                        tube_temp_c=_num(row, "S.Temp"),
                        csr_min=_num(row, "CSR"),
                    )
                )
    report(22, f"STR 汇总完成：{len(result.str_days)} 天。")

    day_map: dict[str, DataDay] = {}

    def get_day(path: Path) -> DataDay:
        ymd = path.parent.name
        iso = f"{ymd[:4]}-{ymd[4:6]}-{ymd[6:8]}"
        if iso not in day_map:
            day_map[iso] = DataDay(date=iso)
        return day_map[iso]

    pld_files = sorted(base.rglob("*_PLD.edf"))
    eve_files = sorted(base.rglob("*_EVE.edf"))
    total_detail_files = max(1, len(pld_files) + len(eve_files))
    done_detail_files = 0

    for p in pld_files:
        d = get_day(p)
        header = read_header(p)
        if header is None:
            d.skipped_files += 1
        else:
            d.duration_min += header.records * header.record_seconds / 60.0
            d.sessions += 1
        done_detail_files += 1
        if done_detail_files % 25 == 0 or done_detail_files == len(pld_files):
            report(22 + int(done_detail_files / total_detail_files * 38), f"正在解析会话时长：{done_detail_files}/{total_detail_files}")

    for p in eve_files:
        d = get_day(p)
        if p.stat().st_size < 256:
            d.skipped_files += 1
            done_detail_files += 1
            report(22 + int(done_detail_files / total_detail_files * 68), f"正在解析事件：{done_detail_files}/{total_detail_files}")
            continue
        for name in _event_names(read_annotation_text(p)):
            if name == "Central Apnea":
                d.central_apnea += 1
            elif name == "Obstructive Apnea":
                d.obstructive_apnea += 1
            elif name == "Hypopnea":
                d.hypopnea += 1
            elif name == "Apnea":
                d.apnea += 1
            elif name == "RERA":
                d.rera += 1
            elif name == "Cheyne-Stokes Respiration":
                d.csr_events += 1
        done_detail_files += 1
        if done_detail_files % 25 == 0 or done_detail_files == total_detail_files:
            report(22 + int(done_detail_files / total_detail_files * 68), f"正在解析事件：{done_detail_files}/{total_detail_files}")

    report(92, "正在汇总统计指标...")
    result.data_days = sorted((d for d in day_map.values() if d.duration_min > 0), key=lambda x: x.date)
    if result.data_days:
        result.range_start = result.data_days[0].date
        result.range_end = result.data_days[-1].date
    elif result.str_days:
        result.range_start = result.str_days[0].date
        result.range_end = result.str_days[-1].date

    if result.range_start and result.range_end:
        start = date.fromisoformat(result.range_start)
        end = date.fromisoformat(result.range_end)
        have = {d.date for d in result.data_days}
        result.missing_dates = [
            (start + timedelta(days=i)).isoformat()
            for i in range((end - start).days + 1)
            if (start + timedelta(days=i)).isoformat() not in have
        ]

    result.summary.update(_summarize_str(result.str_days, "year"))
    result.summary.update(_summarize_str(result.str_days[-90:], "last90"))
    result.summary.update(_summarize_str(result.str_days[-30:], "last30"))
    if result.str_days:
        latest = result.str_days[-1]
        result.summary.update(
            {
                "current_min_pressure": latest.min_pressure,
                "current_max_pressure": latest.max_pressure,
                "current_epr": latest.epr_level,
                "current_humidity": latest.humidity,
                "current_tube_temp": latest.tube_temp_c,
            }
        )
    result.summary.update(
        {
            "calendar_days": len(result.missing_dates) + len(result.data_days),
            "data_used_days": len(result.data_days),
            "data_days4h": sum(1 for d in result.data_days if d.duration_min >= 240),
            "data_total_hours": sum(d.duration_min for d in result.data_days) / 60.0,
            "data_total_events": sum(d.total_events for d in result.data_days),
        }
    )
    result.suggestions = _build_suggestions(result)
    report(100, "解析完成。")
    return result
