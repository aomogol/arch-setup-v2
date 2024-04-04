#!/bin/bash
set -e
#######################################################
# Author    : Ahmet Önder Moğol
#######################################################
echo
tput setaf 3
echo "################################################################"
echo "################### NVIDIA install "
echo "################################################################"
tput sgr0
echo


echo "################### Graphics drive & tools- "
# Graphics Drivers find and install
if lspci | grep -E "NVIDIA|GeForce"; then
	yay -S --needed --noconfirm nvidia-dkms
    yay -S --needed --noconfirm nvidia-settings 
	yay -S --needed --noconfirm nvidia-utils 
	yay -S --needed --noconfirm lib32-nvidia-utils
    
elif lspci | grep -E "Radeon"; then
    yay -S --needed --noconfirm xf86-video-amdgpu

#elif lspci | grep -E "Integrated Graphics Controller"; then
#    yay -S --needed --noconfirm  libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils

echo -e "\nDone!\n"

# Optimus GPU switcher
# https://store.kde.org/p/2053791/


#yay -S --needed --noconfirm envycontrol


list=(

)


###############################################################################
echo "NVIDIA Installation Complete"
###############################################################################
