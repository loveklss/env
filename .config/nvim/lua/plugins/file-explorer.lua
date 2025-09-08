return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = not vim.g.vscode,
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- Already installed, but good to list as a dependency
      "MunifTanjim/nui.nvim",
    },
    config = function()
      -- Set up neo-tree
      require("neo-tree").setup({
        -- This setup is to match the behavior of your NERDTree configuration
        filesystem = {
          filtered_items = {
            visible = true,
            hide_dotfiles = true, -- Corresponds to NERDTreeShowHidden = 0
            hide_gitignored = true,
            -- This is the equivalent of NERDTreeIgnore, with corrected escaping
            hide_by_name = {
              "node_modules",
              "\\.vim$",
              "\\~$",
              "\\.pyc$",
              "\\.swp$",
            },
            never_show = { -- remains hidden even if visible is toggled to true
              ".DS_Store",
              "thumbs.db",
            },
          },
        },
        window = {
          width = 30, -- Corresponds to NERDTreeWinSize = 30
          mappings = {
            ["<Esc>"] = "close_window",
          },
        },
      })

      -- Set the keymap to toggle it, just like in your .vimrc
      vim.keymap.set("n", "<leader>wm", ":Neotree filesystem toggle<CR>", {
        silent = true,
        desc = "Toggle NeoTree File Explorer",
      })
    end,
  },
}