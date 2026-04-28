# BreatheLens

[English](../../README.md) | 中文 | [Deutsch](README.de.md) | [Français](README.fr.md) | [Русский](README.ru.md) | [Español](README.es.md) | [Português](README.pt.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [العربية](README.ar.md)

BreatheLens（呼吸镜）是一个本地运行的 ResMed CPAP / APAP SD 卡数据分析工具。它读取瑞思迈呼吸机原始 SD 卡目录，解析 EDF 文件，并生成每日表格、趋势图、漏气观察表、Excel 报告和压力调整建议。

本项目面向需要快速查看瑞思迈数据的人：无需上传云端，不依赖 OSCAR 数据库。选择包含 `STR.edf`、`DATALOG`、`SETTINGS` 的文件夹即可在本机分析。

## 界面预览

主界面提供数据概览、调整建议、语言切换和文件夹选择。

![BreatheLens 主界面](../images/1.png)

关键指标图表带时间轴，鼠标悬停时可查看日期和数值。

![BreatheLens 关键图表](../images/2.png)

STR 每日汇总表适合查看长期治疗趋势和压力、漏气、AHI 明细。

![BreatheLens STR 汇总](../images/3.png)

DATALOG 页面展示会话时长和事件统计。

![BreatheLens DATALOG](../images/4.png)

漏气观察页用于快速定位需要优先处理的高漏气日期。

![BreatheLens 漏气观察](../images/5.png)

## 功能

- 选择 ResMed SD 卡数据文件夹。
- 自动识别设备型号与序列号。
- 解析 `STR.edf` 每日治疗汇总。
- 解析 `DATALOG/*_PLD.edf` 会话时长。
- 解析 `DATALOG/*_EVE.edf` 事件注释。
- 展示每日使用时长、AHI、CAI、OAI、95% 漏气、95% 压力。
- 界面可直接切换中文、英文、德文、法文、俄文、西班牙文、葡萄牙文、日文、韩文、阿拉伯文。
- 使用后台线程解析大目录，界面保持可操作，并显示实时进度。
- 内置 AHI、95% 漏气、95% 压力关键指标曲线图。
- 提供 STR 汇总、DATALOG 会话事件、漏气观察三类明细表格。
- 自动给出调整建议：优先判断漏气、压力是否顶上限、中枢事件是否偏高。
- 导出 Excel，包含 `Summary`、`STR_Daily`、`DATALOG_Daily`、`Leak_Watch`、`Suggestions`、`Codebook`。
- PySide6 + QML 桌面界面，微信绿色风格，简单高效。
- 使用 Nuitka 打包单文件程序。

## 数据说明

| 文件 | 用途 |
| --- | --- |
| `Identification.tgt` | 设备型号、序列号 |
| `STR.edf` | 每日治疗汇总，含 AHI、漏气、压力、设置 |
| `DATALOG/*_PLD.edf` | 会话时长与低频治疗曲线 |
| `DATALOG/*_EVE.edf` | 呼吸事件注释 |

报告中的建议以数据趋势为依据，不能替代医生诊断。若出现 CAI 持续升高、夜间低氧、胸闷心悸、明显嗜睡等情况，应携带原始数据就医。

## 开发运行

```powershell
uv venv .venv
uv sync
uv run python main.py
```

## 本地打包

```powershell
uv run python build.py
```

输出位于 `dist/`，例如：

```text
dist/BreatheLens.exe
dist/BreatheLens-windows-x64.zip
```

## GitHub Actions 发布

仓库内置 `.github/workflows/release.yml`。

- push tag `v*` 时自动构建并发布 Release。
- 默认构建 GitHub 托管 runner 支持的平台：Windows x64、Windows x86、Windows ARM64、macOS arm64、macOS x64、Linux x64、Linux ARM64。
- 其他平台需要自托管 runner：Linux x86 使用 `self-hosted, linux, X86`；Linux LoongArch64 使用 `self-hosted, linux, LoongArch64`。

手动触发 workflow 时，可打开 `build_self_hosted` 来构建这些自托管平台。Nuitka + PySide6 应在目标系统和架构原生编译；没有对应 runner 时，GitHub Actions 无法可靠交叉编译 Qt GUI 程序。

发布方式：

```bash
git tag v0.1.0
git push origin v0.1.0
```

也可以手动触发 workflow，并填写 `release_tag`，例如 `v0.1.0`。

## 许可证

MIT License。详见 [LICENSE](../../LICENSE)。
