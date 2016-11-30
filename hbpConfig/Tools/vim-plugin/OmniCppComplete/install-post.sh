#/bin/bash

test -n "$install_dir" || install_dir="$HOME/.vim"
intermediary_file="$install_dir/after/ftplugin/hbp_c.vim"
dest_file="$install_dir/after/ftplugin/c.vim"
if test -e "$intermediary_file";then
	cat $intermediary_file >> $dest_file
	rm  -f $intermediary_file
	echo "INSTALL-POST: $dest_file process OK!"
fi


