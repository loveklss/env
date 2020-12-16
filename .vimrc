set nocompatible              " be iMproved, required
filetype off                  "

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
Plugin 'RobertCWebb/vim-jumpmethod.git'
" plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" Git plugin not hosted on GitHub
" Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
" Plugin 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Install L9 and avoid a Naming conflict if you've already installed a
" different version somewhere else.
" Plugin 'ascenator/L9', {'name': 'newL9'}
Plugin 'preservim/nerdcommenter'
Plugin 'octol/vim-cpp-enhanced-highlight'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'edkolev/tmuxline.vim'
Plugin 'edkolev/promptline.vim'
" Plugin 'python-mode/python-mode'
" Plugin 'nathanaelkane/vim-indent-guides'
" Plugin 'joshdick/onedark.vim'
" Plugin 'itchyny/lightline.vim'
" Plugin 'vim-ctrlspace/vim-ctrlspace'
" Plugin 'mox-mox/vim-localsearch'
" Plugin 'bling/vim-bufferline'


Plugin 'jlanzarotta/bufexplorer'
" Plugin 'altercation/vim-colors-solarized'
Plugin 'nanotech/jellybeans.vim'
Plugin 'mg979/vim-studio-dark'
Plugin 'rhysd/vim-clang-format'
Plugin 'Raimondi/delimitMate'
Plugin 'othree/html5.vim'
Plugin 'preservim/nerdtree'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-repeat'
Plugin 'pbrisbin/vim-mkdir'
Plugin 'kien/ctrlp.vim'
Plugin 'tacahiroy/ctrlp-funky'
Plugin 'majutsushi/tagbar'
Plugin 'christoomey/vim-run-interactive'
Plugin 'vim-scripts/MultipleSearch'
" Plugin 'FromtonRouge/OmniCppComplete'
Plugin 'mileszs/ack.vim'

" auto completor
Plugin 'Shougo/neocomplcache'
" Plugin 'Shougo/deoplete.nvim'
" Plugin 'roxma/nvim-yarp'
" Plugin 'roxma/vim-hug-neovim-rpc'

" Plugin 'ycm-core/YouCompleteMe'

Plugin 'ervandew/supertab'
Plugin 'jistr/vim-nerdtree-tabs'
Plugin 'Shougo/vimshell'
Plugin 'Shougo/vimproc.vim'

" snippets
" Bundle 'garbas/vim-snipmate'
" Bundle 'honza/vim-snippets'
"------ snipmate dependencies -------
Bundle 'MarcWeber/vim-addon-mw-utils'
Bundle 'tomtom/tlib_vim'

Plugin 'easymotion/vim-easymotion'
Plugin 'junegunn/vim-easy-align'
Plugin 'adelarsq/vim-matchit'
Plugin 'andymass/vim-matchup'

Plugin 'sjl/gundo.vim'
Plugin 'godlygeek/tabular'
Plugin 'nathanaelkane/vim-indent-guides'

" Plugin 'scrooloose/syntastic'
Plugin 'bronson/vim-trailing-whitespace'

Plugin 'nvie/vim-togglemouse'

" Plugin 'fatih/vim-go'
" Plugin 'kien/rainbow_parentheses.vim'

"-------------
" Cursorline
"-------------
" Plugin 'miyakogi/conoline.vim'
Plugin 'osyo-manga/vim-brightest'
Plugin 'vim-scripts/CursorLineCurrentWindow'
Plugin 'inside/vim-search-pulse'
" Plugin 'rrethy/vim-illuminate'


"--------------
" Color Schemes
"--------------
Plugin 'rickharris/vim-blackboard'
Plugin 'altercation/vim-colors-solarized'
Plugin 'rickharris/vim-monokai'
Plugin 'tpope/vim-vividchalk'
Plugin 'Lokaltog/vim-distinguished'
Plugin 'chriskempson/vim-tomorrow-theme'
Plugin 'fisadev/fisa-vim-colorscheme'
Plugin 'jaromero/vim-monokai-refined'
Plugin 'challenger-deep-theme/vim', {'name': 'challenger-deep-theme'}
Plugin 'miyakogi/slateblue.vim'

"-------------
" Navigator
"-------------
Plugin 'MattesGroeger/vim-bookmarks'
Plugin 'christoomey/vim-tmux-navigator'

