#!/bin/bash
set -e
#######################################################
# Author    : Ahmet Önder Moğol
#######################################################

#echo "################### ilave disk ler için mount point"
# sudo mkdir /mnt/
# sudo mkdir /mnt/

echo "################### Personal settings to install - "
installed_dir=$(dirname $(readlink -f $(basename `pwd`)))
	echo "Installing all shell files"
	echo
	cp $installed_dir/settings/shell-personal/.bashrc ~/.bashrc
	cp $installed_dir/settings/shell-personal/.bashrc-personal ~/.bashrc-personal
	cp $installed_dir/settings/shell-personal/.zshrc ~/.zshrc
	cp $installed_dir/settings/shell-personal/.zshrc-personal ~/.zshrc-personal
	#cp $installed_dir/settings/fish/alias.fish ~/.config/fish/alias.fish
	#sudo cp -f $installed_dir/settings/shell-personal/.bashrc /etc/skel/.bashrc
	#sudo cp -f $installed_dir/settings/shell-personal/.zshrc /etc/skel/.zshrc
	echo
### Switch to ZSH
#sudo chsh $USER -s /bin/zsh
sudo usermod -s /bin/zsh $USER

echo
echo "################### Personal settings to install - "
echo "Sublime text settings"
echo
[ -d $HOME"/.config/sublime-text/Packages/User" ] || mkdir -p $HOME"/.config/sublime-text/Packages/User"
cp  $installed_dir/settings/sublimetext/Preferences.sublime-settings $HOME/.config/sublime-text/Packages/User/Preferences.sublime-settings
echo



