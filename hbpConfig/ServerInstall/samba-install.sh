#!/bin/bash

config_file="/etc/samba/smb.conf"
UbuntuVer=`cat /etc/issue | awk '/./ {print $2}' | sed 's/\.//'`
##################################################
function add_content(){
	cat<<ADD_CONTENTS
#Haobaopeng-Start
[homes]
comment = User Home Directories
browseable = no
writeable = yes
directory mask = 0755
create mask = 0644
#Haobaopeng-End
ADD_CONTENTS
}

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
		ret=$?
		if [ $ret -ne 0 ];then
			exit 1
		fi
		;;
	*)
		if [ $install_info ]; then
			echo "$1 is installed already!"
			return 0
		else
			echo "aptitude unrecognizes the package($1)"
			exit 1;
		fi
		;;
esac
if [ $1 = "samba" ];then
	echo "PROMPT: Now to add user $USER into samba server."
	sudo smbpasswd -a $USER
fi
fi
}

function configure()
{
	if [ -f "$config_file" ];then
		if [ -n "$(cat $config_file | grep '\(Haobaopeng-Start\)\|\(^\[homes\]\)')" ];then
			echo "WARNING: $config_file had been configured, now to re-configure!"
			tmpfile=`mktemp`
			cat $config_file | sed '/\(Haobaopeng-Start\)\|\(^\[homes\]\)/q' | sed '$d' > $tmpfile
			add_content >> $tmpfile
			sudo cp -vf $tmpfile $config_file
			rm $tmpfile
		else
			sudo chmod o+w $config_file
			add_content >> $config_file
			sudo chmod o-w $config_file
		fi
		echo "PROMPT: $config_file configured OK!"
		sudo service smbd restart
	fi
}

########## start ##########
if [ $UbuntuVer -lt 1204 ];then
	smbfs_ver="smbfs"
elif [ $UbuntuVer -eq 1204 ];then
	smbfs_ver="smbnetfs"
elif [ $UbuntuVer -ge 1210 ];then
	smbfs_ver="cifs-utils"
fi

install $smbfs_ver
install samba
configure
exit 0
########## end ##########
