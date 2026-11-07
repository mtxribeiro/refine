#!/usr/bin/env bash

DIR="$HOME/Imagens/Wallpapers"
DEFAULT="$DIR/default.jpg"
CACHE="$HOME/.cache/current-wallpaper"
LOCK="$HOME/.config/hypr/hyprlock.conf"

apply() {
    old=$(pgrep -x swaybg)
    setsid -f swaybg -i "$1" -m fill >/dev/null 2>&1
    sleep 0.3
    [[ -n $old ]] && kill $old
    echo "$1" > "$CACHE"
    sed -i "/^background {/,/^}/ s|^\([[:space:]]*path[[:space:]]*=\).*|\1 ${1//&/\\&}|" "$LOCK" 2>/dev/null
}

if [[ $1 == --restore ]]; then
    wall=$(cat "$CACHE" 2>/dev/null)
    [[ -f $wall ]] || wall=$DEFAULT
    [[ -f $wall ]] && apply "$wall"
    exit
fi

[[ -f $1 ]] && apply "$1"
