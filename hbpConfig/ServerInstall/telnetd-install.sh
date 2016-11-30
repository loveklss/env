#!/bin/bash

config_file="/etc/xinetd.d/telnet"
##################################################
function config_telnetd(){
cat <<CONFIGURE
service telnet 
{
	disable         = no
	socket_type     = stream 
	wait            = no 
	user            = root
	server          = /usr/sbin/in.telnetd
	log_on_failure	+= USERID
	flags			= REUSE
	#################################
#	bind			= 10.0.14.35
#	no_access		= 10.0.13.24
}
CONFIGURE
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
	test ! -e "$config_file" || sudo rm -vf $config_file
	sudo touch $config_file
	sudo chmod o+w $config_file 
	config_telnetd > $config_file
	sudo chmod o-w $config_file
	sudo /etc/init.d/xinetd restart
}

########## start ##########
install telnetd
configure
exit 0
########## end ##########
