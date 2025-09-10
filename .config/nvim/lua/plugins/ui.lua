
-- This file contains all UI-related plugins

return {
  -- 1. Icons
  -- This plugin provides icons for many other plugins
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- 2. Status Line
  -- A modern replacement for vim-airline
  {
    "nvim-lualine/lualine.nvim",
    enabled = not vim.g.vscode,
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- Requires icons
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",
          icons_enabled = true,
          component_separators = { left = '', right = ''},
          section_separators = { left = '', right = ''},
        },
      })
    end,
  },

  -- 3. Colorscheme
  -- Your preferred colorscheme from .vimrc
  {
    "nordtheme/vim",
    name = "nord",
    enabled = not vim.g.vscode,
    lazy = false,      -- We want the colorscheme to load at startup
    priority = 1000,   -- Make sure it has high priority to load before other plugins
    config = function()
      -- Load the colorscheme first
      vim.cmd.colorscheme("nord")

      -- Then, override the background to be pure black
      -- We also override NormalFloat for floating windows like Telescope
      vim.api.nvim_set_hl(0, "Normal", { bg = "#000000" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#000000" })

      -- Set cursorline to be an underline with a transparent background
      vim.api.nvim_set_hl(0, "CursorLine", { underline = true, bg = "none" })
    end,
  },
}
