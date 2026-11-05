#!/usr/bin/env bash

DIR="$HOME/Imagens/Wallpapers"
CACHE="$HOME/.cache/current-wallpaper"

apply() {
    old=$(pgrep -x swaybg)
    setsid -f swaybg -i "$1" -m fill >/dev/null 2>&1
    sleep 0.3
    [[ -n "$old" ]] && kill $old
    echo "$1" > "$CACHE"
}

if [[ "$1" == "--restore" ]]; then
    [[ -f "$CACHE" && -f "$(cat "$CACHE")" ]] && apply "$(cat "$CACHE")"
    exit 0
fi

choice=$(
    find "$DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -printf '%P\n' \
    | sort \
    | while IFS= read -r f; do
        printf '%s\0icon\x1f%s\n' "$f" "$DIR/$f"
    done \
    | rofi -dmenu -show-icons -theme "$HOME/.config/rofi/wallpaper.rasi"
)

[[ -n "$choice" ]] && apply "$DIR/$choice"
