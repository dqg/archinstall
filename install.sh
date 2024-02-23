#!/bin/bash

swapoff -a
umount -Rq /mnt

f() {
    i=1
    until [[ "$i" -eq "0" ]]; do
        echo -e "\e[1;32m$1\e[0m"
        read $2
        [[ -n "${!2}" ]] && eval "$1${!2}"
        i="$?"
    done
}

lsblk -d
f "cfdisk /dev/" "disk"
lsblk /dev/$disk
lsblk /dev/$disk
printf "\e[3J\e[H"
lsblk /dev/$disk
f "mkfs.fat -F 32 /dev/$disk" "boot"
f "mkswap /dev/$disk" "swap"
f "mkfs.ext4 -F /dev/$disk" "root"

set -e
mount /dev/$disk$root /mnt
mkdir /mnt/{a,b,c,boot}
mount /dev/$disk$boot /mnt/boot
swapon /dev/$disk$swap

x="s/Required DatabaseOptional/Never/
s/^#(ParallelDownloads).*/\1 = 3/
/^#Color$/s/#//
/^# Misc options$/a ILoveCandy"
sed -Ei "$x" /etc/pacman.conf

if [[ -f pkg1.tar.zst ]]; then
    mkdir -p /mnt/var/cache/pacman
    tar --zstd -xf pkg1.tar.zst -C /mnt/var/cache/pacman
    pacstrap -U /mnt /mnt/var/cache/pacman/pkg/*
else
    pacstrap /mnt $(cat list)
    pacstrap -U /mnt "https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst"
    tar --zstd -cf pkg1.tar.zst -C /mnt/var/cache/pacman pkg
fi

sed -Ei "$x" /mnt/etc/pacman.conf
genfstab -U /mnt >>/mnt/etc/fstab
ln -sf dash /mnt/bin/sh

install chroot.sh /mnt
arch-chroot /mnt /chroot.sh
rm /mnt/chroot.sh
