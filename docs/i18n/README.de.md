# BreatheLens

[English](../../README.md) | [中文](README.zh.md) | Deutsch | [Français](README.fr.md) | [Русский](README.ru.md) | [Español](README.es.md) | [Português](README.pt.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [العربية](README.ar.md)

BreatheLens ist ein lokaler Analysator für ResMed CPAP- und APAP-SD-Karten. Das Programm liest den ursprünglichen SD-Kartenordner eines ResMed-Geräts, verarbeitet EDF-Dateien und erstellt Tagestabellen, Trenddiagramme, Leckageprüfungen, Excel-Berichte und Hinweise zur Druckanpassung.

Es richtet sich an Anwender, die ResMed-Daten schnell prüfen möchten, ohne Daten in die Cloud hochzuladen und ohne eine OSCAR-Datenbank zu importieren. Wählen Sie den Ordner mit `STR.edf`, `DATALOG` und `SETTINGS`, um die Analyse lokal zu starten.

## Bildschirmansichten

![BreatheLens Hauptansicht](../images/1.png)

![BreatheLens Diagramme](../images/2.png)

![BreatheLens STR-Zusammenfassung](../images/3.png)

![BreatheLens DATALOG](../images/4.png)

![BreatheLens Leckageprüfung](../images/5.png)

## Funktionen

- Auswahl eines ResMed-SD-Kartenordners.
- Erkennung von Gerätemodell und Seriennummer.
- Analyse der täglichen Therapieübersicht aus `STR.edf`.
- Analyse der Sitzungsdauer aus `DATALOG/*_PLD.edf`.
- Analyse der Ereignisannotationen aus `DATALOG/*_EVE.edf`.
- Anzeige von Nutzungsdauer, AHI, CAI, OAI, 95-%-Leckage und 95-%-Druck.
- Direkter Sprachwechsel in der Oberfläche: Chinesisch, Englisch, Deutsch, Französisch, Russisch, Spanisch, Portugiesisch, Japanisch, Koreanisch und Arabisch.
- Verarbeitung großer Ordner im Hintergrund mit Fortschrittsanzeige.
- Diagramme für AHI, 95-%-Leckage und 95-%-Druck.
- Tabellen für STR-Zusammenfassung, DATALOG-Sitzungen und Leckageprüfung.
- Hinweise zur Anpassung anhand von Leckage, Druckobergrenze und zentralen Ereignissen.
- Excel-Export mit `Summary`, `STR_Daily`, `DATALOG_Daily`, `Leak_Watch`, `Suggestions` und `Codebook`.
- PySide6- und QML-Desktopoberfläche.
- Einzeldatei-Build mit Nuitka.

## Gelesene Daten

| Datei | Zweck |
| --- | --- |
| `Identification.tgt` | Gerätemodell und Seriennummer |
| `STR.edf` | Tägliche Therapieübersicht mit AHI, Leckage, Druck und Einstellungen |
| `DATALOG/*_PLD.edf` | Sitzungsdauer und niederfrequente Therapiesignale |
| `DATALOG/*_EVE.edf` | Atemereignisse |

Die Hinweise beruhen auf Datentrends. Sie ersetzen keine ärztliche Diagnose. Bei dauerhaft hohem CAI, nächtlicher Sauerstoffentsättigung, Brustenge, Herzklopfen oder deutlicher Tagesschläfrigkeit sollten die Originaldaten ärztlich geprüft werden.

## Entwicklung

```powershell
uv venv .venv
uv sync
uv run python main.py
```

## Lokaler Build

```powershell
uv run python build.py
```

Die Ausgabe liegt in `dist/`, zum Beispiel `dist/BreatheLens.exe`.

## Release

`.github/workflows/release.yml` baut und veröffentlicht Releases bei Tags nach dem Muster `v*`. Manuelle Läufe können über `release_tag` gestartet werden. Für Linux x86 und Linux LoongArch64 werden passende selbst gehostete Runner benötigt.

## Lizenz

MIT License. Siehe [LICENSE](../../LICENSE).
