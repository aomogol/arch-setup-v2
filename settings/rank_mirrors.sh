#!/usr/bin/bash
echo
echo "##########################################"
echo "     Updating Mirrors To Fastest Ones     "
echo "##########################################"
echo
# sudo reflector --verbose -phttps -f10 -l10 --sort rate --save /etc/pacman.d/mirrorlist && sudo pacman -Syy

# rate- mirrors
export TMPFILE="$(mktemp)"; \
    sudo true; \
    rate-mirrors --save=$TMPFILE arch --max-delay=43200 \
      && sudo mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist-backup \
      && sudo mv $TMPFILE /etc/pacman.d/mirrorlist



echo
echo "##################################"
echo " Done ! Updating should go faster "
echo "##################################"
