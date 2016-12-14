set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'mileszs/ack.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
" Plugin 'tpope/vim-fugitive'
" Plugin 'file:///home/qhu/.vim/bundle/'
" plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" Git plugin not hosted on GitHub
" Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
" Plugin 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
" Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Install L9 and avoid a Naming conflict if you've already installed a
" different version somewhere else.
" Plugin 'ascenator/L9', {'name': 'newL9'}

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
" vundle end ....................
"//说明：vimrc变量设置时的‘＝’等号两边不能有空格。
let mapleader=','
let g:mapleader=','
"//=========================//
"nmap	--The key is valid in normal mode only.
"imap	--The key is valid in insert mode only.
"vmap	--The key is valid in visual mode only.
"cmap	--The key is valid in command line mode only.
"map	--The key is valid in normal and visual mode.
"map!	--The key is valid in insert and command line mode.
"
"//===== vim中的编码设置 =====//
"//vim中对多字节编码的支持
"//euc-cn是GB2312的别名，不支持繁体汉字。
"//cp936是GBK的别名，是GB2312的超集，可以支持繁体汉字。
"//latin-1 是ISO-8859-1的别名,ISO_8859-1是单字节编码。

set encoding=utf-8		"//或者set enc=cp936 //encoding是Vim的内部使用编码，会影响Vim内部的 Buffer、消息文字等。
set fileencodings=utf-8,gb18030,gb2312,gbk,ucs-bom,latin-1
"//Vim在打开文件时会根据fileencodings选项来识别文件编码，可以同时设置多个编码，Vim会根据设置的顺序来猜测所打开文件的编码。 
set fileencoding=utf-8
"//vim在保存新建文件时会根据fileencoding的设置编码来保存。如果是打开已有文件，Vim会根据打开文件时所识别的编码来保存，除非在保存时重新设置fileencoding。
"set termencoding=cp936	"或 set tenc=cp936 //在终端环境下使用Vim时，通过tenc项来告诉Vim,终端所使用的编码。hbp:实际是不用设置tenc就可以了.

"//===== general setting =====//
set nocompatible	"not compatible Vi
set vb t_vb=		"Command error beep off
set mouse=a			"//Enable mouse usage (all modes)
set autoread		"//自动重加载文件，默认关闭。
set autowrite		"//Automatically save before commands like :next and :make
"set autowriteall	"//可使切换文件时，修改的文件被自动保存
set keymodel=startsel,stopsel	"//Shift+Directionkey used to select texts.
"set selection=inclusive			"//包括光标当前处的字符（即光标右边的字符）(Include the cursor character.)
set selection=exclusive		"//不包括光标当前处的字符(Exclude the cursor character.)
"set autochdir					"//不能设置，否则tag会找不到
"//===== about search =====//
set hlsearch		"high light the result of search.
set incsearch		"增量式搜索
"set ignorecase		"Do case insensitive matching(忽略大小写)
"set smartcase		"Do smart case matching
"//===== display setting =====//
set t_Co=256		"set terminal color 256
set ts=4
set expandtab
"colorscheme freya	"or color freya
"colorscheme navajo_hbp
colorscheme freya_hbp
set number			"display line number
set ruler
set cursorline		"显示光标行
set linebreak		"or set lbr
set whichwrap=h,l,[,],<,>
set tabstop=4
set softtabstop=4
set shiftwidth=4
set autoindent		
set nosmartindent
"//==== remap windows shortcut key ====//
"<C-F1> <C-F2> <C-F3> <C-F4> 这4个键被系统定义，不能再次重定义。
"map <C-\>n :%s/<C-R>=expand("<cword>")<cr>//gn<cr>		"统计光标处单词的总数
map <C-\>n :%s/<C-R><C-W>//gn<cr>						"统计光标处单词的总数
map  <F3> :vimgrep <C-R><C-W> %<cr> :cw<cr>
map! <F3> :vimgrep <C-R><C-W> %<cr> :cw<cr>
map <F7> <Esc>:cp<cr>
map! <F7> <Esc>:cp<cr>
map <F8> <Esc>:cn<cr>
map! <F8> <Esc>:cn<cr>
map <C-F8> <Esc>:ccl<cr>
map! <C-F8> <Esc>:ccl<cr>

"imap <C-a>	<Esc>ggVG		"//映射Ctrl+a全选功能（映射不成功）
"lmap <C-a>	<Esc>ggVG		"//映射Ctrl+a全选功能（映射不成功）
"//Tab缩进映射
vmap <Tab>	>
vmap <S-Tab> <
"//==== Ctrl-s 保存 =====//
nmap <C-s>	:w<cr>
vmap <C-s>	:w<cr>
cmap <C-s>	:w<cr>
imap <C-s>	<Esc>:w<cr>a
nmap <F9>	:w<cr>
vmap <F9>	:w<cr>
cmap <F9>	:w<cr>
imap <F9>	<Esc>:w<cr>a
"//===== F5 退出窗口 =====//
map  <F5>	<Esc>:q<cr>
map! <F5>	<Esc>:q<cr>
nmap  <S-q>	<Esc>:qa<cr>
nmap  <C-q>	<Esc>:q!<cr>
"vmap <C-c>	y
"nmap <C-v>	P	//no action
"imap <C-v>	<Esc>lPa			//remap paste operation

