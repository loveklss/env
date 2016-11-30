"//==== 自动补全成对括号 for FileType C =====//
"autocmd FileType c  imap ( ()<Esc>i
"let b:c_file_type=1
"if  b:c_file_type == 1 
"if exists("b:c_file_type")
"imap /*	/**/<Left><Left>
imap {<CR>	{<CR>}<ESC>O
"inoremap '	''<Esc>i
"inoremap "	""<Left>

"imap <	<><Left>
"imap (	()<Esc>i
"imap {	{}<Esc>i
"imap [	[]<Esc>i
"endif
