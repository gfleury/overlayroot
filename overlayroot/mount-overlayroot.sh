#!/bin/sh
#  Copyright, 2012 Dustin Kirkland <kirkland@ubuntu.com>
#  Copyright, 2012 Scott Moser <smoser@ubuntu.com>
#  Copyright, 2012 Axel Heider
#             2016 George Fleury <gfleury@gmail.com>
#
#  Based on scripts from
#    Sebastian P.
#    Nicholas A. Schembri State College PA USA
#    Axel Heider
#    Dustin Kirkland
#    Scott Moser
#
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see
#    <http://www.gnu.org/licenses/>.

. /lib/dracut-lib.sh


clean_path() {
	# remove '//' in a path.
	local p="$1" tmp=""
	while [ "${p#*//}" != "$p" ]; do
		tmp=${p#*//}
		p="${p%%//*}/${tmp}"
	done
	_RET="$p"
}

overlayrootify_fstab() {
	# overlayrootify_fstab(input, root_ro, root_rw, dir_prefix, recurse, swap)
	# read input fstab file, write an overlayroot version to stdout
	# also returns (_RET) a list of directories that will need to be made
	local input="$1" root_ro="${2:-/run/sysroot}"
	local root_rw="${3:-/run/root-rw}" dir_prefix="${4:-/root}"
	local recurse=${5:-1} swap=${6:-0} fstype=${7:-overlay}
	local hash="#" oline="" ospec="" upper="" dirs="" copy_opts=""
	local spec file vfstype opts pass freq line ro_line
	local workdir="" use_orig="" relfile="" needs_workdir=true
	
	[ -f "$input" ] || return 1

	while read spec file vfstype opts pass freq; do
		line="$spec $file $vfstype $opts $pass $freq"
		case ",$opts," in
			*,ro,*) ro_opts="$opts";;
			*) ro_opts="ro,${opts}";;
		esac
		ro_line="$spec ${root_ro}$file $vfstype ${ro_opts},nofail $pass 0"

		use_orig=""
		if [ "${spec#${hash}}" != "$spec" ]; then
			use_orig="comment"
		elif [ -z "$freq" ]; then
			use_orig="malformed-line"
		else
			case "$vfstype" in
				vfat|fat) use_orig="fs-unsupported";;
				proc|sysfs|tmpfs|dev|devpts|udev) use_orig="fs-virtual";;
			esac
		fi

		rel_file=${file#/}
		if [ -n "$use_orig" ]; then
			if [ "$use_orig" != "comment" ]; then
				echo "$line # $MYTAG:$use_orig"
			else
				echo "$line"
			fi
		elif [ "$vfstype" = "swap" ]; then
			if [ "$swap" = "0" ]; then
				# comment out swap lines
				echo "#$MYTAG:swap=${swap}#${line}"
			elif [ "${spec#/}" != "${spec}" ] &&
			     [ "${spec#/dev/}" = "${spec}" ]; then
				# comment out swap files (spec starts with / and not in /dev)
				echo "#$MYTAG:swapfile#${line}"
			else
				echo "${line}"
			fi
		elif [ "$file" = "/" ]; then
			#ospec="${root_ro}${file}"
			ospec="${fstype}"
			copy_opts=""
			[ "${opts#*nobootwait*}" != "${opts}" ] &&
				copy_opts=",nobootwait"
			clean_path "${root_rw}/${dir_prefix}${file}"
			upper="$_RET"

			oline="${ospec} ${file} $fstype "
			clean_path "${root_ro}${file}"
			oline="${oline}lowerdir=$_RET"
			oline="${oline},upperdir=${upper}${copy_opts}"
			if [ "$fstype" = "overlayfs" -o "$fstype" = "overlay" ] &&
				${needs_workdir}; then
				workdir="${root_rw}/workdir"
				oline="${oline},workdir=$workdir"
				dirs="${dirs} $workdir"
			fi
 			oline="${oline} $pass $freq"

			if [ "$recurse" != "0" ]; then
				echo "$ro_line"
				echo "$oline"
				dirs="${dirs} ${upper}"
			else
				echo "$line"
				[ "$file" = "/" ] && dirs="${dirs} ${upper}"
			fi
		else
			echo "${line}"
		fi
	done < "$input"
	_RET=${dirs# }
}


mkdir -p /run/sysroot || echo Fail create ro dir 
mkdir -p /run/root-rw || echo Fail create rw dir

[ -f $NEWROOT/etc/overlayroot.conf ] && . $NEWROOT/etc/overlayroot.conf

# Silent fallback if no device specified on conf file
[ -n "$overlayrootdevice" ] || return 1
[ ! -b $overlayrootdevice ] && (echo Overlayroot device not found. Falling back to root device. && return 1)
[ $? != 0 ] || return

# Mount and/or format the ephemeral device 
mount $overlayrootdevice /run/root-rw || ((mkfs.xfs -f $overlayrootdevice && mount $overlayrootdevice /run/root-rw) || (echo Fail mount $overlayrootdevice. Falling back to root device. && return 1))
[ $? = 0 ] || return

# Create working directories to the RW filesystem
mkdir -p /run/root-rw/root
mkdir -p /run/root-rw/workdir

mount --make-private $NEWROOT 2>> /run/.overlayroot.log
mount --make-private / 2>> /run/.overlayroot.log
mount --make-private /run 2>> /run/.overlayroot.log
# Move the original root filesystem mount point to the new directory
mount --move $NEWROOT /run/sysroot 2>> /run/.overlayroot.log || (echo Failed to move $NEWROOT to /run/sysroot. && return 1)
[ $? = 0 ] || return

# Try to mount overlay, if fail fallback to original root filesystem.
mount -t overlay -o lowerdir=/run/sysroot,upperdir=/run/root-rw/root,workdir=/run/root-rw/workdir overlay $NEWROOT  || (mount --move /run/sysroot $NEWROOT && echo Failed to mount overlay root filesystem. Falling back to root device. && return 1)
[ $? = 0 ] || return

mkdir -p /sysroot/run/sysroot
mkdir -p /sysroot/run/root-rw

mount --move /run/sysroot /sysroot/run/sysroot
mount --move /run/root-rw /sysroot/run/root-rw

overlayrootify_fstab /sysroot/run/sysroot/etc/fstab > /sysroot/etc/fstab

