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

    function switchTab(index) {
        activeTab = index
        if (!root.appBackend) return
        if (index === 2) root.appBackend.setTableMode(0)
        else if (index === 3) root.appBackend.setTableMode(1)
        else if (index === 4) root.appBackend.setTableMode(2)
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
        title: "选择瑞思迈数据文件夹"
        onAccepted: root.appBackend.analyze(selectedFolder)
    }

    FolderDialog {
        id: exportDialog
        title: "选择 Excel 输出目录"
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
                    text: chartBox.series.title || ""
                    color: "#111827"
                    font.pixelSize: 15
                    font.bold: true
                    Layout.fillWidth: true
                }
                Text {
                    text: chartBox.series.unit || ""
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
                            ctx.fillText("暂无图表数据", left + 8, top + 30)
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
                            ctx.fillText("阈值 " + warning, left + 8, warnY - 5)
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
                            return (point.date || point.label) + "\n" + point.value + " " + (chartBox.series.unit || "")
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
                    text: modelData
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
                            text: "BreatheLens 瑞思迈数据分析"
                            color: "#111827"
                            font.pixelSize: 22
                            font.bold: true
                        }
                        Text {
                            text: root.appBackend && root.appBackend.folder.length > 0 ? root.appBackend.folder : "选择 SD 卡导出的 ResMed 文件夹，自动解析 STR 与 DATALOG。"
                            color: "#6B7280"
                            font.pixelSize: 13
                            elide: Text.ElideMiddle
                            Layout.fillWidth: true
                        }
                    }

                    GhostButton {
                        text: "选择文件夹"
                        enabled: root.appBackend && !root.appBackend.busy
                        onClicked: folderDialog.open()
                    }
                    PrimaryButton {
                        text: "导出 Excel"
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
                                model: ["概览与建议", "关键图表", "STR 汇总", "DATALOG", "漏气观察"]
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
                                        text: "概览"
                                        color: "#111827"
                                        font.pixelSize: 18
                                        font.bold: true
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        text: root.appBackend ? root.appBackend.summary : ""
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
                                            text: "调整建议"
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
                                                text: "先治漏气"
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
                text: root.appBackend ? root.appBackend.status : ""
                color: "#047857"
                font.pixelSize: 13
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }
    }

    component TablePage: Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
        ColumnLayout {
            anchors.fill: parent
            spacing: 10
            Text {
                Layout.fillWidth: true
                text: root.appBackend ? root.appBackend.tableTitle : "明细表"
                color: "#111827"
                font.pixelSize: 17
                font.bold: true
            }
            TableHeader {}
            DetailTable {}
        }
    }
}
