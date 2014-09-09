#!/bin/sh
#
#	Packs a rootfs folder into a compressed initramfs image using
#   cpio, gzip and mkbootimg
#
#	2014 - Marcus Sonntag <marcus dot sonntag at planetultra dot de>

# Get this script's name
me=${0##*/}

# Some helper functions
# -------------------------------------------------------------------------
usage()
{
	echo "Usage: $me <rootfs-folder> <target-uramdisk-image>" >&2
	exit 2
}

error_exit()
{
	echo $1 >&2
	exit 1
}

check_folder()	# Check for existing folder
{
	if [ ! -d "$1" ]; then
		echo "Could not find folder $1" >&2;
		return 1
	fi

	return 0
}

check_file()	# Check for existing file
{
	if [ ! -f "$1" ]; then
		echo "Could not find file $1" >&2;
		return 1
	fi

	return 0
}
# -------------------------------------------------------------------------


# Main pack function
# -------------------------------------------------------------------------
pack()
{
	# Pack
	olddir=$(pwd)
	cd "$folder"
	sudo find . | sudo cpio -H newc -o > $tmppack || return 1
	cd "$olddir"
	sudo chown $USER $tmppack || return 1

	# Zip
	cat $tmppack | gzip > $tmpzip

	# Wrap with uboot header
	mkimage -A arm -T ramdisk -C gzip -d $tmpzip $target || return 1

	return 0
}
# -------------------------------------------------------------------------

# Check invocation
folder=$1
target=$2

if	[ $# -ne 2 -o ! "$folder" -o ! "$target" ]
then
	usage
fi

# Resolve target to abolute path
target=$(readlink -m $target) || error_exit "Could not resolve absolute path to $2"

# Prepare temporary files
tmppack=$(mktemp) || exit 1
tmpzip=$(mktemp) || exit 1

trap "rm -f $tmppack $tmpzip" 0

# Execute
check_folder $folder || exit 1
check_folder $(dirname $target) || exit 1

echo "Packing $folder into init-ramdisk $target..." >&2

pack $folder $target || error_exit "Error during packing of $folder"
