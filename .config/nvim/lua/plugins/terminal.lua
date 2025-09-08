
-- This file installs and configures toggleterm for a floating terminal.

return {
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    config = function()
      require("toggleterm").setup({
        -- A more sensible size for a floating terminal
        size = function(term)
          if term.direction == "horizontal" then
            return 15
          elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
          end
        end,
        start_in_insert = true,
        -- This makes it open in the center as a floating window
        direction = 'float',
      })

      -- Helper function to set terminal keymaps
      function _G.set_terminal_keymaps()
        local opts = { buffer = 0 }
        -- Exit terminal mode with Esc or jk
        vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
        vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
        -- Navigate between vim windows from within the terminal
        vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
        vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
        vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
        vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
      end

      -- Set the keymaps when a terminal is opened
      vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

      -- Set the main toggle keymap
      vim.keymap.set("n", "<leader>t", "<cmd>ToggleTerm<cr>", {
        desc = "Toggle floating terminal"
      })
    end
  }
}
