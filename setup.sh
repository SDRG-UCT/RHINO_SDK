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

entry_header() {
cat << EOF
-------------------------------------------------------------------------------
RHINOSDK setup script
Adapted from TISDK setup script -> www.ti.com
This script will set up your development host for SDK development.
Parts of this script require administrator priviliges (sudo access).
-------------------------------------------------------------------------------
EOF
}

exit_footer() {
cat << EOF
-------------------------------------------------------------------------------
RHINO_SDK setup completed successfully!
Congratulations!
http://www.sdrg.ee.uct.ac.za/
-------------------------------------------------------------------------------
EOF
}

rootdirdefault=$PWD
cwd=`dirname $0`
# Minimum major Linux version for running add-to-group script
min_ver_upper=12

# Publish the TISDK setup header
entry_header

# Make sure that the common.sh file exists
if [ -f $cwd/bin/common.sh ]; then
    . $cwd/bin/common.sh
    get_host_type host
    get_major_host_version host_upper
else
    echo "common.sh does not exist in the bin directory"
    exit 1
fi

if [ -f $cwd/bin/setup-host-check.sh ]; then
    $cwd/bin/setup-host-check.sh
    check_status
else
    echo "setup-host-check.sh does not exist in the bin directory"
    exit 1
fi

echo
echo "--------------------------------------------------------------------------------"
echo "Which directory do you want to use as your RHINO_SDK_PATH?(if this directory does not exist it will be created)"
read -p "[ $rootdirdefault ] " rdir

if [ ! -n "$rdir" ]; then
    rdir=$rootdirdefault
fi

sed -i "s=export RHINO_SDK_PATH\=.*$=export RHINO_SDK_PATH\=$rdir=g" $cwd/Rules.make

echo "--------------------------------------------------------------------------------"


# Only execute if the Linux version is above 12.xx
if [ "$host_upper" -gt "$min_ver_upper" -o "$host_upper" -eq "$min_ver_upper" ]; then
    if [ -f $cwd/bin/add-to-group.sh ]; then
        $cwd/bin/add-to-group.sh
        check_status
    else
        echo "add-to-group.sh does not exist in the bin directory"
        exit 1
    fi
fi

if [ -f $cwd/bin/setup-package-install.sh ]; then
     $cwd/bin/setup-package-install.sh
     check_status
else
    echo "setup-package-install.sh does not exist in the bin directory"
    exit 1
fi

if [ -f $cwd/bin/setup-targetfs-nfs.sh ]; then
    $cwd/bin/setup-targetfs-nfs.sh
    check_status
else
    echo "setup-targetfs-nfs.sh does not exist in the bin directory"
    exit 1
fi

if [ -f $cwd/bin/setup-tftp.sh ]; then
    $cwd/bin/setup-tftp.sh
    check_status
else
    echo "setup-tftp.sh does not exist in the bin directory"
    exit 1
fi

if [ -f $cwd/bin/setup-minicom.sh ]; then
    $cwd/bin/setup-minicom.sh
    check_status
else
    echo "setup-minicom.sh does not exist in the bin directory"
    exit 1
fi

if [ -f $cwd/bin/setup-uboot-env.sh ]; then
    $cwd/bin/setup-uboot-env.sh
    check_status
else
    echo "setup-uboot-env.sh does not exist in the bin directory"
    exit 1
fi

# Publish the TISDK exit header
exit_footer
