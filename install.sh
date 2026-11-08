#!/bin/bash

cd "$(dirname "$0")"

build="git base-devel"
tools="vim"
audio="pipewire-audio pavucontrol"
keys="playerctl brightnessctl"
network="nm-connection-editor"
codecs="gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav"
wayland="niri xwayland-satellite swaybg quickshell"
apps="alacritty nautilus"
portals="xdg-desktop-portal-gtk xdg-desktop-portal-gnome"
auth="polkit-gnome gnome-keyring"
theme="adw-gtk-theme"
fonts="noto-fonts noto-fonts-emoji noto-fonts-cjk ttf-liberation ttf-dejavu"

sudo pacman -Syu --needed --noconfirm $build $tools $audio $keys $network $codecs $wayland $apps $portals $auth $theme $fonts

if ! command -v yay &>/dev/null && ! command -v paru &>/dev/null; then
    until [[ $o =~ ^[1-3]$ ]]; do
        read -rp ":: AUR helper: 1) paru  2) yay  3) none (default=1): " o
        o=${o:-1}
    done

    if [[ $o != 3 ]]; then
        h=paru
        [[ $o == 2 ]] && h=yay
        git clone "https://aur.archlinux.org/$h.git" /tmp/aurh
        (cd /tmp/aurh && makepkg -si --noconfirm)
    fi
fi

mkdir -p ~/.config ~/Imagens
cp -r .config/* ~/.config/
cp -r Wallpapers ~/Imagens/

gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark

orphans=$(pacman -Qdtq)
[[ -n $orphans ]] && sudo pacman -Rns --noconfirm $orphans

sudo pacman -Scc --noconfirm

echo -e "\n\033[1;32mInstallation complete. Reboot the system.\033[0m"
