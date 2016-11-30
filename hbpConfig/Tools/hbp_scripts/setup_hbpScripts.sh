#!/bin/bash

basename=`basename $0`
cd `dirname $0`
##############################################
function help_info()
{
	cat <<HELP
"$0 clean --global" to remove scripts from /usr/local/bin/.hbpScripts/
"$0 clean --local" to remove scripts from ~/.hbpScripts/
"$0 install --global" to install scripts to /usr/local/bin/.hbpScripts/
"$0 install --local" to install scripts to ~/.hbpScripts/
"$0 backup --global" to save /etc/profile.d/bashrc-add.sh to $PWD/bashrc-add
"$0 backup --local" to save ~/.bashrc-add to $PWD/bashrc-add
HELP
}

function quire()
{
echo -n $1
condition="true"
while [ $condition = true ];do
	read -n 1 -s answer
	if [ $answer = "y" -o $answer = "Y" ];then
		echo $answer
		condition="false"
	elif [ $answer = "n" -o $answer = "N" ];then
		echo $answer
		exit 0	#exit the current shell process(sub process)
	fi
done
}

function add_content()
{
	cat<<ADD_CONTENTS
#Haobaopeng-Start
if [ -r ~/.bashrc-add ]; then
	. ~/.bashrc-add
fi
#Haobaopeng-End
ADD_CONTENTS
}

function export_env()
{
	if [ -f "$BEADDED_bashrc_file" ];then
		if [ -n "$(cat $BEADDED_bashrc_file | grep Haobaopeng-Start)" ];then
			echo "WARNING: $BEADDED_bashrc_file already has exported the environments, now to update!"
			tmpfile=`mktemp`
			cat $BEADDED_bashrc_file | sed '/Haobaopeng-Start/q' | sed '$d' > $tmpfile
			add_content >> $tmpfile
			cp -vf $tmpfile $BEADDED_bashrc_file
			rm $tmpfile
		else
			add_content >> $BEADDED_bashrc_file
		fi
	fi
}

function unexport_env()
{
	if [ -f "$BEADDED_bashrc_file" ];then
		if [ -n "$(cat $BEADDED_bashrc_file | grep Haobaopeng-Start)" ];then
			echo "INFO: $BEADDED_bashrc_file already has exported the environments, now to remove!"
			tmpfile=`mktemp`
			cat $BEADDED_bashrc_file | sed '/Haobaopeng-Start/q' | sed '$d' > $tmpfile
			cp -vf $tmpfile $BEADDED_bashrc_file
			rm $tmpfile
		fi
	fi
}

########### start ##########
#read -p "Input passwd:" -n 4 -s -a Passwd
#echo $Passwd
#echo -n "Input muliple values into an array:"
#read -a array
#echo "get ${#array[@]} values in array"
#echo "get ${array[0]} values in array"

if [ $basename != "setup_hbpScripts.sh" ];then
	echo "This script doesn't support to execute as the way of \". xx.sh\" or \"source xx.sh\""
	return 1
fi

case $2 in
	--global)
	SUDO="sudo"
	BEADDED_bashrc_file=
	install_dir="/usr/local/bin/.hbpScripts"
	src_file="./bashrc-add"
	obj_file="/etc/profile.d/bashrc-add.sh"
	;;
	--local)
	SUDO=
	BEADDED_bashrc_file="$HOME/.bashrc"
	install_dir="$HOME/.hbpScripts"
	src_file="./bashrc-add"
	obj_file="$HOME/.bashrc-add"
	;;
	*)
	help_info
	exit 1
	;;
esac

case $1  in
clean)
	if [ -d $install_dir ];then
		$SUDO rm -rvf $install_dir
		$SUDO rm -rvf $obj_file
		unexport_env
	else
		echo "WARNING: $install_dir is not exist!" 
	fi
	;;
install)
	if [ -d $install_dir ];then
		quire "WARNING: This will remove the scripts of installed ago, continue?[y/n]"
		$SUDO rm -rvf $install_dir
		$SUDO rm -rvf $obj_file
	fi
	test -d $install_dir || $SUDO mkdir -pv $install_dir || exit 1
	for i in hbpScripts/*.sh; do
		if [ -f $i ];then
			$SUDO cp -vf $i $install_dir/
		fi
	done
	$SUDO cp -vf hbpScripts/vims $install_dir/
	$SUDO cp -vf $src_file $obj_file
	export_env
	;;
backup)
	if [ -f $obj_file -a $obj_file -ot $src_file ];then
		quire "WARNING: $obj_file is older than $src_file, backup continue?[y/n]"
	fi
	cp -vf $obj_file $src_file
	;;
*)
	help_info
	exit 1
	;;
esac
exit 0
########### end ##########

