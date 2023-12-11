#!/bin/bash

apt -y install ffmpeg pulseaudio alsa-utils pip python3.11-venv sudo zip curl hexyl

echo -e "Nmhh12\nNmhh12" | passwd root

apt -y install mdadm lvm2
modprobe md 
modprobe linear
modprobe raid0 
modprobe raid1
modprobe raid5
modprobe raid6 
modprobe raid10
parted -s -a optimal -s /dev/sda mklabel msdos
parted -s -a optimal /dev/sda unit s mkpart p ext4 65535 100%
parted -s /dev/sda set 1 lvm on
parted -s -a optimal -s /dev/sdb mklabel msdos
parted -s -a optimal /dev/sdb unit s mkpart p ext4 65535 100%
parted -s /dev/sdb set 1 lvm on
mdadm --create /dev/md0 -f -a yes --run --level=mirror --raid-devices=2 /dev/sda1 /dev/sdb1
mdadm --detail --scan | tee -a /etc/mdadm/mdadm.conf
update-initramfs -u
pvcreate /dev/md0
vgcreate vgmd0 /dev/md0
lvcreate -n media -L 230G vgmd0
mkfs.ext4 -F /dev/vgmd0/media
mount /dev/vgmd0/media /media/
echo '/dev/mapper/vgmd0-media /media ext4 defaults,nofail,discard 0 0' | sudo tee -a /etc/fstab

curl https://raw.githubusercontent.com/kvaczko/rap/main/rap.zip -o /rap.zip
cd /
unzip rap.zip

ln -s /media/ /data/IRIS
rm -fR /data/IRIS/lost+found/

chmod +x /data/script/*

cp /data/config/sshd_config /etc/ssh/
service sshd reload

cp /data/config/website.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable website.service

sed -i '/dtparam=audio=on/d' /boot/config.txt 
sed '/dtoverlay/s/$/,noaudio/' -i /boot/config.txt
echo "dtoverlay=hifiberry-dacplusadc" | tee -a /boot/config.txt
cp /boot/config.txt /boot/firmware/config.txt

crontab </data/config/crontab.txt

reboot
