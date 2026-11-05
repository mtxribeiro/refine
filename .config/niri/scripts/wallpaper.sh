#!/usr/bin/env bash

DIR="$HOME/Imagens/Wallpapers"
DEFAULT="$DIR/current.jpg"
CACHE="$HOME/.cache/current-wallpaper"
LOCK_CONF="$HOME/.config/hypr/hyprlock.conf"

apply() {
    old=$(pgrep -x swaybg)
    setsid -f swaybg -i "$1" -m fill >/dev/null 2>&1
    sleep 0.3
    [[ -n "$old" ]] && kill $old
    echo "$1" > "$CACHE"
    [[ -f "$LOCK_CONF" ]] && sed -i "/^background {/,/^}/ s|^\([[:space:]]*path[[:space:]]*=\).*|\1 ${1//&/\\&}|" "$LOCK_CONF"
}

if [[ "$1" == "--restore" ]]; then
    wall=""
    [[ -f "$CACHE" ]] && wall=$(cat "$CACHE")
    [[ -f "$wall" ]] || wall="$DEFAULT"
    [[ -f "$wall" ]] && apply "$wall"
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
