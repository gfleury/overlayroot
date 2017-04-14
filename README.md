#  Dracut module to permit root fs overlay 

Mount virtual root fs with rw-fs pointing to one filesystem on top or ro-fs from another filesystem.

Usages examples:
- EC2 ephemeral storage as RW on top of EBS volumus as a RO. (probably same performance from instances storage). Get instance storage IOPS performance on EBS root volumes.
- If the root EBS volume fails, should improve the graceful degradation.
- Protect root filesystem from modifications.
- The root device volume for an I3 instance must be an Amazon EBS volume. So this allow you to use all nvme drivers performance on the root file system. Allowing you to use ephemeral volumes as I3 root filesystem.

## Latest version:

- https://s3.amazonaws.com/gfleury/dracut-modules-overlayroot-0.1-beta.amzn1.noarch.rpm

## Using

- Spin up an Amazon Linux instance with root EBS volume and with ephemeral storage
- Update to latest version 
- Install the overlayroot package
- Recreate initramfs
- Reboot

```
yum install kernel-4.9.20-10.30.amzn1.x86_64 -y 
rpm -ivh https://s3.amazonaws.com/gfleury/dracut-modules-overlayroot-0.1-beta.amzn1.noarch.rpm
echo "overlayrootdevice=/dev/xvdb" >> /etc/overlayroot.conf
dracut -f /boot/initramfs-4.9.20-10.30.amzn1.x86_64.img 4.9.20-10.30.amzn1.x86_64
reboot
```
 ** this example the ephemeral device is /dev/xvdb

[1] https://www.kernel.org/doc/Documentation/filesystems/overlayfs.txt 
