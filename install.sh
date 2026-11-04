#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

build="git base-devel"
archive="zip unzip unrar"
tools="vim flatpak"
audio="pipewire-audio pavucontrol"
codecs="gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav"
viewers="mpv imv"
wayland="niri xwayland-satellite swaybg"
apps="rofi alacritty"
portals="xdg-desktop-portal-gtk xdg-desktop-portal-gnome"
auth="polkit-gnome gnome-keyring"
theme="adw-gtk-theme"
fonts="noto-fonts noto-fonts-emoji noto-fonts-cjk ttf-liberation ttf-dejavu"

sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm $build $archive $tools $audio $codecs $viewers $wayland $apps $portals $auth $theme $fonts

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
orphans=$(pacman -Qdtq) && sudo pacman -Rns --noconfirm $orphans

echo -e "\n\033[1;32mInstallation complete. Reboot the system.\033[0m"
