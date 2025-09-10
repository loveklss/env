
-- This file installs and configures nvim-treesitter for advanced syntax highlighting.

return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- The build step is essential to install the parsers
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        -- A list of parser names, or "all"
        ensure_installed = { "c", "cpp", "lua", "python", "vim", "vimdoc", "bash", "json", "cmake" },

        -- Install parsers synchronously (only applied to `ensure_installed`)
        sync_install = false,

        -- Automatically install missing parsers when entering a buffer
        auto_install = true,

        -- The highlight module is what provides the enhanced syntax highlighting
        highlight = {
          enable = true,
          -- Some languages require regex-based highlighting as well, enable for those.
          additional_vim_regex_highlighting = false,
        },

        -- Enable the indentation module
        indent = {
          enable = true,
        },
      })
    end,
  },
}
