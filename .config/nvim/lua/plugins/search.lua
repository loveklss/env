-- This file installs and configures the MultipleSearch plugin based on user request.

return {
  {
    "vim-scripts/MultipleSearch",
    config = function()
      local map = vim.keymap.set

      -- Map ; to highlight the word under the cursor with case-insensitive whole word matching
      map('n', ';', ':Search \\c\\<<C-R><C-W>\\><CR>', {
        silent = true,
        desc = "Highlight word under cursor (case-insensitive whole word)",
      })

      -- Map ;; to a safe function that resets both native and MultipleSearch highlights
      map('n', ';;', function()
        -- Always clear the native highlight
        vim.cmd('nohlsearch')
        -- Safely try to clear the MultipleSearch highlight
        -- pcall (protected call) will prevent errors if the command doesn't exist yet
        pcall(vim.cmd, 'SearchReset')
      end, {
        silent = true,
        desc = "Reset all search highlights",
      })
    end,
  },
}