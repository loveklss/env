-- This is the final LSP setup, with diagnostics disabled by default and a proper toggle.

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "j-hui/fidget.nvim",
    },
    config = function()
      -- *** Diagnostics Toggling Setup ***
      vim.diagnostic.config({
        virtual_text = false,
        signs = false,
        underline = false,
        update_in_insert = false,
      })

      local function toggle_diagnostics()
        local config = vim.diagnostic.config()
        if config.virtual_text then
          vim.diagnostic.config({ virtual_text = false, signs = false, underline = false, update_in_insert = false })
          print("Diagnostics display OFF")
        else
          vim.diagnostic.config({ virtual_text = true, signs = true, underline = true, update_in_insert = true })
          print("Diagnostics display ON")
        end
      end

      local map = vim.keymap.set
      map('n', '<leader>ld', toggle_diagnostics, { desc = "Toggle LSP Diagnostics Display" })
      vim.api.nvim_create_user_command('LspDiagToggle', toggle_diagnostics, { desc = "Toggle display of LSP diagnostics" })

      -- on_attach: Mappings for LSP-specific actions. These are only active when an LSP server is attached.
      local on_attach = function(client, bufnr)
        -- Mappings for gd, gD, gr are now handled by the global smart_fallback function.
        -- We only map other, non-conflicting LSP actions here.
        map('n', 'gi', '<cmd>Telescope lsp_implementations<CR>', { buffer = bufnr, desc = "LSP: Go to Implementation" })
        map('n', 'gt', '<cmd>Telescope lsp_type_definitions<CR>', { buffer = bufnr, desc = "LSP: Go to Type Definition" })
        map('n', 'K', vim.lsp.buf.hover, { buffer = bufnr, desc = "LSP: Hover Documentation" })
        map('n', '<C-k>', vim.lsp.buf.signature_help, { buffer = bufnr, desc = "LSP: Signature Help" })
        map('n', '[d', vim.diagnostic.goto_prev, { buffer = bufnr, desc = "LSP: Go to Previous Diagnostic" })
        map('n', ']d', vim.diagnostic.goto_next, { buffer = bufnr, desc = "LSP: Go to Next Diagnostic" })
        map('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr, desc = "LSP: Code Action" })
        map('n', '<leader>rn', vim.lsp.buf.rename, { desc = "LSP: Rename Symbol" })
      end

      local function use_gtags(func_name)
        local gtags_ok, gtags = pcall(require, "custom.telescope-gtags")
        if gtags_ok and gtags and gtags[func_name] then
          gtags[func_name]()
        else
          print("Failed to load or execute function '" .. func_name .. "' in lua/custom/telescope-gtags.lua")
        end
      end

      local function smart_fallback(lsp_telescope_cmd, gtags_func_name)
        local filetype = vim.bo.filetype
        if (filetype == 'c' or filetype == 'cpp') then
          -- For C/C++, both compile_commands.json and an active LSP client must exist
          if vim.fn.findfile('compile_commands.json', '.;') ~= '' and #vim.lsp.get_active_clients({ bufnr = 0 }) > 0 then
            vim.cmd(lsp_telescope_cmd)
          else
            use_gtags(gtags_func_name)
          end
        else
          -- For other filetypes, just check if any LSP is active
          if #vim.lsp.get_active_clients({ bufnr = 0 }) > 0 then
            vim.cmd(lsp_telescope_cmd)
          else
            use_gtags(gtags_func_name)
          end
        end
      end

      -- Use the smart_fallback for all navigation actions, calling Telescope for the LSP part.
      map('n', 'gd', function() smart_fallback('Telescope lsp_definitions', "showDefinition") end, { desc = "Go to Definition (Smart)" })
      map('n', 'gD', function() smart_fallback('Telescope lsp_declarations', "showDefinition") end, { desc = "Go to Declaration (Smart)" })
      map('n', 'gr', function() smart_fallback('Telescope lsp_references', "showReference") end, { desc = "Find References (Smart)" })

      -- Setup Mason and LSP servers
      require("mason").setup()
      require("fidget").setup({})

      local lspconfig = require("lspconfig")
      local servers = { "lua_ls", "clangd", "pyright" }
      for _, server_name in ipairs(servers) do
        local server_opts = {
          on_attach = on_attach,
        }

        if server_name == "clangd" then
          server_opts.cmd = {
            "clangd",
            "--background-index",
          }
        end

        lspconfig[server_name].setup(server_opts)
      end
    end,
  },
}
