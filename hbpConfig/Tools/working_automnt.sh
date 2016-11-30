#!/bin/bash

install_dir="$HOME/.config/autostart"
[ -e "$install_dir" ] || mkdir -p $install_dir


function working_desktop()
{
	cat <<CONTENT
[Desktop Entry]
Name=No Name
Type=Application
OnlyShowIn=GNOME;Unity;
Exec=/home/$USER/.config/autostart/workingmnt.sh
CONTENT
}

workingmnt_sh()
{
source_dir="/media/workdisk/workspace"
	cat <<CONTENT
#!/bin/bash
sudo chown $USER:$USER /media/workdisk
[ -e "~/working" ] || mkdir -p ~/working
[ -e "$source_dir" ] ||  mkdir -p $source_dir
sudo mount --bind $source_dir ~/working
CONTENT
}

working_desktop > $install_dir/working.desktop
workingmnt_sh	> $install_dir/workingmnt.sh
chmod +x $install_dir/workingmnt.sh

case "$1" in
	now)
		source $install_dir/workingmnt.sh
		;;
	*)
		echo "\"$0 now\" to mount immediately."
		;;
esac
