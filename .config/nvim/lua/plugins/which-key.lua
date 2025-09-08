
-- This file installs and configures which-key.nvim

return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy", -- Load it on the first keypress to speed up startup
    config = function()
      require("which-key").setup({
        -- your configuration comes here
        -- or leave it empty to use the default settings
      })
    end
  }
}
