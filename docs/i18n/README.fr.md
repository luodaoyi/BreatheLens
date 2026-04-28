# BreatheLens

[English](../../README.md) | [中文](README.zh.md) | [Deutsch](README.de.md) | Français | [Русский](README.ru.md) | [Español](README.es.md) | [Português](README.pt.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [العربية](README.ar.md)

BreatheLens est un analyseur local de cartes SD ResMed CPAP / APAP. Il lit le dossier original de la carte SD, analyse les fichiers EDF et produit des tableaux quotidiens, des graphiques de tendance, une revue des fuites, des rapports Excel et des suggestions d'ajustement de pression.

L'outil sert aux personnes qui veulent consulter rapidement leurs données ResMed sans téléversement vers le cloud et sans base OSCAR. Sélectionnez le dossier contenant `STR.edf`, `DATALOG` et `SETTINGS`, puis lancez l'analyse locale.

## Captures d'écran

![BreatheLens écran principal](../images/1.png)

![BreatheLens graphiques](../images/2.png)

![BreatheLens résumé STR](../images/3.png)

![BreatheLens DATALOG](../images/4.png)

![BreatheLens revue des fuites](../images/5.png)

## Fonctionnalités

- Sélection d'un dossier de carte SD ResMed.
- Détection du modèle et du numéro de série.
- Analyse du résumé quotidien `STR.edf`.
- Analyse des durées de session `DATALOG/*_PLD.edf`.
- Analyse des événements `DATALOG/*_EVE.edf`.
- Affichage de l'utilisation quotidienne, AHI, CAI, OAI, fuite 95 % et pression 95 %.
- Changement de langue intégré : chinois, anglais, allemand, français, russe, espagnol, portugais, japonais, coréen et arabe.
- Analyse en arrière-plan avec progression visible.
- Graphiques pour AHI, fuite 95 % et pression 95 %.
- Tableaux STR, DATALOG et revue des fuites.
- Suggestions basées sur les fuites, la pression proche du plafond et les événements centraux.
- Export Excel avec `Summary`, `STR_Daily`, `DATALOG_Daily`, `Leak_Watch`, `Suggestions` et `Codebook`.
- Interface desktop PySide6 + QML.
- Construction en fichier unique avec Nuitka.

## Données lues

| Fichier | Usage |
| --- | --- |
| `Identification.tgt` | Modèle et numéro de série |
| `STR.edf` | Résumé quotidien avec AHI, fuite, pression et réglages |
| `DATALOG/*_PLD.edf` | Durée des sessions et signaux de thérapie basse fréquence |
| `DATALOG/*_EVE.edf` | Annotations d'événements respiratoires |

Les suggestions reposent sur des tendances de données. Elles ne remplacent pas un diagnostic médical. En cas de CAI durablement élevé, de désaturation nocturne, d'oppression thoracique, de palpitations ou de somnolence marquée, consultez un professionnel avec les données originales.

## Développement

```powershell
uv venv .venv
uv sync
uv run python main.py
```

## Construction locale

```powershell
uv run python build.py
```

La sortie se trouve dans `dist/`, par exemple `dist/BreatheLens.exe`.

## Publication

Le workflow `.github/workflows/release.yml` construit et publie les tags `v*`. Un lancement manuel peut fournir `release_tag`. Linux x86 et Linux LoongArch64 nécessitent des runners auto-hébergés adaptés.

## Licence

MIT License. Voir [LICENSE](../../LICENSE).
