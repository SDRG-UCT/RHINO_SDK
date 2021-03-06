#platform
PLATFORM=rhino
#PLATFORM=am3517_evm

#Architecture
ARCH=armv7a

#u-boot machine
UBOOT_MACHINE=$(PLATFORM)_config

#Points to the root of the RHINO SDK
export RHINO_SDK_PATH=__RHINO_SDK_PATH__

#root of the target file system for installing applications
DESTDIR=__DESTDIR__

#Points to the root of the Linux libraries and headers matching the
#demo file system.
export LINUX_DEVKIT_PATH=$(RHINO_SDK_PATH)/linux-devkit

#Cross compiler prefix
export CROSS_COMPILE=$(LINUX_DEVKIT_PATH)/sysroots/i686-arago-linux/usr/bin/arm-linux-gnueabihf-

#Default CC value to be used when cross compiling.  This is so that the
#GNU Make default of "cc" is not used to point to the host compiler
export CC=$(CROSS_COMPILE)gcc

#Location of environment-setup file
export ENV_SETUP=$(LINUX_DEVKIT_PATH)/environment-setup

#Location of build Directory
export BUILD_DIR=$(RHINO_SDK_PATH)/tmp/build

#The directory that points to the u-boot source tree
UBOOT_SOURCE_PATH=$(RHINO_SDK_PATH)/firmware/am3517/source/u-boot

#The directory that points to the SDK kernel source tree
LINUXKERNEL_INSTALL_DIR=$(RHINO_SDK_PATH)/firmware/am3517/source/borph


CFLAGS= -march=armv7-a    -marm -mthumb-interwork -mfloat-abi=hard -mfpu=neon -mtune=cortex-a8
