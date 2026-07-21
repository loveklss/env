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
          position = "right",
          width = 30, -- Corresponds to NERDTreeWinSize = 30
          mappings = {
            ["/"] = "none", -- 禁用 neo-tree 默认的模糊搜索，恢复 vim 原生的 / 搜索
            ["f"] = "none", -- 禁用 neo-tree 默认的 f 搜索，以便支持全局的 fo 快捷键
            ["<esc>"] = function(state)
              require("neo-tree.command").execute({ action = "close" })
            end,
            ["<CR>"] = function(state)
              -- 自定义Enter行为：打开文件并关闭neo-tree
              local node = state.tree:get_node()
              if node.type == "file" then
                -- 先关闭 neo-tree，再打开文件，避免 buffer 命名冲突 (E95)
                require("neo-tree.command").execute({ action = "close" })
                vim.schedule(function()
                  vim.cmd("edit " .. vim.fn.fnameescape(node.path))
                end)
              else
                require("neo-tree.sources.filesystem.commands").toggle_node(state)
              end
            end,
          },
        },
        close_if_last_window = false,
        popup_border_style = "rounded",
        enable_git_status = false,
        enable_diagnostics = true,
        enable_modified_markers = false,
        default_component_configs = {
          git_status = {
            symbols = {
              -- Change type
              added     = "",
              deleted   = "",
              modified  = "",
              renamed   = "",
              -- Status type
              untracked = "",
              ignored   = "",
              unstaged  = "",
              staged    = "",
              conflict  = "",
            }
          },
          modified = {
            symbol = "",
          }
        }
      })

      -- Set the keymap to toggle it, just like in your .vimrc
      vim.keymap.set("n", "fp", function()
        -- 如果 outline 处于打开状态，先关闭它
        local outline_ok, outline = pcall(require, "outline")
        if outline_ok and outline.is_open() then
          outline.close()
        end
        vim.cmd("Neotree filesystem toggle")
      end, {
        silent = true,
        desc = "Toggle NeoTree File Explorer",
      })
    end,
  },
}