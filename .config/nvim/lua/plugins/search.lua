
-- This file installs and configures the MultipleSearch plugin based on user request.

return {
  {
    "vim-scripts/MultipleSearch",
    config = function()
      local map = vim.keymap.set

      -- Map ; to highlight the word under the cursor
      -- <C-R><C-W> is the standard way to insert the word under the cursor in the command line
      map('n', ';', ':Search <C-R><C-W><CR>', {
        silent = true,
        desc = "Highlight word under cursor",
      })

      -- Map ;; to reset both native and MultipleSearch highlights
      map('n', ';;', ':nohlsearch<CR>:SearchReset<CR>', {
        silent = true,
        desc = "Reset all search highlights",
      })
    end,
  },
}