" Plugin 'tmhedberg/SimpylFold'
" Plugin 'maralla/completor.vim'
" Syntax check...
" Plugin 'vim-syntastic/syntastic'
" Plugin 'tomtom/tcomment_vim'
" Plugin 'jwalton512/vim-blade'
" Plugin 'jistr/vim-nerdtree-tabs'
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
set ignorecase		"Do case insensitive matching(忽略大小写)
"set smartcase		"Do smart case matching
"//===== display setting =====//
set t_Co=256		"set terminal color 256
"colorscheme freya	"or color freya
"colorscheme navajo_hbp
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
" map <C-\>n :%s/<C-R><C-W>//gn<cr>						"统计光标处单词的总数
" map  <F3> :vimgrep <C-R><C-W> %<cr> :cw<cr>
" map! <F3> :vimgrep <C-R><C-W> %<cr> :cw<cr>
" map <F7> <Esc>:cp<cr>
" map! <F7> <Esc>:cp<cr>
" map <F8> <Esc>:cn<cr>
" map! <F8> <Esc>:cn<cr>
" map <C-F8> <Esc>:ccl<cr>
" map! <C-F8> <Esc>:ccl<cr>

"imap <C-a>	<Esc>ggVG		"//映射Ctrl+a全选功能（映射不成功）
"lmap <C-a>	<Esc>ggVG		"//映射Ctrl+a全选功能（映射不成功）
"//Tab缩进映射
vmap <Tab>	>
vmap <S-Tab> <
"//==== Ctrl-s 保存 =====//
" nmap <C-s>	:w<cr>
" vmap <C-s>	:w<cr>
" cmap <C-s>	:w<cr>
" imap <C-s>	<Esc>:w<cr>
nmap <F9>   :set expandtab<cr>:set tabstop=2<cr>:set softtabstop=2<cr>:set shiftwidth=2<cr>
vmap <F9>   :set expandtab<cr>:set tabstop=2<cr>:set softtabstop=2<cr>:set shiftwidth=2<cr>
cmap <F9>   :set expandtab<cr>:set tabstop=2<cr>:set softtabstop=2<cr>:set shiftwidth=2<cr>
imap <F9>   <Esc>:set expandtab<cr>:set tabstop=2<cr>:set softtabstop=2<cr>:set shiftwidth=2<cr>i
"nmap <F9>	:w<cr>
"vmap <F9>	:w<cr>
"cmap <F9>	:w<cr>
"imap <F9>	<Esc>:w<cr>
"//===== F5 退出窗口 =====//
map  <c-q>	<Esc><Esc>:q<cr>
map! <c-q>	<Esc><Esc>:q<cr>
" map  <S-F5>	<Esc><Esc>:qa<cr>
" map! <S-F5>	<Esc><Esc>:qa<cr>
" map  <C-F5>	<Esc><Esc>:q!<cr>
" map! <C-F5> <Esc><Esc>:q!<cr>
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

"about winManager
"map <silent><leader>wm	:WMToggle<cr>
"let g:winManagerWindowLayout = 'FileExplorer | BufExplorer'
"let g:winManagerWindowLayout = 'FileExplorer'
"let g:winManagerWidth = 30
"setlocal modifiable		//no action.

"about ctags
set tags=tags
"set tags+=~/.vim/arm_systags
"//===== about TagList =====//
map <silent><leader>tl	:TlistToggle<cr>tu	:TlistUpdate<cr>
map <silent><leader>tu	:TlistUpdate<cr>
"map <F8>	:TlistUpdate<cr>
"cmap <F8>	:TlistUpdate<cr>
"imap <F8>	<Esc>:TlistUpdate<cr>a

let Tlist_Show_One_File=1
let Tlist_Use_Right_Window=1
let Tlist_Exit_OnlyWindow=1
"let Tlist_File_Fold_Auto_Close=1
let Tlist_WinWidth=30
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

" let g:airline_theme="zenburn"
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#whitespace#enabled = 0
let g:airline#extensions#whitespace#symbol = '!'

" colorscheme jellybeans
" colorscheme freya_hbp
" colorscheme challenger_deep
colorscheme vsdark
" let g:Vsd.contrast = 2  " high
" let g:Vsd.contrast = 0  " low
" let g:Vsd.contrast = 1  " medium (default)

