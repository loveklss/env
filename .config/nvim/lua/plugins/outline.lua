
-- This file installs and configures a symbol outline plugin.

return {
  {
    "hedyhli/outline.nvim",
    enabled = not vim.g.vscode,
    -- Use the recommended lazy-loading pattern with a keymap
    keys = {
      { "<leader>tl", "<cmd>Outline<cr>", desc = "Toggle Symbols Outline" },
    },
    -- The config function runs when the plugin is loaded
    config = function()
      require("outline").setup({
        outline_window = {
          width = 44,
          relative_width = false,
          auto_close = true,  -- Enter键跳转后自动关闭
        },
        keymaps = {
          close = {"<Esc>", "q"},
          goto_location = "<Cr>",  -- Enter跳转并关闭
          peek_location = "o",     -- o键预览但不关闭侧边栏
          hover_symbol = "K",
          toggle_preview = "P",
          rename_symbol = "r",
          code_actions = "a",
          fold = "h",
          unfold = "l",
          fold_all = "W",
          unfold_all = "E",
          fold_reset = "R",
        },
      })
    end,
  },
}
