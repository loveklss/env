#!/bin/bash

config_file="/etc/exports"
if [ -n "$1" ];then
	cd $1 || echo "Error: nfs home folder is not existing"; exit 1 
	nfs_server_dir="$1"
else
	nfs_server_dir="/home/nfsroot"
fi
###################################
function check_install()
{
	install_info=`apt-cache policy $1 | grep Installed | cut -b 15-18`
}

function install(){
if [ -n "$1" ]; then
check_install $1
case $install_info in
	none)
		sudo apt-get install $1
		if [ $? -ne 0 ];then
			exit 1
		fi
		;;
	*)
		if [ $install_info ]; then
			echo "$1 be already installed!"
		else
			echo "aptitude unrecognizes the package($1)"
			exit 1;
		fi
		;;
esac
fi
}

function configure()
{
	test -d "$nfs_server_dir" || sudo mkdir -v -m a=rwx "$nfs_server_dir"
	test -h "~/nfsroot" || ln -s $nfs_server_dir ~/nfsroot
	#####
	if [ -e "$config_file" ];then
		tmpfile=`mktemp`
		cat $config_file | sed '/^[^#]/q' | sed '$d' > $tmpfile
		echo "$nfs_server_dir	*(rw,sync,no_root_squash)" >>  $tmpfile
		sudo cp -vf $tmpfile $config_file
		rm $tmpfile
		######
		echo "PROMPT: $config_file configured OK!"
		sudo exportfs -rv
	fi
}

########## start ##########
install nfs-kernel-server 
configure
exit 0
########## end ##########