"//==== about windows switch operate =====//
if 0
nmap <C-h>	<C-W>h
nmap <C-l>	<C-W>l
nmap <c-J>	<C-w>j
nmap <c-k>	<c-w>k
else
let g:miniBufExplMapWindowNavVim = 1
endif

"//===== vim失去焦点就自动保存 =====/
""au FocusLost * :wa		"//一旦vim窗口失去焦点，即你切换到其他窗口，vim编辑文件就会自动保存
""au FocusLost * :up		"//只保存被修改的文件。
"//===== 命令行模式补全 =====//
set wildmenu				"显示补全列表,在命令行输入字符后，按TAB键出现补全列表。
set wildmode=longest:full   "补全行为设置

"//==== 关于补全 =====//
syntax enable
""filetype plugin indent on		"//是以下3条的缩写形式。(智能补全功能有效)
filetype on					"//打开文件类型检测功能
filetype plugin on			"//允许vim加载文件类型插件,会在runtimepath目录下的ftplugin子目录中搜索所有名为c.vim、c_*.vim，和c/*.vim的脚本,并执行它们.
filetype indent on			"//允许vim为不同类型的文件定义不同的缩进格式(对c类型的文件来说，它只是打开了cindent选项。)
"set completeopt=longest,menu	"//关闭Ctrl-X Ctrl_O结果的预览窗口，只显示下接窗口
set completeopt=menu			"//longest参数不能自动选择下拉窗口的第一个条目；影响lookupfile窗口的删除字符功能，退格键会把一个单词删除，不能按字符删除。
"set cpt=.,w,b

"key mapping
"使用pumvisible()来判断下拉菜单是否显示
inoremap <expr>	<CR>	pumvisible()?"\<C-Y>":"\<CR>"
inoremap <expr> <C-J>   pumvisible()?"\<PageDown>\<C-N>\<C-P>":"\<C-J>"
inoremap <expr> <C-K>   pumvisible()?"\<PageUp>\<C-P>\<C-N>":"\<C-K>"
inoremap <expr> <C-U>   pumvisible()?"\<C-E>":"\<C-U>"

"//这个按键映射会影响INSTER模式下的Tab键（Tab键补全功能，而不能输入Tab字符。
"inoremap <C-I>	<C-X><C-I>
"//补全宏定义
inoremap <C-D>  <C-X><C-D>
"//补全文件名
inoremap <C-F>	<C-X><C-F>
"//补全标签
inoremap <C-]>	<C-X><C-]>
"//补全整行
inoremap <C-L>	<C-X><C-L>
"/****** about c file *****/
set cindent

"//==== about cscope setting ========//
if has("cscope")
	set cscopetag	"//support Ctrl+] and Ctrl+t
	"set csto=1		"//set to 1 if you want the reverse search order.

	" add any cscope database in current directory	
	if filereadable("cscope.out")
		cs add cscope.out
	" else add the database pointed to by environment variable
	"elseif filereadable("../cscope.out")
	"	cs add ../cscope.out
	elseif $CSCOPE_DB != ""
		cs add $CSCOPE_DB
	endif
	"show msg when any other cscope db added
	set cscopeverbose

"	<C-R>=expand("cword")总体是为了得到：光标下的变量或函数。
"	cword 表示：cursor word, 类似的还有：cfile表示光标所在处的文件名.
	"nnoremap <C-/>s	:cs find s <C-R>=expand("<cword>")<cr><cr> //no action
	nmap <C-\>s :cs find s <C-R>=expand("<cword>")<cr><cr>
	nmap <C-\>g :cs find g <C-R>=expand("<cword>")<cr><cr>
	nmap <C-\>d :cs find d <C-R>=expand("<cword>")<cr><cr>
	nmap <C-\>c :cs find c <C-R>=expand("<cword>")<cr><cr>
	nmap <C-\>t :cs find t <C-R>=expand("<cword>")<cr><cr>
	nmap <C-\>e :cs find e <C-R>=expand("<cword>")<cr><cr>
	nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<cr><cr>
	nmap <C-\>i :cs find i <C-R>=expand("<cfile>")<cr><cr>
endif
"//===== about buffer operate =====//
"map <left>		:bn<cr>
"map <right>	:bp<cr>
"map <space>	:b#<cr>
"nn <c-n>	:bn<cr>		//Ctrl+n
"nm <C-h>	:bn<cr>		//Ctrl+h
"nm <S-h>	:bn<cr>		//Shift+h
set hidden             "//Hide buffers when they are abandoned
map	<C-N>	:bn<cr>
map	<c-P>	:bp<cr>
map	<space>	:b#<cr>
map	<c-u>	:Ack<space>
map	<silent><leader>bc :BufClose<cr>

