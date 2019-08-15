#!/bin/bash
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

check() {
    require_binaries /usr/bin/mount
    require_binaries /usr/bin/umount
    require_binaries /usr/sbin/mkfs.ext4
}

depends() {
    return 0
}

installkernel() {
    instmods overlay
}

install() {
    dracut_install /usr/bin/mount
    dracut_install /usr/bin/umount
    dracut_install /usr/sbin/mkfs.ext4
    inst_hook pre-pivot 10 "$moddir/mount-overlayroot.sh"
}
