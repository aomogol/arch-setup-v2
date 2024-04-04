#!/bin/bash
set -e
#######################################################
# Author    : Ahmet Önder Moğol
#######################################################
sudo pacman -S --needed --noconfirm figlet
figlet "AOMogol"
figlet "Packages Install"

# ------------------------------------------------------
# Check if yay is installed
# ------------------------------------------------------
echo -e "${GREEN}"
    figlet "yay"
echo -e "${NONE}"
if sudo pacman -Qs yay > /dev/null ; then
    echo ":: yay is already installed!"
else
    echo ":: yay is not installed. Starting the installation!"
    #_installPackagesPacman "base-devel"
    SCRIPT=$(realpath "$0")
    temp_path=$(dirname "$SCRIPT")
    echo $temp_path
    git clone https://aur.archlinux.org/yay-bin.git ~/yay-bin
    cd ~/yay-bin
    makepkg -si
    cd $temp_path
    echo ":: yay has been installed successfully."
fi
echo ""

# ------------------------------------------------------
# Pacman.conf file
# ------------------------------------------------------
echo "########## /etc/pacman.conf düzenleme color ve paralel download"
# sudo nano /etc/pacman.conf
echo "Pacman parallel downloads set to 20"
	FIND="#ParallelDownloads = 5"
	REPLACE="ParallelDownloads = 20"
	sudo sed -i "s/$FIND/$REPLACE/g" /etc/pacman.conf

echo "Color"
	FIND="#Color"
	REPLACE="Color"
	sudo sed -i "s/$FIND/$REPLACE/g" /etc/pacman.conf

# ------------------------------------------------------
# Updates
# ------------------------------------------------------
# 
yay -Syyu --noconfirm

# ------------------------------------------------------
# List of packages to install
# ------------------------------------------------------
# 
packages=(
    base-devel
    git
    linux-headers
    neofetch
    wget
    bash-completion
    thorium-browser-bin
    chromium
    firefox
    brave-bin
    google-chrome
    qbittorrent
    bat
    tldr
    ncdu

    zoom
    discord
    telegram-desktop

    btop
    htop
    gvfs-mtp
    ntfs-3g
    nfs-utils
    cifs-utils
    dosfstools
    exfatprogs
    paru-bin
    pkgcacheclean
    pacman-contrib
    reflector
    rate-mirrors

    sddm-kcm
    kdegraphics-thumbnailers
    kdesdk-thumbnailers
    kdenetwork-filesharing
    konsave
    systemd-kcm
    systemd-manager-git
    ark
    dolphin
    dolphin-plugins
    partitionmanager
    gparted
    grub-customizer
    update-grub
    gnome-firmware
    inxi
    rsync
    ripgrep
    trash-cli
    duf
    syncthing
    file-roller
    unarchiver
    p7zip
    zip
    unrar
    unzip
    peazip
    kdeconnect
    gvfs
    gvfs-smb
    samba
    avahi
    traceroute
    warpinator
    nss-mdns
    networkmanager-openvpn
    bind
    dnsdiag
    netplan
    localsend-bin

    ttf-meslo-nerd-font-powerlevel10k
    powerline-fonts
    ttf-ms-fonts
    awesome-terminal-fonts
    ttf-ubuntu-font-family
    ttf-hack
    ttf-roboto
    adobe-source-sans-fonts

    okular
    sublime-text-4
    visual-studio-code-bin
    meld
    gedit
    thunderbird
    onlyoffice

    spotify
    vlc
    aribb24
    spectacle
    simplescreenrecorder-bin
    svgpart
    gwenview

    github-cli
    github-desktop-bin
    docker
    docker-compose
    
    archiso
    downgrade
    caffeine-ng

    terminator
    terminus-font
    starship
    zoxide
)

# ------------------------------------------------------
# Install packages using yay
# ------------------------------------------------------
# 
for package in "${packages[@]}"; do
    if yay -Qi "$package" &> /dev/null; then
        tput setaf 2
  		echo "###############################################################################"
  		echo "################## The package "$1 - $package " is already installed"
      	echo "###############################################################################"
      	echo
		tput sgr0
    else
       	tput setaf 3
    	echo "###############################################################################"
    	echo "##################  Installing package "  $1 - $package
    	echo "###############################################################################"
    	echo
    	tput sgr0
        yay -S --noconfirm --needed "$package"
    fi
done

