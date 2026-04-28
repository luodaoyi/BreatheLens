# BreatheLens

[English](../../README.md) | [中文](README.zh.md) | [Deutsch](README.de.md) | [Français](README.fr.md) | [Русский](README.ru.md) | Español | [Português](README.pt.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [العربية](README.ar.md)

BreatheLens es un analizador local de tarjetas SD ResMed CPAP / APAP. Lee la carpeta original de la tarjeta SD, analiza archivos EDF y genera tablas diarias, gráficos de tendencia, revisión de fugas, informes Excel y sugerencias de ajuste de presión.

Está pensado para revisar datos ResMed con rapidez, sin subirlos a la nube y sin importar una base de datos OSCAR. Seleccione la carpeta que contiene `STR.edf`, `DATALOG` y `SETTINGS` para analizarla localmente.

## Capturas

![BreatheLens pantalla principal](../images/1.png)

![BreatheLens gráficos](../images/2.png)

![BreatheLens resumen STR](../images/3.png)

![BreatheLens DATALOG](../images/4.png)

![BreatheLens revisión de fugas](../images/5.png)

## Funciones

- Selección de una carpeta de tarjeta SD ResMed.
- Detección del modelo y número de serie.
- Análisis del resumen diario `STR.edf`.
- Análisis de duración de sesiones `DATALOG/*_PLD.edf`.
- Análisis de eventos `DATALOG/*_EVE.edf`.
- Visualización de uso diario, AHI, CAI, OAI, fuga 95 % y presión 95 %.
- Cambio de idioma en la interfaz: chino, inglés, alemán, francés, ruso, español, portugués, japonés, coreano y árabe.
- Procesamiento en segundo plano con progreso visible.
- Gráficos de AHI, fuga 95 % y presión 95 %.
- Tablas STR, DATALOG y revisión de fugas.
- Sugerencias basadas en fugas, presión cercana al límite superior y eventos centrales.
- Exportación Excel con `Summary`, `STR_Daily`, `DATALOG_Daily`, `Leak_Watch`, `Suggestions` y `Codebook`.
- Interfaz de escritorio PySide6 + QML.
- Empaquetado en un solo archivo con Nuitka.

## Datos leídos

| Archivo | Uso |
| --- | --- |
| `Identification.tgt` | Modelo y número de serie |
| `STR.edf` | Resumen diario con AHI, fuga, presión y ajustes |
| `DATALOG/*_PLD.edf` | Duración de sesiones y señales de baja frecuencia |
| `DATALOG/*_EVE.edf` | Anotaciones de eventos respiratorios |

Las sugerencias se basan en tendencias de datos. No sustituyen un diagnóstico médico. Si el CAI se mantiene alto, hay baja oxigenación nocturna, opresión en el pecho, palpitaciones o somnolencia marcada, lleve los datos originales a un profesional.

## Desarrollo

```powershell
uv venv .venv
uv sync
uv run python main.py
```

## Compilación local

```powershell
uv run python build.py
```

La salida queda en `dist/`, por ejemplo `dist/BreatheLens.exe`.

## Publicación

El workflow `.github/workflows/release.yml` compila y publica etiquetas `v*`. En una ejecución manual puede indicar `release_tag`. Linux x86 y Linux LoongArch64 requieren runners autohospedados compatibles.

## Licencia

MIT License. Consulte [LICENSE](../../LICENSE).
