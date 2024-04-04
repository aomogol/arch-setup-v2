#!/bin/bash
set -e
##################################################################################################################
# Author    : Ahmet Önder Moğol
##################################################################################################################
echo "################################################################"
echo "################### Pipewire Install "
echo "################################################################"
##################################################################################################################
#https://wiki.archlinux.org/title/PipeWire
#starting on an ArcoLinuxL iso
#https://wiki.archlinux.org/title/PipeWire#Bluetooth_devices
#compare
yay -Rdd --noconfirm gnome-bluetooth 
yay -Rdd --noconfirm blueberry
yay -Rdd --noconfirm jack2
yay -Rdd --noconfirm pulseaudio-alsa
yay -Rdd --noconfirm pulseaudio-bluetooth
yay -Rdd --noconfirm pulseaudio
yay -Rdd --noconfirm pipewire-media-session
#yay -R --noconfirm pipewire-pulse
#yay -R --noconfirm pipewire-alsa
#yay -Rdd --noconfirm pipewire-jack
#yay -R --noconfirm pipewire-zeroconf
#yay -Rdd --noconfirm pipewire
#yay -R --noconfirm pipewire-media-session
yay -S --needed --noconfirm pipewire
yay -S --needed --noconfirm lib32-pipewire
yay -S --needed --noconfirm pipewire-alsa
yay -S --needed --noconfirm pipewire-jack
yay -S --needed --noconfirm lib32-pipewire-jack
yay -S --needed --noconfirm pipewire-zeroconf
yay -S --needed --noconfirm pipewire-pulse
#yay -S --needed --noconfirm gnome-bluetooth
yay -S --needed --noconfirm blueberry
yay -S --needed --noconfirm wireplumber
#sudo systemctl enable bluetooth.service

echo "Reboot now"
echo
echo "################################################################"
echo "################### Pipewire Install = Done "
echo "################################################################"

