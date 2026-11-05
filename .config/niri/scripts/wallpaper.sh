#!/usr/bin/env bash

DIR="$HOME/Imagens/Wallpapers"
DEFAULT="$DIR/current.jpg"
CACHE="$HOME/.cache/current-wallpaper"
LOCK_CONF="$HOME/.config/hypr/hyprlock.conf"
THUMBS="${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper-thumbs"

apply() {
    old=$(pgrep -x swaybg)
    setsid -f swaybg -i "$1" -m fill >/dev/null 2>&1
    sleep 0.3
    [[ -n "$old" ]] && kill $old
    echo "$1" > "$CACHE"
    [[ -f "$LOCK_CONF" ]] && sed -i "/^background {/,/^}/ s|^\([[:space:]]*path[[:space:]]*=\).*|\1 ${1//&/\\&}|" "$LOCK_CONF"
}

thumb() {
    local src="$DIR/$1"
    local out="$THUMBS/${1//\//_}.png"
    if [[ ! -f "$out" || "$src" -nt "$out" ]]; then
        magick "${src}[0]" -resize 300x200^ -gravity center -extent 300x200 \
            \( -size 300x200 xc:black -fill white -draw "roundrectangle 0,0,299,199,24,24" \) \
            -alpha off -compose copy_opacity -composite "$out" 2>/dev/null
    fi
    printf '%s' "$out"
}

if [[ "$1" == "--restore" ]]; then
    wall=""
    [[ -f "$CACHE" ]] && wall=$(cat "$CACHE")
    [[ -f "$wall" ]] || wall="$DEFAULT"
    [[ -f "$wall" ]] && apply "$wall"
    exit 0
fi

mkdir -p "$THUMBS"

choice=$(
    find "$DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -printf '%P\n' \
    | sort \
    | while IFS= read -r f; do
        printf '%s\0icon\x1f%s\n' "$f" "$(thumb "$f")"
    done \
    | rofi -dmenu -show-icons -theme "$HOME/.config/rofi/wallpaper.rasi"
)

[[ -n "$choice" ]] && apply "$DIR/$choice"
