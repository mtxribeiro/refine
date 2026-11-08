import Quickshell
import QtQuick
import "../../components"

BarButton {
    id: root

    readonly property var days: ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"]
    readonly property var months: ["Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"]

    function pad(n) {
        return String(n).padStart(2, "0")
    }

    label: `${days[clock.date.getDay()]}, ${clock.date.getDate()} de ${months[clock.date.getMonth()]} ${pad(clock.date.getHours())}:${pad(clock.date.getMinutes())}`

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
