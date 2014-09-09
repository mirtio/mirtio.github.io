---
layout: post
title: Extracting and Repacking a Red Pitaya's initramdisk
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

## Extraction

To extract the initramdisk to a folder you may use the following script I provide [here][2]. Simply save it to a file `unmkramdiskimg.sh` and make it executable. You may also download the script by issuing the commands

    wget https://mirtio.github.io/assets/unmkramdiskimg.sh
    chmod u+x unmkramdiskimg.sh

## Packaging

For packaging you may use the counter part script from [here][3]. The same applies here as for the extraction script. Type

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