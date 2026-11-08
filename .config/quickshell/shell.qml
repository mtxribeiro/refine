//@ pragma UseQApplication

import Quickshell
import Quickshell.Io
import QtQuick
import "services"
import "modules/bar"
import "modules/panels"
import "modules/launcher"
import "modules/lock"
import "modules/wallpaper"

ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {}
    }

    Variants {
        model: Quickshell.screens

        PanelHost {}
    }

    Launcher {
        id: launcher
    }

    WallpaperPicker {
        id: wallpaperPicker
    }

    Lock {}

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            launcher.shown = !launcher.shown
        }

        function open(): void {
            launcher.shown = true
        }

        function close(): void {
            launcher.shown = false
        }
    }

    IpcHandler {
        target: "wallpaper"

        function toggle(): void {
            wallpaperPicker.shown = !wallpaperPicker.shown
        }

        function open(): void {
            wallpaperPicker.shown = true
        }

        function close(): void {
            wallpaperPicker.shown = false
        }
    }

    IpcHandler {
        target: "session"

        function lock(): void {
            Session.lock()
        }

        function unlock(): void {
            Session.unlock()
        }
    }
}
