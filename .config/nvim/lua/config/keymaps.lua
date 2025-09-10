
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

-- Other useful mappings
-- Center screen when moving half-page
map('n', '<C-d>', '<C-d>zz')
map('n', '<C-u>', '<C-u>zz')

-- F9 to toggle indentation between 2-width spaces and 4-width tabs
local function toggle_indentation()
  -- Check the current state using the 'expandtab' option
  if vim.opt.expandtab:get() then
    -- If currently using spaces, switch to 4-width tabs
    vim.opt.expandtab = false
    vim.opt.tabstop = 4
    vim.opt.softtabstop = 4
    vim.opt.shiftwidth = 4
    print("Indentation set to: 4-width Tabs")
  else
    -- If currently using tabs, switch to 2-width spaces
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

-- Silent search
map('n', '/', function()
  local pattern = vim.fn.input('Search: ')
  if pattern ~= '' then
    pcall(vim.cmd, '/' .. pattern)
  end
end, { silent = true, desc = "Search (silent)" })

map('n', '?', function()
  local pattern = vim.fn.input('Search backward: ')
  if pattern ~= '' then
    pcall(vim.cmd, '?' .. pattern)
  end
end, { silent = true, desc = "Search backward (silent)" })


