#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm \
    base-devel git \
    zip unzip unrar \
    vim flatpak \
    pipewire-audio pavucontrol \
    gstreamer gst-plugins-{base,good,bad,ugly} gst-libav \
    mpv imv \
    niri xwayland-satellite \
    rofi alacritty \
    xdg-desktop-portal-{gtk,gnome} \
    polkit-gnome gnome-keyring \
    adw-gtk-theme \
    noto-fonts noto-fonts-{emoji,cjk} ttf-{liberation,dejavu}

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

mkdir -p ~/.config
cp -r "$DIR/.config/." ~/.config/

gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark

sudo pacman -Scc --noconfirm
orphans=$(pacman -Qdtq) && sudo pacman -Rns --noconfirm $orphans

echo -e "\n\033[1;32mInstallation complete. Reboot the system.\033[0m"
