#!/bin/sh
#
#	Extracts a compressed initramfs to a folder using cpio and gunzip
#   cpio, gzip and mkbootimg
#
#	2014 - Marcus Sonntag <marcus dot sonntag at planetultra dot de>

# Get this script's name
me=${0##*/}

# Some helper functions
# -------------------------------------------------------------------------
usage()
{
	echo "Usage: $me [-f] <uramdisk-image> <target-folder>
	-f
		Force extraction even if target folder is not empty" >&2
		
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

# Main unpack function
# -------------------------------------------------------------------------
unpack()
{
	# Unwrap uboot header (skip first 64 bytes)
	(
		dd bs=64 skip=1 count=0
		dd bs=4096
	) < $image > $tmppack || return 1

	# Unzip
	cat $tmppack | gunzip > $tmpzip

	# Unpack
	olddir=$(pwd)
	cd "$folder"
	sudo cpio -id --no-absolute-filenames < $tmpzip
	cd "$olddir"

	return 0
}
# -------------------------------------------------------------------------

# Parse arguments
OPTIND=1

# Default values
force=0

while getopts "f" opt; do
	case "$opt" in
	f)
		force=1
		;;
	esac
done

shift $((OPTIND-1))

# Check invocation
image=$1
folder=$2

if [ $# -ne 2 -o ! "$folder" -o ! "$image" ]; then
	usage
fi

# Resolve folder to abolute path
folder=$(readlink -m $folder) || error_exit "Could not resolve absolute path to $2"

# Prepare temporary files
tmppack=$(mktemp) || exit 1
tmpzip=$(mktemp) || exit 1

trap "rm -f $tmppack $tmpzip" 0

# Execute
check_file   $image || exit 1

# Avoid unpacking to root and possibly overwriting system files
if [ "$folder" = "/" ]; then
	error_exit "Cannot extract to \"/\""
fi

# Check if folder must be created or isn't empty
if [ ! -d "$folder" ]; then
	mkdir -p "$folder" || error_exit "Unable to create folder $folder"
elif [ "$(ls -A $folder)" ]; then
	if [ $force -eq 0 ]; then
		error_exit "Folder $folder is not empty. Specify the '-f' option to force extraction."
	fi
fi

echo "Trying to extract $image to $folder..." >&2

unpack $image $folder || error_exit "Error during extraction of $image"