"set termguicolors
set background=dark
hi! Normal ctermbg=NONE guibg=NONE
hi! NonText ctermbg=NONE guibg=NONE

if &background == "dark"
	let s:base03 = "NONE"
	let s:base02 = "NONE"
endif


" Plugins config
" vim-clang-format
vmap <silent><leader>cf :ClangFormat<cr>
" nerdtree
map <silent><leader>wm	:NERDTreeToggle<cr>:NERDTreeRefreshRoot<cr>
let NERDTreeIgnore=['\.vim$', '\~$', '\.pyc$', '\.swp$']
let NERDTreeShowBookmarks=1
let NERDTreeShowHidden=0
let NERDTreeShowLineNumbers=1
let NERDChristmasTree=0
let NERDTreeWinSize=30
let NERDTreeChDirMode=2

" Ctrlp
nmap <F2> :LUTags<Cr>
nmap <F3> :CtrlPFunky<Cr>
" nmap <F4> :execute 'CtrlPFunky ' . expand('<cword>')<Cr>
nmap <F4> :CtrlPQuickfix<Cr>
nmap <F5> :GundoToggle<cr>
let g:ctrlp_map = '<c-s>'
let g:ctrlp_cmd = 'CtrlPMixed'
let g:ctrlp_by_filename = 0
" let g:ctrlp_match_window = 'bottom,order:ttb,min:1,max:10,results:10'

let g:ctrlp_prompt_mappings = {
	\ 'PrtSelectMove("j")':   ['<c-n>', '<down>'],
	\ 'PrtSelectMove("k")':   ['<c-p>', '<up>'],
	\ 'PrtHistory(-1)':       ['<c-j>'],
    \ 'PrtHistory(1)':        ['<c-k>'],
	\ }

