
-- This file installs and configures a bufferline at the top of the editor.

return {
  {
    'akinsho/bufferline.nvim',
    enabled = false,
    enabled = false,
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons', -- For file icons
    config = function()
      require("bufferline").setup({
        options = {
          -- Use buffer numbers, names, or both
          mode = "buffers",
          -- Other styling options...
          separator_style = "slant",
          show_buffer_close_icons = true,
          show_close_icon = true,
        }
      })
    end
  }
}
