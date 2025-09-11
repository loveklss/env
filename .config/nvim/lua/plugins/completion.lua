-- Minimal working CMP configuration with LSP via omnifunc

return {
  {
    "hrsh7th/cmp-omni",
  },
  
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-omni",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "onsails/lspkind.nvim",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = {
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.close(),
          ["<CR>"] = cmp.mapping.confirm({ 
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        },
        sources = cmp.config.sources({
          { 
            name = "omni",
            option = {
              disable_omnifuncs = {}  -- Don't disable any omnifuncs
            }
          },
          { name = "luasnip" },
          { name = "buffer" },  -- Move buffer back to first group
          { name = "path" },
        }),
        formatting = {
          format = require("lspkind").cmp_format({
            mode = "symbol_text",
            maxwidth = 50,
            ellipsis_char = "...",
            menu = {
              omni = "[LSP]",
              luasnip = "[Snip]",
              buffer = "[Buf]",
              path = "[Path]",
            }
          })
        },
      })
      
      print("Minimal CMP setup completed")
      
       -- Load LSP omnifunc globally
       require("plugins.lsp-omnifunc")
       print("LspOmnifunc loaded and registered")
      
      -- Add debug commands
      vim.api.nvim_create_user_command('CmpDebug', function()
        print("=== CMP Debug ===")
        print("Omnifunc:", vim.bo.omnifunc)
        print("LSP clients:", #vim.lsp.get_active_clients({bufnr = 0}))
        
        -- Test omnifunc manually
        if vim.bo.omnifunc and vim.bo.omnifunc ~= '' then
          local line = vim.api.nvim_get_current_line()
          local col = vim.api.nvim_win_get_cursor(0)[2]
          print("Testing omnifunc...")
          local ok, result = pcall(vim.fn[vim.bo.omnifunc], 1, '')
          if ok and result >= 0 then
            local base = string.sub(line, result + 1, col)
            local ok2, completions = pcall(vim.fn[vim.bo.omnifunc], 0, base)
            if ok2 then
              print("Omnifunc completions:", type(completions), #(completions or {}))
            else
              print("Omnifunc completion error:", completions)
            end
          else
            print("Omnifunc findstart error:", result)
          end
        end
        
        -- Test CMP sources
        local sources = cmp.get_config().sources
        print("CMP sources configured:", #sources)
        for i, source in ipairs(sources) do
          print("  " .. i .. ". " .. source.name)
        end
      end, {})
      
      -- Test omni source manually
      vim.api.nvim_create_user_command('TestOmni', function()
        local cmp = require('cmp')
        -- Force trigger completion with omni source
        cmp.complete({
          config = {
            sources = {
              { name = "omni" }
            }
          }
        })
      end, {})
      
    end,
  }
}