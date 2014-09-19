---
layout: post
title: Extracting and Repacking a Red Pitaya's initramdisk
categories: 
   - redpitaya 
   - red pitaya 
   - u-boot 
   - mkimage 
   - extract 
   - initramdisk 
   - arm
comments: true
---

It took me some time to figure out on how to quickly extract, modify and then repack a [Red Pitaya's][1] initramdisk without installing a full build environment. In this post I provide some easy to use Linux shell scripts to do just that.

First you will need some tools, i.e.

- cpio
- mkbootimg
    
The latter is part of the **u-boot-tools** package and may be installed through a package manager such as aptitude by issuing

    sudo apt-get install u-boot-tools
    
on the command line. The former should already be available on most systems and can be installed through the package `cpio` if it is not.

The Red Pitaya's initramdisk may be easily grabbed by copying the `uramdisk.image.gz` file from the official SD-card image or from a running Red Pitaya's `/opt` folder.

## How it works

For extraction, the first step is to remove the 64 byte u-boot header from the packed ramdisk which is simply done by using `dd`. Then it is uncompressed using `gunzip` and finally extracted by cpio. The sequence of commands is

```bash
( dd bs=64 skip=1 count=0; dd bs=4096 ) < $infile > $tempfile1
cat $tempfile1 | gunzip > $tempfile2
cd $outfolder; sudo cpio -id --no-absolute-filenames < $tempfile2
```

Note that the `sudo` invocation of `cpio` is necessary here as most files and folders inside the initramdisk are owned by root.
The arguments to `cpio` mean

- `-i`: extract
- `-d`: create leading directories
- `--no-absolute-filenames`: Don't create files on absolute paths as it may overwrite your system files otherwise!

For repackaging, the steps are essentially reversed. The u-boot header is added by a call to `mkbootimg` instead

```bash
cd $infolder; sudo find . | sudo cpio -H newc -o > $tempfile1
cat $tempfile1 | gzip > $tempfile2
mkimage -A arm -T ramdisk -C gzip -d $tempfile2 $outfile
```

The arguments to `cpio` mean

- `-o`: create archive
- `-H newc`: Choose the [newc format][4] for the archive

The following scripts make it easy to automate extraction and repackaging.

## Extraction

To extract the initramdisk to a folder you may use the following script I provide [here][2]. Simply save it to a file `unmkramdiskimg.sh` and make it executable. You may also download the script by issuing the commands

    wget https://mirtio.github.io/assets/unmkramdiskimg.sh
    chmod u+x unmkramdiskimg.sh

## Packaging

For packaging you may use the counterpart script `mkramdiskimg.sh` from [here][3]. The same applies here as for the extraction script. Type

    wget https://mirtio.github.io/assets/mkramdiskimg.sh
    chmod u+x mkramdiskimg.sh

to get an executable copy in your current folder.

## Usage

To extract, simply pass the filename of the packed initramdisk and a target folder to extract to the extraction script:

    ./unmkramdiskimg.sh uramdisk.image.gz initramdisk

_Note:_ If the target folder already exists and isn't empty, you have to specify the "-f" modifier to force extraction.

To repackage, pass the name of the folder containing the rootfs and a target filename to save the initramdisk to:

    ./mkramdiskimg.sh initramdisk uramdisk.image.gz

Then put the resulting image file back on your Red Pitaya's SD card. If you want to do this on a running Red Pitaya then you first have to mount the SD card as writable

    mount -o remount,rw /opt
    <copy uramdisk image>

and finally don't forget to either remount the SD card as read-only again (otherwise the SD card's file system may get corrupted on power-loss) or reboot the system:

    mount -o remount,ro /opt
    reboot
   
Now your modified image is ready to be used!

[1]: http://redpitaya.com  "Red Pitaya Website"
[2]: /assets/unmkramdiskimg.sh "Script file for extracting initramdisk images"
[3]: /assets/mkramdiskimg.sh "Script file for packaging initramdisk images"
[4]: http://www.gnu.org/software/cpio/manual/cpio.html "GNU manual for cpio"