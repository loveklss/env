-- This file implements a startup-time check to decide between LSP and Gtags for navigation.

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "j-hui/fidget.nvim",
    },
    config = function()
      vim.lsp.set_log_level("warn") -- Set log level back to warn

      local map = vim.keymap.set

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

      map('n', '<leader>ld', toggle_diagnostics, { desc = "Toggle LSP Diagnostics Display" })
      vim.api.nvim_create_user_command('LspDiagToggle', toggle_diagnostics, { desc = "Toggle display of LSP diagnostics" })

      -- Define the Gtags functions first
      local function use_gtags(func_name)
        local gtags_ok, gtags = pcall(require, "custom.telescope-gtags")
        if gtags_ok and gtags and gtags[func_name] then
          gtags[func_name]()
        else
          print("Failed to load or execute function '" .. func_name .. "' in lua/custom/telescope-gtags.lua")
        end
      end

      -- Define the two possible on_attach functions
      local on_attach_lsp_nav = function(client, bufnr)
        -- Set up omnifunc for LSP completion
        vim.bo[bufnr].omnifunc = 'LspOmnifunc'
        
        -- LSP navigation
        map('n', 'gd', '<cmd>Telescope lsp_definitions<CR>', { buffer = bufnr, desc = "LSP: Go to Definition" })
        map('n', 'gD', vim.lsp.buf.declaration, { buffer = bufnr, desc = "LSP: Go to Declaration" })
        map('n', 'gr', '<cmd>Telescope lsp_references<CR>', { buffer = bufnr, desc = "LSP: Find References" })
        map('n', 'gi', '<cmd>Telescope lsp_implementations<CR>', { buffer = bufnr, desc = "LSP: Go to Implementation" })
        map('n', 'gt', '<cmd>Telescope lsp_type_definitions<CR>', { buffer = bufnr, desc = "LSP: Go to Type Definition" })

        -- Other standard LSP mappings
        map('n', 'K', vim.lsp.buf.hover, { buffer = bufnr, desc = "LSP: Hover Documentation" })
        map('n', '<C-k>', vim.lsp.buf.signature_help, { buffer = bufnr, desc = "LSP: Signature Help" })
        map('n', '[d', vim.diagnostic.goto_prev, { buffer = bufnr, desc = "LSP: Go to Previous Diagnostic" })
        map('n', ']d', vim.diagnostic.goto_next, { buffer = bufnr, desc = "LSP: Go to Next Diagnostic" })
        map('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr, desc = "LSP: Code Action" })
        map('n', '<leader>rn', vim.lsp.buf.rename, { desc = "LSP: Rename Symbol" })
      end

      local on_attach_no_nav = function(client, bufnr)
        -- Set up omnifunc for LSP completion
        vim.bo[bufnr].omnifunc = 'LspOmnifunc'
        
        -- Still map the other useful LSP functions
        map('n', 'K', vim.lsp.buf.hover, { buffer = bufnr, desc = "LSP: Hover Documentation" })
        map('n', '<C-k>', vim.lsp.buf.signature_help, { buffer = bufnr, desc = "LSP: Signature Help" })
        map('n', '[d', vim.diagnostic.goto_prev, { buffer = bufnr, desc = "LSP: Go to Previous Diagnostic" })
        map('n', ']d', vim.diagnostic.goto_next, { buffer = bufnr, desc = "LSP: Go to Next Diagnostic" })
        map('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr, desc = "LSP: Code Action" })
        map('n', '<leader>rn', vim.lsp.buf.rename, { desc = "LSP: Rename Symbol" })
      end

      -- *** The Startup-Time Decision Logic ***
      local on_attach_to_use
      if vim.fn.findfile('compile_commands.json', '.;') ~= '' then
        on_attach_to_use = on_attach_lsp_nav
      else
        map('n', 'gd', function() use_gtags("showDefinition") end, { desc = "Gtags: Go to Definition" })
        map('n', 'gD', function() use_gtags("showDefinition") end, { desc = "Gtags: Go to Declaration" })
        map('n', 'gr', function() use_gtags("showReference") end, { desc = "Gtags: Find References" })
        on_attach_to_use = on_attach_no_nav
      end

      -- Setup Mason and LSP servers
      require("mason").setup()
      require("fidget").setup({})

      -- Use default capabilities and set up omnifunc for completion
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      
      print("LSP configured with default capabilities (using omnifunc for completion)")

      local lspconfig = require("lspconfig")
      
      -- Setup clangd with specific completion configuration
      lspconfig.clangd.setup {
        on_attach = on_attach_to_use,
        capabilities = capabilities,
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
        },
        init_options = {
          usePlaceholders = true,
          completeUnimported = true,
          clangdFileStatus = true,
        },
      }
      
      -- Setup other servers
      local other_servers = { "lua_ls", "pyright" }
      for _, server_name in ipairs(other_servers) do
        lspconfig[server_name].setup {
          on_attach = on_attach_to_use,
          capabilities = capabilities,
        }
      end
    end,
  },
}