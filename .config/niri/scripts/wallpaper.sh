#!/bin/bash
shopt -s nullglob nocaseglob
dir=~/Imagens/Wallpapers
file=$(for f in "$dir"/*.{jpg,jpeg,png,webp}; do
    printf '%s\0icon\x1f%s\n' "${f##*/}" "$f"
done | rofi -dmenu -show-icons -p "Wallpaper") || exit
ln -sf "$dir/$file" ~/.config/niri/.current-wallpaper
pkill swaybg
setsid -f swaybg -i ~/.config/niri/.current-wallpaper -m fill
