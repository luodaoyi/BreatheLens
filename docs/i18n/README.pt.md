# BreatheLens

[English](../../README.md) | [中文](README.zh.md) | [Deutsch](README.de.md) | [Français](README.fr.md) | [Русский](README.ru.md) | [Español](README.es.md) | Português | [日本語](README.ja.md) | [한국어](README.ko.md) | [العربية](README.ar.md)

BreatheLens é um analisador local de cartões SD ResMed CPAP / APAP. Ele lê a pasta original do cartão SD, analisa arquivos EDF e gera tabelas diárias, gráficos de tendência, revisão de vazamento, relatórios Excel e sugestões de ajuste de pressão.

O projeto serve para quem precisa revisar dados ResMed rapidamente, sem enviar nada para a nuvem e sem importar um banco OSCAR. Selecione a pasta com `STR.edf`, `DATALOG` e `SETTINGS` para analisar localmente.

## Capturas de tela

![Tela principal do BreatheLens](../images/1.png)

![Gráficos do BreatheLens](../images/2.png)

![Resumo STR do BreatheLens](../images/3.png)

![DATALOG do BreatheLens](../images/4.png)

![Revisão de vazamento do BreatheLens](../images/5.png)

## Recursos

- Seleção de uma pasta de cartão SD ResMed.
- Detecção de modelo e número de série.
- Análise do resumo diário `STR.edf`.
- Análise da duração das sessões `DATALOG/*_PLD.edf`.
- Análise dos eventos `DATALOG/*_EVE.edf`.
- Exibição de uso diário, AHI, CAI, OAI, vazamento 95 % e pressão 95 %.
- Troca de idioma na interface: chinês, inglês, alemão, francês, russo, espanhol, português, japonês, coreano e árabe.
- Processamento em segundo plano com progresso visível.
- Gráficos de AHI, vazamento 95 % e pressão 95 %.
- Tabelas STR, DATALOG e revisão de vazamento.
- Sugestões com base em vazamento, pressão no limite superior e eventos centrais.
- Exportação Excel com `Summary`, `STR_Daily`, `DATALOG_Daily`, `Leak_Watch`, `Suggestions` e `Codebook`.
- Interface desktop PySide6 + QML.
- Build de arquivo único com Nuitka.

## Dados lidos

| Arquivo | Uso |
| --- | --- |
| `Identification.tgt` | Modelo e número de série |
| `STR.edf` | Resumo diário com AHI, vazamento, pressão e configurações |
| `DATALOG/*_PLD.edf` | Duração das sessões e sinais de baixa frequência |
| `DATALOG/*_EVE.edf` | Anotações de eventos respiratórios |

As sugestões são baseadas em tendências de dados. Elas não substituem diagnóstico médico. Se CAI permanecer alto, houver baixa oxigenação noturna, aperto no peito, palpitações ou sonolência intensa, leve os dados originais a um profissional.

## Desenvolvimento

```powershell
uv venv .venv
uv sync
uv run python main.py
```

## Build local

```powershell
uv run python build.py
```

A saída fica em `dist/`, por exemplo `dist/BreatheLens.exe`.

## Publicação

O workflow `.github/workflows/release.yml` compila e publica tags `v*`. Em execução manual, informe `release_tag`. Linux x86 e Linux LoongArch64 precisam de runners self-hosted compatíveis.

## Licença

MIT License. Consulte [LICENSE](../../LICENSE).
