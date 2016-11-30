#!/bin/bash
cd `dirname $0`
plugname=lookupfile
if [ $1 = '1' ]; then
echo "Install $plugname plugin OK!"
find -maxdepth 1 -path "./*" -type d  -exec cp -a {} ~/.vim/ \;
elif [ -f ~/.vim/syntax/help_cn.vim ]; then
echo "Remove $plugname plugin OK!"
rm -rf ~/.vim/syntax/help_cn.vim
rm -f ~/.vim/doc/*.cnx
rm -f ~/.vim/plugin/vimcdoc.vim
else
echo "$plugname plugin is removed alredy!"
fi


