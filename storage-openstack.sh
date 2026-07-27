sudo fdisk -l — List disks
sudo pvcreate /dev/sdb — Initialize physical volume for LVM
sudo vgcreate cinder-volumes /dev/sdb — Create LVM volume group for Cinder
sudo vgs — Show LVM volume groups