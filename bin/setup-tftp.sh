#!/bin/sh

# This distribution contains contributions or derivatives under copyright
# as follows:
#
# Copyright (c) 2010, Texas Instruments Incorporated
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# - Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# - Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
# - Neither the name of Texas Instruments nor the names of its
#   contributors may be used to endorse or promote products derived
#   from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

cwd=`dirname $0`
. $cwd/common.sh

tftpcfg=/etc/xinetd.d/tftp
tftprootdefault=/tftpboot

if [ -f $cwd/../.targetfs ]; then
    rootpath=`cat $cwd/../.targetfs`
else
    echo "Where is your target filesystem extracted?"
    read -p "[ ${HOME}/targetNFS ]" rootpath

    if [ ! -n "$rootpath" ]; then
        rootpath="${HOME}/targetNFS"
    fi
    echo
fi

imageinstalldefault=$rootpath/boot

tftp() {
    echo "
service tftp
{
protocol = udp
port = 69
socket_type = dgram
wait = yes
user = nobody
server = /usr/sbin/in.tftpd
server_args = $tftproot
disable = no
}
" | sudo tee $tftpcfg > /dev/null
     check_status
     echo
     echo "$tftpcfg successfully created"
}

echo "--------------------------------------------------------------------------------"
echo "Which directory do you want to be your tftp root directory?(if this directory does not exist it will be created for you)"
read -p "[ $tftprootdefault ] " tftproot

if [ ! -n "$tftproot" ]; then
    tftproot=$tftprootdefault
fi
echo $tftproot > $cwd/../.tftproot
echo "--------------------------------------------------------------------------------"

echo
echo "--------------------------------------------------------------------------------"
echo "This step will set up the tftp server in the $tftproot directory."
echo
echo "Note! This command requires you to have administrator priviliges (sudo access) "
echo "on your host."
read -p "Press return to continue" REPLY

if [ -d $tftproot ]; then
    echo
    echo "$tftproot already exists, not creating.."
else
    sudo mkdir -p $tftproot
    check_status
    sudo chmod 777 $tftproot
    check_status
    sudo chown nobody $tftproot
    check_status
fi

echo "--------------------------------------------------------------------------------"
echo "Which directory will your Linux and u-boot images be installed to?(if this directory does not exist it will be created for you)"
read -p "[ $imageinstalldefault ] " imageinstallroot

if [ ! -n "$imageinstallroot" ]; then
    imageinstallroot=$imageinstalldefault
fi
echo "--------------------------------------------------------------------------------"

platform=`cat $cwd/../Rules.make | grep -e "^PLATFORM=" | cut -d= -f2`
uimage="uImage"
uboot="u-boot.img"
mlo="MLO"
uimagesrc=`ls -1 $cwd/../firmware/am3517/prebuilt-stable/$uimage`
if [ -f $imageinstallroot/$uimage ]; then
    echo
    echo "$imageinstallroot/$uimage already exists. The existing installed file can be renamed and saved under the new name."
    echo "(r) rename (o) overwrite (s) skip copy "
    read -p "[r] " exists
    case "$exists" in
      s) echo "Skipping copy of $uimage, existing version will be used"
         ;;
      o) sudo cp $uimagesrc $imageinstallroot
         check_status
         echo
         echo "Successfully overwritten $uimage in Image install directory $imageinstallroot"
         ;;
      *) dte="`date +%m%d%Y`_`date +%H`.`date +%M`"
         echo "New name for existing uImage: "
         read -p "[ $uimage.$dte ]" newname
         if [ ! -n "$newname" ]; then
             newname="$uimage.$dte"
         fi
         sudo mv "$imageinstallroot/$uimage" "$imageinstallroot/$newname"
         check_status
         sudo cp $uimagesrc $imageinstallroot
         check_status
         echo
         echo "Successfully copied $uimage to Image install directory $imageinstallroot as $newname"
         ;;
    esac
else
    sudo cp $uimagesrc $imageinstallroot
    check_status
    echo
    echo "Successfully copied $uimage to Image install directory $imageinstallroot"
fi

echo
if [ -f $tftproot/$uimage ]; then
    echo "Symbolic Link $tftproot/$uimage already exists and will be replaced."
    sudo rm "$tftproot/$uimage"
