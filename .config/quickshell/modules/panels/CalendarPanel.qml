import QtQuick
import "../../theme"
import "../../components"

Item {
    id: root

    readonly property var today: new Date()
    readonly property var months: ["Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"]
    readonly property var weekdays: ["D", "S", "T", "Q", "Q", "S", "S"]
    readonly property int cell: 34

    property int year: today.getFullYear()
    property int month: today.getMonth()

    readonly property int offset: new Date(year, month, 1).getDay()

    function shift(step) {
        const d = new Date(year, month + step, 1)
        year = d.getFullYear()
        month = d.getMonth()
    }

    implicitWidth: cell * 7 + Theme.spacing.md * 2
    implicitHeight: col.implicitHeight + Theme.spacing.md * 2

    Column {
        id: col
        x: Theme.spacing.md
        y: Theme.spacing.md
        width: root.cell * 7
        spacing: Theme.spacing.xs

        Item {
            width: parent.width
            height: 28

            MouseArea {
                anchors.left: parent.left
                anchors.leftMargin: Theme.spacing.sm
                anchors.verticalCenter: parent.verticalCenter
                width: title.implicitWidth
                height: parent.height
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.year = root.today.getFullYear()
                    root.month = root.today.getMonth()
                }

                Text {
                    id: title
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.months[root.month] + " " + root.year
                    color: Theme.colors.text
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.normal + 1
                    font.weight: Font.Medium
                }
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                IconButton {
                    icon: "pan-start-symbolic"
                    size: 28
                    onClicked: root.shift(-1)
                }

                IconButton {
                    icon: "pan-end-symbolic"
                    size: 28
                    onClicked: root.shift(1)
                }
            }
        }

        Row {
            Repeater {
                model: root.weekdays

                delegate: Item {
                    required property string modelData

                    width: root.cell
                    height: 24

                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        color: Theme.colors.textDisabled
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.small
                    }
                }
            }
        }

        Grid {
            columns: 7

            Repeater {
                model: 42

                delegate: Item {
                    id: day

                    required property int index

                    readonly property var date: new Date(root.year, root.month, 1 - root.offset + index)
                    readonly property bool inMonth: date.getMonth() === root.month
                    readonly property bool isToday: date.toDateString() === root.today.toDateString()

                    width: root.cell
                    height: 30

                    Rectangle {
                        anchors.centerIn: parent
                        width: 28
                        height: 28
                        radius: 14
                        color: day.isToday ? Theme.colors.accent : "transparent"
                    }

                    Text {
                        anchors.centerIn: parent
                        text: day.date.getDate()
                        color: day.isToday ? Theme.colors.accentText : (day.inMonth ? Theme.colors.text : Theme.colors.textDisabled)
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.normal
                    }
                }
            }
        }
    }
}
