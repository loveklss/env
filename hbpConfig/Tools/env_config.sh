#!/bin/bash

case "$1" in
setup)
	operate="install"
	;;
remove)
	operate="purge"
	;;
*)
	echo "$0 setup to install some tools needed by development."
	echo "$0 remove to uninstall those tools."
	;;
esac

if [ -n "$operate" ]; then
sudo apt-get $operate \
tree vim-gtk \
sysv-rc-conf \
xinetd openssh-server \
cscope exuberant-ctags \
subversion \
libncurses5-dev libreadline6-dev \
make u-boot-tools \
bison flex m4 texinfo \
gawk \
sparse \

fi
#uboot-mkimage \
#gnome-terminal	\
#thunar \
