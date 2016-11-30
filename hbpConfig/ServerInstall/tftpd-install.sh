#!/bin/bash

tftpd_dir="/home/tftpboot"
tftpd_hpa_conf="/etc/xinetd.d/tftpd-hpa"
tftpd_conf="/etc/xinetd.d/tftpd"
##################################################
function config_tftpd(){
cat <<CONFIGURE
service tftp
{
	disable         = no
	socket_type     = dgram
	protocol        = udp   
	wait            = yes
	user            = root
	server          = /usr/sbin/in.tftpd
	#server_args     = -s /home/haobp/tftpboot
	server_args     = -s $tftpd_dir
	per_source      = 11
	cps             = 100 2
	flags           = IPv4
}
CONFIGURE
}

function config_tftpd-hpa(){
cat <<CONFIGURE
service tftp
{
	disable         = no
	socket_type     = dgram
	protocol        = udp   
	wait            = yes
	#user            = haobp
	user            = root 
	server          = /usr/sbin/in.tftpd
	server_args     = -s -c -t 15 -u $USER $tftpd_dir
	per_source      = 11
	cps             = 100 2
	flags           = IPv4
}
CONFIGURE
}

function help(){
cat <<HELP
"$1 -a|--hpa|hpa" to install tftpd of hpa version.
"$1 -g|--general|general" to install tftpd of old version.
"$1 config" to configure the tftpd, must be installed already.
HELP
}
function prompt_help()
{
cat <<EOF
"$0 -h|--help|help" to get help information.	
EOF
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
	test -d "$tftpd_dir" || sudo mkdir -v -m a=rwx "$tftpd_dir"
	test -h "~/tftpboot" || ln -s $tftpd_dir ~/tftpboot
	#####
	test ! -e "$config_file" || sudo rm -vf $config_file
	sudo touch $config_file
	sudo chmod o+w $config_file 
	config_$tftpd_version > $config_file
	sudo chmod o-w $config_file
	sudo /etc/init.d/xinetd restart
}


########## start ##########
if [ $# -lt 1 ]; then
	echo "Error: lack the needed parameter!"
	prompt_help
	exit 1;
elif [ $# -gt 1 ]; then
	echo "Warning: the redundant paramters will be ignored!"
fi

case $1 in
	hpa|--hpa|-a)
		install tftp-hpa
		install tftpd-hpa
		config_file=$tftpd_hpa_conf
		tftpd_version="tftpd-hpa"
		;;
	general|--general|-g)
		install tftp
		install tftpd
		config_file=$tftpd_conf
		tftpd_version="tftpd"
		;;
	config)
		if [ -e "$tftpd_hpa_conf" ];then
			tftpd_version="tftpd-hpa"
			config_file=$tftpd_hpa_conf
		elif [ -e "$tftpd_conf" ];then
			tftpd_version="tftpd"
			config_file=$tftpd_conf
		else
			echo "WARNING: TFTP-SERVER may be not installed yet, or the config file was removed unexpectedly."
			echo "Now to check installation information..."
			check_install tftpd-hpa
			if [ -n $install_info -a $install_info != "none" ];then
				tftpd_version="tftpd-hpa"
				config_file=$tftpd_hpa_conf
			else
				check_install tftpd
				if [ -n $install_info -a $install_info != "none" ];then
				tftpd_version="tftpd"
				config_file=$tftpd_conf
				fi
			fi
			if [ -n "$tftpd_version" ];then
				echo "$tftpd_version was installed,just the config file was removed."
			else
				echo "TFTP-SERVER isn't installed yet now."
			fi
		fi
		;;
	help|--help|-h)
		help $0
		exit 0
		;;
	*)
		echo "Error: unrecognized parameter!"
		prompt_help
		exit 1
		;;
esac
configure
exit 0

:<<COMMENT
sudo /etc/init.d/xinetd restart
COMMENT

########## end ##########