set wildignore+=*/tmp/*,*.so,*.o,*.a,*.obj,*.swp,*.zip,*.pyc,*.pyo,*.class,.DS_Store  " MacOSX/Linux
set wildignore+=*/tmp/*,*.so,*.swp,*.zip     " MacOSX/Linux
set wildignore+=*\\tmp\\*,*.swp,*.zip,*.exe  " Windows
let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(exe|so|dll)$',
  \ 'link': 'some_bad_symbolic_links',
  \ }

" let g:ctrlp_regexp = 0
" let g:ctrlp_user_command = 'cat %s/cscope.files'
" ctrlp-funky
let g:ctrlp_funky_multi_buffers = 1
let g:ctrlp_funky_sort_by_mru = 1
let g:ctrlp_funky_syntax_highlight = 1
let g:ctrlp_funky_use_cache = 1
" let g:ctrlp_funky_nerdtree_include_files = 1
" let g:ctrlp_types = [ 'tag', 'funky' ]

" matchup
let loaded_matchit = 1

" Tagbar
map <silent><leader>tl	:TagbarToggle<cr>
map <silent><leader>tb	:TagbarToggle<cr>
let g:tagbar_width = 30
let g:tagbar_expand = 1
let g:tagbar_sort = 0
let g:tagbar_compact = 1
let g:tagbar_autofocus = 1
" let g:tagbar_vertical = 30
" let g:tagbar_indent = 1
"let g:tagbar_show_visibility = 0

" vim-run-interactive
nnoremap <leader>ri :RunInInteractiveShell<space>

" MultipleSearch
" <leader>mm
nnoremap <silent><Leader>* :Search <C-R><C-W><cr>
" map <silent><F8>	:nohl<cr>
map <silent><F8>	:SearchReset<cr>
let g:MultipleSearchColorSequence = "Cyan, Green, Blue, LightRed, LightYellow"
let g:MultipleSearchTextColorSequence = "black, black, black, black, black"
let g:MultipleSearchMaxColors=5

" OmniCppcomplete
" set nocp
filetype plugin on
inoremap <C-D>  <C-X><C-O>
let OmniCpp_SelectFirstItem = 0

" Supertab
let g:SuperTabDefaultCompletionType = "context"
" let g:SuperTabDefaultCompletionType = "<c-x><c-o>"
let g:SuperTabCompletionContexts = ['s:ContextText', 's:ContextDiscover']
let g:SuperTabContextTextOmniPrecedence = ['&omnifunc', '&completefunc']
let g:SuperTabContextDiscoverDiscovery =
		        \ ["&completefunc:<c-x><c-u>", "&omnifunc:<c-x><c-o>"]

" Neocomplcache
"Note: This option must set it in .vimrc(_vimrc).  NOT IN .gvimrc(_gvimrc)!
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplcache.
let g:neocomplcache_enable_at_startup = 1
" Use smartcase.
let g:neocomplcache_enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplcache_min_syntax_length = 3
let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'
let g:neocomplcache_auto_completion_start_length = 2
let g:neocomplcache_disable_auto_complete = 0
let g:neocomplcache_max_list = 25
let g:neocomplcache_enable_prefetch = 1
set completeopt-=preview
"let g:neocomplcache_caching_limit_file_size = 1000
let g:NeoComplCacheCachingTags = 1

" Enable heavy features.
" Use camel case completion.
"let g:neocomplcache_enable_camel_case_completion = 1
" Use underbar completion.
"let g:neocomplcache_enable_underbar_completion = 1

" Define dictionary.
let g:neocomplcache_dictionary_filetype_lists = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
    \ 'scheme' : $HOME.'/.gosh_completions'
        \ }

" Define keyword.
if !exists('g:neocomplcache_keyword_patterns')
    let g:neocomplcache_keyword_patterns = {}
endif
let g:neocomplcache_keyword_patterns['default'] = '\h\w*'

if !exists('g:neocomplcache_omni_patterns')
	let g:neocomplcache_omni_patterns = {}
endif
let g:neocomplcache_omni_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
let g:neocomplcache_omni_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
let g:neocomplcache_omni_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

" Plugin key-mappings.
inoremap <expr><C-g>     neocomplcache#undo_completion()
inoremap <expr><C-l>     neocomplcache#complete_common_string()

" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  return neocomplcache#smart_close_popup() . "\<CR>"
  " For no inserting <CR> key.
  "return pumvisible() ? neocomplcache#close_popup() : "\<CR>"
endfunction
" <TAB>: completion.
"inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr><C-y>  neocomplcache#close_popup()
inoremap <expr><C-e>  neocomplcache#cancel_popup()
" Close popup by <Space>.
"inoremap <expr><Space> pumvisible() ? neocomplcache#close_popup() : "\<Space>"

" For cursor moving in insert mode(Not recommended)
"inoremap <expr><Left>  neocomplcache#close_popup() . "\<Left>"
"inoremap <expr><Right> neocomplcache#close_popup() . "\<Right>"
"inoremap <expr><Up>    neocomplcache#close_popup() . "\<Up>"
"inoremap <expr><Down>  neocomplcache#close_popup() . "\<Down>"
" Or set this.
"let g:neocomplcache_enable_cursor_hold_i = 1
" Or set this.
"let g:neocomplcache_enable_insert_char_pre = 1

" AutoComplPop like behavior.
"let g:neocomplcache_enable_auto_select = 1

" Shell like behavior(not recommended).
"set completeopt+=longest
"let g:neocomplcache_enable_auto_select = 1
"let g:neocomplcache_disable_auto_complete = 1
"inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"

" neoplete
let g:deoplete#enable_at_startup = 1

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" Enable heavy omni completion.
if !exists('g:neocomplcache_force_omni_patterns')
  let g:neocomplcache_force_omni_patterns = {}
endif
let g:neocomplcache_force_omni_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
let g:neocomplcache_force_omni_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
let g:neocomplcache_force_omni_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

" For perlomni.vim setting.
" https://github.com/c9s/perlomni.vim
let g:neocomplcache_force_omni_patterns.perl = '\h\w*->\h\w*\|\h\w*::'

" nerdcommenter
let NERDSpaceDelims=1
" nmap <D-/> :NERDComToggleComment<cr>
let NERDCompactSexyComs=1

" easymotion
map f <Plug>(easymotion-prefix)
map ff <Plug>(easymotion-s)
map fs <Plug>(easymotion-f)
map fl <Plug>(easymotion-lineforward)
map fj <Plug>(easymotion-j)
map fk <Plug>(easymotion-k)
map fh <Plug>(easymotion-linebackward)
let g:EasyMotion_smartcase = 1
let g:EasyMotion_force_csapprox = 0

" my customize
" nmap <C-]>:cs find g <C-R>=expand("<cword>")<cr><cr>

" highlight current line
au WinLeave * set nocursorline nocursorcolumn
au WinEnter * set cursorline cursorcolumn
set cursorline cursorcolumn
hi clear CursorLine
hi CursorLine gui=underline cterm=underline
hi CursorColumn cterm=NONE
" hi CursorColumn cterm=NONE ctermbg=darkred ctermfg=white guibg=darkred guifg=white

" search
" set incsearch
"set highlight 	" conflict with highlight current line
" set ignorecase
" set smartcase

" editor settings
set history=1000
set nocompatible
set nofoldenable                                                  " disable folding"
set confirm                                                       " prompt when existing from an unsaved file
set backspace=indent,eol,start                                    " More powerful backspacing
set t_Co=256                                                      " Explicitly tell vim that the terminal has 256 colors "
set mouse=a                                                       " use mouse in all modes
set report=0                                                      " always report number of lines changed                "
set nowrap                                                        " dont wrap lines
set scrolloff=5                                                   " 5 lines above/below cursor when scrolling
set number                                                        " show line numbers
set showmatch                                                     " show matching bracket (briefly jump)
set showcmd                                                       " show typed command in status bar
set title                                                         " show file in titlebar
set laststatus=2                                                  " use 2 lines for the status bar
set matchtime=2                                                   " show matching bracket for 0.2 seconds
set matchpairs+=<:>                                               " specially for html
" set relativenumber

" Default Indentation
" set autoindent
" set smartindent     " indent when
" set tabstop=8       " tab width
" set softtabstop=4   " backspace
" set shiftwidth=4    " indent width
" set textwidth=79
" set smarttab
set noexpandtab       " expand tab to space

autocmd FileType php setlocal tabstop=2 shiftwidth=2 softtabstop=2 textwidth=120
autocmd FileType ruby setlocal tabstop=2 shiftwidth=2 softtabstop=2 textwidth=120
autocmd FileType php setlocal tabstop=4 shiftwidth=4 softtabstop=4 textwidth=120
autocmd FileType coffee,javascript setlocal tabstop=2 shiftwidth=2 softtabstop=2 textwidth=120
autocmd FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4 textwidth=120
autocmd FileType html,htmldjango,xhtml,haml setlocal tabstop=2 shiftwidth=2 softtabstop=2 textwidth=0
autocmd FileType sass,scss,css setlocal tabstop=2 shiftwidth=2 softtabstop=2 textwidth=120

" syntax support
autocmd Syntax javascript set syntax=jquery   " JQuery syntax support
" js
let g:html_indent_inctags = "html,body,head,tbody"
let g:html_indent_script1 = "inc"
let g:html_indent_style1 = "inc"

" When editing a file, always jump to the last cursor position
autocmd BufReadPost *
      \ if ! exists("g:leave_my_cursor_position_alone") |
      \     if line("'\"") > 0 && line ("'\"") <= line("$") |
      \         exe "normal g'\"" |
      \     endif |
      \ endif

" w!! to sudo & write a file
cmap w!! %!sudo tee >/dev/null %

" Quickly edit/reload the vimrc file
nmap <silent> <leader>ev :e $MYVIMRC<CR>
nmap <silent> <leader>sv :so $MYVIMRC<CR>

nnoremap <leader>a :Ack

" vim-easy-align
vmap <Leader>a <Plug>(EasyAlign)
nmap <Leader>a <Plug>(EasyAlign)
if !exists('g:easy_align_delimiters')
	let g:easy_align_delimiters = {}
endif
let g:easy_align_delimiters['#'] = { 'pattern': '#', 'ignore_groups': ['String'] }

" syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0

" delimitMate
let delimitMate_matchpairs = "(:),[:],{:}"

set hlsearch!		"high light the result of search.

" YouCompleteMe
let g:ycm_auto_trigger = 0
let g:ycm_show_diagnostics_ui = 0

" remove tags search for complete
"set complete-=tag

" conoline
" let g:conoline_auto_enable = 1

" - osyo-manga/vim-brightest
" BrightestEnable
" BrightestDisable

" let g:brightest#highlight = {
" \   "group" : "BrightestUnderline"
" \}
" let g:brightest#highlight_in_cursorline = {
 "\	"group" : "BrightestCursorLineBg"
" "\}

let g:brightest#pattern = '\k\+'

" let g:brightest#enable_filetypes = {
" \	"cpp" : 0
" \}

