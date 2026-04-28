from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import struct


@dataclass(frozen=True)
class EdfHeader:
    path: Path
    size: int
    patient: str
    recording: str
    start_date: str
    start_time: str
    header_bytes: int
    records: int
    record_seconds: float
    labels: list[str]
    dimensions: list[str]
    physical_min: list[float]
    physical_max: list[float]
    digital_min: list[float]
    digital_max: list[float]
    samples_per_record: list[int]

    @property
    def signal_count(self) -> int:
        return len(self.labels)

    @property
    def bytes_per_record(self) -> int:
        return sum(self.samples_per_record) * 2


def _ascii(buf: bytes) -> str:
    return buf.decode("ascii", errors="ignore").strip()


def read_header(path: str | Path) -> EdfHeader | None:
    p = Path(path)
    size = p.stat().st_size
    if size < 256:
        return None

    with p.open("rb") as f:
        fixed = f.read(256)
        try:
            header_bytes = int(_ascii(fixed[184:192]))
            raw_records = int(_ascii(fixed[236:244]))
            record_seconds = float(_ascii(fixed[244:252]))
            signal_count = int(_ascii(fixed[252:256]))
        except ValueError:
            return None

        if header_bytes < 256 or signal_count <= 0:
            return None
        variable = f.read(header_bytes - 256)

    offset = 0

    def fields(width: int) -> list[str]:
        nonlocal offset
        values = []
        for _ in range(signal_count):
            values.append(_ascii(variable[offset : offset + width]))
            offset += width
        return values

    labels = fields(16)
    fields(80)
    dimensions = fields(8)
    physical_min = [float(x or 0) for x in fields(8)]
    physical_max = [float(x or 0) for x in fields(8)]
    digital_min = [float(x or 0) for x in fields(8)]
    digital_max = [float(x or 0) for x in fields(8)]
    fields(80)
    samples_per_record = [int(float(x or 0)) for x in fields(8)]
    fields(32)

    bytes_per_record = sum(samples_per_record) * 2
    records = raw_records
    if records < 0 and bytes_per_record > 0:
        records = max(0, (size - header_bytes) // bytes_per_record)
    if records < 0:
        return None

    return EdfHeader(
        path=p,
        size=size,
        patient=_ascii(fixed[8:88]),
        recording=_ascii(fixed[88:168]),
        start_date=_ascii(fixed[168:176]),
        start_time=_ascii(fixed[176:184]),
        header_bytes=header_bytes,
        records=records,
        record_seconds=record_seconds,
        labels=labels,
        dimensions=dimensions,
        physical_min=physical_min,
        physical_max=physical_max,
        digital_min=digital_min,
        digital_max=digital_max,
        samples_per_record=samples_per_record,
    )


def _to_physical(raw: int, header: EdfHeader, index: int) -> float | None:
    if raw in (-32768, 32767):
        return None
    dmin = header.digital_min[index]
    dmax = header.digital_max[index]
    pmin = header.physical_min[index]
    pmax = header.physical_max[index]
    if dmax == dmin:
        return float(raw)
    return (raw - dmin) * (pmax - pmin) / (dmax - dmin) + pmin


def read_records(path: str | Path) -> tuple[EdfHeader, list[dict[str, float | list[float | None] | None]]] | None:
    header = read_header(path)
    if header is None:
        return None

    records: list[dict[str, float | list[float | None] | None]] = []
    with header.path.open("rb") as f:
        f.seek(header.header_bytes)
        for _ in range(header.records):
            row: dict[str, float | list[float | None] | None] = {}
            for idx, label in enumerate(header.labels):
                count = header.samples_per_record[idx]
                raw_bytes = f.read(count * 2)
                values = [
                    _to_physical(v[0], header, idx)
                    for v in struct.iter_unpack("<h", raw_bytes)
                ]
                row[label] = values[0] if count == 1 else values
            records.append(row)
    return header, records


def read_annotation_text(path: str | Path) -> str:
    header = read_header(path)
    if header is None:
        return ""

    chunks: list[bytes] = []
    with header.path.open("rb") as f:
        f.seek(header.header_bytes)
        for _ in range(header.records):
            for idx, label in enumerate(header.labels):
                block_size = header.samples_per_record[idx] * 2
                block = f.read(block_size)
                if "Annotations" in label:
                    chunks.append(block)
    return b"".join(chunks).decode("latin1", errors="ignore")
