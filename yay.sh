#!/bin/sh

git clone --depth 1 https://aur.archlinux.org/yay-bin.git /yay || exit 1
chown -R nobody:nobody /yay
(cd /yay && runuser -u nobody makepkg)

pacman -U --noconfirm /yay/*.zst
mv -v /yay/*.zst /var/cache/pacman/pkg
rm -r /yay