
-- This file installs and configures a symbol outline plugin.

return {
  {
    "simrat39/symbols-outline.nvim",
    enabled = not vim.g.vscode,
    -- Use the recommended lazy-loading pattern with a keymap
    keys = {
      { "<leader>tl", "<cmd>SymbolsOutline<cr>", desc = "Toggle Symbols Outline" },
    },
    -- The config function runs when the plugin is loaded
    config = function()
      require("symbols-outline").setup({
        width = 24,
        auto_close = true,  -- 选择符号后自动关闭侧边框
      })
    end,
  },
}
