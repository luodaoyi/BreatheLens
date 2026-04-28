# BreatheLens

[English](../../README.md) | [中文](README.zh.md) | [Deutsch](README.de.md) | [Français](README.fr.md) | [Русский](README.ru.md) | [Español](README.es.md) | [Português](README.pt.md) | [日本語](README.ja.md) | 한국어 | [العربية](README.ar.md)

BreatheLens는 ResMed CPAP / APAP SD 카드를 로컬에서 분석하는 도구입니다. ResMed 장치의 원본 SD 카드 폴더를 읽고 EDF 파일을 분석해 일별 표, 추세 그래프, 누출 점검표, Excel 보고서, 압력 조정 제안을 만듭니다.

클라우드 업로드나 OSCAR 데이터베이스 없이 ResMed 데이터를 빠르게 확인하려는 사용자를 위한 프로젝트입니다. `STR.edf`, `DATALOG`, `SETTINGS`가 들어 있는 폴더를 선택하면 로컬에서 분석합니다.

## 화면

![BreatheLens 메인 화면](../images/1.png)

![BreatheLens 그래프](../images/2.png)

![BreatheLens STR 요약](../images/3.png)

![BreatheLens DATALOG](../images/4.png)

![BreatheLens 누출 점검](../images/5.png)

## 기능

- ResMed SD 카드 데이터 폴더 선택.
- 장치 모델과 일련번호 감지.
- `STR.edf` 일별 치료 요약 분석.
- `DATALOG/*_PLD.edf` 세션 시간 분석.
- `DATALOG/*_EVE.edf` 이벤트 주석 분석.
- 일별 사용 시간, AHI, CAI, OAI, 95 % 누출, 95 % 압력 표시.
- UI 언어 전환: 중국어, 영어, 독일어, 프랑스어, 러시아어, 스페인어, 포르투갈어, 일본어, 한국어, 아랍어.
- 큰 폴더를 백그라운드에서 분석하고 진행률 표시.
- AHI, 95 % 누출, 95 % 압력 그래프.
- STR 요약, DATALOG 세션/이벤트, 누출 점검 표.
- 누출, 압력 상한 도달, 중심성 이벤트 증가를 기준으로 한 조정 제안.
- `Summary`, `STR_Daily`, `DATALOG_Daily`, `Leak_Watch`, `Suggestions`, `Codebook` 시트가 포함된 Excel 내보내기.
- PySide6 + QML 데스크톱 UI.
- Nuitka 단일 파일 빌드.

## 읽는 데이터

| 파일 | 용도 |
| --- | --- |
| `Identification.tgt` | 장치 모델과 일련번호 |
| `STR.edf` | AHI, 누출, 압력, 설정을 포함한 일별 요약 |
| `DATALOG/*_PLD.edf` | 세션 시간과 저주파 치료 신호 |
| `DATALOG/*_EVE.edf` | 호흡 이벤트 주석 |

제안은 데이터 추세를 바탕으로 하며 의학적 진단을 대체하지 않습니다. CAI가 계속 높거나, 야간 산소 저하, 흉부 답답함, 심계항진, 뚜렷한 주간 졸림이 있으면 원본 데이터를 가지고 의료진과 상담하십시오.

## 개발

```powershell
uv venv .venv
uv sync
uv run python main.py
```

## 로컬 빌드

```powershell
uv run python build.py
```

출력은 `dist/`에 생성됩니다. 예: `dist/BreatheLens.exe`

## 릴리스

`.github/workflows/release.yml`은 `v*` 태그에서 빌드와 릴리스를 수행합니다. 수동 실행 시 `release_tag`를 입력할 수 있습니다. Linux x86 및 Linux LoongArch64에는 호환되는 self-hosted runner가 필요합니다.

## 라이선스

MIT License. [LICENSE](../../LICENSE)를 참고하십시오.