fi
sudo ln -s "$imageinstallroot/$uimage" "$tftproot/$uimage"
check_status
echo "Successfully created symbolic link to $imageinstallroot/$uimage in directory $tftproot"

ubootsrc=`ls -1 $cwd/../firmware/am3517/prebuilt-stable/$uboot`
if [ -f $imageinstallroot/$uboot ]; then
    echo
    echo "$imageinstallroot/$uboot already exists. The existing installed file can be renamed and saved under the new name."
    echo "(r) rename (o) overwrite (s) skip copy "
    read -p "[r] " exists
    case "$exists" in
      s) echo "Skipping copy of $uboot, existing version will be used"
         ;;
      o) sudo cp $ubootsrc $imageinstallroot
         check_status
         echo
         echo "Successfully overwritten $uboot in Image install directory $imageinstallroot"
         ;;
      *) dte="`date +%m%d%Y`_`date +%H`.`date +%M`"
         echo "New name for existing uImage: "
         read -p "[ $uboot.$dte ]" newname
         if [ ! -n "$newname" ]; then
             newname="$uboot.$dte"
         fi
         sudo mv "$imageinstallroot/$uboot" "$imageinstallroot/$newname"
         check_status
         sudo cp $ubootsrc $imageinstallroot
         check_status
         echo
         echo "Successfully copied $uboot to Image install directory $imageinstallroot as $newname"
         ;;
    esac
else
    sudo cp $ubootsrc $imageinstallroot
    check_status
    echo
    echo "Successfully copied $uboot to Image install directory $imageinstallroot"
fi

echo
if [ -f $tftproot/$uboot ]; then
    echo "Symbolic Link $tftproot/$uboot already exists and will be replaced."
    sudo rm "$tftproot/$uboot"
fi
sudo ln -s "$imageinstallroot/$uboot" "$tftproot/$uboot"
check_status
echo "Successfully created symbolic link to $imageinstallroot/$uboot in directory $tftproot"

mlosrc=`ls -1 $cwd/../firmware/am3517/prebuilt-stable/$mlo`
if [ -f $imageinstallroot/$mlo ]; then
    echo
    echo "$imageinstallroot/$mlo already exists. The existing installed file can be renamed and saved under the new name."
    echo "(r) rename (o) overwrite (s) skip copy "
    read -p "[r] " exists
    case "$exists" in
      s) echo "Skipping copy of $mlo, existing version will be used"
         ;;
      o) sudo cp $mlosrc $imageinstallroot
         check_status
         echo
         echo "Successfully overwritten $mlo in Image install directory $imageinstallroot"
         ;;
      *) dte="`date +%m%d%Y`_`date +%H`.`date +%M`"
         echo "New name for existing uImage: "
         read -p "[ $mlo.$dte ]" newname
         if [ ! -n "$newname" ]; then
             newname="$mlo.$dte"
         fi
         sudo mv "$imageinstallroot/$mlo" "$imageinstallroot/$newname"
         check_status
         sudo cp $mlosrc $imageinstallroot
         check_status
         echo
         echo "Successfully copied $mlo to Image install directory $imageinstallroot as $newname"
         ;;
    esac
else
    sudo cp $mlosrc $imageinstallroot
    check_status
    echo
    echo "Successfully copied $mlo to Image install directory $imageinstallroot"
fi

echo
if [ -f $tftproot/$mlo ]; then
    echo "Symbolic Link $tftproot/$mlo already exists and will be replaced."
    sudo rm "$tftproot/$mlo"
fi
sudo ln -s "$imageinstallroot/$mlo" "$tftproot/$mlo"
check_status
echo "Successfully created symbolic link to $imageinstallroot/$mlo in directory $tftproot"

if [ -f $tftpcfg ]; then
    echo
    echo "$tftpcfg already exists.."

    #Use = instead of == for POSIX and dash shell compliance
    if [ "`cat $tftpcfg | grep server_args | cut -d= -f2 | sed 's/^[ ]*//'`" \
          = "$tftproot" ]; then
        echo "$tftproot already exported for TFTP, skipping.."
    else
        echo "Copying old $tftpcfg to $tftpcfg.old"
        sudo cp $tftpcfg $tftpcfg.old
        check_status
        tftp
    fi
else
    tftp
fi

echo
echo "Restarting tftp server"
sudo service xinetd stop
check_status
sleep 1
sudo service xinetd start
check_status
echo "--------------------------------------------------------------------------------"
