#!/bin/bash
dir=~/Imagens/Wallpapers
file=$(ls "$dir" | rofi -dmenu -p "Wallpaper") || exit
ln -sf "$dir/$file" ~/.config/niri/current-wallpaper
pkill swaybg
setsid -f swaybg -i ~/.config/niri/current-wallpaper -m fill
