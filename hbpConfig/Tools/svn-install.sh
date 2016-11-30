#!/bin/bash

SVNTOP="$HOME/.subversion"
config_file="$SVNTOP/config"
script_file="$SVNTOP/svndiff.sh"

function check_install()
{
	install_info=`apt-cache policy $1 | grep Installed | cut -b 15-18`
}

function doinstall(){
if [ -n "$1" ]; then
check_install $1
case $install_info in
	none)
		sudo apt-get install $1
		ret=$?
		if [ $ret -ne 0 ];then
			echo "Install failed!"
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
fi
}
make_script()
{
	cat << CONTENT 
#!/bin/bash
#!/bin/sh
#去掉前5个参数
shift 5
#使用vimdiff比较
vimdiff "\$@"
CONTENT
}

function configure()
{
	if [ -f "$config_file" ];then
		tmpfile=`mktemp`
		sed -e '/^diff-cmd = /d' -e '/diff-cmd = diff_program/a\diff-cmd = '$script_file''  $config_file > $tmpfile
		cp -vf $tmpfile $config_file
		rm $tmpfile
		echo "PROMPT: $config_file configured OK!"
	fi
}

########## start ##########
doinstall subversion
[ -d "$SVNTOP"	]	|| svn --version > /dev/null
[ -e "$script_file" ] || touch $script_file 
[ -x "$script_file" ] || chmod +x $script_file
make_script > $script_file
configure
exit 0
########## end ##########