"command! BufClose call BufcloseCloseIt()
"function! BufcloseCloseIt()
command! BufClose call <SID>BufcloseCloseIt()
function! <SID>BufcloseCloseIt()
let l:currentBufNum = bufnr("%")
let l:alternateBufNum = bufnr("#")

if buflisted(l:alternateBufNum)
buffer #
"b 4		//select buffer 4
else
bnext
"execute("b".l:alternateBufNum)		//select buffer
endif
"if bufnr("%") == l:currentBufNum
"new
"endif
if buflisted(l:currentBufNum)
"execute("bdelete!".l:currentBufNum)
execute("bd!".l:currentBufNum)
endif
endfunction

"//===========================//
"map <silent><leader>w	:w<cr>		//save file
map <silent> <S-F8>	:nohl<cr>

"about winManager
map <silent><leader>wm	:WMToggle<cr>
"let g:winManagerWindowLayout = 'FileExplorer | BufExplorer'
let g:winManagerWindowLayout = 'FileExplorer'
let g:winManagerWidth = 20
"setlocal modifiable		//no action.

"about ctags
set tags=tags
set tags+=~/.vim/arm_systags
"//===== about TagList =====//
map <silent><leader>tl	:TlistToggle<cr>
map <silent><leader>tu	:TlistUpdate<cr>
"map <F8>	:TlistUpdate<cr>
"cmap <F8>	:TlistUpdate<cr>
"imap <F8>	<Esc>:TlistUpdate<cr>a

let Tlist_Show_One_File=1
let Tlist_Use_Right_Window=1
let Tlist_Exit_OnlyWindow=1
"let Tlist_File_Fold_Auto_Close=1
let Tlist_WinWidth=26
let Tlist_Auto_Update=1

"//===== about MRU =====/
map <silent><leader>mr	:MRU<cr>
"let MRU_Use_Current_Window = 1			"//MRU 列表内容使用当前窗口打开。
"let MRU_Auto_Close = 0					"//MRU 禁止列表窗口自动关闭功能。
"let MRU_Include_Files = '\.c$\|\.h$'	"//MRU list只包含c和h文件。
"let MRU_Exclude_Files = '^/tmp/.*\|^/var/tmp/.*'  " For Unix
"let MRU_Max_Entries = 1000				"default entries is 100
"let MRU_File = 'd:\myhome\_vim_mru_files' "//default path = $HOME/.vim_mru_files
"let MRU_Window_Height = 15				"//default value = 8.
if filereadable("cscope.out") || filereadable("filenametags")
let MRU_Include_Files = '\.c$\|\.cpp\|\.h$'
let MRU_File = './.vim_mru_files'
let MRU_Max_Entries = 50
endif

""""""""""""""""""""""""""""""
" lookupfile setting
""""""""""""""""""""""""""""""
let g:LookupFile_MinPatLength = 2               "最少输入2个字符才开始查找
let g:LookupFile_PreserveLastPattern = 0        "不保存上次查找的字符串
let g:LookupFile_PreservePatternHistory = 1     "保存查找历史
let g:LookupFile_AlwaysAcceptFirst = 1          "回车打开第一个匹配项目
let g:LookupFile_AllowNewFiles = 0              "不允许创建不存在的文件
if filereadable("./filenametags")               "设置tag文件的名字
	let g:LookupFile_TagExpr = '"./filenametags"'
endif
"映射LookupFile为,lk
map <silent> <leader>lk :LUTags<cr>
"映射LUBufs为,lb
map <silent> <leader>lb :LUBufs<cr>
"映射LUWalk为,lw
map <silent> <leader>lw :LUWalk<cr>

"########################################
"auto goto the last postion of the file
"########################################
" Only do this part when compiled with support for autocommands.
if has("autocmd")
" Put these in an autocmd group, so that we can delete them easily.
augroup vimrcEx
autocmd!

" For all text files set 'textwidth' to 78 characters.
"autocmd FileType text setlocal textidth=78

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
" Also don't do it when the mark is in the first line, that is the default
" position when opening a file.
autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

augroup END
endif "has("autocmd")

""""""""""""""""""""""""""""""
" autosave senssion
""""""""""""""""""""""""""""""
function s:SaveSession()
	set sessionoptions=buffers,curdir,resize,folds,tabpages,winpos
	mks! .lsession.vim 
endfunction

function s:ReadSession()  
    let session_file = ".lsession.vim"  
    if filereadable( session_file )  
		execute  "source ". session_file
    endif  
endfunction  

if filereadable("/tmp/vims_flag") 
augroup csyncEx
	autocmd!
	autocmd VimLeave * :call s:SaveSession()
	"autocmd VimEnter * :call s:ReadSession()
augroup END
endif

