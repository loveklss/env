
-- This file installs and configures indent-blankline.nvim for indentation guides.

return {
  {
    "lukas-reineke/indent-blankline.nvim",
    enabled = false,
    enabled = false,
    -- The `main` key is a lazy.nvim feature that specifies the main module of the plugin.
    -- It's a good practice for plugins that follow a standard structure.
    main = "ibl",
    -- The `opts` table is a lazy.nvim feature that passes these options to the plugin's setup function.
    opts = {
      -- For more options, see `:h ibl.setup`
      scope = {
        enabled = true,
        show_start = false,
        show_end = false,
      },
    },
  },
}
