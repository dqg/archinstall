#!/bin/sh

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
grub-mkconfig -o /boot/grub/grub.cfg
systemctl enable NetworkManager

echo "LANG=en_US.UTF-8" >/etc/locale.conf
sed -i "/^#en_US/s/#//" /etc/locale.gen
locale-gen

ln -sf /usr/share/zoneinfo/Asia/Colombo /etc/localtime
hwclock -w
echo "arch" >/etc/hostname
echo "root:password" | chpasswd