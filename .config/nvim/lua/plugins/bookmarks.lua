
-- This file installs the vim-bookmarks plugin.

return {
  {
    "MattesGroeger/vim-bookmarks",
    -- This plugin works out of the box with its default keymaps (mm, mn, etc.)
    -- We lazy-load it on the first time a file is opened.
    event = "BufReadPost",
  },
}
