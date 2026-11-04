#!/bin/bash
shopt -s nullglob nocaseglob extglob
dir=~/Imagens/Wallpapers
link=~/.config/niri/.current-wallpaper
step=1
[[ $1 == prev ]] && step=-1

files=("$dir"/*.@(jpg|jpeg|png|webp))
n=${#files[@]}
(( n )) || exit

current=$(readlink -f "$link")
idx=-1
for i in "${!files[@]}"; do
    [[ $(readlink -f "${files[i]}") == "$current" ]] && idx=$i && break
done

next=${files[(idx + step + n) % n]}
ln -sf "$next" "$link"

old=$(pgrep swaybg)
setsid -f swaybg -i "$link" -m fill
sleep 0.5
[[ -n $old ]] && kill $old
