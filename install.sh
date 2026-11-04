#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo pacman -Syu --noconfirm

sudo pacman -S --needed --noconfirm \
    pipewire-audio \
    gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav \
    xdg-desktop-portal-gtk xdg-desktop-portal-gnome \
    polkit-gnome gnome-keyring \
    noto-fonts noto-fonts-emoji noto-fonts-cjk ttf-liberation ttf-dejavu \
    base-devel flatpak zip unzip unrar vim \
    niri xwayland-satellite rofi \
    alacritty pavucontrol mpv imv

if ! command -v yay &>/dev/null && ! command -v paru &>/dev/null; then
    o=""
    while [[ "$o" != 1 && "$o" != 2 && "$o" != 3 ]]; do
        printf ":: Existem 3 opções disponíveis para AUR helper:\n"
        printf "   1) paru  2) yay  3) nenhum\n\n"
        read -rp "Digite um número (padrão=1): " o
        o=${o:-1}
    done

    AUR_HELPER=$([[ $o == 1 ]] && echo paru || ([[ $o == 2 ]] && echo yay))

    if [[ -n "$AUR_HELPER" ]]; then
        git clone "https://aur.archlinux.org/${AUR_HELPER}.git" /tmp/aurh
        cd /tmp/aurh && makepkg -si --noconfirm && cd -
    fi
fi

mkdir -p ~/.config

cp -r "$SCRIPT_DIR/.config/"* ~/.config/

sudo pacman -Scc --noconfirm

orphans=$(pacman -Qdtq || true)
if [[ -n "$orphans" ]]; then
    sudo pacman -Rns --noconfirm $orphans
fi

echo -e "\n\033[1;32mInstalação concluída. Reinicie o sistema.\033[0m"
