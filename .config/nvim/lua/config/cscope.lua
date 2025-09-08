
-- This file configures the classic cscope and gtags integration.

return {
  -- This is a configuration file, not a plugin.
  "cscope-settings",
  lazy = false, -- We want these settings to apply on startup.
  config = function()
    -- 1. Set cscope options from .vimrc
    vim.opt.cscopetag = true      -- Use cscope for tag commands
    vim.opt.cscopeprg = 'gtags-cscope' -- Use gtags-cscope as the backend
    vim.opt.cscopeverbose = true  -- Show messages when adding a database

    -- 2. Automatically find and add the GTAGS database
    -- vim.fn.findfile searches up from the current directory (;) for the file.
    local gtags_file = vim.fn.findfile("GTAGS", ".;")
    if gtags_file ~= "" then
      vim.cmd("silent cs add " .. gtags_file)
      print("GTAGS database loaded from: " .. gtags_file)
    end

    -- 3. Map cscope query keybindings from .vimrc
    local map = vim.keymap.set
    local expand = vim.fn.expand
    local cmd = vim.cmd

    -- Helper function to run cscope queries
    local function cs_find(mode)
      local word = expand('<cword>')
      local file = expand('<cfile>')
      if mode == 'f' or mode == 'i' then
        cmd('cs find ' .. mode .. ' ' .. file)
      else
        if word == '' then
          print("No word under cursor for cscope query.")
          return
        end
        cmd('cs find ' .. mode .. ' ' .. word)
      end
    end

    -- Keymaps with corrected backslash escaping
    map('n', '<C-\\_s>', function() cs_find('s') end, { desc = 'Cscope: Find [S]ymbol' })
    map('n', '<C-\\_g>', function() cs_find('g') end, { desc = 'Cscope: Find [G]lobal definition' })
    map('n', '<C-\\_d>', function() cs_find('d') end, { desc = 'Cscope: Find functions [D]ownstream (called by)' })
    map('n', '<C-\\_c>', function() cs_find('c') end, { desc = 'Cscope: Find [C]alls to function' })
    map('n', '<C-\\_t>', function() cs_find('t') end, { desc = 'Cscope: Find [T]ext string' })
    map('n', '<C-\\_e', function() cs_find('e') end, { desc = 'Cscope: Find [E]grep pattern' })
    map('n', '<C-\\_f', function() cs_find('f') end, { desc = 'Cscope: Find [F]ile' })
    map('n', '<C-\\_i', function() cs_find('i') end, { desc = 'Cscope: Find files [I]ncluding file' })
  end,
}
