
-- This file installs and configures nvim-autopairs for auto-closing brackets.

return {
  {
    "windwp/nvim-autopairs",
    -- Load the plugin when we enter insert mode
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({
        -- You can add configuration here if needed, for example, to disable it for certain filetypes
      })

      -- This is a recommended integration with nvim-cmp
      -- It will prevent autopairs from interfering with completion confirmation.
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")
      cmp.event:on(
        "confirm_done",
        cmp_autopairs.on_confirm_done()
      )
    end,
  },
}
