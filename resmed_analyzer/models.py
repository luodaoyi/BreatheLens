from __future__ import annotations

from PySide6.QtCore import QAbstractTableModel, QModelIndex, Qt, QByteArray


class SimpleTableModel(QAbstractTableModel):
    DisplayRole = Qt.ItemDataRole.DisplayRole

    def __init__(self) -> None:
        super().__init__()
        self._headers: list[str] = []
        self._rows: list[list[str]] = []

    def set_table(self, headers: list[str], rows: list[list]) -> None:
        self.beginResetModel()
        self._headers = headers
        self._rows = [[self._format(v) for v in row] for row in rows]
        self.endResetModel()

    def rowCount(self, parent: QModelIndex = QModelIndex()) -> int:
        return 0 if parent.isValid() else len(self._rows)

    def columnCount(self, parent: QModelIndex = QModelIndex()) -> int:
        return 0 if parent.isValid() else len(self._headers)

    def data(self, index: QModelIndex, role: int = DisplayRole):
        if not index.isValid() or role != self.DisplayRole:
            return None
        return self._rows[index.row()][index.column()]

    def headerData(self, section: int, orientation: Qt.Orientation, role: int = DisplayRole):
        if role != self.DisplayRole:
            return None
        if orientation == Qt.Orientation.Horizontal and 0 <= section < len(self._headers):
            return self._headers[section]
        if orientation == Qt.Orientation.Vertical:
            return str(section + 1)
        return None

    def roleNames(self) -> dict[int, QByteArray]:
        return {int(self.DisplayRole): QByteArray(b"display")}

    @staticmethod
    def _format(value) -> str:
        if isinstance(value, float):
            return f"{value:.2f}".rstrip("0").rstrip(".")
        return "" if value is None else str(value)
