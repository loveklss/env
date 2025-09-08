
-- This file installs a collection of functionality-enhancing plugins.

return {
  -- 1. GitSigns: Git integration for the sign column
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require('gitsigns').setup({
        -- Default options are excellent
      })
    end
  },

  -- 2. Trouble: A pretty list for diagnostics
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>xx", "<cmd>TroubleToggle<cr>", desc = "Toggle Trouble (diagnostics list)" },
      { "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics" },
      { "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document Diagnostics" },
    },
    opts = {
      -- Use your preferred icons
      icons = true,
    },
  },

  -- 3. Auto-Session: Automatically save and restore sessions
  {
    "rmagatti/auto-session",
    config = function()
      require("auto-session").setup({
        log_level = "error",
        -- Do not create session files for directories like home, downloads, etc.
        auto_session_suppress_dirs = { "~/", "~/Downloads", "/" },
      })
    end,
  },
}
