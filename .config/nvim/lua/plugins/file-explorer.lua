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
            ["<CR>"] = function(state)
              -- 自定义Enter行为：打开文件并关闭neo-tree
              local node = state.tree:get_node()
              if node.type == "file" then
                require("neo-tree.sources.filesystem.commands").open(state)
                -- 使用vim.schedule异步关闭，避免buffer冲突
                vim.schedule(function()
                  require("neo-tree.command").execute({ action = "close" })
                end)
              else
                require("neo-tree.sources.filesystem.commands").toggle_node(state)
              end
            end,
          },
        },
        close_if_last_window = false,
        popup_border_style = "rounded",
        enable_git_status = true,
        enable_diagnostics = true,
      })

      -- Set the keymap to toggle it, just like in your .vimrc
      vim.keymap.set("n", "<leader>wm", ":Neotree filesystem toggle<CR>", {
        silent = true,
        desc = "Toggle NeoTree File Explorer",
      })
    end,
  },
}