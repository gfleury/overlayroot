#  Dracut module to permit root fs overlay 

Mount virtual root fs with rw-fs pointing to one filesystem on top or ro-fs from another filesystem.

Usages examples:
- EC2 ephemeral storage as RW on top of EBS volumus as a RO. (probably same performance from instances storage). Get instance storage IOPS on EBS root volumes.
- If the root EBS volume fails, should improve the graceful degradation.
- Protect root filesystem from modifications.

## Latest version:

- https://s3.amazonaws.com/gfleury/dracut-modules-overlayroot-0.1-beta.amzn1.noarch.rpm



[1] https://www.kernel.org/doc/Documentation/filesystems/overlayfs.txt 
