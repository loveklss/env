-- This file is for setting Neovim options.
-- This configuration has been de-duplicated from the original .vimrc and reviewed for plugin-specific options.

-- Set a global variable for the leader key
-- This must be done before any keymaps are loaded
vim.g.mapleader = ","

-- =============================================================================
-- SECTION: Core Behavior
-- =============================================================================
vim.opt.selection = "exclusive" -- Use exclusive selection
vim.opt.mouse = "a"           -- Enable mouse in all modes
vim.opt.hidden = true         -- Allow buffer switching without saving
vim.opt.autowrite = true      -- Automatically save before commands like :next
vim.opt.autoread = true       -- Automatically re-read files changed outside of vim
vim.opt.confirm = true        -- Prompt for confirmation when closing an unsaved file
vim.opt.history = 1000        -- Number of commands to remember in history
vim.opt.backspace = "indent,eol,start" -- Allow backspacing over everything in insert mode
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.fileencodings = "utf-8,gb18030,gb2312,gbk,ucs-bom,latin-1"

-- =============================================================================
-- SECTION: UI and Appearance
-- =============================================================================
vim.opt.termguicolors = true  -- Enable 24-bit RGB colors
vim.opt.background = "dark"   -- Assume a dark background
vim.opt.number = true         -- Show line numbers
vim.opt.ruler = true          -- Show cursor position
vim.opt.cursorline = true     -- Highlight the current line
vim.opt.cursorcolumn = true   -- Highlight the current column
vim.opt.laststatus = 2        -- Always show the status line
vim.opt.showcmd = true        -- Show command in the last line
vim.opt.cmdheight = 1         -- Set command line height to 1 to avoid double-line menu
vim.opt.showmatch = true      -- Show matching brackets
vim.opt.matchtime = 2         -- How long to show matching brackets (in tenths of a second)
vim.opt.title = true          -- Set the window title
vim.opt.scrolloff = 5         -- Keep 5 lines of context around the cursor
vim.opt.wrap = false          -- Do not wrap lines
vim.opt.linebreak = true      -- Break lines at word boundaries
vim.opt.foldenable = false    -- Disable code folding
vim.opt.guicursor = "n-v-c:block,i:ver25" -- Set cursor shape for different modes

-- =============================================================================
-- SECTION: Indentation and Tabs
-- =============================================================================
vim.opt.tabstop = 4           -- Number of spaces a <Tab> in the file counts for
vim.opt.softtabstop = 4       -- Number of spaces to insert for a <Tab>
vim.opt.shiftwidth = 4        -- Number of spaces to use for each step of (auto)indent
vim.opt.autoindent = true     -- Copy indent from current line when starting a new line
vim.opt.cindent = true        -- Enable C-style indenting
vim.opt.expandtab = false     -- Use real tabs, not spaces

-- =============================================================================
-- SECTION: Search
-- =============================================================================
vim.opt.hlsearch = true       -- Highlight all matches on search
vim.opt.incsearch = true      -- Incremental search
vim.opt.ignorecase = true     -- Ignore case in search patterns
vim.opt.smartcase = true      -- Override the 'ignorecase' option if the search pattern contains upper case characters

-- =============================================================================
-- SECTION: Command-line and Completion
-- =============================================================================
vim.opt.wildmenu = true       -- Display a menu for command-line completion
vim.opt.wildmode = "list:full" -- Completion mode
vim.opt.completeopt = "menu,longest" -- Set completion options. Removed 'preview' to avoid extra windows.

-- =============================================================================
-- SECTION: Final Setup Commands
-- =============================================================================
-- Enable filetype detection and plugins. This is crucial.
vim.cmd("filetype plugin indent on")
vim.cmd("syntax enable")