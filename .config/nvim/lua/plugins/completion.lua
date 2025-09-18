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
      {
        "L3MON4D3/LuaSnip",
        dependencies = { "rafamadriz/friendly-snippets" },
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end
      },
      "saadparwaiz1/cmp_luasnip",
      "onsails/lspkind.nvim",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        -- Configure completion matching behavior
        matching = {
          disallow_fuzzy_matching = true,
          disallow_partial_matching = false,
          disallow_prefix_unmatching = true,
        },
        -- Configure completion behavior
        completion = {
          completeopt = "menu,menuone,noselect",
        },
        -- Custom enabled function to control when completion triggers
        enabled = function()
          -- Get current context
          local context = require("cmp.config.context")
          local line = vim.api.nvim_get_current_line()
          local col = vim.api.nvim_win_get_cursor(0)[2]
          
          -- Don't complete after % character
          if col > 0 and line:sub(col, col) == "%" then
            return false
          end
          if col > 1 and line:sub(col-1, col-1) == "%" then
            return false
          end
          
          -- Don't complete in comments (if available)
          if context.in_treesitter_capture("comment") then
            return false
          end
          
          return true
        end,
        -- Modern window styling with borders
        window = {
          completion = cmp.config.window.bordered({
            border = "rounded",
            winhighlight = "Normal:CmpPmenu,FloatBorder:CmpBorder,CursorLine:PmenuSel,Search:None",
          }),
          documentation = cmp.config.window.bordered({
            border = "rounded",
            winhighlight = "Normal:CmpDoc,FloatBorder:CmpDocBorder",
          }),
        },
        -- Enable experimental features
        experimental = {
          ghost_text = {
            hl_group = "CmpGhostText",
          },
        },
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
          -- Snippet source disabled
          -- { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = require("lspkind").cmp_format({
            mode = "symbol_text",
            maxwidth = 60,
            ellipsis_char = "…",
            show_labelDetails = true,
            before = function(entry, vim_item)
              -- Customize menu appearance
              local menu_icon = {
                omni = "🔮",
                luasnip = "🚀",
                buffer = "📝",
                path = "📁",
              }
              vim_item.menu = string.format(" %s %s", 
                menu_icon[entry.source.name] or "💡", 
                ({
                  omni = "LSP",
                  luasnip = "Snippet",
                  buffer = "Buffer", 
                  path = "Path",
                })[entry.source.name] or entry.source.name
              )
              return vim_item
            end
          })
        },
      })
      
      -- Set up custom highlight groups for better UI
      vim.api.nvim_set_hl(0, "CmpPmenu", { bg = "#1e1e2e", fg = "#cdd6f4" })
      vim.api.nvim_set_hl(0, "CmpBorder", { fg = "#585b70" })
      vim.api.nvim_set_hl(0, "CmpDoc", { bg = "#181825", fg = "#cdd6f4" })
      vim.api.nvim_set_hl(0, "CmpDocBorder", { fg = "#585b70" })
      vim.api.nvim_set_hl(0, "CmpGhostText", { fg = "#6c7086", italic = true })
      
      print("Minimal CMP setup completed with enhanced UI")
      
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