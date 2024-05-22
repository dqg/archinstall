#!/bin/bash

swapoff -a
umount -Rq /mnt

f() {
    false
    until [[ "$?" -eq "0" ]]; do
        echo -e "\e[1;32m$1\e[0m"
        read -r "$2"
        [[ -n "${!2}" ]] && eval "$1${!2}"
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

install chroot.sh yay.sh /mnt
x="s/^#(ParallelDownloads).*/\1 = 3/
/^#Color$/s/#//
/^# Misc options$/a ILoveCandy"
sed -Ei "$x" /etc/pacman.conf

if [[ -f pkg1.tar.zst ]]; then
    mkdir -p /mnt/var/cache/pacman
    tar --zstd -xf pkg1.tar.zst -C /mnt/var/cache/pacman
    pacstrap -U /mnt /mnt/var/cache/pacman/pkg/*.zst
else
    pacstrap /mnt $(cat pkg.txt)
    arch-chroot /mnt /yay.sh
    tar --zstd -cf pkg1.tar.zst -C /mnt/var/cache/pacman pkg
fi

sed -Ei "$x" /mnt/etc/pacman.conf
genfstab -U /mnt >>/mnt/etc/fstab
ln -sfv dash /mnt/bin/sh
arch-chroot /mnt /chroot.sh
rm /mnt/*.sh