#!/bin/bash

test -n "$post_dir" || post_dir="."
echo "# Most recently edited files in Vim (version 3.0)" > $HOME/.vim_mru_files
echo "$HOME/test" >> $HOME/.vim_mru_files

echo "INSTALL-POST: Make $HOME/.vim_mru_files Ok!"
