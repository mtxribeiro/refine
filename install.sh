#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

build="git base-devel"
tools="vim flatpak"
audio="pipewire-audio"
codecs="gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav"
wayland="niri xwayland-satellite waybar swaybg"
apps="rofi alacritty pavucontrol nm-connection-editor nwg-bar"
portals="xdg-desktop-portal-gtk xdg-desktop-portal-gnome"
auth="polkit-gnome gnome-keyring"
theme="adw-gtk-theme"
fonts="noto-fonts noto-fonts-emoji noto-fonts-cjk ttf-liberation ttf-dejavu ttf-nerd-fonts-symbols"

sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm $build $tools $audio $codecs $wayland $apps $portals $auth $theme $fonts

if ! command -v yay &>/dev/null && ! command -v paru &>/dev/null; then
    until [[ $o =~ ^[1-3]$ ]]; do
        read -rp ":: AUR helper: 1) paru  2) yay  3) none (default=1): " o
        o=${o:-1}
    done

    if [[ $o != 3 ]]; then
        h=$([[ $o == 1 ]] && echo paru || echo yay)
        git clone "https://aur.archlinux.org/$h.git" /tmp/aurh
        (cd /tmp/aurh && makepkg -si --noconfirm)
    fi
fi

mkdir -p ~/.config ~/Imagens/Wallpapers

cp -r "$DIR/.config/." ~/.config/

gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark

sudo pacman -Scc --noconfirm

orphans=$(pacman -Qdtq)
if [[ -n "$orphans" ]]; then
    sudo pacman -Rns --noconfirm $orphans
fi

echo -e "\n\033[1;32mInstallation complete. Reboot the system.\033[0m"
