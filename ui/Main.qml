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

    FontLoader { id: uiFont; source: "" }

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
        }
        contentItem: Text {
            text: parent.text
            color: "#1F2937"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font: parent.font
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 22
        spacing: 16

        Rectangle {
            Layout.fillWidth: true
            height: 84
            radius: 12
            color: "#FFFFFF"
            border.color: "#E5E7EB"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 18
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
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 16

            ColumnLayout {
                Layout.preferredWidth: 390
                Layout.fillHeight: true
                spacing: 16

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 230
                    radius: 12
                    color: "#FFFFFF"
                    border.color: "#E5E7EB"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 10
                        Text {
                            text: "概览"
                            color: "#111827"
                            font.pixelSize: 17
                            font.bold: true
                        }
                        Text {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            text: root.appBackend ? root.appBackend.summary : ""
                            color: "#374151"
                            font.pixelSize: 14
                            lineHeight: 1.25
                            wrapMode: Text.WordWrap
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 12
                    color: "#FFFFFF"
                    border.color: "#E5E7EB"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 10
                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "调整建议"
                                color: "#111827"
                                font.pixelSize: 17
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
                                font.pixelSize: 14
                                selectByMouse: true
                                background: Rectangle { color: "transparent" }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 12
                color: "#FFFFFF"
                border.color: "#E5E7EB"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "每日汇总"
                            color: "#111827"
                            font.pixelSize: 17
                            font.bold: true
                            Layout.fillWidth: true
                        }
                        BusyIndicator {
                            running: root.appBackend && root.appBackend.busy
                            visible: root.appBackend && root.appBackend.busy
                            implicitWidth: 28
                            implicitHeight: 28
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 36
                        radius: 8
                        color: "#F3F4F6"
                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 0
                            Repeater {
                                model: ["日期", "使用(h)", "AHI", "CAI", "OAI", "95%漏气", "95%压力", "最小压", "最大压"]
                                Text {
                                    width: index === 0 ? 112 : 82
                                    height: 36
                                    text: modelData
                                    color: "#4B5563"
                                    font.bold: true
                                    font.pixelSize: 12
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: index === 0 ? Text.AlignLeft : Text.AlignHCenter
                                }
                            }
                        }
                    }

                    TableView {
                        id: table
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: tableModel
                        columnSpacing: 0
                        rowSpacing: 0

                        columnWidthProvider: function(column) {
                            return column === 0 ? 112 : 82
                        }
                        rowHeightProvider: function(row) {
                            return 34
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
                                color: {
                                    if (column === 5 && Number(display) >= 24) return "#E11D48"
                                    if (column === 2 && Number(display) >= 5) return "#D97706"
                                    return "#1F2937"
                                }
                                font.pixelSize: 12
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: column === 0 ? Text.AlignLeft : Text.AlignHCenter
                                elide: Text.ElideRight
                            }
                        }
                    }
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
}
