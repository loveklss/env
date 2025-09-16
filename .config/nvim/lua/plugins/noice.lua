-- This file installs and configures noice.nvim for a more modern UI.

return {
  {
    "folke/noice.nvim",
    enabled = not vim.g.vscode,
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("noice").setup({
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        presets = {
          bottom_search = true,
          command_palette = false, -- Disable the default top-aligned command palette
          long_message_to_split = true,
          inc_rename = false,
          lsp_doc_border = false,
        },
        routes = {
          {
            filter = {
              event = "msg_show",
              kind = "emsg",
              find = "E486",
            },
            opts = { skip = true },
          },
          {
            filter = { event = "msg_show", kind = "", find = "change;" },
            opts = { skip = true },
          },
          {
            filter = { event = "msg_show", kind = "", find = "more line" },
            opts = { skip = true },
          },
          {
            filter = { event = "msg_show", kind = "", find = "less;" },
            opts = { skip = true },
          },
          {
            filter = { event = "msg_show", kind = "", find = "Already at" },
            opts = { skip = true },
          },
        },
        -- Custom view for the command line popup
        views = {
          cmdline_popup = {
            position = {
              row = "50%",
              col = "50%",
            },
            size = {
              width = "30%",
              height = "auto",
            },
          },
          pum = {
            backend = "popup",
          }
        },
      })
    end
  }
}
