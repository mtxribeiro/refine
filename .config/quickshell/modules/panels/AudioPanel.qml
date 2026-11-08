import QtQuick
import "../../theme"
import "../../components"
import "../../services"

Item {
    id: root

    implicitWidth: 280
    implicitHeight: col.implicitHeight + Theme.spacing.md * 2

    Column {
        id: col
        x: Theme.spacing.md
        y: Theme.spacing.md
        width: parent.width - Theme.spacing.md * 2
        spacing: Theme.spacing.md

        VolumeRow {
            width: parent.width
            title: Audio.sink ? "Saída  ·  " + Audio.sink.description : "Nenhuma saída de áudio"
            icon: Audio.icon
            value: Audio.volume
            muted: Audio.muted
            onMoved: v => Audio.setVolume(v)
            onMuteToggled: Audio.toggleMute()
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.colors.border
        }

        VolumeRow {
            width: parent.width
            title: Audio.source ? "Entrada  ·  " + Audio.source.description : "Nenhum microfone"
            icon: Audio.micIcon
            value: Audio.micVolume
            muted: Audio.micMuted
            onMoved: v => Audio.setMicVolume(v)
            onMuteToggled: Audio.toggleMicMute()
        }
    }
}
