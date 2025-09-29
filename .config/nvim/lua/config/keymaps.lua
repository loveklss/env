
-- This file is for setting general keymaps that are not tied to a specific plugin.

local map = vim.keymap.set

-- Indentation in visual mode
map('v', '<Tab>', '>gv', { desc = "Indent line(s)" })
map('v', '<S-Tab>', '<gv', { desc = "Un-indent line(s)" })

-- Buffer navigation
map('n', '<C-N>', ':bn<CR>', { silent = true, desc = "Next buffer" })
map('n', '<C-P>', ':bp<CR>', { silent = true, desc = "Previous buffer" })
map('n', '<leader>bd', ':bdelete<CR>', { silent = true, desc = "Close current buffer" })
map('n', '<Space>', ':b#<CR>', { silent = true, desc = "Switch to alternate buffer" })

-- Fast quitting
map('n', '<c-q>', ':q<CR>', { silent = true, desc = "Quit" })

-- Save file with Ctrl+S
map('n', '<C-s>', ':w<CR>', { silent = true, desc = "Save file" })
map('i', '<C-s>', '<Esc>:w<CR>a', { silent = true, desc = "Save file (insert mode)" })
map('v', '<C-s>', '<Esc>:w<CR>', { silent = true, desc = "Save file (visual mode)" })

-- Other useful mappings
-- Center screen when moving half-page
map('n', '<C-d>', '<C-d>zz')
map('n', '<C-u>', '<C-u>zz')

-- F9 to toggle indentation between 2-width spaces and tabs
local function toggle_indentation()
  -- Check the current state using the 'expandtab' option
  if vim.opt.expandtab:get() and vim.opt.shiftwidth:get() == 2 then
    -- If currently using 2-width spaces, switch to tabs
    vim.opt.expandtab = false
    vim.opt.tabstop = 4
    vim.opt.softtabstop = 4
    vim.opt.shiftwidth = 4
    print("Indentation set to: Tabs")
  else
    -- Default to 2-width spaces
    vim.opt.expandtab = true
    vim.opt.tabstop = 2
    vim.opt.softtabstop = 2
    vim.opt.shiftwidth = 2
    print("Indentation set to: 2-width Spaces")
  end
end

map({'n', 'v', 'i'}, '<F9>', toggle_indentation, { desc = "Toggle indentation (Tabs/Spaces)" })

-- Silent Ctrl-t
map('n', '<C-t>', function()
  pcall(vim.cmd, 'pop')
end, { silent = true, desc = "Tag back (silent)" })



