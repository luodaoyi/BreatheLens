import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

ApplicationWindow {
    id: root
    width: 1180
    height: 760
    visible: true
    title: "BreatheLens"
    color: "#F5F7F6"
    readonly property var appBackend: backend
    property int activeTab: 0
    property string languageCode: "zh"
    readonly property bool rtlLanguage: languageCode === "ar"
    LayoutMirroring.enabled: rtlLanguage
    LayoutMirroring.childrenInherit: true

    readonly property var languageOptions: [
        { "code": "zh", "name": "中文" },
        { "code": "en", "name": "English" },
        { "code": "de", "name": "Deutsch" },
        { "code": "fr", "name": "Français" },
        { "code": "ru", "name": "Русский" },
        { "code": "es", "name": "Español" },
        { "code": "pt", "name": "Português" },
        { "code": "ja", "name": "日本語" },
        { "code": "ko", "name": "한국어" },
        { "code": "ar", "name": "العربية" }
    ]

    readonly property var i18n: ({
        "zh": {
            "app_title": "BreatheLens 瑞思迈数据分析",
            "subtitle": "选择 SD 卡导出的 ResMed 文件夹，自动解析 STR 与 DATALOG。",
            "choose_folder": "选择文件夹", "export_excel": "导出 Excel", "language": "语言",
            "folder_dialog": "选择瑞思迈数据文件夹", "export_dialog": "选择 Excel 输出目录",
            "tab_overview": "概览与建议", "tab_charts": "关键图表", "tab_str": "STR 汇总", "tab_datalog": "DATALOG", "tab_leak": "漏气观察",
            "overview": "概览", "advice": "调整建议", "leak_first": "先治漏气", "detail_table": "明细表",
            "chart_ahi": "AHI 趋势", "chart_leak": "95%漏气趋势", "chart_pressure": "95%压力趋势",
            "no_chart": "暂无图表数据", "threshold": "阈值",
            "unit_per_hour": "次/小时", "unit_l_min": "L/min", "unit_pressure": "cmH2O",
            "table_str_title": "STR 每日汇总", "table_datalog_title": "DATALOG 会话与事件", "table_leak_title": "漏气观察",
            "h_date": "日期", "h_usage": "使用(h)", "h_ahi": "AHI", "h_cai": "CAI", "h_oai": "OAI", "h_leak": "95%漏气",
            "h_pressure95": "95%压力", "h_min_pressure": "最小压", "h_max_pressure": "最大压", "h_duration": "时长(min)",
            "h_sessions": "会话", "h_events": "事件", "h_est_ahi": "估算AHI", "h_ca": "CA", "h_oa": "OA", "h_h": "H", "h_ua": "UA", "h_skipped": "跳过"
        },
        "en": {
            "app_title": "BreatheLens ResMed Data Analysis", "subtitle": "Choose a ResMed SD card folder and parse STR and DATALOG automatically.",
            "choose_folder": "Choose Folder", "export_excel": "Export Excel", "language": "Language",
            "folder_dialog": "Choose ResMed data folder", "export_dialog": "Choose Excel output folder",
            "tab_overview": "Overview & Advice", "tab_charts": "Charts", "tab_str": "STR Summary", "tab_datalog": "DATALOG", "tab_leak": "Leak Watch",
            "overview": "Overview", "advice": "Adjustment Advice", "leak_first": "Fix Leak First", "detail_table": "Details",
            "chart_ahi": "AHI Trend", "chart_leak": "95% Leak Trend", "chart_pressure": "95% Pressure Trend",
            "no_chart": "No chart data", "threshold": "Threshold", "unit_per_hour": "events/h", "unit_l_min": "L/min", "unit_pressure": "cmH2O",
            "table_str_title": "STR Daily Summary", "table_datalog_title": "DATALOG Sessions & Events", "table_leak_title": "Leak Watch",
            "h_date": "Date", "h_usage": "Usage(h)", "h_ahi": "AHI", "h_cai": "CAI", "h_oai": "OAI", "h_leak": "95% Leak",
            "h_pressure95": "95% Pressure", "h_min_pressure": "Min Pressure", "h_max_pressure": "Max Pressure", "h_duration": "Duration(min)",
            "h_sessions": "Sessions", "h_events": "Events", "h_est_ahi": "Est. AHI", "h_ca": "CA", "h_oa": "OA", "h_h": "H", "h_ua": "UA", "h_skipped": "Skipped"
        },
        "de": {
            "app_title": "BreatheLens ResMed-Datenanalyse", "subtitle": "ResMed-SD-Kartenordner wählen und STR sowie DATALOG automatisch analysieren.",
            "choose_folder": "Ordner wählen", "export_excel": "Excel exportieren", "language": "Sprache",
            "folder_dialog": "ResMed-Datenordner wählen", "export_dialog": "Excel-Ausgabeordner wählen",
            "tab_overview": "Überblick & Rat", "tab_charts": "Diagramme", "tab_str": "STR Übersicht", "tab_datalog": "DATALOG", "tab_leak": "Leckage",
            "overview": "Überblick", "advice": "Einstellhinweise", "leak_first": "Leck zuerst", "detail_table": "Details",
            "chart_ahi": "AHI-Verlauf", "chart_leak": "95%-Leckage", "chart_pressure": "95%-Druck",
            "no_chart": "Keine Diagrammdaten", "threshold": "Grenze", "unit_per_hour": "Ereignisse/h", "unit_l_min": "L/min", "unit_pressure": "cmH2O",
            "table_str_title": "STR Tagesübersicht", "table_datalog_title": "DATALOG Sitzungen & Ereignisse", "table_leak_title": "Leckagebeobachtung",
            "h_date": "Datum", "h_usage": "Nutzung(h)", "h_ahi": "AHI", "h_cai": "CAI", "h_oai": "OAI", "h_leak": "95% Leck",
            "h_pressure95": "95% Druck", "h_min_pressure": "Min. Druck", "h_max_pressure": "Max. Druck", "h_duration": "Dauer(min)",
            "h_sessions": "Sitzungen", "h_events": "Ereignisse", "h_est_ahi": "AHI gesch.", "h_ca": "CA", "h_oa": "OA", "h_h": "H", "h_ua": "UA", "h_skipped": "Überspr."
        },
        "fr": {
            "app_title": "BreatheLens Analyse ResMed", "subtitle": "Choisissez le dossier SD ResMed pour analyser STR et DATALOG automatiquement.",
            "choose_folder": "Choisir dossier", "export_excel": "Exporter Excel", "language": "Langue",
            "folder_dialog": "Choisir le dossier de données ResMed", "export_dialog": "Choisir le dossier de sortie Excel",
            "tab_overview": "Aperçu & conseils", "tab_charts": "Graphiques", "tab_str": "Résumé STR", "tab_datalog": "DATALOG", "tab_leak": "Fuites",
            "overview": "Aperçu", "advice": "Conseils de réglage", "leak_first": "Fuite d'abord", "detail_table": "Détails",
            "chart_ahi": "Tendance AHI", "chart_leak": "Fuite 95%", "chart_pressure": "Pression 95%",
            "no_chart": "Aucune donnée", "threshold": "Seuil", "unit_per_hour": "évén./h", "unit_l_min": "L/min", "unit_pressure": "cmH2O",
            "table_str_title": "Résumé quotidien STR", "table_datalog_title": "Sessions & événements DATALOG", "table_leak_title": "Suivi des fuites",
            "h_date": "Date", "h_usage": "Usage(h)", "h_ahi": "AHI", "h_cai": "CAI", "h_oai": "OAI", "h_leak": "Fuite 95%",
            "h_pressure95": "Pression 95%", "h_min_pressure": "Press. min", "h_max_pressure": "Press. max", "h_duration": "Durée(min)",
            "h_sessions": "Sessions", "h_events": "Événements", "h_est_ahi": "AHI estimé", "h_ca": "CA", "h_oa": "OA", "h_h": "H", "h_ua": "UA", "h_skipped": "Ignoré"
        },
        "ru": {
            "app_title": "BreatheLens анализ ResMed", "subtitle": "Выберите папку SD ResMed для автоматического разбора STR и DATALOG.",
            "choose_folder": "Выбрать папку", "export_excel": "Экспорт Excel", "language": "Язык",
            "folder_dialog": "Выберите папку данных ResMed", "export_dialog": "Выберите папку вывода Excel",
            "tab_overview": "Обзор и советы", "tab_charts": "Графики", "tab_str": "Сводка STR", "tab_datalog": "DATALOG", "tab_leak": "Утечки",
            "overview": "Обзор", "advice": "Рекомендации", "leak_first": "Сначала утечки", "detail_table": "Детали",
            "chart_ahi": "Тренд AHI", "chart_leak": "Утечка 95%", "chart_pressure": "Давление 95%",
            "no_chart": "Нет данных", "threshold": "Порог", "unit_per_hour": "событ./ч", "unit_l_min": "л/мин", "unit_pressure": "смH2O",
            "table_str_title": "Ежедневная сводка STR", "table_datalog_title": "Сессии и события DATALOG", "table_leak_title": "Контроль утечек",
            "h_date": "Дата", "h_usage": "Исп.(ч)", "h_ahi": "AHI", "h_cai": "CAI", "h_oai": "OAI", "h_leak": "Утечка 95%",
            "h_pressure95": "Давл. 95%", "h_min_pressure": "Мин. давл.", "h_max_pressure": "Макс. давл.", "h_duration": "Длит.(мин)",
            "h_sessions": "Сессии", "h_events": "События", "h_est_ahi": "Оцен. AHI", "h_ca": "CA", "h_oa": "OA", "h_h": "H", "h_ua": "UA", "h_skipped": "Пропуск"
        },
        "es": {
            "app_title": "BreatheLens análisis ResMed", "subtitle": "Elige la carpeta SD de ResMed y analiza STR y DATALOG automáticamente.",
            "choose_folder": "Elegir carpeta", "export_excel": "Exportar Excel", "language": "Idioma",
            "folder_dialog": "Elegir carpeta de datos ResMed", "export_dialog": "Elegir carpeta de salida Excel",
            "tab_overview": "Resumen y consejos", "tab_charts": "Gráficos", "tab_str": "Resumen STR", "tab_datalog": "DATALOG", "tab_leak": "Fugas",
            "overview": "Resumen", "advice": "Consejos de ajuste", "leak_first": "Primero fugas", "detail_table": "Detalles",
            "chart_ahi": "Tendencia AHI", "chart_leak": "Fuga 95%", "chart_pressure": "Presión 95%",
            "no_chart": "Sin datos", "threshold": "Umbral", "unit_per_hour": "eventos/h", "unit_l_min": "L/min", "unit_pressure": "cmH2O",
            "table_str_title": "Resumen diario STR", "table_datalog_title": "Sesiones y eventos DATALOG", "table_leak_title": "Vigilancia de fugas",
            "h_date": "Fecha", "h_usage": "Uso(h)", "h_ahi": "AHI", "h_cai": "CAI", "h_oai": "OAI", "h_leak": "Fuga 95%",
            "h_pressure95": "Presión 95%", "h_min_pressure": "Pres. mín", "h_max_pressure": "Pres. máx", "h_duration": "Duración(min)",
            "h_sessions": "Sesiones", "h_events": "Eventos", "h_est_ahi": "AHI est.", "h_ca": "CA", "h_oa": "OA", "h_h": "H", "h_ua": "UA", "h_skipped": "Omitido"
        },
        "pt": {
            "app_title": "BreatheLens análise ResMed", "subtitle": "Escolha a pasta SD ResMed e analise STR e DATALOG automaticamente.",
            "choose_folder": "Escolher pasta", "export_excel": "Exportar Excel", "language": "Idioma",
            "folder_dialog": "Escolher pasta de dados ResMed", "export_dialog": "Escolher pasta de saída Excel",
            "tab_overview": "Visão e conselhos", "tab_charts": "Gráficos", "tab_str": "Resumo STR", "tab_datalog": "DATALOG", "tab_leak": "Fugas",
            "overview": "Visão geral", "advice": "Sugestões de ajuste", "leak_first": "Fuga primeiro", "detail_table": "Detalhes",
            "chart_ahi": "Tendência AHI", "chart_leak": "Fuga 95%", "chart_pressure": "Pressão 95%",
            "no_chart": "Sem dados", "threshold": "Limite", "unit_per_hour": "eventos/h", "unit_l_min": "L/min", "unit_pressure": "cmH2O",
            "table_str_title": "Resumo diário STR", "table_datalog_title": "Sessões e eventos DATALOG", "table_leak_title": "Observação de fugas",
            "h_date": "Data", "h_usage": "Uso(h)", "h_ahi": "AHI", "h_cai": "CAI", "h_oai": "OAI", "h_leak": "Fuga 95%",
            "h_pressure95": "Pressão 95%", "h_min_pressure": "Press. mín", "h_max_pressure": "Press. máx", "h_duration": "Duração(min)",
            "h_sessions": "Sessões", "h_events": "Eventos", "h_est_ahi": "AHI est.", "h_ca": "CA", "h_oa": "OA", "h_h": "H", "h_ua": "UA", "h_skipped": "Ignorado"
        },
        "ja": {
            "app_title": "BreatheLens ResMed データ分析", "subtitle": "ResMed SDカードのフォルダを選び、STR と DATALOG を自動解析します。",
            "choose_folder": "フォルダ選択", "export_excel": "Excel出力", "language": "言語",
            "folder_dialog": "ResMed データフォルダを選択", "export_dialog": "Excel 出力先を選択",
            "tab_overview": "概要と提案", "tab_charts": "グラフ", "tab_str": "STR概要", "tab_datalog": "DATALOG", "tab_leak": "リーク",
            "overview": "概要", "advice": "調整提案", "leak_first": "リーク優先", "detail_table": "詳細",
            "chart_ahi": "AHI 推移", "chart_leak": "95%リーク", "chart_pressure": "95%圧力",
            "no_chart": "データなし", "threshold": "閾値", "unit_per_hour": "回/時", "unit_l_min": "L/min", "unit_pressure": "cmH2O",
            "table_str_title": "STR 日別概要", "table_datalog_title": "DATALOG セッションとイベント", "table_leak_title": "リーク確認",
            "h_date": "日付", "h_usage": "使用(h)", "h_ahi": "AHI", "h_cai": "CAI", "h_oai": "OAI", "h_leak": "95%リーク",
            "h_pressure95": "95%圧力", "h_min_pressure": "最小圧", "h_max_pressure": "最大圧", "h_duration": "時間(min)",
            "h_sessions": "セッション", "h_events": "イベント", "h_est_ahi": "推定AHI", "h_ca": "CA", "h_oa": "OA", "h_h": "H", "h_ua": "UA", "h_skipped": "スキップ"
        },
        "ko": {
            "app_title": "BreatheLens ResMed 데이터 분석", "subtitle": "ResMed SD 카드 폴더를 선택해 STR 및 DATALOG를 자동 분석합니다.",
            "choose_folder": "폴더 선택", "export_excel": "Excel 내보내기", "language": "언어",
            "folder_dialog": "ResMed 데이터 폴더 선택", "export_dialog": "Excel 출력 폴더 선택",
            "tab_overview": "개요 및 제안", "tab_charts": "차트", "tab_str": "STR 요약", "tab_datalog": "DATALOG", "tab_leak": "누출 관찰",
            "overview": "개요", "advice": "조정 제안", "leak_first": "누출 우선", "detail_table": "상세",
            "chart_ahi": "AHI 추세", "chart_leak": "95% 누출", "chart_pressure": "95% 압력",
            "no_chart": "차트 데이터 없음", "threshold": "임계값", "unit_per_hour": "회/시간", "unit_l_min": "L/min", "unit_pressure": "cmH2O",
            "table_str_title": "STR 일별 요약", "table_datalog_title": "DATALOG 세션 및 이벤트", "table_leak_title": "누출 관찰",
            "h_date": "날짜", "h_usage": "사용(h)", "h_ahi": "AHI", "h_cai": "CAI", "h_oai": "OAI", "h_leak": "95% 누출",
            "h_pressure95": "95% 압력", "h_min_pressure": "최소압", "h_max_pressure": "최대압", "h_duration": "시간(min)",
            "h_sessions": "세션", "h_events": "이벤트", "h_est_ahi": "추정 AHI", "h_ca": "CA", "h_oa": "OA", "h_h": "H", "h_ua": "UA", "h_skipped": "건너뜀"
        },
        "ar": {
            "app_title": "BreatheLens تحليل بيانات ResMed", "subtitle": "اختر مجلد بطاقة ResMed SD لتحليل STR و DATALOG تلقائيا.",
            "choose_folder": "اختيار مجلد", "export_excel": "تصدير Excel", "language": "اللغة",
            "folder_dialog": "اختيار مجلد بيانات ResMed", "export_dialog": "اختيار مجلد إخراج Excel",
            "tab_overview": "نظرة ونصائح", "tab_charts": "الرسوم", "tab_str": "ملخص STR", "tab_datalog": "DATALOG", "tab_leak": "التسرب",
            "overview": "نظرة عامة", "advice": "اقتراحات الضبط", "leak_first": "عالج التسرب أولا", "detail_table": "التفاصيل",
            "chart_ahi": "اتجاه AHI", "chart_leak": "تسرب 95%", "chart_pressure": "ضغط 95%",
            "no_chart": "لا توجد بيانات", "threshold": "الحد", "unit_per_hour": "حدث/ساعة", "unit_l_min": "L/min", "unit_pressure": "cmH2O",
            "table_str_title": "ملخص STR اليومي", "table_datalog_title": "جلسات وأحداث DATALOG", "table_leak_title": "مراقبة التسرب",
            "h_date": "التاريخ", "h_usage": "الاستخدام(h)", "h_ahi": "AHI", "h_cai": "CAI", "h_oai": "OAI", "h_leak": "تسرب 95%",
            "h_pressure95": "ضغط 95%", "h_min_pressure": "أدنى ضغط", "h_max_pressure": "أعلى ضغط", "h_duration": "المدة(min)",
            "h_sessions": "جلسات", "h_events": "أحداث", "h_est_ahi": "AHI تقديري", "h_ca": "CA", "h_oa": "OA", "h_h": "H", "h_ua": "UA", "h_skipped": "متجاهل"
        }
    })

    function tr(key) {
        var pack = i18n[languageCode] || i18n["en"]
        return pack[key] || i18n["en"][key] || key
    }

    function currentLanguageIndex() {
        for (var i = 0; i < languageOptions.length; i++) {
            if (languageOptions[i].code === languageCode) return i
        }
        return 0
    }

    function tabLabels() {
        return [tr("tab_overview"), tr("tab_charts"), tr("tab_str"), tr("tab_datalog"), tr("tab_leak")]
    }

    function chartTitle(title) {
        if (title.indexOf("漏气") >= 0) return tr("chart_leak")
        if (title.indexOf("压力") >= 0) return tr("chart_pressure")
        if (title.indexOf("AHI") >= 0) return tr("chart_ahi")
        return title
    }

    function chartUnit(unit) {
        if (unit === "次/小时") return tr("unit_per_hour")
        if (unit === "L/min") return tr("unit_l_min")
        if (unit === "cmH2O") return tr("unit_pressure")
        return unit
    }

    function tableHeader(label) {
        var map = {
            "日期": "h_date", "使用(h)": "h_usage", "AHI": "h_ahi", "CAI": "h_cai", "OAI": "h_oai",
            "95%漏气": "h_leak", "95%压力": "h_pressure95", "最小压": "h_min_pressure", "最大压": "h_max_pressure",
            "时长(min)": "h_duration", "会话": "h_sessions", "事件": "h_events", "估算AHI": "h_est_ahi",
            "CA": "h_ca", "OA": "h_oa", "H": "h_h", "UA": "h_ua", "跳过": "h_skipped"
        }
        return map[label] ? tr(map[label]) : label
    }

    function tableTitle() {
        if (activeTab === 2) return tr("table_str_title")
        if (activeTab === 3) return tr("table_datalog_title")
        if (activeTab === 4) return tr("table_leak_title")
        return tr("detail_table")
    }

    function localizedSummary() {
        if (!root.appBackend) return ""
        if (root.appBackend.summary === "未分析") {
            var pack = {
                "zh": "未分析", "en": "Not analyzed", "de": "Nicht analysiert", "fr": "Non analysé",
                "ru": "Не проанализировано", "es": "Sin analizar", "pt": "Não analisado",
                "ja": "未解析", "ko": "분석 전", "ar": "لم يتم التحليل"
            }
            return pack[languageCode] || pack["en"]
        }
        return root.appBackend.summary
    }

    function localizedStatus() {
        if (!root.appBackend) return ""
        if (root.appBackend.status === "请选择瑞思迈 SD 卡数据文件夹。") {
            var pack = {
                "zh": "请选择瑞思迈 SD 卡数据文件夹。",
                "en": "Please choose a ResMed SD card data folder.",
                "de": "Bitte einen ResMed-SD-Kartendatenordner wählen.",
                "fr": "Veuillez choisir un dossier de données SD ResMed.",
                "ru": "Выберите папку данных SD-карты ResMed.",
                "es": "Elija una carpeta de datos SD de ResMed.",
                "pt": "Escolha uma pasta de dados SD ResMed.",
                "ja": "ResMed SDカードのデータフォルダを選択してください。",
                "ko": "ResMed SD 카드 데이터 폴더를 선택하세요.",
                "ar": "يرجى اختيار مجلد بيانات بطاقة ResMed SD."
            }
            return pack[languageCode] || pack["en"]
        }
        return root.appBackend.status
    }

    function switchTab(index) {
        activeTab = index
        if (!root.appBackend) return
        if (index === 2) root.appBackend.setTableMode(0)
        else if (index === 3) root.appBackend.setTableMode(1)
        else if (index === 4) root.appBackend.setTableMode(2)
    }

    function applyLanguage(code) {
        languageCode = code
        if (root.appBackend) root.appBackend.setLanguage(languageCode)
    }

    function columnWidth(column) {
        var count = root.appBackend ? root.appBackend.tableHeaders.length : 0
        if (column === 0) return 120
        if (count >= 11) return 90
        if (count <= 7) return 120
        return 104
    }

    function colorForCell(column, value) {
        var headers = root.appBackend ? root.appBackend.tableHeaders : []
        var name = headers[column] || ""
        var numberValue = Number(value)
        if (name.indexOf("漏气") >= 0 && numberValue >= 24) return "#E11D48"
        if (name.indexOf("AHI") >= 0 && numberValue >= 5) return "#D97706"
        return "#1F2937"
    }

    FolderDialog {
        id: folderDialog
        title: root.tr("folder_dialog")
        onAccepted: root.appBackend.analyze(selectedFolder)
    }

    FolderDialog {
        id: exportDialog
        title: root.tr("export_dialog")
        onAccepted: root.appBackend.exportExcel(selectedFolder)
    }

    component PrimaryButton: Button {
        font.pixelSize: 14
        font.bold: true
        leftPadding: 18
        rightPadding: 18
        topPadding: 10
        bottomPadding: 10
        background: Rectangle {
            radius: 8
            color: parent.down ? "#05A854" : parent.hovered ? "#06B95D" : "#07C160"
            opacity: parent.enabled ? 1 : 0.55
        }
        contentItem: Text {
            text: parent.text
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font: parent.font
        }
    }

    component GhostButton: Button {
        font.pixelSize: 14
        leftPadding: 16
        rightPadding: 16
        topPadding: 10
        bottomPadding: 10
        background: Rectangle {
            radius: 8
            color: parent.hovered ? "#E9F7EF" : "#FFFFFF"
            border.color: "#DDE7E2"
            opacity: parent.enabled ? 1 : 0.55
        }
        contentItem: Text {
            text: parent.text
            color: "#1F2937"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font: parent.font
        }
    }

    component MetricChart: Rectangle {
        id: chartBox
        required property var series
        property int hoverIndex: -1
        property real hoverX: 0
        property real hoverY: 0
        property real graphLeft: 48
        property real graphRight: 18
        property real graphTop: 12
        property real graphBottom: 42
        property real graphMaxValue: 1
        Layout.fillWidth: true
        Layout.preferredHeight: 220
        radius: 10
        color: "#FFFFFF"
        border.color: "#E5E7EB"

        function updateHover(mouseX, mouseY, canvasWidth, canvasHeight) {
            var points = series.points || []
            if (points.length === 0) {
                hoverIndex = -1
                return
            }
            var graphW = Math.max(1, canvasWidth - graphLeft - graphRight)
            var graphH = Math.max(1, canvasHeight - graphTop - graphBottom)
            if (mouseX < graphLeft || mouseX > graphLeft + graphW || mouseY < graphTop || mouseY > graphTop + graphH) {
                hoverIndex = -1
                chartCanvas.requestPaint()
                return
            }
            var ratio = (mouseX - graphLeft) / graphW
            var index = Math.round(ratio * (points.length - 1))
            index = Math.max(0, Math.min(points.length - 1, index))
            hoverIndex = index
            hoverX = graphLeft + (points.length === 1 ? graphW : index / (points.length - 1) * graphW)
            hoverY = graphTop + graphH - (Number(points[index].value || 0) / graphMaxValue) * graphH
            chartCanvas.requestPaint()
        }

        Connections {
            target: root.appBackend
            function onChartSeriesChanged() {
                chartCanvas.requestPaint()
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Rectangle {
                    width: 10
                    height: 10
                    radius: 5
                    color: chartBox.series.color || "#07C160"
                }
                Text {
                    text: root.chartTitle(chartBox.series.title || "")
                    color: "#111827"
                    font.pixelSize: 15
                    font.bold: true
                    Layout.fillWidth: true
                }
                Text {
                    text: root.chartUnit(chartBox.series.unit || "")
                    color: "#6B7280"
                    font.pixelSize: 12
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Canvas {
                    id: chartCanvas
                    anchors.fill: parent
                    antialiasing: true
                    Component.onCompleted: requestPaint()
                    onWidthChanged: requestPaint()
                    onHeightChanged: requestPaint()
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        ctx.clearRect(0, 0, width, height)

                        var points = chartBox.series.points || []
                        var left = chartBox.graphLeft
                        var right = chartBox.graphRight
                        var top = chartBox.graphTop
                        var bottom = chartBox.graphBottom
                        var graphW = Math.max(1, width - left - right)
                        var graphH = Math.max(1, height - top - bottom)

                        ctx.strokeStyle = "#E5E7EB"
                        ctx.lineWidth = 1
                        ctx.beginPath()
                        ctx.moveTo(left, top)
                        ctx.lineTo(left, top + graphH)
                        ctx.lineTo(left + graphW, top + graphH)
                        ctx.stroke()

                        if (points.length === 0) {
                            ctx.fillStyle = "#9CA3AF"
                            ctx.font = "13px sans-serif"
                            ctx.fillText(root.tr("no_chart"), left + 8, top + 30)
                            return
                        }

                        var maxValue = Math.max(Number(chartBox.series.warning || 0), 1)
                        for (var i = 0; i < points.length; i++) {
                            maxValue = Math.max(maxValue, Number(points[i].value || 0))
                        }
                        maxValue = maxValue * 1.15
                        chartBox.graphMaxValue = maxValue

                        ctx.fillStyle = "#6B7280"
                        ctx.font = "11px sans-serif"
                        ctx.textAlign = "right"
                        ctx.fillText(maxValue.toFixed(maxValue >= 10 ? 0 : 1), left - 8, top + 8)
                        ctx.fillText("0", left - 8, top + graphH)

                        var tickCount = Math.min(7, points.length)
                        ctx.textAlign = "center"
                        ctx.strokeStyle = "#EEF2F0"
                        ctx.fillStyle = "#6B7280"
                        for (var tick = 0; tick < tickCount; tick++) {
                            var tickIndex = tickCount === 1 ? 0 : Math.round(tick / (tickCount - 1) * (points.length - 1))
                            var tickX = left + (points.length === 1 ? graphW : tickIndex / (points.length - 1) * graphW)
                            ctx.beginPath()
                            ctx.moveTo(tickX, top)
                            ctx.lineTo(tickX, top + graphH)
                            ctx.stroke()
                            ctx.fillText(points[tickIndex].label || "", tickX, top + graphH + 24)
                        }

                        var warning = Number(chartBox.series.warning || 0)
                        if (warning > 0) {
                            var warnY = top + graphH - (warning / maxValue) * graphH
                            ctx.strokeStyle = "#FCA5A5"
                            ctx.setLineDash([4, 4])
                            ctx.beginPath()
                            ctx.moveTo(left, warnY)
                            ctx.lineTo(left + graphW, warnY)
                            ctx.stroke()
                            ctx.setLineDash([])
                            ctx.fillStyle = "#E11D48"
                            ctx.textAlign = "left"
                            ctx.fillText(root.tr("threshold") + " " + warning, left + 8, warnY - 5)
                        }

                        ctx.strokeStyle = chartBox.series.color || "#07C160"
                        ctx.lineWidth = 2
                        ctx.beginPath()
                        for (var j = 0; j < points.length; j++) {
                            var x = left + (points.length === 1 ? graphW : j / (points.length - 1) * graphW)
                            var y = top + graphH - (Number(points[j].value || 0) / maxValue) * graphH
                            if (j === 0) ctx.moveTo(x, y)
                            else ctx.lineTo(x, y)
                        }
                        ctx.stroke()

                        ctx.fillStyle = chartBox.series.color || "#07C160"
                        var step = Math.max(1, Math.floor(points.length / 12))
                        for (var k = 0; k < points.length; k += step) {
                            var px = left + (points.length === 1 ? graphW : k / (points.length - 1) * graphW)
                            var py = top + graphH - (Number(points[k].value || 0) / maxValue) * graphH
                            ctx.beginPath()
                            ctx.arc(px, py, 2.5, 0, Math.PI * 2)
                            ctx.fill()
                        }

                        if (chartBox.hoverIndex >= 0) {
                            ctx.strokeStyle = "#111827"
                            ctx.globalAlpha = 0.28
                            ctx.lineWidth = 1
                            ctx.beginPath()
                            ctx.moveTo(chartBox.hoverX, top)
                            ctx.lineTo(chartBox.hoverX, top + graphH)
                            ctx.stroke()
                            ctx.globalAlpha = 1
                            ctx.fillStyle = "#111827"
                            ctx.beginPath()
                            ctx.arc(chartBox.hoverX, chartBox.hoverY, 4, 0, Math.PI * 2)
                            ctx.fill()
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton
                    onPositionChanged: function(mouse) {
                        chartBox.updateHover(mouse.x, mouse.y, width, height)
                    }
                    onExited: {
                        chartBox.hoverIndex = -1
                        chartCanvas.requestPaint()
                    }
                }

                Rectangle {
                    visible: chartBox.hoverIndex >= 0
                    width: Math.max(138, tooltipText.implicitWidth + 20)
                    height: 52
                    radius: 8
                    color: "#111827"
                    opacity: 0.94
                    x: Math.min(parent.width - width - 8, Math.max(8, chartBox.hoverX - width / 2))
                    y: Math.max(8, chartBox.hoverY - height - 12)
                    Text {
                        id: tooltipText
                        anchors.centerIn: parent
                        text: {
                            var points = chartBox.series.points || []
                            if (chartBox.hoverIndex < 0 || chartBox.hoverIndex >= points.length) return ""
                            var point = points[chartBox.hoverIndex]
                            return (point.date || point.label) + "\n" + point.value + " " + root.chartUnit(chartBox.series.unit || "")
                        }
                        color: "#FFFFFF"
                        font.pixelSize: 12
                        lineHeight: 1.2
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }

    component Panel: Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: 12
        color: "#FFFFFF"
        border.color: "#E5E7EB"
    }

    component TableHeader: Rectangle {
        Layout.fillWidth: true
        height: 38
        radius: 8
        color: "#F3F4F6"
        Row {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 0
            Repeater {
                model: root.appBackend ? root.appBackend.tableHeaders : []
                Text {
                    width: root.columnWidth(index)
                    height: 38
                    text: root.tableHeader(modelData)
                    color: "#4B5563"
                    font.bold: true
                    font.pixelSize: 12
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: index === 0 ? Text.AlignLeft : Text.AlignHCenter
                    elide: Text.ElideRight
                }
            }
        }
    }

    component DetailTable: TableView {
        id: table
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        model: tableModel
        columnSpacing: 0
        rowSpacing: 0
        columnWidthProvider: function(column) {
            return root.columnWidth(column)
        }
        rowHeightProvider: function(row) {
            return 34
        }
        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AlwaysOn
            active: true
        }
        delegate: Rectangle {
            required property var display
            required property int row
            required property int column
            implicitWidth: table.columnWidthProvider(column)
            implicitHeight: 34
            color: row % 2 === 0 ? "#FFFFFF" : "#FAFBFA"
            border.color: "#EEF2F0"
            Text {
                anchors.fill: parent
                anchors.leftMargin: column === 0 ? 8 : 2
                anchors.rightMargin: 2
                text: display
                color: root.colorForCell(column, display)
                font.pixelSize: 12
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: column === 0 ? Text.AlignLeft : Text.AlignHCenter
                elide: Text.ElideRight
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 22
        spacing: 14

        Rectangle {
            Layout.fillWidth: true
            height: root.appBackend && root.appBackend.busy ? 112 : 84
            radius: 12
            color: "#FFFFFF"
            border.color: "#E5E7EB"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 14

                    Rectangle {
                        width: 48
                        height: 48
                        radius: 12
                        color: "#07C160"
                        Text {
                            anchors.centerIn: parent
                            text: "R"
                            color: "white"
                            font.pixelSize: 24
                            font.bold: true
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Text {
                            text: root.tr("app_title")
                            color: "#111827"
                            font.pixelSize: 22
                            font.bold: true
                        }
                        Text {
                            text: root.appBackend && root.appBackend.folder.length > 0 ? root.appBackend.folder : root.tr("subtitle")
                            color: "#6B7280"
                            font.pixelSize: 13
                            elide: Text.ElideMiddle
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        spacing: 8
                        Text {
                            text: root.tr("language")
                            color: "#374151"
                            font.pixelSize: 13
                            verticalAlignment: Text.AlignVCenter
                        }
                        ComboBox {
                            id: languageBox
                            objectName: "languageBox"
                            model: root.languageOptions
                            textRole: "name"
                            valueRole: "code"
                            currentIndex: root.currentLanguageIndex()
                            implicitWidth: 132
                            onActivated: function(index) {
                                root.applyLanguage(root.languageOptions[index].code)
                            }
                        }
                    }

                    GhostButton {
                        text: root.tr("choose_folder")
                        enabled: root.appBackend && !root.appBackend.busy
                        onClicked: folderDialog.open()
                    }
                    PrimaryButton {
                        text: root.tr("export_excel")
                        enabled: root.appBackend && !root.appBackend.busy
                        onClicked: exportDialog.open()
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    visible: root.appBackend && root.appBackend.busy
                    spacing: 10
                    ProgressBar {
                        Layout.fillWidth: true
                        from: 0
                        to: 100
                        value: root.appBackend ? root.appBackend.progress : 0
                    }
                    Text {
                        width: 44
                        text: root.appBackend ? root.appBackend.progress + "%" : "0%"
                        color: "#047857"
                        font.pixelSize: 12
                        font.bold: true
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }

        Panel {
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    Rectangle {
                        id: tabStrip
                        objectName: "tabStrip"
                        Layout.fillWidth: true
                        height: 44
                        radius: 8
                        color: "#F3F4F6"
                        border.color: "#E5E7EB"
                        Row {
                            anchors.fill: parent
                            anchors.margins: 4
                            spacing: 4
                            Repeater {
                                model: root.tabLabels()
                                Rectangle {
                                    width: (tabStrip.width - 24) / 5
                                    height: 36
                                    radius: 7
                                    color: root.activeTab === index ? "#07C160" : "transparent"
                                    border.color: root.activeTab === index ? "#07C160" : "transparent"
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData
                                        color: root.activeTab === index ? "#FFFFFF" : "#374151"
                                        font.pixelSize: 14
                                        font.bold: root.activeTab === index
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.switchTab(index)
                                    }
                                }
                            }
                        }
                    }
                    BusyIndicator {
                        running: root.appBackend && root.appBackend.busy
                        visible: root.appBackend && root.appBackend.busy
                        implicitWidth: 28
                        implicitHeight: 28
                    }
                }

                StackLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    currentIndex: root.activeTab

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        RowLayout {
                            anchors.fill: parent
                            spacing: 14

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 10
                                color: "#FAFBFA"
                                border.color: "#E5E7EB"
                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 18
                                    spacing: 12
                                    Text {
                                        text: root.tr("overview")
                                        color: "#111827"
                                        font.pixelSize: 18
                                        font.bold: true
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        text: root.localizedSummary()
                                        color: "#374151"
                                        font.pixelSize: 15
                                        lineHeight: 1.28
                                        wrapMode: Text.WordWrap
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 10
                                color: "#FAFBFA"
                                border.color: "#E5E7EB"
                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 18
                                    spacing: 12
                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text {
                                            text: root.tr("advice")
                                            color: "#111827"
                                            font.pixelSize: 18
                                            font.bold: true
                                            Layout.fillWidth: true
                                        }
                                        Rectangle {
                                            radius: 8
                                            color: "#E9F7EF"
                                            width: 74
                                            height: 26
                                            Text {
                                                anchors.centerIn: parent
                                                text: root.tr("leak_first")
                                                color: "#07A855"
                                                font.pixelSize: 12
                                                font.bold: true
                                            }
                                        }
                                    }
                                    ScrollView {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        clip: true
                                        TextArea {
                                            text: root.appBackend ? root.appBackend.suggestions : ""
                                            readOnly: true
                                            wrapMode: Text.WordWrap
                                            color: "#374151"
                                            font.pixelSize: 15
                                            selectByMouse: true
                                            background: Rectangle { color: "transparent" }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    ScrollView {
                        id: chartScroll
                        clip: true
                        contentWidth: availableWidth
                        ColumnLayout {
                            width: chartScroll.availableWidth
                            spacing: 12
                            Repeater {
                                model: root.appBackend ? root.appBackend.chartSeries : []
                                MetricChart {
                                    required property var modelData
                                    series: modelData
                                }
                            }
                        }
                    }

                    TablePage {}
                    TablePage {}
                    TablePage {}
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 34
            radius: 8
            color: "#ECFDF3"
            Text {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                text: root.localizedStatus()
                color: "#047857"
                font.pixelSize: 13
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }
    }

    Component.onCompleted: {
        root.applyLanguage(root.languageCode)
    }

    component TablePage: Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
        ColumnLayout {
            anchors.fill: parent
            spacing: 10
            Text {
                Layout.fillWidth: true
                text: root.tableTitle()
                color: "#111827"
                font.pixelSize: 17
                font.bold: true
            }
            TableHeader {}
            DetailTable {}
        }
    }
}
