# BreatheLens

[English](../../README.md) | [中文](README.zh.md) | [Deutsch](README.de.md) | [Français](README.fr.md) | [Русский](README.ru.md) | [Español](README.es.md) | [Português](README.pt.md) | 日本語 | [한국어](README.ko.md) | [العربية](README.ar.md)

BreatheLens は、ResMed CPAP / APAP の SD カードをローカルで解析するツールです。ResMed 機器の SD カードフォルダーを読み取り、EDF ファイルを解析して、日別テーブル、トレンドグラフ、リーク確認表、Excel レポート、圧力調整の提案を生成します。

クラウドにアップロードせず、OSCAR データベースにも依存せず、ResMed データをすばやく確認したい人向けです。`STR.edf`、`DATALOG`、`SETTINGS` を含むフォルダーを選択すると、ローカルで解析できます。

## 画面

![BreatheLens メイン画面](../images/1.png)

![BreatheLens グラフ](../images/2.png)

![BreatheLens STR サマリー](../images/3.png)

![BreatheLens DATALOG](../images/4.png)

![BreatheLens リーク確認](../images/5.png)

## 機能

- ResMed SD カードデータフォルダーの選択。
- 機器モデルとシリアル番号の検出。
- `STR.edf` の日別治療サマリー解析。
- `DATALOG/*_PLD.edf` のセッション時間解析。
- `DATALOG/*_EVE.edf` のイベント注釈解析。
- 日別使用時間、AHI、CAI、OAI、95 % リーク、95 % 圧力の表示。
- UI 言語の切り替え：中国語、英語、ドイツ語、フランス語、ロシア語、スペイン語、ポルトガル語、日本語、韓国語、アラビア語。
- 大きなフォルダーをバックグラウンドで解析し、進捗を表示。
- AHI、95 % リーク、95 % 圧力のグラフ。
- STR、DATALOG、リーク確認の詳細テーブル。
- リーク、圧力上限、中心性イベントに基づく調整提案。
- `Summary`、`STR_Daily`、`DATALOG_Daily`、`Leak_Watch`、`Suggestions`、`Codebook` を含む Excel 出力。
- PySide6 + QML のデスクトップ UI。
- Nuitka による単一ファイルビルド。

## 読み取るデータ

| ファイル | 用途 |
| --- | --- |
| `Identification.tgt` | 機器モデルとシリアル番号 |
| `STR.edf` | AHI、リーク、圧力、設定を含む日別サマリー |
| `DATALOG/*_PLD.edf` | セッション時間と低周波治療信号 |
| `DATALOG/*_EVE.edf` | 呼吸イベント注釈 |

提案はデータ傾向に基づくもので、医療診断ではありません。CAI の高値が続く、夜間酸素低下、胸部圧迫感、動悸、強い日中眠気がある場合は、元データを持って医療者に相談してください。

## 開発

```powershell
uv venv .venv
uv sync
uv run python main.py
```

## ローカルビルド

```powershell
uv run python build.py
```

出力は `dist/` に作成されます。例: `dist/BreatheLens.exe`

## リリース

`.github/workflows/release.yml` は `v*` タグでビルドとリリースを行います。手動実行では `release_tag` を指定できます。Linux x86 と Linux LoongArch64 には対応する self-hosted runner が必要です。

## ライセンス

MIT License。詳しくは [LICENSE](../../LICENSE) を参照してください。
