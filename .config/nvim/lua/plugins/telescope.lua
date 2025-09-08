
-- This file configures Telescope and its related keybindings.

return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.6",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        -- You can add Telescope configurations here if needed in the future.
      })

      local map = vim.keymap.set
      local builtin = require("telescope.builtin")

      -- Define the "smart" fallback function for document symbols
      local function document_symbols_fallback()
        local clients = vim.lsp.get_active_clients({ bufnr = 0 })
        if #clients > 0 then
          builtin.lsp_document_symbols()
        else
          print("LSP not active. Falling back to local gtags module for current file symbols...")
          -- Safely require and use the local module
          local gtags_ok, gtags = pcall(require, "custom.telescope-gtags")
          if gtags_ok and gtags then
            gtags.showCurrentFileTags()
          else
            print("Failed to load lua/custom/telescope-gtags.lua")
          end
        end
      end

      -- Define a function for finding files using the 'filenametags' file
      local function filenametags_smart()
        if vim.fn.filereadable('filenametags') == 1 then
          builtin.tags({ ctags_file = 'filenametags', prompt_title = "Find File by Name" })
        else
          print("No filenametags file found in the current directory.")
        end
      end

      -- Map keys to the correct functions
      map("n", "<leader>fs", document_symbols_fallback, { desc = "Find Symbols in Document (LSP/gtags fallback)" })
      map("n", "<leader>ft", filenametags_smart, { desc = "Find File by Name (filenametags)" })

      -- General pickers that should always work
      map("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "[F]ind [F]iles" })
      map("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "[F]ind by [G]rep" })
      map("n", "<leader>fb", ":Telescope buffers<CR>", { desc = "[F]ind [B]uffers" })
      map("n", "<leader>fh", ":Telescope help_tags<CR>", { desc = "[F]ind [H]elp" })
    end,
  },
}
