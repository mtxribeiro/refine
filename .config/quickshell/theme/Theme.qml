pragma Singleton

import Quickshell
import QtQuick

Singleton {
    readonly property QtObject colors: QtObject {
        readonly property color background: "#161616"
        readonly property color surface: "#1e1e1e"
        readonly property color surfaceVariant: "#262626"
        readonly property color surfaceHigh: "#2e2e2e"
        readonly property color border: "#33ffffff"
        readonly property color borderStrong: "#4dffffff"
        readonly property color hover: "#14ffffff"
        readonly property color pressed: "#1fffffff"
        readonly property color text: "#f2f2f2"
        readonly property color textSecondary: "#a8a8a8"
        readonly property color textDisabled: "#6b6b6b"
        readonly property color accent: "#e6e6e6"
        readonly property color accentText: "#161616"
        readonly property color overlay: "#99000000"
    }

    readonly property QtObject radius: QtObject {
        readonly property int small: 8
        readonly property int medium: 12
        readonly property int large: 16
        readonly property int full: 999
    }

    readonly property QtObject spacing: QtObject {
        readonly property int xs: 4
        readonly property int sm: 8
        readonly property int md: 12
        readonly property int lg: 16
        readonly property int xl: 24
    }

    readonly property QtObject font: QtObject {
        readonly property string family: "Noto Sans"
        readonly property int small: 11
        readonly property int normal: 13
        readonly property int large: 15
        readonly property int title: 18
    }

    readonly property QtObject bar: QtObject {
        readonly property int height: 36
    }

    readonly property QtObject anim: QtObject {
        readonly property int instant: 70
        readonly property int fast: 90
        readonly property int normal: 120
        readonly property int slow: 180
        readonly property int easing: Easing.OutCubic
    }
}
