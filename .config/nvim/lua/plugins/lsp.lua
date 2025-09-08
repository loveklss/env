-- This is the final LSP setup, with diagnostics disabled by default and a proper toggle.

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
    },
    config = function()
      -- *** The New, Simpler, Correct Way ***

      -- 1. Set diagnostics to be OFF by default.
      vim.diagnostic.config({
        virtual_text = false,
        signs = false,
        underline = false,
        update_in_insert = false,
      })

      -- 2. Create a true toggle function that changes the global diagnostic config.
      local function toggle_diagnostics()
        local config = vim.diagnostic.config()
        -- Check one of the values to see the current state.
        if config.virtual_text then
          -- If they are ON, turn them OFF.
          vim.diagnostic.config({ virtual_text = false, signs = false, underline = false, update_in_insert = false })
          print("Diagnostics display OFF")
        else
          -- If they are OFF, turn them ON.
          vim.diagnostic.config({ virtual_text = true, signs = true, underline = true, update_in_insert = true })
          print("Diagnostics display ON")
        end
      end

      -- 3. Map the key and command to this new toggle function.
      local map = vim.keymap.set
      map('n', '<leader>ld', toggle_diagnostics, { desc = "Toggle LSP Diagnostics Display" })
      vim.api.nvim_create_user_command('LspDiagToggle', toggle_diagnostics, { desc = "Toggle display of LSP diagnostics" })

      -- The rest of the LSP configuration remains the same.
      local on_attach = function(client, bufnr)
        map('n', 'gi', vim.lsp.buf.implementation, { buffer = bufnr, desc = "LSP: Go to Implementation" })
        map('n', 'gy', vim.lsp.buf.type_definition, { buffer = bufnr, desc = "LSP: Go to Type Definition" })
        map('n', 'K', vim.lsp.buf.hover, { buffer = bufnr, desc = "LSP: Hover Documentation" })
        map('n', '<C-k>', vim.lsp.buf.signature_help, { buffer = bufnr, desc = "LSP: Signature Help" })
        map('n', '[d', vim.diagnostic.goto_prev, { buffer = bufnr, desc = "LSP: Go to Previous Diagnostic" })
        map('n', ']d', vim.diagnostic.goto_next, { buffer = bufnr, desc = "LSP: Go to Next Diagnostic" })
        map('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr, desc = "LSP: Code Action" })
        map('n', '<leader>rn', vim.lsp.buf.rename, { buffer = bufnr, desc = "LSP: Rename Symbol" })
      end

      local function use_gtags(func_name)
        local gtags_ok, gtags = pcall(require, "custom.telescope-gtags")
        if gtags_ok and gtags and gtags[func_name] then
          gtags[func_name]()
        else
          print("Failed to load or execute function '" .. func_name .. "' in lua/custom/telescope-gtags.lua")
        end
      end

      local function smart_fallback(lsp_func, gtags_func_name)
        local filetype = vim.bo.filetype
        if filetype == 'c' or filetype == 'cpp' then
          if vim.fn.findfile('compile_commands.json', '.') ~= '' then
            lsp_func()
          else
            use_gtags(gtags_func_name)
          end
        else
          if #vim.lsp.get_active_clients({ bufnr = 0 }) > 0 then
            lsp_func()
          else
            use_gtags(gtags_func_name)
          end
        end
      end

      map('n', 'gd', function() smart_fallback(vim.lsp.buf.definition, "showDefinition") end, { desc = "Go to Definition (Smart Fallback)" })
      map('n', 'gD', function() smart_fallback(vim.lsp.buf.declaration, "showDefinition") end, { desc = "Go to Declaration (Smart Fallback)" })
      map('n', 'gr', function() smart_fallback(vim.lsp.buf.references, "showReference") end, { desc = "Find References (Smart Fallback)" })

      require("mason").setup()
      local lspconfig = require("lspconfig")
      local servers = { "lua_ls", "clangd", "pyright" }
      for _, server_name in ipairs(servers) do
        lspconfig[server_name].setup {
          on_attach = on_attach,
        }
      end
    end,
  },
}