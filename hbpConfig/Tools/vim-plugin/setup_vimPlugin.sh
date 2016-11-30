#!/bin/bash

basename=`basename $0`
cd `dirname $0`
###################################
#plugin_files=`find -path "*noINSTALL" -type d -prune -o -name "*.sh" -type f -prune -o -name "*" -type f -print`
plugins=`find  -maxdepth 1 -path "*noINSTALL" -type d -prune -o -path "./*" -type d -print`
post_sh=`find  -path "*noINSTALL" -type d -prune -o -name "install-post.sh" -type f -print`
##################################################
function help_info()
{
	cat <<HELP
"$0 clean --global" to remove plugins from /etc/vim/after/ 
"$0 clean --local" to remove plugins from $HOME/.vim/
"$0 install --global" to install plugins to /etc/vim/after/ 
"$0 install --local" to install plugins to $HOME/.vim/
"$0 backup --global" to save /etc/vim/vimrc.local to $PWD/vimrc
"$0 backup --local" to save $HOME/.vimrc to $PWD/vimrc
HELP
}

function quire()
{
echo -n $1
while [ -n "true" ];do
	read -n 1 -s answer
	if [ $answer = "y" -o $answer = "Y" ];then
		echo $answer
		break
	elif [ $answer = "n" -o $answer = "N" ];then
		echo $answer
		exit 0	#exit the entire script.
	fi
done
}

########### start ##########
if [ $basename != "setup_vimPlugin.sh" ];then
	echo "This script doesn't support to execute as the way of \". xx.sh\" or \"source xx.sh\""
	return 1
fi

case $2 in
	--global)
		SUDO="sudo"
		install_dir="/etc/vim/after"
		vimconf_src_file="./vimrc"
		vimconf_obj_file="/etc/vim/vimrc.local"
		;;
	--local)
		SUDO=
		install_dir="$HOME/.vim"
		vimconf_src_file="./vimrc"
		vimconf_obj_file="$HOME/.vimrc"
		;;
	*)
		help_info
		exit 1
		;;
esac

case $1 in
clean)
	if [ -d $install_dir ];then
		$SUDO rm -rf $install_dir
		echo "removed directory \`$install_dir\`"
		$SUDO rm -vf $vimconf_obj_file
	else
		echo "WARNING: $install_dir is not exist!" 
	fi
	;;
install)
	if [ -d $install_dir ];then
		quire "WARNING: This will remove the plugins of installed ago, continue?[y/n]"
		$SUDO rm -rf $install_dir
		echo "removed directory \`$install_dir\`"
	fi
	$SUDO cp -avf $vimconf_src_file $vimconf_obj_file
	test -d $install_dir || $SUDO mkdir -pv $install_dir || exit 1
	for i in $plugins;do
		$SUDO cp -af $i/* $install_dir
		plugin_name=`echo $i | sed 's#\./##'`
		echo "plugin \`$plugin_name\` installed OK!"
	done
	$SUDO rm -f $install_dir/*.sh
	##do all install-post scripts ##
	for i in $post_sh; do
		post_dir=`dirname $i`
		source $i
	done
	;;
backup)
	if [ -f $vimconf_obj_file -a $vimconf_obj_file -ot $vimconf_src_file ];then
		quire "WARNING: $vimconf_obj_file is older than $vimconf_src_file, backup continue?[y/n]"
	fi
	cp -avf $vimconf_obj_file $vimconf_src_file
	;;
*)
	help_info
	exit 1
	;;
esac
exit 0
########### end ##########