# ------------------------------------------------------
# All packages installed
# ------------------------------------------------------
# 
      	tput setaf 3
    	echo "###############################################################################"
    	echo "##################  All packages installed successfully."
    	echo "###############################################################################"
    	echo
    	tput sgr0

# ------------------------------------------------------
# User groups
# ------------------------------------------------------
# 
# EDITOR=nano sudo -E visudo
sudo usermod -aG wheel $USER
sudo usermod -aG users,power,lp,adm,audio,video,optical,storage,network,rfkill $USER

# ------------------------------------------------------
# determine processor type and install microcode
# ------------------------------------------------------
#
    tput setaf 3
    echo "###############################################################################"
    echo "##################  Installing microcode ."
    echo "###############################################################################"
    echo
    tput sgr0

echo "Installing Intel microcode"
proc_type=$(lscpu | awk '/Vendor ID:/ {print $3}')
case "$proc_type" in
	GenuineIntel)
		echo "Installing Intel microcode"
		yay -S --needed --noconfirm intel-ucode
		proc_ucode=intel-ucode.img
		;;
	AuthenticAMD)
		echo "Installing AMD microcode"
		yay -S --needed --noconfirm amd-ucode
		proc_ucode=amd-ucode.img
		;;
esac	

# ------------------------------------------------------
# CD / DVD burn 
# ------------------------------------------------------
# yay -S --needed k3b cdrtools dvd+rw-tools vcdimager emovix cdrdao cdparanoia

# ------------------------------------------------------
# DUF control
# ------------------------------------------------------
if [ ! -f /usr/bin/duf ]; then
    yay -S --needed --noconfirm duf
fi

# ------------------------------------------------------
# # Syncthing service
# ------------------------------------------------------
sudo systemctl enable --now syncthing@aom.service

# ------------------------------------------------------
### services enable
# ------------------------------------------------------
sudo systemctl enable avahi-daemon.service
#sudo systemctl enable bluetooth 


# ------------------------------------------------------
# Mirror List yenileme
# ------------------------------------------------------
    tput setaf 3
    echo "###############################################################################"
    echo "################## Mirror List yenileme"
    echo "###############################################################################"
    echo
    tput sgr0
# sudo reflector --latest 10  --fastest 10 --sort rate --protocol http,https --save /etc/pacman.d/mirrorlist

# rate- mirrors
# export TMPFILE="$(mktemp)"; \
    # sudo true; \
    # rate-mirrors --save=$TMPFILE arch --max-delay=43200 \
    # && sudo mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist-backup \
    # && sudo mv $TMPFILE /etc/pacman.d/mirrorlist

echo
tput setaf 3
echo "################################################################"
echo "###################  Mirrorlist yenilendi "
echo "################################################################"

# ------------------------------------------------------
# Setting environment variables
# ------------------------------------------------------
# echo "Setting environment variables"
# echo
# if [ -f /etc/environment ]; then
	#		echo "QT_QPA_PLATFORMTHEME=qt5ct" | sudo tee /etc/environment
	#		echo "QT_STYLE_OVERRIDE=kvantum" | sudo tee -a /etc/environment
	#echo "EDITOR=nano" | sudo tee -a /etc/environment
	#echo "BROWSER=thorium-browser" | sudo tee -a /etc/environment
# fi

# ------------------------------------------------------
# Firmware 
# ------------------------------------------------------
# yay -S --noconfirm --needed upd72020x-fw wd719x-firmware aic94xx-firmware lshw hw-probe hwinfo linux-firmware-qlogic

# ------------------------------------------------------
# Logitech MX Mouse
# ------------------------------------------------------
# echo "################### Logitech MX Mouse"
# yay -S --noconfirm --needed logiops


# ------------------------------------------------------
# Remove orphans
# ------------------------------------------------------
# 
echo "############# Remove orphans & "
# yay -Rns $(pacman -Qtdq) --noconfirm
echo "############# Remove orphans DONE..."
# ------------------------------------------------------
# Docker install
# ------------------------------------------------------
# 
    tput setaf 3
    echo "###############################################################################"
    echo "################## Docker ayarları "
    echo "###############################################################################"
    echo
    tput sgr0
#sudo groupadd docker
#newgrp docker
sudo usermod -aG docker $USER
sudo systemctl enable docker.service
sudo systemctl start docker.service
sudo systemctl enable containerd.service
sudo systemctl start containerd.service
sudo chmod 666 /var/run/docker.sock
#docker run hello-world