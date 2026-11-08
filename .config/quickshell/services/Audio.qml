pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property real micVolume: source?.audio?.volume ?? 0
    readonly property bool micMuted: source?.audio?.muted ?? false

    readonly property string icon: {
        if (muted || volume === 0)
            return "audio-volume-muted-symbolic"
        if (volume < 0.34)
            return "audio-volume-low-symbolic"
        if (volume < 0.67)
            return "audio-volume-medium-symbolic"
        return "audio-volume-high-symbolic"
    }

    readonly property string micIcon: micMuted ? "microphone-disabled-symbolic" : "microphone-sensitivity-high-symbolic"

    function clamp(value) {
        return Math.max(0, Math.min(1, value))
    }

    function setVolume(value) {
        if (sink?.audio)
            sink.audio.volume = clamp(value)
    }

    function toggleMute() {
        if (sink?.audio)
            sink.audio.muted = !sink.audio.muted
    }

    function setMicVolume(value) {
        if (source?.audio)
            source.audio.volume = clamp(value)
    }

    function toggleMicMute() {
        if (source?.audio)
            source.audio.muted = !source.audio.muted
    }

    PwObjectTracker {
        objects: [root.sink, root.source]
    }
}
