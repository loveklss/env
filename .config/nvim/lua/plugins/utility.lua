
-- This file contains a collection of useful utility plugins.

return {
  -- 1. Commenting
  -- gc to comment, gcc to comment the current line
  { "numToStr/Comment.nvim", opts = {} },

  -- 2. Surrounding pairs (e.g., ysiw" to surround a word with quotes)
  {
    "kylechui/nvim-surround",
    version = "*", -- Use latest version
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end,
  },

  -- 3. Git Integration
  -- Provides a powerful wrapper around git commands
  { "tpope/vim-fugitive" },

  -- 4. Enhanced bracket matching for %
  { "andymass/vim-matchup", event = "VeryLazy" },

  -- 5. Fast cursor movement (replaces vim-easymotion)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {},
    -- stylua: ignore
    -- Default keys are excellent, but we can define them here for clarity
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash Jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Flash Remote" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },
}
