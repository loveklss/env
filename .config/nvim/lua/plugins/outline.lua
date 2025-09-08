
-- This file installs and configures a symbol outline plugin.

return {
  {
    "simrat39/symbols-outline.nvim",
    -- Use the recommended lazy-loading pattern with a keymap
    keys = {
      { "<leader>tl", "<cmd>SymbolsOutline<cr>", desc = "Toggle Symbols Outline" },
    },
    -- The config function runs when the plugin is loaded
    config = function()
      require("symbols-outline").setup({
        width = 24,
      })
    end,
  },
}
