
-- This file installs and configures vim-illuminate

return {
  {
    "RRethy/vim-illuminate",
    enabled = false, -- Temporarily disabled for debugging
    event = "VeryLazy", -- Load it lazily to keep startup fast
    config = function()
      require('illuminate').configure({
        -- default configuration options
        -- providers: ['lsp', 'treesitter', 'regex'],
        delay = 100,
      })
    end
  }
}
